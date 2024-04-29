--------------------------------------------------------
--  DDL for Package Body CSI_GEN_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_GEN_UTILITY_PVT" AS
/* $Header: csivgub.pls 120.12.12000000.2 2007/06/18 14:15:59 sdandapa ship $ */

PROCEDURE read_debug_profiles IS
   BEGIN
     g_debug_level         := fnd_profile.value('CSI_DEBUG_LEVEL');
     g_debug_file          := fnd_profile.value('CSI_LOGFILE_NAME');
     g_debug_file_path     := fnd_profile.value('CSI_LOGFILE_PATH');
   END read_debug_profiles;

PROCEDURE put_line(p_message IN VARCHAR2)
IS
   l_message               VARCHAR2(4000);

   l_sid                   NUMBER;
   l_serial                number;
   l_audsid                number;
   l_user                  varchar2(30);
   l_schema                varchar2(30);
   l_os_user               VARCHAR2(30);
   l_logon_time            date;
   l_module                varchar2(48);

   l_file_handle           utl_file.file_type;

BEGIN

	IF g_debug_level is null THEN
		read_debug_profiles;
	END IF;

 IF g_debug_level > 0 THEN
    IF g_audsid is NULL THEN

      SELECT sid, serial#, audsid, username, schemaname, osuser, logon_time, module
      INTO   l_sid, l_serial, l_audsid, l_user, l_schema, l_os_user, l_logon_time, l_module
      FROM   v$session
      WHERE  audsid = (SELECT userenv('SESSIONID') FROM sys.dual);

      --
      g_audsid := l_audsid;

      l_message := '***-new sql session'||l_audsid||'-'||l_sid||'-'||l_serial||'-'||l_user||'-'||l_schema||'-'||
                   l_os_user||l_module||'-'||to_char(l_logon_time, 'DD-MON-YYYY HH24:MI:SS')||'-***';
      l_file_handle := UTL_FILE.FOPEN(g_debug_file_path, g_debug_file, 'a');
      UTL_FILE.PUT_LINE (l_file_handle, l_message);
    END IF;

    l_message     := g_audsid||'-'||to_char(sysdate, 'ddmmyyyy hh24:mi:ss')||'-'||p_message;
    l_file_handle := UTL_FILE.FOPEN(g_debug_file_path, g_debug_file, 'a');
    UTL_FILE.PUT_LINE (l_file_handle, l_message);
    UTL_FILE.FFLUSH(l_file_handle);
    UTL_FILE.FCLOSE(l_file_handle);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    null;
END put_line;


FUNCTION enable_trace (l_trace_flag IN VARCHAR2)
RETURN VARCHAR2
is
event_on            BINARY_INTEGER;
event_num           BINARY_INTEGER := 10046; -- Trace event
l_flag              VARCHAR2(1):=l_trace_flag;
begin
 /***** srramakr Commented for Bug 3304439
 DBMS_SYSTEM.READ_EV(event_num,event_on);
 IF event_on <> 1 THEN
        IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
                   dbms_session.set_sql_trace(TRUE);
           l_flag:='Y';
    Else
           l_flag:='N';
    END IF;
 ELSE
           l_flag:='N';
 END IF;
 *****/
 l_flag := 'N';
RETURN l_flag;
END enable_trace;

  FUNCTION dump_error_stack RETURN varchar2
  IS
    l_msg_count       number;
    l_msg_data        varchar2(2000);
    l_msg_index_out   number;
    x_msg_data        varchar2(4000);
  BEGIN

    x_msg_data := null;

    fnd_msg_pub.count_and_get(
      p_count  => l_msg_count,
      p_data   => l_msg_data);

    FOR l_ind IN 1..l_msg_count
    LOOP

      fnd_msg_pub.get(
        p_msg_index     => l_ind,
        p_encoded       => fnd_api.g_false,
        p_data          => l_msg_data,
        p_msg_index_out => l_msg_index_out);

      x_msg_data := ltrim(x_msg_data||' '||l_msg_data);

      IF length(x_msg_data) > 1999 THEN
        x_msg_data := substr(x_msg_data, 1, 1999);
        exit;
      END IF;

    END LOOP;

    RETURN x_msg_data;

  EXCEPTION
    WHEN others THEN
      RETURN null;
  END dump_error_stack;

PROCEDURE dump_ext_attrib_values_rec
     (p_ext_attrib_values_rec       IN  csi_datastructures_pub.extend_attrib_values_rec)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_ext_attrib_values_rec';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
--   SAVEPOINT       dump_ext_attrib_values_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Extended Attribs Record:');
PUT_LINE ('                                       ');
PUT_LINE ('attribute_value_id          :'||p_ext_attrib_values_rec.attribute_value_id);
PUT_LINE ('instance_id                 :'||p_ext_attrib_values_rec.instance_id);
PUT_LINE ('attribute_id                :'||p_ext_attrib_values_rec.attribute_id);
PUT_LINE ('attribute_value             :'||p_ext_attrib_values_rec.attribute_value);
PUT_LINE ('active_start_date           :'||p_ext_attrib_values_rec.active_start_date);
PUT_LINE ('active_end_date             :'||p_ext_attrib_values_rec.active_end_date);
PUT_LINE ('context                     :'||p_ext_attrib_values_rec.context);
PUT_LINE ('attribute1                  :'||p_ext_attrib_values_rec.attribute1);
PUT_LINE ('attribute2                  :'||p_ext_attrib_values_rec.attribute2);
PUT_LINE ('attribute3                  :'||p_ext_attrib_values_rec.attribute3);
PUT_LINE ('attribute4                  :'||p_ext_attrib_values_rec.attribute4);
PUT_LINE ('attribute5                  :'||p_ext_attrib_values_rec.attribute5);
PUT_LINE ('attribute6                  :'||p_ext_attrib_values_rec.attribute6);
PUT_LINE ('attribute7                  :'||p_ext_attrib_values_rec.attribute7);
PUT_LINE ('attribute8                  :'||p_ext_attrib_values_rec.attribute8);
PUT_LINE ('attribute9                  :'||p_ext_attrib_values_rec.attribute9);
PUT_LINE ('attribute10                 :'||p_ext_attrib_values_rec.attribute10);
PUT_LINE ('attribute11                 :'||p_ext_attrib_values_rec.attribute11);
PUT_LINE ('attribute12                 :'||p_ext_attrib_values_rec.attribute12);
PUT_LINE ('attribute13                 :'||p_ext_attrib_values_rec.attribute13);
PUT_LINE ('attribute14                 :'||p_ext_attrib_values_rec.attribute14);
PUT_LINE ('attribute15                 :'||p_ext_attrib_values_rec.attribute15);
PUT_LINE ('object_version_number       :'||p_ext_attrib_values_rec.object_version_number);


EXCEPTION
        WHEN OTHERS THEN
               -- ROLLBACK TO  dump_ext_attrib_values_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                     );
                END IF;

END dump_ext_attrib_values_rec;


PROCEDURE dump_ext_attrib_values_tbl
     (p_ext_attrib_values_tbl       IN  csi_datastructures_pub.extend_attrib_values_tbl)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_ext_attrib_values_tbl';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT       dump_ext_attrib_values_tbl;

IF p_ext_attrib_values_tbl.COUNT > 0 THEN
 FOR tab_row IN p_ext_attrib_values_tbl.FIRST .. p_ext_attrib_values_tbl.LAST
   LOOP
    IF p_ext_attrib_values_tbl.EXISTS(tab_row) THEN

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Extended Attribs Table Record #  :'||tab_row);
PUT_LINE ('                                       ');
PUT_LINE ('attribute_value_id          :'||p_ext_attrib_values_tbl(tab_row).attribute_value_id);
PUT_LINE ('instance_id                 :'||p_ext_attrib_values_tbl(tab_row).instance_id);
PUT_LINE ('attribute_id                :'||p_ext_attrib_values_tbl(tab_row).attribute_id);
PUT_LINE ('attribute_value             :'||p_ext_attrib_values_tbl(tab_row).attribute_value);
PUT_LINE ('active_start_date           :'||p_ext_attrib_values_tbl(tab_row).active_start_date);
PUT_LINE ('active_end_date             :'||p_ext_attrib_values_tbl(tab_row).active_end_date);
PUT_LINE ('context                     :'||p_ext_attrib_values_tbl(tab_row).context);
PUT_LINE ('attribute1                  :'||p_ext_attrib_values_tbl(tab_row).attribute1);
PUT_LINE ('attribute2                  :'||p_ext_attrib_values_tbl(tab_row).attribute2);
PUT_LINE ('attribute3                  :'||p_ext_attrib_values_tbl(tab_row).attribute3);
PUT_LINE ('attribute4                  :'||p_ext_attrib_values_tbl(tab_row).attribute4);
PUT_LINE ('attribute5                  :'||p_ext_attrib_values_tbl(tab_row).attribute5);
PUT_LINE ('attribute6                  :'||p_ext_attrib_values_tbl(tab_row).attribute6);
PUT_LINE ('attribute7                  :'||p_ext_attrib_values_tbl(tab_row).attribute7);
PUT_LINE ('attribute8                  :'||p_ext_attrib_values_tbl(tab_row).attribute8);
PUT_LINE ('attribute9                  :'||p_ext_attrib_values_tbl(tab_row).attribute9);
PUT_LINE ('attribute10                 :'||p_ext_attrib_values_tbl(tab_row).attribute10);
PUT_LINE ('attribute11                 :'||p_ext_attrib_values_tbl(tab_row).attribute11);
PUT_LINE ('attribute12                 :'||p_ext_attrib_values_tbl(tab_row).attribute12);
PUT_LINE ('attribute13                 :'||p_ext_attrib_values_tbl(tab_row).attribute13);
PUT_LINE ('attribute14                 :'||p_ext_attrib_values_tbl(tab_row).attribute14);
PUT_LINE ('attribute15                 :'||p_ext_attrib_values_tbl(tab_row).attribute15);
PUT_LINE ('object_version_number       :'||p_ext_attrib_values_tbl(tab_row).object_version_number);
    END IF;
  END LOOP;
END IF;

EXCEPTION
        WHEN OTHERS THEN
              --  ROLLBACK TO  dump_ext_attrib_values_tbl;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                     );
                END IF;

END dump_ext_attrib_values_tbl;



PROCEDURE dump_ext_attrib_query_rec
     (p_ext_attrib_query_rec       IN  csi_datastructures_pub.extend_attrib_query_rec)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_ou_query_rec';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT       dump_ext_attrib_query_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Extended Attribs Query Record:');
PUT_LINE ('                                       ');
PUT_LINE ('attribute_value_id          :'||p_ext_attrib_query_rec.attribute_value_id);
PUT_LINE ('instance_id                 :'||p_ext_attrib_query_rec.instance_id);
PUT_LINE ('attribute_id                :'||p_ext_attrib_query_rec.attribute_id);

EXCEPTION
        WHEN OTHERS THEN
               -- ROLLBACK TO  dump_ext_attrib_query_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                     );
                END IF;
END dump_ext_attrib_query_rec;


PROCEDURE dump_ou_query_rec
     (p_ou_query_rec       IN  csi_datastructures_pub.organization_unit_query_rec)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_ou_query_rec';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT       dump_ou_qurey_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Org. Assignments Query Record:');
PUT_LINE ('                                       ');
PUT_LINE ('instance_ou_id              :'||p_ou_query_rec.instance_ou_id);
PUT_LINE ('instance_id                 :'||p_ou_query_rec.instance_id);
PUT_LINE ('operating_unit_id           :'||p_ou_query_rec.operating_unit_id);
PUT_LINE ('relationship_type_code      :'||p_ou_query_rec.relationship_type_code);

EXCEPTION
        WHEN OTHERS THEN
               -- ROLLBACK TO  dump_ou_qurey_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                     );
                END IF;

END dump_ou_query_rec;

PROCEDURE dump_instance_rec
     (p_instance_rec       IN  csi_datastructures_pub.instance_rec)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_instance_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
   --SAVEPOINT       dump_instance_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Record:');
