--------------------------------------------------------
--  DDL for Package Body AHL_VWP_VISITS_STAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_VISITS_STAGES_PVT" AS
/* $Header: AHLVSTGB.pls 120.0.12010000.3 2010/02/24 14:19:36 skpathak ship $ */

-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_VISITS_STAGES_PVT
--
-- PURPOSE
--    This package specification is a Private API for managing
--    Planning --> Visit Work Package --> VISITS --> STAGES
--    related procedures in Complex Maintainance, Repair and Overhauling(CMRO).
--
--    It defines used pl/sql records and tables datatypes
--
--
-- NOTES
--
--
-- HISTORY
-- 04-FEB-2004    ADHARIA       POST 11.5.10 Created.

-----------------------------------------------------------------
--   Define Global CONSTANTS                                   --
-----------------------------------------------------------------
G_PKG_NAME             CONSTANT VARCHAR2(30) := 'AHL_VWP_VISIT_STAGES_PVT';
G_DEBUG 		        VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;
---------------------------------------------------------------------
--   Define Record Types for record structures needed by the APIs  --
---------------------------------------------------------------------
-- NO RECORD TYPES *************

--------------------------------------------------------------------
-- Define Table Type for Records Structures                       --
--------------------------------------------------------------------
TYPE Dept_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------
--  START: Defining local functions and procedures SIGNATURES     --
--------------------------------------------------------------------
FUNCTION  Get_Stage_Id
RETURN NUMBER;

PROCEDURE VALIDATE_STAGES(
   p_visit_id		     in number,
   p_stages_rec              IN     Visit_Stages_Rec_Type,
   x_return_status           OUT    NOCOPY VARCHAR2,
   x_msg_count               OUT    NOCOPY NUMBER,
   x_msg_data                OUT    NOCOPY VARCHAR2
);

procedure default_missing_attributes(
   p_x_stages_rec              IN OUT NOCOPY     Visit_Stages_Rec_Type
);

--Added by amagrawa
PROCEDURE Validate_bef_Times_Derive
 ( p_visit_id	      IN	NUMBER,
   x_valid_flag       OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_error_msg_code   OUT NOCOPY VARCHAR2
   );
--End of changes by amagrawa
--------------------------------------------------------------------
--  END: Defining local functions and procedures SIGNATURES       --
--------------------------------------------------------------------

-- ****************************************************************

--------------------------------------------------------------------
-- START: Defining local functions and procedures BODY            --
--------------------------------------------------------------------

--------------------------------------------------------------------
-- END: Defining local functions and procedures BODY              --
--------------------------------------------------------------------

-- *************************************************************

----------------------------------------------------------------------
-- START: Defining procedures BODY, which are called from UI screen --
----------------------------------------------------------------------

--------------------------------------------------------------------
-- PROCEDURE
--    Get_Stages_Details
--
-- PURPOSE
--    Get a particular Stage Records with all details
--------------------------------------------------------------------
PROCEDURE Get_Stages_Details (
   p_api_version             IN   NUMBER,
   p_init_msg_list           IN   VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN   VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN   NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN   VARCHAR2  := 'JSP',
   p_visit_id                IN   NUMBER,
   p_start_row               IN   NUMBER,
   p_rows_per_page           IN	  NUMBER,


   x_stages_tbl               OUT  NOCOPY Visit_stages_tbl_Type,
   x_row_count               OUT  NOCOPY NUMBER,

   x_return_status           OUT  NOCOPY VARCHAR2,
   x_msg_count               OUT  NOCOPY NUMBER,
   x_msg_data                OUT  NOCOPY VARCHAR2
)
IS

   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Get_Stages_Details';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_msg_data           VARCHAR2(2000);
   l_return_status      VARCHAR2(1);
   l_valid_flag         VARCHAR2(1) := 'N';
   l_stages_tbl         Visit_stages_tbl_Type;
   l_st_ind                  number := 0;
   l_dept_id		     number;
   l_visit_start_date    DATE;

   l_cum_duration        NUMBER :=0;


-- To find visit related information
CURSOR c_visit (x_id IN NUMBER)
IS
      SELECT START_DATE_TIME , department_id FROM AHL_VISITS_VL
      WHERE VISIT_ID = x_id;
--
-- SATHAPLI::DFF Project, 05-Jan-2010, fetch the DFF data as well
/*
CURSOR C_STAGE(C_VISIT_ID number)
is
	select s.stage_id, s.stage_num, s.stage_name,
          s.object_version_number, s.duration
    from ahl_vwp_stages_vl s
	where s.visit_id = c_visit_id
    order by s.stage_num;
*/
CURSOR C_STAGE(c_visit_id IN NUMBER)
IS
  SELECT S.stage_id
        ,S.stage_num
        ,S.stage_name
        ,S.object_version_number
        ,S.duration
        ,S.attribute_category
        ,S.attribute1
        ,S.attribute2
        ,S.attribute3
        ,S.attribute4
        ,S.attribute5
        ,S.attribute6
        ,S.attribute7
        ,S.attribute8
        ,S.attribute9
        ,S.attribute10
        ,S.attribute11
        ,S.attribute12
        ,S.attribute13
        ,S.attribute14
        ,S.attribute15
  FROM   ahl_vwp_stages_vl s
  WHERE  s.visit_id = c_visit_id
  ORDER BY s.stage_num;

l_stage_rec             C_STAGE%rowtype;

CURSOR C_STAGE_DATE(C_STAGE_ID number)
is
	select vt.stage_id,
	--       sum(s.duration) over(order by s.stage_num) CUMUL_DURATION,
	--       min(vt.start_date_time) start_date_time,
	       max(vt.end_date_time) end_date_time
	from ahl_visit_tasks_b vt
	where vt.stage_id = C_STAGE_ID
    AND nvl(vt.status_code,'X') <> 'DELETED'
	group by vt.stage_id;

l_stage_date_rec             c_stage_date%rowtype;

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Get_Stages_Details;

  -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.enable_debug;
   END IF;

   -- Debug info.
   IF Ahl_Debug_Pub.G_FILE_DEBUG THEN
       IF G_DEBUG='Y' THEN
	  AHL_DEBUG_PUB.debug( l_full_name ||':*****Start*****');
       END IF;
    END IF;

   IF Fnd_Api.to_boolean (p_init_msg_list) THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME
   ) THEN
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;



   ------------------------Start of API ----------------------
	x_row_count := 0;
   -- Cursor to find visit start time
     OPEN c_visit (p_visit_id);
     FETCH c_visit INTO l_visit_start_date,l_dept_id;
     CLOSE c_visit;

