--------------------------------------------------------
--  DDL for Package Body WMA_DERIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMA_DERIVE" AS
/* $Header: wmacdrvb.pls 120.0 2005/05/25 07:40:34 appldev noship $ */

  FUNCTION getTxnMode (orgID IN NUMBER) return NUMBER IS
    txnMode NUMBER;
  begin

    select nvl(mobile_transaction_mode, wip_constants.background)
      into txnMode
      from wip_parameters
     where organization_id = orgID;

    return txnMode;
  exception
    when others then
      return wip_constants.background;
  end getTxnMode;

  /**
   * returns the next value in a database sequence
   */
  FUNCTION getNextVal (sequence IN VARCHAR2) return NUMBER is
    nextVal NUMBER;

  BEGIN
    EXECUTE IMMEDIATE 'select ' || sequence || '.nextval from dual'
    INTO nextVal;

    return nextVal;
  END getNextVal;


  /**
   * given an itemID, getItem populates the wma_common.Item structure
   * with the item information.
   */
  FUNCTION getItem (
    itemID IN NUMBER,
    orgID  IN NUMBER) return wma_common.Item
  IS
    item wma_common.Item;

    cursor getItemInfo (itemID NUMBER, orgID NUMBER) IS
      select msikfv.inventory_item_id,
             msikfv.concatenated_segments,
             msikfv.description,
             msikfv.organization_id,
             msikfv.primary_uom_code,
             msikfv.lot_control_code,
             msikfv.auto_lot_alpha_prefix,
             msikfv.start_auto_lot_number,
             msikfv.serial_number_control_code,
             msikfv.auto_serial_alpha_prefix,
             msikfv.start_auto_serial_number,
             msikfv.location_control_code,
             msikfv.revision_qty_control_code,
             msikfv.restrict_locators_code,
             msikfv.restrict_subinventories_code,
             msikfv.shelf_life_code,
             msikfv.shelf_life_days,
             msikfv.inventory_asset_flag,
             msikfv.allowed_units_lookup_code,
             msikfv.mtl_transactions_enabled_flag,
             null,                    -- projectID, assume locator is not available
             null                     -- taskID, assume locator is not available
      from mtl_system_items_kfv msikfv
      where msikfv.inventory_item_id = itemID
        and msikfv.organization_id = orgID;

  BEGIN
    open getItemInfo (itemID, orgID);
    fetch getItemInfo into item;
    if (getItemInfo%NOTFOUND) then
      item.invItemID := null;
    end if;
    close getItemInfo;

    return item;

  END getItem;


  /**
   * given an itemID and a locatorID, getItem populates the
   * wma_common.Item structure with the item information. Calling this
   * version of getItem fills in the projectID and taskID fields of
   * wma_common.Item
   */
  FUNCTION getItem (
    itemID    IN NUMBER,
    orgID     IN NUMBER,
    locatorID IN NUMBER) return wma_common.Item
  IS
    item wma_common.Item;

    cursor getItemInfo (orgID NUMBER, locatorID NUMBER) IS
      select mil.project_id,
             mil.task_id
      from mtl_item_locations mil
      where inventory_location_id = locatorID
        and organization_id = orgID;

  BEGIN
    -- get most of the item information
    item := getItem (itemID, orgID);

    -- get the extra location information
    open getItemInfo (orgID, locatorID);
    fetch getItemInfo into item.projectID, item.taskID;
    if (getItemInfo%NOTFOUND) then    -- location information does not exist
      item.projectID := null;
      item.taskID := null;
    end if;

    return item;

  END getItem;


  /**
   * getJob will fill out the structure wma_common.Job given the
   * wipEntityID. Note that the given wipEntityID should be connected
   * to a discrete job instead of a repetitive schedule.
   *
   * HISTORY:
   * 30-DEC-2004  spondalu  Bug 4093569: eAM-WMS Integration enhancements: Relaxed
   *                        entity_type condition to include eAM jobs.
   */
  Function getJob(wipEntityID NUMBER) return wma_common.Job IS
    jobInfo wma_common.Job;

    cursor theJob (wipEntityID NUMBER) IS
      select wdj.wip_entity_id,
             wdj.organization_id,
             wen.wip_entity_name,
             wdj.job_type,
             wdj.description,
             wdj.primary_item_id,
             wdj.status_type,
             wdj.wip_supply_type,
             wdj.line_id,
             wl.line_code,
             wdj.scheduled_start_date,
             wdj.scheduled_completion_date,
             wdj.start_quantity,
             wdj.quantity_completed,
             wdj.quantity_scrapped,
             wdj.completion_subinventory,
             wdj.completion_locator_id,
             wdj.project_id,
             wdj.task_id,
             wdj.end_item_unit_number
      from   wip_discrete_jobs wdj,
             wip_lines wl,
             wip_entities wen
      where  wdj.wip_entity_id = wipEntityID
        AND  wen.wip_entity_id = wipEntityID
        AND  wen.entity_type in (WIP_CONSTANTS.DISCRETE,
                                 WIP_CONSTANTS.EAM)
        AND  wl.line_id (+)= wdj.line_id
        AND  wl.organization_id (+) = wdj.organization_id;

  BEGIN
    open theJob(wipEntityID);
    fetch theJob into jobInfo;
    if (theJob%NOTFOUND) then
      jobInfo.wipEntityID := null;
    end if;
    close theJob;

    return jobInfo;

  End getJob;

  /**
   * given an Environment partially filled (the ID's must be filled),
   * derive the rest of the structure as possible depending on the
   * information available to it.
   */
  PROCEDURE deriveEnvironment (
    environment IN OUT NOCOPY wma_common.Environment)
  IS
    userName varchar2(100);
    orgCode varchar2(4);

    cursor getUser (userID NUMBER) IS
      select user_name from fnd_user
       where user_id = userID;

    cursor getOrg (orgID NUMBER) IS
      select organization_code from mtl_parameters
       where organization_id = orgID;
  BEGIN
    -- check that all ID's are not missing
    if ( environment.userID is null OR
         environment.orgID is null ) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    -- derive the user name from userID
    open getUser(environment.userID);
    fetch getUser into userName;
    close getUser;

    -- derive the org code from orgID
    open getOrg(environment.orgID);
    fetch getOrg into orgCode;
    close getOrg;

    -- assign them
    environment.userName := userName;
    environment.orgCode := orgCode;

  END deriveEnvironment;

END wma_derive;

/
