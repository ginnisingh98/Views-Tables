--------------------------------------------------------
--  DDL for Package Body ICX_POR_EXT_DIAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_EXT_DIAG" AS
/* $Header: ICXEXTDB.pls 120.1 2006/01/10 11:36:01 sbgeorge noship $*/

--------------------------------------------------------------
--                   Global Variables                       --
--------------------------------------------------------------
gOperatingUnitId	NUMBER := -999;
gOperatingUnitName	hr_operating_units.name%TYPE;
gInventoryOrgId		NUMBER := -999;
gInventoryOrgName	hr_all_organization_units.name%TYPE;

gCategorySetId		NUMBER;
gValidateFlag		VARCHAR2(1);
gStructureId		NUMBER;

--------------------------------------------------------------
--                  Construct Message Procedures            --
--------------------------------------------------------------
-- Get operating unit name
FUNCTION getOperatingUnit(pOperatingUnitId	IN NUMBER)
  RETURN VARCHAR2
IS
  xErrLoc	PLS_INTEGER := 100;
BEGIN
  IF (gOperatingUnitId <> pOperatingUnitId) THEN
    SELECT organization_id,
           name
    INTO   gOperatingUnitId,
           gOperatingUnitName
    FROM   hr_operating_units
    WHERE  organization_id = pOperatingUnitId;
  END IF;
  RETURN gOperatingUnitName;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'OU: '||pOperatingUnitId;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.getOperatingUnit-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END getOperatingUnit;

-- Get inventory organization name
FUNCTION getInventoryOrg(pInventoryOrgId	IN NUMBER)
  RETURN VARCHAR2
IS
  xErrLoc	PLS_INTEGER := 100;
BEGIN
  IF (pInventoryOrgId <> gInventoryOrgId) THEN
    SELECT organization_id,
           name
    INTO   gInventoryOrgId,
           gInventoryOrgName
    FROM   hr_all_organization_units
    WHERE  organization_id = pInventoryOrgId;
  END IF;
  RETURN gInventoryOrgName;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'InvOrg: '||pInventoryOrgId;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.getInventoryOrg-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END getInventoryOrg;

-- Construct message, usually pOrgName carries Operating Unit or
-- Inventory Organization, pDocName carries document number, and
-- pExtraValue carries line number, item number or description,
-- or supplier site code.
FUNCTION constructMessage(pStatus		IN NUMBER,
			  pOrgName		IN VARCHAR2,
			  pDocName		IN VARCHAR2,
			  pExtraValue		IN VARCHAR2,
			  pExtraValue2		IN VARCHAR2)
  RETURN VARCHAR2
IS
  xErrLoc	PLS_INTEGER := 100;
  xMessage	VARCHAR2(4000);
  xIcxSchema	VARCHAR2(20);

BEGIN
  xErrLoc := 100;
  xIcxSchema := ICX_POR_EXT_UTL.getIcxSchema;
  xErrLoc := 200;
  IF pStatus = INVALID_TEMPLATE_LINE THEN
    xMessage := 'Invalid template line ' || pDocName || ', ' ||
      pExtraValue || ' in Operating Unit: ' ||  pOrgName;
    RETURN xMessage;
  ELSIF pStatus = INVALID_BLANKET_LINE THEN
    xMessage := 'Invalid blanket line ' || pDocName || ', ' ||
      pExtraValue || ' in Operating Unit: ' ||  pOrgName;
    RETURN xMessage;
  ELSIF pStatus = INVALID_QUOTATION_LINE THEN
    xMessage := 'Invalid quotation line ' || pDocName || ', ' ||
      pExtraValue || ' in Operating Unit: ' ||  pOrgName;
    RETURN xMessage;
  ELSIF pStatus = INVALID_ASL THEN
    xMessage := 'Invalid ASL ' || pDocName || ', ' ||
      pExtraValue || ' in Operating Unit: ' ||  pOrgName;
    RETURN xMessage;
  ELSIF pStatus = INVALID_ITEM THEN
    xMessage := 'Invalid item ' || pExtraValue ||
      ' in Operating Unit: ' ||  pOrgName;
    RETURN xMessage;
  END IF;

  xErrLoc := 300;
  IF pStatus IN (INACTIVE_TEMPLATE, TEMPLATE_INACTIVE_BLANKET,
                 TEMPLATE_INEFFECTIVE_BLANKET,
                 TEMPLATE_INACTIVE_BLANKET_LINE,
                 TEMPLATE_OUTSIDE_BLANKET)
  THEN
    IF pStatus = INACTIVE_TEMPLATE THEN
      xErrLoc := 310;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_INACTIVE_TEMPLATE');
    ELSIF pStatus = TEMPLATE_INACTIVE_BLANKET THEN
      xErrLoc := 320;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_TEMP_INACTIVE_BLANK');
    ELSIF pStatus = TEMPLATE_INEFFECTIVE_BLANKET THEN
      xErrLoc := 330;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_TEMP_INEFFECTIVE_BLANK');
    ELSIF pStatus = TEMPLATE_INACTIVE_BLANKET_LINE THEN
      xErrLoc := 340;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_TEMP_INACTIVE_BLANK_LN');
    ELSIF pStatus = TEMPLATE_OUTSIDE_BLANKET THEN
      xErrLoc := 350;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_TEMP_OUTSIDE_BLANK_LN');
    END IF;

    xErrLoc := 360;
    fnd_message.set_token('OPERATING_UNIT_NAME', pOrgName);
    xErrLoc := 370;
    fnd_message.set_token('TEMPLATE_NAME', pDocName);
    xErrLoc := 380;
    fnd_message.set_token('ITEM_NUMBER', pExtraValue);
    xErrLoc := 390;
    xMessage := fnd_message.get;

    xErrLoc := 395;
    RETURN xMessage;
  END IF;

  xErrLoc := 400;
  IF pStatus IN (INACTIVE_BLANKET, INEFFECTIVE_BLANKET,
                 INACTIVE_BLANKET_LINE, OUTSIDE_BLANKET,
                 GLOBAL_AGREEMENT_DISABLED,
                 GLOBAL_AGREEMENT_INVALID_ITEM,
                 GLOBAL_AGREEMENT_INVALID_UOM)
  THEN
    IF pStatus = INACTIVE_BLANKET THEN
      xErrLoc := 410;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_INACTIVE_BLANKET');
    ELSIF pStatus = INEFFECTIVE_BLANKET THEN
      xErrLoc := 420;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_INEFFECTIVE_BLANKET');
    ELSIF pStatus = INACTIVE_BLANKET_LINE THEN
      xErrLoc := 430;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_INACTIVE_BLANKET_LINE');
    ELSIF pStatus = OUTSIDE_BLANKET THEN
      xErrLoc := 440;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_OUTSIDE_BLANKET');
    ELSIF pStatus = GLOBAL_AGREEMENT_DISABLED THEN
      xErrLoc := 442;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_GA_DISABLED');
    ELSIF pStatus = GLOBAL_AGREEMENT_INVALID_ITEM THEN
      xErrLoc := 444;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_GA_INVALID_ITEM');
    ELSIF pStatus = GLOBAL_AGREEMENT_INVALID_UOM THEN
      xErrLoc := 446;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_GA_INVALID_UOM');
    END IF;

    xErrLoc := 450;
    fnd_message.set_token('OPERATING_UNIT_NAME', pOrgName);
    xErrLoc := 460;
    fnd_message.set_token('AGREEMENT_NUMBER', pDocName);
    xErrLoc := 470;
    fnd_message.set_token('ITEM_NUMBER', pExtraValue);
    xErrLoc := 480;
    xMessage := fnd_message.get;

    xErrLoc := 490;
    RETURN xMessage;
  END IF;

  xErrLoc := 492;
  IF pStatus = GLOBAL_AGREEMENT_INVALID_SITE THEN
    fnd_message.set_name(xIcxSchema, 'ICX_CAT_GA_INVALID_SITE');
    fnd_message.set_token('OPERATING_UNIT_NAME', pOrgName);
    fnd_message.set_token('AGREEMENT_NUMBER', pDocName);
    fnd_message.set_token('ITEM_NUMBER', pExtraValue);
    fnd_message.set_token('SUPPLIER_SITE_CODE', pExtraValue2);
    xMessage := fnd_message.get;

    RETURN xMessage;
  END IF;

  xErrLoc := 500;
  IF pStatus IN (INACTIVE_QUOTATION, INEFFECTIVE_QUOTATION,
                 QUOTATION_NO_EFFECTIVE_PRICE)
  THEN
    IF pStatus = INACTIVE_QUOTATION THEN
      xErrLoc := 510;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_INACTIVE_QUOTATION');
    ELSIF pStatus = INEFFECTIVE_QUOTATION THEN
      xErrLoc := 520;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_INEFFECTIVE_QUOTATION');
    ELSIF pStatus = QUOTATION_NO_EFFECTIVE_PRICE THEN
      xErrLoc := 530;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_QUOTE_NO_EFFECT_PRICE');
    END IF;

    xErrLoc := 550;
    fnd_message.set_token('OPERATING_UNIT_NAME', pOrgName);
    xErrLoc := 560;
    fnd_message.set_token('QUOTATION_NUMBER', pDocName);
    xErrLoc := 570;
    fnd_message.set_token('ITEM_NUMBER', pExtraValue);
    xErrLoc := 580;
    xMessage := fnd_message.get;

    xErrLoc := 590;
    RETURN xMessage;
  END IF;

  xErrLoc := 600;
  IF pStatus IN (DISABLED_ASL, UNALLOWED_ASL,
                 ASL_NO_PRICE)
  THEN
    IF pStatus = DISABLED_ASL THEN
      xErrLoc := 610;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_DISABLED_ASL');
    ELSIF pStatus = UNALLOWED_ASL THEN
      xErrLoc := 620;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_UNALLOWED_ASL');
    ELSIF pStatus = ASL_NO_PRICE THEN
      xErrLoc := 630;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_ASL_NO_PRICE');
    END IF;

    xErrLoc := 650;
    fnd_message.set_token('INVENTORY_ORGANIZATION', pOrgName);
    xErrLoc := 660;
    fnd_message.set_token('SUPPLIER_NAME', pDocName);
    xErrLoc := 670;
    fnd_message.set_token('ITEM_NUMBER', pExtraValue);
    xErrLoc := 680;
    xMessage := fnd_message.get;

    xErrLoc := 690;
    RETURN xMessage;
  END IF;

  xErrLoc := 700;
  IF pStatus IN (UNPURCHASABLE_OUTSIDE, NOTINTERNAL,
                 UNPURCHASABLE_NOTINTERNAL, ITEM_NO_PRICE)
  THEN
    IF pStatus = UNPURCHASABLE_OUTSIDE THEN
      xErrLoc := 710;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_UNPURCHAE_OUTSIDE');
    ELSIF pStatus = NOTINTERNAL THEN
      xErrLoc := 720;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_NOINTERNAL');
    ELSIF pStatus = UNPURCHASABLE_NOTINTERNAL THEN
      xErrLoc := 730;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_UNPURCHASE_NOINTERNAL');
    ELSIF pStatus = ITEM_NO_PRICE THEN
      xErrLoc := 740;
      fnd_message.set_name(xIcxSchema, 'ICX_CAT_ITEM_NO_PRICE');
    END IF;

    xErrLoc := 750;
    fnd_message.set_token('INVENTORY_ORGANIZATION', pOrgName);
    xErrLoc := 770;
    fnd_message.set_token('ITEM_NUMBER', pExtraValue);
    xErrLoc := 780;
    xMessage := fnd_message.get;

    xErrLoc := 790;
    RETURN xMessage;
  END IF;

  xErrLoc := 800;
  IF pStatus = CATEGORY_NOT_EXTRACTED THEN
    xErrLoc := 810;
    fnd_message.set_name(xIcxSchema, 'ICX_CAT_CATEGORY_NOT_EXTRACTED');
    xErrLoc := 850;
    fnd_message.set_token('OPERATING_UNIT_NAME', pOrgName);
    xErrLoc := 860;
    fnd_message.set_token('ITEM_CATEGORY', pDocName);
    xErrLoc := 870;
    fnd_message.set_token('ITEM_NUMBER', pExtraValue);
    xErrLoc := 880;
    xMessage := fnd_message.get;

    xErrLoc := 890;
    RETURN xMessage;
  END IF;

  xErrLoc := 900;
  IF pStatus = TEMPLATE_HEADER_NOT_EXTRACTED THEN
    xErrLoc := 910;
    fnd_message.set_name(xIcxSchema, 'ICX_CAT_TEMPHEAD_NOT_EXTRACTED');
    xErrLoc := 950;
    fnd_message.set_token('OPERATING_UNIT_NAME', pOrgName);
    xErrLoc := 960;
    fnd_message.set_token('TEMPLATE_NAME', pDocName);
    xErrLoc := 970;
    fnd_message.set_token('ITEM_NUMBER', pExtraValue);
    xErrLoc := 980;
    xMessage := fnd_message.get;

    xErrLoc := 990;
    RETURN xMessage;
  END IF;

  xErrLoc := 1000;
  RETURN xMessage;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.constructMessage-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END constructMessage;

