--------------------------------------------------------
--  DDL for Package CSI_MASS_EDIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_MASS_EDIT_PUB" AUTHID CURRENT_USER as
/* $Header: csipmees.pls 120.6.12010000.2 2008/11/06 20:26:28 mashah ship $ */
-- Start of Comments
-- Package name     : CSI_MASS_EDIT_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
g_user_id              NUMBER := FND_GLOBAL.user_id;
g_login_id             NUMBER := FND_GLOBAL.login_id;


TYPE mass_edit_rec IS RECORD
  (
   entry_id               NUMBER        :=  fnd_api.g_miss_num
  ,name                   VARCHAR2(50)  :=  fnd_api.g_miss_char
  ,txn_line_id            NUMBER        :=  fnd_api.g_miss_num
  ,txn_line_detail_id     NUMBER        :=  fnd_api.g_miss_num
  ,status_code            VARCHAR2(30)  :=  fnd_api.g_miss_char
  ,batch_type             VARCHAR2(30)  :=  fnd_api.g_miss_char
  ,description            VARCHAR2(2000):=  fnd_api.g_miss_char
  ,schedule_date          DATE          :=  fnd_api.g_miss_date
  ,start_date             DATE          :=  fnd_api.g_miss_date
  ,end_date               DATE          :=  fnd_api.g_miss_date
  ,object_version_number  NUMBER        :=  fnd_api.g_miss_num
  ,system_cascade         VARCHAR2(1)   :=  fnd_api.g_miss_char
  );

 TYPE  mass_edit_tbl IS TABLE OF mass_edit_rec INDEX BY BINARY_INTEGER;

 TYPE mass_edit_inst_rec is RECORD
 (
    TXN_LINE_DETAIL_ID     NUMBER        :=  fnd_api.g_miss_num
   ,INSTANCE_ID            NUMBER        :=  fnd_api.g_miss_num
   ,ACTIVE_END_DATE        DATE          :=  fnd_api.g_miss_date
   ,OBJECT_VERSION_NUMBER  NUMBER        :=  fnd_api.g_miss_num
 );

 TYPE mass_edit_inst_tbl IS TABLE OF mass_edit_inst_rec INDEX BY BINARY_INTEGER;

TYPE mass_edit_error_rec IS RECORD
(
  ENTRY_ID                        NUMBER           := FND_API.G_MISS_NUM ,
  TXN_LINE_DETAIL_ID              NUMBER           := FND_API.G_MISS_NUM ,
  INSTANCE_ID                     NUMBER           := FND_API.G_MISS_NUM ,
  ERROR_TEXT                      VARCHAR2(2000)   := FND_API.G_MISS_CHAR,
  ERROR_CODE                      VARCHAR2(1)      := FND_API.G_MISS_CHAR,
  NAME                            VARCHAR2(50)     := FND_API.G_MISS_CHAR
);

TYPE  mass_edit_error_tbl IS TABLE OF mass_edit_error_rec INDEX BY BINARY_INTEGER;

TYPE mass_edit_sys_error_rec IS RECORD
(
  ENTRY_ID                        NUMBER           := FND_API.G_MISS_NUM ,
  BATCH_NAME                      VARCHAR2(30)     := FND_API.G_MISS_CHAR,
  TXN_LINE_DETAIL_ID              NUMBER           := FND_API.G_MISS_NUM ,
  SYSTEM_ID                       NUMBER           := FND_API.G_MISS_NUM ,
  ERROR_TEXT                      VARCHAR2(2000)   := FND_API.G_MISS_CHAR,
  ERROR_CODE                      VARCHAR2(1)      := FND_API.G_MISS_CHAR,
  NAME                            VARCHAR2(50)     := FND_API.G_MISS_CHAR
);

TYPE  mass_edit_sys_error_tbl IS TABLE OF mass_edit_sys_error_rec INDEX BY BINARY_INTEGER;

TYPE Mass_Upd_Rep_Error_Rec IS RECORD
(
       Instance_id                     NUMBER           := FND_API.G_MISS_NUM,
       Entity_Name                     VARCHAR2(30)     := FND_API.G_MISS_CHAR,
       Error_Message                   VARCHAR2(2000)   := FND_API.G_MISS_CHAR,
       ENTRY_ID                        NUMBER           := FND_API.G_MISS_NUM ,
       TXN_LINE_DETAIL_ID              NUMBER           := FND_API.G_MISS_NUM ,
       ERROR_CODE                      VARCHAR2(1)      := FND_API.G_MISS_CHAR,
       NAME                            VARCHAR2(50)     := FND_API.G_MISS_CHAR
);

TYPE Mass_Upd_Rep_Error_Tbl IS TABLE OF Mass_Upd_Rep_Error_Rec INDEX BY BINARY_INTEGER;


PROCEDURE Initiate_Mass_Edit
   (
     errbuf                       OUT NOCOPY    VARCHAR2
    ,retcode                      OUT NOCOPY    NUMBER
    ,p_entry_id                   IN            NUMBER
    );

/* This is the Procedure for the Concurrent Program that processes the mass edit batch */
PROCEDURE Process_mass_edit_batch
   ( errbuf                       OUT NOCOPY    VARCHAR2
    ,retcode                      OUT NOCOPY    NUMBER
    ,p_Entry_id                   IN  NUMBER
   );

  /*
     This API is used to Create a new Mass edit Batch
  */

