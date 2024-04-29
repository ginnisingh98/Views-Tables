--------------------------------------------------------
--  DDL for Package Body HZ_GEO_STRUCT_MAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_STRUCT_MAP_PUB" AS
/* $Header: ARHGNRMB.pls 120.17 2006/04/11 00:28:16 nsinghai noship $ */

TYPE l_geo_struct_map_dtl_rec_type IS RECORD
  (loc_seq_num             NUMBER,
   loc_comp                VARCHAR2(30),
   geo_type                VARCHAR2(30),
   geo_element_col         VARCHAR2(30)
   );

TYPE l_geo_struct_map_dtl_tbl_type IS TABLE of l_geo_struct_map_dtl_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE validate_address_context(
    p_location_table_name              IN         VARCHAR2,
    p_context                          IN         VARCHAR2,
    p_territory_code                   IN         VARCHAR2,
    x_ret_status                       OUT NOCOPY VARCHAR2
  );

  PROCEDURE check_valid_loc_comp(
    p_loc_comp                         IN         VARCHAR2,
    p_location_table_name              IN         VARCHAR2,
    x_ret_status                       OUT NOCOPY VARCHAR2,
    x_error_code                       OUT NOCOPY VARCHAR2
  );

  PROCEDURE check_valid_geo_type(
    p_geo_type                         IN         VARCHAR2,
    x_ret_status                       OUT NOCOPY VARCHAR2,
    x_error_code                       OUT NOCOPY VARCHAR2
  );

  PROCEDURE find_geo_element_col(
    p_geography_type                  IN           VARCHAR2,
    p_parent_geography_type           IN           VARCHAR2,
    p_country                         IN           VARCHAR2,
    p_geo_element_col                 OUT NOCOPY   VARCHAR2,
    x_ret_status                      OUT NOCOPY   VARCHAR2
  );

  PROCEDURE validate_address_context(p_location_table_name IN         VARCHAR2,
                                     p_context             IN         VARCHAR2,
                                     p_territory_code      IN         VARCHAR2,
                                     x_ret_status          OUT NOCOPY VARCHAR2
                                     ) IS
    l_descriptive_flexfield_name fnd_descr_flex_contexts_vl.descriptive_flexfield_name%TYPE;
    l_context fnd_descr_flex_contexts_vl.descriptive_flex_context_code%TYPE;
    l_application_id NUMBER;
  BEGIN
    IF UPPER(p_location_table_name) = 'HR_LOCATIONS_ALL' THEN
      l_descriptive_flexfield_name := 'Address Location';
      l_application_id := 800;
    -- Removed PO_VENDOR_SITES_ALL from the below if condition. Bug # 4584465
    --ELSIF UPPER(p_location_table_name) = 'PO_VENDOR_SITES_ALL' THEN
    --  l_descriptive_flexfield_name := 'Site Address';
    --  l_application_id := 200;
    ELSIF UPPER(p_location_table_name) = 'HZ_LOCATIONS' THEN
      l_descriptive_flexfield_name := 'Remit Address HZ';
      l_application_id := 222;
    END IF;

    BEGIN
     SELECT address_style
     INTO   l_context
     FROM   fnd_territories
     WHERE  territory_code = p_territory_code
     AND    l_application_id = 222
     AND    address_style = p_context ;

     EXCEPTION WHEN NO_DATA_FOUND THEN

     BEGIN
      SELECT descriptive_flex_context_code
      INTO   l_context
      FROM   fnd_descr_flex_contexts_vl
      WHERE  application_id = l_application_id
      AND    descriptive_flexfield_name = l_descriptive_flexfield_name
      AND    descriptive_flex_context_code = p_context;

     EXCEPTION WHEN NO_DATA_FOUND THEN
      x_ret_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_ADDRESS_STYLE_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
     END;
    END;

  END validate_address_context;

  PROCEDURE check_valid_loc_comp(p_loc_comp   IN VARCHAR2,
                                 p_location_table_name IN VARCHAR2,
                                 x_ret_status OUT NOCOPY VARCHAR2,
                                 x_error_code OUT NOCOPY VARCHAR2) IS
    l_exists VARCHAR2(6);
    l_application_id NUMBER;
  BEGIN

    x_ret_status := FND_API.G_RET_STS_SUCCESS;

    IF UPPER(p_location_table_name) = 'HR_LOCATIONS_ALL' THEN
      l_application_id := 800;
    ELSIF UPPER(p_location_table_name) = 'HZ_LOCATIONS' THEN
      l_application_id := 222;
    END IF;

    SELECT 'Exists'
    INTO   l_exists
    FROM   fnd_columns col, fnd_tables tbl
    WHERE  tbl.table_id = col.table_id
    AND    tbl.application_id = col.application_id
    AND    tbl.application_id= l_application_id
    AND    col.column_name = p_loc_comp
    AND    tbl.table_name = p_location_table_name
    AND    col.column_name NOT IN ('LAST_UPDATED_BY', 'CREATION_DATE', 'CREATED_BY',
                                   'LAST_UPDATE_DATE', 'LAST_UPDATE_LOGIN');

  EXCEPTION WHEN NO_DATA_FOUND THEN
    x_ret_status := FND_API.G_RET_STS_ERROR;
    x_error_code := 'HZ_GEO_LOC_COMP_INVALID';

  END;

  PROCEDURE check_valid_geo_type(p_geo_type   IN VARCHAR2,
                                 x_ret_status OUT NOCOPY VARCHAR2,
                                 x_error_code OUT NOCOPY VARCHAR2) IS
    l_exists VARCHAR2(6);
  BEGIN

    x_ret_status := FND_API.G_RET_STS_SUCCESS;

    SELECT 'Exists'
    INTO   l_exists
    FROM   hz_geography_types_b
    WHERE  geography_type = UPPER(p_geo_type);

  EXCEPTION WHEN NO_DATA_FOUND THEN
    x_ret_status := FND_API.G_RET_STS_ERROR;
    x_error_code := 'HZ_GEO_GEO_TYPE_INVALID';

  END;

  PROCEDURE find_geo_element_col(p_geography_type IN VARCHAR2,
                                 p_parent_geography_type IN VARCHAR2,
                                 p_country IN VARCHAR2,
                                 p_geo_element_col OUT NOCOPY VARCHAR2,
                                 x_ret_status OUT NOCOPY VARCHAR2) IS
    CURSOR determine_geo_element_col(p_parent_geo_type VARCHAR2,
                                     p_country VARCHAR2) IS
      SELECT geography_type, geography_element_column
      FROM  hz_geo_structure_levels
      WHERE country_code = p_country
      START WITH parent_geography_type  = p_parent_geo_type
      AND   country_code = p_country
      CONNECT BY PRIOR geography_type = parent_geography_type
      AND   country_code = p_country;
    l_geo_type hz_geography_types_b.geography_type%TYPE;
    l_geo_element_col hz_geo_structure_levels.geography_element_column%TYPE;

  BEGIN

    x_ret_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
      SELECT geography_element_column
      INTO  p_geo_element_col
      FROM  hz_geo_structure_levels
      WHERE geography_type = p_geography_type
      AND   parent_geography_type  = p_parent_geography_type
      AND   country_code = p_country;

    EXCEPTION WHEN NO_DATA_FOUND THEN
      p_geo_element_col := null;
    END;
    --
    IF p_geo_element_col IS NULL THEN
      OPEN determine_geo_element_col(p_parent_geography_type, p_country);
      LOOP
        FETCH determine_geo_element_col INTO l_geo_type, l_geo_element_col;
        EXIT WHEN determine_geo_element_col%NOTFOUND;
        IF l_geo_type = p_geography_type THEN
          p_geo_element_col := l_geo_element_col;
          EXIT;
        END IF;
      END LOOP;
      CLOSE determine_geo_element_col;
      IF p_geo_element_col IS NULL THEN
        x_ret_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END find_geo_element_col;

  PROCEDURE do_create_geo_struct_mapping
    (p_geo_struct_map_rec      IN              geo_struct_map_rec_type,
     p_geo_struct_map_dtl_tbl  IN              geo_struct_map_dtl_tbl_type,
     x_map_id                  OUT  NOCOPY     NUMBER,
     x_return_status           OUT  NOCOPY     VARCHAR2) IS

   i                 BINARY_INTEGER;
   n                 BINARY_INTEGER;
   m                 BINARY_INTEGER;
   l_map_id          NUMBER;
   l_country         VARCHAR2(2);
   l_loc_seq_num     NUMBER;
   l_loc_comp        VARCHAR2(30);
   l_geo_type        VARCHAR2(30);
   l_parent_geo_type VARCHAR2(30);
   l_error_code      VARCHAR2(30);
   l_geo_struct_map_dtl_tbl  l_geo_struct_map_dtl_tbl_type ;
   p_mltbl                  HZ_GNR_UTIL_PKG.maploc_rec_tbl_type;
   x_map_row_id      VARCHAR2(50);
   x_map_dtl_row_id  VARCHAR2(50);
   l_token_name      VARCHAR2(30);
   l_token_value     VARCHAR2(30);
   l_temp            VARCHAR2(100);

   CURSOR c_determine_geo_element_col(c_geo_type VARCHAR2, c_country VARCHAR2) IS
   SELECT level+1 seq_num
   FROM   hz_geo_structure_levels
   WHERE  geography_type = c_geo_type
   START WITH parent_geography_type = 'COUNTRY'
   AND country_code = c_country
   CONNECT BY PRIOR geography_type = parent_geography_type
   AND country_code = c_country;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_error_code := NULL;

    -- Location table name is mandatory

    IF p_geo_struct_map_rec.loc_tbl_name IS NULL THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_LOC_TABLE_MAND');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Country code is mandatory

    IF p_geo_struct_map_rec.country_code IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_COUNTRY_MAND');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- location table name should be one of
    -- PO_VENDOR_SITES_ALL, HR_LOCATIONS_ALL, HZ_LOCATIONS
    -- Removed PO_VENDOR_SITES_ALL from the below if condition. Bug # 4584465

    IF UPPER(p_geo_struct_map_rec.loc_tbl_name) NOT IN ('HR_LOCATIONS_ALL',
                                                        'HZ_LOCATIONS') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_LOC_TABLE_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- country should exist in fnd_territories

    BEGIN
      SELECT territory_code
      INTO l_country
      FROM fnd_territories
      WHERE territory_code = UPPER(p_geo_struct_map_rec.country_code);

    EXCEPTION WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_COUNTRY_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

    END;

    -- Address_style is nullable
    -- If not null then should exist as a context defined under the respective product's
    -- address flexfield

    IF p_geo_struct_map_rec.address_style IS NULL THEN
      NULL;
    ELSE
      validate_address_context(UPPER(p_geo_struct_map_rec.loc_tbl_name),
                               UPPER(p_geo_struct_map_rec.address_style),
                               UPPER(p_geo_struct_map_rec.country_code),
                               x_return_status);
    END IF;

    -- At least one row is mandatory in map details
    -- Not more than 10 rows can be passed in map details

    IF p_geo_struct_map_dtl_tbl.COUNT < 2 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_2_MAP_DTL_MAND');
      -- Please enter at least two location components.
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

    ELSIF p_geo_struct_map_dtl_tbl.COUNT > 10 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_TOO_MANY_MAP_DTLS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

    END IF;

    -- sort the map details table into a temporary
    -- table which will be indexed by loc_seq_num
    -- Before sorting validate that loc seq num, loc comp,
    -- geo type is mandatory in each row.
    -- If not null then check that loc comp and geo type are
    -- valid. If the sorted table has fewer number of rows than
    -- what is passed, then it means that loc_seq_num was duplicate.

    BEGIN

      i := p_geo_struct_map_dtl_tbl.first;
      WHILE i IS NOT NULL LOOP

        -- Modified the below code to derive loc_seq_num from hz_geo_structure_levels
        -- The new loc_seq_num will override the passed loc_seq_num value.
        l_loc_seq_num := NULL;
        IF p_geo_struct_map_dtl_tbl(i).geo_type = 'COUNTRY' then
           l_loc_seq_num := 1;
        ELSE
          OPEN  c_determine_geo_element_col(p_geo_struct_map_dtl_tbl(i).geo_type, p_geo_struct_map_rec.country_code);
          FETCH c_determine_geo_element_col INTO l_loc_seq_num;
          CLOSE c_determine_geo_element_col;
        END IF;

        IF l_loc_seq_num IS NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_error_code := 'HZ_GEO_EL_COL_NOT_FOUND';
          l_token_name := 'GEOTYPE';
          l_token_value := p_geo_struct_map_dtl_tbl(i).geo_type;
          EXIT;
        END IF;
        IF p_geo_struct_map_dtl_tbl(i).loc_comp IS NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
         l_error_code := 'HZ_GEO_LOC_COMP_MAND';
         EXIT;
        ELSE
          check_valid_loc_comp(p_geo_struct_map_dtl_tbl(i).loc_comp, p_geo_struct_map_rec.loc_tbl_name,
                                 x_return_status, l_error_code);
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            l_token_name := 'LOCCOMP';
            l_token_value := p_geo_struct_map_dtl_tbl(i).loc_comp;
            EXIT;
          END IF;
        END IF;
        IF p_geo_struct_map_dtl_tbl(i).geo_type IS NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_error_code := 'HZ_GEO_GEO_TYPE_MAND';
          EXIT;
        ELSE
          check_valid_geo_type(p_geo_struct_map_dtl_tbl(i).geo_type, x_return_status, l_error_code);
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            l_token_name := 'GEOTYPE';
            l_token_value := p_geo_struct_map_dtl_tbl(i).geo_type;
            EXIT;
          END IF;
        END IF;
        l_geo_struct_map_dtl_tbl(l_loc_seq_num).loc_seq_num :=  l_loc_seq_num;
        l_geo_struct_map_dtl_tbl(l_loc_seq_num).loc_comp    :=  p_geo_struct_map_dtl_tbl(i).loc_comp;
        l_geo_struct_map_dtl_tbl(l_loc_seq_num).geo_type    :=  p_geo_struct_map_dtl_tbl(i).geo_type;
        i := p_geo_struct_map_dtl_tbl.next(i);
      END LOOP;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', l_error_code);
        IF l_token_value IS NOT NULL THEN
          FND_MESSAGE.SET_TOKEN(l_token_name, l_token_value);
        END IF;
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END;

    BEGIN
      IF p_geo_struct_map_dtl_tbl.count <> l_geo_struct_map_dtl_tbl.count THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_LOC_SEQ_NUM');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END;

    -- Validate that the first geo_type is COUNTRY in the sorted table
    -- Assign geography_element1 to COUNTRY
    -- Find geography_element column for the others
    BEGIN
      i := l_geo_struct_map_dtl_tbl.first;
      IF l_geo_struct_map_dtl_tbl(i).geo_type <> 'COUNTRY' THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GEO_TYPE_NOT_COUNTRY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        l_geo_struct_map_dtl_tbl(i).geo_element_col := 'GEOGRAPHY_ELEMENT1';
      END IF;
      i := l_geo_struct_map_dtl_tbl.next(i);

      WHILE i IS NOT NULL LOOP
        l_geo_type := l_geo_struct_map_dtl_tbl(i).geo_type;
        n := l_geo_struct_map_dtl_tbl.PRIOR(i);
        l_parent_geo_type := l_geo_struct_map_dtl_tbl(n).geo_type;
        find_geo_element_col(l_geo_type,
                             l_parent_geo_type,
                             p_geo_struct_map_rec.country_code,
                             l_geo_struct_map_dtl_tbl(i).geo_element_col,
                             x_return_status);
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          EXIT;
        END IF;
        i := l_geo_struct_map_dtl_tbl.next(i);
      END LOOP;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_EL_COL_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('GEOTYPE',l_geo_struct_map_dtl_tbl(i).geo_type);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END;

    -- Call table handler to insert row and make a
    -- call to create map packages

    BEGIN --insert row
      SELECT HZ_GEO_STRUCT_MAP_S.nextval
      INTO l_map_id
      FROM dual;
      hz_geo_struct_map_pvt.insert_row(
                                  x_map_row_id,
                                  l_map_id,
                                  p_geo_struct_map_rec.country_code,
                                  p_geo_struct_map_rec.loc_tbl_name,
                                  p_geo_struct_map_rec.address_style);
      END;

      BEGIN
      i := l_geo_struct_map_dtl_tbl.first;
      m := 0;
      WHILE i IS NOT NULL LOOP
