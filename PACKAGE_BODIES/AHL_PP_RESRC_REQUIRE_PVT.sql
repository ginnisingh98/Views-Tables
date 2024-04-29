--------------------------------------------------------
--  DDL for Package Body AHL_PP_RESRC_REQUIRE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PP_RESRC_REQUIRE_PVT" AS
/* $Header: AHLVREQB.pls 120.12.12010000.8 2010/04/20 12:27:36 pekambar ship $*/

----------------------------------------------
-- Declare Constants --
-----------------------
G_PKG_NAME         VARCHAR2(30):= 'AHL_PP_RESRC_REQUIRE_PVT';
G_MODULE_TYPE      VARCHAR2(30);
G_DEBUG            VARCHAR2(1) := AHL_DEBUG_PUB.is_log_enabled;

-------------------------------------------------
-- Declare Locally used Record and Table Types --
-------------------------------------------------

-------------------------------------------------
-- Declare Local Procedures                    --
-------------------------------------------------
-- Process_Resrc_Require       -- Remove_Resource_Requirement
-- Get_Resource_Requirement    -- Update_Resrc_Require
                               -- Create_Resrc_Require


--------------------------------------------------------------------
-- PROCEDURE
--    Check_Lookup_Name_Or_Id
--
-- PURPOSE
--    Converts Lookup Name/Code to ID/Value or Vice versa
--------------------------------------------------------------------
PROCEDURE Check_Lookup_Name_Or_Id
 ( p_lookup_type      IN MFG_LOOKUPS.lookup_type%TYPE,
   p_lookup_code      IN MFG_LOOKUPS.lookup_code%TYPE,
   p_meaning          IN MFG_LOOKUPS.meaning%TYPE,
   p_check_id_flag    IN VARCHAR2,

   x_lookup_code      OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2)
IS
BEGIN
  IF (p_lookup_code IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT lookup_code INTO x_lookup_code
           FROM MFG_LOOKUPS
          WHERE lookup_type = p_lookup_type
            AND lookup_code = p_lookup_code
            AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
            AND TRUNC(NVL(end_date_active,SYSDATE));
        ELSE
           x_lookup_code := p_lookup_code;
        END IF;
  ELSE
        SELECT lookup_code INTO x_lookup_code
           FROM MFG_LOOKUPS
          WHERE lookup_type = p_lookup_type
            AND meaning = p_meaning
            AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
            AND TRUNC(NVL(end_date_active,SYSDATE));
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

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Serial_Name_Or_Id
--
-- PURPOSE
--    Converts Serial Name to ID or Vice versa
--------------------------------------------------------------------
PROCEDURE Check_Serial_Name_Or_Id
    (p_serial_id        IN NUMBER,
     p_serial_number    IN VARCHAR2,

     x_serial_id        OUT NOCOPY NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_error_msg_code   OUT NOCOPY VARCHAR2
     )
IS
BEGIN
   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug( ': Inside Check  Serial Number= ' || p_serial_number);
    END IF;

    IF (p_serial_number IS NOT NULL) THEN
           SELECT instance_id
              INTO x_serial_id
            FROM BOM_DEPT_RES_INSTANCES
          WHERE SERIAL_NUMBER  = p_serial_number;
    END IF;
   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug(': Inside Check Serial Id= ' || x_serial_id);
   END IF;

    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_SERIAL_NOT_EXISTS';
    WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_SERIAL_NOT_EXISTS';
    WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_Serial_Name_Or_Id;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Resource_Name_Or_Id
--
-- PURPOSE
--    Converts Resource Name to ID or Vice versa
--------------------------------------------------------------------
PROCEDURE Check_Resource_Name_Or_Id
    (p_resource_id      IN NUMBER,
     p_resource_code    IN VARCHAR2,
     p_workorder_id     IN NUMBER,

     x_resource_id      OUT NOCOPY NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_error_msg_code   OUT NOCOPY VARCHAR2
     )
IS
BEGIN
    IF (p_resource_code IS NOT NULL) THEN
        SELECT DISTINCT(BR.RESOURCE_ID)
          INTO x_resource_id
            FROM BOM_RESOURCES BR, BOM_DEPARTMENT_RESOURCES BDR, AHL_WORKORDER_OPERATIONS_V AWV
        WHERE BR.RESOURCE_ID = BDR.RESOURCE_ID AND BDR.DEPARTMENT_ID = AWV.DEPARTMENT_ID
        AND AWV.WORKORDER_ID = p_workorder_id AND BR.RESOURCE_CODE = p_resource_code;
    END IF;

   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug(': Inside Check Resource Id= ' || x_Resource_id);
   END IF;

    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_RESOURCE_NOT_EXISTS';
    WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_PP_RESOURCE_NOT_EXISTS';
    WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_Resource_Name_Or_Id;

--------------------------------------------------------------------
-- PROCEDURE
--       Insert_Row
---------------------------------------------------------------------
PROCEDURE Insert_Row (
  X_OPERATION_RESOURCE_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_LAST_UPDATE_DATE      IN DATE,
  X_LAST_UPDATED_BY       IN NUMBER,
  X_CREATION_DATE         IN DATE,
  X_CREATED_BY            IN NUMBER,
  X_LAST_UPDATE_LOGIN     IN NUMBER,
  X_RESOURCE_ID           IN NUMBER,
  X_WORKORDER_OPERATION_ID IN NUMBER,
  X_RESOURCE_SEQ_NUMBER   IN NUMBER,
  X_UOM_CODE              IN VARCHAR2,
  X_QUANTITY              IN NUMBER,
  X_DURATION              IN NUMBER,
  X_SCHEDULED_START_DATE  IN DATE,
  X_SCHEDULED_END_DATE    IN DATE,
  X_ATTRIBUTE_CATEGORY    IN VARCHAR2,
  X_ATTRIBUTE1            IN VARCHAR2,
  X_ATTRIBUTE2            IN VARCHAR2,
  X_ATTRIBUTE3            IN VARCHAR2,
  X_ATTRIBUTE4            IN VARCHAR2,
  X_ATTRIBUTE5            IN VARCHAR2,
  X_ATTRIBUTE6            IN VARCHAR2,
  X_ATTRIBUTE7            IN VARCHAR2,
  X_ATTRIBUTE8            IN VARCHAR2,
  X_ATTRIBUTE9            IN VARCHAR2,
  X_ATTRIBUTE10           IN VARCHAR2,
  X_ATTRIBUTE11           IN VARCHAR2,
  X_ATTRIBUTE12           IN VARCHAR2,
  X_ATTRIBUTE13           IN VARCHAR2,
  X_ATTRIBUTE14           IN VARCHAR2,
  X_ATTRIBUTE15           IN VARCHAR2
) IS
BEGIN
  INSERT INTO AHL_OPERATION_RESOURCES (
    OPERATION_RESOURCE_ID,
    OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    RESOURCE_ID ,
    WORKORDER_OPERATION_ID ,
    RESOURCE_SEQUENCE_NUM ,
    --UOM,
    QUANTITY ,
    DURATION ,
    SCHEDULED_START_DATE,
    SCHEDULED_END_DATE,
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
    ATTRIBUTE15 )
  VALUES(
    X_OPERATION_RESOURCE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_RESOURCE_ID ,
    X_WORKORDER_OPERATION_ID ,
    X_RESOURCE_SEQ_NUMBER ,
    --X_UOM_CODE ,
    X_QUANTITY ,
    X_DURATION ,
    X_SCHEDULED_START_DATE ,
    X_SCHEDULED_END_DATE ,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15);

END Insert_Row;

---------------------------------------------------------------------
-- PROCEDURE
--       Update_Row
---------------------------------------------------------------------
PROCEDURE UPDATE_ROW (
  X_OPERATION_RESOURCE_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_RESOURCE_ID           IN NUMBER,
  X_WORKORDER_OPERATION_ID IN NUMBER,
  X_RESOURCE_SEQ_NUMBER   IN NUMBER,
  X_UOM_CODE              IN VARCHAR2,
  X_QUANTITY              IN NUMBER,
  X_DURATION              IN NUMBER,
  X_SCHEDULED_START_DATE  IN DATE,
  X_SCHEDULED_END_DATE    IN DATE,
  X_ATTRIBUTE_CATEGORY    IN VARCHAR2,
  X_ATTRIBUTE1            IN VARCHAR2,
  X_ATTRIBUTE2            IN VARCHAR2,
  X_ATTRIBUTE3            IN VARCHAR2,
  X_ATTRIBUTE4            IN VARCHAR2,
  X_ATTRIBUTE5            IN VARCHAR2,
  X_ATTRIBUTE6            IN VARCHAR2,
  X_ATTRIBUTE7            IN VARCHAR2,
  X_ATTRIBUTE8            IN VARCHAR2,
  X_ATTRIBUTE9            IN VARCHAR2,
  X_ATTRIBUTE10           IN VARCHAR2,
  X_ATTRIBUTE11           IN VARCHAR2,
  X_ATTRIBUTE12           IN VARCHAR2,
  X_ATTRIBUTE13           IN VARCHAR2,
  X_ATTRIBUTE14           IN VARCHAR2,
  X_ATTRIBUTE15           IN VARCHAR2,
  X_LAST_UPDATE_DATE      IN DATE,
  X_LAST_UPDATED_BY       IN NUMBER,
  X_LAST_UPDATE_LOGIN     IN NUMBER
)
IS

BEGIN
  UPDATE AHL_OPERATION_RESOURCES SET
    OBJECT_VERSION_NUMBER           = X_OBJECT_VERSION_NUMBER + 1,
    RESOURCE_ID                     = X_RESOURCE_ID ,
    WORKORDER_OPERATION_ID          = X_WORKORDER_OPERATION_ID ,
    RESOURCE_SEQUENCE_NUM           = X_RESOURCE_SEQ_NUMBER ,
    --UOM                             = X_UOM_CODE ,
    QUANTITY                        = X_QUANTITY ,
    DURATION                        = X_DURATION ,
    SCHEDULED_START_DATE            = X_SCHEDULED_START_DATE ,
    SCHEDULED_END_DATE              = X_SCHEDULED_END_DATE ,
    ATTRIBUTE_CATEGORY              = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1                      = X_ATTRIBUTE1,
    ATTRIBUTE2                      = X_ATTRIBUTE2,
    ATTRIBUTE3                      = X_ATTRIBUTE3,
    ATTRIBUTE4                      = X_ATTRIBUTE4,
    ATTRIBUTE5                      = X_ATTRIBUTE5,
    ATTRIBUTE6                      = X_ATTRIBUTE6,
    ATTRIBUTE7                      = X_ATTRIBUTE7,
    ATTRIBUTE8                      = X_ATTRIBUTE8,
    ATTRIBUTE9                      = X_ATTRIBUTE9,
    ATTRIBUTE10                     = X_ATTRIBUTE10,
    ATTRIBUTE11                     = X_ATTRIBUTE11,
    ATTRIBUTE12                     = X_ATTRIBUTE12,
    ATTRIBUTE13                     = X_ATTRIBUTE13,
    ATTRIBUTE14                     = X_ATTRIBUTE14,
    ATTRIBUTE15                     = X_ATTRIBUTE15,
    LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN
    WHERE OPERATION_RESOURCE_ID     = X_OPERATION_RESOURCE_ID
    AND OBJECT_VERSION_NUMBER       = X_OBJECT_VERSION_NUMBER;

END UPDATE_ROW;

---------------------------------------------------------------------
-- PROCEDURE
--       Delete_Row
---------------------------------------------------------------------
PROCEDURE DELETE_ROW (
  X_OPERATION_RESOURCE_ID IN NUMBER
) IS
BEGIN
  DELETE FROM AHL_OPERATION_RESOURCES
  WHERE OPERATION_RESOURCE_ID = X_OPERATION_RESOURCE_ID;
END DELETE_ROW;

---------------------------------------------------------------------
-- PROCEDURE
--       Check_Resrc_Require_Req_Items
---------------------------------------------------------------------
PROCEDURE Check_Resrc_Require_Req_Items (
   p_resrc_Require_rec    IN    Resrc_Require_Rec_Type,
   x_return_status       OUT   NOCOPY VARCHAR2
)
IS
   l_Require_start_date   DATE;
   l_Require_end_date     DATE;
   l_eff_st_date          DATE;
   l_eff_end_date         DATE;
   l_sch_st_date          DATE;
   l_sch_end_date         DATE;

-- To find all information from AHL_OPERATION_RESOURCES view
  CURSOR c_oper_req (x_id IN NUMBER) IS
   SELECT * FROM AHL_OPERATION_RESOURCES
   WHERE OPERATION_RESOURCE_ID = x_id;
   c_oper_req_rec c_oper_req%ROWTYPE;

 -- Cursor to check
 /*CURSOR c_wo_oper (x_id IN NUMBER) IS
   SELECT TO_DATE(ACTUAL_START_DATE,'DD-MM-YYYY'), TO_DATE(ACTUAL_END_DATE,'DD-MM-YYYY'),
          TO_DATE(SCHEDULED_START_DATE,'DD-MM-YYYY'), TO_DATE(SCHEDULED_END_DATE,'DD-MM-YYYY')
   FROM AHL_WORKORDER_OPERATIONS_V WHERE WORKORDER_OPERATION_ID = x_id;*/
-- bug 4092197
-- no point in doing a date conversion on a date value
-- if the intent was to lose the time portion, then the trunc function can be used
-- but do not need to use trunc function
-- since the date comparisons between resource start/end dates and operation start/end dates
-- are already taken care of in the calling APIs (create and update)
-- by assigning the operation time stamp to the resource dates
-- of the trunc(resource_date) = trunc(operation_date)
CURSOR c_wo_oper (x_id IN NUMBER) IS
   SELECT ACTUAL_START_DATE, ACTUAL_END_DATE,
          SCHEDULED_START_DATE, SCHEDULED_END_DATE
   FROM AHL_WORKORDER_OPERATIONS_V WHERE WORKORDER_OPERATION_ID = x_id;

BEGIN
   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '--Operation ID =' || p_resrc_Require_rec.OPERATION_RESOURCE_ID);
    Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || 'WORKORDER_OPERATION_ID = ' || p_resrc_Require_rec.WORKORDER_OPERATION_ID);
    Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || 'Resource ID = ' || p_resrc_Require_rec.Resource_Id);
   END IF;

IF p_resrc_Require_rec.OPERATION_RESOURCE_ID = Fnd_Api.G_MISS_NUM OR p_resrc_Require_rec.OPERATION_RESOURCE_ID IS NULL THEN
   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug('Inside Check_Resrc_Require_Req_Items check while adding');
   END IF;
      -- OPERATION_SEQ_NUMBER
    IF (p_resrc_Require_rec.OPERATION_SEQ_NUMBER IS NULL OR p_resrc_Require_rec.OPERATION_SEQ_NUMBER = Fnd_Api.G_MISS_NUM) THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         IF G_DEBUG='Y' THEN
          Ahl_Debug_Pub.debug ( 'OPERATION_SEQUENCE NUMBER PROB');
		  END IF;
         Fnd_Message.set_name ('AHL', 'AHL_PP_OPER_SEQ_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;

     -- OPERATION_SEQ_NUMBER - Positive
   IF (p_resrc_Require_rec.OPERATION_SEQ_NUMBER IS NOT NULL AND p_resrc_Require_rec.OPERATION_SEQ_NUMBER <> Fnd_Api.G_MISS_NUM) THEN
      IF p_resrc_Require_rec.OPERATION_SEQ_NUMBER < 0 THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
              IF G_DEBUG='Y' THEN
                    Ahl_Debug_Pub.debug ( 'ONLY POSITIVE');
                END IF;
		     Fnd_Message.set_name ('AHL', 'AHL_PP_ONLY_POSITIVE_VALUE');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;

     -- RESOURCE_SEQ_NUMBER
   IF (p_resrc_Require_rec.RESOURCE_SEQ_NUMBER IS NULL OR p_resrc_Require_rec.RESOURCE_SEQ_NUMBER = Fnd_Api.G_MISS_NUM) THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_RESRC_SEQ_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;

   -- RESOURCE_SEQ_NUMBER -- Positive / Multiples of 10
   IF (p_resrc_Require_rec.RESOURCE_SEQ_NUMBER IS NOT NULL AND p_resrc_Require_rec.RESOURCE_SEQ_NUMBER <> Fnd_Api.G_MISS_NUM) THEN
      IF p_resrc_Require_rec.RESOURCE_SEQ_NUMBER < 0 THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_PP_ONLY_POSITIVE_VALUE');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
      END IF;

      IF (p_resrc_Require_rec.RESOURCE_SEQ_NUMBER mod 10) <> 0 THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_PP_RESRC_SEQ_MULTI_OF_TEN');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;
END IF;

   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || 'Check other valid fileds');
   END IF;
   -- Schedule seq number validation
 	-- JKJAIN US space FP for ER # 6998882-- start
 	    IF (
 	         p_resrc_Require_rec.schedule_seq_num IS NOT NULL AND
 	         p_resrc_Require_rec.schedule_seq_num <> Fnd_Api.G_MISS_NUM
 	       )
 	    THEN

 	      IF (
 	          p_resrc_Require_rec.schedule_seq_num < 0 OR
 	          TRUNC(p_resrc_Require_rec.schedule_seq_num) <> p_resrc_Require_rec.schedule_seq_num
 	         )
 	      THEN

 	               IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
 	                  Fnd_Message.set_name ('AHL', 'AHL_COM_SCHED_SEQ_INV');
 	                  Fnd_Msg_Pub.ADD;
 	               END IF;
 	               x_return_status := Fnd_Api.g_ret_sts_error;
 	               RETURN;

 	      END IF;

 	    END IF;
 	-- JKJAIN US space FP for ER # 6998882 end

   IF g_MODULE_TYPE='JSP' THEN

   IF p_Resrc_Require_Rec.RESOURCE_NAME IS NULL OR p_Resrc_Require_Rec.RESOURCE_NAME = Fnd_Api.G_MISS_CHAR THEN
      IF G_DEBUG='Y' THEN
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- RESOURCE_NAME ='|| p_resrc_Require_rec.RESOURCE_NAME);
      END IF;

      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_RESOURCE_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;
   END IF;

   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Duration =' || p_resrc_Require_rec.Duration);
   END IF;
    -- DURATION
   IF (p_resrc_Require_rec.Duration IS NULL OR p_resrc_Require_rec.Duration = Fnd_Api.G_MISS_NUM) THEN
      IF G_DEBUG='Y' THEN
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Duration =' || p_resrc_Require_rec.Duration);
      END IF;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_DURATION_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;
    -- DURATION - Positive
   IF (p_resrc_Require_rec.Duration IS NOT NULL AND p_resrc_Require_rec.Duration <> Fnd_Api.G_MISS_NUM) THEN
      IF p_resrc_Require_rec.Duration < 0 THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_PP_ONLY_POSITIVE_VALUE');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;

    -- QUANTITY
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Quantity =' || p_resrc_Require_rec.quantity);
   END IF;

   IF (p_resrc_Require_rec.QUANTITY IS NULL OR p_resrc_Require_rec.QUANTITY = Fnd_Api.G_MISS_NUM) THEN
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Quantity =' || p_resrc_Require_rec.quantity);
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_QUANTITY_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;

    -- QUANTITY - Positive
   IF (p_resrc_Require_rec.QUANTITY IS NOT NULL AND p_resrc_Require_rec.QUANTITY <> Fnd_Api.G_MISS_NUM) THEN
      IF p_resrc_Require_rec.QUANTITY < 0 THEN
          IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name ('AHL', 'AHL_PP_ONLY_POSITIVE_VALUE');
             Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.g_ret_sts_error;
          RETURN;
      END IF;
   END IF;

     -- REQ_START_DATE
   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- REQ_START_DATE =' || p_resrc_Require_rec.REQ_START_DATE);
    END IF;

   IF (p_resrc_Require_rec.REQ_START_DATE IS NULL OR p_resrc_Require_rec.REQ_START_DATE = Fnd_Api.G_MISS_DATE) THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_REQUIRE_ST_DT_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;

      -- REQ_END_DATE
   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- REQ_START_DATE =' || p_resrc_Require_rec.REQ_START_DATE);
   END IF;

   IF (p_resrc_Require_rec.REQ_END_DATE IS NULL OR p_resrc_Require_rec.REQ_END_DATE = Fnd_Api.G_MISS_DATE) THEN
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_REQUIRE_END_DT_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;
   --
   -- Use local vars to reduce amount of typing.
   IF p_resrc_Require_rec.Req_start_date IS NOT NULL OR p_resrc_Require_rec.Req_start_date <> Fnd_Api.g_miss_date THEN
    	l_Require_start_date := p_resrc_Require_rec.Req_start_date;
   END IF;

   IF p_resrc_Require_rec.Req_end_date IS NOT NULL OR p_resrc_Require_rec.Req_end_date <> Fnd_Api.g_miss_date THEN
		l_Require_end_date := p_resrc_Require_rec.Req_end_date;
   END IF;

   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Start Date =' || l_Require_start_date);
       Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- End Date =' || l_Require_end_date);
   END IF;

   --
   -- Validate the active dates.
		IF l_Require_start_date IS NOT NULL AND l_Require_end_date IS NOT NULL THEN
		  IF l_Require_start_date > l_Require_end_date THEN
			IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_REQ_FROMDT_GTR_TODT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
		  END IF;
    	END IF;

    ------------------- Start Uncommented on 27 Jan 2003 as bug#2771573 -----------------
   IF g_MODULE_TYPE='JSP' THEN
    IF p_resrc_Require_rec.OPERATION_RESOURCE_ID = Fnd_Api.G_MISS_NUM OR p_resrc_Require_rec.OPERATION_RESOURCE_ID IS NULL THEN
          OPEN c_wo_oper(p_resrc_Require_rec.WORKORDER_OPERATION_ID);
          FETCH c_wo_oper INTO l_eff_st_date, l_eff_end_date, l_sch_st_date, l_sch_end_date;
             IF c_wo_oper%NOTFOUND THEN
                CLOSE c_wo_oper;
                Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '--If condition--');
                Fnd_Message.SET_NAME('AHL','AHL_PP_WORKORDER_NOT_EXISTS');
                Fnd_Msg_Pub.ADD;
             ELSE
                CLOSE c_wo_oper;
             END IF;
     ELSE
          OPEN c_oper_req(p_resrc_Require_rec.OPERATION_RESOURCE_ID);
          FETCH c_oper_req INTO c_oper_req_rec;
             IF c_oper_req%NOTFOUND THEN
                CLOSE c_oper_req;
                Fnd_Message.SET_NAME('AHL','AHL_PP_WORKORDER_OPER_NOT_EXISTS');
                Fnd_Msg_Pub.ADD;
             ELSE
                CLOSE c_oper_req;
                OPEN c_wo_oper(c_oper_req_rec.WORKORDER_OPERATION_ID);
                FETCH c_wo_oper INTO l_eff_st_date, l_eff_end_date, l_sch_st_date, l_sch_end_date;
                 IF c_wo_oper%NOTFOUND THEN
                    CLOSE c_wo_oper;
                    Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '--Else If condition--');
                    Fnd_Message.SET_NAME('AHL','AHL_PP_WORKORDER_NOT_EXISTS');
                    Fnd_Msg_Pub.ADD;
                 ELSE
                    CLOSE c_wo_oper;
                 END IF;
             END IF;
    END IF;



    IF G_DEBUG='Y' THEN
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Actual Start Date =' || l_eff_st_date);
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Actual End Date =' || l_eff_end_date);
      Ahl_Debug_Pub.debug('**************************************************************************');
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Scheduled Start Date =' || l_sch_st_date);
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Scheduled End Date =' || l_sch_end_date);
      Ahl_Debug_Pub.debug('**************************************************************************');
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Require Start Date =' || l_Require_start_date);
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Require End Date =' || l_Require_end_date);
      Ahl_Debug_Pub.debug('**************************************************************************');
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Operation ID =' || p_resrc_Require_rec.OPERATION_RESOURCE_ID);
    END IF;
   -- bug 4092197
   --l_Require_start_date := TO_DATE(l_Require_start_date,'DD-MON-YYYY');
   --l_Require_end_date   := TO_DATE(l_Require_end_date,'DD-MON-YYYY');
	IF l_Require_start_date IS NOT NULL THEN
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items AAA' || '-- Start Date =' || l_Require_start_date);
--JKJain, removed the validations of Required dates with Actual dates. Bug 9195920.
/*      IF l_eff_st_date IS NOT NULL THEN
        Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items AAA' || '-- Actual Start Date =' || l_eff_st_date);
        IF l_Require_start_date < l_eff_st_date THEN
    		 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_REQ_STDT_LESS_ACT_STDT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
        END IF;
      ELS*/
	  IF l_sch_st_date IS NOT NULL THEN
        Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items AAA' || '-- Scheduled Start Date =' || l_sch_st_date);
        IF l_Require_start_date < l_sch_st_date THEN
    		 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_REQ_STDT_LESS_SCH_STDT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
        END IF;
      END IF;

