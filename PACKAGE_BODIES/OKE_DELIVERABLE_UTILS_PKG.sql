--------------------------------------------------------
--  DDL for Package Body OKE_DELIVERABLE_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DELIVERABLE_UTILS_PKG" as
/* $Header: OKEDTSUB.pls 120.0 2005/05/25 17:35:33 appldev noship $ */

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
  ) is

  cursor c_check_item is
    select deliverable_id
    from   oke_deliverables_b
    where  source_code = nvl(X_SOURCE_CODE, '-99')
    and    source_header_id = X_SOURCE_HEADER_ID
    --and    deliverable_number = X_DELIVERABLE_NUM
    and    source_deliverable_id = X_SOURCE_DELIVERABLE_ID;

  --l_count number;
  l_user_id number;
  l_row_id varchar2(30);
  l_project_id number;

begin

  open c_check_item;
  fetch c_check_item into x_deliverable_id;
  if (c_check_item%NOTFOUND) then

      l_user_id := fnd_global.user_id;

      select OKE_K_DELIVERABLES_S.NEXTVAL
      into X_DELIVERABLE_ID
      from dual;

      if (nvl(X_SOURCE_CODE, -99) = 'PA') then
          l_project_id := X_SOURCE_HEADER_ID;
      end if;

      OKE_DELIVERABLES_PKG.INSERT_ROW (
      X_DELIVERABLE_ID        => X_DELIVERABLE_ID,
      X_DELIVERABLE_NUMBER    => X_DELIVERABLE_NUM,
      X_SOURCE_CODE           => X_SOURCE_CODE,
      X_SOURCE_HEADER_ID      => X_SOURCE_HEADER_ID,
      X_SOURCE_DELIVERABLE_ID => X_SOURCE_DELIVERABLE_ID,
      X_CREATION_DATE         => sysdate,
      X_CREATED_BY            => l_user_id,
      X_LAST_UPDATE_DATE      => sysdate,
      X_LAST_UPDATED_BY       => l_user_id,
      X_LAST_UPDATE_LOGIN     => l_user_id,
      X_UNIT_PRICE            => 1,
      X_UOM_CODE              => null,
      X_QUANTITY              => null,
      X_UNIT_NUMBER           => null,
      X_ATTRIBUTE_CATEGORY    => null,
      X_ATTRIBUTE1            => null,
      X_ATTRIBUTE2            => null,
      X_ATTRIBUTE3            => null,
      X_ATTRIBUTE4            => null,
      X_ATTRIBUTE5            => null,
      X_ATTRIBUTE6            => null,
      X_ATTRIBUTE7            => null,
      X_ATTRIBUTE8            => null,
      X_ATTRIBUTE9            => null,
      X_ATTRIBUTE10           => null,
      X_ATTRIBUTE11           => null,
      X_ATTRIBUTE12           => null,
      X_ATTRIBUTE13           => null,
      X_ATTRIBUTE14           => null,
      X_ATTRIBUTE15           => null,
      X_ROWID                 => l_row_id,
      X_SOURCE_LINE_ID        => null,
      X_CURRENCY_CODE         => X_CURRENCY_CODE,
      X_INVENTORY_ORG_ID      => null,
      X_DELIVERY_DATE         => null,
      X_ITEM_ID               => null,
      X_DESCRIPTION           => null,
      X_COMMENTS              => null,
      X_PROJECT_ID            => l_project_id
      );
  end if;
  close c_check_item;

end CREATE_DELIVERABLE;


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
  ) is

  cursor c_ship is
    select inventory_org_id,
           l.id1 location_id,
           v.name ship_from_org,
	   l.name location_name,
	   b.deliverable_id,
         b.quantity,
         b.uom_code
    from   oke_deliverables_b b,
           hr_all_organization_units_vl v,
           okx_locations_v l
	   --po_supplier_sites_val_v l
    where  source_code = x_source_code
    and    source_header_id = x_source_header_id
    and    source_deliverable_id = x_source_deliverable_id
    and    v.organization_id(+) = b.inventory_org_id
    and    b.inventory_org_id = l.organization_id(+);
    --and    nvl(l.rfq_only_site_flag, 'N') = 'N';
begin

    open c_ship;
    fetch c_ship into x_ship_from_org_id,
                      x_ship_from_location_id,
		      x_ship_from_org,
                      x_ship_from_location,
		      x_deliverable_id,
                  x_quantity,
                  x_uom;
    close c_ship;