PUT_LINE ('                                       ');
PUT_LINE ('instance_id                 :'||p_instance_rec.instance_id);
PUT_LINE ('instance_number             :'||p_instance_rec.instance_number);
PUT_LINE ('external_reference          :'||p_instance_rec.external_reference);
PUT_LINE ('inventory_item_id           :'||p_instance_rec.inventory_item_id);
PUT_LINE ('vld_organization_id         :'||p_instance_rec.vld_organization_id);
PUT_LINE ('inventory_revision          :'||p_instance_rec.inventory_revision);
PUT_LINE ('inv_master_organization_id  :'||p_instance_rec.inv_master_organization_id);
PUT_LINE ('serial_number               :'||p_instance_rec.serial_number);
PUT_LINE ('mfg_serial_number_flag      :'||p_instance_rec.mfg_serial_number_flag);
PUT_LINE ('lot_number                  :'||p_instance_rec.lot_number);
PUT_LINE ('quantity                    :'||p_instance_rec.quantity);
PUT_LINE ('unit_of_measure             :'||p_instance_rec.unit_of_measure);
PUT_LINE ('accounting_class_code       :'||p_instance_rec.accounting_class_code );
PUT_LINE ('instance_condition_id       :'||p_instance_rec.instance_condition_id);
PUT_LINE ('instance_status_id          :'||p_instance_rec.instance_status_id);
PUT_LINE ('customer_view_flag          :'||p_instance_rec.customer_view_flag);
PUT_LINE ('merchant_view_flag          :'||p_instance_rec.merchant_view_flag);
PUT_LINE ('sellable_flag               :'||p_instance_rec.sellable_flag);
PUT_LINE ('system_id                   :'||p_instance_rec.system_id);
PUT_LINE ('instance_type_code          :'||p_instance_rec.instance_type_code );
PUT_LINE ('active_start_date           :'||p_instance_rec.active_start_date);
PUT_LINE ('active_end_date             :'||p_instance_rec.active_end_date);
PUT_LINE ('location_type_code          :'||p_instance_rec.location_type_code );
PUT_LINE ('location_id                 :'||p_instance_rec.location_id );
PUT_LINE ('inv_organization_id         :'||p_instance_rec.inv_organization_id);
PUT_LINE ('inv_subinventory_name       :'||p_instance_rec.inv_subinventory_name);
PUT_LINE ('inv_locator_id              :'||p_instance_rec.inv_locator_id);
PUT_LINE ('pa_project_id               :'||p_instance_rec.pa_project_id);
PUT_LINE ('pa_project_task_id          :'||p_instance_rec.pa_project_task_id );
PUT_LINE ('in_transit_order_line_id    :'||p_instance_rec.in_transit_order_line_id);
PUT_LINE ('wip_job_id                  :'||p_instance_rec.wip_job_id);
PUT_LINE ('po_order_line_id            :'||p_instance_rec.po_order_line_id);
PUT_LINE ('last_oe_order_line_id       :'||p_instance_rec.last_oe_order_line_id );
PUT_LINE ('last_oe_rma_line_id         :'||p_instance_rec.last_oe_rma_line_id);
PUT_LINE ('last_po_po_line_id          :'||p_instance_rec.last_po_po_line_id);
PUT_LINE ('last_oe_po_number           :'||p_instance_rec.last_oe_po_number);
PUT_LINE ('last_wip_job_id             :'||p_instance_rec.last_wip_job_id );
PUT_LINE ('last_pa_project_id          :'||p_instance_rec.last_pa_project_id);
PUT_LINE ('last_pa_task_id             :'||p_instance_rec.last_pa_task_id);
PUT_LINE ('last_oe_agreement_id        :'||p_instance_rec.last_oe_agreement_id);
PUT_LINE ('install_date                :'||p_instance_rec.install_date);
PUT_LINE ('manually_created_flag       :'||p_instance_rec.manually_created_flag);
PUT_LINE ('return_by_date              :'||p_instance_rec.return_by_date);
PUT_LINE ('actual_return_date          :'||p_instance_rec.actual_return_date);
PUT_LINE ('creation_complete_flag      :'||p_instance_rec.creation_complete_flag);
PUT_LINE ('completeness_flag           :'||p_instance_rec.completeness_flag);
PUT_LINE ('version_label               :'||p_instance_rec.version_label);
PUT_LINE ('version_label_description   :'||p_instance_rec.version_label_description);
PUT_LINE ('context                     :'||p_instance_rec.context );
PUT_LINE ('attribute1                  :'||p_instance_rec.attribute1);
PUT_LINE ('attribute2                  :'||p_instance_rec.attribute2);
PUT_LINE ('attribute3                  :'||p_instance_rec.attribute3);
PUT_LINE ('attribute4                  :'||p_instance_rec.attribute4);
PUT_LINE ('attribute5                  :'||p_instance_rec.attribute5);
PUT_LINE ('attribute6                  :'||p_instance_rec.attribute6);
PUT_LINE ('attribute7                  :'||p_instance_rec.attribute7);
PUT_LINE ('attribute8                  :'||p_instance_rec.attribute8);
PUT_LINE ('attribute9                  :'||p_instance_rec.attribute9);
PUT_LINE ('attribute10                 :'||p_instance_rec.attribute10);
PUT_LINE ('attribute11                 :'||p_instance_rec.attribute11);
PUT_LINE ('attribute12                 :'||p_instance_rec.attribute12);
PUT_LINE ('attribute13                 :'||p_instance_rec.attribute13);
PUT_LINE ('attribute14                 :'||p_instance_rec.attribute14);
PUT_LINE ('attribute15                 :'||p_instance_rec.attribute15);
PUT_LINE ('attribute16                 :'||p_instance_rec.attribute16);
PUT_LINE ('attribute17                 :'||p_instance_rec.attribute17);
PUT_LINE ('attribute18                 :'||p_instance_rec.attribute18);
PUT_LINE ('attribute19                 :'||p_instance_rec.attribute19);
PUT_LINE ('attribute20                 :'||p_instance_rec.attribute20);
PUT_LINE ('attribute21                 :'||p_instance_rec.attribute21);
PUT_LINE ('attribute22                 :'||p_instance_rec.attribute22);
PUT_LINE ('attribute23                 :'||p_instance_rec.attribute23);
PUT_LINE ('attribute24                 :'||p_instance_rec.attribute24);
PUT_LINE ('attribute25                 :'||p_instance_rec.attribute25);
PUT_LINE ('attribute26                 :'||p_instance_rec.attribute26);
PUT_LINE ('attribute27                 :'||p_instance_rec.attribute27);
PUT_LINE ('attribute28                 :'||p_instance_rec.attribute28);
PUT_LINE ('attribute29                 :'||p_instance_rec.attribute29);
PUT_LINE ('attribute30                 :'||p_instance_rec.attribute30);
PUT_LINE ('object_version_number       :'||p_instance_rec.object_version_number);
PUT_LINE ('last_txn_line_detail_id     :'||p_instance_rec.last_txn_line_detail_id);
PUT_LINE ('install_location_type_code  :'||p_instance_rec.install_location_type_code);
PUT_LINE ('install_location_id         :'||p_instance_rec.install_location_id);
PUT_LINE ('instance_usage_code         :'||p_instance_rec.instance_usage_code);
PUT_LINE ('config_inst_hdr_id          :'||p_instance_rec.config_inst_hdr_id);
PUT_LINE ('config_inst_rev_num         :'||p_instance_rec.config_inst_rev_num);
PUT_LINE ('config_inst_item_id         :'||p_instance_rec.config_inst_item_id);
PUT_LINE ('config_valid_status         :'||p_instance_rec.config_valid_status);
PUT_LINE ('instance_description        :'||p_instance_rec.instance_description);
PUT_LINE ('call_contracts              :'||p_instance_rec.call_contracts);
PUT_LINE ('network_asset_flag          :'||p_instance_rec.network_asset_flag);
PUT_LINE ('maintainable_flag           :'||p_instance_rec.maintainable_flag);
PUT_LINE ('pn_location_id              :'||p_instance_rec.pn_location_id);
PUT_LINE ('asset_criticality_code      :'||p_instance_rec.asset_criticality_code);
PUT_LINE ('category_id                 :'||p_instance_rec.category_id);
PUT_LINE ('equipment_gen_object_id     :'||p_instance_rec.equipment_gen_object_id);
PUT_LINE ('instantiation_flag          :'||p_instance_rec.instantiation_flag);
PUT_LINE ('linear_location_id          :'||p_instance_rec.linear_location_id);
PUT_LINE ('operational_log_flag        :'||p_instance_rec.operational_log_flag);
PUT_LINE ('checkin_status              :'||p_instance_rec.checkin_status);
PUT_LINE ('supplier_warranty_exp_date  :'||p_instance_rec.supplier_warranty_exp_date);
PUT_LINE ('purchase_unit_price         :'||p_instance_rec.purchase_unit_price);
PUT_LINE ('purchase_currency_code      :'||p_instance_rec.purchase_currency_code);
PUT_LINE ('payables_unit_price         :'||p_instance_rec.payables_unit_price);
PUT_LINE ('payables_currency_code      :'||p_instance_rec.payables_currency_code);
PUT_LINE ('sales_unit_price            :'||p_instance_rec.sales_unit_price);
PUT_LINE ('sales_currency_code         :'||p_instance_rec.sales_currency_code);
PUT_LINE ('operational_status_code     :'||p_instance_rec.operational_status_code);
EXCEPTION
        WHEN OTHERS THEN
                -- ROLLBACK TO  dump_instance_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                     );
                END IF;

END dump_instance_rec;


PROCEDURE dump_instance_query_rec
     (p_instance_query_rec       IN  csi_datastructures_pub.instance_query_rec)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_instance_query_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT       dump_instance_query_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Query Record ');
PUT_LINE ('                                       ');
PUT_LINE ('instance_id                 :'||p_instance_query_rec.instance_id  );
PUT_LINE ('inventory_item_id           :'||p_instance_query_rec.inventory_item_id);
PUT_LINE ('inventory_revision          :'||p_instance_query_rec.inventory_revision);
PUT_LINE ('inv_master_organization_id  :'||p_instance_query_rec.inv_master_organization_id);
PUT_LINE ('serial_number               :'||p_instance_query_rec.serial_number);
PUT_LINE ('lot_number                  :'||p_instance_query_rec.lot_number);
PUT_LINE ('unit_of_measure             :'||p_instance_query_rec.unit_of_measure);
PUT_LINE ('instance_condition_id       :'||p_instance_query_rec.instance_condition_id);
PUT_LINE ('instance_status_id          :'||p_instance_query_rec.instance_status_id);
PUT_LINE ('system_id                   :'||p_instance_query_rec.system_id);
PUT_LINE ('instance_type_code          :'||p_instance_query_rec.instance_type_code );
PUT_LINE ('location_type_code          :'||p_instance_query_rec.location_type_code );
PUT_LINE ('location_id                 :'||p_instance_query_rec.location_id );
PUT_LINE ('inv_organization_id         :'||p_instance_query_rec.inv_organization_id);
PUT_LINE ('inv_subinventory_name       :'||p_instance_query_rec.inv_subinventory_name);
PUT_LINE ('inv_locator_id              :'||p_instance_query_rec.inv_locator_id);
PUT_LINE ('pa_project_id               :'||p_instance_query_rec.pa_project_id);
PUT_LINE ('pa_project_task_id          :'||p_instance_query_rec.pa_project_task_id );
PUT_LINE ('in_transit_order_line_id    :'||p_instance_query_rec.in_transit_order_line_id);
PUT_LINE ('wip_job_id                  :'||p_instance_query_rec.wip_job_id);
PUT_LINE ('po_order_line_id            :'||p_instance_query_rec.po_order_line_id);
PUT_LINE ('last_oe_order_line_id       :'||p_instance_query_rec.last_oe_order_line_id );
PUT_LINE ('last_oe_rma_line_id         :'||p_instance_query_rec.last_oe_rma_line_id);
PUT_LINE ('last_po_po_line_id          :'||p_instance_query_rec.last_po_po_line_id);
PUT_LINE ('last_oe_po_number           :'||p_instance_query_rec.last_oe_po_number);
PUT_LINE ('last_wip_job_id             :'||p_instance_query_rec.last_wip_job_id );
PUT_LINE ('last_pa_project_id          :'||p_instance_query_rec.last_pa_project_id);
PUT_LINE ('last_pa_task_id             :'||p_instance_query_rec.last_pa_task_id);
PUT_LINE ('last_oe_agreement_id        :'||p_instance_query_rec.last_oe_agreement_id);
PUT_LINE ('install_date                :'||p_instance_query_rec.install_date);
PUT_LINE ('manually_created_flag       :'||p_instance_query_rec.manually_created_flag);
PUT_LINE ('return_by_date              :'||p_instance_query_rec.return_by_date);
PUT_LINE ('actual_return_date          :'||p_instance_query_rec.actual_return_date);
PUT_LINE ('instance_usage_code         :'||p_instance_query_rec.instance_usage_code);
PUT_LINE ('config_inst_hdr_id          :'||p_instance_query_rec.config_inst_hdr_id);
PUT_LINE ('config_inst_rev_num         :'||p_instance_query_rec.config_inst_rev_num);
PUT_LINE ('config_inst_item_id         :'||p_instance_query_rec.config_inst_item_id);
PUT_LINE ('instance_description        :'||p_instance_query_rec.instance_description);
PUT_LINE ('operational_status_code     :'||p_instance_query_rec.operational_status_code);
EXCEPTION
        WHEN OTHERS THEN
   --             ROLLBACK TO  dump_instance_query_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                     );
                END IF;

END dump_instance_query_rec;


PROCEDURE dump_instance_header_rec
     (p_instance_header_rec  IN  csi_datastructures_pub.instance_header_rec)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_instance_header_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT       dump_instance_header_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Header Record:');
