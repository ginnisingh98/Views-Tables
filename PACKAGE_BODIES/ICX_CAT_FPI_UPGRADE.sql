--------------------------------------------------------
--  DDL for Package Body ICX_CAT_FPI_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_FPI_UPGRADE" AS
/* $Header: ICXUPGIB.pls 120.0.12010000.2 2008/08/02 14:38:05 kkram ship $*/

--------------------------------------------------------------
--                    Cursors and Types                     --
--------------------------------------------------------------
TYPE tItemRecord IS RECORD (
  rt_item_id		NUMBER,
  rt_category_id	NUMBER);

TYPE tTemplateItemRecord IS RECORD (
  template_id		ICX_CAT_ITEM_PRICES.template_id%TYPE,
  rt_item_id		NUMBER,
  hash_value		NUMBER);

TYPE tTemplateItemCache IS TABLE OF tTemplateItemRecord
  INDEX BY BINARY_INTEGER;

--------------------------------------------------------------
--                         Caches                           --
--------------------------------------------------------------
gTemplateItemCache 	tTemplateItemCache;
gHashBase 		PLS_INTEGER;
gHashSize 		PLS_INTEGER;

--------------------------------------------------------------
--                   Global Variables                       --
--------------------------------------------------------------
-- Current Item
gCurrentItem 			tItemRecord;
-- Dynamic SQL to update ICX_CAT_ITEMS_TLP, ICX_CAT_EXT_ITEMS_TLP
gDynSqlBaseAttributes		VARCHAR2(4000);
gDynSqlCatAttributes		VARCHAR2(4000);
gReturnErr      		VARCHAR2(4000) := NULL;
gLogLevel			PLS_INTEGER := ICX_POR_EXT_UTL.DEBUG_LEVEL;
gLogFile			VARCHAR2(200) := 'icxupgfi.log';
gCommitSize     		PLS_INTEGER := 2000;
gContinueExtItemTlp		BOOLEAN := FALSE;

--------------------------------------------------------------
--                   Global PL/SQL Tables                   --
--------------------------------------------------------------
-- Global PL/SQL tables for ICX_CAT_ITEMS_B, ICX_CAT_ITEMS_TLP,
-- ICX_CAT_EXT_ITEMS_TLP, ICX_CAT_CATEGORY_ITEMS
gIRtItemIds			DBMS_SQL.NUMBER_TABLE;
gIOldRtItemIds			DBMS_SQL.NUMBER_TABLE;
gIOrgIds			DBMS_SQL.NUMBER_TABLE;
gISupplierPartNums		DBMS_SQL.VARCHAR2_TABLE;
gIRtCategoryIds			DBMS_SQL.NUMBER_TABLE;
gIExtractorUpdatedFlags		DBMS_SQL.VARCHAR2_TABLE;

-- Global PL/SQL tables for description of ICX_CAT_ITEMS_TLP,
gITRtItemIds			DBMS_SQL.NUMBER_TABLE;
gITItemDescriptions		DBMS_SQL.VARCHAR2_TABLE;

-- Global PL/SQL tables for template headers of ICX_CAT_CATEGORY_ITEMS
gCIRtItemIds			DBMS_SQL.NUMBER_TABLE;
gCITemplateIds			DBMS_SQL.VARCHAR2_TABLE;

-- Global PL/SQL tables for ICX_CAT_ITEM_PRICES
-- Extracted price records
gEPRtItemIds			DBMS_SQL.NUMBER_TABLE;
gEPActiveFlags			DBMS_SQL.VARCHAR2_TABLE;
gEPOrgIds			DBMS_SQL.NUMBER_TABLE;
gEPPriceTypes			DBMS_SQL.VARCHAR2_TABLE;
gEPRowIds      			DBMS_SQL.UROWID_TABLE;
gEPRateTypes 			DBMS_SQL.VARCHAR2_TABLE;
gEPRateDates			DBMS_SQL.DATE_TABLE;
gEPRates			DBMS_SQL.NUMBER_TABLE;
gEPSupplierNumbers		DBMS_SQL.VARCHAR2_TABLE;
gEPSupplierContactIds		DBMS_SQL.NUMBER_TABLE;
gEPItemRevisions		DBMS_SQL.VARCHAR2_TABLE;
gEPLineTypeIds			DBMS_SQL.NUMBER_TABLE;
gEPBuyerIds			DBMS_SQL.NUMBER_TABLE;

-- Bulkloaded price records
gBPRtItemIds			DBMS_SQL.NUMBER_TABLE;
gBRActiveFlgs			DBMS_SQL.VARCHAR2_TABLE;
gBPOrgIds			DBMS_SQL.NUMBER_TABLE;
gBPSupplierSiteIds		DBMS_SQL.NUMBER_TABLE;
gBPPriceTypes			DBMS_SQL.VARCHAR2_TABLE;
gBPRowIds      			DBMS_SQL.UROWID_TABLE;

-- POR_FAVORITE_LIST_LINES
gUpFavRowIds      		DBMS_SQL.UROWID_TABLE;
gUpFavRtItemIds			DBMS_SQL.NUMBER_TABLE;
gInFavRowIds      		DBMS_SQL.UROWID_TABLE;
gInFavRtItemIds			DBMS_SQL.NUMBER_TABLE;

--------------------------------------------------------------
--                         Procedures                       --
--------------------------------------------------------------

PROCEDURE cleanTables(pMode VARCHAR2) IS
BEGIN
  IF pMode IN ('ALL', 'ITEM') THEN
    gIRtItemIds.DELETE;
    gIOldRtItemIds.DELETE;
    gIOrgIds.DELETE;
    gISupplierPartNums.DELETE;
    gIRtCategoryIds.DELETE;
    gIExtractorUpdatedFlags.DELETE;
  END IF;

  IF pMode IN ('ALL', 'TLP') THEN
    gITRtItemIds.DELETE;
    gITItemDescriptions.DELETE;
  END IF;

  IF pMode IN ('ALL', 'CAT_ITEM') THEN
    gCIRtItemIds.DELETE;
    gCITemplateIds.DELETE;
  END IF;

  IF pMode IN ('ALL', 'EXTRACTED_PRICE') THEN
    gEPRtItemIds.DELETE;
    gEPActiveFlags.DELETE;
    gEPOrgIds.DELETE;
    gEPPriceTypes.DELETE;
    gEPRowIds.DELETE;
    gEPRateTypes.DELETE;
    gEPRateDates.DELETE;
    gEPRates.DELETE;
    gEPSupplierNumbers.DELETE;
    gEPSupplierContactIds.DELETE;
    gEPItemRevisions.DELETE;
    gEPLineTypeIds.DELETE;
    gEPBuyerIds.DELETE;
  END IF;

  IF pMode IN ('ALL', 'BULKLOADED_PRICE') THEN
    gBPRtItemIds.DELETE;
    gBRActiveFlgs.DELETE;
    gBPOrgIds.DELETE;
    gBPSupplierSiteIds.DELETE;
    gBPPriceTypes.DELETE;
    gBPRowIds.DELETE;
  END IF;
END cleanTables;


FUNCTION snapShot(pIndex	IN PLS_INTEGER,
                  pMode		IN VARCHAR2) RETURN VARCHAR2
IS
  xShot VARCHAR2(2000) := 'Snap Shot('||pMode||')['||pIndex||']--';
BEGIN
  IF pMode = 'ITEM' THEN
    xShot := xShot || ' gIRtItemIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gIRtItemIds, pIndex) || ', ';
    xShot := xShot || ' gIOldRtItemIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gIOldRtItemIds, pIndex) || ', ';
    xShot := xShot || ' gIOrgIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gIOrgIds, pIndex) || ', ';
    xShot := xShot || ' gISupplierPartNums: ' ||
      ICX_POR_EXT_UTL.getTableElement(gISupplierPartNums, pIndex) || ', ';
    xShot := xShot || ' gIRtCategoryIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gIRtCategoryIds, pIndex) || ', ';
    xShot := xShot || ' gIExtractorUpdatedFlags: ' ||
      ICX_POR_EXT_UTL.getTableElement(gIExtractorUpdatedFlags, pIndex);
  ELSIF pMode = 'TLP' THEN
    xShot := xShot || ' gITRtItemIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gITRtItemIds, pIndex) || ', ';
    xShot := xShot || ' gITItemDescriptions: ' ||
      ICX_POR_EXT_UTL.getTableElement(gITItemDescriptions, pIndex);
  ELSIF pMode = 'CAT_ITEM' THEN
    xShot := xShot || ' gCIRtItemIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gCIRtItemIds, pIndex) || ', ';
    xShot := xShot || ' gCITemplateIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gCITemplateIds, pIndex);
  ELSIF pMode = 'EXTRACTED_PRICE' THEN
    xShot := xShot || ' gEPRtItemIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPRtItemIds, pIndex) || ', ';
    xShot := xShot || ' gEPActiveFlags: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPActiveFlags, pIndex) || ', ';
    xShot := xShot || ' gEPOrgIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPOrgIds, pIndex) || ', ';
    xShot := xShot || ' gEPPriceTypes: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPPriceTypes, pIndex) || ', ';
    xShot := xShot || ' gEPRateTypes: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPRateTypes, pIndex) || ', ';
    xShot := xShot || ' gEPRateDates: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPRateDates, pIndex) || ', ';
    xShot := xShot || ' gEPRates: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPRates, pIndex) || ', ';
    xShot := xShot || ' gEPSupplierNumbers: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPSupplierNumbers, pIndex) || ', ';
    xShot := xShot || ' gEPSupplierContactIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPSupplierContactIds, pIndex) || ', ';
    xShot := xShot || ' gEPItemRevisions: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPItemRevisions, pIndex) || ', ';
    xShot := xShot || ' gEPLineTypeIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPLineTypeIds, pIndex) || ', ';
    xShot := xShot || ' gEPBuyerIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPBuyerIds, pIndex) || ', ';
    xShot := xShot || ' gEPRowIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gEPRowIds, pIndex);
  ELSIF pMode = 'BULKLOADED_PRICE' THEN
    xShot := xShot || ' gBPRtItemIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gBPRtItemIds, pIndex) || ', ';
    xShot := xShot || ' gBRActiveFlgs: ' ||
      ICX_POR_EXT_UTL.getTableElement(gBRActiveFlgs, pIndex) || ', ';
    xShot := xShot || ' gBPOrgIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gBPOrgIds, pIndex) || ', ';
    xShot := xShot || ' gBPSupplierSiteIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gBPSupplierSiteIds, pIndex) || ', ';
    xShot := xShot || ' gBPPriceTypes: ' ||
      ICX_POR_EXT_UTL.getTableElement(gBPPriceTypes, pIndex) || ', ';
    xShot := xShot || ' gBPRowIds: ' ||
      ICX_POR_EXT_UTL.getTableElement(gBPRowIds, pIndex);
  END IF;

  RETURN xShot;
END snapShot;

--------------------------------------------------------------
--                 Process Caching Data                     --
--------------------------------------------------------------
PROCEDURE clearCache IS
BEGIN
  gTemplateItemCache.DELETE;
END clearCache;

PROCEDURE setHashRange(pHashBase	IN NUMBER,
                       pHashSize	IN NUMBER) IS
  xErrLoc	PLS_INTEGER := 100;
BEGIN
  xErrLoc := 100;
  clearCache;
  gHashBase := pHashBase;
  gHashSize := pHashSize;
END setHashRange;

PROCEDURE initCaches IS
  xErrLoc	PLS_INTEGER := 100;
  xHashSize	PLS_INTEGER;
BEGIN
  xErrLoc := 100;
  -- Caculate hash size based on gCommitSize, but at least 1024
  -- A power of 2 for the hash_size parameter is best
  xHashSize := GREATEST(POWER(2,ROUND(LOG(2,gCommitSize*10))),
                        POWER(2, 10));
  xErrLoc := 200;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Cache hash size is ' || xHashSize);
  setHashRange(1, xHashSize);
END initCaches;

-- A hash value based on the input string. For example,
-- to get a hash value on a string where the hash value
-- should be between 1000 and 3047, use 1000 as the base
-- value and 2048 as the hash_size value. Using a power
-- of 2 for the hash_size parameter works best.
FUNCTION getHashValue(pHashString	IN VARCHAR2)
  RETURN NUMBER
IS
  xErrLoc	PLS_INTEGER := 100;
BEGIN
  xErrLoc := 100;
  RETURN DBMS_UTILITY.get_hash_value(pHashString,
                                     gHashBase,
                                     gHashSize);
END getHashValue;

FUNCTION findTemplateItemCache(pTemplateItem	IN OUT NOCOPY tTemplateItemRecord)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER := 100;
  xHashString	VARCHAR2(2000);
  xHashValue	PLS_INTEGER;
  xTemplateItem	tTemplateItemRecord;
