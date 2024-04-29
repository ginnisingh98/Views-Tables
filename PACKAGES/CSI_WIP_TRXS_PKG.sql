--------------------------------------------------------
--  DDL for Package CSI_WIP_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_WIP_TRXS_PKG" AUTHID CURRENT_USER AS
/* $Header: csipiwps.pls 120.6.12010000.1 2008/07/25 08:11:35 appldev ship $ */

  g_pkg_name  varchar2(30) := 'csi_wip_trxs_pkg';
  g_api_name  varchar2(80) := 'csi_wip_trxs_pkg';

  TYPE txn_ref IS RECORD (
    transaction_id                  number       := fnd_api.g_miss_num,
    transaction_date                date         := fnd_api.g_miss_date,
    creation_date                   date         := fnd_api.g_miss_date,
    transaction_type_id             number       := fnd_api.g_miss_num,
    transaction_source_type_id      number       := fnd_api.g_miss_num,
    transaction_action_id           number       := fnd_api.g_miss_num,
    inventory_item_id               number       := fnd_api.g_miss_num,
    organization_id                 number       := fnd_api.g_miss_num,
    primary_quantity                number       := fnd_api.g_miss_num,
    master_organization_id          number       := fnd_api.g_miss_num,
    item                            varchar2(40) := fnd_api.g_miss_char,
    primary_uom_code                varchar2(3)  := fnd_api.g_miss_char,
    srl_control_code                number       := fnd_api.g_miss_num,
    lot_control_code                number       := fnd_api.g_miss_num,
    rev_control_code                number       := fnd_api.g_miss_num,
    loc_control_code                number       := fnd_api.g_miss_num,
    ib_trackable_flag               varchar2(1)  := fnd_api.g_miss_char,
    eam_item_type                   number       := fnd_api.g_miss_num,
    bom_item_type                   number       := fnd_api.g_miss_num,
    wip_entity_id                   number       := fnd_api.g_miss_num,
    wip_entity_name                 varchar2(30) := fnd_api.g_miss_char,
    wip_entity_type                 number       := fnd_api.g_miss_num,
    wip_job_type                    number       := fnd_api.g_miss_num,
    wip_status_type                 number       := fnd_api.g_miss_num,
    wip_assembly_item_id            number       := fnd_api.g_miss_num,
    wip_start_quantity              number       := fnd_api.g_miss_num,
    wip_completed_quantity          number       := fnd_api.g_miss_num,
    wip_maint_source_code           number       := fnd_api.g_miss_num,
    wip_source_line_id              number       := fnd_api.g_miss_num,
    wip_source_code                 varchar2(30) := fnd_api.g_miss_char,
    wip_maint_obj_type              number       := fnd_api.g_miss_num,
    wip_maint_obj_id                number       := fnd_api.g_miss_num);

  TYPE mmt_rec IS RECORD (
    inventory_item_id               number       := fnd_api.g_miss_num,
    organization_id                 number       := fnd_api.g_miss_num,
    subinventory_code               varchar2(10) := fnd_api.g_miss_char,
    revision                        varchar2(3)  := fnd_api.g_miss_char,
    transaction_source_id           number       := fnd_api.g_miss_num,
    transaction_set_id              number       := fnd_api.g_miss_num, --bug 5376024
    transaction_date                date         := fnd_api.g_miss_date,
    transaction_quantity            number       := fnd_api.g_miss_num,
    transaction_uom                 varchar2(3)  := fnd_api.g_miss_char,
    locator_id                      number       := fnd_api.g_miss_num,
    serial_number                   varchar2(30) := fnd_api.g_miss_char,
    lot_number                      varchar2(80) := fnd_api.g_miss_char,
    subinv_location_id              number       := fnd_api.g_miss_num,
    hr_location_id                  number       := fnd_api.g_miss_num,
    mmt_primary_quantity            number       := fnd_api.g_miss_num,
    lot_primary_quantity            number       := fnd_api.g_miss_num,
    instance_quantity               number       := fnd_api.g_miss_num);

  TYPE mmt_tbl IS TABLE OF mmt_rec INDEX BY binary_integer;

  TYPE requirements_rec IS RECORD(
    wip_entity_id                   number,
    inventory_item_id               number,
    organization_Id                 number,
    required_quantity               number,
    issued_quantity                 number,
    quantity_per_assy               number);

  TYPE requirements_tbl IS TABLE OF requirements_rec INDEX by binary_integer;

  TYPE issues_rec IS RECORD (
    instance_id                     number,
    inventory_item_id               number,
    organization_id                 number,
    subinventory_code               varchar2(30),
    locator_id                      number,
    item_revision                   varchar2(3),
    lot_number                      varchar2(80),
    serial_number                   varchar2(30),
    quantity                        number,
    owner_party_id                  number);

  TYPE issues_tbl IS TABLE of issues_rec INDEX by binary_integer;

  TYPE assy_comp_map_rec IS RECORD (
    assy_instance_id                number,
    comp_instance_id                number,
    comp_quantity                   number);

  TYPE assy_comp_map_tbl IS TABLE of assy_comp_map_rec INDEX by binary_integer;

  PROCEDURE wip_comp_issue(
    p_transaction_id         IN            number,
    p_message_id             IN            number,
    px_trx_error_rec         IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status             OUT nocopy varchar2);

  PROCEDURE wip_comp_receipt(
    p_transaction_id         IN            number,
    p_message_id             IN            number,
    px_trx_error_rec         IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status             OUT nocopy varchar2);

  PROCEDURE wip_assy_completion(
    p_transaction_id         IN            number,
    p_message_id             IN            number,
    px_trx_error_rec         IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status             OUT nocopy varchar2);


   PROCEDURE wip_byproduct_completion(
    p_transaction_id         IN            number,
    p_message_id             IN            number,
    px_trx_error_rec         IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status             OUT nocopy varchar2);

   PROCEDURE wip_byproduct_return(
    p_transaction_id         IN            number,
    p_message_id             IN            number,
    px_trx_error_rec         IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status             OUT nocopy varchar2);



  PROCEDURE wip_assy_return(
    p_transaction_id         IN            number,
    p_message_id             IN            number,
    px_trx_error_rec         IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status             OUT nocopy varchar2);

  PROCEDURE wip_neg_comp_return(
    p_transaction_id         IN            number,
    p_message_id             IN            number,
    px_trx_error_rec         IN OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status             OUT nocopy varchar2);

  PROCEDURE process_manual_rltns(
    p_wip_entity_id          IN            number,
    x_return_status             OUT nocopy varchar2,
    x_error_message             OUT nocopy varchar2);

  PROCEDURE eam_wip_completion(
    p_wip_entity_id    IN number,
    p_organization_id  IN number,
    px_trx_error_rec   OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status    OUT nocopy varchar2);

  PROCEDURE eam_rebuildable_return(
    p_wip_entity_id    IN number,
    p_organization_id  IN number,
    p_instance_id      IN number,
    px_trx_error_rec   OUT nocopy csi_datastructures_pub.transaction_error_rec,
    x_return_status    OUT nocopy varchar2);

END csi_wip_trxs_pkg;

/
