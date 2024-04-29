--------------------------------------------------------
--  DDL for Package Body CSE_PO_RECEIPT_INTO_PROJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_PO_RECEIPT_INTO_PROJECT" AS
/* $Header: CSEPORCB.pls 120.22.12000000.2 2007/07/02 09:13:05 amourya ship $ */

  l_debug varchar2(1) := NVL(fnd_profile.value('CSE_DEBUG_OPTION'),'N');

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    IF l_debug = 'Y' THEN
      cse_debug_pub.add(p_message);
      IF nvl(fnd_global.conc_request_id, -1) <> -1 THEN
        fnd_file.put_line(fnd_file.log, p_message);
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  PROCEDURE decode_message(
    p_msg_header         IN  xnp_message.msg_header_rec_type,
    p_msg_text           IN  varchar2,
    x_return_status      OUT NOCOPY varchar2,
    x_error_message      OUT NOCOPY varchar2,
    x_rcv_attributes_rec OUT NOCOPY cse_datastructures_pub.rcv_attributes_rec_type)
  IS
    l_rcv_transaction_id     number;
    l_file                   varchar2(500);
  BEGIN

    x_return_status    := g_ret_sts_success;
    x_error_message    := null;

    cse_util_pkg.set_debug;

    debug('==============================================================================');
    debug('decode_message : po_receipt_into_project :- '||to_char(sysdate,'dd-mon-yy hh24:mi:ss'));

    debug('  msg.message_id       : '||p_msg_header.message_id);
    debug('  msg.message_code     : '||p_msg_header.message_code);
    debug('  msg.creation_date    : '||p_msg_header.creation_date);

    xnp_xml_utils.decode(p_msg_text, 'RCV_TRANSACTION_ID', l_rcv_transaction_id);

    IF (nvl(l_Rcv_Transaction_Id,fnd_api.g_miss_num)  = fnd_api.g_miss_num) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    x_rcv_attributes_rec.rcv_transaction_id :=  l_rcv_transaction_id;
    x_rcv_attributes_rec.message_Id         :=  p_msg_header.message_id;

    debug('  rcv_transaction_id   : '||l_rcv_transaction_id);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      fnd_message.set_name('CSE','CSE_DECODE_MSG_ERROR');
      fnd_message.set_token('MESSAGE_ID',p_msg_header.message_id);
      fnd_message.set_token('MESSAGE_CODE',p_msg_header.message_code);
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := fnd_message.get;
  END decode_message;

  PROCEDURE cleanup_transaction_temps(
    p_rcv_transaction_id IN number)
  IS
    l_interface_transaction_id   number;
  BEGIN

    SELECT interface_transaction_id
    INTO   l_interface_transaction_id
    FROM   rcv_transactions
    WHERE  transaction_id = p_rcv_transaction_id;

    DELETE FROM mtl_serial_numbers_temp
    WHERE  transaction_temp_id = l_interface_transaction_id;

    DELETE FROM mtl_transaction_lots_temp
    WHERE  transaction_temp_id = l_interface_transaction_id;

  END cleanup_transaction_temps;

  PROCEDURE update_csi_data(
    p_rcv_attributes_rec IN         cse_datastructures_pub.rcv_attributes_rec_type,
    x_rcv_txn_tbl        OUT NOCOPY cse_datastructures_pub.rcv_txn_tbl_type,
    x_return_status      OUT NOCOPY varchar2,
    x_error_message      OUT NOCOPY varchar2)
  IS
    l_rcv_transaction_id      NUMBER;
    l_instance_rec            csi_datastructures_pub.Instance_Rec;
    l_instance_query_rec      csi_datastructures_pub.Instance_Query_Rec;
    l_api_version             NUMBER DEFAULT     1.0;
    l_commit                  varchar2(1) DEFAULT  FND_API.G_FALSE;
    l_init_msg_list           varchar2(1) DEFAULT     FND_API.G_TRUE;
    l_active_instance_only    varchar2(1) DEFAULT     FND_API.G_FALSE;
    l_resolve_id_columns      varchar2(1) DEFAULT     FND_API.G_FALSE;
    l_time_stamp              varchar2(50);
    l_object_version_number   NUMBER          := 1;
    l_sysdate                 DATE            := SYSDATE;
    l_instance_header_tbl_out csi_datastructures_pub.instance_header_tbl;
    l_error_message           varchar2(2000);
    l_return_status           varchar2(1);
    l_msg_count               NUMBER;
    l_msg_data                varchar2(2000);
    l_Party_Query_Rec         csi_datastructures_pub.party_query_rec;
    l_Account_Query_Rec       csi_datastructures_pub.party_account_query_rec;
    l_Validation_Level        NUMBER   := fnd_api.g_valid_level_full;
    l_Is_Item_Serialized      varchar2(2);
    l_ext_attrib_values_tbl   csi_datastructures_pub.extend_attrib_values_tbl;
    l_party_tbl               csi_datastructures_pub.party_tbl;
    l_account_tbl             csi_datastructures_pub.party_account_tbl;
    l_pricing_attrib_tbl      csi_datastructures_pub.pricing_attribs_tbl;
    l_org_assignments_tbl     csi_datastructures_pub.organization_units_tbl;
    l_txn_rec                 csi_datastructures_pub.transaction_rec;
    l_asset_assignment_tbl    csi_datastructures_pub.instance_asset_tbl;
    l_Transaction_Id          NUMBER;
    l_Instance_Id_Lst         csi_datastructures_pub.Id_Tbl;
    l_employee_id             NUMBER;
    l_Depreciable             varchar2(3);
    l_Transaction_Status_Code varchar2(30);
    l_Location_Id             NUMBER;
    l_Location_Type           varchar2(30);
    l_master_org              NUMBER;
    l_dflt_inst_status_id     number;

    FUNCTION Is_Expired(P_Status_Id IN NUMBER) RETURN BOOLEAN IS
      l_Status_Id NUMBER;
      CURSOR Status_Cur IS
        SELECT Instance_Status_Id
        FROM   CSI_Instance_Statuses
        WHERE  UPPER(NAME)='EXPIRED';
    BEGIN
      OPEN Status_Cur;
      FETCH Status_Cur INTO l_Status_Id;
      IF Status_Cur%NOTFOUND THEN
        l_Status_Id := NULL;
      END IF;

      CLOSE Status_Cur;
      IF l_Status_Id = p_Status_id THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;
    END Is_Expired;

  BEGIN

    x_return_status    := g_ret_sts_success;
    x_error_message    := NULL;

    debug('Inside API cse_po_receipt_into_project.update_csi_data');
    debug('  rcv_transaction_id   : '||p_rcv_attributes_rec.rcv_transaction_id);

    l_rcv_transaction_id :=  p_rcv_attributes_rec.rcv_transaction_id;

    get_rcv_transaction_details(
      p_rcv_transaction_id => l_rcv_transaction_id,
      x_rcv_txn_tbl        => x_rcv_txn_tbl,
      x_return_status      => l_return_status,
      x_error_message      => l_error_message);

    IF NOT l_return_status = g_ret_sts_success THEN
      fnd_message.set_name('CSE','CSE_RCV_VALIDATION_ERROR');
      fnd_message.set_token('RCV_TRANSACTION_ID',l_Rcv_Transaction_Id);
      RAISE fnd_api.g_exc_error;
    END IF;

    IF x_rcv_txn_tbl.count = 0 THEN
      fnd_message.set_name('CSE','CSE_RCV_DETAILS_NOT_FOUND');
      fnd_message.set_token('RCV_TRANSACTION_ID',l_Rcv_Transaction_Id);
      RAISE fnd_api.g_exc_error;
    END IF;

    IF x_rcv_txn_tbl(1).serial_number IS NULL THEN
      l_is_item_serialized :='N';
      debug('  non serialized item');
    ELSIF  NOT x_rcv_txn_tbl(1).serial_number IS NULL THEN
      debug('  serialized item');
      l_is_item_serialized :='Y';
    END IF;

    cse_util_pkg.check_depreciable(
      p_inventory_item_id => x_rcv_txn_tbl(1).Inventory_Item_Id,
      p_depreciable       => l_Depreciable);

    IF l_depreciable = 'Y' THEN
      l_transaction_status_code := cse_datastructures_pub.G_PENDING;
      debug('  depreciable item');
    ELSIF l_depreciable = 'N' THEN
      l_transaction_status_code := cse_datastructures_pub.G_COMPLETE;
      debug('  normal item');
    END IF;

    l_location_id   := cse_util_pkg.get_dflt_project_location_id;
    l_location_type := cse_util_pkg.get_location_type_code('Project');

    l_txn_rec.transaction_type_id     := cse_util_pkg.get_txn_type_id('PO_RECEIPT_INTO_PROJECT','PO');
    l_txn_rec.transaction_status_code := l_transaction_status_code;
    l_txn_rec.source_header_ref_Id    := x_rcv_txn_tbl(1).po_header_id;
    l_txn_rec.source_header_ref       := x_rcv_txn_tbl(1).po_number;
    l_txn_rec.source_line_ref_id      := x_rcv_txn_tbl(1).po_line_id;
    l_txn_rec.source_line_ref         := x_rcv_txn_tbl(1).po_line_number;
    l_txn_rec.source_dist_ref_id1     := x_rcv_txn_tbl(1).po_distribution_id;
    l_txn_rec.source_dist_ref_id2     := x_rcv_txn_tbl(1).rcv_transaction_id;
    l_txn_rec.message_id              := p_rcv_attributes_rec.message_id;
    l_txn_rec.transaction_date        := sysdate;
    l_txn_rec.source_transaction_date := x_rcv_txn_tbl(1).transaction_date;
    l_txn_rec.transaction_quantity    := x_rcv_txn_tbl(1).quantity;
    l_txn_rec.transaction_uom_code    := x_rcv_txn_tbl(1).uom;
    l_txn_rec.transacted_by           := cse_util_pkg.get_fnd_employee_id(x_rcv_txn_tbl(1).transacted_by);

    l_dflt_inst_status_id := cse_util_pkg.get_default_status_id(l_txn_rec.transaction_type_id);

    FOR i IN x_rcv_txn_tbl.FIRST .. x_rcv_txn_tbl.LAST
    LOOP

      debug('processing record # '||i);

      cse_util_pkg.get_master_organization(
        p_organization_id         => x_rcv_txn_tbl(i).Organization_Id,
        p_master_organization_id  => l_Master_Org,
        x_return_status           => l_return_status,
        x_error_message           => l_error_message);

      IF NOT l_return_status = g_ret_sts_success  THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      l_instance_query_rec                            := cse_util_pkg.init_instance_query_rec;

      IF x_rcv_txn_tbl(i).serial_number is null THEN
        l_instance_query_rec.inventory_item_id          := x_rcv_txn_tbl(i).inventory_item_id;
        l_instance_query_rec.inventory_revision         := NVL(x_rcv_txn_tbl(i).revision_id,g_miss_char);
        l_instance_query_rec.inv_master_organization_id := l_master_org;
        l_instance_query_rec.serial_number              := NVL(x_rcv_txn_tbl(i).serial_number,g_miss_char);
        l_instance_query_rec.lot_number                 := NVL(x_rcv_txn_tbl(i).lot_number,g_miss_char);
        l_instance_query_rec.pa_project_id              := x_rcv_txn_tbl(i).project_id;
        l_instance_query_rec.pa_project_task_id         := x_rcv_txn_tbl(i).task_id;
        l_instance_query_rec.instance_usage_code        := cse_datastructures_pub.g_in_process;
      ELSE
        l_instance_query_rec.inventory_item_id          := x_rcv_txn_tbl(i).inventory_item_id;
        l_instance_query_rec.serial_number              := NVL(x_rcv_txn_tbl(i).serial_number,g_miss_char);
      END IF;

      debug('Calling API csi_item_instance_pub.get_item_instances');

      csi_item_instance_pub.get_item_instances(
        p_api_version          => l_api_version,
        p_commit               => l_commit,
        p_init_msg_list        => l_init_msg_list,
        p_validation_level     => l_Validation_Level,
        p_instance_Query_rec   => l_instance_query_rec,
        p_party_query_rec      => l_Party_Query_Rec,
        p_account_query_rec    => l_account_query_rec,
        p_transaction_id       => l_transaction_id,
        p_resolve_id_columns   => l_resolve_id_columns,
        p_active_instance_only => l_Active_Instance_Only,
        x_Instance_Header_Tbl  => l_instance_header_tbl_out,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data );

      IF NOT l_return_status = g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      debug('  l_instance_header_tbl_out.count : '||l_instance_header_tbl_out.count);

      IF NOT l_IS_Item_Serialized ='Y' THEN

        IF l_instance_header_tbl_out.COUNT = 0 THEN

          l_instance_rec                            := cse_util_pkg.init_Instance_Create_Rec;
          l_instance_rec.inventory_Item_Id          := x_rcv_txn_tbl(i).Inventory_Item_Id;
          l_instance_rec.inventory_Revision         := x_rcv_txn_tbl(i).Revision_Id;
          l_instance_rec.vld_organization_Id        := x_rcv_txn_tbl(i).Organization_Id;
          l_instance_rec.inv_Master_Organization_Id := l_master_org;
          l_instance_rec.serial_number              := NULL; -- remove this later
          l_instance_rec.lot_number                 := x_rcv_txn_tbl(i).Lot_Number;
          l_instance_rec.pa_Project_Id              := x_rcv_txn_tbl(i).Project_Id;
          l_instance_rec.pa_Project_Task_Id         := x_rcv_txn_tbl(i).Task_Id;
          l_instance_rec.quantity                   := x_rcv_txn_tbl(i).Quantity;
          l_instance_rec.unit_of_measure            := x_rcv_txn_tbl(i).UOM;
          l_instance_rec.mfg_serial_number_flag     := 'N';
          l_instance_rec.location_id                := l_Location_Id;
          l_instance_rec.location_type_code         := l_Location_Type;
	  l_instance_rec.last_po_po_line_id	    := x_Rcv_txn_Tbl(i).PO_Line_Id; --5184815
          l_instance_rec.instance_usage_code        := cse_datastructures_pub.g_in_process;
          l_instance_rec.version_label              := 'AS-CREATED';
          l_instance_rec.active_start_date          := l_sysdate;
          l_instance_rec.creation_complete_flag     := 'Y';
          l_instance_rec.customer_view_flag         := 'N';
          l_instance_rec.merchant_view_flag         := 'Y';
          l_instance_rec.object_version_number      := l_object_version_number;
          l_instance_rec.vld_organization_id        := x_rcv_txn_tbl(i).organization_id;
          l_instance_rec.instance_status_id         := l_dflt_inst_status_id;

          l_ext_attrib_values_tbl := cse_util_pkg.init_ext_attrib_values_tbl;
          l_party_tbl             := cse_util_pkg.init_party_tbl;
          l_account_tbl           := cse_util_pkg.init_account_tbl;
          l_pricing_attrib_tbl    := cse_util_pkg.init_pricing_attribs_tbl;
          l_org_assignments_tbl   := cse_util_pkg.init_org_assignments_tbl;
          l_asset_assignment_tbl  := cse_util_pkg.init_asset_assignment_tbl;

          debug('Calling API csi_item_instance_pub.create_item_instance - nsrl destination create');

          csi_item_instance_pub.create_item_instance(
            p_api_version           => l_api_version,
            p_commit                => l_commit,
            p_init_msg_list         => l_init_msg_list,
            p_validation_level      => l_validation_level,
            p_instance_Rec          => l_instance_rec,
            p_ext_attrib_values_tbl => l_ext_attrib_values_tbl,
            p_party_tbl             => l_party_tbl,
            p_account_tbl           => l_account_tbl,
            p_pricing_attrib_tbl    => l_pricing_attrib_tbl,
            p_org_assignments_tbl   => l_org_assignments_tbl,
            p_asset_assignment_tbl  => l_asset_assignment_tbl,
            p_txn_rec               => l_txn_rec,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data );

          IF NOT l_return_status = g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('  instance_id          : '||l_instance_rec.instance_id);

          x_rcv_txn_tbl(i).csi_transaction_id := l_txn_rec.transaction_id;

        ELSIF l_instance_header_tbl_out.COUNT > 0 THEN

          debug('Calling API cse_util_pkg.get_destination_instance');

          cse_util_pkg.get_destination_instance(
            P_Dest_Instance_Tbl   => l_instance_header_tbl_out,
            X_Instance_Rec        => l_instance_rec,
            x_return_status       => l_return_status,
            x_error_message       => l_error_message);

          IF NOT l_return_status = g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('  dest_instance_id     : '||l_instance_rec.instance_id);

          l_instance_rec.Quantity        := l_instance_rec.Quantity + x_rcv_txn_tbl(i).Quantity;
          l_instance_rec.Active_End_Date :=  NULL;
    	  l_instance_rec.last_po_po_line_id :=  x_Rcv_txn_Tbl(i).PO_Line_Id; --5184815

          l_party_tbl.DELETE;
          l_account_tbl           := cse_util_pkg.init_account_tbl;
          l_pricing_attrib_tbl    := cse_util_pkg.init_pricing_attribs_tbl;
          l_org_assignments_tbl   := cse_util_pkg.init_org_assignments_tbl;
          l_asset_assignment_tbl  := cse_util_pkg.init_asset_assignment_tbl;
          l_ext_attrib_values_tbl := cse_util_pkg.init_ext_attrib_values_tbl;

          IF is_expired(l_instance_rec.instance_status_id) THEN
            l_instance_rec.instance_status_id := l_dflt_inst_status_id;
          END IF;

          debug('Calling API csi_item_instance_pub.update_item_instance - nsrl destination update');

          csi_item_instance_pub.update_item_instance(
            p_api_version            => l_api_version,
            p_commit                 => l_commit,
            p_validation_level       => l_Validation_Level,
            p_init_msg_list          => l_init_msg_list,
            p_instance_rec           => l_instance_rec,
            p_ext_attrib_values_tbl  => l_ext_attrib_values_tbl,
            p_party_tbl              => l_party_tbl,
            p_account_tbl            => l_account_tbl,
            p_pricing_attrib_tbl     => l_pricing_attrib_tbl,
            p_org_assignments_tbl    => l_org_assignments_tbl,
            p_txn_rec                => l_txn_rec,
            p_asset_assignment_tbl   => l_asset_assignment_tbl,
            x_instance_id_lst        => l_instance_id_lst,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data );

          IF NOT l_return_status = g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
          x_rcv_txn_tbl(i).CSI_Transaction_Id := l_txn_rec.Transaction_Id;
        END IF;

      ELSIF l_IS_Item_Serialized ='Y' THEN

        IF l_instance_header_tbl_out.COUNT = 1 THEN

          debug('  dest_instance_id     : '||l_instance_header_tbl_out(1).instance_id);

          l_instance_rec                       := cse_util_pkg.init_instance_update_rec;
          l_instance_rec.instance_id           := l_instance_header_tbl_out(1).instance_id;
          l_instance_rec.Quantity              := 1;
          l_instance_rec.last_po_po_line_id :=  x_Rcv_txn_Tbl(i).PO_Line_Id; --5184815
          l_instance_rec.Object_version_Number := l_instance_header_tbl_out(1).Object_Version_Number;
          l_instance_rec.active_end_date       := null;
          l_instance_rec.instance_usage_code   := cse_datastructures_pub.g_in_process;

          IF is_expired(l_instance_rec.instance_status_id) THEN
            l_instance_rec.instance_status_id := l_dflt_inst_status_id;
          END IF;

          l_party_tbl.DELETE;
          l_account_tbl           := cse_util_pkg.init_account_tbl;
          l_pricing_attrib_tbl    := cse_util_pkg.init_pricing_attribs_tbl;
          l_org_assignments_tbl   := cse_util_pkg.init_org_assignments_tbl;
          l_asset_assignment_tbl  := cse_util_pkg.init_asset_assignment_tbl;
          l_ext_attrib_values_tbl := cse_util_pkg.init_ext_attrib_values_tbl;

          debug('Calling API csi_item_instance_pub.update_item_instance - srl destination update');

          csi_item_instance_pub.update_item_instance(
            p_api_version            => l_api_version,
            p_commit                 => l_commit,
            p_validation_level       => l_Validation_Level,
            p_init_msg_list          => l_init_msg_list,
            p_instance_rec           => l_instance_rec,
            p_ext_attrib_values_tbl  => l_ext_attrib_values_tbl,
            p_party_tbl              => l_party_tbl,
            p_account_tbl            => l_account_tbl,
            p_pricing_attrib_tbl     => l_pricing_attrib_tbl,
            p_org_assignments_tbl    => l_org_assignments_tbl,
            p_txn_rec                => l_txn_rec,
            p_asset_assignment_tbl   => l_asset_assignment_tbl,
            x_instance_id_lst        => l_instance_id_lst,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data );

          IF NOT l_return_status = g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          x_rcv_txn_tbl(i).csi_transaction_id := l_txn_rec.transaction_id;

        ELSIF l_instance_header_tbl_out.COUNT = 0 THEN

          l_instance_rec                            := cse_util_pkg.init_instance_create_rec;
          l_instance_rec.inventory_item_id          := x_rcv_txn_tbl(i).inventory_item_id;
          l_instance_rec.inventory_revision         := x_rcv_txn_tbl(i).revision_id;
          l_instance_rec.vld_organization_id        := x_rcv_txn_tbl(i).organization_id;
          l_instance_rec.inv_master_organization_id := l_master_org;
          l_instance_rec.serial_number              := x_rcv_txn_tbl(i).serial_number;
          l_instance_rec.lot_number                 := x_rcv_txn_tbl(i).lot_number;
          l_instance_rec.pa_project_id              := x_rcv_txn_tbl(i).project_id;
          l_instance_rec.pa_project_task_id         := x_rcv_txn_tbl(i).task_id;
 	  l_instance_rec.last_po_po_line_id	    := x_Rcv_txn_Tbl(i).PO_Line_Id; --5184815
          l_instance_rec.quantity                   := 1;
          l_instance_rec.unit_of_measure            := x_rcv_txn_tbl(i).uom;
          l_instance_rec.mfg_serial_number_flag     := 'Y';
          l_instance_rec.instance_usage_code        := cse_datastructures_pub.g_in_process;
          l_instance_rec.version_label              := 'AS-CREATED';
          l_instance_rec.active_start_date          := l_sysdate;
          l_instance_rec.active_end_date            := NULL;
          l_instance_rec.creation_complete_flag     := 'Y';
          l_instance_rec.customer_view_flag         := 'N';
          l_instance_rec.merchant_view_flag         := 'Y';
          l_instance_rec.object_version_number      := l_object_version_number;
          l_instance_rec.vld_organization_id        := x_rcv_txn_tbl(i).organization_id;
          l_instance_rec.location_id                := l_location_id;
          l_instance_rec.location_type_code         := l_location_type;
          l_instance_rec.instance_status_id         := l_dflt_inst_status_id;

          l_party_tbl             := cse_util_pkg.init_party_tbl;
          l_account_tbl           := cse_util_pkg.init_account_tbl;
          l_pricing_attrib_tbl    := cse_util_pkg.init_pricing_attribs_tbl;
          l_org_assignments_tbl   := cse_util_pkg.init_org_assignments_tbl;
          l_asset_assignment_tbl  := cse_util_pkg.init_asset_assignment_tbl;
          l_ext_attrib_values_tbl := cse_util_pkg.init_ext_attrib_values_tbl;

          debug('Calling API csi_item_instance_pub.create_item_instance - srl destination create');

          csi_item_instance_pub.create_item_instance(
            p_api_version           => l_api_version,
            p_commit                => l_commit,
            p_init_msg_list         => l_init_msg_list,
            p_validation_level      => l_validation_level,
            p_instance_Rec          => l_instance_rec,
            p_ext_attrib_values_tbl => l_ext_attrib_values_tbl,
            p_party_tbl             => l_party_tbl,
            p_account_tbl           => l_account_tbl,
            p_pricing_attrib_tbl    => l_pricing_attrib_tbl,
            p_org_assignments_tbl   => l_org_assignments_tbl,
            p_asset_assignment_tbl  => l_asset_assignment_tbl,
            p_txn_rec               => l_txn_rec,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data );

          IF NOT l_return_status = g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;

          debug('  instance_id           : '||l_instance_rec.instance_id);

          x_rcv_txn_tbl(i).csi_transaction_id := l_txn_rec.transaction_id;

        END IF;

        BEGIN
          IF x_rcv_txn_tbl(i).serial_number IS NOT NULL THEN
            UPDATE mtl_serial_numbers
            SET    current_status       = 4,
                   last_txn_source_name = 'CSE_PO_RECEIPT',
                   last_txn_source_id   = x_rcv_txn_tbl(i).rcv_transaction_id
            WHERE  inventory_item_id    = x_rcv_txn_tbl(i).inventory_item_id
            AND    serial_number        = x_rcv_txn_tbl(i).serial_number;
          END IF;
        END;

      END IF; -- serial
    END LOOP;

    debug('  csi_transaction_id   : '||l_txn_rec.transaction_id);
    debug('update_csi_data successful. rcv_transaction_id : '||p_rcv_attributes_rec.rcv_transaction_id);
    commit;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := g_ret_sts_error;
      x_error_message := nvl(l_error_message, cse_util_pkg.dump_error_stack);
    WHEN OTHERS THEN
      fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
      fnd_message.set_token('ERR_MSG', SQLERRM);
      x_error_message := fnd_message.get;
      x_return_status := g_ret_sts_unexp_error;
  END update_csi_data;

  PROCEDURE get_rcv_transaction_details(
    p_rcv_transaction_id IN  NUMBER,
    x_rcv_txn_tbl        OUT NOCOPY  cse_datastructures_pub.rcv_txn_tbl_type,
    x_return_status      OUT NOCOPY  varchar2,
    x_error_message      OUT NOCOPY  varchar2)
  IS

    l_lot_code           number;
    l_serial_code        number;

    l_rcv_txn_rec        cse_datastructures_pub.rcv_txn_rec_type;
    l_rcv_txn_tbl        cse_datastructures_pub.rcv_txn_tbl_type;
    ind                  binary_integer := 0;

    CURSOR rcvtxn_cur(p_rcv_txn_id IN NUMBER) IS
      SELECT rt.transaction_id           transaction_id,
             rt.transaction_date         transaction_date,
             rt.transaction_type         transaction_type,
             rt.destination_type_code    destination_type_code,
             rt.employee_id              transacted_by,
             rt.organization_id          organization_id,
             rt.quantity                 quantity,
             rt.po_header_id             po_header_id,
             rt.po_line_id               po_line_id,
             rt.po_distribution_id       po_distribution_id,
             rt.uom_code                 txn_uom_code,
             rt.vendor_id                po_vendor_id,
             rt.shipment_header_id       shipment_header_id,
             rt.shipment_line_id         shipment_line_id,
             rt.interface_transaction_id interface_transaction_id,
             pda.project_id              project_id,
             pda.task_id                 task_id,
             pda.rate                    rate,
             pda.org_id                  org_id,
             plla.price_override         price_override,
             pla.item_id                 item_id,
             pla.item_revision           item_revision,
             to_char(pla.line_num)       po_line_number,
             pha.segment1                po_number
      FROM   rcv_transactions        rt,
             po_distributions_all    pda,
             po_line_locations_all   plla,
             po_lines_all            pla,
             po_headers_all          pha
      WHERE  rt.transaction_id          = p_rcv_txn_id
      AND    rt.po_distribution_id      = pda.po_distribution_id
      AND    rt.po_line_location_id     = plla.line_location_id
      AND    rt.po_line_id              = pla.po_line_id
      AND    rt.po_header_id            = pha.po_header_id;

    CURSOR lotsrl_cur(p_interface_transaction_id in number, p_quantity in number) IS
      SELECT mtlt.lot_number         lot_number,
             msn.serial_number       serial_number,
             decode(mtlt.serial_transaction_temp_id,null,nvl(mtlt.transaction_quantity,p_quantity),1) quantity
      FROM   mtl_transaction_lots_temp mtlt,
             mtl_serial_numbers        msn
      WHERE  mtlt.transaction_temp_id = p_interface_transaction_id
      AND    msn.line_mark_id(+)  = mtlt.serial_transaction_temp_id;

    CURSOR srl_cur(p_interface_transaction_id in number) IS
      SELECT msn.serial_number   serial_number
      FROM   mtl_serial_numbers  msn
      WHERE  EXISTS (
        SELECT 'x' FROM mtl_serial_numbers_temp msnt
        WHERE   msnt.transaction_temp_id = p_interface_transaction_id
        AND     msnt.transaction_temp_id = msn.line_mark_id) ;

  BEGIN

    x_return_status := g_ret_sts_success;
    x_error_message := null;

    debug('Inside API cse_po_receipt_into_project.get_rcv_transaction_details');
    debug('  rcv_transaction_id   : '||p_rcv_transaction_id);

    FOR rcvtxn_rec IN rcvtxn_cur(p_rcv_transaction_id)
    LOOP

      mo_global.set_policy_context('S', rcvtxn_rec.org_id);

      debug('  po_number            : '||rcvtxn_rec.po_number);
      debug('  po_line_number       : '||rcvtxn_rec.po_line_number);
      debug('  po_header_id         : '||rcvtxn_rec.po_header_id);
      debug('  po_line_id           : '||rcvtxn_rec.po_line_id);
      debug('  po_distribution_id   : '||rcvtxn_rec.po_distribution_id);
      debug('  po_vendor_id         : '||rcvtxn_rec.po_vendor_id);
      debug('  project_id           : '||rcvtxn_rec.project_id);
      debug('  task_id              : '||rcvtxn_rec.task_id);
      debug('  quantity             : '||rcvtxn_rec.quantity);
      debug('  uom_code             : '||rcvtxn_rec.txn_uom_code);
      debug('  intf_transaction_id  : '||rcvtxn_rec.interface_transaction_id);

      SELECT primary_uom_code,
             serial_number_control_code,
             lot_control_code
      INTO   l_rcv_txn_rec.uom,
             l_serial_code,
             l_lot_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = rcvtxn_rec.item_id
      AND    organization_id   = rcvtxn_rec.organization_id;

      l_rcv_txn_rec.rcv_transaction_id := rcvtxn_rec.transaction_id;
      l_rcv_txn_rec.temp_txn_id        := rcvtxn_rec.interface_transaction_id;
      l_rcv_txn_rec.organization_id    := rcvtxn_rec.organization_id;
      l_rcv_txn_rec.po_header_id       := rcvtxn_rec.po_header_id;
      l_rcv_txn_rec.po_number          := rcvtxn_rec.po_number;
      l_rcv_txn_rec.po_line_id         := rcvtxn_rec.po_line_id;
      l_rcv_txn_rec.po_line_number     := rcvtxn_rec.po_line_number;
      l_rcv_txn_rec.po_distribution_id := rcvtxn_rec.po_distribution_id;
      l_rcv_txn_rec.project_id         := rcvtxn_rec.project_id;
      l_rcv_txn_rec.task_id            := rcvtxn_rec.task_id;
      l_rcv_txn_rec.transacted_by      := rcvtxn_rec.transacted_by;
      l_rcv_txn_rec.transaction_date   := rcvtxn_rec.transaction_date;
      l_rcv_txn_rec.inventory_item_id  := rcvtxn_rec.item_id;
      l_rcv_txn_rec.revision_id        := rcvtxn_rec.item_revision;
      l_rcv_txn_rec.lot_number         := null;
      l_rcv_txn_rec.serial_number      := null;
      l_rcv_txn_rec.quantity           := rcvtxn_rec.quantity;
      l_rcv_txn_rec.amount             := rcvtxn_rec.price_override*nvl(rcvtxn_rec.rate,1)* rcvtxn_rec.quantity;
      l_rcv_txn_rec.po_vendor_id       := rcvtxn_rec.po_vendor_id;
      l_rcv_txn_rec.transaction_type   := rcvtxn_rec.transaction_type;
      l_rcv_txn_rec.destination_type_code := rcvtxn_rec.destination_type_code;

      IF rcvtxn_rec.project_id IS NOT NULL THEN

        IF l_lot_code <> 1 THEN
          FOR lotsrl_rec IN lotsrl_cur(rcvtxn_rec.interface_transaction_id, rcvtxn_rec.quantity)
          LOOP
            ind := ind + 1;
            l_rcv_txn_tbl(ind) := l_rcv_txn_rec;
            l_rcv_txn_tbl(ind).lot_number    := lotsrl_rec.lot_number;
            l_rcv_txn_tbl(ind).serial_number := lotsrl_rec.serial_number;
            l_rcv_txn_tbl(ind).quantity      := lotsrl_rec.quantity;
            l_rcv_txn_tbl(ind).amount   := rcvtxn_rec.price_override* nvl(rcvtxn_rec.Rate,1)* lotsrl_rec.quantity;
          END LOOP;
        ELSIF l_serial_code <> 1 and l_lot_code = 1 THEN
          FOR srl_rec IN srl_cur(rcvtxn_rec.interface_transaction_id)
          LOOP
            ind := ind + 1;
            l_rcv_txn_tbl(ind) := l_rcv_txn_rec;
            l_rcv_txn_tbl(ind).lot_number    := null;
            l_rcv_txn_tbl(ind).serial_number := srl_rec.serial_number;
            l_rcv_txn_tbl(ind).quantity      := 1;
            l_rcv_txn_tbl(ind).amount        := rcvtxn_rec.price_override* nvl(rcvtxn_rec.rate,1);
          END LOOP;
        ELSE -- non serial
          ind := ind + 1;
          l_rcv_txn_tbl(ind) := l_rcv_txn_rec;
        END IF;
      END IF;
    END LOOP;

    debug('rcv_txn_tbl.COUNT      : '||l_rcv_txn_tbl.count);

    IF l_rcv_txn_tbl.count > 0 THEN
      FOR ind IN l_rcv_txn_tbl.FIRST .. l_rcv_txn_tbl.LAST
      LOOP
        debug('record # '||ind);
        debug('  serial_number        : '||l_rcv_txn_tbl(ind).serial_number);
        debug('  lot_number           : '||l_rcv_txn_tbl(ind).lot_number);
        debug('  quantity             : '||l_rcv_txn_tbl(ind).quantity);
        debug('  amount               : '||l_rcv_txn_tbl(ind).amount);
      END LOOP;
    END IF;

    x_rcv_txn_tbl := l_rcv_txn_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_error_message := fnd_message.get;
  END get_rcv_transaction_details;

  PROCEDURE knock_the_commitment(
    p_rcv_transaction_id   IN         number,
    x_return_status        OUT NOCOPY varchar2)
  IS
    l_sql_stmt             varchar2(540);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_sql_stmt := 'UPDATE rcv_receiving_sub_ledger '||
                  'SET    pa_addition_flag   = ''Y'''||
                  'WHERE  rcv_transaction_id = :rcv_txn_id ';
    BEGIN
      execute immediate l_sql_stmt using p_rcv_transaction_id;
      UPDATE rcv_transactions
	SET    pa_addition_flag = 'Y'
 	WHERE  transaction_id   = p_rcv_transaction_id;
    EXCEPTION
      WHEN others THEN
        UPDATE rcv_transactions
        SET    pa_addition_flag = 'Y'
        WHERE  transaction_id   = p_rcv_transaction_id;
    END;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_success;
  END knock_the_commitment;

  PROCEDURE interface_nl_to_pa(
    p_rcv_txn_tbl   IN  cse_datastructures_pub.Rcv_Txn_Tbl_Type,
    x_return_status OUT NOCOPY varchar2,
    x_error_message OUT NOCOPY varchar2)
  IS
    l_Item_Name                varchar2(40);
    l_project_name             varchar2(150);
    l_Task_Number              varchar2(100);
    l_nl_pa_interface_tbl      pa_interface_tbl_type;
    l_Transaction_Source       varchar2(30);
    l_Transaction_Type         varchar2(50);
    l_Batch_Name               varchar2(50);
    l_Cr_Code_Combination_Id   NUMBER DEFAULT NULL;
    l_Dr_Code_Combination_Id   NUMBER DEFAULT NULL;
    l_Price_Var_CC_Id          NUMBER DEFAULT NULL;
    l_User_Id                  NUMBER;
    l_System_Linkage           varchar2(3) := 'VI';
    l_return_status            varchar2(1);
    l_error_message            varchar2(2000);
    l_Sysdate                  DATE := SYSDATE;
    l_Expenditure_Ending_Date  DATE;
    l_Depreciable              varchar2(3);
    l_Vendor_Num               varchar2(50);
    l_vendor_id                number;
    l_Operating_Unit           NUMBER;

  CURSOR item_name_cur(p_item_id IN number, p_org_id IN number) IS
    SELECT concatenated_segments
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = p_item_id
    AND    organization_id = p_org_id;

  CURSOR project_name_cur(p_project_id IN  NUMBER) IS
    SELECT segment1
    FROM   pa_projects_all
    WHERE  project_id = p_project_id;

  CURSOR Task_Number_Cur(P_Project_Id IN NUMBER, P_Task_Id IN NUMBER) IS
    SELECT pt.task_number
    FROM   pa_tasks  pt
    WHERE  pt.task_id = p_task_id
    AND    pt.project_id = p_project_id;

  CURSOR  vendor_cur(p_po_header_id IN number) IS
    SELECT pv.vendor_id, pv.segment1
    FROM   po_vendors pv, po_headers_all ph
    WHERE  ph.po_header_id = p_po_header_id
    AND    pv.vendor_id    = ph.vendor_id;

  CURSOR  Exp_Details_Cur(P_PO_Distribution_ID IN NUMBER) IS
    SELECT pod.Org_Id                       Org_ID,
           SYSDATE                          Expenditure_Item_Date,
           pod.expenditure_type             Expenditure_Type,
           pod.expenditure_organization_id  Expenditure_Org_Id,
           pod.code_combination_id          Dr_CC_Id,
           hr.Name                 Expenditure_Organization_Name
    FROM   po_distributions_all   pod,
           hr_organization_units  hr
    WHERE  pod.po_distribution_id = p_po_distribution_id
    AND    hr.organization_id = pod.Expenditure_Organization_Id;

  Exp_Details_Rec Exp_Details_Cur%ROWTYPE;

  CURSOR  cr_cc_cur(p_org_id in number) IS
    SELECT accts_pay_code_combination_id
    FROM   ap_system_parameters_all
    WHERE  org_id = p_org_id;

  BEGIN

    x_return_status := g_ret_sts_success;

    debug('Inside API cse_po_receipt_into_project.interface_nl_to_pa');

    IF p_rcv_txn_tbl.COUNT = 0 THEN
      fnd_message.set_name('CSE','CSE_RCV_TXN_TBL_NO_ROWS');
      fnd_msg_pub.add;
      RAISE FND_API.g_Exc_Error;
    END IF;

    l_user_id := fnd_global.user_id ;

    OPEN  Project_Name_Cur(p_rcv_txn_tbl(1).Project_Id);
    FETCH Project_Name_Cur  INTO  l_Project_Name;
    CLOSE Project_Name_Cur;

    debug('  project_name         : '||l_project_name);

    OPEN  Task_Number_Cur(p_rcv_txn_tbl(1).Project_Id, p_rcv_txn_tbl(1).Task_Id);
    FETCH Task_Number_Cur  INTO  l_Task_Number;
    CLOSE Task_Number_Cur;

    debug('  task_number          : '||l_task_number);

    OPEN  Exp_Details_Cur(p_rcv_txn_tbl(1).po_distribution_id);
    FETCH Exp_Details_Cur  INTO  Exp_Details_Rec;
    CLOSE Exp_Details_Cur;

    l_Expenditure_Ending_Date:= pa_utils.getweekending(Exp_Details_Rec.expenditure_item_date);
    l_Dr_Code_Combination_Id := Exp_Details_Rec.Dr_CC_Id;
    l_Operating_Unit := Exp_Details_Rec.org_id;

    OPEN  Cr_CC_Cur(exp_details_rec.org_id);
    FETCH Cr_CC_Cur INTO l_Cr_Code_Combination_Id;
    CLOSE Cr_CC_Cur;

    OPEN Item_Name_Cur(p_rcv_txn_tbl(1).Inventory_Item_Id, p_rcv_txn_tbl(1).Organization_Id);
    FETCH Item_Name_Cur INTO l_Item_Name;
    CLOSE Item_Name_Cur;

    debug('  item_name            : '||l_item_name);

    cse_util_pkg.check_depreciable(
      p_inventory_item_id   => p_rcv_txn_tbl(1).inventory_item_id,
      p_depreciable         => l_depreciable);

    IF l_depreciable ='Y' THEN
      l_transaction_source :='CSE_PO_RECEIPT_DEPR';
    ELSIF l_depreciable ='N' THEN
      l_transaction_source :='CSE_PO_RECEIPT';
    END IF;

    OPEN Vendor_Cur(p_rcv_txn_tbl(1).PO_Header_Id);
    FETCH Vendor_Cur INTO l_vendor_id, l_vendor_num;
    CLOSE Vendor_Cur;

    debug('  vendor_number        : '||l_vendor_num);

    FOR i IN p_rcv_txn_tbl.FIRST ..p_rcv_txn_tbl.LAST
    LOOP

      l_nl_pa_interface_tbl(i).transaction_source      := l_transaction_source;
      l_nl_pa_interface_tbl(i).batch_name              := to_char(p_rcv_txn_tbl(i).csi_transaction_id);
      l_nl_pa_interface_tbl(i).expenditure_ending_date := l_expenditure_ending_date;
      l_nl_pa_interface_tbl(i).organization_name       := exp_details_rec.expenditure_organization_name;
      l_nl_pa_interface_tbl(i).expenditure_item_date   := exp_details_rec.expenditure_item_date;
      l_nl_pa_interface_tbl(i).project_number          := l_project_name;
      l_nl_pa_interface_tbl(i).task_number             := l_task_number;
      l_nl_pa_interface_tbl(i).expenditure_type        := exp_details_rec.expenditure_type;
      l_nl_pa_interface_tbl(i).quantity                := p_rcv_txn_tbl(i).quantity;
      l_nl_pa_interface_tbl(i).expenditure_comment     := 'ENTERPRISE INSTALL BASE';
      l_nl_pa_interface_tbl(i).transaction_status_Code := 'P';

      IF p_rcv_txn_tbl(i).serial_number IS NOT NULL THEN
        l_nl_pa_interface_tbl(i).orig_transaction_reference :=
             p_rcv_txn_tbl(i).Rcv_Transaction_Id||'-'||p_rcv_txn_tbl(i).Serial_Number;
      ELSE
        l_nl_pa_interface_tbl(i).Orig_Transaction_Reference:= p_rcv_txn_tbl(i).rcv_transaction_id;
      END IF;

      l_nl_pa_interface_tbl(i).attribute6              := l_item_name;
      l_nl_pa_interface_tbl(i).attribute7              := p_rcv_txn_tbl(i).serial_number;
      l_nl_pa_interface_tbl(i).attribute8              := null;
      l_nl_pa_interface_tbl(i).attribute9              := null;
      l_nl_pa_interface_tbl(i).attribute10             := null;
      l_nl_pa_interface_tbl(i).interface_id            := null;
      l_nl_pa_interface_tbl(i).org_Id                  := l_operating_unit;
      l_nl_pa_interface_tbl(i).dr_code_combination_id  := l_dr_code_combination_id;
      l_nl_pa_interface_tbl(i).cr_code_combination_id  := l_cr_code_combination_id;
      l_nl_pa_interface_tbl(i).cdl_system_reference1   := p_rcv_txn_tbl(i).po_vendor_id;
      l_nl_pa_interface_tbl(i).cdl_system_reference2   := p_rcv_txn_tbl(i).po_header_id;
      l_nl_pa_interface_tbl(i).cdl_system_reference3   := p_rcv_txn_tbl(i).po_distribution_id;
      l_nl_pa_interface_tbl(i).cdl_system_reference4   := p_rcv_txn_tbl(i).rcv_transaction_id;
      l_nl_pa_interface_tbl(i).cdl_system_reference5   :=
        cse_asset_util_pkg.get_rcv_sub_ledger_id(p_rcv_txn_tbl(i).rcv_transaction_id);
      l_nl_pa_interface_tbl(i).gl_date                 := l_Expenditure_Ending_Date;
      l_nl_pa_interface_tbl(i).system_linkage          := l_System_Linkage;
      l_nl_pa_interface_tbl(i).user_transaction_source := 'ENTERPRISE INSTALL BASE';
      l_nl_pa_interface_tbl(i).last_update_date        := l_sysdate;
      l_nl_pa_interface_tbl(i).last_updated_by         := l_user_id;
      l_nl_pa_interface_tbl(i).creation_date           := l_sysdate;
      l_nl_pa_interface_tbl(i).created_by              := l_user_id;
      l_nl_pa_interface_tbl(i).vendor_number           := l_vendor_num;
      l_nl_pa_interface_tbl(i).acct_raw_cost           := p_rcv_txn_tbl(i).amount;
      l_nl_pa_interface_tbl(i).denom_raw_cost          := p_rcv_txn_tbl(i).amount;
      l_nl_pa_interface_tbl(i).billable_flag           := 'Y';
      l_nl_pa_interface_tbl(i).unmatched_negative_txn_flag := 'Y';
      l_nl_pa_interface_tbl(i).organization_id         := p_rcv_txn_tbl(i).organization_id;
      l_nl_pa_interface_tbl(i).inventory_item_id       := p_rcv_txn_tbl(i).inventory_item_id;
      l_nl_pa_interface_tbl(i).po_header_id            := p_rcv_txn_tbl(i).po_header_id;
      l_nl_pa_interface_tbl(i).po_line_id              := p_rcv_txn_tbl(i).po_line_id;
      l_nl_pa_interface_tbl(i).po_number               := p_rcv_txn_tbl(i).po_number;
      l_nl_pa_interface_tbl(i).po_line_num             := p_rcv_txn_tbl(i).po_line_number;
      l_nl_pa_interface_tbl(i).vendor_id               := l_vendor_id;
      l_nl_pa_interface_tbl(i).project_id              := p_rcv_txn_tbl(i).project_id;
      l_nl_pa_interface_tbl(i).task_id                 := p_rcv_txn_tbl(i).task_id;
      l_nl_pa_interface_tbl(i).document_type           := p_rcv_txn_tbl(i).destination_type_code;
      l_nl_pa_interface_tbl(i).document_distribution_type := p_rcv_txn_tbl(i).transaction_type;

    END LOOP;

    debug('  pa_interface_tbl.count : '||l_nl_pa_interface_tbl.COUNT);

    IF NOT l_nl_pa_interface_tbl.COUNT = 0 THEN

      cse_ipa_trans_pkg.populate_pa_interface(
        p_nl_pa_interface_tbl  => l_nl_pa_interface_tbl,
        x_return_status        => l_return_status,
        x_error_message        => l_error_message);

      IF l_return_status = fnd_api.g_ret_sts_success THEN
        knock_the_commitment(
          p_rcv_transaction_id  => p_rcv_txn_tbl(1).rcv_transaction_id,
          x_return_status       => l_return_status);
        commit;
      END IF;

    END IF;

    x_return_status := l_return_status;
    x_error_message := l_error_message;

    debug('interface_nl_to_pa successful. rcv_transaction_id : '||p_rcv_txn_tbl(1).rcv_transaction_id);
    debug('==============================================================================');

  EXCEPTION
    WHEN FND_API.G_Exc_Error THEN
      x_error_message := fnd_message.get;
      x_return_status := g_ret_sts_error;
    WHEN OTHERS THEN
      fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
      fnd_message.set_token('ERR_MSG', SQLERRM);
      x_error_message := fnd_message.get;
      x_return_status := g_ret_sts_unexp_error;
  END interface_nl_to_pa;

END cse_po_receipt_into_project;

/
