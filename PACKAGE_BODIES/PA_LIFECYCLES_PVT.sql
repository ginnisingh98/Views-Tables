--------------------------------------------------------
--  DDL for Package Body PA_LIFECYCLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_LIFECYCLES_PVT" AS
 /* $Header: PALCDFVB.pls 120.1 2005/08/19 16:35:32 mwasowic noship $   */

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE create_lifecycle (
	P_api_version			IN	NUMBER   :=1.0				,
	P_commit			IN	VARCHAR2 :=FND_API.G_FALSE		,
	P_validate_only			IN	VARCHAR2 :=FND_API.G_TRUE		,
	P_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL   ,
	P_calling_module		IN	VARCHAR2 :='SELF_SERVICE'		,
	P_debug_mode			IN	VARCHAR2 :='N'				,
	P_max_msg_count			IN	NUMBER   :=G_MISS_NUM			,
	P_lifecycle_short_name 		IN	VARCHAR2				,
	P_lifecycle_name		IN	VARCHAR2				,
	P_lifecycle_description	        IN	VARCHAR2				,
	P_lifecycle_project_usage_type	IN	VARCHAR2				,
	P_lifecycle_product_usage_type	IN	VARCHAR2				,
	X_lifecycle_id			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	X_return_status			OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	) IS

	l_api_name		       CONSTANT VARCHAR(30) := 'create_lifecycle';
	l_api_version		       CONSTANT NUMBER      := 1.0;
	l_msg_count				NUMBER;
	l_msg_index_out				NUMBER;
	l_data					VARCHAR2(2000);
	l_msg_data				VARCHAR2(2000);
	l_return_status				VARCHAR2(1);


	l_is_uniq				VARCHAR2(1) :='N';
	l_row_id				VARCHAR2(30);
	l_lifecycle_id				NUMBER;
	l_pev_id				NUMBER;
	l_pev_struct_id				NUMBER;
	l_proj_struct_type_id			NUMBER;
	l_lcyl_usage_id				NUMBER;
	l_pev_sched_id				NUMBER;
	l_obj_relnship_id			NUMBER;
	l_structure_type_id			NUMBER;


	c_object_type CONSTANT VARCHAR(30) := 'PA_STRUCTURES';
	c_project_id CONSTANT NUMBER := 0;
	c_lifecycle	     CONSTANT VARCHAR(30) := 'LIFECYCLE';

	CURSOR cur_struc_type_id
	IS
	SELECT structure_type_id
	FROM   pa_structure_types
	WHERE  structure_type_class_code = c_lifecycle;

BEGIN


	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE PVT: Inside create_lifecycle...');
	END IF;

	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT LCYL_CREATE_LIFECYCLE_PVT;
	END IF;

        IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE PVT: Checking api compatibility...');
	END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           g_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE PVT: Checking for validations on parameters...');
	END IF;

	BEGIN
	  SELECT 'N'
	  INTO l_is_uniq
	  FROM dual
	  WHERE exists(Select 'XYZ' from pa_proj_elements
			WHERE element_number = P_lifecycle_short_name
			AND object_type=c_object_type
			AND project_id=c_project_id);
	EXCEPTION
	  when NO_DATA_FOUND then  -- the short name is unique
	  l_is_uniq := 'Y';
	END;
	-- This short name is already in use

	IF(l_is_uniq <> 'Y') THEN
		PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name           => 'PA_LCYL_SHORT_NAME_EXISTS'
				 );
		x_msg_data := 'PA_LCYL_SHORT_NAME_EXISTS';
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PVT.create_lifecycle : checking message count');
        END IF;

       l_msg_count := FND_MSG_PUB.count_msg;


       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages(
		  p_encoded        => FND_API.G_TRUE	,
	          p_msg_index      => 1			,
	          p_msg_count      => l_msg_count	,
	          p_msg_data       => l_msg_data	,
	          p_data           => l_data		,
	          p_msg_index_out  => l_msg_index_out
		  );
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;


	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE PVT:Obtaining lifecycle_id...');
	END IF;

        SELECT PA_TASKS_S.NEXTVAL
	INTO l_lifecycle_id
	FROM dual;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE PVT:Inserting into pa_proj_elements...');
	END IF;

	PA_PROJ_ELEMENTS_PKG.Insert_Row(
		X_ROW_ID			=> l_row_id			,
                X_PROJ_ELEMENT_ID		=> l_lifecycle_id		,
                X_PROJECT_ID			=> c_project_id			,
                X_OBJECT_TYPE			=> c_object_type		,
                X_ELEMENT_NUMBER		=> P_lifecycle_short_name	,
                X_NAME				=> P_lifecycle_name		,
                X_DESCRIPTION			=> P_lifecycle_description	,
                X_STATUS_CODE			=> NULL				,
                X_WF_STATUS_CODE		=> NULL				,
                X_PM_PRODUCT_CODE		=> NULL				,
                X_PM_TASK_REFERENCE		=> NULL				,
                X_CLOSED_DATE			=> NULL				,
                X_LOCATION_ID			=> NULL				,
                X_MANAGER_PERSON_ID		=> NULL				,
                X_CARRYING_OUT_ORGANIZATION_ID  => NULL				,
                X_TYPE_ID			=> NULL				,
                X_PRIORITY_CODE			=> NULL				,
                X_INC_PROJ_PROGRESS_FLAG	=> NULL				,
                X_REQUEST_ID			=> NULL				,
                X_PROGRAM_APPLICATION_ID	=> NULL				,
                X_PROGRAM_ID			=> NULL				,
                X_PROGRAM_UPDATE_DATE		=> NULL				,
                X_LINK_TASK_FLAG		=> NULL				,
                X_ATTRIBUTE_CATEGORY		=> NULL				,
                X_ATTRIBUTE1			=> NULL				,
                X_ATTRIBUTE2			=> NULL				,
                X_ATTRIBUTE3			=> NULL				,
                X_ATTRIBUTE4			=> NULL				,
                X_ATTRIBUTE5			=> NULL				,
                X_ATTRIBUTE6			=> NULL				,
                X_ATTRIBUTE7			=> NULL				,
                X_ATTRIBUTE8			=> NULL				,
                X_ATTRIBUTE9			=> NULL				,
                X_ATTRIBUTE10			=> NULL				,
                X_ATTRIBUTE11			=> NULL				,
                X_ATTRIBUTE12			=> NULL				,
                X_ATTRIBUTE13			=> NULL				,
                X_ATTRIBUTE14			=> NULL				,
                X_ATTRIBUTE15			=> NULL				,
                X_TASK_WEIGHTING_DERIV_CODE     => NULL				,
                X_WORK_ITEM_CODE		=> NULL				,
                X_UOM_CODE			=> NULL				,
                X_WQ_ACTUAL_ENTRY_CODE		=> NULL				,
                X_TASK_PROGRESS_ENTRY_PAGE_ID   => NULL				,
                x_parent_structure_id		=> NULL				,
                x_phase_code			=> NULL				,
                x_phase_version_id		=> NULL,
                X_SOURCE_OBJECT_ID              => c_project_id,
                X_SOURCE_OBJECT_TYPE            => 'PA_PROJECTS'
		);

	IF(p_debug_mode = 'Y') THEN
		pa_debug.debug('CREATE_LIFECYCLE PVT:Obtaining proj_element_version_id...');
	END IF;


        SELECT PA_PROJ_ELEMENT_VERSIONS_S.NEXTVAL
	INTO l_pev_id
	FROM dual;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE PVT:Inserting into pa_proj_element_versions...');
	END IF;

	PA_PROJ_ELEMENT_VERSIONS_PKG.Insert_Row(
		X_ROW_ID                        => l_row_id		,
                X_ELEMENT_VERSION_ID            => l_pev_id		,
                X_PROJ_ELEMENT_ID               => l_lifecycle_id	,
                X_OBJECT_TYPE                   => c_object_type	,
                X_PROJECT_ID                    => c_project_id		,
                X_PARENT_STRUCTURE_VERSION_ID   => NULL			,
                X_DISPLAY_SEQUENCE              => NULL			,
                X_WBS_LEVEL                     => NULL			,
                X_WBS_NUMBER                    => NULL			,
                X_ATTRIBUTE_CATEGORY            => NULL			,
                X_ATTRIBUTE1                    => NULL			,
                X_ATTRIBUTE2                    => NULL			,
                X_ATTRIBUTE3                    => NULL			,
                X_ATTRIBUTE4                    => NULL			,
                X_ATTRIBUTE5                    => NULL			,
                X_ATTRIBUTE6                    => NULL			,
                X_ATTRIBUTE7                    => NULL			,
                X_ATTRIBUTE8                    => NULL			,
                X_ATTRIBUTE9                    => NULL			,
                X_ATTRIBUTE10                   => NULL			,
                X_ATTRIBUTE11                   => NULL			,
                X_ATTRIBUTE12                   => NULL			,
                X_ATTRIBUTE13                   => NULL			,
                X_ATTRIBUTE14                   => NULL			,
                X_ATTRIBUTE15                   => NULL			,
                X_TASK_UNPUB_VER_STATUS_CODE    => 'Working',
                X_SOURCE_OBJECT_ID              => c_project_id ,
                X_SOURCE_OBJECT_TYPE            => 'PA_PROJECTS'
		);

         IF(p_debug_mode = 'Y') THEN
		pa_debug.debug('CREATE_LIFECYCLE PVT:Obtaining proj_element_version_structure_id...');
	END IF;

	SELECT PA_PROJ_ELEM_VER_STRUCTURE_S.NEXTVAL
	INTO l_pev_struct_id
	FROM dual;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE PVT:Inserting into pa_proj_elem_version_structure...');
	END IF;


	PA_PROJ_ELEM_VER_STRUCTURE_PKG.insert_row(
                    X_ROWID                   => l_row_id			,
                    X_PEV_STRUCTURE_ID        => l_pev_struct_id		,
                    X_ELEMENT_VERSION_ID      => l_pev_id			,
                    X_VERSION_NUMBER          => 1				,
                    X_NAME                    => P_lifecycle_name		,
                    X_PROJECT_ID              => c_project_id			,
                    X_PROJ_ELEMENT_ID         => l_lifecycle_id			,
                    X_DESCRIPTION             => P_lifecycle_description	,
                    X_EFFECTIVE_DATE          => NULL				,
                    X_PUBLISHED_DATE          => NULL				,
                    X_PUBLISHED_BY            => NULL				,
                    X_CURRENT_BASELINE_DATE   => NULL				,
                    X_CURRENT_BASELINE_FLAG   => 'Y'				,
                    X_CURRENT_BASELINE_BY     => NULL				,
                    X_ORIGINAL_BASELINE_DATE  => NULL				,
                    X_ORIGINAL_BASELINE_FLAG  => 'Y'				,
                    X_ORIGINAL_BASELINE_BY    => NULL				,
                    X_LOCK_STATUS_CODE        => NULL				,
                    X_LOCKED_BY               => NULL				,
                    X_LOCKED_DATE             => NULL 				,
                    X_STATUS_CODE             => NULL				,
                    X_WF_STATUS_CODE          => NULL				,
                    X_LATEST_EFF_PUBLISHED_FLAG => 'Y'				,
                    X_CHANGE_REASON_CODE      => NULL 				,
                    X_RECORD_VERSION_NUMBER   => NULL				 ,
                    X_SOURCE_OBJECT_ID        => c_project_id,
                    X_SOURCE_OBJECT_TYPE      => 'PA_PROJECTS'
		  );

	IF(p_debug_mode = 'Y') THEN
		pa_debug.debug('CREATE_LIFECYCLE PVT:Obtaining proj_structure_type_id...');
	END IF;

	SELECT PA_PROJ_STRUCTURE_TYPES_S.NEXTVAL
	INTO   l_proj_struct_type_id
	FROM   dual;

	OPEN  cur_struc_type_id;
        FETCH cur_struc_type_id INTO l_structure_type_id;
	CLOSE cur_struc_type_id;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE PVT:Inserting into pa_proj_structure_types...');
	END IF;


	PA_PROJ_STRUCTURE_TYPES_PKG.insert_row(
                      X_ROWID                  => l_row_id			,
                      X_PROJ_STRUCTURE_TYPE_ID => l_proj_struct_type_id		,
                      X_PROJ_ELEMENT_ID        => l_lifecycle_id		,
                      X_STRUCTURE_TYPE_ID      => l_structure_type_id		,
                      X_RECORD_VERSION_NUMBER  => NULL				,
                      X_ATTRIBUTE_CATEGORY     => NULL				,
                      X_ATTRIBUTE1             => NULL				,
                      X_ATTRIBUTE2             => NULL				,
                      X_ATTRIBUTE3             => NULL				,
                      X_ATTRIBUTE4             => NULL				,
                      X_ATTRIBUTE5             => NULL				,
                      X_ATTRIBUTE6             => NULL				,
                      X_ATTRIBUTE7             => NULL				,
                      X_ATTRIBUTE8             => NULL				,
                      X_ATTRIBUTE9             => NULL				,
                      X_ATTRIBUTE10            => NULL				,
                      X_ATTRIBUTE11            => NULL				,
                      X_ATTRIBUTE12            => NULL				,
                      X_ATTRIBUTE13            => NULL				,
                      X_ATTRIBUTE14            => NULL				,
                      X_ATTRIBUTE15            => NULL
		      );

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE PVT:Inserting into PA_LIFECYCLE_USAGES..');
	END IF;

	IF (p_lifecycle_project_usage_type = 'Y') THEN
	        SELECT PA_LIFECYCLE_USAGES_S.NEXTVAL
		INTO   l_lcyl_usage_id
		FROM   dual;

		PA_LIFECYCLE_USAGES_PKG.INSERT_ROW(
			  X_LIFECYCLE_USAGE_ID       => l_lcyl_usage_id	,
			  X_RECORD_VERSION_NUMBER    => 1			,
			  X_LIFECYCLE_ID 	     => l_lifecycle_id		,
			  X_USAGE_TYPE		     => 'PROJECTS'
			  );
	END IF;

	IF  (p_lifecycle_product_usage_type = 'Y') THEN
	        SELECT PA_LIFECYCLE_USAGES_S.NEXTVAL
		INTO   l_lcyl_usage_id
		FROM   dual;

		PA_LIFECYCLE_USAGES_PKG.INSERT_ROW(
			  X_LIFECYCLE_USAGE_ID       => l_lcyl_usage_id		,
			  X_RECORD_VERSION_NUMBER    => 1			,
			  X_LIFECYCLE_ID 	     => l_lifecycle_id		,
			  X_USAGE_TYPE		     => 'PRODUCTS'
		          );
	END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE PVT:Inserting into PA_PROJ_ELEM_VER_SCHEDULE..');
	END IF;

	 SELECT PA_PROJ_ELEM_VER_SCHEDULE_S.NEXTVAL
	 INTO   l_pev_sched_id
	 FROM   dual;


	PA_PROJ_ELEMENT_SCH_PKG.Insert_Row (
		X_ROW_ID			     => l_row_id		,
		X_PEV_SCHEDULE_ID		     => l_pev_sched_id		,
		X_ELEMENT_VERSION_ID		     => l_pev_id		,
		X_PROJECT_ID			     => c_project_id		,
		X_PROJ_ELEMENT_ID		     => l_lifecycle_id		,
		X_SCHEDULED_START_DATE		     => sysdate			,
		X_SCHEDULED_FINISH_DATE		     => sysdate			,
		X_OBLIGATION_START_DATE		     => NULL			,
		X_OBLIGATION_FINISH_DATE	     => NULL			,
		X_ACTUAL_START_DATE		     => NULL			,
		X_ACTUAL_FINISH_DATE		     => NULL			,
		X_ESTIMATED_START_DATE		     => NULL			,
		X_ESTIMATED_FINISH_DATE		     => NULL			,
		X_DURATION                           => NULL			,
		X_EARLY_START_DATE		     => NULL			,
		X_EARLY_FINISH_DATE		     => NULL			,
		X_LATE_START_DATE		     => NULL			,
		X_LATE_FINISH_DATE		     => NULL			,
		X_CALENDAR_ID			     => NULL			,
		X_MILESTONE_FLAG		     => NULL			,
		X_CRITICAL_FLAG			     => NULL			,
		X_WQ_PLANNED_QUANTITY		     => NULL			,
		X_PLANNED_EFFORT                     => NULL			,
		X_ACTUAL_DURATION                    => NULL			,
		X_ESTIMATED_DURATION		     => NULL,
		X_SOURCE_OBJECT_ID                 => c_project_id,
		X_SOURCE_OBJECT_TYPE               => 'PA_PROJECTS'
		);