BEGIN
  xErrLoc := 100;
  IF pTemplateItem.hash_value > ICX_POR_EXT_ITEM.NULL_NUMBER THEN
    RETURN TRUE;
  END IF;

  xHashString := pTemplateItem.template_id || pTemplateItem.rt_item_id;

  xErrLoc := 200;
  xHashValue := getHashValue(xHashString);

  xErrLoc := 300;
  WHILE (TRUE) LOOP
    -- It is impossible to have cache full, so we don't need
    -- to worry about caching replacement
    IF gTemplateItemCache.EXISTS(xHashValue) THEN
      xTemplateItem := gTemplateItemCache(xHashValue);
      xErrLoc := 320;
      -- All NULL value is replace by NULL_NUMBER
      IF (xTemplateItem.template_id = pTemplateItem.template_id AND
          xTemplateItem.rt_item_id = pTemplateItem.rt_item_id)
      THEN
        pTemplateItem.hash_value := xTemplateItem.hash_value;
        RETURN TRUE;
      ELSE
        xHashValue := xHashValue + 1;
      END IF;
    ELSE
      pTemplateItem.hash_value := xHashValue;
      RETURN FALSE;
    END IF;
  END LOOP;

  RETURN FALSE;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_ITEM.findTemplateItemCache-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END findTemplateItemCache;

PROCEDURE putTemplateItemCache(pTemplateItem	IN tTemplateItemRecord) IS
  xErrLoc	PLS_INTEGER := 100;
BEGIN
  xErrLoc := 100;

  IF pTemplateItem.hash_value = ICX_POR_EXT_ITEM.NULL_NUMBER THEN
    RETURN;
  END IF;

  xErrLoc := 200;
  gTemplateItemCache(pTemplateItem.hash_value) := pTemplateItem;
EXCEPTION
  when others then
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_ITEM.putTemplateItemCache-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END putTemplateItemCache;


FUNCTION getOldPrimaryCategoryId(pRtItemId	IN NUMBER)
  RETURN NUMBER
IS
  xRtCategoryId		NUMBER;
BEGIN
  SELECT ci.rt_category_id
  INTO	 xRtCategoryId
  FROM   icx_por_category_items ci
  WHERE  ci.rt_item_id = pRtItemId
  AND    EXISTS (SELECT 'primary category'
                 FROM   icx_por_categories_tl cat
                 WHERE  cat.rt_category_id = ci.rt_category_id
                 AND    cat.type = ICX_POR_EXT_CLASS.CATEGORY_TYPE)
  AND    ROWNUM = 1;
  RETURN xRtCategoryId;
END getOldPrimaryCategoryId;

FUNCTION getPrimaryCategoryId(pRtItemId	IN NUMBER)
  RETURN NUMBER
IS
  xRtCategoryId		NUMBER;
BEGIN
  SELECT ci.rt_category_id
  INTO	 xRtCategoryId
  FROM   icx_cat_category_items ci
  WHERE  ci.rt_item_id = pRtItemId
  AND    EXISTS (SELECT 'primary category'
                 FROM   icx_cat_categories_tl cat
                 WHERE  cat.rt_category_id = ci.rt_category_id
                 AND    cat.type = ICX_POR_EXT_CLASS.CATEGORY_TYPE)
  AND    ROWNUM = 1;
  RETURN xRtCategoryId;
END getPrimaryCategoryId;

-- Fetch category attributes
PROCEDURE fetchAttributes(pRtCategoryId NUMBER) IS
  CURSOR cCatAttributes(cpRtCategoryId NUMBER) IS
    SELECT rt_descriptor_id,
           key, type,
           stored_in_table,
           stored_in_column
    FROM   icx_cat_descriptors_tl
    WHERE  rt_category_id = cpRtCategoryId
    AND    language = (SELECT language_code
                       FROM   fnd_languages
                       WHERE  installed_flag = 'B');

  xRtDescriptorIds	DBMS_SQL.NUMBER_TABLE;
  xKeys			DBMS_SQL.VARCHAR2_TABLE;
  xTypes		DBMS_SQL.NUMBER_TABLE;
  xStoredInTables	DBMS_SQL.VARCHAR2_TABLE;
  xStoredInColumns	DBMS_SQL.VARCHAR2_TABLE;

  xUpdateColumns	VARCHAR2(2000) := NULL;
  xSelectColumns	VARCHAR2(2000) := NULL;

  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);

BEGIN
  xErrLoc := 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'Fetch attributes for category ' || pRtCategoryId);
  END IF;

  OPEN cCatAttributes(pRtCategoryId);
  FETCH cCatAttributes
  BULK  COLLECT INTO xRtDescriptorIds, xKeys, xTypes,
                     xStoredInTables, xStoredInColumns;

  xErrLoc := 100;

  IF (ICX_POR_EXT_UTL.gDebugLevel = ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..xRtDescriptorIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        'rt_descriptor_id: ' || xRtDescriptorIds(i) ||
        ', key: ' || xKeys(i) || ', type: ' || xTypes(i) ||
        ', stored_in_table: ' || xStoredInTables(i) ||
        ', stored_in_column: ' || xStoredInColumns(i));
    END LOOP;
  END IF;

  xErrLoc := 150;
  -- Build dynamic SQL
  FOR i in 1..xRtDescriptorIds.COUNT LOOP
    xErrLoc := 200;

    -- Let's skip all seeded base attributes and pricing attributes
    -- 'SUPPLIER', 'SUPPLIER_ID', 'SUPPLIER_PART_NUM',
    -- 'MANUFACTURER', 'MANUFACTURER_PART_NUM', 'UOM',
    -- 'DESCRIPTION', 'COMMENTS', 'ALIAS',
    -- 'PRICE', 'CURRENCY', 'INTERNAL_ITEM_NUM',
    -- 'PICTURE', 'PICTURE_URL', 'CONTRACT_NUM',
    -- 'CONTRACT_LINE', 'CONTRACT_PRICE', 'CONTRACT_CURRENCY',
    -- 'CONTRACT_RATE_TYPE', 'CONTRACT_RATE_DATE', 'CONTRACT_RATE',
    -- 'ATTACHMENT_URL', 'LONG_DESCRIPTION', 'UNSPSC',
    -- 'AVAILABILITY', 'LEAD_TIME', 'FUNCTIONAL_PRICE',
    -- 'FUNCTIONAL_CURRENCY', 'ITEM_TYPE', 'SUPPLIER_SITE',
    -- 'BUYER', 'PRICELIST',
    IF (pRtCategoryId > 0 OR
        xRtDescriptorIds(i) > 100)
    THEN
      IF (xStoredInColumns(i) IS NULL) THEN
        ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
          'Empty stored_in_column for attribute: ' || xKeys(i));
      ELSE
        xErrLoc := 240;
        IF (xUpdateColumns IS NOT NULL) THEN
          xUpdateColumns := xUpdateColumns || ',';
          xSelectColumns := xSelectColumns || ',';
        END IF;

        xUpdateColumns := xUpdateColumns || xStoredInColumns(i);

        xErrLoc := 260;
        IF (pRtCategoryId = 0) THEN
          IF (xTypes(i) = 0) THEN
            xSelectColumns := xSelectColumns || 'i.A' ||
              xRtDescriptorIds(i);
          ELSIF (xTypes(i) = 1) THEN
            xSelectColumns := xSelectColumns || 'to_number(i.A' ||
              xRtDescriptorIds(i) || ')';
          ELSE
            xSelectColumns := xSelectColumns || 'tl.A' ||
              xRtDescriptorIds(i);
          END IF;
        ELSE
          IF (xTypes(i) = 1) THEN
            xSelectColumns := xSelectColumns || 'to_number(c.A' ||
              xRtDescriptorIds(i) || ')';
          ELSE
            xSelectColumns := xSelectColumns || 'c.A' ||
              xRtDescriptorIds(i);
          END IF;
        END IF;

      END IF;
    END IF;
  END LOOP;

  xErrLoc := 300;

  IF (pRtCategoryId = 0) THEN
    IF (xUpdateColumns IS NOT NULL) THEN
      xErrLoc := 350;
      gDynSqlBaseAttributes :=
        'UPDATE ICX_CAT_ITEMS_TLP tlp ' ||
        'SET    (' || xUpdateColumns || ') = ' ||
        '(SELECT ' || xSelectColumns ||
        ' FROM   ICX_POR_ITEMS i, ICX_POR_ITEMS_TL tl ' ||
        ' WHERE  i.rt_item_id = :old_rt_item_id ' ||
        ' AND    i.rt_item_id = tl.rt_item_id ' ||
        ' AND    tlp.language = tl.language) ' ||
        'WHERE  tlp.rt_item_id = :new_rt_item_id';
    ELSE
      gDynSqlBaseAttributes := NULL;
    END IF;

  ELSE
    IF (xUpdateColumns IS NOT NULL) THEN
      xErrLoc := 370;
      gDynSqlCatAttributes :=
        'UPDATE ICX_CAT_EXT_ITEMS_TLP tlp ' ||
        'SET    (' || xUpdateColumns || ') = ' ||
        '(SELECT ' || xSelectColumns ||
        ' FROM   ICX_POR_C' || pRtCategoryId || '_TL c' ||
        ' WHERE  c.rt_item_id = :old_rt_item_id ' ||
        ' AND    c.language = tlp.language) ' ||
        'WHERE  tlp.rt_item_id = :new_rt_item_id ' ||
        'AND    tlp.rt_category_id = ' || pRtCategoryId;
    ELSE
      gDynSqlCatAttributes := NULL;
    END IF;
  END IF;

  xErrLoc := 400;
  IF (pRtCategoryId = 0) THEN
    IF (gDynSqlBaseAttributes IS NOT NULL) THEN
      IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
        ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
          gDynSqlBaseAttributes);
      END IF;
    END IF;
  ELSE
    IF (gDynSqlCatAttributes IS NOT NULL) THEN
      IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
        ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
          gDynSqlCatAttributes);
      END IF;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'fetchAttributes(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    raise ICX_POR_EXT_UTL.gException;
END fetchAttributes;