PUT_LINE ('                                       ');
PUT_LINE ('instance_id                 :'||p_instance_header_rec.instance_id  );
PUT_LINE ('instance_number             :'||p_instance_header_rec.instance_number);
PUT_LINE ('external_reference          :'||p_instance_header_rec.external_reference);
--PUT_LINE ('item_description            :'||p_instance_header_rec.item_description);
PUT_LINE ('inventory_item_id           :'||p_instance_header_rec.inventory_item_id);
PUT_LINE ('inventory_revision          :'||p_instance_header_rec.inventory_revision);
PUT_LINE ('inv_master_organization_id  :'||p_instance_header_rec.inv_master_organization_id);
PUT_LINE ('serial_number               :'||p_instance_header_rec.serial_number);
PUT_LINE ('mfg_serial_number_flag      :'||p_instance_header_rec.mfg_serial_number_flag);
PUT_LINE ('lot_number                  :'||p_instance_header_rec.lot_number);
PUT_LINE ('quantity                    :'||p_instance_header_rec.quantity);
--PUT_LINE ('unit_of_measure_name        :'||p_instance_header_rec.unit_of_measure_name);
PUT_LINE ('unit_of_measure             :'||p_instance_header_rec.unit_of_measure);
PUT_LINE ('accounting_class            :'||p_instance_header_rec.accounting_class);
PUT_LINE ('accounting_class_code       :'||p_instance_header_rec.accounting_class_code );
PUT_LINE ('instance_condition          :'||p_instance_header_rec.instance_condition);
PUT_LINE ('instance_condition_id       :'||p_instance_header_rec.instance_condition_id);
PUT_LINE ('instance_status             :'||p_instance_header_rec.instance_status);
PUT_LINE ('instance_status_id          :'||p_instance_header_rec.instance_status_id);
PUT_LINE ('customer_view_flag          :'||p_instance_header_rec.customer_view_flag);
PUT_LINE ('merchant_view_flag          :'||p_instance_header_rec.merchant_view_flag);
PUT_LINE ('sellable_flag               :'||p_instance_header_rec.sellable_flag);
PUT_LINE ('system_id                   :'||p_instance_header_rec.system_id);
PUT_LINE ('system_name                 :'||p_instance_header_rec.system_name);
PUT_LINE ('instance_type_code          :'||p_instance_header_rec.instance_type_code );
PUT_LINE ('instance_type_name          :'||p_instance_header_rec.instance_type_name);
PUT_LINE ('active_start_date           :'||p_instance_header_rec.active_start_date);
PUT_LINE ('active_end_date             :'||p_instance_header_rec.active_end_date);
PUT_LINE ('location_type_code          :'||p_instance_header_rec.location_type_code );
--PUT_LINE ('location_description        :'||p_instance_header_rec.location_description);
PUT_LINE ('location_id                 :'||p_instance_header_rec.location_id );
PUT_LINE ('inv_organization_id         :'||p_instance_header_rec.inv_organization_id);
PUT_LINE ('inv_organization_name       :'||p_instance_header_rec.inv_organization_name);
--PUT_LINE ('inv_description             :'||p_instance_header_rec.inv_description);
PUT_LINE ('inv_subinventory_name       :'||p_instance_header_rec.inv_subinventory_name);
PUT_LINE ('inv_locator_id              :'||p_instance_header_rec.inv_locator_id);
--PUT_LINE ('pa_task_description         :'||p_instance_header_rec.pa_task_description);
PUT_LINE ('pa_project_id               :'||p_instance_header_rec.pa_project_id);
PUT_LINE ('pa_project_task_id          :'||p_instance_header_rec.pa_project_task_id );
PUT_LINE ('pa_project_name             :'||p_instance_header_rec.pa_project_name );
PUT_LINE ('pa_project_number           :'||p_instance_header_rec.pa_project_number );
PUT_LINE ('pa_task_name                :'||p_instance_header_rec.pa_task_name );
PUT_LINE ('pa_task_number              :'||p_instance_header_rec.pa_task_number );
--PUT_LINE ('oe_line_item_input          :'||p_instance_header_rec.oe_line_item_input);
PUT_LINE ('in_transit_order_line_id    :'||p_instance_header_rec.in_transit_order_line_id);
PUT_LINE ('in_transit_order_line_number:'||p_instance_header_rec.in_transit_order_line_number);
PUT_LINE ('in_transit_order_number     :'||p_instance_header_rec.in_transit_order_number);
PUT_LINE ('wip_entity_name             :'||p_instance_header_rec.wip_entity_name);
PUT_LINE ('wip_job_id                  :'||p_instance_header_rec.wip_job_id);
--PUT_LINE ('wip_entity_description      :'||p_instance_header_rec.wip_entity_description);
--PUT_LINE ('po_item_description         :'||p_instance_header_rec.po_item_description);
PUT_LINE ('po_order_line_id            :'||p_instance_header_rec.po_order_line_id);
PUT_LINE ('last_oe_order_line_id       :'||p_instance_header_rec.last_oe_order_line_id );
PUT_LINE ('last_oe_rma_line_id         :'||p_instance_header_rec.last_oe_rma_line_id);
PUT_LINE ('last_po_po_line_id          :'||p_instance_header_rec.last_po_po_line_id);
PUT_LINE ('last_oe_po_number           :'||p_instance_header_rec.last_oe_po_number);
PUT_LINE ('last_wip_job_id             :'||p_instance_header_rec.last_wip_job_id );
PUT_LINE ('last_pa_project_id          :'||p_instance_header_rec.last_pa_project_id);
PUT_LINE ('last_pa_task_id             :'||p_instance_header_rec.last_pa_task_id);
PUT_LINE ('last_oe_agreement_id        :'||p_instance_header_rec.last_oe_agreement_id);
PUT_LINE ('install_date                :'||p_instance_header_rec.install_date);
PUT_LINE ('manually_created_flag       :'||p_instance_header_rec.manually_created_flag);
PUT_LINE ('return_by_date              :'||p_instance_header_rec.return_by_date);
PUT_LINE ('actual_return_date          :'||p_instance_header_rec.actual_return_date);
PUT_LINE ('creation_complete_flag      :'||p_instance_header_rec.creation_complete_flag);
PUT_LINE ('completeness_flag           :'||p_instance_header_rec.completeness_flag);
PUT_LINE ('context                     :'||p_instance_header_rec.context );
PUT_LINE ('attribute1                  :'||p_instance_header_rec.attribute1);
PUT_LINE ('attribute2                  :'||p_instance_header_rec.attribute2);
PUT_LINE ('attribute3                  :'||p_instance_header_rec.attribute3);
PUT_LINE ('attribute4                  :'||p_instance_header_rec.attribute4);
PUT_LINE ('attribute5                  :'||p_instance_header_rec.attribute5);
PUT_LINE ('attribute6                  :'||p_instance_header_rec.attribute6);
PUT_LINE ('attribute7                  :'||p_instance_header_rec.attribute7);
PUT_LINE ('attribute8                  :'||p_instance_header_rec.attribute8);
PUT_LINE ('attribute9                  :'||p_instance_header_rec.attribute9);
PUT_LINE ('attribute10                 :'||p_instance_header_rec.attribute10);
PUT_LINE ('attribute11                 :'||p_instance_header_rec.attribute11);
PUT_LINE ('attribute12                 :'||p_instance_header_rec.attribute12);
PUT_LINE ('attribute13                 :'||p_instance_header_rec.attribute13);
PUT_LINE ('attribute14                 :'||p_instance_header_rec.attribute14);
PUT_LINE ('attribute15                 :'||p_instance_header_rec.attribute15);
PUT_LINE ('attribute16                 :'||p_instance_header_rec.attribute16);
PUT_LINE ('attribute17                 :'||p_instance_header_rec.attribute17);
PUT_LINE ('attribute18                 :'||p_instance_header_rec.attribute18);
PUT_LINE ('attribute19                 :'||p_instance_header_rec.attribute19);
PUT_LINE ('attribute20                 :'||p_instance_header_rec.attribute20);
PUT_LINE ('attribute21                 :'||p_instance_header_rec.attribute21);
PUT_LINE ('attribute22                 :'||p_instance_header_rec.attribute22);
PUT_LINE ('attribute23                 :'||p_instance_header_rec.attribute23);
PUT_LINE ('attribute24                 :'||p_instance_header_rec.attribute24);
PUT_LINE ('attribute25                 :'||p_instance_header_rec.attribute25);
PUT_LINE ('attribute26                 :'||p_instance_header_rec.attribute26);
PUT_LINE ('attribute27                 :'||p_instance_header_rec.attribute27);
PUT_LINE ('attribute28                 :'||p_instance_header_rec.attribute28);
PUT_LINE ('attribute29                 :'||p_instance_header_rec.attribute29);
PUT_LINE ('attribute30                 :'||p_instance_header_rec.attribute30);
PUT_LINE ('object_version_number       :'||p_instance_header_rec.object_version_number);
PUT_LINE ('last_txn_line_detail_id     :'||p_instance_header_rec.last_txn_line_detail_id);
PUT_LINE ('install_location_type_code  :'||p_instance_header_rec.install_location_type_code);
PUT_LINE ('install_location_id         :'||p_instance_header_rec.install_location_id);
PUT_LINE ('instance_usage_code         :'||p_instance_header_rec.instance_usage_code);
PUT_LINE ('current_loc_address1        :'||p_instance_header_rec.current_loc_address1);
PUT_LINE ('current_loc_address2        :'||p_instance_header_rec.current_loc_address2);
PUT_LINE ('current_loc_address3        :'||p_instance_header_rec.current_loc_address3);
PUT_LINE ('current_loc_address4        :'||p_instance_header_rec.current_loc_address4);
PUT_LINE ('current_loc_city            :'||p_instance_header_rec.current_loc_city);
PUT_LINE ('current_loc_state           :'||p_instance_header_rec.current_loc_state);
PUT_LINE ('current_loc_postal_code     :'||p_instance_header_rec.current_loc_postal_code);
PUT_LINE ('current_loc_country         :'||p_instance_header_rec.current_loc_country);
PUT_LINE ('sales_order_number          :'||p_instance_header_rec.sales_order_number);
PUT_LINE ('sales_order_line_number     :'||p_instance_header_rec.sales_order_line_number);
PUT_LINE ('sales_order_date            :'||p_instance_header_rec.sales_order_date);
PUT_LINE ('purchase_order_number       :'||p_instance_header_rec.purchase_order_number);
PUT_LINE ('instance_usage_name         :'||p_instance_header_rec.instance_usage_name);
PUT_LINE ('install_loc_address1        :'||p_instance_header_rec.install_loc_address1);
PUT_LINE ('install_loc_address2        :'||p_instance_header_rec.install_loc_address2);
PUT_LINE ('install_loc_address3        :'||p_instance_header_rec.install_loc_address3);
PUT_LINE ('install_loc_address4        :'||p_instance_header_rec.install_loc_address4);
PUT_LINE ('install_loc_city            :'||p_instance_header_rec.install_loc_city);
PUT_LINE ('install_loc_state           :'||p_instance_header_rec.install_loc_state);
PUT_LINE ('install_loc_postal_code     :'||p_instance_header_rec.install_loc_postal_code);
PUT_LINE ('install_loc_country         :'||p_instance_header_rec.install_loc_country);
PUT_LINE ('vld_organization_id         :'||p_instance_header_rec.vld_organization_id);
PUT_LINE ('current_loc_number          :'||p_instance_header_rec.current_loc_number);
PUT_LINE ('install_loc_number          :'||p_instance_header_rec.install_loc_number);
PUT_LINE ('config_inst_hdr_id          :'||p_instance_header_rec.config_inst_hdr_id);
PUT_LINE ('config_inst_rev_num         :'||p_instance_header_rec.config_inst_rev_num);
PUT_LINE ('config_inst_item_id         :'||p_instance_header_rec.config_inst_item_id);
PUT_LINE ('config_valid_status         :'||p_instance_header_rec.config_valid_status);
PUT_LINE ('instance_description        :'||p_instance_header_rec.instance_description);
PUT_LINE ('start_loc_address1          :'||p_instance_header_rec.start_loc_address1);
PUT_LINE ('start_loc_address2          :'||p_instance_header_rec.start_loc_address2);
PUT_LINE ('start_loc_address3          :'||p_instance_header_rec.start_loc_address3);
PUT_LINE ('start_loc_address4          :'||p_instance_header_rec.start_loc_address4);
PUT_LINE ('start_loc_city              :'||p_instance_header_rec.start_loc_city);
PUT_LINE ('start_loc_state             :'||p_instance_header_rec.start_loc_state);
PUT_LINE ('start_loc_postal_code       :'||p_instance_header_rec.start_loc_postal_code);
PUT_LINE ('start_loc_country           :'||p_instance_header_rec.start_loc_country);
PUT_LINE ('end_loc_address1            :'||p_instance_header_rec.end_loc_address1);
PUT_LINE ('end_loc_address2            :'||p_instance_header_rec.end_loc_address2);
PUT_LINE ('end_loc_address3            :'||p_instance_header_rec.end_loc_address3);
PUT_LINE ('end_loc_address4            :'||p_instance_header_rec.end_loc_address4);
PUT_LINE ('end_loc_city                :'||p_instance_header_rec.end_loc_city);
PUT_LINE ('end_loc_state               :'||p_instance_header_rec.end_loc_state);
PUT_LINE ('end_loc_postal_code         :'||p_instance_header_rec.end_loc_postal_code);
PUT_LINE ('end_loc_country             :'||p_instance_header_rec.end_loc_country);
PUT_LINE ('network_asset_flag          :'||p_instance_header_rec.network_asset_flag);
PUT_LINE ('maintainable_flag           :'||p_instance_header_rec.maintainable_flag);
PUT_LINE ('pn_location_id              :'||p_instance_header_rec.pn_location_id);
PUT_LINE ('asset_criticality_code      :'||p_instance_header_rec.asset_criticality_code);
PUT_LINE ('category_id                 :'||p_instance_header_rec.category_id);
PUT_LINE ('equipment_gen_object_id     :'||p_instance_header_rec.equipment_gen_object_id);
PUT_LINE ('instantiation_flag          :'||p_instance_header_rec.instantiation_flag);
PUT_LINE ('linear_location_id          :'||p_instance_header_rec.linear_location_id);
PUT_LINE ('operational_log_flag        :'||p_instance_header_rec.operational_log_flag);
PUT_LINE ('checkin_status              :'||p_instance_header_rec.checkin_status);
PUT_LINE ('supplier_warranty_exp_date  :'||p_instance_header_rec.supplier_warranty_exp_date);
PUT_LINE ('purchase_unit_price         :'||p_instance_header_rec.purchase_unit_price);
PUT_LINE ('purchase_currency_code      :'||p_instance_header_rec.purchase_currency_code);
PUT_LINE ('payables_unit_price         :'||p_instance_header_rec.payables_unit_price);
PUT_LINE ('payables_currency_code      :'||p_instance_header_rec.payables_currency_code);
PUT_LINE ('sales_unit_price            :'||p_instance_header_rec.sales_unit_price);
PUT_LINE ('sales_currency_code         :'||p_instance_header_rec.sales_currency_code);
PUT_LINE ('operational_status_code     :'||p_instance_header_rec.operational_status_code);
EXCEPTION
        WHEN OTHERS THEN
        --        ROLLBACK TO  dump_instance_header_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                     );
                END IF;

END dump_instance_header_rec;



PROCEDURE dump_txn_rec
     (p_txn_rec             IN  csi_datastructures_pub.transaction_rec)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_txn_rec';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
--   SAVEPOINT       dump_txn_rec;

put_line('                                       ');
put_line('Dumping the values for Transaction Record:');
put_line('                                       ');
put_line('transaction_id               : '|| p_txn_rec.transaction_id );
put_line('transaction_date             : '|| p_txn_rec.transaction_date );
put_line('source_transaction_date      : '|| p_txn_rec.source_transaction_date );
put_line('transaction_type_id          : '|| p_txn_rec.transaction_type_id );
put_line('txn_sub_type_id              : '|| p_txn_rec.txn_sub_type_id );
put_line('source_group_ref_id          : '|| p_txn_rec.source_group_ref_id );
put_line('source_group_ref             : '|| p_txn_rec.source_group_ref );
put_line('source_header_ref_id         : '|| p_txn_rec.source_header_ref_id );
put_line('source_header_ref            : '|| p_txn_rec.source_header_ref );
put_line('source_line_ref_id           : '|| p_txn_rec.source_line_ref_id );
put_line('source_line_ref              : '|| p_txn_rec.source_line_ref );
put_line('source_dist_ref_id1          : '|| p_txn_rec.source_dist_ref_id1 );
put_line('source_dist_ref_id2          : '|| p_txn_rec.source_dist_ref_id2 );
put_line('inv_material_transaction_id  : '|| p_txn_rec.inv_material_transaction_id );
put_line('transaction_quantity         : '|| p_txn_rec.transaction_quantity );
put_line('transaction_uom_code         : '|| p_txn_rec.transaction_uom_code );
put_line('transacted_by                : '|| p_txn_rec.transacted_by );
put_line('transaction_status_code      : '|| p_txn_rec.transaction_status_code );
put_line('transaction_action_code      : '|| p_txn_rec.transaction_action_code );
put_line('message_id                   : '|| p_txn_rec.message_id );
put_line('context                      : '|| p_txn_rec.context );
put_line('attribute1                   : '|| p_txn_rec.attribute1 );
put_line('attribute2                   : '|| p_txn_rec.attribute2 );
put_line('attribute3                   : '|| p_txn_rec.attribute3 );
put_line('attribute4                   : '|| p_txn_rec.attribute4 );
put_line('attribute5                   : '|| p_txn_rec.attribute5 );
put_line('attribute6                   : '|| p_txn_rec.attribute6 );
put_line('attribute7                   : '|| p_txn_rec.attribute7 );
put_line('attribute8                   : '|| p_txn_rec.attribute8 );
put_line('attribute9                   : '|| p_txn_rec.attribute9 );
put_line('attribute10                  : '|| p_txn_rec.attribute10 );
put_line('attribute11                  : '|| p_txn_rec.attribute11 );
put_line('attribute12                  : '|| p_txn_rec.attribute12 );
put_line('attribute13                  : '|| p_txn_rec.attribute13 );
put_line('attribute14                  : '|| p_txn_rec.attribute14 );
put_line('attribute15                  : '|| p_txn_rec.attribute15 );
put_line('object_version_number        : '|| p_txn_rec.object_version_number);
put_line('split_reason_code            : '|| p_txn_rec.split_reason_code);
put_line('gl_interface_status_code     : '|| p_txn_rec.gl_interface_status_code);

EXCEPTION
        WHEN OTHERS THEN
--                ROLLBACK TO  dump_txn_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_txn_rec;

PROCEDURE dump_txn_tbl
      (p_txn_tbl             IN  csi_datastructures_pub.transaction_tbl)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_txn_tbl';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

        -- Standard Start of API savepoint
  --      SAVEPOINT       dump_txn_tbl;
        IF p_txn_tbl.COUNT > 0 THEN
           FOR tab_row IN p_txn_tbl.FIRST .. p_txn_tbl.LAST
           LOOP
             IF p_txn_tbl.EXISTS(tab_row) THEN
                   dump_txn_rec(p_txn_rec => p_txn_tbl(tab_row));
             END IF;
           END LOOP;
         END IF;



EXCEPTION
        WHEN OTHERS THEN
      --          ROLLBACK TO  dump_txn_tbl;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_txn_tbl;

PROCEDURE dump_txn_query_rec
     (p_txn_query_rec             IN  csi_datastructures_pub.transaction_query_rec)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_txn_query_rec';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
 --  SAVEPOINT       dump_txn_query_rec;

put_line('                                       ');
put_line('Dumping the values for Transaction query Record:');
put_line('                                       ');
put_line('transaction_id               : '|| p_txn_query_rec.transaction_id );
put_line('transaction_type_id          : '|| p_txn_query_rec.transaction_type_id );
put_line('source_group_ref_id          : '|| p_txn_query_rec.source_group_ref_id );
put_line('source_group_ref             : '|| p_txn_query_rec.source_group_ref );
put_line('source_header_ref_id         : '|| p_txn_query_rec.source_header_ref_id );
put_line('source_header_ref            : '|| p_txn_query_rec.source_header_ref );
put_line('source_line_ref_id           : '|| p_txn_query_rec.source_line_ref_id );
put_line('source_line_ref              : '|| p_txn_query_rec.source_line_ref );
put_line('source_transaction_date      : '|| p_txn_query_rec.source_transaction_date );
put_line('inv_material_transaction_id  : '|| p_txn_query_rec.inv_material_transaction_id );
put_line('message_id                   : '|| p_txn_query_rec.message_id );
put_line('transaction_start_date       : '|| p_txn_query_rec.transaction_start_date );
put_line('transaction_end_date         : '|| p_txn_query_rec.transaction_end_date );
put_line('instance_id                  : '|| p_txn_query_rec.instance_id );
put_line('txn_sub_type_id              : '|| p_txn_query_rec.txn_sub_type_id );
put_line('transaction_status_code      : '|| p_txn_query_rec.transaction_status_code );


