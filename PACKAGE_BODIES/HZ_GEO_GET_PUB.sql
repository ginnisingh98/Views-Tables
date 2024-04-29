--------------------------------------------------------
--  DDL for Package Body HZ_GEO_GET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_GET_PUB" AS
/* $Header: ARHGEGEB.pls 120.12.12010000.2 2009/02/10 14:11:13 rgokavar ship $ */

  PROCEDURE get_zone
    (p_location_table_name IN         VARCHAR2,
     p_location_id         IN         VARCHAR2,
     p_zone_type           IN         VARCHAR2,
     p_date                IN         DATE,
     p_init_msg_list       IN         VARCHAR2 := FND_API.G_FALSE,
     x_zone_tbl            OUT NOCOPY zone_tbl_type,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2) IS

    l_ref_geo_type           hz_geography_types_b.geography_type%TYPE;
    l_count                  NUMBER;
    l_gnr_count              NUMBER;
    l_geography_id           NUMBER;
    l_postal_code            VARCHAR2(360);
    l_postal_code_range_flag VARCHAR2(1);
    l_geography_use          hz_geography_types_b.geography_use%TYPE;

    CURSOR included_geo_types(p_zone_type IN VARCHAR2) IS
    SELECT object_type
    FROM   hz_relationship_types
    WHERE  subject_type = p_zone_type
    AND    status = 'A'
    AND    relationship_type = 'TAX';


    CURSOR c_get_zones(c_object_type IN VARCHAR2, c_geography_id IN NUMBER) IS
    SELECT subject_id
    FROM   hz_relationships
    WHERE  subject_type = p_zone_type
    AND    subject_table_name = 'HZ_GEOGRAPHIES'
    AND    object_type = c_object_type
    AND    object_id = c_geography_id
    AND    object_table_name = 'HZ_GEOGRAPHIES'
    AND    relationship_type = 'TAX'
    AND    directional_flag = 'F'
    AND    relationship_code  = 'PARENT_OF'
    AND    p_date BETWEEN start_date and end_date;

    l_zone_id  number;
    l_zone_tbl zone_tbl_type;
    l_zone_tbl_final zone_tbl_type;
    i          number;
    j          number;
    l_populate_tbl varchar2(1);
    l_tbl_count  number;
    l_country_found   VARCHAR2(1);
    l_country_code    VARCHAR2(80);

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    i := 1;

    -- Validate zone type

    -- Bug 6842648 Perf fix to query
    SELECT count(1)
    INTO   l_count
    FROM   hz_geography_types_b
    WHERE  geography_type = p_zone_type
    AND    geography_use <> 'MASTER_REF'
    AND    rownum = 1;

    IF l_count = 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_ZONE_TYPE_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate that the zone type has associated reference
    -- geography types

    BEGIN
    -- Bug 6842648 Perf fix to query
      SELECT count(1)
      INTO   l_count
      FROM   hz_relationship_types
      WHERE  subject_type = p_zone_type
      AND    status = 'A'
      AND    rownum = 1;
    END;

    IF l_count = 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_ASSOC_GEO_TYPES');
      FND_MESSAGE.SET_TOKEN('GEO_TYPE', p_zone_type);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- To get country_code for the location
    BEGIN
      IF p_location_table_name = 'HZ_LOCATIONS' THEN
         SELECT country
         INTO   l_country_code
         FROM   hz_locations
         WHERE  location_id = p_location_id;
      ELSIF p_location_table_name = 'HR_LOCATIONS_ALL' THEN
         SELECT country
         INTO   l_country_code
         FROM   hr_locations
         WHERE  location_id = p_location_id;
      END IF;
    EXCEPTION WHEN others THEN
      l_country_code := NULL;
    END;

    -- Make a check that geo name referencing has been
    -- done for this location
    -- Bug 6842648 Perf fix to query
    SELECT count(1)
    INTO   l_gnr_count
    FROM   hz_geo_name_references
    WHERE  location_table_name = p_location_table_name
    AND    location_id = p_location_id
    AND    rownum = 1;

     -- Below code is commenmted for bug # 5011582
     -- Will display the message after the end loop of included_geo_types
