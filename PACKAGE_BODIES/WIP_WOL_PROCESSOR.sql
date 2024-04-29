--------------------------------------------------------
--  DDL for Package Body WIP_WOL_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WOL_PROCESSOR" AS
/* $Header: wipwolpb.pls 115.7 2002/11/29 14:22:38 rmahidha noship $ */

--copied from $INV_TOP/src/inltwv.ppc
  PROCEDURE deriveItemRevision(p_header_id IN NUMBER) is
    BEGIN
    UPDATE wip_lpn_completions wlc
       SET last_update_date = SYSDATE,
           bom_revision =
            (SELECT NVL(wlc.bom_revision, MAX(mir.revision))
             FROM mtl_item_revisions mir
             WHERE mir.organization_id = wlc.organization_id
             AND mir.inventory_item_id = wlc.inventory_item_id
             AND mir.effectivity_date <= SYSDATE
             AND mir.effectivity_date =
              (SELECT MAX(mir2.effectivity_date)
               FROM mtl_item_revisions mir2
               WHERE mir2.organization_id = wlc.organization_id
               AND mir2.inventory_item_id = wlc.inventory_item_id
               AND mir2.effectivity_date <= SYSDATE))
     WHERE p_header_id = source_id
       AND p_header_id <> header_id
       AND bom_revision IS NULL
       AND EXISTS (
       SELECT 'X'
       FROM mtl_system_items msi
       WHERE msi.organization_id = wlc.organization_id
       AND msi.inventory_item_id = wlc.inventory_item_id
       AND msi.revision_qty_control_code = 2);
  END deriveItemRevision;

--copied from $INV_TOP/src/inltwv.ppc
  FUNCTION validateItemRevision(p_source_id IN NUMBER) return NUMBER is
    BEGIN
      UPDATE wip_lpn_completions wlc
         SET last_update_date = sysdate,
             error_code = 'HOOWAA'
       WHERE p_source_id = source_id
         AND source_id <> header_id
         AND ((bom_revision is not null
               AND ( (EXISTS (
                       SELECT 'item is under revision control'
                       FROM mtl_system_items msi
                       WHERE msi.organization_id = wlc.organization_id
                       AND msi.inventory_item_id = wlc.inventory_item_id
                       AND msi.revision_qty_control_code = 2)
                     AND NOT EXISTS (
                       SELECT 'revision is effective and not an open/hold eco'
                       FROM bom_bill_released_revisions_v bbrrv
                       WHERE bbrrv.inventory_item_id = wlc.inventory_item_id
                       AND bbrrv.organization_id = wlc.organization_id
                       AND bbrrv.revision = wlc.bom_revision
                       AND bbrrv.effectivity_date <= SYSDATE))
                    OR
                    (EXISTS (
                       SELECT 'item is not under revision control'
                       FROM mtl_system_items msi
                       WHERE msi.organization_id = wlc.organization_id
                       AND msi.inventory_item_id = wlc.inventory_item_id
                       AND msi.revision_qty_control_code = 1))))
              OR
              (bom_revision IS NULL
               AND (EXISTS (
                      SELECT 'item is under revision control'
                      FROM mtl_system_items msi
                      WHERE msi.organization_id = wlc.organization_id
                      AND msi.inventory_item_id = wlc.inventory_item_id
                      AND msi.revision_qty_control_code = 2)
                    AND NOT EXISTS (
                      SELECT 'any effective revision'
                      FROM bom_bill_released_revisions_v bbrrv
                      WHERE bbrrv.inventory_item_id = wlc.inventory_item_id
                      AND bbrrv.organization_id = wlc.organization_id
                      AND bbrrv.effectivity_date <= SYSDATE))));
    return SQL%ROWCOUNT;
  END validateItemRevision;

  FUNCTION Get_Component_ProjectSupply (
          p_organization_id   IN     NUMBER,
          p_project_id        IN     NUMBER,
          p_task_id           IN     NUMBER,
          p_wip_entity_id     IN     NUMBER,
          p_supply_sub        IN     VARCHAR2,
          p_supply_loc_id     IN OUT NOCOPY NUMBER,
          p_item_id           IN     NUMBER,
          p_org_loc_control   IN     NUMBER) RETURN BOOLEAN IS

  l_loc_id              NUMBER       := 0;
  l_peg_flag            VARCHAR2(1)  := NULL;

  CURSOR c1 IS
    SELECT end_assembly_pegging_flag
    FROM   mtl_system_items
    WHERE  inventory_item_id = p_item_id
    AND    organization_id = p_organization_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO l_peg_flag;
    CLOSE c1;

    IF ( l_peg_flag IN ( 'I' , 'X' ) ) THEN
        IF (pjm_project_locator.Check_ItemLocatorControl(p_organization_id,
            p_supply_sub, p_supply_loc_id, p_item_id, 0)) THEN

            pjm_project_locator.Get_DefaultProjectLocator(p_organization_id,
                                      p_supply_loc_id,
                                      p_project_id,
                                      p_task_id,
                                      l_loc_id);
        END IF;
    ELSE
        pjm_project_locator.Get_DefaultProjectLocator(p_organization_id,
                                  p_supply_loc_id,
                                  NULL,
                                  NULL,
                                  l_loc_id);

    END IF;

    PJM_UserProjectLocator_Pub.Get_UserProjectSupply(
        p_item_id,
        p_organization_id,
        p_wip_entity_id,
        l_loc_id);

    IF l_loc_id <> 0 THEN
        p_supply_loc_id := L_loc_id ;
    END IF;
    return(TRUE);
  END Get_Component_ProjectSupply;

