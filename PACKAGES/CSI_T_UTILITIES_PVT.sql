--------------------------------------------------------
--  DDL for Package CSI_T_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_UTILITIES_PVT" AUTHID CURRENT_USER as
/* $Header: csivtuls.pls 120.2 2006/03/16 03:22:27 srsarava noship $ */

  g_pkg_name  varchar2(30) := 'csi_t_utilities_pvt';

  TYPE txn_cascade_rec IS RECORD(
    PARENT_SOURCE_TABLE     VARCHAR2(30) := fnd_api.g_miss_char,
    PARENT_SOURCE_ID        NUMBER       := fnd_api.g_miss_num,
    CHILD_SOURCE_ID         NUMBER       := fnd_api.g_miss_num,
    ORDERED_QUANTITY        NUMBER       := fnd_api.g_miss_num, --fix for bug 5096435
    INVENTORY_ITEM_ID       NUMBER       := fnd_api.g_miss_num,
    ITEM_REVISION           VARCHAR2(30) := fnd_api.g_miss_char,
    QUANTITY_RATIO          NUMBER       := fnd_api.g_miss_num,
    ITEM_UOM                VARCHAR2(3)  := fnd_api.g_miss_char);

  TYPE txn_cascade_tbl IS TABLE OF txn_cascade_rec INDEX BY binary_integer;

  PROCEDURE build_instance_id_list(
    p_txn_line_detial_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_instance_id_list    OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE build_txn_line_id_list(
    p_txn_line_detial_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_line_id_list    OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE build_party_dtl_id_list(
    p_txn_party_detial_tbl IN  csi_t_datastructures_grp.txn_party_detail_tbl,
    x_party_dtl_id_list    OUT NOCOPY varchar2,
    x_return_status        OUT NOCOPY varchar2);

  PROCEDURE build_line_dtl_id_list(
    p_txn_line_detial_tbl IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_line_dtl_id_list    OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE build_txn_system_id_list(
    p_txn_line_detial_tbl IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_system_id_list  OUT NOCOPY varchar2,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE merge_tables(
    px_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_pty_dtl_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_pty_acct_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_ii_rltns_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_org_assgn_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_ext_attrib_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_systems_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    --
    p_line_dtl_tbl     IN csi_t_datastructures_grp.txn_line_detail_tbl,
    p_pty_dtl_tbl      IN csi_t_datastructures_grp.txn_party_detail_tbl,
    p_pty_acct_tbl     IN csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_ii_rltns_tbl     IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_org_assgn_tbl    IN csi_t_datastructures_grp.txn_org_assgn_tbl,
    p_ext_attrib_tbl   IN csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    p_txn_systems_tbl  IN csi_t_datastructures_grp.txn_systems_tbl);

  PROCEDURE convert_ids_to_index(
    px_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_pty_dtl_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_pty_acct_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_ii_rltns_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_org_assgn_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_ext_attrib_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_systems_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl);

  PROCEDURE get_source_dtls(
    p_txn_source_param_rec    IN  csi_t_ui_pvt.txn_source_param_rec,
    x_txn_source_rec          OUT NOCOPY csi_t_ui_pvt.txn_source_rec,
    x_txn_line_rec            OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    x_txn_line_detail_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_party_detail_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_pty_acct_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_org_assgn_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_return_status           OUT NOCOPY varchar2);

  PROCEDURE cascade_child(
    p_data_string      IN  varchar2,
    x_return_status    OUT NOCOPY varchar2);

  PROCEDURE cascade_model(
    p_model_line_id    IN  number,
    x_return_status    OUT NOCOPY varchar2);

  PROCEDURE cascade(
    p_txn_cascade_tbl  IN  csi_t_utilities_pvt.txn_cascade_tbl,
    x_return_status    OUT NOCOPY varchar2);

END csi_t_utilities_pvt;


 

/
