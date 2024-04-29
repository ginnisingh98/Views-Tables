--------------------------------------------------------
--  DDL for Package Body PJI_REP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_REP_UTIL" AS
/* $Header: PJIRX07B.pls 120.42.12010000.8 2010/02/10 12:08:47 paljain ship $ */

g_project_id NUMBER:=-1;
g_pa_calendar_type VARCHAR2(1):='P';
g_global_calendar_type VARCHAR2(1):='E';
g_period_name  VARCHAR2(30);
g_report_date_julian  NUMBER;
g_actual_version_id  NUMBER :=-1;
g_cstforecast_version_id  NUMBER;
g_cstbudget_version_id  NUMBER;
g_cstbudget2_version_id  NUMBER;
g_revforecast_version_id  NUMBER;
g_revbudget_version_id  NUMBER;
g_revbudget2_version_id  NUMBER;
g_orig_cstforecast_version_id  NUMBER;
g_orig_cstbudget_version_id  NUMBER;
g_orig_cstbudget2_version_id  NUMBER;
g_orig_revforecast_version_id  NUMBER;
g_orig_revbudget_version_id  NUMBER;
g_orig_revbudget2_version_id  NUMBER;
g_cost_bgt_plan_type_id NUMBER;
g_rev_bgt_plan_type_id NUMBER;
g_cost_fcst_plan_type_id NUMBER;
g_rev_fcst_plan_type_id NUMBER;
g_prg_flag VARCHAR2(1);
g_project_org_id NUMBER;
g_proj_currency_code VARCHAR2(30);
g_projfunc_currency_code VARCHAR2(30);
g_gl_calendar_id NUMBER :=-99;
g_pa_calendar_id NUMBER :=-99;
g_global_calendar_id NUMBER :=-99;
g_input_calendar_type VARCHAR2(1) :=' ';
g_input_calendar_id NUMBER := -99;

g_debug_mode VARCHAR2(1) := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');
g_proc NUMBER :=5;

PROCEDURE Add_Message (p_app_short_name VARCHAR2
                , p_msg_name VARCHAR2
                , p_msg_type VARCHAR2
				, p_token1 VARCHAR2 DEFAULT NULL
				, p_token1_value VARCHAR2 DEFAULT NULL
				, p_token2 VARCHAR2 DEFAULT NULL
				, p_token2_value VARCHAR2 DEFAULT NULL
				, p_token3 VARCHAR2 DEFAULT NULL
				, p_token3_value VARCHAR2 DEFAULT NULL
				, p_token4 VARCHAR2 DEFAULT NULL
				, p_token4_value VARCHAR2 DEFAULT NULL
				, p_token5 VARCHAR2 DEFAULT NULL
				, p_token5_value VARCHAR2 DEFAULT NULL
				) IS
BEGIN
    Fnd_Message.set_name(p_app_short_name, p_msg_name);
--	Fnd_Msg_Pub.ADD;
	IF p_token1 IS NOT NULL THEN
	   Fnd_Message.set_token(p_token1, p_token1_value);
	END IF;

	IF p_token2 IS NOT NULL THEN
	   Fnd_Message.set_token(p_token2, p_token2_value);
	END IF;

	IF p_token3 IS NOT NULL THEN
	   Fnd_Message.set_token(p_token3, p_token3_value);
	END IF;

	IF p_token4 IS NOT NULL THEN
	   Fnd_Message.set_token(p_token4, p_token4_value);
	END IF;

	IF p_token5 IS NOT NULL THEN
	   Fnd_Message.set_token(p_token5, p_token5_value);
	END IF;
    Fnd_Msg_Pub.add_detail(p_message_type=>p_msg_type);
EXCEPTION
WHEN OTHERS THEN
	Fnd_Message.set_name('PJI','PJI_REP_GENERIC_MSG');
	Fnd_Message.set_token('PROC_NAME','Pji_Rep_Util.Add_Message');
END Add_Message;

PROCEDURE Log_Struct_Change_Event(p_wbs_version_id_tbl SYSTEM.PA_NUM_TBL_TYPE) IS
l_i NUMBER;
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'populate_wbs_hierachy_cache: beginning', TRUE , g_proc);
	END IF;
	--Bug 5929145 Log events only for projects and not templates
	-- Insert into event log for the project structure change of current project
	FORALL l_i IN p_wbs_version_id_tbl.FIRST..p_wbs_version_id_tbl.LAST
	INSERT INTO pa_pji_proj_events_log
	(event_type,event_id, event_object, operation_type, status, last_update_date
  , last_updated_by, creation_date, created_by, last_update_login, attribute1, attribute2)
	SELECT 'STRUCT_CHANGE',pa_pji_proj_events_log_s.NEXTVAL,'-99','X','X',SYSDATE,
	Fnd_Global.USER_ID,SYSDATE,Fnd_Global.USER_ID,Fnd_Global.LOGIN_ID,p_wbs_version_id_tbl(l_i),'N'
	FROM dual WHERE exists (
		SELECT ppa.project_id from PA_PROJECTS_ALL ppa, PA_PROJ_ELEM_VER_STRUCTURE ppevs WHERE
		ppa.project_id = ppevs.project_id AND
		ppevs.ELEMENT_VERSION_ID = p_wbs_version_id_tbl(l_i) AND
		ppa.template_flag <> 'Y'
	)
	and not exists                                --changes start for 8738137
	(select 'Y'
	from pa_pji_proj_events_log
	where event_type = 'STRUCT_CHANGE'
	and event_object = '-99'
	and attribute1 = p_wbs_version_id_tbl(l_i)
	and attribute2 ='N');	                      --changes end for 8738137

	-- Insert into event log for the program structure change for all parent project and current project
	FORALL l_i IN p_wbs_version_id_tbl.FIRST..p_wbs_version_id_tbl.LAST
	INSERT INTO pa_pji_proj_events_log
	(event_type,event_id, event_object, operation_type, status, last_update_date
  	, last_updated_by, creation_date, created_by, last_update_login, attribute1, attribute2)
	SELECT
	'STRUCT_CHANGE',pa_pji_proj_events_log_s.NEXTVAL,'-99','X','X',SYSDATE,
	Fnd_Global.USER_ID,SYSDATE,Fnd_Global.USER_ID,Fnd_Global.LOGIN_ID,sup_id,'Y'
	FROM
	(
	  select /*+ ordered
	             index(prg PJI_XBS_DENORM_N1) */
	    distinct(prg.SUP_ID) SUP_ID
	  from
	    PJI_XBS_DENORM prg,
	    PA_PROJECTS_ALL prj
	  where
	    prg.STRUCT_VERSION_ID is null                     and
	    prg.SUB_ID            = p_wbs_version_id_tbl(l_i) and
	    prg.SUP_PROJECT_ID    = prj.PROJECT_ID            and
	    prj.SYS_PROGRAM_FLAG  = 'Y'                       and
	    prj.template_flag <> 'Y'                          and not exists
		(select 'Y'                       --changes start for 8738137
		from pa_pji_proj_events_log
		where event_type = 'STRUCT_CHANGE'
		and event_object = '-99'
		and attribute1 = prg.sup_id
		and attribute2 = 'Y')              --changes end for 8738137
		);

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Log_Struct_Change_Event');
	RAISE;
END;


/* Need to add program logic */
 PROCEDURE Populate_WBS_Hierarchy_Cache(p_project_id NUMBER
, p_element_version_id NUMBER
, p_prg_flag VARCHAR2 DEFAULT 'N'
, p_page_type VARCHAR2 DEFAULT 'WORKPLAN'
, p_report_date_julian NUMBER DEFAULT NULL
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS
l_count NUMBER;
l_i		NUMBER;
l_j		NUMBER;
l_rollup_percent NUMBER;
l_pre_proj_element_id NUMBER := -1;
l_proj_element_id NUMBER;
l_prg_flag VARCHAR2(1);
l_project_id NUMBER;
l_relationship_type VARCHAR2(2);
l_element_version_id_str VARCHAR2(30);
l_proj_elem_ids_tbl              SYSTEM.PA_NUM_TBL_TYPE;
l_complete_percents_tbl            SYSTEM.PA_NUM_TBL_TYPE;

l_proj_elem_ids_tmp_tbl              SYSTEM.PA_NUM_TBL_TYPE;
l_complete_percents_tmp_tbl            SYSTEM.PA_NUM_TBL_TYPE;
l_rowid_tbl SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
l_update_flag BOOLEAN;


BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'populate_wbs_hierachy_cache: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;


	SELECT COUNT(*)
	INTO l_count
	FROM pji_rep_xbs_denorm
	WHERE sup_project_id = p_project_id
	AND prg_flag = p_prg_flag
	AND wbs_version_id = p_element_version_id
	AND ROWNUM=1;

	l_element_version_id_str := TO_CHAR(p_element_version_id);

	DELETE FROM pa_pji_proj_events_log
		WHERE attribute1 = l_element_version_id_str
		AND event_object = '-99'
		AND attribute2 = p_prg_flag
		AND event_type = 'STRUCT_CHANGE';
	IF SQL%ROWCOUNT > 0 THEN
		l_update_flag := TRUE;
	ELSE
		l_update_flag := FALSE;
	END IF;

	IF p_page_type = 'WORKPLAN' THEN
	   l_relationship_type := 'LW';
	ELSE
	   l_relationship_type := 'LF';
	END IF;

	IF (l_count=0) OR l_update_flag THEN

	   IF (l_update_flag) THEN

		   DELETE FROM pji_rep_xbs_denorm
		   WHERE wbs_version_id = p_element_version_id
		   AND prg_flag = p_prg_flag;

	   END IF;

		IF p_prg_flag = 'N' THEN


			/*
			** for initial structure information, get the structure record and change its
			** parent to -1, so that -1 is a unique parent which has only one child
			*/
			INSERT INTO pji_rep_xbs_denorm
			(SUP_PROJECT_ID, PRG_ROLLUP_FLAG, PROJECT_ID, PARENT_ELEMENT_ID,
			CHILD_ELEMENT_ID, PRG_FLAG, NAME, ROLLUP_FLAG, DISPLAY_CHILD_FLAG,
			CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY,
			LAST_UPDATE_LOGIN, WBS_VERSION_ID,DISPLAY_SEQUENCE,OWNER_WBS_VERSION_ID,RELATIONSHIP_TYPE)
			SELECT p_project_id,'N',p_project_id,-1,struct_ver.proj_element_id,
			'N',struct_ver.NAME,'Y','Y'	,
			SYSDATE, SYSDATE, 1, 1,
			0 ,p_element_version_id, -1, p_element_version_id, 'WF'
			FROM pa_proj_elem_ver_structure	struct_ver
			WHERE 1=1
			AND struct_ver.project_id = p_project_id
			AND struct_ver.element_version_id = p_element_version_id;

			/*
			** Insert the self node for this project
			*/
			INSERT INTO pji_rep_xbs_denorm
			(SUP_PROJECT_ID, PRG_ROLLUP_FLAG, PROJECT_ID, PARENT_ELEMENT_ID,
			CHILD_ELEMENT_ID, PRG_FLAG, NAME, ROLLUP_FLAG, DISPLAY_CHILD_FLAG,
			CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY,
			LAST_UPDATE_LOGIN, WBS_VERSION_ID,DISPLAY_SEQUENCE,OWNER_WBS_VERSION_ID,RELATIONSHIP_TYPE)
			SELECT p_project_id,'N',p_project_id,struct_ver.proj_element_id,
			struct_ver.proj_element_id,'N',struct_ver.NAME,'N','N'        ,
			SYSDATE, SYSDATE, 1, 1,
			0 ,p_element_version_id, 0, p_element_version_id, 'WF'
			FROM pa_proj_elem_ver_structure	struct_ver
			WHERE 1=1
			AND struct_ver.project_id = p_project_id
			AND struct_ver.element_version_id = p_element_version_id;

			/*
			** for wbs structure information
			*/
			INSERT INTO pji_rep_xbs_denorm
			(SUP_PROJECT_ID, PRG_ROLLUP_FLAG, PROJECT_ID, PARENT_ELEMENT_ID,
			CHILD_ELEMENT_ID, PRG_FLAG, NAME, ROLLUP_FLAG, DISPLAY_CHILD_FLAG,
			CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY,
			LAST_UPDATE_LOGIN, WBS_VERSION_ID,DISPLAY_SEQUENCE,OWNER_WBS_VERSION_ID,RELATIONSHIP_TYPE)
			SELECT denorm.sup_project_id,'N',denorm.sup_project_id,denorm.sup_emt_id,
			denorm.sub_emt_id,'N',emt.name,DECODE(denorm.sub_level-sup_level,0,'N','Y'),DECODE(denorm.sub_leaf_flag,'Y','N','Y'),
			SYSDATE, SYSDATE, 1, 1,
			0 ,p_element_version_id, ver.display_sequence,p_element_version_id, denorm.relationship_type
			FROM pji_xbs_denorm denorm, pa_proj_elements emt,pa_proj_element_versions ver
			WHERE 1=1
			AND denorm.sup_project_id = p_project_id
			AND denorm.struct_version_id = p_element_version_id
			AND denorm.sub_level - denorm.sup_level<=1
			AND denorm.struct_type = 'WBS'
			AND denorm.SUB_EMT_ID = emt.PROJ_ELEMENT_ID
			AND ver.project_id = p_project_id
			AND ver.parent_structure_version_id = p_element_version_id
			AND ver.object_type = 'PA_TASKS'
			AND ver.proj_element_id = denorm.sub_emt_id;

			INSERT INTO pji_rep_xbs_denorm
			(SUP_PROJECT_ID, PRG_ROLLUP_FLAG, PROJECT_ID, PARENT_ELEMENT_ID,
			CHILD_ELEMENT_ID, PRG_FLAG, NAME, ROLLUP_FLAG, DISPLAY_CHILD_FLAG,
			CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY,
			LAST_UPDATE_LOGIN, WBS_VERSION_ID,DISPLAY_SEQUENCE,OWNER_WBS_VERSION_ID,RELATIONSHIP_TYPE)
			SELECT
			denorm.sup_project_id
			, 'N'
			, denorm.sup_project_id
			, denorm.sup_emt_id
			, denorm.sub_emt_id
			, 'N'
			, emt.name
			, 'Y'
			, DECODE(denorm.sub_leaf_flag,'Y','N','Y')
			, SYSDATE
			, SYSDATE
			, 1
			, 1
			, 0
			, p_element_version_id
			, ver.display_sequence
			, p_element_version_id
			, denorm.relationship_type
			FROM pji_xbs_denorm denorm
			, pa_proj_elements emt
			,pa_proj_element_versions ver
			WHERE 1=1
			AND denorm.sup_project_id = p_project_id
			AND denorm.sub_emt_id = emt.proj_element_id
			AND denorm.struct_version_id = p_element_version_id
			AND denorm.struct_type = 'XBS'
			AND ver.project_id = p_project_id
			AND ver.parent_structure_version_id = p_element_version_id
			AND ver.object_type = 'PA_TASKS'
			AND ver.proj_element_id = denorm.sub_emt_id;

		ELSE


			SELECT COUNT(*)
			INTO l_count
			FROM pji_xbs_denorm
			WHERE sup_project_id = p_project_id
			AND sup_id = p_element_version_id
			AND struct_type = 'PRG'
			AND sub_level>sup_level
			AND ROWNUM=1;

			IF l_count >0 THEN
			   l_prg_flag := 'Y';
			ELSE
			   l_prg_flag := 'N';
			END IF;

			/*
			** Insert the virtual Header
			*/

			INSERT INTO pji_rep_xbs_denorm
			(SUP_PROJECT_ID, PRG_ROLLUP_FLAG, PROJECT_ID, PARENT_ELEMENT_ID,
			CHILD_ELEMENT_ID, PRG_FLAG, NAME, ROLLUP_FLAG, DISPLAY_CHILD_FLAG,
			CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY,
			LAST_UPDATE_LOGIN, WBS_VERSION_ID,DISPLAY_SEQUENCE,OWNER_WBS_VERSION_ID,RELATIONSHIP_TYPE)
			SELECT p_project_id
			, l_prg_flag
			,struct_ver.project_id
			,-1
			,struct_ver.proj_element_id
			,'Y'
			,struct_ver.NAME
			,'Y'
			,'Y'
			, SYSDATE
			, SYSDATE
			, 1
			, 1
			, 0
			,p_element_version_id
			, -1
			,p_element_version_id
			, 'WF'
			FROM pa_proj_elem_ver_structure	struct_ver
			WHERE 1=1
			AND struct_ver.project_id = p_project_id
			AND struct_ver.element_version_id = p_element_version_id;


			/*
			** Insert the project level self amount
			*/
			INSERT INTO pji_rep_xbs_denorm
			(SUP_PROJECT_ID, PRG_ROLLUP_FLAG, PROJECT_ID, PARENT_ELEMENT_ID,
			CHILD_ELEMENT_ID, PRG_FLAG, NAME, ROLLUP_FLAG, DISPLAY_CHILD_FLAG,
			CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY,
			LAST_UPDATE_LOGIN, WBS_VERSION_ID,DISPLAY_SEQUENCE,OWNER_WBS_VERSION_ID,RELATIONSHIP_TYPE)
			SELECT p_project_id
			, DECODE(struct_ver.project_id, p_project_id, l_prg_flag,DECODE(SUB_LEAF_FLAG,'Y','N','Y'))
			,struct_ver.project_id
			,denorm.sub_emt_id
			,denorm.sub_emt_id
			,'Y'
			,struct_ver.NAME
			,'N'
			,'N'
			, SYSDATE
			, SYSDATE
			, 1
			, 1
			, 0
			,p_element_version_id
			, 0
			, denorm.sup_id
			, 'WF'
			FROM pji_xbs_denorm denorm, pa_proj_elem_ver_structure	struct_ver, pa_proj_elements emt
			WHERE 1=1
			AND denorm.sup_project_id = p_project_id
			AND denorm.sup_id = p_element_version_id
			AND denorm.struct_version_id IS NULL
			AND denorm.struct_type = 'PRG'
			AND denorm.sub_id = struct_ver.element_version_id
			AND denorm.sub_emt_id = emt.proj_element_id
			AND emt.project_id = struct_ver.project_id
			AND NVL(denorm.relationship_type,'WF') IN ('WF',l_relationship_type);

			/*
			** Insert wbs information inside each structure
			*/
			INSERT INTO pji_rep_xbs_denorm
			(SUP_PROJECT_ID, PRG_ROLLUP_FLAG, PROJECT_ID, PARENT_ELEMENT_ID,
			CHILD_ELEMENT_ID, PRG_FLAG, NAME, ROLLUP_FLAG, DISPLAY_CHILD_FLAG,
			CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY,
			LAST_UPDATE_LOGIN, WBS_VERSION_ID,DISPLAY_SEQUENCE,OWNER_WBS_VERSION_ID,RELATIONSHIP_TYPE)
			SELECT p_project_id
			, DECODE(emt.project_id, p_project_id, l_prg_flag,DECODE(structs.SUB_LEAF_FLAG,'Y','N','Y'))
			,emt.project_id
			,denorm.sup_emt_id
			,denorm.sub_emt_id
			,'Y'
			,emt.name
			,DECODE(denorm.sub_level-denorm.sup_level,0,'N','Y')
			,DECODE(denorm.sub_leaf_flag,'Y','N','Y')
			, SYSDATE
			, SYSDATE
			, 1
			, 1
			, 0
			,p_element_version_id
			, ver.display_sequence
			,denorm.struct_version_id
			, denorm.relationship_type
			FROM pa_proj_elements emt, pji_xbs_denorm denorm,
				 (SELECT sub_id wbs_version_id, sub_leaf_flag
				  FROM pji_xbs_denorm
				  WHERE 1=1
				  AND sup_project_id = p_project_id
				  AND sup_id = p_element_version_id
				  AND struct_version_id IS NULL
				  AND struct_type = 'PRG'
   	  			  AND NVL(relationship_type,'WF') IN ('WF',l_relationship_type)
				  ) structs
				  ,pa_proj_element_versions ver
			WHERE 1=1
			AND denorm.sub_level-denorm.sup_level<=1
			AND denorm.struct_type = 'WBS'
			AND denorm.sub_emt_id = emt.proj_element_id
			AND denorm.struct_version_id = structs.wbs_version_id
			AND ver.project_id = emt.project_id
			AND ver.parent_structure_version_id = denorm.struct_version_id
			AND ver.object_type = 'PA_TASKS'
			AND ver.proj_element_id = denorm.sub_emt_id;

			/*
			** Insert the link between structure and the top level elements
			*/

			INSERT INTO pji_rep_xbs_denorm
			(SUP_PROJECT_ID, PRG_ROLLUP_FLAG, PROJECT_ID, PARENT_ELEMENT_ID,
			CHILD_ELEMENT_ID, PRG_FLAG, NAME, ROLLUP_FLAG, DISPLAY_CHILD_FLAG,
			CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY,
			LAST_UPDATE_LOGIN, WBS_VERSION_ID,DISPLAY_SEQUENCE,OWNER_WBS_VERSION_ID,RELATIONSHIP_TYPE)
			SELECT
			p_project_id
			, DECODE(emt.project_id, p_project_id, l_prg_flag,DECODE(structs.SUB_LEAF_FLAG,'Y','N','Y'))
			,emt.project_id
			, denorm.sup_emt_id
			, denorm.sub_emt_id
			, 'Y'
			, emt.name
			, 'Y'
			, DECODE(denorm.sub_leaf_flag,'Y','N','Y')
			, SYSDATE
			, SYSDATE
			, 1
			, 1
			, 0
			, p_element_version_id
			, ver.display_sequence
			, denorm.struct_version_id
			, denorm.relationship_type
			FROM pji_xbs_denorm denorm
			, pa_proj_elements emt
			, (SELECT sub_id wbs_version_id, sub_leaf_flag
				  FROM pji_xbs_denorm
				  WHERE 1=1
				  AND sup_project_id = p_project_id
				  AND sup_id = p_element_version_id
				  AND struct_version_id IS NULL
				  AND struct_type = 'PRG'
				  AND NVL(relationship_type,'WF') IN ('WF',l_relationship_type)
				  ) structs
	    	,pa_proj_element_versions ver
			WHERE 1=1
			AND denorm.sub_emt_id = emt.proj_element_id
			AND denorm.struct_version_id = structs.wbs_version_id
			AND denorm.struct_type = 'XBS'
			AND ver.project_id = emt.project_id
			AND ver.parent_structure_version_id = denorm.struct_version_id
			AND ver.object_type = 'PA_TASKS'
			AND ver.proj_element_id = denorm.sub_emt_id;

			/*
			* Insert link from project to project
			*/
			INSERT INTO pji_rep_xbs_denorm
			(SUP_PROJECT_ID, PRG_ROLLUP_FLAG, PROJECT_ID, PARENT_ELEMENT_ID,
			CHILD_ELEMENT_ID, PRG_FLAG, NAME, ROLLUP_FLAG, DISPLAY_CHILD_FLAG,
			CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY,
			LAST_UPDATE_LOGIN, WBS_VERSION_ID,DISPLAY_SEQUENCE,OWNER_WBS_VERSION_ID,RELATIONSHIP_TYPE)
			SELECT p_project_id
			,DECODE(struct_ver.project_id, p_project_id, l_prg_flag,DECODE(structs.SUB_LEAF_FLAG,'Y','N','Y'))
			,struct_ver.project_id
			,denorm.sub_rollup_id
			,denorm.sub_emt_id
			,'Y'
			,struct_ver.NAME
			,'Y'
			,'Y'
			, SYSDATE
			, SYSDATE
			, 1
			, 1
			, 0
			,p_element_version_id
			, -1
			, sub_id
			, denorm.relationship_type
			FROM pji_xbs_denorm denorm, pa_proj_elem_ver_structure	struct_ver,pa_proj_elements emt
			, (SELECT sub_id wbs_version_id, sub_leaf_flag
				  FROM pji_xbs_denorm
				  WHERE 1=1
				  AND sup_project_id = p_project_id
				  AND sup_id = p_element_version_id
				  AND struct_version_id IS NULL
				  AND struct_type = 'PRG'
				  AND NVL(relationship_type,'WF') IN ('WF',l_relationship_type)
				  ) structs
			WHERE 1=1
			AND denorm.sup_id = structs.wbs_version_id
			AND denorm.struct_type = 'PRG'
			AND denorm.struct_version_id IS NULL
			AND denorm.sub_rollup_id <> denorm.sup_emt_id
			AND denorm.sub_id = struct_ver.element_version_id
			AND denorm.sub_emt_id = emt.proj_element_id
			AND emt.project_id = struct_ver.project_id;

			/*
			* set rollup flag for elements have links to other projects
			*/

			UPDATE pji_rep_xbs_denorm
			SET display_child_flag = 'Y'
			WHERE rollup_flag = 'Y'
			AND sup_project_id = p_project_id
			AND prg_flag = 'Y'
			AND child_element_id IN
				  (SELECT sub_rollup_id
				   FROM pji_xbs_denorm,
				   (SELECT sub_id wbs_version_id, sub_leaf_flag
				   		   FROM pji_xbs_denorm
						   WHERE 1=1
						   AND sup_project_id = p_project_id
						   AND sup_id = p_element_version_id
						   AND struct_version_id IS NULL
				  		   AND struct_type = 'PRG'
						   AND NVL(relationship_type,'WF') IN ('WF',l_relationship_type)
						   ) structs
	 			   WHERE 1=1
				   AND struct_type ='PRG'
				   AND struct_version_id IS NULL
				   AND sup_id = structs.wbs_version_id
				   AND NVL(sub_rollup_id, sup_emt_id) <> sup_emt_id);

		END IF;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'populate_wbs_hierachy_cache: before getting percent', TRUE , g_proc);
	END IF;

	COMMIT;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'populate_wbs_hierachy_cache: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
                           x_msg_count := x_msg_count + 1;
                           x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Populate_WBS_Hierarchy_Cache');
	RAISE;