FUNCTION getPriceReport(p_document_type		IN VARCHAR2,
                        p_org_id		IN NUMBER,
                        p_inventory_organization_id IN NUMBER,
                        p_status		IN NUMBER,
                        p_contract_num		IN VARCHAR2,
                        p_internal_item_num	IN VARCHAR2,
                        p_description		IN VARCHAR2,
                        p_supplier_site_code	IN VARCHAR2,
                        p_template_id		IN VARCHAR2,
                        p_supplier		IN VARCHAR2,
                        p_supplier_part_num	IN VARCHAR2)
  RETURN VARCHAR2
IS
  xReport 		VARCHAR2(4000) := '';
  xOperatingUnit	hr_operating_units.name%TYPE;
  xInventoryOrg		hr_all_organization_units.name%TYPE;
  xItemNum		VARCHAR2(2000);
BEGIN
  IF p_document_type IN (ICX_POR_EXT_ITEM.TEMPLATE_TYPE,
                         ICX_POR_EXT_ITEM.CONTRACT_TYPE,
                         ICX_POR_EXT_ITEM.INTERNAL_TEMPLATE_TYPE,
                         ICX_POR_EXT_ITEM.GLOBAL_AGREEMENT_TYPE)
  THEN
    xOperatingUnit := getOperatingUnit(p_org_id);
    IF p_internal_item_num IS NULL THEN
      IF p_supplier_part_num = TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER) THEN
        xItemNum := p_description;
      ELSE
        xItemNum := p_supplier_part_num;
      END IF;
    ELSE
      xItemNum := p_internal_item_num;
    END IF;

    IF p_document_type IN (ICX_POR_EXT_ITEM.CONTRACT_TYPE,
                           ICX_POR_EXT_ITEM.GLOBAL_AGREEMENT_TYPE)
    THEN
      xReport := constructMessage(p_status,
        xOperatingUnit, p_contract_num,
        xItemNum, p_supplier_site_code);
    ELSE
      xReport := constructMessage(p_status,
        xOperatingUnit, p_template_id, xItemNum);
    END IF;
  ELSIF p_document_type IN (ICX_POR_EXT_ITEM.ASL_TYPE,
                            ICX_POR_EXT_ITEM.PURCHASING_ITEM_TYPE,
                            ICX_POR_EXT_ITEM.INTERNAL_ITEM_TYPE)
  THEN
    xInventoryOrg := getInventoryOrg(
      p_inventory_organization_id);

    IF p_document_type = ICX_POR_EXT_ITEM.ASL_TYPE THEN
      xReport := constructMessage(p_status,
        xInventoryOrg, p_supplier,
        p_internal_item_num);
    ELSE
      xReport := constructMessage(p_status,
        xInventoryOrg, NULL, p_internal_item_num);
    END IF;
  END IF;
  RETURN xReport;
END getPriceReport;

--------------------------------------------------------------
--                Check Classification Procedures           --
--------------------------------------------------------------
-- Check category status
FUNCTION checkCategoryStatus(pValue		IN  VARCHAR2,
                             pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xCategoryId		NUMBER;
  xWebEnabledFlag	VARCHAR2(1);
  xStartDate		DATE;
  xEndDate		DATE;
  xDisableDate		DATE;

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkCategoryStatus(pValue: ' || pValue || ')');
  END IF;

  xErrLoc := 100;
  BEGIN
    SELECT category_id,
           web_status,
           start_date_active,
           end_date_active,
           disable_date
    INTO   xCategoryId,
    	   xWebEnabledFlag,
    	   xStartDate,
    	   xEndDate,
    	   xDisableDate
    FROM   mtl_categories_kfv
    WHERE  structure_id = gStructureId
    AND    concatenated_segments = pValue;
  EXCEPTION
    WHEN OTHERS THEN
      xStatus := INVALID_CATEGORY;
      pMessage := 'Invalid category: ' || pValue;
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
      RETURN xStatus;
  END;
    IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
        'Category found with category_id: ' || xCategoryId ||
        ', xWebEnabledFlag: ' || NVL(xWebEnabledFlag, 'NULL') ||
        ', xStartDate: ' || NVL(TO_CHAR(xStartDate, 'MM/DD/YY HH24:MI:SS'),
                                'NULL') || ', xEndDate: ' ||
        NVL(TO_CHAR(xEndDate, 'MM/DD/YY HH24:MI:SS'), 'NULL') ||
        ', xDisableDate: ' || NVL(TO_CHAR(xDisableDate, 'MM/DD/YY HH24:MI:SS'),
                                  'NULL'));
    END IF;

  xErrLoc := 220;
  IF xWebEnabledFlag <> 'Y' THEN
    xStatus := NOT_WEBENABLED_CATEGORY;
    pMessage := 'Not webenabled category: ' || xCategoryId;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
    RETURN xStatus;
  END IF;

  xErrLoc := 240;
  IF (NVL(xStartDate, SYSDATE) > SYSDATE OR
      NVL(xEndDate, SYSDATE+1) <= SYSDATE OR
      NVL(xDisableDate, SYSDATE+1) <= SYSDATE)
  THEN
    xStatus := INACTIVE_CATEGORY;
    pMessage := 'Inactive category: ' || xCategoryId;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
    RETURN xStatus;
  END IF;

  xErrLoc := 300;
  IF gValidateFlag = 'Y' THEN
    BEGIN
      SELECT VALID_FOR_EXTRACT
      INTO   xStatus
      FROM   mtl_category_set_valid_cats
      WHERE  category_set_id = gCategorySetId
      AND    category_id = xCategoryId;
    EXCEPTION
      WHEN OTHERS THEN
        xStatus := INVALID_CATEGORY_SET;
        pMessage := 'Invalid category set: ' || xCategoryId;
        RETURN xStatus;
    END;
  END IF;

  xErrLoc := 400;
  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkCategoryStatus-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END checkCategoryStatus;

-- Check template header status
FUNCTION checkTemplateHeaderStatus(pValue		IN  VARCHAR2,
                                   pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xInactiveDate		DATE;

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkTemplateHeaderStatus(pValue: ' || pValue || ')');
  END IF;

  xErrLoc := 100;
  BEGIN
    SELECT inactive_date
    INTO   xInactiveDate
    FROM   po_reqexpress_headers_all
    WHERE  express_name = pValue
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
      xStatus := INVALID_TEMPLATE_HEADER;
      pMessage := 'Invalid template header: ' || pValue;
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
      RETURN xStatus;
  END;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'Template header found with xInactiveDate: ' ||
      NVL(TO_CHAR(xInactiveDate, 'MM/DD/YY HH24:MI:SS'), 'NULL'));
  END IF;

  xErrLoc := 200;
  IF NVL(xInactiveDate, SYSDATE+1) <= SYSDATE  THEN
    xStatus := INACTIVE_TEMPLATE_HEADER;
    pMessage := 'Inactive template header: ' || pValue;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
    RETURN xStatus;
  END IF;

  xErrLoc := 400;
  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkTemplateHeaderStatus-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END checkTemplateHeaderStatus;