/*      IF l_eff_end_date IS NOT NULL THEN
        Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items AAA' || '-- Actual Start Date =' || l_eff_st_date);
        IF l_Require_start_date > l_eff_end_date THEN
    		 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_REQ_STDT_MORE_ACT_EDDT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
        END IF;
      ELS */
	  IF l_sch_end_date IS NOT NULL THEN
        Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items AAA' || '-- Scheduled End Date =' || l_sch_end_date);
        IF l_Require_start_date > l_sch_end_date THEN
   			 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_REQ_STDT_MORE_SCH_EDDT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
        END IF;
      END IF;
    END IF;

	IF l_Require_end_date IS NOT NULL THEN
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items BBB' || '-- End Date =' || l_Require_end_date);
/*      IF l_eff_end_date IS NOT NULL THEN
        Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items BBB' || '-- Actual End Date =' || l_eff_end_date);
        IF l_Require_end_date > l_eff_end_date THEN
    		 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_REQ_EDDT_MORE_ACT_EDDT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
        END IF;
      ELS */
	  IF l_sch_end_date IS NOT NULL THEN
        Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items BBB' || '-- Scheduled End Date =' || l_sch_end_date);
        IF l_Require_end_date > l_sch_end_date THEN
    		 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_REQ_EDDT_MORE_SCH_EDDT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
        END IF;
      END IF;

/*      IF l_eff_st_date IS NOT NULL THEN
        Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items BBB' || '-- Actual Start Date =' || l_eff_st_date);
        IF l_Require_end_date < l_eff_st_date THEN
    		 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_REQ_EDDT_LESS_ACT_STDT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
        END IF;
      ELS */
	  IF l_sch_st_date IS NOT NULL THEN
        Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items BBB' || '-- Scheduled Start Date =' || l_sch_st_date);
        IF l_Require_end_date < l_sch_st_date THEN
   			 IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
				Fnd_Message.set_name ('AHL', 'AHL_PP_REQ_EDDT_LESS_SCH_STDT');
				Fnd_Msg_Pub.ADD;
			 END IF;
			 x_return_status := Fnd_Api.g_ret_sts_error;
			 RETURN;
        END IF;
      END IF;
    END IF; -- CHECK FOR l_Require_end_date IS NOT NULL

  END IF; -- CHECK FOR g_MODULE_TYPE='JSP' THEN

END Check_Resrc_Require_Req_Items;

--       Check_Resrc_Require_UK_Items
PROCEDURE Check_Resrc_Require_UK_Items (
   p_resrc_Require_rec   IN    Resrc_Require_Rec_Type,
   p_validation_mode    IN    VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status      OUT   NOCOPY VARCHAR2
)
IS
   l_valid_flag   VARCHAR2(1);
   l_ctr          NUMBER:=0;
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;

   --
   -- For when ID is passed in, we need to check if this ID is unique.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
  IF G_DEBUG='Y' THEN
  Ahl_Debug_Pub.debug( ' RESOURCE SEQ NUMBER -->'||p_resrc_Require_rec.RESOURCE_SEQ_NUMBER);
  Ahl_Debug_Pub.debug( ' OPERATION_RESOURCE_ID -->' ||p_resrc_Require_rec.OPERATION_RESOURCE_ID);
  Ahl_Debug_Pub.debug( ' WORKORDER_OPERATION_ID -->' ||p_resrc_Require_rec.WORKORDER_OPERATION_ID);
  END IF;

  IF p_validation_mode = Jtf_Plsql_Api.g_create AND (p_resrc_Require_rec.OPERATION_RESOURCE_ID IS NULL OR p_resrc_Require_rec.OPERATION_RESOURCE_ID = FND_API.g_miss_num) THEN
       Ahl_Debug_Pub.debug( 'For create l_valid_flag -->' || l_valid_flag);
       Ahl_Debug_Pub.debug( 'QUERY -->' || 'RESOURCE_SEQUENCE_NUM = ' || p_resrc_Require_rec.RESOURCE_SEQ_NUMBER  ||
          ' AND WORKORDER_OPERATION_ID = ' || p_resrc_Require_rec.WORKORDER_OPERATION_ID);

       l_valid_flag := Ahl_Utility_Pvt.check_uniqueness (
         'AHL_OPERATION_RESOURCES',
         'RESOURCE_SEQUENCE_NUM = ' || p_resrc_Require_rec.RESOURCE_SEQ_NUMBER  ||
          ' AND WORKORDER_OPERATION_ID = ' || p_resrc_Require_rec.WORKORDER_OPERATION_ID
           );
   ELSE
        Ahl_Debug_Pub.debug( 'QUERY -->' || 'RESOURCE_SEQUENCE_NUM = ' || p_resrc_Require_rec.RESOURCE_SEQ_NUMBER  ||

          ' AND WORKORDER_OPERATION_ID = ' || p_resrc_Require_rec.WORKORDER_OPERATION_ID ||
           ' AND OPERATION_RESOURCE_ID <> ' || p_resrc_Require_rec.OPERATION_RESOURCE_ID);

        l_valid_flag := Ahl_Utility_Pvt.check_uniqueness (
         'AHL_OPERATION_RESOURCES',
         'RESOURCE_SEQUENCE_NUM = ' || p_resrc_Require_rec.RESOURCE_SEQ_NUMBER  ||
          ' AND WORKORDER_OPERATION_ID = ' || p_resrc_Require_rec.WORKORDER_OPERATION_ID ||
           ' AND OPERATION_RESOURCE_ID <> ' || p_resrc_Require_rec.OPERATION_RESOURCE_ID
          );

       Ahl_Debug_Pub.debug( 'l_valid_flag cccc -->' || l_valid_flag);
       Ahl_Debug_Pub.debug( 'QUERY -->' || 'RESOURCE_SEQUENCE_NUM = ' || p_resrc_Require_rec.RESOURCE_SEQ_NUMBER  ||
          ' AND WORKORDER_OPERATION_ID = ' || p_resrc_Require_rec.WORKORDER_OPERATION_ID ||
           ' AND OPERATION_RESOURCE_ID <> ' || p_resrc_Require_rec.OPERATION_RESOURCE_ID);
   END IF;

   IF l_valid_flag = Fnd_Api.g_false
   THEN

      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_REQ_NOT_UNIQUE');
         Fnd_Msg_Pub.ADD;
      END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RETURN;
   END IF;

