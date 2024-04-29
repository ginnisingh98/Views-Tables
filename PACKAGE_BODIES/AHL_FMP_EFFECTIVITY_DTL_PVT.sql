--------------------------------------------------------
--  DDL for Package Body AHL_FMP_EFFECTIVITY_DTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_EFFECTIVITY_DTL_PVT" AS
/* $Header: AHLVMEDB.pls 120.0.12010000.4 2009/09/22 21:27:26 sikumar ship $ */

G_PKG_NAME      VARCHAR2(30) := 'AHL_FMP_EFFECTIVITY_DTL_PVT';
G_API_NAME      VARCHAR2(30) := 'PROCESS_EFFECTIVITY_DETAIL';
G_DEBUG         VARCHAR2(1)  :=AHL_DEBUG_PUB.is_log_enabled;
G_APPLN_USAGE   VARCHAR2(30) :=LTRIM(RTRIM(FND_PROFILE.value('AHL_APPLN_USAGE')));


-- Function to get the Record Identifier for Error Messages
FUNCTION get_record_identifier
(
  p_effectivity_detail_rec       IN    effectivity_detail_rec_type
) RETURN VARCHAR2
IS

l_record_identifier       VARCHAR2(2000) := '';

BEGIN

  IF ( p_effectivity_detail_rec.serial_number_from IS NOT NULL AND
       p_effectivity_detail_rec.serial_number_from <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_effectivity_detail_rec.serial_number_from;
  END IF;

  l_record_identifier := l_record_identifier || ' - ';

  IF ( p_effectivity_detail_rec.serial_number_to IS NOT NULL AND
       p_effectivity_detail_rec.serial_number_to <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_effectivity_detail_rec.serial_number_to;
  END IF;

  l_record_identifier := l_record_identifier || ' - ';

  IF ( p_effectivity_detail_rec.manufacturer IS NOT NULL AND
       p_effectivity_detail_rec.manufacturer <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_effectivity_detail_rec.manufacturer;
  END IF;

  l_record_identifier := l_record_identifier || ' - ';

  IF ( p_effectivity_detail_rec.manufacture_date_from IS NOT NULL AND
       p_effectivity_detail_rec.manufacture_date_from <> FND_API.G_MISS_DATE ) THEN
    l_record_identifier := l_record_identifier || TO_CHAR( p_effectivity_detail_rec.manufacture_date_from, 'DD-MON-YYYY' );
  END IF;

  l_record_identifier := l_record_identifier || ' - ';

  IF ( p_effectivity_detail_rec.manufacture_date_to IS NOT NULL AND
       p_effectivity_detail_rec.manufacture_date_to <> FND_API.G_MISS_DATE ) THEN
    l_record_identifier := l_record_identifier || TO_CHAR( p_effectivity_detail_rec.manufacture_date_to, 'DD-MON-YYYY' );
  END IF;

  l_record_identifier := l_record_identifier || ' - ';

  IF ( p_effectivity_detail_rec.country IS NOT NULL AND
       p_effectivity_detail_rec.country <> FND_API.G_MISS_CHAR ) THEN
    l_record_identifier := l_record_identifier || p_effectivity_detail_rec.country;
  END IF;

  RETURN l_record_identifier;

END get_record_identifier;

-- Function to get the Record Identifier for Error Messages
FUNCTION get_ext_record_identifier
(
  p_effty_ext_detail_rec       IN    effty_ext_detail_rec_type
) RETURN VARCHAR2
IS

l_record_identifier       VARCHAR2(2000) := '';

BEGIN
   IF ( p_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'OWNER' )THEN
      IF ( p_effty_ext_detail_rec.owner IS NOT NULL AND
           p_effty_ext_detail_rec.owner <> FND_API.G_MISS_CHAR ) THEN
        l_record_identifier := l_record_identifier || p_effty_ext_detail_rec.owner;
      END IF;
   ELSIF( p_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'LOCATION' ) THEN
      IF ( p_effty_ext_detail_rec.location IS NOT NULL AND
           p_effty_ext_detail_rec.location <> FND_API.G_MISS_CHAR ) THEN
        l_record_identifier := l_record_identifier || p_effty_ext_detail_rec.location;
      END IF;
   ELSIF( p_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'CSIEXTATTR' ) THEN
      IF ( p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE IS NOT NULL AND
           p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE <> FND_API.G_MISS_CHAR ) THEN
        l_record_identifier := l_record_identifier || p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE;
      END IF;
      l_record_identifier := l_record_identifier || ' - ';
      /*IF ( p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME IS NOT NULL AND
           p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME <> FND_API.G_MISS_CHAR ) THEN
        l_record_identifier := l_record_identifier || p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME;
      END IF;
      l_record_identifier := l_record_identifier || ' - ';*/
      IF ( p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE IS NOT NULL AND
           p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE <> FND_API.G_MISS_CHAR ) THEN
        l_record_identifier := l_record_identifier || p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE;
      END IF;
   ELSE
     IF ( p_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE IS NOT NULL AND
           p_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE <> FND_API.G_MISS_CHAR ) THEN
        l_record_identifier := l_record_identifier || p_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE;
      END IF;
   END IF;

  RETURN l_record_identifier;

END get_ext_record_identifier;

-- Procedure to validate the Inputs of the API
PROCEDURE validate_api_inputs
(
  p_effectivity_detail_tbl         IN   effectivity_detail_tbl_type,
  p_effty_ext_detail_tbl         IN   effty_ext_detail_tbl_type,
  p_mr_header_id                   IN   NUMBER,
  p_mr_effectivity_id              IN   NUMBER,
  x_return_status                  OUT NOCOPY VARCHAR2
)
IS
l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);
l_appln_code                VARCHAR2(30);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check Profile value

  IF G_APPLN_USAGE IS NULL THEN
     FND_MESSAGE.SET_NAME('AHL','AHL_COM_APP_PRFL_UNDEF');
     FND_MSG_PUB.ADD;
     RETURN;
  END IF;


  IF ( G_APPLN_USAGE = 'PM' ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_PM_MED_PM_INSTALL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if a valid value is passed in p_mr_header_id

  IF ( p_mr_header_id = FND_API.G_MISS_NUM OR
       p_mr_header_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_MR_HEADER_ID_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the Maintenance Requirement is in Updatable status
  AHL_FMP_COMMON_PVT.validate_mr_status
  (
    x_return_status        => l_return_status,
    x_msg_data             => l_msg_data,
    p_mr_header_id         => p_mr_header_id
  );

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    FND_MESSAGE.set_name( 'AHL', l_msg_data );
    FND_MSG_PUB.add;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  -- Check if a valid value is passed in p_mr_effectivity_id
  IF ( p_mr_effectivity_id = FND_API.G_MISS_NUM OR
       p_mr_effectivity_id IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_MRE_ID_NULL' );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Check if the Maintenance Requirement Effectivity exists
  AHL_FMP_COMMON_PVT.validate_mr_effectivity
  (
    x_return_status        => l_return_status,
    x_msg_data             => l_msg_data,
    p_mr_effectivity_id    => p_mr_effectivity_id
  );

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    FND_MESSAGE.set_name( 'AHL', l_msg_data );
    FND_MSG_PUB.add;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  -- Check if atleast one record is passed in p_effectivity_detail_tbl
  IF ( p_effectivity_detail_tbl.count < 1 AND p_effty_ext_detail_tbl.count < 1 ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MESSAGE.set_token( 'PROCEDURE', G_PKG_NAME || '.' || G_API_NAME );
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Validate DML Operation
  FOR i IN 1..p_effectivity_detail_tbl.count LOOP
    IF ( p_effectivity_detail_tbl(i).dml_operation <> 'D' AND
         p_effectivity_detail_tbl(i).dml_operation <> 'U' AND
         p_effectivity_detail_tbl(i).dml_operation <> 'C' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_DML_INVALID' );
      FND_MESSAGE.set_token( 'FIELD', p_effectivity_detail_tbl(i).dml_operation );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_detail_tbl(i) ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END LOOP;

    -- Validate DML Operation for extended details
  FOR i IN 1..p_effty_ext_detail_tbl.count LOOP
    IF ( p_effty_ext_detail_tbl(i).dml_operation <> 'D' AND
         p_effty_ext_detail_tbl(i).dml_operation <> 'U' AND
         p_effty_ext_detail_tbl(i).dml_operation <> 'C' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_DML_INVALID' );
      FND_MESSAGE.set_token( 'FIELD', p_effty_ext_detail_tbl(i).dml_operation );
      FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_effty_ext_detail_tbl(i) ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
    IF ( p_effty_ext_detail_tbl(i).EFFECT_EXT_DTL_REC_TYPE <> 'OWNER' AND
         p_effty_ext_detail_tbl(i).EFFECT_EXT_DTL_REC_TYPE <> 'LOCATION' AND
         p_effty_ext_detail_tbl(i).EFFECT_EXT_DTL_REC_TYPE <> 'CSIEXTATTR' ) THEN
      FND_MESSAGE.set_name( 'AHL', 'AHL_COM_DML_INVALID' );
      FND_MESSAGE.set_token( 'FIELD', p_effty_ext_detail_tbl(i).EFFECT_EXT_DTL_REC_TYPE );
      FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_effty_ext_detail_tbl(i) ) );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END LOOP;

END validate_api_inputs;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_lov_attribute_ids
(
  p_x_effectivity_detail_rec       IN OUT NOCOPY  effectivity_detail_rec_type
)
IS

BEGIN

  IF ( p_x_effectivity_detail_rec.manufacturer IS NULL ) THEN
    p_x_effectivity_detail_rec.manufacturer_id := NULL;
  ELSIF ( p_x_effectivity_detail_rec.manufacturer = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.manufacturer_id := FND_API.G_MISS_NUM;
  END IF;

  IF ( p_x_effectivity_detail_rec.country IS NULL ) THEN
    p_x_effectivity_detail_rec.country_code := NULL;
  ELSIF ( p_x_effectivity_detail_rec.country = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.country_code := FND_API.G_MISS_CHAR;
  END IF;

END clear_lov_attribute_ids;

-- Procedure to Default NULL / G_MISS Values for LOV attributes
PROCEDURE clear_ext_lov_attribute_ids
(
  p_x_effty_ext_detail_rec       IN OUT NOCOPY  effty_ext_detail_rec_type
)
IS

BEGIN

   IF ( p_x_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'OWNER' )THEN
      IF ( p_x_effty_ext_detail_rec.owner IS NULL ) THEN
        p_x_effty_ext_detail_rec.owner_id := NULL;
      ELSIF ( p_x_effty_ext_detail_rec.owner = FND_API.G_MISS_CHAR ) THEN
        p_x_effty_ext_detail_rec.owner_id := FND_API.G_MISS_NUM;
      END IF;
   ELSIF( p_x_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'LOCATION' ) THEN
      IF ( p_x_effty_ext_detail_rec.location IS NULL ) THEN
        p_x_effty_ext_detail_rec.location_type_code := NULL;
      ELSIF ( p_x_effty_ext_detail_rec.location = FND_API.G_MISS_CHAR ) THEN
        p_x_effty_ext_detail_rec.location_type_code := FND_API.G_MISS_CHAR;
      END IF;
   ELSIF( p_x_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'CSIEXTATTR' ) THEN
      IF ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE IS NULL )THEN
        p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME := NULL;
      ELSIF (p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE = FND_API.G_MISS_CHAR)THEN
        p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME := FND_API.G_MISS_CHAR;
      END IF;
   END IF;


END clear_ext_lov_attribute_ids;

-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_values_to_ids
(
  p_x_effectivity_detail_rec   IN OUT NOCOPY  effectivity_detail_rec_type,
  p_mr_effectivity_id          IN             NUMBER,
  x_return_status              OUT NOCOPY     VARCHAR2
)
IS

l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);
l_inventory_item_id       NUMBER;
l_item_number             VARCHAR2(40);
l_relationship_id         NUMBER;
l_position_ref_meaning    VARCHAR2(80);

CURSOR get_item_effectivity ( c_mr_effectivity_id NUMBER )
IS
SELECT  DECODE( relationship_id, null,
                                 inventory_item_id,
                                 position_inventory_item_id ),
        DECODE( relationship_id, null,
                                 item_number,
                                 position_item_number ),
        relationship_id,
        position_ref_meaning
FROM    AHL_MR_EFFECTIVITIES_V
WHERE   mr_effectivity_id = c_mr_effectivity_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate Manufacturer
  IF ( ( p_x_effectivity_detail_rec.manufacturer_id IS NOT NULL AND
         p_x_effectivity_detail_rec.manufacturer_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_effectivity_detail_rec.manufacturer IS NOT NULL AND
         p_x_effectivity_detail_rec.manufacturer <> FND_API.G_MISS_CHAR ) ) THEN

    OPEN get_item_effectivity( p_mr_effectivity_id );

    FETCH get_item_effectivity INTO
      l_inventory_item_id,
      l_item_number,
      l_relationship_id,
      l_position_ref_meaning;

    CLOSE get_item_effectivity;

    AHL_FMP_COMMON_PVT.validate_manufacturer
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_inventory_item_id    => l_inventory_item_id,
      p_relationship_id      => l_relationship_id,
      p_manufacturer_name    => p_x_effectivity_detail_rec.manufacturer,
      p_x_manufacturer_id    => p_x_effectivity_detail_rec.manufacturer_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( l_msg_data = 'AHL_FMP_INVALID_MF' OR
           l_msg_data = 'AHL_FMP_TOO_MANY_MFS' ) THEN
        IF ( p_x_effectivity_detail_rec.manufacturer IS NULL OR
             p_x_effectivity_detail_rec.manufacturer = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_effectivity_detail_rec.manufacturer_id ));
        ELSE
          FND_MESSAGE.set_token( 'FIELD', p_x_effectivity_detail_rec.manufacturer );
        END IF;
      ELSE
        IF ( p_x_effectivity_detail_rec.manufacturer IS NULL OR
             p_x_effectivity_detail_rec.manufacturer = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD1', TO_CHAR( p_x_effectivity_detail_rec.manufacturer_id ));
        ELSE
          FND_MESSAGE.set_token( 'FIELD1', p_x_effectivity_detail_rec.manufacturer );
        END IF;

        IF ( l_position_ref_meaning IS NOT NULL ) THEN
          FND_MESSAGE.set_token( 'FIELD2', l_position_ref_meaning );
        ELSE
          FND_MESSAGE.set_token( 'FIELD2', l_item_number );
        END IF;
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_detail_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

  -- Convert / Validate Country
  IF ( ( p_x_effectivity_detail_rec.country_code IS NOT NULL AND
         p_x_effectivity_detail_rec.country_code <> FND_API.G_MISS_CHAR )
       OR
       ( p_x_effectivity_detail_rec.country IS NOT NULL AND
         p_x_effectivity_detail_rec.country <> FND_API.G_MISS_CHAR ) )
  THEN

    AHL_FMP_COMMON_PVT.validate_country
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_country_name         => p_x_effectivity_detail_rec.country,
      p_x_country_code       => p_x_effectivity_detail_rec.country_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      IF ( p_x_effectivity_detail_rec.country IS NULL OR
           p_x_effectivity_detail_rec.country = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_effectivity_detail_rec.country_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_effectivity_detail_rec.country );
      END IF;
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_detail_rec ) );
      FND_MSG_PUB.add;
    END IF;

  END IF;

END convert_values_to_ids;

-- Procedure to perform Value to ID conversion for appropriate attributes
PROCEDURE convert_ext_values_to_ids
(
  p_x_effty_ext_detail_rec   IN OUT NOCOPY  effty_ext_detail_rec_type,
  p_mr_effectivity_id          IN             NUMBER,
  x_return_status              OUT NOCOPY     VARCHAR2
)
IS
l_return_status           VARCHAR2(1);
l_msg_data                VARCHAR2(2000);
l_inventory_item_id       NUMBER;
l_item_number             VARCHAR2(40);
l_relationship_id         NUMBER;
l_position_ref_meaning    VARCHAR2(80);

CURSOR get_item_effectivity ( c_mr_effectivity_id NUMBER )
IS
SELECT  DECODE( relationship_id, null,
                                 inventory_item_id,
                                 position_inventory_item_id ),
        DECODE( relationship_id, null,
                                 item_number,
                                 position_item_number ),
        relationship_id,
        position_ref_meaning
FROM    AHL_MR_EFFECTIVITIES_V
WHERE   mr_effectivity_id = c_mr_effectivity_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Convert / Validate Manufacturer
  IF ( p_x_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'OWNER' )THEN
   IF ( ( p_x_effty_ext_detail_rec.owner_id IS NOT NULL AND
         p_x_effty_ext_detail_rec.owner_id <> FND_API.G_MISS_NUM ) OR
       ( p_x_effty_ext_detail_rec.owner IS NOT NULL AND
         p_x_effty_ext_detail_rec.owner <> FND_API.G_MISS_CHAR ) ) THEN

    OPEN get_item_effectivity( p_mr_effectivity_id );

    FETCH get_item_effectivity INTO
      l_inventory_item_id,
      l_item_number,
      l_relationship_id,
      l_position_ref_meaning;

    CLOSE get_item_effectivity;

    AHL_FMP_COMMON_PVT.validate_owner
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_owner                => p_x_effty_ext_detail_rec.owner,
      p_x_owner_id           => p_x_effty_ext_detail_rec.owner_id
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );

      IF ( l_msg_data = 'AHL_FMP_INVALID_OWNER' OR
           l_msg_data = 'AHL_FMP_INV_TOO_MANY_OWNERS' ) THEN
        IF ( p_x_effty_ext_detail_rec.owner IS NULL OR
             p_x_effty_ext_detail_rec.owner = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_effty_ext_detail_rec.owner_id ));
        ELSE
          FND_MESSAGE.set_token( 'FIELD', p_x_effty_ext_detail_rec.owner );
        END IF;
      ELSE
        IF ( p_x_effty_ext_detail_rec.owner IS NULL OR
             p_x_effty_ext_detail_rec.owner = FND_API.G_MISS_CHAR ) THEN
          FND_MESSAGE.set_token( 'FIELD', TO_CHAR( p_x_effty_ext_detail_rec.owner_id ));
        ELSE
          FND_MESSAGE.set_token( 'FIELD', p_x_effty_ext_detail_rec.owner );
        END IF;
      END IF;

      FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_x_effty_ext_detail_rec ) );
      FND_MSG_PUB.add;
    END IF;
   END IF;
  END IF;

  -- Convert / Validate Location
  IF( p_x_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'LOCATION' ) THEN
   IF ( ( p_x_effty_ext_detail_rec.location_type_code IS NOT NULL AND
         p_x_effty_ext_detail_rec.location_type_code <> FND_API.G_MISS_CHAR )
       OR
       ( p_x_effty_ext_detail_rec.location IS NOT NULL AND
         p_x_effty_ext_detail_rec.location <> FND_API.G_MISS_CHAR ) )
   THEN

    AHL_FMP_COMMON_PVT.validate_location
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_location             => p_x_effty_ext_detail_rec.location,
      p_x_location_type_code       => p_x_effty_ext_detail_rec.location_type_code
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      IF ( p_x_effty_ext_detail_rec.location IS NULL OR
           p_x_effty_ext_detail_rec.location = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_effty_ext_detail_rec.location_type_code );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_effty_ext_detail_rec.location );
      END IF;
      FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_x_effty_ext_detail_rec ) );
      FND_MSG_PUB.add;
    END IF;
   END IF;
  END IF;

  -- Convert / Validate Location
  IF( p_x_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'CSIEXTATTR' ) THEN
   IF ( ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE IS NOT NULL AND
         p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE <> FND_API.G_MISS_CHAR )
       OR
       ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME IS NOT NULL AND
         p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME <> FND_API.G_MISS_CHAR ) )
   THEN

    AHL_FMP_COMMON_PVT.validate_csi_ext_attribute
    (
      x_return_status        => l_return_status,
      x_msg_data             => l_msg_data,
      p_csi_attribute_name   => p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME,
      p_x_csi_attribute_code => p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      IF ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME IS NULL OR
           p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME = FND_API.G_MISS_CHAR ) THEN
        FND_MESSAGE.set_token( 'FIELD', p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE );
      ELSE
        FND_MESSAGE.set_token( 'FIELD', p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME );
      END IF;
      FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_x_effty_ext_detail_rec ) );
      FND_MSG_PUB.add;
    END IF;
   END IF;
  END IF;