-- Process item records based on gCurrentItem
PROCEDURE processItems IS
  /*
   The possible price records sharing the same RT_ITEM_ID:
   1. Both SUPPLIER and SUPPLIER_PART_NUM are not null
      a> Templates with contract reference
      b> Contracts
      c> Templates without contract reference
      d> ASLs
      e> Master items
      f> Bulkloaded items
   2. Either SUPPLIER or SUPPLIER_PART_NUM is null, not both
      a> Templates with contract reference
      b> Contracts
      c> Templates without contract reference
      d> ASLs
      e> Master items
   3. Both SUPPLIER and SUPPLIER_PART_NUM are null
      a> Templates with contract reference
      b> Contracts
      c> Templates without contract reference
      e> Master items
      f> Internal templates
      g> Intenal items

   */
  -- Cursor for all item records: subtable records and price list lines
  CURSOR cItemRecords(p_rt_item_id IN NUMBER) IS
    SELECT NVL(sub.orc_operating_unit_id, ICX_POR_EXT_ITEM.NULL_NUMBER) org_id,
           NVL(ph.vendor_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_id,
           pl.vendor_product_num supplier_part_num,
           NVL(sub.orc_supplier_site_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_site_id,
           7 type, -- template_contracts
           greatest(pl.last_update_date,
                    ph.last_update_date) last_update_date,
           -- pcreddy : Bug # 3234875 : Price type should be TEMPLATE
           -- for template lines copied from blankets
           -- ph.type_lookup_code price_type, -- 'BLANKET' or 'QUOTATION'
           'TEMPLATE' as price_type,
           pl.item_description item_description,
           sub.orc_template_id template_id,
           ph.rate_type,
	   ph.rate_date,
	   ph.rate,
	   pv.segment1 supplier_number,
	   NVL(ph.vendor_contact_id, prl.suggested_vendor_contact_id) supplier_contact_id,
	   prl.item_revision,
	   prl.line_type_id,
           prl.suggested_buyer_id buyer_id,
           sub.rowid row_id
    FROM   icx_por_oracle_item_subtable sub,
           po_reqexpress_lines_all prl,
           po_headers_all ph,
           po_lines_all pl,
           po_vendors pv
    WHERE  sub.rt_item_id = p_rt_item_id
    AND    sub.orc_template_id is not null
    AND    sub.orc_contract_id is not null
    AND    sub.orc_template_id = prl.express_name
    AND    sub.orc_template_line_id = prl.sequence_num
    AND    (sub.orc_operating_unit_id is NULL AND
            prl.org_id is NULL OR
            prl.org_id = sub.orc_operating_unit_id)
    AND    sub.orc_contract_id = ph.po_header_id
    AND    sub.orc_contract_line_id = pl.po_line_id
    AND    prl.suggested_vendor_id = pv.vendor_id (+)
  UNION ALL
    SELECT NVL(sub.orc_operating_unit_id, ICX_POR_EXT_ITEM.NULL_NUMBER) org_id,
           NVL(ph.vendor_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_id,
           pl.vendor_product_num supplier_part_num,
           NVL(sub.orc_supplier_site_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_site_id,
           6 type, -- contracts
           greatest(pl.last_update_date,
                    ph.last_update_date) last_update_date,
           ph.type_lookup_code price_type, -- 'BLANKET' or 'QUOTATION'
           pl.item_description item_description,
           NVL(sub.orc_template_id, TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER)) template_id,
           ph.rate_type,
	   ph.rate_date,
	   ph.rate,
	   pv.segment1 supplier_number,
	   ph.vendor_contact_id supplier_contact_id,
	   pl.item_revision,
	   pl.line_type_id,
	   ph.agent_id buyer_id,
           sub.rowid row_id
    FROM   icx_por_oracle_item_subtable sub,
           po_headers_all ph,
           po_lines_all pl,
           po_vendors pv
    WHERE  sub.rt_item_id = p_rt_item_id
    AND    sub.orc_contract_id is not null
    AND    sub.orc_contract_id = ph.po_header_id
    AND    sub.orc_contract_line_id = pl.po_line_id
    AND    ph.vendor_id = pv.vendor_id (+)
  UNION ALL
    SELECT NVL(sub.orc_operating_unit_id, ICX_POR_EXT_ITEM.NULL_NUMBER) org_id,
           NVL(prl.suggested_vendor_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_id,
           prl.suggested_vendor_product_code supplier_part_num,
           NVL(sub.orc_supplier_site_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_site_id,
           5 type, -- templates
           greatest(prl.last_update_date,
                    prh.last_update_date) last_update_date,
           'TEMPLATE' price_type,
           prl.item_description item_description,
           sub.orc_template_id template_id,
           TO_CHAR(NULL) rate_type,
	   TO_DATE(NULL) rate_date,
	   TO_NUMBER(NULL) rate,
	   pv.segment1 supplier_number,
	   prl.suggested_vendor_contact_id supplier_contact_id,
	   prl.item_revision,
	   prl.line_type_id,
           prl.suggested_buyer_id buyer_id,
           sub.rowid row_id
    FROM   icx_por_oracle_item_subtable sub,
           po_reqexpress_headers_all prh,
           po_reqexpress_lines_all prl,
           po_vendors pv
    WHERE  sub.rt_item_id = p_rt_item_id
    AND    sub.orc_template_id is not null
    AND    sub.orc_contract_id is null
    AND    prh.express_name = sub.orc_template_id
    AND    (sub.orc_operating_unit_id is NULL AND
            prh.org_id is NULL OR
            prh.org_id = sub.orc_operating_unit_id)
    AND    prl.express_name = sub.orc_template_id
    AND    prl.sequence_num = sub.orc_template_line_id
    AND    (sub.orc_operating_unit_id is NULL AND
            prl.org_id is NULL OR
            prl.org_id = sub.orc_operating_unit_id)
    AND    prl.suggested_vendor_id = pv.vendor_id (+)
  UNION ALL
    SELECT NVL(sub.orc_operating_unit_id, ICX_POR_EXT_ITEM.NULL_NUMBER) org_id,
           NVL(prl.suggested_vendor_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_id,
           prl.suggested_vendor_product_code supplier_part_num,
           NVL(sub.orc_supplier_site_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_site_id,
           4 type, -- internal templates
           greatest(prl.last_update_date,
                    prh.last_update_date) last_update_date,
           'INTERNAL_TEMPLATE' price_type,
           prl.item_description item_description,
           sub.orc_template_id template_id,
           TO_CHAR(NULL) rate_type,
	   TO_DATE(NULL) rate_date,
	   TO_NUMBER(NULL) rate,
	   TO_CHAR(NULL) supplier_number,
	   TO_NUMBER(NULL) supplier_contact_id,
	   prl.item_revision,
	   prl.line_type_id,
           prl.suggested_buyer_id buyer_id,
           sub.rowid row_id
    FROM   icx_por_oracle_item_subtable sub,
           po_reqexpress_headers_all prh,
           po_reqexpress_lines_all prl
    WHERE  sub.rt_item_id = p_rt_item_id
    AND    sub.orc_template_id is not null
    AND    sub.orc_contract_id is null
    AND    sub.search_type = 'INTERNAL'
    AND    prh.express_name = sub.orc_template_id
    AND    (sub.orc_operating_unit_id is NULL AND
            prh.org_id is NULL OR
            prh.org_id = sub.orc_operating_unit_id)
    AND    prl.express_name = sub.orc_template_id
    AND    prl.sequence_num = sub.orc_template_line_id
    AND    (sub.orc_operating_unit_id is NULL AND
            prl.org_id is NULL OR
            prl.org_id = sub.orc_operating_unit_id)
  UNION ALL
    SELECT prl.buyer_id org_id,
           NVL(prl.supplier_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_id,
           item.a3 supplier_part_num,
           NVL(pvs.vendor_site_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_site_id,
           3 type, -- Bulk Loaded
           prl.last_update_date last_update_date,
           --Bug#3148018
           --For lines with contract_reference_num, should have a price_type
           --of CONTRACT
           decode(prl.contract_reference_num, null, 'BULKLOAD', 'CONTRACT') price_type,
           TO_CHAR(NULL) item_description,
           TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER) template_id,
           TO_CHAR(NULL) rate_type,
	   TO_DATE(NULL) rate_date,
	   TO_NUMBER(NULL) rate,
	   TO_CHAR(NULL) supplier_number,
	   TO_NUMBER(NULL) supplier_contact_id,
	   TO_CHAR(NULL) item_revision,
	   TO_NUMBER(NULL) line_type_id,
           TO_NUMBER(NULL) buyer_id,
           prl.rowid row_id
    FROM   icx_por_price_list_lines prl,
           icx_por_items item,
           po_vendor_sites_all pvs
    WHERE  prl.item_id = p_rt_item_id
    AND    prl.buyer_approval_status = 'APPROVED'
    AND    item.rt_item_id = p_rt_item_id
    AND    prl.supplier_site = pvs.vendor_site_code (+)
    AND    prl.supplier_id = pvs.vendor_id (+)
    AND    prl.buyer_id = pvs.org_id (+)
  UNION ALL
    SELECT NVL(sub.orc_operating_unit_id, ICX_POR_EXT_ITEM.NULL_NUMBER) org_id,
           NVL(pasl.vendor_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_id,
           pasl.primary_vendor_item supplier_part_num,
           NVL(sub.orc_supplier_site_id, ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_site_id,
           2 type, -- ASLs
           pasl.last_update_date last_update_date,
           'ASL' price_type,
           TO_CHAR(NULL) item_description,
           TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER) template_id,
           TO_CHAR(NULL) rate_type,
	   TO_DATE(NULL) rate_date,
	   TO_NUMBER(NULL) rate,
	   TO_CHAR(NULL) supplier_number,
	   TO_NUMBER(NULL) supplier_contact_id,
	   TO_CHAR(NULL) item_revision,
	   TO_NUMBER(NULL) line_type_id,
           TO_NUMBER(NULL) buyer_id,
           sub.rowid row_id
    FROM   icx_por_oracle_item_subtable sub,
           po_approved_supplier_list pasl
    WHERE  sub.rt_item_id = p_rt_item_id
    AND    sub.orc_template_id is null
    AND    sub.orc_contract_id is null
    AND    sub.orc_asl_id is not null
    AND    pasl.asl_id = sub.orc_asl_id
    AND    (sub.orc_operating_unit_id is NULL AND
            pasl.owning_organization_id is NULL OR
            pasl.owning_organization_id =
              (SELECT fspa.inventory_organization_id
               FROM   financials_system_params_all fspa
               WHERE  fspa.org_id = sub.orc_operating_unit_id
               AND    rownum = 1))
  UNION ALL
    SELECT NVL(sub.orc_operating_unit_id, ICX_POR_EXT_ITEM.NULL_NUMBER) org_id,
           TO_NUMBER(ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_id,
           TO_CHAR(NULL) supplier_part_num,
           TO_NUMBER(ICX_POR_EXT_ITEM.NULL_NUMBER) supplier_site_id,
           1 type, -- Master Items
           msi.last_update_date last_update_date,
           DECODE(sub.search_type, 'SUPPLIER',
                  'PURCHASING_ITEM', 'INTERNAL_ITEM') price_type,
           TO_CHAR(NULL) item_description,
           TO_CHAR(NULL) template_id,
           TO_CHAR(NULL) rate_type,
	   TO_DATE(NULL) rate_date,
	   TO_NUMBER(NULL) rate,
	   TO_CHAR(NULL) supplier_number,
	   TO_NUMBER(NULL) supplier_contact_id,
	   TO_CHAR(NULL) item_revision,
	   TO_NUMBER(NULL) line_type_id,
           TO_NUMBER(NULL) buyer_id,
           sub.rowid row_id
    FROM   icx_por_oracle_item_subtable sub,
           icx_por_items item,
           mtl_system_items msi
    WHERE  sub.rt_item_id = p_rt_item_id
    AND    sub.orc_template_id is null
    AND    sub.orc_contract_id is null
    AND    sub.orc_asl_id is null
    AND    sub.rt_item_id = item.rt_item_id
    AND    item.orc_item_id is not null
    AND    msi.inventory_item_id = item.orc_item_id
    AND    (sub.orc_operating_unit_id is NULL AND
            msi.organization_id is NULL OR
            msi.organization_id =
              (SELECT fspa.inventory_organization_id
               FROM   financials_system_params_all fspa
               WHERE  fspa.org_id = sub.orc_operating_unit_id
               AND    rownum = 1))
  -- pcreddy : Bug # 3234875 : Order by type desc
  ORDER BY 1, 2, 3, 5 DESC, 6 DESC;
  --       org_id, supplier_id, supplier_part_num,
  --       type, last_update_date;

  xOrgIds		DBMS_SQL.NUMBER_TABLE;
  xSupplierIds		DBMS_SQL.NUMBER_TABLE;
  xSupplierPartNums	DBMS_SQL.VARCHAR2_TABLE;
  xSupplierSiteIds	DBMS_SQL.NUMBER_TABLE;
  xTypes		DBMS_SQL.NUMBER_TABLE;
  xLastUpdateDates	DBMS_SQL.DATE_TABLE;
  xPriceTypes		DBMS_SQL.VARCHAR2_TABLE;
  xItemDescriptions	DBMS_SQL.VARCHAR2_TABLE;
  xTemplateIds		DBMS_SQL.VARCHAR2_TABLE;
  xRateTypes 		DBMS_SQL.VARCHAR2_TABLE;
  xRateDates		DBMS_SQL.DATE_TABLE;
  xRates		DBMS_SQL.NUMBER_TABLE;
  xSupplierNumbers	DBMS_SQL.VARCHAR2_TABLE;
  xSupplierContactIds	DBMS_SQL.NUMBER_TABLE;
  xItemRevisions	DBMS_SQL.VARCHAR2_TABLE;
  xLineTypeIds		DBMS_SQL.NUMBER_TABLE;
  xBuyerIds		DBMS_SQL.NUMBER_TABLE;

  xRowIds          	DBMS_SQL.UROWID_TABLE;

  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);

  xOrgId 		NUMBER;
  xSupplierId 		NUMBER;
  xSupplierPartNum 	ICX_CAT_ITEMS_B.supplier_part_num%TYPE;
  xSupplierSiteId 	NUMBER;
  xRtItemId 		NUMBER;
  xType 		PLS_INTEGER;
  xActiveFlag		VARCHAR2(1);
  xCount		PLS_INTEGER;

  xTemplateItem		tTemplateItemRecord;

BEGIN
  xErrLoc := 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DETIL_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
      'Process item records for item: ' || gCurrentItem.rt_item_id);
  END IF;
  clearCache;

  xErrLoc := 60;
  OPEN cItemRecords(gCurrentItem.rt_item_id);

  xErrLoc := 70;
  FETCH cItemRecords
  BULK  COLLECT INTO xOrgIds, xSupplierIds,
                     xSupplierPartNums, xSupplierSiteIds,
                     xTypes, xLastUpdateDates,
                     xPriceTypes, xItemDescriptions,
                     xTemplateIds, xRateTypes, xRateDates,
                     xRates, xSupplierNumbers,
                     xSupplierContactIds, xItemRevisions,
                     xLineTypeIds, xBuyerIds, xRowIds;

  xErrLoc := 80;
  IF xOrgIds.COUNT = 0 THEN
    RETURN;
  END IF;

  xErrLoc := 100;
  IF (ICX_POR_EXT_UTL.gDebugLevel = ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..xOrgIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        'org_id: ' || xOrgIds(i) ||
        ', supplier_id: ' || xSupplierIds(i) ||
        ', supplier_part_num: ' || xSupplierPartNums(i) ||
        ', supplier_site_id: ' || xSupplierSiteIds(i) ||
        ', type: ' || xTypes(i) ||
        ', last_update_date: ' || xLastUpdateDates(i) ||
        ', price_type: ' || xPriceTypes(i) ||
        ', item_description: ' || xItemDescriptions(i) ||
        ', template_id: ' || xTemplateIds(i) ||
        ', rate_type: ' || xRateTypes(i) ||
	', rate_date: ' || xRateDates(i) ||
	', rate: ' || xRates(i) ||
	', supplier_number: ' || xSupplierNumbers(i) ||
	', supplier_contact_id: ' || xSupplierContactIds(i) ||
	', item_revision: ' || xItemRevisions(i) ||
	', line_type_id: ' || xLineTypeIds(i) ||
	', buyer_id: ' || xBuyerIds(i) ||
        ', rowid: ' || xRowIds(i));
    END LOOP;
  END IF;

  -- Set first item uniqueness criteria
  xOrgId := xOrgIds(1);
  xSupplierId := xSupplierIds(1);
  xSupplierPartNum := xSupplierPartNums(1);
  xSupplierSiteId := xSupplierSiteIds(1);
  xRtItemId := gCurrentItem.rt_item_id;
  xType := 0;

  -- Set global PL/SQL tables for Items
  xCount := gIRtItemIds.COUNT + 1;
  gIRtItemIds(xCount) := xRtItemId;
  gIOldRtItemIds(xCount) := gCurrentItem.rt_item_id;
  gIOrgIds(xCount) := xOrgId;
  gISupplierPartNums(xCount) := xSupplierPartNum;
  gIRtCategoryIds(xCount) := gCurrentItem.rt_category_id;
  IF (xTypes(1) = 3) THEN
    -- Bulkloaded item
    gIExtractorUpdatedFlags(xCount) := 'N';
  ELSE
    gIExtractorUpdatedFlags(xCount) := 'Y';
  END IF;
  -- Only update item description from template/contracts
  IF (xItemDescriptions(1) is not null) THEN
    xCount := gITRtItemIds.COUNT + 1;
    gITRtItemIds(xCount) := xRtItemId;
    gITItemDescriptions(xCount) := xItemDescriptions(1);
  END IF;

  xErrLoc := 150;
  FOR i in 1..xRowIds.COUNT LOOP
    -- Check item uniqueness
    IF (xOrgIds(i) = xOrgId AND
        xSupplierIds(i) = xSupplierId AND
        (xSupplierPartNums(i) IS NULL AND xSupplierPartNum IS NULL OR
         xSupplierPartNums(i) = xSupplierPartNum))
    THEN
      xErrLoc := 200;
      -- Set extractor updated flag
      IF xTypes(i) <> 3 THEN
        gIExtractorUpdatedFlags(gIExtractorUpdatedFlags.COUNT) := 'Y';
      END IF;

      -- Set active flag
      -- No longer check supplier_site
      -- IF xSupplierSiteIds(i) = xSupplierSiteId THEN
        IF xTypes(i) = 7 THEN
          -- Template_contract
          xActiveFlag := 'Y';
        ELSIF xTypes(i) = 6 THEN
          -- Contract
          IF xTemplateIds(i) <> TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER) THEN
            -- Contract with template reference
            xActiveFlag := 'N';
            -- Clear template_id
            xTemplateIds(i) := TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER);
          ELSE
            xActiveFlag := 'Y';
          END IF;
        ELSIF (xTypes(i) in (4, 5)) THEN
          -- Template, Internal template
          IF (xType = 0) THEN
            -- No documents with higher priority exist
            -- Only the first template line is active
            xActiveFlag := 'Y';
          ELSE
            xActiveFlag := 'N';
          END IF;
        ELSIF (xTypes(i) = 3) THEN
          -- Bulkloaded
          IF (xType = 0) THEN
            -- No documents with higher priority exist
            -- All Bulkloaded price list lines are active
            xActiveFlag := 'Y';
          ELSIF (xType = 3) THEN
            -- set active_flag as the previous record
            xActiveFlag := xActiveFlag;
          ELSE
            -- set active_flag to 'N'
            xActiveFlag := 'N';
          END IF;
        ELSIF (xTypes(i) = 2) THEN
          -- ASL
          IF (xType = 0) THEN
            -- No documents with higher priority exist
            -- All ASLs are active
            xActiveFlag := 'Y';
          ELSIF (xType = 2) THEN
            -- set active_flag as the previous record
            xActiveFlag := xActiveFlag;
          ELSE
            -- set active_flag to 'N'
            xActiveFlag := 'N';
          END IF;
        ELSIF (xTypes(i) = 1) THEN
          -- Master item record in subtable means no
          -- documents with higher priority exist
          xActiveFlag := 'Y';
        END IF; -- IF (xTypes(i) ... )

        -- Set xType
        xType := xTypes(i);
      -- No longer check supplier_site
      /*
      ELSE
        -- Different supplier_site_id
        xActiveFlag := 'Y';
        -- Reset xType
        xType := 0;
      END IF; -- IF (xSupplierSiteIds(i) = xSupplierSiteId)
      */

    ELSE
      xErrLoc := 240;
      -- Create new rt_item_id
      SELECT icx_por_itemid.nextval
      INTO   xRtItemId
      FROM   sys.dual;

      xErrLoc := 300;
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
        'Create a new item: ' || xRtItemId ||
        ' for item[old_rt_item_id: ' ||
        gCurrentItem.rt_item_id || ', org_id: ' ||
        xOrgIds(i) || ', supplier_id: ' ||
        xSupplierIds(i) || ', supplier_part_num: ' ||
        xSupplierPartNums(i) || ']' );

      xErrLoc := 310;
      -- Set global PL/SQL tables for Items
      xCount := gIRtItemIds.COUNT + 1;
      gIRtItemIds(xCount) := xRtItemId;
      gIOldRtItemIds(xCount) := gCurrentItem.rt_item_id;
      gIOrgIds(xCount) := xOrgIds(i);
      gISupplierPartNums(xCount) := xSupplierPartNums(i);
      gIRtCategoryIds(xCount) := gCurrentItem.rt_category_id;
      IF (xTypes(i) = 3) THEN
        -- Bulkloaded item
        gIExtractorUpdatedFlags(xCount) := 'N';
      ELSE
        gIExtractorUpdatedFlags(xCount) := 'Y';
      END IF;
      -- Only update item description from template/contracts
      IF (xItemDescriptions(i) is not null) THEN
        xCount := gITRtItemIds.COUNT + 1;
        gITRtItemIds(xCount) := xRtItemId;
        gITItemDescriptions(xCount) := xItemDescriptions(i);
      END IF;
      IF xTypes(i) = 6 THEN
        -- Clear template_id for Contract
        xTemplateIds(i) := TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER);
      END IF;
      xErrLoc := 320;
      -- Set active flag
      xActiveFlag := 'Y';
      -- Reset xType
      xType := 0;
    END IF;

    -- Set global PL/SQL tables for template headers for an item
    IF (xTemplateIds(i) <> TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER)) THEN
      -- Check for duplicate records
      xTemplateItem.template_id := xTemplateIds(i);
      xTemplateItem.rt_item_id := xRtItemId;
      IF NOT findTemplateItemCache(xTemplateItem) THEN
        xCount := gCIRtItemIds.COUNT + 1;
        gCIRtItemIds(xCount) := xRtItemId;
        gCITemplateIds(xCount) := xTemplateIds(i);
        putTemplateItemCache(xTemplateItem);
      END IF;
    END IF;

    xOrgId := xOrgIds(i);
    xSupplierId := xSupplierIds(i);
    xSupplierPartNum := xSupplierPartNums(i);
    xSupplierSiteId := xSupplierSiteIds(i);

    -- Set global PL/SQL tables for price records for an item
    IF (xTypes(i) <> 3) THEN
      -- Extracted price records
      xErrLoc := 500;
      xCount := gEPRtItemIds.COUNT + 1;
      gEPRtItemIds(xCount) := xRtItemId;
      gEPOrgIds(xCount) := xOrgIds(i);
      gEPActiveFlags(xCount) := xActiveFlag;
      gEPPriceTypes(xCount) := xPriceTypes(i);
      gEPRateTypes(xCount) := xRateTypes(i);
      gEPRateDates(xCount) := xRateDates(i);
      gEPRates(xCount) := xRates(i);
      gEPSupplierNumbers(xCount) := xSupplierNumbers(i);
      gEPSupplierContactIds(xCount) := xSupplierContactIds(i);
      gEPItemRevisions(xCount) := xItemRevisions(i);
      gEPLineTypeIds(xCount) := xLineTypeIds(i);
      gEPBuyerIds(xCount) := xBuyerIds(i);
      gEPRowIds(xCount) := xRowIds(i);
    ELSE
      -- Bulkloaded price records
      xErrLoc := 600;
      xCount := gBPRtItemIds.COUNT + 1;
      gBPRtItemIds(xCount) := xRtItemId;
      gBPOrgIds(xCount) := xOrgIds(i);
      gBPSupplierSiteIds(xCount) := xSupplierSiteIds(i);
      gBRActiveFlgs(xCount) := xActiveFlag;
      gBPPriceTypes(xCount) := xPriceTypes(i);
      gBPRowIds(xCount) := xRowIds(i);
    END IF;

  END LOOP;

  xErrLoc := 800;
  CLOSE cItemRecords;
EXCEPTION
  WHEN OTHERS THEN
    IF (cItemRecords%ISOPEN) THEN
      CLOSE cItemRecords;
    END IF;

    ROLLBACK;
    xReturnErr :=
      'processItems(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    raise ICX_POR_EXT_UTL.gException;
END processItems;

-- Move data into ICX_CAT_ITEMS_B, ICX_CAT_ITEMS_TLP, ICX_CAT_CATEGORY_ITEMS
PROCEDURE moveItems IS
  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);

  xSqlString 		VARCHAR2(4000);
  xCursorId  		NUMBER;
  xResultCount 		NUMBER;
  xMode			VARCHAR2(20) := 'ITEM';

BEGIN
  xErrLoc := 50;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'moveItem[Count: ' || gIRtItemIds.COUNT || ']');

  IF (ICX_POR_EXT_UTL.gDebugLevel = ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..gIRtItemIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        snapShot(i, xMode));
    END LOOP;
  END IF;

  xErrLoc := 100;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'ICX_CAT_ITEMS_B');

  -- Let's use object_version_number to store old_rt_item_id for now
  FORALL i IN 1..gIRtItemIds.COUNT
    INSERT INTO ICX_CAT_ITEMS_B
    (rt_item_id, object_version_number, org_id,
     supplier_id,
     supplier, supplier_part_num, supplier_part_auxid,
     internal_item_id, internal_item_num,
     extractor_updated_flag, last_update_login, last_updated_by, last_update_date,
     created_by, creation_date, request_id,
     program_application_id, program_id, program_update_date)
    SELECT gIRtItemIds(i), gIOldRtItemIds(i), gIOrgIds(i),
           NVL(item.supplier_id, ICX_POR_EXT_ITEM.NULL_NUMBER),
           item.A1, gISupplierPartNums(i), '##NULL##',
           item.orc_item_id, item.orc_item_num,
           gIExtractorUpdatedFlags(i),
           gUpgradeUserId, gUpgradeUserId, sysdate,
           gUpgradeUserId, item.creation_date, gUpgradeUserId,
           gUpgradeUserId, gUpgradeUserId, sysdate
    FROM   ICX_POR_ITEMS item
    WHERE  item.rt_item_id = gIOldRtItemIds(i);

  COMMIT;

  xErrLoc := 150;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'ICX_CAT_ITEMS_TLP');

  FORALL i IN 1..gIRtItemIds.COUNT
    INSERT INTO ICX_CAT_ITEMS_TLP
    (rt_item_id, language, org_id,
     supplier_id, item_source_type, search_type,
     primary_category_id, primary_category_name,
     internal_item_id, internal_item_num,
     supplier, supplier_part_num, supplier_part_auxid,
     manufacturer, manufacturer_part_num, description,
     comments, alias,
     picture, picture_url, thumbnail_image,
     attachment_url, long_description,
     unspsc_code, availability, lead_time, item_type,
     ctx_desc, last_update_login, last_updated_by, last_update_date,
     created_by, creation_date, request_id,
     program_application_id, program_id, program_update_date)
    SELECT gIRtItemIds(i), tl.language, gIOrgIds(i),
           NVL(item.supplier_id, ICX_POR_EXT_ITEM.NULL_NUMBER),
           item.item_source_type, item.search_type,
           gIRtCategoryIds(i), cat.category_name,
           item.orc_item_id, item.orc_item_num,
           item.A1, gISupplierPartNums(i), '##NULL##',
           item.A4, item.A5, tl.A7,
           tl.A8, tl.A9,
           NVL(item.A13, item.A14), item.A14, NVL(item.A13, item.A14),
           item.A22, tl.A23,
           item.A24, item.A25, to_number(item.A26), item.A29,
           NULL, gUpgradeUserId, gUpgradeUserId, sysdate,
           gUpgradeUserId, tl.creation_date, gUpgradeUserId,
           gUpgradeUserId, gUpgradeUserId, sysdate
    FROM   ICX_POR_ITEMS item,
           ICX_POR_ITEMS_TL tl,
           ICX_POR_CATEGORY_ITEMS ci,
           ICX_POR_CATEGORIES_TL cat
    WHERE  item.rt_item_id = gIOldRtItemIds(i)
    AND    item.rt_item_id = tl.rt_item_id
    AND    ci.rt_item_id = item.rt_item_id
    AND    cat.rt_category_id = ci.rt_category_id
    AND    cat.rt_category_id = gIRtCategoryIds(i)
    AND    tl.language = cat.language;

  COMMIT;

  xErrLoc := 200;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Dynamic SQL to update base attributes of ICX_CAT_ITEMS_TLP');

  IF (gDynSqlBaseAttributes IS NOT NULL) THEN
    xErrLoc := 210;
    xCursorId := DBMS_SQL.open_cursor;
    xErrLoc := 220;
    DBMS_SQL.parse(xCursorId, gDynSqlBaseAttributes, DBMS_SQL.NATIVE);
    xErrLoc := 230;
    DBMS_SQL.bind_array(xCursorId, ':new_rt_item_id', gIRtItemIds);
    xErrLoc := 240;
    DBMS_SQL.bind_array(xCursorId, ':old_rt_item_id', gIOldRtItemIds);
    xErrLoc := 250;
    xResultCount := DBMS_SQL.execute(xCursorId);
    xErrLoc := 260;
    DBMS_SQL.close_cursor(xCursorId);

    xErrLoc := 270;
    COMMIT;
  END IF;

  xErrLoc := 300;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Primary category into ICX_CAT_CATEGORY_ITEMS');

  FORALL i IN 1..gIRtItemIds.COUNT
    INSERT INTO ICX_CAT_CATEGORY_ITEMS
    (rt_item_id, rt_category_id,
     last_update_login, last_updated_by, last_update_date,
     created_by, creation_date, request_id,
     program_application_id, program_id, program_update_date)
    VALUES(gIRtItemIds(i), gIRtCategoryIds(i),
           gUpgradeUserId, gUpgradeUserId, sysdate,
           gUpgradeUserId, sysdate, gUpgradeUserId,
           gUpgradeUserId, gUpgradeUserId, sysdate);

  COMMIT;

  xErrLoc := 400;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'ICX_CAT_EXT_ITEMS_TLP');

  FORALL i IN 1..gIRtItemIds.COUNT
    INSERT INTO ICX_CAT_EXT_ITEMS_TLP
    (rt_item_id, language, org_id,
     rt_category_id, primary_flag,
     last_update_login, last_updated_by, last_update_date,
     created_by, creation_date, request_id,
     program_application_id, program_id, program_update_date)
    SELECT gIRtItemIds(i), tl.language, gIOrgIds(i),
           gIRtCategoryIds(i), NULL,
           gUpgradeUserId, gUpgradeUserId, sysdate,
           gUpgradeUserId, sysdate, gUpgradeUserId,
           gUpgradeUserId, gUpgradeUserId, sysdate
    FROM   ICX_POR_ITEMS_TL tl
    WHERE  tl.rt_item_id = gIOldRtItemIds(i);

  COMMIT;

  xErrLoc := 500;
  cleanTables(xMode);

  xErrLoc := 600;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'moveItems(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    ICX_POR_EXT_UTL.pushError(snapShot(SQL%ROWCOUNT+1, xMode));
    raise ICX_POR_EXT_UTL.gException;
