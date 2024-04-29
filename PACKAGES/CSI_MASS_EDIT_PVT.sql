--------------------------------------------------------
--  DDL for Package CSI_MASS_EDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_MASS_EDIT_PVT" AUTHID CURRENT_USER as
/* $Header: csivmees.pls 120.5.12010000.2 2008/11/06 20:33:06 mashah ship $ */
-- Start of Comments
-- Package name     : CSI_MASS_EDIT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

g_entry_id                NUMBER;
g_batch_name              VARCHAR2(50);

TYPE NumTabType    is  varray(10000) of number;
TYPE Char30TabType is  varray(10000) of varchar2(30);
TYPE DateTabType   is  varray(10000) of date;

PROCEDURE CREATE_MASS_EDIT_BATCH
   (
    p_api_version          		IN   NUMBER,
    p_commit                	IN   VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN   VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN   NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec          	IN OUT NOCOPY csi_mass_edit_pub.mass_edit_rec,
    px_txn_line_rec             IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec ,
    px_mass_edit_inst_tbl       IN OUT NOCOPY csi_mass_edit_pub.mass_edit_inst_tbl,
    px_txn_line_detail_rec      IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_txn_party_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_mass_edit_error_tbl       OUT NOCOPY    csi_mass_edit_pub.mass_edit_error_tbl,
    x_return_status          	OUT NOCOPY    VARCHAR2,
    x_msg_count              	OUT NOCOPY    NUMBER,
    x_msg_data	                OUT NOCOPY    VARCHAR2

  );