--
        m := m + 1;
        p_mltbl(m).loc_seq_num     := l_geo_struct_map_dtl_tbl(i).loc_seq_num;
        p_mltbl(m).loc_component   := l_geo_struct_map_dtl_tbl(i).loc_comp;
        p_mltbl(m).geography_type  := l_geo_struct_map_dtl_tbl(i).geo_type;
        p_mltbl(m).geo_element_col := l_geo_struct_map_dtl_tbl(i).geo_element_col;
        p_mltbl(m).loc_compval     := null;
        p_mltbl(m).geography_id    := null;
--
        hz_geo_struct_map_dtl_pvt.insert_row(
                                  x_map_dtl_row_id,
                                  l_map_id,
                                  l_geo_struct_map_dtl_tbl(i).loc_seq_num,
                                  l_geo_struct_map_dtl_tbl(i).loc_comp,
                                  l_geo_struct_map_dtl_tbl(i).geo_type,
                                  l_geo_struct_map_dtl_tbl(i).geo_element_col);
         i := l_geo_struct_map_dtl_tbl.next(i);
        END LOOP;
      END; -- insert row

      x_map_id := l_map_id;

END do_create_geo_struct_mapping;

PROCEDURE create_geo_struct_mapping(
     p_geo_struct_map_rec      IN              geo_struct_map_rec_type,
     p_geo_struct_map_dtl_tbl  IN              geo_struct_map_dtl_tbl_type,
     p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
     x_map_id                  OUT    NOCOPY   NUMBER,
     x_return_status           OUT    NOCOPY   VARCHAR2,
     x_msg_count               OUT    NOCOPY   NUMBER,
     x_msg_data                OUT    NOCOPY   VARCHAR2) IS
   p_index_name  VARCHAR2(30);
   l_temp            VARCHAR2(1000);
 BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_geo_struct_map;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_geo_struct_mapping(
                              p_geo_struct_map_rec,
                              p_geo_struct_map_dtl_tbl,
                              x_map_id,
                              x_return_status
        );

    --  if validation failed at any point, then raise an exception to stop processing
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_geo_struct_map;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_geo_struct_map;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO create_geo_struct_map;
        x_return_status := FND_API.G_RET_STS_ERROR;
        HZ_UTILITY_V2PUB.find_index_name(p_index_name);
        IF p_index_name = 'HZ_GEO_STRUCT_MAP_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_MAP_ID');
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_GEO_STRUCT_MAP_U2' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_MAP_ROW_EXISTS');
          FND_MESSAGE.SET_TOKEN('TABLENAME', p_geo_struct_map_rec.loc_tbl_name);
          FND_MESSAGE.SET_TOKEN('COUNTRY', p_geo_struct_map_rec.country_code);
          FND_MESSAGE.SET_TOKEN('ADDRSTYLE', p_geo_struct_map_rec.address_style);
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_GEO_STRUCT_MAP_DTL_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_LOC_SEQ_NUM');
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_GEO_STRUCT_MAP_DTL_U2' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_LOC_COMP');
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_GEO_STRUCT_MAP_DTL_U3' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_GEO_TYPE');
          FND_MSG_PUB.ADD;
        END IF;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO create_geo_struct_map;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

  END create_geo_struct_mapping;

  PROCEDURE delete_geo_struct_mapping(
                   p_map_id              IN         NUMBER,
                   p_location_table_name IN         VARCHAR2,
                   p_country             IN         VARCHAR2,
                   p_address_style       IN         VARCHAR2,
                   p_geo_struct_map_dtl_tbl  IN     geo_struct_map_dtl_tbl_type,
                   p_init_msg_list       IN         VARCHAR2 := FND_API.G_FALSE,
                   x_return_status       OUT NOCOPY VARCHAR2,
                   x_msg_count           OUT NOCOPY NUMBER,
                   x_msg_data            OUT NOCOPY VARCHAR2
                   ) IS
  l_map_id       NUMBER;
  l_usage_id     NUMBER;
  l_count        NUMBER;
  l_pkgname      VARCHAR2(50);
  l_status       VARCHAR2(30);
