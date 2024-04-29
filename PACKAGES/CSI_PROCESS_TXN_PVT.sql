--------------------------------------------------------
--  DDL for Package CSI_PROCESS_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_PROCESS_TXN_PVT" AUTHID CURRENT_USER AS
/* $Header: csivptxs.pls 120.0.12000000.1 2007/01/16 15:40:33 appldev ship $ */

  g_pkg_name           VARCHAR2(30) := 'csi_process_txn_pvt';

  TYPE item_attr_rec IS RECORD(
    SRC_SERIAL_CONTROL_FLAG      VARCHAR2(1)   := 'N',
    DST_SERIAL_CONTROL_FLAG      VARCHAR2(1)   := 'N',
    LOT_CONTROL_FLAG             VARCHAR2(1)   := 'N',
    LOCATOR_CONTROL_FLAG         VARCHAR2(1)   := 'N',
    REVISION_CONTROL_FLAG        VARCHAR2(1)   := 'N',
    IB_TRACKABLE_FLAG            VARCHAR2(1)   := 'N',
    SHIPPABLE_FLAG               VARCHAR2(1)   := 'N',
    BOM_ITEM_TYPE                VARCHAR2(30)  := fnd_api.g_miss_char,
    STOCKABLE_FLAG               VARCHAR2(1)   := 'N');


  PROCEDURE get_sub_type_rec(
    p_txn_type_id           IN  number,
    p_sub_type_id           IN  number,
    x_sub_type_rec          OUT NOCOPY csi_txn_sub_types%rowtype,
    x_return_status         OUT NOCOPY varchar2);


  PROCEDURE sub_type_validations(
    p_sub_type_rec          IN  csi_txn_sub_types%rowtype,
    p_txn_instances_tbl     IN  csi_process_txn_grp.txn_instances_tbl,
    p_txn_i_parties_tbl     IN  csi_process_txn_grp.txn_i_parties_tbl,
    x_return_status         OUT NOCOPY varchar2);


  PROCEDURE validate_dest_location_rec(
    p_in_out_flag       IN     varchar2,
    p_dest_location_rec IN OUT NOCOPY csi_process_txn_grp.dest_location_rec,
    x_return_status        OUT NOCOPY varchar2);


  PROCEDURE get_item_attributes(
    p_in_out_flag           IN  varchar2,
    p_sub_type_rec          IN  csi_txn_sub_types%rowtype,
    p_inventory_item_id     IN  number,
    p_organization_id       IN  number,
    x_item_attr_rec         OUT NOCOPY csi_process_txn_pvt.item_attr_rec,
    x_return_status         OUT NOCOPY varchar2);


  PROCEDURE get_src_instance_id(
    p_in_out_flag           IN  varchar2,
    p_sub_type_rec          IN  csi_txn_sub_types%rowtype,
    p_instance_rec          IN  csi_process_txn_grp.txn_instance_rec,
    p_dest_location_rec     IN  csi_process_txn_grp.dest_location_rec,
    p_item_attr_rec         IN  csi_process_txn_pvt.item_attr_rec,
    p_transaction_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_instance_id           OUT NOCOPY number,
    x_return_status         OUT NOCOPY varchar2);

  PROCEDURE get_dest_instance_id(
    p_in_out_flag           IN  varchar2,
    p_sub_type_rec          IN  csi_txn_sub_types%rowtype,
    p_instance_rec          IN  csi_process_txn_grp.txn_instance_rec,
    p_dest_location_rec     IN  csi_process_txn_grp.dest_location_rec,
    p_item_attr_rec         IN  csi_process_txn_pvt.item_attr_rec,
    x_instance_id           OUT NOCOPY number,
    x_return_status         OUT NOCOPY varchar2);

  PROCEDURE process_ib(
    p_in_out_flag           IN     varchar2,
    p_sub_type_rec          IN     csi_txn_sub_types%rowtype,
    p_item_attr_rec         IN     csi_process_txn_pvt.item_attr_rec,
    p_instance_index        IN     binary_integer,
    p_dest_location_rec     IN     csi_process_txn_grp.dest_location_rec,
    p_instance_rec          IN OUT NOCOPY csi_process_txn_grp.txn_instance_rec,
    p_i_parties_tbl         IN OUT NOCOPY csi_process_txn_grp.txn_i_parties_tbl,
    p_ip_accounts_tbl       IN OUT NOCOPY csi_process_txn_grp.txn_ip_accounts_tbl,
    p_ext_attrib_vals_tbl   IN OUT NOCOPY csi_process_txn_grp.txn_ext_attrib_values_tbl,
    p_pricing_attribs_tbl   IN OUT NOCOPY csi_process_txn_grp.txn_pricing_attribs_tbl,
    p_org_units_tbl         IN OUT NOCOPY csi_process_txn_grp.txn_org_units_tbl,
    p_instance_asset_tbl    IN OUT NOCOPY csi_process_txn_grp.txn_instance_asset_tbl,
    p_transaction_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    px_txn_error_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status            OUT NOCOPY varchar2);


  PROCEDURE process_relation(
    p_instances_tbl         IN     csi_process_txn_grp.txn_instances_tbl,
    p_ii_relationships_tbl  IN     csi_process_txn_grp.txn_ii_relationships_tbl,
    p_transaction_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status            OUT NOCOPY varchar2);

--  Moved the check and break routine from rma receipt pub to avoid circular dependancy introduced in that routine for bug 2373109 and also to not load rma receipt for Non RMA txns . shegde. Bug 2443204

   PROCEDURE check_and_break_relation(
    p_instance_id         IN     number,
    p_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status       OUT NOCOPY    varchar2);

  --code modification start for 3681856--
  -- exposing the unexpire instance routine for usability
  -- added new param p_call_contracts,to decide whether to notify contracts API while un-expiring

  PROCEDURE unexpire_instance(
    p_instance_id       IN  number,
    p_call_contracts      IN  varchar2 := fnd_api.g_true,
    p_transaction_rec   IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status     OUT nocopy varchar2);

END csi_process_txn_pvt;

 

/
