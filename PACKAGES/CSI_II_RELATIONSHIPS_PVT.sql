--------------------------------------------------------
--  DDL for Package CSI_II_RELATIONSHIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_II_RELATIONSHIPS_PVT" AUTHID CURRENT_USER AS
/* $Header: csiviirs.pls 120.2.12010000.2 2008/12/15 19:30:35 lakmohan ship $ */
-- start of comments
-- PACKAGE name     : csi_ii_relationships_pvt
-- purpose          :
-- history          :
-- note             :
-- END of comments

-- default NUMBER of records fetch per call
g_default_num_rec_fetch  NUMBER := 30;

/* Start of Cyclic Relationships */

TYPE instance_rec IS RECORD
( instance_id  NUMBER,
  hop          NUMBER );

TYPE instance_tbl IS TABLE OF instance_rec
INDEX BY BINARY_INTEGER ;
--
TYPE REL_COLOR_REC IS RECORD
   ( node_id     NUMBER,
     color_code  VARCHAR2(1)
   );
TYPE REL_COLOR_TBL IS TABLE OF REL_COLOR_REC INDEX BY BINARY_INTEGER;
--
PROCEDURE Get_Cyclic_Node
     ( p_instance_id      IN         NUMBER,
       p_cyclic_node      OUT NOCOPY NUMBER,
       p_rel_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
       p_stop_at_cyclic   IN         VARCHAR2 DEFAULT FND_API.G_TRUE,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2 );
--
PROCEDURE get_rel_for_instance
       (p_instance_id IN NUMBER,
        p_time_stamp IN DATE,
        p_active_relationship_only IN VARCHAR2,
        x_relationship_tbl IN OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl) ;

PROCEDURE get_neighbors_for_instance
       (p_instance_id IN NUMBER ,
        p_hop  IN NUMBER ,
        p_depth IN NUMBER ,
        p_time_stamp IN DATE,
        p_active_relationship_only IN VARCHAR2,
        x_neighbor_inst_tbl OUT NOCOPY instance_tbl) ;

PROCEDURE get_cyclic_relationships
 (
     p_api_version               IN  NUMBER,
     p_commit                    IN  VARCHAR2 := fnd_api.g_false,
     p_init_msg_list             IN  VARCHAR2 := fnd_api.g_false,
     p_validation_level          IN  NUMBER  := fnd_api.g_valid_level_full,
     p_instance_id               IN  NUMBER ,
     p_depth                     IN  NUMBER,
     p_time_stamp                IN  DATE,
     p_active_relationship_only  IN  VARCHAR2 := fnd_api.g_false,
     x_relationship_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
 );

/* End of Cyclic Relationships */

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
     p_recursive_flag            IN  VARCHAR2 := fnd_api.g_false,
     x_relationship_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
 );


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

PROCEDURE update_relationship
 (
     p_api_version                IN  NUMBER,
     p_commit                     IN  VARCHAR2 := fnd_api.g_false,
     p_init_msg_list              IN  VARCHAR2 := fnd_api.g_false,
     p_validation_level           IN  NUMBER   := fnd_api.g_valid_level_full,
     p_relationship_tbl           IN  csi_datastructures_pub.ii_relationship_tbl,
     p_replace_flag               IN  VARCHAR2 := fnd_api.g_false,
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
     p_validation_level            IN  NUMBER           := fnd_api.g_valid_level_full,
     p_relationship_rec            IN  csi_datastructures_pub.ii_relationship_rec,
     p_txn_rec                     IN  OUT NOCOPY csi_datastructures_pub.transaction_rec,
     x_instance_id_lst             OUT NOCOPY csi_datastructures_pub.id_tbl,
     x_return_status               OUT NOCOPY VARCHAR2,
     x_msg_count                   OUT NOCOPY NUMBER,
     x_msg_data                    OUT NOCOPY VARCHAR2
 );

/*----------------------------------------------------------*/
/* Procedure name:  Resolve_id_columns                      */
/* Description : This procudure gets the descriptions for   */
/*               id columns                                 */
/*----------------------------------------------------------*/

PROCEDURE  Resolve_id_columns
 (
     p_rel_history_tbl  IN OUT NOCOPY  csi_datastructures_pub.relationship_history_tbl
 );

