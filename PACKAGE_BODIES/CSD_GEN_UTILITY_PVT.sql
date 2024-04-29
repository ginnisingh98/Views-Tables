--------------------------------------------------------
--  DDL for Package Body CSD_GEN_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_GEN_UTILITY_PVT" AS
/* $Header: csdvtgub.pls 120.1 2005/08/17 15:14:34 swai noship $*/

 PROCEDURE set_debug_on IS
    l_audsid NUMBER;
    l_sid    NUMBER;
    l_os_user VARCHAR2(30);
  BEGIN
    IF csd_gen_utility_pvt.g_debug = fnd_api.g_false THEN
      IF csd_gen_utility_pvt.g_file IS NULL THEN
        SELECT USERENV('SESSIONID') INTO l_audsid FROM sys.dual;

           SELECT sid, SUBSTR(osuser,1,8) INTO l_sid ,l_os_user
        FROM   v$session
        WHERE  audsid = l_audsid;

           SELECT l_os_user||'.csd'||TO_CHAR(l_sid)||'.dbg'
        INTO   csd_gen_utility_pvt.g_file
        FROM   dual;
        csd_gen_utility_pvt.g_file_ptr := utl_file.fopen(G_DIR, G_FILE, 'w');
      ELSE
        csd_gen_utility_pvt.g_file_ptr := utl_file.fopen(G_DIR, G_FILE, 'a');
      END IF;
      csd_gen_utility_pvt.g_debug    := fnd_api.g_true;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END set_debug_on;

 PROCEDURE set_debug_off IS
  BEGIN
    IF csd_gen_utility_pvt.is_debug_on THEN
      utl_file.fclose(csd_gen_utility_pvt.g_file_ptr);
      csd_gen_utility_pvt.g_debug := fnd_api.g_false;
    END IF;
  END set_debug_off;

 FUNCTION is_debug_on RETURN BOOLEAN
  IS
  BEGIN
    IF csd_gen_utility_pvt.g_debug = fnd_api.g_true THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_debug_on;

 PROCEDURE ADD(
    p_debug_msg IN VARCHAR2)
  IS
  BEGIN
    --csd_gen_utility_pvt.add(p_debug_msg);
    IF csd_gen_utility_pvt.g_debug_level > 0 THEN
      set_debug_on;
      IF is_debug_on THEN
        IF ( Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level) THEN
          fnd_log.string(fnd_log.level_statement,'csd.plsql.csd_gen_utility_pvt',p_debug_msg);
        END IF;
	utl_file.put_line(g_file_ptr, p_debug_msg);
        utl_file.fflush(g_file_ptr);
      END IF;
    END IF;
  END ADD;

  PROCEDURE dump_api_info(
    p_pkg_name  IN VARCHAR2,
    p_api_name  IN VARCHAR2)
  IS
  BEGIN
    csd_gen_utility_pvt.ADD('Inside API :'||p_pkg_name||'.'||p_api_name);
  END dump_api_info;

  PROCEDURE dump_error_stack
  IS
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_msg_index_out NUMBER;
  BEGIN
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
      csd_gen_utility_pvt.ADD('Error: '||l_msg_data);
    END LOOP;
  END dump_error_stack;

  FUNCTION dump_error_stack RETURN VARCHAR2
  IS
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_msg_index_out   NUMBER;
    x_msg_data        VARCHAR2(4000);
  BEGIN
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
      x_msg_data := LTRIM(x_msg_data||' '||l_msg_data);
    END LOOP;
    RETURN x_msg_data;
  EXCEPTION
    WHEN OTHERS THEN
      csd_gen_utility_pvt.ADD('Error in dump_error_stack:'||SQLERRM);
      RETURN x_msg_data;
  END dump_error_stack;

  PROCEDURE dump_prod_txn_rec (
    p_prod_txn_rec IN csd_process_pvt.product_txn_rec)
  IS
    l_rec csd_process_pvt.product_txn_rec;
  BEGIN
    l_rec := p_prod_txn_rec;

   IF csd_gen_utility_pvt.g_debug_level >= 5 THEN
    csd_gen_utility_pvt.ADD(' Product Txn Rec');
    csd_gen_utility_pvt.ADD('  product_transaction_id   :'|| l_rec.product_transaction_id );
    csd_gen_utility_pvt.ADD('  repair_line_id           :'|| l_rec.repair_line_id );
    csd_gen_utility_pvt.ADD('  estimate_detail_id       :'|| l_rec.estimate_detail_id );
    csd_gen_utility_pvt.ADD('  action_type              :'|| l_rec.action_type );
    csd_gen_utility_pvt.ADD('  action_code              :'|| l_rec.action_code );
    csd_gen_utility_pvt.ADD('  incident_id              :'|| l_rec.incident_id );
    csd_gen_utility_pvt.ADD('  transaction_type_id      :'|| l_rec.transaction_type_id );
    csd_gen_utility_pvt.ADD('  business_process_id      :'|| l_rec.business_process_id );
    csd_gen_utility_pvt.ADD('  txn_billing_type_id      :'|| l_rec.txn_billing_type_id );
    csd_gen_utility_pvt.ADD('  original_source_id       :'|| l_rec.original_source_id );
    csd_gen_utility_pvt.ADD('  source_id                :'|| l_rec.source_id );
    csd_gen_utility_pvt.ADD('  line_type_id             :'|| l_rec.line_type_id );
    csd_gen_utility_pvt.ADD('  order_number             :'|| l_rec.order_number );
    csd_gen_utility_pvt.ADD('  status                   :'|| l_rec.status );
    csd_gen_utility_pvt.ADD('  currency_code            :'|| l_rec.currency_code );
    csd_gen_utility_pvt.ADD('  line_category_code       :'|| l_rec.line_category_code );
    csd_gen_utility_pvt.ADD('  unit_of_measure_code     :'|| l_rec.unit_of_measure_code );
    csd_gen_utility_pvt.ADD('  inventory_item_id        :'|| l_rec.inventory_item_id );
    csd_gen_utility_pvt.ADD('  revision                 :'|| l_rec.revision );
    csd_gen_utility_pvt.ADD('  quantity                 :'|| l_rec.quantity );
    csd_gen_utility_pvt.ADD('  serial_number            :'|| l_rec.source_serial_number );
    csd_gen_utility_pvt.ADD('  lot_number               :'|| l_rec.lot_number );
    csd_gen_utility_pvt.ADD('  instance_id              :'|| l_rec.source_instance_id );
    csd_gen_utility_pvt.ADD('  instance_number          :'|| l_rec.source_instance_number );
    csd_gen_utility_pvt.ADD('  price_list_id            :'|| l_rec.price_list_id );
    csd_gen_utility_pvt.ADD('  contract_id              :'|| l_rec.contract_id );
    csd_gen_utility_pvt.ADD('  sub_inventory            :'|| l_rec.sub_inventory );
    csd_gen_utility_pvt.ADD('  organization_id          :'|| l_rec.organization_id );
    csd_gen_utility_pvt.ADD('  invoice_to_org_id        :'|| l_rec.invoice_to_org_id );
    csd_gen_utility_pvt.ADD('  ship_to_org_id           :'|| l_rec.ship_to_org_id );
    csd_gen_utility_pvt.ADD('  no_charge_flag           :'|| l_rec.no_charge_flag );
    csd_gen_utility_pvt.ADD('  interface_to_om_flag     :'|| l_rec.interface_to_om_flag );
    csd_gen_utility_pvt.ADD('  book_sales_order_flag    :'|| l_rec.book_sales_order_flag );
    csd_gen_utility_pvt.ADD('  release_sales_order_flag :'|| l_rec.release_sales_order_flag );
    csd_gen_utility_pvt.ADD('  ship_sales_order_flag    :'|| l_rec.ship_sales_order_flag );
    csd_gen_utility_pvt.ADD('  process_txn_flag         :'|| l_rec.process_txn_flag );
    csd_gen_utility_pvt.ADD('  return_reason            :'|| l_rec.return_reason );
    csd_gen_utility_pvt.ADD('  return_by_date           :'|| l_rec.return_by_date );
    csd_gen_utility_pvt.ADD('  object_version_number    :'|| l_rec.object_version_number );
    csd_gen_utility_pvt.ADD('  security_group_id        :'|| l_rec.security_group_id );
   END IF;
 END dump_prod_txn_rec;

 PROCEDURE dump_sr_rec (
    p_sr_rec IN csd_process_pvt.service_request_rec
    ) IS
    l_rec csd_process_pvt.service_request_rec := p_sr_rec;
  BEGIN
    csd_gen_utility_pvt.ADD('  request_date    :'|| l_rec.request_date );
    csd_gen_utility_pvt.ADD('  type_id         :'|| l_rec.type_id );
    csd_gen_utility_pvt.ADD('  type_name       :'|| l_rec.type_name );
    csd_gen_utility_pvt.ADD('  status_id       :'|| l_rec.status_id );
    csd_gen_utility_pvt.ADD('  status_name     :'|| l_rec.status_name );
    csd_gen_utility_pvt.ADD('  severity_id     :'|| l_rec.severity_id );
    csd_gen_utility_pvt.ADD('  severity_name   :'|| l_rec.severity_name );
    csd_gen_utility_pvt.ADD('  urgency_id      :'|| l_rec.urgency_id );
    csd_gen_utility_pvt.ADD('  urgency_name    :'|| l_rec.urgency_name );
    csd_gen_utility_pvt.ADD('  closed_date     :'|| l_rec.closed_date );
    csd_gen_utility_pvt.ADD('  owner_id        :'|| l_rec.owner_id );
    csd_gen_utility_pvt.ADD('  owner_group_id  :'|| l_rec.owner_group_id );
    csd_gen_utility_pvt.ADD('  publish_flag    :'|| l_rec.publish_flag );
    csd_gen_utility_pvt.ADD('  summary         :'|| l_rec.summary );
    csd_gen_utility_pvt.ADD('  caller_type     :'|| l_rec.caller_type );
    csd_gen_utility_pvt.ADD('  customer_id     :'|| l_rec.customer_id );
    csd_gen_utility_pvt.ADD('  customer_number :'|| l_rec.customer_number );
    csd_gen_utility_pvt.ADD('  employee_number :'|| l_rec.employee_number );
    csd_gen_utility_pvt.ADD('  verify_cp_flag  :'|| l_rec.verify_cp_flag );
    csd_gen_utility_pvt.ADD('  customer_product_id :'|| l_rec.customer_product_id );
    csd_gen_utility_pvt.ADD('  cp_ref_number   :'|| l_rec.cp_ref_number );
    csd_gen_utility_pvt.ADD('  inventory_item_id :'|| l_rec.inventory_item_id );
    csd_gen_utility_pvt.ADD('  inventory_org_id  :'|| l_rec.inventory_org_id );
    csd_gen_utility_pvt.ADD('  current_serial_number:'|| l_rec.current_serial_number );
    csd_gen_utility_pvt.ADD('  original_order_number:'|| l_rec.original_order_number );
    csd_gen_utility_pvt.ADD('  purchase_order_num  :'|| l_rec.purchase_order_num );
    csd_gen_utility_pvt.ADD('  problem_code        :'|| l_rec.problem_code );
    csd_gen_utility_pvt.ADD('  exp_resolution_date :'|| l_rec.exp_resolution_date );
    csd_gen_utility_pvt.ADD('  bill_to_site_use_id :'|| l_rec.bill_to_site_use_id );
    csd_gen_utility_pvt.ADD('  ship_to_site_use_id :'|| l_rec.ship_to_site_use_id );
    csd_gen_utility_pvt.ADD('  contract_id         :'|| l_rec.contract_id );
    csd_gen_utility_pvt.ADD('  account_id          :'|| l_rec.account_id );
    csd_gen_utility_pvt.ADD('  resource_type       :'|| l_rec.resource_type );
    csd_gen_utility_pvt.ADD('  cust_po_number      :'|| l_rec.cust_po_number );
    csd_gen_utility_pvt.ADD('  cp_revision_id      :'|| l_rec.cp_revision_id );
    csd_gen_utility_pvt.ADD('  inv_item_revision   :'|| l_rec.inv_item_revision );
    csd_gen_utility_pvt.ADD('  sr_contact_point_id :'|| l_rec.sr_contact_point_id );
    csd_gen_utility_pvt.ADD('  party_id            :'|| l_rec.party_id );
    csd_gen_utility_pvt.ADD('  contact_point_id    :'|| l_rec.contact_point_id );
    csd_gen_utility_pvt.ADD('  contact_point_type  :'|| l_rec.contact_point_type );
    csd_gen_utility_pvt.ADD('  primary_flag        :'|| l_rec.primary_flag );
    csd_gen_utility_pvt.ADD('  contact_type        :'|| l_rec.contact_type );
END dump_sr_rec;

PROCEDURE dump_estimate_rec (
    p_estimate_rec IN csd_repair_estimate_pvt.repair_estimate_rec
    ) IS
    l_rec csd_repair_estimate_pvt.repair_estimate_rec := p_estimate_rec;

BEGIN

