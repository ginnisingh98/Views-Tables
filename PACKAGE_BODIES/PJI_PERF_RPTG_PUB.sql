--------------------------------------------------------
--  DDL for Package Body PJI_PERF_RPTG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PERF_RPTG_PUB" as
/*$Header: PJIPRFPB.pls 120.0 2006/07/02 21:53:35 ajdas noship $*/

--Global constants to be used in error messages
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'PJI_PERF_RPTG_PUB';
--PACKAGE GLOBAL to be used during updates -------------------------------------
G_USER_ID      CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID    CONSTANT NUMBER := FND_GLOBAL.login_id;
g_debug_mode VARCHAR2(1):= NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
--------------------------------------------------------------------------------
--Name:       Create_resource_rollup
--Type:       Procedure
--Description:This procedure can be used to create smart lines in
--            PJI_FP_XBS_ACCUM_F,PJI_ROLLUP_LEVEL_STATUS table based on the
--            RBS for list of Workplans/Financial Plans and Actual transaction.
--
--History:
--      30-JUN-2006   DEGUPTA     Created
--
--------------------------------------------------------------------------------

PROCEDURE Create_resource_rollup
( p_api_version_number      IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                  IN    VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list           IN    VARCHAR2    := FND_API.G_FALSE
 ,x_msg_count               OUT  NOCOPY NUMBER
 ,x_msg_data                OUT  NOCOPY VARCHAR2
 ,x_return_status           OUT  NOCOPY VARCHAR2
 ,p_project_id              IN    NUMBER
 ,p_plan_version_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
 ,p_rbs_version_id_tbl      SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
 ,p_prg_rollup_flag         IN    VARCHAR2   :='N'
)
IS
   l_api_name         CONSTANT  VARCHAR2(30)     := 'Create_resource_rollup';
   l_return_status    VARCHAR2(1);
   l_err_code          NUMBER(15);
   l_err_stage         VARCHAR2(2000);
   l_err_stack         VARCHAR2(2000);
   i                   NUMBER    := 0; --counter
   j                   NUMBER    := 0; --counter
   l_msg_count         NUMBER ;
   l_msg_data          VARCHAR2(2000);
   l_wbs_version_id    NUMBER;
BEGIN

--  Standard begin of API savepoint

    SAVEPOINT Create_resource_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number  ,
                               p_api_version_number  ,
                               l_api_name         ,
                               G_PKG_NAME         )
    THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN

       FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    -- CHECK FOR MANDATORY FIELDS

IF P_PROJECT_ID IS NULL THEN

  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_ID_MISSING'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
  END IF;
   x_return_status             := FND_API.G_RET_STS_ERROR;
  RAISE FND_API.G_EXC_ERROR;
    END IF;

  IF P_PLAN_VERSION_ID_TBL.COUNT = 0 THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PLAN_VERSION_ID_MISSING'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
        END IF;
         x_return_status             := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
        END IF;

    IF P_RBS_VERSION_ID_TBL.COUNT = 0 THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_RESOURCE_IS_MISSING'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
        END IF;
          x_return_status             := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
        END IF;

begin
  SELECT distinct WBS_VERSION_ID
  into l_wbs_version_id
  FROM PJI_PJP_WBS_HEADER
  WHERE PROJECT_ID = p_project_id
  AND PLAN_VERSION_ID = p_plan_version_id_tbl(1);
  exception
  when no_data_found then
      x_return_status             := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
when too_many_rows then
      x_return_status             := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
end;
  Pji_Fm_Xbs_Accum_Maint.maintain_smart_slice (
		  p_rbs_version_id_tbl  =>p_rbs_version_id_tbl,
		  p_plan_version_id_tbl =>p_plan_version_id_tbl,
		  p_wbs_element_id      =>NULL,
		  p_rbs_element_id      => NULL,
		  p_prg_rollup_flag     =>p_prg_rollup_flag,
		  p_curr_record_type_id => NULL,
		  p_calendar_type       => NULL,
	          p_wbs_version_id      =>l_wbs_version_id,
             p_commit              =>p_commit ,
		  x_msg_count           =>x_msg_count,
		  x_msg_data            =>x_msg_data,
		  x_return_status       =>l_return_status);


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR     THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR        THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

   IF (FND_API.to_boolean( p_commit )) THEN
    COMMIT ;
   else
    ROLLBACK TO Create_resource_pub;
   END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO create_resource_pub;
       x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
        (   p_count    =>  x_msg_count  ,
            p_data    =>  x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_resource_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get
        (   p_count    =>  x_msg_count  ,
            p_data    =>  x_msg_data  );

  WHEN OTHERS THEN
      ROLLBACK TO create_resource_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    FND_MSG_PUB.add_exc_msg
        ( p_pkg_name    => G_PKG_NAME
        , p_procedure_name  => l_api_name  );

  END IF;

  FND_MSG_PUB.Count_And_Get
      (   p_count    =>  x_msg_count  ,
          p_data    =>  x_msg_data  );

END Create_resource_rollup;




PROCEDURE Delete_resource_rollup
( p_api_version_number      IN   NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit                  IN   VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list           IN   VARCHAR2    := FND_API.G_FALSE
 ,x_msg_count               OUT NOCOPY NUMBER
 ,x_msg_data                OUT NOCOPY VARCHAR2
 ,x_return_status           OUT NOCOPY VARCHAR2
 ,p_project_id              IN   NUMBER
 ,p_plan_version_id_tbl     IN SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
 ,p_rbs_version_id_tbl      IN SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type()
) IS
   l_api_name         CONSTANT  VARCHAR2(30)     := 'Delete_resource_rollup';
   l_return_status    VARCHAR2(1);
   l_err_code          NUMBER(15);
   l_err_stage         VARCHAR2(2000);
   l_err_stack         VARCHAR2(2000);
   i                   NUMBER    := 0; --counter
   j                   NUMBER    := 0; --counter
   l_msg_count         NUMBER ;
   l_msg_data          VARCHAR2(2000);

begin
--  Standard begin of API savepoint

    SAVEPOINT Delete_resource_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number  ,
                               p_api_version_number  ,
                               l_api_name         ,
                               G_PKG_NAME         )
    THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN

       FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    -- CHECK FOR MANDATORY FIELDS