PROCEDURE update_mass_edit_batch (
    p_api_version               IN     NUMBER,
    p_commit                    IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN     NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec            IN OUT NOCOPY csi_mass_edit_pub.mass_edit_rec,
    px_txn_line_rec             IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec ,
    px_mass_edit_inst_tbl       IN OUT NOCOPY csi_mass_edit_pub.mass_edit_inst_tbl,
    px_txn_line_detail_rec      IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_txn_party_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_mass_edit_error_tbl       OUT NOCOPY    csi_mass_edit_pub.mass_edit_error_tbl,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

PROCEDURE DELETE_MASS_EDIT_BATCH
   (
    p_api_version               IN  NUMBER,
    p_commit                	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN  NUMBER   := fnd_api.g_valid_level_full,
    p_mass_edit_rec          	IN  csi_mass_edit_pub.mass_edit_rec,
    x_return_status          	OUT NOCOPY    VARCHAR2,
    x_msg_count              	OUT NOCOPY    NUMBER,
    x_msg_data	                OUT NOCOPY    VARCHAR2

  );


  PROCEDURE GET_MASS_EDIT_DETAILS (
    p_api_version          	IN  NUMBER,
    p_commit               	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list        	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level     	IN  NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec          	IN  OUT NOCOPY csi_mass_edit_pub.mass_edit_rec,
    x_txn_line_detail_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl ,
    x_txn_party_detail_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_pty_acct_detail_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_ext_attrib_vals_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER ,
    x_msg_data                  OUT NOCOPY VARCHAR2);

 -- Validate the batch ID /Name
  FUNCTION Is_valid_batch (
    p_batch_name        IN  VARCHAR2,
    p_batch_id          IN  NUMBER,
    x_mass_edit_rec     OUT NOCOPY csi_mass_edit_pub.mass_edit_rec)
   RETURN BOOLEAN;

    --validate the uniqueness of the batch name
    PROCEDURE validate_batch_name(
    p_batch_name        IN  VARCHAR2,
    p_api_name          IN  VARCHAR2 ,
    x_mass_edit_error_tbl   OUT NOCOPY  csi_mass_edit_pub.mass_edit_error_tbl);

    --validate batchtype
    PROCEDURE validate_batch_type(
    p_batch_type        IN  VARCHAR2,
    p_api_name          IN  VARCHAR2,
    x_sub_type_id       OUT NOCOPY NUMBER ,
    x_mass_edit_error_tbl   OUT NOCOPY  csi_mass_edit_pub.mass_edit_error_tbl);

    --validate batch status
    PROCEDURE validate_batch_status
        (p_batch_id   IN NUMBER ,
         x_mass_edit_error_tbl   OUT NOCOPY  csi_mass_edit_pub.mass_edit_error_tbl);

--Procedure to validate the mass update batch
PROCEDURE validate_batch (px_mass_edit_rec        IN csi_mass_edit_pub.mass_edit_rec,
                          p_mode                  IN VARCHAR2,
                          x_mass_edit_error_tbl   OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl,
                          x_return_status         OUT NOCOPY VARCHAR2);

PROCEDURE log_mu_error (
    p_index                 IN  NUMBER,
    p_instance_id           IN  NUMBER,
    p_txn_line_detail_id    IN  NUMBER,
    p_error_code            IN  VARCHAR2,
    x_mass_edit_error_tbl   OUT NOCOPY  csi_mass_edit_pub.mass_edit_error_tbl);

PROCEDURE vld_item_instance_active (p_instance_id_tab          IN NumTabType,
                                    p_txn_line_detail_id_tab   IN NumTabType,
                                    px_mass_edit_error_tbl     IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl);

PROCEDURE vld_batch_inst_same_owner(p_txn_line_id_tab          IN NumTabType,
                                    px_mass_edit_error_tbl     IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl);

PROCEDURE vld_batch_inst_curr_owner (p_txn_line_id_tab          IN NumTabType,
                                     px_mass_edit_error_tbl     IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl);

PROCEDURE vld_child_inst_location(p_instance_id_tab          IN NumTabType,
                                  p_txn_line_detail_id_tab   IN NumTabType,
                                  p_instance_usage_code_tab  IN Char30TabType,
                                  px_mass_edit_error_tbl     IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl);

PROCEDURE vld_item_inst_location(p_instance_id_tab           IN NumTabType,
                                 p_txn_line_id_tab           IN NumTabType,
                                 p_location_type_code_tab    IN Char30TabType,
                                 p_location_id_tab           IN NumTabType,
                                 p_install_location_id_tab   IN NumTabType,
                                 p_instance_status_id_tab    IN NumTabType,
                                 px_mass_edit_error_tbl      IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl);

PROCEDURE check_item_inst_loc_changed(p_txn_line_detail_id_tab    IN NumTabType,
                                      p_instance_id_tab           IN NumTabType,
                                      p_install_location_id_tab   IN NumTabType,
                                      p_location_id_tab           IN NumTabType,
                                      p_instance_status_id_tab    IN NumTabType,
                                      p_external_reference_tab    IN Char30TabType,
                                      p_install_date_tab          IN DateTabType,
                                      p_system_id_tab             IN NumTabType,
                                      px_mass_edit_error_tbl      IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl);

PROCEDURE vld_xfer_date(p_txn_line_id_tab       IN NumTabType,
                        px_mass_edit_error_tbl  IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl);

PROCEDURE vld_term_date(p_txn_line_id_tab       IN NumTabType,
                        px_mass_edit_error_tbl  IN OUT NOCOPY csi_mass_edit_pub.mass_edit_error_tbl);

/*----------------------------------------------------*/
/* Procedure name: VLD_SYSTEM_ACTIVE               */
/* Description :   procedure to validate whether the */
/*                 system is active or not            */
/*----------------------------------------------------*/
PROCEDURE VLD_SYSTEM_ACTIVE(
         p_system_id        IN NUMBER ,
         p_txn_line_id      IN NUMBER,
         p_mu_sys_error_tbl IN OUT NOCOPY csi_mass_edit_pub.mass_edit_sys_error_tbl);


/*----------------------------------------------------*/
/* Procedure name: VLD_SYSTEM_CURRENT_OWNER               */
/* Description :   procedure to validate current system owner */
/*                 system is active or not            */
/*----------------------------------------------------*/
PROCEDURE VLD_SYSTEM_CURRENT_OWNER(
         p_system_id        IN NUMBER ,
         p_customer_id      IN NUMBER,
         p_txn_line_id      IN NUMBER,
         p_mu_sys_error_tbl IN OUT NOCOPY csi_mass_edit_pub.mass_edit_sys_error_tbl);

/*----------------------------------------------------*/
/* Procedure name: VLD_SYSTEM_LOCATION_CHGD               */
/* Description :   procedure to validate whether the location */
/*                and contact info changed            */
/*----------------------------------------------------*/
PROCEDURE VLD_SYSTEM_LOCATION_CHGD(
         p_system_id        IN NUMBER ,
         p_txn_line_id      IN NUMBER,
         p_mu_sys_error_tbl IN OUT NOCOPY csi_mass_edit_pub.mass_edit_sys_error_tbl);

End CSI_MASS_EDIT_PVT;

/