--Added by amagrawa
       Validate_bef_Times_Derive
            (p_visit_id	      => p_visit_id,
             x_valid_flag     => l_valid_flag,
             x_return_status  => l_return_status,
             x_error_msg_code => l_msg_data);
-- To check if
 -- Modified by amagrawa as per review comments.
       IF(l_valid_flag ='N') THEN

		    	 FOR l_stage_rec IN C_STAGE(P_VISIT_ID)
		         LOOP

                     l_st_ind := l_stage_rec.stage_num -1;

         			 l_stages_tbl(l_st_ind).stage_id := l_stage_rec.stage_id;
			         l_stages_tbl(l_st_ind).stage_num := l_stage_rec.stage_num;
			         l_stages_tbl(l_st_ind).stage_name := l_stage_rec.stage_name;
			         l_stages_tbl(l_st_ind).object_version_number := l_stage_rec.object_version_number;
			         l_stages_tbl(l_st_ind).duration := l_stage_rec.duration;
   	                 l_stages_tbl(l_st_ind).stage_planned_start_time :=null;
		             l_stages_tbl(l_st_ind).stage_planned_end_time := null;
                     l_stages_tbl(l_st_ind).Stage_Actual_End_Time := null;

                     -- SATHAPLI::DFF Project, 05-Jan-2010, set the DFF data too, in the OUT parameter
                     l_stages_tbl(l_st_ind).attribute_category := l_stage_rec.attribute_category;
                     l_stages_tbl(l_st_ind).attribute1         := l_stage_rec.attribute1;
                     l_stages_tbl(l_st_ind).attribute2         := l_stage_rec.attribute2;
                     l_stages_tbl(l_st_ind).attribute3         := l_stage_rec.attribute3;
                     l_stages_tbl(l_st_ind).attribute4         := l_stage_rec.attribute4;
                     l_stages_tbl(l_st_ind).attribute5         := l_stage_rec.attribute5;
                     l_stages_tbl(l_st_ind).attribute6         := l_stage_rec.attribute6;
                     l_stages_tbl(l_st_ind).attribute7         := l_stage_rec.attribute7;
                     l_stages_tbl(l_st_ind).attribute8         := l_stage_rec.attribute8;
                     l_stages_tbl(l_st_ind).attribute9         := l_stage_rec.attribute9;
                     l_stages_tbl(l_st_ind).attribute10        := l_stage_rec.attribute10;
                     l_stages_tbl(l_st_ind).attribute11        := l_stage_rec.attribute11;
                     l_stages_tbl(l_st_ind).attribute12        := l_stage_rec.attribute12;
                     l_stages_tbl(l_st_ind).attribute13        := l_stage_rec.attribute13;
                     l_stages_tbl(l_st_ind).attribute14        := l_stage_rec.attribute14;
                     l_stages_tbl(l_st_ind).attribute15        := l_stage_rec.attribute15;

	             END LOOP;
       ELSE --Return Status = 'S'
-- End of changes by amagrawa
		 FOR l_stage_rec IN C_STAGE(P_VISIT_ID)
		 LOOP

            l_st_ind := l_stage_rec.stage_num -1;
            l_cum_duration := l_cum_duration + l_stage_rec.duration;

         	l_stages_tbl(l_st_ind).stage_id := l_stage_rec.stage_id;
			l_stages_tbl(l_st_ind).stage_num := l_stage_rec.stage_num;
			l_stages_tbl(l_st_ind).stage_name := l_stage_rec.stage_name;
			l_stages_tbl(l_st_ind).object_version_number := l_stage_rec.object_version_number;
			l_stages_tbl(l_st_ind).duration := l_stage_rec.duration;
   	        l_stages_tbl(l_st_ind).stage_planned_start_time :=
            AHL_VWP_TIMES_PVT.compute_date(l_visit_start_date, l_dept_id, l_cum_duration - l_stage_rec.duration);
		    l_stages_tbl(l_st_ind).stage_planned_end_time :=
  		    AHL_VWP_TIMES_PVT.compute_date(l_visit_start_date, l_dept_id, l_cum_duration );

             -- SATHAPLI::DFF Project, 05-Jan-2010, set the DFF data too, in the OUT parameter
             l_stages_tbl(l_st_ind).attribute_category := l_stage_rec.attribute_category;
             l_stages_tbl(l_st_ind).attribute1         := l_stage_rec.attribute1;
             l_stages_tbl(l_st_ind).attribute2         := l_stage_rec.attribute2;
             l_stages_tbl(l_st_ind).attribute3         := l_stage_rec.attribute3;
             l_stages_tbl(l_st_ind).attribute4         := l_stage_rec.attribute4;
             l_stages_tbl(l_st_ind).attribute5         := l_stage_rec.attribute5;
             l_stages_tbl(l_st_ind).attribute6         := l_stage_rec.attribute6;
             l_stages_tbl(l_st_ind).attribute7         := l_stage_rec.attribute7;
             l_stages_tbl(l_st_ind).attribute8         := l_stage_rec.attribute8;
             l_stages_tbl(l_st_ind).attribute9         := l_stage_rec.attribute9;
             l_stages_tbl(l_st_ind).attribute10        := l_stage_rec.attribute10;
             l_stages_tbl(l_st_ind).attribute11        := l_stage_rec.attribute11;
             l_stages_tbl(l_st_ind).attribute12        := l_stage_rec.attribute12;
             l_stages_tbl(l_st_ind).attribute13        := l_stage_rec.attribute13;
             l_stages_tbl(l_st_ind).attribute14        := l_stage_rec.attribute14;
             l_stages_tbl(l_st_ind).attribute15        := l_stage_rec.attribute15;

            l_stage_date_rec := null;

            OPEN C_STAGE_DATE(l_stage_rec.stage_id);
            FETCH C_STAGE_DATE INTO l_stage_date_rec;
            CLOSE C_STAGE_DATE;

            l_stages_tbl(l_st_ind).Stage_Actual_End_Time := l_stage_date_rec.end_date_time;

           END LOOP;
         END IF; --start and dept not null
 -- Modified by amagrawa as per review comments.
         		 x_row_count := l_stages_tbl.count;
  --               x_return_status := FND_API.G_RET_STS_SUCCESS;

	 --------------------------
      x_stages_tbl := l_stages_tbl;

   ------------------------End of API Body------------------------------------
    -- Standard call to get message count and if count is 1, get message info
        Fnd_Msg_Pub.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data,
          p_encoded => Fnd_Api.g_false);

    -- Check if API is called in debug mode. If yes, enable debug.
        IF G_DEBUG='Y' THEN
		     AHL_DEBUG_PUB.enable_debug;
        END IF;

    -- Debug info.
