--------------------------------------------------------
--  DDL for Package Body AHL_RM_ROUTE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_ROUTE_UTIL" AS
/* $Header: AHLVRUTB.pls 120.7.12010000.6 2009/12/31 11:13:52 pdoki ship $ */

G_PKG_NAME VARCHAR2(30) := 'AHL_RM_ROUTE_UTIL';

-- Procedure to validate Operation
PROCEDURE validate_operation
(
  x_return_status   OUT NOCOPY  VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  p_concatenated_segments IN    AHL_OPERATIONS_B_KFV.concatenated_segments%TYPE,
  p_x_operation_id    IN OUT NOCOPY AHL_OPERATIONS_B.operation_id%TYPE
)
IS

l_operation_id      AHL_OPERATIONS_B.operation_id%TYPE;

CURSOR get_rec_from_value ( c_concatenated_segments AHL_OPERATIONS_B_KFV.concatenated_segments%TYPE )
IS
SELECT DISTINCT operation_id
FROM    AHL_OPERATIONS_B_KFV
WHERE   concatenated_segments = c_concatenated_segments;

CURSOR get_rec_from_id ( c_operation_id AHL_OPERATIONS_B.operation_id%TYPE )
IS
SELECT DISTINCT operation_id
FROM    AHL_OPERATIONS_B
WHERE   operation_id = c_operation_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_concatenated_segments IS NULL OR
   p_concatenated_segments = FND_API.G_MISS_CHAR ) AND
       ( p_x_operation_id IS NULL OR
   p_x_operation_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_concatenated_segments IS NULL OR
   p_concatenated_segments = FND_API.G_MISS_CHAR ) AND
       ( p_x_operation_id IS NOT NULL AND
   p_x_operation_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_operation_id );

    FETCH get_rec_from_id INTO
      l_operation_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_OPERATON';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_concatenated_segments IS NOT NULL AND
       p_concatenated_segments <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_concatenated_segments );

    LOOP
      FETCH get_rec_from_value INTO
  l_operation_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_operation_id = p_x_operation_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_OPERATION';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_operation_id := l_operation_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_OPERATIONS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_operation;

-- Procedure to validate lookups
PROCEDURE validate_lookup
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_lookup_type    IN        FND_LOOKUPS.lookup_type%TYPE,
  p_lookup_meaning   IN        FND_LOOKUPS.meaning%TYPE,
  p_x_lookup_code  IN OUT NOCOPY FND_LOOKUPS.lookup_code%TYPE
)
IS

l_lookup_code    FND_LOOKUPS.lookup_code%TYPE;

CURSOR get_rec_from_value ( c_lookup_type FND_LOOKUPS.lookup_type%TYPE,
          c_lookup_meaning FND_LOOKUPS.meaning%TYPE )
IS
SELECT DISTINCT lookup_code
FROM    FND_LOOKUP_VALUES_VL
WHERE   lookup_type = c_lookup_type
AND   meaning = c_lookup_meaning
AND   SYSDATE BETWEEN NVL( start_date_active, SYSDATE ) AND
        NVL( end_date_active, SYSDATE );

CURSOR get_rec_from_id ( c_lookup_type FND_LOOKUPS.lookup_type%TYPE,
       c_lookup_code FND_LOOKUPS.lookup_code%TYPE )
IS
SELECT DISTINCT lookup_code
FROM    FND_LOOKUP_VALUES_VL
WHERE   lookup_type = c_lookup_type
AND   lookup_code = c_lookup_code
AND   SYSDATE BETWEEN NVL( start_date_active, SYSDATE ) AND
        NVL( end_date_active, SYSDATE );

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_lookup_type IS NULL OR
       p_lookup_type = FND_API.G_MISS_CHAR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_lookup_meaning IS NULL OR
   p_lookup_meaning = FND_API.G_MISS_CHAR ) AND
       ( p_x_lookup_code IS NULL OR
   p_x_lookup_code = FND_API.G_MISS_CHAR ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_lookup_meaning IS NULL OR
   p_lookup_meaning = FND_API.G_MISS_CHAR ) AND
       ( p_x_lookup_code IS NOT NULL AND
   p_x_lookup_code <> FND_API.G_MISS_CHAR ) ) THEN

    OPEN get_rec_from_id( p_lookup_type, p_x_lookup_code );

    FETCH get_rec_from_id INTO
      l_lookup_code;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_LOOKUP';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_lookup_meaning IS NOT NULL AND
       p_lookup_meaning <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_lookup_type, p_lookup_meaning );

    LOOP
      FETCH get_rec_from_value INTO
  l_lookup_code;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_lookup_code = p_x_lookup_code ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_LOOKUP';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_lookup_code := l_lookup_code;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_TOO_MANY_LOOKUPS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_lookup;

-- Procedure to validate Operator
PROCEDURE validate_operator
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_operator_name  IN        HZ_PARTIES.party_name%TYPE,
  p_x_operator_party_id  IN OUT NOCOPY NUMBER
)
IS

l_operator_party_id  HZ_PARTIES.party_id%TYPE;

CURSOR get_rec_from_value ( c_operator_name HZ_PARTIES.party_name%TYPE )
IS
SELECT DISTINCT party_id
FROM    HZ_PARTIES
WHERE   party_name = c_operator_name;

CURSOR get_rec_from_id ( c_operator_party_id NUMBER )
IS
SELECT DISTINCT party_id
FROM    HZ_PARTIES
WHERE   party_id = c_operator_party_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_operator_name IS NULL OR
   p_operator_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_operator_party_id IS NULL OR
   p_x_operator_party_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_operator_name IS NULL OR
   p_operator_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_operator_party_id IS NOT NULL AND
   p_x_operator_party_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_operator_party_id );

    FETCH get_rec_from_id INTO
      l_operator_party_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_OPERATOR';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_operator_name IS NOT NULL AND
       p_operator_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_operator_name );

    LOOP
      FETCH get_rec_from_value INTO
  l_operator_party_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_operator_party_id = p_x_operator_party_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_OPERATOR';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_operator_party_id := l_operator_party_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_OPERATORS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_operator;

-- Procedure to validate Item
PROCEDURE validate_adt_item
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_item_number    IN        MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
  p_x_inventory_item_id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
  p_x_inventory_org_id   IN OUT NOCOPY MTL_SYSTEM_ITEMS.organization_id%TYPE
)
IS

l_inventory_item_flag   MTL_SYSTEM_ITEMS.inventory_item_flag%TYPE;
l_inventory_item_id   MTL_SYSTEM_ITEMS.inventory_item_id%TYPE;
l_inventory_org_id    MTL_SYSTEM_ITEMS.organization_id%TYPE;

CURSOR get_rec_from_value ( c_item_number MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE ,
          c_inventory_org_id  MTL_SYSTEM_ITEMS.organization_id%TYPE)
IS
--AMSRINIV. Bug 4913429. Doing away with the use of 'upper' to tune below query.
SELECT
mtl.INVENTORY_ITEM_ID ,
mtl.organization_id ,
mtl.inventory_item_flag
from
AHL_MTL_ITEMS_EAM_V mtl
where
MTL.inventory_item_flag = 'Y'
AND mtl.enabled_flag = 'Y'
and mtl.concatenated_segments like c_item_number
and mtl.organization_id = c_inventory_org_id
order by 1;
/*
SELECT DISTINCT MI.inventory_item_id,
    MI.organization_id,
    NVL(MI.inventory_item_flag,'X')
FROM    MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE   MP.organization_id = MI.organization_id
AND   MI.concatenated_segments = c_item_number
AND   MI.organization_id = c_inventory_org_id
AND   MI.enabled_flag = 'Y'
AND   SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
      AND NVL( MI.end_date_active, SYSDATE )
AND DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',MP.eam_enabled_flag )='Y';
*//*
SELECT DISTINCT
mtl.INVENTORY_ITEM_ID ,
mtl.organization_id ,
NVL(mtl.inventory_item_flag,'X')
from
MTL_SYSTEM_ITEMS_KFV MTL
, fnd_lookup_values_vl IT
, MTL_PARAMETERS MP
where
DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',mp.eam_enabled_flag )='Y'
AND MTL.ORGANIZATION_ID = MP.MASTER_ORGANIZATION_ID
and MTL.inventory_item_flag = 'Y'
AND IT.lookup_code (+) = MTL.item_type
AND IT.lookup_type (+) = 'ITEM_TYPE'
AND mtl.enabled_flag = 'Y'
AND SYSDATE BETWEEN NVL( mtl.start_date_active, SYSDATE )
AND NVL( mtl.end_date_active, SYSDATE )
and upper(mtl.concatenated_segments) like upper(c_item_number)
and mtl.organization_id = c_inventory_org_id
order by 1;
*/
CURSOR get_rec_from_id ( c_inventory_item_id MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
       c_inventory_org_id  MTL_SYSTEM_ITEMS.organization_id%TYPE )
IS
SELECT
mtl.INVENTORY_ITEM_ID ,
mtl.organization_id ,
mtl.inventory_item_flag
from AHL_MTL_ITEMS_EAM_V mtl
where
MTL.inventory_item_flag = 'Y'
AND mtl.enabled_flag = 'Y'
and mtl.inventory_item_id = c_inventory_item_id
and mtl.organization_id = c_inventory_org_id
order by 1;
/*
SELECT DISTINCT MI.inventory_item_id,
    MI.organization_id,
    NVL(MI.inventory_item_flag,'X')
FROM    MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',MP.eam_enabled_flag )='Y'
AND   MP.organization_id = MI.organization_id
AND   MI.inventory_item_id = c_inventory_item_id
AND   MI.organization_id = c_inventory_org_id
AND   MI.enabled_flag = 'Y'
AND   SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
      AND NVL( MI.end_date_active, SYSDATE );
*//*
SELECT DISTINCT
mtl.INVENTORY_ITEM_ID ,
mtl.organization_id ,
NVL(mtl.inventory_item_flag,'X')
from MTL_SYSTEM_ITEMS_KFV MTL
, MTL_PARAMETERS MP
, fnd_lookup_values_vl IT
where
DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',mp.eam_enabled_flag )='Y'
AND MTL.ORGANIZATION_ID = MP.MASTER_ORGANIZATION_ID
and MTL.inventory_item_flag = 'Y'
AND IT.lookup_code (+) = MTL.item_type
AND IT.lookup_type (+) = 'ITEM_TYPE'
AND mtl.enabled_flag = 'Y'
AND SYSDATE BETWEEN NVL( mtl.start_date_active, SYSDATE )
AND NVL( mtl.end_date_active, SYSDATE )
and mtl.inventory_item_id = c_inventory_item_id
and mtl.organization_id = c_inventory_org_id
order by 1;
*/


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_item_number IS NULL OR
   p_item_number = FND_API.G_MISS_CHAR ) AND
       ( p_x_inventory_item_id IS NULL OR
   p_x_inventory_item_id = FND_API.G_MISS_NUM ) AND
       ( p_x_inventory_org_id IS NULL OR
   p_x_inventory_org_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_item_number IS NULL OR
   p_item_number = FND_API.G_MISS_CHAR ) AND
       ( p_x_inventory_item_id IS NOT NULL AND
   p_x_inventory_item_id <> FND_API.G_MISS_NUM AND
   p_x_inventory_org_id IS NOT NULL AND
   p_x_inventory_org_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_inventory_item_id , p_x_inventory_org_id );

    FETCH get_rec_from_id INTO
      l_inventory_item_id,
      l_inventory_org_id,
      l_inventory_item_flag;

    IF ( get_rec_from_id%NOTFOUND ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_ITEM';
    ELSE
      IF ( l_inventory_item_flag = 'N' ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_NOT_COMPONENT_ITEM';
      END IF;
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_item_number IS NOT NULL AND
       p_item_number <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_item_number , p_x_inventory_org_id);

    LOOP
      FETCH get_rec_from_value INTO
  l_inventory_item_id,
  l_inventory_org_id,
  l_inventory_item_flag;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_inventory_item_id = p_x_inventory_item_id AND
     l_inventory_org_id = p_x_inventory_org_id AND
     l_inventory_item_flag = 'Y' ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_ITEM';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      IF ( l_inventory_item_flag = 'N' ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_NOT_COMPONENT_ITEM';
      ELSE
  p_x_inventory_item_id := l_inventory_item_id;
  p_x_inventory_org_id := l_inventory_org_id;
      END IF;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_TOO_MANY_ITEMS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_adt_item;


-- Procedure to validate Item
PROCEDURE validate_item
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_item_number    IN        MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
  p_x_inventory_item_id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
  p_x_inventory_org_id   IN OUT NOCOPY MTL_SYSTEM_ITEMS.organization_id%TYPE
)
IS

l_inventory_item_flag   MTL_SYSTEM_ITEMS.inventory_item_flag%TYPE;
--l_wip_supply_type   MTL_SYSTEM_ITEMS.wip_supply_type%TYPE; --pdoki commented for Bug 8589785
l_stock_enabled_flag    MTL_SYSTEM_ITEMS.stock_enabled_flag%TYPE;
l_mtl_txns_enabled_flag MTL_SYSTEM_ITEMS.mtl_transactions_enabled_flag%TYPE;
l_inventory_item_id   MTL_SYSTEM_ITEMS.inventory_item_id%TYPE;
l_inventory_org_id    MTL_SYSTEM_ITEMS.organization_id%TYPE;

CURSOR get_rec_from_value ( c_item_number MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE ,
          c_inventory_org_id  MTL_SYSTEM_ITEMS.organization_id%TYPE)
IS
SELECT DISTINCT MTL.inventory_item_id,
    MTL.organization_id,
    MTL.inventory_item_flag,
    MTL.mtl_transactions_enabled_flag,
    MTL.stock_enabled_flag
    --NVL(MTL.wip_supply_type,0) --pdoki commented for Bug 8589785