end DEFAULT_SHIP_DELIVERABLE;


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
  ) is

  cursor c_flag is
    select count(1)
    from   oke_deliverable_actions
    where  deliverable_id = X_DELIVERABLE_ID
    and    nvl(ready_flag, 'N') = 'Y';

  l_count NUMBER := 0;
begin

  open c_flag;
  fetch c_flag into l_count;
  close c_flag;

  if (l_count > 0) then
     X_FLAG := 'Y';
  else
     X_FLAG := 'N';
  end if;

end CHECK_FLAG;


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
  ) is
begin

  update oke_deliverables_b
  set quantity = X_QUANTITY
  where source_code = X_SOURCE_CODE
  and   source_header_id = X_SOURCE_HEADER_ID
  and   source_deliverable_id = X_SOURCE_DELIVERABLE_ID;

end UPDATE_QTY;


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
  ) is

  cursor c_id is
    select deliverable_id,
    quantity,
    unit_price,
    uom_code,
    inventory_org_id,
    v.organization_name,
    currency_code
    from   oke_deliverables_b b,
           org_organization_definitions v
    where  source_code = X_SOURCE_CODE
    and    source_header_id = X_SOURCE_HEADER_ID
    and    source_deliverable_id = X_SOURCE_DELIVERABLE_ID
    and    b.inventory_org_id = organization_id(+);
begin

  open c_id;
  fetch c_id into X_DELIVERABLE_ID,
                  X_QUANTITY,
                  X_UNIT_PRICE,
                  X_UOM_CODE,
		  X_SHIP_TO_ORG_ID,
		  X_SHIP_TO_ORG,
		  X_CURRENCY_CODE;
  close c_id;

end GET_DELIVERABLE;


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
  ) is

    cursor c_id is
    select deliverable_id,
           currency_code
    from   oke_deliverables_b b
    where  source_code = X_SOURCE_CODE
    and    source_header_id = X_SOURCE_HEADER_ID
    and    source_deliverable_id = X_SOURCE_DELIVERABLE_ID;

begin

  open c_id;
  fetch c_id into X_DELIVERABLE_ID, X_CURRENCY_CODE;
  close c_id;

end GET_DELIVERABLE_ID;


/*
 * Procedure Name:  Check_action
 * Usage:           To the existance of the action record
 * Parameters (IN):
 *                  X_SOURCE_CODE            Deliverable source
 *                  X_SOURCE_HEADER_ID       Source header ID
 *                  X_SOURCE_DELIVERABLE_ID  Source deliverable ID
 *                  X_ACTION_TYPE            Action Type
 *
 *           (OUT): X_flag                   Existance flag
 */

procedure CHECK_ACTION (
  X_SOURCE_CODE in VARCHAR2,
  X_SOURCE_HEADER_ID in NUMBER,
  X_SOURCE_DELIVERABLE_ID in NUMBER,
  X_ACTION_TYPE in VARCHAR2,
  X_FLAG out NOCOPY VARCHAR2
  ) is
  cursor c_1 is
     select 'Y'
     from   oke_deliverable_actions a,
            oke_deliverables_b b
     where  a.deliverable_id = b.deliverable_id
     and    a.action_type = X_ACTION_TYPE
     and    b.source_code = X_SOURCE_CODE
     and    b.source_deliverable_id = X_SOURCE_DELIVERABLE_ID
     and    b.source_header_id = X_SOURCE_HEADER_ID;
begin
  open c_1;
  fetch c_1 into X_FLAG;
  if (c_1%NOTFOUND) then
      X_FLAG := 'N';
  end if;
  close c_1;

end CHECK_ACTION;


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
  ) is
begin

  update oke_deliverables_b
  set   currency_code = X_CURRENCY_CODE
  where source_code = X_SOURCE_CODE
  and   source_header_id = X_SOURCE_HEADER_ID
  and   source_deliverable_id = X_SOURCE_DELIVERABLE_ID;

end UPDATE_CURRENCY;

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
  ) is
begin

  update oke_deliverables_b
  set   unit_price = X_UNIT_PRICE
  where source_code = X_SOURCE_CODE
  and   source_header_id = X_SOURCE_HEADER_ID
  and   source_deliverable_id = X_SOURCE_DELIVERABLE_ID;

