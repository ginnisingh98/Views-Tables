--------------------------------------------------------
--  DDL for Package Body PA_LIFECYCLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_LIFECYCLES_PUB" AS
 /* $Header: PALCDFPB.pls 120.1 2005/08/19 16:35:24 mwasowic noship $   */

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE create_lifecycle (
	P_api_version			IN	NUMBER	  := 1.0			,
	P_init_msg_list			IN	VARCHAR2  := FND_API.G_TRUE		,
	P_commit			IN	VARCHAR2  := FND_API.G_FALSE		,
	P_validate_only			IN	VARCHAR2  := FND_API.G_TRUE		,
	P_validation_level		IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL ,
	P_calling_module		IN	VARCHAR2  := 'SELF-SERVICE'		,
	P_debug_mode			IN	VARCHAR2  := 'N'			,
	P_max_msg_count			IN	NUMBER    := G_MISS_NUM			,
	P_lifecycle_short_name 		IN	VARCHAR2				,
	P_lifecycle_name		IN	VARCHAR2				,
	P_lifecycle_description		IN	VARCHAR2  := G_MISS_CHAR		,
	P_lifecycle_project_usage_type	IN	VARCHAR2  := 'Y'			,
	P_lifecycle_product_usage_type	IN	VARCHAR2  := G_MISS_CHAR		,
	X_lifecycle_id			OUT	NOCOPY NUMBER 					, --File.Sql.39 bug 4440895
	X_return_status			OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	) IS

	l_api_name		       CONSTANT VARCHAR(30) := 'create_lifecycle';
	l_api_version		       CONSTANT NUMBER      := 1.0;
	l_msg_count                             NUMBER;
	l_msg_index_out				NUMBER;
	l_data					VARCHAR2(2000);
	l_msg_data				VARCHAR2(2000);
	l_return_status				VARCHAR2(1);

	l_lifecycle_project_usage_type		VARCHAR2(1);
	l_lifecycle_product_usage_type		VARCHAR2(1);
	l_lifecycle_id				NUMBER;
	l_lifecycle_description			VARCHAR2(250);

BEGIN

	IF(p_debug_mode = 'Y') then
	  pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle : Entered create_lifecycle...');
	END IF;

	IF (p_commit = FND_API.G_TRUE) then
		SAVEPOINT LCYL_CREATE_LIFECYCLE_PUB;
	END IF;


        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Initialise message stack

	IF( p_debug_mode = 'Y') THEN
	    pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle : Initialising message stack...');
	END IF;

	pa_debug.init_err_stack('PA_LIFECYCLES_PUB.CREATE_LIFECYCLE');

	IF FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
	 fnd_msg_pub.initialize;
	END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle :After initialising the stack...');
	END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle :Checking for checkboxes...');
	END IF;

	IF (P_lifecycle_name is NULL)
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_NAME_REQUIRED');
            x_msg_data := 'PA_LCYL_NAME_REQUIRED';
            x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

        IF (P_lifecycle_short_name is NULL)
        THEN
		 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_SHORT_NAME_REQUIRED');
            x_msg_data := 'PA_LCYL_SHORT_NAME_REQUIRED';
            x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;


	IF (P_lifecycle_project_usage_type is NULL) then
	    l_lifecycle_project_usage_type := 'N';
	ELSE
	    l_lifecycle_project_usage_type := P_lifecycle_project_usage_type;
        END IF;


	IF (P_lifecycle_product_usage_type is NULL OR
	    P_lifecycle_product_usage_type = G_MISS_CHAR) then
		l_lifecycle_product_usage_type := 'N';
	ELSE
		l_lifecycle_product_usage_type := P_lifecycle_product_usage_type;
	END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle :Checking for validity of required parameters...');
	END IF;


	IF (nvl(l_lifecycle_project_usage_type,'N') = 'N' AND
	    nvl(l_lifecycle_product_usage_type,'N') = 'N')
	THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_USAGE_REQUIRED');
            x_msg_data := 'PA_LCYL_USAGE_REQUIRED';
            x_return_status := FND_API.G_RET_STS_ERROR;
   	END IF;

        IF P_lifecycle_description = G_MISS_CHAR  THEN
		l_lifecycle_description := null;
        ELSE
		l_lifecycle_description := P_lifecycle_description;
        END IF;

	IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle : checking message count');
        END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
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


	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle : Before call to private create  API');
	END IF;

	pa_lifecycles_pvt.create_lifecycle (
	P_api_version			=> P_api_version			,
	p_commit			=> p_commit				,
	p_validate_only			=> p_validate_only			,
	p_validation_level		=> p_validation_level			,
	p_calling_module		=> p_calling_module			,
	p_debug_mode			=> p_debug_mode				,
	p_max_msg_count			=> p_max_msg_count			,
	P_lifecycle_short_name 		=> P_lifecycle_short_name		,
	P_lifecycle_name		=> P_lifecycle_name			,
	P_lifecycle_description	        => l_lifecycle_description		,
	P_lifecycle_project_usage_type	=> l_lifecycle_project_usage_type	,
	P_lifecycle_product_usage_type	=> l_lifecycle_product_usage_type	,
	X_lifecycle_id			=> l_lifecycle_id			,
	X_return_status			=> l_return_status			,
	X_msg_count			=> l_msg_count				,
	X_msg_data			=> l_msg_data
	);

	IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle : checking message count after call to private create  API ');
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

x_lifecycle_id       := l_lifecycle_id;
x_return_status      := FND_API.G_RET_STS_SUCCESS;


IF FND_API.TO_BOOLEAN(P_COMMIT)
THEN
    COMMIT;
END IF;

EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_CREATE_LIFECYCLE_PUB;
    END IF;

    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
                            p_procedure_name => 'CREATE_LIFECYCLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_CREATE_LIFECYCLE_PUB;
    END IF;

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_CREATE_LIFECYCLE_PUB;
    END IF;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
                            p_procedure_name => 'CREATE_LIFECYCLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));



END create_lifecycle;


	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/