FROM    AHL_MTL_ITEMS_EAM_V MTL
WHERE
MTL.concatenated_segments = c_item_number
AND   MTL.organization_id = c_inventory_org_id
AND   MTL.enabled_flag = 'Y';
/*
SELECT DISTINCT MI.inventory_item_id,
--      MI.organization_id,
    MP.master_organization_id,
    NVL(MI.inventory_item_flag,'X'),
    NVL(MI.mtl_transactions_enabled_flag,'X'),
    NVL(MI.stock_enabled_flag,'X'),
    NVL(MI.wip_supply_type,0)
FROM    MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',MP.eam_enabled_flag )='Y'
AND   MP.master_organization_id = MI.organization_id
AND   MI.concatenated_segments = c_item_number
--AND     MI.organization_id = c_inventory_org_id
AND   MP.master_organization_id = c_inventory_org_id
AND   MI.enabled_flag = 'Y'
AND   SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
      AND NVL( MI.end_date_active, SYSDATE );
*/
/*
SELECT DISTINCT
mtl.inventory_item_id ,
mtl.inventory_org_id ,
NVL(mtl.inventory_item_flag,'X'),
NVL(mtl.mtl_transactions_enabled_flag,'X'),
NVL(mtl.stock_enabled_flag,'X'),
NVL(mtl.wip_supply_type,0)
from ahl_mtl_items_non_ou_v mtl
where
DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',mtl.eam_enabled_flag )='Y'
AND   mtl.enabled_flag = 'Y'
AND   SYSDATE BETWEEN NVL( mtl.start_date_active, SYSDATE )
      AND NVL( mtl.end_date_active, SYSDATE )
and upper(mtl.concatenated_segments) like upper(c_item_number)
and mtl.inventory_org_id = c_inventory_org_id
order by 1;
*/
--
CURSOR get_rec_from_id ( c_inventory_item_id MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
       c_inventory_org_id  MTL_SYSTEM_ITEMS.organization_id%TYPE )
IS
SELECT DISTINCT MTL.inventory_item_id,
    MTL.organization_id,
    MTL.inventory_item_flag,
    MTL.mtl_transactions_enabled_flag,
    MTL.stock_enabled_flag
   -- NVL(MTL.wip_supply_type,0) --pdoki commented for Bug 8589785
FROM    AHL_MTL_ITEMS_EAM_V MTL
WHERE
    MTL.inventory_item_id = c_inventory_item_id
AND  MTL.organization_id = c_inventory_org_id
AND   MTL.enabled_flag = 'Y';
/*
SELECT DISTINCT MI.inventory_item_id,
--      MI.organization_id,
    MP.master_organization_id,
    NVL(MI.inventory_item_flag,'X'),
    NVL(MI.mtl_transactions_enabled_flag,'X'),
    NVL(MI.stock_enabled_flag,'X'),
    NVL(MI.wip_supply_type,0)
FROM    MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',MP.eam_enabled_flag )='Y'
AND   MP.master_organization_id = MI.organization_id
AND   MI.inventory_item_id = c_inventory_item_id
--AND     MI.organization_id = c_inventory_org_id
AND   MP.master_organization_id = c_inventory_org_id
AND   MI.enabled_flag = 'Y'
AND   SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
      AND NVL( MI.end_date_active, SYSDATE );
      */
/*
SELECT DISTINCT
mtl.inventory_item_id ,
mtl.inventory_org_id ,
NVL(mtl.inventory_item_flag,'X'),
NVL(mtl.mtl_transactions_enabled_flag,'X'),
NVL(mtl.stock_enabled_flag,'X'),
NVL(mtl.wip_supply_type,0)
from ahl_mtl_items_non_ou_v mtl
where
DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',mtl.eam_enabled_flag )='Y'
AND   mtl.enabled_flag = 'Y'
AND   SYSDATE BETWEEN NVL( mtl.start_date_active, SYSDATE )
      AND NVL( mtl.end_date_active, SYSDATE )
and mtl.inventory_item_id = c_inventory_item_id
and mtl.inventory_org_id = c_inventory_org_id
order by 1;
*/

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_item_number IS NULL OR
   p_item_number = FND_API.G_MISS_CHAR ) AND
       ( p_x_inventory_item_id IS NULL OR
   p_x_inventory_item_id = FND_API.G_MISS_NUM ) AND
       ( p_x_inventory_org_id IS NULL OR
   p_x_inventory_org_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_item_number IS NULL OR
   p_item_number = FND_API.G_MISS_CHAR ) AND
       ( p_x_inventory_item_id IS NOT NULL AND
   p_x_inventory_item_id <> FND_API.G_MISS_NUM AND
   p_x_inventory_org_id IS NOT NULL AND
   p_x_inventory_org_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_inventory_item_id , p_x_inventory_org_id );

    FETCH get_rec_from_id INTO
      l_inventory_item_id,
      l_inventory_org_id,
      l_inventory_item_flag,
      l_mtl_txns_enabled_flag,
      l_stock_enabled_flag ;
      --l_wip_supply_type; --pdoki commented for Bug 8589785

    IF ( get_rec_from_id%NOTFOUND ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_ITEM';
    ELSE
      IF ( l_inventory_item_flag = 'N' OR
     l_mtl_txns_enabled_flag = 'N' OR
     l_stock_enabled_flag = 'N' ) THEN

  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_NOT_COMPONENT_ITEM';
      END IF;
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_item_number IS NOT NULL AND
       p_item_number <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_item_number , p_x_inventory_org_id);

-- JKJain, bug 8766220 , Loop not required as cursor is expected to return only one row. That is the reason to add DISTINCT in the two cursors.
--    LOOP
      FETCH get_rec_from_value INTO
  l_inventory_item_id,
  l_inventory_org_id,
  l_inventory_item_flag,
  l_mtl_txns_enabled_flag,
  l_stock_enabled_flag ;
 -- l_wip_supply_type; --pdoki commented for Bug 8589785

--     EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_inventory_item_id = p_x_inventory_item_id AND
     l_inventory_org_id = p_x_inventory_org_id AND
     l_inventory_item_flag = 'Y' AND
     l_mtl_txns_enabled_flag = 'Y' AND
     l_stock_enabled_flag = 'Y' ) THEN

  CLOSE get_rec_from_value;
  RETURN;
      END IF;

--    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_ITEM';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      IF ( l_inventory_item_flag = 'N' OR
     l_stock_enabled_flag = 'N' OR
     l_mtl_txns_enabled_flag = 'N' ) THEN

  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_NOT_COMPONENT_ITEM';
      ELSE
  p_x_inventory_item_id := l_inventory_item_id;
  p_x_inventory_org_id := l_inventory_org_id;
      END IF;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_TOO_MANY_ITEMS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_item;

-- Procedure to validate Service Item
PROCEDURE validate_service_item
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_item_number    IN        MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
  p_x_inventory_item_id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
  p_x_inventory_org_id   IN OUT NOCOPY MTL_SYSTEM_ITEMS.organization_id%TYPE
)
IS

l_outside_operation_flag  MTL_SYSTEM_ITEMS.outside_operation_flag%TYPE;
l_purchasing_enabled_flag MTL_SYSTEM_ITEMS.purchasing_enabled_flag%TYPE;
l_purchasing_item_flag    MTL_SYSTEM_ITEMS.purchasing_item_flag%TYPE;
l_inventory_item_id   MTL_SYSTEM_ITEMS.inventory_item_id%TYPE;
l_inventory_org_id    MTL_SYSTEM_ITEMS.organization_id%TYPE;

CURSOR get_rec_from_value ( c_item_number MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE )
IS
SELECT DISTINCT MI.inventory_item_id,
    MI.organization_id,
    MI.outside_operation_flag,
    MI.purchasing_item_flag,
    MI.purchasing_enabled_flag
FROM    MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',MP.eam_enabled_flag )='Y'
AND   MP.organization_id = MI.organization_id
AND   MI.concatenated_segments = c_item_number
AND   MI.enabled_flag = 'Y'
AND   SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
      AND NVL( MI.end_date_active, SYSDATE );

CURSOR get_rec_from_id ( c_inventory_item_id MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
       c_inventory_org_id  MTL_SYSTEM_ITEMS.organization_id%TYPE )
IS
SELECT DISTINCT MI.inventory_item_id,
    MI.organization_id,
    MI.outside_operation_flag,
    MI.purchasing_item_flag,
    MI.purchasing_enabled_flag
FROM    MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',MP.eam_enabled_flag )='Y'
AND   MP.organization_id = MI.organization_id
AND   MI.inventory_item_id = c_inventory_item_id
AND   MI.organization_id = c_inventory_org_id
AND   MI.enabled_flag = 'Y'
AND   SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
      AND NVL( MI.end_date_active, SYSDATE );

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_item_number IS NULL OR
   p_item_number = FND_API.G_MISS_CHAR ) AND
       ( p_x_inventory_item_id IS NULL OR
   p_x_inventory_item_id = FND_API.G_MISS_NUM ) AND
       ( p_x_inventory_org_id IS NULL OR
   p_x_inventory_org_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_item_number IS NULL OR
   p_item_number = FND_API.G_MISS_CHAR ) AND
       ( p_x_inventory_item_id IS NOT NULL AND
   p_x_inventory_item_id <> FND_API.G_MISS_NUM AND
   p_x_inventory_org_id IS NOT NULL AND
   p_x_inventory_org_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_inventory_item_id , p_x_inventory_org_id );

    FETCH get_rec_from_id INTO
      l_inventory_item_id,
      l_inventory_org_id,
      l_outside_operation_flag,
      l_purchasing_item_flag,
      l_purchasing_enabled_flag;

    IF ( get_rec_from_id%NOTFOUND ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_ITEM';
    ELSE
      IF ( l_outside_operation_flag = 'Y' OR
     l_purchasing_item_flag = 'N' OR
     l_purchasing_enabled_flag = 'N' ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_NOT_SERVICE_ITEM';
      END IF;
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_item_number IS NOT NULL AND
       p_item_number <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_item_number );

    LOOP
      FETCH get_rec_from_value INTO
  l_inventory_item_id,
  l_inventory_org_id,
  l_outside_operation_flag,
  l_purchasing_item_flag,
  l_purchasing_enabled_flag;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_inventory_item_id = p_x_inventory_item_id AND
     l_inventory_org_id = p_x_inventory_org_id AND
     l_outside_operation_flag = 'N' AND
     l_purchasing_item_flag = 'Y' AND
     l_purchasing_enabled_flag = 'Y' ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_ITEM';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      IF ( l_outside_operation_flag = 'Y' OR
     l_purchasing_enabled_flag = 'N' OR
     l_purchasing_item_flag = 'N' ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_NOT_SERVICE_ITEM';
      ELSE
  p_x_inventory_item_id := l_inventory_item_id;
  p_x_inventory_org_id := l_inventory_org_id;
      END IF;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_TOO_MANY_ITEMS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_service_item;

-- Procedure to validate Effectivity Item
PROCEDURE validate_effectivity_item
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_item_number    IN        MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
  p_org_code     IN        MTL_PARAMETERS.ORGANIZATION_CODE%TYPE,
  p_x_inventory_item_id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
  p_x_inventory_org_id   IN OUT NOCOPY MTL_SYSTEM_ITEMS.organization_id%TYPE
)
IS

l_comms_nl_trackable_flag  MTL_SYSTEM_ITEMS.COMMS_NL_TRACKABLE_FLAG%TYPE;
l_inventory_item_id    MTL_SYSTEM_ITEMS.inventory_item_id%TYPE;
l_inventory_org_id     MTL_SYSTEM_ITEMS.organization_id%TYPE;

CURSOR get_rec_from_value ( c_item_number MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
          c_org_code    MTL_PARAMETERS.ORGANIZATION_CODE%TYPE)
IS
SELECT
MTL.INVENTORY_ITEM_ID ,
MTL.organization_id ,
MTL.comms_nl_trackable_flag
from   AHL_MTL_ITEMS_EAM_V MTL
where
upper(nvl(MTL.comms_nl_trackable_flag,'N')) = 'Y'
and MTL.enabled_flag = 'Y'
and upper(MTL.concatenated_segments) like upper(c_item_number)
and upper(MTL.organization_code) like upper(c_org_code)
order by 1;
/*
SELECT DISTINCT MI.inventory_item_id,
    MP.master_organization_id,
    MI.comms_nl_trackable_flag
FROM    MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE   MP.master_organization_id = MI.organization_id
AND   upper(MI.concatenated_segments) = upper(c_item_number)
AND   MI.enabled_flag = 'Y'
AND   upper(MP.ORGANIZATION_CODE)=upper(c_org_code)
AND   SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
      AND NVL( MI.end_date_active, SYSDATE )
AND DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',MP.eam_enabled_flag )='Y';
*/
/*
SELECT DISTINCT
mtl.INVENTORY_ITEM_ID ,
mtl.organization_id ,
mtl.comms_nl_trackable_flag
from MTL_SYSTEM_ITEMS_KFV MTL
, MTL_PARAMETERS MP
, MTL_PARAMETERS MP1
, fnd_lookup_values_vl IT
where
DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',mp.eam_enabled_flag )='Y'
AND MTL.ORGANIZATION_ID = MP.MASTER_ORGANIZATION_ID
and MP.MASTER_ORGANIZATION_ID = MP1.ORGANIZATION_ID
and sysdate between nvl( MTL.start_date_active, sysdate )
and nvl( MTL.end_date_active, sysdate )
and IT.lookup_code (+) = MTL.item_type
and IT.lookup_type (+) = 'ITEM_TYPE'
and MTL.enabled_flag = 'Y'
and upper(mtl.concatenated_segments) like upper(c_item_number)
and upper(mp1.organization_code) like upper(c_org_code)
order by 1;
*/

CURSOR get_rec_from_id ( c_inventory_item_id MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
       c_inventory_org_id  MTL_SYSTEM_ITEMS.organization_id%TYPE )