end UPDATE_PRICE;


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
  X_LAST_UPDATE_LOGIN in NUMBER
 ) is
  x_ship_id         NUMBER;
  x_ship_name       PA_PROJ_ELEMENTS.NAME%TYPE;
  x_ship_due_date   DATE;
  x_proc_id         NUMBER;
  x_proc_name       PA_PROJ_ELEMENTS.NAME%TYPE;
  x_proc_due_date   DATE;
 begin
  OKE_DELIVERABLES_PKG.INSERT_ROW(
    X_ROWID => X_ROWID,
    X_DELIVERABLE_ID => X_DELIVERABLE_ID,
    X_DELIVERABLE_NUMBER => X_DELIVERABLE_NUMBER,
    X_SOURCE_CODE => X_SOURCE_CODE,
    X_UNIT_PRICE => X_UNIT_PRICE,
    X_UOM_CODE => X_UOM_CODE,
    X_QUANTITY => X_QUANTITY,
    X_UNIT_NUMBER => X_UNIT_NUMBER,
    X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1 => X_ATTRIBUTE1,
    X_ATTRIBUTE2 => X_ATTRIBUTE2,
    X_ATTRIBUTE3 => X_ATTRIBUTE3,
    X_ATTRIBUTE4 => X_ATTRIBUTE4,
    X_ATTRIBUTE5 => X_ATTRIBUTE5,
    X_ATTRIBUTE6 => X_ATTRIBUTE6 ,
    X_ATTRIBUTE7 => X_ATTRIBUTE7,
    X_ATTRIBUTE8 => X_ATTRIBUTE8,
    X_ATTRIBUTE9 => X_ATTRIBUTE9,
    X_ATTRIBUTE10 => X_ATTRIBUTE10,
    X_ATTRIBUTE11 => X_ATTRIBUTE11,
    X_ATTRIBUTE12 => X_ATTRIBUTE12,
    X_ATTRIBUTE13 => X_ATTRIBUTE13,
    X_ATTRIBUTE14 => X_ATTRIBUTE14,
    X_ATTRIBUTE15 => X_ATTRIBUTE15,
    X_SOURCE_HEADER_ID => X_SOURCE_HEADER_ID,
    X_SOURCE_LINE_ID => X_SOURCE_LINE_ID,
    X_SOURCE_DELIVERABLE_ID => X_SOURCE_DELIVERABLE_ID,
    X_PROJECT_ID => X_PROJECT_ID,
    X_CURRENCY_CODE => X_CURRENCY_CODE,
    X_INVENTORY_ORG_ID => X_INVENTORY_ORG_ID,
    X_DELIVERY_DATE => X_DELIVERY_DATE,
    X_ITEM_ID => X_ITEM_ID,
    X_DESCRIPTION => X_DESCRIPTION,
    X_COMMENTS => X_COMMENTS,
    X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
    X_CREATION_DATE => X_CREATION_DATE,
    X_CREATED_BY => X_CREATED_BY,
    X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN
  );

  PA_DELIVERABLE_UTILS.GET_SHIP_PROC_ACTN_DETAIL(
        p_dlvr_id           => X_SOURCE_DELIVERABLE_ID
       ,x_ship_id           => x_ship_id
       ,x_ship_name         => x_ship_name
       ,x_ship_due_date     => x_ship_due_date
       ,x_proc_id           => x_proc_id
       ,x_proc_name         => x_proc_name
       ,x_proc_due_date     => x_proc_due_date
  );
  IF( x_ship_id IS NOT NULL ) THEN
    INSERT INTO oke_deliverable_actions (
        ACTION_ID
      , CREATION_DATE
      , CREATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      , ACTION_TYPE
      , ACTION_NAME
      , DELIVERABLE_ID
      , PA_ACTION_ID
      , EXPECTED_DATE
      , uom_code
      , quantity
      , unit_price
      , currency_code
      , ship_from_org_id
    ) VALUES (
        oke_k_deliverables_s.NEXTVAL
      , SYSDATE
      , FND_GLOBAL.USER_ID
      , SYSDATE
      , FND_GLOBAL.USER_ID
      , FND_GLOBAL.LOGIN_ID
      , 'WSH'
      , x_ship_name
      , X_DELIVERABLE_ID
      , x_ship_id
      , x_ship_due_date
      , x_uom_code
      , x_quantity
      , x_unit_price
      , x_currency_code
      , X_INVENTORY_ORG_ID
    );
  END IF;
  IF( x_proc_id IS NOT NULL ) THEN
    INSERT INTO oke_deliverable_actions (
        ACTION_ID
      , CREATION_DATE
      , CREATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      , ACTION_TYPE
      , ACTION_NAME
      , DELIVERABLE_ID
      , PA_ACTION_ID
      , EXPECTED_DATE
      , uom_code
      , quantity
      , unit_price
      , currency_code
      , ship_to_org_id
      , destination_type_code
    ) VALUES (
        oke_k_deliverables_s.NEXTVAL
      , SYSDATE
      , FND_GLOBAL.USER_ID
      , SYSDATE
      , FND_GLOBAL.USER_ID
      , FND_GLOBAL.LOGIN_ID
      , 'REQ'
      , x_proc_name
      , X_DELIVERABLE_ID
      , x_proc_id
      , x_proc_due_date
      , x_uom_code
      , x_quantity
      , x_unit_price
      , x_currency_code
      , X_INVENTORY_ORG_ID
      , 'EXPENSE'
    );
  END IF;