END;

PROCEDURE Populate_WP_Plan_Vers_Cache(p_project_id NUMBER
, p_prg_flag VARCHAR2 DEFAULT 'N'
, p_current_version_id NUMBER DEFAULT NULL
, p_latest_version_id NUMBER DEFAULT NULL
, p_baselined_version_id NUMBER DEFAULT NULL
, p_plan1_version_id NUMBER DEFAULT NULL
, p_plan2_version_id NUMBER DEFAULT NULL
, p_curr_wbs_vers_id NUMBER DEFAULT NULL
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS

BEGIN
        IF g_debug_mode = 'Y' THEN
           Pji_Utils.WRITE2LOG( 'Populate_WP_Plan_Vers_Cache: beginning', TRUE , g_proc);
        END IF;

        IF x_return_status IS NULL THEN
                x_msg_count := 0;
                x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        END IF;

        BEGIN
	  -- fnd_stats.set_table_stats('PJI','PJI_PLAN_EXTR_TMP',10,10,10);
	  pji_pjp_fp_curr_wrap.set_table_stats('PJI','PJI_PLAN_EXTR_TMP',10,10,10);
	END;

	DELETE FROM PJI_PLAN_EXTR_TMP;
        IF p_prg_flag = 'Y' THEN
                -- populate the plan versions ids into the temp table for the program hierarchy
                INSERT INTO PJI_PLAN_EXTR_TMP
                (PROJECT_ID, PLAN_VER_ID, LPB_PLAN_VER_ID, BASE_PLAN_VER_ID, PLAN1_VER_ID, PLAN2_VER_ID, STRUCT_VER_ID)
                SELECT
                         header.project_id,
                         MAX(DECODE(header_p.plan_version_id,p_current_version_id,header.plan_version_id,NULL)),
                         MAX(DECODE(header_p.plan_version_id,p_latest_version_id,header.plan_version_id,NULL)),
                         MAX(DECODE(header_p.plan_version_id,p_baselined_version_id,header.plan_version_id,NULL)),
                         MAX(DECODE(header_p.plan_version_id,p_plan1_version_id,header.plan_version_id,NULL)),
                         MAX(DECODE(header_p.plan_version_id,p_plan2_version_id,header.plan_version_id,NULL)),
                         MAX(DECODE(header_p.plan_version_id,p_current_version_id,header.wbs_version_id,NULL))
                FROM
                          pji_xbs_denorm denorm
                        , pa_proj_elements elem
                        , pji_pjp_wbs_header header
                        , pji_pjp_wbs_header header_p
                WHERE 1=1
                  AND header_p.project_id = p_project_id
                  AND header_p.plan_version_id IN
                  (
                        p_current_version_id,
                        p_latest_version_id,
                        p_baselined_version_id,
                        p_plan1_version_id,
                        p_plan2_version_id
                  )
                  AND denorm.sup_project_id = header_p.project_id
                  AND denorm.sup_id = header_p.wbs_version_id
                  AND denorm.struct_type = 'PRG'
                  AND NVL(denorm.relationship_type,'WF') IN ('LW','WF')
                  AND denorm.struct_version_id IS NULL
                  AND denorm.sub_emt_id = elem.proj_element_id
                  AND header.project_id = elem.project_id
                  AND header.wbs_version_id = denorm.sub_id
                  AND header.wp_flag = 'Y'
                GROUP BY header.project_id;
        ELSE
                INSERT INTO PJI_PLAN_EXTR_TMP
                (PROJECT_ID, PLAN_VER_ID, LPB_PLAN_VER_ID, BASE_PLAN_VER_ID, PLAN1_VER_ID, PLAN2_VER_ID, STRUCT_VER_ID)
                VALUES
                (p_project_id, p_current_version_id, p_latest_version_id, p_baselined_version_id, p_plan1_version_id, p_plan2_version_id, p_curr_wbs_vers_id);
        END IF;

        IF g_debug_mode = 'Y' THEN
           Pji_Utils.WRITE2LOG( 'Populate_WP_Plan_Vers_Cache: finishing', TRUE , g_proc);
        END IF;

EXCEPTION
        WHEN OTHERS THEN
        x_msg_count := x_msg_count + 1;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Default_Calendar_Info');
        RAISE;
END Populate_WP_Plan_Vers_Cache;

PROCEDURE Derive_Default_Calendar_Info(
p_project_id NUMBER
, x_calendar_type OUT NOCOPY VARCHAR2
, x_calendar_id  OUT NOCOPY NUMBER
, x_period_name  OUT NOCOPY VARCHAR2
, x_report_date_julian  OUT NOCOPY NUMBER
, x_slice_name OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS

l_tp_flag               varchar2(10);          --Bug 9048624
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_calendar_info: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;



	IF g_project_id <> p_project_id THEN
		/*
		** Following are the defaulting rules:
		** calendar_type: always pa calendar.
		** calendar_id: pa calendar id for the project org.
		** period_name: based on the project performance or implementations setup.
		** report_date: julian start date of the above determined period.
		*/
		Derive_Project_Attributes(p_project_id, x_return_status, x_msg_count, x_msg_data);
	END IF;

	/* Since we override our implemenation of enterprise calendar, we
	 * always use -1 as our enterprise calendar id .
	 */

	g_global_calendar_id := -1;
	g_global_calendar_type := 'E';
/*
	SELECT calendar_id
	INTO g_global_calendar_id
	FROM fii_time_cal_name
	WHERE period_set_name = Fnd_Profile.VALUE( 'BIS_ENTERPRISE_CALENDAR' )
	AND period_type = Fnd_Profile.VALUE( 'BIS_PERIOD_TYPE' );
*/
--Bug 5593229
--  	x_calendar_type := g_global_calendar_type;

--Bug 9048624
		l_tp_flag := PJI_UTILS.get_setup_parameter('TIME_PHASE_FLAG');

		if(l_tp_flag = 'N') then
			x_calendar_type := NVL(Fnd_Profile.value('PJI_DEF_RPT_CAL_TYPE'), 'E');
		else
			SELECT Min(calendar_type) into x_calendar_type
			FROM pji_fp_xbs_accum_f WHERE project_id = p_project_id
			and plan_version_id <> -1 and calendar_type <> 'A';
		end if;
--Bug 9048624

	Derive_Pa_Calendar_Info(p_project_id
	,x_calendar_type
	,x_calendar_id
	,x_report_date_julian
	,x_period_name
	,x_slice_name
	, x_return_status
	, x_msg_count
	, x_msg_data);


	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_calendar_info: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Default_Calendar_Info');
	RAISE;
END Derive_Default_Calendar_Info;

PROCEDURE Derive_WP_Calendar_Info(
p_project_id NUMBER
, p_plan_version_id NUMBER
, x_calendar_id  OUT NOCOPY NUMBER
, x_calendar_type OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS
l_fin_plan_type_id NUMBER(15);
l_time_phase_same_flag VARCHAR2(80);
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_wp_calendar_info: beginning', TRUE , g_proc);
	END IF;


/*	SELECT fin_plan_type_id
	INTO l_fin_plan_type_id
	FROM pa_budget_versions
	WHERE budget_version_id = p_plan_version_id;
*/
	Derive_VP_Calendar_Info(
	p_project_id
	, p_plan_version_id
	, NULL
	, 'COST'
	, x_calendar_id
	, x_calendar_type
	, l_time_phase_same_flag
	, x_return_status
	, x_msg_count
	, x_msg_data);

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_wp_calendar_info: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'WP CALENDAR');
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_WP_Calendar_Info');
	RAISE;
END Derive_WP_Calendar_Info;

PROCEDURE Derive_VP_Calendar_Info(
p_project_id NUMBER
, p_cst_version_id NUMBER
, p_rev_version_id NUMBER
, p_context_version_type VARCHAR2
, x_calendar_id  OUT NOCOPY NUMBER
, x_calendar_type OUT NOCOPY VARCHAR2
, x_time_phase_valid_flag OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS
l_gl_calendar_id NUMBER;
l_pa_calendar_id NUMBER;
l_all_cal_type VARCHAR2(30);
l_cost_cal_type VARCHAR2(30);
l_revenue_cal_type VARCHAR2(30);
l_preference_code VARCHAR2(30);
l_working_version_id NUMBER;
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_vp_calendar_info: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	IF p_cst_version_id IS NOT NULL AND p_cst_version_id <> -99 THEN
	   IF p_cst_version_id = p_rev_version_id THEN
	   	  l_preference_code := 'SAME';
	   ELSIF p_rev_version_id IS NOT NULL AND p_rev_version_id <> -99 THEN
	   	  l_preference_code := 'SEP';
	   ELSE
	   	  l_preference_code := 'COST';
	   END IF;
	   l_working_version_id := p_cst_version_id;
	ELSIF p_rev_version_id IS NOT NULL AND p_rev_version_id <> -99 THEN
	   l_working_version_id := p_rev_version_id;
	   l_preference_code := 'REVENUE';
	ELSE
		RETURN;
	END IF;


	SELECT org.gl_calendar_id,org.pa_calendar_id
	INTO l_gl_calendar_id, l_pa_calendar_id
	FROM
	pa_projects_all projects,
	pji_org_extr_info org
	/* WHERE NVL(projects.org_id,-99) = NVL(org.org_id,-99) -- Added NVL for bug 3989132 */
        WHERE projects.org_id = org.org_id -- Removed NVL for Bug5376591
	AND projects.project_id = p_project_id;

	SELECT all_time_phased_code, cost_time_phased_code, revenue_time_phased_code
	INTO   l_all_cal_type, l_cost_cal_type, l_revenue_cal_type
	FROM   pa_proj_fp_options
	WHERE  project_id = p_project_id
	AND    fin_plan_version_id = l_working_version_id
	AND    fin_plan_option_level_code = Pa_Fp_Constants_Pkg.G_OPTION_LEVEL_PLAN_VERSION;

	IF l_preference_code = 'SEP' THEN
		SELECT revenue_time_phased_code
		INTO   l_revenue_cal_type
		FROM   pa_proj_fp_options
		WHERE  project_id = p_project_id
		AND    fin_plan_version_id = p_rev_version_id
		AND    fin_plan_option_level_code = Pa_Fp_Constants_Pkg.G_OPTION_LEVEL_PLAN_VERSION;
	END IF ;

	IF l_preference_code = 	'REVENUE' THEN
	   x_calendar_type := l_revenue_cal_type;
	ELSIF l_preference_code  = 'SAME' THEN
	   x_calendar_type := l_all_cal_type;
	ELSIF l_preference_code = 'COST' THEN
	   x_calendar_type := l_cost_cal_type;
	ELSE
	/* if it is SEP, if cost is not valid, we will take revenue
	 * if revenue is not valid, we will take cost
	 * if both valid, we decide it using the context version type */
	   IF (l_cost_cal_type IS NULL) OR (l_cost_cal_type = 'N') THEN
	   	  x_calendar_type := l_revenue_cal_type;
	   ELSIF (l_revenue_cal_type IS NULL) OR (l_revenue_cal_type = 'N') THEN
	      x_calendar_type := l_cost_cal_type;
	   ELSE
	   	   IF p_context_version_type = 'COST' THEN
	   	   	  x_calendar_type := l_cost_cal_type;
		   ELSE
		      x_calendar_type := l_revenue_cal_type;
		   END IF ;
	   END IF ;
	END IF;

	-- We have make sure if cost is selected, it is valid, so if the selected one is not valid, that means
	-- revenue is not valid, so it will be an invalid case
	IF (x_calendar_type IS NULL) OR (x_calendar_type = 'N') THEN
	   x_time_phase_valid_flag := 'PJI_REP_PLAN_NOT_TF';
	/*
	 * the left cases are: 1. cost revenue both valid and same (Valid)
	 *  2. one is null, the other is valid (Valid)
	 *  3. cost revenue both valid and not same (Not Valid)
	 *  4, one is N, the other is valid (Not Valid)
	 * NVL(l_revenue_cal_type,l_cost_cal_type) <> NVL(l_cost_cal_type,l_rev_cal_type) will handle
	 * all 2,3,4 cases
	 */
	ELSIF (l_preference_code  = 'SEP') AND (NVL(l_revenue_cal_type,l_cost_cal_type) <> NVL(l_cost_cal_type,l_revenue_cal_type)) THEN
	   IF (l_revenue_cal_type = 'N') AND (l_cost_cal_type <>'N') THEN
	   	  x_time_phase_valid_flag := 'PJI_REP_REV_NOT_TF';
	   ELSIF (l_revenue_cal_type <> 'N') AND (l_cost_cal_type = 'N') THEN
	   	  x_time_phase_valid_flag := 'PJI_REP_COST_NOT_TF ';
	   ELSE
	   	   IF p_context_version_type = 'COST' THEN
	   	   	  x_time_phase_valid_flag := 'PJI_REP_TF_NOT_SAME';
		   ELSE
		      x_time_phase_valid_flag := 'PJI_REP_TF_NOT_SAME_REV';
		   END IF ;
	   END IF;
	ELSE
	   x_time_phase_valid_flag := 'Y';
	END IF;


	IF x_calendar_type = Pa_Fp_Constants_Pkg.G_TIME_PHASED_CODE_P THEN
	   x_calendar_id := l_pa_calendar_id;
	ELSIF x_calendar_type = Pa_Fp_Constants_Pkg.G_TIME_PHASED_CODE_G THEN
	   x_calendar_id := l_gl_calendar_id;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_vp_calendar_info: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Pji_Rep_Util.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'VP CALENDAR');
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Vp_Calendar_Info');
	RAISE;
END Derive_Vp_Calendar_Info;


FUNCTION Get_Version_Type(
p_project_id NUMBER
, p_fin_plan_type_id NUMBER
, p_version_type VARCHAR2
) RETURN VARCHAR2 IS
l_version_type pa_budget_versions.version_type%TYPE;
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'get_version_type: beginning', TRUE , g_proc);
	END IF;

	SELECT fin_plan_preference_code
	INTO   l_version_type
	FROM   pa_proj_fp_options
	WHERE  project_id = p_project_id
	AND    fin_plan_type_id = p_fin_plan_type_id
	AND    fin_plan_option_level_code = Pa_Fp_Constants_Pkg.G_OPTION_LEVEL_PLAN_TYPE;

	IF  l_version_type = Pa_Fp_Constants_Pkg.G_PREF_COST_AND_REV_SAME	THEN
		l_version_type := Pa_Fp_Constants_Pkg.G_VERSION_TYPE_ALL;
	ELSE
		l_version_type := p_version_type;
	END IF;

	IF g_debug_mode = 'Y' THEN
		Pji_Utils.WRITE2LOG( 'get_version_type: returning', TRUE , g_proc);
	END IF;

	RETURN l_version_type;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'VERSION TYPE');
	RETURN NULL;
END Get_Version_Type;

