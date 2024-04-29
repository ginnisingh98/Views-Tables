--------------------------------------------------------
--  DDL for Package CSI_FA_INSTANCE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_FA_INSTANCE_GRP" AUTHID CURRENT_USER AS
/* $Header: csigfais.pls 120.3 2005/07/05 18:24:12 brmanesh noship $ */

  g_pkg_name                constant varchar2(30) := 'csi_fa_instance_grp';

  TYPE fixed_asset_rec IS RECORD (
    asset_id                   number,
    book_type_code             varchar2(15),
    asset_location_id          number,
    asset_quantity             number,
    fa_sync_flag               varchar2(1),
    fa_sync_validation_reqd    varchar2(1));

  TYPE eam_rec IS RECORD (
    category_id                number,
    asset_criticality_code     varchar2(30),
    owning_department_id       number,
    wip_accounting_class_code  varchar2(10),
    area_id                    number,
    parent_instance_id         number);

  TYPE instance_serial_rec IS RECORD (
    instance_number            varchar2(30),
    serial_number              varchar2(30),
    lot_number                 varchar2(30),
    external_reference         varchar2(30),
    instance_usage_code        varchar2(30),
    instance_description       varchar2(240),
    operational_status_code    varchar2(30));

  TYPE instance_serial_tbl IS TABLE of instance_serial_rec INDEX BY binary_integer;

  PROCEDURE create_item_instance(
    p_fixed_asset_rec          IN     fixed_asset_rec,
    p_eam_rec                  IN     eam_rec,
    p_instance_rec             IN     csi_datastructures_pub.instance_rec,
    p_instance_serial_tbl      IN     instance_serial_tbl,
    p_party_tbl                IN     csi_datastructures_pub.party_tbl,
    p_party_account_tbl        IN     csi_datastructures_pub.party_account_tbl,
    px_csi_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_instance_tbl                OUT nocopy csi_datastructures_pub.instance_tbl,
    x_instance_asset_tbl          OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    x_return_status               OUT nocopy varchar2,
    x_error_message               OUT nocopy varchar2);

  PROCEDURE copy_item_instance(
    p_fixed_asset_rec          IN     fixed_asset_rec,
    p_instance_rec             IN     csi_datastructures_pub.instance_rec,
    p_instance_serial_tbl      IN     instance_serial_tbl,
    p_eam_rec                  IN     eam_rec,
    p_copy_parties             IN     varchar2,
    p_copy_accounts            IN     varchar2,
    p_copy_contacts            IN     varchar2,
    p_copy_org_assignments     IN     varchar2,
    p_copy_asset_assignments   IN     varchar2,
    p_copy_pricing_attribs     IN     varchar2,
    p_copy_ext_attribs         IN     varchar2,
    p_copy_inst_children       IN     varchar2,
    px_csi_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_instance_tbl                OUT nocopy csi_datastructures_pub.instance_tbl,
    x_instance_asset_tbl          OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    x_return_status               OUT nocopy varchar2,
    x_error_message               OUT nocopy varchar2);

  PROCEDURE associate_item_instance(
    p_fixed_asset_rec          IN     fixed_asset_rec,
    p_instance_tbl             IN     csi_datastructures_pub.instance_tbl,
    px_csi_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_instance_asset_tbl          OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    x_return_status               OUT nocopy varchar2,
    x_error_message               OUT nocopy varchar2);

  PROCEDURE update_asset_association(
    p_instance_asset_tbl       IN     csi_datastructures_pub.instance_asset_tbl,
    px_csi_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status               OUT nocopy varchar2,
    x_error_message               OUT nocopy varchar2);

  PROCEDURE create_instance_assets (
    px_instance_asset_tbl      IN OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    px_csi_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_return_status               OUT nocopy varchar2,
    x_error_message               OUT nocopy varchar2);

END csi_fa_instance_grp;

 

/
