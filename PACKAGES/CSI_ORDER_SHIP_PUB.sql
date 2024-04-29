--------------------------------------------------------
--  DDL for Package CSI_ORDER_SHIP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ORDER_SHIP_PUB" AUTHID CURRENT_USER AS
/* $Header: csipioss.pls 120.6.12010000.2 2008/10/01 17:52:10 rsinn ship $ */


  g_pkg_name                constant varchar2(30) := 'csi_order_ship_pub';
  g_api_name                         varchar2(80) := 'order_shipment';

  g_txn_type_id                      number;
  g_dflt_sub_type_id                 number;

  /*----------------------------------------------------------*/
  /* Record Name   : model_inst_rec                           */
  /* Description   : used for keeping the txn_line_detail     */
  /*                 of the top model instance                */
  /*----------------------------------------------------------*/

  TYPE model_inst_rec is RECORD(
    parent_line_id       NUMBER         := fnd_api.g_miss_num,
    instance_id          NUMBER         := fnd_api.g_miss_num,
    rem_qty              NUMBER         := fnd_api.g_miss_num,
    txn_line_detail_id   NUMBER         := fnd_api.g_miss_num,
    process_flag         VARCHAR2(1)    := fnd_api.g_miss_char);

  TYPE model_inst_tbl is TABLE OF model_inst_rec INDEX BY BINARY_INTEGER;

  /*----------------------------------------------------------*/
  /* Record name:  MTL_TXN_REC                                */
  /* Description:  Record used for keeping the source details */
  /*               of material tansaction                     */
  /*----------------------------------------------------------*/

  TYPE MTL_TXN_REC is RECORD(
    MTL_TRANSACTION_ID        NUMBER         :=  FND_API.G_MISS_NUM,
    SOURCE_LINE_ID            NUMBER         :=  FND_API.G_MISS_NUM,
    SOURCE_HEADER_REF_ID      NUMBER         :=  FND_API.G_MISS_NUM,
    SOURCE_HEADER_REF         VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    SOURCE_LINE_REF_ID        NUMBER         :=  FND_API.G_MISS_NUM,
    SOURCE_LINE_REF           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    SOURCE_TRANSACTION_DATE   DATE           :=  FND_API.G_MISS_DATE,
    INV_MATERIAL_TRANSACTION_ID NUMBER       :=  FND_API.G_MISS_NUM );

  TYPE item_control_rec IS RECORD (
    inventory_item_id         number       := fnd_api.g_miss_num,
    organization_id           number       := fnd_api.g_miss_num,
    ib_trackable_flag         varchar2(1)  := fnd_api.g_miss_char,
    serial_control_code       number       := fnd_api.g_miss_num,
    lot_control_code          number       := fnd_api.g_miss_num,
    revision_control_code     number       := fnd_api.g_miss_num,
    locator_control_code      number       := fnd_api.g_miss_num,
    primary_uom_code          varchar2(3)  := fnd_api.g_miss_char,
    bom_item_type             number       := fnd_api.g_miss_num,
    model_item_id             number       := fnd_api.g_miss_num,
    pick_components_flag      varchar2(1)  := fnd_api.g_miss_char,
    reservable_type           number       := fnd_api.g_miss_num,
    negative_balances_code    number       := fnd_api.g_miss_num,
    shippable_flag            varchar2(1)  := fnd_api.g_miss_char,
    transactable_flag         varchar2(1)  := fnd_api.g_miss_char);

  /*-----------------------------------------------------------*/
  /* Record name:  order_shipment_rec                          */
  /* Description:  Record used for keeping the shipment details*/
  /*-----------------------------------------------------------*/

  TYPE order_shipment_rec IS RECORD(
    line_id                 NUMBER         :=  FND_API.G_MISS_NUM,
    header_id               NUMBER         :=  FND_API.G_MISS_NUM,
    txn_line_detail_id      NUMBER         :=  FND_API.G_MISS_NUM,
    orig_inst_id            NUMBER         :=  FND_API.G_MISS_NUM,
    instance_id             NUMBER         :=  FND_API.G_MISS_NUM,
    system_id               NUMBER         :=  FND_API.G_MISS_NUM,
    instance_qty            NUMBER         :=  FND_API.G_MISS_NUM,
    party_id                NUMBER         :=  FND_API.G_MISS_NUM,
    party_source_table      VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    party_account_id        NUMBER         :=  FND_API.G_MISS_NUM,
    inst_obj_version_number NUMBER         :=  FND_API.G_MISS_NUM,
    txn_dtls_qty            NUMBER         :=  FND_API.G_MISS_NUM,
    ord_line_shipped_qty    NUMBER         :=  FND_API.G_MISS_NUM,
    instance_match          VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    quantity_match          VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    -- Added this for Bug 3384668
    lot_match               VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    customer_id             NUMBER         :=  FND_API.G_MISS_NUM,
    inventory_item_id       NUMBER         :=  FND_API.G_MISS_NUM,
    organization_id         NUMBER         :=  FND_API.G_MISS_NUM,
    revision                VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    subinventory            VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    locator_id              NUMBER         :=  FND_API.G_MISS_NUM,
    lot_number              VARCHAR2(80)   :=  FND_API.G_MISS_CHAR,
    serial_number           VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    transaction_uom         VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    order_quantity_uom      VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    invoice_to_contact_id   NUMBER         :=  FND_API.G_MISS_NUM,
    invoice_to_org_id       NUMBER         :=  FND_API.G_MISS_NUM,
    line_type_id            NUMBER         :=  FND_API.G_MISS_NUM,
    ordered_quantity        NUMBER         :=  FND_API.G_MISS_NUM,
    ship_to_contact_id      NUMBER         :=  FND_API.G_MISS_NUM,
    ship_to_org_id          NUMBER         :=  FND_API.G_MISS_NUM,
    ship_from_org_id        NUMBER         :=  FND_API.G_MISS_NUM,
    sold_to_org_id          NUMBER         :=  FND_API.G_MISS_NUM,
    sold_from_org_id        NUMBER         :=  FND_API.G_MISS_NUM,
    source_line_id          NUMBER         :=  FND_API.G_MISS_NUM,
    shipped_quantity        NUMBER         :=  FND_API.G_MISS_NUM,
    ship_to_site_use_id     NUMBER         :=  FND_API.G_MISS_NUM,
    transaction_type_id     NUMBER         :=  FND_API.G_MISS_NUM,
    transaction_date        DATE           :=  FND_API.G_MISS_DATE,
    item_type_code          VARCHAR2(30)   :=  FND_API.G_MISS_CHAR,
    cust_po_number          VARCHAR2(50)   :=  FND_API.G_MISS_CHAR,
    ato_line_id             NUMBER         :=  FND_API.G_MISS_NUM,
    top_model_line_id       NUMBER         :=  FND_API.G_MISS_NUM,
    link_to_line_id         NUMBER         :=  FND_API.G_MISS_NUM,
    order_number            number         :=  fnd_api.g_miss_num,
    line_number             varchar2(30)   :=  fnd_api.g_miss_char,
    ib_owner                varchar2(30)   :=  fnd_api.g_miss_char,
    end_customer_id         NUMBER         :=  fnd_api.g_miss_num,
    deliver_to_org_id       NUMBER         :=  FND_API.G_MISS_NUM,
    ib_install_loc          VARCHAR2(60)   :=  fnd_api.g_miss_char,
    ib_install_loc_id       NUMBER         :=  fnd_api.g_miss_num,
    ib_current_loc          VARCHAR2(60)   :=  fnd_api.g_miss_char,
    ib_current_loc_id       NUMBER         :=  fnd_api.g_miss_num,
    source_code             VARCHAR2(30)   :=  fnd_api.g_miss_char); -- Added for Siebel Genesis Project

  TYPE order_shipment_tbl IS TABLE OF order_shipment_rec  INDEX BY BINARY_INTEGER;

  /*----------------------------------------------------------*/
  /* Record name:  order_line_rec                             */
  /* Description : Record used to keep the order line details */
  /*----------------------------------------------------------*/

  TYPE order_line_rec IS RECORD(
    header_id          NUMBER         :=  FND_API.G_MISS_NUM,
    order_line_id      NUMBER         :=  FND_API.G_MISS_NUM,
    om_vld_org_id      NUMBER         :=  fnd_api.g_miss_num,
    unit_price         NUMBER         :=  fnd_api.g_miss_num,
    currency_code      varchar2(15)   :=  fnd_api.g_miss_char,
    inv_item_id        NUMBER         :=  FND_API.G_MISS_NUM,
    inv_org_id         NUMBER         :=  FND_API.G_MISS_NUM,
    ordered_item       varchar2(80)   :=  fnd_api.g_miss_char,
    ordered_quantity   NUMBER         :=  FND_API.G_MISS_NUM,
    shipped_quantity   NUMBER         :=  FND_API.G_MISS_NUM,
    fulfilled_quantity NUMBER         :=  FND_API.G_MISS_NUM,
    trx_sub_type_id    NUMBER         :=  FND_API.G_MISS_NUM,
    split_ord_line_id  NUMBER         :=  FND_API.G_MISS_NUM,
    serial_code        NUMBER         :=  FND_API.G_MISS_NUM,
    internal_party_id  NUMBER         :=  FND_API.G_MISS_NUM,
    trx_line_id        NUMBER         :=  FND_API.G_MISS_NUM,
    ato_line_id        NUMBER         :=  FND_API.G_MISS_NUM,
    top_model_line_id  NUMBER         :=  FND_API.G_MISS_NUM,
    link_to_line_id    NUMBER         :=  FND_API.G_MISS_NUM,
    party_id           NUMBER         :=  FND_API.G_MISS_NUM,
    customer_id        NUMBER         :=  FND_API.G_MISS_NUM,
    invoice_to_org_id  NUMBER         :=  FND_API.G_MISS_NUM,
    ship_to_org_id     NUMBER         :=  FND_API.G_MISS_NUM,
    sold_from_org_id   NUMBER         :=  FND_API.G_MISS_NUM,
    sold_to_org_id     NUMBER         :=  FND_API.G_MISS_NUM,
    ship_to_party_site_id   NUMBER    := fnd_api.g_miss_num,
    item_type_code          VARCHAR2(30)  := FND_API.G_MISS_CHAR,
    transaction_date        DATE          := FND_API.G_MISS_DATE,
    order_quantity_uom      VARCHAR2(30)  := FND_API.G_MISS_CHAR,
    primary_uom             VARCHAR2(30)  := fnd_api.g_miss_char,
    inv_mtl_transaction_id  NUMBER     := FND_API.G_MISS_NUM ,
    ship_to_contact_id    NUMBER      := FND_API.G_MISS_NUM,
    invoice_to_contact_id NUMBER      := FND_API.G_MISS_NUM,
    agreement_id          NUMBER      := FND_API.g_MISS_NUM,
    order_number          number      := fnd_api.g_miss_num,
    line_number           varchar2(30):= fnd_api.g_miss_char,
    actual_shipment_date  DATE        := FND_API.G_MISS_DATE,
    fulfillment_date      DATE        := FND_API.G_MISS_DATE,
    org_id                NUMBER      := fnd_api.g_miss_num,
    ib_owner              varchar2(60):= fnd_api.g_miss_char,
    end_customer_id       NUMBER      := fnd_api.g_miss_num,
    deliver_to_org_id     NUMBER      := FND_API.G_MISS_NUM,
    ib_install_loc        VARCHAR2(60):= fnd_api.g_miss_char,
    ib_install_loc_id     NUMBER      := fnd_api.g_miss_num,
    ib_current_loc        VARCHAR2(60):= fnd_api.g_miss_char,
    ib_current_loc_id     NUMBER      := fnd_api.g_miss_num,
    bom_item_type         number      := fnd_api.g_miss_num,
    reservable_type       number      := fnd_api.g_miss_num,
    negative_balances_code number     := fnd_api.g_miss_num,
    mtl_action_id          number     := fnd_api.g_miss_num,
    mtl_src_type_id        number     := fnd_api.g_miss_num,
    config_header_id       number     :=  fnd_api.g_miss_num,
    config_rev_nbr         number     :=  fnd_api.g_miss_num,
    configuration_id       number     :=  fnd_api.g_miss_num,
    macd_order_line        varchar2(1):= fnd_api.g_false,
     --4344316
    model_remnant_flag     VARCHAR2(1) :=  FND_API.G_MISS_CHAR,
    source_code            VARCHAR2(30) :=  FND_API.G_MISS_CHAR -- Added for Siebel Genesis Project
    );

  /*----------------------------------------------------------*/
  /* Record name:  txn_sub_type_rec                           */
  /* Description : Record used to keep the sub type definition*/
  /*----------------------------------------------------------*/

  TYPE txn_sub_type_rec IS RECORD(
    src_chg_owner_code   VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    nsrc_chg_owner_code  VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    src_status_id        NUMBER         :=  FND_API.G_MISS_NUM ,
    nsrc_status_id       NUMBER         :=  FND_API.G_MISS_NUM ,
    src_change_owner     VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    nsrc_change_owner    VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    trx_type_id          NUMBER         :=  FND_API.G_MISS_NUM ,
    sub_type_id          NUMBER         :=  FND_API.G_MISS_NUM ,
    src_reference_reqd   VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    nsrc_reference_reqd  VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    src_return_reqd      VARCHAR2(1)    :=  FND_API.G_MISS_CHAR,
    nsrc_return_reqd     VARCHAR2(1)    :=  FND_API.G_MISS_CHAR );

  /*----------------------------------------------------------*/
  /* Procedure name: Order_shipment                           */
  /* Description   : Main Procedure that process the order    */
  /*               shipment                                   */
  /*----------------------------------------------------------*/

  PROCEDURE order_shipment(
    p_mtl_transaction_id      IN            number,
    p_message_id              IN            number,
    x_return_status              OUT NOCOPY varchar2,
    px_trx_error_rec          IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec);

  /*----------------------------------------------------------*/
  /* Procedure name:  get_order_shipment_rec                  */
  /* Description : Procedure that gets the Shipment record    */
  /*----------------------------------------------------------*/

  PROCEDURE get_order_shipment_rec(
    p_mtl_transaction_id      IN  NUMBER,
    p_order_line_rec          IN order_line_rec,
    p_txn_sub_type_rec        IN  txn_sub_type_rec,
    p_transaction_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_order_shipment_tbl      OUT NOCOPY order_shipment_tbl,
    px_error_rec              IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status           OUT NOCOPY VARCHAR2);


  /*----------------------------------------------------------*/
  /* Procedure name:  Build_SHTD_table                        */
  /* Description : Procedure used to match the shipment with  */
  /*               txn line details                           */
  /*----------------------------------------------------------*/

  PROCEDURE Build_SHTD_table(
    p_mtl_transaction_id      IN  NUMBER,
    p_order_line_rec          IN OUT NOCOPY order_line_rec,
    p_txn_sub_type_rec        IN     txn_sub_type_rec,
    p_trx_detail_exist        IN     boolean,
    p_trackable_parent        IN     boolean,
    p_transaction_rec         IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_order_shipment_tbl         OUT NOCOPY order_shipment_tbl,
    px_error_rec              IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status              OUT NOCOPY VARCHAR2);

  /*----------------------------------------------------------*/
  /* Procedure name:  Construct_for_txn_exists                */
  /* Description : Procedure that process the txn line detail */
  /*               if exists                                  */
  /*----------------------------------------------------------*/
  PROCEDURE Construct_for_txn_exists(
    p_txn_sub_type_rec        IN  txn_sub_type_rec,
    p_order_line_rec          IN order_line_rec,
    x_order_shipment_tbl      IN OUT NOCOPY order_shipment_tbl,
    x_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status           OUT NOCOPY VARCHAR2 );


  /*----------------------------------------------------------*/
  /* Procedure name:  update_install_base                     */
  /* Description   :  Procedure that updates the IB from the  */
  /*                  matched txn line details                */
  /*----------------------------------------------------------*/
  PROCEDURE update_install_base(
    p_api_version             IN NUMBER,
    p_commit                  IN VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN NUMBER   := fnd_api.g_valid_level_full,
    p_txn_line_rec            IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    p_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    p_txn_party_detail_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    p_txn_pty_acct_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    p_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    p_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_txn_systems_tbl         IN OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    p_pricing_attribs_tbl     IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    p_order_line_rec          IN order_line_rec,
    p_trx_rec                 IN csi_datastructures_pub.transaction_rec,
    p_source                  IN VARCHAR2,
    p_validate_only           IN VARCHAR2,
    px_error_rec              IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2 );

  /*----------------------------------------------------------*/
  /* Procedure name:  match_txn_with_ship                     */
  /* Description   :  Procedure used to do the matching of    */
  /*  (instance and qty) txn line details and shipment        */
  /*----------------------------------------------------------*/
  PROCEDURE match_txn_with_ship(
    p_serial_code             IN NUMBER,
    x_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_order_shipment_tbl      IN OUT NOCOPY order_shipment_tbl,
    x_return_status           OUT NOCOPY VARCHAR2 );

  /*----------------------------------------------------------*/
  /* Procedure name:  process_txn                             */
  /* Description   :  Procedure used to match the unresolved  */
  /*                  txn line details and update staus to    */
  /*                  'IN_PROCESS' so that the txn line dtls  */
  /*                  are eligible for processing             */
  /*----------------------------------------------------------*/
  PROCEDURE process_txn_dtl(
    p_serial_code             IN NUMBER,
    p_txn_sub_type_rec        IN  txn_sub_type_rec,
    p_order_line_rec          IN order_line_rec,
    x_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_ii_rltns_tbl        IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_order_shipment_tbl      IN OUT NOCOPY order_shipment_tbl,
    x_return_status           OUT NOCOPY VARCHAR2 );

  /*----------------------------------------------------------*/
  /* Procedure name:  process_option_item                     */
  /* Description : Procedure used to create the txn line      */
  /*      details if it have to be splitted in the qty ratio  */
  /*      and txn details does not exist                      */
  /*----------------------------------------------------------*/
  PROCEDURE process_option_item(
    p_serial_code             IN NUMBER,
    p_order_line_rec          IN order_line_rec,
    p_txn_sub_type_rec        IN  txn_sub_type_rec,
    p_trackable_parent        IN boolean, 	 --Added for 4548453
    x_order_shipment_tbl      IN OUT NOCOPY order_shipment_tbl,
    x_model_inst_tbl          IN OUT NOCOPY model_inst_tbl,
    x_trx_line_id             OUT NOCOPY NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2 );

  /*----------------------------------------------------------*/
  /* Procedure name:  rebuild_shipping_tbl                    */
  /* Description : Procedure used to rebuild the shipment     */
  /*        table if the item type code is config             */
  /*----------------------------------------------------------*/
  PROCEDURE rebuild_shipping_tbl(
    p_qty_ratio               IN NUMBER,
    x_order_shipment_tbl      IN OUT NOCOPY order_shipment_tbl,
    x_return_status           OUT NOCOPY VARCHAR2 );

  /*----------------------------------------------------------*/
  /* Procedure name:  validate_txn_tbl                        */
  /* Description : Procedure used to for validationg the      */
  /*   txn line details and the child tables                  */
  /*----------------------------------------------------------*/
  PROCEDURE validate_txn_tbl(
    p_txn_line_rec            IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    p_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    p_txn_party_detail_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    p_txn_pty_acct_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    p_order_line_rec          IN OUT NOCOPY order_line_rec,
    p_source                  IN VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2 );

  /*----------------------------------------------------------*/
  /* Procedure name:  DECODE_MESSAGE                          */
  /* Description : Procedure used to decode the messages      */
  /*----------------------------------------------------------*/
  PROCEDURE decode_message(
    p_msg_header      IN  XNP_MESSAGE.Msg_Header_Rec_Type,
    p_msg_text	      IN  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_error_message   OUT NOCOPY VARCHAR2,
    x_mtl_trx_rec     OUT NOCOPY MTL_TXN_REC);

  PROCEDURE oke_shipment(
    p_mtl_txn_id           IN            number,
    x_return_status           OUT NOCOPY varchar2,
    px_trx_error_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec);

  TYPE customer_product_rec IS RECORD(
    instance_id          number,
    quantity             number,
    line_id              number,
    txn_line_detail_id   number,
    transaction_id       number,
    serial_number        varchar2(80),
    lot_number           varchar2(80));

  TYPE customer_products_tbl IS TABLE of customer_product_rec INDEX BY binary_integer;

  PROCEDURE get_comp_instances_from_wip(
    p_wip_entity_id   IN     number,
    p_organization_id IN     number,
    p_cps_tbl         IN     customer_products_tbl,
    px_csi_txn_rec    IN OUT nocopy csi_datastructures_pub.transaction_rec,
    x_iir_tbl            OUT nocopy csi_datastructures_pub.ii_relationship_tbl,
    x_return_status      OUT nocopy varchar2);

END csi_order_ship_pub ;

/