/*
** derive all plan versions-related default information
*/
PROCEDURE Derive_Default_Plan_Versions(
p_project_id NUMBER
, x_actual_version_id OUT NOCOPY NUMBER
, x_cstforecast_version_id OUT NOCOPY NUMBER
, x_cstbudget_version_id OUT NOCOPY NUMBER
, x_cstbudget2_version_id OUT NOCOPY NUMBER
, x_revforecast_version_id OUT NOCOPY NUMBER
, x_revbudget_version_id OUT NOCOPY NUMBER
, x_revbudget2_version_id OUT NOCOPY NUMBER
, x_orig_cstforecast_version_id OUT NOCOPY NUMBER
, x_orig_cstbudget_version_id OUT NOCOPY NUMBER
, x_orig_cstbudget2_version_id OUT NOCOPY NUMBER
, x_orig_revforecast_version_id OUT NOCOPY NUMBER
, x_orig_revbudget_version_id OUT NOCOPY NUMBER
, x_orig_revbudget2_version_id OUT NOCOPY NUMBER
, x_prior_cstfcst_version_id OUT NOCOPY NUMBER
, x_prior_revfcst_version_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS
l_cst_budget_version_type pa_budget_versions.version_type%TYPE;
l_rev_budget_version_type pa_budget_versions.version_type%TYPE;
l_cst_forecast_version_type pa_budget_versions.version_type%TYPE;
l_rev_forecast_version_type pa_budget_versions.version_type%TYPE;
l_fp_options_id pa_proj_fp_options.proj_fp_options_id%TYPE;
l_temp_holder1 NUMBER;
l_temp_holder2 NUMBER;
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_plan_versions: beginning', TRUE , g_proc);
	END IF;


	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

--	IF g_project_id <> p_project_id THEN
	/*
	** Following are the defaulting rules:
	** cost budget plan version: current baselined version of approved cost plan type.
	** revenue budget plan version: current baselined version of approved revenue plan type.
	** cost forecast plan version: current baselined version of primary cost plan type.
	** revenue forecast plan version: current baselined version of primary revenue plan type.
	** cost budget2 plan version: null.
	** revenue budget2 plan version: null.
	** misc: return original baselined for all above plan versions.
	*/
	BEGIN
		/*
		** Get approved cost and revenue plan types for the
		** project.
		*/
		Pa_Fin_Plan_Utils.Get_Appr_Cost_Plan_Type_Info(
	          p_project_id=>p_project_id
	          ,x_plan_type_id =>g_cost_bgt_plan_type_id
	          ,x_return_status=>x_return_status
	          ,x_msg_count=>x_msg_count
	          ,x_msg_data=>x_msg_data);
		Pa_Fin_Plan_Utils.Get_Appr_Rev_Plan_Type_Info(
	          p_project_id=>p_project_id
	          ,x_plan_type_id=>g_rev_bgt_plan_type_id
	          ,x_return_status=>x_return_status
	          ,x_msg_count=>x_msg_count
	          ,x_msg_data=>x_msg_data);
		/*
		** Get primary cost and revenue plan types for the
		** project.
		*/
		Pa_Fin_Plan_Utils.Is_Pri_Fcst_Cost_PT_Attached(
	          p_project_id=>p_project_id
	          ,x_plan_type_id=>g_cost_fcst_plan_type_id
	          ,x_return_status=>x_return_status
	          ,x_msg_count=>x_msg_count
	          ,x_msg_data=>x_msg_data);
		Pa_Fin_Plan_Utils.Is_Pri_Fcst_Rev_PT_Attached(
	          p_project_id=>p_project_id
	          ,x_plan_type_id=>g_rev_fcst_plan_type_id
	          ,x_return_status=>x_return_status
	          ,x_msg_count=>x_msg_count
	          ,x_msg_data=>x_msg_data);
		/*
		** Get current and original baselined plan versions
		** for approved/primary cost and revenue plan types.
		*/
		IF g_cost_bgt_plan_type_id IS NOT NULL THEN
			Pa_Fin_Plan_Utils.Get_Cost_Base_Version_Info(
		          p_project_id=>p_project_id
		          ,p_fin_plan_Type_id=>g_cost_bgt_plan_type_id
		          ,p_budget_type_code=>NULL
		          ,x_budget_version_id=>g_cstbudget_version_id
		          ,x_return_status =>x_return_status
		          ,x_msg_count=>x_msg_count
		          ,x_msg_data=>x_msg_data);

			l_cst_budget_version_type:=Get_Version_Type(p_project_id
			    ,g_cost_bgt_plan_type_id
			    ,Pa_Fp_Constants_Pkg.G_VERSION_TYPE_COST);

			Pa_Fin_Plan_Utils.Get_Curr_Original_Version_Info(
		          p_project_id=>p_project_id
		          ,p_fin_plan_Type_id=>g_cost_bgt_plan_type_id
		          ,p_version_type=>l_cst_budget_version_type
			    ,x_fp_options_id=>l_fp_options_id
		          ,x_fin_plan_version_id=>g_orig_cstbudget_version_id
		          ,x_return_status =>x_return_status
		          ,x_msg_count=>x_msg_count
		          ,x_msg_data=>x_msg_data);
		END IF;

		IF g_rev_bgt_plan_type_id IS NOT NULL THEN
			Pa_Fin_Plan_Utils.Get_Rev_Base_Version_Info(
		          p_project_id=>p_project_id
		          ,p_fin_plan_Type_id=>g_rev_bgt_plan_type_id
		          ,p_budget_type_code=>NULL
		          ,x_budget_version_id=>g_revbudget_version_id
		          ,x_return_status =>x_return_status
		          ,x_msg_count=>x_msg_count
		          ,x_msg_data=>x_msg_data);

			l_rev_budget_version_type:=Get_Version_Type(p_project_id
			    ,g_rev_bgt_plan_type_id
			    ,Pa_Fp_Constants_Pkg.G_VERSION_TYPE_REVENUE);

			Pa_Fin_Plan_Utils.Get_Curr_Original_Version_Info(
		          p_project_id=>p_project_id
		          ,p_fin_plan_Type_id=>g_rev_bgt_plan_type_id
		          ,p_version_type=>l_rev_budget_version_type
			    ,x_fp_options_id=>l_fp_options_id
		          ,x_fin_plan_version_id=>g_orig_revbudget_version_id
		          ,x_return_status =>x_return_status
		          ,x_msg_count=>x_msg_count
		          ,x_msg_data=>x_msg_data);
		END IF;

		IF g_cost_fcst_plan_type_id IS NOT NULL THEN
			Pa_Fin_Plan_Utils.Get_Cost_Base_Version_Info(
		          p_project_id=>p_project_id
		          ,p_fin_plan_Type_id=>g_cost_fcst_plan_type_id
		          ,p_budget_type_code=>NULL
		          ,x_budget_version_id=>g_cstforecast_version_id
		          ,x_return_status =>x_return_status
		          ,x_msg_count=>x_msg_count
		          ,x_msg_data=>x_msg_data);

			l_cst_forecast_version_type:=Get_Version_Type(p_project_id
			    ,g_cost_fcst_plan_type_id
			    ,Pa_Fp_Constants_Pkg.G_VERSION_TYPE_COST);

			Pa_Fin_Plan_Utils.Get_Curr_Original_Version_Info(
		          p_project_id=>p_project_id
		          ,p_fin_plan_Type_id=>g_cost_fcst_plan_type_id
		          ,p_version_type=>l_cst_forecast_version_type
			    ,x_fp_options_id=>l_fp_options_id
		          ,x_fin_plan_version_id=>g_orig_cstforecast_version_id
		          ,x_return_status =>x_return_status
		          ,x_msg_count=>x_msg_count
		          ,x_msg_data=>x_msg_data);

			IF (g_cstforecast_version_id IS NOT NULL) AND (g_cstforecast_version_id <>-99) THEN
				Pa_Planning_Element_Utils.get_finplan_bvids(p_project_id=>p_project_id
				,p_budget_version_id => g_cstforecast_version_id
				, x_current_version_id => l_temp_holder1
				, x_original_version_id => l_temp_holder2
				, x_prior_fcst_version_id => x_prior_cstfcst_version_id
		         ,x_return_status =>x_return_status
		         ,x_msg_count=>x_msg_count
		         ,x_msg_data=>x_msg_data);
			--Bug5510794 deriving the correct prior forecast version id
			x_prior_cstfcst_version_id := Pa_Planning_Element_Utils.get_prior_forecast_version_id
						(g_cstforecast_version_id, p_project_id);
			END IF;

		END IF;

		IF g_rev_fcst_plan_type_id IS NOT NULL THEN
			Pa_Fin_Plan_Utils.Get_Rev_Base_Version_Info(
		          p_project_id=>p_project_id
		          ,p_fin_plan_Type_id=>g_rev_fcst_plan_type_id
		          ,p_budget_type_code=>NULL
		          ,x_budget_version_id=>g_revforecast_version_id
		          ,x_return_status =>x_return_status
		          ,x_msg_count=>x_msg_count
		          ,x_msg_data=>x_msg_data);

			l_rev_forecast_version_type:=Get_Version_Type(p_project_id
			    ,g_rev_fcst_plan_type_id
			    ,Pa_Fp_Constants_Pkg.G_VERSION_TYPE_REVENUE);

			Pa_Fin_Plan_Utils.Get_Curr_Original_Version_Info(
		          p_project_id=>p_project_id
		          ,p_fin_plan_Type_id=>g_rev_fcst_plan_type_id
		          ,p_version_type=>l_rev_forecast_version_type
			    ,x_fp_options_id=>l_fp_options_id
		          ,x_fin_plan_version_id=>g_orig_revforecast_version_id
		          ,x_return_status =>x_return_status
		          ,x_msg_count=>x_msg_count
		          ,x_msg_data=>x_msg_data);

			IF (g_revforecast_version_id IS NOT NULL) AND (g_revforecast_version_id <>-99) THEN
				Pa_Planning_Element_Utils.get_finplan_bvids(p_project_id=>p_project_id
				,p_budget_version_id => g_revforecast_version_id
				, x_current_version_id => l_temp_holder1
				, x_original_version_id => l_temp_holder2
				, x_prior_fcst_version_id => x_prior_revfcst_version_id
		         ,x_return_status =>x_return_status
		         ,x_msg_count=>x_msg_count
		         ,x_msg_data=>x_msg_data);
			--Bug5510794 deriving the correct prior forecast version id
			x_prior_revfcst_version_id := Pa_Planning_Element_Utils.get_prior_forecast_version_id
						(g_revforecast_version_id, p_project_id);
			END IF;
		END IF;
		g_actual_version_id := get_fin_plan_actual_version(p_project_id);
	  	g_project_id := p_project_id;
	END;
--	END IF;
	x_cstforecast_version_id := g_cstforecast_version_id;
	x_cstbudget_version_id := g_cstbudget_version_id;
	x_revforecast_version_id := g_revforecast_version_id;
	x_revbudget_version_id := g_revbudget_version_id;
	x_orig_cstforecast_version_id := g_orig_cstforecast_version_id;
	x_orig_cstbudget_version_id := g_orig_cstbudget_version_id;
	x_orig_revforecast_version_id := g_orig_revforecast_version_id;
	x_orig_revbudget_version_id := g_orig_revbudget_version_id;
	x_actual_version_id := g_actual_version_id;

	/*
	** Budget2 information is always defaulted to null. This is provided
	** as a placeholder for any future changes.
	*/
	x_cstbudget2_version_id := g_cstbudget2_version_id;
	x_revbudget2_version_id := g_revbudget2_version_id;
	x_orig_cstbudget2_version_id := g_orig_cstbudget2_version_id;
	x_orig_revbudget2_version_id := g_orig_revbudget2_version_id;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_plan_versions: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Default_Plan_Versions');
	RAISE;
END Derive_Default_Plan_Versions;

/*
** derive all plan versions-related default information
*/
PROCEDURE Derive_Default_Currency_Info(
p_project_id NUMBER
, x_currency_record_type OUT NOCOPY NUMBER
, x_currency_code OUT NOCOPY VARCHAR2
, x_currency_type OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY  VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS


BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_currency_info: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

--	IF g_project_id <> p_project_id THEN
		/*
		** Following are the defaulting rules:
		** currency rec type: always project currency (8).
		** currency code: derive project currency code from pa_projects_all.
		** currency_type: always project currency 'P'.
		*/
		Derive_Project_Attributes(p_project_id, x_return_status, x_msg_count, x_msg_data);
--	END IF;

	x_currency_record_type:=8;
	x_currency_type:='P';
	x_currency_code:=g_proj_currency_code;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_currency_info: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Default_Currency_Info');
	RAISE;
END Derive_Default_Currency_Info;


PROCEDURE Derive_Perf_Currency_Info(
p_project_id NUMBER
, x_currency_record_type OUT NOCOPY NUMBER
, x_currency_code OUT NOCOPY VARCHAR2
, x_currency_type OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY  VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS


BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_perf_currency_info: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

/*--bug 5593229
 	x_currency_record_type:=1;
	x_currency_type:='G';
	x_currency_code:=Pji_Utils.get_global_primary_currency;
*/

	IF (Fnd_Profile.value('PJI_DEF_RPT_CUR_TYPE') = 'GLOBAL_CURRENCY')  THEN
	  IF pji_utils.get_setup_parameter('GLOBAL_CURR1_FLAG') = 'Y' THEN         --Bug 9067029
		x_currency_record_type:= 1;
		x_currency_type:= 'G';
		x_currency_code:= Pji_Utils.get_global_primary_currency;
	  ELSE
	    x_currency_record_type:= 4;
		x_currency_type:= 'F';
		x_currency_code := g_projfunc_currency_code;
      END IF;
	ELSIF (Fnd_Profile.value('PJI_DEF_RPT_CUR_TYPE') = 'SEC_GLOBAL_CURRENCY') THEN
	  IF pji_utils.get_setup_parameter('GLOBAL_CURR2_FLAG') = 'Y' THEN          --Bug 9067029
		x_currency_record_type:= 2;
		x_currency_type:= 'G';
		x_currency_code:= Pji_Utils.get_global_secondary_currency;
	  ELSE
		x_currency_record_type:= 4;
		x_currency_type:= 'F';
		x_currency_code := g_projfunc_currency_code;
	  END IF;
	ELSIF (Fnd_Profile.value('PJI_DEF_RPT_CUR_TYPE') = 'PROJ_CURRENCY')  THEN
		x_currency_record_type:= 8;
		x_currency_type:= 'P';
		x_currency_code:= g_proj_currency_code;
	ELSE
		x_currency_record_type:= 4;
		x_currency_type:= 'F';
		x_currency_code := g_projfunc_currency_code;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_currency_info: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Default_Currency_Info');
	RAISE;
END Derive_Perf_Currency_Info;

FUNCTION Derive_FactorBy(
p_project_id NUMBER
, p_fin_plan_version_id NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
l_factor_by_code VARCHAR2(30);
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_factorby: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	IF p_fin_plan_version_id IS NOT NULL THEN
		/*
		 ** Pick the default factor by defined for the selected
		 ** plan_type.
		 */
		SELECT factor_by_code
		INTO l_factor_by_code
		FROM pa_proj_fp_options
		WHERE 1=1
		AND fin_plan_option_level_code = 'PLAN_VERSION'
		AND project_id = p_project_id
		AND fin_plan_version_id = p_fin_plan_version_id;
	ELSE
		/*
		 ** In project performance we display data for more
		 ** than one plan type hence we donot know what plantype
		 ** to derive the default value from. That is the reason
		 ** why we have hard coded it to be 1.
		 */
		l_factor_by_code:= 1;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_factorby: returning', TRUE , g_proc);
	END IF;

	RETURN l_factor_by_code;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN '1';
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_FactorBy');
	RETURN '1';
END Derive_FactorBy;

FUNCTION Derive_Prg_Rollup_Flag(
p_project_id NUMBER) RETURN VARCHAR2 IS
l_return_status VARCHAR2(1000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_prg_rollup_flag: beginning', TRUE , g_proc);
	END IF;

--	IF p_project_id <> g_project_id THEN
	   	/*
		** Refresh all cached values for the project.
		*/
		Derive_Project_Attributes(p_project_id, l_return_status, l_msg_count, l_msg_data);
--	END IF;

	RETURN g_prg_flag;

--	RETURN 'N'; --bug 4127656 temporarily turn off program reporting

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_prg_rollup_flag: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_prg_rollup_flag');
	RETURN NULL;
END Derive_Prg_Rollup_Flag;

FUNCTION Derive_Perf_Prg_Rollup_Flag(
p_project_id NUMBER) RETURN VARCHAR2 IS
BEGIN
	 RETURN 'N';
END;

PROCEDURE Derive_Project_Attributes(
p_project_id NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_project_attributes: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

--	IF p_project_id <> g_project_id THEN
	   /*
	   ** Reset the values of the project cache to null to ensure
	   ** that cache never reflects out of sync values.
	   */
	   g_project_org_id:=NULL;
	   g_proj_currency_code:=NULL;
	   g_prg_flag:=NULL;
	   g_gl_calendar_id:=NULL;
	   g_pa_calendar_id:=NULL;
	   g_project_id := p_project_id;
	   /*
	   ** Derive all the required values for a given project. The
	   ** join to org_extr table will ensure that we always return
	   ** data for summarized projects.
	   */
	   SELECT
	   prj.org_id
	   , prj.project_currency_code
                             , prj.projfunc_currency_code
	   , NVL(prj.sys_program_flag,'N')
	   , info.gl_calendar_id
	   , info.pa_calendar_id
	   INTO
	   g_project_org_id
	   , g_proj_currency_code
                             , g_projfunc_currency_code
	   , g_prg_flag
	   , g_gl_calendar_id
	   , g_pa_calendar_id
	   FROM pa_projects_all prj
	   , pji_org_extr_info info
	   WHERE project_id = p_project_id
	   /* AND NVL(info.org_id,-99) = NVL(prj.org_id,-99); -- Added NVL for bug 3989132 */
           AND info.org_id = prj.org_id; -- Removed NVL for Bug5376591

   	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_project_attributes: finishing', TRUE , g_proc);
	END IF;

--	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'PROJ ATTRIBUTES');
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Project_Attributes');
	RAISE;
END Derive_Project_Attributes;

/*
 * Not for project performance, only for workplan and fin plan
*/
PROCEDURE Derive_Default_RBS_Parameters(
p_project_id NUMBER
,p_plan_version_id NUMBER
, x_rbs_version_id OUT NOCOPY NUMBER
, x_rbs_element_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_rbs_parameters: beginning', TRUE , g_proc);
	END IF;


	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	SELECT rbs_version_id
	INTO x_rbs_version_id
	FROM
	pa_proj_fp_options
	WHERE fin_plan_version_id = p_plan_version_id;

	IF x_rbs_version_id IS NULL THEN
	   RAISE NO_DATA_FOUND;
	END IF;

	Derive_Default_Rbs_Element_Id(
	x_rbs_version_id
	, x_rbs_element_id
	, x_return_status
	, x_msg_count
	, x_msg_data);

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_rbs_parameters: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_rbs_version_id := -99;
	x_rbs_element_id := -99;
/*	x_msg_count := x_msg_count + 1;
	x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_VP_NO_RBS_VERSION', p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING);
*/	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Default_RBS_Parameters');
	RAISE;
END Derive_Default_RBS_Parameters;


/*
 * Not for fin plan and work plan, only for project performance
*/
PROCEDURE Derive_Perf_RBS_Parameters(
p_project_id NUMBER
,p_plan_version_id NUMBER
,p_prg_flag VARCHAR DEFAULT 'N'
, x_rbs_version_id OUT NOCOPY NUMBER
, x_rbs_element_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
CURSOR c_rbs_versions IS
	SELECT rbs_version_id
	FROM
	pa_rbs_prj_assignments
	WHERE
	project_id = p_project_id
	AND assignment_status ='ACTIVE'
	AND prog_rep_usage_flag IN ('Y',p_prg_flag)
	ORDER BY primary_reporting_rbs_flag DESC;
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_perf_rbs_parameters: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;


	OPEN c_rbs_versions;
		FETCH c_rbs_versions INTO x_rbs_version_id;

		IF c_rbs_versions%NOTFOUND THEN
		   CLOSE c_rbs_versions; /* Added for bug 7270236 */
		   RAISE NO_DATA_FOUND;
		END IF;

	CLOSE c_rbs_versions; --bug#3877822

	IF x_rbs_version_id IS NULL THEN
	   RAISE NO_DATA_FOUND;
	END IF;

	Derive_Default_Rbs_Element_Id(
	x_rbs_version_id
	, x_rbs_element_id
	, x_return_status
	, x_msg_count
	, x_msg_data);

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_perf_rbs_parameters: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_rbs_version_id := -99;
	x_rbs_element_id := -99;
/*	x_msg_count := x_msg_count + 1;
	x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_PERF_NO_RBS_VERSION', p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING);
*/	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Perf_RBS_Parameters');
	RAISE;
END Derive_Perf_RBS_Parameters;


PROCEDURE Derive_Default_RBS_Element_Id(
p_rbs_version_id NUMBER
, x_rbs_element_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
CURSOR c_rbs_elements IS
	SELECT rbs_element_id
	FROM
	pa_rbs_elements rbs
	WHERE
	rbs.rbs_version_id = p_rbs_version_id
	AND rbs.rbs_level = 1
	ORDER BY rbs.user_created_flag;

BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_rbs_element_id: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	OPEN c_rbs_elements;
		FETCH c_rbs_elements INTO x_rbs_element_id;

		IF c_rbs_elements%NOTFOUND THEN
		   RAISE NO_DATA_FOUND;
		END IF;

	CLOSE c_rbs_elements;  -- Bug#3877822

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_rbs_element_id: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'RBS ELEMENT');
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Default_RBS_Element_Id');
	RAISE;
END Derive_Default_RBS_Element_Id;

PROCEDURE Derive_Default_WBS_Parameters(
p_project_id NUMBER
,p_plan_version_id NUMBER
, x_wbs_version_id OUT NOCOPY NUMBER
, x_wbs_element_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_wbs_parameter: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	BEGIN
		SELECT hdr.wbs_version_id
		INTO x_wbs_version_id
		FROM
		pji_pjp_wbs_header hdr
		WHERE
		hdr.project_id = p_project_id
		AND hdr.plan_version_id = p_plan_version_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RETURN;
	END;

	BEGIN
		SELECT elm.proj_element_id
		INTO x_wbs_element_id
		FROM pa_proj_element_versions elm
		WHERE elm.element_version_id = x_wbs_version_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		x_msg_count := x_msg_count + 1;
		x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
		Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'WBS ELEMENT');
	END;

/*	SELECT hdr.wbs_version_id,elm.proj_element_id
	INTO x_wbs_version_id, x_wbs_element_id
	FROM
	pji_pjp_wbs_header hdr
	, pa_proj_element_versions elm
	WHERE
	hdr.wbs_version_id = elm.element_version_id
	AND hdr.project_id = p_project_id
	AND hdr.plan_version_id = p_plan_version_id;
*/
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_wbs_parameter: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Default_WBS_Parameters');
	RAISE;
END Derive_Default_WBS_Parameters;

PROCEDURE Derive_WP_WBS_Parameters(
p_project_id NUMBER
, x_wbs_version_id OUT NOCOPY NUMBER
, x_wbs_element_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
CURSOR c_wbs_params IS
	SELECT element_version_id, proj_element_id
	FROM
	pa_proj_elem_ver_structure
	WHERE
	project_id = p_project_id
	ORDER BY NVL(Latest_eff_published_flag,'N') DESC, NVL(current_working_flag,'N') DESC;
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_wp_wbs_parameter: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	OPEN c_wbs_params;
		FETCH c_wbs_params INTO x_wbs_version_id,x_wbs_element_id;

		IF c_wbs_params%NOTFOUND THEN
		   RAISE NO_DATA_FOUND;
		END IF;

	CLOSE c_wbs_params; --bug#3877822

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_wp_wbs_parameter: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_WP_WBS_Parameters');
	RAISE;
END Derive_WP_WBS_Parameters;



/*
 *  Slice name is decide by the calendar type and the number
 *  of records in the time tables.
 *  if the calendar type is "E" (same as calendar_id =-1), operation goes to the _ENT_ table
 *  otherwise operation goes to the _CAL_ table
 *  in the sequence of Period, Quarter and Year, if the qualified records in the table is
 *  less or equals to 12, then use that table name as the slice name otherwise go to the next table
 */
PROCEDURE Derive_Slice_Name(
p_project_id NUMBER
, p_calendar_id NUMBER
, x_slice_name OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
l_start_date DATE;
l_end_date DATE;
l_rec_count NUMBER;
BEGIN

	Pa_Debug.init_err_stack('PJI_REP_UTIL.Derive_Slice_Name');
	IF g_debug_mode = 'Y' THEN
	   Pa_Debug.write_file('Derive_Slice_Name: beginning',5);
--	   Pji_Utils.WRITE2LOG( 'derive_slice_name: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	SELECT start_date,NVL(completion_date,TRUNC(SYSDATE))
	INTO l_start_date, l_end_date
	FROM pa_projects_all
	WHERE project_id = p_project_id;

	IF p_calendar_id = -1 THEN

	   SELECT COUNT(*)
	   INTO l_rec_count
	   FROM pji_time_ent_period_v
	   WHERE start_date >= l_start_date
	   AND end_date <= l_end_date;

	   IF l_rec_count > 12 THEN

	   	   SELECT COUNT(*)
		   INTO l_rec_count
		   FROM pji_time_ent_qtr_v
		   WHERE start_date >= l_start_date
		   AND end_date <= l_end_date;

		   IF l_rec_count <= 1 THEN
		   	  x_slice_name := 'PJI_TIME_ENT_PERIOD_V';
		   ELSIF l_rec_count > 12 THEN

	   	   	   SELECT COUNT(*)
	   		   INTO l_rec_count
	   		   FROM pji_time_ent_year_v
	   		   WHERE start_date >= l_start_date
	   		   AND end_date <= l_end_date;

			   IF l_rec_count <=1 THEN
	   			   x_slice_name := 'PJI_TIME_ENT_QTR_V';
			   ELSE
			   	   x_slice_name := 'PJI_TIME_ENT_YEAR_V';
			   END IF;
		   ELSE
		   	  x_slice_name := 'PJI_TIME_ENT_QTR_V';
		   END IF;
	   ELSE
	   	   x_slice_name := 'PJI_TIME_ENT_PERIOD_V';
	   END IF;
	ELSE

	   SELECT COUNT(*)
	   INTO l_rec_count
	   FROM pji_time_cal_period_v
	   WHERE start_date >= l_start_date
	   AND end_date <= l_end_date
	   AND calendar_id = p_calendar_id;

	   IF l_rec_count > 12 THEN

	   	   SELECT COUNT(*)
		   INTO l_rec_count
		   FROM pji_time_cal_qtr_v
		   WHERE start_date >= l_start_date
		   AND end_date <= l_end_date
		   AND calendar_id = p_calendar_id;

		   IF l_rec_count <= 1 THEN
		   	  x_slice_name := 'PJI_TIME_CAL_PERIOD_V';
		   ELSIF l_rec_count > 12 THEN

		   	   SELECT COUNT(*)
			   INTO l_rec_count
			   FROM pji_time_cal_year_v
			   WHERE start_date >= l_start_date
			   AND end_date <= l_end_date
			   AND calendar_id = p_calendar_id;

			   IF l_rec_count <=1 THEN
	   			   x_slice_name := 'PJI_TIME_CAL_QTR_V';
			   ELSE
			   	   x_slice_name := 'PJI_TIME_CAL_YEAR_V';
			   END IF;
		   ELSE
		   	  x_slice_name := 'PJI_TIME_CAL_QTR_V';
		   END IF;
	   ELSE
	   	   x_slice_name := 'PJI_TIME_CAL_PERIOD_V';
	   END IF;

	END IF;

	IF g_debug_mode = 'Y' THEN
--	   Pji_Utils.WRITE2LOG( 'derive_slice_name: finishing', TRUE , g_proc);
  	   Pa_Debug.write_file('Derive_Slice_Name: returning',5);
	END IF;
	Pa_Debug.Reset_Err_Stack;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'SLICE NAME');
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Slice_Name');
	RAISE;
END Derive_Slice_Name;

PROCEDURE Derive_Plan_Type_Parameters(
p_project_id NUMBER
, p_fin_plan_type_id NUMBER
, x_plan_pref_code OUT NOCOPY VARCHAR2
, x_budget_forecast_flag OUT NOCOPY VARCHAR2
, x_plan_type_name OUT NOCOPY VARCHAR2
, x_plan_report_mask OUT NOCOPY VARCHAR2
, x_plan_margin_mask OUT NOCOPY VARCHAR2
, x_cost_app_flag IN OUT NOCOPY VARCHAR2
, x_rev_app_flag IN OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
l_class_code VARCHAR2(30);
BEGIN

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_plan_type_parameters: begining', TRUE , g_proc);
	END IF;

	SELECT pt.plan_class_code
	, pt.NAME
	, op.FIN_PLAN_PREFERENCE_CODE
	, op.MARGIN_DERIVED_FROM_CODE
	, DECODE(op.fin_plan_preference_code,
	  		'COST_AND_REV_SEP',op.report_labor_hrs_from_code,
			'REVENUE_ONLY','REVENUE',
			'COST')
        , NVL(op.approved_cost_plan_type_flag,'N')
        , NVL(op.approved_rev_plan_type_flag, 'N')
	INTO l_class_code
	, x_plan_type_name
	, x_plan_pref_code
	, x_plan_margin_mask
	, x_plan_report_mask
        , x_cost_app_flag
        , x_rev_app_flag
	FROM pa_fin_plan_types_vl pt
	, pa_proj_fp_options op
	WHERE 1=1
	AND pt.fin_plan_type_id = p_fin_plan_type_id
	AND op.fin_plan_type_id = pt.fin_plan_type_id
	AND op.fin_plan_option_level_code = 'PLAN_TYPE'
	AND op.project_id = p_project_id;

	IF l_class_code = 'BUDGET' THEN
	   x_budget_forecast_flag := 'B';
	ELSE
	   x_budget_forecast_flag := 'F';
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_plan_type_parameters: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'PLAN TYPE PARAMETERS');
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Plan_Type_Parameters');
	RAISE;
END Derive_Plan_Type_Parameters;


PROCEDURE Derive_Version_Margin_Mask(
p_project_id NUMBER
, p_plan_version_id NUMBER
, x_plan_margin_mask OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
BEGIN

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_version_margin_mask: begining', TRUE , g_proc);
	END IF;

	SELECT op.MARGIN_DERIVED_FROM_CODE
	INTO x_plan_margin_mask
	FROM pa_proj_fp_options op
	WHERE op.fin_plan_version_id = p_plan_version_id
	AND op.fin_plan_option_level_code = 'PLAN_VERSION'
	AND op.project_id = p_project_id;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_version_margin_mask: finishing', TRUE , g_proc);
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'PLAN VERSION MARGIN MASK');
	x_plan_margin_mask := 'B';
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Version_Margin_Mask');
	RAISE;
END Derive_Version_Margin_Mask;

PROCEDURE Derive_Version_Parameters(
p_version_id NUMBER
, x_version_name OUT NOCOPY VARCHAR2
, x_version_no OUT NOCOPY VARCHAR2
, x_version_record_no OUT NOCOPY VARCHAR2
, x_budget_status_code OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_version_parameters: begining', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	SELECT version_number, version_name, record_version_number,budget_status_code
	INTO x_version_no, x_version_name, x_version_record_no , x_budget_status_code
	FROM pa_budget_versions
	WHERE budget_version_id = p_version_id;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_version_parameters: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_NO_PLAN_VERSION', p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING);
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Version_Parameters');
	RAISE;
END Derive_Version_Parameters;

PROCEDURE Derive_Fin_Plan_Versions(p_project_id NUMBER
,p_version_id NUMBER
, x_curr_budget_version_id OUT NOCOPY NUMBER
, x_orig_budget_version_id OUT NOCOPY NUMBER
, x_prior_fcst_version_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
)
IS
l_return_status VARCHAR2(1000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(1000);
BEGIN


	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_fin_plan_versions: begining', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	Pa_Planning_Element_Utils.get_finplan_bvids(
         p_project_id                 => p_project_id
	,p_budget_version_id          => p_version_id
        ,p_view_plan_flag             => 'Y'                   /* Bug#4221225 */
	, x_current_version_id        => x_curr_budget_version_id
	, x_original_version_id       => x_orig_budget_version_id
	, x_prior_fcst_version_id     => x_prior_fcst_version_id
	, x_return_status             => l_return_status
	, x_msg_count                 => l_msg_count
	, x_msg_data                  => l_msg_data);

	--Bug5510794 deriving the correct prior forecast version id
	x_prior_fcst_version_id := Pa_Planning_Element_Utils.get_prior_forecast_version_id(p_version_id, p_project_id);

	IF (l_msg_count > 0) THEN
	   x_msg_count := l_msg_count;
	   x_return_status := l_return_status;
	   x_msg_data := l_msg_data;
	END IF;


	IF x_curr_budget_version_id = -1 THEN
	   x_curr_budget_version_id := -99;
	END IF;

	IF x_orig_budget_version_id = -1 THEN
	   x_orig_budget_version_id := -99;
	END IF;

	IF x_prior_fcst_version_id = -1 THEN
	   x_prior_fcst_version_id := -99;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_fin_plan_versions: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Fin_Plan_Versions');
	RAISE;
END Derive_Fin_Plan_Versions;


PROCEDURE Derive_Work_Plan_Versions(p_project_id NUMBER
,p_structure_version_id NUMBER
, x_current_version_id OUT NOCOPY NUMBER
, x_baselined_version_id OUT NOCOPY NUMBER
, x_published_version_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
)
IS
l_return_status VARCHAR2(1000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(1000);
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_work_plan_versions: begining', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	Pa_Planning_Element_Utils.get_workplan_bvids
	(p_project_id
	, p_structure_version_id
	, x_current_version_id
	, x_baselined_version_id
	, x_published_version_id
	, x_return_status
	, x_msg_count
	, x_msg_data);

	IF (l_msg_count > 0) THEN
	   x_msg_count := l_msg_count;
	   x_return_status := l_return_status;
	   x_msg_data := l_msg_data;
	END IF;


	IF x_current_version_id = -1 THEN
	   x_current_version_id := -99;
	END IF;

	IF x_baselined_version_id = -1 THEN
	   x_baselined_version_id := -99;
	END IF;

	IF x_published_version_id = -1 THEN
	   x_published_version_id := -99;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_work_plan_versions: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Work_Plan_Versions');
	RAISE;
END Derive_Work_Plan_Versions;

/*
FUNCTION get_report_date_julian(p_calendar_type VARCHAR2
, p_calendar_id NUMBER
, p_org_id NUMBER) RETURN NUMBER
IS
l_return_status VARCHAR2(1000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
BEGIN

	Pa_Debug.init_err_stack('PJI_REP_UTIL.Get_Report_Date_Julian');
	IF g_debug_mode = 'Y' THEN
	   Pa_Debug.write_file('Get_Report_Date_Julian: begining',5);
--	   Pji_Utils.WRITE2LOG( 'derive_report_date_julian: begining', TRUE , g_proc);
	END IF;

--	IF (p_calendar_type <> g_input_calendar_type) OR (p_calendar_id <> g_input_calendar_id) THEN
		 Derive_Period_Julian(p_calendar_type
		 , p_calendar_id
		 , p_org_id
		 , l_return_status
		 , l_msg_count
		 , l_msg_data);
		 g_input_calendar_type := p_calendar_type;
		 g_input_calendar_id := p_calendar_id;
--	END IF;
	RETURN g_report_date_julian;

	IF g_debug_mode = 'Y' THEN
--	   Pji_Utils.WRITE2LOG( 'derive_report_date_julian: finishing', TRUE , g_proc);
  	   Pa_Debug.write_file('Get_Report_Date_Julian: returning',5);
	END IF;
	Pa_Debug.Reset_Err_Stack;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Get_Report_Date_Julian');
	RETURN 1;
END Get_Report_Date_Julian;


FUNCTION get_period_name(p_calendar_type VARCHAR2
, p_calendar_id NUMBER
, p_org_id NUMBER) RETURN VARCHAR2
IS
l_return_status VARCHAR2(1000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
BEGIN

	Pa_Debug.init_err_stack('PJI_REP_UTIL.Get_Period_Name');
	IF g_debug_mode = 'Y' THEN
	   Pa_Debug.write_file('Get_Period_Name: begining',5);
--	   Pji_Utils.WRITE2LOG( 'get_period_name: begining', TRUE , g_proc);
	END IF;

--	IF (p_calendar_type <> g_input_calendar_type) OR (p_calendar_id <> g_input_calendar_id) THEN
		 Derive_Period_Julian(p_calendar_type
		 , p_calendar_id
		 , p_org_id
		 , l_return_status
		 , l_msg_count
		 , l_msg_data);
		 g_input_calendar_type := p_calendar_type;
		 g_input_calendar_id := p_calendar_id;
--	END IF;

	IF g_debug_mode = 'Y' THEN
--	   Pji_Utils.WRITE2LOG( 'get_period_name: returning', TRUE , g_proc);
  	   Pa_Debug.write_file('Get_Period_Name: returning',5);
	END IF;
	Pa_Debug.Reset_Err_Stack;

	RETURN g_period_name;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Period_Name');
	RETURN NULL;
END Get_Period_Name;

*/
PROCEDURE Derive_Pa_Calendar_Info(p_project_id NUMBER
, p_calendar_type VARCHAR2
, x_calendar_id OUT NOCOPY NUMBER
, x_report_date_julian OUT NOCOPY NUMBER
, x_period_name OUT NOCOPY VARCHAR2
, x_slice_name OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
)
IS
l_curr_rep_gl_period VARCHAR2(30);
l_curr_rep_pa_period VARCHAR2(30);
l_curr_rep_ent_period VARCHAR2(30);
l_specific_pa_period VARCHAR2(30);
l_specific_gl_period VARCHAR2(30);
l_specific_ent_period VARCHAR2(30);
l_specific_period VARCHAR2(30);
l_active_rep VARCHAR2(30);
l_report_date DATE;
l_application_id NUMBER;
l_period_name VARCHAR2(100);
l_gl_calendar_id NUMBER;
l_pa_calendar_id NUMBER;
BEGIN
	Pa_Debug.init_err_stack('PJI_REP_UTIL.Derive_Period_Julian');
	IF g_debug_mode = 'Y' THEN
	   Pa_Debug.write_file('Derive_Period_Julian: begining',5);
--	   Pji_Utils.WRITE2LOG( 'derive_period_julian: begining', TRUE , g_proc);
	END IF;

	IF p_calendar_type = 'E' THEN
	   x_calendar_id := -1;
	ELSE
	   SELECT info.gl_calendar_id, info.pa_calendar_id
	   INTO l_gl_calendar_id, l_pa_calendar_id
	   FROM pji_org_extr_info info, pa_projects_all proj
	   WHERE info.org_id = proj.org_id
	   AND proj.project_id = p_project_id;

	   IF p_calendar_type = 'G' THEN
	      x_calendar_id := l_gl_calendar_id;
	   ELSE
	   	  x_calendar_id := l_pa_calendar_id;
	   END IF;
	END IF;

	Derive_Slice_Name(p_project_id,
	x_calendar_id,
	x_slice_name,
	x_return_status,
	x_msg_count,
	x_msg_data);


	SELECT curr_rep_gl_period, curr_rep_pa_period, curr_rep_ent_period
	INTO l_curr_rep_gl_period, l_curr_rep_pa_period, l_curr_rep_ent_period
	FROM pji_system_settings;

	IF p_calendar_type = 'G' THEN
	   l_active_rep := l_curr_rep_gl_period;
	   l_application_id := 101;
	ELSIF p_calendar_type = 'P' THEN
	   l_active_rep := l_curr_rep_pa_period;
	   l_application_id := 275;
	ELSE
	   l_active_rep := l_curr_rep_ent_period;
	END IF;

	IF l_active_rep IS NULL THEN
		x_msg_count := x_msg_count + 1;
		x_return_status := Fnd_Api.G_RET_STS_ERROR;
		Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_CUR_PERIOD_MISSING', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR);
		x_report_date_julian :=2;
		RETURN;
	END IF;

	IF l_active_rep = 'SPECIFIC' THEN
 	    BEGIN

			SELECT
				info.pa_curr_rep_period,
				info.gl_curr_rep_period,
				params.value
			INTO l_specific_pa_period, l_specific_gl_period, l_specific_ent_period
			FROM pji_org_extr_info info,
			     pji_system_parameters params,
				 pa_projects_all proj
			WHERE proj.project_id = p_project_id
			AND info.org_id = proj.org_id
			AND params.name  = 'PJI_PJP_ENT_CURR_REP_PERIOD';

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_msg_count := x_msg_count + 1;
			x_return_status := Fnd_Api.G_RET_STS_ERROR;
			Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_CUR_PERIOD_MISSING', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR);
			x_report_date_julian :=2;
			RETURN;
		END;

		IF p_calendar_type = 'G' THEN
		   l_specific_period := l_specific_gl_period;
		ELSIF p_calendar_type = 'P' THEN
		   l_specific_period := l_specific_pa_period;
		ELSE
		   l_specific_period := l_specific_ent_period;
		END IF;

		IF l_specific_period IS NULL THEN
			x_msg_count := x_msg_count + 1;
			x_return_status := Fnd_Api.G_RET_STS_ERROR;
			Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_CUR_PERIOD_MISSING', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR);
			x_report_date_julian :=2;
			RETURN;
		END IF;
	END IF;


	IF p_calendar_type = 'E' THEN
		IF l_active_rep IN ('CURRENT','PRIOR') THEN
		   SELECT start_date
		   INTO l_report_date
		   FROM pji_time_ent_period_v
		   WHERE TRUNC(SYSDATE) BETWEEN start_date AND end_date;
		END IF;

		IF l_active_rep = 'PRIOR' THEN
			  SELECT MAX(start_date)
			  INTO l_report_date
			  FROM pji_time_ent_period_v
			  WHERE end_date <l_report_date;
		END IF;

		IF l_active_rep = 'SPECIFIC' THEN
		    l_period_name := l_specific_period;

			SELECT start_date
			INTO l_report_date
			FROM pji_time_ent_period_v
			WHERE name = l_period_name;
		ELSE
			SELECT name
			INTO l_period_name
			FROM pji_time_ent_period_v
			WHERE l_report_date BETWEEN start_date AND end_date;
		END IF;
	ELSE
		IF l_active_rep ='FIRST_OPEN' THEN
			SELECT MIN(TIM.start_date) first_open
			INTO l_report_date
			FROM
			pji_time_cal_period_v TIM
			, gl_period_statuses glps
			, pa_implementations paimp
			WHERE 1=1
			AND TIM.calendar_id = x_calendar_id
			AND paimp.set_of_books_id = glps.set_of_books_id
			AND glps.application_id = l_application_id
			AND glps.period_name = TIM.NAME
			AND closing_status = 'O';
		ELSIF l_active_rep = 'LAST_OPEN' THEN
			SELECT MAX(TIM.start_date) last_open
			INTO l_report_date
			FROM
			pji_time_cal_period_v TIM
			, gl_period_statuses glps
			, pa_implementations paimp
			WHERE 1=1
			AND TIM.calendar_id = x_calendar_id
			AND paimp.set_of_books_id = glps.set_of_books_id
			AND glps.application_id = 275
			AND glps.period_name = TIM.NAME
			AND closing_status = 'O';
		ELSIF l_active_rep = 'LAST_CLOSED' THEN
			SELECT MAX(TIM.start_date) last_closed
			INTO  l_report_date
			FROM
			pji_time_cal_period_v TIM
			, gl_period_statuses glps
			, pa_implementations paimp
			WHERE 1=1
			AND TIM.calendar_id = x_calendar_id
			AND paimp.set_of_books_id = glps.set_of_books_id
			AND glps.application_id = l_application_id
			AND glps.period_name = TIM.NAME
			AND closing_status = 'C';
		ELSIF l_active_rep IN ('CURRENT','PRIOR') THEN
			SELECT start_date
			INTO l_report_date
			FROM pji_time_cal_period_v
			WHERE TRUNC(SYSDATE) BETWEEN start_date
			AND end_date
			AND calendar_id = x_calendar_id;
		END IF;

		IF l_active_rep = 'PRIOR' THEN
			SELECT MAX(start_date)
			INTO l_report_date
			FROM pji_time_cal_period_v
			WHERE end_date < l_report_date
			AND calendar_id = x_calendar_id;
		END IF;

		IF l_active_rep = 'SPECIFIC' THEN
		    l_period_name := l_specific_period;

			SELECT start_date
			INTO l_report_date
			FROM pji_time_cal_period_v
			WHERE name = l_period_name
			AND calendar_id = x_calendar_id;
		ELSE
			SELECT name
			INTO l_period_name
			FROM pji_time_cal_period_v
			WHERE l_report_date BETWEEN start_date AND end_date
			AND calendar_id = x_calendar_id;
		END IF;
	END IF;

	x_report_date_julian := TO_CHAR(l_report_date,'j');
	IF x_report_date_julian IS NULL THEN
	   x_report_date_julian :=2;
	END IF;
	x_period_name := l_period_name;



	IF g_debug_mode = 'Y' THEN
--	   Pji_Utils.WRITE2LOG( 'derive_period_julian: finishing', TRUE , g_proc);
  	   Pa_Debug.write_file('Derive_Period_Julian: returning',5);
	END IF;
	Pa_Debug.Reset_Err_Stack;


EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'CURRENT PERIOD');
	x_report_date_julian :=2;
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Period_Julian');
	RAISE;
END Derive_Pa_Calendar_Info;


FUNCTION get_work_plan_actual_version(p_project_id NUMBER
) RETURN NUMBER
IS
l_struct_sharing_code pa_projects_all.STRUCTURE_SHARING_CODE%TYPE;
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'get_work_plan_actual_version: begining', TRUE , g_proc);
	END IF;

    l_struct_sharing_code := Pa_Project_Structure_Utils.get_Structure_sharing_code(
        p_project_id=> p_project_id );
        -- SHARE_FULL
        -- SHARE_PARTIAL
        -- SPLIT_NO_MAPPING
        -- SPLILT_MAPPING

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'get_work_plan_actual_version: returning', TRUE , g_proc);
	END IF;

    IF (l_struct_sharing_code = 'SPLIT_NO_MAPPING' OR l_struct_sharing_code = 'SPLILT_MAPPING') THEN
    RETURN -2;
    ELSE
    RETURN -1;
    END IF;
EXCEPTION
	WHEN OTHERS THEN
	RETURN -1;
END get_work_plan_actual_version;

FUNCTION get_fin_plan_actual_version(p_project_id NUMBER
) RETURN NUMBER
IS
BEGIN
	RETURN -1;
END get_fin_plan_actual_version;

FUNCTION get_effort_uom(p_project_id NUMBER
) RETURN NUMBER
IS
BEGIN
    RETURN 1;
END get_effort_uom;

-- -----------------------------------------------------------------

-- -------------- --
-- User: aartola  --
-- -------------- --

-- -----------------------------------------------------------------
-- Setup Current Reporting Periods
-- -----------------------------------------------------------------

PROCEDURE update_curr_rep_periods(
	p_pa_curr_rep_period 	VARCHAR2,
	p_gl_curr_rep_period 	VARCHAR2,
	p_ent_curr_rep_period	VARCHAR2
) AS

-- ----------------------------------------------
-- declare statements --

l_org_id_count		NUMBER := 0;
l_ent_period_count	NUMBER := 0;

-- ----------------------------------------------

BEGIN
-- ----------------------------------------------
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'update_curr_rep_periods: begining', TRUE , g_proc);
	END IF;

-- check if pji_org_extr_info table has a record for p_org_id
-- Count funtion is introduced
SELECT 	COUNT(info.org_id)
INTO	l_org_id_count
FROM	pji_org_extr_info info
WHERE 	1=1
AND 	info.org_id = NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99);


IF	l_org_id_count = 0
THEN

	-- insert p_org_id, pa_curr_rep_period and gl_curr_rep_period (everything else is null)

	INSERT
	INTO	pji_org_extr_info
		(
		 org_id,
		 pa_curr_rep_period,
		 gl_curr_rep_period
		)
	VALUES
		(
		NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99),
		 p_pa_curr_rep_period,
		 p_gl_curr_rep_period
		);
ELSE

	-- update pa_curr_rep_period and gl_curr_rep_period

	UPDATE 	pji_org_extr_info
	SET	pa_curr_rep_period = p_pa_curr_rep_period,
	 	gl_curr_rep_period = p_gl_curr_rep_period
	WHERE	org_id = NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99);
END IF;

-- ----------------------------------------------
--Count funtion is introduced
SELECT 	COUNT(params.name)
INTO	l_ent_period_count
FROM	pji_system_parameters params
WHERE 	1=1
AND 	params.name = 'PJI_PJP_ENT_CURR_REP_PERIOD';

IF	l_ent_period_count = 0
THEN

	INSERT
	INTO	pji_system_parameters
		(
		 name,
		 value
		)
	VALUES
		(
		 'PJI_PJP_ENT_CURR_REP_PERIOD',
		 p_ent_curr_rep_period
		);
ELSE

	UPDATE 	pji_system_parameters
	SET 	value = p_ent_curr_rep_period
	WHERE 	name = 'PJI_PJP_ENT_CURR_REP_PERIOD';



END IF;


-- ----------------------------------------------

COMMIT;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'update_curr_rep_periods: finishing', TRUE , g_proc);
	END IF;


END update_curr_rep_periods;

-- -----------------------------------------------------------------


PROCEDURE get_project_home_default_param
                                  ( p_project_id        IN      NUMBER,
                                    p_page_Type         IN      VARCHAR2,
                                    x_fin_plan_type_id  IN OUT NOCOPY   NUMBER,
                                    x_cost_version_id   IN OUT NOCOPY   NUMBER,
                                    x_rev_version_id    IN OUT NOCOPY   NUMBER,
                                    x_struct_version_id IN OUT NOCOPY   NUMBER,
                                    x_return_status     IN OUT NOCOPY   VARCHAR2,
                                    x_msg_count         IN OUT NOCOPY   NUMBER,
                                    x_msg_data          IN OUT NOCOPY   VARCHAR2)
IS


l_cost_plan_type_id       NUMBER;
l_rev_plan_type_id        NUMBER;
l_cost_version_type       VARCHAR2(30);
l_rev_version_type        VARCHAR2(30);
l_fp_options_id           NUMBER;
l_cost_version_id         NUMBER;
l_rev_version_id          NUMBER;
l_plan_type_id            NUMBER;
l_struct_version_id    NUMBER;


BEGIN


	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'get_project_home_default_parameters: begining', TRUE , g_proc);
	END IF;

    x_msg_count := 0;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


    /* Get the Approved Budget - Cost and Revenue Plan Type */

     IF  (p_page_type = 'VB')  THEN


          Pa_Fin_Plan_Utils.Get_Appr_Cost_Plan_Type_Info(
                                            p_project_id    =>  p_project_id
                                           ,x_plan_type_id  =>  l_cost_plan_type_id
                                           ,x_return_status =>  x_return_status
                                           ,x_msg_count     =>  x_msg_count
                                           ,x_msg_data      =>  x_msg_data);


          Pa_Fin_Plan_Utils.Get_Appr_Rev_Plan_Type_Info(
                                            p_project_id     =>  p_project_id
                                           ,x_plan_type_id   =>  l_rev_plan_type_id
                                           ,x_return_status  =>  x_return_status
                                           ,x_msg_count      =>  x_msg_count
                                           ,x_msg_data       =>  x_msg_data);


           IF (l_cost_plan_type_id IS NULL) AND (l_rev_plan_type_id IS NULL) THEN

              x_msg_data := 'PJI_REP_VP_BDGT_PRJ_SH_NO_PT' ;
              RETURN;

           END IF;


           IF (l_cost_plan_type_id IS NOT NULL) THEN


               l_plan_type_id   := l_cost_plan_type_id;
               l_cost_version_type   :=Get_Version_Type(p_project_id,
                                                        l_cost_plan_type_id,
                                                        Pa_Fp_Constants_Pkg.G_VERSION_TYPE_COST);

                Pa_Fin_Plan_Utils.Get_Curr_Working_Version_Info(
                                           p_project_id           => p_project_id,
                                           p_fin_plan_type_id     => l_cost_plan_type_id,
                                           p_version_type         => l_cost_version_type,
                                           x_fp_options_id        => l_fp_options_id,
                                           x_fin_plan_version_id  => l_cost_version_id,
                                           x_return_status        => x_return_status,
                                           x_msg_count            => x_msg_count,
                                           x_msg_data             => x_msg_data);


                  IF (l_cost_version_id IS NULL) THEN

                      x_msg_data := 'PJI_REP_VP_BDGT_PRJ_SH_NO_PV' ;
                      RETURN;

                  END IF;


          END IF;


           IF (l_rev_plan_type_id IS NOT NULL) THEN

               l_plan_type_id  := l_rev_plan_type_id;

               l_rev_version_type   :=Get_Version_Type( p_project_id,
                                                        l_rev_plan_type_id,
                                                        Pa_Fp_Constants_Pkg.G_VERSION_TYPE_REVENUE);


                Pa_Fin_Plan_Utils.Get_Curr_Working_Version_Info(
                                           p_project_id           => p_project_id,
                                           p_fin_plan_type_id     => l_rev_plan_type_id,
                                           p_version_type         => l_rev_version_type,
                                           x_fp_options_id        => l_fp_options_id,
                                           x_fin_plan_version_id  => l_rev_version_id,
                                           x_return_status        => x_return_status,
                                           x_msg_count            => x_msg_count,
                                           x_msg_data             => x_msg_data);


                  IF (l_rev_version_id IS NULL) THEN

                      x_msg_data := 'PJI_REP_VP_BDGT_PRJ_SH_NO_PV' ;
                      RETURN;

                  END IF;


           END IF;



           IF (l_cost_plan_type_id IS NOT NULL) AND (l_rev_plan_type_id IS NOT NULL) THEN

              l_plan_type_id := l_cost_plan_type_id;

           END IF;
           x_fin_plan_type_id   := l_plan_type_id;
           x_cost_version_id    := l_cost_version_id;
           x_rev_version_id     := l_rev_version_id;


        END IF;




    /* Get the Primary Forecast - Cost and Revenue Plan Type */

    IF  (p_page_type = 'VF')  THEN



              Pa_Fin_Plan_Utils.Is_Pri_Fcst_Cost_PT_Attached(
                                      p_project_id      =>  p_project_id
                                     ,x_plan_type_id    =>  l_cost_plan_type_id
                                     ,x_return_status   =>  x_return_status
                                     ,x_msg_count       =>  x_msg_count
                                     ,x_msg_data        =>  x_msg_data);

               Pa_Fin_Plan_Utils.Is_Pri_Fcst_Rev_PT_Attached(
                                      p_project_id      =>  p_project_id
                                     ,x_plan_type_id    =>  l_rev_plan_type_id
                                     ,x_return_status   =>  x_return_status
                                     ,x_msg_count       =>  x_msg_count
                                     ,x_msg_data        =>  x_msg_data);


           IF (l_cost_plan_type_id IS NULL) AND (l_rev_plan_type_id IS NULL) THEN
             x_msg_data := 'PJI_REP_VP_FCST_PRJ_SH_NO_PT' ;
              RETURN;

           END IF;

           IF (l_cost_plan_type_id IS NOT NULL) THEN


               l_plan_type_id   := l_cost_plan_type_id;

               l_cost_version_type   :=Get_Version_Type(p_project_id,
                                                        l_cost_plan_type_id,
                                                        Pa_Fp_Constants_Pkg.G_VERSION_TYPE_COST);


                Pa_Fin_Plan_Utils.Get_Curr_Working_Version_Info(
                                           p_project_id           => p_project_id,
                                           p_fin_plan_type_id     => l_cost_plan_type_id,
                                           p_version_type         => l_cost_version_type,
                                           x_fp_options_id        => l_fp_options_id,
                                           x_fin_plan_version_id  => l_cost_version_id,
                                           x_return_status        => x_return_status,
                                           x_msg_count            => x_msg_count,
                                           x_msg_data             => x_msg_data);


                  IF (l_cost_version_id IS NULL) THEN

                      x_msg_data := 'PJI_REP_VP_FCST_PRJ_SH_NO_PV' ;
                      RETURN;

                  END IF;

          END IF;


           IF (l_rev_plan_type_id IS NOT NULL) THEN

               l_plan_type_id  := l_rev_plan_type_id;

               l_rev_version_type   :=Get_Version_Type( p_project_id,
                                                        l_rev_plan_type_id,
                                                        Pa_Fp_Constants_Pkg.G_VERSION_TYPE_REVENUE);


                Pa_Fin_Plan_Utils.Get_Curr_Working_Version_Info(
                                           p_project_id           => p_project_id,
                                           p_fin_plan_type_id     => l_rev_plan_type_id,
                                           p_version_type         => l_rev_version_type,
                                           x_fp_options_id        => l_fp_options_id,
                                           x_fin_plan_version_id  => l_rev_version_id,
                                           x_return_status        => x_return_status,
                                           x_msg_count            => x_msg_count,
                                           x_msg_data             => x_msg_data);


                  IF (l_rev_version_id IS NULL) THEN

                      x_msg_data := 'PJI_REP_VP_FCST_PRJ_SH_NO_PV' ;
                      RETURN;

                  END IF;


           END IF;

           IF (l_cost_plan_type_id IS NOT NULL) AND (l_rev_plan_type_id IS NOT NULL) THEN

              l_plan_type_id := l_cost_plan_type_id;

           END IF;

                x_fin_plan_type_id   := l_plan_type_id;
                x_cost_version_id    := l_cost_version_id;
                x_rev_version_id     := l_rev_version_id;


    END IF;



    /* Get the Structure version for the work plan */

    IF  (p_page_type = 'WP')  THEN


        /* Get the latest wp published version */

         l_struct_version_id :=   Pa_Project_Structure_Utils.GET_LATEST_WP_VERSION(p_project_id);


        /* If latest published version is null then get it from currenct working version */


        IF l_struct_version_id IS NULL THEN

          l_struct_version_id :=  Pa_Project_Structure_Utils.get_current_working_ver_id(p_project_id);

        END IF;

          x_struct_version_id := l_struct_version_id;

    END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'get_project_home_default_parameters: finishing', TRUE , g_proc);
	END IF;


EXCEPTION
    WHEN OTHERS THEN
       x_msg_count := 1;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.get_project_home_default_param');
        RAISE;

END get_project_home_default_param;

PROCEDURE Derive_WP_Period(
p_project_id NUMBER
, p_published_version_id NUMBER
, p_working_version_id NUMBER
, x_from_period OUT NOCOPY  NUMBER
, x_to_period OUT NOCOPY  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
CURSOR c_dates IS
		SELECT TO_CHAR(sch.scheduled_start_date,'j'),TO_CHAR(sch.scheduled_finish_date,'j')
		FROM
		pji_pjp_wbs_header hdr
		, pa_proj_elem_ver_schedule sch
		WHERE
		hdr.project_id = p_project_id
		AND hdr.plan_version_id IN ( p_published_version_id,p_working_version_id)
		AND sch.element_version_id = hdr.wbs_version_id
		ORDER BY DECODE(hdr.plan_version_id, p_published_version_id, 0,1);

BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_WP_Period: begining', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	OPEN c_dates;
		FETCH c_dates INTO x_from_period,x_to_period;


		IF c_dates%NOTFOUND THEN
		   RAISE NO_DATA_FOUND;
		END IF;

	CLOSE c_dates;--bug#3877822

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_WP_Period: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_from_period := NULL;
	x_to_period := NULL;
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_WP_Period');
	RAISE;
END Derive_WP_Period;

PROCEDURE Derive_VP_Period(
p_project_id NUMBER
, p_plan_version_id_tbl  SYSTEM.pa_num_tbl_type
, x_from_period OUT NOCOPY  NUMBER
, x_to_period OUT NOCOPY  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_VP_Period: begining', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	Get_Default_Period_Dates (
	    p_plan_version_id_tbl
	  , p_project_id
	  , x_from_period
	  , x_to_period
	 );


	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_VP_Period: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_from_period := NULL;
	x_to_period := NULL;
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_VP_Period');
	RAISE;
END Derive_VP_Period;

PROCEDURE Derive_Perf_Period(
p_project_id NUMBER
, p_plan_version_id_tbl  SYSTEM.pa_num_tbl_type
, x_from_period OUT NOCOPY  NUMBER
, x_to_period OUT NOCOPY  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_Perf_Period: begining', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	Get_Default_Period_Dates (
	    p_plan_version_id_tbl
	  , p_project_id
	  , x_from_period
	  , x_to_period
	 );

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_Perf_Period: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_from_period := NULL;
	x_to_period := NULL;
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Perf_Period');
	RAISE;
END Derive_Perf_Period;

FUNCTION Get_Slice_Name(
p_project_id NUMBER
,p_calendar_id NUMBER) RETURN VARCHAR2
IS
l_slice_name VARCHAR2(50);
l_return_status VARCHAR2(1000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
BEGIN

	Pa_Debug.init_err_stack('PJI_REP_UTIL.Get_Slice_Name');
	IF g_debug_mode = 'Y' THEN
	   Pa_Debug.write_file('Get_Slice_Name: begining',5);
--	   Pji_Utils.WRITE2LOG( 'Get_Slice_Name: begining', TRUE , g_proc);
	END IF;

	Derive_Slice_Name(p_project_id,
	p_calendar_id,
	l_slice_name,
	l_return_status,
	l_msg_count,
	l_msg_data);


	IF g_debug_mode = 'Y' THEN
--	   Pji_Utils.WRITE2LOG( 'Get_Slice_Name: returning', TRUE , g_proc);
  	   Pa_Debug.write_file('Get_Slice_Name: returning',5);
	END IF;
	Pa_Debug.Reset_Err_Stack;

	RETURN l_slice_name;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Period_Name');
	RETURN NULL;
END Get_Slice_Name;
/*
 * Aded procedure for bug 3842347
 */

/* Modified code for bug 4175400*/
PROCEDURE Get_Default_Period_Dates (
    p_plan_version_ids          IN  SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type()
  , p_project_id                IN  NUMBER
  , x_min_julian_date           OUT NOCOPY  NUMBER
  , x_max_julian_date           OUT NOCOPY  NUMBER
 )
IS
  l_min_date                    DATE   := NULL;
  l_max_date                    DATE   := NULL;
  l_cur_min_date                DATE   := NULL;
  l_cur_max_date                DATE   := NULL;
  l_plan_version_id             NUMBER := NULL;
  l_plan_version_ids            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  j                             NUMBER := 0;
BEGIN
    IF g_debug_mode = 'Y' THEN
       Pji_Utils.WRITE2LOG( 'Get_Default_Period_Dates: begining', TRUE , g_proc);
    END IF;

   -- Checking if project id is null or p_plan_version_ids's table is null then exiting smoothly
   IF ( p_project_id IS NULL OR p_plan_version_ids.COUNT <= 0 ) THEN
     IF g_debug_mode = 'Y' THEN
        Pji_Utils.WRITE2LOG( 'Exiting from Get_Default_Period_Dates: no Project or Plan version id found', TRUE , g_proc);
     END IF;

     RETURN;
   END IF;

   l_plan_version_ids.extend(17);

   FOR i IN p_plan_version_ids.FIRST..p_plan_version_ids.LAST LOOP
      l_plan_version_id  := NULL;

      IF    ( p_plan_version_ids.EXISTS(i)) THEN
         j := j + 1;
         l_plan_version_ids(j)  := p_plan_version_ids(i);

         IF g_debug_mode = 'Y' THEN
            Pji_Utils.WRITE2LOG( 'Get_Default_Period_Dates: inside pa_resource_assignments table', TRUE , g_proc);
         END IF;
      END IF;
   END LOOP;

   FOR i IN 1..17 LOOP
      IF    ( l_plan_version_ids.EXISTS(i)) THEN
              NULL;
      ELSE
        l_plan_version_ids(i) := 0;
      END IF;
   END LOOP;


   IF ( l_plan_version_ids.COUNT > 0 ) THEN
      BEGIN
          SELECT MAX(max_txn_date), MIN(min_txn_date)
                 INTO l_max_date, l_min_date
                 FROM pji_pjp_wbs_header
                 WHERE project_id = p_project_id
                 AND   plan_version_id IN (l_plan_version_ids(1),l_plan_version_ids(2),l_plan_version_ids(3),l_plan_version_ids(4),
                                           l_plan_version_ids(5),l_plan_version_ids(6),l_plan_version_ids(7),l_plan_version_ids(8),
                                           l_plan_version_ids(9),l_plan_version_ids(10),l_plan_version_ids(11),l_plan_version_ids(12),
                                           l_plan_version_ids(13),l_plan_version_ids(14),l_plan_version_ids(15),l_plan_version_ids(16),l_plan_version_ids(17) );

                 IF g_debug_mode = 'Y' THEN
                    Pji_Utils.WRITE2LOG( 'Get_Default_Period_Dates: Done selecting pa_resource_assignments table', TRUE , g_proc);
                 END IF;
      EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_min_date := NULL;
              l_max_date := NULL;
              IF g_debug_mode = 'Y' THEN
                 Pji_Utils.WRITE2LOG( 'Get_Default_Period_Dates: No data found in pa_resource_assignments table', TRUE , g_proc);
              END IF;
      END;
    END IF;

   x_min_julian_date    := TO_CHAR(l_min_date,'j');
   x_max_julian_date    := TO_CHAR(l_max_date,'j');

   IF g_debug_mode = 'Y' THEN
     Pji_Utils.WRITE2LOG( 'Get_Default_Period_Dates: Leaving ', TRUE , g_proc);
   END IF;

EXCEPTION
	WHEN OTHERS THEN
        x_min_julian_date := NULL;
        x_max_julian_date := NULL;
        IF g_debug_mode = 'Y' THEN
          Pji_Utils.WRITE2LOG( 'Get_Default_Period_Dates: When others ', TRUE , g_proc);
        END IF;
	NULL;

END Get_Default_Period_Dates;


PROCEDURE Derive_Project_Type(p_project_id NUMBER
, x_project_type OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
)
IS
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_Project_Type: begining', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

    SELECT DISTINCT UPPER(t.project_type_class_code)
    INTO x_project_type
    FROM pa_projects_all   p
    , pa_project_types_all t
    WHERE 1=1
    AND p.project_id = p_project_Id
    AND p.project_type = t.project_type
    /*AND NVL(p.org_id,-99) = NVL(t.org_id,-99); -- Added NVL for bug 3989132*/
    AND p.org_id = t.org_id ; -- Removed NVL for Bug 5376591


	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_Project_Type: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_project_type := 'CONTRACT';
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Project_Type');
	RAISE;
END Derive_Project_Type;

PROCEDURE Derive_Percent_Complete
( p_project_id NUMBER
, p_wbs_version_id NUMBER
, p_wbs_element_id NUMBER
, p_rollup_flag VARCHAR2
, p_report_date_julian NUMBER
, p_structure_type VARCHAR2
, p_calendar_type VARCHAR2 DEFAULT 'E'
, p_calendar_id NUMBER DEFAULT -1
, p_prg_flag VARCHAR2
, x_percent_complete  OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
)
IS
l_object_type VARCHAR2(30);
l_report_date DATE := NULL;
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_Percent_Complete: begining', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	BEGIN
		SELECT object_type
		INTO l_object_type
		FROM pa_proj_elements
		WHERE proj_element_id = p_wbs_element_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			 l_object_type := 'PA_STRUCTURES';
	END;

	IF p_calendar_type = 'E' THEN
		SELECT end_date
		INTO l_report_date
		FROM pji_time_ent_period
		WHERE TO_DATE(p_report_date_julian,'j') BETWEEN start_date AND end_date;
	ELSIF p_calendar_type = 'G' OR p_calendar_type = 'P' THEN
		SELECT end_date
		INTO l_report_date
		FROM pji_time_cal_period
		WHERE TO_DATE(p_report_date_julian,'j') BETWEEN start_date AND end_date
		AND calendar_id=p_calendar_id;
	END IF;

	IF p_structure_type = 'FINANCIAL' AND p_prg_flag = 'Y' THEN
	   x_percent_complete := NULL;
	ELSE
	   x_percent_complete := Pa_Progress_Utils.get_pc_from_sub_tasks_assgn(p_project_id =>p_project_id
												  ,p_proj_element_id => p_wbs_element_id
												  ,p_structure_version_id => p_wbs_version_id
												  ,p_include_sub_tasks_flag => p_rollup_flag
												  ,p_structure_type => p_structure_type
												  ,p_object_type => l_object_type
												  ,p_as_of_date =>l_report_date
												  ,p_program_flag => p_prg_flag);
	END IF;
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_Complete_Percent: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_percent_complete := NULL;
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Complete_Percentage');
	RAISE;
END Derive_Percent_Complete;


PROCEDURE Check_Cross_Org
( p_project_id NUMBER
, x_cross_org_flag OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
)
IS
l_env_org NUMBER(15);
l_project_org NUMBER(15);
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Check_Cross_Org: begining', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	SELECT
    NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99)
	INTO l_env_org
	FROM dual;

	SELECT org_id
	INTO l_project_org
	FROM pa_projects_all
	WHERE project_id = p_project_id;

	IF l_env_org = l_project_org THEN
	   x_cross_org_flag := 'F';
	ELSE
	   x_cross_org_flag := 'T';
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Check_Cross_Org: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 x_cross_org_flag := 'F';
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Check_Cross_Org');
	RAISE;
END Check_Cross_Org;

/*
	This is a wrapper API which does the consistency check
	for program in workplan context.
*/
PROCEDURE CHECK_WP_PARAM_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,p_margin_code		IN  pa_proj_fp_options.margin_derived_from_code%TYPE
   ,p_published_flag	IN  VARCHAR2
   ,p_calendar_type		IN  pji_fp_xbs_accum_f.calendar_type%TYPE
   ,p_calendar_id		IN  pa_projects_all.calendar_id%TYPE
   ,p_rbs_version_id	IN  pa_proj_fp_options.rbs_version_id%TYPE
   ,x_pc_flag			OUT NOCOPY VARCHAR2
   ,x_pfc_flag			OUT NOCOPY VARCHAR2
   ,x_margin_flag		OUT NOCOPY VARCHAR2
   ,x_workpub_flag	    OUT NOCOPY VARCHAR2
   ,x_time_phase_flag	OUT NOCOPY VARCHAR2
   ,x_rbs_flag			OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2)
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);