PROCEDURE CREATE_MASS_EDIT_BATCH
   (
    p_api_version               IN   NUMBER,
    p_commit                	IN   VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN   VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN   NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec          	IN OUT NOCOPY csi_mass_edit_pub.mass_edit_rec,
    px_txn_line_rec             IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec ,
    px_mass_edit_inst_tbl       IN OUT NOCOPY csi_mass_edit_pub.mass_edit_inst_tbl,
    px_txn_line_detail_rec      IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_txn_party_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_mass_edit_error_tbl       OUT NOCOPY    mass_edit_error_tbl,
    x_return_status          	OUT NOCOPY    VARCHAR2,
    x_msg_count              	OUT NOCOPY    NUMBER,
    x_msg_data	                OUT NOCOPY    VARCHAR2

  );

  /*
     This API is the Update Batch API to update an already existing Mass edit batch
     It can add, remove, update item instances as well it's child entities in the batch
  */

PROCEDURE UPDATE_MASS_EDIT_BATCH (
    p_api_version               IN     NUMBER,
    p_commit                    IN     VARCHAR2 := fnd_api.g_false,
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN     NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec            IN OUT NOCOPY csi_mass_edit_pub.mass_edit_rec,
    px_txn_line_rec             IN OUT NOCOPY csi_t_datastructures_grp.txn_line_rec ,
    px_mass_edit_inst_tbl       IN OUT NOCOPY mass_edit_inst_tbl,
    px_txn_line_detail_rec      IN OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_rec,
    px_txn_party_detail_tbl     IN OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    px_txn_pty_acct_detail_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    px_txn_ext_attrib_vals_tbl  IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_mass_edit_error_tbl       OUT NOCOPY    mass_edit_error_tbl,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2);

  /*
     This API can be used to delete the mass udpate batch and all of its transaction details
     created for that batch
  */

PROCEDURE DELETE_MASS_EDIT_BATCH
   (
    p_api_version               IN  NUMBER,
    p_commit                	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN  NUMBER   := fnd_api.g_valid_level_full,
    p_mass_edit_rec          	IN  mass_edit_rec,
    x_return_status          	OUT NOCOPY    VARCHAR2,
    x_msg_count              	OUT NOCOPY    NUMBER,
    x_msg_data	                OUT NOCOPY    VARCHAR2

  );

  /*
     This is a wrapper API can be used to delete multiple mass udpate batches and in turn calls the
     delete_mass_edit_batch API
  */

PROCEDURE DELETE_MASS_EDIT_BATCHES
   (
    p_api_version               IN  NUMBER,
    p_commit                	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list         	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level      	IN  NUMBER   := fnd_api.g_valid_level_full,
    p_mass_edit_tbl          	IN  mass_edit_tbl,
    x_return_status          	OUT NOCOPY    VARCHAR2,
    x_msg_count              	OUT NOCOPY    NUMBER,
    x_msg_data	                OUT NOCOPY    VARCHAR2
  );

  /*
     This API gets all the transaction line details and also the child records for each of
     these line details, for a given mass edit batch.
  */

  PROCEDURE GET_MASS_EDIT_DETAILS (
    p_api_version          	IN  NUMBER,
    p_commit               	IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list        	IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level     	IN  NUMBER   := fnd_api.g_valid_level_full,
    px_mass_edit_rec          	IN  OUT NOCOPY mass_edit_rec,
    x_txn_line_detail_tbl       OUT NOCOPY csi_t_datastructures_grp.txn_line_detail_tbl ,
    x_txn_party_detail_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_party_detail_tbl,
    x_txn_pty_acct_detail_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_pty_acct_detail_tbl,
    x_txn_ext_attrib_vals_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER ,
    x_msg_data                  OUT NOCOPY VARCHAR2);

/*----------------------------------------------------*/
/* Procedure name: PROCESS_SYSTEM_MASS_UPDATE         */
/* Description :   procedure used to update System in */
/*                 mass update batch                  */
/*----------------------------------------------------*/

PROCEDURE PROCESS_SYSTEM_MASS_UPDATE
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_Entry_id              IN NUMBER
    ,p_instance_tbl          IN OUT NOCOPY csi_datastructures_pub.instance_tbl
    ,p_ext_attrib_values_tbl IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT NOCOPY    VARCHAR2
    ,x_msg_count             OUT NOCOPY    NUMBER
    ,x_msg_data              OUT NOCOPY    VARCHAR2
 );

/*----------------------------------------------------*/
/* Procedure name: IDENTIFY_SYSTEM_FOR_UPDATE         */
/* Description :   procedure used to identifies System for */
/*                 mass update batch                  */
/*----------------------------------------------------*/
PROCEDURE IDENTIFY_SYSTEM_FOR_UPDATE (
        p_txn_line_id           IN     NUMBER
       ,p_upd_system_tbl        OUT NOCOPY   csi_datastructures_pub.mu_systems_tbl
       ,x_return_status         OUT NOCOPY    VARCHAR2);

/*----------------------------------------------------*/
/* Procedure name: VALIDATE_SYSTEM_BATCH               */
/* Description :   procedure to validate systems before*/
/*                  before mass update                 */
/*----------------------------------------------------*/
PROCEDURE VALIDATE_SYSTEM_BATCH (
        p_entry_id              IN  NUMBER
       ,p_txn_line_id           IN  NUMBER
       ,p_upd_system_tbl        IN   csi_datastructures_pub.mu_systems_tbl
       ,x_return_status         OUT NOCOPY    VARCHAR2);

End CSI_MASS_EDIT_PUB;

/