END Check_Resrc_Require_UK_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Resrc_Require_Items
--
---------------------------------------------------------------------
PROCEDURE Check_Resrc_Require_Items (
   p_resrc_Require_rec  IN  Resrc_Require_Rec_Type,
   p_validation_mode   IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
BEGIN
   --
   -- Validate Required items.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug('BEFORE ..... Check_Resrc_Require_Req_Items');
   END IF;
   Check_Resrc_Require_Req_Items (
      p_resrc_Require_rec    => p_resrc_Require_rec,
      x_return_status       => x_return_status
   );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;
   --
   -- Validate uniqueness.
   Check_Resrc_Require_UK_Items (
      p_resrc_Require_rec    => p_resrc_Require_rec,
      p_validation_mode     => p_validation_mode,
      x_return_status       => x_return_status
   );

   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Resrc_Require_Items;

--------------------------------------------------------------------
-- PROCEDURE
--   Validate_Resrc_Require
--
--------------------------------------------------------------------
PROCEDURE Validate_Resrc_Require (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_resrc_Require_rec  IN  Resrc_Require_Rec_Type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS
   L_API_VERSION CONSTANT NUMBER := 1.0;
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Validate_Resrc_Require';
   L_FULL_NAME   CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_return_status        VARCHAR2(1);

   -- Added to fix bug# 6512803.
   CURSOR get_res_type(p_resource_id IN NUMBER) IS
     SELECT resource_type
     FROM   BOM_RESOURCES
     WHERE resource_id = p_resource_id;

   l_resource_type_code  BOM_RESOURCES.resource_type%TYPE;

BEGIN
   --------------------- initialize -----------------------
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Start');
   END IF;

   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   IF NOT Fnd_Api.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME
   ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;
   x_return_status := Fnd_Api.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':Check items');
   END IF;

   IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
      Check_Resrc_Require_Items (
         p_resrc_Require_rec   => p_resrc_Require_rec,
         p_validation_mode    => Jtf_Plsql_Api.g_create,
         x_return_status      => l_return_status
      );

      IF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;
--FP for Bug 6625880. AMSRINIV. Doing away with below validation as misc resources can be scheduled.
-- Fix for bug# 6512803. Validate scheduled type with resource type.
/*
   IF (p_resrc_Require_rec.scheduled_type_code IS NOT NULL AND
       p_resrc_Require_rec.scheduled_type_code <> FND_API.G_MISS_NUM) THEN
       IF (p_resrc_Require_rec.resource_type_code IS NULL AND
           p_resrc_Require_rec.resource_type_code = FND_API.G_MISS_NUM) THEN
           OPEN get_res_type(p_resrc_Require_rec.resource_id);
           FETCH get_res_type INTO l_resource_type_code;
           CLOSE get_res_type;
       ELSE
           l_resource_type_code := p_resrc_Require_rec.resource_type_code;
       END IF;
       IF (l_resource_type_code NOT IN (1,2)) AND p_resrc_Require_rec.scheduled_type_code = 1 THEN
         FND_MESSAGE.set_name( 'AHL', 'AHL_PRD_INVALID_SCHEDULE_TYPE' );
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.g_exc_error;
       END IF;
   END IF;
*/
  -------------------- finish --------------------------
   Fnd_Msg_Pub.count_and_get (
         p_encoded => Fnd_Api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );
   IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( l_full_name ||':End');
   END IF;

   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.disable_debug;
   END IF;

EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := Fnd_Api.g_ret_sts_unexp_error;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
		THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;

      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Validate_Resrc_Require;

 -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
 --------------------------------------------------------------------------------------------------
 -- Procedure added for Bug # 7697909
 -- This procedure expands Master Work Order scheduled dates such that there is enough space
 -- for child work orders to expand and add resource requirement.
 -- This process of expanding the work orders is needed only for Planned Work Order
 -- due to the fact that scheduling for planned work orders is done by EAM, and EAM
 -- does not take care of expanding Master work orders.
 --------------------------------------------------------------------------------------------------
 PROCEDURE Expand_Master_Wo_Dates(
      l_Resrc_Require_Rec  IN OUT NOCOPY Resrc_Require_Rec_Type
 )
 IS

 CURSOR  c_get_mwo_details(c_child_wip_entity_id IN NUMBER)
 IS
 SELECT  WO.workorder_id workorder_id,
	 WO.object_version_number object_version_number,
	 WO.wip_entity_id wip_entity_id,
	 WO.status_code status_code
 FROM    AHL_WORKORDERS WO,
	 WIP_SCHED_RELATIONSHIPS WOR
 WHERE   WO.wip_entity_id = WOR.parent_object_id
 AND     WO.master_workorder_flag = 'Y'
 AND     WO.status_code <> '22'
 AND     WOR.parent_object_type_id = 1
 AND     WOR.relationship_type = 1
 AND     WOR.child_object_type_id = 1
 AND     WOR.child_object_id = c_child_wip_entity_id;

 CURSOR c_get_visit_date(c_workorder_id IN NUMBER)
 IS
 SELECT
   wipj.scheduled_completion_date
 FROM
   ahl_workorders awo,
   wip_discrete_jobs wipj
 WHERE
       wipj.wip_entity_id = awo.wip_entity_id
   AND awo.master_workorder_flag = 'Y'
   AND awo.visit_task_id IS NULL
   AND awo.visit_id = (
		       SELECT
			 awov.visit_id
		       FROM
			 ahl_workorders awov
		       WHERE
			 awov.workorder_id = c_workorder_id
		      );

 CURSOR c_get_plan_flag(c_wip_entity_id NUMBER)
 IS
 SELECT
   wipj.firm_planned_flag
 FROM
   WIP_DISCRETE_JOBS wipj
 WHERE
   wipj.wip_entity_id = c_wip_entity_id;

 l_visit_sch_end_date DATE;
 l_mwo_details_rec c_get_mwo_details%ROWTYPE;
 l_up_workorder_rec  AHL_PRD_WORKORDER_PVT.prd_workorder_rec;
 l_up_workoper_tbl   AHL_PRD_WORKORDER_PVT.prd_workoper_tbl;
 l_api_name        CONSTANT VARCHAR2(30) := 'EXPAND_MASTER_WO_DATES';
 l_return_status            VARCHAR2(1);
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(2000);
 l_plan_flag  NUMBER;

 BEGIN
	-- Check if the work order is planned or firm
	-- If firm then return
	OPEN c_get_plan_flag(l_Resrc_Require_Rec.wip_entity_id);
	FETCH c_get_plan_flag INTO l_plan_flag;
	CLOSE c_get_plan_flag;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	THEN
	   fnd_log.string(
		    FND_LOG.LEVEL_STATEMENT,
		    'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
		    'l_plan_flag -> '||l_plan_flag
	   );
	END IF;


	IF l_plan_flag = 1
	THEN
	   RETURN;
	END IF;

	-- Retrieve master work order details for the work order
	-- to which resource requirements are added.
	OPEN c_get_mwo_details(l_Resrc_Require_Rec.wip_entity_id);
	FETCH c_get_mwo_details INTO l_mwo_details_rec;
	CLOSE c_get_mwo_details;

	-- Retrieve Visit master work order's scheduled end date
	OPEN c_get_visit_date(l_Resrc_Require_Rec.workorder_id);
	FETCH c_get_visit_date INTO l_visit_sch_end_date;
	CLOSE c_get_visit_date;

	l_up_workorder_rec.WORKORDER_ID       := l_mwo_details_rec.workorder_id;
	l_up_workorder_rec.OBJECT_VERSION_NUMBER := l_mwo_details_rec.object_version_number;
	l_up_workorder_rec.SCHEDULED_END_DATE := l_visit_sch_end_date;
	l_up_workorder_rec.SCHEDULED_END_HR   := TO_NUMBER(TO_CHAR(l_visit_sch_end_date, 'HH24'));
	l_up_workorder_rec.SCHEDULED_END_MI   := TO_NUMBER(TO_CHAR(l_visit_sch_end_date, 'MI'));

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	THEN
	   fnd_log.string(
		    FND_LOG.LEVEL_STATEMENT,
		    'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
		    'Before calling AHL_PRD_WORKORDER_PVT.update_job'
	   );
	   fnd_log.string(
		    FND_LOG.LEVEL_STATEMENT,
		    'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
		    'l_Resrc_Require_Rec.wip_entity_id -> '||l_Resrc_Require_Rec.wip_entity_id
	   );
	   fnd_log.string(
		    FND_LOG.LEVEL_STATEMENT,
		    'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
		    'l_up_workorder_rec.WORKORDER_ID -> '||l_up_workorder_rec.WORKORDER_ID
	   );
	   fnd_log.string(
		    FND_LOG.LEVEL_STATEMENT,
		    'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
		    'l_up_workorder_rec.SCHEDULED_END_DATE -> '||TO_CHAR(l_up_workorder_rec.SCHEDULED_END_DATE, 'DD-MON-YYYY HH24:MI:SS')
	   );
	END IF;

	-- The work order is expanded such that the end date of the work order
	-- is same as that of visit master work orders end date.
	AHL_PRD_WORKORDER_PVT.update_job
	(
	     p_api_version            => 1.0                        ,
	     p_init_msg_list          => FND_API.G_FALSE            ,
	     p_commit                 => FND_API.G_FALSE            ,
	     p_validation_level       => FND_API.G_VALID_LEVEL_FULL ,
	     p_default                => FND_API.G_TRUE             ,
	     p_module_type            => NULL                       ,
	     x_return_status          => l_return_status            ,
	     x_msg_count              => l_msg_count                ,
	     x_msg_data               => l_msg_data                 ,
	     p_wip_load_flag          => 'Y'                            ,
	     p_x_prd_workorder_rec    => l_up_workorder_rec         ,
	     p_x_prd_workoper_tbl     => l_up_workoper_tbl
	 );

	 IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	     RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
	 THEN
	     fnd_log.string(
			    FND_LOG.LEVEL_STATEMENT,
			    'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			    'After calling AHL_PRD_WORKORDER_PVT.update_job'
			   );
	 END IF;

 END Expand_Master_Wo_Dates;
 -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end
--------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Create_Resrc_Require
--  Type              : Private
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create Resource Requirement Parameters:
--       p_x_resrc_Require_tbl     IN OUT NOCOPY AHL_PP_RESRC_Require_PVT.Resrc_Require_Tbl_Type,
--         Contains Resource Reqirement information to create
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Create_Resrc_Require (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_interface_flag         IN            VARCHAR2,
    p_x_resrc_Require_Tbl    IN OUT NOCOPY AHL_PP_RESRC_Require_PVT.Resrc_Require_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
   )
 IS
 -- Check to see Operation Resource Id exists
 CURSOR Sch_id_exists (x_id IN NUMBER) IS
   SELECT 1 FROM dual
    WHERE EXISTS (SELECT 1
                  FROM AHL_OPERATION_RESOURCES
                  WHERE OPERATION_RESOURCE_ID = x_id);

 -- To find workorder_operation_id from ahl_workorder_operation_v view
 CURSOR c_wo_oper (x_id IN NUMBER, x_seq IN NUMBER) IS
   SELECT WORKORDER_OPERATION_ID FROM
     AHL_WORKORDER_OPERATIONS
     --AHL_WORKORDER_OPERATIONS_V
   WHERE WORKORDER_ID = x_id AND OPERATION_SEQUENCE_NUM = x_seq;

-- To find the resource sequence nubmer from ahl_operation_resources
 CURSOR c_resrc_seq (x_id IN NUMBER, x_oper_seq IN NUMBER, x_resrc_seq IN NUMBER) IS
   SELECT COUNT(*) FROM
     AHL_WORKORDER_OPERATIONS AWOV, AHL_OPERATION_RESOURCES AOR
   WHERE AWOV.WORKORDER_OPERATION_ID = AOR.WORKORDER_OPERATION_ID AND
     AWOV.WORKORDER_ID = x_id AND AWOV.OPERATION_SEQUENCE_NUM = x_oper_seq AND
     AOR.RESOURCE_SEQUENCE_NUM = x_resrc_seq;

-- To find the resource sequence nubmer from ahl_operation_resources
 CURSOR c_workorder (x_id IN NUMBER) IS
   SELECT * FROM AHL_WORKORDERS
   WHERE WORKORDER_ID = x_id;
   c_workorder_rec c_workorder%ROWTYPE;

-- To find the resource sequence nubmer from ahl_operation_resources
 CURSOR c_resources (x_id IN NUMBER) IS
   SELECT DEPARTMENT_ID FROM
     BOM_DEPARTMENT_RESOURCES
   WHERE RESOURCE_ID = x_id;

-- To find the resource sequence nubmer from ahl_operation_resources
 CURSOR c_wo_dept (x_id IN NUMBER) IS
    SELECT --V.DEPARTMENT_ID,  -- department should be from wip_operations
              V.ORGANIZATION_ID,
	      WORKORDER_NAME, WIP_ENTITY_ID FROM
        AHL_VISITS_B V, AHL_VISIT_TASKS_B T, AHL_WORKORDERS W
    WHERE W.VISIT_TASK_ID = T.VISIT_TASK_ID AND T.VISIT_ID = V.VISIT_ID
    AND W.VISIT_TASK_ID = x_id;

-- To find the UOM_CODE from MTL_UNITS_OF_MEASURE table
  CURSOR c_UOM (x_name IN VARCHAR2) IS
   SELECT UOM_CODE
     FROM MTL_UNITS_OF_MEASURE
   WHERE UNIT_OF_MEASURE = x_name;
   -- Get uom from bom resources
   CURSOR c_uom_code (x_id IN NUMBER)
    IS
   SELECT unit_of_measure
     FROM bom_resources
    WHERE resource_id = x_id;

   --Modified by srini to fix timestamp
   --Check to get the timestamp for operation
   /*CURSOR wip_operation_dates (c_workorder_id IN NUMBER,
                                  c_op_seq_num   IN NUMBER)
       IS
      SELECT first_unit_start_date,
            last_unit_completion_date
       FROM wip_operations a, ahl_workorders b
       WHERE a.wip_entity_id = b.wip_entity_id
        AND workorder_id = c_workorder_id
        AND operation_seq_num = c_op_seq_num;*/
       --fix for bug number 6211089
       CURSOR wip_operation_dates (c_workorder_operation_id IN NUMBER)
       IS
      SELECT first_unit_start_date,
            last_unit_completion_date
       FROM wip_operations a, ahl_workorders b,ahl_workorder_operations c
       WHERE a.wip_entity_id = b.wip_entity_id
        AND b.workorder_id = c.workorder_id
        AND a.operation_seq_num = c.OPERATION_SEQUENCE_NUM
        AND c.workorder_operation_id = c_workorder_operation_id;


 -- Added resource_type for bug# 6512803.
 CURSOR c_get_std_rate_flag(p_resource_id NUMBER)
 IS
 SELECT
   STANDARD_RATE_FLAG, resource_type
 FROM
   BOM_RESOURCES
 WHERE
   resource_id = p_resource_id;

   -- Schedule seq number validation
-- JKJAIN US space FP for ER # 6998882-- start
 	  CURSOR get_def_sched_seq(c_wo_oper_id IN NUMBER)
 	  IS
 	  SELECT
 	     MIN(wipor.schedule_seq_num)
 	  FROM
 	     ahl_workorder_operations awop,
 	     ahl_workorders awo,
 	     wip_operation_resources wipor
 	  WHERE
 	         awop.operation_sequence_num = wipor.operation_seq_num
 	     AND awo.wip_entity_id = wipor.wip_entity_id
 	     AND awop.workorder_id = awo.workorder_id
 	     AND awop.workorder_operation_id = c_wo_oper_id;

 	  l_def_sched_seq  NUMBER;
-- JKJAIN US space FP for ER # 6998882-- end

 l_api_name        CONSTANT VARCHAR2(30) := 'Create_Resrc_Require';
 l_api_version     CONSTANT NUMBER       := 1.0;
 L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

 l_wo_operation_id          NUMBER;
 l_dummy                    NUMBER;
 l_requirement_id           NUMBER;
 l_serial_id                NUMBER;
 l_resrc_seq_num            NUMBER;
 l_object_version_number    NUMBER;
 l_wo_operation_txn_id      NUMBER;
 l_process_status           NUMBER;
 l_employee_id              NUMBER;
 l_msg_count                NUMBER;
 l_resrc_dept_id            NUMBER;
 l_dept_id                  NUMBER;
 l_wo_dept                  NUMBER;
 l_count                    NUMBER;
 j                          NUMBER;
 l_std_rate_flag            VARCHAR2(30);

 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_error_message            VARCHAR2(120);
 l_employee_name            VARCHAR2(240);
 l_wo_organization_id       NUMBER;
 l_department_id            NUMBER;
 l_wip_entity_id            NUMBER;
 --
 l_Resrc_Require_Rec        Resrc_Require_Rec_Type;
 l_Resrc_Require_Tbl        Resrc_Require_Tbl_Type;
 l_op_start_date            DATE;
 l_op_end_date              DATE;
 --
 l_workorder_name           VARCHAR2(80);
 l_default                  VARCHAR2(10);

 -- Added for bug# 6444617.
 l_resource_type            bom_resources.resource_type%TYPE;

 BEGIN
   --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT Create_Resrc_Require;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug ('start p_interface_flag:'||p_interface_flag);
   Ahl_Debug_Pub.debug ('p_x_resrc_Require_tbl.COUNT:'||p_x_resrc_Require_tbl.COUNT);
   END IF;
   -- Debug info.
   -- Dbms_Output.Enable(50000);
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'Enter AHL_PP_RESRC_Require_PVT. Create_Resrc_Require +PPResrc_Require_Pvt+');
   END IF;
   G_MODULE_TYPE:=P_MODULE_TYPE;

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
   --------------------Start of API Body-----------------------------------
   IF p_x_resrc_Require_tbl.COUNT > 0 THEN
     FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST
      LOOP
           l_Resrc_Require_Rec := p_x_resrc_Require_tbl(i);
        --------------------Value OR ID conversion---------------------------
        --Start API Body
           IF p_module_type = 'JSP'
           THEN
              l_Resrc_Require_Rec.resource_id      := NULL;
           END IF;
       IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.debug ( ' Workorder Id = ' || l_Resrc_Require_Rec.workorder_id);
        Ahl_Debug_Pub.debug ( ' Operation Sequence = ' || l_Resrc_Require_Rec.operation_seq_number);
        Ahl_Debug_Pub.debug ( ' Resource Sequence = ' || l_Resrc_Require_Rec.resource_seq_number);
        Ahl_Debug_Pub.debug ( 'UOM NAME: ' || l_Resrc_Require_Rec.uom_name);
        Ahl_Debug_Pub.debug ( 'UOM CODE: ' || l_Resrc_Require_Rec.uom_code);
        Ahl_Debug_Pub.debug ( 'OPER SDATE: ' || l_Resrc_Require_Rec.oper_start_date);
        Ahl_Debug_Pub.debug ( 'OPER EDATE: ' || l_Resrc_Require_Rec.oper_end_date);
        Ahl_Debug_Pub.debug ( 'REQSDATE: ' || l_Resrc_Require_Rec.req_start_date);
        Ahl_Debug_Pub.debug ( 'REQEDATE: ' || l_Resrc_Require_Rec.req_end_date);

       END IF;

         IF l_Resrc_Require_Rec.workorder_id IS NOT NULL THEN
           IF l_Resrc_Require_Rec.operation_seq_number IS NOT NULL AND l_Resrc_Require_Rec.operation_seq_number <> FND_API.G_MISS_NUM THEN

                OPEN c_wo_oper(l_Resrc_Require_Rec.workorder_id, l_Resrc_Require_Rec.operation_seq_number);
                FETCH c_wo_oper INTO l_wo_operation_id;
                IF c_wo_oper%NOTFOUND THEN
                      CLOSE c_wo_oper;
                      Ahl_Debug_Pub.debug('NO SEQ');
                      Fnd_Message.SET_NAME('AHL','AHL_PP_OPER_SEQ_NOT_EXISTS');
                      Fnd_Msg_Pub.ADD;
                ELSE
                      CLOSE c_wo_oper;
                      l_Resrc_Require_Rec.workorder_operation_id := l_wo_operation_id;

                      IF l_Resrc_Require_Rec.resource_seq_number IS NOT NULL AND
                      l_Resrc_Require_Rec.resource_seq_number <> FND_API.G_MISS_NUM THEN
                            OPEN c_resrc_seq(l_Resrc_Require_Rec.workorder_id, l_Resrc_Require_Rec.operation_seq_number,l_Resrc_Require_Rec.resource_seq_number);
                            FETCH c_resrc_seq INTO l_count;
                            CLOSE c_resrc_seq;

                            IF l_count > 0 THEN
                                  IF G_DEBUG='Y' THEN
	                              Ahl_Debug_Pub.debug('UNIQ 1');
                                  END IF;
	                              Fnd_Message.SET_NAME('AHL','AHL_PP_RESRC_SEQ_NOT_UNIQUE');
                                  Fnd_Msg_Pub.ADD;
                            END IF;
                      END IF; -- Check resrc sequence number
                END IF; -- Check c_wo_oper%NOTFOUND

           END IF; -- Check of Oper sequence number
        ELSE
           Fnd_Message.SET_NAME('AHL','AHL_PP_JOB_NOT_EXISTS');
           Fnd_Msg_Pub.ADD;
        END IF; -- Check of work order id

        --rroy
        -- ACL Changes
        IF p_module_type = 'JSP' THEN

             OPEN c_workorder(l_Resrc_Require_Rec.workorder_id);
             FETCH c_workorder INTO c_workorder_rec;
             IF c_workorder%NOTFOUND THEN
                Fnd_Message.SET_NAME('AHL','AHL_PP_WORKORDER_NOT_EXISTS');
                Fnd_Msg_Pub.ADD;
             END IF;
             CLOSE c_workorder;
	END IF;

        l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(
                                   p_workorder_id => l_resrc_require_rec.workorder_id,
                                   p_ue_id => NULL,
                                   p_visit_id => NULL,
                                   p_item_instance_id => NULL);
        IF l_return_status = FND_API.G_TRUE THEN
               FND_MESSAGE.Set_Name('AHL', 'AHL_PP_CRT_RESREQ_UNTLCKD');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
        END IF;
        --rroy
        -- ACL Changes

        --Required to check the operation start dates and resource start and end date are same
	/*OPEN wip_operation_dates(l_Resrc_Require_Rec.workorder_id,
			                         l_Resrc_Require_Rec.operation_seq_number);*/
	        -- fix for bug number 6211089
	        OPEN wip_operation_dates(l_Resrc_Require_Rec.WORKORDER_OPERATION_ID);
			FETCH wip_operation_dates INTO l_op_start_date,l_op_end_date;
  		CLOSE wip_operation_dates;
        --Validation is required to include operation timestamp for Requested start date
	-- requested end date
	-- Bug # 6728602 -- start
	/*IF (TRUNC(l_Resrc_Require_Rec.req_start_date) = TRUNC(l_op_end_date)
	AND TRUNC(l_Resrc_Require_Rec.req_end_date) = TRUNC(l_op_end_date )) THEN

		     l_Resrc_Require_Rec.req_start_date := l_op_end_date;
		     l_Resrc_Require_Rec.req_end_date := l_op_end_date;

	ELSIF  (TRUNC(l_Resrc_Require_Rec.req_start_date) = TRUNC(l_op_start_date )
  	    AND TRUNC(l_Resrc_Require_Rec.req_end_date) = TRUNC(l_op_start_date )) THEN

		     l_Resrc_Require_Rec.req_start_date := l_op_start_date;
		     l_Resrc_Require_Rec.req_end_date := l_op_start_date;

        ELSIF (TRUNC(l_Resrc_Require_Rec.req_start_date) = TRUNC(l_op_start_date )
		    AND TRUNC(l_Resrc_Require_Rec.req_end_date) = TRUNC(l_op_end_date )) THEN

                     l_Resrc_Require_Rec.req_start_date := l_op_start_date;
		     l_Resrc_Require_Rec.req_end_date := l_op_end_date;

        ELSIF (TRUNC(l_Resrc_Require_Rec.req_start_date) = TRUNC(l_op_start_date )
		    AND TRUNC(l_Resrc_Require_Rec.req_end_date) <> TRUNC(l_op_start_date )) THEN

		     l_Resrc_Require_Rec.req_start_date := l_op_start_date;

        ELSIF (TRUNC(l_Resrc_Require_Rec.req_start_date) <> TRUNC(l_op_end_date )
		    AND TRUNC(l_Resrc_Require_Rec.req_end_date) = TRUNC(l_op_end_date )) THEN

		     l_Resrc_Require_Rec.req_end_date := l_op_end_date;

	END IF;	*/
	IF(l_Resrc_Require_Rec.req_start_date < l_op_start_date OR l_Resrc_Require_Rec.req_start_date > l_op_end_date)THEN
	          l_Resrc_Require_Rec.req_start_date := l_op_start_date;
	     END IF;
	     IF(l_Resrc_Require_Rec.req_end_date > l_op_end_date OR l_Resrc_Require_Rec.req_end_date < l_op_start_date)THEN
	          l_Resrc_Require_Rec.req_end_date := l_op_end_date;
        END IF;
	-- Bug # 6728602 -- end

        IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.debug ( ' Workorder Operation Id = ' || l_wo_operation_id);
        Ahl_Debug_Pub.debug ( ' Resource Type Name = ' || l_Resrc_Require_Rec.resource_type_name);
        Ahl_Debug_Pub.debug ( ' Resource Type Code = ' || l_Resrc_Require_Rec.resource_type_code);
        Ahl_Debug_Pub.debug ( ' Requested Start Date = ' || TO_CHAR(l_Resrc_Require_Rec.req_start_date, 'DD-MM-YYYY HH24:MI:SS'));
        Ahl_Debug_Pub.debug ( ' Requested End Date = ' || TO_CHAR(l_Resrc_Require_Rec.req_end_date, 'DD-MM-YYYY HH24:MI:SS'));
        END IF;
	    --
         -- For Resource Type
         IF ( l_Resrc_Require_Rec.resource_type_name IS NOT NULL AND
              l_Resrc_Require_Rec.resource_type_name <> Fnd_Api.G_MISS_CHAR )
         THEN
             Check_Lookup_Name_Or_Id (
                  p_lookup_type  => 'BOM_RESOURCE_TYPE',
                  p_lookup_code  => NULL,
                  p_meaning      => l_Resrc_Require_Rec.resource_type_name,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_Resrc_Require_Rec.resource_type_code,
                  x_return_status => l_return_status);

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_RESRC_TYPE_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
         END IF;
         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( ' Resource Type Code = ' || l_Resrc_Require_Rec.resource_type_code);
         Ahl_Debug_Pub.debug ( ' Resource Name = ' || l_Resrc_Require_Rec.RESOURCE_NAME);
         Ahl_Debug_Pub.debug ( ' Resource ID = ' || l_Resrc_Require_Rec.Resource_Id);

         Ahl_Debug_Pub.debug ( l_full_name || '*******************BEFORE RESOURCE NAME CHECK');
         END IF;
	     -- For Resource
         IF l_Resrc_Require_Rec.RESOURCE_NAME IS NOT NULL AND
            l_Resrc_Require_Rec.RESOURCE_NAME <> Fnd_Api.G_MISS_CHAR
         THEN
             Check_Resource_Name_Or_Id
                 (p_Resource_Id      => l_Resrc_Require_Rec.Resource_Id,
                  p_Resource_code    => l_Resrc_Require_Rec.Resource_Name,
                  p_workorder_id     => l_Resrc_Require_Rec.workorder_id,

                  x_Resource_Id      => l_Resrc_Require_Rec.Resource_Id,
                  x_return_status    => l_return_status,
                  x_error_msg_code   => l_msg_data
                  );

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_RESOURCE_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
         END IF;
       IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug ( l_full_name || '*******************AFTER RESOURCE NAME CHECK');
       END IF;

       IF p_module_type = 'JSP'
       THEN
           /*-- Get department id -- commented out as dept is retrieved along with
             -- operation start dates.
           OPEN c_wo_dept (c_workorder_rec.visit_task_id);
           FETCH c_wo_dept INTO --l_department_id,
                                l_wo_organization_id,
                                l_workorder_name, l_wip_entity_id;
           CLOSE c_wo_dept; */
           --
            OPEN c_resources(l_Resrc_Require_Rec.Resource_Id);
            FETCH c_resources INTO l_resrc_dept_id;
            IF c_resources%NOTFOUND THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_RESRC_DEPT_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
            END IF;
            CLOSE c_resources;

            -- check resource id dept matches the operation dept.
            IF (l_resrc_dept_id <> l_department_id) THEN
              Fnd_Message.SET_NAME('AHL','AHL_PP_RESRC_DEPT_NOT_EXISTS');
              Fnd_Msg_Pub.ADD;
            END IF;

          --Convert Uom code
          OPEN c_uom_code(l_Resrc_Require_Rec.Resource_Id);
		  FETCH c_uom_code INTO l_Resrc_Require_Rec.UOM_CODE;
		  CLOSE c_uom_code;
          --
           p_x_resrc_Require_tbl(i).uom_code := l_Resrc_Require_Rec.UOM_CODE;
          -- For Units of Measure
         IF l_Resrc_Require_Rec.UOM_NAME IS NOT NULL AND
            l_Resrc_Require_Rec.UOM_NAME <> Fnd_Api.G_MISS_CHAR
         THEN
                OPEN c_UOM(l_Resrc_Require_Rec.UOM_NAME);
                FETCH c_UOM INTO l_Resrc_Require_Rec.UOM_CODE;
                IF c_UOM%NOTFOUND THEN
                      CLOSE c_UOM;
                      Fnd_Message.SET_NAME('AHL','AHL_PP_UOM_NOT_EXISTS');
                      Fnd_Msg_Pub.ADD;
                ELSE
                      CLOSE c_UOM;
                END IF;
         END IF;

          -- For AutoCharge Type
         IF ( l_Resrc_Require_Rec.CHARGE_TYPE_NAME IS NOT NULL AND
              l_Resrc_Require_Rec.CHARGE_TYPE_NAME <> Fnd_Api.G_MISS_CHAR )
         THEN
             Check_Lookup_Name_Or_Id (
                  p_lookup_type  => 'BOM_AUTOCHARGE_TYPE',
                  p_lookup_code  => NULL,
                  p_meaning      => l_Resrc_Require_Rec.CHARGE_TYPE_NAME,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_Resrc_Require_Rec.CHARGE_TYPE_CODE,
                  x_return_status => l_return_status);

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_CHARGE_TYPE_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
         END IF;
         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( l_full_name || ' AutoCharge Code = ' || l_Resrc_Require_Rec.CHARGE_TYPE_CODE);
         Ahl_Debug_Pub.debug ( l_full_name || ' COST BASIS NAME = ' || l_Resrc_Require_Rec.COST_BASIS_NAME);
         Ahl_Debug_Pub.debug ( l_full_name || ' COST BASIS CODE = ' || l_Resrc_Require_Rec.COST_BASIS_CODE);
         END IF;
           -- For Cost Basis
         IF ( l_Resrc_Require_Rec.COST_BASIS_NAME IS NOT NULL AND
              l_Resrc_Require_Rec.COST_BASIS_NAME <> Fnd_Api.G_MISS_CHAR )
         THEN
             Check_Lookup_Name_Or_Id (
                  p_lookup_type   => 'CST_BASIS',
                  p_lookup_code   => NULL,
                  p_meaning       => l_Resrc_Require_Rec.COST_BASIS_NAME,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_Resrc_Require_Rec.COST_BASIS_CODE,
                  x_return_status => l_return_status);

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_COST_BASIS_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
         END IF;
         IF G_DEBUG='Y' THEN
          Ahl_Debug_Pub.debug ( l_full_name || ' COST BASIS CODE = ' || l_Resrc_Require_Rec.COST_BASIS_CODE);
          Ahl_Debug_Pub.debug ( l_full_name || ' SCHEDULED TYPE NAME = ' || l_Resrc_Require_Rec.SCHEDULED_TYPE_NAME);
          Ahl_Debug_Pub.debug ( l_full_name || ' SCHEDULED TYPE CODE = ' || l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE);
         END IF;
           -- For Scheduled Type
         IF ( l_Resrc_Require_Rec.SCHEDULED_TYPE_NAME IS NOT NULL AND
              l_Resrc_Require_Rec.SCHEDULED_TYPE_NAME <> Fnd_Api.G_MISS_CHAR )
         THEN
             Check_Lookup_Name_Or_Id (
                  p_lookup_type   => 'BOM_RESOURCE_SCHEDULE_TYPE',
                  p_lookup_code   => NULL,
                  p_meaning       => l_Resrc_Require_Rec.SCHEDULED_TYPE_NAME,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE,
                  x_return_status => l_return_status);

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_SCHED_TYPE_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
         END IF;
         IF G_DEBUG='Y' THEN
          Ahl_Debug_Pub.debug ( l_full_name || ' SCHEDULED TYPE CODE = ' || l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE);
          Ahl_Debug_Pub.debug ( l_full_name || ' STANDARD RATE FLAG = ' || l_Resrc_Require_Rec.STD_RATE_FLAG_CODE);
         END IF;
              -- To find meaning for fnd_lookups code
         IF (l_Resrc_Require_Rec.STD_RATE_FLAG_CODE IS NOT NULL AND
             l_Resrc_Require_Rec.STD_RATE_FLAG_CODE <> Fnd_Api.G_MISS_NUM) THEN
            SELECT meaning
              INTO l_std_rate_flag
            FROM MFG_LOOKUPS
            WHERE lookup_code = l_Resrc_Require_Rec.STD_RATE_FLAG_CODE
            AND LOOKUP_TYPE = 'BOM_NO_YES';
         END IF;

         END IF;

        -------------------------------- Validate -----------------------------------------
        IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.debug ( l_full_name || ' ******Before calling Validate_Resrc_Require****');
        END IF;

