--------------------------------------------------------
--  DDL for Package Body AHL_LTP_SPACE_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_SPACE_ASSIGN_PVT" AS
/* $Header: AHLVSANB.pls 120.0 2005/05/26 10:59:45 appldev noship $ */

G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_SPACE_ASSIGN_PVT';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
--
-- PACKAGE
--    AHL_LTP_SPACE_ASSIGN_PVT
--
-- PURPOSE
--    This package is a Private API for assigning Spaces to a visit information in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_SPACE_ASSIGNMENT:
--    Create_Space_Assignment (see below for specification)
--    Update_Space_Assignment (see below for specification)
--    Delete_Space_Assignment (see below for specification)
--    Validate_Space_Assignment (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 02-May-2002    ssurapan      Created.
--
--  PROCEDURE:
--   Check_lookup_name_Or_Id(private procedure)
-- DESCRIPTION :
--   used to retrieve lookup code
--
PROCEDURE Check_lookup_name_Or_Id
 ( p_lookup_type      IN FND_LOOKUPS.lookup_type%TYPE,
   p_lookup_code      IN FND_LOOKUPS.lookup_code%TYPE,
   p_meaning          IN FND_LOOKUPS.meaning%TYPE,
   p_check_id_flag    IN VARCHAR2,
   x_lookup_code      OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2)
IS
BEGIN
      --
      IF (p_lookup_code IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND lookup_code = p_lookup_code
            AND SYSDATE BETWEEN start_date_active
            AND NVL(end_date_active,SYSDATE);
        ELSE
           x_lookup_code := p_lookup_code;
        END IF;
     ELSE
         --
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND meaning     = p_meaning
            AND SYSDATE BETWEEN start_date_active
            AND NVL(end_date_active,SYSDATE);
    END IF;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN TOO_MANY_ROWS THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE;
END;
-- Start of Coments
-- CHECK_ORG_NAME_OR_ID
--
-- PURPOSE
--    Converts Org Name to ID or Vice versa
--
-- PARAMETERS
--
-- NOTES
PROCEDURE Check_org_name_Or_Id
    (p_organization_id     IN NUMBER,
     p_org_name            IN VARCHAR2,
     x_organization_id     OUT NOCOPY NUMBER,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_error_msg_code      OUT NOCOPY VARCHAR2
     )
   IS
BEGIN
      IF (p_organization_id IS NOT NULL)
       THEN
          SELECT organization_id
              INTO x_organization_id
            FROM HR_ALL_ORGANIZATION_UNITS
          WHERE organization_id   = p_organization_id;
      ELSE
          SELECT organization_id
              INTO x_organization_id
            FROM HR_ALL_ORGANIZATION_UNITS
          WHERE NAME  = p_org_name;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_LTP_ORG_NOT_EXISTS';
       WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_LTP_ORG_NOT_EXISTS';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_org_name_Or_Id;
-- Start of Comments
-- PROCEDURE
--    CHECK_DEPT_DESC_OR_ID
--
-- PURPOSE
--    Converts Dept description to ID or Vice Versa
--
-- PARAMETERS
--
-- NOTES
--
PROCEDURE Check_dept_desc_Or_Id
    (p_organization_id     IN NUMBER,
     p_org_name            IN VARCHAR2,
     p_department_id       IN NUMBER,
     p_dept_description    IN VARCHAR2,
     x_department_id       OUT NOCOPY NUMBER,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_error_msg_code      OUT NOCOPY VARCHAR2)
   IS
BEGIN
     --
	 /* Exists clause added by mpothuku on 18/01/05 to consider the depts with shifts only */
      IF (p_department_id IS NOT NULL)
       THEN
          SELECT department_id
             INTO x_department_id
            FROM BOM_DEPARTMENTS
          WHERE organization_id = p_organization_id
            AND department_id   = p_department_id
		    AND EXISTS ( SELECT 'x' FROM AHL_DEPARTMENT_SHIFTS WHERE DEPARTMENT_ID = BOM_DEPARTMENTS.DEPARTMENT_ID);
	 ELSE
          SELECT department_id
             INTO x_department_id
           FROM BOM_DEPARTMENTS
          WHERE organization_id =  p_organization_id
            AND description = p_dept_description
		    AND EXISTS ( SELECT 'x' FROM AHL_DEPARTMENT_SHIFTS WHERE DEPARTMENT_ID = BOM_DEPARTMENTS.DEPARTMENT_ID);
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_LTP_DEPT_NOT_EXISTS';
       WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_LTP_DEPT_NOT_EXISTS';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_dept_desc_Or_Id;
--
-- PROCEDURE
--    CHECK_SPACE_NAME_OR_ID
--
-- PURPOSE
--    Converts Space Name to ID or Vice versa
--
-- PARAMETERS
--
-- NOTES
--
PROCEDURE Check_space_name_Or_Id
    (p_space_id            IN NUMBER,
     p_space_name          IN VARCHAR2,
     x_space_id            OUT NOCOPY NUMBER,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_error_msg_code      OUT NOCOPY VARCHAR2
     )
   IS
BEGIN
      --
      IF (p_space_name IS NOT NULL)
       THEN
          SELECT space_id
              INTO x_space_id
            FROM AHL_SPACES_VL
          WHERE space_name   = p_space_name;
      ELSE
          SELECT space_id
              INTO x_space_id
           FROM AHL_SPACES_VL
          WHERE SPACE_ID  = p_space_id;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_LTP_SPACE_NOT_EXISTS';
       WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_LTP_SPACE_NOT_EXISTS';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_space_name_Or_Id;
--
-- PROCEDURE
--    CHECK_VISIT_NUMBER_OR_ID
--
-- PURPOSE
--    Converts Visit Number to ID or Vice versa
--
-- PARAMETERS
--
-- NOTES
--
PROCEDURE Check_visit_number_Or_Id
    (p_visit_id            IN   NUMBER,
     p_visit_number        IN   NUMBER,
     x_visit_id             OUT NOCOPY NUMBER,
     x_return_status        OUT NOCOPY VARCHAR2,
     x_error_msg_code       OUT NOCOPY VARCHAR2
     )
   IS
BEGIN
      IF (p_visit_id IS NOT NULL)
       THEN
          SELECT visit_id
              INTO x_visit_id
            FROM AHL_VISITS_VL
          WHERE visit_id   = p_visit_id;
      ELSE
          SELECT visit_id
              INTO x_visit_id
           FROM AHL_VISITS_VL
          WHERE visit_number  = p_visit_number;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_LTP_SPACE_NOT_EXISTS';
       WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_LTP_SPACE_NOT_EXISTS';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_visit_number_Or_Id;
--
-- PROCEDURE
--    Assign_Space_Assign_Rec
--
--
PROCEDURE Assign_Space_Assign_Rec (
   p_space_assign_rec      IN  AHL_LTP_SPACE_ASSIGN_PUB.Space_assignment_rec,
   x_space_assign_rec        OUT NOCOPY Space_Assignment_rec
)
IS

BEGIN
     x_space_assign_rec.space_assignment_id   :=  p_space_assign_rec.space_assignment_id;
     x_space_assign_rec.space_id              :=  p_space_assign_rec.space_id;
     x_space_assign_rec.space_name            :=  p_space_assign_rec.space_name;
     x_space_assign_rec.visit_id              :=  p_space_assign_rec.visit_id;
     x_space_assign_rec.object_version_number :=  p_space_assign_rec.object_version_number;
     x_space_assign_rec.attribute_category    :=  p_space_assign_rec.attribute_category;
     x_space_assign_rec.attribute1            :=  p_space_assign_rec.attribute1;
     x_space_assign_rec.attribute2            :=  p_space_assign_rec.attribute2;
     x_space_assign_rec.attribute3            :=  p_space_assign_rec.attribute3;
     x_space_assign_rec.attribute4            :=  p_space_assign_rec.attribute4;
     x_space_assign_rec.attribute5            :=  p_space_assign_rec.attribute5;
     x_space_assign_rec.attribute6            :=  p_space_assign_rec.attribute6;
     x_space_assign_rec.attribute7            :=  p_space_assign_rec.attribute7;
     x_space_assign_rec.attribute8            :=  p_space_assign_rec.attribute8;
     x_space_assign_rec.attribute9            :=  p_space_assign_rec.attribute9;
     x_space_assign_rec.attribute10           :=  p_space_assign_rec.attribute10;
     x_space_assign_rec.attribute11           :=  p_space_assign_rec.attribute11;
     x_space_assign_rec.attribute12           :=  p_space_assign_rec.attribute12;
     x_space_assign_rec.attribute13           :=  p_space_assign_rec.attribute13;
     x_space_assign_rec.attribute14           :=  p_space_assign_rec.attribute14;
     x_space_assign_rec.attribute15           :=  p_space_assign_rec.attribute15;

END Assign_Space_Assign_Rec;
--
-- PROCEDURE
--    Complete_Space_Assign_Rec
--
--
PROCEDURE Complete_Space_Assign_Rec (
   p_space_assign_rec      IN  Space_assignment_rec,
   x_space_assign_rec      OUT NOCOPY Space_assignment_rec
)
IS
  CURSOR c_space_assign_rec
   IS
   SELECT ROWID ROW_ID,
          SPACE_ASSIGNMENT_ID,
          SPACE_ID,
          VISIT_ID,
          OBJECT_VERSION_NUMBER,
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
          ATTRIBUTE15
     FROM  ahl_space_assignments
   WHERE   space_assignment_id = p_space_assign_rec.space_assignment_id;
   --
   -- This is the only exception for using %ROWTYPE.
   l_space_assign_rec    c_space_assign_rec%ROWTYPE;
BEGIN
   x_space_assign_rec := p_space_assign_rec;
   OPEN c_space_assign_rec;
   FETCH c_space_assign_rec INTO l_space_assign_rec;
   IF c_space_assign_rec%NOTFOUND THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AHL', 'AHL_LTP_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
        CLOSE c_space_assign_rec;
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   END IF;
   CLOSE c_space_assign_rec;
   --Check for object version number
    IF (l_space_assign_rec.object_version_number <> p_space_assign_rec.object_version_number)
    THEN
        Fnd_Message.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

   -- SPACE ID
   IF p_space_assign_rec.space_id <> FND_API.g_miss_num THEN
      x_space_assign_rec.space_id := p_space_assign_rec.space_id;
      ELSE
      x_space_assign_rec.space_id := l_space_assign_rec.space_id;
   END IF;
   -- VISIT_ID
   IF p_space_assign_rec.visit_id <> FND_API.g_miss_num THEN
      x_space_assign_rec.visit_id := p_space_assign_rec.visit_id;
      ELSE
      x_space_assign_rec.visit_id := l_space_assign_rec.visit_id;
   END IF;
   -- ATTRIBUTE CATEGORY
   IF p_space_assign_rec.attribute_category <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute_category := p_space_assign_rec.attribute_category;
      ELSE
      x_space_assign_rec.attribute_category := l_space_assign_rec.attribute_category;
   END IF;
   -- ATTRIBUTE 1
   IF p_space_assign_rec.attribute1 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute1 := p_space_assign_rec.attribute1;
      ELSE
      x_space_assign_rec.attribute1 := l_space_assign_rec.attribute1;
   END IF;
   -- ATTRIBUTE 2
   IF p_space_assign_rec.attribute2 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute2 := p_space_assign_rec.attribute2;
      ELSE
      x_space_assign_rec.attribute2 := l_space_assign_rec.attribute2;
   END IF;
   -- ATTRIBUTE 3
   IF p_space_assign_rec.attribute3 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute3 := p_space_assign_rec.attribute3;
      ELSE
      x_space_assign_rec.attribute3 := l_space_assign_rec.attribute3;
   END IF;
   -- ATTRIBUTE 4
   IF p_space_assign_rec.attribute4 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute4 := p_space_assign_rec.attribute4;
      ELSE
      x_space_assign_rec.attribute4 := l_space_assign_rec.attribute4;
   END IF;
   -- ATTRIBUTE 5
   IF p_space_assign_rec.attribute5 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute5 := p_space_assign_rec.attribute5;
      ELSE
      x_space_assign_rec.attribute5 := l_space_assign_rec.attribute5;
   END IF;
   -- ATTRIBUTE 6
   IF p_space_assign_rec.attribute6 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute6 := p_space_assign_rec.attribute6;
      ELSE
      x_space_assign_rec.attribute6 := l_space_assign_rec.attribute6;
   END IF;
   -- ATTRIBUTE 7
   IF p_space_assign_rec.attribute7 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute7 := p_space_assign_rec.attribute7;
      ELSE
      x_space_assign_rec.attribute7 := l_space_assign_rec.attribute7;
   END IF;
   -- ATTRIBUTE 8
   IF p_space_assign_rec.attribute8 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute8 := p_space_assign_rec.attribute8;
      ELSE
      x_space_assign_rec.attribute8 := l_space_assign_rec.attribute8;
   END IF;
   -- ATTRIBUTE 9
   IF p_space_assign_rec.attribute9 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute9 := p_space_assign_rec.attribute9;
      ELSE
      x_space_assign_rec.attribute9 := l_space_assign_rec.attribute9;
   END IF;
   -- ATTRIBUTE 10
   IF p_space_assign_rec.attribute10 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute10 := p_space_assign_rec.attribute10;
      ELSE
      x_space_assign_rec.attribute10 := l_space_assign_rec.attribute10;
   END IF;
   -- ATTRIBUTE 11
   IF p_space_assign_rec.attribute11 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute11 := p_space_assign_rec.attribute11;
      ELSE
      x_space_assign_rec.attribute11 := l_space_assign_rec.attribute11;
   END IF;
   -- ATTRIBUTE 12
   IF p_space_assign_rec.attribute12 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute12 := p_space_assign_rec.attribute12;
      ELSE
      x_space_assign_rec.attribute12 := l_space_assign_rec.attribute12;
   END IF;
   -- ATTRIBUTE 13
   IF p_space_assign_rec.attribute13 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute13 := p_space_assign_rec.attribute13;
      ELSE
      x_space_assign_rec.attribute13 := l_space_assign_rec.attribute13;
   END IF;
   -- ATTRIBUTE 14
   IF p_space_assign_rec.attribute14 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute14 := p_space_assign_rec.attribute14;
      ELSE
      x_space_assign_rec.attribute14 := l_space_assign_rec.attribute14;
   END IF;
   -- ATTRIBUTE 15
   IF p_space_assign_rec.attribute15 <> FND_API.g_miss_char THEN
      x_space_assign_rec.attribute15 := p_space_assign_rec.attribute15;
      ELSE
      x_space_assign_rec.attribute15 := l_space_assign_rec.attribute15;
   END IF;

END Complete_Space_Assign_Rec;
--
--
-- NAME
--   Validate_Space_Assign_Items
--
-- PURPOSE
--   This procedure is to validate Space Assign attributes
--
PROCEDURE Validate_Space_Assign_Items
( p_space_assign_rec	        IN	space_assignment_rec,
  p_validation_mode		IN	VARCHAR2 := Jtf_Plsql_Api.g_create,
  x_return_status		OUT NOCOPY	VARCHAR2
) IS

CURSOR check_unique (c_visit_id IN NUMBER,
                     c_space_id IN NUMBER)
IS
    SELECT space_assignment_id
      FROM AHL_SPACE_ASSIGNMENTS
      WHERE VISIT_ID = p_space_assign_rec.visit_id
        AND SPACE_ID = p_space_assign_rec.space_id;
--
CURSOR visit_item_cur (c_visit_id IN NUMBER)
 IS
SELECT visit_type_code,
       inventory_item_id,
       trunc(start_date_time) start_date_time,
	   trunc(close_date_time)
   FROM ahl_visits_b
WHERE visit_id = c_visit_id;
--
CURSOR space_available_cur(c_space_id IN NUMBER)
IS
   SELECT trunc(start_date) start_date,
          trunc(end_date) end_date
     FROM ahl_space_unavailable_b
    WHERE space_id = c_space_id;
--
CURSOR space_capable_cur (c_space_id IN NUMBER,
                          c_visit_type  IN VARCHAR2,
                          c_inventory_item_id  IN NUMBER)
IS
SELECT space_capability_id
  FROM ahl_space_capabilities
 WHERE space_id = c_space_id
  AND visit_type = c_visit_type
  AND inventory_item_id = c_inventory_item_id;
--

CURSOR space_unavailable_cur(c_space_id IN NUMBER,
                             c_start_date IN DATE,
							 c_end_date  IN DATE)
IS
   SELECT trunc(start_date),trunc(end_date)
     FROM ahl_space_unavailable_b
    WHERE space_id = c_space_id
--	 AND ((c_start_date between trunc(start_date) and trunc(end_date))
--	   or (c_end_date between trunc(start_date) and trunc(end_date)));
	  AND ((trunc(start_date) between c_start_date and c_end_date)
	      OR (trunc(end_date) between c_start_date and c_end_date));

  l_table_name	VARCHAR2(30);
  l_pk_name	VARCHAR2(30);
  l_pk_value	VARCHAR2(30);
  l_where_clause VARCHAR2(2000);
  l_dummy     NUMBER;
--
  l_visit_type_code   VARCHAR2(80);
  l_start_date_time   DATE;
  l_end_date_time     DATE;
  l_start_date        DATE;
  l_end_date          DATE;
  l_inventory_item_id NUMBER;
  l_space_unavailability_id  NUMBER;
  l_space_capability_id  NUMBER;
--
BEGIN
        --  Initialize API/Procedure return status to success
	x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
 -- Check required parameters
     IF  (p_space_assign_rec.SPACE_ID IS NULL OR
          p_space_assign_rec.SPACE_ID = Fnd_Api.G_MISS_NUM
          )
         --
     THEN
          -- missing required fields
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
               Fnd_Message.set_name('AHL', 'AHL_LTP_SPACE_ID_NOT_EXIST');
               Fnd_Msg_Pub.ADD;
               RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
     END IF;
     -- VISIT_ID
     IF (p_space_assign_rec.VISIT_ID = Fnd_Api.G_MISS_NUM OR
         p_space_assign_rec.VISIT_ID IS NULL)
     THEN
          -- missing required fields
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
               Fnd_Message.set_name('AHL', 'AHL_LTP_VISIT_ID_NOT_EXIST');
               Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
     END IF;

    --   Validate uniqueness
    OPEN check_unique (p_space_assign_rec.visit_id,
                       p_space_assign_rec.space_id);
    FETCH check_unique INTO l_dummy;
    CLOSE check_unique;
    --
     IF l_dummy IS NOT NULL THEN
        Fnd_Message.set_name('AHL', 'AHL_LTP_SP_ASSIGN_DUP_RECORD');
        Fnd_Msg_Pub.ADD;
      END IF;
    --- Validation for visit type and inventory item
    OPEN  visit_item_cur(p_space_assign_rec.visit_id);
    FETCH visit_item_cur INTO l_visit_type_code,
                              l_inventory_item_id,
                              l_start_date_time,
							  l_end_date_time;
    CLOSE visit_item_cur;
    --new

	OPEN space_unavailable_cur(p_space_assign_rec.space_id,
	                           l_start_date_time,
							   nvl(l_end_date_time,l_start_date_time));
    LOOP
	FETCH space_unavailable_cur INTO l_start_date,l_end_date;
	EXIT WHEN space_unavailable_cur%NOTFOUND;
	IF space_unavailable_cur%FOUND THEN
        Fnd_Message.set_name('AHL', 'AHL_LTP_SP_UNAVAL_PERIOD');
        Fnd_message.set_token( 'PERIOD', l_start_date ||' '||'to'||' '||l_end_date );
        Fnd_Msg_Pub.ADD;
     END IF;
	 END LOOP;
	CLOSE space_unavailable_cur;

	-- new
	/*
    --Check for space availability
    OPEN space_available_cur(p_space_assign_rec.space_id);
    LOOP
    FETCH space_available_cur INTO l_start_date,l_end_date;
    EXIT WHEN space_available_cur%NOTFOUND;
    IF (l_start_date_time >= l_start_date AND
        l_start_date_time <= l_end_date) THEN
        Fnd_Message.set_name('AHL', 'AHL_LTP_SP_UNAVAL_PERIOD');
        Fnd_message.set_token( 'PERIOD', l_start_date ||' '||'to'||' '||l_end_date );
        Fnd_Msg_Pub.ADD;
    END IF;
    END LOOP;
    CLOSE space_available_cur;
    --
    */
	--Check for visit type
      OPEN space_capable_cur(p_space_assign_rec.space_id,
                               l_visit_type_code,
                               l_inventory_item_id);
       FETCH space_capable_cur INTO l_space_capability_id;
       IF l_space_capability_id IS NULL THEN
           Fnd_Message.set_name('AHL', 'AHL_LTP_VISIT_ITEM_NOT_EXIST');
           Fnd_Msg_Pub.ADD;
       END IF;
       CLOSE  space_capable_cur;

    --
END Validate_Space_Assign_Items;
--
--
-- PROCEDURE
--    Validate_Space_Assign
--
-- PURPOSE
--    Validate  space Assignment attributes
--
-- PARAMETERS
--
-- NOTES
--
--
PROCEDURE Validate_Space_Assign
( p_api_version		  IN    NUMBER,
  p_init_msg_list      	  IN    VARCHAR2 := Fnd_Api.G_FALSE,
  p_validation_level      IN    NUMBER	 := Fnd_Api.G_VALID_LEVEL_FULL,
  p_space_assign_rec      IN    space_assignment_rec,
  x_return_status	    OUT NOCOPY VARCHAR2,
  x_msg_count		    OUT NOCOPY NUMBER,
  x_msg_data		    OUT NOCOPY VARCHAR2
)
IS
   l_api_name	    CONSTANT    VARCHAR2(30)  := 'Validate_Space_Assign';
   l_api_version    CONSTANT    NUMBER        := 1.0;
   l_full_name      CONSTANT    VARCHAR2(60)  := G_PKG_NAME || '.' || l_api_name;
   l_return_status		VARCHAR2(1);
   l_space_assign_rec	        space_assignment_rec;
  BEGIN
        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
        	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean( p_init_msg_list ) THEN
        	Fnd_Msg_Pub.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        --
        -- API body
        --
	IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item
	THEN
		Validate_Space_assign_Items
		( p_space_assign_rec	        => p_space_assign_rec,
		  p_validation_mode 	        => Jtf_Plsql_Api.g_create,
		  x_return_status		=> l_return_status
		);
		-- If any errors happen abort API.
		IF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR
		THEN
		   RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = Fnd_Api.G_RET_STS_ERROR
		THEN
		    RAISE Fnd_Api.G_EXC_ERROR;
		END IF;
	END IF;
        --
        -- END of API body.
        --
   -------------------- finish --------------------------
   Fnd_Msg_Pub.count_and_get(
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data);
  EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
       	x_return_status := Fnd_Api.G_RET_STS_ERROR ;
        Fnd_Msg_Pub.Count_AND_Get
        	( p_count	=>      x_msg_count,
		  p_data	=>      x_msg_data,
		  p_encoded	=>      Fnd_Api.G_FALSE
	     );
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       	x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
        Fnd_Msg_Pub.Count_AND_Get
        	( p_count	=>      x_msg_count,
		  p_data	=>      x_msg_data,
		  p_encoded	=>      Fnd_Api.G_FALSE
	     );
        WHEN OTHERS THEN
       	x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
        IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
        	THEN
              		Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
	        END IF;
	        Fnd_Msg_Pub.Count_AND_Get
        	( p_count	=>      x_msg_count,
                  p_data	=>      x_msg_data,
		  p_encoded	=>      Fnd_Api.G_FALSE
	     );
END Validate_Space_Assign;
--
-- PROCEDURE
--    Create_Space_Assignment
--
-- PURPOSE
--    Create Space Assignment Record
--
-- PARAMETERS
--    p_x_space_assign_rec: the record representing AHL_SPACE_ASSIGNMENTS..
--
-- NOTES
--
PROCEDURE Create_Space_Assignment (
   p_api_version             IN     NUMBER,
   p_init_msg_list           IN     VARCHAR2  := FND_API.g_false,
   p_commit                  IN     VARCHAR2  := FND_API.g_false,
   p_validation_level        IN     NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN     VARCHAR2  := 'JSP',
   p_x_space_assign_rec     IN OUT NOCOPY ahl_ltp_space_assign_pub.Space_Assignment_Rec,
   p_reschedule_flag         IN      VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
 )
IS
 l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_SPACE_ASSIGNMENT';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_dummy                    NUMBER;
 l_rowid                    VARCHAR2(30);
 l_space_id                 NUMBER;
 l_visit_id                 NUMBER;
 l_space_assignment_id      NUMBER;
 l_space_assign_rec         Space_Assignment_Rec;
 --
 CURSOR c_seq
  IS
  SELECT AHL_SPACE_ASSIGNMENTS_S.NEXTVAL
    FROM   dual;
 --
   CURSOR c_id_exists (x_id IN NUMBER) IS
     SELECT 1
       FROM   dual
      WHERE EXISTS (SELECT 1
                      FROM   ahl_space_assignments
                     WHERE  space_assignment_id = x_id);
 --
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT create_space_assignment;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_assign_pvt.Create Space Assignment','+SPASN+');
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Value OR ID conversion---------------------------
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'visit_id'||p_x_space_assign_rec.visit_id);
       AHL_DEBUG_PUB.debug( 'space number'||p_x_space_assign_rec.space_name);
       AHL_DEBUG_PUB.debug( 'space id'||p_x_space_assign_rec.space_id);
       AHL_DEBUG_PUB.debug( 'space assign id'||p_x_space_assign_rec.space_assignment_id);
   END IF;
   --
     IF p_reschedule_flag = 'Y' THEN
      --Check is required  during rescheduling
	  IF (p_x_space_assign_rec.visit_id IS NOT NULL AND
          p_x_space_assign_rec.visit_id <> FND_API.G_MISS_NUM ) THEN
          --
       AHL_DEBUG_PUB.debug( 'inside schedule flag:'||p_x_space_assign_rec.space_name);
		  --
          DELETE FROM AHL_SPACE_ASSIGNMENTS
			WHERE visit_id = p_x_space_assign_rec.visit_id;
			 --
	  END IF;
	  --
	  END IF; --Reschedule flag

       AHL_DEBUG_PUB.debug( 'number of records space_id'||p_x_space_assign_rec.space_name);

      -- Convert Space name to space id
      IF (p_x_space_assign_rec.space_name IS NOT NULL AND
          p_x_space_assign_rec.space_name <> FND_API.G_MISS_CHAR )   OR
         (p_x_space_assign_rec.space_id IS NOT NULL AND
          p_x_space_assign_rec.space_id <> FND_API.G_MISS_NUM) THEN

          Check_space_name_Or_Id
               (p_space_id         => null,
                p_space_name       => p_x_space_assign_rec.space_name,
                x_space_id         => l_space_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

          IF NVL(l_return_status,'x') <> 'S'
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_LTP_SPACE_NOT_EXISTS');
              Fnd_Message.SET_TOKEN('SPACEID',p_x_space_assign_rec.space_name);
              Fnd_Msg_Pub.ADD;
          END IF;
     END IF;
     --Assign the returned value
     p_x_space_assign_rec.space_id := l_space_id;

      -- Convert Visit Number to visit id
      IF (p_x_space_assign_rec.visit_number IS NOT NULL AND
          p_x_space_assign_rec.visit_number <> FND_API.G_MISS_NUM )   OR
         (p_x_space_assign_rec.visit_id IS NOT NULL AND
          p_x_space_assign_rec.visit_id <> FND_API.G_MISS_NUM) THEN

          Check_visit_number_Or_Id
               (p_visit_id         => p_x_space_assign_rec.visit_id,
                p_visit_number      => p_x_space_assign_rec.visit_number,
                x_visit_id         => l_visit_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

          IF NVL(l_return_status,'x') <> 'S'
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_LTP_VISIT_ID_NOT_EXIST');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
     END IF;
     --Assign the returned value
     p_x_space_assign_rec.visit_id := l_visit_id;

  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

  --------------------------------Validation ---------------------------
   --Assign to local variable
   Assign_Space_Assign_Rec (
   p_space_assign_rec  => p_x_space_assign_rec,
   x_space_assign_rec  => l_Space_assign_rec);

     -- Call Validate space rec input attributes
    Validate_Space_Assign
        ( p_api_version	          => l_api_version,
          p_init_msg_list         => p_init_msg_list,
          p_validation_level      => p_validation_level,
          p_space_assign_rec      => l_Space_assign_rec,
          x_return_status	  => l_return_status,
          x_msg_count		  => l_msg_count,
          x_msg_data		  => l_msg_data );


  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;


   IF (p_x_space_assign_rec.space_assignment_id = Fnd_Api.G_MISS_NUM or
       p_x_space_assign_rec.space_assignment_id IS NULL)
   THEN
         --
         -- If the ID is not passed into the API, then
         -- grab a value from the sequence.
         OPEN c_seq;
         FETCH c_seq INTO l_space_assignment_id;
         CLOSE c_seq;
         --
         -- Check to be sure that the sequence does not exist.
         OPEN c_id_exists (l_space_assignment_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         --
         -- If the value for the ID already exists, then
         -- l_dummy would be populated with '1', otherwise,
         -- it receives NULL.
         IF l_dummy IS NOT NULL  THEN
             Fnd_Message.SET_NAME('AHL','AHL_LTP_SEQUENCE_NOT_EXISTS');
             Fnd_Msg_Pub.ADD;
          END IF;
         -- For optional fields
         --
         IF  p_x_space_assign_rec.attribute_category = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute_category := NULL;
         ELSE
            l_space_assign_rec.attribute_category := p_x_space_assign_rec.attribute_category;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute1 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute1 := NULL;
         ELSE
            l_space_assign_rec.attribute1 := p_x_space_assign_rec.attribute1;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute2 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute2 := NULL;
         ELSE
            l_space_assign_rec.attribute2 := p_x_space_assign_rec.attribute2;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute3 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute3 := NULL;
         ELSE
            l_space_assign_rec.attribute3 := p_x_space_assign_rec.attribute3;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute4 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute4 := NULL;
         ELSE
            l_space_assign_rec.attribute4 := p_x_space_assign_rec.attribute4;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute5 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute5 := NULL;
         ELSE
            l_space_assign_rec.attribute5 := p_x_space_assign_rec.attribute5;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute6 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute6 := NULL;
         ELSE
            l_space_assign_rec.attribute6 := p_x_space_assign_rec.attribute6;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute7 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute7 := NULL;
         ELSE
            l_space_assign_rec.attribute7 := p_x_space_assign_rec.attribute7;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute8 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute8 := NULL;
         ELSE
            l_space_assign_rec.attribute8 := p_x_space_assign_rec.attribute8;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute9 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute9 := NULL;
         ELSE
            l_space_assign_rec.attribute9 := p_x_space_assign_rec.attribute9;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute10 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute10 := NULL;
         ELSE
            l_space_assign_rec.attribute10 := p_x_space_assign_rec.attribute10;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute11 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute11 := NULL;
         ELSE
            l_space_assign_rec.attribute11 := p_x_space_assign_rec.attribute11;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute12 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute12 := NULL;
         ELSE
            l_space_assign_rec.attribute12 := p_x_space_assign_rec.attribute12;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute13 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute13 := NULL;
         ELSE
            l_space_assign_rec.attribute13 := p_x_space_assign_rec.attribute13;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute14 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute14 := NULL;
         ELSE
            l_space_assign_rec.attribute14 := p_x_space_assign_rec.attribute14;
         END IF;
         --
         IF  p_x_space_assign_rec.attribute15 = FND_API.G_MISS_CHAR
         THEN
            l_space_assign_rec.attribute15 := NULL;
         ELSE
            l_space_assign_rec.attribute15 := p_x_space_assign_rec.attribute15;
         END IF;
   END IF;
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   Ahl_Debug_Pub.debug( 'Before insert state'||l_space_assignment_id);

   ----------------------------DML Operation---------------------------------
   --insert the record
    INSERT INTO AHL_SPACE_ASSIGNMENTS
                  (
                 SPACE_ASSIGNMENT_ID,
                 SPACE_ID,
                 VISIT_ID,
                 OBJECT_VERSION_NUMBER,
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
                )
         VALUES
               (
                l_space_assignment_id,
                l_space_assign_rec.space_id,
                l_space_assign_rec.visit_id,
                1,
                l_space_assign_rec.attribute_category,
                l_space_assign_rec.attribute1,
                l_space_assign_rec.attribute2,
                l_space_assign_rec.attribute3,
                l_space_assign_rec.attribute4,
                l_space_assign_rec.attribute5,
                l_space_assign_rec.attribute6,
                l_space_assign_rec.attribute7,
                l_space_assign_rec.attribute8,
                l_space_assign_rec.attribute9,
                l_space_assign_rec.attribute10,
                l_space_assign_rec.attribute11,
                l_space_assign_rec.attribute12,
                l_space_assign_rec.attribute13,
                l_space_assign_rec.attribute14,
                l_space_assign_rec.attribute15,
                SYSDATE,
                Fnd_Global.user_id,
                SYSDATE,
                Fnd_Global.user_id,
                Fnd_Global.login_id
              );

  p_x_space_assign_rec.space_assignment_id := l_space_assignment_id;
---------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Create Space assignment','+SPANS+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_space_assignment;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Create Space assignment','+SPASN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_space_assignment;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Create Space assignment','+SPASN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
WHEN OTHERS THEN
    ROLLBACK TO create_space_assignment;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_ASSIGN_PVT',
                            p_procedure_name  =>  'CREATE_SPACE_ASSIGNMENT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Create Space assignment','+SPASN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
END Create_Space_assignment;
--
-- PROCEDURE
--    Update_Space_Assignment
--
-- PURPOSE
--    Update Space Assignment Record.
--
-- PARAMETERS
--    p_space_assign_rec: the record representing AHL_SPACE_ASSIGNMENT
--
-- NOTES
--
PROCEDURE Update_Space_Assignment (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN     VARCHAR2  := 'JSP',
   p_space_assign_rec        IN    ahl_ltp_space_assign_pub.Space_Assignment_Rec,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2
)
IS
 l_api_name        CONSTANT VARCHAR2(30) := 'UPDATE_SPACE_ASSIGNMENT';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_dummy                    NUMBER;
 l_rowid                    VARCHAR2(30);
 l_space_id                 NUMBER;
 l_visit_id                 NUMBER;
 l_space_assignment_id      NUMBER;
 l_space_assign_rec         Space_Assignment_Rec;

BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT update_space_assignment;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_assign_pvt.Update Space Assignment','+SPANT+');
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   ---------------------start API Body------------------------------------
   --Assign to local variable
   Assign_Space_Assign_Rec (
   p_space_assign_rec  => p_space_assign_rec,
   x_space_assign_rec  => l_Space_assign_rec);
   --------------------Value OR ID conversion---------------------------
      -- Convert Space name to space id
      IF (p_space_assign_rec.space_name IS NOT NULL AND
          p_space_assign_rec.space_name <> FND_API.G_MISS_CHAR )   OR
         (p_space_assign_rec.space_id IS NOT NULL AND
          p_space_assign_rec.space_id <> FND_API.G_MISS_NUM) THEN

          Check_space_name_Or_Id
               (p_space_id         => p_space_assign_rec.space_id,
                p_space_name       => p_space_assign_rec.space_name,
                x_space_id         => l_space_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

          IF NVL(l_return_status,'x') <> 'S'
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_LTP_SPACE_NOT_EXISTS');
              Fnd_Message.SET_TOKEN('SPACEID',p_space_assign_rec.space_name);
              Fnd_Msg_Pub.ADD;
          END IF;
     END IF;
     --Assign the returned value
     l_space_assign_rec.space_id := l_space_id;

      -- Convert Visit Number to visit id
      IF (p_space_assign_rec.visit_number IS NOT NULL AND
          p_space_assign_rec.visit_number <> FND_API.G_MISS_NUM )   OR
         (p_space_assign_rec.visit_id IS NOT NULL AND
          p_space_assign_rec.visit_id <> FND_API.G_MISS_NUM) THEN

          Check_visit_number_Or_Id
               (p_visit_id         => p_space_assign_rec.visit_id,
                p_visit_number      => p_space_assign_rec.visit_number,
                x_visit_id         => l_visit_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

          IF NVL(l_return_status,'x') <> 'S'
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_LTP_VISIT_NOT_EXISTS');
              Fnd_Message.SET_TOKEN('VISITID',p_space_assign_rec.visit_number);
              Fnd_Msg_Pub.ADD;
          END IF;
     END IF;
     --Assign the returned value
     l_space_assign_rec.visit_id := l_visit_id;

  --------------------------------Validation ---------------------------
   -- get existing values and compare
   Complete_Space_Assign_Rec (
      p_space_assign_rec  => l_space_assign_rec,
     x_space_assign_rec   => l_space_assign_rec);

     -- Call Validate space assignment attributes
    Validate_Space_Assign
        ( p_api_version	          => l_api_version,
          p_init_msg_list         => p_init_msg_list,
          p_validation_level      => p_validation_level,
          p_space_assign_rec      => l_Space_assign_rec,
          x_return_status	  => l_return_status,
          x_msg_count		  => l_msg_count,
          x_msg_data		  => l_msg_data );

   ----------------------------DML Operation---------------------------------
   --Call table handler generated package to update a record
           UPDATE AHL_SPACE_ASSIGNMENTS
             SET visit_id              = l_Space_assign_rec.visit_id,
                 space_id              = l_Space_assign_rec.space_id,
                 object_version_number = l_Space_assign_rec.object_version_number+1,
                 attribute_category    = l_Space_assign_rec.attribute_category,
                 attribute1            = l_Space_assign_rec.attribute1,
                 attribute2            = l_Space_assign_rec.attribute2,
                 attribute3            = l_Space_assign_rec.attribute3,
                 attribute4            = l_Space_assign_rec.attribute4,
                 attribute5            = l_Space_assign_rec.attribute5,
                 attribute6            = l_Space_assign_rec.attribute6,
                 attribute7            = l_Space_assign_rec.attribute7,
                 attribute8            = l_Space_assign_rec.attribute8,
                 attribute9            = l_Space_assign_rec.attribute9,
                 attribute10           = l_Space_assign_rec.attribute10,
                 attribute11           = l_Space_assign_rec.attribute11,
                 attribute12           = l_Space_assign_rec.attribute12,
                 attribute13           = l_Space_assign_rec.attribute13,
                 attribute14           = l_Space_assign_rec.attribute14,
                 attribute15           = l_Space_assign_rec.attribute15,
                 last_update_date      = SYSDATE,
                 last_updated_by       = Fnd_Global.user_id,
                 last_update_login     = Fnd_Global.login_id
         WHERE  space_assignment_id  = p_space_assign_rec.space_assignment_id;


  ---------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Update Space assignment','+SPANT+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_space_assignment;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
               x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Update Space Assignment','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_space_assignment;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Update Space Assignment','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
WHEN OTHERS THEN
    ROLLBACK TO update_space_assignment;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_ASSIGN_PVT',
                            p_procedure_name  =>  'UPDATE_SPACE_ASSIGNMENT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

   IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Update Space Assignemnt','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
END Update_Space_Assignment;
--
-- PROCEDURE
--    Delete_Space_Assignment
--
-- PURPOSE
--    Delete  Space Assignment Record.
--
-- PARAMETERS
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--
PROCEDURE Delete_Space_Assignment (
   p_api_version                IN     NUMBER,
   p_init_msg_list              IN     VARCHAR2  := FND_API.g_false,
   p_commit                     IN     VARCHAR2  := FND_API.g_false,
   p_validation_level           IN     NUMBER    := FND_API.g_valid_level_full,
   p_space_assign_rec           IN     ahl_ltp_space_assign_pub.Space_Assignment_Rec,
   x_return_status                 OUT NOCOPY VARCHAR2,
   x_msg_count                     OUT NOCOPY NUMBER,
   x_msg_data                      OUT NOCOPY VARCHAR2

)
IS
 l_api_name        CONSTANT VARCHAR2(30) := 'DELETE_SPACE_ASSIGNMENT';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_dummy                    NUMBER;
 l_space_assignment_id      NUMBER;
 l_space_id                 NUMBER;
 l_object_version_number    NUMBER;

  CURSOR c_space_assign_cur
                 (c_space_assignment_id IN NUMBER)
   IS
  SELECT   space_assignment_id,object_version_number
    FROM     ahl_space_assignments
   WHERE    space_assignment_id = c_space_assignment_id;

  CURSOR c_visit_spaces_cur
                 (c_visit_id IN NUMBER)
   IS
  SELECT   sa.space_assignment_id,
           sa.space_id,
           sa.visit_id,
		   trunc(vt.start_date_time) start_date_time,
		   trunc(vt.close_date_time) close_date_time,
		   vt.organization_id,
		   vt.department_id,
		   sp.organization_id sporg_id,
		   sp.bom_department_id spdept_id
    FROM   ahl_space_assignments sa,
	       ahl_visits_vl vt,
		   ahl_spaces_b sp
   WHERE sa.visit_id = vt.visit_id
     AND sp.space_id = sa.space_id
     AND vt.visit_id = c_visit_id;

  CURSOR c_check_unavail_cur
                 (c_space_id   IN NUMBER,
				  c_start_date IN DATE,
				  c_end_date   IN DATE)
   IS
  SELECT   1
    FROM   ahl_space_unavailable_b
   WHERE space_id = space_id
     AND (c_start_date between trunc(start_date) and trunc(end_date)
	    OR
		c_end_date between trunc(start_date) and trunc(end_date));

 l_visit_spaces_rec         c_visit_spaces_cur%ROWTYPE;

BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT delete_space_assignment;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_assign_pvt.Delete Space Assignment','+SPANT+');
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -----------------------Start of API Body-----------------------------
   IF (p_space_assign_rec.visit_id IS NOT NULL AND
       p_space_assign_rec.visit_id <> FND_API.G_MISS_NUM) THEN
	  --
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'visit id'||p_space_assign_rec.visit_id);
    END IF;

	  OPEN  c_visit_spaces_cur(p_space_assign_rec.visit_id);
	  LOOP
	  FETCH c_visit_spaces_cur INTO l_visit_spaces_rec;
	  EXIT WHEN c_visit_spaces_cur%NOTFOUND;
	  IF l_visit_spaces_rec.space_id IS NOT NULL THEN

   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'Space ID'||l_visit_spaces_rec.space_id);
      AHL_DEBUG_PUB.debug( 'org ID'||l_visit_spaces_rec.organization_id);
      AHL_DEBUG_PUB.debug( 'dept ID'||l_visit_spaces_rec.department_id);
      AHL_DEBUG_PUB.debug( 'sorg ID'||l_visit_spaces_rec.sporg_id);
      AHL_DEBUG_PUB.debug( 'sdept ID'||l_visit_spaces_rec.spdept_id);
    END IF;
        --
	    IF (nvl(l_visit_spaces_rec.organization_id,-1) <> l_visit_spaces_rec.sporg_id
		   OR nvl(l_visit_spaces_rec.department_id,-1) <> l_visit_spaces_rec.spdept_id )
		  THEN
		    --Remove space assignments
		    DELETE FROM AHL_SPACE_ASSIGNMENTS
		    WHERE space_assignment_id = l_visit_spaces_rec.space_assignment_id;
		 ELSE
	     --Check for space Unnavailabilty condition
		 OPEN c_check_unavail_cur(l_visit_spaces_rec.space_id,
		                          l_visit_spaces_rec.start_date_time,
								  nvl(l_visit_spaces_rec.close_date_time,
								  l_visit_spaces_rec.start_date_time));
		 FETCH c_check_unavail_cur INTO l_dummy;
		 IF c_check_unavail_cur%FOUND THEN
		    --Remove space assignments
		    DELETE FROM AHL_SPACE_ASSIGNMENTS
	        WHERE space_Assignment_id = l_visit_spaces_rec.space_assignment_id;
 		  END IF;
    	  CLOSE c_check_unavail_cur;
		 END IF;
	  END IF;
	  END LOOP;
	  CLOSE c_visit_spaces_cur;
	END IF;
   --
   IF (p_space_assign_rec.space_assignment_id IS NOT NULL AND
       p_space_assign_rec.space_assignment_id <> FND_API.G_MISS_NUM )

	THEN
   -- Check for Record exists
   OPEN c_space_assign_cur(p_space_assign_rec.space_assignment_id);
   FETCH c_space_assign_cur INTO l_space_assignment_id,
                                 l_object_version_number;
   IF c_space_assign_cur%NOTFOUND THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AHL', 'AHL_LTP_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      CLOSE c_space_assign_cur;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_space_assign_cur;
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'space assign id'||l_space_assignment_id);
    AHL_DEBUG_PUB.debug( 'l ovn number'||l_object_version_number);
    AHL_DEBUG_PUB.debug( 'p ovn number'||p_space_assign_rec.object_version_number);
    END IF;
   --Check for object version number
   IF l_object_version_number <> p_space_assign_rec.object_version_number
   THEN
       FND_MESSAGE.set_name('AHL', 'AHL_COM_RECORD_CHANGED');
       FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   END IF;
   -------------------Call Table handler generated procedure------------
      DELETE FROM AHL_SPACE_ASSIGNMENTS
      WHERE SPACE_ASSIGNMENT_ID = p_space_assign_rec.space_assignment_id;
  END IF;
  ---------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Delete Space Assignment','+SPANT+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_space_assignment;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Delete Space Assignment','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_space_assignment;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Delete Space Assignment','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
WHEN OTHERS THEN
    ROLLBACK TO delete_space_assignment;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_ASSIGN_PVT',
                            p_procedure_name  =>  'DELETE_SPACE_ASSIGNMENT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Delete Space Assignment','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
END Delete_Space_Assignment;
--
-- PROCEDURE
--    Schedule_Visit
--
-- PURPOSE
--    Schedule_Visit
--
-- PARAMETERS
--    p_schedule_visit_rec   : Record Representing Schedule_Visit_Rec
--
-- NOTES
-- anraj: 09-FEB-2005
--				i.		The calls to AHL_LTP_REQST_MATRL_PVT.Modify_Visit_Task_Matrls has been commnetd out because
--						it is handled in AHL_VWP_VISITS_PVT.Process_Visit.
--				ii.	The code to remove space assignment has been commented because it is handled in AHL_VWP_VISITS_PVT.Process_Visit
--				iii.	Commented cursors c_space_assign_cur,c_visit_sched_cur,visit_info_cur
PROCEDURE Schedule_Visit (
	p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_schedule_visit_rec    IN  OUT NOCOPY ahl_ltp_space_assign_pub.Schedule_Visit_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)
IS
 -- Get the existing visit details
	CURSOR	schedule_visit_cur (c_visit_id IN NUMBER)
	IS
   SELECT	visit_id,
				object_version_number,
				status_code
   FROM		AHL_VISITS_B
   WHERE		VISIT_ID = c_visit_id;

	-- anraj: commented, issue number 144
	-- To Check space assignments having different org
	/*
	CURSOR c_space_assign_cur (c_visit_id IN NUMBER)
	IS
   SELECT space_assignment_id,
          object_version_number
   FROM AHL_SPACE_ASSIGNMENTS A
   WHERE VISIT_ID = c_visit_id;
	*/
	-- anraj: commented, issue number 144
	/*
	CURSOR c_visit_sched_cur (c_visit_id IN NUMBER)
	IS
   SELECT 1
   FROM AHL_VISITS_VL
   WHERE VISIT_ID = c_visit_id
	AND (organization_id IS NULL
	OR department_id IS NULL
	OR start_date_time IS NULL );
	*/

	CURSOR	visit_det_cur  IS
	SELECT	organization_id,
				trunc(start_date_time),
				visit_name
	FROM		ahl_visits_vl
	WHERE		visit_id = p_x_schedule_visit_rec.visit_id;

	-- anraj: commented, issue number 144
	/*
	CURSOR visit_info_cur  IS
	SELECT organization_id,
		organization_name,
		department_id,
		department_name,
		visit_type_code
	FROM ahl_visits_info_v
	WHERE VISIT_ID = p_x_schedule_visit_rec.visit_id;
	*/

	--
	l_api_name        CONSTANT VARCHAR2(30) := 'SCHEDULE_VISIT';
	l_api_version     CONSTANT NUMBER       := 1.0;
	l_msg_count                NUMBER;
	l_return_status            VARCHAR2(1);
	l_msg_data                 VARCHAR2(2000);
	--l_dummy                    VARCHAR2(10);
	l_rowid                    VARCHAR2(30);
	l_organization_id          NUMBER;
	l_date                     VARCHAR2(30);
	l_department_id            NUMBER;
	l_org_name                 VARCHAR2(240);
	l_dept_name                VARCHAR2(240);
	l_visit_id                 NUMBER;
	l_visit_type_code          VARCHAR2(30);
	l_object_version_number    NUMBER;
	l_start_date_time          DATE;
	l_visit_name               VARCHAR2(80);
	l_visit_status_code        VARCHAR2(30);
	--
	l_schedule_visit_rec      schedule_visit_cur%ROWTYPE;
	--l_space_assign_rec        c_space_assign_cur%ROWTYPE;
	--
	l_Visit_tbl    ahl_vwp_visits_pvt.Visit_Tbl_Type;
	i number := 0;
	BEGIN

		IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
			fnd_log.string
			(
				fnd_log.level_procedure,
				'ahl.plsql.AHL_LTP_SPACE_ASSIGN_PVT.Schedule_Visit',
				'At the start of PLSQL procedure'
			);
		END IF;

		--------------------Initialize ----------------------------------
		-- Standard Start of API savepoint
		SAVEPOINT schedule_visit;
		-- Check if API is called in debug mode. If yes, enable debug.
		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.enable_debug;
		END IF;
		-- Debug info.
		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_assign_pvt.Schedule Visit','+SPANT+');
		END IF;
		-- Standard call to check for call compatibility.
		IF FND_API.to_boolean(p_init_msg_list)
		THEN
			FND_MSG_PUB.initialize;
		END IF;
		--  Initialize API return status to success
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		-- Initialize message list if p_init_msg_list is set to TRUE.
		IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
   ---------------------start API Body------------------------------------
		IF p_module_type = 'JSP'
		THEN
			p_x_schedule_visit_rec.org_id := null;
			p_x_schedule_visit_rec.dept_id := null;
		END IF;

		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'planned end hour'||p_x_schedule_visit_rec.planned_end_hour);
			AHL_DEBUG_PUB.debug( 'plan end date'||p_x_schedule_visit_rec.planned_end_date);
		END IF;

		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'dept id'||p_x_schedule_visit_rec.org_name);
		END IF;

		-- moved this block of code up, to get acess to l_visit_id
		-- Convert Visit Number to visit id
		IF (p_x_schedule_visit_rec.visit_number IS NOT NULL AND
          p_x_schedule_visit_rec.visit_number <> FND_API.G_MISS_NUM )   OR
         (p_x_schedule_visit_rec.visit_id IS NOT NULL AND
          p_x_schedule_visit_rec.visit_id <> FND_API.G_MISS_NUM) THEN

			Check_visit_number_Or_Id
               (p_visit_id         => p_x_schedule_visit_rec.visit_id,
                p_visit_number      => p_x_schedule_visit_rec.visit_number,
                x_visit_id         => l_visit_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

         IF NVL(l_return_status,'x') <> 'S'
         THEN
				Fnd_Message.SET_NAME('AHL','AHL_LTP_VISIT_NOT_EXISTS');
            Fnd_Message.SET_TOKEN('VISITID',p_x_schedule_visit_rec.visit_number);
            Fnd_Msg_Pub.ADD;
         END IF;
		END IF;

		--Get the existing Record
		OPEN  schedule_visit_cur(l_visit_id);
		FETCH schedule_visit_cur INTO l_schedule_visit_rec;
		CLOSE schedule_visit_cur;


		--Assign the returned value
		p_x_schedule_visit_rec.visit_id := l_visit_id;


		--Convert Value To ID
		IF (	p_x_schedule_visit_rec.org_name IS NULL OR
				p_x_schedule_visit_rec.org_name = FND_API.G_MISS_CHAR) THEN
			-- anraj: if visit is in planning Organization is not mandatory
			IF (l_schedule_visit_rec.status_code <> 'PLANNING') THEN
				Fnd_Message.SET_NAME('AHL','AHL_LTP_ORG_REQUIRED');
				Fnd_Msg_Pub.ADD;
			END IF;
		END IF;

		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'dept name'||p_x_schedule_visit_rec.dept_name);
		END IF;
    --DEPT ID
		IF (	p_x_schedule_visit_rec.dept_name IS NULL OR
				p_x_schedule_visit_rec.dept_name = FND_API.G_MISS_CHAR) THEN
		  -- anraj: if visit is in planning Department is not mandatory
			IF (l_schedule_visit_rec.status_code <> 'PLANNING') THEN
				Fnd_Message.SET_NAME('AHL','AHL_LTP_DEPT_REQUIRED');
            Fnd_Msg_Pub.ADD;
			END IF;
		END IF;
    --

     -- Check for visit start date
		IF (	p_x_schedule_visit_rec.start_date IS  NULL AND
				p_x_schedule_visit_rec.start_date = FND_API.G_MISS_DATE)
		THEN
           Fnd_Message.SET_NAME('AHL','AHL_LTP_START_DATE_INVALID');
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.G_EXC_ERROR;
		END IF;
		--

		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'space mean:'||p_x_schedule_visit_rec.space_category_mean);
			AHL_DEBUG_PUB.debug( 'space code:'||p_x_schedule_visit_rec.space_category_code);
		END IF;

		--For Space Category
      IF p_x_schedule_visit_rec.space_category_mean IS NOT NULL AND
         p_x_schedule_visit_rec.space_category_mean <> Fnd_Api.G_MISS_CHAR
      THEN
			Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_LTP_SPACE_CATEGORY',
                  p_lookup_code  => NULL,
                  p_meaning      => p_x_schedule_visit_rec.space_category_mean,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => p_x_schedule_visit_rec.space_category_code,
                  x_return_status => l_return_status);

         IF NVL(l_return_status, 'X') <> 'S'
         THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_SP_CATEGORY_NOT_EXIST');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
		ELSE
			-- Id presents
         IF p_x_schedule_visit_rec.space_category_code IS NOT NULL AND
            p_x_schedule_visit_rec.space_category_code <> Fnd_Api.G_MISS_CHAR
         THEN
           p_x_schedule_visit_rec.space_category_code := p_x_schedule_visit_rec.space_category_code;
			END IF;
		END IF;

		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'mean:'||p_x_schedule_visit_rec.visit_type_mean);
			AHL_DEBUG_PUB.debug( 'visit type code:'||p_x_schedule_visit_rec.visit_type_code);
		END IF;

		-- Visit type code
      IF p_x_schedule_visit_rec.visit_type_mean IS NOT NULL AND
         p_x_schedule_visit_rec.visit_type_mean <> Fnd_Api.G_MISS_CHAR
      THEN
			Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_PLANNING_VISIT_TYPE',
                  p_lookup_code  => NULL,
                  p_meaning      => p_x_schedule_visit_rec.visit_type_mean,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => p_x_schedule_visit_rec.visit_type_code,
                  x_return_status => l_return_status);

         IF NVL(l_return_status, 'X') <> 'S'
         THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_VISIT_TYPE_NOT_EXISTS');
            Fnd_Message.SET_TOKEN('VISIT',p_x_schedule_visit_rec.visit_type_mean);
            Fnd_Msg_Pub.ADD;
         END IF;
		ELSE
        -- Id presents
			IF p_x_schedule_visit_rec.visit_type_code IS NOT NULL AND
            p_x_schedule_visit_rec.visit_type_code <> Fnd_Api.G_MISS_CHAR
			THEN
	           p_x_schedule_visit_rec.visit_type_code := p_x_schedule_visit_rec.visit_type_code;
			--
		    --Commented by mpothuku on 02/25/04 as Visit type in not mandatory
			/*
			ELSIF (l_schedule_visit_rec.status_code <> 'PLANNING' )
			THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_VISIT_TYPE_REQUIRED');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
			*/
			END IF;

		END IF;
     --
		IF p_x_schedule_visit_rec.object_version_number <> l_schedule_visit_rec.object_version_number
		THEN
			Fnd_Message.SET_NAME('AHL','AHL_LTP_INVALID_RECORD');
         Fnd_Msg_Pub.ADD;
		END IF;

		-- Check for visit status
		-- anraj : Commented the following block as Impelmented/Partially Implemented visits can also be updated.
		/* IF (l_schedule_visit_rec.status_code <> 'PLANNING' )THEN
        Fnd_Message.SET_NAME('AHL','AHL_VISIT_NOT_PLANNED');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
		END IF;
		*/

		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'dept id'||p_x_schedule_visit_rec.dept_id);
			AHL_DEBUG_PUB.debug( 'visit type'||p_x_schedule_visit_rec.visit_type_code);
		END IF;
		--
		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'schedule visits schedule_flag'||p_x_schedule_visit_rec.schedule_flag);
		END IF;

		-- anraj: commented, issue number 144
		-- commented since space assigments are taken care of in the AHL_VWP_VISITS_PVT.Process_Visit
		/*
		IF p_x_schedule_visit_rec.schedule_flag <> 'Y' THEN
			-- Check for the visit has been assigned to different org and department
			IF (	p_x_schedule_visit_rec.org_id IS NOT NULL AND
				p_x_schedule_visit_rec.org_id <> FND_API.G_MISS_NUM)
				OR
				(	p_x_schedule_visit_rec.org_name IS NOT NULL AND
				p_x_schedule_visit_rec.org_name <> FND_API.G_MISS_CHAR)
			THEN

				-- Check for Org has been changes
				OPEN visit_info_cur;
				FETCH visit_info_cur INTO l_organization_id,l_org_name,l_department_id,
		                          l_dept_name,l_visit_type_code;
				CLOSE visit_info_cur;
				--
				IF (	p_x_schedule_visit_rec.org_id <> l_organization_id OR
					p_x_schedule_visit_rec.org_name <> l_org_name OR
					p_x_schedule_visit_rec.dept_id <> l_department_id OR
					p_x_schedule_visit_rec.dept_name <> l_dept_name OR
					p_x_schedule_visit_rec.visit_type_code <> l_visit_type_code)
				THEN

					OPEN c_space_assign_cur( l_schedule_visit_rec.visit_id);
					LOOP
						FETCH c_space_assign_cur INTO l_space_assign_rec;
						EXIT WHEN c_space_assign_cur%NOTFOUND;
						--
						DELETE FROM ahl_space_assignments
						WHERE space_assignment_id = l_space_assign_rec.space_assignment_id;
						--
					END LOOP;
					CLOSE c_space_assign_cur;
				--
				END IF; --dept condtion
			END IF;  --org condition
		END IF; --Schedule flag
	*/
		--Standard check to count messages
		l_msg_count := Fnd_Msg_Pub.count_msg;

		IF l_msg_count > 0 THEN
			X_msg_count := l_msg_count;
			X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
			RAISE Fnd_Api.G_EXC_ERROR;
		END IF;

		OPEN  visit_det_cur;
			FETCH visit_det_cur INTO l_organization_id,l_start_date_time,l_visit_name;
		CLOSE visit_det_cur;

		-- ORGANIZATION_ID
		IF p_x_schedule_visit_rec.org_id = FND_API.g_miss_num THEN
			p_x_schedule_visit_rec.org_id := NULL;
		END IF;
		-- DEPARTMENT_ID
		IF p_x_schedule_visit_rec.dept_id = FND_API.g_miss_num THEN
			p_x_schedule_visit_rec.dept_id := NULL;
		END IF;
		-- START_DATE_TIME
		IF p_x_schedule_visit_rec.start_date = FND_API.g_miss_date THEN
			p_x_schedule_visit_rec.start_date := NULL;
		END IF;
		-- PLANNED_DATE_TIME
		IF p_x_schedule_visit_rec.planned_end_date = FND_API.g_miss_date THEN
			p_x_schedule_visit_rec.planned_end_date := NULL;
		END IF;
		-- Space Categpry
		IF p_x_schedule_visit_rec.space_category_code = FND_API.g_miss_char THEN
			p_x_schedule_visit_rec.space_category_code := NULL;
		END IF;
		-- Visit type Code
		IF p_x_schedule_visit_rec.visit_type_code = FND_API.g_miss_char THEN
			p_x_schedule_visit_rec.visit_type_code := NULL;
		END IF;
		-- Planned End Hour
		IF p_x_schedule_visit_rec.planned_end_hour = FND_API.g_miss_num THEN
			p_x_schedule_visit_rec.planned_end_hour := NULL;
		END IF;
		-- Start Hour
		IF p_x_schedule_visit_rec.start_hour = FND_API.g_miss_num THEN
			p_x_schedule_visit_rec.start_hour := NULL;
		END IF;

     --
		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'start date'||TO_CHAR(p_x_schedule_visit_rec.start_date, 'DD-MM-YYYY ') ||to_char(p_x_schedule_visit_rec.start_hour) ||':00');
			AHL_DEBUG_PUB.debug( 'start hour'||p_x_schedule_visit_rec.start_hour);
			AHL_DEBUG_PUB.debug( 'plan end date'||p_x_schedule_visit_rec.planned_end_date);
		END IF;

		--Check for visit scheduled or not
		-- anraj: commented, issue number 144
		/*
			OPEN c_visit_sched_cur(l_visit_id);
			FETCH c_visit_sched_cur INTO l_dummy;
			CLOSE c_visit_sched_cur;
		*/

		--Standard check to count messages
		l_msg_count := Fnd_Msg_Pub.count_msg;

		IF l_msg_count > 0 THEN
			X_msg_count := l_msg_count;
			X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
			RAISE Fnd_Api.G_EXC_ERROR;
		END IF;

		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'before assign l_visit_id:'||l_visit_id);
			AHL_DEBUG_PUB.debug( 'before assign visit number:'||p_x_schedule_visit_rec.visit_number);
			AHL_DEBUG_PUB.debug( 'before assign org id:'||p_x_schedule_visit_rec.org_id);
			AHL_DEBUG_PUB.debug( 'before assign dept:'||p_x_schedule_visit_rec.dept_id);
			AHL_DEBUG_PUB.debug( 'before assign dept:'||p_x_schedule_visit_rec.dept_id);
			AHL_DEBUG_PUB.debug( 'before assign space_category_code:'||p_x_schedule_visit_rec.space_category_code);
			AHL_DEBUG_PUB.debug( 'before assign space_category_code:'||p_x_schedule_visit_rec.space_category_code);
			AHL_DEBUG_PUB.debug( 'before assign end date:'||p_x_schedule_visit_rec.planned_end_date);
		END IF;

		l_Visit_tbl(i).VISIT_ID               := l_visit_id;
		l_Visit_tbl(i).VISIT_NUMBER           := p_x_schedule_visit_rec.visit_number;
		l_Visit_tbl(i).VISIT_NAME             := l_visit_name;
		l_Visit_tbl(i).OBJECT_VERSION_NUMBER  :=p_x_schedule_visit_rec.object_version_number;
		l_Visit_tbl(i).ORG_NAME               := p_x_schedule_visit_rec.org_name;
		l_Visit_tbl(i).ORGANIZATION_ID        := p_x_schedule_visit_rec.org_id;
		l_Visit_tbl(i).DEPARTMENT_ID         := p_x_schedule_visit_rec.dept_id;
		l_Visit_tbl(i).DEPT_NAME             := p_x_schedule_visit_rec.dept_name;
		l_Visit_tbl(i).SPACE_CATEGORY_CODE   := p_x_schedule_visit_rec.space_category_code;
		l_Visit_tbl(i).SPACE_CATEGORY_NAME   := p_x_schedule_visit_rec.space_category_mean;
		l_Visit_tbl(i).START_DATE            := p_x_schedule_visit_rec.start_date;
		l_Visit_tbl(i).START_HOUR            := to_char(to_number(p_x_schedule_visit_rec.start_hour));
		l_Visit_tbl(i).START_MIN            := null;
		l_Visit_tbl(i).PLAN_END_DATE         := p_x_schedule_visit_rec.planned_end_date;
		l_Visit_tbl(i).PLAN_END_HOUR         := to_char(to_number(p_x_schedule_visit_rec.planned_end_hour));
		l_Visit_tbl(i).PLAN_END_MIN			:= null;
		l_Visit_tbl(i).VISIT_TYPE_CODE        := p_x_schedule_visit_rec.visit_type_code;
		l_Visit_tbl(i).VISIT_TYPE_NAME        := p_x_schedule_visit_rec.visit_type_mean;
		l_Visit_tbl(i).OPERATION_FLAG        := 'U';

		IF l_Visit_tbl.COUNT > 0 THEN
			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
					'Before Calling ahl Vwp Visits Pvt Process Visit Records : '|| l_visit_tbl.count
				);
			END IF;

			AHL_VWP_VISITS_PVT.Process_Visit
	        (
            p_api_version          => p_api_version,
            p_init_msg_list        => p_init_msg_list,
            p_commit               => p_commit,
            p_validation_level     => p_validation_level,
            p_module_type          => p_module_type,
            p_x_Visit_tbl          => l_visit_tbl,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data
			);
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
				'Before Calling ahl Vwp Visits Pvt status : '|| l_return_status
			);
		END IF;

		-- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
			IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
		END IF;


		--  anraj commented as material planning is handled in AHL_VWP_VISITS_PVT.Process_Visit
		--  issue number 144, LTP issues , CMRO Forum
		/*
		IF (p_x_schedule_visit_rec.org_id <> l_organization_id OR
		   trunc(p_x_schedule_visit_rec.start_date) <> l_start_date_time OR
		   l_dummy IS NOT NULL ) THEN

			IF G_DEBUG='Y' THEN
					AHL_DEBUG_PUB.debug( 'before calling when Org Or Start date change AHL_LTP_REQST_MATRL_PVT.Create_Planned_Materials');
					AHL_DEBUG_PUB.debug( 'before calling Visit ID:'||l_visit_id);
					AHL_DEBUG_PUB.debug( 'before calling Start Date:'||p_x_schedule_visit_rec.start_date);
					AHL_DEBUG_PUB.debug( 'before calling Org ID:'||p_x_schedule_visit_rec.org_id);
			END IF;

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
					fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
					'Before Calling ahl ltp reqst matrl pvt Modify Visit Task Material for Visit Id : '|| l_visit_id
				);
			END IF;
			--


			AHL_LTP_REQST_MATRL_PVT.Modify_Visit_Task_Matrls
		          (	p_api_version         => l_api_version,
                  p_init_msg_list       => p_init_msg_list,
                  p_commit              => p_commit,
                  p_validation_level    => p_validation_level,
                  p_visit_id            => l_visit_id,
						p_start_time          => p_x_schedule_visit_rec.start_date,
						p_org_id              => p_x_schedule_visit_rec.org_id,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data);

		END IF;
		*/
		--Standard check to count messages
		l_msg_count := Fnd_Msg_Pub.count_msg;

		IF l_msg_count > 0 THEN
			X_msg_count := l_msg_count;
			X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
			RAISE Fnd_Api.G_EXC_ERROR;
		END IF;

  ---------------------------End of Body---------------------------------------

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Schedule Visit','+SPANT+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO schedule_visit;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
               x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Schedule Visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO schedule_visit;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Schedule visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