csd_gen_utility_pvt.add('repair_estimate_id :'||l_rec.repair_estimate_id);
csd_gen_utility_pvt.add('repair_line_id     :'||l_rec.repair_line_id    );
csd_gen_utility_pvt.add('note_id            :'||l_rec.note_id           );
csd_gen_utility_pvt.add('estimate_date      :'||l_rec.estimate_date     );
csd_gen_utility_pvt.add('estimate_status    :'||l_rec.estimate_status   );
csd_gen_utility_pvt.add('lead_time          :'||l_rec.lead_time         );
csd_gen_utility_pvt.add('lead_time_uom      :'||l_rec.lead_time_uom     );
csd_gen_utility_pvt.add('work_summary       :'||l_rec.work_summary      );
csd_gen_utility_pvt.add('po_number          :'||l_rec.po_number         );
csd_gen_utility_pvt.add('last_update_date   :'||l_rec.last_update_date  );
csd_gen_utility_pvt.add('creation_date      :'||l_rec.creation_date     );
csd_gen_utility_pvt.add('last_updated_by    :'||l_rec.last_updated_by   );
csd_gen_utility_pvt.add('created_by         :'||l_rec.created_by        );
csd_gen_utility_pvt.add('last_update_login  :'||l_rec.last_update_login );
csd_gen_utility_pvt.add('attribute1         :'||l_rec.attribute1  );
csd_gen_utility_pvt.add('attribute2         :'||l_rec.attribute2  );
csd_gen_utility_pvt.add('attribute3         :'||l_rec.attribute3  );
csd_gen_utility_pvt.add('attribute4         :'||l_rec.attribute4  );
csd_gen_utility_pvt.add('attribute5         :'||l_rec.attribute5  );
csd_gen_utility_pvt.add('attribute6         :'||l_rec.attribute6  );
csd_gen_utility_pvt.add('attribute7         :'||l_rec.attribute7  );
csd_gen_utility_pvt.add('attribute8         :'||l_rec.attribute8  );
csd_gen_utility_pvt.add('attribute9         :'||l_rec.attribute9  );
csd_gen_utility_pvt.add('attribute10        :'||l_rec.attribute10  );
csd_gen_utility_pvt.add('attribute11        :'||l_rec.attribute11  );
csd_gen_utility_pvt.add('attribute12        :'||l_rec.attribute12  );
csd_gen_utility_pvt.add('attribute13        :'||l_rec.attribute13  );
csd_gen_utility_pvt.add('attribute14        :'||l_rec.attribute14  );
csd_gen_utility_pvt.add('attribute15        :'||l_rec.attribute15  );
csd_gen_utility_pvt.add('context            :'||l_rec.context      );
csd_gen_utility_pvt.add('object_version_number:'||l_rec.object_version_number );
csd_gen_utility_pvt.add('security_group_id  :'||l_rec.security_group_id        );

END dump_estimate_rec;

PROCEDURE dump_estimate_line_rec
 (
    p_estimate_line_rec IN csd_repair_estimate_pvt.repair_estimate_line_rec
    ) IS
    l_rec csd_repair_estimate_pvt.repair_estimate_line_rec := p_estimate_line_rec;

BEGIN

csd_gen_utility_pvt.add('repair_estimate_line_id :'||l_rec.repair_estimate_line_id );
csd_gen_utility_pvt.add('repair_estimate_id  :'||l_rec.repair_estimate_id        );
csd_gen_utility_pvt.add('repair_line_id      :'||l_rec.repair_line_id            );
csd_gen_utility_pvt.add('estimate_detail_id  :'||l_rec.estimate_detail_id        );
csd_gen_utility_pvt.add('incident_id         :'||l_rec.incident_id               );
csd_gen_utility_pvt.add('transaction_type_id :'||l_rec.transaction_type_id       );
csd_gen_utility_pvt.add('business_process_id :'||l_rec.business_process_id       );
csd_gen_utility_pvt.add('txn_billing_type_id :'||l_rec.txn_billing_type_id       );
csd_gen_utility_pvt.add('original_source_id  :'||l_rec.original_source_id        );
csd_gen_utility_pvt.add('original_source_code:'||l_rec.original_source_code      );
csd_gen_utility_pvt.add('source_id           :'||l_rec.source_id                 );
csd_gen_utility_pvt.add('source_code         :'||l_rec.source_code               );
csd_gen_utility_pvt.add('line_type_id        :'||l_rec.line_type_id              );
csd_gen_utility_pvt.add('item_cost           :'||l_rec.item_cost                 );
csd_gen_utility_pvt.add('customer_product_id :'||l_rec.customer_product_id       );
csd_gen_utility_pvt.add('reference_number    :'||l_rec.reference_number          );
csd_gen_utility_pvt.add('item_revision       :'||l_rec.item_revision             );
csd_gen_utility_pvt.add('justification_notes :'||l_rec.justification_notes       );
csd_gen_utility_pvt.add('estimate_status     :'||l_rec.estimate_status           );
csd_gen_utility_pvt.add('order_number        :'||l_rec.order_number              );
csd_gen_utility_pvt.add('purchase_order_num  :'||l_rec.purchase_order_num        );
csd_gen_utility_pvt.add('source_number       :'||l_rec.source_number             );
csd_gen_utility_pvt.add('status              :'||l_rec.status                    );
csd_gen_utility_pvt.add('currency_code       :'||l_rec.currency_code             );
csd_gen_utility_pvt.add('line_category_code  :'||l_rec.line_category_code        );
csd_gen_utility_pvt.add('unit_of_measure_code:'||l_rec.unit_of_measure_code      );
csd_gen_utility_pvt.add('original_source_number:'||l_rec.original_source_number  );
csd_gen_utility_pvt.add('order_header_id     :'||l_rec.order_header_id           );
csd_gen_utility_pvt.add('order_line_id       :'||l_rec.order_line_id             );
csd_gen_utility_pvt.add('inventory_item_id   :'||l_rec.inventory_item_id         );
csd_gen_utility_pvt.add('after_warranty_cost :'||l_rec.after_warranty_cost       );
csd_gen_utility_pvt.add('selling_price       :'||l_rec.selling_price             );
csd_gen_utility_pvt.add('original_system_reference:'||l_rec.original_system_reference );
csd_gen_utility_pvt.add('estimate_quantity   :'||l_rec.estimate_quantity         );
csd_gen_utility_pvt.add('serial_number       :'||l_rec.serial_number             );
csd_gen_utility_pvt.add('lot_number          :'||l_rec.lot_number                );
csd_gen_utility_pvt.add('instance_id         :'||l_rec.instance_id               );
csd_gen_utility_pvt.add('instance_number     :'||l_rec.instance_number           );
csd_gen_utility_pvt.add('price_list_id       :'||l_rec.price_list_id             );
csd_gen_utility_pvt.add('contract_id         :'||l_rec.contract_id               );
csd_gen_utility_pvt.add('coverage_id         :'||l_rec.coverage_id               );
csd_gen_utility_pvt.add('coverage_txn_group_id:'||l_rec.coverage_txn_group_id    );
csd_gen_utility_pvt.add('coverage_bill_rate_id:'||l_rec.coverage_bill_rate_id    );
csd_gen_utility_pvt.add('sub_inventory       :'||l_rec.sub_inventory             );
csd_gen_utility_pvt.add('organization_id     :'||l_rec.organization_id           );
csd_gen_utility_pvt.add('invoice_to_org_id   :'||l_rec.invoice_to_org_id         );
csd_gen_utility_pvt.add('ship_to_org_id      :'||l_rec.ship_to_org_id            );
csd_gen_utility_pvt.add('no_charge_flag      :'||l_rec.no_charge_flag            );
csd_gen_utility_pvt.add('interface_to_om_flag:'||l_rec.interface_to_om_flag      );
csd_gen_utility_pvt.add('return_reason       :'||l_rec.return_reason             );
csd_gen_utility_pvt.add('return_by_date      :'||l_rec.return_by_date            );
csd_gen_utility_pvt.add('last_update_date    :'||l_rec.last_update_date          );
csd_gen_utility_pvt.add('creation_date       :'||l_rec.creation_date             );
csd_gen_utility_pvt.add('last_updated_by     :'||l_rec.last_updated_by           );
csd_gen_utility_pvt.add('created_by          :'||l_rec.created_by                );
csd_gen_utility_pvt.add('last_update_login   :'||l_rec.last_update_login         );
csd_gen_utility_pvt.add('attribute1          :'||l_rec.attribute1                );
csd_gen_utility_pvt.add('attribute2          :'||l_rec.attribute2                );
csd_gen_utility_pvt.add('attribute3          :'||l_rec.attribute3                );
csd_gen_utility_pvt.add('attribute4          :'||l_rec.attribute4                );
csd_gen_utility_pvt.add('attribute5          :'||l_rec.attribute5                );
csd_gen_utility_pvt.add('attribute6          :'||l_rec.attribute6                );
csd_gen_utility_pvt.add('attribute7          :'||l_rec.attribute7                );
csd_gen_utility_pvt.add('attribute8          :'||l_rec.attribute8                );
csd_gen_utility_pvt.add('attribute9          :'||l_rec.attribute9                );
csd_gen_utility_pvt.add('attribute10         :'||l_rec.attribute10               );
csd_gen_utility_pvt.add('attribute11         :'||l_rec.attribute11               );
csd_gen_utility_pvt.add('attribute12         :'||l_rec.attribute12               );
csd_gen_utility_pvt.add('attribute13         :'||l_rec.attribute13               );
csd_gen_utility_pvt.add('attribute14         :'||l_rec.attribute14               );
csd_gen_utility_pvt.add('attribute15         :'||l_rec.attribute15               );
csd_gen_utility_pvt.add('context             :'||l_rec.context                   );
csd_gen_utility_pvt.add('object_version_number :'||l_rec.object_version_number   );
csd_gen_utility_pvt.add('security_group_id   :'||l_rec.security_group_id         );
csd_gen_utility_pvt.add('charge_line_type    :'||l_rec.charge_line_type          );
csd_gen_utility_pvt.add('apply_contract_discount  :'||l_rec.apply_contract_discount );
csd_gen_utility_pvt.add('coverage_id         :'||l_rec.coverage_id               );
csd_gen_utility_pvt.add('coverage_txn_group_id    :'||l_rec.coverage_txn_group_id );
csd_gen_utility_pvt.add('est_line_source_type_code:'||l_rec.est_line_source_type_code );
csd_gen_utility_pvt.add('est_line_source_id1 :'||l_rec.est_line_source_id1       );
csd_gen_utility_pvt.add('est_line_source_id2 :'||l_rec.est_line_source_id1       );
csd_gen_utility_pvt.add('ro_service_code_id  :'||l_rec.ro_service_code_id        );

END dump_estimate_line_rec;

PROCEDURE dump_repair_order_group_rec
 (
    p_repair_order_group_rec IN csd_repair_groups_pvt.repair_order_group_rec
    ) IS
    l_rec csd_repair_groups_pvt.repair_order_group_rec := p_repair_order_group_rec;

BEGIN

csd_gen_utility_pvt.add('repair_group_id        :'||l_rec.repair_group_id );
csd_gen_utility_pvt.add('incident_id            :'||l_rec.incident_id );
csd_gen_utility_pvt.add('repair_group_number    :'||l_rec.repair_group_number );
csd_gen_utility_pvt.add('repair_type_id         :'||l_rec.repair_type_id );
csd_gen_utility_pvt.add('inventory_item_id      :'||l_rec.inventory_item_id );
csd_gen_utility_pvt.add('unit_of_measure        :'||l_rec.unit_of_measure );
csd_gen_utility_pvt.add('group_quantity         :'||l_rec.group_quantity );
csd_gen_utility_pvt.add('repair_order_quantity  :'||l_rec.repair_order_quantity );
csd_gen_utility_pvt.add('rma_quantity           :'||l_rec.rma_quantity );
csd_gen_utility_pvt.add('received_quantity      :'||l_rec.received_quantity);
csd_gen_utility_pvt.add('approved_quantity      :'||l_rec.approved_quantity );
csd_gen_utility_pvt.add('submitted_quantity     :'||l_rec.submitted_quantity );
csd_gen_utility_pvt.add('completed_quantity     :'||l_rec.completed_quantity );
csd_gen_utility_pvt.add('released_quantity      :'||l_rec.released_quantity );
csd_gen_utility_pvt.add('shipped_quantity       :'||l_rec.shipped_quantity );
csd_gen_utility_pvt.add('created_by             :'||l_rec.created_by );
csd_gen_utility_pvt.add('creation_date          :'||l_rec.creation_date );
csd_gen_utility_pvt.add('last_updated_by        :'||l_rec.last_updated_by );
csd_gen_utility_pvt.add('last_update_date       :'||l_rec.last_update_date );
csd_gen_utility_pvt.add('last_update_login      :'||l_rec.last_update_login );
csd_gen_utility_pvt.add('context                :'||l_rec.context );
csd_gen_utility_pvt.add('attribute1             :'||l_rec.attribute1 );
csd_gen_utility_pvt.add('attribute2             :'||l_rec.attribute2 );
csd_gen_utility_pvt.add('attribute3             :'||l_rec.attribute3 );
csd_gen_utility_pvt.add('attribute4             :'||l_rec.attribute4 );
csd_gen_utility_pvt.add('attribute5             :'||l_rec.attribute5 );
csd_gen_utility_pvt.add('attribute6             :'||l_rec.attribute6 );
csd_gen_utility_pvt.add('attribute7             :'||l_rec.attribute7 );
csd_gen_utility_pvt.add('attribute8             :'||l_rec.attribute8 );
csd_gen_utility_pvt.add('attribute9             :'||l_rec.attribute9 );
csd_gen_utility_pvt.add('attribute10            :'||l_rec.attribute10 );
csd_gen_utility_pvt.add('attribute11            :'||l_rec.attribute11 );
csd_gen_utility_pvt.add('attribute12            :'||l_rec.attribute12 );
csd_gen_utility_pvt.add('attribute13            :'||l_rec.attribute13 );
csd_gen_utility_pvt.add('attribute14            :'||l_rec.attribute14 );
csd_gen_utility_pvt.add('attribute15            :'||l_rec.attribute15 );
csd_gen_utility_pvt.add('security_group_id      :'||l_rec.security_group_id );
csd_gen_utility_pvt.add('object_version_number  :'||l_rec.object_version_number);
csd_gen_utility_pvt.add('group_txn_status       :'||l_rec.group_txn_status );

END dump_repair_order_group_rec;


