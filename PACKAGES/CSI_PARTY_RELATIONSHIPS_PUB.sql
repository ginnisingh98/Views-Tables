--------------------------------------------------------
--  DDL for Package CSI_PARTY_RELATIONSHIPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_PARTY_RELATIONSHIPS_PUB" AUTHID CURRENT_USER AS
/* $Header: csipips.pls 120.1 2005/06/06 17:46:57 appldev  $ */


/*----------------------------------------------------------*/
/* Procedure name:  Get_inst_party_relationships            */
/* Description : Procedure used to  get party relationships */
/*               for an item instance                       */
/*----------------------------------------------------------*/

PROCEDURE get_inst_party_relationships
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_party_query_rec         IN  csi_datastructures_pub.party_query_rec
     ,p_resolve_id_columns      IN  VARCHAR2 := fnd_api.g_false
     ,p_time_stamp              IN  DATE
     ,x_party_header_tbl        OUT NOCOPY csi_datastructures_pub.party_header_tbl
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2                  );


/*-------------------------------------------------------------*/
/* Procedure name:   Create_inst_party_realationships          */
/* Description :   Procedure used to create new instance-party */
/*                 relationships                               */
/*-------------------------------------------------------------*/

PROCEDURE create_inst_party_relationship
 (    p_api_version         IN     NUMBER
     ,p_commit              IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_party_tbl           IN OUT NOCOPY csi_datastructures_pub.party_tbl
     ,p_party_account_tbl   IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
     ,p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,p_oks_txn_inst_tbl    IN OUT NOCOPY oks_ibint_pub.txn_instance_tbl
     ,x_return_status       OUT NOCOPY    VARCHAR2
     ,x_msg_count           OUT NOCOPY    NUMBER
     ,x_msg_data            OUT NOCOPY    VARCHAR2                    );


/*---------------------------------------------------------------*/
/* Procedure name:  Update_inst_party_relationship               */
/* Description :   Procedure used to  update the existing        */
/*                 instance -party relationships                 */
/*---------------------------------------------------------------*/


PROCEDURE update_inst_party_relationship
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_party_tbl                   IN     csi_datastructures_pub.party_tbl
     ,p_party_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,p_oks_txn_inst_tbl            IN OUT NOCOPY oks_ibint_pub.txn_instance_tbl
     ,x_return_status               OUT NOCOPY    VARCHAR2
     ,x_msg_count                   OUT NOCOPY    NUMBER
     ,x_msg_data                    OUT NOCOPY    VARCHAR2             );

/*---------------------------------------------------------------*/
/* Procedure name:  Expire_inst_party_relationship               */
/* Description :  Procedure used to  expire an existing          */
/*                 instance -party relationships                 */
/*---------------------------------------------------------------*/

PROCEDURE expire_inst_party_relationship
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_party_tbl          IN     csi_datastructures_pub.party_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY    VARCHAR2
     ,x_msg_count                   OUT NOCOPY    NUMBER
     ,x_msg_data                    OUT NOCOPY    VARCHAR2               );


/*----------------------------------------------------------------*/
/* Procedure name:  Get_inst_party_account                        */
/* Description :  Procedure used to  get the accounts related to  */
/*                an instance-parties                             */
/*----------------------------------------------------------------*/

PROCEDURE get_inst_party_accounts
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_account_query_rec       IN  csi_datastructures_pub.party_account_query_rec
     ,p_resolve_id_columns      IN  VARCHAR2 := fnd_api.g_false
     ,p_time_stamp              IN  DATE
     ,x_account_header_tbl      OUT NOCOPY csi_datastructures_pub.party_account_header_tbl
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2              );


/*----------------------------------------------------------*/
/* Procedure name:  Create_inst_party_account               */
/* Description :  Procedure used to  create new             */
/*                instance-party account relationships      */
/*----------------------------------------------------------*/

PROCEDURE create_inst_party_account
 (    p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_party_account_tbl   IN  OUT NOCOPY csi_datastructures_pub.party_account_tbl
     ,p_txn_rec             IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT NOCOPY     VARCHAR2
     ,x_msg_count           OUT NOCOPY     NUMBER
     ,x_msg_data            OUT NOCOPY     VARCHAR2  );

/*--------------------------------------------------------------*/
/* Procedure name:  Update_inst_party_account                   */
/* Description :  Procedure used to update the existing         */
/*                instance-party account relationships          */
/*--------------------------------------------------------------*/

PROCEDURE update_inst_party_account
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_party_account_tbl           IN     csi_datastructures_pub.party_account_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY    VARCHAR2
     ,x_msg_count                   OUT NOCOPY    NUMBER
     ,x_msg_data                    OUT NOCOPY    VARCHAR2            );



/*-------------------------------------------------------------*/
/* Procedure name: Expire_inst_party_account                   */
/* Description :  Procedure used to expire an existing         */
/*                instance-party account relationships         */
/*-------------------------------------------------------------*/

PROCEDURE expire_inst_party_account
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_party_account_tbl           IN     csi_datastructures_pub.party_account_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY    VARCHAR2
     ,x_msg_count                   OUT NOCOPY    NUMBER
     ,x_msg_data                    OUT NOCOPY    VARCHAR2         );


END csi_party_relationships_pub ;


 

/