--  pkg_name       VARCHAR2(1000);
--  l_drp_sql      VARCHAR2(1000);
  l_address_usage_dtls_tbl  HZ_ADDRESS_USAGES_PUB.address_usage_dtls_tbl_type;

  CURSOR c_address_usages IS
  SELECT usage_id
  FROM   hz_address_usages
  WHERE  map_id = p_map_id;

  CURSOR c_address_usage_dtls(c_geography_type varchar2) IS
  SELECT dtl.usage_id
  FROM   Hz_address_usages usg, Hz_address_usage_dtls dtl
  WHERE  usg.map_id = p_map_id
  AND    dtl.geography_type = c_geography_type
  AND    dtl.usage_id = usg.usage_id;

  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  i                    BINARY_INTEGER;
  l_delete_mapping_also VARCHAR(1);
  l_del_geo_type       VARCHAR2(100);

  BEGIN

    -- delete row using country, address style, location table name
    -- If above is not provided map_id should be provided, delete as
    -- per map id.

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_map_id IS NULL THEN
      IF p_location_table_name IS NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_LOC_TABLE_MAND');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_country IS NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_COUNTRY_MAND');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_address_style IS NULL THEN
        BEGIN
          SELECT map_id
          INTO  l_map_id
          FROM  hz_geo_struct_map
          WHERE country_code = p_country
          AND   loc_tbl_name = p_location_table_name
          AND   address_style  IS NULL;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_MAPPING_ROW');
          FND_MSG_PUB.ADD;

        END;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        BEGIN
          SELECT map_id
          INTO  l_map_id
          FROM  hz_geo_struct_map
          WHERE country_code = p_country
          AND   loc_tbl_name = p_location_table_name
          AND   address_style = p_address_style;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_MAPPING_ROW');
          FND_MSG_PUB.ADD;
        END;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;
    ELSE
      BEGIN
        SELECT map_id
        INTO  l_map_id
        FROM  hz_geo_struct_map
        WHERE map_id = p_map_id;

      EXCEPTION WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_MAPPING_ROW');
        FND_MSG_PUB.ADD;
      END;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

    IF p_geo_struct_map_dtl_tbl.COUNT > 0 THEN
       i:= p_geo_struct_map_dtl_tbl.FIRST;
       LOOP
          BEGIN
             SELECT count(*)
             INTO  l_count
             FROM  hz_geo_struct_map_dtl
             WHERE map_id = p_map_id;

             -- At least two location components is required for the mapping.
             -- So, if the count is more than 2 we can delete the mapping details.
             -- If count is 2 or less, we delete both mappings (Bug 5096570) Nishant 06-Apr-2006
             IF l_count < 3 then

               l_delete_mapping_also := 'N';

               BEGIN
                 SELECT geography_type
                 INTO  l_del_geo_type
                 FROM  hz_geo_struct_map_dtl
                 WHERE map_id = p_map_id
                 AND   geography_type <> p_geo_struct_map_dtl_tbl(i).geo_type;

                 l_delete_mapping_also := 'Y';
			   EXCEPTION WHEN NO_DATA_FOUND THEN
                /*
				x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_2_MAP_DTL_MAND');
                -- At least two location components is required for the mapping
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
                */
                -- only 1 mapping detail that will be deleted below, so just delete the
                -- mapping itself.
                l_delete_mapping_also := 'Y';
               END;

             END IF;

             IF p_geo_struct_map_dtl_tbl(i).geo_type = 'COUNTRY' THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GEO_TYPE_NOT_COUNTRY');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END;

          -- If there is a record in the usage dtls table, detete that record before
          -- deleting the mapping dtl record.
          OPEN c_address_usage_dtls(p_geo_struct_map_dtl_tbl(i).geo_type);
          LOOP
             FETCH c_address_usage_dtls INTO l_usage_id;
             EXIT WHEN c_address_usage_dtls%NOTFOUND;
             l_address_usage_dtls_tbl(1).geography_type := p_geo_struct_map_dtl_tbl(i).geo_type;
             HZ_ADDRESS_USAGES_PUB.delete_address_usages(
                                p_usage_id               => l_usage_id,
                                p_address_usage_dtls_tbl => l_address_usage_dtls_tbl,
                                p_init_msg_list          => 'F',
                                x_return_status          => l_return_status,
                                x_msg_count              => l_msg_count,
                                x_msg_data               => l_msg_data);
             IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_ERR_IN_USAGE_DEL_API');
                -- Error in Usage Delete API
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END LOOP;
          CLOSE c_address_usage_dtls;

          hz_geo_struct_map_dtl_pvt.delete_row(l_map_id,p_geo_struct_map_dtl_tbl(i).geo_type);

          -- If count is 2 or less, we delete both mapping details (Bug 5096570) Nishant 06-Apr-2006
          IF (l_del_geo_type) IS NOT NULL THEN
            -- This is the last mapping which cannot exist on its own
            -- delete mapping detail for other remaining record
            hz_geo_struct_map_dtl_pvt.delete_row(l_map_id,l_del_geo_type);
          END IF;

          IF (l_delete_mapping_also = 'Y') THEN
            -- delete mapping record also
            hz_geo_struct_map_pvt.delete_row(l_map_id);
            i := p_geo_struct_map_dtl_tbl.LAST; -- make i = LAST so that it exits loop
          END IF;

          EXIT WHEN i = p_geo_struct_map_dtl_tbl.LAST;
          i := p_geo_struct_map_dtl_tbl.NEXT(i);
       END LOOP;

       /* -- Commenting out regeneration call here because Usage details deletion
          -- will regenerate the package

        -- After deleting all the usage dtls and mapping dtls
        -- call the genpkg to recreate gnr package.
        --dbms_output.put_line('Before Gen pkg Create usage : map id :'|| p_address_usages_rec.map_id);
        BEGIN
           hz_gnr_gen_pkg.genpkg(p_map_id,l_pkgname,l_status);
           IF l_status = FND_API.G_RET_STS_ERROR THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_PKG_ERR');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        EXCEPTION WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_INTERNAL_ERROR');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        END;
        --dbms_output.put_line('After Gen pkg Create usage : map id :'|| p_address_usages_rec.map_id);
        */

    ELSE
       FOR i IN c_address_usages
       LOOP

          SELECT count(*)
          INTO  l_count
          FROM  hz_address_usage_dtls
          WHERE usage_id = i.usage_id;

          -- If count is > 0 there is usage exists and we need to delete the usage records.
          -- Else, there is no need to call the delete usage API
          IF l_count > 0 then
             HZ_ADDRESS_USAGES_PUB.delete_address_usages(
                                p_usage_id       => i.usage_id,
                                p_address_usage_dtls_tbl => l_address_usage_dtls_tbl,
                                p_init_msg_list  => 'F',
                                x_return_status  => l_return_status,
                                x_msg_count      => l_msg_count,
                                x_msg_data       => l_msg_data);
             IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_ERR_IN_USAGE_DEL_API');
                -- Error in Usage Delete API
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;

       EXIT WHEN c_address_usages%NOTFOUND;
       END LOOP;

       SELECT count(*)
       INTO   l_count
       FROM   hz_geo_struct_map_dtl
       WHERE  map_id = l_map_id;

       IF l_count > 0 THEN
         hz_geo_struct_map_dtl_pvt.delete_row(l_map_id);
       END IF;
       hz_geo_struct_map_pvt.delete_row(l_map_id);
    END IF;

