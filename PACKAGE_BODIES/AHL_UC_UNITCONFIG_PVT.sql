--------------------------------------------------------
--  DDL for Package Body AHL_UC_UNITCONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_UNITCONFIG_PVT" AS
/* $Header: AHLVUCXB.pls 120.3.12010000.2 2008/11/28 07:05:57 sathapli ship $ */

-- Define global internal variables
G_PKG_NAME VARCHAR2(30) := 'AHL_UC_UNITCONFIG_PVT';

CURSOR get_uc_header(c_uc_header_id number) IS
  SELECT uc_header_id,
         object_version_number,
         uc_name,
         uc_status_code,
         active_uc_status_code,
         csi_instance_id,
         instance_number,
         active_start_date,
         active_end_date,
         parent_uc_header_id,
         mc_header_id,
         mc_name,
         mc_revision,
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
    FROM ahl_unit_config_headers_v
   WHERE uc_header_id = c_uc_header_id;

-- Procedure to clear the LOV attributes' ID to NULL or G_MISS Values if its
-- corresponding displayed field is NULL or G_MISS values
PROCEDURE clear_lov_attribute_ids(
  p_x_uc_header_rec       IN OUT NOCOPY  ahl_uc_instance_pvt.uc_header_rec_type)
IS
BEGIN
  IF (p_x_uc_header_rec.instance_number IS NULL) THEN
    p_x_uc_header_rec.instance_id := NULL;
  ELSIF (p_x_uc_header_rec.instance_number = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.instance_id := FND_API.G_MISS_NUM;
  END IF;
  IF (p_x_uc_header_rec.mc_name IS NULL AND
      p_x_uc_header_rec.mc_revision IS NULL) THEN
    p_x_uc_header_rec.mc_header_id := NULL;
  ELSIF (p_x_uc_header_rec.mc_name = FND_API.G_MISS_CHAR AND
      p_x_uc_header_rec.mc_revision = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.mc_header_id := FND_API.G_MISS_NUM;
  END IF;
END clear_lov_attribute_ids;

-- Procedure to change G_MISS values to NULL in case they are passed during creation
PROCEDURE nullify_attributes(
  p_x_uc_header_rec       IN OUT NOCOPY ahl_uc_instance_pvt.uc_header_rec_type)
IS
BEGIN
  IF (p_x_uc_header_rec.active_uc_status_code = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.active_uc_status_code := null;
  END IF;
  IF (p_x_uc_header_rec.mc_header_id = FND_API.G_MISS_NUM) THEN
    p_x_uc_header_rec.mc_header_id := null;
  END IF;
  IF (p_x_uc_header_rec.mc_name = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.mc_name := null;
  END IF;
  IF (p_x_uc_header_rec.mc_revision = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.mc_revision := null;
  END IF;
  IF (p_x_uc_header_rec.parent_uc_header_id = FND_API.G_MISS_NUM) THEN
    p_x_uc_header_rec.parent_uc_header_id := null;
  END IF;
  IF (p_x_uc_header_rec.active_end_date = FND_API.G_MISS_DATE) THEN
    p_x_uc_header_rec.active_end_date := null;
  END IF;
  IF (p_x_uc_header_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute_category := null;
  END IF;
  IF (p_x_uc_header_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute1 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute2 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute3 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute4 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute5 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute6 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute7 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute8 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute9 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute10 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute11 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute12 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute13 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute14 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute15 := null;
  END IF;
END nullify_attributes;

--Procedure to convert G_MISS values to NULL and NULL to OLD values during updating

PROCEDURE convert_attributes(
  p_x_uc_header_rec       IN OUT NOCOPY   ahl_uc_instance_pvt.uc_header_rec_type,
  x_return_status         OUT NOCOPY      VARCHAR2)
IS
  l_old_uc_header_rec get_uc_header%ROWTYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN  get_uc_header( p_x_uc_header_rec.uc_header_id );
  FETCH get_uc_header INTO l_old_uc_header_rec;
  IF ( get_uc_header%NOTFOUND ) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
    FND_MESSAGE.set_token('UC_HEADER_ID', p_x_uc_header_rec.uc_header_id);
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  IF ( l_old_uc_header_rec.object_version_number <>
       p_x_uc_header_rec.object_version_number ) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE get_uc_header;

  IF (p_x_uc_header_rec.uc_name IS NULL) THEN
    p_x_uc_header_rec.uc_name := l_old_uc_header_rec.uc_name;
  ELSIF (p_x_uc_header_rec.uc_name = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.uc_name := null;
  END IF;
  IF (p_x_uc_header_rec.mc_header_id IS NULL) THEN
    p_x_uc_header_rec.mc_header_id := l_old_uc_header_rec.mc_header_id;
  ELSIF (p_x_uc_header_rec.mc_header_id = FND_API.G_MISS_NUM) THEN
    p_x_uc_header_rec.mc_header_id := null;
  END IF;
  IF (p_x_uc_header_rec.mc_name IS NULL) THEN
    p_x_uc_header_rec.mc_name := l_old_uc_header_rec.mc_name;
  ELSIF (p_x_uc_header_rec.mc_name = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.mc_name := null;
  END IF;
  IF (p_x_uc_header_rec.mc_revision IS NULL) THEN
    p_x_uc_header_rec.mc_revision := l_old_uc_header_rec.mc_revision;
  ELSIF (p_x_uc_header_rec.mc_revision = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.mc_revision := null;
  END IF;
  IF (p_x_uc_header_rec.instance_id IS NULL) THEN
    p_x_uc_header_rec.instance_id := l_old_uc_header_rec.csi_instance_id;
  ELSIF (p_x_uc_header_rec.instance_id = FND_API.G_MISS_NUM) THEN
    p_x_uc_header_rec.instance_id := null;
  END IF;
  IF (p_x_uc_header_rec.instance_number IS NULL) THEN
    p_x_uc_header_rec.instance_number := l_old_uc_header_rec.instance_number;
  ELSIF (p_x_uc_header_rec.instance_number = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.instance_number := null;
  END IF;
  IF (p_x_uc_header_rec.unit_config_status_code IS NULL) THEN
    p_x_uc_header_rec.unit_config_status_code := l_old_uc_header_rec.uc_status_code;
  ELSIF (p_x_uc_header_rec.unit_config_status_code = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.unit_config_status_code := null;
  END IF;
  IF (p_x_uc_header_rec.active_start_date IS NULL) THEN
    p_x_uc_header_rec.active_start_date := l_old_uc_header_rec.active_start_date;
  ELSIF (p_x_uc_header_rec.active_start_date = FND_API.G_MISS_DATE) THEN
    p_x_uc_header_rec.active_start_date := null;
  END IF;
  IF (p_x_uc_header_rec.active_end_date IS NULL) THEN
    p_x_uc_header_rec.active_end_date := l_old_uc_header_rec.active_end_date;
  ELSIF (p_x_uc_header_rec.active_end_date = FND_API.G_MISS_DATE) THEN
    p_x_uc_header_rec.active_end_date := null;
  END IF;
  IF (p_x_uc_header_rec.active_uc_status_code IS NULL) THEN
    p_x_uc_header_rec.active_uc_status_code := l_old_uc_header_rec.active_uc_status_code;
  ELSIF (p_x_uc_header_rec.active_uc_status_code = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.active_uc_status_code := null;
  END IF;
  IF (p_x_uc_header_rec.parent_uc_header_id IS NULL) THEN
    p_x_uc_header_rec.parent_uc_header_id := l_old_uc_header_rec.parent_uc_header_id;
  ELSIF (p_x_uc_header_rec.parent_uc_header_id = FND_API.G_MISS_NUM) THEN
    p_x_uc_header_rec.parent_uc_header_id := null;
  END IF;
  IF (p_x_uc_header_rec.attribute_category IS NULL) THEN
    p_x_uc_header_rec.attribute_category := l_old_uc_header_rec.attribute_category;
  ELSIF (p_x_uc_header_rec.attribute_category = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute_category := null;
  END IF;
  IF (p_x_uc_header_rec.attribute1 IS NULL) THEN
    p_x_uc_header_rec.attribute1 := l_old_uc_header_rec.attribute1;
  ELSIF (p_x_uc_header_rec.attribute1 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute1 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute2 IS NULL) THEN
    p_x_uc_header_rec.attribute2 := l_old_uc_header_rec.attribute2;
  ELSIF (p_x_uc_header_rec.attribute2 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute2 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute3 IS NULL) THEN
    p_x_uc_header_rec.attribute3 := l_old_uc_header_rec.attribute3;
  ELSIF (p_x_uc_header_rec.attribute3 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute3 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute4 IS NULL) THEN
    p_x_uc_header_rec.attribute4 := l_old_uc_header_rec.attribute4;
  ELSIF (p_x_uc_header_rec.attribute4 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute4 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute5 IS NULL) THEN
    p_x_uc_header_rec.attribute5 := l_old_uc_header_rec.attribute5;
  ELSIF (p_x_uc_header_rec.attribute5 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute5 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute6 IS NULL) THEN
    p_x_uc_header_rec.attribute6 := l_old_uc_header_rec.attribute6;
  ELSIF (p_x_uc_header_rec.attribute6 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute6 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute7 IS NULL) THEN
    p_x_uc_header_rec.attribute7 := l_old_uc_header_rec.attribute7;
  ELSIF (p_x_uc_header_rec.attribute7 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute7 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute8 IS NULL) THEN
    p_x_uc_header_rec.attribute8 := l_old_uc_header_rec.attribute8;
  ELSIF (p_x_uc_header_rec.attribute8 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute8 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute9 IS NULL) THEN
    p_x_uc_header_rec.attribute9 := l_old_uc_header_rec.attribute9;
  ELSIF (p_x_uc_header_rec.attribute9 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute9 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute10 IS NULL) THEN
    p_x_uc_header_rec.attribute10 := l_old_uc_header_rec.attribute10;
  ELSIF (p_x_uc_header_rec.attribute10 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute10 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute11 IS NULL) THEN
    p_x_uc_header_rec.attribute11 := l_old_uc_header_rec.attribute11;
  ELSIF (p_x_uc_header_rec.attribute11 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute11 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute12 IS NULL) THEN
    p_x_uc_header_rec.attribute12 := l_old_uc_header_rec.attribute12;
  ELSIF (p_x_uc_header_rec.attribute12 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute12 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute13 IS NULL) THEN
    p_x_uc_header_rec.attribute13 := l_old_uc_header_rec.attribute13;
  ELSIF (p_x_uc_header_rec.attribute13 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute13 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute14 IS NULL) THEN
    p_x_uc_header_rec.attribute14 := l_old_uc_header_rec.attribute14;
  ELSIF (p_x_uc_header_rec.attribute14 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute14 := null;
  END IF;
  IF (p_x_uc_header_rec.attribute15 IS NULL) THEN
    p_x_uc_header_rec.attribute15 := l_old_uc_header_rec.attribute15;
  ELSIF (p_x_uc_header_rec.attribute15 = FND_API.G_MISS_CHAR) THEN
    p_x_uc_header_rec.attribute15 := null;
  END IF;
END convert_attributes;

-- Procedure to validate individual record attributes
PROCEDURE validate_parameters(
  p_uc_header_rec         IN  ahl_uc_instance_pvt.uc_header_rec_type,
  x_return_status         OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (p_uc_header_rec.mc_name IS NULL AND
      p_uc_header_rec.mc_revision IS NOT NULL) OR
     (p_uc_header_rec.mc_name IS NOT NULL AND
      p_uc_header_rec.mc_revision IS NULL) THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_MC_NAME_REV_INVALID' );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
END;

-- Procedure to validate mc_header
PROCEDURE validate_mc_header(
  p_mc_name              IN VARCHAR2,
  p_mc_revision          IN VARCHAR2,
  p_x_mc_header_id       IN OUT NOCOPY NUMBER,
  x_relationship_id      OUT NOCOPY VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2)
IS
  l_mc_header_id      NUMBER;
  l_relationship_id   NUMBER;
  CURSOR get_rec_from_value(c_mc_name varchar2, c_mc_revision varchar2) IS
    SELECT H.mc_header_id,
           R.relationship_id
      FROM ahl_mc_headers_b H,
           ahl_mc_relationships R
     WHERE H.name = c_mc_name
       AND H.revision = c_mc_revision
       AND H.mc_header_id = R.mc_header_id
       AND R.parent_relationship_id IS NULL
       AND trunc(nvl(R.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(R.active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  CURSOR get_rec_from_id(c_mc_header_id NUMBER ) IS
    SELECT H.mc_header_id,
           R.relationship_id
      FROM ahl_mc_headers_b H,
           ahl_mc_relationships R
     WHERE H.mc_header_id = c_mc_header_id
       AND H.mc_header_id = R.mc_header_id
       AND R.parent_relationship_id IS NULL
       AND trunc(nvl(R.active_start_date,SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(R.active_end_date, SYSDATE+1)) > trunc(SYSDATE);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (p_mc_name IS NULL OR p_mc_revision IS NULL) AND
      p_x_mc_header_id IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.set_name('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
    FND_MSG_PUB.add;
  ELSIF (p_mc_name IS NULL OR p_mc_revision IS NULL) AND
         p_x_mc_header_id IS NOT NULL THEN
    OPEN get_rec_from_id(p_x_mc_header_id);
    FETCH get_rec_from_id INTO l_mc_header_id, l_relationship_id;
    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('AHL', 'AHL_UC_MC_HEADER_ID_INVALID');
      FND_MESSAGE.set_token('MC_HEADER_ID', p_x_mc_header_id);
      FND_MSG_PUB.add;
    ELSE
      p_x_mc_header_id := l_mc_header_id;
      x_relationship_id := l_relationship_id;
    END IF;
    CLOSE get_rec_from_id;
  ELSIF p_mc_name IS NOT NULL AND p_mc_revision IS NOT NULL THEN
    OPEN get_rec_from_value(p_mc_name, p_mc_revision);
    LOOP
      FETCH get_rec_from_value INTO l_mc_header_id, l_relationship_id;
      EXIT WHEN get_rec_from_value%NOTFOUND;
    END LOOP;
    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('AHL', 'AHL_UC_MC_HEADER_INVALID');
      FND_MESSAGE.set_token('MC_NAME', p_mc_name);
      FND_MESSAGE.set_token('MC_REV', p_mc_revision);
      FND_MSG_PUB.add;
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_mc_header_id := l_mc_header_id;
      x_relationship_id := l_relationship_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('AHL', 'AHL_UC_MC_HEADER_INVALID');
      FND_MESSAGE.set_token('MC_NAME', p_mc_name);
      FND_MESSAGE.set_token('MC_REV', p_mc_revision);
      FND_MSG_PUB.add;
    END IF;
    CLOSE get_rec_from_value;
  END IF;
END validate_mc_header;

-- Procedure to validate csi_item_instance
PROCEDURE validate_csi_instance(
  p_instance_num         IN csi_item_instances.instance_number%TYPE,
  p_x_instance_id        IN OUT NOCOPY NUMBER,
  p_relationship_id      IN NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2)
IS
  l_instance_id      number;
  --The following cursors don't consider the profile option fnd_profile.value('AHL_VALIDATE_ALT_ITEM_ORG')
  --That is assuming fnd_profile.value('AHL_VALIDATE_ALT_ITEM_ORG')='Y'
  CURSOR get_rec_from_value(c_instance_num csi_item_instances.instance_number%TYPE,
                            c_relationship_id NUMBER) IS
  --Added DISTINCT to the following two queries for fixing bug 4102152, Jerry on 01/04/2005
    SELECT distinct C.instance_id
      FROM csi_item_instances C,
           ahl_mc_relationships R,
           ahl_item_associations_b A
     WHERE C.instance_number = c_instance_num
       AND R.relationship_id = c_relationship_id
       AND R.item_group_id = A.item_group_id
       AND C.inventory_item_id = A.inventory_item_id
       AND C.inv_master_organization_id = A.inventory_org_id
       -- SATHAPLI::FP Bug 7498459, 27-Nov-2008 - Even INVENTORY instances are allowed for UC header creation.
       -- AND C.location_type_code NOT IN ('PO','IN-TRANSIT','PROJECT','INVENTORY')
       AND C.location_type_code NOT IN ('PO','IN-TRANSIT','PROJECT')
       AND (A.revision IS NULL OR A.revision = C.inventory_revision) --Added by Jerry on 03/31/2005
       AND A.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
       --Added by Jerry on 04/26/2005
       AND trunc(nvl(C.active_end_date, SYSDATE+1)) > trunc(SYSDATE)

       -- SATHAPLI::Bug# 5347338 fix
       /*
       AND NOT EXISTS (SELECT 'X'
                         FROM csi_ii_relationships I
                        WHERE I.subject_id = C.instance_id
                          AND I.relationship_type_code = 'COMPONENT-OF'
                          AND trunc(nvl(I.active_start_date,SYSDATE)) <= trunc(SYSDATE)
                          AND trunc(nvl(I.active_end_date, SYSDATE+1)) > trunc(SYSDATE))
       */

       AND NOT EXISTS (SELECT 'X'
                         FROM ahl_unit_config_headers H
                        WHERE H.csi_item_instance_id = C.instance_id
                          AND trunc(nvl(H.active_end_date, SYSDATE+1)) > trunc(SYSDATE));
  CURSOR get_rec_from_id(c_instance_id NUMBER, c_relationship_id NUMBER) IS
    SELECT distinct C.instance_id
      FROM csi_item_instances C,
           ahl_mc_relationships R,
           ahl_item_associations_b A
     WHERE C.instance_id = c_instance_id
       AND R.relationship_id = c_relationship_id
       AND R.item_group_id = A.item_group_id
       AND C.inventory_item_id = A.inventory_item_id
       AND C.inv_master_organization_id = A.inventory_org_id
       -- SATHAPLI::FP Bug 7498459, 27-Nov-2008 - Even INVENTORY instances are allowed for UC header creation.
       -- AND C.location_type_code NOT IN ('PO','IN-TRANSIT','PROJECT','INVENTORY')
       AND C.location_type_code NOT IN ('PO','IN-TRANSIT','PROJECT')
       AND (A.revision IS NULL OR A.revision = C.inventory_revision) --Added by Jerry on 03/31/2005
       AND A.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
       --Added by Jerry on 04/26/2005
       AND trunc(nvl(C.active_end_date, SYSDATE+1)) > trunc(SYSDATE)

       -- SATHAPLI::Bug# 5347338 fix
       /*
       AND NOT EXISTS (SELECT 'X'
                         FROM csi_ii_relationships I
                        WHERE I.subject_id = C.instance_id
                          AND I.relationship_type_code = 'COMPONENT-OF'
                          AND trunc(nvl(I.active_start_date,SYSDATE)) <= trunc(SYSDATE)
                          AND trunc(nvl(I.active_end_date, SYSDATE+1)) > trunc(SYSDATE))
       */

       AND NOT EXISTS (SELECT 'X'
                         FROM ahl_unit_config_headers H
                        WHERE H.csi_item_instance_id = C.instance_id
                          AND trunc(nvl(H.active_end_date, SYSDATE+1)) > trunc(SYSDATE));
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_instance_num IS NULL AND p_x_instance_id IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.set_name('AHL', 'AHL_COM_INVALID_PROCEDURE_CALL');
    FND_MSG_PUB.add;
  ELSIF p_instance_num IS NULL AND p_x_instance_id IS NOT NULL  THEN
    OPEN get_rec_from_id(p_x_instance_id, p_relationship_id);
    FETCH get_rec_from_id INTO l_instance_id;
    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('AHL', 'AHL_UC_CSII_INVALID');
      FND_MESSAGE.set_token('CSII', p_x_instance_id);
      FND_MSG_PUB.add;
    END IF;
    CLOSE get_rec_from_id;
  ELSIF p_instance_num IS NOT NULL THEN
    OPEN get_rec_from_value(p_instance_num, p_relationship_id);
    LOOP
      FETCH get_rec_from_value INTO l_instance_id;
      EXIT WHEN get_rec_from_value%NOTFOUND;
    END LOOP;
    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('AHL', 'AHL_UC_CSII_INVALID');
      FND_MESSAGE.set_token('CSII', p_instance_num);
      FND_MSG_PUB.add;
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_instance_id := l_instance_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('AHL', 'AHL_UC_CSII_INVALID');
      FND_MESSAGE.set_token('CSII', p_instance_num);
      FND_MSG_PUB.add;
    END IF;
    CLOSE get_rec_from_value;
  END IF;
END validate_csi_instance;

-- Procedure to validate individual record attributes
PROCEDURE validate_attributes(
  p_uc_header_rec         IN  ahl_uc_instance_pvt.uc_header_rec_type,
  p_dml_operation         IN  VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2)
IS
  CURSOR check_uc_name1(c_uc_name varchar2) IS
    SELECT 'x'
    FROM ahl_unit_config_headers
    WHERE name = c_uc_name;
  CURSOR check_uc_name2(c_uc_name varchar2, c_uc_header_id number) IS
    SELECT 'x'
    FROM ahl_unit_config_headers
    WHERE name = c_uc_name
    AND unit_config_header_id <> c_uc_header_id;
  CURSOR check_uc_name3(c_uc_header_id number) IS
    SELECT name
    FROM ahl_unit_config_headers
    WHERE unit_config_header_id = c_uc_header_id;
  l_dummy             varchar2(1);
  l_name              check_uc_name3%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Check if name is unique when creating or updating a UC header record
  IF p_dml_operation = 'C' THEN
    OPEN check_uc_name1(p_uc_header_rec.uc_name);
    FETCH check_uc_name1 INTO l_dummy;
    IF check_uc_name1%FOUND THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_NAME_DUPLICATE' );
      FND_MESSAGE.set_token( 'NAME', p_uc_header_rec.uc_name );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE check_uc_name1;
  ELSIF p_dml_operation = 'U' THEN
    OPEN check_uc_name2(p_uc_header_rec.uc_name, p_uc_header_rec.uc_header_id);
    FETCH check_uc_name2 INTO l_dummy;
    IF check_uc_name2%FOUND THEN
      FND_MESSAGE.set_name( 'AHL','AHL_UC_NAME_DUPLICATE' );
      FND_MESSAGE.set_token( 'NAME', p_uc_header_rec.uc_name );
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE check_uc_name2;

    -- UC name change is only allowed when the unit_config_status is DRAFT
    IF p_uc_header_rec.unit_config_status_code NOT IN ('DRAFT', 'APPROVAL_REJECTED') THEN
      OPEN check_uc_name3(p_uc_header_rec.uc_header_id);
      FETCH check_uc_name3 INTO l_name;
      IF check_uc_name3%FOUND AND (l_name.name <> p_uc_header_rec.uc_name) THEN
        FND_MESSAGE.set_name( 'AHL','AHL_UC_NAME_CHANGE_UNALLOWED' );
        FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      CLOSE check_uc_name3;
    END IF;
  END IF;
  -- Check name is not null. This procedure is executed after nullify_attributes
  -- (create) or convert_attributes(update), so the check is the same for creation
  -- and update.
  IF p_uc_header_rec.uc_name is NULL THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_NAME_NULL');
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  -- The following checks are actually not really necessary.
  -- Check if the master_config_id contains a null value.
  IF p_uc_header_rec.mc_header_id IS NULL THEN
    FND_MESSAGE.set_name('AHL','AHL_MC_HEADER_ID_INVALID');
    FND_MESSAGE.set_token('MC_HEADER_ID', p_uc_header_rec.mc_header_id);
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  -- Check if the csi_item_instance_id contains a null value.
  IF p_uc_header_rec.instance_id IS NULL THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_INSTANCE_NULL');
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  -- Check if the unit_config_status_code contains a null value.
  IF p_uc_header_rec.unit_config_status_code IS NULL THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_CONFIG_STATUS_NULL');
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

END validate_attributes;

-- Define Procedure create_uc_header --
-- This API is used to create a UC header record in ahl_unit_config_headers
PROCEDURE create_uc_header(
  p_api_version        IN            NUMBER     := 1.0,
  p_init_msg_list      IN            VARCHAR2   := FND_API.G_FALSE,
  p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_module_type        IN            VARCHAR2   := NULL,
  x_return_status      OUT NOCOPY    VARCHAR2,
  x_msg_count          OUT NOCOPY    NUMBER,
  x_msg_data           OUT NOCOPY    VARCHAR2,
  p_x_uc_header_rec    IN OUT NOCOPY ahl_uc_instance_pvt.uc_header_rec_type)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'create_uc_header';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_relationship_id           NUMBER;
  l_serial_number             csi_item_instances.serial_number%TYPE;
  l_mfg_serial_number_flag    csi_item_instances.mfg_serial_number_flag%TYPE;
  l_serial_number_tag         csi_iea_values.attribute_value%TYPE;
  l_object_version_number     NUMBER;
  l_return_val                BOOLEAN;
  l_transaction_type_id       NUMBER;
  l_attribute_id              NUMBER;
  l_attribute_value_id        NUMBER;
  l_attribute_value           csi_iea_values.attribute_value%TYPE;
  l_csi_instance_rec          csi_datastructures_pub.instance_rec;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_csi_extend_attrib_rec     csi_datastructures_pub.extend_attrib_values_rec;
  l_csi_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;

  CURSOR get_serial_number(c_instance_id NUMBER) IS
    SELECT serial_number, mfg_serial_number_flag
      FROM csi_item_instances
     WHERE instance_id = c_instance_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT create_uc_header;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  -- If the module type is JSP, then default values for ID columns of LOV attributes

  IF ( p_module_type = 'JSP' ) THEN
    clear_lov_attribute_ids(p_x_uc_header_rec);
  END IF;
  -- Set unit_config_status_code to 'DRAFT'
  p_x_uc_header_rec.unit_config_status_code := 'DRAFT';
  -- Nullify G_MISS values of optional fields
  nullify_attributes(p_x_uc_header_rec);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   ': after nullify_attributes');
  END IF;

  validate_parameters(p_x_uc_header_rec, l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  validate_mc_header(p_x_uc_header_rec.mc_name,
                     p_x_uc_header_rec.mc_revision,
                     p_x_uc_header_rec.mc_header_id,
                     l_relationship_id,
                     l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --dbms_output.put_line('after mc_header validate and mc_name '|| p_x_uc_header_rec.mc_name);
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   ': after validate_mc_header and l_relationship_id ='||l_relationship_id);
  END IF;

  --IF (p_module_type = 'JSP') THEN
  --Commented out the condition on 10/18/2005 by Jerry to fix bug 4612418
    validate_csi_instance(p_x_uc_header_rec.instance_number,
                          p_x_uc_header_rec.instance_id,
                          l_relationship_id,
                          l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  --END IF;

  -- Validate all attributes (Item level validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    validate_attributes(p_x_uc_header_rec, 'C', l_return_status);
    -- If any severe error occurs, then, abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
                   ': aafter validate_attributes');
  END IF;

  -- Get the unit_config_header_id from the Sequence
  SELECT AHL_UNIT_CONFIG_HEADERS_S.NEXTVAL
  INTO   p_x_uc_header_rec.uc_header_id
  FROM   DUAL;
  p_x_uc_header_rec.object_version_number := 1;

  -- Insert the record into table ahl_unit_config_headers
  INSERT INTO ahl_unit_config_headers(
    unit_config_header_id,
    object_version_number,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    name,
    master_config_id,
    csi_item_instance_id,
    unit_config_status_code,
    active_start_date,
    active_end_date,
    active_uc_status_code,
    parent_uc_header_id,
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
    attribute15)
    VALUES(
    p_x_uc_header_rec.uc_header_id,
    p_x_uc_header_rec.object_version_number,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    fnd_global.login_id,
    p_x_uc_header_rec.uc_name,
    p_x_uc_header_rec.mc_header_id,
    p_x_uc_header_rec.instance_id,
    p_x_uc_header_rec.unit_config_status_code,
    p_x_uc_header_rec.active_start_date,
    p_x_uc_header_rec.active_end_date,
    p_x_uc_header_rec.active_uc_status_code,
    p_x_uc_header_rec.parent_uc_header_id,
    p_x_uc_header_rec.attribute_category,
    p_x_uc_header_rec.attribute1,
    p_x_uc_header_rec.attribute2,
    p_x_uc_header_rec.attribute3,
    p_x_uc_header_rec.attribute4,
    p_x_uc_header_rec.attribute5,
    p_x_uc_header_rec.attribute6,
    p_x_uc_header_rec.attribute7,
    p_x_uc_header_rec.attribute8,
    p_x_uc_header_rec.attribute9,
    p_x_uc_header_rec.attribute10,
    p_x_uc_header_rec.attribute11,
    p_x_uc_header_rec.attribute12,
    p_x_uc_header_rec.attribute13,
    p_x_uc_header_rec.attribute14,
    p_x_uc_header_rec.attribute15);

  -- Insert into the exactly same record into ahl_unit_config_headers_h
  ahl_util_uc_pkg.copy_uc_header_to_history(p_x_uc_header_rec.uc_header_id, l_return_status);
  --IF history copy failed, then don't raise exception, just add the message to the message stack
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
    FND_MSG_PUB.add;
  END IF;

  --Need to check if the instance picked from CSI with serial_number has a serial_no_tag, and
  --if not, we have to derive its value according to mfg_serail_number_flag ('Y'->'INVENTORY',
  --assuming CSI has the validation to ensure the serial_number exisiting in table
  --mfg_searil_numbers, otherwise it is 'TEMPORARY'
  OPEN get_serial_number(p_x_uc_header_rec.instance_id);
  FETCH get_serial_number INTO l_serial_number, l_mfg_serial_number_flag;
  IF get_serial_number%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_CSII_INVALID');
    FND_MESSAGE.set_token('CSII', p_x_uc_header_rec.instance_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
    CLOSE get_serial_number;
  ELSE
    CLOSE get_serial_number;
  END IF;

  IF l_serial_number IS NOT NULL THEN
    --Retrieve existing value of serial_number_tag if present.
    AHL_UTIL_UC_PKG.getcsi_attribute_value(p_x_uc_header_rec.instance_id,
                                           'AHL_TEMP_SERIAL_NUM',
                                           l_attribute_value,
                                           l_attribute_value_id,
                                           l_object_version_number,
                                           l_return_val);
    IF NOT l_return_val THEN --serial_number_tag doesn't exist
      IF l_mfg_serial_number_flag = 'Y' THEN
        l_serial_number_tag := 'INVENTORY';
      ELSE
        l_serial_number_tag := 'TEMPORARY';
      END IF;
      --Build CSI transaction record, first get transaction_type_id
      AHL_Util_UC_Pkg.getcsi_transaction_id('UC_UPDATE', l_transaction_type_id, l_return_val);
      IF NOT(l_return_val) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_csi_transaction_rec.source_transaction_date := SYSDATE;
      l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
      AHL_Util_UC_Pkg.getcsi_attribute_id('AHL_TEMP_SERIAL_NUM', l_attribute_id,l_return_val);
      IF NOT(l_return_val) THEN
        FND_MESSAGE.set_name('AHL','AHL_UC_ATTRIB_CODE_MISSING');
        FND_MESSAGE.set_token('CODE', 'AHL_TEMP_SERIAL_NUM');
        FND_MSG_PUB.add;
      ELSE
        l_csi_extend_attrib_rec.attribute_id := l_attribute_id;
        l_csi_extend_attrib_rec.attribute_value := l_serial_number_tag;
        l_csi_extend_attrib_rec.instance_id := p_x_uc_header_rec.instance_id;
        l_csi_ext_attrib_values_tbl(1) := l_csi_extend_attrib_rec;
      END IF;

      CSI_ITEM_INSTANCE_PUB.create_extended_attrib_values(
                          p_api_version            => 1.0,
                          p_txn_rec                => l_csi_transaction_rec,
                          p_ext_attrib_tbl         => l_csi_ext_attrib_values_tbl,
                          x_return_status          => l_return_status,
                          x_msg_count              => l_msg_count,
                          x_msg_data               => l_msg_data);

      IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution','At the end of the procedure');
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT;
  END IF;
  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_uc_header;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_uc_header;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO create_uc_header;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END create_uc_header;

-- Define Procedure update_uc_header --
-- This API is used to update a UC header name or some attributes of the top node
-- instance of the UC.
PROCEDURE update_uc_header(
  p_api_version        IN            NUMBER     := 1.0,
  p_init_msg_list      IN            VARCHAR2   := FND_API.G_FALSE,
  p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_module_type        IN            VARCHAR2   := NULL,
  x_return_status      OUT NOCOPY    VARCHAR2,
  x_msg_count          OUT NOCOPY    NUMBER,
  x_msg_data           OUT NOCOPY    VARCHAR2,
  p_x_uc_header_rec    IN OUT NOCOPY ahl_uc_instance_pvt.uc_header_rec_type,
  p_uc_instance_rec    IN  ahl_uc_instance_pvt.uc_instance_rec_type)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'update_uc_header';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT update_uc_header;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   'At the start of the procedure');
  END IF;

  -- Convert G_MISS values to NULL and NULL to OLD values
  convert_attributes(p_x_uc_header_rec, l_return_status);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   ': after convert_attributes');
  END IF;

  -- ACL :: Changes for R12
  IF (ahl_util_uc_pkg.IS_UNIT_QUARANTINED(p_unit_header_id => p_x_uc_header_rec.uc_header_id , p_instance_id => null) = FND_API.G_TRUE) THEN
    FND_MESSAGE.set_name( 'AHL','AHL_UC_INVALID_Q_ACTION' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Validate all attributes (Item level validation)
  IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
    validate_attributes(p_x_uc_header_rec, 'U', l_return_status);
    -- If any severe error occurs, then, abort API.
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                   ': after validate_attributes');
  END IF;

  UPDATE ahl_unit_config_headers SET
    object_version_number = object_version_number + 1,
    last_update_date = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.login_id,
    name = p_x_uc_header_rec.uc_name,
    master_config_id = p_x_uc_header_rec.mc_header_id,
    csi_item_instance_id = p_x_uc_header_rec.instance_id,
    unit_config_status_code = p_x_uc_header_rec.unit_config_status_code,
    active_start_date = p_x_uc_header_rec.active_start_date,
    active_end_date = p_x_uc_header_rec.active_end_date,
    active_uc_status_code = p_x_uc_header_rec.active_uc_status_code,
    parent_uc_header_id = p_x_uc_header_rec.parent_uc_header_id,
    attribute_category = p_x_uc_header_rec.attribute_category,
    attribute1 = p_x_uc_header_rec.attribute1,
    attribute2 = p_x_uc_header_rec.attribute2,
    attribute3 = p_x_uc_header_rec.attribute3,
    attribute4 = p_x_uc_header_rec.attribute4,
    attribute5 = p_x_uc_header_rec.attribute5,
    attribute6 = p_x_uc_header_rec.attribute6,
    attribute7 = p_x_uc_header_rec.attribute7,
    attribute8 = p_x_uc_header_rec.attribute8,
    attribute9 = p_x_uc_header_rec.attribute9,
    attribute10 = p_x_uc_header_rec.attribute10,
    attribute11 = p_x_uc_header_rec.attribute11,
    attribute12 = p_x_uc_header_rec.attribute12,
    attribute13 = p_x_uc_header_rec.attribute13,
    attribute14 = p_x_uc_header_rec.attribute14,
    attribute15 = p_x_uc_header_rec.attribute15
  WHERE unit_config_header_id = p_x_uc_header_rec.uc_header_id
    AND object_version_number = p_x_uc_header_rec.object_version_number;
  IF SQL%NOTFOUND THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API','ovn='||p_x_uc_header_rec.object_version_number);
    END IF;
    FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  ahl_util_uc_pkg.copy_uc_header_to_history(p_x_uc_header_rec.uc_header_id, l_return_status);
  --IF history copy failed, then don't raise exception, just add the message to the message stack
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
    FND_MSG_PUB.add;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API','before calling update_instance_attr');
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API','x_return_status='||x_return_status);
  END IF;
  --Call ahl_uc_instance_pvt.update_instance_attr to update the top node instance attributes
  --In front end UI, if there is no change to the instance attributes, then the whole p_uc_instance_rec
  --will be null.
  IF p_uc_instance_rec.instance_id IS NOT NULL THEN
    ahl_uc_instance_pvt.update_instance_attr(
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.G_FALSE,
      p_commit             => FND_API.G_FALSE,
      p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_uc_header_id       => p_x_uc_header_rec.uc_header_id,
      p_uc_instance_rec    => p_uc_instance_rec,
      p_prod_user_flag     => 'N');

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API', 'After calling update_instance_attr');
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API','x_return_status='||x_return_status);
    END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API', 'Before check message count');
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API', 'Before commit');
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': within API', 'After commit');
  END IF;

  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_uc_header;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_uc_header;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO update_uc_header;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END update_uc_header;

-- Define Procedure delete_uc_header --

PROCEDURE delete_uc_header(
  p_api_version           IN            NUMBER     := 1.0,
  p_init_msg_list         IN            VARCHAR2   := FND_API.G_FALSE,
  p_commit                IN            VARCHAR2   := FND_API.G_FALSE,
  p_validation_level      IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  p_uc_header_id          IN            NUMBER,
  p_object_version_number IN            NUMBER,
  p_csi_instance_ovn      IN            NUMBER)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'delete_uc_header';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_uc_header_rec  get_uc_header%ROWTYPE;
  l_uc_status      ahl_unit_config_headers.unit_config_status_code%TYPE;
  l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_csi_upd_transaction_rec       csi_datastructures_pub.transaction_rec;
  l_csi_instance_rec          csi_datastructures_pub.instance_rec;
  l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
  l_csi_instance_id_lst       csi_datastructures_pub.id_tbl;
  l_csi_relationship_id       NUMBER;
  l_transaction_type_id       NUMBER;
  l_return_value              BOOLEAN;
  l_csi_instance_ovn          NUMBER;
  l_dummy_num                 NUMBER;
  l_object_version_number     NUMBER;

  CURSOR get_csi_obj_ver_num(c_instance_id NUMBER) IS
    SELECT object_version_number
      FROM csi_item_instances
     WHERE instance_id = c_instance_id
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
  CURSOR get_all_subunits(c_uc_header_id NUMBER) IS
    SELECT parent_uc_header_id, unit_config_header_id
      FROM ahl_unit_config_headers
START WITH unit_config_header_id = c_uc_header_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY parent_uc_header_id = PRIOR unit_config_header_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
FOR UPDATE OF unit_config_header_id;
  CURSOR get_top_unit(c_uc_header_id NUMBER) IS
    SELECT unit_config_header_id, unit_config_status_code
      FROM ahl_unit_config_headers
     WHERE parent_uc_header_id IS NULL
START WITH unit_config_header_id = c_uc_header_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY unit_config_header_id = PRIOR parent_uc_header_id
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

  CURSOR get_csi_ii_relationship(c_instance_id NUMBER) IS
    SELECT relationship_id,
           object_version_number
      FROM csi_ii_relationships
     WHERE subject_id = c_instance_id
       AND relationship_type_code='COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);
BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT delete_uc_header;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
                               'At the start of the procedure');
  END IF;

  IF (p_uc_header_id IS NULL OR p_uc_header_id = FND_API.G_MISS_NUM OR
      p_object_version_number IS NULL OR p_object_version_number = FND_API.G_MISS_NUM OR
      p_csi_instance_ovn IS NULL OR p_csi_instance_ovn = FND_API.G_MISS_NUM ) THEN
    FND_MESSAGE.set_name( 'AHL', 'AHL_COM_INVALID_PROCEDURE_CALL' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --In case p_uc_header_id is a subunit, then whether it can be expired depends on its ancestor
  --uc_header_id's status
  OPEN get_top_unit(p_uc_header_id);
  FETCH get_top_unit INTO l_dummy_num, l_uc_status;
  IF get_top_unit%NOTFOUND THEN
    CLOSE get_top_unit;
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'uc_header_id');
    FND_MESSAGE.set_token('VALUE', p_uc_header_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_uc_status IS NULL OR l_uc_status NOT IN ('DRAFT', 'APPROVAL_REJECTED')) THEN
    CLOSE get_top_unit;
    FND_MESSAGE.set_name( 'AHL', 'AHL_UC_STATUS_NOT_DRAFT' );
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Get p_uc_header_id its own attribute from ahl_unit_config_headers_v
  OPEN get_uc_header(p_uc_header_id);
  FETCH get_uc_header INTO l_uc_header_rec;
  IF get_uc_header%NOTFOUND THEN
    CLOSE get_uc_header;
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'uc_header_id');
    FND_MESSAGE.set_token('VALUE', p_uc_header_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    CLOSE get_uc_header;
  END IF;

  UPDATE ahl_unit_config_headers
  SET active_end_date = SYSDATE,
      parent_uc_header_id = NULL,
      --Suitable for both standalone units and sub units
      object_version_number = object_version_number + 1,
      last_update_date = SYSDATE,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
  WHERE unit_config_header_id = p_uc_header_id
  AND object_version_number = p_object_version_number;

  IF SQL%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  ahl_util_uc_pkg.copy_uc_header_to_history(p_uc_header_id, l_return_status);
  --IF history copy failed, then don't raise exception, just add the message tothe message stack
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
    FND_MSG_PUB.add;
  END IF;

  --The following lines are used to expire all the instances and subunits installed in this
  --draft UC, the relationship between the subunit with its immediate parent is expired but
  --the relationship below the subunit are not expired.
  --First, get transaction_type_id.
  AHL_UTIL_UC_PKG.getcsi_transaction_id('UC_UPDATE',l_transaction_type_id, l_return_value);
  IF NOT l_return_value THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Set the CSI transaction record
  l_csi_transaction_rec.source_transaction_date := SYSDATE;
  l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
  --This transaction record copy is required for expiring item instance because for some reason
  --expiring relationship and expiring item instance cannot share the same transaction record.
  l_csi_upd_transaction_rec := l_csi_transaction_rec;

  --Get the object_version_number of the csi instance
  --This section was moved from after calling CSI expire_relationship to before
  --calling expire_relationship because expire_relationhship will increase the object version
  --number of CSI instance itself
  OPEN get_csi_obj_ver_num(l_uc_header_rec.csi_instance_id);
  FETCH get_csi_obj_ver_num INTO l_csi_instance_ovn;
  IF (get_csi_obj_ver_num%NOTFOUND) THEN
    CLOSE get_csi_obj_ver_num;
    FND_MESSAGE.set_name('AHL','AHL_COM_RECORD_DELETED');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_csi_instance_ovn <> p_csi_instance_ovn) THEN
    CLOSE get_csi_obj_ver_num;
    FND_MESSAGE.set_name('AHL','AHL_COM_RECORD_CHANGED');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_uc_header_rec.parent_uc_header_id IS NOT NULL THEN
  --Means it is a subunit, need to expire the relationship with its parent (here we can also
  --call remove_instance API to do it, but a bit too expensive(deriving status etc.)
    OPEN get_csi_ii_relationship(l_uc_header_rec.csi_instance_id);
    FETCH get_csi_ii_relationship INTO l_csi_relationship_id, l_object_version_number;
    IF get_csi_ii_relationship%NOTFOUND THEN
      CLOSE get_csi_ii_relationship;
      FND_MESSAGE.set_name('AHL','AHL_UC_CSI_REL_REC_INVALID');
      FND_MESSAGE.set_token('INSTANCE', l_uc_header_rec.csi_instance_id);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      CLOSE get_csi_ii_relationship;
    END IF;

    --Set CSI relationship record
    l_csi_relationship_rec.relationship_id := l_csi_relationship_id;
    l_csi_relationship_rec.object_version_number := l_object_version_number;
    CSI_II_RELATIONSHIPS_PUB.expire_relationship(
                           p_api_version      => 1.0,
                           p_relationship_rec => l_csi_relationship_rec,
                           p_txn_rec          => l_csi_transaction_rec,
                           x_instance_id_lst  => l_csi_instance_id_lst,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data);

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      l_csi_instance_ovn := l_csi_instance_ovn + 1;
    ELSIF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  --Call CSI API to expire the instance and all its descendants if exist
  l_csi_instance_rec.instance_id := l_uc_header_rec.csi_instance_id;
  l_csi_instance_rec.object_version_number := l_csi_instance_ovn;
  CSI_ITEM_INSTANCE_PUB.expire_item_instance(
                           p_api_version         => 1.0,
                           p_instance_rec        => l_csi_instance_rec,
                           p_expire_children     => FND_API.G_TRUE,
                           p_txn_rec             => l_csi_upd_transaction_rec,
                           x_instance_id_lst     => l_csi_instance_id_lst,
                           x_return_status       => l_return_status,
                           x_msg_count           => l_msg_count,
                           x_msg_data            => l_msg_data);
  --dbms_output.put_line('l_msg_date='||l_msg_data);
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Then expire all of the subunit headers. Here don't need to worry about the status of subunit.
  --because all the Draft units can only have Draft subunits and only separate units are allowed
  --to be submitted for approval
  FOR l_subunits IN get_all_subunits(l_uc_header_rec.uc_header_id) LOOP
    UPDATE ahl_unit_config_headers
       SET active_end_date = sysdate,
           object_version_number = object_version_number + 1,
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
     WHERE unit_config_header_id = l_subunits.unit_config_header_id;
     --here no object_version_number check

    ahl_util_uc_pkg.copy_uc_header_to_history(l_subunits.unit_config_header_id,l_return_status);
    --IF history copy failed, then don't raise exception, just add the messageto the message stack
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.set_name('AHL', 'AHL_UC_HISTORY_COPY_FAILED');
      FND_MSG_PUB.add;
    END IF;
  END LOOP;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution','At the end of the procedure');
  END IF;

  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT;
  END IF;
  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_uc_header;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_uc_header;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO delete_uc_header;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END delete_uc_header;

END AHL_UC_UNITCONFIG_PVT; -- Package spec

/
