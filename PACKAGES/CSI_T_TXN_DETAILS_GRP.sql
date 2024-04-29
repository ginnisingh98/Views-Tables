--------------------------------------------------------
--  DDL for Package CSI_T_TXN_DETAILS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_DETAILS_GRP" AUTHID CURRENT_USER AS
/* $Header: csigttxs.pls 120.3 2005/09/27 23:12:06 sumathur noship $ */


  /*
     This function checks for the existence of a transaction details
     record in the database . The key to identify the txn line record is
     transaction_source_table, transaction_source_id.
     Returns a 'Y' or 'N'
  */

  FUNCTION check_txn_details_exist(
    p_txn_line_rec           IN  csi_t_datastructures_grp.txn_line_rec)
  RETURN Boolean ;

  /*
     For a given transaction line record,this API gets all the transaction
     line details and also the specified set of child records for each of
     these line details. This API also returns , if specified, all the Extended Attributes
     defined for the Item and Level and the CSI extended attribute values
     if there is an instance referenced on the transaction line detail
  */

  PROCEDURE get_transaction_details(
    p_api_version          	IN  NUMBER,
    p_commit               	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list        	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level     	IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_line_query_rec        IN  csi_t_datastructures_grp.txn_line_query_rec ,
    p_txn_line_detail_query_rec IN  csi_t_datastructures_grp.txn_line_detail_query_rec ,
    x_txn_line_detail_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl ,
    p_get_parties_flag     	IN  VARCHAR2 := fnd_api.g_false,
    x_txn_party_detail_tbl  OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    p_get_pty_accts_flag   	IN  VARCHAR2 := fnd_api.g_false,
    x_txn_pty_acct_detail_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    p_get_ii_rltns_flag    	IN  VARCHAR2 := fnd_api.g_false,
    x_txn_ii_rltns_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    p_get_org_assgns_flag  	IN  VARCHAR2 := fnd_api.g_false,
    x_txn_org_assgn_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    p_get_ext_attrib_vals_flag  IN  VARCHAR2 := fnd_api.g_false,
    x_txn_ext_attrib_vals_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    p_get_csi_attribs_flag 	IN  VARCHAR2 := fnd_api.g_false,
    x_csi_ext_attribs_tbl   OUT NOCOPY csi_t_datastructures_grp.csi_ext_attribs_tbl,
    p_get_csi_iea_values_flag   IN  VARCHAR2 := fnd_api.g_false,
    x_csi_iea_values_tbl    OUT NOCOPY csi_t_datastructures_grp.csi_ext_attrib_vals_tbl,
    p_get_txn_systems_flag      IN  VARCHAR2 := fnd_api.g_false,
    x_txn_systems_tbl           OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER ,
    x_msg_data              OUT NOCOPY VARCHAR2);

  /*
     This API creates new transaction line details, party and party account associations,
     configuration details, org assignments and extended attributes for
     a transaction line
  */
  PROCEDURE create_transaction_dtls(
    p_api_version           	IN     NUMBER,
    p_commit                	IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN     NUMBER   := fnd_api.g_valid_level_full,
    px_txn_line_rec          	IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec ,
    px_txn_line_detail_tbl  	IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl,
    px_txn_party_detail_tbl 	IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl ,
    px_txn_pty_acct_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ii_rltns_tbl     	IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    px_txn_org_assgn_tbl    	IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    px_txn_systems_tbl          IN OUT NOCOPY csi_t_datastructures_grp.txn_systems_tbl,
    x_return_status          OUT NOCOPY    VARCHAR2,
    x_msg_count              OUT NOCOPY    NUMBER,
    x_msg_data               OUT NOCOPY    VARCHAR2);

  /*
     This API is used to update the transaction line details. If the update results in a cascading effect
     to any/all of it's child entities then those records may/may not be deleted (depending on the value
     for the preserve_detail_flag for them) but a new set of child records can also be passed to be created
     and linked to the transaction line detail. This API allows creates only on the child entities for the Line
     details whereas the Line details itself can only be an update
  */
  PROCEDURE update_txn_line_dtls
  (
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
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  );

  /*
    This API deletes all the transaction details incl. all it's children for the
    given transaction line id. If selective child records need to be deleted then the users should call
    the individual delete API's provided
  */
  PROCEDURE delete_transaction_dtls
  (
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_transaction_line_id    IN  NUMBER
    ,p_api_caller_identity    IN  VARCHAR2 DEFAULT 'OTHER'
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
  );

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


  /*
     This API is used to Manage the transaction details. It accepts a create as well as a delete on the
     transaction line details entity. This API inturn invokes existing Create, Update and Delete txn details
     APIs and the underlying business logic does not change - so if the update results in a cascading effect
     to any/all of it's child entities then those records may/may not be deleted (depending on the value
     for the preserve_detail_flag for them) but a new set of child records can also be passed to be created/updated
     transaction line detail.
     Currently it's usage may be limited to Mass Update as the source but we can enhance it for others like Configurator
  */

  PROCEDURE update_transaction_dtls
  (
     p_api_version              IN  NUMBER
    ,p_commit                   IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list            IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level         IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_line_rec             IN  csi_t_datastructures_grp.txn_line_rec
    ,px_txn_line_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl
    ,px_txn_ii_rltns_tbl        IN OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl
    ,px_txn_party_detail_tbl    IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl
    ,px_txn_pty_acct_detail_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl
    ,px_txn_org_assgn_tbl       IN OUT NOCOPY csi_t_datastructures_grp.txn_org_assgn_tbl
    ,px_txn_ext_attrib_vals_tbl IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  );

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
    x_msg_data                OUT NOCOPY VARCHAR2);


END csi_t_txn_details_grp;

 

/