EXCEPTION
        WHEN OTHERS THEN
     --           ROLLBACK TO  dump_txn_query_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_txn_query_rec;

PROCEDURE dump_txn_sort_rec
     (p_txn_sort_rec             IN  csi_datastructures_pub.transaction_sort_rec)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_txn_query_rec';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
 --  SAVEPOINT       dump_txn_sort_rec;

put_line('                                       ');
put_line('Dumping the values for Transaction sort Record:');
put_line('                                       ');
put_line('transaction_date             : '||p_txn_sort_rec.transaction_date );
put_line('transaction_type_id          : '||p_txn_sort_rec.transaction_type_id );

EXCEPTION
        WHEN OTHERS THEN
         --       ROLLBACK TO  dump_txn_sort_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_txn_sort_rec;

PROCEDURE dump_txn_error_rec
     (p_txn_error_rec             IN  csi_datastructures_pub.transaction_error_rec)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_txn_error_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
--   SAVEPOINT       dump_txn_error_rec;

put_line('                                       ');
put_line('Dumping the values for Transaction Error Record:');
put_line('                                       ');
put_line('transaction_error_id         : '|| p_txn_error_rec.transaction_error_id );
put_line('transaction_id               : '|| p_txn_error_rec.transaction_id );
put_line('message_id                   : '|| p_txn_error_rec.message_id );
put_line('error_text                   : '|| p_txn_error_rec.error_text );
put_line('source_type                  : '|| p_txn_error_rec.source_type );
put_line('source_id                    : '|| p_txn_error_rec.source_id );
put_line('processed_flag               : '|| p_txn_error_rec.processed_flag );
put_line('object_version_number        : '|| p_txn_error_rec.object_version_number );
put_line('transaction_type_id          : '|| p_txn_error_rec.transaction_type_id );
put_line('source_group_ref                     : '|| p_txn_error_rec.source_group_ref );
put_line('source_group_ref_id          : '|| p_txn_error_rec.source_group_ref_id );
put_line('source_header_ref                    : '|| p_txn_error_rec.source_header_ref );
put_line('source_header_ref_id         : '|| p_txn_error_rec.source_header_ref_id );
put_line('source_line_ref                      : '|| p_txn_error_rec.source_line_ref );
put_line('source_line_ref_id               : '|| p_txn_error_rec.source_line_ref_id );
put_line('source_dist_ref_id1              : '|| p_txn_error_rec.source_dist_ref_id1 );
put_line('source_dist_ref_id2              : '|| p_txn_error_rec.source_dist_ref_id2 );
put_line('inv_material_transaction_id  : '|| p_txn_error_rec.inv_material_transaction_id );
put_line('error_stage  : '|| p_txn_error_rec.error_stage );
put_line('message_string  : '|| p_txn_error_rec.message_string );
EXCEPTION
        WHEN OTHERS THEN
            --    ROLLBACK TO  dump_txn_error_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_txn_error_rec;

PROCEDURE dump_rel_rec
     (p_rel_rec             IN  csi_datastructures_pub.ii_relationship_rec)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_rel_rec';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT       dump_rel_rec;

put_line('                                       ');
put_line('Dumping the values for Instance-Instance relationship Record:');
put_line('                                       ');
put_line('relationship_id              : '|| p_rel_rec.relationship_id );
put_line('relationship_type_code       : '|| p_rel_rec.relationship_type_code );
put_line('object_id                    : '|| p_rel_rec.object_id );
put_line('subject_id                   : '|| p_rel_rec.subject_id );
put_line('position_reference           : '|| p_rel_rec.position_reference );
put_line('active_start_date            : '|| p_rel_rec.active_start_date );
put_line('active_end_date              : '|| p_rel_rec.active_end_date );
put_line('display_order                : '|| p_rel_rec.display_order );
put_line('mandatory_flag               : '|| p_rel_rec.mandatory_flag );
put_line('context                      : '|| p_rel_rec.context );
put_line('attribute1                   : '|| p_rel_rec.attribute1 );
put_line('attribute2                   : '|| p_rel_rec.attribute2 );
put_line('attribute3                   : '|| p_rel_rec.attribute3 );
put_line('attribute4                   : '|| p_rel_rec.attribute4 );
put_line('attribute5                   : '|| p_rel_rec.attribute5 );
put_line('attribute6                   : '|| p_rel_rec.attribute6 );
put_line('attribute7                   : '|| p_rel_rec.attribute7 );
put_line('attribute8                   : '|| p_rel_rec.attribute8 );
put_line('attribute9                   : '|| p_rel_rec.attribute9 );
put_line('attribute10                  : '|| p_rel_rec.attribute10 );
put_line('attribute11                  : '|| p_rel_rec.attribute11 );
put_line('attribute12                  : '|| p_rel_rec.attribute12 );
put_line('attribute13                  : '|| p_rel_rec.attribute13 );
put_line('attribute14                  : '|| p_rel_rec.attribute14 );
put_line('attribute15                  : '|| p_rel_rec.attribute15 );
put_line('object_version_number        : '|| p_rel_rec.object_version_number );



EXCEPTION
        WHEN OTHERS THEN
         --       ROLLBACK TO  dump_rel_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_rel_rec;


PROCEDURE dump_rel_tbl
     (p_rel_tbl             IN  csi_datastructures_pub.ii_relationship_tbl)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_rel_tbl';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

        -- Standard Start of API savepoint
  --      SAVEPOINT       dump_rel_tbl;
        IF p_rel_tbl.COUNT > 0 THEN
           FOR tab_row IN p_rel_tbl.FIRST .. p_rel_tbl.LAST
           LOOP
             IF p_rel_tbl.EXISTS(tab_row) THEN
                   dump_rel_rec(p_rel_rec => p_rel_tbl(tab_row));
             END IF;
           END LOOP;
         END IF;



EXCEPTION
        WHEN OTHERS THEN
        --        ROLLBACK TO  dump_rel_tbl;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_rel_tbl;

PROCEDURE dump_rel_query_rec
     (p_rel_query_rec             IN  csi_datastructures_pub.relationship_query_rec)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_rel_query_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
 --  SAVEPOINT       dump_rel_query_rec;

put_line('                                       ');
put_line('Dumping the values for Instance-Instance relationship query Record:');
put_line('                                       ');
put_line('relationship_id              : '|| p_rel_query_rec.relationship_id );
put_line('relationship_type_code       : '|| p_rel_query_rec.relationship_type_code );
put_line('object_id                    : '|| p_rel_query_rec.object_id );
put_line('subject_id                   : '|| p_rel_query_rec.subject_id );


EXCEPTION
        WHEN OTHERS THEN
       --         ROLLBACK TO  dump_rel_query_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_rel_query_rec;

PROCEDURE dump_sys_rec
     (P_system_rec             IN  csi_datastructures_pub.system_rec)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_sys_rec';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT       dump_sys_rec;

put_line('                                       ');
put_line('Dumping the values for System Record:');
put_line('                                       ');
put_line('system_id                    : '|| p_system_rec.system_id );
put_line('customer_id                  : '|| p_system_rec.customer_id );
put_line('system_type_code             : '|| p_system_rec.system_type_code );
put_line('system_number                : '|| p_system_rec.system_number );
put_line('parent_system_id             : '|| p_system_rec.parent_system_id );
put_line('ship_to_contact_id           : '|| p_system_rec.ship_to_contact_id );
put_line('bill_to_contact_id           : '|| p_system_rec.bill_to_contact_id );
put_line('technical_contact_id         : '|| p_system_rec.technical_contact_id );
put_line('service_admin_contact_id     : '|| p_system_rec.service_admin_contact_id );
put_line('ship_to_site_use_id          : '|| p_system_rec.ship_to_site_use_id );
put_line('bill_to_site_use_id          : '|| p_system_rec.bill_to_site_use_id );
put_line('install_site_use_id          : '|| p_system_rec.install_site_use_id );
put_line('coterminate_day_month        : '|| p_system_rec.coterminate_day_month );
put_line('autocreated_from_system_id   : '|| p_system_rec.autocreated_from_system_id );
put_line('config_system_type           : '|| p_system_rec.config_system_type );
put_line('start_date_active            : '|| p_system_rec.start_date_active );
put_line('end_date_active              : '|| p_system_rec.end_date_active );
put_line('context                      : '|| p_system_rec.context );
put_line('attribute1                   : '|| p_system_rec.attribute1 );
put_line('attribute2                   : '|| p_system_rec.attribute2 );
put_line('attribute3                   : '|| p_system_rec.attribute3 );
put_line('attribute4                   : '|| p_system_rec.attribute4 );
put_line('attribute5                   : '|| p_system_rec.attribute5 );
put_line('attribute6                   : '|| p_system_rec.attribute6 );
put_line('attribute7                   : '|| p_system_rec.attribute7 );
put_line('attribute8                   : '|| p_system_rec.attribute8 );
put_line('attribute9                   : '|| p_system_rec.attribute9 );
put_line('attribute10                  : '|| p_system_rec.attribute10 );
put_line('attribute11                  : '|| p_system_rec.attribute11 );
put_line('attribute12                  : '|| p_system_rec.attribute12 );
put_line('attribute13                  : '|| p_system_rec.attribute13 );
put_line('attribute14                  : '|| p_system_rec.attribute14 );
put_line('attribute15                  : '|| p_system_rec.attribute15 );
put_line('object_version_number        : '|| p_system_rec.object_version_number );
put_line('name                         : '|| p_system_rec.name );
put_line('description                  : '|| p_system_rec.description );
put_line('tech_cont_change_flag        : '|| p_system_rec.tech_cont_change_flag );
put_line('bill_to_cont_change_flag     : '|| p_system_rec.bill_to_cont_change_flag );
put_line('ship_to_cont_change_flag     : '|| p_system_rec.ship_to_cont_change_flag );
put_line('serv_admin_cont_change_flag  : '|| p_system_rec.serv_admin_cont_change_flag );
put_line('bill_to_site_change_flag     : '|| p_system_rec.bill_to_site_change_flag );
put_line('ship_to_site_change_flag     : '|| p_system_rec.ship_to_site_change_flag );
put_line('install_to_site_change_flag  : '|| p_system_rec.install_to_site_change_flag );


EXCEPTION
        WHEN OTHERS THEN
      --          ROLLBACK TO  dump_sys_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_sys_rec;



PROCEDURE dump_sys_tbl
     (p_systems_tbl             IN  csi_datastructures_pub.systems_tbl)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_sys_tbl';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

        -- Standard Start of API savepoint
   --     SAVEPOINT       dump_sys_tbl;
        IF p_systems_tbl.COUNT > 0 THEN
           FOR tab_row IN p_systems_tbl.FIRST .. p_systems_tbl.LAST
           LOOP
             IF p_systems_tbl.EXISTS(tab_row) THEN
                   dump_sys_rec(p_system_rec => p_systems_tbl(tab_row));
             END IF;
           END LOOP;
         END IF;



EXCEPTION
        WHEN OTHERS THEN
           --    ROLLBACK TO  dump_sys_tbl;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_sys_tbl;


PROCEDURE dump_sys_query_rec
     (p_system_query_rec             IN  csi_datastructures_pub.system_query_rec)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_sys_query_rec';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT       dump_sys_query_rec;

put_line('                                       ');
put_line('Dumping the values for System query Record:');
put_line('                                       ');
put_line('system_id                    : '|| p_system_query_rec.system_id );
put_line('system_type_code             : '|| p_system_query_rec.system_type_code );
put_line('system_number                : '|| p_system_query_rec.system_number );



EXCEPTION
        WHEN OTHERS THEN
    --            ROLLBACK TO  dump_sys_query_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;

END dump_sys_query_rec;

PROCEDURE dump_ext_attrib_rec
     (p_ext_attrib_rec           IN  csi_datastructures_pub.ext_attrib_rec)
IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'dump_ext_attrib_rec';
        l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN

        -- Standard Start of API savepoint
     --   SAVEPOINT       dump_ext_attrib_pvt;

put_line('                                       ');
put_line('Dumping the values for Extended attribs Record:');
put_line('                                       ');
put_line('attribute_id                 : '|| p_ext_attrib_rec.attribute_id );
put_line('attribute_level              : '|| p_ext_attrib_rec.attribute_level );
put_line('master_organization_id       : '|| p_ext_attrib_rec.master_organization_id );
put_line('inventory_item_id            : '|| p_ext_attrib_rec.inventory_item_id );
put_line('item_category_id             : '|| p_ext_attrib_rec.item_category_id );
put_line('instance_id                  : '|| p_ext_attrib_rec.instance_id );
put_line('attribute_code               : '|| p_ext_attrib_rec.attribute_code );
put_line('attribute_name               : '|| p_ext_attrib_rec.attribute_name );
put_line('attribute_category           : '|| p_ext_attrib_rec.attribute_category );
put_line('description                  : '|| p_ext_attrib_rec.description );
put_line('active_start_date            : '|| p_ext_attrib_rec.active_start_date );
put_line('active_end_date              : '|| p_ext_attrib_rec.active_end_date );
put_line('context                      : '|| p_ext_attrib_rec.context );
put_line('attribute1                   : '|| p_ext_attrib_rec.attribute1 );
put_line('attribute2                   : '|| p_ext_attrib_rec.attribute2 );
put_line('attribute3                   : '|| p_ext_attrib_rec.attribute3 );
put_line('attribute4                   : '|| p_ext_attrib_rec.attribute4 );
put_line('attribute5                   : '|| p_ext_attrib_rec.attribute5 );
put_line('attribute6                   : '|| p_ext_attrib_rec.attribute6 );
put_line('attribute7                   : '|| p_ext_attrib_rec.attribute7 );
put_line('attribute8                   : '|| p_ext_attrib_rec.attribute8 );
put_line('attribute9                   : '|| p_ext_attrib_rec.attribute9 );
put_line('attribute10                  : '|| p_ext_attrib_rec.attribute10 );
put_line('attribute11                  : '|| p_ext_attrib_rec.attribute11 );
put_line('attribute12                  : '|| p_ext_attrib_rec.attribute12 );
put_line('attribute13                  : '|| p_ext_attrib_rec.attribute13 );
put_line('attribute14                  : '|| p_ext_attrib_rec.attribute14 );
put_line('attribute15                  : '|| p_ext_attrib_rec.attribute15 );
put_line('object_version_number        : '|| p_ext_attrib_rec.object_version_number );

EXCEPTION
        WHEN OTHERS THEN
     --           ROLLBACK TO  dump_ext_attrib_pvt;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME          ,
                        l_api_name
                     );
                END IF;
END dump_ext_attrib_rec;


PROCEDURE dump_inst_party_id
  (p_instance_party_id_lst IN  csi_datastructures_pub.id_tbl
     ) IS
 l_api_name      CONSTANT VARCHAR2(30)   := 'dump_inst_party_id';
 l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN
-- Standard Start of API savepoint
  -- SAVEPOINT       dump_inst_party_id;

FOR i IN p_instance_party_id_lst.FIRST..p_instance_party_id_lst.LAST LOOP

   PUT_LINE ('Instance Party id        :'||p_instance_party_id_lst(i));
END LOOP;

EXCEPTION
      WHEN OTHERS THEN
       --    ROLLBACK TO  dump_inst_party_id;
            IF      FND_MSG_PUB.Check_Msg_Level
                    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
            FND_MSG_PUB.Add_Exc_Msg
              (       g_pkg_name          ,
                      l_api_name           );
            END IF;
END dump_inst_party_id ;