IS
SELECT
mtl.INVENTORY_ITEM_ID ,
mtl.organization_id ,
mtl.comms_nl_trackable_flag
from   AHL_MTL_ITEMS_EAM_V MTL
where
upper(nvl(MTL.comms_nl_trackable_flag,'N')) = 'Y'
and MTL.enabled_flag = 'Y'
and mtl.inventory_item_id = c_inventory_item_id
and mtl.organization_id = c_inventory_org_id
order by 1;
/*
SELECT DISTINCT MI.inventory_item_id,
    MP.master_organization_id,
    MI.comms_nl_trackable_flag
FROM    MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE   MP.master_organization_id = MI.organization_id
AND   MI.inventory_item_id = c_inventory_item_id
AND   MI.organization_id = c_inventory_org_id
AND   MI.enabled_flag = 'Y'
AND   SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
      AND NVL( MI.end_date_active, SYSDATE )
AND DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',MP.eam_enabled_flag )='Y';
*/
/*SELECT DISTINCT
mtl.INVENTORY_ITEM_ID ,
mtl.organization_id ,
mtl.comms_nl_trackable_flag
from MTL_SYSTEM_ITEMS_KFV MTL
, MTL_PARAMETERS MP
, fnd_lookup_values_vl IT
where
DECODE(AHL_UTIL_PKG.IS_PM_INSTALLED,'Y','Y',mp.eam_enabled_flag )='Y'
AND MTL.ORGANIZATION_ID = MP.MASTER_ORGANIZATION_ID
and sysdate between nvl( MTL.start_date_active, sysdate )
and nvl( MTL.end_date_active, sysdate )
and IT.lookup_code (+) = MTL.item_type
and IT.lookup_type (+) = 'ITEM_TYPE'
and MTL.enabled_flag = 'Y'
and mtl.inventory_item_id = c_inventory_item_id
and mtl.organization_id = c_inventory_org_id
order by 1;
*/


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_item_number IS NULL OR
   p_item_number = FND_API.G_MISS_CHAR ) AND
       ( p_x_inventory_item_id IS NULL OR
   p_x_inventory_item_id = FND_API.G_MISS_NUM ) AND
       ( p_x_inventory_org_id IS NULL OR
   p_x_inventory_org_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( (
     ( p_item_number IS NULL OR p_item_number = FND_API.G_MISS_CHAR )
  OR ( p_org_code IS NULL OR p_org_code = FND_API.G_MISS_CHAR )
  )
      AND
       (
     ( p_x_inventory_item_id IS NOT NULL AND p_x_inventory_item_id <> FND_API.G_MISS_NUM )
       AND ( p_x_inventory_org_id IS NOT NULL AND p_x_inventory_org_id <> FND_API.G_MISS_NUM )
       )
      ) THEN

    OPEN get_rec_from_id( p_x_inventory_item_id , p_x_inventory_org_id );

    FETCH get_rec_from_id INTO
      l_inventory_item_id,
      l_inventory_org_id,
      l_comms_nl_trackable_flag;

    IF ( get_rec_from_id%NOTFOUND ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_ITEM';
    ELSE
      IF ( l_comms_nl_trackable_flag = 'N' ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_NOT_effectivity_ITEM';
      END IF;
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( (p_item_number IS NOT NULL AND p_item_number <> FND_API.G_MISS_CHAR )
    AND(p_org_code IS NOT NULL AND p_item_number <> FND_API.G_MISS_CHAR)
     ) THEN

    OPEN get_rec_from_value( p_item_number, p_org_code);

    LOOP
      FETCH get_rec_from_value INTO
  l_inventory_item_id,
  l_inventory_org_id,
  l_comms_nl_trackable_flag;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_inventory_item_id = p_x_inventory_item_id AND
     l_inventory_org_id = p_x_inventory_org_id AND
     l_comms_nl_trackable_flag = 'Y' ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_ITEM';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      IF ( l_comms_nl_trackable_flag = 'N' ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_NOT_effectivity_ITEM';
      ELSE
  p_x_inventory_item_id := l_inventory_item_id;
  p_x_inventory_org_id := l_inventory_org_id;
      END IF;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_TOO_MANY_ITEMS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_effectivity_item;

-- Procedure to validate Accounting class
PROCEDURE validate_accounting_class
(
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_data          OUT NOCOPY    VARCHAR2,
  p_accounting_class        IN      WIP_ACCOUNTING_CLASSES.description%TYPE,
  p_x_accounting_class_code   IN OUT NOCOPY WIP_ACCOUNTING_CLASSES.class_code%TYPE,
  p_x_accounting_class_org_id IN OUT NOCOPY WIP_ACCOUNTING_CLASSES.organization_id%TYPE
)
IS

l_accounting_class_code      WIP_ACCOUNTING_CLASSES.class_code%TYPE;
l_accounting_class_org_id    WIP_ACCOUNTING_CLASSES.organization_id%TYPE;

CURSOR get_rec_from_value ( c_accounting_class WIP_ACCOUNTING_CLASSES.description%TYPE )
IS
SELECT DISTINCT class_code,
    organization_id
FROM    WIP_ACCOUNTING_CLASSES
WHERE   description = c_accounting_class
AND   class_type = 6;

CURSOR get_rec_from_id ( c_accounting_class_code WIP_ACCOUNTING_CLASSES.class_code%TYPE ,
       c_accounting_class_org_id WIP_ACCOUNTING_CLASSES.organization_id%TYPE )
IS
SELECT DISTINCT class_code,
    organization_id
FROM    WIP_ACCOUNTING_CLASSES
WHERE   class_code = c_accounting_class_code
AND   organization_id = c_accounting_class_org_id
AND   class_type = 6;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_accounting_class IS NULL OR
   p_accounting_class = FND_API.G_MISS_CHAR ) AND
       ( p_x_accounting_class_code IS NULL OR
   p_x_accounting_class_code = FND_API.G_MISS_CHAR ) AND
       ( p_x_accounting_class_org_id IS NULL OR
   p_x_accounting_class_org_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_accounting_class IS NULL OR
   p_accounting_class = FND_API.G_MISS_CHAR ) AND
       ( p_x_accounting_class_code IS NOT NULL AND
   p_x_accounting_class_code <> FND_API.G_MISS_CHAR AND
   p_x_accounting_class_org_id IS NOT NULL AND
   p_x_accounting_class_org_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_accounting_class_code , p_x_accounting_class_org_id );

    FETCH get_rec_from_id INTO
      l_accounting_class_code,
      l_accounting_class_org_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_ACC_CLASS';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_accounting_class IS NOT NULL AND
       p_accounting_class <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_accounting_class );

    LOOP
      FETCH get_rec_from_value INTO
  l_accounting_class_code,
  l_accounting_class_org_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_accounting_class_code = p_x_accounting_class_code AND
     l_accounting_class_org_id = p_x_accounting_class_org_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_ACC_CLASS';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_accounting_class_code := l_accounting_class_code;
      p_x_accounting_class_org_id := l_accounting_class_org_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_ACC_CLASSES';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;
END validate_accounting_class;

-- Procedure to validate Task Template Group
PROCEDURE validate_task_template_group
(
  x_return_status      OUT NOCOPY    VARCHAR2,
  x_msg_data         OUT NOCOPY    VARCHAR2,
  p_task_template_group      IN      JTF_TASK_TEMP_GROUPS_VL.template_group_name%TYPE,
  p_x_task_template_group_id IN OUT NOCOPY JTF_TASK_TEMP_GROUPS_VL.task_template_group_id%TYPE
)
IS

l_task_template_group_id    JTF_TASK_TEMP_GROUPS_VL.task_template_group_id%TYPE;

CURSOR get_rec_from_value ( c_task_template_group JTF_TASK_TEMP_GROUPS_VL.template_group_name%TYPE )
IS
SELECT DISTINCT task_template_group_id
FROM    JTF_TASK_TEMP_GROUPS_VL
WHERE    trunc(sysdate) >= trunc(nvl(start_date_active, sysdate)) and
           trunc(sysdate) < trunc(nvl(end_date_active, sysdate+1)) and
           template_group_name = c_task_template_group;

CURSOR get_rec_from_id ( c_task_template_group_id JTF_TASK_TEMP_GROUPS_VL.task_template_group_id%TYPE )
IS
SELECT DISTINCT task_template_group_id
FROM    JTF_TASK_TEMP_GROUPS_VL
WHERE   trunc(sysdate) >= trunc(nvl(start_date_active, sysdate)) and
           trunc(sysdate) < trunc(nvl(end_date_active, sysdate+1)) and
           task_template_group_id = c_task_template_group_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_task_template_group IS NULL OR
   p_task_template_group = FND_API.G_MISS_CHAR ) AND
       ( p_x_task_template_group_id IS NULL OR
   p_x_task_template_group_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_task_template_group IS NULL OR
   p_task_template_group = FND_API.G_MISS_CHAR ) AND
       ( p_x_task_template_group_id IS NOT NULL AND
   p_x_task_template_group_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_task_template_group_id );

    FETCH get_rec_from_id INTO
      l_task_template_group_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_TASK_TEMPLATE';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_task_template_group IS NOT NULL AND
       p_task_template_group <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_task_template_group );

    LOOP
      FETCH get_rec_from_value INTO
  l_task_template_group_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_task_template_group_id = p_x_task_template_group_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_TASK_TEMPLATE';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_task_template_group_id := l_task_template_group_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_TASK_TEMPLATES';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_task_template_group;

-- Procedure to validate QA Inspection Type
PROCEDURE validate_qa_inspection_type
(
  x_return_status     OUT NOCOPY    VARCHAR2,
  x_msg_data        OUT NOCOPY    VARCHAR2,
  p_qa_inspection_type_desc IN      QA_CHAR_VALUE_LOOKUPS_V.description%TYPE,
  p_x_qa_inspection_type    IN OUT NOCOPY QA_CHAR_VALUE_LOOKUPS_V.short_code%TYPE
)
IS

l_qa_inspection_type   QA_CHAR_VALUE_LOOKUPS_V.short_code%TYPE;

CURSOR get_rec_from_value ( c_qa_inspection_type_desc QA_CHAR_VALUE_LOOKUPS_V.description%TYPE )
IS
SELECT DISTINCT short_code
FROM    QA_CHAR_VALUE_LOOKUPS_V
WHERE   description = c_qa_inspection_type_desc;

CURSOR get_rec_from_id ( c_qa_inspection_type QA_CHAR_VALUE_LOOKUPS_V.short_code%TYPE )
IS
SELECT DISTINCT short_code
FROM    QA_CHAR_VALUE_LOOKUPS_V
WHERE   short_code = c_qa_inspection_type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_qa_inspection_type_desc IS NULL OR
   p_qa_inspection_type_desc = FND_API.G_MISS_CHAR ) AND
       ( p_x_qa_inspection_type IS NULL OR
   p_x_qa_inspection_type = FND_API.G_MISS_CHAR ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_qa_inspection_type_desc IS NULL OR
   p_qa_inspection_type_desc = FND_API.G_MISS_CHAR ) AND
       ( p_x_qa_inspection_type IS NOT NULL AND
   p_x_qa_inspection_type <> FND_API.G_MISS_CHAR ) ) THEN

    OPEN get_rec_from_id( p_x_qa_inspection_type );

    FETCH get_rec_from_id INTO
      l_qa_inspection_type;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_INSP_TYPE';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_qa_inspection_type_desc IS NOT NULL AND
       p_qa_inspection_type_desc <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_qa_inspection_type_desc );

    LOOP
      FETCH get_rec_from_value INTO
  l_qa_inspection_type;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_qa_inspection_type = p_x_qa_inspection_type ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_INSP_TYPE';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_qa_inspection_type := l_qa_inspection_type;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_INSP_TYPES';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_qa_inspection_type;

-- Procedure to validate QA Plan
PROCEDURE validate_qa_plan
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_qa_plan    IN        QA_PLANS_VAL_V.name%TYPE,
  p_x_qa_plan_id   IN OUT NOCOPY QA_PLANS_VAL_V.plan_id%TYPE
)
IS

l_qa_plan_id     QA_PLANS_VAL_V.plan_id%TYPE;

CURSOR get_rec_from_value ( c_qa_plan QA_PLANS_VAL_V.name%TYPE )
IS
SELECT DISTINCT plan_id
FROM    QA_PLANS_VAL_V
WHERE   name = c_qa_plan;

CURSOR get_rec_from_id ( c_qa_plan_id QA_PLANS_VAL_V.plan_id%TYPE )
IS
SELECT DISTINCT plan_id
FROM    QA_PLANS_VAL_V
WHERE   plan_id = c_qa_plan_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_qa_plan IS NULL OR
   p_qa_plan = FND_API.G_MISS_CHAR ) AND
       ( p_x_qa_plan_id IS NULL OR
   p_x_qa_plan_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_qa_plan IS NULL OR
   p_qa_plan = FND_API.G_MISS_CHAR ) AND
       ( p_x_qa_plan_id IS NOT NULL AND
   p_x_qa_plan_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_qa_plan_id );

    FETCH get_rec_from_id INTO
      l_qa_plan_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_QA_PLAN';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_qa_plan IS NOT NULL AND
       p_qa_plan <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_qa_plan );

    LOOP
      FETCH get_rec_from_value INTO
  l_qa_plan_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_qa_plan_id = p_x_qa_plan_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_QA_PLAN';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_qa_plan_id := l_qa_plan_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_QA_PLANS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_qa_plan;

-- Procedure to valiadate the Item Group
PROCEDURE validate_item_group
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_association_type   IN        VARCHAR2,
  p_item_group_name  IN        AHL_ITEM_GROUPS_VL.name%TYPE,
  p_x_item_group_id  IN OUT NOCOPY AHL_ITEM_GROUPS_VL.item_group_id%TYPE
)
IS

l_item_group_id      AHL_ITEM_GROUPS_VL.item_group_id%TYPE;

CURSOR get_rec_from_value ( c_item_group_name AHL_ITEM_GROUPS_VL.name%TYPE , c_association_type   VARCHAR2)
IS
SELECT DISTINCT item_group_id
FROM    AHL_ITEM_GROUPS_VL
WHERE   name = c_item_group_name
AND   DECODE(c_association_type,'DISPOSITION',TYPE_CODE,'NON-TRACKED')='NON-TRACKED';

CURSOR get_rec_from_id ( c_item_group_id AHL_ITEM_GROUPS_VL.item_group_id%TYPE , c_association_type   VARCHAR2)
IS
SELECT DISTINCT item_group_id
FROM    AHL_ITEM_GROUPS_VL
WHERE   item_group_id = c_item_group_id
AND   DECODE(c_association_type,'DISPOSITION',TYPE_CODE,'NON-TRACKED')='NON-TRACKED';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_item_group_name IS NULL OR
   p_item_group_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_item_group_id IS NULL OR
   p_x_item_group_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_item_group_name IS NULL OR
   p_item_group_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_item_group_id IS NOT NULL AND
   p_x_item_group_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_item_group_id,p_association_type );

    FETCH get_rec_from_id INTO
      l_item_group_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_ITEM_GRP';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_item_group_name IS NOT NULL AND
       p_item_group_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_item_group_name,p_association_type );

    LOOP
      FETCH get_rec_from_value INTO
  l_item_group_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_item_group_id = p_x_item_group_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_ITEM_GRP';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_item_group_id := l_item_group_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_ITEM_GRPS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_item_group;

