--------------------------------------------------------
--  DDL for Package OKE_DELIVERABLE_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DELIVERABLE_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: OKEDTSUS.pls 120.0 2005/05/25 17:55:05 appldev noship $ */

/*
 * Procedure Name:  Create_deliverable
 * Usage:           To create a dummy deliverable for non-item
 *                  based deliverable
 * Parameters (IN):
 *                  X_DELIVERABLE_NUM        Deliverable number
 *                  X_SOURCE_CODE            Deliverable source
 *                  X_SOURCE_HEADER_ID       Source header ID
 *                  X_SOURCE_DELIVERABLE_ID  Source deliverable ID
 *                  X_CURRENCY_CODE          Currency code
 *
 *           (OUT): X_DELIVERABLE_ID         Deliverable ID
 */

procedure CREATE_DELIVERABLE (
  X_DELIVERABLE_NUM in VARCHAR2,
  X_SOURCE_CODE in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER,
  X_CURRENCY_CODE in VARCHAR2,
  X_DELIVERABLE_ID out NOCOPY NUMBER
  );


/*
 * Procedure Name:  Default_Ship_Deliverable
 * Usage:           To get item-based deliverable information for shipping action
 *
 * Parameters (IN):
 *                  X_SOURCE_CODE            Deliverable source
 *                  X_SOURCE_HEADER_ID       Source header ID
 *                  X_SOURCE_DELIVERABLE_ID  Source deliverable ID
 *
 *           (OUT): X_SHIP_FROM_ORG_ID       Ship from org ID
 *                  X_SHIP_FROM_LOCATION_ID  Ship from location ID
 *                  X_SHIP_FROM_ORG          Ship from org
 *                  X_SHIP_FROM_LOCATION     Ship from location
 *                  X_DELIVERABLE_ID         Deliverable ID
 *                  X_QUANTITY               Quantity
 *                  X_UOM                    Uom Code
 */

procedure DEFAULT_SHIP_DELIVERABLE (
  X_SOURCE_CODE in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER,
  X_SHIP_FROM_ORG_ID out NOCOPY NUMBER,
  X_SHIP_FROM_LOCATION_ID out NOCOPY NUMBER,
  X_SHIP_FROM_ORG out NOCOPY VARCHAR2,
  X_SHIP_FROM_LOCATION out NOCOPY VARCHAR2,
  X_DELIVERABLE_ID out NOCOPY NUMBER,
  X_QUANTITY out NOCOPY NUMBER,
  X_UOM out NOCOPY VARCHAR2
  );


/*
 * Procedure Name:  Check_flag
 * Usage:           To check the ready flag in action table
 *                  for a deliverable
 * Parameters (IN):
 *                  X_DELIVERABLE_ID         Deliverable ID
 *
 *           (OUT): X_FLAG                   Ready flag
 */

procedure CHECK_FLAG (
  X_DELIVERABLE_ID in NUMBER,
  X_FLAG out NOCOPY VARCHAR2
  );


/*
 * Procedure Name:  Update_qty
 * Usage:           To update the quantity in deliverable table
 *                  for a non-item based deliverable
 * Parameters (IN):
 *                  X_QUANTITY               Quantity
 *                  X_SOURCE_CODE            Deliverable source
 *                  X_SOURCE_HEADER_ID       Source header ID
 *                  X_SOURCE_DELIVERABLE_ID  Source deliverable ID
 */

procedure UPDATE_QTY (
  X_QUANTITY in NUMBER,
  X_SOURCE_CODE in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER
  );


/*
 * Procedure Name:  Get_deliverable
 * Usage:           To get deliverable information
 * Parameters (IN):
 *                  X_SOURCE_CODE            Deliverable source
 *                  X_SOURCE_HEADER_ID       Source header ID
 *                  X_SOURCE_DELIVERABLE_ID  Source deliverable ID
 *
 *           (OUT): X_DELIVERABLE_ID         Deliverable ID
 *                  X_QUANTITY               Quantity
 *                  X_UNIT_PRICE             Unit price
 *                  X_UOM_CODE               Uom Code
 *                  X_SHIP_TO_ORG_ID         Ship to org ID
 *                  X_SHIP_TO_ORG            Ship to org
 *                  X_CURRENCY_CODE          Currency code
 */

procedure GET_DELIVERABLE (
  X_SOURCE_CODE in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER,
  X_DELIVERABLE_ID out NOCOPY NUMBER,
  X_QUANTITY out NOCOPY NUMBER,
  X_UNIT_PRICE out NOCOPY NUMBER,
  X_UOM_CODE out NOCOPY VARCHAR2,
  X_SHIP_TO_ORG_ID out NOCOPY NUMBER,
  X_SHIP_TO_ORG out NOCOPY VARCHAR2,
  X_CURRENCY_CODE out NOCOPY VARCHAR2
  );