l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_module_name                   VARCHAR2(100) := 'pa.plsql.CHECK_WP_PARAM_CONSISTENCY';

BEGIN
    x_msg_count := 0;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.set_curr_function( p_function   => 'CHECK_WP_PARAM_CONSISTENCY',
                                     p_debug_mode => l_debug_mode );
    END IF;

	--Call the currency check API
	Pji_Rep_Util.CHECK_WP_CURRENCY_CONSISTENCY
	  ( p_project_id		=> p_project_id
	   ,p_wbs_version_id	=> p_wbs_version_id
	   ,x_pc_flag			=> x_pc_flag
	   ,x_pfc_flag			=> x_pfc_flag
	   ,x_return_status		=> x_return_status
	   ,x_msg_count			=> x_msg_count
	   ,x_msg_data			=> x_msg_data );

	IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;

	--Call the margin check API
	Pji_Rep_Util.CHECK_WP_MARGIN_CONSISTENCY
	  ( p_project_id		=> p_project_id
	   ,p_wbs_version_id	=> p_wbs_version_id
	   ,p_margin_code		=> p_margin_code
	   ,x_margin_flag		=> x_margin_flag
	   ,x_return_status		=> x_return_status
	   ,x_msg_count			=> x_msg_count
	   ,x_msg_data			=> x_msg_data );

	IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;

	--Call the status check API
	   Pji_Rep_Util.CHECK_WP_STATUS_CONSISTENCY
	  ( p_project_id		=> p_project_id
	   ,p_wbs_version_id	=> p_wbs_version_id
	   ,p_published_flag	=> p_published_flag
	   ,x_workpub_flag		=> x_workpub_flag
	   ,x_return_status		=> x_return_status
	   ,x_msg_count			=> x_msg_count
	   ,x_msg_data			=> x_msg_data );

	IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;

	--Call the time phase check API only if the published flag is Y
	IF p_published_flag = 'Y' THEN
		Pji_Rep_Util.CHECK_WP_TIME_CONSISTENCY
		  ( p_project_id		=> p_project_id
		   ,p_wbs_version_id	=> p_wbs_version_id
		   ,p_calendar_type		=> p_calendar_type
		   ,p_calendar_id		=> p_calendar_id
		   ,x_time_phase_flag	=> x_time_phase_flag
		   ,x_return_status		=> x_return_status
		   ,x_msg_count			=> x_msg_count
		   ,x_msg_data			=> x_msg_data );

		IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
			RETURN;
		END IF;
	END IF;

	--Call the RBS check API
	   Pji_Rep_Util.CHECK_WP_RBS_CONSISTENCY
	  ( p_project_id		=> p_project_id
	   ,p_wbs_version_id	=> p_wbs_version_id
	   ,p_rbs_version_id	=> p_rbs_version_id
	   ,x_rbs_flag			=> x_rbs_flag
	   ,x_return_status		=> x_return_status
	   ,x_msg_count			=> x_msg_count
	   ,x_msg_data			=> x_msg_data );

	IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.g_err_stage:= 'Exiting CHECK_WP_PARAM_CONSISTENCY';
         Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         Pa_Debug.reset_curr_function;
    END IF;