--------------------------------------------------------------
--                    Check Item Procedures                 --
--------------------------------------------------------------
-- Check extracted category status
FUNCTION checkExtCategoryStatus(pCategoryId	IN  NUMBER,
                                pItemNum	IN  VARCHAR2,
                                pMessage	OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xCategoryName		mtl_categories_kfv.concatenated_segments%TYPE;
  xRtCategoryId		NUMBER;

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkExtCategoryStatus(pCategoryId: ' || pCategoryId || ')');
  END IF;

  xErrLoc := 100;
  BEGIN
    SELECT VALID_FOR_EXTRACT,
           rt_category_id
    INTO   xStatus,
           xRtCategoryId
    FROM   icx_cat_categories_tl
    WHERE  key = to_char(pCategoryId)
    AND    type = ICX_POR_EXT_CLASS.CATEGORY_TYPE
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
      xStatus := CATEGORY_NOT_EXTRACTED;
      SELECT concatenated_segments
      INTO   xCategoryName
      FROM   mtl_categories_kfv
      WHERE  category_id = pCategoryId
      AND    rownum = 1;

      xErrLoc := 150;
      pMessage := constructMessage(xStatus, gOperatingUnitName,
                                   xCategoryName, pItemNum);
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
      RETURN xStatus;
  END;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'Category extracted as rt_category_id: '||xRtCategoryId);
  END IF;

  xErrLoc := 400;
  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkExtCategoryStatus-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END checkExtCategoryStatus;

-- Check extracted template header status
FUNCTION checkExtTemplateHeaderStatus(pTemplateName	IN  VARCHAR2,
                                      pItemNum		IN  VARCHAR2,
                                      pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xRtCategoryId		NUMBER;

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkExtTemplateHeaderStatus(pTemplateName: ' || pTemplateName || ')');
  END IF;

  xErrLoc := 100;
  BEGIN
    SELECT VALID_FOR_EXTRACT,
           rt_category_id
    INTO   xStatus,
           xRtCategoryId
    FROM   icx_cat_categories_tl
    WHERE  key = pTemplateName||'_tmpl'
    AND    type = ICX_POR_EXT_CLASS.TEMPLATE_HEADER_TYPE
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
      xStatus := TEMPLATE_HEADER_NOT_EXTRACTED;

      xErrLoc := 150;
      pMessage := constructMessage(xStatus, gOperatingUnitName,
                                   pTemplateName, pItemNum);
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
      RETURN xStatus;
  END;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'Template header extracted as rt_category_id: '||xRtCategoryId);
  END IF;

  xErrLoc := 400;
  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkExtTemplateHeaderStatus-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END checkExtTemplateHeaderStatus;

-- Check blanket/quotation status
FUNCTION checkContractLineStatus(pType			IN  VARCHAR2,
				 pOperatingUnitId	IN  NUMBER,
                                 pPONum			IN  VARCHAR2,
                                 pLineNum		IN  VARCHAR2,
                                 pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xContractLineId	NUMBER;
  xItemNum		VARCHAR2(700);
  xCategoryId		NUMBER;
  xOperatingUnit	hr_operating_units.name%TYPE;

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkContractLineStatus(pType: ' || pType ||
      ', pOperatingUnitId: ' || pOperatingUnitId ||
      ', pPONum: ' || pPONum ||
      ', pLineNum: ' || pLineNum || ')');
  END IF;

  xErrLoc := 100;
  xOperatingUnit := getOperatingUnit(pOperatingUnitId);

  xErrLoc := 120;
  BEGIN
    SELECT pl.po_line_id,
           getContractLineStatus(pl.po_line_id,
                                    ICX_POR_EXT_TEST.gTestMode),
           NVL(mi.concatenated_segments, pl.item_description),
           pl.category_id
    INTO   xContractLineId,
           xStatus,
           xItemNum,
           xCategoryId
    FROM   po_headers_all ph,
           po_lines_all pl,
           financials_system_params_all fsp,
           mtl_system_items_kfv mi
    WHERE  ph.segment1 = pPONum
    AND    (ph.org_id is null and pOperatingUnitId is null or ph.org_id = pOperatingUnitId)
    AND    ph.type_lookup_code = pType
    AND    ph.po_header_id = pl.po_header_id
    AND    pl.line_num = TO_NUMBER(pLineNum)
    AND    (ph.org_id is null and fsp.org_id is null or ph.org_id = fsp.org_id)
    AND    fsp.inventory_organization_id = NVL(mi.organization_id,
             fsp.inventory_organization_id)
    AND    pl.item_id = mi.inventory_item_id (+)
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
      IF pType = 'BLANKET' THEN
        xStatus := INVALID_BLANKET_LINE;
      ELSE
        xStatus := INVALID_QUOTATION_LINE;
      END IF;
      xErrLoc := 150;
      pMessage := constructMessage(xStatus, xOperatingUnit,
                                   pPONum, pLineNum);
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
      RETURN xStatus;
  END;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'Contract line found ' || xContractLineId ||
      ' with status: ' || xStatus);
  END IF;

  xErrLoc := 200;
  IF (xStatus <> VALID_FOR_EXTRACT) THEN
    pMessage := constructMessage(xStatus, xOperatingUnit,
                                 pPONum, xItemNum);
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
    RETURN xStatus;
  END IF;

  xErrLoc := 400;
  xStatus := checkExtCategoryStatus(xCategoryId, xItemNum, pMessage);
  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkContractLineStatus-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END checkContractLineStatus;

-- Check template status
FUNCTION checkTemplateLineStatus(pOperatingUnitId	IN  NUMBER,
                                 pTemplateName		IN  VARCHAR2,
                                 pLineNum		IN  VARCHAR2,
                                 pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xItemNum		VARCHAR2(700);
  xCategoryId		NUMBER;
  xOperatingUnit	hr_operating_units.name%TYPE;

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkTemplateLineStatus(pOperatingUnitId: ' || pOperatingUnitId ||
      ', pTemplateName: ' || pTemplateName ||
      ', pLineNum: ' || pLineNum || ')');
  END IF;

  xErrLoc := 100;
  xOperatingUnit := getOperatingUnit(pOperatingUnitId);

  xErrLoc := 120;
  BEGIN
    SELECT getTemplateLineStatus(prl.express_name,
                                 prl.sequence_num,
                                 prl.org_id,
                                 prh.inactive_date,
                                 prl.po_line_id,
                                 ICX_POR_EXT_TEST.gTestMode),
           NVL(mi.concatenated_segments, prl.item_description),
           prl.category_id
    INTO   xStatus,
           xItemNum,
           xCategoryId
    FROM   po_reqexpress_headers_all prh,
           po_reqexpress_lines_all prl,
           financials_system_params_all fsp,
           mtl_system_items_kfv mi
    WHERE  prh.express_name = pTemplateName
    AND    (prh.org_id is null and pOperatingUnitId is null or prh.org_id = pOperatingUnitId)
    AND    prl.express_name = prh.express_name
    AND    (prh.org_id is null and prl.org_id is null or prl.org_id = prh.org_id)
    AND    prl.sequence_num = TO_NUMBER(pLineNum)
    AND    (prh.org_id is null and fsp.org_id is null or prh.org_id = fsp.org_id)
    AND    fsp.inventory_organization_id = NVL(mi.organization_id,
             fsp.inventory_organization_id)
    AND    prl.item_id = mi.inventory_item_id (+)
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
      xStatus := INVALID_TEMPLATE_LINE;
      xErrLoc := 150;
      pMessage := constructMessage(xStatus, xOperatingUnit,
                                   pTemplateName, pLineNum);
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
      RETURN xStatus;
  END;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'Tempalte line found with status: ' || xStatus);
  END IF;

  xErrLoc := 200;
  IF (xStatus <> VALID_FOR_EXTRACT) THEN
    pMessage := constructMessage(xStatus, xOperatingUnit,
                                 pTemplateName, xItemNum);
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
    RETURN xStatus;
  END IF;

  xErrLoc := 400;
  xStatus := checkExtCategoryStatus(xCategoryId, xItemNum, pMessage);
  xErrLoc := 420;
  IF xStatus = VALID_FOR_EXTRACT THEN
    xStatus := checkExtTemplateHeaderStatus(pTemplateName,
                                            xItemNum, pMessage);
  END IF;

  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkTemplateLineStatus-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END checkTemplateLineStatus;

-- Check ASL status
FUNCTION checkASLStatus(pOperatingUnitId	IN  NUMBER,
                        pASLId			IN  VARCHAR2,
                        pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xSupplier		po_vendors.vendor_name%TYPE;
  xItemNum		VARCHAR2(700);
  xOrgName		hr_all_organization_units.name%TYPE;
  xCategoryId		NUMBER;
  xOperatingUnit	hr_operating_units.name%TYPE;

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkASLStatus(pOperatingUnitId: ' || pOperatingUnitId ||
      ', pASLId: ' || pASLId || ')');
  END IF;

  xErrLoc := 100;
  xOperatingUnit := getOperatingUnit(pOperatingUnitId);

  xErrLoc := 120;
  BEGIN
    SELECT getASLStatus(pasl.asl_id,
                           pasl.disable_flag,
                           pasl.asl_status_id,
                           mi.list_price_per_unit,
                           ICX_POR_EXT_TEST.gTestMode),
           pv.vendor_name,
           mi.concatenated_segments,
           NVL(pasl.category_id, mic.category_id),
           hr.name
    INTO   xStatus,
           xSupplier,
           xItemNum,
           xCategoryId,
           xOrgName
    FROM   po_approved_supplier_list pasl,
           po_vendors pv,
           financials_system_params_all fsp,
           mtl_system_items_kfv mi,
           mtl_item_categories mic,
           hr_all_organization_units hr
    WHERE  pasl.asl_id = pASLId
    AND    (fsp.org_id is null and pOperatingUnitId is null or fsp.org_id = pOperatingUnitId)
    AND    fsp.inventory_organization_id = pasl.owning_organization_id
    AND    pasl.vendor_id = pv.vendor_id
    AND    fsp.inventory_organization_id = mi.organization_id
    AND    pasl.item_id = mi.inventory_item_id
    AND    mic.category_set_id = gCategorySetId
    AND    mic.inventory_item_id = mi.inventory_item_id
    AND	   mic.organization_id = mi.organization_id
    AND    mi.organization_id = hr.organization_id
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
      xStatus := INVALID_ASL;
      xErrLoc := 150;
      pMessage := constructMessage(xStatus, xOperatingUnit,
                                   pASLId, NULL);
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
      RETURN xStatus;
  END;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'ASL found with status: ' || xStatus);
  END IF;

  xErrLoc := 200;
  IF (xStatus <> VALID_FOR_EXTRACT) THEN
    pMessage := constructMessage(xStatus, xOrgName,
                                 xSupplier, xItemNum);
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
    RETURN xStatus;
  END IF;

  xErrLoc := 400;
  xStatus := checkExtCategoryStatus(xCategoryId, xItemNum, pMessage);
  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkASLStatus-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END checkASLStatus;