end INSERT_ROW;

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
) is
Cursor c_check_inv_org(b_inv_org_id number,b_deliverable_id number) IS
select 'X' from oke_deliverable_actions where
deliverable_id=b_deliverable_id and
( ( ship_from_org_id = b_inv_org_id and action_type = 'WSH' )
or   (ship_to_org_id = b_inv_org_id and action_type = 'REQ' ) );

Cursor c_get_location(b_inv_org_id number) is
select id1
from   okx_locations_v
where  organization_id = b_inv_org_id;

l_inv_changed    Varchar2(1) :='Y';
l_location_count Number := 0;
l_location_id    number;
begin
  OKE_DELIVERABLES_PKG.UPDATE_ROW(X_DELIVERABLE_ID => X_DELIVERABLE_ID,
  X_DELIVERABLE_NUMBER => X_DELIVERABLE_NUMBER,
  X_SOURCE_CODE => X_SOURCE_CODE,
  X_UNIT_PRICE => X_UNIT_PRICE,
  X_UOM_CODE => X_UOM_CODE,
  X_QUANTITY => X_QUANTITY,
  X_UNIT_NUMBER => X_UNIT_NUMBER,
  X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1 => X_ATTRIBUTE1,
  X_ATTRIBUTE2 => X_ATTRIBUTE2,
  X_ATTRIBUTE3 => X_ATTRIBUTE3,
  X_ATTRIBUTE4 => X_ATTRIBUTE4,
  X_ATTRIBUTE5 => X_ATTRIBUTE5,
  X_ATTRIBUTE6 => X_ATTRIBUTE6 ,
  X_ATTRIBUTE7 => X_ATTRIBUTE7,
  X_ATTRIBUTE8 => X_ATTRIBUTE8,
  X_ATTRIBUTE9 => X_ATTRIBUTE9,
  X_ATTRIBUTE10 => X_ATTRIBUTE10,
  X_ATTRIBUTE11 => X_ATTRIBUTE11,
  X_ATTRIBUTE12 => X_ATTRIBUTE12,
  X_ATTRIBUTE13 => X_ATTRIBUTE13,
  X_ATTRIBUTE14 => X_ATTRIBUTE14,
  X_ATTRIBUTE15 => X_ATTRIBUTE15,
  X_SOURCE_HEADER_ID => X_SOURCE_HEADER_ID,
  X_SOURCE_LINE_ID => X_SOURCE_LINE_ID,
  X_SOURCE_DELIVERABLE_ID => X_SOURCE_DELIVERABLE_ID,
  X_PROJECT_ID => X_PROJECT_ID,
  X_CURRENCY_CODE => X_CURRENCY_CODE,
  X_INVENTORY_ORG_ID => X_INVENTORY_ORG_ID,
  X_DELIVERY_DATE => X_DELIVERY_DATE,
  X_ITEM_ID => X_ITEM_ID,
  X_DESCRIPTION => X_DESCRIPTION,
  X_COMMENTS => X_COMMENTS,
  X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
  X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
  X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN);

  if (PA_DELIVERABLE_UTILS.Is_Dlvr_Item_Based ( x_source_deliverable_id ) = 'Y') then

    update oke_deliverable_actions
    set    uom_code = x_uom_code,
           quantity = x_quantity,
           unit_price = x_unit_price,
           currency_code = x_currency_code
    where  deliverable_id = x_deliverable_id;