-- Procedure to valiadate the Item Composition
PROCEDURE validate_item_comp
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_x_item_comp_detail_id   IN OUT NOCOPY NUMBER
)
IS

l_item_comp_id      NUMBER;

CURSOR get_rec_from_id ( c_item_comp_detail_id NUMBER )
IS
SELECT DISTINCT ICD.item_comp_detail_id
FROM    AHL_ITEM_COMP_DETAILS ICD
    , AHL_ITEM_COMPOSITIONS CD
WHERE   ICD.item_comp_detail_id = c_item_comp_detail_id
AND   CD.APPROVAL_STATUS_CODE ='COMPLETE'
AND   CD.item_composition_id = ICD.item_composition_id
AND   nvl(trunc(CD.EFFECTIVE_END_DATE),trunc(sysdate+1)) > trunc(sysdate)
AND   nvl(trunc(ICD.EFFECTIVE_END_DATE),trunc(sysdate+1)) > trunc(sysdate);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_x_item_comp_detail_id IS NULL OR
   p_x_item_comp_detail_id = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

   OPEN get_rec_from_id( p_x_item_comp_detail_id );

    FETCH get_rec_from_id INTO
      l_item_comp_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_ITEM_COMP';
   ELSIF ( get_rec_from_id%ROWCOUNT = 1 ) THEN
      p_x_item_comp_detail_id := l_item_comp_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_ITEM_COMPS';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;


END validate_item_comp;


-- Procedure to valiadate the Positin Path
PROCEDURE validate_position_path
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_position_path  IN        VARCHAR2,
  p_x_position_path_id   IN OUT NOCOPY NUMBER
)
IS

l_position_path_id  NUMBER;
/*
CURSOR get_rec_from_value ( c_position_path VARCHAR2 )
IS
SELECT DISTINCT path_position_id
FROM    AHL_MC_PATH_POSITIONS
WHERE   position_ref_code = c_position_path;
*/
CURSOR get_rec_from_id ( c_position_path_id NUMBER )
IS
--AMSRINIV. Bug 4913429. Replacing below commented query with a new query for better performance
SELECT DISTINCT
mcp.path_position_id
FROM
  ahl_mc_relationships mcr,
  ahl_mc_headers_b mch,
  ahl_mc_path_position_nodes mcp,
  ahl_route_effectivities re
WHERE
  re.mc_id IS NOT NULL AND
  re.mc_id = mch.mc_id AND
  mch.mc_header_id =mcr.mc_header_id AND
  mch.mc_id = mcp.mc_id AND
  mch.version_number = NVL(mcp.version_number, mch.version_number) AND
  mcr.position_key =  mcp.position_key AND
  mcp.SEQUENCE = ( SELECT MAX(SEQUENCE) FROM  ahl_mc_path_position_nodes WHERE path_position_id = NVL(c_position_path_id,-1) )  AND
  mcp.path_position_id =  NVL(c_position_path_id,-1);

/*SELECT DISTINCT
mcp.path_position_id
FROM
ahl_mc_relationships mcr
, ahl_mc_headers_b mch
,   ahl_mc_path_position_nodes mcp
, AHL_ROUTE_EFFECTIVITIES_V re
WHERE
mch.mc_header_id = mcr.mc_header_id
and mch.mc_id = mcp.mc_id
and re.MC_ID = mch.MC_ID
and mch.version_number = nvl(mcp.version_number, mch.version_number)
and mcr.position_key = mcp.position_key
and mcp.sequence = (select max(sequence) from ahl_mc_path_position_nodes where path_position_id = nvl(c_position_path_id,-1))
and mcp.path_position_id = nvl(c_position_path_id,-1);*/


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_position_path IS NULL OR
   p_position_path = FND_API.G_MISS_CHAR ) AND
       ( p_x_position_path_id IS NULL OR
   p_x_position_path_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_position_path IS NULL OR
   p_position_path = FND_API.G_MISS_CHAR ) AND
       ( p_x_position_path_id IS NOT NULL AND
   p_x_position_path_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_position_path_id );

    FETCH get_rec_from_id INTO
      l_position_path_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_POS_PATH';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;
/*
  IF ( p_position_path IS NOT NULL AND
       p_position_path <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_position_path );

    LOOP
      FETCH get_rec_from_value INTO
  l_position_path_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_position_path_id = p_x_position_path_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_POS_PATH';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_position_path_id := l_position_path_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_POS_PATHS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;
*/
END validate_position_path;


-- Procedure to valiadate the master_configuration
PROCEDURE validate_master_configuration
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_mc_name    IN AHL_MC_HEADERS_V.NAME%TYPE,
  p_x_mc_id    IN OUT NOCOPY AHL_MC_HEADERS_V.MC_ID%TYPE,
  p_mc_revision_number   IN AHL_MC_HEADERS_V.REVISION%TYPE ,
  p_x_mc_header_id   IN OUT NOCOPY AHL_MC_HEADERS_V.MC_HEADER_ID%TYPE
)
IS

l_mc_header_id      AHL_MC_HEADERS_V.MC_HEADER_ID%TYPE;
l_mc_id       AHL_MC_HEADERS_V.MC_ID%TYPE;

CURSOR get_rec_from_value ( c_mc_name AHL_MC_HEADERS_V.NAME%TYPE )
IS
--AMSRINIV.  Bug 4913429. Replacing below commented query with a new query for better performance
SELECT DISTINCT mc_id
FROM    AHL_MC_HEADERS_B
WHERE   upper(name) = upper(c_mc_name)
AND   CONFIG_STATUS_CODE='COMPLETE';

/*SELECT DISTINCT mc_id
FROM    AHL_MC_HEADERS_V
WHERE   upper(name) = upper(c_mc_name)
AND   CONFIG_STATUS_CODE='COMPLETE';*/

CURSOR get_rec_from_value1 ( c_mc_name AHL_MC_HEADERS_V.NAME%TYPE , c_mc_revision_number AHL_MC_HEADERS_V.REVISION%TYPE)
IS
--AMSRINIV.  Bug 4913429. Replacing below commented query with a new query for better performance
SELECT DISTINCT mc_header_id, mc_id
FROM    AHL_MC_HEADERS_B
WHERE   upper(name) = upper(c_mc_name)
AND   upper(revision)=upper(c_mc_revision_number)
AND   CONFIG_STATUS_CODE='COMPLETE';
/*
SELECT DISTINCT mc_header_id,
    mc_id
FROM    AHL_MC_HEADERS_V
WHERE   upper(name) = upper(c_mc_name)
AND   upper(revision)=upper(c_mc_revision_number)
AND   CONFIG_STATUS_CODE='COMPLETE';*/

/*
CURSOR get_rec_from_id1 ( c_mc_header_id AHL_MC_HEADERS_V.MC_HEADER_ID%TYPE )
IS
SELECT DISTINCT mc_header_id
FROM    AHL_MC_HEADERS_V
WHERE   mc_header_id = c_mc_header_id
AND   CONFIG_STATUS_CODE='COMPLETE'
;

CURSOR get_rec_from_id ( c_mc_id AHL_MC_HEADERS_V.MC_ID%TYPE )
IS
SELECT DISTINCT mc_id
FROM    AHL_MC_HEADERS_V
WHERE   mc_id = c_mc_id
AND   CONFIG_STATUS_CODE='COMPLETE'
;
*/
/*
CURSOR get_rec_status_id ( c_mc_id AHL_MC_HEADERS_V.MC_ID%TYPE )
IS
SELECT DISTINCT mc_id
FROM    AHL_MC_HEADERS_V
WHERE   mc_id = c_mc_id
AND   CONFIG_STATUS_CODE='COMPLETE'
;

CURSOR get_rec_status_id1 ( c_mc_header_id AHL_MC_HEADERS_V.MC_HEADER_ID%TYPE )
IS
SELECT DISTINCT mc_header_id
FROM    AHL_MC_HEADERS_V
WHERE   mc_header_id = c_mc_header_id
AND   CONFIG_STATUS_CODE='COMPLETE'
;
*/
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_mc_name IS NULL OR
   p_mc_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_mc_id IS NULL OR
   p_x_mc_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;
/*
  IF ( ( p_mc_name IS NULL OR
   p_mc_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_mc_id IS NOT NULL AND
   p_x_mc_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_mc_id );

    LOOP
    FETCH get_rec_from_id INTO
      l_mc_id;
    EXIT WHEN get_rec_from_id%NOTFOUND;

    IF ( l_mc_id = p_x_mc_id ) THEN
  CLOSE get_rec_from_id;
  RETURN;
      END IF;
    END LOOP;

    IF ( get_rec_from_id%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_MC';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;
*/

  IF ( (p_mc_name IS NOT NULL AND p_mc_name <> FND_API.G_MISS_CHAR)
    AND (p_mc_revision_number IS NOT NULL AND p_mc_revision_number <> FND_API.G_MISS_CHAR)
      )
  THEN

    OPEN get_rec_from_value1( p_mc_name, p_mc_revision_number);

    LOOP
      FETCH get_rec_from_value1 INTO
  l_mc_header_id,l_mc_id;

      EXIT WHEN get_rec_from_value1%NOTFOUND;

      IF ( l_mc_id = p_x_mc_id AND l_mc_header_id = p_x_mc_header_id ) THEN
  CLOSE get_rec_from_value1;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value1%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_MC';
    ELSE
     p_x_mc_id := l_mc_id ;
     p_x_mc_header_id := l_mc_header_id;
      /*
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_mc_id := l_mc_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_MCS';
      */
    END IF;

    CLOSE get_rec_from_value1;
    RETURN;
   END IF ;
/*
   OPEN get_rec_status_id( p_x_mc_header_id );

    FETCH get_rec_status_id INTO
      l_mc_header_id;

    IF get_rec_status_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INCOMPLETE_MC';
    END IF;

    CLOSE get_rec_status_id;
    RETURN;

  END IF;
*/

IF ( p_mc_name IS NOT NULL AND
       p_mc_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_mc_name );

    LOOP
      FETCH get_rec_from_value INTO
  l_mc_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_mc_id = p_x_mc_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_MC';
    ELSE
      p_x_mc_id := l_mc_id;
      /*
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_mc_id := l_mc_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_MCS';
      */
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

   END IF ;

END validate_master_configuration;


-- Procedure to validate UOM
PROCEDURE validate_uom
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_uom      IN        MTL_UNITS_OF_MEASURE_VL.unit_of_measure%TYPE,
  p_x_uom_code     IN OUT NOCOPY MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE
)
IS

l_uom_code  MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE;

CURSOR get_rec_from_value ( c_uom MTL_UNITS_OF_MEASURE_VL.unit_of_measure%TYPE )
IS
SELECT DISTINCT uom_code
FROM    MTL_UNITS_OF_MEASURE_VL
WHERE   upper(unit_of_measure) = upper(c_uom);

CURSOR get_rec_from_id ( c_uom_code MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE )
IS
SELECT DISTINCT uom_code
FROM    MTL_UNITS_OF_MEASURE_VL
WHERE   upper(uom_code) = upper(c_uom_code);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_uom IS NULL OR
   p_uom = FND_API.G_MISS_CHAR ) AND
       ( p_x_uom_code IS NULL OR
   p_x_uom_code = FND_API.G_MISS_CHAR ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_uom IS NULL OR
   p_uom = FND_API.G_MISS_CHAR ) AND
       ( p_x_uom_code IS NOT NULL AND
   p_x_uom_code <> FND_API.G_MISS_CHAR ) ) THEN

    OPEN get_rec_from_id( p_x_uom_code );

    FETCH get_rec_from_id INTO
      l_uom_code;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_UOM';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_uom IS NOT NULL AND
       p_uom <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_uom );

    LOOP
      FETCH get_rec_from_value INTO
  l_uom_code;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_uom_code = p_x_uom_code ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_UOM';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_uom_code := l_uom_code;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_UOMS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_uom;

-- Procedure to validate whether a UOM is valid for an Item / Item Group
PROCEDURE validate_item_uom
(
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_data     OUT NOCOPY VARCHAR2,
  p_item_group_id  IN  AHL_ITEM_GROUPS_VL.item_group_id%TYPE,
  p_inventory_item_id  IN  MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
  p_inventory_org_id   IN  MTL_SYSTEM_ITEMS.organization_id%TYPE,
  p_uom_code     IN  MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE
)
IS

l_dummy      VARCHAR2(1);

CURSOR get_uom_for_item ( c_uom_code MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE,
        c_inventory_item_id MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
        c_inventory_org_id MTL_SYSTEM_ITEMS.organization_id%TYPE )
IS
SELECT    'X'
FROM    AHL_ITEM_CLASS_UOM_V
WHERE   uom_code = c_uom_code
AND   inventory_item_id = c_inventory_item_id
AND   inventory_org_id = c_inventory_org_id;

CURSOR get_uom_for_item_group ( c_uom_code MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE,
        c_item_group_id AHL_ITEM_GROUPS_VL.item_group_id%TYPE )