/*------------------------------------------------------------*/
/* Procedure name:  get_inst_relationship_hist                */
/* Description :    Procedure used to get inst relationships  */
/*                  from history for a given transaction_id   */
/*------------------------------------------------------------*/

PROCEDURE get_inst_relationship_hist
(
      p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_transaction_id          IN  NUMBER
     ,x_rel_history_tbl         OUT NOCOPY csi_datastructures_pub.relationship_history_tbl
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
);


PROCEDURE Get_Next_Level
    (p_object_id                 IN  NUMBER,
     p_relationship_id           IN  NUMBER,
     p_subject_id                IN  NUMBER,
     p_rel_tbl                   OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     p_rel_type_code             IN  VARCHAR2,
     p_time_stamp                IN  DATE,
     p_active_relationship_only  IN  VARCHAR2,
     p_active_instances_only     IN  VARCHAR2 DEFAULT fnd_api.g_true,
     p_config_only               IN  VARCHAR2 DEFAULT fnd_api.g_false -- if true will retrieve instances with config keys
    );
  --
  FUNCTION Parent_of
     ( p_subject_id      IN  NUMBER,
       p_rel_tbl         IN  csi_datastructures_pub.ii_relationship_tbl
     ) RETURN NUMBER;
  --

  PROCEDURE check_for_object
    ( p_subject_id             IN      NUMBER,
      p_object_id              IN      NUMBER,
      p_relationship_type_code IN      VARCHAR2,
      x_return_status          OUT NOCOPY     VARCHAR2,
      x_msg_count              OUT NOCOPY     NUMBER,
      x_msg_data               OUT NOCOPY     VARCHAR2);

  FUNCTION Is_link_type
    ( p_instance_id          IN      NUMBER
    ) RETURN BOOLEAN;

  FUNCTION relationship_for_link
    ( p_instance_id          IN      NUMBER,
      p_mode                 IN      VARCHAR2,
      p_relationship_id      IN      NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE DFS
    (p_relationship_rec    IN  csi_datastructures_pub.ii_relationship_rec,
     p_active_relationship_only  IN  VARCHAR2,
     p_active_instances_only     IN  VARCHAR2,
     p_config_only               IN  VARCHAR2
    );

  PROCEDURE Get_Children
    (p_relationship_query_rec    IN  csi_datastructures_pub.relationship_query_rec,
     p_rel_tbl                   OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     p_depth                     IN  NUMBER,
     p_active_relationship_only  IN  VARCHAR2,
     p_active_instances_only     IN  VARCHAR2 DEFAULT fnd_api.g_true, -- should be passed as false only when un-expiring
     p_config_only               IN  VARCHAR2 DEFAULT fnd_api.g_false, -- if true will retrieve instances with config keys
     p_time_stamp                IN  DATE,
     p_get_dfs                   IN  VARCHAR2 DEFAULT FND_API.G_TRUE,
     p_ii_relationship_level_tbl OUT NOCOPY csi_ii_relationships_pvt.ii_relationship_level_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
    );
  --
  PROCEDURE Get_Top_Most_Parent
     ( p_subject_id      IN  NUMBER,
       p_rel_type_code   IN  VARCHAR2,
       p_object_id       OUT NOCOPY NUMBER
     );
PROCEDURE Get_Next_Level
    (p_object_id                 IN  NUMBER,
     p_rel_tbl                   OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl
    );

PROCEDURE Get_Children
    (p_object_id     IN  NUMBER,
     p_rel_tbl       OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl
    );

PROCEDURE Get_Immediate_Parents
  ( p_subject_id       IN NUMBER,
    p_rel_type_code    IN VARCHAR2,
    p_rel_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl
  );

TYPE ii_relationship_level_rec IS RECORD
(
    relationship_id    NUMBER := FND_API.G_MISS_NUM,
    current_level      NUMBER := FND_API.G_MISS_NUM
);

TYPE  ii_relationship_level_tbl IS TABLE OF ii_relationship_level_rec
                            INDEX BY BINARY_INTEGER;

-- Begin Add Code for Siebel Genesis Project
FUNCTION Get_Root_Parent
(
    p_subject_id      IN  NUMBER,
    p_rel_type_code   IN  VARCHAR2,
    p_object_id       IN  NUMBER
) RETURN NUMBER;
-- End Add Code for Siebel Genesis Project

END csi_ii_relationships_pvt;

/
