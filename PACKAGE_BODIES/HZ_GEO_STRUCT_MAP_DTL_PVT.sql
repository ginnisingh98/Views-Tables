--------------------------------------------------------
--  DDL for Package Body HZ_GEO_STRUCT_MAP_DTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_STRUCT_MAP_DTL_PVT" AS
/*$Header: ARHGEMDB.pls 120.2 2005/09/01 20:02:05 baianand noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_map_id                                IN            NUMBER,
    x_loc_seq_num                           IN            NUMBER,
    x_loc_component                         IN            VARCHAR2,
    x_geography_type                        IN            VARCHAR2,
    x_geo_element_col                       IN            VARCHAR2
) IS


BEGIN

      INSERT INTO HZ_GEO_STRUCT_MAP_DTL (
        map_id,
        loc_seq_num,
        loc_component,
        geography_type,
        geo_element_col,
        last_updated_by,
        creation_date,
        created_by,
        last_update_date,
        last_update_login
      )
      VALUES (
        DECODE(x_map_id,
               FND_API.G_MISS_NUM, NULL,
               x_map_id),
        DECODE(x_loc_seq_num,
               FND_API.G_MISS_NUM, NULL,
               x_loc_seq_num),
        DECODE(x_loc_component,
               FND_API.G_MISS_CHAR, NULL,
               x_loc_component),
        DECODE(x_geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
        DECODE(x_geo_element_col,
               FND_API.G_MISS_CHAR, NULL,
               x_geo_element_col),
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_update_login
      ) RETURNING
        rowid
      INTO
        x_rowid;

END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_map_id                                IN     NUMBER,
    x_loc_seq_num                           IN     NUMBER,
    x_loc_component                         IN     VARCHAR2,
    x_geography_type                        IN     VARCHAR2,
    x_geo_element_col                       IN     VARCHAR2
) IS
BEGIN

    UPDATE HZ_GEO_STRUCT_MAP_DTL
    SET
      map_id =
        DECODE(x_map_id,
               NULL, map_id,
               FND_API.G_MISS_NUM, NULL,
               x_map_id),
      loc_seq_num =
        DECODE(x_loc_seq_num,
               NULL, loc_seq_num,
               FND_API.G_MISS_NUM, NULL,
               x_loc_seq_num),
      loc_component =
        DECODE(x_loc_component,
               NULL, loc_component,
               FND_API.G_MISS_CHAR, NULL,
               x_loc_component),
      geography_type =
        DECODE(x_geography_type,
               NULL, geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
      geo_element_col =
        DECODE(x_geo_element_col,
               NULL, geo_element_col,
               FND_API.G_MISS_CHAR, NULL,
               x_geo_element_col),
      last_updated_by = hz_utility_v2pub.last_updated_by,
      creation_date = creation_date,
      created_by = created_by,
      last_update_date = hz_utility_v2pub.last_update_date,
      last_update_login = hz_utility_v2pub.last_update_login
    WHERE rowid = x_rowid;
    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_map_id                                IN            NUMBER,
    x_loc_seq_num                           IN            NUMBER,
    x_loc_component                         IN            VARCHAR2,
    x_geography_type                        IN            VARCHAR2,
    x_geo_element_col                       IN            VARCHAR2
) IS

    CURSOR c IS
      SELECT * FROM hz_geo_struct_map_dtl
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;
    Recinfo c%ROWTYPE;

BEGIN

    OPEN c;
    FETCH c INTO Recinfo;
    IF ( c%NOTFOUND ) THEN
      CLOSE c;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF (
        ( ( Recinfo.map_id = x_map_id )
        OR ( ( Recinfo.map_id IS NULL )
          AND (  x_map_id IS NULL ) ) )
    AND ( ( Recinfo.loc_seq_num = x_loc_seq_num)
        OR ( ( Recinfo.loc_seq_num IS NULL )
          AND (  x_loc_seq_num IS NULL ) ) )
    AND ( ( Recinfo.loc_component = x_loc_component )
        OR ( ( Recinfo.loc_component IS NULL )
          AND (  x_loc_component IS NULL ) ) )
    AND ( ( Recinfo.geography_type = x_geography_type )
        OR ( ( Recinfo.geography_type IS NULL )
          AND (  x_geography_type IS NULL ) ) )
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  return;

END Lock_Row;

PROCEDURE Select_Row (
    x_map_id                                IN OUT NOCOPY NUMBER,
    x_loc_seq_num                           OUT    NOCOPY NUMBER,
    x_loc_component                         OUT    NOCOPY VARCHAR2,
    x_geography_type                        OUT    NOCOPY VARCHAR2,
    x_geo_element_col                       OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(map_id, FND_API.G_MISS_NUM),
      NVL(loc_seq_num, FND_API.G_MISS_NUM),
      NVL(loc_component, FND_API.G_MISS_CHAR),
      NVL(geography_type, FND_API.G_MISS_CHAR)
    INTO
      x_map_id,
      x_loc_seq_num,
      x_loc_component,
      x_geography_type
    FROM HZ_GEO_STRUCT_MAP_DTL
    WHERE map_id =  x_map_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'geo structure map dtl');
      FND_MESSAGE.SET_TOKEN('VALUE', x_map_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_map_id                        IN     NUMBER
) IS
BEGIN

  DELETE FROM hz_geo_struct_map_dtl
  WHERE map_id = x_map_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;

-- This API can use to delete only one record in mapping detail table.
PROCEDURE Delete_Row (
    x_map_id                        IN     NUMBER,
    x_geography_type                IN     VARCHAR2
) IS
BEGIN

  DELETE FROM hz_geo_struct_map_dtl
  WHERE map_id = x_map_id
  AND   geography_type = x_geography_type;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;

END HZ_GEO_STRUCT_MAP_DTL_PVT;

/