-- Schedule seq number validation
-- JKJAIN US space FP for ER # 6998882-- start
		 IF (
			l_Resrc_Require_Rec.schedule_seq_num IS NULL
		 )
		 THEN

			  OPEN get_def_sched_seq(l_Resrc_Require_Rec.workorder_operation_id);
			  FETCH get_def_sched_seq INTO l_def_sched_seq;
			  CLOSE get_def_sched_seq;

			  l_Resrc_Require_Rec.schedule_seq_num := NVL(l_def_sched_seq, 10);

		 END IF;
-- JKJAIN US space FP for ER # 6998882 -- end

        IF p_interface_flag is null or p_interface_flag <> 'N' THEN

             Validate_Resrc_Require (
                  p_api_version        => l_api_version,
                  p_init_msg_list      => p_init_msg_list,
                  p_commit             => p_commit,
                  p_validation_level   => p_validation_level,
                  p_resrc_Require_rec  => l_Resrc_Require_Rec,
                  x_return_status      => l_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data
             );
        END IF;
         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( l_full_name || ' ******After calling Validate_Resrc_Require****');
         END IF;
   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

       --
       IF l_Resrc_Require_Rec.Operation_Resource_Id = FND_API.G_MISS_NUM OR l_Resrc_Require_Rec.Operation_Resource_Id IS NULL
       THEN
         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( l_full_name || ' ******INSIDE  DEFAULT VALUES****');
         END IF;

	 -- These conditions are Required for optional fields
         IF (l_Resrc_Require_Rec.CHARGE_TYPE_CODE IS NULL OR
             l_Resrc_Require_Rec.CHARGE_TYPE_CODE = Fnd_Api.G_MISS_NUM) THEN
           l_Resrc_Require_Rec.charge_type_code    := 2;
         END IF;

         IF (l_Resrc_Require_Rec.COST_BASIS_CODE IS NULL OR
             l_Resrc_Require_Rec.COST_BASIS_CODE = Fnd_Api.G_MISS_NUM) THEN
           l_Resrc_Require_Rec.cost_basis_code    := 1;
         END IF;

         IF (l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE IS NULL OR
             l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE = Fnd_Api.G_MISS_NUM) THEN
           l_Resrc_Require_Rec.scheduled_type_code    := 1;
         END IF;

         -- As part of fix for bug# 6512803, merged validation of STD_RATE_FLAG_CODE and
         -- SCHEDULED_TYPE_CODE under one IF block.
         IF (l_Resrc_Require_Rec.STD_RATE_FLAG_CODE IS NULL OR
             l_Resrc_Require_Rec.STD_RATE_FLAG_CODE = Fnd_Api.G_MISS_NUM) OR
            (l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE IS NULL OR
             l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE = Fnd_Api.G_MISS_NUM) THEN

           -- Balaji modified the code for Bug # 5951435-- Begin

           OPEN c_get_std_rate_flag(l_Resrc_Require_Rec.Resource_Id);
           FETCH c_get_std_rate_flag INTO l_Resrc_Require_Rec.std_rate_flag_code, l_resource_type;
           CLOSE c_get_std_rate_flag;
           --l_Resrc_Require_Rec.std_rate_flag_code    := 1;

           -- Balaji modified the code for Bug # 5951435-- End
           -- Added to fix bug# 6512803.
           IF (l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE IS NULL OR
               l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE = Fnd_Api.G_MISS_NUM) THEN
              IF (l_resource_type IN (1,2)) THEN
                l_Resrc_Require_Rec.scheduled_type_code    := 1;
              ELSE
                l_Resrc_Require_Rec.scheduled_type_code    := 2;
              END IF;
           END IF;

         END IF;

          -- Last Updated Date
          IF l_Resrc_Require_Rec.last_update_login = FND_API.G_MISS_NUM
          THEN
           l_Resrc_Require_Rec.last_update_login := NULL;
          ELSE
           l_Resrc_Require_Rec.last_update_login := l_Resrc_Require_Rec.last_update_login;
          END IF;
          -- Attribute Category
          IF l_Resrc_Require_Rec.attribute_category = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute_category := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute_category := l_Resrc_Require_Rec.attribute_category;
          END IF;
          -- Attribute1
          IF l_Resrc_Require_Rec.attribute1 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute1 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute1 := l_Resrc_Require_Rec.attribute1;
          END IF;
          -- Attribute2
          IF l_Resrc_Require_Rec.attribute2 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute2 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute2 := l_Resrc_Require_Rec.attribute2;
          END IF;
          -- Attribute3
          IF l_Resrc_Require_Rec.attribute3 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute3 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute3 := l_Resrc_Require_Rec.attribute3;
          END IF;
          -- Attribute4
          IF l_Resrc_Require_Rec.attribute4 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute4 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute4 := l_Resrc_Require_Rec.attribute4;
          END IF;
          -- Attribute5
          IF l_Resrc_Require_Rec.attribute5 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute5 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute5 := l_Resrc_Require_Rec.attribute5;
          END IF;
          -- Attribute6
          IF l_Resrc_Require_Rec.attribute6 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute6 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute6 := l_Resrc_Require_Rec.attribute6;
          END IF;
          -- Attribute7
          IF l_Resrc_Require_Rec.attribute7 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute7 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute7 := l_Resrc_Require_Rec.attribute7;
          END IF;
          -- Attribute8
          IF l_Resrc_Require_Rec.attribute8 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute8 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute8 := l_Resrc_Require_Rec.attribute8;
          END IF;
          -- Attribute9
          IF l_Resrc_Require_Rec.attribute9 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute9 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute9 := l_Resrc_Require_Rec.attribute9;
          END IF;
          -- Attribute10
          IF l_Resrc_Require_Rec.attribute10 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute10 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute10 := l_Resrc_Require_Rec.attribute10;
          END IF;
          -- Attribute11
          IF l_Resrc_Require_Rec.attribute11 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute11 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute11 := l_Resrc_Require_Rec.attribute11;
          END IF;
          -- Attribute12
          IF l_Resrc_Require_Rec.attribute12 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute12 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute12 := l_Resrc_Require_Rec.attribute12;
          END IF;
          -- Attribute13
          IF l_Resrc_Require_Rec.attribute13 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute13 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute13 := l_Resrc_Require_Rec.attribute13;
          END IF;
          -- Attribute14
          IF l_Resrc_Require_Rec.attribute14 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute14 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute14 := l_Resrc_Require_Rec.attribute14;
          END IF;
          -- Attribute15
          IF l_Resrc_Require_Rec.attribute15 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute15 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute15 := l_Resrc_Require_Rec.attribute15;
          END IF;

            p_x_resrc_Require_tbl(i)  := l_Resrc_Require_Rec;
          END IF;
          IF G_DEBUG='Y' THEN
		  Ahl_Debug_Pub.debug ( l_full_name || ' ******OUTSIDE  DEFAULT VALUES****');
		  END IF;

    END LOOP;
 END IF;
         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ('p_interface_flag'||p_interface_flag);
         END IF;
 IF  nvl(p_interface_flag,'Y')= 'Y' THEN
    -- CALL Load_WIP_Jobs API
    -- If not sucess then not allowed to insert in our entity
       OPEN c_workorder(l_Resrc_Require_Rec.workorder_id);
       FETCH c_workorder INTO c_workorder_rec;
       CLOSE c_workorder;
      --Get organization id
      OPEN c_wo_dept (c_workorder_rec.visit_task_id);
      FETCH c_wo_dept INTO --l_department_id,
                           l_wo_organization_id,l_workorder_name,
	                   l_wip_entity_id;
      CLOSE c_wo_dept;
      --
     j:=1;
    FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST
    LOOP
  IF G_DEBUG='Y' THEN
  Ahl_Debug_Pub.debug ( l_full_name || 'CALL FOR WIP JOBS');
  Ahl_Debug_Pub.debug ('p_x_resrc_Require_tbl(i).OPERATION_SEQ_NUMBER' ||p_x_resrc_Require_tbl(i).OPERATION_SEQ_NUMBER  );
  Ahl_Debug_Pub.debug ('p_x_resrc_Require_tbl(i).RESOURCE_SEQ_NUMBER' ||p_x_resrc_Require_tbl(i).RESOURCE_SEQ_NUMBER  );
  Ahl_Debug_Pub.debug ('p_x_resrc_Require_tbl(i).RESOURCE_ID' ||p_x_resrc_Require_tbl(i).RESOURCE_ID );
  Ahl_Debug_Pub.debug ('p_x_resrc_Require_tbl(i).QUANTITY' ||p_x_resrc_Require_tbl(i).QUANTITY );
  END IF;
       l_Resrc_Require_Tbl(j).organization_id       := l_wo_organization_id;
       l_Resrc_Require_Tbl(j).wip_entity_id         := l_wip_entity_id;
       l_Resrc_Require_Tbl(j).job_number            := l_workorder_name;
       l_Resrc_Require_Tbl(j).workorder_id          := p_x_resrc_Require_tbl(i).WORKORDER_ID;
       l_Resrc_Require_Tbl(j).operation_seq_number  := p_x_resrc_Require_tbl(i).OPERATION_SEQ_NUMBER;
       l_Resrc_Require_Tbl(j).uom_code              := p_x_resrc_Require_tbl(i).UOM_CODE;
       l_Resrc_Require_Tbl(j).resource_seq_number   := p_x_resrc_Require_tbl(i).RESOURCE_SEQ_NUMBER;
-- JKJAIN US space FP for ER # 6998882-- start
 	   l_Resrc_Require_Tbl(j).schedule_seq_num      := p_x_resrc_Require_tbl(i).schedule_seq_num;
--JKJAIN US space FP for ER # 6998882 -- end
       l_Resrc_Require_Tbl(j).resource_id           := p_x_resrc_Require_tbl(i).RESOURCE_ID;
       l_Resrc_Require_Tbl(j).duration              := p_x_resrc_Require_tbl(i).DURATION;
       l_Resrc_Require_Tbl(j).req_start_date        := p_x_resrc_Require_tbl(i).REQ_START_DATE;
       l_Resrc_Require_Tbl(j).req_end_date          := p_x_resrc_Require_tbl(i).REQ_END_DATE;
       l_Resrc_Require_Tbl(j).quantity              := p_x_resrc_Require_tbl(i).QUANTITY;
       l_Resrc_Require_Tbl(j).applied_num           := p_x_resrc_Require_tbl(i).QUANTITY;
       l_Resrc_Require_Tbl(j).open_num              := p_x_resrc_Require_tbl(i).QUANTITY;
       l_Resrc_Require_Tbl(j).cost_basis_code       := p_x_resrc_Require_tbl(i).COST_BASIS_CODE;
       l_Resrc_Require_Tbl(j).charge_type_code      := p_x_resrc_Require_tbl(i).CHARGE_TYPE_CODE;
       l_Resrc_Require_Tbl(j).std_rate_flag_code    := p_x_resrc_Require_tbl(i).STD_RATE_FLAG_CODE;
       l_Resrc_Require_Tbl(j).scheduled_type_code   := p_x_resrc_Require_tbl(i).SCHEDULED_TYPE_CODE;
       l_Resrc_Require_Tbl(j).operation_flag        := 'C';

  IF G_DEBUG='Y' THEN
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).WIP_ENTITY_ID: ' ||l_Resrc_Require_Tbl(j).WIP_ENTITY_ID  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).JOB_NUMBER: ' ||l_Resrc_Require_Tbl(j).JOB_NUMBER  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).UOM_CODE: ' ||l_Resrc_Require_Tbl(j).UOM_CODE  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).WORKORDER_ID: ' ||l_Resrc_Require_Tbl(j).WORKORDER_ID  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).ORGANIZATION_ID: ' ||l_Resrc_Require_Tbl(j).ORGANIZATION_ID  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).OPERATION_SEQ_NUM: ' ||l_Resrc_Require_Tbl(j).OPERATION_SEQ_NUMBER  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).RESOURCE_SEQ_NUM: ' ||l_Resrc_Require_Tbl(j).RESOURCE_SEQ_NUMBER  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).RESOURCE_ID: ' ||l_Resrc_Require_Tbl(j).RESOURCE_ID );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).QUANTITY: ' ||l_Resrc_Require_Tbl(j).QUANTITY );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).DURATION: ' ||l_Resrc_Require_Tbl(j).DURATION );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).REQ_START_DATE: ' ||l_Resrc_Require_Tbl(j).REQ_START_DATE );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).REQ_END_DATE: ' ||l_Resrc_Require_Tbl(j).REQ_END_DATE );
  END IF;

       -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
       Expand_Master_Wo_Dates(l_Resrc_Require_Tbl(j));
       -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end

       j := j + 1;
    END LOOP;

    -- Call AHL_WIP_JOB_PVT.load_wip_job API  If the status is success then process
    IF P_MODULE_TYPE='JSP'
    THEN


	AHL_EAM_JOB_PVT.process_resource_req
          (
           p_api_version          => p_api_version,
           p_init_msg_list        => p_init_msg_list,
           p_commit               => p_commit,
           p_validation_level     => p_validation_level,
           p_default              => l_default,
           p_module_type          => p_module_type,
           x_return_status        => l_return_status,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data,
           p_resource_req_tbl     => l_Resrc_Require_Tbl);

        -- possible that EAM api returns error status but no error messages.
        -- not chking return status causes data corruption - see bug# 7632674
        -- Raise errors if exceptions occur
        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
           IF G_DEBUG='Y' THEN
              Ahl_Debug_Pub.debug ('Error returned from AHL_EAM_JOB_PVT.process_resource_req:'||l_return_status);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           IF G_DEBUG='Y' THEN
              Ahl_Debug_Pub.debug ('Error returned from AHL_EAM_JOB_PVT.process_resource_req:'||l_return_status);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   END IF;

 END IF;  -- interface flag

 IF G_DEBUG='Y' THEN
 Ahl_Debug_Pub.debug ('after wip load p_interface_flag'||l_return_status);
 Ahl_Debug_Pub.debug ('after wip load p_x_resrc_Require_tbl.COUNT'||p_x_resrc_Require_tbl.COUNT);

 END IF;

  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- IF l_return_status ='S' THEN
    --
  IF p_x_resrc_Require_tbl.COUNT > 0 THEN
     FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST
      LOOP
           IF G_DEBUG='Y' THEN
           Ahl_Debug_Pub.debug ( l_full_name || ' ******INSIDE  REQUIRE LOOP****');
		   END IF;

           l_Resrc_Require_Rec := p_x_resrc_Require_tbl(i);
       IF  l_Resrc_Require_Rec.Operation_Resource_id = FND_API.G_MISS_NUM OR l_Resrc_Require_Rec.Operation_Resource_Id IS NULL
       THEN
           IF G_DEBUG='Y' THEN
           Ahl_Debug_Pub.debug ( l_full_name || ' ******INSIDE REQUIRE ID IF CASE****');
		   END IF;

        --
        -- Get Sequence Number for Resource Requirement ID
        SELECT AHL_OPERATION_RESOURCES_S.NEXTVAL
               INTO l_Resrc_Require_Rec.Operation_Resource_id
        FROM DUAL;

        --Check for Record Exists
        OPEN Sch_id_exists(l_Requirement_id);
        FETCH Sch_id_exists INTO l_dummy;
        CLOSE Sch_id_exists;
        --
        IF l_dummy IS NOT NULL THEN
           Fnd_Message.SET_NAME('AHL','AHL_PP_SEQUENCE_NO_EXISTS');
           Fnd_Msg_Pub.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( l_full_name || ' ******Before calling Insert_Row****');
         Ahl_Debug_Pub.debug ( 'l_Resrc_Require_Rec.workorder_operation_id'||l_Resrc_Require_Rec.workorder_operation_id);
         Ahl_Debug_Pub.debug ( 'pworkorder_operation_id'||p_x_resrc_Require_tbl(i).workorder_operation_id);
         END IF;

          -- Create Record in schedule Resources
             Insert_Row (
                   X_OPERATION_RESOURCE_ID => l_Resrc_Require_Rec.Operation_Resource_id,
                   X_OBJECT_VERSION_NUMBER => 1,
                   X_LAST_UPDATE_DATE      => SYSDATE,
                   X_LAST_UPDATED_BY       => fnd_global.user_id,
                   X_CREATION_DATE         => SYSDATE,
                   X_CREATED_BY            => fnd_global.user_id,
                   X_LAST_UPDATE_LOGIN     => fnd_global.login_id,
                   X_RESOURCE_ID           => l_Resrc_Require_Rec.RESOURCE_ID,
                   X_WORKORDER_OPERATION_ID => l_Resrc_Require_Rec.workorder_operation_id,
                   X_RESOURCE_SEQ_NUMBER   => l_Resrc_Require_Rec.RESOURCE_SEQ_NUMBER,
                   X_UOM_CODE              => l_Resrc_Require_Rec.UOM_CODE,
                   X_QUANTITY              => l_Resrc_Require_Rec.QUANTITY,
                   X_DURATION              => l_Resrc_Require_Rec.DURATION,
                   X_SCHEDULED_START_DATE  => NVL(l_Resrc_Require_Rec.REQ_START_DATE,l_Resrc_Require_Rec.OPER_START_DATE),
                   X_SCHEDULED_END_DATE    => NVL(l_Resrc_Require_Rec.REQ_END_DATE,l_Resrc_Require_Rec.OPER_END_DATE),
                   X_ATTRIBUTE_CATEGORY    => l_Resrc_Require_Rec.attribute_category,
                   X_ATTRIBUTE1            => l_Resrc_Require_Rec.attribute1,
                   X_ATTRIBUTE2            => l_Resrc_Require_Rec.attribute2,
                   X_ATTRIBUTE3            => l_Resrc_Require_Rec.attribute3,
                   X_ATTRIBUTE4            => l_Resrc_Require_Rec.attribute4,
                   X_ATTRIBUTE5            => l_Resrc_Require_Rec.attribute5,
                   X_ATTRIBUTE6            => l_Resrc_Require_Rec.attribute6,
                   X_ATTRIBUTE7            => l_Resrc_Require_Rec.attribute7,
                   X_ATTRIBUTE8            => l_Resrc_Require_Rec.attribute8,
                   X_ATTRIBUTE9            => l_Resrc_Require_Rec.attribute9,
                   X_ATTRIBUTE10           => l_Resrc_Require_Rec.attribute10,
                   X_ATTRIBUTE11           => l_Resrc_Require_Rec.attribute11,
                   X_ATTRIBUTE12           => l_Resrc_Require_Rec.attribute12,
                   X_ATTRIBUTE13           => l_Resrc_Require_Rec.attribute13,
                   X_ATTRIBUTE14           => l_Resrc_Require_Rec.attribute14,
                   X_ATTRIBUTE15           => l_Resrc_Require_Rec.attribute15
                  );
                  IF G_DEBUG='Y' THEN
                  Ahl_Debug_Pub.debug ( l_full_name || ' ******After calling Insert_Row****');
				  END IF;

                  p_x_resrc_Require_tbl(i)  := l_Resrc_Require_Rec;
          END IF;

              SELECT AHL_WO_OPERATIONS_TXNS_S.NEXTVAL
                 INTO l_wo_operation_txn_id
              FROM DUAL;
              IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug( 'before calling log record l_wo_operation_txn_id:'||l_wo_operation_txn_id);
              END IF;

           -- Create Record in transactions table
              AHL_PP_MATERIALS_PVT.Log_Transaction_Record
                   ( p_wo_operation_txn_id    => l_wo_operation_txn_id,
                     p_object_version_number  => 1,
                     p_last_update_date       => sysdate,
                     p_last_updated_by        => fnd_global.user_id,
                     p_creation_date          => sysdate,
                     p_created_by             => fnd_global.user_id,
                     p_last_update_login      => fnd_global.login_id,
                     p_load_type_code         => 1,
                     p_transaction_type_code  => 2,
                     p_workorder_operation_id => p_x_resrc_Require_tbl(i).workorder_operation_id,
                     p_bom_resource_id        => p_x_resrc_Require_tbl(i).Resource_id,
                     p_operation_resource_id  => p_x_resrc_Require_tbl(i).Operation_Resource_id,
                     p_res_sched_start_date   => p_x_resrc_Require_tbl(i).REQ_START_DATE,
                     p_res_sched_end_date     => p_x_resrc_Require_tbl(i).REQ_START_DATE
                   );
            IF G_DEBUG='Y' THEN
            Ahl_Debug_Pub.debug ( l_full_name || ' ******OUTSIDE REQUIRE IF CASE****');
			END IF;
    END LOOP;
    IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug ( l_full_name || ' ******OUTSIDE REQUIRE LOOP****');
	END IF;

  END IF;