EXCEPTION
WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PJI_REP_UTIL'
                    ,p_procedure_name  => 'CHECK_WP_PARAM_CONSISTENCY'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END CHECK_WP_PARAM_CONSISTENCY;

/*
	check if all the projects in the program hierarchy contain
	the same project and project functional currency.
*/
PROCEDURE CHECK_WP_CURRENCY_CONSISTENCY
( p_project_id		IN	pa_projects_all.project_id%TYPE
 ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
 ,x_pc_flag			OUT NOCOPY VARCHAR2
 ,x_pfc_flag			OUT NOCOPY VARCHAR2
 ,x_return_status		OUT NOCOPY VARCHAR2
 ,x_msg_count			OUT NOCOPY NUMBER
 ,x_msg_data			OUT NOCOPY VARCHAR2)
AS

CURSOR get_proj_currency_details(c_project_id pa_projects_all.project_id%TYPE)
IS
SELECT project_currency_code,projfunc_currency_code
FROM pa_projects_all
WHERE project_id = c_project_id;

CURSOR check_project_currency(c_project_id pa_projects_all.project_id%TYPE,
							  c_wbs_version_id  pji_xbs_denorm.sup_project_id%TYPE,
							  c_currency_code pa_projects_all.project_currency_code%TYPE)
IS
SELECT 1
FROM pji_xbs_denorm denorm,
     pa_proj_elements ele,
     pa_projects_all proj
WHERE denorm.sup_project_id = c_project_id
AND   denorm.sup_id = c_wbs_version_id
AND   denorm.struct_type = 'PRG'
AND   denorm.struct_version_id IS NULL
AND   denorm.sub_emt_id = ele.proj_element_id
AND   ele.project_id = proj.project_id
AND   proj.project_currency_code <> c_currency_code;

CURSOR check_projfunc_currency(c_project_id pa_projects_all.project_id%TYPE,
					 		   c_wbs_version_id  pji_xbs_denorm.sup_project_id%TYPE,
							   c_currency_code pa_projects_all.project_currency_code%TYPE)
IS
SELECT 1
FROM pji_xbs_denorm denorm,
     pa_proj_elements ele,
     pa_projects_all proj
WHERE denorm.sup_project_id = c_project_id
AND   denorm.sup_id = c_wbs_version_id
AND   denorm.struct_type = 'PRG'
AND   denorm.struct_version_id IS NULL
AND   denorm.sub_emt_id = ele.proj_element_id
AND   ele.project_id = proj.project_id
AND   proj.projfunc_currency_code <> c_currency_code;

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);


l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_module_name                   VARCHAR2(100) := 'pa.plsql.CHECK_WP_CURRENCY_CONSISTENCY';

l_project_currency_code		pa_projects_all.project_currency_code%TYPE;
l_projfunc_currency_code	pa_projects_all.projfunc_currency_code%TYPE;
l_dummy						NUMBER;

BEGIN
    x_msg_count := 0;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.set_curr_function( p_function   => 'CHECK_WP_CURRENCY_CONSISTENCY',
                                     p_debug_mode => l_debug_mode );
    END IF;

	--These flags will denote the respective consistency. A value of Y for x_pc_flag
	--indicates that all the projects in the program have the same PC/PFC. A value of N indicates
	--inconsistency.
	x_pc_flag			:= 'Y';
	x_pfc_flag			:= 'Y';

	--Obtain the project and the projfunc currency codes
	OPEN get_proj_currency_details(p_project_id);
	FETCH get_proj_currency_details INTO l_project_currency_code,l_projfunc_currency_code;
	CLOSE get_proj_currency_details;

	OPEN check_project_currency(p_project_id,p_wbs_version_id,l_project_currency_code);
	FETCH check_project_currency INTO l_dummy;
	IF check_project_currency%FOUND THEN
		x_pc_flag := 'N';
	END IF;
	CLOSE check_project_currency;

	OPEN check_projfunc_currency(p_project_id,p_wbs_version_id,l_projfunc_currency_code);
	FETCH check_projfunc_currency INTO l_dummy;
	IF check_projfunc_currency%FOUND THEN
		x_pfc_flag := 'N';
	END IF;
	CLOSE check_projfunc_currency;

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.g_err_stage:= 'Exiting CHECK_WP_CURRENCY_CONSISTENCY';
         Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         Pa_Debug.reset_curr_function;
    END IF;
EXCEPTION

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PJI_REP_UTIL'
                    ,p_procedure_name  => 'CHECK_WP_CURRENCY_CONSISTENCY'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END CHECK_WP_CURRENCY_CONSISTENCY;

/*
	check if all the linked structure versions in the
	program hierarchy have the same margin mask.
*/
PROCEDURE CHECK_WP_MARGIN_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,p_margin_code		IN  pa_proj_fp_options.margin_derived_from_code%TYPE
   ,x_margin_flag		OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2)
AS

CURSOR check_margin_mask(c_project_id pa_projects_all.project_id%TYPE,
  			 		     c_wbs_version_id  pji_xbs_denorm.sup_project_id%TYPE,
						 c_margin_code pa_proj_fp_options.margin_derived_from_code%TYPE)
IS
SELECT 1
FROM pji_xbs_denorm denorm,
     pji_pjp_wbs_header header,
     pa_proj_fp_options opt
WHERE denorm.sup_project_id = c_project_id
AND   denorm.sup_id = c_wbs_version_id
AND   denorm.struct_type = 'PRG'
AND   denorm.struct_version_id IS NULL
AND   denorm.sub_id = header.wbs_version_id
AND   header.wp_flag = 'Y'
AND   header.plan_version_id = opt.fin_plan_version_id
AND   opt.fin_plan_option_level_code = 'PLAN_VERSION'
AND   opt.margin_derived_from_code <> c_margin_code;

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);


l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_module_name                   VARCHAR2(100) := 'pa.plsql.CHECK_WP_MARGIN_CONSISTENCY';

l_dummy						NUMBER;

BEGIN
    x_msg_count := 0;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.set_curr_function( p_function   => 'CHECK_WP_MARGIN_CONSISTENCY',
                                     p_debug_mode => l_debug_mode );
    END IF;

	--These flags will denote the respective consistency. A value of Y for x_currency_flag
	--indicates that all the projects in the program have the same PC/PFC. A value of N indicates
	--inconsistency.
	x_margin_flag		:= 'Y';

	OPEN check_margin_mask(p_project_id,p_wbs_version_id,p_margin_code);
	FETCH check_margin_mask INTO l_dummy;
	IF check_margin_mask%FOUND THEN
		x_margin_flag := 'N';
	END IF;
	CLOSE check_margin_mask;

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.g_err_stage:= 'Exiting CHECK_WP_MARGIN_CONSISTENCY';
         Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         Pa_Debug.reset_curr_function;
    END IF;
EXCEPTION

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PJI_REP_UTIL'
                    ,p_procedure_name  => 'CHECK_WP_MARGIN_CONSISTENCY'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END CHECK_WP_MARGIN_CONSISTENCY;


/*
	check if all the structure versions in the program hierarchy
	have the same status. ie published/not published.
*/

PROCEDURE CHECK_WP_STATUS_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,p_published_flag	IN  VARCHAR2
   ,x_workpub_flag	    OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2)
AS

CURSOR check_published_flag(c_project_id pa_projects_all.project_id%TYPE,
  			 		        c_wbs_version_id  pji_xbs_denorm.sup_project_id%TYPE,
							c_published_flag VARCHAR2)
IS
SELECT 1
FROM pji_xbs_denorm denorm,
     pa_proj_elements ele
WHERE denorm.sup_project_id = c_project_id
AND   denorm.sup_id = c_wbs_version_id
AND   denorm.struct_type = 'PRG'
AND   denorm.struct_version_id IS NULL
AND   denorm.sub_emt_id = ele.proj_element_id
AND   Pa_Project_Structure_Utils.Check_Struc_Ver_Published(ele.project_id,denorm.sub_id) <> c_published_flag;

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);


l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_module_name                   VARCHAR2(100) := 'pa.plsql.CHECK_WP_STATUS_CONSISTENCY';

l_dummy						NUMBER;