END convert_ext_values_to_ids;

-- Procedure to add Default values for effectivity_detail attributes
PROCEDURE default_attributes
(
  p_x_effectivity_detail_rec       IN OUT NOCOPY   effectivity_detail_rec_type
)
IS

BEGIN

  p_x_effectivity_detail_rec.last_update_date := SYSDATE;
  p_x_effectivity_detail_rec.last_updated_by := FND_GLOBAL.user_id;
  p_x_effectivity_detail_rec.last_update_login := FND_GLOBAL.login_id;

  IF ( p_x_effectivity_detail_rec.dml_operation = 'C' ) THEN
    p_x_effectivity_detail_rec.object_version_number := 1;
    p_x_effectivity_detail_rec.creation_date := SYSDATE;
    p_x_effectivity_detail_rec.created_by := FND_GLOBAL.user_id;
  END IF;

END default_attributes;

-- Procedure to add Default values for effectivity_detail attributes
PROCEDURE default_ext_attributes
(
  p_x_effty_ext_detail_rec       IN OUT NOCOPY   effty_ext_detail_rec_type
)
IS

BEGIN

  p_x_effty_ext_detail_rec.last_update_date := SYSDATE;
  p_x_effty_ext_detail_rec.last_updated_by := FND_GLOBAL.user_id;
  p_x_effty_ext_detail_rec.last_update_login := FND_GLOBAL.login_id;

  IF ( p_x_effty_ext_detail_rec.dml_operation = 'C' ) THEN
    p_x_effty_ext_detail_rec.object_version_number := 1;
    p_x_effty_ext_detail_rec.creation_date := SYSDATE;
    p_x_effty_ext_detail_rec.created_by := FND_GLOBAL.user_id;
  END IF;

