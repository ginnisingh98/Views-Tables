--------------------------------------------------------
--  DDL for Package Body INVPVALM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVALM" AS
/* $Header: INVPVM1B.pls 120.1.12010000.2 2009/06/08 03:15:02 maychen ship $ */

FUNCTION validate_item_org1
(
org_id		NUMBER,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text      IN OUT  NOCOPY VARCHAR2,
xset_id       IN      NUMBER    DEFAULT -999
)
RETURN INTEGER
IS

   -- Cursor to retrieve item child org records

   CURSOR cc
   IS
      SELECT
	 msii.TRANSACTION_ID,
	 msii.INVENTORY_ITEM_ID      III,
	 msii.ORGANIZATION_ID        ORGID,
	 mp.MASTER_ORGANIZATION_ID   MORGID,
	 msii.DESCRIPTION,
	 msii.LONG_DESCRIPTION,
	 msii.BUYER_ID,
	 msii.ACCOUNTING_RULE_ID,
	 msii.INVOICING_RULE_ID,
	 msii.PURCHASING_ITEM_FLAG,
	 msii.SHIPPABLE_ITEM_FLAG,
	 msii.CUSTOMER_ORDER_FLAG,
	 msii.INTERNAL_ORDER_FLAG,
	 msii.INVENTORY_ITEM_FLAG,
	 msii.PURCHASING_ENABLED_FLAG,
	 msii.CUSTOMER_ORDER_ENABLED_FLAG,
	 msii.INTERNAL_ORDER_ENABLED_FLAG,
	 msii.SO_TRANSACTIONS_FLAG,
	 msii.MTL_TRANSACTIONS_ENABLED_FLAG,
	 msii.STOCK_ENABLED_FLAG,
	 msii.BOM_ENABLED_FLAG,
	 msii.BUILD_IN_WIP_FLAG,
	 msii.REVISION_QTY_CONTROL_CODE,
	 msii.ITEM_CATALOG_GROUP_ID,
	 msii.CATALOG_STATUS_FLAG,
	 msii.RETURNABLE_FLAG,
	 msii.DEFAULT_SHIPPING_ORG,
	 msii.COLLATERAL_FLAG,
	 msii.TAXABLE_FLAG,
	 msii.PURCHASING_TAX_CODE,
	 msii.QTY_RCV_EXCEPTION_CODE,
	 msii.ALLOW_ITEM_DESC_UPDATE_FLAG,
	 msii.INSPECTION_REQUIRED_FLAG,
	 msii.RECEIPT_REQUIRED_FLAG,
	 msii.MARKET_PRICE,
	 msii.HAZARD_CLASS_ID,
	 msii.RFQ_REQUIRED_FLAG,
	 msii.QTY_RCV_TOLERANCE,
	 msii.LIST_PRICE_PER_UNIT,
	 msii.UN_NUMBER_ID,
	 msii.PRICE_TOLERANCE_PERCENT,
	 msii.ASSET_CATEGORY_ID,
	 msii.ROUNDING_FACTOR,
	 msii.UNIT_OF_ISSUE,
	 msii.ENFORCE_SHIP_TO_LOCATION_CODE,
	 msii.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
	 msii.ALLOW_UNORDERED_RECEIPTS_FLAG,
	 msii.ALLOW_EXPRESS_DELIVERY_FLAG,
	 msii.DAYS_EARLY_RECEIPT_ALLOWED,
	 msii.DAYS_LATE_RECEIPT_ALLOWED,
	 msii.RECEIPT_DAYS_EXCEPTION_CODE,
	 msii.RECEIVING_ROUTING_ID,
	 msii.INVOICE_CLOSE_TOLERANCE,
	 msii.RECEIVE_CLOSE_TOLERANCE,
	 msii.AUTO_LOT_ALPHA_PREFIX,
         msii.CHECK_SHORTAGES_FLAG,     /*CK 21MAY98 Added new attribute*/
          msii.EFFECTIVITY_CONTROL
      ,   msii.OVERCOMPLETION_TOLERANCE_TYPE
      ,   msii.OVERCOMPLETION_TOLERANCE_VALUE
      ,   msii.OVER_SHIPMENT_TOLERANCE
      ,   msii.UNDER_SHIPMENT_TOLERANCE
      ,   msii.OVER_RETURN_TOLERANCE
      ,   msii.UNDER_RETURN_TOLERANCE
      ,   msii.EQUIPMENT_TYPE
      ,   msii.RECOVERED_PART_DISP_CODE
      ,   msii.DEFECT_TRACKING_ON_FLAG
      ,   msii.EVENT_FLAG
      ,   msii.ELECTRONIC_FLAG
      ,   msii.DOWNLOADABLE_FLAG
      ,   msii.VOL_DISCOUNT_EXEMPT_FLAG
      ,   msii.COUPON_EXEMPT_FLAG
      ,   msii.COMMS_NL_TRACKABLE_FLAG
      ,   msii.ASSET_CREATION_CODE
      ,   msii.COMMS_ACTIVATION_REQD_FLAG
      ,   msii.ORDERABLE_ON_WEB_FLAG
      ,   msii.BACK_ORDERABLE_FLAG
      ,  msii.WEB_STATUS
      ,  msii.INDIVISIBLE_FLAG
      ,   msii.DIMENSION_UOM_CODE
      ,   msii.UNIT_LENGTH
      ,   msii.UNIT_WIDTH
      ,   msii.UNIT_HEIGHT
      ,   msii.BULK_PICKED_FLAG
      ,   msii.LOT_STATUS_ENABLED
      ,   msii.DEFAULT_LOT_STATUS_ID
      ,   msii.SERIAL_STATUS_ENABLED
      ,   msii.DEFAULT_SERIAL_STATUS_ID
      ,   msii.LOT_SPLIT_ENABLED
      ,   msii.LOT_MERGE_ENABLED
      ,   msii.INVENTORY_CARRY_PENALTY
      ,   msii.OPERATION_SLACK_PENALTY
      ,   msii.FINANCING_ALLOWED_FLAG
      ,  msii.EAM_ITEM_TYPE
      ,  msii.EAM_ACTIVITY_TYPE_CODE
      ,  msii.EAM_ACTIVITY_CAUSE_CODE
      ,  msii.EAM_ACT_NOTIFICATION_FLAG
      ,  msii.EAM_ACT_SHUTDOWN_STATUS
      ,  msii.DUAL_UOM_CONTROL
      ,  msii.SECONDARY_UOM_CODE
      ,  msii.DUAL_UOM_DEVIATION_HIGH
      ,  msii.DUAL_UOM_DEVIATION_LOW
      --,  msii.SERVICE_ITEM_FLAG
      --,  msii.USAGE_ITEM_FLAG
      ,  msii.CONTRACT_ITEM_TYPE_CODE
--      ,  msii.SUBSCRIPTION_DEPEND_FLAG
      --
      ,  msii.SERV_REQ_ENABLED_CODE
      ,  msii.SERV_BILLING_ENABLED_FLAG
