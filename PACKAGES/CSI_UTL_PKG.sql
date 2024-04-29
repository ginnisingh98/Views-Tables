--------------------------------------------------------
--  DDL for Package CSI_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_UTL_PKG" AUTHID CURRENT_USER as
/* $Header: csiutls.pls 120.4 2006/03/20 00:59:22 srsarava noship $ */

  /*----------------------------------------------------------*/
  /* Package Name  : csi_utl_pkg                              */
  /* Description   : used by the order shipment interface     */
  /*                 to do the validations                    */
  /*----------------------------------------------------------*/

  TYPE txn_line_dtl_rec is RECORD
  ( txn_line_detail_id   NUMBER :=  FND_API.G_MISS_NUM );

  TYPE txn_line_dtl_tbl is TABLE OF txn_line_dtl_rec INDEX BY BINARY_INTEGER;

  TYPE txn_ps_rec is RECORD(
    txn_line_detail_id         number      := fnd_api.g_miss_num,
    transaction_line_id        number      := fnd_api.g_miss_num,
    processed_flag             varchar2(1) := fnd_api.g_miss_char,
    quantity                   number      := fnd_api.g_miss_num,
    quantity_ratio             number      := fnd_api.g_miss_num,
    quantity_remaining         number      := fnd_api.g_miss_num);

  TYPE txn_ps_tbl IS TABLE OF txn_ps_rec INDEX BY binary_integer;


  FUNCTION get_curr_party(
    p_instance_id   IN NUMBER,
    p_rel_type_code IN VARCHAR2) RETURN NUMBER ;

  PROCEDURE get_ext_attribs(
    p_instance_id        IN  NUMBER ,
    p_attribute_id       IN  NUMBER ,
    x_attribute_value_id OUT NOCOPY NUMBER,
    x_obj_version_number OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2);

  PROCEDURE get_org_assign(
    p_instance_id        IN  NUMBER ,
    p_operating_unit_id  IN  NUMBER ,
    p_rel_type_code      IN  VARCHAR2,
    x_instance_ou_id     OUT NOCOPY NUMBER,
    x_obj_version_number OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2);

  PROCEDURE get_party_account(
    p_instance_pty_id    IN  NUMBER ,
    p_rel_type_code      IN  VARCHAR2,
    x_ip_account_id      OUT NOCOPY NUMBER,
    x_obj_version_number OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2);

  PROCEDURE get_instance_party(
    p_instance_id        IN  NUMBER ,
    p_rel_type_code      IN  VARCHAR2,
    x_inst_pty_qty       OUT NOCOPY NUMBER,
    x_obj_version_number OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2);

  PROCEDURE get_instance(
    p_instance_id        IN  NUMBER ,
    x_obj_version_number OUT NOCOPY NUMBER,
    x_inst_qty           OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2 );

  FUNCTION get_ii_obj_ver_num(
    p_relationship_id IN NUMBER) RETURN NUMBER ;

  FUNCTION get_org_obj_ver_num(
    p_instance_ou_id IN NUMBER) RETURN NUMBER ;

  FUNCTION get_ext_obj_ver_num(
    p_attrib_value_id IN NUMBER) RETURN NUMBER;

  FUNCTION get_pty_obj_ver_num(
    p_inst_pty_id IN NUMBER) RETURN NUMBER;

  FUNCTION get_acct_obj_ver_num(
    p_ip_acct_id  IN NUMBER) RETURN NUMBER;

  FUNCTION get_primay_uom(
    p_inv_item_id IN NUMBER,
    p_inv_org_id  IN NUMBER) RETURN VARCHAR2;

  FUNCTION Check_relation_exists(
    p_txn_ii_rltns_tbl   IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_txn_line_detail_id IN NUMBER) RETURN BOOLEAN;

  PROCEDURE Get_Pricing_Attribs(
    p_line_id               IN NUMBER,
    x_pricing_attb_tbl      IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl,
    x_return_status         OUT NOCOPY VARCHAR2 );

  PROCEDURE split_ship_rec(
    x_upd_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl
   ,x_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl
   ,x_txn_line_detail_rec     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec
   ,p_txn_sub_type_rec        IN csi_order_ship_pub.txn_sub_type_rec
   ,p_order_shipment_rec      IN csi_order_ship_pub.order_shipment_rec
   ,p_order_line_rec          IN csi_order_ship_pub.order_line_rec
   ,p_proc_qty                IN NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2);