WHEN OTHERS THEN
    ROLLBACK TO schedule_visit;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_ASSIGN_PVT',
                            p_procedure_name  =>  'SCHEDULE_VISIT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
               x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Schedule Visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

    END IF;
END Schedule_Visit;
--
-- PROCEDURE
--    Unschedule_Visit
--
-- PURPOSE
--    Unschedule_Visit
--
-- PARAMETERS
--    p_x_schedule_visit_rec   : Record Representing Schedule_Visit_Rec
--
-- NOTES
-- anraj: 09-FEB-2005
--				i.		Commented the UPDATE of ahl_schedule_materials
--				ii.	The code to remove space assignment has been commented because it is handled in AHL_VWP_VISITS_PVT.Process_Visit
--				iii.	Commented cursors c_space_assign_cur,c_visit_task_matrl_cur,c_sch_mat_cur
PROCEDURE Unschedule_Visit (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_schedule_visit_rec    IN  OUT NOCOPY ahl_ltp_space_assign_pub.Schedule_Visit_Rec,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)
IS

	CURSOR c_schedule_visit_cur (c_visit_id IN NUMBER)
	IS
   SELECT visit_id, status_code,
          object_version_number
   FROM AHL_VISITS_B
   WHERE VISIT_ID = c_visit_id;
	--
	/*
	CURSOR c_space_assign_cur (c_visit_id IN NUMBER)
	IS
   SELECT space_assignment_id,
          object_version_number
   FROM AHL_SPACE_ASSIGNMENTS
   WHERE VISIT_ID = c_visit_id;
	*/
	--
	/*
	CURSOR c_sch_mat_cur (c_visit_id IN NUMBER)
   IS
	SELECT scheduled_material_id,
         object_version_number
   FROM ahl_schedule_materials
	WHERE visit_id = c_visit_id;
	*/
	--
	/*
	CURSOR c_visit_task_matrl_cur(c_sch_mat_id IN NUMBER)
	IS
	SELECT scheduled_date,scheduled_quantity
	FROM ahl_visit_task_matrl_v
	WHERE schedule_material_id = c_sch_mat_id;
	*/
	l_api_name        CONSTANT VARCHAR2(30) := 'UNSCHEDULE_VISIT';
	l_api_version     CONSTANT NUMBER       := 1.0;
	l_msg_count                NUMBER;
	l_return_status            VARCHAR2(1);
	l_msg_data                 VARCHAR2(2000);
	l_dummy                    NUMBER;
	l_rowid                    VARCHAR2(30);
	l_organization_id          NUMBER;
	l_department_id            NUMBER;
	l_visit_id                 NUMBER;
	l_object_version_number    NUMBER;
	l_start_date_time          DATE;
	l_space_assignment_id      NUMBER;
	l_space_version_number     NUMBER;
	l_visit_status_code        VARCHAR2(30);
	l_meaning                  VARCHAR2(80);
	--
	--l_schedule_material_id     NUMBER;
	--l_scheduled_date           DATE;
	--l_scheduled_quantity       NUMBER;
	--
	l_visit_tbl		    AHL_VWP_VISITS_PVT.Visit_Tbl_Type;
	i			    NUMBER := 0;
	l_visit_name               VARCHAR2(80);
	BEGIN
		--------------------Initialize ----------------------------------
		-- Standard Start of API savepoint
		SAVEPOINT unschedule_visit;
		-- Check if API is called in debug mode. If yes, enable debug.
		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.enable_debug;
		END IF;
		-- Debug info.
		IF G_DEBUG='Y' THEN
			AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_assign_pvt.Unschedule Visit','+SPANT+');
		END IF;
		-- Standard call to check for call compatibility.
		IF FND_API.to_boolean(p_init_msg_list)
		THEN
			FND_MSG_PUB.initialize;
		END IF;
		--  Initialize API return status to success
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		-- Initialize message list if p_init_msg_list is set to TRUE.
		IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		---------------------start API Body------------------------------------
      -- Convert Visit Number to visit id
      IF (p_x_schedule_visit_rec.visit_number IS NOT NULL AND
          p_x_schedule_visit_rec.visit_number <> FND_API.G_MISS_NUM )   OR
         (p_x_schedule_visit_rec.visit_id IS NOT NULL AND
          p_x_schedule_visit_rec.visit_id <> FND_API.G_MISS_NUM) THEN

          Check_visit_number_Or_Id
               (p_visit_id         => p_x_schedule_visit_rec.visit_id,
                p_visit_number      => p_x_schedule_visit_rec.visit_number,
                x_visit_id         => l_visit_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

			IF NVL(l_return_status,'x') <> 'S'
         THEN
				Fnd_Message.SET_NAME('AHL','AHL_LTP_VISIT_NOT_EXISTS');
            Fnd_Message.SET_TOKEN('VISITID',p_x_schedule_visit_rec.visit_number);
            Fnd_Msg_Pub.ADD;
         END IF;
		END IF;
		--Assign the returned value
		p_x_schedule_visit_rec.visit_id := l_visit_id;
		--Get the existing Record
		OPEN c_schedule_visit_cur(l_visit_id);
		FETCH  c_schedule_visit_cur INTO l_visit_id,l_visit_status_code,
                                      l_object_version_number;
		CLOSE c_schedule_visit_cur;
		--
		IF p_x_schedule_visit_rec.object_version_number <> l_object_version_number
		THEN
			Fnd_Message.SET_NAME('AHL','AHL_LTP_INAVLID_RECORD');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
		END IF;
		-- Check for visit status
		IF (l_visit_status_code <> 'PLANNING' )THEN
        Fnd_Message.SET_NAME('AHL','AHL_VISIT_NOT_PLANNED');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
		END IF;
		--
		--Check for material scheduling
		-- anraj commented because material scheduling is handled in AHL_VWP_VISITS_PVT.Process_Visit
		-- issue number 144, LTP issues , CMRO Forum
		/*
		OPEN c_sch_mat_cur(l_visit_id);
		LOOP
			FETCH c_sch_mat_cur INTO l_schedule_material_id,
	                          l_object_version_number;
			EXIT WHEN c_sch_mat_cur%NOTFOUND;

			IF l_schedule_material_id IS NOT NULL THEN
			--Check for Item scheduled
				OPEN c_visit_task_matrl_cur(l_schedule_material_id);
				FETCH c_visit_task_matrl_cur INTO l_scheduled_date,l_scheduled_quantity;
				IF l_scheduled_date IS NOT NULL THEN
					Fnd_Message.SET_NAME('AHL','AHL_LTP_MRP_SCHEDUl_ITEM');
					Fnd_Msg_Pub.ADD;
					CLOSE c_visit_task_matrl_cur;
					RAISE Fnd_Api.G_EXC_ERROR;
				ELSE
					UPDATE ahl_schedule_materials
					SET	requested_quantity = 0,
							object_version_number = l_object_version_number + 1,
							last_update_date      = SYSDATE,
							last_updated_by       = Fnd_Global.user_id,
							last_update_login     = Fnd_Global.login_id
					WHERE scheduled_material_id = l_schedule_material_id;
				--
				END IF;  --Scheduled date
			CLOSE c_visit_task_matrl_cur;
			--
			END IF;-- Scheduled mat id
      END LOOP;
      CLOSE c_sch_mat_cur;
		*/
		--
      --Check for Record in space assignments
		-- anraj: commented, issue number 144
		-- commented since space assigments are taken care of in the AHL_VWP_VISITS_PVT.Process_Visit
		/*
		IF l_visit_id IS NOT NULL THEN
			OPEN c_space_assign_cur(l_visit_id);
			LOOP
				FETCH c_space_assign_cur INTO l_space_assignment_id,l_space_version_number;
				EXIT WHEN c_space_assign_cur%NOTFOUND;
				-- Remove space assingment record
				DELETE FROM AHL_SPACE_ASSIGNMENTS
				WHERE space_assignment_id = l_space_assignment_id;
			--
			END LOOP;
			CLOSE c_space_assign_cur;
		END IF;
		*/
     --Update visits table
     /* changes made by mpothuku on 12/20/04 for calling the VWP API to make the visit update instead of directly
		updating the visit. */
		-- Changes by mpothuku start
     /*
     UPDATE AHL_VISITS_B
     SET organization_id = NULL,
         department_id   = NULL,
         start_date_time = NULL,
		   close_date_time = NULL,
		   any_task_chg_flag   = 'Y',
		   object_version_number = l_object_version_number + 1,
           last_update_date      = SYSDATE,
           last_updated_by       = Fnd_Global.user_id,
           last_update_login     = Fnd_Global.login_id

       WHERE visit_id = l_visit_id;
     */
     -- Visit Name Mandatory for Update
     SELECT visit_name INTO l_visit_name
     FROM AHL_VISITS_VL WHERE VISIT_ID = l_visit_id;

     l_visit_tbl(i).VISIT_NUMBER          := p_x_schedule_visit_rec.visit_number;
     l_visit_tbl(i).VISIT_NAME            := l_visit_name;
     l_visit_tbl(i).organization_id			:= NULL;
     l_visit_tbl(i).department_id			:= NULL;
     l_visit_tbl(i).start_date				:= NULL;
     l_visit_tbl(i).start_hour				:= NULL;
     l_visit_tbl(i).START_MIN					:= NULL;
     l_visit_tbl(i).plan_end_date			:= NULL;
     l_visit_tbl(i).plan_end_hour			:= NULL;
     l_visit_tbl(i).plan_end_min				:= NULL;
     l_visit_tbl(i).visit_id					:= l_visit_id;
     l_visit_tbl(i).object_version_number := p_x_schedule_visit_rec.object_version_number;
     l_visit_tbl(i).operation_flag        := 'U';

		IF l_Visit_tbl.COUNT > 0 THEN
			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
				fnd_log.string
				(
					fnd_log.level_statement,
               'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
					'Before Calling ahl Vwp Visits Pvt Process Visit Records : '|| l_visit_tbl.count
				);

			END IF;

			AHL_VWP_VISITS_PVT.Process_Visit
			(
            p_api_version          => p_api_version,
            p_init_msg_list        => p_init_msg_list,
            p_commit               => p_commit,
            p_validation_level     => p_validation_level,
            p_module_type          => p_module_type,
            p_x_Visit_tbl	   => l_visit_tbl,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data
			);
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'After Calling ahl Vwp Visits Pvt status : '|| l_return_status
		);

     END IF;

		-- Check Error Message stack.
		IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
			l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
		END IF;

     -- Changes by mpothuku End

  ---------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Unschedule Visit','+SPANT+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO unschedule_visit;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

         AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
         AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Unschedule Visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO unschedule_visit;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Unschedule visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN OTHERS THEN
    ROLLBACK TO unschedule_visit;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_ASSIGN_PVT',
                            p_procedure_name  =>  'UNSCHEDULE_VISIT',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_assign_pvt.Unschedule Visit','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
END Unschedule_Visit;

END AHL_LTP_SPACE_ASSIGN_PVT;

/