--      ,  msii.SERV_IMPORTANCE_LEVEL
      ,  msii.PLANNED_INV_POINT_FLAG
      ,  msii.LOT_TRANSLATE_ENABLED
      ,  msii.DEFAULT_SO_SOURCE_TYPE
      ,  msii.CREATE_SUPPLY_FLAG
      ,  msii.SUBSTITUTION_WINDOW_CODE
      ,  msii.SUBSTITUTION_WINDOW_DAYS
      FROM
         MTL_SYSTEM_ITEMS_INTERFACE  msii
      ,  MTL_PARAMETERS              mp
      WHERE
             ( (msii.organization_id = org_id) OR (all_Org = 1) )
         AND msii.process_flag = 2
         AND msii.organization_id = mp.organization_id
         AND msii.set_process_id = xset_id
         AND msii.organization_id <> mp.master_organization_id;

   -- Attributes that are Item level;
   -- can't be different from master org's value.

   CURSOR ee
   IS
      --SELECT  SUBSTR(ATTRIBUTE_NAME,18)  Attribute_Code
      SELECT  attribute_name
           ,  control_level
      FROM  mtl_item_attributes
      WHERE
             control_level = 1
         AND attribute_group_id_gui IN
             (20, 25, 30, 31, 35, 40, 41, 51,
              60, 62, 65, 70, 80, 90, 100, 120, 130);
     /* Start Bug 3713912 */ --added 130 in the above where clause.

	msicount		number;
	msiicount		number;
	l_item_id		number;
	l_org_id		number;
	trans_id		number;
	ext_flag		number := 0;
	error_msg		varchar2(70);
	status			number;
	dumm_status		number;
	master_org_id		number;
	LOGGING_ERR		exception;
	VALIDATE_ERR		exception;
	X_TRUE			NUMBER  :=  1;

	A_DESCRIPTION			number := 2;
	A_LONG_DESCRIPTION		number := 2;
	A_BUYER_ID			number := 2;
	A_ACCOUNTING_RULE_ID		number := 2;
	A_INVOICING_RULE_ID		number := 2;
 	A_PURCHASING_ITEM_FLAG		number := 2;
	A_SHIPPABLE_ITEM_FLAG		number := 2;
	A_CUSTOMER_ORDER_FLAG		number := 2;
	A_INTERNAL_ORDER_FLAG		number := 2;
	A_INVENTORY_ITEM_FLAG		number := 2;
	A_PURCHASING_ENABLED_FLAG	number := 2;
	A_CUSTOMER_ORDER_ENABLED_FLAG	number := 2;
	A_INTERNAL_ORDER_ENABLED_FLAG	number := 2;
	A_SO_TRANSACTIONS_FLAG		number := 2;
	A_MTL_TRANSACTIONS_ENABLED_F	number := 2;
	A_STOCK_ENABLED_FLAG		number := 2;
	A_BOM_ENABLED_FLAG		number := 2;
	A_BUILD_IN_WIP_FLAG		number := 2;
	A_REVISION_QTY_CONTROL_CODE	number := 2;
	A_ITEM_CATALOG_GROUP_ID		number := 1;--Bug:3565730
 	A_CATALOG_STATUS_FLAG		number := 2;
	A_RETURNABLE_FLAG		number := 2;
	A_DEFAULT_SHIPPING_ORG		number := 2;
	A_COLLATERAL_FLAG		number := 2;
	A_TAXABLE_FLAG			number := 2;
	A_PURCHASING_TAX_CODE		number := 2;
	A_QTY_RCV_EXCEPTION_CODE	number := 2;
	A_ALLOW_ITEM_DESC_UPDATE_FLAG	number := 2;
	A_INSPECTION_REQUIRED_FLAG	number := 2;
	A_RECEIPT_REQUIRED_FLAG		number := 2;
	A_MARKET_PRICE			number := 2;
	A_HAZARD_CLASS_ID		number := 2;
	A_RFQ_REQUIRED_FLAG		number := 2;
	A_QTY_RCV_TOLERANCE		number := 2;
	A_LIST_PRICE_PER_UNIT		number := 2;
	A_UN_NUMBER_ID			number := 2;
	A_PRICE_TOLERANCE_PERCENT	number := 2;
	A_ASSET_CATEGORY_ID		number := 2;
	A_ROUNDING_FACTOR		number := 2;
	A_UNIT_OF_ISSUE			number := 2;
	A_ENFORCE_SHIP_TO_LOCATION_C	number := 2;
	A_ALLOW_SUBSTITUTE_RECEIPTS_F	number := 2;
	A_ALLOW_UNORDERED_RECEIPTS_F	number := 2;
	A_ALLOW_EXPRESS_DELIVERY_FLAG	number := 2;
	A_DAYS_EARLY_RECEIPT_ALLOWED	number := 2;
	A_DAYS_LATE_RECEIPT_ALLOWED	number := 2;
	A_RECEIPT_DAYS_EXCEPTION_CODE	number := 2;
	A_RECEIVING_ROUTING_ID		number := 2;
	A_INVOICE_CLOSE_TOLERANCE	number := 2;
	A_RECEIVE_CLOSE_TOLERANCE	number := 2;
	A_AUTO_LOT_ALPHA_PREFIX		number := 2;
	/*CK 21MAY98 Added for new attribute*/
	A_CHECK_SHORTAGES_FLAG		number := 2;
     A_EFFECTIVITY_CONTROL            NUMBER  :=  2;
   A_OVERCOMPLETION_TOLERANCE_TYP   NUMBER  :=  2;
   A_OVERCOMPLETION_TOLERANCE_VAL   NUMBER  :=  2;
   A_OVER_SHIPMENT_TOLERANCE          NUMBER  :=  2;
   A_UNDER_SHIPMENT_TOLERANCE         NUMBER  :=  2;
   A_OVER_RETURN_TOLERANCE            NUMBER  :=  2;
   A_UNDER_RETURN_TOLERANCE           NUMBER  :=  2;
   A_EQUIPMENT_TYPE                   NUMBER  :=  2;
   A_RECOVERED_PART_DISP_CODE         NUMBER  :=  2;
   A_DEFECT_TRACKING_ON_FLAG          NUMBER  :=  2;
   A_EVENT_FLAG                       NUMBER  :=  2;
   A_ELECTRONIC_FLAG                  NUMBER  :=  2;
   A_DOWNLOADABLE_FLAG                NUMBER  :=  2;
   A_VOL_DISCOUNT_EXEMPT_FLAG         NUMBER  :=  2;
   A_COUPON_EXEMPT_FLAG               NUMBER  :=  2;
   A_COMMS_NL_TRACKABLE_FLAG          NUMBER  :=  2;
   A_ASSET_CREATION_CODE              NUMBER  :=  2;
   A_COMMS_ACTIVATION_REQD_FLAG       NUMBER  :=  2;
   A_ORDERABLE_ON_WEB_FLAG            NUMBER  :=  2;
   A_BACK_ORDERABLE_FLAG              NUMBER  :=  2;
        A_WEB_STATUS			number := 2;
        A_INDIVISIBLE_FLAG		number := 2;
   A_DIMENSION_UOM_CODE               NUMBER  :=  2;
   A_UNIT_LENGTH                      NUMBER  :=  2;
   A_UNIT_WIDTH                       NUMBER  :=  2;
   A_UNIT_HEIGHT                      NUMBER  :=  2;
   A_BULK_PICKED_FLAG                 NUMBER  :=  2;
   A_LOT_STATUS_ENABLED               NUMBER  :=  2;
   A_DEFAULT_LOT_STATUS_ID            NUMBER  :=  2;
   A_SERIAL_STATUS_ENABLED            NUMBER  :=  2;
   A_DEFAULT_SERIAL_STATUS_ID         NUMBER  :=  2;
   A_LOT_SPLIT_ENABLED                NUMBER  :=  2;
   A_LOT_MERGE_ENABLED                NUMBER  :=  2;
   A_INVENTORY_CARRY_PENALTY          NUMBER  :=  2;
   A_OPERATION_SLACK_PENALTY          NUMBER  :=  2;
   A_FINANCING_ALLOWED_FLAG           NUMBER  :=  2;

   A_EAM_ITEM_TYPE                    NUMBER  :=  2;
   A_EAM_ACTIVITY_TYPE_CODE           NUMBER  :=  2;
   A_EAM_ACTIVITY_CAUSE_CODE          NUMBER  :=  2;
   A_EAM_ACT_NOTIFICATION_FLAG        NUMBER  :=  2;
   A_EAM_ACT_SHUTDOWN_STATUS          NUMBER  :=  2;
  -- A_DUAL_UOM_CONTROL                 NUMBER  :=  2; -- commented for bug 7567332.
   A_SECONDARY_UOM_CODE               NUMBER  :=  2;
   A_DUAL_UOM_DEVIATION_HIGH          NUMBER  :=  2;
   A_DUAL_UOM_DEVIATION_LOW           NUMBER  :=  2;
  -- A_SERVICE_ITEM_FLAG                NUMBER  :=  2;
  -- A_USAGE_ITEM_FLAG                  NUMBER  :=  2;
   A_CONTRACT_ITEM_TYPE_CODE          NUMBER  :=  2;
--   A_SUBSCRIPTION_DEPEND_FLAG         NUMBER  :=  2;

   A_SERV_REQ_ENABLED_CODE            NUMBER  :=  2;
   A_SERV_BILLING_ENABLED_FLAG        NUMBER  :=  2;
--   A_SERV_IMPORTANCE_LEVEL            NUMBER  :=  2;
   A_PLANNED_INV_POINT_FLAG           NUMBER  :=  2;
   A_LOT_TRANSLATE_ENABLED            NUMBER  :=  2;
   A_DEFAULT_SO_SOURCE_TYPE           NUMBER  :=  2;
   A_CREATE_SUPPLY_FLAG               NUMBER  :=  2;
   A_SUBSTITUTION_WINDOW_CODE         NUMBER  :=  2;
   A_SUBSTITUTION_WINDOW_DAYS         NUMBER  :=  2;

BEGIN