--    IF l_count = 0 THEN
--      x_return_status := FND_API.G_RET_STS_ERROR;
--      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_GEO_NAME_REF');
--      FND_MSG_PUB.ADD;
--      RAISE FND_API.G_EXC_ERROR;
--    END IF;

    l_country_found := 'N';

    -- Find zone

    OPEN included_geo_types(p_zone_type);
    LOOP
      FETCH included_geo_types INTO l_ref_geo_type;
      EXIT WHEN included_geo_types%NOTFOUND;

      IF l_ref_geo_type = 'COUNTRY' THEN
         l_country_found := 'Y';
      END IF;

      -- find the geography id from hz_geo_name_references
      BEGIN
        SELECT geography_id
        INTO   l_geography_id
        FROM   hz_geo_name_references
        WHERE  location_table_name = p_location_table_name
        AND    location_id = p_location_id
        AND    geography_type = l_ref_geo_type;

      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_geography_id := NULL;

        -- if l_ref_geo_type is COUNTRY get geography_id from hz_geograpies
        IF l_ref_geo_type = 'COUNTRY' THEN
           SELECT geography_id
           INTO   l_geography_id
           FROM   hz_geographies
           WHERE  country_code = l_country_code
           AND    geography_type = l_ref_geo_type
           -- Bug 5410283 (Added on 07-Aug-2006)
		   AND    p_date BETWEEN start_date AND end_date;
        END IF;

      END;

      IF l_geography_id IS NOT NULL THEN

        OPEN c_get_zones(l_ref_geo_type,l_geography_id);
        LOOP
          FETCH c_get_zones INTO l_zone_id;
          EXIT WHEN c_get_zones%NOTFOUND;
          l_zone_tbl(i).zone_id := l_zone_id;

            IF l_zone_id IS NOT NULL THEN
              SELECT postal_code_range_flag, geography_use
              INTO   l_postal_code_range_flag, l_geography_use
              FROM   hz_geography_types_b
              WHERE  geography_type = p_zone_type;


              -- Postal code range flag is applicable only for eTax
              -- if geography_use is not TAX then return the zone id

              IF l_geography_use = 'TAX' THEN
                IF l_postal_code_range_flag = 'N' THEN
                  -- return the zone_id
                --  EXIT;
                  null;
                ELSE

                  -- Bug 4639558 return the zone
                  -- if no range exists for the master_ref_geography
                  -- for that zone.

                 -- Bug 6842648 Perf fix to query
                 -- Bug 7837051 Commented Master_ref_geography_id Join
                 SELECT count(1) INTO l_count
                 FROM  hz_geography_ranges
                 WHERE -- master_ref_geography_id = l_geography_id AND
                       geography_id = l_zone_id
                 AND   geography_type = p_zone_type
                 AND   geography_use = 'TAX'
                 AND   rownum = 1;

                IF l_count > 0 THEN

                  -- Removed PO_VENDOR_SITES_ALL from the below if condition. Bug # 4584465

                  IF p_location_table_name = 'HR_LOCATIONS_ALL' THEN

                    SELECT postal_code
                    INTO   l_postal_code
                    FROM   hr_locations_all
                    WHERE  location_id = p_location_id;

                  ELSIF p_location_table_name = 'HZ_LOCATIONS' THEN

                    SELECT postal_code
                    INTO   l_postal_code
                    FROM   hz_locations
                    WHERE  location_id = p_location_id;

                  END IF;

                  -- Bug 6842648 Perf fix to query
                  -- Bug 7837051 Commented Master_ref_geography_id Join
                  SELECT count(1)
                  INTO   l_count
                  FROM   hz_geography_ranges
                  WHERE  geography_id = l_zone_id
                --AND    master_ref_geography_id = l_geography_id
                  AND    l_postal_code between geography_from and geography_to
                  AND    p_date between start_date and end_date
                  AND    rownum = 1;

                  IF l_count = 0 THEN
                    -- If count = 0,
                    l_zone_id := NULL;
                    l_zone_tbl(i).zone_id := l_zone_id;
                    i := i-1;
                  END IF;

                 ELSE -- no range record found
                   NULL; -- continue in the loop
                 END IF;

                END IF; --postal code range flag

              ELSE -- geography use not tax
                NULL; -- continue in the loop to find out more zones can be found
              END IF; -- geography use

            ELSE -- x_zone_id is null
              NULL; -- continue in the loop
            END IF;
            i := i+1;
        END LOOP;
        CLOSE c_get_zones;
      ELSE -- l_geography_id is null
        NULL; -- continue in the loop
      END IF;

    END LOOP;

    -- If there is COUNTRY in included_geo_types and no GNR
    IF (l_country_found = 'N' AND
        l_gnr_count = 0) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_GEO_NAME_REF');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_zone_tbl.COUNT > 0 THEN
       i := l_zone_tbl.FIRST;
       LOOP
         IF l_zone_tbl(i).zone_id IS NOT NULL THEN
            IF l_zone_tbl_final.COUNT > 0 THEN
               j := l_zone_tbl_final.FIRST;
               LOOP
                  IF l_zone_tbl(i).zone_id = l_zone_tbl_final(j).zone_id then
                     l_populate_tbl := 'N';
                     EXIT;
                  ELSE
                     l_populate_tbl := 'Y';
                  END IF;
                  EXIT WHEN j = l_zone_tbl_final.LAST;
                  j := l_zone_tbl_final.NEXT(j);
               END LOOP;
               IF l_populate_tbl = 'Y' THEN
                  l_tbl_count := l_zone_tbl_final.COUNT;
                  SELECT geography_id, geography_code, geography_name
                  INTO   l_zone_tbl_final(l_tbl_count+1).zone_id,
                         l_zone_tbl_final(l_tbl_count+1).zone_code,
                         l_zone_tbl_final(l_tbl_count+1).zone_name
                  FROM   hz_geographies
                  WHERE  geography_id = l_zone_tbl(i).zone_id
                  -- Bug 5410283 (Added on 07-Aug-2006)
  	              AND    p_date BETWEEN start_date AND end_date;
                  l_zone_tbl_final(l_tbl_count+1).zone_type := p_zone_type;
               END IF;
            ELSE
               SELECT geography_id, geography_code, geography_name
               INTO   l_zone_tbl_final(i).zone_id, l_zone_tbl_final(i).zone_code, l_zone_tbl_final(i).zone_name
               FROM   hz_geographies
               WHERE  geography_id = l_zone_tbl(i).zone_id
               -- Bug 5410283 (Added on 07-Aug-2006)
               AND    p_date BETWEEN start_date AND end_date;

               l_zone_tbl_final(i).zone_type := p_zone_type;
            END IF;
         END IF;
         EXIT WHEN i = l_zone_tbl.LAST;
         i := l_zone_tbl.NEXT(i);
       END LOOP;
    END IF;

    x_zone_tbl := l_zone_tbl_final;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END get_zone;

