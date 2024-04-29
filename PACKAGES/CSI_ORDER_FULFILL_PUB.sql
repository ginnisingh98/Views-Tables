--------------------------------------------------------
--  DDL for Package CSI_ORDER_FULFILL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ORDER_FULFILL_PUB" AUTHID CURRENT_USER AS
/* $Header: csipiofs.pls 120.1 2005/07/12 17:53:29 brmanesh noship $*/

  g_pkg_name           varchar2(30) := 'csi_order_fulfill_pub';

  TYPE config_rec IS RECORD(
    line_id                   number,
    item_id                   number,
    ship_organization_id      number,
    order_quantity            number,
    split_from_line_id        number,
    serial_code               number,
    make_flag                 varchar2(1), -- Y=Make else Buy
    config_wip_job_id         number,
    config_wip_org_id         number,
    request_id                number,
    sub_model_flag            varchar2(1), -- Y=order line is of a submodel
    sub_model_line_id         number,
    sub_model_wip_supply_type number,
    sub_config_item_id        number,
    sub_model_serial_code     number,
    sub_config_wip_job_id     number,
    sub_config_wip_org_id     number,
    sub_config_make_flag      varchar2(1)); -- Y=Make else Buy

  TYPE sub_type_rec IS RECORD(
    transaction_type_id       number,
    sub_type_id               number,
    src_change_owner          varchar2(1),
    src_change_owner_code     varchar2(1),
    src_status_id             number,
    src_reference_reqd        varchar2(1),
    src_return_reqd           varchar2(1),
    nsrc_change_owner         varchar2(1),
    nsrc_change_owner_code    varchar2(1),
    nsrc_status_id            number,
    nsrc_reference_reqd       varchar2(1),
    nsrc_return_reqd          varchar2(1));

  TYPE config_serial_inst_rec IS RECORD(
    serial_number             varchar2(30),
    instance_id               number,
    location_type_code        varchar2(30),
    ship_flag                 varchar2(1),
    reship_flag               varchar2(1),
    wip_config_flag           varchar2(1),
    relationship_id           number,
    relationship_ovn          number);

  TYPE config_serial_inst_tbl IS TABLE OF config_serial_inst_rec INDEX BY binary_integer;

  TYPE parent_instance IS RECORD(
    item_id                   number,
    instance_id               number,
    quantity                  number,
    serial_number             varchar2(80),
    allocated_flag            varchar2(1),
    alloc_count               number,
    relationship_id           number,
    relationship_ovn          number);

  TYPE parent_instances IS TABLE OF parent_instance INDEX BY binary_integer;

  TYPE wip_instance IS RECORD(
    instance_id               number,
    quantity                  number,
    serial_number             varchar2(80),
    location_type_code        varchar2(80),
    instance_usage_code       varchar2(80),
    allocated_flag            varchar2(1));

  TYPE wip_instances IS TABLE OF wip_instance INDEX BY binary_integer;

  TYPE parent_child_map_rec IS RECORD(
    object_tld_id             number,
    subject_tld_id            number,
    object_instance_id        number,
    subject_instance_id       number);

  TYPE parent_child_map_tbl IS TABLE OF parent_child_map_rec INDEX BY binary_integer;

  TYPE default_info_rec is RECORD(
    om_vld_org_id             number,
    sub_type_id               number,
    src_change_owner          varchar2(1),
    src_change_owner_code     varchar2(1),
    src_status_id             number,
    owner_party_acct_id       number,
    owner_party_id            number,
    current_party_site_id     number,
    install_party_site_id     number,
    identified_item_type      varchar2(30),
    ownership_cascade_at_txn  varchar2(1),
    internal_party_id         number,
    freeze_date               date,
    cascade_owner_flag        varchar2(1),
    split_flag                varchar2(1),
    ratio_split_flag          varchar2(1),
    split_ratio               number,
    transaction_line_id       number,
    primary_uom_code          varchar2(30));

  /* ---------------------------------------------------------------------- */
  /* To get the next level IB trackable OE children. This routine is used   */
  /* to identify children for building the relationships                    */
  /* ---------------------------------------------------------------------- */

  PROCEDURE get_ib_trackable_children(
    p_current_line_id      IN  number,
    p_om_vld_org_id        IN  number,
    x_trackable_line_tbl   OUT NOCOPY oe_order_pub.line_tbl_type,
    x_return_status        OUT NOCOPY varchar2);

  PROCEDURE get_all_ib_trackable_children(
    p_model_line_id        IN  number,
    p_om_vld_org_id        IN  number,
    x_trackable_line_tbl   OUT NOCOPY oe_order_pub.line_tbl_type,
    x_return_status        OUT NOCOPY varchar2);

  PROCEDURE get_ib_trackable_parent(
    p_current_line_id      IN  number,
    p_om_vld_org_id        IN  number,
    x_parent_line_rec      OUT NOCOPY oe_order_pub.line_rec_type,
    x_return_status        OUT NOCOPY varchar2);

  PROCEDURE order_fulfillment(
    p_order_line_id        IN  number,
    p_message_id           IN  number,
    x_return_status        OUT NOCOPY varchar2,
    px_trx_error_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec);

  /* over loading this routine for XNC dependency, the signature change */
  /* that affected the xnc_ib_wf.populate_ib routine                    */

  PROCEDURE order_fulfillment(
    p_order_line_id        IN  number,
    p_message_id           IN  number,
    x_return_status        OUT NOCOPY varchar2,
    x_error_message        OUT NOCOPY varchar2);

  PROCEDURE process_old_order_lines(
    errbuf                 OUT NOCOPY varchar2,
    retcode                OUT NOCOPY number);

  PROCEDURE update_profile(
    errbuf                 OUT NOCOPY  varchar2,
    retcode                OUT NOCOPY  number);

  PROCEDURE fulfill_wf(
    itemtype               IN     VARCHAR2,
    itemkey                IN     VARCHAR2,
    actid                  IN     NUMBER,
    funcmode               IN     VARCHAR2,
    resultout              IN OUT NOCOPY VARCHAR2);

  PROCEDURE cz_fulfillment(
    p_order_line_id        IN number,
    x_return_status        OUT NOCOPY varchar2,
    x_return_message       OUT NOCOPY varchar2);

  /*----------------------------------------------------------*/
  /* Procedure name:  Construct_txn_dtls                      */
  /* Description : Procedure to create txn line details       */
  /*               if it does not exist                       */
  /*----------------------------------------------------------*/

  PROCEDURE Construct_txn_dtls(
    x_order_shipment_tbl  IN OUT NOCOPY csi_order_ship_pub.order_shipment_tbl,
    p_order_line_rec      IN     csi_order_ship_pub.order_line_rec,
    p_trackable_parent    IN     boolean,
    x_trx_line_id            OUT NOCOPY NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2 );


  PROCEDURE logical_drop_ship(
     p_mtl_txn_id           IN  number,
     p_message_id           IN  number,
     x_return_status        OUT NOCOPY varchar2,
     px_trx_error_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_error_rec);

END csi_order_fulfill_pub;

 

/