END moveItems;

-- Update item_description of ICX_CAT_ITEMS_TLP
PROCEDURE updateItemsTLP IS
  xErrLoc	PLS_INTEGER;
  xReturnErr	VARCHAR2(2000);
  xMode		VARCHAR2(20) := 'TLP';

BEGIN
  xErrLoc := 50;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'updateItemsTLP[Count: ' || gITRtItemIds.COUNT || ']');

  IF (ICX_POR_EXT_UTL.gDebugLevel = ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..gITRtItemIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        snapShot(i, xMode));
    END LOOP;
  END IF;

  xErrLoc := 100;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Update item_description of ICX_CAT_ITEMS_TLP');

  FORALL i IN 1..gITRtItemIds.COUNT
    UPDATE ICX_CAT_ITEMS_TLP
    SET description = gITItemDescriptions(i)
    WHERE  rt_item_id = gITRtItemIds(i)
    AND    language = (SELECT language_code
                       FROM   fnd_languages
                       WHERE  installed_flag = 'B');

  COMMIT;

  xErrLoc := 150;
  cleanTables(xMode);

  xErrLoc := 200;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'updateItemsTLP(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    ICX_POR_EXT_UTL.pushError(snapShot(SQL%ROWCOUNT+1, xMode));
    raise ICX_POR_EXT_UTL.gException;
