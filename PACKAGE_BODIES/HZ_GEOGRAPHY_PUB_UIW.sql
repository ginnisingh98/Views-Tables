--------------------------------------------------------
--  DDL for Package Body HZ_GEOGRAPHY_PUB_UIW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEOGRAPHY_PUB_UIW" AS
/*$Header: ARHGEOWB.pls 120.1 2005/10/26 14:06:46 idali noship $ */


/**
 * PROCEDURE create_master_relation
 *
 * DESCRIPTION
 *     Creates Geography Relationships.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_master_relation_rec           Geography type record.
 *   IN/OUT:
 *   OUT:
 *     x_relationship_id              Returns relationship_id for the relationship created.
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
 *     06-20-2005    Kate Shan           o Created.
 *
 */

PROCEDURE create_master_relation (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_master_relation_rec       IN         MASTER_RELATION_REC_TYPE,
    x_relationship_id           OUT   NOCOPY     NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
) IS
  l_master_relation_rec HZ_GEOGRAPHY_PUB.MASTER_RELATION_REC_TYPE;
BEGIN

    l_master_relation_rec.geography_id := p_master_relation_rec.geography_id;
    l_master_relation_rec.parent_geography_id := p_master_relation_rec.parent_geography_id;
    l_master_relation_rec.start_date := p_master_relation_rec.start_date;
    l_master_relation_rec.end_date := p_master_relation_rec.end_date;
    l_master_relation_rec.created_by_module := p_master_relation_rec.created_by_module;
    l_master_relation_rec.application_id := p_master_relation_rec.application_id;

    HZ_GEOGRAPHY_PUB.create_master_relation (
        p_init_msg_list => p_init_msg_list,
        p_master_relation_rec => l_master_relation_rec,
        x_relationship_id  => x_relationship_id,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

END create_master_relation;


/**
 * PROCEDURE update_relationship
 *
 * DESCRIPTION
 *     Updates Geography Relationships.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_master_relation_rec          Geography type record.
 *     p_object_version_number        Object version number of the row
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
 *     06-20-2005    Kate Shan           o Created.
 *
 */

PROCEDURE update_relationship (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_relationship_id           IN         NUMBER,
    p_status                    IN         VARCHAR2,
    p_object_version_number     IN OUT  NOCOPY   NUMBER,
    x_return_status             OUT     NOCOPY   VARCHAR2,
    x_msg_count                 OUT     NOCOPY   NUMBER,
    x_msg_data                  OUT     NOCOPY   VARCHAR2
) IS
BEGIN

   HZ_GEOGRAPHY_PUB.update_relationship(
    p_init_msg_list => p_init_msg_list,
    p_relationship_id => p_relationship_id,
    p_status => p_status,
    p_object_version_number => p_object_version_number,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data );

END update_relationship;

/**
 * PROCEDURE create_geo_identifier
 *
 * DESCRIPTION
 *     Creates Geography Identifiers.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geo_identifier_rec           Geo_identifier type record.
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
 *     06-20-2005    Kate Shan           o Created.
 *
 */

PROCEDURE create_geo_identifier(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geo_identifier_rec        IN         GEO_IDENTIFIER_REC_TYPE,
    x_return_status             OUT  NOCOPY      VARCHAR2,
    x_msg_count                 OUT  NOCOPY      NUMBER,
    x_msg_data                  OUT  NOCOPY      VARCHAR2
) IS
  l_geo_identifier_rec HZ_GEOGRAPHY_PUB.GEO_IDENTIFIER_REC_TYPE;
BEGIN

  l_geo_identifier_rec.geography_id := p_geo_identifier_rec.geography_id;
  l_geo_identifier_rec.identifier_subtype := p_geo_identifier_rec.identifier_subtype;
  l_geo_identifier_rec.identifier_value := p_geo_identifier_rec.identifier_value;
  l_geo_identifier_rec.identifier_type := p_geo_identifier_rec.identifier_type;
  l_geo_identifier_rec.geo_data_provider := p_geo_identifier_rec.geo_data_provider;
  l_geo_identifier_rec.primary_flag := p_geo_identifier_rec.primary_flag;
  l_geo_identifier_rec.language_code := p_geo_identifier_rec.language_code;
  l_geo_identifier_rec.created_by_module := p_geo_identifier_rec.created_by_module;
  l_geo_identifier_rec.application_id := p_geo_identifier_rec.application_id;


  HZ_GEOGRAPHY_PUB.create_geo_identifier(
    p_init_msg_list => p_init_msg_list,
    p_geo_identifier_rec => l_geo_identifier_rec,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data  => x_msg_data );

END create_geo_identifier;

/**
 * PROCEDURE update_geo_identifier
 *
 * DESCRIPTION
 *     Creates Geography Identifiers.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geo_identifier_rec           Geo_identifier type record.
 *
 *   IN/OUT:
 *     p_object_version_number
 *   OUT:
 *     x_cp_request_id                Concurrent Program Request Id,whenever CP
 *                                    to update denormalized data gets kicked off.
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
 *     06-20-2005    Kate Shan           o Created.
 *     26-OCT-2005   Idris Ali           o Bug 4578867 Added parameter x_cp_request_id.
 *
 */
PROCEDURE update_geo_identifier (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geo_identifier_rec        IN         GEO_IDENTIFIER_REC_TYPE,
    p_object_version_number     IN OUT  NOCOPY   NUMBER,
    x_cp_request_id             OUT     NOCOPY   NUMBER,  --Bug 4578867
    x_return_status             OUT     NOCOPY   VARCHAR2,
    x_msg_count                 OUT     NOCOPY   NUMBER,
    x_msg_data                  OUT     NOCOPY   VARCHAR2
) IS
  l_geo_identifier_rec HZ_GEOGRAPHY_PUB.GEO_IDENTIFIER_REC_TYPE;
BEGIN

  l_geo_identifier_rec.geography_id := p_geo_identifier_rec.geography_id;
  l_geo_identifier_rec.identifier_subtype := p_geo_identifier_rec.identifier_subtype;
  l_geo_identifier_rec.identifier_value := p_geo_identifier_rec.identifier_value;
  l_geo_identifier_rec.identifier_type := p_geo_identifier_rec.identifier_type;
  l_geo_identifier_rec.geo_data_provider := p_geo_identifier_rec.geo_data_provider;
  l_geo_identifier_rec.primary_flag := p_geo_identifier_rec.primary_flag;
  l_geo_identifier_rec.language_code := p_geo_identifier_rec.language_code;
  l_geo_identifier_rec.created_by_module := p_geo_identifier_rec.created_by_module;
  l_geo_identifier_rec.application_id := p_geo_identifier_rec.application_id;
  l_geo_identifier_rec.new_identifier_subtype := p_geo_identifier_rec.new_identifier_subtype; -- Bug 4578867
  l_geo_identifier_rec.new_identifier_value := p_geo_identifier_rec.new_identifier_value;


  HZ_GEOGRAPHY_PUB.update_geo_identifier (
    p_init_msg_list => p_init_msg_list,
    p_geo_identifier_rec => l_geo_identifier_rec,
    p_object_version_number => p_object_version_number,
    x_cp_request_id => x_cp_request_id, --Bug 4578867
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
   );

END update_geo_identifier;

/**
 * PROCEDURE delete_geo_identifier
 *
 * DESCRIPTION
 *     Deletes Geography Identifiers.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_id                 geography id
 *     p_identifier_type
 *     p_identifier_subtype
 *     p_identifier_value
 *
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
 *     06-20-2005    Kate Shan           o Created.
 *
 */

 PROCEDURE delete_geo_identifier(
      p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
      p_geography_id		IN NUMBER,
      p_identifier_type	        IN VARCHAR2,
      p_identifier_subtype	IN VARCHAR2,
      p_identifier_value        IN VARCHAR2,
      p_language_code           IN VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT  NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
      ) IS
BEGIN
  HZ_GEOGRAPHY_PUB.delete_geo_identifier(
      p_init_msg_list => p_init_msg_list,
      p_geography_id => p_geography_id,
      p_identifier_type => p_identifier_type,
      p_identifier_subtype => p_identifier_subtype,
      p_identifier_value => p_identifier_value,
      p_language_code => p_language_code,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
  );

END delete_geo_identifier;


/**
 * PROCEDURE create_master_geography
 *
 * DESCRIPTION
 *     Creates Master Geography.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_master_geography_rec         Master Geography type record.
 *   IN/OUT:
 *   OUT:
 *
 *     x_geography_id                 Return ID of the geography being created.
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
 *     06-20-2005    Kate Shan           o Created.
 *
 */

PROCEDURE create_master_geography(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_master_geography_rec      IN         MASTER_GEOGRAPHY_REC_TYPE,
    p_parent_geography_id       IN         PARENT_GEOGRAPHY_TBL_TYPE,
    x_geography_id              OUT   NOCOPY     NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
) IS
  l_master_geography_rec HZ_GEOGRAPHY_PUB.MASTER_GEOGRAPHY_REC_TYPE;
  l_parent_geography_id  HZ_GEOGRAPHY_PUB.parent_geography_tbl_type;
BEGIN

  FOR i in 1 ..p_parent_geography_id.count LOOP
    l_parent_geography_id(i) := p_parent_geography_id(i);
  END LOOP;

  l_master_geography_rec.geography_type := p_master_geography_rec.geography_type;
  l_master_geography_rec.geography_name := p_master_geography_rec.geography_name;
  l_master_geography_rec.geography_code := p_master_geography_rec.geography_code;
  l_master_geography_rec.geography_code_type := p_master_geography_rec.geography_code_type;
  IF l_master_geography_rec.start_date = fnd_api.g_miss_date or l_master_geography_rec.start_date is null THEN
    l_master_geography_rec.start_date :=sysdate;
  END IF;
  IF l_master_geography_rec.end_date = fnd_api.g_miss_date or l_master_geography_rec.end_date is null THEN
    l_master_geography_rec.end_date := to_date('31-12-4712','DD-MM-YYYY');
  END IF;
  l_master_geography_rec.geo_data_provider := p_master_geography_rec.geo_data_provider;
  l_master_geography_rec.language_code := p_master_geography_rec.language_code;
  l_master_geography_rec.parent_geography_id := l_parent_geography_id;
  l_master_geography_rec.timezone_code := p_master_geography_rec.timezone_code;
  l_master_geography_rec.created_by_module := p_master_geography_rec.created_by_module;
  l_master_geography_rec.application_id := p_master_geography_rec.application_id;

  HZ_GEOGRAPHY_PUB.create_master_geography(
    p_init_msg_list => p_init_msg_list,
    p_master_geography_rec => l_master_geography_rec,
    x_geography_id => x_geography_id,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

END create_master_geography;

/**
 * PROCEDURE update_geography
 *
 * DESCRIPTION
 *     Updates Geography
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_master_geography_rec         Master Geography type record.
 *
 *   IN/OUT:
 *     p_object_version_number
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
 *     06-20-2005    Kate Shan           o Created.
 *
 */
PROCEDURE update_geography (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_id              IN        NUMBER,
    p_end_date                  IN        DATE,
    p_timezone_code             IN        VARCHAR2,
    p_object_version_number     IN OUT  NOCOPY   NUMBER,
    x_return_status             OUT     NOCOPY   VARCHAR2,
    x_msg_count                 OUT     NOCOPY   NUMBER,
    x_msg_data                  OUT     NOCOPY   VARCHAR2
) IS
BEGIN

  HZ_GEOGRAPHY_PUB.update_geography (
    p_init_msg_list => p_init_msg_list,
    p_geography_id => p_geography_id,
    p_end_date => p_end_date,
    p_geometry => null,
    p_timezone_code => p_timezone_code,
    p_object_version_number => p_object_version_number,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );

END update_geography;

/**
 * PROCEDURE create_geography_range
 *
 * DESCRIPTION
 *     Creates Geography Range.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_range_rec          Geography range type record.
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
 *     06-20-2005    Kate Shan           o Created.
 *
 */

PROCEDURE create_geography_range(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_range_rec       IN         GEOGRAPHY_RANGE_REC_TYPE,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
) IS
  l_geography_range_rec HZ_GEOGRAPHY_PUB.GEOGRAPHY_RANGE_REC_TYPE;
BEGIN

  l_geography_range_rec.zone_id := p_geography_range_rec.zone_id;
  l_geography_range_rec.master_ref_geography_id := p_geography_range_rec.master_ref_geography_id;
  l_geography_range_rec.identifier_type := p_geography_range_rec.identifier_type;
  l_geography_range_rec.geography_from := p_geography_range_rec.geography_from;
  l_geography_range_rec.geography_to := p_geography_range_rec.geography_to;
  l_geography_range_rec.geography_type := p_geography_range_rec.geography_type;
  l_geography_range_rec.start_date := p_geography_range_rec.start_date;
  l_geography_range_rec.end_date := p_geography_range_rec.end_date;
  l_geography_range_rec.created_by_module := p_geography_range_rec.created_by_module;
  l_geography_range_rec.application_id := p_geography_range_rec.application_id;


    HZ_GEOGRAPHY_PUB.create_geography_range (
    p_init_msg_list => p_init_msg_list,
    p_geography_range_rec => l_geography_range_rec,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
    );

END create_geography_range;


/**
 * PROCEDURE update_geography_range
 *
 * DESCRIPTION
 *     Updates Geography range
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     geography_id
 *     geography_from
 *     start_date
 *     end_date
 *
 *   IN/OUT:
 *     p_object_version_number
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
 *     06-20-2005    Kate Shan           o Created.
 *
 */
PROCEDURE update_geography_range (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_id              IN        NUMBER,
    p_geography_from            IN        VARCHAR2,
    p_start_date                IN        DATE,
    p_end_date                  IN        DATE,
    p_object_version_number     IN OUT  NOCOPY   NUMBER,
    x_return_status             OUT     NOCOPY   VARCHAR2,
    x_msg_count                 OUT     NOCOPY   NUMBER,
    x_msg_data                  OUT     NOCOPY   VARCHAR2
) IS
BEGIN
    HZ_GEOGRAPHY_PUB.update_geography_range(
      p_init_msg_list => p_init_msg_list,
      p_geography_id => p_geography_id,
      p_geography_from => p_geography_from,
      p_start_date => p_start_date,
      p_end_date => p_end_date,
      p_object_version_number => p_object_version_number,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    );
END update_geography_range;


/**
 * PROCEDURE create_zone_relation
 *
 * DESCRIPTION
 *     Creates Zone Relation.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_id
 *     p_zone_relation_tbl            Zone relation table of records.
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
 *     06-20-2005    Kate Shan           o Created.
 *     10-25-2005    Idris Ali           o Bug 4684003:Modified code to pass supplied value for
 *                                          end_date and start_date to Hz_geogrpahy_pub.create_zone_relation procedure
 *                                          instead of defaulting it.
 *
 */

PROCEDURE create_zone_relation(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_id              IN         NUMBER,
    p_zone_relation_tbl         IN         ZONE_RELATION_TBL_TYPE,
    p_created_by_module           IN         VARCHAR2,
    p_application_id	        IN         NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
 ) IS
   l_zone_relation_tbl HZ_GEOGRAPHY_PUB.ZONE_RELATION_TBL_TYPE;
 BEGIN

     FOR i in 1 .. p_zone_relation_tbl.count LOOP
       l_zone_relation_tbl(i).included_geography_id := p_zone_relation_tbl(i).included_geography_id;
       l_zone_relation_tbl(i).geography_from := p_zone_relation_tbl(i).geography_from;
       l_zone_relation_tbl(i).geography_to := p_zone_relation_tbl(i).geography_to;
       l_zone_relation_tbl(i).identifier_type := p_zone_relation_tbl(i).identifier_type;
       l_zone_relation_tbl(i).geography_type := p_zone_relation_tbl(i).geography_type;

       IF p_zone_relation_tbl(i).start_date = fnd_api.g_miss_date or p_zone_relation_tbl(i).start_date is null or
          p_zone_relation_tbl(i).start_date = to_date(null)
       THEN
          l_zone_relation_tbl(i).start_date :=sysdate;
       ELSE
          l_zone_relation_tbl(i).start_date := p_zone_relation_tbl(i).start_date;
       END IF;
       IF p_zone_relation_tbl(i).end_date = fnd_api.g_miss_date or p_zone_relation_tbl(i).end_date is null
       THEN
          l_zone_relation_tbl(i).end_date := to_date('31-12-4712','DD-MM-YYYY');
       ELSE
          l_zone_relation_tbl(i).end_date := p_zone_relation_tbl(i).end_date;
       END IF;

     END LOOP;

     HZ_GEOGRAPHY_PUB.create_zone_relation(
       p_init_msg_list => p_init_msg_list,
       p_geography_id => p_geography_id,
       p_zone_relation_tbl => l_zone_relation_tbl,
       p_created_by_module => p_created_by_module,
       p_application_id => p_application_id,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data
     );
 END create_zone_relation;


/**
 * PROCEDURE create_zone
 *
 * DESCRIPTION
 *     Creates Zone
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_zone_type
 *     p_zone_name
 *     p_zone_code
 *     p_start_date
 *     p_end_date
 *     p_geo_data_provider
 *     p_zone_relation_tbl           table of records to create relationships
 *     p_timezone_code
 *     p_created_by_module
 *     p_application_id
 *     p_program_login_id
 *
 *     OUT:
 *      x_return_status
 *                                              Return status after the call. The status can
 *      					be FND_API.G_RET_STS_SUCCESS (success),
 *                                              FND_API.G_RET_STS_ERROR (error),
 *                                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *      x_msg_count                             Number of messages in message stack.
 *      x_msg_data                              Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     06-20-2005    Kate Shan           o Created.
 *     10-25-2005    Idris Ali           o Bug 4684003:Modified code to pass supplied value for
 *                                          end_date and start_date to Hz_geogrpahy_pub.create_zone procedure
 *                                          instead of defaulting it.
 *
 */

PROCEDURE create_zone(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_zone_type                 IN         VARCHAR2,
    p_zone_name                 IN         VARCHAR2,
    p_zone_code                 IN         VARCHAR2,
    p_zone_code_type            IN         VARCHAR2,
    p_start_date                IN         DATE ,
    p_end_date                  IN         DATE ,
    p_geo_data_provider         IN         VARCHAR2 ,
    p_language_code             IN         VARCHAR2,
    p_zone_relation_tbl         IN         ZONE_RELATION_TBL_TYPE,
--    p_geometry                  IN         MDSYS.SDO_GEOMETRY,
    p_timezone_code             IN         VARCHAR2,
    x_geography_id              OUT  NOCOPY NUMBER,
    p_created_by_module         IN         VARCHAR2,
    p_application_id	        IN         NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
) IS
   l_zone_relation_tbl HZ_GEOGRAPHY_PUB.ZONE_RELATION_TBL_TYPE;
BEGIN

  FOR i in 1 .. p_zone_relation_tbl.count LOOP
       l_zone_relation_tbl(i).included_geography_id := p_zone_relation_tbl(i).included_geography_id;
       l_zone_relation_tbl(i).geography_from := p_zone_relation_tbl(i).geography_from;
       l_zone_relation_tbl(i).geography_to := p_zone_relation_tbl(i).geography_to;
       l_zone_relation_tbl(i).identifier_type := p_zone_relation_tbl(i).identifier_type;
       l_zone_relation_tbl(i).geography_type := p_zone_relation_tbl(i).geography_type;

      IF p_zone_relation_tbl(i).start_date = fnd_api.g_miss_date or p_zone_relation_tbl(i).start_date is null OR  --Bug 4684003
          p_zone_relation_tbl(i).start_date = to_date(NULL) THEN
         l_zone_relation_tbl(i).start_date :=sysdate;
       ELSE
         l_zone_relation_tbl(i).start_date := p_zone_relation_tbl(i).start_date;
       END IF;
       IF p_zone_relation_tbl(i).end_date = fnd_api.g_miss_date or p_zone_relation_tbl(i).end_date is null THEN
         l_zone_relation_tbl(i).end_date := to_date('31-12-4712','DD-MM-YYYY');
       ELSE
         l_zone_relation_tbl(i).end_date := p_zone_relation_tbl(i).end_date;
       END IF;
  END LOOP;

  HZ_GEOGRAPHY_PUB.create_zone(
    p_init_msg_list => p_init_msg_list,
    p_zone_type => p_zone_type,
    p_zone_name => p_zone_name,
    p_zone_code => p_zone_code,
    p_zone_code_type => p_zone_code_type,
    p_start_date => p_start_date,
    p_end_date => p_end_date,
    p_geo_data_provider => p_geo_data_provider,
    p_language_code => p_language_code,
    p_zone_relation_tbl => l_zone_relation_tbl,
    p_geometry => null,
    p_timezone_code => p_timezone_code,
    x_geography_id => x_geography_id,
    p_created_by_module => p_created_by_module,
    p_application_id => p_application_id,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data
  );
END create_zone;


END HZ_GEOGRAPHY_PUB_UIW;

/
