--------------------------------------------------------
--  DDL for Package Body AHL_LTP_SIMUL_PLAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_SIMUL_PLAN_PVT" AS
/* $Header: AHLVSPNB.pls 120.5.12010000.2 2010/01/27 09:46:44 skpathak ship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_SIMUL_PLAN_PVT';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
--
-----------------------------------------------------------
-- PACKAGE
--    AHL_LTP_SIMUL_PLAN_PVT
--
-- PURPOSE
--    This package is a Private API for managing Simulation plans information in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_SIMULATION_PLANS_VL:
--    Create_Simulation_plan (see below for specification)
--    Update_Simulation_plan (see below for specification)
--    Delete_Simulation_plan (see below for specification)
--    Validate_Simulation_plan (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 23-Apr-2002    ssurapan      Created.
--------------------------------------------------------------------
-- PROCEDURE
--    CHECK_PLAN_NAME_OR_ID
--
-- PURPOSE
--    Converts Plan Name to ID or Vice versa
--
-- PARAMETERS
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Check_plan_name_Or_Id
    (p_simulation_plan_id     IN NUMBER,
     p_plan_name              IN VARCHAR2,
     x_plan_id             OUT NOCOPY NUMBER,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_error_msg_code      OUT NOCOPY VARCHAR2
     )
   IS
BEGIN
      IF (p_simulation_plan_id IS NOT NULL)
       THEN
          SELECT simulation_plan_id
              INTO x_plan_id
            FROM AHL_SIMULATION_PLANS_VL
          WHERE simulation_plan_id   = p_simulation_plan_id;
      ELSE
          SELECT simulation_plan_id
              INTO x_plan_id
            FROM AHL_SIMULATION_PLANS_VL
          WHERE SIMULATION_PLAN_NAME = p_plan_name;
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
END Check_plan_name_Or_Id;

--------------------------------------------------------------------
-- FUNCTION
--    Get_Visit_Task_Number
--
-- PURPOSE
--    To retrieve visit task's task number with maximum plus one criteria
--------------------------------------------------------------------

FUNCTION Get_Visit_Task_Number(p_visit_id IN NUMBER,p_task_number IN NUMBER)
RETURN NUMBER
IS
 -- To find out the maximum task number value in the visit
    CURSOR c_task_number IS
      SELECT visit_task_number
      FROM Ahl_Visit_Tasks_B
      WHERE Visit_Id = p_visit_id
   and visit_task_number = p_task_number;

 CURSOR gen_task_number IS
      SELECT MAX(visit_task_number)
      FROM Ahl_Visit_Tasks_B
      WHERE Visit_Id = p_visit_id;

    x_Visit_Task_Number NUMBER;
BEGIN
   -- Check for Visit Number
 OPEN c_Task_Number;
 FETCH c_Task_Number INTO x_Visit_Task_Number;
 CLOSE c_Task_Number;
 IF x_Visit_Task_Number IS NOT NULL THEN
  OPEN gen_task_number;
  FETCH gen_task_number INTO x_Visit_Task_Number;
  CLOSE gen_task_number;
  x_Visit_Task_Number := x_Visit_Task_Number + 1;
 ELSE
  x_Visit_Task_Number := p_task_number;
 END IF;

   RETURN x_Visit_Task_Number;
END Get_Visit_Task_Number;

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Simulation_Rec
--
---------------------------------------------------------------------
PROCEDURE Complete_Simulation_Rec (
   p_simulation_rec      IN  Simulation_plan_rec,
   x_simulation_rec      OUT NOCOPY Simulation_plan_rec
)
IS
  CURSOR c_simulation_rec
   IS
   SELECT ROW_ID,
          SIMULATION_PLAN_ID,
          SIMULATION_PLAN_NAME,
          PRIMARY_PLAN_FLAG,
          DESCRIPTION,
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
     FROM  ahl_simulation_plans_vl
   WHERE   simulation_plan_id = p_simulation_rec.simulation_plan_id;
   --
   -- This is the only exception for using %ROWTYPE.
   l_simulation_rec    c_simulation_rec%ROWTYPE;
BEGIN
   x_simulation_rec := p_simulation_rec;
   OPEN c_simulation_rec;
   FETCH c_simulation_rec INTO l_simulation_rec;
   IF c_simulation_rec%NOTFOUND THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AHL', 'AHL_LTP_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   END IF;
   CLOSE c_simulation_rec;
   --Check for object version number
    IF (l_simulation_rec.object_version_number <> p_simulation_rec.object_version_number)
    THEN
        Fnd_Message.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'inside complete name 1:'||l_simulation_rec.simulation_plan_name);
    END IF;

   -- SIMULATION_PLAN_NAME
   IF p_simulation_rec.simulation_plan_name <> FND_API.g_miss_char THEN
      x_simulation_rec.simulation_plan_name := p_simulation_rec.simulation_plan_name;
      ELSE
      x_simulation_rec.simulation_plan_name := l_simulation_rec.simulation_plan_name;
   END IF;
   -- DESCRIPTION
   IF p_simulation_rec.description <> FND_API.g_miss_char THEN
      x_simulation_rec.description := p_simulation_rec.description;
      ELSE
      x_simulation_rec.description := l_simulation_rec.description;
   END IF;
   -- ATTRIBUTE CATEGORY
   IF p_simulation_rec.attribute_category <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute_category := p_simulation_rec.attribute_category;
      ELSE
      x_simulation_rec.attribute_category := l_simulation_rec.attribute_category;
   END IF;
   -- ATTRIBUTE 1
   IF p_simulation_rec.attribute1 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute1 := p_simulation_rec.attribute1;
      ELSE
      x_simulation_rec.attribute1 := l_simulation_rec.attribute1;
   END IF;
   -- ATTRIBUTE 2
   IF p_simulation_rec.attribute2 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute2 := p_simulation_rec.attribute2;
      ELSE
      x_simulation_rec.attribute2 := l_simulation_rec.attribute2;
   END IF;
   -- ATTRIBUTE 3
   IF p_simulation_rec.attribute3 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute3 := p_simulation_rec.attribute3;
      ELSE
      x_simulation_rec.attribute3 := l_simulation_rec.attribute3;
   END IF;
   -- ATTRIBUTE 4
   IF p_simulation_rec.attribute4 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute4 := p_simulation_rec.attribute4;
      ELSE
      x_simulation_rec.attribute4 := l_simulation_rec.attribute4;
   END IF;
   -- ATTRIBUTE 5
   IF p_simulation_rec.attribute5 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute5 := p_simulation_rec.attribute5;
      ELSE
      x_simulation_rec.attribute5 := l_simulation_rec.attribute5;
   END IF;
   -- ATTRIBUTE 6
   IF p_simulation_rec.attribute6 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute6 := p_simulation_rec.attribute6;
      ELSE
      x_simulation_rec.attribute6 := l_simulation_rec.attribute6;
   END IF;
   -- ATTRIBUTE 7
   IF p_simulation_rec.attribute7 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute7 := p_simulation_rec.attribute7;
      ELSE
      x_simulation_rec.attribute7 := l_simulation_rec.attribute7;
   END IF;
   -- ATTRIBUTE 8
   IF p_simulation_rec.attribute8 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute8 := p_simulation_rec.attribute8;
      ELSE
      x_simulation_rec.attribute8 := l_simulation_rec.attribute8;
   END IF;
   -- ATTRIBUTE 9
   IF p_simulation_rec.attribute9 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute9 := p_simulation_rec.attribute9;
      ELSE
      x_simulation_rec.attribute9 := l_simulation_rec.attribute9;
   END IF;
   -- ATTRIBUTE 10
   IF p_simulation_rec.attribute10 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute10 := p_simulation_rec.attribute10;
      ELSE
      x_simulation_rec.attribute10 := l_simulation_rec.attribute10;
   END IF;
   -- ATTRIBUTE 11
   IF p_simulation_rec.attribute11 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute11 := p_simulation_rec.attribute11;
      ELSE
      x_simulation_rec.attribute11 := l_simulation_rec.attribute11;
   END IF;
   -- ATTRIBUTE 12
   IF p_simulation_rec.attribute12 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute12 := p_simulation_rec.attribute12;
      ELSE
      x_simulation_rec.attribute12 := l_simulation_rec.attribute12;
   END IF;
   -- ATTRIBUTE 13
   IF p_simulation_rec.attribute13 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute13 := p_simulation_rec.attribute13;
      ELSE
      x_simulation_rec.attribute13 := l_simulation_rec.attribute13;
   END IF;
   -- ATTRIBUTE 14
   IF p_simulation_rec.attribute14 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute14 := p_simulation_rec.attribute14;
      ELSE
      x_simulation_rec.attribute14 := l_simulation_rec.attribute14;
   END IF;
   -- ATTRIBUTE 15
   IF p_simulation_rec.attribute15 <> FND_API.g_miss_char THEN
      x_simulation_rec.attribute15 := p_simulation_rec.attribute15;
      ELSE
      x_simulation_rec.attribute15 := l_simulation_rec.attribute15;
   END IF;

END Complete_Simulation_Rec;

---------------------------------------------------------------------
-- PROCEDURE
--    Assign_Simulation_Rec
--
---------------------------------------------------------------------
PROCEDURE Assign_Simulation_Rec (
   p_simulation_rec      IN  AHL_LTP_SIMUL_PLAN_PUB.Simulation_plan_rec,
   x_simulation_rec        OUT NOCOPY Simulation_plan_rec
)
IS

BEGIN
     x_simulation_rec.simulation_plan_id    :=  p_simulation_rec.plan_id;
     x_simulation_rec.primary_plan_flag     :=  p_simulation_rec.primary_plan_flag;
     x_simulation_rec.simulation_plan_name  :=  p_simulation_rec.plan_name;
     x_simulation_rec.description           :=  p_simulation_rec.description;
     x_simulation_rec.object_version_number :=  p_simulation_rec.object_version_number;
     x_simulation_rec.attribute_category    :=  p_simulation_rec.attribute_category;
     x_simulation_rec.attribute1            :=  p_simulation_rec.attribute1;
     x_simulation_rec.attribute2            :=  p_simulation_rec.attribute2;
     x_simulation_rec.attribute3            :=  p_simulation_rec.attribute3;
     x_simulation_rec.attribute4            :=  p_simulation_rec.attribute4;
     x_simulation_rec.attribute5            :=  p_simulation_rec.attribute5;
     x_simulation_rec.attribute6            :=  p_simulation_rec.attribute6;
     x_simulation_rec.attribute7            :=  p_simulation_rec.attribute7;
     x_simulation_rec.attribute8            :=  p_simulation_rec.attribute8;
     x_simulation_rec.attribute9            :=  p_simulation_rec.attribute9;
     x_simulation_rec.attribute10           :=  p_simulation_rec.attribute10;
     x_simulation_rec.attribute11           :=  p_simulation_rec.attribute11;
     x_simulation_rec.attribute12           :=  p_simulation_rec.attribute12;
     x_simulation_rec.attribute13           :=  p_simulation_rec.attribute13;
     x_simulation_rec.attribute14           :=  p_simulation_rec.attribute14;
     x_simulation_rec.attribute15           :=  p_simulation_rec.attribute15;

END Assign_Simulation_Rec;

------------------------------------------------------------------------------
--
-- NAME
--   Validate_Simulation_plan_Items
--
-- PURPOSE
--   This procedure is to validate Simulation plan attributes
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE Validate_Simulation_plan_Items
( p_simulation_plan_rec         IN simulation_plan_rec,
  p_validation_mode  IN VARCHAR2 := Jtf_Plsql_Api.g_create,
  x_return_status  OUT NOCOPY VARCHAR2
) IS
  l_table_name VARCHAR2(30);
  l_pk_name VARCHAR2(30);
  l_pk_value VARCHAR2(30);
  l_where_clause VARCHAR2(2000);
  l_dummy        NUMBER;
--
CURSOR check_plan_name_cur (c_plan_name IN VARCHAR2)
  IS
 SELECT 1 FROM
    AHL_SIMULATION_PLANS_VL
  WHERE simulation_plan_name = c_plan_name
    AND primary_plan_flag = 'N';


BEGIN
    --  Initialize API/Procedure return status to success
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  -- Check required parameters
  -- PLAN_NAME
     IF (p_simulation_plan_rec.SIMULATION_PLAN_NAME IS NULL
         OR
         p_simulation_plan_rec.SIMULATION_PLAN_NAME = FND_API.G_MISS_CHAR)
     THEN

          -- missing required fields
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
               Fnd_Message.set_name('AHL', 'AHL_LTP_PLAN_NAME_NOT_EXIST');
               Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
     END IF;
  --   Validate uniqueness
     OPEN check_plan_name_cur(p_simulation_plan_rec.simulation_plan_name);
     FETCH check_plan_name_cur INTO l_dummy;
      IF check_plan_name_cur%FOUND THEN
         Fnd_Message.set_name('AHL', 'AHL_LTP_SIMUL_DUPLE_NAME');
         Fnd_Msg_Pub.ADD;
      END IF;
         x_return_status := Fnd_Api.g_ret_sts_error;
      CLOSE check_plan_name_cur;
  --Check for primary plan
  IF p_simulation_plan_rec.primary_plan_flag = 'Y' THEN
     Fnd_Message.set_name('AHL', 'AHL_LTP_SIMUL_DUPLE_NAME');
     Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.g_ret_sts_error;
   END IF;

END Validate_Simulation_plan_Items;
----------------------------------------------------------------------------
-- NAME
--   Validate_Simulation_plan_Record
--
-- PURPOSE
--   This procedure is to validate Simulation plans record
--
-- NOTES
-- End of Comments
-----------------------------------------------------------------------------
PROCEDURE Validate_Simulation_plan_Rec(
   p_simulation_plan_rec  IN     simulation_plan_rec,
   x_return_status             OUT NOCOPY  VARCHAR2
) IS
      -- Status Local Variables
     l_return_status VARCHAR2(1);
  BEGIN
        --  Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
 --
   NULL;
 --
END Validate_Simulation_plan_Rec;
--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Simulation_plan
--
-- PURPOSE
--    Validate  simulation plan attributes
--
-- PARAMETERS
--
-- NOTES
--
--------------------------------------------------------------------
PROCEDURE Validate_Simulation_plan
( p_api_version         IN         NUMBER,
  p_init_msg_list       IN         VARCHAR2 := Fnd_Api.G_FALSE,
  p_validation_level    IN         NUMBER  := Fnd_Api.G_VALID_LEVEL_FULL,
  p_simulation_plan_rec IN         simulation_plan_rec,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2
)
IS
   l_api_name    CONSTANT VARCHAR2(30)  := 'Validate_Simulation_Plan';
   l_api_version CONSTANT NUMBER        := 1.0;
   l_full_name   CONSTANT VARCHAR2(60)  := G_PKG_NAME || '.' || l_api_name;
   l_return_status        VARCHAR2(1);
   l_simulation_plan_rec  simulation_plan_rec;
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
  Validate_Simulation_plan_Items
  ( p_simulation_plan_rec   => p_simulation_plan_rec,
    p_validation_mode          => Jtf_Plsql_Api.g_create,
    x_return_status  => l_return_status
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
 -- Perform cross attribute validation and missing attribute checks. Record
 -- level validation.
 IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_record
 THEN
  Validate_Simulation_plan_Rec(
    p_simulation_plan_rec         => p_simulation_plan_rec,
    x_return_status       => l_return_status
  );
  IF l_return_status = Fnd_Api.G_RET_STS_ERROR
  THEN
             RAISE Fnd_Api.G_EXC_ERROR;
  ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR
  THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
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
         ( p_count =>      x_msg_count,
    p_data =>      x_msg_data,
    p_encoded =>      Fnd_Api.G_FALSE
      );
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
        Fnd_Msg_Pub.Count_AND_Get
         ( p_count =>      x_msg_count,
    p_data =>      x_msg_data,
    p_encoded =>      Fnd_Api.G_FALSE
      );
        WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
        IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
         THEN
                Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
         Fnd_Msg_Pub.Count_AND_Get
         ( p_count =>      x_msg_count,
                  p_data =>      x_msg_data,
    p_encoded =>      Fnd_Api.G_FALSE
      );
END Validate_Simulation_plan;

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Simulation_plan
--
-- PURPOSE
--    Create Simulation plan Record
--
-- PARAMETERS
--    p_x_simulation_plan_rec: the record representing AHL_SIMULATION_PLANS_VL view..
--
-- NOTES
--------------------------------------------------------------------

PROCEDURE Create_Simulation_plan (
   p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2  := FND_API.g_false,
   p_commit                IN            VARCHAR2  := FND_API.g_false,
   p_validation_level      IN            NUMBER    := FND_API.g_valid_level_full,
   p_module_type           IN            VARCHAR2  := 'JSP',
   p_x_simulation_plan_rec IN OUT NOCOPY ahl_ltp_simul_plan_pub.Simulation_Plan_Rec,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2
 )
IS
 l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_SIMULATION_PLAN';
 l_api_version CONSTANT NUMBER       := 1.0;
 l_msg_count            NUMBER;
 l_return_status        VARCHAR2(1);
 l_msg_data             VARCHAR2(2000);
 l_dummy                NUMBER;
 l_rowid                VARCHAR2(30);
 l_simulation_plan_id   NUMBER;
 l_simulation_plan_rec  Simulation_Plan_Rec;
 --
 CURSOR c_seq IS
  SELECT AHL_SIMULATION_PLANS_B_S.NEXTVAL
  FROM   dual;
 --
 CURSOR c_id_exists (x_id IN NUMBER) IS
  SELECT 1
  FROM dual
  WHERE EXISTS (SELECT 1
                FROM ahl_simulation_plans_b
                WHERE simulation_plan_id = x_id);
 --
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT create_simulation_plan;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pvt.Create Simulation plan','+SIMPL+');
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
   --Assign to local variable
   Assign_Simulation_Rec (
   p_simulation_rec  => p_x_simulation_plan_rec,
   x_simulation_rec  => l_Simulation_plan_rec);

     -- Call Validate space rec input attributes
    Validate_Simulation_plan
      (p_api_version         => l_api_version,
       p_init_msg_list       => p_init_msg_list,
       p_validation_level    => p_validation_level,
       p_simulation_plan_rec => l_Simulation_plan_rec,
       x_return_status       => l_return_status,
       x_msg_count           => l_msg_count,
       x_msg_data            => l_msg_data );


   IF (p_x_simulation_plan_rec.plan_id = Fnd_Api.G_MISS_NUM OR
       p_x_simulation_plan_rec.plan_id IS NULL)
   THEN
         --
         -- If the ID is not passed into the API, then
         -- grab a value from the sequence.
         OPEN c_seq;
         FETCH c_seq INTO l_simulation_plan_id;
         CLOSE c_seq;
         --
         -- Check to be sure that the sequence does not exist.
         OPEN c_id_exists (l_simulation_plan_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         --
         -- If the value for the ID already exists, then
         -- l_dummy would be populated with '1', otherwise,
         -- it receives NULL.
         IF l_dummy IS NOT NULL THEN
             Fnd_Message.SET_NAME('AHL','AHL_LTP_SEQUENCE_NOT_EXISTS');
             Fnd_Msg_Pub.ADD;
          END IF;
         -- For optional fields
         IF p_x_simulation_plan_rec.description = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.description := NULL;
         ELSE
            l_simulation_plan_rec.description := p_x_simulation_plan_rec.description;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute_category = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute_category := NULL;
         ELSE
            l_simulation_plan_rec.attribute_category := p_x_simulation_plan_rec.attribute_category;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute1 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute1 := NULL;
         ELSE
            l_simulation_plan_rec.attribute1 := p_x_simulation_plan_rec.attribute1;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute2 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute2 := NULL;
         ELSE
            l_simulation_plan_rec.attribute2 := p_x_simulation_plan_rec.attribute2;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute3 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute3 := NULL;
         ELSE
            l_simulation_plan_rec.attribute3 := p_x_simulation_plan_rec.attribute3;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute4 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute4 := NULL;
         ELSE
            l_simulation_plan_rec.attribute4 := p_x_simulation_plan_rec.attribute4;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute5 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute5 := NULL;
         ELSE
            l_simulation_plan_rec.attribute5 := p_x_simulation_plan_rec.attribute5;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute6 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute6 := NULL;
         ELSE
            l_simulation_plan_rec.attribute6 := p_x_simulation_plan_rec.attribute6;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute7 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute7 := NULL;
         ELSE
            l_simulation_plan_rec.attribute7 := p_x_simulation_plan_rec.attribute7;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute8 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute8 := NULL;
         ELSE
            l_simulation_plan_rec.attribute8 := p_x_simulation_plan_rec.attribute8;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute9 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute9 := NULL;
         ELSE
            l_simulation_plan_rec.attribute9 := p_x_simulation_plan_rec.attribute9;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute10 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute10 := NULL;
         ELSE
            l_simulation_plan_rec.attribute10 := p_x_simulation_plan_rec.attribute10;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute11 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute11 := NULL;
         ELSE
            l_simulation_plan_rec.attribute11 := p_x_simulation_plan_rec.attribute11;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute12 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute12 := NULL;
         ELSE
            l_simulation_plan_rec.attribute12 := p_x_simulation_plan_rec.attribute12;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute13 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute13 := NULL;
         ELSE
            l_simulation_plan_rec.attribute13 := p_x_simulation_plan_rec.attribute13;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute14 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute14 := NULL;
         ELSE
            l_simulation_plan_rec.attribute14 := p_x_simulation_plan_rec.attribute14;
         END IF;
         --
         IF p_x_simulation_plan_rec.attribute15 = FND_API.G_MISS_CHAR THEN
            l_simulation_plan_rec.attribute15 := NULL;
         ELSE
            l_simulation_plan_rec.attribute15 := p_x_simulation_plan_rec.attribute15;
         END IF;
   END IF;
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   ----------------------------DML Operation---------------------------------
   --Call table handler generated package to insert a record
   AHL_SIMULATION_PLANS_PKG.INSERT_ROW (
         X_ROWID                   => l_rowid,
         X_SIMULATION_PLAN_ID      => l_simulation_plan_id,
         X_PRIMARY_PLAN_FLAG       => 'N',
         X_OBJECT_VERSION_NUMBER   => 1,
         X_ATTRIBUTE_CATEGORY      => l_simulation_plan_rec.attribute_category,
         X_ATTRIBUTE1              => l_simulation_plan_rec.attribute1,
         X_ATTRIBUTE2              => l_simulation_plan_rec.attribute2,
         X_ATTRIBUTE3              => l_simulation_plan_rec.attribute3,
         X_ATTRIBUTE4              => l_simulation_plan_rec.attribute4,
         X_ATTRIBUTE5              => l_simulation_plan_rec.attribute5,
         X_ATTRIBUTE6              => l_simulation_plan_rec.attribute6,
         X_ATTRIBUTE7              => l_simulation_plan_rec.attribute7,
         X_ATTRIBUTE8              => l_simulation_plan_rec.attribute8,
         X_ATTRIBUTE9              => l_simulation_plan_rec.attribute9,
         X_ATTRIBUTE10             => l_simulation_plan_rec.attribute10,
         X_ATTRIBUTE11             => l_simulation_plan_rec.attribute11,
         X_ATTRIBUTE12             => l_simulation_plan_rec.attribute12,
         X_ATTRIBUTE13             => l_simulation_plan_rec.attribute13,
         X_ATTRIBUTE14             => l_simulation_plan_rec.attribute14,
         X_ATTRIBUTE15             => l_simulation_plan_rec.attribute15,
         X_SIMULATION_PLAN_NAME    => l_simulation_plan_rec.simulation_plan_name,
         X_DESCRIPTION             => l_simulation_plan_rec.description,
         X_CREATION_DATE           => SYSDATE,
         X_CREATED_BY              => Fnd_Global.USER_ID,
         X_LAST_UPDATE_DATE        => SYSDATE,
         X_LAST_UPDATED_BY         => Fnd_Global.USER_ID,
         X_LAST_UPDATE_LOGIN       => Fnd_Global.LOGIN_ID);

  p_x_simulation_plan_rec.plan_id := l_simulation_plan_id;
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
   Ahl_Debug_Pub.debug( 'End of private api Create Simulation plan','+SMPLN+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
    END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_simulation_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Create Simulation plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_simulation_plan;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Create Simulation plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN OTHERS THEN
    ROLLBACK TO create_simulation_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PVT',
                            p_procedure_name  =>  'CREATE_SIMULATION_PLAN',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_unavl_pvt.Create Simulation plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
END Create_Simulation_plan;



--------------------------------------------------------------------
-- PROCEDURE
--    Update_Simulation_plan
--
-- PURPOSE
--    Update Simulation plan Record.
--
-- PARAMETERS
--    p_simulation_plan_rec: the record representing AHL_SIMULATION_PLANS_VL
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Update_Simulation_plan (
   p_api_version         IN           NUMBER,
   p_init_msg_list       IN           VARCHAR2  := FND_API.g_false,
   p_commit              IN           VARCHAR2  := FND_API.g_false,
   p_validation_level    IN           NUMBER    := FND_API.g_valid_level_full,
   p_module_type         IN           VARCHAR2  := 'JSP',
   p_simulation_plan_rec IN           ahl_ltp_simul_plan_pub.Simulation_plan_Rec,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  CURSOR primary_plan_cur(c_plan_id IN NUMBER)
  IS
  SELECT primary_plan_flag
    FROM AHL_SIMULATION_PLANS_VL
  WHERE simulation_plan_id = c_plan_id;

 l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_SIMULATION_PLAN';
 l_api_version CONSTANT NUMBER       := 1.0;
 l_msg_count            NUMBER;
 l_return_status        VARCHAR2(1);
 l_msg_data             VARCHAR2(2000);
 l_dummy                NUMBER;
 l_rowid                VARCHAR2(30);
 l_organization_id      NUMBER;
 l_department_id        NUMBER;
 l_space_id             NUMBER;
 l_simulation_plan_id   NUMBER;
 l_simulation_plan_rec  Simulation_Plan_Rec;
 l_Asimulation_plan_rec Simulation_Plan_Rec;
 l_primary_plan_flag    VARCHAR2(1);
BEGIN


  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT update_simulation_plan;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pvt.Update Simulation plan','+SMPNL+');
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
   --Assign to local variable
   Assign_Simulation_Rec (
   p_simulation_rec  => p_simulation_plan_rec,
   x_simulation_rec  => l_Simulation_plan_rec);
   --Start API Body

      -- Convert org name to organization id
      IF (p_simulation_plan_rec.plan_name IS NOT NULL AND
          p_simulation_plan_rec.plan_name <> FND_API.G_MISS_CHAR )   OR
         (l_simulation_plan_rec.simulation_plan_id IS NOT NULL AND
          l_simulation_plan_rec.simulation_plan_id <> FND_API.G_MISS_NUM) THEN

          Check_plan_name_Or_Id
               (p_simulation_plan_id  => l_simulation_plan_rec.simulation_plan_id,
                p_plan_name         => p_simulation_plan_rec.plan_name,
                x_plan_id           => l_simulation_plan_id,
                x_return_status    => l_return_status,
                x_error_msg_code   => l_msg_data);

          IF NVL(l_return_status,'x') <> 'S'
          THEN
              Fnd_Message.SET_NAME('AHL','AHL_LTP_PLAN_NOT_EXISTS');
              Fnd_Message.SET_TOKEN('PLANID',p_simulation_plan_rec.plan_name);
              Fnd_Msg_Pub.ADD;
          END IF;
     END IF;
     --Assign the returned value
     l_simulation_plan_rec.simulation_plan_id := l_simulation_plan_id;

  --------------------------------Validation ---------------------------
   -- get existing values and compare
   Complete_Simulation_Rec (
      p_simulation_rec  => l_simulation_plan_rec,
     x_simulation_rec   => l_Asimulation_plan_rec);

     -- Call Validate simulation plan attributes
    Validate_Simulation_plan
        ( p_api_version           => l_api_version,
          p_init_msg_list         => p_init_msg_list,
          p_validation_level      => p_validation_level,
          p_simulation_plan_rec   => l_ASimulation_plan_rec,
          x_return_status   => l_return_status,
          x_msg_count    => l_msg_count,
          x_msg_data    => l_msg_data );

  IF l_Asimulation_plan_rec.simulation_plan_id IS NOT NULL THEN
    OPEN primary_plan_cur(l_ASimulation_plan_rec.simulation_plan_id);
    FETCH primary_plan_cur INTO l_primary_plan_flag;
    CLOSE primary_plan_cur;
   IF l_primary_plan_flag = 'Y' THEN
      Fnd_Message.SET_NAME('AHL','AHL_LTP_PRIMARY_PLAN');
      Fnd_Msg_Pub.ADD;
   END IF;
   END IF;
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   ----------------------------DML Operation---------------------------------
   --Call table handler generated package to update a record
   AHL_SIMULATION_PLANS_PKG.UPDATE_ROW
         (
         X_SIMULATION_PLAN_ID      => l_Asimulation_plan_rec.simulation_plan_id,
         X_PRIMARY_PLAN_FLAG       => 'N',
         X_SIMULATION_PLAN_NAME    => l_Asimulation_plan_rec.simulation_plan_name,
         X_DESCRIPTION             => l_Asimulation_plan_rec.description,
         X_OBJECT_VERSION_NUMBER   => l_Asimulation_plan_rec.object_version_number+1,
         X_ATTRIBUTE_CATEGORY      => l_Asimulation_plan_rec.attribute_category,
         X_ATTRIBUTE1              => l_Asimulation_plan_rec.attribute1,
         X_ATTRIBUTE2              => l_Asimulation_plan_rec.attribute2,
         X_ATTRIBUTE3              => l_Asimulation_plan_rec.attribute3,
         X_ATTRIBUTE4              => l_Asimulation_plan_rec.attribute4,
         X_ATTRIBUTE5              => l_Asimulation_plan_rec.attribute5,
         X_ATTRIBUTE6              => l_Asimulation_plan_rec.attribute6,
         X_ATTRIBUTE7              => l_Asimulation_plan_rec.attribute7,
         X_ATTRIBUTE8              => l_Asimulation_plan_rec.attribute8,
         X_ATTRIBUTE9              => l_Asimulation_plan_rec.attribute9,
         X_ATTRIBUTE10             => l_Asimulation_plan_rec.attribute10,
         X_ATTRIBUTE11             => l_Asimulation_plan_rec.attribute11,
         X_ATTRIBUTE12             => l_Asimulation_plan_rec.attribute12,
         X_ATTRIBUTE13             => l_Asimulation_plan_rec.attribute13,
         X_ATTRIBUTE14             => l_Asimulation_plan_rec.attribute14,
         X_ATTRIBUTE15             => l_Asimulation_plan_rec.attribute15,
         X_LAST_UPDATE_DATE        => SYSDATE,
         X_LAST_UPDATED_BY         => Fnd_Global.USER_ID,
         X_LAST_UPDATE_LOGIN       => Fnd_Global.LOGIN_ID);


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
   Ahl_Debug_Pub.debug( 'End of private api Update Simulation plan','+SMPLN+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_simulation_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Update Simulation plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_simulation_plan;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Update Simulation plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN OTHERS THEN
    ROLLBACK TO update_simulation_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PVT',
                            p_procedure_name  =>  'UPDATE_SIMULATION_PLAN',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Update Simulation plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
END Update_Simulation_plan;


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Simulation_plan
--
-- PURPOSE
--    Delete  Simulation plan Record.
--
-- PARAMETERS
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Simulation_plan (
   p_api_version         IN     NUMBER,
   p_init_msg_list       IN     VARCHAR2  := FND_API.g_false,
   p_commit              IN     VARCHAR2  := FND_API.g_false,
   p_validation_level    IN     NUMBER    := FND_API.g_valid_level_full,
   p_simulation_plan_rec IN     ahl_ltp_simul_plan_pub.Simulation_plan_Rec,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2

)
IS
  CURSOR c_simulation_plan_cur
                 (c_simulation_plan_id IN NUMBER)
   IS
  SELECT   simulation_plan_id,object_version_number,
           primary_plan_flag
    FROM     ahl_simulation_plans_vl
   WHERE    simulation_plan_id = c_simulation_plan_id
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

 -- Added by mpothuku on 12/22/04 to retrieve the associated simulation visits.
 --mpothuku begin

  CURSOR get_simulation_visits_cur
              (c_simulation_plan_id IN NUMBER)
  IS
  SELECT   visit_id
    FROM ahl_visits_b
    WHERE simulation_plan_id = c_simulation_plan_id;

  -- Added by mpothuku on 12/22/04 to retrieve the associated simulation visits.
  CURSOR Get_simul_visit_tasks_cur(C_VISIT_ID IN NUMBER)
    IS
 SELECT visit_task_id
  FROM ahl_visit_tasks_vl
  WHERE visit_id = C_VISIT_ID;

  -- End mpothuku

 --
 l_api_name        CONSTANT VARCHAR2(30) := 'DELETE_SIMULATION_PLAN';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_dummy                    NUMBER;
 l_simulation_plan_id       NUMBER;
 l_object_version_number    NUMBER;
 l_primary_plan_flag        VARCHAR2(1);
 l_visit_id                 NUMBER;
 l_visit_tbl                AHL_VWP_VISITS_PVT.Visit_Tbl_Type;
 l_visit_count              NUMBER := 0;
 l_simul_visit_tasks_rec    Get_simul_visit_tasks_cur%ROWTYPE;
 l_count                    NUMBER;
 l_space_assignment_id      NUMBER;

BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT delete_simulation_plan;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pvt.Delete Simulation plan','+SMPLN+');
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
   -- Check for Record exists
   OPEN c_simulation_plan_cur(p_simulation_plan_rec.plan_id);
   FETCH c_simulation_plan_cur INTO l_simulation_plan_id,
                                    l_object_version_number,
                                    l_primary_plan_flag;
   IF c_simulation_plan_cur%NOTFOUND THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AHL', 'AHL_LTP_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      CLOSE c_simulation_plan_cur;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_simulation_plan_cur;
   --
   --Check for primary plan
   IF l_primary_plan_flag =  'Y'
   THEN
       FND_MESSAGE.set_name('AHL', 'AHL_LTP_PRIMARY_PLAN');
       FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   END IF;

   /* Added by mpothuku on 12/22/04 to delete the associated simulation visits.
   */
     -- Get all the visits associated
  OPEN get_simulation_visits_cur(l_simulation_plan_id);
  LOOP
     FETCH get_simulation_visits_cur INTO l_visit_id;
     EXIT WHEN get_simulation_visits_cur%NOTFOUND;
     IF l_visit_id IS NOT NULL THEN
        Remove_Visits_FR_Plan (
            p_api_version      => p_api_version,
            p_init_msg_list    => FND_API.g_false,--p_init_msg_list,
            p_commit           => FND_API.g_false, --p_commit,
            p_validation_level => p_validation_level,
            p_module_type      => null,
            p_visit_id         => l_visit_id,
            p_plan_id          => null,
            p_v_ovn            => null,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data);

       -- Check Error Message stack.
       IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
    l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
    END IF; -- If Visit not null
  END LOOP;
  CLOSE get_simulation_visits_cur;

   --Check for object version number
   IF l_object_version_number <> p_simulation_plan_rec.object_version_number
   THEN
       FND_MESSAGE.set_name('AHL', 'AHL_LTP_RECORD_CHANGED');
       FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
   END IF;
   -------------------Call Table handler generated procedure------------
 AHL_SIMULATION_PLANS_PKG.DELETE_ROW (
         X_SIMULATION_PLAN_ID => l_simulation_plan_id
     );
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
   Ahl_Debug_Pub.debug( 'End of private api Delete Simulation plan','+SMPLN+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_simulation_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Delete Simulation plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_simulation_plan;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Delete Simulation plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN OTHERS THEN
    ROLLBACK TO delete_simulation_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PVT',
                            p_procedure_name  =>  'DELETE_SIMULATION_PLAN',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Delete Simulation plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
END Delete_Simulation_plan;


--------------------------------------------------------------------
-- PROCEDURE
--    Copy_Visits_To_Plan
--
-- PURPOSE
--    Copy Visits from primary plan to  Simulation Plan and one simulation plan
--    to another
--
--
-- PARAMETERS
-- p_visit_rec     Record representing AHL_VISITS_VL
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Copy_Visits_To_Plan (
   p_api_version      IN            NUMBER,
   p_init_msg_list    IN            VARCHAR2  := FND_API.g_false,
   p_commit           IN            VARCHAR2  := FND_API.g_false,
   p_validation_level IN            NUMBER    := FND_API.g_valid_level_full,
   p_module_type      IN            VARCHAR2  := 'JSP',
   p_visit_id         IN            NUMBER   ,
   p_visit_number     IN            NUMBER   ,
   p_plan_id          IN            NUMBER,
   p_v_ovn            IN            NUMBER,
   p_p_ovn            IN            NUMBER,
   x_visit_id            OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2 )
IS
 --

-- yazhou 20-Jul-2006 starts
-- bug fix#5387780
-- Should allow only primary visits in the current OU to be copied

 CURSOR get_visit_id_cur (c_visit_number IN NUMBER)
  IS
   SELECT visit_id,asso_primary_visit_id
    FROM ahl_visits_vl
    WHERE visit_number = c_visit_number
      AND status_code ='PLANNING'
      AND (ORGANIZATION_ID is NULL OR ORGANIZATION_ID IN ( SELECT organization_id
                                      FROM org_organization_definitions
                                      WHERE operating_unit = mo_global.get_current_org_id() ));

-- yazhou 20-Jul-2006 starts

 --
 CURSOR get_visit_num_cur (c_visit_id IN NUMBER)
  IS
   SELECT visit_id,asso_primary_visit_id
    FROM ahl_visits_vl
    WHERE visit_id = c_visit_id;
 --

 CURSOR visit_detail_cur(c_visit_id IN NUMBER)
 IS
 SELECT VISIT_ID,
        VISIT_NAME,
        ORGANIZATION_ID,
        DEPARTMENT_ID,
        STATUS_CODE,
        START_DATE_TIME,
        VISIT_TYPE_CODE,
        SIMULATION_PLAN_ID,
        ITEM_INSTANCE_ID,
        INVENTORY_ITEM_ID,
        ASSO_PRIMARY_VISIT_ID,
        SIMULATION_DELETE_FLAG,
        TEMPLATE_FLAG,
        OUT_OF_SYNC_FLAG,
        PROJECT_FLAG,
        ITEM_ORGANIZATION_ID,
        INV_LOCATOR_ID,  --Added by sowsubra
        PROJECT_ID,
        VISIT_NUMBER,
        DESCRIPTION,
        SERVICE_REQUEST_ID,
        SPACE_CATEGORY_CODE,
        SCHEDULE_DESIGNATOR,
        CLOSE_DATE_TIME,
        PRICE_LIST_ID,
        ESTIMATED_PRICE,
        ACTUAL_PRICE,
        OUTSIDE_PARTY_FLAG,
        ANY_TASK_CHG_FLAG,
        UNIT_SCHEDULE_ID,
        OBJECT_VERSION_NUMBER,
        PRIORITY_CODE,
        PROJECT_TEMPLATE_ID,
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
  FROM AHL_VISITS_VL
  WHERE visit_id = c_visit_id;
   -- Check for one visit can be copied into simulation plan
   CURSOR check_visit_exist_cur (c_plan_id IN NUMBER,
                                 c_visit_id IN NUMBER,
                                 c_asso_visit_id IN NUMBER)
   IS
   SELECT asso_primary_visit_id
      FROM AHL_VISITS_VL
    WHERE simulation_plan_id = c_plan_id
      AND (asso_primary_visit_id = c_visit_id
         OR NVL(asso_primary_visit_id, 0) = c_asso_visit_id);
  --
  CURSOR get_visit_task_cur
                  (c_visit_id IN NUMBER)
     IS
   SELECT VISIT_TASK_ID,
          VISIT_TASK_NUMBER,
          OBJECT_VERSION_NUMBER,
          VISIT_ID,
          PROJECT_TASK_ID,
          COST_PARENT_ID,
          MR_ROUTE_ID,
          MR_ID,
          DURATION,
          UNIT_EFFECTIVITY_ID,
          VISIT_TASK_NAME,
          DESCRIPTION,
          START_FROM_HOUR,
          INVENTORY_ITEM_ID,
          ITEM_ORGANIZATION_ID,
          INSTANCE_ID,
          PRIMARY_VISIT_TASK_ID,
          SUMMARY_TASK_FLAG,
          ORIGINATING_TASK_ID,
          SERVICE_REQUEST_ID,
          TASK_TYPE_CODE,
          DEPARTMENT_ID,
          PRICE_LIST_ID,
          STATUS_CODE,
          ACTUAL_COST,
          ESTIMATED_PRICE,
          ACTUAL_PRICE,
          STAGE_ID,
          START_DATE_TIME,
          END_DATE_TIME,
          -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Fetch past dates too
          PAST_TASK_START_DATE,
          PAST_TASK_END_DATE,
          QUANTITY, -- Added by rnahata for Issue 105
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
       FROM AHL_VISIT_TASKS_VL
     WHERE visit_id = c_visit_id
  AND STATUS_CODE <> 'DELETED';
 --
 CURSOR Get_space_Assign_cur (c_visit_id IN NUMBER) IS
  SELECT space_id,space_assignment_id
  FROM ahl_space_assignments
  WHERE visit_id = c_visit_id;

--Added by mpothuku on 12/27/04

 -- To find the coresponding task id in the new visit
 CURSOR c_new_task_ID(x_visit_task_id IN NUMBER, x_new_visit_id IN NUMBER) IS
  SELECT b.VISIT_TASK_ID
  FROM AHL_VISIT_TASKS_B a, AHL_VISIT_TASKS_B b
  WHERE a.visit_task_id = x_visit_task_id
   AND a.visit_task_number = b.visit_task_number
   AND b.visit_id = x_new_visit_id;

 -- To find task link related information for a visit
 CURSOR c_visit_task_links(x_visit_id IN NUMBER) IS
  SELECT VISIT_TASK_ID ,
         PARENT_TASK_ID,
         --SECURITY_GROUP_ID,
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
  FROM AHL_TASK_LINKS
  WHERE visit_task_id in (SELECT VISIT_TASK_ID
                          FROM AHL_VISIT_TASKS_B
                          WHERE visit_id = x_visit_id);

--To get the stages from a visit
CURSOR Get_stages_cur(c_visit_id IN NUMBER) IS
 SELECT STAGE_ID,
        STAGE_NUM,
        VISIT_ID,
        DURATION,
        OBJECT_VERSION_NUMBER,
        STAGE_NAME,
        --SECURITY_GROUP_ID,
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
 FROM ahl_vwp_stages_vl s
 WHERE visit_id = c_visit_id
 ORDER BY stage_num;

-- Added by mpothuku on 01/20/05 To find if this Unit has been planned in other visits already
CURSOR chk_unit_effectivities (c_unit_id IN NUMBER, c_plan_id IN NUMBER,c_visit_id IN NUMBER) IS
 SELECT VISIT_NUMBER,ASSO_PRIMARY_VISIT_ID FROM AHL_VISITS_B WHERE
 VISIT_ID IN (SELECT DISTINCT VISIT_ID FROM AHL_VISIT_TASKS_B WHERE
 Unit_Effectivity_Id = c_unit_id)
 --The following condition is necessary since the summary task may already have been
 --added to the current visit which will have the same UE as the planned task
 and visit_id <> c_visit_id
 and simulation_plan_id = c_plan_id
 and status_code not in ('CANCELLED','DELETED');

/*
CURSOR c_ue_details(c_unit_id IN NUMBER) IS
 select ue.title ue_title, ue.part_number, ue.serial_number, MR.title mr_title from ahl_unit_effectivities_v ue,ahl_mr_headers_v MR where MR.mr_header_id = ue.mr_header_id
 and ue.unit_effectivity_id = c_unit_id;
*/

/*
   AnRaj: Added for fixing the performance issues logged in bug#:4919576
*/

CURSOR c_ue_mr_sr_id(c_unit_id IN NUMBER) IS
   select   ue.mr_header_id, ue.cs_incident_id,ue.csi_item_instance_id
   from     ahl_unit_effectivities_b ue
   where    ue.unit_effectivity_id = c_unit_id;
ue_mr_sr_rec      c_ue_mr_sr_id%ROWTYPE;

CURSOR c_ue_mr_details(c_mr_header_id IN NUMBER,c_item_instance_id IN NUMBER) IS
   SELECT   mr.title ue_title,
            mtl.concatenated_segments part_number,
            csi.serial_number serial_number,
            mr.title mr_title
   FROM     ahl_mr_headers_vl mr,
            mtl_system_items_kfv mtl,
            csi_item_instances csi
   WHERE    mr.mr_header_id = c_mr_header_id
   AND      csi.instance_id = c_item_instance_id
   AND      csi.inventory_item_id = mtl.inventory_item_id
   AND      csi.inv_master_organization_id = mtl.organization_id ;
ue_mr_details_rec      c_ue_mr_details%ROWTYPE;

CURSOR c_ue_sr_details(cs_incident_id IN NUMBER,c_item_instance_id IN NUMBER) IS
   SELECT   (cit.name || '-' || cs.incident_number) ue_title,
            mtl.concatenated_segments part_number,
            csi.serial_number serial_number,
            null mr_title
   FROM     cs_incident_types_vl cit,
            cs_incidents_all_b cs,
            mtl_system_items_kfv mtl,
            csi_item_instances csi
   WHERE    cs.incident_id = cs_incident_id
   AND      cit.incident_type_id = cs.incident_type_id
   AND      csi.instance_id   = c_item_instance_id
   AND      csi.inventory_item_id = mtl.inventory_item_id
   AND      csi.inv_master_organization_id = mtl.organization_id ;
ue_sr_details_rec    c_ue_sr_details%ROWTYPE;
/*
   AnRaj: End of Fix bug#:4919576
*/


CURSOR get_visit_number(c_visit_id IN NUMBER)
  IS
   SELECT visit_number
    FROM ahl_visits_vl
    WHERE visit_id = c_visit_id;

CURSOR check_primary_visit(c_visit_id IN NUMBER) IS
 SELECT ahlv.visit_id from ahl_visits_b ahlv, ahl_simulation_plans_b ahlsp
 where ahlv.visit_id = c_visit_id
 and ahlv.simulation_plan_id = ahlsp.simulation_plan_id
 and ahlsp.primary_plan_flag = 'Y';

CURSOR c_task(c_task_id IN NUMBER) IS
     SELECT *
      FROM   Ahl_Visit_tasks_vl
      WHERE  visit_task_id = c_task_id;

-- To find the coresponding Stage id in the new visit
CURSOR c_new_stage_id(c_old_stage_id IN NUMBER, c_new_visit_id IN NUMBER) IS
     SELECT NewStage.Stage_Id
     FROM ahl_vwp_stages_b OldStage, ahl_vwp_stages_b NewStage
     WHERE OldStage.Stage_Id = c_old_stage_id
       AND NewStage.visit_id = c_new_visit_id
          AND NewStage.Stage_Num = OldStage.Stage_Num;

--mpothuku End
  --
 l_api_name        CONSTANT VARCHAR2(30) := 'COPY_VISITS_TO_PLAN';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_full_name       CONSTANT VARCHAR2(60)  := G_PKG_NAME || '.' || l_api_name;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_dummy                    NUMBER;
 l_rowid                    VARCHAR2(30);
 l_simulation_plan_id       NUMBER;
 l_visit_id                 NUMBER;
 l_primary_visit_id         NUMBER;
 l_new_visit_id             NUMBER;
 l_visit_number             NUMBER;
 x_visit_number             NUMBER;
 l_plan_ovn_number          NUMBER;
 l_plan_flag                VARCHAR2(1);
 l_meaning                  VARCHAR2(80);
 l_dup_id                   NUMBER;
 l_visit_detail_rec         visit_detail_cur%ROWTYPE;
 l_visit_rec                AHL_VWP_VISITS_PVT.visit_rec_type;
 l_visit_task_rec           get_visit_task_cur%ROWTYPE;
 l_visit_task_id            NUMBER;
 l_space_id                 NUMBER;
 l_space_assignment_id      NUMBER;
 l_pvisit_id                NUMBER;
 l_new_parent_task_id       NUMBER;
 l_new_task_id              NUMBER;
 l_stage_id                 NUMBER;
 l_stage_rec                Get_stages_cur%ROWTYPE;
 --l_ue_details_rec         c_ue_details%ROWTYPE;
 l_primary_visit_number     NUMBER;
 l_asso_prim_visit_id       NUMBER;
 l_asso_prim_visit_number   NUMBER;
 l_primary_visit_task_id    NUMBER;
 l_primary_visit_check      NUMBER;
 l_originating_task_id      NUMBER;
 l_cost_parent_id           NUMBER;
 c_task_rec                 c_task%ROWTYPE;
 l_task_link_rec            c_visit_task_links%ROWTYPE;

 --
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT copy_visits_to_plan;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   -- Debug info.
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pvt.Copy Visits to Plan','+SMPNL+');
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
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'visit_id'||p_visit_id);
    AHL_DEBUG_PUB.debug( 'visit_number'||p_visit_number);
   END IF;
   ---------------------start API Body------------------------------------
   --
    IF  (p_visit_number IS NOT NULL AND
        p_visit_number <> FND_API.G_MISS_NUM) THEN
        --
        OPEN get_visit_id_cur(p_visit_number);
        FETCH get_visit_id_cur INTO  l_pvisit_id, l_primary_visit_id;
       IF get_visit_id_cur%NOTFOUND  THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_INVALID_VISIT_NUMBER');
        Fnd_Msg_Pub.ADD;
         CLOSE get_visit_id_cur;
        RAISE Fnd_Api.G_EXC_ERROR;
        --
       END IF;
        CLOSE get_visit_id_cur;
      END IF;
   IF G_DEBUG='Y' THEN
     --
    AHL_DEBUG_PUB.debug( 'visit_id'||l_pvisit_id);
    AHL_DEBUG_PUB.debug( 'visit_number'||l_primary_visit_id);
    END IF;
     --
     IF  (p_visit_id IS NOT NULL AND
          p_visit_id <> FND_API.G_MISS_NUM) THEN
        OPEN get_visit_num_cur(p_visit_id);
        FETCH get_visit_num_cur INTO  l_pvisit_id, l_primary_visit_id;
        IF get_visit_num_cur%NOTFOUND THEN
         Fnd_message.SET_NAME('AHL','AHL_LTP_INVALID_VISIT_NUMBER');
         Fnd_Msg_Pub.ADD;
         CLOSE get_visit_num_cur;
         RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
         CLOSE get_visit_num_cur;
     END IF;
     --
   --Get simulation plan id
     IF (p_plan_id IS NOT NULL AND
         p_plan_id <> FND_API.G_MISS_NUM) THEN
         SELECT simulation_plan_id,primary_plan_flag
                 INTO l_simulation_plan_id, l_plan_flag
            FROM AHL_SIMULATION_PLANS_VL
           WHERE simulation_plan_id = p_plan_id;
     ELSE
        Fnd_message.SET_NAME('AHL','AHL_LTP_INVALID_SIMUL_NAME');
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
    --Check for copying to priamry plan
    IF l_plan_flag = 'Y' THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_NO_COPY_PRIM_PLAN');
        Fnd_Msg_Pub.ADD;
       RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
    --
    OPEN visit_detail_cur(l_pvisit_id);
    FETCH visit_detail_cur INTO l_visit_detail_rec;
    CLOSE visit_detail_cur;
    --
    --Check for duplicate records
    IF l_visit_detail_rec.visit_id = l_pvisit_id THEN
      IF l_visit_detail_rec.simulation_plan_id = p_plan_id THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_RECORD_EXISTS');
        Fnd_Msg_Pub.ADD;
       RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
    END IF;

  --Check for Object version number
 IF (p_v_ovn IS NOT NULL AND p_v_ovn <> FND_API.G_MISS_NUM )
 THEN
   IF p_v_ovn <> l_visit_detail_rec.object_version_number THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_INVALID_VISIT_RECORD');
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END IF;
    --
    SELECT object_version_number INTO l_plan_ovn_number FROM
       AHL_SIMULATION_PLANS_VL WHERE simulation_plan_id = p_plan_id;
   --Check for plan object version number
   IF (p_p_ovn IS NOT NULL AND p_p_ovn <> FND_API.G_MISS_NUM )
   THEN
     IF p_p_ovn <> l_plan_ovn_number THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_INVALID_PLAN_RECORD');
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
     END IF;
   END IF;
   --Check for duplicate records
    OPEN check_visit_exist_cur(p_plan_id,l_pvisit_id,l_primary_visit_id);
    FETCH check_visit_exist_cur INTO l_dup_id;
    CLOSE check_visit_exist_cur;
     --
    IF l_dup_id IS NOT NULL THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_VISIT_NUMBER_EXISTS');
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
     END IF;
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'plan_id'||p_plan_id);
    AHL_DEBUG_PUB.debug( 'visit_id'||l_pvisit_id);
    AHL_DEBUG_PUB.debug( 'asso visit id'||l_primary_visit_id);
   END IF;

   --Change by mpothuku End

 IF G_DEBUG='Y' THEN
  AHL_DEBUG_PUB.debug( 'visit_type_code'||l_visit_detail_rec.visit_type_code);
  AHL_DEBUG_PUB.debug( 'inventory_id'||l_visit_detail_rec.inventory_item_id);
 END IF;
 --Get visit id
 SELECT Ahl_Visits_B_S.NEXTVAL  INTO l_visit_id
 FROM   dual;
 --Get visit number
 SELECT MAX(visit_number) INTO l_visit_number
 FROM Ahl_Visits_B;
      --
 ahl_visits_pkg.Insert_Row
 (
  X_ROWID                 => l_rowid,
  X_VISIT_ID              => l_visit_id,
  X_VISIT_NUMBER          => l_visit_number+1,
  X_VISIT_TYPE_CODE       => l_visit_detail_rec.visit_type_code,
  X_SIMULATION_PLAN_ID    => p_plan_id,
  X_ITEM_INSTANCE_ID      => l_visit_detail_rec.item_instance_id,
  X_ITEM_ORGANIZATION_ID  => l_visit_detail_rec.item_organization_id,
  X_INVENTORY_ITEM_ID     => l_visit_detail_rec.inventory_item_id,
  X_ASSO_PRIMARY_VISIT_ID  => nvl(l_visit_detail_rec.asso_primary_visit_id,l_pvisit_id),
  X_SIMULATION_DELETE_FLAG => NVL(l_visit_detail_rec.simulation_delete_flag,'N'),
  X_TEMPLATE_FLAG         => l_visit_detail_rec.template_flag,
  X_OUT_OF_SYNC_FLAG      => l_visit_detail_rec.out_of_sync_flag,
  X_PROJECT_FLAG          => l_visit_detail_rec.project_flag,
  X_PROJECT_ID            => l_visit_detail_rec.project_id,
  X_SERVICE_REQUEST_ID    => l_visit_detail_rec.service_request_id,
  X_SPACE_CATEGORY_CODE   => l_visit_detail_rec.space_category_code,
  X_SCHEDULE_DESIGNATOR   => l_visit_detail_rec.schedule_designator,
  X_ATTRIBUTE_CATEGORY    => l_visit_detail_rec.attribute_category,
  X_ATTRIBUTE1            => l_visit_detail_rec.attribute1,
  X_ATTRIBUTE2            => l_visit_detail_rec.attribute2,
  X_ATTRIBUTE3            => l_visit_detail_rec.attribute3,
  X_ATTRIBUTE4            => l_visit_detail_rec.attribute4,
  X_ATTRIBUTE5            => l_visit_detail_rec.attribute5,
  X_ATTRIBUTE6            => l_visit_detail_rec.attribute6,
  X_ATTRIBUTE7            => l_visit_detail_rec.attribute7,
  X_ATTRIBUTE8            => l_visit_detail_rec.attribute8,
  X_ATTRIBUTE9            => l_visit_detail_rec.attribute9,
  X_ATTRIBUTE10           => l_visit_detail_rec.attribute10,
  X_ATTRIBUTE11           => l_visit_detail_rec.attribute11,
  X_ATTRIBUTE12           => l_visit_detail_rec.attribute12,
  X_ATTRIBUTE13           => l_visit_detail_rec.attribute13,
  X_ATTRIBUTE14           => l_visit_detail_rec.attribute14,
  X_ATTRIBUTE15           => l_visit_detail_rec.attribute15,
  X_OBJECT_VERSION_NUMBER => 1,
  X_ORGANIZATION_ID       => l_visit_detail_rec.organization_id,
  X_DEPARTMENT_ID         => l_visit_detail_rec.department_id,
  X_STATUS_CODE           => l_visit_detail_rec.status_code,
  X_START_DATE_TIME       => l_visit_detail_rec.start_date_time,
  X_CLOSE_DATE_TIME       => l_visit_detail_rec.close_date_time,
  X_VISIT_NAME            => l_visit_detail_rec.visit_name,--'COPY FROM PLAN',
  X_DESCRIPTION           => l_visit_detail_rec.description,
  X_PRICE_LIST_ID         => l_visit_detail_rec.price_list_id,
  X_ESTIMATED_PRICE       => l_visit_detail_rec.estimated_price,
  X_ACTUAL_PRICE          => l_visit_detail_rec.actual_price,
  X_OUTSIDE_PARTY_FLAG    => l_visit_detail_rec.outside_party_flag,
  X_ANY_TASK_CHG_FLAG     => l_visit_detail_rec.any_task_chg_flag,
  X_PRIORITY_CODE      => l_visit_detail_rec.priority_code,
  X_PROJECT_TEMPLATE_ID   => l_visit_detail_rec.project_template_id,
  X_UNIT_SCHEDULE_ID      => l_visit_detail_rec.unit_schedule_id,
  X_INV_LOCATOR_ID        => l_visit_detail_rec.inv_locator_id, /*Added by sowsubra*/
  X_CREATION_DATE         => SYSDATE,
  X_CREATED_BY            => Fnd_Global.USER_ID,
  X_LAST_UPDATE_DATE      => SYSDATE,
  X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
  X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID
 );
 --Assign Out parameter
 x_visit_id := l_visit_id;

    --Added by mpothuku to copy Visit Stages on 01/13/04
 OPEN Get_stages_cur(l_pvisit_id);
 LOOP
  FETCH Get_stages_cur INTO l_stage_rec;
  EXIT WHEN Get_stages_cur%NOTFOUND;
  IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'inside loop stage num:'||l_stage_rec.stage_num);
  END IF;
        -- Get visit task id
    /* Have to Confirm with the Stages API */
    SELECT Ahl_vwp_stages_B_S.NEXTVAL into l_stage_id
    FROM   dual;
        --
    IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'visit call insert stage:'||l_stage_id);
    END IF;
     /* Copy the details in the Simulation Visit */
        -- Invoke the table handler to create a record
    Ahl_VWP_Stages_Pkg.Insert_Row (
   X_ROWID                   => l_rowid,
   X_VISIT_ID                => l_visit_id,
   X_STAGE_ID                => l_stage_id,
   X_STAGE_NUM               => l_stage_rec.Stage_Num,
   X_STAGE_NAME              => l_stage_rec.Stage_Name,
   X_DURATION                => l_stage_rec.Duration,
   X_OBJECT_VERSION_NUMBER   => 1,
   X_ATTRIBUTE_CATEGORY      => l_stage_rec.ATTRIBUTE_CATEGORY,
   X_ATTRIBUTE1              => l_stage_rec.ATTRIBUTE1,
   X_ATTRIBUTE2              => l_stage_rec.ATTRIBUTE2,
   X_ATTRIBUTE3              => l_stage_rec.ATTRIBUTE3,
   X_ATTRIBUTE4              => l_stage_rec.ATTRIBUTE4,
   X_ATTRIBUTE5              => l_stage_rec.ATTRIBUTE5,
   X_ATTRIBUTE6              => l_stage_rec.ATTRIBUTE6,
   X_ATTRIBUTE7              => l_stage_rec.ATTRIBUTE7,
   X_ATTRIBUTE8              => l_stage_rec.ATTRIBUTE8,
   X_ATTRIBUTE9              => l_stage_rec.ATTRIBUTE9 ,
   X_ATTRIBUTE10             => l_stage_rec.ATTRIBUTE10,
   X_ATTRIBUTE11             => l_stage_rec.ATTRIBUTE11,
   X_ATTRIBUTE12             => l_stage_rec.ATTRIBUTE12,
   X_ATTRIBUTE13             => l_stage_rec.ATTRIBUTE13,
   X_ATTRIBUTE14             => l_stage_rec.ATTRIBUTE14,
   X_ATTRIBUTE15             => l_stage_rec.ATTRIBUTE15,
   X_CREATION_DATE           => SYSDATE,
   X_CREATED_BY              => Fnd_Global.USER_ID,
   X_LAST_UPDATE_DATE        => SYSDATE,
   X_LAST_UPDATED_BY         => Fnd_Global.USER_ID,
   X_LAST_UPDATE_LOGIN       => Fnd_Global.LOGIN_ID);

  IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.Debug( l_full_name ||': Visit ID =' || l_visit_id);
   AHL_DEBUG_PUB.Debug( l_full_name ||': Stage Number =' ||l_stage_rec.Stage_Num);
  END IF;
   END LOOP;
   CLOSE Get_stages_cur;
   --mpothuku End

   /* To find if the visit belongs to the primary plan/simulation plan */
    l_primary_visit_check := null;
 OPEN check_primary_visit(l_pvisit_id);
 FETCH check_primary_visit into l_primary_visit_check;
 CLOSE check_primary_visit;

   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'visit id before tasks:'||l_pvisit_id);
   END IF;
  --Copy the corresponding tasks
 OPEN get_visit_task_cur(l_pvisit_id);
 LOOP
  IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'inside loop task num:'||l_visit_task_rec.visit_task_number);
  END IF;
  FETCH get_visit_task_cur INTO l_visit_task_rec;
  EXIT WHEN get_visit_task_cur%NOTFOUND;
  -- Get visit task id
  SELECT Ahl_Visit_Tasks_B_S.NEXTVAL INTO
  l_visit_task_id   FROM   dual;
  --
  IF G_DEBUG='Y' THEN
  AHL_DEBUG_PUB.debug( 'visit call insert task:'||l_visit_task_id);
  END IF;

  /* Added by mpothuku on 01/20/05 to Check if the UE is associated with any of the visits in the plan */
  IF(l_visit_task_rec.task_type_code = 'PLANNED' and l_visit_task_rec.unit_effectivity_id IS NOT NULL) THEN

   OPEN chk_unit_effectivities (l_visit_task_rec.unit_effectivity_id,l_simulation_plan_id,l_visit_id);
   FETCH chk_unit_effectivities INTO l_visit_number,l_asso_prim_visit_id;
     IF (chk_unit_effectivities%FOUND) THEN
    CLOSE chk_unit_effectivities;

    -- ERROR MESSAGE

    /*
       AnRaj: Added for fixing the performance issues logged in bug#:4919576
       Split the query to select MR and SR details seperately
    */
    /*
    OPEN c_ue_details (l_visit_task_rec.unit_effectivity_id);
    FETCH c_ue_details INTO l_ue_details_rec;
    CLOSE c_ue_details;
    */
    -- Get the UE's SR and MR details
    OPEN c_ue_mr_sr_id(l_visit_task_rec.unit_effectivity_id);
    FETCH c_ue_mr_sr_id INTO ue_mr_sr_rec;
    CLOSE c_ue_mr_sr_id;

    -- If the UE  corresponds to a SR
    IF ue_mr_sr_rec.cs_incident_id IS NOT NULL THEN
       OPEN c_ue_sr_details(ue_mr_sr_rec.cs_incident_id,ue_mr_sr_rec.csi_item_instance_id);
       FETCH c_ue_sr_details INTO ue_sr_details_rec;
       CLOSE c_ue_sr_details;

       Fnd_Message.SET_NAME('AHL','AHL_LTP_SIM_VISIT_UNIT_FOUND');
       Fnd_Message.SET_TOKEN('UE_TITLE', ue_sr_details_rec.ue_title);
       Fnd_Message.SET_TOKEN('ITEM_NUMBER', ue_sr_details_rec.part_number);
       Fnd_Message.SET_TOKEN('SERIAL_NUMBER', ue_sr_details_rec.serial_number);
       Fnd_Message.SET_TOKEN('MR_TITLE', ue_sr_details_rec.mr_title);
    ELSE
       -- Else if UE corresponds to MR
       OPEN  c_ue_mr_details(ue_mr_sr_rec.mr_header_id,ue_mr_sr_rec.csi_item_instance_id);
       FETCH c_ue_mr_details INTO ue_mr_details_rec;
       CLOSE c_ue_mr_details;

       Fnd_Message.SET_NAME('AHL','AHL_LTP_SIM_VISIT_UNIT_FOUND');
       Fnd_Message.SET_TOKEN('UE_TITLE', ue_mr_details_rec.ue_title);
       Fnd_Message.SET_TOKEN('ITEM_NUMBER', ue_mr_details_rec.part_number);
       Fnd_Message.SET_TOKEN('SERIAL_NUMBER', ue_mr_details_rec.serial_number);
       Fnd_Message.SET_TOKEN('MR_TITLE', ue_mr_details_rec.mr_title);
    END IF;

    OPEN get_visit_number (l_pvisit_id);
    FETCH get_visit_number INTO l_primary_visit_number;
    CLOSE get_visit_number;

    OPEN get_visit_number (l_asso_prim_visit_id);
    FETCH get_visit_number INTO l_asso_prim_visit_number;
    CLOSE get_visit_number;


    x_return_status := Fnd_Api.g_ret_sts_error;

    /*
    Fnd_Message.SET_NAME('AHL','AHL_LTP_SIM_VISIT_UNIT_FOUND');
    Fnd_Message.SET_TOKEN('UE_TITLE', l_ue_details_rec.ue_title);
    Fnd_Message.SET_TOKEN('ITEM_NUMBER', l_ue_details_rec.part_number);
    Fnd_Message.SET_TOKEN('SERIAL_NUMBER', l_ue_details_rec.serial_number);
    Fnd_Message.SET_TOKEN('MR_TITLE', l_ue_details_rec.mr_title);
    */
    /*
       AnRaj: End of Fix bug#:4919576
    */


    Fnd_Message.SET_TOKEN('VISIT1', l_primary_visit_number);
    Fnd_Message.SET_TOKEN('VISIT2', l_asso_prim_visit_number);
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
     ELSE
     CLOSE chk_unit_effectivities;
     END IF;
  END IF;

        -- Call to create task
    IF(l_primary_visit_check IS NOT NULL) THEN
      l_primary_visit_task_id := l_visit_task_rec.visit_task_id;
    ELSE
      l_primary_visit_task_id := l_visit_task_rec.primary_visit_task_id;
    END IF;
        Ahl_Visit_Tasks_Pkg.INSERT_ROW (
        X_ROWID                 => l_rowid,
        X_VISIT_TASK_ID         => l_visit_task_id,
        X_VISIT_TASK_NUMBER     => l_visit_task_rec.visit_task_number,
        X_OBJECT_VERSION_NUMBER => 1,
        X_VISIT_ID              => l_visit_id,
        X_PROJECT_TASK_ID       => l_visit_task_rec.project_task_id,
        X_COST_PARENT_ID        => null,--l_visit_task_rec.cost_parent_id,
        X_MR_ROUTE_ID           => l_visit_task_rec.mr_route_id,
        X_MR_ID                 => l_visit_task_rec.mr_id,
        X_DURATION              => l_visit_task_rec.duration,
        X_UNIT_EFFECTIVITY_ID   => l_visit_task_rec.unit_effectivity_id,
        X_START_FROM_HOUR       => l_visit_task_rec.start_from_hour,
        X_INVENTORY_ITEM_ID     => l_visit_task_rec.inventory_item_id,
        X_ITEM_ORGANIZATION_ID  => l_visit_task_rec.item_organization_id,
        X_INSTANCE_ID           => l_visit_task_rec.instance_id,
        X_PRIMARY_VISIT_TASK_ID => l_primary_visit_task_id,
        X_SUMMARY_TASK_FLAG     => l_visit_task_rec.summary_task_flag,
        X_ORIGINATING_TASK_ID   => null,--l_visit_task_rec.originating_task_id,
        X_SERVICE_REQUEST_ID    => l_visit_task_rec.service_request_id,
        X_DEPARTMENT_ID         => l_visit_task_rec.department_id,
        X_TASK_TYPE_CODE        => l_visit_task_rec.task_type_code,
        X_PRICE_LIST_ID         => l_visit_task_rec.price_list_id,
        X_STATUS_CODE           => l_visit_task_rec.status_code,
        X_ESTIMATED_PRICE       => l_visit_task_rec.estimated_price,
        X_ACTUAL_PRICE          => l_visit_task_rec.actual_price,
        X_ACTUAL_COST           => l_visit_task_rec.actual_cost,
        X_STAGE_ID              => null,--l_visit_task_rec.stage_id,
      -- Added cxcheng POST11510-- No Calculation Need for Sim---------
        X_START_DATE_TIME       => l_visit_task_rec.start_date_time,
        X_END_DATE_TIME         => l_visit_task_rec.end_date_time,
        -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Added two new attributes for past dates
        X_PAST_TASK_START_DATE  => l_visit_task_rec.PAST_TASK_START_DATE,
        X_PAST_TASK_END_DATE    => l_visit_task_rec.PAST_TASK_END_DATE,
        X_ATTRIBUTE_CATEGORY    => l_visit_task_rec.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1            => l_visit_task_rec.ATTRIBUTE1,
        X_ATTRIBUTE2            => l_visit_task_rec.ATTRIBUTE2,
        X_ATTRIBUTE3            => l_visit_task_rec.ATTRIBUTE3,
        X_ATTRIBUTE4            => l_visit_task_rec.ATTRIBUTE4,
        X_ATTRIBUTE5            => l_visit_task_rec.ATTRIBUTE5,
        X_ATTRIBUTE6            => l_visit_task_rec.ATTRIBUTE6,
        X_ATTRIBUTE7            => l_visit_task_rec.ATTRIBUTE7,
        X_ATTRIBUTE8            => l_visit_task_rec.ATTRIBUTE8,
        X_ATTRIBUTE9            => l_visit_task_rec.ATTRIBUTE9,
        X_ATTRIBUTE10           => l_visit_task_rec.ATTRIBUTE10,
        X_ATTRIBUTE11           => l_visit_task_rec.ATTRIBUTE11,
        X_ATTRIBUTE12           => l_visit_task_rec.ATTRIBUTE12,
        X_ATTRIBUTE13           => l_visit_task_rec.ATTRIBUTE13,
        X_ATTRIBUTE14           => l_visit_task_rec.ATTRIBUTE14,
        X_ATTRIBUTE15           => l_visit_task_rec.ATTRIBUTE15,
        X_VISIT_TASK_NAME       => l_visit_task_rec.visit_task_name,
        X_DESCRIPTION           => l_visit_task_rec.description,
        X_QUANTITY              => l_visit_task_rec.quantity, -- Added by rnahata for Issue 105
        X_CREATION_DATE         => SYSDATE,
        X_CREATED_BY            => Fnd_Global.USER_ID,
        X_LAST_UPDATE_DATE      => SYSDATE,
        X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
        X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID );

 END LOOP;
    CLOSE get_visit_task_cur;

 --Get the tasks of the Source Visit
 OPEN get_visit_task_cur(l_pvisit_id);
 LOOP
 FETCH get_visit_task_cur INTO l_visit_task_rec;
 EXIT WHEN get_visit_task_cur%NOTFOUND;
 l_originating_task_id := null;
 l_cost_parent_id := null;
 l_stage_id := null;

 IF(l_visit_task_rec.originating_task_id is not null OR l_visit_task_rec.cost_parent_id is not null
  OR l_visit_task_rec.stage_id is not null) THEN
  --Get the corresponding task record from the Simulation visit to update.
  OPEN c_new_task_ID(l_visit_task_rec.visit_task_id,l_visit_id);
  FETCH c_new_task_ID INTO l_new_task_id;
  CLOSE c_new_task_ID;

  IF(l_visit_task_rec.originating_task_id is not null) THEN
   OPEN c_new_task_ID(l_visit_task_rec.originating_task_id,l_visit_id);
   FETCH c_new_task_ID INTO l_originating_task_id;
   CLOSE c_new_task_ID;
  END IF;

  IF(l_visit_task_rec.cost_parent_id is not null) THEN
   OPEN c_new_task_ID(l_visit_task_rec.cost_parent_id,l_visit_id);
   FETCH c_new_task_ID INTO l_cost_parent_id;
   CLOSE c_new_task_ID;
  END IF;

  IF(l_visit_task_rec.stage_id is not null) THEN
   OPEN c_new_stage_id(l_visit_task_rec.stage_id,l_visit_id);
   FETCH c_new_stage_id INTO l_stage_id;
   CLOSE c_new_stage_id;
  END IF;

  UPDATE AHL_VISIT_TASKS_B SET
   cost_parent_id = l_cost_parent_id,
   originating_task_id = l_originating_task_id,
   stage_id = l_stage_id
  where visit_task_id = l_new_task_id;

 END IF;
 END LOOP;
 CLOSE get_visit_task_cur;
 -- Added by mpothuku on 12/27/04 to copy task links
    -- Copy task links from originating visit

    OPEN c_visit_task_links(l_pvisit_id);
 LOOP
  FETCH c_visit_task_links INTO l_task_link_rec;
  EXIT WHEN c_visit_task_links%NOTFOUND;

  -- Find corresponding task id in new visit
  OPEN c_new_task_ID(l_task_link_rec.visit_task_id,l_visit_id);
  FETCH c_new_task_ID INTO l_new_task_id;
  CLOSE c_new_task_ID;

  OPEN c_new_task_ID(l_task_link_rec.parent_task_id,l_visit_id);
  FETCH c_new_task_ID INTO l_new_parent_task_id;
  CLOSE c_new_task_ID;

          -- Create task link
  INSERT INTO AHL_TASK_LINKS
  (
   TASK_LINK_ID,
   OBJECT_VERSION_NUMBER,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_LOGIN,
   VISIT_TASK_ID,
   PARENT_TASK_ID,
   --SECURITY_GROUP_ID,
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
  )
  values
  (
   ahl_task_links_s.nextval,
   1,
   SYSDATE,
   Fnd_Global.USER_ID,
   SYSDATE,
   Fnd_Global.USER_ID,
   Fnd_Global.USER_ID,
   l_new_task_id,
   l_new_parent_task_id,
   --l_task_link_rec.SECURITY_GROUP_ID,
   l_task_link_rec.ATTRIBUTE_CATEGORY,
   l_task_link_rec.ATTRIBUTE1,
   l_task_link_rec.ATTRIBUTE2,
   l_task_link_rec.ATTRIBUTE3,
   l_task_link_rec.ATTRIBUTE4,
   l_task_link_rec.ATTRIBUTE5,
   l_task_link_rec.ATTRIBUTE6,
   l_task_link_rec.ATTRIBUTE7,
   l_task_link_rec.ATTRIBUTE8,
   l_task_link_rec.ATTRIBUTE9,
   l_task_link_rec.ATTRIBUTE10,
   l_task_link_rec.ATTRIBUTE11,
   l_task_link_rec.ATTRIBUTE12,
   l_task_link_rec.ATTRIBUTE13,
   l_task_link_rec.ATTRIBUTE14,
   l_task_link_rec.ATTRIBUTE15
  );
        END LOOP;
        CLOSE c_visit_task_links;
       --mpothuku End

       --Copy any space assignments
       OPEN Get_space_Assign_cur(l_pvisit_id);
       LOOP
       FETCH Get_space_Assign_cur INTO l_space_id,l_space_assignment_id;
       EXIT WHEN Get_space_Assign_cur%NOTFOUND;
       IF Get_space_Assign_cur%FOUND THEN
    --Create record in space assignments with new visit id
    --Get space assignment id
   SELECT AHL_SPACE_ASSIGNMENTS_S.NEXTVAL INTO l_space_assignment_id
    FROM   dual;
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
      l_space_id,
      l_visit_id,
      1,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      SYSDATE,
      Fnd_Global.user_id,
      SYSDATE,
      Fnd_Global.user_id,
      Fnd_Global.login_id
    );

       END IF;
       END LOOP;
       CLOSE Get_space_Assign_cur;

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
   Ahl_Debug_Pub.debug( 'End of private api Copy visits to plan','+SMPLN+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO copy_visits_to_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Copy Visits to plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO copy_visits_to_plan;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Copy Visits to plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

WHEN OTHERS THEN
    ROLLBACK TO copy_visits_to_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PVT',
                            p_procedure_name  =>  'COPY_VISITS_TO_PLAN',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Copy Visits to plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

END Copy_Visits_To_Plan;


--------------------------------------------------------------------
-- PROCEDURE
--    Remove_Visits_FR_Plan
--
-- PURPOSE
--    Remove  Visits from  Simulation Plan
--
--
-- PARAMETERS
-- p_visit_rec     Record representing AHL_VISITS_VL
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Remove_Visits_FR_Plan (
   p_api_version      IN            NUMBER,
   p_init_msg_list    IN            VARCHAR2 := FND_API.g_false,
   p_commit           IN            VARCHAR2 := FND_API.g_false,
   p_validation_level IN            NUMBER   := FND_API.g_valid_level_full,
   p_module_type      IN            VARCHAR2 := 'JSP',
   p_visit_id         IN            NUMBER,
   p_plan_id          IN            NUMBER,
   p_v_ovn            IN            NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
)
IS
 --
 CURSOR get_visit_task_cur (c_visit_id IN NUMBER)
  IS
   SELECT *
    FROM ahl_visit_tasks_vl
   WHERE visit_id = c_visit_id;
 --
 CURSOR Check_space_cur (c_visit_id IN NUMBER)
  IS
  SELECT space_assignment_id
    FROM ahl_space_assignments
   WHERE visit_id = c_visit_id;
 --
 -- Added by mpothuku on 12/27/04 to find any task links for a task
 CURSOR c_links (x_id IN NUMBER) IS
   SELECT COUNT(*) FROM Ahl_Task_Links L ,Ahl_Visit_Tasks_B T
   WHERE (T.VISIT_TASK_ID = L.VISIT_TASK_ID OR T.VISIT_TASK_ID = L.PARENT_TASK_ID)
   AND T.VISIT_TASK_ID = x_id;

--To check if the unplanned tasks UE is associated with any other visits other than itself before its deletion.
  CURSOR check_unplanned_ue_assoc(c_ue_id IN NUMBER, c_visit_id IN NUMBER) IS
 SELECT 'X' from ahl_visit_tasks_b where unit_effectivity_id = c_ue_id
   AND visit_id <> c_visit_id;

   CURSOR check_summary_task_unplanned(c_originating_task_id IN NUMBER) IS
 SELECT 'X' from ahl_visit_tasks_b where
     originating_task_id = c_originating_task_id and task_type_code = 'UNPLANNED';


 --
 l_api_name    CONSTANT VARCHAR2(30) := 'REMOVE_VISITS_FR_PLAN';
 l_api_version CONSTANT NUMBER       := 1.0;
 l_full_name   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

 l_msg_count            NUMBER;
 l_return_status        VARCHAR2(1);
 l_msg_data             VARCHAR2(2000);
 l_visit_task_id        NUMBER;
 l_space_assignment_id  NUMBER;
 l_count                NUMBER;
 l_planned_order_flag   VARCHAR2(1);
 l_task_rec             get_visit_task_cur%ROWTYPE;
 l_dummy                VARCHAR2(1);

 TYPE delete_unit_effectivity_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 l_delete_unit_effectivity_tbl delete_unit_effectivity_tbl;
 ue_count     NUMBER :=0 ;
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT remove_visits_fr_plan;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pvt.Remove Visits from Plan','+SMPNL+');
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
 --Remove tasks
 OPEN get_visit_task_cur(p_visit_id);
 LOOP
 FETCH get_visit_task_cur INTO l_task_rec;
 EXIT WHEN get_visit_task_cur%NOTFOUND;
 l_visit_task_id := l_task_rec.visit_task_id;

 /* Added by mpothuku on 12/28/04 to delete the links */
 -- If a task being deleted has associated Children Tasks, tasks that define it as a parent,
 -- the association must be removed.
 OPEN c_links (l_visit_task_id);
 FETCH c_links INTO l_count;
 IF l_count > 0 THEN
  DELETE Ahl_Task_Links
     WHERE VISIT_TASK_ID = l_visit_task_id
        OR PARENT_TASK_ID = l_visit_task_id;
 END IF;
 CLOSE c_links;

 /* Change by mpothuku on 02/03/05 to delete the unit effectivities for Unplanned tasks before removing the association */

 IF(l_task_rec.TASK_TYPE_CODE = 'SUMMARY' AND l_task_rec.mr_id is not null
    AND l_task_rec.originating_task_id is null) THEN
 -- Find out if the UE is associated with any other Active Visits
 -- Ideally if any are found they should be Simulation Visits only
  OPEN check_summary_task_unplanned(l_task_rec.visit_task_id);
  FETCH check_summary_task_unplanned into l_dummy;
  IF(check_summary_task_unplanned%FOUND) THEN
   CLOSE check_summary_task_unplanned;
   OPEN check_unplanned_ue_assoc(l_task_rec.UNIT_EFFECTIVITY_ID, l_task_rec.visit_id );
   FETCH check_unplanned_ue_assoc INTO l_dummy;
   IF (check_unplanned_ue_assoc%NOTFOUND) THEN
    CLOSE check_unplanned_ue_assoc;
    l_delete_unit_effectivity_tbl(ue_count) := l_task_rec.UNIT_EFFECTIVITY_ID;
    ue_count := ue_count + 1;
   ELSE
    CLOSE check_unplanned_ue_assoc;
   END IF;
  ELSE
   CLOSE check_summary_task_unplanned;
  END IF;
  END IF;

  AHL_VISIT_TASKS_PKG.DELETE_ROW (
         X_VISIT_TASK_ID => l_visit_task_id);

     END LOOP;
     CLOSE get_visit_task_cur;


  --Delete the unit effectivites also
  if(l_delete_unit_effectivity_tbl.count > 0) THEN
   for ue_count in 0..l_delete_unit_effectivity_tbl.count -1
   LOOP
    IF(l_delete_unit_effectivity_tbl(ue_count) is not null) THEN
     AHL_UMP_UNPLANNED_PVT.DELETE_UNIT_EFFECTIVITY
     (
     P_API_VERSION         => p_api_version,
     p_init_msg_list       => FND_API.G_FALSE,
     p_commit              => FND_API.G_FALSE,

     X_RETURN_STATUS       => l_return_status,
     X_MSG_COUNT           => l_msg_count,
     X_MSG_DATA            => l_msg_data,
     P_UNIT_EFFECTIVITY_ID => l_delete_unit_effectivity_tbl(ue_count)
     );

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string
     (
      fnd_log.level_statement,
     'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
      'After Calling ahl Ump Unplanned Pvt status : '|| l_return_status
     );
     END IF;

     IF (l_msg_count > 0) OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
   END LOOP;
  END IF;
     --Check for any space assignments
  OPEN Check_space_cur(p_visit_id);
     LOOP
     FETCH Check_space_cur INTO l_space_assignment_id;
     EXIT WHEN Check_space_cur%NOTFOUND;
     IF Check_space_cur%FOUND THEN
        DELETE FROM ahl_space_assignments
        WHERE space_assignment_id = l_space_assignment_id;
     END IF;
     END LOOP;
     CLOSE Check_space_cur;
     /* Added by mpothuku on 12/28/04 to delete the links */
     --Remove the stages before the visit is deleted
     ahl_vwp_visits_stages_pvt.delete_stages
     (
      p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_validation_level => p_validation_level,
      p_module_type      => NULL,
      p_visit_id         => p_visit_id,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data
     );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
  fnd_log.string
  (
   fnd_log.level_statement,
     'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
   'After Calling ahl Vwp Visits stages Pvt status : '|| l_return_status
  );
    END IF;

/* Added by mpothuku on 02/07/05. May need this after the enhancement for Scheduling materials
   for Simulation Visits */

/*
 --Delete any materials that might have been scheduled if new tasks are created.
 -- To Check if any materials are schedueled for the visit
 OPEN  c_Material(p_visit_id);
 FETCH c_Material INTO c_Material_rec;

 IF c_Material%FOUND THEN
    -- Removing planned materials for the visit
    AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials
    (
     p_api_version            => p_api_version,
     p_init_msg_list          => Fnd_Api.G_FALSE,
     p_commit                 => Fnd_Api.G_FALSE,
     p_visit_id               => p_visit_id,
     p_visit_task_id          => NULL,
     p_org_id                 => NULL,
     p_start_date             => NULL,
     p_operation_flag         => 'R',

     x_planned_order_flag     => l_planned_order_flag ,
     x_return_status          => l_return_status,
     x_msg_count              => l_msg_count,
     x_msg_data               => l_msg_data
    );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     CLOSE c_Material;
     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

 END IF;
 CLOSE c_Material;
*/
     /* mpothuku End */
     -- Remove the visit as well
    AHL_VISITS_PKG.DELETE_ROW (
            X_VISIT_ID => p_visit_id);

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
   IF G_DEBUG='Y' THEN
   -- Debug info
   Ahl_Debug_Pub.debug( 'End of private api Remove visits from plan','+SMPLN+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO remove_visits_fr_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Remove Visits from plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO remove_visits_fr_plan;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Remove Visits from plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

WHEN OTHERS THEN
    ROLLBACK TO remove_visits_fr_plan;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PVT',
                            p_procedure_name  =>  'REMOVE_VISITS_FR_PLAN',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Remove Visits from plan','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

END Remove_Visits_FR_Plan;


--------------------------------------------------------------------
-- PROCEDURE
--    Toggle_Simulation_Delete
--
-- PURPOSE
--    Toggle Simulation Delete/Undelete
--
-- PARAMETERS
--    p_visit_id                    : Visit Id
--    p_visit_object_version_number : Visit Object Version Number
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Toggle_Simulation_Delete (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                      IN      NUMBER,
   p_visit_object_version_number   IN      NUMBER,
   x_return_status                 OUT NOCOPY     VARCHAR2,
   x_msg_count                     OUT NOCOPY     NUMBER,
   x_msg_data                      OUT NOCOPY     VARCHAR2
)
IS
CURSOR visit_detail_cur(c_visit_id IN NUMBER)
IS
   SELECT VISIT_ID,
          OBJECT_VERSION_NUMBER,
          SIMULATION_DELETE_FLAG
      FROM AHL_VISITS_VL
    WHERE VISIT_ID = c_visit_id;

 l_api_name        CONSTANT VARCHAR2(30) := 'TOGGLE_SIMULATION_DELETE';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_visit_id                 NUMBER;
 l_object_version_number    NUMBER;
 l_simulation_delete_flag   VARCHAR2(1);
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT toggle_simulation_delete;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   -- Debug info.
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pvt.toggle simulation delete','+SMPNL+');
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

  ---------------------start API Body----------------------------------------
--   Check for Visit ID
   IF p_visit_id IS NOT NULL THEN
      OPEN visit_detail_cur(p_visit_id);
      FETCH visit_detail_cur INTO l_visit_id,
                                  l_object_version_number,
                                  l_simulation_delete_flag;
      IF visit_detail_cur%NOTFOUND THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_INVALID_RECORD');
        Fnd_Msg_Pub.ADD;
      END IF;
      CLOSE visit_detail_cur;
     END IF;
      --Check for object version number
      IF p_visit_object_version_number <> l_object_version_number THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_INVALID_RECORD');
        Fnd_Msg_Pub.ADD;
      END IF;
     --
     IF l_simulation_delete_flag = 'N' THEN
        UPDATE AHL_VISITS_B
         SET SIMULATION_DELETE_FLAG = 'Y',
  -- mpothuku start on 12/22/04
      OBJECT_VERSION_NUMBER = l_object_version_number + 1
  -- mpothuku End
       WHERE visit_id = p_visit_id;
     ELSE
        UPDATE AHL_VISITS_B
         SET SIMULATION_DELETE_FLAG = 'N',
 --Added by mpothuku on 12/22/04
      OBJECT_VERSION_NUMBER = l_object_version_number + 1
 -- mpothuku End
       WHERE visit_id = p_visit_id;
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
   IF G_DEBUG='Y' THEN
   -- Debug info
   Ahl_Debug_Pub.debug( 'End of private api Toggle Simulation Delete','+SMPLN+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO toggle_simulation_delete;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Toggle Simulation Delete','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO toggle_simulation_delete;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Toggle Simulation Delete','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN OTHERS THEN
    ROLLBACK TO toggle_simulation_delete;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PVT',
                            p_procedure_name  =>  'TOGGLE_SIMULATION_DELETE',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        IF AHL_DEBUG_PUB.G_FILE_DEBUG THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Toggle Simulation Delete','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

END Toggle_Simulation_Delete;

--------------------------------------------------------------------
-- PROCEDURE
--    Set_Plan_As_Primary
--
-- PURPOSE
--    Set Plan As Primary
--
-- PARAMETERS
--    p_plan_id                     : Simulation Plan Id
--    p_object_version_number       : Plan Object Version Number
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Set_Plan_As_Primary (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_plan_id                 IN      NUMBER,
   p_object_version_number   IN      NUMBER,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
CURSOR plan_cur  (c_plan_id IN NUMBER)
IS
  SELECT simulation_plan_id,
        object_version_number,
        primary_plan_flag
    FROM AHL_SIMULATION_PLANS_VL
  WHERE SIMULATION_PLAN_ID = c_plan_id;
  --
  CURSOR visit_detail_cur (c_plan_id IN NUMBER)
  IS
  SELECT visit_id,object_version_number
    FROM AHL_VISITS_VL
   WHERE SIMULATION_PLAN_ID = c_plan_id;
  --
  CURSOR check_visit_cur (c_plan_id IN NUMBER)
   IS
    SELECT visit_id FROM
      AHL_VISITS_VL
    WHERE SIMULATION_PLAN_ID = c_plan_id;
  --
 l_api_name        CONSTANT VARCHAR2(30) := 'SET_PLAN_AS_PRIMARY';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(2000);
 l_return_status            VARCHAR2(1);
 l_simulation_plan_id       NUMBER;
 l_primary_plan_flag        VARCHAR2(1);
 l_object_version_number    NUMBER;
 l_visit_id                 NUMBER;
 l_dummy                    NUMBER;
 BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT set_plan_as_primary;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pvt.set plan as primary','+SMPNL+');
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

  ---------------------start API Body----------------------------------------
   IF p_plan_id IS NULL AND p_plan_id <> FND_API.G_MISS_NUM THEN
      OPEN plan_cur(p_plan_id);
      FETCH plan_cur INTO l_simulation_plan_id,
                          l_object_version_number,
                          l_primary_plan_flag;
      IF plan_cur%NOTFOUND THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_RECORD_INVALID');
        Fnd_Msg_Pub.ADD;
      END IF;
      CLOSE plan_cur;
   END IF;
   --Check for any visits
     OPEN check_visit_cur(p_plan_id);
     FETCH check_visit_cur INTO l_dummy;
     IF check_visit_cur%NOTFOUND THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_SIMULATION_NO_VISITS');
        Fnd_Msg_Pub.ADD;
        CLOSE check_visit_cur;
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
     CLOSE check_visit_cur;
   --
   --Check for Record change
   IF p_object_version_number <> l_object_version_number THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_INVALID_PLAN_RECORD');
        Fnd_Msg_Pub.ADD;
   END IF;
   --Get all the simulated visits
    IF p_plan_id IS NOT NULL AND p_plan_id <> FND_API.G_MISS_NUM
    THEN

    OPEN visit_detail_cur(p_plan_id);
    LOOP
    FETCH visit_detail_cur INTO l_visit_id,l_object_version_number;

    EXIT WHEN visit_detail_cur%NOTFOUND;
     --Call set visit as primary
        Set_Visit_As_Primary
             ( p_api_version   => p_api_version,
               p_init_msg_list   => FND_API.G_FALSE,--p_init_msg_list,
               p_commit     => FND_API.G_FALSE, --p_commit,
               p_validation_level  => p_validation_level,
               p_module_type   => p_module_type,
               p_visit_id    => l_visit_id,
               p_plan_id    => p_plan_id,
               p_object_version_number  => l_object_version_number,
               x_return_status          => l_return_status,
               x_msg_count              => l_msg_count,
               x_msg_data               => l_msg_data);
      END LOOP;
    CLOSE visit_detail_cur;
    END IF;
    --Remove simulation plan
    -------------------Call Table handler generated procedure------------
       AHL_SIMULATION_PLANS_PKG.DELETE_ROW (
       X_SIMULATION_PLAN_ID => p_plan_id);
    ---------------------------End of Body---------------------------------------

  -- Changes by mpothuku end

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
   Ahl_Debug_Pub.debug( 'End of private api Set Plan as Primary','+SMPLN+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO toggle_simulation_delete;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Set Plan As Primary','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO set_plan_as_primary;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt. Set Plan as Primary','+SMPLN+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;
WHEN OTHERS THEN
    ROLLBACK TO set_plan_as_primary;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PVT',
                            p_procedure_name  =>  'SET_PLAN_AS_PRIMARY',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Set Plan as Primary','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
END Set_Plan_As_Primary;

--------------------------------------------------------------------
-- PROCEDURE
--    Set_Visit_As_Primary
--
-- PURPOSE
--    Set Visit As Primary
--
-- PARAMETERS
--    p_visit_id                    : Simulation Visit Id
--    p_object_version_number       : Visit Object Version Number
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Set_Visit_As_Primary (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER,
   p_plan_id                 IN      NUMBER,
   p_object_version_number   IN      NUMBER,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
 CURSOR simul_visit_cur  (c_visit_id  IN NUMBER,
                          c_plan_id   IN NUMBER)
    IS
   SELECT VISIT_ID,
          VISIT_NUMBER,
          VISIT_TYPE_CODE,
          SIMULATION_PLAN_ID,
          ITEM_INSTANCE_ID,
          ITEM_ORGANIZATION_ID,
          INVENTORY_ITEM_ID,
          ASSO_PRIMARY_VISIT_ID,
          SIMULATION_DELETE_FLAG,
          TEMPLATE_FLAG,
          OUT_OF_SYNC_FLAG,
          PROJECT_FLAG,
          PROJECT_ID,
          SERVICE_REQUEST_ID,
          SPACE_CATEGORY_CODE,
          SCHEDULE_DESIGNATOR,
          PRIORITY_CODE,
          PROJECT_TEMPLATE_ID,
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
          OBJECT_VERSION_NUMBER,
          ORGANIZATION_ID,
          DEPARTMENT_ID,
          STATUS_CODE,
          START_DATE_TIME,
          CLOSE_DATE_TIME,
          PRICE_LIST_ID,
          ESTIMATED_PRICE,
          ACTUAL_PRICE,
          OUTSIDE_PARTY_FLAG,
          ANY_TASK_CHG_FLAG,
          UNIT_SCHEDULE_ID,
          VISIT_NAME,
          DESCRIPTION,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          INV_LOCATOR_ID --Added by sowsubra
     FROM AHL_VISITS_VL
   WHERE VISIT_ID = c_visit_id
     AND SIMULATION_PLAN_ID = c_plan_id;

 --
 CURSOR check_primary_cur (c_plan_id IN NUMBER)
  IS
    SELECT simulation_plan_id
       FROM AHL_SIMULATION_PLANS_VL
     WHERE simulation_plan_id = c_plan_id
       AND primary_plan_flag = 'Y';

 --
 -- To get associated visit tasks
 CURSOR simul_visit_task_cur (c_visit_id IN NUMBER)
   IS
     SELECT
           ATSK.VISIT_TASK_ID,
           ATSK.VISIT_TASK_NUMBER,
           ATSK.OBJECT_VERSION_NUMBER,
           ATSK.VISIT_ID,
           ATSK.PROJECT_TASK_ID,
           ATSK.COST_PARENT_ID,
           ATSK.MR_ROUTE_ID,
           ATSK.MR_ID,
           ATSK.DURATION,
           ATSK.UNIT_EFFECTIVITY_ID,
           ATSK.VISIT_TASK_NAME,
           ATSK.DESCRIPTION,
           ATSK.START_FROM_HOUR,
           ATSK.INVENTORY_ITEM_ID,
           ATSK.ITEM_ORGANIZATION_ID,
           ATSK.INSTANCE_ID,
           ATSK.PRIMARY_VISIT_TASK_ID,
           ATSK.SUMMARY_TASK_FLAG,
           ATSK.ORIGINATING_TASK_ID,
           ATSK.SERVICE_REQUEST_ID,
           ATSK.TASK_TYPE_CODE,
           ATSK.DEPARTMENT_ID,
           ATSK.PRICE_LIST_ID,
           ATSK.STATUS_CODE,
           ATSK.ACTUAL_COST,
           ATSK.ESTIMATED_PRICE,
           ATSK.ACTUAL_PRICE,
           ATSK.STAGE_ID,
           ATSK.START_DATE_TIME,
           ATSK.END_DATE_TIME,
           -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Added two new attributes for past dates
           ATSK.PAST_TASK_START_DATE,
           ATSK.PAST_TASK_END_DATE,
           ATSK.QUANTITY, -- Added by rnahata for Issue 105
           ATSK.ATTRIBUTE_CATEGORY,
           ATSK.ATTRIBUTE1,
           ATSK.ATTRIBUTE2,
           ATSK.ATTRIBUTE3,
           ATSK.ATTRIBUTE4,
           ATSK.ATTRIBUTE5,
           ATSK.ATTRIBUTE6,
           ATSK.ATTRIBUTE7,
           ATSK.ATTRIBUTE8,
           ATSK.ATTRIBUTE9,
           ATSK.ATTRIBUTE10,
           ATSK.ATTRIBUTE11,
           ATSK.ATTRIBUTE12,
           ATSK.ATTRIBUTE13,
           ATSK.ATTRIBUTE14,
           ATSK.ATTRIBUTE15,
       MTSB.CONCATENATED_SEGMENTS ITEM_NAME,
       CSIS.SERIAL_NUMBER SERIAL_NUMBER
     FROM ahl_visit_tasks_vl ATSK,
      MTL_SYSTEM_ITEMS_B_KFV MTSB,
      CSI_ITEM_INSTANCES CSIS
   WHERE visit_id = c_visit_id and
     ATSK.INSTANCE_ID = CSIS.INSTANCE_ID (+) and
     ATSK. INVENTORY_ITEM_ID = MTSB.INVENTORY_ITEM_ID(+) AND
     ATSK. ITEM_ORGANIZATION_ID = MTSB.ORGANIZATION_ID(+) AND
       STATUS_CODE <> 'DELETED';
  -- Check for tasks exist in primary visit
  CURSOR check_visit_task_cur (c_visit_id IN NUMBER,
                               c_visit_task_id IN NUMBER)
   IS
    SELECT visit_task_id
       FROM ahl_visit_tasks_vl
     WHERE visit_id = c_visit_id
      AND visit_task_id = c_visit_task_id
   AND status_code <> 'DELETED';

 -- Check for tasks exist in primary visit tasks which are not in simulation visit
  CURSOR check_exist_visit_task_cur (c_visit_id IN NUMBER)
   IS
    SELECT visit_task_id
       FROM ahl_visit_tasks_vl
     WHERE visit_id = c_visit_id;

 -- Check for tasks exist in primary visit tasks which are not in simulation visit
  CURSOR check_prim_visit_task_cur (c_visit_id IN NUMBER,
                                    c_visit_task_id IN NUMBER)
   IS
    SELECT primary_visit_task_id
       FROM ahl_visit_tasks_vl
     WHERE visit_id = c_visit_id
     AND primary_visit_task_id = c_visit_task_id
  AND status_code <> 'DELETED' ;

 --Get tasks that needs deletion
  CURSOR get_tasks_delete_csr(x_id IN NUMBER)
  IS
 SELECT visit_task_id,object_version_number,visit_task_number
    FROM  Ahl_Visit_Tasks_VL
 WHERE VISIT_ID = x_id AND NVL(STATUS_CODE,'X') <> 'DELETED'
 AND ((TASK_TYPE_CODE = 'SUMMARY' AND ORIGINATING_TASK_ID IS NULL)
    OR TASK_TYPE_CODE = 'UNASSOCIATED'
    OR (TASK_TYPE_CODE = 'SUMMARY' AND MR_ID IS NULL));

  --Check for space assignments
  CURSOR check_space_cur (c_visit_id IN NUMBER)
   IS
  SELECT space_assignment_id
    FROM ahl_space_assignments
   WHERE visit_id = c_visit_id;
 --
 -- Added by mpothuku on 12/27/04
 -- To find any task links for a task
    CURSOR c_links (x_id IN NUMBER) IS
      SELECT COUNT(*) FROM Ahl_Task_Links L ,Ahl_Visit_Tasks_B T
      WHERE (T.VISIT_TASK_ID = L.VISIT_TASK_ID OR T.VISIT_TASK_ID = L.PARENT_TASK_ID)
      AND T.VISIT_TASK_ID = x_id;

 -- To find task link related information for a visit
   CURSOR c_visit_task_links(x_visit_id IN NUMBER) IS
     SELECT VISIT_TASK_ID ,
      PARENT_TASK_ID,
      --SECURITY_GROUP_ID,
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
     FROM AHL_TASK_LINKS
     WHERE visit_task_id in (  SELECT VISIT_TASK_ID
            FROM AHL_VISIT_TASKS_B
            WHERE visit_id = x_visit_id);
-- To find the coresponding task id in the new visit
   CURSOR c_new_task(x_visit_task_id IN NUMBER, x_new_visit_id IN NUMBER) IS
     SELECT b.VISIT_TASK_ID,b.VISIT_TASK_NUMBER
     FROM AHL_VISIT_TASKS_B a, AHL_VISIT_TASKS_B b
     WHERE a.visit_task_id = x_visit_task_id
          AND a.visit_task_number = b.visit_task_number
          AND b.visit_id = x_new_visit_id;


--To get the stages from a visit
  CURSOR Get_stages_cur(c_visit_id IN NUMBER) IS
    SELECT STAGE_ID,
     STAGE_NUM,
     VISIT_ID,
     DURATION,
       OBJECT_VERSION_NUMBER,
     STAGE_NAME,
     --SECURITY_GROUP_ID
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
    FROM ahl_vwp_stages_vl s
    WHERE visit_id = c_visit_id
    ORDER BY stage_num;

-- To find the coresponding Stage id in the new visit
CURSOR c_new_stage(c_old_stage_id IN NUMBER, c_new_visit_id IN NUMBER) IS
 SELECT NewStage.Stage_Id, NewStage.Stage_Name
 FROM ahl_vwp_stages_vl OldStage, ahl_vwp_stages_vl NewStage
 WHERE OldStage.Stage_Id = c_old_stage_id
  AND NewStage.visit_id = c_new_visit_id
  AND NewStage.Stage_Num = OldStage.Stage_Num;

-- Added by mpothuku on 01/20/05 To find if this Unit has been planned in other visits already
CURSOR chk_unit_effectivities (c_unit_id IN NUMBER,c_visit_id IN NUMBER) IS
 SELECT VISIT_NUMBER FROM AHL_VISITS_B ahlv ,AHL_SIMULATION_PLANS_B ahlp WHERE
 VISIT_ID IN (SELECT DISTINCT VISIT_ID FROM AHL_VISIT_TASKS_B WHERE
 Unit_Effectivity_Id = c_unit_id)
 and visit_id <> c_visit_id
 and ahlv.simulation_plan_id = ahlp.simulation_plan_id
 and ahlp.primary_plan_flag = 'Y'
 --The following condition is necessary since the summary task may already have been
 --added to the current visit which will have the same UE as the planned task
 and status_code not in ('CANCELLED','DELETED');

/*
   AnRaj: Added for fixing the performance issues logged in bug#:4919576
*/

/*  CURSOR c_ue_details(c_unit_id IN NUMBER) IS
 select ue.title ue_title, ue.part_number, ue.serial_number, MR.title mr_title from ahl_unit_effectivities_v ue,ahl_mr_headers_v MR where MR.mr_header_id = ue.mr_header_id
 and ue.unit_effectivity_id = c_unit_id;
*/

CURSOR c_ue_mr_sr_id(c_unit_id IN NUMBER) IS
 select   ue.mr_header_id, ue.cs_incident_id,ue.csi_item_instance_id
 from     ahl_unit_effectivities_b ue
 where    ue.unit_effectivity_id = c_unit_id;
ue_mr_sr_id_rec      c_ue_mr_sr_id%ROWTYPE;

CURSOR c_ue_mr_details(c_mr_header_id IN NUMBER,c_item_instance_id IN NUMBER) IS
 SELECT   mr.title ue_title,
          mtl.concatenated_segments part_number,
          csi.serial_number serial_number,
          mr.title mr_title
 FROM     ahl_mr_headers_vl mr,
          mtl_system_items_kfv mtl,
          csi_item_instances csi
 WHERE    mr.mr_header_id = c_mr_header_id
 AND      csi.instance_id = c_item_instance_id
 AND      csi.inventory_item_id = mtl.inventory_item_id
 AND      csi.inv_master_organization_id = mtl.organization_id ;
ue_mr_details_rec       c_ue_mr_details%ROWTYPE;

CURSOR c_ue_sr_details(cs_incident_id IN NUMBER,c_item_instance_id IN NUMBER) IS
 SELECT   (cit.name || '-' || cs.incident_number) ue_title,
          mtl.concatenated_segments part_number,
          csi.serial_number serial_number,
          null mr_title
 FROM     cs_incident_types_vl cit,
          cs_incidents_all_b cs,
          mtl_system_items_kfv mtl,
          csi_item_instances csi
 WHERE    cs.incident_id = cs_incident_id
 AND      cit.incident_type_id = cs.incident_type_id
 AND      csi.instance_id   = c_item_instance_id
 AND      csi.inventory_item_id = mtl.inventory_item_id
 AND      csi.inv_master_organization_id = mtl.organization_id ;
ue_sr_details_rec       c_ue_sr_details%ROWTYPE;
/*
   AnRaj: End of Fix bug#:4919576
*/

CURSOR c_Visit(x_id IN NUMBER) IS
 SELECT *
 FROM   Ahl_Visits_VL
 WHERE  VISIT_ID = x_id;

CURSOR c_task(c_task_id IN NUMBER) IS
 SELECT *
 FROM   Ahl_Visit_tasks_vl
 WHERE  visit_task_id = c_task_id;

CURSOR c_new_primary_task (c_simulation_task_id IN NUMBER) IS
 SELECT prim.visit_task_id, prim.visit_task_number FROM
 ahl_visit_tasks_b prim, ahl_visit_tasks_b sim
 WHERE
 sim.visit_task_id = c_simulation_task_id and
 prim.visit_task_id = sim.primary_visit_task_id;

-- mpothuku End

-- anraj for fixing the issue number 207 in the CMRO Forum
CURSOR c_visit_details_for_materials(c_visit_id IN NUMBER) IS
 SELECT  organization_id,department_id,start_date_time
 FROM    ahl_visits_vl
 WHERE   VISIT_ID = c_visit_id;

/*Added by sowsubra*/
CURSOR c_validate_subinv_loc_dtl(p_inv_locator_id IN NUMBER, p_org_id IN NUMBER) IS
 SELECT subinventory_code, CONCATENATED_SEGMENTS
 FROM mtl_item_locations_kfv
 WHERE inventory_location_id = p_inv_locator_id
 -- jaramana on Feb 14, 2008 for bug 6819370
 -- Removed null check on segment19 and segment20
 AND organization_id = p_org_id;

/*Added by sowsubra*/
CURSOR c_get_default_loc_dtl(p_org_id IN NUMBER, p_dept_id IN NUMBER) IS
 SELECT ds.inv_locator_id, mtl.subinventory_code, mtl.CONCATENATED_SEGMENTS
 FROM ahl_department_shifts_v ds, hr_organization_units hou, mtl_item_locations_kfv mtl
 WHERE hou.organization_id = p_org_id
 AND hou.name = ds.organization_name
 AND ds.department_id = p_dept_id
 AND hou.organization_id = mtl.organization_id
 AND ds.inv_locator_id = mtl.inventory_location_id;

 l_visit_details_for_materials c_visit_details_for_materials%ROWTYPE;

 l_api_name        CONSTANT VARCHAR2(30) := 'SET_VISIT_AS_PRIMARY';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_full_name       CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(2000);
 l_return_status            VARCHAR2(1);
 l_rowid                    VARCHAR2(30);
 l_simulation_plan_id       NUMBER;
 l_primary_plan_flag        VARCHAR2(1);
 l_s_object_number          NUMBER;
 l_simul_visit_rec          simul_visit_cur%ROWTYPE;
 l_primary_visit_id         NUMBER;
 l_primary_plan_id          NUMBER;
 l_primary_visit_number     NUMBER;
 l_unit_effectivity_id      NUMBER;
 l_primary_visit_task_id    NUMBER;
 l_visit_task_id            NUMBER;
 l_prim_visit_task_id       NUMBER;
 l_simul_visit_task_rec     simul_visit_task_cur%ROWTYPE;
 l_exist_prim_visit_task_id NUMBER;
 l_sim_prim_visit_task_id   NUMBER;
 l_space_assignment_id      NUMBER;
 l_count                    NUMBER;
 l_new_parent_task_id       NUMBER;
 l_new_task_id              NUMBER;
 l_new_task_number          NUMBER;
 l_new_stage_id             NUMBER;
 l_stage_rec                Get_stages_cur%ROWTYPE;
 l_visit_number             NUMBER;
 -- l_ue_details_rec        c_ue_details%ROWTYPE;
 l_visit_tbl                AHL_VWP_VISITS_PVT.Visit_Tbl_Type;
 l_visit_count              NUMBER := 0;
 l_prim_visit_rec           AHL_VWP_VISITS_PVT.Visit_Rec_Type;
 l_prim_visit_tbl           AHL_VWP_VISITS_PVT.Visit_Tbl_Type;
 c_visit_rec                c_Visit%ROWTYPE;
 l_prim_visit_task_rec      AHL_VWP_RULES_PVT.Task_Rec_Type;
 c_task_rec                 c_task%ROWTYPE;
 l_hour                     NUMBER(2);
 l_hour_close               NUMBER(2);
 l_minute                   NUMBER(2);
 l_minute_close             NUMBER(2);
 l_tasks_delete_rec         get_tasks_delete_csr%ROWTYPE;
 l_planned_order_flag       VARCHAR2(1);
 l_new_stage_name           VARCHAR2(80);
 l_dummy                    VARCHAR2(1);
 l_visit_task_number        NUMBER;
 l_task_link_rec            c_visit_task_links%ROWTYPE;
 /*Added by sowsubra*/
 l_locator_id               NUMBER := 0;

 BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT set_visit_as_primary;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pvt.set visit as primary','+SMPNL+');
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

  ---------------------start API Body----------------------------------------
   --Check for simulation plan is primary
     OPEN check_primary_cur(p_plan_id);
     FETCH check_primary_cur INTO l_primary_plan_id;
     CLOSE check_primary_cur;
   --
      IF l_primary_plan_id IS NOT NULL THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_PRIMARY_PLAN');
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   --Check for visit belongs to simulation plan
   SELECT simulation_plan_id,
          primary_plan_flag,
          object_version_number INTO
             l_simulation_plan_id,l_primary_plan_flag, l_s_object_number
          FROM AHL_SIMULATION_PLANS_VL
       WHERE simulation_plan_id = p_plan_id
         AND primary_plan_flag = 'N';
   --
   IF l_simulation_plan_id IS NULL THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_PRIMARY_PLAN');
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Check for simulation plan
    OPEN simul_visit_cur(p_visit_id,p_plan_id);
    FETCH simul_visit_cur INTO l_simul_visit_rec;
    IF simul_visit_cur%NOTFOUND THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_INVALID_RECORD');
        Fnd_Msg_Pub.ADD;
        CLOSE simul_visit_cur;
        RAISE Fnd_Api.G_EXC_ERROR;
     END IF;
     CLOSE simul_visit_cur;

     --Check for object version number
    IF p_object_version_number <> l_simul_visit_rec.object_version_number
    THEN
        Fnd_message.SET_NAME('AHL','AHL_LTP_INVALID_PLAN_RECORD');
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
    --Get corresponding primary visit

    SELECT VISIT_ID,VISIT_NUMBER, a.SIMULATION_PLAN_ID INTO
                        l_primary_visit_id, l_primary_visit_number,
                        l_simulation_plan_id
            FROM ahl_visits_vl a, ahl_simulation_plans_vl b
            WHERE a.visit_id = l_simul_visit_rec.asso_primary_visit_id
             and a.simulation_plan_id = b.simulation_plan_id
             and b.primary_plan_flag = 'Y';
   IF G_DEBUG='Y' THEN

       AHL_DEBUG_PUB.debug( 'before update id :'||l_primary_visit_id);
       AHL_DEBUG_PUB.debug( 'before update number:'||l_primary_visit_number);
   END IF;

   --Check for simulation delete flag
 IF l_simul_visit_rec.simulation_delete_flag = 'Y' THEN --Remove the Primary Visit
  /* Modified by mpothuku on 01/25/05 to delete the primary visit if the Simulation Flag is delete */
  /*
  Fnd_message.SET_NAME('AHL','AHL_LTP_VISIT_REMOVED');
  Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
  */
  IF l_primary_visit_id IS NOT NULL THEN
   l_visit_tbl(l_visit_count).visit_id := l_primary_visit_id;
   l_visit_tbl(l_visit_count).operation_flag := 'D';
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string
    (
     fnd_log.level_statement,
     'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
     'Before Calling ahl Vwp Visits Pvt Process Visit Records : '|| l_visit_count
    );
   END IF;
   AHL_VWP_VISITS_PVT.Process_Visit
   (
    p_api_version          => p_api_version,
    p_init_msg_list        => FND_API.g_false,--p_init_msg_list,
    p_commit               => FND_API.g_false, --p_commit,
    p_validation_level     => p_validation_level,
    p_module_type          => p_module_type,
    p_x_Visit_tbl     => l_visit_tbl,
    x_return_status        => l_return_status,
    x_msg_count            => l_msg_count,
    x_msg_data             => l_msg_data
   );

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
   THEN
    fnd_log.string
    (
     fnd_log.level_statement,
     'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
     'After Calling ahl Vwp Visits Pvt status : '|| l_return_status
    );
   END IF;
   -- Check Error Message stack.
   IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
   END IF;
  END IF;

 ELSE --Modify the visit and its related atributes

  IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'after else update id :'||l_primary_visit_id);
   AHL_DEBUG_PUB.debug( 'after else update number:'||l_primary_visit_number);
   --AHL_DEBUG_PUB.debug( 'after else update date:'||l_simul_visit_rec.START_DATE_TIME);
  END IF;
        --Replace primary visit attributes with simulation visit attributes
  OPEN c_Visit(l_primary_visit_id);
  FETCH c_Visit INTO c_visit_rec;
  CLOSE c_Visit;

  -- To check if visit starttime is not null then store time in HH4 format
        IF (l_simul_visit_rec.START_DATE_TIME IS NOT NULL AND l_simul_visit_rec.START_DATE_TIME <> Fnd_Api.G_MISS_DATE) THEN
            l_hour := TO_NUMBER(TO_CHAR(l_simul_visit_rec.START_DATE_TIME , 'HH24'));
            l_minute := TO_NUMBER(TO_CHAR(l_simul_visit_rec.START_DATE_TIME , 'MI'));
        ELSE
            l_hour := NULL;
   l_minute := NULL;
            l_simul_visit_rec.START_DATE_TIME := NULL;
        END IF;

        -- To check if visit closetime is not null then store time in HH4 format
        IF (l_simul_visit_rec.CLOSE_DATE_TIME IS NOT NULL AND l_simul_visit_rec.CLOSE_DATE_TIME <> Fnd_Api.G_MISS_DATE) THEN
            l_hour_close := TO_NUMBER(TO_CHAR(l_simul_visit_rec.CLOSE_DATE_TIME , 'HH24'));
            l_minute_close := TO_NUMBER(TO_CHAR(l_simul_visit_rec.CLOSE_DATE_TIME , 'MI'));
        ELSE
            l_hour_close := NULL;
   l_minute_close := NULL;
            l_simul_visit_rec.CLOSE_DATE_TIME := Null;
        END IF;

      -- To chk if the subinvneotry/locator information is valid for the organization. If not valid
      /*Added by sowsubra - starts*/
      OPEN c_validate_subinv_loc_dtl (l_simul_visit_rec.inv_locator_id, l_simul_visit_rec.organization_id);
      FETCH c_validate_subinv_loc_dtl INTO l_prim_visit_rec.SUBINVENTORY,l_prim_visit_rec.LOCATOR_SEGMENT;
        IF c_validate_subinv_loc_dtl%NOTFOUND THEN
          OPEN c_get_default_loc_dtl(l_simul_visit_rec.organization_id, l_simul_visit_rec.department_id);
          FETCH c_get_default_loc_dtl INTO l_locator_id,l_prim_visit_rec.SUBINVENTORY,l_prim_visit_rec.LOCATOR_SEGMENT;
            IF c_get_default_loc_dtl%NOTFOUND THEN
              l_prim_visit_rec.inv_locator_id := NULL;
            ELSE
              l_prim_visit_rec.inv_locator_id := l_locator_id;
            END IF;
          CLOSE c_get_default_loc_dtl;
        END IF;
        CLOSE c_validate_subinv_loc_dtl;
      /*Added by sowsubra - ends*/

  l_prim_visit_rec.VISIT_ID    := l_primary_visit_id;
  l_prim_visit_rec.VISIT_NUMBER   := l_primary_visit_number;
  l_prim_visit_rec.VISIT_TYPE_CODE  := l_simul_visit_rec.VISIT_TYPE_CODE;
  l_prim_visit_rec.SIMULATION_PLAN_ID  := l_simulation_plan_id;
  l_prim_visit_rec.ITEM_INSTANCE_ID  := l_simul_visit_rec.ITEM_INSTANCE_ID;
  l_prim_visit_rec.INVENTORY_ITEM_ID  := l_simul_visit_rec.INVENTORY_ITEM_ID;
  l_prim_visit_rec.ASSO_PRIMARY_VISIT_ID := NULL;
  l_prim_visit_rec.SIMULATION_DELETE_FLAG := 'N';
  l_prim_visit_rec.TEMPLATE_FLAG   := l_simul_visit_rec.TEMPLATE_FLAG;
  l_prim_visit_rec.OUT_OF_SYNC_FLAG  := l_simul_visit_rec.OUT_OF_SYNC_FLAG;
  l_prim_visit_rec.PROJECT_FLAG   := l_simul_visit_rec.PROJECT_FLAG;
  l_prim_visit_rec.PROJECT_ID    := l_simul_visit_rec.PROJECT_ID;
  l_prim_visit_rec.ATTRIBUTE1    := l_simul_visit_rec.ATTRIBUTE1;
  l_prim_visit_rec.ATTRIBUTE2    := l_simul_visit_rec.ATTRIBUTE2;
  l_prim_visit_rec.ATTRIBUTE3    := l_simul_visit_rec.ATTRIBUTE3;
  l_prim_visit_rec.ATTRIBUTE4    := l_simul_visit_rec.ATTRIBUTE4;
  l_prim_visit_rec.ATTRIBUTE5    := l_simul_visit_rec.ATTRIBUTE5;
  l_prim_visit_rec.ATTRIBUTE6    := l_simul_visit_rec.ATTRIBUTE6;
  l_prim_visit_rec.ATTRIBUTE7    := l_simul_visit_rec.ATTRIBUTE7;
  l_prim_visit_rec.ATTRIBUTE8    := l_simul_visit_rec.ATTRIBUTE8;
  l_prim_visit_rec.ATTRIBUTE9    := l_simul_visit_rec.ATTRIBUTE9;
  l_prim_visit_rec.ATTRIBUTE10   := l_simul_visit_rec.ATTRIBUTE10;
  l_prim_visit_rec.ATTRIBUTE11   := l_simul_visit_rec.ATTRIBUTE11;
  l_prim_visit_rec.ATTRIBUTE12   := l_simul_visit_rec.ATTRIBUTE12;
  l_prim_visit_rec.ATTRIBUTE13   := l_simul_visit_rec.ATTRIBUTE13;
  l_prim_visit_rec.ATTRIBUTE14   := l_simul_visit_rec.ATTRIBUTE14;
  l_prim_visit_rec.ATTRIBUTE15   := l_simul_visit_rec.ATTRIBUTE15;
  l_prim_visit_rec.OBJECT_VERSION_NUMBER  := c_visit_rec.OBJECT_VERSION_NUMBER;
  l_prim_visit_rec.ORGANIZATION_ID  := l_simul_visit_rec.ORGANIZATION_ID;
  --l_prim_visit_rec.ORG_NAME    := l_simul_visit_rec.ORG_NAME;
  l_prim_visit_rec.DEPARTMENT_ID   := l_simul_visit_rec.DEPARTMENT_ID;
  --l_prim_visit_rec.DEPT_NAME   := l_simul_visit_rec.DEPT_NAME;
  l_prim_visit_rec.STATUS_CODE   := l_simul_visit_rec.STATUS_CODE;

  l_prim_visit_rec.START_DATE    := l_simul_visit_rec.START_DATE_TIME;
  l_prim_visit_rec.START_HOUR    := l_hour;
  l_prim_visit_rec.START_MIN    := l_minute;
  l_prim_visit_rec.PLAN_END_DATE   := l_simul_visit_rec.CLOSE_DATE_TIME;
  l_prim_visit_rec.PLAN_END_HOUR   := l_hour_close;
  l_prim_visit_rec.PLAN_END_MIN   := l_minute_close;

  l_prim_visit_rec.OUTSIDE_PARTY_FLAG  := l_simul_visit_rec.OUTSIDE_PARTY_FLAG;
  l_prim_visit_rec.VISIT_NAME    := l_simul_visit_rec.VISIT_NAME;
  l_prim_visit_rec.DESCRIPTION   := l_simul_visit_rec.DESCRIPTION;
  l_prim_visit_rec.SERVICE_REQUEST_ID  := l_simul_visit_rec.SERVICE_REQUEST_ID;
  l_prim_visit_rec.SPACE_CATEGORY_CODE := l_simul_visit_rec.SPACE_CATEGORY_CODE;
  l_prim_visit_rec.PRIORITY_CODE    := l_simul_visit_rec.priority_code;
  l_prim_visit_rec.PROJ_TEMPLATE_ID  := l_simul_visit_rec.PROJECT_TEMPLATE_ID;
  l_prim_visit_rec.UNIT_SCHEDULE_ID  := l_simul_visit_rec.UNIT_SCHEDULE_ID;
  l_prim_visit_rec.OPERATION_FLAG   := 'U';
  l_prim_visit_tbl(0) := l_prim_visit_rec;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
   fnd_log.string
   (
    fnd_log.level_statement,
    'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    'Before Calling ahl Vwp Visits Pvt Process Visit Records for visit : '|| l_primary_visit_id
   );

  END IF;

  AHL_VWP_VISITS_PVT.Process_Visit
  (
    p_api_version          => p_api_version,
    p_init_msg_list        => FND_API.g_false,
    p_commit               => FND_API.g_false,
    p_validation_level     => p_validation_level,
    p_module_type          => NULL, --p_module_type,
    p_x_Visit_tbl          => l_prim_visit_tbl,
    x_return_status        => l_return_status,
    x_msg_count            => l_msg_count,
    x_msg_data             => l_msg_data
  );

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

  -- Update the Any_task_chg flag to 'Y'
        AHL_VWP_RULES_PVT.Update_Visit_Task_Flag
        (
   p_visit_id      => l_primary_visit_id,
            p_flag          =>  'Y',
            x_return_status => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check for tasks exist in primary visit tasks which are not in simulation visit
  OPEN get_tasks_delete_csr (l_primary_visit_id);
  LOOP
  FETCH get_tasks_delete_csr INTO l_tasks_delete_rec;
  EXIT WHEN get_tasks_delete_csr%NOTFOUND;
   IF l_tasks_delete_rec.visit_task_id IS NOT NULL THEN
    /* Added by mpothuku on 01/11/04 */
    l_sim_prim_visit_task_id := null;
    /* mpothuku End */
    OPEN check_prim_visit_task_cur(p_visit_id,l_tasks_delete_rec.visit_task_id);
    FETCH check_prim_visit_task_cur INTO l_sim_prim_visit_task_id;
    CLOSE check_prim_visit_task_cur;
    IF (l_sim_prim_visit_task_id IS NULL)
    THEN
     --This will take care of removing the links as well from the primary tasks.
       AHL_VWP_TASKS_PVT.Delete_Task
          (
           p_api_version      => p_api_version,
           p_init_msg_list    => FND_API.g_false,
           p_commit           => FND_API.g_false,
           p_validation_level => p_validation_level,
           p_module_type      => NULL,
           p_visit_task_id    => l_tasks_delete_rec.visit_task_id,
           x_return_status    => l_return_status,
           x_msg_count        => l_msg_count,
           x_msg_data         => l_msg_data
          );

     -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
       l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
       CLOSE get_tasks_delete_csr;
       RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;
    END IF;
   END IF;
  END LOOP;
  CLOSE get_tasks_delete_csr;

    -- Set the corrseponding tasks
  OPEN simul_visit_task_cur(p_visit_id);
     LOOP
     FETCH simul_visit_task_cur INTO l_simul_visit_task_rec;

  IF G_DEBUG='Y' THEN
  AHL_DEBUG_PUB.debug( 'after fetch'||l_simul_visit_task_rec.primary_visit_task_id);
  END IF;

  EXIT WHEN simul_visit_task_cur%NOTFOUND;
  --
  l_primary_visit_task_id := null;
  --Check if there is corresponding task in the Primary Visit table.
  IF l_simul_visit_task_rec.primary_visit_task_id IS NOT NULL THEN
   --Replace simulation visit task attributes with primary task attributes
   OPEN check_visit_task_cur(l_primary_visit_id,l_simul_visit_task_rec.primary_visit_task_id);
   FETCH check_visit_task_cur INTO l_primary_visit_task_id;
   CLOSE check_visit_task_cur;

   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'Primary visit task:'||l_primary_visit_task_id);
   END IF;
  END IF;

  /* Added by mpothuku on 01/20/05 to Check if the UE is associated with any of the visits in the plan */
  IF(l_simul_visit_task_rec.task_type_code = 'PLANNED' and l_simul_visit_task_rec.unit_effectivity_id IS NOT NULL) THEN

    OPEN chk_unit_effectivities (l_simul_visit_task_rec.unit_effectivity_id,l_primary_visit_id);
    FETCH chk_unit_effectivities INTO l_visit_number;
    IF (chk_unit_effectivities%FOUND) THEN
       CLOSE chk_unit_effectivities;

       /*
          AnRaj: Added for fixing the performance issues logged in bug#:4919576
       */
       -- ERROR MESSAGE
       /*
       OPEN c_ue_details (l_simul_visit_task_rec.unit_effectivity_id);
       FETCH c_ue_details INTO l_ue_details_rec;
       CLOSE c_ue_details;
       */
       x_return_status := Fnd_Api.g_ret_sts_error;
       OPEN  c_ue_mr_sr_id(l_simul_visit_task_rec.unit_effectivity_id);
       FETCH c_ue_mr_sr_id INTO ue_mr_sr_id_rec;
       CLOSE c_ue_mr_sr_id;

       IF ue_mr_sr_id_rec.cs_incident_id IS NOT NULL THEN
          OPEN c_ue_sr_details(ue_mr_sr_id_rec.cs_incident_id,ue_mr_sr_id_rec.csi_item_instance_id);
          FETCH c_ue_sr_details INTO ue_sr_details_rec;
          CLOSE c_ue_sr_details;
          Fnd_Message.SET_NAME('AHL','AHL_LTP_PRIM_VISIT_UNIT_FOUND');
          Fnd_Message.SET_TOKEN('UE_TITLE', ue_sr_details_rec.ue_title);
          Fnd_Message.SET_TOKEN('ITEM_NUMBER', ue_sr_details_rec.part_number);
          Fnd_Message.SET_TOKEN('SERIAL_NUMBER', ue_sr_details_rec.serial_number);
          Fnd_Message.SET_TOKEN('MR_TITLE', ue_sr_details_rec.mr_title);
          Fnd_Message.SET_TOKEN('VISIT1', l_primary_visit_number);
          Fnd_Message.SET_TOKEN('VISIT2', l_visit_number);
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
       ELSE
          OPEN c_ue_mr_details(ue_mr_sr_id_rec.mr_header_id,ue_mr_sr_id_rec.csi_item_instance_id);
          FETCH c_ue_mr_details INTO ue_mr_details_rec;
          CLOSE c_ue_mr_details;
          Fnd_Message.SET_NAME('AHL','AHL_LTP_PRIM_VISIT_UNIT_FOUND');
          Fnd_Message.SET_TOKEN('UE_TITLE', ue_mr_details_rec.ue_title);
          Fnd_Message.SET_TOKEN('ITEM_NUMBER', ue_mr_details_rec.part_number);
          Fnd_Message.SET_TOKEN('SERIAL_NUMBER', ue_mr_details_rec.serial_number);
          Fnd_Message.SET_TOKEN('MR_TITLE', ue_mr_details_rec.mr_title);
          Fnd_Message.SET_TOKEN('VISIT1', l_primary_visit_number);
          Fnd_Message.SET_TOKEN('VISIT2', l_visit_number);
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;
       /*
          AnRaj: End of Fix bug#:4919576
       */
    ELSE
       CLOSE chk_unit_effectivities;
    END IF;
 END IF;

  IF(l_simul_visit_task_rec.primary_visit_task_id IS NOT NULL and l_primary_visit_task_id IS NOT NULL )
  THEN
   OPEN c_task(l_simul_visit_task_rec.primary_visit_task_id);
   FETCH c_task INTO c_task_rec;
   CLOSE c_task;
   l_prim_visit_task_rec.VISIT_TASK_ID := l_simul_visit_task_rec.primary_visit_task_id;
   l_prim_visit_task_rec.OBJECT_VERSION_NUMBER := c_task_rec.OBJECT_VERSION_NUMBER;
   l_prim_visit_task_rec.VISIT_TASK_NUMBER  := l_simul_visit_task_rec.visit_task_number;
   l_prim_visit_task_rec.VISIT_ID    := l_primary_visit_id;
   l_prim_visit_task_rec.PROJECT_TASK_ID  := l_simul_visit_task_rec.PROJECT_TASK_ID;
   l_prim_visit_task_rec.COST_PARENT_ID     := null;
   l_prim_visit_task_rec.MR_ROUTE_ID   := l_simul_visit_task_rec.MR_ROUTE_ID;
   l_prim_visit_task_rec.MR_ID     := l_simul_visit_task_rec.MR_ID;
   l_prim_visit_task_rec.DURATION    := l_simul_visit_task_rec.DURATION;
   l_prim_visit_task_rec.UNIT_EFFECTIVITY_ID := l_simul_visit_task_rec.UNIT_EFFECTIVITY_ID;
   l_prim_visit_task_rec.START_FROM_HOUR  := l_simul_visit_task_rec.START_FROM_HOUR;
   l_prim_visit_task_rec.INVENTORY_ITEM_ID  := l_simul_visit_task_rec.INVENTORY_ITEM_ID;
   l_prim_visit_task_rec.ITEM_ORGANIZATION_ID := l_simul_visit_task_rec.ITEM_ORGANIZATION_ID;
   l_prim_visit_task_rec.INSTANCE_ID   := l_simul_visit_task_rec.INSTANCE_ID;
   l_prim_visit_task_rec.PRIMARY_VISIT_TASK_ID := null;
   --l_prim_visit_task_rec.SUMMARY_TASK_FLAG := l_simul_visit_task_rec.SUMMARY_TASK_FLAG;
   l_prim_visit_task_rec.ORIGINATING_TASK_ID := null;
   l_prim_visit_task_rec.SERVICE_REQUEST_ID := l_simul_visit_task_rec.SERVICE_REQUEST_ID;
   l_prim_visit_task_rec.TASK_TYPE_CODE  := l_simul_visit_task_rec.TASK_TYPE_CODE;
   --l_prim_visit_task_rec.PRICE_LIST_ID  := l_simul_visit_task_rec.PRICE_LIST_ID ;
   --l_prim_visit_task_rec.ESTIMATED_PRICE  := l_simul_visit_task_rec.ESTIMATED_PRICE;
   --l_prim_visit_task_rec.ACTUAL_PRICE  := l_simul_visit_task_rec.ACTUAL_PRICE;
   --l_prim_visit_task_rec.ACTUAL_COST   := l_simul_visit_task_rec.ACTUAL_COST;
   l_prim_visit_task_rec.STAGE_ID           := null;--l_simul_visit_task_rec.STAGE_ID;
   l_prim_visit_task_rec.TASK_STATUS_CODE   := l_simul_visit_task_rec.STATUS_CODE;
   l_prim_visit_task_rec.ATTRIBUTE_CATEGORY := l_simul_visit_task_rec.ATTRIBUTE_CATEGORY;
   l_prim_visit_task_rec.ATTRIBUTE1         := l_simul_visit_task_rec.attribute1;
   l_prim_visit_task_rec.ATTRIBUTE2         := l_simul_visit_task_rec.attribute2;
   l_prim_visit_task_rec.ATTRIBUTE3         := l_simul_visit_task_rec.attribute3;
   l_prim_visit_task_rec.ATTRIBUTE4         := l_simul_visit_task_rec.attribute4;
   l_prim_visit_task_rec.ATTRIBUTE5         := l_simul_visit_task_rec.attribute5;
   l_prim_visit_task_rec.ATTRIBUTE6         := l_simul_visit_task_rec.attribute6;
   l_prim_visit_task_rec.ATTRIBUTE7         := l_simul_visit_task_rec.attribute7;
   l_prim_visit_task_rec.ATTRIBUTE8         := l_simul_visit_task_rec.attribute8;
   l_prim_visit_task_rec.ATTRIBUTE9         := l_simul_visit_task_rec.attribute9;
   l_prim_visit_task_rec.ATTRIBUTE10        := l_simul_visit_task_rec.attribute10;
   l_prim_visit_task_rec.ATTRIBUTE11        := l_simul_visit_task_rec.attribute11;
   l_prim_visit_task_rec.ATTRIBUTE12        := l_simul_visit_task_rec.attribute12;
   l_prim_visit_task_rec.ATTRIBUTE13        := l_simul_visit_task_rec.attribute13;
   l_prim_visit_task_rec.ATTRIBUTE14        := l_simul_visit_task_rec.attribute14;
   l_prim_visit_task_rec.ATTRIBUTE15        := l_simul_visit_task_rec.attribute15;
   l_prim_visit_task_rec.VISIT_TASK_NAME    := l_simul_visit_task_rec.visit_task_name;
   l_prim_visit_task_rec.DESCRIPTION        := l_simul_visit_task_rec.description;
   l_prim_visit_task_rec.DEPARTMENT_ID      := l_simul_visit_task_rec.department_id;
   l_prim_visit_task_rec.ITEM_NAME          := l_simul_visit_task_rec.ITEM_NAME;
   l_prim_visit_task_rec.SERIAL_NUMBER      := l_simul_visit_task_rec.SERIAL_NUMBER;
   l_prim_visit_task_rec.QUANTITY           := l_simul_visit_task_rec.QUANTITY; -- Added by rnahata for Issue 105

   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Added two new attributes for past dates
   l_prim_visit_task_rec.PAST_TASK_START_DATE     := l_simul_visit_task_rec.PAST_TASK_START_DATE;
   l_prim_visit_task_rec.PAST_TASK_START_DATE     := l_simul_visit_task_rec.PAST_TASK_END_DATE;


   AHL_VWP_TASKS_PVT.Update_Task
   (
    p_api_version       => p_api_version,
    p_init_msg_list     => Fnd_Api.g_false,
    p_commit            => Fnd_Api.g_false,
    p_validation_level  => p_validation_level,
    --passing null here as we dont want the OrigtaskId,
    --to be picked up as the value we are passing at this point.
    p_module_type       => null,
    p_x_task_rec        => l_prim_visit_task_rec,
    x_return_status     => l_return_status,
    x_msg_count         => l_msg_count,
    x_msg_data          => l_msg_data
   );

   -- Check Error Message stack.
   IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
     l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
     RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

  ELSIF((l_simul_visit_task_rec.primary_visit_task_id IS NULL) OR
      (l_simul_visit_task_rec.primary_visit_task_id IS NOT NULL AND l_primary_visit_task_id IS NULL))
   /* This clause means that
      1. Either the task is deleted from primary visit after copying to simulation visit Or
      2. The task is created in the Simulation visit.
   */
  THEN
   /* Added by mpothuku on 01/11/04 to insert new row into the PrimaryVisit */
   SELECT Ahl_Visit_Tasks_B_S.NEXTVAL INTO
   l_visit_task_id   FROM   dual;

   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'visit call insert new task created in simulation:'||l_simul_visit_task_rec.visit_task_number);
   END IF;

   l_visit_task_number := Get_Visit_Task_Number(l_primary_visit_id,l_simul_visit_task_rec.visit_task_number);
   Ahl_Visit_Tasks_Pkg.INSERT_ROW
   (
    X_ROWID                 => l_rowid,
    X_VISIT_TASK_ID         => l_visit_task_id,
    X_VISIT_TASK_NUMBER     => l_visit_task_number,
    X_OBJECT_VERSION_NUMBER => 1,
    X_VISIT_ID              => l_primary_visit_id,
    X_PROJECT_TASK_ID       => l_simul_visit_task_rec.project_task_id,
    X_COST_PARENT_ID        => null,
    X_MR_ROUTE_ID           => l_simul_visit_task_rec.mr_route_id,
    X_MR_ID                 => l_simul_visit_task_rec.mr_id,
    X_DURATION              => l_simul_visit_task_rec.duration,
    X_UNIT_EFFECTIVITY_ID   => l_simul_visit_task_rec.unit_effectivity_id,
    X_START_FROM_HOUR       => l_simul_visit_task_rec.start_from_hour,
    X_INVENTORY_ITEM_ID     => l_simul_visit_task_rec.inventory_item_id,
    X_ITEM_ORGANIZATION_ID  => l_simul_visit_task_rec.item_organization_id,
    X_INSTANCE_ID           => l_simul_visit_task_rec.instance_id,
    X_PRIMARY_VISIT_TASK_ID => null,
    X_SUMMARY_TASK_FLAG     => l_simul_visit_task_rec.summary_task_flag,
    X_ORIGINATING_TASK_ID   => null,
    X_SERVICE_REQUEST_ID    => l_simul_visit_task_rec.service_request_id,
    X_TASK_TYPE_CODE        => l_simul_visit_task_rec.task_type_code,
    X_PRICE_LIST_ID         => null,
    X_STATUS_CODE           => l_simul_visit_task_rec.status_code,
    X_ESTIMATED_PRICE       => null,
    X_ACTUAL_PRICE          => null,
    X_ACTUAL_COST           => null,
    X_STAGE_ID              => null,
    -- Added cxcheng POST11510-- No Calculation Need for Sim---------
    X_START_DATE_TIME       => l_simul_visit_task_rec.start_date_time,
    X_END_DATE_TIME         => l_simul_visit_task_rec.end_date_time,
    -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Added two new attributes for past dates
    X_PAST_TASK_START_DATE  => l_simul_visit_task_rec.PAST_TASK_START_DATE,
    X_PAST_TASK_END_DATE    => l_simul_visit_task_rec.PAST_TASK_END_DATE,
    X_ATTRIBUTE_CATEGORY    => l_simul_visit_task_rec.attribute_category,
    X_ATTRIBUTE1            => l_simul_visit_task_rec.attribute1,
    X_ATTRIBUTE2            => l_simul_visit_task_rec.attribute2,
    X_ATTRIBUTE3            => l_simul_visit_task_rec.attribute3,
    X_ATTRIBUTE4            => l_simul_visit_task_rec.attribute4,
    X_ATTRIBUTE5            => l_simul_visit_task_rec.attribute5,
    X_ATTRIBUTE6            => l_simul_visit_task_rec.attribute6,
    X_ATTRIBUTE7            => l_simul_visit_task_rec.attribute7,
    X_ATTRIBUTE8            => l_simul_visit_task_rec.attribute8,
    X_ATTRIBUTE9            => l_simul_visit_task_rec.attribute9,
    X_ATTRIBUTE10           => l_simul_visit_task_rec.attribute10,
    X_ATTRIBUTE11           => l_simul_visit_task_rec.attribute11,
    X_ATTRIBUTE12           => l_simul_visit_task_rec.attribute12,
    X_ATTRIBUTE13           => l_simul_visit_task_rec.attribute13,
    X_ATTRIBUTE14           => l_simul_visit_task_rec.attribute14,
    X_ATTRIBUTE15           => l_simul_visit_task_rec.attribute15,
    X_VISIT_TASK_NAME       => l_simul_visit_task_rec.visit_task_name,
    X_DESCRIPTION           => l_simul_visit_task_rec.description,
    X_DEPARTMENT_ID         => l_simul_visit_task_rec.department_id,
    X_QUANTITY              => l_simul_visit_task_rec.quantity, -- Added by rnahata for Issue 105
    X_CREATION_DATE         => SYSDATE,
    X_CREATED_BY            => Fnd_Global.USER_ID,
    X_LAST_UPDATE_DATE      => SYSDATE,
    X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
    X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID
   );
   /* Need to update the simulation_visit's primary_visit_task_id with the Id thats generated here */
   UPDATE ahl_visit_tasks_b
       SET primary_visit_task_id = l_visit_task_id
       WHERE visit_task_id = l_simul_visit_task_rec.visit_task_id;

  END IF;
  /* mpothuku End */
  IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'After insertion of simulation visit task:'||l_simul_visit_task_rec.visit_task_id);
  END IF;
  END LOOP;
  CLOSE simul_visit_task_cur;

  -- For updating the cost_parent_id and originating_task_id
  OPEN simul_visit_task_cur(p_visit_id);
     LOOP
     FETCH simul_visit_task_cur INTO l_simul_visit_task_rec;

  IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'after fetch'||l_simul_visit_task_rec.primary_visit_task_id);
  END IF;

  EXIT WHEN simul_visit_task_cur%NOTFOUND;
  --Check if the task has an originating_task_id /cost_parent_id
  IF(l_simul_visit_task_rec.originating_task_id IS NOT NULL OR
     l_simul_visit_task_rec.cost_parent_id IS NOT NULL OR
     l_simul_visit_task_rec.stage_id IS NOT NULL )
  THEN
   --Get the corresponding task record from the primary visit to update.
   OPEN c_new_primary_task(l_simul_visit_task_rec.visit_task_id);
   FETCH c_new_primary_task INTO l_new_task_id,l_new_task_number;
   CLOSE c_new_primary_task;

   OPEN c_task(l_new_task_id);
   FETCH c_task INTO c_task_rec;
   CLOSE c_task;

   l_prim_visit_task_rec.VISIT_TASK_ID   := c_task_rec.VISIT_TASK_ID;
   l_prim_visit_task_rec.VISIT_TASK_NUMBER  := c_task_rec.VISIT_TASK_NUMBER;
   l_prim_visit_task_rec.VISIT_ID    := l_primary_visit_id;
   l_prim_visit_task_rec.OBJECT_VERSION_NUMBER := c_task_rec.OBJECT_VERSION_NUMBER;
   l_prim_visit_task_rec.PROJECT_TASK_ID  := c_task_rec.PROJECT_TASK_ID;
   l_prim_visit_task_rec.MR_ROUTE_ID   := c_task_rec.MR_ROUTE_ID;
   l_prim_visit_task_rec.MR_ID     := c_task_rec.MR_ID;
   l_prim_visit_task_rec.DURATION    := c_task_rec.DURATION;
   l_prim_visit_task_rec.UNIT_EFFECTIVITY_ID := c_task_rec.UNIT_EFFECTIVITY_ID;
   l_prim_visit_task_rec.START_FROM_HOUR  := c_task_rec.START_FROM_HOUR;
   l_prim_visit_task_rec.INVENTORY_ITEM_ID  := c_task_rec.INVENTORY_ITEM_ID;
   l_prim_visit_task_rec.ITEM_ORGANIZATION_ID := c_task_rec.ITEM_ORGANIZATION_ID;
   l_prim_visit_task_rec.INSTANCE_ID   := c_task_rec.INSTANCE_ID;
   l_prim_visit_task_rec.PRIMARY_VISIT_TASK_ID := null;
   l_prim_visit_task_rec.SERVICE_REQUEST_ID := c_task_rec.SERVICE_REQUEST_ID;
   l_prim_visit_task_rec.TASK_TYPE_CODE  := c_task_rec.TASK_TYPE_CODE;
   l_prim_visit_task_rec.TASK_STATUS_CODE  := c_task_rec.STATUS_CODE;
   l_prim_visit_task_rec.ATTRIBUTE_CATEGORY    := c_task_rec.ATTRIBUTE_CATEGORY;
   l_prim_visit_task_rec.ATTRIBUTE1            := c_task_rec.attribute1;
   l_prim_visit_task_rec.ATTRIBUTE2            := c_task_rec.attribute2;
   l_prim_visit_task_rec.ATTRIBUTE3            := c_task_rec.attribute3;
   l_prim_visit_task_rec.ATTRIBUTE4            := c_task_rec.attribute4;
   l_prim_visit_task_rec.ATTRIBUTE5            := c_task_rec.attribute5;
   l_prim_visit_task_rec.ATTRIBUTE6            := c_task_rec.attribute6;
   l_prim_visit_task_rec.ATTRIBUTE7            := c_task_rec.attribute7;
   l_prim_visit_task_rec.ATTRIBUTE8            := c_task_rec.attribute8;
   l_prim_visit_task_rec.ATTRIBUTE9            := c_task_rec.attribute9;
   l_prim_visit_task_rec.ATTRIBUTE10           := c_task_rec.attribute10;
   l_prim_visit_task_rec.ATTRIBUTE11           := c_task_rec.attribute11;
   l_prim_visit_task_rec.ATTRIBUTE12           := c_task_rec.attribute12;
   l_prim_visit_task_rec.ATTRIBUTE13           := c_task_rec.attribute13;
   l_prim_visit_task_rec.ATTRIBUTE14           := c_task_rec.attribute14;
   l_prim_visit_task_rec.ATTRIBUTE15           := c_task_rec.attribute15;
   l_prim_visit_task_rec.VISIT_TASK_NAME       := c_task_rec.visit_task_name;
   l_prim_visit_task_rec.DESCRIPTION           := c_task_rec.description;
   l_prim_visit_task_rec.DEPARTMENT_ID         := c_task_rec.department_id;
   l_prim_visit_task_rec.ITEM_NAME    := l_simul_visit_task_rec.ITEM_NAME;
   l_prim_visit_task_rec.SERIAL_NUMBER   := l_simul_visit_task_rec.SERIAL_NUMBER;
   l_prim_visit_task_rec.ORIGINATING_TASK_ID   := null;
   l_prim_visit_task_rec.ORGINATING_TASK_NUMBER:= null;
   l_prim_visit_task_rec.COST_PARENT_ID  := null;
   l_prim_visit_task_rec.COST_PARENT_NUMBER := null;
   l_prim_visit_task_rec.STAGE_ID    := null;
   l_prim_visit_task_rec.STAGE_NAME   := null;

   IF(l_simul_visit_task_rec.ORIGINATING_TASK_ID IS NOT NULL) THEN
    OPEN c_new_primary_task(l_simul_visit_task_rec.ORIGINATING_TASK_ID);
    FETCH c_new_primary_task INTO l_new_task_id,l_new_task_number;
    CLOSE c_new_primary_task;
    l_prim_visit_task_rec.ORIGINATING_TASK_ID := l_new_task_id;
    l_prim_visit_task_rec.ORGINATING_TASK_NUMBER := l_new_task_number;
   END IF;

   IF(l_simul_visit_task_rec.COST_PARENT_ID IS NOT NULL) THEN
    OPEN c_new_primary_task(l_simul_visit_task_rec.COST_PARENT_ID);
    FETCH c_new_primary_task INTO l_new_task_id,l_new_task_number;
    CLOSE c_new_primary_task;
    l_prim_visit_task_rec.COST_PARENT_ID := l_new_task_id;
    l_prim_visit_task_rec.COST_PARENT_NUMBER := l_new_task_number;
   END IF;

   IF(l_simul_visit_task_rec.STAGE_ID IS NOT NULL) THEN
    OPEN c_new_stage(l_simul_visit_task_rec.STAGE_ID,l_primary_visit_id);
    FETCH c_new_stage INTO l_new_stage_id,l_new_stage_name;
    CLOSE c_new_stage;
    l_prim_visit_task_rec.STAGE_ID := l_new_stage_id;
    l_prim_visit_task_rec.STAGE_NAME := l_new_stage_name;
   END IF;


   AHL_VWP_TASKS_PVT.Update_Task
   (
    p_api_version       => p_api_version,
    p_init_msg_list     => Fnd_Api.g_false,
    p_commit            => Fnd_Api.g_false,
    p_validation_level  => p_validation_level,
    --passing LTP here as we want the OrigtaskId,
    --to be picked up as the value we are passing.
    p_module_type       => 'LTP',
    p_x_task_rec        => l_prim_visit_task_rec,
    x_return_status     => l_return_status,
    x_msg_count         => l_msg_count,
    x_msg_data          => l_msg_data
   );

   -- Check Error Message stack.
   IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
     l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
     RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
  END IF;
  END LOOP;
  CLOSE simul_visit_task_cur;

  /*Added by mpothuku to Copy the Task Links back to the Primary Visit */
  --Remove task links from the Primary Visit.
  OPEN check_exist_visit_task_cur (l_primary_visit_id);
  LOOP
  FETCH check_exist_visit_task_cur INTO l_exist_prim_visit_task_id;
  EXIT WHEN check_exist_visit_task_cur%NOTFOUND;

   /* Added by mpothuku on 01/11/04 to delete the existing links */
   OPEN c_links (l_exist_prim_visit_task_id);
   FETCH c_links INTO l_count;
   IF l_count > 0 THEN
    DELETE Ahl_Task_Links
    WHERE VISIT_TASK_ID = l_exist_prim_visit_task_id
       OR PARENT_TASK_ID = l_exist_prim_visit_task_id;
   END IF;
   CLOSE c_links;
  END LOOP;
  CLOSE check_exist_visit_task_cur;

   /* Copy the Links from Simulation Visit */
  OPEN c_visit_task_links(p_visit_id);
  LOOP
     FETCH c_visit_task_links INTO l_task_link_rec;
     EXIT WHEN c_visit_task_links%NOTFOUND;

     -- Find coresponding task id in new visit
     OPEN c_new_primary_task(l_task_link_rec.visit_task_id);
     FETCH c_new_primary_task INTO l_new_task_id,l_new_task_number;
     CLOSE c_new_primary_task;

     OPEN c_new_primary_task(l_task_link_rec.parent_task_id);
     FETCH c_new_primary_task INTO l_new_parent_task_id,l_new_task_number;
     CLOSE c_new_primary_task;

     -- Create task link
     INSERT INTO AHL_TASK_LINKS
     (
    TASK_LINK_ID,
    OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    VISIT_TASK_ID,
    PARENT_TASK_ID,
    --SECURITY_GROUP_ID,
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
    )
    values
    (
    ahl_task_links_s.nextval,
    1,
    SYSDATE,
    Fnd_Global.USER_ID,
    SYSDATE,
    Fnd_Global.USER_ID,
    Fnd_Global.USER_ID,
    l_new_task_id,
    l_new_parent_task_id,
    --l_task_link_rec.SECURITY_GROUP_ID,
    l_task_link_rec.ATTRIBUTE_CATEGORY,
    l_task_link_rec.ATTRIBUTE1,
    l_task_link_rec.ATTRIBUTE2,
    l_task_link_rec.ATTRIBUTE3,
    l_task_link_rec.ATTRIBUTE4,
    l_task_link_rec.ATTRIBUTE5,
    l_task_link_rec.ATTRIBUTE6,
    l_task_link_rec.ATTRIBUTE7,
    l_task_link_rec.ATTRIBUTE8,
    l_task_link_rec.ATTRIBUTE9,
    l_task_link_rec.ATTRIBUTE10,
    l_task_link_rec.ATTRIBUTE11,
    l_task_link_rec.ATTRIBUTE12,
    l_task_link_rec.ATTRIBUTE13,
    l_task_link_rec.ATTRIBUTE14,
    l_task_link_rec.ATTRIBUTE15
   );
  END LOOP;
  CLOSE c_visit_task_links;

  --Copying the Stages Back to the Primary Visit
  OPEN Get_stages_cur(p_visit_id);
  LOOP
   FETCH Get_stages_cur INTO l_stage_rec;
   EXIT WHEN Get_stages_cur%NOTFOUND;
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'inside loop stage num:'||l_stage_rec.stage_num);
   END IF;

   -- Get Stage id of the primary Visit that has to be updated
   OPEN c_new_stage(l_stage_rec.stage_id,l_primary_visit_id);
   FETCH c_new_stage INTO l_new_stage_id,l_new_stage_name;
   CLOSE c_new_stage;

   --
     IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'visit call update stage:'||l_stage_rec.stage_id);
     END IF;
     /* Copy the details in the Simulation Visit */
   -- Invoke the table handler to update a record
     Ahl_VWP_Stages_Pkg.Update_Row (
    X_VISIT_ID              => l_primary_visit_id,
    X_STAGE_ID              => l_new_stage_id,
    X_STAGE_NUM             => l_stage_rec.Stage_Num,
    X_STAGE_NAME            => l_stage_rec.Stage_Name,
    X_DURATION              => l_stage_rec.Duration,
    X_OBJECT_VERSION_NUMBER => l_stage_rec.object_version_number+1,
    X_ATTRIBUTE_CATEGORY    => l_stage_rec.ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1            => l_stage_rec.ATTRIBUTE1,
    X_ATTRIBUTE2            => l_stage_rec.ATTRIBUTE2,
    X_ATTRIBUTE3            => l_stage_rec.ATTRIBUTE3,
    X_ATTRIBUTE4            => l_stage_rec.ATTRIBUTE4,
    X_ATTRIBUTE5            => l_stage_rec.ATTRIBUTE5,
    X_ATTRIBUTE6            => l_stage_rec.ATTRIBUTE6,
    X_ATTRIBUTE7            => l_stage_rec.ATTRIBUTE7,
    X_ATTRIBUTE8            => l_stage_rec.ATTRIBUTE8,
    X_ATTRIBUTE9            => l_stage_rec.ATTRIBUTE9 ,
    X_ATTRIBUTE10           => l_stage_rec.ATTRIBUTE10,
    X_ATTRIBUTE11           => l_stage_rec.ATTRIBUTE11,
    X_ATTRIBUTE12           => l_stage_rec.ATTRIBUTE12,
    X_ATTRIBUTE13           => l_stage_rec.ATTRIBUTE13,
    X_ATTRIBUTE14           => l_stage_rec.ATTRIBUTE14,
    X_ATTRIBUTE15           => l_stage_rec.ATTRIBUTE15,
    X_LAST_UPDATE_DATE      => SYSDATE,
    X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
    X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID );

   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.Debug( l_full_name ||': Visit ID =' || l_primary_visit_id);
    AHL_DEBUG_PUB.Debug( l_full_name ||': Stage Number =' ||  l_stage_rec.Stage_Num);
   END IF;
  END LOOP;
  CLOSE Get_stages_cur;

  IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'before delete simulation visit:'||p_visit_id);
  END IF;

  --To adjust the task times for the inserted/updated tasks
  AHL_VWP_TIMES_PVT.Calculate_Task_Times
  (
   p_api_version      => p_api_version,
   p_init_msg_list    => Fnd_Api.G_FALSE,
   p_commit           => Fnd_Api.G_FALSE,
   p_validation_level => p_validation_level,
   x_return_status    => l_return_status,
   x_msg_count        => l_msg_count,
   x_msg_data         => l_msg_data,
   p_visit_id         => l_primary_visit_id
  );

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string
   (
    fnd_log.level_statement,
    'ahl.plsql.'||L_FULL_NAME,
    'After calling AHL_VWP_TIMES_PVT.Calculate_Task_Times'
   );
  END IF;

  IF l_msg_count > 0 OR l_return_status <> Fnd_Api.g_ret_sts_success THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- anraj for fixing the issue number 207 in the CMRO Forum
  -- If none of the Org,dept and start date are null then Process_Planned_Materials is called with 'U'
  -- Else Process_Planned_Materials is called with the 'D' flag.
  OPEN c_visit_details_for_materials(l_primary_visit_id);
  FETCH c_visit_details_for_materials INTO l_visit_details_for_materials;
  CLOSE c_visit_details_for_materials;

  IF (  l_visit_details_for_materials.organization_id IS NOT NULL AND
    l_visit_details_for_materials.department_id IS NOT NULL AND
    l_visit_details_for_materials.start_date_time IS NOT NULL)
  THEN
   --Schedule material Reqmts in the Primary Visit for tasks created newly.
   AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials
   (
    p_api_version        => p_api_version,
    p_init_msg_list      => FND_API.g_false,
    p_commit             => FND_API.g_false,
    p_validation_level   => p_validation_level,--FND_API.g_valid_level_full,
    p_visit_id           => l_primary_visit_id,
    p_visit_task_id      => NULL,
    p_org_id             => NULL,
    p_start_date         => NULL,
    p_operation_flag     => 'U',
    x_planned_order_flag => l_planned_order_flag ,
    x_return_status      => l_return_status,
    x_msg_count          => l_msg_count,
    x_msg_data           => l_msg_data
   );
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string
    (
     fnd_log.level_statement,
     'ahl.plsql.'||L_FULL_NAME,
     ' After calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials With p_operation_flag U '
    );
   END IF;
  ELSE
   AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials
   (
    p_api_version        => p_api_version,
    p_init_msg_list      => FND_API.g_false,
    p_commit             => FND_API.g_false,
    p_validation_level   => p_validation_level,--FND_API.g_valid_level_full,
    p_visit_id           => l_primary_visit_id,
    p_visit_task_id      => NULL,
    p_org_id             => NULL,
    p_start_date         => NULL,
    p_operation_flag     => 'D',
    x_planned_order_flag => l_planned_order_flag ,
    x_return_status      => l_return_status,
    x_msg_count          => l_msg_count,
    x_msg_data           => l_msg_data
   );
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string
    (
     fnd_log.level_statement,
     'ahl.plsql.'||L_FULL_NAME,
     ' After calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials With p_operation_flag D '
    );
   END IF;
  END IF;

  -- modification end

  IF l_msg_count > 0 OR l_return_status <> Fnd_Api.g_ret_sts_success THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Only if Simulation Flag is not set we ought to delete the Simulation Visit otherwise it
   anyway be deleted in process Visit
  */

  Remove_Visits_FR_Plan
  (
     p_api_version      => p_api_version,
     p_init_msg_list    => FND_API.g_false,--p_init_msg_list,
     p_commit           => FND_API.g_false, --p_commit,
     p_validation_level => p_validation_level,
     p_module_type      => p_module_type,
     p_visit_id         => p_visit_id,
     p_plan_id          => null,
     p_v_ovn            => null,
     x_return_status    => l_return_status,
     x_msg_count        => l_msg_count,
     x_msg_data         => l_msg_data
    );
 END IF;

 --mpothuku End

 -- Check Error Message stack.
 IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
 l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
   END IF;
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
   Ahl_Debug_Pub.debug( 'End of private api Set visit Primary','+SMPLN+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;
   --
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO set_visit_as_primary;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt. set visit as primary','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO set_visit_as_primary;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.set visit as primary','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN OTHERS THEN
    ROLLBACK TO set_visit_as_primary;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PVT',
                            p_procedure_name  =>  'SET_VISIT_AS_PRIMARY',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt. set visit as primary','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
END Set_Visit_As_Primary;
--
--------------------------------------------------------------------
-- PROCEDURE
--    Delet_Simul_Visits
--
-- PURPOSE
--    Procedure will be used to remove all the simulated visits. Will be
--    Called from VWP beofre visit has been pushed to production
--
-- PARAMETERS
--    p_visit_id                    : Primary Visit Id
--
-- NOTES
--------------------------------------------------------------------

PROCEDURE Delete_Simul_Visits (
   p_api_version      IN      NUMBER,
   p_init_msg_list    IN      VARCHAR2  := FND_API.g_false,
   p_commit           IN      VARCHAR2  := FND_API.g_false,
   p_validation_level IN      NUMBER    := FND_API.g_valid_level_full,
   p_visit_id         IN      NUMBER,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2)
  --
  IS
  -- Get visits belongs to simulation plans
  CURSOR Get_simul_visits_cur (C_VISIT_ID IN NUMBER)
     IS
  SELECT vt.visit_id, vt.visit_number,
         vt.asso_primary_visit_id
    FROM ahl_visits_vl vt, ahl_simulation_plans_vl sp
   WHERE vt.simulation_plan_id = sp.simulation_plan_id
     AND sp.primary_plan_flag = 'N'
     AND vt.asso_primary_visit_id = C_VISIT_ID;
  -- Get all the associated tasks
  CURSOR Get_simul_visit_tasks_cur(C_VISIT_ID IN NUMBER)
    IS
 SELECT visit_task_id
  FROM ahl_visit_tasks_vl
  WHERE visit_id = C_VISIT_ID;

  --

  l_api_name     CONSTANT VARCHAR2(30) := 'DELETE_SIMUL_VISITS';
  l_api_version  CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);
  l_simul_visits_rec      Get_simul_visits_cur%ROWTYPE;
  l_simul_visit_tasks_rec Get_simul_visit_tasks_cur%ROWTYPE;
  l_visit_tbl             AHL_VWP_VISITS_PVT.Visit_Tbl_Type;
  l_visit_count           NUMBER := 0;
  l_count                 NUMBER;
  l_space_assignment_id   NUMBER;
  --
BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT Delete_Simul_Visits;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'enter ahl_ltp_simul_plan_pvt.Delete Simul Visits','+SMPNL+');
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

    ---------------------start API Body----------------------------------------
  /* Changes made by mpothuku on 12/22/04 to call the VWP API instead of
  direct deletion of tasks and Visits */
  -- Changes by mpothuku Begin
  -- Get all the visits associated
  OPEN Get_simul_visits_cur(p_visit_id);
  LOOP
     FETCH Get_simul_visits_cur INTO l_simul_visits_rec;
     EXIT WHEN Get_simul_visits_cur%NOTFOUND;
     IF l_simul_visits_rec.visit_id IS NOT NULL THEN
        Remove_Visits_FR_Plan (
            p_api_version      => p_api_version,
            p_init_msg_list    =>  FND_API.g_false,--p_init_msg_list,
            p_commit           => FND_API.g_false, --p_commit,
            p_validation_level => p_validation_level,
            p_module_type      => NULL,
            p_visit_id         => l_simul_visits_rec.visit_id,
            p_plan_id          => null,
            p_v_ovn            => null,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data);

        -- Check Error Message stack.
        IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
           l_msg_count := FND_MSG_PUB.count_msg;
           IF l_msg_count > 0 THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
     END IF; -- Visit not null
  END LOOP;
  CLOSE Get_simul_visits_cur;
  --
  -- mpothuku End
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
   Ahl_Debug_Pub.debug( 'End of private api Delete_Simul_Visits','+SMPLN+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;
   --
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Delete_Simul_Visits;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt. Delete Simul Visits','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Delete_Simul_Visits;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        -- Debug info.
   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt.Delete Simul Visits','+SMPLN+');
        END IF;
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

WHEN OTHERS THEN
    ROLLBACK TO Delete_Simul_Visits;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SIMUL_PLAN_PVT',
                            p_procedure_name  =>  'DELETE_SIMUL_VISITS',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   -- Debug info.
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.log_app_messages (
      x_msg_count, x_msg_data, 'SQL ERROR' );
      AHL_DEBUG_PUB.debug( 'ahl_ltp_simul_plan_pvt. Delete Simul Visits','+SMPLN+');
   END IF;
   -- Check if API is called in debug mode. If yes, disable debug.
   AHL_DEBUG_PUB.disable_debug;

END Delete_Simul_Visits;


--
END AHL_LTP_SIMUL_PLAN_PVT;

/