-- No need to populate pa_object relationship at thi stage, it will be populated at the time of phase creation

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PVT.create_lifecycle : checking message count');
        END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages(
	          p_encoded	    => FND_API.G_TRUE		,
	          p_msg_index	    => 1			,
	          p_msg_count	    => l_msg_count		,
	          p_msg_data       => l_msg_data		,
	          p_data           => l_data			,
	          p_msg_index_out  => l_msg_index_out
		  );
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;


x_lifecycle_id       := l_lifecycle_id;
x_return_status      := FND_API.G_RET_STS_SUCCESS;

IF FND_API.TO_BOOLEAN(P_COMMIT)
     THEN
        COMMIT;
     END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_CREATE_LIFECYCLE_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'create_lifecycle',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_CREATE_LIFECYCLE_PVT;
    END IF;

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_CREATE_LIFECYCLE_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'create_lifecycle',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

end create_lifecycle;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/


PROCEDURE create_lifecycle_phase (
	 P_api_version			IN	NUMBER   :=1.0				,
	 p_commit			IN	VARCHAR2 :=FND_API.G_FALSE		,
	 p_validate_only		IN	VARCHAR2 :=FND_API.G_TRUE		,
	 p_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL	,
	 p_calling_module		IN	VARCHAR2 :='SELF_SERVICE'		,
	 p_debug_mode			IN	VARCHAR2 :='N'				,
	 P_max_msg_count		IN	NUMBER   :=G_MISS_NUM			,
	 P_lifecycle_id			IN	NUMBER					,
	 P_phase_display_sequence	IN	NUMBER					,
	 P_phase_code			IN	VARCHAR2				,
	 P_phase_short_name 		IN	VARCHAR2 				,
	 P_phase_name			IN	VARCHAR2 				,
	 P_phase_description		IN	VARCHAR2 				,
	 X_lifecycle_phase_id		OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	 X_return_status		OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	 X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	 X_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	) IS

	l_api_name           CONSTANT VARCHAR(30) := 'create_lifecycle_phase';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data                    VARCHAR2(2000);
	l_return_status               VARCHAR2(1);

        l_is_uniq		      VARCHAR2(1);
	l_row_id                      VARCHAR2(30);
	l_phase_id                    NUMBER;
	l_pev_id	              NUMBER;
	l_pev_struct_id               NUMBER;
	l_proj_struct_type_id         NUMBER;
	l_pev_sched_id	              NUMBER;
	l_obj_relnship_id             NUMBER;
	l_life_elem_ver_id            NUMBER;


	c_object_type	     CONSTANT VARCHAR(30) := 'PA_TASKS';
	c_project_id	     CONSTANT NUMBER := 0;


	CURSOR l_check_phase_name_csr
	IS
	SELECT 'N'
	FROM   dual
	WHERE  exists(Select 'XYZ'
		FROM  pa_proj_elements pelem
		    , pa_proj_element_versions phasever
		WHERE phasever.PARENT_STRUCTURE_VERSION_ID = l_life_elem_ver_id
		AND   phasever.PROJECT_ID = c_project_id
		AND   phasever.OBJECT_TYPE = c_object_type
		AND   phasever.PROJ_ELEMENT_ID = pelem.PROJ_ELEMENT_ID
		AND   pelem.element_number = p_phase_short_name
		AND   pelem.project_id = c_project_id
		AND   pelem.object_type = c_object_type);

	CURSOR l_get_life_elem_ver_id
	IS
	SELECT 	ELEMENT_VERSION_ID
	FROM    pa_proj_element_versions
	WHERE 	PROJ_ELEMENT_ID = p_lifecycle_id;