END default_ext_attributes;

-- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_missing_attributes
(
  p_x_effectivity_detail_rec       IN OUT NOCOPY   effectivity_detail_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_effectivity_detail_rec.serial_number_from = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.serial_number_from := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.serial_number_to = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.serial_number_to := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.manufacturer_id = FND_API.G_MISS_NUM ) THEN
    p_x_effectivity_detail_rec.manufacturer_id := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.manufacturer = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.manufacturer := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.manufacture_date_from = FND_API.G_MISS_DATE ) THEN
    p_x_effectivity_detail_rec.manufacture_date_from := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.manufacture_date_to = FND_API.G_MISS_DATE ) THEN
    p_x_effectivity_detail_rec.manufacture_date_to := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.country_code = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.country_code := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.country = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.country := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute_category := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute1 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute2 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute3 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute4 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute5 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute6 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute7 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute8 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute9 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute10 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute11 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute12 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute13 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute14 := null;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute15 := null;
  END IF;

END default_missing_attributes;

-- Procedure to add Default values for missing attributes (CREATE)
PROCEDURE default_ext_missing_attributes
(
  p_x_effty_ext_detail_rec       IN OUT NOCOPY   effty_ext_detail_rec_type
)
IS

BEGIN

  -- Convert G_MISS values to NULL
  IF ( p_x_effty_ext_detail_rec.owner = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.owner := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.owner_id = FND_API.G_MISS_NUM ) THEN
    p_x_effty_ext_detail_rec.owner_id := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.LOCATION = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.LOCATION := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.LOCATION_TYPE_CODE = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.LOCATION_TYPE_CODE := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute_category := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute1 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute2 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute3 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute4 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute5 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute6 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute7 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute8 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute9 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute10 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute11 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute12 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute13 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute14 := null;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute15 := null;
  END IF;

END default_ext_missing_attributes;

-- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_unchanged_attributes
(
  p_x_effectivity_detail_rec       IN OUT NOCOPY   effectivity_detail_rec_type
)
IS

l_old_effectivity_detail_rec       effectivity_detail_rec_type;

CURSOR get_old_rec ( c_mr_effectivity_detail_id NUMBER )
IS
SELECT  exclude_flag,
        serial_number_from,
        serial_number_to,
        manufacturer_id,
        manufacturer,
        manufacture_date_from,
        manufacture_date_to,
        country_code,
        country,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15
FROM    AHL_MR_EFFECTIVITY_DTLS_V
WHERE   mr_effectivity_detail_id = c_mr_effectivity_detail_id;