-- Commented the below code, since it also called from delete usages API.
--    pkg_name := 'HZ_GNR_MAP' ||to_char(l_map_id);
--    l_drp_sql := 'Drop Package Body '|| pkg_name;

--    EXECUTE IMMEDIATE l_drp_sql;

--    l_drp_sql := 'Drop Package '|| pkg_name;

--    EXECUTE IMMEDIATE l_drp_sql;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count        => x_msg_count,
                              p_data        => x_msg_data);

   WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count        => x_msg_count,
                              p_data        => x_msg_data);

 END delete_geo_struct_mapping;

PROCEDURE create_geo_struct_map_dtls
  (p_map_id                  IN              NUMBER,
   p_geo_struct_map_dtl_tbl  IN              geo_struct_map_dtl_tbl_type,
   p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
   x_return_status           OUT    NOCOPY   VARCHAR2,
   x_msg_count               OUT    NOCOPY   NUMBER,
   x_msg_data                OUT    NOCOPY   VARCHAR2
  ) IS

   i                         BINARY_INTEGER;
   n                         BINARY_INTEGER;
   l_country                 VARCHAR2(30);
   l_loc_tbl_name            VARCHAR2(30);
   l_loc_seq_num             NUMBER;
   l_loc_comp                VARCHAR2(30);
   l_geo_type                VARCHAR2(30);
   l_geo_element_column      VARCHAR2(30);
   l_error_code              VARCHAR2(30);
   x_map_dtl_row_id          VARCHAR2(50);
   l_token_name              VARCHAR2(30);
   l_token_value             VARCHAR2(30);
   p_index_name              VARCHAR2(30);
   l_map_dtl_count           NUMBER;
   l_geo_struct_map_dtl_tbl  l_geo_struct_map_dtl_tbl_type ;

   CURSOR c_struct_map(c_map_id number) IS
   SELECT country_code, loc_tbl_name
   FROM   hz_geo_struct_map
   WHERE  map_id = c_map_id;

   CURSOR c_map_dtl_count(c_map_id number) IS
   SELECT count(*)
   FROM   hz_geo_struct_map_dtl
   WHERE  map_id = c_map_id;

   CURSOR c_determine_geo_element_col(c_geo_type VARCHAR2, c_country VARCHAR2) IS
   SELECT level+1 seq_num, geography_element_column
   FROM   hz_geo_structure_levels
   WHERE  geography_type = c_geo_type
   START WITH parent_geography_type = 'COUNTRY'
   AND country_code = c_country
   CONNECT BY PRIOR geography_type = parent_geography_type
   AND country_code = c_country;