BEGIN
    x_msg_count := 0;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.set_curr_function( p_function   => 'CHECK_WP_STATUS_CONSISTENCY',
                                     p_debug_mode => l_debug_mode );
    END IF;

	--These flags will denote the respective consistency. A value of Y for x_currency_flag
	--indicates that all the projects in the program have the same PC/PFC. A value of N indicates
	--inconsistency.
	x_workpub_flag   	:= 'Y';

	--The flag x_workpub_flag just denotes an inconsistency in the pgm structure.
	OPEN check_published_flag(p_project_id,p_wbs_version_id,p_published_flag);
	FETCH check_published_flag INTO l_dummy;
	IF check_published_flag%FOUND THEN
		x_workpub_flag := 'N';
	END IF;
	CLOSE check_published_flag;

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.g_err_stage:= 'Exiting CHECK_WP_PARAM_CONSISTENCY';
         Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         Pa_Debug.reset_curr_function;
    END IF;
EXCEPTION

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PJI_REP_UTIL'
                    ,p_procedure_name  => 'CHECK_WP_STATUS_CONSISTENCY'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END CHECK_WP_STATUS_CONSISTENCY;


/*
	check if all the structure versions in the program hierarchy have
	same time phasing.
*/
PROCEDURE CHECK_WP_TIME_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,p_calendar_type		IN  pji_fp_xbs_accum_f.calendar_type%TYPE
   ,p_calendar_id		IN  pa_projects_all.calendar_id%TYPE
   ,x_time_phase_flag	OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2)
AS


CURSOR get_pgm_ver_details(c_project_id pa_projects_all.project_id%TYPE,
  			 		       c_wbs_version_id  pji_xbs_denorm.sup_project_id%TYPE)
IS
SELECT header.project_id, header.plan_version_id
FROM pji_xbs_denorm denorm,
	 pji_pjp_wbs_header header
WHERE denorm.sup_project_id = c_project_id
AND   denorm.sup_id = c_wbs_version_id
AND   denorm.struct_type = 'PRG'
AND   denorm.struct_version_id IS NULL
AND   header.wbs_version_id = denorm.sub_id
AND   header.wp_flag = 'Y';


l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);


l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_module_name                   VARCHAR2(100) := 'pa.plsql.CHECK_WP_TIME_CONSISTENCY';

l_calendar_id				pa_projects_all.calendar_id%TYPE;
l_calendar_type				pji_fp_xbs_accum_f.calendar_type%TYPE;

BEGIN
    x_msg_count := 0;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.set_curr_function( p_function   => 'CHECK_WP_TIME_CONSISTENCY',
                                     p_debug_mode => l_debug_mode );
    END IF;

	--These flags will denote the respective consistency. A value of Y for x_currency_flag
	--indicates that all the projects in the program have the same PC/PFC. A value of N indicates
	--inconsistency.
	x_time_phase_flag	:= 'Y';

	FOR rec IN get_pgm_ver_details(p_project_id,p_wbs_version_id) LOOP
		Pji_Rep_Util.Derive_WP_Calendar_Info(
			 p_project_id		=>	rec.project_id
			,p_plan_version_id	=>	rec.plan_version_id
			,x_calendar_id		=>	l_calendar_id
			,x_calendar_type	=>	l_calendar_type
			,x_return_status	=>	x_return_status
			,x_msg_count		=>	x_msg_count
			,x_msg_data			=>	x_msg_data);

			IF x_return_status = Fnd_Api.G_RET_STS_SUCCESS THEN
				IF NVL(l_calendar_id,-99) <> NVL(p_calendar_id,-99) AND l_calendar_type <> p_calendar_type THEN
					x_time_phase_flag := 'N';
					EXIT;
				END IF;
			ELSE
				EXIT; -- you have returned with error.
			END IF;
	END LOOP;

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.g_err_stage:= 'Exiting CHECK_WP_TIME_CONSISTENCY';
         Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         Pa_Debug.reset_curr_function;
    END IF;
EXCEPTION

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PJI_REP_UTIL'
                    ,p_procedure_name  => 'CHECK_WP_PARAM_CONSISTENCY'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END CHECK_WP_TIME_CONSISTENCY;

/*
	check if all the structure versions  in the program hierarchy have
	the same RBS.
*/
PROCEDURE CHECK_WP_RBS_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,p_rbs_version_id	IN  pa_proj_fp_options.rbs_version_id%TYPE
   ,x_rbs_flag			OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2)
AS

CURSOR check_rbs_flag(c_project_id pa_projects_all.project_id%TYPE,
  			 		  c_wbs_version_id  pji_xbs_denorm.sup_project_id%TYPE,
					  c_rbs_version_id  pa_proj_fp_options.rbs_version_id%TYPE)
IS
SELECT 1
FROM pji_xbs_denorm denorm,
     pji_pjp_wbs_header header,
     pa_proj_fp_options opt
WHERE denorm.sup_project_id = c_project_id
AND   denorm.sup_id = c_wbs_version_id
AND   denorm.struct_type = 'PRG'
AND   denorm.struct_version_id IS NULL
AND   denorm.sub_id = header.wbs_version_id
AND   header.wp_flag = 'Y'
AND   header.plan_version_id = opt.fin_plan_version_id
AND   opt.fin_plan_option_level_code = 'PLAN_VERSION'
AND   NVL(opt.rbs_version_id, -50) <> c_rbs_version_id; --Bug 4506849


l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);


l_debug_level2                  CONSTANT NUMBER := 2;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level4                  CONSTANT NUMBER := 4;
l_debug_level5                  CONSTANT NUMBER := 5;

l_module_name                   VARCHAR2(100) := 'pa.plsql.CHECK_WP_RBS_CONSISTENCY';

l_dummy						NUMBER;

BEGIN
    x_msg_count := 0;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.set_curr_function( p_function   => 'CHECK_WP_RBS_CONSISTENCY',
                                     p_debug_mode => l_debug_mode );
    END IF;

	--These flags will denote the respective consistency. A value of Y for x_currency_flag
	--indicates that all the projects in the program have the same PC/PFC. A value of N indicates
	--inconsistency.
	x_rbs_flag			:= 'Y';

	OPEN check_rbs_flag(p_project_id,p_wbs_version_id,p_rbs_version_id);
	FETCH check_rbs_flag INTO l_dummy;
	IF check_rbs_flag%FOUND THEN
		x_rbs_flag := 'N';
	END IF;
	CLOSE check_rbs_flag;

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.g_err_stage:= 'Exiting CHECK_WP_RBS_CONSISTENCY';
         Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level3);
         Pa_Debug.reset_curr_function;
    END IF;
EXCEPTION

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PJI_REP_UTIL'
                    ,p_procedure_name  => 'CHECK_WP_RBS_CONSISTENCY'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END CHECK_WP_RBS_CONSISTENCY;

FUNCTION GET_WP_BASELINED_PLAN_VERSION
 ( p_project_id IN pa_projects_all.project_id%TYPE)
RETURN NUMBER
IS
 CURSOR get_baselined_version(c_project_id pa_projects_all.project_id%TYPE)
  IS
  SELECT header.plan_version_id
  FROM pa_proj_elem_ver_structure str,
       pji_pjp_wbs_header header
  WHERE str.project_id = c_project_id
  AND str.current_flag = 'Y'
  AND header.project_id = str.project_id
  AND header.wbs_version_id = str.element_version_id
  AND header.wp_flag = 'Y';

  l_baseline_version_id pji_pjp_wbs_header.plan_version_id%TYPE;

BEGIN
  OPEN get_baselined_version(p_project_id);
  FETCH get_baselined_version INTO l_baseline_version_id;
  CLOSE get_baselined_version;
  RETURN l_baseline_version_id;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END;

FUNCTION GET_WP_LATEST_VERSION
 ( p_project_id IN pa_projects_all.project_id%TYPE)
RETURN NUMBER
IS
 CURSOR get_latest_published_version(c_project_id pa_projects_all.project_id%TYPE)
  IS
  SELECT header.plan_version_id
  FROM pa_proj_elem_ver_structure str,
       pji_pjp_wbs_header header
  WHERE str.project_id = c_project_id
  AND str.latest_eff_published_flag = 'Y'
  AND header.project_id = str.project_id
  AND header.wbs_version_id = str.element_version_id
  AND header.wp_flag = 'Y';

  l_latest_published_version_id pji_pjp_wbs_header.plan_version_id%TYPE;

BEGIN
  OPEN get_latest_published_version(p_project_id);
  FETCH get_latest_published_version INTO l_latest_published_version_id;
  CLOSE get_latest_published_version;
  RETURN l_latest_published_version_id;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END;

FUNCTION GET_DEFAULT_EXPANSION_LEVEL
( p_project_id IN pa_projects_all.project_id%TYPE
 ,p_object_type  IN VARCHAR2)
RETURN NUMBER
IS
	CURSOR get_wp_default_disp_lvl(c_project_id pa_projects_all.project_id%TYPE)
	IS
	SELECT wp_default_display_lvl
	FROM   pa_workplan_options_v
	WHERE  PROJECT_ID = c_project_id;

	CURSOR get_fp_default_disp_lvl(c_project_id pa_projects_all.project_id%TYPE)
	IS
	SELECT default_display_lvl
	FROM   pa_financial_options_v
	WHERE  PROJECT_ID = c_project_id;

	l_default_exp_level NUMBER := 0;
BEGIN
	IF p_object_type = 'T' THEN
		OPEN get_wp_default_disp_lvl(p_project_id);
		FETCH get_wp_default_disp_lvl INTO l_default_exp_level;
		CLOSE get_wp_default_disp_lvl;

		l_default_exp_level := NVL(l_default_exp_level,0);
	--Bug 5469672 Add logic to derive default FBS expansion level
	ELSIF p_object_type = 'FT' THEN
		OPEN get_fp_default_disp_lvl(p_project_id);
		FETCH get_fp_default_disp_lvl INTO l_default_exp_level;
		CLOSE get_fp_default_disp_lvl;

		l_default_exp_level := NVL(l_default_exp_level,0);
	ELSIF p_object_type = 'R' THEN
		l_default_exp_level := 2;   --Once we have a proper setup for RBS, this hardcoding should be replaced.
	ELSE
		l_default_exp_level := 0;
	END IF;

	RETURN l_default_exp_level;
END GET_DEFAULT_EXPANSION_LEVEL;

PROCEDURE Derive_Default_Plan_Type_Ids(
  p_project_id                  IN         NUMBER
, x_cost_fcst_plan_type_id      OUT NOCOPY NUMBER
, x_cost_bgt_plan_type_id       OUT NOCOPY NUMBER
, x_cost_bgt2_plan_type_id      OUT NOCOPY NUMBER
, x_rev_fcst_plan_type_id       OUT NOCOPY NUMBER
, x_rev_bgt_plan_type_id        OUT NOCOPY NUMBER
, x_rev_bgt2_plan_type_id       OUT NOCOPY NUMBER
, x_return_status               IN OUT NOCOPY VARCHAR2
, x_msg_count                   IN OUT NOCOPY NUMBER
, x_msg_data                    IN OUT NOCOPY VARCHAR2)

IS
 l_cost_bgt_plan_type_id                 NUMBER := NULL;
 l_rev_bgt_plan_type_id                  NUMBER := NULL;

BEGIN
        IF g_debug_mode = 'Y' THEN
           Pji_Utils.WRITE2LOG( 'Get_Plan_Types_Id: beginning', TRUE , g_proc);
        END IF;


        IF x_return_status IS NULL THEN
                x_msg_count := 0;
                x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        END IF;

        IF p_project_id  IS NOT NULL THEN

               /*
                ** Get approved cost and revenue plan types for the
                ** project.
                */
                Pa_Fin_Plan_Utils.Get_Appr_Cost_Plan_Type_Info(
                  p_project_id=>p_project_id
                  ,x_plan_type_id =>l_cost_bgt_plan_type_id
                  ,x_return_status=>x_return_status
                  ,x_msg_count=>x_msg_count
                  ,x_msg_data=>x_msg_data);
                Pa_Fin_Plan_Utils.Get_Appr_Rev_Plan_Type_Info(
                  p_project_id=>p_project_id
                  ,x_plan_type_id=>l_rev_bgt_plan_type_id
                  ,x_return_status=>x_return_status
                  ,x_msg_count=>x_msg_count
                  ,x_msg_data=>x_msg_data);

               /* Assigning cost budget type id in cost budget 2 type id
                  and revenue budget type id in revenue budget 2 type  id */

		  		  x_cost_bgt_plan_type_id     := l_cost_bgt_plan_type_id ;
                  x_rev_bgt_plan_type_id       := l_rev_bgt_plan_type_id;
                  x_cost_bgt2_plan_type_id   := NULL;--l_cost_bgt_plan_type_id ;
                  x_rev_bgt2_plan_type_id     := NULL; --l_rev_bgt_plan_type_id;

                /*
                ** Get primary cost and revenue plan types for the
                ** project.
                */
                Pa_Fin_Plan_Utils.Is_Pri_Fcst_Cost_PT_Attached(
                  p_project_id=>p_project_id
                  ,x_plan_type_id=>x_cost_fcst_plan_type_id
                  ,x_return_status=>x_return_status
                  ,x_msg_count=>x_msg_count
                  ,x_msg_data=>x_msg_data);
                Pa_Fin_Plan_Utils.Is_Pri_Fcst_Rev_PT_Attached(
                  p_project_id=>p_project_id
                  ,x_plan_type_id=>x_rev_fcst_plan_type_id
                  ,x_return_status=>x_return_status
                  ,x_msg_count=>x_msg_count
                  ,x_msg_data=>x_msg_data);
     ELSE
        x_cost_bgt_plan_type_id  := NULL;
        x_rev_bgt_plan_type_id   := NULL;
        x_cost_bgt2_plan_type_id := NULL;
        x_rev_bgt2_plan_type_id  := NULL;
        x_cost_fcst_plan_type_id := NULL;
        x_rev_fcst_plan_type_id  := NULL;
     END IF;

EXCEPTION
    WHEN OTHERS THEN
       NULL;
END Derive_Default_Plan_Type_Ids;

/*
** Get all plan versions for a given project and plan type id
*/
PROCEDURE Derive_Plan_Version_Ids(
                 p_project_id                      IN NUMBER
               , p_cost_fcst_plan_type_id          IN NUMBER
               , p_cost_bgt_plan_type_id           IN NUMBER
               , p_cost_bgt2_plan_type_id          IN NUMBER
               , p_rev_fcst_plan_type_id           IN NUMBER
               , p_rev_bgt_plan_type_id            IN NUMBER
               , p_rev_bgt2_plan_type_id           IN NUMBER
               , x_cstforecast_version_id          OUT NOCOPY NUMBER
               , x_cstbudget_version_id            OUT NOCOPY NUMBER
               , x_cstbudget2_version_id           OUT NOCOPY NUMBER
               , x_revforecast_version_id          OUT NOCOPY NUMBER
               , x_revbudget_version_id            OUT NOCOPY NUMBER
               , x_revbudget2_version_id           OUT NOCOPY NUMBER
               , x_orig_cstbudget_version_id       OUT NOCOPY NUMBER
               , x_orig_cstbudget2_version_id      OUT NOCOPY NUMBER
               , x_orig_revbudget_version_id       OUT NOCOPY NUMBER
               , x_orig_revbudget2_version_id      OUT NOCOPY NUMBER
               , x_prior_cstfcst_version_id        OUT NOCOPY NUMBER
               , x_prior_revfcst_version_id        OUT NOCOPY NUMBER
               , x_return_status                   IN OUT NOCOPY VARCHAR2
               , x_msg_count                       IN OUT NOCOPY NUMBER
               , x_msg_data                        IN OUT NOCOPY VARCHAR2)
IS
      l_cst_budget_version_type              pa_budget_versions.version_type%TYPE;
      l_rev_budget_version_type              pa_budget_versions.version_type%TYPE;
      l_cst_budget2_version_type             pa_budget_versions.version_type%TYPE;
      l_rev_budget2_version_type             pa_budget_versions.version_type%TYPE;
      l_cst_forecast_version_type            pa_budget_versions.version_type%TYPE;
      l_rev_forecast_version_type            pa_budget_versions.version_type%TYPE;
      l_fp_options_id                        pa_proj_fp_options.proj_fp_options_id%TYPE;
      l_temp_holder1                         NUMBER;
      l_temp_holder2                         NUMBER;
      l_temp_cstforecast_version_id          NUMBER;
      l_tmp_orig_cstforecast_ver_id          NUMBER;
      l_temp_revforecast_version_id          NUMBER;
      l_tmp_orig_revforecast_ver_id          NUMBER;
