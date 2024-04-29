--------------------------------------------------------
--  DDL for Package Body WMA_SPECIAL_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_SPECIAL_LOVS" AS
/* $Header: wmaslovb.pls 115.6 2002/11/14 23:20:35 jyeung ship $ */

  /**
   * This procedure is used by SubinvLovBean as the lov statement. The OUT param
   * is a ref cursor which contains all the subinv that are valid for the given
   * item.
   */
  PROCEDURE getSubinventories(
              subinventories  OUT NOCOPY LovCurType,
              orgID           IN  NUMBER,
              itemID          IN  NUMBER,
	      trxTypeID       IN  NUMBER,
              invName         IN  VARCHAR2) IS
    restrictSubinv NUMBER;
  BEGIN
    select restrict_subinventories_code
      into restrictSubinv
    from mtl_system_items
    where organization_id = orgID
      and inventory_item_id = itemID;

    if ( restrictSubinv <> 1 ) then
    -- item is not restricted to subinventories
      OPEN subinventories FOR
        select secondary_inventory_name,
               locator_type
        from   mtl_secondary_inventories
        where  organization_id = orgID
        and    secondary_inventory_name like invName || '%'
        and    secondary_inventory_name <> 'AX_INTRANS'
	and    inv_material_status_grp.is_status_applicable(
                           NULL, -- p_wms_installed,
                           NULL,
                           trxTypeID, -- p_trx_type_id (is this same as trx_type_id?)
                           NULL,
                           NULL,
                           orgID,
                           itemID,
                           secondary_inventory_name,
                           NULL,
                           NULL,
                           NULL,
                           'Z') = 'Y'
        order by secondary_inventory_name;
    else
    -- item is restricted to subinventories
      OPEN subinventories FOR
        select misi.secondary_inventory,
               msi.locator_type
        from   mtl_item_sub_inventories misi,
               mtl_secondary_inventories msi
        where  misi.secondary_inventory = msi.secondary_inventory_name
          and  misi.organization_id = msi.organization_id
          and  misi.inventory_item_id = itemID
          and  misi.organization_id = orgID
          and  misi.secondary_inventory like invName || '%'
          and  misi.secondary_inventory <> 'AX_INTRANS'
	  and  inv_material_status_grp.is_status_applicable(
                           NULL, -- p_wms_installed,
                           NULL,
                           trxTypeID, -- p_trx_type_id (is this same as trx_type_id?)
                           NULL,
                           NULL,
                           orgID,
                           itemID,
                           msi.secondary_inventory_name,
                           NULL,
                           NULL,
                           NULL,
                           'Z') = 'Y'
        order by misi.secondary_inventory;
    end if;
  EXCEPTION
    when others then
      NULL;
  END getSubinventories;


  /**
   * This function is used by the SubinvLovBean.  It returns the appropriate
   * locator control code depending on if it's determined at the org, subinv,
   * or item level.
   */
  FUNCTION locatorControl(
                orgID     IN  NUMBER,
                subinv    IN  VARCHAR2,
                itemID    IN  NUMBER) RETURN NUMBER IS
    orgLevelCtl NUMBER;
    subinvLevelCtl NUMBER;
    itemLevelCtl NUMBER;
  BEGIN
    select stock_locator_control_code
      into orgLevelCtl
    from   mtl_parameters
    where  organization_id = orgID;

    if ( orgLevelCtl < 4 ) then -- controlled at org level
      return orgLevelCtl;
    end if;

    -- not 1, 2, 3, so it must be subinv level control
    select locator_type
      into subinvLevelCtl
    from   mtl_secondary_inventories
    where  organization_id = orgID
      and  secondary_inventory_name = subinv;

    if ( subinvLevelCtl < 4 ) then  -- subinv level
      return subinvLevelCtl;
    end if;


    -- not 1 ,2, 3, so it must be item level
    select location_control_code
      into itemLevelCtl
    from   mtl_system_items
    where  inventory_item_id = itemID
      and  organization_id = orgID;

    return itemLevelCtl;


    -- excution should never be here.  If it does, then no control.
    return 1;

  END locatorControl;

  /**
   * This procedure is used by the LocatorLovBean as the lov statement. The OUT param
   * is a ref cursor which contains all the valid locators for the given item.
   */
  PROCEDURE getLocators(
                locators  OUT NOCOPY LovCurType,
                orgID     IN  NUMBER,
                subinv    IN  VARCHAR2,
                itemID    IN  NUMBER,
		trxTypeID IN  NUMBER,
                locName   IN  VARCHAR2) IS
    restrictLocatorCode NUMBER;
  BEGIN
    select restrict_locators_code
      into restrictLocatorCode
    from   mtl_system_items
    where  inventory_item_id = itemID
      and  organization_id = orgID;

    if ( restrictLocatorCode = 2 ) then
    -- not restricted to predefined locators
      OPEN locators FOR
        select inventory_location_id,
               concatenated_segments
        from   mtl_item_locations_kfv
        where  organization_id = orgID
          and  subinventory_code = subinv
          and  concatenated_segments like locName || '%'
	  and  inv_material_status_grp.is_status_applicable(
                           NULL, -- p_wms_installed,
                           NULL,
                           trxTypeID, -- p_trx_type_id (is this same as trx_type_id?)
                           NULL,
                           NULL,
                           orgID,
                           itemID,
                           NULL,
                           inventory_location_id,
                           NULL,
                           NULL,
                           'L') = 'Y'
        order by concatenated_segments;
    else
    -- restricted to predefined locators
      OPEN locators FOR
        select msl.secondary_locator,
               milk.concatenated_segments
        from   mtl_secondary_locators msl,
               mtl_item_locations_kfv milk
        where  msl.organization_id = milk.organization_id
          and  msl.secondary_locator = milk.inventory_location_id
          and  msl.subinventory_code = milk.subinventory_code
          and  msl.inventory_item_id = itemID
          and  msl.organization_id = orgID
          and  msl.subinventory_code = subinv
          and  milk.concatenated_segments like locName || '%'
	  and  inv_material_status_grp.is_status_applicable(
                           NULL, -- p_wms_installed,
                           NULL,
                           trxTypeID, -- p_trx_type_id (is this same as trx_type_id?)
                           NULL,
                           NULL,
                           orgID,
                           itemID,
                           NULL,
                           inventory_location_id,
                           NULL,
                           NULL,
                           'L') = 'Y'
        order by milk.concatenated_segments;
    end if;
  EXCEPTION
    when others then
      NULL;
  END getLocators;

END wma_special_lovs;

/
