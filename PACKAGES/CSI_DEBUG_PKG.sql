--------------------------------------------------------
--  DDL for Package CSI_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_DEBUG_PKG" AUTHID CURRENT_USER as
/* $Header: csidbugs.pls 120.4 2005/07/08 17:09:18 brmanesh noship $ */

  g_utl_check_done   char := 'N';

  TYPE order_line is RECORD(
    header_id              number,
    line_number            varchar2(30),
    line_id                number,
    item_id                number,
    item_number            varchar2(80),
    ship_from_org_id       number,
    order_uom              varchar2(30),
    order_qty              number,
    line_status            varchar2(30),
    item_type              varchar2(30),
    identified_item_type   varchar2(30),
    link_to_line_id        number,
    ato_line_id            number,
    top_model_line_id      number,
    ib_trackable_flag      varchar2(1),
    level                  number,
    sort_order             varchar2(240),
    sort_flag              varchar2(1) := 'N',
    org_id                 number,
    order_type_id          number,
    line_type_id           number,
    ship_to_contact_id     number,
    invoice_to_contact_id  number,
    deliver_to_contact_id  number,
    price_list_id          number,
    unit_selling_price     number,
    creation_date          date,
    comp_seq_id            number,
    line_category_code     varchar2(30),
    cancelled_flag         varchar2(1),
    source_type_code       varchar2(30),
    drop_ship_flag         varchar2(1),
    fulfilled_flag         varchar2(1),
    configuration_id       number,
    config_header_id       number,
    config_rev_nbr         number,
    shippable_flag         varchar2(1),
    fulfillment_date       date,
    shipment_date          date,
    shipped_flag           varchar2(1),
    split_from_line_id     number,
    ship_to_org_id         number,
    invoice_to_org_id      number,
    deliver_to_org_id      number,
    item_revision          varchar2(3),
    fulfilled_quantity     number,
    shipped_quantity       number,
    parent_ato_line_id     number,
    macd_flag              varchar2(1) := 'N');

  TYPE order_lines is TABLE OF order_line INDEX BY binary_integer;

  TYPE ato_model_rec IS RECORD(
    model_line_id          number,
    model_item_id          number,
    config_line_id         number,
    config_item_id         number,
    parent_ato_line_id     number,
    wip_supply_type        number,
    wip_entity_id          number,
    wip_entity_name        varchar2(30),
    organization_id        number,
    phantom_flag           varchar2(1),
    sub_model_flag         varchar2(1),
    make_buy_flag          varchar2(1));

  TYPE ato_model_tbl IS TABLE of ato_model_rec INDEX BY binary_integer;

  TYPE item_rec is RECORD(
    item_id              number,
    item                 varchar2(240),
    organization_id      number,
    primary_uom_code     varchar2(3),
    serial_code          number,
    lot_code             number,
    locator_code         number,
    revision_code        number,
    bom_item_type        number,
    shippable_flag       varchar2(1),
    reservable_type      number,
    ib_trackable_flag    varchar2(1),
    base_item_id         number,
    pick_flag            varchar2(1),
    returnable_flag      varchar2(1),
    wip_supply_type      number,
    make_buy_code        number,
    inventory_flag       varchar2(1),
    inv_transactable_flag varchar2(1));

  TYPE item_tbl is TABLE of item_rec INDEX BY binary_integer;

  TYPE mmt_rec is RECORD(
    mtl_txn_id           number,
    mtl_txn_date         date,
    item_id              number,
    organization_id      number,
    mtl_type_id          number,
    mtl_txn_name         varchar2(80),
    mtl_action_id        number,
    mtl_source_type_id   number,
    mtl_source_id        number,
    mtl_source_line_id   number,
    mtl_txn_qty          number,
    mtl_txn_uom          varchar2(30),
    mtl_pri_qty          number,
    mtl_pri_uom          varchar2(30),
    mtl_type_class       number,
    mtl_xfer_txn_id      number,
    user_defined         varchar2(1),
    status               varchar2(30),
    message_id           number,
    message_code         varchar2(30),
    message_status       varchar2(30),
    csi_txn_id           number,
    csi_txn_date         date,
    error_id             number,
    error_text           varchar2(2000));

  TYPE mmt_tbl is TABLE of mmt_rec INDEX BY binary_integer;

  TYPE mut_rec is RECORD(
    item_id              number,
    serial_number        varchar2(80),
    lot_number           varchar2(80),
    instance_id          number,
    location_type_code   varchar2(30),
    instance_usage_code  varchar2(30),
    instance_in_error    varchar2(1) := 'N');

  TYPE mut_tbl IS TABLE of mut_rec INDEX BY binary_integer;

  TYPE job_rec IS record(
    wip_entity_id        number,
    organization_id      number,
    wip_entity_name      varchar2(30),
    wip_entity_type      number,
    wip_job_status       number,
    primary_item_id      number,
    start_qty            number,
    qty_completed        number,
    qty_scrapped         number,
    over_compl_type      number,
    over_compl_value     number,
    source_code          varchar2(30),
    source_line_id       number,
    maint_obj_source     number);

  TYPE wip_req_rec IS record(
    comp_item            varchar2(240),
    comp_item_id         number,
    oper_seq_num         number,
    comp_seq_id          number,
    qty_per_assy         number,
    required_qty         number,
    qty_issued           number,
    wip_supply_type      number,
    supply_subinv        varchar2(80),
    primary_uom_code     varchar2(3),
    serial_code          number,
    lot_code             number);

  TYPE wip_req_tbl IS TABLE of wip_req_rec INDEX BY binary_integer;

  TYPE tld_rec IS record(
    transaction_line_id           number,
    txn_line_detail_id            number,
    inventory_item_id             number,
    quantity                      number,
    serial_number                 varchar2(80),
    lot_number                    varchar2(80),
    instance_id                   number,
    location_type_code            varchar2(30),
    location_id                   number,
    processing_status             varchar2(30),
    source_transaction_flag       varchar2(1),
    config_inst_baseline_rev_num  number,
    config_inst_hdr_id            number,
    config_inst_item_id           number,
    config_inst_rev_num           number);

  TYPE tld_tbl IS TABLE of tld_rec INDEX BY binary_integer;

  TYPE source_file is RECORD(
    file_name                    varchar2(30),
    integration                  varchar2(30));

  TYPE source_files IS TABLE of source_file INDEX BY binary_integer;

  TYPE instance_rec IS RECORD(
    instance_id                  number);

  TYPE instance_tbl IS TABLE of instance_rec INDEX BY binary_integer;

  PROCEDURE order_status(
    p_order_number       IN number);

  PROCEDURE job_status(
    p_job_name           IN varchar2,
    p_organization_id    IN number);

  PROCEDURE serial_status(
    p_serial_number      IN varchar2,
    p_item_id            IN number,
    p_standalone_mode    IN varchar2 := 'Y');

  PROCEDURE txn_status(
    p_mtl_txn_id         IN number);

  PROCEDURE rma_status(
    p_rma_number         IN number);

  PROCEDURE instance_status(
    p_instance_id        IN number,
    p_standalone_mode    IN varchar2 := 'Y');

  PROCEDURE diagnose(
    errbuf               OUT nocopy varchar2,
    retcode              OUT nocopy number,
    p_entity             IN varchar2,
    p_parameter1         IN varchar2,
    p_parameter2         IN varchar2);

  PROCEDURE dump_installation_details(
    p_order_lines           IN order_lines,
    p_source_table          IN varchar2 default 'OE_ORDER_LINES_ALL');

  PROCEDURE get_order_lines(
    p_order_number       IN number,
    x_order_lines        OUT nocopy order_lines);

  PROCEDURE get_ib_trackable_lines(
    px_order_lines       IN OUT nocopy order_lines);

  PROCEDURE dump_file_version(
    p_file_name          IN varchar2,
    p_subdir             IN varchar2 default 'patch/115/sql',
    p_prod_code          IN varchar2 default 'CSI');

  PROCEDURE dump_file_versions(
    p_source_files       IN source_files);

END csi_debug_pkg;

 

/
