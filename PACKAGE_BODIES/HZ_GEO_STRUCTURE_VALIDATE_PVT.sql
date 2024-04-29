--------------------------------------------------------
--  DDL for Package Body HZ_GEO_STRUCTURE_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_STRUCTURE_VALIDATE_PVT" AS
/*$Header: ARHGSTVB.pls 120.10 2005/10/18 21:03:02 baianand noship $ */


--------------------------------------
-- declaration of private global varibles
--------------------------------------

--------------------------------------------------
-- declaration of private procedures and functions
---------------------------------------------------

-- validate uniqueness of geography type within a parent_geography type in relationship type
PROCEDURE validate_geo_type_unique (
  p_geography_type        IN VARCHAR2,
  p_parent_geography_type IN VARCHAR2,
  x_return_status         IN OUT NOCOPY VARCHAR2
  );

-- validate relationship_type_id FK
PROCEDURE validate_relationship_type_id (
 p_relationship_type_id     IN NUMBER,
 x_return_status            IN OUT NOCOPY VARCHAR2
 );


------------------------------------------
-- body of public procedures and functions
------------------------------------------

/**
 * PROCEDURE validate_geography_type
 *
 * DESCRIPTION
 *     Validate Geography Type based on the Unique flag.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_geography_type               Geography Type you want to validate.
 *     p_master_ref_flag              Geography Use flag.
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
       p_geography_type       IN VARCHAR2,
       p_master_ref_flag      IN VARCHAR2,
       x_return_status        IN OUT NOCOPY VARCHAR2
 ) IS

       l_count           NUMBER;

   BEGIN
          SELECT count(*)
          INTO   l_count
          FROM   hz_geography_types_b
          WHERE  GEOGRAPHY_TYPE = UPPER(p_geography_type)
            AND  GEOGRAPHY_USE = decode(p_master_ref_flag,'Y','MASTER_REF',GEOGRAPHY_USE);

          IF l_count = 0 THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'geography_type');
          fnd_message.set_token('COLUMN', 'geography_type');
          fnd_message.set_token('TABLE', 'hz_geography_types_b');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
         END IF;

  END validate_geography_type;

  /**
 * PROCEDURE validate_geography_id
 *
 * DESCRIPTION
 *     Validate Geography id.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_geography_id               Geography id you want to validate.
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


 PROCEDURE validate_geography_id (
       p_geography_id         IN NUMBER,
       p_master_ref_flag      IN VARCHAR2,
       x_return_status        IN OUT NOCOPY VARCHAR2
 ) IS

       l_count           NUMBER;

   BEGIN
          SELECT count(*)
          INTO   l_count
          FROM   HZ_GEOGRAPHIES
          WHERE  GEOGRAPHY_ID = p_geography_id
            AND  GEOGRAPHY_USE = decode(p_master_ref_flag,'Y','MASTER_REF',GEOGRAPHY_USE);

         IF l_count = 0 THEN

          fnd_message.set_name('AR', 'HZ_GEO_NO_RECORD');
          fnd_message.set_token('TOKEN1', 'geography');
          fnd_message.set_token('TOKEN2', 'geography_id '||p_geography_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
              NULL;
  END validate_geography_id;

  --------------------------------
  ---- body of public procedures
  --------------------------------

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


  PROCEDURE validate_geo_rel_type(
     p_create_update_flag           IN  VARCHAR2,
     p_geo_rel_type_rec    IN  HZ_GEOGRAPHY_STRUCTURE_PUB.geo_rel_type_REC_TYPE,
     x_return_status                IN OUT NOCOPY VARCHAR2
   ) IS

   BEGIN

     IF p_create_update_flag='C' THEN
         -- validate mandatory columns
        hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'C',
          p_column                 => 'geography_type',
          p_column_value           => p_geo_rel_type_rec.geography_type,
          x_return_status          => x_return_status
          );


        hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'C',
          p_column                 => 'parent_geography_type',
          p_column_value           => p_geo_rel_type_rec.parent_geography_type,
          x_return_status          => x_return_status
          );

        hz_utility_v2pub.validate_created_by_module(
          p_create_update_flag     => 'C',
          p_created_by_module      => p_geo_rel_type_rec.created_by_module,
          p_old_created_by_module  => null,
          x_return_status          => x_return_status);
      END IF;

        -- check if geography_type and parent_geography_type are same . If yes , raise error
        -- because a geography_type can not be parent of the same geography_type.
         IF p_geo_rel_type_rec.geography_type = p_geo_rel_type_rec.parent_geography_type THEN

          fnd_message.set_name('AR', 'HZ_GEO_DUPL_GEO_TYPE');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;

         END IF;
      --dbms_output.put_line('In validate after mandatory validation '||x_return_status);

      IF p_create_update_flag='C' THEN
         -- validate parent geography type
         validate_geography_type (
          p_geography_type       => p_geo_rel_type_rec.parent_geography_type,
          p_master_ref_flag      => 'N',
          x_return_status        => x_return_status
          );

          -- validate geography type
         validate_geography_type (
          p_geography_type       => p_geo_rel_type_rec.geography_type,
          p_master_ref_flag      => 'N',
          x_return_status        => x_return_status
          );
      END IF;

      --dbms_output.put_line('In validate after geography types validation '||x_return_status);

      IF p_create_update_flag='C' THEN
          -- validate geography type uniqueness within parent geography type
          validate_geo_type_unique(
           p_geography_type          => p_geo_rel_type_rec.geography_type,
           p_parent_geography_type   => p_geo_rel_type_rec.parent_geography_type,
           x_return_status           => x_return_status
           );
      END IF;
      --dbms_output.put_line('In validate after geo unique validation '||x_return_status);

      /*IF p_create_update_flag ='C' THEN
        -- validate whether geography_type is below parent_geography_type
        HZ_GEOGRAPHY_VALIDATE_PVT.validate_structure(
            p_geography_type        => p_geo_rel_type_rec.geography_type,
            p_parent_geography_type => p_geo_rel_type_rec.parent_geography_type,
            p_country_code          => p_geo_rel_type_rec.country_code,
            x_return_status         => x_return_status
            );
      END IF; */