BEGIN

  -- Get the old record from AHL_MR_EFFECTIVITY_DTLS.
  OPEN  get_old_rec( p_x_effectivity_detail_rec.mr_effectivity_detail_id );

  FETCH get_old_rec INTO
        l_old_effectivity_detail_rec.exclude_flag,
        l_old_effectivity_detail_rec.serial_number_from,
        l_old_effectivity_detail_rec.serial_number_to,
        l_old_effectivity_detail_rec.manufacturer_id,
        l_old_effectivity_detail_rec.manufacturer,
        l_old_effectivity_detail_rec.manufacture_date_from,
        l_old_effectivity_detail_rec.manufacture_date_to,
        l_old_effectivity_detail_rec.country_code,
        l_old_effectivity_detail_rec.country,
        l_old_effectivity_detail_rec.attribute_category,
        l_old_effectivity_detail_rec.attribute1,
        l_old_effectivity_detail_rec.attribute2,
        l_old_effectivity_detail_rec.attribute3,
        l_old_effectivity_detail_rec.attribute4,
        l_old_effectivity_detail_rec.attribute5,
        l_old_effectivity_detail_rec.attribute6,
        l_old_effectivity_detail_rec.attribute7,
        l_old_effectivity_detail_rec.attribute8,
        l_old_effectivity_detail_rec.attribute9,
        l_old_effectivity_detail_rec.attribute10,
        l_old_effectivity_detail_rec.attribute11,
        l_old_effectivity_detail_rec.attribute12,
        l_old_effectivity_detail_rec.attribute13,
        l_old_effectivity_detail_rec.attribute14,
        l_old_effectivity_detail_rec.attribute15;

  IF get_old_rec%NOTFOUND THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_INVALID_EFF_DTL_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_detail_rec ) );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_effectivity_detail_rec.exclude_flag IS NULL ) THEN
    p_x_effectivity_detail_rec.exclude_flag := l_old_effectivity_detail_rec.exclude_flag;
  END IF;

  IF ( p_x_effectivity_detail_rec.serial_number_from = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.serial_number_from := null;
  ELSIF ( p_x_effectivity_detail_rec.serial_number_from IS NULL ) THEN
    p_x_effectivity_detail_rec.serial_number_from := l_old_effectivity_detail_rec.serial_number_from;
  END IF;

  IF ( p_x_effectivity_detail_rec.serial_number_to = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.serial_number_to := null;
  ELSIF ( p_x_effectivity_detail_rec.serial_number_to IS NULL ) THEN
    p_x_effectivity_detail_rec.serial_number_to := l_old_effectivity_detail_rec.serial_number_to;
  END IF;

  IF ( p_x_effectivity_detail_rec.manufacturer_id = FND_API.G_MISS_NUM ) THEN
    p_x_effectivity_detail_rec.manufacturer_id := null;
  ELSIF ( p_x_effectivity_detail_rec.manufacturer_id IS NULL ) THEN
    p_x_effectivity_detail_rec.manufacturer_id := l_old_effectivity_detail_rec.manufacturer_id;
  END IF;

  IF ( p_x_effectivity_detail_rec.manufacturer = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.manufacturer := null;
  ELSIF ( p_x_effectivity_detail_rec.manufacturer IS NULL ) THEN
    p_x_effectivity_detail_rec.manufacturer := l_old_effectivity_detail_rec.manufacturer;
  END IF;

  IF ( p_x_effectivity_detail_rec.manufacture_date_from = FND_API.G_MISS_DATE ) THEN
    p_x_effectivity_detail_rec.manufacture_date_from := null;
  ELSIF ( p_x_effectivity_detail_rec.manufacture_date_from IS NULL ) THEN
    p_x_effectivity_detail_rec.manufacture_date_from := l_old_effectivity_detail_rec.manufacture_date_from;
  END IF;

  IF ( p_x_effectivity_detail_rec.manufacture_date_to = FND_API.G_MISS_DATE ) THEN
    p_x_effectivity_detail_rec.manufacture_date_to := null;
  ELSIF ( p_x_effectivity_detail_rec.manufacture_date_to IS NULL ) THEN
    p_x_effectivity_detail_rec.manufacture_date_to := l_old_effectivity_detail_rec.manufacture_date_to;
  END IF;

  IF ( p_x_effectivity_detail_rec.country_code = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.country_code := null;
  ELSIF ( p_x_effectivity_detail_rec.country_code IS NULL ) THEN
    p_x_effectivity_detail_rec.country_code := l_old_effectivity_detail_rec.country_code;
  END IF;

  IF ( p_x_effectivity_detail_rec.country = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.country := null;
  ELSIF ( p_x_effectivity_detail_rec.country IS NULL ) THEN
    p_x_effectivity_detail_rec.country := l_old_effectivity_detail_rec.country;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute_category := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute_category IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute_category := l_old_effectivity_detail_rec.attribute_category;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute1 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute1 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute1 := l_old_effectivity_detail_rec.attribute1;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute2 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute2 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute2 := l_old_effectivity_detail_rec.attribute2;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute3 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute3 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute3 := l_old_effectivity_detail_rec.attribute3;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute4 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute4 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute4 := l_old_effectivity_detail_rec.attribute4;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute5 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute5 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute5 := l_old_effectivity_detail_rec.attribute5;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute6 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute6 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute6 := l_old_effectivity_detail_rec.attribute6;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute7 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute7 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute7 := l_old_effectivity_detail_rec.attribute7;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute8 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute8 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute8 := l_old_effectivity_detail_rec.attribute8;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute9 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute9 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute9 := l_old_effectivity_detail_rec.attribute9;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute10 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute10 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute10 := l_old_effectivity_detail_rec.attribute10;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute11 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute11 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute11 := l_old_effectivity_detail_rec.attribute11;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute12 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute12 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute12 := l_old_effectivity_detail_rec.attribute12;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute13 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute13 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute13 := l_old_effectivity_detail_rec.attribute13;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute14 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute14 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute14 := l_old_effectivity_detail_rec.attribute14;
  END IF;

  IF ( p_x_effectivity_detail_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_effectivity_detail_rec.attribute15 := null;
  ELSIF ( p_x_effectivity_detail_rec.attribute15 IS NULL ) THEN
    p_x_effectivity_detail_rec.attribute15 := l_old_effectivity_detail_rec.attribute15;
  END IF;

END default_unchanged_attributes;

-- Procedure to add Default values for unchanged attributes (UPDATE)
PROCEDURE default_ext_unchg_attributes
(
  p_x_effty_ext_detail_rec       IN OUT NOCOPY   effty_ext_detail_rec_type
)
IS

l_old_effty_ext_detail_rec       effty_ext_detail_rec_type;

CURSOR get_old_rec ( c_mr_effectivity_ext_dtl_id NUMBER )
IS
SELECT
        EFFECT_EXT_DTL_REC_TYPE,
        EXCLUDE_FLAG,
        OWNER_ID,
        LOCATION_TYPE_CODE,
        CSI_EXT_ATTRIBUTE_CODE,
        CSI_EXT_ATTRIBUTE_VALUE,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15
FROM    AHL_MR_EFFECTIVITY_EXT_DTLS
WHERE   MR_EFFECTIVITY_EXT_DTL_ID = c_mr_effectivity_ext_dtl_id;

BEGIN

  -- Get the old record from AHL_MR_EFFECTIVITY_DTLS.
  OPEN  get_old_rec( p_x_effty_ext_detail_rec.mr_effectivity_ext_dtl_id );

  FETCH get_old_rec INTO
        l_old_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE,
        l_old_effty_ext_detail_rec.EXCLUDE_FLAG,
        l_old_effty_ext_detail_rec.OWNER_ID,
        l_old_effty_ext_detail_rec.LOCATION_TYPE_CODE,
        l_old_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE,
        l_old_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE,
        l_old_effty_ext_detail_rec.attribute_category,
        l_old_effty_ext_detail_rec.attribute1,
        l_old_effty_ext_detail_rec.attribute2,
        l_old_effty_ext_detail_rec.attribute3,
        l_old_effty_ext_detail_rec.attribute4,
        l_old_effty_ext_detail_rec.attribute5,
        l_old_effty_ext_detail_rec.attribute6,
        l_old_effty_ext_detail_rec.attribute7,
        l_old_effty_ext_detail_rec.attribute8,
        l_old_effty_ext_detail_rec.attribute9,
        l_old_effty_ext_detail_rec.attribute10,
        l_old_effty_ext_detail_rec.attribute11,
        l_old_effty_ext_detail_rec.attribute12,
        l_old_effty_ext_detail_rec.attribute13,
        l_old_effty_ext_detail_rec.attribute14,
        l_old_effty_ext_detail_rec.attribute15;

  IF get_old_rec%NOTFOUND THEN
    IF(l_old_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'OWNER')THEN
       FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_INVEFF_EXT_OWN_REC' );
    ELSIF (l_old_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'LOCATION')THEN
       FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_INVEFF_EXT_LOC_REC' );
    ELSIF (l_old_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'CSIEXTATTR')THEN
       FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_INVEFF_EXT_ATTR_REC' );
    END IF;
    FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_x_effty_ext_detail_rec ) );
    FND_MSG_PUB.add;
    CLOSE get_old_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE get_old_rec;

  -- Convert G_MISS values to NULL and NULL values to Old values
  IF ( p_x_effty_ext_detail_rec.exclude_flag IS NULL ) THEN
    p_x_effty_ext_detail_rec.exclude_flag := l_old_effty_ext_detail_rec.exclude_flag;
  END IF;

  IF ( p_x_effty_ext_detail_rec.OWNER_ID = FND_API.G_MISS_NUM ) THEN
    p_x_effty_ext_detail_rec.OWNER_ID := null;
  ELSIF ( p_x_effty_ext_detail_rec.OWNER_ID IS NULL ) THEN
    p_x_effty_ext_detail_rec.OWNER_ID := l_old_effty_ext_detail_rec.OWNER_ID;
  END IF;

  IF ( p_x_effty_ext_detail_rec.OWNER = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.OWNER := null;
  ELSIF ( p_x_effty_ext_detail_rec.OWNER IS NULL ) THEN
    p_x_effty_ext_detail_rec.OWNER := l_old_effty_ext_detail_rec.OWNER;
  END IF;

  IF ( p_x_effty_ext_detail_rec.LOCATION = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.LOCATION := null;
  ELSIF ( p_x_effty_ext_detail_rec.LOCATION IS NULL ) THEN
    p_x_effty_ext_detail_rec.LOCATION := l_old_effty_ext_detail_rec.LOCATION;
  END IF;

  IF ( p_x_effty_ext_detail_rec.LOCATION_TYPE_CODE = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.LOCATION_TYPE_CODE := null;
  ELSIF ( p_x_effty_ext_detail_rec.LOCATION_TYPE_CODE IS NULL ) THEN
    p_x_effty_ext_detail_rec.LOCATION_TYPE_CODE := l_old_effty_ext_detail_rec.LOCATION_TYPE_CODE;
  END IF;

  IF ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE := null;
  ELSIF ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE IS NULL ) THEN
    p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE := l_old_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE;
  END IF;

  IF ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE := null;
  ELSIF ( p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE IS NULL ) THEN
    p_x_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE := l_old_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute_category := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute_category IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute_category := l_old_effty_ext_detail_rec.attribute_category;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute1 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute1 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute1 := l_old_effty_ext_detail_rec.attribute1;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute2 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute2 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute2 := l_old_effty_ext_detail_rec.attribute2;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute3 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute3 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute3 := l_old_effty_ext_detail_rec.attribute3;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute4 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute4 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute4 := l_old_effty_ext_detail_rec.attribute4;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute5 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute5 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute5 := l_old_effty_ext_detail_rec.attribute5;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute6 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute6 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute6 := l_old_effty_ext_detail_rec.attribute6;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute7 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute7 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute7 := l_old_effty_ext_detail_rec.attribute7;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute8 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute8 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute8 := l_old_effty_ext_detail_rec.attribute8;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute9 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute9 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute9 := l_old_effty_ext_detail_rec.attribute9;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute10 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute10 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute10 := l_old_effty_ext_detail_rec.attribute10;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute11 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute11 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute11 := l_old_effty_ext_detail_rec.attribute11;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute12 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute12 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute12 := l_old_effty_ext_detail_rec.attribute12;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute13 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute13 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute13 := l_old_effty_ext_detail_rec.attribute13;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute14 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute14 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute14 := l_old_effty_ext_detail_rec.attribute14;
  END IF;

  IF ( p_x_effty_ext_detail_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
    p_x_effty_ext_detail_rec.attribute15 := null;
  ELSIF ( p_x_effty_ext_detail_rec.attribute15 IS NULL ) THEN
    p_x_effty_ext_detail_rec.attribute15 := l_old_effty_ext_detail_rec.attribute15;
  END IF;

END default_ext_unchg_attributes;

-- Procedure to validate individual effectivity_detail attributes
PROCEDURE validate_attributes
(
  p_effectivity_detail_rec       IN    effectivity_detail_rec_type,
  x_return_status                OUT NOCOPY VARCHAR2
)
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_effectivity_detail_rec.dml_operation = 'C' ) THEN
    -- Check if the Exclude Flag does not contain a null value.
    IF ( p_effectivity_detail_rec.exclude_flag IS NULL OR
         p_effectivity_detail_rec.exclude_flag = FND_API.G_MISS_CHAR ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_EX_FLAG_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_detail_rec ) );
      FND_MSG_PUB.add;
    ELSE
      -- Check if the Exclude Flag does not contain an invalid value.
      IF ( p_effectivity_detail_rec.exclude_flag <> 'Y' AND
           p_effectivity_detail_rec.exclude_flag <> 'N' ) THEN
        FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_EX_FLAG' );
        FND_MESSAGE.set_token( 'FIELD', p_effectivity_detail_rec.exclude_flag );
        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_detail_rec ) );
        FND_MSG_PUB.add;
      END IF;
    END IF;
    RETURN;
  END IF;

  IF ( p_effectivity_detail_rec.dml_operation = 'U' ) THEN
    -- Check if the Exclude Flag does not contain a null value.
    IF ( p_effectivity_detail_rec.exclude_flag = FND_API.G_MISS_CHAR ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_EX_FLAG_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_detail_rec ) );
      FND_MSG_PUB.add;
    ELSIF ( p_effectivity_detail_rec.exclude_flag IS NOT NULL ) THEN
      -- Check if the Exclude Flag does not contain an invalid value.
      IF ( p_effectivity_detail_rec.exclude_flag <> 'Y' AND
           p_effectivity_detail_rec.exclude_flag <> 'N' ) THEN
        FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_EX_FLAG' );
        FND_MESSAGE.set_token( 'FIELD', p_effectivity_detail_rec.exclude_flag );
        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_detail_rec ) );
        FND_MSG_PUB.add;
      END IF;
    END IF;
  END IF;

  -- Check if the mandatory Effectivity Detail ID column contains a null value.
  IF ( p_effectivity_detail_rec.mr_effectivity_detail_id IS NULL OR
       p_effectivity_detail_rec.mr_effectivity_detail_id = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_MR_EFF_DTL_ID_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_detail_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_effectivity_detail_rec.object_version_number IS NULL OR
       p_effectivity_detail_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_MED_OBJ_VERSION_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_detail_rec ) );
    FND_MSG_PUB.add;
  END IF;