-- Commented by amagrawa as per review comments.
--    IF Ahl_Debug_Pub.G_FILE_DEBUG THEN
       IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.debug(L_FULL_NAME||'AHL_VWP_Tasks_PVT - End');
	   END IF;
--    END IF;

   -- Check if API is called in debug mode. If yes, disable debug.
    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.disable_debug;
    END IF;
    RETURN;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   ROLLBACK TO Get_Stages_Details;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);
 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Get_Stages_Details;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => Fnd_Api.g_false);
 WHEN OTHERS THEN
      ROLLBACK TO Get_Stages_Details;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
		THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data  );


END Get_Stages_Details;


--------------------------------------------------------------------
-- PROCEDURE
--    Create_Stages
--
-- PURPOSE
--    To create a Stage for visit based on the profile value set.
--    this procedure defaults the stage_num and stage_name to count and duration to 0.
--    will be called by create_visit and only the visit_id is passed.
--------------------------------------------------------------------
PROCEDURE Create_Stages (
   p_api_version             IN     NUMBER,
   p_init_msg_list           IN     VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN     VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN     NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN     VARCHAR2  := 'JSP',

   p_visit_id                IN     NUMBER,
   x_return_status           OUT    NOCOPY VARCHAR2,
   x_msg_count               OUT    NOCOPY NUMBER,
   x_msg_data                OUT    NOCOPY VARCHAR2
)
IS
  -- Define local Variables
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Create Stages';
   L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_msg_data              VARCHAR2(2000);
   l_msg_count             NUMBER;

   l_stage_count           NUMBER;
   l_rowid                 ROWID;


BEGIN
   --------------------- Initialize -----------------------
   SAVEPOINT Create_Stage;

   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;

   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.Debug( l_full_name ||': Start');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;

    --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   ------------------------Start of API Body------------------------------------

   --------------------Value OR ID conversion---------------------------
/*  not reqd;
   IF p_module_type = 'JSP'
   THEN
     -- do nothing;
   END IF;
*/

   -------------------------------- Validate -----------------------------------------

    IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.Debug( l_full_name ||':START VALIDATE');
    END IF;

   --
   -- Check for the ID.
   --
   IF (P_VISIT_ID = Fnd_Api.g_miss_num OR P_VISIT_ID IS Null)
   THEN
             Fnd_Message.SET_NAME('AHL','AHL_VWP_VISIT_INVALID');
             Fnd_Msg_Pub.ADD;
   END IF;

    --
    -- Check profile
    --
    l_stage_count := FND_PROFILE.value('AHL_NUMBER_OF_STAGES');
-- Modified by amagrawa as per review comments.
    If l_stage_count is null
    then
             Fnd_Message.SET_NAME('AHL','AHL_VWP_ST_PROFILE_NOT_DEF');
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_stage_count <= 0
	then
             Fnd_Message.SET_NAME('AHL','AHL_VWP_ST_PROFILE_GT_ZERO');
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_stage_count <> floor(l_stage_count)
    then
             Fnd_Message.SET_NAME('AHL','AHL_VWP_ST_PROFILE_NOT_INT');
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
             RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;


/*   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
*/
   IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.Debug( l_full_name ||':END VALIDATE');
   END IF;

   -------------------------- Insert --------------------------
    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.Debug( l_full_name ||':Insert');
    END IF;


    FOR I IN 1..L_STAGE_COUNT
    LOOP

        -- Invoke the table handler to create a record
        --

	   Ahl_VWP_Stages_Pkg.Insert_Row (
	     X_ROWID                 => l_rowid,
	     X_VISIT_ID              => P_VISIT_ID,
	     X_STAGE_ID              => Get_Stage_Id,
	     X_STAGE_NUM             => i,
	     X_STAGE_NAME            => i,
	     X_DURATION              => 0,
	     X_OBJECT_VERSION_NUMBER => 1,

   	     X_ATTRIBUTE_CATEGORY      => NULL,
	     X_ATTRIBUTE1              => NULL ,
	     X_ATTRIBUTE2              => NULL ,
	     X_ATTRIBUTE3              => NULL ,
	     X_ATTRIBUTE4              => NULL ,
	     X_ATTRIBUTE5              => NULL ,
	     X_ATTRIBUTE6              => NULL ,
	     X_ATTRIBUTE7              => NULL ,
	     X_ATTRIBUTE8              => NULL ,
	     X_ATTRIBUTE9              => NULL ,
	     X_ATTRIBUTE10             => NULL ,
	     X_ATTRIBUTE11             => NULL ,
	     X_ATTRIBUTE12             => NULL ,
	     X_ATTRIBUTE13             => NULL ,
	     X_ATTRIBUTE14             => NULL ,
	     X_ATTRIBUTE15             => NULL ,

	     X_CREATION_DATE         => SYSDATE,
	     X_CREATED_BY            => Fnd_Global.USER_ID,
	     X_LAST_UPDATE_DATE      => SYSDATE,
	     X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
	     X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID);

     IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.Debug( l_full_name ||': Visit ID =' || P_VISIT_ID);
       AHL_DEBUG_PUB.Debug( l_full_name ||': STAGE Number =' ||  I);
     END IF;
   END LOOP;

  ---------------------------End of API Body---------------------------------------
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
       AHL_DEBUG_PUB.Debug( l_full_name ||':End');
   END IF;

   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
      Ahl_Debug_Pub.disable_debug;
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Create_Stage;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Create_Stage;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Stage;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
		THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Create_StageS;


--------------------------------------------------------------------
-- PROCEDURE
--    Update_Stages
--
-- PURPOSE
--    To create a Stage for visit based on the profile value set.
--    this procedure defaults the stage_num and stage_name to count and duration to 0.
--    will be called by create_visit and only the visit_id is passed.
--------------------------------------------------------------------
PROCEDURE Update_Stages (
   p_api_version             IN     NUMBER,
   p_init_msg_list           IN     VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN     VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN     NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN     VARCHAR2  := 'JSP',

   p_visit_id                IN     NUMBER,
   p_x_stages_tbl            IN  OUT NOCOPY Visit_Stages_Tbl_Type,

   x_return_status           OUT    NOCOPY VARCHAR2,
   x_msg_count               OUT    NOCOPY NUMBER,
   x_msg_data                OUT    NOCOPY VARCHAR2
)
IS
  -- Define local Variables
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Update Stages';
   L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_msg_data              VARCHAR2(2000);
   l_msg_count             NUMBER;
   l_dummy                 varchar2(1);
   l_visit_status          varchar2(30);
   l_return_status         varchar2(1);
   l_validate_status       varchar2(1);

   l_planned_order_flag VARCHAR2(1);