-- Check master item status
FUNCTION checkMasterStatus(pOperatingUnitId	IN  NUMBER,
                           pItemNum		IN  VARCHAR2,
                           pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xStatus1		PLS_INTEGER;
  xStatus2		PLS_INTEGER;
  xItemId		NUMBER;
  xCategoryId		NUMBER;
  xOrgName		hr_all_organization_units.name%TYPE;
  xLoadPurchasing	VARCHAR2(1);
  xLoadInternal		VARCHAR2(1);
  xOperatingUnit	hr_operating_units.name%TYPE;

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkMasterStatus(pOperatingUnitId: ' || pOperatingUnitId ||
      ', pItemNum: ' || pItemNum || ')');
  END IF;

  xErrLoc := 100;
  xOperatingUnit := getOperatingUnit(pOperatingUnitId);

  xErrLoc := 120;
  BEGIN
    SELECT getPurchasingItemStatus(mi.purchasing_enabled_flag,
                                      mi.outside_operation_flag,
                                      mi.list_price_per_unit,
                                      ICX_POR_EXT_TEST.gTestMode),
           getInternalItemStatus(mi.internal_order_enabled_flag,
                                    ICX_POR_EXT_TEST.gTestMode),
           mi.inventory_item_id,
           mic.category_id,
           hr.name
    INTO   xStatus1,
           xStatus2,
           xItemId,
           xCategoryId,
           xOrgName
    FROM   financials_system_params_all fsp,
           mtl_system_items_kfv mi,
           mtl_item_categories mic,
           hr_all_organization_units hr
    WHERE  (fsp.org_id is null and pOperatingUnitId is null or fsp.org_id = pOperatingUnitId)
    AND    fsp.inventory_organization_id = mi.organization_id
    AND    mi.concatenated_segments = pItemNum
    AND    mic.category_set_id = gCategorySetId
    AND    mic.inventory_item_id = mi.inventory_item_id
    AND	   mic.organization_id = mi.organization_id
    AND    mi.organization_id = hr.organization_id
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
      xStatus := INVALID_ITEM;
      xErrLoc := 150;
      pMessage := constructMessage(xStatus, xOperatingUnit,
                                   NULL, pItemNum);
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
      RETURN xStatus;
  END;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'Item found ' || xItemId || ' with purchasing status: ' ||
      xStatus1 || ', internal status: ' || xStatus2);
  END IF;

  xErrLoc := 200;
  SELECT NVL(load_item_master, 'N'),
         NVL(load_internal_item, 'N')
  INTO   xLoadPurchasing,
         xLoadInternal
  FROM   icx_por_loader_values;

  xErrLoc := 240;
  IF (xLoadPurchasing = 'Y' AND xLoadInternal = 'Y') THEN
    IF (xStatus1 <> VALID_FOR_EXTRACT AND
        xStatus2 <> VALID_FOR_EXTRACT)
    THEN
      xStatus := UNPURCHASABLE_NOTINTERNAL;
    ELSE
      xStatus := VALID_FOR_EXTRACT;
    END IF;
  ELSIF xLoadPurchasing = 'Y' THEN
    xStatus := xStatus1;
  ELSIF xLoadInternal = 'Y' THEN
    xStatus := xStatus2;
  END IF;

  IF (xStatus <> VALID_FOR_EXTRACT) THEN
    pMessage := constructMessage(xStatus, xOrgName,
                                 NULL, pItemNum);
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
    RETURN xStatus;
  END IF;

  xErrLoc := 400;
  xStatus := checkExtCategoryStatus(xCategoryId, pItemNum, pMessage);
  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkMasterStatus-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END checkMasterStatus;

FUNCTION getStatusString(pStatus	IN NUMBER)
  RETURN VARCHAR2
IS
  xStatusStr		VARCHAR2(80);
BEGIN
  IF pStatus = INVALID_BUSINESS_GROUP THEN
    xStatusStr := 'INVALID_BUSINESS_GROUP';
  ELSIF pStatus = INVALID_OPERATING_UNIT THEN
    xStatusStr := 'INVALID_OPERATING_UNIT';
  ELSIF pStatus = INVALID_TYPE THEN
    xStatusStr := 'INVALID_TYPE';
  ELSIF pStatus = INVALID_CATEGORY THEN
    xStatusStr := 'INVALID_CATEGORY';
  ELSIF pStatus = INVALID_TEMPLATE_HEADER THEN
    xStatusStr := 'INVALID_TEMPLATE_HEADER';
  ELSIF pStatus = INVALID_TEMPLATE_LINE THEN
    xStatusStr := 'INVALID_TEMPLATE_LINE';
  ELSIF pStatus = INVALID_BLANKET_LINE THEN
    xStatusStr := 'INVALID_BLANKET_LINE';
  ELSIF pStatus = INVALID_QUOTATION_LINE THEN
    xStatusStr := 'INVALID_QUOTATION_LINE';
  ELSIF pStatus = INVALID_ASL THEN
    xStatusStr := 'INVALID_ASL';
  ELSIF pStatus = INVALID_ITEM THEN
    xStatusStr := 'INVALID_ITEM';
  ELSIF pStatus = VALID_FOR_EXTRACT THEN
    xStatusStr := 'VALID_FOR_EXTRACT';
  ELSIF pStatus = INACTIVE_TEMPLATE THEN
    xStatusStr := 'INACTIVE_TEMPLATE';
  ELSIF pStatus = TEMPLATE_INACTIVE_BLANKET THEN
    xStatusStr := 'TEMPLATE_INACTIVE_BLANKET';
  ELSIF pStatus = TEMPLATE_INEFFECTIVE_BLANKET THEN
    xStatusStr := 'TEMPLATE_INEFFECTIVE_BLANKET';
  ELSIF pStatus = TEMPLATE_INACTIVE_BLANKET_LINE THEN
    xStatusStr := 'TEMPLATE_INACTIVE_BLANKET_LINE';
  ELSIF pStatus = TEMPLATE_OUTSIDE_BLANKET THEN
    xStatusStr := 'TEMPLATE_OUTSIDE_BLANKET';
  ELSIF pStatus = INACTIVE_BLANKET THEN
    xStatusStr := 'INACTIVE_BLANKET';
  ELSIF pStatus = INEFFECTIVE_BLANKET THEN
    xStatusStr := 'INEFFECTIVE_BLANKET';
  ELSIF pStatus = INACTIVE_BLANKET_LINE THEN
    xStatusStr := 'INACTIVE_BLANKET_LINE';
  ELSIF pStatus = OUTSIDE_BLANKET THEN
    xStatusStr := 'OUTSIDE_BLANKET';
  ELSIF pStatus = INACTIVE_QUOTATION THEN
    xStatusStr := 'INACTIVE_QUOTATION';
  ELSIF pStatus = QUOTATION_NO_EFFECTIVE_PRICE THEN
    xStatusStr := 'QUOTATION_NO_EFFECTIVE_PRICE';
  ELSIF pStatus = INEFFECTIVE_QUOTATION THEN
    xStatusStr := 'INEFFECTIVE_QUOTATION';
  ELSIF pStatus = DISABLED_ASL THEN
    xStatusStr := 'DISABLED_ASL';
  ELSIF pStatus = UNALLOWED_ASL THEN
    xStatusStr := 'UNALLOWED_ASL';
  ELSIF pStatus = ASL_NO_PRICE THEN
    xStatusStr := 'ASL_NO_PRICE';
  ELSIF pStatus = UNPURCHASABLE_OUTSIDE THEN
    xStatusStr := 'UNPURCHASABLE_OUTSIDE';
  ELSIF pStatus = NOTINTERNAL THEN
    xStatusStr := 'NOTINTERNAL';
  ELSIF pStatus = UNPURCHASABLE_NOTINTERNAL THEN
    xStatusStr := 'UNPURCHASABLE_NOTINTERNAL';
  ELSIF pStatus = ITEM_NO_PRICE THEN
    xStatusStr := 'ITEM_NO_PRICE';
  ELSIF pStatus = CATEGORY_NOT_EXTRACTED THEN
    xStatusStr := 'CATEGORY_NOT_EXTRACTED';
  ELSIF pStatus = TEMPLATE_HEADER_NOT_EXTRACTED THEN
    xStatusStr := 'TEMPLATE_HEADER_NOT_EXTRACTED';
  ELSIF pStatus = NOT_WEBENABLED_CATEGORY THEN
    xStatusStr := 'NOT_WEBENABLED_CATEGORY';
  ELSIF pStatus = INACTIVE_CATEGORY THEN
    xStatusStr := 'INACTIVE_CATEGORY';
  ELSIF pStatus = INVALID_CATEGORY_SET THEN
    xStatusStr := 'INVALID_CATEGORY_SET';
  ELSIF pStatus = INACTIVE_TEMPLATE_HEADER THEN
    xStatusStr := 'INACTIVE_TEMPLATE_HEADER';
  ELSIF pStatus = GLOBAL_AGREEMENT_DISABLED THEN
    xStatusStr := 'GLOBAL_AGREEMENT_DISABLED';
  ELSIF pStatus = GLOBAL_AGREEMENT_INVALID_SITE THEN
    xStatusStr := 'GLOBAL_AGREEMENT_INVALID_SITE';
  ELSIF pStatus = GLOBAL_AGREEMENT_INVALID_ITEM THEN
    xStatusStr := 'GLOBAL_AGREEMENT_INVALID_ITEM';
  ELSIF pStatus = GLOBAL_AGREEMENT_INVALID_UOM THEN
    xStatusStr := 'GLOBAL_AGREEMENT_INVALID_UOM';
  END IF;

  RETURN xStatusStr;

END getStatusString;