END validate_geo_rel_type;

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

  PROCEDURE validate_geo_structure(
  p_create_update_flag        IN VARCHAR2,
  p_geo_structure_rec         IN HZ_GEOGRAPHY_STRUCTURE_PUB.geo_structure_rec_type,
  x_return_status             IN OUT NOCOPY VARCHAR2
  ) IS

    l_geography_type          VARCHAR2(30);
    l_addr_val_level          VARCHAR2(30);
    l_count                   NUMBER;
    l_geo_count               NUMBER;
    l_pgeo_count              NUMBER;

  BEGIN

  -- validate mandatory columns
  IF p_create_update_flag = 'C' THEN
    hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'C',
          p_column                 => 'geography_id',
          p_column_value           => p_geo_structure_rec.geography_id,
          x_return_status          => x_return_status
          );

    hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'C',
          p_column                 => 'geography_type',
          p_column_value           => p_geo_structure_rec.geography_type,
          x_return_status          => x_return_status
          );

    hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'C',
          p_column                 => 'parent_geography_type',
          p_column_value           => p_geo_structure_rec.parent_geography_type,
          x_return_status          => x_return_status
          );

   /* commented per bug : 2911108
   hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'C',
          p_column                 => 'geography_element_column',
          p_column_value           => p_geo_structure_rec.geography_element_column,
          x_return_status          => x_return_status
          );*/

    hz_utility_v2pub.validate_created_by_module(
      p_create_update_flag     => 'C',
      p_created_by_module      => p_geo_structure_rec.created_by_module,
      p_old_created_by_module  => null,
      x_return_status          => x_return_status);

  END IF;


  -- validate geography_id
  IF p_create_update_flag = 'C' THEN

    validate_geography_id(
       p_geography_id    => p_geo_structure_rec.geography_id,
       p_master_ref_flag => 'Y',
       x_return_status   => x_return_status
       );

        -- validate whether geography_type of the above geography_id is 'COUNTRY'
        SELECT geography_type
          INTO l_geography_type
          FROM HZ_GEOGRAPHIES
         WHERE geography_id = p_geo_structure_rec.geography_id;

         IF l_geography_type <> 'COUNTRY' THEN
          FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_INVALID_TYPE' );
           FND_MESSAGE.SET_TOKEN( 'GEO_ID', p_geo_structure_rec.geography_id);
           FND_MSG_PUB.ADD;
          x_return_status := fnd_api.g_ret_sts_error;
         END IF;
  END IF;

  IF p_create_update_flag = 'C' THEN

      validate_geography_type(
        p_geography_type  => p_geo_structure_rec.geography_type,
        p_master_ref_flag => 'Y',
        x_return_status   => x_return_status
         );
      validate_geography_type(
         p_geography_type  => p_geo_structure_rec.parent_geography_type,
         p_master_ref_flag => 'Y',
         x_return_status   => x_return_status
         );
  END IF;

  -- Below if conditions is added for bug # 4656717
  -- Should check for duplicate geography type being entered in the same structure
  -- We should check the uniqueness of  geography_id geography_type and geography_id and parent_geography_type.
  IF p_create_update_flag = 'C' THEN
    BEGIN

      SELECT count(*) INTO l_geo_count
      FROM   hz_geo_structure_levels
      WHERE  geography_id = p_geo_structure_rec.geography_id
      AND    geography_type = p_geo_structure_rec.geography_type;

      IF l_geo_count > 0 THEN
        fnd_message.set_name('AR', 'HZ_GEO_TYPE_EXISTS_IN_STRUCT');
        fnd_message.set_token('P_GEO_TYPE', p_geo_structure_rec.geography_type);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      SELECT count(*) INTO l_pgeo_count
      FROM   hz_geo_structure_levels
      WHERE  geography_id = p_geo_structure_rec.geography_id
      AND    parent_geography_type = p_geo_structure_rec.parent_geography_type;

      IF l_pgeo_count > 0 THEN
        fnd_message.set_name('AR', 'HZ_GEO_PTYPE_EXISTS_IN_STRUCT');
        fnd_message.set_token('P_PGEO_TYPE', p_geo_structure_rec.parent_geography_type);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END;
  END IF;

  IF p_create_update_flag = 'C' THEN
     -- Added the below if condition and error message for bug # 4596440
     -- Address validation level should not be populated all the geography types.
     -- It should be populated only for parent_geography_type = 'COUNTRY'.
     IF p_geo_structure_rec.addr_val_level is NOT NULL then
        IF p_geo_structure_rec.parent_geography_type = 'COUNTRY' then
           BEGIN
              SELECT lookup_code
              INTO   l_addr_val_level
              FROM   ar_lookups
              WHERE  lookup_type = 'HZ_ADDRESS_VALIDATION_LEVEL'
              AND    lookup_code = p_geo_structure_rec.addr_val_level;
           EXCEPTION WHEN NO_DATA_FOUND THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_VAL_LEVEL');
              --  The Address Validation Level is invalid. Please pass a valid Address Validation Level
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END;
        ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_VAL_LEVEL_INVALID_GEO');
           --  Address validation level can be set only for parent geography type, 'COUNTRY'
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;
  END IF;

        -- validate geography_element_column to be one of geography_element1..10 columns of hz_geographies
