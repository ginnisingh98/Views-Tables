--------------------------------------------------------
--  DDL for Package CSE_ASSET_MOVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_ASSET_MOVE_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEFAMVS.pls 120.6.12010000.1 2008/07/30 05:17:33 appldev ship $ */

  TYPE move_trans_rec IS RECORD (
    transaction_id               NUMBER,
    transaction_type_id          NUMBER,
    instance_id                  NUMBER,
    primary_units                NUMBER,
    serial_number                VARCHAR2(30),
    inv_material_transaction_id  NUMBER,
    source_transaction_type      VARCHAR2(30),
    inv_item_id                  NUMBER,
    inv_org_id                   NUMBER,
    shipment_number              VARCHAR2(30),
    inv_organization_id          NUMBER,
    inv_subinventory_name        VARCHAR2(10),
    location_id                  NUMBER,
    location_type_code           VARCHAR2(30),
    transaction_date             DATE,
    transaction_quantity         NUMBER,
    object_version_number        NUMBER,
    operation_status_code        VARCHAR2(30),
    instance_usage_code          VARCHAR2(30),
    source_index                 BINARY_INTEGER,
    serial_control_code          number);

  TYPE move_trans_tbl IS TABLE OF move_trans_rec INDEX BY BINARY_INTEGER ;

  TYPE txn_context IS RECORD (
    csi_txn_id             number,
    csi_txn_type_id        number,
    csi_txn_date           date,
    mtl_txn_id             number,
    mtl_txn_type_id        number,
    mtl_txn_action_id      number,
    mtl_txn_src_type_id    number,
    mtl_txn_date           date,
    mtl_txn_src_id         number,
    mtl_src_trx_line_id    number,
    mtl_xfer_txn_id        number,
    inventory_item_id      number,
    organization_id        number,
    item                   varchar2(120),
    item_description       varchar2(540),
    primary_quantity       number,
    primary_uom_code       varchar2(6),
    depreciable_flag       varchar2(1),
    src_serial_code        number,
    dst_serial_code        number,
    src_lot_code           number,
    dst_lot_code           number);

  TYPE instance_rec IS RECORD (
    csi_txn_id             number,
    csi_txn_type_id        number,
    csi_txn_date           date,
    mtl_txn_id             number,
    mtl_txn_date           date,
    mtl_txn_qty            number,
    rcv_txn_id             number,
    po_distribution_id     number,
    instance_id            number,
    quantity               number,
    inventory_item_id      number,
    organization_id        number,
    item                   varchar2(80),
    item_description       varchar2(240),
    subinventory_code      varchar2(30),
    primary_uom_code       varchar2(6),
    serial_number          varchar2(30),
    lot_number             varchar2(30),
    pa_project_id          number,
    pa_project_task_id     number,
    location_type_code     varchar2(30),
    location_id            number,
    mtl_dist_acct_id       number,
    depreciable_flag       varchar2(1),
    redeploy_flag          varchar2(1),
    group_asset_id         number,
    asset_description      varchar2(80),
    asset_unit_cost        number,
    asset_cost             number,
    asset_category_id      number,
    book_type_code         varchar2(30),
    date_placed_in_service date,
    asset_location_id      number,
    asset_key_ccid         number,
    deprn_expense_ccid     number,
    payables_ccid          number,
    tag_number             varchar2(15),
    model_number           varchar2(40),
    manufacturer_name      varchar2(30),
    employee_id            number,
    search_method          varchar2(10),
    source_txn_type        varchar2(30),
    fa_group_by            varchar2(30),
    src_dst_flag           varchar2(1));

  TYPE instance_tbl IS TABLE of instance_rec INDEX BY binary_integer;

  TYPE fa_query_rec IS RECORD(
    inventory_item_id      number,
    asset_id               number,
    asset_description      varchar2(80),
    book_type_code         varchar2(30),
    asset_category_id      number,
    date_placed_in_service date,
    serial_number          varchar2(80),
    model_number           varchar2(30),
    tag_nuber              varchar2(30),
    manufacturer_name      varchar2(30),
    asset_key_ccid         number,
    search_method          varchar2(10));

  TYPE fixed_asset_rec IS RECORD(
    asset_id               number,
    asset_number           varchar2(30),
    asset_category_id      number,
    asset_key_ccid         number,
    tag_number             varchar2(30),
    asset_description      varchar2(240),
    manufacturer_name      varchar2(30),
    serial_number          varchar2(80),
    model_number           varchar2(80),
    current_units          number,
    book_type_code         varchar2(30),
    date_placed_in_service date,
    asset_cost             number,
    mass_addition_id       number,
    feeder_system_name     varchar2(40),
    reviewer_comments      varchar2(240),
    instance_asset_id      number);

  TYPE fixed_asset_tbl IS TABLE of fixed_asset_rec INDEX BY binary_integer;

  PROCEDURE process_move_transactions(
    x_retcode              OUT NOCOPY VARCHAR2,
    x_errbuf               OUT NOCOPY VARCHAR2,
    p_inventory_item_id    IN  NUMBER DEFAULT NULL);

END cse_asset_move_pkg ;

/
