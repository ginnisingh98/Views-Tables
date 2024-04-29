--------------------------------------------------------
--  DDL for Package CSI_T_TXN_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_PARTIES_PVT" AUTHID CURRENT_USER AS
/* $Header: csivtpas.pls 115.6 2002/11/12 00:32:14 rmamidip noship $ */

  PROCEDURE create_txn_party_dtls(
    p_api_version          IN  NUMBER,
    p_commit               IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_party_dtl_index  IN  NUMBER,
    p_txn_party_detail_rec IN  OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_rec,
    px_txn_pty_acct_detail_tbl IN  OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2);


  PROCEDURE create_txn_pty_acct_dtls(
    p_api_version         IN  NUMBER,
    p_commit              IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list       IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level    IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_pty_acct_detail_rec IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_rec,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2);


  PROCEDURE update_txn_party_dtls(
    p_api_version          IN  NUMBER,
    p_commit               IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_party_detail_tbl IN  csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2);

  /*
  */
  PROCEDURE update_txn_pty_acct_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_pty_acct_detail_tbl    IN  csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );


  PROCEDURE delete_txn_party_dtls
  (
     p_api_version          IN  NUMBER
    ,p_commit               IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_party_ids_tbl    IN  csi_t_datastructures_grp.txn_party_ids_tbl
    ,x_txn_pty_acct_ids_tbl OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_ids_tbl
    ,x_return_status        OUT NOCOPY VARCHAR2
    ,x_msg_count            OUT NOCOPY NUMBER
    ,x_msg_data             OUT NOCOPY VARCHAR2
  );

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

  PROCEDURE get_pty_acct_dtls(
    p_party_dtl_id        in  number,
    x_pty_acct_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status       OUT NOCOPY varchar2);

  PROCEDURE get_party_dtls(
    p_line_dtl_id      in  number,
    x_party_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_return_status    OUT NOCOPY varchar2);

  PROCEDURE get_all_party_dtls(
    p_line_detail_tbl  in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_party_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_return_status    OUT NOCOPY varchar2);

  PROCEDURE get_all_pty_acct_dtls(
    p_party_detail_tbl    in  csi_t_datastructures_grp.txn_party_detail_tbl,
    x_pty_acct_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_return_status       OUT NOCOPY varchar2);

END csi_t_txn_parties_pvt;

 

/
