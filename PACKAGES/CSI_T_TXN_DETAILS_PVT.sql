--------------------------------------------------------
--  DDL for Package CSI_T_TXN_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_DETAILS_PVT" AUTHID CURRENT_USER AS
/* $Header: csivttxs.pls 120.2 2005/09/27 23:13:09 sumathur noship $ */


  FUNCTION check_txn_details_exist(
    p_txn_line_rec  IN  csi_t_datastructures_grp.txn_line_rec)
  RETURN BOOLEAN;


  PROCEDURE create_transaction_dtls(
    p_api_version           IN     NUMBER,
    p_commit                IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full,
    p_split_source_flag     IN     VARCHAR2 := fnd_api.g_false,
    px_txn_line_rec         IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec ,
    px_txn_line_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl ,
    px_txn_pty_acct_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ii_rltns_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_txn_org_assgn_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_systems_tbl      IN OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER ,
    x_msg_data              OUT NOCOPY    VARCHAR2);

  PROCEDURE update_transaction_dtls (
     p_api_version              IN  NUMBER
    ,p_commit                   IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list            IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level         IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_line_rec             IN csi_t_datastructures_grp.txn_line_rec
    ,px_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl
    ,px_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,px_txn_party_detail_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl
    ,px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,px_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl
    ,px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                   OUT NOCOPY NUMBER
    ,x_msg_data                    OUT NOCOPY VARCHAR2);

  /*
  */
  PROCEDURE delete_transaction_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_transaction_line_id    IN  NUMBER
    ,p_txn_line_detail_id     IN  NUMBER -- added for Mass update R12
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_transaction_details(
     p_api_version          IN  NUMBER
    ,p_commit               IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_line_query_rec   IN  csi_t_datastructures_grp.txn_line_query_rec
    ,p_txn_line_detail_query_rec IN  csi_t_datastructures_grp.txn_line_detail_query_rec
    ,x_txn_line_detail_tbl  OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl
    ,p_get_parties_flag     IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_party_detail_tbl OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl
    ,p_get_pty_accts_flag   IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_pty_acct_detail_tbl  OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,p_get_ii_rltns_flag    IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_ii_rltns_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,p_get_org_assgns_flag  IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_org_assgn_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl
    ,p_get_ext_attrib_vals_flag IN  VARCHAR2 := fnd_api.g_false
    ,x_txn_ext_attrib_vals_tbl  OUT NOCOPY csi_t_datastructures_grp.
                                  txn_ext_attrib_vals_tbl
    ,p_get_csi_attribs_flag IN  VARCHAR2 := fnd_api.g_false
    ,x_csi_ext_attribs_tbl  OUT NOCOPY csi_t_datastructures_grp.csi_ext_attribs_tbl
    ,p_get_csi_iea_values_flag IN  VARCHAR2 := fnd_api.g_false
    ,x_csi_iea_values_tbl   OUT NOCOPY csi_t_datastructures_grp.csi_ext_attrib_vals_tbl
    ,p_get_txn_systems_flag IN VARCHAR2 := fnd_api.g_false
    ,x_txn_systems_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl
    ,x_return_status        OUT NOCOPY VARCHAR2
    ,x_msg_count            OUT NOCOPY NUMBER
    ,x_msg_data             OUT NOCOPY VARCHAR2);

  PROCEDURE split_transaction_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    p_upd_txn_line_rec      IN  csi_t_datastructures_grp.txn_line_rec,
    p_upd_txn_line_dtl_tbl  IN  csi_t_datastructures_grp.txn_line_detail_tbl,
    px_crt_txn_line_rec     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_crt_txn_line_dtl_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2);

  PROCEDURE copy_transaction_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    p_src_txn_line_rec      IN  csi_t_datastructures_grp.txn_line_rec,
    px_new_txn_line_rec     IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    p_copy_parties_flag     IN  varchar2 := fnd_api.g_true,
    p_copy_pty_accts_flag   IN  varchar2 := fnd_api.g_true,
    p_copy_ii_rltns_flag    IN  varchar2 := fnd_api.g_true,
    p_copy_org_assgn_flag   IN  varchar2 := fnd_api.g_true,
    p_copy_ext_attribs_flag IN  varchar2 := fnd_api.g_true,
    p_copy_txn_systems_flag IN  varchar2 := fnd_api.g_true,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE split_transaction_details(
    p_api_version             IN  NUMBER,
    p_commit                  IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full,
    p_src_txn_line_rec        IN  csi_t_datastructures_grp.txn_line_rec,
    px_split_txn_line_rec     IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_rec,
    px_line_dtl_tbl           IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_pty_dtl_tbl             OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_pty_acct_tbl            OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_org_assgn_tbl           OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_txn_ext_attrib_vals_tbl OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_txn_systems_tbl         OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2  ) ;

END csi_t_txn_details_pvt;

 

/