IS
SELECT    'X'
FROM    AHL_ITEM_CLASS_UOM_V UOM, AHL_ITEM_ASSOCIATIONS_B ASSOC
WHERE   UOM.uom_code = c_uom_code
AND   UOM.inventory_item_id = ASSOC.inventory_item_id
AND   UOM.inventory_org_id = ASSOC.inventory_org_id
AND   ASSOC.item_group_id = c_item_group_id;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_uom_code IS NULL OR
       p_uom_code = FND_API.G_MISS_CHAR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_inventory_item_id IS NULL OR
   p_inventory_item_id = FND_API.G_MISS_NUM ) AND
       ( p_inventory_org_id IS NULL OR
   p_inventory_org_id = FND_API.G_MISS_NUM ) AND
       ( p_item_group_id IS NULL OR
   p_item_group_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( p_item_group_id IS NOT NULL AND
       p_item_group_id <> FND_API.G_MISS_NUM ) THEN

    OPEN get_uom_for_item_group( p_uom_code , p_item_group_id );

    FETCH get_uom_for_item_group INTO
      l_dummy;

    IF get_uom_for_item_group%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_UOM_ITEM_GRP';
    END IF;

    CLOSE get_uom_for_item_group;
    RETURN;

  END IF;

  IF ( p_inventory_item_id IS NOT NULL AND
       p_inventory_item_id <> FND_API.G_MISS_NUM AND
       p_inventory_org_id IS NOT NULL AND
       p_inventory_org_id <> FND_API.G_MISS_NUM ) THEN

    OPEN get_uom_for_item( p_uom_code, p_inventory_item_id, p_inventory_org_id );

    FETCH get_uom_for_item INTO
      l_dummy;

    IF get_uom_for_item%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_UOM_ITEM';
    END IF;

    CLOSE get_uom_for_item;
    RETURN;

  END IF;

END validate_item_uom;

-- Procedure to validate Product Type and Zone association
PROCEDURE validate_pt_zone
(
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_data     OUT NOCOPY VARCHAR2,
  p_product_type_code  IN  AHL_PRODTYPE_ZONES.product_type_code%TYPE,
  p_zone_code    IN  AHL_PRODTYPE_ZONES.zone_code%TYPE
)
IS

CURSOR check_pt_zone ( c_product_type_code AHL_PRODTYPE_ZONES.product_type_code%TYPE,
           c_zone_code AHL_PRODTYPE_ZONES.zone_code%TYPE )
IS
SELECT 'X'
FROM   AHL_PRODTYPE_ZONES
WHERE  product_type_code = c_product_type_code
AND    zone_code = c_zone_code
AND    sub_zone_code IS NULL;

l_dummy        VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_product_type_code IS NULL OR
       p_product_type_code = FND_API.G_MISS_CHAR OR
       p_zone_code IS NULL OR
       p_zone_code = FND_API.G_MISS_CHAR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN check_pt_zone( p_product_type_code , p_zone_code );

  FETCH check_pt_zone INTO
    l_dummy;

  IF check_pt_zone%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_RM_INVALID_PT_ZONE';
  END IF;

  CLOSE check_pt_zone;
  RETURN;

END validate_pt_zone;

-- Procedure to validate Product Type, Zone and Sub Zone association
PROCEDURE validate_pt_zone_subzone
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_product_type_code  IN  AHL_PRODTYPE_ZONES.product_type_code%TYPE ,
  p_zone_code    IN  AHL_PRODTYPE_ZONES.zone_code%TYPE,
  p_sub_zone_code  IN  AHL_PRODTYPE_ZONES.sub_zone_code%TYPE
)
IS

CURSOR check_pt_zone_subzone ( c_product_type_code AHL_PRODTYPE_ZONES.product_type_code%TYPE, c_zone_code AHL_PRODTYPE_ZONES.zone_code%TYPE, c_sub_zone_code AHL_PRODTYPE_ZONES.sub_zone_code%TYPE )
IS
SELECT 'X'
FROM   AHL_PRODTYPE_ZONES
WHERE  product_type_code = c_product_type_code
AND    zone_code = c_zone_code
AND    sub_zone_code = c_sub_zone_code;

l_dummy        VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_product_type_code IS NULL OR
       p_product_type_code = FND_API.G_MISS_CHAR OR
       p_zone_code IS NULL OR
       p_zone_code = FND_API.G_MISS_CHAR OR
       p_sub_zone_code IS NULL OR
       p_sub_zone_code = FND_API.G_MISS_CHAR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN check_pt_zone_subzone( p_product_type_code, p_zone_code, p_sub_zone_code );

  FETCH check_pt_zone_subzone INTO
    l_dummy;

  IF check_pt_zone_subzone%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_RM_INVALID_PT_ZONE_SUBZONE';
  END IF;

  CLOSE check_pt_zone_subzone;
  RETURN;

END validate_pt_zone_subzone;

-- Procedure to validate MFG Lookups
PROCEDURE validate_mfg_lookup
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_lookup_type    IN        MFG_LOOKUPS.lookup_type%TYPE,
  p_lookup_meaning   IN        MFG_LOOKUPS.meaning%TYPE,
  p_x_lookup_code  IN OUT NOCOPY MFG_LOOKUPS.lookup_code%TYPE
)
IS

l_lookup_code    MFG_LOOKUPS.lookup_code%TYPE;
l_sp_cursor_use       VARCHAR2(5) := 'N';

CURSOR get_rec_from_value_sp ( c_lookup_type MFG_LOOKUPS.lookup_type%TYPE,
          c_lookup_meaning MFG_LOOKUPS.meaning%TYPE ,
          c_lookup_code_1 NUMBER ,
          c_lookup_code_2 NUMBER)
IS
SELECT DISTINCT lookup_code
FROM    MFG_LOOKUPS
WHERE   lookup_type = c_lookup_type
AND   UPPER(meaning) = UPPER(c_lookup_meaning)
AND   SYSDATE BETWEEN NVL( start_date_active, SYSDATE ) AND
        NVL( end_date_active, SYSDATE )
AND   LOOKUP_CODE IN (c_lookup_code_1, c_lookup_code_2);

CURSOR get_rec_from_id_sp ( c_lookup_type FND_LOOKUPS.lookup_type%TYPE,
       c_lookup_code FND_LOOKUPS.lookup_code%TYPE ,
       c_lookup_code_1 NUMBER ,
       c_lookup_code_2 NUMBER)
IS
SELECT DISTINCT lookup_code
FROM    MFG_LOOKUPS
WHERE   lookup_type = c_lookup_type
AND   lookup_code = c_lookup_code
AND   SYSDATE BETWEEN NVL( start_date_active, SYSDATE ) AND
        NVL( end_date_active, SYSDATE )
AND   LOOKUP_CODE IN (c_lookup_code_1, c_lookup_code_2);

CURSOR get_rec_from_value ( c_lookup_type MFG_LOOKUPS.lookup_type%TYPE,
          c_lookup_meaning MFG_LOOKUPS.meaning%TYPE )
IS
SELECT DISTINCT lookup_code
FROM    MFG_LOOKUPS
WHERE   lookup_type = c_lookup_type
AND   UPPER(meaning) = UPPER(c_lookup_meaning)
AND   SYSDATE BETWEEN NVL( start_date_active, SYSDATE ) AND
        NVL( end_date_active, SYSDATE );

CURSOR get_rec_from_id ( c_lookup_type FND_LOOKUPS.lookup_type%TYPE,
       c_lookup_code FND_LOOKUPS.lookup_code%TYPE )
IS
SELECT DISTINCT lookup_code
FROM    MFG_LOOKUPS
WHERE   lookup_type = c_lookup_type
AND   lookup_code = c_lookup_code
AND   SYSDATE BETWEEN NVL( start_date_active, SYSDATE ) AND
        NVL( end_date_active, SYSDATE );

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_lookup_type IS NULL OR
       p_lookup_type = FND_API.G_MISS_CHAR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_lookup_meaning IS NULL OR
   p_lookup_meaning = FND_API.G_MISS_CHAR ) AND
       ( p_x_lookup_code IS NULL OR
   p_x_lookup_code = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_lookup_meaning IS NULL OR
   p_lookup_meaning = FND_API.G_MISS_CHAR ) AND
       ( p_x_lookup_code IS NOT NULL AND
   p_x_lookup_code <> FND_API.G_MISS_NUM ) ) THEN

    IF ( p_lookup_type = 'CST_BASIS' OR p_lookup_type = 'BOM_RESOURCE_SCHEDULE_TYPE' OR p_lookup_type = 'SYS_YES_NO')
  THEN
      OPEN get_rec_from_id_sp( p_lookup_type, p_x_lookup_code , 1 , 2 );
      l_sp_cursor_use := 'Y';
  ELSIF (  p_lookup_type = 'BOM_AUTOCHARGE_TYPE')
  THEN
     OPEN get_rec_from_id_sp( p_lookup_type, p_x_lookup_code , 2 , -1);
     l_sp_cursor_use := 'Y';
  ELSE
     OPEN get_rec_from_id( p_lookup_type, p_x_lookup_code );
    END IF;

    IF(l_sp_cursor_use = 'Y')
    THEN
  FETCH get_rec_from_id_sp INTO
  l_lookup_code;

  IF get_rec_from_id_sp%NOTFOUND THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_INVALID_MFG_LOOKUP';
  END IF;

  CLOSE get_rec_from_id_sp;
    ELSE
  FETCH get_rec_from_id INTO
  l_lookup_code;

  IF get_rec_from_id%NOTFOUND THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_INVALID_MFG_LOOKUP';
  END IF;

  CLOSE get_rec_from_id;
    END IF;

    RETURN;

  END IF;

  IF ( p_lookup_meaning IS NOT NULL AND
       p_lookup_meaning <> FND_API.G_MISS_CHAR ) THEN

    IF ( p_lookup_type = 'CST_BASIS' OR p_lookup_type = 'BOM_RESOURCE_SCHEDULE_TYPE' OR p_lookup_type = 'SYS_YES_NO')
    THEN
  OPEN get_rec_from_value_sp(  p_lookup_type, p_lookup_meaning , 1 , 2 );
  l_sp_cursor_use := 'Y';
    ELSIF (  p_lookup_type = 'BOM_AUTOCHARGE_TYPE')
    THEN
   OPEN get_rec_from_value_sp( p_lookup_type, p_lookup_meaning, 2 , -1 );
   l_sp_cursor_use := 'Y';
    ELSE
   OPEN get_rec_from_value( p_lookup_type, p_lookup_meaning );
    END IF;

    IF( l_sp_cursor_use  = 'Y')
    THEN

  LOOP
  FETCH get_rec_from_value_sp INTO
  l_lookup_code;

  EXIT WHEN get_rec_from_value_sp%NOTFOUND;

  IF ( l_lookup_code = p_x_lookup_code ) THEN
  CLOSE get_rec_from_value_sp;
  RETURN;
  END IF;

  END LOOP;

  IF ( get_rec_from_value_sp%ROWCOUNT = 0 ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_INVALID_MFG_LOOKUP';
  ELSIF ( get_rec_from_value_sp%ROWCOUNT = 1 ) THEN
  p_x_lookup_code := l_lookup_code;
  ELSE
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_TOO_MANY_MFG_LOOKUPS';
  END IF;

  CLOSE get_rec_from_value_sp;
  RETURN;
    ELSE
  LOOP
  FETCH get_rec_from_value INTO
  l_lookup_code;

  EXIT WHEN get_rec_from_value%NOTFOUND;

  IF ( l_lookup_code = p_x_lookup_code ) THEN
  CLOSE get_rec_from_value;
  RETURN;
  END IF;

  END LOOP;

  IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_INVALID_MFG_LOOKUP';
  ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
  p_x_lookup_code := l_lookup_code;
  ELSE
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_TOO_MANY_MFG_LOOKUPS';
  END IF;

  CLOSE get_rec_from_value;
  RETURN;

    END IF;
  END IF;

END validate_mfg_lookup;

-- Procedure to validate ASO Resource
PROCEDURE validate_aso_resource
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_aso_resource_name  IN        AHL_RESOURCES.name%TYPE,
  p_x_aso_resource_id  IN OUT NOCOPY AHL_RESOURCES.resource_id%TYPE
)
IS

l_aso_resource_id      AHL_RESOURCES.resource_id%TYPE;

CURSOR get_rec_from_value ( c_aso_resource_name AHL_RESOURCES.name%TYPE )
IS
SELECT DISTINCT resource_id
FROM    AHL_RESOURCES
WHERE   UPPER(TRIM(name)) = UPPER(TRIM(c_aso_resource_name));

CURSOR get_rec_from_id ( c_aso_resource_id AHL_RESOURCES.resource_id%TYPE )
IS
SELECT DISTINCT resource_id
FROM    AHL_RESOURCES
WHERE   resource_id = c_aso_resource_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_aso_resource_name IS NULL OR
   p_aso_resource_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_aso_resource_id IS NULL OR
   p_x_aso_resource_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_aso_resource_name IS NULL OR
   p_aso_resource_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_aso_resource_id IS NOT NULL AND
   p_x_aso_resource_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_aso_resource_id );

    FETCH get_rec_from_id INTO
      l_aso_resource_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_ASO_RESOURCE';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_aso_resource_name IS NOT NULL AND
       p_aso_resource_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_aso_resource_name );

    LOOP
      FETCH get_rec_from_value INTO
  l_aso_resource_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_aso_resource_id = p_x_aso_resource_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_ASO_RESOURCE';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_aso_resource_id := l_aso_resource_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_ASO_RESOURCES';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_aso_resource;

-- Procedure to validate ASO Resource
PROCEDURE validate_bom_resource
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_bom_resource_code  IN        BOM_RESOURCES.resource_code%TYPE,
  p_x_bom_resource_id  IN OUT NOCOPY BOM_RESOURCES.resource_id%TYPE,
  p_x_bom_org_id   IN OUT NOCOPY BOM_RESOURCES.organization_id%TYPE
)
IS

l_bom_resource_id      BOM_RESOURCES.resource_id%TYPE;
l_bom_org_id         BOM_RESOURCES.organization_id%TYPE;

CURSOR get_rec_from_value ( c_bom_resource_code BOM_RESOURCES.resource_code%TYPE )
IS
SELECT DISTINCT resource_id,
    organization_id
FROM    BOM_RESOURCES
WHERE   resource_code = c_bom_resource_code;

CURSOR get_rec_from_id ( c_bom_resource_id BOM_RESOURCES.resource_id%TYPE,
       c_bom_org_id  BOM_RESOURCES.organization_id%TYPE )
IS
SELECT DISTINCT resource_id,
    organization_id
