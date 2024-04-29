--------------------------------------------------------
--  DDL for Package HZ_GEOGRAPHY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEOGRAPHY_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHGEOSS.pls 120.3 2006/02/17 09:09:20 idali noship $ */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE master_relation_rec_type IS RECORD(
     geography_id                          NUMBER,
     parent_geography_id                   NUMBER,
     start_date                            DATE DEFAULT SYSDATE,
     end_date                              DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY'),
     created_by_module                     VARCHAR2(150),
     application_id                        NUMBER
    );

TYPE geo_identifier_rec_type IS RECORD(
  geography_id		    NUMBER,
  identifier_subtype	VARCHAR2(30),
  identifier_value      VARCHAR2(360),
  identifier_type	    VARCHAR2(30),
  geo_data_provider     VARCHAR2(30) DEFAULT 'USER_ENTERED',
  primary_flag		    VARCHAR2(1) DEFAULT 'N',
  language_code         VARCHAR2(4) DEFAULT userenv('LANG'),
  created_by_module     VARCHAR2(150),
  application_id	    NUMBER,
  new_identifier_value  VARCHAR2(360),
  new_identifier_subtype VARCHAR2(30)
    );

TYPE parent_geography_tbl_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;


TYPE master_geography_rec_type IS RECORD(
   geography_type        VARCHAR2(30),
   geography_name        VARCHAR2(360),
   geography_code        VARCHAR2(30),
   geography_code_type   VARCHAR2(30),
   start_date            DATE DEFAULT SYSDATE,
   end_date              DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY'),
   geo_data_provider     VARCHAR2(30) DEFAULT 'USER_ENTERED',
   language_code         VARCHAR2(4) DEFAULT userenv('LANG'),
   parent_geography_id   PARENT_GEOGRAPHY_TBL_TYPE,
   geometry              MDSYS.SDO_GEOMETRY,
   timezone_code         VARCHAR2(50),
   created_by_module     VARCHAR2(150),
   application_id	 NUMBER
      );

TYPE geography_range_rec_type IS RECORD(
    zone_id                  NUMBER,
    master_ref_geography_id  NUMBER,
    identifier_type          VARCHAR2(30),
    geography_from           VARCHAR2(360),
    geography_to             VARCHAR2(360),
    geography_type           VARCHAR2(30),
    start_date               DATE DEFAULT SYSDATE,
    end_date                 DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY'),
    created_by_module     VARCHAR2(150),
    application_id	NUMBER
         );

TYPE zone_relation_rec_type IS RECORD (
     included_geography_id      NUMBER,
     geography_from             VARCHAR2(360),
     geography_to               VARCHAR2(360),
     identifier_type            VARCHAR2(30),
     geography_type             VARCHAR2(30),
     start_date                 DATE DEFAULT SYSDATE,
     end_date                   DATE DEFAULT to_date('31-12-4712','DD-MM-YYYY')
     );

TYPE zone_relation_tbl_type IS TABLE OF zone_relation_rec_type
     INDEX BY BINARY_INTEGER;


-------------------------------------------------
-- declaration of public procedures and functions
-------------------------------------------------

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
 *     11-21-2002    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_master_relation (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_master_relation_rec       IN         MASTER_RELATION_REC_TYPE,
    x_relationship_id           OUT   NOCOPY     NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
);


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
 *     11-22-2002    Rekha Nalluri        o Created.
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
);

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
 *     12-03-2002    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_geo_identifier(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geo_identifier_rec        IN         GEO_IDENTIFIER_REC_TYPE,
    x_return_status             OUT  NOCOPY      VARCHAR2,
    x_msg_count                 OUT  NOCOPY      NUMBER,
    x_msg_data                  OUT  NOCOPY      VARCHAR2
);

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
 *
 *     x_cp_request_id                Concurrent Program Request Id, whenever CP
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
 *     12-03-2002    Rekha Nalluri    o Created.
 *     21-Oct-2005   Nishant          Added  x_cp_request_id OUT parameter
 *                                    for Bug 457886
 *
 */
PROCEDURE update_geo_identifier (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geo_identifier_rec        IN         GEO_IDENTIFIER_REC_TYPE,
    p_object_version_number     IN OUT  NOCOPY   NUMBER,
    x_cp_request_id             OUT     NOCOPY   NUMBER,
    x_return_status             OUT     NOCOPY   VARCHAR2,
    x_msg_count                 OUT     NOCOPY   NUMBER,
    x_msg_data                  OUT     NOCOPY   VARCHAR2
);

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
 *     01-02-2003    Rekha Nalluri        o Created.
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
      );


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
 *     12-03-2002    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_master_geography(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_master_geography_rec      IN         MASTER_GEOGRAPHY_REC_TYPE,
    x_geography_id              OUT   NOCOPY     NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
);

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
 *     12-12-2002    Rekha Nalluri        o Created.
 *
 */
PROCEDURE update_geography (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_id              IN        NUMBER,
    p_end_date                  IN        DATE,
    p_geometry                  IN        MDSYS.SDO_GEOMETRY,
    p_timezone_code             IN        VARCHAR2,
    p_object_version_number     IN OUT  NOCOPY   NUMBER,
    x_return_status             OUT     NOCOPY   VARCHAR2,
    x_msg_count                 OUT     NOCOPY   NUMBER,
    x_msg_data                  OUT     NOCOPY   VARCHAR2
);

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
 *     01-20-2003    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_geography_range(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_range_rec       IN         GEOGRAPHY_RANGE_REC_TYPE,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
      );


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
 *     01-23-2003    Rekha Nalluri        o Created.
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
);


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
 *     01-23-2003    Rekha Nalluri        o Created.
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
      );


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
 *     p_geometry
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
 *     01-24-2003    Rekha Nalluri        o Created.
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
    p_geometry                  IN         MDSYS.SDO_GEOMETRY,
    p_timezone_code             IN         VARCHAR2,
    x_geography_id              OUT  NOCOPY NUMBER,
    p_created_by_module         IN         VARCHAR2,
    p_application_id	        IN         NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
      );


END HZ_GEOGRAPHY_PUB;

 

/
