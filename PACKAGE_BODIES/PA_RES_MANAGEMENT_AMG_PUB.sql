--------------------------------------------------------
--  DDL for Package Body PA_RES_MANAGEMENT_AMG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RES_MANAGEMENT_AMG_PUB" AS
/* $Header: PAPMRSPB.pls 120.3.12010000.11 2010/03/22 09:47:30 vgovvala ship $ */

G_PA_MISS_NUM   CONSTANT   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
G_PA_MISS_DATE  CONSTANT   DATE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;
G_PA_MISS_CHAR  CONSTANT   VARCHAR2(3) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

/*---Bug 6511907 PJR Date Validation Enhancement ----- Start---*/

FUNCTION GET_PROJECT_START_DATE(l_prj_id NUMBER)
RETURN DATE
IS

l_start_dt DATE;

BEGIN

SELECT start_date
INTO l_start_dt
FROM pa_projects_all
WHERE project_id = l_prj_id;

RETURN l_start_dt;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
        RETURN NULL;
 WHEN OTHERS THEN
        RETURN NULL;
END;

FUNCTION GET_PROJECT_COMPLETION_DATE(l_prj_id NUMBER)
RETURN DATE
IS

l_compl_dt DATE;

BEGIN

SELECT completion_date
INTO l_compl_dt
FROM pa_projects_all
WHERE project_id = l_prj_id;

RETURN l_compl_dt;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
        RETURN NULL;
 WHEN OTHERS THEN
        RETURN NULL;
END;

/*---Bug 6511907 PJR Date Validation Enhancement ----- End---*/

FUNCTION IS_VALID_APPROVER(l_approver_id NUMBER,l_resource_id NUMBER,l_start_date DATE)
RETURN VARCHAR2
IS

l_dummy VARCHAR2(1) := 'N';

BEGIN

BEGIN
SELECT 'Y' into l_dummy
  FROM dual
 WHERE l_approver_id in
(SELECT pa_resource_utils.get_hr_manager_id(res_denorm.resource_id,l_start_date) approver_id
 from pa_resources_denorm res_denorm
 WHERE  l_start_date between resource_effective_start_date
        and resource_effective_end_date
  START WITH resource_id = l_resource_id
  CONNECT BY
          prior pa_resource_utils.get_hr_manager_id(res_denorm.resource_id,l_start_date)= person_id
          and pa_resource_utils.get_hr_manager_id(res_denorm.resource_id,l_start_date) <> prior person_id
         and l_start_date between prior resource_effective_start_date and prior resource_effective_end_date
          and  l_start_date between resource_effective_start_date and resource_effective_end_date
  UNION
  SELECT per.person_id  approver_id
   from pa_resources_denorm res_denorm,
        fnd_grants       fg,
        fnd_objects      fob,
        per_all_people_f per,
        wf_roles wfr,
        (select pa_security_pvt.get_menu_id('PA_PRM_RES_PRMRY_CONTACT') menu_id
        from dual) prmry_contact_menu
   where   fob.obj_name              = 'ORGANIZATION'
   and     res_denorm.resource_id    = l_resource_id
   and     l_start_date between res_denorm.resource_effective_start_date and res_denorm.resource_effective_end_date
   and     fg.instance_pk1_value     = to_char(res_denorm.resource_organization_id)
   and     fg.instance_type          = 'INSTANCE'
   and     fg.object_id              = fob.object_id
   and     fg.grantee_type           = 'USER'
   AND     fg.grantee_key    = wfr.name
   AND     wfr.orig_system    = 'HZ_PARTY'
   AND     per.party_id      = wfr.orig_system_id
   and     sysdate between per.effective_start_date and per.effective_end_date
   and     fg.menu_id                = prmry_contact_menu.menu_id
   and     trunc(SYSDATE) between trunc(fg.start_date) and     trunc(NVL(fg.end_date, SYSDATE+1))
UNION
   select per.person_id  approver_id
   from pa_resources_denorm res_denorm,
        fnd_grants          fg,
        fnd_objects         fob,
        wf_roles            wfr,
        per_people_f        per,
        (select pa_security_pvt.get_menu_id('PA_PRM_RES_AUTH') menu_id
         from dual) res_auth_menu
   where   fob.obj_name              = 'ORGANIZATION'
   and     res_denorm.resource_id    = l_resource_id
   and     fg.instance_pk1_value     = to_char(res_denorm.resource_organization_id)
   and     l_start_date between res_denorm.resource_effective_start_date and res_denorm.resource_effective_end_date
   and     fg.instance_type          = 'INSTANCE'
   and     fg.object_id              = fob.object_id
   and     fg.grantee_type           = 'USER'
   and     fg.menu_id = res_auth_menu.menu_id
   and     trunc(SYSDATE) between trunc(fg.start_date)
                          and     trunc(NVL(fg.end_date, SYSDATE+1))
   AND   fg.grantee_key    = wfr.name
   AND   wfr.orig_system    = 'HZ_PARTY'
   AND   per.party_id      = wfr.orig_system_id
   and   sysdate between per.effective_start_date and per.effective_end_date
   and     per.person_id <> res_denorm.manager_id
   and     per.person_id not in
          (
             select per2.person_Id
             from
                fnd_grants       fg2,
                fnd_objects      fob2,
                wf_roles         wfr2,
                (select pa_security_pvt.get_menu_id('PA_PRM_RES_PRMRY_CONTACT') menu_id
                from dual) prmry_contact_menu,
                per_people_f     per2
             where   fob.obj_name               = 'ORGANIZATION'
             and     fg2.instance_pk1_value     = to_char(res_denorm.resource_organization_id)
             and     fg2.instance_type          = 'INSTANCE'
             and     fg2.object_id              = fob2.object_id
             and     fg2.grantee_type           = 'USER'
             and     fg2.menu_id = prmry_contact_menu.menu_id
             and     trunc(SYSDATE) between trunc(fg2.start_date)
                                    and     trunc(NVL(fg2.end_date, SYSDATE+1))
             AND   fg2.grantee_key    = wfr2.name
             AND   wfr2.orig_system    = 'HZ_PARTY'
             AND   per2.party_id      = wfr2.orig_system_id
             and   sysdate between per2.effective_start_date
                               and per2.effective_end_date
          )
) ;
EXCEPTION
WHEN NO_DATA_FOUND THEN
        l_dummy := 'N';
WHEN OTHERS THEN
        l_dummy := 'N';
        RAISE ;
END;

return l_dummy;
END IS_VALID_APPROVER;

-- Start of comments
--	API name 	: VALIDATE_FLEX_FIELD
--	Type		: Private
--	Pre-reqs	: None.
--	Function	: This is a private API to validate Flex Field segments.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN/INOUT	:	p_desc_flex_name	IN  VARCHAR2
--					Name of the descriptive flex field.
--				p_attribute_category		IN  VARCHAR2
--					Context value of the flex field.
--				px_attribute1 .. 15     	IN  VARCHAR2
--					Attribute values.
--	OUT		:
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - amksingh  - Created
-- End of comments
PROCEDURE VALIDATE_FLEX_FIELD(
  p_desc_flex_name              IN              VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_attribute_category          IN              VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, px_attribute1                 IN OUT  NOCOPY  VARCHAR2
, px_attribute2                 IN OUT  NOCOPY  VARCHAR2
, px_attribute3                 IN OUT  NOCOPY  VARCHAR2
, px_attribute4                 IN OUT  NOCOPY  VARCHAR2
, px_attribute5                 IN OUT  NOCOPY  VARCHAR2
, px_attribute6                 IN OUT  NOCOPY  VARCHAR2
, px_attribute7                 IN OUT  NOCOPY  VARCHAR2
, px_attribute8                 IN OUT  NOCOPY  VARCHAR2
, px_attribute9                 IN OUT  NOCOPY  VARCHAR2
, px_attribute10                IN OUT  NOCOPY  VARCHAR2
, px_attribute11                IN OUT  NOCOPY  VARCHAR2
, px_attribute12                IN OUT  NOCOPY  VARCHAR2
, px_attribute13                IN OUT  NOCOPY  VARCHAR2
, px_attribute14                IN OUT  NOCOPY  VARCHAR2
, px_attribute15                IN OUT  NOCOPY  VARCHAR2
, x_return_status	        OUT	NOCOPY	VARCHAR2
, x_msg_count			OUT	NOCOPY	NUMBER
, x_msg_data			OUT	NOCOPY	VARCHAR2
)
IS
TYPE seg_col_name       IS TABLE OF VARCHAR2(150)
INDEX BY BINARY_INTEGER;

l_segment_column_name   seg_col_name;
l_attribute             seg_col_name;
BEGIN
        -- This API will return only those segment values which are enabled as part of
        -- Global Data Elements context and the passed context.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- I don't think we need to do null check here
        -- If we do this check, then if some sgements are mandatory
        -- the error will not come
        --IF p_attribute_category IS NULL AND px_attribute1 IS NULL AND px_attribute2 IS NULL
        --AND px_attribute3 IS NULl AND px_attribute4 IS NULL AND px_attribute5 IS NULL
        --AND px_attribute6 IS NULL AND px_attribute7 IS NULL AND px_attribute8 IS NULL
        --AND px_attribute9 IS NULL AND px_attribute10 IS NULL AND px_attribute11 IS NULL
        --AND px_attribute12 IS NULL AND px_attribute13 IS NULL AND px_attribute14 IS NULL
        --AND px_attribute15 IS NULL
        --THEN
        --        return;
        --END IF;

        -- DEFINE ID COLUMNS
        fnd_flex_descval.set_context_value(p_attribute_category);
        fnd_flex_descval.set_column_value('ATTRIBUTE1', px_attribute1);
        fnd_flex_descval.set_column_value('ATTRIBUTE2', px_attribute2);
        fnd_flex_descval.set_column_value('ATTRIBUTE3', px_attribute3);
        fnd_flex_descval.set_column_value('ATTRIBUTE4', px_attribute4);
        fnd_flex_descval.set_column_value('ATTRIBUTE5', px_attribute5);
        fnd_flex_descval.set_column_value('ATTRIBUTE6', px_attribute6);
        fnd_flex_descval.set_column_value('ATTRIBUTE7', px_attribute7);
        fnd_flex_descval.set_column_value('ATTRIBUTE8', px_attribute8);
        fnd_flex_descval.set_column_value('ATTRIBUTE9', px_attribute9);
        fnd_flex_descval.set_column_value('ATTRIBUTE10', px_attribute10);
        fnd_flex_descval.set_column_value('ATTRIBUTE11', px_attribute11);
        fnd_flex_descval.set_column_value('ATTRIBUTE12', px_attribute12);
        fnd_flex_descval.set_column_value('ATTRIBUTE13', px_attribute13);
        fnd_flex_descval.set_column_value('ATTRIBUTE14', px_attribute14);
        fnd_flex_descval.set_column_value('ATTRIBUTE15', px_attribute15);
        px_attribute1 := null;
        px_attribute2 := null;
        px_attribute3 := null;
        px_attribute4 := null;
        px_attribute5 := null;
        px_attribute6 := null;
        px_attribute7 := null;
        px_attribute8 := null;
        px_attribute9 := null;
        px_attribute10 := null;
        px_attribute11 := null;
        px_attribute12 := null;
        px_attribute13 := null;
        px_attribute14 := null;
        px_attribute15 := null;
        -- VALIDATE
        IF (fnd_flex_descval.validate_desccols( 'PA',p_desc_flex_name,'D', sysdate)) then
                x_msg_data := 'VALID: ' || fnd_flex_descval.concatenated_ids;
                x_return_status := 'S';
                FOR j IN 1 ..15 LOOP --Bug 7240954
                        l_segment_column_name(j) := ltrim(rtrim(FND_FLEX_DESCVAL.segment_column_name(j)));
                        l_attribute(j)           := ltrim(rtrim(FND_FLEX_DESCVAL.segment_id(j)));

                        IF l_segment_column_name(j) = 'ATTRIBUTE1' Then
                                px_attribute1 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE2' Then
                                px_attribute2 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE3' Then
                                px_attribute3 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE4' Then
                                px_attribute4 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE5' Then
                                px_attribute5 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE6' Then
                                px_attribute6 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE7' Then
                                px_attribute7 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE8' Then
                                px_attribute8 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE9' Then
                                px_attribute9 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE10' Then
                                px_attribute10 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE11' Then
                                px_attribute11 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE12' Then
                                px_attribute12 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE13' Then
                                px_attribute13 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE14' Then
                                px_attribute14 := l_attribute(j);
                        ELSIF l_segment_column_name(j) = 'ATTRIBUTE15' Then
                                px_attribute15 := l_attribute(j);
                        END IF;
                END LOOP;
        ELSE
                x_msg_data := 'INVALID: ' || fnd_flex_descval.error_message;
                x_return_status := 'E';
        END IF;
EXCEPTION
WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'VALIDATE_FLEX_FIELD'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        RAISE;
END VALIDATE_FLEX_FIELD;

-- Start of comments
--	API name 	: CREATE_REQUIREMENTS
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to create one or more requirements for one or more projects.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are:	FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_requirement_in_tbl	IN  REQUIREMENT_IN_TBL_TYPE	Required
--					Table of requirement records. Please see the REQUIREMENT_IN_TBL_TYPE datatype table.
--	OUT		:
--				x_requirement_id_tbl	OUT SYSTEM.PA_NUM_TBL_TYPE
--					Table to store requirement_ids created by the API.
--					Reference: pa_project_assignments.assignment_id
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - amksingh  - Created
-- End of comments
PROCEDURE CREATE_REQUIREMENTS
(
  p_api_version_number		IN		NUMBER   := 1.0
, p_init_msg_list		IN		VARCHAR2 := FND_API.G_TRUE
, p_commit			IN		VARCHAR2 := FND_API.G_FALSE
, p_requirement_in_tbl		IN		REQUIREMENT_IN_TBL_TYPE
, x_requirement_id_tbl		OUT	NOCOPY	SYSTEM.PA_NUM_TBL_TYPE
, x_return_status		OUT	NOCOPY	VARCHAR2
, x_msg_count			OUT	NOCOPY	NUMBER
, x_msg_data			OUT	NOCOPY	VARCHAR2
)
IS
l_calling_application           VARCHAR2(10)            := 'PLSQL';
l_calling_module                VARCHAR2(10)            := 'AMG';
l_check_id_flag                 VARCHAR2(1)             := 'Y';
l_check_role_security_flag      VARCHAR2(1)             := 'Y';
l_check_resource_security_flag  VARCHAR2(1)             := 'Y';
l_log_level                     NUMBER                  := 3;
l_module                        VARCHAR2(100)           := 'PA_RES_MANAGEMENT_AMG_PUB.CREATE_REQUIREMENTS';
l_commit                        VARCHAR2(1)             := FND_API.G_FALSE;
l_init_msg_list                 VARCHAR2(1)             := FND_API.G_FALSE;
l_validate_only                 VARCHAR2(1)             := FND_API.G_FALSE;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_data                          VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);

i                               NUMBER;
l_new_assignment_id_tbl         SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
l_new_assignment_id             NUMBER;
l_assignment_number             NUMBER;
l_assignment_row_id             ROWID;
l_resource_id                   NUMBER;
l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
l_error_flag                    VARCHAR2(1)             := 'N';
l_error_flag_local              VARCHAR2(1)             := 'N';
l_req_rec		        REQUIREMENT_IN_REC_TYPE;
l_asgn_creation_mode		VARCHAR2(10)	        := 'FULL';
l_assignment_type		VARCHAR2(30)	        := 'OPEN_ASSIGNMENT';
l_multiple_status_flag		VARCHAR2(1)	        := 'N';
l_dummy_code                    VARCHAR2(30);
l_loop_msg_count                NUMBER                  :=0;
l_start_msg_count               NUMBER                  :=0;
l_end_msg_count                 NUMBER                  :=0;
l_missing_params                VARCHAR2(1000);
l_privilege                     VARCHAR2(30);
l_object_name                   VARCHAR2(30);
l_object_key                    NUMBER;
l_error_message_code            VARCHAR2(30);
l_ret_code                      VARCHAR2(1);


CURSOR c_get_valid_calendar_types(c_code VARCHAR2) IS
SELECT lookup_code
FROM pa_lookups
WHERE lookup_type = 'CHANGE_CALENDAR_TYPE_CODE'
AND lookup_code = c_code
AND lookup_code <> 'RESOURCE';

CURSOR c_get_project_dtls(c_project_id NUMBER) IS
SELECT role_list_id, multi_currency_billing_flag, calendar_id, work_type_id, location_id
FROM pa_projects_all
WHERE project_id = c_project_id;

CURSOR c_get_team_templ_dtls(c_team_templ_id NUMBER) IS
SELECT role_list_id, calendar_id, work_type_id
FROM pa_team_templates
WHERE team_template_id = c_team_templ_id;

CURSOR c_get_role_dtls(c_role_id NUMBER) IS
SELECT meaning, default_min_job_level, default_max_job_level, default_job_id
FROM   pa_project_role_types_vl
WHERE  project_role_id = c_role_id ;

CURSOR get_bill_rate_override_flags(c_project_id NUMBER) IS
SELECT impl.rate_discount_reason_flag ,impl.br_override_flag, impl.br_discount_override_flag
FROM pa_implementations_all impl
    , pa_projects_all proj
WHERE proj.org_id=impl.org_id		-- Removed nvl condition from org_id : Post review changes for Bug 5130421
AND proj.project_id = c_project_id ;

CURSOR c_get_lookup_exists(c_lookup_type VARCHAR2, c_lookup_code VARCHAR2) IS
SELECT 'Y'
FROM dual
WHERE EXISTS
(SELECT 'XYZ' FROM pa_lookups WHERE lookup_type = c_lookup_type AND lookup_code = c_lookup_code);


CURSOR c_get_location(c_location_id NUMBER) IS
SELECT country_code, region, city
FROM pa_locations
WHERE location_id = c_location_id;

CURSOR c_derive_country_code(c_country_name IN VARCHAR2) IS
SELECT country_code
FROM pa_country_v
WHERE name = c_country_name;

CURSOR c_derive_country_name(c_country_code IN VARCHAR2) IS
SELECT name
FROM pa_country_v
WHERE  country_code  = c_country_code;


-- This cursor is for future extension when we support creation of team role from planning resource
CURSOR c_get_planning_res_info(c_resource_list_member_id NUMBER, c_budget_version_id NUMBER, c_project_id NUMBER) IS
SELECT
  ra.resource_list_member_id
, firstrow.person_id
, rlm.resource_id
, PA_RESOURCE_UTILS.get_person_name_no_date(firstrow.person_id)
, ra.project_id
, ra.budget_version_id
, decode (ra.role_count, 1, firstrow.named_role, null) named_role
, decode (ra.role_count, 1, firstrow.project_role_id, null) project_role_id
, decode (ra.role_count, 1, ro.meaning, null) project_role
, ra.min_date task_assign_start_date
, ra.max_date task_assign_end_date
, firstrow.resource_assignment_id
, firstrow.res_type_code
FROM pa_resource_assignments firstrow
, pa_resource_list_members rlm
, pa_proj_roles_v ro
, (SELECT project_id , budget_version_id , resource_list_member_id , count(1) role_count , max(max_id) max_id
     , min(min_date) min_date , max(max_date) max_date
   FROM (SELECT project_id , budget_version_id , resource_list_member_id , project_role_id
           , max(resource_assignment_id) max_id , min(SCHEDULE_START_DATE) min_date , max(SCHEDULE_END_DATE) max_date
         FROM pa_resource_assignments
         WHERE ta_display_flag = 'Y' and nvl(PROJECT_ASSIGNMENT_ID, -1) = -1
         AND resource_class_code = 'PEOPLE'
         GROUP BY project_id, budget_version_id, resource_list_member_id, project_role_id
         ) res_roles
    GROUP BY project_id, budget_version_id, resource_list_member_id
   ) ra
WHERE ra.resource_list_member_id = rlm.resource_list_member_id
AND firstrow.resource_assignment_id = ra.max_id
AND firstrow.project_role_id = ro.project_role_id (+)
AND ra.budget_version_id = c_budget_version_id
AND ra.resource_list_member_id = c_resource_list_member_id
AND ra.project_id = c_project_id
AND firstrow.person_id IS NULL;
-- If the value from this cusror is returned, then passed resource list member id is valid
-- Pass this resource list member id, budget version id to internal API
-- Pass calendar type as PROJECT and calendar_id as of project
-- Pass sum_tasks_flag as N

-- In case of assignments, user can choose calendar type between PROJECT or RESOURCE
-- Pass this resource list member id, budget version id to internal API
-- Pass sum_tasks_flag as Y if calendar is RESOURCE
-- pass person_id, resource_id

-- Added for Bug 5202329
CURSOR c_get_exp_organization_id(c_business_group_id NUMBER, c_exp_organization_name VARCHAR) IS
SELECT organization_id
FROM hr_organization_units
WHERE business_group_id = c_business_group_id
AND name = c_exp_organization_name;


l_role_list_id                  NUMBER;
l_multi_currency_billing_flag   VARCHAR2(1);
l_calendar_id                   NUMBER;
l_work_type_id                  NUMBER;
l_location_id                   NUMBER;
l_role_name                     VARCHAR2(80);
l_min_job_level                 NUMBER;
l_max_job_level                 NUMBER;
l_fcst_job_id                   NUMBER;
l_valid_flag                    VARCHAR2(1);
l_tp_amount_type_desc_tmp       VARCHAR2(80);
l_rate_discount_reason_flag     VARCHAR2(1);
l_br_override_flag              VARCHAR2(1);
l_br_discount_override_flag     VARCHAR2(1);
l_project_id_tmp                NUMBER;
l_project_role_id_tmp		NUMBER;
l_search_country_code_tmp	VARCHAR2(2);
l_srch_exp_org_str_ver_id_tmp	NUMBER;
l_search_exp_start_org_id_tmp	NUMBER;
l_expenditure_org_id_tmp	NUMBER;
l_exp_organization_id_tmp       NUMBER;
l_fcst_job_group_id_tmp         NUMBER;
l_fcst_job_id_tmp               NUMBER;
l_tp_currency_override_tmp      VARCHAR2(30);
l_valid_country                 VARCHAR2(1);
l_dummy_country_code            VARCHAR2(2);
l_dummy_state		        VARCHAR2(240);
l_dummy_city		        VARCHAR2(80);
l_out_location_id	        NUMBER;
l_bill_currency_override_tmp    VARCHAR2(30); -- 5144288, 5144369
l_business_group_id             NUMBER;       -- Added for Bug 5202329

BEGIN

        --Flows which are supported by this API
        ---------------------------------------
        --1. Create project requirements
        --        1.1 Setting basic information(staffing priority, staffing owner, subteams, location etc..)
        --        1.2 Setting schedule information(dates, status, calendar etc..)
        --        1.3 Setting competencies defaulted by team role
        --        1.4 Setting advertisement rule
        --        1.5 Setting candidate search(search organization, weightages etc..) information
        --        1.6 Setting financial information(expendtiture organization, bill rate etc..)
        --        1.7 Setting forecast infomation(job, job group, expenditure type etc..)
        --2. Create team template requirments
        --        2.1 Setting basic information(staffing priority, staffing owner, subteams, location etc..)
        --        2.2 Setting schedule information(dates, status, calendar etc..)
        --        2.3 Setting competencies defaulted by team role
        --
        --Flows which are not supported by this API
        -------------------------------------------
        --1. Create team role for given planning resource
        --2. Adding candidates while creating requirements
        --3. Adding new competencies(other than defaulted by role) while creating requirement


        -- Mandatory Parameters
        -----------------------
        --1. Either project_role_id or project_role_name should be passed.
        --2. Either team_template_id or one of project_id, project_name, project_number should be passed.
        --3. Both start_date and end_date should be passed.
        --4. Either status_code or status_name should be specified.


        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_requirement_id_tbl:= SYSTEM.pa_num_tbl_type();

        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'CREATE_REQUIREMENTS', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint CREATE_REQUIREMENTS_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of create_requirements', l_log_level);
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Printing Input Parameters......', l_log_level);
                i := p_requirement_in_tbl.first;
                WHILE i IS NOT NULL LOOP
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').requirement_id'||p_requirement_in_tbl(i).requirement_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').requirement_name'||p_requirement_in_tbl(i).requirement_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').team_template_id'||p_requirement_in_tbl(i).team_template_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').number_of_requirements'||p_requirement_in_tbl(i).number_of_requirements, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_role_id'||p_requirement_in_tbl(i).project_role_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_role_name'||p_requirement_in_tbl(i).project_role_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_id'||p_requirement_in_tbl(i).project_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_name'||p_requirement_in_tbl(i).project_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_number'||p_requirement_in_tbl(i).project_number, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').staffing_owner_person_id'||p_requirement_in_tbl(i).staffing_owner_person_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').staffing_priority_code'||p_requirement_in_tbl(i).staffing_priority_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').staffing_priority_name'||p_requirement_in_tbl(i).staffing_priority_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_subteam_id'||p_requirement_in_tbl(i).project_subteam_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_subteam_name'||p_requirement_in_tbl(i).project_subteam_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').location_id'||p_requirement_in_tbl(i).location_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').location_country_code'||p_requirement_in_tbl(i).location_country_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').location_country_name'||p_requirement_in_tbl(i).location_country_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').location_region'||p_requirement_in_tbl(i).location_region, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').location_city'||p_requirement_in_tbl(i).location_city, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').min_resource_job_level'||p_requirement_in_tbl(i).min_resource_job_level, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').max_resource_job_level'||p_requirement_in_tbl(i).max_resource_job_level, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').description'||p_requirement_in_tbl(i).description, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').additional_information'||p_requirement_in_tbl(i).additional_information, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').start_date'||p_requirement_in_tbl(i).start_date, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').end_date'||p_requirement_in_tbl(i).end_date, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').status_code'||p_requirement_in_tbl(i).status_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').status_name'||p_requirement_in_tbl(i).status_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').calendar_type'||p_requirement_in_tbl(i).calendar_type, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').calendar_id'||p_requirement_in_tbl(i).calendar_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').calendar_name'||p_requirement_in_tbl(i).calendar_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').start_adv_action_set_flag'||p_requirement_in_tbl(i).start_adv_action_set_flag, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').adv_action_set_id'||p_requirement_in_tbl(i).adv_action_set_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').adv_action_set_name'||p_requirement_in_tbl(i).adv_action_set_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').comp_match_weighting'||p_requirement_in_tbl(i).comp_match_weighting, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').avail_match_weighting'||p_requirement_in_tbl(i).avail_match_weighting, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').job_level_match_weighting'||p_requirement_in_tbl(i).job_level_match_weighting, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').enable_auto_cand_nom_flag'||p_requirement_in_tbl(i).enable_auto_cand_nom_flag, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_min_availability'||p_requirement_in_tbl(i).search_min_availability, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_exp_org_str_ver_id'||p_requirement_in_tbl(i).search_exp_org_str_ver_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_exp_org_hier_name'||p_requirement_in_tbl(i).search_exp_org_hier_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_exp_start_org_id'||p_requirement_in_tbl(i).search_exp_start_org_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_exp_start_org_name'||p_requirement_in_tbl(i).search_exp_start_org_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_country_code'||p_requirement_in_tbl(i).search_country_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_country_name'||p_requirement_in_tbl(i).search_country_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_min_candidate_score'||p_requirement_in_tbl(i).search_min_candidate_score, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_org_id'||p_requirement_in_tbl(i).expenditure_org_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_org_name'||p_requirement_in_tbl(i).expenditure_org_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_organization_id'||p_requirement_in_tbl(i).expenditure_organization_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_organization_name'||p_requirement_in_tbl(i).expenditure_organization_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_type_class'||p_requirement_in_tbl(i).expenditure_type_class, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_type'||p_requirement_in_tbl(i).expenditure_type, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').fcst_job_group_id'||p_requirement_in_tbl(i).fcst_job_group_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').fcst_job_group_name'||p_requirement_in_tbl(i).fcst_job_group_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').fcst_job_id'||p_requirement_in_tbl(i).fcst_job_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').fcst_job_name'||p_requirement_in_tbl(i).fcst_job_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').work_type_id'||p_requirement_in_tbl(i).work_type_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').work_type_name'||p_requirement_in_tbl(i).work_type_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').bill_rate_option'||p_requirement_in_tbl(i).bill_rate_option, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').bill_rate_override'||p_requirement_in_tbl(i).bill_rate_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').bill_rate_curr_override'||p_requirement_in_tbl(i).bill_rate_curr_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').markup_percent_override'||p_requirement_in_tbl(i).markup_percent_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').discount_percentage'||p_requirement_in_tbl(i).discount_percentage, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').rate_disc_reason_code'||p_requirement_in_tbl(i).rate_disc_reason_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').tp_rate_option'||p_requirement_in_tbl(i).tp_rate_option, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').tp_rate_override'||p_requirement_in_tbl(i).tp_rate_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').tp_currency_override'||p_requirement_in_tbl(i).tp_currency_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').tp_calc_base_code_override'||p_requirement_in_tbl(i).tp_calc_base_code_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').tp_percent_applied_override'||p_requirement_in_tbl(i).tp_percent_applied_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').extension_possible'||p_requirement_in_tbl(i).extension_possible, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expense_owner'||p_requirement_in_tbl(i).expense_owner, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expense_limit'||p_requirement_in_tbl(i).expense_limit, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').orig_system_code'||p_requirement_in_tbl(i).orig_system_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').orig_system_reference'||p_requirement_in_tbl(i).orig_system_reference, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').record_version_number'||p_requirement_in_tbl(i).record_version_number, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute_category'||p_requirement_in_tbl(i).attribute_category, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute1'||p_requirement_in_tbl(i).attribute1, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute2'||p_requirement_in_tbl(i).attribute2, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute3'||p_requirement_in_tbl(i).attribute3, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute4'||p_requirement_in_tbl(i).attribute4, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute5'||p_requirement_in_tbl(i).attribute5, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute6'||p_requirement_in_tbl(i).attribute6, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute7'||p_requirement_in_tbl(i).attribute7, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute8'||p_requirement_in_tbl(i).attribute8, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute9'||p_requirement_in_tbl(i).attribute9, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute10'||p_requirement_in_tbl(i).attribute10, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute11'||p_requirement_in_tbl(i).attribute11, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute12'||p_requirement_in_tbl(i).attribute12, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute13'||p_requirement_in_tbl(i).attribute13, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute14'||p_requirement_in_tbl(i).attribute14, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute15'||p_requirement_in_tbl(i).attribute15, l_log_level);
                        pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                        i := p_requirement_in_tbl.next(i);
                END LOOP;
        END IF;

        PA_STARTUP.INITIALIZE(
                  p_calling_application                 => l_calling_application
                , p_calling_module                      => l_calling_module
                , p_check_id_flag                       => l_check_id_flag
                , p_check_role_security_flag            => l_check_role_security_flag
                , p_check_resource_security_flag        => l_check_resource_security_flag
                , p_debug_level                         => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of pa_startup.initialize', l_log_level);
        END IF;

        -- Page does not check PRM licensing, but keeping this code so in future if required, can be used
        --l_prm_license_flag  := nvl(FND_PROFILE.VALUE('PA_PRM_LICENSED'),'N');
        --IF l_prm_license_flag <> 'Y' THEN
        --        null;
        --END IF;

        i := p_requirement_in_tbl.first;

        WHILE i IS NOT NULL LOOP
                l_error_flag_local := 'N';
                l_missing_params := null;
                l_req_rec := null;
                l_valid_country := 'Y';

                l_start_msg_count := FND_MSG_PUB.count_msg;

                l_req_rec := p_requirement_in_tbl(i);

                -- Blank Out Parameters if not passed.
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Record#'||i, l_log_level);
                        pa_debug.write(l_module, '-----------------------------', l_log_level);
                        pa_debug.write(l_module, 'NullOut parameters which are not required.', l_log_level);
                END IF;

                        /*--Bug 6511907 PJR Date Validation Enhancement ----- Start--*/
                        /*-- Validating Resource Req Start and End Date against
                             Project Start and Completion dates --*/

                        Declare
                          l_validate           VARCHAR2(10);
                          l_start_date_status  VARCHAR2(10);
                          l_end_date_status    VARCHAR2(10);
                          l_start_date         DATE;
                          l_end_date           DATE;
                        Begin
                         If l_req_rec.start_date is not null or l_req_rec.end_date is not null then
                           l_start_date := l_req_rec.start_date;
                           l_end_date   := l_req_rec.end_date;
                           PA_PROJECT_DATES_UTILS.Validate_Resource_Dates
                                       (l_req_rec.project_id, l_start_date, l_end_date,
                                        l_validate, l_start_date_status, l_end_date_status);

                           If l_validate = 'Y' and l_start_date_status = 'I' Then

                              pa_utils.add_message
                               ( p_app_short_name  => 'PA'
                                ,p_msg_name	       => 'PA_PJR_DATE_START_ERROR'
                                ,p_token1          => 'PROJ_TXN_START_DATE'
				,p_value1          =>  GET_PROJECT_START_DATE(l_req_rec.project_id)
                                ,p_token2          => ''
                                ,p_value2          => ''
                                ,p_token3          => ''
                                ,p_value3          => ''
                               );

                              RAISE  FND_API.G_EXC_ERROR;
                           End If;

                           If l_validate = 'Y' and l_end_date_status = 'I' Then

                              pa_utils.add_message
                               ( p_app_short_name  => 'PA'
                                ,p_msg_name	    => 'PA_PJR_DATE_FINISH_ERROR'
                                ,p_token1          => 'PROJ_TXN_END_DATE'
				,p_value1          => GET_PROJECT_COMPLETION_DATE(l_req_rec.project_id)
                                ,p_token2          => ''
                                ,p_value2          => ''
                                ,p_token3          => ''
                                ,p_value3          => ''
                               );

                              RAISE  FND_API.G_EXC_ERROR;
                           End If;
                         End If;
                        End;

                        /*--Bug 6511907 PJR Date Validation Enhancement ----- End--*/
                IF l_req_rec.requirement_id = G_PA_MISS_NUM THEN
                        l_req_rec.requirement_id := null;
                END IF;

                IF l_req_rec.requirement_name = G_PA_MISS_CHAR THEN
                        l_req_rec.requirement_name := null;
                END IF;

                IF l_req_rec.team_template_id = G_PA_MISS_NUM THEN
                        l_req_rec.team_template_id := null;
                END IF;

                IF l_req_rec.number_of_requirements = G_PA_MISS_NUM THEN
                        l_req_rec.number_of_requirements := 1;
                END IF;

                IF l_req_rec.project_role_id = G_PA_MISS_NUM THEN
                        l_req_rec.project_role_id := null;
                END IF;

                IF l_req_rec.project_role_name = G_PA_MISS_CHAR THEN
                        l_req_rec.project_role_name := null;
                END IF;

                IF l_req_rec.project_id = G_PA_MISS_NUM THEN
                        l_req_rec.project_id := null;
                END IF;

                IF l_req_rec.project_name = G_PA_MISS_CHAR THEN
                        l_req_rec.project_name := null;
                END IF;

                IF l_req_rec.project_number = G_PA_MISS_CHAR THEN
                        l_req_rec.project_number := null;
                END IF;

                -- Some fields like Staffing Owner will be defaulted further in internal APIs
                -- But user may like to pass them explicitely as null
                -- So in that case we need to distinguish MISS NUM with null
                -- But there is a problem that pa_inerface_utils_pub.g_pa_miss_num
                -- is diffrent than fnd_api.g_miss_num. PJR internal code uses
                -- fnd_api.g_miss_num, so it throws the error.
                -- For this reason, we need to convert the G_PA_MISS_NUM/CHAR to FND_API.G_MISS_NUM/CHAR
                -- before sending it to internal APIs

                IF l_req_rec.staffing_owner_person_id = G_PA_MISS_NUM THEN
                        -- We can not make null here
                        -- Because underlying API treat null as override and does not
                        -- default value.
                        l_req_rec.staffing_owner_person_id := FND_API.G_MISS_NUM;
                END IF;

                IF l_req_rec.staffing_priority_code = G_PA_MISS_CHAR THEN
                        l_req_rec.staffing_priority_code := null;
                END IF;

                IF l_req_rec.staffing_priority_name = G_PA_MISS_CHAR THEN
                        l_req_rec.staffing_priority_name := null;
                END IF;

                IF l_req_rec.project_subteam_id = G_PA_MISS_NUM THEN
                        l_req_rec.project_subteam_id := null;
                END IF;

                IF l_req_rec.project_subteam_name = G_PA_MISS_CHAR THEN
                        l_req_rec.project_subteam_name := null;
                END IF;

                -- Location will be default to project location for project requirements
                -- But user may like to pass them explicitely as null
                -- So in that case we need to distinguish MISS CHAR with null
                IF l_req_rec.location_id = G_PA_MISS_NUM THEN
                        l_req_rec.location_id := FND_API.G_MISS_NUM;
                END IF;

                IF l_req_rec.location_country_code = G_PA_MISS_CHAR THEN
                        l_req_rec.location_country_code := FND_API.G_MISS_CHAR;
                END IF;

                IF l_req_rec.location_country_name = G_PA_MISS_CHAR THEN
                        l_req_rec.location_country_name := FND_API.G_MISS_CHAR;
                END IF;

                IF l_req_rec.location_region = G_PA_MISS_CHAR THEN
                        l_req_rec.location_region := FND_API.G_MISS_CHAR;
                END IF;

                IF l_req_rec.location_city = G_PA_MISS_CHAR THEN
                        l_req_rec.location_city := FND_API.G_MISS_CHAR;
                END IF;


                IF l_req_rec.min_resource_job_level = G_PA_MISS_NUM THEN
                        l_req_rec.min_resource_job_level := null;
                END IF;

                IF l_req_rec.max_resource_job_level = G_PA_MISS_NUM THEN
                        l_req_rec.max_resource_job_level := null;
                END IF;

                IF l_req_rec.description = G_PA_MISS_CHAR THEN
                        l_req_rec.description := null;
                END IF;

                IF l_req_rec.additional_information = G_PA_MISS_CHAR THEN
                        l_req_rec.additional_information := null;
                END IF;

                IF l_req_rec.start_date = G_PA_MISS_DATE THEN
                        l_req_rec.start_date := null;
                END IF;

                IF l_req_rec.end_date = G_PA_MISS_DATE THEN
                        l_req_rec.end_date := null;
                END IF;

                IF l_req_rec.status_code = G_PA_MISS_CHAR THEN
                        l_req_rec.status_code := null;
                END IF;

                IF l_req_rec.status_name = G_PA_MISS_CHAR THEN
                        l_req_rec.status_name := null;
                END IF;

                IF l_req_rec.calendar_type = G_PA_MISS_CHAR THEN
                        l_req_rec.calendar_type := 'PROJECT';
                END IF;

                IF l_req_rec.calendar_id = G_PA_MISS_NUM THEN
                        l_req_rec.calendar_id := null;
                END IF;

                IF l_req_rec.calendar_name = G_PA_MISS_CHAR THEN
                        l_req_rec.calendar_name := null;
                END IF;

                IF l_req_rec.start_adv_action_set_flag = G_PA_MISS_CHAR THEN
                        l_req_rec.start_adv_action_set_flag := null;
                END IF;

                IF l_req_rec.adv_action_set_id = G_PA_MISS_NUM THEN
                        l_req_rec.adv_action_set_id := null;
                END IF;

                IF l_req_rec.adv_action_set_name = G_PA_MISS_CHAR THEN
                        l_req_rec.adv_action_set_name := null;
                END IF;

                IF l_req_rec.comp_match_weighting = G_PA_MISS_NUM THEN
                        l_req_rec.comp_match_weighting := null;
                END IF;

                IF l_req_rec.avail_match_weighting = G_PA_MISS_NUM THEN
                        l_req_rec.avail_match_weighting := null;
                END IF;

                IF l_req_rec.job_level_match_weighting = G_PA_MISS_NUM THEN
                        l_req_rec.job_level_match_weighting := null;
                END IF;

                IF l_req_rec.enable_auto_cand_nom_flag = G_PA_MISS_CHAR THEN
                        l_req_rec.enable_auto_cand_nom_flag := null;
                END IF;

                IF l_req_rec.search_min_availability = G_PA_MISS_NUM THEN
                        l_req_rec.search_min_availability := null;
                END IF;

                IF l_req_rec.search_exp_org_str_ver_id = G_PA_MISS_NUM THEN
                        l_req_rec.search_exp_org_str_ver_id := null;
                END IF;

                IF l_req_rec.search_exp_org_hier_name = G_PA_MISS_CHAR THEN
                        l_req_rec.search_exp_org_hier_name := null;
                END IF;

                IF l_req_rec.search_exp_start_org_id = G_PA_MISS_NUM THEN
                        l_req_rec.search_exp_start_org_id := null;
                END IF;

                IF l_req_rec.search_exp_start_org_name = G_PA_MISS_CHAR THEN
                        l_req_rec.search_exp_start_org_name := null;
                END IF;

                -- Search country code, name can be made as null, so we need to distinguish
                -- miss char with null
                IF l_req_rec.search_country_code = G_PA_MISS_CHAR THEN
                        l_req_rec.search_country_code := FND_API.G_MISS_CHAR;
                END IF;

                IF l_req_rec.search_country_name = G_PA_MISS_CHAR THEN
                        l_req_rec.search_country_name := FND_API.G_MISS_CHAR;
                END IF;

                IF l_req_rec.search_min_candidate_score = G_PA_MISS_NUM THEN
                        l_req_rec.search_min_candidate_score := null;
                END IF;

                IF l_req_rec.expenditure_org_id = G_PA_MISS_NUM THEN
                        l_req_rec.expenditure_org_id := null;
                END IF;

                IF l_req_rec.expenditure_org_name = G_PA_MISS_CHAR THEN
                        l_req_rec.expenditure_org_name := null;
                END IF;

                IF l_req_rec.expenditure_organization_id = G_PA_MISS_NUM THEN
                        l_req_rec.expenditure_organization_id := null;
                END IF;

                IF l_req_rec.expenditure_organization_name = G_PA_MISS_CHAR THEN
                        l_req_rec.expenditure_organization_name := null;
                END IF;

                IF l_req_rec.expenditure_type_class = G_PA_MISS_CHAR THEN
                        l_req_rec.expenditure_type_class := null;
                END IF;

                IF l_req_rec.expenditure_type = G_PA_MISS_CHAR THEN
                        l_req_rec.expenditure_type := null;
                END IF;

                -- Job Group and ID can be null, so we need to distinguish b/w null and miss chars
                IF l_req_rec.fcst_job_group_id = G_PA_MISS_NUM THEN
                        l_req_rec.fcst_job_group_id := FND_API.G_MISS_NUM;
                END IF;

                IF l_req_rec.fcst_job_group_name = G_PA_MISS_CHAR THEN
                        l_req_rec.fcst_job_group_name := FND_API.G_MISS_CHAR;
                END IF;

                IF l_req_rec.fcst_job_id = G_PA_MISS_NUM THEN
                        l_req_rec.fcst_job_id := FND_API.G_MISS_NUM;
                END IF;

                IF l_req_rec.fcst_job_name = G_PA_MISS_CHAR THEN
                        l_req_rec.fcst_job_name := FND_API.G_MISS_CHAR;
                END IF;

                IF l_req_rec.work_type_id = G_PA_MISS_NUM THEN
                        l_req_rec.work_type_id := null;
                END IF;

                IF l_req_rec.work_type_name = G_PA_MISS_CHAR THEN
                        l_req_rec.work_type_name := null;
                END IF;

                IF l_req_rec.bill_rate_option = G_PA_MISS_CHAR THEN
                        l_req_rec.bill_rate_option := 'NONE';
                END IF;

                IF l_req_rec.bill_rate_override = G_PA_MISS_NUM THEN
                        l_req_rec.bill_rate_override := null;
                END IF;

                IF l_req_rec.bill_rate_curr_override = G_PA_MISS_CHAR THEN
                        l_req_rec.bill_rate_curr_override := null;
                END IF;

                IF l_req_rec.markup_percent_override = G_PA_MISS_NUM THEN
                        l_req_rec.markup_percent_override := null;
                END IF;

                IF l_req_rec.discount_percentage = G_PA_MISS_NUM THEN
                        l_req_rec.discount_percentage := null;
                END IF;

                IF l_req_rec.rate_disc_reason_code = G_PA_MISS_CHAR THEN
                        l_req_rec.rate_disc_reason_code := null;
                END IF;

                IF l_req_rec.tp_rate_option = G_PA_MISS_CHAR THEN
                        l_req_rec.tp_rate_option := 'NONE';
                END IF;

                IF l_req_rec.tp_rate_override = G_PA_MISS_NUM THEN
                        l_req_rec.tp_rate_override := null;
                END IF;

                IF l_req_rec.tp_currency_override = G_PA_MISS_CHAR THEN
                        l_req_rec.tp_currency_override := null;
                END IF;

                IF l_req_rec.tp_calc_base_code_override = G_PA_MISS_CHAR THEN
                        l_req_rec.tp_calc_base_code_override := null;
                END IF;

                IF l_req_rec.tp_percent_applied_override = G_PA_MISS_NUM THEN
                        l_req_rec.tp_percent_applied_override := null;
                END IF;

                IF l_req_rec.extension_possible = G_PA_MISS_CHAR THEN
                        l_req_rec.extension_possible := null;
                END IF;

                IF l_req_rec.expense_owner = G_PA_MISS_CHAR THEN
                        l_req_rec.expense_owner := null;
                END IF;

                IF l_req_rec.expense_limit = G_PA_MISS_NUM THEN
                        l_req_rec.expense_limit := null;
                END IF;

                IF l_req_rec.orig_system_code = G_PA_MISS_CHAR THEN
                        l_req_rec.orig_system_code := null;
                END IF;

                IF l_req_rec.orig_system_reference = G_PA_MISS_CHAR THEN
                        l_req_rec.orig_system_reference := null;
                END IF;

                IF l_req_rec.record_version_number = G_PA_MISS_NUM THEN
                        l_req_rec.record_version_number := 1;
                END IF;

                IF l_req_rec.attribute_category = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute_category := null;
                END IF;

                IF l_req_rec.attribute1 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute1 := null;
                END IF;

                IF l_req_rec.attribute2 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute2 := null;
                END IF;

                IF l_req_rec.attribute3 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute3 := null;
                END IF;

                IF l_req_rec.attribute4 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute4 := null;
                END IF;

                IF l_req_rec.attribute5 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute5 := null;
                END IF;

                IF l_req_rec.attribute6 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute6 := null;
                END IF;

                IF l_req_rec.attribute7 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute7 := null;
                END IF;

                IF l_req_rec.attribute8 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute8 := null;
                END IF;

                IF l_req_rec.attribute9 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute9 := null;
                END IF;

                IF l_req_rec.attribute10 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute10 := null;
                END IF;

                IF l_req_rec.attribute11 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute11 := null;
                END IF;

                IF l_req_rec.attribute12 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute12 := null;
                END IF;

                IF l_req_rec.attribute13 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute13 := null;
                END IF;

                IF l_req_rec.attribute14 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute14 := null;
                END IF;

                IF l_req_rec.attribute15 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute15 := null;
                END IF;


                -- Mandatory Parameters Check
                -----------------------------

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory parameter validation starts', l_log_level);
                END IF;

                IF l_req_rec.number_of_requirements IS NULL THEN
                        l_missing_params := l_missing_params||', NUMBER_OF_REQUIREMENTS';
                END IF;

                IF l_req_rec.project_role_id IS NULL AND l_req_rec.project_role_name IS NULL THEN
                        l_missing_params := l_missing_params||', PROJECT_ROLE_ID, PROJECT_ROLE_NAME';
                END IF;

                IF (l_req_rec.team_template_id IS NULL AND l_req_rec.project_id IS NULL
                        AND l_req_rec.project_name IS NULL AND l_req_rec.project_number IS NULL
                     )
                    OR
                    (l_req_rec.team_template_id IS NOT NULL AND
                        (l_req_rec.project_id IS NOT NULL OR l_req_rec.project_name IS NOT NULL
                                OR l_req_rec.project_number IS NOT NULL
                        )
                     )
                THEN
                        -- Note that here we are supporting only Project Requirment and Team Template Requirment Flow.
                        -- We are not supporting  apply team template flow in which team template id and project id
                        -- both are present.
                        l_missing_params := l_missing_params||', TEAM_TEMPLATE_ID, PROJECT_ID, PROJECT_NAME, PROJECT_NUMBER';
                END IF;

                IF l_req_rec.start_date IS NULL OR l_req_rec.end_date IS NULL THEN
                        l_missing_params := l_missing_params||', START_DATE, END_DATE';
                END IF;

                -- Requirment status is not mandatory, if not passed we default it to 101 (Open)
                --IF l_req_rec.status_code IS NULL AND l_req_rec.status_name IS NULL THEN
                --        l_missing_params := l_missing_params||', STATUS_CODE, STATUS_NAME';
                --END IF;
                IF l_req_rec.status_code IS NULL AND l_req_rec.status_name IS NULL THEN
                       l_req_rec.status_code := 101;
                END IF;

                IF l_req_rec.location_id IS NULL OR l_req_rec.location_id = FND_API.G_MISS_NUM THEN
                        -- If either city or state (or) both are passed ,then country is
                        -- mandatory
                        IF (l_req_rec.location_country_code IS NULL AND l_req_rec.location_country_name IS NULL)
                           OR (l_req_rec.location_country_code =  FND_API.G_MISS_CHAR AND l_req_rec.location_country_name = FND_API.G_MISS_CHAR)
                        THEN
                                IF (l_req_rec.location_region <> FND_API.G_MISS_CHAR AND l_req_rec.location_region IS NOT NULL)
                                    OR (l_req_rec.location_city <> FND_API.G_MISS_CHAR AND l_req_rec.location_city IS NOT NULL)
                                THEN
                                        l_missing_params := l_missing_params||', LOCATION_COUNTRY_CODE, LOCATION_COUNTRY_NAME';
                                        l_valid_country := 'N';
                                END IF;
                        ELSIF l_req_rec.location_country_code IS NOT NULL AND l_req_rec.location_country_code <> FND_API.G_MISS_CHAR
                        THEN
                                OPEN c_derive_country_name(l_req_rec.location_country_code);
                                FETCH c_derive_country_name INTO l_req_rec.location_country_name;
                                IF c_derive_country_name%NOTFOUND THEN
                                        -- Invalid Country code passed.
                                        l_missing_params := l_missing_params||', LOCATION_COUNTRY_CODE';
                                        l_valid_country := 'N';
                                ELSE
                                        l_valid_country := 'Y';
                                END IF;
                                CLOSE c_derive_country_name;
                        ELSIF l_req_rec.location_country_name IS NOT NULL AND l_req_rec.location_country_name <> FND_API.G_MISS_CHAR
                        THEN
                              OPEN c_derive_country_code(l_req_rec.location_country_name);
                              FETCH c_derive_country_code INTO l_req_rec.location_country_code;
                              IF c_derive_country_code%NOTFOUND THEN
                                        -- Invalid Country Name passed.
                                        l_missing_params := l_missing_params||', LOCATION_COUNTRY_NAME';
                                        l_valid_country := 'N';
                               ELSE
                                        l_valid_country := 'Y';
                              END IF;
                              CLOSE c_derive_country_code;
                        END IF;

                        -- If the country is valid,then proceed with the state and city validations
                        IF l_valid_country = 'Y' AND l_req_rec.location_country_code IS NOT NULL
                        AND l_req_rec.location_country_code <> FND_API.G_MISS_CHAR
                        THEN

                                l_dummy_country_code := l_req_rec.location_country_code;
                                IF l_req_rec.location_region IS NULL OR l_req_rec.location_region = FND_API.G_MISS_CHAR THEN
                                        l_dummy_state := null;
                                ELSE
                                        l_dummy_state := l_req_rec.location_region;
                                END IF;

                                IF l_req_rec.location_city IS NULL OR l_req_rec.location_city = FND_API.G_MISS_CHAR THEN
                                        l_dummy_city := null;
                                ELSE
                                        l_dummy_city := l_req_rec.location_city;
                                END IF;

                                PA_LOCATION_UTILS.CHECK_LOCATION_EXISTS
                                (
                                         p_country_code         => l_dummy_country_code
                                        ,p_city		        => l_dummy_city
                                        ,p_region	        => l_dummy_state
                                        ,x_location_id	        => l_out_location_id
                                        ,x_return_status        => l_return_status
                                );

                                IF l_out_location_id IS NULL THEN
                                        PA_UTILS.ADD_MESSAGE('PA','PA_AMG_RES_INV_CRC_COMB');
                                        l_error_flag_local := 'Y'; -- 5148975
                                ELSE
                                        l_req_rec.location_id := l_out_location_id;
                                END IF;
                        END IF;
                ELSE
                        -- if location id is passed, then it will override the city, region, country code
                        OPEN c_get_location(l_req_rec.location_id);
                        FETCH c_get_location INTO l_req_rec.location_country_code, l_req_rec.location_region, l_req_rec.location_city;

                        IF c_get_location%NOTFOUND THEN
                                l_missing_params := l_missing_params||', LOCATION_ID';
                        END IF;
                        CLOSE c_get_location;
                END IF; -- l_req_rec.location_id IS NULL OR l_req_rec.location_id = FND_API.G_MISS_NUM


                IF l_req_rec.team_template_id IS NULL THEN
                        -- Project Requirement Flow

                        IF l_req_rec.calendar_type IS NULL OR (l_req_rec.calendar_type NOT IN('PROJECT','OTHER')) THEN
                                l_missing_params := l_missing_params||', CALENDAR_TYPE';
                        ELSE
                                IF l_req_rec.calendar_type = 'OTHER' AND l_req_rec.calendar_id IS NULL
                                        AND l_req_rec.calendar_name IS NULL
                                THEN
                                        l_missing_params := l_missing_params||', CALENDAR_ID, CALENDAR_NAME';
                                END IF;
                        END IF;

                        -- 5148545 : Added check for search org hier and start org name
                        IF l_req_rec.search_exp_org_str_ver_id IS NULL AND l_req_rec.search_exp_org_hier_name IS NULL
                        AND (l_req_rec.search_exp_start_org_id IS NOT NULL OR l_req_rec.search_exp_start_org_name IS NOT NULL) THEN
                                l_missing_params := l_missing_params||', SEARCH_EXP_ORG_STR_VER_ID, SEARCH_EXP_ORG_HIER_NAME';
                        END IF;

                        IF l_req_rec.search_exp_start_org_id IS NULL AND l_req_rec.search_exp_start_org_name IS NULL
                        AND (l_req_rec.search_exp_org_str_ver_id IS NOT NULL OR l_req_rec.search_exp_org_hier_name IS NOT NULL) THEN
                                l_missing_params := l_missing_params||', SEARCH_EXP_START_ORG_ID, SEARCH_EXP_START_ORG_NAME';
                        END IF;


                        IF l_req_rec.bill_rate_option IS NULL OR l_req_rec.bill_rate_option NOT IN('RATE','MARKUP','DISCOUNT','NONE') THEN
                                l_missing_params := l_missing_params||', BILL_RATE_OPTION';
                        ELSE
                                IF l_req_rec.bill_rate_option = 'NONE' THEN
                                        l_req_rec.bill_rate_override := null;
                                        l_req_rec.bill_rate_curr_override := null;
                                        l_req_rec.markup_percent_override := null;
                                        l_req_rec.discount_percentage := null;
                                        l_req_rec.rate_disc_reason_code := null;
                                ELSIF l_req_rec.bill_rate_option = 'RATE' THEN
                                        l_req_rec.markup_percent_override := null;
                                        l_req_rec.discount_percentage := null;
                                        IF l_req_rec.bill_rate_override IS NULL THEN
                                                l_missing_params := l_missing_params||', BILL_RATE_OVERRIDE';
                                        END IF;
                                ELSIF l_req_rec.bill_rate_option = 'MARKUP' THEN
                                        l_req_rec.bill_rate_override := null;
                                        l_req_rec.bill_rate_curr_override := null;
                                        l_req_rec.discount_percentage := null;
                                        IF l_req_rec.markup_percent_override IS NULL THEN
                                                l_missing_params := l_missing_params||', MARKUP_PERCENT_OVERRIDE';
                                        END IF;
                                ELSIF l_req_rec.bill_rate_option = 'DISCOUNT' THEN
                                        l_req_rec.bill_rate_override := null;
                                        l_req_rec.bill_rate_curr_override := null;
                                        l_req_rec.markup_percent_override := null;
                                        IF l_req_rec.discount_percentage IS NULL THEN
                                                l_missing_params := l_missing_params||', DISCOUNT_PERCENTAGE';
                                        END IF;
                                END IF;
                        END IF;

                        IF l_req_rec.expenditure_type_class IS NULL AND l_req_rec.expenditure_type IS NOT NULL THEN
                                -- Expenditue type is specified then class must also be there
                                l_missing_params := l_missing_params||', EXPENDITURE_TYPE_CLASS';
                        ELSIF l_req_rec.expenditure_type_class IS NOT NULL AND l_req_rec.expenditure_type IS NULL THEN
                                l_missing_params := l_missing_params||', EXPENDITURE_TYPE';
                        END IF;

                        IF l_req_rec.tp_rate_option IS NULL OR l_req_rec.tp_rate_option NOT IN('RATE','BASIS','NONE') THEN
                                l_missing_params := l_missing_params||', TP_RATE_OPTION';
                        ELSE
                                IF l_req_rec.tp_rate_option = 'NONE' THEN
                                        l_req_rec.tp_rate_override := null;
                                        l_req_rec.tp_currency_override := null;
                                        l_req_rec.tp_calc_base_code_override := null;
                                        l_req_rec.tp_percent_applied_override := null;
                                ELSIF l_req_rec.tp_rate_option = 'RATE' THEN
                                        l_req_rec.tp_calc_base_code_override := null;
                                        l_req_rec.tp_percent_applied_override := null;
                                        IF l_req_rec.tp_rate_override IS NULL OR l_req_rec.tp_currency_override IS NULL THEN
                                                l_missing_params := l_missing_params||', TP_RATE_OVERRIDE, TP_CURRENCY_OVERRIDE';
                                        END IF;
                                ELSIF l_req_rec.tp_rate_option = 'BASIS' THEN
                                        l_req_rec.tp_rate_override := null;
                                        l_req_rec.tp_currency_override := null;
                                        IF l_req_rec.tp_calc_base_code_override IS NULL OR l_req_rec.tp_percent_applied_override IS NULL THEN
                                                l_missing_params := l_missing_params||', TP_CALC_BASE_CODE_OVERRIDE, TP_PERCENT_APPLIED_OVERRIDE';
                                        END IF;
                                END IF;
                        END IF;

                        IF l_req_rec.extension_possible IS NOT NULL AND l_req_rec.extension_possible NOT IN ('Y','N') THEN
                                l_missing_params := l_missing_params||', EXTENSION_POSSIBLE';
                        END IF;
                END IF; -- l_req_rec.team_template_id IS NULL THEN

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory parameter validation over. List of Missing Parameters='||l_missing_params, l_log_level);
                END IF;

                IF l_missing_params IS NOT NULL THEN
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                        l_error_flag_local := 'Y';
                END IF;

                -- NullOut parameters which are not required in team template flow
                IF l_req_rec.team_template_id IS NOT NULL THEN
                        -- Team Template flow
                        l_req_rec.extension_possible := null;
                        --5152025 : Mistakenly work_type_id and work_type_name was getting nulled out
                        --l_req_rec.work_type_id := null;
                        --l_req_rec.work_type_name := null;
                        l_req_rec.bill_rate_override := null;
                        l_req_rec.bill_rate_curr_override := null;
                        l_req_rec.markup_percent_override := null;
                        l_req_rec.discount_percentage := null;
                        l_req_rec.rate_disc_reason_code := null;
                        l_req_rec.tp_rate_override := null;
                        l_req_rec.tp_currency_override := null;
                        l_req_rec.tp_calc_base_code_override := null;
                        l_req_rec.tp_percent_applied_override := null;
                        l_req_rec.expense_owner := null;
                        l_req_rec.expense_limit := null;
                        l_req_rec.fcst_job_id := null;
                        l_req_rec.fcst_job_group_id := null;
                        l_req_rec.expenditure_org_id := null;
                        l_req_rec.expenditure_organization_id := null;
                        l_req_rec.expenditure_type_class := null;
                        l_req_rec.expenditure_type := null;
                        l_req_rec.fcst_job_group_name := null;
                        l_req_rec.fcst_job_name := null;
                        l_req_rec.expenditure_org_name := null;
                        l_req_rec.expenditure_organization_name := null;
                        l_req_rec.start_adv_action_set_flag := null;
                        l_req_rec.adv_action_set_id := null;
                        l_req_rec.adv_action_set_name := null;
                END IF; -- l_req_rec.team_template_id IS NOT NULL THEN


                -- Project Name, Number to ID Conversion
                -- Though it is done by pa_assignmnts_pub.create_assignment
                -- But we require to get project_id so that we can defualt
                -- values from the project and check security on project
                -- Also project name to id conversion does not happen by internal APIs
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Deriving ProjectId', l_log_level);
                END IF;

                IF l_error_flag_local <> 'Y' AND l_req_rec.team_template_id IS NULL THEN
                        l_project_id_tmp := l_req_rec.project_id;
                        IF l_req_rec.project_number IS NOT NULL THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;

                                PA_PROJECT_UTILS2.CHECK_PROJECT_NUMBER_OR_ID(
                                         p_project_id           => l_project_id_tmp
                                        ,p_project_number       => l_req_rec.project_number
                                        ,p_check_id_flag        => PA_STARTUP.g_check_id_flag
                                        ,x_project_id           => l_req_rec.project_id
                                        ,x_return_status        => l_return_status
                                        ,x_error_message_code   => l_error_message_code );

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;
                        IF l_req_rec.project_name IS NOT NULL THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;

                                PA_TASKS_MAINT_UTILS.CHECK_PROJECT_NAME_OR_ID(
                                         p_project_id           => l_project_id_tmp
                                        ,p_project_name         => l_req_rec.project_name
                                        ,p_check_id_flag        => PA_STARTUP.g_check_id_flag
                                        ,x_project_id           => l_req_rec.project_id
                                        ,x_return_status        => l_return_status
                                        ,x_error_msg_code       => l_error_message_code );

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;
                END IF; -- l_error_flag_local <> 'Y' AND l_req_rec.team_template_id IS NULL

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'ProjectId='||l_req_rec.project_id, l_log_level);
                        pa_debug.write(l_module, 'TeamTemplateId='||l_req_rec.team_template_id, l_log_level);
                        pa_debug.write(l_module, 'l_error_flag_local='||l_error_flag_local, l_log_level);
                END IF;

                IF l_error_flag_local <> 'Y' AND l_req_rec.team_template_id IS NULL THEN
                        -- Project Requirement Flow
                        l_role_list_id := null;
                        l_multi_currency_billing_flag := null;
                        l_calendar_id := null;
                        l_work_type_id := null;
                        l_location_id := null;

                        OPEN c_get_project_dtls(l_req_rec.project_id);
                        FETCH c_get_project_dtls INTO l_role_list_id, l_multi_currency_billing_flag, l_calendar_id
                                , l_work_type_id, l_location_id;
                        CLOSE c_get_project_dtls;

                        IF l_req_rec.bill_rate_option = 'RATE' AND  nvl(l_multi_currency_billing_flag,'N') <> 'Y'
                        THEN
                                l_req_rec.bill_rate_curr_override := null;
                        END IF;
                ELSIF l_error_flag_local <> 'Y' AND l_req_rec.team_template_id IS NOT NULL THEN
                        -- Team Template Flow
                        l_role_list_id := null;
                        l_multi_currency_billing_flag := null;
                        l_calendar_id := null;
                        l_work_type_id := null;
                        OPEN c_get_team_templ_dtls(l_req_rec.team_template_id);
                        FETCH c_get_team_templ_dtls INTO l_role_list_id, l_calendar_id, l_work_type_id;
                        CLOSE c_get_team_templ_dtls;
                END IF;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Defaults Value from Project or Team Template Flow', l_log_level);
                        pa_debug.write(l_module, 'l_role_list_id='||l_role_list_id, l_log_level);
                        pa_debug.write(l_module, 'l_multi_currency_billing_flag='||l_multi_currency_billing_flag, l_log_level);
                        pa_debug.write(l_module, 'l_calendar_id='||l_calendar_id, l_log_level);
                        pa_debug.write(l_module, 'l_work_type_id='||l_work_type_id, l_log_level);
                        pa_debug.write(l_module, 'l_location_id='||l_location_id, l_log_level);
                END IF;


                -- Default calendar, location, work type, requirement name, min max res job level
                IF l_error_flag_local <> 'Y' THEN
                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Default values of calendar, work type, location from project or team template', l_log_level);
                        END IF;

                        -- For OTHER type of calendar there is alredy check done above in code
                        -- For PROJECT type ignore the user value and take the project value
                        IF l_req_rec.calendar_type = 'PROJECT' THEN
                                l_req_rec.calendar_id := l_calendar_id;
                        END IF;

                        IF l_req_rec.work_type_id IS NULL AND l_req_rec.work_type_name IS NULL
                        THEN
                                l_req_rec.work_type_id := l_work_type_id;
                        END IF;

                        IF l_req_rec.project_id IS NOT NULL AND l_req_rec.location_id = FND_API.G_MISS_NUM
                                AND l_req_rec.location_country_code = FND_API.G_MISS_CHAR
                                AND l_req_rec.location_country_name = FND_API.G_MISS_CHAR
                                AND l_req_rec.location_region = FND_API.G_MISS_CHAR
                                AND l_req_rec.location_city = FND_API.G_MISS_CHAR
                        THEN
                                l_req_rec.location_id := l_location_id;
                        END IF;

                        -- Role Validation
                        -- Though it is done by pa_assignmnts_pub.create_assignment
                        -- But we require to get role_id so that we can defualt
                        -- values from the role
                        -- Defaulting is required

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Validating Role against Role List and doing Role Name to ID conversion', l_log_level);
                        END IF;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_error_message_code := null;
                        l_project_role_id_tmp := l_req_rec.project_role_id;

                        /*passing p_check_id_flag as Y for bug 8557593 */
                        PA_ROLE_UTILS.Check_Role_RoleList (
                                p_role_id               => l_project_role_id_tmp
                                ,p_role_name            => l_req_rec.project_role_name
                                ,p_role_list_id         => l_role_list_id
                                ,p_role_list_name       => NULL
                                ,p_check_id_flag        => 'Y'
                                ,x_role_id              => l_req_rec.project_role_id
                                ,x_role_list_id         => l_role_list_id
                                ,x_return_status        => l_return_status
                                ,x_error_message_code   => l_error_message_code );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After role validation Role id='||l_req_rec.project_role_id, l_log_level);
                                pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                        END IF;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                l_error_flag_local := 'Y';
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Defaulting RequirmentName, Min Job Level, Max Job Level from Role ', l_log_level);
                        END IF;

                        l_role_name := null;
                        l_min_job_level := null;
                        l_max_job_level := null;
                        l_fcst_job_id := null;

                        OPEN c_get_role_dtls(l_req_rec.project_role_id);
                        FETCH c_get_role_dtls INTO l_role_name, l_min_job_level, l_max_job_level, l_fcst_job_id;
                        CLOSE c_get_role_dtls;

                        IF l_req_rec.requirement_name IS NULL THEN
                                l_req_rec.requirement_name := l_role_name;
                        END IF;
                        IF l_req_rec.min_resource_job_level IS NULL THEN
                                l_req_rec.min_resource_job_level := l_min_job_level;
                        END IF;
                        IF l_req_rec.max_resource_job_level IS NULL THEN
                                l_req_rec.max_resource_job_level := l_max_job_level;
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'l_role_name='||l_role_name, l_log_level);
                                pa_debug.write(l_module, 'l_min_job_level='||l_min_job_level, l_log_level);
                                pa_debug.write(l_module, 'l_max_job_level='||l_max_job_level, l_log_level);
                        END IF;
                END IF; -- l_error_flag_local <> 'Y' THEN

                -- All validations are not required as some validation is done in underlying code
                -- Here, we are doing only those validations which are not done internally.
                -- NOTE : In update flow, all these validations are done and it is taken from there
                --        Ideally in create flow also, underlying code should do these validations
                --        But we are doing here to avoid more code changes in existing code.

                IF l_error_flag_local <> 'Y' AND l_req_rec.project_id IS NOT NULL THEN
                        -- Project Requirement Flow

                        -- Search Info Validation
                        -------------------------


                        -- 5147921 : In create requirment flow, weightages were not checked between 0 and 100
                        -- They are checked by internal API in update flow but not in create flow.
                        -- Hence added checks here

                        IF (l_req_rec.comp_match_weighting IS NOT NULL AND (l_req_rec.comp_match_weighting < 0 OR l_req_rec.comp_match_weighting > 100))
                        OR (l_req_rec.avail_match_weighting IS NOT NULL AND (l_req_rec.avail_match_weighting < 0 OR l_req_rec.avail_match_weighting > 100))
                        OR (l_req_rec.job_level_match_weighting IS NOT NULL AND (l_req_rec.job_level_match_weighting < 0 OR l_req_rec.job_level_match_weighting > 100))
                        THEN
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_MATCH_WEIGHTING');
                                l_error_flag_local := 'Y';
                        END IF;

                        IF l_req_rec.search_min_availability IS NOT NULL AND (l_req_rec.search_min_availability < 0 OR l_req_rec.search_min_availability > 100)
                        THEN
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_MIN_AVAIL_INVALID');
                                l_error_flag_local := 'Y';
                        END IF;

                        IF l_req_rec.search_min_candidate_score IS NOT NULL AND (l_req_rec.search_min_candidate_score < 0 OR l_req_rec.search_min_candidate_score > 100 )
                        THEN
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_MIN_CAN_SCORE_INVALID');
                                l_error_flag_local := 'Y';
                        END IF;

                        IF (l_req_rec.search_country_code IS NOT NULL AND l_req_rec.search_country_code <> FND_API.G_MISS_CHAR)
                                OR (l_req_rec.search_country_name IS NOT NULL AND l_req_rec.search_country_name <> FND_API.G_MISS_CHAR)
                        THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;
                                l_search_country_code_tmp := l_req_rec.search_country_code;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Search Country Code and Name to Code Conversion', l_log_level);
                                END IF;

                                PA_LOCATION_UTILS.CHECK_COUNTRY_NAME_OR_CODE
                                        (p_country_code         => l_search_country_code_tmp,
                                        p_country_name          => l_req_rec.search_country_name,
                                        p_check_id_flag         => PA_STARTUP.G_Check_ID_Flag,
                                        x_country_code          => l_req_rec.search_country_code,
                                        x_return_status         => l_return_status,
                                        x_error_message_code    => l_error_message_code);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Search Country Code Validation l_req_rec.search_country_code='||l_req_rec.search_country_code, l_log_level);
                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                END IF;

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;   -- l_req_rec.search_country_code IS NOT NULL

                        IF l_req_rec.search_exp_org_hier_name IS NOT NULL OR l_req_rec.search_exp_org_str_ver_id IS NOT NULL THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;
                                l_srch_exp_org_str_ver_id_tmp := l_req_rec.search_exp_org_str_ver_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Search Organization Hierarchy and Name to ID Conversion', l_log_level);
                                END IF;

                                PA_HR_ORG_UTILS.CHECK_ORGHIERNAME_OR_ID
                                        (p_org_hierarchy_version_id     => l_srch_exp_org_str_ver_id_tmp,
                                        p_org_hierarchy_name            => l_req_rec.search_exp_org_hier_name,
                                        p_check_id_flag                 => PA_STARTUP.G_Check_ID_Flag,
                                        x_org_hierarchy_version_id      => l_req_rec.search_exp_org_str_ver_id,
                                        x_return_status                 => l_return_status,
                                        x_error_msg_code                => l_error_message_code);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Search Organization Hierarchy Validation l_req_rec.search_exp_org_str_ver_id='||l_req_rec.search_exp_org_str_ver_id, l_log_level);
                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                END IF;


                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        -- PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
					PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_SRCH_ORG_HIER_NA');      -- Changed for Bug 5148154
                                        l_error_flag_local := 'Y';
                                ELSE
                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_error_message_code := null;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'Validating Search Organization Hierarchy Type', l_log_level);
                                        END IF;

                                        PA_ORG_UTILS.CHECK_ORGHIERARCHY_TYPE(
                                                p_org_structure_version_id      => l_req_rec.search_exp_org_str_ver_id,
                                                p_org_structure_type            => 'EXPENDITURES',
                                                x_return_status                 => l_return_status,
                                                x_error_message_code            => l_error_message_code);

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'After Search Organization Hierarchy Type Validation', l_log_level);
                                                pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                                pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                        END IF;

                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;
                        END IF; -- l_req_rec.search_exp_org_hier_name IS NOT NULL

                        IF l_req_rec.search_exp_start_org_name IS NOT NULL OR l_req_rec.search_exp_start_org_id IS NOT NULL THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;
                                l_search_exp_start_org_id_tmp := l_req_rec.search_exp_start_org_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Search Organization and Name to ID Conversion', l_log_level);
                                END IF;

                                PA_HR_ORG_UTILS.CHECK_ORGNAME_OR_ID
                                        (p_organization_id      => l_search_exp_start_org_id_tmp,
                                        p_organization_name     => l_req_rec.search_exp_start_org_name,
                                        p_check_id_flag         => PA_STARTUP.G_Check_ID_Flag,
                                        x_organization_id       => l_req_rec.search_exp_start_org_id,
                                        x_return_status         => l_return_status,
                                        x_error_msg_code        => l_error_message_code);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Search Organization Name Validation', l_log_level);
                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                END IF;

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                        l_error_flag_local := 'Y';
                                ELSE
                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_error_message_code := null;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'Validating Search Organization Type', l_log_level);
                                        END IF;

                                        PA_ORG_UTILS.CHECK_ORG_TYPE(
                                                p_organization_id       => l_req_rec.search_exp_start_org_id,
                                                p_org_structure_type    => 'EXPENDITURES',
                                                x_return_status         => l_return_status,
                                                x_error_message_code    => l_error_message_code);

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'After Search Organization Type Validation', l_log_level);
                                                pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                                pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                        END IF;

                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;
                        END IF; -- l_req_rec.search_exp_start_org_name IS NOT NULL

                        IF l_req_rec.search_exp_org_str_ver_id IS NOT NULL AND l_req_rec.search_exp_start_org_id IS NOT NULL THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Search Organization wrt Search Org Hierarchy', l_log_level);
                                END IF;

                                PA_ORG_UTILS.CHECK_ORG_IN_ORGHIERARCHY(
                                p_organization_id               => l_req_rec.search_exp_start_org_id,
                                p_org_structure_version_id      => l_req_rec.search_exp_org_str_ver_id,
                                p_org_structure_type            => 'EXPENDITURES',
                                x_return_status                 => l_return_status,
                                x_error_message_code            => l_error_message_code);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Search wrt Search Org Hierarchy Validation', l_log_level);
                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                END IF;

                                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                        PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;

                        -- Financial Information Validation
                        -----------------------------------

                        IF l_req_rec.expenditure_org_id IS NOT NULL OR l_req_rec.expenditure_org_name IS NOT NULL THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;
                                l_expenditure_org_id_tmp := l_req_rec.expenditure_org_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Expenditure OU and Name to ID conversion', l_log_level);
                                END IF;

                                PA_HR_ORG_UTILS.CHECK_ORGNAME_OR_ID
                                        (p_organization_id      => l_expenditure_org_id_tmp,
                                        p_organization_name     => l_req_rec.expenditure_org_name,
                                        p_check_id_flag         => PA_STARTUP.G_Check_ID_Flag,
                                        x_organization_id       => l_req_rec.expenditure_org_id,
                                        x_return_status         => l_return_status,
                                        x_error_msg_code        => l_error_message_code );

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Expenditure OU Validation l_req_rec.expenditure_org_id='||l_req_rec.expenditure_org_id, l_log_level);
                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                END IF;

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_EXP_OU_INVALID');
                                        l_error_flag_local := 'Y';
                                ELSE
                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_error_message_code := null;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'Validating OU to be used in PA Implementation', l_log_level);
                                        END IF;

                                        PA_HR_UPDATE_API.CHECK_EXP_OU
                                                (p_org_id             => l_req_rec.expenditure_org_id
                                                ,x_return_status      => l_return_status
                                                ,x_error_message_code => l_error_message_code ) ;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'After Expenditure OU to be used in PA Implementation Validation', l_log_level);
                                                pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                                pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                        END IF;

                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                                l_error_flag_local := 'Y';
					-- Start 1: Changed for Bug 5202329
                                        ELSE
                                                SELECT business_group_id
                                                INTO l_business_group_id
                                                FROM hr_organization_units
                                                WHERE organization_id = l_req_rec.expenditure_org_id;
                                        END IF;
					-- End 1: Changed for Bug 5202329
                                END IF;
                        END IF; -- l_req_rec.expenditure_org_id IS NOT NULL

			-- l_error_flag_local <> 'Y' for Bug 5202329
                        IF l_error_flag_local <> 'Y' AND (l_req_rec.expenditure_organization_id IS NOT NULL
			   OR l_req_rec.expenditure_organization_name IS NOT NULL) THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;
                                l_exp_organization_id_tmp := l_req_rec.expenditure_organization_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Expenditure Organization and Name to ID conversion', l_log_level);
                                END IF;

                                PA_HR_ORG_UTILS.CHECK_ORGNAME_OR_ID
                                        (p_organization_id      => l_exp_organization_id_tmp,
                                        p_organization_name     => l_req_rec.expenditure_organization_name,
                                        p_check_id_flag         => PA_STARTUP.G_Check_ID_Flag,
                                        x_organization_id       => l_req_rec.expenditure_organization_id,
                                        x_return_status         => l_return_status,
                                        x_error_msg_code        => l_error_message_code );

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Expenditure Organization Validation', l_log_level);
                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                END IF;

				-- Start 2: Changes for Bug 5202329
                                IF l_error_message_code = 'PA_ORG_NOT_UNIQUE' AND l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        OPEN c_get_exp_organization_id(l_business_group_id, l_req_rec.expenditure_organization_name);
                                        FETCH c_get_exp_organization_id INTO l_req_rec.expenditure_organization_id;
                                        IF c_get_exp_organization_id%NOTFOUND IS NULL THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_EXP_ORG_INVALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                        CLOSE c_get_exp_organization_id;
                                END IF;
                                IF l_error_message_code <> 'PA_ORG_NOT_UNIQUE' AND l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				-- End 2: Changes for Bug 5202329
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_EXP_ORG_INVALID');
                                        l_error_flag_local := 'Y';
                                ELSE
                                        l_valid_flag := null;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'Validating Expenditure Organization to be used in PA', l_log_level);
                                        END IF;

                                        l_valid_flag := PA_UTILS2.CHECKEXPORG
                                                (x_org_id       => l_req_rec.expenditure_organization_id,
                                                x_txn_date      => l_req_rec.start_date);

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'After Expenditure Organization to be used in PA Implementation Validation', l_log_level);
                                                pa_debug.write(l_module, 'l_valid_flag='||l_valid_flag, l_log_level);
                                        END IF;

                                        IF l_valid_flag <> 'Y' THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_EXP_ORG');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;
                        END IF; --  l_req_rec.expenditure_organization_id IS NOT NULL

                        -- Forecast Info Validations
                        -----------------------------

                        IF (l_req_rec.fcst_job_group_name IS NOT NULL  AND l_req_rec.fcst_job_group_name <> FND_API.G_MISS_CHAR)
                                OR (l_req_rec.fcst_job_group_id IS NOT NULL AND l_req_rec.fcst_job_group_id <> FND_API.G_MISS_NUM)
                        THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;
                                l_fcst_job_group_id_tmp := l_req_rec.fcst_job_group_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Job Group and Name to ID conversion', l_log_level);
                                END IF;

                                PA_JOB_UTILS.CHECK_JOB_GROUPNAME_OR_ID(
                                        p_job_group_id          => l_fcst_job_group_id_tmp
                                        ,p_job_group_name       => l_req_rec.fcst_job_group_name
                                        ,p_check_id_flag        => PA_STARTUP.G_Check_ID_Flag
                                        ,x_job_group_id         => l_req_rec.fcst_job_group_id
                                        ,x_return_status        => l_return_status
                                        ,x_error_message_code   => l_error_message_code );

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Job Group Validation l_req_rec.fcst_job_group_id='||l_req_rec.fcst_job_group_id, l_log_level);
                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                END IF;

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;

                        IF (l_req_rec.fcst_job_name IS NOT NULL AND l_req_rec.fcst_job_name <> FND_API.G_MISS_CHAR)
                                OR (l_req_rec.fcst_job_id IS NOT NULL  AND l_req_rec.fcst_job_id <> FND_API.G_MISS_NUM)
                        THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;
                                l_fcst_job_id_tmp := l_req_rec.fcst_job_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Job and Name to ID conversion', l_log_level);
                                END IF;

                                PA_JOB_UTILS.CHECK_JOBNAME_OR_ID (
                                        p_job_id                => l_fcst_job_id_tmp
                                        ,p_job_name		=> l_req_rec.fcst_job_name
                                        ,p_job_group_id         => l_req_rec.fcst_job_group_id -- 5144999
                                        ,p_check_id_flag	=> PA_STARTUP.G_Check_ID_Flag
                                        ,x_job_id		=> l_req_rec.fcst_job_id
                                        ,x_return_status	=> l_return_status
                                        ,x_error_message_code	=> l_error_message_code);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Job Validation l_req_rec.fcst_job_id='||l_req_rec.fcst_job_id, l_log_level);
                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                END IF;

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;

                        IF l_req_rec.fcst_job_id IS NOT NULL AND l_req_rec.fcst_job_id <> FND_API.G_MISS_NUM
                        AND l_req_rec.fcst_job_group_id IS NOT NULL  AND l_req_rec.fcst_job_group_id <> FND_API.G_MISS_NUM
                        THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Job wrt Job Group', l_log_level);
                                END IF;

                                PA_JOB_UTILS.VALIDATE_JOB_RELATIONSHIP (
                                        p_job_id                => l_req_rec.fcst_job_id
                                        ,p_job_group_id         => l_req_rec.fcst_job_group_id
                                        ,x_return_status        => l_return_status
                                        ,x_error_message_code   => l_error_message_code);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Job wrt Job Group Validation', l_log_level);
                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                END IF;

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;


                        -- Bill Rate Options Validation
                        -------------------------------

                        IF l_req_rec.bill_rate_option <> 'NONE' THEN
                                l_rate_discount_reason_flag := 'N';
                                l_br_override_flag := 'N';
                                l_br_discount_override_flag := 'N';

                                OPEN get_bill_rate_override_flags(l_req_rec.project_id);
                                FETCH get_bill_rate_override_flags INTO  l_rate_discount_reason_flag, l_br_override_flag, l_br_discount_override_flag;
                                CLOSE get_bill_rate_override_flags;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Bill Rate Options', l_log_level);
                                        pa_debug.write(l_module, 'l_rate_discount_reason_flag='||l_rate_discount_reason_flag, l_log_level);
                                        pa_debug.write(l_module, 'l_br_override_flag='||l_br_override_flag, l_log_level);
                                        pa_debug.write(l_module, 'l_br_discount_override_flag='||l_br_discount_override_flag, l_log_level);
                                END IF;

                                IF l_req_rec.bill_rate_option = 'RATE' THEN
                                        IF l_br_override_flag <> 'Y' OR l_req_rec.bill_rate_override <= 0 THEN /* OR l_req_rec.bill_rate_override > 100 - Removed for Bug 5703021*/
                                                IF l_br_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_BILL_RATE_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_BILL_RATE_OVRD');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;

                                        -- 5144288, 5144369 : Added bill rate currency check below
                                        -- Begin
                                        IF nvl(l_multi_currency_billing_flag,'N') = 'Y' AND l_br_override_flag = 'Y' THEN

                                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                                l_error_message_code := null;
                                                l_bill_currency_override_tmp := l_req_rec.bill_rate_curr_override;

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'Validating Bill Rate Currency', l_log_level);
                                                END IF;

                                                PA_PROJECTS_MAINT_UTILS.CHECK_CURRENCY_NAME_OR_CODE(
                                                        p_agreement_currency       => l_bill_currency_override_tmp
                                                        ,p_agreement_currency_name  => null
                                                        ,p_check_id_flag            => 'Y'
                                                        ,x_agreement_currency       => l_req_rec.bill_rate_curr_override
                                                        ,x_return_status            => l_return_status
                                                        ,x_error_msg_code           => l_error_message_code);

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'After Bill Rate Currency Validation', l_log_level);
                                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                                END IF;

                                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_CISI_CURRENCY_NULL');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                        -- 5144288, 5144369 : End
                                ELSIF l_req_rec.bill_rate_option = 'MARKUP' THEN
					-- 5144675 Changed l_req_rec.markup_percent_override <= 0 to < 0
                                        IF l_br_override_flag <> 'Y' OR l_req_rec.markup_percent_override < 0
					   OR l_req_rec.markup_percent_override > 100 THEN
                                                IF l_br_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_BILL_RATE_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_MARKUP_PERCENT');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                ELSIF l_req_rec.bill_rate_option = 'DISCOUNT' THEN
					-- 5144675 Changed l_req_rec.discount_percentage <=0 to < 0
                                        IF l_br_discount_override_flag <> 'Y' OR l_req_rec.discount_percentage < 0
					   OR l_req_rec.discount_percentage > 100 THEN
                                                IF l_br_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_DISC_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_DISCOUNT_PERCENT');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                END IF;
                                IF l_req_rec.rate_disc_reason_code IS NULL THEN
                                        IF (l_rate_discount_reason_flag ='Y' AND (l_br_override_flag ='Y' OR l_br_discount_override_flag='Y') AND
                                                (l_req_rec.bill_rate_override IS NOT NULL OR l_req_rec.markup_percent_override IS NOT NULL OR l_req_rec.discount_percentage IS NOT NULL)
                                           )
                                        THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_RATE_DISC_REASON_REQUIRED');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                ELSE
                                        l_valid_flag := 'N';
                                        OPEN c_get_lookup_exists('RATE AND DISCOUNT REASON', l_req_rec.rate_disc_reason_code);
                                        FETCH c_get_lookup_exists INTO l_valid_flag;
                                        CLOSE c_get_lookup_exists;
                                        IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                                -- This is a new message, define it
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_DISC_RSN_INVALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Validating Bill Rate Options l_error_flag_local='||l_error_flag_local, l_log_level);
                                END IF;
                        END IF; -- l_req_rec.bill_rate_option <> 'NONE'

                        -- Transfer Price Rate Options Validation
                        -----------------------------------------

                        IF l_req_rec.tp_rate_option <> 'NONE' THEN

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Transfer Price Rate Options', l_log_level);
                                END IF;

                                IF l_req_rec.tp_rate_option = 'RATE' THEN
					-- 5144675 Changed l_req_rec.tp_rate_override <= 0 to  < 0
                                        IF l_req_rec.tp_rate_override < 0 OR l_req_rec.tp_rate_override > 100 THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_TP_RATE_OVRD');
                                                l_error_flag_local := 'Y';
                                        END IF;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_error_message_code := null;
                                        l_tp_currency_override_tmp := l_req_rec.tp_currency_override;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'Validating Transfer Price Rate Currency', l_log_level);
                                        END IF;

                                        PA_PROJECTS_MAINT_UTILS.CHECK_CURRENCY_NAME_OR_CODE(
                                                p_agreement_currency       => l_tp_currency_override_tmp
                                                ,p_agreement_currency_name  => null
                                                ,p_check_id_flag            => 'Y'
                                                ,x_agreement_currency       => l_req_rec.tp_currency_override
                                                ,x_return_status            => l_return_status
                                                ,x_error_msg_code           => l_error_message_code);

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'After Transfer Price Rate Currency Validation', l_log_level);
                                                pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                                pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                        END IF;

                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_CURR_NOT_VALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                ELSIF l_req_rec.tp_rate_option = 'BASIS' THEN
					-- 5144675 Changed l_req_rec.tp_percent_applied_override <=0 to < 0
                                        IF l_req_rec.tp_percent_applied_override < 0 OR l_req_rec.tp_percent_applied_override > 100  THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_APPLY_BASIS_PERCENT');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                        l_valid_flag := 'N';
                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'Validating Transfer Price Rate Basis', l_log_level);
                                        END IF;

                                        OPEN c_get_lookup_exists('CC_MARKUP_BASE_CODE', l_req_rec.tp_calc_base_code_override);
                                        FETCH c_get_lookup_exists INTO l_valid_flag;
                                        CLOSE c_get_lookup_exists;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'After Transfer Price Rate Basis Validation', l_log_level);
                                                pa_debug.write(l_module, 'l_valid_flag='||l_valid_flag, l_log_level);
                                        END IF;

                                        IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_TP_BASIS_INVALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Validating Transfer Price Rate Options l_error_flag_local='||l_error_flag_local, l_log_level);
                                END IF;
                        END IF; -- l_req_rec.tp_rate_option <> 'NONE'

                        -- Res Loan Agreement Validations
                        ---------------------------------

                        IF l_req_rec.expense_owner IS NOT NULL THEN
                                l_valid_flag := 'N';

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Expense Owner Option', l_log_level);
                                END IF;

                                OPEN c_get_lookup_exists('EXPENSE_OWNER_TYPE', l_req_rec.expense_owner);
                                FETCH c_get_lookup_exists INTO l_valid_flag;
                                CLOSE c_get_lookup_exists;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Expense Owner Option Validation', l_log_level);
                                        pa_debug.write(l_module, 'l_valid_flag='||l_valid_flag, l_log_level);
                                END IF;

                                IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_EXP_OWNER_INVALID');
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;
                END IF; -- l_error_flag_local <> 'Y' AND l_req_rec.project_id IS NOT NULL

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'After all validations l_error_flag_local='||l_error_flag_local, l_log_level);
                END IF;

                -- Flex field Validation
                ------------------------

                IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        VALIDATE_FLEX_FIELD(
                                  p_desc_flex_name         => 'PA_TEAM_ROLE_DESC_FLEX'
                                , p_attribute_category     => l_req_rec.attribute_category
                                , px_attribute1            => l_req_rec.attribute1
                                , px_attribute2            => l_req_rec.attribute2
                                , px_attribute3            => l_req_rec.attribute3
                                , px_attribute4            => l_req_rec.attribute4
                                , px_attribute5            => l_req_rec.attribute5
                                , px_attribute6            => l_req_rec.attribute6
                                , px_attribute7            => l_req_rec.attribute7
                                , px_attribute8            => l_req_rec.attribute8
                                , px_attribute9            => l_req_rec.attribute9
                                , px_attribute10           => l_req_rec.attribute10
                                , px_attribute11           => l_req_rec.attribute11
                                , px_attribute12           => l_req_rec.attribute12
                                , px_attribute13           => l_req_rec.attribute13
                                , px_attribute14           => l_req_rec.attribute14
                                , px_attribute15           => l_req_rec.attribute15
                                , x_return_status          => l_return_status
                                , x_msg_count		   => l_msg_count
                                , x_msg_data		   => l_msg_data
                         );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Flex Field Validation l_return_status='||l_return_status, l_log_level);
                                pa_debug.write(l_module, 'After Flex Field Validation l_msg_data='||l_msg_data, l_log_level);
                        END IF;


                        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS  THEN
                                -- This message does not have toekn defined, still it is ok to pass token as the value
                                -- returned by flex APIs because token are appended as it is
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_DFF_VALIDATION_FAILED',
                                                      'ERROR_MESSAGE', l_msg_data );
                                l_error_flag_local := 'Y';
                        END IF;
                END IF; -- l_error_flag_local <> 'Y'

                -- Security Check
                -----------------

                IF l_error_flag_local <> 'Y' THEN

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Checking Security for Record#'||i, l_log_level);
                        END IF;

                        IF l_req_rec.team_template_id IS NOT NULL THEN
                                l_privilege := 'PA_PRM_DEFINE_TEAM_TEMPLATE';
                                l_object_name := null;
                                l_object_key := null;
                        ELSIF l_req_rec.project_id IS NOT NULL THEN
                                l_privilege := 'PA_ASN_CR_AND_DL';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := null;
                        ELSE
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_UNEXPECTED ERROR');
                                raise FND_API.G_EXC_ERROR;
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'l_privilege='||l_privilege, l_log_level);
                                pa_debug.write(l_module, 'l_object_name='||l_object_name, l_log_level);
                                pa_debug.write(l_module, 'l_object_key='||l_object_key, l_log_level);
                        END IF;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                  x_ret_code       => l_ret_code
                                , x_return_status  => l_return_status
                                , x_msg_count      => l_msg_count
                                , x_msg_data       => l_msg_data
                                , p_init_msg_list   => 'F'
                                , p_privilege      => l_privilege
                                , p_object_name    => l_object_name
                                , p_object_key     => l_object_key);

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Security Check l_ret_code='||l_ret_code, l_log_level);
                        END IF;


                        IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                -- This message does not have token defined, but intentionally putting token
                                -- bcoz we still want to show the privielge name which is missing
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_CR_DL'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                l_error_flag_local := 'Y';
                        END IF;
                END IF;

                -- Call Core Actual API
                -----------------------

                IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling pa_assignments_pub.execute_create_assignment for Record#'||i, l_log_level);
                        END IF;

                        l_new_assignment_id_tbl := null;
                        l_new_assignment_id := null;
                        l_assignment_number := null;
                        l_assignment_row_id := null;
                        l_resource_id := null;

                        PA_ASSIGNMENTS_PUB.EXECUTE_CREATE_ASSIGNMENT
                        (
                                  p_api_version                 => p_api_version_number
                                , p_init_msg_list               => l_init_msg_list
                                , p_commit                      => l_commit
                                , p_validate_only               => l_validate_only
                                , p_asgn_creation_mode		=> l_asgn_creation_mode
                                , p_assignment_name		=> l_req_rec.requirement_name
                                , p_assignment_type		=> l_assignment_type
                                , p_assignment_template_id      => l_req_rec.team_template_id
--                                , p_source_assignment_id        => l_req_rec.source_requirement_id
                                , p_number_of_requirements      => l_req_rec.number_of_requirements
                                , p_project_role_id             => l_req_rec.project_role_id
                                , p_project_role_name           => l_req_rec.project_role_name
                                , p_project_id                  => l_req_rec.project_id
                                , p_project_name                => l_req_rec.project_name
                                , p_project_number              => l_req_rec.project_number
                --                , p_resource_id                 =>
                --                , p_project_party_id            =>
                --                , p_resource_name               =>
                --                , p_resource_source_id          => null
                                , p_staffing_owner_person_id    => l_req_rec.staffing_owner_person_id
                --                , p_staffing_owner_name         =>
                                , p_staffing_priority_code      => l_req_rec.staffing_priority_code
                                , p_staffing_priority_name      => l_req_rec.staffing_priority_name
                                , p_project_subteam_id          => l_req_rec.project_subteam_id
                                , p_project_subteam_name        => l_req_rec.project_subteam_name
                                , p_location_id                 => l_req_rec.location_id
                                , p_location_city               => l_req_rec.location_city
                                , p_location_region             => l_req_rec.location_region
                                , p_location_country_name       => l_req_rec.location_country_name
                                , p_location_country_code       => l_req_rec.location_country_code
                                , p_min_resource_job_level      => l_req_rec.min_resource_job_level
                                , p_max_resource_job_level	=> l_req_rec.max_resource_job_level
                                , p_description                 => l_req_rec.description
                                , p_additional_information      => l_req_rec.additional_information
                                , p_start_date                  => l_req_rec.start_date
                                , p_end_date                    => l_req_rec.end_date
                                , p_status_code                 => l_req_rec.status_code
                                , p_project_status_name         => l_req_rec.status_name
                --		, p_multiple_status_flag        => l_multiple_status_flag
                --                , p_assignment_effort           =>
                --                , p_resource_list_member_id   =>
                --                , p_budget_version_id		=>
                --                , p_sum_tasks_flag            =>
                                , p_calendar_type               => l_req_rec.calendar_type
                                , p_calendar_id	                => l_req_rec.calendar_id
                                , p_calendar_name               => l_req_rec.calendar_name
                                , p_start_adv_action_set_flag   => l_req_rec.start_adv_action_set_flag
                                , p_adv_action_set_id           => l_req_rec.adv_action_set_id
                                , p_adv_action_set_name         => l_req_rec.adv_action_set_name
                                -- As of now internal code does not support setting the candidate search options
                                -- at create time. It can only be updated.
                                , p_comp_match_weighting        => l_req_rec.comp_match_weighting
                                , p_avail_match_weighting       => l_req_rec.avail_match_weighting
                                , p_job_level_match_weighting   => l_req_rec.job_level_match_weighting
                                , p_enable_auto_cand_nom_flag   => l_req_rec.enable_auto_cand_nom_flag
                                , p_search_min_availability     => l_req_rec.search_min_availability
                                , p_search_exp_org_struct_ver_id => l_req_rec.search_exp_org_str_ver_id
                                , p_search_exp_start_org_id     => l_req_rec.search_exp_start_org_id
                                , p_search_country_code         => l_req_rec.search_country_code
                                , p_search_min_candidate_score  => l_req_rec.search_min_candidate_score
                                , p_expenditure_org_id          => l_req_rec.expenditure_org_id
                                , p_expenditure_org_name        => l_req_rec.expenditure_org_name
                                , p_expenditure_organization_id => l_req_rec.expenditure_organization_id
                                , p_exp_organization_name       => l_req_rec.expenditure_organization_name
                                , p_expenditure_type_class      => l_req_rec.expenditure_type_class
                                , p_expenditure_type            => l_req_rec.expenditure_type
                                , p_fcst_job_group_id           => l_req_rec.fcst_job_group_id
                                , p_fcst_job_group_name         => l_req_rec.fcst_job_group_name
                                , p_fcst_job_id                 => l_req_rec.fcst_job_id
                                , p_fcst_job_name               => l_req_rec.fcst_job_name
--                                , p_fcst_tp_amount_type         => l_req_rec.fcst_tp_amount_type
                                , p_work_type_id                => l_req_rec.work_type_id
                                , p_work_type_name              => l_req_rec.work_type_name
                                , p_bill_rate_override          => l_req_rec.bill_rate_override
                                , p_bill_rate_curr_override     => l_req_rec.bill_rate_curr_override
                                , p_markup_percent_override     => l_req_rec.markup_percent_override
                                , p_discount_percentage         => l_req_rec.discount_percentage
                                , p_rate_disc_reason_code       => l_req_rec.rate_disc_reason_code
                                , p_tp_rate_override            => l_req_rec.tp_rate_override
                                , p_tp_currency_override        => l_req_rec.tp_currency_override
                                , p_tp_calc_base_code_override  => l_req_rec.tp_calc_base_code_override
                                , p_tp_percent_applied_override => l_req_rec.tp_percent_applied_override
                                , p_extension_possible          => l_req_rec.extension_possible
                                , p_expense_owner               => l_req_rec.expense_owner
                                , p_expense_limit               => l_req_rec.expense_limit
                --                , p_revenue_currency_code     =>
                --                , p_revenue_bill_rate           =>
                --                , p_markup_percent              =>
                --                , p_resource_calendar_percent   =>
                                , p_attribute_category          => l_req_rec.attribute_category
                                , p_attribute1                  => l_req_rec.attribute1
                                , p_attribute2                  => l_req_rec.attribute2
                                , p_attribute3                  => l_req_rec.attribute3
                                , p_attribute4                  => l_req_rec.attribute4
                                , p_attribute5                  => l_req_rec.attribute5
                                , p_attribute6                  => l_req_rec.attribute6
                                , p_attribute7                  => l_req_rec.attribute7
                                , p_attribute8                  => l_req_rec.attribute8
                                , p_attribute9                  => l_req_rec.attribute9
                                , p_attribute10                 => l_req_rec.attribute10
                                , p_attribute11                 => l_req_rec.attribute11
                                , p_attribute12                 => l_req_rec.attribute12
                                , p_attribute13                 => l_req_rec.attribute13
                                , p_attribute14                 => l_req_rec.attribute14
                                , p_attribute15                 => l_req_rec.attribute15
                                , x_new_assignment_id_tbl       => l_new_assignment_id_tbl
                                , x_new_assignment_id           => l_new_assignment_id
                                , x_assignment_number           => l_assignment_number
                                , x_assignment_row_id           => l_assignment_row_id
                                , x_resource_id                 => l_resource_id
                                , x_return_status               => l_return_status
                                , x_msg_count                   => l_msg_count
                                , x_msg_data                    => l_msg_data
                        );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After call pa_assignments_pub.execute_create_assignment l_return_status='||l_return_status, l_log_level);
                        END IF;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                l_error_flag_local := 'Y';
                                -- Still we populating out tables so that if calling env tries
                                -- to get all ids even after error has occured
                                x_requirement_id_tbl.extend(1);
                                x_requirement_id_tbl(x_requirement_id_tbl.count):= -1;
                        ELSE
                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Updating Original System Code and Reference', l_log_level);
                                        pa_debug.write(l_module, 'l_new_assignment_id_tbl.count'||l_new_assignment_id_tbl.count, l_log_level);
                                END IF;

                                IF l_new_assignment_id_tbl.count > 0 THEN
                                        FOR j in l_new_assignment_id_tbl.FIRST..l_new_assignment_id_tbl.LAST LOOP
                                                IF l_new_assignment_id_tbl.exists(j) THEN
                                                        x_requirement_id_tbl.extend(1);
                                                        x_requirement_id_tbl(x_requirement_id_tbl.count):= l_new_assignment_id_tbl(j);
                                                        IF (l_req_rec.orig_system_code IS NOT NULL OR l_req_rec.orig_system_reference IS NOT NULL) THEN
                                                                UPDATE PA_PROJECT_ASSIGNMENTS
                                                                SET orig_system_code = l_req_rec.orig_system_code
                                                                , orig_system_reference = l_req_rec.orig_system_reference
                                                                WHERE assignment_id = l_new_assignment_id_tbl(j);
                                                        END IF;
                                                END IF;
                                        END LOOP;
                                END IF;
                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Updating Original System Code and Reference', l_log_level);
                                END IF;
                        END IF;
		ELSE
			-- Still we populating out tables so that if calling env tries
			-- to get all ids even after error has occured
			x_requirement_id_tbl.extend(1);
			x_requirement_id_tbl(x_requirement_id_tbl.count):= -1;
                END IF;

                l_end_msg_count := FND_MSG_PUB.count_msg;
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'l_start_msg_count='||l_start_msg_count, l_log_level);
                        pa_debug.write(l_module, 'l_end_msg_count='||l_end_msg_count, l_log_level);
                END IF;
                l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Repopulating Error Message Stack', l_log_level);
                        END IF;

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;
                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Repopulating Error Message Stack', l_log_level);
                        END IF;
                END IF;
                i := p_requirement_in_tbl.next(i);
        END LOOP;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'All records are done', l_log_level);
                pa_debug.write(l_module, 'l_error_flag='||l_error_flag, l_log_level);
                pa_debug.write(l_module, 'FND_MSG_PUB.count_msg='||FND_MSG_PUB.count_msg, l_log_level);
        END IF;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO CREATE_REQUIREMENTS_SP;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SQLERRM;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO CREATE_REQUIREMENTS_SP;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'CREATE_REQUIREMENTS'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;
END CREATE_REQUIREMENTS;

-- Start of comments
--	API name 	: UPDATE_REQUIREMENTS
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to update one or more requirements for one or more projects
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are: FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_requirement_in_tbl	IN  REQUIREMENT_IN_TBL_TYPE	Required
--					Table of requirement records. Please see the REQUIREMENT_IN_TBL_TYPE datatype table.
--	OUT		:
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - amksingh  - Created
-- End of comments
PROCEDURE UPDATE_REQUIREMENTS
(
  p_api_version_number		IN		NUMBER   := 1.0
, p_init_msg_list		IN		VARCHAR2 := FND_API.G_TRUE
, p_commit			IN		VARCHAR2 := FND_API.G_FALSE
, p_requirement_in_tbl		IN		REQUIREMENT_IN_TBL_TYPE
, x_return_status		OUT	NOCOPY	VARCHAR2
, x_msg_count			OUT	NOCOPY	NUMBER
, x_msg_data			OUT	NOCOPY	VARCHAR2
)
IS
l_calling_application           VARCHAR2(10)            := 'PLSQL';
l_calling_module                VARCHAR2(10)            := 'AMG';
l_check_id_flag                 VARCHAR2(1)             := 'Y';
l_check_role_security_flag      VARCHAR2(1)             := 'Y';
l_check_resource_security_flag  VARCHAR2(1)             := 'Y';
l_log_level                     NUMBER                  := 3;
l_module                        VARCHAR2(100)           := 'PA_RES_MANAGEMENT_AMG_PUB.UPDATE_REQUIREMENTS';
l_commit                        VARCHAR2(1)             := FND_API.G_FALSE;
l_init_msg_list                 VARCHAR2(1)             := FND_API.G_FALSE;
l_validate_only                 VARCHAR2(1)             := FND_API.G_FALSE;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_data                          VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);

i                               NUMBER;
l_new_assignment_id_tbl         SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
l_new_assignment_id             NUMBER;
l_assignment_number             NUMBER;
l_assignment_row_id             ROWID;
l_resource_id                   NUMBER;
l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
l_error_flag                    VARCHAR2(1)             := 'N';
l_error_flag_local              VARCHAR2(1)             := 'N';
l_req_rec		        REQUIREMENT_IN_REC_TYPE;
l_asgn_update_mode		VARCHAR2(10)	        := 'FULL';
l_assignment_type		VARCHAR2(30)	        := 'OPEN_ASSIGNMENT';
l_multiple_status_flag		VARCHAR2(1)	        := 'N';
l_loop_msg_count                NUMBER                  :=0;
l_start_msg_count               NUMBER                  :=0;
l_end_msg_count                 NUMBER                  :=0;
l_missing_params                VARCHAR2(1000);
l_privilege                     VARCHAR2(30);
l_object_name                   VARCHAR2(30);
l_object_key                    NUMBER;
l_error_message_code            VARCHAR2(30);
l_ret_code                      VARCHAR2(1);


CURSOR get_bill_rate_override_flags(c_project_id NUMBER) IS
SELECT impl.rate_discount_reason_flag ,impl.br_override_flag, impl.br_discount_override_flag
FROM pa_implementations_all impl
    , pa_projects_all proj
WHERE proj.org_id=impl.org_id  -- Removed nvl condition from org_id : Post review changes for Bug 5130421
AND proj.project_id = c_project_id ;

CURSOR c_get_lookup_exists(c_lookup_type VARCHAR2, c_lookup_code VARCHAR2) IS
SELECT 'Y'
FROM dual
WHERE EXISTS
(SELECT 'XYZ' FROM pa_lookups WHERE lookup_type = c_lookup_type AND lookup_code = c_lookup_code);

CURSOR c_get_subteam_party_id(c_requirement_id NUMBER) IS
SELECT project_subteam_party_id, project_subteam_id
FROM pa_project_subteam_parties
WHERE object_id = c_requirement_id
AND object_type = 'PA_PROJECT_ASSIGNMENTS'
AND primary_subteam_flag = 'Y';

CURSOR c_get_requirement_details(c_requirement_id NUMBER) IS
SELECT *
FROM pa_project_assignments
WHERE assignment_type = 'OPEN_ASSIGNMENT'
AND assignment_id = c_requirement_id;

CURSOR c_get_system_status_code(c_status_code VARCHAR2, c_status_type VARCHAR2) IS
SELECT project_system_status_code
FROM pa_project_statuses
WHERE status_type = c_status_type
AND project_status_code = c_status_code;

CURSOR c_get_location(c_location_id NUMBER) IS
SELECT country_code, region, city
FROM pa_locations
WHERE location_id = c_location_id;

CURSOR c_derive_country_code(c_country_name IN VARCHAR2) IS
SELECT country_code
FROM pa_country_v
WHERE name = c_country_name;

CURSOR c_derive_country_name(c_country_code IN VARCHAR2) IS
SELECT name
FROM pa_country_v
WHERE  country_code  = c_country_code;

-- 5144288, 5144369 : Added c_get_mcb_flag
CURSOR c_get_mcb_flag(c_project_id NUMBER) IS
SELECT multi_currency_billing_flag
FROM pa_projects_all
WHERE project_id = c_project_id;


l_req_dtls_csr                  c_get_requirement_details%ROWTYPE;
l_valid_flag                    VARCHAR2(1);
l_rate_discount_reason_flag     VARCHAR2(1);
l_br_override_flag              VARCHAR2(1);
l_br_discount_override_flag     VARCHAR2(1);
l_project_subteam_party_id      NUMBER;
l_project_subteam_id            NUMBER;
l_system_status_code            VARCHAR2(30);
l_basic_info_changed            VARCHAR2(1);
l_candidate_info_changed        VARCHAR2(1);
l_fin_info_changed              VARCHAR2(1);
l_fin_bill_rate_info_changed    VARCHAR2(1);
l_fin_tp_rate_info_changed      VARCHAR2(1);
l_valid_country                 VARCHAR2(1);
l_dummy_country_code            VARCHAR2(2);
l_dummy_state		        VARCHAR2(240);
l_dummy_city		        VARCHAR2(80);
l_out_location_id	        NUMBER;
l_multi_currency_billing_flag   VARCHAR2(1); -- 5144288, 5144369
l_bill_currency_override_tmp    VARCHAR2(30); -- 5144288, 5144369

BEGIN

        --Flows which are supported by this API
        ---------------------------------------
        --1. Update project requirements
        --        1.1 Updating basic information(staffing priority, staffing owner, subteams, location etc..)
        --        1.2 Updating candidate search(search organization, weightages etc..) information
        --        1.3 Updating financial information(expendtiture organization, bill rate etc..)
        --        1.4 Updating forecast infomation(job, job group, expenditure type etc..)
        --2. Create team template requirments
        --        2.1 Updating basic information(staffing priority, staffing owner, subteams, location etc..)
        --
        --Flows which are not supported by this API
        -------------------------------------------
        --1. Update team role for given planning resource
        --2. Adding candidates while updating requirements
        --3. Adding/Updating competencies
        --4. Updating schedule information(dates, status, calendar etc..)
        --5. Updating advertisement rule

        -- Mandatory Parameters
        -----------------------
        --1. Requirement_id should be passed.

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'UPDATE_REQUIREMENTS', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint UPDATE_REQUIREMENTS_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of update_requirements', l_log_level);
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Printing Input Parameters......', l_log_level);
                i := p_requirement_in_tbl.first;
                WHILE i IS NOT NULL LOOP
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').requirement_id'||p_requirement_in_tbl(i).requirement_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').requirement_name'||p_requirement_in_tbl(i).requirement_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').team_template_id'||p_requirement_in_tbl(i).team_template_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').number_of_requirements'||p_requirement_in_tbl(i).number_of_requirements, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_role_id'||p_requirement_in_tbl(i).project_role_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_role_name'||p_requirement_in_tbl(i).project_role_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_id'||p_requirement_in_tbl(i).project_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_name'||p_requirement_in_tbl(i).project_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_number'||p_requirement_in_tbl(i).project_number, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').staffing_owner_person_id'||p_requirement_in_tbl(i).staffing_owner_person_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').staffing_priority_code'||p_requirement_in_tbl(i).staffing_priority_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').staffing_priority_name'||p_requirement_in_tbl(i).staffing_priority_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_subteam_id'||p_requirement_in_tbl(i).project_subteam_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').project_subteam_name'||p_requirement_in_tbl(i).project_subteam_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').location_id'||p_requirement_in_tbl(i).location_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').location_country_code'||p_requirement_in_tbl(i).location_country_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').location_country_name'||p_requirement_in_tbl(i).location_country_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').location_region'||p_requirement_in_tbl(i).location_region, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').location_city'||p_requirement_in_tbl(i).location_city, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').min_resource_job_level'||p_requirement_in_tbl(i).min_resource_job_level, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').max_resource_job_level'||p_requirement_in_tbl(i).max_resource_job_level, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').description'||p_requirement_in_tbl(i).description, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').additional_information'||p_requirement_in_tbl(i).additional_information, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').start_date'||p_requirement_in_tbl(i).start_date, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').end_date'||p_requirement_in_tbl(i).end_date, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').status_code'||p_requirement_in_tbl(i).status_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').status_name'||p_requirement_in_tbl(i).status_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').calendar_type'||p_requirement_in_tbl(i).calendar_type, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').calendar_id'||p_requirement_in_tbl(i).calendar_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').calendar_name'||p_requirement_in_tbl(i).calendar_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').start_adv_action_set_flag'||p_requirement_in_tbl(i).start_adv_action_set_flag, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').adv_action_set_id'||p_requirement_in_tbl(i).adv_action_set_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').adv_action_set_name'||p_requirement_in_tbl(i).adv_action_set_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').comp_match_weighting'||p_requirement_in_tbl(i).comp_match_weighting, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').avail_match_weighting'||p_requirement_in_tbl(i).avail_match_weighting, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').job_level_match_weighting'||p_requirement_in_tbl(i).job_level_match_weighting, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').enable_auto_cand_nom_flag'||p_requirement_in_tbl(i).enable_auto_cand_nom_flag, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_min_availability'||p_requirement_in_tbl(i).search_min_availability, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_exp_org_str_ver_id'||p_requirement_in_tbl(i).search_exp_org_str_ver_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_exp_org_hier_name'||p_requirement_in_tbl(i).search_exp_org_hier_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_exp_start_org_id'||p_requirement_in_tbl(i).search_exp_start_org_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_exp_start_org_name'||p_requirement_in_tbl(i).search_exp_start_org_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_country_code'||p_requirement_in_tbl(i).search_country_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_country_name'||p_requirement_in_tbl(i).search_country_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').search_min_candidate_score'||p_requirement_in_tbl(i).search_min_candidate_score, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_org_id'||p_requirement_in_tbl(i).expenditure_org_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_org_name'||p_requirement_in_tbl(i).expenditure_org_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_organization_id'||p_requirement_in_tbl(i).expenditure_organization_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_organization_name'||p_requirement_in_tbl(i).expenditure_organization_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_type_class'||p_requirement_in_tbl(i).expenditure_type_class, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expenditure_type'||p_requirement_in_tbl(i).expenditure_type, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').fcst_job_group_id'||p_requirement_in_tbl(i).fcst_job_group_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').fcst_job_group_name'||p_requirement_in_tbl(i).fcst_job_group_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').fcst_job_id'||p_requirement_in_tbl(i).fcst_job_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').fcst_job_name'||p_requirement_in_tbl(i).fcst_job_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').work_type_id'||p_requirement_in_tbl(i).work_type_id, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').work_type_name'||p_requirement_in_tbl(i).work_type_name, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').bill_rate_option'||p_requirement_in_tbl(i).bill_rate_option, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').bill_rate_override'||p_requirement_in_tbl(i).bill_rate_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').bill_rate_curr_override'||p_requirement_in_tbl(i).bill_rate_curr_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').markup_percent_override'||p_requirement_in_tbl(i).markup_percent_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').discount_percentage'||p_requirement_in_tbl(i).discount_percentage, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').rate_disc_reason_code'||p_requirement_in_tbl(i).rate_disc_reason_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').tp_rate_option'||p_requirement_in_tbl(i).tp_rate_option, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').tp_rate_override'||p_requirement_in_tbl(i).tp_rate_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').tp_currency_override'||p_requirement_in_tbl(i).tp_currency_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').tp_calc_base_code_override'||p_requirement_in_tbl(i).tp_calc_base_code_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').tp_percent_applied_override'||p_requirement_in_tbl(i).tp_percent_applied_override, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').extension_possible'||p_requirement_in_tbl(i).extension_possible, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expense_owner'||p_requirement_in_tbl(i).expense_owner, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').expense_limit'||p_requirement_in_tbl(i).expense_limit, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').orig_system_code'||p_requirement_in_tbl(i).orig_system_code, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').orig_system_reference'||p_requirement_in_tbl(i).orig_system_reference, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').record_version_number'||p_requirement_in_tbl(i).record_version_number, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute_category'||p_requirement_in_tbl(i).attribute_category, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute1'||p_requirement_in_tbl(i).attribute1, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute2'||p_requirement_in_tbl(i).attribute2, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute3'||p_requirement_in_tbl(i).attribute3, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute4'||p_requirement_in_tbl(i).attribute4, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute5'||p_requirement_in_tbl(i).attribute5, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute6'||p_requirement_in_tbl(i).attribute6, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute7'||p_requirement_in_tbl(i).attribute7, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute8'||p_requirement_in_tbl(i).attribute8, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute9'||p_requirement_in_tbl(i).attribute9, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute10'||p_requirement_in_tbl(i).attribute10, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute11'||p_requirement_in_tbl(i).attribute11, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute12'||p_requirement_in_tbl(i).attribute12, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute13'||p_requirement_in_tbl(i).attribute13, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute14'||p_requirement_in_tbl(i).attribute14, l_log_level);
                        pa_debug.write(l_module, 'p_requirement_in_tbl('||i||').attribute15'||p_requirement_in_tbl(i).attribute15, l_log_level);
                        pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                        i := p_requirement_in_tbl.next(i);
                END LOOP;
        END IF;

        PA_STARTUP.INITIALIZE(
                  p_calling_application                 => l_calling_application
                , p_calling_module                      => l_calling_module
                , p_check_id_flag                       => l_check_id_flag
                , p_check_role_security_flag            => l_check_role_security_flag
                , p_check_resource_security_flag        => l_check_resource_security_flag
                , p_debug_level                         => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of PA_STARTUP.INITIALIZE', l_log_level);
        END IF;

        -- Page does not check PRM licensing, but keeping this code so in future if required, can be used
        --l_prm_license_flag  := nvl(FND_PROFILE.VALUE('PA_PRM_LICENSED'),'N');
        --IF l_prm_license_flag <> 'Y' THEN
        --        null;
        --END IF;


        i := p_requirement_in_tbl.first;

        WHILE i IS NOT NULL LOOP
                l_error_flag_local := 'N';
                l_missing_params := null;
                l_req_rec := null;
                l_valid_country := 'Y';
                l_basic_info_changed := 'N';
                l_candidate_info_changed := 'N';
                l_fin_info_changed := 'N';
                l_fin_bill_rate_info_changed := 'N';
                l_fin_tp_rate_info_changed := 'N';

                l_start_msg_count := FND_MSG_PUB.count_msg;

                l_req_rec := p_requirement_in_tbl(i);

                -- Mandatory Parameters Check
                ------------------------------

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Record#'||i, l_log_level);
                        pa_debug.write(l_module, '-----------------------------', l_log_level);
                        pa_debug.write(l_module, 'Validate requirement_id.', l_log_level);
                END IF;

                        /*--Bug 6511907 PJR Date Validation Enhancement ----- Start--*/
                        /*-- Validating Resource Req Start and End Date against
                             Project Start and Completion dates --*/

                        Declare
                          l_validate           VARCHAR2(10);
                          l_start_date_status  VARCHAR2(10);
                          l_end_date_status    VARCHAR2(10);
                          l_start_date         DATE;
                          l_end_date           DATE;
                        Begin
                         If l_req_rec.start_date is not null or l_req_rec.end_date is not null then
                           l_start_date := l_req_rec.start_date;
                           l_end_date   := l_req_rec.end_date;
                           PA_PROJECT_DATES_UTILS.Validate_Resource_Dates
                                       (l_req_rec.project_id, l_start_date, l_end_date,
                                                   l_validate, l_start_date_status, l_end_date_status);

                           If l_validate = 'Y' and l_start_date_status = 'I' Then

                              pa_utils.add_message
                               ( p_app_short_name  => 'PA'
                                ,p_msg_name	       => 'PA_PJR_DATE_START_ERROR'
                                ,p_token1          => 'PROJ_TXN_START_DATE'
                                ,p_value1          => GET_PROJECT_START_DATE(l_req_rec.project_id)
                                ,p_token2          => ''
                                ,p_value2          => ''
                                ,p_token3          => ''
                                ,p_value3          => ''
                               );

                              RAISE  FND_API.G_EXC_ERROR;
                           End If;

                           If l_validate = 'Y' and l_end_date_status = 'I' Then

                              pa_utils.add_message
                               ( p_app_short_name  => 'PA'
                                ,p_msg_name	    => 'PA_PJR_DATE_FINISH_ERROR'
                                ,p_token1          => 'PROJ_TXN_END_DATE'
                                ,p_value1          => GET_PROJECT_COMPLETION_DATE(l_req_rec.project_id)
                                ,p_token2          => ''
                                ,p_value2          => ''
                                ,p_token3          => ''
                                ,p_value3          => ''
                               );

                              RAISE  FND_API.G_EXC_ERROR;
                           End If;
                         End If;
                        End;

                        /*--Bug 6511907 PJR Date Validation Enhancement ----- End--*/
                l_req_dtls_csr := null;
                OPEN c_get_requirement_details(l_req_rec.requirement_id);
                FETCH c_get_requirement_details INTO l_req_dtls_csr;

                IF c_get_requirement_details%NOTFOUND THEN
                        l_missing_params := l_missing_params||', REQUIREMENT_ID';
                ELSE
                        l_system_status_code := null;
                        OPEN c_get_system_status_code(l_req_dtls_csr.status_code, 'OPEN_ASGMT');
                        FETCH c_get_system_status_code INTO l_system_status_code;
                        CLOSE c_get_system_status_code;

                        IF l_system_status_code IN ('OPEN_ASGMT_FILLED','OPEN_ASGMT_CANCEL') THEN
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_STS_ACT_NOT_ALLW');
                                l_error_flag_local := 'Y';
                        END IF;

                        IF nvl(l_req_dtls_csr.mass_wf_in_progress_flag, 'N') = 'Y' THEN
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_ASSIGNMENT_WF');
                                l_error_flag_local := 'Y';
                        END IF;
                END IF;

                CLOSE c_get_requirement_details;

                IF l_req_rec.work_type_id IS NULL AND l_req_rec.work_type_name IS NULL THEN
                        l_missing_params := l_missing_params||', WORK_TYPE_ID, WORK_TYPE_NAME';
                END IF;

                IF l_req_rec.min_resource_job_level IS NULL THEN
                        l_missing_params := l_missing_params||', MIN_RESOURCE_JOB_LEVEL';
                END IF;

                IF l_req_rec.max_resource_job_level IS NULL THEN
                        l_missing_params := l_missing_params||', MAX_RESOURCE_JOB_LEVEL';
                END IF;

                IF l_req_rec.location_id IS NULL OR l_req_rec.location_id = G_PA_MISS_NUM THEN
                        -- If either city or state (or) both are passed ,then country is
                        -- mandatory
                        IF (l_req_rec.location_country_code IS NULL AND l_req_rec.location_country_name IS NULL)
                           OR (l_req_rec.location_country_code =  G_PA_MISS_CHAR AND l_req_rec.location_country_name = G_PA_MISS_CHAR)
                        THEN
                                IF (l_req_rec.location_region <> G_PA_MISS_CHAR AND l_req_rec.location_region IS NOT NULL)
                                    OR (l_req_rec.location_city <> G_PA_MISS_CHAR AND l_req_rec.location_city IS NOT NULL)
                                THEN
                                        l_missing_params := l_missing_params||', LOCATION_COUNTRY_CODE, LOCATION_COUNTRY_NAME';
                                        l_valid_country := 'N';
                                END IF;
                        ELSIF l_req_rec.location_country_code IS NOT NULL AND l_req_rec.location_country_code <> G_PA_MISS_CHAR
                        THEN
                                OPEN c_derive_country_name(l_req_rec.location_country_code);
                                FETCH c_derive_country_name INTO l_req_rec.location_country_name;
                                IF c_derive_country_name%NOTFOUND THEN
                                        -- Invalid Country code passed.
                                        l_missing_params := l_missing_params||', LOCATION_COUNTRY_CODE';
                                        l_valid_country := 'N';
                                ELSE
                                        l_valid_country := 'Y';
                                END IF;
                                CLOSE c_derive_country_name;
                        ELSIF l_req_rec.location_country_name IS NOT NULL AND l_req_rec.location_country_name <> G_PA_MISS_CHAR
                        THEN
                              OPEN c_derive_country_code(l_req_rec.location_country_name);
                              FETCH c_derive_country_code INTO l_req_rec.location_country_code;
                              IF c_derive_country_code%NOTFOUND THEN
                                        -- Invalid Country Name passed.
                                        l_missing_params := l_missing_params||', LOCATION_COUNTRY_NAME';
                                        l_valid_country := 'N';
                               ELSE
                                        l_valid_country := 'Y';
                              END IF;
                              CLOSE c_derive_country_code;
                        END IF;

                        -- If the country is valid,then proceed with the state and city validations
                        IF l_valid_country = 'Y' AND l_req_rec.location_country_code IS NOT NULL
                        AND l_req_rec.location_country_code <> G_PA_MISS_CHAR
                        THEN

                                IF l_req_rec.location_id = G_PA_MISS_NUM THEN
                                        OPEN c_get_location(l_req_dtls_csr.location_id);
                                        FETCH c_get_location INTO l_dummy_country_code, l_dummy_state, l_dummy_city;
                                        CLOSE c_get_location;
                                END IF;

                                l_dummy_country_code := l_req_rec.location_country_code;

                                IF l_req_rec.location_region IS NULL THEN
                                        l_dummy_state := null;
                                ELSIF l_req_rec.location_region = G_PA_MISS_CHAR THEN
                                        l_dummy_state := l_dummy_state;
                                ELSE
                                        l_dummy_state := l_req_rec.location_region;
                                END IF;

                                IF l_req_rec.location_city IS NULL THEN
                                        l_dummy_city := null;
                                ELSIF l_req_rec.location_city = G_PA_MISS_CHAR THEN
                                        l_dummy_city := l_dummy_city;
                                ELSE
                                        l_dummy_city := l_req_rec.location_city;
                                END IF;

                                PA_LOCATION_UTILS.CHECK_LOCATION_EXISTS
                                (
                                         p_country_code         => l_dummy_country_code
                                        ,p_city		        => l_dummy_city
                                        ,p_region	        => l_dummy_state
                                        ,x_location_id	        => l_out_location_id
                                        ,x_return_status        => l_return_status
                                );

                                IF l_out_location_id IS NULL THEN
                                        PA_UTILS.ADD_MESSAGE('PA','PA_AMG_RES_INV_CRC_COMB');
                                        l_error_flag_local := 'Y'; -- 5148975
                                ELSE
                                        l_req_rec.location_id := l_out_location_id;
                                END IF;
                        END IF;
                ELSE
                        -- if location id is passed, then it will override the city, region, country code
                        OPEN c_get_location(l_req_rec.location_id);
                        FETCH c_get_location INTO l_req_rec.location_country_code, l_req_rec.location_region, l_req_rec.location_city;

                        IF c_get_location%NOTFOUND THEN
                                l_missing_params := l_missing_params||', LOCATION_ID';
                        END IF;
                        CLOSE c_get_location;
                END IF; -- l_req_rec.location_id IS NULL OR l_req_rec.location_id = FND_API.G_MISS_NUM



                -- For start date, and end dates, status, calendar uses cant update from this flow
                --IF l_req_rec.start_date IS NULL THEN
                --        l_missing_params := l_missing_params||', START_DATE';
                --END IF;

                --IF l_req_rec.end_date IS NULL THEN
                --        l_missing_params := l_missing_params||', END_DATE';
                --END IF;

                --IF l_req_rec.status_code IS NULL AND l_req_rec.status_name IS NULL THEN
                --        l_missing_params := l_missing_params||', STATUS_CODE, STATUS_NAME';
                --END IF;

                --IF l_req_rec.calendar_id IS NULL AND l_req_rec.calendar_name IS NULL THEN
                --        l_missing_params := l_missing_params||', CALENDAR_ID, CALENDAR_NAME';
                --END IF;

                IF nvl(l_req_dtls_csr.template_flag, 'N') = 'N' AND l_req_dtls_csr.project_id IS NOT NULL THEN
                        -- Project Requirement Flow

                        -- These checks are NULL checks, which means user is passing them explicitely as NULL
                        -- If user does not pass anything, then it will be G_PA_MISS_XXX

                        IF l_req_rec.comp_match_weighting IS NULL THEN
                                l_missing_params := l_missing_params||', COMP_MATCH_WEIGHTING';
                        END IF;

                        IF l_req_rec.avail_match_weighting IS NULL THEN
                                l_missing_params := l_missing_params||', AVAIL_MATCH_WEIGHTING';
                        END IF;

                        IF l_req_rec.job_level_match_weighting IS NULL THEN
                                l_missing_params := l_missing_params||', JOB_LEVEL_MATCH_WEIGHTING';
                        END IF;

                        -- Let enable_auto_cand_nom_flag be null, If null then we shd take it as N
                        --IF l_req_rec.enable_auto_cand_nom_flag IS NULL THEN
                        --        l_missing_params := l_missing_params||', ENABLE_AUTO_CAND_NOM_FLAG';
                        --END IF;

                        IF l_req_rec.search_min_availability IS NULL THEN
                                l_missing_params := l_missing_params||', SEARCH_MIN_AVAILABILITY';
                        END IF;

                        IF l_req_rec.search_exp_org_str_ver_id IS NULL AND l_req_rec.search_exp_org_hier_name IS NULL THEN
                                l_missing_params := l_missing_params||', SEARCH_EXP_ORG_STR_VER_ID, SEARCH_EXP_ORG_HIER_NAME';
                        END IF;

                        IF l_req_rec.search_exp_start_org_id IS NULL AND l_req_rec.search_exp_start_org_name IS NULL THEN
                                l_missing_params := l_missing_params||', SEARCH_EXP_START_ORG_ID, SEARCH_EXP_START_ORG_NAME';
                        END IF;

                        IF l_req_rec.search_min_candidate_score IS NULL THEN
                                l_missing_params := l_missing_params||', SEARCH_MIN_CANDIDATE_SCORE';
                        END IF;

                        IF l_req_rec.expenditure_org_id IS NULL AND l_req_rec.expenditure_org_name IS NULL THEN
                                l_missing_params := l_missing_params||', EXPENDITURE_ORG_ID, EXPENDITURE_ORG_NAME';
                        END IF;

                        IF l_req_rec.expenditure_organization_id IS NULL AND l_req_rec.expenditure_organization_name IS NULL THEN
                                l_missing_params := l_missing_params||', EXPENDITURE_ORGANIZATION_ID, EXPENDITURE_ORGANIZATION_NAME';
                        END IF;

                        IF l_req_rec.expenditure_type_class IS NULL THEN
                                l_missing_params := l_missing_params||', EXPENDITURE_TYPE_CLASS';
                        END IF;

                        IF l_req_rec.expenditure_type IS NULL THEN
                                l_missing_params := l_missing_params||', EXPENDITURE_TYPE';
                        END IF;

                        IF l_req_rec.bill_rate_option IS NULL THEN
                                l_missing_params := l_missing_params||', BILL_RATE_OPTION';
                        ELSIF l_req_rec.bill_rate_option <> G_PA_MISS_CHAR AND l_req_rec.bill_rate_option NOT IN('RATE','MARKUP','DISCOUNT','NONE') THEN
                                l_missing_params := l_missing_params||', BILL_RATE_OPTION';
                        ELSIF l_req_rec.bill_rate_option = 'NONE' THEN
                                l_req_rec.bill_rate_override := null;
                                l_req_rec.bill_rate_curr_override := null;
                                l_req_rec.markup_percent_override := null;
                                l_req_rec.discount_percentage := null;
                                l_req_rec.rate_disc_reason_code := null;
                        ELSIF l_req_rec.bill_rate_option = 'RATE' THEN
                                l_req_rec.markup_percent_override := null;
                                l_req_rec.discount_percentage := null;
                                IF (l_req_rec.bill_rate_override IS NULL OR l_req_rec.bill_rate_override = G_PA_MISS_NUM)
                                AND l_req_dtls_csr.bill_rate_override IS NULL
                                THEN
                                        l_missing_params := l_missing_params||', BILL_RATE_OVERRIDE';
                                END IF;
                        ELSIF l_req_rec.bill_rate_option = 'MARKUP' THEN
                                l_req_rec.bill_rate_override := null;
                                l_req_rec.bill_rate_curr_override := null;
                                l_req_rec.discount_percentage := null;
                                IF (l_req_rec.markup_percent_override IS NULL OR l_req_rec.markup_percent_override = G_PA_MISS_NUM)
                                AND l_req_dtls_csr.markup_percent_override IS NULL
                                THEN
                                        l_missing_params := l_missing_params||', MARKUP_PERCENT_OVERRIDE';
                                END IF;
                        ELSIF l_req_rec.bill_rate_option = 'DISCOUNT' THEN
                                l_req_rec.bill_rate_override := null;
                                l_req_rec.bill_rate_curr_override := null;
                                l_req_rec.markup_percent_override := null;
                                IF (l_req_rec.discount_percentage IS NULL OR l_req_rec.discount_percentage = G_PA_MISS_NUM)
                                AND l_req_dtls_csr.discount_percentage IS NULL
                                THEN
                                        l_missing_params := l_missing_params||', DISCOUNT_PERCENTAGE';
                                END IF;
                        END IF;


                        IF l_req_rec.tp_rate_option IS NULL THEN
                                l_missing_params := l_missing_params||', TP_RATE_OPTION';
                        ELSIF l_req_rec.tp_rate_option <> G_PA_MISS_CHAR AND l_req_rec.tp_rate_option NOT IN('RATE','BASIS','NONE')
                        THEN
                                l_missing_params := l_missing_params||', TP_RATE_OPTION';
                        ELSIF l_req_rec.tp_rate_option = 'NONE' THEN
                                l_req_rec.tp_rate_override := null;
                                l_req_rec.tp_currency_override := null;
                                l_req_rec.tp_calc_base_code_override := null;
                                l_req_rec.tp_percent_applied_override := null;
                        ELSIF l_req_rec.tp_rate_option = 'RATE' THEN
                                l_req_rec.tp_calc_base_code_override := null;
                                l_req_rec.tp_percent_applied_override := null;
                                IF (((l_req_rec.tp_rate_override IS NULL OR l_req_rec.tp_rate_override = G_PA_MISS_NUM)
                                        AND l_req_dtls_csr.tp_rate_override IS NULL)
                                    OR
                                     ((l_req_rec.tp_currency_override IS NULL OR l_req_rec.tp_currency_override = G_PA_MISS_CHAR)
                                        AND l_req_dtls_csr.tp_currency_override IS NULL)
                                    )
                                THEN
                                        l_missing_params := l_missing_params||', TP_RATE_OVERRIDE, TP_CURRENCY_OVERRIDE';
                                END IF;
                        ELSIF l_req_rec.tp_rate_option = 'BASIS' THEN
                                l_req_rec.tp_rate_override := null;
                                l_req_rec.tp_currency_override := null;
                                IF (((l_req_rec.tp_calc_base_code_override IS NULL OR l_req_rec.tp_calc_base_code_override = G_PA_MISS_CHAR)
                                        AND l_req_dtls_csr.tp_calc_base_code_override IS NULL)
                                    OR
                                     ((l_req_rec.tp_percent_applied_override IS NULL OR l_req_rec.tp_percent_applied_override = G_PA_MISS_NUM)
                                        AND l_req_dtls_csr.tp_percent_applied_override IS NULL)
                                    )
                                THEN
                                        l_missing_params := l_missing_params||', TP_CALC_BASE_CODE_OVERRIDE, TP_PERCENT_APPLIED_OVERRIDE';
                                END IF;
                        END IF;

                        IF l_req_rec.extension_possible <>  G_PA_MISS_CHAR AND l_req_rec.extension_possible NOT IN ('Y','N') THEN
                                l_missing_params := l_missing_params||', EXTENSION_POSSIBLE';
                        END IF;
                END IF; -- nvl(l_req_dtls_csr.team_template_flag, 'N')

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory parameter validation over. List of Missing Parameters='||l_missing_params, l_log_level);
                END IF;

                IF l_missing_params IS NOT NULL THEN
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                        l_error_flag_local := 'Y';
                END IF;

                -- Retrieve values from data base if Parameters are not passed.
                ---------------------------------------------------------------


                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Take values from database for those parameters which are not passed.', l_log_level);
                END IF;

                IF l_req_rec.requirement_name = G_PA_MISS_CHAR THEN
                        l_req_rec.requirement_name := l_req_dtls_csr.assignment_name;
                END IF;


                -- These parameters are Not used for Update Flow:

                -- Internal API requires to pass FND_API miss nums instead of null
                -- if we pass null, they treat it as update and raise error
                l_req_rec.team_template_id := l_req_dtls_csr.assignment_template_id;

                l_req_rec.number_of_requirements := FND_API.G_MISS_NUM;

                l_req_rec.project_role_id := FND_API.G_MISS_NUM;

                l_req_rec.project_role_name := FND_API.G_MISS_CHAR;

                l_req_rec.project_id := l_req_dtls_csr.project_id;

                l_req_rec.project_name := FND_API.G_MISS_CHAR;

                l_req_rec.project_number := FND_API.G_MISS_CHAR;

                IF l_req_rec.staffing_owner_person_id = G_PA_MISS_NUM THEN
                        l_req_rec.staffing_owner_person_id := l_req_dtls_csr.staffing_owner_person_id;
                END IF;

                IF l_req_rec.staffing_priority_code = G_PA_MISS_CHAR THEN
                        l_req_rec.staffing_priority_code := l_req_dtls_csr.staffing_priority_code;
                END IF;

                IF l_req_rec.staffing_priority_name = G_PA_MISS_CHAR THEN
                        l_req_rec.staffing_priority_name := null;
                END IF;

                l_project_subteam_party_id := null;

                OPEN c_get_subteam_party_id(l_req_rec.requirement_id);
                FETCH c_get_subteam_party_id INTO l_project_subteam_party_id, l_project_subteam_id;
                CLOSE c_get_subteam_party_id;

                IF l_req_rec.project_subteam_id = G_PA_MISS_NUM THEN
                        -- The reason we need to check name here, because
                        -- If name is passed and id is not. In this case, id
                        -- will default to previous id and new name will be lost
                        IF l_req_rec.project_subteam_name = G_PA_MISS_CHAR THEN
                                l_req_rec.project_subteam_id := l_project_subteam_id;
                        ELSIF l_req_rec.project_subteam_name IS NULL THEN
                                l_req_rec.project_subteam_id := null;
                        ELSE
                                l_req_rec.project_subteam_id := null;
                        END IF;
                END IF;

                IF l_req_rec.project_subteam_name = G_PA_MISS_CHAR THEN
                        l_req_rec.project_subteam_name := null;
                END IF;


                IF l_req_rec.location_id = G_PA_MISS_NUM THEN
                        l_req_rec.location_id := l_req_dtls_csr.location_id;
                END IF;

                IF l_req_rec.location_country_code = G_PA_MISS_CHAR THEN
                        l_req_rec.location_country_code := null;
                END IF;

                IF l_req_rec.location_country_name = G_PA_MISS_CHAR THEN
                        l_req_rec.location_country_name := null;
                END IF;

                IF l_req_rec.location_region = G_PA_MISS_CHAR THEN
                        l_req_rec.location_region := null;
                END IF;

                IF l_req_rec.location_city = G_PA_MISS_CHAR THEN
                        l_req_rec.location_city := null;
                END IF;

                IF l_req_rec.min_resource_job_level = G_PA_MISS_NUM THEN
                        l_req_rec.min_resource_job_level := l_req_dtls_csr.min_resource_job_level;
                END IF;

                IF l_req_rec.max_resource_job_level = G_PA_MISS_NUM THEN
                        l_req_rec.max_resource_job_level := l_req_dtls_csr.max_resource_job_level;
                END IF;

                IF l_req_rec.description = G_PA_MISS_CHAR THEN
                        l_req_rec.description := l_req_dtls_csr.description;
                END IF;

                IF l_req_rec.additional_information = G_PA_MISS_CHAR THEN
                        l_req_rec.additional_information := l_req_dtls_csr.additional_information;
                END IF;

                -- These parameters are not For Update flow
                l_req_rec.start_date := l_req_dtls_csr.start_date;
                l_req_rec.end_date := l_req_dtls_csr.end_date;
                l_req_rec.status_code := l_req_dtls_csr.status_code;
                l_req_rec.status_name := null;
                l_req_rec.calendar_type := null;
                l_req_rec.calendar_id := l_req_dtls_csr.calendar_id;
                l_req_rec.calendar_name := null;
                l_req_rec.start_adv_action_set_flag := null;
                l_req_rec.adv_action_set_id := null;
                l_req_rec.adv_action_set_name := null;


                IF l_req_rec.comp_match_weighting = G_PA_MISS_NUM THEN
                        l_req_rec.comp_match_weighting := l_req_dtls_csr.competence_match_weighting;
                END IF;

                IF l_req_rec.avail_match_weighting = G_PA_MISS_NUM THEN
                        l_req_rec.avail_match_weighting := l_req_dtls_csr.availability_match_weighting;
                END IF;

                IF l_req_rec.job_level_match_weighting = G_PA_MISS_NUM THEN
                        l_req_rec.job_level_match_weighting := l_req_dtls_csr.job_level_match_weighting;
                END IF;

                IF l_req_rec.enable_auto_cand_nom_flag = G_PA_MISS_CHAR THEN
                        l_req_rec.enable_auto_cand_nom_flag := l_req_dtls_csr.enable_auto_cand_nom_flag;
                END IF;

                -- Treat null as N for flags
                IF l_req_rec.enable_auto_cand_nom_flag IS NULL THEN
                        l_req_rec.enable_auto_cand_nom_flag := 'N';
                END IF;

                IF l_req_rec.search_min_availability = G_PA_MISS_NUM THEN
                        l_req_rec.search_min_availability := l_req_dtls_csr.search_min_availability;
                END IF;

                IF l_req_rec.search_exp_org_str_ver_id = G_PA_MISS_NUM THEN
                        IF l_req_rec.search_exp_org_hier_name = G_PA_MISS_CHAR THEN
                                l_req_rec.search_exp_org_str_ver_id := l_req_dtls_csr.search_exp_org_struct_ver_id;
                        ELSIF l_req_rec.search_exp_org_hier_name IS NULL THEN
                                l_req_rec.search_exp_org_str_ver_id := null;
                        ELSE
                                l_req_rec.search_exp_org_str_ver_id := null;
                        END IF;
                END IF;

                IF l_req_rec.search_exp_org_hier_name = G_PA_MISS_CHAR THEN
                        l_req_rec.search_exp_org_hier_name := null;
                END IF;

                IF l_req_rec.search_exp_start_org_id = G_PA_MISS_NUM THEN
                        IF l_req_rec.search_exp_start_org_name = G_PA_MISS_CHAR THEN
                                l_req_rec.search_exp_start_org_id := l_req_dtls_csr.search_exp_start_org_id;
                        ELSIF l_req_rec.search_exp_start_org_name IS NULL THEN
                                l_req_rec.search_exp_start_org_id := null;
                        ELSE
                                l_req_rec.search_exp_start_org_id := null;
                        END IF;
                END IF;

                IF l_req_rec.search_exp_start_org_name = G_PA_MISS_CHAR THEN
                        l_req_rec.search_exp_start_org_name := null;
                END IF;

                IF l_req_rec.search_country_code = G_PA_MISS_CHAR THEN
                        IF l_req_rec.search_country_name = G_PA_MISS_CHAR THEN
                                l_req_rec.search_country_code := l_req_dtls_csr.search_country_code;
                        ELSIF l_req_rec.search_country_name IS NULL THEN
                                l_req_rec.search_country_code := null;
                        ELSE
                                l_req_rec.search_country_code := null;
                        END IF;
                END IF;

                IF l_req_rec.search_country_name = G_PA_MISS_CHAR THEN
                        l_req_rec.search_country_name := null;
                END IF;

                IF l_req_rec.search_min_candidate_score = G_PA_MISS_NUM THEN
                        l_req_rec.search_min_candidate_score := l_req_dtls_csr.search_min_candidate_score;
                END IF;

                IF l_req_rec.expenditure_org_id = G_PA_MISS_NUM THEN
                        IF l_req_rec.expenditure_org_name = G_PA_MISS_CHAR THEN
                                l_req_rec.expenditure_org_id := l_req_dtls_csr.expenditure_org_id;
                        ELSIF l_req_rec.expenditure_org_name IS NULL THEN
                                l_req_rec.expenditure_org_id := null;
                        ELSE
                                l_req_rec.expenditure_org_id := null;
                        END IF;
                END IF;

                IF l_req_rec.expenditure_org_name = G_PA_MISS_CHAR THEN
                        l_req_rec.expenditure_org_name := null;
                END IF;

                IF l_req_rec.expenditure_organization_id = G_PA_MISS_NUM THEN
                        IF l_req_rec.expenditure_organization_name = G_PA_MISS_CHAR THEN
                                l_req_rec.expenditure_organization_id := l_req_dtls_csr.expenditure_organization_id;
                        ELSIF l_req_rec.expenditure_organization_name IS NULL THEN
                                l_req_rec.expenditure_organization_id := null;
                        ELSE
                                l_req_rec.expenditure_organization_id := null;
                        END IF;
                END IF;

                IF l_req_rec.expenditure_organization_name = G_PA_MISS_CHAR THEN
                        l_req_rec.expenditure_organization_name := null;
                END IF;

                IF l_req_rec.expenditure_type_class = G_PA_MISS_CHAR THEN
                        l_req_rec.expenditure_type_class := l_req_dtls_csr.expenditure_type_class;
                END IF;

                IF l_req_rec.expenditure_type = G_PA_MISS_CHAR THEN
                        l_req_rec.expenditure_type := l_req_dtls_csr.expenditure_type;
                END IF;


                IF l_req_rec.fcst_job_group_id = G_PA_MISS_NUM THEN
                        IF l_req_rec.fcst_job_group_name = G_PA_MISS_CHAR THEN
                                l_req_rec.fcst_job_group_id := l_req_dtls_csr.fcst_job_group_id;
                        ELSIF l_req_rec.fcst_job_group_name IS NULL THEN
                                l_req_rec.fcst_job_group_id := null;
                        ELSE
                                l_req_rec.fcst_job_group_id := null;
                        END IF;
                END IF;

                IF l_req_rec.fcst_job_group_name = G_PA_MISS_CHAR THEN
                        l_req_rec.fcst_job_group_name := null;
                END IF;

                IF l_req_rec.fcst_job_id = G_PA_MISS_NUM THEN
                        IF l_req_rec.fcst_job_name = G_PA_MISS_CHAR THEN
                                l_req_rec.fcst_job_id := l_req_dtls_csr.fcst_job_id;
                        ELSIF l_req_rec.fcst_job_name IS NULL THEN
                                l_req_rec.fcst_job_id := null;
                        ELSE
                                l_req_rec.fcst_job_id := null;
                        END IF;
                END IF;

                IF l_req_rec.fcst_job_name = G_PA_MISS_CHAR THEN
                        l_req_rec.fcst_job_name := null;
                END IF;

                IF l_req_rec.work_type_id = G_PA_MISS_NUM THEN
                        IF l_req_rec.work_type_name = G_PA_MISS_CHAR THEN
                                l_req_rec.work_type_id := l_req_dtls_csr.work_type_id;
                        ELSIF l_req_rec.work_type_name IS NULL THEN
                                l_req_rec.work_type_id := null;
                        ELSE
                                l_req_rec.work_type_id := null;
                        END IF;
                END IF;

                IF l_req_rec.work_type_name = G_PA_MISS_CHAR THEN
                        l_req_rec.work_type_name := null;
                END IF;

                -- No need to default this
                --  l_req_rec.bill_rate_option := 'NONE';

                IF l_req_rec.bill_rate_override = G_PA_MISS_NUM THEN
                        l_req_rec.bill_rate_override := l_req_dtls_csr.bill_rate_override;
                END IF;

                IF l_req_rec.bill_rate_curr_override = G_PA_MISS_CHAR THEN
                        l_req_rec.bill_rate_curr_override := l_req_dtls_csr.bill_rate_curr_override;
                END IF;

                IF l_req_rec.markup_percent_override = G_PA_MISS_NUM THEN
                        l_req_rec.markup_percent_override := l_req_dtls_csr.markup_percent_override;
                END IF;

                IF l_req_rec.discount_percentage = G_PA_MISS_NUM THEN
                        l_req_rec.discount_percentage := l_req_dtls_csr.discount_percentage;
                END IF;

                IF l_req_rec.rate_disc_reason_code = G_PA_MISS_CHAR THEN
                        l_req_rec.rate_disc_reason_code := l_req_dtls_csr.rate_disc_reason_code;
                END IF;

                -- No need to default this
                -- l_req_rec.tp_rate_option := 'NONE';

                IF l_req_rec.tp_rate_override = G_PA_MISS_NUM THEN
                        l_req_rec.tp_rate_override := l_req_dtls_csr.tp_rate_override;
                END IF;

                IF l_req_rec.tp_currency_override = G_PA_MISS_CHAR THEN
                        l_req_rec.tp_currency_override := l_req_dtls_csr.tp_currency_override;
                END IF;

                IF l_req_rec.tp_calc_base_code_override = G_PA_MISS_CHAR THEN
                        l_req_rec.tp_calc_base_code_override := l_req_dtls_csr.tp_calc_base_code_override;
                END IF;

                IF l_req_rec.tp_percent_applied_override = G_PA_MISS_NUM THEN
                        l_req_rec.tp_percent_applied_override := l_req_dtls_csr.tp_percent_applied_override;
                END IF;

                IF l_req_rec.extension_possible = G_PA_MISS_CHAR THEN
                        l_req_rec.extension_possible := l_req_dtls_csr.extension_possible;
                END IF;

                IF l_req_rec.expense_owner = G_PA_MISS_CHAR THEN
                        l_req_rec.expense_owner := l_req_dtls_csr.expense_owner;
                END IF;

                IF l_req_rec.expense_limit = G_PA_MISS_NUM THEN
                        l_req_rec.expense_limit := l_req_dtls_csr.expense_limit;
                END IF;

                IF l_req_rec.orig_system_code = G_PA_MISS_CHAR THEN
                        l_req_rec.orig_system_code := l_req_dtls_csr.orig_system_code;
                END IF;

                IF l_req_rec.orig_system_reference = G_PA_MISS_CHAR THEN
                        l_req_rec.orig_system_reference := l_req_dtls_csr.orig_system_reference;
                END IF;

                IF l_req_rec.record_version_number = G_PA_MISS_NUM THEN
                        l_req_rec.record_version_number := l_req_dtls_csr.record_version_number;
                END IF;

                IF l_req_rec.attribute_category = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute_category := l_req_dtls_csr.attribute_category;
                END IF;

                IF l_req_rec.attribute1 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute1 := l_req_dtls_csr.attribute1;
                END IF;

                IF l_req_rec.attribute2 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute2 := l_req_dtls_csr.attribute2;
                END IF;

                IF l_req_rec.attribute3 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute3 := l_req_dtls_csr.attribute3;
                END IF;

                IF l_req_rec.attribute4 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute4 := l_req_dtls_csr.attribute4;
                END IF;

                IF l_req_rec.attribute5 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute5 := l_req_dtls_csr.attribute5;
                END IF;

                IF l_req_rec.attribute6 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute6 := l_req_dtls_csr.attribute6;
                END IF;

                IF l_req_rec.attribute7 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute7 := l_req_dtls_csr.attribute7;
                END IF;

                IF l_req_rec.attribute8 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute8 := l_req_dtls_csr.attribute8;
                END IF;

                IF l_req_rec.attribute9 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute9 := l_req_dtls_csr.attribute9;
                END IF;

                IF l_req_rec.attribute10 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute10 := l_req_dtls_csr.attribute10;
                END IF;

                IF l_req_rec.attribute11 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute11 := l_req_dtls_csr.attribute11;
                END IF;

                IF l_req_rec.attribute12 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute12 := l_req_dtls_csr.attribute12;
                END IF;

                IF l_req_rec.attribute13 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute13 := l_req_dtls_csr.attribute13;
                END IF;

                IF l_req_rec.attribute14 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute14 := l_req_dtls_csr.attribute14;
                END IF;

                IF l_req_rec.attribute15 = G_PA_MISS_CHAR THEN
                        l_req_rec.attribute15 := l_req_dtls_csr.attribute15;
                END IF;


                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Got the values from database.', l_log_level);
                        pa_debug.write(l_module, 'DB value of ProjectId='||l_req_dtls_csr.project_id, l_log_level);
                        pa_debug.write(l_module, 'DB value of TeamTemplateId='||l_req_dtls_csr.assignment_template_id, l_log_level);
                        pa_debug.write(l_module, 'DB value of TeamTemplateFlag='||l_req_dtls_csr.template_flag, l_log_level);
                        pa_debug.write(l_module, 'l_error_flag_local='||l_error_flag_local, l_log_level);
                END IF;


                -- All validations are not required as some validation is done in underlying code
                -- Here, we are doing only those validations which are not done internally.

                IF l_error_flag_local <> 'Y' AND nvl(l_req_dtls_csr.template_flag,'N') = 'N' THEN
                        -- Project Requirement Flow


                        -- Bill Rate Options Validation
                        -------------------------------

                        IF l_req_rec.bill_rate_option <> 'NONE' THEN
                                l_rate_discount_reason_flag := 'N';
                                l_br_override_flag := 'N';
                                l_br_discount_override_flag := 'N';

                                OPEN get_bill_rate_override_flags(l_req_rec.project_id);
                                FETCH get_bill_rate_override_flags INTO  l_rate_discount_reason_flag, l_br_override_flag, l_br_discount_override_flag;
                                CLOSE get_bill_rate_override_flags;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Bill Rate Options', l_log_level);
                                        pa_debug.write(l_module, 'l_rate_discount_reason_flag='||l_rate_discount_reason_flag, l_log_level);
                                        pa_debug.write(l_module, 'l_br_override_flag='||l_br_override_flag, l_log_level);
                                        pa_debug.write(l_module, 'l_br_discount_override_flag='||l_br_discount_override_flag, l_log_level);
                                END IF;

                                IF l_req_rec.bill_rate_option = 'RATE' THEN

                                        IF l_br_override_flag <> 'Y' OR l_req_rec.bill_rate_override <= 0 THEN /* OR l_req_rec.bill_rate_override > 100 - Removed for Bug 5703021*/
                                                IF l_br_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_BILL_RATE_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_BILL_RATE_OVRD');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;

                                        -- 5144288, 5144369 : Begin
                                        l_multi_currency_billing_flag := null;
                                        OPEN c_get_mcb_flag(l_req_rec.project_id);
                                        FETCH c_get_mcb_flag INTO l_multi_currency_billing_flag;
                                        CLOSE c_get_mcb_flag;

                                        IF nvl(l_multi_currency_billing_flag,'N') = 'Y' AND l_br_override_flag = 'Y' THEN
                                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                                l_error_message_code := null;
                                                l_bill_currency_override_tmp := l_req_rec.bill_rate_curr_override;

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'Validating Bill Rate Currency', l_log_level);
                                                END IF;

                                                PA_PROJECTS_MAINT_UTILS.CHECK_CURRENCY_NAME_OR_CODE(
                                                        p_agreement_currency       => l_bill_currency_override_tmp
                                                        ,p_agreement_currency_name  => null
                                                        ,p_check_id_flag            => 'Y'
                                                        ,x_agreement_currency       => l_req_rec.bill_rate_curr_override
                                                        ,x_return_status            => l_return_status
                                                        ,x_error_msg_code           => l_error_message_code);

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'After Bill Rate Currency Validation', l_log_level);
                                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                                END IF;

                                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_CISI_CURRENCY_NULL');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                        -- 5144288, 5144369 : End
                                ELSIF l_req_rec.bill_rate_option = 'MARKUP' THEN
					-- 5144675 Changed l_req_rec.markup_percent_override <= 0 to < 0
                                        IF l_br_override_flag <> 'Y' OR l_req_rec.markup_percent_override < 0
					   OR l_req_rec.markup_percent_override > 100 THEN
                                                IF l_br_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_BILL_RATE_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_MARKUP_PERCENT');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                ELSIF l_req_rec.bill_rate_option = 'DISCOUNT' THEN
					-- 5144675 Changed l_req_rec.discount_percentage <= 0 to < 0
                                        IF l_br_discount_override_flag <> 'Y' OR l_req_rec.discount_percentage < 0
					    OR l_req_rec.discount_percentage > 100 THEN
                                                IF l_br_discount_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_DISC_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_DISCOUNT_PERCENT');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                END IF;

                                IF l_req_rec.rate_disc_reason_code IS NULL THEN
                                        IF (l_rate_discount_reason_flag ='Y' AND (l_br_override_flag ='Y' OR l_br_discount_override_flag='Y') AND
                                                (l_req_rec.bill_rate_override IS NOT NULL OR l_req_rec.markup_percent_override IS NOT NULL OR l_req_rec.discount_percentage IS NOT NULL)
                                           )
                                        THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_RATE_DISC_REASON_REQUIRED');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                ELSE
                                        l_valid_flag := 'N';
                                        OPEN c_get_lookup_exists('RATE AND DISCOUNT REASON', l_req_rec.rate_disc_reason_code);
                                        FETCH c_get_lookup_exists INTO l_valid_flag;
                                        CLOSE c_get_lookup_exists;
                                        IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_DISC_RSN_INVALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Validating Bill Rate Options l_error_flag_local='||l_error_flag_local, l_log_level);
                                END IF;
                        END IF; -- l_req_rec.bill_rate_option <> 'NONE'

                        -- Transfer Price Rate Options Validation
                        -----------------------------------------

                        IF l_req_rec.tp_rate_option <> 'NONE' THEN

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Transfer Price Rate Options', l_log_level);
                                END IF;

                                IF l_req_rec.tp_rate_option = 'RATE' THEN
                                        null; -- This validation is done internally
                                ELSIF l_req_rec.tp_rate_option = 'BASIS' THEN
                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'Validating Transfer Price Rate Basis', l_log_level);
                                        END IF;

                                        OPEN c_get_lookup_exists('CC_MARKUP_BASE_CODE', l_req_rec.tp_calc_base_code_override);
                                        FETCH c_get_lookup_exists INTO l_valid_flag;
                                        CLOSE c_get_lookup_exists;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'After Transfer Price Rate Basis Validation', l_log_level);
                                                pa_debug.write(l_module, 'l_valid_flag='||l_valid_flag, l_log_level);
                                        END IF;

                                        IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_TP_BASIS_INVALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Validating Transfer Price Rate Options l_error_flag_local='||l_error_flag_local, l_log_level);
                                END IF;
                        END IF; -- l_req_rec.tp_rate_option <> 'NONE'

                        -- Res Loan Agreement Validations
                        ---------------------------------

                        IF l_req_rec.expense_owner IS NOT NULL THEN
                                l_valid_flag := 'N';

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Expense Owner Option', l_log_level);
                                END IF;

                                OPEN c_get_lookup_exists('EXPENSE_OWNER_TYPE', l_req_rec.expense_owner);
                                FETCH c_get_lookup_exists INTO l_valid_flag;
                                CLOSE c_get_lookup_exists;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Expense Owner Option Validation', l_log_level);
                                        pa_debug.write(l_module, 'l_valid_flag='||l_valid_flag, l_log_level);
                                END IF;

                                IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_EXP_OWNER_INVALID');
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;
                END IF; -- l_error_flag_local <> 'Y' AND nvl(l_req_dtls_csr.template_flag,'N') = 'N'

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'After all validations l_error_flag_local='||l_error_flag_local, l_log_level);
                END IF;

                -- Flex field Validation
                ------------------------

                IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        VALIDATE_FLEX_FIELD(
                                  p_desc_flex_name         => 'PA_TEAM_ROLE_DESC_FLEX'
                                , p_attribute_category     => l_req_rec.attribute_category
                                , px_attribute1            => l_req_rec.attribute1
                                , px_attribute2            => l_req_rec.attribute2
                                , px_attribute3            => l_req_rec.attribute3
                                , px_attribute4            => l_req_rec.attribute4
                                , px_attribute5            => l_req_rec.attribute5
                                , px_attribute6            => l_req_rec.attribute6
                                , px_attribute7            => l_req_rec.attribute7
                                , px_attribute8            => l_req_rec.attribute8
                                , px_attribute9            => l_req_rec.attribute9
                                , px_attribute10           => l_req_rec.attribute10
                                , px_attribute11           => l_req_rec.attribute11
                                , px_attribute12           => l_req_rec.attribute12
                                , px_attribute13           => l_req_rec.attribute13
                                , px_attribute14           => l_req_rec.attribute14
                                , px_attribute15           => l_req_rec.attribute15
                                , x_return_status          => l_return_status
                                , x_msg_count		   => l_msg_count
                                , x_msg_data		   => l_msg_data
                         );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Flex Field Validation l_return_status='||l_return_status, l_log_level);
                                pa_debug.write(l_module, 'After Flex Field Validation l_msg_data='||l_msg_data, l_log_level);
                        END IF;


                        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS  THEN
                                -- This message does not have toekn defined, still it is ok to pass token as the value
                                -- returned by flex APIs because token are appended as it is
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_DFF_VALIDATION_FAILED',
                                                      'MESSAGE', l_msg_data );
                                l_error_flag_local := 'Y';
                        END IF;
                END IF; -- l_error_flag_local <> 'Y'

                -- Security Check
                -----------------
                -- The underlying API does security check of PA_ASN_BASIC_INFO_ED
                -- , PA_CREATE_CANDIDATES, PA_ASN_FCST_INFO_ED
                -- But still we need to do check here because there are some more checks required
                -- Also the underlying API does not consider the MISS chars

                IF l_error_flag_local <> 'Y' AND nvl(l_req_dtls_csr.template_flag,'N') = 'N' THEN
                        -- Project Requirement

                        IF nvl(l_req_rec.requirement_name, 'XYZ') <> nvl(l_req_dtls_csr.assignment_name, 'XYZ')
                        OR nvl(l_req_rec.min_resource_job_level, -1) <> nvl(l_req_dtls_csr.min_resource_job_level, -1)
                        OR nvl(l_req_rec.max_resource_job_level, -1) <> nvl(l_req_dtls_csr.max_resource_job_level, -1)
                        OR nvl(l_req_rec.staffing_priority_code, 'XYZ') <> nvl(l_req_dtls_csr.staffing_priority_code, 'XYZ')
                        OR nvl(l_req_rec.staffing_owner_person_id, -1) <> nvl(l_req_dtls_csr.staffing_owner_person_id, -1)
                        OR nvl(l_req_rec.description, 'XYZ') <> nvl(l_req_dtls_csr.description, 'XYZ')
                        OR nvl(l_req_rec.additional_information, 'XYZ') <> nvl(l_req_dtls_csr.additional_information, 'XYZ')
                        OR nvl(l_req_rec.project_subteam_id, -1) <> nvl(l_project_subteam_id, -1)
                        OR nvl(l_req_rec.location_id, -1) <> nvl(l_req_dtls_csr.location_id, -1)
                        THEN
                                l_basic_info_changed := 'Y';
                        END IF;

                        IF nvl(l_req_rec.comp_match_weighting, -1) <> nvl(l_req_dtls_csr.competence_match_weighting, -1)
                        OR nvl(l_req_rec.avail_match_weighting, -1) <> nvl(l_req_dtls_csr.availability_match_weighting, -1)
                        OR nvl(l_req_rec.job_level_match_weighting, -1) <> nvl(l_req_dtls_csr.job_level_match_weighting, -1)
                        OR nvl(l_req_rec.enable_auto_cand_nom_flag, 'XYZ') <> nvl(l_req_dtls_csr.enable_auto_cand_nom_flag, 'XYZ')
                        OR nvl(l_req_rec.search_min_availability, -1) <> nvl(l_req_dtls_csr.search_min_availability, -1)
                        OR nvl(l_req_rec.search_exp_org_str_ver_id, -1) <> nvl(l_req_dtls_csr.search_exp_org_struct_ver_id, -1)
                        OR nvl(l_req_rec.search_exp_start_org_id, -1) <> nvl(l_req_dtls_csr.search_exp_start_org_id, -1)
                        OR nvl(l_req_rec.search_country_code, 'XYZ') <> nvl(l_req_dtls_csr.search_country_code, 'XYZ')
                        OR nvl(l_req_rec.search_min_candidate_score, -1) <> nvl(l_req_dtls_csr.search_min_candidate_score, -1)
                        THEN
                                l_candidate_info_changed := 'Y';
                        END IF;

                        IF nvl(l_req_rec.extension_possible, 'XYZ') <> nvl(l_req_dtls_csr.extension_possible, 'XYZ')
                        OR nvl(l_req_rec.expense_owner, 'XYZ') <> nvl(l_req_dtls_csr.expense_owner, 'XYZ')
                        OR nvl(l_req_rec.expense_limit, -1) <> nvl(l_req_dtls_csr.expense_limit, -1)
                        OR nvl(l_req_rec.expenditure_org_id, -1) <> nvl(l_req_dtls_csr.expenditure_org_id, -1)
                        OR nvl(l_req_rec.expenditure_organization_id, -1) <> nvl(l_req_dtls_csr.expenditure_organization_id, -1)
                        OR nvl(l_req_rec.expenditure_type_class, 'XYZ') <> nvl(l_req_dtls_csr.expenditure_type_class, 'XYZ')
                        OR nvl(l_req_rec.fcst_job_group_id, -1) <> nvl(l_req_dtls_csr.fcst_job_group_id, -1)
                        OR nvl(l_req_rec.fcst_job_id, -1) <> nvl(l_req_dtls_csr.fcst_job_id, -1)
                        OR nvl(l_req_rec.work_type_id, -1) <> nvl(l_req_dtls_csr.work_type_id, -1)
                        THEN
                                l_fin_info_changed := 'Y';
                        END IF;

                        IF nvl(l_req_rec.bill_rate_override, -1) <> nvl(l_req_dtls_csr.bill_rate_override, -1)
                        OR nvl(l_req_rec.bill_rate_curr_override, 'XYZ') <> nvl(l_req_dtls_csr.bill_rate_curr_override, 'XYZ')
                        OR nvl(l_req_rec.markup_percent_override, -1) <> nvl(l_req_dtls_csr.markup_percent_override, -1)
                        OR nvl(l_req_rec.discount_percentage, -1) <> nvl(l_req_dtls_csr.discount_percentage, -1)
                        OR nvl(l_req_rec.rate_disc_reason_code, 'XYZ') <> nvl(l_req_dtls_csr.rate_disc_reason_code, 'XYZ')
                        THEN
                                l_fin_bill_rate_info_changed := 'Y';
                        END IF;

                        IF nvl(l_req_rec.tp_rate_override, -1) <> nvl(l_req_dtls_csr.tp_rate_override, -1)
                        OR nvl(l_req_rec.tp_currency_override, 'XYZ') <> nvl(l_req_dtls_csr.tp_currency_override, 'XYZ')
                        OR nvl(l_req_rec.tp_percent_applied_override, -1) <> nvl(l_req_dtls_csr.tp_percent_applied_override, -1)
                        OR nvl(l_req_rec.tp_calc_base_code_override, 'XYZ') <> nvl(l_req_dtls_csr.tp_calc_base_code_override, 'XYZ')
                        THEN
                                l_fin_tp_rate_info_changed := 'Y';
                        END IF;


                        IF l_basic_info_changed = 'Y' THEN

                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_ret_code := 'T';
                                l_privilege := 'PA_ASN_BASIC_INFO_ED';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_req_rec.project_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Project Level Security for PA_ASN_BASIC_INFO_ED', l_log_level);
                                END IF ;

                                PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                          x_ret_code       => l_ret_code
                                        , x_return_status  => l_return_status
                                        , x_msg_count      => l_msg_count
                                        , x_msg_data       => l_msg_data
                                        , p_privilege      => l_privilege
                                        , p_object_name    => l_object_name
                                        , p_object_key     => l_object_key
                                        , p_init_msg_list  => FND_API.G_FALSE);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_BASIC_INFO_ED l_ret_code '|| l_ret_code , l_log_level);
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_BASIC_INFO_ED l_return_status '|| l_return_status , l_log_level);
                                END IF ;

                                IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Checking Requirement Level Security for PA_ASN_BASIC_INFO_ED', l_log_level);
                                        END IF ;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';
                                        l_privilege := 'PA_ASN_BASIC_INFO_ED';
                                        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
                                        l_object_key := l_req_rec.requirement_id;

                                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                                  x_ret_code       => l_ret_code
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data
                                                , p_privilege      => l_privilege
                                                , p_object_name    => l_object_name
                                                , p_object_key     => l_object_key
                                                , p_init_msg_list  => FND_API.G_FALSE );

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Requirement Level Security for PA_ASN_BASIC_INFO_ED l_ret_code='||l_ret_code, l_log_level);
                                                pa_debug.write(l_module,'Requirement Level Security for PA_ASN_BASIC_INFO_ED l_return_status='||l_return_status, l_log_level);
                                        END IF ;
                                END IF;

                                IF nvl(l_ret_code,'F') <> 'T' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_UPD_ASGN_BASIC_INFO'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                        l_error_flag_local := 'Y';
                                END IF;

                        END IF;-- l_basic_info_changed = 'Y'

                        IF l_candidate_info_changed = 'Y' THEN

                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_ret_code := 'T';
                                l_privilege := 'PA_CREATE_CANDIDATES';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_req_rec.project_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Project Level Security for PA_CREATE_CANDIDATES', l_log_level);
                                END IF ;

                                PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                          x_ret_code       => l_ret_code
                                        , x_return_status  => l_return_status
                                        , x_msg_count      => l_msg_count
                                        , x_msg_data       => l_msg_data
                                        , p_privilege      => l_privilege
                                        , p_object_name    => l_object_name
                                        , p_object_key     => l_object_key
                                        , p_init_msg_list  => FND_API.G_FALSE);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Project Level Security for PA_CREATE_CANDIDATES l_ret_code '|| l_ret_code , l_log_level);
                                        pa_debug.write(l_module, 'Project Level Security for PA_CREATE_CANDIDATES l_return_status '|| l_return_status , l_log_level);
                                END IF ;

                                IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Checking Requirement Level Security for PA_CREATE_CANDIDATES', l_log_level);
                                        END IF ;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';
                                        l_privilege := 'PA_CREATE_CANDIDATES';
                                        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
                                        l_object_key := l_req_rec.requirement_id;

                                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                                  x_ret_code       => l_ret_code
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data
                                                , p_privilege      => l_privilege
                                                , p_object_name    => l_object_name
                                                , p_object_key     => l_object_key
                                                , p_init_msg_list  => FND_API.G_FALSE );

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Requirement Level Security for PA_CREATE_CANDIDATES l_ret_code='||l_ret_code, l_log_level);
                                                pa_debug.write(l_module,'Requirement Level Security for PA_CREATE_CANDIDATES l_return_status='||l_return_status, l_log_level);
                                        END IF ;
                                END IF;

                                IF nvl(l_ret_code,'F') <> 'T' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_UPD_ASGN_CANDIDATE'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                        l_error_flag_local := 'Y';
                                END IF;

                        END IF;-- l_candidate_info_changed = 'Y'

                        IF l_fin_info_changed = 'Y' OR l_fin_bill_rate_info_changed = 'Y' OR l_fin_tp_rate_info_changed = 'Y' THEN

                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_ret_code := 'T';
                                l_privilege := 'PA_ASN_FCST_INFO_ED';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_req_rec.project_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Project Level Security for PA_ASN_FCST_INFO_ED', l_log_level);
                                END IF ;

                                PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                          x_ret_code       => l_ret_code
                                        , x_return_status  => l_return_status
                                        , x_msg_count      => l_msg_count
                                        , x_msg_data       => l_msg_data
                                        , p_privilege      => l_privilege
                                        , p_object_name    => l_object_name
                                        , p_object_key     => l_object_key
                                        , p_init_msg_list  => FND_API.G_FALSE);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_FCST_INFO_ED l_ret_code '|| l_ret_code , l_log_level);
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_FCST_INFO_ED l_return_status '|| l_return_status , l_log_level);
                                END IF ;

                                IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Checking Requirement Level Security for PA_CREATE_CANDIDATES', l_log_level);
                                        END IF ;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';
                                        l_privilege := 'PA_ASN_FCST_INFO_ED';
                                        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
                                        l_object_key := l_req_rec.requirement_id;

                                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                                  x_ret_code       => l_ret_code
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data
                                                , p_privilege      => l_privilege
                                                , p_object_name    => l_object_name
                                                , p_object_key     => l_object_key
                                                , p_init_msg_list  => FND_API.G_FALSE );

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Requirement Level Security for PA_ASN_FCST_INFO_ED l_ret_code='||l_ret_code, l_log_level);
                                                pa_debug.write(l_module,'Requirement Level Security for PA_ASN_FCST_INFO_ED l_return_status='||l_return_status, l_log_level);
                                        END IF ;
                                END IF;

                                IF nvl(l_ret_code,'F') <> 'T' OR l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_UPD_ASGN_FIN_INFO'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                        l_error_flag_local := 'Y';
                                END IF;

                        END IF;-- l_fin_info_changed = 'Y' OR l_fin_bill_rate_info_changed = 'Y' OR l_fin_tp_rate_info_changed = 'Y'


                        IF l_fin_bill_rate_info_changed = 'Y' THEN

                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_ret_code := 'T';
                                l_privilege := 'PA_ASN_FCST_INFO_BILL_ED';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_req_rec.project_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Project Level Security for PA_ASN_FCST_INFO_BILL_ED', l_log_level);
                                END IF ;

                                PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                          x_ret_code       => l_ret_code
                                        , x_return_status  => l_return_status
                                        , x_msg_count      => l_msg_count
                                        , x_msg_data       => l_msg_data
                                        , p_privilege      => l_privilege
                                        , p_object_name    => l_object_name
                                        , p_object_key     => l_object_key
                                        , p_init_msg_list  => FND_API.G_FALSE);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_FCST_INFO_BILL_ED l_ret_code '|| l_ret_code , l_log_level);
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_FCST_INFO_BILL_ED l_return_status '|| l_return_status , l_log_level);
                                END IF ;

                                IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Checking Requirement Level Security for PA_ASN_FCST_INFO_BILL_ED', l_log_level);
                                        END IF ;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';
                                        l_privilege := 'PA_ASN_FCST_INFO_BILL_ED';
                                        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
                                        l_object_key := l_req_rec.requirement_id;

                                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                                  x_ret_code       => l_ret_code
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data
                                                , p_privilege      => l_privilege
                                                , p_object_name    => l_object_name
                                                , p_object_key     => l_object_key
                                                , p_init_msg_list  => FND_API.G_FALSE );

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Requirement Level Security for PA_ASN_FCST_INFO_BILL_ED l_ret_code='||l_ret_code, l_log_level);
                                                pa_debug.write(l_module,'Requirement Level Security for PA_ASN_FCST_INFO_BILL_ED l_return_status='||l_return_status, l_log_level);
                                        END IF ;
                                END IF;

                                IF nvl(l_ret_code,'F') <> 'T' OR l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_UPD_ASGN_BR_INFO'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                        l_error_flag_local := 'Y';
                                END IF;

                        END IF;-- l_fin_bill_rate_info_changed = 'Y'

                        IF l_fin_tp_rate_info_changed = 'Y' THEN

                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_ret_code := 'T';
                                l_privilege := 'PA_ASN_FCST_INFO_TP_ED';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_req_rec.project_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Project Level Security for PA_ASN_FCST_INFO_TP_ED', l_log_level);
                                END IF ;

                                PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                          x_ret_code       => l_ret_code
                                        , x_return_status  => l_return_status
                                        , x_msg_count      => l_msg_count
                                        , x_msg_data       => l_msg_data
                                        , p_privilege      => l_privilege
                                        , p_object_name    => l_object_name
                                        , p_object_key     => l_object_key
                                        , p_init_msg_list  => FND_API.G_FALSE);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_FCST_INFO_TP_ED l_ret_code '|| l_ret_code , l_log_level);
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_FCST_INFO_TP_ED l_return_status '|| l_return_status , l_log_level);
                                END IF ;

                                IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Checking Requirement Level Security for PA_ASN_FCST_INFO_TP_ED', l_log_level);
                                        END IF ;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';
                                        l_privilege := 'PA_ASN_FCST_INFO_TP_ED';
                                        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
                                        l_object_key := l_req_rec.requirement_id;

                                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                                  x_ret_code       => l_ret_code
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data
                                                , p_privilege      => l_privilege
                                                , p_object_name    => l_object_name
                                                , p_object_key     => l_object_key
                                                , p_init_msg_list  => FND_API.G_FALSE );

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Requirement Level Security for PA_ASN_FCST_INFO_TP_ED l_ret_code='||l_ret_code, l_log_level);
                                                pa_debug.write(l_module,'Requirement Level Security for PA_ASN_FCST_INFO_TP_ED l_return_status='||l_return_status, l_log_level);
                                        END IF ;
                                END IF;

                                IF nvl(l_ret_code,'F') <> 'T' OR l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_UPD_ASGN_TP_INFO'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;-- l_fin_tp_rate_info_changed = 'Y'
                ELSIF l_error_flag_local <> 'Y' AND nvl(l_req_dtls_csr.template_flag,'N') = 'Y' THEN
                        -- Template Requirement
                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';
                        l_privilege := 'PA_PRM_DEFINE_TEAM_TEMPLATE';
                        l_object_name := null;
                        l_object_key := null;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module,'Checking Team template security', l_log_level);
                        END IF ;

                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                  x_ret_code       => l_ret_code
                                , x_return_status  => l_return_status
                                , x_msg_count      => l_msg_count
                                , x_msg_data       => l_msg_data
                                , p_privilege      => l_privilege
                                , p_object_name    => l_object_name
                                , p_object_key     => l_object_key
                                , p_init_msg_list  => FND_API.G_FALSE );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module,'Team Template Security l_ret_code='||l_ret_code, l_log_level);
                                pa_debug.write(l_module,'Team Template Security l_return_status='||l_return_status, l_log_level);
                        END IF ;

                        IF nvl(l_ret_code,'F') <> 'T' OR l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_UPD'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                l_error_flag_local := 'Y';
                        END IF;
                END IF; -- l_error_flag_local <> 'Y' AND nvl(l_req_dtls_csr.template_flag,'N') = 'N'


                -- Call Core Actual API
                -----------------------

                IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling PA_ASSIGNMENTS_PUB.EXECUTE_UPDATE_REQUIREMENT for Record#'||i, l_log_level);
                        END IF;


                        PA_ASSIGNMENTS_PUB.EXECUTE_UPDATE_REQUIREMENT
                        (
                                  p_api_version                 => p_api_version_number
                                , p_init_msg_list               => l_init_msg_list
                                , p_commit                      => l_commit
                                , p_validate_only               => l_validate_only
                                , p_asgn_update_mode		=> l_asgn_update_mode
                                , p_assignment_id               => l_req_rec.requirement_id
                                , p_assignment_name		=> l_req_rec.requirement_name
--                                , p_assignment_number           =>
                                , p_assignment_type		=> l_assignment_type
                                , p_assignment_template_id      => l_req_rec.team_template_id
--                                , p_source_assignment_id        => l_req_dtls_csr.source_assignment_id
--                                , p_number_of_requirements      => l_req_rec.number_of_requirements
                                , p_project_role_id             => l_req_rec.project_role_id
                                , p_project_role_name           => l_req_rec.project_role_name
                                , p_project_id                  => l_req_rec.project_id
--                                , p_project_name                => l_req_rec.project_name
                                , p_project_number              => l_req_rec.project_number
                --                , p_resource_id                 =>
                --                , p_project_party_id            =>
                --                , p_resource_name               =>
                --                , p_resource_source_id          => null
                                , p_staffing_owner_person_id    => l_req_rec.staffing_owner_person_id
                --                , p_staffing_owner_name         =>
                                , p_staffing_priority_code      => l_req_rec.staffing_priority_code
                                , p_staffing_priority_name      => l_req_rec.staffing_priority_name
                                , p_project_subteam_id          => l_req_rec.project_subteam_id
                                , p_project_subteam_name        => l_req_rec.project_subteam_name
                                , p_project_subteam_party_id    => l_project_subteam_party_id
                                , p_location_id                 => l_req_rec.location_id
                                , p_location_city               => l_req_rec.location_city
                                , p_location_region             => l_req_rec.location_region
                                , p_location_country_name       => l_req_rec.location_country_name
                                , p_location_country_code       => l_req_rec.location_country_code
                                , p_min_resource_job_level      => l_req_rec.min_resource_job_level
                                , p_max_resource_job_level	=> l_req_rec.max_resource_job_level
                                , p_description                 => l_req_rec.description
                                , p_additional_information      => l_req_rec.additional_information
                                , p_start_date                  => l_req_rec.start_date
                                , p_end_date                    => l_req_rec.end_date
                                , p_status_code                 => l_req_rec.status_code
                                , p_project_status_name         => l_req_rec.status_name
                		, p_multiple_status_flag        => l_req_dtls_csr.multiple_status_flag
                --                , p_assignment_effort           =>
--                                , p_resource_list_member_id   => l_req_dtls_csr.resource_list_member_id
                --                , p_budget_version_id		=>
                --                , p_sum_tasks_flag            =>
--                                , p_calendar_type               => l_req_rec.calendar_type
                                , p_calendar_id	                => l_req_rec.calendar_id
                                , p_calendar_name               => l_req_rec.calendar_name
--                                , p_start_adv_action_set_flag   => l_req_rec.start_adv_action_set_flag
--                                , p_adv_action_set_id           => l_req_rec.adv_action_set_id
--                                , p_adv_action_set_name         => l_req_rec.adv_action_set_name
                                -- As of now internal code does not support setting the candidate search options
                                -- at create time. It can only be updated.
                                , p_comp_match_weighting        => l_req_rec.comp_match_weighting
                                , p_avail_match_weighting       => l_req_rec.avail_match_weighting
                                , p_job_level_match_weighting   => l_req_rec.job_level_match_weighting
                                , p_enable_auto_cand_nom_flag   => l_req_rec.enable_auto_cand_nom_flag
                                , p_search_min_availability     => l_req_rec.search_min_availability
                                , p_search_exp_org_struct_ver_id => l_req_rec.search_exp_org_str_ver_id
                                , p_search_exp_org_hier_name    => l_req_rec.search_exp_org_hier_name
                                , p_search_exp_start_org_id     => l_req_rec.search_exp_start_org_id
                                , p_search_exp_start_org_name   => l_req_rec.search_exp_start_org_name
                                , p_search_country_code         => l_req_rec.search_country_code
                                , p_search_country_name         => l_req_rec.search_country_name
                                , p_search_min_candidate_score  => l_req_rec.search_min_candidate_score
                                , p_expenditure_org_id          => l_req_rec.expenditure_org_id
                                , p_expenditure_org_name        => l_req_rec.expenditure_org_name
                                , p_expenditure_organization_id => l_req_rec.expenditure_organization_id
                                , p_exp_organization_name       => l_req_rec.expenditure_organization_name
                                , p_expenditure_type_class      => l_req_rec.expenditure_type_class
                                , p_expenditure_type            => l_req_rec.expenditure_type
                                , p_fcst_job_group_id           => l_req_rec.fcst_job_group_id
                                , p_fcst_job_group_name         => l_req_rec.fcst_job_group_name
                                , p_fcst_job_id                 => l_req_rec.fcst_job_id
                                , p_fcst_job_name               => l_req_rec.fcst_job_name
--                                , p_fcst_tp_amount_type         => l_req_rec.fcst_tp_amount_type
                                , p_work_type_id                => l_req_rec.work_type_id
                                , p_work_type_name              => l_req_rec.work_type_name
                                , p_bill_rate_override          => l_req_rec.bill_rate_override
                                , p_bill_rate_curr_override     => l_req_rec.bill_rate_curr_override
                                , p_markup_percent_override     => l_req_rec.markup_percent_override
                                , p_discount_percentage         => l_req_rec.discount_percentage
                                , p_rate_disc_reason_code       => l_req_rec.rate_disc_reason_code
                                , p_tp_rate_override            => l_req_rec.tp_rate_override
                                , p_tp_currency_override        => l_req_rec.tp_currency_override
                                , p_tp_calc_base_code_override  => l_req_rec.tp_calc_base_code_override
                                , p_tp_percent_applied_override => l_req_rec.tp_percent_applied_override
                                , p_extension_possible          => l_req_rec.extension_possible
                                , p_expense_owner               => l_req_rec.expense_owner
                                , p_expense_limit               => l_req_rec.expense_limit
                                , p_expense_limit_currency_code => l_req_dtls_csr.expense_limit_currency_code
                                , p_revenue_currency_code       => l_req_dtls_csr.revenue_currency_code
                                , p_revenue_bill_rate           => l_req_dtls_csr.revenue_bill_rate
                                , p_markup_percent              => l_req_dtls_csr.markup_percent
                --                , p_resource_calendar_percent   =>
                                , p_record_version_number       => l_req_rec.record_version_number
                                , p_attribute_category          => l_req_rec.attribute_category
                                , p_attribute1                  => l_req_rec.attribute1
                                , p_attribute2                  => l_req_rec.attribute2
                                , p_attribute3                  => l_req_rec.attribute3
                                , p_attribute4                  => l_req_rec.attribute4
                                , p_attribute5                  => l_req_rec.attribute5
                                , p_attribute6                  => l_req_rec.attribute6
                                , p_attribute7                  => l_req_rec.attribute7
                                , p_attribute8                  => l_req_rec.attribute8
                                , p_attribute9                  => l_req_rec.attribute9
                                , p_attribute10                 => l_req_rec.attribute10
                                , p_attribute11                 => l_req_rec.attribute11
                                , p_attribute12                 => l_req_rec.attribute12
                                , p_attribute13                 => l_req_rec.attribute13
                                , p_attribute14                 => l_req_rec.attribute14
                                , p_attribute15                 => l_req_rec.attribute15
                                , x_return_status               => l_return_status
                                , x_msg_count                   => l_msg_count
                                , x_msg_data                    => l_msg_data
                        );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After call PA_ASSIGNMENTS_PUB.EXECUTE_CREATE_ASSIGNMENT l_return_status='||l_return_status, l_log_level);
                        END IF;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                --l_error_flag := 'Y';
                                l_error_flag_local := 'Y';
                        ELSE
                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Updating Original System Code and Reference', l_log_level);
                                END IF;

                                IF l_req_rec.orig_system_code IS NOT NULL OR l_req_rec.orig_system_reference IS NOT NULL THEN
                                        UPDATE PA_PROJECT_ASSIGNMENTS
                                        SET orig_system_code = decode(l_req_rec.orig_system_code, null, orig_system_code, l_req_rec.orig_system_code)
                                        , orig_system_reference = decode(l_req_rec.orig_system_reference, null, orig_system_reference, l_req_rec.orig_system_reference)
                                        WHERE assignment_id = l_req_rec.requirement_id;
                                END IF;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Updating Original System Code and Reference', l_log_level);
                                END IF;
                        END IF;
                END IF;

                l_end_msg_count := FND_MSG_PUB.count_msg;
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'l_start_msg_count='||l_start_msg_count, l_log_level);
                        pa_debug.write(l_module, 'l_end_msg_count='||l_end_msg_count, l_log_level);
                END IF;
                l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Repopulating Error Message Stack', l_log_level);
                        END IF;

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;
                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Repopulating Error Message Stack', l_log_level);
                        END IF;
                END IF;
                i := p_requirement_in_tbl.next(i);
        END LOOP;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'All records are done', l_log_level);
                pa_debug.write(l_module, 'l_error_flag='||l_error_flag, l_log_level);
                pa_debug.write(l_module, 'FND_MSG_PUB.count_msg='||FND_MSG_PUB.count_msg, l_log_level);
        END IF;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_REQUIREMENTS_SP;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SQLERRM;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_REQUIREMENTS_SP;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'UPDATE_REQUIREMENTS'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;
END UPDATE_REQUIREMENTS;

-- Start of comments
--	API name 	: DELETE_REQUIREMENTS
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This API is a public API to delete one or more requirements for one or more projects.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are:	FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_requirement_in_tbl	IN  REQUIREMENT_IN_TBL_TYPE	Required
--					Table of requirement records. Please see the REQUIREMENT_IN_TBL_TYPE datatype table.
--	OUT		:
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - avaithia  - Created
-- End of comments
PROCEDURE DELETE_REQUIREMENTS
(
  p_api_version_number		IN		NUMBER   := 1.0
, p_init_msg_list		IN		VARCHAR2 := FND_API.G_TRUE
, p_commit			IN		VARCHAR2 := FND_API.G_FALSE
, p_requirement_in_tbl		IN		REQUIREMENT_IN_TBL_TYPE
, x_return_status		OUT	NOCOPY	VARCHAR2
, x_msg_count			OUT	NOCOPY	NUMBER
, x_msg_data			OUT	NOCOPY	VARCHAR2
)
IS
l_calling_application           VARCHAR2(10)            := 'PLSQL';
l_calling_module                VARCHAR2(10)            := 'AMG';
l_check_id_flag                 VARCHAR2(1)             := 'Y';
l_check_role_security_flag      VARCHAR2(1)             := 'Y';
l_check_resource_security_flag  VARCHAR2(1)             := 'Y';

l_log_level                     NUMBER                  := 3;
l_module                        VARCHAR2(100)           := 'PA_RES_MANAGEMENT_AMG_PUB.DELETE_REQUIREMENTS';
l_commit                        VARCHAR2(1)             := FND_API.G_FALSE;
l_init_msg_list                 VARCHAR2(1)             := FND_API.G_FALSE;
l_validate_only                 VARCHAR2(1)             := FND_API.G_FALSE;

l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_data                          VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);

i                               NUMBER;

l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
l_error_flag                    VARCHAR2(1)             := 'N';
l_error_flag_local              VARCHAR2(1)             := 'N';

l_req_rec		        REQUIREMENT_IN_REC_TYPE;

l_dummy_code                    VARCHAR2(30);
l_loop_msg_count                NUMBER                  :=0;
l_start_msg_count               NUMBER                  :=0;
l_end_msg_count                 NUMBER                  :=0;

l_missing_params                VARCHAR2(1000);
l_privilege                     VARCHAR2(30);
l_object_name                   VARCHAR2(30);
l_object_key                    NUMBER;
l_error_message_code            VARCHAR2(30);
l_ret_code                      VARCHAR2(1);

l_assignment_number             NUMBER;
l_assignment_row_id             ROWID;
l_assignment_type               VARCHAR2(30)            := 'OPEN_ASSIGNMENT';
l_record_version_number	        NUMBER;
l_assignment_id			NUMBER;
l_project_id			NUMBER;
l_team_template_id		NUMBER;
l_status_code			VARCHAR2(30);
l_system_status_code		VARCHAR2(30);

CURSOR c_derive_values(p_requirement_id IN NUMBER) IS
SELECT ROWID,project_id,record_version_number,ASSIGNMENT_TEMPLATE_ID,assignment_number,status_code
FROM   pa_project_assignments
WHERE  assignment_id = p_requirement_id
AND  ASSIGNMENT_TYPE = l_assignment_type ;

CURSOR c_get_system_status IS
SELECT PROJECT_SYSTEM_STATUS_CODE
FROM   pa_project_statuses
WHERE  project_status_code = l_status_code
AND  status_type  = 'OPEN_ASGMT';

BEGIN

        --------------------------------------------------
        -- RESET OUT params
        --------------------------------------------------
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_msg_count := 0;
	x_msg_data := NULL ;

        --------------------------------------------------
        -- Initialize Current Function and Msg Stack
        --------------------------------------------------
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'DELETE_REQUIREMENTS', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;
        --------------------------------------------------
        -- Create Savepoint
        --------------------------------------------------
        IF p_commit = FND_API.G_TRUE THEN
                savepoint DELETE_REQUIREMENTS_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of DELETE_REQUIREMENTS', l_log_level);
        END IF;
        --------------------------------------------------
        -- Start Initialize
        --------------------------------------------------
        PA_STARTUP.INITIALIZE(
                  p_calling_application => l_calling_application
                , p_calling_module => l_calling_module
                , p_check_id_flag => l_check_id_flag
                , p_check_role_security_flag => l_check_role_security_flag
                , p_check_resource_security_flag => l_check_resource_security_flag
                , p_debug_level => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of PA_STARTUP.INITIALIZE', l_log_level);
        END IF;
        --------------------------------------------------
        -- Defaulting Values and Mandatory param validations
        -- Security Check
        -- Core Logic
        --------------------------------------------------
        i := p_requirement_in_tbl.first;

        WHILE i is not NULL LOOP
                l_error_flag_local := 'N';
                l_missing_params := null;
                l_req_rec := null;

                l_start_msg_count := FND_MSG_PUB.count_msg;

                l_req_rec := p_requirement_in_tbl(i);

                -- Blank Out Parameters if not passed.
           	IF l_req_rec.requirement_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_req_rec.requirement_id := NULL  ;
		END IF;

		IF l_req_rec.record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_req_rec.record_version_number := NULL ;
		END IF;

		IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Requirement_id is ' || l_req_rec.requirement_id,l_log_level);
			pa_debug.write(l_module, 'Record Version Number is ' || l_req_rec.record_version_number, l_log_level);
                END IF;

                -- Mandatory Parameters Check
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory Parameter Validation Starts', l_log_level);
                END IF;

		IF l_req_rec.requirement_id IS NULL THEN
			l_missing_params := l_missing_params||'REQUIREMENT_ID ' ;
		END IF;


		IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory Parameter Validation Over. ',l_log_level);
			pa_debug.write(l_module, 'The missing parameters are '||l_missing_params, l_log_level);
                END IF;

                IF l_missing_params IS NOT NULL THEN
                        l_error_flag_local := 'Y';
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                END IF;

		IF l_error_flag_local <> 'Y' THEN

                	l_assignment_id := l_req_rec.requirement_id ;
                	-- Derive the other values
                	OPEN c_derive_values(l_assignment_id);
                	FETCH c_derive_values INTO l_assignment_row_id ,l_project_id,l_record_version_number,l_team_template_id,l_assignment_number,l_status_code;
			IF c_derive_values%NOTFOUND THEN
                                l_missing_params := l_missing_params||'REQUIREMENT_ID ' ;
                                l_error_flag_local := 'Y';
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                        'INVALID_PARAMS', l_missing_params);
			END IF;
               		CLOSE c_derive_values;

			IF l_error_flag_local <> 'Y' THEN

                        l_system_status_code := null;
                        OPEN c_get_system_status ;
			FETCH c_get_system_status INTO l_system_status_code ;
			CLOSE c_get_system_status;

			--IF l_system_status_code IN ('OPEN_ASGMT_CANCEL','OPEN_ASGMT_FILLED') THEN --Bug 7638990
			IF l_system_status_code IN ('OPEN_ASGMT_FILLED') THEN  --Bug 7638990
				l_error_flag_local := 'Y' ;
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_STS_ACT_NOT_ALLW');
			END IF;

                	-- Security Check
                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Checking Security for record number '||i, l_log_level);
                        END IF;

                        IF l_project_id IS NOT NULL THEN
                                l_privilege := 'PA_ASN_CR_AND_DL';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_project_id ;
			ELSIF l_team_template_id IS NOT NULL THEN
                                l_privilege := 'PA_PRM_DEFINE_TEAM_TEMPLATE';
                                l_object_name := null;
                                l_object_key := null;
			ELSE -- This wont happen
				PA_UTILS.ADD_MESSAGE('PA', 'PA_UNEXPECTED ERROR');
                                raise FND_API.G_EXC_ERROR;
                        END IF;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                  x_ret_code       => l_ret_code
                                , x_return_status  => l_return_status
                                , x_msg_count      => l_msg_count
                                , x_msg_data       => l_msg_data
                                , p_privilege      => l_privilege
                                , p_object_name    => l_object_name
                                , p_object_key     => l_object_key
				,p_init_msg_list   => FND_API.G_FALSE);

                        IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                -- This message does not have token defined, but intentionally putting token
                                -- because we still want to show the privilege name which is missing
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_CR_DL'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                l_error_flag_local := 'Y';
                        END IF;

			END IF;
	         END IF;

                -- Call Actual API
                IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling PA_ASSIGNMENTS_PUB.DELETE_ASSIGNMENT for record number'||i, l_log_level);
                        END IF;


			PA_ASSIGNMENTS_PUB.Delete_Assignment
			( p_assignment_row_id => l_assignment_row_id
 			, p_assignment_id     => l_assignment_id
 			, p_record_version_number  => l_record_version_number
			, p_assignment_type        => l_assignment_type
 			, p_assignment_number      => l_assignment_number
 			, p_commit                 => l_commit
 			, p_validate_only          => l_validate_only
 			, x_return_status          => l_return_status
 			, x_msg_count              => l_msg_count
 			, x_msg_data               => l_msg_data
 			);
                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After call PA_ASSIGNMENTS_PUB.DELETE_ASSIGNMENT l_return_status='||l_return_status, l_log_level);
                        END IF;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                l_error_flag_local := 'Y';
                        END IF;
                END IF;

                l_end_msg_count := FND_MSG_PUB.count_msg;
                l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;
                END IF;
                i := p_requirement_in_tbl.next(i);
        END LOOP;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO DELETE_REQUIREMENTS_SP;
        END IF;

	IF c_derive_values%ISOPEN THEN
		CLOSE c_derive_values ;
	END IF;

	IF c_get_system_status%ISOPEN THEN
                CLOSE c_get_system_status ;
	END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SQLERRM;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO DELETE_REQUIREMENTS_SP;
        END IF;

        IF c_derive_values%ISOPEN THEN
                CLOSE c_derive_values ;
        END IF;

        IF c_get_system_status%ISOPEN THEN
                CLOSE c_get_system_status ;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'DELETE_REQUIREMENTS'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;
END DELETE_REQUIREMENTS;

-- Start of comments
--	API name 	: STAFF_REQUIREMENTS
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to staff the requirements.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are:	FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_staff_requirement_tbl	IN  STAFF_REQUIREMENT_TBL_TYPE	Required
--					Table of staffing information for each requirement. Please see the datatype Staff_requirement_tbl_TYPE.
--	OUT		:
--				x_assignment_id_tbl	OUT SYSTEM.PA_NUM_TBL_TYPE
--					Table to store the staffed assignment ids and newly created requirement_ids
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - avaithia  - Created
-- End of comments
PROCEDURE STAFF_REQUIREMENTS
(
  p_api_version_number          IN              NUMBER   := 1.0
, p_init_msg_list               IN              VARCHAR2 := FND_API.G_TRUE
, p_commit                      IN              VARCHAR2 := FND_API.G_FALSE
, P_STAFF_REQUIREMENT_TBL       IN              STAFF_REQUIREMENT_TBL_TYPE
, X_ASSIGNMENT_ID_TBL           OUT     NOCOPY  SYSTEM.PA_NUM_TBL_TYPE
, x_return_status               OUT     NOCOPY  VARCHAR2
, x_msg_count                   OUT     NOCOPY  NUMBER
, x_msg_data                    OUT     NOCOPY  VARCHAR2
)
IS
l_calling_application           VARCHAR2(10)            := 'PLSQL';
l_calling_module                VARCHAR2(10)            := 'AMG';
l_check_id_flag                 VARCHAR2(1)             := 'Y';
l_check_role_security_flag      VARCHAR2(1)             := 'Y';
l_check_resource_security_flag  VARCHAR2(1)             := 'Y';

l_log_level                     NUMBER                  := 3;
l_module                        VARCHAR2(100)           := 'PA_RES_MANAGEMENT_AMG_PUB.STAFF_REQUIREMENTS';
l_commit                        VARCHAR2(1)             := FND_API.G_FALSE;
l_init_msg_list                 VARCHAR2(1)             := FND_API.G_FALSE;
l_validate_only                 VARCHAR2(1)             := FND_API.G_FALSE;

l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_data                          VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);

i                               NUMBER;

l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
l_error_flag                    VARCHAR2(1)             := 'N';
l_error_flag_local              VARCHAR2(1)             := 'N';

l_loop_msg_count                NUMBER                  :=0;
l_start_msg_count               NUMBER                  :=0;
l_end_msg_count                 NUMBER                  :=0;
l_before_api_msg_count		NUMBER                  :=0;
l_after_api_msg_count		NUMBER			:=0;

l_missing_params                VARCHAR2(1000);
l_privilege                     VARCHAR2(30);
l_object_name                   VARCHAR2(30);
l_object_key                    NUMBER;
l_error_message_code            VARCHAR2(30);
l_ret_code                      VARCHAR2(1);

l_staff_rec			STAFF_REQUIREMENT_REC_TYPE ;

l_requirement_creation_mode     VARCHAR2(10);
l_source_requirement_id         NUMBER;
l_resource_id               	NUMBER;
l_person_id                 	NUMBER;
l_assignment_status_code        VARCHAR2(30);
l_assignment_status_name    	VARCHAR2(80);
l_unfilled_assign_status_code	VARCHAR2(30);
l_unfilled_assign_status_name   VARCHAR2(80);
l_remaining_candidate_code      VARCHAR2(30);
l_change_reason_code            VARCHAR2(30);
l_record_version_number		NUMBER;
l_start_date			DATE;
l_end_date			DATE;

l_project_id 			NUMBER;
l_team_template_id		NUMBER;
l_status_code 			NUMBER;
l_db_start_date			DATE;
l_db_end_date			DATE;

l_out_assignment_id		NUMBER;
l_out_assignment_number		NUMBER;
l_out_assignment_row_id		ROWID;
l_out_resource_id		NUMBER;

CURSOR c_derive_values(c_source_reqmt_id IN NUMBER) IS
SELECT project_id,ASSIGNMENT_TEMPLATE_ID ,status_code,start_date,end_date
FROM   pa_project_assignments
WHERE  assignment_id = c_source_reqmt_id ;

CURSOR c_valid_status_code IS
SELECT project_status_name from pa_project_statuses
where
status_type = 'STAFFED_ASGMT'
and   project_status_code = l_assignment_status_code
and   trunc(SYSDATE) between start_date_active and nvl(end_date_active, trunc(SYSDATE))
and   starting_status_flag = 'Y' and project_system_status_code <> 'STAFFED_ASGMT_CONF';

CURSOR c_valid_unfilled_status_code IS
SELECT project_status_name from pa_project_statuses
where
status_type = 'OPEN_ASGMT'
and   project_status_code = l_unfilled_assign_status_code
and   trunc(SYSDATE) between start_date_active and nvl(end_date_active, trunc(SYSDATE))
and   starting_status_flag = 'Y' ;

CURSOR c_valid_status_name IS
SELECT project_status_code from pa_project_statuses
where
status_type = 'STAFFED_ASGMT'
and   project_status_name = l_assignment_status_name
and   trunc(SYSDATE) between start_date_active and nvl(end_date_active, trunc(SYSDATE))
and   starting_status_flag = 'Y' and project_system_status_code <> 'STAFFED_ASGMT_CONF';

CURSOR c_valid_unfilled_status_name IS
SELECT project_status_code from pa_project_statuses
where
status_type = 'OPEN_ASGMT'
and   project_status_name = l_unfilled_assign_status_name
and   trunc(SYSDATE) between start_date_active and nvl(end_date_active, trunc(SYSDATE))
and   starting_status_flag = 'Y' ;

BEGIN

        --------------------------------------------------
        -- RESET OUT params
        --------------------------------------------------
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        x_msg_data := NULL ;

	X_ASSIGNMENT_ID_TBL := SYSTEM.PA_NUM_TBL_TYPE();
        --------------------------------------------------
        -- Initialize Current Function and Msg Stack
        --------------------------------------------------
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'STAFF_REQUIREMENTS', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;
        --------------------------------------------------
        -- Create Savepoint
        --------------------------------------------------
        IF p_commit = FND_API.G_TRUE THEN
                savepoint STAFF_REQUIREMENTS_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of STAFF_REQUIREMENTS', l_log_level);
        END IF;
        --------------------------------------------------
        -- Start Initialize
        --------------------------------------------------
        PA_STARTUP.INITIALIZE(
                  p_calling_application => l_calling_application
                , p_calling_module => l_calling_module
                , p_check_id_flag => l_check_id_flag
                , p_check_role_security_flag => l_check_role_security_flag
                , p_check_resource_security_flag => l_check_resource_security_flag
                , p_debug_level => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of PA_STARTUP.INITIALIZE', l_log_level);
        END IF;
        --------------------------------------------------
        -- Defaulting Values and Mandatory param validations
        -- Security Check
        -- Core Logic
        --------------------------------------------------
	i := P_STAFF_REQUIREMENT_TBL.FIRST ;

        WHILE i is not NULL LOOP
                l_error_flag_local := 'N';
                l_missing_params := null;
		l_staff_rec :=  NULL ;
                l_start_msg_count := FND_MSG_PUB.count_msg;

		l_staff_rec := P_STAFF_REQUIREMENT_TBL(i);

		------------------------------------------------------------------------------------------
                -- Blank Out Parameters if not passed.
	        ------------------------------------------------------------------------------------------
		-- Commented out as this param needs to be derived inside code
		-- it should not be exposed to the user


		IF l_staff_rec.source_requirement_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_staff_rec.source_requirement_id := NULL ;
                END IF;

	 	IF l_staff_rec.resource_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_staff_rec.resource_id := NULL ;
                END IF;

		IF l_staff_rec.person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_staff_rec.person_id := NULL ;
                END IF;

		IF l_staff_rec.assignment_status_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_staff_rec.assignment_status_code := NULL ;
                END IF;

		IF l_staff_rec.assignment_status_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_staff_rec.assignment_status_name := NULL ;
                END IF;

		IF l_staff_rec.unfilled_assign_status_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_staff_rec.unfilled_assign_status_code := NULL ;
                END IF;

		IF l_staff_rec.unfilled_assign_status_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_staff_rec.unfilled_assign_status_name := NULL ;
                END IF;

		IF l_staff_rec.remaining_candidate_code  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_staff_rec.remaining_candidate_code := NULL ;
                END IF;

		IF l_staff_rec.change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_staff_rec.change_reason_code := NULL ;
                END IF;

                IF l_staff_rec.record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_staff_rec.record_version_number := NULL ;
                END IF;

		IF l_staff_rec.start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
			l_staff_rec.start_date := NULL ;
		END IF;

		IF l_staff_rec.end_Date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
                        l_staff_rec.end_Date := NULL ;
                END IF;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module,'Source Requirement ID ' || l_staff_rec.source_requirement_id,l_log_level);
			pa_debug.write(l_module,'Record Version Number ' ||l_staff_rec.record_version_number,l_log_level);
			pa_debug.write(l_module,'Resource id ' || l_staff_rec.resource_id,l_log_level);
                        pa_debug.write(l_module,'Person Id ' || l_staff_rec.person_id,l_log_level);
                        pa_debug.write(l_module,'Asgmt Status code ' ||l_staff_rec.assignment_status_code,l_log_level);
			pa_debug.write(l_module,'Asgmt Status name ' ||l_staff_rec.assignment_status_name,l_log_level);
                        pa_debug.write(l_module,'Unfilled Asgmt Status code ' ||l_staff_rec.unfilled_assign_status_code,l_log_level);
                        pa_debug.write(l_module,'Unfilled Asgmt Status Name ' ||l_staff_rec.unfilled_assign_status_name,l_log_level);
			pa_debug.write(l_module,'Remaining Candidate Code ' ||l_staff_rec.remaining_candidate_code,l_log_level);
			pa_debug.write(l_module,'Change Reason Code ' ||l_staff_rec.change_reason_code,l_log_level);
			pa_debug.write(l_module,'Start date ' || l_staff_rec.start_date,l_log_level);
                        pa_debug.write(l_module,'End date ' || l_staff_rec.end_Date,l_log_level);

		END IF;

		l_source_requirement_id := l_staff_rec.source_requirement_id;
		l_record_version_number := l_staff_rec.record_version_number;
		-- l_requirement_creation_mode := l_staff_rec.requirement_creation_mode;
		l_resource_id := l_staff_rec.resource_id ;
		l_person_id := l_staff_rec.person_id ;
		l_assignment_status_code := l_staff_rec.assignment_status_code ;
		l_assignment_status_name := l_staff_rec.assignment_status_name ;
	 	l_unfilled_assign_status_code := l_staff_rec.unfilled_assign_status_code;
		l_unfilled_assign_status_name := l_staff_rec.unfilled_assign_status_name ;
		l_remaining_candidate_code := l_staff_rec.remaining_candidate_code;
		l_change_reason_code := l_staff_rec.change_reason_code ;
		l_start_date := l_staff_rec.start_date ;
		l_end_date := l_staff_rec.end_Date;
		------------------------------------------
		-- Mandatory params check
		------------------------------------------
		IF l_source_requirement_id IS NULL THEN
			l_missing_params := l_missing_params||'SOURCE_REQUIREMENT_ID' ;
                END IF;

		IF l_record_version_number IS NULL THEN
                        l_missing_params := l_missing_params||', RECORD_VERSION_NUMBER ';
		END IF;

		IF l_start_date IS NULL THEN
			l_missing_params := l_missing_params||', START_DATE ';
		END IF;

		IF l_end_Date IS NULL THEN
			l_missing_params := l_missing_params||', END_DATE ';
		END IF;

		IF l_resource_id IS NULL THEN
			IF l_person_id IS NOT NULL THEN
				l_resource_id := PA_RESOURCE_UTILS.GET_RESOURCE_ID(l_person_id);
			ELSE -- if both are NULL
				l_missing_params := l_missing_params||', RESOURCE_ID ';
			END IF;
		END IF;

		IF l_person_id IS NULL THEN
			IF l_resource_id IS NOT NULL THEN
				l_person_id := PA_RESOURCE_UTILS.GET_PERSON_ID(l_resource_id);
			ELSE -- if both are NULL
				l_missing_params := l_missing_params||', PERSON_ID ';
			END IF;
		END IF;

		IF l_assignment_status_code IS NULL THEN
			IF l_assignment_status_name IS  NULL THEN
				-- both NULL ,then add them .Any one is available,derive the other
				l_missing_params := l_missing_params||', ASSIGNMENT_STATUS_CODE , ASSIGNMENT_STATUS_NAME';
			END IF;
		END IF;

		IF l_missing_params IS NOT NULL THEN
                        l_error_flag_local := 'Y';
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                	IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'The missing parameters are '||l_missing_params, l_log_level);
			END IF;
		END IF;

		------------------------------------------------------------------------
		-- 1) Derive Values and verify for valid values 2) Do Security Check
		------------------------------------------------------------------------
		IF l_error_flag_local <> 'Y' THEN
			OPEN c_derive_values(l_source_requirement_id);
			FETCH c_derive_values INTO l_project_id,l_team_template_id,l_status_code,l_db_start_date,l_db_end_date;
                        IF c_derive_values%NOTFOUND THEN
                                l_error_flag_local := 'Y' ;
                                l_missing_params := l_missing_params||'SOURCE_REQUIREMENT_ID' ;
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
			ELSE
				-- If the requirement exists ,determine the mode and validate status values passed
				-- Logic got from AssignResourceVORowImpl.java

				-- 1) Creation Mode
				IF l_start_date > l_db_start_date OR l_end_date < l_db_end_date THEN
					l_requirement_creation_mode := 'PARTIAL';
				ELSE
					l_requirement_creation_mode := 'FULL';
				END IF;

				-- 2) Assignment Status Code Validation
				IF l_assignment_status_code IS NOT NULL THEN
					-- Anusha : Existing API just checks whether the status code name exists in
					-- pa_project_statuses table

					-- It does not check whether the status is a valid starting status and not
					-- Confirmed etc.

					-- Hence we need in explicitly here. In UI (SS) its controlled by poplist query.

					-- Validate the passed status code
					-- If its a valid code passed,it will auto populate status name
					OPEN c_valid_status_code;
					FETCH c_valid_status_code into l_assignment_status_name;

					IF c_valid_status_code%NOTFOUND	THEN
					-- Invalid status code has been passed.
					l_error_flag_local := 'Y' ;
					PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_ASG_STATUS',--New message
					'SOURCE_REQUIREMENT_ID',l_source_requirement_id,'STATUS_CODE',l_assignment_status_code);
					END IF;
					CLOSE c_valid_status_code ;
				ELSE -- if status code is NULL
					-- Validate the passed status name
					-- If its a valid name passed,it will auto populate status code
					OPEN c_valid_status_name;
					FETCH c_valid_status_name into l_assignment_status_code;

					IF c_valid_status_name%NOTFOUND THEN
                                        -- Invalid status name has been passed .Here ,code is also nt passed
					l_error_flag_local := 'Y' ;
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_ASG_STATUS',
                                        'SOURCE_REQUIREMENT_ID',l_source_requirement_id,'STATUS_NAME',l_assignment_status_name);
					END IF;
					CLOSE c_valid_status_name ;
				END IF;

				-- 3) Validate the unfilled open assignment status value passed
				IF l_unfilled_assign_status_code is not NULL THEN

					-- Anusha : Existing API just checks whether the status code name exists in
                                        -- pa_project_statuses table

                                        -- It does not check whether the status is a valid starting status and
					-- whether its a status specific to Open Requirements .
					-- In SS ,this condition is controlled by Poplist query.So,here we need to
					-- simulate the same

                                        -- Validate the passed status code
                                        -- If its a valid code passed,it will auto populate status name
					OPEN c_valid_unfilled_status_code;
					FETCH c_valid_unfilled_status_code into l_unfilled_assign_status_name ;

					IF c_valid_unfilled_status_code%NOTFOUND THEN
                                        -- Invalid statuscode has been passed.
                                        l_error_flag_local := 'Y' ;
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_UNFILL_INV_STATUS',--New message
                                        'SOURCE_REQUIREMENT_ID',l_source_requirement_id,'UNFILLED_STATUS_CODE',l_unfilled_assign_status_code);
					END IF;
					CLOSE c_valid_unfilled_status_code;
				ELSE -- if unfilled status code is NULL
                                        -- Validate the passed unfilled status name
                                        -- If its a valid name passed,it will auto populate status code
                                        OPEN c_valid_unfilled_status_name;
					FETCH c_valid_unfilled_status_name into l_unfilled_assign_status_code;
					IF c_valid_unfilled_status_name%NOTFOUND THEN
                                        -- Invalid unfilled status name has been passed .Here ,code is also nt passed
                                        l_error_flag_local := 'Y' ;
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_UNFILL_INV_STATUS',
					'SOURCE_REQUIREMENT_ID',l_source_requirement_id,'UNFILLED_STATUS_NAME',l_unfilled_assign_status_name);
					END IF;
					CLOSE c_valid_unfilled_status_name;
				END IF;
                        END IF;
                        CLOSE c_derive_values;
		END IF;

		IF l_error_flag_local <> 'Y' THEN
			IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Checking Security for record number '||i, l_log_level);
                        END IF;

                        IF l_project_id IS NOT NULL THEN
                                l_privilege := 'PA_ASN_CR_AND_DL';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_project_id ;
                        ELSIF l_team_template_id IS NOT NULL THEN
                                l_privilege := 'PA_PRM_DEFINE_TEAM_TEMPLATE';
                                l_object_name := null;
                                l_object_key := null;
                        ELSE -- This wont happen though (using hard coded english for internal reference)
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_UNEXPECTED ERROR');
                                raise FND_API.G_EXC_ERROR;
                        END IF;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

			PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                         x_ret_code       => l_ret_code
                       , x_return_status  => l_return_status
                       , x_msg_count      => l_msg_count
                       , x_msg_data       => l_msg_data
                       , p_privilege      => l_privilege
                       , p_object_name    => l_object_name
                       , p_object_key     => l_object_key
                       ,p_init_msg_list   => FND_API.G_FALSE);
                                                                                                                                                  IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                            -- This message does not have token defined, but intentionally putting token
                            -- because we still want to show the privilege name which is missing
                               PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_STAFF'
                                                         ,'MISSING_PRIVILEGE', l_privilege);
                               l_error_flag_local := 'Y';
                       END IF;
 		END IF;

		--------------------------------------------------------
		-- Call Actual API
		--------------------------------------------------------
		IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_msg_count:= 0;
                        l_msg_data := NULL ;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling PA_ASSIGNMENTS_PUB.Execute_Staff_Assign_From_Open for record number ' || i, l_log_level);
                        END IF;

			l_before_api_msg_count := FND_MSG_PUB.count_msg;
			PA_ASSIGNMENTS_PUB.Execute_Staff_Assign_From_Open
			( p_asgn_creation_mode          => l_requirement_creation_mode
			 ,p_record_version_number       => l_record_version_number
			 ,p_multiple_status_flag	=> 'N'
			 ,p_assignment_status_code      => l_assignment_status_code
			 ,p_assignment_status_name      => l_assignment_status_name
			 ,p_unfilled_assign_status_code => l_unfilled_assign_status_code
			 ,p_unfilled_assign_status_name => l_unfilled_assign_status_name
			 ,p_remaining_candidate_code    => l_remaining_candidate_code
			 ,p_change_reason_code          => l_change_reason_code
			 ,p_resource_id                 => l_resource_id
			 ,p_source_assignment_id        => l_source_requirement_id
			 ,p_start_date			=> l_start_date
			 ,p_end_date			=> l_end_date
			 ,p_init_msg_list               => l_init_msg_list
			 ,p_commit                      => l_commit
			 ,p_validate_only               => l_validate_only
			 ,x_new_assignment_id           => l_out_assignment_id
			 ,x_assignment_number           => l_out_assignment_number
			 ,x_assignment_row_id           => l_out_assignment_row_id
			 ,x_resource_id                 => l_out_resource_id
			 ,x_return_status               => l_return_status
			 ,x_msg_count                   => l_msg_count
			 ,x_msg_data                    => l_msg_data
			);

                        l_after_api_msg_count := FND_MSG_PUB.count_msg;
			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'After main API Call l_return_status ' || l_return_status,l_log_level);
				pa_debug.write(l_module, 'l_msg_count is ' || l_msg_count ||' and l_msg_data is ' ||l_msg_data);
			END IF;

			---------------------------------------------------------------------------------------------
			-- Populate OUT table appropriately
			---------------------------------------------------------------------------------------------
			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				l_error_flag_local := 'Y';
				X_ASSIGNMENT_ID_TBL.EXTEND(1);
				X_ASSIGNMENT_ID_TBL(X_ASSIGNMENT_ID_TBL.COUNT) := -1;
			ELSE -- Success
				IF (l_after_api_msg_count - l_before_api_msg_count) = 0 AND l_msg_data is NULL THEN
					X_ASSIGNMENT_ID_TBL.EXTEND(1);
					X_ASSIGNMENT_ID_TBL(X_ASSIGNMENT_ID_TBL.COUNT) := l_out_assignment_id ;
				ELSE -- some message populated while executing the called API
					l_error_flag_local := 'Y';
					X_ASSIGNMENT_ID_TBL.EXTEND(1);
					X_ASSIGNMENT_ID_TBL(X_ASSIGNMENT_ID_TBL.COUNT) := -1;
				END IF;
			END IF;

			---------------------------------------------------------------------------------------------
			l_end_msg_count := FND_MSG_PUB.count_msg;

			l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

			IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
				l_error_flag := 'Y';

				FOR j in l_start_msg_count+1..l_end_msg_count LOOP
					-- Always get from first location in stack i.e. l_start_msg_count+1
					-- Because stack moves down after delete
					FND_MSG_PUB.get (
					p_msg_index      => l_start_msg_count+1,
					p_encoded        => FND_API.G_FALSE,
					p_data           => l_data,
					p_msg_index_out  => l_msg_index_out );

				-- Always delete at first location in stack i.e. l_start_msg_count+1
				-- Because stack moves down after delete
				FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

				PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
					'RECORD_NO', i,'MESSAGE', l_data);
				END LOOP;
			END IF;
			---------------------------------------------------------------------------------------------
		END IF;
		i := P_STAFF_REQUIREMENT_TBL.NEXT(i);
	END LOOP;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO STAFF_REQUIREMENTS_SP;
        END IF;

        IF c_derive_values%ISOPEN THEN
                CLOSE c_derive_values ;
        END IF;

	IF c_valid_status_code%ISOPEN THEN
                CLOSE c_valid_status_code ;
	END IF;

	IF c_valid_status_name%ISOPEN THEN
                CLOSE c_valid_status_name;
	END IF;

        IF c_valid_unfilled_status_code%ISOPEN THEN
                CLOSE c_valid_unfilled_status_code ;
	END IF;

	IF c_valid_unfilled_status_name%ISOPEN THEN
                CLOSE c_valid_unfilled_status_name ;
	END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;


        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;
WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTRB(SQLERRM,1,240);

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO STAFF_REQUIREMENTS_SP;
        END IF;

        IF c_derive_values%ISOPEN THEN
                CLOSE c_derive_values ;
        END IF;

        IF c_valid_status_code%ISOPEN THEN
                CLOSE c_valid_status_code ;
        END IF;

        IF c_valid_status_name%ISOPEN THEN
                CLOSE c_valid_status_name;
        END IF;

        IF c_valid_unfilled_status_code%ISOPEN THEN
                CLOSE c_valid_unfilled_status_code ;
        END IF;

        IF c_valid_unfilled_status_name%ISOPEN THEN
                CLOSE c_valid_unfilled_status_name ;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'STAFF_REQUIREMENTS'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;

END STAFF_REQUIREMENTS;

-- Start of comments
--	API name 	: COPY_TEAM_ROLES
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to copy team roles from project assignments or requirements.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are: FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_req_asgn_id_tbl	IN  SYSTEM.PA_NUM_TBL_TYPE	Required
--					Table of requirement or assignment ids.
--					Reference: pa_project_assignments.assignment_id
--	OUT		:
--				x_req_asgn_id_tbl	OUT SYSTEM.PA_NUM_TBL_TYPE
--					Table to store the created requirement or assignment ids
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - avaithia  - Created
-- End of comments
PROCEDURE COPY_TEAM_ROLES
(
  p_api_version_number          IN              NUMBER   := 1.0
, p_init_msg_list               IN              VARCHAR2 := FND_API.G_TRUE
, p_commit                      IN              VARCHAR2 := FND_API.G_FALSE
, p_req_asgn_id_tbl             IN              SYSTEM.PA_NUM_TBL_TYPE
, x_req_asgn_id_tbl             OUT     NOCOPY  SYSTEM.PA_NUM_TBL_TYPE
, x_return_status               OUT     NOCOPY  VARCHAR2
, x_msg_count                   OUT     NOCOPY  NUMBER
, x_msg_data                    OUT     NOCOPY  VARCHAR2
)
IS
l_calling_application           VARCHAR2(10)            := 'PLSQL';
l_calling_module                VARCHAR2(10)            := 'AMG';
l_check_id_flag                 VARCHAR2(1)             := 'Y';
l_check_role_security_flag      VARCHAR2(1)             := 'Y';
l_check_resource_security_flag  VARCHAR2(1)             := 'Y';

l_log_level                     NUMBER                  := 3;
l_module                        VARCHAR2(100)           := 'PA_RES_MANAGEMENT_AMG_PUB.COPY_TEAM_ROLES';
l_commit                        VARCHAR2(1)             := FND_API.G_FALSE;
l_init_msg_list                 VARCHAR2(1)             := FND_API.G_FALSE;

l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_data                          VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);

i                               NUMBER;
k				NUMBER;

-- l_req_rec               REQUIREMENT_IN_REC_TYPE;
l_req_rec			NUMBER ;

l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
l_error_flag                    VARCHAR2(1)             := 'N';
l_error_flag_local              VARCHAR2(1)             := 'N';

l_loop_msg_count                NUMBER                  :=0;
l_start_msg_count               NUMBER                  :=0;
l_end_msg_count                 NUMBER                  :=0;

l_missing_params                VARCHAR2(1000);
l_privilege                     VARCHAR2(30);
l_object_name                   VARCHAR2(30);
l_object_key                    NUMBER;
l_error_message_code            VARCHAR2(30);
l_ret_code                      VARCHAR2(1);

l_req_asgn_id			NUMBER;
l_project_id			NUMBER;
l_team_template_id		NUMBER;

l_out_req_asgn_id		NUMBER;
l_out_req_asgn_number	 	NUMBER;
l_out_req_asgn_row_id 		ROWID;

l_before_api_msg_count		NUMBER;
l_after_api_msg_count		NUMBER;

l_status_code			VARCHAR2(30);

CURSOR c_derive_values(p_req_asgn_id IN NUMBER) IS
SELECT project_id,ASSIGNMENT_TEMPLATE_ID,status_code
FROM   pa_project_assignments
WHERE  assignment_id = p_req_asgn_id ;

CURSOR c_get_system_status IS
SELECT PROJECT_SYSTEM_STATUS_CODE
FROM   pa_project_statuses
WHERE  project_status_code = l_status_code
  AND  status_type  in ('OPEN_ASGMT','STAFFED_ASGMT');

l_system_status_code     	VARCHAR2(30);
BEGIN

        --------------------------------------------------
        -- RESET OUT params
        --------------------------------------------------
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        x_msg_data := NULL ;

	X_REQ_ASGN_ID_TBL := SYSTEM.PA_NUM_TBL_TYPE();
        --------------------------------------------------
        -- Initialize Current Function and Msg Stack
        --------------------------------------------------
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'COPY_TEAM_ROLES', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;
        --------------------------------------------------
        -- Create Savepoint
        --------------------------------------------------
        IF p_commit = FND_API.G_TRUE THEN
                savepoint COPY_TEAM_ROLES_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of COPY_TEAM_ROLES', l_log_level);
        END IF;
        --------------------------------------------------
        -- Start Initialize
        --------------------------------------------------
        PA_STARTUP.INITIALIZE(
                  p_calling_application => l_calling_application
                , p_calling_module => l_calling_module
                , p_check_id_flag => l_check_id_flag
                , p_check_role_security_flag => l_check_role_security_flag
                , p_check_resource_security_flag => l_check_resource_security_flag
                , p_debug_level => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of PA_STARTUP.INITIALIZE', l_log_level);
        END IF;
        --------------------------------------------------
        -- Defaulting Values and Mandatory param validations
        -- Security Check
        -- Core Logic
        --------------------------------------------------
        i := p_req_asgn_id_tbl.first;
        WHILE i is not NULL LOOP
                l_error_flag_local := 'N';
                l_missing_params := null;
                l_req_asgn_id := null;
		l_req_rec := NULL ;

                l_start_msg_count := FND_MSG_PUB.count_msg;

		l_req_rec := p_req_asgn_id_tbl(i);

		l_req_asgn_id := l_req_rec;

		-- Blank Out Parameters if not passed.
		IF l_req_asgn_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_req_asgn_id := NULL ;
		END IF ;

                -- Mandatory Parameters Check
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory Parameter Validation Starts', l_log_level);
                END IF;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'The Passed id is : ' || l_req_asgn_id ,l_log_level);
		END IF;

                IF l_req_asgn_id is NULL THEN
			l_missing_params := l_missing_params||'TEAM_ROLE_ID';
		END IF;

		IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory Parameter Validation Over. ',l_log_level);
                        pa_debug.write(l_module, 'The missing parameters are '||l_missing_params, l_log_level);
                END IF;

		IF l_missing_params IS NOT NULL THEN
                        l_error_flag_local := 'Y';
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                END IF;

		IF l_error_flag_local <> 'Y' THEN
			OPEN c_derive_values(l_req_asgn_id) ;
			FETCH c_derive_values INTO l_project_id ,l_team_template_id,l_status_code ;
			IF c_derive_values%NOTFOUND THEN

                                l_error_flag_local := 'Y' ;
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS'
							,'TEAM_ROLE_ID',l_req_asgn_id); -- New message to say invalid team role
			ELSE -- If team role exists
				OPEN c_get_system_status ;
                        	FETCH c_get_system_status INTO l_system_status_code ;
                        	CLOSE c_get_system_status;
      /* Bug 9159158
                        IF l_system_status_code IN ('OPEN_ASGMT_CANCEL','OPEN_ASGMT_FILLED','STAFFED_ASGMT_CANCEL') THEN
                                l_error_flag_local := 'Y' ;
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_CP_STATUS'); -- New message
                        END IF;
      */
                        END IF;
                        CLOSE c_derive_values;

			--------------------------------------------------------
                        -- Security Check
			--------------------------------------------------------

			IF l_error_flag_local <> 'Y' THEN

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Checking Security for record number '||i, l_log_level);
                        END IF;

                        IF l_project_id IS NOT NULL THEN
                                l_privilege := 'PA_ASN_CR_AND_DL';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_project_id ;
                        /* ELSIF l_team_template_id IS NOT NULL THEN
                                -- Commented as Copy team role functionality is not available to team templates

                                l_privilege := 'PA_PRM_DEFINE_TEAM_TEMPLATE';
                                l_object_name := null;
                                l_object_key := null;*/
                        ELSE -- This wont happen though (using hard coded english for internal reference)
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_UNEXPECTED ERROR');
                                raise FND_API.G_EXC_ERROR;
                        END IF;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                  x_ret_code       => l_ret_code
                                , x_return_status  => l_return_status
                                , x_msg_count      => l_msg_count
                                , x_msg_data       => l_msg_data
                                , p_privilege      => l_privilege
                                , p_object_name    => l_object_name
                                , p_object_key     => l_object_key
				,p_init_msg_list   => FND_API.G_FALSE);

                        IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                -- This message does not have token defined, but intentionally putting token
                                -- because we still want to show the privilege name which is missing
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_COPY_TM_RO'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                l_error_flag_local := 'Y';
                        END IF;

			END IF;
		END IF;

		--------------------------------------------------------
                -- Call Actual API
                --------------------------------------------------------
		IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;
			l_msg_count:= 0;
			l_msg_data := NULL ;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling PA_ASSIGNMENTS_PUB.COPY_TEAM_ROLES for record number'||i, l_log_level);
                        END IF;

			l_before_api_msg_count := FND_MSG_PUB.count_msg;
			PA_ASSIGNMENTS_PUB.Copy_Team_Role
                        (
                                p_assignment_id => l_req_asgn_id,
                                x_new_assignment_id => l_out_req_asgn_id ,
                                x_assignment_number => l_out_req_asgn_number,
                                x_assignment_row_id => l_out_req_asgn_row_id,
                                x_return_status     => l_return_status,
                                x_msg_count         => l_msg_count,
                                x_msg_data          => l_msg_data
                        );
			l_after_api_msg_count := FND_MSG_PUB.count_msg;

			IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After call PA_ASSIGNMENTS_PUB.COPY_TEAM_ROLES l_return_status='||l_return_status, l_log_level);
                        END IF;
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                l_error_flag_local := 'Y';
				X_REQ_ASGN_ID_TBL.extend(1);
                                X_REQ_ASGN_ID_TBL(X_REQ_ASGN_ID_TBL.COUNT) := -1;
			ELSE -- Success
				IF (l_after_api_msg_count - l_before_api_msg_count) = 0 AND l_msg_data is NULL THEN
					X_REQ_ASGN_ID_TBL.extend(1);
					X_REQ_ASGN_ID_TBL(X_REQ_ASGN_ID_TBL.COUNT) := l_out_req_asgn_id ;
				ELSE -- some message populated while executing the called API
					l_error_flag_local := 'Y';
					X_REQ_ASGN_ID_TBL.extend(1);
					X_REQ_ASGN_ID_TBL(X_REQ_ASGN_ID_TBL.COUNT) := -1 ; -- to indicate some wrong operation happened
				END IF;
                        END IF;
                END IF;

		l_end_msg_count := FND_MSG_PUB.count_msg;
                l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';


                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete

                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;
                END IF;

	i := p_req_asgn_id_tbl.next(i);
	END LOOP;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO COPY_TEAM_ROLES_SP;
        END IF;

        IF c_derive_values%ISOPEN THEN
                CLOSE c_derive_values ;
        END IF;

	IF c_get_system_status%ISOPEN THEN
		CLOSE c_get_system_status ;
	END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;


        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTRB(SQLERRM,1,240);

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO COPY_TEAM_ROLES_SP;
        END IF;

        IF c_derive_values%ISOPEN THEN
                CLOSE c_derive_values ;
        END IF;

        IF c_get_system_status%ISOPEN THEN
                CLOSE c_get_system_status ;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'COPY_TEAM_ROLES'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;

END COPY_TEAM_ROLES;

-- Start of comments
--	API name 	: CREATE_ASSIGNMENTS
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to create one or more assignments for one or more projects.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are: FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_assignment_in_tbl	IN  ASSIGNMENT_IN_TBL_TYPE	Required
--					Table of assignment records.
--					Please see the ASSIGNMENT_IN_TBL_TYPE datatype table.
--	OUT		:
--				x_assignment_id_tbl	OUT SYSTEM.PA_NUM_TBL_TYPE
--					Table to store assignment ids created by the API.
--					Reference: pa_project_assignments.assignment_id
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - amksingh  - Created
-- End of comments
PROCEDURE CREATE_ASSIGNMENTS
(
  p_api_version_number		IN		NUMBER   := 1.0
, p_init_msg_list		IN		VARCHAR2 := FND_API.G_TRUE
, p_commit			IN		VARCHAR2 := FND_API.G_FALSE
, p_assignment_in_tbl		IN		ASSIGNMENT_IN_TBL_TYPE
, x_assignment_id_tbl		OUT	NOCOPY	SYSTEM.PA_NUM_TBL_TYPE
, x_return_status		OUT	NOCOPY	VARCHAR2
, x_msg_count			OUT	NOCOPY	NUMBER
, x_msg_data			OUT	NOCOPY	VARCHAR2
)
IS
l_calling_application           VARCHAR2(10)            := 'PLSQL';
l_calling_module                VARCHAR2(10)            := 'AMG';
l_check_id_flag                 VARCHAR2(1)             := 'Y';
l_check_role_security_flag      VARCHAR2(1)             := 'Y';
l_check_resource_security_flag  VARCHAR2(1)             := 'Y';
l_log_level                     NUMBER                  := 3;
l_module                        VARCHAR2(100)           := 'PA_RES_MANAGEMENT_AMG_PUB.CREATE_ASSIGNMENTS';
l_commit                        VARCHAR2(1)             := FND_API.G_FALSE;
l_init_msg_list                 VARCHAR2(1)             := FND_API.G_FALSE;
l_validate_only                 VARCHAR2(1)             := FND_API.G_FALSE;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_data                          VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);

i                               NUMBER;
l_new_assignment_id_tbl         SYSTEM.PA_NUM_TBL_TYPE  := SYSTEM.PA_NUM_TBL_TYPE();
l_new_assignment_id             NUMBER;
l_assignment_number             NUMBER;
l_assignment_row_id             ROWID;
l_resource_id                   NUMBER;
l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
l_error_flag                    VARCHAR2(1)             := 'N';
l_error_flag_local              VARCHAR2(1)             := 'N';
l_asgn_rec		        ASSIGNMENT_IN_REC_TYPE;
l_asgn_creation_mode		VARCHAR2(10)	        := 'FULL';
--l_assignment_type		VARCHAR2(30)	        := 'OPEN_ASSIGNMENT';
l_multiple_status_flag		VARCHAR2(1)	        := 'N';
l_loop_msg_count                NUMBER                  :=0;
l_start_msg_count               NUMBER                  :=0;
l_end_msg_count                 NUMBER                  :=0;
l_missing_params                VARCHAR2(1000);
l_privilege                     VARCHAR2(30);
l_object_name                   VARCHAR2(30);
l_object_key                    NUMBER;
l_error_message_code            VARCHAR2(30);
l_ret_code                      VARCHAR2(1);


CURSOR c_get_valid_calendar_types(c_code VARCHAR2) IS
SELECT lookup_code
FROM pa_lookups
WHERE lookup_type = 'CHANGE_CALENDAR_TYPE_CODE'
AND lookup_code = c_code
AND lookup_code <> 'RESOURCE';

CURSOR c_get_project_dtls(c_project_id NUMBER) IS
SELECT role_list_id, multi_currency_billing_flag, calendar_id, work_type_id, location_id
FROM pa_projects_all
WHERE project_id = c_project_id;

CURSOR c_get_team_templ_dtls(c_team_templ_id NUMBER) IS
SELECT role_list_id, calendar_id, work_type_id
FROM pa_team_templates
WHERE team_template_id = c_team_templ_id;

CURSOR c_get_role_dtls(c_role_id NUMBER) IS
SELECT meaning
FROM   pa_project_role_types_vl
WHERE  project_role_id = c_role_id ;

CURSOR get_bill_rate_override_flags(c_project_id NUMBER) IS
SELECT impl.rate_discount_reason_flag ,impl.br_override_flag, impl.br_discount_override_flag
FROM pa_implementations_all impl
    , pa_projects_all proj
WHERE proj.org_id=impl.org_id   -- Removed nvl condition from org_id : Post review changes for Bug 5130421
AND proj.project_id = c_project_id ;

CURSOR c_get_lookup_exists(c_lookup_type VARCHAR2, c_lookup_code VARCHAR2) IS
SELECT 'Y'
FROM dual
WHERE EXISTS
(SELECT 'XYZ' FROM pa_lookups WHERE lookup_type = c_lookup_type AND lookup_code = c_lookup_code);

CURSOR c_get_location(c_location_id NUMBER) IS
SELECT country_code, region, city
FROM pa_locations
WHERE location_id = c_location_id;

CURSOR c_derive_country_code(c_country_name IN VARCHAR2) IS
SELECT country_code
FROM pa_country_v
WHERE name = c_country_name;

CURSOR c_derive_country_name(c_country_code IN VARCHAR2) IS
SELECT name
FROM pa_country_v
WHERE  country_code  = c_country_code;


-- This cursor is for future extension when we support creation of team role from planning resource
CURSOR c_get_planning_res_info(c_resource_list_member_id NUMBER, c_budget_version_id NUMBER, c_project_id NUMBER) IS
SELECT
  ra.resource_list_member_id
, firstrow.person_id
, rlm.resource_id
, PA_RESOURCE_UTILS.get_person_name_no_date(firstrow.person_id)
, ra.project_id
, ra.budget_version_id
, decode (ra.role_count, 1, firstrow.named_role, null) named_role
, decode (ra.role_count, 1, firstrow.project_role_id, null) project_role_id
, decode (ra.role_count, 1, ro.meaning, null) project_role
, ra.min_date task_assign_start_date
, ra.max_date task_assign_end_date
, firstrow.resource_assignment_id
, firstrow.res_type_code
FROM pa_resource_assignments firstrow
, pa_resource_list_members rlm
, pa_proj_roles_v ro
, (SELECT project_id , budget_version_id , resource_list_member_id , count(1) role_count , max(max_id) max_id
     , min(min_date) min_date , max(max_date) max_date
   FROM (SELECT project_id , budget_version_id , resource_list_member_id , project_role_id
           , max(resource_assignment_id) max_id , min(SCHEDULE_START_DATE) min_date , max(SCHEDULE_END_DATE) max_date
         FROM pa_resource_assignments
         WHERE ta_display_flag = 'Y' and nvl(PROJECT_ASSIGNMENT_ID, -1) = -1
         AND resource_class_code = 'PEOPLE'
         GROUP BY project_id, budget_version_id, resource_list_member_id, project_role_id
         ) res_roles
    GROUP BY project_id, budget_version_id, resource_list_member_id
   ) ra
WHERE ra.resource_list_member_id = rlm.resource_list_member_id
AND firstrow.resource_assignment_id = ra.max_id
AND firstrow.project_role_id = ro.project_role_id (+)
AND ra.budget_version_id = c_budget_version_id
AND ra.resource_list_member_id = c_resource_list_member_id
AND ra.project_id = c_project_id
AND firstrow.person_id IS NULL;
-- If the value from this cusror is returned, then passed resource list member id is valid
-- Pass this resource list member id, budget version id to internal API
-- Pass calendar type as PROJECT and calendar_id as of project
-- Pass sum_tasks_flag as N

-- In case of assignments, user can choose calendar type between PROJECT or RESOURCE
-- Pass this resource list member id, budget version id to internal API
-- Pass sum_tasks_flag as Y if calendar is RESOURCE
-- pass person_id, resource_id

-- Bug 5175060
CURSOR c_get_system_status_code(c_status_code VARCHAR2, c_status_type VARCHAR2) IS
SELECT project_system_status_code,starting_status_flag
FROM pa_project_statuses
WHERE status_type = c_status_type
AND project_status_code = c_status_code;

CURSOR c_get_sys_code_from_name(c_status_name VARCHAR2, c_status_type VARCHAR2) IS
SELECT project_system_status_code,starting_status_flag
FROM pa_project_statuses
WHERE status_type = c_status_type
AND project_status_name = c_status_name;

l_dummy_sys_code 		pa_project_statuses.project_system_status_code%TYPE;
--End 5175060

l_starting_status_flag		VARCHAR2(1);

l_role_list_id                  NUMBER;
l_multi_currency_billing_flag   VARCHAR2(1);
l_calendar_id                   NUMBER;
l_work_type_id                  NUMBER;
l_location_id                   NUMBER;
l_role_name                     VARCHAR2(80);
l_valid_flag                    VARCHAR2(1);
l_rate_discount_reason_flag     VARCHAR2(1);
l_br_override_flag              VARCHAR2(1);
l_br_discount_override_flag     VARCHAR2(1);
l_project_id_tmp                NUMBER;
l_project_role_id_tmp		NUMBER;
l_tp_currency_override_tmp      VARCHAR2(30);
l_my_person_id                  NUMBER;
l_my_resource_id                NUMBER;
l_my_resource_name              VARCHAR2(240);
l_valid_country                 VARCHAR2(1);
l_dummy_country_code            VARCHAR2(2);
l_dummy_state		        VARCHAR2(240);
l_dummy_city		        VARCHAR2(80);
l_out_location_id	        NUMBER;
l_bill_currency_override_tmp    VARCHAR2(30); -- 5144288, 5144369

BEGIN

        --Flows which are supported by this API
        ---------------------------------------
        --1. Create project assignments
        --        1.1 Setting basic information(staffing priority, staffing owner, subteams, location etc..)
        --        1.2 Setting schedule information(dates, status, calendar etc..)
        --        1.3 Setting forecast infomation(expenditure type etc..)
        --
        --Flows which are not supported by this API
        -------------------------------------------
        --1. Create team role for given planning resource

        --Mandatory parameters
        -----------------------
        --1. assignment_type should be specified.
        --2. Either project_role_id or project_role_name should be passed.
        --3. Either of project_id, project_name, project_number should be passed.
        --4. resource_id should be passed.
        --5. Both start_date and end_date should be passed.
        --6. Either status_code or status_name should be specified.


        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_assignment_id_tbl:= SYSTEM.pa_num_tbl_type();

        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'CREATE_ASSIGNMENTS', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint CREATE_ASSIGNMENTS_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of create_assignments', l_log_level);
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Printing Input Parameters......', l_log_level);
                i := p_assignment_in_tbl.first;
                WHILE i IS NOT NULL LOOP
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').assignment_id'||p_assignment_in_tbl(i).assignment_id, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').assignment_name'||p_assignment_in_tbl(i).assignment_name, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').assignment_type'||p_assignment_in_tbl(i).assignment_type, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_role_id'||p_assignment_in_tbl(i).project_role_id, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_role_name'||p_assignment_in_tbl(i).project_role_name, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_id'||p_assignment_in_tbl(i).project_id, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_name'||p_assignment_in_tbl(i).project_name, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_number'||p_assignment_in_tbl(i).project_number, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').resource_id'||p_assignment_in_tbl(i).resource_id, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').staffing_owner_person_id'||p_assignment_in_tbl(i).staffing_owner_person_id, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').staffing_priority_code'||p_assignment_in_tbl(i).staffing_priority_code, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').staffing_priority_name'||p_assignment_in_tbl(i).staffing_priority_name, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_subteam_id'||p_assignment_in_tbl(i).project_subteam_id, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_subteam_name'||p_assignment_in_tbl(i).project_subteam_name, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').location_id'||p_assignment_in_tbl(i).location_id, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').location_country_code'||p_assignment_in_tbl(i).location_country_code, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').location_country_name'||p_assignment_in_tbl(i).location_country_name, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').location_region'||p_assignment_in_tbl(i).location_region, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').location_city'||p_assignment_in_tbl(i).location_city, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').description'||p_assignment_in_tbl(i).description, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').additional_information'||p_assignment_in_tbl(i).additional_information, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').start_date'||p_assignment_in_tbl(i).start_date, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').end_date'||p_assignment_in_tbl(i).end_date, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').status_code'||p_assignment_in_tbl(i).status_code, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').status_name'||p_assignment_in_tbl(i).status_name, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').calendar_type'||p_assignment_in_tbl(i).calendar_type, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').calendar_id'||p_assignment_in_tbl(i).calendar_id, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').calendar_name'||p_assignment_in_tbl(i).calendar_name, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').resource_calendar_percent'||p_assignment_in_tbl(i).resource_calendar_percent, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').expenditure_type_class'||p_assignment_in_tbl(i).expenditure_type_class, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').expenditure_type'||p_assignment_in_tbl(i).expenditure_type, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').work_type_id'||p_assignment_in_tbl(i).work_type_id, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').work_type_name'||p_assignment_in_tbl(i).work_type_name, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').bill_rate_option'||p_assignment_in_tbl(i).bill_rate_option, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').bill_rate_override'||p_assignment_in_tbl(i).bill_rate_override, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').bill_rate_curr_override'||p_assignment_in_tbl(i).bill_rate_curr_override, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').markup_percent_override'||p_assignment_in_tbl(i).markup_percent_override, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').discount_percentage'||p_assignment_in_tbl(i).discount_percentage, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').rate_disc_reason_code'||p_assignment_in_tbl(i).rate_disc_reason_code, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').tp_rate_option'||p_assignment_in_tbl(i).tp_rate_option, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').tp_rate_override'||p_assignment_in_tbl(i).tp_rate_override, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').tp_currency_override'||p_assignment_in_tbl(i).tp_currency_override, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').tp_calc_base_code_override'||p_assignment_in_tbl(i).tp_calc_base_code_override, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').tp_percent_applied_override'||p_assignment_in_tbl(i).tp_percent_applied_override, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').extension_possible'||p_assignment_in_tbl(i).extension_possible, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').expense_owner'||p_assignment_in_tbl(i).expense_owner, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').expense_limit'||p_assignment_in_tbl(i).expense_limit, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').orig_system_code'||p_assignment_in_tbl(i).orig_system_code, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').orig_system_reference'||p_assignment_in_tbl(i).orig_system_reference, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').record_version_number'||p_assignment_in_tbl(i).record_version_number, l_log_level);
			pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').auto_approve ' || p_assignment_in_tbl(i).auto_approve, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute_category'||p_assignment_in_tbl(i).attribute_category, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute1'||p_assignment_in_tbl(i).attribute1, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute2'||p_assignment_in_tbl(i).attribute2, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute3'||p_assignment_in_tbl(i).attribute3, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute4'||p_assignment_in_tbl(i).attribute4, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute5'||p_assignment_in_tbl(i).attribute5, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute6'||p_assignment_in_tbl(i).attribute6, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute7'||p_assignment_in_tbl(i).attribute7, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute8'||p_assignment_in_tbl(i).attribute8, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute9'||p_assignment_in_tbl(i).attribute9, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute10'||p_assignment_in_tbl(i).attribute10, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute11'||p_assignment_in_tbl(i).attribute11, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute12'||p_assignment_in_tbl(i).attribute12, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute13'||p_assignment_in_tbl(i).attribute13, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute14'||p_assignment_in_tbl(i).attribute14, l_log_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute15'||p_assignment_in_tbl(i).attribute15, l_log_level);
                        pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                        i := p_assignment_in_tbl.next(i);
                END LOOP;
        END IF;

        PA_STARTUP.INITIALIZE(
                  p_calling_application                 => l_calling_application
                , p_calling_module                      => l_calling_module
                , p_check_id_flag                       => l_check_id_flag
                , p_check_role_security_flag            => l_check_role_security_flag
                , p_check_resource_security_flag        => l_check_resource_security_flag
                , p_debug_level                         => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of pa_startup.initialize', l_log_level);
        END IF;

        -- Page does not check PRM licensing, but keeping this code so in future if required, can be used
        --l_prm_license_flag  := nvl(FND_PROFILE.VALUE('PA_PRM_LICENSED'),'N');
        --IF l_prm_license_flag <> 'Y' THEN
        --        null;
        --END IF;

        i := p_assignment_in_tbl.first;

        WHILE i IS NOT NULL LOOP
                l_error_flag_local := 'N';
                l_missing_params := null;
                l_asgn_rec := null;
                l_valid_country := 'Y';
       		PA_STAFFED_ASSIGNMENT_PVT.G_AUTO_APPROVE := NULL ;

                l_start_msg_count := FND_MSG_PUB.count_msg;

                l_asgn_rec := p_assignment_in_tbl(i);

                -- Blank Out Parameters if not passed.
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Record#'||i, l_log_level);
                        pa_debug.write(l_module, '-----------------------------', l_log_level);
                        pa_debug.write(l_module, 'NullOut parameters which are not required.', l_log_level);
                END IF;

                  /*--Bug 6511907 PJR Date Validation Enhancement ----- Start--*/
                        /*-- Validating Resource Req Start and End Date against
                             Project Start and Completion dates --*/

                        Declare
                          l_validate           VARCHAR2(10);
                          l_start_date_status  VARCHAR2(10);
                          l_end_date_status    VARCHAR2(10);
                          l_start_date         DATE;
                          l_end_date           DATE;
                        Begin
                         If l_asgn_rec.start_date is not null or l_asgn_rec.end_date is not null then
                           l_start_date := l_asgn_rec.start_date;
                           l_end_date   := l_asgn_rec.end_date;
                           PA_PROJECT_DATES_UTILS.Validate_Resource_Dates
                                       (l_asgn_rec.project_id, l_start_date, l_end_date,
                                                   l_validate, l_start_date_status, l_end_date_status);

                           If l_validate = 'Y' and l_start_date_status = 'I' Then

                              pa_utils.add_message
                               ( p_app_short_name  => 'PA'
                                ,p_msg_name	       => 'PA_PJR_DATE_START_ERROR'
                                ,p_token1          => 'PROJ_TXN_START_DATE'
                                ,p_value1          => GET_PROJECT_START_DATE(l_asgn_rec.project_id)
                                ,p_token2          => ''
                                ,p_value2          => ''
                                ,p_token3          => ''
                                ,p_value3          => ''
                               );

                              RAISE  FND_API.G_EXC_ERROR;
                           End If;

                           If l_validate = 'Y' and l_end_date_status = 'I' Then

                              pa_utils.add_message
                               ( p_app_short_name  => 'PA'
                                ,p_msg_name	    => 'PA_PJR_DATE_FINISH_ERROR'
                                ,p_token1          => 'PROJ_TXN_END_DATE'
                                ,p_value1          => GET_PROJECT_COMPLETION_DATE(l_asgn_rec.project_id)
                                ,p_token2          => ''
                                ,p_value2          => ''
                                ,p_token3          => ''
                                ,p_value3          => ''
                               );

                              RAISE  FND_API.G_EXC_ERROR;
                           End If;
                         End If;
                        End;

                        /*--Bug 6511907 PJR Date Validation Enhancement ----- End--*/
                IF l_asgn_rec.assignment_id = G_PA_MISS_NUM THEN
                        l_asgn_rec.assignment_id := null;
                END IF;

                IF l_asgn_rec.assignment_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.assignment_name := null;
                END IF;

                IF l_asgn_rec.assignment_type = G_PA_MISS_CHAR THEN
                        l_asgn_rec.assignment_type := null;
                END IF;


                IF l_asgn_rec.project_role_id = G_PA_MISS_NUM THEN
                        l_asgn_rec.project_role_id := null;
                END IF;

                IF l_asgn_rec.project_role_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.project_role_name := null;
                END IF;

                IF l_asgn_rec.project_id = G_PA_MISS_NUM THEN
                        l_asgn_rec.project_id := null;
                END IF;

                IF l_asgn_rec.project_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.project_name := null;
                END IF;

                IF l_asgn_rec.project_number = G_PA_MISS_CHAR THEN
                        l_asgn_rec.project_number := null;
                END IF;

                IF l_asgn_rec.resource_id = G_PA_MISS_NUM THEN
                        l_asgn_rec.resource_id := null;
                END IF;


                -- Some fields like Staffing Owner will be defaulted further in internal APIs
                -- But user may like to pass them explicitely as null
                -- So in that case we need to distinguish MISS NUM with null
                -- But there is a problem that pa_inerface_utils_pub.g_pa_miss_num
                -- is diffrent than fnd_api.g_miss_num. PJR internal code uses
                -- fnd_api.g_miss_num, so it throws the error.
                -- For this reason, we need to convert the G_PA_MISS_NUM/CHAR to FND_API.G_MISS_NUM/CHAR
                -- before sending it to internal APIs

                IF l_asgn_rec.staffing_owner_person_id = G_PA_MISS_NUM THEN
                        -- We can not make null here
                        -- Because underlying API treat null as override and does not
                        -- default value.
                        l_asgn_rec.staffing_owner_person_id := FND_API.G_MISS_NUM;
                END IF;

                IF l_asgn_rec.staffing_priority_code = G_PA_MISS_CHAR THEN
                        l_asgn_rec.staffing_priority_code := null;
                END IF;

                IF l_asgn_rec.staffing_priority_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.staffing_priority_name := null;
                END IF;

                IF l_asgn_rec.project_subteam_id = G_PA_MISS_NUM THEN
                        l_asgn_rec.project_subteam_id := null;
                END IF;

                IF l_asgn_rec.project_subteam_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.project_subteam_name := null;
                END IF;

                -- Location will be default to project location for project requirments
                -- But user may like to pass them explicitely as null
                -- So in that case we need to distinguish MISS CHAR with null
                IF l_asgn_rec.location_id = G_PA_MISS_NUM THEN
                        l_asgn_rec.location_id := FND_API.G_MISS_NUM;
                END IF;

                IF l_asgn_rec.location_country_code = G_PA_MISS_CHAR THEN
                        l_asgn_rec.location_country_code := FND_API.G_MISS_CHAR;
                END IF;

                IF l_asgn_rec.location_country_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.location_country_name := FND_API.G_MISS_CHAR;
                END IF;

                IF l_asgn_rec.location_region = G_PA_MISS_CHAR THEN
                        l_asgn_rec.location_region := FND_API.G_MISS_CHAR;
                END IF;

                IF l_asgn_rec.location_city = G_PA_MISS_CHAR THEN
                        l_asgn_rec.location_city := FND_API.G_MISS_CHAR;
                END IF;


                IF l_asgn_rec.description = G_PA_MISS_CHAR THEN
                        l_asgn_rec.description := null;
                END IF;

                IF l_asgn_rec.additional_information = G_PA_MISS_CHAR THEN
                        l_asgn_rec.additional_information := null;
                END IF;

                IF l_asgn_rec.start_date = G_PA_MISS_DATE THEN
                        l_asgn_rec.start_date := null;
                END IF;

                IF l_asgn_rec.end_date = G_PA_MISS_DATE THEN
                        l_asgn_rec.end_date := null;
                END IF;

                IF l_asgn_rec.status_code = G_PA_MISS_CHAR THEN
                        l_asgn_rec.status_code := null;
                END IF;

                IF l_asgn_rec.status_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.status_name := null;
                END IF;

                IF l_asgn_rec.calendar_type = G_PA_MISS_CHAR THEN
                        l_asgn_rec.calendar_type := 'PROJECT';
                END IF;

                IF l_asgn_rec.calendar_id = G_PA_MISS_NUM THEN
                        l_asgn_rec.calendar_id := null;
                END IF;

                IF l_asgn_rec.calendar_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.calendar_name := null;
                END IF;
                -- 5171889 : Changed = to <>
                --IF l_asgn_rec.resource_calendar_percent = G_PA_MISS_NUM OR l_asgn_rec.calendar_type = 'RESOURCE' THEN
                IF l_asgn_rec.resource_calendar_percent = G_PA_MISS_NUM OR l_asgn_rec.calendar_type <> 'RESOURCE' THEN
                        l_asgn_rec.resource_calendar_percent := null;
                END IF;

                IF l_asgn_rec.expenditure_type_class = G_PA_MISS_CHAR THEN
                        l_asgn_rec.expenditure_type_class := null;
                END IF;

                IF l_asgn_rec.expenditure_type = G_PA_MISS_CHAR THEN
                        l_asgn_rec.expenditure_type := null;
                END IF;

                IF l_asgn_rec.work_type_id = G_PA_MISS_NUM THEN
                        l_asgn_rec.work_type_id := null;
                END IF;

                IF l_asgn_rec.work_type_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.work_type_name := null;
                END IF;

                IF l_asgn_rec.bill_rate_option = G_PA_MISS_CHAR THEN
                        l_asgn_rec.bill_rate_option := 'NONE';
                END IF;

                IF l_asgn_rec.bill_rate_override = G_PA_MISS_NUM THEN
                        l_asgn_rec.bill_rate_override := null;
                END IF;

                IF l_asgn_rec.bill_rate_curr_override = G_PA_MISS_CHAR THEN
                        l_asgn_rec.bill_rate_curr_override := null;
                END IF;

                IF l_asgn_rec.markup_percent_override = G_PA_MISS_NUM THEN
                        l_asgn_rec.markup_percent_override := null;
                END IF;

                IF l_asgn_rec.discount_percentage = G_PA_MISS_NUM THEN
                        l_asgn_rec.discount_percentage := null;
                END IF;

                IF l_asgn_rec.rate_disc_reason_code = G_PA_MISS_CHAR THEN
                        l_asgn_rec.rate_disc_reason_code := null;
                END IF;

                IF l_asgn_rec.tp_rate_option = G_PA_MISS_CHAR THEN
                        l_asgn_rec.tp_rate_option := 'NONE';
                END IF;

                IF l_asgn_rec.tp_rate_override = G_PA_MISS_NUM THEN
                        l_asgn_rec.tp_rate_override := null;
                END IF;

                IF l_asgn_rec.tp_currency_override = G_PA_MISS_CHAR THEN
                        l_asgn_rec.tp_currency_override := null;
                END IF;

                IF l_asgn_rec.tp_calc_base_code_override = G_PA_MISS_CHAR THEN
                        l_asgn_rec.tp_calc_base_code_override := null;
                END IF;

                IF l_asgn_rec.tp_percent_applied_override = G_PA_MISS_NUM THEN
                        l_asgn_rec.tp_percent_applied_override := null;
                END IF;

                IF l_asgn_rec.extension_possible = G_PA_MISS_CHAR THEN
                        l_asgn_rec.extension_possible := null;
                END IF;

                IF l_asgn_rec.expense_owner = G_PA_MISS_CHAR THEN
                        l_asgn_rec.expense_owner := null;
                END IF;

                IF l_asgn_rec.expense_limit = G_PA_MISS_NUM THEN
                        l_asgn_rec.expense_limit := null;
                END IF;

                IF l_asgn_rec.orig_system_code = G_PA_MISS_CHAR THEN
                        l_asgn_rec.orig_system_code := null;
                END IF;

                IF l_asgn_rec.orig_system_reference = G_PA_MISS_CHAR THEN
                        l_asgn_rec.orig_system_reference := null;
                END IF;

                IF l_asgn_rec.record_version_number = G_PA_MISS_NUM THEN
                        l_asgn_rec.record_version_number := 1;
                END IF;

		IF l_asgn_rec.auto_approve = G_PA_MISS_CHAR THEN
                        l_asgn_rec.auto_approve := 'N'; -- If this param is not passed ,take as 'N'
		END IF;

		IF l_asgn_rec.auto_approve = 'Y' THEN
			-- If Auto Approve is True,then pass the status as Confirmed
			-- This is needed for the security check for resource authority
			-- to be done in PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment API (internal)
			-- One more reason is : Only Confirmed Assignments can be approved.

			l_asgn_rec.status_code := '105';
			l_asgn_rec.status_name := 'Confirmed';
		END IF;

		-- Set Global Variable for Auto Approve
		PA_STAFFED_ASSIGNMENT_PVT.G_AUTO_APPROVE := l_asgn_rec.auto_approve ;

                IF l_asgn_rec.attribute_category = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute_category := null;
                END IF;

                IF l_asgn_rec.attribute1 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute1 := null;
                END IF;

                IF l_asgn_rec.attribute2 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute2 := null;
                END IF;

                IF l_asgn_rec.attribute3 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute3 := null;
                END IF;

                IF l_asgn_rec.attribute4 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute4 := null;
                END IF;

                IF l_asgn_rec.attribute5 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute5 := null;
                END IF;

                IF l_asgn_rec.attribute6 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute6 := null;
                END IF;

                IF l_asgn_rec.attribute7 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute7 := null;
                END IF;

                IF l_asgn_rec.attribute8 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute8 := null;
                END IF;

                IF l_asgn_rec.attribute9 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute9 := null;
                END IF;

                IF l_asgn_rec.attribute10 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute10 := null;
                END IF;

                IF l_asgn_rec.attribute11 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute11 := null;
                END IF;

                IF l_asgn_rec.attribute12 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute12 := null;
                END IF;

                IF l_asgn_rec.attribute13 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute13 := null;
                END IF;

                IF l_asgn_rec.attribute14 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute14 := null;
                END IF;

                IF l_asgn_rec.attribute15 = G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute15 := null;
                END IF;


                -- Mandatory Parameters Check
                -----------------------------

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory parameter validation starts', l_log_level);
                END IF;

                IF l_asgn_rec.assignment_type IS NULL OR l_asgn_rec.assignment_type NOT IN ('STAFFED_ASSIGNMENT','STAFFED_ADMIN_ASSIGNMENT') THEN
                        l_missing_params := l_missing_params||', ASSIGNMENT_TYPE';
                END IF;

                IF l_asgn_rec.project_role_id IS NULL AND l_asgn_rec.project_role_name IS NULL THEN
                        l_missing_params := l_missing_params||', PROJECT_ROLE_ID, PROJECT_ROLE_NAME';
                END IF;

                IF l_asgn_rec.project_id IS NULL AND l_asgn_rec.project_name IS NULL AND l_asgn_rec.project_number IS NULL
                THEN
                        l_missing_params := l_missing_params||', PROJECT_ID, PROJECT_NAME, PROJECT_NUMBER';
                END IF;

                IF l_asgn_rec.resource_id IS NULL THEN
                        l_missing_params := l_missing_params||', RESOURCE_ID';
                END IF;


                IF l_asgn_rec.start_date IS NULL OR l_asgn_rec.end_date IS NULL THEN
                        l_missing_params := l_missing_params||', START_DATE, END_DATE';
                END IF;

                -- Assignment status is not mandatory, if not passed we default it to 104 (Provisonal)
                --IF l_asgn_rec.status_code IS NULL AND l_asgn_rec.status_name IS NULL THEN
                --        l_missing_params := l_missing_params||', STATUS_CODE, STATUS_NAME';
                --END IF;
                IF l_asgn_rec.status_code IS NULL AND l_asgn_rec.status_name IS NULL  THEN
                       l_asgn_rec.status_code := 104;
                END IF;

		-- Bug 5175060 If Auto Approval is not there and Yet, Some other status other than
		-- Provisional is passed by user , Throw error.

		-- If Status code is passed,it always takes precedence over name

		IF l_asgn_rec.auto_approve = 'N' THEN

		IF l_asgn_rec.status_code IS NOT NULL THEN
			OPEN c_get_system_status_code(l_asgn_rec.status_code,'STAFFED_ASGMT');
			FETCH c_get_system_status_code INTO l_dummy_sys_code,l_starting_status_flag; -- 5210813
			IF c_get_system_status_code%NOTFOUND THEN -- Not existent value passed
				l_missing_params := l_missing_params||', STATUS_CODE';
			ELSE
				-- If it is confirmed or its not a starting status throw error - 5210813
				IF l_dummy_sys_code = 'STAFFED_ASGMT_CONF' OR l_starting_status_flag ='N'  THEN
					l_missing_params := l_missing_params||', STATUS_CODE';
				END IF;
			END IF;
			CLOSE c_get_system_status_code;
		ELSIF l_asgn_rec.status_name IS NOT NULL THEN
			OPEN c_get_sys_code_from_name(l_asgn_rec.status_name,'STAFFED_ASGMT');
			FETCH c_get_sys_code_from_name INTO l_dummy_sys_code,l_starting_status_flag; -- 5210813
                        IF c_get_sys_code_from_name%NOTFOUND THEN -- Not existent value passed
                                l_missing_params := l_missing_params||', STATUS_NAME';
			ELSE
                                -- If it s confirmed or its not a starting status throw error
                                IF l_dummy_sys_code = 'STAFFED_ASGMT_CONF' OR l_starting_status_flag ='N' THEN
                                        l_missing_params := l_missing_params||', STATUS_NAME';
                                END IF;
                        END IF;
			CLOSE c_get_sys_code_from_name;	-- Correct spelling mistake in cursor name 5200325
		END IF;

		END IF;
		-- End 5175060
                IF l_asgn_rec.location_id IS NULL OR l_asgn_rec.location_id = FND_API.G_MISS_NUM THEN
                        -- If either city or state (or) both are passed ,then country is
                        -- mandatory
                        IF (l_asgn_rec.location_country_code IS NULL AND l_asgn_rec.location_country_name IS NULL)
                           OR (l_asgn_rec.location_country_code =  FND_API.G_MISS_CHAR AND l_asgn_rec.location_country_name = FND_API.G_MISS_CHAR)
                        THEN
                                IF (l_asgn_rec.location_region <> FND_API.G_MISS_CHAR AND l_asgn_rec.location_region IS NOT NULL)
                                    OR (l_asgn_rec.location_city <> FND_API.G_MISS_CHAR AND l_asgn_rec.location_city IS NOT NULL)
                                THEN
                                        l_missing_params := l_missing_params||', LOCATION_COUNTRY_CODE, LOCATION_COUNTRY_NAME';
                                        l_valid_country := 'N';
                                END IF;
                        ELSIF l_asgn_rec.location_country_code IS NOT NULL AND l_asgn_rec.location_country_code <> FND_API.G_MISS_CHAR
                        THEN
                                OPEN c_derive_country_name(l_asgn_rec.location_country_code);
                                FETCH c_derive_country_name INTO l_asgn_rec.location_country_name;
                                IF c_derive_country_name%NOTFOUND THEN
                                        -- Invalid Country code passed.
                                        l_missing_params := l_missing_params||', LOCATION_COUNTRY_CODE';
                                        l_valid_country := 'N';
                                ELSE
                                        l_valid_country := 'Y';
                                END IF;
                                CLOSE c_derive_country_name;
                        ELSIF l_asgn_rec.location_country_name IS NOT NULL AND l_asgn_rec.location_country_name <> FND_API.G_MISS_CHAR
                        THEN
                              OPEN c_derive_country_code(l_asgn_rec.location_country_name);
                              FETCH c_derive_country_code INTO l_asgn_rec.location_country_code;
                              IF c_derive_country_code%NOTFOUND THEN
                                        -- Invalid Country Name passed.
                                        l_missing_params := l_missing_params||', LOCATION_COUNTRY_NAME';
                                        l_valid_country := 'N';
                               ELSE
                                        l_valid_country := 'Y';
                              END IF;
                              CLOSE c_derive_country_code;
                        END IF;

                        -- If the country is valid,then proceed with the state and city validations
                        IF l_valid_country = 'Y' AND l_asgn_rec.location_country_code IS NOT NULL
                        AND l_asgn_rec.location_country_code <> FND_API.G_MISS_CHAR
                        THEN

                                l_dummy_country_code := l_asgn_rec.location_country_code;
                                IF l_asgn_rec.location_region IS NULL OR l_asgn_rec.location_region = FND_API.G_MISS_CHAR THEN
                                        l_dummy_state := null;
                                ELSE
                                        l_dummy_state := l_asgn_rec.location_region;
                                END IF;

                                IF l_asgn_rec.location_city IS NULL OR l_asgn_rec.location_city = FND_API.G_MISS_CHAR THEN
                                        l_dummy_city := null;
                                ELSE
                                        l_dummy_city := l_asgn_rec.location_city;
                                END IF;

                                PA_LOCATION_UTILS.CHECK_LOCATION_EXISTS
                                (
                                         p_country_code         => l_dummy_country_code
                                        ,p_city		        => l_dummy_city
                                        ,p_region	        => l_dummy_state
                                        ,x_location_id	        => l_out_location_id
                                        ,x_return_status        => l_return_status
                                );

                                IF l_out_location_id IS NULL THEN
                                        PA_UTILS.ADD_MESSAGE('PA','PA_AMG_RES_INV_CRC_COMB');
                                        l_error_flag_local := 'Y'; -- 5148975
                                ELSE
                                        l_asgn_rec.location_id := l_out_location_id;
                                END IF;
                        END IF;
                ELSE
                        -- if location id is passed, then it will override the city, region, country code
                        OPEN c_get_location(l_asgn_rec.location_id);
                        FETCH c_get_location INTO l_asgn_rec.location_country_code, l_asgn_rec.location_region, l_asgn_rec.location_city;

                        IF c_get_location%NOTFOUND THEN
                                l_missing_params := l_missing_params||', LOCATION_ID';
                        END IF;
                        CLOSE c_get_location;
                END IF; -- l_asgn_rec.location_id IS NULL OR l_asgn_rec.location_id = FND_API.G_MISS_NUM


                IF l_asgn_rec.calendar_type IS NULL OR (l_asgn_rec.calendar_type NOT IN('PROJECT','OTHER', 'RESOURCE')) THEN
                        l_missing_params := l_missing_params||', CALENDAR_TYPE';
                ELSE
                        IF l_asgn_rec.calendar_type = 'OTHER' AND l_asgn_rec.calendar_id IS NULL
                                AND l_asgn_rec.calendar_name IS NULL
                        THEN
                                l_missing_params := l_missing_params||', CALENDAR_ID, CALENDAR_NAME';
                        END IF;
                        IF l_asgn_rec.calendar_type = 'RESOURCE' AND l_asgn_rec.resource_calendar_percent IS NULL
                        THEN
                                l_missing_params := l_missing_params||', RESOURCE_CALENDAR_PERCENT';
                        END IF;
                END IF;

                IF l_asgn_rec.assignment_type = 'STAFFED_ASSIGNMENT' THEN
                        IF l_asgn_rec.bill_rate_option IS NULL OR l_asgn_rec.bill_rate_option NOT IN('RATE','MARKUP','DISCOUNT','NONE') THEN
                                l_missing_params := l_missing_params||', BILL_RATE_OPTION';
                        ELSE
                                IF l_asgn_rec.bill_rate_option = 'NONE' THEN
                                        l_asgn_rec.bill_rate_override := null;
                                        l_asgn_rec.bill_rate_curr_override := null;
                                        l_asgn_rec.markup_percent_override := null;
                                        l_asgn_rec.discount_percentage := null;
                                        l_asgn_rec.rate_disc_reason_code := null;
                                ELSIF l_asgn_rec.bill_rate_option = 'RATE' THEN
                                        l_asgn_rec.markup_percent_override := null;
                                        l_asgn_rec.discount_percentage := null;
                                        IF l_asgn_rec.bill_rate_override IS NULL THEN
                                                l_missing_params := l_missing_params||', BILL_RATE_OVERRIDE';
                                        END IF;
                                ELSIF l_asgn_rec.bill_rate_option = 'MARKUP' THEN
                                        l_asgn_rec.bill_rate_override := null;
                                        l_asgn_rec.bill_rate_curr_override := null;
                                        l_asgn_rec.discount_percentage := null;
                                        IF l_asgn_rec.markup_percent_override IS NULL THEN
                                                l_missing_params := l_missing_params||', MARKUP_PERCENT_OVERRIDE';
                                        END IF;
                                ELSIF l_asgn_rec.bill_rate_option = 'DISCOUNT' THEN
                                        l_asgn_rec.bill_rate_override := null;
                                        l_asgn_rec.bill_rate_curr_override := null;
                                        l_asgn_rec.markup_percent_override := null;
                                        IF l_asgn_rec.discount_percentage IS NULL THEN
                                                l_missing_params := l_missing_params||', DISCOUNT_PERCENTAGE';
                                        END IF;
                                END IF;
                        END IF;


                        IF l_asgn_rec.tp_rate_option IS NULL OR l_asgn_rec.tp_rate_option NOT IN('RATE','BASIS','NONE') THEN
                                l_missing_params := l_missing_params||', TP_RATE_OPTION';
                        ELSE
                                IF l_asgn_rec.tp_rate_option = 'NONE' THEN
                                        l_asgn_rec.tp_rate_override := null;
                                        l_asgn_rec.tp_currency_override := null;
                                        l_asgn_rec.tp_calc_base_code_override := null;
                                        l_asgn_rec.tp_percent_applied_override := null;
                                ELSIF l_asgn_rec.tp_rate_option = 'RATE' THEN
                                        l_asgn_rec.tp_calc_base_code_override := null;
                                        l_asgn_rec.tp_percent_applied_override := null;
                                        IF l_asgn_rec.tp_rate_override IS NULL OR l_asgn_rec.tp_currency_override IS NULL THEN
                                                l_missing_params := l_missing_params||', TP_RATE_OVERRIDE, TP_CURRENCY_OVERRIDE';
                                        END IF;
                                ELSIF l_asgn_rec.tp_rate_option = 'BASIS' THEN
                                        l_asgn_rec.tp_rate_override := null;
                                        l_asgn_rec.tp_currency_override := null;
                                        IF l_asgn_rec.tp_calc_base_code_override IS NULL OR l_asgn_rec.tp_percent_applied_override IS NULL THEN
                                                l_missing_params := l_missing_params||', TP_CALC_BASE_CODE_OVERRIDE, TP_PERCENT_APPLIED_OVERRIDE';
                                        END IF;
                                END IF;
                        END IF;

                        IF l_asgn_rec.extension_possible IS NOT NULL AND l_asgn_rec.extension_possible NOT IN ('Y','N') THEN
                                l_missing_params := l_missing_params||', EXTENSION_POSSIBLE';
                        END IF;
                END IF; -- l_asgn_rec.assignment_type = 'STAFFED_ASSIGNMENT'

		IF l_asgn_rec.auto_approve NOT IN ('Y','N') THEN
			l_missing_params := l_missing_params||', AUTO_APPROVE' ;
		END IF;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory parameter validation over. List of Missing Parameters='||l_missing_params, l_log_level);
                END IF;

                IF l_missing_params IS NOT NULL THEN
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                        l_error_flag_local := 'Y';
                END IF;

                -- Project Name, Number to ID Conversion
                -- Though it is done by pa_assignmnts_pub.create_assignment
                -- But we require to get project_id so that we can defualt
                -- values from the project and check security on project
                -- Also project name to id conversion does not happen by internal APIs
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Deriving ProjectId', l_log_level);
                END IF;

                IF l_error_flag_local <> 'Y' THEN
                        l_project_id_tmp := l_asgn_rec.project_id;
                        IF l_asgn_rec.project_number IS NOT NULL THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;

                                PA_PROJECT_UTILS2.CHECK_PROJECT_NUMBER_OR_ID(
                                         p_project_id           => l_project_id_tmp
                                        ,p_project_number       => l_asgn_rec.project_number
                                        ,p_check_id_flag        => PA_STARTUP.g_check_id_flag
                                        ,x_project_id           => l_asgn_rec.project_id
                                        ,x_return_status        => l_return_status
                                        ,x_error_message_code   => l_error_message_code );

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;
                        IF l_asgn_rec.project_name IS NOT NULL THEN
                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_error_message_code := null;

                                PA_TASKS_MAINT_UTILS.CHECK_PROJECT_NAME_OR_ID(
                                         p_project_id           => l_project_id_tmp
                                        ,p_project_name         => l_asgn_rec.project_name
                                        ,p_check_id_flag        => PA_STARTUP.g_check_id_flag
                                        ,x_project_id           => l_asgn_rec.project_id
                                        ,x_return_status        => l_return_status
                                        ,x_error_msg_code       => l_error_message_code );

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                        PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;
                END IF; -- l_error_flag_local <> 'Y' AND l_asgn_rec.team_template_id IS NULL

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'ProjectId='||l_asgn_rec.project_id, l_log_level);
                        pa_debug.write(l_module, 'l_error_flag_local='||l_error_flag_local, l_log_level);
                END IF;

                IF l_error_flag_local <> 'Y' THEN
                        -- Project assignment Flow
                        l_role_list_id := null;
                        l_multi_currency_billing_flag := null;
                        l_calendar_id := null;
                        l_work_type_id := null;
                        l_location_id := null;

                        OPEN c_get_project_dtls(l_asgn_rec.project_id);
                        FETCH c_get_project_dtls INTO l_role_list_id, l_multi_currency_billing_flag, l_calendar_id
                                , l_work_type_id, l_location_id;
                        CLOSE c_get_project_dtls;

                        IF l_asgn_rec.bill_rate_option = 'RATE' AND  nvl(l_multi_currency_billing_flag,'N') <> 'Y' THEN
                                l_asgn_rec.bill_rate_curr_override := null;
                        END IF;
                END IF;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Defaults Value from Project', l_log_level);
                        pa_debug.write(l_module, 'l_role_list_id='||l_role_list_id, l_log_level);
                        pa_debug.write(l_module, 'l_multi_currency_billing_flag='||l_multi_currency_billing_flag, l_log_level);
                        pa_debug.write(l_module, 'l_calendar_id='||l_calendar_id, l_log_level);
                        pa_debug.write(l_module, 'l_work_type_id='||l_work_type_id, l_log_level);
                        pa_debug.write(l_module, 'l_location_id='||l_location_id, l_log_level);
                END IF;


                -- Default calendar, location, work type, assignment name
                IF l_error_flag_local <> 'Y' THEN
                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Default values of calendar, work type, location from project or team template', l_log_level);
                        END IF;

                        -- For OTHER type of calendar there is alredy check done above in code
                        -- For PROJECT type ignore the user value and take the project value
                        IF l_asgn_rec.calendar_type = 'PROJECT' THEN
                                l_asgn_rec.calendar_id := l_calendar_id;
                        END IF;

                        IF l_asgn_rec.work_type_id IS NULL AND l_asgn_rec.work_type_name IS NULL
                        THEN
                                l_asgn_rec.work_type_id := l_work_type_id;
                        END IF;

                        IF l_asgn_rec.project_id IS NOT NULL AND l_asgn_rec.location_id = FND_API.G_MISS_NUM
                                AND l_asgn_rec.location_country_code = FND_API.G_MISS_CHAR
                                AND l_asgn_rec.location_country_name = FND_API.G_MISS_CHAR
                                AND l_asgn_rec.location_region = FND_API.G_MISS_CHAR
                                AND l_asgn_rec.location_city = FND_API.G_MISS_CHAR
                        THEN
                                l_asgn_rec.location_id := l_location_id;
                        END IF;

                        -- Role Validation
                        -- Though it is done by pa_assignmnts_pub.create_assignment
                        -- But we require to get role_id so that we can defualt
                        -- values from the role
                        -- Defaulting is required

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Validating Role against Role List and doing Role Name to ID conversion', l_log_level);
                        END IF;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_error_message_code := null;
                        l_project_role_id_tmp := l_asgn_rec.project_role_id;

                       /* passing p_check_id_flag as Y for bug 8557593 */
                         PA_ROLE_UTILS.Check_Role_RoleList (
                                p_role_id               => l_project_role_id_tmp
                                ,p_role_name            => l_asgn_rec.project_role_name
                                ,p_role_list_id         => l_role_list_id
                                ,p_role_list_name       => NULL
                                ,p_check_id_flag        => 'Y'
                                ,x_role_id              => l_asgn_rec.project_role_id
                                ,x_role_list_id         => l_role_list_id
                                ,x_return_status        => l_return_status
                                ,x_error_message_code   => l_error_message_code );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After role validation Role id='||l_asgn_rec.project_role_id, l_log_level);
                                pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                        END IF;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                PA_UTILS.ADD_MESSAGE('PA', l_error_message_code);
                                l_error_flag_local := 'Y';
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Defaulting RequirmentName from Role ', l_log_level);
                        END IF;

                        l_role_name := null;

                        OPEN c_get_role_dtls(l_asgn_rec.project_role_id);
                        FETCH c_get_role_dtls INTO l_role_name;
                        CLOSE c_get_role_dtls;

                        IF l_asgn_rec.assignment_name IS NULL THEN
                                l_asgn_rec.assignment_name := l_role_name;
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'l_role_name='||l_role_name, l_log_level);
                        END IF;
                END IF; -- l_error_flag_local <> 'Y' THEN

                -- All validations are not required as some validation is done in underlying code
                -- Here, we are doing only those validations which are not done internally.
                -- NOTE : In update flow, all these validations are done and it is taken from there
                --        Ideally in create flow also, underlying code should do these validations
                --        But we are doing here to avoid more code changes in existing code.

                IF l_error_flag_local <> 'Y' AND l_asgn_rec.assignment_type = 'STAFFED_ASSIGNMENT' THEN

                        -- Bill Rate Options Validation
                        -------------------------------

                        IF l_asgn_rec.bill_rate_option <> 'NONE' THEN
                                l_rate_discount_reason_flag := 'N';
                                l_br_override_flag := 'N';
                                l_br_discount_override_flag := 'N';

                                OPEN get_bill_rate_override_flags(l_asgn_rec.project_id);
                                FETCH get_bill_rate_override_flags INTO  l_rate_discount_reason_flag, l_br_override_flag, l_br_discount_override_flag;
                                CLOSE get_bill_rate_override_flags;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Bill Rate Options', l_log_level);
                                        pa_debug.write(l_module, 'l_rate_discount_reason_flag='||l_rate_discount_reason_flag, l_log_level);
                                        pa_debug.write(l_module, 'l_br_override_flag='||l_br_override_flag, l_log_level);
                                        pa_debug.write(l_module, 'l_br_discount_override_flag='||l_br_discount_override_flag, l_log_level);
                                END IF;

                                IF l_asgn_rec.bill_rate_option = 'RATE' THEN
                                        IF l_br_override_flag <> 'Y' OR l_asgn_rec.bill_rate_override <= 0 THEN /* OR l_asgn_rec.bill_rate_override > 100  - Removed for Bug 5703021*/
                                                IF l_br_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_BILL_RATE_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_BILL_RATE_OVRD');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                        -- 5144288, 5144369 : Added bill rate currency check below
                                        -- Begin
                                        IF nvl(l_multi_currency_billing_flag,'N') = 'Y' AND l_br_override_flag = 'Y' THEN

                                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                                l_error_message_code := null;
                                                l_bill_currency_override_tmp := l_asgn_rec.bill_rate_curr_override;

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'Validating Bill Rate Currency', l_log_level);
                                                END IF;

                                                PA_PROJECTS_MAINT_UTILS.CHECK_CURRENCY_NAME_OR_CODE(
                                                        p_agreement_currency       => l_bill_currency_override_tmp
                                                        ,p_agreement_currency_name  => null
                                                        ,p_check_id_flag            => 'Y'
                                                        ,x_agreement_currency       => l_asgn_rec.bill_rate_curr_override
                                                        ,x_return_status            => l_return_status
                                                        ,x_error_msg_code           => l_error_message_code);

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'After Bill Rate Currency Validation', l_log_level);
                                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                                END IF;

                                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_CISI_CURRENCY_NULL');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                        -- 5144288, 5144369 : End
                                ELSIF l_asgn_rec.bill_rate_option = 'MARKUP' THEN
					-- 5144675 Changed l_asgn_rec.markup_percent_override <=0 to < 0
                                        IF l_br_override_flag <> 'Y' OR l_asgn_rec.markup_percent_override < 0
					   OR l_asgn_rec.markup_percent_override > 100 THEN
                                                IF l_br_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_BILL_RATE_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_MARKUP_PERCENT');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                ELSIF l_asgn_rec.bill_rate_option = 'DISCOUNT' THEN
					-- 5144675 Changed l_asgn_rec.discount_percentage <= 0 to  < 0
                                        IF l_br_discount_override_flag <> 'Y' OR l_asgn_rec.discount_percentage < 0
					   OR l_asgn_rec.discount_percentage > 100 THEN
                                                IF l_br_discount_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_DISC_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_DISCOUNT_PERCENT');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                END IF;
                                IF l_asgn_rec.rate_disc_reason_code IS NULL THEN
                                        IF (l_rate_discount_reason_flag ='Y' AND (l_br_override_flag ='Y' OR l_br_discount_override_flag='Y') AND
                                                (l_asgn_rec.bill_rate_override IS NOT NULL OR l_asgn_rec.markup_percent_override IS NOT NULL OR l_asgn_rec.discount_percentage IS NOT NULL)
                                           )
                                        THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_RATE_DISC_REASON_REQUIRED');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                ELSE
                                        l_valid_flag := 'N';
                                        OPEN c_get_lookup_exists('RATE AND DISCOUNT REASON', l_asgn_rec.rate_disc_reason_code);
                                        FETCH c_get_lookup_exists INTO l_valid_flag;
                                        CLOSE c_get_lookup_exists;
                                        IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_DISC_RSN_INVALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Validating Bill Rate Options l_error_flag_local='||l_error_flag_local, l_log_level);
                                END IF;
                        END IF; -- l_asgn_rec.bill_rate_option <> 'NONE'

                        -- Transfer Price Rate Options Validation
                        -----------------------------------------

                        IF l_asgn_rec.tp_rate_option <> 'NONE' THEN

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Transfer Price Rate Options', l_log_level);
                                END IF;

                                IF l_asgn_rec.tp_rate_option = 'RATE' THEN
					-- 5144675 Changed l_asgn_rec.tp_rate_override <= to < 0
                                        IF l_asgn_rec.tp_rate_override < 0 OR l_asgn_rec.tp_rate_override > 100 THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_TP_RATE_OVRD');
                                                l_error_flag_local := 'Y';
                                        END IF;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_error_message_code := null;
                                        l_tp_currency_override_tmp := l_asgn_rec.tp_currency_override;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'Validating Transfer Price Rate Currency', l_log_level);
                                        END IF;

                                        PA_PROJECTS_MAINT_UTILS.CHECK_CURRENCY_NAME_OR_CODE(
                                                p_agreement_currency       => l_tp_currency_override_tmp
                                                ,p_agreement_currency_name  => null
                                                ,p_check_id_flag            => 'Y'
                                                ,x_agreement_currency       => l_asgn_rec.tp_currency_override
                                                ,x_return_status            => l_return_status
                                                ,x_error_msg_code           => l_error_message_code);

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'After Transfer Price Rate Currency Validation', l_log_level);
                                                pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                                pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                        END IF;

                                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_CURR_NOT_VALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                ELSIF l_asgn_rec.tp_rate_option = 'BASIS' THEN
					-- 5144675 Changed l_asgn_rec.tp_percent_applied_override <= to < 0
                                        IF l_asgn_rec.tp_percent_applied_override < 0 OR l_asgn_rec.tp_percent_applied_override > 100  THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_APPLY_BASIS_PERCENT');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                        l_valid_flag := 'N';
                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'Validating Transfer Price Rate Basis', l_log_level);
                                        END IF;

                                        OPEN c_get_lookup_exists('CC_MARKUP_BASE_CODE', l_asgn_rec.tp_calc_base_code_override);
                                        FETCH c_get_lookup_exists INTO l_valid_flag;
                                        CLOSE c_get_lookup_exists;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'After Transfer Price Rate Basis Validation', l_log_level);
                                                pa_debug.write(l_module, 'l_valid_flag='||l_valid_flag, l_log_level);
                                        END IF;

                                        IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_TP_BASIS_INVALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Validating Transfer Price Rate Options l_error_flag_local='||l_error_flag_local, l_log_level);
                                END IF;
                        END IF; -- l_asgn_rec.tp_rate_option <> 'NONE'

                        -- Res Loan Agreement Validations
                        ---------------------------------

                        IF l_asgn_rec.expense_owner IS NOT NULL THEN
                                l_valid_flag := 'N';

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Expense Owner Option', l_log_level);
                                END IF;

                                OPEN c_get_lookup_exists('EXPENSE_OWNER_TYPE', l_asgn_rec.expense_owner);
                                FETCH c_get_lookup_exists INTO l_valid_flag;
                                CLOSE c_get_lookup_exists;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Expense Owner Option Validation', l_log_level);
                                        pa_debug.write(l_module, 'l_valid_flag='||l_valid_flag, l_log_level);
                                END IF;

                                IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_EXP_OWNER_INVALID');
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;
                END IF; -- l_error_flag_local <> 'Y' AND l_asgn_rec.assignment_type = 'STAFFED_ASSIGNMENT'

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'After all validations l_error_flag_local='||l_error_flag_local, l_log_level);
                END IF;

                -- Flex field Validation
                ------------------------

                IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        VALIDATE_FLEX_FIELD(
                                  p_desc_flex_name         => 'PA_TEAM_ROLE_DESC_FLEX'
                                , p_attribute_category     => l_asgn_rec.attribute_category
                                , px_attribute1            => l_asgn_rec.attribute1
                                , px_attribute2            => l_asgn_rec.attribute2
                                , px_attribute3            => l_asgn_rec.attribute3
                                , px_attribute4            => l_asgn_rec.attribute4
                                , px_attribute5            => l_asgn_rec.attribute5
                                , px_attribute6            => l_asgn_rec.attribute6
                                , px_attribute7            => l_asgn_rec.attribute7
                                , px_attribute8            => l_asgn_rec.attribute8
                                , px_attribute9            => l_asgn_rec.attribute9
                                , px_attribute10           => l_asgn_rec.attribute10
                                , px_attribute11           => l_asgn_rec.attribute11
                                , px_attribute12           => l_asgn_rec.attribute12
                                , px_attribute13           => l_asgn_rec.attribute13
                                , px_attribute14           => l_asgn_rec.attribute14
                                , px_attribute15           => l_asgn_rec.attribute15
                                , x_return_status          => l_return_status
                                , x_msg_count		   => l_msg_count
                                , x_msg_data		   => l_msg_data
                         );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Flex Field Validation l_return_status='||l_return_status, l_log_level);
                                pa_debug.write(l_module, 'After Flex Field Validation l_msg_data='||l_msg_data, l_log_level);
                        END IF;


                        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS  THEN
                                -- This message does not have toekn defined, still it is ok to pass token as the value
                                -- returned by flex APIs because token are appended as it is
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_DFF_VALIDATION_FAILED',
                                                      'MESSAGE', l_msg_data );
                                l_error_flag_local := 'Y';
                        END IF;
                END IF; -- l_error_flag_local <> 'Y'

                -- Security Check
                -----------------

                IF l_error_flag_local <> 'Y' THEN

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Checking Security for Record#'||i, l_log_level);
                        END IF;


                        IF l_asgn_rec.assignment_type = 'STAFFED_ASSIGNMENT' THEN
                                l_privilege := 'PA_ASN_CR_AND_DL';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_asgn_rec.project_id;
                        ELSIF l_asgn_rec.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN
                                l_privilege := 'PA_ADM_ASN_CR_AND_DL';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_asgn_rec.project_id;
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'l_privilege='||l_privilege, l_log_level);
                                pa_debug.write(l_module, 'l_object_name='||l_object_name, l_log_level);
                                pa_debug.write(l_module, 'l_object_key='||l_object_key, l_log_level);
                        END IF;

                        --If required this may be used to get
                        --l_my_person_id := null;
                        --l_my_resource_id := null;
                        --l_my_resource_name := null;
                        --PA_COMP_PROFILE_PUB.GET_USER_INFO(
                        --    p_user_id         => fnd_global.user_id
                        --  , x_Person_id       => l_my_person_id
                        --  , x_Resource_id     => l_my_resource_id
                        --  , x_resource_name   => l_my_resource_name);
                        --IF l_debug_mode = 'Y' THEN
                        --        pa_debug.write(l_module, 'Logged in user Person Id='||l_my_person_id, l_log_level);
                        --        pa_debug.write(l_module, 'Logged in user Resource Id='||l_my_resource_id, l_log_level);
                        --        pa_debug.write(l_module, 'Logged in user Resource Name='||l_my_resource_name, l_log_level);
                        --END IF;


                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

                        IF l_asgn_rec.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN
                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Resource Authority', l_log_level);
                                END IF;

                                PA_SECURITY_PVT.CHECK_CONFIRM_ASMT
                                        (p_project_id           => l_asgn_rec.project_id
                                        , p_resource_id         => l_asgn_rec.resource_id
                                        , p_resource_name       => null
                                        , p_privilege           => l_privilege
                                        , p_start_date          => l_asgn_rec.start_date
                                        , x_ret_code            => l_ret_code
                                        , x_return_status       => l_return_status
                                        , x_msg_count           => l_msg_count
                                        , x_msg_data            => l_msg_data
                                        );

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Resource Authority Check l_ret_code='||l_ret_code, l_log_level);
                                END IF;
                        ELSE
                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Project Security', l_log_level);
                                END IF;

                                PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                          x_ret_code       => l_ret_code
                                        , x_return_status  => l_return_status
                                        , x_msg_count      => l_msg_count
                                        , x_msg_data       => l_msg_data
                                        , p_init_msg_list   => 'F'
                                        , p_privilege      => l_privilege
                                        , p_object_name    => l_object_name
                                        , p_object_key     => l_object_key);

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Project Security Check l_ret_code='||l_ret_code, l_log_level);
                                END IF;
                        END IF;


                        IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                -- This message does not have token defined, but intentionally putting token
                                -- bcoz we still want to show the privielge name which is missing
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_CR_DL'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                l_error_flag_local := 'Y';
                        END IF;
                END IF;

                -- Call Core Actual API
                -----------------------

                IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling pa_assignments_pub.execute_create_assignment for Record#'||i, l_log_level);
                        END IF;

                        l_new_assignment_id_tbl := null;
                        l_new_assignment_id := null;
                        l_assignment_number := null;
                        l_assignment_row_id := null;
                        l_resource_id := null;

                        PA_ASSIGNMENTS_PUB.EXECUTE_CREATE_ASSIGNMENT
                        (
                                  p_api_version                 => p_api_version_number
                                , p_init_msg_list               => l_init_msg_list
                                , p_commit                      => l_commit
                                , p_validate_only               => l_validate_only
                                , p_asgn_creation_mode		=> l_asgn_creation_mode
                                , p_assignment_name		=> l_asgn_rec.assignment_name
                                , p_assignment_type		=> l_asgn_rec.assignment_type
--                                , p_assignment_template_id      => l_asgn_rec.team_template_id
--                                , p_source_assignment_id        => l_asgn_rec.source_assignment_id
--                                , p_number_of_assignments      => l_asgn_rec.number_of_assignments
                                , p_project_role_id             => l_asgn_rec.project_role_id
                                , p_project_role_name           => l_asgn_rec.project_role_name
                                , p_project_id                  => l_asgn_rec.project_id
                                , p_project_name                => l_asgn_rec.project_name
                                , p_project_number              => l_asgn_rec.project_number
                                , p_resource_id                 => l_asgn_rec.resource_id
                --                , p_project_party_id            =>
                --                , p_resource_name               =>
                --                , p_resource_source_id          => null
                                , p_staffing_owner_person_id    => l_asgn_rec.staffing_owner_person_id
                --                , p_staffing_owner_name         =>
                                , p_staffing_priority_code      => l_asgn_rec.staffing_priority_code
                                , p_staffing_priority_name      => l_asgn_rec.staffing_priority_name
                                , p_project_subteam_id          => l_asgn_rec.project_subteam_id
                                , p_project_subteam_name        => l_asgn_rec.project_subteam_name
                                , p_location_id                 => l_asgn_rec.location_id
                                , p_location_city               => l_asgn_rec.location_city
                                , p_location_region             => l_asgn_rec.location_region
                                , p_location_country_name       => l_asgn_rec.location_country_name
                                , p_location_country_code       => l_asgn_rec.location_country_code
--                                , p_min_resource_job_level      => l_asgn_rec.min_resource_job_level
--                                , p_max_resource_job_level	=> l_asgn_rec.max_resource_job_level
                                , p_description                 => l_asgn_rec.description
                                , p_additional_information      => l_asgn_rec.additional_information
                                , p_start_date                  => l_asgn_rec.start_date
                                , p_end_date                    => l_asgn_rec.end_date
                                , p_status_code                 => l_asgn_rec.status_code
                                , p_project_status_name         => l_asgn_rec.status_name
                		, p_multiple_status_flag        => l_multiple_status_flag
                --                , p_assignment_effort           =>
                --                , p_resource_list_member_id   =>
                --                , p_budget_version_id		=>
                --                , p_sum_tasks_flag            =>
                                , p_calendar_type               => l_asgn_rec.calendar_type
                                , p_calendar_id	                => l_asgn_rec.calendar_id
                                , p_calendar_name               => l_asgn_rec.calendar_name
                                , p_resource_calendar_percent   => l_asgn_rec.resource_calendar_percent
--                                , p_start_adv_action_set_flag   => l_asgn_rec.start_adv_action_set_flag
--                                , p_adv_action_set_id           => l_asgn_rec.adv_action_set_id
--                                , p_adv_action_set_name         => l_asgn_rec.adv_action_set_name
                                -- As of now internal code does not support setting the candidate search options
                                -- at create time. It can only be updated.
--                                , p_comp_match_weighting        => l_asgn_rec.comp_match_weighting
--                                , p_avail_match_weighting       => l_asgn_rec.avail_match_weighting
--                                , p_job_level_match_weighting   => l_asgn_rec.job_level_match_weighting
--                                , p_enable_auto_cand_nom_flag   => l_asgn_rec.enable_auto_cand_nom_flag
--                                , p_search_min_availability     => l_asgn_rec.search_min_availability
--                                , p_search_exp_org_struct_ver_id => l_asgn_rec.search_exp_org_str_ver_id
--                                , p_search_exp_start_org_id     => l_asgn_rec.search_exp_start_org_id
--                                , p_search_country_code         => l_asgn_rec.search_country_code
--                                , p_search_min_candidate_score  => l_asgn_rec.search_min_candidate_score
--                                , p_expenditure_org_id          => l_asgn_rec.expenditure_org_id
--                                , p_expenditure_org_name        => l_asgn_rec.expenditure_org_name
--                                , p_expenditure_organization_id => l_asgn_rec.expenditure_organization_id
--                                , p_exp_organization_name       => l_asgn_rec.expenditure_organization_name
                                , p_expenditure_type_class      => l_asgn_rec.expenditure_type_class
                                , p_expenditure_type            => l_asgn_rec.expenditure_type
--                                , p_fcst_job_group_id           => l_asgn_rec.fcst_job_group_id
--                                , p_fcst_job_group_name         => l_asgn_rec.fcst_job_group_name
--                                , p_fcst_job_id                 => l_asgn_rec.fcst_job_id
--                                , p_fcst_job_name               => l_asgn_rec.fcst_job_name
--                                , p_fcst_tp_amount_type         => l_asgn_rec.fcst_tp_amount_type
                                , p_work_type_id                => l_asgn_rec.work_type_id
                                , p_work_type_name              => l_asgn_rec.work_type_name
                                , p_bill_rate_override          => l_asgn_rec.bill_rate_override
                                , p_bill_rate_curr_override     => l_asgn_rec.bill_rate_curr_override
                                , p_markup_percent_override     => l_asgn_rec.markup_percent_override
                                , p_discount_percentage         => l_asgn_rec.discount_percentage
                                , p_rate_disc_reason_code       => l_asgn_rec.rate_disc_reason_code
                                , p_tp_rate_override            => l_asgn_rec.tp_rate_override
                                , p_tp_currency_override        => l_asgn_rec.tp_currency_override
                                , p_tp_calc_base_code_override  => l_asgn_rec.tp_calc_base_code_override
                                , p_tp_percent_applied_override => l_asgn_rec.tp_percent_applied_override
                                , p_extension_possible          => l_asgn_rec.extension_possible
                                , p_expense_owner               => l_asgn_rec.expense_owner
                                , p_expense_limit               => l_asgn_rec.expense_limit
                --                , p_revenue_currency_code     =>
                --                , p_revenue_bill_rate           =>
                --                , p_markup_percent              =>

                                , p_attribute_category          => l_asgn_rec.attribute_category
                                , p_attribute1                  => l_asgn_rec.attribute1
                                , p_attribute2                  => l_asgn_rec.attribute2
                                , p_attribute3                  => l_asgn_rec.attribute3
                                , p_attribute4                  => l_asgn_rec.attribute4
                                , p_attribute5                  => l_asgn_rec.attribute5
                                , p_attribute6                  => l_asgn_rec.attribute6
                                , p_attribute7                  => l_asgn_rec.attribute7
                                , p_attribute8                  => l_asgn_rec.attribute8
                                , p_attribute9                  => l_asgn_rec.attribute9
                                , p_attribute10                 => l_asgn_rec.attribute10
                                , p_attribute11                 => l_asgn_rec.attribute11
                                , p_attribute12                 => l_asgn_rec.attribute12
                                , p_attribute13                 => l_asgn_rec.attribute13
                                , p_attribute14                 => l_asgn_rec.attribute14
                                , p_attribute15                 => l_asgn_rec.attribute15
                                , x_new_assignment_id_tbl       => l_new_assignment_id_tbl
                                , x_new_assignment_id           => l_new_assignment_id
                                , x_assignment_number           => l_assignment_number
                                , x_assignment_row_id           => l_assignment_row_id
                                , x_resource_id                 => l_resource_id
                                , x_return_status               => l_return_status
                                , x_msg_count                   => l_msg_count
                                , x_msg_data                    => l_msg_data
                        );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After call pa_assignments_pub.execute_create_assignment l_return_status='||l_return_status, l_log_level);
                        END IF;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                l_error_flag_local := 'Y';
                                -- Still we populating out tables so that if calling env tries
                                -- to get all ids even after error has occured
                                x_assignment_id_tbl.extend(1);
                                x_assignment_id_tbl(x_assignment_id_tbl.count):= -1;
                        ELSE
                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Updating Original System Code and Reference', l_log_level);
                                        pa_debug.write(l_module, 'l_new_assignment_id_tbl.count'||l_new_assignment_id_tbl.count, l_log_level);
                                END IF;


                                IF l_new_assignment_id_tbl.count > 0 THEN
                                        FOR j in l_new_assignment_id_tbl.FIRST..l_new_assignment_id_tbl.LAST LOOP
                                                IF l_new_assignment_id_tbl.exists(j) THEN
                                                        x_assignment_id_tbl.extend(1);
                                                        x_assignment_id_tbl(x_assignment_id_tbl.count):= l_new_assignment_id_tbl(j);
                                                        IF (l_asgn_rec.orig_system_code IS NOT NULL OR l_asgn_rec.orig_system_reference IS NOT NULL) THEN
                                                                UPDATE PA_PROJECT_ASSIGNMENTS
                                                                SET orig_system_code = l_asgn_rec.orig_system_code
                                                                , orig_system_reference = l_asgn_rec.orig_system_reference
                                                                WHERE assignment_id = l_new_assignment_id_tbl(j);
                                                        END IF;
                                                END IF;
                                        END LOOP;
                                END IF;
                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Updating Original System Code and Reference', l_log_level);
                                END IF;
                        END IF;
                END IF;

                l_end_msg_count := FND_MSG_PUB.count_msg;
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'l_start_msg_count='||l_start_msg_count, l_log_level);
                        pa_debug.write(l_module, 'l_end_msg_count='||l_end_msg_count, l_log_level);
                END IF;
                l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Repopulating Error Message Stack', l_log_level);
                        END IF;

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;
                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Repopulating Error Message Stack', l_log_level);
                        END IF;
                END IF;
                i := p_assignment_in_tbl.next(i);
        END LOOP;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'All records are done', l_log_level);
                pa_debug.write(l_module, 'l_error_flag='||l_error_flag, l_log_level);
                pa_debug.write(l_module, 'FND_MSG_PUB.count_msg='||FND_MSG_PUB.count_msg, l_log_level);
        END IF;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO CREATE_ASSIGNMENTS_SP;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SQLERRM;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO CREATE_ASSIGNMENTS_SP;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'CREATE_ASSIGNMENTS'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;
END CREATE_ASSIGNMENTS;


-- Start of comments
--      API name        : UPDATE_ASSIGNMENTS
--      Type            : Public
--      Pre-reqs        : None.
--      Function        : This is a public API to update one or more assignments for one or more projects.
--      Usage           : This API will be called from AMG.
--      Parameters      :
--      IN              :       p_commit                IN  VARCHAR2
--                                      Identifier to commit the transaction.
--                                      Valid values are: FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--                              p_init_msg_list         IN  VARCHAR2
--                                      Identifier to initialize the error message stack.
--                                      Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--                              p_api_version_number    IN  NUMBER                      Required
--                                      To be compliant with Applications API coding standards.
--				p_assignment_in_tbl     IN  ASSIGNMENT_IN_TBL_TYPE	Required
--					Table of assignment records. Please see the ASSIGNMENT_IN_TBL_TYPE datatype table
--      OUT             :
--                              x_return_status         OUT VARCHAR2
--                                      Indicates the return status of the API.
--                                      Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--                              x_msg_count             OUT NUMBER
--                                      Indicates the number of error messages in the message stack
--                              x_msg_data              OUT VARCHAR2
--                                      Indicates the error message text if only one error exists
--      History         :
--
--                              01-Mar-2006 - avaithia  - Created
-- End of comments

PROCEDURE UPDATE_ASSIGNMENTS
(
  p_api_version_number          IN              NUMBER   := 1.0
, p_init_msg_list               IN              VARCHAR2 := FND_API.G_TRUE
, p_commit                      IN              VARCHAR2 := FND_API.G_FALSE
, p_assignment_in_tbl           IN              ASSIGNMENT_IN_TBL_TYPE
, x_return_status               OUT     NOCOPY  VARCHAR2
, x_msg_count                   OUT     NOCOPY  NUMBER
, x_msg_data                    OUT     NOCOPY  VARCHAR2
)
IS
l_calling_application           VARCHAR2(10)            := 'PLSQL';
l_calling_module                VARCHAR2(10)            := 'AMG';
l_check_id_flag                 VARCHAR2(1)             := 'Y';
l_check_role_security_flag      VARCHAR2(1)             := 'Y';
l_check_resource_security_flag  VARCHAR2(1)             := 'Y';

l_log_level                     NUMBER                  := 3;
l_module                        VARCHAR2(100)           := 'PA_RES_MANAGEMENT_AMG_PUB.UPDATE_ASSIGNMENTS';
l_commit                        VARCHAR2(1)             := FND_API.G_FALSE;
l_init_msg_list                 VARCHAR2(1)             := FND_API.G_FALSE;
l_validate_only                 VARCHAR2(1)             := FND_API.G_FALSE;
l_asgn_update_mode              VARCHAR2(10)            := 'FULL'; -- This is just a dummy value
l_multiple_status_flag          VARCHAR2(1)             := 'N';

l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_data                          VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);

i                               NUMBER;
l_asgn_rec			ASSIGNMENT_IN_REC_TYPE;

l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
l_error_flag                    VARCHAR2(1)             := 'N';
l_error_flag_local              VARCHAR2(1)             := 'N';

l_loop_msg_count                NUMBER                  :=0;
l_start_msg_count               NUMBER                  :=0;
l_end_msg_count                 NUMBER                  :=0;

l_missing_params                VARCHAR2(1000);
l_privilege                     VARCHAR2(30);
l_object_name                   VARCHAR2(30);
l_object_key                    NUMBER;
l_error_message_code            VARCHAR2(30);
l_ret_code                      VARCHAR2(1);

l_before_api_msg_count          NUMBER;
l_after_api_msg_count           NUMBER;

l_assignment_name		PA_PROJECT_ASSIGNMENTS.ASSIGNMENT_NAME%TYPE;
l_assignment_id			PA_PROJECT_ASSIGNMENTS.ASSIGNMENT_ID%TYPE;
l_record_version_number		PA_PROJECT_ASSIGNMENTS.RECORD_VERSION_NUMBER%TYPE;
l_status_code			PA_PROJECT_ASSIGNMENTS.STATUS_CODE%TYPE;
l_apprvl_status_code		PA_PROJECT_ASSIGNMENTS.APPRVL_STATUS_CODE%TYPE;
l_apprvl_sys_status_code	PA_PROJECT_STATUSES.PROJECT_SYSTEM_STATUS_CODE%TYPE;
l_mass_wf_in_progress_flag	PA_PROJECT_ASSIGNMENTS.MASS_WF_IN_PROGRESS_FLAG%TYPE ;

CURSOR c_sys_status_code(l_in_status_code IN VARCHAR2  ) IS
SELECT project_system_status_code
FROM  pa_project_statuses
WHERE project_status_code = l_in_status_code
AND status_type= 'ASGMT_APPRVL';

CURSOR c_asgn_db_values IS
SELECT * from pa_project_assignments
WHERE assignment_id = l_assignment_id
  AND assignment_type <> 'OPEN_ASSIGNMENT' ;

CURSOR c_get_subteam_party_id(l_in_assignment_id IN NUMBER) IS
SELECT project_subteam_party_id, project_subteam_id
FROM pa_project_subteam_parties
WHERE object_id = l_in_assignment_id
AND object_type = 'PA_PROJECT_ASSIGNMENTS'
AND primary_subteam_flag = 'Y';

CURSOR get_bill_rate_override_flags(c_project_id NUMBER) IS
SELECT impl.rate_discount_reason_flag ,impl.br_override_flag, impl.br_discount_override_flag
FROM pa_implementations_all impl
    , pa_projects_all proj
WHERE proj.org_id=impl.org_id   -- Removed nvl condition from org_id : Post review changes for Bug 5130421
AND proj.project_id = c_project_id ;

CURSOR c_get_lookup_exists(c_lookup_type VARCHAR2, c_lookup_code VARCHAR2) IS
SELECT 'Y'
FROM dual
WHERE EXISTS
(SELECT 'XYZ' FROM pa_lookups WHERE lookup_type = c_lookup_type AND lookup_code = c_lookup_code);

CURSOR c_derive_country_code(c_country_name IN VARCHAR2) IS
SELECT COUNTRY_CODE
FROM PA_COUNTRY_V
WHERE NAME = c_country_name;

CURSOR c_derive_country_name(c_country_code IN VARCHAR2) IS
SELECT NAME
FROM PA_COUNTRY_V
WHERE  COUNTRY_CODE  = c_country_code;

-- 5144288, 5144369 : Added c_get_mcb_flag
CURSOR c_get_mcb_flag(c_project_id NUMBER) IS
SELECT multi_currency_billing_flag
FROM pa_projects_all
WHERE project_id = c_project_id;



l_valid_country		        VARCHAR2(1):='N';
l_dummy_country_code            VARCHAR2(2);
l_dummy_state		        VARCHAR2(240);
l_dummy_city		        VARCHAR2(80);
l_out_location_id	        NUMBER;
l_asgn_db_values_rec	        c_asgn_db_values%ROWTYPE;
l_valid_assignment	        VARCHAR2(1) := 'N';
l_project_subteam_party_id      NUMBER;
l_project_subteam_id            NUMBER;
l_valid_flag                    VARCHAR2(1);
l_rate_discount_reason_flag     VARCHAR2(1);
l_br_override_flag              VARCHAR2(1);
l_br_discount_override_flag     VARCHAR2(1);
l_basic_info_changed		VARCHAR2(1);
l_fin_info_changed              VARCHAR2(1);
l_fin_bill_rate_info_changed    VARCHAR2(1);
l_fin_tp_rate_info_changed      VARCHAR2(1);

l_multi_currency_billing_flag   VARCHAR2(1); -- 5144288, 5144369
l_bill_currency_override_tmp    VARCHAR2(30); -- 5144288, 5144369



BEGIN

        --------------------------------------------------
        -- RESET OUT params
        --------------------------------------------------
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        x_msg_data := NULL ;
        --------------------------------------------------
        -- Initialize Current Function and Msg Stack
        --------------------------------------------------
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'UPDATE_ASSIGNMENTS', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;
        --------------------------------------------------
        -- Create Savepoint
        --------------------------------------------------
        IF p_commit = FND_API.G_TRUE THEN
                savepoint UPDATE_ASSIGNMENTS_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of UPDATE_ASSIGNMENTS', l_log_level);
        END IF;
        --------------------------------------------------
        -- Start Initialize
        --------------------------------------------------
        PA_STARTUP.INITIALIZE(
                  p_calling_application => l_calling_application
                , p_calling_module => l_calling_module
                , p_check_id_flag => l_check_id_flag
                , p_check_role_security_flag => l_check_role_security_flag
                , p_check_resource_security_flag => l_check_resource_security_flag
                , p_debug_level => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of PA_STARTUP.INITIALIZE', l_log_level);
        END IF;
        ----------------------------------------------------
        -- Mandatory param validations and Defaulting Values
        -- Security Check
        -- Core Logic
        ----------------------------------------------------
	i := p_assignment_in_tbl.first ;

	WHILE i IS NOT NULL LOOP

		l_error_flag_local := 'N';
                l_missing_params := null;
		l_asgn_rec := NULL ;
		l_basic_info_changed := 'N';
                l_fin_info_changed := 'N';
                l_fin_bill_rate_info_changed := 'N';
                l_fin_tp_rate_info_changed := 'N';

		l_start_msg_count := FND_MSG_PUB.count_msg;

		l_asgn_rec := p_assignment_in_tbl(i);

         /*--Bug 6511907 PJR Date Validation Enhancement ----- Start--*/
         /*-- Validating Resource Req Start and End Date against
         Project Start and Completion dates --*/

         If l_asgn_rec.start_date is not null or l_asgn_rec.end_date is not null Then
                        Declare
                          l_validate           VARCHAR2(10);
                          l_start_date_status  VARCHAR2(10);
                          l_end_date_status    VARCHAR2(10);
                          l_start_date         DATE;
                          l_end_date           DATE;
                        Begin
                         If l_asgn_rec.start_date is not null or l_asgn_rec.end_date is not null then
                           l_start_date := l_asgn_rec.start_date;
                           l_end_date   := l_asgn_rec.end_date;
                           PA_PROJECT_DATES_UTILS.Validate_Resource_Dates
                                       (l_asgn_rec.project_id, l_start_date, l_end_date,
                                                   l_validate, l_start_date_status, l_end_date_status);

                           If l_validate = 'Y' and l_start_date_status = 'I' Then

                              pa_utils.add_message
                               ( p_app_short_name  => 'PA'
                                ,p_msg_name	       => 'PA_PJR_DATE_START_ERROR'
                                ,p_token1          => 'PROJ_TXN_START_DATE'
                                ,p_value1          => GET_PROJECT_START_DATE(l_asgn_rec.project_id)
                                ,p_token2          => ''
                                ,p_value2          => ''
                                ,p_token3          => ''
                                ,p_value3          => ''
                               );

                              RAISE  FND_API.G_EXC_ERROR;
                           End If;

                           If l_validate = 'Y' and l_end_date_status = 'I' Then

                              pa_utils.add_message
                               ( p_app_short_name  => 'PA'
                                ,p_msg_name	    => 'PA_PJR_DATE_FINISH_ERROR'
                                ,p_token1          => 'PROJ_TXN_END_DATE'
                                ,p_value1          => GET_PROJECT_COMPLETION_DATE(l_asgn_rec.project_id)
                                ,p_token2          => ''
                                ,p_value2          => ''
                                ,p_token3          => ''
                                ,p_value3          => ''
                               );

                              RAISE  FND_API.G_EXC_ERROR;
                           End If;
                         End If;
                        End;

         End if;
         /*--Bug 6511907 PJR Date Validation Enhancement ----- End--*/

		-----------------------------------------------------------------------
		-- Print all the IN params here
		-----------------------------------------------------------------------

		-----------------------------------------------------------------------
		-- Mandatory Parameters Check and Valid Values Checks
		-----------------------------------------------------------------------
		l_asgn_db_values_rec := NULL ;

		l_assignment_id := l_asgn_rec.assignment_id ;

		OPEN c_asgn_db_values ;
		FETCH c_asgn_db_values INTO l_asgn_db_values_rec ;

		IF c_asgn_db_values%NOTFOUND THEN
			l_missing_params := l_missing_params || 'ASSIGNMENT_ID';
		ELSE
			l_valid_assignment := 'Y';
			-- Assignment ID exists
			l_apprvl_sys_status_code := NULL ;
                        OPEN c_sys_status_code(l_asgn_db_values_rec.apprvl_status_code);
                        FETCH c_sys_status_code INTO l_apprvl_sys_status_code;
                        CLOSE c_sys_status_code ;

                        IF l_apprvl_sys_status_code in ('ASGMT_APPRVL_CANCELED','ASGMT_APPRVL_SUBMITTED') THEN
                                l_error_flag_local := 'Y';
                                PA_UTILS.ADD_MESSAGE('PA','PA_AMG_RES_INV_UP_ASG_STATUS') ;-- Need new msg
				-- Discuss with Amit
                        END IF;

                        IF nvl(l_asgn_db_values_rec.mass_wf_in_progress_flag, 'N') = 'Y' THEN
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_ASSIGNMENT_WF');
                                l_error_flag_local := 'Y';
                        END IF;

		END IF;
		CLOSE c_asgn_db_values ;

                IF l_asgn_rec.work_type_id IS NULL AND l_asgn_rec.work_type_name IS NULL THEN
                        l_missing_params := l_missing_params||', WORK_TYPE_ID, WORK_TYPE_NAME';
                END IF;

		IF l_valid_assignment = 'Y' THEN
			IF l_asgn_db_values_rec.project_id IS NOT NULL THEN
				-- Update Project Assignment Flow

				-- Bug 5174557 : Assignment Type Change is not allowed.
				IF l_asgn_rec.assignment_type IS NOT NULL AND
				   l_asgn_rec.assignment_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

					IF l_asgn_rec.assignment_type <> l_asgn_db_values_rec.assignment_type THEN
						l_missing_params := l_missing_params||', ASSIGNMENT_TYPE';
					END IF;
                		END IF;

				IF l_asgn_rec.expenditure_type_class IS NULL THEN
					l_missing_params := l_missing_params||', EXPENDITURE_TYPE_CLASS';
				END IF;

				IF l_asgn_rec.expenditure_type IS NULL THEN
                                        l_missing_params := l_missing_params||', EXPENDITURE_TYPE';
                                END IF;

				IF l_asgn_rec.bill_rate_option IS NULL THEN
                                	l_missing_params := l_missing_params||', BILL_RATE_OPTION';
				ELSIF  l_asgn_rec.bill_rate_option <> G_PA_MISS_CHAR
				   AND l_asgn_rec.bill_rate_option NOT IN('RATE','MARKUP','DISCOUNT','NONE') THEN
                                	l_missing_params := l_missing_params||', BILL_RATE_OPTION';
				ELSIF l_asgn_rec.bill_rate_option = 'NONE' THEN
					l_asgn_rec.bill_rate_override := null;
					l_asgn_rec.bill_rate_curr_override := NULL ;
					l_asgn_rec.markup_percent_override := NULL ;
					l_asgn_rec.discount_percentage := NULL ;
					l_asgn_rec.rate_disc_reason_code := NULL ;
				ELSIF l_asgn_rec.bill_rate_option = 'RATE' THEN
					l_asgn_rec.markup_percent_override := null;
                                	l_asgn_rec.discount_percentage := null;
                                	IF (l_asgn_rec.bill_rate_override IS NULL
					    OR l_asgn_rec.bill_rate_override = G_PA_MISS_NUM)
						AND l_asgn_db_values_rec.bill_rate_override IS NULL
                                	THEN
                                       	     l_missing_params := l_missing_params||', BILL_RATE_OVERRIDE';
                                	END IF;
				ELSIF l_asgn_rec.bill_rate_option ='MARKUP' THEN
					l_asgn_rec.bill_rate_override := null;
                                        l_asgn_rec.bill_rate_curr_override := NULL ;
					l_asgn_rec.discount_percentage := null;
					IF (l_asgn_rec.markup_percent_override IS NULL
					    OR l_asgn_rec.markup_percent_override = G_PA_MISS_NUM)
						AND l_asgn_db_values_rec.markup_percent_override IS NULL
					THEN
						l_missing_params := l_missing_params||', MARKUP_PERCENT_OVERRIDE';
					END IF;
				ELSIF l_asgn_rec.bill_rate_option = 'DISCOUNT' THEN
					l_asgn_rec.bill_rate_override := null;
                                        l_asgn_rec.bill_rate_curr_override := NULL ;
					l_asgn_rec.markup_percent_override := NULL ;
					IF (l_asgn_rec.discount_percentage IS NULL
					    OR l_asgn_rec.discount_percentage = G_PA_MISS_NUM)
                                                AND l_asgn_db_values_rec.discount_percentage IS NULL
					THEN
						l_missing_params := l_missing_params||', DISCOUNT_PERCENTAGE';
					END IF;
				END IF;

				IF l_asgn_rec.tp_rate_option  IS NULL THEN
                                	l_missing_params := l_missing_params||', TP_RATE_OPTION';
                        	ELSIF l_asgn_rec.tp_rate_option <> G_PA_MISS_CHAR
				   AND l_asgn_rec.tp_rate_option NOT IN('RATE','BASIS','NONE') THEN
					l_missing_params := l_missing_params||', TP_RATE_OPTION';
                                ELSIF l_asgn_rec.tp_rate_option = 'NONE' THEN
					l_asgn_rec.tp_rate_override := null;
					l_asgn_rec.tp_currency_override := NULL ;
					l_asgn_rec.tp_calc_base_code_override := NULL ;
                                        l_asgn_rec.tp_percent_applied_override := NULL ;
				ELSIF l_asgn_rec.tp_rate_option = 'RATE' THEN
					l_asgn_rec.tp_calc_base_code_override := NULL ;
                                        l_asgn_rec.tp_percent_applied_override := NULL ;
					IF ((l_asgn_rec.tp_rate_override IS NULL
					     OR l_asgn_rec.tp_rate_override = G_PA_MISS_NUM
					     )
					    AND l_asgn_db_values_rec.tp_rate_override IS NULL
					    )
					    OR
					   ((l_asgn_rec.tp_currency_override IS NULL
					     OR l_asgn_rec.tp_currency_override = G_PA_MISS_CHAR
					     )
                                             AND l_asgn_db_values_rec.tp_currency_override IS NULL
					    )
					THEN
						l_missing_params := l_missing_params||', TP_RATE_OVERRIDE, TP_CURRENCY_OVERRIDE';
					END IF;
				ELSIF l_asgn_rec.tp_rate_option = 'BASIS' THEN
					l_asgn_rec.tp_rate_override := null;
                                        l_asgn_rec.tp_currency_override := NULL ;
					IF ((l_asgn_rec.tp_calc_base_code_override IS NULL
					     OR l_asgn_rec.tp_calc_base_code_override = G_PA_MISS_CHAR
					     )
					    AND l_asgn_db_values_rec.tp_calc_base_code_override IS NULL
					   )
					    OR
					   (( l_asgn_rec.tp_percent_applied_override IS NULL
					      OR l_asgn_rec.tp_percent_applied_override = G_PA_MISS_NUM
					     )
                                             AND l_asgn_db_values_rec.tp_percent_applied_override IS NULL
					   )
					THEN
						l_missing_params := l_missing_params||', TP_CALC_BASE_CODE_OVERRIDE,TP_PERCENT_APPLIED_OVERRIDE' ;
					END IF;
				END IF;

				IF l_asgn_rec.extension_possible <>  G_PA_MISS_CHAR
				   AND l_asgn_rec.extension_possible NOT IN ('Y','N')
				THEN
					l_missing_params := l_missing_params||', EXTENSION_POSSIBLE';
				END IF;

				IF l_asgn_rec.expense_owner  <>  G_PA_MISS_CHAR
				   AND l_asgn_rec.expense_owner NOT IN ('CLIENT','PROJECT_ORG','RESOURCE_ORG')
				THEN
					l_missing_params := l_missing_params||', EXPENSE_OWNER';
				END IF;

				-- If either city or state (or) both are passed ,then country is
				-- mandatory
				IF (l_asgn_rec.location_country_code IS NULL AND l_asgn_rec.location_country_name IS NULL)
				   OR
				   (l_asgn_rec.location_country_code =  G_PA_MISS_CHAR
				       AND l_asgn_rec.location_country_code = G_PA_MISS_CHAR
				       AND l_asgn_db_values_rec.location_id IS NULL)
				THEN
					IF (l_asgn_rec.location_region <> G_PA_MISS_CHAR AND
					    l_asgn_rec.location_region IS NOT NULL)
					    OR
					   (l_asgn_rec.location_city <> G_PA_MISS_CHAR AND
					    l_asgn_rec.location_city IS NOT NULL)
					THEN
						-- This means,User is NULLING OUT Country Field
						-- But Passing State (or) City Values.
						-- (OR)
						-- In DB,No Country has been specified yet.
						-- User is not passing Country Value
						-- But user is trying to specify State or City
						-- We should nt allow it
						--PA_UTILS.ADD_MESSAGE('PA','PA_COUNTRY_INVALID');
						l_missing_params := l_missing_params||', LOCATION_COUNTRY_CODE, LOCATION_COUNTRY_NAME';
						l_valid_country := 'N';
					END IF;
				ELSIF l_asgn_rec.location_country_code IS NOT NULL
				      AND l_asgn_rec.location_country_code <> G_PA_MISS_CHAR
				THEN
					OPEN c_derive_country_name(l_asgn_rec.location_country_code);
					FETCH c_derive_country_name INTO l_asgn_rec.location_country_name;
					IF c_derive_country_name%NOTFOUND THEN
						-- Invalid Country code passed.
						l_missing_params := l_missing_params||', LOCATION_COUNTRY_CODE';
						l_valid_country := 'N';
					ELSE
						l_valid_country := 'Y';
					END IF;
					CLOSE c_derive_country_name;
				ELSIF l_asgn_rec.location_country_name IS NOT NULL
				      AND l_asgn_rec.location_country_name <> G_PA_MISS_CHAR
				THEN
				      OPEN c_derive_country_code(l_asgn_rec.location_country_name);
				      FETCH c_derive_country_code INTO l_asgn_rec.location_country_code;
				      IF c_derive_country_code%NOTFOUND THEN
						-- Invalid Country Name passed.
						l_missing_params := l_missing_params||', LOCATION_COUNTRY_NAME';
						l_valid_country := 'N';
					ELSE
						l_valid_country := 'Y';
				      END IF;
				      CLOSE c_derive_country_code;
				END IF;

				-- If the country is valid,then proceed with the state and city validations
				IF (l_valid_country = 'Y') -- This is for user passed values
				   OR
				   (l_asgn_rec.location_country_code = G_PA_MISS_CHAR -- This is for existing DB Value
				    AND l_asgn_rec.location_country_name = G_PA_MISS_CHAR
				    AND l_asgn_db_values_rec.location_id IS NOT NULL)
				THEN
					-- If Existing Location ID exists
					-- Derive DB values for location details
					IF (
					     (l_asgn_rec.location_country_code = G_PA_MISS_CHAR
					     AND  l_asgn_rec.location_country_name = G_PA_MISS_CHAR
					     )
					     OR (l_asgn_rec.location_region = G_PA_MISS_CHAR)
					     OR (l_asgn_rec.location_city = G_PA_MISS_CHAR)
					   )
					   AND ( l_asgn_db_values_rec.location_id IS NOT NULL)
					THEN
						SELECT country_code,region,city
						INTO l_dummy_country_code,l_dummy_state,l_dummy_city
						FROM PA_LOCATIONS
						WHERE location_id = l_asgn_db_values_rec.location_id;
					END IF;

					IF (l_asgn_rec.location_country_code <> G_PA_MISS_CHAR)
					THEN
						l_dummy_country_code := l_asgn_rec.location_country_code;
					END IF;

					IF (l_asgn_rec.location_region <> G_PA_MISS_CHAR)
					THEN
						l_dummy_state := l_asgn_rec.location_region;
					END IF;

					IF (l_asgn_rec.location_city <> G_PA_MISS_CHAR)
					THEN
						l_dummy_city := l_asgn_rec.location_city;
					END IF;

					-- ==== A ==== Added for 5174316 : Start
					l_asgn_rec.location_country_code := l_dummy_country_code ;
					l_asgn_rec.location_region := l_dummy_state ;
					l_asgn_rec.location_city := l_dummy_city ;
					-- ==== A ==== Added for 5174316 : End

					-- If any of values ,not passed, DB Values will be taken
					pa_location_utils.Check_Location_Exists
					(
						 p_country_code => l_dummy_country_code
						,p_city		=> l_dummy_city
						,p_region	=> l_dummy_state
						,x_location_id	=> l_out_location_id
						,x_return_status => l_return_status
					);

					IF l_out_location_id IS NULL THEN
						PA_UTILS.ADD_MESSAGE('PA','PA_AMG_RES_INV_CRC_COMB'); -- New message to say ,Invalid comb
                                                l_error_flag_local := 'Y'; -- 5148975
					END IF;
				END IF;
				--
			END IF; -- Project Flow
		END IF; -- If it is a valid assignment

		IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory parameter validation over.List of Missing Parameters='||l_missing_params, l_log_level);
                END IF;

                IF l_missing_params IS NOT NULL THEN
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                        l_error_flag_local := 'Y';
                END IF;

		-- Take the db values,if param is not passed

		IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Take values from database for those parameters which are not passed.', l_log_level);
                END IF;

		IF l_asgn_rec.assignment_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_asgn_rec.assignment_name := l_asgn_db_values_rec.assignment_name ;
                END IF;

		IF l_asgn_rec.assignment_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.assignment_type := l_asgn_db_values_rec.assignment_type ;
                END IF;

		-- These parameters are Not used for Update Flow:
                -- Internal API requires to pass FND_API miss nums instead of null
                -- if we pass null, they treat it as update and raise error

		l_asgn_rec.project_role_id := FND_API.G_MISS_NUM;

		l_asgn_rec.project_role_name := FND_API.G_MISS_CHAR;

		l_asgn_rec.project_id := l_asgn_db_values_rec.project_id;

		l_asgn_rec.project_name := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ;

		l_asgn_rec.project_number := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ;

		-- Resource ID cant be changed once an assignment is done
		-- Internal API expects it to be passed as Miss NUM
                l_asgn_rec.resource_id := FND_API.G_MISS_NUM ;


		IF l_asgn_rec.staffing_owner_person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.staffing_owner_person_id := l_asgn_db_values_rec.staffing_owner_person_id ;
                END IF;

		IF l_asgn_rec.staffing_priority_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.staffing_priority_code := l_asgn_db_values_rec.staffing_priority_code ;
                END IF;

		IF l_asgn_rec.staffing_priority_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.staffing_priority_name := NULL ;
		END IF;

		l_project_subteam_party_id := null;

                OPEN c_get_subteam_party_id( l_asgn_rec.assignment_id );
                FETCH c_get_subteam_party_id INTO l_project_subteam_party_id, l_project_subteam_id;
                CLOSE c_get_subteam_party_id;

                IF l_asgn_rec.project_subteam_id = G_PA_MISS_NUM THEN
                        -- The reason we need to check name here, because
                        -- If name is passed and id is not. In this case, id
                        -- will default to previous id and new name will be lost
                        IF l_asgn_rec.project_subteam_name = G_PA_MISS_CHAR THEN
                                l_asgn_rec.project_subteam_id := l_project_subteam_id;
                        ELSIF l_asgn_rec.project_subteam_name IS NULL THEN
                                l_asgn_rec.project_subteam_id := null;
                        ELSE
                                l_asgn_rec.project_subteam_id := null;
                        END IF;
                END IF;

                IF l_asgn_rec.project_subteam_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.project_subteam_name := null;
                END IF;

		--IF l_asgn_rec.project_subteam_id IS NULL AND  l_asgn_rec.project_subteam_name IS NULL
		--THEN
		--	l_project_subteam_party_id := NULL;
		--END IF;

                IF l_asgn_rec.location_id = G_PA_MISS_NUM THEN
                        l_asgn_rec.location_id := l_asgn_db_values_rec.location_id;
                END IF;

		/* Commented for Bug 5174316
		   The following logic is wrong.If we dont pass these params ,
		   it should not be NULLED OUT.
		   The logic is already present in location tagged with ==== A ====
                IF l_asgn_rec.location_country_code = G_PA_MISS_CHAR THEN
                        l_asgn_rec.location_country_code := null;
                END IF;

                IF l_asgn_rec.location_country_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.location_country_name := null;
                END IF;

                IF l_asgn_rec.location_region = G_PA_MISS_CHAR THEN
                        l_asgn_rec.location_region := null;
                END IF;

                IF l_asgn_rec.location_city = G_PA_MISS_CHAR THEN
                        l_asgn_rec.location_city := null;
                END IF;
   		*/

		IF l_asgn_rec.description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.description := l_asgn_db_values_rec.description ;
		ELSE
			l_asgn_rec.description := SUBSTRB(l_asgn_rec.description,1,2000);
                END IF;

		IF l_asgn_rec.additional_information = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.additional_information := l_asgn_db_values_rec.additional_information ;
		ELSE
			l_asgn_rec.additional_information := SUBSTRB(l_asgn_rec.additional_information,1,2000) ;
                END IF;

	        -- These parameters are not For Update flow
		l_asgn_rec.start_date := l_asgn_db_values_rec.start_date ;

		l_asgn_rec.end_date := l_asgn_db_values_rec.end_date;

		l_asgn_rec.status_code := l_asgn_db_values_rec.status_code;

		l_asgn_rec.status_name := NULL ;

		l_asgn_rec.calendar_type := NULL;

		l_asgn_rec.calendar_id := l_asgn_db_values_rec.calendar_id;

		l_asgn_rec.calendar_name  := NULL ;

		IF l_asgn_rec.resource_calendar_percent = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.resource_calendar_percent  := l_asgn_db_values_rec.resource_calendar_percent ;
                END IF;

		IF l_asgn_rec.expenditure_type_class = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.expenditure_type_class := l_asgn_db_values_rec.expenditure_type_class ;
                END IF;

		IF l_asgn_rec.expenditure_type  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.expenditure_type := l_asgn_db_values_rec.expenditure_type ;
                END IF;

                IF l_asgn_rec.work_type_id = G_PA_MISS_NUM THEN
                        IF l_asgn_rec.work_type_name = G_PA_MISS_CHAR THEN
                                l_asgn_rec.work_type_id := l_asgn_db_values_rec.work_type_id;
                        ELSIF l_asgn_rec.work_type_name IS NULL THEN
                                l_asgn_rec.work_type_id := null;
                        ELSE
                                l_asgn_rec.work_type_id := null;
                        END IF;
                END IF;

                IF l_asgn_rec.work_type_name = G_PA_MISS_CHAR THEN
                        l_asgn_rec.work_type_name := null;
                END IF;

		IF l_asgn_rec.bill_rate_override = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.bill_rate_override := l_asgn_db_values_rec.bill_rate_override;
		END IF;

		IF l_asgn_rec.bill_rate_curr_override = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.bill_rate_curr_override := l_asgn_db_values_rec.bill_rate_curr_override;
                END IF;

		IF l_asgn_rec.markup_percent_override = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.markup_percent_override := l_asgn_db_values_rec.markup_percent_override;
                END IF;

		IF l_asgn_rec.discount_percentage = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.discount_percentage := l_asgn_db_values_rec.discount_percentage;
                END IF;

		IF l_asgn_rec.rate_disc_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.rate_disc_reason_code := l_asgn_db_values_rec.rate_disc_reason_code;
                END IF;

		IF l_asgn_rec.tp_rate_override = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.tp_rate_override := l_asgn_db_values_rec.tp_rate_override;
                END IF;

		IF l_asgn_rec.tp_currency_override = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.tp_currency_override := l_asgn_db_values_rec.tp_currency_override;
                END IF;

		IF l_asgn_rec.tp_calc_base_code_override = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.tp_calc_base_code_override := l_asgn_db_values_rec.tp_calc_base_code_override;
                END IF;

		IF l_asgn_rec.tp_percent_applied_override = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.tp_percent_applied_override := l_asgn_db_values_rec.tp_percent_applied_override;
                END IF;

		IF l_asgn_rec.extension_possible = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.extension_possible := l_asgn_db_values_rec.extension_possible;
                END IF;

		IF l_asgn_rec.expense_owner = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.expense_owner := l_asgn_db_values_rec.expense_owner;
                END IF;

		IF l_asgn_rec.expense_limit = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.expense_limit := l_asgn_db_values_rec.expense_limit;
                END IF;

		IF l_asgn_rec.orig_system_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.orig_system_code := l_asgn_db_values_rec.orig_system_code;
                END IF;

		IF l_asgn_rec.orig_system_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.orig_system_reference := l_asgn_db_values_rec.orig_system_reference;
                END IF;

		IF l_asgn_rec.record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.record_version_number := l_asgn_db_values_rec.record_version_number;
                END IF;

		IF l_asgn_rec.attribute_category  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute_category := l_asgn_db_values_rec.attribute_category;
                END IF;

		IF l_asgn_rec.attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute1 := l_asgn_db_values_rec.attribute1;
                END IF;

		IF l_asgn_rec.attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute2 := l_asgn_db_values_rec.attribute2;
                END IF;

		IF l_asgn_rec.attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute3 := l_asgn_db_values_rec.attribute3;
                END IF;

		IF l_asgn_rec.attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute4 := l_asgn_db_values_rec.attribute4;
                END IF;

                IF l_asgn_rec.attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute5 := l_asgn_db_values_rec.attribute5;
                END IF;

                IF l_asgn_rec.attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute6 := l_asgn_db_values_rec.attribute6;
                END IF;

                IF l_asgn_rec.attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute7 := l_asgn_db_values_rec.attribute7;
                END IF;

                IF l_asgn_rec.attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute8 := l_asgn_db_values_rec.attribute8;
                END IF;

                IF l_asgn_rec.attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute9 := l_asgn_db_values_rec.attribute9;
                END IF;

		IF l_asgn_rec.attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute10 :=l_asgn_db_values_rec.attribute10;
                END IF;

                IF l_asgn_rec.attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute11 := l_asgn_db_values_rec.attribute11;
                END IF;

                IF l_asgn_rec.attribute12 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute12 :=l_asgn_db_values_rec.attribute12;
                END IF;

                IF l_asgn_rec.attribute13 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute13 :=l_asgn_db_values_rec.attribute13;
                END IF;

                IF l_asgn_rec.attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute14 := l_asgn_db_values_rec.attribute14;
                END IF;

                IF l_asgn_rec.attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.attribute15 :=l_asgn_db_values_rec.attribute15;
                END IF;


                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'After defaulting values ', l_log_level);
                        pa_debug.write(l_module, 'ProjectId is ' || l_asgn_db_values_rec.project_id, l_log_level);
                        pa_debug.write(l_module, 'DB Value of TeamTemplateFlag is ' ||l_asgn_db_values_rec.template_flag, l_log_level);
                        pa_debug.write(l_module, 'l_error_flag_local is '||l_error_flag_local, l_log_level);
                END IF;

		--------------------------------------------------------------------------------------------
		-- Validation Of Param Values continues
		--------------------------------------------------------------------------------------------
                -- All validations are not required as some validation is done in underlying code
                -- Here, we are doing only those validations which are not done internally.

                IF l_error_flag_local <> 'Y' THEN
                        -- Project Assignment Flow

			-------------------------------
			-- Bill Rate Options Validation
                        -------------------------------

                        IF l_asgn_rec.bill_rate_option <> 'NONE' THEN
                                l_rate_discount_reason_flag := 'N';
                                l_br_override_flag := 'N';
                                l_br_discount_override_flag := 'N';

                                OPEN get_bill_rate_override_flags(l_asgn_rec.project_id);
                                FETCH get_bill_rate_override_flags INTO  l_rate_discount_reason_flag, l_br_override_flag, l_br_discount_override_flag;
                                CLOSE get_bill_rate_override_flags;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Bill Rate Options', l_log_level);
                                        pa_debug.write(l_module, 'l_rate_discount_reason_flag is '||l_rate_discount_reason_flag, l_log_level);
                                        pa_debug.write(l_module, 'l_br_override_flag is '||l_br_override_flag, l_log_level);
                                        pa_debug.write(l_module, 'l_br_discount_override_flag is '||l_br_discount_override_flag, l_log_level);
                                END IF;

				IF l_asgn_rec.bill_rate_option = 'RATE' THEN
                                        IF l_br_override_flag <> 'Y' OR l_asgn_rec.bill_rate_override <= 0 THEN /* OR l_asgn_rec.bill_rate_override > 100  - Removed for Bug 5703021*/
                                                IF l_br_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_BILL_RATE_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_BILL_RATE_OVRD');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                        -- 5144288, 5144369 : Begin
                                        l_multi_currency_billing_flag := null;
                                        OPEN c_get_mcb_flag(l_asgn_rec.project_id);
                                        FETCH c_get_mcb_flag INTO l_multi_currency_billing_flag;
                                        CLOSE c_get_mcb_flag;

                                        IF nvl(l_multi_currency_billing_flag,'N') = 'Y' AND l_br_override_flag = 'Y' THEN
                                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                                l_error_message_code := null;
                                                l_bill_currency_override_tmp := l_asgn_rec.bill_rate_curr_override;

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'Validating Bill Rate Currency', l_log_level);
                                                END IF;

                                                PA_PROJECTS_MAINT_UTILS.CHECK_CURRENCY_NAME_OR_CODE(
                                                        p_agreement_currency       => l_bill_currency_override_tmp
                                                        ,p_agreement_currency_name  => null
                                                        ,p_check_id_flag            => 'Y'
                                                        ,x_agreement_currency       => l_asgn_rec.bill_rate_curr_override
                                                        ,x_return_status            => l_return_status
                                                        ,x_error_msg_code           => l_error_message_code);

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'After Bill Rate Currency Validation', l_log_level);
                                                        pa_debug.write(l_module, 'l_return_status='||l_return_status, l_log_level);
                                                        pa_debug.write(l_module, 'l_error_message_code='||l_error_message_code, l_log_level);
                                                END IF;

                                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_CISI_CURRENCY_NULL');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                        -- 5144288, 5144369 : End
                                ELSIF l_asgn_rec.bill_rate_option = 'MARKUP' THEN
					-- 5144675 Changed l_asgn_rec.markup_percent_override <=0 to  < 0
                                        IF l_br_override_flag <> 'Y' OR l_asgn_rec.markup_percent_override < 0
					   OR l_asgn_rec.markup_percent_override > 100 THEN
                                                IF l_br_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_BILL_RATE_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_MARKUP_PERCENT');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                ELSIF l_asgn_rec.bill_rate_option = 'DISCOUNT' THEN
					-- 5144675 Changed l_asgn_rec.discount_percentage <= 0 to < 0
					IF l_br_discount_override_flag <> 'Y' OR l_asgn_rec.discount_percentage < 0
					   OR l_asgn_rec.discount_percentage > 100 THEN
                                                IF l_br_discount_override_flag <> 'Y' THEN
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_DISC_OVRD_NA');
                                                        l_error_flag_local := 'Y';
                                                ELSE
                                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_DISCOUNT_PERCENT');
                                                        l_error_flag_local := 'Y';
                                                END IF;
                                        END IF;
                                END IF;

                                IF l_asgn_rec.rate_disc_reason_code IS NULL THEN
                                        IF (l_rate_discount_reason_flag ='Y' AND (l_br_override_flag ='Y' OR l_br_discount_override_flag='Y') AND
                                                (l_asgn_rec.bill_rate_override IS NOT NULL OR l_asgn_rec.markup_percent_override IS NOT NULL OR l_asgn_rec.discount_percentage IS NOT NULL)
                                           )
                                        THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_RATE_DISC_REASON_REQUIRED');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                ELSE
					l_valid_flag := 'N';
                                        OPEN c_get_lookup_exists('RATE AND DISCOUNT REASON', l_asgn_rec.rate_disc_reason_code);
                                        FETCH c_get_lookup_exists INTO l_valid_flag;
                                        CLOSE c_get_lookup_exists;
                                        IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_DISC_RSN_INVALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Validating Bill Rate Options l_error_flag_local is '||l_error_flag_local, l_log_level);
                                END IF;
                        END IF; -- l_asgn_rec.bill_rate_option <> 'NONE'

			---------------------------------------------
			-- Transfer Price Rate Options Validation
                        ---------------------------------------------

                        IF l_asgn_rec.tp_rate_option <> 'NONE' THEN

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Transfer Price Rate Options', l_log_level);
                                END IF;

                                IF l_asgn_rec.tp_rate_option = 'RATE' THEN
                                        null; -- This validation is done internally
                                ELSIF l_asgn_rec.tp_rate_option = 'BASIS' THEN
                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'Validating Transfer Price Rate Basis', l_log_level);
                                        END IF;

                                        OPEN c_get_lookup_exists('CC_MARKUP_BASE_CODE', l_asgn_rec.tp_calc_base_code_override);
                                        FETCH c_get_lookup_exists INTO l_valid_flag;
                                        CLOSE c_get_lookup_exists;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module, 'After Transfer Price Rate Basis Validation', l_log_level);
                                                pa_debug.write(l_module, 'l_valid_flag='||l_valid_flag, l_log_level);
                                        END IF;

                                        IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_TP_BASIS_INVALID');
                                                l_error_flag_local := 'Y';
                                        END IF;
                                END IF;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Validating Transfer Price Rate Options l_error_flag_local='||l_error_flag_local, l_log_level);
                                END IF;
                        END IF; -- l_asgn_rec.tp_rate_option <> 'NONE'

			---------------------------------------------
			-- Res Loan Agreement Validations
			---------------------------------------------
			IF l_asgn_rec.expense_owner IS NOT NULL THEN
				l_valid_flag := 'N';

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Validating Expense Owner Option', l_log_level);
                                END IF;

                                OPEN c_get_lookup_exists('EXPENSE_OWNER_TYPE', l_asgn_rec.expense_owner);
                                FETCH c_get_lookup_exists INTO l_valid_flag;
                                CLOSE c_get_lookup_exists;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'After Expense Owner Option Validation', l_log_level);
                                        pa_debug.write(l_module, 'l_valid_flag='||l_valid_flag, l_log_level);
                                END IF;

                                IF nvl(l_valid_flag,'N') <> 'Y' THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_EXP_OWNER_INVALID');
                                        l_error_flag_local := 'Y';
                                END IF;
			END IF;
			IF l_debug_mode = 'Y' THEN
	                        pa_debug.write(l_module, 'After all validations except flexfield l_error_flag_local='||l_error_flag_local, l_log_level);
		        END IF;

			-- Flex field Validation
			------------------------

			IF l_error_flag_local <> 'Y' THEN
				l_return_status := FND_API.G_RET_STS_SUCCESS;

				VALIDATE_FLEX_FIELD(
					  p_desc_flex_name         => 'PA_TEAM_ROLE_DESC_FLEX'
					, p_attribute_category     => l_asgn_rec.attribute_category
					, px_attribute1            => l_asgn_rec.attribute1
					, px_attribute2            => l_asgn_rec.attribute2
					, px_attribute3            => l_asgn_rec.attribute3
					, px_attribute4            => l_asgn_rec.attribute4
					, px_attribute5            => l_asgn_rec.attribute5
					, px_attribute6            => l_asgn_rec.attribute6
					, px_attribute7            => l_asgn_rec.attribute7
					, px_attribute8            => l_asgn_rec.attribute8
					, px_attribute9            => l_asgn_rec.attribute9
					, px_attribute10           => l_asgn_rec.attribute10
					, px_attribute11           => l_asgn_rec.attribute11
					, px_attribute12           => l_asgn_rec.attribute12
					, px_attribute13           => l_asgn_rec.attribute13
					, px_attribute14           => l_asgn_rec.attribute14
					, px_attribute15           => l_asgn_rec.attribute15
					, x_return_status          => l_return_status
					, x_msg_count              => l_msg_count
					, x_msg_data               => l_msg_data
				 );

				IF l_debug_mode = 'Y' THEN
					pa_debug.write(l_module, 'After Flex Field Validation l_return_status='||l_return_status, l_log_level);
					pa_debug.write(l_module, 'After Flex Field Validation l_msg_data='||l_msg_data, l_log_level);
				END IF;

				IF l_return_status <>  FND_API.G_RET_STS_SUCCESS  THEN
					-- This message does not have toekn defined, still it is ok to pass token as the value
					-- returned by flex APIs because token are appended as it is
					PA_UTILS.ADD_MESSAGE('PA', 'PA_DFF_VALIDATION_FAILED',
							      'MESSAGE', l_msg_data );
					l_error_flag_local := 'Y';
				END IF;
			END IF;

		END IF; -- End of Param Validations

		-- Security Check
                -----------------
                -- The underlying API does security check of PA_ASN_BASIC_INFO_ED
                -- , PA_CREATE_CANDIDATES, PA_ASN_FCST_INFO_ED
                -- But still we need to do check here because there are some more checks required
                -- Also the underlying API does not consider the MISS chars

		----------- (1)
                IF l_error_flag_local <> 'Y' AND nvl(l_asgn_db_values_rec.template_flag,'N') = 'N' THEN
                        -- Project Assignment
                        IF nvl(l_asgn_rec.assignment_name, 'XYZ') <> nvl(l_asgn_db_values_rec.assignment_name, 'XYZ')
                        OR nvl(l_asgn_rec.staffing_priority_code, 'XYZ') <> nvl(l_asgn_db_values_rec.staffing_priority_code, 'XYZ')
                        OR nvl(l_asgn_rec.staffing_owner_person_id, -1) <> nvl(l_asgn_db_values_rec.staffing_owner_person_id, -1)
                        OR nvl(l_asgn_rec.description, 'XYZ') <> nvl(l_asgn_db_values_rec.description, 'XYZ')
                        OR nvl(l_asgn_rec.additional_information, 'XYZ') <> nvl(l_asgn_db_values_rec.additional_information, 'XYZ')
                        OR nvl(l_asgn_rec.project_subteam_id, -1) <> nvl(l_project_subteam_id, -1)
                        OR nvl(l_asgn_rec.location_id, -1) <> nvl(l_asgn_db_values_rec.location_id, -1)
			OR nvl(l_asgn_rec.attribute_category,'XX') <> nvl(l_asgn_db_values_rec.attribute_category,'XX')
			OR nvl(l_asgn_rec.attribute1,'XX') <> nvl(l_asgn_db_values_rec.attribute1,'XX')
			OR nvl(l_asgn_rec.attribute2,'XX') <> nvl(l_asgn_db_values_rec.attribute2,'XX')
			OR nvl(l_asgn_rec.attribute3,'XX') <> nvl(l_asgn_db_values_rec.attribute3,'XX')
			OR nvl(l_asgn_rec.attribute4,'XX') <> nvl(l_asgn_db_values_rec.attribute4,'XX')
			OR nvl(l_asgn_rec.attribute5,'XX') <> nvl(l_asgn_db_values_rec.attribute5,'XX')
			OR nvl(l_asgn_rec.attribute6,'XX') <> nvl(l_asgn_db_values_rec.attribute6,'XX')
			OR nvl(l_asgn_rec.attribute7,'XX') <> nvl(l_asgn_db_values_rec.attribute7,'XX')
			OR nvl(l_asgn_rec.attribute8,'XX') <> nvl(l_asgn_db_values_rec.attribute8,'XX')
			OR nvl(l_asgn_rec.attribute9,'XX') <> nvl(l_asgn_db_values_rec.attribute9,'XX')
			OR nvl(l_asgn_rec.attribute10,'XX') <> nvl(l_asgn_db_values_rec.attribute10,'XX')
			OR nvl(l_asgn_rec.attribute11,'XX') <> nvl(l_asgn_db_values_rec.attribute11,'XX')
			OR nvl(l_asgn_rec.attribute12,'XX') <> nvl(l_asgn_db_values_rec.attribute12,'XX')
			OR nvl(l_asgn_rec.attribute13,'XX') <> nvl(l_asgn_db_values_rec.attribute13,'XX')
			OR nvl(l_asgn_rec.attribute14,'XX') <> nvl(l_asgn_db_values_rec.attribute14,'XX')
			OR nvl(l_asgn_rec.attribute15,'XX') <> nvl(l_asgn_db_values_rec.attribute15,'XX')
                        THEN
                                l_basic_info_changed := 'Y';
                        END IF;


                        IF nvl(l_asgn_rec.extension_possible, 'XYZ') <> nvl(l_asgn_db_values_rec.extension_possible, 'XYZ')
                        OR nvl(l_asgn_rec.expense_owner, 'XYZ') <> nvl(l_asgn_db_values_rec.expense_owner, 'XYZ')
                        OR nvl(l_asgn_rec.expense_limit, -1) <> nvl(l_asgn_db_values_rec.expense_limit, -1)
                        OR nvl(l_asgn_rec.expenditure_type_class, 'XYZ') <> nvl(l_asgn_db_values_rec.expenditure_type_class, 'XYZ')
                        OR nvl(l_asgn_rec.expenditure_type, 'XYZ') <> nvl(l_asgn_db_values_rec.expenditure_type, 'XYZ')
                        OR nvl(l_asgn_rec.work_type_id, -1) <> nvl(l_asgn_db_values_rec.work_type_id, -1)
                        THEN
                                l_fin_info_changed := 'Y';
                        END IF;

                        IF nvl(l_asgn_rec.bill_rate_override, -1) <> nvl(l_asgn_db_values_rec.bill_rate_override, -1)
                        OR nvl(l_asgn_rec.bill_rate_curr_override, 'XYZ') <> nvl(l_asgn_db_values_rec.bill_rate_curr_override, 'XYZ')
                        OR nvl(l_asgn_rec.markup_percent_override, -1) <> nvl(l_asgn_db_values_rec.markup_percent_override, -1)
                        OR nvl(l_asgn_rec.discount_percentage, -1) <> nvl(l_asgn_db_values_rec.discount_percentage, -1)
                        OR nvl(l_asgn_rec.rate_disc_reason_code, 'XYZ') <> nvl(l_asgn_db_values_rec.rate_disc_reason_code, 'XYZ')
                        THEN
                                l_fin_bill_rate_info_changed := 'Y';
			END IF;

			IF nvl(l_asgn_rec.tp_rate_override, -1) <> nvl(l_asgn_db_values_rec.tp_rate_override, -1)
                        OR nvl(l_asgn_rec.tp_currency_override, 'XYZ') <> nvl(l_asgn_db_values_rec.tp_currency_override, 'XYZ')
                        OR nvl(l_asgn_rec.tp_percent_applied_override, -1) <> nvl(l_asgn_db_values_rec.tp_percent_applied_override, -1)
                        OR nvl(l_asgn_rec.tp_calc_base_code_override, 'XYZ') <> nvl(l_asgn_db_values_rec.tp_calc_base_code_override, 'XYZ')
                        THEN
                                l_fin_tp_rate_info_changed := 'Y';
                        END IF;

                        IF l_basic_info_changed = 'Y' THEN

                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_ret_code := 'T';

				IF l_asgn_db_values_rec.assignment_type = 'STAFFED_ASSIGNMENT' THEN

					l_privilege := 'PA_ASN_BASIC_INFO_ED';
				ELSIF l_asgn_db_values_rec.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN

					l_privilege := 'PA_ADM_ASN_CR_AND_DL';
				END IF;

                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_asgn_rec.project_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Project Level Security for PA_ASN_BASIC_INFO_ED', l_log_level);
                                END IF ;

				l_before_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;
                                PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                          x_ret_code       => l_ret_code
                                        , x_return_status  => l_return_status
                                        , x_msg_count      => l_msg_count
                                        , x_msg_data       => l_msg_data
                                        , p_privilege      => l_privilege
                                        , p_object_name    => l_object_name
                                        , p_object_key     => l_object_key
                                        , p_init_msg_list  => FND_API.G_FALSE);
				l_after_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;

				IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_BASIC_INFO_ED l_ret_code '|| l_ret_code , l_log_level);
                                END IF ;

				IF nvl(l_ret_code, 'F') = 'F' OR (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
					IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Checking Assignment Level Security for PA_ASN_BASIC_INFO_ED', l_log_level);
                                        END IF ;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';

					IF l_asgn_db_values_rec.assignment_type = 'STAFFED_ASSIGNMENT' THEN

						l_privilege := 'PA_ASN_BASIC_INFO_ED';
					ELSIF l_asgn_db_values_rec.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN
						l_privilege := 'PA_ADM_ASN_CR_AND_DL';
					END IF;

                                        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
                                        l_object_key := l_asgn_rec.assignment_id;

					l_before_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;
 					PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                                  x_ret_code       => l_ret_code
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data
                                                , p_privilege      => l_privilege
                                                , p_object_name    => l_object_name
                                                , p_object_key     => l_object_key
                                                , p_init_msg_list  => FND_API.G_FALSE );
					l_after_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;

					IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Assignment Level Security for PA_ASN_BASIC_INFO_ED l_ret_code='||l_ret_code, l_log_level);
                                        END IF ;
                                END IF;

                                IF nvl(l_ret_code,'F') <> 'T' OR (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_UPD_ASGN_BASIC_INFO'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                        l_error_flag_local := 'Y';
                                END IF;
			END IF; -- End If basic info changed

			IF l_fin_info_changed = 'Y' OR l_fin_bill_rate_info_changed = 'Y' OR l_fin_tp_rate_info_changed = 'Y' THEN

                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_ret_code := 'T';
				IF l_asgn_db_values_rec.assignment_type = 'STAFFED_ASSIGNMENT' THEN

					l_privilege := 'PA_ASN_FCST_INFO_ED';
				ELSIF l_asgn_db_values_rec.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN
					l_privilege := 'PA_ADM_ASN_FCST_INFO_ED';
				END IF;

                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_asgn_rec.project_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Project Level Security for PA_ASN_FCST_INFO_ED', l_log_level);
                                END IF ;

				l_before_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;
                                PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                          x_ret_code       => l_ret_code
                                        , x_return_status  => l_return_status
                                        , x_msg_count      => l_msg_count
                                        , x_msg_data       => l_msg_data
                                        , p_privilege      => l_privilege
                                        , p_object_name    => l_object_name
                                        , p_object_key     => l_object_key
                                        , p_init_msg_list  => FND_API.G_FALSE);
				l_after_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_FCST_INFO_ED l_ret_code '|| l_ret_code , l_log_level);
                                END IF ;

				IF nvl(l_ret_code,'F') <> 'T' OR (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Checking Assignment Level Security for PA_CREATE_CANDIDATES', l_log_level);
                                        END IF ;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';
					IF l_asgn_db_values_rec.assignment_type = 'STAFFED_ASSIGNMENT' THEN

						l_privilege := 'PA_ASN_FCST_INFO_ED';
					ELSIF l_asgn_db_values_rec.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN
						l_privilege := 'PA_ADM_ASN_FCST_INFO_ED';
					END IF;

                                        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
                                        l_object_key := l_asgn_rec.assignment_id;

					l_before_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;
                                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                                  x_ret_code       => l_ret_code
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data
                                                , p_privilege      => l_privilege
                                                , p_object_name    => l_object_name
                                                , p_object_key     => l_object_key
                                                , p_init_msg_list  => FND_API.G_FALSE );
					l_after_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;

					IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Requirement Level Security for PA_ASN_FCST_INFO_ED l_ret_code='||l_ret_code, l_log_level);
                                        END IF ;
                                END IF;

				IF nvl(l_ret_code,'F') <> 'T' OR (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_UPD_ASGN_FIN_INFO'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                        l_error_flag_local := 'Y';
                                END IF;

			END IF; -- End If Financial Information changed

			IF l_fin_bill_rate_info_changed = 'Y' THEN

                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_ret_code := 'T';
                                l_privilege := 'PA_ASN_FCST_INFO_BILL_ED';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_asgn_rec.project_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Project Level Security for PA_ASN_FCST_INFO_BILL_ED', l_log_level);
                                END IF ;

				l_before_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;
                                PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                          x_ret_code       => l_ret_code
                                        , x_return_status  => l_return_status
                                        , x_msg_count      => l_msg_count
                                        , x_msg_data       => l_msg_data
                                        , p_privilege      => l_privilege
                                        , p_object_name    => l_object_name
                                        , p_object_key     => l_object_key
                                        , p_init_msg_list  => FND_API.G_FALSE);
				l_after_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_FCST_INFO_BILL_ED l_ret_code '|| l_ret_code , l_log_level);
                                END IF ;

                                IF nvl(l_ret_code, 'F') = 'F' OR (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Checking Assignment Level Security for PA_ASN_FCST_INFO_BILL_ED', l_log_level);
                                        END IF ;

					l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';
                                        l_privilege := 'PA_ASN_FCST_INFO_BILL_ED';
                                        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
                                        l_object_key :=  l_asgn_rec.assignment_id;

					l_before_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;
					PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
						  x_ret_code       => l_ret_code
						, x_return_status  => l_return_status
						, x_msg_count      => l_msg_count
						, x_msg_data       => l_msg_data
						, p_privilege      => l_privilege
						, p_object_name    => l_object_name
						, p_object_key     => l_object_key
						, p_init_msg_list  => FND_API.G_FALSE);
					l_after_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Assignment Level Security for PA_ASN_FCST_INFO_BILL_ED l_ret_code='||l_ret_code, l_log_level);
                                        END IF ;
                                END IF;

				IF nvl(l_ret_code,'F') <> 'T' OR (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_UPD_ASGN_BR_INFO'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                        l_error_flag_local := 'Y';
                                END IF;
			END IF ; -- End If l_fin_bill_rate_info_changed

			IF l_fin_tp_rate_info_changed = 'Y' THEN

                                l_return_status := FND_API.G_RET_STS_SUCCESS;
                                l_ret_code := 'T';
                                l_privilege := 'PA_ASN_FCST_INFO_TP_ED';
                                l_object_name := 'PA_PROJECTS';
                                l_object_key := l_asgn_rec.project_id;

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Checking Project Level Security for PA_ASN_FCST_INFO_TP_ED', l_log_level);
                                END IF ;

				l_before_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;
				PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
					  x_ret_code       => l_ret_code
					, x_return_status  => l_return_status
					, x_msg_count      => l_msg_count
					, x_msg_data       => l_msg_data
					, p_privilege      => l_privilege
					, p_object_name    => l_object_name
					, p_object_key     => l_object_key
					, p_init_msg_list  => FND_API.G_FALSE);
				l_after_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;

				IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Project Level Security for PA_ASN_FCST_INFO_TP_ED l_ret_code '|| l_ret_code , l_log_level);
                                END IF ;

                                IF nvl(l_ret_code, 'F') = 'F' OR (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN

                                        IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Checking Assignment Level Security for PA_ASN_FCST_INFO_TP_ED', l_log_level);
                                        END IF ;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';
                                        l_privilege := 'PA_ASN_FCST_INFO_TP_ED';
                                        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
                                        l_object_key := l_asgn_rec.assignment_id;

					l_before_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;
                                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                                  x_ret_code       => l_ret_code
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data
                                                , p_privilege      => l_privilege
                                                , p_object_name    => l_object_name
                                                , p_object_key     => l_object_key
                                                , p_init_msg_list  => FND_API.G_FALSE );
					l_after_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;

					IF l_debug_mode = 'Y' THEN
                                                pa_debug.write(l_module,'Assignment Level Security for PA_ASN_FCST_INFO_TP_ED l_ret_code='||l_ret_code, l_log_level);
                                                pa_debug.write(l_module,'Assignment Level Security for PA_ASN_FCST_INFO_TP_ED l_return_status='||l_return_status, l_log_level);
                                        END IF ;
                                END IF;

                                IF nvl(l_ret_code,'F') <> 'T' OR (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_UPD_ASGN_TP_INFO'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                        l_error_flag_local := 'Y';
                                END IF;
                        END IF;-- l_fin_tp_rate_info_changed = 'Y'

		END IF; ----------- (1)

		--------------------------------------------------------------------------------------
		-- All Validations and Security checks are over at this point
		-- Call Actual Core API
		--------------------------------------------------------------------------------------
		IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling PA_ASSIGNMENTS_PUB.EXECUTE_UPDATE_ASSIGNMENT for Record No.'||i, l_log_level);
			END IF;

			l_before_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;

			--Before calling API ,Make location_id as NULL
			--If country code is made NULL

			--This consistent with Update_Assignment API code in PARAPUBB.pls
			IF (l_asgn_rec.location_country_code IS NULL
			   AND l_asgn_rec.location_country_name IS NULL)
			THEN
				l_asgn_rec.location_id := NULL ;
			END IF;

			PA_ASSIGNMENTS_PUB.EXECUTE_UPDATE_ASSIGNMENT
			(
			  p_api_version                 => p_api_version_number
			, p_init_msg_list               => l_init_msg_list
			, p_commit                      => l_commit
			, p_validate_only               => l_validate_only
			, p_asgn_update_mode            => l_asgn_update_mode
			, p_assignment_id 		=> l_asgn_rec.assignment_id
			, p_record_version_number	=> l_asgn_rec.record_version_number
			, p_assignment_name		=> l_asgn_rec.assignment_name
			, p_assignment_type		=> l_asgn_rec.assignment_type
			, p_multiple_status_flag	=> l_asgn_db_values_rec.multiple_status_flag
			, p_project_status_name		=> l_asgn_rec.status_name
			, p_status_code			=> l_asgn_rec.status_code
			, p_start_date			=> l_asgn_rec.start_date
			, p_end_date			=> l_asgn_rec.end_date
			, p_staffing_priority_code	=> l_asgn_rec.staffing_priority_code
			, p_project_id			=> l_asgn_rec.project_id
--			, p_assignment_template_id	=> l_asgn_rec.assignment_template_id
			, p_project_role_id		=> l_asgn_rec.project_role_id
			, p_project_subteam_id		=> l_asgn_rec.project_subteam_id
			, p_project_subteam_party_id    => l_project_subteam_party_id
			, p_description			=> l_asgn_rec.description
--			, p_assignment_effort		=> l_asgn_rec.assignment_effort
			, p_extension_possible		=> l_asgn_rec.extension_possible
--			, p_source_assignment_id	=> l_asgn_rec.source_assignment_id
--			, p_min_resource_job_level	=> l_asgn_rec.min_resource_job_level
--			, p_max_resource_job_level	=> l_asgn_rec.max_resource_job_level
--			, p_assignment_number		=> l_asgn_rec.assignment_number --
			, p_additional_information	=> l_asgn_rec.additional_information
			, p_location_id			=> l_asgn_rec.location_id
			, p_work_type_id                => l_asgn_rec.work_type_id
--			 ,p_revenue_currency_code       => l_asgn_rec.revenue_currency_code
--			 ,p_revenue_bill_rate           => l_asgn_rec.revenue_bill_rate
--			 ,p_markup_percent              => l_asgn_rec.markup_percent
			 ,p_expense_owner               => l_asgn_rec.expense_owner
			 ,p_expense_limit               => l_asgn_rec.expense_limit
--			 ,p_expense_limit_currency_code => l_asgn_rec.expense_limit_currency_code
--			 ,p_fcst_tp_amount_type         => l_asgn_rec.fcst_tp_amount_type
--			 ,p_fcst_job_id                 => l_asgn_rec.fcst_job_id
--			 ,p_fcst_job_group_id           => l_asgn_rec.fcst_job_group_id
--			 ,p_expenditure_org_id          => l_asgn_rec.expenditure_org_id
--			 ,p_expenditure_organization_id => l_asgn_rec.expenditure_organization_id
			 ,p_expenditure_type_class      => l_asgn_rec.expenditure_type_class
			 ,p_expenditure_type            => l_asgn_rec.expenditure_type
--			 ,p_project_number              =>
--			 ,p_resource_name               =>
--			 ,p_resource_source_id          =>
			 ,p_resource_id                 => l_asgn_rec.resource_id
			 ,p_project_subteam_name        => l_asgn_rec.project_subteam_name
			 ,p_staffing_priority_name      => l_asgn_rec.staffing_priority_name
--			 ,p_project_role_name           => l_asgn_rec.project_role_name
			 ,p_location_city               => l_asgn_rec.location_city
			 ,p_location_region             => l_asgn_rec.location_region
--			 ,p_location_country_name       => l_asgn_rec.location_country_name
			 ,p_location_country_code       => l_asgn_rec.location_country_code
			 ,p_calendar_name               => l_asgn_rec.calendar_name
			 ,p_calendar_id                 => l_asgn_rec.calendar_id
			 ,p_work_type_name              => l_asgn_rec.work_type_name
--			 ,p_fcst_job_name               =>
--			 ,p_fcst_job_group_name
--			 ,p_expenditure_org_name
--			 ,p_exp_organization_name
--			 ,p_comp_match_weighting
--			 ,p_avail_match_weighting
--			 ,p_job_level_match_weighting
--			 ,p_search_min_availability
--			 ,p_search_country_code
--			 ,p_search_country_name
--			 ,p_search_exp_org_struct_ver_id
--			 ,p_search_exp_org_hier_name
--			 ,p_search_exp_start_org_id
--			 ,p_search_exp_start_org_name
--			 ,p_search_min_candidate_score
--			 ,p_enable_auto_cand_nom_flag
			 ,p_bill_rate_override          => l_asgn_rec.bill_rate_override
			 ,p_bill_rate_curr_override     => l_asgn_rec.bill_rate_curr_override
			 ,p_markup_percent_override     => l_asgn_rec.markup_percent_override
			 ,p_discount_percentage         => l_asgn_rec.discount_percentage
			 ,p_rate_disc_reason_code       => l_asgn_rec.rate_disc_reason_code
			 ,p_tp_rate_override            => l_asgn_rec.tp_rate_override
			 ,p_tp_currency_override        => l_asgn_rec.tp_currency_override
			 ,p_tp_calc_base_code_override  => l_asgn_rec.tp_calc_base_code_override
			 ,p_tp_percent_applied_override => l_asgn_rec.tp_percent_applied_override
			 ,p_staffing_owner_person_id    => l_asgn_rec.staffing_owner_person_id
--			 ,p_staffing_owner_name         =>
--			 ,p_resource_list_member_id
			 ,p_attribute_category          => l_asgn_rec.attribute_category
			 ,p_attribute1                  => l_asgn_rec.attribute1
			 ,p_attribute2                  => l_asgn_rec.attribute2
			 ,p_attribute3                  => l_asgn_rec.attribute3
			 ,p_attribute4                  => l_asgn_rec.attribute4
			 ,p_attribute5                  => l_asgn_rec.attribute5
			 ,p_attribute6                  => l_asgn_rec.attribute6
			 ,p_attribute7                  => l_asgn_rec.attribute7
			 ,p_attribute8                  => l_asgn_rec.attribute8
			 ,p_attribute9                  => l_asgn_rec.attribute9
			 ,p_attribute10                 => l_asgn_rec.attribute10
			 ,p_attribute11                 => l_asgn_rec.attribute11
			 ,p_attribute12                 => l_asgn_rec.attribute12
			 ,p_attribute13                 => l_asgn_rec.attribute13
			 ,p_attribute14                 => l_asgn_rec.attribute14
			 ,p_attribute15                 => l_asgn_rec.attribute15
			 ,x_return_status               => l_return_status
			 ,x_msg_count                   => l_msg_count
			 ,x_msg_data                    => l_msg_data
			);
			l_after_api_msg_count :=  FND_MSG_PUB.COUNT_MSG;

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'After call PA_ASSIGNMENTS_PUB.EXECUTE_UPDATE_ASSIGNMENT l_return_status='||l_return_status, l_log_level);
			END IF;

			IF (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
				--l_error_flag := 'Y';
				l_error_flag_local := 'Y';
			ELSE
				IF l_debug_mode = 'Y' THEN
					pa_debug.write(l_module, 'Updating Original System Code and Reference', l_log_level);
				END IF;

				--IF l_asgn_rec.orig_system_code IS NOT NULL OR l_asgn_rec.orig_system_reference IS NOT NULL THEN
				--	UPDATE PA_PROJECT_ASSIGNMENTS
				--	SET orig_system_code = decode(l_asgn_rec.orig_system_code, null, orig_system_code, l_asgn_rec.orig_system_code)
				--	, orig_system_reference = decode(l_asgn_rec.orig_system_reference, null, orig_system_reference, l_asgn_rec.orig_system_reference)
				--	WHERE assignment_id = l_asgn_rec.assignment_id;
				--END IF;

				UPDATE PA_PROJECT_ASSIGNMENTS
				SET	orig_system_code = l_asgn_rec.orig_system_code
				,	orig_system_reference = l_asgn_rec.orig_system_reference
				WHERE	assignment_id = l_asgn_rec.assignment_id;

				IF l_debug_mode = 'Y' THEN
					pa_debug.write(l_module, 'After Updating Original System Code and Reference', l_log_level);
				END IF;
			END IF;
		END IF;

                l_end_msg_count := FND_MSG_PUB.count_msg;
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'l_start_msg_count='||l_start_msg_count, l_log_level);
                        pa_debug.write(l_module, 'l_end_msg_count='||l_end_msg_count, l_log_level);
                END IF;
                l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Repopulating Error Message Stack', l_log_level);
                        END IF;

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;
                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Repopulating Error Message Stack', l_log_level);
                        END IF;
                END IF;

	i := p_assignment_in_tbl.next(i);

	END LOOP ;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_ASSIGNMENTS_SP;
	END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTRB(SQLERRM,1,240);

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_ASSIGNMENTS_SP;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'UPDATE_ASSIGNMENTS'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;

END UPDATE_ASSIGNMENTS ;
-- Start of comments
--	API name 	: DELETE_ASSIGNMENTS
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to deletes one or more assignments for one or more projects.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are: FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_assignment_in_tbl	IN  ASSIGNMENT_IN_TBL_TYPE	Required
--					Table of assignment records.
--
--					Please see the ASSIGNMENT_IN_TBL_TYPE datatype table.
--	OUT		:	x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - vkadimes  - Created
-- End of comments
PROCEDURE DELETE_ASSIGNMENTS (
  p_commit                IN      VARCHAR2                :=      'F'
, p_init_msg_list         IN      VARCHAR2                :=      'T'
, p_api_version_number    IN      NUMBER                  :=      1.0
, p_assignment_in_tbl     IN      ASSIGNMENT_IN_TBL_TYPE
, x_return_status         OUT NOCOPY   VARCHAR2
, x_msg_count             OUT NOCOPY   NUMBER
, x_msg_data              OUT NOCOPY   VARCHAR2
) IS
-- Debug Params
l_debug_level           NUMBER          :=3;
l_debug_mode            VARCHAR2(1)     :='N';
l_module                VARCHAR2(255)   := 'PA_RES_MANAGEMENT_AMG_PUB.DELETE_ASSIGNMENTS';
--Looping Params
i                       NUMBER;
-- pa_initialize calling  params
l_calling_application           VARCHAR2(10)            := 'PLSQL';
l_calling_module                VARCHAR2(10)            := 'AMG';
l_check_id_flag                 VARCHAR2(1)             := 'Y';
l_check_role_security_flag      VARCHAR2(1)             := 'Y';
l_check_resource_security_flag  VARCHAR2(1)             := 'Y';
--Loop Params
l_req_rec                       PA_RES_MANAGEMENT_AMG_PUB.ASSIGNMENT_IN_REC_TYPE;
l_loop_msg_count                NUMBER                  :=0;
l_start_msg_count               NUMBER                  :=0;
l_end_msg_count                 NUMBER                  :=0;
l_missing_params                VARCHAR2(1000);
l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
l_ret_code                      VARCHAR2(1);
-- Error Flags
l_error_flag                    VARCHAR2(1)             := 'N';
l_error_flag_local              VARCHAR2(1)             := 'N';

l_assignment_type               VARCHAR2(30);
l_status_code                   VARCHAR2(30);
l_project_id                    NUMBER;
l_assignment_template_id        NUMBER;
l_system_status_code            VARCHAR2(30);
l_assignment_row_id             ROWID;
l_record_version_number         NUMBER;
-- security check
l_privilege                     VARCHAR2(30);
l_object_name                   VARCHAR2(30);
l_object_key                    NUMBER;
l_error_message_code            VARCHAR2(30);
l_assignment_number             NUMBER;
-- Temp prams
l_commit                        VARCHAR2(1)             := FND_API.G_FALSE;
l_init_msg_list                 VARCHAR2(1)             := FND_API.G_FALSE;
l_validate_only                 VARCHAR2(1)             := FND_API.G_FALSE;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_assignment_id                 NUMBER;
l_data                          VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_resource_id                   NUMBER;
l_start_date                    DATE ;
l_mass_wf_in_progress_flag      VARCHAR2(1);
l_apprvl_status_code		VARCHAR2(30);
l_apprvl_sys_status_code	VARCHAR2(30);

CURSOR CUR_ASSIGNMENT_DETAILS(l_assignment_id NUMBER ) IS
SELECT ROWID , assignment_type, status_code, project_id, record_version_number, assignment_number,
resource_id, start_date, mass_wf_in_progress_flag, apprvl_status_code
FROM  pa_project_assignments
WHERE assignment_id=l_assignment_id
AND   assignment_type <> 'OPEN_ASSIGNMENT' ;

CURSOR cur_get_system_status(l_status_code VARCHAR2 ) IS
SELECT PROJECT_SYSTEM_STATUS_CODE
FROM   pa_project_statuses
WHERE  project_status_code = l_status_code ;

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'DELETE_ASSIGNMENTS', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint DELETE_ASSIGNMENTS_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of delete_assignments', l_debug_level);
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Printing Input Parameters......', l_debug_level);
                i := p_assignment_in_tbl.first;
                WHILE i IS NOT NULL LOOP
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').assignment_id'||p_assignment_in_tbl(i).assignment_id, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').assignment_name'||p_assignment_in_tbl(i).assignment_name, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').assignment_type'||p_assignment_in_tbl(i).assignment_type, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_role_id'||p_assignment_in_tbl(i).project_role_id, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_role_name'||p_assignment_in_tbl(i).project_role_name, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_id'||p_assignment_in_tbl(i).project_id, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_name'||p_assignment_in_tbl(i).project_name, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_number'||p_assignment_in_tbl(i).project_number, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').resource_id'||p_assignment_in_tbl(i).resource_id, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').staffing_owner_person_id'||p_assignment_in_tbl(i).staffing_owner_person_id, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').staffing_priority_code'||p_assignment_in_tbl(i).staffing_priority_code, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').staffing_priority_name'||p_assignment_in_tbl(i).staffing_priority_name, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_subteam_id'||p_assignment_in_tbl(i).project_subteam_id, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').project_subteam_name'||p_assignment_in_tbl(i).project_subteam_name, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').location_id'||p_assignment_in_tbl(i).location_id, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').location_country_code'||p_assignment_in_tbl(i).location_country_code, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').location_country_name'||p_assignment_in_tbl(i).location_country_name, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').location_region'||p_assignment_in_tbl(i).location_region, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').location_city'||p_assignment_in_tbl(i).location_city, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').description'||p_assignment_in_tbl(i).description, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').additional_information'||p_assignment_in_tbl(i).additional_information, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').start_date'||p_assignment_in_tbl(i).start_date, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').end_date'||p_assignment_in_tbl(i).end_date, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').status_code'||p_assignment_in_tbl(i).status_code, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').status_name'||p_assignment_in_tbl(i).status_name, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').calendar_type'||p_assignment_in_tbl(i).calendar_type, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').calendar_id'||p_assignment_in_tbl(i).calendar_id, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').calendar_name'||p_assignment_in_tbl(i).calendar_name, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').resource_calendar_percent'||p_assignment_in_tbl(i).resource_calendar_percent, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').expenditure_type_class'||p_assignment_in_tbl(i).expenditure_type_class, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').expenditure_type'||p_assignment_in_tbl(i).expenditure_type, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').work_type_id'||p_assignment_in_tbl(i).work_type_id, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').work_type_name'||p_assignment_in_tbl(i).work_type_name, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').bill_rate_option'||p_assignment_in_tbl(i).bill_rate_option, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').bill_rate_override'||p_assignment_in_tbl(i).bill_rate_override, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').bill_rate_curr_override'||p_assignment_in_tbl(i).bill_rate_curr_override, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').markup_percent_override'||p_assignment_in_tbl(i).markup_percent_override, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').discount_percentage'||p_assignment_in_tbl(i).discount_percentage, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').rate_disc_reason_code'||p_assignment_in_tbl(i).rate_disc_reason_code, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').tp_rate_option'||p_assignment_in_tbl(i).tp_rate_option, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').tp_rate_override'||p_assignment_in_tbl(i).tp_rate_override, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').tp_currency_override'||p_assignment_in_tbl(i).tp_currency_override, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').tp_calc_base_code_override'||p_assignment_in_tbl(i).tp_calc_base_code_override, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').tp_percent_applied_override'||p_assignment_in_tbl(i).tp_percent_applied_override, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').extension_possible'||p_assignment_in_tbl(i).extension_possible, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').expense_owner'||p_assignment_in_tbl(i).expense_owner, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').expense_limit'||p_assignment_in_tbl(i).expense_limit, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').orig_system_code'||p_assignment_in_tbl(i).orig_system_code, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').orig_system_reference'||p_assignment_in_tbl(i).orig_system_reference, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').record_version_number'||p_assignment_in_tbl(i).record_version_number, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute_category'||p_assignment_in_tbl(i).attribute_category, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute1'||p_assignment_in_tbl(i).attribute1, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute2'||p_assignment_in_tbl(i).attribute2, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute3'||p_assignment_in_tbl(i).attribute3, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute4'||p_assignment_in_tbl(i).attribute4, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute5'||p_assignment_in_tbl(i).attribute5, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute6'||p_assignment_in_tbl(i).attribute6, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute7'||p_assignment_in_tbl(i).attribute7, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute8'||p_assignment_in_tbl(i).attribute8, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute9'||p_assignment_in_tbl(i).attribute9, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute10'||p_assignment_in_tbl(i).attribute10, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute11'||p_assignment_in_tbl(i).attribute11, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute12'||p_assignment_in_tbl(i).attribute12, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute13'||p_assignment_in_tbl(i).attribute13, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute14'||p_assignment_in_tbl(i).attribute14, l_debug_level);
                        pa_debug.write(l_module, 'p_assignment_in_tbl('||i||').attribute15'||p_assignment_in_tbl(i).attribute15, l_debug_level);
                        pa_debug.write(l_module, '------------------------------------------------------------------', l_debug_level);
                        i := p_assignment_in_tbl.next(i);
                END LOOP;
        END IF;

        PA_STARTUP.INITIALIZE(
                  p_calling_application                 => l_calling_application
                , p_calling_module                      => l_calling_module
                , p_check_id_flag                       => l_check_id_flag
                , p_check_role_security_flag            => l_check_role_security_flag
                , p_check_resource_security_flag        => l_check_resource_security_flag
                , p_debug_level                         => l_debug_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of pa_startup.initialize', l_debug_level);
        END IF;

        i := p_assignment_in_tbl.first;

        WHILE i IS NOT NULL LOOP

                l_error_flag_local := 'N';
                l_missing_params := null;
                l_req_rec := null;

                l_start_msg_count := FND_MSG_PUB.count_msg;

                l_req_rec := p_assignment_in_tbl(i);

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Record#'||i, l_debug_level);
                        pa_debug.write(l_module, '-----------------------------', l_debug_level);
                        pa_debug.write(l_module, 'NullOut parameters which are not required.', l_debug_level);
                END IF;

                -- Blank Out Required Parameters if not passed.
                IF l_req_rec.assignment_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_req_rec.assignment_id := NULL  ;
                END IF;

                IF l_req_rec.record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_req_rec.record_version_number := NULL ;
                END IF;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Requirement_id is ' || l_req_rec.assignment_id,l_debug_level);
                        pa_debug.write(l_module, 'Record Version Number is ' || l_req_rec.record_version_number, l_debug_level);
                END IF;

                -- Mandatory Parameters Check
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory Parameter Validation Starts', l_debug_level);
                END IF;

                IF l_req_rec.assignment_id IS NULL THEN
                        l_missing_params := l_missing_params ||',ASSIGNMENT_ID';
                END IF;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory Parameter Validation Over. ',l_debug_level);
                        pa_debug.write(l_module, 'The missing parameters are '||l_missing_params, l_debug_level);
                END IF;

                IF l_missing_params IS NOT NULL THEN
                        l_error_flag_local := 'Y';
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                END IF;

                l_assignment_id := l_req_rec.assignment_id;
		IF l_error_flag_local <> 'Y' THEN

			OPEN CUR_ASSIGNMENT_DETAILS(l_assignment_id) ;
			FETCH CUR_ASSIGNMENT_DETAILS INTO l_assignment_row_id, l_assignment_type, l_status_code, l_project_id,l_record_version_number, l_assignment_number, l_resource_id, l_start_date,l_mass_wf_in_progress_flag, l_apprvl_status_code;

			IF CUR_ASSIGNMENT_DETAILS%NOTFOUND THEN
				l_error_flag_local := 'Y';
				PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
							'INVALID_PARAMS', 'ASSIGNMENT_ID');
			END IF;

			CLOSE CUR_ASSIGNMENT_DETAILS;

		END IF ;

                IF l_error_flag_local <> 'Y' THEN
                        l_system_status_code := null;
                        OPEN cur_get_system_status(l_status_code);
                        FETCH cur_get_system_status INTO l_system_status_code ;
                        CLOSE cur_get_system_status;

			OPEN cur_get_system_status(l_apprvl_status_code);
			FETCH cur_get_system_status INTO l_apprvl_sys_status_code;
			CLOSE cur_get_system_status;
                END IF;

                IF l_system_status_code  = 'STAFFED_ASGMT_CANCEL'
		OR l_apprvl_sys_status_code IN ('ASGMT_APPRVL_SUBMITTED','ASGMT_APPRVL_CANCELED')
		OR NVL(l_mass_wf_in_progress_flag,'N') = 'Y' THEN
		--- Need more specific Generic Message.
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_STS_ACT_NOT_ALLW');
                        l_error_flag_local := 'Y';
                END IF;

                IF l_error_flag_local <> 'Y' THEN

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Security check starts', l_debug_level);
                        END IF;

                        IF l_project_id IS NOT NULL THEN
                                IF l_assignment_type = 'STAFFED_ASSIGNMENT' THEN

                                        l_privilege := 'PA_ASN_CR_AND_DL';
                                        l_object_name := 'PA_PROJECTS';
                                        l_object_key := l_project_id ;

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';

                                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                                  x_ret_code       => l_ret_code
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data
                                                , p_privilege      => l_privilege
                                                , p_object_name    => l_object_name
                                                , p_object_key     => l_object_key
                                                , p_init_msg_list   => FND_API.G_FALSE);

                                ELSIF l_assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN

                                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                                        l_ret_code := 'T';

                                        PA_SECURITY_PVT.CHECK_CONFIRM_ASMT(
                                                  p_project_id     => l_project_id
                                                , p_resource_id    => l_resource_id
                                                , p_resource_name  => null
                                                , p_privilege      => 'PA_ADM_ASN_CONFIRM'
                                                , p_start_date     => l_start_date
                                                , x_ret_code       => l_ret_code
                                                , x_return_status  => l_return_status
                                                , x_msg_count      => l_msg_count
                                                , x_msg_data       => l_msg_data
                                                , p_init_msg_list  => FND_API.G_FALSE);
                                END IF;
                        ELSE
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_UNEXPECTED ERROR');
                                raise FND_API.G_EXC_ERROR;
                        END IF;

                        IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                -- This message does not have token defined, but intentionally putting token
                                -- because we still want to show the privilege name which is missing
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_CR_DL'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                l_error_flag_local := 'Y';
                        END IF;
                END IF;

                IF l_error_flag_local <> 'Y' THEN

                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling PA_ASSIGNMENTS_PUB.DELETE_ASSIGNMENT for record number'||i, l_debug_level);
                        END IF;

                        PA_ASSIGNMENTS_PUB.DELETE_ASSIGNMENT (
                                  p_assignment_row_id      => l_assignment_row_id
                                , p_assignment_id          => l_assignment_id
                                , p_record_version_number  => l_record_version_number
                                , p_assignment_type        => l_assignment_type
                                , p_assignment_number      => l_assignment_number
                                , p_commit                 => l_commit
                                , p_validate_only          => l_validate_only
                                , x_return_status          => l_return_status
                                , x_msg_count              => l_msg_count
                                , x_msg_data               => l_msg_data );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After call PA_ASSIGNMENTS_PUB.DELETE_ASSIGNMENT l_return_status='||l_return_status, l_debug_level);
                        END IF;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                l_error_flag_local := 'Y';
                        END IF;
                END IF;

                l_end_msg_count := FND_MSG_PUB.count_msg;
                l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                          p_msg_index      => l_start_msg_count+1
                                        , p_encoded        => FND_API.G_FALSE
                                        , p_data           => l_data
                                        , p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;
                END IF;
                i := p_assignment_in_tbl.next(i);
        END LOOP;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO DELETE_ASSIGNMENTS_SP;
        END IF;

        IF cur_assignment_details%ISOPEN THEN
                CLOSE cur_assignment_details ;
        END IF;

        IF cur_get_system_status%ISOPEN THEN
                CLOSE cur_get_system_status ;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.GET_MESSAGES (
                          p_encoded        => FND_API.G_FALSE
                        , p_msg_index      => 1
                        , p_msg_count      => l_msg_count
                        , p_msg_data       => l_msg_data
                        , p_data           => l_data
                        , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTRB(SQLERRM,1,240);

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO DELETE_ASSIGNMENTS_SP;
        END IF;

        IF cur_assignment_details%ISOPEN THEN
                CLOSE cur_assignment_details ;
        END IF;

        IF cur_get_system_status%ISOPEN THEN
                CLOSE cur_get_system_status ;
        END IF;

        FND_MSG_PUB.add_exc_msg (
                  p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
                , p_procedure_name      => 'DELETE_REQUIREMENTS'
                , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;

END DELETE_ASSIGNMENTS;


-- Start of comments
--      API name        : SUBMIT_ASSIGNMENTS
--      Type            : Public
--      Pre-reqs        : None.
--      Function        : This is a public API to submit/approve one or more assignments for one or more projects.
--      Usage           : This API will be called from AMG.
--      Parameters      :
--      IN              :       p_commit                IN  VARCHAR2
--                                      Identifier to commit the transaction.
--                                      Valid values are: FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--                              p_init_msg_list         IN  VARCHAR2
--                                      Identifier to initialize the error message stack.
--                                      Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--                              p_api_version_number    IN  NUMBER                      Required
--                                      To be compliant with Applications API coding standards.
--				p_submit_assignment_id_tbl  IN	SUBMIT_ASSIGNMENT_IN_TBL_TYPE  Required
--					Table of assignment records. Please see the SUBMIT_ASSIGNMENT_IN_TBL_TYPE
--					datatype table.
--	OUT             :
--                              x_return_status                 OUT VARCHAR2
--                                      Indicates the return status of the API.
--                                      Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--                              x_msg_count                     OUT NUMBER
--                                      Indicates the number of error messages in the message stack
--                              x_msg_data                      OUT VARCHAR2
--                                      Indicates the error message text if only one error exists
--      History         :
--
--                              15-Mar-2006 - avaithia  - Created
-- End of comments

PROCEDURE SUBMIT_ASSIGNMENTS
(
  p_api_version_number          IN              NUMBER   := 1.0
, p_init_msg_list               IN              VARCHAR2 := FND_API.G_TRUE
, p_commit                      IN              VARCHAR2 := FND_API.G_FALSE
, p_submit_assignment_in_tbl    IN              SUBMIT_ASSIGNMENT_IN_TBL_TYPE
, x_return_status               OUT     NOCOPY  VARCHAR2
, x_msg_count                   OUT     NOCOPY  NUMBER
, x_msg_data                    OUT     NOCOPY  VARCHAR2
)
IS
l_calling_application           VARCHAR2(10)            := 'PLSQL';
l_calling_module                VARCHAR2(10)            := 'AMG';
l_check_id_flag                 VARCHAR2(1)             := 'Y';
l_check_role_security_flag      VARCHAR2(1)             := 'Y';
l_check_resource_security_flag  VARCHAR2(1)             := 'Y';

l_log_level                     NUMBER                  := 3;
l_module                        VARCHAR2(100)           := 'PA_RES_MANAGEMENT_AMG_PUB.SUBMIT_ASSIGNMENTS';
l_commit                        VARCHAR2(1)             := FND_API.G_FALSE;
l_init_msg_list                 VARCHAR2(1)             := FND_API.G_FALSE;

l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_data                          VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);

i                               NUMBER;

l_asgn_rec                      SUBMIT_ASSIGNMENT_IN_REC_TYPE;
l_assignment_id                 NUMBER;
l_auto_approve                  VARCHAR2(1)             := 'N';
l_apr_person_id_1               NUMBER;
l_apr_person_id_2               NUMBER;
l_note_to_approver              VARCHAR2(240);
l_record_version_number         NUMBER;

l_project_id                    NUMBER;
l_resource_id                   NUMBER;
l_start_date                    DATE;
l_assignment_type               VARCHAR2(30);

l_mass_wf_in_progress_flag      VARCHAR2(1);
l_apprvl_status_code            VARCHAR2(30);
l_apprvl_sys_status_code	VARCHAR2(30);

l_out_new_assignment_flag       VARCHAR2(1) ;
l_out_approval_required_flag    VARCHAR2(1) ;
l_out_record_version_number     NUMBER;

l_validate_only                 VARCHAR2(1)             := FND_API.G_FALSE;
l_overcommitment_flag           VARCHAR2(1);
l_conflict_group_id             NUMBER;

l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
l_error_flag                    VARCHAR2(1)             := 'N';
l_error_flag_local              VARCHAR2(1)             := 'N';

l_loop_msg_count                NUMBER                  :=0;
l_start_msg_count               NUMBER                  :=0;
l_end_msg_count                 NUMBER                  :=0;

l_missing_params                VARCHAR2(1000);
l_privilege                     VARCHAR2(30);
l_object_name                   VARCHAR2(30);
l_object_key                    NUMBER;
l_error_message_code            VARCHAR2(30);
l_ret_code                      VARCHAR2(1)             := FND_API.G_TRUE;

l_before_api_msg_count          NUMBER;
l_after_api_msg_count           NUMBER;

l_full_name_apr1                VARCHAR2(240);
l_sys_person_type_apr1          VARCHAR2(30);
l_user_person_type_apr1         VARCHAR2(80);

l_full_name_apr2                VARCHAR2(240);
l_sys_person_type_apr2          VARCHAR2(30);
l_user_person_type_apr2         VARCHAR2(80);

l_valid 			VARCHAR2(1); -- Bug 5175869

CURSOR c_valid_asgn_id(p_assignment_id IN NUMBER) IS
SELECT project_id , resource_id,start_date,assignment_type,mass_wf_in_progress_flag ,apprvl_status_code,record_version_number
FROM   pa_project_assignments
WHERE  assignment_type <> 'OPEN_ASSIGNMENT'
  AND  assignment_id = p_assignment_id ;

CURSOR get_person_type(p_person_id IN NUMBER) IS
SELECT per.full_name, ppt.SYSTEM_PERSON_TYPE , ppt.USER_PERSON_TYPE
FROM per_all_people_f per , per_person_types ppt
where per.person_type_id = ppt.person_type_id
AND   per.person_id = p_person_id
AND   per.effective_end_date = (SELECT MAX(pf.effective_end_date)
                          FROM per_all_people_f pf
                          WHERE pf.person_id = p_person_id);

CURSOR c_sys_status_code(l_in_status_code IN VARCHAR2  ) IS
SELECT project_system_status_code
FROM  pa_project_statuses
WHERE project_status_code = l_in_status_code
AND status_type= 'ASGMT_APPRVL';

BEGIN
        --------------------------------------------------
        -- RESET OUT params
        --------------------------------------------------
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        x_msg_data := NULL ;

        --------------------------------------------------
        -- Initialize Current Function and Msg Stack
        --------------------------------------------------
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'SUBMIT_ASSIGNMENTS', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;
        --------------------------------------------------
        -- Create Savepoint
        --------------------------------------------------
        IF p_commit = FND_API.G_TRUE THEN
                savepoint SUBMIT_ASSIGNMENTS_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of SUBMIT_ASSIGNMENTS', l_log_level);
        END IF;
        --------------------------------------------------
        -- Start Initialize
        --------------------------------------------------
        PA_STARTUP.INITIALIZE(
                  p_calling_application => l_calling_application
                , p_calling_module => l_calling_module
                , p_check_id_flag => l_check_id_flag
                , p_check_role_security_flag => l_check_role_security_flag
                , p_check_resource_security_flag => l_check_resource_security_flag
                , p_debug_level => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of PA_STARTUP.INITIALIZE', l_log_level);
        END IF;
        --------------------------------------------------
        -- Defaulting Values and Mandatory param validations
        -- Security Check
        -- Core Logic
        --------------------------------------------------
        i := p_submit_assignment_in_tbl.first;
        WHILE i is not NULL LOOP
                l_error_flag_local := 'N';
                l_missing_params := null;
                l_asgn_rec := NULL ;

                l_start_msg_count := FND_MSG_PUB.count_msg;

                l_asgn_rec := p_submit_assignment_in_tbl(i);

                -- Blank Out Parameters if not passed.

                IF l_asgn_rec.assignment_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.assignment_id := NULL ;
                END IF;

                IF l_asgn_rec.record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.record_version_number := NULL ;
                END IF;

                IF l_asgn_rec.auto_approve = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.auto_approve := NULL ;
                END IF;

                IF l_asgn_rec.apr_person_id_1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.apr_person_id_1 := NULL ;
                END IF;

                IF l_asgn_rec.apr_person_id_2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_asgn_rec.apr_person_id_2 := NULL ;
                END IF;

                IF l_asgn_rec.note_to_approver = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_asgn_rec.note_to_approver := NULL ;
                END IF;

                l_assignment_id := l_asgn_rec.assignment_id ;
                l_record_version_number := l_asgn_rec.record_version_number ;
                l_auto_approve := l_asgn_rec.auto_approve;
                l_apr_person_id_1 := l_asgn_rec.apr_person_id_1 ;
                l_apr_person_id_2 := l_asgn_rec.apr_person_id_2 ;
                l_note_to_approver := l_asgn_rec.note_to_approver ;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Assignment Id ' || l_assignment_id,l_log_level);
                        pa_debug.write(l_module, 'Record Version Number is ' ||l_record_version_number,l_log_level);
                        pa_debug.write(l_module, 'Auto Approve is ' ||l_auto_approve,l_log_level);
                        pa_debug.write(l_module, 'Approve Person Id 1 is ' || l_apr_person_id_1,l_log_level);
                        pa_debug.write(l_module, 'Approve Person Id 2 is ' || l_apr_person_id_2,l_log_level);
                        pa_debug.write(l_module, 'Note to Approver is ' || l_note_to_approver,l_log_level);
                END IF;

                -- Mandatory Parameters Check
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory Parameter Validation Starts', l_log_level);
                END IF;

                IF l_asgn_rec.assignment_id IS NULL THEN
                        l_missing_params := l_missing_params||'ASSIGNMENT_ID ' ;
                END IF;

                IF l_asgn_rec.record_version_number IS NULL THEN
                        l_missing_params := l_missing_params||', RECORD_VERSION_NUMBER ' ;
                END IF;

                IF l_asgn_rec.auto_approve IS NULL THEN
                        l_missing_params := l_missing_params||', AUTO_APPROVE ' ;
                END IF;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory Parameter Validation Over. ',l_log_level);
                        pa_debug.write(l_module, 'The missing parameters are '||l_missing_params, l_log_level);
                END IF;

                IF l_missing_params IS NOT NULL THEN
                        l_error_flag_local := 'Y';
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                END IF;

                IF l_error_flag_local <> 'Y' THEN --------- (1)
                        l_assignment_id := l_asgn_rec.assignment_id ;

                        -- Validate whether the passed id is a valid one
                        OPEN c_valid_asgn_id(l_assignment_id) ;
                        FETCH c_valid_asgn_id into l_project_id ,l_resource_id,l_start_date,l_assignment_type,l_mass_wf_in_progress_flag ,l_apprvl_status_code,l_record_version_number;
                        IF c_valid_asgn_id%NOTFOUND THEN
                                l_missing_params := l_missing_params||' ,ASSIGNMENT_ID' ;
                                l_error_flag_local := 'Y';
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                        'INVALID_PARAMS', l_missing_params);
                        ELSE -- The passed Id is a valid assignment

                                IF nvl(l_mass_wf_in_progress_flag,'N') = 'Y' THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_ASSIGNMENT_WF');
                                        l_error_flag_local := 'Y';
                                END IF;

				OPEN c_sys_status_code(l_apprvl_status_code);
				FETCH c_sys_status_code INTO l_apprvl_sys_status_code ;
				CLOSE c_sys_status_code ;

                                IF l_apprvl_sys_status_code in ('ASGMT_APPRVL_CANCELED','ASGMT_APPRVL_SUBMITTED','ASGMT_APPRVL_APPROVED')
                                THEN
                                        -- We can submit only if the approval status is Working or Requires resubmission
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_STS_ACT_NOT_ALLW');
                                        l_error_flag_local := 'Y'; -- Modify above new err msg for Approved also
                                END IF;
                        END IF;
                        CLOSE c_valid_asgn_id ;

                        -- Validate the flag value passed for Auto Approve
                        IF l_asgn_rec.auto_approve not in ('Y','N') THEN
                                l_error_flag_local := 'Y';
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS','INVALID_PARAMS','AUTO_APPROVE');
                        END IF;
                        --------------------------------------------------------
                        --  Derive x_new_assignment_flag and x_approval_required
                        --------------------------------------------------------

                        IF l_error_flag_local <> 'Y' THEN

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Before Calling PA_ASSIGNMENT_APPROVAL_PUB.Populate_Changed_Items_Table for record number '||i, l_log_level);
                        END IF;

                        l_before_api_msg_count := FND_MSG_PUB.count_msg;
                        PA_ASSIGNMENT_APPROVAL_PUB.Populate_Changed_Items_Table
                        (
                                 p_assignment_id => l_assignment_id
                                ,x_new_assignment_flag => l_out_new_assignment_flag
                                ,x_approval_required_flag => l_out_approval_required_flag
                                ,x_record_version_number => l_out_record_version_number
                                ,x_return_status => l_return_status
                                ,x_msg_count     => l_msg_count
                                ,x_msg_data      => l_msg_data
                        );

                        l_after_api_msg_count := FND_MSG_PUB.count_msg;
                        -- Dont rely on l_return_status as inside above API
                        -- IF no of msgs in stack is  > 0 ,they set it as error
                        -- So, Just rely on (l_after_api_msg_count - l_before_api_msg_count) value

                        IF (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
                                l_error_flag_local := 'Y';
                                -- PA_UTILS.ADD_MESSAGE('PA', 'PA_UNEXPECTED ERROR');
                        END IF;

                        END IF;
                        ------------------------------------------------------------------
                        -- If Populate_Changed_Items_Table is successful ,proceed further
                        ------------------------------------------------------------------
                        IF l_error_flag_local <> 'Y' THEN --------- (2)

                                IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'Populate_Changed_Items_Table is successful',l_log_level)
;
                                END IF;

                                IF l_auto_approve = 'Y' THEN
                                        -- Check for resource authority
                                        IF l_assignment_type = 'STAFFED_ASSIGNMENT' THEN

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'Checking for PA_ASN_CONFIRM privilege',l_log_level);
                                                END IF;

                                                pa_security_pvt.check_confirm_asmt
                                                (p_project_id => l_project_id
                                                ,p_resource_id => l_resource_id
                                                ,p_resource_name => null
                                                ,p_privilege => 'PA_ASN_CONFIRM'
                                                ,p_start_date => l_start_date
						,p_init_msg_list   => 'F'
                                                ,x_ret_code => l_ret_code
                                                ,x_return_status => l_return_status
                                                ,x_msg_count     => l_msg_count
                                                ,x_msg_data      => l_msg_data
                                                );
                                        ELSIF l_assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'Checking for PA_ADM_ASN_CONFIRM privilege',l_log_level);
                                                END IF;

                                                pa_security_pvt.check_confirm_asmt
                                                 (p_project_id => l_project_id
                                                 ,p_resource_id => l_resource_id
                                                 ,p_resource_name => null
                                                 ,p_privilege => 'PA_ADM_ASN_CONFIRM'
                                                 ,p_start_date => l_start_date
						 ,p_init_msg_list   => 'F'
                                                 ,x_ret_code => l_ret_code
                                                 ,x_return_status => l_return_status
                                                 ,x_msg_count     => l_msg_count
                                                 ,x_msg_data      => l_msg_data
                                                );
                                        END IF;

                                        IF  l_ret_code = FND_API.G_FALSE AND l_out_approval_required_flag = 'N'  THEN

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'Populating PA_ASGN_CONFIRM_NOT_ALLOWED',l_log_level);
                                                END IF;

                                                l_error_flag_local := 'Y';
                                                PA_UTILS.Add_Message ( 'PA','PA_ASGN_CONFIRM_NOT_ALLOWED');
                                                -- Can we use PA_ASGN_CONFIRM_NOT_ALLOWED
                                                -- In TAD its given as PA_NO_RESOURCE_AUTHORITY ,its not appropriate
                                        END IF;

                                        IF l_ret_code = FND_API.G_TRUE OR l_out_approval_required_flag ='Y' THEN

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'Calling Start_Assignment_Approvals',l_log_level);
                                                END IF;

                                                l_before_api_msg_count := FND_MSG_PUB.count_msg;

                                                -- Call API PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals
                                                PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals
                                                (
                                                 p_assignment_id => l_assignment_id
                                                ,p_new_assignment_flag => 'N'
                                                ,p_action_code => 'APPROVE'
                                                ,p_note_to_approver => l_note_to_approver
                                                ,p_record_version_number => l_record_version_number
                                                ,p_validate_only => l_validate_only
                                                ,x_overcommitment_flag => l_overcommitment_flag
                                                ,x_conflict_group_id => l_conflict_group_id
                                                ,x_return_status => l_return_status
                                                ,x_msg_count => l_msg_count
                                                ,x_msg_data => l_msg_data
                                                );
                                                l_after_api_msg_count := FND_MSG_PUB.count_msg;

                                                IF l_debug_mode = 'Y' THEN
                                                        pa_debug.write(l_module, 'l_overcommitment_flag ' ||l_overcommitment_flag,l_log_level);
                                                        pa_debug.write(l_module, 'l_conflict_group_id ' ||l_conflict_group_id,l_log_level);
                                                        pa_debug.write(l_module, 'l_return_status ' ||l_return_status,l_log_level);
                                                END IF;

                                                IF (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
                                                        l_error_flag_local := 'Y';
                                                -- Dont check l_return_status as internal API
                                                -- sets return status as E if there are any msgs in stack
                                                -- Even before this API is called.

                                                END IF;
                                        END IF;
                                ELSE    -- Auto Approve Flag is No

                                        OPEN get_person_type(l_apr_person_id_1);
                                        FETCH get_person_type INTO l_full_name_apr1 ,l_sys_person_type_apr1,l_user_person_type_apr1;
                                        IF get_person_type%NOTFOUND THEN
                                                l_full_name_apr1 := NULL;
                                                l_sys_person_type_apr1 := NULL ;
                                                l_user_person_type_apr1 :=  NULL ;
                                        END IF;
                                        CLOSE get_person_type;

                                        OPEN get_person_type(l_apr_person_id_2);
                                        FETCH get_person_type INTO l_full_name_apr2,l_sys_person_type_apr2,l_user_person_type_apr2;
                                        IF get_person_type%NOTFOUND THEN
                                                l_full_name_apr2 := NULL;
                                                l_sys_person_type_apr2 := NULL ;
                                                l_user_person_type_apr2 :=  NULL ;
                                        END IF;
                                        CLOSE get_person_type;

                                        -- Populate PA_NO_NON_EXCLUDED_APR if
                                        -- You are going to submit for approval
                                        -- and there are no approvers specified.

                                        IF (l_full_name_apr1 is NULL AND l_full_name_apr2 is NULL)
                                            OR
                                           (l_apr_person_id_1 is NULL AND l_apr_person_id_2 is NULL)
                                        THEN
                                                l_error_flag_local := 'Y';
                                                PA_UTILS.ADD_MESSAGE('PA','PA_NO_NON_EXCLUDED_APR');
                                        END IF;

					-- Bug 5175869 : Start
					IF l_apr_person_id_1 IS NOT NULL THEN
						l_valid := 'N';
						l_valid := IS_VALID_APPROVER(l_apr_person_id_1,l_resource_id,l_start_date);
						IF l_valid = 'N' THEN
							l_error_flag_local := 'Y';
                                                	PA_UTILS.ADD_MESSAGE('PA','PA_INVALID_APPRVR'
										,'APPROVER_ID',l_apr_person_id_1);
						END IF;
					END IF;

					IF l_apr_person_id_2 IS NOT NULL THEN
						l_valid := 'N';
                                                l_valid := IS_VALID_APPROVER(l_apr_person_id_2,l_resource_id,l_start_date);
                                                IF l_valid = 'N' THEN
                                                        l_error_flag_local := 'Y';
                                                        PA_UTILS.ADD_MESSAGE('PA','PA_INVALID_APPRVR'
                                                                                ,'APPROVER_ID',l_apr_person_id_2);
						END IF;
					END IF;

					-- Bug 5175869 : End

                                        IF (l_error_flag_local <> 'Y' AND l_apr_person_id_1 is NOT NULL) THEN

						-- Added for Bug 5245870
						-- If second approver is present then call the api with validate only parameter.
						IF (l_apr_person_id_2 IS NOT NULL) THEN
							l_validate_only := FND_API.G_TRUE;
						ELSE
							l_validate_only := FND_API.G_FALSE;
						END IF;

                                        l_before_api_msg_count := FND_MSG_PUB.count_msg;
                                        PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals
                                        (
                                         p_assignment_id => l_assignment_id
                                        ,p_new_assignment_flag => l_out_new_assignment_flag
                                        ,p_action_code => 'SUBMIT'
                                        ,p_note_to_approver => l_note_to_approver
                                        ,p_apr_person_id => l_apr_person_id_1
                                        ,p_apr_person_name => l_full_name_apr1
                                        ,p_apr_person_type => 'RESOURCE_MANAGER' /* Added for bug 9379440 */
                                        ,p_apr_person_order => 1
                                        ,p_apr_person_exclude => 'N'
                                        ,p_record_version_number => l_record_version_number
                                        ,p_validate_only => l_validate_only
                                        ,x_overcommitment_flag => l_overcommitment_flag
                                        ,x_conflict_group_id => l_conflict_group_id
                                        ,x_return_status => l_return_status
                                        ,x_msg_count => l_msg_count
                                        ,x_msg_data => l_msg_data
                                        );
                                --l_apr_person_name1:= pa_resource_utils.get_person_name_no_date(l_apr_person_id_1);
                                --l_apr_person_name2:=pa_resource_utils.get_person_name_no_date(l_apr_person_id_2);

                                        l_after_api_msg_count := FND_MSG_PUB.count_msg;

                                        IF l_debug_mode = 'Y' THEN
                                             pa_debug.write(l_module, 'l_overcommitment_flag ' ||l_overcommitment_flag,l_log_level);
                                             pa_debug.write(l_module, 'l_conflict_group_id ' ||l_conflict_group_id,l_log_level);
                                             pa_debug.write(l_module, 'l_return_status ' ||l_return_status,l_log_level);
                                        END IF;

                                        IF (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
                                            l_error_flag_local := 'Y';
                                                -- Dont check l_return_status as internal API
                                                -- sets return status as E if there are any msgs in stack
                                                -- Even before this API is called.
                                        END IF;

                                        END IF; -- If no error and l_apr_person_id_1 is not null

                                        IF (l_error_flag_local <> 'Y' AND l_apr_person_id_2 IS NOT NULL) THEN
                                                -- Call API for Approver 2
						l_validate_only := FND_API.G_FALSE;  -- Added for Bug 5245870
                                                l_before_api_msg_count := FND_MSG_PUB.count_msg;
                                                PA_ASSIGNMENT_APPROVAL_PUB.Start_Assignment_Approvals
                                                (
                                                p_assignment_id => l_assignment_id
                                                ,p_new_assignment_flag => l_out_new_assignment_flag
                                                ,p_action_code => 'SUBMIT'
                                                ,p_note_to_approver => l_note_to_approver
                                                ,p_apr_person_id => l_apr_person_id_2
                                                ,p_apr_person_name => 'STAFFING_MANAGER' /* Added for bug 9379440 */
                                                ,p_apr_person_type => l_sys_person_type_apr2
						,p_apr_person_order => 2       -- Changed for Bug 5245870 from 1 to 2
                                                ,p_apr_person_exclude => 'N'
                                                ,p_record_version_number => l_record_version_number
                                                ,p_validate_only => l_validate_only
                                                ,x_overcommitment_flag => l_overcommitment_flag
                                                ,x_conflict_group_id => l_conflict_group_id
                                                ,x_return_status => l_return_status
                                                ,x_msg_count => l_msg_count
                                                ,x_msg_data => l_msg_data
                                                );
                                --l_apr_person_name1:= pa_resource_utils.get_person_name_no_date(l_apr_person_id_1);
                                --l_apr_person_name2:=pa_resource_utils.get_person_name_no_date(l_apr_person_id_2);

                                                l_after_api_msg_count := FND_MSG_PUB.count_msg;
                                                IF (l_after_api_msg_count - l_before_api_msg_count) > 0 THEN
                                                        l_error_flag_local := 'Y';
                                                        -- Dont check l_return_status as internal API
                                                        -- sets return status as E if there are any msgs in stack
                                                        -- Even before this API is called.
                                                END IF;
                                        END IF;  -- If no error and l_apr_person_id_2 is not null
                                END IF; -- End if Auto Approve Flag is Yes .

                        END IF; -- l_error_flag_local <> Y --------- (2)
                END IF; -- l_error_flag_local <> Y --------- (1)

                l_end_msg_count := FND_MSG_PUB.count_msg;

                l_loop_msg_count := l_end_msg_count - l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Repopulating Error Message Stack', l_log_level);
                        END IF;

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;
                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Repopulating Error Message Stack', l_log_level);
                        END IF;
                END IF;
        i:= p_submit_assignment_in_tbl.next(i);
        END LOOP;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF c_valid_asgn_id%ISOPEN THEN
                CLOSE c_valid_asgn_id ;
        END IF;

        IF get_person_type%ISOPEN THEN
                CLOSE get_person_type;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO SUBMIT_ASSIGNMENTS_SP;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTRB(SQLERRM,1,240);

        IF c_valid_asgn_id%ISOPEN THEN
                CLOSE c_valid_asgn_id ;
        END IF;

        IF get_person_type%ISOPEN THEN
                CLOSE get_person_type;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO SUBMIT_ASSIGNMENTS_SP;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'SUBMIT_ASSIGNMENTS'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;

END SUBMIT_ASSIGNMENTS ;

-- Start of comments
--	API name 	: CREATE_REQUIREMENT_COMPETENCE
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to create one or more competences for one or more project requirements.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are: FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_competence_in_tbl	IN  COMPETENCE_IN_TBL	Required
--					Table of competence records.
--					Please see the COMPETENCE_IN_TBL_TYPE datatype table.
--	OUT		:
--				x_competence_element_id_tbl	OUT SYSTEM.PA_NUM_TBL_TYPE
--					Table to store the competence element ids created by the API.
--					Reference: per_comepetence_elements.competence_element_id
--				x_return_status			OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count			OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data			OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - vkadimes  - Created
-- End of comments
PROCEDURE CREATE_REQUIREMENT_COMPETENCE
(
  p_commit			IN	        VARCHAR2   :='F'
, p_init_msg_list		IN	        VARCHAR2   :='T'
, p_api_version_number		IN	        NUMBER     :=1.0
, p_competence_in_tbl		IN	        COMPETENCE_IN_TBL_TYPE
, x_competence_element_id_tbl	OUT     NOCOPY  SYSTEM.PA_NUM_TBL_TYPE
, x_return_status		OUT     NOCOPY  VARCHAR2
, x_msg_count			OUT     NOCOPY  NUMBER
, x_msg_data			OUT     NOCOPY  VARCHAR2
)
IS
-- Debug level setting Params
l_debug_mode			VARCHAR2(1);
l_module			VARCHAR2(255)		:= 'PA_RES_MANAGEMENT_AMG_PUB.CREATE_REQUIREMENT_COMPETENCE';
l_debug_level			NUMBER			:=3;
-- Params for  pa_startup.initialize call
l_calling_application		VARCHAR2(10)		:='PLSQL';
l_check_id_flag			VARCHAR2(1)		:= 'Y';
l_check_role_security_flag	VARCHAR2(1)		:= 'Y';
l_check_resource_security_flag	VARCHAR2(1)		:= 'Y';
l_calling_module		VARCHAR2(10)		:='AMG';
--Looping Params
i				NUMBER;
-- Record Type
l_competence_in_rec		COMPETENCE_IN_REC_TYPE;
-- Error Flags
l_error_flag                    VARCHAR2(1);
l_local_error_flag              VARCHAR2(1);
--Message Counters
l_start_msg_count               NUMBER;
l_end_msg_count                 NUMBER;
l_loop_msg_count                NUMBER ;
-- Miss Params List
l_miss_params			VARCHAR2(2000);
-- security check Params
l_privilege			VARCHAR2(30);
l_object_name			VARCHAR2(30);
l_object_key			NUMBER;
l_project_id			NUMBER;
l_template_id			NUMBER;
l_requirement_id		NUMBER;
l_ret_code			VARCHAR2(1);
l_wf_progress_flag              VARCHAR2(1);
l_status_code_num               NUMBER ;
-- Internal API calling Params
l_msg_data                      VARCHAR2(2000);
l_msg_count                     NUMBER;
l_commit			VARCHAR2(1)             := FND_API.G_FALSE;
l_return_status                 VARCHAR2(1);
l_data                          VARCHAR2(2000);
-- Temp Params
l_req_sys_status_code		VARCHAR2(30);
l_status_code                   VARCHAR2(30);
l_element_row_id		ROWID;
l_element_id			per_competence_elements.competence_element_id%TYPE;
l_msg_index_out                 NUMBER;

-- This cursor is used to Retrive the Info Regarding the given Requirement
CURSOR cur_assign_info (l_requirement_id  NUMBER ) IS
SELECT project_id,status_code,mass_wf_in_progress_flag
FROM	pa_project_assignments
where assignment_id = l_requirement_id
AND assignment_type = 'OPEN_ASSIGNMENT'
AND nvl(template_flag,'N') = 'N';

-- This cursor is used to get the system status code of the Given Requirement
CURSOR cur_status_code(l_status_code VARCHAR2  ) IS
SELECT project_system_status_code
FROM  pa_project_statuses
WHERE project_status_code = l_status_code
AND status_type= 'OPEN_ASGMT';

BEGIN
	-- Follows which are supported by this API
	------------------------------------------
	-- Adding one competence when Requirement_id and competence id
	-- or Name or Alias are passsed with Data like
	-- Mandatary Flag and Rating level.

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	x_competence_element_id_tbl :=  SYSTEM.PA_NUM_TBL_TYPE();

	l_debug_mode  := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');


	IF l_debug_mode = 'Y' THEN
		PA_DEBUG.set_curr_function(p_function => 'CREATE_REQUIREMENT_COMPETENCE', p_debug_mode => l_debug_mode);
	END IF;

	IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
		FND_MSG_PUB.initialize;
	END IF;

	IF P_COMMIT = FND_API.G_TRUE THEN
		SAVEPOINT CREATE_REQU_COMPETENCE_SP;
	END IF ;

 	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module, 'Save Point create ', l_debug_level);
		pa_debug.write(l_module, 'Start of CREATE_REQUIREMENT_COMPETENCE ', l_debug_level);
		pa_debug.write(l_module, 'Before calling pa_startup.initialize ', l_debug_level);
	END IF ;

	PA_STARTUP.INITIALIZE(
		  p_calling_application			=> l_calling_application
		, p_calling_module			=> l_calling_module
		, p_check_id_flag			=> l_check_id_flag
		, p_check_role_security_flag		=> l_check_role_security_flag
		, p_check_resource_Security_flag	=> l_check_resource_Security_flag
		, p_debug_level				=> l_debug_level);

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module, 'After calling pa_startup.initialize ', l_debug_level);
	END IF ;


	--checking the Input params..
	IF l_debug_mode = 'Y' THEN

		pa_debug.write(l_module, 'Printing Input Parameters......', l_debug_level);

		i := p_competence_in_tbl.first();

		WHILE i IS NOT NULL LOOP

			l_competence_in_rec := p_competence_in_tbl(i);

			pa_debug.write(l_module, 'Values for Record No :'|| i , l_debug_level);
			pa_debug.write(l_module, '-----------------------------', l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.requirement_id for record ' || i || l_competence_in_rec.requirement_id , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_element_id for record ' || i || l_competence_in_rec.competence_element_id  , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_id for record ' || i || l_competence_in_rec.competence_id	    , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_name for record ' || i || l_competence_in_rec.competence_name , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_alias for record ' || i || l_competence_in_rec.competence_alias , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.rating_level_id for record ' || i ||  l_competence_in_rec.rating_level_id , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.rating_level_value for record ' || i ||  l_competence_in_rec.rating_level_value , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.mandatory_flag for record ' || i ||  l_competence_in_rec.mandatory_flag , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.record_version_number for record ' || i ||  l_competence_in_rec.record_version_number , l_debug_level);

			i :=p_competence_in_tbl.next(i);
		END LOOP;

	END IF;
	-- Starting the Record validationa and API call.

	i := p_competence_in_tbl.first();

	WHILE i IS NOT NULL LOOP
		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'Inside Loop For Callling Internal API Record  '|| i , l_debug_level);
			pa_debug.write(l_module, '-------------------------------', l_debug_level);
		END IF ;

		l_local_error_flag := 'N';
		l_start_msg_count :=  FND_MSG_PUB.count_msg;
		l_competence_in_rec:=NULL ;
		l_miss_params := NULL;
		l_competence_in_rec := p_competence_in_tbl(i);
		-- Nulling out unpassed parameters

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'Start of Nulling out Params which are not passing for Record no '|| i , l_debug_level);
		END IF ;
		-- Nulling out unpassed params
		IF l_competence_in_rec.requirement_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.requirement_id	:= NULL;
		END IF ;

		IF l_competence_in_rec.competence_element_id	= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.competence_element_id	:= NULL;
		END IF;

		IF l_competence_in_rec.competence_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.competence_id := NULL;
		END IF;

		IF l_competence_in_rec.competence_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_competence_in_rec.competence_name := NULL;
		END IF ;

		IF l_competence_in_rec.competence_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_competence_in_rec.competence_alias := NULL;
		END IF;

		IF l_competence_in_rec.rating_level_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.rating_level_id := NULL;
		END IF;

		IF l_competence_in_rec.rating_level_value = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.rating_level_value := NULL;
		END IF;

		IF l_competence_in_rec.mandatory_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_competence_in_rec.mandatory_flag :=NULL;
		END IF;

		IF l_competence_in_rec.record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.record_version_number :=NULL;
		END IF;

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'End  of Nulling out Params which are not passing for Record no '|| i , l_debug_level);
			pa_debug.write(l_module, 'Start of checking for Missing Params for Record no '|| i , l_debug_level);
		END IF ;
		-- checking for missing params
		IF l_competence_in_rec.requirement_id IS NULL THEN
			l_miss_params:= l_miss_params||', REQUIREMENT_ID';
		END IF;

		IF l_competence_in_rec.competence_id IS    NULL  AND
			l_competence_in_rec.competence_name IS  NULL  AND
			l_competence_in_rec.competence_alias IS NULL  THEN
			l_miss_params:= l_miss_params||', COMPETANCE_ID, COMPETENCE_NAME, COMPETENCE_ALIAS';
		END IF;

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'After checking for miss Params for Record no '|| i , l_debug_level);
		END IF ;

		IF l_miss_params IS NOT NULL THEN
			l_local_error_flag :='Y';
			PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
						'INVALID_PARAMS', l_miss_params);
		END IF ;

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'Getting Requiremnet Details like project_id ,team_template_id,status_code etc '|| i , l_debug_level);
		END IF  ;

		l_requirement_id :=  l_competence_in_rec.requirement_id;

                -- security check
		OPEN cur_assign_info(l_requirement_id);
		FETCH cur_assign_info INTO l_project_id,l_status_code,l_wf_progress_flag;
		-- checking for the validity of the requirement_id.

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'Checking for the Validity of the Record.'|| i , l_debug_level);
		END IF  ;

		IF cur_assign_info%NOTFOUND THEN
			l_local_error_flag := 'Y';
                        l_miss_params := l_miss_params||', REQUIREMENT_ID';
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_miss_params);
        	END IF;

		CLOSE cur_assign_info;

		OPEN cur_status_code(l_status_code);
		FETCH cur_status_code INTO l_req_sys_status_code;
		CLOSE cur_status_code;

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'After getting requirement Details for Record '|| i , l_debug_level);
			pa_debug.write(l_module, 'l_project_id ' ||l_project_id ||'l_template_id '||l_template_id  , l_debug_level);
			pa_debug.write(l_module, 'l_req_sys_status_code '|| l_req_sys_status_code || 'l_wf_progress_flag ' || l_wf_progress_flag, l_debug_level);
		END IF;

		IF l_local_error_flag <> 'Y' THEN

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'Checking Security for record No'||i, l_debug_level);
			END IF;

			IF l_project_id IS NOT NULL THEN
				l_privilege := 'PA_ASN_BASIC_INFO_ED ';
				l_object_name := 'PA_PROJECTS';
				l_object_key := l_project_id;
		        ELSE
				-- This should never happen.
				PA_UTILS.ADD_MESSAGE('PA', 'PA_UNEXPECTED ERROR');
				raise FND_API.G_EXC_ERROR;
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling  PA_SECURITY_PVT.CHECK_USER_PRIVILEGE for Record = '||i||' with Following Values', l_debug_level);
				pa_debug.write(l_module, 'l_privilege :'|| l_privilege, l_debug_level);
				pa_debug.write(l_module, 'l_object_name :'||l_object_name, l_debug_level);
				pa_debug.write(l_module, 'l_object_key :'||l_object_key, l_debug_level);
                        END IF;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

			-- Checking Security at project level or at Template level
                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
				   x_ret_code       => l_ret_code
				 , x_return_status  => l_return_status
				 , x_msg_count      => l_msg_count
				 , x_msg_data       => l_msg_data
				 , p_privilege      => l_privilege
				 , p_object_name    => l_object_name
				 , p_object_key     => l_object_key
				 , p_init_msg_list   => FND_API.G_FALSE);

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Return Status from PA_SECURITY_PVT.CHECK_USER_PRIVILEGE for Record '||i||'is l_return_status '|| l_return_status , l_debug_level);
				pa_debug.write(l_module, 'l_ret_code ='|| l_ret_code , l_debug_level);
			END IF ;

                        IF (nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS)
			AND l_project_id IS NOT NULL  THEN
			-- If project level security Fails wll call Requirement level Security
				IF l_debug_mode = 'Y' THEN
					 pa_debug.write(l_module, 'No Access Found at Project level checking at Requirement level', l_debug_level);
				END IF ;
				l_privilege := 'PA_ASN_BASIC_INFO_ED';
				l_object_name := 'PA_PROJECT_ASSIGNMENTS';
				l_object_key := l_requirement_id;
				PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
					  x_ret_code       => l_ret_code
					, x_return_status  => l_return_status
					, x_msg_count      => l_msg_count
					, x_msg_data       => l_msg_data
					, p_privilege      => l_privilege
					, p_object_name    => l_object_name
					, p_object_key     => l_object_key
					, p_init_msg_list   => FND_API.G_FALSE );

				IF l_debug_mode = 'Y' THEN
					 pa_debug.write(l_module, 'Return Status are Requirement level l_date return value l_ret_code'|| l_ret_code, l_debug_level);
				END IF ;


			END IF;

			IF (nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				-- This message does not have token defined, but intentionally putting token
                                -- bcoz we still want to show the privielge name which is missing
				IF l_debug_mode = 'Y' THEN
					 pa_debug.write(l_module, 'User Dont have Privillege to modify this Requirement', l_debug_level);
				END IF ;

				PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_ADD_COMP'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
				l_local_error_flag := 'Y';
		        END IF ;
			-- checking Requiremnet Status
			IF l_req_sys_status_code IN ('ASGMT_APPRVL_SUBMITTED','OPEN_ASGMT_FILLED', 'ASGMT_APPRVL_CANCELED') THEN
				 PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_STS_ACT_NOT_ALLW');
				 l_local_error_flag := 'Y';
			END IF ;
			-- Checking WF status..
			IF l_wf_progress_flag = 'Y' THEN
				PA_UTILS.ADD_MESSAGE('PA', 'PA_ASSIGNMENT_WF');
				l_local_error_flag := 'Y';
			END IF;

			IF l_debug_mode = 'Y' THEN
			        pa_debug.write(l_module, 'End of Security  check '|| l_ret_code, l_debug_level);
			END IF ;


		END IF;


	        --- Calling pa_competence_pub.Add_competence_elemets
		IF  l_local_error_flag <> 'Y' THEN
			-- No error occured.ie local error Flag is N
			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'Calling PA_COMPETENCE_PUB.ADD_COMPETENCE_ELEMENT ', l_debug_level);
			END IF ;
			l_return_status := FND_API.G_RET_STS_SUCCESS;
			-- Calling Internal API to Add competence
			PA_COMPETENCE_PUB.ADD_COMPETENCE_ELEMENT(
				    p_object_name		=> 'OPEN_ASSIGNMENT'
				  , p_object_id			=> l_competence_in_rec.requirement_id
				  , p_competence_id		=> l_competence_in_rec.competence_id
				  , p_competence_alias		=> l_competence_in_rec.competence_alias
				  , p_competence_name		=> l_competence_in_rec.competence_name
				  , p_rating_level_id		=> l_competence_in_rec.rating_level_id
				  , p_rating_level_value	=> l_competence_in_rec.rating_level_value
				  , p_mandatory_flag		=> l_competence_in_rec.mandatory_flag
				  , p_init_msg_list		=> 'F'
				  , P_commit			=> l_commit
				  , p_validate_only		=> 'N'
				  , x_element_id		=> l_element_id
				  , x_element_rowid		=> l_element_row_id
				  , x_return_status		=> l_return_status
				  , x_msg_count			=> l_msg_count
				  , x_msg_data			=> l_msg_data);

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'After Calling PA_COMPETENCE_PUB.ADD_COMPETENCE_ELEMENT ', l_debug_level);
				pa_debug.write(l_module, 'l_return_status '|| l_return_status || 'for record '|| i , l_debug_level);
			END IF ;

			IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
				x_competence_element_id_tbl.extend(1);
				x_competence_element_id_tbl(x_competence_element_id_tbl.count):= l_element_id;
			ELSE
 				x_competence_element_id_tbl.extend(1);
				x_competence_element_id_tbl(x_competence_element_id_tbl.count):= -1;
				l_local_error_flag := 'Y';
			END IF;
		ELSE
		  -- if local Error Flag is set for missparams or sec.Populating Out  table with -1
 			x_competence_element_id_tbl.extend(1);
			x_competence_element_id_tbl(x_competence_element_id_tbl.count):= -1;
		END IF ;
		  -- Taking end count of loop
		l_end_msg_count := FND_MSG_PUB.count_msg;
		l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

 		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'Error Flag for Record '|| i || ' is l_local_error_flag  '|| l_local_error_flag , l_debug_level);
		END IF ;

		IF l_local_error_flag = 'Y' OR l_loop_msg_count > 0 THEN
			l_error_flag := 'Y';

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'After Calling PA_COMPETENCE_PUB.ADD_COMPETENCE_ELEMENT ', l_debug_level);
			END IF ;

			FOR j in l_start_msg_count+1..l_end_msg_count LOOP
				FND_MSG_PUB.get (
					  p_msg_index      =>  l_start_msg_count+1
					, p_encoded        => FND_API.G_FALSE
					, p_data           => l_data
					, p_msg_index_out  => l_msg_index_out );

				FND_MSG_PUB.DELETE_MSG(p_msg_index =>  l_start_msg_count+1);
					-- Adding Record Number to The Message.
				PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
						  'RECORD_NO', i,
						  'MESSAGE', l_data);
			END LOOP;

		END IF;
		i := P_COMPETENCE_IN_TBL.next(i);
	END LOOP;
        -- End of Loop(Record Loop)
	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module, 'Out Of PA_COMPETENCE_PUB.ADD_COMPETENCE_ELEMENT  API calling Loop', l_debug_level);
	END IF ;

	IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_debug_mode = 'Y' THEN
		PA_DEBUG.reset_curr_function;
	END IF;

	IF p_commit = FND_API.G_TRUE THEN
		commit;
	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		l_msg_count := FND_MSG_PUB.count_msg;

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'In Side Exception Block FND_API.G_EXC_ERROR', l_debug_level);
			pa_debug.write(l_module, 'Closing CURSORS if OPEN', l_debug_level);
		END IF ;

		IF cur_assign_info%ISOPEN THEN
			CLOSE cur_assign_info;
		END IF;

		IF cur_status_code%ISOPEN THEN
			CLOSE cur_status_code;
		END IF;

		IF p_commit = FND_API.G_TRUE THEN
			ROLLBACK TO CREATE_REQU_COMPETENCE_SP;
		END IF;

		IF l_msg_count = 1 AND x_msg_data IS NULL THEN
			PA_INTERFACE_UTILS_PUB.GET_MESSAGES(
				  p_encoded        => FND_API.G_FALSE
				, p_msg_index      => 1
				, p_msg_count      => l_msg_count
				, p_msg_data       => l_msg_data
				, p_data           => l_data
				, p_msg_index_out  => l_msg_index_out);

			x_msg_data := l_data;
			x_msg_count := l_msg_count;
		ELSE
			x_msg_count := l_msg_count;
		END IF;

		IF l_debug_mode = 'Y' THEN
			Pa_Debug.reset_curr_function;
		END IF;

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_msg_data      := SUBSTRB(SQLERRM,1,240);

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'In Side Exception Block others ', l_debug_level);
			pa_debug.write(l_module, 'Closing CURSORS if OPEN', l_debug_level);
		END IF ;

		IF cur_assign_info%ISOPEN THEN
			CLOSE cur_assign_info;
		END IF;

		IF cur_status_code%ISOPEN THEN
			CLOSE cur_status_code;
		END IF;

		IF p_commit = FND_API.G_TRUE THEN
			ROLLBACK TO CREATE_REQU_COMPETENCE_SP;
		END IF;

		FND_MSG_PUB.add_exc_msg (
			  p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
			, p_procedure_name      => 'CREATE_REQUIREMENT_COMPETENCE'
			, p_error_text          => x_msg_data);

		x_msg_count     := FND_MSG_PUB.count_msg;

		IF l_debug_mode = 'Y' THEN
			PA_DEBUG.reset_curr_function;
		END IF;
		RAISE;

END CREATE_REQUIREMENT_COMPETENCE;

-- Start of comments
--	API name 	: UPDATE_REQUIREMENT_COMPETENCE
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to update one or more competences for one or more project requirements.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are: FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_competence_in_tbl	IN  COMPETENCE_IN_TBL_TYPE	Required
--					Table of competence records. Please see the COMPETENCE_IN_TBL_TYPE datatype table.
--	OUT		:
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - vkadimes  - Created
-- End of comments
PROCEDURE UPDATE_REQUIREMENT_COMPETENCE
(
  p_commit		IN		VARCHAR2  := 'F'
, p_init_msg_list	IN		VARCHAR2  := 'T'
, p_api_version_number	IN		NUMBER    := 1.0
, p_competence_in_tbl	IN		COMPETENCE_IN_TBL_TYPE
, x_return_status	OUT NOCOPY	VARCHAR2
, x_msg_count		OUT NOCOPY	NUMBER
, x_msg_data		OUT NOCOPY	VARCHAR2
) IS
-- Debug Level
l_module			VARCHAR2(255)		:= 'PA_RES_MANAGEMENT_AMG_PUB.UPDATE_REQUIREMENT_COMPETENCE';
l_debug_mode			VARCHAR2(1);
l_debug_level                   NUMBER		:=3;
-- Params for pa_startup.initialize call
l_calling_application		VARCHAR2(10)		:='PLSQL';
l_check_id_flag			VARCHAR2(1)		:= 'Y';
l_check_role_security_flag	VARCHAR2(1)		:= 'Y';
l_check_resource_security_flag	VARCHAR2(1)		:= 'Y';
l_calling_module		VARCHAR(10)		:= 'AMG';
--Looping params

i				NUMBER;
--Record Type
l_competence_in_rec		COMPETENCE_IN_REC_TYPE;
--Loop params
--Error Flags
l_local_error_flag		VARCHAR2(1);
l_error_flag			VARCHAR2(1);
-- Message Counters
l_start_msg_count		NUMBER ;
l_end_msg_count			NUMBER ;
l_loop_msg_count		NUMBER ;
-- Miss Params List
l_miss_params			VARCHAR2(2000);
--temp Params
l_requirement_id                NUMBER;
l_dummy                         NUMBER;
l_competence_element_id         NUMBER;
l_competence_id			NUMBER;
-- Security check Params
l_project_id			NUMBER :=NULL;
l_template_id			NUMBER :=NULL;
l_wf_progress_flag              VARCHAR2(1);
l_status_code                   VARCHAR2(10);
l_req_sys_status_code		VARCHAR2(30);
l_privilege			VARCHAR2(30);
l_object_name			VARCHAR2(30);
l_object_key			NUMBER;
l_ret_code			VARCHAR2(1);

l_msg_index_out                 NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_count                     NUMBER;
l_return_status                 VARCHAR2(1);

--Internal API calling Params
l_commit			VARCHAR2(1)             := FND_API.G_FALSE;
l_object_version_number		NUMBER;
l_data				VARCHAR2(2000);

-- Given Competence Element id this cursor is used to get the info about that
-- Perticulat competence
CURSOR cur_competence_details(l_competence_element_id NUMBER) IS
SELECT *
FROM PA_OPEN_ASGMT_COMPETENCES_V
WHERE competence_element_id = l_competence_element_id;

-- For Future developement
/*CURSOR cur_competence_details_alt(l_requirement_id NUMBER, l_competence_id NUMBER ) IS
SELECT *
FROM PA_OPEN_ASGMT_COMPETENCES_V
WHERE assignment_id = l_requirement_id
AND   competence_id=l_competence_id;*/


-- This cursor is used to get the information like which Requirement
-- competence belong to and validity .
CURSOR cur_assign_info (l_requirement_id IN NUMBER ) IS
SELECT project_id,assignment_template_id,status_code,mass_wf_in_progress_flag
FROM	pa_project_assignments
where assignment_id = l_requirement_id;

-- To get the project system status code for
-- perticular requirement.
CURSOR cur_status_code(l_status_code VARCHAR2  ) IS
SELECT project_system_status_code
FROM  pa_project_statuses
WHERE project_status_code = l_status_code;

-- To Hold the values used.
l_cur_competence_in_rec         PA_OPEN_ASGMT_COMPETENCES_V%ROWTYPE;

BEGIN
	--Flows which are supported by this API
	------------------------------------------------------
	-- User MUST PASS P_COMPETENCE_ELEMENT_ID
	-- Updating  a competence by Passing p_competence_element_id
	-- when competence alias is passed it will be replaced with the one from Data base.
	-- ie competence name will be ignore and will be replaced with Data base value.
	-- Only we will Allow Mandatery Flag and Rating level to be updated.

	--Flows which are not supported by this API
	----------------------------------------------------------
	-- Updating a Competence by Passing Combination of Requirement_id and one of the
	-- competence id or competence alias or competence name


	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_debug_mode  := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

	IF l_debug_mode = 'Y' THEN
		PA_DEBUG.set_curr_function(p_function => 'UPDATE_REQUIREMENT_COMPETENCE', p_debug_mode => l_debug_mode);
	END IF;

	-- Resetting the Error Stack.
	IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
		FND_MSG_PUB.initialize;
	END IF;

	IF P_COMMIT = FND_API.G_TRUE THEN
		SAVEPOINT UPDATE_REQU_COMPETENCE_SP;
	END IF ;

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module,'Save Point create ', l_debug_level);
	END IF ;

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module,'Start of UPDATE_REQUIREMENT_COMPETENCE ', l_debug_level);
	END IF ;

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module,'Before calling pa_startup.initialize ', l_debug_level);
	END IF ;

	PA_STARTUP.INITIALIZE(
		  p_calling_application			=> l_calling_application
		, p_calling_module			=> l_calling_module
		, p_check_id_flag			=> l_check_id_flag
		, p_check_role_security_flag		=> l_check_role_security_flag
		, p_check_resource_Security_flag	=> l_check_resource_Security_flag
		, p_debug_level				=> l_debug_level);

	IF l_debug_mode = 'Y' THEN
		 pa_debug.write(l_module,'After calling pa_startup.initialize ', l_debug_level);
	END IF ;

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module,'Printing Input Parameters......', l_debug_level);

		i := p_competence_in_tbl.first();

		WHILE i IS NOT NULL LOOP

			l_competence_in_rec := p_competence_in_tbl(i);

			pa_debug.write(l_module, 'Values for Record No :'|| i , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.requirement_id for record ' || i || l_competence_in_rec.requirement_id , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_element_id for record ' || i || l_competence_in_rec.competence_element_id  , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_id for record ' || i || l_competence_in_rec.competence_id	    , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_name for record ' || i || l_competence_in_rec.competence_name , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_alias for record ' || i || l_competence_in_rec.competence_alias , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.rating_level_id for record ' || i ||  l_competence_in_rec.rating_level_id , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.rating_level_value for record ' || i ||  l_competence_in_rec.rating_level_value , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.mandatory_flag for record ' || i ||  l_competence_in_rec.mandatory_flag , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.record_version_number for record ' || i ||  l_competence_in_rec.record_version_number , l_debug_level);

			i :=p_competence_in_tbl.next(i);
		END LOOP;

	END IF;

	i := p_competence_in_tbl.first();

	WHILE i IS NOT NULL LOOP

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'Inside Loop For Record  '|| i , l_debug_level);
		END IF ;
		-- setting the Params at the starting of the loop
		l_local_error_flag	:= 'N';
		l_start_msg_count	:= FND_MSG_PUB.count_msg;
		l_competence_in_rec	:= NULL ;
		l_miss_params		:= NULL;
		l_competence_in_rec	:= P_COMPETENCE_IN_TBL(i);

		IF l_competence_in_rec.competence_element_id IS NULL
		OR l_competence_in_rec.competence_element_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_miss_params := l_miss_params || 'P_COMPETENCE_ELEMENT_ID';
		END IF;

		IF l_miss_params IS NOT NULL THEN
			l_local_error_flag := 'Y';
 			PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
			'INVALID_PARAMS', l_miss_params);
		END IF;

		IF  l_local_error_flag <> 'Y' THEN
			-- Getting Requirement competence Details
			-- These variables are loaded
			l_requirement_id := l_competence_in_rec.requirement_id;
			l_competence_id  := l_competence_in_rec.competence_id;
			l_competence_element_id := l_competence_in_rec.competence_element_id;
			-- Getting the Data about competence
			IF l_competence_element_id IS NOT  NULL
			AND  l_competence_element_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  THEN

				OPEN cur_competence_details(l_competence_element_id);
				FETCH cur_competence_details INTO l_cur_competence_in_rec;
				-- checking the validity of l_competence_element_id
				IF cur_competence_details%NOTFOUND THEN
					l_local_error_flag := 'Y';
		       			l_miss_params := l_miss_params || 'P_COMPETENCE_ELEMENT_ID';
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                        'INVALID_PARAMS', l_miss_params);
				END IF;
				-- closing the cursor
				CLOSE cur_competence_details;
				--Loading the values with the existing Data Base Values
			/*for Future Devolopement
			ELSE
				OPEN cur_competence_details_alt(l_requirement_id,l_competence_id);
				FETCH cur_competence_details_alt INTO l_cur_competence_in_rec;
				-- checking the validity of l_requirement_id,l_competence_id
				IF cur_competence_details_alt%NOTFOUND THEN
					 l_local_error_flag := 'Y';
					 PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_ASGMT_ID');
				END IF;
				--Closing the cursor
				CLOSE cur_competence_details_alt;
				-- Populating the competence element id
				l_competence_in_rec.p_competence_element_id := l_cur_competence_in_rec.competence_element_id;
				l_competence_element_id := l_cur_competence_in_rec.competence_element_id;*/
			END IF;
		END IF;

		IF l_local_error_flag <> 'Y' THEN
                -- Loading the Competence Name and Alias with the Exiting values.
			l_requirement_id := l_cur_competence_in_rec.assignment_id;
			l_competence_in_rec.requirement_id := l_cur_competence_in_rec.assignment_id;
			l_competence_id  := l_cur_competence_in_rec.competence_id;
			l_competence_in_rec.competence_id := l_cur_competence_in_rec.competence_id;
			l_competence_in_rec.competence_name  := l_cur_competence_in_rec.competence_name;
			l_competence_in_rec.competence_alias := l_cur_competence_in_rec.competence_alias;

			IF l_competence_in_rec.record_version_number IS NULL
			OR l_competence_in_rec.record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

				l_competence_in_rec.record_version_number := l_cur_competence_in_rec.object_version_number;

			END IF;
		END IF;
                -- Taking care of miss char value..
		IF l_competence_in_rec.requirement_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.requirement_id	:= FND_API.G_MISS_NUM;
		END IF ;

		IF l_competence_in_rec.competence_element_id	= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.competence_element_id	:= FND_API.G_MISS_NUM;
		END IF;

		IF l_competence_in_rec.competence_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.competence_id := FND_API.G_MISS_NUM;
		END IF;

		IF l_competence_in_rec.competence_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_competence_in_rec.competence_name := FND_API.G_MISS_CHAR;
		END IF ;

		IF l_competence_in_rec.competence_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_competence_in_rec.competence_alias := FND_API.G_MISS_CHAR;
		END IF;

		IF l_competence_in_rec.rating_level_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.rating_level_id := FND_API.G_MISS_NUM;
		END IF;

		IF l_competence_in_rec.rating_level_value = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.rating_level_value := FND_API.G_MISS_NUM;
		END IF;

		IF l_competence_in_rec.mandatory_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_competence_in_rec.mandatory_flag :=FND_API.G_MISS_CHAR;
		END IF;

		IF l_competence_in_rec.record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_competence_in_rec.record_version_number :=FND_API.G_MISS_NUM;
		END IF;
		--- Security check

		IF l_local_error_flag <> 'Y' THEN

			OPEN cur_assign_info(l_requirement_id);
			FETCH cur_assign_info INTO l_project_id,l_template_id,l_status_code,l_wf_progress_flag;
			CLOSE cur_assign_info;

			OPEN cur_status_code(l_status_code);
			FETCH cur_status_code INTO l_req_sys_status_code;
			CLOSE cur_status_code;

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'Checking Security for record No'||i, l_debug_level);
			END IF;

			IF l_project_id IS NOT NULL THEN
				l_privilege := 'PA_ASN_BASIC_INFO_ED ';
				l_object_name := 'PA_PROJECTS';
				l_object_key := l_project_id;
			ELSIF l_template_id IS NOT NULL THEN
				l_privilege := 'PA_PRM_DEFINE_TEAM_TEMPLATE';
				l_object_name := null;
				l_object_key := null;
		        ELSE
                                -- This should never happen.
				PA_UTILS.ADD_MESSAGE('PA', 'PA_UNEXPECTED ERROR');
                                raise FND_API.G_EXC_ERROR;
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling  PA_SECURITY_PVT.CHECK_USER_PRIVILEGE for Record '||i||'with Following Values', l_debug_level);
				pa_debug.write(l_module, 'l_privilege'|| l_privilege, l_debug_level);
				pa_debug.write(l_module, 'l_object_name'||l_object_name, l_debug_level);
				pa_debug.write(l_module, 'l_object_key'||l_object_key, l_debug_level);
                        END IF;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

			-- Checking Security at project level or at Template level
                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                  x_ret_code       => l_ret_code
                                , x_return_status  => l_return_status
                                , x_msg_count      => l_msg_count
                                , x_msg_data       => l_msg_data
                                , p_privilege      => l_privilege
                                , p_object_name    => l_object_name
                                , p_object_key     => l_object_key
				,p_init_msg_list   => FND_API.G_FALSE);
			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'Return Status from PA_SECURITY_PVT.CHECK_USER_PRIVILEGE for Record '||i||'is l_return_status '|| l_return_status , l_debug_level);
				pa_debug.write(l_module, 'l_ret_code'|| l_ret_code, l_debug_level);
			END IF ;

			IF (nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS)
			AND l_project_id IS NOT NULL  THEN
			-- If project level security Fails wll call Requirement level Security
				IF l_debug_mode = 'Y' THEN
					pa_debug.write(l_module,'No Access Found at Project level checking at Requirement level', l_debug_level);
				END IF ;

				l_privilege := 'PA_ASN_BASIC_INFO_ED';
				l_object_name := 'PA_PROJECT_ASSIGNMENTS';
				l_object_key := l_requirement_id;
				PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
					  x_ret_code       => l_ret_code
					, x_return_status  => l_return_status
					, x_msg_count      => l_msg_count
					, x_msg_data       => l_msg_data
					, p_privilege      => l_privilege
					, p_object_name    => l_object_name
					, p_object_key     => l_object_key
					, p_init_msg_list   => FND_API.G_FALSE );

				IF l_debug_mode = 'Y' THEN
					pa_debug.write(l_module,'Return Status are Requirement level l_date return value l_ret_code'|| l_ret_code, l_debug_level);
				END IF ;

			END IF;

			IF (nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				-- This message does not have token defined, but intentionally putting token
                                -- bcoz we still want to show the privielge name which is missing
				PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_ADD_COMP'
						    ,'MISSING_PRIVILEGE', l_privilege);
                                l_local_error_flag := 'Y';
		        END IF ;
			-- checking Assignment Status.
			IF l_req_sys_status_code IN ('ASGMT_APPRVL_SUBMITTED', 'OPEN_ASGMT_FILLED', 'ASGMT_APPRVL_CANCELED') THEN
				 PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_STS_ACT_NOT_ALLW');
				 l_local_error_flag := 'Y';
			END IF ;
			-- Checking WF status..
			IF l_wf_progress_flag = 'Y' THEN
				PA_UTILS.ADD_MESSAGE('PA', 'PA_ASSIGNMENT_WF');
				l_local_error_flag := 'Y';
			END IF;

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'End of Security  check '|| l_ret_code, l_debug_level);
			END IF ;
		END IF;

		IF  l_local_error_flag <> 'Y' THEN
		  		-- No error occured.ie local error Flag is N
			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'Calling PA_COMPETENCE_PUB.UPDATE_COMPETENCE_ELEMENT ', l_debug_level);
			END IF ;

			l_return_status := FND_API.G_RET_STS_SUCCESS;

			PA_COMPETENCE_PUB.UPDATE_COMPETENCE_ELEMENT(
				  p_object_name		  =>'OPEN_ASSIGNMENT'
				, p_object_id		  => l_competence_in_rec.requirement_id
				, p_competence_id	  => l_competence_in_rec.competence_id
				, p_competence_alias	  => l_competence_in_rec.competence_alias
				, p_competence_name	  => l_competence_in_rec.competence_name
				, p_element_id		  => l_competence_in_rec.competence_element_id
				, p_rating_level_id	  => l_competence_in_rec.rating_level_id
				, p_rating_level_value	  => l_competence_in_rec.rating_level_value
				, p_mandatory_flag	  => l_competence_in_rec.mandatory_flag
				, p_init_msg_list         => 'F'
				, p_element_rowid	  => l_cur_competence_in_rec.row_id
				, p_commit		  => l_commit
				, p_validate_only	  => 'N'
				, p_object_version_number => l_competence_in_rec.record_version_number
				, x_object_version_number => l_object_version_number
				, x_msg_count		  => l_msg_count
				, x_msg_data		  => l_msg_data
				, x_return_status	  => l_return_status);

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'After Calling PA_COMPETENCE_PUB.UPDATE_COMPETENCE_ELEMENT ', l_debug_level);
				pa_debug.write(l_module, 'l_return_status '|| l_return_status || 'for record '|| i , l_debug_level);
			END IF ;
		END IF;-- end of API call..

		l_end_msg_count := FND_MSG_PUB.count_msg;
		l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

 		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module, 'Error Flag for Record '|| i || ' is l_local_error_flag  '|| l_local_error_flag , l_debug_level);
		END IF ;

		IF l_local_error_flag = 'Y' OR l_loop_msg_count > 0 THEN
			l_error_flag := 'Y';
			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'After Calling PA_COMPETENCE_PUB.UPDATE_COMPETENCE_ELEMENT ', l_debug_level);
			END IF ;
			FOR j in l_start_msg_count+1..l_end_msg_count LOOP
				FND_MSG_PUB.get (
					  p_msg_index      =>  l_start_msg_count+1
					, p_encoded        => FND_API.G_FALSE
					, p_data           => l_data
					, p_msg_index_out  => l_msg_index_out );

				FND_MSG_PUB.DELETE_MSG(p_msg_index =>  l_start_msg_count+1);
					-- Adding Record Number to The Message.
				PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
							'RECORD_NO', i,
							'MESSAGE', l_data);

			END LOOP;
		END IF;
		i := p_competence_in_tbl.next(i);
	END LOOP; -- end if Internal API call Loop

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module,'Out Of PA_COMPETENCE_PUB.UPDATE_COMPETENCE_ELEMENT  API calling Loop', l_debug_level);
	END IF ;

	IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF l_debug_mode = 'Y' THEN
		PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;

	IF p_commit = FND_API.G_TRUE THEN
		commit;
	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		l_msg_count := FND_MSG_PUB.count_msg;

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module,'In Side Exception Block FND_API.G_EXC_ERROR', l_debug_level);
			pa_debug.write(l_module,'Closing CURSORS if OPEN', l_debug_level);
		END IF ;

		IF cur_assign_info%ISOPEN THEN
			CLOSE cur_assign_info;
		END IF;

		IF cur_status_code%ISOPEN THEN
			CLOSE cur_status_code;
		END IF;

		IF cur_competence_details%ISOPEN THEN
			CLOSE cur_competence_details;
		END IF;

		IF p_commit = FND_API.G_TRUE THEN
			ROLLBACK TO UPDATE_REQU_COMPETENCE_SP;
		END IF;

		IF l_msg_count = 1 AND x_msg_data IS NULL THEN
			PA_INTERFACE_UTILS_PUB.GET_MESSAGES(
				  p_encoded        => FND_API.G_FALSE
				, p_msg_index      => 1
				, p_msg_count      => l_msg_count
				, p_msg_data       => l_msg_data
				, p_data           => l_data
				, p_msg_index_out  => l_msg_index_out);

			x_msg_data := l_data;
			x_msg_count := l_msg_count;
		ELSE
			x_msg_count := l_msg_count;
		END IF;

		IF l_debug_mode = 'Y' THEN
			PA_DEBUG.reset_curr_function;
		END IF;

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_msg_data      := SUBSTRB(SQLERRM,1,240);

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module,'In Side Exception Block others ', l_debug_level);
			pa_debug.write(l_module,'Closing CURSORS if OPEN', l_debug_level);
		END IF ;

		IF cur_assign_info%ISOPEN THEN
			CLOSE cur_assign_info;
		END IF;

		IF cur_status_code%ISOPEN THEN
			CLOSE cur_status_code;
		END IF;

		IF cur_competence_details%ISOPEN THEN
			CLOSE cur_competence_details;
		END IF;

		IF p_commit = FND_API.G_TRUE THEN
			ROLLBACK TO UPDATE_REQU_COMPETENCE_SP;
		END IF;

		FND_MSG_PUB.ADD_EXC_MSG(
			  p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
			, p_procedure_name      => 'CREATE_REQUIREMENT_COMPETENCE'
			, p_error_text          => x_msg_data);

		x_msg_count     := FND_MSG_PUB.count_msg;

		IF l_debug_mode = 'Y' THEN
			PA_DEBUG.reset_curr_function;
		END IF;
		RAISE;
END UPDATE_REQUIREMENT_COMPETENCE;

-- Start of comments
--	API name 	: DELETE_REQUIREMENT_COMPETENCE
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to create/nominate one or more candidates for
--			  project requirements.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are:	FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				P_COMPETENCE_IN_TBL	IN  COMPETENCE_IN_TBL_TYPE	Required
--					Table of competence records. Please see the COMPETENCE_IN_TBL_TYPE datatype table
--	OUT		:
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - vkadimes  - Created
-- End of comments
PROCEDURE DELETE_REQUIREMENT_COMPETENCE (
  p_commit		IN		VARCHAR2 :='F'
, p_init_msg_list	IN		VARCHAR2 := 'T'
, p_api_version_number	IN		NUMBER   := 1.0
, p_competence_in_tbl	IN		COMPETENCE_IN_TBL_TYPE
, x_return_status	OUT NOCOPY	VARCHAR2
, x_msg_count		OUT NOCOPY	NUMBER
, x_msg_data		OUT NOCOPY	VARCHAR2
) IS

-- Debug Level
l_module			VARCHAR2(255)		:= 'PA_RES_MANAGEMENT_AMG_PUB.DELETE_REQUIREMENT_COMPETENCE';
l_debug_mode			VARCHAR2(1);
l_debug_level			NUMBER			:=3;
-- Params for pa_startup.initialize call
l_calling_application		VARCHAR2(10)		:='PLSQL';
l_check_id_flag			VARCHAR2(1)		:= 'Y';
l_check_role_security_flag	VARCHAR2(1)		:= 'Y';
l_check_resource_security_flag	VARCHAR2(1)		:= 'Y';
l_calling_module		VARCHAR2(10)		:= 'AMG';
--Looping params
i				NUMBER;
--Record Type
l_competence_in_rec		COMPETENCE_IN_REC_TYPE;
--Error Flags
l_local_error_flag		VARCHAR2(1);
l_error_flag			VARCHAR2(1);
-- Message Counters
l_start_msg_count		NUMBER ;
l_end_msg_count			NUMBER ;
l_loop_msg_count		NUMBER ;
-- Miss Params List
l_miss_params			VARCHAR2(2000);
--temp Params
l_requirement_id                NUMBER;
l_dummy                         NUMBER;
l_competence_element_id         NUMBER;
l_competence_id			NUMBER;
-- Security check Params
l_project_id			NUMBER :=NULL;
l_template_id			NUMBER :=NULL;
l_wf_progress_flag              VARCHAR2(1);
l_status_code                   VARCHAR2(10);
l_req_sys_status_code		VARCHAR2(30);
l_privilege			VARCHAR2(30);
l_object_name			VARCHAR2(30);
l_object_key			NUMBER;
l_ret_code			VARCHAR2(1);
l_msg_index_out                 NUMBER;
l_msg_data                      VARCHAR2(2000);
l_msg_count                     NUMBER;
l_return_status                 VARCHAR2(1);
--Internal API calling Params
l_commit			VARCHAR2(1)             := FND_API.G_FALSE;
l_object_version_number		NUMBER;
l_data				VARCHAR2(2000);

-- Given Competence Element id this cursor is used to get the info about that
-- Perticulat competence
CURSOR cur_competence_details(l_competence_element_id NUMBER) IS
SELECT *
FROM PA_OPEN_ASGMT_COMPETENCES_V
WHERE competence_element_id = l_competence_element_id;


-- This cursor is used to get the information like which Requirement
-- competence belong to and validity .
CURSOR cur_assign_info (l_requirement_id IN NUMBER ) IS
SELECT project_id,assignment_template_id,status_code,mass_wf_in_progress_flag
FROM	pa_project_assignments
where assignment_id = l_requirement_id;

-- To get the project system status code for
-- perticular requirement.
CURSOR cur_status_code(l_status_code VARCHAR2  ) IS
SELECT project_system_status_code
FROM  pa_project_statuses
WHERE project_status_code = l_status_code
AND status_type= 'OPEN_ASGMT';

-- Record type
l_cur_competence_in_rec         PA_OPEN_ASGMT_COMPETENCES_V%ROWTYPE;

BEGIN
	-- Flows which are supported by this API
	-----------------------------------------
	--Deleting one competence from Both Project Requirement and Team Template Requirement by Passing
	--Competence_element_id.
	--Flows which are not supported by this API
	--------------------------------------------
	-- Deleting the Requirement by passing Requirement id and one of competence_id or competence alias or
	-- competence Name.

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_debug_mode    := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

	IF l_debug_mode = 'Y' THEN
		PA_DEBUG.set_curr_function(p_function => 'DELETE_REQUIREMENT_COMPETENCE', p_debug_mode => l_debug_mode);
	END IF;

	-- Resetting the Error Stack.
	IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
		FND_MSG_PUB.initialize;
	END IF;

	IF P_COMMIT = FND_API.G_TRUE THEN
		SAVEPOINT DELETE_REQU_COMPETENCE_SP;
	END IF ;

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module,'Save Point create ', l_debug_level);
		pa_debug.write(l_module,'Start of DELETE_REQUIREMENT_COMPETENCE ', l_debug_level);
		pa_debug.write(l_module,'Before calling pa_startup.initialize ', l_debug_level);
	END IF ;

	PA_STARTUP.INITIALIZE(
		   p_calling_application		=> l_calling_application
		 , p_calling_module			=> l_calling_module
		 , p_check_id_flag			=> l_check_id_flag
		 , p_check_role_security_flag		=> l_check_role_security_flag
		 , p_check_resource_Security_flag	=> l_check_resource_Security_flag
		 , p_debug_level			=> l_debug_level);

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module,'After calling pa_startup.initialize ', l_debug_level);
	END IF ;

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module,'Printing Input Parameters......', l_debug_level);

		i := p_competence_in_tbl.first();

		WHILE i IS NOT NULL LOOP

			l_competence_in_rec := p_competence_in_tbl(i);

			pa_debug.write(l_module,'Values for Record No :'|| i , l_debug_level);
			pa_debug.write(l_module,'l_competence_in_rec.requirement_id for record ' || i || l_competence_in_rec.requirement_id , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_element_id for record ' || i || l_competence_in_rec.competence_element_id  , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_id for record ' || i || l_competence_in_rec.competence_id	    , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_name for record ' || i || l_competence_in_rec.competence_name , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.competence_alias for record ' || i || l_competence_in_rec.competence_alias , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.rating_level_id for record ' || i ||  l_competence_in_rec.rating_level_id , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.rating_level_value for record ' || i ||  l_competence_in_rec.rating_level_value , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.mandatory_flag for record ' || i ||  l_competence_in_rec.mandatory_flag , l_debug_level);
			pa_debug.write(l_module, 'l_competence_in_rec.record_version_number for record ' || i ||  l_competence_in_rec.record_version_number , l_debug_level);

			i :=p_competence_in_tbl.next(i);

		END LOOP;

	END IF;

	i := p_competence_in_tbl.first();

	WHILE i IS NOT NULL LOOP

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module,'Inside Loop For Record  '|| i , l_debug_level);
		END IF ;
		-- Initializing the local Params for loop
		l_local_error_flag	:= 'N';
		l_start_msg_count	:= FND_MSG_PUB.count_msg;
		l_competence_in_rec	:= NULL ;
		l_miss_params		:= NULL;
		l_competence_in_rec	:= P_COMPETENCE_IN_TBL(i);
		-- check for missparams.......
		IF l_competence_in_rec.competence_element_id IS NULL OR
		   l_competence_in_rec.competence_element_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
			l_miss_params := l_miss_params || 'COMPETENCE_ELEMENT_ID';
		END IF;

		IF l_miss_params IS NOT NULL THEN
			l_local_error_flag := 'Y';
 			PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
			'INVALID_PARAMS', l_miss_params);
		END IF;

		IF  l_local_error_flag <> 'Y' THEN
			OPEN cur_competence_details(l_competence_in_rec.competence_element_id);
			FETCH cur_competence_details INTO l_cur_competence_in_rec;
			-- Checking for the validity of competence id
			IF cur_competence_details%NOTFOUND THEN
				l_local_error_flag := 'Y';
                                l_miss_params := l_miss_params || 'COMPETENCE_ELEMENT_ID';
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                'INVALID_PARAMS', l_miss_params);
			END IF;

			CLOSE cur_competence_details;
			-- Getting the requirement_id for that Record
			l_requirement_id := l_cur_competence_in_rec.assignment_id;

		END IF;

		IF  l_local_error_flag <> 'Y' THEN

			IF l_competence_in_rec.record_version_number IS NULL
			OR l_competence_in_rec.record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

				l_competence_in_rec.record_version_number :=l_cur_competence_in_rec.object_version_number;

			END IF;

			OPEN cur_assign_info(l_requirement_id);
			FETCH cur_assign_info INTO l_project_id,l_template_id,l_status_code,l_wf_progress_flag;
			CLOSE cur_assign_info;

			OPEN cur_status_code(l_status_code);
			FETCH cur_status_code INTO l_req_sys_status_code;
			CLOSE cur_status_code;

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'Checking Security for record No'||i, l_debug_level);
			END IF;

			IF l_project_id IS NOT NULL THEN
				l_privilege := 'PA_ASN_BASIC_INFO_ED ';
				l_object_name := 'PA_PROJECTS';
				l_object_key := l_project_id;
			ELSIF l_template_id IS NOT NULL THEN
				l_privilege := 'PA_PRM_DEFINE_TEAM_TEMPLATE';
				l_object_name := null;
				l_object_key := null;
		        ELSE
                                -- This should never happen.
				PA_UTILS.ADD_MESSAGE('PA', 'PA_UNEXPECTED ERROR');
                                raise FND_API.G_EXC_ERROR;
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling  PA_SECURITY_PVT.CHECK_USER_PRIVILEGE for Record '||i||'with Following Values', l_debug_level);
				pa_debug.write(l_module, 'l_privilege'|| l_privilege, l_debug_level);
				pa_debug.write(l_module, 'l_object_name'||l_object_name, l_debug_level);
				pa_debug.write(l_module, 'l_object_key'||l_object_key, l_debug_level);
                        END IF;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

			-- Checking Security at project level or at Template level
                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                  x_ret_code       => l_ret_code
                                , x_return_status  => l_return_status
                                , x_msg_count      => l_msg_count
                                , x_msg_data       => l_msg_data
                                , p_privilege      => l_privilege
                                , p_object_name    => l_object_name
                                , p_object_key     => l_object_key
				,p_init_msg_list   => FND_API.G_FALSE);

                         IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Return Status from PA_SECURITY_PVT.CHECK_USER_PRIVILEGE for Record '||i||'is l_return_status '|| l_return_status , l_debug_level);
				pa_debug.write(l_module, 'l_ret_code'|| l_ret_code, l_debug_level);
			 END IF ;

			IF (nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS)
			AND l_project_id IS NOT NULL  THEN
			-- If project level security Fails wll call Requirement level Security
				IF l_debug_mode = 'Y' THEN
					 pa_debug.write(l_module,'No Access Found at Project level checking at Requirement level', l_debug_level);
				END IF ;

				l_privilege := 'PA_ASN_BASIC_INFO_ED';
				l_object_name := 'PA_PROJECT_ASSIGNMENTS';
				l_object_key := l_requirement_id;
				PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
					  x_ret_code       => l_ret_code
					, x_return_status  => l_return_status
					, x_msg_count      => l_msg_count
					, x_msg_data       => l_msg_data
					, p_privilege      => l_privilege
					, p_object_name    => l_object_name
					, p_object_key     => l_object_key
					, p_init_msg_list   => FND_API.G_FALSE );

				IF l_debug_mode = 'Y' THEN
					pa_debug.write(l_module,'Return Status are Requirement level l_date return value l_ret_code'|| l_ret_code, l_debug_level);
				END IF ;

			END IF;

			IF (nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				-- This message does not have token defined, but intentionally putting token
                                -- bcoz we still want to show the privielge name which is missing
				PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_ADD_COMP'
						    ,'MISSING_PRIVILEGE', l_privilege);
                                l_local_error_flag := 'Y';
		        END IF ;
			-- checking Assignment Status.
			IF l_req_sys_status_code IN ('ASGMT_APPRVL_SUBMITTED','OPEN_ASGMT_FILLED', 'ASGMT_APPRVL_CANCELED') THEN
	                     -- Need more specific message saying.. cant edit assignment.
				 PA_UTILS.ADD_MESSAGE('PA','PA_ASSIGNMENT_WF');
				 l_local_error_flag := 'Y';
			END IF ;
			-- Checking WF status..
			IF l_wf_progress_flag = 'Y' THEN
				PA_UTILS.ADD_MESSAGE('PA','PA_ASSIGNMENT_WF');
				l_local_error_flag := 'Y';
			END IF;

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'End of Security  check '|| l_ret_code, l_debug_level);
			END IF ;
		END IF;
		-- Nulling out the Params as they will not be used.
		l_competence_in_rec.requirement_id     := l_cur_competence_in_rec.assignment_id;
		l_competence_in_rec.competence_id      := l_cur_competence_in_rec.competence_id;
		l_competence_in_rec.competence_alias   := NULL;
		l_competence_in_rec.competence_name	 := NULL;
		l_competence_in_rec.rating_level_id	 := NULL;
		l_competence_in_rec.rating_level_value := NULL;
		l_competence_in_rec.mandatory_flag     := NULL;

		IF  l_local_error_flag <> 'Y' THEN
		  		-- No error occured.ie local error Flag is N
			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'Calling PA_COMPETENCE_PUB.DELETE_COMPETENCE_ELEMENT', l_debug_level);
			END IF ;

			l_return_status := FND_API.G_RET_STS_SUCCESS;

			PA_COMPETENCE_PUB.DELETE_COMPETENCE_ELEMENT(
				  p_object_name			=> 'OPEN_ASSIGNMENT'
				, p_object_id			=> l_competence_in_rec.requirement_id
				, p_competence_id		=> l_competence_in_rec.competence_id
				, p_competence_alias		=> l_competence_in_rec.competence_alias
				, p_competence_name		=> l_competence_in_rec.competence_name
				, p_element_rowid		=> l_cur_competence_in_rec.row_id
				, p_element_id			=> l_competence_in_rec.competence_element_id
				, p_init_msg_list		=> 'F'
				, p_commit			=> l_commit
				, p_validate_only		=> 'F'
				, p_object_version_number	=>l_competence_in_rec.record_version_number
				, x_return_status		=> l_return_status
				, x_msg_count			=> l_msg_count
				, x_msg_data			=> l_msg_data);

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module,'After Calling PA_COMPETENCE_PUB.DELETE_COMPETENCE_ELEMENT ', l_debug_level);
				pa_debug.write(l_module,'l_return_status '|| l_return_status || 'for record '|| i , l_debug_level);
			END IF ;

		END IF;-- end of API call..

		l_end_msg_count := FND_MSG_PUB.count_msg;
		l_loop_msg_count := l_end_msg_count -  l_start_msg_count;

 		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module,'Error Flag for Record '|| i || ' is l_local_error_flag  '|| l_local_error_flag , l_debug_level);
		END IF ;

		IF l_local_error_flag = 'Y' OR l_loop_msg_count > 0 THEN
			l_error_flag := 'Y';
			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module,'After Calling PA_COMPETENCE_PUB.DELETE_COMPETENCE_ELEMENT ', l_debug_level);
			END IF ;
			FOR j in l_start_msg_count+1..l_end_msg_count LOOP
				FND_MSG_PUB.GET (
					  p_msg_index      =>  l_start_msg_count+1
					, p_encoded        => FND_API.G_FALSE
					, p_data           => l_data
					, p_msg_index_out  => l_msg_index_out );

				FND_MSG_PUB.DELETE_MSG(p_msg_index =>  l_start_msg_count+1);
					-- Adding Record Number to The Message.
				PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
							'RECORD_NO', i,
							'MESSAGE', l_data);
			END LOOP;
		END IF;
			i := p_competence_in_tbl.next(i);
	END LOOP; -- end if Internal API call Loop

	IF l_debug_mode = 'Y' THEN
		pa_debug.write(l_module,'Out Of PA_COMPETENCE_PUB.DELETE_COMPETENCE_ELEMENT  API calling Loop', l_debug_level);
	END IF ;

	IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
		RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF l_debug_mode = 'Y' THEN
              PA_DEBUG.RESET_CURR_FUNCTION;
        END IF;

	IF p_commit = FND_API.G_TRUE THEN
		commit;
	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		l_msg_count := FND_MSG_PUB.count_msg;

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module,'In Side Exception Block FND_API.G_EXC_ERROR', l_debug_level);
			pa_debug.write(l_module,'Closing CURSORS if OPEN', l_debug_level);
		END IF ;

		IF cur_assign_info%ISOPEN THEN
			CLOSE cur_assign_info;
		END IF;

		IF cur_status_code%ISOPEN THEN
			CLOSE cur_status_code;
		END IF;

		IF cur_competence_details%ISOPEN THEN
			CLOSE cur_competence_details;
		END IF;

		IF p_commit = FND_API.G_TRUE THEN
			ROLLBACK TO DELETE_REQU_COMPETENCE_SP;
		END IF;

		IF l_msg_count = 1 AND x_msg_data IS NULL THEN
			PA_INTERFACE_UTILS_PUB.GET_MESSAGES(
				  p_encoded        => FND_API.G_FALSE
				, p_msg_index      => 1
				, p_msg_count      => l_msg_count
				, p_msg_data       => l_msg_data
				, p_data           => l_data
				, p_msg_index_out  => l_msg_index_out);

			x_msg_data := l_data;
			x_msg_count := l_msg_count;
		ELSE
			x_msg_count := l_msg_count;
		END IF;

		IF l_debug_mode = 'Y' THEN
			PA_DEBUG.reset_curr_function;
		END IF;

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		x_msg_data      := SUBSTRB(SQLERRM,1,240);

		IF l_debug_mode = 'Y' THEN
			pa_debug.write(l_module,'In Side Exception Block others ', l_debug_level);
			pa_debug.write(l_module,'Closing CURSORS if OPEN', l_debug_level);
		END IF ;

		IF cur_assign_info%ISOPEN THEN
			CLOSE cur_assign_info;
		END IF;

		IF cur_status_code%ISOPEN THEN
			CLOSE cur_status_code;
		END IF;

		IF cur_competence_details%ISOPEN THEN
			CLOSE cur_competence_details;
		END IF;

		IF p_commit = FND_API.G_TRUE THEN
			ROLLBACK TO DELETE_REQU_COMPETENCE_SP;
		END IF;

		FND_MSG_PUB.ADD_EXC_MSG(
			  p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
			, p_procedure_name      => 'CREATE_REQUIREMENT_COMPETENCE'
			, p_error_text          => x_msg_data);

		x_msg_count     := FND_MSG_PUB.count_msg;

		IF l_debug_mode = 'Y' THEN
			PA_DEBUG.reset_curr_function;
		END IF;

		RAISE;

END DELETE_REQUIREMENT_COMPETENCE;

-- Start of comments
--	API name 	: CREATE_CANDIDATES
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to create/nominate one or more candidates for
--			  project requirements.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are:	FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_candidate_in_tbl	IN  CANDIDATE_IN_TBL_TYPE	Required
--					Table of candidate records. Please see the CANDIDATE_IN_TBL_TYPE datatype table.
--	OUT		:
--				x_candidate_id_tbl	OUT SYSTEM.PA_NUM_TBL_TYPE
--					Table to store the candidate ids created by the API.
--					Reference : pa_candidates.candidate_id
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - msachan  - Created
-- End of comments
PROCEDURE CREATE_CANDIDATES
(
  p_commit		        IN		VARCHAR2 := FND_API.G_FALSE
, p_init_msg_list	        IN		VARCHAR2 := FND_API.G_TRUE
, p_api_version_number	        IN		NUMBER   := 1.0
, p_candidate_in_tbl	        IN		CANDIDATE_IN_TBL_TYPE
, x_candidate_id_tbl	        OUT     NOCOPY	SYSTEM.PA_NUM_TBL_TYPE
, x_return_status	        OUT     NOCOPY	VARCHAR2
, x_msg_count		        OUT     NOCOPY 	NUMBER
, x_msg_data		        OUT     NOCOPY 	VARCHAR2
)
IS
	l_debug_mode                    VARCHAR2(1);
        l_module                        VARCHAR2(100)           := 'PA_CANDIDATE_AMG_PUB.CREATE_CANDIDATES';
	l_calling_application           VARCHAR2(10)            := 'PLSQL';
        l_calling_module                VARCHAR2(10)            := 'AMG';
        l_check_id_flag                 VARCHAR2(1)             := 'Y';
        l_check_role_security_flag      VARCHAR2(1)             := 'Y';
        l_check_resource_security_flag  VARCHAR2(1)             := 'Y';
	l_log_level                     NUMBER                  := 3;

	i                               NUMBER;
	l_missing_params                VARCHAR2(1000);
	l_project_system_status_code	VARCHAR2(30);
	l_error_flag_local		VARCHAR2(1)             := 'N';
	l_error_flag			VARCHAR2(1)             := 'N';
	l_start_msg_count               NUMBER                  := 0;
	l_end_msg_count                 NUMBER                  := 0;
	l_loop_msg_count                NUMBER                  := 0;
	l_candidate_in_rec		CANDIDATE_IN_REC_TYPE;
	l_project_id			NUMBER;
	l_privilege                     VARCHAR2(30);
        l_object_name                   VARCHAR2(30);
        l_object_key                    NUMBER;
	l_resource_valid                VARCHAR2(1)             := 'N';
	l_privilege_name		VARCHAR2(40)		:= null;
	l_project_super_user            VARCHAR2(1)             := 'N';
        l_ret_code                      VARCHAR2(1);
	l_person_id                     NUMBER;
	l_logged_person_id		NUMBER;
	l_asmt_start_date		DATE;
	l_resource_start_date		DATE;
	l_resource_end_date		DATE;
	l_requirement_start_date	DATE;
	l_requirement_end_date		DATE;
        l_status_code                   VARCHAR2(30);
        l_system_status_code            VARCHAR2(30);
        l_mass_wf_in_progress_flag      VARCHAR2(1);
	l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
	l_msg_count                     NUMBER;
	l_msg_data                      VARCHAR2(2000);
	l_msg_index_out                 NUMBER;
	l_data                          VARCHAR2(2000);

CURSOR c_get_requirement_info(c_assignment_id NUMBER) IS
SELECT project_id, start_date, status_code, mass_wf_in_progress_flag
FROM   pa_project_assignments
WHERE  assignment_id = c_assignment_id
AND    assignment_type = 'OPEN_ASSIGNMENT';

CURSOR c_get_system_status_code(c_status_code VARCHAR2, c_status_type VARCHAR2) IS
SELECT project_system_status_code
FROM pa_project_statuses
WHERE  trunc(SYSDATE) BETWEEN start_date_active AND nvl(end_date_active, trunc(SYSDATE))
AND    status_type = c_status_type
AND    project_status_code = c_status_code;

CURSOR c_get_resource_info(c_resource_id NUMBER) IS
SELECT resource_source_id
FROM   pa_c_elig_resource_v
WHERE  resource_id = c_resource_id;

CURSOR c_get_person_id(c_user_id NUMBER) IS
SELECT employee_id
FROM   fnd_user
WHERE  user_id = c_user_id;

CURSOR c_get_candidate_id(c_assignment_id NUMBER, c_resource_id NUMBER) IS
SELECT candidate_id
FROM   pa_candidates
WHERE  assignment_id = c_assignment_id
AND    resource_id   = c_resource_id;

BEGIN

	--Flows which are supported by this API
		  ---------------------------------------
		  --1. Creating candidates for given open requirements.
		  --        1.1 Validating requirement_id
		  --        1.2 Validating resource_id if it is not null
		  --        1.3 Validating status_code to be a valid code
		  --        1.3 Given requirement id and either of resource_id or person_id, a candidate is created for that open requirement
		  --        1.4 Returning table return the candidate_id of the candidates created.
	--Flows which are not supported by this API
		  -------------------------------------------
		  --1. Validating person_id is not done in this api. It is handled by the called public api.

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_candidate_id_tbl := SYSTEM.PA_NUM_TBL_TYPE();

        l_debug_mode  := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'CREATE_CANDIDATES', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint CREATE_CANDIDATES_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of CREATE_CANDIDATES', l_log_level);
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Printing Input Parameters......', l_log_level);
		pa_debug.write(l_module, 'p_commit '||p_commit, l_log_level);
		pa_debug.write(l_module, 'p_init_msg_list '||p_init_msg_list, l_log_level);
		pa_debug.write(l_module, 'p_api_version_number '||p_api_version_number, l_log_level);
                pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                i := p_candidate_in_tbl.first;
                WHILE i IS NOT NULL LOOP
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').candidate_id '||p_candidate_in_tbl(i).candidate_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').requirement_id '||p_candidate_in_tbl(i).requirement_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').resource_id '||p_candidate_in_tbl(i).resource_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').person_id '||p_candidate_in_tbl(i).person_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').status_code '||p_candidate_in_tbl(i).status_code, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').nomination_comments '||p_candidate_in_tbl(i).nomination_comments, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').ranking '||p_candidate_in_tbl(i).ranking, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').change_reason_code '||p_candidate_in_tbl(i).change_reason_code, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').record_version_number '||p_candidate_in_tbl(i).record_version_number, l_log_level);
                        pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                        i := p_candidate_in_tbl.next(i);
                END LOOP;
        END IF;

        PA_STARTUP.INITIALIZE(
                  p_calling_application		 => l_calling_application
                , p_calling_module		 => l_calling_module
                , p_check_id_flag		 => l_check_id_flag
                , p_check_role_security_flag	 => l_check_role_security_flag
                , p_check_resource_security_flag => l_check_resource_security_flag
                , p_debug_level			 => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of PA_STARTUP.INITIALIZE', l_log_level);
        END IF;

        --l_prm_license_flag  := nvl(FND_PROFILE.VALUE('PA_PRM_LICENSED'),'N');
        --IF l_prm_license_flag <> 'Y' THEN
        --        null;
        --END IF;

        l_project_super_user := FND_PROFILE.value_specific('PA_SUPER_PROJECT',fnd_global.user_id,fnd_global.login_id,275,null,null);

        i := p_candidate_in_tbl.first;

        WHILE i is not NULL LOOP

                l_missing_params := null;
                l_error_flag_local := 'N';
                l_start_msg_count := FND_MSG_PUB.count_msg;

                l_candidate_in_rec := p_candidate_in_tbl(i);

	        IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Record#'||i, l_log_level);
                        pa_debug.write(l_module, '---------------------------------------------------------', l_log_level);
	                pa_debug.write(l_module, 'Inside while loop. Blanking out the parameters not passed', l_log_level);
		END IF;

                -- Blank Out Parameters if not passed
		-------------------------------------
                IF l_candidate_in_rec.requirement_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_candidate_in_rec.requirement_id := null;
                END IF;

                IF l_candidate_in_rec.resource_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_candidate_in_rec.resource_id := null;
                END IF;

                IF l_candidate_in_rec.person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
                        l_candidate_in_rec.person_id := null;
                END IF;

                IF l_candidate_in_rec.status_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_candidate_in_rec.status_code := 107; -- Default to Pending Review
                END IF;

                IF l_candidate_in_rec.nomination_comments = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                        l_candidate_in_rec.nomination_comments := null;
                END IF;

		-- Null out the parameters which are not required in create flow
                l_candidate_in_rec.candidate_id := null;
                l_candidate_in_rec.ranking := null;
                l_candidate_in_rec.change_reason_code := null;
                l_candidate_in_rec.record_version_number := null;

	        IF l_debug_mode = 'Y' THEN
	                pa_debug.write(l_module, 'Blanking out missing and not required parameters over.', l_log_level);
	                pa_debug.write(l_module, 'Mandatory parameters validation begin.', l_log_level);
	        END IF;

                -- Mandatory Parameters Check
		-----------------------------
                IF l_candidate_in_rec.requirement_id IS NULL THEN
                        l_missing_params := l_missing_params||', REQUIREMENT_ID';
		ELSE
			-- Check for requirement id valid and assignment type OPEN_ASSIGNMENT
                        l_status_code := null;
                        l_mass_wf_in_progress_flag := null;
                        l_system_status_code := null;

			OPEN c_get_requirement_info(l_candidate_in_rec.requirement_id);
			FETCH c_get_requirement_info INTO l_project_id, l_requirement_start_date, l_status_code, l_mass_wf_in_progress_flag;
			IF c_get_requirement_info%NOTFOUND IS NULL THEN
                                l_missing_params := l_missing_params||', REQUIREMENT_ID';
                        ELSE
                                l_system_status_code := null;
                                OPEN c_get_system_status_code(l_status_code, 'OPEN_ASGMT');
                                FETCH c_get_system_status_code INTO l_system_status_code;
                                CLOSE c_get_system_status_code;

                                IF l_system_status_code IN ('OPEN_ASGMT_FILLED','OPEN_ASGMT_CANCEL') THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_STS_ACT_NOT_ALLW');
                                        l_error_flag_local := 'Y';
                                END IF;

                                IF nvl(l_mass_wf_in_progress_flag, 'N') = 'Y' THEN
                                        PA_UTILS.ADD_MESSAGE('PA', 'PA_ASSIGNMENT_WF');
                                        l_error_flag_local := 'Y';
                                END IF;
			END IF;
			CLOSE c_get_requirement_info;
                END IF;

                IF l_candidate_in_rec.resource_id IS NULL AND l_candidate_in_rec.person_id IS NULL THEN
                        l_missing_params := l_missing_params||', RESOURCE_ID, PERSON_ID';
                END IF;

                IF l_candidate_in_rec.status_code IS NOT NULL THEN
			l_project_system_status_code := null;
			OPEN  c_get_system_status_code(l_candidate_in_rec.status_code, 'CANDIDATE');
			FETCH c_get_system_status_code INTO l_project_system_status_code;
			CLOSE c_get_system_status_code;
			IF l_project_system_status_code IS NULL OR l_project_system_status_code NOT IN ('CANDIDATE_PENDING_REVIEW', 'CANDIDATE_UNDER_REVIEW', 'CANDIDATE_SUITABLE') THEN
				l_missing_params := l_missing_params||', STATUS_CODE';
			END IF;
                END IF;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory parameter validation over. l_missing_params='||l_missing_params, l_log_level);
                END IF;

                IF l_missing_params IS NOT NULL THEN
                        l_error_flag_local := 'Y';
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                END IF;


		-- Validate resource id and/or person id
		----------------------------------------
		IF l_error_flag_local <> 'Y' THEN
			IF l_candidate_in_rec.resource_id IS NOT NULL THEN
				OPEN c_get_resource_info(l_candidate_in_rec.resource_id);
                                FETCH c_get_resource_info INTO l_person_id;
				IF c_get_resource_info%NOTFOUND IS NULL THEN
	                                l_error_flag_local := 'Y';
					PA_UTILS.ADD_MESSAGE ( p_app_short_name => 'PA'
						              ,p_msg_name       => 'PA_RESOURCE_INVALID_AMBIGUOUS' );
				END IF;
                                CLOSE c_get_resource_info;
			ELSIF l_candidate_in_rec.person_id IS NOT NULL THEN
				l_person_id := l_candidate_in_rec.person_id;
			ELSE
				l_error_flag_local := 'Y';
			END IF;
		END IF;

		-- Security Check
                -----------------
		-- Check PA_CREATE_CANDIDATES privilege on PA_PROJECTS and PA_PROJECT_ASSIGNMENTS as done in AddCandidatesTopCO.java
                IF l_error_flag_local <> 'Y' THEN

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Checking PA_CREATE_CANDIDATES privilege on PA_PROJECTS and PA_PROJECT_ASSIGNMENTS for record#'||i, l_log_level);
                        END IF;

                        l_privilege   := 'PA_CREATE_CANDIDATES';
                        l_object_name := 'PA_PROJECTS';
			l_object_key  := l_project_id;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                  x_ret_code       => l_ret_code
                                , x_return_status  => l_return_status
                                , x_msg_count      => l_msg_count
                                , x_msg_data       => l_msg_data
                                , p_privilege      => l_privilege
                                , p_object_name    => l_object_name
                                , p_object_key     => l_object_key
				, p_init_msg_list  => FND_API.G_FALSE);

                        IF nvl(l_ret_code, 'F') = 'F' AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	                        l_privilege   := 'PA_CREATE_CANDIDATES';
			        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
		                l_object_key  := l_candidate_in_rec.requirement_id;

	                        l_return_status := FND_API.G_RET_STS_SUCCESS;
		                l_ret_code := 'T';

			        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
				          x_ret_code       => l_ret_code
					, x_return_status  => l_return_status
	                                , x_msg_count      => l_msg_count
		                        , x_msg_data       => l_msg_data
			                , p_privilege      => l_privilege
				        , p_object_name    => l_object_name
	                                , p_object_key     => l_object_key
					, p_init_msg_list  => FND_API.G_FALSE);
			END IF;
			IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                -- This message does not have token defined, but intentionally putting token
                                -- bcoz we still want to show the privielge name which is missing
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_ADD_CAND'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                l_error_flag_local := 'Y';
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Security check complete for record#'||i||' privilege '||l_ret_code, l_log_level);
                        END IF;

                END IF;

		-- Check whether the user has resource authority over nominee
		-------------------------------------------------------------
		IF l_project_super_user <> 'Y' AND l_error_flag_local <> 'Y' AND l_candidate_in_rec.resource_id IS NOT NULL THEN

		        IF l_debug_mode = 'Y' THEN
		                pa_debug.write(l_module, 'If not project super user then check for confirmed assignment', l_log_level);
			END IF;

			OPEN c_get_person_id(FND_GLOBAL.USER_ID);
			FETCH c_get_person_id INTO l_logged_person_id;
			CLOSE c_get_person_id;

			IF l_logged_person_id <> l_person_id THEN
				l_privilege_name := 'PA_NOMINATE_CANDIDATES';
			ELSE l_privilege_name := 'PA_NOMINATE_SELF_AS_CANDIDATE';
			END IF;

			PA_SECURITY_PVT.CHECK_CONFIRM_ASMT(p_project_id      => -999,
							   p_resource_id     => l_candidate_in_rec.resource_id,
		                                           p_resource_name   => null,
				                           p_privilege       => l_privilege_name,
						           p_start_date      => l_requirement_start_date,
		                                           x_ret_code        => l_ret_code,
		                                           x_return_status   => l_return_status,
			                                   x_msg_count       => l_msg_count,
				                           x_msg_data        => l_msg_data);

                        IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                l_error_flag_local := 'Y';
				PA_UTILS.ADD_MESSAGE ( p_app_short_name => 'PA'
					              ,p_msg_name       => 'PA_NO_RESOURCE_AUTHORITY' );
                        END IF;

			IF l_debug_mode = 'Y' THEN
			        pa_debug.write(l_module, 'After call of PA_SECURITY_PVT.CHECK_CONFIRM_ASMT', l_log_level);
		        END IF;

		END IF;

                IF l_error_flag_local <> 'Y' THEN
                        -- Core API call
			IF l_debug_mode = 'Y' THEN
			        pa_debug.write(l_module, 'Calling core API PA_CANDIDATE_PUB.ADD_CANDIDATE', l_log_level);
		        END IF;

                        PA_CANDIDATE_PUB.ADD_CANDIDATE(
                                p_assignment_id         => l_candidate_in_rec.requirement_id,
                                p_resource_name         => null,
                                -- p_resource_id           => l_candidate_in_rec.resource_id,
                                -- for bug#8280206. resource id should be passed as null from create AMG API
                                p_resource_id           => null,
                                p_status_code           => l_candidate_in_rec.status_code,
                                p_nomination_comments   => l_candidate_in_rec.nomination_comments,
                                p_person_id             => l_person_id,
                                p_privilege_name        => l_privilege_name,
                                p_project_super_user    => l_project_super_user,
				p_init_msg_list		=> FND_API.G_FALSE,
				-- Added for bug 9187892
                                p_attribute_category    => l_candidate_in_rec.attribute_category,
                                p_attribute1            => l_candidate_in_rec.attribute1,
                                p_attribute2            => l_candidate_in_rec.attribute2,
                                p_attribute3            => l_candidate_in_rec.attribute3,
                                p_attribute4            => l_candidate_in_rec.attribute4,
                                p_attribute5            => l_candidate_in_rec.attribute5,
                                p_attribute6            => l_candidate_in_rec.attribute6,
                                p_attribute7            => l_candidate_in_rec.attribute7,
                                p_attribute8            => l_candidate_in_rec.attribute8,
                                p_attribute9            => l_candidate_in_rec.attribute9,
                                p_attribute10           => l_candidate_in_rec.attribute10,
                                p_attribute11           => l_candidate_in_rec.attribute11,
                                p_attribute12           => l_candidate_in_rec.attribute12,
                                p_attribute13           => l_candidate_in_rec.attribute13,
                                p_attribute14           => l_candidate_in_rec.attribute14,
                                p_attribute15           => l_candidate_in_rec.attribute15,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data);
			IF l_debug_mode = 'Y' THEN
		                pa_debug.write(l_module, 'After call PA_CANDIDATE_PUB.ADD_CANDIDATE l_return_status='||l_return_status, l_log_level);
	                END IF;
			IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
				x_candidate_id_tbl.extend(1);
				OPEN c_get_candidate_id(l_candidate_in_rec.requirement_id, l_candidate_in_rec.resource_id);
				FETCH c_get_candidate_id INTO x_candidate_id_tbl(x_candidate_id_tbl.COUNT);
				CLOSE c_get_candidate_id;
			ELSE
				l_error_flag_local := 'Y';
				x_candidate_id_tbl.extend(1);
				x_candidate_id_tbl(x_candidate_id_tbl.COUNT) := -1;
			END IF;
		ELSE
			x_candidate_id_tbl.extend(1);
			x_candidate_id_tbl(x_candidate_id_tbl.COUNT) := -1;
                END IF;

                l_end_msg_count := FND_MSG_PUB.count_msg;
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'l_start_msg_count='||l_start_msg_count, l_log_level);
                        pa_debug.write(l_module, 'l_end_msg_count='||l_end_msg_count, l_log_level);
                END IF;
		l_loop_msg_count := l_end_msg_count - l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

			IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Repopulating Error Message Stack', l_log_level);
                        END IF;

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;

			IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Repopulating Error Message Stack', l_log_level);
                        END IF;

		END IF;
                i := p_candidate_in_tbl.next(i);
        END LOOP;

	IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'All records are done', l_log_level);
                pa_debug.write(l_module, 'l_error_flag='||l_error_flag, l_log_level);
                pa_debug.write(l_module, 'FND_MSG_PUB.count_msg='||FND_MSG_PUB.count_msg, l_log_level);
        END IF;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

	IF c_get_requirement_info%ISOPEN THEN
		CLOSE c_get_requirement_info;
	END IF;

	IF c_get_system_status_code%ISOPEN THEN
		CLOSE c_get_system_status_code;
	END IF;

	IF c_get_resource_info%ISOPEN THEN
		CLOSE c_get_resource_info;
	END IF;

	IF c_get_person_id%ISOPEN THEN
		CLOSE c_get_person_id;
	END IF;

	IF c_get_candidate_id%ISOPEN THEN
		CLOSE c_get_candidate_id;
	END IF;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO CREATE_CANDIDATES_SP;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTRB(SQLERRM,1,240);

	IF c_get_requirement_info%ISOPEN THEN
		CLOSE c_get_requirement_info;
	END IF;

	IF c_get_system_status_code%ISOPEN THEN
		CLOSE c_get_system_status_code;
	END IF;

	IF c_get_resource_info%ISOPEN THEN
		CLOSE c_get_resource_info;
	END IF;

	IF c_get_person_id%ISOPEN THEN
		CLOSE c_get_person_id;
	END IF;

	IF c_get_candidate_id%ISOPEN THEN
		CLOSE c_get_candidate_id;
	END IF;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO CREATE_CANDIDATES_SP;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'CREATE_CANDIDATES'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;

END CREATE_CANDIDATES;

-- Start of comments
--	API name 	: UPDATE_CANDIDATES
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to update one or more candidates for project requirements.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are:	FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_candidate_in_tbl	IN  CANDIDATE_IN_TBL_TYPE	Required
--					Table of candidate records. Please see the CANDIDATE_IN_TBL_TYPE datatype table.
--	OUT		:
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - msachan  - Created
-- End of comments
PROCEDURE UPDATE_CANDIDATES
(
  p_commit		        IN		VARCHAR2 := FND_API.G_FALSE
, p_init_msg_list	        IN		VARCHAR2 := FND_API.G_TRUE
, p_api_version_number	        IN		NUMBER   := 1.0
, p_candidate_in_tbl	        IN		CANDIDATE_IN_TBL_TYPE
, x_return_status	        OUT     NOCOPY	VARCHAR2
, x_msg_count		        OUT     NOCOPY	NUMBER
, x_msg_data		        OUT     NOCOPY	VARCHAR2
)
IS
	l_debug_mode                    VARCHAR2(1);
        l_module                        VARCHAR2(100)           := 'PA_CANDIDATE_AMG_PUB.UPDATE_CANDIDATES';
	l_calling_application           VARCHAR2(10)            := 'PLSQL';
	l_calling_module                VARCHAR2(10)            := 'AMG';
	l_check_id_flag                 VARCHAR2(1)             := 'Y';
	l_check_role_security_flag      VARCHAR2(1)             := 'Y';
	l_check_resource_security_flag  VARCHAR2(1)             := 'Y';
	l_log_level                     NUMBER                  := 3;
	i                               NUMBER;
	l_error_flag                    VARCHAR2(1)             := 'N';
	l_error_flag_local              VARCHAR2(1)             := 'N';
	l_missing_params                VARCHAR2(1000);
	l_candidate_in_rec		CANDIDATE_IN_REC_TYPE;
	l_project_system_status_code	VARCHAR2(30);
	l_project_id			NUMBER;
	l_record_version_number		NUMBER;
	l_start_msg_count               NUMBER                  := 0;
	l_end_msg_count                 NUMBER                  := 0;
	l_loop_msg_count                NUMBER                  := 0;

	l_privilege                     VARCHAR2(30);
        l_object_name                   VARCHAR2(30);
        l_object_key                    NUMBER;
	l_resource_valid                VARCHAR2(1)             := 'N';
	l_privilege_name		VARCHAR2(40)		:= null;
        l_ret_code                      VARCHAR2(1);
	l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
	l_msg_count                     NUMBER;
	l_msg_data                      VARCHAR2(2000);
	l_msg_index_out                 NUMBER;
	l_data                          VARCHAR2(2000);

CURSOR c_get_system_status_code(c_status_code VARCHAR2) IS
SELECT project_system_status_code FROM pa_project_statuses
WHERE  trunc(SYSDATE) BETWEEN start_date_active AND nvl(end_date_active, trunc(SYSDATE))
AND    status_type = 'CANDIDATE'
AND    project_status_code = c_status_code;

CURSOR c_get_requirement_info(c_assignment_id NUMBER) IS
SELECT project_id
FROM   pa_project_assignments
WHERE  assignment_id = c_assignment_id
AND    assignment_type = 'OPEN_ASSIGNMENT';

CURSOR c_get_candidate_details(c_candidate_id NUMBER) IS
SELECT candidate_id, status_code, candidate_ranking, record_version_number, assignment_id
FROM   pa_candidates
WHERE  candidate_id = c_candidate_id;

	l_cand_rec			c_get_candidate_details%ROWTYPE;

BEGIN

	--Flows which are supported by this API
		  ---------------------------------------
		  --1. Updating candidate information
		  --        1.1 Validating candidate_id
		  --        1.2 Validating status_code to be a valid code
		  --        1.3 Only updatable attributes of candidates once created are status_code, ranking, record_version_number, change_reason_code
	--Flows which are not supported by this API
		  -------------------------------------------
		  --1. Validations like new status_code acceptable or not are done by underlying called apis.

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'UPDATE_CANDIDATES', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint UPDATE_CANDIDATES_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of UPDATE_CANDIDATES', l_log_level);
                pa_debug.write(l_module, 'Printing Input Parameters......', l_log_level);
		pa_debug.write(l_module, 'p_commit '||p_commit, l_log_level);
		pa_debug.write(l_module, 'p_init_msg_list '||p_init_msg_list, l_log_level);
		pa_debug.write(l_module, 'p_api_version_number '||p_api_version_number, l_log_level);
                pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                i := p_candidate_in_tbl.first;
                WHILE i IS NOT NULL LOOP
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').candidate_id '||p_candidate_in_tbl(i).candidate_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').requirement_id '||p_candidate_in_tbl(i).requirement_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').resource_id '||p_candidate_in_tbl(i).resource_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').person_id '||p_candidate_in_tbl(i).person_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').status_code '||p_candidate_in_tbl(i).status_code, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').nomination_comments '||p_candidate_in_tbl(i).nomination_comments, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').ranking '||p_candidate_in_tbl(i).ranking, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').change_reason_code '||p_candidate_in_tbl(i).change_reason_code, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').record_version_number '||p_candidate_in_tbl(i).record_version_number, l_log_level);
                        pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                        i := p_candidate_in_tbl.next(i);
                END LOOP;
        END IF;

        PA_STARTUP.INITIALIZE(
                  p_calling_application                 => l_calling_application
                , p_calling_module                      => l_calling_module
                , p_check_id_flag                       => l_check_id_flag
                , p_check_role_security_flag            => l_check_role_security_flag
                , p_check_resource_security_flag        => l_check_resource_security_flag
                , p_debug_level                         => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of PA_STARTUP.INITIALIZE', l_log_level);
        END IF;

        --l_prm_license_flag  := nvl(FND_PROFILE.VALUE('PA_PRM_LICENSED'),'N');
        --IF l_prm_license_flag <> 'Y' THEN
        --        null;
        --END IF;

        i := p_candidate_in_tbl.first;

        WHILE i IS NOT NULL LOOP
                l_error_flag_local := 'N';
                l_missing_params := null;
                l_start_msg_count := FND_MSG_PUB.count_msg;

                l_candidate_in_rec := p_candidate_in_tbl(i);
		l_cand_rec := null;

                -- Mandatory Parameters Check
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Record#'||i, l_log_level);
                        pa_debug.write(l_module, '-----------------------------', l_log_level);
                        pa_debug.write(l_module, 'Inside while loop. Mandatory parameter check.', l_log_level);
                END IF;

		-- Check on Candidate Id
		OPEN c_get_candidate_details(l_candidate_in_rec.candidate_id);
                FETCH c_get_candidate_details INTO l_cand_rec;

		IF c_get_candidate_details%NOTFOUND THEN
			l_missing_params := l_missing_params||', CANDIDATE_ID';
                END IF;

		CLOSE c_get_candidate_details;

                -- Check on Status Code
		IF l_candidate_in_rec.status_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_candidate_in_rec.status_code := l_cand_rec.status_code;
		ELSIF l_candidate_in_rec.status_code IS NOT NULL THEN
			l_project_system_status_code := null;

			OPEN  c_get_system_status_code(l_candidate_in_rec.status_code);
			FETCH c_get_system_status_code INTO l_project_system_status_code;
			CLOSE c_get_system_status_code;

			IF l_project_system_status_code IS NULL OR l_project_system_status_code NOT IN
				('CANDIDATE_DECLINED', 'CANDIDATE_PENDING_REVIEW', 'CANDIDATE_SUITABLE',
				'CANDIDATE_SYSTEM_NOMINATED', 'CANDIDATE_UNDER_REVIEW', 'CANDIDATE_WITHDRAWN') THEN
				l_missing_params := l_missing_params||', STATUS_CODE';
			END IF;
		END IF;

		IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory parameter validation over. List of Missing Parameters='||l_missing_params, l_log_level);
                END IF;

		IF l_missing_params IS NOT NULL THEN
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                        l_error_flag_local := 'Y';
                END IF;

                IF l_error_flag_local <> 'Y' THEN

			-- Nulling out the parameters which are not required and defaulting the required parameter from the database.
			l_candidate_in_rec.requirement_id := l_cand_rec.assignment_id;
			l_candidate_in_rec.resource_id := null;
			l_candidate_in_rec.person_id := null;
			l_candidate_in_rec.nomination_comments := null;

			-- Retrieve values from data base if Parameters are not passed.
			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'Retrieving values from database if parameters are not passed.', l_log_level);
			END IF;

			IF l_candidate_in_rec.ranking = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
				l_candidate_in_rec.ranking := l_cand_rec.candidate_ranking;
			END IF;

			IF l_candidate_in_rec.record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
				l_candidate_in_rec.record_version_number := l_cand_rec.record_version_number;
			END IF;

			-- If Change Reason Code is not passed then use null
			IF l_candidate_in_rec.change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
				l_candidate_in_rec.change_reason_code := null;
			END IF;

			IF l_debug_mode = 'Y' THEN
				pa_debug.write(l_module, 'Candidate Id = '||l_candidate_in_rec.candidate_id, l_log_level);
				pa_debug.write(l_module, '-----------------------------', l_log_level);
				pa_debug.write(l_module, 'Old Status Code = '||l_cand_rec.status_code, l_log_level);
				pa_debug.write(l_module, 'Old Ranking = '||l_cand_rec.candidate_ranking, l_log_level);
				pa_debug.write(l_module, 'Old Record Version Number = '||l_cand_rec.record_version_number, l_log_level);
				pa_debug.write(l_module, '-----------------------------', l_log_level);
				pa_debug.write(l_module, 'New Status Code = '||l_candidate_in_rec.status_code, l_log_level);
				pa_debug.write(l_module, 'New Ranking = '||l_candidate_in_rec.ranking, l_log_level);
				pa_debug.write(l_module, 'New Record Version Number = '||(l_candidate_in_rec.record_version_number+1), l_log_level);
				pa_debug.write(l_module, '-----------------------------', l_log_level);
				pa_debug.write(l_module, 'Change Reason Code = '||l_candidate_in_rec.change_reason_code, l_log_level);
				pa_debug.write(l_module, '-----------------------------', l_log_level);
			END IF;

			-- Getting Project Id for security check
			OPEN c_get_requirement_info(l_candidate_in_rec.requirement_id);
			FETCH c_get_requirement_info INTO l_project_id;
			CLOSE c_get_requirement_info;

			IF l_project_id IS NULL THEN  -- Check for requirement id valid and assignment type OPEN_ASSIGNMENT
				l_error_flag_local := 'Y';
        			l_missing_params := l_missing_params||', REQUIREMENT_ID';
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
			END IF;

		END IF;

		-- Security Check : Check PA_VIEW_CANDIDATES privilege on PA_PROJECTS and PA_PROJECT_ASSIGNMENTS as done in CandidatesTopCO.java
                -------------------

                IF l_error_flag_local <> 'Y' THEN

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Checking PA_VIEW_CANDIDATES privilege on PA_PROJECTS and PA_PROJECT_ASSIGNMENTS for record#'||i, l_log_level);
                        END IF;

                        l_privilege   := 'PA_VIEW_CANDIDATES';

			l_object_name := 'PA_PROJECTS';
			l_object_key  := l_project_id;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                  x_ret_code       => l_ret_code
                                , x_return_status  => l_return_status
                                , x_msg_count      => l_msg_count
                                , x_msg_data       => l_msg_data
                                , p_privilege      => l_privilege
                                , p_object_name    => l_object_name
                                , p_object_key     => l_object_key
				, p_init_msg_list  => FND_API.G_FALSE);

                        IF nvl(l_ret_code, 'F') = 'F' AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
			        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
		                l_object_key  := l_candidate_in_rec.requirement_id;

	                        l_return_status := FND_API.G_RET_STS_SUCCESS;
		                l_ret_code := 'T';

			        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
				          x_ret_code       => l_ret_code
					, x_return_status  => l_return_status
	                                , x_msg_count      => l_msg_count
		                        , x_msg_data       => l_msg_data
			                , p_privilege      => l_privilege
				        , p_object_name    => l_object_name
	                                , p_object_key     => l_object_key
					, p_init_msg_list  => FND_API.G_FALSE);
			END IF;
			IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                -- This message does not have token defined, but intentionally putting token
                                -- bcoz we still want to show the privielge name which is missing
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_ADD_CAND'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                l_error_flag_local := 'Y';
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Security check complete for record#'||i||' privilege '||l_ret_code, l_log_level);
                        END IF;

                END IF;

                -- Call Core Actual API
                -----------------------

                IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling PA_CANDIDATE_PUB.UPDATE_CANDIDATE for Record#'||i, l_log_level);
                        END IF;

                        PA_CANDIDATE_PUB.UPDATE_CANDIDATE
                        (
				  p_candidate_id		=> l_candidate_in_rec.candidate_id
				, p_status_code			=> l_candidate_in_rec.status_code
				, p_ranking			=> l_candidate_in_rec.ranking
				, p_change_reason_code		=> l_candidate_in_rec.change_reason_code
				, p_record_version_number	=> l_candidate_in_rec.record_version_number
				, p_init_msg_list		=> FND_API.G_FALSE
				, p_validate_status		=> FND_API.G_TRUE
			        -- Added for bug 9187892
                                , p_attribute_category    => l_candidate_in_rec.attribute_category
                                , p_attribute1            => l_candidate_in_rec.attribute1
                                , p_attribute2            => l_candidate_in_rec.attribute2
                                , p_attribute3            => l_candidate_in_rec.attribute3
                                , p_attribute4            => l_candidate_in_rec.attribute4
                                , p_attribute5            => l_candidate_in_rec.attribute5
                                , p_attribute6            => l_candidate_in_rec.attribute6
                                , p_attribute7            => l_candidate_in_rec.attribute7
                                , p_attribute8            => l_candidate_in_rec.attribute8
                                , p_attribute9            => l_candidate_in_rec.attribute9
                                , p_attribute10           => l_candidate_in_rec.attribute10
                                , p_attribute11           => l_candidate_in_rec.attribute11
                                , p_attribute12           => l_candidate_in_rec.attribute12
                                , p_attribute13           => l_candidate_in_rec.attribute13
                                , p_attribute14           => l_candidate_in_rec.attribute14
                                , p_attribute15           => l_candidate_in_rec.attribute15
				, x_record_version_number	=> l_record_version_number
				, x_msg_count			=> l_msg_count
				, x_msg_data			=> l_msg_data
				, x_return_status		=> l_return_status
                        );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After call PA_CANDIDATE_PUB.UPDATE_CANDIDATE l_return_status='||l_return_status, l_log_level);
                        END IF;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                l_error_flag_local := 'Y';
				IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'PA_CANDIDATE_PUB.UPDATE_CANDIDATE unsuccessful', l_log_level);
                                END IF;
                        ELSE
				IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'PA_CANDIDATE_PUB.UPDATE_CANDIDATE successful', l_log_level);
					pa_debug.write(l_module, 'Updated record_version_number = '||l_record_version_number, l_log_level);
                                END IF;
                        END IF;
                END IF;

                l_end_msg_count := FND_MSG_PUB.count_msg;
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'l_start_msg_count='||l_start_msg_count, l_log_level);
                        pa_debug.write(l_module, 'l_end_msg_count='||l_end_msg_count, l_log_level);
                END IF;
                l_loop_msg_count := l_end_msg_count - l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Repopulating Error Message Stack', l_log_level);
                        END IF;

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;

			IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Repopulating Error Message Stack', l_log_level);
                        END IF;

		END IF;
                i := p_candidate_in_tbl.next(i);
        END LOOP;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'All records are done', l_log_level);
                pa_debug.write(l_module, 'l_error_flag='||l_error_flag, l_log_level);
                pa_debug.write(l_module, 'FND_MSG_PUB.count_msg='||FND_MSG_PUB.count_msg, l_log_level);
        END IF;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

	IF c_get_candidate_details%ISOPEN THEN
		CLOSE c_get_candidate_details;
	END IF;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_CANDIDATES_SP;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTRB(SQLERRM,1,240);

     	IF c_get_candidate_details%ISOPEN THEN
		CLOSE c_get_candidate_details;
	END IF;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_CANDIDATES_SP;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'UPDATE_CANDIDATES'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;

END UPDATE_CANDIDATES;

-- Start of comments
--	API name 	: DELETE_CANDIDATES
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to delete one or more candidates for project requirements.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit		IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are:	FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list		IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number	IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_candidate_in_tbl	IN  CANDIDATE_IN_TBL_TYPE	Required
--					Table of candidate records. Please see the CANDIDATE_IN_TBL_TYPE datatype table.
--	OUT		:
--				x_return_status		OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count		OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data		OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - msachan  - Created
-- End of comments
PROCEDURE DELETE_CANDIDATES
(
  p_commit		        IN		VARCHAR2 := FND_API.G_FALSE
, p_init_msg_list	        IN		VARCHAR2 := FND_API.G_TRUE
, p_api_version_number	        IN		NUMBER   := 1.0
, p_candidate_in_tbl	        IN		CANDIDATE_IN_TBL_TYPE
, x_return_status	        OUT     NOCOPY	VARCHAR2
, x_msg_count		        OUT     NOCOPY	NUMBER
, x_msg_data		        OUT     NOCOPY	VARCHAR2
)
IS
	l_debug_mode                    VARCHAR2(1);
        l_module                        VARCHAR2(100)           := 'PA_CANDIDATE_AMG_PUB.DELETE_CANDIDATES';
	i                               NUMBER;
	l_log_level                     NUMBER                  := 3;
	l_calling_application           VARCHAR2(10)            := 'PLSQL';
	l_calling_module                VARCHAR2(10)            := 'AMG';
	l_check_id_flag                 VARCHAR2(1)             := 'Y';
	l_check_role_security_flag      VARCHAR2(1)             := 'Y';
	l_check_resource_security_flag  VARCHAR2(1)             := 'Y';
	l_error_flag_local              VARCHAR2(1)             := 'N';
	l_error_flag                    VARCHAR2(1)             := 'N';
	l_missing_params                VARCHAR2(1000);
	l_start_msg_count               NUMBER                  := 0;
	l_end_msg_count                 NUMBER                  := 0;
	l_loop_msg_count                NUMBER                  := 0;

	l_candidate_in_rec		CANDIDATE_IN_REC_TYPE;
	l_project_id			NUMBER;
	l_record_version_number		NUMBER;

	l_privilege                     VARCHAR2(30);
        l_object_name                   VARCHAR2(30);
        l_object_key                    NUMBER;
	l_resource_valid                VARCHAR2(1)             := 'N';
	l_privilege_name		VARCHAR2(40)		:= null;
        l_ret_code                      VARCHAR2(1);
	l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
	l_msg_count                     NUMBER;
	l_msg_data                      VARCHAR2(2000);
	l_msg_index_out                 NUMBER;
	l_data                          VARCHAR2(2000);

CURSOR c_get_requirement_info(c_assignment_id NUMBER) IS
SELECT project_id, record_version_number
FROM   pa_project_assignments
WHERE  assignment_id = c_assignment_id
AND    assignment_type = 'OPEN_ASSIGNMENT';

BEGIN

	--Flows which are supported by this API
		  ---------------------------------------
		  --1. Deleting all the candidates for a given open requirement
		  --        1.1 Validating requirement_id
		  --        1.2 Deleting all candidates for the given requirement_id
		  --        1.3 Changing no_of_active_candidates for the given requirement_id to zero after deleting all the candidates.
	--Flows which are not supported by this API
		  -------------------------------------------
		  --1. Validations like whether candidates can be deleted after once being confirmed are left for the underlying apis to handle.
		  --2. Either all or none of the candidates would be deleted for the specified requirement_id.

	x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'DELETE_CANDIDATES', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint DELETE_CANDIDATES_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of DELETE_CANDIDATES', l_log_level);
                pa_debug.write(l_module, 'Printing Input Parameters......', l_log_level);
		pa_debug.write(l_module, 'p_commit '||p_commit, l_log_level);
		pa_debug.write(l_module, 'p_init_msg_list '||p_init_msg_list, l_log_level);
		pa_debug.write(l_module, 'p_api_version_number '||p_api_version_number, l_log_level);
                pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                i := p_candidate_in_tbl.first;
                WHILE i IS NOT NULL LOOP
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').candidate_id '||p_candidate_in_tbl(i).candidate_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').requirement_id '||p_candidate_in_tbl(i).requirement_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').resource_id '||p_candidate_in_tbl(i).resource_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').person_id '||p_candidate_in_tbl(i).person_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').status_code '||p_candidate_in_tbl(i).status_code, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').nomination_comments '||p_candidate_in_tbl(i).nomination_comments, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').ranking '||p_candidate_in_tbl(i).ranking, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').change_reason_code '||p_candidate_in_tbl(i).change_reason_code, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').record_version_number '||p_candidate_in_tbl(i).record_version_number, l_log_level);
                        pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                        i := p_candidate_in_tbl.next(i);
                END LOOP;
        END IF;

        PA_STARTUP.INITIALIZE(
                  p_calling_application                 => l_calling_application
                , p_calling_module                      => l_calling_module
                , p_check_id_flag                       => l_check_id_flag
                , p_check_role_security_flag            => l_check_role_security_flag
                , p_check_resource_security_flag        => l_check_resource_security_flag
                , p_debug_level                         => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of PA_STARTUP.INITIALIZE', l_log_level);
        END IF;

        --l_prm_license_flag  := nvl(FND_PROFILE.VALUE('PA_PRM_LICENSED'),'N');
        --IF l_prm_license_flag <> 'Y' THEN
        --        null;
        --END IF;

        i := p_candidate_in_tbl.first;

	WHILE i IS NOT NULL LOOP
                l_error_flag_local := 'N';
                l_missing_params := null;
                l_start_msg_count := FND_MSG_PUB.count_msg;

                l_candidate_in_rec := p_candidate_in_tbl(i);
		l_record_version_number := 0;
		l_project_id := 0;

                -- Mandatory Parameters Check
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Record#'||i, l_log_level);
                        pa_debug.write(l_module, '-----------------------------', l_log_level);
                        pa_debug.write(l_module, 'Inside while loop. Mandatory parameter check.', l_log_level);
                END IF;

                IF l_candidate_in_rec.requirement_id IS NULL THEN
                        l_missing_params := l_missing_params||', REQUIREMENT_ID';
                END IF;

                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory parameter validation over. l_missing_params='||l_missing_params, l_log_level);
                END IF;

                IF l_missing_params IS NOT NULL THEN
                        l_error_flag_local := 'Y';
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                END IF;

                IF l_error_flag_local <> 'Y' THEN

			OPEN c_get_requirement_info(l_candidate_in_rec.requirement_id);
			FETCH c_get_requirement_info INTO l_project_id, l_record_version_number;
			-- CLOSE c_get_requirement_info;  -- Commented for Bug 5178399

			-- IF l_project_id IS NULL THEN  -- Check for requirement id valid and assignment type OPEN_ASSIGNMENT -- Commented for Bug 5178399
			IF c_get_requirement_info%NOTFOUND THEN    -- Check for requirement id valid and assignment type OPEN_ASSIGNMENT  -- Added for Bug 5178399
				l_error_flag_local := 'Y';
                                l_missing_params := l_missing_params||', REQUIREMENT_ID';
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
			END IF;

			CLOSE c_get_requirement_info;  -- Added for Bug 5178399

			-- Nulling out the parameters which are not required.
			l_candidate_in_rec.candidate_id := null;
			l_candidate_in_rec.resource_id := null;
			l_candidate_in_rec.person_id := null;
			l_candidate_in_rec.status_code := null;
			l_candidate_in_rec.nomination_comments := null;
			l_candidate_in_rec.ranking := null;
			l_candidate_in_rec.change_reason_code := null;
			l_candidate_in_rec.record_version_number := null;

		END IF;

                -- Security Check : Check PA_CREATE_CANDIDATES privilege on PA_PROJECTS and PA_PROJECT_ASSIGNMENTS as done in AddCandidatesTopCO.java
                -------------------

                IF l_error_flag_local <> 'Y' THEN

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Checking PA_CREATE_CANDIDATES privilege on PA_PROJECTS and PA_PROJECT_ASSIGNMENTS for record#'||i, l_log_level);
                        END IF;

                        l_privilege   := 'PA_CREATE_CANDIDATES';

			l_object_name := 'PA_PROJECTS';
			l_object_key  := l_project_id;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                  x_ret_code       => l_ret_code
                                , x_return_status  => l_return_status
                                , x_msg_count      => l_msg_count
                                , x_msg_data       => l_msg_data
                                , p_privilege      => l_privilege
                                , p_object_name    => l_object_name
                                , p_object_key     => l_object_key
				, p_init_msg_list  => FND_API.G_FALSE);

                        IF nvl(l_ret_code, 'F') = 'F' AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
			        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
		                l_object_key  := l_candidate_in_rec.requirement_id;

	                        l_return_status := FND_API.G_RET_STS_SUCCESS;
		                l_ret_code := 'T';

			        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
				          x_ret_code       => l_ret_code
					, x_return_status  => l_return_status
	                                , x_msg_count      => l_msg_count
		                        , x_msg_data       => l_msg_data
			                , p_privilege      => l_privilege
				        , p_object_name    => l_object_name
	                                , p_object_key     => l_object_key
					, p_init_msg_list  => FND_API.G_FALSE);
			END IF;
			IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                -- This message does not have token defined, but intentionally putting token
                                -- bcoz we still want to show the privielge name which is missing
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_ADD_CAND'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                l_error_flag_local := 'Y';
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Security check complete for record#'||i||' privilege '||l_ret_code, l_log_level);
                        END IF;

                END IF;

                -- Call Core Actual API
                -----------------------

                IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling PA_CANDIDATE_PUB.DELETE_CANDIDATES for Record#'||i, l_log_level);
                        END IF;

                        PA_CANDIDATE_PUB.DELETE_CANDIDATES
                        (
				  p_assignment_id	=> l_candidate_in_rec.requirement_id
				, p_status_code		=> null
				, x_return_status	=> l_return_status
				, x_msg_count		=> l_msg_count
				, x_msg_data		=> l_msg_data
                        );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After call PA_CANDIDATE_PUB.DELETE_CANDIDATES l_return_status='||l_return_status, l_log_level);
                        END IF;

                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                l_error_flag_local := 'Y';
				IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'PA_CANDIDATE_PUB.DELETE_CANDIDATES unsuccessful', l_log_level);
                                END IF;
                        ELSE
				IF l_debug_mode = 'Y' THEN
					pa_debug.write(l_module, 'Calling PA_PROJECT_ASSIGNMENTS_PKG.UPDATE_ROW for Record#'||i, l_log_level);
				END IF;
				-- Set the number of active candidates to zero
				PA_PROJECT_ASSIGNMENTS_PKG.UPDATE_ROW
				(
					  p_assignment_id           => l_candidate_in_rec.requirement_id
					, p_no_of_active_candidates => 0
					, p_record_version_number   => l_record_version_number
					, x_return_status           => l_return_status
				);
				IF l_debug_mode = 'Y' THEN
					pa_debug.write(l_module, 'After call PA_PROJECT_ASSIGNMENTS_PKG.UPDATE_ROW l_return_status='||l_return_status, l_log_level);
				END IF;
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					l_error_flag_local := 'Y';
					IF l_debug_mode = 'Y' THEN
						pa_debug.write(l_module, 'PA_PROJECT_ASSIGNMENTS_PKG.UPDATE_ROW unsuccessful', l_log_level);
					END IF;
				ELSE
					IF l_debug_mode = 'Y' THEN
						pa_debug.write(l_module, 'PA_PROJECT_ASSIGNMENTS_PKG.UPDATE_ROW and PA_CANDIDATE_PUB.DELETE_CANDIDATES successful', l_log_level);
					END IF;
				END IF;
                        END IF;
                END IF;

                l_end_msg_count := FND_MSG_PUB.count_msg;
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'l_start_msg_count='||l_start_msg_count, l_log_level);
                        pa_debug.write(l_module, 'l_end_msg_count='||l_end_msg_count, l_log_level);
                END IF;
                l_loop_msg_count := l_end_msg_count - l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Repopulating Error Message Stack', l_log_level);
                        END IF;

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;

			IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Repopulating Error Message Stack', l_log_level);
                        END IF;

		END IF;
                i := p_candidate_in_tbl.next(i);
        END LOOP;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'All records are done', l_log_level);
                pa_debug.write(l_module, 'l_error_flag='||l_error_flag, l_log_level);
                pa_debug.write(l_module, 'FND_MSG_PUB.count_msg='||FND_MSG_PUB.count_msg, l_log_level);
        END IF;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

	IF c_get_requirement_info%ISOPEN THEN
		CLOSE c_get_requirement_info;
	END IF;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO DELETE_CANDIDATES_SP;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTRB(SQLERRM,1,240);

     	IF c_get_requirement_info%ISOPEN THEN
		CLOSE c_get_requirement_info;
	END IF;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO DELETE_CANDIDATES_SP;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'DELETE_CANDIDATES'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;

END DELETE_CANDIDATES;

-- Start of comments
--	API name 	: CREATE_CANDIDATE_LOG
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This is a public API to create log for one or more candidates for project requirements.
--	Usage		: This API will be called from AMG.
--	Parameters	:
--	IN		:	p_commit			IN  VARCHAR2
--					Identifier to commit the transaction.
--					Valid values are:	FND_API.G_FALSE for FALSE and FND_API.G_TRUE for TRUE
--				p_init_msg_list			IN  VARCHAR2
--					Identifier to initialize the error message stack.
--					Valid values are: FND_API.G_FALSE for FALSE amd FND_API.G_TRUE for TRUE
--				p_api_version_number		IN  NUMBER			Required
--					To be compliant with Applications API coding standards.
--				p_candidate_log_tbl		IN  CANDIDATE_LOG_TBL_TYPE	Required
--					Table of candidate review records. Please see the CANDIDATE_LOG_TBL_TYPE datatype table.
--	OUT		:
--				x_candidate_review_id_tbl	OUT SYSTEM.PA_NUM_TBL_TYPE
--					Table to store the candidate review ids created by the API.
--					Reference : pa_candidate_reviews.candidate_review_id
--				x_return_status			OUT VARCHAR2
--					Indicates the return status of the API.
--					Valid values are: 'S' for Success, 'E' for Error, 'U' for Unexpected Error
--				x_msg_count			OUT NUMBER
--					Indicates the number of error messages in the message stack
--				x_msg_data			OUT VARCHAR2
--					Indicates the error message text if only one error exists
--	History		:
--                              01-Mar-2006 - msachan  - Created
-- End of comments
PROCEDURE CREATE_CANDIDATE_LOG
(
  p_commit			IN		VARCHAR2 := FND_API.G_FALSE
, p_init_msg_list		IN		VARCHAR2 := FND_API.G_TRUE
, p_api_version_number		IN		NUMBER   := 1.0
, p_candidate_log_tbl		IN		CANDIDATE_LOG_TBL_TYPE
, x_candidate_review_id_tbl	OUT     NOCOPY	SYSTEM.PA_NUM_TBL_TYPE
, x_return_status		OUT     NOCOPY	VARCHAR2
, x_msg_count			OUT     NOCOPY	NUMBER
, x_msg_data			OUT     NOCOPY	VARCHAR2
)
IS
	l_debug_mode                    VARCHAR2(1);
        l_module                        VARCHAR2(100)           := 'PA_CANDIDATE_AMG_PUB.CREATE_CANDIDATE_LOG';
	i                               NUMBER;
	l_log_level                     NUMBER                  := 3;
	l_calling_application           VARCHAR2(10)            := 'PLSQL';
	l_calling_module                VARCHAR2(10)            := 'AMG';
	l_check_id_flag                 VARCHAR2(1)             := 'Y';
	l_check_role_security_flag      VARCHAR2(1)             := 'Y';
	l_check_resource_security_flag  VARCHAR2(1)             := 'Y';
	l_error_flag_local              VARCHAR2(1)             := 'N';
	l_error_flag                    VARCHAR2(1)             := 'N';
	l_missing_params                VARCHAR2(1000);
	l_start_msg_count               NUMBER                  := 0;
	l_end_msg_count                 NUMBER                  := 0;
	l_loop_msg_count                NUMBER                  := 0;

	l_candidate_log_tbl		CANDIDATE_LOG_REC_TYPE;
	l_project_system_status_code	VARCHAR2(30);
	l_cand_record_version_number	NUMBER;
	l_lookup_code			VARCHAR2(20);

	l_privilege                     VARCHAR2(30);
        l_object_name                   VARCHAR2(30);
        l_object_key                    NUMBER;
	l_resource_valid                VARCHAR2(1)             := 'N';
	l_privilege_name		VARCHAR2(40)		:= null;
        l_ret_code                      VARCHAR2(1);
	l_return_status                 VARCHAR2(1)             := FND_API.G_RET_STS_SUCCESS;
	l_msg_count                     NUMBER;
	l_msg_data                      VARCHAR2(2000);
	l_msg_index_out                 NUMBER;
	l_data                          VARCHAR2(2000);

CURSOR c_get_valid_lookup_code(c_change_reason_code VARCHAR2) IS
SELECT lookup_code
FROM   pa_lookups
WHERE  lookup_type = 'CANDIDATE_STS_CHANGE_REASON'
AND    lookup_code = c_change_reason_code;

CURSOR c_get_candidate_details(c_candidate_id NUMBER) IS
SELECT pcv.project_id, pc.assignment_id, pc.record_version_number
FROM   pa_candidates pc, pa_candidates_v pcv
WHERE  pc.candidate_id = c_candidate_id
AND    pcv.candidate_number = c_candidate_id;

CURSOR c_get_system_status_code(c_status_code VARCHAR2) IS
SELECT project_system_status_code FROM pa_project_statuses
WHERE  trunc(SYSDATE) BETWEEN start_date_active AND nvl(end_date_active, trunc(SYSDATE))
AND    status_type = 'CANDIDATE'
AND    project_status_code = c_status_code;

	l_cand_rec			c_get_candidate_details%ROWTYPE;

BEGIN

	--Flows which are supported by this API
		  ---------------------------------------
		  --1. Creating a log of candidate when the status is changed.
		  --        1.1 Validating candidate_id
		  --        1.2 Validating for valid status_code
		  --        1.3 validating change_reason_status
		  --        1.4 Creating a entry in pa_candidate_reviews if the status is changed.
	--Flows which are not supported by this API
		  -------------------------------------------
		  --1. Validations like status_code change allowed or not are handled by the underlying apis.

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_candidate_review_id_tbl := SYSTEM.PA_NUM_TBL_TYPE();

	l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'CREATE_CANDIDATE_LOG', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint CREATE_CANDIDATE_LOG_SP;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'Start of CREATE_CANDIDATE_LOG', l_log_level);
                pa_debug.write(l_module, 'Printing Input Parameters......', l_log_level);
		pa_debug.write(l_module, 'p_commit '||p_commit, l_log_level);
		pa_debug.write(l_module, 'p_init_msg_list '||p_init_msg_list, l_log_level);
		pa_debug.write(l_module, 'p_api_version_number '||p_api_version_number, l_log_level);
                pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                i := p_candidate_log_tbl.first;
                WHILE i IS NOT NULL LOOP
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').candidate_id '||p_candidate_log_tbl(i).candidate_id, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').status_code '||p_candidate_log_tbl(i).status_code, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').change_reason_code '||p_candidate_log_tbl(i).change_reason_code, l_log_level);
                        pa_debug.write(l_module, 'p_candidate_in_tbl('||i||').review_comments '||p_candidate_log_tbl(i).review_comments, l_log_level);
                        pa_debug.write(l_module, '------------------------------------------------------------------', l_log_level);
                        i := p_candidate_log_tbl.next(i);
                END LOOP;
        END IF;

        PA_STARTUP.INITIALIZE(
                  p_calling_application                 => l_calling_application
                , p_calling_module                      => l_calling_module
                , p_check_id_flag                       => l_check_id_flag
                , p_check_role_security_flag            => l_check_role_security_flag
                , p_check_resource_security_flag        => l_check_resource_security_flag
                , p_debug_level                         => l_log_level
                );

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call of PA_STARTUP.INITIALIZE', l_log_level);
        END IF;

        --l_prm_license_flag  := nvl(FND_PROFILE.VALUE('PA_PRM_LICENSED'),'N');
        --IF l_prm_license_flag <> 'Y' THEN
        --        null;
        --END IF;

        i := p_candidate_log_tbl.first;

	WHILE i IS NOT NULL LOOP
                l_error_flag_local := 'N';
                l_missing_params := null;
                l_start_msg_count := FND_MSG_PUB.count_msg;

                l_candidate_log_tbl := p_candidate_log_tbl(i);
		l_cand_rec := null;

                -- Mandatory Parameters Check
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Record#'||i, l_log_level);
                        pa_debug.write(l_module, '-----------------------------', l_log_level);
                        pa_debug.write(l_module, 'Inside while loop. Mandatory parameter check.', l_log_level);
                END IF;

		-- Check on Candidate Id
		OPEN c_get_candidate_details(l_candidate_log_tbl.candidate_id);
                FETCH c_get_candidate_details INTO l_cand_rec;

		IF c_get_candidate_details%NOTFOUND THEN
			l_missing_params := l_missing_params||', CANDIDATE_ID';
		END IF;

		CLOSE c_get_candidate_details;

                -- Check on Status Code
		IF l_candidate_log_tbl.status_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_candidate_log_tbl.status_code := null;
		ELSIF l_candidate_log_tbl.status_code IS NOT NULL THEN
			l_project_system_status_code := null;

			OPEN  c_get_system_status_code(l_candidate_log_tbl.status_code);
			FETCH c_get_system_status_code INTO l_project_system_status_code;
			CLOSE c_get_system_status_code;

			IF l_project_system_status_code IS NULL OR l_project_system_status_code NOT IN
				('CANDIDATE_DECLINED', 'CANDIDATE_PENDING_REVIEW', 'CANDIDATE_SUITABLE',
				'CANDIDATE_SYSTEM_NOMINATED', 'CANDIDATE_UNDER_REVIEW', 'CANDIDATE_WITHDRAWN') THEN
				l_missing_params := l_missing_params||', STATUS_CODE';
			END IF;
		END IF;

		-- Check for Change Reason Code
		IF l_candidate_log_tbl.change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
			l_candidate_log_tbl.change_reason_code := null;
		ELSIF l_candidate_log_tbl.change_reason_code IS NOT NULL THEN

			OPEN  c_get_valid_lookup_code(l_candidate_log_tbl.change_reason_code);
			FETCH c_get_valid_lookup_code INTO l_lookup_code;

			IF c_get_valid_lookup_code%NOTFOUND THEN
				l_missing_params := l_missing_params||', CHANGE_REASON_CODE';
			END IF;

			CLOSE c_get_valid_lookup_code;

		END IF;

		IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'Mandatory parameter validation over. List of Missing Parameters='||l_missing_params, l_log_level);
                END IF;

		IF l_missing_params IS NOT NULL THEN
                        PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_INV_PARAMS',
                                                'INVALID_PARAMS', l_missing_params);
                        l_error_flag_local := 'Y';
                END IF;

                IF l_error_flag_local <> 'Y' THEN


			-- Check for Review Comments
			IF l_candidate_log_tbl.review_comments = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
				l_candidate_log_tbl.review_comments := null;
			END IF;

			-- Security Check : Check PA_REVIEW_CANDIDATE_LOG privilege on PA_PROJECTS and PA_PROJECT_ASSIGNMENTS as done in CandRevwLogTopCO.java
			-------------------

			IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Checking PA_REVIEW_CANDIDATE_LOG privilege on PA_PROJECTS and PA_PROJECT_ASSIGNMENTS for record#'||i, l_log_level);
                        END IF;

                        l_privilege   := 'PA_REVIEW_CANDIDATE_LOG';

			l_object_name := 'PA_PROJECTS';
			l_object_key  := l_cand_rec.project_id;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;
                        l_ret_code := 'T';

                        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                                  x_ret_code       => l_ret_code
                                , x_return_status  => l_return_status
                                , x_msg_count      => l_msg_count
                                , x_msg_data       => l_msg_data
                                , p_privilege      => l_privilege
                                , p_object_name    => l_object_name
                                , p_object_key     => l_object_key
				, p_init_msg_list  => FND_API.G_FALSE);

                        IF nvl(l_ret_code, 'F') = 'F' AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
			        l_object_name := 'PA_PROJECT_ASSIGNMENTS';
		                l_object_key  := l_cand_rec.assignment_id;

	                        l_return_status := FND_API.G_RET_STS_SUCCESS;
		                l_ret_code := 'T';

			        PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
				          x_ret_code       => l_ret_code
					, x_return_status  => l_return_status
	                                , x_msg_count      => l_msg_count
		                        , x_msg_data       => l_msg_data
			                , p_privilege      => l_privilege
				        , p_object_name    => l_object_name
	                                , p_object_key     => l_object_key
					, p_init_msg_list  => FND_API.G_FALSE);
			END IF;
			IF nvl(l_ret_code, 'F') = 'F' OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                -- This message does not have token defined, but intentionally putting token
                                -- bcoz we still want to show the privielge name which is missing
                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_REQ_ADD_CAND_LOG'
                                                      ,'MISSING_PRIVILEGE', l_privilege);
                                l_error_flag_local := 'Y';
                        END IF;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Security check complete for record#'||i||' privilege '||l_ret_code, l_log_level);
                        END IF;

                END IF;

                -- Call Core Actual API
                -----------------------

                IF l_error_flag_local <> 'Y' THEN
                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Calling PA_CANDIDATE_PUB.ADD_CANDIDATE_LOG for Record#'||i, l_log_level);
                        END IF;

                        PA_CANDIDATE_PUB.ADD_CANDIDATE_LOG
                        (
				  p_candidate_id		=> l_candidate_log_tbl.candidate_id
				, p_status_code			=> l_candidate_log_tbl.status_code
				, p_change_reason_code		=> l_candidate_log_tbl.change_reason_code
				, p_review_comments		=> l_candidate_log_tbl.review_comments
				, p_cand_record_version_number	=> l_cand_rec.record_version_number
				, x_cand_record_version_number	=> l_cand_record_version_number
				, p_init_msg_list		=> FND_API.G_FALSE
			        -- Added for bug 9187892
                                , p_attribute_category    => l_candidate_log_tbl.attribute_category
                                , p_attribute1            => l_candidate_log_tbl.attribute1
                                , p_attribute2            => l_candidate_log_tbl.attribute2
                                , p_attribute3            => l_candidate_log_tbl.attribute3
                                , p_attribute4            => l_candidate_log_tbl.attribute4
                                , p_attribute5            => l_candidate_log_tbl.attribute5
                                , p_attribute6            => l_candidate_log_tbl.attribute6
                                , p_attribute7            => l_candidate_log_tbl.attribute7
                                , p_attribute8            => l_candidate_log_tbl.attribute8
                                , p_attribute9            => l_candidate_log_tbl.attribute9
                                , p_attribute10           => l_candidate_log_tbl.attribute10
                                , p_attribute11           => l_candidate_log_tbl.attribute11
                                , p_attribute12           => l_candidate_log_tbl.attribute12
                                , p_attribute13           => l_candidate_log_tbl.attribute13
                                , p_attribute14           => l_candidate_log_tbl.attribute14
                                , p_attribute15           => l_candidate_log_tbl.attribute15
				, x_return_status		=> l_return_status
				, x_msg_count			=> l_msg_count
				, x_msg_data			=> l_msg_data
                        );

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After call PA_CANDIDATE_PUB.ADD_CANDIDATE_LOG l_return_status='||l_return_status, l_log_level);
                        END IF;

			IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
				x_candidate_review_id_tbl.extend(1);
				x_candidate_review_id_tbl(x_candidate_review_id_tbl.COUNT) := l_cand_record_version_number;
				IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'PA_CANDIDATE_PUB.ADD_CANDIDATE_LOG successful', l_log_level);
                                END IF;
			ELSE
				l_error_flag_local := 'Y';
				x_candidate_review_id_tbl.extend(1);
				x_candidate_review_id_tbl(x_candidate_review_id_tbl.COUNT) := -1;
				IF l_debug_mode = 'Y' THEN
                                        pa_debug.write(l_module, 'PA_CANDIDATE_PUB.ADD_CANDIDATE_LOG unsuccessful', l_log_level);
                                END IF;
			END IF;
		ELSE
			x_candidate_review_id_tbl.extend(1);
			x_candidate_review_id_tbl(x_candidate_review_id_tbl.COUNT) := -1;
                END IF;

                l_end_msg_count := FND_MSG_PUB.count_msg;
                IF l_debug_mode = 'Y' THEN
                        pa_debug.write(l_module, 'l_start_msg_count='||l_start_msg_count, l_log_level);
                        pa_debug.write(l_module, 'l_end_msg_count='||l_end_msg_count, l_log_level);
                END IF;
                l_loop_msg_count := l_end_msg_count - l_start_msg_count;

                IF l_error_flag_local = 'Y' OR l_loop_msg_count > 0 THEN
                        l_error_flag := 'Y';

                        IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'Repopulating Error Message Stack', l_log_level);
                        END IF;

                        FOR j in l_start_msg_count+1..l_end_msg_count LOOP
                                -- Always get from first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.get (
                                        p_msg_index      => l_start_msg_count+1,
                                        p_encoded        => FND_API.G_FALSE,
                                        p_data           => l_data,
                                        p_msg_index_out  => l_msg_index_out );

                                -- Always delete at first location in stack i.e. l_start_msg_count+1
                                -- Because stack moves down after delete
                                FND_MSG_PUB.DELETE_MSG(p_msg_index => l_start_msg_count+1);

                                PA_UTILS.ADD_MESSAGE('PA', 'PA_AMG_RES_ERROR_MSG',
                                                'RECORD_NO', i,
                                                'MESSAGE', l_data);
                        END LOOP;

			IF l_debug_mode = 'Y' THEN
                                pa_debug.write(l_module, 'After Repopulating Error Message Stack', l_log_level);
                                pa_debug.write(l_module, 'l_cand_record_version_number = '||l_cand_record_version_number, l_log_level);
                        END IF;

		END IF;
                i := p_candidate_log_tbl.next(i);
        END LOOP;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'All records are done', l_log_level);
                pa_debug.write(l_module, 'l_error_flag='||l_error_flag, l_log_level);
                pa_debug.write(l_module, 'FND_MSG_PUB.count_msg='||FND_MSG_PUB.count_msg, l_log_level);
        END IF;

        IF l_error_flag = 'Y' OR FND_MSG_PUB.count_msg > 0 THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                commit;
        END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

	IF c_get_candidate_details%ISOPEN THEN
		CLOSE c_get_candidate_details;
	END IF;

	IF c_get_system_status_code%ISOPEN THEN
		CLOSE c_get_system_status_code;
	END IF;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO CREATE_CANDIDATE_LOG_SP;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => l_msg_count
                , p_msg_data       => l_msg_data
                , p_data           => l_data
                , p_msg_index_out  => l_msg_index_out);

                x_msg_data := l_data;
                x_msg_count := l_msg_count;
        ELSE
                x_msg_count := l_msg_count;
        END IF;

        IF l_debug_mode = 'Y' THEN
                Pa_Debug.reset_curr_function;
        END IF;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := SUBSTRB(SQLERRM,1,240);

	IF c_get_candidate_details%ISOPEN THEN
		CLOSE c_get_candidate_details;
	END IF;

	IF c_get_system_status_code%ISOPEN THEN
		CLOSE c_get_system_status_code;
	END IF;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO CREATE_CANDIDATE_LOG_SP;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_RES_MANAGEMENT_AMG_PUB'
        , p_procedure_name      => 'CREATE_CANDIDATE_LOG'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;
        RAISE;

END CREATE_CANDIDATE_LOG;

END PA_RES_MANAGEMENT_AMG_PUB;

/