FROM    BOM_RESOURCES
WHERE   resource_id = c_bom_resource_id
AND   organization_id = c_bom_org_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_bom_resource_code IS NULL OR
   p_bom_resource_code = FND_API.G_MISS_CHAR ) AND
       ( p_x_bom_resource_id IS NULL OR
   p_x_bom_resource_id = FND_API.G_MISS_NUM ) AND
       ( p_x_bom_org_id IS NULL OR
   p_x_bom_org_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_bom_resource_code IS NULL OR
   p_bom_resource_code = FND_API.G_MISS_CHAR ) AND
       ( p_x_bom_resource_id IS NOT NULL AND
   p_x_bom_resource_id <> FND_API.G_MISS_NUM AND
   p_x_bom_org_id IS NOT NULL AND
   p_x_bom_org_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_bom_resource_id , p_x_bom_org_id );

    FETCH get_rec_from_id INTO
      l_bom_resource_id,
      l_bom_org_id;

    IF ( get_rec_from_id%NOTFOUND ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_BOM_RESOURCE';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_bom_resource_code IS NOT NULL AND
       p_bom_resource_code <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_bom_resource_code );

    LOOP
      FETCH get_rec_from_value INTO
  l_bom_resource_id,
  l_bom_org_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_bom_resource_id = p_x_bom_resource_id AND
     l_bom_org_id = p_x_bom_org_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_BOM_RESOURCE';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_bom_resource_id := l_bom_resource_id;
      p_x_bom_org_id := l_bom_org_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_BOM_RESOURCES';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_bom_resource;

-- pdoki ER 7436910 Begin.
-- Procedure to validate ASO Resource
PROCEDURE validate_bom_res_dep
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_bom_resource_id  IN NUMBER,
  p_bom_org_id   IN  BOM_DEPARTMENTS.organization_id%TYPE,
  p_bom_department_name  IN        BOM_DEPARTMENTS.DESCRIPTION%TYPE,
  p_x_bom_department_id  IN OUT NOCOPY BOM_DEPARTMENTS.department_id%TYPE
)
IS

l_bom_department_id      number;

CURSOR get_rec_from_value ( c_bom_department_name BOM_DEPARTMENTS.DESCRIPTION%TYPE , c_bom_resource_id NUMBER, c_bom_org_id NUMBER)
IS
select distinct DEPT.department_id
from bom_departments DEPT, BOM_DEPARTMENT_RESOURCES DEPT_RES, BOM_RESOURCES RES
where DEPT_RES.department_id = DEPT.department_id
and DEPT.description = c_bom_department_name
and DEPT_RES.resource_id = c_bom_resource_id
and DEPT.organization_id = c_bom_org_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_bom_department_name IS NULL OR
   p_bom_department_name = FND_API.G_MISS_CHAR  ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( p_bom_department_name IS NOT NULL AND
       p_bom_department_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_bom_department_name, p_bom_resource_id, p_bom_org_id );

    LOOP
      FETCH get_rec_from_value INTO
  l_bom_department_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_bom_department_id = p_x_bom_department_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_BOM_RES_DEPT';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_bom_department_id := l_bom_department_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_BOM_RES_DEPTS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_bom_res_dep;
-- pdoki ER 7436910 End.

-- Procedure to validate Resource Costing - Activity
PROCEDURE validate_activity
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_activity     IN        CST_ACTIVITIES.activity%TYPE,
  p_x_activity_id  IN OUT NOCOPY CST_ACTIVITIES.activity_id%TYPE
)
IS

l_activity_id    CST_ACTIVITIES.activity_id%TYPE;

CURSOR get_rec_from_value ( c_activity CST_ACTIVITIES.activity%TYPE )
IS
SELECT DISTINCT activity_id
FROM    CST_ACTIVITIES
WHERE   activity = c_activity;

CURSOR get_rec_from_id ( c_activity_id CST_ACTIVITIES.activity_id%TYPE )
IS
SELECT DISTINCT activity_id
FROM    CST_ACTIVITIES
WHERE   activity_id = c_activity_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_activity IS NULL OR
   p_activity = FND_API.G_MISS_CHAR ) AND
       ( p_x_activity_id IS NULL OR
   p_x_activity_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_activity IS NULL OR
   p_activity = FND_API.G_MISS_CHAR ) AND
       ( p_x_activity_id IS NOT NULL AND
   p_x_activity_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_activity_id );

    FETCH get_rec_from_id INTO
      l_activity_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_ACTIVITY';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_activity IS NOT NULL AND
       p_activity <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_activity );

    LOOP
      FETCH get_rec_from_value INTO
  l_activity_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_activity_id = p_x_activity_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_ACTIVITY';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_activity_id := l_activity_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_ACTIVITIES';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_activity;

-- Procedure to validate Skill Type
PROCEDURE validate_skill_type
(
  x_return_status   OUT NOCOPY  VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  p_business_group_id   IN    PER_COMPETENCES.business_group_id%TYPE,
  p_skill_name      IN    PER_COMPETENCES.name%TYPE,
  p_x_skill_competence_id IN OUT NOCOPY PER_COMPETENCES.competence_id%TYPE
)
IS

l_skill_competence_id    PER_COMPETENCES.competence_id%TYPE;

CURSOR get_rec_from_value ( c_skill_name PER_COMPETENCES.name%TYPE,
          c_business_group_id PER_COMPETENCES.business_group_id%TYPE )
IS
SELECT DISTINCT competence_id
FROM    PER_COMPETENCES
WHERE   name = c_skill_name
AND   business_group_id = c_business_group_id;

CURSOR get_rec_from_id ( c_skill_competence_id PER_COMPETENCES.competence_id%TYPE,
       c_business_group_id PER_COMPETENCES.business_group_id%TYPE )
IS
SELECT DISTINCT competence_id
FROM    PER_COMPETENCES
WHERE   competence_id = c_skill_competence_id
AND   business_group_id = c_business_group_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_business_group_id IS NULL OR
       p_business_group_id = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_skill_name IS NULL OR
   p_skill_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_skill_competence_id IS NULL OR
   p_x_skill_competence_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_skill_name IS NULL OR
   p_skill_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_skill_competence_id IS NOT NULL AND
   p_x_skill_competence_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_skill_competence_id, p_business_group_id );

    FETCH get_rec_from_id INTO
      l_skill_competence_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_SKILL_TYPE';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_skill_name IS NOT NULL AND
       p_skill_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_skill_name, p_business_group_id );

    LOOP
      FETCH get_rec_from_value INTO
  l_skill_competence_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_skill_competence_id = p_x_skill_competence_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_SKILL_TYPE';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_skill_competence_id := l_skill_competence_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_SKILL_TYPES';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_skill_type;

-- Procedure to validate Skill Level
PROCEDURE validate_skill_level
(
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_data    OUT NOCOPY    VARCHAR2,
  p_business_group_id IN        PER_RATING_LEVELS.business_group_id%TYPE,
  p_skill_competence_id IN        PER_RATING_LEVELS.competence_id%TYPE,
  p_skill_level_desc  IN        VARCHAR2,
  p_x_rating_level_id IN OUT NOCOPY PER_RATING_LEVELS.rating_level_id%TYPE
)
IS

l_rating_level_id      PER_RATING_LEVELS.rating_level_id%TYPE;

CURSOR get_rec_from_value ( c_skill_level_desc PER_RATING_LEVELS.name%TYPE,
          c_skill_competence_id PER_RATING_LEVELS.competence_id%TYPE,
          c_business_group_id PER_RATING_LEVELS.business_group_id%TYPE )
IS
SELECT DISTINCT rating_level_id
FROM    PER_RATING_LEVELS
WHERE   TO_CHAR( step_value ) || '-' || name = c_skill_level_desc
AND   competence_id = c_skill_competence_id
AND   business_group_id = c_business_group_id;

CURSOR get_rec_from_id ( c_rating_level_id PER_RATING_LEVELS.rating_level_id%TYPE,
       c_skill_competence_id PER_RATING_LEVELS.competence_id%TYPE,
       c_business_group_id PER_RATING_LEVELS.business_group_id%TYPE )
IS
SELECT DISTINCT rating_level_id
FROM    PER_RATING_LEVELS
WHERE   rating_level_id = c_rating_level_id
AND   competence_id = c_skill_competence_id
AND   business_group_id = c_business_group_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_business_group_id IS NULL OR
       p_business_group_id = FND_API.G_MISS_NUM OR
       p_skill_competence_id IS NULL OR
       p_skill_competence_id = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_skill_level_desc IS NULL OR
   p_skill_level_desc = FND_API.G_MISS_CHAR ) AND
       ( p_x_rating_level_id IS NULL OR
   p_x_rating_level_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_skill_level_desc IS NULL OR
   p_skill_level_desc = FND_API.G_MISS_CHAR ) AND
       ( p_x_rating_level_id IS NOT NULL AND
   p_x_rating_level_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_rating_level_id, p_skill_competence_id, p_business_group_id );

    FETCH get_rec_from_id INTO
      l_rating_level_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_SKILL_LEVEL';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_skill_level_desc IS NOT NULL AND
       p_skill_level_desc <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_skill_level_desc, p_skill_competence_id, p_business_group_id );

    LOOP
      FETCH get_rec_from_value INTO
  l_rating_level_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_rating_level_id = p_x_rating_level_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_SKILL_LEVEL';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_rating_level_id := l_rating_level_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_SKILL_LEVELS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_skill_level;

-- Procedure to validate Qualification Type
PROCEDURE validate_qualification_type
(
  x_return_status     OUT NOCOPY    VARCHAR2,
  x_msg_data        OUT NOCOPY    VARCHAR2,
  p_qualification_type      IN      PER_QUALIFICATION_TYPES.name%TYPE,
  p_x_qualification_type_id IN OUT NOCOPY PER_QUALIFICATION_TYPES.qualification_type_id%TYPE
)
IS

l_qualification_type_id      PER_QUALIFICATION_TYPES.qualification_type_id%TYPE;

CURSOR get_rec_from_value ( c_qualification_type PER_QUALIFICATION_TYPES.name%TYPE )
IS
SELECT DISTINCT qualification_type_id
FROM    PER_QUALIFICATION_TYPES
WHERE   name = c_qualification_type;

CURSOR get_rec_from_id ( c_qualification_type_id PER_QUALIFICATION_TYPES.qualification_type_id%TYPE )
IS
SELECT DISTINCT qualification_type_id
FROM    PER_QUALIFICATION_TYPES
WHERE   qualification_type_id = c_qualification_type_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_qualification_type IS NULL OR
   p_qualification_type = FND_API.G_MISS_CHAR ) AND
       ( p_x_qualification_type_id IS NULL OR
   p_x_qualification_type_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_qualification_type IS NULL OR
   p_qualification_type = FND_API.G_MISS_CHAR ) AND
       ( p_x_qualification_type_id IS NOT NULL AND
   p_x_qualification_type_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_qualification_type_id );

    FETCH get_rec_from_id INTO
      l_qualification_type_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_QUAL_TYPE';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_qualification_type IS NOT NULL AND
       p_qualification_type <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_qualification_type );

    LOOP
      FETCH get_rec_from_value INTO
  l_qualification_type_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_qualification_type_id = p_x_qualification_type_id ) THEN
  CLOSE get_rec_from_value;
  RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_QUAL_TYPE';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_qualification_type_id := l_qualification_type_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_TOO_MANY_QUAL_TYPES';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_qualification_type;