PROCEDURE dump_hz_person_rec (
    p_person_rec              IN  HZ_PARTY_V2PUB.person_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.ADD('HZ_PARTY_V2PUB.person_rec_type');
  csd_gen_utility_pvt.add('pre_name_adjunct              :'||p_person_rec.person_pre_name_adjunct );
  csd_gen_utility_pvt.add('first_name                    :'||p_person_rec.person_first_name );
  csd_gen_utility_pvt.add('middle_name                   :'||p_person_rec.person_middle_name );
  csd_gen_utility_pvt.add('last_name                     :'||p_person_rec.person_last_name );
  csd_gen_utility_pvt.add('name_suffix                   :'||p_person_rec.person_name_suffix );
  csd_gen_utility_pvt.add('title                         :'||p_person_rec.person_title );
  csd_gen_utility_pvt.add('academic_title                :'||p_person_rec.person_academic_title );
  csd_gen_utility_pvt.add('previous_last_name            :'||p_person_rec.person_previous_last_name );
  csd_gen_utility_pvt.add('initials                      :'||p_person_rec.person_initials );
  csd_gen_utility_pvt.add('known_as                      :'||p_person_rec.known_as );
  csd_gen_utility_pvt.add('known_as2                     :'||p_person_rec.known_as2 );
  csd_gen_utility_pvt.add('known_as3                     :'||p_person_rec.known_as3 );
  csd_gen_utility_pvt.add('known_as4                     :'||p_person_rec.known_as4 );
  csd_gen_utility_pvt.add('known_as5                     :'||p_person_rec.known_as5 );
  csd_gen_utility_pvt.add('person_name_phonetic          :'||p_person_rec.person_name_phonetic );
  csd_gen_utility_pvt.add('first_name_phonetic           :'||p_person_rec.person_first_name_phonetic );
  csd_gen_utility_pvt.add('last_name_phonetic            :'||p_person_rec.person_last_name_phonetic );
  csd_gen_utility_pvt.add('middle_name_phonetic          :'||p_person_rec.middle_name_phonetic );
  csd_gen_utility_pvt.add('tax_reference                 :'||p_person_rec.tax_reference );
  csd_gen_utility_pvt.add('jgzz_fiscal_code              :'||p_person_rec.jgzz_fiscal_code );
  csd_gen_utility_pvt.add('person_iden_type              :'||p_person_rec.person_iden_type );
  csd_gen_utility_pvt.add('person_identifier             :'||p_person_rec.person_identifier );
  csd_gen_utility_pvt.add('date_of_birth                 :'||p_person_rec.date_of_birth );
  csd_gen_utility_pvt.add('place_of_birth                :'||p_person_rec.place_of_birth );
  csd_gen_utility_pvt.add('date_of_death                 :'||p_person_rec.date_of_death );
  csd_gen_utility_pvt.add('gender                        :'||p_person_rec.gender );
  csd_gen_utility_pvt.add('declared_ethnicity            :'||p_person_rec.declared_ethnicity );
  csd_gen_utility_pvt.add('marital_status                :'||p_person_rec.marital_status );
  csd_gen_utility_pvt.add('marital_status_effective_date :'||p_person_rec.marital_status_effective_date);
  csd_gen_utility_pvt.add('personal_income               :'||p_person_rec.personal_income);
  csd_gen_utility_pvt.add('head_of_household_flag        :'||p_person_rec.head_of_household_flag );
  csd_gen_utility_pvt.add('household_income              :'||p_person_rec.household_income);
  csd_gen_utility_pvt.add('household_size                :'||p_person_rec.household_size);
  csd_gen_utility_pvt.add('rent_own_ind                  :'||p_person_rec.rent_own_ind );
  csd_gen_utility_pvt.add('last_known_gps                :'||p_person_rec.last_known_gps );
  csd_gen_utility_pvt.add('internal_flag                 :'||p_person_rec.internal_flag );
  csd_gen_utility_pvt.add('content_source_type           :'||p_person_rec.content_source_type );
  csd_gen_utility_pvt.add('attribute_category            :'||p_person_rec.attribute_category );
  csd_gen_utility_pvt.add('attribute1                    :'||p_person_rec.attribute1 );
  csd_gen_utility_pvt.add('attribute2                    :'||p_person_rec.attribute2 );
  csd_gen_utility_pvt.add('attribute3                    :'||p_person_rec.attribute3 );
  csd_gen_utility_pvt.add('attribute4                    :'||p_person_rec.attribute4 );
  csd_gen_utility_pvt.add('attribute5                    :'||p_person_rec.attribute5 );
  csd_gen_utility_pvt.add('attribute6                    :'||p_person_rec.attribute6 );
  csd_gen_utility_pvt.add('attribute7                    :'||p_person_rec.attribute7 );
  csd_gen_utility_pvt.add('attribute8                    :'||p_person_rec.attribute8 );
  csd_gen_utility_pvt.add('attribute9                    :'||p_person_rec.attribute9 );
  csd_gen_utility_pvt.add('attribute10                   :'||p_person_rec.attribute10 );
  csd_gen_utility_pvt.add('attribute11                   :'||p_person_rec.attribute11 );
  csd_gen_utility_pvt.add('attribute12                   :'||p_person_rec.attribute12 );
  csd_gen_utility_pvt.add('attribute13                   :'||p_person_rec.attribute13 );
  csd_gen_utility_pvt.add('attribute14                   :'||p_person_rec.attribute14 );
  csd_gen_utility_pvt.add('attribute15                   :'||p_person_rec.attribute15 );
  csd_gen_utility_pvt.add('attribute16                   :'||p_person_rec.attribute16 );
  csd_gen_utility_pvt.add('attribute17                   :'||p_person_rec.attribute17 );
  csd_gen_utility_pvt.add('attribute18                   :'||p_person_rec.attribute18 );
  csd_gen_utility_pvt.add('attribute19                   :'||p_person_rec.attribute19 );
  csd_gen_utility_pvt.add('attribute20                   :'||p_person_rec.attribute20 );
  csd_gen_utility_pvt.add('party_rec.party_id                  :'||p_person_rec.party_rec.party_id);
  csd_gen_utility_pvt.add('party_rec.party_number              :'||p_person_rec.party_rec.party_number );
  csd_gen_utility_pvt.add('party_rec.validated_flag            :'||p_person_rec.party_rec.validated_flag );
  csd_gen_utility_pvt.add('party_rec.orig_system_reference     :'||p_person_rec.party_rec.orig_system_reference );
  csd_gen_utility_pvt.add('party_rec.status                    :'||p_person_rec.party_rec.status );
  csd_gen_utility_pvt.add('party_rec.category_code             :'||p_person_rec.party_rec.category_code );
  csd_gen_utility_pvt.add('party_rec.salutation                :'||p_person_rec.party_rec.salutation );
  csd_gen_utility_pvt.add('party_rec.attribute_category        :'||p_person_rec.party_rec.attribute_category );
  csd_gen_utility_pvt.add('party_rec.attribute1                :'||p_person_rec.party_rec.attribute1 );
  csd_gen_utility_pvt.add('party_rec.attribute2                :'||p_person_rec.party_rec.attribute2 );
  csd_gen_utility_pvt.add('party_rec.attribute3                :'||p_person_rec.party_rec.attribute3 );
  csd_gen_utility_pvt.add('party_rec.attribute4                :'||p_person_rec.party_rec.attribute4 );
  csd_gen_utility_pvt.add('party_rec.attribute5                :'||p_person_rec.party_rec.attribute5 );
  csd_gen_utility_pvt.add('party_rec.attribute6                :'||p_person_rec.party_rec.attribute6 );
  csd_gen_utility_pvt.add('party_rec.attribute7                :'||p_person_rec.party_rec.attribute7 );
  csd_gen_utility_pvt.add('party_rec.attribute8                :'||p_person_rec.party_rec.attribute8 );
  csd_gen_utility_pvt.add('party_rec.attribute9                :'||p_person_rec.party_rec.attribute9 );
  csd_gen_utility_pvt.add('party_rec.attribute10               :'||p_person_rec.party_rec.attribute10 );
  csd_gen_utility_pvt.add('party_rec.attribute11               :'||p_person_rec.party_rec.attribute11 );
  csd_gen_utility_pvt.add('party_rec.attribute12               :'||p_person_rec.party_rec.attribute12 );
  csd_gen_utility_pvt.add('party_rec.attribute13               :'||p_person_rec.party_rec.attribute13 );
  csd_gen_utility_pvt.add('party_rec.attribute14               :'||p_person_rec.party_rec.attribute14 );
  csd_gen_utility_pvt.add('party_rec.attribute15               :'||p_person_rec.party_rec.attribute15 );
  csd_gen_utility_pvt.add('party_rec.attribute16               :'||p_person_rec.party_rec.attribute16 );
  csd_gen_utility_pvt.add('party_rec.attribute17               :'||p_person_rec.party_rec.attribute17 );
  csd_gen_utility_pvt.add('party_rec.attribute18               :'||p_person_rec.party_rec.attribute18 );
  csd_gen_utility_pvt.add('party_rec.attribute19               :'||p_person_rec.party_rec.attribute19 );
  csd_gen_utility_pvt.add('party_rec.attribute20               :'||p_person_rec.party_rec.attribute20 );
  csd_gen_utility_pvt.add('party_rec.attribute21               :'||p_person_rec.party_rec.attribute21 );
  csd_gen_utility_pvt.add('party_rec.attribute22               :'||p_person_rec.party_rec.attribute22 );
  csd_gen_utility_pvt.add('party_rec.attribute23               :'||p_person_rec.party_rec.attribute23 );
  csd_gen_utility_pvt.add('party_rec.attribute24               :'||p_person_rec.party_rec.attribute24 );
END dump_hz_person_rec;


PROCEDURE dump_hz_org_rec (
    p_org_rec                 IN  HZ_PARTY_V2PUB.organization_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.ADD('HZ_PARTY_V2PUB.organization_rec_type');
  csd_gen_utility_pvt.add('organization_name               :'||p_org_rec.organization_name );
  -- csd_gen_utility_pvt.add('duns_number                     :'||p_org_rec.duns_number);
  csd_gen_utility_pvt.add('duns_number_c                   :'||p_org_rec.duns_number_c );
  csd_gen_utility_pvt.add('enquiry_duns                    :'||p_org_rec.enquiry_duns );
  csd_gen_utility_pvt.add('ceo_name                        :'||p_org_rec.ceo_name );
  csd_gen_utility_pvt.add('ceo_title                       :'||p_org_rec.ceo_title );
  csd_gen_utility_pvt.add('principal_name                  :'||p_org_rec.principal_name );
  csd_gen_utility_pvt.add('principal_title                 :'||p_org_rec.principal_title );
  csd_gen_utility_pvt.add('legal_status                    :'||p_org_rec.legal_status );
  csd_gen_utility_pvt.add('control_yr                      :'||p_org_rec.control_yr);
  csd_gen_utility_pvt.add('employees_total                 :'||p_org_rec.employees_total);
  csd_gen_utility_pvt.add('hq_branch_ind                   :'||p_org_rec.hq_branch_ind );
  csd_gen_utility_pvt.add('branch_flag                     :'||p_org_rec.branch_flag );
  csd_gen_utility_pvt.add('oob_ind                         :'||p_org_rec.oob_ind );
  csd_gen_utility_pvt.add('line_of_business                :'||p_org_rec.line_of_business );
  csd_gen_utility_pvt.add('cong_dist_code                  :'||p_org_rec.cong_dist_code );
  csd_gen_utility_pvt.add('sic_code                        :'||p_org_rec.sic_code );
  csd_gen_utility_pvt.add('import_ind                      :'||p_org_rec.import_ind );
  csd_gen_utility_pvt.add('export_ind                      :'||p_org_rec.export_ind );
  csd_gen_utility_pvt.add('labor_surplus_ind               :'||p_org_rec.labor_surplus_ind );
  csd_gen_utility_pvt.add('debarment_ind                   :'||p_org_rec.debarment_ind );
  csd_gen_utility_pvt.add('minority_owned_ind              :'||p_org_rec.minority_owned_ind );
  csd_gen_utility_pvt.add('minority_owned_type             :'||p_org_rec.minority_owned_type );
  csd_gen_utility_pvt.add('woman_owned_ind                 :'||p_org_rec.woman_owned_ind );
  csd_gen_utility_pvt.add('disadv_8a_ind                   :'||p_org_rec.disadv_8a_ind );
  csd_gen_utility_pvt.add('small_bus_ind                   :'||p_org_rec.small_bus_ind );
  csd_gen_utility_pvt.add('rent_own_ind                    :'||p_org_rec.rent_own_ind );
  csd_gen_utility_pvt.add('debarments_count                :'||p_org_rec.debarments_count);
  csd_gen_utility_pvt.add('debarments_date                 :'||p_org_rec.debarments_date);
  csd_gen_utility_pvt.add('failure_score                   :'||p_org_rec.failure_score );
  csd_gen_utility_pvt.add('failure_score_natnl_percentile  :'||p_org_rec.failure_score_natnl_percentile);
  csd_gen_utility_pvt.add('failure_score_override_code     :'||p_org_rec.failure_score_override_code );
  csd_gen_utility_pvt.add('failure_score_commentary        :'||p_org_rec.failure_score_commentary );
  csd_gen_utility_pvt.add('global_failure_score            :'||p_org_rec.global_failure_score );
  csd_gen_utility_pvt.add('db_rating                       :'||p_org_rec.db_rating );
  csd_gen_utility_pvt.add('credit_score                    :'||p_org_rec.credit_score );
  csd_gen_utility_pvt.add('credit_score_commentary         :'||p_org_rec.credit_score_commentary );
  csd_gen_utility_pvt.add('paydex_score                    :'||p_org_rec.paydex_score );
  csd_gen_utility_pvt.add('paydex_three_months_ago         :'||p_org_rec.paydex_three_months_ago );
  csd_gen_utility_pvt.add('paydex_norm                     :'||p_org_rec.paydex_norm );
  csd_gen_utility_pvt.add('best_time_contact_begin         :'||p_org_rec.best_time_contact_begin);
  csd_gen_utility_pvt.add('best_time_contact_end           :'||p_org_rec.best_time_contact_end);
  csd_gen_utility_pvt.add('organization_name_phonetic      :'||p_org_rec.organization_name_phonetic );
  csd_gen_utility_pvt.add('tax_reference                   :'||p_org_rec.tax_reference );
  csd_gen_utility_pvt.add('gsa_indicator_flag              :'||p_org_rec.gsa_indicator_flag );
  csd_gen_utility_pvt.add('jgzz_fiscal_code                :'||p_org_rec.jgzz_fiscal_code );
  csd_gen_utility_pvt.add('analysis_fy                     :'||p_org_rec.analysis_fy );
  csd_gen_utility_pvt.add('fiscal_yearend_month            :'||p_org_rec.fiscal_yearend_month );
  csd_gen_utility_pvt.add('curr_fy_potential_revenue       :'||p_org_rec.curr_fy_potential_revenue);
  csd_gen_utility_pvt.add('next_fy_potential_revenue       :'||p_org_rec.next_fy_potential_revenue);
  csd_gen_utility_pvt.add('year_established                :'||p_org_rec.year_established);
  csd_gen_utility_pvt.add('mission_statement               :'||p_org_rec.mission_statement );
  csd_gen_utility_pvt.add('organization_type               :'||p_org_rec.organization_type );
  csd_gen_utility_pvt.add('business_scope                  :'||p_org_rec.business_scope );
  csd_gen_utility_pvt.add('corporation_class               :'||p_org_rec.corporation_class );
  csd_gen_utility_pvt.add('known_as                        :'||p_org_rec.known_as );
  csd_gen_utility_pvt.add('known_as2                       :'||p_org_rec.known_as2 );
  csd_gen_utility_pvt.add('known_as3                       :'||p_org_rec.known_as3 );
  csd_gen_utility_pvt.add('known_as4                       :'||p_org_rec.known_as4 );
  csd_gen_utility_pvt.add('known_as5                       :'||p_org_rec.known_as5 );
  csd_gen_utility_pvt.add('local_bus_iden_type             :'||p_org_rec.local_bus_iden_type );
  csd_gen_utility_pvt.add('local_bus_identifier            :'||p_org_rec.local_bus_identifier );
  csd_gen_utility_pvt.add('pref_functional_currency        :'||p_org_rec.pref_functional_currency );
  csd_gen_utility_pvt.add('registration_type               :'||p_org_rec.registration_type );
  csd_gen_utility_pvt.add('total_employees_text            :'||p_org_rec.total_employees_text );
  csd_gen_utility_pvt.add('total_employees_ind             :'||p_org_rec.total_employees_ind );
  csd_gen_utility_pvt.add('total_emp_est_ind               :'||p_org_rec.total_emp_est_ind );
  csd_gen_utility_pvt.add('total_emp_min_ind               :'||p_org_rec.total_emp_min_ind );
  csd_gen_utility_pvt.add('parent_sub_ind                  :'||p_org_rec.parent_sub_ind );
  csd_gen_utility_pvt.add('incorp_year                     :'||p_org_rec.incorp_year);
  -- csd_gen_utility_pvt.add('primary_contact_id              :'||p_org_rec.primary_contact_id);
  csd_gen_utility_pvt.add('sic_code_type                   :'||p_org_rec.sic_code_type );
  csd_gen_utility_pvt.add('public_private_ownership_flag   :'||p_org_rec.public_private_ownership_flag );
  csd_gen_utility_pvt.add('internal_flag                   :'||p_org_rec.internal_flag );
  csd_gen_utility_pvt.add('local_activity_code_type        :'||p_org_rec.local_activity_code_type );
  csd_gen_utility_pvt.add('local_activity_code             :'||p_org_rec.local_activity_code );
  csd_gen_utility_pvt.add('emp_at_primary_adr              :'||p_org_rec.emp_at_primary_adr );
  csd_gen_utility_pvt.add('emp_at_primary_adr_text         :'||p_org_rec.emp_at_primary_adr_text );
  csd_gen_utility_pvt.add('emp_at_primary_adr_est_ind      :'||p_org_rec.emp_at_primary_adr_est_ind );
  csd_gen_utility_pvt.add('emp_at_primary_adr_min_ind      :'||p_org_rec.emp_at_primary_adr_min_ind );
  csd_gen_utility_pvt.add('high_credit                     :'||p_org_rec.high_credit);
  csd_gen_utility_pvt.add('avg_high_credit                 :'||p_org_rec.avg_high_credit);
  csd_gen_utility_pvt.add('total_payments                  :'||p_org_rec.total_payments);
  csd_gen_utility_pvt.add('credit_score_class              :'||p_org_rec.credit_score_class);
  csd_gen_utility_pvt.add('credit_score_natl_percentile    :'||p_org_rec.credit_score_natl_percentile);
  csd_gen_utility_pvt.add('credit_score_incd_default       :'||p_org_rec.credit_score_incd_default);
  csd_gen_utility_pvt.add('credit_score_age                :'||p_org_rec.credit_score_age);
  csd_gen_utility_pvt.add('credit_score_date               :'||p_org_rec.credit_score_date);
  csd_gen_utility_pvt.add('credit_score_commentary2        :'||p_org_rec.credit_score_commentary2 );
  csd_gen_utility_pvt.add('credit_score_commentary3        :'||p_org_rec.credit_score_commentary3 );
  csd_gen_utility_pvt.add('credit_score_commentary4        :'||p_org_rec.credit_score_commentary4 );
  csd_gen_utility_pvt.add('credit_score_commentary5        :'||p_org_rec.credit_score_commentary5 );
  csd_gen_utility_pvt.add('credit_score_commentary6        :'||p_org_rec.credit_score_commentary6 );
  csd_gen_utility_pvt.add('credit_score_commentary7        :'||p_org_rec.credit_score_commentary7 );
  csd_gen_utility_pvt.add('credit_score_commentary8        :'||p_org_rec.credit_score_commentary8 );
  csd_gen_utility_pvt.add('credit_score_commentary9        :'||p_org_rec.credit_score_commentary9 );
  csd_gen_utility_pvt.add('credit_score_commentary10       :'||p_org_rec.credit_score_commentary10 );
  csd_gen_utility_pvt.add('failure_score_class             :'||p_org_rec.failure_score_class);
  csd_gen_utility_pvt.add('failure_score_incd_default      :'||p_org_rec.failure_score_incd_default);
  csd_gen_utility_pvt.add('failure_score_age               :'||p_org_rec.failure_score_age);
  csd_gen_utility_pvt.add('failure_score_date              :'||p_org_rec.failure_score_date);
  csd_gen_utility_pvt.add('failure_score_commentary2       :'||p_org_rec.failure_score_commentary2 );
  csd_gen_utility_pvt.add('failure_score_commentary3       :'||p_org_rec.failure_score_commentary3 );
  csd_gen_utility_pvt.add('failure_score_commentary4       :'||p_org_rec.failure_score_commentary4 );
  csd_gen_utility_pvt.add('failure_score_commentary5       :'||p_org_rec.failure_score_commentary5 );
  csd_gen_utility_pvt.add('failure_score_commentary6       :'||p_org_rec.failure_score_commentary6 );
  csd_gen_utility_pvt.add('failure_score_commentary7       :'||p_org_rec.failure_score_commentary7 );
  csd_gen_utility_pvt.add('failure_score_commentary8       :'||p_org_rec.failure_score_commentary8 );
  csd_gen_utility_pvt.add('failure_score_commentary9       :'||p_org_rec.failure_score_commentary9 );
  csd_gen_utility_pvt.add('failure_score_commentary10      :'||p_org_rec.failure_score_commentary10 );
  csd_gen_utility_pvt.add('maximum_credit_recommendation   :'||p_org_rec.maximum_credit_recommendation);
  csd_gen_utility_pvt.add('maximum_credit_currency_code    :'||p_org_rec.maximum_credit_currency_code );
  csd_gen_utility_pvt.add('displayed_duns_party_id         :'||p_org_rec.displayed_duns_party_id);
  csd_gen_utility_pvt.add('content_source_type             :'||p_org_rec.content_source_type );
  csd_gen_utility_pvt.add('content_source_number           :'||p_org_rec.content_source_number );
  csd_gen_utility_pvt.add('attribute_category              :'||p_org_rec.attribute_category );
  csd_gen_utility_pvt.add('attribute1                      :'||p_org_rec.attribute1 );
  csd_gen_utility_pvt.add('attribute2                      :'||p_org_rec.attribute2 );
  csd_gen_utility_pvt.add('attribute3                      :'||p_org_rec.attribute3 );
  csd_gen_utility_pvt.add('attribute4                      :'||p_org_rec.attribute4 );
  csd_gen_utility_pvt.add('attribute5                      :'||p_org_rec.attribute5 );
  csd_gen_utility_pvt.add('attribute6                      :'||p_org_rec.attribute6 );
  csd_gen_utility_pvt.add('attribute7                      :'||p_org_rec.attribute7 );
  csd_gen_utility_pvt.add('attribute8                      :'||p_org_rec.attribute8 );
  csd_gen_utility_pvt.add('attribute9                      :'||p_org_rec.attribute9 );
  csd_gen_utility_pvt.add('attribute10                     :'||p_org_rec.attribute10 );
  csd_gen_utility_pvt.add('attribute11                     :'||p_org_rec.attribute11 );
  csd_gen_utility_pvt.add('attribute12                     :'||p_org_rec.attribute12 );
  csd_gen_utility_pvt.add('attribute13                     :'||p_org_rec.attribute13 );
  csd_gen_utility_pvt.add('attribute14                     :'||p_org_rec.attribute14 );
  csd_gen_utility_pvt.add('attribute15                     :'||p_org_rec.attribute15 );
  csd_gen_utility_pvt.add('attribute16                     :'||p_org_rec.attribute16 );
  csd_gen_utility_pvt.add('attribute17                     :'||p_org_rec.attribute17 );
  csd_gen_utility_pvt.add('attribute18                     :'||p_org_rec.attribute18 );
  csd_gen_utility_pvt.add('attribute19                     :'||p_org_rec.attribute19 );
  csd_gen_utility_pvt.add('attribute20                     :'||p_org_rec.attribute20 );
  csd_gen_utility_pvt.add('party_rec.party_id                  :'||p_org_rec.party_rec.party_id);
  csd_gen_utility_pvt.add('party_rec.party_number              :'||p_org_rec.party_rec.party_number );
  csd_gen_utility_pvt.add('party_rec.validated_flag            :'||p_org_rec.party_rec.validated_flag );
  csd_gen_utility_pvt.add('party_rec.orig_system_reference     :'||p_org_rec.party_rec.orig_system_reference );
  csd_gen_utility_pvt.add('party_rec.status                    :'||p_org_rec.party_rec.status );
  csd_gen_utility_pvt.add('party_rec.category_code             :'||p_org_rec.party_rec.category_code );
  csd_gen_utility_pvt.add('party_rec.salutation                :'||p_org_rec.party_rec.salutation );
  csd_gen_utility_pvt.add('party_rec.attribute_category        :'||p_org_rec.party_rec.attribute_category );
  csd_gen_utility_pvt.add('party_rec.attribute1                :'||p_org_rec.party_rec.attribute1 );
  csd_gen_utility_pvt.add('party_rec.attribute2                :'||p_org_rec.party_rec.attribute2 );
  csd_gen_utility_pvt.add('party_rec.attribute3                :'||p_org_rec.party_rec.attribute3 );
  csd_gen_utility_pvt.add('party_rec.attribute4                :'||p_org_rec.party_rec.attribute4 );
  csd_gen_utility_pvt.add('party_rec.attribute5                :'||p_org_rec.party_rec.attribute5 );
  csd_gen_utility_pvt.add('party_rec.attribute6                :'||p_org_rec.party_rec.attribute6 );
  csd_gen_utility_pvt.add('party_rec.attribute7                :'||p_org_rec.party_rec.attribute7 );
  csd_gen_utility_pvt.add('party_rec.attribute8                :'||p_org_rec.party_rec.attribute8 );
  csd_gen_utility_pvt.add('party_rec.attribute9                :'||p_org_rec.party_rec.attribute9 );
  csd_gen_utility_pvt.add('party_rec.attribute10               :'||p_org_rec.party_rec.attribute10 );
  csd_gen_utility_pvt.add('party_rec.attribute11               :'||p_org_rec.party_rec.attribute11 );
  csd_gen_utility_pvt.add('party_rec.attribute12               :'||p_org_rec.party_rec.attribute12 );
  csd_gen_utility_pvt.add('party_rec.attribute13               :'||p_org_rec.party_rec.attribute13 );
  csd_gen_utility_pvt.add('party_rec.attribute14               :'||p_org_rec.party_rec.attribute14 );
  csd_gen_utility_pvt.add('party_rec.attribute15               :'||p_org_rec.party_rec.attribute15 );
  csd_gen_utility_pvt.add('party_rec.attribute16               :'||p_org_rec.party_rec.attribute16 );
  csd_gen_utility_pvt.add('party_rec.attribute17               :'||p_org_rec.party_rec.attribute17 );
  csd_gen_utility_pvt.add('party_rec.attribute18               :'||p_org_rec.party_rec.attribute18 );
  csd_gen_utility_pvt.add('party_rec.attribute19               :'||p_org_rec.party_rec.attribute19 );
  csd_gen_utility_pvt.add('party_rec.attribute20               :'||p_org_rec.party_rec.attribute20 );
  csd_gen_utility_pvt.add('party_rec.attribute21               :'||p_org_rec.party_rec.attribute21 );
  csd_gen_utility_pvt.add('party_rec.attribute22               :'||p_org_rec.party_rec.attribute22 );
  csd_gen_utility_pvt.add('party_rec.attribute23               :'||p_org_rec.party_rec.attribute23 );
  csd_gen_utility_pvt.add('party_rec.attribute24               :'||p_org_rec.party_rec.attribute24 );
END dump_hz_org_rec;



PROCEDURE dump_hz_acct_rec (
    p_account_rec             IN  HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.add('HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type');
  csd_gen_utility_pvt.add('cust_account_id                :'||p_account_rec.cust_account_id);
  csd_gen_utility_pvt.add('account_number                 :'||p_account_rec.account_number);
  csd_gen_utility_pvt.add('attribute_category             :'||p_account_rec.attribute_category);
  csd_gen_utility_pvt.add('attribute1                     :'||p_account_rec.attribute1);
  csd_gen_utility_pvt.add('attribute2                     :'||p_account_rec.attribute2);
  csd_gen_utility_pvt.add('attribute3                     :'||p_account_rec.attribute3);
  csd_gen_utility_pvt.add('attribute4                     :'||p_account_rec.attribute4);
  csd_gen_utility_pvt.add('attribute5                     :'||p_account_rec.attribute5);
  csd_gen_utility_pvt.add('attribute6                     :'||p_account_rec.attribute6);
  csd_gen_utility_pvt.add('attribute7                     :'||p_account_rec.attribute7);
  csd_gen_utility_pvt.add('attribute8                     :'||p_account_rec.attribute8);
  csd_gen_utility_pvt.add('attribute9                     :'||p_account_rec.attribute9);
  csd_gen_utility_pvt.add('attribute10                    :'||p_account_rec.attribute10);
  csd_gen_utility_pvt.add('attribute11                    :'||p_account_rec.attribute11);
  csd_gen_utility_pvt.add('attribute12                    :'||p_account_rec.attribute12);
  csd_gen_utility_pvt.add('attribute13                    :'||p_account_rec.attribute13);
  csd_gen_utility_pvt.add('attribute14                    :'||p_account_rec.attribute14);
  csd_gen_utility_pvt.add('attribute15                    :'||p_account_rec.attribute15);
  csd_gen_utility_pvt.add('attribute16                    :'||p_account_rec.attribute16);
  csd_gen_utility_pvt.add('attribute17                    :'||p_account_rec.attribute17);
  csd_gen_utility_pvt.add('attribute18                    :'||p_account_rec.attribute18);
  csd_gen_utility_pvt.add('attribute19                    :'||p_account_rec.attribute19);
  csd_gen_utility_pvt.add('attribute20                    :'||p_account_rec.attribute20);
  csd_gen_utility_pvt.add('global_attribute_category      :'||p_account_rec.global_attribute_category);
  csd_gen_utility_pvt.add('global_attribute1              :'||p_account_rec.global_attribute1);
  csd_gen_utility_pvt.add('global_attribute2              :'||p_account_rec.global_attribute2);
  csd_gen_utility_pvt.add('global_attribute3              :'||p_account_rec.global_attribute3);
  csd_gen_utility_pvt.add('global_attribute4              :'||p_account_rec.global_attribute4);
  csd_gen_utility_pvt.add('global_attribute5              :'||p_account_rec.global_attribute5);
  csd_gen_utility_pvt.add('global_attribute6              :'||p_account_rec.global_attribute6);
  csd_gen_utility_pvt.add('global_attribute7              :'||p_account_rec.global_attribute7);
  csd_gen_utility_pvt.add('global_attribute8              :'||p_account_rec.global_attribute8);
  csd_gen_utility_pvt.add('global_attribute9              :'||p_account_rec.global_attribute9);
  csd_gen_utility_pvt.add('global_attribute10             :'||p_account_rec.global_attribute10);
  csd_gen_utility_pvt.add('global_attribute11             :'||p_account_rec.global_attribute11);
  csd_gen_utility_pvt.add('global_attribute12             :'||p_account_rec.global_attribute12);
  csd_gen_utility_pvt.add('global_attribute13             :'||p_account_rec.global_attribute13);
  csd_gen_utility_pvt.add('global_attribute14             :'||p_account_rec.global_attribute14);
  csd_gen_utility_pvt.add('global_attribute15             :'||p_account_rec.global_attribute15);
  csd_gen_utility_pvt.add('global_attribute16             :'||p_account_rec.global_attribute16);
  csd_gen_utility_pvt.add('global_attribute17             :'||p_account_rec.global_attribute17);
  csd_gen_utility_pvt.add('global_attribute18             :'||p_account_rec.global_attribute18);
  csd_gen_utility_pvt.add('global_attribute19             :'||p_account_rec.global_attribute19);
  csd_gen_utility_pvt.add('global_attribute20             :'||p_account_rec.global_attribute20);
  csd_gen_utility_pvt.add('orig_system_reference          :'||p_account_rec.orig_system_reference);
  csd_gen_utility_pvt.add('status                         :'||p_account_rec.status);
  csd_gen_utility_pvt.add('customer_type                  :'||p_account_rec.customer_type);
  csd_gen_utility_pvt.add('customer_class_code            :'||p_account_rec.customer_class_code);
  csd_gen_utility_pvt.add('primary_salesrep_id            :'||p_account_rec.primary_salesrep_id);
  csd_gen_utility_pvt.add('sales_channel_code             :'||p_account_rec.sales_channel_code);
  csd_gen_utility_pvt.add('order_type_id                  :'||p_account_rec.order_type_id);
  csd_gen_utility_pvt.add('price_list_id                  :'||p_account_rec.price_list_id);
  -- csd_gen_utility_pvt.add('subcategory_code               :'||p_account_rec.subcategory_code);
  csd_gen_utility_pvt.add('tax_code                       :'||p_account_rec.tax_code);
  csd_gen_utility_pvt.add('fob_point                      :'||p_account_rec.fob_point);
  csd_gen_utility_pvt.add('freight_term                   :'||p_account_rec.freight_term);
  csd_gen_utility_pvt.add('ship_partial                   :'||p_account_rec.ship_partial);
  csd_gen_utility_pvt.add('ship_via                       :'||p_account_rec.ship_via);
  csd_gen_utility_pvt.add('warehouse_id                   :'||p_account_rec.warehouse_id);
  -- csd_gen_utility_pvt.add('payment_term_id                :'||p_account_rec.payment_term_id);
  csd_gen_utility_pvt.add('tax_header_level_flag          :'||p_account_rec.tax_header_level_flag);
  csd_gen_utility_pvt.add('tax_rounding_rule              :'||p_account_rec.tax_rounding_rule);
  csd_gen_utility_pvt.add('coterminate_day_month          :'||p_account_rec.coterminate_day_month);
  csd_gen_utility_pvt.add('primary_specialist_id          :'||p_account_rec.primary_specialist_id);
  csd_gen_utility_pvt.add('secondary_specialist_id        :'||p_account_rec.secondary_specialist_id);
  csd_gen_utility_pvt.add('account_liable_flag            :'||p_account_rec.account_liable_flag);
  csd_gen_utility_pvt.add('current_balance                :'||p_account_rec.current_balance);
  csd_gen_utility_pvt.add('account_established_date       :'||p_account_rec.account_established_date);
  csd_gen_utility_pvt.add('account_termination_date       :'||p_account_rec.account_termination_date);
  csd_gen_utility_pvt.add('account_activation_date        :'||p_account_rec.account_activation_date);
  csd_gen_utility_pvt.add('department                     :'||p_account_rec.department);
  csd_gen_utility_pvt.add('held_bill_expiration_date      :'||p_account_rec.held_bill_expiration_date);
  csd_gen_utility_pvt.add('hold_bill_flag                 :'||p_account_rec.hold_bill_flag);
  csd_gen_utility_pvt.add('realtime_rate_flag             :'||p_account_rec.realtime_rate_flag);
  csd_gen_utility_pvt.add('acct_life_cycle_status         :'||p_account_rec.acct_life_cycle_status);
  csd_gen_utility_pvt.add('account_name                   :'||p_account_rec.account_name);
  csd_gen_utility_pvt.add('deposit_refund_method          :'||p_account_rec.deposit_refund_method);
  csd_gen_utility_pvt.add('dormant_account_flag           :'||p_account_rec.dormant_account_flag);
  csd_gen_utility_pvt.add('npa_number                     :'||p_account_rec.npa_number);
  csd_gen_utility_pvt.add('suspension_date                :'||p_account_rec.suspension_date);
  csd_gen_utility_pvt.add('source_code                    :'||p_account_rec.source_code);
  csd_gen_utility_pvt.add('comments                       :'||p_account_rec.comments);
  csd_gen_utility_pvt.add('dates_negative_tolerance       :'||p_account_rec.dates_negative_tolerance);
  csd_gen_utility_pvt.add('dates_positive_tolerance       :'||p_account_rec.dates_positive_tolerance);
  csd_gen_utility_pvt.add('date_type_preference           :'||p_account_rec.date_type_preference);
  csd_gen_utility_pvt.add('over_shipment_tolerance        :'||p_account_rec.over_shipment_tolerance);
  csd_gen_utility_pvt.add('under_shipment_tolerance       :'||p_account_rec.under_shipment_tolerance);
  csd_gen_utility_pvt.add('over_return_tolerance          :'||p_account_rec.over_return_tolerance);
  csd_gen_utility_pvt.add('under_return_tolerance         :'||p_account_rec.under_return_tolerance);
  csd_gen_utility_pvt.add('item_cross_ref_pref            :'||p_account_rec.item_cross_ref_pref);
  csd_gen_utility_pvt.add('ship_sets_include_lines_flag   :'||p_account_rec.ship_sets_include_lines_flag);
  csd_gen_utility_pvt.add('arrivalsets_include_lines_flag :'||p_account_rec.arrivalsets_include_lines_flag);
  csd_gen_utility_pvt.add('sched_date_push_flag           :'||p_account_rec.sched_date_push_flag);
  csd_gen_utility_pvt.add('invoice_quantity_rule          :'||p_account_rec.invoice_quantity_rule);
  csd_gen_utility_pvt.add('pricing_event                  :'||p_account_rec.pricing_event);
  csd_gen_utility_pvt.add('status_update_date             :'||p_account_rec.status_update_date);
  csd_gen_utility_pvt.add('autopay_flag                   :'||p_account_rec.autopay_flag);
  csd_gen_utility_pvt.add('notify_flag                    :'||p_account_rec.notify_flag);
  csd_gen_utility_pvt.add('last_batch_id                  :'||p_account_rec.last_batch_id);
END dump_hz_acct_rec;



PROCEDURE dump_hz_cust_profile_rec (
    p_cust_profile_rec        IN  HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.add('HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type');
  csd_gen_utility_pvt.add('cust_account_profile_id       :'||p_cust_profile_rec.cust_account_profile_id);
  csd_gen_utility_pvt.add('cust_account_id               :'||p_cust_profile_rec.cust_account_id);
  csd_gen_utility_pvt.add('status                        :'||p_cust_profile_rec.status);
  csd_gen_utility_pvt.add('collector_id                  :'||p_cust_profile_rec.collector_id);
  csd_gen_utility_pvt.add('credit_analyst_id             :'||p_cust_profile_rec.credit_analyst_id);
  csd_gen_utility_pvt.add('credit_checking               :'||p_cust_profile_rec.credit_checking);
  csd_gen_utility_pvt.add('next_credit_review_date       :'||p_cust_profile_rec.next_credit_review_date);
  csd_gen_utility_pvt.add('tolerance                     :'||p_cust_profile_rec.tolerance);
  csd_gen_utility_pvt.add('discount_terms                :'||p_cust_profile_rec.discount_terms);
  csd_gen_utility_pvt.add('dunning_letters               :'||p_cust_profile_rec.dunning_letters);
  csd_gen_utility_pvt.add('interest_charges              :'||p_cust_profile_rec.interest_charges);
  csd_gen_utility_pvt.add('send_statements               :'||p_cust_profile_rec.send_statements);
  csd_gen_utility_pvt.add('credit_balance_statements     :'||p_cust_profile_rec.credit_balance_statements);
  csd_gen_utility_pvt.add('credit_hold                   :'||p_cust_profile_rec.credit_hold);
  csd_gen_utility_pvt.add('profile_class_id              :'||p_cust_profile_rec.profile_class_id);
  csd_gen_utility_pvt.add('site_use_id                   :'||p_cust_profile_rec.site_use_id);
  csd_gen_utility_pvt.add('credit_rating                 :'||p_cust_profile_rec.credit_rating);
  csd_gen_utility_pvt.add('risk_code                     :'||p_cust_profile_rec.risk_code);
  csd_gen_utility_pvt.add('standard_terms                :'||p_cust_profile_rec.standard_terms);
  csd_gen_utility_pvt.add('override_terms                :'||p_cust_profile_rec.override_terms);
  csd_gen_utility_pvt.add('dunning_letter_set_id         :'||p_cust_profile_rec.dunning_letter_set_id);
  csd_gen_utility_pvt.add('interest_period_days          :'||p_cust_profile_rec.interest_period_days);
  csd_gen_utility_pvt.add('payment_grace_days            :'||p_cust_profile_rec.payment_grace_days);
  csd_gen_utility_pvt.add('discount_grace_days           :'||p_cust_profile_rec.discount_grace_days);
  csd_gen_utility_pvt.add('statement_cycle_id            :'||p_cust_profile_rec.statement_cycle_id);
  csd_gen_utility_pvt.add('account_status                :'||p_cust_profile_rec.account_status);
  csd_gen_utility_pvt.add('percent_collectable           :'||p_cust_profile_rec.percent_collectable);
  csd_gen_utility_pvt.add('autocash_hierarchy_id         :'||p_cust_profile_rec.autocash_hierarchy_id);
  csd_gen_utility_pvt.add('attribute_category            :'||p_cust_profile_rec.attribute_category);
  csd_gen_utility_pvt.add('attribute1                    :'||p_cust_profile_rec.attribute1);
  csd_gen_utility_pvt.add('attribute2                    :'||p_cust_profile_rec.attribute2);
  csd_gen_utility_pvt.add('attribute3                    :'||p_cust_profile_rec.attribute3);
  csd_gen_utility_pvt.add('attribute4                    :'||p_cust_profile_rec.attribute4);
  csd_gen_utility_pvt.add('attribute5                    :'||p_cust_profile_rec.attribute5);
  csd_gen_utility_pvt.add('attribute6                    :'||p_cust_profile_rec.attribute6);
  csd_gen_utility_pvt.add('attribute7                    :'||p_cust_profile_rec.attribute7);
  csd_gen_utility_pvt.add('attribute8                    :'||p_cust_profile_rec.attribute8);
  csd_gen_utility_pvt.add('attribute9                    :'||p_cust_profile_rec.attribute9);
  csd_gen_utility_pvt.add('attribute10                   :'||p_cust_profile_rec.attribute10);
  csd_gen_utility_pvt.add('attribute11                   :'||p_cust_profile_rec.attribute11);
  csd_gen_utility_pvt.add('attribute12                   :'||p_cust_profile_rec.attribute12);
  csd_gen_utility_pvt.add('attribute13                   :'||p_cust_profile_rec.attribute13);
  csd_gen_utility_pvt.add('attribute14                   :'||p_cust_profile_rec.attribute14);
  csd_gen_utility_pvt.add('attribute15                   :'||p_cust_profile_rec.attribute15);
  csd_gen_utility_pvt.add('auto_rec_incl_disputed_flag   :'||p_cust_profile_rec.auto_rec_incl_disputed_flag);
  csd_gen_utility_pvt.add('tax_printing_option           :'||p_cust_profile_rec.tax_printing_option);
  csd_gen_utility_pvt.add('charge_on_finance_charge_flag :'||p_cust_profile_rec.charge_on_finance_charge_flag);
  csd_gen_utility_pvt.add('grouping_rule_id              :'||p_cust_profile_rec.grouping_rule_id);
  csd_gen_utility_pvt.add('clearing_days                 :'||p_cust_profile_rec.clearing_days);
  csd_gen_utility_pvt.add('jgzz_attribute_category       :'||p_cust_profile_rec.jgzz_attribute_category);
  csd_gen_utility_pvt.add('jgzz_attribute1               :'||p_cust_profile_rec.jgzz_attribute1);
  csd_gen_utility_pvt.add('jgzz_attribute2               :'||p_cust_profile_rec.jgzz_attribute2);
  csd_gen_utility_pvt.add('jgzz_attribute3               :'||p_cust_profile_rec.jgzz_attribute3);
  csd_gen_utility_pvt.add('jgzz_attribute4               :'||p_cust_profile_rec.jgzz_attribute4);
  csd_gen_utility_pvt.add('jgzz_attribute5               :'||p_cust_profile_rec.jgzz_attribute5);
  csd_gen_utility_pvt.add('jgzz_attribute6               :'||p_cust_profile_rec.jgzz_attribute6);
  csd_gen_utility_pvt.add('jgzz_attribute7               :'||p_cust_profile_rec.jgzz_attribute7);
  csd_gen_utility_pvt.add('jgzz_attribute8               :'||p_cust_profile_rec.jgzz_attribute8);
  csd_gen_utility_pvt.add('jgzz_attribute9               :'||p_cust_profile_rec.jgzz_attribute9);
  csd_gen_utility_pvt.add('jgzz_attribute10              :'||p_cust_profile_rec.jgzz_attribute10);
  csd_gen_utility_pvt.add('jgzz_attribute11              :'||p_cust_profile_rec.jgzz_attribute11);
  csd_gen_utility_pvt.add('jgzz_attribute12              :'||p_cust_profile_rec.jgzz_attribute12);
  csd_gen_utility_pvt.add('jgzz_attribute13              :'||p_cust_profile_rec.jgzz_attribute13);
  csd_gen_utility_pvt.add('jgzz_attribute14              :'||p_cust_profile_rec.jgzz_attribute14);
  csd_gen_utility_pvt.add('jgzz_attribute15              :'||p_cust_profile_rec.jgzz_attribute15);
  csd_gen_utility_pvt.add('global_attribute1             :'||p_cust_profile_rec.global_attribute1);
  csd_gen_utility_pvt.add('global_attribute2             :'||p_cust_profile_rec.global_attribute2);
  csd_gen_utility_pvt.add('global_attribute3             :'||p_cust_profile_rec.global_attribute3);
  csd_gen_utility_pvt.add('global_attribute4             :'||p_cust_profile_rec.global_attribute4);
  csd_gen_utility_pvt.add('global_attribute5             :'||p_cust_profile_rec.global_attribute5);
  csd_gen_utility_pvt.add('global_attribute6             :'||p_cust_profile_rec.global_attribute6);
  csd_gen_utility_pvt.add('global_attribute7             :'||p_cust_profile_rec.global_attribute7);
  csd_gen_utility_pvt.add('global_attribute8             :'||p_cust_profile_rec.global_attribute8);
  csd_gen_utility_pvt.add('global_attribute9             :'||p_cust_profile_rec.global_attribute9);
  csd_gen_utility_pvt.add('global_attribute10            :'||p_cust_profile_rec.global_attribute10);
  csd_gen_utility_pvt.add('global_attribute11            :'||p_cust_profile_rec.global_attribute11);
  csd_gen_utility_pvt.add('global_attribute12            :'||p_cust_profile_rec.global_attribute12);
  csd_gen_utility_pvt.add('global_attribute13            :'||p_cust_profile_rec.global_attribute13);
  csd_gen_utility_pvt.add('global_attribute14            :'||p_cust_profile_rec.global_attribute14);
  csd_gen_utility_pvt.add('global_attribute15            :'||p_cust_profile_rec.global_attribute15);
  csd_gen_utility_pvt.add('global_attribute16            :'||p_cust_profile_rec.global_attribute16);
  csd_gen_utility_pvt.add('global_attribute17            :'||p_cust_profile_rec.global_attribute17);
  csd_gen_utility_pvt.add('global_attribute18            :'||p_cust_profile_rec.global_attribute18);
  csd_gen_utility_pvt.add('global_attribute19            :'||p_cust_profile_rec.global_attribute19);
  csd_gen_utility_pvt.add('global_attribute20            :'||p_cust_profile_rec.global_attribute20);
  csd_gen_utility_pvt.add('global_attribute_category     :'||p_cust_profile_rec.global_attribute_category);
  csd_gen_utility_pvt.add('cons_inv_flag                 :'||p_cust_profile_rec.cons_inv_flag);
  csd_gen_utility_pvt.add('cons_inv_type                 :'||p_cust_profile_rec.cons_inv_type);
  csd_gen_utility_pvt.add('autocash_hierarchy_id_for_adr :'||p_cust_profile_rec.autocash_hierarchy_id_for_adr);
  csd_gen_utility_pvt.add('lockbox_matching_option       :'||p_cust_profile_rec.lockbox_matching_option);
END dump_hz_cust_profile_rec;



PROCEDURE dump_hz_phone_rec (
    p_phone_rec               IN  HZ_CONTACT_POINT_V2PUB.phone_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.add('HZ_CONTACT_POINT_V2PUB.phone_rec_type');
  csd_gen_utility_pvt.add('phone_calling_calendar        :'||p_phone_rec.phone_calling_calendar);
  csd_gen_utility_pvt.add('last_contact_dt_time          :'||p_phone_rec.last_contact_dt_time);
  csd_gen_utility_pvt.add('timezone_id                   :'||p_phone_rec.timezone_id);
  csd_gen_utility_pvt.add('phone_area_code               :'||p_phone_rec.phone_area_code);
  csd_gen_utility_pvt.add('phone_country_code            :'||p_phone_rec.phone_country_code);
  csd_gen_utility_pvt.add('phone_number                  :'||p_phone_rec.phone_number);
  csd_gen_utility_pvt.add('phone_extension               :'||p_phone_rec.phone_extension);
  csd_gen_utility_pvt.add('phone_line_type               :'||p_phone_rec.phone_line_type);
  csd_gen_utility_pvt.add('raw_phone_number              :'||p_phone_rec.raw_phone_number);
END dump_hz_phone_rec;



PROCEDURE dump_hz_email_rec (
    p_email_rec               IN  HZ_CONTACT_POINT_V2PUB.email_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.add('HZ_CONTACT_POINT_PUB.email_rec_type');
  csd_gen_utility_pvt.add('email_format  :'||p_email_rec.email_format);
  csd_gen_utility_pvt.add('email_address :'||p_email_rec.email_address);
END dump_hz_email_rec;



PROCEDURE dump_hz_web_rec (
    p_web_rec                 IN  HZ_CONTACT_POINT_V2PUB.web_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.add('HZ_CONTACT_POINT_PUB.web_rec_type');
  csd_gen_utility_pvt.add('web_type :'||p_web_rec.web_type);
  csd_gen_utility_pvt.add('url      :'||p_web_rec.url);
END dump_hz_web_rec;



PROCEDURE dump_address_rec (
    p_addr_rec            IN  CSD_PROCESS_PVT.address_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.add('CSD_PROCESS_PVT.address_rec_type');
  csd_gen_utility_pvt.add('location_id                   :'||p_addr_rec.location_id);
  csd_gen_utility_pvt.add('address1                      :'||p_addr_rec.address1);
  csd_gen_utility_pvt.add('address2                      :'||p_addr_rec.address2);
  csd_gen_utility_pvt.add('address3                      :'||p_addr_rec.address3);
  csd_gen_utility_pvt.add('address4                      :'||p_addr_rec.address4);
  csd_gen_utility_pvt.add('city                          :'||p_addr_rec.city);
  csd_gen_utility_pvt.add('state                         :'||p_addr_rec.state);
  csd_gen_utility_pvt.add('postal_code                   :'||p_addr_rec.postal_code);
  csd_gen_utility_pvt.add('province                      :'||p_addr_rec.province);
  csd_gen_utility_pvt.add('county                        :'||p_addr_rec.county);
  csd_gen_utility_pvt.add('country                       :'||p_addr_rec.country);
  csd_gen_utility_pvt.add('language                      :'||p_addr_rec.language);
  csd_gen_utility_pvt.add('position                      :'||p_addr_rec.position);
  csd_gen_utility_pvt.add('address_key                   :'||p_addr_rec.address_key);
  csd_gen_utility_pvt.add('postal_plus4_code             :'||p_addr_rec.postal_plus4_code);
  csd_gen_utility_pvt.add('delivery_point_code           :'||p_addr_rec.delivery_point_code);
  csd_gen_utility_pvt.add('location_directions           :'||p_addr_rec.location_directions);
  -- csd_gen_utility_pvt.add('address_error_code            :'||p_addr_rec.address_error_code);
  csd_gen_utility_pvt.add('clli_code                     :'||p_addr_rec.clli_code);
  csd_gen_utility_pvt.add('short_description             :'||p_addr_rec.short_description);
  csd_gen_utility_pvt.add('description                   :'||p_addr_rec.description);
  csd_gen_utility_pvt.add('sales_tax_geocode             :'||p_addr_rec.sales_tax_geocode);
  csd_gen_utility_pvt.add('sales_tax_inside_city_limits  :'||p_addr_rec.sales_tax_inside_city_limits);
  csd_gen_utility_pvt.add('address_effective_date        :'||p_addr_rec.address_effective_date);
  csd_gen_utility_pvt.add('address_expiration_date       :'||p_addr_rec.address_expiration_date);
  csd_gen_utility_pvt.add('address_style                 :'||p_addr_rec.address_style);
END dump_address_rec;

PROCEDURE dump_hz_party_site_rec (
    p_party_site_rec     IN  HZ_PARTY_SITE_V2PUB.party_site_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.add('HZ_PARTY_SITE_V2PUB.party_site_rec_type');
  csd_gen_utility_pvt.add('party_site_id              :'||p_party_site_rec.party_site_id);
  csd_gen_utility_pvt.add('party_id                   :'||p_party_site_rec.party_id);
  csd_gen_utility_pvt.add('location_id                :'||p_party_site_rec.location_id);
  csd_gen_utility_pvt.add('party_site_number          :'||p_party_site_rec.party_site_number);
  csd_gen_utility_pvt.add('orig_system_reference      :'||p_party_site_rec.orig_system_reference);
  csd_gen_utility_pvt.add('mailstop                   :'||p_party_site_rec.mailstop);
  csd_gen_utility_pvt.add('identifying_address_flag   :'||p_party_site_rec.identifying_address_flag);
  csd_gen_utility_pvt.add('language                   :'||p_party_site_rec.language);
  csd_gen_utility_pvt.add('status                     :'||p_party_site_rec.status);
  csd_gen_utility_pvt.add('party_site_name            :'||p_party_site_rec.party_site_name);
  csd_gen_utility_pvt.add('attribute_category         :'||p_party_site_rec.attribute_category);
  csd_gen_utility_pvt.add('attribute1                 :'||p_party_site_rec.attribute1);
  csd_gen_utility_pvt.add('attribute2                 :'||p_party_site_rec.attribute2);
  csd_gen_utility_pvt.add('attribute3                 :'||p_party_site_rec.attribute3);
  csd_gen_utility_pvt.add('attribute4                 :'||p_party_site_rec.attribute4);
  csd_gen_utility_pvt.add('attribute5                 :'||p_party_site_rec.attribute5);
  csd_gen_utility_pvt.add('attribute6                 :'||p_party_site_rec.attribute6);
  csd_gen_utility_pvt.add('attribute7                 :'||p_party_site_rec.attribute7);
  csd_gen_utility_pvt.add('attribute8                 :'||p_party_site_rec.attribute8);
  csd_gen_utility_pvt.add('attribute9                 :'||p_party_site_rec.attribute9);
  csd_gen_utility_pvt.add('attribute10                :'||p_party_site_rec.attribute10);
  csd_gen_utility_pvt.add('attribute11                :'||p_party_site_rec.attribute11);
  csd_gen_utility_pvt.add('attribute12                :'||p_party_site_rec.attribute12);
  csd_gen_utility_pvt.add('attribute13                :'||p_party_site_rec.attribute13);
  csd_gen_utility_pvt.add('attribute14                :'||p_party_site_rec.attribute14);
  csd_gen_utility_pvt.add('attribute15                :'||p_party_site_rec.attribute15);
  csd_gen_utility_pvt.add('attribute16                :'||p_party_site_rec.attribute16);
  csd_gen_utility_pvt.add('attribute17                :'||p_party_site_rec.attribute17);
  csd_gen_utility_pvt.add('attribute18                :'||p_party_site_rec.attribute18);
  csd_gen_utility_pvt.add('attribute19                :'||p_party_site_rec.attribute19);
  csd_gen_utility_pvt.add('attribute20                :'||p_party_site_rec.attribute20);
  csd_gen_utility_pvt.add('addressee                  :'||p_party_site_rec.addressee);
END dump_hz_party_site_rec;



PROCEDURE dump_hz_party_site_use_rec (
    p_party_site_use_rec IN  HZ_PARTY_SITE_V2PUB.party_site_use_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.add('HZ_PARTY_SITE_V2PUB.party_site_use_rec_type');
  csd_gen_utility_pvt.add('party_site_use_id :'||p_party_site_use_rec.party_site_use_id);
  csd_gen_utility_pvt.add('comments          :'||p_party_site_use_rec.comments);
  csd_gen_utility_pvt.add('site_use_type     :'||p_party_site_use_rec.site_use_type);
  csd_gen_utility_pvt.add('party_site_id     :'||p_party_site_use_rec.party_site_id);
  csd_gen_utility_pvt.add('primary_per_type  :'||p_party_site_use_rec.primary_per_type);
  csd_gen_utility_pvt.add('status            :'||p_party_site_use_rec.status);
END dump_hz_party_site_use_rec;



PROCEDURE dump_hz_party_rel_rec (
    p_party_rel_rec      IN  HZ_RELATIONSHIP_V2PUB.relationship_rec_type
)
IS
BEGIN
  csd_gen_utility_pvt.add('HZ_RELATIONSHIP_V2PUB.relationship_rec_type');
  csd_gen_utility_pvt.add('relationship_id      :'||p_party_rel_rec.relationship_id);

  csd_gen_utility_pvt.add('subject_id                 :'||p_party_rel_rec.subject_id);
  csd_gen_utility_pvt.add('subject_type               :'||p_party_rel_rec.subject_type);
  csd_gen_utility_pvt.add('subject_table_name         :'||p_party_rel_rec.subject_table_name);
  csd_gen_utility_pvt.add('object_id                  :'||p_party_rel_rec.object_id);
  csd_gen_utility_pvt.add('object_type                :'||p_party_rel_rec.object_type);
  csd_gen_utility_pvt.add('object_table_name          :'||p_party_rel_rec.object_table_name);
  csd_gen_utility_pvt.add('relationship_type    :'||p_party_rel_rec.relationship_type);
  csd_gen_utility_pvt.add('comments                   :'||p_party_rel_rec.comments);
  csd_gen_utility_pvt.add('start_date                 :'||p_party_rel_rec.start_date);
  csd_gen_utility_pvt.add('end_date                   :'||p_party_rel_rec.end_date);
  csd_gen_utility_pvt.add('status                     :'||p_party_rel_rec.status);
  csd_gen_utility_pvt.add('content_source_type        :'||p_party_rel_rec.content_source_type);
  csd_gen_utility_pvt.add('attribute_category         :'||p_party_rel_rec.attribute_category);
  csd_gen_utility_pvt.add('attribute1                 :'||p_party_rel_rec.attribute1);
  csd_gen_utility_pvt.add('attribute2                 :'||p_party_rel_rec.attribute2);
  csd_gen_utility_pvt.add('attribute3                 :'||p_party_rel_rec.attribute3);
  csd_gen_utility_pvt.add('attribute4                 :'||p_party_rel_rec.attribute4);
  csd_gen_utility_pvt.add('attribute5                 :'||p_party_rel_rec.attribute5);
  csd_gen_utility_pvt.add('attribute6                 :'||p_party_rel_rec.attribute6);
  csd_gen_utility_pvt.add('attribute7                 :'||p_party_rel_rec.attribute7);
  csd_gen_utility_pvt.add('attribute8                 :'||p_party_rel_rec.attribute8);
  csd_gen_utility_pvt.add('attribute9                 :'||p_party_rel_rec.attribute9);
  csd_gen_utility_pvt.add('attribute10                :'||p_party_rel_rec.attribute10);
  csd_gen_utility_pvt.add('attribute11                :'||p_party_rel_rec.attribute11);
  csd_gen_utility_pvt.add('attribute12                :'||p_party_rel_rec.attribute12);
  csd_gen_utility_pvt.add('attribute13                :'||p_party_rel_rec.attribute13);
  csd_gen_utility_pvt.add('attribute14                :'||p_party_rel_rec.attribute14);
  csd_gen_utility_pvt.add('attribute15                :'||p_party_rel_rec.attribute15);
  csd_gen_utility_pvt.add('attribute16                :'||p_party_rel_rec.attribute16);
  csd_gen_utility_pvt.add('attribute17                :'||p_party_rel_rec.attribute17);
  csd_gen_utility_pvt.add('attribute18                :'||p_party_rel_rec.attribute18);
  csd_gen_utility_pvt.add('attribute19                :'||p_party_rel_rec.attribute19);
  csd_gen_utility_pvt.add('attribute20                :'||p_party_rel_rec.attribute20);
  csd_gen_utility_pvt.add('party_rec.party_id                  :'||p_party_rel_rec.party_rec.party_id);
  csd_gen_utility_pvt.add('party_rec.party_number              :'||p_party_rel_rec.party_rec.party_number );
  csd_gen_utility_pvt.add('party_rec.validated_flag            :'||p_party_rel_rec.party_rec.validated_flag );
  csd_gen_utility_pvt.add('party_rec.orig_system_reference     :'||p_party_rel_rec.party_rec.orig_system_reference );
  csd_gen_utility_pvt.add('party_rec.status                    :'||p_party_rel_rec.party_rec.status );
  csd_gen_utility_pvt.add('party_rec.category_code             :'||p_party_rel_rec.party_rec.category_code );
  csd_gen_utility_pvt.add('party_rec.salutation                :'||p_party_rel_rec.party_rec.salutation );
  csd_gen_utility_pvt.add('party_rec.attribute_category        :'||p_party_rel_rec.party_rec.attribute_category );
  csd_gen_utility_pvt.add('party_rec.attribute1                :'||p_party_rel_rec.party_rec.attribute1 );
  csd_gen_utility_pvt.add('party_rec.attribute2                :'||p_party_rel_rec.party_rec.attribute2 );
  csd_gen_utility_pvt.add('party_rec.attribute3                :'||p_party_rel_rec.party_rec.attribute3 );
  csd_gen_utility_pvt.add('party_rec.attribute4                :'||p_party_rel_rec.party_rec.attribute4 );
  csd_gen_utility_pvt.add('party_rec.attribute5                :'||p_party_rel_rec.party_rec.attribute5 );
  csd_gen_utility_pvt.add('party_rec.attribute6                :'||p_party_rel_rec.party_rec.attribute6 );
  csd_gen_utility_pvt.add('party_rec.attribute7                :'||p_party_rel_rec.party_rec.attribute7 );
  csd_gen_utility_pvt.add('party_rec.attribute8                :'||p_party_rel_rec.party_rec.attribute8 );
  csd_gen_utility_pvt.add('party_rec.attribute9                :'||p_party_rel_rec.party_rec.attribute9 );
  csd_gen_utility_pvt.add('party_rec.attribute10               :'||p_party_rel_rec.party_rec.attribute10 );
  csd_gen_utility_pvt.add('party_rec.attribute11               :'||p_party_rel_rec.party_rec.attribute11 );
  csd_gen_utility_pvt.add('party_rec.attribute12               :'||p_party_rel_rec.party_rec.attribute12 );
  csd_gen_utility_pvt.add('party_rec.attribute13               :'||p_party_rel_rec.party_rec.attribute13 );
  csd_gen_utility_pvt.add('party_rec.attribute14               :'||p_party_rel_rec.party_rec.attribute14 );
  csd_gen_utility_pvt.add('party_rec.attribute15               :'||p_party_rel_rec.party_rec.attribute15 );
  csd_gen_utility_pvt.add('party_rec.attribute16               :'||p_party_rel_rec.party_rec.attribute16 );
  csd_gen_utility_pvt.add('party_rec.attribute17               :'||p_party_rel_rec.party_rec.attribute17 );
  csd_gen_utility_pvt.add('party_rec.attribute18               :'||p_party_rel_rec.party_rec.attribute18 );
  csd_gen_utility_pvt.add('party_rec.attribute19               :'||p_party_rel_rec.party_rec.attribute19 );
  csd_gen_utility_pvt.add('party_rec.attribute20               :'||p_party_rel_rec.party_rec.attribute20 );
  csd_gen_utility_pvt.add('party_rec.attribute21               :'||p_party_rel_rec.party_rec.attribute21 );
  csd_gen_utility_pvt.add('party_rec.attribute22               :'||p_party_rel_rec.party_rec.attribute22 );
  csd_gen_utility_pvt.add('party_rec.attribute23               :'||p_party_rel_rec.party_rec.attribute23 );
  csd_gen_utility_pvt.add('party_rec.attribute24               :'||p_party_rel_rec.party_rec.attribute24 );
END dump_hz_party_rel_rec;


PROCEDURE dump_diagnostic_code_rec (
      p_diagnostic_code_rec IN  CSD_DIAGNOSTIC_CODES_PVT.diagnostic_code_rec_type
) IS
    l_rec csd_diagnostic_codes_pvt.diagnostic_code_rec_type := p_diagnostic_code_rec;

BEGIN

csd_gen_utility_pvt.add('diagnostic_code _id :'||l_rec.diagnostic_code_id );
csd_gen_utility_pvt.add('object_version_number :'||l_rec.object_version_number   );
csd_gen_utility_pvt.add('diagnostic_code     :'||l_rec.diagnostic_code           );
csd_gen_utility_pvt.add('description         :'||l_rec.description               );
csd_gen_utility_pvt.add('active_from         :'||l_rec.active_from               );
csd_gen_utility_pvt.add('active_to           :'||l_rec.active_to                 );
csd_gen_utility_pvt.add('attribute_category  :'||l_rec.attribute_category        );
csd_gen_utility_pvt.add('attribute1          :'||l_rec.attribute1                );
csd_gen_utility_pvt.add('attribute2          :'||l_rec.attribute2                );
csd_gen_utility_pvt.add('attribute3          :'||l_rec.attribute3                );
csd_gen_utility_pvt.add('attribute4          :'||l_rec.attribute4                );
csd_gen_utility_pvt.add('attribute5          :'||l_rec.attribute5                );
csd_gen_utility_pvt.add('attribute6          :'||l_rec.attribute6                );
csd_gen_utility_pvt.add('attribute7          :'||l_rec.attribute7                );
csd_gen_utility_pvt.add('attribute8          :'||l_rec.attribute8                );
csd_gen_utility_pvt.add('attribute9          :'||l_rec.attribute9                );
csd_gen_utility_pvt.add('attribute10         :'||l_rec.attribute10               );
csd_gen_utility_pvt.add('attribute11         :'||l_rec.attribute11               );
csd_gen_utility_pvt.add('attribute12         :'||l_rec.attribute12               );
csd_gen_utility_pvt.add('attribute13         :'||l_rec.attribute13               );
csd_gen_utility_pvt.add('attribute14         :'||l_rec.attribute14               );
csd_gen_utility_pvt.add('attribute15         :'||l_rec.attribute15               );

END dump_diagnostic_code_rec;

PROCEDURE dump_dc_domain_rec (
      p_dc_domain_rec IN  CSD_DC_DOMAINS_PVT.dc_domain_rec_type
) IS
    l_rec csd_dc_domains_pvt.dc_domain_rec_type := p_dc_domain_rec;

BEGIN

csd_gen_utility_pvt.add('dc_domain _id       :'||l_rec.dc_domain_id              );
csd_gen_utility_pvt.add('object_version_number :'||l_rec.object_version_number   );
csd_gen_utility_pvt.add('diagnostic_code_id  :'||l_rec.diagnostic_code_id        );
csd_gen_utility_pvt.add('inventory_item_id   :'||l_rec.inventory_item_id         );
csd_gen_utility_pvt.add('category_id         :'||l_rec.category_id               );
csd_gen_utility_pvt.add('category_set_id     :'||l_rec.category_set_id           );
csd_gen_utility_pvt.add('domain_type_code    :'||l_rec.domain_type_code          );
csd_gen_utility_pvt.add('attribute_category  :'||l_rec.attribute_category        );
csd_gen_utility_pvt.add('attribute1          :'||l_rec.attribute1                );
csd_gen_utility_pvt.add('attribute2          :'||l_rec.attribute2                );
csd_gen_utility_pvt.add('attribute3          :'||l_rec.attribute3                );
csd_gen_utility_pvt.add('attribute4          :'||l_rec.attribute4                );
csd_gen_utility_pvt.add('attribute5          :'||l_rec.attribute5                );
csd_gen_utility_pvt.add('attribute6          :'||l_rec.attribute6                );
csd_gen_utility_pvt.add('attribute7          :'||l_rec.attribute7                );
csd_gen_utility_pvt.add('attribute8          :'||l_rec.attribute8                );
csd_gen_utility_pvt.add('attribute9          :'||l_rec.attribute9                );
csd_gen_utility_pvt.add('attribute10         :'||l_rec.attribute10               );
csd_gen_utility_pvt.add('attribute11         :'||l_rec.attribute11               );
csd_gen_utility_pvt.add('attribute12         :'||l_rec.attribute12               );
csd_gen_utility_pvt.add('attribute13         :'||l_rec.attribute13               );
csd_gen_utility_pvt.add('attribute14         :'||l_rec.attribute14               );
csd_gen_utility_pvt.add('attribute15         :'||l_rec.attribute15               );

END dump_dc_domain_rec;

PROCEDURE dump_ro_diagnostic_code_rec (
      p_ro_diagnostic_code_rec      IN  CSD_RO_DIAGNOSTIC_CODES_PVT.ro_diagnostic_code_rec_type
) IS
    l_rec csd_ro_diagnostic_codes_pvt.ro_diagnostic_code_rec_type := p_ro_diagnostic_code_rec;

BEGIN

csd_gen_utility_pvt.add('ro_diagnostic_code_id  :'||l_rec.ro_diagnostic_code_id     );
csd_gen_utility_pvt.add('object_version_number  :'||l_rec.object_version_number     );
csd_gen_utility_pvt.add('repair_line_id   	:'||l_rec.repair_line_id            );
csd_gen_utility_pvt.add('diagnostic_code_id   	:'||l_rec.diagnostic_code_id        );
csd_gen_utility_pvt.add('attribute_category  	:'||l_rec.attribute_category        );
csd_gen_utility_pvt.add('attribute1          	:'||l_rec.attribute1                );
csd_gen_utility_pvt.add('attribute2         	:'||l_rec.attribute2                );
csd_gen_utility_pvt.add('attribute3         	:'||l_rec.attribute3                );
csd_gen_utility_pvt.add('attribute4         	:'||l_rec.attribute4                );
csd_gen_utility_pvt.add('attribute5         	:'||l_rec.attribute5                );
csd_gen_utility_pvt.add('attribute6         	:'||l_rec.attribute6                );
csd_gen_utility_pvt.add('attribute7         	:'||l_rec.attribute7                );
csd_gen_utility_pvt.add('attribute8         	:'||l_rec.attribute8                );
csd_gen_utility_pvt.add('attribute9         	:'||l_rec.attribute9                );
csd_gen_utility_pvt.add('attribute10        	:'||l_rec.attribute10               );
csd_gen_utility_pvt.add('attribute11        	:'||l_rec.attribute11               );
csd_gen_utility_pvt.add('attribute12        	:'||l_rec.attribute12               );
csd_gen_utility_pvt.add('attribute13        	:'||l_rec.attribute13               );
csd_gen_utility_pvt.add('attribute14        	:'||l_rec.attribute14               );
csd_gen_utility_pvt.add('attribute15        	:'||l_rec.attribute15               );

END dump_ro_diagnostic_code_rec;

PROCEDURE dump_service_code_rec (
      p_service_code_rec IN  CSD_SERVICE_CODES_PVT.service_code_rec_type
) IS
    l_rec csd_service_codes_pvt.service_code_rec_type := p_service_code_rec;

BEGIN

csd_gen_utility_pvt.add('service_code _id    :'||l_rec.service_code_id           );
csd_gen_utility_pvt.add('object_version_number :'||l_rec.object_version_number   );
csd_gen_utility_pvt.add('service_code        :'||l_rec.service_code              );
csd_gen_utility_pvt.add('description         :'||l_rec.description               );
csd_gen_utility_pvt.add('active_from         :'||l_rec.active_from               );
csd_gen_utility_pvt.add('active_to           :'||l_rec.active_to                 );
csd_gen_utility_pvt.add('attribute_category  :'||l_rec.attribute_category        );
csd_gen_utility_pvt.add('attribute1          :'||l_rec.attribute1                );
csd_gen_utility_pvt.add('attribute2          :'||l_rec.attribute2                );
csd_gen_utility_pvt.add('attribute3          :'||l_rec.attribute3                );
csd_gen_utility_pvt.add('attribute4          :'||l_rec.attribute4                );
csd_gen_utility_pvt.add('attribute5          :'||l_rec.attribute5                );
csd_gen_utility_pvt.add('attribute6          :'||l_rec.attribute6                );
csd_gen_utility_pvt.add('attribute7          :'||l_rec.attribute7                );
csd_gen_utility_pvt.add('attribute8          :'||l_rec.attribute8                );
csd_gen_utility_pvt.add('attribute9          :'||l_rec.attribute9                );
csd_gen_utility_pvt.add('attribute10         :'||l_rec.attribute10               );
csd_gen_utility_pvt.add('attribute11         :'||l_rec.attribute11               );
csd_gen_utility_pvt.add('attribute12         :'||l_rec.attribute12               );
csd_gen_utility_pvt.add('attribute13         :'||l_rec.attribute13               );
csd_gen_utility_pvt.add('attribute14         :'||l_rec.attribute14               );
csd_gen_utility_pvt.add('attribute15         :'||l_rec.attribute15               );

END dump_service_code_rec;

PROCEDURE dump_sc_domain_rec (
      p_sc_domain_rec IN  CSD_SC_DOMAINS_PVT.sc_domain_rec_type
) IS
    l_rec csd_sc_domains_pvt.sc_domain_rec_type := p_sc_domain_rec;

BEGIN

csd_gen_utility_pvt.add('sc_domain _id       :'||l_rec.sc_domain_id              );
csd_gen_utility_pvt.add('object_version_number :'||l_rec.object_version_number   );
csd_gen_utility_pvt.add('service_code_id     :'||l_rec.service_code_id           );
csd_gen_utility_pvt.add('inventory_item_id   :'||l_rec.inventory_item_id         );
csd_gen_utility_pvt.add('category_id         :'||l_rec.category_id               );
csd_gen_utility_pvt.add('category_set_id     :'||l_rec.category_set_id           );
csd_gen_utility_pvt.add('domain_type_code    :'||l_rec.domain_type_code          );
csd_gen_utility_pvt.add('attribute_category  :'||l_rec.attribute_category        );
csd_gen_utility_pvt.add('attribute1          :'||l_rec.attribute1                );
csd_gen_utility_pvt.add('attribute2          :'||l_rec.attribute2                );
csd_gen_utility_pvt.add('attribute3          :'||l_rec.attribute3                );
csd_gen_utility_pvt.add('attribute4          :'||l_rec.attribute4                );
csd_gen_utility_pvt.add('attribute5          :'||l_rec.attribute5                );
csd_gen_utility_pvt.add('attribute6          :'||l_rec.attribute6                );
csd_gen_utility_pvt.add('attribute7          :'||l_rec.attribute7                );
csd_gen_utility_pvt.add('attribute8          :'||l_rec.attribute8                );
csd_gen_utility_pvt.add('attribute9          :'||l_rec.attribute9                );
csd_gen_utility_pvt.add('attribute10         :'||l_rec.attribute10               );
csd_gen_utility_pvt.add('attribute11         :'||l_rec.attribute11               );
csd_gen_utility_pvt.add('attribute12         :'||l_rec.attribute12               );
csd_gen_utility_pvt.add('attribute13         :'||l_rec.attribute13               );
csd_gen_utility_pvt.add('attribute14         :'||l_rec.attribute14               );
csd_gen_utility_pvt.add('attribute15         :'||l_rec.attribute15               );

END dump_sc_domain_rec;


PROCEDURE dump_sc_work_entity_rec (
      p_sc_work_entity_rec      IN  CSD_SC_WORK_ENTITIES_PVT.sc_work_entity_rec_type
) IS
    l_rec csd_sc_work_entities_pvt.sc_work_entity_rec_type := p_sc_work_entity_rec;

BEGIN

csd_gen_utility_pvt.add('sc_work_entity_id      :'||l_rec.sc_work_entity_id         );
csd_gen_utility_pvt.add('object_version_number  :'||l_rec.object_version_number     );
csd_gen_utility_pvt.add('service_code_id   	:'||l_rec.service_code_id           );
csd_gen_utility_pvt.add('work_entity_id1   	:'||l_rec.work_entity_id1           );
csd_gen_utility_pvt.add('work_entity_type_code  :'||l_rec.work_entity_type_code     );
csd_gen_utility_pvt.add('work_entity_id2        :'||l_rec.work_entity_id2           );
csd_gen_utility_pvt.add('work_entity_id3     	:'||l_rec.work_entity_id3           );
csd_gen_utility_pvt.add('attribute_category  	:'||l_rec.attribute_category        );
csd_gen_utility_pvt.add('attribute1          	:'||l_rec.attribute1                );
csd_gen_utility_pvt.add('attribute2         	:'||l_rec.attribute2                );
csd_gen_utility_pvt.add('attribute3         	:'||l_rec.attribute3                );
csd_gen_utility_pvt.add('attribute4         	:'||l_rec.attribute4                );
csd_gen_utility_pvt.add('attribute5         	:'||l_rec.attribute5                );
csd_gen_utility_pvt.add('attribute6         	:'||l_rec.attribute6                );
csd_gen_utility_pvt.add('attribute7         	:'||l_rec.attribute7                );
csd_gen_utility_pvt.add('attribute8         	:'||l_rec.attribute8                );
csd_gen_utility_pvt.add('attribute9         	:'||l_rec.attribute9                );
csd_gen_utility_pvt.add('attribute10        	:'||l_rec.attribute10               );
csd_gen_utility_pvt.add('attribute11        	:'||l_rec.attribute11               );
csd_gen_utility_pvt.add('attribute12        	:'||l_rec.attribute12               );
csd_gen_utility_pvt.add('attribute13        	:'||l_rec.attribute13               );
csd_gen_utility_pvt.add('attribute14        	:'||l_rec.attribute14               );
csd_gen_utility_pvt.add('attribute15        	:'||l_rec.attribute15               );

END dump_sc_work_entity_rec;

PROCEDURE dump_ro_service_code_rec (
      p_ro_service_code_rec      IN  CSD_RO_SERVICE_CODES_PVT.ro_service_code_rec_type
) IS
    l_rec csd_ro_service_codes_pvt.ro_service_code_rec_type := p_ro_service_code_rec;

BEGIN

csd_gen_utility_pvt.add('ro_service_code_id     :'||l_rec.ro_service_code_id        );
csd_gen_utility_pvt.add('object_version_number  :'||l_rec.object_version_number     );
csd_gen_utility_pvt.add('repair_line_id   	:'||l_rec.repair_line_id            );
csd_gen_utility_pvt.add('service_code_id   	:'||l_rec.service_code_id           );
csd_gen_utility_pvt.add('source_type_code       :'||l_rec.source_type_code          );
csd_gen_utility_pvt.add('source_solution_id     :'||l_rec.source_solution_id        );
csd_gen_utility_pvt.add('applicable_flag     	:'||l_rec.applicable_flag           );
csd_gen_utility_pvt.add('attribute_category  	:'||l_rec.attribute_category        );
csd_gen_utility_pvt.add('attribute1          	:'||l_rec.attribute1                );
csd_gen_utility_pvt.add('attribute2         	:'||l_rec.attribute2                );
csd_gen_utility_pvt.add('attribute3         	:'||l_rec.attribute3                );
csd_gen_utility_pvt.add('attribute4         	:'||l_rec.attribute4                );
csd_gen_utility_pvt.add('attribute5         	:'||l_rec.attribute5                );
csd_gen_utility_pvt.add('attribute6         	:'||l_rec.attribute6                );
csd_gen_utility_pvt.add('attribute7         	:'||l_rec.attribute7                );
csd_gen_utility_pvt.add('attribute8         	:'||l_rec.attribute8                );
csd_gen_utility_pvt.add('attribute9         	:'||l_rec.attribute9                );
csd_gen_utility_pvt.add('attribute10        	:'||l_rec.attribute10               );
csd_gen_utility_pvt.add('attribute11        	:'||l_rec.attribute11               );
csd_gen_utility_pvt.add('attribute12        	:'||l_rec.attribute12               );
csd_gen_utility_pvt.add('attribute13        	:'||l_rec.attribute13               );
csd_gen_utility_pvt.add('attribute14        	:'||l_rec.attribute14               );
csd_gen_utility_pvt.add('attribute15        	:'||l_rec.attribute15               );

END dump_ro_service_code_rec;


PROCEDURE dump_repair_estimate_line_tbl (
  p_repair_estimate_line_tbl      IN  CSD_REPAIR_ESTIMATE_PVT.repair_estimate_line_tbl
) IS
    l_tbl CSD_REPAIR_ESTIMATE_PVT.repair_estimate_line_tbl := p_repair_estimate_line_tbl;
BEGIN
  IF l_tbl.count > 0 THEN
    csd_gen_utility_pvt.add('repair_estimate_line_tbl count :'||l_tbl.count);
    FOR i IN l_tbl.first..l_tbl.last LOOP
      IF l_tbl.exists(i) THEN
          csd_gen_utility_pvt.add('repair_estimate_line_tbl('||to_char(i)||'):');
          dump_estimate_line_rec(l_tbl(i));
      END IF;
    END LOOP;
  END IF;
END dump_repair_estimate_line_tbl;


PROCEDURE dump_mle_lines_rec_type (
  p_mle_lines_rec      IN  CSD_REPAIR_ESTIMATE_PVT.mle_lines_rec_type
) IS
    l_rec CSD_REPAIR_ESTIMATE_PVT.mle_lines_rec_type := p_mle_lines_rec;
BEGIN
    csd_gen_utility_pvt.add('   inventory_item_id         :'||l_rec.inventory_item_id);
    csd_gen_utility_pvt.add('   uom                       :'||l_rec.uom);
    csd_gen_utility_pvt.add('   quantity                  :'||l_rec.quantity);
    csd_gen_utility_pvt.add('   selling_price             :'||l_rec.selling_price);
    csd_gen_utility_pvt.add('   item_name                 :'||l_rec.item_name);
    csd_gen_utility_pvt.add('   comms_nl_trackable_flag   :'||l_rec.comms_nl_trackable_flag);
    csd_gen_utility_pvt.add('   txn_billing_type_id       :'||l_rec.txn_billing_type_id);
    csd_gen_utility_pvt.add('   est_line_source_type_code :'||l_rec.est_line_source_type_code);
    csd_gen_utility_pvt.add('   est_line_source_id1       :'||l_rec.est_line_source_id1);
    csd_gen_utility_pvt.add('   est_line_source_id2       :'||l_rec.est_line_source_id2);
    csd_gen_utility_pvt.add('   ro_service_code_id        :'||l_rec.ro_service_code_id);
END dump_mle_lines_rec_type;

PROCEDURE dump_mle_lines_tbl_type (
  p_mle_lines_tbl      IN  CSD_REPAIR_ESTIMATE_PVT.mle_lines_tbl_type
) IS
    l_tbl CSD_REPAIR_ESTIMATE_PVT.mle_lines_tbl_type := p_mle_lines_tbl;
BEGIN
  IF l_tbl.count > 0 THEN
    csd_gen_utility_pvt.add('mle_lines_tbl count :'||l_tbl.count);
    FOR i IN l_tbl.first..l_tbl.last LOOP
      IF l_tbl.exists(i) THEN
        csd_gen_utility_pvt.add('mle_lines_tbl('||to_char(i)||'):');
        dump_mle_lines_rec_type(l_tbl(i));
      END IF;
    END LOOP;
  END IF;
END dump_mle_lines_tbl_type;

Function G_CURRENT_RUNTIME_LEVEL Return Number IS
   Begin
      Return Fnd_Log.G_Current_Runtime_Level ;
   End ;
END csd_gen_utility_pvt;

/