BEGIN

    IF g_debug_mode = 'Y' THEN
      Pji_Utils.WRITE2LOG( 'derive_default_plan_versions: beginning', TRUE , g_proc);
    END IF;


    IF x_return_status IS NULL THEN
	x_msg_count := 0;
	x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
     END IF;

     IF p_project_id IS NOT NULL THEN
	/*
	** Following are the defaulting rules:
	** cost budget plan version: current baselined version of approved cost plan type.
	** revenue budget plan version: current baselined version of approved revenue plan type.
	** cost forecast plan version: current baselined version of primary cost plan type.
	** revenue forecast plan version: current baselined version of primary revenue plan type.
	** cost budget2 plan version: current baselined version of approved cost plan type 2.
	** revenue budget2 plan version: current baselined version of approved revenue plan type 2.
	** misc: return original baselined for all above plan versions.
	*/
	BEGIN

		/*
		** Get current and original baselined plan versions
		** for approved/primary cost and revenue plan types.
		*/
		IF p_cost_bgt_plan_type_id IS NOT NULL THEN
		   	BEGIN
				Pa_Fin_Plan_Utils.Get_Cost_Base_Version_Info(
			          p_project_id         =>p_project_id
			          ,p_fin_plan_Type_id  =>p_cost_bgt_plan_type_id
			          ,p_budget_type_code  =>NULL
			          ,x_budget_version_id =>x_cstbudget_version_id
			          ,x_return_status     =>x_return_status
			          ,x_msg_count         =>x_msg_count
			          ,x_msg_data          =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 x_cstbudget_version_id := NULL;
		   	END;

			BEGIN
				l_cst_budget_version_type:=Get_Version_Type(p_project_id
				    ,p_cost_bgt_plan_type_id
				    ,Pa_Fp_Constants_Pkg.G_VERSION_TYPE_COST);

				Pa_Fin_Plan_Utils.Get_Curr_Original_Version_Info(
			          p_project_id              =>p_project_id
			          ,p_fin_plan_Type_id       =>p_cost_bgt_plan_type_id
			          ,p_version_type           =>l_cst_budget_version_type
			          ,x_fp_options_id          =>l_fp_options_id
			          ,x_fin_plan_version_id    =>x_orig_cstbudget_version_id
			          ,x_return_status          =>x_return_status
			          ,x_msg_count              =>x_msg_count
			          ,x_msg_data               =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 x_orig_cstbudget_version_id := NULL;
		   	END;

        ELSE
          x_cstbudget_version_id       := NULL;
          x_orig_cstbudget_version_id  := NULL;
		END IF;

		IF p_rev_bgt_plan_type_id IS NOT NULL THEN

		   	BEGIN
				Pa_Fin_Plan_Utils.Get_Rev_Base_Version_Info(
			          p_project_id            =>p_project_id
			          ,p_fin_plan_Type_id     =>p_rev_bgt_plan_type_id
			          ,p_budget_type_code     =>NULL
			          ,x_budget_version_id    =>x_revbudget_version_id
			          ,x_return_status        =>x_return_status
			          ,x_msg_count            =>x_msg_count
			          ,x_msg_data             =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 x_revbudget_version_id := NULL;
		   	END;

			BEGIN
				l_rev_budget_version_type:=Get_Version_Type(p_project_id
				    ,p_rev_bgt_plan_type_id
				    ,Pa_Fp_Constants_Pkg.G_VERSION_TYPE_REVENUE);

				Pa_Fin_Plan_Utils.Get_Curr_Original_Version_Info(
			          p_project_id                   =>p_project_id
			          ,p_fin_plan_Type_id            =>p_rev_bgt_plan_type_id
			          ,p_version_type                =>l_rev_budget_version_type
				  ,x_fp_options_id               =>l_fp_options_id
			          ,x_fin_plan_version_id         =>x_orig_revbudget_version_id
			          ,x_return_status               =>x_return_status
			          ,x_msg_count                   =>x_msg_count
			          ,x_msg_data                    =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 x_orig_revbudget_version_id := NULL;
		   	END;

        ELSE
            x_revbudget_version_id               := NULL;
            x_orig_revbudget_version_id          := NULL;
		END IF;

		/*
		** Get current and original baselined plan versions
		** for approved/primary cost and revenue plan types 2.
		*/
		IF p_cost_bgt2_plan_type_id IS NOT NULL THEN

		   	BEGIN
				Pa_Fin_Plan_Utils.Get_Cost_Base_Version_Info(
			          p_project_id         =>p_project_id
			          ,p_fin_plan_Type_id  =>p_cost_bgt2_plan_type_id
			          ,p_budget_type_code  =>NULL
			          ,x_budget_version_id =>x_cstbudget2_version_id
			          ,x_return_status     =>x_return_status
			          ,x_msg_count         =>x_msg_count
			          ,x_msg_data          =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 x_cstbudget2_version_id := NULL;
		   	END;

			BEGIN
				l_cst_budget2_version_type:=Get_Version_Type(p_project_id
				    ,p_cost_bgt2_plan_type_id
				    ,Pa_Fp_Constants_Pkg.G_VERSION_TYPE_COST);

				Pa_Fin_Plan_Utils.Get_Curr_Original_Version_Info(
			           p_project_id             =>p_project_id
			          ,p_fin_plan_Type_id       =>p_cost_bgt2_plan_type_id
			          ,p_version_type           =>l_cst_budget2_version_type
			          ,x_fp_options_id          =>l_fp_options_id
			          ,x_fin_plan_version_id    =>x_orig_cstbudget2_version_id
			          ,x_return_status          =>x_return_status
			          ,x_msg_count              =>x_msg_count
			          ,x_msg_data               =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 x_orig_cstbudget2_version_id := NULL;
		   	END;

        ELSE
          x_cstbudget2_version_id       := NULL;
          x_orig_cstbudget2_version_id  := NULL;
		END IF;

		IF p_rev_bgt2_plan_type_id IS NOT NULL THEN

		   	BEGIN
			Pa_Fin_Plan_Utils.Get_Rev_Base_Version_Info(
		          p_project_id            =>p_project_id
		          ,p_fin_plan_Type_id     =>p_rev_bgt2_plan_type_id
		          ,p_budget_type_code     =>NULL
		          ,x_budget_version_id    =>x_revbudget2_version_id
		          ,x_return_status        =>x_return_status
		          ,x_msg_count            =>x_msg_count
		          ,x_msg_data             =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 x_revbudget2_version_id := NULL;
		   	END;

			BEGIN
				l_rev_budget2_version_type:=Get_Version_Type(p_project_id
				    ,p_rev_bgt2_plan_type_id
				    ,Pa_Fp_Constants_Pkg.G_VERSION_TYPE_REVENUE);

				Pa_Fin_Plan_Utils.Get_Curr_Original_Version_Info(
			          p_project_id                   =>p_project_id
			          ,p_fin_plan_Type_id            =>p_rev_bgt2_plan_type_id
			          ,p_version_type                =>l_rev_budget2_version_type
				  ,x_fp_options_id               =>l_fp_options_id
			          ,x_fin_plan_version_id         =>x_orig_revbudget2_version_id
			          ,x_return_status               =>x_return_status
			          ,x_msg_count                   =>x_msg_count
			          ,x_msg_data                    =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 x_orig_revbudget2_version_id := NULL;
		   	END;
        ELSE
            x_revbudget2_version_id               := NULL;
            x_orig_revbudget2_version_id          := NULL;
		END IF;

		/*
		** Get current and prior baselined plan versions
		** for forecast cost and revenue plan types.
		*/
		IF p_cost_fcst_plan_type_id IS NOT NULL THEN

		   	BEGIN
				Pa_Fin_Plan_Utils.Get_Cost_Base_Version_Info(
			          p_project_id             =>p_project_id
			          ,p_fin_plan_Type_id      =>p_cost_fcst_plan_type_id
			          ,p_budget_type_code      =>NULL
			          ,x_budget_version_id     =>l_temp_cstforecast_version_id
			          ,x_return_status         =>x_return_status
			          ,x_msg_count             =>x_msg_count
			          ,x_msg_data              =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 l_temp_cstforecast_version_id := NULL;
		   	END;

			BEGIN
				l_cst_forecast_version_type:=Get_Version_Type(p_project_id
				    ,p_cost_fcst_plan_type_id
				    ,Pa_Fp_Constants_Pkg.G_VERSION_TYPE_COST);

				Pa_Fin_Plan_Utils.Get_Curr_Original_Version_Info(
			          p_project_id                =>p_project_id
			          ,p_fin_plan_Type_id         =>p_cost_fcst_plan_type_id
			          ,p_version_type             =>l_cst_forecast_version_type
				  ,x_fp_options_id            =>l_fp_options_id
			          ,x_fin_plan_version_id      =>l_tmp_orig_cstforecast_ver_id
			          ,x_return_status            =>x_return_status
			          ,x_msg_count                =>x_msg_count
			          ,x_msg_data                 =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 l_tmp_orig_cstforecast_ver_id := NULL;
		   	END;

			IF (l_temp_cstforecast_version_id IS NOT NULL) AND (l_temp_cstforecast_version_id <>-99) THEN
                 x_cstforecast_version_id   := l_temp_cstforecast_version_id;

				BEGIN
					Pa_Planning_Element_Utils.get_finplan_bvids(
	                                 p_project_id               =>p_project_id
					,p_budget_version_id        => l_temp_cstforecast_version_id
					, x_current_version_id      => l_temp_holder1
					, x_original_version_id     => l_temp_holder2
					, x_prior_fcst_version_id   => x_prior_cstfcst_version_id
			                , x_return_status           => x_return_status
			                , x_msg_count               => x_msg_count
			                , x_msg_data                => x_msg_data);
					--Bug5510794 deriving the correct prior forecast version id
					x_prior_cstfcst_version_id := Pa_Planning_Element_Utils.get_prior_forecast_version_id(l_temp_cstforecast_version_id, p_project_id);
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					 x_prior_cstfcst_version_id := NULL;
			   	END;

            ELSE
              x_cstforecast_version_id     := NULL;
              x_prior_cstfcst_version_id   := NULL;
			END IF;
        ELSE
           x_cstforecast_version_id     := NULL;
           x_prior_cstfcst_version_id   := NULL;
		END IF;

		IF p_rev_fcst_plan_type_id IS NOT NULL THEN

		   	BEGIN
				Pa_Fin_Plan_Utils.Get_Rev_Base_Version_Info(
			          p_project_id         =>p_project_id
			          ,p_fin_plan_Type_id  =>p_rev_fcst_plan_type_id
			          ,p_budget_type_code  =>NULL
			          ,x_budget_version_id =>l_temp_revforecast_version_id
			          ,x_return_status     =>x_return_status
			          ,x_msg_count         =>x_msg_count
			          ,x_msg_data          =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 l_temp_revforecast_version_id := NULL;
		   	END;

			BEGIN
				l_rev_forecast_version_type:=Get_Version_Type(p_project_id
				    ,p_rev_fcst_plan_type_id
				    ,Pa_Fp_Constants_Pkg.G_VERSION_TYPE_REVENUE);

				Pa_Fin_Plan_Utils.Get_Curr_Original_Version_Info(
			          p_project_id           =>p_project_id
			          ,p_fin_plan_Type_id    =>p_rev_fcst_plan_type_id
			          ,p_version_type        =>l_rev_forecast_version_type
				  ,x_fp_options_id       =>l_fp_options_id
			          ,x_fin_plan_version_id =>l_tmp_orig_revforecast_ver_id
			          ,x_return_status       =>x_return_status
			          ,x_msg_count           =>x_msg_count
			          ,x_msg_data            =>x_msg_data);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				 l_tmp_orig_revforecast_ver_id := NULL;
		   	END;

			IF (l_temp_revforecast_version_id IS NOT NULL) AND (l_temp_revforecast_version_id <>-99) THEN
                               x_revforecast_version_id     := l_temp_revforecast_version_id;

				BEGIN
					Pa_Planning_Element_Utils.get_finplan_bvids(
	                                 p_project_id                   => p_project_id
					,p_budget_version_id            => l_temp_revforecast_version_id
					, x_current_version_id          => l_temp_holder1
					, x_original_version_id         => l_temp_holder2
					, x_prior_fcst_version_id       => x_prior_revfcst_version_id
			                , x_return_status               => x_return_status
			                , x_msg_count                   => x_msg_count
			                , x_msg_data                    => x_msg_data);
					--Bug5510794 deriving the correct prior forecast version id
					x_prior_revfcst_version_id := Pa_Planning_Element_Utils.get_prior_forecast_version_id(l_temp_revforecast_version_id, p_project_id);
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					 x_prior_revfcst_version_id := NULL;
			   	END;

             ELSE
                 x_revforecast_version_id   := NULL;
                 x_prior_revfcst_version_id := NULL;
			 END IF;
        ELSE
           x_revforecast_version_id   := NULL;
           x_prior_revfcst_version_id := NULL;
		END IF;
	END;
    ELSE
        x_cstbudget_version_id       := NULL;
        x_orig_cstbudget_version_id  := NULL;
        x_revbudget_version_id       := NULL;
        x_orig_revbudget_version_id  := NULL;
        x_revbudget2_version_id      := NULL;
        x_orig_revbudget2_version_id := NULL;
        x_cstbudget2_version_id      := NULL;
        x_orig_cstbudget2_version_id := NULL;
        x_cstforecast_version_id     := NULL;
        x_prior_cstfcst_version_id   := NULL;
        x_revforecast_version_id     := NULL;
        x_prior_revfcst_version_id   := NULL;

    END IF;

    /* The pa api of retrieving the plan versions need to check whether the given
     * plan type belongs to the given project id. If not, it will put an error
     * message into the stack. Since we don't think this is a exception, we have
     * catched the exception in the API, but the error message is still there,
     * so we need to clean the stack too.*/

    Fnd_Msg_Pub.Initialize;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_default_plan_versions: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Get_Plan_Versions_Id');
	RAISE;
END Derive_Plan_Version_Ids;

/*
 * This api checks for each project in this passed program whether they
 * have the same GL or same PA calendar or not. If GL calendar is same then x_gl_flag
 * will return 'T' else 'F'. This logic is true for PA calendar also.
 */
PROCEDURE Check_Perf_Cal_Consistency(
                        p_project_id        IN  pa_projects_all.project_id%TYPE
                       ,p_wbs_version_id    IN  pji_xbs_denorm.sup_project_id%TYPE
                       ,x_gl_flag           OUT NOCOPY VARCHAR2
                       ,x_pa_flag           OUT NOCOPY VARCHAR2
                       ,x_return_status     OUT NOCOPY VARCHAR2
                       ,x_msg_count         OUT NOCOPY NUMBER
                       ,x_msg_data          OUT NOCOPY VARCHAR2)
IS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);
l_num_of_gl_cal                 NUMBER := 0;
l_num_of_pa_cal                 NUMBER := 0;
l_debug_level3                  CONSTANT NUMBER := 3;
l_debug_level5                  CONSTANT NUMBER := 5;
l_module_name                   VARCHAR2(100) := 'pa.plsql.Check_Perf_Cal_Consistency';

BEGIN
    x_msg_count := 0;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.set_curr_function( p_function   => 'Check_Perf_Cal_Consistency',
                                     p_debug_mode => l_debug_mode );
    END IF;

	--These flags will denote the respective consistency. A value of T for x_gl_flag, and x_pa_flag
	--indicates that all the projects in the program have the same GL/PA calendar. A value of F indicates
	--inconsistency.
        x_gl_flag			:= 'T';
	x_pa_flag			:= 'T';

	--Obtain the GL and PA calendars count
            SELECT COUNT(DISTINCT info.gl_calendar_id),
                   COUNT(DISTINCT info.pa_calendar_id)
            INTO l_num_of_gl_cal,
                 l_num_of_pa_cal
            FROM
                 pji_xbs_denorm denorm
               , pa_proj_elements elem
               , pa_projects_all proj
               , pji_org_extr_info info
            WHERE 1=1
            AND denorm.sup_project_id = p_project_id         -- project_id
            AND denorm.sup_id         = p_wbs_version_id     -- wbs_version_id
            AND denorm.struct_type    = 'PRG'
            AND denorm.struct_version_id IS NULL
            AND NVL(denorm.relationship_type,'WF') IN ('LF','WF')
            AND denorm.sub_emt_id     = elem.proj_element_id
            AND proj.project_id       = elem.project_id
            AND NVL(info.org_id,-99)  = NVL(proj.org_id,-99);

            IF (NVL(l_num_of_gl_cal,0) > 1 ) THEN
               x_gl_flag := 'F';
            ELSE
               x_gl_flag := 'T';
            END IF;

            IF (NVL(l_num_of_pa_cal,0) > 1 ) THEN
               x_pa_flag := 'F';
            ELSE
               x_pa_flag := 'T';
            END IF;

            IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'Exiting Check_Perf_Cal_Consistency';
               Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level3);
               Pa_Debug.reset_curr_function;
            END IF;
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PJI_REP_UTIL'
                    ,p_procedure_name  => 'Check_Perf_Cal_Consistency'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END Check_Perf_Cal_Consistency;

/*
 * This api checks for each project in this passed program whether they
 * have the same Project Functional Currency (PFC) or not. If PFC is same then x_pfc_flag
 * will return 'T' else 'F'.
 */
PROCEDURE Check_Perf_Curr_Consistency(
                        p_project_id        IN  pa_projects_all.project_id%TYPE
                       ,p_wbs_version_id    IN  pji_xbs_denorm.sup_project_id%TYPE
                       ,x_pfc_flag          OUT NOCOPY VARCHAR2
                       ,x_return_status     OUT NOCOPY VARCHAR2
                       ,x_msg_count         OUT NOCOPY NUMBER
                       ,x_msg_data          OUT NOCOPY VARCHAR2)
IS
 l_msg_count                     NUMBER := 0;
 l_data                          VARCHAR2(2000);
 l_msg_data                      VARCHAR2(2000);
 l_debug_mode                    VARCHAR2(1);
 l_debug_level3                  CONSTANT NUMBER := 3;
 l_debug_level5                  CONSTANT NUMBER := 5;
 l_module_name                   VARCHAR2(100) := 'pa.plsql.Check_Perf_Cal_Consistency';
 l_num_of_projfunc_curr	         NUMBER;

BEGIN
    x_msg_count := 0;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
         Pa_Debug.set_curr_function( p_function   => 'Check_Perf_Curr_Consistency',
                                     p_debug_mode => l_debug_mode );
    END IF;

	--These flags will denote the respective consistency. A value of T for x_pfc_flag
	--indicates that all the projects in the program have the same PFC. A value of F indicates
	--inconsistency.
           x_pfc_flag			:= 'T';

	--Obtain the PFC count
          SELECT COUNT(DISTINCT proj.projfunc_currency_code)
          INTO l_num_of_projfunc_curr
          FROM
                 pji_xbs_denorm denorm
               , pa_proj_elements elem
               , pa_projects_all proj
          WHERE 1=1
          AND denorm.sup_project_id = p_project_id         -- project_id
          AND denorm.sup_id         = p_wbs_version_id     -- wbs_version_id
          AND denorm.struct_type    = 'PRG'
          AND denorm.struct_version_id IS NULL
          AND NVL(denorm.relationship_type,'WF') IN ('LF','WF')
          AND denorm.sub_emt_id     = elem.proj_element_id
          AND proj.project_id       = elem.project_id;

          IF (NVL(l_num_of_projfunc_curr,0) > 1 ) THEN
             x_pfc_flag := 'F';
          ELSE
             x_pfc_flag := 'T';
          END IF;

          IF l_debug_mode = 'Y' THEN
             Pa_Debug.g_err_stage:= 'Exiting Check_Perf_Curr_Consistency';
             Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level3);
             Pa_Debug.reset_curr_function;
          END IF;
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PJI_REP_UTIL'
                    ,p_procedure_name  => 'Check_Perf_Curr_Consistency'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(l_module_name,Pa_Debug.g_err_stage,l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END Check_Perf_Curr_Consistency;

/* Adding this procedure to do addition calculation with Null rules
 * for bug 4194804. Please do not add out parameters because this
 * function is also used as select function in VO.xml also
 */
FUNCTION Measures_Total(
                     p_measure1        IN         NUMBER
                   , p_measure2        IN         NUMBER   DEFAULT NULL
                   , p_measure3        IN         NUMBER   DEFAULT NULL
                   , p_measure4        IN         NUMBER   DEFAULT NULL
                   , p_measure5        IN         NUMBER   DEFAULT NULL
                   , p_measure6        IN         NUMBER   DEFAULT NULL
                   , p_measure7        IN         NUMBER   DEFAULT NULL
                  ) RETURN NUMBER
IS
 l_measures_total                NUMBER;
 l_debug_mode                    VARCHAR2(1);
 l_debug_level3                  CONSTANT NUMBER := 3;
 l_debug_level5                  CONSTANT NUMBER := 5;
 l_module_name                   VARCHAR2(100) := 'pa.plsql.Measures_Total';
BEGIN
    IF ( p_measure1 IS NULL AND  p_measure2 IS NULL AND  p_measure3 IS NULL AND
         p_measure4 IS NULL AND  p_measure5 IS NULL AND  p_measure6 IS NULL AND
         p_measure7 IS NULL ) THEN

         RETURN TO_NUMBER(NULL);
    ELSE
      l_measures_total := ( NVL(p_measure1,0) + NVL(p_measure2,0) + NVL(p_measure3,0) +
                            NVL(p_measure4,0) + NVL(p_measure5,0) + NVL(p_measure6,0) +
                            NVL(p_measure7,0) );
      RETURN l_measures_total;
    END IF;

EXCEPTION
 WHEN OTHERS THEN
  NULL;
END Measures_Total;

/* Checks if the smart slice api has been called or not.
   If it is called then no need to call processing page,
   but if it is not called then call the api and launch
   the processing page. But if the processing is Deferred
   then launch concurrent program   */

/* Changed the whole logic for Program and Project case for bug 4411930 */

PROCEDURE Is_Smart_Slice_Created(
                  p_rbs_version_id      IN  NUMBER,
                  p_plan_version_id_tbl IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
                  p_wbs_element_id      IN  NUMBER,
                  p_rbs_element_id      IN  NUMBER,
                  p_prg_rollup_flag     IN  VARCHAR2,
                  p_curr_record_type_id IN  NUMBER,
                  p_calendar_type       IN  VARCHAR2,
                  p_wbs_version_id      IN  NUMBER,
                  p_commit              IN  VARCHAR2 := 'Y',
                  p_project_id          IN  NUMBER,  -- Aded for bug 4419342
                  x_Smart_Slice_Flag    OUT NOCOPY  VARCHAR2,
                  x_msg_count           OUT NOCOPY  NUMBER,
                  x_msg_data            OUT NOCOPY  VARCHAR2,
                  x_return_status       OUT NOCOPY  VARCHAR2)
IS
  l_plan_version_id                NUMBER      := NULL;
  l_plan_version_id_tbl            SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_plan_type_id_tbl               SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_project_id_tbl                 SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_get_wbs_version_id_tbl         SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_wbs_version_id_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_exists                         VARCHAR2(1) := 'N';
  j                                NUMBER      := 0;
  l_count                          NUMBER      := 1;
  l_IsSmartSliceCreated_Flag       VARCHAR2(1) := 'Y';
  l_found                          BOOLEAN;
  l_project_id                     NUMBER := 1;
BEGIN
    l_IsSmartSliceCreated_Flag := 'Y';

     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    IF g_debug_mode = 'Y' THEN
       Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: begining', TRUE , g_proc);
    END IF;

   -- Checking if RBS version id is null or p_plan_version_ids's table is null then exiting smoothly
   IF ( p_rbs_version_id IS NULL OR p_plan_version_id_tbl.COUNT <= 0 ) THEN
     IF g_debug_mode = 'Y' THEN
        Pji_Utils.WRITE2LOG( 'Exiting from Is_Smart_Slice_Created: no RBS or Plan version id found', TRUE , g_proc);
     END IF;

     RETURN;
   END IF;

   l_plan_version_id_tbl.EXTEND;
   FOR i IN p_plan_version_id_tbl.FIRST..p_plan_version_id_tbl.LAST LOOP
    IF    ( p_plan_version_id_tbl.EXISTS(i)) THEN
      l_found := FALSE;
      FOR j IN l_plan_version_id_tbl.FIRST..l_plan_version_id_tbl.LAST LOOP
        IF (  l_plan_version_id_tbl(j) = p_plan_version_id_tbl(i) ) THEN
              l_found := TRUE;
              EXIT;
        END IF;
      END LOOP;
      IF ( NOT l_found ) THEN
         l_plan_version_id_tbl(l_plan_version_id_tbl.COUNT) := p_plan_version_id_tbl(i);
         l_plan_version_id_tbl.EXTEND;
         IF g_debug_mode = 'Y' THEN
            Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: inside assignment', TRUE , g_proc);
         END IF;
      END IF;
    END IF;
  END LOOP;

  l_count := l_plan_version_id_tbl.COUNT - 1;


   FOR i IN 1..17 LOOP
      IF    ( l_plan_version_id_tbl.EXISTS(i)) THEN
              NULL;
      ELSE
        l_plan_version_id_tbl.EXTEND;
        l_plan_version_id_tbl(i) := 0;
      END IF;
        l_project_id_tbl.EXTEND;
        l_project_id_tbl(i) := p_project_id;
   END LOOP;

     IF ( g_debug_mode = 'Y') THEN
           Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: Done with logic', TRUE , g_proc);
    END IF;

/* Program case */
IF (NVL(p_prg_rollup_flag,'N')    = 'Y') THEN

     IF g_debug_mode = 'Y' THEN
           Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: Entering into Program logic', TRUE , g_proc);
    END IF;

     BEGIN
       SELECT project_id
       INTO l_project_id
       FROM
         pa_proj_element_versions
       WHERE
         ELEMENT_VERSION_ID = p_wbs_version_id;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           NULL;
     END;

     IF (g_debug_mode = 'Y') THEN
           Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: Done with Project Select', TRUE , g_proc);
    END IF;

    BEGIN
          SELECT DISTINCT head.wbs_version_id BULK COLLECT
          INTO l_get_wbs_version_id_tbl
          FROM pji_pjp_wbs_header head
          WHERE head.plan_version_id IN ( l_plan_version_id_tbl(1),l_plan_version_id_tbl(2),l_plan_version_id_tbl(3),
                                        l_plan_version_id_tbl(4), l_plan_version_id_tbl(5),l_plan_version_id_tbl(6),
                                        l_plan_version_id_tbl(7),l_plan_version_id_tbl(8), l_plan_version_id_tbl(9),
                                        l_plan_version_id_tbl(10),l_plan_version_id_tbl(11),l_plan_version_id_tbl(12),
                                        l_plan_version_id_tbl(13),l_plan_version_id_tbl(14),l_plan_version_id_tbl(15),
                                        l_plan_version_id_tbl(16),l_plan_version_id_tbl(17) )
          AND head.project_id  = l_project_id;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
            IF g_debug_mode = 'Y' THEN
                  Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: No data found in wbs_version_id Select', TRUE , g_proc);
             END IF;
      END;

      IF g_debug_mode = 'Y' THEN
            Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: Done with wbs_version_id Select', TRUE , g_proc);
      END IF;

      BEGIN
          SELECT DISTINCT NVL(head.plan_type_id,-1) BULK COLLECT
          INTO l_plan_type_id_tbl
          FROM pji_pjp_wbs_header head
          WHERE head.plan_version_id IN ( l_plan_version_id_tbl(1),l_plan_version_id_tbl(2),l_plan_version_id_tbl(3),
                                        l_plan_version_id_tbl(4), l_plan_version_id_tbl(5),l_plan_version_id_tbl(6),
                                        l_plan_version_id_tbl(7),l_plan_version_id_tbl(8), l_plan_version_id_tbl(9),
                                        l_plan_version_id_tbl(10),l_plan_version_id_tbl(11),l_plan_version_id_tbl(12),
                                        l_plan_version_id_tbl(13),l_plan_version_id_tbl(14),l_plan_version_id_tbl(15),
                                        l_plan_version_id_tbl(16),l_plan_version_id_tbl(17) )
          AND head.project_id  = l_project_id;
      EXCEPTION
           WHEN NO_DATA_FOUND THEN
             NULL;
             IF g_debug_mode = 'Y' THEN
                  Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: No data found in plan_type_id Select', TRUE , g_proc);
             END IF;
      END;

      IF g_debug_mode = 'Y' THEN
           Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: Done with plan_type_id Select', TRUE , g_proc);
      END IF;

      FOR i IN 1..17 LOOP
        IF    ( l_get_wbs_version_id_tbl.EXISTS(i)) THEN
                NULL;
        ELSE
             l_get_wbs_version_id_tbl.EXTEND;
             l_get_wbs_version_id_tbl(i) := 0;
        END IF;
      END LOOP;

      FOR i IN 1..17 LOOP
         IF    ( l_plan_type_id_tbl.EXISTS(i)) THEN
                NULL;
         ELSE
             l_plan_type_id_tbl.EXTEND;
             l_plan_type_id_tbl(i) := 0;
         END IF;
      END LOOP;

      IF g_debug_mode = 'Y' THEN
           Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: Before deleting project tem table and plan version temp table', TRUE , g_proc);
     END IF;

     l_plan_version_id_tbl.DELETE;
     l_project_id_tbl.DELETE;

     IF g_debug_mode = 'Y' THEN
         Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: Before selecting plan version,project,wbs', TRUE , g_proc);
     END IF;

     BEGIN
          SELECT DISTINCT head.plan_version_id,head.project_id ,pji.sub_id wbs_version_id  BULK COLLECT
          INTO  l_plan_version_id_tbl, l_project_id_tbl,l_wbs_version_id_tbl
          FROM  pji_xbs_Denorm pji
             ,pji_pjp_wbs_header head
          WHERE pji.struct_type='PRG'
          --AND   pji.sup_level<>pji.sub_level --Bug 4624479
          AND   pji.sup_id IN(l_get_wbs_version_id_tbl(1),l_get_wbs_version_id_tbl(2),l_get_wbs_version_id_tbl(3)
                           ,l_get_wbs_version_id_tbl(4),l_get_wbs_version_id_tbl(5),l_get_wbs_version_id_tbl(6)
                           ,l_get_wbs_version_id_tbl(7),l_get_wbs_version_id_tbl(8),l_get_wbs_version_id_tbl(9)
                           ,l_get_wbs_version_id_tbl(10),l_get_wbs_version_id_tbl(11),l_get_wbs_version_id_tbl(12)
                           ,l_get_wbs_version_id_tbl(13),l_get_wbs_version_id_tbl(14),l_get_wbs_version_id_tbl(15)
                           ,l_get_wbs_version_id_tbl(16),l_get_wbs_version_id_tbl(17))
        AND   pji.sub_id=head.wbs_version_id
        AND   p_prg_rollup_flag='Y'
        AND  NVL(head.plan_type_id,-1) IN (l_plan_type_id_tbl(1),l_plan_type_id_tbl(2),l_plan_type_id_tbl(3)
                           ,l_plan_type_id_tbl(4),l_plan_type_id_tbl(5),l_plan_type_id_tbl(6)
                           ,l_plan_type_id_tbl(7),l_plan_type_id_tbl(8),l_plan_type_id_tbl(9)
                           ,l_plan_type_id_tbl(10),l_plan_type_id_tbl(11),l_plan_type_id_tbl(12)
                           ,l_plan_type_id_tbl(13),l_plan_type_id_tbl(14),l_plan_type_id_tbl(15)
                           ,l_plan_type_id_tbl(16),l_plan_type_id_tbl(17))
        AND   ((head.cb_flag='Y' )  OR (head.co_flag='Y' ) OR (head.wp_flag='Y') OR (head.wp_flag='N'
        AND head.plan_version_id = -1)  );

    EXCEPTION
      WHEN OTHERS THEN
       NULL;
      IF g_debug_mode = 'Y' THEN
          Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: No data found in selecting plan version,project,wbs', TRUE , g_proc);
       END IF;
    END;

    IF g_debug_mode = 'Y' THEN
         Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: Done with selecting plan version,project,wbs', TRUE , g_proc);
   END IF;

END IF; -- Program Case

IF g_debug_mode = 'Y' THEN
         Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: Done with program logic and checking status table', TRUE , g_proc);
END IF;


     FOR i IN 1..l_plan_version_id_tbl.COUNT LOOP

	 IF (l_plan_version_id_tbl(i) <> 0) THEN
         -- Reset flag values.
         l_exists               := 'N';
       BEGIN
           SELECT 'Y'
           INTO   l_exists FROM dual
           WHERE EXISTS ( SELECT 1
           FROM   pji_rollup_level_status rst
           WHERE  rst.rbs_version_id  = p_rbs_version_id
           AND    rst.plan_version_id = l_plan_version_id_tbl(i)
           AND    rst.project_id      = l_project_id_tbl(i));
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               x_Smart_Slice_Flag := 'Y';
               x_return_status :=  Fnd_Api.G_RET_STS_SUCCESS;
               IF ( g_debug_mode = 'Y' ) THEN
                  Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: No data found ', TRUE , g_proc);
               END IF;
       END;

       IF ( g_debug_mode = 'Y') THEN
               Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: Coming out as one of the version does not hace smart slice', TRUE , g_proc);
       END IF;

       -- If smart slice does not exist mark to create the same
         IF ( l_exists = 'N' ) THEN
            l_IsSmartSliceCreated_Flag := 'N';
           EXIT;
         END IF;

	 END IF;

     END LOOP;

      /* Important:  If the process is Deferred for getting the data, then a new status will be passed i.e. 'D' */

       x_Smart_Slice_Flag := l_IsSmartSliceCreated_Flag;
       x_return_status    := Fnd_Api.G_RET_STS_SUCCESS;
EXCEPTION
        WHEN OTHERS THEN
        x_msg_count     := 1;
        x_return_status  := Fnd_Api.G_RET_STS_ERROR;
        IF g_debug_mode = 'Y' THEN
          Pji_Utils.WRITE2LOG( 'Is_Smart_Slice_Created: When others ', TRUE , g_proc);
        END IF;
        NULL;
END Is_Smart_Slice_Created;



/*
   This procedure checks if the passed plan versions
   are having same RBS or not. It returns two valid
   values:
   'Y':- The passed Plan versions having same RBS
   'N':- The passed Plan version do not have same RBS
   Assumptions:
       + RBS is attached with context plan version
       + Additional Plan versions are selected
 */
PROCEDURE Chk_plan_vers_have_same_RBS(
                  p_fin_plan_version_id_tbl        IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
                  x_R_PlanVers_HavSame_RBS_Flag    OUT NOCOPY  VARCHAR2,
                  x_msg_count                      OUT NOCOPY  NUMBER,
                  x_msg_data                       OUT NOCOPY  VARCHAR2,
                  x_return_status                  OUT NOCOPY  VARCHAR2)
IS
  l_fin_plan_version_id             NUMBER      := NULL;
  l_fin_plan_version_ids            SYSTEM.pa_num_tbl_type;
  j                                 NUMBER      := 0;
  l_count                           NUMBER      := 1;
  l_R_PlanVers_HavSame_RBS_Flag     VARCHAR2(1) := 'Y';
BEGIN
    l_R_PlanVers_HavSame_RBS_Flag := 'Y';

    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    IF g_debug_mode = 'Y' THEN
       Pji_Utils.WRITE2LOG( 'Chk_plan_vers_have_same_RBS: begining', TRUE , g_proc);
    END IF;

   -- Checking if p_plan_version_ids's table is null then exiting smoothly
   IF ( p_fin_plan_version_id_tbl.COUNT <= 0 ) THEN
     IF g_debug_mode = 'Y' THEN
        Pji_Utils.WRITE2LOG( 'Exiting from Chk_plan_vers_have_same_RBS: No Plan version id found', TRUE , g_proc);
     END IF;

     RETURN;
   END IF;
   l_count := 1;

   FOR i IN p_fin_plan_version_id_tbl.FIRST..p_fin_plan_version_id_tbl.LAST LOOP
      l_fin_plan_version_id  := NULL;

      IF    ( p_fin_plan_version_id_tbl.EXISTS(i)) THEN
         j := j + 1;
         l_fin_plan_version_ids(j)  := p_fin_plan_version_id_tbl(i);

         IF g_debug_mode = 'Y' THEN
            Pji_Utils.WRITE2LOG( 'Chk_plan_vers_have_same_RBS: inside assignment', TRUE , g_proc);
         END IF;
      END IF;
   END LOOP;

   FOR i IN 1..8 LOOP
      IF    ( l_fin_plan_version_ids.EXISTS(i)) THEN
              NULL;
      ELSE
        l_fin_plan_version_ids(i) := 0;
      END IF;
   END LOOP;

   IF ( l_fin_plan_version_ids.COUNT > 0 ) THEN
      BEGIN
        SELECT DECODE(COUNT(DISTINCT rbs_version_id),l_count,'Y','N')
        INTO l_R_PlanVers_HavSame_RBS_Flag
        FROM pa_proj_fp_options
        WHERE 1=1
        AND fin_plan_option_level_code='PLAN_VERSION'
        AND fin_plan_version_id IN (l_fin_plan_version_ids(1),l_fin_plan_version_ids(2),l_fin_plan_version_ids(3),l_fin_plan_version_ids(4),
                       l_fin_plan_version_ids(5),l_fin_plan_version_ids(6),l_fin_plan_version_ids(7),l_fin_plan_version_ids(8));

                 IF g_debug_mode = 'Y' THEN
                    Pji_Utils.WRITE2LOG( 'Chk_plan_vers_have_same_RBS: Done selecting from pa_proj_fp_options table ', TRUE , g_proc);
                 END IF;

             IF ( l_R_PlanVers_HavSame_RBS_Flag = 'Y') THEN
                x_R_PlanVers_HavSame_RBS_Flag := l_R_PlanVers_HavSame_RBS_Flag;
                x_return_status               := Fnd_Api.G_RET_STS_SUCCESS;
             ELSE
                x_R_PlanVers_HavSame_RBS_Flag := l_R_PlanVers_HavSame_RBS_Flag;
                x_msg_count                   := NVL(x_msg_count,0) + 1;
                x_return_status               := Fnd_Api.G_RET_STS_ERROR;
                Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_NOT_SAME_RBS', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR);
             END IF;


      EXCEPTION
           WHEN NO_DATA_FOUND THEN
               x_R_PlanVers_HavSame_RBS_Flag := 'N';
               x_msg_count                   := NVL(x_msg_count,0) + 1;
               x_return_status               := Fnd_Api.G_RET_STS_ERROR;
               Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_NOT_SAME_RBS', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR);
               IF g_debug_mode = 'Y' THEN
                 Pji_Utils.WRITE2LOG( 'Chk_plan_vers_have_same_RBS: No data found ', TRUE , g_proc);
               END IF;
      END;
   END IF;
EXCEPTION
        WHEN OTHERS THEN
        x_msg_count     := 1;
        x_return_status  := Fnd_Api.G_RET_STS_ERROR;
        IF g_debug_mode = 'Y' THEN
          Pji_Utils.WRITE2LOG( 'Chk_plan_vers_have_same_RBS: When others ', TRUE , g_proc);
        END IF;
        NULL;
END Chk_plan_vers_have_same_RBS;

PROCEDURE GET_PROCESS_STATUS_MSG(
      p_project_id            IN  pa_projects_all.project_id%TYPE
    , p_structure_type        IN  pa_structure_types.structure_type%TYPE := NULL
    , p_structure_version_id  IN  pa_proj_element_versions.element_version_id%TYPE := NULL
    , p_prg_flag              IN  VARCHAR2 := NULL
    , x_message_name          OUT  NOCOPY VARCHAR2
    , x_message_type          OUT  NOCOPY VARCHAR2
	, x_structure_version_id  OUT NOCOPY NUMBER
	, x_conc_request_id       OUT NOCOPY NUMBER
	, x_return_status 		  IN OUT NOCOPY VARCHAR2
	, x_msg_count 			  IN OUT NOCOPY NUMBER
	, x_msg_data 			  IN OUT NOCOPY VARCHAR2)
IS

CURSOR  struct_list(c_structure_version_id pa_proj_element_versions.element_version_id%TYPE
		     , c_structure_type VARCHAR2) IS
SELECT vs.element_version_id, vs.project_id
FROM pa_proj_elem_ver_structure vs
     , pji_xbs_denorm denorm
WHERE denorm.struct_version_id IS NULL
AND denorm.struct_type = 'PRG'
AND NVL(denorm.relationship_type,'WF') IN ('WF',c_structure_type)
AND denorm.sup_id = c_structure_version_id
AND denorm.sub_id = vs.element_version_id;

l_relationship_type VARCHAR2(2);
l_project_id            pa_projects_all.project_id%TYPE;
l_structure_version_id  pa_proj_element_versions.element_version_id%TYPE;

BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Get_Process_Status_Msg: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	IF p_prg_flag = 'N' THEN
		Pa_Project_Structure_Utils.GET_STRUCTURE_MSG(
		      p_project_id => p_project_id
		    , p_structure_type => p_structure_type
		    , p_structure_version_id => p_structure_version_id
		    , x_message_name => x_message_name
		    , x_message_type => x_message_type
			, x_structure_version_id => x_structure_version_id
			, x_conc_request_id => x_conc_request_id);

		RETURN;
	ELSE
		IF p_structure_type = 'WORKPLAN' THEN
		   l_relationship_type := 'LW';
		ELSE
		   l_relationship_type := 'LF';
		END IF;

		OPEN struct_list(p_structure_version_id,l_relationship_type);

	    LOOP
	      FETCH struct_list INTO l_structure_version_id,l_project_id;
	      EXIT WHEN struct_list%NOTFOUND;
			Pa_Project_Structure_Utils.GET_STRUCTURE_MSG(
			      p_project_id => l_project_id
			    , p_structure_type => p_structure_type
			    , p_structure_version_id => l_structure_version_id
			    , x_message_name => x_message_name
			    , x_message_type => x_message_type
				, x_structure_version_id => x_structure_version_id
				, x_conc_request_id => x_conc_request_id);
	      IF x_message_name IS NOT NULL THEN
	        CLOSE struct_list;
	        RETURN;
	      END IF;
	    END LOOP;
		CLOSE struct_list;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Get_Process_Status_Msg: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
   WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Complete_Percentage');
	RAISE;
END Get_Process_Status_Msg;

PROCEDURE CHECK_PROJ_TYPE_CONSISTENCY
  ( p_project_id		IN	NUMBER
   ,p_wbs_version_id	IN  NUMBER
   ,p_structure_type	IN VARCHAR2 DEFAULT 'FINANCIAL'
   ,x_ptc_flag			OUT NOCOPY VARCHAR2 -- project type consistency flag
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2)
IS
l_relationship_type VARCHAR2(2);
l_proj_type_count NUMBER;
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Check_Proj_Type_Consistency: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	IF p_structure_type = 'WORKPLAN' THEN
	   l_relationship_type := 'LW';
	ELSE
	   l_relationship_type := 'LF';
	END IF;

	SELECT COUNT(DISTINCT UPPER(pt.project_type_class_code))
	INTO l_proj_type_count
	FROM pji_xbs_denorm denorm
		 ,pa_proj_elem_ver_structure vs
		 ,pa_projects_all proj
		 ,pa_project_types_all pt
	WHERE struct_type = 'PRG'
	AND sup_project_id = p_project_id
	AND struct_version_id IS NULL
	AND NVL(denorm.relationship_type,'WF') IN ('WF',l_relationship_type)
	AND denorm.sup_id = p_wbs_version_id
	AND denorm.sub_id = vs.element_version_id
	AND vs.project_id = proj.project_id
	AND proj.project_type = pt.project_type
	AND proj.org_id = pt.org_id ; --Added clause for performnace imp. for bug 5376591

	IF l_proj_type_count>1 THEN
	   x_ptc_flag := 'F';
	ELSE
	   x_ptc_flag := 'T';
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Check_Proj_Type_Consistency: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
   WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Check_Proj_Type_Consistency');
	RAISE;
END Check_Proj_Type_Consistency;




PROCEDURE Derive_Pji_Calendar_Info(
p_project_id IN	NUMBER
, p_period_type IN VARCHAR2
, p_as_of_date IN NUMBER
, x_calendar_type IN OUT NOCOPY VARCHAR2
, x_calendar_id   OUT NOCOPY NUMBER
, x_period_name  OUT NOCOPY VARCHAR2
, x_report_date_julian  OUT NOCOPY NUMBER
, x_slice_name OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
l_gl_calendar_id NUMBER;
l_pa_calendar_id NUMBER;

BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_pji_calendar_info: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

   SELECT info.gl_calendar_id, info.pa_calendar_id
   INTO l_gl_calendar_id, l_pa_calendar_id
   FROM pji_org_extr_info info, pa_projects_all proj
   WHERE info.org_id = proj.org_id
   AND proj.project_id = p_project_id;

	IF x_calendar_type IS NULL THEN
		IF p_period_type = 'FII_TIME_CAL_PERIOD' OR p_period_type = 'FII_TIME_CAL_QTR'
		   OR p_period_type = 'FII_TIME_CAL_YEAR' THEN
		   x_calendar_type := 'G';
		   x_calendar_id := l_gl_calendar_id;
		ELSIF p_period_type = 'PJI_TIME_PA_PERIOD' THEN
		   x_calendar_type := 'P';
		   x_calendar_id := l_pa_calendar_id;
		ELSE
		   x_calendar_type := 'E';
		   x_calendar_id := -1;
		END IF;
	ELSE
		IF x_calendar_type = 'E' THEN
		   x_calendar_id := -1;
		ELSE
		   IF x_calendar_type = 'G' THEN
		      x_calendar_id := l_gl_calendar_id;
		   ELSE
		   	  x_calendar_id := l_pa_calendar_id;
		   END IF;
		END IF;
	END IF;

	IF x_calendar_type = 'E' THEN
	   SELECT name,TO_CHAR(start_date,'j')
	   INTO x_period_name, x_report_date_julian
	   FROM pji_time_ent_period_v
	   WHERE TO_DATE(p_as_of_date, 'j') BETWEEN start_date AND end_date;
	ELSE
	   SELECT name,TO_CHAR(start_date,'j')
	   INTO x_period_name, x_report_date_julian
	   FROM pji_time_cal_period_v
	   WHERE calendar_id = x_calendar_id
	   AND TO_DATE(p_as_of_date,'j') BETWEEN start_date AND end_date;
	END IF;

	IF x_report_date_julian IS NULL THEN
	   x_report_date_julian :=2;
	END IF;

	Derive_Slice_Name(p_project_id,
	x_calendar_id,
	x_slice_name,
	x_return_status,
	x_msg_count,
	x_msg_data);

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_pji_calendar_info: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Pji_Calendar_Info');
	x_report_date_julian :=2;
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Pji_Calendar_Info');
	x_report_date_julian :=2;
	RAISE;
END Derive_Pji_Calendar_Info;

PROCEDURE Derive_Pji_Currency_Info(
p_project_id NUMBER
, p_currency_record_type IN VARCHAR2
, x_currency_record_type OUT NOCOPY NUMBER
, x_currency_code OUT NOCOPY VARCHAR2
, x_currency_type OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
l_projfunc_currency_code VARCHAR2(15);
l_project_currency_code VARCHAR2(15);
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_pji_currency_info: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	x_currency_record_type := p_currency_record_type;

	IF p_currency_record_type = 1 THEN
	   x_currency_code := Pji_Utils.get_global_primary_currency;
	   x_currency_type := 'G';
	ELSIF p_currency_record_type = 2 THEN
	   x_currency_type := 'G';
	   x_currency_code := Pji_Utils.get_global_secondary_currency;
	ELSE
		SELECT projfunc_currency_code, project_currency_code
		INTO l_projfunc_currency_code,l_project_currency_code
		FROM pa_projects_all
		WHERE project_id = p_project_id;

		IF p_currency_record_type = 4 THEN
		   x_currency_code := l_projfunc_currency_code;
		   x_currency_type := 'F';
		ELSE
		   x_currency_code := l_project_currency_code;
		   x_currency_type := 'P';
		END IF;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_pji_currency_info: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Pji_Currency_Info');
	RAISE;
END Derive_Pji_Currency_Info;


PROCEDURE Validate_Plan_Type(p_project_id NUMBER
, p_plan_type_id NUMBER
, x_plan_type_id IN OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
l_plan_type_count NUMBER;
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'validate_plan_type: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	SELECT COUNT(*)
	INTO l_plan_type_count
	FROM pa_proj_fp_options
	WHERE project_id = p_project_id
	AND fin_plan_type_id = p_plan_type_id
	AND fin_plan_option_level_code = 'PLAN_TYPE'
	AND ROWNUM =1;

	IF l_plan_type_count > 0 THEN
	   x_plan_type_id := p_plan_type_id;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'validate_plan_type: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Validate_Plan_Type');
	RAISE;
END Validate_Plan_Type;

FUNCTION is_str_linked_to_working_ver
(p_project_id NUMBER
 , p_structure_version_id NUMBER
 , p_relationship_type VARCHAR2 := 'LW') return VARCHAR2
is
l_return_value VARCHAR2(1) := null;
l_count NUMBER;
BEGIN
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'is_str_linked_to_working_ver: beginning', TRUE , g_proc);
	END IF;

	l_return_value := 'Y';

	Select count(*)
	INTO l_count
	FROM
		  pji_xbs_denorm denorm
		, pa_proj_elements elem
		, pa_proj_elem_ver_structure ppevs
	WHERE 1=1
	AND denorm.sup_project_id = p_project_id
	AND denorm.sup_id = p_structure_version_id
	AND denorm.struct_type = 'PRG'
	AND NVL(denorm.relationship_type,'WF') IN (p_relationship_type,'WF')
	AND denorm.struct_version_id IS NULL
	AND denorm.sub_emt_id = elem.proj_element_id
	AND ppevs.project_id = elem.project_id
	AND ppevs.element_version_id = denorm.sub_id
	AND ppevs.status_code = 'STRUCTURE_WORKING';

	IF l_count = 0 THEN
	   l_return_value := 'N';
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'is_str_linked_to_working_ver: finishing', TRUE , g_proc);
	END IF;

	return(l_return_value);
EXCEPTION
	WHEN OTHERS THEN
	l_return_value := 'N';
	return(l_return_value);

END IS_STR_LINKED_TO_WORKING_VER;

FUNCTION Get_Page_Pers_Function_Name
(p_project_type             VARCHAR2
,p_page_type            VARCHAR2) return VARCHAR2
IS
l_return_value VARCHAR2(255) := null;
BEGIN
  IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Get_Page_Pers_Function_Name : Start', TRUE , g_proc);
  END IF;

 IF p_project_type = 'CONTRACT' THEN
    SELECT ATTRIBUTE12 into l_return_value
         FROM   pa_lookups
	 WHERE  lookup_code = p_page_type and lookup_type='PA_PAGE_TYPES';
  ELSIF p_project_type = 'INDIRECT' THEN
    SELECT ATTRIBUTE13 into l_return_value
	 FROM   pa_lookups
	 WHERE  lookup_code = p_page_type and lookup_type='PA_PAGE_TYPES';
   ELSIF p_project_type = 'CAPITAL' THEN
     SELECT ATTRIBUTE14 into l_return_value
         FROM   pa_lookups
	 WHERE  lookup_code = p_page_type and lookup_type='PA_PAGE_TYPES';
 END IF;

    IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Get_Page_Pers_Function_Name : Finish', TRUE , g_proc);
    END IF;

 return(l_return_value);

EXCEPTION
	WHEN OTHERS THEN
	return(l_return_value);

END Get_Page_Pers_Function_Name;

--bug 7602538
PROCEDURE drv_prf_prd(
p_from_date IN VARCHAR2,
p_to_date IN VARCHAR2,
x_from_period OUT NOCOPY NUMBER,
x_to_period OUT NOCOPY NUMBER)
IS
l_from_date DATE := NULL;
l_to_date  DATE := NULL;
BEGIN
l_from_date := to_date(p_from_date, 'YYYY-MM-DD');
l_to_date := to_date(p_to_date, 'YYYY-MM-DD');

x_from_period    := TO_CHAR(l_from_date,'j');
x_to_period    := TO_CHAR(l_to_date,'j');

END drv_prf_prd;

--bug 5612955
FUNCTION get_default_calendar_type return VARCHAR2 IS

l_calendar_type VARCHAR2(10);

cursor c1 is
SELECT NVL(Fnd_Profile.value('PJI_DEF_RPT_CAL_TYPE'), 'E') FROM dual;  -- Based on profile "PJI: Default Reporting Calendar Type"

begin

open c1;
fetch c1 into l_calendar_type;
close c1;

return l_calendar_type;
END get_default_calendar_type;

FUNCTION get_default_period_name
  ( p_project_id IN NUMBER) return VARCHAR2
  IS

l_calendar_type VARCHAR2(1);

l_calendar_id NUMBER;
l_report_date_julian NUMBER;


l_period_name VARCHAR2(255);

l_slice_name VARCHAR2(80);
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(50);


cursor c1 is
SELECT NVL(Fnd_Profile.value('PJI_DEF_RPT_CAL_TYPE'), 'E') FROM dual; -- Based on Profile : PJI: Default Reporting Calendar Type

begin

open c1;
fetch c1 into l_calendar_type;
close c1;

Derive_Pa_Calendar_Info(p_project_id,l_calendar_type,l_calendar_id,l_report_date_julian,l_period_name,l_slice_name,l_return_status,l_msg_count,l_msg_data);

return Upper(l_period_name);
END get_default_period_name;

 -- API name                      : GET_TASK_LATEST_PUBLISHED_COST
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Get the task latest published cost value
--
--
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_task_id                   IN NUMBER
--
--  History
--
--  26-FEB-09   rbruno    -Created


FUNCTION GET_TASK_LATEST_PUBLISHED_COST
  ( p_project_id IN NUMBER, p_task_id in NUMBER
  ) return NUMBER
  IS

CURSOR c2 IS



SELECT Sum(brdn_cost) LATEST_PUBLISHED_COST

FROM pji_fp_xbs_accum_f f,
pa_projects_all p,
pa_rbs_prj_assignments r,
pa_proj_elem_ver_structure s,
pa_proj_element_versions ppev,
pji_pjp_wbs_header h
WHERE p.project_id=f.project_id
AND p.project_id=r.project_id
AND p.project_id=s.project_id
AND p.project_id=ppev.project_id
AND p.project_id=h.project_id
AND f.rbs_version_id=-1
AND f.project_id= p_project_id
AND f.project_element_id = p_task_id
AND f.currency_code=p.projfunc_currency_code
AND f.rbs_aggr_level='T'
AND f.prg_rollup_flag='N'
AND f.period_type_id=32
AND f.plan_type_id=10
AND h.wp_flag='Y'
AND s.latest_eff_published_flag='Y'
AND s.element_version_id=h.wbs_version_id
AND s.element_version_id=ppev.element_version_id
AND ppev.object_type='PA_STRUCTURES'
AND f.plan_version_id=h.plan_version_id
AND r.WP_USAGE_FLAG = 'Y'
AND f.rbs_version_id = -1
AND f.rbs_element_id = -1


GROUP BY
p.project_id,
f.project_element_id,
f.calendar_type,
f.period_type_id,
f.curr_record_type_id,
f.plan_type_id,
f.plan_version_id,
f.rbs_version_id;

   l_latest_published_cost NUMBER;
  BEGIN
    OPEN c2;
    FETCH c2 into l_latest_published_cost;
    CLOSE c2;

    return Nvl(l_latest_published_cost,0);
  END GET_TASK_LATEST_PUBLISHED_COST;

FUNCTION GET_TASK_BASELINE_COST
   ( p_project_id IN NUMBER, p_task_id in NUMBER) return NUMBER
  IS
    CURSOR c1 IS

SELECT Sum(f.brdn_cost) BASELINE_COST
FROM
 pji_fp_xbs_accum_f f,
 pa_projects_all p,
 PA_PROJ_ELEM_VER_STRUCTURE ppev,
 pji_pjp_wbs_header h
WHERE
 p.project_id = p_project_id AND
 p.project_id=f.project_id AND
 f.project_element_id = p_task_id AND
 p.project_id = ppev.project_id AND
 p.project_id = h.project_id AND
 f.currency_code=p.projfunc_currency_code AND
 f.rbs_aggr_level='T' AND
 f.period_type_id=32 AND
 f.plan_type_id=10 AND
 f.prg_rollup_flag='N' AND
 ppev.ELEMENT_VERSION_ID = h.wbs_version_id AND
 ppev.CURRENT_flag = 'Y' AND --current baseline
 h.wp_flag='Y' AND
 f.plan_version_id=h.plan_version_id AND
 f.rbs_version_id = -1 AND
 f.rbs_element_id = -1
GROUP BY f.project_id,f.project_element_id;

  l_baseline_cost NUMBER;


  BEGIN
    OPEN c1;
    FETCH c1 into l_baseline_cost;
    CLOSE c1;
    return l_baseline_cost;
  END GET_TASK_BASELINE_COST;

END Pji_Rep_Util;

/
