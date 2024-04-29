--------------------------------------------------------
--  DDL for Package HZ_GEO_STRUCTURE_PUB_UIW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_STRUCTURE_PUB_UIW" AUTHID CURRENT_USER AS
/*$Header: ARHGSTWS.pls 120.1 2005/08/26 15:22:23 dmmehta noship $ */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE incl_geo_type_tbl_type IS TABLE OF VARCHAR2(30)
    INDEX BY BINARY_INTEGER;

TYPE geography_type_rec_type IS RECORD(
     geography_type                          VARCHAR2(30),
     geography_type_name                     VARCHAR2(80),
     created_by_module                       VARCHAR2(150),
     application_id                          NUMBER
    );

TYPE geo_structure_rec_type IS RECORD(
    geography_id                            NUMBER,
    geography_type                          VARCHAR2(30),
    parent_geography_type                   VARCHAR2(30),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
    );

TYPE geo_rel_type_rec_type IS RECORD(
      geography_type                     VARCHAR2(30),
      parent_geography_type              VARCHAR2(30),
      status                             VARCHAR2(1),
      created_by_module                  VARCHAR2(150),
      application_id                     NUMBER
);

TYPE zone_type_rec_type IS RECORD(
   geography_type      VARCHAR2(30),
   geography_type_name VARCHAR2(80),
   geography_use       VARCHAR2(30),
   limited_by_geography_id NUMBER,
   postal_code_range_flag  VARCHAR2(1) DEFAULT 'N',
--   included_geography_type incl_geo_type_tbl_type,
   created_by_module     VARCHAR2(150),
   application_id	NUMBER
     );


--G_MISS_GEO_TYPE_REC                 GEOGRAPHY_TYPE_REC_TYPE;

-------------------------------------------------
-- declaration of public procedures and functions
-------------------------------------------------

/**
 * PROCEDURE create_geography_type
 *
 * DESCRIPTION
 *     Creates Geography type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_type_rec           Geography type record.
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
 *   06-28-2005    Kate Shan        o Created.
 *
 */

PROCEDURE create_geography_type (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_type_rec        IN         GEOGRAPHY_TYPE_REC_TYPE,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
);

/**
 * PROCEDURE create_geo_structure
 *
 * DESCRIPTION
 *     Creates Geography Structure.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geo_structure_rec            Geography structure type record.

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
 *   06-28-2005    Kate Shan        o Created.
 *
 */


PROCEDURE create_geo_structure(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_geo_structure_rec                   IN         GEO_STRUCTURE_REC_TYPE,
    x_return_status             	  OUT  NOCOPY      VARCHAR2,
    x_msg_count                 	  OUT  NOCOPY      NUMBER,
    x_msg_data                  	  OUT  NOCOPY      VARCHAR2
);


/**
 * PROCEDURE delete_geo_structure
 *
 * DESCRIPTION
 *     Deletes the row in the structure. Disables the relationship_type if it is not used by any other structure.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geo_structure_rec            Geography structure type record.

 *   IN/OUT:
 *
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
 *   06-28-2005    Kate Shan        o Created.
 *
 */

 PROCEDURE delete_geo_structure(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_id                        IN         NUMBER,
    p_geography_type                      IN         VARCHAR2,
    p_parent_geography_type               IN         VARCHAR2,
    x_return_status             	  OUT  NOCOPY      VARCHAR2,
    x_msg_count                 	  OUT  NOCOPY      NUMBER,
    x_msg_data                  	  OUT  NOCOPY      VARCHAR2
    );

/**
 * PROCEDURE create_geography_rel_type
 *
 * DESCRIPTION
 *     Creates Geography Relationship type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_rel_type_rec       Geography Relationship type record.
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
 *   06-28-2005    Kate Shan        o Created.
 *
 */

 PROCEDURE create_geo_rel_type(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_geo_rel_type_rec                    IN         GEO_REL_TYPE_REC_TYPE,
    x_relationship_type_id                OUT   NOCOPY     NUMBER,
    x_return_status             	  OUT   NOCOPY     VARCHAR2,
    x_msg_count                 	  OUT   NOCOPY     NUMBER,
    x_msg_data                  	  OUT   NOCOPY     VARCHAR2
 );


 /**
 * PROCEDURE create_zone_type
 *
 * DESCRIPTION
 *     Creates Zone Type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_zone_type_rec                Zone_type type record.
 *     included_geography_type        incl_geo_type_tbl_type,
 *   IN/OUT:
 *   OUT:
 *
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
 *     06-28-2005    Kate Shan        o Created.
 *
 */

PROCEDURE create_zone_type(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_zone_type_rec             IN         ZONE_TYPE_REC_TYPE,
    p_included_geography_type   IN         INCL_GEO_TYPE_TBL_TYPE,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
);



/**
 * PROCEDURE update_zone_type
 *
 * DESCRIPTION
 *     Updates zone type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geographytype                Geography type.
 *     p_limited_by_geography_id
 *     p_postal_code_range_flag
 *   IN/OUT:
 *     p_object_version_number        object version number of the row being updated
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
 *   06-28-2005    Kate Shan        o Created.
 *
 */

 PROCEDURE update_zone_type(
    p_init_msg_list             	  IN         VARCHAR2 := FND_API.G_FALSE,
    p_zone_type_rec                       IN         ZONE_TYPE_REC_TYPE,
    p_included_geography_type   IN         INCL_GEO_TYPE_TBL_TYPE,
    p_object_version_number    		  IN OUT NOCOPY  NUMBER,
    x_return_status             	  OUT  NOCOPY      VARCHAR2,
    x_msg_count                 	  OUT  NOCOPY      NUMBER,
    x_msg_data                  	  OUT  NOCOPY      VARCHAR2
 );

END HZ_GEO_STRUCTURE_PUB_UIW;

 

/
