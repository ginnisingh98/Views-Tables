--------------------------------------------------------
--  DDL for Package HZ_HIERARCHY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_HIERARCHY_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHHINSS.pls 120.2 2005/06/16 21:11:59 jhuang noship $*/

-----------------------------
-- declaration of record type
-----------------------------

TYPE hierarchy_node_rec_type IS RECORD(
    hierarchy_type             VARCHAR2(30),
    parent_id                  NUMBER(15),
    parent_table_name          VARCHAR2(30),
    parent_object_type         VARCHAR2(30),
    child_id                   NUMBER(15),
    child_table_name           VARCHAR2(30),
    child_object_type          VARCHAR2(30),
    effective_start_date       DATE,
    effective_end_date         DATE,
    status                     VARCHAR2(1),
    relationship_id            NUMBER(15),
    actual_content_source      VARCHAR2(30)
);

-------------------------------------------------
-- declaration of public procedures and functions
-------------------------------------------------

/**
 * PROCEDURE create_link
 *
 * DESCRIPTION
 *     Creates a hierarchial relationship between two nodes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_hierarchy_node_rec           Hierarchy node record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *    31-JAN-00  Indrajit Sen   o Created
 *
 */

PROCEDURE create_link(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_node_rec                    IN      HIERARCHY_NODE_REC_TYPE,
    x_return_status                         OUT     NOCOPY VARCHAR2,
    x_msg_count                             OUT     NOCOPY NUMBER,
    x_msg_data                              OUT     NOCOPY VARCHAR2
);


/**
 * PROCEDURE update_link
 *
 * DESCRIPTION
 *     Updates a hierarchial relationship between two nodes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_hierarchy_node_rec           Hierarchy node record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *    31-JAN-00  Indrajit Sen   o Created
 *
 */

PROCEDURE update_link(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_hierarchy_node_rec                    IN      HIERARCHY_NODE_REC_TYPE,
    x_return_status                         OUT     NOCOPY VARCHAR2,
    x_msg_count                             OUT     NOCOPY NUMBER,
    x_msg_data                              OUT     NOCOPY VARCHAR2
);


/**
 * PROCEDURE
 *     convert_rel_type
 *
 * DESCRIPTION
 *     Procedure to convert a particular relationship type
 *     to a hierarchical relationship type
 *
 * SCOPE - Public
 *
 * ARGUMENTS  : IN:
 *                       p_rel_type
 *                       p_multi_parent_allowed
 *                       p_incl_unrelated_entities
 *              OUT:
 *          IN/ OUT:
 *
 * RETURNS    :
 *                       Errbuf
 *                       Retcode
 *
 * NOTES      : p_rel_type can be non-hierarchical relationship type
 *              p_multi_parent_allowed is Y/N
 *              p_incl_unrelated_entities is Y/N
 *
 * MODIFICATION HISTORY
 *
 *    31-JAN-00  Indrajit Sen   o Created
 *
 */

PROCEDURE convert_rel_type(
    Errbuf                                  OUT     NOCOPY VARCHAR2,
    Retcode                                 OUT     NOCOPY VARCHAR2,
    p_rel_type                              IN      VARCHAR2,
    p_multi_parent_allowed                  IN      VARCHAR2 DEFAULT 'N',
    p_incl_unrelated_entities               IN      VARCHAR2 DEFAULT 'N'
);

END HZ_HIERARCHY_PUB;

 

/