END updateItemsTLP;

-- Create template headers into ICX_CAT_CATEGORY_ITEMS
PROCEDURE createTempCategoryItems IS
  xErrLoc	PLS_INTEGER;
  xReturnErr	VARCHAR2(2000);
  xMode		VARCHAR2(20) := 'CAT_ITEM';

BEGIN
  xErrLoc := 50;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'createTempCategoryItems[Count: ' || gCIRtItemIds.COUNT || ']');

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Template headers into ICX_CAT_CATEGORY_ITEMS');

  xErrLoc := 100;
  IF (ICX_POR_EXT_UTL.gDebugLevel = ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..gCIRtItemIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        snapShot(i, xMode));
    END LOOP;
  END IF;

  FORALL i IN 1..gCIRtItemIds.COUNT
    INSERT INTO ICX_CAT_CATEGORY_ITEMS
    (rt_item_id, rt_category_id,
     last_update_login, last_updated_by, last_update_date,
     created_by, creation_date, request_id,
     program_application_id, program_id, program_update_date)
    SELECT gCIRtItemIds(i), cat.rt_category_id,
           gUpgradeUserId, gUpgradeUserId, sysdate,
           gUpgradeUserId, sysdate, gUpgradeUserId,
           gUpgradeUserId, gUpgradeUserId, sysdate
    FROM   ICX_POR_CATEGORIES_TL cat
    WHERE  cat.key = gCITemplateIds(i) || '_tmpl'
    AND    cat.type = 3
    AND    cat.language = (SELECT language_code
                           FROM   fnd_languages
                           WHERE  installed_flag = 'B');

  COMMIT;

  xErrLoc := 150;
  cleanTables(xMode);

  xErrLoc := 200;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'createTempCategoryItems(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    ICX_POR_EXT_UTL.pushError(snapShot(SQL%ROWCOUNT+1, xMode));
    raise ICX_POR_EXT_UTL.gException;
END createTempCategoryItems;

-- Move data into ICX_CAT_ITEM_PRICES from ICX_POR_ORACLE_ITEM_SUBTABLE
PROCEDURE moveExtractedPrices IS
  xErrLoc	PLS_INTEGER;
  xReturnErr	VARCHAR2(2000);
  xMode		VARCHAR2(20) := 'EXTRACTED_PRICE';

BEGIN
  xErrLoc := 50;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'moveExtractedPrices[Count: ' || gEPRtItemIds.COUNT || ']');

  IF (ICX_POR_EXT_UTL.gDebugLevel = ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..gEPRtItemIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        snapShot(i, xMode));
    END LOOP;
  END IF;

  xErrLoc := 100;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'ICX_CAT_ITEM_PRICES from ICX_POR_ORACLE_ITEM_SUBTABLE');

  FORALL i IN 1..gEPRtItemIds.COUNT
    INSERT INTO ICX_CAT_ITEM_PRICES
    (rt_item_id, price_type,
     active_flag, object_version_number,
     asl_id, supplier_site_id,
     contract_id, contract_line_id,
     template_id, template_line_id,
     inventory_item_id,
     mtl_category_id, org_id,
     search_type, unit_price,
     currency, unit_of_measure,
     functional_price, supplier_site_code,
     contract_num, contract_line_num,
     rate_type, rate_date, rate,
     supplier_number, supplier_contact_id,
     item_revision, line_type_id, buyer_id,
     price_list_id, last_update_login,
     last_updated_by, last_update_date,
     created_by, creation_date, request_id,
     program_application_id, program_id, program_update_date)
    SELECT gEPRtItemIds(i), gEPPriceTypes(i),
           gEPActiveFlags(i), 1,
           NVL(sub.orc_asl_id, ICX_POR_EXT_ITEM.NULL_NUMBER),
           NVL(sub.orc_supplier_site_id, ICX_POR_EXT_ITEM.NULL_NUMBER),
           NVL(sub.orc_contract_id, ICX_POR_EXT_ITEM.NULL_NUMBER),
           NVL(sub.orc_contract_line_id, ICX_POR_EXT_ITEM.NULL_NUMBER),
           -- PCREDDY: 3234875 : No template id for Contract lines
           DECODE(gEPPriceTypes(i), 'BLANKET', TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER),
             NVL(sub.orc_template_id, TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER))),
           DECODE(gEPPriceTypes(i), 'BLANKET', TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER),
             NVL(sub.orc_template_line_id, TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER))),
           NVL(item.orc_item_id, ICX_POR_EXT_ITEM.NULL_NUMBER),
           sub.orc_category_id, gEPOrgIds(i),
           sub.search_type, sub.unit_price,
           sub.currency, sub.unit_of_measure,
           sub.functional_price, sub.orc_supplier_site_code,
           sub.orc_contract_num, sub.orc_contract_line_num,
           gEPRateTypes(i), gEPRateDates(i), gEPRates(i),
           gEPSupplierNumbers(i), gEPSupplierContactIds(i),
           gEPItemRevisions(i), gEPLineTypeIds(i), gEPBuyerIds(i),
           NULL, gUpgradeUserId, gUpgradeUserId, sysdate,
           gUpgradeUserId, sub.creation_date, gUpgradePhaseId,
           gUpgradeUserId, gUpgradeUserId, sysdate
    FROM   ICX_POR_ORACLE_ITEM_SUBTABLE sub,
           ICX_POR_ITEMS item
    WHERE  sub.rowid = gEPRowIds(i)
    AND    item.rt_item_id = sub.rt_item_id;

  COMMIT;

  xErrLoc := 150;
  cleanTables(xMode);

  xErrLoc := 200;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'moveExtractedPrices(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    ICX_POR_EXT_UTL.pushError(snapShot(SQL%ROWCOUNT+1, xMode));
    raise ICX_POR_EXT_UTL.gException;
END moveExtractedPrices;

-- Move data into ICX_CAT_ITEM_PRICES from ICX_POR_PRICE_LIST_LINES
PROCEDURE moveBulkloadedPrices IS
  xErrLoc	PLS_INTEGER;
  xReturnErr	VARCHAR2(2000);
  xMode		VARCHAR2(20) := 'BULKLOADED_PRICE';