/* not currently used
--copy of pjm_project_locator.Get_Flow_ProjectSupply (PJMPLOC[S,B].pls)
  FUNCTION generateLocatorIDs(p_header_id IN NUMBER,
                              p_org_id IN NUMBER,
                              p_wip_entity_id IN NUMBER,
                              p_project_id IN NUMBER,
                              p_task_id IN NUMBER) return boolean
  IS
    CURSOR c_items IS
        SELECT inventory_item_id, subinventory_code, locator_id, rowid
          FROM wip_lpn_completions
         WHERE p_header_id = source_id
           AND p_header_id <> header_id
           AND locator_id is not null
      ORDER BY operation_seq_num;

    l_proj_ref_enabled  NUMBER       := 2;
    l_org_loc_control   NUMBER       := 0;
    l_success           BOOLEAN      := TRUE;
    l_ROW_ID            ROWID;

    BEGIN
    if (p_org_id  is not null) then
       BEGIN
         SELECT NVL(mp.project_reference_enabled, 2),
                mp.stock_locator_control_code
           INTO l_proj_ref_enabled,
                l_org_loc_control
           FROM mtl_parameters mp
          WHERE mp.organization_id = p_org_id;

         EXCEPTION
           when OTHERS then
             return false;
       END;
    END if;

    if ((l_proj_ref_enabled = 1) AND (p_project_id is not null)) then
      FOR compRec IN c_items LOOP
        l_success := Get_Component_ProjectSupply(
                                    p_org_id,
                                    p_project_id,
                                    p_task_id,
                                    p_wip_entity_id,
                                    compRec.subinventory_code,
                                    compRec.locator_id,
                                    compRec.inventory_item_id,
                                    l_org_loc_control);
        if(l_success = false) then
          return false;
        else
          if (compRec.locator_id <> 0) then
            BEGIN
               UPDATE wip_lpn_completions
                  SET (locator_id, item_project_id, item_task_id) =
                      (select inventory_location_id, project_id, task_id
                         from mtl_item_locations
                        where inventory_location_id = compRec.locator_id
                          and organization_id = p_org_id)
                WHERE rowid = compRec.rowid;

               EXCEPTION
               when others then
               return false;
            END;
          END if;
        END if;
      END loop;
    END if;
    return true;
  END generateLocatorIDs;
*/
  PROCEDURE completeAssyItem(p_header_id IN  NUMBER,
                             x_err_msg    OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2)
    IS
    l_wlcRec wip_lpn_completions%ROWTYPE;
    l_errNum NUMBER;
    l_err_msg VARCHAR2(240);
    l_wip_entity_id NUMBER;

    BEGIN
    SAVEPOINT preProcessing;
    x_return_status := FND_API.G_RET_STS_ERROR;

    SELECT *
    INTO l_wlcRec
    FROM wip_lpn_completions
    WHERE header_id = p_header_id;

    --default locator ids by the item's project