--END IF;
   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;
   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   IF G_DEBUG='Y' THEN
   -- Debug info
   Ahl_Debug_Pub.debug( 'End of public api Create Resource Reqst +PPResrc_Require_Pvt+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   --
   END IF;

 EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Resrc_Require;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN
       -- Debug info.
       AHL_DEBUG_PUB.log_app_messages (x_msg_count, x_msg_data, 'ERROR' );

        -- Check if API is called in debug mode. If yes, disable debug.
       AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Resrc_Require;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        Ahl_Debug_Pub.debug('Inside Exception' || '**UNEXPECTED ERRORS');
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );

        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN OTHERS THEN
    ROLLBACK TO Create_Resrc_Require;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    Ahl_Debug_Pub.debug('Inside Exception' || '**SQL ERRORS');
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_RESRC_Require_PVT',
                            p_procedure_name  =>  'Create_Resrc_Require',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );

        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

END Create_Resrc_Require;

-------------------------------------------------------------------------------------------
--
-- Start of Comments --
--  Procedure name    : Update_Resrc_Require
--  Type              : Private
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Update Resource Requirement Parameters:
--       p_x_resrc_Require_tbl     IN OUT NOCOPY AHL_PP_RESRC_Require_PVT.Resrc_Require_Tbl_Type,
--         Contains Resource Requirement information to perform Updation
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Update_Resrc_Require (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := Null,
    p_interface_flag         IN            VARCHAR2,

    p_x_resrc_Require_Tbl    IN OUT NOCOPY Resrc_Require_Tbl_Type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
   )
 IS

-- To find the WORKORDER_ID from AHL_WORKORDER_OPERATIONS_V view
  CURSOR c_wo_oper (x_id IN NUMBER) IS
   SELECT WORKORDER_ID,OPERATION_SEQUENCE_NUM FROM
     AHL_WORKORDER_OPERATIONS_V
   WHERE WORKORDER_OPERATION_ID = x_id;

-- To Get Wip Entity Id and Org Id
  CURSOR c_work_orders (x_id IN NUMBER) IS
   SELECT WIP_ENTITY_ID,WORKORDER_NAME,
          ORGANIZATION_ID FROM
     AHL_WORKORDERS A, AHL_VISIT_TASKS_B B,
	   AHL_VISITS_B C
   WHERE WORKORDER_ID = x_id
    AND A.VISIT_TASK_ID = B.VISIT_TASK_ID
	AND B.VISIT_ID = C.VISIT_ID;

-- To find the RESOURCE_SEQUENCE_NUM from AHL_OPERATION_RESOURCES view
  CURSOR c_oper_resrc (x_id IN NUMBER) IS
   SELECT RESOURCE_SEQUENCE_NUM FROM
     AHL_OPERATION_RESOURCES
   WHERE WORKORDER_OPERATION_ID = x_id;

-- To find all information from AHL_OPERATION_RESOURCES view
  CURSOR c_oper_req (x_id IN NUMBER) IS
   SELECT * FROM AHL_OPERATION_RESOURCES
   WHERE OPERATION_RESOURCE_ID = x_id;
   c_oper_req_rec c_oper_req%ROWTYPE;

-- To find the resource sequence nubmer from ahl_operation_resources
 /*
  * R12 Perf Tuning
  * Balaji modified the query to use only base tables
  * instead of AHL_WORKORDERS_V
  */
 CURSOR c_workorder (x_id IN NUMBER) IS
   --SELECT * FROM AHL_WORKORDERS_V
   --WHERE WORKORDER_ID = x_id;
 SELECT
  WO.visit_task_id,
  WDJ.owning_department department_id
 FROM
  AHL_WORKORDERS WO,
  WIP_DISCRETE_JOBS WDJ
 WHERE
  WO.workorder_id = x_id AND
  WDJ.wip_entity_id = wo.wip_entity_id;

   c_workorder_rec c_workorder%ROWTYPE;

-- To find the resource sequence nubmer from ahl_operation_resources
 CURSOR c_resources (x_id IN NUMBER) IS
   SELECT DEPARTMENT_ID FROM
     BOM_DEPARTMENT_RESOURCES
   WHERE RESOURCE_ID = x_id;

-- To find the UOM_CODE from MTL_UNITS_OF_MEASURE table
  CURSOR c_UOM (x_name IN VARCHAR2) IS
   SELECT UOM_CODE
     FROM MTL_UNITS_OF_MEASURE
   WHERE UNIT_OF_MEASURE = x_name;

   -- Get uom from bom resources
   CURSOR c_uom_code (x_id IN NUMBER)
    IS
   SELECT unit_of_measure
     FROM bom_resources
    WHERE resource_id = x_id;

   --Modified by srini to fix timestamp
   --Check to get the timestamp for operation
   /*CURSOR wip_operation_dates (c_workorder_id IN NUMBER,
                               c_op_seq_num   IN NUMBER)
    IS
   SELECT first_unit_start_date,
         last_unit_completion_date, a.department_id
    FROM wip_operations a, ahl_workorders b
    WHERE a.wip_entity_id = b.wip_entity_id
     AND workorder_id = c_workorder_id
     AND operation_seq_num = c_op_seq_num;*/

    -- Fix for bug# 6053137 added by Adithya
    CURSOR wip_operation_dates (c_workorder_operation_id IN NUMBER)
    IS
    SELECT first_unit_start_date,
           last_unit_completion_date
    FROM wip_operations a, ahl_workorders b,ahl_workorder_operations c
    WHERE a.wip_entity_id = b.wip_entity_id
    AND b.workorder_id = c.workorder_id
    AND a.operation_seq_num = c.OPERATION_SEQUENCE_NUM
    AND c.workorder_operation_id = c_workorder_operation_id;

 l_api_name        CONSTANT VARCHAR2(30) := 'Update_Resrc_Require';
 l_full_name       CONSTANT VARCHAR2(80) := G_PKG_NAME || '.' || L_API_NAME;
 l_api_version     CONSTANT NUMBER       := 1.0;

 l_msg_count                NUMBER;
 l_object_version_number    NUMBER;
 l_resrc_seq_num            NUMBER;
 l_workorder_id             NUMBER;
 l_wo_operation_id          NUMBER;
 l_wo_operation_txn_id      NUMBER;
 l_resrc_dept_id            NUMBER;
 l_dept_id                  NUMBER;
 j                          NUMBER;

 l_return_status            VARCHAR2(1);
 l_std_rate_flag            VARCHAR2(30);
 l_uom_code                 VARCHAR2(3);
 l_msg_data                 VARCHAR2(2000);

 l_Resrc_Require_Rec        Resrc_Require_Rec_Type;
 l_Resrc_Require_Tbl        Resrc_Require_Tbl_Type;
 l_default                  VARCHAR2(10);
 l_work_order_rec           c_work_orders%ROWTYPE;
 l_wip_entity_id            NUMBER;
 l_op_start_date            DATE;
 l_op_end_date              DATE;
 l_department_id            NUMBER;

 BEGIN
   --------------------Initialize ----------------------------------
   -- Standard Start of API savepoint
   SAVEPOINT Update_Resrc_Require;

   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN

   AHL_DEBUG_PUB.enable_debug;

   -- Debug info.
   Ahl_Debug_Pub.debug( 'Enter ahl_pp_resrc_require_pvt. Update Resource  Requirement +PPResrc_Require_Pvt+');
   END IF;

   G_MODULE_TYPE:=P_MODULE_TYPE;
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
   --------------------Start of API Body-----------------------------------
   IF p_x_resrc_Require_tbl.COUNT > 0 THEN
     FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST
      LOOP
         l_Resrc_Require_Rec := p_x_resrc_Require_tbl(i);
         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( l_full_name || 'OPERATION_RESOURCE_ID = ' || l_Resrc_Require_Rec.OPERATION_RESOURCE_ID);
		 END IF;
   --------------------Value OR ID conversion---------------------------
        --Start API Body
       IF p_module_type = 'JSP'
       THEN
          l_Resrc_Require_Rec.resource_id      := NULL;
       END IF;

       OPEN c_oper_req(l_Resrc_Require_Rec.OPERATION_RESOURCE_ID);
       FETCH c_oper_req INTO c_oper_req_rec;
       CLOSE c_oper_req;

       l_Resrc_Require_Rec.WORKORDER_OPERATION_ID := c_oper_req_rec.WORKORDER_OPERATION_ID;
       l_Resrc_Require_Rec.RESOURCE_SEQ_NUMBER    := c_oper_req_rec.RESOURCE_SEQUENCE_NUM;

       -- rroy
       -- ACL changes
       OPEN c_WO_oper (l_Resrc_Require_Rec.WORKORDER_OPERATION_ID);
       FETCH c_WO_oper INTO l_workorder_id,l_Resrc_Require_Rec.operation_seq_number;
       CLOSE c_WO_oper;

       l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(
                                   p_workorder_id => l_workorder_id,
                                   p_ue_id => NULL,
                                   p_visit_id => NULL,
                                   p_item_instance_id => NULL);
       IF l_return_status = FND_API.G_TRUE THEN
          FND_MESSAGE.Set_Name('AHL', 'AHL_PP_UPD_RESREQ_UNTLCKD');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- rroy
       -- ACL changes
       -- Added as part of fix for bug 4092197
       -- Since this check is there in Create API
       -- it should be there in update, otherwise
       -- creation is allowed but updation of the same record is not allowed
       --Required to check the operation start dates and resource start and end date are same
       /*OPEN wip_operation_dates(l_Resrc_Require_Rec.workorder_id,
                                l_Resrc_Require_Rec.operation_seq_number);
       FETCH wip_operation_dates INTO l_op_start_date,l_op_end_date,l_department_id;
       CLOSE wip_operation_dates;*/
       -- Fix for bug# 6053137 added by Adithya
	OPEN wip_operation_dates(l_Resrc_Require_Rec.WORKORDER_OPERATION_ID);
		FETCH wip_operation_dates INTO l_op_start_date,l_op_end_date;
	CLOSE wip_operation_dates;
       --Validation is required to include operation timestamp for Requested start date
       -- requested end date
       -- Bug # 6728602 -- start

       IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.debug ( ' l_Resrc_Require_Rec.req_start_date = ' || to_char(l_Resrc_Require_Rec.req_start_date,'DD-MON-YYYY HH24:MI:SS'));
        Ahl_Debug_Pub.debug ( ' l_Resrc_Require_Rec.req_end_date = ' || to_char(l_Resrc_Require_Rec.req_end_date,'DD-MON-YYYY HH24:MI:SS'));
       END IF;
       IF(l_Resrc_Require_Rec.req_start_date < l_op_start_date OR l_Resrc_Require_Rec.req_start_date > l_op_end_date)THEN
          l_Resrc_Require_Rec.req_start_date := l_op_start_date;
       END IF;
       IF(l_Resrc_Require_Rec.req_end_date > l_op_end_date OR l_Resrc_Require_Rec.req_end_date < l_op_start_date)THEN
          l_Resrc_Require_Rec.req_end_date := l_op_end_date;
       END IF;

       /*IF  (TRUNC(l_Resrc_Require_Rec.req_start_date) = TRUNC(l_op_start_date )
	    AND TRUNC(l_Resrc_Require_Rec.req_end_date) = TRUNC(l_op_start_date )) THEN

		     l_Resrc_Require_Rec.req_start_date := l_op_start_date;
		     l_Resrc_Require_Rec.req_end_date := l_op_start_date;

       ELSIF (TRUNC(l_Resrc_Require_Rec.req_start_date) = TRUNC(l_op_end_date)
	     AND TRUNC(l_Resrc_Require_Rec.req_end_date) = TRUNC(l_op_end_date )) THEN

		     l_Resrc_Require_Rec.req_start_date := l_op_end_date;
		     l_Resrc_Require_Rec.req_end_date := l_op_end_date;

       ELSIF (TRUNC(l_Resrc_Require_Rec.req_start_date) = TRUNC(l_op_start_date )
		    AND TRUNC(l_Resrc_Require_Rec.req_end_date) = TRUNC(l_op_end_date )) THEN

                     l_Resrc_Require_Rec.req_start_date := l_op_start_date;
		     l_Resrc_Require_Rec.req_end_date := l_op_end_date;

       ELSIF (TRUNC(l_Resrc_Require_Rec.req_start_date) = TRUNC(l_op_start_date )
		    AND TRUNC(l_Resrc_Require_Rec.req_end_date) <> TRUNC(l_op_start_date )) THEN

		     l_Resrc_Require_Rec.req_start_date := l_op_start_date;

       ELSIF (TRUNC(l_Resrc_Require_Rec.req_start_date) <> TRUNC(l_op_end_date )
		    AND TRUNC(l_Resrc_Require_Rec.req_end_date) = TRUNC(l_op_end_date )) THEN

		     l_Resrc_Require_Rec.req_end_date := l_op_end_date;


       END IF;*/
        -- Bug # 6728602 -- end
  -- end of changes for bug 4092197
        IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.debug ( l_full_name || ' WORKORDER_OPERATION_ID = ' || l_Resrc_Require_Rec.WORKORDER_OPERATION_ID);
        Ahl_Debug_Pub.debug ( l_full_name || ' Resource ID = ' || l_Resrc_Require_Rec.Resource_Id);
		END IF;
        --Ahl_Debug_Pub.debug ( l_full_name || ' RESOURCE_SEQUENCE_NUM = ' || l_Resrc_Require_Rec.RESOURCE_SEQ_NUMBER);

        /*Ahl_Debug_Pub.debug ( l_full_name || ' Object Version Nubmer = ' || l_Resrc_Require_Rec.object_version_number);
        Ahl_Debug_Pub.debug ( l_full_name || ' Resource Type Name = ' || l_Resrc_Require_Rec.resource_type_name);
        Ahl_Debug_Pub.debug ( l_full_name || ' Resource Type Code = ' || l_Resrc_Require_Rec.resource_type_code);*/

         -- For Resource Type
         IF ( l_Resrc_Require_Rec.resource_type_name IS NOT NULL AND
              l_Resrc_Require_Rec.resource_type_name <> Fnd_Api.G_MISS_CHAR )
         THEN
             Check_Lookup_Name_Or_Id (
                  p_lookup_type  => 'BOM_RESOURCE_TYPE',
                  p_lookup_code  => NULL,
                  p_meaning      => l_Resrc_Require_Rec.resource_type_name,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_Resrc_Require_Rec.resource_type_code,
                  x_return_status => l_return_status);

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_RESRC_TYPE_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
         END IF;

         --Ahl_Debug_Pub.debug ( l_full_name || ' Resource Type Code = ' || l_Resrc_Require_Rec.resource_type_code);
         --Ahl_Debug_Pub.debug ( l_full_name || ' Resource Name = ' || l_Resrc_Require_Rec.RESOURCE_NAME);
         -- For Resource
         IF l_Resrc_Require_Rec.RESOURCE_NAME IS NOT NULL AND
            l_Resrc_Require_Rec.RESOURCE_NAME <> Fnd_Api.G_MISS_CHAR
         THEN
             Check_Resource_Name_Or_Id
                 (p_Resource_id      => l_Resrc_Require_Rec.Resource_Id,
                  p_Resource_code    => l_Resrc_Require_Rec.Resource_Name,
                  p_workorder_id     => l_workorder_id,

                  x_Resource_Id    => l_Resrc_Require_Rec.Resource_Id,
                  x_return_status    => l_return_status,
                  x_error_msg_code   => l_msg_data
                  );

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_RESOURCE_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
         END IF;
         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( l_full_name || 'After Resource ID = ' || l_Resrc_Require_Rec.Resource_Id);
         END IF;
    --Assign workorder
	l_Resrc_Require_Rec.workorder_id := l_workorder_id;

     -- RESOURCE_TYPE_NAME
   IF (l_Resrc_Require_Rec.RESOURCE_TYPE_NAME IS NULL OR l_Resrc_Require_Rec.RESOURCE_TYPE_NAME = Fnd_Api.G_MISS_CHAR) THEN
       Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Resource Type Name =' || l_Resrc_Require_Rec.RESOURCE_TYPE_NAME);
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_RESRC_TYPE_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
   END IF;

   Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Resource Name =' || l_Resrc_Require_Rec.RESOURCE_NAME);
     -- RESOURCE_NAME
   IF (l_Resrc_Require_Rec.RESOURCE_NAME IS NULL OR l_Resrc_Require_Rec.RESOURCE_NAME = Fnd_Api.G_MISS_CHAR) THEN
      Ahl_Debug_Pub.debug('Check_Resrc_Require_Req_Items' || '-- Resource Name =' || l_Resrc_Require_Rec.RESOURCE_NAME);
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_PP_RESRC_NAME_MISSING');
         Fnd_Msg_Pub.ADD;
      END IF;
   END IF;

         Ahl_Debug_Pub.debug ( l_full_name || 'After WORKORDER ID = ' || l_Resrc_Require_Rec.workorder_id);
         /*OPEN c_workorder(l_Resrc_Require_Rec.workorder_id);
         FETCH c_workorder INTO c_workorder_rec;
         IF c_workorder%NOTFOUND THEN
            CLOSE c_workorder;
            Fnd_Message.SET_NAME('AHL','AHL_PP_WORKORDER_NOT_EXISTS');
            Fnd_Msg_Pub.ADD;
         ELSE
            CLOSE c_workorder;*/

            OPEN c_resources(l_Resrc_Require_Rec.Resource_Id);
            FETCH c_resources INTO l_resrc_dept_id;
            IF c_resources%NOTFOUND THEN
                  CLOSE c_resources;
                  Fnd_Message.SET_NAME('AHL','AHL_PP_RESRC_DEPT_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
            ELSE
                  CLOSE c_resources;
                  --IF l_resrc_dept_id = c_workorder_rec.department_id THEN
                  IF l_resrc_dept_id <> l_department_id THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_RESRC_DEPT_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  END IF;
            END IF;

         --END IF;

         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( l_full_name || ' Unit of Measure = ' || l_Resrc_Require_Rec.UOM_Name);
         Ahl_Debug_Pub.debug ( l_full_name || ' UOM Code = ' || l_Resrc_Require_Rec.UOM_CODE);
         END IF;
          -- For Units of Measure
         IF l_Resrc_Require_Rec.UOM_NAME IS NOT NULL AND
            l_Resrc_Require_Rec.UOM_NAME <> Fnd_Api.G_MISS_CHAR
         THEN
                OPEN c_UOM(l_Resrc_Require_Rec.UOM_NAME);
                FETCH c_UOM INTO l_Resrc_Require_Rec.UOM_CODE;
                IF c_UOM%NOTFOUND THEN
                      CLOSE c_UOM;
                      Fnd_Message.SET_NAME('AHL','AHL_PP_UOM_NOT_EXISTS');
                      Fnd_Msg_Pub.ADD;
                ELSE
                      CLOSE c_UOM;
                END IF;
         END IF;
	      --Convert Uom code
          OPEN c_uom_code(l_Resrc_Require_Rec.Resource_Id);
		  FETCH c_uom_code INTO l_Resrc_Require_Rec.UOM_CODE;
		  CLOSE c_uom_code;
          --
           p_x_resrc_Require_tbl(i).uom_code := l_Resrc_Require_Rec.UOM_CODE;

         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( l_full_name || ' UOM Code = ' || l_Resrc_Require_Rec.UOM_CODE);
         Ahl_Debug_Pub.debug ( l_full_name || ' AutoCharge Type = ' || l_Resrc_Require_Rec.CHARGE_TYPE_NAME);
         Ahl_Debug_Pub.debug ( l_full_name || ' AutoCharge Code = ' || l_Resrc_Require_Rec.CHARGE_TYPE_CODE);
         END IF;
          -- For AutoCharge Type
         IF ( l_Resrc_Require_Rec.CHARGE_TYPE_NAME IS NOT NULL AND
              l_Resrc_Require_Rec.CHARGE_TYPE_NAME <> Fnd_Api.G_MISS_CHAR )
         THEN
             Check_Lookup_Name_Or_Id (
                  p_lookup_type  => 'BOM_AUTOCHARGE_TYPE',
                  p_lookup_code  => NULL,
                  p_meaning      => l_Resrc_Require_Rec.CHARGE_TYPE_NAME,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_Resrc_Require_Rec.CHARGE_TYPE_CODE,
                  x_return_status => l_return_status);

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_CHARGE_TYPE_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
         END IF;
         IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( l_full_name || ' AutoCharge Code = ' || l_Resrc_Require_Rec.CHARGE_TYPE_CODE);
         Ahl_Debug_Pub.debug ( l_full_name || ' COST BASIS NAME = ' || l_Resrc_Require_Rec.COST_BASIS_NAME);
         Ahl_Debug_Pub.debug ( l_full_name || ' COST BASIS CODE = ' || l_Resrc_Require_Rec.COST_BASIS_CODE);
         END IF;
           -- For Cost Basis
         IF ( l_Resrc_Require_Rec.COST_BASIS_NAME IS NOT NULL AND
              l_Resrc_Require_Rec.COST_BASIS_NAME <> Fnd_Api.G_MISS_CHAR )
         THEN
             Check_Lookup_Name_Or_Id (
                  p_lookup_type   => 'CST_BASIS',
                  p_lookup_code   => NULL,
                  p_meaning       => l_Resrc_Require_Rec.COST_BASIS_NAME,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_Resrc_Require_Rec.COST_BASIS_CODE,
                  x_return_status => l_return_status);

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_COST_BASIS_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
         END IF;
         IF G_DEBUG='Y' THEN
          Ahl_Debug_Pub.debug ( l_full_name || ' COST BASIS CODE = ' || l_Resrc_Require_Rec.COST_BASIS_CODE);
          Ahl_Debug_Pub.debug ( l_full_name || ' SCHEDULED TYPE NAME = ' || l_Resrc_Require_Rec.SCHEDULED_TYPE_NAME);
          Ahl_Debug_Pub.debug ( l_full_name || ' SCHEDULED TYPE CODE = ' || l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE);
         END IF;
           -- For Scheduled Type
         IF ( l_Resrc_Require_Rec.SCHEDULED_TYPE_NAME IS NOT NULL AND
              l_Resrc_Require_Rec.SCHEDULED_TYPE_NAME <> Fnd_Api.G_MISS_CHAR )
         THEN
             Check_Lookup_Name_Or_Id (
                  p_lookup_type   => 'BOM_RESOURCE_SCHEDULE_TYPE',
                  p_lookup_code   => NULL,
                  p_meaning       => l_Resrc_Require_Rec.SCHEDULED_TYPE_NAME,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE,
                  x_return_status => l_return_status);

             IF NVL(l_return_status, 'X') <> 'S'
             THEN
                  Fnd_Message.SET_NAME('AHL','AHL_PP_SCHED_TYPE_NOT_EXISTS');
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
             END IF;
         END IF;
         IF G_DEBUG='Y' THEN
          Ahl_Debug_Pub.debug ( l_full_name || ' SCHEDULED TYPE CODE = ' || l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE);
          Ahl_Debug_Pub.debug ( l_full_name || ' STANDARD RATE FLAG = ' || l_Resrc_Require_Rec.STD_RATE_FLAG_CODE);
         END IF;
              -- To find meaning for fnd_lookups code
         IF (l_Resrc_Require_Rec.STD_RATE_FLAG_CODE IS NOT NULL AND
             l_Resrc_Require_Rec.STD_RATE_FLAG_CODE <> Fnd_Api.G_MISS_NUM) THEN
            SELECT meaning
              INTO l_std_rate_flag
            FROM MFG_LOOKUPS
            WHERE lookup_code = l_Resrc_Require_Rec.STD_RATE_FLAG_CODE
            AND LOOKUP_TYPE = 'BOM_NO_YES';
         END IF;

        -------------------------------- Validate -----------------------------------------

             Validate_Resrc_Require (
                  p_api_version        => l_api_version,
                  p_init_msg_list      => p_init_msg_list,
                  p_commit             => p_commit,
                  p_validation_level   => p_validation_level,
                  p_resrc_Require_rec   => l_Resrc_Require_Rec,
                  x_return_status      => l_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data
             );

          --Standard check to count messages
           l_msg_count := Fnd_Msg_Pub.count_msg;

           IF l_msg_count > 0 THEN
              x_msg_count := l_msg_count;
              x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
              RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
           END IF;

       --
       IF  l_Resrc_Require_Rec.Operation_Resource_id <> FND_API.G_MISS_NUM OR l_Resrc_Require_Rec.Operation_Resource_Id IS NOT NULL
       THEN
          -- These conditions are Required for optional fields

          -- Last Updated Date
          IF l_Resrc_Require_Rec.last_update_login = FND_API.G_MISS_NUM
          THEN
           l_Resrc_Require_Rec.last_update_login := NULL;
          ELSE
           l_Resrc_Require_Rec.last_update_login := l_Resrc_Require_Rec.last_update_login;
          END IF;
          -- Attribute Category
          IF l_Resrc_Require_Rec.attribute_category = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute_category := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute_category := l_Resrc_Require_Rec.attribute_category;
          END IF;
          -- Attribute1
          IF l_Resrc_Require_Rec.attribute1 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute1 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute1 := l_Resrc_Require_Rec.attribute1;
          END IF;
          -- Attribute2
          IF l_Resrc_Require_Rec.attribute2 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute2 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute2 := l_Resrc_Require_Rec.attribute2;
          END IF;
          -- Attribute3
          IF l_Resrc_Require_Rec.attribute3 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute3 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute3 := l_Resrc_Require_Rec.attribute3;
          END IF;
          -- Attribute4
          IF l_Resrc_Require_Rec.attribute4 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute4 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute4 := l_Resrc_Require_Rec.attribute4;
          END IF;
          -- Attribute5
          IF l_Resrc_Require_Rec.attribute5 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute5 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute5 := l_Resrc_Require_Rec.attribute5;
          END IF;
          -- Attribute6
          IF l_Resrc_Require_Rec.attribute6 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute6 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute6 := l_Resrc_Require_Rec.attribute6;
          END IF;
          -- Attribute7
          IF l_Resrc_Require_Rec.attribute7 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute7 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute7 := l_Resrc_Require_Rec.attribute7;
          END IF;
          -- Attribute8
          IF l_Resrc_Require_Rec.attribute8 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute8 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute8 := l_Resrc_Require_Rec.attribute8;
          END IF;
          -- Attribute9
          IF l_Resrc_Require_Rec.attribute9 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute9 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute9 := l_Resrc_Require_Rec.attribute9;
          END IF;
          -- Attribute10
          IF l_Resrc_Require_Rec.attribute10 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute10 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute10 := l_Resrc_Require_Rec.attribute10;
          END IF;
          -- Attribute11
          IF l_Resrc_Require_Rec.attribute11 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute11 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute11 := l_Resrc_Require_Rec.attribute11;
          END IF;
          -- Attribute12
          IF l_Resrc_Require_Rec.attribute12 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute12 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute12 := l_Resrc_Require_Rec.attribute12;
          END IF;
          -- Attribute13
          IF l_Resrc_Require_Rec.attribute13 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute13 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute13 := l_Resrc_Require_Rec.attribute13;
          END IF;
          -- Attribute14
          IF l_Resrc_Require_Rec.attribute14 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute14 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute14 := l_Resrc_Require_Rec.attribute14;
          END IF;
          -- Attribute15
          IF l_Resrc_Require_Rec.attribute15 = FND_API.G_MISS_CHAR
          THEN
           l_Resrc_Require_Rec.attribute15 := NULL;
          ELSE
           l_Resrc_Require_Rec.attribute15 := l_Resrc_Require_Rec.attribute15;
          END IF;

            p_x_resrc_Require_tbl(i)  := l_Resrc_Require_Rec;
          -- Check Object version number.
         IF G_DEBUG='Y' THEN
              Ahl_Debug_Pub.debug ( l_full_name || ' Record Object Version Nubmer = ' || l_resrc_Require_Rec.object_version_number);
              Ahl_Debug_Pub.debug ( l_full_name || ' Cursor Object Version Nubmer = ' || c_oper_req_rec.object_version_number);
           END IF;
          IF (c_oper_req_rec.object_version_number <> l_Resrc_Require_Rec.object_version_number)
          THEN
             Fnd_Message.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
             --
          END IF;

       END IF;
     END LOOP;
   END IF;

IF (p_interface_flag IS NULL) OR (p_interface_flag IS NOT NULL AND p_interface_flag = 'Y') THEN
    -- CALL Load_WIP_Jobs API
    -- If not sucess then not allowed to insert in our entity
       OPEN c_workorder(l_Resrc_Require_Rec.workorder_id);
       FETCH c_workorder INTO c_workorder_rec;
       CLOSE c_workorder;
       --

     j:=1;
    FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST
    LOOP
	   --
       OPEN c_work_orders(l_Resrc_Require_Rec.workorder_id);
       FETCH c_work_orders INTO l_work_order_rec;
       CLOSE c_work_orders;
       --
       l_Resrc_Require_Tbl(j).organization_id        := l_work_order_rec.organization_id;
       l_Resrc_Require_Tbl(j).wip_entity_id          := l_work_order_rec.wip_entity_id;
       l_Resrc_Require_Tbl(j).job_number             := l_work_order_rec.workorder_name;
       l_Resrc_Require_Tbl(j).workorder_id           := p_x_resrc_Require_tbl(i).WORKORDER_ID;
       l_Resrc_Require_Tbl(j).operation_seq_number   := p_x_resrc_Require_tbl(i).OPERATION_SEQ_NUMBER;
       l_Resrc_Require_Tbl(j).uom_code               := p_x_resrc_Require_tbl(i).UOM_CODE;
       l_Resrc_Require_Tbl(j).resource_seq_number    := p_x_resrc_Require_tbl(i).RESOURCE_SEQ_NUMBER;
       l_Resrc_Require_Tbl(j).resource_id            := p_x_resrc_Require_tbl(i).RESOURCE_ID;
       l_Resrc_Require_Tbl(j).duration               := p_x_resrc_Require_tbl(i).DURATION;
       l_Resrc_Require_Tbl(j).req_start_date         := p_x_resrc_Require_tbl(i).REQ_START_DATE;
       l_Resrc_Require_Tbl(j).req_end_date           := p_x_resrc_Require_tbl(i).REQ_END_DATE;
       l_Resrc_Require_Tbl(j).quantity               := p_x_resrc_Require_tbl(i).QUANTITY;
       l_Resrc_Require_Tbl(j).applied_num            := p_x_resrc_Require_tbl(i).QUANTITY;
       l_Resrc_Require_Tbl(j).open_num               := p_x_resrc_Require_tbl(i).QUANTITY;
       l_Resrc_Require_Tbl(j).cost_basis_code        := p_x_resrc_Require_tbl(i).COST_BASIS_CODE;
       l_Resrc_Require_Tbl(j).charge_type_code       := p_x_resrc_Require_tbl(i).CHARGE_TYPE_CODE;
       l_Resrc_Require_Tbl(j).std_rate_flag_code     := p_x_resrc_Require_tbl(i).STD_RATE_FLAG_CODE;
       l_Resrc_Require_Tbl(j).scheduled_type_code    := p_x_resrc_Require_tbl(i).SCHEDULED_TYPE_CODE;
-- JKJAIN US space FP for ER # 6998882-- start
 	   l_Resrc_Require_Tbl(j).schedule_seq_num    := p_x_resrc_Require_tbl(i).schedule_seq_num;
-- JKJAIN US space FP for ER # 6998882-- end
       l_Resrc_Require_Tbl(j).operation_flag         := 'U';
       --
  IF G_DEBUG='Y' THEN
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).WIP_ENTITY_ID: ' ||l_Resrc_Require_Tbl(j).WIP_ENTITY_ID  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).JOB_NUMBER: ' ||l_Resrc_Require_Tbl(j).JOB_NUMBER  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).UOM_CODE: ' ||l_Resrc_Require_Tbl(j).UOM_CODE  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).WORKORDER_ID: ' ||l_Resrc_Require_Tbl(j).WORKORDER_ID  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).ORGANIZATION_ID: ' ||l_Resrc_Require_Tbl(j).ORGANIZATION_ID  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).OPERATION_SEQ_NUM: ' ||l_Resrc_Require_Tbl(j).OPERATION_SEQ_NUMBER  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).RESOURCE_SEQ_NUM: ' ||l_Resrc_Require_Tbl(j).RESOURCE_SEQ_NUMBER  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).RESOURCE_ID: ' ||l_Resrc_Require_Tbl(j).RESOURCE_ID );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).QUANTITY: ' ||l_Resrc_Require_Tbl(j).QUANTITY );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).DURATION: ' ||l_Resrc_Require_Tbl(j).DURATION );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).REQ_START_DATE: ' ||l_Resrc_Require_Tbl(j).REQ_START_DATE );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).REQ_END_DATE: ' ||l_Resrc_Require_Tbl(j).REQ_END_DATE );
  END IF;

       -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
       Expand_Master_Wo_Dates(l_Resrc_Require_Tbl(j));
       -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end

       j := j + 1;
    END LOOP;

    -- Call AHL_EAN_JOB_PVT If the status is success then process
	AHL_EAM_JOB_PVT.process_resource_req
          (
           p_api_version          => p_api_version,
           p_init_msg_list        => p_init_msg_list,
           p_commit               => p_commit,
           p_validation_level     => p_validation_level,
           p_default              => l_default,
           p_module_type          => p_module_type,
           x_return_status        => l_return_status,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data,
           p_resource_req_tbl     => l_Resrc_Require_Tbl);