BEGIN
  xErrLoc := 50;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'moveBulkloadedPrices[Count: ' || gBPRtItemIds.COUNT || ']');

  xErrLoc := 100;
  IF (ICX_POR_EXT_UTL.gDebugLevel = ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..gBPRtItemIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        snapShot(i, xMode));
    END LOOP;
  END IF;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'ICX_CAT_ITEM_PRICES from ICX_POR_PRICE_LIST_LINES');

  xErrLoc := 200;
  FORALL i IN 1..gBPRtItemIds.COUNT
    INSERT INTO ICX_CAT_ITEM_PRICES
    (rt_item_id, price_type,
     active_flag, object_version_number,
     asl_id, supplier_site_id,
     contract_id, contract_line_id,
     template_id, template_line_id,
     inventory_item_id,
     mtl_category_id, org_id,
     search_type, unit_price,
     currency, unit_of_measure,
     functional_price,
     supplier_site_code,
     contract_num, contract_line_num,
     price_list_id, last_update_login,
     last_updated_by, last_update_date,
     created_by, creation_date, request_id,
     program_application_id, program_id, program_update_date)
    SELECT gBPRtItemIds(i), gBPPriceTypes(i),
           gBRActiveFlgs(i), 1,
           ICX_POR_EXT_ITEM.NULL_NUMBER,
           NVL(gBPSupplierSiteIds(i), ICX_POR_EXT_ITEM.NULL_NUMBER),
           NVL(prl.contract_reference_id, ICX_POR_EXT_ITEM.NULL_NUMBER),
           ICX_POR_EXT_ITEM.NULL_NUMBER,
           TO_CHAR(ICX_POR_EXT_ITEM.NULL_NUMBER),
           ICX_POR_EXT_ITEM.NULL_NUMBER,
           ICX_POR_EXT_ITEM.NULL_NUMBER,
           ICX_POR_EXT_ITEM.NULL_NUMBER, gBPOrgIds(i),
           'SUPPLIER', prl.unit_price,
           prl.currency_code, prl.uom,
           NULL, -- Leave functional_price as NULL
           prl.supplier_site,
           prl.contract_reference_num, NULL,
           prl.header_id,
           gUpgradeUserId, gUpgradeUserId, sysdate,
           gUpgradeUserId, prl.creation_date, gUpgradePhaseId,
           gUpgradeUserId, gUpgradeUserId, sysdate
    FROM   ICX_POR_PRICE_LIST_LINES prl
    WHERE  prl.rowid = gBPRowIds(i);

  COMMIT;

  xErrLoc := 300;
  cleanTables(xMode);

  xErrLoc := 400;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'moveBulkloadedPrices(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    ICX_POR_EXT_UTL.pushError(snapShot(SQL%ROWCOUNT+1, xMode));
    raise ICX_POR_EXT_UTL.gException;
END moveBulkloadedPrices;

-- Move data
PROCEDURE moveData (pMode VARCHAR2) IS
  xErrLoc	PLS_INTEGER;
  xReturnErr	VARCHAR2(2000);

BEGIN
  xErrLoc := 50;

  IF ((pMode = 'OUTLOOP' AND gIRtItemIds.COUNT > 0) OR
      gIRtItemIds.COUNT >= gCommitSize)
  THEN
    xErrLoc := 100;
    moveItems;
  END IF;
  IF ((pMode = 'OUTLOOP' AND gITRtItemIds.COUNT > 0) OR
      gITRtItemIds.COUNT >= gCommitSize)
  THEN
    xErrLoc := 200;
    updateItemsTLP;
  END IF;
  IF ((pMode = 'OUTLOOP' AND gCIRtItemIds.COUNT > 0) OR
      gCIRtItemIds.COUNT >= gCommitSize)
  THEN
    xErrLoc := 300;
    createTempCategoryItems;
  END IF;
  IF ((pMode = 'OUTLOOP' AND gEPRtItemIds.COUNT > 0) OR
      gEPRtItemIds.COUNT >= gCommitSize)
  THEN
    xErrLoc := 400;
    moveExtractedPrices;
  END IF;
  IF ((pMode = 'OUTLOOP' AND gBPRtItemIds.COUNT > 0) OR
      gBPRtItemIds.COUNT >= gCommitSize)
  THEN
    xErrLoc := 500;
    moveBulkloadedPrices;
  END IF;

  xErrLoc := 600;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'moveData(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    raise ICX_POR_EXT_UTL.gException;
END moveData;

-- Update category attributes of ICX_CAT_EXT_ITEMS_TLP
-- Note: We use icx_cat_items_b.object_version_number to
--       store old_rt_item_id during the upgrade process
PROCEDURE updateExtItemsTLP IS
  CURSOR cAllCategories IS
    SELECT cat.rt_category_id
    FROM   icx_cat_categories_tl cat
    WHERE  cat.type = ICX_POR_EXT_CLASS.CATEGORY_TYPE
    AND    cat.language = (SELECT language_code
                           FROM   fnd_languages
                           WHERE  installed_flag = 'B')
    AND    EXISTS (SELECT 'category attributes'
                   FROM   icx_por_descriptors_tl des
                   WHERE  des.rt_category_id = cat.rt_category_id)
    AND    EXISTS (SELECT 'items belong to this category'
                   FROM   icx_cat_category_items ci,
                          icx_cat_items_b i
                   WHERE  cat.rt_category_id = ci.rt_category_id
                   AND    i.rt_item_id = ci.rt_item_id);

  -- Cursor for all rt_item_ids with a rt_category_id
  CURSOR cCatItems(pRtCategoryId IN NUMBER) IS
    SELECT i.rt_item_id rt_item_id,
           decode(i.object_version_number, 1,
                  i.rt_item_id,
                  i.object_version_number) old_rt_item_id
    FROM   icx_cat_category_items ci,
           icx_cat_items_b i
    WHERE  ci.rt_category_id = pRtCategoryId
    AND    ci.rt_item_id = i.rt_item_id;

  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);

  xRtItemIds		DBMS_SQL.NUMBER_TABLE;
  xOldRtItemIds		DBMS_SQL.NUMBER_TABLE;

  xSqlString 		VARCHAR2(4000);
  xCursorId  		NUMBER;
  xResultCount 		NUMBER;

BEGIN
  xErrLoc := 50;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Update category attributes of ICX_CAT_EXT_ITEMS_TLP');

  FOR all_category IN cAllCategories LOOP
    xErrLoc := 100;
    -- Fetch category attributes
    fetchAttributes(all_category.rt_category_id);

    IF (gDynSqlCatAttributes IS NOT NULL) THEN
      xErrLoc := 150;
      OPEN cCatItems(all_category.rt_category_id);

      xErrLoc := 180;
      LOOP
        xRtItemIds.DELETE;
        xOldRtItemIds.DELETE;

        xErrLoc := 200;
        FETCH cCatItems
        BULK  COLLECT INTO xRtItemIds, xOldRtItemIds
        LIMIT gCommitSize;
        EXIT  WHEN xRtItemIds.COUNT = 0;

        xErrLoc := 210;
        IF (ICX_POR_EXT_UTL.gDebugLevel = ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
          FOR i in 1..xRtItemIds.COUNT LOOP
            ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
              'xRtItemIds('||i||'): '||xRtItemIds(i)||', '||
              'xOldRtItemIds('||i||'): '||xOldRtItemIds(i));
          END LOOP;
        END IF;

        -- Dynamic SQL to update category attributes of ICX_CAT_EXT_ITEMS_TLP

        xErrLoc := 220;
        xCursorId := DBMS_SQL.open_cursor;
        xErrLoc := 230;
        DBMS_SQL.parse(xCursorId, gDynSqlCatAttributes, DBMS_SQL.NATIVE);
        xErrLoc := 240;
        DBMS_SQL.bind_array(xCursorId, ':new_rt_item_id', xRtItemIds);
        xErrLoc := 260;
        DBMS_SQL.bind_array(xCursorId, ':old_rt_item_id', xOldRtItemIds);
        xErrLoc := 270;
        xResultCount := DBMS_SQL.execute(xCursorId);
        xErrLoc := 280;
        DBMS_SQL.close_cursor(xCursorId);

        xErrLoc := 300;
        IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DETIL_LEVEL THEN
          ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
            'Restore ICX_CAT_ITEMS_B.object_version_number to 1');
        END IF;

        xErrLoc := 320;
        -- Let's restore object_version_number to 1
        FORALL i IN 1..xRtItemIds.COUNT
          UPDATE icx_cat_items_b
          SET    object_version_number = 1
          WHERE  rt_item_id = xRtItemIds(i);

        COMMIT;
        xErrLoc := 350;
      END LOOP;

      xErrLoc := 400;
      CLOSE cCatItems;
    END IF;

  END LOOP;

  xErrLoc := 700;
EXCEPTION
  WHEN OTHERS THEN
    IF (cAllCategories%ISOPEN) THEN
      CLOSE cAllCategories;
    END IF;
    IF (cCatItems%ISOPEN) THEN
      CLOSE cCatItems;
    END IF;

    ROLLBACK;
    xReturnErr :=
      'updateExtItemsTLP(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    raise ICX_POR_EXT_UTL.gException;
END updateExtItemsTLP;

-- Create unextracted internal item price record
-- Only need to create row in icx_cat_item_prices
PROCEDURE createInternalItemPrices IS
  CURSOR cInternalItemPrices IS
    SELECT p.rowid
    FROM   icx_cat_item_prices p
    WHERE  p.price_type = 'INTERNAL_TEMPLATE'
    AND    NOT EXISTS (SELECT 'already upgraded'
                       FROM   icx_cat_item_prices p2
                       WHERE  p2.rt_item_id = p.rt_item_id
                       AND    p2.price_type = 'INTERNAL_ITEM');
  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);
  xRowIds		DBMS_SQL.UROWID_TABLE;
BEGIN
  xErrLoc := 50;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'create missing internal item prices');

  OPEN cInternalItemPrices;
  xErrLoc := 100;
  LOOP
    xRowIds.DELETE;
    xErrLoc := 120;
    FETCH cInternalItemPrices
    BULK  COLLECT INTO xRowIds
    LIMIT gCommitSize;
    EXIT  WHEN xRowIds.COUNT = 0;

    xErrLoc := 160;
    FORALL i IN 1..xRowIds.COUNT
      INSERT INTO ICX_CAT_ITEM_PRICES
      (rt_item_id, price_type,
       active_flag, object_version_number,
       asl_id, supplier_site_id,
       contract_id, contract_line_id,
       template_id, template_line_id,
       inventory_item_id,
       mtl_category_id, org_id,
       search_type, unit_price,
       currency, unit_of_measure,
       functional_price,
       supplier_site_code,
       contract_num, contract_line_num,
       price_list_id, last_update_login,
       last_updated_by, last_update_date,
       created_by, creation_date, request_id,
       program_application_id, program_id, program_update_date)
      SELECT p.rt_item_id, 'INTERNAL_ITEM',
             'N', 1,
             ICX_POR_EXT_ITEM.NULL_NUMBER, ICX_POR_EXT_ITEM.NULL_NUMBER,
             ICX_POR_EXT_ITEM.NULL_NUMBER, ICX_POR_EXT_ITEM.NULL_NUMBER,
             ICX_POR_EXT_ITEM.NULL_NUMBER, ICX_POR_EXT_ITEM.NULL_NUMBER,
             mi.inventory_item_id,
             p.mtl_category_id, p.org_id,
             'INTERNAL',
             mi.list_price_per_unit unit_price,
	     gsb.currency_code currency,
	     NVL(muom.uom_code, mi.primary_uom_code) unit_of_measure,
	     mi.list_price_per_unit functional_price,
             NULL, NULL, NULL, NULL,
             gUpgradeUserId, gUpgradeUserId, sysdate,
	     gUpgradeUserId, sysdate, gUpgradeUserId,
	     gUpgradeUserId, gUpgradeUserId, sysdate
      FROM   icx_cat_item_prices p,
             mtl_system_items_kfv mi,
	     gl_sets_of_books gsb,
	     financials_system_params_all fsp,
	     mtl_units_of_measure_tl muom
      WHERE  p.inventory_item_id = mi.inventory_item_id
      AND    p.org_id = fsp.org_id
      AND    mi.organization_id = fsp.inventory_organization_id
      AND    mi.unit_of_issue = muom.unit_of_measure(+)
      AND    muom.language(+) = ICX_POR_EXTRACTOR.gBaseLang
      AND    fsp.set_of_books_id = gsb.set_of_books_id
      AND    p.rowid = xRowIds(i);

    COMMIT;
    xErrLoc := 180;
  END LOOP;
  xErrLoc := 300;
  CLOSE cInternalItemPrices;

  xErrLoc := 600;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF (cInternalItemPrices%ISOPEN) THEN
      CLOSE cInternalItemPrices;
    END IF;
    xReturnErr :=
      'createInternalItemPrices(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    raise ICX_POR_EXT_UTL.gException;
END createInternalItemPrices;