BEGIN

   -- Standard start of API savepoint
   SAVEPOINT create_geo_struct_map_dtls;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_country      := NULL;
   l_loc_tbl_name := NULL;
   OPEN  c_struct_map(p_map_id);
   FETCH c_struct_map INTO l_country, l_loc_tbl_name;
   CLOSE c_struct_map;

   IF (l_country IS NULL OR l_loc_tbl_name IS NULL) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_MAP_ID');
      -- Please pass a valid map ID that is not NULL.
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_map_dtl_count := 0;
   OPEN  c_map_dtl_count(p_map_id);
   FETCH c_map_dtl_count INTO l_map_dtl_count;
   CLOSE c_map_dtl_count;

   -- Not more than 10 rows can be created in map details
   IF (p_geo_struct_map_dtl_tbl.COUNT+l_map_dtl_count) > 10 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_TOO_MANY_MAP_DTLS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- sort the map details table into a temporary
   -- table which will be indexed by loc_seq_num
   -- Before sorting validate that loc seq num, loc comp,
   -- geo type is mandatory in each row.
   -- If not null then check that loc comp and geo type are
   -- valid. If the sorted table has fewer number of rows than
   -- what is passed, then it means that loc_seq_num was duplicate.

   BEGIN

      i := p_geo_struct_map_dtl_tbl.first;
      WHILE i IS NOT NULL LOOP

         -- Added the below code to derive loc_seq_num from hz_geo_structure_levels
         -- The new loc_seq_num will override the passed loc_seq_num value.
         l_loc_seq_num := NULL;
         IF p_geo_struct_map_dtl_tbl(i).geo_type = 'COUNTRY' then
           l_loc_seq_num := 1;
           l_geo_element_column := 'GEOGRAPHY_ELEMENT1';
         ELSE
           OPEN  c_determine_geo_element_col(p_geo_struct_map_dtl_tbl(i).geo_type, l_country);
           FETCH c_determine_geo_element_col INTO l_loc_seq_num, l_geo_element_column;
           CLOSE c_determine_geo_element_col;
         END IF;

         IF (l_loc_seq_num IS NULL OR l_geo_element_column IS NULL) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_EL_COL_NOT_FOUND');
            FND_MESSAGE.SET_TOKEN('GEOTYPE',p_geo_struct_map_dtl_tbl(i).geo_type);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF p_geo_struct_map_dtl_tbl(i).loc_comp IS NULL THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_error_code := 'HZ_GEO_LOC_COMP_MAND';
            EXIT;
         ELSE
            check_valid_loc_comp(p_geo_struct_map_dtl_tbl(i).loc_comp, l_loc_tbl_name,
                                 x_return_status, l_error_code);
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               l_token_name := 'LOCCOMP';
               l_token_value := p_geo_struct_map_dtl_tbl(i).loc_comp;
               EXIT;
            END IF;
         END IF;

         IF p_geo_struct_map_dtl_tbl(i).geo_type IS NULL THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_error_code := 'HZ_GEO_GEO_TYPE_MAND';
            EXIT;
         ELSE
            check_valid_geo_type(p_geo_struct_map_dtl_tbl(i).geo_type, x_return_status, l_error_code);
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               l_token_name := 'GEOTYPE';
               l_token_value := p_geo_struct_map_dtl_tbl(i).geo_type;
               EXIT;
            END IF;
         END IF;


         l_geo_struct_map_dtl_tbl(l_loc_seq_num).loc_seq_num := l_loc_seq_num;
         l_geo_struct_map_dtl_tbl(l_loc_seq_num).loc_comp := p_geo_struct_map_dtl_tbl(i).loc_comp;
         l_geo_struct_map_dtl_tbl(l_loc_seq_num).geo_type := p_geo_struct_map_dtl_tbl(i).geo_type;
         l_geo_struct_map_dtl_tbl(l_loc_seq_num).geo_element_col := l_geo_element_column;
         i := p_geo_struct_map_dtl_tbl.next(i);

      END LOOP;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         FND_MESSAGE.SET_NAME('AR', l_error_code);
         IF l_token_value IS NOT NULL THEN
            FND_MESSAGE.SET_TOKEN(l_token_name, l_token_value);
         END IF;
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END;

   -- Call table handler to insert row and make a
   -- call to create map packages

   BEGIN --insert row
      i := l_geo_struct_map_dtl_tbl.first;
      WHILE i IS NOT NULL LOOP

         hz_geo_struct_map_dtl_pvt.insert_row(
                                  x_map_dtl_row_id,
                                  p_map_id,
                                  l_geo_struct_map_dtl_tbl(i).loc_seq_num,
                                  l_geo_struct_map_dtl_tbl(i).loc_comp,
                                  l_geo_struct_map_dtl_tbl(i).geo_type,
                                  l_geo_struct_map_dtl_tbl(i).geo_element_col);
         i := l_geo_struct_map_dtl_tbl.next(i);
      END LOOP;
   END; -- insert row

   --  if validation failed at any point, then raise an exception to stop processing
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data);

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_geo_struct_map_dtls;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_geo_struct_map_dtls;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO create_geo_struct_map_dtls;
        x_return_status := FND_API.G_RET_STS_ERROR;
        HZ_UTILITY_V2PUB.find_index_name(p_index_name);

        IF p_index_name = 'HZ_GEO_STRUCT_MAP_DTL_U1' THEN
          -- FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_LOC_SEQ_NUM');
          -- Changed the error message from HZ_GEO_DUP_LOC_SEQ_NUM to HZ_GEO_DUP_GEO_TYPE
          -- In the new design we are overriding the LOC_SEQ_NUM passed by the user
          -- and deriving it based on GEO_TYPE. So, it is better to display GEO_TYPE
          -- unique index error message for LOC_SEQ_NUM also.
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_GEO_TYPE');
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_GEO_STRUCT_MAP_DTL_U2' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_LOC_COMP');
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_GEO_STRUCT_MAP_DTL_U3' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_GEO_TYPE');
          FND_MSG_PUB.ADD;
        END IF;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);
   WHEN OTHERS THEN
        ROLLBACK TO create_geo_struct_map_dtls;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END create_geo_struct_map_dtls;

