--------------------------------------------------------
--  DDL for Package Body HZ_GEOGRAPHY_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEOGRAPHY_VALIDATE_PVT" AS
/*$Header: ARHGEOVB.pls 120.15 2006/01/23 07:07:00 idali noship $ */


-----------------------------------------
-- declaration of private global varibles
-----------------------------------------

--------------------------------------------------
-- declaration of private procedures and functions
--------------------------------------------------

-------------------------------
-- body of private procedures
-------------------------------



--------------------------------
-- body of public procedures
--------------------------------
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
    ) IS

    l_count     NUMBER;
    l_geography_id NUMBER;
    l_country_id  NUMBER;

    BEGIN

    -- check whether the country structure is defined
      SELECT geography_id INTO l_geography_id
        FROM hz_geographies
       WHERE country_code = p_country_code
         AND geography_type = 'COUNTRY';

       BEGIN

        SELECT 1 into l_count
          FROM hz_geo_structure_levels
         WHERE geography_id = l_geography_id
           AND rownum <2;

        IF l_count = 0 THEN
           fnd_message.set_name('AR', 'HZ_GEO_STRUCT_UNDEFINED');
            fnd_message.set_token('GEO_ID', l_geography_id);
            fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
         END IF;

    -- check whether geography_type and parent_geography_type are as per the country structure
       /*SELECT 1 into l_count
         FROM dual
        WHERE p_geography_type in (SELECT geography_type
                                   FROM HZ_GEO_STRUCTURE_LEVELS
                                   WHERE country_code = p_country_code
                                   CONNECT BY PRIOR geography_type=parent_geography_type
                                   START WITH parent_geography_type = p_parent_geography_type); */

-- changing the above validation as fix for 2917924

   SELECT 1 into l_count
     FROM hz_geo_structure_levels
    WHERE geography_id=l_geography_id
      and geography_type=p_geography_type
      and parent_geography_type=p_parent_geography_type;

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('AR', 'HZ_GEO_INVALID_COMBINATION');
            fnd_message.set_token('COUNTRY', p_country_code);
            fnd_message.set_token('PARENT_GEO', p_parent_geography_type);
            fnd_message.set_token('CHILD_GEO', p_geography_type);
            fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
           END;
 END validate_structure;

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
        ) RETURN VARCHAR2 IS

   l_geography_type    VARCHAR2(30);

   BEGIN

      SELECT geography_type
        INTO l_geography_type
        FROM HZ_GEOGRAPHIES
       WHERE geography_id = p_geography_id;

     RETURN l_geography_type;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK','geography_id');
          fnd_message.set_token('COLUMN', 'geography_id');
          fnd_message.set_token('TABLE','HZ_GEOGRAPHIES');
          fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