PROCEDURE create_lifecycle_phase(
	 P_api_version			IN	NUMBER   := 1.0				,
	 p_init_msg_list		IN	VARCHAR2 :=FND_API.G_TRUE		,
	 p_commit			IN	VARCHAR2 :=FND_API.G_FALSE		,
	 p_validate_only		IN	VARCHAR2 :=FND_API.G_TRUE		,
	 p_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL	,
	 p_calling_module		IN	VARCHAR2 :='SELF_SERVICE'		,
	 p_debug_mode			IN	VARCHAR2 :='N'				,
	 P_max_msg_count		IN	NUMBER   :=G_MISS_NUM			,
	 P_lifecycle_id			IN	NUMBER					,
	 P_phase_status_name		IN	VARCHAR2				,
	 P_phase_short_name 		IN	VARCHAR2 				,
	 P_phase_name			IN	VARCHAR2 				,
	 P_phase_display_sequence	IN	NUMBER   				,
	 P_phase_description		IN	VARCHAR2 :=G_MISS_CHAR			,
	 X_lifecycle_phase_id		OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	 X_return_status		OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	 X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	 X_msg_data			OUT	NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
	 ) IS

	l_api_name	     CONSTANT VARCHAR(30) := 'create_lifecycle_phase';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);

	l_lifecycle_phase_id	      NUMBER;
	l_phase_description           VARCHAR2(250);
	l_lifecycle_exists            VARCHAR2(1);
	l_phase_code                  VARCHAR2(30);

	c_object_type        CONSTANT VARCHAR(30) := 'PA_TASKS';
	c_project_id         CONSTANT NUMBER := 0;



CURSOR l_get_lifecycle_csr
IS
Select 'Y'
From dual
Where exists(SELECT 'XYZ' from pa_proj_elements
	     WHERE  proj_element_id = P_lifecycle_id
	     AND    object_type='PA_STRUCTURES'
	     AND    project_id=c_project_id);

CURSOR l_get_phase_csr
IS
SELECT project_status_code
from pa_project_statuses
WHERE  project_status_name = P_phase_status_name
AND    status_type = 'PHASE';


BEGIN

/* This procedure does not take care of uniqueness of phase sequence. This is responsibility of
calling environment */

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle_phase :Entered create_lifecycle_phase...');
	END IF;

	IF (p_commit = FND_API.G_TRUE) THEN
		SAVEPOINT CREATE_LCYL_PHASES_PUB;
	END IF;

	IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           g_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;


	IF( p_debug_mode = 'Y') THEN
	    pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle_phase : Initialising message stack...');
	END IF;

	pa_debug.init_err_stack('PA_LIFECYCLES_PUB.CREATE_LIFECYCLE_PHASES');

	IF FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
	 fnd_msg_pub.initialize;
	END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle_phase :After initialising the stack...');
	END IF;

	IF (P_phase_name is NULL )
        THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_PHASE_NAME_REQUIRED');
            x_msg_data := 'PA_LCYL_PHASE_NAME_REQUIRED';
            x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

        IF (P_phase_short_name is NULL )
        THEN
		 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_PHASE_SHORT_NAME_REQ');
            x_msg_data := 'PA_LCYL_PHASE_SHORT_NAME_REQ';
            x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

        IF (P_phase_display_sequence is NULL )
        THEN
		 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_PHASE_SEQ_NO_REQ');
            x_msg_data := 'PA_LCYL_PHASE_SEQ_NO_REQ';
            x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	l_lifecycle_exists:='N';
	OPEN l_get_lifecycle_csr;
        FETCH l_get_lifecycle_csr INTO l_lifecycle_exists;
        CLOSE l_get_lifecycle_csr;

	IF(l_lifecycle_exists <> 'Y') THEN
		PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_NOT_VALID');
		x_msg_data := 'PA_LCYL_NOT_VALID';
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	OPEN l_get_phase_csr;
        FETCH l_get_phase_csr INTO l_phase_code;
        CLOSE l_get_phase_csr;

	IF(l_phase_code is null) THEN
		PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_PHASE_NOT_VALID');
		x_msg_data := 'PA_LCYL_PHASE_NOT_VALID';
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;


	IF p_phase_description = G_MISS_CHAR  THEN
		l_phase_description := null;
        ELSE
		l_phase_description := P_phase_description;
        END IF;

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.create_lifecycle_phase : checking message count');
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
	  pa_debug.debug('CREATE_LIFECYCLE_PHASES PUB: Before call to private API');
	END IF;

	pa_lifecycles_pvt.create_lifecycle_phase (
			 P_api_version			=> P_api_version
			,p_commit			=> p_commit
			,p_validate_only		=> p_validate_only
			,p_validation_level		=> p_validation_level
			,p_calling_module		=> p_calling_module
			,p_debug_mode			=> p_debug_mode
			,p_max_msg_count		=> p_max_msg_count
			,P_lifecycle_id			=> p_lifecycle_id
			,P_phase_display_sequence	=> p_phase_display_sequence
			,P_phase_code			=> l_phase_code
			,P_phase_short_name 		=> P_phase_short_name
			,P_phase_name			=> P_phase_name
			,P_phase_description		=> l_phase_description
			,X_lifecycle_phase_id		=> l_lifecycle_phase_id
			,x_return_status		=> l_return_status
			,x_msg_count			=> l_msg_count
			,X_msg_data			=> l_msg_data
 			);

	IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug(' PA_LIFECYCLES_PUB.create_lifecycle_phase :: checking message count');
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

x_lifecycle_phase_id       := l_lifecycle_phase_id;
x_return_status      := FND_API.G_RET_STS_SUCCESS;


IF FND_API.TO_BOOLEAN(P_COMMIT)
THEN
    COMMIT;
END IF;


EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO CREATE_LCYL_PHASES_PUB;
    END IF;

    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
                            p_procedure_name => 'CREATE_LIFECYCLE_PHASE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO CREATE_LCYL_PHASES_PUB;
    END IF;

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO CREATE_LCYL_PHASES_PUB;
    END IF;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
                            p_procedure_name => 'CREATE_LIFECYCLE_PHASE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));



end create_lifecycle_phase;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE delete_lifecycle (
	P_api_version			IN	NUMBER	  := 1.0			,
	P_init_msg_list			IN	VARCHAR2  := FND_API.G_TRUE  		,
	P_commit			IN	VARCHAR2  := FND_API.G_FALSE 		,
	P_validate_only			IN	VARCHAR2  := FND_API.G_TRUE  		,
	P_validation_level		IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL	,
	P_calling_module		IN	VARCHAR2  := 'SELF-SERVICE'  		,
	P_debug_mode			IN	VARCHAR2  := 'N'	     		,
	P_max_msg_count			IN	NUMBER    := G_MISS_NUM			,
	P_lifecycle_id			IN	NUMBER 	 				,
	p_record_version_number         IN      NUMBER					,
	X_return_status			OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2				 --File.Sql.39 bug 4440895
	)
