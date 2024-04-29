--------------------------------------------------------
--  DDL for Package CSI_T_TXN_ATTRIBS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_ATTRIBS_GRP" AUTHID CURRENT_USER AS
/* $Header: csigteas.pls 115.7 2002/11/12 00:15:21 rmamidip noship $ */

/* API to create extended attribute values for a transaction line detail */

  PROCEDURE create_txn_ext_attrib_dtls(
    p_api_version           	IN  NUMBER,
    p_commit                	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN  NUMBER   := fnd_api.g_valid_level_full,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2);

/* API to update the extended attribute values of a transaction line detail */

  PROCEDURE update_txn_ext_attrib_dtls
  (
     p_api_version            	IN  NUMBER
    ,p_commit                 	IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          	IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       	IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_ext_attrib_vals_tbl 	IN csi_t_datastructures_grp.
                                     txn_ext_attrib_vals_tbl
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
  );

/* API to delete the extended attribute values of a transaction line detail */

  PROCEDURE delete_txn_ext_attrib_dtls
  (
     p_api_version             IN  NUMBER
    ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_ext_attrib_ids_tbl  IN  csi_t_datastructures_grp.
                                     txn_ext_attrib_ids_tbl
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
  );

END csi_t_txn_attribs_grp;

 

/