END get_geography_type;


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
  )IS

   l_geography_type          VARCHAR2(30);
   l_parent_geography_type   VARCHAR2(30);
   l_count                   NUMBER;
   l_start_date              DATE;
   l_country_code            VARCHAR2(2);
   l_end_date                DATE;

  BEGIN

    -- Initialize  start_date and end_date
       l_start_date :=NULL;
       l_end_date:=NULL;

      IF p_create_update_flag = 'C' THEN
       -- validate start_date and end_date
       HZ_UTILITY_V2PUB.validate_start_end_date(
           p_create_update_flag                    => p_create_update_flag,
           p_start_date_column_name                => 'start_date',
           p_start_date                            => p_master_relation_rec.start_date,
           p_old_start_date                        => l_start_date,
           p_end_date_column_name                  => 'end_date',
           p_end_date                              => p_master_relation_rec.end_date,
           p_old_end_date                          => l_end_date,
           x_return_status                         => x_return_status
           );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

       --dbms_output.put_line('In validate relatio after date validate');

      -- validate geography_id and parent_geography_id
      IF p_create_update_flag = 'C' THEN
       HZ_GEO_STRUCTURE_VALIDATE_PVT.validate_geography_id(
        p_geography_id         => p_master_relation_rec.geography_id,
        p_master_ref_flag      => 'Y',
        x_return_status        => x_return_status
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

       HZ_GEO_STRUCTURE_VALIDATE_PVT.validate_geography_id(
        p_geography_id         => p_master_relation_rec.parent_geography_id,
        p_master_ref_flag      => 'Y',
        x_return_status        => x_return_status
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

     END IF;

     --dbms_output.put_line('In validate relation after geography_id validate');

      IF p_create_update_flag = 'C' THEN
      -- get geography_type and parent_geography_type
       l_geography_type := get_geography_type(p_geography_id => p_master_relation_rec.geography_id,
                                              x_return_status  => x_return_status);
       l_parent_geography_type := get_geography_type(p_geography_id => p_master_relation_rec.parent_geography_id,
                                        x_return_status  => x_return_status);

       --dbms_output.put_line('In validate relation after get geography type');
       -- get country code for geography_id

          SELECT country_code INTO l_country_code
            FROM HZ_GEOGRAPHIES
           WHERE geography_id=p_master_relation_rec.parent_geography_id;
        IF l_country_code IS NULL THEN
          fnd_message.set_name('AR', 'HZ_GEO_NO_RECORD');
          fnd_message.set_token('TOKEN1', 'country_code');
          fnd_message.set_token('TOKEN2', 'geography_id '||p_master_relation_rec.parent_geography_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;

        END IF;

        -- validate whether geography_type is at lower level to parent_geography_type per that country structure
          -- --dbms_output.put_line('before validate_structure');
            validate_structure(
            p_geography_type        => l_geography_type,
            p_parent_geography_type => l_parent_geography_type,
            p_country_code          => l_country_code,
            x_return_status         => x_return_status
            );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            ----dbms_output.put_line('x_return_status is '||x_return_status);
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            ----dbms_output.put_line('after validate_structure');
         END IF;

         --dbms_output.put_line('In validate relatio after structure validation');

         IF p_create_update_flag = 'C' THEN

        -- check whether geography_id is unique within parent_geography_id
        SELECT count(*) INTO l_count
          FROM HZ_RELATIONSHIPS
         WHERE subject_id=p_master_relation_rec.parent_geography_id
           AND object_id = p_master_relation_rec.geography_id
           AND subject_type = l_parent_geography_type
           AND object_type = l_geography_type
           AND relationship_type='MASTER_REF'
           AND status = 'A';

       IF l_count > 0 THEN
          fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
          fnd_message.set_token('COLUMN', 'geography_id');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
     END IF;

 END validate_master_relation;

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
 *   08-25-2005    Nishant Singhai    o Modified for Bug 4549821. Added
 *                                      identifier_type check in WHERE clause to
 *                                      to verify if identifier value already exists
 *                                      in case of 'C'.
 *   10-25-2005    Nishant Singhai     Modified for Bug 4578867 (for NAME, if anything other than
 *	                                   STANDARD_NAME is used raise error)
 *
 */

PROCEDURE validate_geo_identifier (
    p_geo_identifier_rec                    IN     HZ_GEOGRAPHY_PUB.geo_identifier_rec_type,
    p_create_update_flag                    IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
  )IS

    l_count             NUMBER;

  BEGIN

    IF p_create_update_flag = 'C' THEN
       HZ_GEO_STRUCTURE_VALIDATE_PVT.validate_geography_id(
        p_geography_id         => p_geo_identifier_rec.geography_id,
        p_master_ref_flag      => 'N',
        x_return_status        => x_return_status
        );

    -- validate identifier_subtype,identifier_type and geo_data_provider lookups

      IF p_geo_identifier_rec.identifier_type='CODE' THEN

       HZ_UTILITY_V2PUB.validate_lookup(
         p_column           => 'geography_code_type',
         p_lookup_type      => 'HZ_GEO_IDENTIFIER_SUBTYPE',
         p_column_value     => p_geo_identifier_rec.identifier_subtype,
         x_return_status    => x_return_status
        );

     -- Added by Nishant on 25-Oct-2005 for Bug 4578867 (Since STANDARD_NAME lookup
     -- is being end-dated, for identifier type =NAME, there will be only 1
	 -- identifier_subtype, which is STANDARD_NAME. So, for NAME, if anything other than
	 -- STANDARD_NAME is used raise error.
     ELSIF p_geo_identifier_rec.identifier_type='NAME' THEN
        IF (p_geo_identifier_rec.identifier_subtype <> 'STANDARD_NAME') THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_LOOKUP' );
            FND_MESSAGE.SET_TOKEN( 'COLUMN', 'identifier_subtype' );
            FND_MESSAGE.SET_TOKEN( 'LOOKUP_TYPE', 'HZ_GEO_IDENTIFIER_SUBTYPE' );
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
     -- this will not be called as only NAME and CODE are valid identifier type
     -- but keeping it as 'catch all' condition to validate what is passed in
     ELSE
       HZ_UTILITY_V2PUB.validate_lookup(
         p_column   => 'identifier_subtype',
         p_lookup_type      => 'HZ_GEO_IDENTIFIER_SUBTYPE',
         p_column_value     => p_geo_identifier_rec.identifier_subtype,
         x_return_status    => x_return_status
        );
    END IF;

     HZ_UTILITY_V2PUB.validate_lookup(
     p_column   => 'identifier_type',
     p_lookup_type      => 'HZ_GEO_IDENTIFIER_TYPE',
     p_column_value     => p_geo_identifier_rec.identifier_type,
     x_return_status    => x_return_status
     );


     -- language_code must be FK to fnd_languages
     IF p_geo_identifier_rec.language_code IS NOT NULL THEN
      SELECT count(*) INTO l_count
        FROM fnd_languages
       WHERE language_code = p_geo_identifier_rec.language_code
         AND rownum <2;

         IF l_count = 0 THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK','language_code');
          fnd_message.set_token('COLUMN', 'language_code');
          fnd_message.set_token('TABLE','FND_LANGUAGES');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END IF;
       END IF;

   /* If p_create_update_flag = 'C' THEN
     -- check the uniqueness for the combination of geography_id,identifier_type,
     -- identifier_subtype,identifier_value and language_code
     SELECT count(*) INTO l_count
       FROM HZ_GEOGRAPHY_IDENTIFIERS
      WHERE geography_id=p_geo_identifier_rec.geography_id
        AND identifier_type=p_geo_identifier_rec.identifier_type
        AND identifier_subtype=p_geo_identifier_rec.identifier_subtype
        AND identifier_value=p_geo_identifier_rec.identifier_value
        AND language_code = p_geo_identifier_rec.language_code;

        IF l_count > 0 THEN
          fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
           fnd_message.set_token('COLUMN', 'geography_id,identifier_type,identifier_subtype,identifier_value,language_code');
           fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
        END IF;
     END IF; */

     HZ_UTILITY_V2PUB.validate_lookup(
     p_column   => 'geo_data_provider',
     p_lookup_type      => 'HZ_GEO_DATA_PROVIDER',
     p_column_value     => p_geo_identifier_rec.geo_data_provider,
     x_return_status    => x_return_status
     );

      IF p_create_update_flag = 'C' THEN
--  Bug 4591502 : ISSUE # 16 : validate only in create

        hz_utility_v2pub.validate_created_by_module(
          p_create_update_flag     => 'C',
          p_created_by_module      => p_geo_identifier_rec.created_by_module,
          p_old_created_by_module  => null,
          x_return_status          => x_return_status);

        IF p_geo_identifier_rec.identifier_type='NAME' THEN
         -- check if name is unique for a geography_id and identifier type, with in that language_code
         -- identifier type check added in WHERE clause by NSINGHAI on 25-Aug-2005 for Bug 4549821
          SELECT count(*) INTO l_count
            FROM HZ_GEOGRAPHY_IDENTIFIERS
           WHERE geography_id=p_geo_identifier_rec.geography_id
             AND language_code = UPPER(p_geo_identifier_rec.language_code)
             AND UPPER(identifier_value) = UPPER(p_geo_identifier_rec.identifier_value)
             AND identifier_type = p_geo_identifier_rec.identifier_type
             AND rownum <2;

          IF l_count > 0 THEN
             fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
             fnd_message.set_token('COLUMN', 'identifier_value within the identifier_type NAME and language code '||p_geo_identifier_rec.language_code);
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
          END IF;
        END IF;
      END IF;

      IF p_create_update_flag = 'U' THEN
        --check if the row exists
        SELECT count(*) INTO l_count
          FROM hz_geography_identifiers
         WHERE geography_id = p_geo_identifier_rec.geography_id
           AND identifier_type = p_geo_identifier_rec.identifier_type
           AND identifier_subtype = p_geo_identifier_rec.identifier_subtype
           AND identifier_value = p_geo_identifier_rec.identifier_value
           AND language_code = p_geo_identifier_rec.language_code
           ;

         IF  l_count = 0 THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_RECORD');
             FND_MESSAGE.SET_TOKEN('TOKEN1', 'geography_identifier');
             FND_MESSAGE.SET_TOKEN('TOKEN2', 'geography_id '||p_geo_identifier_rec.geography_id||',identifier_type '||p_geo_identifier_rec.identifier_type||
                                   ', identifier_subtype '||p_geo_identifier_rec.identifier_subtype||', identifier_value '||p_geo_identifier_rec.identifier_value||
                                   ', language_code '||p_geo_identifier_rec.language_code);
             FND_MSG_PUB.ADD;
             x_return_status := fnd_api.g_ret_sts_error;
          END IF;
       END IF;


 END validate_geo_identifier;

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
  ) IS

   l_count                 NUMBER;
   l_parent_geography_tbl  HZ_GEOGRAPHY_PUB.parent_geography_tbl_type;
   l_start_date            DATE;
   l_end_date              DATE;
   l_last  NUMBER;
   --l_geography_type     VARCHAR2(30);


   BEGIN

   l_parent_geography_tbl := p_master_geography_rec.parent_geography_id;

   -- Initialize  start_date and end_date
       l_start_date :=NULL;
       l_end_date:=NULL;


     -- check whether end_date >= start_date
       HZ_UTILITY_V2PUB.validate_start_end_date(
           p_create_update_flag                    => p_create_update_flag,
           p_start_date_column_name                => 'start_date',
           p_start_date                            => p_master_geography_rec.start_date,
           p_old_start_date                        => l_start_date,
           p_end_date_column_name                  => 'end_date',
           p_end_date                              => p_master_geography_rec.end_date,
           p_old_end_date                          => l_end_date,
           x_return_status                         => x_return_status
           );

        --dbms_output.put_line('In validate, after date validation '||x_return_status);
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;


   IF p_create_update_flag = 'C' THEN
     -- validate geography_type
   HZ_GEO_STRUCTURE_VALIDATE_PVT.validate_geography_type(
     p_geography_type       => p_master_geography_rec.geography_type,
     p_master_ref_flag      => 'Y',
     x_return_status        => x_return_status
     );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
         -- validate geography name for mandatory
     HZ_UTILITY_V2PUB.validate_mandatory (
    p_create_update_flag         =>'C',
    p_column                     => 'geography_name',
    p_column_value               => p_master_geography_rec.geography_name,
    p_restricted                 => 'N',
    x_return_status              => x_return_status
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    hz_utility_v2pub.validate_created_by_module(
      p_create_update_flag     => 'C',
      p_created_by_module      => p_master_geography_rec.created_by_module,
      p_old_created_by_module  => null,
      x_return_status          => x_return_status);

  END IF;

  -- geography_code_type is mandatory if geography_code is NOT NULL
   IF (p_master_geography_rec.geography_code IS NOT NULL AND p_master_geography_rec.geography_code_type IS NULL) THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'geography_code_type' );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;


    --dbms_output.put_line('In valiadte, after geography_code_type validation');

  -- validate timezone_code for FK to FND_TIMEZONES
   IF p_master_geography_rec.timezone_code IS NOT NULL THEN

      SELECT count(*) INTO l_count
        FROM FND_TIMEZONES_B
       WHERE timezone_code = p_master_geography_rec.timezone_code;

     IF l_count = 0 THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'timezone_code');
          fnd_message.set_token('COLUMN','timezone_code');
          fnd_message.set_token('TABLE','FND_TIMEZONES_B');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
     END IF;
   END IF;

   -- language_code must be FK to fnd_languages
   IF p_master_geography_rec.language_code IS NOT NULL THEN
          SELECT count(*) INTO l_count
            FROM fnd_languages
           WHERE language_code = UPPER(p_master_geography_rec.language_code)
             AND rownum <2;
     IF l_count = 0 THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'language_code');
          fnd_message.set_token('COLUMN','language_code');
          fnd_message.set_token('TABLE','FND_LANGUAGES');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
     END IF;
   END IF;

    --validate for duplicate country
   IF p_master_geography_rec.geography_type = 'COUNTRY' THEN
    SELECT count(*) INTO l_count
      FROM hz_geographies
     WHERE geography_code=p_master_geography_rec.geography_code
       AND geography_type='COUNTRY';

    IF l_count > 0 THEN
         fnd_message.set_name('AR', 'HZ_GEO_DUPLICATE_GEOG_CODE');
          fnd_message.set_token('COUNTRY_CODE', p_master_geography_rec.geography_code);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    END IF;


    -- validate parent_geography_id
   l_last := l_parent_geography_tbl.last;
   IF l_last > 0 THEN
   FOR i in 1 .. l_last loop
   IF l_parent_geography_tbl.exists(i)= TRUE THEN
       hz_geo_structure_validate_pvt.validate_geography_id (
       p_geography_id         => l_parent_geography_tbl(i),
       p_master_ref_flag     => 'Y',
       x_return_status        => x_return_status);
       END IF;
    END LOOP;
    END IF;
   -- validate geography_code for FK to FND_TERRITORIES if geography_type is 'COUNTRY'
   IF  p_master_geography_rec.geography_type = 'COUNTRY' THEN
    SELECT count(*) INTO l_count
      FROM FND_TERRITORIES
     WHERE territory_code = UPPER(p_master_geography_rec.geography_code);
       IF l_count = 0 THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK','territory_code');
          fnd_message.set_token('COLUMN', 'geography_code');
          fnd_message.set_token('TABLE','FND_TERRITORIES');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
   END IF;

   -- if geography_type <> 'COUNTRY' then atleast one parent should be passed.
     IF p_master_geography_rec.geography_type <> 'COUNTRY' THEN
     --dbms_output.put_line('parent count is '||to_char(l_parent_geography_tbl.count));

       IF l_parent_geography_tbl.count = 0 THEN
          fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
          fnd_message.set_token('COLUMN', 'parent_geography_id');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
     END IF;

END validate_master_geography;

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
    p_create_update_flag                   IN     VARCHAR2,
    x_return_status                        IN OUT NOCOPY VARCHAR2
  ) IS

  l_count                 NUMBER;


 BEGIN

 -- validate for mandatory columns
    HZ_UTILITY_V2PUB.validate_mandatory (
    p_create_update_flag         =>p_create_update_flag,
    p_column                     => 'zone_id',
    p_column_value               => p_geography_range_rec.zone_id,
    p_restricted                 => 'N',
    x_return_status              => x_return_status
    );


    HZ_UTILITY_V2PUB.validate_mandatory (
    p_create_update_flag         =>p_create_update_flag,
    p_column                     => 'geography_from',
    p_column_value               => p_geography_range_rec.geography_from,
    p_restricted                 => 'N',
    x_return_status              => x_return_status
    );

    IF p_create_update_flag = 'C' THEN
    HZ_UTILITY_V2PUB.validate_mandatory (
    p_create_update_flag         =>p_create_update_flag,
    p_column                     => 'master_ref_geography_id',
    p_column_value               => p_geography_range_rec.master_ref_geography_id,
    p_restricted                 => 'N',
    x_return_status              => x_return_status
    );

    HZ_UTILITY_V2PUB.validate_mandatory (
    p_create_update_flag         =>p_create_update_flag,
    p_column                     => 'geography_to',
    p_column_value               => p_geography_range_rec.geography_to,
    p_restricted                 => 'N',
    x_return_status              => x_return_status
    );

    HZ_UTILITY_V2PUB.validate_mandatory (
    p_create_update_flag         =>p_create_update_flag,
    p_column                     => 'identifier_type',
    p_column_value               => p_geography_range_rec.identifier_type,
    p_restricted                 => 'N',
    x_return_status              => x_return_status
    );

    hz_utility_v2pub.validate_created_by_module(
      p_create_update_flag     => 'C',
      p_created_by_module      => p_geography_range_rec.created_by_module,
      p_old_created_by_module  => null,
      x_return_status          => x_return_status);

   END IF;

   IF p_create_update_flag = 'U' THEN

     HZ_UTILITY_V2PUB.validate_mandatory (
    p_create_update_flag         =>'U',
    p_column                     => 'start_date',
    p_column_value               => p_geography_range_rec.start_date,
    p_restricted                 => 'N',
    x_return_status              => x_return_status
    );

    HZ_UTILITY_V2PUB.validate_mandatory (
    p_create_update_flag         =>'U',
    p_column                     => 'end_date',
    p_column_value               => p_geography_range_rec.end_date,
    p_restricted                 => 'N',
    x_return_status              => x_return_status
    );

    END IF;


   IF p_create_update_flag = 'C' THEN
       -- validate for start_date and end_date
     HZ_UTILITY_V2PUB.validate_start_end_date(
           p_create_update_flag                    => p_create_update_flag,
           p_start_date_column_name                => 'start_date',
           p_start_date                            => p_geography_range_rec.start_date,
           p_old_start_date                        => NULL,
           p_end_date_column_name                  => 'end_date',
           p_end_date                              => p_geography_range_rec.end_date,
           p_old_end_date                          => NULL,
           x_return_status                         => x_return_status
           );

    END IF;

    -- Added the below begin and exception to fix the bug # 4670425
    -- If geography_from and geography_to are both numbers then it will execute the first part.
    -- If geography_from and geography_to are alpha numeric, it will execute the exception part.
    BEGIN
       -- geography_to must be greater than or equal to geography_from
       IF to_number(p_geography_range_rec.geography_from) > to_number(p_geography_range_rec.geography_to) THEN
          fnd_message.set_name('AR', 'HZ_GEO_INVALID_RANGE');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
    EXCEPTION WHEN VALUE_ERROR THEN
       -- geography_to must be greater than or equal to geography_from
       IF p_geography_range_rec.geography_from > p_geography_range_rec.geography_to THEN
          fnd_message.set_name('AR', 'HZ_GEO_INVALID_RANGE');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END IF;
    END;

    -- validate zone_id
    BEGIN
      SELECT 1 INTO l_count
        FROM hz_geographies
       WHERE geography_id = p_geography_range_rec.zone_id
         AND geography_use <> 'MASTER_REF';


       EXCEPTION WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK','geography_id');
          fnd_message.set_token('COLUMN', 'zone_id');
          fnd_message.set_token('TABLE','HZ_GEOGRAPHIES');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END;

    --validate master_ref_geography_id
    --master_ref_geography_id is mandatory only in create
     IF p_create_update_flag = 'C' THEN
     BEGIN

       SELECT 1 INTO l_count
         FROM hz_geographies
        WHERE geography_id = p_geography_range_rec.master_ref_geography_id
          AND geography_use = 'MASTER_REF';


       EXCEPTION WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK','geography_id');
          fnd_message.set_token('COLUMN', 'master_ref_geography_id');
          fnd_message.set_token('TABLE','HZ_GEOGRAPHIES');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
       END;
     END IF;

 END validate_geography_range;


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
   ) IS

   l_count                   NUMBER;

   BEGIN


       -- validate start_date and end_date
       HZ_UTILITY_V2PUB.validate_start_end_date(
           p_create_update_flag                    => p_create_update_flag,
           p_start_date_column_name                => 'start_date',
           p_start_date                            => p_zone_relation_rec.start_date,
           p_old_start_date                        => NULL,
           p_end_date_column_name                  => 'end_date',
           p_end_date                              => p_zone_relation_rec.end_date,
           p_old_end_date                          => NULL,
           x_return_status                         => x_return_status
           );


         -- validate geography_id
        SELECT count(*) INTO l_count
          FROM hz_geographies
         WHERE geography_id = p_zone_relation_rec.geography_id;

         IF l_count = 0 THEN
           fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'geography_id');
          fnd_message.set_token('COLUMN','geography_id');
          fnd_message.set_token('TABLE','HZ_GEOGRAPHIES');
          fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
         END IF;

         --validate included_geography_id
           SELECT count(*) INTO l_count
          FROM hz_geographies
         WHERE geography_id = p_zone_relation_rec.included_geography_id;

         IF l_count = 0 THEN
           fnd_message.set_name('AR', 'HZ_GEO_INVALID_VALUE');
           fnd_message.set_token('VALUE',p_zone_relation_rec.included_geography_id);
           fnd_message.set_token('COLUMN', 'included_geography_id');
           fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
         END IF;
END validate_zone_relation;


END HZ_GEOGRAPHY_VALIDATE_PVT;

/
