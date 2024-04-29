--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_REQUEST_PVT" as
/* $Header: PAYRPVTB.pls 120.8.12010000.3 2010/05/06 06:27:12 kkorrapo ship $ */

-- This procedure will validate the status of project request for project creation.
-- Users are not allowed to create a project from a project request having system
-- Status of 'PROJ_REQ_CLOSED' OR 'PROJ_REQ_CANCELED'.
--
-- Input parameters
-- Parameters                   Type
-- p_request_sys_status         pa_project_statuses.project_system_status_code%TYPE
--
G_DEBUG_MODE VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
PROCEDURE debug(p_msg IN VARCHAR2) IS
l_debug_mode               varchar2(1); -- Added for Bug 4469333
BEGIN
	l_debug_mode  := PA_PROJECT_REQUEST_PVT.G_DEBUG_MODE ; -- Added for Bug 4469333

        IF l_debug_mode = 'Y' THEN -- IF Clause Included for Bug 4469333

	 --dbms_output.put_line('pa_project_request_pvt'|| ' : ' || p_msg);
	 PA_DEBUG.WRITE(
		 x_module => 'pa.plsql.pa_project_request_pvt',
		 x_msg => p_msg,
		 x_log_level => 6);
   pa_debug.write_file('LOG', p_msg);
   -- Added the following line in order to show log messages in Concurrent Program
   FND_FILE.PUT_LINE(FND_FILE.LOG,p_msg);

        END IF ; -- End of IF Clause started for Bug 4469333
END debug;


PROCEDURE create_project_validation
(p_request_sys_status IN       pa_project_statuses.project_system_status_code%TYPE,
 x_return_status      OUT    	NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
 x_msg_count          OUT    	NOCOPY NUMBER,  --File.Sql.39 bug 4440895
 x_msg_data           OUT    	NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS
create_proj_not_allowed 	EXCEPTION;
l_msg_index_out	     	  NUMBER;
-- added for Bug Fix: 4537865
l_new_msg_data		  VARCHAR2(2000);
-- added for Bug Fix: 4537865

BEGIN
	 x_return_status 	:= FND_API.G_RET_STS_SUCCESS;

	 -- Check if the user is allowed to create project.
	 -- For any project request with a system status code of
	 -- 'PROJ_REQ_CANCELED' or 'PROJ_REQ_CLOSED',
	 -- user is not allowed to create project from it.

	 IF p_request_sys_status = 'PROJ_REQ_CANCELED'  OR
		 p_request_sys_status = 'PROJ_REQ_CLOSED' THEN

			RAISE create_proj_not_allowed;
	 END IF;

EXCEPTION
	 WHEN create_proj_not_allowed THEN
		 PA_UTILS.add_message(p_app_short_name    => 'PA',
			p_msg_name          => 'PA_CANNOT_CREATE_PROJ');
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_msg_count := FND_MSG_PUB.Count_Msg;
			x_msg_data := 'PA_CANNOT_CREATE_PROJ';

			IF x_msg_count = 1 THEN
				 pa_interface_utils_pub.get_messages
					 (p_encoded        => FND_API.G_TRUE,
					 p_msg_index      => 1,
					 p_msg_count      => x_msg_count,
					 p_msg_data       => x_msg_data,
				       --p_data           => x_msg_data,		* Commented for Bug: 4537865
					 p_data		  => l_new_msg_data,		-- added for Bug Fix: 4537865
					 p_msg_index_out  => l_msg_index_out );
			-- added for Bug Fix: 4537865
			x_msg_data := l_new_msg_data;
			-- added for Bug Fix: 4537865
			END IF;

	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := FND_MSG_PUB.Count_Msg;
		 x_msg_data      := substr(SQLERRM,1,240);
		 FND_MSG_PUB.add_exc_msg
			 ( p_pkg_name         => 'PA_PROJECT_REQUEST_PVT',
			 p_procedure_name   => 'create_project_validation');

		 IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,                * Commented for Bug: 4537865
                                        p_data           => l_new_msg_data,            -- added for Bug Fix: 4537865
					p_msg_index_out  => l_msg_index_out );
			-- added for Bug Fix: 4537865
                        x_msg_data := l_new_msg_data;
                        -- added for Bug Fix: 4537865
		 END IF;

		 RAISE; -- This is optional depending on the needs

END create_project_validation;


--
-- Procedure     : get_object_info
-- Purpose       : Get all the attributes of an object.
--
--
PROCEDURE get_object_info
(       p_object_type                IN VARCHAR2    ,
				p_object_id1                 IN VARCHAR2    ,
				p_object_id2                 IN VARCHAR2    ,
				p_object_id3                 IN VARCHAR2    ,
				p_object_id4                 IN VARCHAR2    ,
				p_object_id5                 IN VARCHAR2    ,
				x_object_name                OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
				x_object_number              OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
				x_object_type_name           OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
        x_object_subtype             OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
				x_status_name                OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
				x_description                OUT NOCOPY VARCHAR2    , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS

	 CURSOR lup IS
		 SELECT lookup_code, meaning
			 FROM pa_lookups
			 WHERE lookup_type = 'PROJ_REQ_OBJECT_TYPE'
			 AND lookup_code = p_object_type;

	 v_lup lup%ROWTYPE;

   -- 2564086: Modified to select from pa_projects_all.
	 CURSOR prj IS
		 SELECT p.name, p.segment1, p.project_type, s.project_status_name, p.description
			 FROM pa_projects_all p, pa_project_statuses s
			 WHERE p.project_status_code = s.project_status_code
			 AND p.project_id = p_object_id1;

   v_prj prj%ROWTYPE;

	 CURSOR prq IS
		 SELECT r.request_name, r.request_number, lup.meaning, s.project_status_name, r.description
			 FROM pa_project_requests r, pa_project_statuses s, pa_lookups lup
			 WHERE r.status_code = s.project_status_code
			 AND r.request_id = p_object_id1
			 AND r.request_type = lup.lookup_code
			 AND lup.lookup_type = 'PROJECT_REQUEST_TYPE';

	 v_prq prq%ROWTYPE;

	 CURSOR asl IS
		 SELECT a.lead_number, s.meaning, a.description
			 FROM as_leads a, as_statuses_tl s
			 WHERE a.status = s.status_code
			 AND a.lead_id = p_object_id1
			 AND s.LANGUAGE = userenv('LANG'); -- added for Bug 4099490

	 v_asl asl%ROWTYPE;

BEGIN
	 x_return_status 	:= FND_API.G_RET_STS_SUCCESS;

	 x_object_name := NULL;
	 x_object_number := NULL;
	 x_object_type_name := NULL;
	 x_object_subtype := NULL;
	 x_status_name := NULL;
	 x_description := NULL;

	 OPEN lup;
	 FETCH lup INTO v_lup;
	 x_object_type_name := v_lup.meaning;
	 debug('x_object_type_name = '||  x_object_type_name);
	 CLOSE lup;

	 IF p_object_type = 'PA_PROJECTS' THEN
			OPEN prj;
			FETCH prj INTO v_prj;
			IF prj%NOTFOUND THEN
				 RETURN;
			ELSE
				 x_object_name := v_prj.name;
				 debug('x_object_name = '||x_object_name);
				 x_object_number := v_prj.segment1;
				 x_object_subtype := v_prj.project_type;
				 x_status_name := v_prj.project_status_name;
				 x_description := v_prj.description;
			END IF;

	 ELSIF p_object_type = 'PA_PROJECT_REQUESTS' THEN
			OPEN prq;
			FETCH prq INTO v_prq;
			IF prq%NOTFOUND THEN
				 RETURN;
			ELSE
				 x_object_name := v_prq.request_name;
				 debug('x_object_name = '||x_object_name);
				 x_object_number := v_prq.request_number;
				 x_object_subtype := v_prq.meaning;
				 x_status_name := v_prq.project_status_name;
				 x_description := v_prq.description;
			END IF;

	 ELSIF p_object_type = 'AS_LEADS' THEN
			OPEN asl;
			FETCH asl INTO v_asl;
			IF asl%NOTFOUND THEN
				 RETURN;
			ELSE
                                 -- bug 6416428 - skkoppul : changed SUBSTR to SUBSTRB
				 x_object_name := SUBSTRB(v_asl.description, 1, 80);
				 debug('x_object_name = '||x_object_name);
				 x_object_number := v_asl.lead_number;
				 x_status_name := v_asl.meaning;
				 x_description := v_asl.description;
			END IF;

	 END IF;

EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROJECT_REQUEST_PVT',
			 p_procedure_name   => 'get_object_info');
		 raise;

END get_object_info;


--
-- Procedure     : populate_associations_temp
-- Purpose       : Insert data into PA_ASSOCIATIONS_TEMP that is used to
--                 display
--                 the associations on the Relationships page.
--
--
PROCEDURE populate_associations_temp
(       p_object_type_from                 IN VARCHAR2,
        p_object_id_from1                  IN VARCHAR2,
				p_object_id_from2                  IN VARCHAR2,
        p_object_id_from3                  IN VARCHAR2,
        p_object_id_from4                  IN VARCHAR2,
        p_object_id_from5                  IN VARCHAR2,
        x_return_status              OUT  NOCOPY VARCHAR2            , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER              , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
	 CURSOR c1 IS
		 SELECT object_type_to, object_id_to1, object_id_to2, object_id_to3, object_id_to4, object_id_to5
			 FROM pa_object_relationships
			 WHERE relationship_type = 'A'
			 AND relationship_subtype = 'PROJECT_REQUEST'
			 START WITH (object_type_from = p_object_type_from
			 AND object_id_from1 = p_object_id_from1)
			 CONNECT BY (PRIOR object_id_to1 = object_id_from1
       AND PRIOR object_type_to = object_type_from
			 AND PRIOR object_id_from1 <> object_id_to1);

		 l_object_type_tbl PA_PLSQL_DATATYPES.Char30TabTyp;
		 l_object_id1_tbl PA_PLSQL_DATATYPES.Char240TabTyp;
		 l_object_id2_tbl PA_PLSQL_DATATYPES.Char240TabTyp;
		 l_object_id3_tbl PA_PLSQL_DATATYPES.Char240TabTyp;
		 l_object_id4_tbl PA_PLSQL_DATATYPES.Char240TabTyp;
		 l_object_id5_tbl PA_PLSQL_DATATYPES.Char240TabTyp;
		 l_object_name_tbl PA_PLSQL_DATATYPES.Char80TabTyp;
		 l_object_number_tbl PA_PLSQL_DATATYPES.Char80TabTyp;
		 l_object_type_name_tbl PA_PLSQL_DATATYPES.Char80TabTyp;
		 l_object_subtype_tbl PA_PLSQL_DATATYPES.Char80TabTyp;
		 l_status_name_tbl PA_PLSQL_DATATYPES.Char80TabTyp;
		 l_description_tbl PA_PLSQL_DATATYPES.Char250TabTyp;

		 j NUMBER := 1;

BEGIN
	 debug('Entering populate_associations_temp');
	 x_return_status 	:= FND_API.G_RET_STS_SUCCESS;

	 FOR v_c1 IN c1 LOOP
			debug('Entering c1 loop');
			debug('j = '||j);
			l_object_type_tbl(j) := v_c1.object_type_to;
			l_object_id1_tbl(j) := v_c1.object_id_to1;
			l_object_id2_tbl(j) := v_c1.object_id_to2;
			l_object_id3_tbl(j) := v_c1.object_id_to3;
			l_object_id4_tbl(j) := v_c1.object_id_to4;
			l_object_id5_tbl(j) := v_c1.object_id_to5;
			debug('object_id1 = ' || v_c1.object_id_to1);

			debug('Before calling get_object_info');
			get_object_info(p_object_type => v_c1.object_type_to,
				p_object_id1 => v_c1.object_id_to1,
				p_object_id2 => v_c1.object_id_to2,
				p_object_id3 => v_c1.object_id_to3,
				p_object_id4 => v_c1.object_id_to4,
				p_object_id5 => v_c1.object_id_to5,
				x_object_name => l_object_name_tbl(j),
				x_object_number => l_object_number_tbl(j),
				x_object_type_name => l_object_type_name_tbl(j),
				x_object_subtype => l_object_subtype_tbl(j),
				x_status_name => l_status_name_tbl(j),
				x_description => l_description_tbl(j),
				x_return_status => x_return_status,
				x_msg_count => x_msg_count,
				x_msg_data => x_msg_data);

			debug('After calling get_object_info');
			j := j +1;

	 END LOOP;

	 IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_object_type_tbl.COUNT > 0) THEN
			PA_PROJ_REQ_ASSOCIATIONS_PKG.insert_rows(p_object_type_tbl => l_object_type_tbl,
				p_object_id1_tbl   => l_object_id1_tbl,
				p_object_id2_tbl   => l_object_id2_tbl,
				p_object_id3_tbl   => l_object_id3_tbl,
				p_object_id4_tbl   => l_object_id4_tbl,
				p_object_id5_tbl   => l_object_id5_tbl,
				p_object_name_tbl  => l_object_name_tbl,
				p_object_number_tbl => l_object_number_tbl,
				p_object_type_name_tbl => l_object_type_name_tbl,
				p_object_subtype_tbl   => l_object_subtype_tbl,
				p_status_name_tbl      => l_status_name_tbl,
				p_description_tbl      => l_description_tbl,
				x_return_status => x_return_status,
				x_msg_count => x_msg_count,
				x_msg_data => x_msg_data);
	 END IF;

	 debug('Leaving populate_associations_temp');
EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROJECT_REQUEST_PVT',
			 p_procedure_name   => 'populate_associations_temp');
		 raise;

END populate_associations_temp;


PROCEDURE close_project_request
	(p_request_id        IN     	pa_project_requests.request_id%TYPE,
	 x_return_status      OUT    	NOCOPY VARCHAR2,   --File.Sql.39 bug 4440895
	 x_msg_count          OUT    	NOCOPY NUMBER,   --File.Sql.39 bug 4440895
	 x_msg_data           OUT    	NOCOPY VARCHAR2)   --File.Sql.39 bug 4440895
