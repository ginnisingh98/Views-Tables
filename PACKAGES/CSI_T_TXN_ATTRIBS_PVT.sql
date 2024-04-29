--------------------------------------------------------
--  DDL for Package CSI_T_TXN_ATTRIBS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_ATTRIBS_PVT" AUTHID CURRENT_USER AS
/* $Header: csivteas.pls 120.0 2005/05/25 02:38:54 appldev noship $ */

  PROCEDURE create_txn_ext_attrib_dtls(
    p_api_version             IN  NUMBER,
    p_commit                  IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_ext_attrib_vals_rec IN  OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_rec,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE update_txn_ext_attrib_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_ext_attrib_vals_tbl IN  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );

  PROCEDURE delete_txn_ext_attrib_dtls(
     p_api_version             IN  NUMBER
    ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_ext_attrib_ids_tbl  IN  csi_t_datastructures_grp.
                                    txn_ext_attrib_ids_tbl
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE get_csi_ext_attrib_vals(
    p_instance_id      in  number,
    x_csi_ea_vals_tbl  OUT NOCOPY csi_t_datastructures_grp.csi_ext_attrib_vals_tbl,
    x_return_status    OUT NOCOPY varchar2);

  PROCEDURE get_csi_ext_attribs(
    p_line_dtl_id         in  number,
    p_instance_id         in  number,
    x_csi_ext_attribs_tbl OUT NOCOPY csi_t_datastructures_grp.csi_ext_attribs_tbl,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE get_ext_attrib_dtls(
    p_line_dtl_id      in  number,
    x_ext_attrib_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status    OUT NOCOPY varchar2);

  PROCEDURE get_all_csi_ext_attrib_vals(
    p_txn_line_detail_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_csi_ea_vals_tbl     OUT NOCOPY csi_t_datastructures_grp.csi_ext_attrib_vals_tbl,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE get_all_csi_ext_attribs(
    p_txn_line_detail_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_csi_ext_attribs_tbl OUT NOCOPY csi_t_datastructures_grp.csi_ext_attribs_tbl,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE get_all_ext_attrib_dtls(
    p_txn_line_detail_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_ext_attrib_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status       OUT NOCOPY varchar2);

-- Added for CZ Integration (Begin)
  PROCEDURE get_ext_attrib_id(
    p_attrib_code    IN   VARCHAR2 ,
    p_attrib_level   IN   VARCHAR2 ,
    p_txn_line_detail_id    IN   NUMBER ,
    x_attribute_id          OUT NOCOPY  NUMBER ,
    x_source_table         OUT NOCOPY VARCHAR2,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_error_msg             OUT NOCOPY  VARCHAR2);

-- Added for CZ Integration (End)
END csi_t_txn_attribs_pvt;

 

/
