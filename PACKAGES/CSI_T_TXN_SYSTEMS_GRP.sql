--------------------------------------------------------
--  DDL for Package CSI_T_TXN_SYSTEMS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_T_TXN_SYSTEMS_GRP" AUTHID CURRENT_USER AS
/* $Header: csigtsys.pls 115.2 2002/11/12 00:16:41 rmamidip noship $ */
-- Start of Comments
-- Package name     : CSI_T_TXN_SYSTEMS_GRP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;



PROCEDURE create_txn_system(
    p_api_version                IN     NUMBER,
    p_commit                     IN     VARCHAR2     := fnd_api.g_false,
    p_init_msg_list              IN     VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN     NUMBER       := fnd_api.g_valid_level_full,
    p_txn_system_rec             IN     csi_t_datastructures_grp.txn_system_rec,
    x_txn_system_id              OUT NOCOPY    NUMBER,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
    );

PROCEDURE update_txn_system(
    p_api_version                IN     NUMBER,
    p_commit                     IN     VARCHAR2     := fnd_api.g_false,
    p_init_msg_list              IN     VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN     NUMBER       := fnd_api.g_valid_level_full,
    p_txn_system_rec             IN     csi_t_datastructures_grp.txn_system_rec,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
    );

PROCEDURE delete_txn_system
 (
     p_api_version                 IN     NUMBER,
     p_commit                      IN     VARCHAR2   := fnd_api.g_false,
     p_init_msg_list               IN     VARCHAR2   := fnd_api.g_false,
     p_validation_level            IN     NUMBER     := fnd_api.g_valid_level_full,
     p_txn_system_id               IN     NUMBER,
     x_return_status               OUT NOCOPY    VARCHAR2,
     x_msg_count                   OUT NOCOPY    NUMBER,
     x_msg_data                    OUT NOCOPY    VARCHAR2
 );


end csi_t_txn_systems_grp;

 

/