BEGIN

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE_PVT.create_lifecycle_phase: Inside create_lifecycle_phase ...');
	END IF;

	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT LCYL_CREATE_LCYL_PHASES_PVT;
	END IF;

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE_PVT.create_lifecycle_phase: Calling api compatilbility check...');
	END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(
			l_api_version	,
                        p_api_version	,
                        l_api_name	,
                        g_pkg_name
			)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE_PVT.create_lifecycle_phase: Checking for valid parameters..');
	END IF;

	OPEN l_get_life_elem_ver_id;
	FETCH l_get_life_elem_ver_id INTO l_life_elem_ver_id;
	CLOSE l_get_life_elem_ver_id;

	l_is_uniq :='Y';
	OPEN l_check_phase_name_csr;
        FETCH l_check_phase_name_csr INTO l_is_uniq;
        CLOSE l_check_phase_name_csr;

       -- This check  shd be done if validation level full
	IF(l_is_uniq <> 'Y') THEN
		PA_UTILS.ADD_MESSAGE(
				p_app_short_name => 'PA'	,
                                p_msg_name       => 'PA_LCYL_DUPLICATE_PHASE_SHNAME'
				);
		x_msg_data := 'PA_LCYL_DUPLICATE_PHASE_SHNAME';
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PVT.create_lifecycle_phase : checking message count');
        END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages
	         (p_encoded        => FND_API.G_TRUE		,
	          p_msg_index      => 1				,
	          p_msg_count      => l_msg_count		,
	          p_msg_data       => l_msg_data		,
	          p_data           => l_data			,
	          p_msg_index_out  => l_msg_index_out
		  );
	    x_msg_data := l_data;
	 END IF;
         RAISE  FND_API.G_EXC_ERROR;
       END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE_PVT.create_lifecycle_phase: Obtaining lifecycle_phase_id...');
	END IF;

        SELECT PA_TASKS_S.NEXTVAL
	INTO   l_phase_id
	FROM   dual;


	if(p_debug_mode = 'Y') then
	  pa_debug.debug('CREATE_LIFECYCLE_PVT.create_lifecycle_phase:Inserting into pa_proj_elements...');
	end if;

	PA_PROJ_ELEMENTS_PKG.Insert_Row(
		X_ROW_ID                  => l_row_id			,
                x_proj_element_id         => l_phase_id			,
                x_project_id              => c_project_id		,
                x_object_type             => c_object_type		,
                x_element_number          => p_phase_short_name		,
                x_name                    => p_phase_name		,
                X_DESCRIPTION             => P_phase_description	,
                X_STATUS_CODE             => NULL			,
                X_WF_STATUS_CODE          => NULL			,
                X_PM_PRODUCT_CODE         => NULL			,
                X_PM_TASK_REFERENCE       => NULL			,
                X_CLOSED_DATE             => NULL			,
                X_LOCATION_ID             => NULL			,
                X_MANAGER_PERSON_ID       => NULL			,
                X_CARRYING_OUT_ORGANIZATION_ID => NULL			,
                X_TYPE_ID                 => NULL			,
                X_PRIORITY_CODE           => NULL			,
                X_INC_PROJ_PROGRESS_FLAG  => NULL			,
                X_REQUEST_ID              => NULL			,
                X_PROGRAM_APPLICATION_ID  => NULL			,
                X_PROGRAM_ID              => NULL			,
                X_PROGRAM_UPDATE_DATE     => NULL			,
                X_LINK_TASK_FLAG          => NULL			,
                X_ATTRIBUTE_CATEGORY      => NULL			,
                X_ATTRIBUTE1              => NULL			,
                X_ATTRIBUTE2              => NULL			,
                X_ATTRIBUTE3              => NULL			,
                X_ATTRIBUTE4              => NULL			,
                X_ATTRIBUTE5              => NULL			,
                X_ATTRIBUTE6              => NULL			,
                X_ATTRIBUTE7              => NULL			,
                X_ATTRIBUTE8              => NULL			,
                X_ATTRIBUTE9              => NULL			,
                X_ATTRIBUTE10             => NULL			,
                X_ATTRIBUTE11             => NULL			,
                X_ATTRIBUTE12             => NULL			,
                X_ATTRIBUTE13             => NULL			,
                X_ATTRIBUTE14             => NULL			,
                X_ATTRIBUTE15             => NULL			,
                X_TASK_WEIGHTING_DERIV_CODE   => NULL			,
                X_WORK_ITEM_CODE          => NULL			,
                X_UOM_CODE                => NULL			,
                X_WQ_ACTUAL_ENTRY_CODE    => NULL			,
                X_TASK_PROGRESS_ENTRY_PAGE_ID  => NULL			,
                x_parent_structure_id     => P_lifecycle_id		,
                x_phase_code              => p_phase_code		,
                x_phase_version_id        => NULL,
                X_SOURCE_OBJECT_ID        => c_project_id,
                X_SOURCE_OBJECT_TYPE      => 'PA_PROJECTS'
		);


	IF(p_debug_mode = 'Y') THEN
		pa_debug.debug('CREATE_LIFECYCLE PVT.create_lifecyle_phase:Obtaining proj_element_version_id...');
	END IF;


        SELECT PA_PROJ_ELEMENT_VERSIONS_S.NEXTVAL
	INTO   l_pev_id
	FROM   dual;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE PVT.create_lifecyle_phas:Inserting into pa_proj_element_versions...');
	END IF;

	PA_PROJ_ELEMENT_VERSIONS_PKG.Insert_Row(
		X_ROW_ID                        => l_row_id			,
                X_ELEMENT_VERSION_ID            => l_pev_id			,
                X_PROJ_ELEMENT_ID               => l_phase_id			,
                X_OBJECT_TYPE                   => c_object_type		,
                X_PROJECT_ID                    => c_project_id			,
                X_PARENT_STRUCTURE_VERSION_ID   => l_life_elem_ver_id		,
                X_DISPLAY_SEQUENCE              => p_phase_display_sequence	,
                X_WBS_LEVEL                     => NULL				,
                X_WBS_NUMBER                    => NULL				,
                X_ATTRIBUTE_CATEGORY            => NULL				,
                X_ATTRIBUTE1                    => NULL				,
                X_ATTRIBUTE2                    => NULL				,
                X_ATTRIBUTE3                    => NULL				,
                X_ATTRIBUTE4                    => NULL				,
                X_ATTRIBUTE5                    => NULL				,
                X_ATTRIBUTE6                    => NULL				,
                X_ATTRIBUTE7                    => NULL				,
                X_ATTRIBUTE8                    => NULL				,
                X_ATTRIBUTE9                    => NULL				,
                X_ATTRIBUTE10                   => NULL				,
                X_ATTRIBUTE11                   => NULL				,
                X_ATTRIBUTE12                   => NULL				,
                X_ATTRIBUTE13                   => NULL				,
                X_ATTRIBUTE14                   => NULL				,
                X_ATTRIBUTE15                   => NULL				,
		X_TASK_UNPUB_VER_STATUS_CODE    => 'Working',
		X_SOURCE_OBJECT_ID              => c_project_id,
		X_SOURCE_OBJECT_TYPE            => 'PA_PROJECTS'
		);

  	IF(p_debug_mode = 'Y') THEN
		pa_debug.debug('CREATE_LIFECYCLE PVT.create_lifecyle_phase:Obtaining pev_schedule_id...');
	END IF;

	SELECT PA_PROJ_ELEM_VER_SCHEDULE_S.NEXTVAL
	INTO   l_pev_sched_id
	FROM   dual;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE PVT.create_lifecyle_phas:Inserting into PA_PROJ_ELEMENT_VER_SCHEDULE...');
	END IF;


	PA_PROJ_ELEMENT_SCH_PKG.Insert_Row (
		X_ROW_ID			=> l_row_id			,
		X_PEV_SCHEDULE_ID		=> l_pev_sched_id		,
		X_ELEMENT_VERSION_ID		=> l_pev_id			,
		X_PROJECT_ID			=> c_project_id			,
		X_PROJ_ELEMENT_ID		=> l_phase_id			,
		X_SCHEDULED_START_DATE		=> sysdate			,
		X_SCHEDULED_FINISH_DATE		=> sysdate			,
		X_OBLIGATION_START_DATE		=> NULL				,
		X_OBLIGATION_FINISH_DATE	=> NULL				,
		X_ACTUAL_START_DATE		=> NULL				,
		X_ACTUAL_FINISH_DATE		=> NULL				,
		X_ESTIMATED_START_DATE		=> NULL				,
		X_ESTIMATED_FINISH_DATE		=> NULL				,
		X_DURATION			=> NULL				,
		X_EARLY_START_DATE		=> NULL				,
		X_EARLY_FINISH_DATE		=> NULL				,
		X_LATE_START_DATE		=> NULL				,
		X_LATE_FINISH_DATE		=> NULL				,
		X_CALENDAR_ID			=> NULL				,
		X_MILESTONE_FLAG		=> NULL				,
		X_CRITICAL_FLAG			=> NULL				,
		X_WQ_PLANNED_QUANTITY		=> NULL				,
		X_PLANNED_EFFORT		=> NULL				,
		X_ACTUAL_DURATION		=> NULL				,
		X_ESTIMATED_DURATION		=> NULL,
		X_SOURCE_OBJECT_ID      => c_project_id,
		X_SOURCE_OBJECT_TYPE    => 'PA_PROJECTS'
		);


  	IF(p_debug_mode = 'Y') THEN
		pa_debug.debug('CREATE_LIFECYCLE PVT.create_lifecyle_phase:Obtaining OBJECT_RELATIONSHIP_ID...');
	END IF;

	SELECT pa_object_relationships_s.NEXTVAL
	INTO   l_obj_relnship_id
	FROM   dual;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE PVT.create_lifecyle_phas:Inserting into PA_OBJECT_RELATIONSHIPS...');
	END IF;

	PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
		 p_user_id			=> FND_GLOBAL.USER_ID			,
		 p_object_type_from		=> 'PA_STRUCTURES'			,
	         p_object_id_from1		=> l_life_elem_ver_id			,
	         p_object_id_from2		=> NULL					,
	         p_object_id_from3		=> NULL					,
	         p_object_id_from4		=> NULL					,
	         p_object_id_from5		=> NULL					,
	         p_object_type_to		=> 'PA_TASKS'				,
	         p_object_id_to1		=> l_pev_id				,
		 p_object_id_to2		=> NULL					,
	         p_object_id_to3		=> NULL					,
	         p_object_id_to4		=> NULL					,
		 p_object_id_to5		=> NULL					,
		 p_relationship_type		=> 'S'					,
	         p_relationship_subtype		=> 'STRUCTURE_TO_TASK'			,
	         p_lag_day			=> NULL					,
	         p_imported_lag			=> NULL					,
	         p_priority			=> NULL					,
	         p_pm_product_code		=> NULL					,
	         x_object_relationship_id	=> l_obj_relnship_id			,
	         x_return_status		=> l_return_status
		);

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PVT.create_lifecycle_phase : checking message count');
        END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages
	         (p_encoded        => FND_API.G_TRUE		,
	          p_msg_index      => 1				,
	          p_msg_count      => l_msg_count		,
	          p_msg_data       => l_msg_data		,
	          p_data           => l_data			,
	          p_msg_index_out  => l_msg_index_out
		  );
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

x_lifecycle_phase_id       := l_phase_id;
x_return_status      := FND_API.G_RET_STS_SUCCESS;

