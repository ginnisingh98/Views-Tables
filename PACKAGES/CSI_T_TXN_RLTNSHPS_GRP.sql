--------------------------------------------------------
--  DDL for Package CSI_T_TXN_RLTNSHPS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_RLTNSHPS_GRP" AUTHID CURRENT_USER AS
/* $Header: csigtiis.pls 115.7 2002/11/12 00:15:37 rmamidip noship $ */

  /* Create the transaction instance to instance relationship details */

  PROCEDURE create_txn_ii_rltns_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    px_txn_ii_rltns_tbl     IN  OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2);

  /* API to update the transaction ii relationships */

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

  /* API to delete transaction ii relationships */

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

END csi_t_txn_rltnshps_grp;

 

/