IS

l_api_name           CONSTANT VARCHAR(30) := 'delete_lifecycle';
l_api_version        CONSTANT NUMBER      := 1.0;
l_msg_count                   NUMBER;
l_msg_index_out               NUMBER;
l_data                        VARCHAR2(2000);
l_msg_data                    VARCHAR2(2000);
l_return_status               VARCHAR2(1);
l_errorcode		      NUMBER;

l_lifecycle_exists            VARCHAR2(1);
l_lifecycle_id                NUMBER;
l_phase_id                    NUMBER;
l_del_lifecycle_ok            VARCHAR2(1);
l_life_elem_ver_id            NUMBER;
l_project_usage_exists			VARCHAR2(1):='N';
l_product_usage_exists			VARCHAR2(1):='N';
c_project_type CONSTANT VARCHAR(30) := 'PROJECTS';
c_product_type CONSTANT VARCHAR(30) := 'PRODUCTS';



c_object_type        CONSTANT VARCHAR(30) := 'PA_STRUCTURES';
c_project_id         CONSTANT NUMBER := 0;

CURSOR l_get_lifecycle_csr
IS
Select 'Y'
From dual
Where exists(SELECT 'XYZ' from pa_proj_elements
             WHERE   proj_element_id = P_lifecycle_id
	     AND    object_type= c_object_type
	     AND    project_id=c_project_id
	     );

CURSOR l_phases_csr
IS
Select elem.proj_element_id, elem.record_version_number
From pa_proj_element_versions ever
, pa_proj_elements  elem
Where ever.parent_structure_version_id = l_life_elem_ver_id
AND   ever.object_type= 'PA_TASKS'
AND   ever.project_id=c_project_id
AND   ever.proj_element_id = elem.proj_element_id
AND   elem.project_id = c_project_id
AND   elem.object_type = 'PA_TASKS';

CURSOR l_get_life_elem_ver_id
IS
Select 	ELEMENT_VERSION_ID
From pa_proj_element_versions
Where 	PROJ_ELEMENT_ID = p_lifecycle_id;


BEGIN

	IF(p_debug_mode = 'Y') then
	  pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : Entered delete_lifecycle...');
	END IF;

	IF (p_commit = FND_API.G_TRUE) then
		SAVEPOINT LCYL_DELETE_LIFECYCLE_PUB;
	END IF;


        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Initialise message stack

	IF( p_debug_mode = 'Y') THEN
	    pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : Initialising message stack...');
	END IF;

	pa_debug.init_err_stack('PA_LIFECYCLES_PUB.DELETE_LIFECYCLE');

	IF FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
	 fnd_msg_pub.initialize;
	END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle :After initialising the stack...');
	END IF;

	--  dbms_output.put_line('After initializing the stack');


	l_lifecycle_exists:='N';
	OPEN l_get_lifecycle_csr;
        FETCH l_get_lifecycle_csr INTO l_lifecycle_exists;
        CLOSE l_get_lifecycle_csr;

	IF(l_lifecycle_exists <> 'Y') THEN
		PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_NOT_VALID');
		x_msg_data := 'PA_LCYL_NOT_VALID';
		x_return_status := FND_API.G_RET_STS_ERROR;
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

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : checking message count');
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

	OPEN l_get_life_elem_ver_id;
	FETCH l_get_life_elem_ver_id INTO l_life_elem_ver_id;
	CLOSE l_get_life_elem_ver_id;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : Before call to private API check_delete_phase_ok');
	END IF;


    IF(l_project_usage_exists = 'Y') then
	pa_lifecycles_pvt.check_delete_lifecycle_ok(
		P_api_version			=> P_api_version	,
		p_calling_module		=> p_calling_module	,
		p_debug_mode			=> p_debug_mode		,
		p_max_msg_count			=> p_max_msg_count	,
		P_lifecycle_id			=> p_lifecycle_id	,
		P_lifecycle_version_id          => l_life_elem_ver_id	,
		X_return_status			=> l_return_status	,
		X_msg_count			=> l_msg_count		,
		X_msg_data			=> l_msg_data		,
		x_del_lifecycle_ok              => l_del_lifecycle_ok
		);
     END IF;

     IF(l_product_usage_exists = 'Y') then

	PA_EGO_WRAPPER_PUB.check_delete_lifecycle_ok(
		p_api_version			=> P_api_version	,
		p_lifecycle_id 			=> p_lifecycle_id	,
		p_init_msg_list			=> p_init_msg_list	,
		x_delete_ok			=> l_del_lifecycle_ok	,
		x_return_status			=> l_return_status	,
		x_errorcode			=> l_errorcode		,
		x_msg_count			=> l_msg_count		,
		x_msg_data			=> l_msg_data
		);

     END IF;


        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : checking message count');
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

      IF (l_del_lifecycle_ok <> FND_API.G_TRUE) THEN
	 RAISE  FND_API.G_EXC_ERROR;
      END IF;

      IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : calling pa_lifecycles_pvt.delete_lifecycle_phase for each phase');
      END IF;

      FOR r IN l_phases_csr LOOP
     		pa_lifecycles_pub.delete_lifecycle_phase(
			P_api_version			=> P_api_version		,
			p_init_msg_list			=> p_init_msg_list		,
			p_commit			=> p_commit			,
			p_validate_only			=> p_validate_only		,
			p_validation_level		=> p_validation_level		,
			p_calling_module		=> p_calling_module		,
			p_debug_mode			=> p_debug_mode			,
			p_max_msg_count			=> p_max_msg_count		,
			P_lifecycle_id			=> p_lifecycle_id		,
			p_phase_id			=> r.proj_element_id		,
			p_record_version_number         => r.record_version_number	,
			X_return_status			=> l_return_status		,
			X_msg_count			=> l_msg_count			,
			X_msg_data			=> l_msg_data
			);

     END LOOP;

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : checking message count');
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


	IF(l_product_usage_exists = 'Y') then

		PA_EGO_WRAPPER_PUB.delete_stale_data_for_lc(
			p_api_version		=> P_api_version	,
			p_lifecycle_id 		=> p_lifecycle_id	,
			p_init_msg_list		=> p_init_msg_list	,
			p_commit       		=> p_commit		,
			x_errorcode   		=> l_errorcode		,
			x_return_status		=> l_return_status	,
			x_msg_count		=> l_msg_count		,
			x_msg_data		=> l_msg_data);
        END IF;
	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : Before call to private API delete_lifecycle');
	END IF;

	pa_lifecycles_pvt.delete_lifecycle(
	P_api_version			=> P_api_version,
	p_commit			=> p_commit,
	p_validate_only			=> p_validate_only,
	p_validation_level		=> p_validation_level,
	p_calling_module		=> p_calling_module,
	p_debug_mode			=> p_debug_mode,
	p_max_msg_count			=> p_max_msg_count,
	p_lifecycle_id			=> p_lifecycle_id,
	p_record_version_number         => p_record_version_number,
	X_return_status			=> l_return_status,
	X_msg_count			=> l_msg_count,
	X_msg_data			=> l_msg_data
	);

	IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : checking message count');
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

