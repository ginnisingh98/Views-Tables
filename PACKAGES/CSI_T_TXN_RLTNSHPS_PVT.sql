--------------------------------------------------------
--  DDL for Package CSI_T_TXN_RLTNSHPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_RLTNSHPS_PVT" AUTHID CURRENT_USER AS
/* $Header: csivtiis.pls 115.5 2002/11/12 00:31:25 rmamidip noship $ */

  PROCEDURE create_txn_ii_rltns_dtls(
    p_api_version        IN  NUMBER,
    p_commit             IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list      IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level   IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_ii_rltns_rec   IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_rec,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2);

  PROCEDURE update_txn_ii_rltns_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_ii_rltns_tbl       IN  csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );

  PROCEDURE delete_txn_ii_rltns_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_ii_rltns_ids_tbl   IN  csi_t_datastructures_grp.txn_ii_rltns_ids_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_ii_rltns_dtls(
    p_txn_line_id_list in  varchar2,
    x_ii_rltns_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status    OUT NOCOPY varchar2);

END csi_t_txn_rltnshps_pvt;

 

/