--------------------------------------------------------------
--                     Main Check Procedures                --
--------------------------------------------------------------
-- Check classification status
FUNCTION checkClassStatus(pType		IN  VARCHAR2,
                          pValue	IN  VARCHAR2,
                          pMessage	OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xBusinessGroupId	PLS_INTEGER;
  xOperatingUnitId	PLS_INTEGER;
  xType			VARCHAR2(20);

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkClassStatus(pType: ' || pType ||
      ', pValue: ' || pValue || ')');
  END IF;

  xErrLoc := 100;
  SELECT category_set_id,
         validate_flag,
         structure_id
  INTO   gCategorySetId,
         gValidateFlag,
         gStructureId
  FROM   mtl_default_sets_view
  WHERE  functional_area_id = 2;

  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'Category Set Information[category_set_id: ' || gCategorySetId ||
      ', validate_flag: ' || gValidateFlag ||
      ', structure_id: ' || gStructureId || ']');
  END IF;

  xErrLoc := 200;
  xType := SUBSTR(UPPER(pType), 1, 20);

  IF xType = 'CATEGORY' THEN
    RETURN checkCategoryStatus(pValue, pMessage);
  ELSIF xType = 'TEMPLATE_HEADER' THEN
    RETURN checkTemplateHeaderStatus(pValue, pMessage);
  ELSE
    xStatus := INVALID_TYPE;
    pMessage := 'Invalid type: ' || pType;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);

    RETURN xStatus;
  END IF;

  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkClassStatus-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.printStackTrace;
    raise ICX_POR_EXT_UTL.gException;
END checkClassStatus;

-- Check classification status
FUNCTION checkClassStatus(pType		IN  VARCHAR2,
                          pValue	IN  VARCHAR2)
  RETURN VARCHAR2
IS
  xMessage		VARCHAR2(2000);
  xStatus		PLS_INTEGER;
BEGIN
  xStatus := checkClassStatus(pType, pValue, xMessage);
  RETURN 'Status: ['||getStatusString(xStatus)||'] '||xMessage;
END checkClassStatus;

-- Check item status
FUNCTION checkItemStatus(pBusinessGroup	IN  VARCHAR2,
                         pOperatingUnit	IN  VARCHAR2,
                         pType		IN  VARCHAR2,
                         pValue1	IN  VARCHAR2,
                         pValue2	IN  VARCHAR2,
                         pMessage	OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xBusinessGroupId	PLS_INTEGER;
  xOperatingUnitId	PLS_INTEGER;

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkItemStatus(pBusinessGroup: ' || pBusinessGroup ||
      ', pOperatingUnit: ' || pOperatingUnit ||
      ', pType: ' || pType ||
      ', pValue1: ' || NVL(pValue1, 'NULL') ||
      ', pValue2: ' || NVL(pValue2, 'NULL') || ')');
  END IF;

  xErrLoc := 100;
  -- Check business group
  BEGIN
    SELECT business_group_id
    INTO   xBusinessGroupId
    FROM   per_business_groups_perf
    WHERE  name = pBusinessGroup;
  EXCEPTION
    WHEN OTHERS THEN
      xStatus := INVALID_BUSINESS_GROUP;
      pMessage := 'Invalid business group: ' || pBusinessGroup;
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
      RETURN xStatus;
  END;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'Business group found with business_group_id: ' || xBusinessGroupId);
  END IF;

  xErrLoc := 200;
  -- Check operating unit
  BEGIN
    SELECT organization_id
    INTO   xOperatingUnitId
    FROM   hr_operating_units
    WHERE  business_group_id = xBusinessGroupId
    AND    name = pOperatingUnit;
  EXCEPTION
    WHEN OTHERS THEN
      xStatus := INVALID_OPERATING_UNIT;
      pMessage := 'Invalid operating unit: ' || pOperatingUnit;
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
      RETURN xStatus;
  END;

  xErrLoc := 300;
  xStatus := checkItemStatus(xOperatingUnitId, pType, pValue1,
                             pValue2, pMessage);

  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkItemStatus-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.printStackTrace;
    raise ICX_POR_EXT_UTL.gException;
END checkItemStatus;

-- Check item status
FUNCTION checkItemStatus(pOperatingUnitId	IN  NUMBER,
                         pType			IN  VARCHAR2,
                         pValue1		IN  VARCHAR2,
                         pValue2		IN  VARCHAR2,
                         pMessage		OUT NOCOPY VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc		PLS_INTEGER := 100;
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xType			VARCHAR2(20);

BEGIN
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'checkItemStatus(pOperatingUnitID: ' || pOperatingUnitId ||
      ', pType: ' || pType ||
      ', pValue1: ' || NVL(pValue1, 'NULL') ||
      ', pValue2: ' || NVL(pValue2, 'NULL') || ')');
  END IF;

  xErrLoc := 100;
  SELECT category_set_id,
         validate_flag,
         structure_id
  INTO   gCategorySetId,
         gValidateFlag,
         gStructureId
  FROM   mtl_default_sets_view
  WHERE  functional_area_id = 2;

  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'Category Set Information[category_set_id: ' || gCategorySetId ||
      ', validate_flag: ' || gValidateFlag ||
      ', structure_id: ' || gStructureId || ']');
  END IF;

  xErrLoc := 200;

  xType := SUBSTR(UPPER(pType), 1, 20);

  IF xType IN ('BLANKET', 'QUOTATION') THEN
    RETURN checkContractLineStatus(xType, pOperatingUnitId, pValue1,
                                   pValue2, pMessage);
  ELSIF xType = 'TEMPLATE' THEN
    RETURN checkTemplateLineStatus(pOperatingUnitId, pValue1,
                                   pValue2, pMessage);
  ELSIF xType = 'ASL' THEN
    RETURN checkASLStatus(pOperatingUnitId, pValue1, pMessage);
  ELSIF xType = 'ITEM' THEN
    RETURN checkMasterStatus(pOperatingUnitId, pValue1, pMessage);
  ELSE
    xStatus := INVALID_TYPE;
    pMessage := 'Invalid type: ' || pType;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, pMessage);
    RETURN xStatus;
  END IF;

  xErrLoc := 300;
  RETURN xStatus;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_DIAG.checkItemStatus-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.printStackTrace;
    raise ICX_POR_EXT_UTL.gException;
END checkItemStatus;

-- Check item status
FUNCTION checkItemStatus(pBusinessGroup	IN  VARCHAR2,
                         pOperatingUnit	IN  VARCHAR2,
                         pType		IN  VARCHAR2,
                         pValue1	IN  VARCHAR2,
                         pValue2	IN  VARCHAR2)
  RETURN VARCHAR2
IS
  xMessage		VARCHAR2(2000);
  xStatus		PLS_INTEGER;
BEGIN
  xStatus := checkItemStatus(pBusinessGroup, pOperatingUnit, pType,
                             pValue1, pValue2, xMessage);
  RETURN 'Status: ['||getStatusString(xStatus)||'] '||xMessage;
END checkItemStatus;

-- Check item status
FUNCTION checkItemStatus(pOperatingUnitId	IN  NUMBER,
                         pType			IN  VARCHAR2,
                         pValue1		IN  VARCHAR2,
                         pValue2		IN  VARCHAR2)
  RETURN VARCHAR2
IS
  xMessage		VARCHAR2(2000);
  xStatus		PLS_INTEGER;
BEGIN
  xStatus := checkItemStatus(pOperatingUnitId, pType, pValue1,
                             pValue2, xMessage);
  RETURN 'Status: ['||getStatusString(xStatus)||'] '||xMessage;
END checkItemStatus;

--------------------------------------------------------------
--          Functions to get extracted price status         --
--------------------------------------------------------------
FUNCTION getContractLineStatus(p_contract_line_id	IN NUMBER,
                               p_test_mode		IN VARCHAR2)
  RETURN NUMBER
IS
  xStatus		PLS_INTEGER := VALID_FOR_EXTRACT;
  xString 		VARCHAR2(2000);
  xHTypeLookupCode	po_headers_all.type_lookup_code%TYPE;
  xHApprovedDate	DATE;
  xHApprovedFlag	VARCHAR2(1);
  xHCancelFlag		VARCHAR2(1);
  xHFrozenFlag		VARCHAR2(1);
  xHClosedCode		po_headers_all.closed_code%TYPE;
  xLClosedCode		po_lines_all.closed_code%TYPE;
  xLCancelFlag		VARCHAR2(1);
  xHStatusLookupCode	po_headers_all.status_lookup_code%TYPE;
  xHQuotationClassCode	po_headers_all.quotation_class_code%TYPE;
  xHStartDate		DATE;
  xHEndDate		DATE;
  xLExpirationDate	DATE;

