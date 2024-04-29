--------------------------------------------------------
--  DDL for Package CSI_T_TXN_LINE_DTLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_LINE_DTLS_PVT" AUTHID CURRENT_USER AS
/* $Header: csivttds.pls 120.0 2005/05/24 18:35:28 appldev noship $*/

  g_pkg_name varchar2(30) := 'csi_t_txn_line_dtls_pvt';

  PROCEDURE create_txn_line_dtls(
    p_api_version           IN  NUMBER,
    p_commit                IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_line_dtl_index    IN  NUMBER,
    p_txn_line_dtl_rec      IN  OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_txn_party_dtl_tbl    IN  OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl  IN  OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ii_rltns_tbl     IN  OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_txn_org_assgn_tbl    IN  OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_ext_attrib_vals_tbl  IN  OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2);

  PROCEDURE update_txn_line_dtls (
     p_api_version              IN  NUMBER
    ,p_commit                   IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list            IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level         IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_line_rec             IN  csi_t_datastructures_grp.txn_line_rec
    ,p_txn_line_detail_tbl      IN     csi_t_datastructures_grp.txn_line_detail_tbl
    ,px_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,px_txn_party_detail_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl
    ,px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,px_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl
    ,px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                   OUT NOCOPY NUMBER
    ,x_msg_data                    OUT NOCOPY VARCHAR2);

  PROCEDURE build_txn_lines_select(
    p_txn_line_query_rec     in csi_t_datastructures_grp.txn_line_query_rec,
    x_lines_select_stmt OUT NOCOPY varchar2,
    x_lines_restrict    OUT NOCOPY varchar2,
    x_return_status     OUT NOCOPY varchar2);

  PROCEDURE get_txn_line_dtls(
    p_txn_line_query_rec        IN  csi_t_datastructures_grp.txn_line_query_rec,
    p_txn_line_detail_query_rec IN  csi_t_datastructures_grp.txn_line_detail_query_rec,
    x_txn_line_dtl_tbl OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    x_return_status    OUT NOCOPY varchar2);

  PROCEDURE delete_txn_line_dtls(
     p_api_version             IN  NUMBER
    ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_line_detail_ids_tbl IN  csi_t_datastructures_grp.
                                     txn_line_detail_ids_tbl
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE update_txn_line(
    p_txn_line_rec  in  csi_t_datastructures_grp.txn_line_rec,
    x_return_status OUT NOCOPY varchar2);

END csi_t_txn_line_dtls_pvt;

 

/
