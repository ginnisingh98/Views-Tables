--------------------------------------------------------
--  DDL for Package CSI_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: csipitxs.pls 120.3.12010000.2 2008/09/19 18:32:27 rsinn ship $ */

  g_om_source_table        constant varchar2(30) := 'OE_ORDER_LINES_ALL';
  g_cz_source_table        constant varchar2(30) := 'CONFIGURATOR';
  g_oke_source_table       constant varchar2(30) := 'WSH_DELIVERY_DETAILS';
  g_ship_source_table      constant varchar2(30) := 'WSH_DELIVERY_DETAILS';

  g_om_txn_type_id         constant number       := 51;
  g_rma_txn_type_id        constant number       := 53;
  g_oke_txn_type_id        constant number       := 326;
  g_macd_txn_type_id       constant number       := 401; --Added for bug 5194812

  TYPE source_header_rec IS RECORD(
    source_header_id         number,
    source_header_ref        varchar2(30),
    org_id                   number,
    sold_from_org_id         number,
    owner_party_account_id   number,
    agreement_id             number,
    ship_to_address_id       number,
    bill_to_address_id       number,
    ship_to_contact_id       number,
    bill_to_contact_id       number,
    cust_po_number           varchar2(50),
    -- For partner ordering
    sold_to_org_id           number,
    deliver_to_org_id        number);


  TYPE source_line_rec IS RECORD(
    source_table             varchar2(80),
    source_line_id           number,
    source_line_ref          varchar2(30),
    org_id                   number,
    sold_from_org_id         number,
    inventory_item_id        number,
    organization_id          number,
    item_revision            varchar2(3),
    uom_code                 varchar2(3),
    source_quantity          number,
    shipped_quantity         number,
    shipped_date             date,
    fulfilled_quantity       number,
    fulfilled_date           date,
    owner_party_id           number,
    owner_party_account_id   number,
    ship_to_address_id       number,
    bill_to_address_id       number,
    ship_to_party_site_id    number,
    agreement_id             number,
    ship_to_contact_id       number,
    ship_to_contact_party_id number,
    bill_to_contact_id       number,
    bill_to_contact_party_id number,
    link_to_line_id          number,
    top_model_line_id        number,
    ato_line_id              number,
    item_type_code           varchar2(30),
    cust_po_number           varchar2(50),
    config_header_id         number,
    config_rev_num           number,
    config_item_id           number,
    batch_validate_flag      varchar2(1),
    -- For partner ordering
    sold_to_org_id           number,
    deliver_to_org_id        number,
    ib_current_loc           varchar2(60),
    ib_current_loc_id        number,
    ib_install_loc           varchar2(60),
    ib_install_loc_id        number,
    install_to_party_site_id number);

  TYPE source_line_tbl IS TABLE OF source_line_rec INDEX BY BINARY_INTEGER;

  PROCEDURE get_source_info(
    p_source_table         IN  varchar2,
    p_source_id            IN  number,
    x_source_header_rec    OUT NOCOPY source_header_rec,
    x_source_line_rec      OUT NOCOPY source_line_rec,
    x_return_status        OUT NOCOPY varchar);

  TYPE item_attributes_rec IS RECORD(
    serial_control_code      number,
    lot_control_code         number,
    locator_control_code     number,
    revision_control_code    number,
    ib_trackable_flag        varchar2(1),
    shippable_flag           varchar2(1),
    inv_item_flag            varchar2(1),
    stockable_flag           varchar2(1),
    bom_item_type            number,
    pick_components_flag     varchar2(1),
    primary_uom_code         varchar2(8),
    ato_item_flag            varchar2(1),
    model_item_id            number,
    ib_item_instance_class   varchar2(30),
    config_model_type        varchar2(30),
    negative_balances_code   number);

  PROCEDURE get_item_attributes(
    p_inventory_item_id    IN     number,
    p_organization_id      IN     number,
    x_item_attrib_rec         OUT NOCOPY item_attributes_rec,
    x_return_status           OUT NOCOPY varchar2);


  /* ------------------------------------------------------------------- */
  /* use the source information and build a default transaction detail  */
  /* ------------------------------------------------------------------- */

  -- this routine also splits the txn_line_detail based on the srl cntrl flag
  -- and also based on the parent/child ratio so that the instance are
  -- based on the number of txn line detail records

  -- also cascades the transaction details from its parent having txn details

  PROCEDURE build_default_txn_detail(
    p_source_table         IN     varchar2,
    p_source_id            IN     number,
    p_source_header_rec    IN     source_header_rec,
    p_source_line_rec      IN     source_line_rec,
    p_csi_txn_rec          IN     csi_datastructures_pub.transaction_rec,
    px_txn_line_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    x_txn_line_detail_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_party_tbl           OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_party_acct_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_org_assgn_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_pricing_attribs_tbl     OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status           OUT NOCOPY varchar2);


  /* ------------------------------------------------------------------- */
  /* this routine is to rebuild the user entered transaction detail with */
  /* the addition of all the defaults like contacts, org assignments etc.*/
  /* ------------------------------------------------------------------- */

  -- rebuild also splits the transaction detail bases on the serial control
  -- flag or the based on the parent/child ratios.

  -- for shipping we might want to pass the mtl_txn_table based on which we should
  -- re-build the txn detail table

  PROCEDURE rebuild_txn_detail(
    p_source_table         IN     varchar2,
    p_source_id            IN     number,
    p_source_header_rec    IN     source_header_rec,
    p_source_line_rec      IN     source_line_rec,
    p_csi_txn_rec          IN     csi_datastructures_pub.transaction_rec,
    px_txn_line_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_txn_line_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_party_acct_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_org_assgn_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_pricing_attribs_tbl     OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status           OUT NOCOPY varchar2);


  PROCEDURE get_cz_txn_details(
    p_config_session_key   IN  csi_utility_grp.config_session_key,
    x_txn_line_rec         OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    x_txn_line_dtl_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_party_tbl        OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_party_acct_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_org_assgn_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_txn_ii_rltns_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_eav_tbl          OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status        OUT NOCOPY varchar2);

  PROCEDURE get_config_keys_for_order(
    p_header_id            IN  number,
    x_config_session_keys  OUT NOCOPY csi_utility_grp.config_session_keys,
    x_return_status        OUT NOCOPY varchar2);

  PROCEDURE get_cz_relations(
    p_source_header_rec    IN  source_header_rec,
    p_source_line_rec      IN  source_line_rec,
    px_txn_line_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_ii_rltns_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_eav_tbl          OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status        OUT NOCOPY varchar2);

  /* this routine takes the source line info and the current entered source txn
     line detail info and builds the non source relation based on the source table
     information

       . if it is for the config line then it would read the config txn detail to read
         the relationship and builds them to the corresponding source line detail
         entered in the order line level

       . if it is for the fulfillment/shipment then it reads the parent and child
         information from the order line and builds the parent and the child relation
         for the current order line being processed

   */

  PROCEDURE get_relations(
    p_source_id            IN     number,
    p_source_table         IN     varchar2,
    p_source_header_rec    IN     source_header_rec,
    p_source_line_rec      IN     source_line_rec,
    px_txn_line_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_ii_rltns_tbl        OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_eav_tbl             OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status           OUT NOCOPY varchar2);

  PROCEDURE get_extended_attrib_values(
    p_source_id            IN     number,
    p_source_table         IN     varchar2,
    p_source_header_rec    IN     source_header_rec,
    p_source_line_rec      IN     source_line_rec,
    px_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_eav_tbl             OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status           OUT NOCOPY varchar2);

  PROCEDURE get_order_line_source_info(
    p_order_line_id           IN  number,
    x_source_header_rec       OUT NOCOPY source_header_rec,
    x_source_line_rec         OUT NOCOPY source_line_rec,
    x_return_status           OUT NOCOPY varchar2);

  PROCEDURE dump_instance_key(
    p_instance_key            IN  csi_utility_grp.config_instance_key);

  PROCEDURE dump_instance_keys(
    p_instance_keys           IN  csi_utility_grp.config_instance_keys);

  /*
  PROCEDURE dump_instance_keys(
    p_instance_keys           IN  csi_utility_grp.config_instance_keys)
  IS
    l_rec    csi_utility_grp.config_instance_key;
  BEGIN
    IF p_instance_keys.COUNT > 0 THEN
      FOR l_ind IN p_instance_keys.FIRST .. p_instance_keys.LAST
      LOOP
        l_rec := p_instance_keys(l_ind);
        csi_t_gen_utility_pvt.add('Instance rec: #'||l_ind);
        csi_t_gen_utility_pvt.add('  inst_hdr_id              :'||l_rec.inst_hdr_id
        csi_t_gen_utility_pvt.add('  inst_item_id             :'||l_rec.inst_item_id
        csi_t_gen_utility_pvt.add('  inst_rev_num             :'||l_rec.inst_rev_num
        csi_t_gen_utility_pvt.add('  inst_baseline_rev_num    :'||l_rec.inst_baseline_rev_num
      END LOOP;
    END IF;
  END dump_instance_keys;
  */

  PROCEDURE interface_ib(
    p_source_header_rec    IN     csi_interface_pkg.source_header_rec,
    p_source_line_rec      IN     csi_interface_pkg.source_line_rec,
    px_csi_txn_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    px_txn_line_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_party_acct_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_org_assgn_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_eav_tbl         IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_ii_rltns_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_pricing_attribs_tbl IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status           OUT NOCOPY varchar2,
    x_return_message          OUT NOCOPY varchar2);

  FUNCTION check_MACD_processing(
    p_config_session_key      IN csi_utility_grp.config_session_key,
    x_return_status           OUT NOCOPY varchar2)
  RETURN boolean;

  TYPE mtl_txn_rec IS RECORD(
    trx_source_line_id       number,
    inventory_item_id        number,
    organization_id          number,
    revision                 varchar2(30),
    subinventory_code        varchar2(80),
    locator_id               number,
    lot_number               varchar2(80),
    serial_number            varchar2(80),
    transaction_quantity     number,
    transaction_uom          varchar2(3),
    transaction_date         date,
    lot_control_code         number,
    serial_control_code      number,
    primary_uom              varchar2(3),
    primary_quantity         number,
    transaction_type_id      number,
    transaction_action_id    number,
    src_serial_flag          varchar2(1),
    dest_serial_flag         varchar2(1),
    create_update_flag       varchar2(1),
    match_flag               varchar2(1) := 'N',
    instance_id              number,
    negative_instance_flag   varchar2(1) := 'N',
    object_version_num       number);

  TYPE mtl_txn_tbl IS TABLE OF mtl_txn_rec INDEX BY BINARY_INTEGER;

  PROCEDURE process_cz_txn_details(
    p_config_session_keys  IN  csi_utility_grp.config_session_keys,
    p_instance_id          IN  number,
    x_instance_tbl         OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status        OUT NOCOPY varchar2);

  -- following routines are for processing mtl transactions

  PROCEDURE get_mtl_txn_tbl(
    p_mtl_txn_id    IN  number,
    x_mtl_txn_tbl   OUT NOCOPY mtl_txn_tbl,
    x_return_status OUT NOCOPY varchar2);

  PROCEDURE pre_process_mtl_txn_tbl(
    p_item_attrib_rec IN     item_attributes_rec,
    px_mtl_txn_tbl    IN OUT NOCOPY mtl_txn_tbl,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE get_inventory_instances(
    p_item_attrib_rec IN     item_attributes_rec,
    px_mtl_txn_tbl    IN OUT NOCOPY mtl_txn_tbl,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE decrement_inventory_instances(
    p_item_attrib_rec IN     item_attributes_rec,
    p_mtl_txn_tbl     IN OUT NOCOPY mtl_txn_tbl,
    px_txn_rec        IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE sync_txn_dtl_and_mtl_txn(
    p_mtl_txn_tbl         IN     mtl_txn_tbl,
    p_item_attrib_rec     IN     item_attributes_rec,
    px_txn_line_dtl_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_dtl_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_party_acct_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_org_assgn_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_eav_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_ii_rltns_tbl   IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status          OUT NOCOPY varchar2);

  FUNCTION check_standard_bom_pc(
    p_instance_id         IN NUMBER,
    p_std_item_rec        IN csi_datastructures_pub.instance_rec,
    p_bom_item_type       IN NUMBER)
  RETURN  boolean;

  PROCEDURE build_relationship_tbl(
    p_txn_ii_rltns_tbl  IN    csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_txn_line_dtl_tbl  IN    csi_t_datastructures_grp.txn_line_detail_tbl,
    x_c_ii_rltns_tbl    OUT NOCOPY   csi_datastructures_pub.ii_relationship_tbl,
    x_u_ii_rltns_tbl    OUT NOCOPY   csi_datastructures_pub.ii_relationship_tbl,
    x_return_status     OUT NOCOPY   varchar2);

END csi_interface_pkg;

/
