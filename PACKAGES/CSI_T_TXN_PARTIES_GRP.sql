--------------------------------------------------------
--  DDL for Package CSI_T_TXN_PARTIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_PARTIES_GRP" AUTHID CURRENT_USER AS
/* $Header: csigtpas.pls 115.7 2002/11/12 00:16:16 rmamidip noship $ */

/* This API creates the parties/party associations for a transaction line detail */

  PROCEDURE create_txn_party_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    px_txn_party_detail_tbl IN  OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2);

/* This API updates the parties/party associations for a transaction line detail */

  PROCEDURE update_txn_party_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_party_detail_tbl   IN  csi_t_datastructures_grp.txn_party_detail_tbl
    ,px_txn_pty_acct_detail_tbl  IN  OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );

/* This API deletes the parties/party associations for a transaction line detail */

  PROCEDURE delete_txn_party_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_party_ids_tbl      IN  csi_t_datastructures_grp.txn_party_ids_tbl
    ,x_txn_pty_acct_ids_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_ids_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );

/* This API creates the party account details for a party on the transaction line detail */

  PROCEDURE create_txn_pty_acct_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    px_txn_pty_acct_detail_tbl  IN  OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2);

/* This API updates the party account details for a party on the transaction line detail */

  PROCEDURE update_txn_pty_acct_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_pty_acct_detail_tbl IN csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );

/* This API deletes the party account details for a party on the transaction line detail */

  PROCEDURE delete_txn_pty_acct_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_pty_acct_ids_tbl   IN csi_t_datastructures_grp.txn_pty_acct_ids_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );

END csi_t_txn_parties_grp;

 

/