/* set the attribute level variables to be used when validating a child's item
** level attributes against the master org's attribute value.  this is done
** outside the loop so that it is only done once for all the records
** instead of once PER record.
*/

   FOR att IN ee LOOP

		if substr(att.attribute_name,18) = 'DESCRIPTION' then
			A_DESCRIPTION := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'LONG_DESCRIPTION' then
			A_LONG_DESCRIPTION := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'BUYER_ID' then
			A_BUYER_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ACCOUNTING_RULE_ID' then
			A_ACCOUNTING_RULE_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'INVOICING_RULE_ID' then
			A_INVOICING_RULE_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PURCHASING_ITEM_FLAG' then
			A_PURCHASING_ITEM_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SHIPPABLE_ITEM_FLAG' then
			A_SHIPPABLE_ITEM_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'CUSTOMER_ORDER_FLAG' then
			A_CUSTOMER_ORDER_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'INTERNAL_ORDER_FLAG' then
			A_INTERNAL_ORDER_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'INVENTORY_ITEM_FLAG' then
			A_INVENTORY_ITEM_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PURCHASING_ENABLED_FLAG' then
			A_PURCHASING_ENABLED_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'CUSTOMER_ORDER_ENABLED_FLAG' then
			A_CUSTOMER_ORDER_ENABLED_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'INTERNAL_ORDER_ENABLED_FLAG' then
			A_INTERNAL_ORDER_ENABLED_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'SO_TRANSACTIONS_FLAG' then
			A_SO_TRANSACTIONS_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MTL_TRANSACTIONS_ENABLED_FLAG' then
			A_MTL_TRANSACTIONS_ENABLED_F := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'STOCK_ENABLED_FLAG' then
			A_STOCK_ENABLED_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'BOM_ENABLED_FLAG' then
			A_BOM_ENABLED_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'BUILD_IN_WIP_FLAG' then
			A_BUILD_IN_WIP_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'REVISION_QTY_CONTROL_CODE' then
			A_REVISION_QTY_CONTROL_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ITEM_CATALOG_GROUP_ID' then
			A_ITEM_CATALOG_GROUP_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'CATALOG_STATUS_FLAG' then
			A_CATALOG_STATUS_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'RETURNABLE_FLAG' then
			A_RETURNABLE_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'DEFAULT_SHIPPING_ORG' then
			A_DEFAULT_SHIPPING_ORG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'COLLATERAL_FLAG' then
			A_COLLATERAL_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'TAXABLE_FLAG' then
			A_TAXABLE_FLAG := att.control_level;
		end if;

		-- Bug 1014929 (1000764)
		if substr(att.attribute_name,18) = 'PURCHASING_TAX_CODE' then
			A_PURCHASING_TAX_CODE := att.control_level;
		end if;

		if substr(att.attribute_name,18) = 'QTY_RCV_EXCEPTION_CODE' then
			A_QTY_RCV_EXCEPTION_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ALLOW_ITEM_DESC_UPDATE_FLAG' then
			A_ALLOW_ITEM_DESC_UPDATE_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'INSPECTION_REQUIRED_FLAG' then
			A_INSPECTION_REQUIRED_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'RECEIPT_REQUIRED_FLAG' then
			A_RECEIPT_REQUIRED_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'MARKET_PRICE' then
			A_MARKET_PRICE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'HAZARD_CLASS_ID' then
			A_HAZARD_CLASS_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'RFQ_REQUIRED_FLAG' then
			A_RFQ_REQUIRED_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'QTY_RCV_TOLERANCE' then
			A_QTY_RCV_TOLERANCE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'LIST_PRICE_PER_UNIT' then
			A_LIST_PRICE_PER_UNIT := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'UN_NUMBER_ID' then
			A_UN_NUMBER_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'PRICE_TOLERANCE_PERCENT' then
			A_PRICE_TOLERANCE_PERCENT := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ASSET_CATEGORY_ID' then
			A_ASSET_CATEGORY_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ROUNDING_FACTOR' then
			A_ROUNDING_FACTOR := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'UNIT_OF_ISSUE' then
			A_UNIT_OF_ISSUE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ENFORCE_SHIP_TO_LOCATION_CODE' then
			A_ENFORCE_SHIP_TO_LOCATION_C := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ALLOW_SUBSTITUTE_RECEIPTS_FLAG' then
			A_ALLOW_SUBSTITUTE_RECEIPTS_F := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ALLOW_UNORDERED_RECEIPTS_FLAG' then
			A_ALLOW_UNORDERED_RECEIPTS_F := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'ALLOW_EXPRESS_DELIVERY_FLAG' then
			A_ALLOW_EXPRESS_DELIVERY_FLAG := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'DAYS_EARLY_RECEIPT_ALLOWED' then
			A_DAYS_EARLY_RECEIPT_ALLOWED := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'DAYS_LATE_RECEIPT_ALLOWED' then
			A_DAYS_LATE_RECEIPT_ALLOWED := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'RECEIPT_DAYS_EXCEPTION_CODE' then
			A_RECEIPT_DAYS_EXCEPTION_CODE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'RECEIVING_ROUTING_ID' then
			A_RECEIVING_ROUTING_ID := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'INVOICE_CLOSE_TOLERANCE' then
			A_INVOICE_CLOSE_TOLERANCE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'RECEIVE_CLOSE_TOLERANCE' then
			A_RECEIVE_CLOSE_TOLERANCE := att.control_level;
		end if;
		if substr(att.attribute_name,18) = 'AUTO_LOT_ALPHA_PREFIX' then
			A_AUTO_LOT_ALPHA_PREFIX := att.control_level;
		end if;

 		/*CK 21MAY98 Added for new attribute*/
 		if substr(att.attribute_name,18) = 'CHECK_SHORTAGES_FLAG' then
 			A_CHECK_SHORTAGES_FLAG := att.control_level;
 		end if;

        IF substr(att.attribute_name,18) = 'EFFECTIVITY_CONTROL' THEN
           A_EFFECTIVITY_CONTROL := att.control_level;
        END IF;

      IF substr(att.attribute_name,18) = 'OVERCOMPLETION_TOLERANCE_TYPE' THEN
         A_OVERCOMPLETION_TOLERANCE_TYP := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'OVERCOMPLETION_TOLERANCE_VALUE' THEN
         A_OVERCOMPLETION_TOLERANCE_VAL := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'OVER_SHIPMENT_TOLERANCE' THEN
         A_OVER_SHIPMENT_TOLERANCE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'UNDER_SHIPMENT_TOLERANCE' THEN
         A_UNDER_SHIPMENT_TOLERANCE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'OVER_RETURN_TOLERANCE' THEN
         A_OVER_RETURN_TOLERANCE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'UNDER_RETURN_TOLERANCE' THEN
         A_UNDER_RETURN_TOLERANCE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'EQUIPMENT_TYPE' THEN
         A_EQUIPMENT_TYPE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'RECOVERED_PART_DISP_CODE' THEN
         A_RECOVERED_PART_DISP_CODE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'DEFECT_TRACKING_ON_FLAG' THEN
         A_DEFECT_TRACKING_ON_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'EVENT_FLAG' THEN
         A_EVENT_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'ELECTRONIC_FLAG' THEN
         A_ELECTRONIC_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'DOWNLOADABLE_FLAG' THEN
         A_DOWNLOADABLE_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'VOL_DISCOUNT_EXEMPT_FLAG' THEN
         A_VOL_DISCOUNT_EXEMPT_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'COUPON_EXEMPT_FLAG' THEN
         A_COUPON_EXEMPT_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'COMMS_NL_TRACKABLE_FLAG' THEN
         A_COMMS_NL_TRACKABLE_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'ASSET_CREATION_CODE' THEN
         A_ASSET_CREATION_CODE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'COMMS_ACTIVATION_REQD_FLAG' THEN
         A_COMMS_ACTIVATION_REQD_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'ORDERABLE_ON_WEB_FLAG' THEN
         A_ORDERABLE_ON_WEB_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'BACK_ORDERABLE_FLAG' THEN
         A_BACK_ORDERABLE_FLAG := att.control_level;
      END IF;

        IF substr(att.attribute_name,18) = 'WEB_STATUS' then
           A_WEB_STATUS := att.control_level;
        END IF;
        IF substr(att.attribute_name,18) = 'INDIVISIBLE_FLAG' then
           A_INDIVISIBLE_FLAG := att.control_level;
        END IF;

      IF substr(att.attribute_name,18) = 'DIMENSION_UOM_CODE' THEN
         A_DIMENSION_UOM_CODE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'UNIT_LENGTH' THEN
         A_UNIT_LENGTH := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'UNIT_WIDTH' THEN
         A_UNIT_WIDTH := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'UNIT_HEIGHT' THEN
         A_UNIT_HEIGHT := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'BULK_PICKED_FLAG' THEN
         A_BULK_PICKED_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'LOT_STATUS_ENABLED' THEN
         A_LOT_STATUS_ENABLED := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'DEFAULT_LOT_STATUS_ID' THEN
         A_DEFAULT_LOT_STATUS_ID := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'SERIAL_STATUS_ENABLED' THEN
         A_SERIAL_STATUS_ENABLED := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'DEFAULT_SERIAL_STATUS_ID' THEN
         A_DEFAULT_SERIAL_STATUS_ID := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'LOT_SPLIT_ENABLED' THEN
         A_LOT_SPLIT_ENABLED := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'LOT_MERGE_ENABLED' THEN
         A_LOT_MERGE_ENABLED := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'INVENTORY_CARRY_PENALTY' THEN
         A_INVENTORY_CARRY_PENALTY := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'OPERATION_SLACK_PENALTY' THEN
         A_OPERATION_SLACK_PENALTY := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'FINANCING_ALLOWED_FLAG' THEN
         A_FINANCING_ALLOWED_FLAG := att.control_level;
      END IF;

      IF substr(att.attribute_name,18) = 'EAM_ITEM_TYPE' THEN
         A_EAM_ITEM_TYPE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'EAM_ACTIVITY_TYPE_CODE' THEN
         A_EAM_ACTIVITY_TYPE_CODE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'EAM_ACTIVITY_CAUSE_CODE' THEN
         A_EAM_ACTIVITY_CAUSE_CODE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'EAM_ACT_NOTIFICATION_FLAG' THEN
         A_EAM_ACT_NOTIFICATION_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'EAM_ACT_SHUTDOWN_STATUS' THEN
         A_EAM_ACT_SHUTDOWN_STATUS := att.control_level;
      END IF;
     /* IF substr(att.attribute_name,18) = 'DUAL_UOM_CONTROL' THEN
         A_DUAL_UOM_CONTROL := att.control_level;
      END IF; */ -- commented for bug 7567332
      IF substr(att.attribute_name,18) = 'SECONDARY_UOM_CODE' THEN
         A_SECONDARY_UOM_CODE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'DUAL_UOM_DEVIATION_HIGH' THEN
         A_DUAL_UOM_DEVIATION_HIGH := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'DUAL_UOM_DEVIATION_LOW' THEN
         A_DUAL_UOM_DEVIATION_LOW := att.control_level;
      END IF;