BEGIN
  xString :=
    'SELECT ' || VALID_FOR_EXTRACT || ' ';
  IF p_test_mode = 'Y' THEN
    xString := xString ||
      'FROM ipo_line_types_b plt, ' ||
      'ipo_headers_all ph, ' ||
      'ipo_lines_all pl ';
  ELSE
    xString := xString ||
      'FROM po_line_types_b plt, ' ||
      'po_headers_all ph, ' ||
      'po_lines_all pl ';
  END IF;
  xString := xString ||
    'WHERE pl.po_line_id = :contract_line_id ' ||
    'AND ph.po_header_id = pl.po_header_id ' ||
    'AND ph.type_lookup_code IN (''BLANKET'', ''QUOTATION'') ' ||
    'AND ((ph.approved_date IS NOT NULL AND ' ||
    '      ph.approved_flag = ''Y'' AND ' ||
    '      NVL(ph.cancel_flag, ''N'') <> ''Y'' AND ' ||
    '      NVL(ph.frozen_flag, ''N'') <> ''Y'' AND ' ||
    '      NVL(ph.closed_code, ''OPEN'') NOT IN (''CLOSED'', ''FINALLY CLOSED'') AND ' ||
    '      NVL(pl.closed_code, ''OPEN'') NOT IN (''CLOSED'', ''FINALLY CLOSED'') AND ' ||
    '      NVL(pl.cancel_flag, ''N'') <> ''Y'') OR ' ||
    '     (ph.status_lookup_code = ''A'' AND ' ||
    '      ph.quotation_class_code = ''CATALOG'')) ' ||
    'AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(ph.start_date), TRUNC( SYSDATE - 1)) AND ' ||
    '                           NVL(TRUNC(ph.end_date), TRUNC( SYSDATE + 1)) ' ||
    'AND TRUNC( SYSDATE) <= NVL(TRUNC(pl.expiration_date), TRUNC( SYSDATE+1)) ' ||
    'AND pl.line_type_id = plt.line_type_id  ' ||
    'AND NVL(plt.outside_operation_flag, ''N'') = ''N'' ' ||
    'AND (ph.type_lookup_code =''BLANKET'' OR ' ||
    '     (ph.type_lookup_code =''QUOTATION'' AND ' ||
    '      (NVL(ph.approval_required_flag,''N'') = ''N'' OR ' ||
    '       (ph.approval_required_flag =''Y'' AND ' ||
    '        EXISTS (SELECT ''current approved effective price break'' ';

  IF p_test_mode = 'Y' THEN
    xString := xString ||
    '                FROM ipo_line_locations_all pll, ' ||
    '                     ipo_quotation_approvals_all pqa ';
  ELSE
    xString := xString ||
    '                FROM po_line_locations_all pll, ' ||
    '                     po_quotation_approvals_all pqa ';
  END IF;

  xString := xString ||
    '                WHERE pl.po_line_id = pll.po_line_id ' ||
    '                AND SYSDATE BETWEEN NVL(pll.start_date, SYSDATE-1) AND ' ||
    '                                    NVL(pll.end_date, SYSDATE+1) ' ||
    '                AND pqa.line_location_id = pll.line_location_id ' ||
    '                AND pqa.approval_type IN (''ALL ORDERS'',''REQUISITIONS'') ' ||
    '                AND SYSDATE BETWEEN NVL(pqa.start_date_active, SYSDATE-1) ' ||
    '                AND NVL(pqa.end_date_active, SYSDATE+1)))))) ';

  BEGIN
    EXECUTE IMMEDIATE xString INTO xStatus
      USING p_contract_line_id;

    /* Bug#3352834:  Validating the Inventory Item's Purchasable Mode.
     *               after validating the blanket.
     */
    xString :=
        'SELECT decode(mi.inventory_item_id,  ' ||
        '               NULL, ' || VALID_FOR_EXTRACT || ', ' ||
		  '                 decode(NVL(mi.purchasing_enabled_flag, ''N''), ' ||
		  '	                  ''N'', ' || INVALID_BLANKET_LINE || ', ' ||
		  '	                  ' || VALID_FOR_EXTRACT || ')) ' ||
        'FROM  ';
    IF p_test_mode = 'Y' THEN
       xString := xString ||
               'ipo_headers_all ph, ' ||
               'ipo_lines_all pl, ' ||
               'imtl_system_items_kfv mi, ' ||
               'ifinancials_system_params_all fsp ';
    ELSE
       xString := xString ||
               'po_headers_all ph, ' ||
               'po_lines_all pl, ' ||
               'mtl_system_items_kfv mi, ' ||
               'financials_system_params_all fsp ';
    END IF;
    xString := xString ||
        'WHERE  pl.po_line_id = :contract_line_id ' ||
        '   AND ph.po_header_id = pl.po_header_id  ' ||
        '   AND ph.type_lookup_code IN (''BLANKET'', ''QUOTATION'') ' ||
        '   AND pl.item_id = mi.inventory_item_id (+) ' ||
        '   AND (ph.org_id is null and fsp.org_id is null or ph.org_id = fsp.org_id) ' ||
        '   AND fsp.inventory_organization_id = NVL(mi.organization_id, fsp.inventory_organization_id)';

    BEGIN
      EXECUTE IMMEDIATE xString INTO xStatus
        USING p_contract_line_id;
      /* Not handling the exception, as the query would always return
         a record. */
    END;

    RETURN xStatus;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xString :=
        'SELECT  ph.type_lookup_code, ' ||
        'ph.approved_date, ' ||
        'ph.approved_flag, ' ||
        'ph.cancel_flag, ' ||
        'ph.frozen_flag, ' ||
        'ph.closed_code, ' ||
        'pl.closed_code, ' ||
        'pl.cancel_flag, ' ||
        'ph.status_lookup_code, ' ||
        'ph.quotation_class_code, ' ||
        'ph.start_date, ' ||
        'ph.end_date, ' ||
        'pl.expiration_date ';

      IF p_test_mode = 'Y' THEN
        xString := xString ||
          'FROM ipo_headers_all ph, ' ||
          'ipo_lines_all pl ';
      ELSE
        xString := xString ||
          'FROM po_headers_all ph, ' ||
          'po_lines_all pl ';
      END IF;
      xString := xString ||
        'WHERE ph.po_header_id = pl.po_header_id ' ||
        'AND pl.po_line_id = :contract_line_id';

      EXECUTE IMMEDIATE xString
        INTO  xHTypeLookupCode,
              xHApprovedDate,
              xHApprovedFlag,
              xHCancelFlag,
              xHFrozenFlag,
              xHClosedCode,
              xLClosedCode,
              xLCancelFlag,
              xHStatusLookupCode,
              xHQuotationClassCode,
              xHStartDate,
              xHEndDate,
              xLExpirationDate
        USING p_contract_line_id;

      IF xHTypeLookupCode = 'BLANKET' THEN
        IF NOT (xHApprovedDate IS NOT NULL AND
                xHApprovedFlag = 'Y' AND
                NVL(xHCancelFlag, 'N') <> 'Y' AND
                NVL(xHFrozenFlag, 'N') <> 'Y' AND
                NVL(xHClosedCode, 'OPEN') NOT IN
                  ('CLOSED', 'FINALLY CLOSED'))
        THEN
          RETURN INACTIVE_BLANKET;
        END IF;
        IF NOT (TRUNC(SYSDATE) BETWEEN
                  NVL(TRUNC(xHStartDate), TRUNC(SYSDATE-1)) AND
                  NVL(TRUNC(xHEndDate), TRUNC(SYSDATE+1)))
        THEN
          RETURN INEFFECTIVE_BLANKET;
        END IF;
        IF NOT (NVL(xLClosedCode, 'OPEN') NOT IN
                  ('CLOSED', 'FINALLY CLOSED') AND
                NVL(xLCancelFlag, 'N') <> 'Y' AND
                TRUNC(SYSDATE) <= NVL(TRUNC(xLExpirationDate),
                                      TRUNC(SYSDATE+1)))
        THEN
          RETURN INACTIVE_BLANKET_LINE;
        END IF;
        -- Otherwise
        RETURN OUTSIDE_BLANKET;
      ELSIF xHTypeLookupCode = 'QUOTATION' THEN
        IF (xHStatusLookupCode <> 'A' OR
            xHQuotationClassCode <> 'CATALOG')
        THEN
          RETURN INACTIVE_QUOTATION;
        END IF;
        IF NOT (TRUNC(SYSDATE) BETWEEN
                  NVL(TRUNC(xHStartDate), TRUNC(SYSDATE-1)) AND
                  NVL(TRUNC(xHEndDate), TRUNC(SYSDATE+1)) AND
                TRUNC(SYSDATE) <= NVL(TRUNC(xLExpirationDate),
                                      TRUNC(SYSDATE+1)))
        THEN
          RETURN INEFFECTIVE_QUOTATION;
        END IF;
        -- Otherwise
        RETURN QUOTATION_NO_EFFECTIVE_PRICE;
      ELSE
        -- Should reach here
        RETURN INVALID_BLANKET_LINE;
      END IF;
  END;

  RETURN xStatus;
END getContractLineStatus;

FUNCTION getGlobalAgreementStatus(p_enabled_flag                IN VARCHAR2,
                                  p_purchasing_site             IN VARCHAR2,
                                  p_inactive_date               IN DATE,
                                  p_local_purchasing_enabled    IN VARCHAR2,
                                  p_local_outside_operation     IN VARCHAR2,
                                  p_local_uom_code              IN VARCHAR2,
                                  p_purchasing_enabled          IN VARCHAR2,
                                  p_outside_operation           IN VARCHAR2,
                                  p_uom_code                    IN VARCHAR2,
                                  p_purchasing_uom_code         IN VARCHAR2,
                                  p_test_mode                   IN VARCHAR2)
  RETURN NUMBER
IS
  xStatus PLS_INTEGER := VALID_FOR_EXTRACT;
BEGIN
  IF NVL(p_enabled_flag, 'N') = 'N' THEN
    RETURN GLOBAL_AGREEMENT_DISABLED;
  END IF;
  IF (p_purchasing_site = 'N' OR
      NVL(p_inactive_date, SYSDATE+1) <= SYSDATE)
  THEN
    RETURN GLOBAL_AGREEMENT_INVALID_SITE;
  END IF;
  IF (p_local_purchasing_enabled = 'N' OR p_purchasing_enabled = 'N' OR
      p_local_outside_operation <> 'N' OR p_outside_operation <> 'N')
  THEN
    RETURN GLOBAL_AGREEMENT_INVALID_ITEM;
  END IF;
  IF (p_uom_code IS NOT NULL AND
      p_local_uom_code IS NOT NULL AND
      p_purchasing_uom_code IS NOT NULL AND
      p_uom_code <> p_local_uom_code AND
      p_uom_code <> p_purchasing_uom_code)
  THEN
    BEGIN
      SELECT VALID_FOR_EXTRACT
      INTO   xStatus
      FROM   dual
      WHERE  EXISTS (SELECT 'same UOM class'
                     FROM   mtl_units_of_measure uom1,
  	  	            mtl_units_of_measure uom2,
  	  	            mtl_units_of_measure uom3
	  	     WHERE  uom1.uom_code = p_uom_code
		     AND    uom2.uom_code = p_local_uom_code
		     AND    uom3.uom_code = p_purchasing_uom_code
		     AND    uom1.uom_class = uom2.uom_class
		     AND    uom1.uom_class = uom3.uom_class);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN GLOBAL_AGREEMENT_INVALID_UOM;
    END;
  END IF;

  RETURN xStatus;
END getGlobalAgreementStatus;

FUNCTION getTemplateLineStatus(p_template_id            IN VARCHAR2,
                               p_template_line_id       IN NUMBER,
                               p_org_id                 IN NUMBER,
                               p_inactive_date		IN DATE,
                               p_contract_line_id	IN NUMBER,
                               p_test_mode		IN VARCHAR2)
  RETURN NUMBER
IS
  xString VARCHAR2(2000);
  xStatus PLS_INTEGER := VALID_FOR_EXTRACT;
