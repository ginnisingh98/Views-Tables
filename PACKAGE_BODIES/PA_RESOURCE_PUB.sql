--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_PUB" AS
/*$Header: PAPMREPB.pls 120.2 2005/08/19 16:43:11 mwasowic noship $*/
-- -------------------------------------------------------------------------------------------------------
-- 	Globals
-- -------------------------------------------------------------------------------------------------------

   G_LAST_UPDATED_BY	NUMBER(15) 	:= FND_GLOBAL.USER_ID;
   G_LAST_UPDATE_DATE        	DATE       	:= SYSDATE;
   G_CREATION_DATE           	DATE       	:= SYSDATE;
   G_CREATED_BY              	NUMBER(15) 	:= FND_GLOBAL.USER_ID;
   G_LAST_UPDATE_LOGIN       	NUMBER(15) 	:= FND_GLOBAL.LOGIN_ID;

-- -------------------------------------------------------------------------------------------------------
-- 	Procedures and Functions
-- -------------------------------------------------------------------------------------------------------

-- FORWARD DECLARATION  ---------------------------------------------------------------

PROCEDURE Get_Resource_Name
(
 p_resource_type_code           IN VARCHAR2,
 p_resource_attr_value          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_name               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Insert_Members (
   p_resource_list_id           IN  NUMBER,
   p_group_resource_type        IN  VARCHAR2,
   p_resource_type_code         IN  VARCHAR2,
   p_resource_group_alias       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
   p_resource_group_name        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
   p_resource_alias             IN  VARCHAR2,
   p_sort_order                 IN  NUMBER,
   p_enabled_flag               IN  VARCHAR2,
   p_resource_attr_value        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
   p_job_group_id               IN  NUMBER,   --Added for bug 2486405.
   p_parent_member_id          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   p_resource_list_member_id   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   p_track_as_labor_flag       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   p_err_code               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   p_err_stage              IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   p_err_stack              IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   p_return_status             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION Fetch_Resource_list_Member_id
         ( p_resource_list_id  IN NUMBER
           , p_alias             IN VARCHAR2
	) RETURN NUMBER;


-- ===============================================================

--
-- Name:		Create_Resource_list
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure creates a resource list and resource list members.
--
-- Called Subprograms:
--	PA_CREATE_RESOURCE.Create_Resource_List
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--

PROCEDURE Create_Resource_List
(p_commit                 IN 	VARCHAR2 := FND_API.G_FALSE,
 p_init_msg_list          IN 	VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number     IN 	NUMBER,
 p_return_status          OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_msg_count              OUT 	NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data               OUT 	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_resource_list_rec      IN  	resource_list_rec,
 p_resource_list_out_rec  OUT  	NOCOPY resource_list_out_rec, --File.Sql.39 bug 4440895
 p_member_tbl             IN  	member_tbl,
 p_member_out_tbl         OUT  	NOCOPY member_out_tbl --File.Sql.39 bug 4440895
 )
 IS

l_api_version_number      CONSTANT   NUMBER := G_API_VERSION_NUMBER;
l_api_name                CONSTANT   VARCHAR2(30) := 'Create_Resource_List';
l_value_conversion_error  BOOLEAN                 := FALSE;
l_resource_list_rec       resource_list_rec;
l_member_tbl              member_tbl;
l_return_status           VARCHAR2(1);
l_err_code                NUMBER := 0;
l_err_stage               VARCHAR2(2000);
l_err_stack               VARCHAR2(2000);
l_resource_list_id        NUMBER;
l_end_date		  DATE;
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;


BEGIN

       SAVEPOINT Create_Resource_List_Pub;

   IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    p_return_status := FND_API.g_ret_sts_success;

    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_CREATE_RESOURCE_LIST',
       p_msg_count	    => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    	  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    	  THEN
			RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
  	   FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
	   FND_MSG_PUB.ADD;
	   p_resource_list_out_rec.return_status:= FND_API.G_RET_STS_ERROR;
           p_return_status := FND_API.g_ret_sts_error;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

       -- l_resource_list_rec.return_status := FND_API.g_ret_sts_success;
       IF p_resource_list_rec.end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_end_date := NULL;
       ELSE
          l_end_date := p_resource_list_rec.end_date;
       END IF;

       PA_CREATE_RESOURCE.Create_Resource_List
       (
        p_resource_list_name   => p_resource_list_rec.resource_list_name,
        p_description          => p_resource_list_rec.description,
        p_group_resource_type  => p_resource_list_rec.group_resource_type,
        p_start_date           => p_resource_list_rec.start_date,
        p_end_date             => l_end_date,
	p_job_group_id         => p_resource_list_rec.job_group_id,   --Added for bug 2486405.
        p_resource_list_id     => l_resource_list_id,
        p_err_code             => l_err_code,
        p_err_stage            => l_err_stage,
        p_err_stack            => l_err_stack
         );

       IF l_err_code > 0  THEN
	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	          	IF NOT pa_project_pvt.check_valid_message (l_err_stage) THEN
	             		FND_MESSAGE.SET_NAME ('PA','PA_ERR_IN_RES_LIST_CREATION');
	          	ELSE
            			FND_MESSAGE.SET_NAME('PA',l_err_stage);
	          	END IF;
          		FND_MSG_PUB.ADD;
	END IF;
	RAISE  FND_API.G_EXC_ERROR;
       END IF;
       IF   l_err_code < 0  THEN
	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
          		FND_MSG_PUB.Add_Exc_Msg
			( p_pkg_name		=>	'G_PKG_NAME'
			, p_procedure_name	=>	'CREATE_RESOURCE_LIST'
			, p_error_text		=>	'ORA-'||LPAD(SUBSTR(l_err_code, 2), 5, '0')
			 );

	END IF;
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

 Process_Members
           (p_return_status       => l_return_status,
            p_resource_list_id    => l_resource_list_id,
            p_member_tbl          => p_member_tbl,
            p_group_resource_type => p_resource_list_rec.group_resource_type,
            p_job_group_id        => p_resource_list_rec.job_group_id,   --Added for bug 2486405.
            p_msg_count           => p_msg_count,
            p_msg_data            => p_msg_data,
            p_member_out_tbl      => p_member_out_tbl
	);

       IF  l_return_status = FND_API.g_ret_sts_success THEN
           p_resource_list_out_rec.return_status :=  FND_API.g_ret_sts_success;
           p_resource_list_out_rec.resource_list_id := l_resource_list_id;
       ELSE
           	p_resource_list_out_rec.return_status := l_return_status;
       	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        		RAISE FND_API.G_EXC_ERROR;
     	END IF;
        END IF;

       IF FND_API.to_boolean( p_commit )
       THEN
        	COMMIT;
       END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        p_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO Create_Resource_List_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO Create_Resource_List_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

     WHEN OTHERS  THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO Create_Resource_List_Pub;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

 	            FND_MSG_PUB.Add_Exc_Msg
	            (   p_pkg_name              =>  G_PKG_NAME ,
              		  p_procedure_name        =>  l_api_name
	    	);

         END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

END Create_Resource_List;
-- ================================================================

--
-- Name:		Process_Members
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure creates resource list members for a given resource list.
--
-- Called Subprograms:
--	Insert_Members
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--

PROCEDURE Process_Members
(p_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_resource_list_id       IN  NUMBER   		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_member_tbl             IN  member_tbl,
 p_group_resource_type    IN  VARCHAR2 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_job_group_id           IN  NUMBER,            --Added for bug 2486405.
 p_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_member_out_tbl         OUT NOCOPY member_out_tbl  --File.Sql.39 bug 4440895
)

IS

l_member_tbl              member_tbl;
l_return_status           VARCHAR2(1);
l_err_code                NUMBER := 0;
l_err_stage               VARCHAR2(2000);
l_err_stack               VARCHAR2(2000);
l_person_id               NUMBER;
l_job_id                  NUMBER;
l_proj_organization_id    NUMBER;
l_vendor_id               NUMBER;
l_expenditure_type        VARCHAR2(30);
l_event_type              VARCHAR2(30);
l_expenditure_category    VARCHAR2(30);
l_revenue_category_code   VARCHAR2(30);
l_resource_list_member_id NUMBER;
l_parent_member_id        NUMBER;
l_track_as_labor_flag     VARCHAR2(1);
l_group_resource_type     VARCHAR2(30);
l_api_name                CONSTANT   VARCHAR2(30) := 'Process_Members ';

BEGIN

       SAVEPOINT  Process_Members_Pub;

       p_return_status := FND_API.g_ret_sts_success;

       --IF p_group_resource_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR or
       --   p_group_resource_type IS NULL THEN
       --   NULL;
       --   Get_Group_resource_type(p_resource_list_id,
       --   l_group_resource_type);
       --ELSE
             l_group_resource_type := p_group_resource_type;
       --END IF;


       FOR i IN 1..p_member_tbl.COUNT LOOP
            p_member_out_tbl(i).return_status := FND_API.g_ret_sts_success;
            l_parent_member_id  := NULL;
            l_resource_list_member_id  := NULL;
            l_track_as_labor_flag  := NULL;
            l_err_code   := NULL;
            l_err_stack  := NULL;
            l_err_stage  := NULL;

            Insert_Members (
             p_resource_list_id          => p_resource_list_id,
             p_group_resource_type       => p_group_resource_type,
             p_resource_type_code        =>
                   p_member_tbl(i).resource_type_code,
             p_resource_group_alias      =>
                   p_member_tbl(i).resource_group_alias,
             p_resource_group_name       =>
                   p_member_tbl(i).resource_group_name,
             p_resource_alias            => p_member_tbl(i).resource_alias,
             p_sort_order                => p_member_tbl(i).sort_order,
             p_enabled_flag              => p_member_tbl(i).enabled_flag,
             p_resource_attr_value       =>
                   p_member_tbl(i).resource_attr_value,
             p_job_group_id              => p_job_group_id,         --Added for bug 2486405.
             p_parent_member_id          => l_parent_member_id,
             p_resource_list_member_id   => l_resource_list_member_id,
             p_track_as_labor_flag       => l_track_as_labor_flag,
             p_err_code                  => l_err_code,
             p_err_stage                 => l_err_stage,
             p_err_stack                 => l_err_stack,
             p_return_status             => l_return_status );

             IF l_err_code > 0  THEN
	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
             		IF NOT pa_project_pvt.check_valid_message (l_err_stage) THEN
	                   	FND_MESSAGE.SET_NAME ('PA','PA_ERR_IN_RL_MEMB_CREATION');
              		  ELSE
                  		FND_MESSAGE.SET_NAME('PA',l_err_stage);
                	END IF;
                   	FND_MSG_PUB.ADD;
	END IF;
              RAISE  FND_API.G_EXC_ERROR;

             ELSIF
                l_err_code < 0 THEN
	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
          		FND_MSG_PUB.Add_Exc_Msg
			( p_pkg_name		=>	'G_PKG_NAME'
			, p_procedure_name	=>	'PROCESS_MEMBERS'
			, p_error_text		=>	'ORA-'||LPAD(SUBSTR(l_err_code, 2), 5, '0')
			 );
	END IF;
                p_member_out_tbl(i).return_status
                  := FND_API.g_ret_sts_unexp_error;
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF
                l_err_code = 0 THEN
                p_member_out_tbl(i).return_status :=
                FND_API.g_ret_sts_success;
                p_member_out_tbl(i).resource_list_member_id :=
                                    l_resource_list_member_id;
            END IF;
     END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO Process_Members_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO Process_Members_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

    WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO Process_Members_Pub;

        IF FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME                  ,
                p_procedure_name        =>  l_api_name
            );

        END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

END Process_Members;
--  ================================================================
--
-- Name:		Insert_Members
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure inserts members in the PA_RESOURCE_LIST_MEMBERS
--		table.
--
-- Called Subprograms:	PA_CREATE_RESOURCE.Create_Resource_list_member
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--      26-APR-99       Update  risingh added call to get_resource_name
--      12-FEB-03       Update  sacgupta  Added job_group_id parameter to the
--                                        procedure.

PROCEDURE Insert_Members (
   p_resource_list_id           IN  NUMBER,
   p_group_resource_type        IN  VARCHAR2,
   p_resource_type_code         IN  VARCHAR2,
   p_resource_group_alias       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
   p_resource_group_name        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
   p_resource_alias	        IN  VARCHAR2,
   p_sort_order                 IN  NUMBER,
   p_enabled_flag               IN  VARCHAR2,
   p_resource_attr_value        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
   p_job_group_id               IN  NUMBER,   --Added for bug 2486405.
   p_parent_member_id          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   p_resource_list_member_id   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   p_track_as_labor_flag       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   p_err_code               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   p_err_stage              IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   p_err_stack              IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   p_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS
l_err_code                NUMBER := 0;
l_err_stage               VARCHAR2(2000);
l_err_stack               VARCHAR2(2000);
l_person_id               NUMBER;
l_job_id                  NUMBER;
l_proj_organization_id    NUMBER;
l_vendor_id               NUMBER;
l_expenditure_type        VARCHAR2(30);
l_event_type              VARCHAR2(30);
l_expenditure_category    VARCHAR2(30);
l_revenue_category_code   VARCHAR2(30);
l_resource_list_member_id NUMBER;
l_parent_member_id        NUMBER;
l_track_as_labor_flag     VARCHAR2(1);
l_api_name              CONSTANT    VARCHAR2(30):=  'Insert_Members';
l_resource_group_name     VARCHAR2(80);
l_resource_name           VARCHAR2(240); -- Bug 2487415

CURSOR l_org_csr IS
SELECT organization_id
FROM   pa_organizations_res_v
WHERE  organization_name = l_resource_group_name;


BEGIN
            p_return_status :=  FND_API.g_ret_sts_success;

	IF ((p_resource_alias  IS NULL )  OR
           (p_resource_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) THEN
		FND_MESSAGE.SET_NAME('PA','PA_NEW_ALIAS_IS_INVALID ');
	  	FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
   	END IF;

            l_person_id  := NULL;
            l_job_id  := NULL;
            l_proj_organization_id  := NULL;
            l_vendor_id  := NULL;
            l_expenditure_type  := NULL;
            l_event_type  := NULL;
            l_expenditure_category  := NULL;
            l_revenue_category_code  := NULL;
            IF p_resource_type_code = 'EMPLOYEE' THEN
               l_person_id := TO_NUMBER(p_resource_attr_value);
            ELSIF  p_resource_type_code = 'JOB' THEN
               l_job_id := TO_NUMBER(p_resource_attr_value);
            ELSIF  p_resource_type_code = 'ORGANIZATION' THEN
               l_proj_organization_id :=
                 TO_NUMBER(p_resource_attr_value);
            ELSIF  p_resource_type_code = 'VENDOR' THEN
               l_vendor_id := TO_NUMBER(p_resource_attr_value);
            ELSIF  p_resource_type_code = 'EXPENDITURE_TYPE'
                   THEN l_expenditure_type :=
                   p_resource_attr_value;
            ELSIF  p_resource_type_code = 'EVENT_TYPE' THEN
               l_event_type := p_resource_attr_value;
            ELSIF  p_resource_type_code =
                   'EXPENDITURE_CATEGORY' THEN
               l_expenditure_category := p_resource_attr_value;
            ELSIF  p_resource_type_code =
                   'REVENUE_CATEGORY' THEN
               l_revenue_category_code := p_resource_attr_value;
            END IF;
            l_parent_member_id  := NULL;
            l_resource_list_member_id  := NULL;
            l_track_as_labor_flag  := NULL;
            l_err_code   := NULL;
            l_err_stack  := NULL;
            l_err_stage  := NULL;

            IF p_group_resource_type = 'EXPENDITURE_CATEGORY'
               THEN
               l_expenditure_category := p_resource_group_alias;
            ELSIF
                p_group_resource_type = 'REVENUE_CATEGORY'
               THEN
               l_revenue_category_code := p_resource_group_alias;
            ELSIF
                p_group_resource_type = 'ORGANIZATION'
               THEN
                 IF (p_resource_group_alias IS NULL OR
                     p_resource_group_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
                     l_resource_group_name := p_resource_group_name;
                 ELSE
                     l_resource_group_name := p_resource_group_name;
                 END IF;
                 OPEN l_org_csr;
                 FETCH l_org_csr INTO l_proj_organization_id;
                 IF l_org_csr%NOTFOUND THEN
		IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
		    FND_MESSAGE.SET_NAME('PA','PA_INVALID_ORGANIZATION');
	  	    FND_MSG_PUB.ADD;
		END IF;
                    CLOSE l_org_csr;
		    RAISE FND_API.G_EXC_ERROR;
                 ELSE
                    CLOSE l_org_csr;
                 END IF;
            END IF;

-- Begin fix 864942 Risingh 04/24/99

            Get_Resource_Name(
             p_resource_type_code   => p_resource_type_code,
             p_resource_attr_value  => p_resource_attr_value,
             p_resource_name        => l_resource_name,
             p_return_status        => p_return_status);

-- End fix 864942

            PA_CREATE_RESOURCE.Create_Resource_list_member (
             p_resource_list_id     => p_resource_list_id,
             p_resource_name        => l_resource_name, -- fix 864942
             p_resource_type_Code   => p_resource_type_code,
             p_alias                => p_resource_alias,
             p_sort_order           => p_sort_order,
             p_display_flag         => 'Y',
             p_enabled_flag         => p_enabled_flag,
             p_person_id            => l_person_id,
             p_job_id               => l_job_id,
             p_proj_organization_id => l_proj_organization_id,
             p_vendor_id            => l_vendor_id,
             p_expenditure_type     => l_expenditure_type,
             p_event_type           => l_event_type,
             p_expenditure_category => l_expenditure_category,
             p_revenue_category_code  => l_revenue_category_code,
             p_non_labor_resource    => NULL,
             p_system_linkage        => NULL,
             p_job_group_id          => p_job_group_id,                  -- Added for bug 2486405.
             p_parent_member_id      => l_parent_member_id,
             p_resource_list_member_id => l_resource_list_member_id,
             p_track_as_labor_flag    => l_track_as_labor_flag,
             p_err_code              => l_err_code,
             p_err_stage             => l_err_stage,
             p_err_stack             => l_err_stack );

             p_parent_member_id := l_parent_member_id;
             p_resource_list_member_id := l_resource_list_member_id;
             p_track_as_labor_flag  := l_track_as_labor_flag;
             p_err_code             := l_err_code;
             p_err_stage	    := l_err_stage;
             p_err_stack            := l_err_stack;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
         p_return_status := FND_API.G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


    WHEN OTHERS THEN
        /* Added the if condition block for bug 2259703 */
         IF NVL(p_err_code,0) = 0 THEN
             p_err_code := SQLCODE;
         END IF;

 	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME                  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;

END Insert_Members;
--  ================================================================

--
-- Name:		Init_Create_Resource_List
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure initializes the global tables for resource lists and
--		resource list members.
--
-- Called Subprograms:	None.
--
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	08-DEC-96	Update	jwhite	Applied latest standards and merged
--					a 'init_create_members' API with this
--					API as per Ashwani's direction.
--

PROCEDURE Init_Create_Resource_List  IS

l_api_name                CONSTANT   VARCHAR2(30) := 'Init_Create_Resource_List';

BEGIN
	FND_MSG_PUB.initialize;

-- Initialize Resource List Globals
	g_resource_list_rec     	:= g_miss_resource_list_rec;
	g_resource_list_out_rec 	:= g_miss_resource_list_out_rec;
	g_member_tbl.DELETE;
	g_member_out_tbl.DELETE;
	g_member_tbl_count 	:= 0;

-- Initialize Resource List Members Globals

	g_load_member_tbl.DELETE;
	g_load_member_out_tbl.DELETE;
	g_load_member_tbl_count	 := 0;
	g_load_resource_list_id 	:= 0;

EXCEPTION

WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;


END Init_Create_Resource_List;
-- ==============================================================

--
-- Name:		Load_Resource_List
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure loads the resource list globals.
--
-- Called Subprograms:	None.
--
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	08-DEC-96	Update	jwhite	Applied latest standards
--


PROCEDURE Load_Resource_List
( p_api_version_number     IN  NUMBER,
  p_resource_list_name     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_description            IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_group_resource_type    IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_start_date             IN  DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_end_date               IN  DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_resource_list_id       IN  NUMBER	    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_new_list_name          IN  VARCHAR2	    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_job_group_id           IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,  --Added for bug 2486405.
  p_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
IS

l_api_version_number      CONSTANT   NUMBER := G_API_VERSION_NUMBER;
l_api_name                CONSTANT   VARCHAR2(30) := 'Load_Resource_List';

BEGIN
       p_return_status := FND_API.g_ret_sts_success;

 -- Standard Api compatibility call
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
    THEN
 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

       g_resource_list_rec.resource_list_name  := p_resource_list_name;
       g_resource_list_rec.description         := p_description;
       g_resource_list_rec.group_resource_type := p_group_resource_type;
       g_resource_list_rec.start_date          := p_start_date;
       g_resource_list_rec.end_date            := p_end_date;
       g_resource_list_rec.resource_list_id    := p_resource_list_id;
       g_resource_list_rec.new_list_name       := p_new_list_name;
       g_resource_list_rec.job_group_id        := p_job_group_id;  --Added for bug 2486405.

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


WHEN OTHERS THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;


END Load_Resource_List;
-- ==============================================================

--
-- Name:		Load_Members
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure loads the resource list members globals.
--
-- Called Subprograms:	None.
--
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	08-DEC-96	Update	jwhite	Applied latest standards
--


PROCEDURE Load_Members
( p_api_version_number     IN  NUMBER,
  p_resource_group_alias   IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_group_name    IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_type_code     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_attr_value    IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_alias         IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_member_id IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_new_alias		   IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_sort_order             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_enabled_flag           IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
IS

l_api_version_number      CONSTANT   NUMBER := G_API_VERSION_NUMBER;
l_api_name                CONSTANT   VARCHAR2(30) := 'Load_members';
l_enabled_flag			pa_resource_list_members.enabled_flag%TYPE;
l_sort_order			pa_resource_list_members.sort_order%TYPE;

BEGIN
       p_return_status := FND_API.g_ret_sts_success;

      -- Standard Api compatibility call

       IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME              )
       THEN
 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

-- VALUE LAYER ---------------------------------------------------------------

-- Default Sort Order if  Parameter NOT Passed

      IF (p_sort_order = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
	l_sort_order := NULL;
      ELSE
	l_sort_order := p_sort_order;
      END IF;


-- Default Enabled Flag if Parameter NOT Passed

       IF (p_enabled_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
	l_enabled_flag := 'Y';
       ELSE
	l_enabled_flag := p_enabled_flag;
       END IF;

-- Assign Globals
       g_member_tbl_count             := g_member_tbl_count + 1;
       g_member_tbl(g_member_tbl_count).resource_group_alias
                   := p_resource_group_alias;
       g_member_tbl(g_member_tbl_count).resource_group_name
                   := p_resource_group_name ;
       g_member_tbl(g_member_tbl_count).resource_type_code
                   := p_resource_type_code;
       g_member_tbl(g_member_tbl_count).resource_attr_value
                   := p_resource_attr_value;
       g_member_tbl(g_member_tbl_count).resource_alias
                   := p_resource_alias;
       g_member_tbl(g_member_tbl_count).sort_order
                   := l_sort_order ;
       g_member_tbl(g_member_tbl_count).enabled_flag
                   := l_enabled_flag;
      g_member_tbl(g_member_tbl_count).new_alias
                   := p_new_alias;
      g_member_tbl(g_member_tbl_count).resource_list_member_id
                   := p_resource_list_member_id;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


WHEN OTHERS THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;


END Load_Members;
-- ==============================================================

--
-- Name:		Exec_Create_Resource_List
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure passes the PL/SQL globals to the Create_Resource_List
--		API. The API is typically used with the load-execute-fetch model.
--
-- Called Subprograms:	Create_Resource_List
--
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	08-DEC-96	Update	jwhite	Applied latest standards
--


PROCEDURE Exec_Create_Resource_List
(p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
 p_init_msg_list          IN 	VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number      IN NUMBER,
 p_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
IS

l_api_version_number   CONSTANT NUMBER := G_API_VERSION_NUMBER;
l_api_name             CONSTANT VARCHAR2(30) := 'Exec_Create_Resource_List';
l_message_count        NUMBER;

BEGIN
       p_return_status := FND_API.g_ret_sts_success;

 -- Standard Api compatibility call

       IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
       THEN
 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

      Create_Resource_List
      (p_commit                 => p_commit,
       p_init_msg_list		=> p_init_msg_list,
       p_api_version_number     => p_api_version_number,
       p_return_status          => p_return_status,
       p_msg_count              => p_msg_count,
       p_msg_data               => p_msg_data,
       p_resource_list_rec      => g_resource_list_rec,
       p_resource_list_out_rec  => g_resource_list_out_rec,
       p_member_tbl             => g_member_tbl,
       p_member_out_tbl         => g_member_out_tbl);

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
 THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );


END Exec_Create_Resource_List;
-- ==============================================================

--
-- Name:		Fetch_Resource_List
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure passes returns the return status and new created
--		resource_list_id, if any, from a load-execute-fetch cycle.
--
-- Called Subprograms:	None.
--
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	08-DEC-96	Update	jwhite	Applied latest standards
--


PROCEDURE Fetch_Resource_List
(
 p_api_version_number      IN NUMBER,
 p_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_resource_list_id        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_list_return_status      OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS

l_api_version_number    CONSTANT    NUMBER      := G_API_VERSION_NUMBER;
l_api_name              CONSTANT    VARCHAR2(30):=  'Fetch_Resource_List';
l_msg_count                         INTEGER     :=0;

BEGIN

   p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Get Resource List Out Values

    p_resource_list_id      := g_resource_list_out_rec.resource_list_id;
    p_list_return_status    := g_resource_list_out_rec.return_status;


EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;


END Fetch_Resource_List;
-- ==============================================================

--
-- Name:		Fetch_Members
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure passes returns the return status and new created
--		resource_list_member_id, if any, from a load-execute-fetch cycle
--		for a given index number.
--
-- Called Subprograms:	None.
--
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	08-DEC-96	Update	jwhite	Applied latest standards
--


PROCEDURE Fetch_Members
 ( p_api_version_number      IN NUMBER,
   p_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   p_member_index            IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   p_resource_list_member_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   p_member_return_status    OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

l_api_version_number    CONSTANT    NUMBER      := G_API_VERSION_NUMBER;
l_api_name              CONSTANT    VARCHAR2(30):=  'Fetch_Members';
l_index                 NUMBER;

BEGIN

 p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  --  Check Line index value

    IF p_member_index = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
         l_index := 1;
    ELSE
         l_index := p_member_index ;
    END IF;

    --  Check whether an entry exists in the G_member_tbl or not.
    --  If there is no entry with that index , then do nothing

     IF NOT g_member_tbl.EXISTS(l_index) THEN
	 p_resource_list_member_id := NULL;
	p_member_return_status    := NULL;
     ELSE
        p_resource_list_member_id :=
          g_member_out_tbl(l_index).resource_list_member_id;
        p_member_return_status    :=
          g_member_out_tbl(l_index).return_status;
     END IF;


EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;


END Fetch_Members;
-- ==============================================================

--
-- Name:		Clear_Create_Resource_List
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure initializes the global tables for resource lists and
--		resource list members.
--
-- Called Subprograms:	None.
--
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	08-DEC-96	Update	jwhite	Applied latest standards and merged
--					a 'clear_create_members' API with this
--					API as per Ashwani's direction.
--


PROCEDURE Clear_Create_Resource_List  IS
BEGIN
	init_create_resource_list;
END Clear_Create_Resource_List;
-- ==============================================================

--
-- Name:		Update_Resource_List
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure updates an existing reource list.
--
-- Called Subprograms:	None.
--
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	08-DEC-96	Update	jwhite	Applied latest standards
--

PROCEDURE Update_Resource_List
(p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number       IN  NUMBER,
 p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
 p_return_status            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_msg_count                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_resource_list_name       IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_list_id         IN  NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_new_list_name            IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_grouped_by_type          IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_description              IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_start_date               IN  DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_end_date                 IN  DATE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_member_tbl               IN  member_tbl,
 p_member_out_tbl           OUT NOCOPY member_out_tbl  --File.Sql.39 bug 4440895
)
IS

l_api_version_number   	CONSTANT NUMBER := G_API_VERSION_NUMBER;
l_api_name             	CONSTANT VARCHAR2(30) := 'Update_Resource_List';
l_message_count        	NUMBER;

--version of add_resource_list_member with which this API is compatible
l_version_add_member	NUMBER := G_API_VERSION_NUMBER;

--version of update_resource_list_member with which this API is compatible
l_version_update_member NUMBER := G_API_VERSION_NUMBER;

l_resource_list_id			NUMBER	:= 0;
l_return_status 			VARCHAR2(1);
l_dummy			VARCHAR2(1);
l_cursor				NUMBER;
l_rows				NUMBER;
l_statement			VARCHAR2(2000);
l_update_header_flag		VARCHAR2(1);
l_update_member_flag		VARCHAR2(1);
l_resource_type_id		NUMBER;
l_resource_list_member_id	NUMBER;

l_rowid_old			VARCHAR2(20) := NULL;
l_start_date_active_old		pa_resource_lists.start_date_active%TYPE;
l_end_date_active_old		pa_resource_lists.end_date_active%TYPE;
l_name_old			pa_resource_lists.name%TYPE;
l_group_resource_type_id_old	pa_resource_lists.group_resource_type_id%TYPE;
l_description_old			pa_resource_lists.description%TYPE;
l_msg_count				NUMBER ;
l_msg_data				VARCHAR2(2000);
l_function_allowed			VARCHAR2(1);
l_resp_id				NUMBER := 0;



-- Check Uniqueness of  New Resource List Name
CURSOR	l_new_list_name_csr (p_new_list_name VARCHAR2)
IS
SELECT	'x'
FROM		pa_resource_lists rl
WHERE		rl.name = p_new_list_name;


-- FIX, 12-FEB-97, jwhite:
-- Modified cursor to ignore Unclassified members
-- ------------------------------------------------------------------------------------
-- Validate Grouped By Type (Cannot Change List Group By if
--	Classified Members Exist)
CURSOR	l_grouped_by_type_csr (l_resource_list_id NUMBER)
IS
SELECT	'x'
FROM 		sys.dual
WHERE		EXISTS
		(SELECT 'x'
		FROM pa_resource_list_members rlm
			, pa_resources r
			, pa_resource_types rt
	              WHERE
		rlm.resource_list_id = l_resource_list_id
		AND rlm.resource_id = r.resource_id
		AND r.resource_type_id = rt.resource_type_id
		AND rt.resource_type_code <> 'UNCLASSIFIED');
-- ------------------------------------------------------------------------------------

-- Validate Resource Type Id
CURSOR	l_resource_type_csr (p_grouped_by_type VARCHAR2)
IS
SELECT	rta.resource_type_id
FROM		pa_resource_types_active_v rta
WHERE		rta.resource_type_code = p_grouped_by_type;

-- Get Original Updatable Columns on PA_RESOURCE_LISTS

CURSOR	l_orignal_columns_csr (l_resource_list_id NUMBER)
IS
SELECT	rl.name, rl.group_resource_type_id, rl.description, rl.start_date_active, rl.end_date_active,   ROWID
FROM		pa_resource_lists rl
WHERE		rl.resource_list_id = l_resource_list_id;

-- Lock Row of Existing Resource List Before Update

CURSOR	l_lock_row_list_csr (l_rowid_old VARCHAR2)
IS
SELECT	'x'
FROM		pa_resource_lists
WHERE		ROWID = l_rowid_old
FOR UPDATE NOWAIT;



BEGIN

 -- Standard Api compatibility call
       SAVEPOINT Update_Resource_List_Pub;

       IF NOT FND_API.Compatible_API_Call (  l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
       THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_UPDATE_RESOURCE_LIST',
       p_msg_count	    => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    	  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    	  THEN
			RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
  	   FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
	   FND_MSG_PUB.ADD;
           p_return_status := FND_API.g_ret_sts_error;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF FND_API.to_boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

-- -----------------------------------------------------------------------
-- Resource List HEADER
-- -----------------------------------------------------------------------

	p_return_status :=  FND_API.G_RET_STS_SUCCESS;


-- VALUE LAYER ----------------------------------------------------------------

	Convert_List_name_to_id
     	(	p_resource_list_name    =>  p_resource_list_name,
      		p_resource_list_id      =>  p_resource_list_id,
      		p_out_resource_list_id  =>  l_resource_list_id,
      		p_return_status         =>  l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        		RAISE FND_API.G_EXC_ERROR;
 	END IF;


-- Validate Date  IN Parameters
--  If a start date is passed, it must not be null. If a start is not passed, then the list start date won't be
--  updated at all.
--  The end date can be null.
--   If a start date and end date are passed, then the start date must be not be later than the end date.

IF ((p_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)) THEN
	IF (p_start_date IS NULL) THEN
  		IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
  		THEN
			FND_MESSAGE.SET_NAME('PA','PA_INVALID_START_DATE');
			FND_MSG_PUB.ADD;
   		END IF;
   		RAISE FND_API.G_EXC_ERROR;
	ELSIF  ((p_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
				 AND (p_end_date IS NOT NULL)) THEN
	   	IF (p_start_date > p_end_date)
	   	THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
			FND_MESSAGE.SET_NAME('PA','PA_INVALID_START_DATE');
            			FND_MSG_PUB.ADD;
		   END IF;
        		   RAISE FND_API.G_EXC_ERROR;
	              END IF;
              END IF;
END IF;

-- Validate IN Parameters New Resource List Name and Grouped By Type


-- New List Name Must NOT Be Null

	IF (p_new_list_name IS NULL) THEN
		IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.SET_NAME('PA', 'PA_NEW_RES_LIST_NO_NULL');
            			FND_MSG_PUB.ADD;
		   END IF;
		   RAISE FND_API.G_EXC_ERROR;
	END IF;

-- New List Name Must NOT Already Exist

	IF (p_new_list_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
	         OPEN l_new_list_name_csr (p_new_list_name);
	         FETCH l_new_list_name_csr INTO l_dummy;
	         IF (l_new_list_name_csr %FOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
			FND_MESSAGE.SET_NAME('PA', 'PA_RE_RL_UNIQUE');
            			FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_new_list_name_csr;
		   RAISE FND_API.G_EXC_ERROR;
	          ELSE
		   CLOSE l_new_list_name_csr;
	          END IF;
	END IF;

-- Cannot Change Grouped-By-Type if List Already has Members

	IF (p_grouped_by_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
	         OPEN l_grouped_by_type_csr ( l_resource_list_id);
	         FETCH l_grouped_by_type_csr INTO l_dummy;
	         IF (l_grouped_by_type_csr%FOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
		FND_MESSAGE.SET_NAME('PA', 'PA_NO_CHANGE_GROUP_BY_TYPE');
            			FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_grouped_by_type_csr;
		   RAISE FND_API.G_EXC_ERROR;
	          ELSE
		   CLOSE l_grouped_by_type_csr;
	          END IF;
	END IF;


-- Get Grouped_By_Type Resource_Type_Id

IF (p_grouped_by_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
    IF (p_grouped_by_type = 'NONE') THEN
		l_resource_type_id := 0;
    ELSE
	         OPEN l_resource_type_csr (p_grouped_by_type);
	         FETCH l_resource_type_csr INTO l_resource_type_id;
	         IF (l_resource_type_csr%NOTFOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
			FND_MESSAGE.SET_NAME('PA', 'PA_GROUPED_RT_INVALID');
            			FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_resource_type_csr;
		   RAISE FND_API.G_EXC_ERROR;
	          ELSE
		   CLOSE l_resource_type_csr;
	          END IF;
      END IF;
END IF;

-- Get Original Updatable Columns for Validation and SQL Update Statement Generation

	OPEN 	l_orignal_columns_csr (l_resource_list_id);
	FETCH 	l_orignal_columns_csr INTO l_name_old, l_group_resource_type_id_old, 				l_description_old, l_start_date_active_old, l_end_date_active_old,
		l_rowid_old;
	CLOSE l_orignal_columns_csr;



-- Validate Date  IN Parameters  Against Existing Resource List Row

IF ((p_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
		OR  (p_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE))
 THEN
	IF ((p_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)  AND
		(l_end_date_active_old IS NOT NULL))
	 THEN
	 	IF (p_start_date > l_end_date_active_old)
		THEN
	    	    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		    THEN
			FND_MESSAGE.SET_NAME('PA','PA_INVALID_START_DATE');
            			FND_MSG_PUB.ADD;
		    END IF;
		    RAISE  FND_API.G_EXC_ERROR;
        		END IF;
	END IF;

	IF (p_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
	THEN
	     IF ((p_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
		 AND (p_end_date IS NOT NULL))
	    THEN
	  	IF (l_start_date_active_old > p_end_date)
		THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		    THEN
			  FND_MESSAGE.SET_NAME('PA','PA_INVALID_END_DATE');
            			  FND_MSG_PUB.ADD;
		    END IF;
		    RAISE  FND_API.G_EXC_ERROR;
	  	END IF;
	     END IF;
	END IF;
END IF;


-- BUILD UPDATE SQL Statement for Resourec List Header ---------------------------------------------

	l_update_header_flag	:= 'N';
	l_statement		:= 'UPDATE PA_RESOURCE_LISTS SET ';

--Changes done for SQL BIND VARIABLE by xin liu. 13-May-2003

	IF (p_new_list_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
	AND (nvl(p_new_list_name, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
             nvl(l_name_old,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
	 THEN
		l_statement := l_statement || 'NAME = :xName'||',';
		l_update_header_flag  := 'Y';
	END IF;

	IF (p_grouped_by_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
	AND ( nvl(l_resource_type_id, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
              nvl(l_group_resource_type_id_old,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
	THEN
			l_statement := l_statement || 'GROUP_RESOURCE_TYPE_ID = :xGRTID'||',';
		l_update_header_flag  := 'Y';
	END IF;

	IF (p_description <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
	AND (nvl(p_description, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
             nvl(l_description_old,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
	THEN
		l_statement := l_statement || 'DESCRIPTION =:xDescription' ||',';
		l_update_header_flag  := 'Y';
	END IF;

	IF (p_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
	AND (nvl(p_start_date, PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <> nvl(l_start_date_active_old,
                                                                PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE))
	THEN
		l_statement := l_statement || 'START_DATE_ACTIVE = '||''''||TO_CHAR(p_start_date)||''''||',';
		l_update_header_flag  := 'Y';
	END IF;

	IF (p_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
	AND (nvl(p_end_date, PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <> nvl(l_end_date_active_old,
                                                                PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE))
	THEN
	l_statement := l_statement || 'END_DATE_ACTIVE  = '||''''||TO_CHAR(p_end_date)||''''||',';
		l_update_header_flag  := 'Y';
	END IF;


	IF (l_update_header_flag = 'Y') THEN

		l_statement := l_statement ||'LAST_UPDATE_DATE ='||''''||TO_CHAR(g_last_update_date)||''''||',';
		l_statement := l_statement ||'LAST_UPDATED_BY  ='||''''||TO_CHAR(g_last_updated_by)||''''||',';
		l_statement := l_statement ||'LAST_UPDATE_LOGIN = '||''''||TO_CHAR(g_last_update_login)||'''';

		l_statement := l_statement || '  WHERE RESOURCE_LIST_ID = '|| TO_CHAR(l_resource_list_id);

-- UPDATE Resource List Header ---------------------------------------------------------------------------

-- Lock Row

	OPEN	l_lock_row_list_csr (l_rowid_old);
	CLOSE l_lock_row_list_csr;

-- Execute UPDATE

		l_cursor := dbms_sql.open_cursor;
		dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);

        IF (p_new_list_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        AND (nvl(p_new_list_name, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
             nvl(l_name_old,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
         THEN
                DBMS_SQL.BIND_VARIABLE(l_cursor, ':xName',p_new_list_name );
        END IF;

        IF (p_grouped_by_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        AND ( nvl(l_resource_type_id, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <>
              nvl(l_group_resource_type_id_old,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
        THEN
                DBMS_SQL.BIND_VARIABLE(l_cursor, ':xGRTID',l_resource_type_id );
        END IF;

        IF (p_description <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        AND (nvl(p_description, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
             nvl(l_description_old,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
        THEN
	    	DBMS_SQL.BIND_VARIABLE(l_cursor, ':xDescription', p_description);

        END IF;

		l_rows := dbms_sql.execute(l_cursor);
		IF (dbms_sql.is_open(l_cursor) ) THEN
			dbms_sql.close_cursor(l_cursor);
		END IF;
	END IF;
-- -----------------------------------------------------------------------
-- Resource List MEMBERS
-- -----------------------------------------------------------------------


FOR I IN  1..p_member_tbl.COUNT LOOP

	p_member_out_tbl(i).return_status  := FND_API.G_RET_STS_SUCCESS;

	IF (p_member_tbl(i).resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
		 AND  (p_member_tbl(i).resource_list_member_id IS NOT NULL) THEN

--  Validate Passed Resource_List_Member_id

		Convert_alias_to_id
		(p_resource_list_id	=>  l_resource_list_id
		,p_alias		=>  p_member_tbl(i).resource_alias
		,p_resource_list_member_id	=>  p_member_tbl(i).resource_list_member_id
 		,p_out_resource_list_member_id	=>  l_resource_list_member_id
		,p_return_status        	=>  l_return_status
		);

	ELSE
-- Find Resource_List_Member_Id with Passed Alias and List Id

  l_resource_list_member_id :=  Fetch_Resource_list_member_id (p_resource_list_id => l_resource_list_id,
            			p_alias => p_member_tbl(i).resource_alias );

	END IF;


	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		 p_member_out_tbl(i).return_status := l_return_status;
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
		 p_member_out_tbl(i).return_status := l_return_status;
        		RAISE FND_API.G_EXC_ERROR;
 	END IF;


	IF (l_resource_list_member_id IS NULL)  THEN

-- ADD NEW Resource List Member

    Add_Resource_List_Member
    ( p_commit               	=> FND_API.G_FALSE
     ,p_init_msg_list          	=> FND_API.G_FALSE
     , p_api_version_number    	=> l_version_add_member
     , p_resource_list_id      	=> l_resource_list_id
     , p_resource_group_alias   => p_member_tbl(i).resource_group_alias
     , p_resource_group_name    => p_member_tbl(i).resource_group_name
     , p_resource_type_code	=> p_member_tbl(i).resource_type_code
     , p_resource_attr_value	=> p_member_tbl(i).resource_attr_value
     , p_resource_alias		=> p_member_tbl(i).resource_alias
     , p_sort_order 		=> p_member_tbl(i).sort_order
     , p_enabled_flag 		=> p_member_tbl(i).enabled_flag
     , p_resource_list_member_id =>
       p_member_out_tbl(i). resource_list_member_id
     , p_msg_count 		=> p_msg_count
     , p_msg_data 		=> p_msg_data
     , p_return_status         	=> p_member_out_tbl(i).return_status
	);

		IF (p_member_out_tbl(i).return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     		ELSIF (p_member_out_tbl(i).return_status = FND_API.G_RET_STS_ERROR) THEN

	        		RAISE FND_API.G_EXC_ERROR;
 		END IF;


	ELSE
-- UPDATE EXISTING Resource List Member

		p_member_out_tbl(i). resource_list_member_id := 	l_resource_list_member_id;

		Update_Resource_List_Member
		( p_commit               =>	FND_API.G_FALSE
		, p_init_msg_list        =>	FND_API.G_FALSE
		, p_api_version_number   => 	l_version_update_member
		, p_resource_list_id     =>	l_resource_list_id
		, p_resource_list_member_id  =>	l_resource_list_member_id
		, p_new_alias            =>	p_member_tbl(i).new_alias
		, p_sort_order 		 =>	p_member_tbl(i).sort_order
		, p_enabled_flag 	 =>	p_member_tbl(i).enabled_flag
		, p_return_status 	 =>	p_member_out_tbl(i).return_status
		, p_msg_count            =>	p_msg_count
		, p_msg_data 		 =>	p_msg_data
		);


		IF (p_member_out_tbl(i).return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     		ELSIF (p_member_out_tbl(i).return_status = FND_API.G_RET_STS_ERROR) THEN

	        		RAISE FND_API.G_EXC_ERROR;
 		END IF;


	END IF;
END LOOP;



	IF FND_API.to_boolean( p_commit )
	THEN
		COMMIT;
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO Update_Resource_List_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO Update_Resource_List_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

WHEN ROW_ALREADY_LOCKED THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;
        IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED');
	FND_MESSAGE.SET_TOKEN('ENTITY', 'RESOURCE_LIST');
            	FND_MSG_PUB.ADD;
        END IF;

        ROLLBACK TO Update_Resource_List_Mbr_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );


    WHEN OTHERS THEN

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	ROLLBACK TO Update_Resource_List_Pub;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );

        END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

END Update_Resource_List;
-- ===============================================================
--
-- Name:		Init_Update_Members
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure initlializes the resource list members globals for the
--		Update_Resource_List load-execute-fetch cycle.
--
-- Called Subprograms:
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--


PROCEDURE Init_Update_Members IS

l_api_name                CONSTANT   VARCHAR2(30) := 'Init_Update_Members';

BEGIN

g_member_tbl.DELETE;
g_member_out_tbl.DELETE;
g_update_member_tbl_count := 0;
g_update_resource_list_id := 0;

EXCEPTION

WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;

END Init_Update_Members;
-- ===============================================================
--
-- Name:		Exec_Update_Resource_List
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure executes the Update_Resource_List API.
--
-- Called Subprograms:	Update_Resource_List
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--


PROCEDURE Exec_Update_Resource_List
(p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list          IN 	VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number      IN NUMBER,
 p_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data                OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS

l_api_version_number   	CONSTANT 	NUMBER := G_API_VERSION_NUMBER;
l_api_name             	CONSTANT 	VARCHAR2(30) := 'Exec_Update_Resource_List';
l_message_count        			NUMBER;

BEGIN

       p_return_status := FND_API.g_ret_sts_success;

 -- Standard Api compatibility call

       IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
       THEN
 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;



      Update_Resource_List
      (p_commit                 => p_commit,
       p_init_msg_list		=> p_init_msg_list,
       p_api_version_number     => p_api_version_number,
       p_return_status          => p_return_status,
       p_msg_count              => p_msg_count,
       p_msg_data               => p_msg_data,
       p_resource_list_id	=> g_resource_list_rec.resource_list_id,
       p_resource_list_name 	=> g_resource_list_rec.resource_list_name,
       p_new_list_name	 	=> g_resource_list_rec.new_list_name,
       p_grouped_by_type 	=> g_resource_list_rec.group_resource_type,
       p_description 	 	=> g_resource_list_rec.description,
       p_start_date		=> g_resource_list_rec.start_date,
       p_end_date  	 	=> g_resource_list_rec.end_date,
       p_member_tbl             => g_member_tbl,
       p_member_out_tbl      	=> g_member_out_tbl);

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
 THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN

         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

END Exec_Update_Resource_List;
-- ===============================================================

--
-- Name:		Clear_Update_Members
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure clears the resource list members globals for the
--		Update_Resource_List load-execute-fetch cycle.
--
-- Called Subprograms:	Init_Update_Members
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--

PROCEDURE Clear_Update_Members IS
BEGIN
  Init_Update_Members;
END Clear_Update_Members;
-- ===============================================================

--
-- Name:		Delete_Resource_List
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure deletes a resource list and its unclassified members.
--
-- Called Subprograms:
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
-- 02-OCT-98   Updated  jxnaraya validations for deletion modified


PROCEDURE Delete_Resource_list
( p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
  p_api_version_number     IN  NUMBER,
  p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
  p_resource_list_name     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_id       IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_err_code               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_err_stage              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
 IS
l_api_version_number   	CONSTANT NUMBER := G_API_VERSION_NUMBER;
l_api_name             	CONSTANT VARCHAR2(30) := 'Delete_Resource_List';
l_message_count        		NUMBER;

l_resource_list_id			NUMBER	:= 0;
l_return_status 			VARCHAR2(1);
l_dummy			VARCHAR2(1);
l_resource_list_member_id	NUMBER	:= 0;
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;


-- LOCK Row of Existing Resource List Before DELETE

CURSOR	l_lock_row_list_csr (l_resource_list_id NUMBER)
IS
SELECT	'x'
FROM		pa_resource_lists rl
WHERE		rl.resource_list_id = l_resource_list_id
FOR UPDATE NOWAIT;

BEGIN

	SAVEPOINT Delete_Resource_List_Pub;

-- Standard Api compatibility call

       IF NOT FND_API.Compatible_API_Call (  l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
       THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_DELETE_RESOURCE_LIST',
       p_msg_count	    => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    	  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    	  THEN
			RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
  	   FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
	   FND_MSG_PUB.ADD;
           p_return_status := FND_API.g_ret_sts_error;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF FND_API.to_boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
        	END IF;

	p_return_status :=  FND_API.G_RET_STS_SUCCESS;


-- VALUE LAYER ---------------------------------------------------------------

	Convert_List_name_to_id
     	(	p_resource_list_name    =>  p_resource_list_name,
      		p_resource_list_id      =>  p_resource_list_id,
      		p_out_resource_list_id  =>  l_resource_list_id,
      		p_return_status         =>  l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        		RAISE FND_API.G_EXC_ERROR;
 	END IF;

-- VALIDATION LAYER ---------------------------------------------------------

   x_err_code := 0;

   PA_GET_RESOURCE.delete_resource_list_ok(
                   l_resource_list_id => l_resource_list_id,
                   x_err_code         => x_err_code,
                   x_err_stage        => x_err_stage);
   IF x_err_code <> 0 THEN
      IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('PA', x_err_stage);
            FND_MSG_PUB.ADD;
      END IF;
      RAISE  FND_API.G_EXC_ERROR;
   END IF;


--	D E L E T E   Resource List  MEMBERS --------------------------------------------------------------

--	Actually, this ONLY deletes UN-classified members.

--	Row-Locking NOT needed as per Ramesh, 12-DEC-96, because the Unclassified resources cannot --	be locked  by users.

	BEGIN

		DELETE
			pa_resource_list_members
		WHERE
			resource_list_id = l_resource_list_id;

		EXCEPTION

		WHEN OTHERS THEN

		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO Delete_Resource_List_Pub;

	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		 THEN
			FND_MESSAGE.SET_NAME('PA','PA_RL_MEMBER_DELETE_ERROR');
			FND_MSG_PUB.ADD;
		END IF;

		FND_MSG_PUB.Count_And_Get
      		  (   p_count         =>  p_msg_count         ,
		            p_data          =>  p_msg_data          );

	END;


--	D E L E T E  RESOURCE LIST -------------------------------------------------------------------------

	BEGIN

		OPEN   l_lock_row_list_csr (l_resource_list_id);
		CLOSE  l_lock_row_list_csr;

		DELETE
			pa_resource_lists
		WHERE
			resource_list_id = l_resource_list_id;

		EXCEPTION

		WHEN ROW_ALREADY_LOCKED THEN

        		p_return_status := FND_API.G_RET_STS_ERROR ;
		ROLLBACK TO Delete_Resource_List_Pub;

		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
			FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED');
			FND_MESSAGE.SET_TOKEN('ENTITY', 'RESOURCE_LIST');
            			FND_MSG_PUB.ADD;
		  END IF;

        		FND_MSG_PUB.Count_And_Get
        		(   p_count         =>  p_msg_count         ,
            		p_data          =>  p_msg_data          );

		WHEN OTHERS THEN

		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO Delete_Resource_List_Pub;

	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		 THEN
			FND_MESSAGE.SET_NAME('PA','PA_RL_DELETE_ERROR');
			FND_MSG_PUB.ADD;
		END IF;

		FND_MSG_PUB.Count_And_Get
      		  (   p_count         =>  p_msg_count         ,
		            p_data          =>  p_msg_data          );

	END;


	IF FND_API.to_boolean( p_commit )
	THEN
		COMMIT;
	END IF;

	FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO Delete_Resource_List_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO Delete_Resource_List_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

    WHEN OTHERS THEN

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	ROLLBACK TO Delete_Resource_List_Pub;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME                  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );


END Delete_Resource_list;
-- ===============================================================

--
-- Name:		Add_Resource_List_Member
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure inserts a new member in the PA_RESOURCE_LIST_MEMBERS
--		table.
--
-- Called Subprograms:	Convert_List_name_to_id
--			, Insert_Members
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--

PROCEDURE Add_Resource_List_Member
(p_commit                  IN VARCHAR2  := FND_API.G_FALSE,
 p_init_msg_list           IN VARCHAR2  := FND_API.G_FALSE,
 p_api_version_number      IN NUMBER,
 p_resource_list_name      IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_list_id        IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_resource_group_alias    IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_group_name     IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_type_code      IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_attr_value     IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_alias          IN VARCHAR2 ,
 p_sort_order              IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_enabled_flag            IN VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_list_member_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_msg_data                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
 IS

l_api_version_number    CONSTANT    NUMBER      :=  G_API_VERSION_NUMBER;
l_api_name              CONSTANT    VARCHAR2(30):=
        'Add_resource_list_member';
l_value_conversion_error            BOOLEAN     :=  FALSE;
l_return_status                     VARCHAR2(1);
l_resource_list_id                  NUMBER;
l_resource_list_member_id	    NUMBER;
l_parent_member_id	            NUMBER;
l_index                             NUMBER;
l_err_code                NUMBER := 0;
l_err_stage               VARCHAR2(2000);
l_err_stack               VARCHAR2(2000);
l_person_id               NUMBER;
l_job_id                  NUMBER;
l_proj_organization_id    NUMBER;
l_vendor_id               NUMBER;
l_expenditure_type        VARCHAR2(30);
l_event_type              VARCHAR2(30);
l_expenditure_category    VARCHAR2(30);
l_revenue_category_code   VARCHAR2(30);
l_track_as_labor_flag     VARCHAR2(1);
l_group_resource_type     VARCHAR2(30);
l_resource_group_name     VARCHAR2(80);
l_resource_group_alias    VARCHAR2(30);
l_group_resource_type_id  NUMBER;
l_sort_order		NUMBER;
l_enabled_flag		pa_resource_list_members.enabled_flag%TYPE;
l_msg_count		NUMBER ;
l_msg_data		VARCHAR2(2000);
l_function_allowed	VARCHAR2(1);
l_resp_id		NUMBER := 0;
l_job_group_id            NUMBER;   -- Added for the bug 2486405.



CURSOR l_resource_list_csr IS
SELECT rl.group_resource_type_id,
       rg.resource_group,
       rl.job_group_id             -- Added for the bug 2486405.
FROM
pa_resource_lists rl,pa_resource_groups_valid_v rg
WHERE rl.resource_list_id = l_resource_list_id
AND   rl.group_resource_type_id = rg.group_resource_type_id;

BEGIN


    SAVEPOINT   Add_Resource_List_Member_Pub;

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    IF FND_API.to_boolean( p_init_msg_list)
    THEN
       FND_MSG_PUB.initialize;
    END IF;

    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_ADD_RESOURCE_LIST_MEMBER',
       p_msg_count	    => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    	  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    	  THEN
			RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
  	   FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
	   FND_MSG_PUB.ADD;
           p_return_status := FND_API.g_ret_sts_error;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


IF p_resource_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
	p_resource_list_member_id := NULL;
	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		FND_MESSAGE.SET_NAME('PA','PA_RL_RES_TYPE_CODE_REQD');
            		FND_MSG_PUB.ADD;
	END IF;
	RAISE  FND_API.G_EXC_ERROR;
 END IF;

IF p_resource_attr_value = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
       IF p_resource_type_code = 'EMPLOYEE'  THEN
          FND_MESSAGE.SET_NAME('PA', 'PA_NO_PERSON_ID');
       ELSIF p_resource_type_code = 'JOB'  THEN
          FND_MESSAGE.SET_NAME('PA', 'PA_NO_JOB_ID');
       ELSIF p_resource_type_code = 'ORGANIZATION'  THEN
          FND_MESSAGE.SET_NAME('PA', 'PA_NO_PROJ_ORG_ID');
       ELSIF p_resource_type_code = 'VENDOR'  THEN
          FND_MESSAGE.SET_NAME('PA', 'PA_NO_VENDOR_ID');
       ELSIF p_resource_type_code = 'EXPENDITURE_TYPE'  THEN
          FND_MESSAGE.SET_NAME('PA', 'PA_NO_EXPENDITURE_TYPE');
       ELSIF p_resource_type_code = 'EVENT_TYPE'  THEN
          FND_MESSAGE.SET_NAME('PA', 'PA_NO_EVENT_TYPE');
       ELSIF p_resource_type_code = 'EXPENDITURE_CATEGORY'  THEN
          FND_MESSAGE.SET_NAME('PA', 'PA_NO_EXPENDITURE_CATEGORY');
       ELSIF p_resource_type_code = 'REVENUE_CATEGORY'  THEN
          FND_MESSAGE.SET_NAME('PA', 'REVENUE_CATEGORY');
       END IF;
       p_resource_list_member_id := NULL;
       FND_MSG_PUB.ADD;
END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

--  Convert the resource list name to resource list id

    Convert_List_name_to_id
     (
      p_resource_list_name    =>  p_resource_list_name,
      p_resource_list_id      =>  p_resource_list_id,
      p_out_resource_list_id  =>  l_resource_list_id,
      p_return_status         =>  l_return_status
      );

 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
 END IF;


-- Get the grouped by resource type of the Resource list
        OPEN l_resource_list_csr;
        FETCH l_resource_list_csr INTO
              l_group_resource_type_id,
              l_group_resource_type,
              l_job_group_id;                -- Added for the bug 2486405.
        IF l_resource_list_csr%NOTFOUND THEN
           CLOSE l_resource_list_csr;
	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
           		FND_MESSAGE.SET_NAME('PA', 'PA_RL_INVALID');
	      	FND_MSG_PUB.ADD;
	END IF;
           RAISE  FND_API.G_EXC_ERROR;
        ELSE
            CLOSE l_resource_list_csr;
        END IF;

            IF l_group_resource_type_id <> 0 AND
               (p_resource_group_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                p_resource_group_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN
	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
                	FND_MESSAGE.SET_NAME('PA', 'PA_RL_GROUPED');
                	FND_MSG_PUB.ADD;
	END IF;
	RAISE  FND_API.G_EXC_ERROR;
            END IF;

	IF (p_sort_order = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
		l_sort_order := NULL;
	ELSE
		l_sort_order := p_sort_order;
	END IF;

	IF (p_enabled_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
		l_enabled_flag := 'Y';
	ELSE
		l_enabled_flag := p_enabled_flag;
	END IF;


             l_resource_group_name  := p_resource_group_name;
             l_resource_group_alias := p_resource_group_alias;

             IF l_group_resource_type_id <> 0 THEN
                IF p_resource_group_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                  l_resource_group_name := p_resource_group_alias;
                ELSIF
                   p_resource_group_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                   l_resource_group_alias := SUBSTR(p_resource_group_name,1,30);
                END IF;
             END IF;

            l_parent_member_id  := NULL;
            l_resource_list_member_id  := NULL;
            l_track_as_labor_flag  := NULL;
            l_err_code   := NULL;
            l_err_stack  := NULL;
            l_err_stage  := NULL;

/* Bug 2259703 Changed the values passed to following two parameters
             p_resource_group_alias      => p_resource_group_alias,
             p_resource_group_name       => p_resource_group_alias,
*/
 Insert_Members (
             p_resource_list_id          => l_resource_list_id,
             p_group_resource_type       => l_group_resource_type,
             p_resource_type_code        => p_resource_type_code,
             p_resource_group_alias      => l_resource_group_alias,
             p_resource_group_name       => l_resource_group_name,
             p_resource_alias            => p_resource_alias,
             p_sort_order                => l_sort_order,
             p_enabled_flag              => l_enabled_flag,
             p_resource_attr_value       => p_resource_attr_value,
             p_job_group_id              => l_job_group_id,         --Added for bug 2486405.
             p_parent_member_id          => l_parent_member_id,
             p_resource_list_member_id   => l_resource_list_member_id,
             p_track_as_labor_flag       => l_track_as_labor_flag,
             p_err_code                  => l_err_code,
             p_err_stage                 => l_err_stage,
             p_err_stack                 => l_err_stack,
             p_return_status             => l_return_status );

	IF l_err_code > 0  THEN
		IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
	                 IF NOT pa_project_pvt.check_valid_message (l_err_stage) THEN
              		    	FND_MESSAGE.SET_NAME ('PA','PA_ERR_IN_RL_MEMB_CREATION');
	                 ELSE
              		    	FND_MESSAGE.SET_NAME ('PA',l_err_stage);
	                 END IF;
              			 FND_MSG_PUB.ADD;
		END IF;
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

            IF l_err_code < 0 THEN
	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
          		FND_MSG_PUB.Add_Exc_Msg
			( p_pkg_name		=>	'G_PKG_NAME'
			, p_procedure_name	=>	'ADD_RESOURCE_LIST_MEMBER'
			, p_error_text		=>	'ORA-'||LPAD(SUBSTR(l_err_code, 2), 5, '0')
			 );

	 END IF;
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

            IF  l_err_code = 0 THEN
               p_return_status := FND_API.g_ret_sts_success;
               p_resource_list_member_id := l_resource_list_member_id;
            END IF;

      IF FND_API.to_boolean( p_commit )
       THEN
        	COMMIT;
       END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO Add_Resource_List_Member_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO Add_Resource_List_Member_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

    WHEN OTHERS THEN

       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       ROLLBACK TO Add_Resource_List_Member_Pub;

        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME                  ,
                p_procedure_name        =>  l_api_name
            );

        END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

END Add_Resource_List_Member;

-- ================================================================

--
-- Name:		Update_Resource_List_Member
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure updates an existing member on the PA_RESOURCE_LIST_MEMBERS
--		table.
--
-- Called Subprograms:	Convert_List_name_to_id
--			, Convert_alias_to_id
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--

PROCEDURE Update_Resource_List_Member
( p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
  p_api_version_number     IN  NUMBER,
  p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
  p_resource_list_name     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_id       IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_resource_alias         IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_member_id IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_new_alias              IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_sort_order             IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_enabled_flag           IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_return_status          OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS

l_api_version_number   CONSTANT NUMBER := G_API_VERSION_NUMBER;
l_api_name             CONSTANT VARCHAR2(30) := 'Update_Resource_List_Member';
l_message_count        NUMBER;

l_resource_list_id			NUMBER	:= 0;
l_return_status 			VARCHAR2(1);
l_dummy			VARCHAR2(1);
l_cursor				INTEGER;
l_rows				NUMBER	:= 0;
l_statement			VARCHAR2(2000);
l_update_member_flag		VARCHAR2(1);
l_resource_list_member_id	NUMBER	:= 0;
l_group_resource_type_id		NUMBER	:= -1;
l_parent_member_id		NUMBER	:= 0;

l_rowid_old			VARCHAR2(20) := NULL;
l_alias_old			pa_resource_list_members.alias%TYPE;
l_sort_order_old			NUMBER	:= 0;
l_enabled_flag_new		pa_resource_list_members.enabled_flag%TYPE;
l_enabled_flag_old		pa_resource_list_members.enabled_flag%TYPE;
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;


--  Get the Group_Resource_Type_Id for the Resource List

CURSOR	l_group_resource_type_csr (l_resource_list_id NUMBER)
IS
SELECT	rl.group_resource_type_id
FROM		pa_resource_lists rl
WHERE		rl.resource_list_id = l_resource_list_id;

-- Find New Alias for a Non-Grouped Resource List

CURSOR	l_new_alias_none_csr (p_new_alias VARCHAR2
					, l_resource_list_id NUMBER)
IS
SELECT	'x'
FROM		pa_resource_list_members rlm
WHERE		rlm.resource_list_id = l_resource_list_id
AND		rlm.alias = p_new_alias;

-- Find Parent Member Id of Resource List Member Id

CURSOR	l_parent_member_csr (l_resource_list_member_id NUMBER)
IS
SELECT	rlm.parent_member_id
FROM		pa_resource_list_members rlm
WHERE		rlm.resource_list_member_id = l_resource_list_member_id;

-- Find New Alias within the Group of the Resource List Member Id

CURSOR	l_new_alias_grouped_csr (p_new_alias VARCHAR2
					, l_parent_member_id NUMBER)
IS
SELECT	'x'
FROM		pa_resource_list_members rlm
WHERE		rlm.parent_member_id = l_parent_member_id
AND		rlm.alias = p_new_alias;

-- Find Original Updatable Columns on PA_RESOURCE_LIST_MEMBERS

CURSOR	l_orignal_columns_csr (l_resource_list_member_id NUMBER)
IS
SELECT	rlm.alias, rlm.sort_order, rlm.enabled_flag, ROWID
FROM		pa_resource_list_members rlm
WHERE		rlm.resource_list_member_id = l_resource_list_member_id;

-- Lock Row of Existing Resource List Member Before Update

CURSOR	l_lock_row_member_csr (l_rowid_old VARCHAR2)
IS
SELECT	'x'
FROM		pa_resource_list_members
WHERE		ROWID = l_rowid_old
FOR UPDATE NOWAIT;



BEGIN

 -- Standard Api compatibility call

       SAVEPOINT Update_Resource_List_Mbr_Pub;

       p_return_status :=  FND_API.G_RET_STS_SUCCESS;

       IF NOT FND_API.Compatible_API_Call (  l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
       THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_UPD_RESOURCE_LIST_MEMBER',
       p_msg_count	    => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    	  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    	  THEN
			RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
  	   FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
	   FND_MSG_PUB.ADD;
           p_return_status := FND_API.g_ret_sts_error;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF FND_API.to_boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
        END IF;

-- VALUE LAYER ----------------------------------------------------------------

	Convert_List_name_to_id
     	(	p_resource_list_name    =>  p_resource_list_name,
      		p_resource_list_id      =>  p_resource_list_id,
      		p_out_resource_list_id  =>  l_resource_list_id,
      		p_return_status         =>  l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        		RAISE FND_API.G_EXC_ERROR;
 	END IF;

   	Convert_alias_to_id
	(	 p_resource_list_id		=> l_resource_list_id
		, p_alias			=> p_resource_alias
		, p_resource_list_member_id	=> p_resource_list_member_id
 		, p_out_resource_list_member_id	=> l_resource_list_member_id
		, p_return_status        	=> l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        		RAISE FND_API.G_EXC_ERROR;
 	END IF;

--	VALIDATE  LAYER ------------------------------------------------------------------------

--	Passed Column-Related Parameters Cannot Be Null

	IF (p_new_alias IS NULL) THEN
		IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.SET_NAME('PA','PA_P_NEW_ALIAS_NO_NULL');
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (p_sort_order IS NULL) THEN
		IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.SET_NAME('PA','PA_P_SORT_ORDER_NO_NULL');
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF (p_enabled_flag IS NULL) THEN
		IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.SET_NAME('PA','PA_P_ENABLED_FLAG_NO_NULL');
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

--	Check Proper Values Passed for P_ENABLED_FLAG.
--	Default Value to 'Y' if NOT Passed at All.

	IF (p_enabled_flag =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
		l_enabled_flag_new := 'Y';
	ELSE
	  IF  (p_enabled_flag  IN ('Y', 'N')) THEN
		l_enabled_flag_new := p_enabled_flag;
	  ELSE
		IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.SET_NAME('PA','PA_ENABLED_FLAG_YES_NO');
            			FND_MSG_PUB.ADD;
		END IF;
        		RAISE FND_API.G_EXC_ERROR;
	  END IF;
	END IF;

--	Check Uniqueness of New Alias
--
--	If a resource list is not grouped, then the new alias must be unique accross the list.
--	Otherwise, a new alias must be unique within the group of the original alias.

	IF (p_new_alias  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

	OPEN l_group_resource_type_csr (l_resource_list_id);
	FETCH l_group_resource_type_csr INTO l_group_resource_type_id;
	CLOSE l_group_resource_type_csr;

	IF (l_group_resource_type_id = 0) THEN
-- Resource List is NOT Grouped. So, new alias must be unique within the entire list.

		OPEN l_new_alias_none_csr (p_new_alias , l_resource_list_id );
		FETCH l_new_alias_none_csr INTO l_dummy;
		IF (l_new_alias_none_csr%FOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
			FND_MESSAGE.SET_NAME('PA','PA_P_NEW_ALIAS_NOT_UNIQUE ');
            			FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_new_alias_none_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		   CLOSE l_new_alias_none_csr;
		END IF;

	ELSE
-- Resource List IS Grouped. So, new alias must be unique within the group of the resource_list_member_id

-- Get Parent_Member_Id (group rlm id) of Resource_List_Member_Id

		OPEN l_parent_member_csr (l_resource_list_member_id );
		FETCH l_parent_member_csr INTO l_parent_member_id;
		CLOSE l_parent_member_csr;

-- Check for Uniqueness within Parent Group of Resource List Member Id.

		OPEN l_new_alias_grouped_csr (p_new_alias , l_parent_member_id );

		FETCH l_new_alias_grouped_csr INTO l_dummy;
		IF (l_new_alias_grouped_csr%FOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
			FND_MESSAGE.SET_NAME('PA','PA_P_NEW_ALIAS_NOT_UNIQUE ');
            			FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_new_alias_grouped_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		   CLOSE l_new_alias_grouped_csr;
		END IF;
	  END IF;
	END IF;

-- BUILD UPDATE SQL STATEMENT for Resource List Member ---------------------------

-- Get Original Updatable Columns for Resource List Member Id

	OPEN	l_orignal_columns_csr (l_resource_list_member_id);
	FETCH l_orignal_columns_csr INTO l_alias_old,  l_sort_order_old, l_enabled_flag_old, 			l_rowid_old;
	CLOSE l_orignal_columns_csr;


	l_update_member_flag	:= 'N';
	l_statement		:= 'UPDATE PA_RESOURCE_LIST_MEMBERS SET ';

	IF (p_new_alias  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
	 AND (NVL(p_new_alias, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> NVL(l_alias_old, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
	THEN
		l_statement := l_statement || 'ALIAS = '||''''||p_new_alias||''''||',';
		l_update_member_flag  := 'Y';
	END IF;

	IF (p_sort_order <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
	AND (NVL(p_sort_order, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <> NVL(l_sort_order_old, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
	THEN
		l_statement := l_statement || 'SORT_ORDER = '||''''||p_sort_order||''''||',';
		l_update_member_flag  := 'Y';
	END IF;

	IF (l_enabled_flag_new <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        AND (NVL(l_enabled_flag_new, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> NVL(l_enabled_flag_old, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR))
	THEN
		l_statement := l_statement || 'ENABLED_FLAG = '||''''|| l_enabled_flag_new ||''''||',';
		l_update_member_flag  := 'Y';
	END IF;

	IF (l_update_member_flag = 'Y') THEN

		l_statement := l_statement ||'LAST_UPDATE_DATE = '||''''||TO_CHAR(g_last_update_date)||''''||',';
		l_statement := l_statement ||'LAST_UPDATED_BY  = '||''''||TO_CHAR(g_last_updated_by)||''''||',';
		l_statement := l_statement ||'LAST_UPDATE_LOGIN =
'||''''||TO_CHAR(g_last_update_login)||'''';

		l_statement := l_statement || '  WHERE RESOURCE_LIST_MEMBER_ID = '|| TO_CHAR(l_resource_list_member_id);

-- UPDATE Resource List Member ---------------------------------------------

-- Lock Row
	OPEN l_lock_row_member_csr (l_rowid_old);
	CLOSE l_lock_row_member_csr;

-- Execute Update

		l_cursor := dbms_sql.open_cursor;
		dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);
		l_rows := dbms_sql.EXECUTE(l_cursor);
		IF (dbms_sql.is_open(l_cursor) ) THEN
			dbms_sql.close_cursor(l_cursor);
		END IF;
	END IF;

       IF FND_API.to_boolean( p_commit )
       THEN
        	COMMIT;
       END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO Update_Resource_List_Mbr_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO Update_Resource_List_Mbr_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count   ,
            p_data          =>  p_msg_data          );

   WHEN ROW_ALREADY_LOCKED THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;
        IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED');
	FND_MESSAGE.SET_TOKEN('ENTITY', 'RESOURCE_LIST_MEMBER');
            	FND_MSG_PUB.ADD;
        END IF;

        ROLLBACK TO Update_Resource_List_Mbr_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );


    WHEN OTHERS THEN

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	ROLLBACK TO Update_Resource_List_Mbr_Pub;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

END Update_Resource_List_Member;
-- ==============================================================

--
-- Name:		Delete_Resource_list_Member
-- Type:		PL/SQL Procedure
-- Decscription:	This procedures deletes a given resource list member id.
--
-- Called Subprograms:
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
-- 02-OCT-98   Update   jxnaraya validations for deletion modified

PROCEDURE Delete_Resource_list_Member
( p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
  p_init_msg_list            IN VARCHAR2 := FND_API.G_FALSE,
  p_api_version_number      IN NUMBER,
  p_resource_list_name     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_id       IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_resource_alias         IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_member_id IN NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_err_code               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_err_stage              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )

IS

l_api_version_number   	CONSTANT 	NUMBER := G_API_VERSION_NUMBER;
l_api_name             	CONSTANT	VARCHAR2(30) := 'Delete_Resource_List_Member';
l_message_count       		 	NUMBER;
l_resource_list_id				NUMBER	:= 0;
l_return_status 				VARCHAR2(1);
l_dummy				VARCHAR2(1);
l_resource_list_member_id		NUMBER	:= 0;
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_parent_member_id                              NUMBER ;
l_unclassified_list_member_id                   NUMBER :=0;


-- LOCK Row of Existing Resource List Member Before DELETE

CURSOR	l_lock_row_member_csr (l_resource_list_member_id NUMBER)
IS
SELECT	'x'
FROM		pa_resource_list_members rlm
WHERE		rlm.resource_list_member_id = l_resource_list_member_id
FOR UPDATE NOWAIT;

/* Changes done for bug 1889671 Resource Mapping Enhancements */

CURSOR Cur_Unclassified_Parent_ID(X_resource_list_member_id pa_resource_list_members.resource_list_member_id%TYPE)  IS
SELECT  parent_member_id
FROM pa_resource_list_members
WHERE resource_list_member_id = x_resource_list_member_id;

CURSOR Cur_Unclassified_member(x_parent_member_id pa_resource_list_members.parent_member_id%TYPE) IS
SELECT resource_list_member_id
FROM pa_resource_list_members
WHERE parent_member_id =x_parent_member_id
AND resource_type_code ='UNCLASSIFIED';

BEGIN
	SAVEPOINT Delete_Resource_List_Mbr_Pub;

-- Standard Api compatibility call

       IF NOT FND_API.Compatible_API_Call (  l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
       THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_DEL_RESOURCE_LIST_MEMBER',
       p_msg_count	    => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    	  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    	  THEN
			RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
  	   FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
	   FND_MSG_PUB.ADD;
           p_return_status := FND_API.g_ret_sts_error;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;
	IF FND_API.to_boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
        END IF;

	p_return_status :=  FND_API.G_RET_STS_SUCCESS;


-- VALUE LAYER:

	Convert_List_name_to_id
     	(	p_resource_list_name    	=>  p_resource_list_name,
      		p_resource_list_id     	=>  p_resource_list_id,
      		p_out_resource_list_id  	=>  l_resource_list_id,
      		p_return_status         	=>  l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        		RAISE FND_API.G_EXC_ERROR;
 	END IF;

	Convert_alias_to_id
	(	 p_resource_list_id		=> l_resource_list_id
		,p_alias			=> p_resource_alias
		,p_resource_list_member_id	=> p_resource_list_member_id
 		,p_out_resource_list_member_id	=> l_resource_list_member_id
		,p_return_status        	=> l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
 	END IF;


-- VALIDATION LAYER ----------------------------------------------------------------
x_err_code := 0;

PA_GET_RESOURCE.delete_resource_list_member_ok(l_resource_list_id,l_resource_list_member_id,x_err_code,x_err_stage);

IF x_err_code <> 0 THEN
   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('PA',x_err_stage);
      FND_MSG_PUB.ADD;
   END IF;
   RAISE  FND_API.G_EXC_ERROR;
END IF;


/*Changes starts for Resource Mapping Enhancements-- Bug 1889671 */

 OPEN Cur_Unclassified_Parent_ID(l_resource_list_member_id);
 FETCH  Cur_Unclassified_Parent_ID INTO l_parent_member_id;
 CLOSE  Cur_Unclassified_Parent_ID;

/*Changes ends for Resource Mapping Enhancements-- Bug 1889671 */


--	D E L E T E   Resource List MEMBER ------------------------------------------------------

	OPEN  l_lock_row_member_csr (l_resource_list_member_id);
	CLOSE  l_lock_row_member_csr;

	DELETE
		pa_resource_list_members
	WHERE
		resource_list_member_id = l_resource_list_member_id;

 /* Chnages added for Resource Mapping Enhancement -- Bug 1889671 */

/* The deletion of unclassified resource list will tale place if de;etion is taking place for listmember and not for group .
*/

  IF l_parent_member_id IS NOT NULL THEN
    OPEN  Cur_Unclassified_member(l_parent_member_id);
    FETCH Cur_Unclassified_member INTO l_unclassified_list_member_id;
    CLOSE Cur_Unclassified_member;

/*Before Deleting the unclassified Resource , check whether it can be deleted. The same check is done for unclassified resource as for normal resource list member. */

    IF l_unclassified_list_member_id IS NOT NULL THEN

     pa_get_resource.delete_resource_list_member_ok(
              		L_RESOURCE_LIST_ID        =>l_resource_list_id,
	         	L_RESOURCE_LIST_MEMBER_ID =>l_unclassified_list_member_id,
		        X_ERR_CODE                =>x_err_code,
		        X_ERR_STAGE               =>x_err_stage);

/* if the unclassified resource list can be dleted then call the procedure */

      IF x_err_code = 0 THEN

         pa_resource_list_pkg.Delete_Unclassified_Child(
                       X_RESOURCE_LIST_ID   =>l_resource_list_id,
                       X_PARENT_MEMBER_ID   =>l_parent_member_id,
                       X_MSG_COUNT          =>x_err_code,
                       X_MSG_DATA           =>x_err_stage,
                       X_RETURN_STATUS      =>l_return_status);

          IF x_err_code <> 0 THEN
            IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.SET_NAME('PA',x_err_stage);
              FND_MSG_PUB.ADD;
            END IF;
           RAISE  FND_API.G_EXC_ERROR;
          END IF;
      END IF;
    END IF;
  END IF;

	IF FND_API.to_boolean( p_commit )
	THEN
		COMMIT;
	END IF;

	EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN

        		p_return_status := FND_API.G_RET_STS_ERROR ;
	        	ROLLBACK TO Delete_Resource_List_Mbr_Pub;

        		FND_MSG_PUB.Count_And_Get
	        	(   p_count         =>  p_msg_count         ,
            		p_data          =>  p_msg_data          );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	        	ROLLBACK TO Delete_Resource_List_Mbr_Pub;

		FND_MSG_PUB.Count_And_Get
	        	(   p_count         =>  p_msg_count         ,
            		p_data          =>  p_msg_data          );

	WHEN ROW_ALREADY_LOCKED THEN

	        	p_return_status := FND_API.G_RET_STS_ERROR ;
        		ROLLBACK TO Delete_Resource_List_Mbr_Pub;

       	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED');
		FND_MESSAGE.SET_TOKEN('ENTITY', 'RESOURCE_LIST');
		FND_MSG_PUB.ADD;
  	END IF;

		FND_MSG_PUB.Count_And_Get
		(   p_count         =>  p_msg_count         ,
			p_data          =>  p_msg_data          );

    	WHEN OTHERS THEN

		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO Delete_Resource_List_Mbr_Pub;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 	THEN
            			FND_MSG_PUB.Add_Exc_Msg
		            (   p_pkg_name              =>  G_PKG_NAME                  ,
              			  p_procedure_name        =>  l_api_name
			            );
        		 END IF;

        		FND_MSG_PUB.Count_And_Get
		        (   p_count         =>  p_msg_count         ,
		            p_data          =>  p_msg_data          );

END Delete_Resource_list_Member;
-- ================================================================
--
-- Name:		Sort_Resource_List_Members
-- Type:		PL/SQL Procedure
-- Decscription:	This sorts a resource list or a group within a resource list
--		by alias or resource name. The sort_order column is
--		resequenced by increments of ten.
--
-- Called Subprograms:	None
--
-- NOTES:
--		This API DOES sort a given resource list by either ALIAS
--		or RESOURCE_NAME. However, it isn't obvious as the
--		'p_sort_by' parameter is included as 'decode' in
--		the cursor 'order by' clauses.
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--

PROCEDURE Sort_Resource_List_Members
( p_commit                 IN VARCHAR2 := FND_API.G_FALSE,
  p_api_version_number     IN  NUMBER,
  p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
  p_resource_list_name     IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_resource_list_id       IN  NUMBER       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_resource_group_alias   IN  VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_sort_by                IN  VARCHAR2,
  p_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_return_status          OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
 IS
l_api_version_number   CONSTANT NUMBER := G_API_VERSION_NUMBER;
l_api_name             CONSTANT VARCHAR2(30) := 'Sort_Resource_List_Members';
l_message_count        NUMBER;

l_resource_list_id			NUMBER	:= 0;
l_return_status 			VARCHAR2(1);
l_dummy			VARCHAR2(1);
l_resource_group_alias   		pa_resource_list_members.alias%TYPE;

l_rg_rowid			VARCHAR2(20) ;
l_rg_rlm_id			NUMBER	:= 0;
l_rg_sort_order			NUMBER	:= 0;
l_mbr_rowid			VARCHAR2(20)	;
l_mbr_sort_order			NUMBER	:= 0;
l_resource_list_member_id 	pa_resource_list_members.resource_list_member_id%TYPE;
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;

-- Cursor for Resource Group  Validation

CURSOR l_rsrc_grp_csr (l_resource_list_id NUMBER, l_resource_group_alias VARCHAR2)
IS
SELECT  	rlm.resource_list_member_id
FROM 		pa_resource_list_members rlm
WHERE 	rlm.resource_list_id = l_resource_list_id
		AND	rlm.parent_member_id IS NULL
	       	AND	rlm.alias = l_resource_group_alias;

-- Cursor for UPDATE LOOP: OUTER  GROUP

CURSOR l_rsrc_list_csr  (l_resource_list_id NUMBER
			, l_resource_group_alias VARCHAR2
			, p_sort_by VARCHAR2)
IS
SELECT 	rlm.ROWID, rlm.resource_list_member_id
FROM		pa_resource_list_members rlm,
		pa_resources r,
		pa_resource_types rt
WHERE		rlm.resource_id = r.resource_id
		AND		r.resource_type_id =  rt.resource_type_id
		AND		rt.resource_type_code <> 'UNCLASSIFIED'
		AND		rlm.resource_list_id = l_resource_list_id
		AND		rlm.parent_member_id IS NULL
		AND		rlm.alias = NVL(l_resource_group_alias,rlm.alias)
		ORDER BY 	DECODE(p_sort_by,'ALIAS',rlm.alias,'RESOURCE_NAME', r.name, rlm.alias);

-- Cursor for UPDATE LOOP: INNER  MEMBERS

CURSOR  l_rsrc_list_mbr_csr (l_rg_rlm_id NUMBER, p_sort_by VARCHAR2)
IS
SELECT 	rlm.ROWID
FROM		pa_resource_list_members rlm,
		pa_resources r,
		pa_resource_types rt
WHERE		rlm.resource_id = r.resource_id
		AND		rlm.parent_member_id = l_rg_rlm_id
		AND		r.resource_type_id =  rt.resource_type_id
		AND		rt.resource_type_code <> 'UNCLASSIFIED'
		ORDER BY 	DECODE(p_sort_by,'ALIAS',rlm.alias,'RESOURCE_NAME', r.name, rlm.alias);

-- ROW LOCKING: A L L  Members of Resource List

CURSOR	l_lock_row_all_csr (l_resource_list_id NUMBER)
IS
SELECT	'x'
FROM		pa_resource_list_members rlm
WHERE		rlm.resource_list_id = l_resource_list_id
FOR UPDATE NOWAIT;

-- ROW LOCKING: A single group and its members

CURSOR	l_lock_row_group_csr (l_resource_list_member_id NUMBER)
IS
SELECT	'x'
FROM		pa_resource_list_members rlm
WHERE		(rlm.resource_list_member_id = l_resource_list_member_id
			OR rlm.parent_member_id = l_resource_list_member_id)
FOR UPDATE NOWAIT;



BEGIN

	SAVEPOINT Sort_Resource_List_Mbr_Pub;

-- Standard Api compatibility call

       IF NOT FND_API.Compatible_API_Call (  l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
       THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_UPD_RESOURCE_LIST_MEMBER',
       p_msg_count	    => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status	    => l_return_status,
       p_function_allowed   => l_function_allowed );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    	  THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    	  THEN
			RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
  	   FND_MESSAGE.SET_NAME('PA','PA_FUNCTION_SECURITY_ENFORCED');
	   FND_MSG_PUB.ADD;
           p_return_status := FND_API.g_ret_sts_error;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF FND_API.to_boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
        END IF;

	p_return_status :=  FND_API.G_RET_STS_SUCCESS;


-- VALUE LAYER --------------------------------------------------------------

	Convert_List_name_to_id
     	(	p_resource_list_name    =>  p_resource_list_name,
      		p_resource_list_id      =>  p_resource_list_id,
      		p_out_resource_list_id  =>  l_resource_list_id,
      		p_return_status         =>  l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
		RAISE FND_API.G_EXC_ERROR;
 	END IF;

-- Default Group Alias to Local Variable
	IF (p_resource_group_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
		l_resource_group_alias := NULL;
	ELSE
		l_resource_group_alias := p_resource_group_alias;
	END IF;


-- VALIDATION LAYER ----------------------------------------------------------

-- FIX, 12-FEB-97, jwhite:
-- Added validation for p_sort_by Allowable Values
-- -----------------------------------------------------------------------------------------

IF ((p_sort_by <> 'ALIAS') AND (p_sort_by <> 'RESOURCE_NAME')) THEN
	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	  THEN
              		FND_MESSAGE.SET_NAME('PA','PA_INVALID_SORT_BY');
  	           	FND_MSG_PUB.ADD;
    	END IF;
	RAISE  FND_API.G_EXC_ERROR;
END IF;

-- -----------------------------------------------------------------------------------------

-- Validate Resource Group Alias if  NOT NULL

	IF (l_resource_group_alias IS NOT NULL) THEN
		OPEN l_rsrc_grp_csr (l_resource_list_id, l_resource_group_alias);
		FETCH l_rsrc_grp_csr INTO l_resource_list_member_id;
		IF  (l_rsrc_grp_csr %NOTFOUND) THEN
		IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	   		THEN
              			FND_MESSAGE.SET_NAME('PA','PA_INVALID_RSRC_GROUP_ALIAS');
  	           		FND_MSG_PUB.ADD;
	    	END IF;
		RAISE  FND_API.G_EXC_ERROR;
		END IF;
		CLOSE l_rsrc_grp_csr ;
	END IF;

-- UPDATE RESOURCE LIST GROUPS AND MEMBERS ---------------


-- LOCK ROWS  Depending on whether to Sort  All Members or a Single Group of Members

	IF (l_resource_group_alias IS NULL) THEN
-- Lock Entire List

		OPEN	l_lock_row_all_csr (l_resource_list_id);
		CLOSE l_lock_row_all_csr;

	ELSE
-- Lock Group and its members

		OPEN	l_lock_row_group_csr (l_resource_list_member_id);
		CLOSE l_lock_row_group_csr;

	END IF;



-- Outer Update Loop: Group

	OPEN l_rsrc_list_csr  (l_resource_list_id, l_resource_group_alias
			, p_sort_by);

	LOOP

		FETCH l_rsrc_list_csr INTO l_rg_rowid, l_rg_rlm_id;
		EXIT WHEN l_rsrc_list_csr%NOTFOUND;

-- Inner Update Loop: 2nd-Level Members

		   l_mbr_sort_order	:=  0;
		   OPEN l_rsrc_list_mbr_csr (l_rg_rlm_id, p_sort_by);

		   LOOP

			FETCH l_rsrc_list_mbr_csr INTO l_mbr_rowid;
			EXIT WHEN l_rsrc_list_mbr_csr%NOTFOUND;

-- Inner Loop Update
			l_mbr_sort_order	:=  l_mbr_sort_order + 10;

			UPDATE 	pa_resource_list_members
			SET 		sort_order =	l_mbr_sort_order
			WHERE		ROWID	=	l_mbr_rowid;

		   END LOOP;
		   CLOSE l_rsrc_list_mbr_csr;

		l_rg_sort_order	:=  l_rg_sort_order + 10;

		UPDATE 	pa_resource_list_members
		SET 		sort_order =	l_rg_sort_order
		WHERE		ROWID	=	l_rg_rowid;

	END LOOP;
	CLOSE l_rsrc_list_csr;



	IF FND_API.to_boolean( p_commit )
	THEN
		COMMIT;
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO Sort_Resource_List_Mbr_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO Sort_Resource_List_Mbr_Pub;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );

     WHEN ROW_ALREADY_LOCKED THEN

	p_return_status := FND_API.G_RET_STS_ERROR ;
        	ROLLBACK TO Sort_Resource_List_Mbr_Pub;

       	IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED');
		FND_MESSAGE.SET_TOKEN('ENTITY', 'RESOURCE_LIST_MEMBER');
		FND_MSG_PUB.ADD;
  	END IF;

		FND_MSG_PUB.Count_And_Get
		(   p_count         =>  p_msg_count         ,
			p_data          =>  p_msg_data          );

    WHEN OTHERS THEN

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	ROLLBACK TO Sort_Resource_List_Mbr_Pub;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME                  ,
                p_procedure_name        =>  l_api_name
            );
         END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count         =>  p_msg_count         ,
            p_data          =>  p_msg_data          );


END Sort_Resource_List_Members;
-- ==============================================================

--
-- Name:		Fetch_Resource_list_id
-- Type:		PL/SQL Procedure
-- Decscription:	This function fetches a resource_list_id.
--
-- Called Subprograms:
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--


FUNCTION Fetch_Resource_list_id
         (p_resource_list_name IN VARCHAR2) RETURN
NUMBER
IS

CURSOR l_resource_list_csr IS
SELECT resource_list_id
FROM
pa_resource_lists
WHERE
name = p_resource_list_name;

l_resource_list_rec  l_resource_list_csr%ROWTYPE;
l_api_name        CONSTANT VARCHAR2(30) := ' Fetch_Resource_list_id';


BEGIN

       OPEN l_resource_list_csr;
       FETCH l_resource_list_csr INTO l_resource_list_rec.resource_list_id;
       IF l_resource_list_csr%NOTFOUND THEN
          CLOSE l_resource_list_csr;
          RETURN NULL;
       ELSE
          CLOSE l_resource_list_csr;
          RETURN l_resource_list_rec.resource_list_id;
       END IF;

EXCEPTION

WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );

        END IF;


END Fetch_Resource_list_id;
--  ================================================================

--
-- Name:		Convert_List_name_to_id
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure converts resource list name to idenfier.
--
-- Called Subprograms:	Fetch_Resource_list_id
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--


PROCEDURE Convert_List_Name_To_Id
(
 p_resource_list_name   IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_list_id     IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_out_resource_list_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )

IS

l_api_name        CONSTANT 	VARCHAR2(30) := 'Convert_List_name_to_id';
l_resource_list_id      		NUMBER ;
l_dummy			VARCHAR2(1);

CURSOR l_resource_list_csr (p_resource_list_id NUMBER)
IS
SELECT 	'x'
FROM 		pa_resource_lists
WHERE 	resource_list_id  = p_resource_list_id;


BEGIN
   p_return_status :=  FND_API.G_RET_STS_SUCCESS;

   IF p_resource_list_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
-- Validate Passed Resource_List_Id

		OPEN l_resource_list_csr (p_resource_list_id);
		FETCH l_resource_list_csr INTO l_dummy;
		IF (l_resource_list_csr %NOTFOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
			FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
               		FND_MESSAGE.SET_TOKEN('ATTR_NAME','Resource List');
               		FND_MESSAGE.SET_TOKEN('ATTR_VALUE', p_resource_list_id);
               		FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_resource_list_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		     CLOSE l_resource_list_csr;
		p_out_resource_list_id := p_resource_list_id;
		END IF;


 ELSIF  --(i.e p_resource_list_id  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
         p_resource_list_name <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

        l_resource_list_id :=
          Fetch_Resource_list_id
          (p_resource_list_name => p_resource_list_name );

          IF l_resource_list_id IS NULL THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
                FND_MESSAGE.SET_TOKEN('ATTR_NAME','Resource List Name');
                FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_resource_list_name);
                FND_MSG_PUB.ADD;
	   RAISE FND_API.G_EXC_ERROR;
              END IF;
           ELSE
                p_out_resource_list_id := l_resource_list_id;
           END IF;

     END IF; -- If p_resource_list_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


    WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME                  ,
                p_procedure_name        =>  l_api_name            );

        END IF;

END Convert_List_Name_To_Id ;
--  ================================================================

--
-- Name:		Fetch_Resource_list_Member_id
-- Type:		PL/SQL Procedure
-- Decscription:	This fuctions fetches the resource_list_member_id.
--
-- Called Subprograms:
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--


FUNCTION Fetch_Resource_list_Member_id
         ( p_resource_list_id  IN NUMBER,
           p_alias             IN VARCHAR2
) RETURN
NUMBER
IS

CURSOR l_resource_list_members_csr IS
SELECT resource_list_member_id
FROM
pa_resource_list_members
WHERE resource_list_id  = p_resource_list_id
AND   alias             = p_alias;

l_resource_list_member_rec  l_resource_list_members_csr%ROWTYPE;
l_api_name		CONSTANT 	VARCHAR2(30) := ' Fetch_Resource_list_Member_id';

BEGIN

       OPEN l_resource_list_members_csr;
       FETCH l_resource_list_members_csr INTO
             l_resource_list_member_rec.resource_list_member_id;
       IF l_resource_list_members_csr%NOTFOUND THEN
          CLOSE l_resource_list_members_csr;
          RETURN NULL;
       ELSE
          CLOSE l_resource_list_members_csr;
          RETURN l_resource_list_member_rec.resource_list_member_id;
       END IF;

EXCEPTION

WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );

        END IF;


END Fetch_Resource_list_Member_id;
--  ================================================================

--
-- Name:		Convert_Alias_To_Id
-- Type:		PL/SQL Procedure
-- Decscription:	This  procedure converts an alias and resource list name to a
--		resource_list_member_id.
--
-- Called Subprograms:	Fetch_Resource_list_Member_id
--
-- History:
--	xx-AUG-96	Created	rkrishna
--	04-DEC-96	Update	jwhite	Applied latest standards.
--

PROCEDURE Convert_Alias_To_Id
(
 p_resource_list_id        IN NUMBER,
 p_alias                   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_list_member_id IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_project_id              IN NUMBER DEFAULT NULL,
 p_out_resource_list_member_id 	OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 p_return_status        	OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS

l_api_name	CONSTANT        VARCHAR2(30) := 'Convert_alias_to_id';
l_resource_list_member_id 	NUMBER;
l_migration_code		VARCHAR2(1);
l_control_flag			VARCHAR2(1);
l_object_type                   VARCHAR2(20);
l_object_id                     NUMBER;
l_dummy				VARCHAR2(1);

CURSOR l_resource_list_members_csr (p_resource_list_member_id NUMBER,
                                    p_resource_list_id        NUMBER,
                                    p_object_id               NUMBER,
                                    p_object_type             VARCHAR2)
IS
SELECT 	'x'
FROM 	pa_resource_list_members
WHERE 	resource_list_member_id  = p_resource_list_member_id
AND     resource_list_id         = p_resource_list_id
AND     nvl(object_id, -99)      = nvl(p_object_id, -99)
AND     nvl(object_type, 'D')    = nvl(p_object_type, 'D');

BEGIN
p_return_status :=  FND_API.G_RET_STS_SUCCESS;

SELECT migration_code, control_flag
INTO   l_migration_code, l_control_flag
FROM   pa_resource_lists_all_bg
WHERE  resource_list_id = p_resource_list_id;

IF l_migration_code is not null THEN
   IF l_control_flag = 'Y' THEN
      l_object_type := 'RESOURCE_LIST';
      l_object_id   := p_resource_list_id;
   ELSE
      IF p_project_id IS NULL THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_object_type := 'PROJECT';
      l_object_id   := p_project_id;
   END IF;
END IF;

IF (p_resource_list_member_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
-- Validate Passed Resource_List_Member_Id

	OPEN l_resource_list_members_csr(
                     p_resource_list_member_id => p_resource_list_member_id,
                     p_resource_list_id        => p_resource_list_id,
                     p_object_id               => l_object_id,
                     p_object_type             => l_object_type);

	FETCH l_resource_list_members_csr INTO l_dummy;
	IF (l_resource_list_members_csr %NOTFOUND) THEN
	   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
              FND_MESSAGE.SET_TOKEN('ATTR_NAME','Resource List Member');
              FND_MESSAGE.SET_TOKEN('ATTR_VALUE', p_resource_list_member_id);
              FND_MSG_PUB.ADD;
	   END IF;
	   CLOSE l_resource_list_members_csr;
	   RAISE FND_API.G_EXC_ERROR;
	ELSE
	   CLOSE l_resource_list_members_csr;
	   p_out_resource_list_member_id := p_resource_list_member_id;
	END IF;

ELSIF (p_alias <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

-- Fetch Resource List Member Id
        -- old model only
        IF l_migration_code is NULL then
     	   l_resource_list_member_id := Fetch_Resource_list_member_id
		           	(p_resource_list_id => p_resource_list_id,
            			 p_alias            => p_alias );
        ELSE
           SELECT resource_list_member_id
             INTO l_resource_list_member_id
             FROM pa_resource_list_members
            WHERE resource_list_id  = p_resource_list_id
              AND object_type       = l_object_type
              AND object_id         = l_object_id
              AND alias             = p_alias;
        END IF;

-- In certain cases,it is ok to get a null resource_list_member_id
-- This implies that the alias is yet to be created. However, since this API is unware of
-- those cases, a null id is always treated as an error.

       	     IF (l_resource_list_member_id IS NULL ) THEN

    		p_out_resource_list_member_id := NULL;
            		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
            			FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
               		FND_MESSAGE.SET_TOKEN('ATTR_NAME','Alias');
               		FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_alias);
               		FND_MSG_PUB.ADD;
		END IF;
              		RAISE FND_API.G_EXC_ERROR;

                  ELSE
		p_out_resource_list_member_id := l_resource_list_member_id;
        	    END IF;

 END IF;  -- IF p_resource_list_member_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     WHEN OTHERS THEN

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );

        END IF;


END Convert_Alias_To_Id;


PROCEDURE Get_Resource_Name
(
 p_resource_type_code          	IN VARCHAR2,
 p_resource_attr_value         	IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_resource_name               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_return_status               OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS

l_api_name		CONSTANT 	VARCHAR2(30) := 'Get_Resource_Name';

CURSOR l_emp_csr (l_resource_attr_value VARCHAR2)
IS
SELECT 	employee_name
FROM 	pa_employees_res_v
WHERE 	person_id  = TO_NUMBER(l_resource_attr_value);

CURSOR l_job_csr (l_resource_attr_value VARCHAR2)
IS
SELECT 	job_name
FROM 	pa_jobs_res_v
WHERE 	job_id  = TO_NUMBER(l_resource_attr_value);

CURSOR l_org_csr (l_resource_attr_value VARCHAR2)
IS
SELECT 	organization_name
FROM 	pa_organizations_res_v
WHERE 	organization_id  = TO_NUMBER(l_resource_attr_value);

CURSOR l_vendor_csr (l_resource_attr_value VARCHAR2)
IS
SELECT 	vendor_name
FROM 	pa_vendors_res_v
WHERE 	vendor_id  = TO_NUMBER(l_resource_attr_value);

CURSOR l_exp_type_csr (l_resource_attr_value VARCHAR2)
IS
SELECT 	expenditure_type
FROM 	pa_expenditure_types_res_v
WHERE 	expenditure_type  = l_resource_attr_value;

CURSOR l_exp_category_csr (l_resource_attr_value VARCHAR2)
IS
SELECT 	expenditure_category
FROM 	pa_expend_categories_res_v
WHERE 	expenditure_category  = l_resource_attr_value;

CURSOR l_event_type_csr (l_resource_attr_value VARCHAR2)
IS
SELECT 	event_type
FROM 	pa_event_types_res_v
WHERE 	event_type  = l_resource_attr_value;

CURSOR l_rev_category_csr (l_resource_attr_value VARCHAR2)
IS
SELECT 	revenue_category_code
FROM 	pa_revenue_categories_res_v
WHERE 	revenue_category_code  = l_resource_attr_value;


BEGIN

	p_return_status :=  FND_API.G_RET_STS_SUCCESS;

   	IF (p_resource_type_code =  'EMPLOYEE') THEN
-- Validate Passed person_id

		OPEN l_emp_csr(p_resource_attr_value);
		FETCH l_emp_csr INTO p_resource_name;
		IF (l_emp_csr%NOTFOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
               		FND_MESSAGE.SET_NAME('PA','PA_INVALID_EMPLOYEE');
               		FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_emp_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		     CLOSE l_emp_csr;
		END IF;

   	ELSIF   (p_resource_type_code = 'JOB') THEN
-- Validate Passed job_id

		OPEN l_job_csr(p_resource_attr_value);
		FETCH l_job_csr INTO p_resource_name;
		IF (l_job_csr%NOTFOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
               		FND_MESSAGE.SET_NAME('PA','PA_INVALID_JOB');
               		FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_job_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		     CLOSE l_job_csr;
		END IF;

   	ELSIF   (p_resource_type_code = 'ORGANIZATION') THEN
-- Validate Passed org_id

		OPEN l_org_csr(p_resource_attr_value);
		FETCH l_org_csr INTO p_resource_name;
		IF (l_org_csr%NOTFOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
               		FND_MESSAGE.SET_NAME('PA','PA_INVALID_ORGANIZATION');
               		FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_org_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		     CLOSE l_org_csr;
		END IF;

   	ELSIF   (p_resource_type_code = 'VENDOR') THEN
-- Validate Passed vendor_id

		OPEN l_vendor_csr(p_resource_attr_value);
		FETCH l_vendor_csr INTO p_resource_name;
		IF (l_vendor_csr%NOTFOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
               		FND_MESSAGE.SET_NAME('PA','PA_INVALID_VENDOR');
               		FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_vendor_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		     CLOSE l_vendor_csr;
		END IF;

   	ELSIF   (p_resource_type_code = 'EXPENDITURE_TYPE') THEN
-- Validate Passed expenditure_type

		OPEN l_exp_type_csr(p_resource_attr_value);
		FETCH l_exp_type_csr INTO p_resource_name;
		IF (l_exp_type_csr%NOTFOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
               		FND_MESSAGE.SET_NAME('PA','PA_INVALID_EXPENDITURE_TYPE');
               		FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_exp_type_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		     CLOSE l_exp_type_csr;
		END IF;

   	ELSIF   (p_resource_type_code = 'EXPENDITURE_CATEGORY') THEN
-- Validate Passed expenditure_category

		OPEN l_exp_category_csr(p_resource_attr_value);
		FETCH l_exp_category_csr INTO p_resource_name;
		IF (l_exp_category_csr%NOTFOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
               		FND_MESSAGE.SET_NAME('PA','PA_INVALID_EXP_CATEGORY');
               		FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_exp_category_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		     CLOSE l_exp_category_csr;
		END IF;

   	ELSIF   (p_resource_type_code = 'EVENT_TYPE') THEN
-- Validate Passed event_type

		OPEN l_event_type_csr(p_resource_attr_value);
		FETCH l_event_type_csr INTO p_resource_name;
		IF (l_event_type_csr%NOTFOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
               		FND_MESSAGE.SET_NAME('PA','PA_INVALID_EVENT_TYPE');
               		FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_exp_type_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		     CLOSE l_event_type_csr;
		END IF;

   	ELSIF   (p_resource_type_code = 'REVENUE_CATEGORY') THEN
-- Validate Passed revenue_category

		OPEN l_rev_category_csr(p_resource_attr_value);
		FETCH l_rev_category_csr INTO p_resource_name;
		IF (l_rev_category_csr%NOTFOUND) THEN
		   IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		   THEN
               		FND_MESSAGE.SET_NAME('PA','PA_INVALID_REV_CATEG');
               		FND_MSG_PUB.ADD;
		   END IF;
		   CLOSE l_rev_category_csr;
		   RAISE FND_API.G_EXC_ERROR;
		ELSE
		     CLOSE l_rev_category_csr;
		END IF;
      END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     WHEN OTHERS THEN

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );

        END IF;

END GET_RESOURCE_NAME ;

FUNCTION is_planning_resource (p_resource_list_member_id     IN NUMBER)
RETURN VARCHAR2 IS

l_return          VARCHAR2(1) := NULL;
l_migration_code  VARCHAR2(1) := NULL;

BEGIN

IF p_resource_list_member_id IS NOT NULL THEN
   BEGIN
   SELECT migration_code
     INTO l_migration_code
     FROM pa_resource_list_members
    WHERE resource_list_member_id = p_resource_list_member_id;

   IF l_migration_code is NULL THEN
      l_return := 'N';
   ELSE
      l_return := 'Y';
   END IF;

   EXCEPTION WHEN NO_DATA_FOUND THEN
      l_migration_code := NULL;
      l_return := NULL;
   END;
END IF;

RETURN l_return;

END is_planning_resource;

FUNCTION is_planning_resource_list (p_resource_list_id     IN NUMBER)
RETURN VARCHAR2 IS

l_return          VARCHAR2(1) := NULL;
l_migration_code  VARCHAR2(1) := NULL;

BEGIN

IF p_resource_list_id IS NOT NULL THEN
   BEGIN
   SELECT migration_code
     INTO l_migration_code
     FROM pa_resource_lists_all_bg
    WHERE resource_list_id = p_resource_list_id;

   IF l_migration_code is NULL THEN
      l_return := 'N';
   ELSE
      l_return := 'Y';
   END IF;

   EXCEPTION WHEN NO_DATA_FOUND THEN
      l_migration_code := NULL;
      l_return := NULL;
   END;
END IF;

RETURN l_return;

END is_planning_resource_list;


END PA_RESOURCE_PUB ;

/