x_return_status      := FND_API.G_RET_STS_SUCCESS;


IF FND_API.TO_BOOLEAN(P_COMMIT)
THEN
    COMMIT;
END IF;


EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DELETE_LIFECYCLE_PUB;
    END IF;

    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
                            p_procedure_name => 'DELETE_LIFECYCLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DELETE_LIFECYCLE_PUB;
    END IF;

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DELETE_LIFECYCLE_PUB;
    END IF;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
                            p_procedure_name => 'DELETE_LIFECYCLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

END delete_lifecycle;


	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE delete_lifecycle_phase (
	P_api_version			IN	NUMBER	  := 1.0			,
	P_init_msg_list			IN	VARCHAR2  := FND_API.G_TRUE  		,
	P_commit			IN	VARCHAR2  := FND_API.G_FALSE 		,
	P_validate_only			IN	VARCHAR2  := FND_API.G_TRUE  		,
	P_validation_level		IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL	,
	P_calling_module		IN	VARCHAR2  := 'SELF-SERVICE'  		,
	P_debug_mode			IN	VARCHAR2  := 'N'	     		,
	P_max_msg_count			IN	NUMBER    := G_MISS_NUM			,
	P_lifecycle_id                  IN      NUMBER					,
	P_phase_id			IN	NUMBER 	 				,
	p_record_version_number         IN      NUMBER					,
	X_return_status			OUT	NOCOPY VARCHAR2				, --File.Sql.39 bug 4440895
	X_msg_count			OUT	NOCOPY NUMBER					, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	) IS

l_api_name           CONSTANT VARCHAR(30) := 'delete_lifecycle_phase';
l_api_version        CONSTANT NUMBER      := 1.0;
l_msg_count                NUMBER;
l_msg_index_out            NUMBER;
l_data			   VARCHAR2(2000);
l_msg_data		   VARCHAR2(2000);
l_return_status		   VARCHAR2(1);
l_errorcode		   NUMBER;

l_phase_exists            VARCHAR2(1) :='N';
l_lifecycle_exists            VARCHAR2(1);
l_phase_id                    NUMBER;
l_lifecycle_id                NUMBER;
l_del_phase_ok            VARCHAR2(1);


l_project_usage_exists			VARCHAR2(1) :='N';
l_product_usage_exists			VARCHAR2(1) :='N';
c_project_type CONSTANT			VARCHAR2(10) :='PROJECTS';
c_product_type CONSTANT			VARCHAR2(10) :='PRODUCTS';
c_object_type CONSTANT			VARCHAR(30) := 'PA_TASKS';
c_project_id  CONSTANT			NUMBER :=0;

CURSOR l_get_phaseexist_csr
IS
Select 'Y'
From dual
Where exists(
        Select 'XYZ'
	from pa_proj_element_versions child
	 , pa_proj_element_versions parent
	where child.proj_element_id = P_phase_id
	and child.parent_structure_version_id = parent.element_version_id
	and parent.proj_element_id = P_lifecycle_id
	AND child.object_type= c_object_type
	AND child.project_id=c_project_id
	and parent.object_type = 'PA_STRUCTURES'
	and parent.project_id = c_project_id);


BEGIN

	IF(p_debug_mode = 'Y') then
	  pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle_phase : Entered delete_lifecycle_phase...');
	END IF;

	IF (p_commit = FND_API.G_TRUE) then
		SAVEPOINT LCYL_DELETE_LCYL_PHASE_PUB;
	END IF;


        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Initialise message stack

	IF( p_debug_mode = 'Y') THEN
	    pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle_phase : Initialising message stack...');
	END IF;

	pa_debug.init_err_stack('PA_LIFECYCLES_PUB.DELETE_LIFECYCLE_PHASE');

	IF FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
	 fnd_msg_pub.initialize;
	END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle_phase :After initialising the stack...');
	END IF;

	--  dbms_output.put_line('After initializing the stack');

        begin
	   Select 'Y' into l_phase_exists
	   From dual
           Where exists(
	   Select 'XYZ' from pa_proj_element_versions child
	 , pa_proj_element_versions parent
	where child.proj_element_id = P_phase_id
	and child.parent_structure_version_id = parent.element_version_id
	and parent.proj_element_id = P_lifecycle_id
	AND child.object_type= c_object_type
	AND child.project_id=c_project_id
	and parent.object_type = 'PA_STRUCTURES'
	and parent.project_id = c_project_id);

        exception
		when NO_DATA_FOUND then
			l_phase_exists :='N';
	end;


	IF(l_phase_exists <> 'Y') THEN
		PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_PHASE_NOT_VALID');
		x_msg_data := 'PA_LCYL_PHASE_NOT_VALID';
		x_return_status := FND_API.G_RET_STS_ERROR;
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
	where exists(select 'XYZ' from pa_lifecycle_usages
			where lifecycle_id=P_lifecycle_id  AND
				usage_type=c_product_type);
	exception
	  when NO_DATA_FOUND then
	  l_product_usage_exists := 'N';
	END;

	IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle_phase: checking message count');
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

    IF(l_project_usage_exists = 'Y') then

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : Before call to private API check_delete_lcyl_phase_ok');
	END IF;

	pa_lifecycles_pvt.check_delete_lcyl_phase_ok(
		P_api_version			=> P_api_version	,
		p_calling_module		=> p_calling_module	,
		p_debug_mode			=> p_debug_mode		,
		p_max_msg_count			=> p_max_msg_count	,
		P_lifecycle_id			=> P_lifecycle_id       ,
		P_lifecycle_phase_id		=> p_phase_id		,
		X_return_status			=> l_return_status	,
		X_msg_count			=> l_msg_count		,
		X_msg_data			=> l_msg_data		,
		x_delete_ok	                => l_del_phase_ok
		);

     END IF;

     IF(l_product_usage_exists = 'Y') then

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_EGO_WRAPPER_PUB.check_delete_phase_ok  : Before call to private API check_delete_lcyl_phase_ok');
	END IF;

	PA_EGO_WRAPPER_PUB.check_delete_phase_ok (
		p_api_version			=> P_api_version	,
		p_phase_id 			=> p_phase_id		,
		p_init_msg_list			=> p_init_msg_list	,
		x_delete_ok			=> l_del_phase_ok	,
		x_return_status			=> l_return_status	,
		x_errorcode			=> l_errorcode		,
		x_msg_count			=> l_msg_count		,
		x_msg_data			=> l_msg_data
		);

     END IF;

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle : checking message count');
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

     IF (l_del_phase_ok <> FND_API.G_TRUE) THEN
	 RAISE  FND_API.G_EXC_ERROR;
      END IF;


      IF(l_product_usage_exists = 'Y') then
		PA_EGO_WRAPPER_PUB.process_phase_delete(
			p_api_version			=> P_api_version		,
			p_phase_id			=> p_phase_id			,
			p_init_msg_list                 => p_init_msg_list		,
			p_commit       	                => p_commit			,
			x_errorcode			=> l_errorcode			,
			x_return_status			=> l_return_status		,
			x_msg_count			=> l_msg_count			,
			x_msg_data			=> l_msg_data);
	 END IF;

      IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle_phase : calling pa_lifecycles_pvt.delete_lifecycle_phase for each phase');
      END IF;


      pa_lifecycles_pvt.delete_lifecycle_phase(
			P_api_version			=> P_api_version		,
			p_commit			=> p_commit			,
			p_validate_only			=> p_validate_only		,
			p_validation_level		=> p_validation_level		,
			p_calling_module		=> p_calling_module		,
			p_debug_mode			=> p_debug_mode			,
			p_max_msg_count			=> p_max_msg_count		,
			p_phase_id			=> p_phase_id			,
			p_record_version_number         => p_record_version_number	,
			X_return_status			=> l_return_status		,
			X_msg_count			=> l_msg_count			,
			X_msg_data			=> l_msg_data
			);

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.delete_lifecycle_phase : checking message count');
        END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages
	         (p_encoded        => FND_API.G_TRUE	,
	          p_msg_index      => 1			,
	          p_msg_count      => l_msg_count	,
	          p_msg_data       => l_msg_data	,
	          p_data           => l_data		,
	          p_msg_index_out  => l_msg_index_out );
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