/* There is no place to enter the project in the mobile
 * wol completion form. Thus there will never be an
 * associated project for the completion and this
 * check is not necessary. Note this commented code
 * has not been tested and will need to be if pjm
 * integration with the wol mobile form takes place
 *    if(l_wlcRec.item_project_id IS NOT NULL) then
 *      if(generateLocatorIDs(p_header_id,
 *                              l_wlcRec.organization_id,
 *                              l_wlcRec.wip_entity_id,
 *                              l_wlcRec.item_project_id,
 *                              l_wlcRec.item_task_id) = false) then
 *        x_err_msg :=  'locator id defaulting error ' || x_err_msg;
 *        RAISE NO_DATA_FOUND;
 *      END if;
 *    END if;
 */


    --is this necessary?
    if(validateItemRevision(l_wlcRec.header_id) <> 0) then
      x_err_msg := fnd_message.get_string('WIP', 'TRANSACTION_FAILED') || ' ' || fnd_message.get_string('WIP', 'VALIDATE_ITEMS_ERROR');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END if;

    deriveItemRevision(l_wlcRec.header_id);

    --charge resources for wol completion
    --to do this we must insert into the wip_flow_schedules table
    --which in turn inserts into the wip_entities table via a
    --trigger

    l_errNum := wip_flow_utilities.create_flow_schedule(
                        p_wip_entity_id => l_wlcRec.wip_entity_id,
                        p_organization_id => l_wlcRec.organization_id,
                        p_last_update_date => l_wlcRec.last_update_date,
                        p_last_updated_by => l_wlcRec.last_updated_by ,
                        p_creation_date => l_wlcRec.creation_date ,
                        p_created_by => l_wlcRec.created_by,
                        p_last_update_login => l_wlcRec.last_update_login,
                        p_request_id => null,
                        p_program_application_id => l_wlcRec.program_application_id,
                        p_program_id => l_wlcRec.program_id,
                        p_program_update_date => l_wlcRec.program_update_date,
                        p_primary_item_id => l_wlcRec.inventory_item_id,
                        p_class_code => l_wlcRec.accounting_class,
                        p_scheduled_start_date => l_wlcRec.transaction_date,
                        p_date_closed => null,
                        p_planned_quantity => 0,
                        p_quantity_completed => l_wlcRec.transaction_quantity,
			p_quantity_scrapped => 0,
                        p_mps_sched_comp_date => null,
                        p_mps_net_quantity => null,
                        p_bom_revision => l_wlcRec.bom_revision,
                        p_routing_revision => l_wlcRec.routing_revision,
                        p_bom_revision_date => l_wlcRec.bom_revision_date,
                        p_routing_revision_date => l_wlcRec.routing_revision_date,
                        p_alternate_bom_designator => l_wlcRec.alternate_bom_designator,
                        p_alternate_routing_designator => l_wlcRec.alternate_routing_designator,
                        p_completion_subinventory => l_wlcRec.subinventory_code,
                        p_completion_locator_id => l_wlcRec.locator_id,
                        p_demand_class => null,
                        p_scheduled_completion_date => l_wlcRec.transaction_date,
                        p_schedule_group_id => null,
                        p_build_sequence => null,
                        p_line_id => null,
                        p_project_id => null,
                        p_task_id => null,
                        p_status => 1, --open
                        p_schedule_number => 'WMALPNWOL' || TO_CHAR(l_wlcRec.header_id),
                        p_scheduled_flag => 2, --not scheduled
                        p_unit_number => l_wlcRec.end_item_unit_number,
 			p_attribute_category => null,
 			p_attribute1 => null,
 			p_attribute2 => null,
 			p_attribute3 => null,
 			p_attribute4 => null,
 			p_attribute5 => null,
 			p_attribute6 => null,
 			p_attribute7 => null,
 			p_attribute8 => null,
 			p_attribute9 => null,
 			p_attribute10 => null,
 			p_attribute11 => null,
 			p_attribute12 => null,
 			p_attribute13 => null,
 			p_attribute14 => null,
 			p_attribute15 => null);

    if(l_errNum = 0) then
      x_err_msg := fnd_message.get_string('WIP', 'TRANSACTION_FAILED');
      fnd_message.set_name('WIP', 'WIP_ERROR_FLOW_VALIDATION');
      fnd_message.set_token('ENTITY1', to_char(l_wlcRec.wip_entity_id));
      x_err_msg := x_err_msg || ' ' || fnd_message.get ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    UPDATE WIP_LPN_COMPLETIONS
       SET wip_entity_id = l_wlcRec.wip_entity_id,
           last_update_date = sysdate
     WHERE l_wlcRec.header_id = header_id
       AND l_wlcRec.header_id = source_id;

    if(not wma_rsc_chrg.Charge_Resource_Overhead(p_header_id)) then
        x_err_msg :=  fnd_message.get_string('WIP', 'TRANSACTION_FAILED') || ' ' ||  fnd_message.get_string('WIP', 'ERROR_RESOURCE_TXN');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END if;

--There is no way to enter a kanban card to
--complete against in the mobile form
    --update kanban card status
--    if(l_wlcRec.kanban_card_id is not null) then
--      INV_Kanban_PVT.Update_Card_Supply_Status(x_return_status  => l_err_msg,
--                                               p_kanban_card_id  => l_wlcRec.kanban_card_id,
--                                               p_supply_status   => INV_Kanban_PVT.G_Supply_Status_Full,
--                                               p_document_type   => INV_Kanban_PVT.G_doc_type_Flow_Schedule,
--                                               p_document_header_id => l_wlcRec.wip_entity_id);
--    END if;
--
--    if(l_err_msg <> fnd_api.G_RET_STS_SUCCESS) then
--      x_err_msg :=  'kanban error ' || l_err_msg || x_err_msg;
--      RAISE NO_DATA_FOUND;
--    END if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;--success!!

    EXCEPTION
      WHEN others Then
        --rely on throwing code to set err_msg; also x_return_status defaulted to error, so nothing
        --to do here except rollback.
        ROLLBACK to SAVEPOINT preProcessing;
  END completeAssyItem;
END wip_wol_processor;

/