-- Procedure to validate whether the Route is in Updatable status
PROCEDURE validate_route_status
(
  p_route_id     IN  NUMBER,
  x_msg_data     OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

  CURSOR get_route_status(c_route_id number) IS
    SELECT revision_status_code
      FROM  ahl_routes_app_v
     WHERE route_id = c_route_id;
  l_route_status_code      VARCHAR2(30);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_route_id IS NULL OR
       p_route_id= FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN get_route_status( p_route_id );

  FETCH get_route_status INTO l_route_status_code;

  IF get_route_status%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_RM_INVALID_ROUTE';
    CLOSE get_route_status;
    RETURN;
  END IF;

  IF ( l_route_status_code <> 'DRAFT' AND
       l_route_status_code <> 'APPROVAL_REJECTED' ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_RM_INVALID_ROUTE_STATUS';
    CLOSE get_route_status;
    RETURN;
  END IF;

  CLOSE get_route_status;

END validate_route_status;


-- Procedure to validate Effectivity of the Route
PROCEDURE validate_efct_status
(
  p_efct_id   IN  NUMBER,
  x_msg_data     OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

  CURSOR get_efct_status(c_efct_id number) IS
--AMSRINIV. Bug 4913429. Replacing below commented query with a new query for better performance
   SELECT ROUTE_ID
        FROM AHL_ROUTE_EFFECTIVITIES
        WHERE ROUTE_EFFECTIVITY_ID = c_efct_id;
    /*SELECT ROUTE_ID
      FROM  AHL_ROUTE_EFFECTIVITIES_V
     WHERE ROUTE_EFFECTIVITY_ID = c_efct_id;*/

  CURSOR get_route_status(c_route_id number) IS
 --AMSRINIV. Bug 4913429. Replacing below commented query with a new query for better performance
    SELECT ROUTE_NO
        FROM AHL_ROUTES_B
        WHERE ROUTE_ID = c_route_id AND
        APPLICATION_USG_CODE=rtrim(ltrim(fnd_profile.value('AHL_APPLN_USAGE')));
   /* SELECT ROUTE_NO
      FROM  AHL_ROUTES_V
     WHERE ROUTE_ID = c_route_id;*/

     l_route_id        NUMBER;
     l_route_no        VARCHAR2(30);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_efct_id IS NULL OR
       p_efct_id= FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN get_efct_status( p_efct_id );

  FETCH get_efct_status INTO l_route_id;

  IF get_efct_status%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_RM_INVALID_efct';
    CLOSE get_efct_status;
    RETURN;
  END IF;

  OPEN get_route_status( l_route_id );

  FETCH get_route_status INTO l_route_no;

  IF get_route_status%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_RM_INVALID_efct_ROUTE';
    CLOSE get_route_status;
    RETURN;
  END IF;

  CLOSE get_efct_status;

END validate_efct_status;


-- Procedure to validate whether the Operation is in Updatable status
PROCEDURE validate_operation_status
(
  p_operation_id   IN  NUMBER,
  x_msg_data     OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

  CURSOR get_operation_status(c_operation_id number) IS
    SELECT revision_status_code
      FROM ahl_operations_b
     WHERE operation_id = c_operation_id;
  l_operation_status_code  VARCHAR2(30);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_operation_id IS NULL OR
       p_operation_id = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN get_operation_status( p_operation_id );

  FETCH get_operation_status INTO l_operation_status_code;

  IF get_operation_status%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_RM_INVALID_OPERATION';
    CLOSE get_operation_status;
    RETURN;
  END IF;

  IF ( l_operation_status_code <> 'DRAFT' AND
       l_operation_status_code <> 'APPROVAL_REJECTED' ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_RM_INVALID_OPER_STATUS';
    CLOSE get_operation_status;
    RETURN;
  END IF;

  CLOSE get_operation_status;
END validate_operation_status;

-- Procedure to validate whether the Time Span of the Route is Greater than the Longest Resource Duration for the Same Route and all the Associated Operations
PROCEDURE validate_route_time_span
(
  p_route_id     IN  NUMBER,
  p_time_span    IN  NUMBER,
  p_rou_start_date IN DATE,
  x_res_max_duration   OUT NOCOPY NUMBER,
  x_msg_data     OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

-- Fix for bug# 6512803. Validate scheduled resources only.
-- Bug # 7644260 (FP for ER # 6998882) -- start
/*
CURSOR get_max_rt_resource_duration( c_route_id NUMBER )
IS
SELECT MAX( duration )
FROM   AHL_RT_OPER_RESOURCES
WHERE  association_type_code = 'ROUTE'
AND    object_id = c_route_id
AND    scheduled_type_id = 1;
*/
CURSOR get_max_rt_resource_duration( c_route_id NUMBER )
IS
SELECT SUM(MAX(duration))
FROM   AHL_RT_OPER_RESOURCES
WHERE  association_type_code = 'ROUTE'
AND object_id = c_route_id
GROUP BY schedule_seq ;
-- Bug # 7644260 (FP for ER # 6998882) -- end

-- Fix for bug# 6512803. Validate scheduled resources only.
-- Bug # 7644260 (FP for ER # 6998882) -- start
/*
CURSOR get_max_op_resource_duration( c_route_id NUMBER )
IS
SELECT MAX( RES.duration )
FROM   AHL_RT_OPER_RESOURCES RES, AHL_OPERATIONS_B OPER, AHL_ROUTE_OPERATIONS ASS
WHERE  RES.association_type_code = 'OPERATION'
AND    RES.object_id = ASS.operation_id
AND    NVL( OPER.end_date_active , TRUNC( SYSDATE ) + 1 ) > TRUNC( SYSDATE )
AND    OPER.operation_id = ASS.operation_id
AND    RES.scheduled_type_id = 1
AND    ASS.route_id = c_route_id;
*/
/*
CURSOR get_max_op_resource_duration( c_route_id NUMBER )
IS
SELECT SUM(OPR_DURATION)
FROM
  (SELECT RES.object_id,RES.schedule_seq, MAX(duration) "OPR_DURATION"
   FROM   AHL_RT_OPER_RESOURCES RES, AHL_OPERATIONS_B OPER, AHL_ROUTE_OPERATIONS ASS
   WHERE  RES.association_type_code = 'OPERATION'
   AND    RES.object_id = ASS.operation_id
   AND    NVL( OPER.end_date_active , TRUNC( SYSDATE ) + 1 ) > TRUNC( SYSDATE )
   AND    OPER.operation_id = ASS.operation_id
   AND    ASS.route_id = c_route_id
   GROUP BY RES.object_id,RES.schedule_seq ) ;
-- Bug # 7644260 (FP for ER # 6998882) -- end
*/

-- Bug # 8639648 -- start
CURSOR get_max_op_resource_duration( c_route_id NUMBER, c_rou_start_date DATE )
IS
SELECT MAX(OPER_DURATION)
FROM   ( SELECT  SUM(RES_DURATION) OPER_DURATION,
                 object_id
       FROM     (SELECT  MAX(res.duration) RES_DURATION,
                         res.object_id
                FROM     ahl_rt_oper_resources res
                WHERE    res.association_type_code = 'OPERATION'
                AND      res.scheduled_type_id = 1
                AND      res.object_id IN
                         (SELECT oper.operation_id
                         FROM    ahl_operations_b oper    ,
                                 ahl_route_operations ass ,
                                 ahl_routes_app_v rou
                         WHERE
                                 (
                                   TRUNC(nvl(c_rou_start_date,rou.start_date_active)) >= TRUNC(oper.start_date_active)
                                   AND
                                   TRUNC(NVL(oper.end_date_active, nvl(c_rou_start_date,rou.start_date_active) + 1)) > TRUNC(nvl(c_rou_start_date,rou.start_date_active))
                                 )
                         AND     rou.route_id      = c_route_id
                         AND     oper.operation_id = ass.operation_id
                         AND     ass.route_id      = c_route_id
                         )
                GROUP BY res.object_id,
                         res.schedule_seq
                )
       GROUP BY object_id
       );
-- Bug # 8639648 -- end

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_route_id IS NULL OR
       p_route_id= FND_API.G_MISS_NUM OR
       p_time_span IS NULL OR
       p_time_span = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN get_max_rt_resource_duration( p_route_id );

  FETCH get_max_rt_resource_duration INTO x_res_max_duration;

  IF get_max_rt_resource_duration%FOUND THEN
    IF ( x_res_max_duration > p_time_span ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_RT_RES_TIME_LONGER';
      CLOSE get_max_rt_resource_duration;
      RETURN;
    END IF;
  END IF;

  CLOSE get_max_rt_resource_duration;

  OPEN get_max_op_resource_duration( p_route_id, p_rou_start_date );

  FETCH get_max_op_resource_duration INTO x_res_max_duration;

  IF get_max_op_resource_duration%FOUND THEN
    IF ( x_res_max_duration > p_time_span ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_OP_RES_TIME_LONGER';
    END IF;
  END IF;

  CLOSE get_max_op_resource_duration;

END validate_route_time_span;

-- Procedure to validate whether the Duration specified for the Route / Operation Resource is longer than The Route Time Span.
PROCEDURE validate_resource_duration
(
  p_object_id     IN  NUMBER,
  p_association_type_code IN  VARCHAR2,
  p_duration      IN  NUMBER,
  x_max_rt_time_span    OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2
)
IS

CURSOR get_route_time_span( c_route_id NUMBER )
IS
SELECT time_span
FROM   AHL_ROUTES_APP_V
WHERE  route_id = c_route_id;

-- Bug # 8639648 -- start
CURSOR get_op_route_time_span( c_operation_id NUMBER )
IS
SELECT MIN( RT.time_span )
FROM   AHL_ROUTES_APP_V RT     ,
       AHL_ROUTE_OPERATIONS ASS,
       AHL_OPERATIONS_B oper
WHERE  ( TRUNC(RT.start_date_active)                                    >= TRUNC(oper.start_date_active)
       AND    TRUNC(NVL(oper.end_date_active, RT.start_date_active + 1)) > TRUNC(RT.start_date_active)
       )
AND    TRUNC ( NVL ( RT.end_date_active , SYSDATE + 1 ) ) > TRUNC( SYSDATE )
AND    oper.operation_id                                  = ass.operation_id
AND    RT.route_id                                        = ASS.route_id
AND    ASS.operation_id                                   = c_operation_id;
-- Bug # 8639648 -- end

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_object_id IS NULL OR
       p_object_id= FND_API.G_MISS_NUM OR
       p_association_type_code IS NULL OR
       p_association_type_code = FND_API.G_MISS_CHAR OR
       p_duration IS NULL OR
       p_duration = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( p_association_type_code = 'ROUTE' ) THEN

    OPEN get_route_time_span( p_object_id );

    FETCH get_route_time_span INTO x_max_rt_time_span;

    IF get_route_time_span%FOUND THEN
      IF ( x_max_rt_time_span < p_duration ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_RM_RT_RES_DURATION_LONGER';
      END IF;
    END IF;

    CLOSE get_route_time_span;

  ELSIF ( p_association_type_code = 'OPERATION' ) THEN

    OPEN get_op_route_time_span( p_object_id );

    FETCH get_op_route_time_span INTO x_max_rt_time_span;

    IF get_op_route_time_span%FOUND THEN
      IF ( x_max_rt_time_span < p_duration ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_RM_OP_RES_DURATION_LONGER';
      END IF;
    END IF;

    CLOSE get_op_route_time_span;
  END IF;

END validate_resource_duration;

-- Procedure to validate whether the longest Duration specified for an operation Resource is longer than associated Route Time Span.
PROCEDURE validate_rt_op_res_duration
(
  p_route_id      IN  NUMBER,
  p_operation_id    IN  NUMBER,
  x_rt_time_span    OUT NOCOPY NUMBER,
  x_op_max_res_duration   OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2
)
IS
/*
CURSOR get_route_time_span( c_route_id NUMBER )
IS
SELECT time_span
FROM   AHL_ROUTES_APP_V
WHERE  route_id = c_route_id;
*/
-- Validate operation duration against route duration only
-- if the operation active start date is after route active start date
CURSOR get_route_time_span(c_route_id NUMBER, c_operation_id NUMBER)
IS
SELECT rou.time_span
FROM   AHL_ROUTES_APP_V rou,
       AHL_OPERATIONS_B oper
WHERE  (
         TRUNC(rou.start_date_active)                               >= TRUNC(oper.start_date_active)
         AND
         TRUNC(NVL(oper.end_date_active, rou.start_date_active + 1)) > TRUNC(rou.start_date_active)
       )
AND    oper.operation_id = c_operation_id
AND    rou.route_id      = c_route_id;

-- Fix for bug# 6512803. Consider only scheduled resources.
-- Modified query to fetch operation duration as
-- sum of max durations across each secheduling sequence.
-- Bug # 8639648 -- start

CURSOR get_op_max_duration( c_operation_id NUMBER )
IS
SELECT NVL(SUM(RES_DURATION),0)
FROM   ( SELECT  MAX( duration ) RES_DURATION
       FROM     AHL_RT_OPER_RESOURCES
       WHERE    association_type_code = 'OPERATION'
       AND      scheduled_type_id     = 1
       AND      object_id             = c_operation_id
       GROUP BY schedule_seq
       );

-- Bug # 8639648 -- end

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_route_id IS NULL OR
       p_route_id = FND_API.G_MISS_NUM OR
       p_operation_id IS NULL OR
       p_operation_id = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN get_route_time_span( p_route_id, p_operation_id );
  OPEN get_op_max_duration( p_operation_id );

  FETCH get_route_time_span INTO x_rt_time_span;
  FETCH get_op_max_duration INTO x_op_max_res_duration;

  IF ( get_route_time_span%FOUND AND
       get_op_max_duration%FOUND ) THEN
    IF ( x_rt_time_span < x_op_max_res_duration ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_RES_DURATION_LONGER';
    END IF;
  END IF;

  CLOSE get_route_time_span;
  CLOSE get_op_max_duration;

END validate_rt_op_res_duration;

-- Procedure to validate whether the route / operation Start date is valid.
PROCEDURE validate_rt_oper_start_date
(
  p_object_id     IN  NUMBER,
  p_association_type    IN  VARCHAR2,
  p_start_date      IN  DATE,
  x_start_date      OUT NOCOPY DATE,
  x_msg_data      OUT NOCOPY VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2
)
IS

CURSOR get_rt_latest_start_date( c_route_id NUMBER )
IS
SELECT MAX( A.start_date_active )
FROM   AHL_ROUTES_APP_V A, AHL_ROUTES_APP_V B
WHERE  A.route_no = B.route_no
AND    A.route_id <> c_route_id
AND    B.route_id = c_route_id;

CURSOR get_op_latest_start_date( c_operation_id NUMBER )
IS
SELECT MAX( A.start_date_active )
FROM   AHL_OPERATIONS_B_KFV A, AHL_OPERATIONS_B_KFV B
WHERE  A.concatenated_segments = B.concatenated_segments
AND    A.operation_id <> c_operation_id
AND    B.operation_id = c_operation_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_start_date IS NULL OR
       p_start_date = FND_API.G_MISS_DATE ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_RM_ST_DATE_NULL';
    RETURN;
  END IF;

  IF ( p_association_type IS NOT NULL AND
       p_association_type <> FND_API.G_MISS_CHAR AND
       p_association_type = 'ROUTE' ) THEN

    OPEN get_rt_latest_start_date( p_object_id );

    FETCH get_rt_latest_start_date INTO x_start_date;

    IF ( get_rt_latest_start_date%FOUND ) THEN
      IF ( TRUNC( x_start_date )  > TRUNC( p_start_date ) ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_RM_ST_DATE_LESSER';
      END IF;
    END IF;

    CLOSE get_rt_latest_start_date;
  ELSIF ( p_association_type IS NOT NULL AND
    p_association_type <> FND_API.G_MISS_CHAR AND
    p_association_type = 'OPERATION' ) THEN

    OPEN get_op_latest_start_date( p_object_id );

    FETCH get_op_latest_start_date INTO x_start_date;

    IF ( get_op_latest_start_date%FOUND ) THEN
      IF ( TRUNC( x_start_date )  > TRUNC( p_start_date ) ) THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_RM_ST_DATE_LESSER';
      END IF;
    END IF;

    CLOSE get_op_latest_start_date;
  END IF;

END validate_rt_oper_start_date;

PROCEDURE validate_ApplnUsage
(
  p_object_id         IN  NUMBER,
  p_association_type    IN  VARCHAR2,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2
)
IS

l_appln_code VARCHAR2(30);
l_object_appln_code VARCHAR2(30);

CURSOR get_rt_ApplnUsage( c_route_id NUMBER )
IS
SELECT r.Application_usg_code
FROM   AHL_ROUTES_B r
WHERE  r.route_id = c_route_id
;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( (p_object_id IS NULL OR p_object_id = FND_API.G_MISS_NUM ) OR
  ( p_association_type IS NULL  OR  p_association_type = FND_API.G_MISS_CHAR ))
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MSG_PUB.add;
    RETURN;
  END IF;

AHL_UTIL_PKG.get_appln_usage
(
x_appln_code  => l_appln_code,
x_return_status => x_return_status
);

-- Application code is mandatory .
  IF x_return_status = FND_API.G_RET_STS_ERROR
  THEN
       x_msg_data := 'AHL_COM_APPLN_CODE_NOTNULL';
       FND_MESSAGE.set_name( 'AHL', 'AHL_COM_APPLN_CODE_NOTNULL' );
       FND_MSG_PUB.add;
       RETURN;
  END IF;

 IF  (  p_association_type = 'ROUTE' )
 THEN

    OPEN get_rt_ApplnUsage( p_object_id );

    FETCH get_rt_ApplnUsage INTO l_object_appln_code;

    IF get_rt_ApplnUsage%NOTFOUND
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_RM_INVALID_ROUTE';
      -- Balaji added code to push error data into fnd stack as a part of public API cleanup in 11510+
      FND_MESSAGE.set_name( 'AHL', 'AHL_RM_INVALID_ROUTE' );
      FND_MSG_PUB.add;
      CLOSE get_rt_ApplnUsage;
      RETURN;
    END IF;

    CLOSE get_rt_ApplnUsage;

 END IF;

  IF (l_object_appln_code<> l_appln_code)
  THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_data := 'AHL_COM_INVALID_APPLN';
        FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_APPLN' );
        FND_MSG_PUB.add;
  END IF;

END validate_ApplnUsage;

FUNCTION get_position_meaning
(
 p_position_path_id IN NUMBER,
 p_item_comp_detail_id IN NUMBER
)
RETURN VARCHAR2
IS
/*
CURSOR get_rec_from_id ( c_position_path_id NUMBER )
IS
SELECT DISTINCT
fnd.MEANING
FROM
ahl_mc_relationships mcr
, ahl_mc_headers_b mch
, ahl_mc_path_position_nodes mcp
, AHL_ROUTE_EFFECTIVITIES_V re
, fnd_lookup_values_vl fnd
, AHL_RT_OPER_MATERIALS AOB
WHERE
mch.mc_header_id = mcr.mc_header_id
and mch.mc_id = mcp.mc_id
and re.MC_ID = mch.MC_ID
and mch.version_number = nvl(mcp.version_number, mch.version_number)
and mcr.position_key = mcp.position_key
and mcp.sequence = (select max(sequence) from ahl_mc_path_position_nodes where path_position_id = nvl(c_position_path_id,-1))
and mcp.path_position_id = nvl(c_position_path_id,-1)
and fnd.LOOKUP_TYPE = 'AHL_POSITION_REFERENCE'
and fnd.LOOKUP_CODE = mcr.POSITION_REF_CODE
;
*/
l_position_path VARCHAR2(80) ; --amsriniv. Bug 6849831

BEGIN


    IF (
    ((p_position_path_id IS NOT NULL) AND (p_position_path_id <> FND_API.G_MISS_NUM ))
    AND
  ((p_item_comp_detail_id IS NULL ) OR (p_item_comp_detail_id = FND_API.G_MISS_NUM ))
    )
    THEN
    l_position_path := AHL_MC_PATH_POSITION_PVT.GET_POSREF_BY_ID(p_position_path_id);
    END IF ;

  RETURN l_position_path;

END get_position_meaning ;

FUNCTION get_source_composition
(
 p_position_path_id IN NUMBER,
 p_item_comp_detail_id IN NUMBER
)
RETURN VARCHAR2
IS

CURSOR get_item_comp ( c_item_comp_detail_id NUMBER )
IS
SELECT DISTINCT MTL.CONCATENATED_SEGMENTS
    , MTL.ORGANIZATION_CODE
FROM    AHL_ITEM_COMP_DETAILS ICD
    , AHL_ITEM_COMPOSITIONS CD
        , AHL_MTL_ITEMS_NON_OU_V MTL
WHERE   ICD.item_comp_detail_id = c_item_comp_detail_id
AND   CD.APPROVAL_STATUS_CODE ='COMPLETE'
AND   CD.item_composition_id = ICD.item_composition_id
AND   CD.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID
AND   CD.INVENTORY_MASTER_ORG_ID =  MTL.INVENTORY_ORG_ID
AND   nvl(trunc(CD.EFFECTIVE_END_DATE),trunc(sysdate+1)) > trunc(sysdate)
AND   nvl(trunc(ICD.EFFECTIVE_END_DATE),trunc(sysdate+1)) > trunc(sysdate)
;

CURSOR get_position_path ( c_position_path_id NUMBER , c_item_comp_detail_id NUMBER)
IS

-- new query uses view ahl_position_alternates_v
--AMSRINIV. Bug 5208104. Replacing below commented query with a new query for better performance
select distinct mtl.concatenated_segments,
                mtl.organization_code
from   (select kfv.inventory_item_id,
               mp.master_organization_id inventory_org_id,
               mp.organization_code,
               kfv.concatenated_segments
        from   mtl_system_items_kfv kfv,
               mtl_parameters mp
        where  kfv.organization_id = mp.organization_id
               and exists (select 'X'
                           from   mtl_parameters mp1
                           where  mp1.master_organization_id = kfv.organization_id
                                  and mp1.eam_enabled_flag = 'Y')) mtl,
       (select inventory_item_id,
               inventory_org_id
        from   ahl_position_alternates_v
        where  relationship_id = c_position_path_id) pal,
       (select item_composition_id,
               item_comp_detail_id
        from   ahl_item_comp_details
        where  nvl(trunc(effective_end_date),trunc(sysdate + 1)) > trunc(sysdate)
               and item_comp_detail_id = c_item_comp_detail_id) icd,
       (select icb.item_composition_id,
               icb.inventory_item_id,
               icb.inventory_master_org_id,
               decode(sign(trunc(nvl(icb.effective_end_date,sysdate + 1)) - trunc(sysdate)),1,icb.approval_status_code,'EXPIRED') approval_status_code,
               icb.effective_end_date effective_end_date
        from   ahl_item_compositions icb
        where  approval_status_code = 'COMPLETE'
               and nvl(trunc(effective_end_date),trunc(sysdate + 1)) > trunc(sysdate)) cd
where  pal.inventory_item_id = mtl.inventory_item_id
       and pal.inventory_org_id = mtl.inventory_org_id
       and pal.inventory_item_id = cd.inventory_item_id
       and pal.inventory_org_id = cd.inventory_master_org_id
       and cd.item_composition_id = icd.item_composition_id;


/*select distinct
mtl.concatenated_segments ,
mtl.organization_code
from
ahl_mtl_items_non_ou_v mtl,
ahl_position_alternates_v pal,
AHL_ITEM_COMP_V CD ,
AHL_ITEM_COMP_DETAILS ICD
where
pal.relationship_id = nvl(c_position_path_id,'-1')
and pal.inventory_item_id = mtl.INVENTORY_ITEM_ID
and pal.inventory_org_id = mtl.INVENTORY_ORG_ID
and pal.inventory_item_id = CD.inventory_item_id
and pal.inventory_org_id = CD.inventory_master_org_id
AND CD.APPROVAL_STATUS_CODE = 'COMPLETE'
AND CD.item_composition_id = ICD.item_composition_id
AND nvl(trunc(CD.EFFECTIVE_END_DATE),trunc(sysdate+1)) > trunc(sysdate)
AND nvl(trunc(ICD.EFFECTIVE_END_DATE),trunc(sysdate+1)) > trunc(sysdate)
AND ICD.ITEM_COMP_DETAIL_ID=c_item_comp_detail_id;*/


/* the previous query .
SELECT DISTINCT
  CD.concatenated_segments ,
  CD.organization_code
FROM
  ahl_mc_relationships mcr,
  ahl_mc_headers_b mch,
  ahl_mc_path_position_nodes mcp,
  ahl_item_associations_v igass ,
  AHL_ROUTE_EFFECTIVITIES re ,
--  ahl_mtl_items_non_ou_v mtl,
  AHL_ITEM_COMP_V CD ,
  AHL_ITEM_COMP_DETAILS ICD
WHERE
  mch.mc_header_id = mcr.mc_header_id
  and mch.mc_id = mcp.mc_id
  and re.MC_ID = mch.MC_ID
  and mch.version_number = nvl(mcp.version_number, mch.version_number)
  and mcr.position_key = mcp.position_key
  and mcp.sequence = (select max(sequence) from ahl_mc_path_position_nodes where path_position_id = nvl(p_position_path_id,'-1'))
  and mcp.path_position_id = nvl(p_position_path_id,'-1')
  and mcr.item_group_id = igass.item_group_id
  and igass.INVENTORY_ITEM_ID = CD.inventory_item_id
  and igass.INVENTORY_ORG_ID = CD.inventory_master_org_id
  AND CD.APPROVAL_STATUS_CODE = 'COMPLETE'
  AND CD.item_composition_id = ICD.item_composition_id
  AND nvl(trunc(CD.EFFECTIVE_END_DATE),trunc(sysdate-1)) < trunc(sysdate)
  AND ICD.ITEM_COMP_DETAIL_ID=c_item_comp_detail_id
  order by 1
 ;
*/
l_item_comp_detail_id NUMBER;
l_position_path VARCHAR2(80);--amsriniv. Bug 6849831
l_concatenated_segments VARCHAR2(40) ;
l_organization_code VARCHAR2(3) ;
l_source_composition VARCHAR2(73) ;


BEGIN
IF (
    ((p_position_path_id IS NOT NULL) AND (p_position_path_id <> FND_API.G_MISS_NUM ))
    AND
  ((p_item_comp_detail_id IS NULL ) OR (p_item_comp_detail_id = FND_API.G_MISS_NUM ))
    )
    THEN
--    l_source_composition := AHL_MC_PATH_POSITION_PVT.GET_POSREF_BY_ID(p_position_path_id);
    l_source_composition := ' ';
    END IF;

    IF (
    ((p_position_path_id IS NULL) OR (p_position_path_id = FND_API.G_MISS_NUM ))
    AND
  ((p_item_comp_detail_id IS NOT NULL ) AND (p_item_comp_detail_id <> FND_API.G_MISS_NUM ))
    )
    THEN

  OPEN get_item_comp( p_item_comp_detail_id );
    FETCH get_item_comp INTO l_concatenated_segments,l_organization_code ;

    IF get_item_comp%FOUND THEN
       l_source_composition := '('||l_concatenated_segments||','||l_organization_code||')';
    END IF;
  CLOSE get_item_comp;
    END IF ;

    IF (
    ((p_position_path_id IS NOT NULL) AND (p_position_path_id <> FND_API.G_MISS_NUM ))
    AND
  ((p_item_comp_detail_id IS NOT NULL ) AND (p_item_comp_detail_id <> FND_API.G_MISS_NUM ))
    )
    THEN

  OPEN get_item_comp( p_item_comp_detail_id );
    FETCH get_item_comp INTO l_concatenated_segments,l_organization_code ;


    IF get_item_comp%FOUND THEN
   IF ((l_concatenated_segments IS NOT NULL ) AND (l_organization_code IS NOT NULL)) THEN
    OPEN get_position_path( p_position_path_id , p_item_comp_detail_id );
      FETCH get_position_path INTO l_concatenated_segments,l_organization_code ;

    IF get_position_path%FOUND THEN
     IF ((l_concatenated_segments IS NOT NULL ) AND (l_organization_code IS NOT NULL)) THEN
        l_position_path := AHL_MC_PATH_POSITION_PVT.GET_POSREF_BY_ID(p_position_path_id);
      IF l_position_path IS NOT NULL THEN
       l_source_composition := l_position_path||':('||l_concatenated_segments||','||l_organization_code||')';
      END IF;
     END IF ;
      END IF;
      CLOSE get_position_path;
    CLOSE get_item_comp;
   END IF;
    END IF;

  END IF ;

  RETURN l_source_composition;

END get_source_composition ;

--Procedure to get Operation id out of Operation Name and Revision
PROCEDURE Operation_Number_To_Id
(
 p_operation_number IN    VARCHAR2,
 p_operation_revision IN    NUMBER,
 x_operation_id   OUT NOCOPY  NUMBER,
 x_return_status  OUT NOCOPY  VARCHAR2
)
IS

-- Cursor for selecting operation id.
CURSOR oper_name_rev_csr_type (p_operation_number IN VARCHAR2, p_operation_revision IN NUMBER)
IS
SELECT operation_id
FROM ahl_operations_vl
WHERE concatenated_segments = p_operation_number
  AND
  revision_number = p_operation_revision;

l_operation_id     NUMBER;
l_api_name  CONSTANT VARCHAR2(30) := 'OPERATION_NUMBER_TO_ID';

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;
 OPEN oper_name_rev_csr_type(p_operation_number, p_operation_revision);
 FETCH oper_name_rev_csr_type INTO l_operation_id;
 CLOSE oper_name_rev_csr_type;

 IF l_operation_id IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AHL','AHL_RM_INV_OPER_NO_REV');
    FND_MESSAGE.SET_TOKEN('NUMBER', p_operation_number);
    FND_MESSAGE.SET_TOKEN('REVISION', p_operation_revision);
    FND_MSG_PUB.ADD;
    IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string
      (
        fnd_log.level_error,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'INVALID Operation Name AND Operation Revision'
      );
    END IF;
 ELSE
    x_operation_id := l_operation_id;
 END IF;

END Operation_Number_To_Id;


--Procedure to get Route id out of Route Number and Revision
PROCEDURE Route_Number_To_Id
(
 p_route_number   IN    VARCHAR2,
 p_route_revision IN    NUMBER,
 x_route_id   OUT NOCOPY  NUMBER,
 x_return_status  OUT NOCOPY  VARCHAR2
)
IS

-- Cursor for selecting route id.
CURSOR route_name_rev_csr_type (p_route_number IN VARCHAR2, p_route_revision IN NUMBER)
IS
SELECT route_id
FROM ahl_routes_app_v
WHERE UPPER( TRIM(route_no)) = UPPER(TRIM(p_route_number))
  AND
  revision_number = p_route_revision;

l_route_id     NUMBER;
l_api_name  CONSTANT VARCHAR2(30) := 'ROUTE_NUMBER_TO_ID';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 OPEN route_name_rev_csr_type(p_route_number, p_route_revision);
 FETCH route_name_rev_csr_type INTO l_route_id;
 CLOSE route_name_rev_csr_type;

 IF l_route_id IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AHL','AHL_RM_INV_ROUTE_NO_REV');
    FND_MESSAGE.SET_TOKEN('NUMBER', p_route_number);
    FND_MESSAGE.SET_TOKEN('REVISION', p_route_revision);
    FND_MSG_PUB.ADD;
    IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string
      (
        fnd_log.level_error,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'INVALID Route Name AND Route Revision'
      );
    END IF;
 ELSE
    x_route_id := l_route_id;
 END IF;

END Route_Number_To_Id;

END AHL_RM_ROUTE_UTIL;

/
