--------------------------------------------------------
--  DDL for Package CSI_II_RELATIONSHIPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_II_RELATIONSHIPS_PUB" AUTHID CURRENT_USER AS
/* $Header: csipiirs.pls 120.0 2005/05/25 02:41:01 appldev noship $ */
/*#
 * This is a public API for managing Instance-to-Instance Relationships.
 * It contains routines to Create, Update and Get Instance-to-Instance Relationships.
 * @rep:scope public
 * @rep:product CSI
 * @rep:displayname Manage Instance-to-Instance Relationships
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CSI_ITEM_INSTANCE
*/
-- start of comments
-- package name     : csi_ii_relationships_pub
-- purpose          :
-- history          :
-- note             :
-- end of comments

-- default NUMBER of records fetch per call
g_default_num_rec_fetch  NUMBER := 30;

/*#
 * This procedure gets the list of relationship(s) among item instances.
 * If the parameter p_time_stamp is passed the relationship information would be constructed
 * from the history. Otherwise the current relationship would be retreived.
 * @param p_api_version API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_relationship_query_rec Record structure containing the query criteria
 * @param p_depth Determines the level to be exploded. If null explode all the levels
 * @param p_time_stamp Get the configuration at this given time
 * @param p_active_relationship_only Determines whether to get active relationships only or not
 * @param x_relationship_tbl Contains the output Relationship table structure for the given query
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Relationships
 */
PROCEDURE get_relationships
 (
     p_api_version               IN  NUMBER,
     p_commit                    IN  VARCHAR2 := fnd_api.g_false,
     p_init_msg_list             IN  VARCHAR2 := fnd_api.g_false,
     p_validation_level          IN  NUMBER  := fnd_api.g_valid_level_full,
     p_relationship_query_rec    IN  csi_datastructures_pub.relationship_query_rec,
     p_depth                     IN  NUMBER,
     p_time_stamp                IN  DATE,
     p_active_relationship_only  IN  VARCHAR2 := fnd_api.g_false,
     x_relationship_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
 );


/*#
 * This procedure creates Instance-to-Instance Relationship(s)
 * @param p_api_version API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_relationship_tbl Table of records for instance-to-instance relationships to be created
 * @param p_txn_rec Transaction Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Relationships
 */
PROCEDURE create_relationship(
    p_api_version                IN   NUMBER,
    p_commit                     IN   VARCHAR2   := fnd_api.g_false,
    p_init_msg_list              IN   VARCHAR2   := fnd_api.g_false,
    p_validation_level           IN   NUMBER     := fnd_api.g_valid_level_full,
    p_relationship_tbl           IN OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

/*#
 * This procedure updates Instance-to-Instance Relationship(s)
 * @param p_api_version API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_relationship_tbl Table of records for instance-to-instance relationships to be updated
 * @param p_txn_rec Transaction Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Relationships
 */
PROCEDURE update_relationship
 (
     p_api_version                IN  NUMBER,
     p_commit                     IN  VARCHAR2 := fnd_api.g_false,
     p_init_msg_list              IN  VARCHAR2 := fnd_api.g_false,
     p_validation_level           IN  NUMBER   := fnd_api.g_valid_level_full,
     p_relationship_tbl           IN      csi_datastructures_pub.ii_relationship_tbl,
     p_txn_rec                    IN  OUT NOCOPY csi_datastructures_pub.transaction_rec,
     x_return_status              OUT NOCOPY VARCHAR2,
     x_msg_count                  OUT NOCOPY NUMBER,
     x_msg_data                   OUT NOCOPY VARCHAR2
 );

PROCEDURE expire_relationship
 (
     p_api_version                 IN  NUMBER,
     p_commit                      IN  VARCHAR2         := fnd_api.g_false,
     p_init_msg_list               IN  VARCHAR2         := fnd_api.g_false,
     p_validation_level            IN  NUMBER     := fnd_api.g_valid_level_full,
     p_relationship_rec            IN  csi_datastructures_pub.ii_relationship_rec,
     p_txn_rec                     IN  OUT NOCOPY csi_datastructures_pub.transaction_rec,
     x_instance_id_lst             OUT NOCOPY csi_datastructures_pub.id_tbl,
     x_return_status               OUT NOCOPY VARCHAR2,
     x_msg_count                   OUT NOCOPY NUMBER,
     x_msg_data                    OUT NOCOPY VARCHAR2
 );

end csi_ii_relationships_pub;

 

/