-- commented as per the bug fix: 2911108
   /*   IF UPPER(p_geo_structure_rec.geography_element_column) NOT IN (
      'GEOGRAPHY_ELEMENT2','GEOGRAPHY_ELEMENT3','GEOGRAPHY_ELEMENT4','GEOGRAPHY_ELEMENT5',
      'GEOGRAPHY_ELEMENT6','GEOGRAPHY_ELEMENT7','GEOGRAPHY_ELEMENT8','GEOGRAPHY_ELEMENT9','GEOGRAPHY_ELEMENT10')
      THEN
           FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_ELEMENT_COL_INVALID');
           FND_MESSAGE.SET_TOKEN( 'GEO_ID', p_geo_structure_rec.geography_id);
           FND_MSG_PUB.ADD;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;*/


  IF p_create_update_flag = 'U' THEN

  -- validate mandatory for relationship_type_id
  hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'U',
          p_column                 => 'geography_id',
          p_column_value           => p_geo_structure_rec.geography_id,
          x_return_status          => x_return_status
          );

  hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'U',
          p_column                 => 'geography_type',
          p_column_value           => p_geo_structure_rec.geography_type,
          x_return_status          => x_return_status
          );
   hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'U',
          p_column                 => 'parent_geography_type',
          p_column_value           => p_geo_structure_rec.parent_geography_type,
          x_return_status          => x_return_status
          );


     END IF;


END VALIDATE_GEO_STRUCTURE;

--------------------------------------------
--- body of private procedures and functions
--------------------------------------------

--- validate geography type uniqueness within parent geography type

