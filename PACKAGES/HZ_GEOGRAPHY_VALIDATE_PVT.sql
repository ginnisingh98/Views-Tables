--------------------------------------------------------
--  DDL for Package HZ_GEOGRAPHY_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEOGRAPHY_VALIDATE_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHGEOVS.pls 115.0 2003/02/01 02:38:13 rnalluri noship $ */


--------------------------------------
-- Type declarations
--------------------------------------

TYPE ZONE_RELATION_REC_TYPE IS RECORD(
  geography_id                NUMBER,
  included_geography_id       NUMBER,
  start_date                  DATE,
  end_date                    DATE
  );
--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE validate_master_relation
 *
 * DESCRIPTION
 *     Validate the relationship record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_master_relation_rec          Master relationship record
 *     p_create_update_flag           Flag that indicates 'C' for create
 *                                    and 'U' for update
 *
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *   11-22-2002    Rekha Nalluri      o Created.
 *
 */

PROCEDURE validate_master_relation (
    p_master_relation_rec                   IN     HZ_GEOGRAPHY_PUB.master_relation_rec_type,
    p_create_update_flag                    IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
  );


 /**
 * PROCEDURE validate_structure
 *
 * DESCRIPTION
 *     Validates whether geography_type and parent_geography_type are as per the structure defined
 *     for that country
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_start_date                   start date
 *     p_end_date                     end date
 *
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *   11-22-2002    Rekha Nalluri      o Created.
 *
 */

PROCEDURE validate_structure(
    p_geography_type           IN VARCHAR2,
    p_parent_geography_type    IN VARCHAR2,
    p_country_code             IN VARCHAR2,
    x_return_status            IN OUT NOCOPY VARCHAR2
    );


 /**
 * PROCEDURE get_geography_type
 *
 * DESCRIPTION
 *     Gets the geography type based on the geography_id passed.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_geography_id                  Geography ID
 *     x_geography_type                Geography Type
 *
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *   11-22-2002    Rekha Nalluri      o Created.
 *
 */
 FUNCTION get_geography_type(
        p_geography_id          IN    NUMBER,
        x_return_status         IN OUT NOCOPY VARCHAR2
        )RETURN VARCHAR2;


/**
 * PROCEDURE validate_geo_identifier
 *
 * DESCRIPTION
 *     Validate the geography identifier record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_geo_identifier_rec           Geography Identifier record
 *     p_create_update_flag           Flag that indicates 'C' for create
 *                                    and 'U' for update
 *
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *   12-03-2002    Rekha Nalluri      o Created.
 *
 */

PROCEDURE validate_geo_identifier (
    p_geo_identifier_rec                    IN     HZ_GEOGRAPHY_PUB.geo_identifier_rec_type,
    p_create_update_flag                    IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
  );

/**
 * PROCEDURE validate_master_geography
 *
 * DESCRIPTION
 *     Validate the master geography record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_master_geography_rec         Master Geography record
 *     p_create_update_flag           Flag that indicates 'C' for create
 *                                    and 'U' for update
 *
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *   12-09-2002    Rekha Nalluri      o Created.
 *
 */

PROCEDURE validate_master_geography (
    p_master_geography_rec                  IN     HZ_GEOGRAPHY_PUB.master_geography_rec_type,
    p_create_update_flag                    IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
  );

 /**
 * PROCEDURE validate_geography_range
 *
 * DESCRIPTION
 *     Validates the geography range record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_geography_range_rec          Geography range record
 *     p_create_update_flag           Flag that indicates 'C' for create
 *                                    and 'U' for update
 *
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *   01-20-2003    Rekha Nalluri      o Created.
 *
 */

PROCEDURE validate_geography_range (
    p_geography_range_rec                  IN     HZ_GEOGRAPHY_PUB.geography_range_rec_type,
    p_create_update_flag                    IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
  );

 /**
 * PROCEDURE validate_zone_relation
 *
 * DESCRIPTION
 *     Validates the zone relation record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:i
 *     p_geography_id                Geography id
 *     p_zone_relation_tbl           Zone relation table of records
 *     p_create_update_flag           Flag that indicates 'C' for create
 *                                    and 'U' for update
 *
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *   01-24-2003    Rekha Nalluri      o Created.
 *
 */

PROCEDURE validate_zone_relation (
   p_zone_relation_rec          IN   ZONE_RELATION_REC_TYPE,
   p_create_update_flag         IN   VARCHAR2,
   x_return_status              IN OUT NOCOPY VARCHAR2
   );

END HZ_GEOGRAPHY_VALIDATE_PVT;

 

/
