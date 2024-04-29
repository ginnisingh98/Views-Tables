--------------------------------------------------------
--  DDL for Package CSI_T_VLDN_ROUTINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_VLDN_ROUTINES_PVT" AUTHID CURRENT_USER AS
/* $Header: csivtvls.pls 120.1 2005/06/17 01:31:51 appldev  $ */

  /*-----------------------------------------------------------*/
  /* Procedure name: Check_Reqd_Param                          */
  /* Description : To Check if the reqd parameter is passed    */
  /* Overloading the procedure to handle all the data types    */
  /*-----------------------------------------------------------*/

  PROCEDURE check_reqd_param(
    p_value             IN  NUMBER,
    p_param_name        IN  VARCHAR2,
    p_api_name          IN  VARCHAR2);

  PROCEDURE Check_Reqd_Param(
    p_value             IN  VARCHAR2,
    p_param_name        IN  VARCHAR2,
    p_api_name          IN  VARCHAR2);

  PROCEDURE Check_Reqd_Param(
    p_value             IN  DATE,
    p_param_name        IN  VARCHAR2,
    p_api_name          IN  VARCHAR2);

  PROCEDURE validate_transaction_line_id(
    p_transaction_line_id   IN  NUMBER,
    x_transaction_line_rec  OUT NOCOPY  csi_t_datastructures_grp.txn_line_rec,
    x_return_status         OUT NOCOPY VARCHAR2);

  PROCEDURE validate_txn_line_detail_id(
    p_txn_line_detail_id  IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

-- Added for M-M
PROCEDURE validate_txn_line_detail_id(
    p_txn_line_detail_id  IN  NUMBER,
    x_txn_line_detail_rec OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE validate_txn_party_detail_id(
    p_txn_party_detail_id IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE validate_txn_acct_detail_id(
    p_txn_acct_detail_id  IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE validate_txn_relationship_id(
    p_txn_relationship_id  IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE validate_txn_ou_id(
    p_txn_operating_unit_id  IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE validate_txn_attrib_detail_id(
    p_txn_attrib_detail_id  IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE validate_txn_source_id(
    p_txn_source_name    IN  VARCHAR2,
    p_txn_source_id      IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE check_ib_creation(
    p_transaction_line_id IN  NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE validate_subject_id(
    p_subject_id        IN  NUMBER,
    p_txn_line_dtl_id   IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE validate_object_id(
    p_object_id         IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE validate_ii_rltns_type_code(
    p_rltns_type_code   IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE validate_instance_party_id(
    p_instance_id        IN  number,
    p_instance_party_id  IN  number,
    x_return_status      OUT NOCOPY VARCHAR2);

  PROCEDURE check_source_integrity(
    p_validation_level   IN  VARCHAR2,
    p_txn_line_rec       IN  csi_t_datastructures_grp.txn_line_rec,
    p_txn_line_dtl_tbl   IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status      OUT NOCOPY VARCHAR2);

  /* used in the main create */
  PROCEDURE check_party_integrity(
    p_txn_line_rec       IN  csi_t_datastructures_grp.txn_line_rec,
    p_txn_line_dtl_tbl   IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    p_party_dtl_tbl      IN  csi_t_datastructures_grp.txn_party_detail_tbl,
    x_return_status      OUT NOCOPY VARCHAR2);

  PROCEDURE convert_rltns_index_to_ids(
    p_line_dtl_tbl  IN     csi_t_datastructures_grp.txn_line_detail_tbl,
    px_ii_rltns_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status OUT NOCOPY    varchar2);

  /* used in the standalone party create */
  PROCEDURE is_valid_owner_for_create(
    p_txn_line_detail_id     IN  NUMBER,
    p_instance_party_id      IN  NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2);

  -- Added for M-M
  procedure get_txn_line_dtl_rec(
    p_index_id            IN  NUMBER,
    p_txn_line_detail_tbl IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_txn_line_detail_rec OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE check_rltns_integrity(
    p_txn_line_detail_tbl  IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    p_txn_ii_rltns_tbl     IN  csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status        OUT NOCOPY VARCHAR2);

  PROCEDURE get_processing_status(
    p_level              IN  varchar2,
    p_level_dtl_id       IN  number,
    x_processing_status  OUT NOCOPY varchar2,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE validate_attrib_source_id(
    p_attrib_source_table IN  varchar2,
    p_attrib_source_id    IN  number,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE validate_party_account_id(
    p_party_id          IN  NUMBER,
    p_party_account_id  IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE get_instance_ref_info(
    p_level                IN  varchar2,
    p_level_dtl_id         IN  number,
    x_instance_id          OUT NOCOPY varchar2,
    x_instance_exists_flag OUT NOCOPY varchar2,
    x_return_status        OUT NOCOPY varchar2);

 PROCEDURE get_party_detail_rec(
   p_party_detail_id   IN  number,
   x_party_detail_rec  OUT NOCOPY csi_t_party_details%rowtype,
   x_return_status    OUT NOCOPY varchar2);

  PROCEDURE validate_instance_id(
    p_instance_id   IN  number,
    x_return_status OUT NOCOPY varchar2);

  procedure validate_instance_reference(
    p_level              IN  varchar2,
    p_level_dtl_id       IN  number,
    p_level_inst_ref_id  IN  number,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE validate_account_id(
    p_account_id         IN  number,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE validate_site_use_id(
    p_account_id         IN  number,
    p_site_use_id        IN  number,
    p_site_use_code      IN  varchar2,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE get_txn_system_id(
    p_txn_systems_index  IN  number,
    p_txn_systems_tbl    IN  csi_t_datastructures_grp.txn_systems_tbl,
    x_txn_system_id      OUT NOCOPY number,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE get_txn_systems_index(
    p_txn_system_id      IN  number,
    p_txn_systems_tbl    IN  csi_t_datastructures_grp.txn_systems_tbl,
    x_txn_systems_index  OUT NOCOPY number,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE validate_contact_flag(
   p_contact_flag in varchar2,
   x_return_status OUT NOCOPY varchar2);

  PROCEDURE validate_ip_account_id(
    p_ip_account_id     IN  number,
    x_return_status     OUT NOCOPY varchar2);

  /* validtion routine for sub_type_id */
  PROCEDURE validate_sub_type_id(
    p_transaction_line_id IN  number,
    p_sub_type_id         IN  number,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE check_duplicate(
    p_txn_line_rec  IN  csi_t_datastructures_grp.txn_line_rec,
    x_return_status OUT NOCOPY varchar2);

  PROCEDURE validate_lot_number(
    p_inventory_item_id  IN  number,
    p_organization_id    IN  number,
    p_lot_number         IN  varchar2,
    x_return_status      OUT NOCOPY varchar2);

  PROCEDURE validate_serial_number(
    p_inventory_item_id  IN  number,
    p_organization_id    IN  number,
    p_serial_number      IN  varchar2,
    x_return_status      OUT NOCOPY varchar2);

-- Added for M-M
PROCEDURE  validate_txn_rltnshp (
                p_txn_line_detail_rec1 IN  csi_t_datastructures_grp.txn_line_detail_rec,
                p_txn_line_detail_rec2 IN  csi_t_datastructures_grp.txn_line_detail_rec,
                p_iir_rec              IN  csi_t_datastructures_grp.txn_ii_rltns_rec,
                x_return_status        OUT NOCOPY varchar2);

-- Added for M-M
PROCEDURE validate_inst_details (
    p_iir_rec       IN csi_t_datastructures_grp.txn_ii_rltns_rec,
    p_txn_dtl_rec   IN csi_t_datastructures_grp.txn_line_detail_rec,
    x_return_status OUT NOCOPY varchar2);

-- Added for M-M
PROCEDURE validate_src_header (
    p_txn_line_id1  IN  number,
    p_txn_line_id2  IN  number,
    p_rel_type_code IN  varchar2,
    x_return_status OUT NOCOPY varchar2);

--Added for CZ
PROCEDURE check_exists_in_cz(
     p_txn_line_dtl_tbl  IN  csi_t_datastructures_grp.txn_line_detail_tbl,
     x_return_status     OUT NOCOPY VARCHAR2);

--Added for CZ
PROCEDURE get_cz_inst_or_tld_id (
       p_config_inst_hdr_id       IN NUMBER ,
       p_config_inst_rev_num      IN NUMBER ,
       p_config_inst_item_id      IN NUMBER ,
       x_instance_id              OUT NOCOPY NUMBER ,
       x_txn_line_detail_id       OUT NOCOPY NUMBER ,
       x_return_status            OUT NOCOPY VARCHAR2);

--Added for CZ
PROCEDURE get_cz_txn_line_id (
       p_config_session_hdr_id       IN NUMBER ,
       p_config_session_rev_num      IN NUMBER ,
       p_config_session_item_id      IN NUMBER ,
       x_txn_line_id               OUT NOCOPY NUMBER ,
       x_return_status            OUT NOCOPY VARCHAR2) ;

--Added for CZ
PROCEDURE check_cz_session_keys (
       p_config_session_hdr_id IN NUMBER ,
       p_config_session_rev_num IN NUMBER ,
       p_config_session_item_id IN NUMBER ,
       x_return_status            OUT NOCOPY VARCHAR2) ;

END csi_t_vldn_routines_pvt;

 

/