PROCEDURE validate_geo_type_unique (
  p_geography_type       IN VARCHAR2,
  p_parent_geography_type IN VARCHAR2,
  x_return_status         IN OUT NOCOPY VARCHAR2
 ) IS

   l_count       NUMBER;

 BEGIN
   SELECT count(*) INTO l_count
     FROM hz_relationship_types
    WHERE SUBJECT_TYPE = p_parent_geography_type
      AND OBJECT_TYPE = p_geography_type
      AND FORWARD_REL_CODE = 'PARENT_OF'
      AND BACKWARD_REL_CODE = 'CHILD_OF';

      IF l_count > 0 THEN

        fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
          fnd_message.set_token('COLUMN', 'geography_type');
          fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;

      END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
 END validate_geo_type_unique;


 --- validate Relationship Type ID FK

 PROCEDURE validate_relationship_type_id (
 p_relationship_type_id     IN NUMBER,
 x_return_status            IN OUT NOCOPY VARCHAR2
 ) IS

       l_count           NUMBER;

   BEGIN
          SELECT 1
          INTO   l_count
          FROM   HZ_RELATIONSHIP_TYPES
          WHERE  RELATIONSHIP_TYPE_ID = p_relationship_type_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('COLUMN', 'relationship_type_id');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
  END validate_relationship_type_id;


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
    p_zone_type_rec                         IN  HZ_GEOGRAPHY_STRUCTURE_PUB.zone_type_rec_type,
    p_create_update_flag                    IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
  ) IS

   l_count         NUMBER;

  BEGIN

     -- validate for mandatory columns

      IF p_create_update_flag = 'C' THEN
      hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'C',
          p_column                 => 'geography_type',
          p_column_value           => p_zone_type_rec.geography_type,
          x_return_status          => x_return_status
          );

      hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'C',
          p_column                 => 'geography_use',
          p_column_value           => p_zone_type_rec.geography_use,
          x_return_status          => x_return_status
          );

      hz_utility_v2pub.validate_created_by_module(
        p_create_update_flag     => 'C',
        p_created_by_module      => p_zone_type_rec.created_by_module,
        p_old_created_by_module  => null,
        x_return_status          => x_return_status);
      END IF;


        HZ_UTILITY_V2PUB.validate_lookup(
       p_column         => 'postal_code_range_flag',
       p_lookup_type    => 'HZ_GEO_POSTAL_CODE_RANGE_FLAG',
       p_column_value   => p_zone_type_rec.postal_code_range_flag,
       x_return_status  => x_return_status
        );

      IF p_create_update_flag = 'C' and
         p_zone_type_rec.limited_by_geography_id is not null
        and p_zone_type_rec.limited_by_geography_id <> fnd_api.g_miss_num THEN
      -- check for the mandatory columnm included_geography_type
         IF p_zone_type_rec.included_geography_type.count = 0 THEN
           FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
           FND_MESSAGE.SET_TOKEN( 'COLUMN', 'included_geography_type' );
           FND_MSG_PUB.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;


       IF p_create_update_flag = 'C' THEN
         HZ_UTILITY_V2PUB.validate_lookup(
       p_column         => 'geography_use',
       p_lookup_type    => 'HZ_RELATIONSHIP_TYPE',
       p_column_value   => p_zone_type_rec.geography_use,
       x_return_status  => x_return_status
        );

       -- check for the uniqueness of geography_type

       SELECT count(*) INTO l_count
         FROM hz_geography_types_b
        WHERE geography_type=p_zone_type_rec.geography_type;

       IF l_count > 0 THEN
        fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
           fnd_message.set_token('COLUMN', 'geography_type');
           fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
       END IF;
       END IF;

       IF (p_zone_type_rec.limited_by_geography_id IS NOT NULL AND p_zone_type_rec.limited_by_geography_id <> fnd_api.g_miss_num) THEN
        SELECT count(*) INTO l_count
          FROM hz_geographies
         WHERE geography_id = p_zone_type_rec.limited_by_geography_id;

          IF l_count = 0 THEN
           fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
           fnd_message.set_token('FK', 'limited_by_geography_id');
           fnd_message.set_token('COLUMN','limited_by_geography_id');
           fnd_message.set_token('TABLE','hz_geographies');
           fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
         END IF;
       END IF;


       IF  p_zone_type_rec.included_geography_type.count > 0 THEN
         FOR i in 1 .. p_zone_type_rec.included_geography_type.count LOOP
           validate_geography_type (
            p_geography_type         =>   p_zone_type_rec.included_geography_type(i),
            p_master_ref_flag        =>   'Y',
            x_return_status          =>   x_return_status
             );
           END LOOP;
        END IF;

 END validate_zone_type;

END HZ_GEO_STRUCTURE_VALIDATE_PVT;

/