CURSOR c_check_visit_status(C_VISIT_ID NUMBER) IS
       SELECT status_code FROM AHL_VISITS_B
                  WHERE VISIT_ID = C_VISIT_ID
                  AND STATUS_CODE IN ('PLANNING', 'PARTIALLY RELEASED', 'RELEASED' );

-- Commented based on review comments
/*CURSOR C_JOB(C_VISIT_ID NUMBER , C_STAGE_NUM NUMBER )
IS
	select 'x' from ahl_workorders_v
	where visit_task_id in
	   (select DISTINCT VISIT_TASK_ID from AHL_VISIT_TASKS_B
	    where visit_id = C_VISIT_ID
	    and STAGE_ID IN (SELECT STAGE_ID FROM AHL_VWP_STAGES_B WHERE stage_num > C_STAGE_NUM
	                     AND VISIT_ID = C_VISIT_ID))
	and ( job_status_code =3  or  firm_planned_flag = 1 );
*/

-- SKPATHAK :: Bug #9402556 :: 24-FEB-2010 :: START
-- Cursor to find out the cumulative duration of all the stages before this stage
CURSOR c_sum_stage_duration (c_stage_id NUMBER,
                             c_visit_id NUMBER)
IS
SELECT sum(duration)
FROM AHL_VWP_STAGES_VL
WHERE visit_id = c_visit_id
AND stage_num < (select stage_num
                    from AHL_VWP_STAGES_VL
                    WHERE stage_id = c_stage_id
                    AND visit_id = c_visit_id);

-- To find visit related information
CURSOR c_visit (c_visit_id IN NUMBER)
IS
      SELECT START_DATE_TIME , department_id FROM AHL_VISITS_B
      WHERE VISIT_ID = c_visit_id;

CURSOR get_past_task_details (c_visit_id NUMBER)
IS
SELECT past_task_start_date, stage_id FROM AHL_VISIT_TASKS_B
WHERE visit_id = c_visit_id
AND past_task_start_date IS NOT NULL;

l_past_task_start_date DATE;
l_stage_id NUMBER;
l_stage_planned_start_time DATE;
l_cum_duration NUMBER;
l_visit_start_date DATE;
l_dept_id NUMBER;
-- SKPATHAK :: Bug #9402556 :: 24-FEB-2010 :: END

   -- To find task related information

l_visit_end_date DATE;

BEGIN
   --------------------- Initialize -----------------------
   SAVEPOINT Update_Stages;

   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
     Ahl_Debug_Pub.enable_debug;
   END IF;

   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.Debug( l_full_name ||': Start');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;

    --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   ------------------------Start of API Body------------------------------------

   --
   -- Check for the ID.
   --
   IF (P_VISIT_ID = Fnd_Api.g_miss_num OR P_VISIT_ID IS Null)
   THEN
             Fnd_Message.SET_NAME('AHL','AHL_VWP_VISIT_NOT_FOUND');
             Fnd_Msg_Pub.ADD;
             -- Added by amagrawa based on review commenst
             RAISE Fnd_Api.G_EXC_ERROR;
   END IF;


   --verify if visit status is planning or released or partially_released
   open c_check_visit_status(p_visit_id);
   fetch c_check_visit_status into l_visit_status;
   if c_check_visit_status%notfound
   then
             Fnd_Message.SET_NAME('AHL','AHL_VWP_VISIT_STATUS_INV');
             Fnd_Msg_Pub.ADD;
 -- Added by amagrawa based on review commenst
             close c_check_visit_status;
             RAISE Fnd_Api.G_EXC_ERROR;
   end if;
   close c_check_visit_status;

-- Commented by amagrawa as per review commenst.
/*   --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
*/
   -------------------------- Update --------------------------
    IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.Debug( l_full_name ||':Insert');
    END IF;


    FOR i IN p_x_stages_tbl.FIRST..p_x_stages_tbl.LAST
    loop

       IF G_DEBUG='Y' THEN
   		 AHL_DEBUG_PUB.Debug( l_full_name ||':START VALIDATE');
       END IF;

   -------------------------------- Validate -----------------------------------------
        l_validate_status := Fnd_Api.G_RET_STS_SUCCESS;

        default_missing_attributes(p_x_stages_tbl(i));



        VALIDATE_STAGES(
	   p_visit_id		=> p_visit_id,
	   p_stages_rec         => p_x_stages_tbl(i),
	   x_return_status      => l_validate_status,
	   x_msg_count          => x_msg_count,
	   x_msg_data           => x_msg_data
        );
      -- Added be amagrawa based on review comments
        IF l_validate_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
              RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF G_DEBUG='Y' THEN
   		 AHL_DEBUG_PUB.Debug( l_full_name ||':END VALIDATE');
        END IF;

-- Commented by amagrawa based on review comments
/*	-- VALIDATE IF JOB IN SUBSEQUENT STAGE IS FIRMED OR RELEASED
	IF l_visit_status IN ('RELEASED' , 'PARTIALLY RELEASED')
	 THEN
	     OPEN C_JOB(P_VISIT_ID, p_x_stages_tbl(i).STAGE_NUM );
	     FETCH C_JOB INTO L_DUMMY;
	     IF C_JOB%FOUND
	     THEN
		     Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_JOB_FIRM_REL');
		     Fnd_Message.SET_TOKEN('STAGE_NAME', p_x_stages_tbl(i).stage_name);
		     Fnd_Msg_Pub.ADD;
		     l_validate_status := Fnd_Api.G_RET_STS_ERROR;
	     END IF;
	     CLOSE C_JOB;
	 END IF;
  /* Uncommented as per Stages test case STG14 : Removed by Senthil for TC */