-- Create unextracted purchasing item price record
-- If this item has internal part, will reuse the internal rt_item_id
-- This procedure has a cursor on item_prices and also modifies the
-- icx_cat_item_prices. This will cause snapshot too old error.
-- To avoid this, insert into item_prices with request_id=-20 and
-- make the cursor not pick these request ids(I.e. dont select the
-- rows which have been inserted by this phase)
PROCEDURE createPurchasingItemPrices IS
  snap_shot_too_old EXCEPTION;
  PRAGMA EXCEPTION_INIT(snap_shot_too_old, -1555);
  CURSOR cPurchasingItemPrices IS
    SELECT NVL(p.rt_item_id, icx_por_itemid.nextval) rt_item_id,
           i.rt_item_id old_rt_item_id,
           p.rt_item_id internal_rt_item_id,
           i.internal_item_id inventory_item_id,
           i.org_id org_id,
           getPrimaryCategoryId(i.rt_item_id) rt_category_id
    FROM   icx_cat_items_b i,
           icx_cat_item_prices p
    WHERE  i.internal_item_id IS NOT NULL
    AND    p.request_id <> gUpgradePhaseId
    AND    EXISTS (SELECT 'supplier sourced documents'
                   FROM   icx_cat_item_prices p2
                   WHERE  p2.inventory_item_id = i.internal_item_id
                   AND    p2.org_id = i.org_id
                   AND    p2.price_type IN ('BLANKET', 'QUOTATION',
                                            'TEMPLATE', 'ASL'))
    AND    i.internal_item_id = p.inventory_item_id (+)
    AND    i.org_id = p.org_id (+)
    AND    p.price_type(+) = 'INTERNAL_ITEM'
    AND    NOT EXISTS (SELECT 'already upgraded'
                       FROM   icx_cat_item_prices p2
                       WHERE  p2.rt_item_id = i.internal_item_id
                       AND    p2.org_id = i.org_id
                       AND    p2.price_type = 'PURCHASING_ITEM');
  xErrLoc		PLS_INTEGER;
  xCount		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);

  xRtItemIds		DBMS_SQL.NUMBER_TABLE;
  xOldRtItemIds		DBMS_SQL.NUMBER_TABLE;
  xInternalRtItemIds	DBMS_SQL.NUMBER_TABLE;
  xInventoryItemIds	DBMS_SQL.NUMBER_TABLE;
  xOrgIds		DBMS_SQL.NUMBER_TABLE;
  xRtCategoryIds	DBMS_SQL.NUMBER_TABLE;
  xLanguage             VARCHAR2(4);

BEGIN
  xErrLoc := 100;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'create missing purchasing item prices');

  xErrLoc := 101;
  SELECT language_code INTO xLanguage
  FROM   fnd_languages
  WHERE  installed_flag = 'B';

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'base language:' ||xLanguage);

  xErrLoc := 102;
  OPEN cPurchasingItemPrices;
  LOOP

   BEGIN
    xRtItemIds.DELETE;
    xOldRtItemIds.DELETE;
    xInternalRtItemIds.DELETE;
    xInventoryItemIds.DELETE;
    xOrgIds.DELETE;
    xRtCategoryIds.DELETE;

    xErrLoc := 120;
    FETCH cPurchasingItemPrices
    BULK  COLLECT INTO xRtItemIds,
                       xOldRtItemIds,
                       xInternalRtItemIds,
                       xInventoryItemIds,
                       xOrgIds,
                       xRtCategoryIds
    LIMIT gCommitSize;
    EXIT  WHEN xRtItemIds.COUNT = 0;

    xErrLoc := 160;
    FORALL i IN 1..xRtItemIds.COUNT
      INSERT INTO ICX_CAT_ITEM_PRICES
      (rt_item_id, price_type,
       active_flag, object_version_number,
       asl_id, supplier_site_id,
       contract_id, contract_line_id,
       template_id, template_line_id,
       inventory_item_id,
       mtl_category_id, org_id,
       search_type, unit_price,
       currency, unit_of_measure,
       functional_price,
       supplier_site_code,
       contract_num, contract_line_num,
       price_list_id, last_update_login,
       last_updated_by, last_update_date,
       created_by, creation_date, request_id,
       program_application_id, program_id, program_update_date)
      SELECT xRtItemIds(i), 'PURCHASING_ITEM',
             'N', 1,
             ICX_POR_EXT_ITEM.NULL_NUMBER, ICX_POR_EXT_ITEM.NULL_NUMBER,
             ICX_POR_EXT_ITEM.NULL_NUMBER, ICX_POR_EXT_ITEM.NULL_NUMBER,
             ICX_POR_EXT_ITEM.NULL_NUMBER, ICX_POR_EXT_ITEM.NULL_NUMBER,
             mi.inventory_item_id,
             mic.category_id mtl_category_id, xOrgIds(i),
             'SUPPLIER',
             mi.list_price_per_unit unit_price,
	     gsb.currency_code currency,
	     mi.primary_uom_code unit_of_measure,
	     mi.list_price_per_unit functional_price,
             NULL, NULL, NULL, NULL,
             gUpgradeUserId, gUpgradeUserId, sysdate,
	     gUpgradeUserId, sysdate, gUpgradePhaseId,
	     gUpgradeUserId, gUpgradeUserId, sysdate
      FROM   mtl_system_items_kfv mi,
             mtl_item_categories mic,
	     gl_sets_of_books gsb,
	     financials_system_params_all fsp,
             --Bug#3581356
             --Since categories are already upgraded,
             --so join with icx_cat_categories_tl to get the valid category
             icx_cat_categories_tl ictl
      WHERE  mi.inventory_item_id = xInventoryItemIds(i)
      AND    fsp.org_id = xOrgIds(i)
      AND    mi.organization_id = fsp.inventory_organization_id
      AND    mi.inventory_item_id = mic.inventory_item_id
      AND    mic.organization_id = mi.organization_id
             --Bug#3581356
             --Join with icx_cat_categories_tl to get the valid category
             --Add the join between gl_sets_of_books and
             --financials_system_params_all
      AND    fsp.set_of_books_id = gsb.set_of_books_id
      AND    ictl.key = to_char(mic.category_id)
      AND    ictl.language = xLanguage
      AND    ictl.type = 2;
    COMMIT;

    xErrLoc := 180;
    FOR i IN 1..xRtItemIds.COUNT LOOP
      IF xInternalRtItemIds IS NULL THEN
        -- Set global PL/SQL tables for Items
        gContinueExtItemTlp := TRUE;
	xCount := gIRtItemIds.COUNT + 1;
	gIRtItemIds(xCount) := xRtItemIds(i);
	gIOldRtItemIds(xCount) := xOldRtItemIds(i);
	gIOrgIds(xCount) := xOrgIds(i);
	gISupplierPartNums(xCount) := NULL;
	gIRtCategoryIds(xCount) := xRtCategoryIds(i);
	gIExtractorUpdatedFlags(xCount) := 'Y';
      END IF;
    END LOOP;

    xErrLoc := 200;
    moveData('INLOOP');

    xErrLoc := 280;
    EXCEPTION
      WHEN snap_shot_too_old THEN
        ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
        'ORA-01555: snapshot too old: caught at ' ||
        'ICX_CAT_FPI_UPGRADE.upgrade-' ||xErrLoc ||
        ', SQLERRM:' ||SQLERRM ||
        '; so close the cursor and repoen the cursor');
        xErrLoc := 282;
        ICX_POR_EXT_UTL.extAFCommit;
        IF (cPurchasingItemPrices%ISOPEN) THEN
          xErrLoc := 284;
          CLOSE cPurchasingItemPrices;
          xErrLoc := 286;
          OPEN cPurchasingItemPrices;
        END IF;
    END;

    xErrLoc := 288;


  END LOOP;

  gUpgradePhaseId := gUpgradeUserId;

  xErrLoc := 300;
  moveData('OUTLOOP');
  CLOSE cPurchasingItemPrices;

  xErrLoc := 600;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF (cPurchasingItemPrices%ISOPEN) THEN
      CLOSE cPurchasingItemPrices;
    END IF;
    xReturnErr :=
      'createPurchasingItemPrices(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    raise ICX_POR_EXT_UTL.gException;
END createPurchasingItemPrices;


--update the request_id of icx_cat_item_prices from -20 to -9
-- (-20) is the phase of create unextracted purchasing items
--
PROCEDURE updateRequestId IS

  xErrLoc              PLS_INTEGER;
  xRtItemIds           DBMS_SQL.NUMBER_TABLE;
  xReturnErr           VARCHAR2(2000);

  CURSOR cRequestId IS
    SELECT p.rt_item_id
    FROM  icx_cat_item_prices p
    WHERE p.request_id = CREATE_PURCHASING_PHASE;

  BEGIN
    xErrLoc := 710;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'update request_id of item prices table');

    OPEN cRequestId;
    LOOP
      xRtItemIds.DELETE;

      xErrLoc := 720;
      FETCH cRequestId
      BULK COLLECT INTO xRtItemIds
      LIMIT gCommitSize;
      EXIT WHEN xRtItemIds.COUNT = 0;

      xErrLoc := 740;
      FORALL i IN 1..xRtItemIds.COUNT
        UPDATE ICX_CAT_ITEM_PRICES
        SET request_id = gUpgradeUserId
        WHERE rt_item_id = xRtItemIds(i);
     COMMIT;

    END LOOP;

    xErrLoc := 760;
    CLOSE cRequestId;

    EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
      IF (cRequestId%ISOPEN) THEN
        CLOSE cRequestId;
      END IF;
      xReturnErr :=
        'updateRequestId(' ||xErrLoc||'): '||sqlerrm;
      gReturnErr := gReturnErr || '-->' || xReturnErr;
      ICX_POR_EXT_UTL.pushError(xReturnErr);
      raise ICX_POR_EXT_UTL.gException;
END updateRequestId;

-- Move records from icx_por_price_lists to icx_cat_price_lists
PROCEDURE movePriceLists IS
  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);
BEGIN
  xErrLoc := 50;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Move records from icx_por_price_lists to icx_cat_price_lists');

  xErrLoc := 100;
  LOOP
    INSERT INTO ICX_CAT_PRICE_LISTS
    (price_list_id, name, supplier_id, buyer_id,
     description, currency, creation_date, created_by,
     last_update_date, last_updated_by, last_update_login,
     request_id, begindate, enddate, status,
     published_date, outdated_date, approval_date,
     rejected_date, deleted_date, buyercomments,
     action, type, parent_header_id)
    SELECT
     header_id, name, supplier_id, buyer_id,
     description, currency_code, creation_date, created_by,
     sysdate, gUpgradeUserId, gUpgradeUserId,
     job_number, begindate, enddate, status,
     published_date, outdated_date, approval_date,
     rejected_date, deleted_date, buyercomments,
     action, type, parent_header_id
    FROM  ICX_POR_PRICE_LISTS old_list
    WHERE NOT EXISTS (SELECT 'Already upgraded'
                      FROM   ICX_CAT_PRICE_LISTS new_list
                      WHERE  old_list.header_id = new_list.price_list_id)
    AND   ROWNUM <= gCommitSize;

    EXIT WHEN SQL%ROWCOUNT < gCommitSize;

    COMMIT;
    xErrLoc := 200;
  END LOOP;
  xErrLoc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'movePriceLists(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    raise ICX_POR_EXT_UTL.gException;
END movePriceLists;

-- Update POR_FAVORITE_LIST_LINES
PROCEDURE updateFavoriteList IS
  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);
BEGIN
  xErrLoc := 100;
  IF (ICX_POR_EXT_UTL.gDebugLevel = ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..gUpFavRowIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        'rt_item_id: ' || gUpFavRtItemIds(i) ||
        ', rowid: ' || gUpFavRowIds(i));
    END LOOP;
  END IF;

  xErrLoc := 120;
  FORALL i IN 1..gUpFavRowIds.COUNT
    UPDATE por_favorite_list_lines
    SET    rt_item_id = gUpFavRtItemIds(i)
    WHERE  rowid = gUpFavRowIds(i);
  xErrLoc := 200;
  gUpFavRtItemIds.DELETE;
  gUpFavRowIds.DELETE;
  xErrLoc := 300;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'updateFavoriteList(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    raise ICX_POR_EXT_UTL.gException;
END updateFavoriteList;

-- Insert POR_FAVORITE_LIST_LINES
PROCEDURE insertFavoriteList IS
  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);
BEGIN
  xErrLoc := 100;
  IF (ICX_POR_EXT_UTL.gDebugLevel = ICX_POR_EXT_UTL.DETIL_LEVEL) THEN
    FOR i in 1..gInFavRowIds.COUNT LOOP
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        'rt_item_id: ' || gInFavRtItemIds(i) ||
        ', rowid: ' || gInFavRowIds(i));
    END LOOP;
  END IF;

  xErrLoc := 120;
  FORALL i IN 1..gInFavRowIds.COUNT
    INSERT INTO por_favorite_list_lines
    (favorite_list_line_id,
     favorite_list_id,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login,
     source_doc_header_id,
     source_doc_line_id,
     item_id,
     item_description,
     line_type_id,
     item_revision,
     category_id,
     unit_meas_lookup_code,
     unit_price,
     suggested_vendor_id,
     suggested_vendor_name,
     suggested_vendor_site_id,
     suggested_vendor_site,
     suggested_vendor_contact_id,
     suggested_vendor_contact,
     supplier_url,
     suggested_buyer_id,
     suggested_buyer,
     supplier_item_num,
     manufacturer_id,
     manufacturer_name,
     manufacturer_part_number,
     rfq_required_flag,
     attribute_category,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     category,
     rt_item_id,
     rt_category_id,
     suggested_vendor_contact_phone,
     new_supplier,
     asl_id,
     template_name,
     template_line_num,
     price_list_id,
     currency,
     rate_type,
     rate)
    SELECT
     por_favorite_list_lines_s.nextval,
     favorite_list_id,
     sysdate,
     gUpgradeUserId,
     sysdate,
     gUpgradeUserId,
     gUpgradeUserId,
     source_doc_header_id,
     source_doc_line_id,
     item_id,
     item_description,
     line_type_id,
     item_revision,
     category_id,
     unit_meas_lookup_code,
     unit_price,
     suggested_vendor_id,
     suggested_vendor_name,
     suggested_vendor_site_id,
     suggested_vendor_site,
     suggested_vendor_contact_id,
     suggested_vendor_contact,
     supplier_url,
     suggested_buyer_id,
     suggested_buyer,
     supplier_item_num,
     manufacturer_id,
     manufacturer_name,
     manufacturer_part_number,
     rfq_required_flag,
     attribute_category,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     category,
     gInFavRtItemIds(i),
     rt_category_id,
     suggested_vendor_contact_phone,
     new_supplier,
     asl_id,
     template_name,
     template_line_num,
     price_list_id,
     currency,
     rate_type,
     rate
    FROM  por_favorite_list_lines
    WHERE rowid = gInFavRowIds(i);
  xErrLoc := 200;
  gInFavRowIds.DELETE;
  gInFavRowIds.DELETE;
  xErrLoc := 300;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'insertFavoriteList(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    raise ICX_POR_EXT_UTL.gException;