END validate_attributes;

-- Procedure to validate individual effectivity_detail attributes
PROCEDURE validate_ext_attributes
(
  p_effty_ext_detail_rec       IN    effty_ext_detail_rec_type,
  x_return_status                OUT NOCOPY VARCHAR2
)
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_effty_ext_detail_rec.dml_operation = 'C' ) THEN
    -- Check if the Exclude Flag does not contain a null value.
    IF ( p_effty_ext_detail_rec.exclude_flag IS NULL OR
         p_effty_ext_detail_rec.exclude_flag = FND_API.G_MISS_CHAR ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_EX_FLAG_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_effty_ext_detail_rec ) );
      FND_MSG_PUB.add;
    ELSE
      -- Check if the Exclude Flag does not contain an invalid value.
      IF ( p_effty_ext_detail_rec.exclude_flag <> 'Y' AND
           p_effty_ext_detail_rec.exclude_flag <> 'N' ) THEN
        FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_EX_FLAG' );
        FND_MESSAGE.set_token( 'FIELD', p_effty_ext_detail_rec.exclude_flag );
        FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_effty_ext_detail_rec ) );
        FND_MSG_PUB.add;
      END IF;
    END IF;
    RETURN;
  END IF;

  IF ( p_effty_ext_detail_rec.dml_operation = 'U' ) THEN
    -- Check if the Exclude Flag does not contain a null value.
    IF ( p_effty_ext_detail_rec.exclude_flag = FND_API.G_MISS_CHAR ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_EX_FLAG_NULL' );
      FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_effty_ext_detail_rec ) );
      FND_MSG_PUB.add;
    ELSIF ( p_effty_ext_detail_rec.exclude_flag IS NOT NULL ) THEN
      -- Check if the Exclude Flag does not contain an invalid value.
      IF ( p_effty_ext_detail_rec.exclude_flag <> 'Y' AND
           p_effty_ext_detail_rec.exclude_flag <> 'N' ) THEN
        FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_EX_FLAG' );
        FND_MESSAGE.set_token( 'FIELD', p_effty_ext_detail_rec.exclude_flag );
        FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_effty_ext_detail_rec ) );
        FND_MSG_PUB.add;
      END IF;
    END IF;
  END IF;

  -- Check if the mandatory Effectivity Detail ID column contains a null value.
  IF ( p_effty_ext_detail_rec.MR_EFFECTIVITY_EXT_DTL_ID IS NULL OR
       p_effty_ext_detail_rec.MR_EFFECTIVITY_EXT_DTL_ID = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_MR_EFF_EXT_DTL_ID_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_effty_ext_detail_rec ) );
    FND_MSG_PUB.add;
  END IF;

  -- Check if the mandatory Object Version Number column contains a null value.
  IF ( p_effty_ext_detail_rec.object_version_number IS NULL OR
       p_effty_ext_detail_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_MED_EXT_OBJ_VER_NULL' );
    FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_effty_ext_detail_rec ) );
    FND_MSG_PUB.add;
  END IF;

END validate_ext_attributes;

-- Procedure to Perform cross attribute validation and missing attribute checks (Record level validation)
PROCEDURE validate_record
(
  p_effectivity_detail_rec       IN    effectivity_detail_rec_type,
  x_return_status                OUT NOCOPY VARCHAR2
)
IS

l_return_status              VARCHAR2(1);
l_msg_data                   VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if Serial Number Range is valid
  IF ( p_effectivity_detail_rec.serial_number_from IS NOT NULL AND
       p_effectivity_detail_rec.serial_number_to IS NOT NULL ) THEN

    AHL_FMP_COMMON_PVT.validate_serial_numbers_range
    (
      x_return_status          => l_return_status,
      x_msg_data               => l_msg_data,
      p_serial_number_from     => p_effectivity_detail_rec.serial_number_from,
      p_serial_number_to       => p_effectivity_detail_rec.serial_number_to
    );

    IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
      FND_MESSAGE.set_name( 'AHL', l_msg_data );
      FND_MESSAGE.set_token( 'FIELD1', p_effectivity_detail_rec.serial_number_from );
      FND_MESSAGE.set_token( 'FIELD2', p_effectivity_detail_rec.serial_number_to );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_detail_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if Manufacture date range is valid
  IF ( p_effectivity_detail_rec.manufacture_date_from IS NOT NULL AND
       p_effectivity_detail_rec.manufacture_date_to IS NOT NULL ) THEN
    IF ( p_effectivity_detail_rec.manufacture_date_from >
         p_effectivity_detail_rec.manufacture_date_to ) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_MFG_DT_RANGE' );
      FND_MESSAGE.set_token( 'FIELD1', p_effectivity_detail_rec.manufacture_date_from );
      FND_MESSAGE.set_token( 'FIELD2', p_effectivity_detail_rec.manufacture_date_to );
      FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_effectivity_detail_rec ) );
      FND_MSG_PUB.add;
    END IF;
  END IF;

  -- Check if atleast one value is passed in the record
  IF ( p_effectivity_detail_rec.serial_number_from IS NULL AND
       p_effectivity_detail_rec.serial_number_to IS NULL AND
       p_effectivity_detail_rec.manufacturer_id IS NULL AND
       p_effectivity_detail_rec.manufacturer IS NULL AND
       p_effectivity_detail_rec.manufacture_date_from IS NULL AND
       p_effectivity_detail_rec.manufacture_date_to IS NULL AND
       p_effectivity_detail_rec.country IS NULL AND
       p_effectivity_detail_rec.country_code IS NULL ) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_FMP_ONE_VALUE_REQD' );
    FND_MSG_PUB.add;
  END IF;

END validate_record;

-- Procedure to Perform cross attribute validation and missing attribute checks (Record level validation)
PROCEDURE validate_ext_record
(
  p_effty_ext_detail_rec       IN    effty_ext_detail_rec_type,
  x_return_status                OUT NOCOPY VARCHAR2
)
IS

l_return_status              VARCHAR2(1);
l_msg_data                   VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'OWNER' )THEN
      IF ( (p_effty_ext_detail_rec.owner IS NULL OR p_effty_ext_detail_rec.owner = FND_API.G_MISS_CHAR) AND
           (p_effty_ext_detail_rec.owner_id IS NULL OR p_effty_ext_detail_rec.owner_id = FND_API.G_MISS_NUM )) THEN
         FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_OWNER_NLL' );
         FND_MSG_PUB.add;
      ELSIF((p_effty_ext_detail_rec.location IS NOT NULL OR p_effty_ext_detail_rec.location <> FND_API.G_MISS_CHAR) AND
           (p_effty_ext_detail_rec.location_type_code IS NOT NULL OR p_effty_ext_detail_rec.location_type_code <> FND_API.G_MISS_CHAR )) THEN
         FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_OWNER_REC' );
         FND_MSG_PUB.add;
      ELSIF((p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME IS NOT NULL OR p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME <> FND_API.G_MISS_CHAR) AND
           (p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE IS NOT NULL OR p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE <> FND_API.G_MISS_CHAR ))THEN
         FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_OWNER_REC' );
         FND_MSG_PUB.add;
      END IF;
   ELSIF( p_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'LOCATION' ) THEN
      IF((p_effty_ext_detail_rec.location IS NULL OR p_effty_ext_detail_rec.location = FND_API.G_MISS_CHAR) AND
           (p_effty_ext_detail_rec.location_type_code IS NULL OR p_effty_ext_detail_rec.location_type_code = FND_API.G_MISS_CHAR )) THEN
         FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_LOC_NLL' );
         FND_MSG_PUB.add;
      ELSIF ( (p_effty_ext_detail_rec.owner IS NOT NULL OR p_effty_ext_detail_rec.owner <> FND_API.G_MISS_CHAR) AND
           (p_effty_ext_detail_rec.owner_id IS NOT NULL OR p_effty_ext_detail_rec.owner_id <> FND_API.G_MISS_NUM )) THEN
         FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_LOC_REC' );
         FND_MSG_PUB.add;
      ELSIF((p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME IS NOT NULL OR p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME <> FND_API.G_MISS_CHAR) AND
           (p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE IS NOT NULL OR p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE <> FND_API.G_MISS_CHAR ))THEN
         FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_LOC_REC' );
         FND_MSG_PUB.add;
      END IF;
   ELSIF( p_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE = 'CSIEXTATTR' ) THEN
     IF((p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME IS NULL OR p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME = FND_API.G_MISS_CHAR) AND
           (p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE IS NULL OR p_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE = FND_API.G_MISS_CHAR ))THEN
         FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_CSIATTR_NLL' );
         FND_MSG_PUB.add;
      ELSIF ( (p_effty_ext_detail_rec.owner IS NOT NULL OR p_effty_ext_detail_rec.owner <> FND_API.G_MISS_CHAR) AND
           (p_effty_ext_detail_rec.owner_id IS NOT NULL OR p_effty_ext_detail_rec.owner_id <> FND_API.G_MISS_NUM )) THEN
         FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_CSIATTR_REC' );
         FND_MSG_PUB.add;
      ELSIF((p_effty_ext_detail_rec.location IS NOT NULL OR p_effty_ext_detail_rec.location <> FND_API.G_MISS_CHAR) AND
           (p_effty_ext_detail_rec.location_type_code IS NOT NULL OR p_effty_ext_detail_rec.location_type_code <> FND_API.G_MISS_CHAR )) THEN
         FND_MESSAGE.set_name( 'AHL','AHL_FMP_INVALID_CSIATTR_REC' );
         FND_MSG_PUB.add;
      END IF;
   END IF;


END validate_ext_record;

-- Procedure to Perform cross records validation and duplicate checks
PROCEDURE validate_records
(
  p_mr_effectivity_id       IN    NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2
)
IS

l_effectivity_detail_rec                effectivity_detail_rec_type;

CURSOR get_dup_rec ( c_mr_effectivity_id NUMBER )
IS
SELECT   serial_number_from,
         serial_number_to,
         manufacturer,
         manufacture_date_from,
         manufacture_date_to,
         country
