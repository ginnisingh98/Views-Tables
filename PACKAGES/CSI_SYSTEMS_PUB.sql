--------------------------------------------------------
--  DDL for Package CSI_SYSTEMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_SYSTEMS_PUB" AUTHID CURRENT_USER AS
/* $Header: csipsyss.pls 120.0 2005/05/25 02:30:57 appldev noship $ */
/*#
 * This is a public API for managing Systems.
 * It contains routines to Create, Update and Get Systems.
 * @rep:scope public
 * @rep:product CSI
 * @rep:displayname Manage Systems
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CSI_ITEM_INSTANCE
*/
-- Start of Comments
-- Package name     : CSI_SYSTEMS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

/*#
 * This procedure gets the System information satisfying the query criteria provided by the
 * calling application. If the p_time_stamp is passed then the information would be constructed
 * from history. Otherwise the current system information would be retreived.
 * @param p_api_version API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_system_query_rec System Query Record structure containing the query criteria
 * @param p_time_stamp System information as of given time
 * @param p_active_systems_only Determines whether to get active systems or all systems based on the query
 * @param x_systems_tbl Output Table structure containing the systems
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Systems
 */
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


/*#
 * This procedure creates a new System in Install Base.
 * @param p_api_version API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_system_rec System Record containing information about the system to be created
 * @param p_txn_rec Transaction Record structure
 * @param x_system_id Contains the created system ID
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create System
 */
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

/*#
 * This procedure updates an existing system record in Install Base.
 * @param p_api_version API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_system_rec System Record containing information about the system to be updated
 * @param p_txn_rec Transaction Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update System
 */
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
     p_commit                      IN     VARCHAR2   := FND_API.G_FALSE,
     p_init_msg_list               IN     VARCHAR2   := FND_API.G_FALSE,
     p_validation_level            IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
     p_system_rec                  IN     csi_datastructures_pub.system_rec,
     p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
     x_instance_id_lst             OUT NOCOPY    csi_datastructures_pub.id_tbl,
     x_return_status               OUT NOCOPY    VARCHAR2,
     x_msg_count                   OUT NOCOPY    NUMBER,
     x_msg_data                    OUT NOCOPY    VARCHAR2
 );


end csi_systems_pub;

 

/