END IF;

IF l_return_status ='S' THEN
    IF p_x_resrc_Require_tbl.COUNT > 0 THEN
      FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST
      LOOP
           l_Resrc_Require_Rec := p_x_resrc_Require_tbl(i);
           IF  l_Resrc_Require_Rec.Operation_Resource_id <> FND_API.G_MISS_NUM
           THEN
                IF G_DEBUG='Y' THEN
                Ahl_Debug_Pub.debug ( l_full_name || 'after WORKORDER_OPERATION_ID = ' || l_Resrc_Require_Rec.WORKORDER_OPERATION_ID);
                Ahl_Debug_Pub.debug ( l_full_name || 'after RESOURCE_ID = ' || l_Resrc_Require_Rec.RESOURCE_ID);
                Ahl_Debug_Pub.debug ( l_full_name || 'after OBJECT_VERSION_NUBMER = ' || l_Resrc_Require_Rec.OBJECT_VERSION_NUMBER);
                END IF;

          -- Create Record in schedule Resources
            Update_Row (
                   X_OPERATION_RESOURCE_ID => l_Resrc_Require_Rec.OPERATION_RESOURCE_ID,
                   X_OBJECT_VERSION_NUMBER => l_Resrc_Require_Rec.OBJECT_VERSION_NUMBER,
                   X_RESOURCE_ID           => l_Resrc_Require_Rec.RESOURCE_ID,
                   X_WORKORDER_OPERATION_ID=> l_Resrc_Require_Rec.WORKORDER_OPERATION_ID,
                   X_RESOURCE_SEQ_NUMBER   => l_Resrc_Require_Rec.RESOURCE_SEQ_NUMBER,
                   X_UOM_CODE              => l_Resrc_Require_Rec.UOM_CODE,
                   X_QUANTITY              => l_Resrc_Require_Rec.QUANTITY,
                   X_DURATION              => l_Resrc_Require_Rec.DURATION,
                   X_SCHEDULED_START_DATE  => l_Resrc_Require_Rec.REQ_START_DATE,
                   X_SCHEDULED_END_DATE    => l_Resrc_Require_Rec.REQ_END_DATE,
                   X_ATTRIBUTE_CATEGORY    => l_Resrc_Require_Rec.attribute_category,
                   X_ATTRIBUTE1            => l_Resrc_Require_Rec.attribute1,
                   X_ATTRIBUTE2            => l_Resrc_Require_Rec.attribute2,
                   X_ATTRIBUTE3            => l_Resrc_Require_Rec.attribute3,
                   X_ATTRIBUTE4            => l_Resrc_Require_Rec.attribute4,
                   X_ATTRIBUTE5            => l_Resrc_Require_Rec.attribute5,
                   X_ATTRIBUTE6            => l_Resrc_Require_Rec.attribute6,
                   X_ATTRIBUTE7            => l_Resrc_Require_Rec.attribute7,
                   X_ATTRIBUTE8            => l_Resrc_Require_Rec.attribute8,
                   X_ATTRIBUTE9            => l_Resrc_Require_Rec.attribute9,
                   X_ATTRIBUTE10           => l_Resrc_Require_Rec.attribute10,
                   X_ATTRIBUTE11           => l_Resrc_Require_Rec.attribute11,
                   X_ATTRIBUTE12           => l_Resrc_Require_Rec.attribute12,
                   X_ATTRIBUTE13           => l_Resrc_Require_Rec.attribute13,
                   X_ATTRIBUTE14           => l_Resrc_Require_Rec.attribute14,
                   X_ATTRIBUTE15           => l_Resrc_Require_Rec.attribute15,
                   X_LAST_UPDATE_DATE      => SYSDATE,
                   X_LAST_UPDATED_BY       => fnd_global.user_id,
                   X_LAST_UPDATE_LOGIN     => fnd_global.login_id
                  );


IF G_DEBUG='Y' THEN
Ahl_Debug_Pub.debug ( 'l_Resrc_Require_Rec.CHARGE_TYPE_CODE:'||l_Resrc_Require_Rec.CHARGE_TYPE_CODE);
END IF;
                 p_x_resrc_Require_tbl(i)  := l_Resrc_Require_Rec;
              --Get the value from sequence
              SELECT AHL_WO_OPERATIONS_TXNS_S.NEXTVAL
                 INTO l_wo_operation_txn_id
              FROM DUAL;
              IF G_DEBUG='Y' THEN
              AHL_DEBUG_PUB.debug( 'before calling log record l_wo_operation_txn_id:'||l_wo_operation_txn_id);
              END IF;
           -- Create Record in transactions table
              AHL_PP_MATERIALS_PVT.Log_Transaction_Record
                   ( p_wo_operation_txn_id    => l_wo_operation_txn_id,
                     p_object_version_number  => 1,
                     p_last_update_date       => sysdate,
                     p_last_updated_by        => fnd_global.user_id,
                     p_creation_date          => sysdate,
                     p_created_by             => fnd_global.user_id,
                     p_last_update_login      => fnd_global.login_id,
                     p_load_type_code         => 1,
                     p_transaction_type_code  => 3,
                     p_workorder_operation_id => p_x_resrc_Require_tbl(i).workorder_operation_id,
                     p_bom_resource_id        => p_x_resrc_Require_tbl(i).Resource_id,
                     p_operation_resource_id  => p_x_resrc_Require_tbl(i).Operation_Resource_id,
                     p_res_sched_start_date   => p_x_resrc_Require_tbl(i).REQ_START_DATE,
                     p_res_sched_end_date     => p_x_resrc_Require_tbl(i).REQ_START_DATE
                   );

       END IF;
     END LOOP;
 END IF;
END IF;
   --
   ------------------------End of Body---------------------------------------
   -- Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of Update Resource Reqst +PPResrc_Require_Pvt+');

   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Resrc_Require;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
       IF G_DEBUG='Y' THEN
        -- Debug info.
       AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );

        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
        END IF;
 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Resrc_Require;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );

        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
		--
        END IF;
WHEN OTHERS THEN
    ROLLBACK TO Update_Resrc_Require;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_RESRC_Require_PVT',
                            p_procedure_name  =>  'UPDATE_Resrc_Require',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );

        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
      END IF;
