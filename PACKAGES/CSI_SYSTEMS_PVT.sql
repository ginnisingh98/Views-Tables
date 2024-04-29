--------------------------------------------------------
--  DDL for Package CSI_SYSTEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_SYSTEMS_PVT" AUTHID CURRENT_USER AS
/* $Header: csivsyss.pls 120.0.12010000.1 2008/07/25 08:16:31 appldev ship $ */
-- start of comments
-- package name     : csi_systems_pvt
-- purpose          :
-- history          :
-- note             :
-- end of comments

-- default NUMBER of records fetch per call
g_default_num_rec_fetch  NUMBER := 30;




PROCEDURE get_systems
 (
     p_api_version               IN  NUMBER,
     p_commit                    IN  VARCHAR2              := fnd_api.g_false,
     p_init_msg_list             IN  VARCHAR2              := fnd_api.g_false,
     p_validation_level          IN  NUMBER                := fnd_api.g_valid_level_full,
     p_system_query_rec          IN  csi_datastructures_pub.system_query_rec,
     p_time_stamp                IN  DATE,
     p_active_systems_only       IN  VARCHAR2 := fnd_api.g_false,
     x_systems_tbl               OUT NOCOPY csi_datastructures_pub.systems_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
 );


PROCEDURE create_system(
    p_api_version                IN   NUMBER,
    p_commit                     IN   VARCHAR2     := fnd_api.g_false,
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN   NUMBER       := fnd_api.g_valid_level_full,
    p_system_rec                 IN    csi_datastructures_pub.system_rec,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_system_id                  OUT NOCOPY  NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE update_system(
    p_api_version                IN   NUMBER,
    p_commit                     IN   VARCHAR2     := fnd_api.g_false,
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN   NUMBER       := fnd_api.g_valid_level_full,
    p_system_rec                 IN   csi_datastructures_pub.system_rec,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE expire_system
 (
     p_api_version                 IN     NUMBER,
     p_commit                      IN     VARCHAR2   := fnd_api.g_false,
     p_init_msg_list               IN     VARCHAR2   := fnd_api.g_false,
     p_validation_level            IN     NUMBER     := fnd_api.g_valid_level_full,
     p_system_rec                  IN     csi_datastructures_pub.system_rec,
     p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
     x_instance_id_lst             OUT NOCOPY    csi_datastructures_pub.id_tbl,
     x_return_status               OUT NOCOPY    VARCHAR2,
     x_msg_count                   OUT NOCOPY    NUMBER,
     x_msg_data                    OUT NOCOPY    VARCHAR2
 );

PROCEDURE validate_systems(
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN   NUMBER       := fnd_api.g_valid_level_full,
    p_validation_mode            IN   VARCHAR2  ,
    p_system_rec                 IN   csi_datastructures_pub.system_rec,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );
--
PROCEDURE Get_system_details
   (
     p_api_version               IN  NUMBER  ,
     p_commit                    IN  VARCHAR2              := fnd_api.g_false,
     p_init_msg_list             IN  VARCHAR2              := fnd_api.g_false,
     p_validation_level          IN  NUMBER                := fnd_api.g_valid_level_full,
     p_system_query_rec          IN  csi_datastructures_pub.system_query_rec,
     p_time_stamp                IN  DATE,
     p_active_systems_only       IN  VARCHAR2              := fnd_api.g_false,
     x_system_header_tbl         OUT NOCOPY csi_datastructures_pub.system_header_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
   );
--
PROCEDURE Resolve_ID_Columns
   ( p_system_header_tbl IN OUT NOCOPY csi_datastructures_pub.system_header_tbl
   );
--
PROCEDURE Get_System_History
   ( p_api_version                IN  NUMBER
    ,p_commit                     IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list              IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level           IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_transaction_id             IN  NUMBER
    ,p_system_id                  IN NUMBER
    ,x_system_history_tbl         OUT NOCOPY csi_datastructures_pub.systems_history_tbl
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
   );
END csi_systems_pvt;

/