x_return_status      := FND_API.G_RET_STS_SUCCESS;


IF FND_API.TO_BOOLEAN(P_COMMIT)
THEN
    COMMIT;
END IF;


EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DELETE_LCYL_PHASE_PUB;
    END IF;

    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
                            p_procedure_name => 'DELETE_LIFECYCLE_PHASE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DELETE_LCYL_PHASE_PUB;
    END IF;

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_DELETE_LCYL_PHASE_PUB;
    END IF;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
                            p_procedure_name => 'DELETE_LIFECYCLE_PHASE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));


END delete_lifecycle_phase;


	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE update_lifecycle (
	P_api_version			IN	NUMBER   :=1.0					,
	p_init_msg_list			IN	VARCHAR2 := FND_API.G_TRUE			,
	p_commit			IN	VARCHAR2 :=FND_API.G_FALSE			,
	p_validate_only			IN	VARCHAR2 :=FND_API.G_TRUE			,
	p_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL		,
	p_calling_module		IN	VARCHAR2 :='SELF SERVICE'			,
	p_debug_mode			IN	VARCHAR2 :='N'					,
	p_max_msg_count			IN	NUMBER   :=G_MISS_NUM				,
	P_lifecycle_id			IN	NUMBER	 					,
	P_lifecycle_short_name	 	IN	VARCHAR2 :=G_MISS_CHAR				,
	P_lifecycle_name		IN	VARCHAR2 :=G_MISS_CHAR				,
	P_lifecycle_description		IN	VARCHAR2 :=G_MISS_CHAR				,
	P_lifecycle_project_usage_type	IN	VARCHAR2 :=G_MISS_CHAR				,
	P_lifecycle_product_usage_type	IN	VARCHAR2 :=G_MISS_CHAR				,
	P_record_version_number		IN	NUMBER						,
	x_return_status			OUT	NOCOPY VARCHAR2					, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER						, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	)
	IS

	l_api_name           CONSTANT		VARCHAR(30) := 'update_lifecycle';
	l_api_version        CONSTANT		NUMBER      := 1.0;
	l_msg_count				NUMBER;
	l_msg_index_out				NUMBER;
	l_data					VARCHAR2(2000);
	l_msg_data				VARCHAR2(2000);
	l_return_status				VARCHAR2(1);

	l_lifecycle_project_usage_type		VARCHAR2(1);
	l_lifecycle_product_usage_type		VARCHAR2(1);
	l_lifecycle_id				NUMBER(15);
	l_short_name				VARCHAR2(100);
	l_lcyl_name				VARCHAR2(100);
	l_lifecycle_description			VARCHAR2(250);
	c_object_type        CONSTANT VARCHAR(30) := 'PA_STRUCTURES';
	c_project_id         CONSTANT NUMBER := 0;
	l_shname_uniq				VARCHAR2(1):='N';
	l_data_changed                    boolean := false;


	BEGIN

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.update_lifecycle : Entered update_lifecycle...');
	END IF;

	IF (p_commit = FND_API.G_TRUE) then
		SAVEPOINT LCYL_UPDATE_LIFECYCLE_PUB;
	END IF;

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLES_PUB.Update_Lifecycle: Checking api compatibility...');
	END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           g_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;


	l_lifecycle_id := P_lifecycle_id;

	-- Initialise message stack

	IF( p_debug_mode = 'Y') THEN
	    pa_debug.debug('PA_LIFECYCLES_PUB.update_lifecycle : Initialising message stack...');
	END IF;

	pa_debug.init_err_stack('PA_LIFECYCLES_PUB.UPDATE_LIFECYCLE');

	IF FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
	 fnd_msg_pub.initialize;
	END IF;



	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.Update_Lifecycle:After initialising the stack..getting the data from database.');
	END IF;



	BEGIN
	  select name,element_number,description
	  into l_lcyl_name,l_short_name,l_lifecycle_description
	  from pa_proj_elements
	  where proj_element_id=l_lifecycle_id
	  AND object_type = c_object_type
	  AND project_id = c_project_id;
	EXCEPTION
	  when NO_DATA_FOUND	then
	  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_LCYL_NOT_VALID');
	  x_msg_data := 'PA_LCYL_NOT_VALID';
	  x_return_status := FND_API.G_RET_STS_ERROR;
	END;

        IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.Update_Lifecycle:Checking for null values assigning the updated values');
	END IF;

	-- Explicit NUlling of name not allowed
	IF (P_lifecycle_name is NULL)
        THEN
	    pa_debug.debug('Lifecycle name is NULL....');
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_NAME_REQUIRED');
            x_msg_data := 'PA_LCYL_NAME_REQUIRED';
            x_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF(P_lifecycle_name <> G_MISS_CHAR) then
		   IF l_lcyl_name <> P_lifecycle_name THEN
			   l_data_changed := true;
                   END IF;
		   l_lcyl_name := P_lifecycle_name;
	END IF;


        IF (P_lifecycle_short_name is NULL)
        THEN
	    pa_debug.debug('Lifecycle short name is NULL....');
		 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_LCYL_SHORT_NAME_REQUIRED');
			              x_msg_data := 'PA_LCYL_SHORT_NAME_REQUIRED';
                  x_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF (P_lifecycle_short_name <> G_MISS_CHAR)
	THEN
		IF(p_debug_mode = 'Y') THEN
	  	  pa_debug.debug('PA_LIFECYCLES_PVT.Update_Lifecycle: Checking for existing parameters for  uniqueness..');
		END IF;

		IF l_short_name <> P_lifecycle_short_name THEN
			BEGIN
			  Select 'N'
			  Into l_shname_uniq
			  from SYS.DUAL
			  Where exists(Select 'XYZ' from pa_proj_elements
				where element_number = P_lifecycle_short_name
				AND object_type=c_object_type
				AND project_id = c_project_id);
			exception
				 when NO_DATA_FOUND then
					l_shname_uniq := 'Y';
			END;

			IF(l_shname_uniq <> 'Y') THEN
				pa_debug.debug('The short name is in use...');
				PA_UTILS.ADD_MESSAGE(
					 p_app_short_name => 'PA',
	                                 p_msg_name       => 'PA_LCYL_SHORT_NAME_EXISTS');
				x_msg_data := 'PA_LCYL_SHORT_NAME_EXISTS';
				x_return_status := FND_API.G_RET_STS_ERROR;
		        ELSE
			        IF l_short_name <> P_lifecycle_short_name THEN
				    l_data_changed := true;
				END IF;
			END IF;
		END IF;
		l_short_name := P_lifecycle_short_name;
	END IF;

	IF P_lifecycle_description is null  THEN
		l_lifecycle_description := null;
	ELSIF(P_lifecycle_description <> G_MISS_CHAR) then
	        IF l_lifecycle_description <> P_lifecycle_description THEN
			    l_data_changed := true;
                END IF;
		l_lifecycle_description := P_lifecycle_description;
	END IF;

	IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.update_lifecycle : checking message count'||FND_MSG_PUB.count_msg);
        END IF;


	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.update_lifecycle : Before call to private API');
	END IF;



	IF (P_lifecycle_project_usage_type is null OR P_lifecycle_product_usage_type is null)
	THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_USAGE_REQUIRED');
            x_msg_data := 'PA_LCYL_USAGE_REQUIRED';
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	BEGIN
		select 'Y'
		into l_lifecycle_project_usage_type
		from SYS.DUAL
		where exists ( select '1' from pa_lifecycle_usages
					where lifecycle_id=l_lifecycle_id
					AND   usage_type='PROJECTS');
	EXCEPTION
	  when NO_DATA_FOUND then
		l_lifecycle_project_usage_type := 'N';
	END;

	IF (P_lifecycle_project_usage_type <> G_MISS_CHAR) THEN
	        IF l_lifecycle_project_usage_type <> P_lifecycle_project_usage_type THEN
			    l_data_changed := true;
                END IF;
		l_lifecycle_project_usage_type := P_lifecycle_project_usage_type;
        END IF;

	BEGIN
		select 'Y'
		into l_lifecycle_product_usage_type
		from SYS.DUAL
		where exists ( select '1' from pa_lifecycle_usages
				       where lifecycle_id=l_lifecycle_id
				       AND   usage_type='PRODUCTS');
	EXCEPTION
	  when NO_DATA_FOUND then
		l_lifecycle_product_usage_type := 'N';
	END;

	IF (P_lifecycle_product_usage_type <> G_MISS_CHAR) THEN
                IF l_lifecycle_product_usage_type <> P_lifecycle_product_usage_type THEN
			    l_data_changed := true;
                END IF;
	    	l_lifecycle_product_usage_type := P_lifecycle_product_usage_type;
   	END IF;

	IF (l_lifecycle_project_usage_type ='N' AND l_lifecycle_product_usage_type ='N')
	THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_LCYL_USAGE_REQUIRED');
            x_msg_data := 'PA_LCYL_USAGE_REQUIRED';
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


	/* The below code could be used to dod not hit the data if nothing is changed
	 IF (NOT (l_data_changed)) THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_NO_CHANGES_TO_UPDATE');
            x_msg_data := 'PA_NO_CHANGES_TO_UPDATE';
            x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;
	*/

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.Update_Lifecycle:After checking for null values  assigning the updated values');
	END IF;

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.Update_Lifecycle: checking message count');
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
	  pa_debug.debug('PA_LIFECYCLES_PUB.Update_Lifecycle: Before call to private update  API');
	END IF;

	pa_lifecycles_pvt.update_lifecycle (
			P_api_version			=> P_api_version			,
			p_commit			=> p_commit				,
			p_validate_only			=> p_validate_only			,
			p_validation_level		=> p_validation_level			,
			p_calling_module		=> p_calling_module			,
			p_debug_mode			=> p_debug_mode				,
			p_max_msg_count			=> p_max_msg_count			,
			p_lifecycle_id			=> l_lifecycle_id			,
			P_lifecycle_short_name 		=> l_short_name				,
			P_lifecycle_name		=> l_lcyl_name				,
			P_lifecycle_description	        => l_lifecycle_description		,
			P_lifecycle_project_usage_type	=> l_lifecycle_project_usage_type	,
			P_lifecycle_product_usage_type	=> l_lifecycle_product_usage_type	,
			P_record_version_number		=> p_record_version_number			,
			X_return_status			=> l_return_status			,
			X_msg_count			=> l_msg_count				,
			X_msg_data			=> l_msg_data
			);


        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.update_lifecycle : checking message count After call to private update API');
        END IF;

	IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.Update_Lifecycle: checking message count');
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
	          p_msg_index_out  => l_msg_index_out );
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
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_UPDATE_LIFECYCLE_PUB;
    END IF;

    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
                            p_procedure_name => 'UPDATE_LIFECYCLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_UPDATE_LIFECYCLE_PUB;
    END IF;

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO LCYL_UPDATE_LIFECYCLE_PUB;
    END IF;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
                            p_procedure_name => 'UPDATE_LIFECYCLE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));