END Update_Resrc_Require;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_Resource_Requirement
--
-- PURPOSE
--    Get a particular Resource Requirement with all details
--------------------------------------------------------------------
PROCEDURE Get_Resource_Requirement (
   p_api_version             IN   NUMBER,
   p_init_msg_list           IN   VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN   VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN   NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN   VARCHAR2  := 'JSP',
    p_x_resrc_Require_Tbl    IN OUT NOCOPY AHL_PP_RESRC_Require_PVT.Resrc_Require_Tbl_Type,
   x_return_status           OUT  NOCOPY VARCHAR2,
   x_msg_count               OUT  NOCOPY NUMBER,
   x_msg_data                OUT  NOCOPY VARCHAR2
)
IS
   L_API_VERSION          CONSTANT NUMBER := 1.0;
   L_API_NAME             CONSTANT VARCHAR2(30) := 'Get_Resource_Requirement';
   L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_Resrc_Require_Rec    AHL_PP_RESRC_Require_PVT.Resrc_Require_Rec_Type;

   l_resrc_type_name  VARCHAR2(80);
   l_resrc_type_code  VARCHAR2(30);
   l_unit_of_measure  VARCHAR2(30);
   l_resrc_name       VARCHAR2(10);
   l_std_rate_flag    VARCHAR2(10);
   l_charge_type      VARCHAR2(80);
   l_cost_basis       VARCHAR2(80);
   l_scheduled_type   VARCHAR2(80);

   l_applied        NUMBER;
   l_wo_oper_id     NUMBER;
   l_oper_seq_num   NUMBER;

   oper_start_date   DATE;
   oper_end_date     DATE;

   --pekambar start : changed for :: 9089320  FP for bug#8532919
   /*CURSOR c_res_req (x_id IN NUMBER) IS
	SELECT * FROM AHL_OPERATION_RESOURCES
	WHERE OPERATION_RESOURCE_ID = x_id;*/

	CURSOR c_res_req (x_id IN NUMBER) IS
 	         SELECT AOR.workorder_operation_id,
 	                 AOR.resource_id,
 	                 AOR.OPERATION_RESOURCE_ID,
 	                 AOR.object_version_number,
 	                 AOR.DURATION,
 	                 AOR.QUANTITY,
 	                 AOR.RESOURCE_SEQUENCE_NUM,
 	                 WOR.START_DATE "SCHEDULED_START_DATE",
 	                 WOR.COMPLETION_DATE "SCHEDULED_END_DATE"
 	         FROM AHL_OPERATION_RESOURCES AOR,
 	                 WIP_OPERATION_RESOURCES WOR,
 	                 AHL_WORKORDER_OPERATIONS AWO ,
 	                 AHL_WORKORDERS AWJ
 	         WHERE AOR.RESOURCE_ID         = WOR.RESOURCE_ID
 	                 AND WOR.RESOURCE_SEQ_NUM = AOR.RESOURCE_SEQUENCE_NUM
 	                 AND    AOR.WORKORDER_OPERATION_ID = AWO.WORKORDER_OPERATION_ID
 	                 AND    AWO.OPERATION_SEQUENCE_NUM = WOR.OPERATION_SEQ_NUM
 	                 AND    AWJ.WORKORDER_ID           = AWO.WORKORDER_ID
 	                 AND    AWJ.WIP_ENTITY_ID          = WOR.WIP_ENTITY_ID
 	                 AND AOR.OPERATION_RESOURCE_ID =  x_id;
   --pekambar End : changed for :: 9089320  FP for bug#8532919
   c_resrc_req c_res_req%ROWTYPE;

   CURSOR c_resource (x_id IN NUMBER) IS
     SELECT ML.MEANING, BR.RESOURCE_TYPE, BR.RESOURCE_CODE
        FROM BOM_RESOURCES BR, MFG_LOOKUPS ML, AHL_OPERATION_RESOURCES AOR
     WHERE BR.RESOURCE_TYPE = ML.LOOKUP_CODE
        AND ML.LOOKUP_TYPE= 'BOM_RESOURCE_TYPE'
        AND AOR.RESOURCE_ID = BR.RESOURCE_ID
        AND AOR.OPERATION_RESOURCE_ID = x_id;

   CURSOR c_WIP_oper (x_id IN NUMBER) IS
     SELECT WORV.* FROM
        AHL_OPERATION_RESOURCES AOR,
        AHL_WORKORDER_OPERATIONS AWO,
        AHL_WORKORDERS AW,
        WIP_OPERATION_RESOURCES_V WORV
     WHERE WORV.OPERATION_SEQ_NUM = AWO.OPERATION_SEQUENCE_NUM
        AND WORV.RESOURCE_SEQ_NUM = AOR.RESOURCE_SEQUENCE_NUM
        AND WORV.WIP_ENTITY_ID = AW.WIP_ENTITY_ID
        AND AW.WORKORDER_ID = AWO.WORKORDER_ID
        AND AWO.WORKORDER_OPERATION_ID = AOR.WORKORDER_OPERATION_ID
        AND AOR.OPERATION_RESOURCE_ID = x_id;
     c_WIP_oper_rec c_WIP_oper%ROWTYPE;

   CURSOR c_WO_oper(x_id IN NUMBER) IS
     SELECT OPERATION_SEQUENCE_NUM, SCHEDULED_START_DATE, SCHEDULED_END_DATE
       FROM AHL_WORKORDER_OPERATIONS_V
     WHERE WORKORDER_OPERATION_ID = x_id;

 /* R12 Perf Tuning
  * Balaji modified the query to use only base tables
  * instead of ahl_pp_requirement_v
  */
   CURSOR c_require (x_id IN NUMBER) IS
    /*
     SELECT *
       FROM ahl_pp_requirement_v
     WHERE REQUIREMENT_ID = x_id;
    */
   SELECT
         BOM.UNIT_OF_MEASURE uom_code,
	 MUOM.UNIT_OF_MEASURE UOM_NAME,
	 AWO.workorder_id job_id
   FROM
         BOM_RESOURCES BOM,
	 MTL_UNITS_OF_MEASURE MUOM,
	 AHL_OPERATION_RESOURCES AOR,
	 AHL_WORKORDER_OPERATIONS AWO
   WHERE
         AOR.OPERATION_RESOURCE_ID = x_id AND
	 AOR.RESOURCE_ID = BOM.RESOURCE_ID AND
	 BOM.UNIT_OF_MEASURE = MUOM.UOM_CODE AND
	 AOR.WORKORDER_OPERATION_ID = AWO.WORKORDER_OPERATION_ID;

   c_require_rec c_require%ROWTYPE;

   CURSOR c_lookups (x_lookup_type IN VARCHAR2, x_lookup_code IN VARCHAR2) IS
     SELECT meaning
        FROM MFG_LOOKUPS
     WHERE lookup_type = x_lookup_type
         AND lookup_code = x_lookup_code
         AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
         AND TRUNC(NVL(end_date_active,SYSDATE));

BEGIN
   -------------------------------- Initialize -----------------------
   -- Standard start of API savepoint
   SAVEPOINT Get_Resource_Requirement;
   IF G_DEBUG='Y' THEN
   -- Check if API is called in debug mode. If yes, enable debug.
   Ahl_Debug_Pub.enable_debug;
   --
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.debug ( l_full_name || ' Start ');
   END IF;

   -- Standard call to check for call compatibility.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_x_resrc_Require_tbl.COUNT > 0 THEN
     FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST
      LOOP
       l_Resrc_Require_Rec := p_x_resrc_Require_Tbl(i);
       ----------------------------------------- Cursor ----------------------------------
       IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug ( l_full_name || ' Operation Resource Id = ' || l_Resrc_Require_Rec.operation_resource_id);
	   END IF;
       OPEN c_res_req (l_Resrc_Require_Rec.operation_resource_id);
       FETCH c_res_req INTO c_resrc_req;
       CLOSE c_res_req;

       OPEN c_resource (l_Resrc_Require_Rec.operation_resource_id);
       FETCH c_resource INTO l_resrc_type_name, l_resrc_type_code, l_resrc_name;
       CLOSE c_resource;
       IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug ( l_full_name || ' Resource Type Name = ' || l_resrc_type_name);
       Ahl_Debug_Pub.debug ( l_full_name || ' Resource Type Code = ' || l_resrc_type_code);
       Ahl_Debug_Pub.debug ( l_full_name || ' Resource Name = ' || l_resrc_name);
       END IF;
       OPEN c_WO_oper (c_resrc_req.workorder_operation_id);
       FETCH c_WO_oper INTO l_oper_seq_num, oper_start_date, oper_end_date;
       CLOSE c_WO_oper;
       IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug ( l_full_name || ' Operation Sequence Number = ' || l_oper_seq_num);
       Ahl_Debug_Pub.debug ( l_full_name || ' Operation Start Date = ' || oper_start_date);
       Ahl_Debug_Pub.debug ( l_full_name || ' Operation End Date = ' || oper_end_date);
       Ahl_Debug_Pub.debug ( l_full_name || ' Resource Id = ' || c_resrc_req.resource_id);
       END IF;

       OPEN c_WIP_oper ( l_Resrc_Require_Rec.operation_resource_id);
       FETCH c_WIP_oper INTO c_WIP_oper_rec;
       CLOSE c_WIP_oper;

       OPEN c_require (l_Resrc_Require_Rec.operation_resource_id);
       FETCH c_require INTO c_require_rec;
       CLOSE c_require;

   ------------------------------------------ Start -----------------------------------
     -- Debug info.

     -- To find meaning for fnd_lookups code
    IF (c_WIP_oper_rec.STANDARD_RATE_FLAG IS NOT NULL) THEN
          SELECT meaning
              INTO l_std_rate_flag
            FROM MFG_LOOKUPS
          WHERE lookup_code = c_WIP_oper_rec.STANDARD_RATE_FLAG
          AND LOOKUP_TYPE = 'BOM_NO_YES';
    END IF;

   OPEN c_lookups ('CST_BASIS', c_WIP_oper_rec.basis_type);
   FETCH c_lookups INTO l_cost_basis;
   CLOSE c_lookups;

   OPEN c_lookups ('BOM_RESOURCE_SCHEDULE_TYPE', c_WIP_oper_rec.scheduled_flag);
   FETCH c_lookups INTO l_scheduled_type;
   CLOSE c_lookups;

       -- Assigning all visits field to visit record attributes meant for display

	l_Resrc_Require_Rec.OPERATION_RESOURCE_ID	:=  c_resrc_req.OPERATION_RESOURCE_ID ;
    l_Resrc_Require_Rec.OBJECT_VERSION_NUMBER   :=  c_resrc_req.object_version_number ;

	l_Resrc_Require_Rec.REQ_START_DATE		    :=  c_resrc_req.SCHEDULED_START_DATE ;
	l_Resrc_Require_Rec.REQ_END_DATE	        :=  c_resrc_req.SCHEDULED_END_DATE ;
 -- change for ER 3974014
	-- the duration entered into AHL_OPERATION_RESOURCES is now the total_duration of all
	-- the resources
	-- so total_required := c_resrc_rec.duration
	-- duration := c_resrc_rec.duration/quantity

    l_Resrc_Require_Rec.TOTAL_REQUIRED          := c_resrc_req.DURATION; -- (c_resrc_req.DURATION * c_resrc_req.QUANTITY);
        -- Balaji changed APPLIED_NUM to be c_WIP_oper_rec.APPLIED_RESOURCE_UNITS instead of
        -- c_WIP_oper_rec.APPLIED_RESOURCE_VALUE b'cos VALUE = UNITS * COST.
	l_Resrc_Require_Rec.APPLIED_NUM             :=  c_WIP_oper_rec.APPLIED_RESOURCE_UNITS;
	--l_Resrc_Require_Rec.APPLIED_NUM             :=  c_WIP_oper_rec.APPLIED_RESOURCE_VALUE;
  	l_Resrc_Require_Rec.OPEN_NUM       	        :=  (l_Resrc_Require_Rec.TOTAL_REQUIRED - l_Resrc_Require_Rec.APPLIED_NUM);

	l_Resrc_Require_Rec.STD_RATE_FLAG_NAME      :=  l_std_rate_flag;
	l_Resrc_Require_Rec.STD_RATE_FLAG_CODE      :=  c_WIP_oper_rec.Standard_Rate_Flag ;

    l_Resrc_Require_Rec.RESOURCE_SEQ_NUMBER     :=  c_resrc_req.RESOURCE_SEQUENCE_NUM;
    l_Resrc_Require_Rec.OPERATION_SEQ_NUMBER    :=  l_oper_seq_num;
-- JKJAIN US space FP for ER # 6998882
	l_Resrc_Require_Rec.SCHEDULE_SEQ_NUM         := c_WIP_oper_rec.SCHEDULE_SEQ_NUM;

    l_Resrc_Require_Rec.RESOURCE_TYPE_CODE      :=  l_resrc_type_code;
    l_Resrc_Require_Rec.RESOURCE_TYPE_NAME      :=  l_resrc_type_name;

    l_Resrc_Require_Rec.RESOURCE_ID             :=  c_resrc_req.RESOURCE_ID;
    l_Resrc_Require_Rec.RESOURCE_NAME           :=  l_resrc_name;

	l_Resrc_Require_Rec.OPER_START_DATE         :=  oper_start_date;
	l_Resrc_Require_Rec.OPER_END_DATE           :=  oper_end_date;
    -- ER 3974014
				IF c_resrc_req.QUANTITY = 0 THEN
    		l_Resrc_Require_Rec.DURATION              := 0;
				ELSE
						l_resrc_require_rec.DURATION              := c_resrc_req.DURATION/c_resrc_req.QUANTITY;
				END IF;
    l_Resrc_Require_Rec.QUANTITY                :=  c_resrc_req.QUANTITY;
    l_Resrc_Require_Rec.SET_UP                  :=  c_WIP_oper_rec.SETUP_ID;

    l_Resrc_Require_Rec.UOM_CODE                :=  c_require_rec.UOM_CODE;
    l_Resrc_Require_Rec.UOM_NAME                :=  c_require_rec.UOM_NAME;

    l_Resrc_Require_Rec.COST_BASIS_CODE         :=  c_WIP_oper_rec.BASIS_TYPE;
    l_Resrc_Require_Rec.COST_BASIS_NAME         :=  l_cost_basis;

    l_Resrc_Require_Rec.SCHEDULED_TYPE_CODE     :=  c_WIP_oper_rec.SCHEDULED_FLAG;
    l_Resrc_Require_Rec.SCHEDULED_TYPE_NAME     :=  l_scheduled_type;

				l_Resrc_Require_Rec.CHARGE_TYPE_CODE        :=  c_WIP_oper_rec.AUTOCHARGE_TYPE;
				l_Resrc_Require_Rec.CHARGE_TYPE_NAME        :=  c_WIP_oper_rec.AUTOCHARGE_CODE;

				-- ACL Changes

				l_Resrc_Require_Rec.IS_UNIT_LOCKED        :=  AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => c_require_rec.job_id,
																																																									p_ue_id => NULL,
																																																									p_visit_id => NULL,
																																																									p_item_instance_id => NULL);


     p_x_resrc_Require_Tbl(i) := l_Resrc_Require_Rec;
     /*Ahl_Debug_Pub.debug ( l_full_name || ' *********************values assing to output parameter***********************');
     Ahl_Debug_Pub.debug ( l_full_name || ' Work Order Id = ' || p_x_resrc_Require_tbl(i).WORKORDER_ID);
     Ahl_Debug_Pub.debug ( l_full_name || ' Operation Resource Id = ' || p_x_resrc_Require_tbl(i).operation_resource_id);
     Ahl_Debug_Pub.debug ( l_full_name || ' Resource Seq Num = ' || p_x_resrc_Require_tbl(i).RESOURCE_SEQ_NUMBER);
     Ahl_Debug_Pub.debug ( l_full_name || ' Operation Seq Num = ' || p_x_resrc_Require_tbl(i).OPERATION_SEQ_NUMBER);
     Ahl_Debug_Pub.debug ( l_full_name || ' Operation Start = ' || p_x_resrc_Require_tbl(i).OPER_START_DATE);
     Ahl_Debug_Pub.debug ( l_full_name || ' Operation End = ' || p_x_resrc_Require_tbl(i).OPER_END_DATE);*/

    END LOOP;
 END IF;
    -- Standard call to get message count and if count is 1, get message info
    Fnd_Msg_Pub.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data,
          p_encoded => Fnd_Api.g_false);

    -- Check if API is called in debug mode. If yes, enable debug.
    IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.enable_debug;
    END IF;
    -- Debug info.
    IF Ahl_Debug_Pub.G_FILE_DEBUG THEN
       Ahl_Debug_Pub.debug( L_FULL_NAME || '- End');
    END IF;

   -- Check if API is called in debug mode. If yes, disable debug.
    Ahl_Debug_Pub.disable_debug;
    RETURN;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   ROLLBACK TO Get_Resource_Requirement;
   Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => Fnd_Api.g_false);


 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Get_Resource_Requirement;
   Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN OTHERS THEN
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_Resource_Requirement;
    Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => 'Get_Resource_Requirement',
                             p_error_text     => SQLERRM);

    Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
                               p_data    => x_msg_data,
                               p_encoded => Fnd_Api.g_false);
