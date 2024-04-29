--------------------------------------------------------
--  DDL for Package HZ_RELATIONSHIP_TYPE_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_RELATIONSHIP_TYPE_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2RTSS.pls 120.9 2006/08/17 10:15:11 idali noship $ */
/*#
 * This package contains the public APIs for relationship types.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Relationship Type
 * @rep:category BUSINESS_ENTITY HZ_RELATIONSHIP_TYPE
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Relationship Type APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE relationship_type_rec_type IS RECORD(
    relationship_type_id            NUMBER,
    relationship_type               VARCHAR2(30),
    forward_rel_code                VARCHAR2(30),
    backward_rel_code               VARCHAR2(30),
    direction_code                  VARCHAR2(30),
    hierarchical_flag               VARCHAR2(1),
    create_party_flag               VARCHAR2(1),
    allow_relate_to_self_flag       VARCHAR2(1),
    allow_circular_relationships    VARCHAR2(1),
    subject_type                    VARCHAR2(30),
    object_type                     VARCHAR2(30),
    status                          VARCHAR2(1),
    created_by_module               VARCHAR2(150),
    application_id                  NUMBER,
    multiple_parent_allowed         VARCHAR2(1),
    incl_unrelated_entities         VARCHAR2(1),
    forward_role                    VARCHAR2(30),
    backward_role                   VARCHAR2(30)
);

G_MISS_REL_TYPE_REC                 RELATIONSHIP_TYPE_REC_TYPE;

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_relationship_type
 *
 * DESCRIPTION
 *     Creates relationship type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_relationship_type_rec        Relationship type record.
 *   IN/OUT:
 *   OUT:
 *     x_relationship_type_id         Relationship type ID.
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to create a relationship type. This API creates records in the
 * HZ_RELATIONSHIP_TYPES table. The relationship type defines the relationships that you
 * can create between different types of parties or other entities. This API internally
 * creates an additional record when the forward and backward relationship codes are
 * different, indicating that you can create the relationship in two ways.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Relationship Type
 * @rep:doccd 120hztig.pdf Relationship Type APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

PROCEDURE create_relationship_type (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_relationship_type_rec     IN         RELATIONSHIP_TYPE_REC_TYPE,
    x_relationship_type_id      OUT NOCOPY        NUMBER,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
);

/**
 * PROCEDURE update_relationship_type
 *
 * DESCRIPTION
 *     Creates relationship type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_relationship_type_rec        Relationship type record.
 *   IN/OUT:
 *   OUT:
 *     x_relationship_type_id         Relationship type ID.
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
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to update a relationship type. This API updates records
 * in the HZ_RELATIONSHIP_TYPES table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Relationship Type
 * @rep:doccd 120hztig.pdf Relationship Type APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_relationship_type (
    p_init_msg_list            IN          VARCHAR2 := FND_API.G_FALSE,
    p_relationship_type_rec    IN          RELATIONSHIP_TYPE_REC_TYPE,
    p_object_version_number    IN OUT NOCOPY      NUMBER,
    x_return_status            OUT NOCOPY         VARCHAR2,
    x_msg_count                OUT NOCOPY         NUMBER,
    x_msg_data                 OUT NOCOPY         VARCHAR2
);

FUNCTION in_instance_sets (
    p_instance_set_name        IN          VARCHAR2,
    p_instance_id              IN          VARCHAR2
) RETURN  VARCHAR2;

END HZ_RELATIONSHIP_TYPE_V2PUB;

 

/