PROCEDURE dump_instance_asset_rec
 (  p_instance_asset_rec  IN  csi_datastructures_pub.instance_asset_rec
     ) IS
    l_api_name      CONSTANT VARCHAR2(30)   := 'dump_instance_asset_rec';
    l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
--   SAVEPOINT       dump_instance_asset_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Asset Record:');
PUT_LINE ('                                       ');
PUT_LINE ('instance_asset_id           :'||p_instance_asset_rec.instance_asset_id);
PUT_LINE ('instance_id                 :'||p_instance_asset_rec.instance_id);
PUT_LINE ('fa_asset_id                 :'||p_instance_asset_rec.fa_asset_id);
PUT_LINE ('fa_book_type_code           :'||p_instance_asset_rec.fa_book_type_code);
PUT_LINE ('fa_location_id              :'||p_instance_asset_rec.fa_location_id);
PUT_LINE ('asset_quantity              :'||p_instance_asset_rec.asset_quantity);
PUT_LINE ('update_status               :'||p_instance_asset_rec.update_status);
PUT_LINE ('active_start_date           :'||p_instance_asset_rec.active_start_date);
PUT_LINE ('active_end_date             :'||p_instance_asset_rec.active_end_date);
PUT_LINE ('fa_sync_flag                :'||p_instance_asset_rec.fa_sync_flag);
PUT_LINE ('fa_sync_validation_reqd     :'||p_instance_asset_rec.fa_sync_validation_reqd);
PUT_LINE ('object_version_number       :'||p_instance_asset_rec.object_version_number);

EXCEPTION
        WHEN OTHERS THEN
--                ROLLBACK TO  dump_instance_asset_rec;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name           );
                END IF;
END dump_instance_asset_rec;


PROCEDURE dump_party_query_rec
     (p_party_query_rec             IN  csi_datastructures_pub.party_query_rec
      ) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_party_query_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
 --  SAVEPOINT       dump_party_query_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Party Query Record:');
PUT_LINE ('                                       ');
PUT_LINE ('instance_party_id           :'||p_party_query_rec.instance_party_id);
PUT_LINE ('instance_id                 :'||p_party_query_rec.instance_id);
PUT_LINE ('party_id                    :'||p_party_query_rec.party_id);
PUT_LINE ('relationship_type_code      :'||p_party_query_rec.relationship_type_code);

EXCEPTION
        WHEN OTHERS THEN
    --            ROLLBACK TO  dump_party_query_rec;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                );
                END IF;
END dump_party_query_rec;


PROCEDURE dump_organization_unit_rec
     (p_org_unit_rec        IN  csi_datastructures_pub.organization_units_rec)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_organization_unit_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT    dump_organization_unit_rec;
PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Org. Assignments Record:');
PUT_LINE ('                                       ');
PUT_LINE ('instance_ou_id              :'||p_org_unit_rec.instance_ou_id);
PUT_LINE ('instance_id                 :'||p_org_unit_rec.instance_id);
PUT_LINE ('operating_unit_id           :'||p_org_unit_rec.operating_unit_id);
PUT_LINE ('relationship_type_code      :'||p_org_unit_rec.relationship_type_code);
PUT_LINE ('active_start_date           :'||p_org_unit_rec.active_start_date);
PUT_LINE ('active_end_date             :'||p_org_unit_rec.active_end_date);
PUT_LINE ('context                     :'||p_org_unit_rec.context);
PUT_LINE ('attribute1                  :'||p_org_unit_rec.attribute1);
PUT_LINE ('attribute2                  :'||p_org_unit_rec.attribute2);
PUT_LINE ('attribute3                  :'||p_org_unit_rec.attribute3);
PUT_LINE ('attribute4                  :'||p_org_unit_rec.attribute4);
PUT_LINE ('attribute5                  :'||p_org_unit_rec.attribute5);
PUT_LINE ('attribute6                  :'||p_org_unit_rec.attribute6);
PUT_LINE ('attribute7                  :'||p_org_unit_rec.attribute7);
PUT_LINE ('attribute8                  :'||p_org_unit_rec.attribute8);
PUT_LINE ('attribute9                  :'||p_org_unit_rec.attribute9);
PUT_LINE ('attribute10                 :'||p_org_unit_rec.attribute10);
PUT_LINE ('attribute11                 :'||p_org_unit_rec.attribute11);
PUT_LINE ('attribute12                 :'||p_org_unit_rec.attribute12);
PUT_LINE ('attribute13                 :'||p_org_unit_rec.attribute13);
PUT_LINE ('attribute14                 :'||p_org_unit_rec.attribute14);
PUT_LINE ('attribute15                 :'||p_org_unit_rec.attribute15);
PUT_LINE ('object_version_number       :'||p_org_unit_rec.object_version_number);

EXCEPTION
        WHEN OTHERS THEN
    --            ROLLBACK TO  dump_organization_unit_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                );
                END IF;

END dump_organization_unit_rec;


PROCEDURE dump_organization_unit_tbl
     (p_org_unit_tbl        IN  csi_datastructures_pub.organization_units_tbl)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'DUMP_ORGANIZATION_UNIT_TBL';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
 --  SAVEPOINT       dump_organization_unit_tbl;

IF p_org_unit_tbl.COUNT > 0 THEN
  FOR tab_row IN p_org_unit_tbl.FIRST .. p_org_unit_tbl.LAST
   LOOP
     IF p_org_unit_tbl.EXISTS(tab_row) THEN

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Org. Assignments Table Record #  :'||tab_row);
PUT_LINE ('                                       ');
PUT_LINE ('instance_ou_id              :'||p_org_unit_tbl(tab_row).instance_ou_id);
PUT_LINE ('instance_id                 :'||p_org_unit_tbl(tab_row).instance_id);
PUT_LINE ('operating_unit_id           :'||p_org_unit_tbl(tab_row).operating_unit_id);
PUT_LINE ('relationship_type_code      :'||p_org_unit_tbl(tab_row).relationship_type_code);
PUT_LINE ('active_start_date           :'||p_org_unit_tbl(tab_row).active_start_date);
PUT_LINE ('active_end_date             :'||p_org_unit_tbl(tab_row).active_end_date);
PUT_LINE ('context                     :'||p_org_unit_tbl(tab_row).context);
PUT_LINE ('attribute1                  :'||p_org_unit_tbl(tab_row).attribute1);
PUT_LINE ('attribute2                  :'||p_org_unit_tbl(tab_row).attribute2);
PUT_LINE ('attribute3                  :'||p_org_unit_tbl(tab_row).attribute3);
PUT_LINE ('attribute4                  :'||p_org_unit_tbl(tab_row).attribute4);
PUT_LINE ('attribute5                  :'||p_org_unit_tbl(tab_row).attribute5);
PUT_LINE ('attribute6                  :'||p_org_unit_tbl(tab_row).attribute6);
PUT_LINE ('attribute7                  :'||p_org_unit_tbl(tab_row).attribute7);
PUT_LINE ('attribute8                  :'||p_org_unit_tbl(tab_row).attribute8);
PUT_LINE ('attribute9                  :'||p_org_unit_tbl(tab_row).attribute9);
PUT_LINE ('attribute10                 :'||p_org_unit_tbl(tab_row).attribute10);
PUT_LINE ('attribute11                 :'||p_org_unit_tbl(tab_row).attribute11);
PUT_LINE ('attribute12                 :'||p_org_unit_tbl(tab_row).attribute12);
PUT_LINE ('attribute13                 :'||p_org_unit_tbl(tab_row).attribute13);
PUT_LINE ('attribute14                 :'||p_org_unit_tbl(tab_row).attribute14);
PUT_LINE ('attribute15                 :'||p_org_unit_tbl(tab_row).attribute15);
PUT_LINE ('object_version_number       :'||p_org_unit_tbl(tab_row).object_version_number);

      END IF;
   END LOOP;
END IF;

EXCEPTION
        WHEN OTHERS THEN
        --        ROLLBACK TO  dump_organization_unit_tbl;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name,
                        l_api_name
                     );
                END IF;

END dump_organization_unit_tbl;


PROCEDURE dump_pricing_attribs_query_rec
        (pricing_attribs_query_rec  IN  csi_datastructures_pub.pricing_attribs_query_rec)
IS
       l_api_name      CONSTANT VARCHAR2(30)   := 'dump_pricing_attribs_query_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
 --  SAVEPOINT    dump_pricing_attribs_query_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Pricing Attribs Query Record:');
PUT_LINE ('                                       ');
PUT_LINE ('pricing_attribute_id        :'||pricing_attribs_query_rec.pricing_attribute_id);
PUT_LINE ('instance_id                 :'||pricing_attribs_query_rec.instance_id);

EXCEPTION
        WHEN OTHERS THEN
          --      ROLLBACK TO  dump_pricing_attribs_query_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                    );
                END IF;

END dump_pricing_attribs_query_rec;


PROCEDURE dump_pricing_attribs_rec
        (p_pricing_attribs_rec  IN  csi_datastructures_pub.pricing_attribs_rec)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_pricing_attribs_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
 --  SAVEPOINT    dump_pricing_attribs_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Pricing Attribs Record:');
PUT_LINE ('                                       ');
PUT_LINE ('pricing_attribute_id        :'||p_pricing_attribs_rec.pricing_attribute_id);
PUT_LINE ('instance_id                 :'||p_pricing_attribs_rec.instance_id);
PUT_LINE ('active_start_date           :'||p_pricing_attribs_rec.active_start_date);
PUT_LINE ('active_end_date             :'||p_pricing_attribs_rec.active_end_date);
PUT_LINE ('pricing_context             :'||p_pricing_attribs_rec.pricing_context);
PUT_LINE ('pricing_attribute1          :'||p_pricing_attribs_rec.pricing_attribute1);
PUT_LINE ('pricing_attribute2          :'||p_pricing_attribs_rec.pricing_attribute2);
PUT_LINE ('pricing_attribute3          :'||p_pricing_attribs_rec.pricing_attribute3);
PUT_LINE ('pricing_attribute4          :'||p_pricing_attribs_rec.pricing_attribute4);
PUT_LINE ('pricing_attribute5          :'||p_pricing_attribs_rec.pricing_attribute5);
PUT_LINE ('pricing_attribute6          :'||p_pricing_attribs_rec.pricing_attribute6);
PUT_LINE ('pricing_attribute7          :'||p_pricing_attribs_rec.pricing_attribute7);
PUT_LINE ('pricing_attribute8          :'||p_pricing_attribs_rec.pricing_attribute8);
PUT_LINE ('pricing_attribute9          :'||p_pricing_attribs_rec.pricing_attribute9);
PUT_LINE ('pricing_attribute10         :'||p_pricing_attribs_rec.pricing_attribute10);
PUT_LINE ('pricing_attribute11         :'||p_pricing_attribs_rec.pricing_attribute11);
PUT_LINE ('pricing_attribute12         :'||p_pricing_attribs_rec.pricing_attribute12);
PUT_LINE ('pricing_attribute13         :'||p_pricing_attribs_rec.pricing_attribute13);
PUT_LINE ('pricing_attribute14         :'||p_pricing_attribs_rec.pricing_attribute14);
PUT_LINE ('pricing_attribute15         :'||p_pricing_attribs_rec.pricing_attribute15);
PUT_LINE ('pricing_attribute16         :'||p_pricing_attribs_rec.pricing_attribute16);
PUT_LINE ('pricing_attribute17         :'||p_pricing_attribs_rec.pricing_attribute17);
PUT_LINE ('pricing_attribute18         :'||p_pricing_attribs_rec.pricing_attribute18);
PUT_LINE ('pricing_attribute19         :'||p_pricing_attribs_rec.pricing_attribute19);
PUT_LINE ('pricing_attribute20         :'||p_pricing_attribs_rec.pricing_attribute20);
PUT_LINE ('pricing_attribute21         :'||p_pricing_attribs_rec.pricing_attribute21);
PUT_LINE ('pricing_attribute22         :'||p_pricing_attribs_rec.pricing_attribute22);
PUT_LINE ('pricing_attribute23         :'||p_pricing_attribs_rec.pricing_attribute23);
PUT_LINE ('pricing_attribute24         :'||p_pricing_attribs_rec.pricing_attribute24);
PUT_LINE ('pricing_attribute25         :'||p_pricing_attribs_rec.pricing_attribute25);
PUT_LINE ('pricing_attribute26         :'||p_pricing_attribs_rec.pricing_attribute26);
PUT_LINE ('pricing_attribute27         :'||p_pricing_attribs_rec.pricing_attribute27);
PUT_LINE ('pricing_attribute28         :'||p_pricing_attribs_rec.pricing_attribute28);
PUT_LINE ('pricing_attribute29         :'||p_pricing_attribs_rec.pricing_attribute29);
PUT_LINE ('pricing_attribute30         :'||p_pricing_attribs_rec.pricing_attribute30);
PUT_LINE ('pricing_attribute31         :'||p_pricing_attribs_rec.pricing_attribute31);
PUT_LINE ('pricing_attribute32         :'||p_pricing_attribs_rec.pricing_attribute32);
PUT_LINE ('pricing_attribute33         :'||p_pricing_attribs_rec.pricing_attribute33);
PUT_LINE ('pricing_attribute34         :'||p_pricing_attribs_rec.pricing_attribute34);
PUT_LINE ('pricing_attribute35         :'||p_pricing_attribs_rec.pricing_attribute35);
PUT_LINE ('pricing_attribute36         :'||p_pricing_attribs_rec.pricing_attribute36);
PUT_LINE ('pricing_attribute37         :'||p_pricing_attribs_rec.pricing_attribute37);
PUT_LINE ('pricing_attribute38         :'||p_pricing_attribs_rec.pricing_attribute38);
PUT_LINE ('pricing_attribute39         :'||p_pricing_attribs_rec.pricing_attribute39);
PUT_LINE ('pricing_attribute40         :'||p_pricing_attribs_rec.pricing_attribute40);
PUT_LINE ('pricing_attribute41         :'||p_pricing_attribs_rec.pricing_attribute41);
PUT_LINE ('pricing_attribute42         :'||p_pricing_attribs_rec.pricing_attribute42);
PUT_LINE ('pricing_attribute43         :'||p_pricing_attribs_rec.pricing_attribute43);
PUT_LINE ('pricing_attribute44         :'||p_pricing_attribs_rec.pricing_attribute44);
PUT_LINE ('pricing_attribute45         :'||p_pricing_attribs_rec.pricing_attribute45);
PUT_LINE ('pricing_attribute46         :'||p_pricing_attribs_rec.pricing_attribute46);
PUT_LINE ('pricing_attribute47         :'||p_pricing_attribs_rec.pricing_attribute47);
PUT_LINE ('pricing_attribute48         :'||p_pricing_attribs_rec.pricing_attribute48);
PUT_LINE ('pricing_attribute49         :'||p_pricing_attribs_rec.pricing_attribute49);
PUT_LINE ('pricing_attribute50         :'||p_pricing_attribs_rec.pricing_attribute50);
PUT_LINE ('pricing_attribute51         :'||p_pricing_attribs_rec.pricing_attribute51);
PUT_LINE ('pricing_attribute52         :'||p_pricing_attribs_rec.pricing_attribute52);
PUT_LINE ('pricing_attribute53         :'||p_pricing_attribs_rec.pricing_attribute53);
PUT_LINE ('pricing_attribute54         :'||p_pricing_attribs_rec.pricing_attribute54);
PUT_LINE ('pricing_attribute55         :'||p_pricing_attribs_rec.pricing_attribute55);
PUT_LINE ('pricing_attribute56         :'||p_pricing_attribs_rec.pricing_attribute56);
PUT_LINE ('pricing_attribute57         :'||p_pricing_attribs_rec.pricing_attribute57);
PUT_LINE ('pricing_attribute58         :'||p_pricing_attribs_rec.pricing_attribute58);
PUT_LINE ('pricing_attribute59         :'||p_pricing_attribs_rec.pricing_attribute59);
PUT_LINE ('pricing_attribute60         :'||p_pricing_attribs_rec.pricing_attribute60);
PUT_LINE ('pricing_attribute61         :'||p_pricing_attribs_rec.pricing_attribute61);
PUT_LINE ('pricing_attribute62         :'||p_pricing_attribs_rec.pricing_attribute62);
PUT_LINE ('pricing_attribute63         :'||p_pricing_attribs_rec.pricing_attribute63);
PUT_LINE ('pricing_attribute64         :'||p_pricing_attribs_rec.pricing_attribute64);
PUT_LINE ('pricing_attribute65         :'||p_pricing_attribs_rec.pricing_attribute65);
PUT_LINE ('pricing_attribute66         :'||p_pricing_attribs_rec.pricing_attribute66);
PUT_LINE ('pricing_attribute67         :'||p_pricing_attribs_rec.pricing_attribute67);
PUT_LINE ('pricing_attribute68         :'||p_pricing_attribs_rec.pricing_attribute68);
PUT_LINE ('pricing_attribute69         :'||p_pricing_attribs_rec.pricing_attribute69);
PUT_LINE ('pricing_attribute70         :'||p_pricing_attribs_rec.pricing_attribute70);
PUT_LINE ('pricing_attribute71         :'||p_pricing_attribs_rec.pricing_attribute71);
PUT_LINE ('pricing_attribute72         :'||p_pricing_attribs_rec.pricing_attribute72);
PUT_LINE ('pricing_attribute73         :'||p_pricing_attribs_rec.pricing_attribute73);
PUT_LINE ('pricing_attribute74         :'||p_pricing_attribs_rec.pricing_attribute74);
PUT_LINE ('pricing_attribute75         :'||p_pricing_attribs_rec.pricing_attribute75);
PUT_LINE ('pricing_attribute76         :'||p_pricing_attribs_rec.pricing_attribute76);
PUT_LINE ('pricing_attribute77         :'||p_pricing_attribs_rec.pricing_attribute77);
PUT_LINE ('pricing_attribute78         :'||p_pricing_attribs_rec.pricing_attribute78);
PUT_LINE ('pricing_attribute79         :'||p_pricing_attribs_rec.pricing_attribute79);
PUT_LINE ('pricing_attribute80         :'||p_pricing_attribs_rec.pricing_attribute80);
PUT_LINE ('pricing_attribute81         :'||p_pricing_attribs_rec.pricing_attribute81);
PUT_LINE ('pricing_attribute82         :'||p_pricing_attribs_rec.pricing_attribute82);
PUT_LINE ('pricing_attribute83         :'||p_pricing_attribs_rec.pricing_attribute83);
PUT_LINE ('pricing_attribute84         :'||p_pricing_attribs_rec.pricing_attribute84);
PUT_LINE ('pricing_attribute85         :'||p_pricing_attribs_rec.pricing_attribute85);
PUT_LINE ('pricing_attribute86         :'||p_pricing_attribs_rec.pricing_attribute86);
PUT_LINE ('pricing_attribute87         :'||p_pricing_attribs_rec.pricing_attribute87);
PUT_LINE ('pricing_attribute88         :'||p_pricing_attribs_rec.pricing_attribute88);
PUT_LINE ('pricing_attribute89         :'||p_pricing_attribs_rec.pricing_attribute89);
PUT_LINE ('pricing_attribute90         :'||p_pricing_attribs_rec.pricing_attribute90);
PUT_LINE ('pricing_attribute91         :'||p_pricing_attribs_rec.pricing_attribute91);
PUT_LINE ('pricing_attribute92         :'||p_pricing_attribs_rec.pricing_attribute92);
PUT_LINE ('pricing_attribute93         :'||p_pricing_attribs_rec.pricing_attribute93);
PUT_LINE ('pricing_attribute94         :'||p_pricing_attribs_rec.pricing_attribute94);
PUT_LINE ('pricing_attribute95         :'||p_pricing_attribs_rec.pricing_attribute95);
PUT_LINE ('pricing_attribute96         :'||p_pricing_attribs_rec.pricing_attribute96);
PUT_LINE ('pricing_attribute97         :'||p_pricing_attribs_rec.pricing_attribute97);
PUT_LINE ('pricing_attribute98         :'||p_pricing_attribs_rec.pricing_attribute98);
PUT_LINE ('pricing_attribute99         :'||p_pricing_attribs_rec.pricing_attribute99);
PUT_LINE ('pricing_attribute100        :'||p_pricing_attribs_rec.pricing_attribute100);
PUT_LINE ('context                     :'||p_pricing_attribs_rec.context);
PUT_LINE ('attribute1                  :'||p_pricing_attribs_rec.attribute1);
PUT_LINE ('attribute2                  :'||p_pricing_attribs_rec.attribute2);
PUT_LINE ('attribute3                  :'||p_pricing_attribs_rec.attribute3);
PUT_LINE ('attribute4                  :'||p_pricing_attribs_rec.attribute4);
PUT_LINE ('attribute5                  :'||p_pricing_attribs_rec.attribute5);
PUT_LINE ('attribute6                  :'||p_pricing_attribs_rec.attribute6);
PUT_LINE ('attribute7                  :'||p_pricing_attribs_rec.attribute7);
PUT_LINE ('attribute8                  :'||p_pricing_attribs_rec.attribute8);
PUT_LINE ('attribute9                  :'||p_pricing_attribs_rec.attribute9);
PUT_LINE ('attribute10                 :'||p_pricing_attribs_rec.attribute10);
PUT_LINE ('attribute11                 :'||p_pricing_attribs_rec.attribute11);
PUT_LINE ('attribute12                 :'||p_pricing_attribs_rec.attribute12);
PUT_LINE ('attribute13                 :'||p_pricing_attribs_rec.attribute13);
PUT_LINE ('attribute14                 :'||p_pricing_attribs_rec.attribute14);
PUT_LINE ('attribute15                 :'||p_pricing_attribs_rec.attribute15);
PUT_LINE ('object_version_number       :'||p_pricing_attribs_rec.object_version_number);