PROCEDURE create_txn_details
 (  x_txn_line_dtl_rec        IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec
   ,p_txn_sub_type_rec        IN csi_order_ship_pub.txn_sub_type_rec
   ,p_order_shipment_rec      IN csi_order_ship_pub.order_shipment_rec
   ,p_order_line_rec          IN csi_order_ship_pub.order_line_rec
   ,x_return_status           OUT NOCOPY VARCHAR2 );

  PROCEDURE get_party_id(
    p_cust_acct_id  IN  number,
    x_party_id      OUT NOCOPY number,
    x_return_status OUT NOCOPY varchar2);

FUNCTION Check_config_exists
    ( p_txn_ii_rltns_tbl  IN csi_t_datastructures_grp.txn_ii_rltns_tbl,
      p_txn_detail_id     IN NUMBER ) RETURN BOOLEAN ;


FUNCTION validate_inst_party
    (p_instance_id IN NUMBER,
     p_inst_party_id IN NUMBER,
     p_pty_rel_code IN VARCHAR2 ) RETURN BOOLEAN;

  PROCEDURE get_dflt_inst_status_id(
    x_instance_status_id   OUT NOCOPY number,
    x_return_status        OUT NOCOPY varchar2);

  PROCEDURE get_dflt_sub_type_id(
    p_transaction_type_id  IN         number,
    x_sub_type_id          OUT NOCOPY number,
    x_return_status        OUT NOCOPY varchar2);

FUNCTION Get_trx_type_id
    (p_trx_line_id IN NUMBER ) RETURN NUMBER ;

FUNCTION Get_trx_line_id
    (p_src_trx_id IN NUMBER,
     p_src_table_name IN VARCHAR2) RETURN NUMBER;


FUNCTION get_serial_contl_code
   ( p_inv_item_id IN NUMBER,
     p_inv_org_id  IN NUMBER  ) RETURN NUMBER ;


FUNCTION get_instance_party_id
  ( p_instance_id   IN NUMBER )RETURN NUMBER ;

FUNCTION get_ip_account_id
  ( p_instance_party_id   IN NUMBER )RETURN NUMBER ;

FUNCTION get_instance
  ( p_order_line_id IN NUMBER )RETURN NUMBER ;

FUNCTION check_relation_exist
  ( p_model_line_id IN NUMBER ,
    p_line_id IN NUMBER    )RETURN BOOLEAN ;

PROCEDURE get_order_line_dtls
 ( p_mtl_transaction_id IN NUMBER,
   x_order_line_rec     OUT NOCOPY  csi_order_ship_pub.order_line_rec,
   x_return_status      OUT NOCOPY VARCHAR2 );

PROCEDURE get_master_organization
  (p_organization_id          IN  NUMBER,
   p_master_organization_id   OUT NOCOPY NUMBER,
   x_return_status            OUT NOCOPY VARCHAR2);

/* Added p_order_header_id as part of fix for Bug : 2897324 */

PROCEDURE get_split_order_line
 ( p_order_line_id     IN NUMBER,
   p_order_header_id   IN NUMBER,
   x_split_ord_line_id OUT NOCOPY  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2 );

PROCEDURE get_sub_type_rec
 ( p_sub_type_id      IN NUMBER,
   p_trx_type_id      IN NUMBER,
   x_trx_sub_type_rec OUT NOCOPY csi_order_ship_pub.txn_sub_type_rec,
   x_return_status    OUT NOCOPY VARCHAR2  );

PROCEDURE get_int_party
 ( x_int_party_id  OUT NOCOPY NUMBER,
   x_return_status OUT NOCOPY VARCHAR2 );

PROCEDURE get_inst_relation
 (  p_ii_relationship_id IN NUMBER,
    x_object_id          OUT NOCOPY NUMBER ,
    x_subject_id         OUT NOCOPY NUMBER ,
    x_return_status      OUT NOCOPY VARCHAR2 );

  PROCEDURE get_model_inst_lst(
    p_parent_line_id  IN  number,
    x_model_inst_tbl  OUT NOCOPY csi_order_ship_pub.model_inst_tbl,
    x_return_status   OUT NOCOPY varchar2);

PROCEDURE get_qty_ratio --fix for 5096435
 ( p_order_line_qty   IN NUMBER,
   p_order_item_id    IN NUMBER,
   p_model_remnant_flag IN VARCHAR2,
   p_link_to_line_id  IN NUMBER,
   x_qty_ratio        OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2 );

PROCEDURE get_link_to_line_id
 ( x_link_to_line_id  IN OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY    VARCHAR2 );