IF FND_API.TO_BOOLEAN(P_COMMIT)
     THEN
        COMMIT;
     END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_CREATE_LCYL_PHASES_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'CREATE_LIFECYCLE_PHASE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_CREATE_LCYL_PHASES_PVT;
    END IF;

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_CREATE_LCYL_PHASES_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'CREATE_LIFECYCLE_PHASE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END create_lifecycle_phase;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE delete_lifecycle(
	 P_api_version			IN	NUMBER   :=1.0				,
	 P_commit			IN	VARCHAR2 :=FND_API.G_FALSE		,
	 P_validate_only		IN	VARCHAR2 :=FND_API.G_TRUE		,
	 P_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL	,
	 P_calling_module		IN	VARCHAR2 :='SELF_SERVICE'		,
	 P_debug_mode			IN	VARCHAR2 :='N'				,
	 P_max_msg_count		IN	NUMBER   :=G_MISS_NUM			,
	 P_lifecycle_id			IN	NUMBER					,
	 P_record_version_number        IN      NUMBER					,
	 X_return_status		OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	 X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	 X_msg_data			OUT	NOCOPY VARCHAR2				 --File.Sql.39 bug 4440895
	) IS

l_api_name           CONSTANT VARCHAR(30) := 'delete_lifecycle';
l_api_version        CONSTANT NUMBER      := 1.0;
l_msg_count                   NUMBER;
l_msg_index_out               NUMBER;
l_data			      VARCHAR2(2000);
l_msg_data                    VARCHAR2(2000);
l_return_status               VARCHAR2(1);


l_rowid			      VARCHAR2(30);
l_element_version_id	      NUMBER;
l_record_version_number       NUMBER;
l_lifecycle_usage_id          NUMBER;


c_object_type	     CONSTANT VARCHAR(30) := 'PA_STRUCTURES';
c_project_id	     CONSTANT NUMBER := 0;


CURSOR l_row_proj_element_versions
IS
SELECT rowid,element_version_id
FROM   pa_proj_element_versions
WHERE  proj_element_id = P_lifecycle_id
AND   project_id = c_project_id
AND   object_type = c_object_type;


CURSOR l_row_proj_elem_ver_schedule
IS
SELECT rowid
FROM   pa_proj_elem_ver_schedule
WHERE  proj_element_id = P_lifecycle_id
AND    element_version_id = l_element_version_id
AND    project_id = c_project_id;


CURSOR l_row_proj_workplan_attrs
IS
SELECT rowid,record_version_number
FROM   pa_proj_workplan_attr
WHERE  proj_element_id = P_lifecycle_id
AND    project_id = c_project_id;


CURSOR l_row_proj_elem_ver_structure
IS
SELECT rowid
FROM   pa_proj_elem_ver_structure
WHERE  element_version_id = l_element_version_id
AND    proj_element_id = P_lifecycle_id
AND    project_id = c_project_id;


CURSOR l_row_proj_structure_types
IS
SELECT rowid
FROM   pa_proj_structure_types
WHERE  proj_element_id = P_lifecycle_id;


cursor l_row_lifecycle_usages
IS
SELECT LIFECYCLE_USAGE_ID
FROM   pa_lifecycle_usages
WHERE  lifecycle_id = P_lifecycle_id;


Begin

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE_PVT: inside delete_lifecycle.....');
	END IF;

	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT LCYL_DEL_PVT;
	END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE_PVT.delete_lifecycle_phase: Checking for call compatability...');
	END IF;

	IF NOT FND_API.COMPATIBLE_API_CALL(
				l_api_version	,
				p_api_version	,
				l_api_name	,
                                g_pkg_name
				)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('CREATE_LIFECYCLE_PVT.delete_lifecycle_phase: Locking on pa_proj_elements...');
	end if;


        --Lock record
        IF (p_validate_only <> FND_API.G_TRUE) THEN
        BEGIN
        -- BEGIN lock

	   SELECT rowid into l_rowid
           FROM pa_proj_elements
           WHERE proj_element_id = P_lifecycle_id
           AND record_version_number = p_record_version_number
	   AND   project_id = c_project_id
           AND   object_type = c_object_type

	   FOR update of record_version_number NOWAIT;

        EXCEPTION

	 when TIMEOUT_ON_RESOURCE then
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(
				p_app_short_name => 'PA',
				p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED'
				);
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';

	 when NO_DATA_FOUND then
	     x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(
				p_app_short_name => 'PA',
				p_msg_name       => 'PA_XC_RECORD_CHANGED'
				);
            l_msg_data := 'PA_XC_RECORD_CHANGED';

	 when OTHERS then
	     x_return_status := FND_API.G_RET_STS_ERROR;
	    IF SQLCODE = -54 THEN
              PA_UTILS.ADD_MESSAGE(
				p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED'
				);
              l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            ELSE
              raise;
            END IF;
        --END LOCK
	END;

      ELSE
      -- IF p_validate_only IS true
      BEGIN

	   SELECT rowid into l_rowid
           FROM   pa_proj_elements
           WHERE  proj_element_id = P_lifecycle_id
 	   AND    project_id = c_project_id
           AND    object_type = c_object_type
           AND    record_version_number = p_record_version_number;

      EXCEPTION

	 when NO_DATA_FOUND then
 	     x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(
				p_app_short_name => 'PA',
                                p_msg_name       => 'PA_XC_RECORD_CHANGED'
				);
            l_msg_data := 'PA_XC_RECORD_CHANGED';

	 when OTHERS then
            raise;
      END;
    END IF;

   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle: checking message count');
   END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages
	         (p_encoded        => FND_API.G_TRUE	,
	          p_msg_index      => 1			,
	          p_msg_count      => l_msg_count	,
	          p_msg_data       => l_msg_data	,
	          p_data           => l_data		,
	          p_msg_index_out  => l_msg_index_out
		  );
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle:Calling PA_PROJ_ELEMENTS_PKG.delete_Row');
   END IF;

     PA_PROJ_ELEMENTS_PKG.delete_Row(l_rowid);


   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle:Calling PA_PROJ_ELEMENT_VERSIONS_PKG.delete_Row');
   END IF;

     OPEN l_row_proj_element_versions;
     FETCH l_row_proj_element_versions into l_rowid,l_element_version_id;
     CLOSE l_row_proj_element_versions;

     PA_PROJ_ELEMENT_VERSIONS_PKG.delete_Row(l_rowid);

   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle:Calling PA_PROJ_ELEMENT_SCH_PKG.delete_Row');
   END IF;

     OPEN l_row_proj_elem_ver_schedule;
     FETCH l_row_proj_elem_ver_schedule into l_rowid;
     CLOSE l_row_proj_elem_ver_schedule;

     PA_PROJ_ELEMENT_SCH_PKG.delete_Row(l_rowid);



   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle:Calling PA_PROJ_ELEM_VER_STRUCTURE_PKG.delete_Row');
   END IF;

      OPEN l_row_proj_elem_ver_structure;
      FETCH l_row_proj_elem_ver_structure into l_rowid;
      CLOSE l_row_proj_elem_ver_structure;

      PA_PROJ_ELEM_VER_STRUCTURE_PKG.delete_Row(l_rowid);

   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle:Calling PA_PROJ_STRUCTURE_TYPES_PKG.delete_Row');
   END IF;

     OPEN l_row_proj_structure_types;
     FETCH l_row_proj_structure_types into l_rowid;
     CLOSE l_row_proj_structure_types;

     PA_PROJ_STRUCTURE_TYPES_PKG.delete_Row(l_rowid);

   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle:Calling PA_LIFECYCLE_USAGES_PKG.delete_Row');
   END IF;

     OPEN l_row_lifecycle_usages;
     LOOP
      FETCH l_row_lifecycle_usages into l_LIFECYCLE_USAGE_ID;
          EXIT WHEN l_row_lifecycle_usages%NOTFOUND;
          PA_LIFECYCLE_USAGES_PKG.Delete_Row(l_LIFECYCLE_USAGE_ID);
      END LOOP;
     CLOSE l_row_lifecycle_usages;


     -- No need to delete object relationship here. It will be deleted in phase deletion


IF (p_debug_mode = 'Y') THEN
	pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle: checking message count');
END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages(
				p_encoded        => FND_API.G_TRUE	,
				p_msg_index      => 1			,
				p_msg_count      => l_msg_count		,
				p_msg_data       => l_msg_data		,
				p_data           => l_data		,
				p_msg_index_out  => l_msg_index_out
				);
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DEL_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'DELETE_LIFECYCLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DEL_PVT;
    END IF;


WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DEL_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'DELETE_LIFECYCLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END delete_lifecycle;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/


PROCEDURE delete_lifecycle_phase (
	P_api_version			IN	NUMBER	  := 1.0			,
	P_commit			IN	VARCHAR2  := FND_API.G_FALSE 		,
	P_validate_only			IN	VARCHAR2  := FND_API.G_TRUE  		,
	P_validation_level		IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL	,
	P_calling_module		IN	VARCHAR2  := 'SELF_SERVICE'  		,
	P_debug_mode			IN	VARCHAR2  := 'N'	     		,
	P_max_msg_count			IN	NUMBER    := G_MISS_NUM			,
	P_phase_id			IN	NUMBER 	 				,
	p_record_version_number         IN      NUMBER					,
	X_return_status			OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	) IS
l_api_name           CONSTANT VARCHAR(30) := 'delete_lifecycle_phase';
l_api_version        CONSTANT NUMBER      := 1.0;
l_msg_count                   NUMBER;
l_msg_index_out               NUMBER;
l_data			      VARCHAR2(2000);
l_msg_data                    VARCHAR2(2000);
l_return_status               VARCHAR2(1);


l_rowid			      VARCHAR2(30);
l_element_version_id	      NUMBER;
l_par_element_version_id      NUMBER;
l_record_version_number       NUMBER;
l_obj_rel_id		      NUMBER;


c_object_type        CONSTANT VARCHAR(30) := 'PA_TASKS';
c_project_id	     CONSTANT NUMBER := 0;


CURSOR l_row_proj_element_versions
IS
Select rowid,element_version_id,parent_structure_version_id
From pa_proj_element_versions
Where proj_element_id = P_phase_id
AND   project_id = c_project_id
AND   object_type = c_object_type;

CURSOR l_row_proj_elem_ver_schedule
IS
Select rowid
From pa_proj_elem_ver_schedule
Where proj_element_id = P_phase_id
AND element_version_id = l_element_version_id
AND   project_id = c_project_id;

CURSOR l_row_object_relationship
IS
Select object_relationship_id, record_version_number
From pa_object_relationships
Where object_type_from = 'PA_STRUCTURES'
and object_id_from1 =  l_par_element_version_id
and object_type_to = c_object_type
and object_id_to1 =  l_element_version_id
and relationship_subtype = 'STRUCTURE_TO_TASK';