----------------------------- IF NO ERRORS UPDATE-----------------------------------------
	      if l_validate_status = Fnd_Api.G_RET_STS_SUCCESS
	      then
		  -- Invoke the table handler to update the record
		  --
		   Ahl_VWP_stages_Pkg.Update_Row (
		     X_VISIT_ID                => P_VISIT_ID,
		     X_STAGE_ID                => p_x_stages_tbl(i).STAGE_ID,
		     X_STAGE_NUM               => p_x_stages_tbl(i).STAGE_NUM,
		     X_STAGE_NAME              => p_x_stages_tbl(i).STAGE_NAME,
		     X_DURATION                => p_x_stages_tbl(i).DURATION,
		     X_OBJECT_VERSION_NUMBER   => p_x_stages_tbl(i).OBJECT_VERSION_NUMBER+1,
		     X_ATTRIBUTE_CATEGORY      => p_x_stages_tbl(i).ATTRIBUTE_CATEGORY,
		     X_ATTRIBUTE1              => p_x_stages_tbl(i).ATTRIBUTE1,
		     X_ATTRIBUTE2              => p_x_stages_tbl(i).ATTRIBUTE2,
		     X_ATTRIBUTE3              => p_x_stages_tbl(i).ATTRIBUTE3,
		     X_ATTRIBUTE4              => p_x_stages_tbl(i).ATTRIBUTE4,
		     X_ATTRIBUTE5              => p_x_stages_tbl(i).ATTRIBUTE5,
		     X_ATTRIBUTE6              => p_x_stages_tbl(i).ATTRIBUTE6,
		     X_ATTRIBUTE7              => p_x_stages_tbl(i).ATTRIBUTE7,
		     X_ATTRIBUTE8              => p_x_stages_tbl(i).ATTRIBUTE8,
		     X_ATTRIBUTE9              => p_x_stages_tbl(i).ATTRIBUTE9,
		     X_ATTRIBUTE10             => p_x_stages_tbl(i).ATTRIBUTE10,
		     X_ATTRIBUTE11             => p_x_stages_tbl(i).ATTRIBUTE11,
		     X_ATTRIBUTE12             => p_x_stages_tbl(i).ATTRIBUTE12,
		     X_ATTRIBUTE13             => p_x_stages_tbl(i).ATTRIBUTE13,
		     X_ATTRIBUTE14             => p_x_stages_tbl(i).ATTRIBUTE14,
		     X_ATTRIBUTE15             => p_x_stages_tbl(i).ATTRIBUTE15,
		     X_LAST_UPDATE_DATE        => SYSDATE,
		     X_LAST_UPDATED_BY         => Fnd_Global.USER_ID,
		     X_LAST_UPDATE_LOGIN       => Fnd_Global.LOGIN_ID );

   			   IF G_DEBUG='Y' THEN
			       AHL_DEBUG_PUB.Debug( l_full_name ||': Visit ID =' || P_VISIT_ID);
			       AHL_DEBUG_PUB.Debug( l_full_name ||': STAGE Number =' ||  p_x_stages_tbl(i).stage_num);
			   END IF;
-- Added by amagrawa after review comments.
	    ELSE -- If validate_status is <> 'S'
                  RAISE Fnd_Api.G_EXC_ERROR;
        END IF; -- end check of validate_status
END LOOP;

    ---------------------------End of API Body---------------------------------------

 -- Added cxcheng POST11510--------------
   --Now adjust the times derivation for task
   AHL_VWP_TIMES_PVT.Calculate_Task_Times(p_api_version => 1.0,
                                    p_init_msg_list => Fnd_Api.G_FALSE,
                                    p_commit        => Fnd_Api.G_FALSE,
                                    p_validation_level      => Fnd_Api.G_VALID_LEVEL_FULL,
                                    x_return_status      => l_return_status,
                                    x_msg_count          => l_msg_count,
                                    x_msg_data           => l_msg_data,
                                    p_visit_id            => p_visit_id);
    -- Added by amagrawa based on review comments.
	    IF l_return_Status <>'S'
        THEN
            IF l_return_Status = FND_API.G_RET_STS_ERROR
            THEN
					    RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_Status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
			           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

     	END IF;

        -- SKPATHAK :: Bug #9402556 :: 24-FEB-2010 :: START
        OPEN get_past_task_details (p_visit_id);
        LOOP
          FETCH get_past_task_details INTO l_past_task_start_date, l_stage_id;
          EXIT WHEN get_past_task_details%NOTFOUND;
            OPEN c_sum_stage_duration (l_stage_id,p_visit_id);
            FETCH c_sum_stage_duration INTO l_cum_duration;
            CLOSE c_sum_stage_duration;

            -- Cursor to find visit start time
            OPEN c_visit (p_visit_id);
            FETCH c_visit INTO l_visit_start_date,l_dept_id;
            CLOSE c_visit;
            -- Find the planned start time of the stage in which this task falls
            l_stage_planned_start_time := AHL_VWP_TIMES_PVT.compute_date(l_visit_start_date, l_dept_id, l_cum_duration);
            -- Validate that the any of the tasks does not start before the stage starts
            IF l_past_task_start_date < l_stage_planned_start_time THEN
              Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_DURN_INVLD');
              Fnd_Msg_Pub.ADD;
              RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END LOOP;
        CLOSE get_past_task_details;
	-- SKPATHAK :: Bug #9402556 :: 24-FEB-2010 :: END


          l_visit_end_date:= AHL_VWP_TIMES_PVT.get_visit_end_time(p_visit_id);

	  IF l_visit_end_date IS NOT NULL THEN

		AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials
		  (p_api_version            => p_api_version,
		   p_init_msg_list          => Fnd_Api.G_FALSE,
		   p_commit                 => Fnd_Api.G_FALSE,
		   p_visit_id               => p_visit_id,
		   p_visit_task_id          => NULL,
		   p_org_id                 => NULL,
		   p_start_date             => NULL,
		   p_operation_flag         => 'U',

		   x_planned_order_flag     => l_planned_order_flag ,
		    x_return_status           => l_return_status,
		    x_msg_count               => l_msg_count,
		    x_msg_data                => l_msg_data);

		IF l_msg_count > 0 OR NVL(l_return_status,'x') <> FND_API.G_RET_STS_SUCCESS THEN
			X_msg_count := l_msg_count;
			X_return_status := Fnd_Api.G_RET_STS_ERROR;
			RAISE Fnd_Api.G_EXC_ERROR;
		END IF;


          END IF;


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
       AHL_DEBUG_PUB.Debug( l_full_name ||':End');
   END IF;

   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
      Ahl_Debug_Pub.disable_debug;
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Update_Stages;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Stages;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Stages;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
		THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Update_Stages;

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Stages
--
-- PURPOSE
--    To delete a Stage for visit.
--    will be called from delete visit and requires only visit_id
--------------------------------------------------------------------
PROCEDURE Delete_Stages (
   p_api_version             IN     NUMBER,
   p_init_msg_list           IN     VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN     VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN     NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN     VARCHAR2  := 'JSP',

   p_visit_id                IN     NUMBER,

   x_return_status           OUT    NOCOPY VARCHAR2,
   x_msg_count               OUT    NOCOPY NUMBER,
   x_msg_data                OUT    NOCOPY VARCHAR2
)
is

  -- Define local Variables
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Delete Stages';
   L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
   l_msg_count             NUMBER;