FROM     AHL_MR_EFFECTIVITY_DTLS_V
WHERE    mr_effectivity_id = c_mr_effectivity_id
GROUP BY serial_number_from,
         serial_number_to,
         manufacturer,
         manufacture_date_from,
         manufacture_date_to,
         country
HAVING   count(*) > 1;

CURSOR get_dup_owner_rec ( c_mr_effectivity_id NUMBER )
IS
SELECT   EFFEXT.OWNER_ID,
         OWN.owner_number
         ,EFFEXT.EFFECT_EXT_DTL_REC_TYPE
FROM    AHL_MR_EFFECTIVITY_EXT_DTLS EFFEXT, ahl_owner_details_v OWN
WHERE    EFFEXT.mr_effectivity_id = c_mr_effectivity_id
AND      EFFEXT.OWNER_ID = OWN.owner_id
AND      EFFECT_EXT_DTL_REC_TYPE = 'OWNER'
GROUP BY EFFEXT.OWNER_ID,
         OWN.owner_number,
         EFFEXT.EFFECT_EXT_DTL_REC_TYPE
HAVING   count(*) > 1;

CURSOR get_dup_location_rec ( c_mr_effectivity_id NUMBER )
IS
SELECT   EFFEXT.LOCATION_TYPE_CODE,
         CS.meaning
         ,EFFEXT.EFFECT_EXT_DTL_REC_TYPE
FROM     AHL_MR_EFFECTIVITY_EXT_DTLS EFFEXT, csi_lookups CS
WHERE    EFFEXT.mr_effectivity_id = c_mr_effectivity_id
and CS.lookup_type='CSI_INST_LOCATION_SOURCE_CODE' and CS.lookup_code = EFFEXT.LOCATION_TYPE_CODE
AND      EFFECT_EXT_DTL_REC_TYPE = 'LOCATION'
GROUP BY EFFEXT.LOCATION_TYPE_CODE,
         CS.meaning,
         EFFEXT.EFFECT_EXT_DTL_REC_TYPE
HAVING   count(*) > 1;


CURSOR get_dup_csi_attrib_rec ( c_mr_effectivity_id NUMBER )
IS
SELECT   EFFEXT.CSI_EXT_ATTRIBUTE_CODE
         , EFFEXT.CSI_EXT_ATTRIBUTE_VALUE
         ,EFFEXT.EFFECT_EXT_DTL_REC_TYPE
         ,(Select CIEA.ATTRIBUTE_NAME from CSI_I_EXTENDED_ATTRIBS CIEA
          WHERE CIEA.ATTRIBUTE_CODE = EFFEXT.CSI_EXT_ATTRIBUTE_CODE AND rownum < 2) CSI_EXT_ATTRIBUTE_NAME
FROM    AHL_MR_EFFECTIVITY_EXT_DTLS EFFEXT
WHERE    EFFEXT.mr_effectivity_id = c_mr_effectivity_id
AND     EFFEXT.EFFECT_EXT_DTL_REC_TYPE = 'CSIEXTATTR'
GROUP BY EFFEXT.CSI_EXT_ATTRIBUTE_CODE,
         EFFEXT.CSI_EXT_ATTRIBUTE_VALUE,
         EFFEXT.EFFECT_EXT_DTL_REC_TYPE
HAVING   count(*) > 1;

l_effty_ext_detail_rec                effty_ext_detail_rec_type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check whether any duplicate effectivity_detail records exist
  OPEN  get_dup_rec( p_mr_effectivity_id );

  LOOP
    FETCH get_dup_rec INTO
      l_effectivity_detail_rec.serial_number_from,
      l_effectivity_detail_rec.serial_number_to,
      l_effectivity_detail_rec.manufacturer,
      l_effectivity_detail_rec.manufacture_date_from,
      l_effectivity_detail_rec.manufacture_date_to,
      l_effectivity_detail_rec.country;

    EXIT WHEN get_dup_rec%NOTFOUND;

    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_DUPLICATE_MED_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( l_effectivity_detail_rec ) );
    FND_MSG_PUB.add;
  END LOOP;

  IF ( get_dup_rec%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_rec;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE get_dup_rec;

  -- Check whether any duplicate effectivity_detail owner records exist
  OPEN  get_dup_owner_rec( p_mr_effectivity_id );

  LOOP
    FETCH get_dup_owner_rec INTO
      l_effty_ext_detail_rec.owner_id,
      l_effty_ext_detail_rec.owner,
      l_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE;

    EXIT WHEN get_dup_owner_rec%NOTFOUND;

    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_DUP_MED_OWNER_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( l_effty_ext_detail_rec ) );
    FND_MSG_PUB.add;
  END LOOP;

  IF ( get_dup_owner_rec%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_owner_rec;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE get_dup_owner_rec;

  -- Check whether any duplicate effectivity_detail location records exist
  OPEN  get_dup_location_rec( p_mr_effectivity_id );

  LOOP
    FETCH get_dup_location_rec INTO
      l_effty_ext_detail_rec.LOCATION_TYPE_CODE,
      l_effty_ext_detail_rec.location,
      l_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE;

    EXIT WHEN get_dup_location_rec%NOTFOUND;

    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_DUP_MED_LOC_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( l_effty_ext_detail_rec ) );
    FND_MSG_PUB.add;
  END LOOP;

  IF ( get_dup_location_rec%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_location_rec;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE get_dup_location_rec;

  -- Check whether any duplicate effectivity_detail location records exist
  OPEN  get_dup_csi_attrib_rec( p_mr_effectivity_id );

  LOOP
    FETCH get_dup_csi_attrib_rec INTO
      l_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_CODE,
      l_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_VALUE,
      l_effty_ext_detail_rec.EFFECT_EXT_DTL_REC_TYPE
      ,l_effty_ext_detail_rec.CSI_EXT_ATTRIBUTE_NAME;

    EXIT WHEN get_dup_csi_attrib_rec%NOTFOUND;

    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_DUP_MED_ATTRIB_REC' );
    FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( l_effty_ext_detail_rec ) );
    FND_MSG_PUB.add;
  END LOOP;

  IF ( get_dup_csi_attrib_rec%ROWCOUNT > 0 ) THEN
    CLOSE get_dup_csi_attrib_rec;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  CLOSE get_dup_csi_attrib_rec;



END validate_records;

PROCEDURE process_effectivity_detail
(
 p_api_version                  IN  NUMBER     := '1.0',
 p_init_msg_list                IN  VARCHAR2   := FND_API.G_TRUE,
 p_commit                       IN  VARCHAR2   := FND_API.G_FALSE,
 p_validation_level             IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default                      IN  VARCHAR2   := FND_API.G_FALSE,
 p_module_type                  IN  VARCHAR2   := NULL,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_x_effectivity_detail_tbl     IN OUT NOCOPY  effectivity_detail_tbl_type,
 p_x_effty_ext_detail_tbl       IN OUT NOCOPY  effty_ext_detail_tbl_type,
 p_mr_header_id                 IN  NUMBER,
 p_mr_effectivity_id            IN  NUMBER
)

IS

CURSOR get_all_effc_info ( c_mr_effectivity_id NUMBER )
IS
SELECT   serial_number_from,
         serial_number_to,
         MR_EFFECTIVITY_DETAIL_ID
FROM     AHL_MR_EFFECTIVITY_DTLS_V
WHERE    mr_effectivity_id = c_mr_effectivity_id;


Cursor find_min_max_serials ( c_mr_effectivity_id NUMBER )
IS
select distinct MIN(CSI.serial_number) , MAX(CSI.serial_number)
from csi_item_instances CSI,
AHL_MR_EFFECTIVITIES EFF
where
EFF.MR_EFFECTIVITY_ID  = c_mr_effectivity_id and
CSI.inventory_item_id = EFF.inventory_item_id
UNION
select distinct MIN(CSI.serial_number) , MAX(CSI.serial_number)
from csi_item_instances CSI,
ahl_position_alternates_v PA,
AHL_MR_EFFECTIVITIES EFF
where
EFF.MR_EFFECTIVITY_ID  = c_mr_effectivity_id  and
EFF.RELATIONSHIP_ID = PA.relationship_id and
CSI.inventory_item_id = PA.inventory_item_id;


l_get_eff_info get_all_effc_info%ROWTYPE;

l_api_version    CONSTANT   NUMBER         := 1.0;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_mr_effectivity_detail_id  NUMBER;

l_min_serial VARCHAR2(30);
l_max_serial VARCHAR2(30);

x VARCHAR2(30);
y VARCHAR2(30);
xi VARCHAR2(30);
yi VARCHAR2(30);