BEGIN
  IF NVL(p_inactive_date, SYSDATE+1) <= SYSDATE THEN
  RETURN INACTIVE_TEMPLATE;
  END IF;

  IF (p_contract_line_id IS NOT NULL AND
      p_contract_line_id <> ICX_POR_EXT_ITEM.NULL_NUMBER)
  THEN
    xStatus := getContractLineStatus(p_contract_line_id, p_test_mode);
    IF xStatus = VALID_FOR_EXTRACT THEN
    RETURN VALID_FOR_EXTRACT;
    ELSIF xStatus = INACTIVE_BLANKET THEN
    RETURN TEMPLATE_INACTIVE_BLANKET;
    ELSIF xStatus = INEFFECTIVE_BLANKET THEN
    RETURN TEMPLATE_INEFFECTIVE_BLANKET;
    ELSIF xStatus = INACTIVE_BLANKET_LINE THEN
    RETURN TEMPLATE_INACTIVE_BLANKET_LINE;
    ELSIF xStatus = OUTSIDE_BLANKET THEN
    RETURN TEMPLATE_OUTSIDE_BLANKET;
    ELSE
      -- Should not reach here
    RETURN INACTIVE_TEMPLATE;
    END IF;
  END IF;

  /* Bug#3464695:  Validating the Inventory Item's Purchasable Mode.
   *               after validating the template.
   * Bug#3524364:  Also validate the Inventory Item's internally
   *               orderable flag.
   */
  xString :=
  'SELECT decode(mi.inventory_item_id, NULL, ' ||
                 VALID_FOR_EXTRACT || ', ' ||
                 'decode(NVL(mi.purchasing_enabled_flag, ''N''), ''N'', ' ||
                        'decode(NVL(mi.internal_order_enabled_flag, ''N''), ''Y'', ' ||
                               'decode(prl.source_type_code, ''INVENTORY'', ' ||
                                       VALID_FOR_EXTRACT || ', ' ||
                                       INVALID_TEMPLATE_LINE || '), ' ||
                                INVALID_TEMPLATE_LINE || '), ' ||
                         VALID_FOR_EXTRACT || ')) ' ||
  'FROM  ';
  IF p_test_mode = 'Y' THEN
     xString := xString ||
             'ipo_reqexpress_lines_all prl, ' ||
             'imtl_system_items_kfv mi, ' ||
             'ifinancials_system_params_all fsp ' ;
  ELSE
     xString := xString ||
             'po_reqexpress_lines_all prl, ' ||
             'mtl_system_items_kfv mi, ' ||
             'financials_system_params_all fsp ';
  END IF;

  xString := xString ||
      'WHERE prl.express_name = :express_name ' ||
      '  AND prl.sequence_num = :sequence_num  ' ||
      '  AND (prl.org_id is null and :org_id is null or prl.org_id = :org_id)  ' ||
      '  AND prl.item_id = mi.inventory_item_id (+)  ' ||
      '  AND (prl.org_id is null and fsp.org_id is null or prl.org_id =  fsp.org_id) ' ||
      '  AND fsp.inventory_organization_id = NVL(mi.organization_id, fsp.inventory_organization_id)';

  BEGIN
    EXECUTE IMMEDIATE xString INTO xStatus
      USING p_template_id, p_template_line_id, p_org_id, p_org_id;
      /* Not handling the exception, as the query would always return
         a record. */
  END;

  RETURN xStatus;
END getTemplateLineStatus;

FUNCTION getASLStatus(p_asl_id			IN NUMBER,
                      p_disable_flag		IN VARCHAR2,
                      p_asl_status_id		IN NUMBER,
                      p_item_price		IN NUMBER,
                      p_test_mode		IN VARCHAR2)
  RETURN NUMBER
IS
  xStatus	PLS_INTEGER := VALID_FOR_EXTRACT;
  xString	VARCHAR2(2000);
BEGIN
  IF (NVL(p_disable_flag, 'N') <> 'N') THEN
  RETURN DISABLED_ASL;
  END IF;

  IF (p_item_price IS NULL) THEN
  RETURN ASL_NO_PRICE;
  END IF;

  xString :=
    'SELECT ' || VALID_FOR_EXTRACT || ' ';
  IF p_test_mode = 'Y' THEN
    xString := xString ||
      'FROM ipo_asl_status_rules ';
  ELSE
    xString := xString ||
      'FROM po_asl_status_rules ';
  END IF;
  xString := xString ||
    'WHERE status_id = :asl_status_id ' ||
    'AND business_rule = ''2_SOURCING'' ' ||
    'AND allow_action_flag = ''Y'' ' ||
    'AND rownum = 1';

  BEGIN
    EXECUTE IMMEDIATE xString INTO xStatus
      USING p_asl_status_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN UNALLOWED_ASL;
  END;

  /* Bug#3464695:  Validating the Inventory Item's Purchasable Mode.
   *               after validating the ASL.
   * Bug#3738786: owning_organization_id in po_approved_supplier_list
   *              is the inventory_organization_id and not org_id in financial_system_params_all
   *              Since the following query is only to find the validity of item in the ASL
   *              AND ASLs are inventory org based and not OU based(which means to create
   *              an ASL in an inventory org-INV1 the master item to be attached should be
   *              enabled in INV1)
   *              So, we can remove the join with financials_system_params_all completely
   */
  xString :=
      'SELECT decode(mi.inventory_item_id,  ' ||
      '               NULL, ' || VALID_FOR_EXTRACT || ', ' ||
      '                 decode(NVL(mi.purchasing_enabled_flag, ''N''), ' ||
      '                       ''N'', ' || INVALID_ASL || ', ' ||
      '                       ' || VALID_FOR_EXTRACT || ')) ' ||
      'FROM  ';
  IF p_test_mode = 'Y' THEN
     xString := xString ||
             'ipo_approved_supplier_list pasl, ' ||
             'imtl_system_items_kfv mi ';
  ELSE
     xString := xString ||
             'po_approved_supplier_list pasl, ' ||
             'mtl_system_items_kfv mi ';
  END IF;
  xString := xString ||
      'WHERE pasl.asl_id = :asl_id ' ||
      '  AND pasl.item_id = mi.inventory_item_id ' ||
      '  AND pasl.owning_organization_id = mi.organization_id ';

  BEGIN
    EXECUTE IMMEDIATE xString INTO xStatus
      USING p_asl_id;
    /* Not handling the exception, as the query would always return
       a record. */
  END;

  RETURN xStatus;
END getASLStatus;

FUNCTION getPurchasingItemStatus(p_purchasing_enabled_flag	IN VARCHAR2,
                                 p_outside_operation_flag	IN VARCHAR2,
                                 p_list_price_per_unit		IN NUMBER,
                                 p_test_mode			IN VARCHAR2)
  RETURN NUMBER
IS
  xStatus PLS_INTEGER := VALID_FOR_EXTRACT;
BEGIN
  IF (p_list_price_per_unit IS NULL) THEN
  RETURN ITEM_NO_PRICE;
  END IF;

  IF NOT (p_purchasing_enabled_flag = 'Y' AND
          NVL(p_outside_operation_flag, 'N') <> 'Y')
  THEN
  RETURN UNPURCHASABLE_OUTSIDE;
  END IF;

  RETURN xStatus;
END getPurchasingItemStatus;

FUNCTION getInternalItemStatus(p_internal_order_enabled_flag	IN VARCHAR2,
                               p_test_mode 			IN VARCHAR2)
  RETURN NUMBER
IS
  xStatus PLS_INTEGER := VALID_FOR_EXTRACT;
BEGIN
  IF (p_internal_order_enabled_flag <> 'Y') THEN
  RETURN NOTINTERNAL;
  END IF;

  RETURN xStatus;
END getInternalItemStatus;

FUNCTION getPriceStatus(p_price_type		IN VARCHAR2,
                        p_row_id		IN ROWID,
                        p_test_mode		IN VARCHAR2)
  RETURN NUMBER
IS
  xStatus PLS_INTEGER := VALID_FOR_EXTRACT;
  xString 		VARCHAR2(2000);
  l_inactive_date	DATE;
  l_contract_line_id	NUMBER;
  l_enabled_flag	VARCHAR2(1);
  l_purchasing_site	VARCHAR2(1);
  l_purchasing_enabled	VARCHAR2(1);
  l_outside_operation	VARCHAR2(1);
  l_uom_code		MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;

-- Centralized Procurement Impacts Enhancement - pcreddy
  l_purchasing_uom_code	MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
  l_local_purchasing_enabled  VARCHAR2(1);
  l_local_outside_operation   VARCHAR2(1);

  l_local_uom_code      MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
  l_disable_flag	VARCHAR2(1);
  l_asl_status_id	NUMBER;
  l_item_price		NUMBER;
  l_internal_order_enabled VARCHAR2(1);

  -- Bug#3464695
  l_asl_id		NUMBER;
  l_express_name	ICX_CAT_ITEM_PRICES.TEMPLATE_ID%TYPE;
  l_sequence_num	NUMBER;
  l_rt_org_id		NUMBER;