begin
   --------------------- Initialize -----------------------
   SAVEPOINT Delete_Stages;

   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
     Ahl_Debug_Pub.enable_debug;
   END IF;

   -- Debug info.
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.Debug( l_full_name ||': Start');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;

    --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   ------------------------Start of API Body------------------------------------
   -- directly delete as we need to delete all stages for the visit

	    delete from AHL_VWP_STAGES_TL
	    where stage_id
	          in (select stage_id from ahl_vwp_stages_b
	              where visit_id = p_visit_id);

	    delete from AHL_VWP_STAGES_B
	    where visit_id = p_visit_id;

   -- directly delete as we need to delete all stages for the visit

   ---------------------------End of API Body---------------------------------------
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
       AHL_DEBUG_PUB.Debug( l_full_name ||':End');
   END IF;

   -- Check if API is called in debug mode. If yes, disable debug.
   IF G_DEBUG='Y' THEN
      Ahl_Debug_Pub.disable_debug;
   END IF;
EXCEPTION
   WHEN Fnd_Api.g_exc_error THEN
      ROLLBACK TO Delete_Stages;
      x_return_status := Fnd_Api.g_ret_sts_error;
      Fnd_Msg_Pub.count_and_get(
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN Fnd_Api.g_exc_unexpected_error THEN
      ROLLBACK TO Delete_Stages;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Stages;
      x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_unexp_error)
		THEN
         Fnd_Msg_Pub.add_exc_msg (G_PKG_NAME, l_api_name);
      END IF;
      Fnd_Msg_Pub.count_and_get (
            p_encoded => Fnd_Api.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


end delete_stages;



----------------------------------------------------------------------
-- END: Defining procedures BODY, which are called from UI screen --
----------------------------------------------------------------------


PROCEDURE VALIDATE_STAGES(
   p_visit_id		     in number,
   p_stages_rec              IN     Visit_Stages_Rec_Type,
   x_return_status           OUT    NOCOPY VARCHAR2,
   x_msg_count               OUT    NOCOPY NUMBER,
   x_msg_data                OUT    NOCOPY VARCHAR2
)
IS
  -- Define local Variables
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Validate Stages';
   L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_msg_data              VARCHAR2(2000);
   l_stage_duration        NUMBER;
   l_dummy                 varchar2(1);

cursor c_stage_name(C_VISIT_ID number, C_STAGE_NAME varchar2, C_STAGE_ID number)
  IS
       SELECT 'x' FROM AHL_VWP_STAGES_VL
                  WHERE VISIT_ID = C_VISIT_ID AND
                  STAGE_ID <> C_STAGE_ID AND
                  STAGE_NAME = C_STAGE_NAME;

cursor c_stage_data(c_stage_id number)
  IS
       select stage_name, duration, object_version_number
       from AHL_VWP_STAGES_VL
       where stage_id = c_stage_id;

l_stage_rec  c_stage_data%rowtype;

cursor c_stage_task(c_stage_id number)
IS
       select 'x' from ahl_visit_tasks_b
       where stage_id = c_stage_id
	   and nvl(status_code,'X')<>'DELETED';


BEGIN

/*   --------------------- initialize -----------------------
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.enable_debug;
	 END IF;

   -- Debug info.
    IF Ahl_Debug_Pub.G_FILE_DEBUG THEN
       IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.debug( l_full_name ||'********************************START******************************* ');
	 END IF;
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
*/
   x_return_status := Fnd_Api.g_ret_sts_success;

   open c_stage_data(p_stages_rec.stage_id);
   fetch c_stage_data into l_stage_rec;
   if c_stage_data%notfound
   then
             Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_NOT_FOUND_NEW'||p_stages_rec.stage_id);
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.g_ret_sts_error;
             return;
   end if;
   close c_stage_data;

   -- obj version number validation
   IF l_stage_rec.OBJECT_VERSION_NUMBER <> p_stages_rec.OBJECT_VERSION_NUMBER
   THEN
             Fnd_Message.SET_NAME('AHL','AHL_COM_RECORD_MOD');
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.g_ret_sts_error;
             return;
   end if;

   IF p_stages_rec.STAGE_NUM IS NULL
   THEN
             Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_NUM_NULL');
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.g_ret_sts_error;
             return;
   end if;


   IF p_stages_rec.stage_name is null or p_stages_rec.stage_name <> l_stage_rec.STAGE_NAME
   THEN
      -- stage name is mandatory
     if p_stages_rec.stage_name is null or p_stages_rec.stage_name = ''
     then
             Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_NAME_NULL');
			 FND_MESSAGE.SET_TOKEN('STAGE_NUM',p_stages_rec.STAGE_NUM);
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.g_ret_sts_error;
			 return;
     else
     -- stage name is unique
	       open c_stage_name(p_visit_id, p_stages_rec.stage_name, p_stages_rec.stage_id);
	       fetch c_stage_name into l_dummy;
	       if c_stage_name%found
	       then
		     Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_NAME_UNIQUE');
		     Fnd_Message.SET_TOKEN('STAGE_NAME', p_stages_rec.stage_name);
		     Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.g_ret_sts_error;
             close c_stage_name;
        	 return;
	       end if;
	       close c_stage_name;
      END IF;
   END IF;

				l_stage_duration := p_stages_rec.DURATION;
   IF p_stages_rec.DURATION is null or p_stages_rec.DURATION <> l_stage_rec.DURATION
   THEN
     -- STAGE DURATION is mandatory
     IF p_stages_rec.DURATION IS NULL
     then
             Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_DUR_NULL');
             Fnd_Message.SET_TOKEN('STAGE_NAME', p_stages_rec.stage_name);
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.g_ret_sts_error;
     -- duration must be positive number
     elsif p_stages_rec.duration < 0
     then
             Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_DURN_INV');
             Fnd_Message.SET_TOKEN('STAGE_NAME', p_stages_rec.stage_name);
             Fnd_Msg_Pub.ADD;
             x_return_status := Fnd_Api.g_ret_sts_error;
     elsif p_stages_rec.duration = 0
     then
             open c_stage_task( p_stages_rec.stage_id);
             fetch c_stage_task into l_dummy;
             if c_stage_task%found
             THEN
		     Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_HAS_TASKS');
		     Fnd_Message.SET_TOKEN('STAGE_NAME', p_stages_rec.stage_name);
		     Fnd_Msg_Pub.ADD;
                     x_return_status := Fnd_Api.g_ret_sts_error;
	           end if;
	           close c_stage_task;
	 elsif p_stages_rec.DURATION > trunc(l_stage_duration,0)
	 THEN
			 Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_DUR_NON_INT');
		     Fnd_Msg_Pub.ADD;
		     x_return_status := Fnd_Api.g_ret_sts_error;

	end if;

   END IF;


END VALIDATE_STAGES;


--------------------------------------------------------------------
-- FUNCTION
--     Get_Stage_Id
--
--------------------------------------------------------------------
FUNCTION  Get_Stage_Id
RETURN NUMBER
IS

 -- To find the next id value from visit sequence
   CURSOR c_seq IS
      SELECT Ahl_vwp_stages_B_S.NEXTVAL
      FROM   dual;

 -- To find whether id already exists
   CURSOR c_id_exists (x_id IN NUMBER) IS
   SELECT 1
   FROM   Ahl_vwp_stages_b
   WHERE  stage_id = x_id;

    x_stage_Id NUMBER;
    l_dummy NUMBER;
BEGIN
  -- Modified by amagrawa according to review comments.
            -- If the ID is not passed into the API, then
            -- grab a value from the sequence.
             LOOP
                  OPEN c_seq;
                  FETCH c_seq INTO x_stage_Id;
                  CLOSE c_seq;
             --
             -- Check to be sure that the sequence does not exist.
                      OPEN c_id_exists (x_stage_Id);
                      FETCH c_id_exists INTO l_dummy;
              -- If Sequence does not exist exit from loop
                        IF c_id_exists%NOTFOUND
                        THEN
                             close c_id_exists;
                             EXIT;
                        END IF;
		                CLOSE c_id_exists;
			 END LOOP;

    RETURN x_stage_Id ;

END Get_Stage_Id;


PROCEDURE VALIDATE_STAGE_UPDATES(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := Fnd_Api.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,

    p_visit_id              IN            NUMBER,
    p_visit_task_id         IN            NUMBER,
    p_stage_name            IN            VARCHAR2   := NULL, -- defaulted as u may pass id or num

    x_stage_id              OUT NOCOPY  NUMBER            ,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
)
is

   L_MAX_PARENT  NUMBER;
   L_MIN_CHILD   NUMBER;
   L_STAGE_NUM   NUMBER;
   L_STAGE_ID    NUMBER;

   l_max_stage_num number := FND_PROFILE.value('AHL_NUMBER_OF_STAGES');

   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'Update Stages';
   L_FULL_NAME             CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;


CURSOR C_valid_stage_num(P_VISIT_TASK_ID NUMBER)
is
	SELECT
	  max_parent_stage_num,
	  min_child_stage_num
	FROM
	  ( SELECT
	  nvl(max(stage_num),1) max_parent_stage_num
	FROM
	  ahl_vwp_stages_b s,
	  AHL_VISIT_TASKS_b t
	WHERE
	  s.stage_id = t.stage_id and
	  t.VISIT_task_id IN
	            ( SELECT  PARENT_TASK_ID FROM AHL_TASK_LINKS WHERE VISIT_TASK_ID =  P_VISIT_TASK_ID )) ,
	  ( SELECT
	  nvl(min(stage_num),l_max_stage_num) min_child_stage_num
	FROM
	  ahl_vwp_stages_b s,
	  AHL_VISIT_TASKS_b t
	WHERE
	  s.stage_id = t.stage_id and
	  t.VISIT_task_id IN
	        ( SELECT  visit_TASK_ID FROM AHL_TASK_LINKS WHERE parent_TASK_ID = P_VISIT_TASK_ID ));


CURSOR C_STAGE_NUM(P_VISIT_ID NUMBER, P_STAGE_NAME VARCHAR2)
is
       SELECT STAGE_NUM, stage_id FROM AHL_VWP_STAGES_VL
       WHERE STAGE_NAME = P_STAGE_NAME AND VISIT_ID = P_VISIT_ID;

begin

   --------------------- initialize -----------------------
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.enable_debug;
	 END IF;

   -- Debug info.
    IF Ahl_Debug_Pub.G_FILE_DEBUG THEN
       IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.debug( l_full_name ||'********************************START******************************* ');
	 END IF;
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


-------------------- basic check for stage num or id------------------------------------------
-- test if passed stage num > max num for all its parents and less that min num for all children--

      open C_valid_stage_num(p_visit_task_id);
      fetch C_valid_stage_num into l_max_parent, l_min_child;
      CLOSE C_VALID_STAGE_NUM;


      IF (P_STAGE_NAME IS NOT NULL AND P_STAGE_NAME <> FND_API.G_MISS_CHAR)
      THEN

           OPEN C_STAGE_NUM(p_visit_id, p_stage_name);
           FETCH C_STAGE_NUM INTO L_STAGE_NUM, L_STAGE_ID;
             IF C_STAGE_NUM%NOTFOUND THEN
		     Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_NOT_FOUND');
		     Fnd_Msg_Pub.ADD;
                     x_return_status := Fnd_Api.g_ret_sts_error;
             ELSE
-- Stage number should be between Parent Stage Number - L_MAX_PARENT, and Child Stage Number - L_MIN_CHILD
		   IF ( L_MAX_PARENT IS NOT NULL AND L_STAGE_NUM < L_MAX_PARENT)
		    OR ( L_MIN_CHILD IS NOT NULL AND L_STAGE_NUM > L_MIN_CHILD)
		   THEN
			     Fnd_Message.SET_NAME('AHL','AHL_VWP_ST_NUM_INV');
			     Fnd_Message.SET_TOKEN('STAGE_NUM', l_stage_NUM);
			     Fnd_Msg_Pub.ADD;
			     x_return_status := Fnd_Api.g_ret_sts_error;
		   END IF;
                   -- SET OUT PARAM
                   X_STAGE_ID := L_STAGE_ID;

              END IF;
           CLOSE C_STAGE_NUM;
      END IF;
-------------------- basic check for stage num or id------------------------------------------

end VALIDATE_STAGE_UPDATES;


procedure default_missing_attributes(
   p_x_stages_rec              IN OUT NOCOPY     Visit_Stages_Rec_Type
)
is
cursor C_get_stage_data(c_stage_id number)
is
	select * from ahl_vwp_stages_vl where stage_id = c_stage_id;
l_stage_REC   C_get_stage_data%rowtype;

begin
   OPEN C_get_stage_data(p_x_stages_rec.STAGE_ID);
   FETCH C_get_stage_data INTO L_STAGE_REC;
   CLOSE C_get_stage_data;


   IF NVL(p_x_stages_rec.STAGE_NUM, 99) = FND_API.G_MISS_NUM
   THEN
        p_x_stages_rec.STAGE_NUM := L_stage_rec.STAGE_NUM;
   END IF;

   IF NVL(p_x_stages_rec.STAGE_NAME, 'A') = FND_API.G_MISS_CHAR
   THEN
        p_x_stages_rec.STAGE_NAME := L_stage_rec.STAGE_NAME;
   END IF;

   IF NVL(p_x_stages_rec.DURATION, 99) = FND_API.G_MISS_NUM
   THEN
        p_x_stages_rec.DURATION := L_stage_rec.DURATION;
   END IF;

end default_missing_attributes;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Stage_Name_Or_Id
--
-- PURPOSE
--    Converts Stage Name to Stage ID
--------------------------------------------------------------------
PROCEDURE Check_Stage_Name_Or_Id
    (p_visit_id          IN NUMBER,
     p_Stage_Name         IN VARCHAR2,
     x_Stage_id          OUT NOCOPY NUMBER,
     x_return_status     OUT NOCOPY VARCHAR2,
     x_error_msg_code    OUT NOCOPY VARCHAR2
     )
IS
  -- Define local variables
   L_API_NAME             CONSTANT VARCHAR2(30) := 'Check_Stage_Name_Or_Id';
   L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;
BEGIN
    IF (p_Stage_Name IS NOT NULL) THEN
          SELECT Stage_Id INTO x_Stage_id
            FROM AHL_VWP_STAGES_VL
          WHERE Visit_Id  = p_visit_id AND Stage_Name = p_Stage_Name;
    ELSE
         x_Stage_id := null;
    END IF;

      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      -- Debug info.
	   IF G_DEBUG='Y' THEN
    	  Ahl_Debug_Pub.debug( 'API Return Status = ' ||L_FULL_NAME||':'|| x_return_status);
	   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_STAGE_NOT_EXISTS';
    WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_STAGE_NOT_EXISTS';
    WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_Stage_Name_Or_Id;

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_bef_Times_Derive
--
-- PURPOSE
--    To validate visit and tasks before deriving their start and end datetimes
--------------------------------------------------------------------
PROCEDURE Validate_bef_Times_Derive
 ( p_visit_id	      IN	NUMBER,
   x_valid_flag       OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_error_msg_code   OUT NOCOPY VARCHAR2)
IS
  -- Define local variables
   L_API_NAME             CONSTANT VARCHAR2(30) := 'Validate_bef_Times_Derive';
   L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_dept                 NUMBER;
   l_count                NUMBER:=0;
   l_dummy                NUMBER;
 --  i                      NUMBER;
--   x                      NUMBER;

 -- Define local cursors
 -- To find out all visit/template details
    CURSOR c_visit(x_id IN NUMBER) IS
      SELECT * FROM AHL_VISITS_VL
      WHERE VISIT_ID = x_id;
    c_visit_rec  c_visit%ROWTYPE;

-- To find whether dept shifts exist for the dept
   CURSOR c_dept (x_id IN NUMBER) IS
    SELECT COUNT(*) FROM AHL_DEPARTMENT_SHIFTS
    WHERE DEPARTMENT_ID = x_id;

-- Commented by amagrawa based on review comments.
-- To find all departments from a visit's tasks table
/*   CURSOR c_task (x_id IN NUMBER) IS
    SELECT DEPARTMENT_ID FROM AHL_VISIT_TASKS_B WHERE VISIT_ID = x_id
    AND NVL(STATUS_CODE,'X') <> 'DELETED' AND DEPARTMENT_ID IS NOT NULL;
    c_task_rec c_task%ROWTYPE;
*/
-- To find only those routes which are there in tasks table but not in route table for a visit
-- Changed by amagrawa to improve performance.
   CURSOR c_route_chk(x_id IN NUMBER) IS
    SELECT DISTINCT(MR_Route_ID) "ROUTE_ID" FROM AHL_VISIT_TASKS_B TSK
    WHERE VISIT_ID = x_id AND MR_Route_ID IS NOT NULL
    AND NOT EXISTS
    (SELECT DISTINCT(MR_Route_ID) "ROUTE_ID" FROM AHL_MR_ROUTES_V MR
	  where MR.mr_route_id =TSK.mr_route_id) and rownum=1;

    c_route_chk_rec c_route_chk%ROWTYPE;

-- Added by amagrawa based on review comments
-- To find if the all visit tasks dept has department shifts defined
   CURSOR c_task_dep_exist (x_visit_id IN NUMBER) IS
     SELECT 1 from dual WHERE exists(
	    SELECT visit_task_id from ahl_visit_tasks_b
	    Where department_id is not null
		and visit_id =  x_visit_id
		and nvl(status_code,'X')<>'DELETED'
		and department_id not in (select department_id from ahl_department_shifts)
		);



BEGIN
   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    x_valid_flag := 'Y';
   OPEN c_Visit(p_visit_id);
   FETCH c_visit INTO c_visit_rec;
   CLOSE c_Visit;

   IF(c_visit_rec.START_DATE_TIME IS NULL OR c_visit_rec.START_DATE_TIME = Fnd_Api.g_miss_date)
    THEN
       Fnd_Message.SET_NAME('AHL','AHL_VWP_VST_NO_ST_DATE');
       Fnd_Msg_Pub.ADD;
       x_valid_flag := 'N';
    END IF;

    IF(c_visit_rec.DEPARTMENT_ID IS NULL OR c_visit_rec.DEPARTMENT_ID = Fnd_Api.g_miss_num)
    THEN
       Fnd_Message.SET_NAME('AHL','AHL_VWP_VST_NO_DEP');
       Fnd_Msg_Pub.ADD;
       x_valid_flag := 'N';
    ELSE
-- Modified by amagrawa based on review comments
     -- To find if the visit dept has department shifts defined
      OPEN c_dept (c_visit_rec.department_id);
      FETCH c_dept INTO l_count;
      CLOSE c_dept;
      	IF l_count=0
	      THEN
    		   Fnd_Message.SET_NAME('AHL','AHL_VWP_VNO_DEP_SFT');
		       Fnd_Msg_Pub.ADD;
		       x_valid_flag := 'N';
	     END IF;
    END IF;

-- Added by amagrawa based on review comments
    open c_task_dep_exist(p_visit_id);
    FETCH c_task_dep_exist into l_dummy;
    IF(c_task_dep_exist%FOUND)
    THEN
       Fnd_Message.SET_NAME('AHL','AHL_VWP_TNO_DEP_SFT');
       Fnd_Msg_Pub.ADD;
       x_valid_flag := 'N';
    END IF;
	CLOSE c_task_dep_exist;

-- To check routes present in visits exists in MRRoutes table
-- Modified by amagrawa based on review comments
    OPEN c_route_chk (p_visit_id);
    FETCH c_route_chk INTO c_route_chk_rec;
    IF c_route_chk%FOUND THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_TSK_MR_NOT_VAL');
       Fnd_Msg_Pub.ADD;
       x_valid_flag := 'N';
    END IF;
    CLOSE c_route_chk;

END Validate_bef_Times_Derive;



END AHL_VWP_VISITS_STAGES_PVT;

/