END update_lifecycle;


	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/


PROCEDURE update_lifecycle_phase (
	P_api_version			IN	NUMBER   :=1.0					,
	p_init_msg_list			IN	VARCHAR2 :=FND_API.G_TRUE			,
	p_commit			IN	VARCHAR2 :=FND_API.G_FALSE			,
	p_validate_only			IN	VARCHAR2 :=FND_API.G_TRUE			,
	p_validation_level		IN	NUMBER   :=FND_API.G_VALID_LEVEL_FULL		,
	p_calling_module		IN	VARCHAR2 :='SELF SERVICE'			,
	p_debug_mode			IN	VARCHAR2 :='N'					,
	P_max_msg_count			IN	NUMBER   :=G_MISS_NUM				,
	P_lifecycle_id			IN	NUMBER						,
	P_lifecycle_phase_id		IN	NUMBER						,
	P_phase_status_name		IN	VARCHAR2 :=G_MISS_CHAR		   		,
	P_phase_short_name		IN	VARCHAR2 :=G_MISS_CHAR				,
	P_phase_name			IN	VARCHAR2 :=G_MISS_CHAR				,
	P_phase_display_sequence	IN	NUMBER   :=G_MISS_NUM				,
	P_phase_description		IN	VARCHAR2 :=G_MISS_CHAR				,
	P_record_version_number		IN	NUMBER						,
	x_return_status			OUT	NOCOPY VARCHAR2					, --File.Sql.39 bug 4440895
	x_msg_count			OUT	NOCOPY NUMBER						, --File.Sql.39 bug 4440895
	X_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	)IS

	l_api_name		CONSTANT	VARCHAR(30) := 'update_lifecycle_phase';
	l_api_version		CONSTANT	NUMBER      := 1.0;
	l_msg_count				NUMBER;
	l_msg_index_out				NUMBER;
	l_data VARCHAR2(2000);
	l_msg_data VARCHAR2(2000);
	l_return_status VARCHAR2(1);

	l_lifecycle_id				NUMBER;
	l_phase_short_name			VARCHAR2(100);
	l_phase_name				VARCHAR2(240);
	l_seqn					NUMBER;
	l_org_seq                               NUMBER;
	l_phase_code				VARCHAR2(30);
	l_new_phase_code                        VARCHAR2(30);
	l_org_phase_code                        VARCHAR2(30);
	l_phase_description			VARCHAR2(250);
	c_object_type		CONSTANT	VARCHAR(30) := 'PA_TASKS';
	c_project_id		CONSTANT	NUMBER :=0;
	l_update_ok                             VARCHAR2(1) := FND_API.G_FALSE;
	l_data_changed                          boolean := false;