IS
	 close_req_not_allowed         EXCEPTION;
	 l_msg_index_out               NUMBER;
	 l_sys_status_code             VARCHAR2(30);
         -- added for Bug Fix: 4537865
	 l_new_msg_data		       VARCHAR2(2000);
         -- added for Bug Fix: 4537865

	 cursor cur_status is
		 select sts.project_system_status_code
			 from pa_project_statuses sts, pa_project_requests req
			 where req.request_id = p_request_id
			 and sts.project_status_code  = req.status_code;
BEGIN


	 -- Initialize the return status to success
	 x_return_status := FND_API.G_RET_STS_SUCCESS;

	 --Log Message
	 debug('Beginning of close_project_request');

		 -- Check if the user is allowed to close the project request.
		 -- For any project request with a status of 'CANCELED' or 'CLOSED',
		 -- user is not allowed to close it.

	 OPEN Cur_Status;
	 FETCH Cur_Status INTO l_sys_status_code;
	 CLOSE Cur_Status;

	 IF l_sys_status_code = 'PROJ_REQ_CANCELED'  OR
		 l_sys_status_code  = 'PROJ_REQ_CLOSED' THEN

			RAISE close_req_not_allowed;
	 END IF;

	 --Log Message
	 debug('Calling PKG update_row');

	 -- Call the table handler

	 PA_PROJECT_REQUEST_PKG.update_row
		 (   p_request_id            =>p_request_id,
		 p_request_status_code   =>'122',
		 p_closed_date		        =>sysdate,
		 x_return_status         =>x_return_status,
		 x_msg_count             =>x_msg_count,
		 x_msg_data              =>x_msg_data );


EXCEPTION
	 WHEN close_req_not_allowed THEN
		 PA_UTILS.add_message(p_app_short_name    => 'PA',
			p_msg_name          => 'PA_CANNOT_CLOSE_REQ');
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_msg_count := FND_MSG_PUB.Count_Msg;
			x_msg_data := 'PA_CANNOT_CLOSE_REQ';

			IF x_msg_count = 1 THEN
				 pa_interface_utils_pub.get_messages
					 (p_encoded        => FND_API.G_TRUE,
					 p_msg_index      => 1,
					 p_msg_count      => x_msg_count,
					 p_msg_data       => x_msg_data,
				       --p_data           => x_msg_data,                * Commented for Bug: 4537865
                                         p_data           => l_new_msg_data,            -- added for Bug Fix: 4537865
					 p_msg_index_out  => l_msg_index_out );
			-- added for Bug Fix: 4537865
			x_msg_data := l_new_msg_data;
			-- added for Bug Fix: 4537865
			END IF;


	 WHEN OTHERS THEN

		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		 x_msg_count     := FND_MSG_PUB.Count_Msg;
		 x_msg_data      := substr(SQLERRM,1,240);

		 -- Set the excetption Message and the stack
		 FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_REQUEST_PVT.close_project_request'
			 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
		 IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,                * Commented for Bug: 4537865
                                        p_data           => l_new_msg_data,            -- added for Bug Fix: 4537865
					p_msg_index_out  => l_msg_index_out );
 		 -- added for Bug Fix: 4537865
                        x_msg_data := l_new_msg_data;
                 -- added for Bug Fix: 4537865
		 END IF;

		 RAISE; -- This is optional depending on the needs


END close_project_request;



--Procedure: get_quick_entry_defaults
--Purpose:   Defaults the quick entry, when create a project from a selected request.
--Note: In parameter template_id is not used currently

PROCEDURE get_quick_entry_defaults (
                p_request_id    IN      NUMBER,
                p_template_id   IN      NUMBER,
		x_field_names   OUT  NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE,  --File.Sql.39 bug 4440895
		x_field_values 	OUT  NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,  --File.Sql.39 bug 4440895
		x_field_types 	OUT  NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE,  --File.Sql.39 bug 4440895
		x_return_status OUT  NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
		x_msg_count     OUT  NOCOPY NUMBER,  --File.Sql.39 bug 4440895
		x_msg_data      OUT  NOCOPY VARCHAR2) IS  --File.Sql.39 bug 4440895

	 -- Declare local variables
	 l_name			  	            VARCHAR(80);
	 l_segment1           	    VARCHAR(80);
	 l_description             	VARCHAR(300);
	 l_project_value           	NUMBER;
	 l_opp_value_currency_code 	VARCHAR(15);
	 l_expected_approval_date  	DATE          ;
	 --This variable holds customer account name
	 l_customer_name            VARCHAR(300);
	 l_country                  VARCHAR2(80)  ;
	 l_state_region             VARCHAR2(80)  ;
	 l_city                     VARCHAR2(80);
	 l_customer_orgnization     VARCHAR2(360);

   l_lead_id                 NUMBER;
   l_probability             NUMBER;
   -- added for Bug Fix: 4537865
   l_two_probability	     NUMBER;
   -- added for Bug Fix: 4537865
   l_org_role_type           VARCHAR2(80);
   l_org_role_name           VARCHAR2(80);
   l_request_type            VARCHAR2(80);
   l_probability_member_id   NUMBER;
   l_probability_list_id     NUMBER;
   l_index                   NUMBER;
   l_msg_index_out           NUMBER;
   l_org_role_id             NUMBER;
   l_opp_org_role_name       VARCHAR2(80);

   l_dest_value_pk2          NUMBER;
   l_dest_value_pk3          NUMBER;
   l_dest_value_pk4          NUMBER;
   l_dest_value_pk5          NUMBER;
   -- added for Bug Fix: 4537865
   l_new_msg_data	     VARCHAR2(2000);
   -- added for Bug Fix: 4537865
   l_person_role_type_tab    PA_PLSQL_DATATYPES.Char250TabTyp;
   l_key_member_tab	         PA_PLSQL_DATATYPES.Char250TabTyp;

   l_lead_number             AS_LEADS_ALL.lead_number%TYPE;
   l_lead_description        AS_LEADS_ALL.description%TYPE;
   l_request_type_meaning    FND_LOOKUPS.meaning%TYPE;

   -- Cursor to get the source lead_id for the passed in project request.

	 CURSOR cur_lead_id IS
		 SELECT object_id_to1
			 FROM pa_object_relationships
			 WHERE relationship_type = 'A'
			 AND relationship_subtype = 'PROJECT_REQUEST'
			 AND object_type_from = 'PA_PROJECT_REQUESTS'
			 AND object_id_from1 = p_request_id
			 AND object_type_to = 'AS_LEADS';

	 -- Cursor to get the probability value for a opportunity
   -- 2418549: Should not default quick entry is the probability is disabled.
	 CURSOR cur_probability (p_lead_id NUMBER ) IS
		 SELECT
		 l.win_probability
			 FROM as_leads_all l, as_forecast_prob_all_vl p
			 WHERE l.lead_id = p_lead_id
       AND l.win_probability = p.probability_value
       AND (p.end_date_active IS NULL OR p.end_date_active >= SYSDATE);

   -- Cursor to get the probability list id for a project template
   CURSOR cur_probability_list (p_template_id NUMBER ) IS
     SELECT probability_list_id
       FROM pa_project_types_all t, pa_projects_all p
   --Added the org_id join for bug 5561036
       WHERE t.org_id = p.org_id
       AND p.project_id = p_template_id
       AND  t.project_type = p.project_type;

   -- Cursor to get the quick entry default values
   -- Return only one record.
   -- 2401402: Default country name instead of country code.
	 CURSOR cur_quick_entry_def  IS
		 SELECT r.request_name name,
			 r.request_name segment1,
			 r.description description,
			 r.value project_value,
			 r.currency_code opp_value_currency_code,
			 r.expected_project_approval_date expected_approval_date,
			 p.party_name customer_name,--bug#9132476
			 ft.territory_short_name country,
			 lc.state state_region,
			 lc.city city,
			 p.party_name customer_orgnization,
			 r.request_type
			 FROM
			 pa_project_requests r,
			 hz_parties p,
			 hz_party_sites s,
			 --hz_cust_accounts a,--bug#9132476
			 hz_locations lc,
       fnd_territories_vl ft
			 WHERE r.cust_party_id = p.party_id(+)
			 AND r.cust_party_site_id = s.party_site_id(+)
			 --AND r.cust_account_id = a.cust_account_id(+)--bug#9132476
			 AND s.location_id =lc.location_id(+)
       AND lc.country = ft.territory_code(+)
			 AND r.request_id = p_request_id;

		 -- Cursor to get key members' mapped project person roles and
     -- key member name. Could be multiple records

		 CURSOR cur_key_members IS
			 SELECT
			   rt.project_role_type,
				 rdv.resource_name
				 FROM
				 pa_project_role_types rt,
				 pa_proj_request_directory_v rdv
				 WHERE
				 rdv.request_id = p_request_id
				 AND rt.project_role_id =rdv.project_role_id
				 AND rdv.owner_flag = 'Y' -- Bug 6195865
				 ORDER BY rdv.resource_name  ;

    -- Cursor to get lead number and description for an opportunity
    CURSOR cur_get_lead_info (p_lead_id NUMBER) IS
      SELECT lead_number, description
       FROM as_leads_all
      WHERE lead_id = p_lead_id;

BEGIN
	 x_return_status := FND_API.G_RET_STS_SUCCESS;

	 debug('Start get_quick_entry_defaults');
	 OPEN cur_quick_entry_def;
	 FETCH cur_quick_entry_def
		 INTO
		 l_name,
		 l_segment1,
		 l_description ,
		 l_project_value ,
		 l_opp_value_currency_code,
		 l_expected_approval_date ,
		 l_customer_name ,
		 l_country ,
		 l_state_region ,
   	 l_city ,
   	 l_customer_orgnization,
		 l_request_type ;

	 debug('After fetch');
	 IF cur_quick_entry_def%NOTFOUND THEN
	    debug('After fetch: 1');
			CLOSE cur_quick_entry_def;
	 ELSE
	    debug('After fetch: 2');
	    CLOSE cur_quick_entry_def;
	 END IF;

   debug('After close');
   x_field_names := SYSTEM.PA_VARCHAR2_30_TBL_TYPE('NAME');
   x_field_values := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE(l_name);
   x_field_types := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(null);

   debug('After init of tables');
   x_field_names.extend(9);
   x_field_values.extend(9);
   x_field_types.extend(9);

   debug('After extend of tables');
	 x_field_names(2)   	:= 'SEGMENT1';
	 x_field_values(2) 	:= l_segment1;
	 x_field_types(2)    := null;
	 x_field_names(3) 	  := 'DESCRIPTION';
	 x_field_values(3) 	:= l_description;
	 x_field_types(3)    := null;
	 x_field_names(4) 	  := 'PROJECT_VALUE';
	 x_field_values(4) 	:= l_project_value;
	 x_field_types(4)    := null;
	 x_field_names(5) 	  := 'OPP_VALUE_CURRENCY_CODE';
	 x_field_values(5) 	:= l_opp_value_currency_code ;
	 x_field_types(5)    := null;
	 x_field_names(6) 	  := 'EXPECTED_APPROVAL_DATE';
	 x_field_values(6) 	:= l_expected_approval_date  ;
	 x_field_types(6)    := null;
	 x_field_names(7)   	:= 'CUSTOMER_NAME'; --customer account
	 x_field_values(7) 	:= l_customer_name;
	 x_field_types(7)    := null;
	 x_field_names(8) 	  := 'COUNTRY';
	 x_field_values(8) 	:= l_country;
	 x_field_types(8)    := null;
	 x_field_names(9) 	  := 'STATE_REGION';
	 x_field_values(9) 	:= l_state_region;
	 x_field_types(9)    := null;
	 x_field_names(10) 	:= 'CITY';
	 x_field_values(10) 	:= l_city;
	 x_field_types(10)   := null;

   OPEN cur_lead_id;
   FETCH cur_lead_id
      INTO l_lead_id;
   CLOSE cur_lead_id;

   Debug('l_lead_id = ' || l_lead_id);

	 OPEN cur_probability(l_lead_id);
	 FETCH cur_probability
		 INTO l_probability;
	 IF cur_probability%NOTFOUND THEN
			CLOSE cur_probability;
			l_probability := NULL;
   ELSE
	    CLOSE cur_probability;
	 END IF;
   debug('Before calling get mapped probability');
   debug('Source Probability = ' ||  l_probability);

   OPEN cur_probability_list(p_template_id);
   FETCH cur_probability_list
     INTO l_probability_list_id;
   debug('proability_list_id = '|| l_probability_list_id);

	 --get mapped project probability
	 IF l_probability IS NOT NULL THEN
			PA_MAPPING_PVT.get_dest_values(
				p_value_map_def_type  		 => 'PROBABILITY_OPP_PROJ',
				p_def_subtype  		 				 => l_request_type,
				p_source_value             => l_probability,
				p_source_value_pk1 	 			 => NULL,
				p_source_value_pk2 	       => NULL,
				p_source_value_pk3 	       => NULL,
				p_source_value_pk4  	     => NULL,
				p_source_value_pk5         => NULL,
        p_probability_list_id      => l_probability_list_id,
			      --x_dest_value   		         => l_probability,                 * Commented for Bug: 4537865
				x_dest_value			 => l_two_probability,		   -- added for Bug: 4537865
					x_dest_value_pk1  	       => l_probability_member_id,
					x_dest_value_pk2  	 	     => l_dest_value_pk2 ,
					x_dest_value_pk3   	       => l_dest_value_pk3,
					x_dest_value_pk4   	       => l_dest_value_pk4,
					x_dest_value_pk5   	       => l_dest_value_pk5,
					x_return_status    	       => x_return_status ,
					x_msg_count   		         => x_msg_count ,
        x_msg_data     		         => x_msg_data );
    END IF;
    -- added for Bug Fix: 4537865
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    l_probability := l_two_probability;
    END IF;
    -- added for Bug Fix: 4537865

    debug('After calling get mapped probability');
    debug('Mapped Project Probability = ' ||  l_probability);
    debug('Mapped Project Probability Member ID = ' || l_probability_member_id);

    --get opportunity organization role.

    SELECT meaning
    INTO l_opp_org_role_name
    FROM pa_lookups
    WHERE lookup_type='OPPORTUNITY_ORG_ROLE'
    AND lookup_code = 'CUSTOMER';

    debug('l_opp_org_role_name = ' || l_opp_org_role_name);

    --get mapped organization role

   PA_MAPPING_PVT.get_dest_values(
        p_value_map_def_type       => 'ORG_ROLE_OPP_PROJ',
        p_def_subtype  		         => l_request_type,
        p_source_value             => l_opp_org_role_name,
	      p_source_value_pk1 	       => NULL,
	      p_source_value_pk2 	       => NULL,
	      p_source_value_pk3 	       => NULL,
	      p_source_value_pk4  	     => NULL,
	      p_source_value_pk5         => NULL,
	      x_dest_value   		         => l_org_role_name,
        x_dest_value_pk1  	       => l_org_role_id,
	      x_dest_value_pk2  	       => l_dest_value_pk2 ,
	      x_dest_value_pk3   	       => l_dest_value_pk3,
	      x_dest_value_pk4   	       => l_dest_value_pk4,
	      x_dest_value_pk5   	       => l_dest_value_pk5,
        x_return_status    	       => x_return_status ,
        x_msg_count   		         => x_msg_count ,
        x_msg_data     		         => x_msg_data );

    x_field_names.extend(1);
    x_field_values.extend(1);
    x_field_types.extend(1);

    x_field_names(11) 	:= 'PROBABILITY_MEMBER_ID';
    x_field_values(11) 	:= l_probability_member_id;
    x_field_types(11)   := null;

    if (l_org_role_id is not null) then
       BEGIN
       select project_role_type
       into l_org_role_type
       from pa_project_role_types_vl
       where project_role_id = l_org_role_id;
       EXCEPTION WHEN NO_DATA_FOUND THEN
         l_org_role_type := null;
         debug('No org role type for role.');
       END;

       if (l_org_role_type is not null) then
          x_field_names.extend(1);
          x_field_values.extend(1);
          x_field_types.extend(1);
          x_field_names(12) 	:= 'ORG_ROLE'; --ORGNIZATION_ROLE
          x_field_values(12) 	:= l_customer_orgnization;
          x_field_types(12)   := l_org_role_type;
       end if;

    end if;

