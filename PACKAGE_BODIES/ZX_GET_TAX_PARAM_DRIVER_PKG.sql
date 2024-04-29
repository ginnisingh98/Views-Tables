--------------------------------------------------------
--  DDL for Package Body ZX_GET_TAX_PARAM_DRIVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_GET_TAX_PARAM_DRIVER_PKG" AS
/* $Header: zxifgetparampkgb.pls 120.38 2006/06/26 22:50:03 lxzhang ship $ */


G_CURRENT_RUNTIME_LEVEL   CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED        CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR             CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION         CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT             CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE         CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT         CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME             CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_GET_TAX_PARAM_DRIVER_PKG.';



PROCEDURE get_driver_value
(
p_struct_name         IN   VARCHAR2,
p_struct_index        IN   BINARY_INTEGER,
p_tax_param_code      IN   VARCHAR2,
x_tax_param_value     OUT  NOCOPY NUMBER,
x_return_status       OUT  NOCOPY VARCHAR2
) IS

BEGIN

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'GET_DRIVER_VALUE.BEGIN','ZX_GET_TAX_PARAM_DRIVER_PKG: GET_DRIVER_VALUE()+');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF p_struct_name = 'TRX_LINE_DIST_TBL' THEN

    IF p_tax_param_code = 'INTERNAL_ORGANIZATION_ID' THEN

      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.INTERNAL_ORGANIZATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLICATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLICATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'LEDGER_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LEDGER_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'CURRENCY_CONVERSION_RATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CURRENCY_CONVERSION_RATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'MINIMUM_ACCOUNTABLE_UNIT' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.MINIMUM_ACCOUNTABLE_UNIT(p_struct_index) ;
    ELSIF p_tax_param_code = 'PRECISION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PRECISION(p_struct_index) ;
    ELSIF p_tax_param_code = 'LEGAL_ENTITY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LEGAL_ENTITY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ESTABLISHMENT_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ESTABLISHMENT_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_AMT' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_AMT(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_QUANTITY' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_QUANTITY(p_struct_index) ;
    ELSIF p_tax_param_code = 'UNIT_PRICE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.UNIT_PRICE(p_struct_index) ;
    ELSIF p_tax_param_code = 'CASH_DISCOUNT' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CASH_DISCOUNT(p_struct_index) ;
    ELSIF p_tax_param_code = 'VOLUME_DISCOUNT' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.VOLUME_DISCOUNT(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRADING_DISCOUNT' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRADING_DISCOUNT(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRANSFER_CHARGE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRANSFER_CHARGE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRANSPORTATION_CHARGE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRANSPORTATION_CHARGE(p_struct_index) ;
    ELSIF p_tax_param_code = 'INSURANCE_CHARGE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.INSURANCE_CHARGE(p_struct_index) ;
    ELSIF p_tax_param_code = 'OTHER_CHARGE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.OTHER_CHARGE(p_struct_index) ;
    ELSIF p_tax_param_code = 'PRODUCT_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PRODUCT_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'PRODUCT_ORG_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PRODUCT_ORG_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_TO_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_TO_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_FROM_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_FROM_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POA_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POA_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POO_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POO_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_TO_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_TO_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_FROM_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_FROM_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ACCOUNT_CCID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ACCOUNT_CCID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RECEIVABLES_TRX_TYPE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RECEIVABLES_TRX_TYPE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_APPLICATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_APPLICATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_TRX_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_TRX_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_LINE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_LINE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_LINE_QUANTITY' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_LINE_QUANTITY(p_struct_index) ;
    ELSIF p_tax_param_code = 'RELATED_DOC_APPLICATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RELATED_DOC_APPLICATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RELATED_DOC_TRX_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RELATED_DOC_TRX_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_FROM_APPLICATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_FROM_APPLICATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_FROM_TRX_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_FROM_TRX_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_FROM_LINE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_FROM_LINE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_FROM_DIST_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_FROM_DIST_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJUSTED_DOC_APPLICATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJUSTED_DOC_APPLICATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJUSTED_DOC_EVENT_CLASS_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJUSTED_DOC_EVENT_CLASS_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJUSTED_DOC_TRX_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJUSTED_DOC_TRX_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJUSTED_DOC_LINE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJUSTED_DOC_LINE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_TO_APPLICATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_TO_APPLICATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_TO_TRX_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_TO_TRX_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_TO_TRX_LINE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_TO_TRX_LINE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_ID_LEVEL2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_ID_LEVEL2(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_ID_LEVEL3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_ID_LEVEL3(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_ID_LEVEL4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_ID_LEVEL4(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_ID_LEVEL5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_ID_LEVEL5(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_ID_LEVEL6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_ID_LEVEL6(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'BATCH_SOURCE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BATCH_SOURCE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'DOC_SEQ_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DOC_SEQ_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'PAYING_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PAYING_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'OWN_HQ_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.OWN_HQ_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRADING_HQ_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRADING_HQ_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POC_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POC_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POI_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POI_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POD_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POD_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TITLE_TRANSFER_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TITLE_TRANSFER_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ASSESSABLE_VALUE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ASSESSABLE_VALUE(p_struct_index) ;
    ELSIF p_tax_param_code = 'ASSET_ACCUM_DEPRECIATION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ASSET_ACCUM_DEPRECIATION(p_struct_index) ;
    ELSIF p_tax_param_code = 'ASSET_COST' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ASSET_COST(p_struct_index) ;
    ELSIF p_tax_param_code = 'NUMERIC1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.NUMERIC1(p_struct_index) ;
    ELSIF p_tax_param_code = 'NUMERIC2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.NUMERIC2(p_struct_index) ;
    ELSIF p_tax_param_code = 'NUMERIC3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.NUMERIC3(p_struct_index) ;
    ELSIF p_tax_param_code = 'NUMERIC4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.NUMERIC4(p_struct_index) ;
    ELSIF p_tax_param_code = 'NUMERIC5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.NUMERIC5(p_struct_index) ;
    ELSIF p_tax_param_code = 'NUMERIC6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.NUMERIC6(p_struct_index) ;
    ELSIF p_tax_param_code = 'NUMERIC7' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.NUMERIC7(p_struct_index) ;
    ELSIF p_tax_param_code = 'NUMERIC8' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.NUMERIC8(p_struct_index) ;
    ELSIF p_tax_param_code = 'NUMERIC9' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.NUMERIC9(p_struct_index) ;
    ELSIF p_tax_param_code = 'NUMERIC10' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.NUMERIC10(p_struct_index) ;
    ELSIF p_tax_param_code = 'FIRST_PTY_ORG_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.FIRST_PTY_ORG_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RDNG_SHIP_TO_PTY_TX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RDNG_SHIP_TO_PTY_TX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RDNG_SHIP_FROM_PTY_TX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RDNG_SHIP_FROM_PTY_TX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RDNG_BILL_TO_PTY_TX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RDNG_BILL_TO_PTY_TX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RDNG_BILL_FROM_PTY_TX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RDNG_BILL_FROM_PTY_TX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RDNG_SHIP_TO_PTY_TX_P_ST_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RDNG_SHIP_TO_PTY_TX_P_ST_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RDNG_SHIP_FROM_PTY_TX_P_ST_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RDNG_SHIP_FROM_PTY_TX_P_ST_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RDNG_BILL_TO_PTY_TX_P_ST_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RDNG_BILL_TO_PTY_TX_P_ST_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RDNG_BILL_FROM_PTY_TX_P_ST_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RDNG_BILL_FROM_PTY_TX_P_ST_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_TO_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_TO_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_FROM_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_FROM_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POA_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POA_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POO_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POO_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'PAYING_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PAYING_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'OWN_HQ_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.OWN_HQ_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRADING_HQ_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRADING_HQ_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POI_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POI_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POD_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POD_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_TO_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_TO_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_FROM_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_FROM_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TITLE_TRANS_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TITLE_TRANS_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_TO_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_TO_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_FROM_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_FROM_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POA_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POA_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POO_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POO_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'PAYING_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PAYING_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'OWN_HQ_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.OWN_HQ_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRADING_HQ_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRADING_HQ_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POI_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POI_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POD_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POD_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_TO_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_TO_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_FROM_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_FROM_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TITLE_TRANS_SITE_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TITLE_TRANS_SITE_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'HQ_ESTB_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.HQ_ESTB_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'MERCHANT_PARTY_TAX_PROF_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.MERCHANT_PARTY_TAX_PROF_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ITEM_DIST_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ITEM_DIST_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'TASK_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TASK_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_FROM_TAX_DIST_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_FROM_TAX_DIST_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJUSTED_DOC_TAX_DIST_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJUSTED_DOC_TAX_DIST_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'AWARD_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.AWARD_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'PROJECT_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PROJECT_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'EXPENDITURE_ORGANIZATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EXPENDITURE_ORGANIZATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_DIST_AMT' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_AMT(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_DIST_QUANTITY' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_QUANTITY(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_DIST_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_DIST_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_CURR_CONV_RATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_CURR_CONV_RATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_DIST_TAX_AMT' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_TAX_AMT(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_DIST_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DIST_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'INTERNAL_ORG_LOCATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.INTERNAL_ORG_LOCATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJUSTED_DOC_DIST_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJUSTED_DOC_DIST_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'CTRL_TOTAL_HDR_TX_AMT' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CTRL_TOTAL_HDR_TX_AMT(p_struct_index) ;
    ELSIF p_tax_param_code = 'CTRL_TOTAL_LINE_TX_AMT' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CTRL_TOTAL_LINE_TX_AMT(p_struct_index) ;
    ELSIF p_tax_param_code = 'SUPPLIER_EXCHANGE_RATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SUPPLIER_EXCHANGE_RATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TAX_INVOICE_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TAX_INVOICE_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_TO_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_TO_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_FROM_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_FROM_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POA_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POA_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POO_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POO_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_TO_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_TO_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_FROM_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_FROM_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'PAYING_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PAYING_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'OWN_HQ_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.OWN_HQ_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRADING_HQ_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRADING_HQ_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POI_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POI_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POD_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POD_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TITLE_TRANSFER_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TITLE_TRANSFER_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ROUNDING_SHIP_TO_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ROUNDING_SHIP_TO_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ROUNDING_SHIP_FROM_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ROUNDING_SHIP_FROM_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ROUNDING_BILL_TO_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ROUNDING_BILL_TO_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'ROUNDING_BILL_FROM_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ROUNDING_BILL_FROM_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RNDG_SHIP_TO_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RNDG_SHIP_TO_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RNDG_SHIP_FROM_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RNDG_SHIP_FROM_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RNDG_BILL_TO_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RNDG_BILL_TO_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'RNDG_BILL_FROM_PARTY_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RNDG_BILL_FROM_PARTY_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_TO_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_TO_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_FROM_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_FROM_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_TO_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_TO_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_FROM_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_FROM_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POA_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POA_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POO_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POO_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'MERCHANT_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.MERCHANT_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'PAYING_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PAYING_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'OWN_HQ_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.OWN_HQ_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRADING_HQ_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRADING_HQ_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POI_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POI_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'POD_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.POD_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TITLE_TRANSFER_PARTY_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TITLE_TRANSFER_PARTY_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_THIRD_PTY_ACCT_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_THIRD_PTY_ACCT_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_THIRD_PTY_ACCT_SITE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_THIRD_PTY_ACCT_SITE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_TO_CUST_ACCT_SITE_USE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_TO_CUST_ACCT_SITE_USE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_TO_CUST_ACCT_SITE_USE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_TO_CUST_ACCT_SITE_USE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SHIP_THIRD_PTY_ACCT_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SHIP_THIRD_PTY_ACCT_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'BILL_THIRD_PTY_ACCT_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BILL_THIRD_PTY_ACCT_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SOURCE_APPLICATION_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SOURCE_APPLICATION_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SOURCE_TRX_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SOURCE_TRX_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'SOURCE_LINE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SOURCE_LINE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_BATCH_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_BATCH_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'OVERRIDING_RECOVERY_RATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.OVERRIDING_RECOVERY_RATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'SOURCE_TAX_LINE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SOURCE_TAX_LINE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'HISTORICAL_TAX_CODE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.HISTORICAL_TAX_CODE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_CURRENCY_CONV_RATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_CURRENCY_CONV_RATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_MAU' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_MAU(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_PRECISION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_PRECISION(p_struct_index) ;
    ELSIF p_tax_param_code = 'INTERFACE_LINE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.INTERFACE_LINE_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'REVERSED_APPLN_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REVERSED_APPLN_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'REVERSED_TRX_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REVERSED_TRX_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'REVERSED_TRX_LINE_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REVERSED_TRX_LINE_ID(p_struct_index) ;

    END IF;

  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(
       G_LEVEL_STATEMENT,
       G_MODULE_NAME||'GET_DRIVER_VALUE.END',
       'ZX_GET_TAX_PARAM_DRIVER_PKG: GET_DRIVER_VALUE()-'||
       ', p_tax_param_code:'||p_tax_param_code||' x_tax_param_value:'||to_char(x_tax_param_value)
     );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||'GET_DRIVER_VALUE',SQLERRM);
      END IF;

END get_driver_value;

PROCEDURE get_driver_value
(
p_struct_name         IN   VARCHAR2,
p_struct_index        IN   BINARY_INTEGER,
p_tax_param_code      IN   VARCHAR2,
x_tax_param_value     OUT  NOCOPY DATE,
x_return_status       OUT  NOCOPY VARCHAR2
) IS

BEGIN

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'GET_DRIVER_VALUE.BEGIN','ZX_GET_TAX_PARAM_DRIVER_PKG: GET_DRIVER_VALUE()+');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF p_struct_name = 'TRX_LINE_DIST_TBL' THEN

    IF p_tax_param_code = 'TRX_DATE' THEN

      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'CURRENCY_CONVERSION_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CURRENCY_CONVERSION_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_SHIPPING_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_SHIPPING_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_RECEIPT_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_RECEIPT_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'RELATED_DOC_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RELATED_DOC_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJUSTED_DOC_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJUSTED_DOC_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_COMMUNICATED_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_COMMUNICATED_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_GL_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_GL_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_DUE_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_DUE_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'DATE1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DATE1(p_struct_index) ;
    ELSIF p_tax_param_code = 'DATE2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DATE2(p_struct_index) ;
    ELSIF p_tax_param_code = 'DATE3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DATE3(p_struct_index) ;
    ELSIF p_tax_param_code = 'DATE4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DATE4(p_struct_index) ;
    ELSIF p_tax_param_code = 'DATE5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DATE5(p_struct_index) ;
    ELSIF p_tax_param_code = 'DATE6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DATE6(p_struct_index) ;
    ELSIF p_tax_param_code = 'DATE7' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DATE7(p_struct_index) ;
    ELSIF p_tax_param_code = 'DATE8' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DATE8(p_struct_index) ;
    ELSIF p_tax_param_code = 'DATE9' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DATE9(p_struct_index) ;
    ELSIF p_tax_param_code = 'DATE10' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DATE10(p_struct_index) ;
    ELSIF p_tax_param_code = 'EXPENDITURE_ITEM_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EXPENDITURE_ITEM_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'SUPPLIER_TAX_INVOICE_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SUPPLIER_TAX_INVOICE_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TAX_INVOICE_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TAX_INVOICE_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'PROVNL_TAX_DETERMINATION_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PROVNL_TAX_DETERMINATION_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'START_EXPENSE_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.START_EXPENSE_DATE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_CURRENCY_CONV_DATE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_CURRENCY_CONV_DATE(p_struct_index) ;

    END IF;

  END IF;

 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(
       G_LEVEL_STATEMENT,
       G_MODULE_NAME||'GET_DRIVER_VALUE.END',
       'ZX_GET_TAX_PARAM_DRIVER_PKG: GET_DRIVER_VALUE()-'||
       'p_tax_param_code:'||p_tax_param_code||' x_tax_param_value:'||to_char(x_tax_param_value));
  END IF;

EXCEPTION

 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||'GET_DRIVER_VALUE',SQLERRM);
   END IF;

END get_driver_value;

PROCEDURE get_driver_value
(
p_struct_name         IN   VARCHAR2,
p_struct_index        IN   BINARY_INTEGER,
p_tax_param_code      IN   VARCHAR2,
x_tax_param_value     OUT  NOCOPY VARCHAR2,
x_return_status       OUT  NOCOPY VARCHAR2
) IS

BEGIN

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'GET_DRIVER_VALUE.BEGIN','ZX_GET_TAX_PARAM_DRIVER_PKG: GET_DRIVER_VALUE()+');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF p_struct_name = 'TRX_LINE_DIST_TBL' THEN

    IF p_tax_param_code = 'ENTITY_CODE' THEN

      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ENTITY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'EVENT_CLASS_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EVENT_CLASS_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'EVENT_TYPE_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EVENT_TYPE_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LEVEL_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LEVEL_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_LEVEL_ACTION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_LEVEL_ACTION(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_DOC_REVISION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_DOC_REVISION(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_CURRENCY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_CURRENCY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'CURRENCY_CONVERSION_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CURRENCY_CONVERSION_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_BUSINESS_CATEGORY' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_BUSINESS_CATEGORY(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_INTENDED_USE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_INTENDED_USE(p_struct_index) ;
    ELSIF p_tax_param_code = 'USER_DEFINED_FISC_CLASS' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.USER_DEFINED_FISC_CLASS(p_struct_index) ;
    ELSIF p_tax_param_code = 'EXEMPT_CERTIFICATE_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EXEMPT_CERTIFICATE_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'EXEMPT_REASON' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EXEMPT_REASON(p_struct_index) ;
    ELSIF p_tax_param_code = 'PRODUCT_FISC_CLASSIFICATION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PRODUCT_FISC_CLASSIFICATION(p_struct_index) ;
    ELSIF p_tax_param_code = 'UOM_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.UOM_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'PRODUCT_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PRODUCT_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'PRODUCT_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PRODUCT_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'PRODUCT_CATEGORY' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PRODUCT_CATEGORY(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_SIC_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_SIC_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'FOB_POINT' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.FOB_POINT(p_struct_index) ;
    ELSIF p_tax_param_code = 'ACCOUNT_STRING' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ACCOUNT_STRING(p_struct_index) ;
    ELSIF p_tax_param_code = 'MERCHANT_PARTY_COUNTRY' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.MERCHANT_PARTY_COUNTRY(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_ENTITY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_ENTITY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_EVENT_CLASS_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_EVENT_CLASS_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_HDR_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_HDR_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_HDR_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_HDR_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_HDR_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_HDR_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_HDR_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_HDR_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_HDR_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_HDR_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_HDR_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_HDR_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_LIN_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_LIN_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_LIN_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_LIN_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_LIN_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_LIN_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_LIN_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_LIN_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_LIN_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_LIN_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_LIN_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_LIN_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'RELATED_DOC_ENTITY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RELATED_DOC_ENTITY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'RELATED_DOC_EVENT_CLASS_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RELATED_DOC_EVENT_CLASS_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'REL_DOC_HDR_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REL_DOC_HDR_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'REL_DOC_HDR_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REL_DOC_HDR_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'REL_DOC_HDR_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REL_DOC_HDR_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'REL_DOC_HDR_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REL_DOC_HDR_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'REL_DOC_HDR_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REL_DOC_HDR_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'REL_DOC_HDR_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REL_DOC_HDR_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'RELATED_DOC_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.RELATED_DOC_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_FROM_ENTITY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_FROM_ENTITY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_FROM_EVENT_CLASS_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_FROM_EVENT_CLASS_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_HDR_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_HDR_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_HDR_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_HDR_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_HDR_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_HDR_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_HDR_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_HDR_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_HDR_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_HDR_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_HDR_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_HDR_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJUSTED_DOC_ENTITY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJUSTED_DOC_ENTITY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_HDR_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_HDR_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_HDR_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_HDR_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_HDR_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_HDR_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_HDR_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_HDR_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_HDR_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_HDR_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_HDR_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_HDR_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_LIN_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_LIN_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_LIN_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_LIN_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_LIN_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_LIN_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_LIN_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_LIN_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_LIN_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_LIN_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_LIN_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_LIN_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJUSTED_DOC_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJUSTED_DOC_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_TO_ENTITY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_TO_ENTITY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_TO_EVENT_CLASS_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_TO_EVENT_CLASS_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_HDR_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_HDR_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_HDR_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_HDR_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_HDR_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_HDR_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_HDR_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_HDR_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_HDR_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_HDR_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_HDR_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_HDR_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_LIN_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_LIN_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_LIN_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_LIN_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_LIN_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_LIN_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_LIN_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_LIN_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_LIN_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_LIN_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_TO_LIN_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_TO_LIN_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'HDR_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.HDR_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'HDR_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.HDR_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'HDR_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.HDR_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'HDR_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.HDR_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'HDR_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.HDR_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'HDR_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.HDR_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_DESCRIPTION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_DESCRIPTION(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_DESCRIPTION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_DESCRIPTION(p_struct_index) ;
    ELSIF p_tax_param_code = 'PRODUCT_DESCRIPTION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PRODUCT_DESCRIPTION(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_WAYBILL_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_WAYBILL_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'BATCH_SOURCE_NAME' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.BATCH_SOURCE_NAME(p_struct_index) ;
    ELSIF p_tax_param_code = 'DOC_SEQ_NAME' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DOC_SEQ_NAME(p_struct_index) ;
    ELSIF p_tax_param_code = 'DOC_SEQ_VALUE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DOC_SEQ_VALUE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_TYPE_DESCRIPTION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_TYPE_DESCRIPTION(p_struct_index) ;
    ELSIF p_tax_param_code = 'MERCHANT_PARTY_NAME' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.MERCHANT_PARTY_NAME(p_struct_index) ;
    ELSIF p_tax_param_code = 'MERCHANT_PARTY_DOCUMENT_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.MERCHANT_PARTY_DOCUMENT_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'MERCHANT_PARTY_REFERENCE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.MERCHANT_PARTY_REFERENCE(p_struct_index) ;
    ELSIF p_tax_param_code = 'MERCHANT_PARTY_TAXPAYER_ID' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.MERCHANT_PARTY_TAXPAYER_ID(p_struct_index) ;
    ELSIF p_tax_param_code = 'MERCHANT_PARTY_TAX_REG_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.MERCHANT_PARTY_TAX_REG_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'ASSET_FLAG' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ASSET_FLAG(p_struct_index) ;
    ELSIF p_tax_param_code = 'ASSET_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ASSET_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'ASSET_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ASSET_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'CHAR1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CHAR1(p_struct_index) ;
    ELSIF p_tax_param_code = 'CHAR2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CHAR2(p_struct_index) ;
    ELSIF p_tax_param_code = 'CHAR3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CHAR3(p_struct_index) ;
    ELSIF p_tax_param_code = 'CHAR4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CHAR4(p_struct_index) ;
    ELSIF p_tax_param_code = 'CHAR5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CHAR5(p_struct_index) ;
    ELSIF p_tax_param_code = 'CHAR6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CHAR6(p_struct_index) ;
    ELSIF p_tax_param_code = 'CHAR7' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CHAR7(p_struct_index) ;
    ELSIF p_tax_param_code = 'CHAR8' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CHAR8(p_struct_index) ;
    ELSIF p_tax_param_code = 'CHAR9' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CHAR9(p_struct_index) ;
    ELSIF p_tax_param_code = 'CHAR10' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CHAR10(p_struct_index) ;
    ELSIF p_tax_param_code = 'TAX_EVENT_CLASS_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TAX_EVENT_CLASS_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TAX_EVENT_TYPE_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TAX_EVENT_TYPE_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'DOC_EVENT_STATUS' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DOC_EVENT_STATUS(p_struct_index) ;
    ELSIF p_tax_param_code = 'DIST_LEVEL_ACTION' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DIST_LEVEL_ACTION(p_struct_index) ;
    ELSIF p_tax_param_code = 'EXPENDITURE_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EXPENDITURE_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'DIST_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DIST_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'DIST_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DIST_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'DIST_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DIST_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'DIST_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DIST_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'DIST_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DIST_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_AMT_INCLUDES_TAX_FLAG' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_AMT_INCLUDES_TAX_FLAG(p_struct_index) ;
    ELSIF p_tax_param_code = 'QUOTE_FLAG' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.Quote_Flag(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULT_TAXATION_COUNTRY' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULT_TAXATION_COUNTRY(p_struct_index) ;
    ELSIF p_tax_param_code = 'HISTORICAL_FLAG' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.HISTORICAL_FLAG(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_LIN_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_LIN_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_LIN_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_LIN_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_LIN_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_LIN_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_LIN_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_LIN_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_LIN_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_LIN_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_LIN_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_LIN_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'DIST_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DIST_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'CTRL_HDR_TX_APPL_FLAG' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.CTRL_HDR_TX_APPL_FLAG(p_struct_index) ;
    ELSIF p_tax_param_code = 'DOCUMENT_SUB_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DOCUMENT_SUB_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'SUPPLIER_TAX_INVOICE_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SUPPLIER_TAX_INVOICE_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_DST_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_DST_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_DST_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_DST_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_DST_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_DST_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_DST_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_DST_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_DST_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_DST_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'APP_FROM_DST_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APP_FROM_DST_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_DST_TRX_USER_KEY1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_DST_TRX_USER_KEY1(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_DST_TRX_USER_KEY2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_DST_TRX_USER_KEY2(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_DST_TRX_USER_KEY3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_DST_TRX_USER_KEY3(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_DST_TRX_USER_KEY4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_DST_TRX_USER_KEY4(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_DST_TRX_USER_KEY5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_DST_TRX_USER_KEY5(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJ_DOC_DST_TRX_USER_KEY6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJ_DOC_DST_TRX_USER_KEY6(p_struct_index) ;
    ELSIF p_tax_param_code = 'INPUT_TAX_CLASSIFICATION_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.INPUT_TAX_CLASSIFICATION_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'OUTPUT_TAX_CLASSIFICATION_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.OUTPUT_TAX_CLASSIFICATION_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'PORT_OF_ENTRY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PORT_OF_ENTRY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TAX_REPORTING_FLAG' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TAX_REPORTING_FLAG(p_struct_index) ;
    ELSIF p_tax_param_code = 'TAX_AMT_INCLUDED_FLAG' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TAX_AMT_INCLUDED_FLAG(p_struct_index) ;
    ELSIF p_tax_param_code = 'COMPOUNDING_TAX_FLAG' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.COMPOUNDING_TAX_FLAG(p_struct_index) ;
    ELSIF p_tax_param_code = 'SOURCE_ENTITY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SOURCE_ENTITY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'SOURCE_EVENT_CLASS_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SOURCE_EVENT_CLASS_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'SOURCE_TRX_LEVEL_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.SOURCE_TRX_LEVEL_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_TO_TRX_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_TO_TRX_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_TO_TRX_LEVEL_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_TO_TRX_LEVEL_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_FROM_TRX_LEVEL_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_FROM_TRX_LEVEL_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'REF_DOC_TRX_LEVEL_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REF_DOC_TRX_LEVEL_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'ADJUSTED_DOC_TRX_LEVEL_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ADJUSTED_DOC_TRX_LEVEL_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULTING_ATTRIBUTE1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE1(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULTING_ATTRIBUTE2' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE2(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULTING_ATTRIBUTE3' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE3(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULTING_ATTRIBUTE4' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE4(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULTING_ATTRIBUTE5' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE5(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULTING_ATTRIBUTE6' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE6(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULTING_ATTRIBUTE7' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE7(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULTING_ATTRIBUTE8' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE8(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULTING_ATTRIBUTE9' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE9(p_struct_index) ;
    ELSIF p_tax_param_code = 'DEFAULTING_ATTRIBUTE10' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.DEFAULTING_ATTRIBUTE10(p_struct_index) ;
    ELSIF p_tax_param_code = 'EXEMPTION_CONTROL_FLAG' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EXEMPTION_CONTROL_FLAG(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLICATION_DOC_STATUS' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLICATION_DOC_STATUS(p_struct_index) ;
    ELSIF p_tax_param_code = 'APPLIED_FROM_TRX_NUMBER' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.APPLIED_FROM_TRX_NUMBER(p_struct_index) ;
    ELSIF p_tax_param_code = 'EXEMPT_REASON_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.EXEMPT_REASON_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_CURRENCY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_CURRENCY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'TRX_LINE_CURRENCY_CONV_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.TRX_LINE_CURRENCY_CONV_TYPE(p_struct_index) ;
    ELSIF p_tax_param_code = 'GLOBAL_ATTRIBUTE1' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.GLOBAL_ATTRIBUTE1(p_struct_index) ;
    ELSIF p_tax_param_code = 'GLOBAL_ATTRIBUTE_CATEGORY' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.GLOBAL_ATTRIBUTE_CATEGORY(p_struct_index) ;
    ELSIF p_tax_param_code = 'LINE_CLASS' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.LINE_CLASS(p_struct_index) ;
    ELSIF p_tax_param_code = 'INTERFACE_ENTITY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.INTERFACE_ENTITY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'REVERSED_ENTITY_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REVERSED_ENTITY_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'REVERSED_EVNT_CLS_CODE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REVERSED_EVNT_CLS_CODE(p_struct_index) ;
    ELSIF p_tax_param_code = 'REVERSED_TRX_LEVEL_TYPE' THEN
      x_tax_param_value := ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.REVERSED_TRX_LEVEL_TYPE(p_struct_index) ;

    END IF;

  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(
       G_LEVEL_STATEMENT,
       G_MODULE_NAME||'GET_DRIVER_VALUE.END',
       'ZX_GET_TAX_PARAM_DRIVER_PKG: GET_DRIVER_VALUE()-'||
       'p_tax_param_code:'||p_tax_param_code||' x_tax_param_value:'||to_char(x_tax_param_value));
  END IF;

EXCEPTION
 WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||'GET_DRIVER_VALUE',SQLERRM);
   END IF;
END get_driver_value;

END ZX_GET_TAX_PARAM_DRIVER_PKG;


/
