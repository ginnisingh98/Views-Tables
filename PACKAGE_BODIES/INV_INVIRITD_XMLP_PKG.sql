--------------------------------------------------------
--  DDL for Package Body INV_INVIRITD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRITD_XMLP_PKG" AS
/* $Header: INVIRITDB.pls 120.2 2008/01/08 06:53:22 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_BREAK_ID = 1 THEN
        P_ORDERBY := 'ORDER BY C_CAT_FLEX,  C_ITEM_FLEX';
      ELSE
        P_ORDERBY := 'ORDER BY C_ITEM_FLEX, C_CAT_FLEX2';
      END IF;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Error Initializing SRW  :SRWINIT')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_	EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Invalid Item Flexfield :MSTK')*/NULL;
        RAISE;
    END;
    BEGIN
      SELECT
        DISTINCT
        MEANING
      INTO P_YES_VALUE
      FROM
        FND_LOOKUP_VALUES
      WHERE LOOKUP_CODE = 'Y'
        AND LOOKUP_TYPE = 'YES_NO'
        AND LANGUAGE = USERENV('LANG')
        AND VIEW_APPLICATION_ID = 0;
      SELECT
        DISTINCT
        MEANING
      INTO P_NO_VALUE
      FROM
        FND_LOOKUP_VALUES
      WHERE LOOKUP_CODE = 'N'
        AND LOOKUP_TYPE = 'YES_NO'
        AND LANGUAGE = USERENV('LANG')
        AND VIEW_APPLICATION_ID = 0;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Invalid Value for Lookup_Type')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_ITEM_HI IS NULL AND P_ITEM_LO IS NULL THEN
        NULL;
      ELSIF P_ITEM_HI = P_ITEM_LO THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Invalid Item Flexfield :where:MSTK')*/NULL;
        RAISE;
    END;
    BEGIN
      BEGIN
        NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(3
                     ,'Invalid Category Flexfield:where:MCAT')*/NULL;
          RAISE;
      END;
      BEGIN
        NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'Invalid Category Flexfield:MCAT')*/NULL;
          RAISE;
      END;
    END;
    BEGIN
      IF P_BOM_INFO = '1' OR P_ALL_INFO = '1' THEN
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(30
                       ,'Invalid Item Flexfield :BOM:MSTK')*/NULL;
            RAISE;
        END;
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(30
                       ,'Invalid Item Flexfield :ENG:MSTK')*/NULL;
            RAISE;
        END;
      ELSE
        NULL;
      END IF;
    END;
    BEGIN
      IF P_CST_INFO = '1' OR P_ALL_INFO = '1' THEN
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(31
                       ,'Invalid Accounting Flexfield :CST:GL#')*/NULL;
            RAISE;
        END;
      ELSE
        NULL;
      END IF;
    END;
    BEGIN
      IF P_PO_INFO = '1' OR P_ALL_INFO = '1' THEN
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(40
                       ,'Invalid Accounting Flexfield :ENC_ACCT:GL#')*/NULL;
            RAISE;
        END;
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(40
                       ,'Invalid Accounting Flexfield :EXP_ACCT:GL#')*/NULL;
            RAISE;
        END;
        /*SRW.MESSAGE(99
                   ,'Debug Mode 1: PO Attributes')*/NULL;
        SELECT
          count(*),
          MAX(CATEGORY_FLEX_STRUCTURE)
        INTO P_FA_INSTALLED,P_ACAT_STRUCT_NUM
        FROM
          FA_SYSTEM_CONTROLS;
        /*SRW.MESSAGE(99
                   ,'Debug Mode 2: ' || TO_CHAR(P_FA_INSTALLED))*/NULL;
        /*SRW.MESSAGE(99
                   ,'Debug Mode 3: ' || TO_CHAR(P_ACAT_STRUCT_NUM))*/NULL;
        IF P_FA_INSTALLED <> 0 THEN
          BEGIN
            /*SRW.MESSAGE(99
                       ,'Debug Mode [3-1]: ' || TO_CHAR(P_ACAT_STRUCT_NUM))*/NULL;
            /*SRW.MESSAGE(99
                       ,'Debug Mode [3-2]: ' || TO_CHAR(P_ACAT_STRUCT_NUM))*/NULL;
          EXCEPTION
            WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
              /*SRW.MESSAGE(40
                         ,'Invalid Category Flexfield :CAT#')*/NULL;
              RAISE;
          END;
        ELSE
          P_PO_ACAT_FLEX := '''x''';
        END IF;
        /*SRW.MESSAGE(99
                   ,'Debug Mode 4: ' || TO_CHAR(P_ACAT_STRUCT_NUM))*/NULL;
      ELSE
        NULL;
      END IF;
    END;
    BEGIN
      IF P_WIP_INFO = '1' OR P_ALL_INFO = '1' THEN
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(70
                       ,'Invalid Locator Flexfield :MTLL')*/NULL;
            RAISE;
        END;
      ELSE
        NULL;
      END IF;
    END;
    BEGIN
      IF P_INVC_INFO = '1' OR P_ALL_INFO = '1' THEN
        BEGIN
          NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(90
                       ,'Invalid Accounting Flexfield :INVC_ACCT:GL#')*/NULL;
            RAISE;
        END;
      ELSE
        NULL;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'SRWEXIT failed')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_GEN_INFO_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_GEN_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (',INV_MEANING_SEL.c_mfg_lookup(' || 'msi.ALLOWED_UNITS_LOOKUP_CODE' || ',''MTL_CONVERSION_TYPE'') Conversions,
             	/*MSI.inventory_item_status_code	Item_status, */
                     INV_MEANING_SEL.C_ITEM_STATUS(msi.INVENTORY_ITEM_STATUS_CODE) Item_Status,
             	INV_MEANING_SEL.c_fnd_lookup(msi.ITEM_TYPE,''ITEM_TYPE'') Item_type,
             	MSI.primary_unit_of_measure	Primary_uom,
             	decode(MSI.DUAL_UOM_CONTROL, 1, ''Non-Dual'', 2, ''Fixed'', 3, ''Default'', 4, ''No Default'', NULL)	DUAL_UOM_CONTROL,
             	INV_MEANING_SEL.C_UNITMEASURE(msi.SECONDARY_UOM_CODE)	SECONDARY_UOM_CODE,
             	msi.DUAL_UOM_DEVIATION_HIGH	DUAL_UOM_DEVIATION_HIGH,
             	msi.DUAL_UOM_DEVIATION_LOW	DUAL_UOM_DEVIATION_LOW,
             	INV_MEANING_SEL.c_fnd_lookup_vl(msi.TRACKING_QUANTITY_IND,''INV_TRACKING_UOM_TYPE'') Tracking_Quantity_Ind,
             	INV_MEANING_SEL.c_fnd_lookup_vl(msi.ONT_PRICING_QTY_SOURCE,''INV_PRICING_UOM_TYPE'') Ont_Pricing_Qty_Source,
             	INV_MEANING_SEL.c_fnd_lookup_vl(msi.SECONDARY_DEFAULT_IND,''INV_DEFAULTING_UOM_TYPE'') Secondary_Default_Ind');
    ELSE
      RETURN (' ,''z'' Conversions,
             		''x'' 	Item_status,
             		''x''	Item_type,
             		''x''	Primary_uom,
             		''x''	DUAL_UOM_CONTROL,
             		''x''	SECONDARY_UOM_CODE,
             		0	DUAL_UOM_DEVIATION_HIGH,
             		0	DUAL_UOM_DEVIATION_LOW,
             		''x''	TRACKING_QUANTITY_IND,
             		''x''	ONT_PRICING_QTY_SOURCE,
             		''x''	SECONDARY_DEFAULT_IND');
    END IF;
    RETURN NULL;
  END C_GEN_INFO_SELFORMULA;

  FUNCTION C_GEN_INFO_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_GEN_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN ('/* Do not select general information */');
    END IF;
    RETURN NULL;
  END C_GEN_INFO_FROMFORMULA;

  FUNCTION C_GEN_INFO_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_GEN_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_GEN_INFO_WHEREFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_CAT_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN ('mtl_item_categories mic, mtl_categories_b mc, ');
  END C_CAT_FROMFORMULA;

  FUNCTION C_CAT_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN ('and msi.inventory_item_id = mic.inventory_item_id
                   and mic.category_id = mc.category_id
                   and mic.category_set_id = ' || TO_CHAR(P_CAT_SET_ID) || '
                   and mic.organization_id = msi.organization_id');
  END C_CAT_WHEREFORMULA;

  FUNCTION C_CAT_PADFORMULA(C_CAT_FIELD IN VARCHAR2
                           ,C_CAT_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_CAT_FIELD)*/NULL;
    RETURN (C_CAT_PAD);
  END C_CAT_PADFORMULA;

  FUNCTION C_BOM_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BOM_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (',' || P_BOM_ITEM_FLEX || '	 C_bom_item_flex,
                     INV_MEANING_SEL.c_mfg_lookup(' || 'msi.bom_item_type' || ',''BOM_ITEM_TYPE'')    BOM_item_type,
             	decode(msi.BOM_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)		BOM_allowed,
             	MSI.ENGINEERING_ECN_CODE	Engineering_Change_Order,
                     decode(msi.ENG_ITEM_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)		Engineering_item,
             	' || P_ENG_ITEM_FLEX || '		C_eng_item_flex ,
             	decode(msi.Effectivity_Control, 1,''Date'',2,''Model/Unit Number'',NULL)  	Effectivity_Control,
             	INV_MEANING_SEL.c_fnd_lookup_vl(' || 'msi.CONFIG_MODEL_TYPE ' || ',''CZ_CONFIG_MODEL_TYPE'')  Config_model_type ,
             	decode(msi.Auto_Created_Config_Flag,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Auto_Created_Config_Flag,
             	INV_MEANING_SEL.c_fnd_lookup_vl(' || 'msi.CONFIG_ORGS ' || ',''INV_CONFIG_ORGS_TYPE'')  Config_orgs ,
             	INV_MEANING_SEL.c_fnd_lookup_vl(' || 'msi.CONFIG_MATCH ' || ',''INV_CONFIG_MATCH_TYPE'')  Config_match
                   ');
    ELSE
      RETURN (',''x''		C_bom_item_flex,
             	''x''		BOM_item_type,
             	''x''		BOM_allowed,
             	''x''		Engineering_Change_Order,
             	''x''		Engineering_item,
             	''x''		C_eng_item_flex ,
             	''x''		Effectivity_Control,
             	''x''		Config_model_type,
             	''x''		Auto_Created_Config_Flag,
             	''x''		Config_orgs,
             	''x''		Config_match
                    ');
    END IF;
    RETURN NULL;
  END C_BOM_SELFORMULA;

  FUNCTION C_BOM_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BOM_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN ('  mtl_system_items_b BIF,
             	  mtl_system_items_b EIF, ');
    ELSE
      RETURN (' /* Do not select BOM info */ ');
    END IF;
    RETURN NULL;
  END C_BOM_FROMFORMULA;

  FUNCTION C_BOM_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BOM_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN ('and msi.BASE_ITEM_ID = BIF.inventory_item_id(+)
             	and BIF.organization_id(+) = ' || TO_CHAR(P_ORG_ID) || '
             	and msi.ENGINEERING_ITEM_ID = EIF.inventory_item_id(+)
             	and EIF.organization_id(+) = ' || TO_CHAR(P_ORG_ID) || ' ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_BOM_WHEREFORMULA;

  FUNCTION C_CST_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_CST_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (', decode(msi.COSTING_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Costing_enabled
             	, ' || P_CST_ACCT_FLEX || '	C_cst_acct_flex
             	, decode(msi.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Include_in_rollup
             	, decode(msi.INVENTORY_ASSET_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Inventory_asset_value
             	, MSI.std_lot_size	Standard_lot_size ');
    ELSE
      RETURN (', ''z''	Costing_enabled
             	, ''x''	C_cst_acct_flex
             	, ''x''	Include_in_rollup
             	, ''x''	Inventory_asset_value
             	,   0	Standard_lot_size ');
    END IF;
    RETURN NULL;
  END C_CST_SELFORMULA;

  FUNCTION C_CST_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_CST_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (' gl_code_combinations CST, ');
    ELSE
      RETURN ('/* Do not select Costing Options */');
    END IF;
    RETURN NULL;
  END C_CST_FROMFORMULA;

  FUNCTION C_CST_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_CST_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN ('and msi.COST_OF_SALES_ACCOUNT = CST.code_combination_id(+) ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_CST_WHEREFORMULA;

  FUNCTION C_PO_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_PO_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (',MSI.asset_category_id  Asset_category_id
                     ,MSI.RECEIVE_CLOSE_TOLERANCE Receive_Close_Tolerance
                     ,MSI.INVOICE_CLOSE_TOLERANCE Invoice_Close_Tolerance
                     ,decode(msi.RECEIPT_REQUIRED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)        Receipt_Required
                     ,decode(msi.INSPECTION_REQUIRED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)     Inspection_Required
             	,decode(msi.PURCHASING_ITEM_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)    	Purchasing_item
             	,decode(msi.MUST_USE_APPROVED_VENDOR_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Use_approved_vendor
             	,decode(msi.TAXABLE_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	Taxable_item
             	,decode(msi.ALLOW_ITEM_DESC_UPDATE_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)	Allow_description_update
             	,MSI.market_price	Market_price
             	,INV_MEANING_SEL.c_po_un_numb(msi.UN_NUMBER_ID)	UN_number
             	,INV_MEANING_SEL.C_PO_HAZARD_CLASS(msi.HAZARD_CLASS_ID)	Hazard_Class
             	,decode(msi.RFQ_REQUIRED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)		RFQ_Required
             	,MSI.list_price_per_unit	List_price
             	,MSI.PRICE_TOLERANCE_PERCENT	Price_tolerance_percent
             	,' || P_PO_ACAT_FLEX || '		C_acat_flex
             	,decode(msi.OUTSIDE_OPERATION_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)	Outside_Operation
             	,MSI.OUTSIDE_OPERATION_UOM_TYPE	Outside_Operation_Unit_Type
             	,MSI.ROUNDING_FACTOR		Rounding_Factor
             	,MSI.UNIT_OF_ISSUE		Unit_of_Issue
             	,' || P_PO_EXP_ACCT_FLEX || '	Expense_Account
             	,' || P_PO_ENC_ACCT_FLEX || '	Encumbrance_Account
             	,INV_MEANING_SEL.C_PER_PEOPLE(msi.buyer_id)	Default_Buyer
             	,decode(msi.PURCHASING_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)		Purchasable
             	,msi.purchasing_tax_code	Purchasing_tax_code
             ');
    ELSE
      RETURN (',  0    Asset_category_id
                     , 0 Receive_Close_Tolerance
                     , 0 Invoice_Close_Tolerance
                     , ''x'' Receipt_Required
                     , ''x'' Inspection_Required
             	,''x''	Purchasing_item
             	,''x''	Use_approved_vendor
             	,''x''	Taxable_item
             	,''x''	Allow_description_update
             	,  0	Market_price
             	,''x''		UN_number
             	,''x''	Hazard_Class
             	,''x''	RFQ_Required
             	,  0	List_price
             	,  0	Price_tolerance_percent
             	,''x''		C_acat_flex
             	,''x''		Outside_Operation
             	,''x''	Outside_Operation_Unit_Type
             	,  0		Rounding_Factor
             	,''x''		Unit_of_Issue
             	,''x''	Expense_Account
             	,''x''	Encumbrance_Account
             	,''x''			Default_Buyer
             	,''x''		Purchasable
             	,''x''		Purchasing_tax_code
                    ');
    END IF;
    RETURN NULL;
  END C_PO_SELFORMULA;

  FUNCTION C_PO_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_PO_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (' fa_categories_b	PACF
             	,gl_code_combinations PXAF,gl_code_combinations PEAF,');
    ELSE
      RETURN ('/* Do not select Purchasing Options */');
    END IF;
    RETURN NULL;
  END C_PO_FROMFORMULA;

  FUNCTION C_PO_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_PO_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN ('and msi.ASSET_CATEGORY_ID = PACF.CATEGORY_ID(+)
             	and msi.EXPENSE_ACCOUNT = PEAF.code_combination_id(+)
             	and msi.ENCUMBRANCE_ACCOUNT = PXAF.code_combination_id(+)');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_PO_WHEREFORMULA;

  FUNCTION C_RCV_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_RCV_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (',INV_MEANING_SEL.c_po_lookup(msi.QTY_RCV_EXCEPTION_CODE,''RECEIVING CONTROL LEVEL'')  Over_tolerance_exception
             	,RRH.ROUTING_NAME		Receiving_Routing
             	,MSI.QTY_RCV_TOLERANCE		Quantity_Received_Tolerance
             	,MSI.ENFORCE_SHIP_TO_LOCATION_CODE Enforce_Ship_To_Location
             	,decode(msi.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Allow_Substitute_Receipts
             	,decode(msi.ALLOW_UNORDERED_RECEIPTS_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Allow_Unordered_Receipts
             	,decode(msi.ALLOW_EXPRESS_DELIVERY_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)	Allow_Express_Delivery
             	,MSI.DAYS_EARLY_RECEIPT_ALLOWED	Days_Early_Receipt_Allowed
             	,MSI.DAYS_LATE_RECEIPT_ALLOWED	Days_Late_Receipt_Allowed
             	,INV_MEANING_SEL.c_po_lookup(msi.RECEIPT_DAYS_EXCEPTION_CODE,''RECEIVING CONTROL LEVEL'')  Receipt_Date_Exception
             	 ');
    ELSE
      RETURN (',''x''		Over_tolerance_exception
             	,''x''	Receiving_Routing
             	,  0		Quantity_Received_Tolerance
             	,''x'' Enforce_Ship_To_Location
             	,''x''		Allow_Substitute_Receipts
             	,''x''		Allow_Unordered_Receipts
             	,''x''		Allow_Express_Delivery
             	,  0	Days_Early_Receipt_Allowed
             	,  0	Days_Late_Receipt_Allowed
             	,''x''			Receipt_Date_Exception');
    END IF;
    RETURN NULL;
  END C_RCV_SELFORMULA;

  FUNCTION C_RCV_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_RCV_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (' rcv_routing_headers RRH, ');
    ELSE
      RETURN ('/* Do not select Receiving Group Options*/');
    END IF;
    RETURN NULL;
  END C_RCV_FROMFORMULA;

  FUNCTION C_RCV_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_RCV_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN ('and MSI.RECEIVING_ROUTING_ID = RRH.ROUTING_HEADER_ID(+) ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_RCV_WHEREFORMULA;

  FUNCTION C_PHYS_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_PHYS_INFO = 1 THEN
      RETURN (',MSI.UNIT_VOLUME	 Unit_Volume
             	,MSI.UNIT_WEIGHT	 Unit_Weight
                     ,decode(msi.container_item_flag,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)        Container_item_flag
                     ,decode(msi.vehicle_item_flag,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)       Vehicle_Item_Flag
                     ,MSI.Maximum_Load_Weight Maximum_Load_Weight
                     ,MSI.Minimum_Fill_Percent Minimum_Fill_Percent
                     ,MSI.Internal_Volume   Internal_Volume
              	,INV_MEANING_SEL.C_FNDCOMMON(' || 'msi.Container_Type_CODE' || ',''CONTAINER_TYPE'') 	Container_Type_Code
             	,INV_MEANING_SEL.c_unit_measure(msi.volume_uom_code) Volume_Unit_of_Measure
             	,INV_MEANING_SEL.c_unit_measure(msi.weight_uom_code) Weight_Unit_of_Measure
             	,INV_MEANING_SEL.C_UNITMEASURE(msi.DIMENSION_UOM_CODE)	DIMENSION_UOM_CODE
              	,msi.UNIT_LENGTH	UNIT_LENGTH
             	,msi.UNIT_WIDTH		UNIT_WIDTH
             	,msi.UNIT_HEIGHT	UNIT_HEIGHT
             	,decode(msi.COLLATERAL_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  COLLATERAL_FLAG
             	,decode(msi.ELECTRONIC_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  ELECTRONIC_FLAG
             	,decode(msi.EVENT_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  EVENT_FLAG
             	,decode(msi.DOWNLOADABLE_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  DOWNLOADABLE_FLAG
             	,decode(msi.EQUIPMENT_TYPE,1,' || '''' || P_YES_VALUE || '''' || ',2,' || '''' || P_NO_VALUE || '''' || ',NULL)	EQUIPMENT_TYPE
             	,decode(msi.INDIVISIBLE_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  INDIVISIBLE_FLAG ');
    ELSE
      RETURN (', 0	Unit_Volume
             	, 0	Unit_Weight
                     ,''x''  Container_item_flag
                     ,''x''  Vehicle_item_flag
                     , 0     Maximum_load_weight
                     , 0     Minimum_Fill_Percent
                     , 0     Internal_volume
                     ,''x''   container_type_code
             	,''x''	Volume_Unit_of_Measure
             	,''x''	Weight_Unit_of_Measure,
             	''x''	DIMENSION_UOM_CODE,
             	0	UNIT_LENGTH,
             	0	UNIT_WIDTH,
             	0	UNIT_HEIGHT,
             	''x''	COLLATERAL_FLAG,
             	''x''	ELECTRONIC_FLAG,
             	''x''	EVENT_FLAG,
             	''x''	DOWNLOADABLE_FLAG,
             	''x''	EQUIPMENT_TYPE,
             	''x''	INDIVISIBLE_FLAG');
    END IF;
    RETURN NULL;
  END C_PHYS_SELFORMULA;

  FUNCTION C_GP_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_GP_INFO = 1 THEN
      RETURN (',INV_MEANING_SEL.c_mfg_lookup(' || 'msi.INVENTORY_PLANNING_CODE' || ',''MTL_MATERIAL_PLANNING'')	 Inventory_Planning_Method
             	,MSI.MAX_MINMAX_QUANTITY	 Minmax_Maximum_quantity
             	,MSI.MIN_MINMAX_QUANTITY	 Minmax_Minimum_quantity
             	,MSI.SAFETY_STOCK_BUCKET_DAYS	 Safety_Stock_Bucket_Days
             	,MSI.CARRYING_COST		 Carrying_cost_percent
             	,MSI.ORDER_COST			 Order_Cost
             	,MSI.MRP_SAFETY_STOCK_PERCENT	 Safety_Stock_Percent
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.MRP_SAFETY_STOCK_CODE' || ',''MTL_SAFETY_STOCK_TYPE'')	 Safety_Stock
             	,MSI.FIXED_ORDER_QUANTITY	 Fixed_order_quantity
             	,MSI.FIXED_DAYS_SUPPLY		 Fixed_days_supply

             	,MSI.MINIMUM_ORDER_QUANTITY	 Minimum_order_quantity
             	,MSI.MAXIMUM_ORDER_QUANTITY	 Maximum_order_quantity
             	,MSI.FIXED_LOT_MULTIPLIER	 Fixed_lot_size_multiplier
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.SOURCE_TYPE' || ',''MTL_SOURCE_TYPES'')	Replenishment_Source_Type
                     ,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.PLANNING_MAKE_BUY_CODE' || ',''MTL_PLANNING_MAKE_BUY'')  Make_or_Buy
             	,MSI.planner_code		 Planner
             	,INV_MEANING_SEL.c_org_name(msi.SOURCE_ORGANIZATION_ID)  Source_Organization
             	,MSI.SOURCE_SUBINVENTORY	 Source_Subinventory
                     ,msi.SUBCONTRACTING_COMPONENT Subcontracting_Component ');
    ELSE
      RETURN (',''x''		Inventory_Planning_Method
             	, 0	Minmax_Maximum_quantity
             	, 0	Minmax_Minimum_quantity
             	, 0	Safety_Stock_Bucket_Days
             	, 0		Carrying_cost_percent
             	, 0			Order_Cost
             	, 0	Safety_Stock_Percent
             	,''x''		Safety_Stock
             	, 0	Fixed_order_quantity
             	, 0		Fixed_days_supply

             	, 0	Minimum_order_quantity
             	, 0	Maximum_order_quantity
             	, 0	Fixed_lot_size_multiplier
             	,''x''		Replenishment_Source_Type
                     ,''x''          Make_or_Buy
             	,''x''		Planner
             	,''x''	 Source_Organization
             	,''x''	 Source_Subinventory
                     , 0  Subcontracting_Component ');
    END IF;
    RETURN NULL;
  END C_GP_SELFORMULA;

  FUNCTION C_GP_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_GP_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN ('/* Do not select General Planning Group Option */');
    END IF;
    RETURN NULL;
  END C_GP_FROMFORMULA;

  FUNCTION C_GP_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_GP_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_GP_WHEREFORMULA;

  FUNCTION C_MPS_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_MPS_INFO = 1 THEN
      RETURN (',INV_MEANING_SEL.c_fnd_lookup_vl(msi.END_ASSEMBLY_PEGGING_FLAG,''ASSEMBLY_PEGGING_CODE'')  End_Assembly_Pegging
                     ,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.RELEASE_TIME_FENCE_CODE' || ',''MTL_RELEASE_TIME_FENCE'')  release_time_fence
                     ,MSI.Release_time_fence_days Release_Time_Fence_Days
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.ROUNDING_CONTROL_TYPE' || ',''MTL_ROUNDING'')  Rounding_control
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.AUTO_REDUCE_MPS' || ',''MRP_AUTO_REDUCE_MPS'')   Reduce_MPS
             	,MSI.SHRINKAGE_RATE		 Shrinkage_Rate
             	,MSI.ACCEPTABLE_EARLY_DAYS	 Acceptable_Early_Days
             	,decode(msi.MRP_CALCULATE_ATP_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)    Calculate_ATP
             	,MSI.OVERRUN_PERCENTAGE		 Overrun_Percentage
             	,MSI.ACCEPTABLE_RATE_DECREASE	 Acceptable_Rate_Decrease
             	,MSI.ACCEPTABLE_RATE_INCREASE	 Acceptable_Rate_Increase
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.PLANNING_TIME_FENCE_CODE' || ',''MTL_TIME_FENCE'')  Planning_Time_Fence
             	,MSI.PLANNING_TIME_FENCE_DAYS	 Planning_Time_Fence_Days
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.DEMAND_TIME_FENCE_CODE' || ',''MTL_TIME_FENCE'')   Demand_Time_Fence
             	,MSI.DEMAND_TIME_FENCE_DAYS	 Demand_Time_Fence_Days
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.MRP_PLANNING_CODE' || ',''MRP_PLANNING_CODE'')  MRP_Planning_Method
             	,MSI.PLANNING_EXCEPTION_SET	 Planning_Exception_Set
                     ,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.ato_forecast_control' || ',''MRP_ATO_FORECAST_CONTROL'')  MRP_Forecast_Control
             	,decode(msi.REPETITIVE_PLANNING_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	 Repetitive_Planning
             	,decode(msi.PLANNED_INV_POINT_FLAG,''Y'',''Yes'',''N'',''No'',NULL) 	 PLANNED_INV_POINT_FLAG
             	,INV_MEANING_SEL.c_mfg_lookup(msi.SUBSTITUTION_WINDOW_CODE,''MTL_TIME_FENCE'') SUBSTITUTION_WINDOW_CODE
             	,msi.SUBSTITUTION_WINDOW_DAYS SUBSTITUTION_WINDOW_DAYS
             	,decode(msi.CREATE_SUPPLY_FLAG,''Y'',''Yes'',''N'',''No'',NULL)  CREATE_SUPPLY_FLAG
                     ,msi.REPAIR_LEADTIME Repair_Lead_time
                     ,msi.REPAIR_YIELD Repair_Yield
                   	,decode(msi.PREPOSITION_POINT ,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  Pre_position_Point
                     ,msi.REPAIR_PROGRAM    Repair_Program  ');
    ELSE
      RETURN (',''z''		 End_Assembly_Pegging
                     ,  0             Release_Time_Fence
                     ,  0             Release_Time_Fence_Days
             	,''x''		 Rounding_control
             	,''x''		 Reduce_MPS
             	,  0		   Shrinkage_Rate
             	,  0		   Acceptable_Early_Days
             	,''x''		 Calculate_ATP
             	,  0		   Overrun_Percentage
             	,  0		   Acceptable_Rate_Decrease
             	,  0		   Acceptable_Rate_Increase
             	,''x''		 Planning_Time_Fence
             	,  0		   Planning_Time_Fence_Days
             	,''x''		 Demand_Time_Fence
             	,  0		   Demand_Time_Fence_Days
             	,''x''		 MRP_Planning_Method
             	,''x''		 Planning_Exception_Set
             	,''x''     MRP_Forecast_Control
             	,''x''		 Repetitive_Planning
             	,''x''		 PLANNED_INV_POINT_FLAG
             	,''0''     SUBSTITUTION_WINDOW_CODE
             	,  0		   SUBSTITUTION_WINDOW_DAYS
             	,''x''		 CREATE_SUPPLY_FLAG
                     , 0    Repair_Lead_time
                     , 0    Repair_Yield
                     ,''x'' Pre_position_Point
                     , 0    Repair_Program  ');
    END IF;
    RETURN NULL;
  END C_MPS_SELFORMULA;

  FUNCTION C_MPS_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_MPS_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_MPS_WHEREFORMULA;

  FUNCTION C_MPS_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_MPS_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN ('/*Do not select MPS/MRP Planning Group Options */');
    END IF;
    RETURN NULL;
  END C_MPS_FROMFORMULA;

  FUNCTION C_LEAD_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (',msi.CUMULATIVE_TOTAL_LEAD_TIME		 Cumulative_Total_Lead_Time
           	,msi.CUM_MANUFACTURING_LEAD_TIME	 Cum_Manufacturing_Lead_Time
           	,msi.FIXED_LEAD_TIME			 Fixed_Lead_Time
           	,msi.FULL_LEAD_TIME			 Processing_Lead_Time
           	,msi.LEAD_TIME_LOT_SIZE			 Lead_Time_Lot_Size
           	,msi.POSTPROCESSING_LEAD_TIME		 Postprocessing_lead_time
           	,msi.PREPROCESSING_LEAD_TIME		 Preprocessing_lead_time
           	,msi.VARIABLE_LEAD_TIME			 Variable_Lead_Time ');
  END C_LEAD_SELFORMULA;

  FUNCTION C_WIP_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_WIP_INFO = 1 THEN
      RETURN (',decode(msi.BUILD_IN_WIP_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	 Build_in_WIP
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.WIP_SUPPLY_TYPE' || ',''WIP_SUPPLY'')  WIP_Supply_Type
             	,' || P_WIP_LOC_FLEX || '	 WIP_Supply_Locator
             	,MSI.WIP_SUPPLY_SUBINVENTORY  WIP_Supply_Subinventory
             	,msi.INVENTORY_CARRY_PENALTY	INVENTORY_CARRY_PENALTY
             	,msi.OPERATION_SLACK_PENALTY	OPERATION_SLACK_PENALTY
             	,decode(msi.OVERCOMPLETION_TOLERANCE_TYPE,1,''Percent'',2,''Amount'',NULL)	OVERCOMPLETION_TOLERANCE_TYPE
             	,msi.OVERCOMPLETION_TOLERANCE_VALUE	OVERCOMPLETION_TOLERANCE_VALUE');
    ELSE
      RETURN (',''x''	 Build_in_WIP
             	,''x''	 WIP_Supply_Type
             	,''x''	 WIP_Supply_Locator
             	,''x''	WIP_Supply_Subinventory
             	,0	INVENTORY_CARRY_PENALTY
             	,0	OPERATION_SLACK_PENALTY
             	,''x''	OVERCOMPLETION_TOLERANCE_TYPE
             	,0	OVERCOMPLETION_TOLERANCE_VALUE');
    END IF;
    RETURN NULL;
  END C_WIP_SELFORMULA;

  FUNCTION C_WIP_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_WIP_INFO = 1 THEN
      RETURN ('mtl_item_locations	 LOC, ');
    ELSE
      RETURN ('/* Do not select WIP Group Options */');
    END IF;
    RETURN NULL;
  END C_WIP_FROMFORMULA;

  FUNCTION C_WIP_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_WIP_INFO = 1 THEN
      RETURN ('and msi.WIP_SUPPLY_LOCATOR_ID =
             	    LOC.INVENTORY_LOCATION_ID(+)
             	and LOC.ORGANIZATION_ID(+) = ' || TO_CHAR(P_ORG_ID));
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_WIP_WHEREFORMULA;

  FUNCTION C_OE_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_OE_INFO = 1 THEN
      RETURN (',decode(msi.CUSTOMER_ORDER_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  Customer_Ordered_Item
             	,decode(msi.CUSTOMER_ORDER_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)      Customer_Orders_Enabled
             	,decode(msi.INTERNAL_ORDER_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)	  Internal_Ordered_Item
             	, decode( msi.INTERNAL_ORDER_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Internal_Orders_Enabled
             	,decode( msi.SHIPPABLE_ITEM_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)	  Shippable_Item
             	, decode( msi.SO_TRANSACTIONS_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  OE_transactable
             	,INV_MEANING_SEL.c_org_name(msi.DEFAULT_SHIPPING_ORG)  Default_Shipping_Organization
             	,INV_MEANING_SEL.C_PICK_RULES(msi.PICKING_RULE_ID)  Picking_Rule
             	,decode( msi.PICK_COMPONENTS_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Pick_Components
             	,decode( msi.SHIP_MODEL_COMPLETE_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Ship_Model_Complete
             	, decode( msi.REPLENISH_TO_ORDER_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)	  Assemble_to_Order
             --	, decode( msi.ATP_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Check_ATP
                     ,INV_MEANING_SEL.C_FND_LOOKUP(msi.ATP_FLAG,''ATP_FLAG'') CHECK_ATP
             	,INV_MEANING_SEL.C_ATP_RULES( msi.ATP_RULE_ID)  ATP_Rule
             	,INV_MEANING_SEL.C_FND_LOOKUP(msi.ATP_COMPONENTS_FLAG, ''ATP_FLAG'')  ATP_Components
             	, decode( nvl(msi.RETURNABLE_FLAG,''Y''),''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  Returnable
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.RETURN_INSPECTION_REQUIREMENT' || ',''MTL_RETURN_INSPECTION'')  RMA_Inspection_Status
             	,msi.OVER_SHIPMENT_TOLERANCE	OVER_SHIPMENT_TOLERANCE
             	,msi.UNDER_SHIPMENT_TOLERANCE	UNDER_SHIPMENT_TOLERANCE
             	,msi.OVER_RETURN_TOLERANCE	OVER_RETURN_TOLERANCE
             	,msi.UNDER_RETURN_TOLERANCE	UNDER_RETURN_TOLERANCE
             	,INV_MEANING_SEL.C_OE_LOOKUP(msi.DEFAULT_SO_SOURCE_TYPE,''SOURCE_TYPE'') DEFAULT_SO_SOURCE_TYPE
                     ,msi.CHARGE_PERIODICITY_code Charge_Periodicity ');
    ELSE
      RETURN (',''x''	  Customer_Ordered_Item
             	,''x''	  Customer_Orders_Enabled
             	,''x''	  Internal_Ordered_Item
             	,''x''	  Internal_Orders_Enabled
             	,''x''	  Shippable_Item
             	,''x''	  OE_transactable
             	,''x''	  Default_Shipping_Organization
             	,''x''	  Picking_Rule
             	,''x''	  Pick_Components
             	,''x''	  Ship_Model_Complete
             	,''x''	  Assemble_to_Order
             	,''x''	  Check_ATP
             	,''x''	  ATP_Rule
             	,''x''	  ATP_Components
             	,''x''	  Returnable
             	,''x''	  RMA_Inspection_Status
             	,0	  OVER_SHIPMENT_TOLERANCE
             	,0	  UNDER_SHIPMENT_TOLERANCE
             	,0    OVER_RETURN_TOLERANCE
              	,0	  UNDER_RETURN_TOLERANCE
                     ,''x''	DEFAULT_SO_SOURCE_TYPE
                     ,  0  Charge_Periodicity ');
    END IF;
    RETURN NULL;
  END C_OE_SELFORMULA;

  FUNCTION C_OE_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_OE_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN ('/* Do not select OE Group Option */');
    END IF;
    RETURN NULL;
  END C_OE_FROMFORMULA;

  FUNCTION C_OE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_OE_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_OE_WHEREFORMULA;

  FUNCTION C_INVC_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_INVC_INFO = 1 THEN
      RETURN (',decode(msi.INVOICEABLE_ITEM_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  Invoiceable_Item
             	,decode(msi.INVOICE_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Invoice_enabled
             	,MSI.tax_code		 Tax_Code
             	,' || P_INVC_ACCT_FLEX || ' Sales_Account
             	,INV_MEANING_SEL.c_ra_terms(msi.PAYMENT_TERMS_ID)    Payment_terms
             	,INV_MEANING_SEL.c_ra_rules(msi.ACCOUNTING_RULE_ID)  Accounting_Rule
             	,INV_MEANING_SEL.c_ra_rules(msi.INVOICING_RULE_ID)  Invoicing_Rule ');
    ELSE
      RETURN (',''x''	 Invoiceable_Item
             	,''x''	 Invoice_enabled
             	,''x''		 Tax_Code
             	,''x'' Sales_Account
             	,''x''		 Payment_terms
             	,''x''		 Accounting_Rule
             	,''x''		 Invoicing_Rule ');
    END IF;
    RETURN NULL;
  END C_INVC_SELFORMULA;

  FUNCTION C_INVC_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_INVC_INFO = 1 THEN
      RETURN (' gl_code_combinations IAF, ');
    ELSE
      RETURN ('/* Do not select Invoice Group Options */');
    END IF;
    RETURN NULL;
  END C_INVC_FROMFORMULA;

  FUNCTION C_INVC_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_INVC_INFO = 1 THEN
      RETURN ('and msi.SALES_ACCOUNT = IAF.code_combination_id(+) ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_INVC_WHEREFORMULA;

  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      NAME VARCHAR2(30);
      SET_ID NUMBER;
    BEGIN
      IF P_CAT_SET_ID IS NULL THEN
        RETURN ('');
      ELSE
        SET_ID := P_CAT_SET_ID;
        SELECT
          CATEGORY_SET_NAME
        INTO NAME
        FROM
          MTL_CATEGORY_SETS_VL
        WHERE CATEGORY_SET_ID = SET_ID;
        RETURN (NAME);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('');
    END;
    RETURN NULL;
  END C_CAT_SET_NAMEFORMULA;

  FUNCTION C_ITEM_PADFORMULA(C_ITEM_FIELD IN VARCHAR2
                            ,C_ITEM_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_ITEM_FIELD)*/NULL;
    RETURN (C_ITEM_PAD);
  END C_ITEM_PADFORMULA;

  FUNCTION C_PHYS_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_PHYS_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN ('/* Do not select OE Group Option */');
    END IF;
    RETURN NULL;
  END C_PHYS_FROMFORMULA;

  FUNCTION C_PHYS_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_PHYS_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_PHYS_WHEREFORMULA;

  FUNCTION C_CAT_PAD2FORMULA(C_CAT_FIELD2 IN VARCHAR2
                            ,C_CAT_PAD2 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_CAT_FIELD2)*/NULL;
    RETURN (C_CAT_PAD2);
  END C_CAT_PAD2FORMULA;

  FUNCTION C_SERVICE_INFO_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SERVICE_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (',INV_MEANING_SEL.C_COVERAGE_SCHEDULE(MSI.COVERAGE_SCHEDULE_ID)    Coverage_schedule_id
             	,MSI.vendor_warranty_flag           vendor_warranty_flag
             	,MSI.service_starting_delay         service_starting_delay
                     ,MSI.service_duration_period_code   service_duration_period_code
                     ,MSI.service_duration               service_duration
                     ,MSI.material_billable_flag         Material_billable_flag
                     ,MSI.service_item_flag              service_item_flag
                     ,decode(msi.serviceable_product_flag,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)   serviceable_product_flag
                     ,decode(msi.Asset_Creation_Code ,''1'',' || '''' || P_YES_VALUE || '''' || ',''0'',' || '''' || P_NO_VALUE || '''' || ',NULL)	Asset_Creation_Code
                     ,decode(msi.COMMS_NL_TRACKABLE_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	COMMS_NL_TRACKABLE_FLAG
                     ,decode(msi.serv_billing_enabled_flag,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	SERV_BILLING_ENABLED_FLAG
                     ,msi.serv_importance_level serv_importance_level
                     ,decode(msi.serv_req_enabled_code,''E'',''Enabled'',''D'',''Disabled'',''I'',''Inactive'',NULL) serv_req_enabled_code
                     ,INV_MEANING_SEL.c_fnd_lookup_vl(' || 'msi.IB_ITEM_INSTANCE_CLASS' || ',''CSI_ITEM_CLASS'')  Ib_Item_Instance_Class
                     ,decode(msi.COMMS_ACTIVATION_REQD_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',' || '''' || P_NO_VALUE || '''' || ') COMMS_ACTIVATION_REQD_FLAG
                     ,INV_MEANING_SEL.c_fnd_lookup_vl(' || 'msi.CONTRACT_ITEM_TYPE_CODE' || ',''OKB_CONTRACT_ITEM_TYPE'')  CONTRACT_ITEM_TYPE_CODE
                     ,INV_MEANING_SEL.c_fnd_lookup_vl(' || 'msi.RECOVERED_PART_DISP_CODE' || ',''CSP_RECOVERED_PART_DISP_CODE'')  RECOVERED_PART_DISP_CODE
                     ,decode(msi.DEFECT_TRACKING_ON_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',' || '''' || P_NO_VALUE || '''' || ') DEFECT_TRACKING_ON_FLAG');
    ELSE
      RETURN (' ,''x''     Coverage_Schedule_id,
             	''x'' 	Vendor_Warranty_Flag,
                   	  0	Service_Starting_Delay,
             	''x''	Service_Duration_Period_Code,
                       0     Service_Duration,
                 	''x''   Material_billable_flag,
                 	''x''   Service_Item_Flag,
                 	''x''   Serviceable_Product_Flag,
             	''x''	Asset_Creation_Code,
             	''x''	COMMS_NL_TRACKABLE_FLAG,
             	''x''	serv_billing_enabled_flag,
             	  0	serv_importance_level,
             	''x''	serv_req_enabled_code ,
             	''x''	Ib_Item_Instance_class ,
                     ''x''   COMMS_ACTIVATION_REQD_FLAG,
                     ''x''   CONTRACT_ITEM_TYPE_CODE,
                     ''x''   RECOVERED_PART_DISP_CODE,
                     ''x''   DEFECT_TRACKING_ON_FLAG ');
    END IF;
    RETURN NULL;
  END C_SERVICE_INFO_SELFORMULA;

  FUNCTION C_SERVICE_INFO_FROMFORMULA RETURN NUMBER IS
  BEGIN
    IF P_SERVICE_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (NULL);
    ELSE
      RETURN (NULL);
    END IF;
    RETURN NULL;
  END C_SERVICE_INFO_FROMFORMULA;

  FUNCTION C_SERVICE_INFO_WHEREFORMULA RETURN NUMBER IS
  BEGIN
    IF P_SERVICE_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (NULL);
    ELSE
      RETURN (NULL);
    END IF;
    RETURN NULL;
  END C_SERVICE_INFO_WHEREFORMULA;

  FUNCTION RESOLVE_VENDOR_WARRANTY(VENDOR_WARRANTY_FLAG IN VARCHAR2) RETURN VARCHAR2 IS
    TEMP VARCHAR2(80);
  BEGIN
    IF VENDOR_WARRANTY_FLAG = 'Y' THEN
      SELECT
        FLU.MEANING
      INTO TEMP
      FROM
        FND_LOOKUPS FLU
      WHERE LOOKUP_TYPE = 'YES_NO'
        AND LOOKUP_CODE = 'Y';
      RETURN (TEMP);
    ELSIF VENDOR_WARRANTY_FLAG = 'N' THEN
      SELECT
        FLU.MEANING
      INTO TEMP
      FROM
        FND_LOOKUPS FLU
      WHERE LOOKUP_TYPE = 'YES_NO'
        AND LOOKUP_CODE = 'N';
      RETURN (TEMP);
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END RESOLVE_VENDOR_WARRANTY;

  FUNCTION RESOLVE_SERVICE_ITEM_FLAG(SERVICE_ITEM_FLAG IN VARCHAR2) RETURN VARCHAR2 IS
    TEMP VARCHAR2(80);
  BEGIN
    IF SERVICE_ITEM_FLAG = 'Y' THEN
      SELECT
        FLU.MEANING
      INTO TEMP
      FROM
        FND_LOOKUPS FLU
      WHERE LOOKUP_TYPE = 'YES_NO'
        AND LOOKUP_CODE = 'Y';
      RETURN (TEMP);
    ELSIF SERVICE_ITEM_FLAG = 'N' THEN
      SELECT
        FLU.MEANING
      INTO TEMP
      FROM
        FND_LOOKUPS FLU
      WHERE LOOKUP_TYPE = 'YES_NO'
        AND LOOKUP_CODE = 'N';
      RETURN (TEMP);
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END RESOLVE_SERVICE_ITEM_FLAG;

  FUNCTION RESOLVE_SERVICEABLE_PRODUCT(SERVICEABLE_PRODUCT_FLAG IN VARCHAR2) RETURN VARCHAR2 IS
    TEMP VARCHAR2(80);
  BEGIN
    IF SERVICEABLE_PRODUCT_FLAG = 'Y' THEN
      SELECT
        FLU.MEANING
      INTO TEMP
      FROM
        FND_LOOKUPS FLU
      WHERE LOOKUP_TYPE = 'YES_NO'
        AND LOOKUP_CODE = 'Y';
      RETURN (TEMP);
    ELSIF SERVICEABLE_PRODUCT_FLAG = 'N' THEN
      SELECT
        FLU.MEANING
      INTO TEMP
      FROM
        FND_LOOKUPS FLU
      WHERE LOOKUP_TYPE = 'YES_NO'
        AND LOOKUP_CODE = 'N';
      RETURN (TEMP);
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END RESOLVE_SERVICEABLE_PRODUCT;

  FUNCTION RESOLVE_MATERIAL_BILLABLE(MATERIAL_BILLABLE_FLAG IN VARCHAR2) RETURN VARCHAR2 IS
    TEMP VARCHAR2(80);
  BEGIN
    IF MATERIAL_BILLABLE_FLAG = 'E' THEN
      SELECT
        CLU.MEANING
      INTO TEMP
      FROM
        CS_LOOKUPS CLU
      WHERE LOOKUP_TYPE = 'MTL_SERVICE_BILLABLE_FLAG'
        AND LOOKUP_CODE = 'E';
      RETURN (TEMP);
    ELSIF MATERIAL_BILLABLE_FLAG = 'L' THEN
      SELECT
        CLU.MEANING
      INTO TEMP
      FROM
        CS_LOOKUPS CLU
      WHERE LOOKUP_TYPE = 'MTL_SERVICE_BILLABLE_FLAG'
        AND LOOKUP_CODE = 'L';
      RETURN (TEMP);
    ELSIF MATERIAL_BILLABLE_FLAG = 'M' THEN
      SELECT
        CLU.MEANING
      INTO TEMP
      FROM
        CS_LOOKUPS CLU
      WHERE LOOKUP_TYPE = 'MTL_SERVICE_BILLABLE_FLAG'
        AND LOOKUP_CODE = 'M';
      RETURN (TEMP);
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END RESOLVE_MATERIAL_BILLABLE;

  FUNCTION C_WEB_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_WEB_INFO = 1 THEN
      RETURN (',MSI.WEB_STATUS  Web_Status
             	,decode(msi.BACK_ORDERABLE_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	 Back_Orderable
             	,decode(msi.ORDERABLE_ON_WEB_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  Web_Orderable
             	,msi.Minimum_License_Quantity Minimum_License_Quantity ');
    END IF;
    RETURN (',msi.web_status web_status ,msi.segment2 Back_Orderable,msi.segment2 Web_Orderable, msi.segment2 Minimum_License_quantity');
  END C_WEB_SELFORMULA;

  FUNCTION C_EAM_FROMFORMULA RETURN CHAR IS
  BEGIN
    IF P_EAM_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN ('/* Do not select Asset Group Options */');
    END IF;
    RETURN NULL;
  END C_EAM_FROMFORMULA;

  FUNCTION C_EAM_SELFORMULA RETURN CHAR IS
  BEGIN
    IF P_EAM_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (',INV_MEANING_SEL.c_mfg_lookup(' || 'msi.EAM_ITEM_TYPE' || ',''MTL_EAM_ITEM_TYPE'')  Eam_Item_Type
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.EAM_ACTIVITY_TYPE_CODE' || ',''MTL_EAM_ACTIVITY_TYPE'') Eam_Activity_Type_Code
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.EAM_ACTIVITY_CAUSE_CODE' || ',''MTL_EAM_ACTIVITY_CAUSE'')  Eam_Activity_Cause_Code
             	,decode(msi.EAM_ACT_NOTIFICATION_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	 Eam_Act_Notification_Flag
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.EAM_ACT_SHUTDOWN_STATUS' || ',''BOM_EAM_SHUTDOWN_TYPE'')  Eam_Act_Shutdown_Status
             	,INV_MEANING_SEL.c_fnd_lookup_vl(' || 'msi.EAM_ACTIVITY_SOURCE_CODE' || ',''MTL_EAM_ACTIVITY_SOURCE'') Eam_Activity_Source_Code
             	');
    ELSE
      RETURN (', ''x''		 Eam_Item_Type
             	, ''x''		 Eam_Activity_Type_Code
             	, ''x''  	 Eam_Activity_Cause_Code
             	, ''x''          Eam_Act_Notification_Flag
             	, ''x''		 Eam_Act_Shutdown_Status
             	, ''x''	 	 Eam_Activity_Source_Code');
    END IF;
    RETURN NULL;
  END C_EAM_SELFORMULA;

  FUNCTION C_EAM_WHEREFORMULA RETURN CHAR IS
  BEGIN
    IF P_EAM_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_EAM_WHEREFORMULA;

  FUNCTION C_OPM_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_OPM_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN ('/* Do not select OE Group Option */');
    END IF;
  END C_OPM_FROMFORMULA;

  FUNCTION C_OPM_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_OPM_INFO = 1 THEN
      RETURN ('
             ,decode(msi.PROCESS_QUALITY_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  Quality_Enabled
             ,decode(msi.PROCESS_COSTING_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Process_Costing_Enabled
             ,decode(msi.RECIPE_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  Recipe_Enabled
             ,decode(msi.HAZARDOUS_MATERIAL_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Hazardious_Material
             ,msi.CAS_NUMBER CAS_Number
             ,decode(msi.PROCESS_EXECUTION_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  Process_Execution_Enabled
             ,msi.PROCESS_SUPPLY_SUBINVENTORY Supply_Subinventory
             ,msi.PROCESS_SUPPLY_LOCATOR_ID Supply_Locator
             ,msi.PROCESS_YIELD_SUBINVENTORY Yield_Subinventory
             ,msi.PROCESS_YIELD_LOCATOR_ID Yield_Locator');
    ELSE
      RETURN (',''x'' Quality_Enabled
             ,''x'' Process_Costing_Enabled
             ,''x'' Recipe_Enabled
             ,''x'' Hazardious_Material
             ,''x'' CAS_Number
             ,''x'' Process_Execution_Enabled
             ,''x'' Supply_Subinventory
             , 0    Supply_Locator
             ,''x'' Yield_Subinventory
             , 0    Yield_Locator     ');
    END IF;
    RETURN NULL;
  END C_OPM_SELFORMULA;

  FUNCTION C_OPM_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ALL_INFO = 1 OR P_OPM_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN (' ');
    END IF;
  END C_OPM_WHEREFORMULA;

  FUNCTION C_INV_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_INV_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_INV_WHEREFORMULA;

  FUNCTION C_INV_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_INV_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (',decode(msi.INVENTORY_ITEM_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	 Inventory_Item
             	,decode(msi.STOCK_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	 Stockable
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.LOT_CONTROL_CODE' || ',''MTL_LOT_CONTROL'')	 Lot_Control
             	,MSI.START_AUTO_LOT_NUMBER	 Starting_Lot_Number
             	,MSI.AUTO_LOT_ALPHA_PREFIX	 Starting_Lot_Prefix
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.SERIAL_NUMBER_CONTROL_CODE' || ',''MTL_SERIAL_NUMBER'')  Serial_Number_Control
             	,MSI.START_AUTO_SERIAL_NUMBER	 Starting_Serial_Number
             	,MSI.AUTO_SERIAL_ALPHA_PREFIX	 Starting_Serial_Prefix
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.SHELF_LIFE_CODE' || ',''MTL_SHELF_LIFE'') Shelf_Life_Control
             	,MSI.SHELF_LIFE_DAYS		 Shelf_Life_Days
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.RESTRICT_SUBINVENTORIES_CODE' || ',''MTL_SUBINVENTORY_RESTRICTIONS'')  Subinventory_Restrictions
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.LOCATION_CONTROL_CODE' || ',''MTL_LOCATION_CONTROL'')  Stock_Locator_Control
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.RESTRICT_LOCATORS_CODE' || ',''MTL_LOCATOR_RESTRICTIONS'') Locator_Restrictions
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.RESERVABLE_TYPE' || ',''MTL_RESERVATION_CONTROL'')  Reservation_Control
             	,decode(msi.CYCLE_COUNT_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	 Cycle_Count_Enabled
             	,MSI.NEGATIVE_MEASUREMENT_ERROR  Neg_Measurement_Error
             	,MSI.POSITIVE_MEASUREMENT_ERROR  Pos_Measurement_Error
             	,decode(msi.MTL_TRANSACTIONS_ENABLED_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	 Transactable
             	,INV_MEANING_SEL.c_mfg_lookup(' || 'msi.REVISION_QTY_CONTROL_CODE' || ',''MTL_ENG_QUANTITY'')  Revision_Control
             	,decode(msi.CHECK_SHORTAGES_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	 Check_Shortages
             	,decode(msi.Lot_Status_Enabled,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) 	 Lot_Status_Enabled
             	,INV_MEANING_SEL.C_LOT_LOOKUP(msi.DEFAULT_LOT_STATUS_ID)	DEFAULT_LOT_STATUS_ID
             	,decode(msi.Serial_Status_Enabled,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Serial_Status_Enabled
             	,INV_MEANING_SEL.C_SERIAL_LOOKUP(msi.DEFAULT_SERIAL_STATUS_ID)	DEFAULT_SERIAL_STATUS_ID
             	,decode(msi.Lot_Split_Enabled,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Lot_Split_Enabled
             	,decode(msi.Lot_Merge_Enabled,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Lot_Merge_Enabled
             	,decode(msi.Bulk_Picked_Flag,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Bulk_Picked
             	,decode(msi.lot_translate_enabled,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) lot_translate_enabled
             	,decode(msi.lot_substitution_enabled,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) lot_substitution_enabled
                     ,msi.MATURITY_DAYS Maturity_Days
                     ,msi.HOLD_DAYS Hold_Days
                     ,msi.RETEST_INTERVAL Retest_Interval
                     ,msi.EXPIRATION_ACTION_CODE     Expiration_Action_Code
                     ,decode(msi.GRADE_CONTROL_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Grade_Control_Flag
                     ,msi.DEFAULT_GRADE Default_Grade
                     ,decode(msi.LOT_DIVISIBLE_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Lot_Divisible_Flag
                     ,decode(msi.CHILD_LOT_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL)  Child_Lot_Flag
                     ,INV_MEANING_SEL.C_LOOKUPS(' || 'msi.PARENT_CHILD_GENERATION_FLAG' || ',''INV_PARENT_CHILD_GENERATION'') Parent_Child_Generation_Flag
                     ,msi.CHILD_LOT_PREFIX Child_Lot_Prefix
                     ,msi.CHILD_LOT_STARTING_NUMBER Child_Lot_Starting_Number
                     ,decode(msi.CHILD_LOT_VALIDATION_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Child_Lot_Validation_Flag
                     ,decode(msi.COPY_LOT_ATTRIBUTE_FLAG,''Y'',' || '''' || P_YES_VALUE || '''' || ',''N'',' || '''' || P_NO_VALUE || '''' || ',NULL) Copy_Lot_Attribute_Flag
                     ,msi.EXPIRATION_ACTION_INTERVAL Expiration_Action_Interval
              ');
    ELSE
      RETURN (',''z''		 Inventory_Item
             	,''x''		 Stockable
             	,''x''		 Lot_Control
             	,''x''  	 Starting_Lot_Number
             	,''x'' 		 Starting_Lot_Prefix
             	,''x''		 Serial_Number_Control
             	,''x''	 	 Starting_Serial_Number
             	,''x''	 	 Starting_Serial_Prefix
             	,''x''		 Shelf_Life_Control
             	,  0		 Shelf_Life_Days
             	,''x''		 Subinventory_Restrictions
             	,''x''		 Stock_Locator_Control
             	,''x''		 Locator_Restrictions
             	,''x''		 Reservation_Control
             	,''x''		 Cycle_Count_Enabled
             	,  0		 Neg_Measurement_Error
             	,  0 		 Pos_Measurement_Error
             	,''x''		 Transactable
             	,''x''		 Revision_Control
             	,''x''		 Check_Shortages
             	,''x''		Lot_Status_Enabled
             	,''x''		DEFAULT_LOT_STATUS_ID
             	,''x''		Serial_Status_Enabled
             	,''x''		DEFAULT_SERIAL_STATUS_ID
             	,''x''		Lot_Split_Enabled
             	,''x''		Lot_Merge_Enabled
             	,''x''		Bulk_Picked
             	,''x''		lot_translate_enabled
             	,''x''		lot_substitution_enabled
                     ,  0       Maturity_Days
             	,  0       Hold_Days
             	,  0       Retest_Interval
             	,''x''     Expiration_Action_Code
             	,''x''     Grade_Control_Flag
             	,''x''     Default_Grade
             	,''x''     Lot_Divisible_Flag
             	,''x''     Child_Lot_Flag
             	,''x''     Parent_Child_Generation_Flag
             	,''x''     Child_Lot_Prefix
             	,  0       Child_Lot_Starting_Number
             	,''x''     Child_Lot_Validation_Flag
             	,''x''     Copy_Lot_Attribute_Flag
                     ,  0       Expiration_Action_Interval

              ');
    END IF;
    RETURN NULL;
  END C_INV_SELFORMULA;

  FUNCTION C_INV_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_INV_INFO = 1 OR P_ALL_INFO = 1 THEN
      RETURN (' ');
    ELSE
      RETURN ('/* Do not select Inventory Group Options */');
    END IF;
    RETURN NULL;
  END C_INV_FROMFORMULA;

 FUNCTION C_INVC_SELECT(C_INVC_ACCT_FIELD VARCHAR2) RETURN VARCHAR2
  IS
 BEGIN
   IF P_BREAK_ID = 1 THEN
     RETURN(C_INVC_ACCT_FIELD);
   ELSE
     RETURN(NULL);
  END IF;
 END C_INVC_SELECT;

 FUNCTION C_WIP_SELECT(C_WIP_LOC_FIELD VARCHAR2) RETURN VARCHAR2
 IS
 BEGIN
   IF (P_ALL_INFO = 1 OR P_WIP_INFO = 1 ) THEN
    RETURN( C_WIP_LOC_FIELD);
   ELSE
    RETURN(NULL);
   END IF;
END C_WIP_SELECT;

FUNCTION C_ENC_SELECT(C_ENC_ACCT_FIELD VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   IF (P_PO_INFO = 1 OR P_ALL_INFO = 1 )  THEN
    RETURN( C_ENC_ACCT_FIELD);
   ELSE
    RETURN(NULL);
   END IF;
END C_ENC_SELECT;

FUNCTION C_EXP_SELECT(C_EXP_ACCT_FIELD VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   IF (P_PO_INFO = 1 OR P_ALL_INFO = 1 )  THEN
    RETURN( C_EXP_ACCT_FIELD);
   ELSE
    RETURN(NULL);
   END IF;
END C_EXP_SELECT;

FUNCTION C_ACAT_SELECT(C_ACAT_FIELD VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   IF (P_PO_INFO = 1 OR P_ALL_INFO = 1 )  THEN
    RETURN( C_ACAT_FIELD);
   ELSE
    RETURN(NULL);
   END IF;
END C_ACAT_SELECT;

FUNCTION C_CST_SELECT(C_CST_ACCT_FIELD VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   IF (P_CST_INFO = 1 OR P_ALL_INFO = 1 ) THEN
    RETURN( C_CST_ACCT_FIELD);
   ELSE
    RETURN(NULL);
   END IF;
END C_CST_SELECT;

END INV_INVIRITD_XMLP_PKG;


/