PROCEDURE update_geo_struct_map_dtls
  (p_map_id                  IN              NUMBER,
   p_geo_struct_map_dtl_tbl  IN              geo_struct_map_dtl_tbl_type,
   p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
   x_return_status           OUT    NOCOPY   VARCHAR2,
   x_msg_count               OUT    NOCOPY   NUMBER,
   x_msg_data                OUT    NOCOPY   VARCHAR2
  ) IS

   p_index_name              VARCHAR2(30);
   l_country                 VARCHAR2(30);
   l_loc_tbl_name            VARCHAR2(30);
   l_loc_seq_num             NUMBER;
   l_geo_type                VARCHAR2(30);
   l_geo_element_column      VARCHAR2(30);
   l_rowid                   VARCHAR2(50);
   l_pkgname                 VARCHAR2(50);
   l_status                  VARCHAR2(30);
   l_count                   NUMBER;
   l_error_code              VARCHAR2(30);
   l_token_name              VARCHAR2(30);
   l_token_value             VARCHAR2(30);
   i                         BINARY_INTEGER;

   CURSOR c_struct_map(c_map_id number) IS
   SELECT country_code, loc_tbl_name
   FROM   hz_geo_struct_map
   WHERE  map_id = c_map_id;

   CURSOR c_struct_map_dtl(c_geography_type varchar2) IS
   SELECT rowid, loc_seq_num,geo_element_col
   FROM   hz_geo_struct_map_dtl
   WHERE  map_id = p_map_id
   AND    geography_type = c_geography_type;

