--------------------------------------------------------
--  DDL for Package Body PA_R_PROJECT_RESOURCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_R_PROJECT_RESOURCES_PUB" 
--  $Header: PARCPRPB.pls 120.3.12010000.4 2009/05/29 15:36:13 jngeorge ship $
AS

 G_PKG_NAME         VARCHAR2(30) := 'PA_R_PROJECT_RESOURCES_PUB';

 P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

PROCEDURE CREATE_RESOURCE(
	P_API_VERSION 	     IN	NUMBER,
	P_INIT_MSG_LIST	     IN	VARCHAR2	DEFAULT NULL,
	P_COMMIT 	     IN	VARCHAR2	DEFAULT NULL,
	P_VALIDATE_ONLY	     IN	VARCHAR2	DEFAULT NULL,
	P_MAX_MSG_COUNT	     IN	NUMBER		DEFAULT NULL,
	P_INTERNAL 	     IN	VARCHAR2	DEFAULT 'Y',
	P_PERSON_ID	     IN	PA_RESOURCE_TXN_ATTRIBUTES.PERSON_ID%TYPE	DEFAULT NULL,
	P_INDIVIDUAL 	     IN	VARCHAR2	DEFAULT 'N',
	P_CHECK_RESOURCE     IN	VARCHAR2        DEFAULT 'N',
        P_SCHEDULED_MEMBER_FLAG IN VARCHAR2     DEFAULT 'Y',
	P_RESOURCE_TYPE	     IN	JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE	 DEFAULT NULL,
        P_PARTY_ID           IN PA_RESOURCE_TXN_ATTRIBUTES.PARTY_ID%TYPE DEFAULT NULL,
        P_FROM_EMP_NUM       IN VARCHAR2        DEFAULT NULL,
        P_TO_EMP_NUM         IN VARCHAR2        DEFAULT NULL,
        P_ORGANIZATION_ID    IN NUMBER          DEFAULT NULL,
        P_REFRESH            IN VARCHAR2        DEFAULT 'Y',
        P_PULL_TERM_RES      IN VARCHAR2        DEFAULT 'N',
        P_TERM_RANGE_DATE    IN DATE            DEFAULT NULL,
        P_PERSON_TYPE        IN VARCHAR2        DEFAULT 'ALL',
        P_START_DATE         IN DATE            DEFAULT NULL, -- Bug 5337454
        -- Added parameters for PJR Resource Pull Enhancements - Bug 5130414
        P_SELECTION_OPTION	IN  VARCHAR2    DEFAULT NULL,
        P_ORG_STR_VERSION_ID	IN  NUMBER      DEFAULT NULL,
        P_START_ORGANIZATION_ID IN  NUMBER      DEFAULT NULL,
        -- End of parameters added for PJR Resource Pull Enhancements - Bug 5130414
	X_RETURN_STATUS      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_MSG_COUNT 	     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	X_MSG_DATA	     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_RESOURCE_ID	     OUT NOCOPY PA_RESOURCES.RESOURCE_ID%TYPE) --File.Sql.39 bug 4440895
 IS
	L_API_VERSION	CONSTANT NUMBER	:= 1.0;
	L_API_NAME	CONSTANT VARCHAR2(30) := 'CREATE_RESOURCE';
	L_INTERNAL		 VARCHAR2(1)  := P_INTERNAL;
	L_PERSON_ID		 NUMBER	      := P_PERSON_ID;
	L_INDIVIDUAL		 VARCHAR2(1)  := P_INDIVIDUAL ;
	L_RESOURCE_TYPE		 JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE	:= P_RESOURCE_TYPE;
	L_INIT_MSG_LIST          VARCHAR2(10) := P_INIT_MSG_LIST;
	L_COMMIT                 VARCHAR2(10) := P_COMMIT;
	L_VALIDATE_ONLY          VARCHAR2(10) := P_VALIDATE_ONLY;
	L_MAX_MSG_COUNT          NUMBER	      := P_MAX_MSG_COUNT;
	l_msg_index_out          NUMBER;
	l_msg_count              NUMBER;
	l_msg_data               VARCHAR2(2000);
	l_data			 VARCHAR2(2000);
	l_return_status		 VARCHAR2(1);

	l_debug_mode		 VARCHAR2(20) := 'N';

 BEGIN

        --For bug 4345198
        IF p_debug_mode = 'Y' THEN
   	   -- Initialize the Error Stack
	   PA_DEBUG.init_err_stack('PA_R_PROJECT_RESOURCES_PUB.Create_Resource');
        END IF;

        -- only for the concurrent program (l_individual = N)
        -- that we check for the debug mode
        -- if not, just leave the default value as N for individual pull
        IF (l_individual = 'N') THEN
	   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
	   l_debug_mode := NVL(l_debug_mode, 'N');
        END IF;

        IF p_debug_mode = 'Y' THEN --For bug 4345198
    	   pa_debug.set_process('PLSQL','LOG',l_debug_mode);
        END IF;

	IF P_INIT_MSG_LIST IS NULL THEN
                L_INIT_MSG_LIST := FND_API.G_FALSE;
        END IF;

        IF P_COMMIT IS NULL THEN
                L_COMMIT := FND_API.G_TRUE;
        END IF;

        IF P_VALIDATE_ONLY IS NULL THEN
                L_VALIDATE_ONLY := FND_API.G_FALSE;
        END IF;

        IF P_MAX_MSG_COUNT IS NULL THEN
                L_MAX_MSG_COUNT := FND_API.G_MISS_NUM;
        END IF;

	IF (l_commit = FND_API.G_TRUE) THEN
		SAVEPOINT res_pub_create_resource;
	END IF;

	If L_RESOURCE_TYPE IS NULL THEN
		L_RESOURCE_TYPE := 'EMPLOYEE';
	End If;

	X_RETURN_STATUS := fnd_api.g_ret_sts_success;

	IF fnd_api.to_boolean(L_INIT_MSG_LIST) THEN
		fnd_msg_pub.initialize;
	END IF;

	IF NOT fnd_api.compatible_api_call(L_API_VERSION, P_API_VERSION, L_API_NAME, G_PKG_NAME)
        THEN
              RAISE fnd_api.g_exc_error;
        END IF;

	IF ((L_INTERNAL is null) or (L_INDIVIDUAL is null) or (L_RESOURCE_TYPE is null)) THEN
		 --dbms_output.put_line('Internal Flag or Individual Flag or Resource Type cannot be null');
		PA_UTILS.Add_Message( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_RS_PUBLIC_PARAMETERS_NULL');
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		RAISE fnd_api.g_exc_error;
	END IF;

	---Call the Private Procedure
        --dbms_output.put_line('Calling Private Procedure PA_R_PROJECT_RESOURCES_PVT.CREATE_RESOURCE ');
	IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.g_err_stage := 'Log: Calling private API - Create_Resource'; --For bug 4345198
	   pa_debug.write_file('CREATE_RESOURCE: ' || 'LOG',pa_debug.g_err_stage);
	END IF;

	PA_R_PROJECT_RESOURCES_PVT.CREATE_RESOURCE (
			 P_COMMIT		  => L_COMMIT,
			 P_VALIDATE_ONLY	  => L_VALIDATE_ONLY,
			 P_INTERNAL		  => L_INTERNAL,
			 P_PERSON_ID		  => L_PERSON_ID,
			 P_INDIVIDUAL		  => L_INDIVIDUAL,
			 P_CHECK_RESOURCE         => P_CHECK_RESOURCE,
                         P_SCHEDULED_MEMBER_FLAG  => P_SCHEDULED_MEMBER_FLAG,
			 P_RESOURCE_TYPE	  => L_RESOURCE_TYPE,
                         P_PARTY_ID               => P_PARTY_ID,
                         P_FROM_EMP_NUM           => P_FROM_EMP_NUM,
                         P_TO_EMP_NUM             => P_TO_EMP_NUM,
                         P_ORGANIZATION_ID        => P_ORGANIZATION_ID,
                         P_REFRESH                => P_REFRESH,
                         P_PULL_TERM_RES          => P_PULL_TERM_RES,
                         P_TERM_RANGE_DATE        => P_TERM_RANGE_DATE,
                         P_PERSON_TYPE            => P_PERSON_TYPE,
                         P_START_DATE             => P_START_DATE, -- Bug 5337454
			 -- Added parameters for PJR Resource Pull Enhancements - Bug 5130414
			 P_SELECTION_OPTION       => P_SELECTION_OPTION,
			 P_ORG_STR_VERSION_ID     => P_ORG_STR_VERSION_ID,
			 P_START_ORGANIZATION_ID  => P_START_ORGANIZATION_ID,
			 -- End of parameters added for PJR Resource Pull Enhancements - Bug 5130414
			 X_RETURN_STATUS	  => L_RETURN_STATUS,
			 X_RESOURCE_ID		  => X_RESOURCE_ID );
	--dbms_output.put_line('after private X_RETURN STATUS ' || x_return_status);

	IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           pa_debug.g_err_stage := 'Log: After private API - Create_Resource'; --For bug 4345198
	   pa_debug.write_file('CREATE_RESOURCE: ' || 'LOG',pa_debug.g_err_stage);
	END IF;

	IF fnd_api.to_boolean(l_commit) THEN
		COMMIT WORK;
	END IF;

        x_return_status := L_RETURN_STATUS;
	l_msg_count     :=  FND_MSG_PUB.Count_Msg;

	--dbms_output.put_line('MSG COUNT '||l_msg_count);

	IF l_msg_count = 1 THEN

		pa_interface_utils_pub.get_messages(
			-- p_encoded	=> FND_API.G_FALSE --  FND_API.G_TRUE   : Bug 7369682 : To get translated message
                        --p_encoded	=> FND_API.G_TRUE   -- Bug 7690604 : Changed back this to FND_API.G_TRUE
                        p_encoded	=> FND_API.G_FALSE  -- Bug 8342225: Changed this to FND_API.G_FALSE
			,p_msg_index    => 1
			,p_msg_count	=> l_msg_count
			,p_msg_data	=> x_msg_data
                        ,p_data         => l_data --: Bug 7369682 : Message is returned by p_data, Not p_msg_data
                        ,p_msg_index_out => l_msg_index_out);

		x_msg_count := l_msg_count;
                x_msg_data  := l_data; -- Bug 8342225: Assigning the l_data value to the output x_msg_data
		--dbms_output.put_line('X_RETURN STATUS ' || x_return_status);
	ELSE
		x_msg_count := l_msg_count;
	END IF;

        IF P_DEBUG_MODE = 'Y' THEN --For bug 4345198
	   --Reset the error stack when returning to the calling program
	   PA_DEBUG.Reset_Err_Stack;
        END IF;


 EXCEPTION
    WHEN fnd_api.g_exc_error THEN
	IF (p_commit = FND_API.G_TRUE) THEN
		ROLLBACK TO res_pub_create_resource;
	END IF;
	-- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_R_PROJECT_RESOURCES_PUB'
                                ,p_procedure_name => 'CREATE_RESOURCE');
        x_return_status := FND_API.G_RET_STS_ERROR ;

    WHEN OTHERS THEN
	 --DBMS_OUTPUT.put_line (' =============== ');
	 --DBMS_OUTPUT.put_line (' Raised Others in Create Resource Public');
	 --DBMS_OUTPUT.put_line (SQLCODE || SQLERRM);

	IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	   pa_debug.write_file('LOG','*****Public API - Create_Resource exception: Others*****');
	   pa_debug.write_file('CREATE_RESOURCE: ' || 'LOG', SQLERRM);
	   pa_debug.write_file('CREATE_RESOURCE: ' || 'LOG',pa_debug.g_err_stack);
	   pa_debug.write_file('CREATE_RESOURCE: ' || 'LOG',pa_debug.g_err_stage);
	END IF;

	IF (p_commit = FND_API.G_TRUE) THEN
		ROLLBACK TO res_pub_create_resource;
	END IF;

	-- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_R_PROJECT_RESOURCES_PUB'
                                ,p_procedure_name => 'CREATE_RESOURCE');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

 END CREATE_RESOURCE;


END PA_R_PROJECT_RESOURCES_PUB;

/
