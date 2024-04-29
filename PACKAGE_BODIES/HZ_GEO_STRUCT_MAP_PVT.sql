--------------------------------------------------------
--  DDL for Package Body HZ_GEO_STRUCT_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEO_STRUCT_MAP_PVT" AS
/*$Header: ARHGEMMB.pls 115.1 2003/02/11 19:46:49 sachandr noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_map_id                                IN            NUMBER,
    x_country_code                          IN            VARCHAR2,
    x_loc_tbl_name                          IN            VARCHAR2,
    x_address_style                         IN            VARCHAR2
) IS


BEGIN

      INSERT INTO HZ_GEO_STRUCT_MAP (
        map_id,
        country_code,
        loc_tbl_name,
        address_style,
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
        DECODE(x_country_code,
               FND_API.G_MISS_CHAR, NULL,
               x_country_code),
        DECODE(x_loc_tbl_name,
               FND_API.G_MISS_CHAR, NULL,
               x_loc_tbl_name),
        DECODE(x_address_style,
               FND_API.G_MISS_CHAR, NULL,
               x_address_style),
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

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_map_id                                IN            NUMBER,
    x_country_code                          IN            VARCHAR2,
    x_loc_tbl_name                          IN            VARCHAR2,
    x_address_style                         IN            VARCHAR2
) IS

    CURSOR c IS
      SELECT * FROM hz_geo_struct_map
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
    AND ( ( Recinfo.country_code = x_country_code)
        OR ( ( Recinfo.country_code IS NULL )
          AND (  x_country_code IS NULL ) ) )
    AND ( ( Recinfo.loc_tbl_name = x_loc_tbl_name )
        OR ( ( Recinfo.loc_tbl_name IS NULL )
          AND (  x_loc_tbl_name IS NULL ) ) )
    AND ( ( Recinfo.address_style = x_address_style )
        OR ( ( Recinfo.address_style IS NULL )
          AND (  x_address_style IS NULL ) ) )
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
    x_country_code                          OUT    NOCOPY VARCHAR2,
    x_loc_tbl_name                          OUT    NOCOPY VARCHAR2,
    x_address_style                         OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(map_id, FND_API.G_MISS_NUM),
      NVL(country_code, FND_API.G_MISS_CHAR),
      NVL(loc_tbl_name, FND_API.G_MISS_CHAR),
      NVL(address_style, FND_API.G_MISS_CHAR)
    INTO
      x_map_id,
      x_country_code,
      x_loc_tbl_name,
      x_address_style
    FROM HZ_GEO_STRUCT_MAP
    WHERE map_id =  x_map_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'geo structure map');
      FND_MESSAGE.SET_TOKEN('VALUE', x_map_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_map_id                        IN     NUMBER
) IS
BEGIN

  DELETE FROM hz_geo_struct_map
  WHERE map_id = x_map_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;

END HZ_GEO_STRUCT_MAP_PVT;

/