BEGIN
  IF p_price_type IN ('TEMPLATE', 'INTERNAL_TEMPLATE') THEN
    xString :=
      'SELECT prl.express_name, '||
      'prl.sequence_num, '||
      'prl.org_id, '||
      'prh.inactive_date, '||
      'p.contract_line_id '||
      'FROM icx_cat_item_prices p, ';
    IF p_test_mode = 'Y' THEN
      xString := xString ||
        'ipo_reqexpress_headers_all prh, '||
        'ipo_reqexpress_lines_all prl ';
    ELSE
      xString := xString ||
        'po_reqexpress_headers_all prh, '||
        'po_reqexpress_lines_all prl ';
    END IF;
    xString := xString ||
      'WHERE p.rowid = :row_id ' ||
      'AND p.org_id = nvl(prh.org_id, '||ICX_POR_EXT_ITEM.NULL_NUMBER||') '||
      'AND p.template_id = prh.express_name '||
      'AND p.org_id = nvl(prl.org_id, '||ICX_POR_EXT_ITEM.NULL_NUMBER||') '||
      'AND p.template_id = prl.express_name '||
      'AND p.template_line_id = prl.sequence_num ';
    EXECUTE IMMEDIATE xString
    INTO    l_express_name,
            l_sequence_num,
            l_rt_org_id,
            l_inactive_date,
            l_contract_line_id
    USING   p_row_id;
    xStatus := getTemplateLineStatus(l_express_name,
                                     l_sequence_num,
                                     l_rt_org_id,
                                     l_inactive_date,
                                     l_contract_line_id,
                                     p_test_mode);

  ELSIF p_price_type IN ('BLANKET', 'QUOTATION') THEN
    SELECT  contract_line_id
    INTO    l_contract_line_id
    FROM    icx_cat_item_prices
    WHERE   rowid = p_row_id;
    xStatus := getContractLineStatus(l_contract_line_id,
                                     p_test_mode);
  ELSIF p_price_type = 'GLOBAL_AGREEMENT' THEN
    xString :=
      'SELECT t.enabled_flag, '||
      'pvs.purchasing_site_flag, '||
      'pvs.inactive_date, '||
      'mi.purchasing_enabled_flag, '||
      'mi.outside_operation_flag, '||
      'p.unit_of_measure, '||
      'mi.primary_uom_code, '||
      'mi2.purchasing_enabled_flag, '||
      'mi2.outside_operation_flag, '||
      'mi2.primary_uom_code '||
      'FROM icx_cat_item_prices p, ';
    IF p_test_mode = 'Y' THEN
      xString := xString ||
        'ipo_ga_org_assignments t, '||
        'ipo_vendor_sites_all pvs, '||
        'imtl_system_items_kfv mi, '||
        'ifinancials_system_params_all fsp, '||
        'imtl_system_items_kfv mi2, '|| -- Centralized proc Impacts
        'ifinancials_system_params_all fsp2 ';
    ELSE
      xString := xString ||
        'po_ga_org_assignments t, '||
        'po_vendor_sites_all pvs, '||
        'mtl_system_items_kfv mi, '||
        'financials_system_params_all fsp, '||
        'mtl_system_items_kfv mi2, '|| -- Centralized proc Impacts
        'financials_system_params_all fsp2 ';
    END IF;
    xString := xString ||
      'WHERE p.rowid = :row_id ' ||
      'AND p.contract_id = t.po_header_id '||
      'AND p.org_id = t.organization_id '||
      'AND t.vendor_site_id = pvs.vendor_site_id (+) '||
      'AND p.org_id = nvl(fsp.org_id, '||ICX_POR_EXT_ITEM.NULL_NUMBER||') '||
      'AND t.purchasing_org_id = fsp2.org_id '|| -- Centralized proc Impacts
      'AND p.inventory_item_id = mi.inventory_item_id (+) '||
      'AND p.inventory_item_id = mi2.inventory_item_id (+) '|| -- Centralized proc Impacts
      'AND fsp.inventory_organization_id = NVL(mi.organization_id, '||
      'fsp.inventory_organization_id) '||
      'AND fsp2.inventory_organization_id = NVL(mi2.organization_id, '||
      'fsp2.inventory_organization_id) '; -- Centralized proc Impacts
    EXECUTE IMMEDIATE xString
    INTO    l_enabled_flag,
            l_purchasing_site,
            l_inactive_date,
	    l_local_purchasing_enabled,  -- Centralized proc Impacts
	    l_local_outside_operation,
	    l_uom_code,
	    l_local_uom_code,
	    l_purchasing_enabled,
	    l_outside_operation,
	    l_purchasing_uom_code
    USING   p_row_id;
    xStatus := getGlobalAgreementStatus(l_enabled_flag,
                                        l_purchasing_site,
                                        l_inactive_date,
                                        l_local_purchasing_enabled,
                                        l_local_outside_operation,
                                        l_local_uom_code,
                                        l_purchasing_enabled,
                                        l_outside_operation,
                                        l_uom_code,
                                        l_purchasing_uom_code,
                                        p_test_mode);
  ELSIF p_price_type = 'ASL' THEN
    xString :=
      'SELECT pasl.asl_id, '||
      'pasl.disable_flag, '||
      'pasl.asl_status_id, '||
      'mi.list_price_per_unit '||
      'FROM icx_cat_item_prices p, ';
    IF p_test_mode = 'Y' THEN
      xString := xString ||
        'ipo_approved_supplier_list pasl, '||
        'imtl_system_items_kfv mi, '||
        'ifinancials_system_params_all fsp ';
    ELSE
      xString := xString ||
        'po_approved_supplier_list pasl, '||
        'mtl_system_items_kfv mi, '||
        'financials_system_params_all fsp ';
    END IF;
    xString := xString ||
      'WHERE p.rowid = :row_id ' ||
      'AND p.org_id = nvl(fsp.org_id, '||ICX_POR_EXT_ITEM.NULL_NUMBER||') '||
      'AND fsp.inventory_organization_id = pasl.owning_organization_id '||
      'AND pasl.item_id = mi.inventory_item_id '||
      'AND pasl.owning_organization_id = mi.organization_id '||
      'AND p.asl_id = pasl.asl_id ';
    EXECUTE IMMEDIATE xString
    INTO    l_asl_id,
            l_disable_flag,
	    l_asl_status_id,
	    l_item_price
    USING   p_row_id;
    xStatus := getASLStatus(l_asl_id,
                            l_disable_flag,
                            l_asl_status_id,
                            l_item_price,
                            p_test_mode);
  ELSIF p_price_type = 'PURCHASING_ITEM' THEN
    xString :=
      'SELECT mi.purchasing_enabled_flag, '||
      'mi.outside_operation_flag, '||
      'mi.list_price_per_unit '||
      'FROM icx_cat_item_prices p, ';
    IF p_test_mode = 'Y' THEN
      xString := xString ||
        'imtl_system_items_kfv mi, '||
        'ifinancials_system_params_all fsp ';
    ELSE
      xString := xString ||
        'mtl_system_items_kfv mi, '||
        'financials_system_params_all fsp ';
    END IF;
    xString := xString ||
      'WHERE p.rowid = :row_id ' ||
      'AND p.org_id = nvl(fsp.org_id, '||ICX_POR_EXT_ITEM.NULL_NUMBER||') '||
      'AND fsp.inventory_organization_id = mi.organization_id '||
      'AND p.inventory_item_id = mi.inventory_item_id ';
    EXECUTE IMMEDIATE xString
    INTO    l_local_purchasing_enabled,
            l_local_outside_operation,
	    l_item_price
    USING   p_row_id;
    xStatus := getPurchasingItemStatus(l_local_purchasing_enabled,
                                       l_local_outside_operation,
                                       l_item_price,
                                       p_test_mode);
  ELSIF p_price_type = 'INTERNAL_ITEM' THEN
    xString :=
      'SELECT mi.internal_order_enabled_flag '||
      'FROM icx_cat_item_prices p, ';
    IF p_test_mode = 'Y' THEN
      xString := xString ||
        'imtl_system_items_kfv mi, '||
        'ifinancials_system_params_all fsp ';
    ELSE
      xString := xString ||
        'mtl_system_items_kfv mi, '||
        'financials_system_params_all fsp ';
    END IF;
    xString := xString ||
      'WHERE p.rowid = :row_id ' ||
      'AND p.org_id = nvl(fsp.org_id, '||ICX_POR_EXT_ITEM.NULL_NUMBER||') '||
      'AND fsp.inventory_organization_id = mi.organization_id '||
      'AND p.inventory_item_id = mi.inventory_item_id ';
    EXECUTE IMMEDIATE xString
    INTO    l_internal_order_enabled
    USING   p_row_id;
    xStatus := getInternalItemStatus(l_internal_order_enabled,
                                     p_test_mode);
  END IF;

  RETURN xStatus;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF p_price_type IN ('TEMPLATE', 'INTERNAL_TEMPLATE') THEN
      xStatus := INVALID_TEMPLATE_LINE;
    ELSIF p_price_type IN ('BLANKET', 'GLOBAL_AGREEMENT') THEN
      xStatus := INVALID_BLANKET_LINE;
    ELSIF p_price_type = 'QUOTATION' THEN
      xStatus := INVALID_QUOTATION_LINE;
    ELSIF p_price_type = 'ASL' THEN
      xStatus := INVALID_ASL;
    ELSIF p_price_type IN ('PURCHASING_ITEM', 'INTERNAL_ITEM') THEN
      xStatus := INVALID_ITEM;
    END IF;
    RETURN xStatus;
END getPriceStatus;

FUNCTION isValidExtPrice(pDocumentType		IN NUMBER,
                         pStatus		IN NUMBER,
                         pLoadContract		IN VARCHAR2,
                         pLoadTemplateLine	IN VARCHAR2,
                         pLoadItemMaster	IN VARCHAR2,
                         pLoadInternalItem	IN VARCHAR2)
  RETURN NUMBER
IS
BEGIN
  IF pDocumentType IN (ICX_POR_EXT_ITEM.TEMPLATE_TYPE,
                       ICX_POR_EXT_ITEM.INTERNAL_TEMPLATE_TYPE)
  THEN
    IF (pLoadTemplateLine = 'Y' AND
        pStatus = VALID_FOR_EXTRACT)
    THEN
      IF pDocumentType = ICX_POR_EXT_ITEM.INTERNAL_TEMPLATE_TYPE THEN
        IF pLoadInternalItem = 'Y' THEN
        RETURN 1;
        END IF;
      RETURN 0;
      END IF;
    RETURN 1;
    END IF;
  RETURN 0;
  END IF;

  IF pDocumentType IN (ICX_POR_EXT_ITEM.CONTRACT_TYPE,
                       ICX_POR_EXT_ITEM.GLOBAL_AGREEMENT_TYPE)
  THEN
    IF (pLoadContract = 'Y' AND
        pStatus = VALID_FOR_EXTRACT)
    THEN
    RETURN 1;
    END IF;
  RETURN 0;
  END IF;

  IF pDocumentType IN (ICX_POR_EXT_ITEM.ASL_TYPE,
                       ICX_POR_EXT_ITEM.PURCHASING_ITEM_TYPE)
  THEN
    IF (pLoadItemMaster = 'Y' AND
        pStatus = VALID_FOR_EXTRACT)
    THEN
    RETURN 1;
    END IF;
  RETURN 0;
  END IF;

  IF pDocumentType = ICX_POR_EXT_ITEM.INTERNAL_ITEM_TYPE THEN
    IF (pLoadInternalItem = 'Y' AND
        pStatus = VALID_FOR_EXTRACT)
    THEN
    RETURN 1;
    END IF;
  RETURN 0;
  END IF;

  RETURN 0;
END isValidExtPrice;

END ICX_POR_EXT_DIAG;

/