/*
		if substr(att.attribute_name,18) = 'SERVICE_ITEM_FLAG' then
			A_SERVICE_ITEM_FLAG := att.control_level;
		end if;
      IF substr(att.attribute_name,18) = 'USAGE_ITEM_FLAG' THEN
         A_USAGE_ITEM_FLAG := att.control_level;
      END IF;
*/
      IF substr(att.attribute_name,18) = 'CONTRACT_ITEM_TYPE_CODE' THEN
         A_CONTRACT_ITEM_TYPE_CODE := att.control_level;
      END IF;
/*      IF substr(att.attribute_name,18) = 'SUBSCRIPTION_DEPEND_FLAG' THEN
         A_SUBSCRIPTION_DEPEND_FLAG := att.control_level;
      END IF;
*/
      IF substr(att.attribute_name,18) = 'SERV_REQ_ENABLED_CODE' THEN
         A_SERV_REQ_ENABLED_CODE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'SERV_BILLING_ENABLED_FLAG' THEN
         A_SERV_BILLING_ENABLED_FLAG := att.control_level;
      END IF;
/*      IF substr(att.attribute_name,18) = 'SERV_IMPORTANCE_LEVEL' THEN
         A_SERV_IMPORTANCE_LEVEL := att.control_level;
      END IF;
*/      IF substr(att.attribute_name,18) = 'PLANNED_INV_POINT_FLAG' THEN
         A_PLANNED_INV_POINT_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'LOT_TRANSLATE_ENABLED' THEN
         A_LOT_TRANSLATE_ENABLED := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'DEFAULT_SO_SOURCE_TYPE' THEN
         A_DEFAULT_SO_SOURCE_TYPE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'CREATE_SUPPLY_FLAG' THEN
         A_CREATE_SUPPLY_FLAG := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'SUBSTITUTION_WINDOW_CODE' THEN
         A_SUBSTITUTION_WINDOW_CODE := att.control_level;
      END IF;
      IF substr(att.attribute_name,18) = 'SUBSTITUTION_WINDOW_DAYS' THEN
         A_SUBSTITUTION_WINDOW_DAYS := att.control_level;
      END IF;

   END LOOP;

   --
   -- Validate the records
   --
   FOR cr IN cc LOOP

		status := 0;
		trans_id := cr.transaction_id;
		l_org_id := cr.ORGID;

		begin /* MASTER_CHILD_1A */

		select  inventory_item_id into msicount
		from  mtl_system_items_B  msi
		where  msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
			and decode(A_BUYER_ID,X_TRUE,nvl(cr.BUYER_ID,-1),nvl(msi.BUYER_ID,-1))=nvl(msi.BUYER_ID,-1)
			and decode(A_ACCOUNTING_RULE_ID,X_TRUE,nvl(cr.ACCOUNTING_RULE_ID,-1),nvl(msi.ACCOUNTING_RULE_ID,-1))=nvl(msi.ACCOUNTING_RULE_ID,-1)
			and decode(A_INVOICING_RULE_ID,X_TRUE,nvl(cr.INVOICING_RULE_ID,-1),nvl(msi.INVOICING_RULE_ID,-1))=nvl(msi.INVOICING_RULE_ID,-1)
 			and decode(A_PURCHASING_ITEM_FLAG,X_TRUE,nvl(cr.PURCHASING_ITEM_FLAG,-1),nvl(msi.PURCHASING_ITEM_FLAG,-1))=nvl(msi.PURCHASING_ITEM_FLAG,-1)
 			and decode(A_SHIPPABLE_ITEM_FLAG,X_TRUE,nvl(cr.SHIPPABLE_ITEM_FLAG,-1),nvl(msi.SHIPPABLE_ITEM_FLAG,-1))=nvl(msi.SHIPPABLE_ITEM_FLAG,-1)
 			and decode(A_CUSTOMER_ORDER_FLAG,X_TRUE,nvl(cr.CUSTOMER_ORDER_FLAG,-1),nvl(msi.CUSTOMER_ORDER_FLAG,-1))=nvl(msi.CUSTOMER_ORDER_FLAG,-1)
 			and decode(A_INTERNAL_ORDER_FLAG,X_TRUE,nvl(cr.INTERNAL_ORDER_FLAG,-1),nvl(msi.INTERNAL_ORDER_FLAG,-1))=nvl(msi.INTERNAL_ORDER_FLAG,-1)
 			and decode(A_INVENTORY_ITEM_FLAG,X_TRUE,nvl(cr.INVENTORY_ITEM_FLAG,-1),nvl(msi.INVENTORY_ITEM_FLAG,-1))=nvl(msi.INVENTORY_ITEM_FLAG,-1);

		exception

			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1A',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1A',
				err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End If;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_1A */

		begin /* MASTER_CHILD_1C */

			select inventory_item_id into msicount
			from  mtl_system_items_B  msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_PURCHASING_ENABLED_FLAG,X_TRUE,nvl(cr.PURCHASING_ENABLED_FLAG,-1),nvl(msi.PURCHASING_ENABLED_FLAG,-1))=nvl(msi.PURCHASING_ENABLED_FLAG,-1)
 			and decode(A_CUSTOMER_ORDER_ENABLED_FLAG,X_TRUE,nvl(cr.CUSTOMER_ORDER_ENABLED_FLAG,-1),nvl(msi.CUSTOMER_ORDER_ENABLED_FLAG,-1))=nvl(msi.CUSTOMER_ORDER_ENABLED_FLAG,-1)
 			and decode(A_INTERNAL_ORDER_ENABLED_FLAG,X_TRUE,nvl(cr.INTERNAL_ORDER_ENABLED_FLAG,-1),nvl(msi.INTERNAL_ORDER_ENABLED_FLAG,-1))=nvl(msi.INTERNAL_ORDER_ENABLED_FLAG,-1)
 			and decode(A_SO_TRANSACTIONS_FLAG,X_TRUE,nvl(cr.SO_TRANSACTIONS_FLAG,-1),nvl(msi.SO_TRANSACTIONS_FLAG,-1))=nvl(msi.SO_TRANSACTIONS_FLAG,-1)
 			and decode(A_MTL_TRANSACTIONS_ENABLED_F,X_TRUE,nvl(cr.MTL_TRANSACTIONS_ENABLED_FLAG,-1),nvl(msi.MTL_TRANSACTIONS_ENABLED_FLAG,-1))=nvl(msi.MTL_TRANSACTIONS_ENABLED_FLAG,-1);

		exception
		   when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1C',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1C',
				err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End If;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_1C */

		begin /* MASTER_CHILD_1B */

		   select inventory_item_id
                   into msicount
		   from  mtl_system_items_B  msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_STOCK_ENABLED_FLAG,X_TRUE,nvl(cr.STOCK_ENABLED_FLAG,-1),nvl(msi.STOCK_ENABLED_FLAG,-1))=nvl(msi.STOCK_ENABLED_FLAG,-1)
 			and decode(A_BOM_ENABLED_FLAG,X_TRUE,nvl(cr.BOM_ENABLED_FLAG,-1),nvl(msi.BOM_ENABLED_FLAG,-1))=nvl(msi.BOM_ENABLED_FLAG,-1)
 			and decode(A_BUILD_IN_WIP_FLAG,X_TRUE,nvl(cr.BUILD_IN_WIP_FLAG,-1),nvl(msi.BUILD_IN_WIP_FLAG,-1))=nvl(msi.BUILD_IN_WIP_FLAG,-1)
 			and decode(A_REVISION_QTY_CONTROL_CODE,X_TRUE,nvl(cr.REVISION_QTY_CONTROL_CODE,-1),nvl(msi.REVISION_QTY_CONTROL_CODE,-1))=nvl(msi.REVISION_QTY_CONTROL_CODE,-1)
 			and decode(A_ITEM_CATALOG_GROUP_ID,X_TRUE,nvl(cr.ITEM_CATALOG_GROUP_ID,-1),nvl(msi.ITEM_CATALOG_GROUP_ID,-1))=nvl(msi.ITEM_CATALOG_GROUP_ID,-1)
 			and decode(A_CHECK_SHORTAGES_FLAG,X_TRUE,nvl(cr.CHECK_SHORTAGES_FLAG,-1),nvl(msi.CHECK_SHORTAGES_FLAG,-1))=nvl(msi.CHECK_SHORTAGES_FLAG,-1)

 		   and decode(A_WEB_STATUS,
                              X_TRUE, nvl(cr.WEB_STATUS, -1),
                              nvl(msi.WEB_STATUS, -1)
                       ) = nvl(msi.WEB_STATUS, -1)

 		   and decode(A_INDIVISIBLE_FLAG,
                              X_TRUE, nvl(cr.INDIVISIBLE_FLAG, -1),
                              nvl(msi.INDIVISIBLE_FLAG, -1)
                       ) = nvl(msi.INDIVISIBLE_FLAG, -1) ;

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1B',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1B',
				err_text);

                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End If;

				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_1B */

		begin /* MASTER_CHILD_1D */

			select inventory_item_id into msicount
			from  mtl_system_items_B  msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_CATALOG_STATUS_FLAG,X_TRUE,nvl(cr.CATALOG_STATUS_FLAG,-1),nvl(msi.CATALOG_STATUS_FLAG,-1))=nvl(msi.CATALOG_STATUS_FLAG,-1)
 			and decode(A_RETURNABLE_FLAG,X_TRUE,nvl(cr.RETURNABLE_FLAG,-1),nvl(msi.RETURNABLE_FLAG,-1))=nvl(msi.RETURNABLE_FLAG,-1)
 			and decode(A_DEFAULT_SHIPPING_ORG,X_TRUE,nvl(cr.DEFAULT_SHIPPING_ORG,-1),nvl(msi.DEFAULT_SHIPPING_ORG,-1))=nvl(msi.DEFAULT_SHIPPING_ORG,-1)
 			and decode(A_COLLATERAL_FLAG,X_TRUE,nvl(cr.COLLATERAL_FLAG,-1),nvl(msi.COLLATERAL_FLAG,-1))=nvl(msi.COLLATERAL_FLAG,-1)
 			and decode(A_TAXABLE_FLAG,X_TRUE,nvl(cr.TAXABLE_FLAG,-1),nvl(msi.TAXABLE_FLAG,-1))=nvl(msi.TAXABLE_FLAG,-1)

 			and decode(A_PURCHASING_TAX_CODE,X_TRUE,nvl(cr.PURCHASING_TAX_CODE,-1),nvl(msi.PURCHASING_TAX_CODE,-1))=nvl(msi.PURCHASING_TAX_CODE,-1)

 			and decode(A_QTY_RCV_EXCEPTION_CODE,X_TRUE,nvl(cr.QTY_RCV_EXCEPTION_CODE,-1),nvl(msi.QTY_RCV_EXCEPTION_CODE,-1))=nvl(msi.QTY_RCV_EXCEPTION_CODE,-1)
 			and decode(A_ALLOW_ITEM_DESC_UPDATE_FLAG,X_TRUE,nvl(cr.ALLOW_ITEM_DESC_UPDATE_FLAG,-1),nvl(msi.ALLOW_ITEM_DESC_UPDATE_FLAG,-1))=nvl(msi.ALLOW_ITEM_DESC_UPDATE_FLAG,-1)
 			and decode(A_INSPECTION_REQUIRED_FLAG,X_TRUE,nvl(cr.INSPECTION_REQUIRED_FLAG,-1),nvl(msi.INSPECTION_REQUIRED_FLAG,-1))=nvl(msi.INSPECTION_REQUIRED_FLAG,-1)
 			and decode(A_RECEIPT_REQUIRED_FLAG,X_TRUE,nvl(cr.RECEIPT_REQUIRED_FLAG,-1),nvl(msi.RECEIPT_REQUIRED_FLAG,-1))=nvl(msi.RECEIPT_REQUIRED_FLAG,-1)
 			and decode(A_MARKET_PRICE,X_TRUE,nvl(cr.MARKET_PRICE,-1),nvl(msi.MARKET_PRICE,-1))=nvl(msi.MARKET_PRICE,-1);

		exception
		   when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1D',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1D',
				err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End If;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_1D */

		begin /* MASTER_CHILD_1E */

			select inventory_item_id into msicount
			from  mtl_system_items_B  msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_HAZARD_CLASS_ID,X_TRUE,nvl(cr.HAZARD_CLASS_ID,-1),nvl(msi.HAZARD_CLASS_ID,-1))=nvl(msi.HAZARD_CLASS_ID,-1)
 			and decode(A_RFQ_REQUIRED_FLAG,X_TRUE,nvl(cr.RFQ_REQUIRED_FLAG,-1),nvl(msi.RFQ_REQUIRED_FLAG,-1))=nvl(msi.RFQ_REQUIRED_FLAG,-1)
 			and decode(A_QTY_RCV_TOLERANCE,X_TRUE,nvl(cr.QTY_RCV_TOLERANCE,-1),nvl(msi.QTY_RCV_TOLERANCE,-1))=nvl(msi.QTY_RCV_TOLERANCE,-1)
 			and decode(A_LIST_PRICE_PER_UNIT,X_TRUE,nvl(cr.LIST_PRICE_PER_UNIT,-1),nvl(msi.LIST_PRICE_PER_UNIT,-1))=nvl(msi.LIST_PRICE_PER_UNIT,-1)
 			and decode(A_UN_NUMBER_ID,X_TRUE,nvl(cr.UN_NUMBER_ID,-1),nvl(msi.UN_NUMBER_ID,-1))=nvl(msi.UN_NUMBER_ID,-1)
 			and decode(A_PRICE_TOLERANCE_PERCENT,X_TRUE,nvl(cr.PRICE_TOLERANCE_PERCENT,-1),nvl(msi.PRICE_TOLERANCE_PERCENT,-1))=nvl(msi.PRICE_TOLERANCE_PERCENT,-1)
 			and decode(A_ASSET_CATEGORY_ID,X_TRUE,nvl(cr.ASSET_CATEGORY_ID,-1),nvl(msi.ASSET_CATEGORY_ID,-1))=nvl(msi.ASSET_CATEGORY_ID,-1)
 			and decode(A_ROUNDING_FACTOR,X_TRUE,nvl(cr.ROUNDING_FACTOR,-1),nvl(msi.ROUNDING_FACTOR,-1))=nvl(msi.ROUNDING_FACTOR,-1)
 			and decode(A_UNIT_OF_ISSUE,X_TRUE,nvl(cr.UNIT_OF_ISSUE,-1),nvl(msi.UNIT_OF_ISSUE,-1))=nvl(msi.UNIT_OF_ISSUE,-1)
 			and decode(A_ENFORCE_SHIP_TO_LOCATION_C,X_TRUE,nvl(cr.ENFORCE_SHIP_TO_LOCATION_CODE,-1),nvl(msi.ENFORCE_SHIP_TO_LOCATION_CODE,-1))=nvl(msi.ENFORCE_SHIP_TO_LOCATION_CODE,-1);
		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1E',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1E',
				err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End If;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_1E */

		begin /* MASTER_CHILD_1F */

			select inventory_item_id into msicount
			from  mtl_system_items_B  msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_ALLOW_SUBSTITUTE_RECEIPTS_F,X_TRUE,nvl(cr.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,-1),nvl(msi.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,-1))=nvl(msi.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,-1)
 			and decode(A_ALLOW_UNORDERED_RECEIPTS_F,X_TRUE,nvl(cr.ALLOW_UNORDERED_RECEIPTS_FLAG,-1),nvl(msi.ALLOW_UNORDERED_RECEIPTS_FLAG,-1))=nvl(msi.ALLOW_UNORDERED_RECEIPTS_FLAG,-1)
 			and decode(A_ALLOW_EXPRESS_DELIVERY_FLAG,X_TRUE,nvl(cr.ALLOW_EXPRESS_DELIVERY_FLAG,-1),nvl(msi.ALLOW_EXPRESS_DELIVERY_FLAG,-1))=nvl(msi.ALLOW_EXPRESS_DELIVERY_FLAG,-1)
 			and decode(A_DAYS_EARLY_RECEIPT_ALLOWED,X_TRUE,nvl(cr.DAYS_EARLY_RECEIPT_ALLOWED,-1),nvl(msi.DAYS_EARLY_RECEIPT_ALLOWED,-1))=nvl(msi.DAYS_EARLY_RECEIPT_ALLOWED,-1)
 			and decode(A_DAYS_LATE_RECEIPT_ALLOWED,X_TRUE,nvl(cr.DAYS_LATE_RECEIPT_ALLOWED,-1),nvl(msi.DAYS_LATE_RECEIPT_ALLOWED,-1))=nvl(msi.DAYS_LATE_RECEIPT_ALLOWED,-1);

		exception
			when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1F',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1F',
				err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End If;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_1F */

