--------------------------------------------------------
--  DDL for Package CSE_ASSET_CREATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_ASSET_CREATION_PKG" AUTHID CURRENT_USER AS
-- $Header: CSEIFACS.pls 120.6.12010000.1 2008/07/30 05:17:52 appldev ship $

  g_pkg_name varchar2(30) := 'cse_asset_creation_pkg';

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
    po_header_id           number,
    po_number              varchar2(30),
    po_vendor_id           number);

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

  TYPE txn_status_rec IS RECORD(
    csi_txn_id            number,
    processed_flag        varchar2(1),
    valid_txn_flag        varchar2(1),
    error_message         varchar2(2000));

  TYPE txn_status_tbl IS TABLE of txn_status_rec INDEX by binary_integer;

  PROCEDURE create_depreciable_assets(
    errbuf                    OUT NOCOPY VARCHAR2,
    retcode                   OUT NOCOPY NUMBER,
    p_inventory_item_id    IN            NUMBER,
    p_organization_id      IN            NUMBER);

  PROCEDURE create_asset(
    p_inst_tbl          IN  instance_tbl,
    x_return_status     OUT nocopy varchar2,
    x_err_inst_rec      OUT nocopy instance_rec);

  PROCEDURE find_asset(
    p_asset_query_rec      IN OUT NOCOPY cse_datastructures_pub.asset_query_rec,
    p_distribution_tbl        OUT NOCOPY cse_datastructures_pub.distribution_tbl,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_error_msg               OUT NOCOPY VARCHAR2);

  PROCEDURE adjust_asset(
    p_asset_query_rec      IN OUT NOCOPY cse_datastructures_pub.asset_query_rec,
    p_mass_add_rec         IN OUT NOCOPY fa_mass_additions%ROWTYPE,
    p_mtl_percent          IN            NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_error_msg               OUT NOCOPY VARCHAR2);

END cse_asset_creation_pkg;

/
