--------------------------------------------------------
--  DDL for Package Body WIP_EAMMTLPROC_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EAMMTLPROC_PRIV" as
 /* $Header: wipemppb.pls 120.9 2008/05/07 20:24:45 fli ship $ */

  procedure fillIssueParamTbl(p_compRec IN wip_mtlTempProc_grp.comp_rec_t,
                              x_params OUT NOCOPY wip_logger.param_tbl_t);


  procedure validateTxns(p_txnHdrID IN NUMBER,
                         x_returnStatus OUT NOCOPY VARCHAR2) is
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_returnStatus VARCHAR2(1);
    l_errMsg VARCHAR2(240);


  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_txnHdrID';
      l_params(1).paramValue := p_txnHdrID;
      wip_logger.entryPoint(p_procName => 'wip_eamMtlProc_priv.validateTxns',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;



    --rebuildable columns(rebuild_item_id, rebuild_serial_number, rebuild_activity_id, rebuild_job_name)
    --not allowed unless jobs is eam
    fnd_message.set_name('WIP', 'WIP_MTI_REB_COL_NOT_ALLOWED');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'WIP_ENTITY_TYPE',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and wip_entity_type <> wip_constants.eam
       and (   rebuild_item_id is not null
            or rebuild_serial_number is not null
            or rebuild_job_name is not null
            or rebuild_activity_id is not null);



    --rebuildable columns(rebuild_item_id, rebuild_serial_number, rebuild_activity_id, rebuild_job_name)
    --not allowed unless item being issued is a rebuild item
    fnd_message.set_name('WIP', 'WIP_MTI_INV_ITEM_NOT_REBLD');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'INVENTORY_ITEM_ID',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and rebuild_item_id is not null
       and not exists (select 1
                         from mtl_system_items msi
                        where msi.inventory_item_id = mti.inventory_item_id
                          and msi.organization_id = mti.organization_id
                          and msi.eam_item_type = 3);

    --rebuild item must be populated if any other columns are populated
    fnd_message.set_name('WIP', 'WIP_MTI_REB_ITEM_MISSING');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'REBUILD_ITEM_ID',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and rebuild_item_id is null
       and (   rebuild_serial_number is not null
            or rebuild_job_name is not null
            or rebuild_activity_id is not null);



    --item must exist in organization
    --item must be rebuildable
    fnd_message.set_name('WIP', 'WIP_ML_EAM_REBUILD_ITEM');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'REBUILD_ITEM_ID',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and rebuild_item_id is not null
       and not exists(select 1
                        from mtl_system_items msi, mtl_parameters mp
                       where mti.rebuild_item_id = msi.inventory_item_id
                         and msi.organization_id = mp.organization_id
						 and mp.maint_organization_id = mti.organization_id
						 and msi.eam_item_type = 3
						 );


    --item must exist in organization
    --item must be an activity
    fnd_message.set_name('WIP', 'WIP_ML_EAM_ACTIVITY');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'REBUILD_ACTIVITY_ID',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and rebuild_activity_id is not null
       and not exists(select 1
                        from mtl_system_items msi
                       where mti.rebuild_activity_id = msi.inventory_item_id
                         and mti.organization_id = msi.organization_id
                         and msi.eam_item_type = 2);



    --txn type must be issue when rebuild columns are populated
    fnd_message.set_name('WIP', 'WIP_MTI_REBUILD_TXN_TYPE');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'TRANSACTION_TYPE_ID',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and transaction_action_id <> wip_constants.isscomp_action
       and rebuild_item_id is not null;



    --primary txn qty must be 1 when transacting rebuildable items
    fnd_message.set_name('WIP', 'WIP_MTI_REBUILD_QTY');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'PRIMARY_QUANTITY',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and abs(primary_quantity) <> 1
       and exists (select 1
                     from mtl_system_items msi
                    where msi.inventory_item_id = mti.inventory_item_id
                      and msi.organization_id = mti.organization_id
                      and msi.eam_item_type = 3);



    --rebuild job name already exists in this organization
    fnd_message.set_name('WIP', 'WIP_ML_JOB_NAME');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'REBUILD_JOB_NAME',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and rebuild_item_id is not null
       and rebuild_job_name is not null
       and exists (select 1
                     from wip_entities we
                    where mti.rebuild_job_name = we.wip_entity_name
                      and mti.organization_id = we.organization_id);



--IB: anjgupta: check this Query one more time!!!!!!!!!!!!!!!!
    --activity not valid for this rebuild item
    fnd_message.set_name('WIP', 'WIP_MTI_NO_ACTIVITY_ASSOC');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'REBUILD_ACTIVITY_ID',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and rebuild_item_id is not null
       and rebuild_activity_id is not null
       and not exists (select 1
                         from mtl_eam_asset_activities meaa, csi_item_instances cii, eam_org_maint_defaults eomd
                         where mti.rebuild_activity_id = meaa.asset_activity_id
                         and meaa.activity_association_id = eomd.object_id
                         and eomd.object_type = 60
                         and eomd.organization_id = mti.organization_id
                         and cii.inventory_item_id =  mti.rebuild_item_id
                         and cii.serial_number = mti.rebuild_serial_number
                         and meaa.maintenance_object_id = cii.instance_id
                         and meaa.maintenance_object_type = 3
                         and nvl(meaa.start_date_active, mti.transaction_date - 1) <= mti.transaction_date
                         and nvl(meaa.end_date_active, mti.transaction_date + 1) >= mti.transaction_date);



    --rebuild item must be serial controlled if rebuild serial number provided
    fnd_message.set_name('WIP', 'WIP_MTI_REBUILD_SN_CNTRL');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'REBUILD_ITEM_ID',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and rebuild_item_id is not null
       and rebuild_serial_number is not null
       and not exists(select 1
                        from mtl_system_items msi, mtl_parameters mp
                       where mti.rebuild_item_id = msi.inventory_item_id
                         and mti.organization_id = mp.maint_organization_id
			 and mp.organization_id = msi.organization_id
                         and msi.serial_number_control_code in (wip_constants.full_sn,
                                                                wip_constants.dyn_rcv_sn));





    --serial number must exist in organization
    -- must be:
    --  + defined not used
    --  + issued out and in the asset's genealogy
    fnd_message.set_name('WIP', 'WIP_ML_EAM_REBUILD_SERIAL');
    l_errMsg := substrb(fnd_message.get, 1, 240);
    update mtl_transactions_interface mti
       set last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           program_application_id = fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate,
           request_id = fnd_global.conc_request_id,
           process_flag = 3,
           lock_flag = 2,
           error_code = 'REBUILD_ITEM_ID',
           error_explanation = l_errMsg
     where transaction_header_id = p_txnHdrID
       and process_flag = 1
       and transaction_source_type_id = 5
       and rebuild_item_id is not null
       and rebuild_serial_number is not null
       and not exists(select 1 --subquery verifies rebuild sn is predefined or (issued out/in stores and in the asset's genealogy)
                        from mtl_serial_numbers msn
                       where mti.rebuild_item_id = msn.inventory_item_id
                       and mti.rebuild_serial_number = msn.serial_number
                         and (   msn.current_status = 1 --defined not used
                              or (    msn.current_status in (3,4) --issued out or in stores
                                  and exists(select 1
                                               from wip_discrete_jobs wdj, mtl_object_genealogy mog,
											    csi_item_instances cii, mtl_serial_numbers msn_parent
                                              where wdj.maintenance_object_id = cii.instance_id
                                              and wdj.maintenance_object_type = 3
                                              and wdj.wip_entity_id = mti.transaction_source_id
                                              and cii.inventory_item_id = msn_parent.inventory_item_id
                                              and cii.serial_number = msn_parent.serial_number
											  and msn_parent.gen_object_id = mog.parent_object_id --work order's gen_object_id
                                              and msn.gen_object_id = mog.object_id --rebuild item's gen_object_id
                                              and mog.start_date_active <= mti.transaction_date
                                              and (mog.end_date_active is null or mog.end_date_active >= mti.transaction_date)))));

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_eamMtlProc_validateTxns',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'success',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_eamMtlProc_priv',
                              p_procedure_name => 'validateTxns',
                              p_error_text => SQLERRM);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_eamMtlProc_validateTxns',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'unexp error:' || SQLERRM,
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  end validateTxns;

  procedure processCompTxn(p_compRec IN wip_mtlTempProc_grp.comp_rec_t,
                           x_returnStatus OUT NOCOPY VARCHAR2) is
    l_params wip_logger.param_tbl_t;
    l_msgData VARCHAR2(2000);
    l_returnStatus VARCHAR2(1);
    l_maintObjID NUMBER;
    l_maintGenObjID NUMBER;
    l_maintObjType NUMBER;
    l_maintObjSrc NUMBER;
    l_errMsg VARCHAR2(2000);
    l_msgCount NUMBER;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;

    type char_tbl_t is table of varchar2(30);
    l_serialNumTbl char_tbl_t := char_tbl_t(null);

  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      fillIssueParamTbl(p_compRec => p_compRec,
                        x_params => l_params);
      wip_logger.entryPoint(p_procName => 'wip_eamMtlProc_priv.processCompTxn',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

    if(p_compRec.eamItemType is null or
    ((p_compRec.eamItemType <> wip_constants.rebuild_item_type) and
    (p_compRec.eamItemType <> 1))) then
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_eamMtlProc_priv.processCompTxn',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'success(not an eam item)',
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
      return;
    end if;
      --if the issued item is serial controlled, we need to insert a new row in the
      --assets genealogy w/the serial number.
    if(p_compRec.serialControlCode in (wip_constants.full_sn, wip_constants.dyn_rcv_sn)) then

      --rebuildable item transactions must always only involve a qty of 1.
      --we have already checked the serial_control_code so a serial number must be in MSNT
      if(p_compRec.lotControlCode = wip_constants.no_lot) then
        select fm_serial_number
          bulk collect into l_serialNumTbl
          from mtl_serial_numbers_temp
         where transaction_temp_id = p_compRec.txnTmpID;
      else
        select fm_serial_number
          bulk collect into l_serialNumTbl
          from mtl_serial_numbers_temp
         where transaction_temp_id = (select serial_transaction_temp_id
                                        from mtl_transaction_lots_temp
                                       where transaction_temp_id = p_compRec.txnTmpID);
      end if;

    --We are inside the serial number loop, hence obj_type will be 3

    select wdj.maintenance_object_id, wdj.maintenance_object_type,
           wdj.maintenance_object_source, msn.gen_object_id
      into l_maintObjID, l_maintObjType, l_maintObjSrc, l_maintGenObjID
      from wip_discrete_jobs wdj, csi_item_instances cii, mtl_serial_numbers msn
     where wdj.wip_entity_id = p_compRec.wipEntityID
     and wdj.maintenance_object_type = 3
     and wdj.maintenance_object_id = cii.instance_id
     and msn.serial_number (+) = cii.serial_number  --Modified outer join for bug 6892336
     and msn.inventory_item_id (+) = cii.inventory_item_id; --Modified outer join for bug 6892336
     --and msn.current_organization_id = cii.last_vld_organization_id;

    IF l_maintGenObjID IS NULL THEN   -- Added for bug 6892336
      l_maintGenObjID := l_maintObjID;
    END IF;

    --obj type=3 means maintenance_object_id is a instance_id in CII
    --obj src=1 to make sure WO is not from ASO.
    --this check should be moved to an EAM package.
    if(l_maintObjType = 3 and l_maintObjSrc = 1) then
      if(p_compRec.txnActionID = wip_constants.isscomp_action) then
        --insert the issued item into the asset's genealogy
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('calling create gen', l_returnStatus);
        end if;
        x_returnStatus := fnd_api.g_ret_sts_success;

        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('maintenance object id is: ' || l_maintObjID, l_returnStatus);
          wip_logger.log('maintenance object type is: ' || l_maintObjType, l_returnStatus);
          wip_logger.log('maintenance object source is: ' || l_maintObjSrc, l_returnStatus);
           wip_logger.log('gen object id is: ' || l_maintGenObjID, l_returnStatus);
        end if;

        wip_eam_genealogy_pvt.create_eam_genealogy(p_api_version => 1.0,
                                                   p_serial_number => l_serialNumTbl(1),
                                                   p_inventory_item_id => p_compRec.itemID,
                                                   p_organization_id => p_compRec.orgID,
                                                   p_parent_object_id => l_maintGenObjID,
                                                   p_start_date_active => p_compRec.txnDate,
                                                   x_return_status => x_returnStatus,
                                                   x_msg_count => l_msgCount,
                                                   x_msg_data => l_msgData);

        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('create gen returned: ' || x_returnStatus, l_returnStatus);
        end if;
      elsif(p_compRec.txnActionID = wip_constants.retcomp_action) then
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('calling update gen', l_returnStatus);
        end if;
        x_returnStatus := fnd_api.g_ret_sts_success;
        for i in 1..l_serialNumTbl.count loop
          wip_eam_genealogy_pvt.update_eam_genealogy(p_api_version => 1.0,
                                                     p_object_type => 2, /* serial number */
                                                     p_serial_number => l_serialNumTbl(i),
                                                     p_inventory_item_id => p_compRec.itemID,
                                                     p_organization_id => p_compRec.orgID,
                                                     p_genealogy_type => 5, /* asset item relationship*/
                                                     p_end_date_active => p_compRec.txnDate,
                                                     x_return_status => x_returnStatus,
                                                     x_msg_count => l_msgCount,
                                                     x_msg_data => l_msgData);
        end loop;
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('upd gen returned: ' || x_returnStatus, l_returnStatus);
        end if;
      end if;

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'genealogy failed';
        if(l_msgData is not null) then
          fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
          fnd_message.set_token('MESSAGE', l_msgData);
          fnd_msg_pub.add; --add the returned error message to the stack.
        end if;
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  end if; --For bug 6892336, we do not deal with genealogy for non-serial item

    if(p_compRec.rebuildItemID > 0 and
       p_compRec.txnActionID = wip_constants.isscomp_action) then
      ----------------------------------------------------------------------------------
      --  This call:
      --  + inserts a record into wjsi
      --  + submits the mass load concurrent request (will run when final commit occurs)
      --  + updates the genealogy (removes the rebuild item if under serial control)
      ----------------------------------------------------------------------------------
      eam_rebuild.create_rebuild_job(p_tempId => p_compRec.txnTmpID,
                                     x_retVal => x_returnStatus,
                                     x_errMsg => l_msgData);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE', l_msgData);
        fnd_msg_pub.add; --add the returned error message to the stack.
        l_errMsg := 'rebuild job creation failed';
        raise fnd_api.g_exc_unexpected_error;
      end if;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('rebuildable job creation succeeded', l_returnStatus);
      end if;
    end if;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_eamMtlProc_priv.processCompTxn',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'procedure success.',
                           x_returnStatus => l_returnStatus); --discard logging return status
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_eamMtlProc_priv.processCompTxn',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => l_errMsg,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_eamMtlProc_priv',
                              p_procedure_name => 'processCompTxn',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_eamMtlProc_priv.processCompTxn',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'unexpected error: ' || SQLERRM,
                             x_returnStatus => l_returnStatus); --discard logging return status
      end if;
  end processCompTxn;

  procedure fillIssueParamTbl(p_compRec IN wip_mtlTempProc_grp.comp_rec_t,
                       x_params OUT NOCOPY wip_logger.param_tbl_t)
  is begin
    x_params(1).paramName := 'p_compRec.wipEntityId';
    x_params(1).paramValue := p_compRec.wipEntityId;
    x_params(2).paramName := 'p_compRec.repLineID';
    x_params(2).paramValue := p_compRec.repLineID;
    x_params(3).paramName := 'p_compRec.orgID';
    x_params(3).paramValue := p_compRec.orgID;
    x_params(4).paramName := 'p_compRec.itemID';
    x_params(4).paramValue := p_compRec.itemID;
    x_params(5).paramName := 'p_compRec.opSeqNum';
    x_params(5).paramValue := p_compRec.opSeqNum;
    x_params(6).paramName := 'p_compRec.primaryQty';
    x_params(6).paramValue := p_compRec.primaryQty;
    x_params(7).paramName := 'p_compRec.txnQty';
    x_params(7).paramValue := p_compRec.txnQty;
    x_params(8).paramName := 'p_compRec.negReqFlag';
    x_params(8).paramValue := p_compRec.negReqFlag;
    x_params(9).paramName := 'p_compRec.wipSupplyType';
    x_params(9).paramValue := p_compRec.wipSupplyType;
    x_params(10).paramName := 'p_compRec.wipEntityType';
    x_params(10).paramValue := p_compRec.wipEntityType;
    x_params(11).paramName := 'p_compRec.supplySub';
    x_params(11).paramValue := p_compRec.supplySub;
    x_params(12).paramName := 'p_compRec.supplyLocID';
    x_params(12).paramValue := p_compRec.supplyLocID;
    x_params(13).paramName := 'p_compRec.txnDate';
    x_params(13).paramValue := p_compRec.txnDate;
    x_params(14).paramName := 'p_compRec.txnHdrID';
    x_params(14).paramValue := p_compRec.txnHdrID;
    x_params(15).paramName := 'p_compRec.movTxnID';
    x_params(15).paramValue := p_compRec.movTxnID;
    x_params(16).paramName := 'p_compRec.cplTxnID';
    x_params(16).paramValue := p_compRec.cplTxnID;
    x_params(17).paramName := 'p_compRec.mtlTxnID';
    x_params(17).paramValue := p_compRec.mtlTxnID;
    x_params(18).paramName := 'p_compRec.qaCollectionID';
    x_params(18).paramValue := p_compRec.qaCollectionID;
    x_params(19).paramName := 'p_compRec.deptID';
    x_params(19).paramValue := p_compRec.deptID;
    x_params(20).paramName := 'p_compRec.txnActionID';
    x_params(20).paramValue := p_compRec.txnActionID;
    x_params(21).paramName := 'p_compRec.serialControlCode';
    x_params(21).paramValue := p_compRec.serialControlCode;
    x_params(22).paramName := 'p_compRec.lotControlCode';
    x_params(22).paramValue := p_compRec.lotControlCode;
    x_params(23).paramName := 'p_compRec.eamItemType';
    x_params(23).paramValue := p_compRec.eamItemType;
    x_params(24).paramName := 'p_compRec.rebuildItemID';
    x_params(24).paramValue := p_compRec.rebuildItemID;
    x_params(25).paramName := 'p_compRec.rebuildJobName';
    x_params(25).paramValue := p_compRec.rebuildJobName;
    x_params(26).paramName := 'p_compRec.rebuildActivityID';
    x_params(26).paramValue := p_compRec.rebuildActivityID;
    x_params(27).paramName := 'p_compRec.rebuildSerialNumber';
    x_params(27).paramValue := p_compRec.rebuildSerialNumber;

  end fillIssueParamTbl;

end wip_eamMtlProc_priv;

/