/*Bug 1529259
  In the following query changed the Table Name from mtl_system_item_b
  to mtl_system_items_vl
  This is to get the correct description
*/
--5446889 ADDED check for long_description
		begin /* MASTER_CHILD_1G */

			select inventory_item_id into msicount
			from  mtl_system_items_VL  msi
			where msi.inventory_item_id = cr.III
			and   msi.organization_id = cr.MORGID
 			and decode(A_RECEIPT_DAYS_EXCEPTION_CODE,X_TRUE,nvl(cr.RECEIPT_DAYS_EXCEPTION_CODE,-1),nvl(msi.RECEIPT_DAYS_EXCEPTION_CODE,-1))=nvl(msi.RECEIPT_DAYS_EXCEPTION_CODE,-1)
 			and decode(A_RECEIVING_ROUTING_ID,X_TRUE,nvl(cr.RECEIVING_ROUTING_ID,-1),nvl(msi.RECEIVING_ROUTING_ID,-1))=nvl(msi.RECEIVING_ROUTING_ID,-1)
 			and decode(A_INVOICE_CLOSE_TOLERANCE,X_TRUE,nvl(cr.INVOICE_CLOSE_TOLERANCE,-1),nvl(msi.INVOICE_CLOSE_TOLERANCE,-1))=nvl(msi.INVOICE_CLOSE_TOLERANCE,-1)
 			and decode(A_RECEIVE_CLOSE_TOLERANCE,X_TRUE,nvl(cr.RECEIVE_CLOSE_TOLERANCE,-1),nvl(msi.RECEIVE_CLOSE_TOLERANCE,-1))=nvl(msi.RECEIVE_CLOSE_TOLERANCE,-1)
 			and decode(A_DESCRIPTION,X_TRUE,nvl(cr.DESCRIPTION,-1),nvl(msi.DESCRIPTION,-1))=nvl(msi.DESCRIPTION,-1)
			and decode(A_LONG_DESCRIPTION,X_TRUE,nvl(cr.LONG_DESCRIPTION,-1),nvl(msi.LONG_DESCRIPTION,-1))=nvl(msi.LONG_DESCRIPTION,-1)
 			and decode(A_AUTO_LOT_ALPHA_PREFIX,X_TRUE,nvl(cr.AUTO_LOT_ALPHA_PREFIX,-1),nvl(msi.AUTO_LOT_ALPHA_PREFIX,-1))=nvl(msi.AUTO_LOT_ALPHA_PREFIX,-1);

                exception
		   when NO_DATA_FOUND then
				dumm_status := INVPUOPI.mtl_log_interface_err(
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1G',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1G',
				err_text);
                                If dumm_status < 0 then
                                   raise LOGGING_ERR ;
                                End If;
				update mtl_system_items_interface msii
				set process_flag = 3
				where msii.transaction_id = cr.transaction_id;

		end;  /* MASTER_CHILD_1G */


      BEGIN  /* MASTER_CHILD_1HA */

         SELECT  inventory_item_id
           INTO  msicount
         FROM  mtl_system_items_b  msi
         WHERE  msi.inventory_item_id = cr.III
           AND  msi.organization_id = cr.MORGID

           AND  DECODE( A_OVERCOMPLETION_TOLERANCE_TYP,
                        x_true, NVL(cr.OVERCOMPLETION_TOLERANCE_TYPE, -1),
                        NVL(msi.OVERCOMPLETION_TOLERANCE_TYPE, -1)
                      ) = NVL(msi.OVERCOMPLETION_TOLERANCE_TYPE, -1)

           AND  DECODE( A_OVERCOMPLETION_TOLERANCE_VAL,
                        x_true, NVL(cr.OVERCOMPLETION_TOLERANCE_VALUE, -1),
                        NVL(msi.OVERCOMPLETION_TOLERANCE_VALUE, -1)
                      ) = NVL(msi.OVERCOMPLETION_TOLERANCE_VALUE, -1)

           AND  DECODE( A_OVER_SHIPMENT_TOLERANCE,
                        x_true, NVL(cr.OVER_SHIPMENT_TOLERANCE, -1),
                        NVL(msi.OVER_SHIPMENT_TOLERANCE, -1)
                      ) = NVL(msi.OVER_SHIPMENT_TOLERANCE, -1)

           AND  DECODE( A_UNDER_SHIPMENT_TOLERANCE,
                        x_true, NVL(cr.UNDER_SHIPMENT_TOLERANCE, -1),
                        NVL(msi.UNDER_SHIPMENT_TOLERANCE, -1)
                      ) = NVL(msi.UNDER_SHIPMENT_TOLERANCE, -1)
           ;
      EXCEPTION

         when NO_DATA_FOUND then
		dumm_status := INVPUOPI.mtl_log_interface_err (
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1HA',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1HA',
				err_text );

            IF dumm_status < 0 THEN
               raise LOGGING_ERR ;
            END IF;

            update mtl_system_items_interface msii
            set process_flag = 3
            where msii.transaction_id = cr.transaction_id;

      END;  /* MASTER_CHILD_1HA */

      BEGIN  /* MASTER_CHILD_1HB */

         SELECT  inventory_item_id
           INTO  msicount
         FROM  mtl_system_items_b  msi
         WHERE  msi.inventory_item_id = cr.III
           AND  msi.organization_id = cr.MORGID

           AND  DECODE( A_OVER_RETURN_TOLERANCE,
                        x_true, NVL(cr.OVER_RETURN_TOLERANCE, -1),
                        NVL(msi.OVER_RETURN_TOLERANCE, -1)
                      ) = NVL(msi.OVER_RETURN_TOLERANCE, -1)

           AND  DECODE( A_UNDER_RETURN_TOLERANCE,
                        x_true, NVL(cr.UNDER_RETURN_TOLERANCE, -1),
                        NVL(msi.UNDER_RETURN_TOLERANCE, -1)
                      ) = NVL(msi.UNDER_RETURN_TOLERANCE, -1)

           AND  DECODE( A_EQUIPMENT_TYPE,
                        x_true, NVL(cr.EQUIPMENT_TYPE, -1),
                        NVL(msi.EQUIPMENT_TYPE, -1)
                      ) = NVL(msi.EQUIPMENT_TYPE, -1)

           AND  DECODE( A_RECOVERED_PART_DISP_CODE,
                        x_true, NVL(cr.RECOVERED_PART_DISP_CODE, -1),
                        NVL(msi.RECOVERED_PART_DISP_CODE, -1)
                      ) = NVL(msi.RECOVERED_PART_DISP_CODE, -1)

           AND  DECODE( A_DEFECT_TRACKING_ON_FLAG,
                        x_true, NVL(cr.DEFECT_TRACKING_ON_FLAG, -1),
                        NVL(msi.DEFECT_TRACKING_ON_FLAG, -1)
                      ) = NVL(msi.DEFECT_TRACKING_ON_FLAG, -1)
           ;
      EXCEPTION

         when NO_DATA_FOUND then
		dumm_status := INVPUOPI.mtl_log_interface_err (
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1HB',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1HB',
				err_text );

            IF dumm_status < 0 THEN
               raise LOGGING_ERR ;
            END IF;

            update mtl_system_items_interface msii
            set process_flag = 3
            where msii.transaction_id = cr.transaction_id;

      END;  /* MASTER_CHILD_1HB */

      BEGIN  /* MASTER_CHILD_1HC */

         SELECT  inventory_item_id
           INTO  msicount
         FROM  mtl_system_items_b  msi
         WHERE  msi.inventory_item_id = cr.III
           AND  msi.organization_id = cr.MORGID

           AND  DECODE( A_EVENT_FLAG,
                        x_true, NVL(cr.EVENT_FLAG, -1),
                        NVL(msi.EVENT_FLAG, -1)
                      ) = NVL(msi.EVENT_FLAG, -1)

           AND  DECODE( A_ELECTRONIC_FLAG,
                        x_true, NVL(cr.ELECTRONIC_FLAG, -1),
                        NVL(msi.ELECTRONIC_FLAG, -1)
                      ) = NVL(msi.ELECTRONIC_FLAG, -1)

           AND  DECODE( A_DOWNLOADABLE_FLAG,
                        x_true, NVL(cr.DOWNLOADABLE_FLAG, -1),
                        NVL(msi.DOWNLOADABLE_FLAG, -1)
                      ) = NVL(msi.DOWNLOADABLE_FLAG, -1)

           AND  DECODE( A_VOL_DISCOUNT_EXEMPT_FLAG,
                        x_true, NVL(cr.VOL_DISCOUNT_EXEMPT_FLAG, -1),
                        NVL(msi.VOL_DISCOUNT_EXEMPT_FLAG, -1)
                      ) = NVL(msi.VOL_DISCOUNT_EXEMPT_FLAG, -1)

           AND  DECODE( A_COUPON_EXEMPT_FLAG,
                        x_true, NVL(cr.COUPON_EXEMPT_FLAG, -1),
                        NVL(msi.COUPON_EXEMPT_FLAG, -1)
                      ) = NVL(msi.COUPON_EXEMPT_FLAG, -1)
           ;
      EXCEPTION

         when NO_DATA_FOUND then
		dumm_status := INVPUOPI.mtl_log_interface_err (
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1HC',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1HC',
				err_text );

            IF dumm_status < 0 THEN
               raise LOGGING_ERR ;
            END IF;

            update mtl_system_items_interface msii
            set process_flag = 3
            where msii.transaction_id = cr.transaction_id;

      END;  /* MASTER_CHILD_1HC */

      BEGIN  /* MASTER_CHILD_1HD */

         SELECT  inventory_item_id
           INTO  msicount
         FROM  mtl_system_items_b  msi
         WHERE  msi.inventory_item_id = cr.III
           AND  msi.organization_id = cr.MORGID

           AND  DECODE( A_COMMS_NL_TRACKABLE_FLAG,
                        x_true, NVL(cr.COMMS_NL_TRACKABLE_FLAG, -1),
                        NVL(msi.COMMS_NL_TRACKABLE_FLAG, -1)
                      ) = NVL(msi.COMMS_NL_TRACKABLE_FLAG, -1)

           AND  DECODE( A_ASSET_CREATION_CODE,
                        x_true, NVL(cr.ASSET_CREATION_CODE, -1),
                        NVL(msi.ASSET_CREATION_CODE, -1)
                      ) = NVL(msi.ASSET_CREATION_CODE, -1)

           AND  DECODE( A_COMMS_ACTIVATION_REQD_FLAG,
                        x_true, NVL(cr.COMMS_ACTIVATION_REQD_FLAG, -1),
                        NVL(msi.COMMS_ACTIVATION_REQD_FLAG, -1)
                      ) = NVL(msi.COMMS_ACTIVATION_REQD_FLAG, -1)

           AND  DECODE( A_ORDERABLE_ON_WEB_FLAG,
                        x_true, NVL(cr.ORDERABLE_ON_WEB_FLAG, -1),
                        NVL(msi.ORDERABLE_ON_WEB_FLAG, -1)
                      ) = NVL(msi.ORDERABLE_ON_WEB_FLAG, -1)

           AND  DECODE( A_BACK_ORDERABLE_FLAG,
                        x_true, NVL(cr.BACK_ORDERABLE_FLAG, -1),
                        NVL(msi.BACK_ORDERABLE_FLAG, -1)
                      ) = NVL(msi.BACK_ORDERABLE_FLAG, -1)
           ;

      EXCEPTION

         when NO_DATA_FOUND then
		dumm_status := INVPUOPI.mtl_log_interface_err (
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1HD',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1HD',
				err_text );

            IF dumm_status < 0 THEN
               raise LOGGING_ERR ;
            END IF;

            update mtl_system_items_interface msii
            set process_flag = 3
            where msii.transaction_id = cr.transaction_id;

      END;  /* MASTER_CHILD_1HD */

      BEGIN  /* MASTER_CHILD_1IA */

         SELECT  inventory_item_id
           INTO  msicount
         FROM  mtl_system_items_b  msi
         WHERE  msi.inventory_item_id = cr.III
           AND  msi.organization_id = cr.MORGID

           AND  DECODE( A_DIMENSION_UOM_CODE,
                        x_true, NVL(cr.DIMENSION_UOM_CODE, -1),
                        NVL(msi.DIMENSION_UOM_CODE, -1)
                      ) = NVL(msi.DIMENSION_UOM_CODE, -1)

           AND  DECODE( A_UNIT_LENGTH,
                        x_true, NVL(cr.UNIT_LENGTH, -1),
                        NVL(msi.UNIT_LENGTH, -1)
                      ) = NVL(msi.UNIT_LENGTH, -1)

           AND  DECODE( A_UNIT_WIDTH,
                        x_true, NVL(cr.UNIT_WIDTH, -1),
                        NVL(msi.UNIT_WIDTH, -1)
                      ) = NVL(msi.UNIT_WIDTH, -1)

           AND  DECODE( A_UNIT_HEIGHT,
                        x_true, NVL(cr.UNIT_HEIGHT, -1),
                        NVL(msi.UNIT_HEIGHT, -1)
                      ) = NVL(msi.UNIT_HEIGHT, -1)

           AND  DECODE( A_BULK_PICKED_FLAG,
                        x_true, NVL(cr.BULK_PICKED_FLAG, -1),
                        NVL(msi.BULK_PICKED_FLAG, -1)
                      ) = NVL(msi.BULK_PICKED_FLAG, -1)

           AND  DECODE( A_LOT_STATUS_ENABLED,
                        x_true, NVL(cr.LOT_STATUS_ENABLED, -1),
                        NVL(msi.LOT_STATUS_ENABLED, -1)
                      ) = NVL(msi.LOT_STATUS_ENABLED, -1)

           AND  DECODE( A_DEFAULT_LOT_STATUS_ID,
                        x_true, NVL(cr.DEFAULT_LOT_STATUS_ID, -1),
                        NVL(msi.DEFAULT_LOT_STATUS_ID, -1)
                      ) = NVL(msi.DEFAULT_LOT_STATUS_ID, -1)
           ;
      EXCEPTION

         when NO_DATA_FOUND then
		dumm_status := INVPUOPI.mtl_log_interface_err (
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1IA',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1IA',
				err_text );

            IF dumm_status < 0 THEN
               raise LOGGING_ERR ;
            END IF;

            update mtl_system_items_interface msii
            set process_flag = 3
            where msii.transaction_id = cr.transaction_id;

      END;  /* MASTER_CHILD_1IA */

      BEGIN  /* MASTER_CHILD_1IB */

         SELECT  inventory_item_id
           INTO  msicount
         FROM  mtl_system_items_b  msi
         WHERE  msi.inventory_item_id = cr.III
           AND  msi.organization_id = cr.MORGID

           AND  DECODE( A_SERIAL_STATUS_ENABLED,
                        x_true, NVL(cr.SERIAL_STATUS_ENABLED, -1),
                        NVL(msi.SERIAL_STATUS_ENABLED, -1)
                      ) = NVL(msi.SERIAL_STATUS_ENABLED, -1)

           AND  DECODE( A_DEFAULT_SERIAL_STATUS_ID,
                        x_true, NVL(cr.DEFAULT_SERIAL_STATUS_ID, -1),
                        NVL(msi.DEFAULT_SERIAL_STATUS_ID, -1)
                      ) = NVL(msi.DEFAULT_SERIAL_STATUS_ID, -1)

           AND  DECODE( A_LOT_SPLIT_ENABLED,
                        x_true, NVL(cr.LOT_SPLIT_ENABLED, -1),
                        NVL(msi.LOT_SPLIT_ENABLED, -1)
                      ) = NVL(msi.LOT_SPLIT_ENABLED, -1)

           AND  DECODE( A_LOT_MERGE_ENABLED,
                        x_true, NVL(cr.LOT_MERGE_ENABLED, -1),
                        NVL(msi.LOT_MERGE_ENABLED, -1)
                      ) = NVL(msi.LOT_MERGE_ENABLED, -1)
           ;

      EXCEPTION

         when NO_DATA_FOUND then
		dumm_status := INVPUOPI.mtl_log_interface_err (
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1IB',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1IB',
				err_text );

            IF dumm_status < 0 THEN
               raise LOGGING_ERR ;
            END IF;

            update mtl_system_items_interface msii
            set process_flag = 3
            where msii.transaction_id = cr.transaction_id;

      END;  /* MASTER_CHILD_1IB */

      BEGIN  /* MASTER_CHILD_1IC */

         SELECT  inventory_item_id
           INTO  msicount
         FROM  mtl_system_items_b  msi
         WHERE  msi.inventory_item_id = cr.III
           AND  msi.organization_id = cr.MORGID

           AND  DECODE( A_INVENTORY_CARRY_PENALTY,
                        x_true, NVL(cr.INVENTORY_CARRY_PENALTY, -1),
                        NVL(msi.INVENTORY_CARRY_PENALTY, -1)
                      ) = NVL(msi.INVENTORY_CARRY_PENALTY, -1)

           AND  DECODE( A_OPERATION_SLACK_PENALTY,
                        x_true, NVL(cr.OPERATION_SLACK_PENALTY, -1),
                        NVL(msi.OPERATION_SLACK_PENALTY, -1)
                      ) = NVL(msi.OPERATION_SLACK_PENALTY, -1)

           AND  DECODE( A_FINANCING_ALLOWED_FLAG,
                        x_true, NVL(cr.FINANCING_ALLOWED_FLAG, -1),
                        NVL(msi.FINANCING_ALLOWED_FLAG, -1)
                      ) = NVL(msi.FINANCING_ALLOWED_FLAG, -1)
           ;
      EXCEPTION

         when NO_DATA_FOUND then
		dumm_status := INVPUOPI.mtl_log_interface_err (
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1IC',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1IC',
				err_text );

            IF dumm_status < 0 THEN
               raise LOGGING_ERR ;
            END IF;

            update mtl_system_items_interface msii
            set process_flag = 3
            where msii.transaction_id = cr.transaction_id;

      END;  /* MASTER_CHILD_1Ic */


      BEGIN  /* MASTER_CHILD_1J */

         SELECT  inventory_item_id
           INTO  msicount
         FROM  mtl_system_items_b  msi
         WHERE  msi.inventory_item_id = cr.III
           AND  msi.organization_id = cr.MORGID

           AND  DECODE( A_EAM_ITEM_TYPE,
                        x_true, NVL(cr.EAM_ITEM_TYPE, -1),
                        NVL(msi.EAM_ITEM_TYPE, -1)
                      ) = NVL(msi.EAM_ITEM_TYPE, -1)

           AND  DECODE( A_EAM_ACTIVITY_TYPE_CODE,
                        x_true, NVL(cr.EAM_ACTIVITY_TYPE_CODE, -1),
                        NVL(msi.EAM_ACTIVITY_TYPE_CODE, -1)
                      ) = NVL(msi.EAM_ACTIVITY_TYPE_CODE, -1)

           AND  DECODE( A_EAM_ACTIVITY_CAUSE_CODE,
                        x_true, NVL(cr.EAM_ACTIVITY_CAUSE_CODE, -1),
                        NVL(msi.EAM_ACTIVITY_CAUSE_CODE, -1)
                      ) = NVL(msi.EAM_ACTIVITY_CAUSE_CODE, -1)

           AND  DECODE( A_EAM_ACT_NOTIFICATION_FLAG,
                        x_true, NVL(cr.EAM_ACT_NOTIFICATION_FLAG, -1),
                        NVL(msi.EAM_ACT_NOTIFICATION_FLAG, -1)
                      ) = NVL(msi.EAM_ACT_NOTIFICATION_FLAG, -1)

           AND  DECODE( A_EAM_ACT_SHUTDOWN_STATUS,
                        x_true, NVL(cr.EAM_ACT_SHUTDOWN_STATUS, -1),
                        NVL(msi.EAM_ACT_SHUTDOWN_STATUS, -1)
                      ) = NVL(msi.EAM_ACT_SHUTDOWN_STATUS, -1)

          /* AND  DECODE( A_DUAL_UOM_CONTROL,
                        x_true, NVL(cr.DUAL_UOM_CONTROL, -1),
                        NVL(msi.DUAL_UOM_CONTROL, -1)
                      ) = NVL(msi.DUAL_UOM_CONTROL, -1) */ -- commented for bug 7567332

           AND  DECODE( A_SECONDARY_UOM_CODE,
                        x_true, NVL(cr.SECONDARY_UOM_CODE, -1),
                        NVL(msi.SECONDARY_UOM_CODE, -1)
                      ) = NVL(msi.SECONDARY_UOM_CODE, -1)

           AND  DECODE( A_DUAL_UOM_DEVIATION_HIGH,
                        x_true, NVL(cr.DUAL_UOM_DEVIATION_HIGH, -1),
                        NVL(msi.DUAL_UOM_DEVIATION_HIGH, -1)
                      ) = NVL(msi.DUAL_UOM_DEVIATION_HIGH, -1)

           AND  DECODE( A_DUAL_UOM_DEVIATION_LOW,
                        x_true, NVL(cr.DUAL_UOM_DEVIATION_LOW, -1),
                        NVL(msi.DUAL_UOM_DEVIATION_LOW, -1)
                      ) = NVL(msi.DUAL_UOM_DEVIATION_LOW, -1)