CURSOR l_get_phase_csr
IS
SELECT project_status_code
from pa_project_statuses
WHERE  project_status_name = P_phase_status_name
AND    status_type = 'PHASE';


BEGIN
	/* Note that check for duplicate shortname and sequence can not be done here. as user may want to update
	   two records at the same time, swapping the values */

	IF(p_debug_mode = 'Y') then
	  pa_debug.debug('PA_LIFECYCLES_PUB.update_lifecycle_phase : Entered update_lifecycle_phase...');
	END IF;

	IF (p_commit = FND_API.G_TRUE) then
		SAVEPOINT LCYL_UPD_LC_PHASE_PUB;
	END IF;

	IF(p_debug_mode = 'Y') THEN
  	  pa_debug.debug('PA_LIFECYCLES_PUB.Update_Lifecycle_phases: Checking api compatibility...');
	END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           g_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;



	-- Initialise message stack

	IF( p_debug_mode = 'Y') THEN
	    pa_debug.debug('PA_LIFECYCLES_PUB.update_lifecycle_phase : Initialising message stack...');
	END IF;

	pa_debug.init_err_stack('PA_LIFECYCLES_PUB.UPDATE_LIFECYCLE_PHASE');

	IF FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
	 fnd_msg_pub.initialize;
	END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.update_lifecycle_phase :After initialising the stack..and getting the old data from database.');
	END IF;

	BEGIN
	  select prj.name,prj.element_number,prj.description,prj.phase_code,elem.display_sequence
	  into l_phase_name,l_phase_short_name,l_phase_description,l_phase_code,l_seqn
	  from pa_proj_elements prj
	  , pa_proj_element_versions elem
	  where prj.proj_element_id=P_lifecycle_phase_id
	  and prj.project_id=c_project_id
	  and prj.object_type=c_object_type
	  and prj.proj_element_id=elem.proj_element_id;

   	 l_org_phase_code := l_phase_code;
	 l_org_seq := l_seqn;

	EXCEPTION
	  when NO_DATA_FOUND	  then
		 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name       => 'PA_LCYL_PHASE_NOT_VALID');
		 x_msg_data := 'PA_LCYL_PHASE_NOT_VALID';
		 x_return_status := FND_API.G_RET_STS_ERROR;
	END;


        IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.Update_lifecycle_phase:Checking for null values  assigning the updated values');
	END IF;

        -- Explicit NULLing not allowed
        IF (P_phase_name is NULL)
        THEN
		 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_LCYL_PHASE_NAME_REQUIRED');
                 x_msg_data := 'PA_LCYL_PHASE_NAME_REQUIRED';
                 x_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF(P_phase_name <> G_MISS_CHAR) then
		   IF l_phase_name <> P_phase_name THEN
			   l_data_changed := true;
                   END IF;
		    l_phase_name := P_phase_name;
	END IF;

        IF (P_phase_short_name is NULL)
        THEN
		 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_LCYL_PHASE_SHORT_NAME_REQ');
			              x_msg_data := 'PA_LCYL_PHASE_SHORT_NAME_REQ';
			              x_return_status := FND_API.G_RET_STS_ERROR;
	elsif(P_phase_short_name <> G_MISS_CHAR) then
		   IF l_phase_short_name <> P_phase_short_name THEN
			   l_data_changed := true;
                   END IF;
 	           l_phase_short_name := P_phase_short_name;
	END IF;

        IF (P_phase_status_name is NULL)
        THEN
		 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_LCYL_PHASE_NOT_VALID');
                  x_msg_data := 'PA_LCYL_PHASE_NOT_VALID';
                  x_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF (P_phase_status_name <> G_MISS_CHAR)
	THEN
		OPEN l_get_phase_csr;
		FETCH l_get_phase_csr INTO l_new_phase_code;
	        CLOSE l_get_phase_csr;

		IF(l_new_phase_code is null) THEN
			PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
				         p_msg_name       => 'PA_LCYL_PHASE_NOT_VALID');
			x_msg_data := 'PA_LCYL_PHASE_NOT_VALID';
			x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;

		IF l_phase_code <> l_new_phase_code THEN
 		   l_data_changed := true;
                END IF;
		l_phase_code := l_new_phase_code;
	END IF;

        IF (P_phase_display_sequence is NULL)
        THEN
		 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_LCYL_PHASE_SEQ_NO_REQ');
                 x_msg_data := 'PA_LCYL_PHASE_SEQ_NO_REQ';
                 x_return_status := FND_API.G_RET_STS_ERROR;
	elsif(P_phase_display_sequence <> G_MISS_NUM) then
		IF l_seqn <> P_phase_display_sequence THEN
 		   l_data_changed := true;
                END IF;
 	        l_seqn := P_phase_display_sequence;
	END IF;

	IF (P_phase_description IS NULL) THEN
		l_phase_description := null;
	elsif(P_phase_description <> G_MISS_CHAR) then
		IF l_phase_description <> P_phase_description THEN
 		   l_data_changed := true;
                END IF;
		   l_phase_description := P_phase_description;
        END IF;

	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.Update_lifecycle_phase:After checking for null values  assigning the updated values');
	END IF;

   	/* The below code could be used to dod not hit the data if nothing is changed
	IF (NOT (l_data_changed)) THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_NO_CHANGES_TO_UPDATE');
            x_msg_data := 'PA_NO_CHANGES_TO_UPDATE';
            x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;
	*/

	IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.Update_lifecycle_phase: checking message count');
        END IF;

       l_msg_count := FND_MSG_PUB.count_msg;

       If l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          If l_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages
	         (p_encoded        => FND_API.G_TRUE	,
	          p_msg_index      => 1			,
	          p_msg_count      => l_msg_count	,
	          p_msg_data       => l_msg_data	,
	          p_data           => l_data		,
	          p_msg_index_out  => l_msg_index_out );
	    x_msg_data := l_data;
	 End if;
         RAISE  FND_API.G_EXC_ERROR;
       End if;

       IF ((P_phase_display_sequence <> G_MISS_NUM AND l_seqn <> l_org_seq)
		OR (P_phase_status_name <> G_MISS_CHAR AND l_phase_code <> l_org_phase_code))
       THEN
            IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.Update_lifecycle_phase: Calling private api check_delete_lcyl_phase_ok');
	    END IF;

	    pa_lifecycles_pvt.check_delete_lcyl_phase_ok(
			P_api_version			=>l_api_version			,
			p_calling_module		=>p_calling_module		,
			p_debug_mode			=>p_debug_mode			,
			P_max_msg_count			=>P_max_msg_count		,
			P_lifecycle_id			=>P_lifecycle_id		,
			P_lifecycle_phase_id		=>P_lifecycle_phase_id		,
			x_delete_ok			=>l_update_ok			,
			x_return_status			=>l_return_status		,
			x_msg_count			=>l_msg_count			,
			X_msg_data			=>l_data
			);

	     l_msg_count := FND_MSG_PUB.count_msg;
	     IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.Update_lifecycle_phase: checking message count');
	     END IF;
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

	    IF (l_update_ok <>FND_API.G_TRUE) THEN
		RAISE  FND_API.G_EXC_ERROR;
            END IF;

       END IF;


	IF(p_debug_mode = 'Y') THEN
	  pa_debug.debug('PA_LIFECYCLES_PUB.update_lifecycle_phase : Before call to private API update_lifecycle_phase');
	END IF;

	pa_lifecycles_pvt.update_lifecycle_phase (
		P_api_version			=>1.0				,
		p_commit			=>p_commit			,
		p_validate_only			=>p_validate_only		,
		p_validation_level		=>p_validation_level		,
		p_calling_module		=>p_calling_module		,
		p_debug_mode			=>p_debug_mode			,
		P_max_msg_count			=>P_max_msg_count		,
		P_lifecycle_id			=> P_lifecycle_id		,
		P_lifecycle_phase_id		=>P_lifecycle_phase_id		,
		P_phase_display_sequence	=>l_seqn			,
		P_phase_code			=>l_phase_code			,
		P_phase_short_name		=>l_phase_short_name		,
		P_phase_name			=>l_phase_name			,
		P_phase_description		=>l_phase_description		,
		P_record_version_number         =>P_record_version_number	,
		x_return_status		        =>l_return_status		,
		x_msg_count			=>l_msg_count			,
		X_msg_data			=>l_data
		);

        IF (p_debug_mode = 'Y') THEN
	        pa_debug.debug('PA_LIFECYCLES_PUB.update_lifecycle_phase : checking message count after call to private API update_lifecycle_phase');
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

	x_return_status      := FND_API.G_RET_STS_SUCCESS;


	IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
	    COMMIT;
	END IF;


EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF p_commit = FND_API.G_TRUE THEN
	  ROLLBACK TO LCYL_UPD_LC_PHASE_PUB;
	END IF;

	fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
	                        p_procedure_name => 'UPDATE_LIFECYCLE_PHASE',
	                       p_error_text     => SUBSTRB(SQLERRM,1,240));
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN FND_API.G_EXC_ERROR THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
	IF p_commit = FND_API.G_TRUE THEN
	  ROLLBACK TO LCYL_UPD_LC_PHASE_PUB;
	END IF;

WHEN OTHERS THEN
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF p_commit = FND_API.G_TRUE THEN
	  ROLLBACK TO LCYL_UPD_LC_PHASE_PUB;
	END IF;
	fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_LIFECYCLES_PUB',
	                      p_procedure_name => 'UPDATE_LIFECYCLE_PHASE',
		                    p_error_text     => SUBSTRB(SQLERRM,1,240));


END update_lifecycle_phase;


END PA_LIFECYCLES_PUB;

/