END Get_Resource_Requirement;
--
PROCEDURE Remove_Resource_Requirement (
   p_api_version             IN    NUMBER,
   p_init_msg_list           IN    VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN    VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN    NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN    VARCHAR2  := 'JSP',
   p_interface_flag         IN     VARCHAR2,
   p_x_resrc_Require_Tbl    IN OUT NOCOPY AHL_PP_RESRC_Require_PVT.Resrc_Require_Tbl_Type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
 --
 CURSOR Get_resource_cur (c_op_resource_id IN NUMBER)
 IS
  SELECT * FROM AHL_OPERATION_RESOURCES
  WHERE operation_resource_id = c_op_resource_id;
 --
 /* R12 Perf Tuning
  * Balaji modified the query to use only base tables
  * instead of AHL_WORKORDERS_V
  */
 CURSOR Get_job_number(c_workorder_id IN NUMBER)
    IS
 SELECT
  wo.workorder_name,
  wdj.organization_id,
  wo.wip_entity_id
 FROM
  ahl_workorders wo,
  wip_discrete_jobs wdj
 WHERE
  wo.workorder_id = c_workorder_id AND
  wdj.wip_entity_id = wo.wip_entity_id;

 --
 CURSOR Get_wo_oper_cur (c_wo_operation_id IN NUMBER)
   IS
  SELECT * FROM ahl_workorder_operations_v
  WHERE workorder_operation_id = c_wo_operation_id;

 --
 CURSOR c_chk_assgn (oper_resrc_id IN NUMBER)
  IS
 SELECT count(*) FROM AHL_WORK_ASSIGNMENTS
  WHERE OPERATION_RESOURCE_ID = oper_resrc_id;
   -- Get uom from bom resources
   CURSOR c_uom_code (x_id IN NUMBER)
    IS
   SELECT unit_of_measure
     FROM bom_resources
    WHERE resource_id = x_id;
 -- Get cost basis, std rate flag,charge type code
   CURSOR c_wip_oper_res (c_wip_entity_id IN NUMBER,
                          c_oper_seq      IN NUMBER,
						  c_res_seq_num   IN NUMBER)
    IS
	 SELECT * FROM WIP_OPERATION_RESOURCES
	  WHERE WIP_ENTITY_ID = c_wip_entity_id
	    AND OPERATION_SEQ_NUM = c_oper_seq
		AND RESOURCE_SEQ_NUM = c_res_seq_num;


 -- check resource txns.
 CURSOR check_resrc_txn (p_wip_entity_id IN NUMBER,
                         p_organization_id IN NUMBER,
                         p_op_seq          IN NUMBER,
                         p_res_seq         IN NUMBER)
 IS
    SELECT 'x' FROM DUAL
    WHERE EXISTS ( SELECT 'x'
                   FROM WIP_TRANSACTIONS
                   WHERE wip_entity_id = p_wip_entity_id
                     AND organization_id = p_organization_id
                     AND operation_seq_num = p_op_seq
                     AND resource_seq_num  = p_res_seq )
       OR EXISTS (SELECT 'x'
                  FROM WIP_COST_TXN_INTERFACE
                  WHERE wip_entity_id = p_wip_entity_id
                    AND organization_id = p_organization_id
                    AND operation_seq_num = p_op_seq
                    AND resource_seq_num  = p_res_seq);

 l_api_name        CONSTANT VARCHAR2(30) := 'Remove_Resource_Requirement';
 l_api_version     CONSTANT NUMBER       := 1.0;

 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(200);
 l_return_status            VARCHAR2(1);
 l_error_message            VARCHAR2(30);
 l_job_number               VARCHAR2(80);
 l_organization_id          NUMBER;
 l_wo_operation_txn_id      NUMBER;
 l_count                    NUMBER;
 l_std_rate_flag            VARCHAR2(10);
 l_uom_code                 VARCHAR2(10);
 l_resource_rec             Get_resource_cur%ROWTYPE;
 l_wo_oper_rec              Get_wo_oper_cur%ROWTYPE;
 l_resrc_Require_Tbl        Resrc_Require_Tbl_Type;
 l_Resrc_Require_Rec        Resrc_Require_Rec_Type;
 --
 l_wip_oper_res_rec c_wip_oper_res%ROWTYPE;
 l_wip_entity_id            NUMBER;
 j NUMBER;
 l_default                  VARCHAR2(10);
 l_junk                     VARCHAR2(1);


 BEGIN
  --------------------Initialize ----------------------------------
   -- Standard Start of API savepoint
   SAVEPOINT Remove_Resource_Requirement;

   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;

   -- Debug info.
   Ahl_Debug_Pub.debug( 'Enter ahl_pp_resrc_require_pvt Remove Resource Requirement +APRRP+');
   END IF;
   -- Standard call to check for call compatibility.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

 ------------------------Start API Body ---------------------------------

   IF p_x_resrc_Require_tbl.COUNT > 0 THEN
     FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST
      LOOP
        --
       IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( ' p_x_resrc_Require_tbl(i).operation_resource_id = ' || p_x_resrc_Require_tbl(i).operation_resource_id);
       END IF;
	   --
        IF (p_x_resrc_Require_tbl(i).operation_resource_id IS NOT NULL AND
            p_x_resrc_Require_tbl(i).operation_resource_id <> FND_API.G_MISS_NUM)
        THEN
           --
           OPEN Get_resource_cur (p_x_resrc_Require_tbl(i).operation_resource_id);
           FETCH Get_resource_cur INTO l_resource_rec;
           IF Get_resource_cur%NOTFOUND THEN
             Fnd_Message.Set_Name('AHL','AHL_PP_RECORD_INVALID');
             Fnd_Msg_Pub.ADD;
             CLOSE Get_resource_cur;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;
           CLOSE Get_resource_cur;
        END IF;
		--
        IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( ' l_resource_rec.resource_id = ' || l_resource_rec.resource_id);
        END IF;
		--
        --Check for object version number
        IF (p_x_resrc_Require_tbl(i).object_version_number IS NOT NULL AND
            p_x_resrc_Require_tbl(i).object_version_number <> FND_API.G_MISS_NUM)
        THEN
          IF(p_x_resrc_Require_tbl(i).object_version_number <> l_resource_rec.object_version_number )
           THEN
             --
             Fnd_Message.Set_Name('AHL','AHL_COM_RECORD_CHANGED');
             Fnd_Msg_Pub.ADD;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        --
        --Get workorder id, operation sequence number
        OPEN Get_wo_oper_cur (l_resource_rec.workorder_operation_id);
        FETCH Get_wo_oper_cur INTO l_wo_oper_rec;
        CLOSE Get_wo_oper_cur;
        --
        --Assign the values
        p_x_resrc_Require_tbl(i).RESOURCE_SEQ_NUMBER  := l_resource_rec.resource_sequence_num;
        p_x_resrc_Require_tbl(i).RESOURCE_ID          := l_resource_rec.resource_id;
        p_x_resrc_Require_tbl(i).OPERATION_SEQ_NUMBER := l_wo_oper_rec.operation_sequence_num;
        p_x_resrc_Require_tbl(i).WORKORDER_ID         := l_wo_oper_rec.workorder_id;
        p_x_resrc_Require_tbl(i).DURATION             := l_resource_rec.duration;
        p_x_resrc_Require_tbl(i).REQ_START_DATE       := l_resource_rec.scheduled_start_date;
        p_x_resrc_Require_tbl(i).REQ_END_DATE         := l_resource_rec.scheduled_end_date;
        p_x_resrc_Require_tbl(i).QUANTITY             := l_resource_rec.quantity;
        -- Get workorder details
        --
        OPEN Get_job_number(p_x_resrc_require_tbl(i).workorder_id);
        FETCH Get_job_number INTO l_job_number, l_organization_id,l_wip_entity_id;
        CLOSE Get_job_number;

        -- rroy
        -- ACL changes

        l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(
                             p_workorder_id => p_x_resrc_require_tbl(i).workorder_id,
                             p_ue_id => NULL,
                             p_visit_id => NULL,
                             p_item_instance_id => NULL);
        IF l_return_status = FND_API.G_TRUE THEN
           FND_MESSAGE.Set_Name('AHL', 'AHL_PP_DEL_RESREQ_UNTLCKD');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- rroy
        -- ACL changes

        -- validate if there are any resource txns.
        OPEN check_resrc_txn(l_wip_entity_id, l_organization_id,
                             l_wo_oper_rec.operation_sequence_num,
                             l_resource_rec.resource_sequence_num);
        FETCH check_resrc_txn INTO l_junk;
        IF (check_resrc_txn%FOUND) THEN
           FND_MESSAGE.Set_Name('AHL', 'AHL_PP_DEL_RESREQ_RESTXN');
           FND_MESSAGE.Set_Token('OPER_RES', l_wo_oper_rec.operation_sequence_num || '-' || l_resource_rec.resource_sequence_num);
           FND_MSG_PUB.ADD;
           CLOSE check_resrc_txn;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE check_resrc_txn;

        -- Get operation Resource details
        OPEN c_wip_oper_res (l_wip_entity_id,
                             l_wo_oper_rec.operation_sequence_num,
                             l_resource_rec.resource_sequence_num);
        FETCH c_wip_oper_res INTO l_wip_oper_res_rec;
        CLOSE c_wip_oper_res;
		--
        IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug ( ' AutoCharge Code = ' || l_wip_oper_res_rec.AUTOCHARGE_TYPE);
         Ahl_Debug_Pub.debug ( ' COST BASIS = ' || l_wip_oper_res_rec.BASIS_TYPE);
         Ahl_Debug_Pub.debug ( ' STANDARD_RATE_FLAG = ' || l_wip_oper_res_rec.STANDARD_RATE_FLAG);
         Ahl_Debug_Pub.debug ( ' l_Resrc_Require_Rec.Resource_Id = ' || l_Resrc_Require_Rec.Resource_Id);
        END IF;
		--Assign Org,Wip entity details
        p_x_resrc_Require_tbl(i).ORGANIZATION_ID := l_organization_id;
        p_x_resrc_Require_tbl(i).WIP_ENTITY_ID := l_wip_entity_id;
        p_x_resrc_Require_tbl(i).CHARGE_TYPE_CODE := l_wip_oper_res_rec.AUTOCHARGE_TYPE;
        p_x_resrc_Require_tbl(i).COST_BASIS_CODE :=  l_wip_oper_res_rec.BASIS_TYPE;
        p_x_resrc_Require_tbl(i).std_rate_flag_code := l_wip_oper_res_rec.STANDARD_RATE_FLAG;
        p_x_resrc_Require_tbl(i).scheduled_type_code := l_wip_oper_res_rec.SCHEDULED_FLAG;
        --Check for Eam code
        OPEN c_uom_code(l_Resource_Rec.Resource_Id);
        FETCH c_uom_code INTO l_uom_code;
		CLOSE c_uom_code;
        --
        IF G_DEBUG='Y' THEN
		 Ahl_Debug_Pub.debug ('l_UOM_CODE: ' ||l_uom_code );
		END IF;
        --
         p_x_resrc_Require_tbl(i).UOM_CODE := l_uom_code;

       IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug ('Inside validation RESEQ'||p_x_resrc_Require_tbl(i).RESOURCE_SEQ_NUMBER);
       Ahl_Debug_Pub.debug ('Inside validationRESOURCES'||p_x_resrc_Require_tbl(i).RESOURCE_ID);
       Ahl_Debug_Pub.debug ('Inside OPERATIONSEQ:'||p_x_resrc_Require_tbl(i).OPERATION_SEQ_NUMBER);
       Ahl_Debug_Pub.debug ('Inside woid:'||p_x_resrc_Require_tbl(i).workorder_id);
       Ahl_Debug_Pub.debug ('Inside operation resource:'||p_x_resrc_Require_tbl(i).operation_resource_id);
       Ahl_Debug_Pub.debug ('Inside OVN:'||p_x_resrc_Require_tbl(i).object_version_number);
       Ahl_Debug_Pub.debug ('l_Resrc_Require_Rec.UOM_CODE: ' ||p_x_resrc_Require_tbl(i).uom_code );

       END IF;
   l_msg_count := Fnd_Msg_Pub.count_msg;
  IF G_DEBUG='Y' THEN
  Ahl_Debug_Pub.debug ( 'msg count:'||l_msg_count);
  END IF;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

     END LOOP;
   END IF; --Count
    --
IF x_return_status = 'S' THEN
    -- Assign before calling  Ahl Eam Job API
     j:=1;
    FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST
    LOOP
       Ahl_Debug_Pub.debug ( 'CALL FOR WIP JOBS');
       l_resrc_Require_Tbl(j).organization_id       := p_x_resrc_Require_tbl(i).ORGANIZATION_ID;
       l_resrc_Require_Tbl(j).wip_entity_id         := p_x_resrc_Require_tbl(i).WIP_ENTITY_ID;
       l_Resrc_Require_Tbl(j).workorder_id          := p_x_resrc_Require_tbl(i).WORKORDER_ID;
       l_resrc_Require_Tbl(j).operation_seq_number  := p_x_resrc_Require_tbl(i).OPERATION_SEQ_NUMBER;
       l_resrc_Require_Tbl(j).resource_seq_number   := p_x_resrc_Require_tbl(i).RESOURCE_SEQ_NUMBER;
       l_resrc_Require_Tbl(j).resource_id           := p_x_resrc_Require_tbl(i).RESOURCE_ID;
       l_Resrc_Require_Tbl(j).uom_code              := p_x_resrc_Require_tbl(i).UOM_CODE;
       l_Resrc_Require_Tbl(j).duration              := p_x_resrc_Require_tbl(i).DURATION;
       l_Resrc_Require_Tbl(j).req_start_date        := p_x_resrc_Require_tbl(i).REQ_START_DATE;
       l_Resrc_Require_Tbl(j).req_end_date          := p_x_resrc_Require_tbl(i).REQ_END_DATE;
       l_Resrc_Require_Tbl(j).quantity              := p_x_resrc_Require_tbl(i).QUANTITY;
       l_Resrc_Require_Tbl(j).cost_basis_code       := p_x_resrc_Require_tbl(i).COST_BASIS_CODE;
       l_Resrc_Require_Tbl(j).charge_type_code      := p_x_resrc_Require_tbl(i).CHARGE_TYPE_CODE;
       l_Resrc_Require_Tbl(j).std_rate_flag_code    := p_x_resrc_Require_tbl(i).STD_RATE_FLAG_CODE;
       l_Resrc_Require_Tbl(j).scheduled_type_code    := p_x_resrc_Require_tbl(i).SCHEDULED_TYPE_CODE;
       l_resrc_Require_Tbl(j).operation_flag        := 'D';
       --
  IF G_DEBUG='Y' THEN
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).WIP_ENTITY_ID: ' ||l_Resrc_Require_Tbl(j).WIP_ENTITY_ID  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).WORKORDER_ID: ' ||l_Resrc_Require_Tbl(j).WORKORDER_ID  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).ORGANIZATION_ID: ' ||l_Resrc_Require_Tbl(j).ORGANIZATION_ID  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).OPERATION_SEQ_NUM: ' ||l_Resrc_Require_Tbl(j).OPERATION_SEQ_NUMBER  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).RESOURCE_SEQ_NUM: ' ||l_Resrc_Require_Tbl(j).RESOURCE_SEQ_NUMBER  );
  Ahl_Debug_Pub.debug ('l_Resrc_Require_Tbl(j).RESOURCE_ID: ' ||l_Resrc_Require_Tbl(j).RESOURCE_ID );

  END IF;

       j := j + 1;
    END LOOP;

    -- Call AHL_EAN_JOB_PVT If the status is success then process
	AHL_EAM_JOB_PVT.process_resource_req
          (
           p_api_version          => p_api_version,
           p_init_msg_list        => p_init_msg_list,
           p_commit               => p_commit,
           p_validation_level     => p_validation_level,
           p_default              => l_default,
           p_module_type          => p_module_type,
           x_return_status        => l_return_status,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data,
           p_resource_req_tbl     => l_Resrc_Require_Tbl);

 END IF; -- X STATUS

IF l_return_status = 'S' THEN
   IF p_x_resrc_Require_tbl.COUNT > 0 THEN
     FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST
      LOOP
            OPEN c_chk_assgn (p_x_resrc_Require_tbl(i).Operation_Resource_Id);
            FETCH c_chk_assgn INTO l_count;
            CLOSE c_chk_assgn;

            IF l_count > 0 THEN
                Ahl_Debug_Pub.debug ('Count in Assignments table' || l_count);
                Fnd_Message.SET_NAME('AHL','AHL_PP_RESRC_ASSIGN_EXITS');
                FND_MESSAGE.SET_TOKEN('RECORD',p_x_resrc_Require_tbl(i).RESOURCE_SEQ_NUMBER,FALSE);
                Fnd_Msg_Pub.ADD;
            ELSE
                Ahl_Debug_Pub.debug ('Count in Assignments table' || l_count);
                Ahl_Debug_Pub.debug ('BEFORE DELETE RESOURCES' || p_x_resrc_Require_tbl(i).Operation_Resource_Id);
                DELETE FROM AHL_OPERATION_RESOURCES
                   WHERE OPERATION_RESOURCE_ID = p_x_resrc_Require_tbl(i).operation_resource_id;
            END IF;
     END LOOP;
   END IF;--Count
END IF; --Return status

---------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Remove Resource Requirement +MAMRP+');

   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Remove_Resource_Requirement;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );

        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
        END IF;
WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO Remove_Resource_Requirement;
    X_return_status := Fnd_Api.G_RET_STS_ERROR;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );

        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
       END IF;

WHEN OTHERS THEN
    ROLLBACK TO Remove_Resource_Requirement;
    X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
    Fnd_Msg_Pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_RESRC_Require_PVT',
                            p_procedure_name  =>  'Remove_Resource_Requirement',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        Ahl_Debug_Pub.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );

        -- Check if API is called in debug mode. If yes, disable debug.
        Ahl_Debug_Pub.disable_debug;
        END IF;
END Remove_Resource_Requirement;

----------------------------------------------------------------------------------
-- Public Procedure Definitions follow --
----------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Process_Resrc_Require
--  Type              : Private
--  Function          : Process ............................based on operation flag
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process Resource Requirement Parameters:
--       p_x_resrc_Require_tbl     IN OUT NOCOPY AHL_PP_RESRC_Require_PVT.Resrc_Require_Tbl_Type,
--         Contains........................     on operation flag
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Process_Resrc_Require (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_operation_flag         IN            VARCHAR2,
    p_interface_flag         IN            VARCHAR2,
    p_x_resrc_Require_tbl     IN OUT NOCOPY AHL_PP_RESRC_Require_PVT.Resrc_Require_Tbl_Type,
    x_return_status             OUT  NOCOPY       VARCHAR2,
    x_msg_count                 OUT  NOCOPY       NUMBER,
    x_msg_data                  OUT  NOCOPY       VARCHAR2
   )
 IS
 l_api_name        CONSTANT VARCHAR2(30) := 'Process_Resrc_Require';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_resrc_Require_rec        AHL_PP_RESRC_Require_PVT.Resrc_Require_Rec_Type;
 l_up_workorder_rec  AHL_PRD_WORKORDER_PVT.prd_workorder_rec;
 l_up_workoper_tbl   AHL_PRD_WORKORDER_PVT.prd_workoper_tbl;
 l_plan_flag  NUMBER;

  CURSOR c_check_planned_wo(c_workorder_id IN NUMBER)
  IS
  SELECT
    WDJ.firm_planned_flag
  FROM
    WIP_DISCRETE_JOBS WDJ,
    AHL_WORKORDERS AWO
  WHERE
    AWO.wip_entity_id = WDJ.wip_entity_id AND
   AWO.workorder_id = c_workorder_id;

 BEGIN
   --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT Process_Resrc_Require;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   -- Debug info.
   Ahl_Debug_Pub.debug( 'Enter AHL_PP_RESRC_Require.process_resrc_Require +PPResrc_Require_Pvt+');
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
   --------------------Start of API Body-----------------------------------
         IF p_operation_flag = 'C' THEN
              --
              -- Call create Resource Requirement
                 Create_Resrc_Require (
                      p_api_version         => p_api_version,
                      p_init_msg_list       => p_init_msg_list,
                      p_commit              => p_commit,
                      p_validation_level    => p_validation_level,
                      p_module_type         => p_module_type,
                      p_interface_flag      => p_interface_flag,
                      p_x_resrc_Require_tbl => p_x_resrc_Require_tbl,
                      x_return_status       => l_return_status,
                      x_msg_count           => l_msg_count,
                      x_msg_data            => l_msg_data
                     ) ;
             IF G_DEBUG='Y' THEN
             Ahl_Debug_Pub.debug('AFTER CREATE_RESRC_REQUIRE');
			 END IF;
           ELSIF p_operation_flag = 'U' THEN
             IF G_DEBUG='Y' THEN
             Ahl_Debug_Pub.debug( 'after update'||p_operation_flag);
             END IF;
               -- Call Update Resource Requirement
               Update_Resrc_Require (
                  p_api_version         => p_api_version,
                  p_init_msg_list       => p_init_msg_list,
                  p_commit              => p_commit,
                  p_validation_level    => p_validation_level,
                  p_module_type         => p_module_type,
                  p_interface_flag      => Null,
                  p_x_resrc_Require_tbl => p_x_resrc_Require_tbl,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data
                  );

           ELSIF p_operation_flag = 'D' THEN

                -- Call Remove Resource Requirement
              Remove_Resource_Requirement (
                   p_api_version       => p_api_version,
                   p_init_msg_list     => p_init_msg_list,
                   p_commit            => p_commit,
                   p_validation_level  => p_validation_level,
                   p_module_type       => p_module_type,
                   p_interface_flag    => NULL,
                   p_x_resrc_Require_tbl => p_x_resrc_Require_tbl,
                   x_return_status     => l_return_status,
                   x_msg_count         => l_msg_count,
                   x_msg_data          => l_msg_data
                   );

           ELSIF p_operation_flag = 'L' THEN

                 -- Call to Get Resource Requirement
              Get_Resource_Requirement (
                   p_api_version       => p_api_version,
                   p_init_msg_list     => p_init_msg_list,
                   p_commit            => p_commit,
                   p_validation_level  => p_validation_level,
                   p_module_type       => p_module_type,
                   p_x_resrc_Require_tbl => p_x_resrc_Require_tbl,
                   x_return_status     => l_return_status,
                   x_msg_count         => l_msg_count,
                   x_msg_data          => l_msg_data
                   );
          END IF;
   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;
   IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Balaji added following piece of code for bug # 5099536
   -- Update_Job API is called to recalculate Master workorder actual dates
   -- after altering resource requirement for a child workorder.
   -- Child workorder scheduled dates are re-calculated correctly by EAM
   -- when resource requirements are altered(Added/Removed/Updated) provided
   -- the Firm_Planned_Flag is set to "Planned" where as
   -- master workorder dates are not recalculated by EAM properly.

   -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- start
   FOR l_res_count IN p_x_resrc_Require_tbl.FIRST .. p_x_resrc_Require_tbl.LAST
   LOOP

       OPEN c_check_planned_wo(p_x_resrc_Require_tbl(l_res_count).workorder_id);
       FETCH c_check_planned_wo INTO l_plan_flag;
       CLOSE c_check_planned_wo;

       IF l_plan_flag = 2 THEN

	 AHL_PRD_WORKORDER_PVT.Update_Master_Wo_Dates(p_x_resrc_Require_tbl(l_res_count).workorder_id);

       END IF;

   END LOOP;
   /*
   IF (
       ( p_operation_flag = 'C' OR p_operation_flag = 'U' OR p_operation_flag = 'D')
       AND
       l_msg_count = 0
      )
   THEN

        FOR i IN p_x_resrc_Require_tbl.FIRST..p_x_resrc_Require_tbl.LAST LOOP
              OPEN c_check_planned_wo(p_x_resrc_Require_tbl(i).workorder_id);
  	      FETCH c_check_planned_wo INTO l_plan_flag;
	      CLOSE c_check_planned_wo;

	      IF l_plan_flag = 2 THEN

		   l_up_workorder_rec.WORKORDER_ID := p_x_resrc_Require_tbl(i).workorder_id;

		   AHL_PRD_WORKORDER_PVT.update_job
		   (
		     p_api_version            => 1.0                        ,
		     p_init_msg_list          => FND_API.G_FALSE            ,
		     p_commit                 => FND_API.G_FALSE            ,
		     p_validation_level       => FND_API.G_VALID_LEVEL_FULL ,
		     p_default                => FND_API.G_TRUE             ,
		     p_module_type            => NULL                       ,
		     x_return_status          => l_return_status            ,
		     x_msg_count              => l_msg_count                ,
		     x_msg_data               => l_msg_data                 ,
		     p_wip_load_flag          => 'Y'		            ,
		     p_x_prd_workorder_rec    => l_up_workorder_rec         ,
		     p_x_prd_workoper_tbl     => l_up_workoper_tbl
		   );

		   IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
		     RAISE FND_API.G_EXC_ERROR;
		   END IF;

		END IF;
	  END LOOP;
   END IF;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   */
   -- Fix for Bug # 8329755 (FP for Bug # 7697909) -- end

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   IF G_DEBUG='Y' THEN
   -- Debug info
   Ahl_Debug_Pub.debug( 'End of public api Process Resource Requirement + PPResrc_Require_Pvt+');

   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Process_Resrc_Require;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
       IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
      END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Process_Resrc_Require;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
        IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
        END IF;
WHEN OTHERS THEN
    ROLLBACK TO Process_Resrc_Require;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_PP_RESRC_Require_PVT',
                            p_procedure_name  =>  'Process_Resrc_Require',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
       IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
              x_msg_count, x_msg_data, 'SQL ERROR' );
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
       END IF;
END Process_Resrc_Require;

END AHL_PP_RESRC_Require_PVT;

/