EXCEPTION
        WHEN OTHERS THEN
      --         ROLLBACK TO  dump_pricing_attribs_rec;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                    );
                END IF;

END dump_pricing_attribs_rec;

PROCEDURE dump_pricing_attribs_tbl
        (p_pricing_attribs_tbl  IN  csi_datastructures_pub.pricing_attribs_tbl)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_pricing_attribs_tbl';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT       dump_pricing_attribs_tbl;

IF p_pricing_attribs_tbl.COUNT > 0 THEN
   FOR tab_row IN p_pricing_attribs_tbl.FIRST .. p_pricing_attribs_tbl.LAST
     LOOP
      IF p_pricing_attribs_tbl.EXISTS(tab_row) THEN

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Pricing Attribs Table Record #  :'||tab_row);
PUT_LINE ('                                       ');
PUT_LINE ('pricing_attribute_id        :'||p_pricing_attribs_tbl(tab_row).pricing_attribute_id);
PUT_LINE ('instance_id                 :'||p_pricing_attribs_tbl(tab_row).instance_id);
PUT_LINE ('active_start_date           :'||p_pricing_attribs_tbl(tab_row).active_start_date);
PUT_LINE ('active_end_date             :'||p_pricing_attribs_tbl(tab_row).active_end_date);
PUT_LINE ('pricing_context             :'||p_pricing_attribs_tbl(tab_row).pricing_context);
PUT_LINE ('pricing_attribute1          :'||p_pricing_attribs_tbl(tab_row).pricing_attribute1);
PUT_LINE ('pricing_attribute2          :'||p_pricing_attribs_tbl(tab_row).pricing_attribute2);
PUT_LINE ('pricing_attribute3          :'||p_pricing_attribs_tbl(tab_row).pricing_attribute3);
PUT_LINE ('pricing_attribute4          :'||p_pricing_attribs_tbl(tab_row).pricing_attribute4);
PUT_LINE ('pricing_attribute5          :'||p_pricing_attribs_tbl(tab_row).pricing_attribute5);
PUT_LINE ('pricing_attribute6          :'||p_pricing_attribs_tbl(tab_row).pricing_attribute6);
PUT_LINE ('pricing_attribute7          :'||p_pricing_attribs_tbl(tab_row).pricing_attribute7);
PUT_LINE ('pricing_attribute8          :'||p_pricing_attribs_tbl(tab_row).pricing_attribute8);
PUT_LINE ('pricing_attribute9          :'||p_pricing_attribs_tbl(tab_row).pricing_attribute9);
PUT_LINE ('pricing_attribute10         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute10);
PUT_LINE ('pricing_attribute11         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute11);
PUT_LINE ('pricing_attribute12         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute12);
PUT_LINE ('pricing_attribute13         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute13);
PUT_LINE ('pricing_attribute14         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute14);
PUT_LINE ('pricing_attribute15         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute15);
PUT_LINE ('pricing_attribute16         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute16);
PUT_LINE ('pricing_attribute17         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute17);
PUT_LINE ('pricing_attribute18         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute18);
PUT_LINE ('pricing_attribute19         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute19);
PUT_LINE ('pricing_attribute20         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute20);
PUT_LINE ('pricing_attribute21         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute21);
PUT_LINE ('pricing_attribute22         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute22);
PUT_LINE ('pricing_attribute23         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute23);
PUT_LINE ('pricing_attribute24         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute24);
PUT_LINE ('pricing_attribute25         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute25);
PUT_LINE ('pricing_attribute26         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute26);
PUT_LINE ('pricing_attribute27         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute27);
PUT_LINE ('pricing_attribute28         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute28);
PUT_LINE ('pricing_attribute29         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute29);
PUT_LINE ('pricing_attribute30         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute30);
PUT_LINE ('pricing_attribute31         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute31);
PUT_LINE ('pricing_attribute32         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute32);
PUT_LINE ('pricing_attribute33         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute33);
PUT_LINE ('pricing_attribute34         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute34);
PUT_LINE ('pricing_attribute35         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute35);
PUT_LINE ('pricing_attribute36         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute36);
PUT_LINE ('pricing_attribute37         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute37);
PUT_LINE ('pricing_attribute38         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute38);
PUT_LINE ('pricing_attribute39         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute39);
PUT_LINE ('pricing_attribute40         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute40);
PUT_LINE ('pricing_attribute41         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute41);
PUT_LINE ('pricing_attribute42         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute42);
PUT_LINE ('pricing_attribute43         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute43);
PUT_LINE ('pricing_attribute44         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute44);
PUT_LINE ('pricing_attribute45         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute45);
PUT_LINE ('pricing_attribute46         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute46);
PUT_LINE ('pricing_attribute47         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute47);
PUT_LINE ('pricing_attribute48         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute48);
PUT_LINE ('pricing_attribute49         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute49);
PUT_LINE ('pricing_attribute50         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute50);
PUT_LINE ('pricing_attribute51         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute51);
PUT_LINE ('pricing_attribute52         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute52);
PUT_LINE ('pricing_attribute53         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute53);
PUT_LINE ('pricing_attribute54         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute54);
PUT_LINE ('pricing_attribute55         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute55);
PUT_LINE ('pricing_attribute56         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute56);
PUT_LINE ('pricing_attribute57         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute57);
PUT_LINE ('pricing_attribute58         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute58);
PUT_LINE ('pricing_attribute59         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute59);
PUT_LINE ('pricing_attribute60         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute60);
PUT_LINE ('pricing_attribute61         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute61);
PUT_LINE ('pricing_attribute62         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute62);
PUT_LINE ('pricing_attribute63         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute63);
PUT_LINE ('pricing_attribute64         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute64);
PUT_LINE ('pricing_attribute65         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute65);
PUT_LINE ('pricing_attribute66         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute66);
PUT_LINE ('pricing_attribute67         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute67);
PUT_LINE ('pricing_attribute68         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute68);
PUT_LINE ('pricing_attribute69         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute69);
PUT_LINE ('pricing_attribute70         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute70);
PUT_LINE ('pricing_attribute71         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute71);
PUT_LINE ('pricing_attribute72         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute72);
PUT_LINE ('pricing_attribute73         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute73);
PUT_LINE ('pricing_attribute74         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute74);
PUT_LINE ('pricing_attribute75         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute75);
PUT_LINE ('pricing_attribute76         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute76);
PUT_LINE ('pricing_attribute77         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute77);
PUT_LINE ('pricing_attribute78         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute78);
PUT_LINE ('pricing_attribute79         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute79);
PUT_LINE ('pricing_attribute80         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute80);
PUT_LINE ('pricing_attribute81         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute81);
PUT_LINE ('pricing_attribute82         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute82);
PUT_LINE ('pricing_attribute83         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute83);
PUT_LINE ('pricing_attribute84         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute84);
PUT_LINE ('pricing_attribute85         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute85);
PUT_LINE ('pricing_attribute86         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute86);
PUT_LINE ('pricing_attribute87         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute87);
PUT_LINE ('pricing_attribute88         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute88);
PUT_LINE ('pricing_attribute89         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute89);
PUT_LINE ('pricing_attribute90         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute90);
PUT_LINE ('pricing_attribute91         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute91);
PUT_LINE ('pricing_attribute92         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute92);
PUT_LINE ('pricing_attribute93         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute93);
PUT_LINE ('pricing_attribute94         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute94);
PUT_LINE ('pricing_attribute95         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute95);
PUT_LINE ('pricing_attribute96         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute96);
PUT_LINE ('pricing_attribute97         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute97);
PUT_LINE ('pricing_attribute98         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute98);
PUT_LINE ('pricing_attribute99         :'||p_pricing_attribs_tbl(tab_row).pricing_attribute99);
PUT_LINE ('pricing_attribute100        :'||p_pricing_attribs_tbl(tab_row).pricing_attribute100);
PUT_LINE ('context                     :'||p_pricing_attribs_tbl(tab_row).context);
PUT_LINE ('attribute1                  :'||p_pricing_attribs_tbl(tab_row).attribute1);
PUT_LINE ('attribute2                  :'||p_pricing_attribs_tbl(tab_row).attribute2);
PUT_LINE ('attribute3                  :'||p_pricing_attribs_tbl(tab_row).attribute3);
PUT_LINE ('attribute4                  :'||p_pricing_attribs_tbl(tab_row).attribute4);
PUT_LINE ('attribute5                  :'||p_pricing_attribs_tbl(tab_row).attribute5);
PUT_LINE ('attribute6                  :'||p_pricing_attribs_tbl(tab_row).attribute6);
PUT_LINE ('attribute7                  :'||p_pricing_attribs_tbl(tab_row).attribute7);
PUT_LINE ('attribute8                  :'||p_pricing_attribs_tbl(tab_row).attribute8);
PUT_LINE ('attribute9                  :'||p_pricing_attribs_tbl(tab_row).attribute9);
PUT_LINE ('attribute10                 :'||p_pricing_attribs_tbl(tab_row).attribute10);
PUT_LINE ('attribute11                 :'||p_pricing_attribs_tbl(tab_row).attribute11);
PUT_LINE ('attribute12                 :'||p_pricing_attribs_tbl(tab_row).attribute12);
PUT_LINE ('attribute13                 :'||p_pricing_attribs_tbl(tab_row).attribute13);
PUT_LINE ('attribute14                 :'||p_pricing_attribs_tbl(tab_row).attribute14);
PUT_LINE ('attribute15                 :'||p_pricing_attribs_tbl(tab_row).attribute15);
PUT_LINE ('object_version_number       :'||p_pricing_attribs_tbl(tab_row).object_version_number);

    END IF;
  END LOOP;
END IF;

EXCEPTION
        WHEN OTHERS THEN
          --      ROLLBACK TO  dump_pricing_attribs_tbl;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                );
                END IF;

END dump_pricing_attribs_tbl;


PROCEDURE dump_party_rec
 ( p_party_rec            IN  csi_datastructures_pub.party_rec
   ) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_party_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN
-- Standard Start of API savepoint
--   SAVEPOINT       dump_party_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Party Record:');
PUT_LINE ('                                       ');
PUT_LINE ('instance_party_id           :'||p_party_rec.instance_party_id);
PUT_LINE ('instance_id                 :'||p_party_rec.instance_id);
PUT_LINE ('party_source_table          :'||p_party_rec.party_source_table);
PUT_LINE ('party_id                    :'||p_party_rec.party_id);
PUT_LINE ('relationship_type_code      :'||p_party_rec.relationship_type_code);
PUT_LINE ('contact_flag                :'||p_party_rec.contact_flag);
PUT_LINE ('contact_ip_id               :'||p_party_rec.contact_ip_id);
PUT_LINE ('active_start_date           :'||p_party_rec.active_start_date);
PUT_LINE ('active_end_date             :'||p_party_rec.active_end_date);
PUT_LINE ('context                     :'||p_party_rec.context);
PUT_LINE ('attribute1                  :'||p_party_rec.attribute1);
PUT_LINE ('attribute2                  :'||p_party_rec.attribute2);
PUT_LINE ('attribute3                  :'||p_party_rec.attribute3);
PUT_LINE ('attribute4                  :'||p_party_rec.attribute4);
PUT_LINE ('attribute5                  :'||p_party_rec.attribute5);
PUT_LINE ('attribute6                  :'||p_party_rec.attribute6);
PUT_LINE ('attribute7                  :'||p_party_rec.attribute7);
PUT_LINE ('attribute8                  :'||p_party_rec.attribute8);
PUT_LINE ('attribute9                  :'||p_party_rec.attribute9);
PUT_LINE ('attribute10                 :'||p_party_rec.attribute10);
PUT_LINE ('attribute11                 :'||p_party_rec.attribute11);
PUT_LINE ('attribute12                 :'||p_party_rec.attribute12);
PUT_LINE ('attribute13                 :'||p_party_rec.attribute13);
PUT_LINE ('attribute14                 :'||p_party_rec.attribute14);
PUT_LINE ('attribute15                 :'||p_party_rec.attribute15);
PUT_LINE ('object_version_number       :'||p_party_rec.object_version_number);


EXCEPTION
        WHEN OTHERS THEN
       --         ROLLBACK TO  dump_party_rec;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name              );
                END IF;
END dump_party_rec;


PROCEDURE dump_party_tbl
  (p_party_tbl        IN  csi_datastructures_pub.party_tbl)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'DUMP_PARTY_TBL';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN
-- Standard Start of API savepoint
   -- SAVEPOINT    dump_party_tbl;

IF p_party_tbl.COUNT > 0 THEN
   FOR tab_row IN p_party_tbl.FIRST .. p_party_tbl.LAST   LOOP
    IF p_party_tbl.EXISTS(tab_row) THEN

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Party Table Record #  :'||tab_row);
PUT_LINE ('                                       ');
PUT_LINE ('instance_party_id           :'||p_party_tbl(tab_row).instance_party_id);
PUT_LINE ('instance_id                 :'||p_party_tbl(tab_row).instance_id);
PUT_LINE ('party_source_table          :'||p_party_tbl(tab_row).party_source_table);
PUT_LINE ('party_id                    :'||p_party_tbl(tab_row).party_id);
PUT_LINE ('relationship_type_code      :'||p_party_tbl(tab_row).relationship_type_code);
PUT_LINE ('contact_flag                :'||p_party_tbl(tab_row).contact_flag);
PUT_LINE ('contact_ip_id               :'||p_party_tbl(tab_row).contact_ip_id);
PUT_LINE ('active_start_date           :'||p_party_tbl(tab_row).active_start_date);
PUT_LINE ('active_end_date             :'||p_party_tbl(tab_row).active_end_date);
PUT_LINE ('context                     :'||p_party_tbl(tab_row).context);
PUT_LINE ('attribute1                  :'||p_party_tbl(tab_row).attribute1);
PUT_LINE ('attribute2                  :'||p_party_tbl(tab_row).attribute2);
PUT_LINE ('attribute3                  :'||p_party_tbl(tab_row).attribute3);
PUT_LINE ('attribute4                  :'||p_party_tbl(tab_row).attribute4);
PUT_LINE ('attribute5                  :'||p_party_tbl(tab_row).attribute5);
PUT_LINE ('attribute6                  :'||p_party_tbl(tab_row).attribute6);
PUT_LINE ('attribute7                  :'||p_party_tbl(tab_row).attribute7);
PUT_LINE ('attribute8                  :'||p_party_tbl(tab_row).attribute8);
PUT_LINE ('attribute9                  :'||p_party_tbl(tab_row).attribute9);
PUT_LINE ('attribute10                 :'||p_party_tbl(tab_row).attribute10);
PUT_LINE ('attribute11                 :'||p_party_tbl(tab_row).attribute11);
PUT_LINE ('attribute12                 :'||p_party_tbl(tab_row).attribute12);
PUT_LINE ('attribute13                 :'||p_party_tbl(tab_row).attribute13);
PUT_LINE ('attribute14                 :'||p_party_tbl(tab_row).attribute14);
PUT_LINE ('attribute15                 :'||p_party_tbl(tab_row).attribute15);
PUT_LINE ('object_version_number       :'||p_party_tbl(tab_row).object_version_number);
     END IF;
   END LOOP;
END IF;
EXCEPTION
        WHEN OTHERS THEN
              --  ROLLBACK TO  dump_party_tbl;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name      );
                END IF;
END dump_party_tbl;

PROCEDURE dump_version_label_rec
(   p_version_label_rec    IN  csi_datastructures_pub.version_label_rec
    ) IS

    l_api_name      CONSTANT VARCHAR2(30)   := 'dump_version_label_rec';
    l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT    dump_version_label_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Version Labels Record:');
PUT_LINE ('                                       ');
PUT_LINE ('version_label_id            :'||p_version_label_rec.version_label_id);
PUT_LINE ('instance_id                 :'||p_version_label_rec.instance_id);
PUT_LINE ('version_label               :'||p_version_label_rec.version_label);
PUT_LINE ('description                 :'||p_version_label_rec.description);
PUT_LINE ('date_time_stamp             :'||p_version_label_rec.date_time_stamp);
PUT_LINE ('active_start_date           :'||p_version_label_rec.active_start_date);
PUT_LINE ('active_end_date             :'||p_version_label_rec.active_end_date);
PUT_LINE ('context                     :'||p_version_label_rec.context);
PUT_LINE ('attribute1                  :'||p_version_label_rec.attribute1);
PUT_LINE ('attribute2                  :'||p_version_label_rec.attribute2);
PUT_LINE ('attribute3                  :'||p_version_label_rec.attribute3);
PUT_LINE ('attribute4                  :'||p_version_label_rec.attribute4);
PUT_LINE ('attribute5                  :'||p_version_label_rec.attribute5);
PUT_LINE ('attribute6                  :'||p_version_label_rec.attribute6);
PUT_LINE ('attribute7                  :'||p_version_label_rec.attribute7);
PUT_LINE ('attribute8                  :'||p_version_label_rec.attribute8);
PUT_LINE ('attribute9                  :'||p_version_label_rec.attribute9);
PUT_LINE ('attribute10                 :'||p_version_label_rec.attribute10);
PUT_LINE ('attribute11                 :'||p_version_label_rec.attribute11);
PUT_LINE ('attribute12                 :'||p_version_label_rec.attribute12);
PUT_LINE ('attribute13                 :'||p_version_label_rec.attribute13);
PUT_LINE ('attribute14                 :'||p_version_label_rec.attribute14);
PUT_LINE ('attribute15                 :'||p_version_label_rec.attribute15);
PUT_LINE ('object_version_number       :'||p_version_label_rec.object_version_number);

EXCEPTION
        WHEN OTHERS THEN
              --  ROLLBACK TO  dump_version_label_rec;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name      );
                END IF;
END dump_version_label_rec;

PROCEDURE dump_version_label_tbl
 (  p_version_label_tbl            IN  csi_datastructures_pub.version_label_tbl
    ) IS

    l_api_name  CONSTANT VARCHAR2(30)   := 'dump_version_label_tbl';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

-- Standard Start of API savepoint
  -- SAVEPOINT    dump_version_label_tbl;

IF p_version_label_tbl.COUNT > 0 THEN
   FOR tab_row IN p_version_label_tbl.FIRST .. p_version_label_tbl.LAST   LOOP

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Version Labels Table Record #  :'||tab_row);
PUT_LINE ('                                       ');
PUT_LINE ('version_label_id            :'||p_version_label_tbl(tab_row).version_label_id);
PUT_LINE ('instance_id                 :'||p_version_label_tbl(tab_row).instance_id);
PUT_LINE ('version_label               :'||p_version_label_tbl(tab_row).version_label);
PUT_LINE ('description                 :'||p_version_label_tbl(tab_row).description);
PUT_LINE ('date_time_stamp             :'||p_version_label_tbl(tab_row).date_time_stamp);
PUT_LINE ('active_start_date           :'||p_version_label_tbl(tab_row).active_start_date);
PUT_LINE ('active_end_date             :'||p_version_label_tbl(tab_row).active_end_date);
PUT_LINE ('context                     :'||p_version_label_tbl(tab_row).context);
PUT_LINE ('attribute1                  :'||p_version_label_tbl(tab_row).attribute1);
PUT_LINE ('attribute2                  :'||p_version_label_tbl(tab_row).attribute2);
PUT_LINE ('attribute3                  :'||p_version_label_tbl(tab_row).attribute3);
PUT_LINE ('attribute4                  :'||p_version_label_tbl(tab_row).attribute4);
PUT_LINE ('attribute5                  :'||p_version_label_tbl(tab_row).attribute5);
PUT_LINE ('attribute6                  :'||p_version_label_tbl(tab_row).attribute6);
PUT_LINE ('attribute7                  :'||p_version_label_tbl(tab_row).attribute7);
PUT_LINE ('attribute8                  :'||p_version_label_tbl(tab_row).attribute8);
PUT_LINE ('attribute9                  :'||p_version_label_tbl(tab_row).attribute9);
PUT_LINE ('attribute10                 :'||p_version_label_tbl(tab_row).attribute10);
PUT_LINE ('attribute11                 :'||p_version_label_tbl(tab_row).attribute11);
PUT_LINE ('attribute12                 :'||p_version_label_tbl(tab_row).attribute12);
PUT_LINE ('attribute13                 :'||p_version_label_tbl(tab_row).attribute13);
PUT_LINE ('attribute14                 :'||p_version_label_tbl(tab_row).attribute14);
PUT_LINE ('attribute15                 :'||p_version_label_tbl(tab_row).attribute15);
PUT_LINE ('object_version_number       :'||p_version_label_tbl(tab_row).object_version_number);
   END LOOP;
END IF;
EXCEPTION
        WHEN OTHERS THEN
             --   ROLLBACK TO  dump_version_label_tbl;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name      );
                END IF;
END dump_version_label_tbl;


PROCEDURE dump_party_account_tbl
  (p_party_account_tbl        IN  csi_datastructures_pub.party_account_tbl
    ) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'DUMP_PARTY_ACCOUNT_TBL';
        l_api_version   CONSTANT NUMBER         := 1.0;

BEGIN

-- Standard Start of API savepoint
   -- SAVEPOINT    dump_party_account_tbl;

IF p_party_account_tbl.COUNT > 0 THEN
   FOR tab_row IN p_party_account_tbl.FIRST .. p_party_account_tbl.LAST   LOOP

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Party Account Table Record #  :'||tab_row);
PUT_LINE ('                                       ');
PUT_LINE ('ip_account_id               :'||p_party_account_tbl(tab_row).ip_account_id);
PUT_LINE ('parent_tbl_index            :'||p_party_account_tbl(tab_row).parent_tbl_index);
PUT_LINE ('instance_party_id           :'||p_party_account_tbl(tab_row).instance_party_id);
PUT_LINE ('party_account_id            :'||p_party_account_tbl(tab_row).party_account_id);
PUT_LINE ('relationship_type_code      :'||p_party_account_tbl(tab_row).relationship_type_code);
PUT_LINE ('active_start_date           :'||p_party_account_tbl(tab_row).active_start_date);
PUT_LINE ('active_end_date             :'||p_party_account_tbl(tab_row).active_end_date);
PUT_LINE ('context                     :'||p_party_account_tbl(tab_row).context);
PUT_LINE ('attribute1                  :'||p_party_account_tbl(tab_row).attribute1);
PUT_LINE ('attribute2                  :'||p_party_account_tbl(tab_row).attribute2);
PUT_LINE ('attribute3                  :'||p_party_account_tbl(tab_row).attribute3);
PUT_LINE ('attribute4                  :'||p_party_account_tbl(tab_row).attribute4);
PUT_LINE ('attribute5                  :'||p_party_account_tbl(tab_row).attribute5);
PUT_LINE ('attribute6                  :'||p_party_account_tbl(tab_row).attribute6);
PUT_LINE ('attribute7                  :'||p_party_account_tbl(tab_row).attribute7);
PUT_LINE ('attribute8                  :'||p_party_account_tbl(tab_row).attribute8);
PUT_LINE ('attribute9                  :'||p_party_account_tbl(tab_row).attribute9);
PUT_LINE ('attribute10                 :'||p_party_account_tbl(tab_row).attribute10);
PUT_LINE ('attribute11                 :'||p_party_account_tbl(tab_row).attribute11);
PUT_LINE ('attribute12                 :'||p_party_account_tbl(tab_row).attribute12);
PUT_LINE ('attribute13                 :'||p_party_account_tbl(tab_row).attribute13);
PUT_LINE ('attribute14                 :'||p_party_account_tbl(tab_row).attribute14);
PUT_LINE ('attribute15                 :'||p_party_account_tbl(tab_row).attribute15);
PUT_LINE ('object_version_number       :'||p_party_account_tbl(tab_row).object_version_number);
PUT_LINE ('call_contracts              :'||p_party_account_tbl(tab_row).call_contracts);

  END LOOP;
END IF;
EXCEPTION
        WHEN OTHERS THEN
              --  ROLLBACK TO  dump_party_account_tbl;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name      );
                END IF;
END dump_party_account_tbl;

PROCEDURE dump_party_account_rec
 ( p_party_account_rec            IN  csi_datastructures_pub.party_account_rec
   ) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_party_account_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN
-- Standard Start of API savepoint
  -- SAVEPOINT       dump_party_account_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Party Account Record:');
PUT_LINE ('                                       ');
PUT_LINE ('ip_account_id               :'||p_party_account_rec.ip_account_id);
PUT_LINE ('parent_tbl_index            :'||p_party_account_rec.parent_tbl_index);
PUT_LINE ('instance_party_id           :'||p_party_account_rec.instance_party_id);
PUT_LINE ('party_account_id            :'||p_party_account_rec.party_account_id);
PUT_LINE ('relationship_type_code      :'||p_party_account_rec.relationship_type_code);
PUT_LINE ('bill_to_address             :'||p_party_account_rec.bill_to_address);
PUT_LINE ('ship_to_address             :'||p_party_account_rec.ship_to_address);
PUT_LINE ('active_start_date           :'||p_party_account_rec.active_start_date);
PUT_LINE ('active_end_date             :'||p_party_account_rec.active_end_date);
PUT_LINE ('context                     :'||p_party_account_rec.context);
PUT_LINE ('attribute1                  :'||p_party_account_rec.attribute1);
PUT_LINE ('attribute2                  :'||p_party_account_rec.attribute2);
PUT_LINE ('attribute3                  :'||p_party_account_rec.attribute3);
PUT_LINE ('attribute4                  :'||p_party_account_rec.attribute4);
PUT_LINE ('attribute5                  :'||p_party_account_rec.attribute5);
PUT_LINE ('attribute6                  :'||p_party_account_rec.attribute6);
PUT_LINE ('attribute7                  :'||p_party_account_rec.attribute7);
PUT_LINE ('attribute8                  :'||p_party_account_rec.attribute8);
PUT_LINE ('attribute9                  :'||p_party_account_rec.attribute9);
PUT_LINE ('attribute10                 :'||p_party_account_rec.attribute10);
PUT_LINE ('attribute11                 :'||p_party_account_rec.attribute11);
PUT_LINE ('attribute12                 :'||p_party_account_rec.attribute12);
PUT_LINE ('attribute13                 :'||p_party_account_rec.attribute13);
PUT_LINE ('attribute14                 :'||p_party_account_rec.attribute14);
PUT_LINE ('attribute15                 :'||p_party_account_rec.attribute15);
PUT_LINE ('object_version_number       :'||p_party_account_rec.object_version_number);
PUT_LINE ('call_contracts              :'||p_party_account_rec.call_contracts);

EXCEPTION
        WHEN OTHERS THEN
              --  ROLLBACK TO  dump_party_account_rec;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name              );
                END IF;
END dump_party_account_rec;


PROCEDURE dump_account_query_rec
     (p_account_query_rec          IN  csi_datastructures_pub.party_account_query_rec
      ) IS

        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_account_query_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN
-- Standard Start of API savepoint
  -- SAVEPOINT       dump_account_query_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Party Account Query Record:');
PUT_LINE ('                                       ');
PUT_LINE ('ip_account_id               :'||p_account_query_rec.ip_account_id);
PUT_LINE ('instance_party_id           :'||p_account_query_rec.instance_party_id);
PUT_LINE ('party_account_id            :'||p_account_query_rec.party_account_id);
PUT_LINE ('relationship_type_code      :'||p_account_query_rec.relationship_type_code);

EXCEPTION
        WHEN OTHERS THEN
             --   ROLLBACK TO  dump_account_query_rec;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name              );
                END IF;
END dump_account_query_rec ;

PROCEDURE dump_asset_query_rec
  (  p_asset_query_rec           IN  csi_datastructures_pub.instance_asset_query_rec
     ) IS

        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_asset_query_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN
-- Standard Start of API savepoint
--   SAVEPOINT       dump_asset_query_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Instance Assets Query Record:');
PUT_LINE ('                                       ');
PUT_LINE ('instance_asset_id           :'||p_asset_query_rec.instance_asset_id);
PUT_LINE ('instance_id                 :'||p_asset_query_rec.instance_id);
PUT_LINE ('fa_asset_id                 :'||p_asset_query_rec.fa_asset_id);
PUT_LINE ('fa_book_type_code           :'||p_asset_query_rec.fa_book_type_code);
PUT_LINE ('fa_location_id              :'||p_asset_query_rec.fa_location_id);
PUT_LINE ('update_status               :'||p_asset_query_rec.update_status);

EXCEPTION
        WHEN OTHERS THEN
--                ROLLBACK TO  dump_asset_query_rec;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name              );
                END IF;
END  dump_asset_query_rec  ;

PROCEDURE dump_ver_label_query_rec
   (  p_version_label_query_rec   IN  csi_datastructures_pub.version_label_query_rec
      )IS

        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_ver_label_query_rec';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN
-- Standard Start of API savepoint
  -- SAVEPOINT       dump_ver_label_query_rec;

PUT_LINE ('                                       ');
PUT_LINE ('Dumping the values for Version Labels Query Record:');
PUT_LINE ('                                       ');
PUT_LINE ('version_label_id            :'||p_version_label_query_rec.version_label_id);
PUT_LINE ('instance_id                 :'||p_version_label_query_rec.instance_id);
PUT_LINE ('version_label               :'||p_version_label_query_rec.version_label);
PUT_LINE ('date_time_stamp             :'||p_version_label_query_rec.date_time_stamp);

EXCEPTION
        WHEN OTHERS THEN
             --   ROLLBACK TO  dump_ver_label_query_rec;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name              );
                END IF;
END  dump_ver_label_query_rec  ;


PROCEDURE dump_id_tbl
        (id_tbl  IN  csi_datastructures_pub.id_tbl)
IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'dump_id_tbl';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN

 -- Standard Start of API savepoint
  -- SAVEPOINT    dump_id_tbl;

   IF id_tbl.COUNT > 0 THEN
    FOR tab_row IN id_tbl.FIRST .. id_tbl.LAST   LOOP
            PUT_LINE (
                id_tbl(tab_row));
    END LOOP;
   END IF;

EXCEPTION
        WHEN OTHERS THEN
               -- ROLLBACK TO  dump_id_tbl;

                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name
                    );
                END IF;

END dump_id_tbl;

PROCEDURE dump_x_msg_data
        (p_msg_count IN NUMBER, x_msg_data OUT NOCOPY VARCHAR2)
IS
l_msg_index     NUMBER:=0;
l_msg_data      VARCHAR2(2000):=NULL;
l_msg_count     NUMBER:=0;
l_msg_dummy     NUMBER:=0;
BEGIN
  fnd_msg_pub.count_and_get
                     (       p_count => l_msg_count,
                             p_data  => l_msg_data
                      );

  FOR l_msg_index IN  1..l_msg_count
  LOOP
  fnd_msg_pub.get ( l_msg_index
                  , fnd_api.g_false
                  , l_msg_data
                  , l_msg_dummy );
  x_msg_data := ltrim(x_msg_data||' '||l_msg_data);
  END LOOP;

END dump_x_msg_data;
--
PROCEDURE dump_oks_txn_inst_tbl(p_oks_txn_inst_tbl   IN oks_ibint_pub.txn_instance_tbl)
IS
BEGIN
   PUT_LINE('OKS_TXN_INST_TBL count is '||p_oks_txn_inst_tbl.count);
   IF p_oks_txn_inst_tbl.count > 0 THEN
      PUT_LINE ('Dumping the values passed to contracts ib_interface:');
      FOR J IN p_oks_txn_inst_tbl.FIRST .. p_oks_txn_inst_tbl.LAST LOOP
         IF p_oks_txn_inst_tbl.EXISTS(J) THEN
	    PUT_LINE('Old_Customer_product_id : '||p_oks_txn_inst_tbl(J).Old_Customer_product_id);
	    PUT_LINE('Old_Quantity : '||p_oks_txn_inst_tbl(J).Old_Quantity);
	    PUT_LINE('Old_Unit_of_measur : '||p_oks_txn_inst_tbl(J).Old_Unit_of_measure);
	    PUT_LINE('Old_Inventory_item_id : '||p_oks_txn_inst_tbl(J).Old_Inventory_item_id);
	    PUT_LINE('Old_Customer_acct_id : '||p_oks_txn_inst_tbl(J).Old_Customer_acct_id);
	    PUT_LINE('New_Customer_product_id : '||p_oks_txn_inst_tbl(J).New_Customer_product_id);
	    PUT_LINE('New_Quantity : '||p_oks_txn_inst_tbl(J).New_Quantity);
	    PUT_LINE('New_Customer_acct_id : '||p_oks_txn_inst_tbl(J).New_Customer_acct_id);
	    PUT_LINE('New_inventory_item_id : '||p_oks_txn_inst_tbl(J).New_inventory_item_id);
	    PUT_LINE('New_Unit_of_measure : '||p_oks_txn_inst_tbl(J).New_Unit_of_measure);
	    PUT_LINE('Org_id : '||p_oks_txn_inst_tbl(J).Org_id);
	    PUT_LINE('Order_line_id : '||p_oks_txn_inst_tbl(J).Order_line_id);
	    PUT_LINE('Shipped_date : '||p_oks_txn_inst_tbl(J).Shipped_date);
	    PUT_LINE('Installation_date : '||p_oks_txn_inst_tbl(J).Installation_date);
	    PUT_LINE('Bill_to_site_use_id : '||p_oks_txn_inst_tbl(J).Bill_to_site_use_id);
	    PUT_LINE('Ship_to_site_use_id : '||p_oks_txn_inst_tbl(J).Ship_to_site_use_id);
	    PUT_LINE('Organization_id : '||p_oks_txn_inst_tbl(J).Organization_id);
	    PUT_LINE('System_id : '||p_oks_txn_inst_tbl(J).System_id);
	    PUT_LINE('Bom_explosion_flag : '||p_oks_txn_inst_tbl(J).Bom_explosion_flag);
	    PUT_LINE('Return_reason_code : '||p_oks_txn_inst_tbl(J).Return_reason_code);
	    PUT_LINE('Raise_credit : '||p_oks_txn_inst_tbl(J).Raise_credit);
	    PUT_LINE('Transaction_date : '||p_oks_txn_inst_tbl(J).Transaction_date);
	    PUT_LINE('Transfer_date : '||p_oks_txn_inst_tbl(J).Transfer_date);
	    PUT_LINE('Termination_date : '||p_oks_txn_inst_tbl(J).Termination_date);
	    PUT_LINE('TRM : '||p_oks_txn_inst_tbl(J).TRM);
	    PUT_LINE('TRF : '||p_oks_txn_inst_tbl(J).TRF);
	    PUT_LINE('RET : '||p_oks_txn_inst_tbl(J).RET);
	    PUT_LINE('RPL : '||p_oks_txn_inst_tbl(J).RPL);
	    PUT_LINE('IDC : '||p_oks_txn_inst_tbl(J).IDC);
	    PUT_LINE('UPD : '||p_oks_txn_inst_tbl(J).UPD);
	    PUT_LINE('SPL : '||p_oks_txn_inst_tbl(J).SPL);
	    PUT_LINE('NEW : '||p_oks_txn_inst_tbl(J).NEW);
	    PUT_LINE('RIN : '||p_oks_txn_inst_tbl(J).RIN);
            PUT_LINE('--------------------------------------------------------------------------');
         END IF;
      END LOOP;
   END IF;
END dump_oks_txn_inst_tbl;

PROCEDURE dump_call_batch_val
     ( p_api_version           IN    NUMBER
      ,p_init_msg_list         IN    VARCHAR2
      ,p_parameter_name        IN    csi_datastructures_pub.parameter_name
      ,p_parameter_value       IN    csi_datastructures_pub.parameter_value
      )
IS
    l_api_name          CONSTANT VARCHAR2(30)   := 'dump_call_batch_val';
    l_api_version       CONSTANT NUMBER         := 1.0;
BEGIN
-- Standard Start of API savepoint
  -- SAVEPOINT       dump_call_batch_val;
   PUT_LINE ('Api_version                 :'||p_api_version);
   PUT_LINE ('Init_msg_list               :'||p_init_msg_list);
   FOR tab_row IN p_parameter_name.FIRST..p_parameter_name.LAST
   LOOP
    PUT_LINE ('parameter_name  :'||p_parameter_name(tab_row));
    PUT_LINE ('parameter_value :'||p_parameter_value(tab_row));
   END LOOP;
EXCEPTION
        WHEN OTHERS THEN
       --  ROLLBACK TO  dump_call_batch_val;
          IF      FND_MSG_PUB.Check_Msg_Level
                 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                  FND_MSG_PUB.Add_Exc_Msg
                ( g_pkg_name ,
                  l_api_name
                 );
          END IF;
END dump_call_batch_val;

PROCEDURE Populate_Install_Param_Rec IS
BEGIN
   SELECT INTERNAL_PARTY_ID
         ,NULL -- PROJECT_LOCATION_ID
         ,NULL -- WIP_LOCATION_ID
         ,NULL -- IN_TRANSIT_LOCATION_ID
         ,NULL -- PO_LOCATION_ID
         ,CATEGORY_SET_ID
         ,nvl(HISTORY_FULL_DUMP_FREQUENCY,10)
         ,nvl(FREEZE_FLAG,'N')
         ,FREEZE_DATE
         ,nvl(SHOW_ALL_PARTY_LOCATION,'N')
         ,nvl(OWNERSHIP_OVERRIDE_AT_TXN,'N')
         ,nvl(SFM_QUEUE_BYPASS_FLAG,'N')
         ,nvl(AUTO_ALLOCATE_COMP_AT_WIP,'N')
         ,TXN_SEQ_START_DATE
         ,nvl(OWNERSHIP_CASCADE_AT_TXN,'N')
         ,'Y'
         ,FA_CREATION_GROUP_BY
   INTO csi_datastructures_pub.G_INSTALL_PARAM_REC.INTERNAL_PARTY_ID
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.PROJECT_LOCATION_ID
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.WIP_LOCATION_ID
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.IN_TRANSIT_LOCATION_ID
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.PO_LOCATION_ID
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.CATEGORY_SET_ID
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.HISTORY_FULL_DUMP_FREQUENCY
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.FREEZE_FLAG
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.FREEZE_DATE
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.SHOW_ALL_PARTY_LOCATION
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.OWNERSHIP_OVERRIDE_AT_TXN
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.SFM_QUEUE_BYPASS_FLAG
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.AUTO_ALLOCATE_COMP_AT_WIP
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.TXN_SEQ_START_DATE
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.OWNERSHIP_CASCADE_AT_TXN
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.FETCH_FLAG
       ,csi_datastructures_pub.G_INSTALL_PARAM_REC.FA_CREATION_GROUP_BY
     FROM CSI_INSTALL_PARAMETERS;
  EXCEPTION
     WHEN OTHERS THEN
        csi_datastructures_pub.G_INSTALL_PARAM_REC.FETCH_FLAG := 'N';
END Populate_Install_Param_Rec;
--
FUNCTION IB_ACTIVE RETURN BOOLEAN IS
  l_freeze_flag VARCHAR2(1) := 'N';
BEGIN
    IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
       csi_gen_utility_pvt.populate_install_param_rec;
    END IF;
    --
    l_freeze_flag := csi_datastructures_pub.g_install_param_rec.freeze_flag;
    --
    IF nvl(l_freeze_flag,'N') = 'Y' THEN
      return TRUE;
    ELSE
      return FALSE;
    END IF;
END IB_ACTIVE;

FUNCTION is_eib_installed RETURN VARCHAR2
IS
    l_eib_installed    VARCHAR2(1) := 'N' ;
    l_temp             VARCHAR2(40);
    l_app_info         BOOLEAN;
BEGIN
   IF (CSI_GEN_UTILITY_PVT.g_cse_install is NULL)
   THEN
      l_app_info := fnd_installation.get_app_info('CSE',
                    CSI_GEN_UTILITY_PVT.g_cse_install, l_temp, l_temp);
   END IF;

   IF (CSI_GEN_UTILITY_PVT.g_cse_install = 'I')
   THEN
     l_eib_installed := 'Y';
   ELSE
     l_eib_installed := 'N';
   END IF;
   RETURN l_eib_installed ;

END is_eib_installed ;

END CSI_GEN_UTILITY_PVT;

/