Function get_conc_name(l_geo_id IN NUMBER)
return VARCHAR2 is
	l_display_val VARCHAR2(3650);
	l_country_id NUMBER;
	l_geo_type VARCHAR2(30);
	l_col VARCHAR2(100);
	l_clause VARCHAR2(1000) := '';

	TYPE ConcGeoName IS REF CURSOR;
	conc_geo ConcGeoName;

	cursor g_structure is
		SELECT geography_element_column
		FROM hz_geo_structure_levels hgsl
		START WITH PARENT_GEOGRAPHY_TYPE = 'COUNTRY'
		and hgsl.geography_id = l_country_id
		CONNECT BY PRIOR hgsl.GEOGRAPHY_TYPE = hgsl.PARENT_GEOGRAPHY_TYPE
		and hgsl.geography_id = l_country_id
		and parent_geography_type <> l_geo_type;

Begin
	Begin
		select geography_element1_id, geography_type into l_country_id, l_geo_type
		from hz_geographies
		where geography_id = l_geo_id;
	Exception
		When no_data_found then
			return hz_utility_v2pub.Get_LookupMeaning('AR_LOOKUPS', 'HZ_GEO_DISPLAY_ONLY', 'WORLD');
	end;

	l_clause := 'nvl2(geography_element1, geography_element1, geography_name)';

	open g_structure;
	loop
		fetch g_structure into l_col;
	EXIT WHEN g_structure%NOTFOUND;
		l_clause := l_clause || '|| nvl2('||l_col||', '':''|| '||l_col||', '''')';
	end loop;
	close g_structure;

	OPEN conc_geo FOR
		'select '||l_clause||' from hz_geographies where geography_id = :1' USING l_geo_id;
	fetch conc_geo into l_display_val;
	close conc_geo;
        return l_display_val;
end get_conc_name;
END;

/
