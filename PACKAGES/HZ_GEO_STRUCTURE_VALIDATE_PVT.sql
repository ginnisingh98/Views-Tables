--------------------------------------------------------
--  DDL for Package HZ_GEO_STRUCTURE_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_STRUCTURE_VALIDATE_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHGSTVS.pls 115.0 2003/02/01 02:36:24 rnalluri noship $ */

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE validate_geography_type
 *
 * DESCRIPTION
 *     Validate Geography type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_geography_type               Geography Type to validate
 *     p_master_ref_flag              Geography Use flag
 *
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *   11-05-2002    Rekha Nalluri      o Created.
 *
 */

PROCEDURE validate_geography_type (
    p_geography_type                        IN     VARCHAR2,
    p_master_ref_flag                       IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
  );

-- validate geography_id

PROCEDURE validate_geography_id (
  p_geography_id              IN NUMBER,
  p_master_ref_flag           IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2
  );


-- PROCEDURE validate_geo_rel_type
  --
  -- DESCRIPTION
  --     Validates geography relationship type record. Checks for
  --
  --         uniqueness
  --         lookups
  --         mandatory columns
  --
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag        Create update flag. 'C' = create. 'U' = update.
  --     p_geo_rel_type_rec geography relationship type record.
  --
  --   IN/OUT:
  --     x_return_status         Return status after the call. The status can
  --                             be FND_API.G_RET_STS_SUCCESS (success),
  --                             FND_API.G_RET_STS_ERROR (error),
  --                             FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   11-11-2002    Rekha Nalluri       o Created.
  --
  --

PROCEDURE validate_geo_rel_type (
  p_create_update_flag        IN VARCHAR2,
  p_geo_rel_type_rec IN HZ_GEOGRAPHY_STRUCTURE_PUB.geo_rel_type_rec_type,
  x_return_status             IN OUT NOCOPY VARCHAR2
  );


-- PROCEDURE validate_geo_structure
  --
  -- DESCRIPTION
  --     Validates geography structure record. Checks for
  --
  --         uniqueness
  --         lookups
  --         mandatory columns
  --
  --
  -- EXTERNAL   PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag        Create update flag. 'C' = create. 'U' = update.
  --     p_geo_structure_rec         geography structure type record.
  --
  --   IN/OUT:
  --     x_return_status         Return status after the call. The status can
  --                             be FND_API.G_RET_STS_SUCCESS (success),
  --                             FND_API.G_RET_STS_ERROR (error),
  --                             FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   11-15-2002    Rekha Nalluri       o Created.
  --
  --

  PROCEDURE validate_geo_structure (
  p_create_update_flag        IN VARCHAR2,
  p_geo_structure_rec         IN HZ_GEOGRAPHY_STRUCTURE_PUB.geo_structure_rec_type,
  x_return_status             IN OUT NOCOPY VARCHAR2
  );


/**
 * PROCEDURE validate_zone_type
 *
 * DESCRIPTION
 *     Validate Zone type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_geography_type               Geography Type to validate
 *     p_geography_use                Geography Usage
 *     p_limited_by_geography_id
 *     p_incl_geo_type                Included geography type
 *
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *
 *
 * MODIFICATION HISTORY
 *
 *   01-09-2003    Rekha Nalluri      o Created.
 *
 */

PROCEDURE validate_zone_type (
    p_zone_type_rec                         IN HZ_GEOGRAPHY_STRUCTURE_PUB.ZONE_TYPE_REC_TYPE,
    p_create_update_flag                    IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
  );

END HZ_GEO_STRUCTURE_VALIDATE_PVT;

 

/
