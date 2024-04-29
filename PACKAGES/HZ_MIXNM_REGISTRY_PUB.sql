--------------------------------------------------------
--  DDL for Package HZ_MIXNM_REGISTRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MIXNM_REGISTRY_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHXREGS.pls 120.1 2005/06/16 21:16:45 jhuang noship $ */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE entity_attribute_rec_type IS RECORD (
    entity_name                       VARCHAR2(30),
    attribute_name                    VARCHAR2(30),
    created_by_module                 VARCHAR2(150),
    application_id                    NUMBER
);

TYPE DATA_SOURCE_TBL IS TABLE OF VARCHAR2(30);

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE Add_EntityAttribute
 *
 * DESCRIPTION
 *     Add the new entity and / or attribute into the dictionary.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_entity_attribute_rec         Entity Attribute record.
 *     p_data_source_tbl              PL/SQL Table for Data Source Setup.
 *   IN/OUT:
 *   OUT:
 *     x_entity_attr_id               Dictionary ID.
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
 *   02-12-2002    Jianying Huang      o Created.
 */

PROCEDURE Add_EntityAttribute (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_entity_attribute_rec                  IN     ENTITY_ATTRIBUTE_REC_TYPE,
    p_data_source_tab                       IN     DATA_SOURCE_TBL,
    x_entity_attr_id                        OUT    NOCOPY NUMBER,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
);

/**
 * PROCEDURE Get_EntityAttribute
 *
 * DESCRIPTION
 *     Get the entity / attribute from the dictionary.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_entity_name                  Entity Name
 *     p_attribute_name               Attribute Name
 *   IN/OUT:
 *   OUT:
 *     x_data_source_tbl              PL/SQL Table for Data Source Setup.
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
 *   02-12-2002    Jianying Huang      o Created.
 */

PROCEDURE Get_EntityAttribute (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_entity_name                           IN     VARCHAR2,
    p_attribute_name                        IN     VARCHAR2,
    x_data_source_tbl                       OUT    NOCOPY DATA_SOURCE_TBL,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
);

/**
 * PROCEDURE Remove_EntityAttribute
 *
 * DESCRIPTION
 *     Remove the entity / attribute from the dictionary.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_entity_name                  Entity Name
 *     p_attribute_name               Attribute Name
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
 *   02-12-2002    Jianying Huang      o Created.
 */

PROCEDURE Remove_EntityAttribute (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_entity_name                           IN     VARCHAR2,
    p_attribute_name                        IN     VARCHAR2,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
);

/**
 * PROCEDURE Remove_EntityAttrDataSource
 *
 * DESCRIPTION
 *     Remove the entity / attribute's data sources from the dictionary.
 *     The data sources must be un-selected.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_entity_name                  Entity Name
 *     p_attribute_name               Attribute Name
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
 *   02-12-2002    Jianying Huang      o Created.
 */

PROCEDURE Remove_EntityAttrDataSource (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_entity_name                           IN     VARCHAR2,
    p_attribute_name                        IN     VARCHAR2,
    p_data_source_tbl                       IN     DATA_SOURCE_TBL,
    x_return_status                         OUT    NOCOPY VARCHAR2,
    x_msg_count                             OUT    NOCOPY NUMBER,
    x_msg_data                              OUT    NOCOPY VARCHAR2
);

END HZ_MIXNM_REGISTRY_PUB;

 

/