/* Added if condition Bug 3632760  Need not create project team members by
 * default in new ASN model*/
/* Removing if condition as part of opportunity owner mapping enhancement */
 /*  IF (FND_PROFILE.Value('AS_ACTIVATE_SALES_INTEROP') IS NULL) THEN  */

    OPEN cur_key_members;
    FETCH cur_key_members
    BULK COLLECT INTO
		 l_person_role_type_tab,
             l_key_member_tab
             LIMIT 150;
    CLOSE cur_key_members ;

    l_index := x_field_names.count + 1;
    IF NVL(l_key_member_tab.COUNT,0) <> 0 THEN

       x_field_names.extend(l_key_member_tab.COUNT);
       x_field_values.extend(l_key_member_tab.COUNT);
       x_field_types.extend(l_key_member_tab.COUNT);

       FOR i IN l_key_member_tab.FIRST..l_key_member_tab.LAST LOOP
          x_field_names(l_index) 	 := 'KEY_MEMBER';
          x_field_values(l_index) 	 := l_key_member_tab(i);
          x_field_types(l_index)    := l_person_role_type_tab(i);
          l_index := l_index +1;
       END LOOP;
    END IF;

 /*  END IF;  */


    l_key_member_tab.delete;
    l_person_role_type_tab.delete;

    -- Project Long Name changes
    l_index := x_field_names.count + 1;
    x_field_names.extend(1);
    x_field_values.extend(1);
    x_field_types.extend(1);

    OPEN cur_get_lead_info(l_lead_id);
    FETCH cur_get_lead_info
    INTO l_lead_number, l_lead_description;

    SELECT meaning
    INTO l_request_type_meaning
    FROM pa_lookups
    WHERE lookup_type = 'PROJECT_REQUEST_TYPE'
    AND lookup_code = l_request_type;

    x_field_names(l_index) := 'LONG_NAME';
    x_field_values(l_index):= l_request_type_meaning ||' '||
                               SUBSTR(l_lead_description, 1, 120)||' '||
                               l_lead_number;
    x_field_types(l_index) := null;

EXCEPTION
       WHEN OTHERS THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         x_msg_count     := FND_MSG_PUB.Count_Msg;
         x_msg_data      := substr(SQLERRM,1,240);

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_REQUEST_PVT.get_quick_entry_defaults'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         IF x_msg_count = 1 THEN
            pa_interface_utils_pub.get_messages
                         (p_encoded        => FND_API.G_TRUE,
                          p_msg_index      => 1,
                          p_msg_count      => x_msg_count,
                          p_msg_data       => x_msg_data,
			--p_data           => x_msg_data,                * Commented for Bug: 4537865
                          p_data           => l_new_msg_data,            -- added for Bug Fix: 4537865
                          p_msg_index_out  => l_msg_index_out );
	 -- added for Bug Fix: 4537865
         x_msg_data := l_new_msg_data;
         -- added for Bug Fix: 4537865
         END IF;

         RAISE; -- This is optional depending on the needs

END get_quick_entry_defaults;

--Procedure: manage_project_requests
--Purpose:   This procedure is called by concurrent program. It calls
--Procedure create_project_requests and update_projects.

PROCEDURE manage_project_requests
          (p_run_mode                      IN     VARCHAR2,
           p_source_application_id         IN     NUMBER,
           p_request_type         	       IN     VARCHAR2,
           p_probability_from     	       IN     NUMBER,
           p_probability_to       	       IN     NUMBER,
	         p_closed_date_within_days       IN 	  NUMBER,
	         p_status		     	  	           IN     VARCHAR2,
	         p_sales_stage_id       	       IN 	  NUMBER,
	         p_value_from		  	             IN	    NUMBER,
	         p_value_to  		  	             IN     NUMBER,
	         p_currency_code        	       IN 	  VARCHAR2,
	         p_classification 	  	         IN     VARCHAR2,
	         p_calling_module   	  	         IN     VARCHAR2,
           p_update_probability       	   IN     VARCHAR2,
	         p_update_value             	   IN     VARCHAR2,
           p_update_exp_appr_date  	       IN     VARCHAR2,
           x_return_status        	       OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
           x_msg_count            	       OUT    NOCOPY NUMBER,  --File.Sql.39 bug 4440895
           x_msg_data                      OUT    NOCOPY VARCHAR2) IS  --File.Sql.39 bug 4440895

   l_is_profile_defined VARCHAR2(1) := NULL;
   l_msg_index_out	     	  NUMBER;
   incompatible_prog     EXCEPTION;
   -- added for Bug: 4537865
   l_new_msg_data		  VARCHAR2(2000);
   -- added for Bug: 4537865
BEGIN
	 Debug('Enter manage_project_requests');

   x_return_status 	:= FND_API.G_RET_STS_SUCCESS;

   IF (FND_PROFILE.Value('AS_ACTIVATE_SALES_INTEROP') IS NULL) THEN
      l_is_profile_defined := 'N' ;
   ELSE
      l_is_profile_defined := 'Y';
   END IF;

   Debug('l_is_profile_defined is [' || l_is_profile_defined||'] calling module ['||p_calling_module ||']');
   -- Raise exception if
   --     1.  If PRC: Manage Project Requests and Maintain Projects is called from OSO
   --     2.  If PRC: Manage Project Request is run when ASN is installed

   IF (  (p_calling_module = 'Oracle Sales Online' and l_is_profile_defined = 'Y' ) OR
         (p_calling_module = 'Oracle Sales' and l_is_profile_defined = 'N' )    ) THEN

      RAISE incompatible_prog ;

   END IF;

   IF p_run_mode = 'CREATE_REQUEST' OR
      p_run_mode = 'CREATE_AND_UPDATE' THEN

			--Call procedure create_project_requests
			Debug('Call procedure create_project_requests ');
      create_project_requests
          (p_source_application_id   	,
           p_request_type         	  ,
           p_probability_from     	  ,
	         p_probability_to       	  ,
	         p_closed_date_within_days  ,
	         p_status		     	  	      ,
	         p_sales_stage_id    	      ,
	         p_value_from		  	        ,
	         p_value_to  		  	        ,
	         p_currency_code     	      ,
	         p_classification 		      ,
                 l_is_profile_defined         ,
           x_return_status           	,
           x_msg_count         	      ,
           x_msg_data) ;
    END IF;

    IF p_run_mode = 'UPDATE_PROJECT' OR
      p_run_mode = 'CREATE_AND_UPDATE' THEN

			debug('Call procedure update_projects');
      --Call procedure update_projects
      update_projects
	        (p_source_application_id         ,
           p_request_type         	       ,
           p_probability_from     	       ,
           p_probability_to       	       ,
	         p_closed_date_within_days       ,
	         p_status		     	  	           ,
	         p_sales_stage_id        	       ,
	         p_value_from		  	             ,
	         p_value_to  		  	             ,
	         p_currency_code        	       ,
	         p_classification 	  	         ,
                 l_is_profile_defined         ,
           p_update_probability       	   ,
	         p_update_value             	   ,
           p_update_exp_appr_date  	       ,
           x_return_status        	       ,
           x_msg_count            	       ,
           x_msg_data);
     END IF;

 EXCEPTION

   WHEN incompatible_prog THEN

       x_return_status := FND_API.G_RET_STS_ERROR;

          IF   (p_calling_module = 'Oracle Sales Online' and l_is_profile_defined = 'Y' ) THEN

               PA_UTILS.add_message(p_app_short_name    => 'PA',
                                    p_msg_name          => 'PA_ORG_SALE_INCOMPAT_PROGRAM');

               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_count := FND_MSG_PUB.Count_Msg;
               x_msg_data := ' PA_ORG_SALE_INCOMPAT_PROGRAM';

          ELSIF (p_calling_module = 'Oracle Sales' and l_is_profile_defined = 'N' ) THEN

               PA_UTILS.add_message(p_app_short_name    => 'PA',
                                    p_msg_name          => 'PA_ORG_SALE_ONLINE_INCOMPAT');

               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_count := FND_MSG_PUB.Count_Msg;
               x_msg_data := 'PA_ORG_SALE_ONLINE_INCOMPAT';

          END IF;

	IF x_msg_count = 1 THEN
		 pa_interface_utils_pub.get_messages
	        	 (p_encoded        => FND_API.G_FALSE,
		  	  p_msg_index      => 1,
			  p_msg_count      => x_msg_count,
			  p_msg_data       => x_msg_data,
			--p_data           => x_msg_data, * commented for Bug: 4537865
			  p_data	   => l_new_msg_data,	-- added for Bug: 4537865
			 p_msg_index_out  => l_msg_index_out );
			-- added for Bug: 4537865
			x_msg_data := l_new_msg_data;
			-- added for Bug: 4537865
	END IF;
        debug('');
        debug('+-----------------------------------------------------------------------------+');
        debug('Exception '||x_msg_data);
        debug('+-----------------------------------------------------------------------------+');
   WHEN OTHERS THEN
     x_msg_count     := 1;
     x_msg_data      := sqlerrm;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJECT_REQUEST_PVT',
       p_procedure_name => 'manage_project_requests');
     RAISE;

END manage_project_requests;


--Procedure: create_project_requests
--Purpose:   This procedure is called by manage_project_requests.
--           It creats the project requests for the user specified
--           opportunities

