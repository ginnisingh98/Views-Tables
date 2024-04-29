--------------------------------------------------------
--  DDL for Package CSI_T_TXN_OUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_OUS_PVT" AUTHID CURRENT_USER AS
/* $Header: csivtous.pls 115.6 2002/11/12 00:31:47 rmamidip noship $ */

  PROCEDURE create_txn_org_assgn_dtls(
    p_api_version             IN  NUMBER,
    p_commit                  IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_org_assgn_rec       IN  OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_rec,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);


  PROCEDURE update_txn_org_assgn_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_org_assgn_tbl      IN  csi_t_datastructures_grp.txn_org_assgn_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );


  PROCEDURE delete_txn_org_assgn_dtls
  (
     p_api_version           IN  NUMBER
    ,p_commit                IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_org_assgn_ids_tbl IN  csi_t_datastructures_grp.txn_org_assgn_ids_tbl
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_org_assgn_dtls(
    p_line_dtl_id      in  number,
    x_org_assgn_tbl    OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_return_status    OUT NOCOPY varchar2);

  PROCEDURE get_all_org_assgn_dtls(
    p_txn_line_detail_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_org_assgn_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    x_return_status       OUT NOCOPY varchar2);

END csi_t_txn_ous_pvt;

 

/