/*
 * Procedure Name:  Get_deliverable_id
 * Usage:           To get deliverable_id
 * Parameters (IN):
 *                  X_SOURCE_CODE            Deliverable source
 *                  X_SOURCE_HEADER_ID       Source header ID
 *                  X_SOURCE_DELIVERABLE_ID  Source deliverable ID
 *
 *           (OUT): X_DELIVERABLE_ID         Deliverable ID
 *                  X_CURRENCY_CODE          Currency code
 */

procedure GET_DELIVERABLE_ID (
  X_SOURCE_CODE in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER,
  X_DELIVERABLE_ID out NOCOPY NUMBER,
  X_CURRENCY_CODE out NOCOPY VARCHAR2
  );



/*
 * Procedure Name:  Check_action
 * Usage:           To the existance of the action record
 * Parameters (IN):
 *                  X_X_SOURCE_CODE          Deliverable source
 *                  X_SOURCE_HEADER_ID       Source header ID
 *                  X_SOURCE_DELIVERABLE_ID  Source deliverable ID
 *                  X_ACTION_TYPE            Action type
 *
 *           (OUT): X_flag                   Existance flag
 */

procedure CHECK_ACTION (
  X_SOURCE_CODE in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER,
  X_ACTION_TYPE in VARCHAR2,
  X_FLAG out NOCOPY VARCHAR2
  );


/*
 * Procedure Name:  Update_currency
 * Usage:           To update the currency in deliverable table
 *                  for a non-item based deliverable
 * Parameters (IN):
 *                  X_CURRENCY_CODE          Currency code
 *                  X_SOURCE_CODE            Deliverable source
 *                  X_SOURCE_HEADER_ID       Source header ID
 *                  X_SOURCE_DELIVERABLE_ID  Source deliverable ID
 */

procedure UPDATE_CURRENCY (
  X_CURRENCY_CODE in VARCHAR2,
  X_SOURCE_CODE in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER
  );

/*
 * Procedure Name:  Update_price
 * Usage:           To update the unit price in deliverable table
 *                  for a non-item based deliverable
 * Parameters (IN):
 *                  X_UNIT_PRICE             Unit price
 *                  X_SOURCE_CODE            Deliverable source
 *                  X_SOURCE_HEADER_ID       Source header ID
 *                  X_SOURCE_DELIVERABLE_ID  Source deliverable ID
 */

procedure UPDATE_PRICE (
  X_UNIT_PRICE in NUMBER,
  X_SOURCE_CODE in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER
  );

/*
 * Procedure Name:  Insert_Row
 * Usage:           To insert a row in oke_deliverables_b
 *
 */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DELIVERABLE_ID in NUMBER,
  X_DELIVERABLE_NUMBER in VARCHAR2,
  X_SOURCE_CODE in VARCHAR2,
  X_UNIT_PRICE in NUMBER,
  X_UOM_CODE in VARCHAR2,
  X_QUANTITY in NUMBER,
  X_UNIT_NUMBER in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_LINE_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_CURRENCY_CODE in VARCHAR2,
  X_INVENTORY_ORG_ID in NUMBER,
  X_DELIVERY_DATE in DATE,
  X_ITEM_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

/*
 * Procedure Name:  Update_Row
 * Usage:           To update a row in oke_deliverables_b
 *
 */

procedure UPDATE_ROW (
  X_DELIVERABLE_ID in NUMBER,
  X_DELIVERABLE_NUMBER in VARCHAR2,
  X_SOURCE_CODE in VARCHAR2,
  X_UNIT_PRICE in NUMBER,
  X_UOM_CODE in VARCHAR2,
  X_QUANTITY in NUMBER,
  X_UNIT_NUMBER in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_LINE_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_CURRENCY_CODE in VARCHAR2,
  X_INVENTORY_ORG_ID in NUMBER,
  X_DELIVERY_DATE in DATE,
  X_ITEM_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

/*
 * Procedure Name:  Lock_Row
 * Usage:           To lock a row in oke_deliverables_b
 *
 */

procedure LOCK_ROW (
  X_DELIVERABLE_ID in NUMBER,
  X_DELIVERABLE_NUMBER in VARCHAR2,
  X_SOURCE_CODE in VARCHAR2,
  X_UNIT_PRICE in NUMBER,
  X_UOM_CODE in VARCHAR2,
  X_QUANTITY in NUMBER,
  X_UNIT_NUMBER in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_LINE_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_CURRENCY_CODE in VARCHAR2,
  X_INVENTORY_ORG_ID in NUMBER,
  X_DELIVERY_DATE in DATE,
  X_ITEM_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_COMMENTS in VARCHAR2
);

/*
 * Procedure Name:  Delete_Row
 * Usage:           To delete a row in oke_deliverables_b
 *
 */

procedure DELETE_ROW (
  X_DELIVERABLE_ID in NUMBER
);

/*
 * Procedure Name:  Add_Language
 * Usage:           Add rows to deliverable translated table
 *
 */

procedure ADD_LANGUAGE;

function Update_Expected_Date (
  p_pa_action_id    in NUMBER,
  p_expected_date  in DATE
) return Varchar2;

end OKE_DELIVERABLE_UTILS_PKG;

 

/