BEGIN

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE_PVT.delete_lifecycle_phases:inside delete_lifecycle_phase..');
	END IF;


	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT LCYL_DEL_PHASE_PVT;
	END IF;

	IF NOT FND_API.COMPATIBLE_API_CALL(
				l_api_version	,
				p_api_version	,
				l_api_name	,
                                g_pkg_name
				)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;


	if(p_debug_mode = 'Y') then
	  pa_debug.debug('PA_LIFECYCLES_PVT.delete_lifecycle_phase:Locking record for pa_proj_elements...');
	end if;

    --Lock record
    IF (p_validate_only <> FND_API.G_TRUE) THEN
      BEGIN
        --lock
         SELECT rowid into l_rowid
         FROM   pa_proj_elements
         WHERE  proj_element_id = p_phase_id
  	 AND   project_id  = c_project_id
	 AND   object_type = c_object_type
         AND  record_version_number = p_record_version_number
         FOR update of record_version_number NOWAIT;

      EXCEPTION

	 when TIMEOUT_ON_RESOURCE then
	     x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';

	 when NO_DATA_FOUND then
	     x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';

	 when OTHERS then
	     x_return_status := FND_API.G_RET_STS_ERROR;
	   IF SQLCODE = -54 THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
              l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            ELSE
              raise;
            END IF;
      END;
    ELSE
    -- IF p_validate_only EQUALS TRUE
      BEGIN
          SELECT rowid into l_rowid
          FROM   pa_proj_elements
          WHERE proj_element_id = p_phase_id
  	  AND   project_id  = c_project_id
	  AND   object_type = c_object_type
          AND record_version_number = p_record_version_number;
      EXCEPTION
         when NO_DATA_FOUND then
	     x_return_status := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';
         when OTHERS then
            raise;
      END;
    END IF;
   IF (p_debug_mode = 'Y') THEN
	pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle_phases: checking message count');
   END IF;

     l_msg_count := FND_MSG_PUB.count_msg;

       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages(
		  p_encoded        => FND_API.G_TRUE	,
	          p_msg_index      => 1			,
	          p_msg_count      => l_msg_count	,
	          p_msg_data       => l_msg_data	,
	          p_data           => l_data		,
	          p_msg_index_out  => l_msg_index_out
		  );
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle_phases:Calling PA_PROJ_ELEMENTS_PKG.delete_Row');
   END IF;


      PA_PROJ_ELEMENTS_PKG.delete_Row(l_rowid);

   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle_phases:Calling PA_PROJ_ELEMENT_VERSIONS_PKG.delete_Row');
   END IF;

      OPEN l_row_proj_element_versions;
      FETCH l_row_proj_element_versions into l_rowid,l_element_version_id, l_par_element_version_id;
      CLOSE l_row_proj_element_versions;


      PA_PROJ_ELEMENT_VERSIONS_PKG.delete_Row(l_rowid);



   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle_phases:Calling PA_PROJ_ELEMENT_SCH_PKG.delete_Row');
   END IF;

      OPEN l_row_proj_elem_ver_schedule;
      FETCH l_row_proj_elem_ver_schedule into l_rowid;
      CLOSE l_row_proj_elem_ver_schedule;

      PA_PROJ_ELEMENT_SCH_PKG.delete_Row(l_rowid);


   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('DELETE_LIFECYCLE_PVT.delete_lifecycle_phases:Calling PA_OBJECT_RELATIONSHIPS_PKG.delete_Row');
   END IF;

      OPEN l_row_object_relationship;
      FETCH l_row_object_relationship INTO  l_obj_rel_id, l_record_version_number;
      CLOSE l_row_object_relationship;

      PA_OBJECT_RELATIONSHIPS_PKG.DELETE_ROW(
		p_object_relationship_id	=>  l_obj_rel_id		,
	        p_object_type_from		=>  NULL			,
	        p_object_id_from1		=>  NULL			,
	        p_object_id_from2		=>  NULL			,
		p_object_id_from3		=>  NULL			,
	        p_object_id_from4		=>  NULL			,
		p_object_id_from5		=>  NULL			,
	        p_object_type_to		=>  NULL			,
	        p_object_id_to1			=>  NULL			,
	        p_object_id_to2			=>  NULL			,
	        p_object_id_to3			=>  NULL			,
	        p_object_id_to4			=>  NULL			,
	        p_object_id_to5			=>  NULL			,
	        p_record_version_number		=>  l_record_version_number	,
	        p_pm_product_code		=>  NULL			,
		x_return_status			=>  l_return_status
		);

   IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('CREATE_LIFECYCLE_PVT.delete_lifecycle_phases: checking message count');
   END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages(
			p_encoded        => FND_API.G_TRUE	,
			p_msg_index      => 1			,
			p_msg_count      => l_msg_count		,
			p_msg_data       => l_msg_data		,
			p_data           => l_data		,
			p_msg_index_out  => l_msg_index_out
			);
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;




EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DEL_PHASE_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'delete_lifecycle_phase',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DEL_PHASE_PVT;
    END IF;


WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DEL_PHASE_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'delete_lifecycle_phase',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END delete_lifecycle_phase;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE check_delete_lifecycle_ok(
	 P_api_version			IN	NUMBER   :=1.0				,
	 P_calling_module		IN	VARCHAR2 :='SELF_SERVICE'		,
	 P_debug_mode			IN	VARCHAR2 :='N'				,
	 P_max_msg_count		IN	NUMBER   :=G_MISS_NUM			,
	 P_lifecycle_id			IN	NUMBER					,
	 P_lifecycle_version_id         IN      NUMBER                                  ,
	 X_return_status		OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	 X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	 X_msg_data			OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	 x_del_lifecycle_ok             OUT     NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	)

IS

	l_api_name           CONSTANT VARCHAR(30) := 'check_delete_lifecycle_ok';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data                    VARCHAR2(2000);
	l_return_status               VARCHAR2(1);


	l_is_project		      VARCHAR2(1);
	l_is_product		      VARCHAR2(1);
	l_row_id		      VARCHAR2(30);
	l_del_lifecycle_ok            VARCHAR2(1);


	c_object_type CONSTANT VARCHAR(30) := 'PA_TASKS';
	c_project_id CONSTANT NUMBER := 0;
	c_usage_project CONSTANT VARCHAR(30) := 'PROJECTS';
	c_usage_product CONSTANT VARCHAR(30) := 'PRODUCTS';

	CURSOR l_check_project_csr
	IS
	Select 'Y'
	From dual
	Where exists(Select 'XYZ'
		From pa_lifecycle_usages
		Where lifecycle_id = P_lifecycle_id
		and usage_type = c_usage_project);

	CURSOR l_check_product_csr
	IS
	Select 'Y'
	From dual
	Where exists(Select 'XYZ'
		From pa_lifecycle_usages
		Where lifecycle_id = P_lifecycle_id
		and usage_type = c_usage_product);

	CURSOR l_project_workplan_csr
	IS
	Select 'Y'
	From dual
	Where exists(Select 'XYZ'
		From pa_proj_workplan_attr
		Where lifecycle_version_id = P_lifecycle_version_id);
Begin
	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE_PVT.check_delete_lifecycle_ok: Inside check_delete_lifecycle_ok...');
	END IF;


        IF NOT FND_API.COMPATIBLE_API_CALL(
				l_api_version	,
				p_api_version	,
				l_api_name	,
                                g_pkg_name
				)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE_PVT.check_delete_lifecycle_ok: Checking for valid parameters..');
	END IF;

	l_is_project :='N';
	OPEN l_check_project_csr;
        FETCH l_check_project_csr INTO l_is_project;
        CLOSE l_check_project_csr;

        IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('CREATE_LIFECYCLE_PVT.check_delete_lifecycle_ok: Checking for assigned to workplan..');
	END IF;

	IF(l_is_project= 'Y') THEN
		l_is_project :='N';
		OPEN l_project_workplan_csr;
		FETCH l_project_workplan_csr INTO l_is_project;
		CLOSE l_project_workplan_csr;
		IF(l_is_project ='Y') THEN
			PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_WORKPLAN_STRUCT_USED');
				x_msg_data := 'PA_LCYL_WORKPLAN_STRUCT_USED';
			x_return_status := 'E';
		END IF;
	END IF;

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('CREATE_LIFECYCLE_PVT.check_delete_lifecycle_ok: checking message count');
        END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages(
	          p_encoded        => FND_API.G_TRUE	,
	          p_msg_index      => 1			,
	          p_msg_count      => l_msg_count	,
	          p_msg_data       => l_msg_data	,
	          p_data           => l_data		,
	          p_msg_index_out  => l_msg_index_out
		  );
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

	x_del_lifecycle_ok:=FND_API.G_TRUE;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'delete_lifecycle_phase_ok',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));


WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'delete_lifecycle_phase_ok',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END check_delete_lifecycle_ok;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE update_lifecycle (
	 p_api_version			IN	NUMBER   :=1.0					,
	 p_commit			IN	VARCHAR2 :=FND_API.G_FALSE			,
	 p_validate_only		IN	VARCHAR2 :=FND_API.G_TRUE			,
	 p_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL		,
	 p_calling_module		IN	VARCHAR2 :='SELF_SERVICE'			,
	 p_debug_mode			IN	VARCHAR2 :='N'					,
	 p_max_msg_count		IN	NUMBER   :=G_MISS_NUM				,
	 P_lifecycle_id			IN	NUMBER						,
	 P_lifecycle_short_name		IN	VARCHAR2					,
	 P_lifecycle_name		IN	VARCHAR2					,
	 P_lifecycle_description	IN	VARCHAR2					,
	 P_lifecycle_project_usage_type	IN	VARCHAR2					,
	 P_lifecycle_product_usage_type	IN	VARCHAR2					,
	 P_record_version_number	IN	NUMBER						,
	 x_return_status		OUT	NOCOPY VARCHAR2					, --File.Sql.39 bug 4440895
	 x_msg_count			OUT	NOCOPY NUMBER						, --File.Sql.39 bug 4440895
	 X_msg_data			OUT	NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
	)

	IS

	l_api_name		CONSTANT	VARCHAR2(30) := 'update_lifecycle';
	l_api_version		CONSTANT	NUMBER      := 1.0;
	l_rowid					VARCHAR2(30);
	l_msg_count				NUMBER;
	l_msg_index_out				NUMBER;
	l_data					VARCHAR2(2000);
	l_msg_data				VARCHAR2(2000);
	l_return_status				VARCHAR2(1);


	l_prj_lcyl_usage_id			NUMBER;
	l_prd_lcyl_usage_id			NUMBER;
	l_lifecycle_id				NUMBER;

	l_proj_usg_exists			VARCHAR2(1):='N';
	l_prod_usg_exists			VARCHAR2(1):='N';
	l_workplan_used 			VARCHAR2(1):='N';
	l_item_used	 			VARCHAR2(1):='N';
	c_object_type		CONSTANT	VARCHAR2(30) := 'PA_STRUCTURES';
	c_project_type		CONSTANT	VARCHAR2(30) :='PROJECTS';
	c_product_type		CONSTANT	VARCHAR2(30) :='PRODUCTS';
	c_project_id		CONSTANT	NUMBER :=0;
	l_record_version_number			NUMBER;
	l_element_version_id			NUMBER;

	l_pev_id				NUMBER;
	l_elem_vers_id				NUMBER;
	l_errorcode				NUMBER;


       CURSOR l_row_proj_element_versions
	IS
	SELECT element_version_id
	FROM   pa_proj_element_versions
	WHERE  proj_element_id = P_lifecycle_id
	AND    project_id = c_project_id
	AND    object_type = c_object_type;

	CURSOR get_project_usage
	IS
	SELECT lifecycle_usage_id
	from pa_lifecycle_usages
	where lifecycle_id = P_lifecycle_id
	AND usage_type=c_project_type;

	CURSOR get_product_usage
	IS
	SELECT lifecycle_usage_id
	from pa_lifecycle_usages
	where lifecycle_id = P_lifecycle_id
	AND usage_type=c_product_type;

	CURSOR l_row_proj_elem_ver_structure
	IS
	Select rowid,PEV_STRUCTURE_ID,element_version_id,record_version_number
	From pa_proj_elem_ver_structure
	WHERE  element_version_id = l_element_version_id
	AND    proj_element_id = P_lifecycle_id
	AND    project_id = c_project_id;