/*
           and decode(A_SERVICE_ITEM_FLAG, X_TRUE, nvl(cr.SERVICE_ITEM_FLAG,-1), nvl(msi.SERVICE_ITEM_FLAG,-1)) = nvl(msi.SERVICE_ITEM_FLAG,-1)

           AND  DECODE( A_USAGE_ITEM_FLAG,
                        x_true, NVL(cr.USAGE_ITEM_FLAG, -1),
                        NVL(msi.USAGE_ITEM_FLAG, -1)
                      ) = NVL(msi.USAGE_ITEM_FLAG, -1)
*/
           AND  DECODE( A_CONTRACT_ITEM_TYPE_CODE,
                        x_true, NVL(cr.CONTRACT_ITEM_TYPE_CODE, -1),
                        NVL(msi.CONTRACT_ITEM_TYPE_CODE, -1)
                      ) = NVL(msi.CONTRACT_ITEM_TYPE_CODE, -1)

/*           AND  DECODE( A_SUBSCRIPTION_DEPEND_FLAG,
                        x_true, NVL(cr.SUBSCRIPTION_DEPEND_FLAG, -1),
                        NVL(msi.SUBSCRIPTION_DEPEND_FLAG, -1)
                      ) = NVL(msi.SUBSCRIPTION_DEPEND_FLAG, -1)
  */         ;

      EXCEPTION

         when NO_DATA_FOUND then
		dumm_status := INVPUOPI.mtl_log_interface_err (
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1J',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1J',
				err_text );

            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;

            update mtl_system_items_interface msii
            set process_flag = 3
            where msii.transaction_id = cr.transaction_id;

      END;  /* MASTER_CHILD_1J */

      BEGIN  /* MASTER_CHILD_1K */

         SELECT  inventory_item_id
           INTO  msicount
         FROM  mtl_system_items_b  msi
         WHERE  msi.inventory_item_id = cr.III
           AND  msi.organization_id = cr.MORGID

           AND  DECODE( A_SERV_REQ_ENABLED_CODE,
                        x_true, NVL(cr.SERV_REQ_ENABLED_CODE, -1),
                        NVL(msi.SERV_REQ_ENABLED_CODE, -1)
                      ) = NVL(msi.SERV_REQ_ENABLED_CODE, -1)

           AND  DECODE( A_SERV_BILLING_ENABLED_FLAG,
                        x_true, NVL(cr.SERV_BILLING_ENABLED_FLAG, -1),
                        NVL(msi.SERV_BILLING_ENABLED_FLAG, -1)
                      ) = NVL(msi.SERV_BILLING_ENABLED_FLAG, -1)