IF P_PROJECT_ID IS NULL THEN

  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
  THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_ID_IS_MISSING'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
  END IF;
   x_return_status             := FND_API.G_RET_STS_ERROR;
  RAISE FND_API.G_EXC_ERROR;
    END IF;

IF p_plan_version_id_tbl.COUNT=0 and p_rbs_version_id_tbl.COUNT=0 then
    DELETE FROM pji_rollup_level_status
    WHERE project_id=p_project_id;


    IF (SQL%ROWCOUNT > 0) THEN

  	DELETE FROM pji_fp_xbs_accum_f
  	WHERE project_id=p_project_id
  	AND (rbs_aggr_level = 'R'
  		 OR (rbs_aggr_level = 'L'
	 	 AND wbs_rollup_flag = 'Y')) ;

    END IF;
ELSIF p_plan_version_id_tbl.COUNT=0 and p_rbs_version_id_tbl.COUNT<>0 then

	FORALL j IN 1..p_rbs_version_id_tbl.COUNT

      DELETE FROM pji_rollup_level_status
       WHERE project_id=p_project_id
       and rbs_version_id=p_rbs_version_id_tbl(j);


    IF (SQL%ROWCOUNT > 0) THEN
	FORALL j IN 1..p_rbs_version_id_tbl.COUNT

    	DELETE FROM pji_fp_xbs_accum_f
  	WHERE project_id=p_project_id
    and rbs_version_id=p_rbs_version_id_tbl(j)
  	AND (rbs_aggr_level = 'R'
  		 OR (rbs_aggr_level = 'L'
	 	 AND wbs_rollup_flag = 'Y')) ;

    END IF;

ELSIF p_plan_version_id_tbl.COUNT<>0 and p_rbs_version_id_tbl.COUNT=0 then

	FORALL i IN 1..p_plan_version_id_tbl.COUNT

     DELETE FROM pji_rollup_level_status
     WHERE project_id=p_project_id
     and plan_version_id=p_plan_version_id_tbl(i);


    IF (SQL%ROWCOUNT > 0) THEN
	FORALL i IN 1..p_plan_version_id_tbl.COUNT

    	DELETE FROM pji_fp_xbs_accum_f
  	WHERE project_id=p_project_id
    and plan_version_id=p_plan_version_id_tbl(i)
  	AND (rbs_aggr_level = 'R'
  		 OR (rbs_aggr_level = 'L'
	 	 AND wbs_rollup_flag = 'Y')) ;

    END IF;

ELSIF p_plan_version_id_tbl.COUNT<>0 and p_rbs_version_id_tbl.COUNT<>0 then
	FOR j IN 1..p_rbs_version_id_tbl.COUNT LOOP
	   FORALL i IN 1..p_plan_version_id_tbl.COUNT
         DELETE FROM pji_rollup_level_status
         WHERE project_id=p_project_id
         and plan_version_id=p_plan_version_id_tbl(i)
         and rbs_version_id=p_rbs_version_id_tbl(j);


         IF (SQL%ROWCOUNT > 0) THEN
	       FORALL i IN 1..p_plan_version_id_tbl.COUNT

           	DELETE FROM pji_fp_xbs_accum_f
        	WHERE project_id=p_project_id
            and plan_version_id=p_plan_version_id_tbl(i)
            and rbs_version_id=p_rbs_version_id_tbl(j)
  	        AND (rbs_aggr_level = 'R'
  		    OR (rbs_aggr_level = 'L'
	 	     AND wbs_rollup_flag = 'Y')) ;

        END IF;
    END LOOP;
ELSE
NULL;
END IF;


  IF (FND_API.to_boolean( p_commit )) THEN
    COMMIT ;
  else
    ROLLBACK to Delete_resource_pub;
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO delete_resource_pub;
       x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get
        (   p_count    =>  x_msg_count  ,
            p_data    =>  x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_resource_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get
        (   p_count    =>  x_msg_count  ,
            p_data    =>  x_msg_data  );

  WHEN OTHERS THEN
      ROLLBACK TO delete_resource_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    FND_MSG_PUB.add_exc_msg
        ( p_pkg_name    => G_PKG_NAME
        , p_procedure_name  => l_api_name  );

  END IF;

  FND_MSG_PUB.Count_And_Get
      (   p_count    =>  x_msg_count  ,
          p_data    =>  x_msg_data  );

END Delete_resource_rollup;
end PJI_PERF_RPTG_PUB;

/