PROCEDURE create_project_requests
	   (p_source_application_id   	 IN     NUMBER,
         p_request_type         	      IN     VARCHAR2,
         p_probability_from     	      IN     NUMBER,
         p_probability_to       	      IN     NUMBER,
         p_closed_date_within_days       IN 	   NUMBER,
         p_status		     	  	 IN     VARCHAR2,
         p_sales_stage_id        	      IN 	   NUMBER,
         p_value_from		  	      IN	   NUMBER,
         p_value_to  		  	      IN	   NUMBER,
         p_currency_code        	      IN 	   VARCHAR2,
         p_classification 	  	      IN     VARCHAR2,
         p_is_profile_defined 	  	      IN     VARCHAR2,
         x_return_status           	 OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
         x_msg_count            	      OUT    NOCOPY NUMBER,  --File.Sql.39 bug 4440895
         x_msg_data             	      OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
    -- Cursor to select all the opportunities based on the parameters entered
    -- by user for project requests creation.
      TYPE cur_sel_opportunities_typ IS REF CURSOR;
      cur_sel_opportunities cur_sel_opportunities_typ ;

      stmt_class1 VARCHAR2(1000);
      stmt_class2 VARCHAR2(1000);
      stmt_class3 VARCHAR2(1000);
      stmt_class4 VARCHAR2(1000);
      stmt_class5 VARCHAR2(1000);
      stmt_categ1 VARCHAR2(1000);
      stmt_categ2 VARCHAR2(1000);
      stmt_categ3 VARCHAR2(1000);
      stmt_categ4 VARCHAR2(1000);
      stmt_categ5 VARCHAR2(1000);

      stmt VARCHAR2(3200);


--     cur_sel_opportunities_rec  cur_sel_opp_temp%ROWTYPE;
    TYPE cur_sel_opportunities_rec_type IS RECORD
    (    request_name varchar2(300),
         description  varchar2(240),
         cust_party_id number,
         cust_party_site_id number,
         value number,
         currency_code varchar2(15),
         expected_project_approval_date date,
         source_reference varchar2(30),
         lead_id number,
         source_org_id number,
         category varchar2(1000)
     );

     cur_sel_opportunities_rec cur_sel_opportunities_rec_type;

   CURSOR cur_sel_account_id (p_party_id NUMBER ) IS
           SELECT cust_account_id
           FROM hz_cust_accounts
           WHERE party_id = p_party_id;

   CURSOR cur_report_info (p_request_id NUMBER ) IS
      SELECT
         p.party_name request_customer,
         l.country,
         l.state,
         l.city
      FROM
         pa_project_requests r,
         hz_parties p,
         hz_party_sites s,
         hz_locations l
      WHERE
         r.cust_party_id = p.party_id(+)
         AND r.cust_party_site_id = s.party_site_id(+)
         AND s.location_id =l.location_id(+)
         AND r.request_id =p_request_id;
         -- 2910113: Removed FOR UPDATE because the cursor triggers
         -- ORA-02014 error. Locking is not necessary for this cursor.
         -- FOR UPDATE
         -- End of 2910113

   l_request_customer   hz_parties.party_name%TYPE;
   l_country		    hz_locations.country%TYPE;
   l_state		    hz_locations.state%TYPE;
   l_city			    hz_locations.city%TYPE;
   l_account_id         NUMBER;
   l_number_of_accounts NUMBER;
   l_cust_party_id      NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_msg_count          NUMBER;
   l_request_id         NUMBER;
   l_request_number     VARCHAR2(25);
   v_count              BINARY_INTEGER := 0;

   -- 2384213: p_classification is a concatinated string like
   -- 'interest_type_id/primary_interest_code_id/secondary_interest_id'. This string
   -- needs to be broken down into the following three local variables.

   l_interest_type_id as_interests_all.interest_type_id%TYPE :=null;
   l_primary_interest_code_id as_interests_all.primary_interest_code_id%TYPE :=null;
   l_secondary_interest_code_id as_interests_all.secondary_interest_code_id%TYPE :=null;
   l_position_1              NUMBER;
   l_position_2              NUMBER;

BEGIN
Debug('entered create project request');

stmt_class1 := 'SELECT DISTINCT lookups.meaning || '' '' || nvl(l.lead_number,'''') request_name,l.description description, '
       ||  'l.customer_id cust_party_id,'
       ||  'l.address_id cust_party_site_id,'
       ||  'l.total_amount value,'
       ||  'l.currency_code currency_code,'
       ||  'l.decision_date expected_project_approval_date,l.lead_number  source_reference,'
       ||  'l.lead_id lead_id,'
       ||  'l.org_id source_org_id,'
       ||  'null as category ' ; /* removed h.category for bug 3744823 */

stmt_class2 := ' FROM as_leads  l, as_interests i, pa_lookups lookups'
       ||  ' WHERE  '
       ||  'lookups.lookup_type = ''PROJECT_REQUEST_TYPE'' '
       ||  ' AND lookups.lookup_code = :1'
       ||  ' AND ('
       ||  ' l.win_probability >= nvl(:2, 0) OR'
       ||  ' (l.win_probability IS NULL AND :2 IS NULL)'
       ||' ) '
       ||' AND ( l.win_probability <= nvl(:3, 100) OR'
       ||' (l.win_probability IS NULL AND :3 IS NULL )'
       ||'  )  '
       ||' AND   l.status = nvl(:4,l.status) '
       ||' AND   (l.decision_date >= sysdate - nvl(:5, 365000 ) OR'
       ||'          l.decision_date IS NULL )';

stmt_class3 := ' AND ('
       ||'         l.sales_stage_id  = nvl(:6,l.sales_stage_id) OR'
       ||'        (l.sales_stage_id IS NULL AND :6 IS NULL)'
       ||'       )'
       ||'AND ( l.total_amount >= nvl(:7, l.total_amount ) OR'
       ||'    (l.total_amount IS NULL AND :7 IS NULL)'
       ||'       ) '
       ||'AND ( l.total_amount  <=nvl(:8,l.total_amount ) OR '
       ||'        (l.total_amount IS NULL AND :8 IS NULL)'
       ||'       )  '
       ||'AND ( l.currency_code =nvl(:9, l.currency_code) OR'
       ||'        (l.currency_code IS NULL AND :9 IS NULL)'
       ||'       )';

stmt_class4 :=' AND ( '
       ||'     i.interest_type_id = nvl(:10,i.interest_type_id) OR'
       ||'         (i.interest_type_id IS NULL AND :10 IS NULL)'
       ||'       )'
       ||'AND (  '
       ||'         i.primary_interest_code_id = nvl(:11, i.primary_interest_code_id) OR'
       ||'        (i.primary_interest_code_id IS NULL AND :11 IS NULL)'
       ||  '       )'
       ||'AND (  '
       ||'         i.secondary_interest_code_id = nvl(:12, i.secondary_interest_code_id) OR'
       ||'    (i.secondary_interest_code_id IS NULL AND :12 IS NULL)'
       ||'   )'
       ||'AND  l.lead_id = i.lead_id (+)';

--Modified stmt_Class5 for bug 5728842. Added o.object_type_to = 'PA_PROJECT_REQUESTS' condition.
stmt_class5 :='AND l.lead_id NOT IN'
       ||'     (SELECT l.lead_id'
       ||'      FROM  as_leads l,'
       ||'        pa_object_relationships o,'
       ||'        pa_project_requests r'
       ||'      WHERE  l.lead_id = o.object_id_from1'
       ||'         AND  o.object_id_to1 = r.request_id'
       ||'     AND  o.object_type_to = ''PA_PROJECT_REQUESTS'''
       ||'     AND  r.request_type = :13 '
       ||'     AND o.relationship_type=''A'''
       ||'     AND o.relationship_subtype =''PROJECT_REQUEST'''
       ||'     AND object_type_from = ''AS_LEADS'')';


stmt_categ1 := 'SELECT DISTINCT lookups.meaning || '' '' || nvl(l.lead_number,'''') request_name,'
       ||' l.description description ,'
       ||' l.customer_id cust_party_id, '
       ||' l.address_id cust_party_site_id,'
       ||' l.total_amount value,'
       ||' l.currency_code currency_code,'
       ||' l.decision_date expected_project_approval_date,'
       ||' l.lead_number  source_reference,'
       ||' l.lead_id lead_id,'
       ||' l.org_id source_org_id,'
       ||' null as category ';

stmt_categ2 := ' FROM  as_leads  l'
       ||' , as_lead_lines_all ll'
       ||' , pa_lead_categories_v h'
       ||' , pa_lookups lookups         '
       ||'  WHERE  '
       ||' lookups.lookup_type = ''PROJECT_REQUEST_TYPE'' '
       ||' AND lookups.lookup_code = :1  '
       ||' AND  ll.product_category_id = h.category_id'
       ||' AND  l.lead_id = ll.lead_id '
       ||' AND ('
       ||'      l.win_probability >= nvl(:2, 0) OR'
       ||'     (l.win_probability IS NULL AND :2 IS NULL)'
       ||'     ) '
       ||' AND ('
       ||'      l.win_probability  <= nvl(:3, 100) OR'
       ||'     (l.win_probability IS NULL AND :3 IS NULL )'
       ||'     )  ';

stmt_categ3 :=    '      AND   l.status = nvl(:4,l.status) '
       ||' AND (l.decision_date >= sysdate - nvl(:5, 365000 ) OR'
       ||'        l.decision_date IS NULL )'
       ||' AND ('
       ||'      l.sales_stage_id  = nvl(:6,l.sales_stage_id) OR'
       ||'     (l.sales_stage_id IS NULL AND :6 IS NULL)'
       ||'     )'
       ||' AND ('
       ||'      l.total_amount >= nvl(:7, l.total_amount ) OR'
       ||'     (l.total_amount IS NULL AND :7 IS NULL)'
       ||'      ) '
       ||' AND ('
       ||'      l.total_amount  <=nvl(:8,l.total_amount ) OR '
       ||'     (l.total_amount IS NULL AND :8 IS NULL)'
       ||'     )  ';

 stmt_categ4 :='  AND ('
       ||'    l.currency_code =nvl(:9, l.currency_code) OR'
       ||'   (l.currency_code IS NULL AND :9 IS NULL)'
       ||'   )'
       ||'  AND ('
       ||'       h.category = nvl(:10, h.category) OR'
       ||'      ( h.category like :10||''/%'')'
       ||'      ) ';

 stmt_categ5 :='      AND l.lead_id NOT IN'
       ||'  (SELECT l.lead_id'
       ||'  FROM  as_leads l,'
       ||'  pa_object_relationships o,'
       ||'  pa_project_requests r'
       ||'  WHERE  l.lead_id = o.object_id_from1'
       ||'  AND  o.object_id_to1 = r.request_id'
       ||'  AND  r.request_type =:11  '
       ||'  AND o.relationship_type=''A'' '
       ||'  AND o.relationship_subtype =''PROJECT_REQUEST'' '
       ||'  AND object_type_from = ''AS_LEADS'')';

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF (p_is_profile_defined = 'N') THEN
      -- Process p_classification.
      l_position_1 := INSTR(p_classification, '/');
      l_position_2 := INSTR(p_classification, '/', 1, 2);

      IF l_position_1 = 0 THEN
        l_interest_type_id := TO_NUMBER(p_classification);
        l_primary_interest_code_id := NULL;
        l_secondary_interest_code_id := NULL;
      ELSIF l_position_2 = 0 THEN
        l_interest_type_id := TO_NUMBER(SUBSTR(p_classification, 1, l_position_1-1));
        l_primary_interest_code_id := TO_NUMBER(SUBSTR(p_classification, l_position_1+1));
        l_secondary_interest_code_id := NULL;
      ELSE
        l_interest_type_id := TO_NUMBER(SUBSTR(p_classification, 1, l_position_1-1));
        l_primary_interest_code_id := TO_NUMBER(SUBSTR(p_classification, l_position_1+1, l_position_2-l_position_1-1));
        l_secondary_interest_code_id := TO_NUMBER(SUBSTR(p_classification, l_position_2+1));
      END IF;

     Debug('l_interest_type_id = '|| l_interest_type_id);
     Debug('l_primary_interest_code_id = '|| l_primary_interest_code_id);
     Debug('l_secondary_interest_code_id = '|| l_secondary_interest_code_id);

   END IF;

  IF (p_is_profile_defined = 'N') THEN
       Debug(substr(stmt_class1,1,250));
       Debug(substr(stmt_class1,251,500));
       Debug(substr(stmt_class1,501,750));
       Debug(substr(stmt_class1,751,1000));
       Debug(substr(stmt_class1,1001,1250));
       Debug(substr(stmt_class1,1251,1500));
       Debug(substr(stmt_class1,1501,1750));
       Debug(substr(stmt_class1,1751,2000));
       Debug(substr(stmt_class2,1,250));
       Debug(substr(stmt_class2,251,500));
       Debug(substr(stmt_class2,501,750));
       Debug(substr(stmt_class2,751,1000));
       Debug(substr(stmt_class2,1001,1250));
       Debug(substr(stmt_class2,1251,1500));
       Debug(substr(stmt_class2,1501,1750));
       Debug(substr(stmt_class2,1751,2000));
       Debug(substr(stmt_class3,1,250));
       Debug(substr(stmt_class3,251,500));
       Debug(substr(stmt_class3,501,750));
       Debug(substr(stmt_class3,751,1000));
       Debug(substr(stmt_class3,1001,1250));
       Debug(substr(stmt_class3,1251,1500));
       Debug(substr(stmt_class3,1501,1750));
       Debug(substr(stmt_class3,1751,2000));
       Debug(substr(stmt_class4,1,250));
       Debug(substr(stmt_class4,251,500));
       Debug(substr(stmt_class4,501,750));
       Debug(substr(stmt_class4,751,1000));
       Debug(substr(stmt_class4,1001,1250));
       Debug(substr(stmt_class4,1251,1500));
       Debug(substr(stmt_class4,1501,1750));
       Debug(substr(stmt_class4,1751,2000));
       Debug(substr(stmt_class5,1,250));
       Debug(substr(stmt_class5,251,500));
       Debug(substr(stmt_class5,501,750));
       Debug(substr(stmt_class5,751,1000));
       Debug(substr(stmt_class5,1001,1250));
       Debug(substr(stmt_class5,1251,1500));
       Debug(substr(stmt_class5,1501,1750));
       Debug(substr(stmt_class5,1751,2000));


       stmt := stmt_class1 || stmt_class2||stmt_class3|| stmt_class4|| stmt_class5;
       Debug(':1 ['||p_request_type||'] :2 ['||p_probability_from||']:3 ['||p_probability_to||']:4 ['||p_status||']');
       Debug(':5 ['||p_closed_date_within_days||']:6 ['||p_sales_stage_id||']:7 ['||p_value_from||']:8 ['||p_value_to||']');
       Debug(':9 ['||p_currency_code||']:10 ['||l_interest_type_id||']:11 ['||l_primary_interest_code_id||']:12 ['||l_secondary_interest_code_id||']');

       OPEN cur_sel_opportunities FOR stmt
                  USING p_request_type,                        --:1
                        p_probability_from,p_probability_from, --:2
                        p_probability_to,p_probability_to,     --:3
                        p_status,                              --:4
                        p_closed_date_within_days,             --:5
                        p_sales_stage_id,p_sales_stage_id,     --:6
                        p_value_from,p_value_from,             --:7
                        p_value_to,p_value_to,                 --:8
                        p_currency_code,p_currency_code,       --:9
                        l_interest_type_id,l_interest_type_id, --:10
                        l_primary_interest_code_id,l_primary_interest_code_id,       --:11
                        l_secondary_interest_code_id,l_secondary_interest_code_id,   --:12
                        p_request_type ;                       --:13
  ELSE
       stmt := stmt_categ1 ||stmt_categ2||stmt_categ3||stmt_categ4||stmt_categ5;
       Debug(substr(stmt_categ1,1,250));
       Debug(substr(stmt_categ1,251,500));
       Debug(substr(stmt_categ1,501,750));
       Debug(substr(stmt_categ1,751,1000));
       Debug(substr(stmt_categ1,1001,1250));
       Debug(substr(stmt_categ1,1251,1500));
       Debug(substr(stmt_categ1,1501,1750));
       Debug(substr(stmt_categ1,1751,2000));
       Debug(substr(stmt_categ2,1,250));
       Debug(substr(stmt_categ2,251,500));
       Debug(substr(stmt_categ2,501,750));
       Debug(substr(stmt_categ2,751,1000));
       Debug(substr(stmt_categ2,1001,1250));
       Debug(substr(stmt_categ2,1251,1500));
       Debug(substr(stmt_categ2,1501,1750));
       Debug(substr(stmt_categ2,1751,2000));
       Debug(substr(stmt_categ3,1,250));
       Debug(substr(stmt_categ3,251,500));
       Debug(substr(stmt_categ3,501,750));
       Debug(substr(stmt_categ3,751,1000));
       Debug(substr(stmt_categ3,1001,1250));
       Debug(substr(stmt_categ3,1251,1500));
       Debug(substr(stmt_categ3,1501,1750));
       Debug(substr(stmt_categ3,1751,2000));
       Debug(substr(stmt_categ4,1,250));
       Debug(substr(stmt_categ4,251,500));
       Debug(substr(stmt_categ4,501,750));
       Debug(substr(stmt_categ4,751,1000));
       Debug(substr(stmt_categ4,1001,1250));
       Debug(substr(stmt_categ4,1251,1500));
       Debug(substr(stmt_categ4,1501,1750));
       Debug(substr(stmt_categ4,1751,2000));
       Debug(substr(stmt_categ5,1,250));
       Debug(substr(stmt_categ5,251,500));
       Debug(substr(stmt_categ5,501,750));
       Debug(substr(stmt_categ5,751,1000));
       Debug(substr(stmt_categ5,1001,1250));
       Debug(substr(stmt_categ5,1251,1500));
       Debug(substr(stmt_categ5,1501,1750));
       Debug(substr(stmt_categ5,1751,2000));

       Debug(':1 ['||p_request_type||'] :2 ['||p_probability_from||']:3 ['||p_probability_to||']:4 ['||p_status||']');
       Debug(':5 ['||p_closed_date_within_days||']:6 ['||p_sales_stage_id||']:7 ['||p_value_from||']:8 ['||p_value_to||']');
       Debug(':9 ['||p_currency_code||']:10 ['||p_classification||']');

       OPEN cur_sel_opportunities FOR stmt
                  USING p_request_type,                        --:1
                        p_probability_from,p_probability_from, --:2
                        p_probability_to,p_probability_to,     --:3
                        p_status,                              --:4
                        p_closed_date_within_days,             --:5
                        p_sales_stage_id,p_sales_stage_id,     --:6
                        p_value_from,p_value_from,             --:7
                        p_value_to,p_value_to,                 --:8
                        p_currency_code,p_currency_code,       --:9
                        p_classification,p_classification,     --:10
                        p_request_type ;                       --:11

  END IF;

LOOP
FETCH cur_sel_opportunities INTO cur_sel_opportunities_rec;
EXIT WHEN cur_sel_opportunities%NOTFOUND;
  v_count := v_count + 1 ;
    Debug('PA_PROJECT_REQUEST_PVT.CREATE_PROJECT_REQUESTS: v_count = '|| v_count);
    Debug('Category ['||cur_sel_opportunities_rec.category||']' );
			l_cust_party_id :=  cur_sel_opportunities_rec.cust_party_id;
	  Debug('l_cust_party_id: ' || l_cust_party_id);

      --get customer account ID
      OPEN cur_sel_account_id (l_cust_party_id);
      FETCH cur_sel_account_id
      INTO l_account_id;

      IF cur_sel_account_id%NOTFOUND THEN
     Debug('cur_sel_account_id%NOTFOUND');

	       CLOSE cur_sel_account_id;
         l_account_id:= NULL;
			ELSE
				 CLOSE cur_sel_account_id;
			END IF;


	  Debug('l_account_id: ' || l_account_id);

			SELECT count(*)
				INTO l_number_of_accounts
				FROM hz_cust_accounts
				WHERE party_id = l_cust_party_id;

	  Debug('After select count(*)');

			IF l_number_of_accounts >1 THEN
         l_account_id:= NULL;
      END IF;

	  Debug('l_account_id: ' || l_account_id);

			--Call create project request public API
	  Debug('Call create project request public API');
      PA_PROJECT_REQUEST_PUB.create_project_request
      ( p_request_name                  =>cur_sel_opportunities_rec.request_name,
        p_request_type                  =>p_request_type,
        p_request_status_code           =>'121',
        p_request_status_name           => null,
        p_description                   =>cur_sel_opportunities_rec.description,
        p_expected_proj_approval_date   =>cur_sel_opportunities_rec.expected_project_approval_date,
        p_closed_date                   =>null,
        p_source_type                   =>'ORACLE_APPLICATION',
        p_application_id                =>p_source_application_id,
        p_source_reference              =>cur_sel_opportunities_rec.source_reference,
        p_source_id                     =>cur_sel_opportunities_rec.lead_id,
        p_source_object                 =>'AS_LEADS',
        p_value                         =>cur_sel_opportunities_rec.value,
        p_currency_code                 =>cur_sel_opportunities_rec.currency_code,
        p_cust_party_id                 =>cur_sel_opportunities_rec.cust_party_id,
        p_cust_party_name               => null,
        p_cust_party_site_id            =>cur_sel_opportunities_rec.cust_party_site_id,
        p_cust_party_site_name          => null,
        p_cust_account_id               =>l_account_id,
        p_cust_account_name             => null,
        p_source_org_id                 => cur_sel_opportunities_rec.source_org_id,
        p_attribute_category            => null,
        p_attribute1                    => 'Test Project Request',
        p_attribute2                    => null,
        p_attribute3                    => null,
        p_attribute4                    => null,
        p_attribute5                    => null,
        p_attribute6                    => null,
        p_attribute7                    => null,
        p_attribute8                    => null,
        p_attribute9                    => null,
        p_attribute10                   => null,
        p_attribute11                   => null,
        p_attribute12                   => null,
        p_attribute13                   => null,
        p_attribute14                   => null,
        p_attribute15                   => null,
        p_create_rel_flag               =>'Y',
        p_api_version                   => null,
        p_init_msg_list                 => null,
        p_commit                        => null ,
				p_validate_only                 => null ,
        p_max_msg_count                 => null ,
        x_request_id                    => l_request_id ,
        x_request_number                => l_request_number,
        x_return_status                 => x_return_status,
        x_msg_count                     =>x_msg_count,
        x_msg_data                      =>x_msg_data );
  Debug('l_request_id= ' || l_request_id);
  Debug('l_request_number= ' || l_request_number);

  Debug('Finish Create Request call');
      OPEN cur_report_info(l_request_id);
      FETCH cur_report_info
      INTO l_request_customer,
           l_country,
           l_state,
           l_city;
      CLOSE cur_report_info;

      /* Added the If condition for bug 3951787*/
      IF  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      PA_REQUESTS_CREATION_PKG.insert_row
      ( p_request_name                    =>cur_sel_opportunities_rec.request_name,
        p_request_number			       =>l_request_number,
        p_request_type                    => p_request_type,
        p_request_status_name             =>'Open',
        p_request_customer                =>l_request_customer,
        p_country				       =>l_country,
        p_state	                      =>l_state,
        p_city				            =>l_city,
        p_value                           =>cur_sel_opportunities_rec.value,
        p_currency_code                   =>cur_sel_opportunities_rec.currency_code,
        p_expected_proj_approval_date     =>cur_sel_opportunities_rec.expected_project_approval_date,
        p_source_reference                =>cur_sel_opportunities_rec.source_reference,
        x_return_status                   =>x_return_status,
        x_msg_count                       =>x_msg_count,
        x_msg_data                        =>x_msg_data);
       END IF;

       -- GET ERROR FROM ERROR STACK
       FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP

            FND_MSG_PUB.get (
            p_encoded        => FND_API.G_FALSE,
            p_msg_index      => i,
            p_data           => l_msg_data,
            p_msg_index_out  => l_msg_count );

            IF l_msg_data IS NOT NULL THEN
            --Insert the error into the temp table for the report display purpose.

            PA_REQUESTS_CREATION_WARN_PKG.insert_row
             (p_request_name        => cur_sel_opportunities_rec.request_name,
	            p_warning		    	    => l_msg_data,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data);

            END IF;
        END LOOP; -- error message loop

        IF v_count >=100 THEN
           COMMIT;
           v_count := 0;
        END IF;
    END LOOP;
   CLOSE cur_sel_opportunities;

EXCEPTION
   WHEN OTHERS THEN
     x_msg_count     := 1;
     x_msg_data      := sqlerrm;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJECT_REQUEST_PVT',
       p_procedure_name => 'create_project_requests');
     RAISE;

END create_project_requests;

--Procedure: update_projects
--Purpose:   This procedure is called by manage_project_requests.
--           It updates the opportunity related project specified
--           by users.


PROCEDURE update_projects
	    (p_source_application_id         IN     NUMBER,
       p_request_type         	       IN     VARCHAR2,
       p_probability_from     	       IN     NUMBER,
       p_probability_to       	       IN     NUMBER,
	     p_closed_date_within_days       IN 	  NUMBER,
	     p_status		     	  	           IN     VARCHAR2,
	     p_sales_stage_id       	       IN 	  NUMBER,
	     p_value_from		  	             IN	    NUMBER,
	     p_value_to  		  	             IN     NUMBER,
	     p_currency_code        	       IN 	  VARCHAR2,
	     p_classification 	  	         IN     VARCHAR2,
	     p_is_profile_defined  	         IN     VARCHAR2,
       p_update_probability            IN     VARCHAR2,
	     p_update_value             	   IN     VARCHAR2,
       p_update_exp_appr_date  	       IN     VARCHAR2,
       x_return_status        	       OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
       x_msg_count            	       OUT    NOCOPY NUMBER,  --File.Sql.39 bug 4440895
       x_msg_data                      OUT    NOCOPY VARCHAR2) IS  --File.Sql.39 bug 4440895


   -- Cursor to select all the opportunities related with the created projects
   -- based on the parameters entered.
   TYPE cur_sel_opportunities_typ IS REF CURSOR;
      cur_sel_opportunities cur_sel_opportunities_typ ;

      stmt_class1 VARCHAR2(1000);
      stmt_class2 VARCHAR2(1000);
      stmt_class3 VARCHAR2(1000);
      stmt_class4 VARCHAR2(1000);
      stmt_class5 VARCHAR2(1000);
      stmt_categ1 VARCHAR2(1000);
      stmt_categ2 VARCHAR2(1000);
      stmt_categ3 VARCHAR2(1000);
      stmt_categ4 VARCHAR2(1000);
      stmt_categ5 VARCHAR2(1000);

      stmt VARCHAR2(3200);


    TYPE cur_sel_opportunities_rec_type IS RECORD
    (    value number,
         currency_code varchar2(15),
         expected_approval_date date,
         probability number,
         request_id number,
         lead_id number,
         category varchar2(1000)
     );

     cur_sel_opportunities_rec cur_sel_opportunities_rec_type;

     CURSOR cur_old_project_info (p_project_id NUMBER) IS
           SELECT
               name,
               segment1,
               s.project_status_name,
               m.probability_percentage,
               m.probability_list_id,
               p.probability_member_id,
               a.opportunity_value,
               a.opp_value_currency_code,
               p.expected_approval_date,
               p.project_value,
               p.record_version_number,
	       p.org_id  -- Added for Bug#3798344
            FROM
               pa_projects_all p,
               pa_project_statuses s ,
               pa_probability_members m ,
               pa_project_opp_attrs a
            WHERE  p.project_status_code = s.project_status_code
              AND  p.probability_member_id = m.probability_member_id(+)
              AND  a.project_id = p.project_id
              AND  p.project_id =  p_project_id;



	      CURSOR cur_wf_ntf_info (p_project_id NUMBER) IS
           SELECT PPP.RESOURCE_SOURCE_ID,
                  PPRT.PROJECT_ROLE_TYPE
           FROM PA_PROJECT_PARTIES         PPP  ,
                PA_PROJECT_ROLE_TYPES      PPRT
           WHERE PPP.PROJECT_ID              = p_project_id
             AND PPP.PROJECT_ROLE_ID         = PPRT.PROJECT_ROLE_ID
             AND (PPRT.PROJECT_ROLE_TYPE     ='PROJECT MANAGER'
                  OR PPRT.PROJECT_ROLE_TYPE  ='STAFFING OWNER')
             AND trunc(sysdate) BETWEEN trunc(PPP.start_date_active)
                 AND NVL(trunc(PPP.end_date_active),sysdate);


    --Used when sending the notifications, each run of update projects has a unique group_id.

    CURSOR cur_wf_ntf_info2 (p_group_id NUMBER) IS
       SELECT user_name,
              object_id1 project_id,
              object_id2 lead_id
       FROM pa_wf_ntf_performers
       WHERE group_id = p_group_id
       ORDER BY user_name,
             object_id1;



   l_project_name 	               pa_projects_all.name%TYPE;
   l_project_number	               pa_projects_all.segment1%TYPE;
   l_project_status_name           pa_project_statuses.project_status_name%TYPE;

   -- Old pipeline project info.
   l_project_value                 pa_projects_all.project_value%TYPE;
   l_probability		               pa_probability_members.probability_percentage%TYPE;
   l_probability_list_id           pa_probability_members.probability_list_id%TYPE;
   l_probability_member_id         pa_probability_members.probability_member_id%TYPE;
   l_opportunity_value             pa_project_opp_attrs.opportunity_value%TYPE;
   l_opp_value_currency_code       pa_project_opp_attrs.opp_value_currency_code%TYPE;
   l_expected_approval_date        pa_projects_all.expected_approval_date%TYPE;

   -- New pipeline project info.
   l_new_probability		           pa_probability_members.probability_percentage%TYPE;
   l_new_probability_member_id     pa_probability_members.probability_member_id%TYPE;
   l_new_opportunity_value         pa_project_opp_attrs.opportunity_value%TYPE;
   l_new_opp_value_currency_code   pa_project_opp_attrs.opp_value_currency_code%TYPE;
   l_new_expected_approval_date    pa_projects_all.expected_approval_date%TYPE;

   l_recipient_tab                 pa_plsql_datatypes.Char240TabTyp;
   l_project_id_tab                PA_PLSQL_DATATYPES.IdTabTyp;
   l_lead_id_tab                   PA_PLSQL_DATATYPES.IdTabTyp;
   l_project_count_tab             PA_PLSQL_DATATYPES.IdTabTyp;

   l_record_version_number   NUMBER;
   l_dest_value_pk2          NUMBER;
   l_dest_value_pk3          NUMBER;
   l_dest_value_pk4          NUMBER;
   l_dest_value_pk5          NUMBER;
   l_msg_data                VARCHAR2(2000);
   l_msg_count               NUMBER;
   l_project_id              NUMBER;
   l_group_id                NUMBER;
   TEXT_DUMMY                CONSTANT VARCHAR2(10) := '~~!@#$*&^';
   l_last_recipient          VARCHAR2(100);
   l_end_recipient           VARCHAR2(100);
   l_recipient_user_name     VARCHAR2(320); /* Modified length from 30 to 320 for bug 2933743 */
   l_recipient_display_name  VARCHAR2(360); /* Modified length from 240 to 360 for bug 2933743 */
   l_view_upd_proj_url       VARCHAR2(600);
   l_item_type               pa_wf_processes.item_type%TYPE;
   l_item_key                pa_wf_processes.item_key%TYPE;
   l_err_code                NUMBER := 0;
   l_err_stage               VARCHAR2(2000);
   l_err_stack               VARCHAR2(2000);
   l_warning                 VARCHAR2(2000);  -- added for bug3632727 - bug 4015199
   v_count                   BINARY_INTEGER := 0;
   l_probability_update        VARCHAR2(1);
   l_opportunity_value_update  VARCHAR2(1);
   l_approval_date_update      VARCHAR2(1);
   l_previous_request_id       NUMBER;

      -- 2384213: p_classification is a concatinated string like
   -- 'interest_type_id/primary_interest_code_id/secondary_interest_id'. This string
   -- needs to be broken down into the following three local variables.

   l_interest_type_id as_interests_all.interest_type_id%TYPE;
   l_primary_interest_code_id as_interests_all.primary_interest_code_id%TYPE;
   l_secondary_interest_code_id as_interests_all.secondary_interest_code_id%TYPE;
   l_position_1              NUMBER;
   l_position_2              NUMBER;

   --  Added by Sachin for P1 bug 3765557
   l_guest_user   pa_wf_ntf_performers.user_name%type;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   Debug('In procedure update_projects for classification ['||p_classification||']');

stmt_class1 := 'SELECT l.total_amount value, '
       ||  'l.currency_code currency_code,'
       ||  'l.decision_date expected_approval_date,'
       ||  'l.win_probability probability, '
       ||  'r.request_id request_id,'
       ||  'l.lead_id lead_id,'
       ||  'null as category ' ;

stmt_class2 := ' FROM as_leads  l, as_interests i, pa_project_requests r, pa_object_relationships o,pa_project_statuses s '
       ||  ' WHERE  '
       ||  ' (l.win_probability >= nvl(:1, 0) OR'
       ||  ' (l.win_probability IS NULL AND :1 IS NULL)'
       ||' ) '
       ||' AND ( l.win_probability <= nvl(:2, 100) OR'
       ||' (l.win_probability IS NULL AND :2 IS NULL )'
       ||'  )  '
       ||' AND   l.status = nvl(:3,l.status) '
       ||' AND   (l.decision_date >= sysdate - nvl(:4, 365000 ) OR'
       ||'          l.decision_date IS NULL )';

stmt_class3 := ' AND ('
       ||'         l.sales_stage_id  = nvl(:5,l.sales_stage_id) OR'
       ||'        (l.sales_stage_id IS NULL AND :5 IS NULL)'
       ||'       )'
       ||'AND ( l.total_amount >= nvl(:6, l.total_amount ) OR'
       ||'    (l.total_amount IS NULL AND :6 IS NULL)'
       ||'       ) '
       ||'AND ( l.total_amount  <=nvl(:7,l.total_amount ) OR '
       ||'        (l.total_amount IS NULL AND :7 IS NULL)'
       ||'       )  '
       ||'AND ( l.currency_code =nvl(:8, l.currency_code) OR'
       ||'        (l.currency_code IS NULL AND :8 IS NULL)'
       ||'       )';

stmt_class4 :=' AND ( '
       ||'     i.interest_type_id = nvl(:9,i.interest_type_id) OR'
       ||'         (i.interest_type_id IS NULL AND :9 IS NULL)'
       ||'       )'
       ||'AND (  '
       ||'         i.primary_interest_code_id = nvl(:10, i.primary_interest_code_id) OR'
       ||'        (i.primary_interest_code_id IS NULL AND :10 IS NULL)'
       ||  '       )'
       ||'AND (  '
       ||'         i.secondary_interest_code_id = nvl(:11, i.secondary_interest_code_id) OR'
       ||'    (i.secondary_interest_code_id IS NULL AND :11 IS NULL)'
       ||'   )'
       ||'AND   l.lead_id = o.object_id_from1';

stmt_class5 :=' AND   o.object_id_to1 = r.request_id'
       ||' AND   l.lead_id = i.lead_id (+)'
       ||' AND   r.status_code =s.project_status_code'
       ||' AND   s.project_system_status_code =''PROJ_REQ_CLOSED'' '
       ||' AND   r.request_type =:12'
       ||' AND   o.relationship_type=''A'' '
       ||' AND   o.relationship_subtype =''PROJECT_REQUEST'' '
       ||' AND   o.object_type_from = ''AS_LEADS'' '
       ||' AND   o.object_type_to = ''PA_PROJECT_REQUESTS'' ';

stmt_categ1 := 'SELECT l.total_amount value, '
       ||  'l.currency_code currency_code,'
       ||  'l.decision_date expected_approval_date,'
       ||  'l.win_probability probability,'
       ||  ' r.request_id request_id,'
       ||  'l.lead_id lead_id,'
       ||  'h.category category ' ;

stmt_categ2 := ' FROM as_leads  l,as_lead_lines ll,pa_lead_categories_v h,pa_project_requests r, pa_object_relationships o,pa_project_statuses s '
       ||  ' WHERE  '
       ||  'll.product_category_id = h.category_id '
       ||  ' AND l.lead_id = ll.lead_id '
       ||  ' AND ('
       ||  ' l.win_probability >= nvl(:1, 0) OR'
       ||  ' (l.win_probability IS NULL AND :1 IS NULL)'
       ||' ) '
       ||' AND ( l.win_probability <= nvl(:2, 100) OR'
       ||' (l.win_probability IS NULL AND :2 IS NULL )'
       ||'  )  '
       ||' AND   l.status = nvl(:3,l.status) '
       ||' AND   (l.decision_date >= sysdate - nvl(:4, 365000 ) OR'
       ||' l.decision_date IS NULL )';

stmt_categ3 := ' AND ('
       ||'         l.sales_stage_id  = nvl(:5,l.sales_stage_id) OR'
       ||'        (l.sales_stage_id IS NULL AND :5 IS NULL)'
       ||'       )'
       ||'AND ( l.total_amount >= nvl(:6, l.total_amount ) OR'
       ||'    (l.total_amount IS NULL AND :6 IS NULL)'
       ||'       ) '
       ||'AND ( l.total_amount  <=nvl(:7,l.total_amount ) OR '
       ||'        (l.total_amount IS NULL AND :7 IS NULL)'
       ||'       )  '
       ||'AND ( l.currency_code =nvl(:8, l.currency_code) OR'
       ||'        (l.currency_code IS NULL AND :8 IS NULL)'
       ||'       )';

stmt_categ4 :='  AND ( '
       ||'          h.category = nvl(:9, h.category) OR '
       ||'        ( h.category like :9||''/%'') '
       ||'           )  '
       ||' AND   l.lead_id = o.object_id_from1'
       ||' AND   o.object_id_to1 = r.request_id'
       ||' AND   r.status_code =s.project_status_code'
       ||' AND   s.project_system_status_code =''PROJ_REQ_CLOSED'' '
       ||' AND   r.request_type =:10'
       ||' AND   o.relationship_type=''A'' '
       ||' AND   o.relationship_subtype =''PROJECT_REQUEST'' '
       ||' AND   o.object_type_from = ''AS_LEADS'' '
       ||' AND   o.object_type_to = ''PA_PROJECT_REQUESTS'' ';


   --Generate group_id for each run of update projects.
   --Used by workflow notification.
   SELECT pa_wf_ntf_performers_s.nextval
   INTO l_group_id
   FROM dual;

   -- Added by Sachin for P1 bug 3765557
   --changed for P1 Bug6727240
   l_guest_user := null;
   SELECT SUBSTRB(FND_WEB_SEC.GET_GUEST_USERNAME_PWD,1,INSTRB(FND_WEB_SEC.GET_GUEST_USERNAME_PWD, '/' )-1)
   into l_guest_user
   from dual;
   --changed for P1 Bug6727240
   -- End bug 3765557

   IF (p_is_profile_defined = 'N') THEN
   -- Process p_classification.
      l_position_1 := INSTR(p_classification, '/');
      l_position_2 := INSTR(p_classification, '/', 1, 2);

      IF l_position_1 = 0 THEN
        l_interest_type_id := TO_NUMBER(p_classification);
        l_primary_interest_code_id := NULL;
        l_secondary_interest_code_id := NULL;
      ELSIF l_position_2 = 0 THEN
        l_interest_type_id := TO_NUMBER(SUBSTR(p_classification, 1, l_position_1-1));
        l_primary_interest_code_id := TO_NUMBER(SUBSTR(p_classification, l_position_1+1));
        l_secondary_interest_code_id := NULL;
      ELSE
        l_interest_type_id := TO_NUMBER(SUBSTR(p_classification, 1, l_position_1-1));
        l_primary_interest_code_id := TO_NUMBER(SUBSTR(p_classification, l_position_1+1, l_position_2-l_position_1-1));
        l_secondary_interest_code_id := TO_NUMBER(SUBSTR(p_classification, l_position_2+1));
      END IF;

      debug('l_interest_type_id = '|| l_interest_type_id);
      debug('l_primary_interest_code_id = '|| l_primary_interest_code_id);
      debug('l_secondary_interest_code_id = '|| l_secondary_interest_code_id);
   END IF;

   -- Loop through the project requests cursor and update projects.
   l_previous_request_id := NULL;

 IF (p_is_profile_defined = 'N') THEN
       Debug(substr(stmt_class1,1,250));
       Debug(substr(stmt_class1,251,500));
       Debug(substr(stmt_class1,501,750));
       Debug(substr(stmt_class1,751,1000));
       Debug(substr(stmt_class1,1001,1250));
       Debug(substr(stmt_class1,1251,1500));
       Debug(substr(stmt_class1,1501,1750));
       Debug(substr(stmt_class1,1751,2000));
       Debug(substr(stmt_class2,1,250));
       Debug(substr(stmt_class2,251,500));
       Debug(substr(stmt_class2,501,750));
       Debug(substr(stmt_class2,751,1000));
       Debug(substr(stmt_class2,1001,1250));
       Debug(substr(stmt_class2,1251,1500));
       Debug(substr(stmt_class2,1501,1750));
       Debug(substr(stmt_class2,1751,2000));
       Debug(substr(stmt_class3,1,250));
       Debug(substr(stmt_class3,251,500));
       Debug(substr(stmt_class3,501,750));
       Debug(substr(stmt_class3,751,1000));
       Debug(substr(stmt_class3,1001,1250));
       Debug(substr(stmt_class3,1251,1500));
       Debug(substr(stmt_class3,1501,1750));
       Debug(substr(stmt_class3,1751,2000));
       Debug(substr(stmt_class4,1,250));
       Debug(substr(stmt_class4,251,500));
       Debug(substr(stmt_class4,501,750));
       Debug(substr(stmt_class4,751,1000));
       Debug(substr(stmt_class4,1001,1250));
       Debug(substr(stmt_class4,1251,1500));
       Debug(substr(stmt_class4,1501,1750));
       Debug(substr(stmt_class4,1751,2000));
       Debug(substr(stmt_class5,1,250));
       Debug(substr(stmt_class5,251,500));
       Debug(substr(stmt_class5,501,750));
       Debug(substr(stmt_class5,751,1000));
       Debug(substr(stmt_class5,1001,1250));
       Debug(substr(stmt_class5,1251,1500));
       Debug(substr(stmt_class5,1501,1750));
       Debug(substr(stmt_class5,1751,2000));


       stmt := stmt_class1 || stmt_class2||stmt_class3|| stmt_class4|| stmt_class5;
       Debug(':12['||p_request_type||']:1 ['||p_probability_from||']:2 ['||p_probability_to||']:3 ['||p_status||']');
       Debug(':4 ['||p_closed_date_within_days||']:5 ['||p_sales_stage_id||']:6 ['||p_value_from||']:7 ['||p_value_to||']');
       Debug(':8 ['||p_currency_code||']:9 ['||l_interest_type_id||']:10 ['||l_primary_interest_code_id||']:11 ['||l_secondary_interest_code_id||']');

       OPEN cur_sel_opportunities FOR stmt
                  USING p_probability_from,p_probability_from, --:1
                        p_probability_to,p_probability_to,     --:2
                        p_status,                              --:3
                        p_closed_date_within_days,             --:4
                        p_sales_stage_id,p_sales_stage_id,     --:5
                        p_value_from,p_value_from,             --:6
                        p_value_to,p_value_to,                 --:7
                        p_currency_code,p_currency_code,       --:8
                        l_interest_type_id,l_interest_type_id, --:9
                        l_primary_interest_code_id,l_primary_interest_code_id,       --:10
                        l_secondary_interest_code_id,l_secondary_interest_code_id,   --:11
                        p_request_type ;                       --:12
  ELSE
       stmt := stmt_categ1 ||stmt_categ2||stmt_categ3||stmt_categ4;
       Debug(substr(stmt_categ1,1,250));
       Debug(substr(stmt_categ1,251,500));
       Debug(substr(stmt_categ1,501,750));
       Debug(substr(stmt_categ1,751,1000));
       Debug(substr(stmt_categ1,1001,1250));
       Debug(substr(stmt_categ1,1251,1500));
       Debug(substr(stmt_categ1,1501,1750));
       Debug(substr(stmt_categ1,1751,2000));
       Debug(substr(stmt_categ2,1,250));
       Debug(substr(stmt_categ2,251,500));
       Debug(substr(stmt_categ2,501,750));
       Debug(substr(stmt_categ2,751,1000));
       Debug(substr(stmt_categ2,1001,1250));
       Debug(substr(stmt_categ2,1251,1500));
       Debug(substr(stmt_categ2,1501,1750));
       Debug(substr(stmt_categ2,1751,2000));
       Debug(substr(stmt_categ3,1,250));
       Debug(substr(stmt_categ3,251,500));
       Debug(substr(stmt_categ3,501,750));
       Debug(substr(stmt_categ3,751,1000));
       Debug(substr(stmt_categ3,1001,1250));
       Debug(substr(stmt_categ3,1251,1500));
       Debug(substr(stmt_categ3,1501,1750));
       Debug(substr(stmt_categ3,1751,2000));
       Debug(substr(stmt_categ4,1,250));
       Debug(substr(stmt_categ4,251,500));
       Debug(substr(stmt_categ4,501,750));
       Debug(substr(stmt_categ4,751,1000));
       Debug(substr(stmt_categ4,1001,1250));
       Debug(substr(stmt_categ4,1251,1500));
       Debug(substr(stmt_categ4,1501,1750));
       Debug(substr(stmt_categ4,1751,2000));

       Debug(':10['||p_request_type||']:1 ['||p_probability_from||']:2 ['||p_probability_to||']:3 ['||p_status||']');
       Debug(':4 ['||p_closed_date_within_days||']:5 ['||p_sales_stage_id||']:6 ['||p_value_from||']:7 ['||p_value_to||']');
       Debug(':8 ['||p_currency_code||']:9 ['||p_classification||']');

       OPEN cur_sel_opportunities FOR stmt
                  USING p_probability_from,p_probability_from, --:1
                        p_probability_to,p_probability_to,     --:2
                        p_status,                              --:3
                        p_closed_date_within_days,             --:4
                        p_sales_stage_id,p_sales_stage_id,     --:5
                        p_value_from,p_value_from,             --:6
                        p_value_to,p_value_to,                 --:7
                        p_currency_code,p_currency_code,       --:8
                        p_classification,p_classification,     --:9
                        p_request_type ;                       --:10

  END IF;

Debug('Cursor has been successfully opened');
Debug('Going into the loop');

LOOP
FETCH cur_sel_opportunities INTO cur_sel_opportunities_rec;
      EXIT WHEN cur_sel_opportunities%NOTFOUND;
    --  debug('l_previous_request_id = '|| l_previous_request_id);
     -- debug('request_id = '||cur_sel_opportunities_rec.request_id);

  -- Can not use DISTINCT on the cursor because SELECT FOR UPDATE. Therefore, needs to
  -- check duplicate request_id rows from the cursor. Only update once for a request_id.

  IF ((l_previous_request_id IS NULL) OR (l_previous_request_id <> cur_sel_opportunities_rec.request_id)) THEN
      v_count := v_count +1;
      --debug('PA_PROJECT_REQUEST_PVT.UPDATE_PROJECTS: v_count = '|| v_count);
      --debug('Category ['||cur_sel_opportunities_rec.category||']' );
      l_previous_request_id := cur_sel_opportunities_rec.request_id;

   --get the project ID for a passed in request ID, relationship direction: Request -> Project

   SELECT object_id_to1
   INTO l_project_id
   FROM  pa_object_relationships
   WHERE relationship_type='A'
     AND relationship_subtype ='PROJECT_REQUEST'
     AND object_type_from ='PA_PROJECT_REQUESTS'
     AND object_type_to = 'PA_PROJECTS'
     AND object_id_from1 = cur_sel_opportunities_rec.request_id;

   debug('Updating this project, project_id  = ' ||  l_project_id );
   debug('Old project info ********************');
      -- get old project info for the report purpose
      OPEN cur_old_project_info (l_project_id);
      FETCH cur_old_project_info
      INTO 	l_project_name,
   		      l_project_number,
   		      l_project_status_name,
            l_probability,
            l_probability_list_id,
            l_probability_member_id,
            l_opportunity_value,
            l_opp_value_currency_code,
            l_expected_approval_date,
            l_project_value,
            l_record_version_number,
	    PA_PROJECT_REQUEST_PVT.G_ORG_ID;  -- Added for Bug#3798344
      CLOSE cur_old_project_info;

      debug('l_project_name = ' ||   l_project_name);
      debug('l_project_number = ' ||  l_project_number);
      debug('l_project_status_name =' ||  l_project_status_name);
      debug('l_probability = '|| l_probability);
      debug('l_probability_member_id = '|| l_probability_member_id);
      debug('l_opportunity_value = ' || l_opportunity_value);
      debug('l_opp_value_currency_code = ' || l_opp_value_currency_code);
      debug('l_expected_approval_date = ' || l_expected_approval_date);
      debug('l_record_version_number= ' ||  l_record_version_number);

      -- Check whether probability is to be updated.
      IF p_update_probability = 'Y' THEN
         -- Get the new project probability value
         PA_MAPPING_PVT.get_dest_values(
        	p_value_map_def_type  	=> 'PROBABILITY_OPP_PROJ',
        	p_def_subtype  		 	    => p_request_type,
					p_source_value          => cur_sel_opportunities_rec.probability,
	  	    p_source_value_pk1 	 	  => NULL,
	  	    p_source_value_pk2 	    => NULL,
	  	    p_source_value_pk3 	    => NULL,
	  	    p_source_value_pk4  	  => NULL,
	  	    p_source_value_pk5      => NULL,
          p_probability_list_id   => l_probability_list_id,
	  	    x_dest_value   		      => l_new_probability,
          x_dest_value_pk1  	    => l_new_probability_member_id,
	  	    x_dest_value_pk2  	 	  => l_dest_value_pk2 ,
	 	      x_dest_value_pk3   	    => l_dest_value_pk3,
	        x_dest_value_pk4   	    => l_dest_value_pk4,
	        x_dest_value_pk5   	    => l_dest_value_pk5,
          x_return_status    	    => x_return_status ,
          x_msg_count   		      => x_msg_count ,
          x_msg_data     		      => x_msg_data );

         debug('Call get_dest_values for probabilty: ' || l_new_probability);

         IF l_probability <> l_new_probability OR
            (l_new_probability IS NULL AND l_probability IS NOT NULL) OR
            (l_new_probability IS NOT NULL AND l_probability IS NULL)  THEN
            l_probability_update := 'Y';
            debug('Probability is to be updated: l_new_probability_member_id = '|| l_new_probability_member_id);
         ELSE
            l_probability_update := 'N';
            l_new_probability := l_probability;
            l_new_probability_member_id := l_probability_member_id;
         END IF;

      ELSE
         l_probability_update := 'N';
         l_new_probability := l_probability;
         l_new_probability_member_id := l_probability_member_id;
      END IF;

      -- Check whether opportunity is to be updated.
      IF p_update_value ='Y' AND l_opportunity_value <> cur_sel_opportunities_rec.value   THEN
         l_opportunity_value_update := 'Y';
         l_new_opportunity_value := cur_sel_opportunities_rec.value ;
         l_new_opp_value_currency_code := cur_sel_opportunities_rec.currency_code;
         -- need to pass the expected_approval_date for rate conversion.
         l_new_expected_approval_date  := cur_sel_opportunities_rec.expected_approval_date;

         debug('Value and Currency will be upated, new value = ' || l_new_opportunity_value || l_new_opp_value_currency_code  );

      ELSE
         l_opportunity_value_update := 'N';
         l_new_opportunity_value := l_opportunity_value;
         l_new_opp_value_currency_code := l_opp_value_currency_code;
      END IF;

      -- Check whether expected approval date is to be updated.
      IF p_update_exp_appr_date ='Y' AND l_expected_approval_date <> cur_sel_opportunities_rec.expected_approval_date  THEN
         l_approval_date_update :='Y';
         l_new_expected_approval_date  := cur_sel_opportunities_rec.expected_approval_date;
         debug('Expected Approval Date will be updated, new date = ' ||  l_new_expected_approval_date);

      ELSE
         l_approval_date_update :='N';
         l_new_expected_approval_date := l_expected_approval_date;
      END IF;

   debug ('x_msg_count =' || x_msg_count);
   debug ('x_msg_data=' ||  x_msg_data);
   debug ('x_return_status = ' ||  x_return_status);

   -- Update pipeline project info.
   IF l_probability_update = 'Y' OR l_opportunity_value_update = 'Y' OR l_approval_date_update = 'Y' THEN

      -- Call project API to update project
      Debug('Begin calling update project API');
      Debug('l_new_probability_member_id= '   || l_new_probability_member_id);
      Debug('l_new_probability = '            || l_new_probability);
      Debug('l_new_opportunity_value = '      || l_new_opportunity_value);
      Debug('l_new_opp_value_currency_code = '|| l_new_opp_value_currency_code);
      Debug('l_new_expected_approval_date = ' || l_new_expected_approval_date);
      Debug('l_project_value = '|| l_project_value);

      PA_PROJECTS_MAINT_PUB.UPDATE_PROJECT_PIPELINE_INFO(
      p_init_msg_list          => FND_API.G_TRUE, -- Changed from G_FALSE for bug 3635099. -- Bug 4015199.
      p_commit                 => FND_API.G_FALSE,
      p_validate_only          => FND_API.G_FALSE,
      p_project_id             => l_project_id,
      p_probability_member_id  => l_new_probability_member_id,
      p_probability_percentage => l_new_probability,
      p_project_value          => l_project_value,
      p_opportunity_value      => l_new_opportunity_value,
      p_opp_value_currency_code=> l_new_opp_value_currency_code,
      p_expected_approval_date => l_new_expected_approval_date,
      p_record_version_number  => l_record_version_number,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data);

      Debug('After calling update project API');
      Debug('***** x_return_status = ' ||  x_return_status );

      IF x_return_status = 'S' THEN

        -- Insert notification related info into pa_wf_ntf_performers
        FOR cur_wf_ntf_info_rec in cur_wf_ntf_info(l_project_id) LOOP

           --get user id for the project manager and staffing owners of this project

           WF_DIRECTORY.getusername
   	           (p_orig_system    => 'PER',
                p_orig_system_id => cur_wf_ntf_info_rec.resource_source_id,
     	          p_name           => l_recipient_user_name,
                p_display_name   => l_recipient_display_name);

	    /* start of bug 3632727 */ -- Bug 4015199
	    if l_recipient_user_name IS NOT NULL then
	    /* end of bug 3632727*/

           INSERT INTO pa_wf_ntf_performers
              (wf_type_code,
               item_type,
               item_key,
               object_id1,
               object_id2,
               user_name,
               user_type,
               group_id)
           VALUES
              ('OM_UPDATE_PROJECTS',
               'PAYPRJNT',
               '-1',
               l_project_id,
               cur_sel_opportunities_rec.lead_id,
               l_recipient_user_name,
               cur_wf_ntf_info_rec.project_role_type,
               l_group_id) ;
		/* start of bug 3632727 */
		else   --Bug 4015199
			 -- populate into temp table
			 l_warning := fnd_message.get_string('PA','PA_UNAME_NOT_ASSIGNED');

			  PA_PROJECTS_UPDATE_WARN_PKG.insert_row
			  ( p_project_name            =>l_project_name,
			    p_warning		      => l_warning,
			    x_return_status                   => x_return_status,
			    x_msg_count                       => x_msg_count,
			    x_msg_data                        => x_msg_data);
		end if; -- l_recipient_user_name IS NOT NULL
	    /* end of bug 3632727 */

         END LOOP;

-- Added by Sachin for P1 bug 3765557
       if l_guest_user is not null then
           INSERT INTO pa_wf_ntf_performers
              (wf_type_code,
               item_type,
               item_key,
               object_id1,
               object_id2,
               user_name,
               user_type,
               group_id)
           VALUES
              ('OM_UPDATE_PROJECTS',
               'PAYPRJNT',
               '-1',
               l_project_id,
               cur_sel_opportunities_rec.lead_id,
               l_guest_user,
               'GUEST',
               l_group_id) ;
        end if;
-- End bug 3765557


         -- Insert into the temp table for report purpose

          PA_PROJECTS_UPDATE_PKG.insert_row
       (p_project_name                    =>l_project_name,
	      p_project_number			            =>l_project_number,
        p_project_status_name             =>l_project_status_name,
        p_old_probability                 =>l_probability,
        p_new_probability		              =>l_new_probability,
        p_old_value                       =>l_opportunity_value,
        p_new_value			                  =>l_new_opportunity_value,
        p_old_value_currency              =>l_opp_value_currency_code,
        p_new_value_currency              =>l_new_opp_value_currency_code,
        p_old_exp_proj_apprvl_date        =>l_expected_approval_date,
				p_new_exp_proj_apprvl_date        =>l_new_expected_approval_date,
        x_return_status                   =>x_return_status,
        x_msg_count                       =>x_msg_count,
        x_msg_data                        =>x_msg_data);


      ELSE -- Not Succeed

         -- GET ERROR FROM ERROR STACK
         FOR i IN 1..FND_MSG_PUB.Count_Msg LOOP

            FND_MSG_PUB.get (
            p_encoded        => FND_API.G_FALSE,
            p_msg_index      => i,
            p_data           => l_msg_data,
            p_msg_index_out  => l_msg_count );

            IF l_msg_data IS NOT NULL THEN
            --Insert the error into the temp table for the report display purpose.
               -- Insert error message to temp table
               PA_PROJECTS_UPDATE_WARN_PKG.insert_row
                  ( p_project_name                    =>l_project_name,
	                  p_warning				                  => l_msg_data,
                    x_return_status                   => x_return_status,
                    x_msg_count                       => x_msg_count,
                    x_msg_data                        => x_msg_data);
            END IF;
         END LOOP;
	 FND_MSG_PUB.Delete_Msg(); --Added for bug 4094370
      END IF;
   END IF; -- calling pipeline project updates

/* commented for bug              2968585
   IF v_count >=100 THEN
      COMMIT;
      v_count := 0;
   END IF;
*/
   END IF; -- end of checking whether the request_id is a duplicate.

   END LOOP;
   CLOSE cur_sel_opportunities;

Commit;    --added for bug 2968585


   --Send notifications to the project managers and staffing owners of the updated projects.
    l_recipient_tab.DELETE;
    l_project_id_tab.DELETE;
    l_lead_id_tab.DELETE;
    l_project_count_tab.DELETE;


   OPEN  cur_wf_ntf_info2 (l_group_id);
   FETCH cur_wf_ntf_info2 BULK COLLECT INTO
         l_recipient_tab,
         l_project_id_tab,
         l_lead_id_tab ;
   CLOSE  cur_wf_ntf_info2;

   l_last_recipient :=  TEXT_DUMMY;
   l_item_type := 'PAYPRJNT';

   debug('l_group_id = '  || l_group_id);
   debug('l_recipient_tab.FIRST = ' || l_recipient_tab.FIRST);
   debug('l_recipient_tab.LAST = ' || l_recipient_tab.LAST);

    IF l_recipient_tab.count <> 0 THEN

       FOR i IN l_recipient_tab.FIRST .. l_recipient_tab.LAST  LOOP

        --  debug('In Notification Loop');
          --debug('In LOOP, i =' || i);

          IF (l_recipient_tab(i) <> l_last_recipient AND l_last_recipient <> TEXT_DUMMY)  THEN

             SELECT PA_PRM_WF_ITEM_KEY_S.nextval
             INTO l_item_key
             FROM DUAL;

             debug('l_item_key(inside loop) = ' || l_item_key);


             -- Create the WF process
             WF_ENGINE.CreateProcess ( ItemType => l_item_type,
                                  ItemKey  => l_item_key,
                                  process  => 'PRC_PA_OM_UPDATE_PROJECTS');


             -- Setting the attribute value for recipient
             WF_ENGINE.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_NTF_RECIPIENT',
                avalue   => l_recipient_tab(i-1)
              );

             debug('Inside Loop, recipient = '||  l_recipient_tab(i-1));
             --Get the number of projects updated for this recipient

             SELECT distinct object_id1
                BULK COLLECT INTO l_project_count_tab
             FROM pa_wf_ntf_performers
             WHERE group_id = l_group_id
             AND user_name = l_recipient_tab(i-1);

             -- Setting the attribute value for recipient count
             WF_ENGINE.SetItemAttrNumber
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_UPD_PROJ_COUNT',
                avalue   => l_project_count_tab.count
              );

             debug('Inside Loop, count of updated projects  = ' || l_project_count_tab.count);
             l_view_upd_proj_url :=
           'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_UPDATED_PIPE_PROJ_LAYOUT&addBreadCrumb=RP'
              || '&paGroupId=' || l_group_id
              || '&paItemType=PAYPRJNT';

             -- Setting the attribute value for updated projects URL
             WF_ENGINE.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_UPD_PROJ_URL_INFO',
                avalue   => l_view_upd_proj_url
              );

             -- Now start the WF process
             WF_ENGINE.StartProcess
             ( itemtype => l_item_type,
               itemkey  => l_item_key );

             -- Insert to PA tables wf process information.

             PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => 'OM_UPDATE_PROJECTS'
                ,p_item_type           => l_item_type
                ,p_item_key            => l_item_key
                ,p_entity_key1         => to_char(l_project_id_tab(i-1))
                ,p_entity_key2         => to_char(l_lead_id_tab(i-1))
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );

          END IF;
          --asign the current recipient to the last recipient
          l_last_recipient := l_recipient_tab(i);

       END LOOP;
   END IF;

   debug('Exit Notification Loop');

   IF l_recipient_tab.count <> 0 THEN
      -- Sent notification for the last recipient.
      SELECT PA_PRM_WF_ITEM_KEY_S.nextval
        INTO l_item_key
        FROM DUAL;
      debug('l_item_key(outside loop) = ' || l_item_key);

      -- Create the WF process
      WF_ENGINE.CreateProcess      ( ItemType => l_item_type,
                                  ItemKey  => l_item_key,
                                  process  => 'PRC_PA_OM_UPDATE_PROJECTS');


      -- Setting the attribute value for recipient

      l_end_recipient := l_recipient_tab(l_recipient_tab.LAST);

      WF_ENGINE.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_NTF_RECIPIENT',
                avalue   => l_end_recipient
              );

      debug('Outside Loop, recipient =' || l_recipient_tab(l_recipient_tab.LAST));

      --Get the number of projects updated for the last recipient

       SELECT distinct object_id1
           BULK COLLECT INTO l_project_count_tab
       FROM pa_wf_ntf_performers
       WHERE group_id = l_group_id
           AND user_name = l_end_recipient;

       -- Setting the attribute value for recipient count
      WF_ENGINE.SetItemAttrNumber
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_UPD_PROJ_COUNT',
                avalue   => l_project_count_tab.COUNT
              );

      debug('Outside Loop, count of updated projects = ' ||l_project_count_tab.COUNT);
      l_view_upd_proj_url :=
           'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_UPDATED_PIPE_PROJ_LAYOUT&addBreadCrumb=RP'
              || '&paGroupId=' || l_group_id
              || '&paItemType=PAYPRJNT';

      -- Setting the attribute value for updated projects URL
      WF_ENGINE.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_UPD_PROJ_URL_INFO',
                avalue   => l_view_upd_proj_url
              );

      -- Now start the WF process
      WF_ENGINE.StartProcess
             ( itemtype => l_item_type,
               itemkey  => l_item_key );

      -- Insert to PA tables wf process information.

      PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => 'OM_UPDATE_PROJECTS'
                ,p_item_type           => l_item_type
                ,p_item_key            => l_item_key
                ,p_entity_key1         => to_char(l_project_id_tab.LAST)
                ,p_entity_key2         => to_char(l_lead_id_tab.LAST)
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );

    END IF;

    debug('End Procedure Update_Projects');

EXCEPTION
   WHEN OTHERS THEN
     x_msg_count     := 1;
     x_msg_data      := sqlerrm;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJECT_REQUEST_PVT',
       p_procedure_name => 'update_projects');
     RAISE;

END update_projects;


--Procedure: post_create_project
--Purpose:   This procedure is to build the two ways relationship
--           between the project request and the project created.
--           And close the project request after the project is created.


PROCEDURE post_create_project(p_request_id        	IN     	pa_project_requests.request_id%TYPE,
     p_project_id         IN      pa_projects_all.project_id%TYPE,
	   x_return_status      OUT    	NOCOPY VARCHAR2,    --File.Sql.39 bug 4440895
	   x_msg_count          OUT    	NOCOPY NUMBER,    --File.Sql.39 bug 4440895
	   x_msg_data           OUT    	NOCOPY VARCHAR2)  IS    --File.Sql.39 bug 4440895

   l_new_obj_rel_id              PA_OBJECT_RELATIONSHIPS.OBJECT_RELATIONSHIP_ID%TYPE;
   l_new_obj_rel_id2             PA_OBJECT_RELATIONSHIPS.OBJECT_RELATIONSHIP_ID%TYPE;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Form the relationship: from the project request to the created project.

      PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
         p_user_id => FND_GLOBAL.USER_ID
        ,p_object_type_from => 'PA_PROJECT_REQUESTS'
        ,p_object_id_from1 => p_request_id
        ,p_object_id_from2 => NULL
        ,p_object_id_from3 => NULL
        ,p_object_id_from4 => NULL
        ,p_object_id_from5 => NULL
        ,p_object_type_to => 'PA_PROJECTS'
        ,p_object_id_to1 =>  p_project_id
        ,p_object_id_to2 => NULL
        ,p_object_id_to3 => NULL
        ,p_object_id_to4 => NULL
        ,p_object_id_to5 => NULL
        ,p_relationship_type => 'A'
        ,p_relationship_subtype => 'PROJECT_REQUEST'
        ,p_lag_day => NULL
        ,p_imported_lag => NULL
        ,p_priority => NULL
        ,p_pm_product_code => NULL
        ,x_object_relationship_id => l_new_obj_rel_id
        ,x_return_status => x_return_status
        );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         -- Form the relationship: from the created project to the source request.

         PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
         p_user_id => FND_GLOBAL.USER_ID
        ,p_object_type_from => 'PA_PROJECTS'
        ,p_object_id_from1 => p_project_id
        ,p_object_id_from2 => NULL
        ,p_object_id_from3 => NULL
        ,p_object_id_from4 => NULL
        ,p_object_id_from5 => NULL
        ,p_object_type_to => 'PA_PROJECT_REQUESTS'
        ,p_object_id_to1 =>  p_request_id
        ,p_object_id_to2 => NULL
        ,p_object_id_to3 => NULL
        ,p_object_id_to4 => NULL
        ,p_object_id_to5 => NULL
        ,p_relationship_type => 'A'
        ,p_relationship_subtype => 'PROJECT_REQUEST'
        ,p_lag_day => NULL
        ,p_imported_lag => NULL
        ,p_priority => NULL
        ,p_pm_product_code => NULL
        ,x_object_relationship_id => l_new_obj_rel_id2
        ,x_return_status => x_return_status
        );
       END IF;

       IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

          -- Close the project request.
          close_project_request
	          (p_request_id       	,
		         x_return_status      ,
		         x_msg_count          ,
		         x_msg_data           );
       END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_msg_count     := 1;
     x_msg_data      := sqlerrm;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJECT_REQUEST_PVT',
       p_procedure_name => 'post_create_project');
     RAISE;
END post_create_project;


PROCEDURE Req_Name_Duplicate(p_request_name       IN      VARCHAR2,
     x_return_status      OUT    	NOCOPY VARCHAR2,    --File.Sql.39 bug 4440895
	   x_msg_count          OUT    	NOCOPY NUMBER,    --File.Sql.39 bug 4440895
	   x_msg_data           OUT    	NOCOPY VARCHAR2) IS    --File.Sql.39 bug 4440895

   CURSOR C1 IS
       SELECT  'N'
       FROM  pa_project_requests
       WHERE UPPER(REQUEST_NAME) = UPPER(P_REQUEST_NAME);
   l_duplicate                      VARCHAR2(1);
   l_msg_index_out	     	  NUMBER;
   dup_req_name_not_allowed         EXCEPTION;
    -- added for 4537865
   l_new_msg_data		    VARCHAR2(2000);
    -- added for 4537865

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN C1;
   FETCH C1
   INTO  l_duplicate;
   IF C1%FOUND THEN
      debug('PA_PROJECT_REQUEST_PVT.req_name_duplicate: found duplicate name');
      CLOSE C1;
      RAISE  dup_req_name_not_allowed;
   END IF;
   CLOSE C1;

EXCEPTION

  WHEN dup_req_name_not_allowed OR
       DUP_VAL_ON_INDEX THEN
		 PA_UTILS.add_message(p_app_short_name    => 'PA',
			p_msg_name          => 'PA_ALL_DUPLICATE_NAME');
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_msg_count := FND_MSG_PUB.Count_Msg;
			x_msg_data := ' PA_ALL_DUPLICATE_NAME';

			IF x_msg_count = 1 THEN
				 pa_interface_utils_pub.get_messages
					 (p_encoded        => FND_API.G_TRUE,
					 p_msg_index      => 1,
					 p_msg_count      => x_msg_count,
					 p_msg_data       => x_msg_data,
				       --p_data           => x_msg_data, 	* Commented for Bug: 4537865
					 p_data		  => l_new_msg_data,	-- added for 4537865
					 p_msg_index_out  => l_msg_index_out );
			 -- added for 4537865
 			 x_msg_data := l_new_msg_data;
    			 -- added for 4537865
			END IF;
  WHEN OTHERS THEN

		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		 x_msg_count     := FND_MSG_PUB.Count_Msg;
		 x_msg_data      := substr(SQLERRM,1,240);

		 -- Set the excetption Message and the stack
		 FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_REQUEST_PVT.req_name_duplicate'
			 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
		 IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,        * Commented for Bug: 4537865
                                        p_data           => l_new_msg_data,    -- added for 4537865
					p_msg_index_out  => l_msg_index_out );
			-- added for 4537865
                         x_msg_data := l_new_msg_data;
                        -- added for 4537865
		 END IF;

		 RAISE; -- This is optional depending on the needs
END Req_Name_Duplicate;

END PA_PROJECT_REQUEST_PVT;

/