/*           AND  DECODE( A_SERV_IMPORTANCE_LEVEL,
                        x_true, NVL(cr.SERV_IMPORTANCE_LEVEL, -1),
                        NVL(msi.SERV_IMPORTANCE_LEVEL, -1)
                      ) = NVL(msi.SERV_IMPORTANCE_LEVEL, -1)
*/
           AND  DECODE( A_PLANNED_INV_POINT_FLAG,
                        x_true, NVL(cr.PLANNED_INV_POINT_FLAG, -1),
                        NVL(msi.PLANNED_INV_POINT_FLAG, -1)
                      ) = NVL(msi.PLANNED_INV_POINT_FLAG, -1)

           AND  DECODE( A_LOT_TRANSLATE_ENABLED,
                        x_true, NVL(cr.LOT_TRANSLATE_ENABLED, -1),
                        NVL(msi.LOT_TRANSLATE_ENABLED, -1)
                      ) = NVL(msi.LOT_TRANSLATE_ENABLED, -1)

           AND  DECODE( A_DEFAULT_SO_SOURCE_TYPE,
                        x_true, NVL(cr.DEFAULT_SO_SOURCE_TYPE, -1),
                        NVL(msi.DEFAULT_SO_SOURCE_TYPE, -1)
                      ) = NVL(msi.DEFAULT_SO_SOURCE_TYPE, -1)

           AND  DECODE( A_CREATE_SUPPLY_FLAG,
                        x_true, NVL(cr.CREATE_SUPPLY_FLAG, -1),
                        NVL(msi.CREATE_SUPPLY_FLAG, -1)
                      ) = NVL(msi.CREATE_SUPPLY_FLAG, -1)

           AND  DECODE( A_SUBSTITUTION_WINDOW_CODE,
                        x_true, NVL(cr.SUBSTITUTION_WINDOW_CODE, -1),
                        NVL(msi.SUBSTITUTION_WINDOW_CODE, -1)
                      ) = NVL(msi.SUBSTITUTION_WINDOW_CODE, -1)

           AND  DECODE( A_SUBSTITUTION_WINDOW_DAYS,
                        x_true, NVL(cr.SUBSTITUTION_WINDOW_DAYS, -1),
                        NVL(msi.SUBSTITUTION_WINDOW_DAYS, -1)
                      ) = NVL(msi.SUBSTITUTION_WINDOW_DAYS, -1)
           ;

      EXCEPTION

         when NO_DATA_FOUND then
            dumm_status := INVPUOPI.mtl_log_interface_err (
				cr.ORGID,
                	        user_id,
	                        login_id,
	                        prog_appid,
	                        prog_id,
	                        request_id,
				cr.TRANSACTION_ID,
				error_msg,
				'MASTER_CHILD_1K',
				'MTL_SYSTEM_ITEMS_INTERFACE',
				'INV_IOI_MASTER_CHILD_1K',
				err_text );

            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;

            update mtl_system_items_interface msii
            set process_flag = 3
            where msii.transaction_id = cr.transaction_id;

      END;  /* MASTER_CHILD_1K */

   END LOOP;

   RETURN (0);

EXCEPTION

	when LOGGING_ERR then
		return(dumm_status);

	when VALIDATE_ERR then
		dumm_status := INVPUOPI.mtl_log_interface_err(
                                l_org_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                trans_id,
                                err_text,
                                'MASTER_CHILD_1',
				'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
                                err_text);
		return(status);

	when OTHERS then
		err_text := substr('INVPVALI.validate_item_org1' || SQLERRM , 1 , 240);
		return(SQLCODE);

END validate_item_org1;


END INVPVALM;

/
