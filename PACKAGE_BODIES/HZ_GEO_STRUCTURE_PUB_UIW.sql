--------------------------------------------------------
--  DDL for Package Body HZ_GEO_STRUCTURE_PUB_UIW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_STRUCTURE_PUB_UIW" AS
/*$Header: ARHGSTWB.pls 120.1 2005/08/26 15:22:27 dmmehta noship $ */

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
) AS
  l_geography_type_rec HZ_GEOGRAPHY_STRUCTURE_PUB.GEOGRAPHY_TYPE_REC_TYPE;
BEGIN
  l_geography_type_rec.geography_type := p_geography_type_rec.geography_type;
  l_geography_type_rec.geography_type_name := p_geography_type_rec.geography_type_name;
  l_geography_type_rec.created_by_module := p_geography_type_rec.created_by_module;
  l_geography_type_rec.application_id := p_geography_type_rec.application_id;

  HZ_GEOGRAPHY_STRUCTURE_PUB.create_geography_type (
    p_init_msg_list => p_init_msg_list,
    p_geography_type_rec => l_geography_type_rec,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data);

END;

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
) AS
  l_geo_structure_rec HZ_GEOGRAPHY_STRUCTURE_PUB.GEO_STRUCTURE_REC_TYPE;
BEGIN

  l_geo_structure_rec.geography_id         := p_geo_structure_rec.geography_id;
  l_geo_structure_rec.geography_type       := p_geo_structure_rec.geography_type;
  l_geo_structure_rec.parent_geography_type:= p_geo_structure_rec.parent_geography_type;
  l_geo_structure_rec.created_by_module    := p_geo_structure_rec.created_by_module;
  l_geo_structure_rec.application_id       := p_geo_structure_rec.application_id;

  HZ_GEOGRAPHY_STRUCTURE_PUB.create_geo_structure(
    p_init_msg_list     => p_init_msg_list,
    p_geo_structure_rec => l_geo_structure_rec,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data);

END;


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
    ) AS
BEGIN
  HZ_GEOGRAPHY_STRUCTURE_PUB.delete_geo_structure(
    p_init_msg_list           => p_init_msg_list,
    p_geography_id            => p_geography_id,
    p_geography_type          => p_geography_type,
    p_parent_geography_type   => p_parent_geography_type,
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_msg_data                => x_msg_data);

END;

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
 )AS
 l_geo_rel_type_rec HZ_GEOGRAPHY_STRUCTURE_PUB.GEO_REL_TYPE_REC_TYPE;
BEGIN
  l_geo_rel_type_rec.geography_type        := p_geo_rel_type_rec.geography_type ;
  l_geo_rel_type_rec.parent_geography_type := p_geo_rel_type_rec.parent_geography_type ;
  l_geo_rel_type_rec.status                := p_geo_rel_type_rec.status ;
  l_geo_rel_type_rec.created_by_module     := p_geo_rel_type_rec.created_by_module ;
  l_geo_rel_type_rec.application_id        := p_geo_rel_type_rec.application_id ;

  HZ_GEOGRAPHY_STRUCTURE_PUB.create_geo_rel_type(
    p_init_msg_list             => p_init_msg_list,
    p_geo_rel_type_rec          => l_geo_rel_type_rec,
    x_relationship_type_id      => x_relationship_type_id,
    x_return_status             => x_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data);

END;


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
)AS
  l_zone_type_rec HZ_GEOGRAPHY_STRUCTURE_PUB.ZONE_TYPE_REC_TYPE;
BEGIN

   FOR i in 1 .. p_included_geography_type.count LOOP
     l_zone_type_rec.included_geography_type(i) := p_included_geography_type(i);
   END LOOP;

   l_zone_type_rec.geography_type  := p_zone_type_rec.geography_type;
   l_zone_type_rec.geography_type_name := p_zone_type_rec.geography_type_name;
   l_zone_type_rec.geography_use := p_zone_type_rec.geography_use;
   l_zone_type_rec.limited_by_geography_id := p_zone_type_rec.limited_by_geography_id;
   l_zone_type_rec.postal_code_range_flag := p_zone_type_rec.postal_code_range_flag;
   l_zone_type_rec.created_by_module := p_zone_type_rec.created_by_module;
   l_zone_type_rec.application_id := p_zone_type_rec.application_id;

   HZ_GEOGRAPHY_STRUCTURE_PUB.create_zone_type(
     p_init_msg_list           => p_init_msg_list,
     p_zone_type_rec           => l_zone_type_rec,
     x_return_status           => x_return_status,
     x_msg_count               => x_msg_count,
     x_msg_data                => x_msg_data);

END;



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
 )AS
l_zone_type_rec HZ_GEOGRAPHY_STRUCTURE_PUB.ZONE_TYPE_REC_TYPE;

BEGIN
   FOR i in 1 .. p_included_geography_type.count LOOP
     l_zone_type_rec.included_geography_type(i) := p_included_geography_type(i);
   END LOOP;

   l_zone_type_rec.geography_type  := p_zone_type_rec.geography_type;
   l_zone_type_rec.geography_type_name := p_zone_type_rec.geography_type_name;
   l_zone_type_rec.geography_use := p_zone_type_rec.geography_use;
   l_zone_type_rec.limited_by_geography_id := p_zone_type_rec.limited_by_geography_id;
   l_zone_type_rec.postal_code_range_flag := p_zone_type_rec.postal_code_range_flag;
   l_zone_type_rec.created_by_module := p_zone_type_rec.created_by_module;
   l_zone_type_rec.application_id := p_zone_type_rec.application_id;

  HZ_GEOGRAPHY_STRUCTURE_PUB.update_zone_type(
    p_init_msg_list           => p_init_msg_list,
    p_zone_type_rec           => l_zone_type_rec,
    p_object_version_number   => p_object_version_number,
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_msg_data                => x_msg_data);
END;

END HZ_GEO_STRUCTURE_PUB_UIW;

/
