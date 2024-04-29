--------------------------------------------------------
--  DDL for Package HZ_HIERARCHY_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_HIERARCHY_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2HISS.pls 120.7 2006/08/17 10:19:03 idali noship $*/
/*#
 * This package includes the public APIs for hierarchy retrieval.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Hierarchy Retrieval
 * @rep:category BUSINESS_ENTITY HZ_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Hierarchy Retrieval APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

-----------------------------
-- declaration of record type
-----------------------------

TYPE related_nodes_list_rec IS RECORD (
    related_node_id            NUMBER(15),
    related_node_table_name    VARCHAR2(30),
    related_node_object_type   VARCHAR2(30),
    level_number               NUMBER(15),
    top_parent_flag            VARCHAR2(1),
    leaf_child_flag            VARCHAR2(1),
    effective_start_date       DATE,
    effective_end_date         DATE,
    relationship_id            NUMBER(15)
   );

TYPE related_nodes_list_type IS TABLE OF related_nodes_list_rec INDEX BY BINARY_INTEGER;

-------------------------------------------------
-- declaration of public procedures and functions
-------------------------------------------------

/*#
 * Use this routine to determine whether or not an entity is the top parent, or root, of a
 * hierarchy. You must pass a valid hierarchy relationship type and any necessary parent
 * information to the API, which then returns Y or N.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Top Parent Check
 * @rep:doccd 120hztig.pdf Hierarchy Retrieval APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE is_top_parent(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_type                        IN      VARCHAR2,
    p_parent_id                             IN      NUMBER,
    p_parent_table_name                     IN      VARCHAR2 := 'HZ_PARTIES',
    p_parent_object_type                    IN      VARCHAR2 := 'ORGANIZATION',
    p_effective_date                        IN      DATE := SYSDATE,
    x_result                                OUT NOCOPY     VARCHAR2,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/*#
 * Use this routine to check whether two entities have a parent-child relationship in a
 * hierarchy. You must pass a valid hierarchy relationship type and any necessary parent
 * and child information to the API, which then returns Y or N.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Parent Child Relationship
 * @rep:doccd 120hztig.pdf Hierarchy Retrieval APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE check_parent_child(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_type                        IN      VARCHAR2,
    p_parent_id                             IN      NUMBER,
    p_parent_table_name                     IN      VARCHAR2 := 'HZ_PARTIES',
    p_parent_object_type                    IN      VARCHAR2 := 'ORGANIZATION',
    p_child_id                              IN      NUMBER,
    p_child_table_name                      IN      VARCHAR2 := 'HZ_PARTIES',
    p_child_object_type                     IN      VARCHAR2 := 'ORGANIZATION',
    p_effective_date                        IN      DATE := SYSDATE,
    x_result                                OUT NOCOPY     VARCHAR2,
    x_level_number                          OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/*#
 * Use this routine to retrieve the parent nodes of a child in a hierarchy. You must pass
 * a valid hierarchy relationship type and any necessary parent type and child node
 * information to the API, which then returns a set of parent nodes in that hierarchy.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Parent Nodes
 * @rep:doccd 120hztig.pdf Hierarchy Retrieval APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_parent_nodes(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_type                        IN      VARCHAR2,
    p_child_id                              IN      NUMBER,
    p_child_table_name                      IN      VARCHAR2,
    p_child_object_type                     IN      VARCHAR2,
    p_parent_table_name                     IN      VARCHAR2,
    p_parent_object_type                    IN      VARCHAR2,
    p_include_node                          IN      VARCHAR2 := 'Y',
    p_effective_date                        IN      DATE := SYSDATE,
    p_no_of_records                         IN      NUMBER := 100,
    x_related_nodes_list                    OUT NOCOPY    RELATED_NODES_LIST_TYPE,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/*#
 * Use this routine to retrieve the child nodes of a parent in a hierarchy. You must pass
 * a valid hierarchy relationship type and any necessary child type and parent node
 * information to the API, which then returns a set of child nodes in that hierarchy.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Child Nodes
 * @rep:doccd 120hztig.pdf Hierarchy Retrieval APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_child_nodes(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_type                        IN      VARCHAR2,
    p_parent_id                             IN      NUMBER,
    p_parent_table_name                     IN      VARCHAR2,
    p_parent_object_type                    IN      VARCHAR2,
    p_child_table_name                      IN      VARCHAR2,
    p_child_object_type                     IN      VARCHAR2,
    p_include_node                          IN      VARCHAR2 := 'Y',
    p_effective_date                        IN      DATE := SYSDATE,
    p_no_of_records                         IN      NUMBER := 100,
    x_related_nodes_list                    OUT NOCOPY    RELATED_NODES_LIST_TYPE,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/*#
 * Use this routine to retrieve the top parent nodes in a hierarchy. You must pass a
 * valid hierarchy relationship type to the API, which then returns a set of the top parent
 * nodes in that hierarchy.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Top Parent Nodes
 * @rep:doccd 120hztig.pdf Hierarchy Retrieval APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE get_top_parent_nodes(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_type                        IN      VARCHAR2,
    p_parent_table_name                     IN      VARCHAR2 := 'HZ_PARTIES',
    p_parent_object_type                    IN      VARCHAR2 := 'ALL',
    p_effective_date                        IN      DATE := SYSDATE,
    p_no_of_records                         IN      NUMBER := 100,
    x_top_parent_list                       OUT NOCOPY    RELATED_NODES_LIST_TYPE,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

END HZ_HIERARCHY_V2PUB;

 

/