END insertFavoriteList;

-- Upgrade POR_FAVORITE_LIST_LINES
PROCEDURE upgradeFavoriteList IS
  CURSOR cFavoriteListLines IS
    SELECT rowid,
           nvl(source_doc_header_id, ICX_POR_EXT_ITEM.NULL_NUMBER) contract_id,
           nvl(source_doc_line_id, ICX_POR_EXT_ITEM.NULL_NUMBER) contract_line_id,
           nvl(asl_id, ICX_POR_EXT_ITEM.NULL_NUMBER) asl_id,
           nvl(template_name, to_char(ICX_POR_EXT_ITEM.NULL_NUMBER)) template_id,
           nvl(template_line_num, ICX_POR_EXT_ITEM.NULL_NUMBER) template_line_id,
           nvl(item_id, ICX_POR_EXT_ITEM.NULL_NUMBER) inventory_item_id,
           price_list_id,
           rt_item_id
    FROM   por_favorite_list_lines
    WHERE  rt_item_id IS NOT NULL;

  TYPE tCursorType	IS REF CURSOR;
  cMatchRtItemIds	tCursorType;

  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);
  xRtItemIds		DBMS_SQL.NUMBER_TABLE;
  xCount		PLS_INTEGER;

BEGIN
  xErrLoc := 50;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'upgrade POR_FAVORITE_LIST_LINES');

  xErrLoc := 100;
  FOR favorite IN cFavoriteListLines LOOP
    xErrLoc := 120;
    IF favorite.price_list_id IS NULL THEN
      OPEN cMatchRtItemIds FOR
        SELECT distinct rt_item_id
        FROM   icx_cat_item_prices
        WHERE  contract_id = favorite.contract_id
        AND    contract_line_id = favorite.contract_line_id
        AND    asl_id = favorite.asl_id
        AND    template_id = favorite.template_id
        AND    template_line_id = favorite.template_line_id
        AND    inventory_item_id = favorite.inventory_item_id
        AND    price_list_id IS NULL;
    ELSE
      OPEN cMatchRtItemIds FOR
        SELECT distinct p.rt_item_id
        FROM   icx_cat_item_prices p,
               icx_cat_items_b i,
               icx_por_items oi
        WHERE  p.price_list_id = favorite.price_list_id
        AND    p.rt_item_id = i.rt_item_id
        AND    oi.rt_item_id = favorite.rt_item_id
        AND    i.supplier = oi.a1
        AND    i.supplier_part_num = oi.a3;
    END IF;

    xRtItemIds.DELETE;
    xErrLoc := 140;
    FETCH cMatchRtItemIds
    BULK  COLLECT INTO xRtItemIds;
    EXIT  WHEN xRtItemIds.COUNT = 0;

    xErrLoc := 160;
    IF xRtItemIds.COUNT = 1 THEN
      IF favorite.rt_item_id <> xRtItemIds(1) THEN
        xErrLoc := 180;
        xCount := gUpFavRowIds.COUNT + 1;
        gUpFavRowIds(xCount) := favorite.rowid;
        gUpFavRtItemIds(xCount) := xRtItemIds(1);
      END IF;
    ELSE
      xErrLoc := 200;
      xCount := gUpFavRowIds.COUNT + 1;
      gUpFavRowIds(xCount) := favorite.rowid;
      gUpFavRtItemIds(xCount) := xRtItemIds(1);
      FOR i IN 2..xRtItemIds.COUNT LOOP
        xErrLoc := 220;
        xCount := gInFavRowIds.COUNT + 1;
        gInFavRowIds(xCount) := favorite.rowid;
        gInFavRtItemIds(xCount) := xRtItemIds(i);
      END LOOP;
    END IF;
    xErrLoc := 240;
    IF gUpFavRowIds.COUNT >= gCommitSize THEN
      updateFavoriteList;
    END IF;
    xErrLoc := 260;
    IF gInFavRowIds.COUNT >= gCommitSize THEN
      insertFavoriteList;
    END IF;
    xErrLoc := 280;
  END LOOP;

  xErrLoc := 300;
  updateFavoriteList;
  xErrLoc := 320;
  insertFavoriteList;

  xErrLoc := 600;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    IF (cFavoriteListLines%ISOPEN) THEN
      CLOSE cFavoriteListLines;
    END IF;
    xReturnErr :=
      'upgradeFavoriteList(' ||xErrLoc||'): '||sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    raise ICX_POR_EXT_UTL.gException;
END upgradeFavoriteList;

PROCEDURE setLog (pLogLevel	IN NUMBER,
		  pLogFile	IN VARCHAR2)
IS
BEGIN
  gLogLevel := pLogLevel;
  gLogFile := pLogFile;
END setLog;

PROCEDURE startLog IS
BEGIN
  ICX_POR_EXT_UTL.setDebugLevel(gLogLevel);
  ICX_POR_EXT_UTL.setUseFile(1);
  ICX_POR_EXT_UTL.setFilePath(ICX_POR_EXT_UTL.UTL_FILE_DIR);
  ICX_POR_EXT_UTL.openLog(gLogFile);
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Start...');
END startLog;

PROCEDURE endLog IS
BEGIN
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'End...');
  ICX_POR_EXT_UTL.closeLog;
END endLog;

PROCEDURE setCommitSize (pCommitSize	IN NUMBER)
IS
BEGIN
  gCommitSize := pCommitSize;
END setCommitSize;

PROCEDURE cleanupJobTables IS
  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);
  xIcxSchema		VARCHAR2(20);

BEGIN
  xErrLoc := 50;
  xIcxSchema := ICX_POR_EXT_UTL.getIcxSchema;

  xErrLoc := 100;
  -- ICX_POR_BATCH_JOBS
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||
    xIcxSchema || '.icx_por_batch_jobs';

  xErrLoc := 200;
  -- ICX_POR_FAILED_LINES
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||
    xIcxSchema || '.icx_por_failed_lines';

  xErrLoc := 300;
  -- ICX_POR_FAILED_LINE_MESSAGES
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||
    xIcxSchema || '.icx_por_failed_line_messages';

  xErrLoc := 400;
  -- ICX_POR_CONTRACT_REFERENCES
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||
    xIcxSchema || '.icx_por_contract_references';

  xErrLoc := 500;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'cleanupJobTables(' ||xErrLoc||'): '||sqlerrm;
    raise_application_error(-20000, xReturnErr);
END cleanupJobTables;

FUNCTION isAlreadyUpgraded RETURN NUMBER
IS
  xResult		NUMBER;
BEGIN
  SELECT 1
  INTO	 xResult
  FROM   dual
  WHERE  EXISTS (SELECT 'schema records'
                 FROM   icx_cat_categories_tl
                 WHERE  rt_category_id > 0)
  OR     EXISTS (SELECT 'data records'
                 FROM   icx_cat_items_b);
  RETURN xResult;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    xResult := 0;
  RETURN xResult;
END isAlreadyUpgraded;

PROCEDURE rollbackUpgrade IS
  xErrLoc			PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);
  xIcxSchema		VARCHAR2(20);

BEGIN
  xErrLoc := 50;
  xIcxSchema := ICX_POR_EXT_UTL.getIcxSchema;

  xErrLoc := 100;
  -- ICX_CAT_ITEMS_B
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||
    xIcxSchema || '.icx_cat_items_b';

  xErrLoc := 200;
  -- ICX_CAT_ITEMS_TLP
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||
    xIcxSchema || '.icx_cat_items_tlp';

  xErrLoc := 300;
  -- ICX_CAT_EXT_ITEMS_TLP
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||
    xIcxSchema || '.icx_cat_ext_items_tlp';

  xErrLoc := 400;
  -- ICX_CAT_CATEGORY_ITEMS
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||
    xIcxSchema || '.icx_cat_category_items';

  xErrLoc := 500;
  -- ICX_CAT_ITEM_PRICES
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||
    xIcxSchema || '.icx_cat_item_prices';

  xErrLoc := 600;
  -- ICX_CAT_ITEM_PRICES
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' ||
    xIcxSchema || '.icx_cat_price_lists';

  xErrLoc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    xReturnErr :=
      'rollbackUpgrade(' ||xErrLoc||'): '||sqlerrm;
    raise_application_error(-20000, xReturnErr);
END rollbackUpgrade;

-- Main upgrade procedure
PROCEDURE upgrade IS
  xErrLoc		PLS_INTEGER;
  xReturnErr		VARCHAR2(2000);
  CURSOR cAllItems IS
    SELECT item.rt_item_id,
           getOldPrimaryCategoryId(item.rt_item_id) rt_category_id
    FROM   icx_por_items item
    WHERE  NOT EXISTS (SELECT 'already upgraded'
                       FROM   icx_cat_items_b new_item
                       WHERE  item.rt_item_id = new_item.rt_item_id)
    AND    (EXISTS (SELECT 'extracted price'
                    FROM   icx_por_oracle_item_subtable sub
                    WHERE  sub.rt_item_id = item.rt_item_id) OR
            EXISTS (SELECT 'bulkloaded price'
                    FROM   icx_por_price_list_lines pll
                    WHERE  pll.item_id = item.rt_item_id));
BEGIN
  xErrLoc := 50;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Start Data Upgrade...');

  xErrLoc := 60;
  -- Bug 2813141, job tables should be cleaned before odf applied
  -- move this procedure into a pre-upgrade script: icxprupi.sql
  -- cleanupJobTables;
  initCaches;

  xErrLoc := 70;
  -- Fetch base attributes
  fetchAttributes(0);

  cleanTables('ALL');

  xErrLoc := 100;
  FOR all_item IN cAllItems LOOP
    xErrLoc := 140;
    gCurrentItem := all_item;
    IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DETIL_LEVEL THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DETIL_LEVEL,
        'gCurrentItem[rt_item_id: ' || gCurrentItem.rt_item_id ||
        ', rt_category_id: ' || gCurrentItem.rt_category_id || ']');
    END IF;

    xErrLoc := 180;
    IF gCurrentItem.rt_category_id IS NOT NULL THEN
      gContinueExtItemTlp := TRUE;
      xErrLoc := 200;
      processItems;
      xErrLoc := 300;
      moveData('INLOOP');
    END IF;
  END LOOP;
  xErrLoc := 400;
  moveData('OUTLOOP');

  xErrLoc := 500;
  movePriceLists;
  xErrLoc := 600;
  createInternalItemPrices;
  xErrLoc := 700;
  gUpgradePhaseId := CREATE_PURCHASING_PHASE;
  createPurchasingItemPrices;
  xErrLoc := 750;
  updateRequestId;
  xErrLoc := 850;
  gUpgradePhaseId := gUpgradeUserId;
  IF gContinueExtItemTlp THEN
    updateExtItemsTLP;
  END IF;

  -- sosingha bug# 3285223: Merge b2847879.sql into the main procedure
  xErrLoc := 900;
      upgradeFavoriteList;

  xErrLoc := 1000;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'End Data Upgrade...');
EXCEPTION
  WHEN OTHERS THEN
    IF (cAllItems%ISOPEN) THEN
      CLOSE cAllItems;
    END IF;

    rollback;
    xReturnErr :=
      'upgrade(' || xErrLoc || '): ' || sqlerrm;
    gReturnErr := gReturnErr || '-->' || xReturnErr;
    ICX_POR_EXT_UTL.pushError(xReturnErr);
    ICX_POR_EXT_UTL.printStackTrace;
    raise_application_error(-20000, gReturnErr);
END upgrade;

END ICX_CAT_FPI_UPGRADE;

/
