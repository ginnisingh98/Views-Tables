--------------------------------------------------------
--  DDL for Package Body CSI_T_GEN_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_GEN_UTILITY_PVT" AS
/* $Header: csivtgub.pls 120.7.12010000.2 2008/11/06 20:34:13 mashah ship $*/

  PROCEDURE build_file_name(
    p_file_segment1  IN varchar2,
    p_file_segment2  IN varchar2,
    p_file_segment3  IN varchar2 )
  IS
  BEGIN

   csi_t_gen_utility_pvt.set_debug_off;

   csi_t_gen_utility_pvt.g_file :=
     p_file_segment1||'.'||p_file_segment2||'.dbg';

  END build_file_name;

  PROCEDURE set_debug_on IS
    l_audsid number;
  BEGIN
    IF csi_t_gen_utility_pvt.g_debug = fnd_api.g_false THEN
      IF csi_t_gen_utility_pvt.g_file is null then
        select userenv('SESSIONID') into l_audsid from sys.dual;
        build_file_name(
          p_file_segment1 => 'csi',
          p_file_segment2 => l_audsid);
        csi_t_gen_utility_pvt.g_file_ptr := utl_file.fopen(G_DIR, G_FILE, 'a');
      ELSE
        csi_t_gen_utility_pvt.g_file_ptr := utl_file.fopen(G_DIR, G_FILE, 'a');
      END IF;
      csi_t_gen_utility_pvt.g_debug    := fnd_api.g_true;
    END IF;
  EXCEPTION
    WHEN others then
      null;
  END set_debug_on;

  PROCEDURE set_debug_off IS
  BEGIN

    IF csi_t_gen_utility_pvt.is_debug_on THEN
      utl_file.fclose(csi_t_gen_utility_pvt.g_file_ptr);
      csi_t_gen_utility_pvt.g_debug := fnd_api.g_false;
    END IF;

  END set_debug_off;

  FUNCTION is_debug_on RETURN boolean
  IS
  BEGIN
    IF csi_t_gen_utility_pvt.g_debug = fnd_api.g_true THEN
      return TRUE;
    ELSE
      return FALSE;
    END IF;
  END is_debug_on;


  PROCEDURE add(
    p_debug_msg in varchar2)
  IS
  BEGIN

    IF csi_t_gen_utility_pvt.g_debug_level > 0 THEN
      set_debug_on;
      IF is_debug_on THEN
        utl_file.put_line(g_file_ptr, p_debug_msg);
        utl_file.fflush(g_file_ptr);
      END IF;
      set_debug_off;
    END IF;

  EXCEPTION
    WHEN others THEN
      null;
  END add;

  /* */
  PROCEDURE dump_api_info(
    p_pkg_name  IN varchar2,
    p_api_name  IN varchar2,
    p_indent    IN number )
  IS
    l_out  varchar2(512);
  BEGIN
    l_out := 'Inside API :'||p_pkg_name||'.'||p_api_name;
    l_out := lpad(l_out, length(l_out)+p_indent, ' ');
    add(l_out);
  END dump_api_info;


  /* */
  PROCEDURE dump_error_stack
  IS
    l_msg_count     number;
    l_msg_data      varchar2(2000);
    l_msg_index_out number;
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

      add('Error: '||l_msg_data);

    END LOOP;

  END dump_error_stack;

  /* */
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
    when others then
      add('Error in dump_error_stack:'||sqlerrm);
      RETURN x_msg_data;
  END dump_error_stack;

  PROCEDURE dump_txn_systems_rec (
    p_txn_systems_rec in csi_t_datastructures_grp.txn_system_rec)
  is
    l_rec csi_t_datastructures_grp.txn_system_rec;
  begin
    l_rec := p_txn_systems_rec;

    add('txn_system_rec');
    add('  transaction_system_id    :'|| l_rec.transaction_system_id );
    add('  transaction_line_id      :'|| l_rec.transaction_line_id );

    IF g_debug_level > 10 THEN
      add('  customer_id              :'|| l_rec.customer_id );
      add('  bill_to_contact_id       :'|| l_rec.bill_to_contact_id );
      add('  ship_to_contact_id       :'|| l_rec.ship_to_contact_id );
      add('  system_name              :'|| l_rec.system_name );
      add('  description              :'|| l_rec.description );
      add('  system_type_code         :'|| l_rec.system_type_code );
      add('  system_number            :'|| l_rec.system_number );
      add('  technical_contact_id     :'|| l_rec.technical_contact_id );
      add('  service_admin_contact_id :'|| l_rec.service_admin_contact_id );
      add('  ship_to_site_use_id      :'|| l_rec.ship_to_site_use_id );
      add('  bill_to_site_use_id      :'|| l_rec.bill_to_site_use_id );
      add('  install_site_use_id      :'|| l_rec.install_site_use_id );
      add('  coterminate_day_month    :'|| l_rec.coterminate_day_month );
      add('  config_system_type       :'|| l_rec.config_system_type );
    END IF;

    IF g_debug_level > 25 THEN
      add('  context                  :'|| l_rec.context );
      add('  attribute1               :'|| l_rec.attribute1 );
      add('  attribute2               :'|| l_rec.attribute2 );
      add('  attribute3               :'|| l_rec.attribute3 );
      add('  attribute4               :'|| l_rec.attribute4 );
      add('  attribute5               :'|| l_rec.attribute5 );
      add('  attribute6               :'|| l_rec.attribute6 );
      add('  attribute7               :'|| l_rec.attribute7 );
      add('  attribute8               :'|| l_rec.attribute8 );
      add('  attribute9               :'|| l_rec.attribute9 );
      add('  attribute10              :'|| l_rec.attribute10 );
      add('  attribute11              :'|| l_rec.attribute11 );
      add('  attribute12              :'|| l_rec.attribute12 );
      add('  attribute13              :'|| l_rec.attribute13 );
      add('  attribute14              :'|| l_rec.attribute14 );
      add('  attribute15              :'|| l_rec.attribute15 );
      add('  object_version_number    :'|| l_rec.object_version_number );
    END IF;
  END dump_txn_systems_rec;

  PROCEDURE dump_txn_line_rec(
    p_txn_line_rec in csi_t_datastructures_grp.txn_line_rec)
  IS
    l_rec csi_t_datastructures_grp.txn_line_rec;
  BEGIN

    l_rec := p_txn_line_rec;

    add('txn_line_rec :');
    add('  transaction_line_id      :'||l_rec.transaction_line_id );
    add('  src_transaction_type_id  :'||l_rec.source_transaction_type_id );
    add('  src_transaction_table    :'||l_rec.source_transaction_table );
    add('  src_transaction_id       :'||l_rec.source_transaction_id );
    add('  processing_status        :'||l_rec.processing_status );

    IF g_debug_level > 10 THEN
      add('  src_transaction_hdr_id   :'||l_rec.source_txn_header_id );
      add('  inv_material_txn_flag    :'||l_rec.inv_material_txn_flag );
      add('  error_code               :'||l_rec.error_code );
      add('  error_explanation        :'||l_rec.error_explanation );
      add('  api_caller_identity      :'||l_rec.api_caller_identity);
      add('  config_session_hdr_id    :'||l_rec.config_session_hdr_id);
      add('  config_session_rev_num   :'||l_rec.config_session_rev_num);
      add('  config_session_item_id   :'||l_rec.config_session_item_id);
    END IF;

    IF g_debug_level > 25 then
      add('  context                  :'|| l_rec.context );
      add('  attribute1               :'|| l_rec.attribute1 );
      add('  attribute2               :'|| l_rec.attribute2 );
      add('  attribute3               :'|| l_rec.attribute3 );
      add('  attribute4               :'|| l_rec.attribute4 );
      add('  attribute5               :'|| l_rec.attribute5 );
      add('  attribute6               :'|| l_rec.attribute6 );
      add('  attribute7               :'|| l_rec.attribute7 );
      add('  attribute8               :'|| l_rec.attribute8 );
      add('  attribute9               :'|| l_rec.attribute9 );
      add('  attribute10              :'|| l_rec.attribute10 );
      add('  attribute11              :'|| l_rec.attribute11 );
      add('  attribute12              :'|| l_rec.attribute12 );
      add('  attribute13              :'|| l_rec.attribute13 );
      add('  attribute14              :'|| l_rec.attribute14 );
      add('  attribute15              :'|| l_rec.attribute15 );
      add('  object_version_number    :'|| l_rec.object_version_number );
    END IF;

  END dump_txn_line_rec;

  PROCEDURE dump_line_detail_rec(
    p_line_detail_rec in csi_t_datastructures_grp.txn_line_detail_rec)
  is
    l_rec csi_t_datastructures_grp.txn_line_detail_rec;
  begin

    l_rec := p_line_detail_rec ;

    add('txn_line_detail_rec :');
    add('  txn_line_detail_id       :'|| l_rec.txn_line_detail_id );
    add('  transaction_line_id      :'|| l_rec.transaction_line_id );
    add('  source_transaction_flag  :'|| l_rec.source_transaction_flag );
    add('  sub_type_id              :'|| l_rec.sub_type_id );

    IF g_debug_level > 5 then
      add('  inv_organization_id      :'|| l_rec.inv_organization_id );
      add('  inventory_item_id        :'|| l_rec.inventory_item_id );
      add('  inventory_revision       :'|| l_rec.inventory_revision );
      add('  mfg_serial_number_flag   :'|| l_rec.mfg_serial_number_flag );
      add('  serial_number            :'|| l_rec.serial_number );
      add('  lot_number               :'|| l_rec.lot_number );
      add('  quantity                 :'|| l_rec.quantity );
      add('  unit_of_measure          :'|| l_rec.unit_of_measure );
      add('  instance_exists_flag     :'|| l_rec.instance_exists_flag );
      add('  instance_id              :'|| l_rec.instance_id );
      add('  location_type_code       :'|| l_rec.location_type_code );
      add('  location_id              :'|| l_rec.location_id );
      add('  changed_instance_id      :'|| l_rec.changed_instance_id );
      add('  csi_system_id            :'|| l_rec.csi_system_id );
      add('  csi_transaction_id       :'|| l_rec.csi_transaction_id );
      add('  active_start_date        :'|| l_rec.active_start_date );
      add('  active_end_date          :'|| l_rec.active_end_date );
      add('  processing_status        :'|| l_rec.processing_status );
      add('  cascade_owner_flag       :'|| l_rec.cascade_owner_flag );
      add('  instance_status_id       :'|| l_rec.instance_status_id );
      add('  preserve_detail_flag     :'|| l_rec.preserve_detail_flag );
    END IF;

    IF g_debug_level > 10 then
      add('  preserve_detail_flag     :'|| l_rec.preserve_detail_flag );
      add('  item_condition_id        :'|| l_rec.item_condition_id );
      add('  instance_type_code       :'|| l_rec.instance_type_code );
      add('  qty_remaining            :'|| l_rec.qty_remaining );
      add('  installation_date        :'|| l_rec.installation_date );
      add('  in_service_date          :'|| l_rec.in_service_date );
      add('  external_reference       :'|| l_rec.external_reference );
      add('  transaction_system_id    :'|| l_rec.transaction_system_id );
      add('  sellable_flag            :'|| l_rec.sellable_flag );
      add('  version_label            :'|| l_rec.version_label );
      add('  return_by_date           :'|| l_rec.return_by_date );
      add('  reference_source_id      :'|| l_rec.reference_source_id );
      add('  reference_source_date    :'|| l_rec.reference_source_date );
      add('  object_version_number    :'|| l_rec.object_version_number );
      add('  inst_hdr_id              :'|| l_rec.config_inst_hdr_id );
      add('  inst_rev_num             :'|| l_rec.config_inst_rev_num );
      add('  inst_item_id             :'|| l_rec.config_inst_item_id );
      add('  inst_baseline_rev_num    :'|| l_rec.config_inst_baseline_rev_num );
    END IF;

    IF g_debug_level > 25 then
      add('  context                  :'|| l_rec.context );
      add('  attribute1               :'|| l_rec.attribute1 );
      add('  attribute2               :'|| l_rec.attribute2 );
      add('  attribute3               :'|| l_rec.attribute3 );
      add('  attribute4               :'|| l_rec.attribute4 );
      add('  attribute5               :'|| l_rec.attribute5 );
      add('  attribute6               :'|| l_rec.attribute6 );
      add('  attribute7               :'|| l_rec.attribute7 );
      add('  attribute8               :'|| l_rec.attribute8 );
      add('  attribute9               :'|| l_rec.attribute9 );
      add('  attribute10              :'|| l_rec.attribute10 );
      add('  attribute11              :'|| l_rec.attribute11 );
      add('  attribute12              :'|| l_rec.attribute12 );
      add('  attribute13              :'|| l_rec.attribute13 );
      add('  attribute14              :'|| l_rec.attribute14 );
      add('  attribute15              :'|| l_rec.attribute15 );
    END IF;

  END dump_line_detail_rec;

  PROCEDURE dump_party_detail_rec(
    p_party_detail_rec in csi_t_datastructures_grp.txn_party_detail_rec )
  is
    l_rec csi_t_datastructures_grp.txn_party_detail_rec;
  begin

    l_rec := p_party_detail_rec;

    add('txn_party_detail_rec :');
    add('  txn_line_details_index   :'|| l_rec.txn_line_details_index );
    add('  txn_party_detail_id      :'|| l_rec.txn_party_detail_id );
    add('  txn_line_detail_id       :'|| l_rec.txn_line_detail_id );
    add('  txn_contact_party_index  :'|| l_rec.txn_contact_party_index );

    IF g_debug_level > 5 then
      add('  party_source_table       :'|| l_rec.party_source_table );
      add('  party_source_id          :'|| l_rec.party_source_id );
      add('  relationship_type_code   :'|| l_rec.relationship_type_code );
      add('  instance_party_id        :'|| l_rec.instance_party_id );
      add('  contact_flag             :'|| l_rec.contact_flag );
      add('  contact_party_id         :'|| l_rec.contact_party_id );
      add('  primary_flag             :'|| l_rec.primary_flag );
      add('  preferred_flag           :'|| l_rec.preferred_flag );
      add('  active_start_date        :'|| l_rec.active_start_date );
      add('  active_end_date          :'|| l_rec.active_end_date );
    END IF;

    IF g_debug_level >= 10 then
      add('  preserve_detail_flag     :'|| l_rec.preserve_detail_flag );
      add('  object_version_number    :'|| l_rec.object_version_number );
    END IF;

    IF g_debug_level > 25 then
      add('  context                  :'|| l_rec.context );
      add('  attribute1               :'|| l_rec.attribute1 );
      add('  attribute2               :'|| l_rec.attribute2 );
      add('  attribute3               :'|| l_rec.attribute3 );
      add('  attribute4               :'|| l_rec.attribute4 );
      add('  attribute5               :'|| l_rec.attribute5 );
      add('  attribute6               :'|| l_rec.attribute6 );
      add('  attribute7               :'|| l_rec.attribute7 );
      add('  attribute8               :'|| l_rec.attribute8 );
      add('  attribute9               :'|| l_rec.attribute9 );
      add('  attribute10              :'|| l_rec.attribute10 );
      add('  attribute11              :'|| l_rec.attribute11 );
      add('  attribute12              :'|| l_rec.attribute12 );
      add('  attribute13              :'|| l_rec.attribute13 );
      add('  attribute14              :'|| l_rec.attribute14 );
      add('  attribute15              :'|| l_rec.attribute15 );
    END IF;

  END dump_party_detail_rec;

  PROCEDURE dump_pty_acct_rec(
    p_pty_acct_rec in csi_t_datastructures_grp.txn_pty_acct_detail_rec)
  IS
   l_rec csi_t_datastructures_grp.txn_pty_acct_detail_rec;
  begin

    l_rec := p_pty_acct_rec;

    add('txn_pty_acct_detail_rec :');
    add('  txn_party_details_index  :'|| l_rec.txn_party_details_index );
    add('  txn_account_detail_id    :'|| l_rec.txn_account_detail_id );
    add('  txn_party_detail_id      :'|| l_rec.txn_party_detail_id );

    IF g_debug_level > 5 THEN
      add('  ip_account_id            :'|| l_rec.ip_account_id );
      add('  account_id               :'|| l_rec.account_id );
      add('  relationship_type_code   :'|| l_rec.relationship_type_code );
      add('  bill_to_address_id       :'|| l_rec.bill_to_address_id );
      add('  ship_to_address_id       :'|| l_rec.ship_to_address_id );
      add('  preserve_detail_flag     :'|| l_rec.preserve_detail_flag );
      add('  active_start_date        :'|| l_rec.active_start_date );
      add('  active_end_date          :'|| l_rec.active_end_date );
    END IF;

    IF g_debug_level > 10 THEN
      add('  object_version_number    :'|| l_rec.object_version_number );
    END IF;

    IF g_debug_level > 25 THEN
      add('  context                  :'|| l_rec.context );
      add('  attribute1               :'|| l_rec.attribute1 );
      add('  attribute2               :'|| l_rec.attribute2 );
      add('  attribute3               :'|| l_rec.attribute3 );
      add('  attribute4               :'|| l_rec.attribute4 );
      add('  attribute5               :'|| l_rec.attribute5 );
      add('  attribute6               :'|| l_rec.attribute6 );
      add('  attribute7               :'|| l_rec.attribute7 );
      add('  attribute8               :'|| l_rec.attribute8 );
      add('  attribute9               :'|| l_rec.attribute9 );
      add('  attribute10              :'|| l_rec.attribute10 );
      add('  attribute11              :'|| l_rec.attribute11 );
      add('  attribute12              :'|| l_rec.attribute12 );
      add('  attribute13              :'|| l_rec.attribute13 );
      add('  attribute14              :'|| l_rec.attribute14 );
      add('  attribute15              :'|| l_rec.attribute15 );
    END IF;

  END dump_pty_acct_rec;

  PROCEDURE dump_ii_rltns_rec(
    p_ii_rltns_rec in csi_t_datastructures_grp.txn_ii_rltns_rec)
  is
    l_rec csi_t_datastructures_grp.txn_ii_rltns_rec;
  begin
    l_rec := p_ii_rltns_rec;

    add('txn_ii_rltns_rec :');
    add('  txn_relationship_id      :'|| l_rec.txn_relationship_id );
    add('  transaction_line_id      :'|| l_rec.transaction_line_id );

    IF g_debug_level > 5 THEN

      add('  subject_index_flag       :'|| l_rec.subject_index_flag );
      add('  subject_type             :'|| l_rec.subject_type );
      add('  subject_id               :'|| l_rec.subject_id );
      add('  relationship_type_code   :'|| l_rec.relationship_type_code );
      add('  object_index_flag        :'|| l_rec.object_index_flag );
      add('  object_type              :'|| l_rec.object_type );
      add('  object_id                :'|| l_rec.object_id );
      add('  csi_inst_relationship_id :'|| l_rec.csi_inst_relationship_id );
      add('  active_start_date        :'|| l_rec.active_start_date );
      add('  active_end_date          :'|| l_rec.active_end_date );

    END IF;

    IF g_debug_level > 10 THEN
      add('  sub_config_inst_hdr_id   :'|| l_rec.sub_config_inst_hdr_id );
      add('  sub_config_inst_rev_num  :'|| l_rec.sub_config_inst_rev_num );
      add('  sub_config_inst_item_id  :'|| l_rec.sub_config_inst_item_id );
      add('  obj_config_inst_hdr_id   :'|| l_rec.obj_config_inst_hdr_id );
      add('  obj_config_inst_rev_num  :'|| l_rec.obj_config_inst_rev_num );
      add('  obj_config_inst_item_id  :'|| l_rec.obj_config_inst_item_id );
      add('  target_commitment_date   :'|| l_rec.target_commitment_date );
      add('  api_caller_identity      :'|| l_rec.api_caller_identity );
      add('  display_order            :'|| l_rec.display_order );
      add('  position_reference       :'|| l_rec.position_reference );
      add('  mandatory_flag           :'|| l_rec.mandatory_flag );
      add('  object_version_number    :'|| l_rec.object_version_number );
    END IF;

    IF g_debug_level > 25 THEN
      add('  context                  :'|| l_rec.context );
      add('  attribute1               :'|| l_rec.attribute1 );
      add('  attribute2               :'|| l_rec.attribute2 );
      add('  attribute3               :'|| l_rec.attribute3 );
      add('  attribute4               :'|| l_rec.attribute4 );
      add('  attribute5               :'|| l_rec.attribute5 );
      add('  attribute6               :'|| l_rec.attribute6 );
      add('  attribute7               :'|| l_rec.attribute7 );
      add('  attribute8               :'|| l_rec.attribute8 );
      add('  attribute9               :'|| l_rec.attribute9 );
      add('  attribute10              :'|| l_rec.attribute10 );
      add('  attribute11              :'|| l_rec.attribute11 );
      add('  attribute12              :'|| l_rec.attribute12 );
      add('  attribute13              :'|| l_rec.attribute13 );
      add('  attribute14              :'|| l_rec.attribute14 );
      add('  attribute15              :'|| l_rec.attribute15 );
    END IF;

  END dump_ii_rltns_rec;

  PROCEDURE dump_org_assgn_rec(
    p_org_assgn_rec in csi_t_datastructures_grp.txn_org_assgn_rec)
  is
    l_rec csi_t_datastructures_grp.txn_org_assgn_rec;
  begin

    l_rec := p_org_assgn_rec;

    add('txn_org_assgn_rec :');
    add('  txn_line_details_index   :'|| l_rec.txn_line_details_index );
    add('  txn_operating_unit_id    :'|| l_rec.txn_operating_unit_id );
    add('  txn_line_detail_id       :'|| l_rec.txn_line_detail_id );

    IF g_debug_level > 5 then
      add('  operating_unit_id        :'|| l_rec.operating_unit_id );
      add('  relationship_type_code   :'|| l_rec.relationship_type_code );
      add('  active_start_date        :'|| l_rec.active_start_date );
      add('  active_end_date          :'|| l_rec.active_end_date );
    END IF;

    IF g_debug_level > 10 then
      add('  instance_ou_id           :'|| l_rec.instance_ou_id );
      add('  preserve_detail_flag     :'|| l_rec.preserve_detail_flag );
      add('  object_version_number    :'|| l_rec.object_version_number );
    END IF;

    IF g_debug_level > 25 then
      add('  context                  :'|| l_rec.context );
      add('  attribute1               :'|| l_rec.attribute1 );
      add('  attribute2               :'|| l_rec.attribute2 );
      add('  attribute3               :'|| l_rec.attribute3 );
      add('  attribute4               :'|| l_rec.attribute4 );
      add('  attribute5               :'|| l_rec.attribute5 );
      add('  attribute6               :'|| l_rec.attribute6 );
      add('  attribute7               :'|| l_rec.attribute7 );
      add('  attribute8               :'|| l_rec.attribute8 );
      add('  attribute9               :'|| l_rec.attribute9 );
      add('  attribute10              :'|| l_rec.attribute10 );
      add('  attribute11              :'|| l_rec.attribute11 );
      add('  attribute12              :'|| l_rec.attribute12 );
      add('  attribute13              :'|| l_rec.attribute13 );
      add('  attribute14              :'|| l_rec.attribute14 );
      add('  attribute15              :'|| l_rec.attribute15 );
    END IF;

  END dump_org_assgn_rec;

  PROCEDURE dump_txn_eav_rec(
    p_txn_eav_rec in csi_t_datastructures_grp.txn_ext_attrib_vals_rec)
  is
   l_rec csi_t_datastructures_grp.txn_ext_attrib_vals_rec;
  begin

    l_rec := p_txn_eav_rec;

    add('txn_ext_attrib_vals_rec :');
    add('  txn_line_details_index   :'|| l_rec.txn_line_details_index );
    add('  txn_attrib_detail_id     :'|| l_rec.txn_attrib_detail_id );
    add('  txn_line_detail_id       :'|| l_rec.txn_line_detail_id );

    IF g_debug_level > 5 then
      add('  attrib_source_table      :'|| l_rec.attrib_source_table );
      add('  attribute_source_id      :'|| l_rec.attribute_source_id );
      add('  attribute_code           :'|| l_rec.attribute_code );
      add('  attribute_level          :'|| l_rec.attribute_level );
      add('  attribute_value          :'|| l_rec.attribute_value );
      add('  active_start_date        :'|| l_rec.active_start_date );
      add('  active_end_date          :'|| l_rec.active_end_date );
    END IF;

    IF g_debug_level > 10 then
      add('  preserve_detail_flag     :'|| l_rec.preserve_detail_flag );
      add('  object_version_number    :'|| l_rec.object_version_number );
      add('  process_flag             :'|| l_rec.process_flag );
    END IF;

    IF g_debug_level > 25 then
      add('  context                  :'|| l_rec.context );
      add('  attribute1               :'|| l_rec.attribute1 );
      add('  attribute2               :'|| l_rec.attribute2 );
      add('  attribute3               :'|| l_rec.attribute3 );
      add('  attribute4               :'|| l_rec.attribute4 );
      add('  attribute5               :'|| l_rec.attribute5 );
      add('  attribute6               :'|| l_rec.attribute6 );
      add('  attribute7               :'|| l_rec.attribute7 );
      add('  attribute8               :'|| l_rec.attribute8 );
      add('  attribute9               :'|| l_rec.attribute9 );
      add('  attribute10              :'|| l_rec.attribute10 );
      add('  attribute11              :'|| l_rec.attribute11 );
      add('  attribute12              :'|| l_rec.attribute12 );
      add('  attribute13              :'|| l_rec.attribute13 );
      add('  attribute14              :'|| l_rec.attribute14 );
      add('  attribute15              :'|| l_rec.attribute15 );
    END IF;
  END dump_txn_eav_rec;

  PROCEDURE dump_csi_ea_rec(
    p_csi_ea_rec in csi_t_datastructures_grp.csi_ext_attribs_rec)
  is
   l_rec csi_t_datastructures_grp.csi_ext_attribs_rec;
  begin

    l_rec := p_csi_ea_rec;

    add('csi_ext_attribs_rec :');
    add('  attribute_id             :'|| l_rec.attribute_id );
    add('  attribute_level          :'|| l_rec.attribute_level );

    IF g_debug_level > 5 THEN
      add('  master_organization_id   :'|| l_rec.master_organization_id );
      add('  inventory_item_id        :'|| l_rec.inventory_item_id );
      add('  item_category_id         :'|| l_rec.item_category_id );
      add('  instance_id              :'|| l_rec.instance_id );
      add('  attribute_code           :'|| l_rec.attribute_code );
      add('  attribute_name           :'|| l_rec.attribute_name );
      add('  attribute_category       :'|| l_rec.attribute_category );
      add('  description              :'|| l_rec.description );
      add('  active_start_date        :'|| l_rec.active_start_date );
      add('  active_end_date          :'|| l_rec.active_end_date );
      add('  object_version_number    :'|| l_rec.object_version_number );
    END IF;

    IF g_debug_level > 25 then
      add('  context                  :'|| l_rec.context );
      add('  attribute1               :'|| l_rec.attribute1 );
      add('  attribute2               :'|| l_rec.attribute2 );
      add('  attribute3               :'|| l_rec.attribute3 );
      add('  attribute4               :'|| l_rec.attribute4 );
      add('  attribute5               :'|| l_rec.attribute5 );
      add('  attribute6               :'|| l_rec.attribute6 );
      add('  attribute7               :'|| l_rec.attribute7 );
      add('  attribute8               :'|| l_rec.attribute8 );
      add('  attribute9               :'|| l_rec.attribute9 );
      add('  attribute10              :'|| l_rec.attribute10 );
      add('  attribute11              :'|| l_rec.attribute11 );
      add('  attribute12              :'|| l_rec.attribute12 );
      add('  attribute13              :'|| l_rec.attribute13 );
      add('  attribute14              :'|| l_rec.attribute14 );
      add('  attribute15              :'|| l_rec.attribute15 );
    END IF;

  END dump_csi_ea_rec;

  PROCEDURE dump_csi_eav_rec (
    p_csi_eav_rec in csi_t_datastructures_grp.csi_ext_attrib_vals_rec)
  IS
    l_rec csi_t_datastructures_grp.csi_ext_attrib_vals_rec;
  BEGIN

    l_rec := p_csi_eav_rec;

    add('csi_t_datastructures_grp.csi_ext_attrib_vals_rec :');
    add('  attribute_value_id       :'|| l_rec.attribute_value_id );
    add('  instance_id              :'|| l_rec.instance_id );
    add('  attribute_id             :'|| l_rec.attribute_id );
    add('  attribute_value          :'|| l_rec.attribute_value );

    IF g_debug_level > 5 then
      add('  active_start_date        :'|| l_rec.active_start_date );
      add('  active_end_date          :'|| l_rec.active_end_date );
      add('  object_version_number    :'|| l_rec.object_version_number );
    END IF;

    IF g_debug_level > 25 then
      add('  context                  :'|| l_rec.context );
      add('  attribute1               :'|| l_rec.attribute1 );
      add('  attribute2               :'|| l_rec.attribute2 );
      add('  attribute3               :'|| l_rec.attribute3 );
      add('  attribute4               :'|| l_rec.attribute4 );
      add('  attribute5               :'|| l_rec.attribute5 );
      add('  attribute6               :'|| l_rec.attribute6 );
      add('  attribute7               :'|| l_rec.attribute7 );
      add('  attribute8               :'|| l_rec.attribute8 );
      add('  attribute9               :'|| l_rec.attribute9 );
      add('  attribute10              :'|| l_rec.attribute10 );
      add('  attribute11              :'|| l_rec.attribute11 );
      add('  attribute12              :'|| l_rec.attribute12 );
      add('  attribute13              :'|| l_rec.attribute13 );
      add('  attribute14              :'|| l_rec.attribute14 );
      add('  attribute15              :'|| l_rec.attribute15 );
    END IF;

  END dump_csi_eav_rec;

  PROCEDURE dump_line_detail_ids_rec(
    p_line_detail_ids_rec in csi_t_datastructures_grp.txn_line_detail_ids_rec)
  IS
    l_rec csi_t_datastructures_grp.txn_line_detail_ids_rec;
  BEGIN
    l_rec := p_line_detail_ids_rec;

    add('txn_line_detail_ids_rec :');
    add('  transaction_line_id      :'|| l_rec.transaction_line_id );
    add('  txn_line_detail_id       :'|| l_rec.txn_line_detail_id );
  END dump_line_detail_ids_rec;

  PROCEDURE dump_party_detail_ids_rec(
    p_party_detail_ids_rec in csi_t_datastructures_grp.txn_party_ids_rec )
  IS
    l_rec csi_t_datastructures_grp.txn_party_ids_rec ;
  BEGIN
    l_rec := p_party_detail_ids_rec ;

    add('txn_party_ids_rec :');
    add('  txn_party_detail_id      :'|| l_rec.txn_party_detail_id );
    add('  txn_line_detail_id       :'|| l_rec.txn_line_detail_id );
  END dump_party_detail_ids_rec;

  PROCEDURE dump_pty_acct_ids_rec(
    p_pty_acct_rec in csi_t_datastructures_grp.txn_pty_acct_ids_rec)
  IS
    l_rec csi_t_datastructures_grp.txn_pty_acct_ids_rec;
  BEGIN
    l_rec := p_pty_acct_rec;

    add('txn_pty_acct_ids_rec :');
    add('  txn_account_detail_id    :'|| l_rec.txn_account_detail_id );
    add('  txn_party_detail_id      :'|| l_rec.txn_party_detail_id );
    add('  txn_line_detail_id       :'|| l_rec.txn_line_detail_id );

  END dump_pty_acct_ids_rec;

  PROCEDURE dump_ii_rltns_ids_rec(
    p_ii_rltns_ids_rec in csi_t_datastructures_grp.txn_ii_rltns_ids_rec)
  IS
    l_rec csi_t_datastructures_grp.txn_ii_rltns_ids_rec;
  BEGIN
    l_rec := p_ii_rltns_ids_rec;

    add('txn_ii_rltns_ids_rec :');
    add('  txn_relationship_id      :'|| l_rec.txn_relationship_id );
    add('  transaction_line_id      :'|| l_rec.transaction_line_id );

  END dump_ii_rltns_ids_rec;

  PROCEDURE dump_oa_ids_rec(
    p_oa_ids_rec in  csi_t_datastructures_grp.txn_org_assgn_ids_rec)
  IS
    l_rec csi_t_datastructures_grp.txn_org_assgn_ids_rec;

  BEGIN

    l_rec := p_oa_ids_rec;

    add('txn_org_assgn_ids_rec :');
    add('  txn_operating_unit_id    :'|| l_rec.txn_operating_unit_id );
    add('  txn_line_detail_id       :'|| l_rec.txn_line_detail_id );

  end dump_oa_ids_rec;

  PROCEDURE dump_txn_ea_ids_rec(
    p_txn_ea_ids_rec in csi_t_datastructures_grp.txn_ext_attrib_ids_rec)
  is
    l_rec csi_t_datastructures_grp.txn_ext_attrib_ids_rec;
  begin
    l_rec := p_txn_ea_ids_rec;

    add('txn_ext_attrib_ids_rec :');
    add('  txn_attrib_detail_id     :'|| l_rec.txn_attrib_detail_id );
    add('  txn_line_detail_id       :'|| l_rec.txn_line_detail_id );

  end dump_txn_ea_ids_rec;

  PROCEDURE dump_txn_source_rec(
     p_txn_source_rec in csi_t_ui_pvt.txn_source_rec)
  IS
    l_rec csi_t_ui_pvt.txn_source_rec;
  BEGIN

    l_rec := p_txn_source_rec;

    IF g_debug_level > 25 THEN
      add('txn_source_rec :');
      add('  organization_id          :'|| l_rec.organization_id );
      add('  inventory_item_id        :'|| l_rec.inventory_item_id );
      add('  inventory_item_name      :'|| l_rec.inventory_item_name );
      add('  item_revision            :'|| l_rec.item_revision );
      add('  source_quantity          :'|| l_rec.source_quantity );
      add('  source_uom               :'|| l_rec.source_uom );
      add('  party_id                 :'|| l_rec.party_id );
      add('  party_account_id         :'|| l_rec.party_id );
      add('  bill_to_address_id       :'|| l_rec.bill_to_address_id );
      add('  ship_to_address_id       :'|| l_rec.ship_to_address_id );
      add('  primary_uom              :'|| l_rec.primary_uom );
      add('  serial_control_flag      :'|| l_rec.serial_control_flag );
      add('  lot_control_flag         :'|| l_rec.lot_control_flag );
      add('  nl_trackable_flag        :'|| l_rec.nl_trackable_flag );

    END IF;
  END dump_txn_source_rec;

  PROCEDURE dump_txn_line_query_rec(
    p_txn_line_query_rec in csi_t_datastructures_grp.txn_line_query_rec)
  IS
    l_rec csi_t_datastructures_grp.txn_line_query_rec;
  BEGIN

    l_rec := p_txn_line_query_rec;

    add('txn_line_query_rec :');

    add('  source_transaction_id    :'|| l_rec.source_transaction_id );
    add('  source_transaction_table :'|| l_rec.source_transaction_table );
    add('  transaction_line_id      :'|| l_rec.transaction_line_id );
    add('  processing_status        :'|| l_rec.processing_status );

    IF g_debug_level > 10 THEN
      add('  source_txn_header_id     :'|| l_rec.source_txn_header_id );
      add('  error_code               :'|| l_rec.error_code );
      add('  error_explanation        :'|| l_rec.error_explanation );
      add('  config_session_hdr_id    :'|| l_rec.config_session_hdr_id );
      add('  config_session_rev_num   :'|| l_rec.config_session_rev_num );
      add('  config_session_item_id   :'|| l_rec.config_session_item_id );
    END IF;

  END dump_txn_line_query_rec;

  PROCEDURE dump_txn_line_detail_query_rec(
    p_txn_line_detail_query_rec in csi_t_datastructures_grp.txn_line_detail_query_rec)
  IS
    l_rec csi_t_datastructures_grp.txn_line_detail_query_rec;
  BEGIN
    l_rec := p_txn_line_detail_query_rec;

    add('txn_line_detail_query_rec :');
    add('  source_transaction_flag  :'|| l_rec.source_transaction_flag );
    add('  txn_line_detail_id       :'|| l_rec.txn_line_detail_id );
    add('  sub_type_id              :'|| l_rec.sub_type_id );
    add('  processing_status        :'|| l_rec.processing_status );

    IF g_debug_level > 10 THEN
      add('  csi_transaction_id       :'|| l_rec.csi_transaction_id );
      add('  error_code               :'|| l_rec.error_code );
      add('  error_explanation        :'|| l_rec.error_explanation );
      add('  instance_exists_flag     :'|| l_rec.instance_exists_flag );
      add('  instance_id              :'|| l_rec.instance_id );
      add('  csi_system_id            :'|| l_rec.csi_system_id );
      add('  transaction_system_id    :'|| l_rec.transaction_system_id );
      add('  inventory_item_id        :'|| l_rec.inventory_item_id );
      add('  inventory_revision       :'|| l_rec.inventory_revision );
      add('  inv_organization_id      :'|| l_rec.inv_organization_id );
      add('  serial_number            :'|| l_rec.serial_number );
      add('  mfg_serial_number_flag   :'|| l_rec.mfg_serial_number_flag );
      add('  lot_number               :'|| l_rec.lot_number );
      add('  location_type_code       :'|| l_rec.location_type_code );
      add('  external_reference       :'|| l_rec.external_reference );
      add('  return_by_date           :'|| l_rec.return_by_date );
    END IF;
  END dump_txn_line_detail_query_rec;

  PROCEDURE dump_csi_instance_rec(
    p_csi_instance_rec in csi_datastructures_pub.instance_rec)
  is
    l_rec csi_datastructures_pub.instance_rec;
  begin
    l_rec := p_csi_instance_rec;

    add('csi_instance_rec :');

    add('  instance_id              :'|| l_rec.instance_id);
    add('  instance_number          :'|| l_rec.instance_number);
    add('  inventory_item_id        :'|| l_rec.inventory_item_id);
    add('  quantity                 :'|| l_rec.quantity);
    add('  unit_of_measure          :'|| l_rec.unit_of_measure);
    add('  vld_organization_id      :'|| l_rec.vld_organization_id);
    add('  serial_number            :'|| l_rec.serial_number);
    add('  lot_number               :'|| l_rec.lot_number);
    add('  accounting_class_code    :'|| l_rec.accounting_class_code);
    add('  location_type_code       :'|| l_rec.location_type_code);
    add('  location_id              :'|| l_rec.location_id);
    add('  inv_organization_id      :'|| l_rec.inv_organization_id);
    add('  inv_subinventory_name    :'|| l_rec.inv_subinventory_name);
    add('  inv_locator_id           :'|| l_rec.inv_locator_id);
    add('  inventory_revision       :'|| l_rec.inventory_revision);
    add('  instance_usage_code      :'|| l_rec.instance_usage_code);
    add('  instance_status_id       :'|| l_rec.instance_status_id);
    add('  active_start_date        :'|| l_rec.active_start_date);
    add('  active_end_date          :'|| l_rec.active_end_date);
    add('  cascade owner flag       :'|| l_rec.cascade_ownership_flag);

    IF g_debug_level > 5 THEN
      add('  mfg_serial_number_flag   :'|| l_rec.mfg_serial_number_flag);
      add('  system_id                :'|| l_rec.system_id);
      add('  last_oe_order_line_id    :'|| l_rec.last_oe_order_line_id);
      add('  last_oe_rma_line_id      :'|| l_rec.last_oe_rma_line_id);
      add('  last_wip_job_id          :'|| l_rec.last_wip_job_id);
      add('  wip_job_id               :'|| l_rec.wip_job_id);
      add('  return_by_date           :'|| l_rec.return_by_date);
      add('  actual_return_date       :'|| l_rec.actual_return_date);
      add('  object_version_number    :'|| l_rec.object_version_number);
    END IF;

    IF g_debug_level > 10 THEN
      add('  config_inst_hdr_id       :'|| l_rec.config_inst_hdr_id);
      add('  config_inst_rev_num      :'|| l_rec.config_inst_rev_num);
      add('  config_inst_item_id      :'|| l_rec.config_inst_item_id);
      add('  instance_condition_id    :'|| l_rec.instance_condition_id);
      add('  install_date             :'|| l_rec.install_date);
      add('  external_reference       :'|| l_rec.external_reference);
      add('  instance_type_code       :'|| l_rec.instance_type_code);
      add('  pa_project_id            :'|| l_rec.pa_project_id);
      add('  pa_project_task_id       :'|| l_rec.pa_project_task_id);
      add('  in_transit_order_line_id :'|| l_rec.in_transit_order_line_id);
      add('  po_order_line_id         :'|| l_rec.po_order_line_id);
      add('  inv_master_org_id        :'|| l_rec.inv_master_organization_id);
      add('  last_po_po_line_id       :'|| l_rec.last_po_po_line_id);
      add('  last_oe_po_number        :'|| l_rec.last_oe_po_number);
      add('  last_pa_project_id       :'|| l_rec.last_pa_project_id);
      add('  last_pa_task_id          :'|| l_rec.last_pa_task_id);
      add('  last_oe_agreement_id     :'|| l_rec.last_oe_agreement_id);
    END IF;

    IF g_debug_level > 15 THEN
      add('  creation_complete_flag   :'|| l_rec.creation_complete_flag);
      add('  completeness_flag        :'|| l_rec.completeness_flag);
      add('  version_label            :'|| l_rec.version_label);
      add('  version_label_desc       :'|| l_rec.version_label_description);
      add('  customer_view_flag       :'|| l_rec.customer_view_flag);
      add('  merchant_view_flag       :'|| l_rec.merchant_view_flag);
      add('  sellable_flag            :'|| l_rec.sellable_flag);
      add('  manually_created_flag    :'|| l_rec.manually_created_flag);
    END IF;

    IF g_debug_level > 25 THEN
      add('  context                  :'|| l_rec.context);
      add('  attribute1               :'|| l_rec.attribute1);
      add('  attribute2               :'|| l_rec.attribute2);
      add('  attribute3               :'|| l_rec.attribute3);
      add('  attribute4               :'|| l_rec.attribute4);
      add('  attribute5               :'|| l_rec.attribute5);
      add('  attribute6               :'|| l_rec.attribute6);
      add('  attribute7               :'|| l_rec.attribute7);
      add('  attribute8               :'|| l_rec.attribute8);
      add('  attribute9               :'|| l_rec.attribute9);
      add('  attribute10              :'|| l_rec.attribute10);
      add('  attribute11              :'|| l_rec.attribute11);
      add('  attribute12              :'|| l_rec.attribute12);
      add('  attribute13              :'|| l_rec.attribute13);
      add('  attribute14              :'|| l_rec.attribute14);
      add('  attribute15              :'|| l_rec.attribute15);
    END IF;

  END dump_csi_instance_rec;

  PROCEDURE dump_csi_instance_tbl(
    p_instance_tbl  in csi_datastructures_pub.instance_tbl)
  IS

    l_inst_line varchar2(2000);

  BEGIN

    add('Instance  ItemID   Quantity  Serial Number       Lot Number          UOM');
    add('--------  -------  --------  ------------------  ------------------  ---');

    IF p_instance_tbl.count > 0 THEN

      FOR l_ind in p_instance_tbl.FIRST .. p_instance_tbl.LAST
      LOOP
        l_inst_line := rpad(to_char(p_instance_tbl(l_ind).instance_id), 10, ' ')||
                  rpad(to_char(p_instance_tbl(l_ind).inventory_item_id), 9, ' ')||
                  rpad(to_char(p_instance_tbl(l_ind).quantity),10, ' ')||
                  rpad(nvl(p_instance_tbl(l_ind).serial_number,' '),20, ' ')||
                  rpad(nvl(p_instance_tbl(l_ind).lot_number,' '),20, ' ')||
                  rpad(p_instance_tbl(l_ind).unit_of_measure,5, ' ');
        add(l_inst_line);
      END LOOP;

    END IF;

  END dump_csi_instance_tbl;

  PROCEDURE dump_txn_tables(
    p_ids_or_index_based IN varchar2,
    p_line_detail_tbl    IN csi_t_datastructures_grp.txn_line_detail_tbl,
    p_party_detail_tbl   IN csi_t_datastructures_grp.txn_party_detail_tbl,
    p_pty_acct_tbl       IN csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_ii_rltns_tbl       IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_org_assgn_tbl      IN csi_t_datastructures_grp.txn_org_assgn_tbl,
    p_ea_vals_tbl        IN csi_t_datastructures_grp.txn_ext_attrib_vals_tbl)
  IS
  BEGIN

    add('txn_line_details     : '||p_line_detail_tbl.COUNT);
    add('txn_party_details    : '||p_party_detail_tbl.COUNT);
    add('txn_party_acct_dtls  : '||p_pty_acct_tbl.COUNT);
    add('txn_ii_relations     : '||p_ii_rltns_tbl.COUNT);
    add('txn_org_assignments  : '||p_org_assgn_tbl.COUNT);
    add('txn_ext_attrib_vals  : '||p_ea_vals_tbl.COUNT);

    IF p_ids_or_index_based = 'I' THEN

      IF p_line_detail_tbl.COUNT > 0 THEN
        FOR l_td_ind IN p_line_detail_tbl.FIRST .. p_line_detail_tbl.LAST
        LOOP
          csi_t_gen_utility_pvt.dump_line_detail_rec(
            p_line_detail_tbl(l_td_ind));

          IF p_party_detail_tbl.COUNT > 0 THEN
            FOR l_pty_ind in p_party_detail_tbl.FIRST.. p_party_detail_tbl.LAST
            LOOP

              IF p_party_detail_tbl(l_pty_ind).txn_line_detail_id =
                 p_line_detail_tbl(l_td_ind).txn_line_detail_id THEN

                csi_t_gen_utility_pvt.dump_party_detail_rec(
                  p_party_detail_tbl(l_pty_ind));

                IF p_pty_acct_tbl.COUNT > 0 THEN
                  FOR l_pa_ind in p_pty_acct_tbl.FIRST .. p_pty_acct_tbl.LAST
                  LOOP
                    IF p_pty_acct_tbl(l_pa_ind).txn_party_detail_id =
                     p_party_detail_tbl(l_pty_ind).txn_party_detail_id THEN

                      csi_t_gen_utility_pvt.dump_pty_acct_rec(
                        p_pty_acct_tbl(l_pa_ind));

                    END IF;
                  END LOOP;
                END IF;

              END IF;
            END LOOP;
          END IF;

          IF p_org_assgn_tbl.COUNT > 0 THEN
            FOR l_ind IN p_org_assgn_tbl.FIRST..p_org_assgn_tbl.LAST
            LOOP
              IF p_org_assgn_tbl(l_ind).txn_line_detail_id =
                 p_line_detail_tbl(l_td_ind).txn_line_detail_id THEN
                csi_t_gen_utility_pvt.dump_org_assgn_rec(
                  p_org_assgn_tbl(l_ind));
              END IF;
            END LOOP;
          END IF;

          IF p_ea_vals_tbl.COUNT > 0 THEN
            FOR l_ind IN p_ea_vals_tbl.FIRST..p_ea_vals_tbl.LAST
            LOOP

              IF p_ea_vals_tbl(l_ind).txn_line_detail_id =
                 p_line_detail_tbl(l_td_ind).txn_line_detail_id THEN

                csi_t_gen_utility_pvt.dump_txn_eav_rec(
                  p_ea_vals_tbl(l_ind));

              END IF;

            END LOOP;
          END IF;

        END LOOP;
      END IF;

    ELSIF p_ids_or_index_based = 'X' THEN
      -- ## to be coded
      null;
    END IF;

    IF p_ii_rltns_tbl.COUNT > 0 THEN
      FOR l_ind in p_ii_rltns_tbl.FIRST..p_ii_rltns_tbl.LAST
      LOOP
        csi_t_gen_utility_pvt.dump_ii_rltns_rec(
          p_ii_rltns_tbl(l_ind));
      END LOOP;
    END IF;

  END dump_txn_tables;

  PROCEDURE dump_txn_source_param_rec(
    p_txn_source_param_rec csi_t_ui_pvt.txn_source_param_rec)
  IS
   x_rec     csi_t_ui_pvt.txn_source_param_rec;
  BEGIN

    x_rec := p_txn_source_param_rec;

    /*
    add('txn_source_param_rec :');
    add('  standalone_mode          :'||x_rec.standalone_mode);
    add('  src_transaction_type_id  :'||x_rec.source_transaction_type_id);
    add('  src_transaction_table    :'||x_rec.source_transaction_table);
    add('  src_transaction_id       :'||x_rec.source_transaction_id);

    IF x_rec.standalone_mode <> 'Y' THEN
      add('  inventory_item_id        :'||x_rec.inventory_item_id);
      add('  inv_orgn_id              :'||x_rec.inv_orgn_id);
      add('  item_revision            :'||x_rec.item_revision);
      add('  transacted_quantity      :'||x_rec.transacted_quantity);
      add('  transacted_uom           :'||x_rec.transacted_uom);
      add('  party_id                 :'||x_rec.party_id);
      add('  account_id               :'||x_rec.account_id);
      add('  ship_to_org_id           :'||x_rec.ship_to_org_id);
      add('  ship_to_contact_id       :'||x_rec.ship_to_contact_id);
      add('  invoice_to_org_id        :'||x_rec.invoice_to_org_id);
      add('  invoice_to_contact_id    :'||x_rec.invoice_to_contact_id);
    END IF;
    */

  END dump_txn_source_param_rec;

  PROCEDURE dump_txn_instance_rec(
    p_txn_instance_rec  IN  csi_process_txn_grp.txn_instance_rec)
  IS
    l_rec csi_process_txn_grp.txn_instance_rec;
  BEGIN

    l_rec := p_txn_instance_rec;

    add('txn_instance_rec ');


    add('  ib_txn_segment_flag      :'||l_rec.ib_txn_segment_flag);
    add('  instance_id              :'||l_rec.instance_id);
    add('  new_instance_id          :'||l_rec.new_instance_id);
    add('  instance_number          :'||l_rec.instance_number);
    add('  external_reference       :'||l_rec.external_reference);
    add('  vld_organization_id      :'||l_rec.vld_organization_id);
    add('  master_organization_id   :'||l_rec.inv_master_organization_id);
    add('  inventory_item_id        :'||l_rec.inventory_item_id);
    add('  inventory_revision       :'||l_rec.inventory_revision);
    add('  quantity                 :'||l_rec.quantity);
    add('  unit_of_measure          :'||l_rec.unit_of_measure);
    add('  location_type_code       :'||l_rec.location_type_code);
    add('  location_id              :'||l_rec.location_id);
    add('  inv_organization_id      :'||l_rec.inv_organization_id);
    add('  inv_subinventory_name    :'||l_rec.inv_subinventory_name);
    add('  inv_locator_id           :'||l_rec.inv_locator_id);
    add('  mfg_serial_number_flag   :'||l_rec.mfg_serial_number_flag);
    add('  serial_number            :'||l_rec.serial_number);
    add('  lot_number               :'||l_rec.lot_number);

    IF g_debug_level > 5 THEN

    add('  accounting_class_code    :'||l_rec.accounting_class_code);
    add('  instance_condition_id    :'||l_rec.instance_condition_id);
    add('  instance_status_id       :'||l_rec.instance_status_id);
    add('  customer_view_flag       :'||l_rec.customer_view_flag);
    add('  merchant_view_flag       :'||l_rec.merchant_view_flag);
    add('  sellable_flag            :'||l_rec.sellable_flag);
    add('  system_id                :'||l_rec.system_id);
    add('  instance_type_code       :'||l_rec.instance_type_code);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);
    add('  pa_project_id            :'||l_rec.pa_project_id);
    add('  pa_project_task_id       :'||l_rec.pa_project_task_id);
    add('  in_transit_order_line_id :'||l_rec.in_transit_order_line_id);
    add('  wip_job_id               :'||l_rec.wip_job_id);
    add('  po_order_line_id         :'||l_rec.po_order_line_id);
    add('  last_oe_order_line_id    :'||l_rec.last_oe_order_line_id);
    add('  last_oe_rma_line_id      :'||l_rec.last_oe_rma_line_id);
    add('  last_po_po_line_id       :'||l_rec.last_po_po_line_id);
    add('  last_oe_po_number        :'||l_rec.last_oe_po_number);
    add('  last_wip_job_id          :'||l_rec.last_wip_job_id);
    add('  last_pa_project_id       :'||l_rec.last_pa_project_id);
    add('  last_pa_task_id          :'||l_rec.last_pa_task_id);
    add('  last_oe_agreement_id     :'||l_rec.last_oe_agreement_id);
    add('  install_date             :'||l_rec.install_date);
    add('  manually_created_flag    :'||l_rec.manually_created_flag);
    add('  return_by_date           :'||l_rec.return_by_date);
    add('  actual_return_date       :'||l_rec.actual_return_date);
    add('  creation_complete_flag   :'||l_rec.creation_complete_flag);
    add('  completeness_flag        :'||l_rec.completeness_flag);
    add('  last_txn_line_detail_id  :'||l_rec.last_txn_line_detail_id);
    add('  install_loc_type_code    :'||l_rec.install_location_type_code);
    add('  install_location_id      :'||l_rec.install_location_id);
    add('  instance_usage_code      :'||l_rec.instance_usage_code);
    add('  version_label            :'||l_rec.version_label);
    add('  version_label_desc       :'||l_rec.version_label_description);
    add('  object_version_number    :'||l_rec.object_version_number);

    END IF;

    IF g_debug_level > 25 THEN
    add('  context                  :'||l_rec.context);
    add('  attribute1               :'||l_rec.attribute1);
    add('  attribute2               :'||l_rec.attribute2);
    add('  attribute3               :'||l_rec.attribute3);
    add('  attribute4               :'||l_rec.attribute4);
    add('  attribute5               :'||l_rec.attribute5);
    add('  attribute6               :'||l_rec.attribute6);
    add('  attribute7               :'||l_rec.attribute7);
    add('  attribute8               :'||l_rec.attribute8);
    add('  attribute9               :'||l_rec.attribute9);
    add('  attribute10              :'||l_rec.attribute10);
    add('  attribute11              :'||l_rec.attribute11);
    add('  attribute12              :'||l_rec.attribute12);
    add('  attribute13              :'||l_rec.attribute13);
    add('  attribute14              :'||l_rec.attribute14);
    add('  attribute15              :'||l_rec.attribute15);
    END IF;

  END dump_txn_instance_rec;

  PROCEDURE dump_dest_location_rec(
    p_dest_location_rec   IN csi_process_txn_grp.dest_location_rec)
  IS
    l_rec csi_process_txn_grp.dest_location_rec;
  BEGIN
    l_rec := p_dest_location_rec;

    add('dest_location_rec :');
    add('  location_type_code       :'||l_rec.location_type_code);
    add('  location_id              :'||l_rec.location_id);
    add('  inv_organization_id      :'||l_rec.inv_organization_id);
    add('  inv_subinventory_name    :'||l_rec.inv_subinventory_name);
    add('  inv_locator_id           :'||l_rec.inv_locator_id);
    add('  pa_project_id            :'||l_rec.pa_project_id);
    add('  pa_project_task_id       :'||l_rec.pa_project_task_id);
    add('  in_transit_order_line_id :'||l_rec.in_transit_order_line_id);
    add('  wip_job_id               :'||l_rec.wip_job_id);
    add('  po_order_line_id         :'||l_rec.po_order_line_id);
  END dump_dest_location_rec;

  PROCEDURE dump_txn_i_party_rec(
    p_txn_i_party_rec IN csi_process_txn_grp.txn_i_party_rec)
  IS
    l_rec csi_process_txn_grp.txn_i_party_rec;
  BEGIN

    l_rec := p_txn_i_party_rec;
    add('txn_i_party_rec :');
    add('  instance_party_id        :'||l_rec.instance_party_id);
    add('  parent_tbl_index         :'||l_rec.parent_tbl_index);
    add('  instance_id              :'||l_rec.instance_id);
    add('  party_source_table       :'||l_rec.party_source_table);
    add('  party_id                 :'||l_rec.party_id);
    add('  relationship_type_code   :'||l_rec.relationship_type_code);
    add('  contact_flag             :'||l_rec.contact_flag);
    add('  contact_ip_id            :'||l_rec.contact_ip_id);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);
    add('  object_version_number    :'||l_rec.object_version_number);

    IF g_debug_level > 25 THEN
    add('  context                  :'||l_rec.context);
    add('  attribute1               :'||l_rec.attribute1);
    add('  attribute2               :'||l_rec.attribute2);
    add('  attribute3               :'||l_rec.attribute3);
    add('  attribute4               :'||l_rec.attribute4);
    add('  attribute5               :'||l_rec.attribute5);
    add('  attribute6               :'||l_rec.attribute6);
    add('  attribute7               :'||l_rec.attribute7);
    add('  attribute8               :'||l_rec.attribute8);
    add('  attribute9               :'||l_rec.attribute9);
    add('  attribute10              :'||l_rec.attribute10);
    add('  attribute11              :'||l_rec.attribute11);
    add('  attribute12              :'||l_rec.attribute12);
    add('  attribute13              :'||l_rec.attribute13);
    add('  attribute14              :'||l_rec.attribute14);
    add('  attribute15              :'||l_rec.attribute15);
    END IF;

  END dump_txn_i_party_rec;

  PROCEDURE dump_txn_ip_account_rec(
    p_txn_ip_account_rec IN csi_process_txn_grp.txn_ip_account_rec)
  IS
    l_rec csi_process_txn_grp.txn_ip_account_rec;
  BEGIN

    l_rec := p_txn_ip_account_rec;

    add('txn_ip_account_rec :');
    add('  ip_account_id            :'||l_rec.ip_account_id);
    add('  parent_tbl_index         :'||l_rec.parent_tbl_index);
    add('  instance_party_id        :'||l_rec.instance_party_id);
    add('  party_account_id         :'||l_rec.party_account_id);
    add('  relationship_type_code   :'||l_rec.relationship_type_code);
    add('  bill_to_address          :'||l_rec.bill_to_address);
    add('  ship_to_address          :'||l_rec.ship_to_address);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);
    add('  object_version_number :'||l_rec.object_version_number);

    IF g_debug_level > 25 THEN
    add('  context                  :'||l_rec.context);
    add('  attribute1               :'||l_rec.attribute1);
    add('  attribute2               :'||l_rec.attribute2);
    add('  attribute3               :'||l_rec.attribute3);
    add('  attribute4               :'||l_rec.attribute4);
    add('  attribute5               :'||l_rec.attribute5);
    add('  attribute6               :'||l_rec.attribute6);
    add('  attribute7               :'||l_rec.attribute7);
    add('  attribute8               :'||l_rec.attribute8);
    add('  attribute9               :'||l_rec.attribute9);
    add('  attribute10              :'||l_rec.attribute10);
    add('  attribute11              :'||l_rec.attribute11);
    add('  attribute12              :'||l_rec.attribute12);
    add('  attribute13              :'||l_rec.attribute13);
    add('  attribute14              :'||l_rec.attribute14);
    add('  attribute15              :'||l_rec.attribute15);
    END IF;

  END dump_txn_ip_account_rec;

  PROCEDURE dump_txn_ii_rltns_rec(
    p_txn_ii_rltns_rec IN csi_process_txn_grp.txn_ii_relationship_rec)
  IS
    l_rec csi_process_txn_grp.txn_ii_relationship_rec;
  BEGIN

    l_rec := p_txn_ii_rltns_rec;

    add('txn_ii_relationship_rec :');
    add('  relationship_id          :'||l_rec.relationship_id);
    add('  relationship_type_code   :'||l_rec.relationship_type_code);
    add('  object_index             :'||l_rec.object_index);
    add('  object_id                :'||l_rec.object_id);
    add('  subject_index            :'||l_rec.subject_index);
    add('  subject_id               :'||l_rec.subject_id);
    add('  subject_has_child        :'||l_rec.subject_has_child);
    add('  position_reference       :'||l_rec.position_reference);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);
    add('  display_order            :'||l_rec.display_order);
    add('  mandatory_flag           :'||l_rec.mandatory_flag);
    add('  object_version_number :'||l_rec.object_version_number);

    IF g_debug_level > 25 THEN
    add('  context                  :'||l_rec.context);
    add('  attribute1               :'||l_rec.attribute1);
    add('  attribute2               :'||l_rec.attribute2);
    add('  attribute3               :'||l_rec.attribute3);
    add('  attribute4               :'||l_rec.attribute4);
    add('  attribute5               :'||l_rec.attribute5);
    add('  attribute6               :'||l_rec.attribute6);
    add('  attribute7               :'||l_rec.attribute7);
    add('  attribute8               :'||l_rec.attribute8);
    add('  attribute9               :'||l_rec.attribute9);
    add('  attribute10              :'||l_rec.attribute10);
    add('  attribute11              :'||l_rec.attribute11);
    add('  attribute12              :'||l_rec.attribute12);
    add('  attribute13              :'||l_rec.attribute13);
    add('  attribute14              :'||l_rec.attribute14);
    add('  attribute15              :'||l_rec.attribute15);
    END IF;

  END dump_txn_ii_rltns_rec;

  PROCEDURE dump_txn_eav_rec(
    p_txn_eav_rec IN csi_process_txn_grp.txn_ext_attrib_value_rec)
  IS
    l_rec csi_process_txn_grp.txn_ext_attrib_value_rec;
  BEGIN

    l_rec := p_txn_eav_rec;

    add('txn_ext_attrib_value_rec :');
    add('  attribute_value_id       :'||l_rec.attribute_value_id);
    add('  parent_tbl_index         :'||l_rec.parent_tbl_index);
    add('  instance_id              :'||l_rec.instance_id);
    add('  attribute_id             :'||l_rec.attribute_id);
    add('  attribute_code           :'||l_rec.attribute_code);
    add('  attribute_value          :'||l_rec.attribute_value);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);
    add('  object_version_number :'||l_rec.object_version_number);

    IF g_debug_level > 25 THEN
    add('  context                  :'||l_rec.context);
    add('  attribute1               :'||l_rec.attribute1);
    add('  attribute2               :'||l_rec.attribute2);
    add('  attribute3               :'||l_rec.attribute3);
    add('  attribute4               :'||l_rec.attribute4);
    add('  attribute5               :'||l_rec.attribute5);
    add('  attribute6               :'||l_rec.attribute6);
    add('  attribute7               :'||l_rec.attribute7);
    add('  attribute8               :'||l_rec.attribute8);
    add('  attribute9               :'||l_rec.attribute9);
    add('  attribute10              :'||l_rec.attribute10);
    add('  attribute11              :'||l_rec.attribute11);
    add('  attribute12              :'||l_rec.attribute12);
    add('  attribute13              :'||l_rec.attribute13);
    add('  attribute14              :'||l_rec.attribute14);
    add('  attribute15              :'||l_rec.attribute15);
    END IF;

  END dump_txn_eav_rec;

  PROCEDURE dump_txn_price_rec(
    p_txn_price_rec IN csi_process_txn_grp.txn_pricing_attrib_rec)
  IS
    l_rec csi_process_txn_grp.txn_pricing_attrib_rec;
  BEGIN

    l_rec := p_txn_price_rec;

    add('txn_pricing_attrib_rec :');
    add('  pricing_attribute_id     :'||l_rec.pricing_attribute_id);
    add('  parent_tbl_index         :'||l_rec.parent_tbl_index);
    add('  instance_id              :'||l_rec.instance_id);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);
    add('  pricing_context          :'||l_rec.pricing_context);
    add('  pricing_attribute1       :'||l_rec.pricing_attribute1);
    add('  pricing_attribute2       :'||l_rec.pricing_attribute2);
    add('  pricing_attribute3       :'||l_rec.pricing_attribute3);
    add('  pricing_attribute4       :'||l_rec.pricing_attribute4);
    add('  pricing_attribute5       :'||l_rec.pricing_attribute5);

    IF g_debug_level > 15 THEN
    add('  pricing_attribute6       :'||l_rec.pricing_attribute6);
    add('  pricing_attribute7       :'||l_rec.pricing_attribute7);
    add('  pricing_attribute8       :'||l_rec.pricing_attribute8);
    add('  pricing_attribute9       :'||l_rec.pricing_attribute9);
    add('  pricing_attribute10      :'||l_rec.pricing_attribute10);
    add('  pricing_attribute11      :'||l_rec.pricing_attribute11);
    add('  pricing_attribute12      :'||l_rec.pricing_attribute12);
    add('  pricing_attribute13      :'||l_rec.pricing_attribute13);
    add('  pricing_attribute14      :'||l_rec.pricing_attribute14);
    add('  pricing_attribute15      :'||l_rec.pricing_attribute15);
    add('  object_version_number    :'||l_rec.object_version_number);
    END IF;

    IF g_debug_level > 25 THEN
    add('  pricing_attribute16      :'||l_rec.pricing_attribute16);
    add('  pricing_attribute17      :'||l_rec.pricing_attribute17);
    add('  pricing_attribute18      :'||l_rec.pricing_attribute18);
    add('  pricing_attribute19      :'||l_rec.pricing_attribute19);
    add('  pricing_attribute20      :'||l_rec.pricing_attribute20);
    add('  pricing_attribute21      :'||l_rec.pricing_attribute21);
    add('  pricing_attribute22      :'||l_rec.pricing_attribute22);
    add('  pricing_attribute23      :'||l_rec.pricing_attribute23);
    add('  pricing_attribute24      :'||l_rec.pricing_attribute24);
    add('  pricing_attribute25      :'||l_rec.pricing_attribute25);
    add('  pricing_attribute26      :'||l_rec.pricing_attribute26);
    add('  pricing_attribute27      :'||l_rec.pricing_attribute27);
    add('  pricing_attribute28      :'||l_rec.pricing_attribute28);
    add('  pricing_attribute29      :'||l_rec.pricing_attribute29);
    add('  pricing_attribute30      :'||l_rec.pricing_attribute30);
    add('  pricing_attribute31      :'||l_rec.pricing_attribute31);
    add('  pricing_attribute32      :'||l_rec.pricing_attribute32);
    add('  pricing_attribute33      :'||l_rec.pricing_attribute33);
    add('  pricing_attribute34      :'||l_rec.pricing_attribute34);
    add('  pricing_attribute35      :'||l_rec.pricing_attribute35);
    add('  pricing_attribute36      :'||l_rec.pricing_attribute36);
    add('  pricing_attribute37      :'||l_rec.pricing_attribute37);
    add('  pricing_attribute38      :'||l_rec.pricing_attribute38);
    add('  pricing_attribute39      :'||l_rec.pricing_attribute39);
    add('  pricing_attribute40      :'||l_rec.pricing_attribute40);
    add('  pricing_attribute41      :'||l_rec.pricing_attribute41);
    add('  pricing_attribute42      :'||l_rec.pricing_attribute42);
    add('  pricing_attribute43      :'||l_rec.pricing_attribute43);
    add('  pricing_attribute44      :'||l_rec.pricing_attribute44);
    add('  pricing_attribute45      :'||l_rec.pricing_attribute45);
    add('  pricing_attribute46      :'||l_rec.pricing_attribute46);
    add('  pricing_attribute47      :'||l_rec.pricing_attribute47);
    add('  pricing_attribute48      :'||l_rec.pricing_attribute48);
    add('  pricing_attribute49      :'||l_rec.pricing_attribute49);
    add('  pricing_attribute50      :'||l_rec.pricing_attribute50);
    add('  pricing_attribute51      :'||l_rec.pricing_attribute51);
    add('  pricing_attribute52      :'||l_rec.pricing_attribute52);
    add('  pricing_attribute53      :'||l_rec.pricing_attribute53);
    add('  pricing_attribute54      :'||l_rec.pricing_attribute54);
    add('  pricing_attribute55      :'||l_rec.pricing_attribute55);
    add('  pricing_attribute56      :'||l_rec.pricing_attribute56);
    add('  pricing_attribute57      :'||l_rec.pricing_attribute57);
    add('  pricing_attribute58      :'||l_rec.pricing_attribute58);
    add('  pricing_attribute59      :'||l_rec.pricing_attribute59);
    add('  pricing_attribute60      :'||l_rec.pricing_attribute60);
    add('  pricing_attribute61      :'||l_rec.pricing_attribute61);
    add('  pricing_attribute62      :'||l_rec.pricing_attribute62);
    add('  pricing_attribute63      :'||l_rec.pricing_attribute63);
    add('  pricing_attribute64      :'||l_rec.pricing_attribute64);
    add('  pricing_attribute65      :'||l_rec.pricing_attribute65);
    add('  pricing_attribute66      :'||l_rec.pricing_attribute66);
    add('  pricing_attribute67      :'||l_rec.pricing_attribute67);
    add('  pricing_attribute68      :'||l_rec.pricing_attribute68);
    add('  pricing_attribute69      :'||l_rec.pricing_attribute69);
    add('  pricing_attribute70      :'||l_rec.pricing_attribute70);
    add('  pricing_attribute71      :'||l_rec.pricing_attribute71);
    add('  pricing_attribute72      :'||l_rec.pricing_attribute72);
    add('  pricing_attribute73      :'||l_rec.pricing_attribute73);
    add('  pricing_attribute74      :'||l_rec.pricing_attribute74);
    add('  pricing_attribute75      :'||l_rec.pricing_attribute75);
    add('  pricing_attribute76      :'||l_rec.pricing_attribute76);
    add('  pricing_attribute77      :'||l_rec.pricing_attribute77);
    add('  pricing_attribute78      :'||l_rec.pricing_attribute78);
    add('  pricing_attribute79      :'||l_rec.pricing_attribute79);
    add('  pricing_attribute80      :'||l_rec.pricing_attribute80);
    add('  pricing_attribute81      :'||l_rec.pricing_attribute81);
    add('  pricing_attribute82      :'||l_rec.pricing_attribute82);
    add('  pricing_attribute83      :'||l_rec.pricing_attribute83);
    add('  pricing_attribute84      :'||l_rec.pricing_attribute84);
    add('  pricing_attribute85      :'||l_rec.pricing_attribute85);
    add('  pricing_attribute86      :'||l_rec.pricing_attribute86);
    add('  pricing_attribute87      :'||l_rec.pricing_attribute87);
    add('  pricing_attribute88      :'||l_rec.pricing_attribute88);
    add('  pricing_attribute89      :'||l_rec.pricing_attribute89);
    add('  pricing_attribute90      :'||l_rec.pricing_attribute90);
    add('  pricing_attribute91      :'||l_rec.pricing_attribute91);
    add('  pricing_attribute92      :'||l_rec.pricing_attribute92);
    add('  pricing_attribute93      :'||l_rec.pricing_attribute93);
    add('  pricing_attribute94      :'||l_rec.pricing_attribute94);
    add('  pricing_attribute95      :'||l_rec.pricing_attribute95);
    add('  pricing_attribute96      :'||l_rec.pricing_attribute96);
    add('  pricing_attribute97      :'||l_rec.pricing_attribute97);
    add('  pricing_attribute98      :'||l_rec.pricing_attribute98);
    add('  pricing_attribute99      :'||l_rec.pricing_attribute99);
    add('  pricing_attribute100     :'||l_rec.pricing_attribute100);
    add('  context                  :'||l_rec.context);
    add('  attribute1               :'||l_rec.attribute1);
    add('  attribute2               :'||l_rec.attribute2);
    add('  attribute3               :'||l_rec.attribute3);
    add('  attribute4               :'||l_rec.attribute4);
    add('  attribute5               :'||l_rec.attribute5);
    add('  attribute6               :'||l_rec.attribute6);
    add('  attribute7               :'||l_rec.attribute7);
    add('  attribute8               :'||l_rec.attribute8);
    add('  attribute9               :'||l_rec.attribute9);
    add('  attribute10              :'||l_rec.attribute10);
    add('  attribute11              :'||l_rec.attribute11);
    add('  attribute12              :'||l_rec.attribute12);
    add('  attribute13              :'||l_rec.attribute13);
    add('  attribute14              :'||l_rec.attribute14);
    add('  attribute15              :'||l_rec.attribute15);
    END IF;

  END dump_txn_price_rec;

  PROCEDURE dump_txn_org_unit_rec(
    p_txn_org_unit_rec IN csi_process_txn_grp.txn_org_unit_rec)
  IS
   l_rec csi_process_txn_grp.txn_org_unit_rec;
  BEGIN

    l_rec := p_txn_org_unit_rec;

    add('txn_org_unit_rec :');
    add('  instance_ou_id           :'||l_rec.instance_ou_id);
    add('  parent_tbl_index         :'||l_rec.parent_tbl_index);
    add('  instance_id              :'||l_rec.instance_id);
    add('  operating_unit_id        :'||l_rec.operating_unit_id);
    add('  relationship_type_code   :'||l_rec.relationship_type_code);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);
    add('  object_version_number    :'||l_rec.object_version_number);

    IF g_debug_level > 25 THEN
    add('  context                  :'||l_rec.context);
    add('  attribute1               :'||l_rec.attribute1);
    add('  attribute2               :'||l_rec.attribute2);
    add('  attribute3               :'||l_rec.attribute3);
    add('  attribute4               :'||l_rec.attribute4);
    add('  attribute5               :'||l_rec.attribute5);
    add('  attribute6               :'||l_rec.attribute6);
    add('  attribute7               :'||l_rec.attribute7);
    add('  attribute8               :'||l_rec.attribute8);
    add('  attribute9               :'||l_rec.attribute9);
    add('  attribute10              :'||l_rec.attribute10);
    add('  attribute11              :'||l_rec.attribute11);
    add('  attribute12              :'||l_rec.attribute12);
    add('  attribute13              :'||l_rec.attribute13);
    add('  attribute14              :'||l_rec.attribute14);
    add('  attribute15              :'||l_rec.attribute15);
    END IF;

  END dump_txn_org_unit_rec;

  PROCEDURE dump_txn_asset_rec(
    p_txn_asset_rec IN csi_process_txn_grp.txn_instance_asset_rec)
  IS
    l_rec csi_process_txn_grp.txn_instance_asset_rec;
  BEGIN

    l_rec := p_txn_asset_rec;

    add('txn_instance_asset_rec :');
    add('  instance_asset_id        :'||l_rec.instance_asset_id);
    add('  parent_tbl_index         :'||l_rec.parent_tbl_index);
    add('  instance_id              :'||l_rec.instance_id);
    add('  fa_asset_id              :'||l_rec.fa_asset_id);
    add('  fa_book_type_code        :'||l_rec.fa_book_type_code);
    add('  fa_location_id           :'||l_rec.fa_location_id);
    add('  asset_quantity           :'||l_rec.asset_quantity);
    add('  update_status            :'||l_rec.update_status);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);
    add('  object_version_number    :'||l_rec.object_version_number);

  END dump_txn_asset_rec;

  PROCEDURE dump_instance_query_rec(
    p_instance_query_rec  IN csi_datastructures_pub.instance_query_rec)
  IS
    l_rec csi_datastructures_pub.instance_query_rec;
  BEGIN
    l_rec := p_instance_query_rec;

    add('csi_datastructures_pub.instance_query_rec :');
    add('  instance_id              :'||l_rec.instance_id);
    add('  inventory_item_id        :'||l_rec.inventory_item_id);
    add('  inventory_revision       :'||l_rec.inventory_revision);
    add('  serial_number            :'||l_rec.serial_number);
    add('  lot_number               :'||l_rec.lot_number);
    add('  unit_of_measure          :'||l_rec.unit_of_measure);
    add('  location_type_code       :'||l_rec.location_type_code);
    add('  location_id              :'||l_rec.location_id);
    add('  inv_organization_id      :'||l_rec.inv_organization_id);
    add('  inv_subinventory_name    :'||l_rec.inv_subinventory_name);
    add('  inv_locator_id           :'||l_rec.inv_locator_id);
    add('  instance_usage_code      :'||l_rec.instance_usage_code);
    add('  in_transit_order_line_id :'||l_rec.in_transit_order_line_id);
    add('  wip_job_id               :'||l_rec.wip_job_id);
    add('  last_oe_order_line_id    :'||l_rec.last_oe_order_line_id);
    add('  last_oe_rma_line_id      :'||l_rec.last_oe_rma_line_id);
    add('  last_wip_job_id          :'||l_rec.last_wip_job_id);

    IF g_debug_level > 10 THEN
      add('  instance_status_id       :'||l_rec.instance_status_id);
      add('  instance_condition_id    :'||l_rec.instance_condition_id);
      add('  instance_type_code       :'||l_rec.instance_type_code);
      add('  master_organization_id   :'||l_rec.inv_master_organization_id);
      add('  system_id                :'||l_rec.system_id);
      add('  query_units_only         :'||l_rec.query_units_only);
      add('  return_by_date           :'||l_rec.return_by_date);
      add('  actual_return_date       :'||l_rec.actual_return_date);
      add('  install_date             :'||l_rec.install_date);
      add('  last_po_po_line_id       :'||l_rec.last_po_po_line_id);
      add('  last_oe_po_number        :'||l_rec.last_oe_po_number);
      add('  last_oe_agreement_id     :'||l_rec.last_oe_agreement_id);
      add('  manually_created_flag    :'||l_rec.manually_created_flag);
      add('  po_order_line_id         :'||l_rec.po_order_line_id);
      add('  pa_project_id            :'||l_rec.pa_project_id);
      add('  pa_project_task_id       :'||l_rec.pa_project_task_id);
      add('  last_pa_project_id       :'||l_rec.last_pa_project_id);
      add('  last_pa_task_id          :'||l_rec.last_pa_task_id);
    END IF;
  END dump_instance_query_rec;

  PROCEDURE dump_csi_party_rec(
    p_party_rec   csi_datastructures_pub.party_rec)
  IS
    l_rec         csi_datastructures_pub.party_rec;
  BEGIN
    l_rec := p_party_rec;

    add('csi_datastructures_pub.party_rec :');
    add('  instance_party_id        :'||l_rec.instance_party_id);
    add('  parent_tbl_index         :'||l_rec.parent_tbl_index);
    add('  instance_id              :'||l_rec.instance_id);

    IF g_debug_level > 5 THEN
      add('  party_source_table       :'||l_rec.party_source_table);
      add('  party_id                 :'||l_rec.party_id);
      add('  relationship_type_code   :'||l_rec.relationship_type_code);
      add('  contact_flag             :'||l_rec.contact_flag);
      add('  contact_ip_id            :'||l_rec.contact_ip_id);
      add('  contact_parent_tbl_index :'||l_rec.contact_parent_tbl_index);
      add('  active_start_date        :'||l_rec.active_start_date);
      add('  active_end_date          :'||l_rec.active_end_date);
      add('  call_contracts           :'||l_rec.call_contracts);
    END IF;

    IF g_debug_level > 25 THEN

    add('  context                  :'||l_rec.context);
    add('  attribute1               :'||l_rec.attribute1);
    add('  attribute2               :'||l_rec.attribute2);
    add('  attribute3               :'||l_rec.attribute3);
    add('  attribute4               :'||l_rec.attribute4);
    add('  attribute5               :'||l_rec.attribute5);
    add('  attribute6               :'||l_rec.attribute6);
    add('  attribute7               :'||l_rec.attribute7);
    add('  attribute8               :'||l_rec.attribute8);
    add('  attribute9               :'||l_rec.attribute9);
    add('  attribute10              :'||l_rec.attribute10);
    add('  attribute11              :'||l_rec.attribute11);
    add('  attribute12              :'||l_rec.attribute12);
    add('  attribute13              :'||l_rec.attribute13);
    add('  attribute14              :'||l_rec.attribute14);
    add('  attribute15              :'||l_rec.attribute15);
    add('  object_version_number    :'||l_rec.object_version_number);
    add('  primary_flag             :'||l_rec.primary_flag);
    add('  preferred_flag           :'||l_rec.preferred_flag);
    add('  interface_id             :'||l_rec.interface_id);

    END IF;

  END dump_csi_party_rec;

  PROCEDURE dump_csi_party_tbl(
    p_party_tbl    csi_datastructures_pub.party_tbl)
  IS
  BEGIN
    IF p_party_tbl.COUNT > 0 THEN
      FOR l_ind IN p_party_tbl.FIRST .. p_party_tbl.LAST
      LOOP
        add('dump party_tbl. record # '||l_ind);
        dump_csi_party_rec(p_party_tbl(l_ind));
      END LOOP;
    END IF;
  END dump_csi_party_tbl;

  PROCEDURE dump_csi_account_rec(
    p_party_account_rec   IN csi_datastructures_pub.party_account_rec)
  IS
    l_rec csi_datastructures_pub.party_account_rec;
  BEGIN

    l_rec := p_party_account_rec;

    add('csi_datastructures_pub.party_account_rec :');
    add('  ip_account_id            :'||l_rec.ip_account_id);
    add('  parent_tbl_index         :'||l_rec.parent_tbl_index);
    add('  instance_party_id        :'||l_rec.instance_party_id);
    add('  party_account_id         :'||l_rec.party_account_id);
    add('  relationship_type_code   :'||l_rec.relationship_type_code);
    add('  bill_to_address          :'||l_rec.bill_to_address);
    add('  ship_to_address          :'||l_rec.ship_to_address);
    add('  call_contracts           :'||l_rec.call_contracts);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);

    IF g_debug_level > 25 THEN

    add('  context                  :'||l_rec.context);
    add('  attribute1               :'||l_rec.attribute1);
    add('  attribute2               :'||l_rec.attribute2);
    add('  attribute3               :'||l_rec.attribute3);
    add('  attribute4               :'||l_rec.attribute4);
    add('  attribute5               :'||l_rec.attribute5);
    add('  attribute6               :'||l_rec.attribute6);
    add('  attribute7               :'||l_rec.attribute7);
    add('  attribute8               :'||l_rec.attribute8);
    add('  attribute9               :'||l_rec.attribute9);
    add('  attribute10              :'||l_rec.attribute10);
    add('  attribute11              :'||l_rec.attribute11);
    add('  attribute12              :'||l_rec.attribute12);
    add('  attribute13              :'||l_rec.attribute13);
    add('  attribute14              :'||l_rec.attribute14);
    add('  attribute15              :'||l_rec.attribute15);
    add('  object_version_number    :'||l_rec.object_version_number);
    add('  vld_organization_id      :'||l_rec.vld_organization_id);
    add('  expire_flag              :'||l_rec.expire_flag);
    add('  grp_call_contracts       :'||l_rec.grp_call_contracts);

    END IF;

  end dump_csi_account_rec;

  PROCEDURE dump_csi_account_tbl(
    p_party_account_tbl   IN csi_datastructures_pub.party_account_tbl)
  IS
  BEGIN
    IF p_party_account_tbl.COUNT > 0 THEN
      FOR l_ind IN p_party_account_tbl.FIRST .. p_party_account_tbl.LAST
      LOOP
        add('dump party_account_tbl. record # '||l_ind);
        dump_csi_account_rec(p_party_account_tbl(l_ind));
      END LOOP;
    END IF;
  END dump_csi_account_tbl;

  PROCEDURE dump_eav_rec(
    p_eav_rec  IN csi_datastructures_pub.extend_attrib_values_rec)
  IS
    l_rec csi_datastructures_pub.extend_attrib_values_rec;
  BEGIN
    l_rec := p_eav_rec;

    add('csi_datastructures_pub.extend_attrib_values_rec :');
    add('  attribute_value_id       :'||l_rec.attribute_value_id);
    add('  instance_id              :'||l_rec.instance_id);
    add('  attribute_id             :'||l_rec.attribute_id);
    add('  attribute_code           :'||l_rec.attribute_code);
    add('  attribute_value          :'||l_rec.attribute_value);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);
  END dump_eav_rec;

  PROCEDURE dump_eav_tbl(
    p_eav_tbl  IN csi_datastructures_pub.extend_attrib_values_tbl)
  IS
  BEGIN
    IF p_eav_tbl.count > 0 THEN
      FOR l_ind IN p_eav_tbl.FIRST .. p_eav_tbl.LAST
      LOOP
        add('dump extend_attrib_values_tbl. record # '||l_ind);
        dump_eav_rec(p_eav_tbl(l_ind));
      END LOOP;
    END IF;
  END dump_eav_tbl;

  PROCEDURE dump_csi_ii_rltns_rec(
    p_ii_rltns_rec IN csi_datastructures_pub.ii_relationship_rec,
    p_rec_index    IN number)
  IS
    l_rec csi_datastructures_pub.ii_relationship_rec;
  BEGIN

    l_rec := p_ii_rltns_rec;

    add('csi_datastructures_pub.ii_relationship_rec : record # :'||p_rec_index);

    add('  relationship_id          :'||l_rec.relationship_id);
    add('  subject_id               :'||l_rec.subject_id);
    add('  relationship_type_code   :'||l_rec.relationship_type_code);
    add('  object_id                :'||l_rec.object_id);
    add('  active_start_date        :'||l_rec.active_start_date);
    add('  active_end_date          :'||l_rec.active_end_date);

    IF g_debug_level > 15 THEN
      add('  subject_has_child        :'||l_rec.subject_has_child);
      add('  position_reference       :'||l_rec.position_reference);
      add('  display_order            :'||l_rec.display_order);
      add('  mandatory_flag           :'||l_rec.mandatory_flag);
    END IF;

    IF g_debug_level > 25 THEN
      add('  context                  :'||l_rec.context);
      add('  attribute1               :'||l_rec.attribute1);
      add('  attribute2               :'||l_rec.attribute2);
      add('  attribute3               :'||l_rec.attribute3);
      add('  attribute4               :'||l_rec.attribute4);
      add('  attribute5               :'||l_rec.attribute5);
      add('  attribute6               :'||l_rec.attribute6);
      add('  attribute7               :'||l_rec.attribute7);
      add('  attribute8               :'||l_rec.attribute8);
      add('  attribute9               :'||l_rec.attribute9);
      add('  attribute10              :'||l_rec.attribute10);
      add('  attribute11              :'||l_rec.attribute11);
      add('  attribute12              :'||l_rec.attribute12);
      add('  attribute13              :'||l_rec.attribute13);
      add('  attribute14              :'||l_rec.attribute14);
      add('  attribute15              :'||l_rec.attribute15);
      add('  object_version_number    :'||l_rec.object_version_number);
      add('  parent_tbl_index         :'||l_rec.parent_tbl_index);
      add('  processed_flag           :'||l_rec.processed_flag);
      add('  interface_id             :'||l_rec.interface_id);
    END IF;

  END dump_csi_ii_rltns_rec;

  PROCEDURE dump_csi_ii_rltns_tbl(
    p_ii_rltns_tbl IN csi_datastructures_pub.ii_relationship_tbl)
  IS
  BEGIN
    IF p_ii_rltns_tbl.COUNT > 0 THEN
      FOR l_ind IN p_ii_rltns_tbl.FIRST .. p_ii_rltns_tbl.LAST
      LOOP
        dump_csi_ii_rltns_rec(p_ii_rltns_tbl(l_ind), l_ind);
      END LOOP;
    END IF;
  END dump_csi_ii_rltns_tbl;

  PROCEDURE dump_csi_config_rec(
    p_config_rec  IN csi_cz_int.config_rec)
  IS
    l_rec csi_cz_int.config_rec;
  BEGIN
    l_rec := p_config_rec;

    add('csi_cz_int.config_rec :');
      add('config_inst_hdr_id      :'||l_rec.config_inst_hdr_id);
      add('config_inst_item_id     :'||l_rec.config_inst_item_id);
      add('config_inst_rev_num     :'||l_rec.config_inst_rev_num);
      add('lock_status             :'||l_rec.lock_status);
    IF g_debug_level > 10 THEN
      add('source_application_id   :'||l_rec.source_application_id);
      add('source_txn_header_ref   :'||l_rec.source_txn_header_ref);
      add('source_txn_line_ref1    :'||l_rec.source_txn_line_ref1);
      add('source_txn_line_ref2    :'||l_rec.source_txn_line_ref2);
      add('source_txn_line_ref3    :'||l_rec.source_txn_line_ref3);
      add('instance_id             :'||l_rec.instance_id);
      add('lock_id                 :'||l_rec.lock_id);
    END IF;
  END dump_csi_config_rec;

  PROCEDURE dump_csi_config_tbl(
    p_config_tbl  IN csi_cz_int.config_tbl)
  IS
  BEGIN
    IF p_config_tbl.count > 0 THEN
      FOR l_ind IN p_config_tbl.FIRST .. p_config_tbl.LAST
      LOOP
        add('dump config_tbl. record # '||l_ind);
        dump_csi_config_rec(p_config_tbl(l_ind));
      END LOOP;
    END IF;
  END dump_csi_config_tbl;

  PROCEDURE dump_mass_edit_rec(
    p_mass_edit_rec IN csi_mass_edit_pub.mass_edit_rec)
  IS
    l_rec csi_mass_edit_pub.mass_edit_rec;
  BEGIN
    l_rec  := p_mass_edit_rec;
    add('csi_mass_edit_pub.mass_edit_rec :');
      add('   entry_id              :'||l_rec.entry_id);
      add('   name                  :'||l_rec.name);
      add('   status_code           :'||l_rec.status_code);
      add('   batch_type            :'||l_rec.batch_type);
      add('   txn_line_id           :'||l_rec.txn_line_id);
      add('   txn_line_detail_id    :'||l_rec.txn_line_detail_id);
      add('   description           :'||l_rec.description);
      add('   schedule_date         :'||l_rec.schedule_date);
      add('   start_date            :'||l_rec.start_date);
      add('   end_date              :'||l_rec.end_date);
      add('   object_version_number :'||l_rec.object_version_number);
      add('   system_cascade        :'||l_rec.system_cascade);

  END dump_mass_edit_rec;

END csi_t_gen_utility_pvt;

/