BEGIN

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PVT.Update_Lifecycle: Inside update_lifecycle...');
	END IF;

	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT LCYL_UPDATE_LIFECYCLE_PVT;
	END IF;

        IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLES_PVT.Update_Lifecycle: Checking api compatibility...');
	END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;


	OPEN l_row_proj_element_versions;
        FETCH l_row_proj_element_versions into l_element_version_id;
        CLOSE l_row_proj_element_versions;

	OPEN get_project_usage;
	FETCH get_project_usage into l_prj_lcyl_usage_id;
	CLOSE get_project_usage;

	IF l_prj_lcyl_usage_id is null THEN
		l_proj_usg_exists := 'N';
        ELSE
		l_proj_usg_exists := 'Y';
	END IF;

	OPEN get_product_usage;
	FETCH get_product_usage into l_prd_lcyl_usage_id;
	CLOSE get_product_usage;

	IF l_prd_lcyl_usage_id is null THEN
		l_prod_usg_exists := 'N';
        ELSE
		l_prod_usg_exists := 'Y';
	END IF;

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLES_PVT.Update_Lifecycle: Checking for used by workplan structure or not..');
	END IF;

	IF l_proj_usg_exists = 'Y' THEN
		BEGIN
		  SELECT 'Y'
		  into l_workplan_used
		  from SYS.DUAL
		  where exists(select 'XYZ' from pa_proj_workplan_attr
				where lifecycle_version_id = l_element_version_id);
	 	  exception
		  when NO_DATA_FOUND then
			  l_workplan_used := 'N';
		END;

      -- No need to check for l_proj_usg_exists as if lifecycle is used in workplan structure. I means it has project usages.
      -- Can's make the usage to N if it is used in workplan structure

		IF( l_workplan_used = 'Y' AND P_lifecycle_project_usage_type = 'N') then
		   PA_UTILS.ADD_MESSAGE(
					p_app_short_name => 'PA',
		                        p_msg_name       => 'PA_LCYL_PRJ_USG_CHG_NOT_ALWD');
		   x_msg_data := 'PA_LCYL_PRJ_USG_CHG_NOT_ALWD';
   		   x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	END IF;

      -- Similar check for item category also has to be made as done above for workplan

	IF (l_prod_usg_exists = 'Y' AND P_lifecycle_product_usage_type = 'N') THEN
		BEGIN
		 PA_EGO_WRAPPER_PUB.check_delete_lifecycle_ok(
			p_api_version			=> P_api_version	,
			p_lifecycle_id 			=> p_lifecycle_id	,
			x_delete_ok			=> l_item_used		,
			x_return_status			=> l_return_status	,
			x_errorcode			=> l_errorcode		,
			x_msg_count			=> l_msg_count		,
			x_msg_data			=> l_msg_data
			);
		END;
	END IF;

       IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PVT.Update_Lifecycle: checking message count');
       END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages
	         (p_encoded        => FND_API.G_TRUE ,
	          p_msg_index      => 1,
	          p_msg_count      => l_msg_count ,
	          p_msg_data       => l_msg_data,
	          p_data           => l_data,
	          p_msg_index_out  => l_msg_index_out );
	     x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

    IF (p_debug_mode = 'Y') THEN
	 pa_debug.debug('PA_LIFECYCLES_PVT.Update_Lifecycle: After  checking message count and applying locking ');
     END IF;

    IF (p_validate_only <> FND_API.G_TRUE) THEN
      BEGIN
        --lock
	 select rowid into l_rowid
         from   pa_proj_elements
         where  proj_element_id = p_lifecycle_id
         AND    record_version_number = p_record_version_number
	 AND    project_id = c_project_id
         AND    object_type = c_object_type
         for update of record_version_number NOWAIT;

      EXCEPTION

	 when TIMEOUT_ON_RESOURCE then
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';

	 when NO_DATA_FOUND then
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';

	 when OTHERS then
            x_return_status := FND_API.G_RET_STS_ERROR;
	   IF SQLCODE = -54 then

              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
              l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            ELSE
              raise;
            END IF;
      END;
    ELSE
      BEGIN
	   SELECT rowid into l_rowid
           FROM   pa_proj_elements
           WHERE  proj_element_id = P_lifecycle_id
 	   AND    project_id = c_project_id
           AND    object_type = c_object_type
           AND    record_version_number = p_record_version_number;

	   EXCEPTION

	   when NO_DATA_FOUND then
 	     x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';

	   when OTHERS then
            raise;
      END;
    END IF;

     l_msg_count := FND_MSG_PUB.count_msg;

       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages
	         (p_encoded        => FND_API.G_TRUE ,
	          p_msg_index      => 1,
	          p_msg_count      => l_msg_count ,
	          p_msg_data       => l_msg_data,
	          p_data           => l_data,
	          p_msg_index_out  => l_msg_index_out );
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PVT.Update_Lifecycle:Inserting into pa_proj_elements...');
	END IF;



	PA_PROJ_ELEMENTS_PKG.UPDATE_ROW(
		X_ROW_ID			=> l_rowid				,
		X_PROJ_ELEMENT_ID		=> P_lifecycle_id			,
		X_PROJECT_ID			=>c_project_id				,
		X_OBJECT_TYPE			=>c_object_type				,
		X_ELEMENT_NUMBER    		=>P_lifecycle_short_name		,
		X_NAME              		=>P_lifecycle_name			,
		X_DESCRIPTION	    		=>P_lifecycle_description		,
		X_STATUS_CODE	    		=>NULL					,
		X_WF_STATUS_CODE    		=>NULL					,
		X_PM_PRODUCT_CODE   		=>NULL					,
		X_PM_TASK_REFERENCE		=>NULL					,
		X_CLOSED_DATE			=>NULL					,
		X_LOCATION_ID			=>NULL					,
		X_MANAGER_PERSON_ID		=> NULL					,
		X_CARRYING_OUT_ORGANIZATION_ID	=> NULL					,
		X_TYPE_ID                 	=> NULL					,
		X_PRIORITY_CODE           	=> NULL					,
		X_INC_PROJ_PROGRESS_FLAG  	=> NULL					,
		X_RECORD_VERSION_NUMBER   	=> P_record_version_number		,
		X_REQUEST_ID              	=> NULL					,
		X_PROGRAM_APPLICATION_ID  	=> NULL					,
		X_PROGRAM_ID              	=> NULL					,
		X_PROGRAM_UPDATE_DATE     	=> NULL					,
		X_ATTRIBUTE_CATEGORY      	=> NULL					,
		X_ATTRIBUTE1              	=> NULL					,
		X_ATTRIBUTE2              	=> NULL					,
		X_ATTRIBUTE3              	=> NULL					,
		X_ATTRIBUTE4              	=> NULL					,
		X_ATTRIBUTE5              	=> NULL					,
		X_ATTRIBUTE6              	=> NULL					,
		X_ATTRIBUTE7              	=> NULL					,
		X_ATTRIBUTE8              	=> NULL					,
		X_ATTRIBUTE9              	=> NULL					,
		X_ATTRIBUTE10             	=> NULL					,
		X_ATTRIBUTE11             	=> NULL					,
		X_ATTRIBUTE12             	=> NULL					,
		X_ATTRIBUTE13             	=> NULL					,
		X_ATTRIBUTE14             	=> NULL					,
		X_ATTRIBUTE15			=> NULL					,
		X_TASK_WEIGHTING_DERIV_CODE	=> NULL					,
		X_WORK_ITEM_CODE		=> NULL					,
		X_UOM_CODE			=> NULL					,
		X_WQ_ACTUAL_ENTRY_CODE		=> NULL					,
		X_TASK_PROGRESS_ENTRY_PAGE_ID	=> NULL					,
		X_parent_structure_id		=> NULL					,
		X_phase_code			=> NULL					,
		X_phase_version_id		=> NULL
		);


	OPEN l_row_proj_elem_ver_structure;
	FETCH l_row_proj_elem_ver_structure into l_rowid,l_pev_id,l_elem_vers_id,l_record_version_number;
	CLOSE l_row_proj_elem_ver_structure;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PVT.Update_Lifecycle:Inserting into PA_PROJ_ELEM_VER_STRUCTURE...');
	END IF;

	PA_PROJ_ELEM_VER_STRUCTURE_PKG.UPDATE_ROW (
		X_ROWID				=>l_rowid				,
		X_PEV_STRUCTURE_ID       	=>l_pev_id				,
		X_ELEMENT_VERSION_ID     	=>l_elem_vers_id         		,
		X_VERSION_NUMBER         	=> 1                    		,
		X_NAME                       	=>  P_lifecycle_name			,
		X_PROJECT_ID             	=> c_project_id				,
		X_PROJ_ELEMENT_ID         	=> P_lifecycle_id			,
		X_DESCRIPTION            	=>  P_lifecycle_description		,
		X_EFFECTIVE_DATE         	=> NULL 				,
		X_PUBLISHED_DATE         	=> NULL           			,
		X_PUBLISHED_BY           	=> NULL           		        ,
		X_CURRENT_BASELINE_DATE  	=> NULL    				,
		X_CURRENT_BASELINE_FLAG  	=> 'Y'          			,
		X_CURRENT_BASELINE_BY    	=> NULL          			,
		X_ORIGINAL_BASELINE_DATE 	=> NULL					,
		X_ORIGINAL_BASELINE_FLAG 	=> 'Y'          			,
		X_ORIGINAL_BASELINE_BY   	=> NULL                 		,
		X_LOCK_STATUS_CODE       	=> NULL                 		,
		X_LOCKED_BY              	=> NULL                 		,
		X_LOCKED_DATE            	=> NULL                 		,
		X_STATUS_CODE            	=> NULL                 		,
		X_WF_STATUS_CODE         	=> NULL                 		,
		X_LATEST_EFF_PUBLISHED_FLAG	=> 'Y'               			,
		X_CHANGE_REASON_CODE		=> NULL               			,
		X_RECORD_VERSION_NUMBER		=> l_record_version_number
                );




	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PVT.Update_Lifecycle:Inserting into PA_LIFECYCLE_USAGES...');
	END IF;

	IF (l_proj_usg_exists = 'N' AND P_lifecycle_project_usage_type = 'Y') THEN
	       SELECT PA_LIFECYCLE_USAGES_S.NEXTVAL
		INTO   l_prj_lcyl_usage_id
		FROM   dual;

		PA_LIFECYCLE_USAGES_PKG.insert_row(
			X_lifecycle_usage_id       => l_prj_lcyl_usage_id	      ,
			X_RECORD_VERSION_NUMBER    => 1				      ,
			X_lifecycle_ID 		   => P_lifecycle_id		      ,
			X_USAGE_TYPE		   => c_project_type
			);

	ELSIF (l_proj_usg_exists = 'Y' AND P_lifecycle_project_usage_type = 'N') THEN
		PA_LIFECYCLE_USAGES_PKG.delete_Row(l_prj_lcyl_usage_id);

	END IF;

	IF (l_prod_usg_exists = 'N' AND P_lifecycle_product_usage_type = 'Y') THEN
	        SELECT PA_LIFECYCLE_USAGES_S.NEXTVAL
		INTO   l_prd_lcyl_usage_id
		FROM   dual;

		PA_LIFECYCLE_USAGES_PKG.insert_row(
			X_lifecycle_usage_id       => l_prd_lcyl_usage_id	,
			X_RECORD_VERSION_NUMBER    => 1				,
			X_lifecycle_ID 	           => P_lifecycle_id		,
			X_USAGE_TYPE		   => c_product_type
			);
	ELSIF (l_prod_usg_exists = 'Y' AND P_lifecycle_product_usage_type = 'N')  THEN
		PA_LIFECYCLE_USAGES_PKG.delete_Row(l_prd_lcyl_usage_id);
	END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_UPDATE_LIFECYCLE_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'UPDATE_LIFECYCLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_UPDATE_LIFECYCLE_PVT;
    END IF;


WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_UPDATE_LIFECYCLE_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'UPDATE_LIFECYCLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END update_lifecycle;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE update_lifecycle_phase (
	P_api_version			IN	NUMBER   :=1.0					,
	p_commit			IN	VARCHAR2 :=FND_API.G_FALSE			,
	p_validate_only		        IN	VARCHAR2 :=FND_API.G_TRUE			,
	p_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL		,
	p_calling_module		IN	VARCHAR2 :='SELF_SERVICE'			,
	p_debug_mode			IN	VARCHAR2 :='N'					,
	P_max_msg_count		        IN	NUMBER   :=G_MISS_NUM				,
	P_lifecycle_id			IN	NUMBER						,
	P_lifecycle_phase_id		IN	NUMBER						,
	P_phase_display_sequence	IN	NUMBER						,
	P_phase_code			IN	VARCHAR2					,
	P_phase_short_name		IN	VARCHAR2 					,
	P_phase_name			IN	VARCHAR2 					,
	P_phase_description		IN	VARCHAR2 					,
	P_record_version_number	        IN	NUMBER						,
	x_return_status		        OUT	NOCOPY VARCHAR2					, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER						, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	)IS

	l_api_name           CONSTANT		VARCHAR2(30) := 'update_lifecycle_phase';
	l_api_version        CONSTANT		NUMBER      := 1.0;
	l_msg_count				NUMBER;
	l_msg_index_out				NUMBER;
	l_data					VARCHAR2(2000);
	l_msg_data				VARCHAR2(2000);
	l_return_status				VARCHAR2(1);

	l_project_usage_exists			VARCHAR2(1):='N';
	l_product_usage_exists			VARCHAR2(1):='N';
	c_project_type CONSTANT			VARCHAR2(30) :='PROJECTS';
	c_product_type CONSTANT			VARCHAR2(30) :='PRODUCTS';
	c_object_type CONSTANT			VARCHAR(30) := 'PA_TASKS';
	c_project_id  CONSTANT			NUMBER :=0;
	l_lcyl_assigned				VARCHAR2(1):='N';
	l_phas_assigned				VARCHAR2(1):='N';
	l_lcyl_in_use				VARCHAR2(1):='N';


	l_is_uniq				VARCHAR2(1):='N';
	l_rowid					VARCHAR2(30);
	l_pev_id				NUMBER;
	l_elem_vers_id				NUMBER;
	l_parent_elem_vers_id			NUMBER;
	l_update_ok				VARCHAR2(1);
	l_record_version_number                 NUMBER;

	CURSOR l_row_proj_elem_ver_structure
	IS
	Select rowid,PEV_STRUCTURE_ID,element_version_id
	From pa_proj_elem_ver_structure
	Where proj_element_id = P_lifecycle_id
	AND   project_id = c_project_id;

	CURSOR l_row_proj_elem_vers
	IS
	Select rowid,element_version_id,parent_structure_version_id,record_version_number
	From pa_proj_element_versions
	Where proj_element_id = P_lifecycle_phase_id
	AND   project_id = c_project_id
	AND   object_type = c_object_type;