PROCEDURE build_inst_ii_tbl
    ( p_orig_inst_id     IN NUMBER,
      p_txn_ii_rltns_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
      p_new_instance_tbl IN csi_datastructures_pub.instance_tbl,
      x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE update_txn_line_dtl
    ( p_source_trx_id    IN NUMBER,
      p_source_trx_table IN VARCHAR2,
      p_api_name         IN VARCHAR2,
      p_error_message    IN VARCHAR2 );

  FUNCTION wip_config_exists(
    p_instance_id         IN NUMBER)
  RETURN boolean;

  FUNCTION check_standard_bom(
    p_order_line_rec      IN csi_order_ship_pub.order_line_rec)
  RETURN boolean;

  PROCEDURE create_txn_dtls(
    p_source_trx_id    IN NUMBER,
    p_source_trx_table IN VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2 );

  PROCEDURE conv_to_prim_uom(
    p_inv_organization_id IN number,
    p_inventory_item_id   IN number,
    p_uom                 IN varchar2,
    x_txn_line_dtl_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status       OUT NOCOPY    varchar2);

  PROCEDURE get_source_trx_dtls(
    p_mtl_transaction_id IN NUMBER,
    x_mtl_txn_rec        OUT NOCOPY csi_order_ship_pub.MTL_TXN_REC,
    x_error_message      OUT NOCOPY VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2);

  PROCEDURE split_txn_dtls(
    split_txn_dtl_id            IN  NUMBER,
    x_txn_line_dtls_lst         OUT NOCOPY txn_line_dtl_tbl,
    x_return_status             OUT NOCOPY varchar2);

  /* Included for Bug 4354267 */
  PROCEDURE split_txn_dtls_with_qty(
    split_txn_dtl_id            IN  NUMBER,
    p_split_qty			IN NUMBER,
    x_return_status             OUT NOCOPY varchar2);


  PROCEDURE get_system_tbl(
    p_txn_systems_rec            IN  csi_t_datastructures_grp.txn_system_rec,
    x_cre_systems_rec            OUT NOCOPY csi_datastructures_pub.system_rec );

  PROCEDURE get_org_assignment_tbl(
    p_txn_line_detail_rec        IN  csi_t_datastructures_grp.txn_line_detail_rec,
    p_txn_org_assgn_tbl          IN  csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_cre_org_units_tbl          OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    x_upd_org_units_tbl          OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    x_return_status              OUT NOCOPY VARCHAR2        );

  PROCEDURE get_ext_attribs_tbl(
    p_txn_line_detail_rec      IN  csi_t_datastructures_grp.txn_line_detail_rec,
    p_txn_ext_attrib_vals_tbl  IN  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_cre_ext_attrib_val_tbl   OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    x_upd_ext_attrib_val_tbl   OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    x_return_status            OUT NOCOPY VARCHAR2 );

  /* Added p_trx_rec for ER 2581101 */
  PROCEDURE get_ii_relation_tbl(
    p_txn_line_detail_tbl      IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    p_txn_ii_rltns_tbl         IN  csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_trx_rec                  IN  csi_datastructures_pub.transaction_rec,
    p_order_line_rec           IN csi_order_ship_pub.order_line_rec,
    x_cre_ii_rltns_tbl         OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
    x_upd_ii_rltns_tbl         OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
    x_return_status            OUT NOCOPY VARCHAR2        );

  PROCEDURE rebuild_tbls(
    p_new_instance_id          IN  NUMBER,
    x_upd_party_tbl            IN  OUT NOCOPY csi_datastructures_pub.party_tbl,
    x_upd_party_acct_tbl       IN  OUT NOCOPY csi_datastructures_pub.party_account_tbl,
    x_upd_org_units_tbl        IN  OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    x_upd_ext_attrib_val_tbl   IN  OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    x_cre_org_units_tbl        IN  OUT NOCOPY csi_datastructures_pub.organization_units_tbl,
    x_cre_ext_attrib_val_tbl   IN  OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
    x_txn_ii_rltns_tbl         IN  OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_line_detail_rec      IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    x_return_status            OUT NOCOPY VARCHAR2 );

  PROCEDURE cascade_txn_dtls(
    p_source_trx_id            IN  NUMBER,
    p_source_trx_table         IN  VARCHAR2,
    p_ratio                    IN  NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE derive_party_id(
    p_cust_acct_role_id        IN  NUMBER,
    x_party_id                 OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE get_party_owner(
    p_txn_line_detail_rec      IN  csi_t_datastructures_grp.txn_line_detail_rec,
    p_txn_party_detail_tbl     IN  csi_t_datastructures_grp.txn_party_detail_tbl,
    p_txn_pty_acct_dtl_tbl     IN  csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_trx_sub_type_rec         IN  csi_order_ship_pub.txn_sub_type_rec,
    p_order_line_rec           IN  csi_order_ship_pub.order_line_rec,
    x_upd_party_tbl            OUT NOCOPY csi_datastructures_pub.party_tbl ,
    x_upd_party_acct_tbl       OUT NOCOPY csi_datastructures_pub.party_account_tbl,
    x_cre_party_tbl            OUT NOCOPY csi_datastructures_pub.party_tbl ,
    x_cre_party_acct_tbl       OUT NOCOPY csi_datastructures_pub.party_account_tbl,
    x_return_status            OUT NOCOPY VARCHAR2);

  PROCEDURE make_non_header_tbl(
    p_instance_header_tbl      IN  csi_datastructures_pub.instance_header_tbl,
    x_instance_tbl             OUT NOCOPY csi_datastructures_pub.instance_tbl,
    x_return_status            OUT NOCOPY varchar2);

  PROCEDURE call_contracts_chk(
    p_txn_line_detail_id   in  number,
    p_txn_ii_rltns_tbl     in  csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_call_contracts       OUT NOCOPY varchar2,
    x_return_status        OUT NOCOPY varchar2);

  PROCEDURE get_item_control_rec(
    p_mtl_txn_id        IN  number,
    x_item_control_rec  OUT NOCOPY csi_order_ship_pub.item_control_rec,
    x_return_status     OUT NOCOPY varchar2);

  ---Added (Start) for m-to-m enhancements
  PROCEDURE rltns_xfaced_to_IB (
    p_xtn_ii_rltns_rec  IN  csi_t_datastructures_grp.txn_ii_rltns_rec,
    x_xface_to_IB_flag  OUT NOCOPY VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE build_txn_relations (
    p_txn_line_detail_tbl IN csi_t_datastructures_grp.txn_line_detail_tbl ,
    x_txn_ii_rltns_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status          OUT NOCOPY VARCHAR2) ;


  PROCEDURE get_partner_rltns (
    p_txn_line_detail_rec IN csi_t_datastructures_grp.txn_line_detail_rec ,
    x_txn_ii_rltns_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_txn_line_detail_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status          OUT NOCOPY VARCHAR2) ;
  ---Added (End) for m-to-m enhancements

  PROCEDURE build_parent_relation (
    p_order_line_rec    IN            csi_order_ship_pub.order_line_rec,
    x_model_inst_tbl    IN OUT NOCOPY csi_order_ship_pub.model_inst_tbl,
    x_txn_line_dtl_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_ii_rltns_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status        OUT NOCOPY VARCHAR2);

  PROCEDURE build_child_relation(
    p_order_line_rec     IN csi_order_ship_pub.order_line_rec,
    p_model_txn_line_rec IN csi_t_datastructures_grp.txn_line_rec,
    px_csi_txn_rec       IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status         OUT NOCOPY varchar2);

  PROCEDURE get_ib_trackable_children(
    p_order_line_rec     IN csi_order_ship_pub.order_line_rec,
    x_trackable_line_tbl OUT NOCOPY oe_order_pub.line_tbl_type,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE amend_contracts(
    p_relationship_type_code in  varchar2,
    p_object_instance_id     in  number,
    p_subject_instance_id    in  number,
    p_trx_rec                in  csi_datastructures_pub.transaction_rec,
    x_return_status          OUT NOCOPY varchar2);

  PROCEDURE get_parties_and_accounts(
    p_instance_id      IN     number,
    p_tld_rec          IN     csi_t_datastructures_grp.txn_line_detail_rec,
    p_t_pty_tbl        IN     csi_t_datastructures_grp.txn_party_detail_tbl,
    p_t_pty_acct_tbl   IN     csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_owner_pty_rec    IN     csi_datastructures_pub.party_rec,
    p_owner_acct_rec   IN     csi_datastructures_pub.party_account_rec,
    p_order_line_rec   IN     csi_order_ship_pub.order_line_rec,
    x_i_pty_tbl           OUT nocopy csi_datastructures_pub.party_tbl,
    x_i_pty_acct_tbl      OUT nocopy csi_datastructures_pub.party_account_tbl,
    x_return_status       OUT nocopy varchar2);

  PROCEDURE get_unit_price_in_primary_uom(
    p_unit_price                IN     number,
    p_unit_price_uom            IN     varchar2,
    px_item_control_rec         IN OUT nocopy csi_order_ship_pub.item_control_rec,
    x_unit_price_in_primary_uom    OUT nocopy number,
    x_return_status                OUT nocopy varchar2);

END csi_utl_pkg ;

 

/