BEGIN

   -- Standard start of API savepoint
   SAVEPOINT update_geo_struct_map_dtls;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_country      := NULL;
   l_loc_tbl_name := NULL;
   OPEN  c_struct_map(p_map_id);
   FETCH c_struct_map INTO l_country, l_loc_tbl_name;
   CLOSE c_struct_map;

   IF (l_country IS NULL OR l_loc_tbl_name IS NULL) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_INVALID_MAP_ID');
      -- Please pass a valid map ID that is not NULL.
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF p_geo_struct_map_dtl_tbl.COUNT > 0 THEN
      i := p_geo_struct_map_dtl_tbl.FIRST;
      LOOP

        l_loc_seq_num := NULL;
        l_geo_element_column := NULL;
        OPEN  c_struct_map_dtl(p_geo_struct_map_dtl_tbl(i).geo_type);
        FETCH c_struct_map_dtl INTO l_rowid, l_loc_seq_num, l_geo_element_column;
        CLOSE c_struct_map_dtl;

        IF (l_loc_seq_num IS NULL OR l_geo_element_column IS NULL) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GEOTYPE_INVALID');
           -- A mapping does not exist for this geography type. Please map the geography type.
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_geo_struct_map_dtl_tbl(i).loc_comp IS NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
         l_error_code := 'HZ_GEO_LOC_COMP_MAND';
         EXIT;
        ELSE
          check_valid_loc_comp(p_geo_struct_map_dtl_tbl(i).loc_comp, l_loc_tbl_name,
                                 x_return_status, l_error_code);
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            l_token_name := 'LOCCOMP';
            l_token_value := p_geo_struct_map_dtl_tbl(i).loc_comp;
            EXIT;
          END IF;
        END IF;

        hz_geo_struct_map_dtl_pvt.Update_Row (
                         x_rowid                 => l_rowid,
                         x_map_id                => p_map_id,
                         x_loc_seq_num           => l_loc_seq_num,
                         x_loc_component         => p_geo_struct_map_dtl_tbl(i).loc_comp,
                         x_geography_type        => p_geo_struct_map_dtl_tbl(i).geo_type,
                         x_geo_element_col       => l_geo_element_column);

        EXIT WHEN i = p_geo_struct_map_dtl_tbl.LAST;
        i := p_geo_struct_map_dtl_tbl.NEXT(i);
      END LOOP;

      --  if validation failed at any point, then raise an exception to stop processing
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      SELECT count(*)
      INTO   l_count
      FROM   Hz_address_usages usg, Hz_address_usage_dtls dtl
      WHERE  usg.map_id = p_map_id
      AND    usg.status_flag = 'A'
      AND    dtl.usage_id = usg.usage_id;

      -- If count is 0, that means there is no active usage details for this map_id
      IF l_count > 0 THEN
        --dbms_output.put_line('Before Gen pkg Create usage : map id :'|| p_address_usages_rec.map_id);
        BEGIN
           hz_gnr_gen_pkg.genpkg(p_map_id,l_pkgname,l_status);
           IF l_status = FND_API.G_RET_STS_ERROR THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_PKG_ERR');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        EXCEPTION WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_GNR_INTERNAL_ERROR');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        END;
        --dbms_output.put_line('After Gen pkg Create usage : map id :'|| p_address_usages_rec.map_id);
      END IF;

   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data);

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_geo_struct_map_dtls;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_geo_struct_map_dtls;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
   WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO update_geo_struct_map_dtls;
        x_return_status := FND_API.G_RET_STS_ERROR;
        HZ_UTILITY_V2PUB.find_index_name(p_index_name);

        IF p_index_name = 'HZ_GEO_STRUCT_MAP_DTL_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_LOC_SEQ_NUM');
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_GEO_STRUCT_MAP_DTL_U2' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_LOC_COMP');
          FND_MSG_PUB.ADD;

        ELSIF p_index_name = 'HZ_GEO_STRUCT_MAP_DTL_U3' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_GEO_TYPE');
          FND_MSG_PUB.ADD;
        END IF;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);
   WHEN OTHERS THEN
        ROLLBACK TO update_geo_struct_map_dtls;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

END update_geo_struct_map_dtls;

END;

/