BEGIN

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PVT.update_lifecycle_phase: Inside update_lifecycle_phase...');
	END IF;

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLES_PVT.update_lifecycle_phase: Checking api compatibility...');
	END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT LCYL_UPD_LCYL_PHASE_PVT;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	/*** NOte that we shd not check existing phase code, short name and sequence here, bcos user may want to
	    swap two phases. This is JAva layer responsibility to take care ***/

	--Lock record

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLES_PVT.update_lifecycle_phase: Locking record ..');
	END IF;

	IF (p_validate_only <> FND_API.G_TRUE) THEN
		BEGIN
        --lock
			select rowid into l_rowid
			from pa_proj_elements
         		where proj_element_id = p_lifecycle_phase_id
         		AND record_version_number = p_record_version_number
	 		AND   project_id = c_project_id
         		AND   object_type = c_object_type
         		for update of record_version_number NOWAIT;

		EXCEPTION

			when TIMEOUT_ON_RESOURCE then
         		   x_return_status := FND_API.G_RET_STS_ERROR;
         		   PA_UTILS.ADD_MESSAGE(
						p_app_short_name => 'PA',
         		                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
         		   l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';

	 		when NO_DATA_FOUND then
         		   x_return_status := FND_API.G_RET_STS_ERROR;
         		   PA_UTILS.ADD_MESSAGE(
						p_app_short_name => 'PA',
         		                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
         		   l_msg_data := 'PA_XC_RECORD_CHANGED';

	 		when OTHERS then
         		   x_return_status := FND_API.G_RET_STS_ERROR;
	 		   IF SQLCODE = -54 then

         		     PA_UTILS.ADD_MESSAGE(
						p_app_short_name => 'PA',
         		                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
         		     l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         		   ELSE
         		     raise;
         		   END IF;
		END;
	ELSE
		BEGIN
			SELECT rowid into l_rowid
           		FROM   pa_proj_elements
           		WHERE  proj_element_id = p_lifecycle_phase_id
 	   		AND    project_id = c_project_id
           		AND    object_type = c_object_type
           		AND    record_version_number = p_record_version_number;

		EXCEPTION

			when NO_DATA_FOUND then
 				x_return_status := FND_API.G_RET_STS_ERROR;
				PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
						     p_msg_name       => 'PA_XC_RECORD_CHANGED');
				l_msg_data := 'PA_XC_RECORD_CHANGED';
			when OTHERS then
				raise;
		 END;
	END IF;

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLES_PVT.update_lifecycle_phase: Checking message count...');
	END IF;

	l_msg_count := FND_MSG_PUB.count_msg;

	If l_msg_count > 0 THEN
	  x_msg_count := l_msg_count;
	   If l_msg_count = 1 THEN
	      pa_interface_utils_pub.get_messages
	         (p_encoded        => FND_API.G_TRUE ,
	          p_msg_index      => 1,
	          p_msg_count      => l_msg_count ,
	          p_msg_data       => l_msg_data,
	          p_data           => l_data,
	          p_msg_index_out  => l_msg_index_out );
	    x_msg_data := l_data;
	 End if;
	  RAISE  FND_API.G_EXC_ERROR;
	End if;

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLES_PVT.update_lifecycle_phase: Updating PA_PROJ_ELEMENTS...');
	END IF;

	PA_PROJ_ELEMENTS_PKG.UPDATE_ROW(
		X_ROW_ID			=> l_rowid				,
		X_PROJ_ELEMENT_ID		=> P_lifecycle_phase_id			,
		X_PROJECT_ID			=>c_project_id				,
		X_OBJECT_TYPE			=>c_object_type				,
		X_ELEMENT_NUMBER		=>P_phase_short_name			,
		X_NAME				=>P_phase_name				,
		X_DESCRIPTION			=>P_phase_description			,
                X_STATUS_CODE			=> NULL					,
                X_WF_STATUS_CODE          	=> NULL       				,
                X_PM_PRODUCT_CODE         	=> NULL       				,
                X_PM_TASK_REFERENCE       	=> NULL       				,
                X_CLOSED_DATE             	=> NULL       				,
                X_LOCATION_ID             	=> NULL       				,
                X_MANAGER_PERSON_ID       	=> NULL       				,
                X_CARRYING_OUT_ORGANIZATION_ID  => NULL					,
                X_TYPE_ID			=> NULL                      		,
                X_PRIORITY_CODE           	=> NULL                      		,
                X_INC_PROJ_PROGRESS_FLAG  	=> NULL                      		,
		X_RECORD_VERSION_NUMBER   	=> P_record_version_number		,
                X_REQUEST_ID              	=> NULL					,
                X_PROGRAM_APPLICATION_ID  	=> NULL                        		,
                X_PROGRAM_ID              	=> NULL                        		,
                X_PROGRAM_UPDATE_DATE     	=> NULL                        		,
                X_ATTRIBUTE_CATEGORY      	=> NULL                        		,
                X_ATTRIBUTE1              	=> NULL                        		,
                X_ATTRIBUTE2              	=> NULL                        		,
                X_ATTRIBUTE3              	=> NULL                        		,
                X_ATTRIBUTE4              	=> NULL                        		,
                X_ATTRIBUTE5              	=> NULL                        		,
                X_ATTRIBUTE6              	=> NULL                        		,
                X_ATTRIBUTE7              	=> NULL                        		,
                X_ATTRIBUTE8              	=> NULL                        		,
                X_ATTRIBUTE9              	=> NULL                        		,
                X_ATTRIBUTE10             	=> NULL                        		,
                X_ATTRIBUTE11             	=> NULL                        		,
                X_ATTRIBUTE12             	=> NULL                        		,
                X_ATTRIBUTE13             	=> NULL                        		,
                X_ATTRIBUTE14             	=> NULL                        		,
                X_ATTRIBUTE15             	=> NULL                        		,
                X_TASK_WEIGHTING_DERIV_CODE     => NULL					,
                X_WORK_ITEM_CODE		=> NULL					,
                X_UOM_CODE			=> NULL					,
                X_WQ_ACTUAL_ENTRY_CODE		=> NULL					,
                X_TASK_PROGRESS_ENTRY_PAGE_ID   => NULL					,
                x_parent_structure_id		=> P_lifecycle_id                       ,
                x_phase_code			=> p_phase_code				,
                x_phase_version_id		=> NULL
		);

	if(P_phase_display_sequence is NOT NULL) then
	      OPEN l_row_proj_elem_vers;
	      FETCH l_row_proj_elem_vers into l_rowid, l_elem_vers_id,l_parent_elem_vers_id,l_record_version_number ;
  	      CLOSE l_row_proj_elem_vers;

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLES_PVT.update_lifecycle_phase: Updating PA_PROJ_ELEMENT_VERSIONS...');
	END IF;

	PA_PROJ_ELEMENT_VERSIONS_PKG.Update_Row(
		X_ROW_ID			=>   l_rowid				,
		X_ELEMENT_VERSION_ID		=>l_elem_vers_id			,
		X_PROJ_ELEMENT_ID		=>P_lifecycle_phase_id			,
		X_OBJECT_TYPE			=> c_object_type			,
		X_PROJECT_ID			=> c_project_id				,
		X_PARENT_STRUCTURE_VERSION_ID	=>l_parent_elem_vers_id			,
		X_DISPLAY_SEQUENCE		=>p_phase_display_sequence		,
		X_WBS_LEVEL			=> NULL					,
		X_WBS_NUMBER			=> NULL					,
		X_RECORD_VERSION_NUMBER		=> l_record_version_number		,
		X_ATTRIBUTE_CATEGORY		=> NULL					,
		X_ATTRIBUTE1			=> NULL	  				,
		X_ATTRIBUTE2			=> NULL	  				,
		X_ATTRIBUTE3			=> NULL	  				,
		X_ATTRIBUTE4			=> NULL	  				,
		X_ATTRIBUTE5			=> NULL	  				,
		X_ATTRIBUTE6			=> NULL	  				,
		X_ATTRIBUTE7			=> NULL	  				,
		X_ATTRIBUTE8			=> NULL	  				,
		X_ATTRIBUTE9			=> NULL					,
		X_ATTRIBUTE10			=> NULL	  				,
		X_ATTRIBUTE11			=> NULL	  				,
		X_ATTRIBUTE12			=> NULL	  				,
		X_ATTRIBUTE13			=> NULL	  				,
		X_ATTRIBUTE14			=> NULL	  				,
		X_ATTRIBUTE15			=> NULL					,
		X_TASK_UNPUB_VER_STATUS_CODE    => 'Working'
		);
      end if;


   IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLES_PVT.update_lifecycle_phase: Checking message count after Updating tables.');
   END IF;

   l_msg_count := FND_MSG_PUB.count_msg;

   If l_msg_count > 0 THEN
	  x_msg_count := l_msg_count;
	     If l_msg_count = 1 THEN
	         pa_interface_utils_pub.get_messages(
			p_encoded        => FND_API.G_TRUE		,
			p_msg_index      => 1				,
			p_msg_count      => l_msg_count			,
	          	p_msg_data       => l_msg_data			,
	          	p_data           => l_data			,
	          	p_msg_index_out  => l_msg_index_out
			);
		x_msg_data := l_data;
	     End if;
	  RAISE  FND_API.G_EXC_ERROR;
   End if;

x_return_status      := FND_API.G_RET_STS_SUCCESS;

IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
     COMMIT;
END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_UPD_LCYL_PHASE_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT'		,
                            p_procedure_name => 'update_lifecycle_phase'	,
                            p_error_text     => SUBSTRB(SQLERRM,1,240)
			    );
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_UPD_LCYL_PHASE_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_UPD_LCYL_PHASE_PVT;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT'		,
                            p_procedure_name => 'update_lifecycle_phase'	,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;

END update_lifecycle_phase;


	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE check_delete_lcyl_phase_ok(
 	 P_api_version			IN	NUMBER	 := 1.0       		,
	 p_calling_module		IN	VARCHAR2 := 'SELF_SERVICE'	,
	 p_debug_mode			IN	VARCHAR2 := 'N'           	,
	 P_max_msg_count		IN	NUMBER	 := G_MISS_NUM		,
	P_lifecycle_id			IN	NUMBER				,
	P_lifecycle_phase_id		IN	NUMBER				,
	x_delete_ok			OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_return_status		        OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	)
	IS

	l_api_name           CONSTANT		VARCHAR2(30) := 'check_delete_lcyl_phase_ok';
	l_api_version        CONSTANT		 NUMBER      := 1.0;
	l_msg_count				NUMBER;
	l_msg_index_out				NUMBER;
	l_data VARCHAR2(2000);
	l_msg_data VARCHAR2(2000);
	l_return_status VARCHAR2(1);

	l_project_usage_exists			VARCHAR2(1):='N';
	l_product_usage_exists			VARCHAR2(1):='N';
	c_project_type CONSTANT			VARCHAR2(30) :='PROJECTS';
	c_product_type CONSTANT			VARCHAR2(30) :='PRODUCTS';
	c_object_type CONSTANT			VARCHAR2(30) := 'PA_TASKS';
	c_project_id   CONSTANT NUMBER :=0;
        l_delete_ok VARCHAR2(1) := FND_API.G_TRUE;
	l_parent_elem_ver_id number;
	l_child_elem_ver_id number;
BEGIN

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLE PVT.check_delete_lcyl_phase_ok: Checking api compatibility...');
	END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	begin
	select 'Y'
	into l_project_usage_exists
	from SYS.DUAL
	where exists( select 'XYZ' from pa_lifecycle_usages
			where lifecycle_id=P_lifecycle_id  AND
				usage_type=c_project_type);
	exception
	  when NO_DATA_FOUND then
	  l_project_usage_exists := 'N';
	END;


	begin
	select 'Y'
	into l_product_usage_exists
	from SYS.DUAL
	where exists( select 'XYZ' from pa_lifecycle_usages
			where lifecycle_id=P_lifecycle_id  AND
				usage_type=c_product_type);
	exception
	  when NO_DATA_FOUND then
	  l_product_usage_exists := 'N';
	END;

	begin
	select element_version_id
	into l_parent_elem_ver_id
	from pa_proj_element_versions
	where proj_element_id = P_lifecycle_id
	and object_type = 'PA_STRUCTURES'
	and project_id = c_project_id;
	exception
	  when NO_DATA_FOUND then
	   raise;
	END;

	begin
	select element_version_id
	into l_child_elem_ver_id
	from pa_proj_element_versions
	where proj_element_id = P_lifecycle_phase_id
	and object_type = 'PA_TASKS'
	and project_id = c_project_id;
	exception
	  when NO_DATA_FOUND then
	   raise;
	END;

	/* If the usage type is project and the following 2 conditions are satisfied
	   1) Lifecycle has been assigned to a workplan
	   2) **ANY** phase has been assigned to a top task

	   then we cannot allow update of sequence number and phase code
	*/

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLE PVT.check_delete_lcyl_phase_ok: After checking for usuage type checking for top task assigned');
	END IF;

	IF(l_project_usage_exists = 'Y') then
		begin
			select FND_API.G_FALSE into l_delete_ok
			from sys.dual
			where exists(
				select 'xyz'
				from pa_proj_workplan_attr
				where lifecycle_version_id = l_parent_elem_ver_id
				and current_phase_version_id = l_child_elem_ver_id);

		exception
		  when NO_DATA_FOUND then
		   l_delete_ok := FND_API.G_TRUE;
		 END;

 		IF l_delete_ok <> FND_API.G_TRUE THEN
			PA_UTILS.ADD_MESSAGE(
				 p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_USED_CURR_PHASE');
			l_msg_data := 'PA_LCYL_USED_CURR_PHASE';
  			x_return_status := FND_API.G_RET_STS_ERROR;
			x_delete_ok := l_delete_ok;

		ELSE

		BEGIN
			select FND_API.G_FALSE into l_delete_ok
			from sys.dual
			where exists(
			select 'xyz'
			from pa_proj_element_versions child
	  		,pa_proj_elements tasks
	  		where child.parent_structure_version_id = l_parent_elem_ver_id
	  		and child.project_id = c_project_id
	  		and child.object_type = 'PA_TASKS'
	  		and tasks.phase_version_id = child.element_version_id
	  		and tasks.project_id <> 0
	  		and tasks.object_type = 'PA_TASKS');
		exception
			when no_data_found then
			l_delete_ok := FND_API.G_TRUE;
		end;
			IF l_delete_ok <> FND_API.G_TRUE THEN
				PA_UTILS.ADD_MESSAGE(
					 p_app_short_name => 'PA',
		                         p_msg_name       => 'PA_LCYL_PHASE_TASK_USED');
				l_msg_data := 'PA_LCYL_PHASE_TASK_USED';
  				x_return_status := FND_API.G_RET_STS_ERROR;
				x_delete_ok := l_delete_ok;
			END IF;

		END IF;

	END if;

	/* Similarly it shd be done for PLM item category */

       l_msg_count := FND_MSG_PUB.count_msg;
       IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PVT.check_delete_lcyl_phase_ok: checking message count ');
       END IF;

       IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages(
			p_encoded        => FND_API.G_TRUE	,
			p_msg_index      => 1			,
			p_msg_count      => l_msg_count		,
			p_msg_data       => l_msg_data		,
			p_data           => l_data		,
			p_msg_index_out  => l_msg_index_out
			);
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'check_delete_lcyl_phase_ok',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PVT',
                            p_procedure_name => 'check_delete_lcyl_phase_ok',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;


END check_delete_lcyl_phase_ok;


END PA_LIFECYCLES_PVT;

/