l_MR_EFFECTIVITY_EXT_DTL_ID NUMBER;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT process_effectivity_detail_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call
  (
    l_api_version,
    p_api_version,
    G_API_NAME,
    G_PKG_NAME
  )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Enable Debug (optional)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' : Begin API' );
  END IF;

  -- Validate all the inputs of the API
  validate_api_inputs
  (
    p_x_effectivity_detail_tbl, -- IN
    p_x_effty_ext_detail_tbl,
    p_mr_header_id, -- IN
    p_mr_effectivity_id, -- IN
    l_return_status -- OUT
  );

  -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' : Done validate_api_inputs' );
  END IF;
  -- If the module type is JSP, then default values for ID columns of LOV attributes
  IF ( p_module_type = 'JSP' ) THEN
    FOR i IN 1..p_x_effectivity_detail_tbl.count LOOP
      IF ( p_x_effectivity_detail_tbl(i).dml_operation <> 'D' ) THEN
        clear_lov_attribute_ids
        (
          p_x_effectivity_detail_tbl(i) -- IN OUT Record with Values and Ids
        );
      END IF;
    END LOOP;
    FOR i IN 1..p_x_effty_ext_detail_tbl.count LOOP
      IF ( p_x_effty_ext_detail_tbl(i).dml_operation <> 'D' ) THEN
        clear_ext_lov_attribute_ids
        (
          p_x_effty_ext_detail_tbl(i) -- IN OUT Record with Values and Ids
        );
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' : Done clear_lov_attribute_ids and clear_ext_lov_attribute_ids' );
  END IF;

  -- Convert Values into Ids.
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_effectivity_detail_tbl.count LOOP
      IF ( p_x_effectivity_detail_tbl(i).dml_operation <> 'D' ) THEN
        convert_values_to_ids
        (
          p_x_effectivity_detail_tbl(i), -- IN OUT Record with Values and Ids
          p_mr_effectivity_id, -- IN
          l_return_status -- OUT
        );

        -- If any severe error occurs, then, abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;
    FOR i IN 1..p_x_effty_ext_detail_tbl.count LOOP
      IF ( p_x_effty_ext_detail_tbl(i).dml_operation <> 'D' ) THEN
        convert_ext_values_to_ids
        (
          p_x_effty_ext_detail_tbl(i), -- IN OUT Record with Values and Ids
          p_mr_effectivity_id, -- IN
          l_return_status -- OUT
        );

        -- If any severe error occurs, then, abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after convert_values_to_ids' );
  END IF;

  -- Default effectivity_detail attributes.
  IF FND_API.to_boolean( p_default ) THEN
    FOR i IN 1..p_x_effectivity_detail_tbl.count LOOP
      IF ( p_x_effectivity_detail_tbl(i).dml_operation <> 'D' ) THEN
        default_attributes
        (
          p_x_effectivity_detail_tbl(i) -- IN OUT
        );
      END IF;
    END LOOP;
    FOR i IN 1..p_x_effty_ext_detail_tbl.count LOOP
      IF ( p_x_effty_ext_detail_tbl(i).dml_operation <> 'D' ) THEN
        default_ext_attributes
        (
          p_x_effty_ext_detail_tbl(i) -- IN OUT
        );
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_attributes' );
  END IF;

  -- Validate all attributes (Item level validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_effectivity_detail_tbl.count LOOP
      validate_attributes
      (
        p_x_effectivity_detail_tbl(i), -- IN
        l_return_status -- OUT
      );

      -- If any severe error occurs, then, abort API.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
    FOR i IN 1..p_x_effty_ext_detail_tbl.count LOOP
      validate_ext_attributes
      (
        p_x_effty_ext_detail_tbl(i), -- IN
        l_return_status -- OUT
      );

      -- If any severe error occurs, then, abort API.
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_attributes' );
  END IF;

  -- Default missing and unchanged attributes.
  FOR i IN 1..p_x_effectivity_detail_tbl.count LOOP
    IF ( p_x_effectivity_detail_tbl(i).dml_operation = 'U' ) THEN
      default_unchanged_attributes
      (
        p_x_effectivity_detail_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_effectivity_detail_tbl(i).dml_operation = 'C' ) THEN
      default_missing_attributes
      (
        p_x_effectivity_detail_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  -- Default missing and unchanged attributes.
  FOR i IN 1..p_x_effty_ext_detail_tbl.count LOOP
    IF ( p_x_effty_ext_detail_tbl(i).dml_operation = 'U' ) THEN
      default_ext_unchg_attributes
      (
        p_x_effty_ext_detail_tbl(i) -- IN OUT
      );
    ELSIF ( p_x_effty_ext_detail_tbl(i).dml_operation = 'C' ) THEN
      default_ext_missing_attributes
      (
        p_x_effty_ext_detail_tbl(i) -- IN OUT
      );
    END IF;
  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after default_unchanged_attributes / default_missing_attributes' );
  END IF;

  -- Perform cross attribute validation and missing attribute checks (Record level validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    FOR i IN 1..p_x_effectivity_detail_tbl.count LOOP
      IF ( p_x_effectivity_detail_tbl(i).dml_operation <> 'D' ) THEN
        validate_record
        (
          p_x_effectivity_detail_tbl(i), -- IN
          l_return_status -- OUT
        );

        -- If any severe error occurs, then, abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;
    FOR i IN 1..p_x_effty_ext_detail_tbl.count LOOP
      IF ( p_x_effty_ext_detail_tbl(i).dml_operation <> 'D' ) THEN
        validate_ext_record
        (
          p_x_effty_ext_detail_tbl(i), -- IN
          l_return_status -- OUT
        );

        -- If any severe error occurs, then, abort API.
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_record' );
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Perform the DML statement directly.
  FOR i IN 1..p_x_effectivity_detail_tbl.count LOOP
    IF ( p_x_effectivity_detail_tbl(i).dml_operation = 'C' ) THEN

      -- Insert the record
      INSERT INTO AHL_MR_EFFECTIVITY_DTLS
      (
        MR_EFFECTIVITY_DETAIL_ID,
        OBJECT_VERSION_NUMBER,
        MR_EFFECTIVITY_ID,
        EXCLUDE_FLAG,
        SERIAL_NUMBER_FROM,
        SERIAL_NUMBER_TO,
        MANUFACTURER_ID,
        MANUFACTURE_DATE_FROM,
        MANUFACTURE_DATE_TO,
        COUNTRY_CODE,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      ) VALUES
      (
        AHL_MR_EFFECTIVITY_DTLS_S.NEXTVAL,
        p_x_effectivity_detail_tbl(i).object_version_number,
        p_mr_effectivity_id,
        p_x_effectivity_detail_tbl(i).exclude_flag,
        p_x_effectivity_detail_tbl(i).serial_number_from,
        p_x_effectivity_detail_tbl(i).serial_number_to,
        p_x_effectivity_detail_tbl(i).manufacturer_id,
        p_x_effectivity_detail_tbl(i).manufacture_date_from,
        p_x_effectivity_detail_tbl(i).manufacture_date_to,
        p_x_effectivity_detail_tbl(i).country_code,
        p_x_effectivity_detail_tbl(i).attribute_category,
        p_x_effectivity_detail_tbl(i).attribute1,
        p_x_effectivity_detail_tbl(i).attribute2,
        p_x_effectivity_detail_tbl(i).attribute3,
        p_x_effectivity_detail_tbl(i).attribute4,
        p_x_effectivity_detail_tbl(i).attribute5,
        p_x_effectivity_detail_tbl(i).attribute6,
        p_x_effectivity_detail_tbl(i).attribute7,
        p_x_effectivity_detail_tbl(i).attribute8,
        p_x_effectivity_detail_tbl(i).attribute9,
        p_x_effectivity_detail_tbl(i).attribute10,
        p_x_effectivity_detail_tbl(i).attribute11,
        p_x_effectivity_detail_tbl(i).attribute12,
        p_x_effectivity_detail_tbl(i).attribute13,
        p_x_effectivity_detail_tbl(i).attribute14,
        p_x_effectivity_detail_tbl(i).attribute15,
        p_x_effectivity_detail_tbl(i).last_update_date,
        p_x_effectivity_detail_tbl(i).last_updated_by,
        p_x_effectivity_detail_tbl(i).creation_date,
        p_x_effectivity_detail_tbl(i).created_by,
        p_x_effectivity_detail_tbl(i).last_update_login
      ) RETURNING mr_effectivity_detail_id INTO l_mr_effectivity_detail_id;

      -- Set OUT values
      p_x_effectivity_detail_tbl(i).mr_effectivity_detail_id := l_mr_effectivity_detail_id;

    ELSIF ( p_x_effectivity_detail_tbl(i).dml_operation = 'U' ) THEN

      -- Update the record
      UPDATE AHL_MR_EFFECTIVITY_DTLS SET
        object_version_number = object_version_number + 1,
        exclude_flag          = p_x_effectivity_detail_tbl(i).exclude_flag,
        serial_number_from    = p_x_effectivity_detail_tbl(i).serial_number_from,
        serial_number_to      = p_x_effectivity_detail_tbl(i).serial_number_to,
        manufacturer_id       = p_x_effectivity_detail_tbl(i).manufacturer_id,
        manufacture_date_from = p_x_effectivity_detail_tbl(i).manufacture_date_from,
        manufacture_date_to   = p_x_effectivity_detail_tbl(i).manufacture_date_to,
        country_code          = p_x_effectivity_detail_tbl(i).country_code,
        attribute_category    = p_x_effectivity_detail_tbl(i).attribute_category,
        attribute1            = p_x_effectivity_detail_tbl(i).attribute1,
        attribute2            = p_x_effectivity_detail_tbl(i).attribute2,
        attribute3            = p_x_effectivity_detail_tbl(i).attribute3,
        attribute4            = p_x_effectivity_detail_tbl(i).attribute4,
        attribute5            = p_x_effectivity_detail_tbl(i).attribute5,
        attribute6            = p_x_effectivity_detail_tbl(i).attribute6,
        attribute7            = p_x_effectivity_detail_tbl(i).attribute7,
        attribute8            = p_x_effectivity_detail_tbl(i).attribute8,
        attribute9            = p_x_effectivity_detail_tbl(i).attribute9,
        attribute10           = p_x_effectivity_detail_tbl(i).attribute10,
        attribute11           = p_x_effectivity_detail_tbl(i).attribute11,
        attribute12           = p_x_effectivity_detail_tbl(i).attribute12,
        attribute13           = p_x_effectivity_detail_tbl(i).attribute13,
        attribute14           = p_x_effectivity_detail_tbl(i).attribute14,
        attribute15           = p_x_effectivity_detail_tbl(i).attribute15,
        last_update_date      = p_x_effectivity_detail_tbl(i).last_update_date,
        last_updated_by       = p_x_effectivity_detail_tbl(i).last_updated_by,
        last_update_login     = p_x_effectivity_detail_tbl(i).last_update_login
      WHERE mr_effectivity_detail_id  = p_x_effectivity_detail_tbl(i).mr_effectivity_detail_id
      AND   object_version_number     = p_x_effectivity_detail_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_FMP_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_detail_tbl(i) ) );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Set OUT values
      p_x_effectivity_detail_tbl(i).object_version_number := p_x_effectivity_detail_tbl(i).object_version_number + 1;

    ELSIF ( p_x_effectivity_detail_tbl(i).dml_operation = 'D' ) THEN

      -- Delete the record
      DELETE AHL_MR_EFFECTIVITY_DTLS
      WHERE mr_effectivity_detail_id = p_x_effectivity_detail_tbl(i).mr_effectivity_detail_id
      AND   object_version_number    = p_x_effectivity_detail_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_FMP_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', TO_CHAR( i ) );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;



  END LOOP;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after DML operation' );
  END IF;


-- this check can only be done once all records are created/updated/deleted.

  FOR i IN 1..p_x_effectivity_detail_tbl.count LOOP
    IF ( p_x_effectivity_detail_tbl(i).dml_operation <> 'D' ) THEN


          OPEN find_min_max_serials ( p_mr_effectivity_id );
          FETCH find_min_max_serials INTO l_min_serial , l_max_serial;
          CLOSE find_min_max_serials;

	  OPEN get_all_effc_info( p_mr_effectivity_id );

	  LOOP
	    FETCH get_all_effc_info INTO
	      l_get_eff_info.serial_number_from,
	      l_get_eff_info.serial_number_to,
	      l_get_eff_info.MR_EFFECTIVITY_DETAIL_ID ;

	    EXIT WHEN get_all_effc_info%NOTFOUND;


            xi := NVL( p_x_effectivity_detail_tbl(i).serial_number_from , l_min_serial);
            yi := NVL( p_x_effectivity_detail_tbl(i).serial_number_to , l_max_serial);
            x :=  NVL( l_get_eff_info.serial_number_from , l_min_serial);
            y :=  NVL( l_get_eff_info.serial_number_to , l_max_serial);


		IF(l_get_eff_info.MR_EFFECTIVITY_DETAIL_ID <> p_x_effectivity_detail_tbl(i).MR_EFFECTIVITY_DETAIL_ID) THEN

			IF(
			   (
			    ( xi >= x ) AND
			    ( xi <= y )
			   )
			   OR
			   (
			    ( yi >= x ) AND
			    ( yi <= y )
			   )
			   OR
			   (
			    ( xi < x ) AND
			    ( yi > y )
			   )
			  )
			THEN
			    FND_MESSAGE.set_name( 'AHL', 'AHL_FMP_OVERLAP_MED_REC' );
			    FND_MESSAGE.set_token( 'RECORD', get_record_identifier( p_x_effectivity_detail_tbl(i) ) );
			    FND_MSG_PUB.add;
			    RAISE FND_API.G_EXC_ERROR;
			END IF;

		END IF;

	  END LOOP;

	  CLOSE get_all_effc_info;

    END IF;

  END LOOP;

  -- Perform the DML statement directly.
  FOR i IN 1..p_x_effty_ext_detail_tbl.count LOOP
    IF ( p_x_effty_ext_detail_tbl(i).dml_operation = 'C' ) THEN

      -- Insert the record
      INSERT INTO AHL_MR_EFFECTIVITY_EXT_DTLS
      (
        MR_EFFECTIVITY_EXT_DTL_ID,
        OBJECT_VERSION_NUMBER,
        MR_EFFECTIVITY_ID,
        EXCLUDE_FLAG,
        EFFECT_EXT_DTL_REC_TYPE,
        OWNER_ID,
        LOCATION_TYPE_CODE,
        CSI_EXT_ATTRIBUTE_CODE,
        CSI_EXT_ATTRIBUTE_VALUE,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      ) VALUES
      (
        AHL_MR_EFFECTIVITY_EXT_DTLS_S.NEXTVAL,
        p_x_effty_ext_detail_tbl(i).object_version_number,
        p_mr_effectivity_id,
        p_x_effty_ext_detail_tbl(i).exclude_flag,
        p_x_effty_ext_detail_tbl(i).EFFECT_EXT_DTL_REC_TYPE,
        p_x_effty_ext_detail_tbl(i).OWNER_ID,
        p_x_effty_ext_detail_tbl(i).LOCATION_TYPE_CODE,
        p_x_effty_ext_detail_tbl(i).CSI_EXT_ATTRIBUTE_CODE,
        p_x_effty_ext_detail_tbl(i).CSI_EXT_ATTRIBUTE_VALUE,
        p_x_effty_ext_detail_tbl(i).attribute_category,
        p_x_effty_ext_detail_tbl(i).attribute1,
        p_x_effty_ext_detail_tbl(i).attribute2,
        p_x_effty_ext_detail_tbl(i).attribute3,
        p_x_effty_ext_detail_tbl(i).attribute4,
        p_x_effty_ext_detail_tbl(i).attribute5,
        p_x_effty_ext_detail_tbl(i).attribute6,
        p_x_effty_ext_detail_tbl(i).attribute7,
        p_x_effty_ext_detail_tbl(i).attribute8,
        p_x_effty_ext_detail_tbl(i).attribute9,
        p_x_effty_ext_detail_tbl(i).attribute10,
        p_x_effty_ext_detail_tbl(i).attribute11,
        p_x_effty_ext_detail_tbl(i).attribute12,
        p_x_effty_ext_detail_tbl(i).attribute13,
        p_x_effty_ext_detail_tbl(i).attribute14,
        p_x_effty_ext_detail_tbl(i).attribute15,
        p_x_effty_ext_detail_tbl(i).last_update_date,
        p_x_effty_ext_detail_tbl(i).last_updated_by,
        p_x_effty_ext_detail_tbl(i).creation_date,
        p_x_effty_ext_detail_tbl(i).created_by,
        p_x_effty_ext_detail_tbl(i).last_update_login
      ) RETURNING MR_EFFECTIVITY_EXT_DTL_ID INTO l_MR_EFFECTIVITY_EXT_DTL_ID;

      -- Set OUT values
      p_x_effty_ext_detail_tbl(i).MR_EFFECTIVITY_EXT_DTL_ID := l_MR_EFFECTIVITY_EXT_DTL_ID;

    ELSIF ( p_x_effty_ext_detail_tbl(i).dml_operation = 'U' ) THEN

      -- Update the record
      UPDATE AHL_MR_EFFECTIVITY_EXT_DTLS SET
        object_version_number = object_version_number + 1,
        exclude_flag          = p_x_effty_ext_detail_tbl(i).exclude_flag,
        EFFECT_EXT_DTL_REC_TYPE    = p_x_effty_ext_detail_tbl(i).EFFECT_EXT_DTL_REC_TYPE,
        OWNER_ID      = p_x_effty_ext_detail_tbl(i).OWNER_ID,
        LOCATION_TYPE_CODE       = p_x_effty_ext_detail_tbl(i).LOCATION_TYPE_CODE,
        CSI_EXT_ATTRIBUTE_CODE = p_x_effty_ext_detail_tbl(i).CSI_EXT_ATTRIBUTE_CODE,
        CSI_EXT_ATTRIBUTE_VALUE   = p_x_effty_ext_detail_tbl(i).CSI_EXT_ATTRIBUTE_VALUE,
        attribute_category    = p_x_effty_ext_detail_tbl(i).attribute_category,
        attribute1            = p_x_effty_ext_detail_tbl(i).attribute1,
        attribute2            = p_x_effty_ext_detail_tbl(i).attribute2,
        attribute3            = p_x_effty_ext_detail_tbl(i).attribute3,
        attribute4            = p_x_effty_ext_detail_tbl(i).attribute4,
        attribute5            = p_x_effty_ext_detail_tbl(i).attribute5,
        attribute6            = p_x_effty_ext_detail_tbl(i).attribute6,
        attribute7            = p_x_effty_ext_detail_tbl(i).attribute7,
        attribute8            = p_x_effty_ext_detail_tbl(i).attribute8,
        attribute9            = p_x_effty_ext_detail_tbl(i).attribute9,
        attribute10           = p_x_effty_ext_detail_tbl(i).attribute10,
        attribute11           = p_x_effty_ext_detail_tbl(i).attribute11,
        attribute12           = p_x_effty_ext_detail_tbl(i).attribute12,
        attribute13           = p_x_effty_ext_detail_tbl(i).attribute13,
        attribute14           = p_x_effty_ext_detail_tbl(i).attribute14,
        attribute15           = p_x_effty_ext_detail_tbl(i).attribute15,
        last_update_date      = p_x_effty_ext_detail_tbl(i).last_update_date,
        last_updated_by       = p_x_effty_ext_detail_tbl(i).last_updated_by,
        last_update_login     = p_x_effty_ext_detail_tbl(i).last_update_login
      WHERE MR_EFFECTIVITY_EXT_DTL_ID  = p_x_effty_ext_detail_tbl(i).MR_EFFECTIVITY_EXT_DTL_ID
      AND   object_version_number     = p_x_effty_ext_detail_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_FMP_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', get_ext_record_identifier( p_x_effty_ext_detail_tbl(i) ) );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Set OUT values
      p_x_effty_ext_detail_tbl(i).object_version_number := p_x_effty_ext_detail_tbl(i).object_version_number + 1;

    ELSIF ( p_x_effty_ext_detail_tbl(i).dml_operation = 'D' ) THEN

      -- Delete the record
      DELETE AHL_MR_EFFECTIVITY_EXT_DTLS
      WHERE MR_EFFECTIVITY_EXT_DTL_ID = p_x_effty_ext_detail_tbl(i).MR_EFFECTIVITY_EXT_DTL_ID
      AND   object_version_number    = p_x_effty_ext_detail_tbl(i).object_version_number;

      -- If the record does not exist, then, abort API.
      IF ( SQL%ROWCOUNT = 0 ) THEN
        FND_MESSAGE.set_name('AHL','AHL_FMP_RECORD_CHANGED');
        FND_MESSAGE.set_token( 'RECORD', TO_CHAR( i ) );
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;



  END LOOP;

  -- Perform cross records validations and duplicate records check
  validate_records
  (
    p_mr_effectivity_id, -- IN
    l_return_status -- OUT
  );

  -- If any severe error occurs, then, abort API.
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug( G_PKG_NAME || '.' || G_API_NAME || ' :  after validate_records' );
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get
  (
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data
  );

  -- Disable debug (if enabled)
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_effectivity_detail_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_effectivity_detail_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO process_effectivity_detail_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => G_API_NAME,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

    -- Disable debug (if enabled)
    IF ( G_DEBUG = 'Y' ) THEN
      AHL_DEBUG_PUB.disable_debug;
    END IF;

END process_effectivity_detail;

END AHL_FMP_EFFECTIVITY_DTL_PVT;

/
