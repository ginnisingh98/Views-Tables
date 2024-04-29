--------------------------------------------------------
--  DDL for Package CSI_T_GEN_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_GEN_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: csivtgus.pls 120.3 2005/06/28 18:34:57 brmanesh noship $*/

  g_dir           varchar2(255) :=
                  nvl(fnd_profile.value('CSI_LOGFILE_PATH'), '/tmp');

  g_file          varchar2(255) := null;

  g_file_ptr      utl_file.file_type;
  g_debug         varchar2(1)    := fnd_api.g_false;

  g_debug_level   number := to_number(nvl(
                  fnd_profile.value('CSI_DEBUG_LEVEL'), '0'));

  PROCEDURE build_file_name(
    p_file_segment1  IN varchar2,
    p_file_segment2  IN varchar2,
    p_file_segment3  IN varchar2 default 'csi');

  PROCEDURE set_debug_on;
  PROCEDURE set_debug_off;
  FUNCTION  is_debug_on return boolean;
  PROCEDURE add (p_debug_msg in varchar2);

  PROCEDURE dump_api_info(
    p_pkg_name  IN varchar2,
    p_api_name  IN varchar2,
    p_indent    IN number default 0);

  PROCEDURE dump_error_stack;

  FUNCTION  dump_error_stack RETURN varchar2;

  PROCEDURE dump_txn_systems_rec (
    p_txn_systems_rec in csi_t_datastructures_grp.txn_system_rec);

  PROCEDURE dump_txn_line_rec(
    p_txn_line_rec in csi_t_datastructures_grp.txn_line_rec);

  PROCEDURE dump_line_detail_rec(
    p_line_detail_rec in csi_t_datastructures_grp.txn_line_detail_rec);

  PROCEDURE dump_party_detail_rec(
    p_party_detail_rec in csi_t_datastructures_grp.txn_party_detail_rec );

  PROCEDURE dump_pty_acct_rec(
    p_pty_acct_rec in csi_t_datastructures_grp.txn_pty_acct_detail_rec);

  PROCEDURE dump_ii_rltns_rec(
    p_ii_rltns_rec in csi_t_datastructures_grp.txn_ii_rltns_rec);

  PROCEDURE dump_org_assgn_rec(
    p_org_assgn_rec in csi_t_datastructures_grp.txn_org_assgn_rec);

  PROCEDURE dump_txn_eav_rec(
    p_txn_eav_rec in csi_t_datastructures_grp.txn_ext_attrib_vals_rec);

  PROCEDURE dump_csi_ea_rec(
    p_csi_ea_rec in csi_t_datastructures_grp.csi_ext_attribs_rec);

  PROCEDURE dump_csi_eav_rec (
    p_csi_eav_rec in csi_t_datastructures_grp.csi_ext_attrib_vals_rec);

  PROCEDURE dump_line_detail_ids_rec(
    p_line_detail_ids_rec in csi_t_datastructures_grp.txn_line_detail_ids_rec);

  PROCEDURE dump_party_detail_ids_rec(
    p_party_detail_ids_rec in csi_t_datastructures_grp.txn_party_ids_rec );

  PROCEDURE dump_pty_acct_ids_rec(
    p_pty_acct_rec in csi_t_datastructures_grp.txn_pty_acct_ids_rec);

  PROCEDURE dump_ii_rltns_ids_rec(
    p_ii_rltns_ids_rec in csi_t_datastructures_grp.txn_ii_rltns_ids_rec);

  PROCEDURE dump_oa_ids_rec(
    p_oa_ids_rec in  csi_t_datastructures_grp.txn_org_assgn_ids_rec);

  PROCEDURE dump_txn_ea_ids_rec(
    p_txn_ea_ids_rec in csi_t_datastructures_grp.txn_ext_attrib_ids_rec);

  PROCEDURE dump_txn_source_rec(
     p_txn_source_rec in csi_t_ui_pvt.txn_source_rec);

  PROCEDURE dump_txn_line_query_rec(
    p_txn_line_query_rec in csi_t_datastructures_grp.txn_line_query_rec);

  PROCEDURE dump_txn_line_detail_query_rec(
    p_txn_line_detail_query_rec in csi_t_datastructures_grp.txn_line_detail_query_rec);

  PROCEDURE dump_csi_instance_rec(
    p_csi_instance_rec in csi_datastructures_pub.instance_rec);

  PROCEDURE dump_csi_instance_tbl(
    p_instance_tbl  in csi_datastructures_pub.instance_tbl);

  PROCEDURE dump_txn_tables(
    p_ids_or_index_based IN varchar2,
    p_line_detail_tbl    IN csi_t_datastructures_grp.txn_line_detail_tbl,
    p_party_detail_tbl   IN csi_t_datastructures_grp.txn_party_detail_tbl,
    p_pty_acct_tbl       IN csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_ii_rltns_tbl       IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_org_assgn_tbl      IN csi_t_datastructures_grp.txn_org_assgn_tbl,
    p_ea_vals_tbl        IN csi_t_datastructures_grp.txn_ext_attrib_vals_tbl);

  PROCEDURE dump_txn_source_param_rec(
    p_txn_source_param_rec csi_t_ui_pvt.txn_source_param_rec);

  PROCEDURE dump_txn_instance_rec(
    p_txn_instance_rec    IN  csi_process_txn_grp.txn_instance_rec);

  PROCEDURE dump_dest_location_rec(
    p_dest_location_rec   IN csi_process_txn_grp.dest_location_rec);

  PROCEDURE dump_txn_i_party_rec(
    p_txn_i_party_rec     IN csi_process_txn_grp.txn_i_party_rec);

  PROCEDURE dump_txn_ip_account_rec(
    p_txn_ip_account_rec  IN csi_process_txn_grp.txn_ip_account_rec);

  PROCEDURE dump_txn_ii_rltns_rec(
    p_txn_ii_rltns_rec    IN csi_process_txn_grp.txn_ii_relationship_rec);

  PROCEDURE dump_txn_eav_rec(
    p_txn_eav_rec         IN csi_process_txn_grp.txn_ext_attrib_value_rec);

  PROCEDURE dump_txn_price_rec(
    p_txn_price_rec       IN csi_process_txn_grp.txn_pricing_attrib_rec);

  PROCEDURE dump_txn_org_unit_rec(
    p_txn_org_unit_rec    IN csi_process_txn_grp.txn_org_unit_rec);

  PROCEDURE dump_txn_asset_rec(
    p_txn_asset_rec       IN csi_process_txn_grp.txn_instance_asset_rec);

  PROCEDURE dump_instance_query_rec(
    p_instance_query_rec  IN csi_datastructures_pub.instance_query_rec);

  PROCEDURE dump_csi_party_rec(
    p_party_rec   csi_datastructures_pub.party_rec);

  PROCEDURE dump_csi_party_tbl(
    p_party_tbl    csi_datastructures_pub.party_tbl);

  PROCEDURE dump_csi_account_rec(
    p_party_account_rec   IN csi_datastructures_pub.party_account_rec);

  PROCEDURE dump_csi_account_tbl(
    p_party_account_tbl   IN csi_datastructures_pub.party_account_tbl);

  PROCEDURE dump_eav_rec(
    p_eav_rec  IN csi_datastructures_pub.extend_attrib_values_rec);

  PROCEDURE dump_eav_tbl(
    p_eav_tbl  IN csi_datastructures_pub.extend_attrib_values_tbl);

  PROCEDURE dump_csi_ii_rltns_rec(
    p_ii_rltns_rec IN csi_datastructures_pub.ii_relationship_rec,
    p_rec_index    IN number default 1);

  PROCEDURE dump_csi_ii_rltns_tbl(
    p_ii_rltns_tbl IN csi_datastructures_pub.ii_relationship_tbl);

  PROCEDURE dump_csi_config_rec(
    p_config_rec IN csi_cz_int.config_rec);

  PROCEDURE dump_csi_config_tbl(
    p_config_tbl IN csi_cz_int.config_tbl);

  PROCEDURE dump_mass_edit_rec(
    p_mass_edit_rec IN csi_mass_edit_pub.mass_edit_rec);

END csi_t_gen_utility_pvt;

 

/