open c_check_inv_org(x_inventory_org_id,x_deliverable_id);
    fetch c_check_inv_org Into l_inv_changed;
    close c_check_inv_org;

    If l_inv_changed = 'Y' then
       open c_get_location(x_inventory_org_id);
       loop
        fetch c_get_location into l_location_id;
        exit when  c_get_location%notfound or l_location_count > 1;
        l_location_count := l_Location_count +1;
       end loop;
       close c_get_location;

       update oke_deliverable_actions
       set    ship_from_org_id = x_inventory_org_id,
              schedule_designator = null,
              ship_from_location_id = decode( l_location_count, 1 , l_location_id, NULL)
       where  deliverable_id = x_deliverable_id
       and    action_type = 'WSH';

       update oke_deliverable_actions
       set    ship_to_org_id = x_inventory_org_id,
              ship_to_location_id = decode( l_location_count, 1 , l_location_id, NULL),
              expenditure_organization_id = NULL
       where  deliverable_id = x_deliverable_id
       and    action_type = 'REQ';
     end if;

  else

    update oke_deliverable_actions
    set    destination_type_code = 'EXPENSE'
    where  deliverable_id = x_deliverable_id
    and    action_type = 'REQ';

  end if;

end UPDATE_ROW;

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
) is
begin
  OKE_DELIVERABLES_PKG.LOCK_ROW(X_DELIVERABLE_ID => X_DELIVERABLE_ID,
  X_DELIVERABLE_NUMBER => X_DELIVERABLE_NUMBER,
  X_SOURCE_CODE => X_SOURCE_CODE,
  X_UNIT_PRICE => X_UNIT_PRICE,
  X_UOM_CODE => X_UOM_CODE,
  X_QUANTITY => X_QUANTITY,
  X_UNIT_NUMBER => X_UNIT_NUMBER,
  X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1 => X_ATTRIBUTE1,
  X_ATTRIBUTE2 => X_ATTRIBUTE2,
  X_ATTRIBUTE3 => X_ATTRIBUTE3,
  X_ATTRIBUTE4 => X_ATTRIBUTE4,
  X_ATTRIBUTE5 => X_ATTRIBUTE5,
  X_ATTRIBUTE6 => X_ATTRIBUTE6 ,
  X_ATTRIBUTE7 => X_ATTRIBUTE7,
  X_ATTRIBUTE8 => X_ATTRIBUTE8,
  X_ATTRIBUTE9 => X_ATTRIBUTE9,
  X_ATTRIBUTE10 => X_ATTRIBUTE10,
  X_ATTRIBUTE11 => X_ATTRIBUTE11,
  X_ATTRIBUTE12 => X_ATTRIBUTE12,
  X_ATTRIBUTE13 => X_ATTRIBUTE13,
  X_ATTRIBUTE14 => X_ATTRIBUTE14,
  X_ATTRIBUTE15 => X_ATTRIBUTE15,
  X_SOURCE_HEADER_ID => X_SOURCE_HEADER_ID,
  X_SOURCE_LINE_ID => X_SOURCE_LINE_ID,
  X_SOURCE_DELIVERABLE_ID => X_SOURCE_DELIVERABLE_ID,
  X_PROJECT_ID => X_PROJECT_ID,
  X_CURRENCY_CODE => X_CURRENCY_CODE,
  X_INVENTORY_ORG_ID => X_INVENTORY_ORG_ID,
  X_DELIVERY_DATE => X_DELIVERY_DATE,
  X_ITEM_ID => X_ITEM_ID,
  X_DESCRIPTION => X_DESCRIPTION,
  X_COMMENTS => X_COMMENTS);
end LOCK_ROW;

/*
 * Procedure Name:  Delete_Row
 * Usage:           To delete a row in oke_deliverables_b
 *
 */

procedure DELETE_ROW (
  X_DELIVERABLE_ID in NUMBER
) is
begin
  OKE_DELIVERABLES_PKG.DELETE_ROW(X_DELIVERABLE_ID => X_DELIVERABLE_ID);
end DELETE_ROW;

/*
 * Procedure Name:  Add_Language
 * Usage:           Add rows to deliverable translated table
 *
 */

procedure ADD_LANGUAGE
is
begin
  OKE_DELIVERABLES_PKG.ADD_LANGUAGE;
end ADD_LANGUAGE;

function Update_Expected_Date (
  p_pa_action_id    in NUMBER,
  p_expected_date  in DATE
 ) return Varchar2 IS
 begin
  update oke_deliverable_actions set expected_date = p_expected_date
   where pa_action_id=p_pa_action_id
  ;
  if sql%rowcount <> 1 then
    return fnd_api.g_false;
   else
    return fnd_api.g_true;
  end if;
 exception
  when others then
   return fnd_api.g_false;
end;

end OKE_DELIVERABLE_UTILS_PKG;

/
