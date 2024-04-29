--------------------------------------------------------
--  DDL for Package Body PA_PAGE_LAYOUT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAGE_LAYOUT_UTILS" AS
/* $Header: PAPGLUTB.pls 120.1.12010000.4 2010/04/22 20:51:31 snizam ship $ */

PROCEDURE VALIDATE_PARAMETERS ( p_object_type           IN     VARCHAR2	,
	                        P_object_id_from        IN     number	,
		                P_object_id_to          IN     number	,
			        x_return_status         OUT    NOCOPY VARCHAR2	, --File.Sql.39 bug 4440895
				x_msg_count             OUT    NOCOPY NUMBER	, --File.Sql.39 bug 4440895
	                        x_msg_data              OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
   CURSOR c_project_exists (p_project_id in number)
   IS
   SELECT project_id
   FROM pa_projects_all
   WHERE project_id = p_project_id;
   l_dummy    number;

BEGIN
       x_return_status:=fnd_api.g_ret_sts_success;

       IF (p_object_type = 'PA_PROJECTS') THEN
         -- Validate project_id_from
         OPEN c_project_exists (p_object_id_from);
         FETCH c_project_exists INTO l_dummy;
         IF(c_project_exists%NOTFOUND) THEN
            PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_INVALID_PROJECT_ID');
             x_return_status := FND_API.G_RET_STS_ERROR;
             --x_ret_code:= fnd_api.g_false;
             x_msg_count     := x_msg_count + 1;
         END IF;
         CLOSE c_project_exists;

          -- Validate project_id_to
         OPEN c_project_exists (p_object_id_to);
         FETCH c_project_exists INTO l_dummy;
         IF(c_project_exists%NOTFOUND) THEN
            PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_INVALID_PROJECT_ID');
             x_return_status := FND_API.G_RET_STS_ERROR;
             --x_ret_code:= fnd_api.g_false;
             x_msg_count     := x_msg_count + 1;
         END IF;
         CLOSE c_project_exists;
     END IF;
 EXCEPTION
        WHEN OTHERS THEN
          IF ( c_project_exists%ISOPEN ) THEN
              close c_project_exists;
          END IF;
          FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_LAYOUT_UTILS'
                                   ,p_procedure_name => PA_DEBUG.G_Err_Stack );
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          --x_ret_code:= fnd_api.g_false;
END VALIDATE_PARAMETERS;


PROCEDURE COPY_OBJECT_PAGE_LAYOUTS(
                        p_object_type           IN     VARCHAR2,
                        P_object_id_from        IN     number  ,
                        P_object_id_to          IN     number  ,
		--	p_function_name         IN     VARCHAR2,	Bug 3665562.
                        x_return_status         OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count             OUT    NOCOPY NUMBER  , --File.Sql.39 bug 4440895
                        x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                        )
IS

l_object_page_layout_id NUMBER;
v_proj_start_date date; /* Bug8732869 */


CURSOR obj_page_layout
IS
   SELECT
	  page_type_code
	, page_id
	, approval_required
	, reporting_cycle_id
	, report_offset_days
	, reminder_days
	, reminder_days_type
	, initial_progress_status
	, final_progress_status
	, rollup_progress_status
	, report_type_id
	, approver_source_id
	, approver_source_type
	, effective_from
	, effective_to
	, object_page_layout_id
	, pers_function_name
   FROM pa_object_page_layouts
   WHERE object_type = p_object_type
   AND object_id = p_object_id_from;

CURSOR obj_regions
IS
   SELECT
	  placeholder_reg_code
	, replacement_reg_code
   FROM pa_object_regions
   where object_type = p_object_type
   and object_id = p_object_id_from;

l_commit_flag		varchar2(1) := 'Y';
l_next_reporting_date	Date ; -- Added for Bug 3026572
l_rep_start_date	Date; -- Added for Bug 3026572

BEGIN
   PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_UTILS.copy_project_page_layouts');
   --x_ret_code:= fnd_api.g_true;
   x_return_status:=fnd_api.g_ret_sts_success;
   savepoint copy_object_page_layouts;



   VALIDATE_PARAMETERS( p_object_type           => p_object_type	,
                        P_object_id_from        => P_object_id_from	,
                        P_object_id_to          => P_object_id_to	,
                        x_return_status         => x_return_status	,
                        x_msg_count             => x_msg_count		,
                        x_msg_data              => x_msg_data
			);

   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
       -- Insert the object page layouts for the new object ID

       FOR obj_page_layout_rec in obj_page_layout LOOP
		/* Bug 3026572 Begin */

		-- This call is made to simulate the same effect as user is trying to update the reporting cycle and
		-- PA_PROGRESS_REPORT_PVT.define_progress_report_setup is getting called

		IF obj_page_layout_rec.page_type_code = 'PPR' AND obj_page_layout_rec.reporting_cycle_id IS NOT NULL THEN

			-- Note that in p_object_type intentionally null is passed instead of actual object type,
			-- so that it does not return the From Project's next reporting date but the actual next
			-- reporting date for the To project

			PA_PROGRESS_REPORT_UTILS.GET_REPORT_START_END_DATES(
				p_Object_Type           => null						,
		                p_Object_Id             => p_object_id_from				,
			        p_report_type_id        => obj_page_layout_rec.report_type_id		,
			        p_Reporting_Cycle_Id    => obj_page_layout_rec.reporting_cycle_id	,
			        p_Reporting_Offset_Days => obj_page_layout_rec.report_offset_days	,
		                p_Publish_Report        => 'N'						,
			        p_report_effective_from => obj_page_layout_rec.effective_from		,
		                x_Report_Start_Date     => l_rep_start_date				,
			        x_Report_End_Date       => l_next_reporting_date
				);


		ELSE
			l_next_reporting_date := null;
		END IF;
		/* Bug 3026572 End */
select start_date into v_proj_start_date from pa_projects_all where project_id=P_object_id_to; /* Bug8732869 */



	        PA_PROGRESS_REPORT_PKG.INSERT_OBJECT_PAGE_LAYOUT_ROW (
		         P_OBJECT_ID			=> p_object_id_to				,
			 P_OBJECT_TYPE			=> p_object_type				,
			 P_PAGE_ID			=> obj_page_layout_rec.page_id			,
	                 P_PAGE_TYPE_CODE		=> obj_page_layout_rec.page_type_code		,
		         P_APPROVAL_REQUIRED		=> obj_page_layout_rec.approval_required	,
			 P_REPORTING_CYCLE_ID		=> obj_page_layout_rec.reporting_cycle_id	,
	                 P_REPORTING_OFFSET_DAYS	=> obj_page_layout_rec.report_offset_days	,
		         P_NEXT_REPORTING_DATE		=> l_next_reporting_date			, -- to_date(null), Bug 3026572
	                 P_REMINDER_DAYS		=> obj_page_layout_rec.reminder_days		,
		         P_REMINDER_DAYS_TYPE		=> obj_page_layout_rec.REMINDER_DAYS_TYPE	,
	                 P_INITIAL_PROGRESS_STATUS	=> obj_page_layout_rec.INITIAL_PROGRESS_STATUS	,
		         P_FINAL_PROGRESS_STATUS	=> obj_page_layout_rec.FINAL_PROGRESS_STATUS	,
	                 P_ROLLUP_PROGRESS_STATUS	=> obj_page_layout_rec.ROLLUP_PROGRESS_STATUS	,
			 P_REPORT_TYPE_ID		=> obj_page_layout_rec.report_type_id		,
			 P_APPROVER_SOURCE_ID		=> obj_page_layout_rec.approver_source_id	,
			 P_APPROVER_SOURCE_TYPE		=> obj_page_layout_rec.approver_source_type	,
			 P_EFFECTIVE_FROM		=> nvl(v_proj_start_date, obj_page_layout_rec.effective_from)	, /* Bug8732869 */
		         P_EFFECTIVE_TO			=> obj_page_layout_rec.effective_to		,
			 --P_FUNCTION_NAME		=> obj_page_layout_rec.effective_to		, Bug 3665562 Incorrect value passed.
			 P_FUNCTION_NAME		=> obj_page_layout_rec.pers_function_name	, -- Pass the correct value.
		         X_OBJECT_PAGE_LAYOUT_ID	=> l_object_page_layout_id			,
			 X_RETURN_STATUS		=> x_return_status				,
		         X_MSG_COUNT			=> x_msg_count					,
	                 X_MSG_DATA			=> x_msg_data
		        );

	        PA_DISTRIBUTION_LIST_UTILS.COPY_DIST_LIST(
			 p_object_type_from => 'PA_OBJECT_PAGE_LAYOUT'			,
	                 p_object_id_from   => obj_page_layout_rec.object_page_layout_id,
		         p_object_type_to   => 'PA_OBJECT_PAGE_LAYOUT'			,
			 p_object_id_to     => l_object_page_layout_id			,
	                 x_return_status    => x_return_status				,
	                 x_msg_count        => x_msg_count				,
	                 x_msg_data         => x_msg_data
	                 );

  		IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
                  l_commit_flag := 'N';
	        END IF;
	END LOOP;

	/* Copy the object_regions */

	FOR obj_regions_rec in obj_regions LOOP
          PA_OBJECT_REGIONS_PKG.INSERT_ROW (
                 P_OBJECT_ID		=> p_object_id_to			,
                 P_OBJECT_TYPE		=> p_object_type			,
                 P_PLACEHOLDER_REG_CODE => obj_regions_rec.PLACEHOLDER_REG_CODE	,
                 P_REPLACEMENT_REG_CODE => obj_regions_rec.REPLACEMENT_REG_CODE	,
                 P_CREATION_DATE        => sysdate				,
                 P_CREATED_BY           => fnd_global.user_id			,
                 P_LAST_UPDATE_DATE     => sysdate				,
                 P_LAST_UPDATED_BY      => fnd_global.user_id			,
                 P_LAST_UPDATE_LOGIN    => fnd_global.user_id
                );
          IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
                  l_commit_flag := 'N';
          END IF;
        END LOOP;

	IF (l_commit_flag = 'N') THEN
             ROLLBACK TO copy_object_page_layouts;
        END IF;
  END IF;

  PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
    WHEN OTHERS THEN
          ROLLBACK TO copy_object_page_layouts;
          FND_MSG_PUB.add_exc_msg ( p_pkg_name	  => 'PA_page_layout_utils.copy_object_page_layouts',
                                    p_procedure_name => PA_DEBUG.G_Err_Stack );

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END COPY_OBJECT_PAGE_LAYOUTS;

/* This is the function to check customer and project value columns
    exists in the project header at the project level. This is for the
    temporary solution to fix the project Header section in progress report
    based on the Header section shown at the project level  */

PROCEDURE CHECK_COLS_IN_PROJ_HEADER(
                        p_object_type	    IN     VARCHAR2	,
		        p_object_id         IN     number	,
                        x_customer_exists   OUT NOCOPY varchar2	, --File.Sql.39 bug 4440895
                        x_proj_val_exists   OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
			             )
IS
  CURSOR C IS
  SELECT replacement_reg_code
  FROM pa_object_regions
  WHERE object_type = p_object_type
  AND object_id = P_object_id
  --AND placeholder_reg_code = 'PA_PROJECT_INFO'; --Bug 3745737
  AND placeholder_reg_code = '/oracle/apps/pa/project/webui/ProjectInfoRN';

  l_replacement_reg_code  pa_object_regions.replacement_reg_code%TYPE := null;

BEGIN
  -- Initialize the out parameters
  x_customer_exists := 'N';
  x_proj_val_exists := 'N';

  OPEN C;
  FETCH C INTO l_replacement_reg_code;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    return;
  END IF;
  CLOSE C;

  --IF ( l_replacement_reg_code = 'PA_PROJECT_INFO_2') THEN --Bug 3745737
  IF ( l_replacement_reg_code = '/oracle/apps/pa/project/webui/ProjectInfo2RN') THEN
     x_customer_exists := 'Y';
     x_proj_val_exists := 'Y';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(C%ISOPEN) THEN
      CLOSE C;
    END IF;
    x_customer_exists := 'N';
    x_proj_val_exists := 'N';
END CHECK_COLS_IN_PROJ_HEADER;


FUNCTION GET_AK_REGION_CODE
  (
   p_region_name IN VARCHAR2,
   p_application_id IN NUMBER
   )  RETURN VARCHAR2
IS

      l_region_code VARCHAR2(30);

      /*
      CURSOR get_region_code is
	SELECT region_code
	FROM ak_regions_vl
	WHERE name = p_region_name
	AND region_application_id = p_application_id;
	*/

BEGIN
	   /*
    OPEN get_region_code;
    FETCH get_region_code INTO l_region_code;
    IF get_region_code%notfound THEN
       CLOSE get_region_code;
       RETURN NULL;
    END IF;
    CLOSE get_region_code;

      RETURN l_region_code;
      */
      RETURN NULL;

END GET_AK_REGION_CODE;


FUNCTION GET_REGION_SOURCE_CODE
  (
   p_region_source_name IN VARCHAR2	,
   p_region_source_type IN VARCHAR2	,
   p_application_id IN NUMBER		,
   p_flex_name IN VARCHAR2
   )  RETURN VARCHAR2
IS

      l_region_source_code VARCHAR2(30);

/*      CURSOR get_region_code is
	SELECT region_code
	FROM ak_regions_vl
	WHERE name = p_region_source_name
	  AND region_application_id = p_application_id;
	  */


      CURSOR get_flex_code is
	SELECT
		descriptive_flex_context_code
	FROM fnd_descr_flex_contexts_vl
	WHERE application_id = p_application_id
	AND descriptive_flexfield_name = p_flex_name
	AND descriptive_flex_context_name = p_region_source_name;

 BEGIN
    IF p_region_source_type = 'STD' THEN

/*       OPEN get_region_code;
       FETCH get_region_code INTO l_region_source_code;
       IF get_region_code%notfound THEN
	  CLOSE get_region_code;
	  RETURN NULL;
       END IF;
       CLOSE get_region_code;

	 RETURN l_region_source_code;*/
	 RETURN NULL;

    ELSIF p_region_source_type = 'DFF' THEN

       OPEN get_flex_code;
       FETCH get_flex_code INTO l_region_source_code;
       IF get_flex_code%notfound THEN
	  CLOSE get_flex_code;
	  RETURN NULL;
       END IF;
       CLOSE get_flex_code;

       RETURN l_region_source_code;
     ELSE
       RETURN NULL;
    END IF;

 END get_region_source_code;


FUNCTION IS_PAGE_TYPE_REGION_DELETABLE(
					p_page_type_code IN VARCHAR2	,
					p_region_source_type IN VARCHAR2,
					p_region_source_code IN VARCHAR2)

   RETURN VARCHAR2
IS

     CURSOR get_page_layout
	IS
	   SELECT ppl.page_id FROM
	     pa_page_layouts ppl, pa_page_layout_regions pplr
	     WHERE ppl.page_id = pplr.page_id
	     AND ppl.page_type_code = p_page_type_code
	     AND pplr.region_source_type = p_region_source_type
	     AND pplr.region_source_code = p_region_source_code;
      l_page_id NUMBER;

      l_ret VARCHAR2(1) := 'Y';
 BEGIN
    OPEN get_page_layout;
    FETCH get_page_layout INTO l_page_id;

    IF (get_page_layout%notfound) THEN
       l_ret := 'Y';
     ELSE
       l_ret := 'N';
    END IF;

    CLOSE get_page_layout;

    RETURN l_ret;

END is_page_type_region_deletable;


FUNCTION GET_CONTEXT_NAME(
			   p_context_code IN VARCHAR2
			   )
   RETURN VARCHAR2
IS

      CURSOR get_name IS
      SELECT descriptive_flex_context_name
      FROM fnd_descr_flex_contexts_vl
      WHERE descriptive_flexfield_name = 'PA_STATUS_REPORT_DESC_FLEX'
      AND descriptive_flex_context_code =  p_context_code
      AND application_id = fnd_global.resp_appl_id;        /* Added for for Bug 2634995 */

      l_context_name  VARCHAR2(80);   --Bug 9585564 Increased the size


BEGIN
    OPEN get_name;
    FETCH get_name INTO l_context_name;
    CLOSE get_name;

    RETURN l_context_name;

END GET_CONTEXT_NAME;


PROCEDURE CHECK_PAGELAYOUT_NAME_OR_ID (
					p_pagelayout_name	IN	VARCHAR2 :=FND_API.G_MISS_CHAR	,
					p_pagetype_code		IN	VARCHAR2 :=FND_API.G_MISS_CHAR	,
					p_check_id_flag		IN	VARCHAR2 := 'A'			,
					x_pagelayout_id		IN OUT	NOCOPY NUMBER				, --File.Sql.39 bug 4440895
					x_return_status		OUT	NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
					x_error_message_code	OUT	NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

    IF (x_pagelayout_id IS NOT NULL) THEN
       IF (x_pagelayout_id >0 AND p_check_id_flag = 'Y') THEN
			SELECT page_id
	      	  	INTO   x_pagelayout_id
	        	FROM   pa_page_layouts
	        	WHERE  page_id = x_pagelayout_id;
       ELSIF (p_check_id_flag = 'N') THEN
           -- No ID validation is required
              x_pagelayout_id := x_pagelayout_id;
       ELSIF(p_check_id_flag = 'A') THEN
         IF (p_pagelayout_name is null) THEN
            x_pagelayout_id := null;
         ELSE
           --Find the Id for the name
            SELECT page_id
                INTO   x_pagelayout_id
                FROM   pa_page_layouts
	      WHERE  page_name = p_pagelayout_name
	      AND page_type_code = p_pagetype_code;

         END IF;
       END IF;
    ELSE
       IF (p_pagelayout_name is not null) THEN
		SELECT page_id
        	INTO   x_pagelayout_id
        	FROM   pa_page_layouts
		  WHERE  page_name = p_pagelayout_name
		  AND page_type_code = p_pagetype_code;
       ELSE
          x_pagelayout_id := null;
       END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
	        x_return_status := FND_API.G_RET_STS_ERROR;
    		x_error_message_code := 'PA_INV_PAGE_NAME';
        WHEN TOO_MANY_ROWS THEN
	        x_return_status := FND_API.G_RET_STS_ERROR;
    		x_error_message_code := 'PA_INV_PAGE_NAME';
        WHEN OTHERS THEN
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END;


FUNCTION CHECK_PAGE_LAYOUT_DELETABLE (p_page_id NUMBER)
    RETURN VARCHAR2
IS
          CURSOR c_object_layout_referenced
          IS
          SELECT 'X'
	  FROM pa_object_page_layouts
          WHERE page_id = p_page_id;

  -- Bug 3454743 : Added the below cursor
          CURSOR c_report_type_referenced
          IS
          Select 'X'
          FROM pa_report_types
          WHERE page_id = p_page_id;

          CURSOR c_page_type IS
          SELECT page_type_code
          FROM pa_page_layouts
          WHERE page_id = p_page_id;

          /*
	  CURSOR c_profile_refernce IS
          SELECT 'X'
	  FROM fnd_profile_options po,
	       fnd_profile_option_values pov
	  WHERE po.application_id = 275
	  AND po.profile_option_name = 'PA_TEAM_HOME_PAGELAYOUT'
	  AND po.profile_option_id = pov.profile_option_id
          AND pov.application_id = 275
	  AND to_number(pov.profile_option_value) = p_page_id;
	  */

         l_dummy varchar2(1);
         l_deletable_flag varchar2(1) := 'Y';
         l_page_type_code pa_page_layouts.page_type_code%TYPE;

BEGIN
           -- The seeded page layout is not deletable
           IF (p_page_id < 1000) THEN
             l_deletable_flag := 'N';
             return l_deletable_flag;
           END IF;

	   OPEN c_page_type;
             FETCH c_page_type into l_page_type_code;
           CLOSE c_page_type;

	   OPEN c_object_layout_referenced;
           FETCH c_object_layout_referenced into l_dummy;
           IF (c_object_layout_referenced%FOUND) THEN
              --l_deletable_flag := 'N';
	      IF (l_page_type_code = 'PPR') THEN
		l_deletable_flag := 'N';
	      END IF;
              CLOSE c_object_layout_referenced;
              return l_deletable_flag;
           END IF;
           CLOSE c_object_layout_referenced;

  -- Bug 3454743 : Added the below check
           OPEN c_report_type_referenced;
           FETCH c_report_type_referenced into l_dummy;
           IF (c_report_type_referenced%FOUND) THEN
              l_deletable_flag := 'N';
              CLOSE c_report_type_referenced;
              return l_deletable_flag;
           END IF;
           CLOSE c_report_type_referenced;

           /*
	   -- If deletable check for reference in pa_task_types
           IF(pa_task_type_utils.check_page_layout_referenced(p_page_id)) THEN
              l_deletable_flag := 'N';
           END IF;

           -- Added for Project Team member home stored in profiles
           IF (l_deletable_flag = 'Y') THEN
            -- get the page type code
             OPEN c_page_type;
             FETCH c_page_type into l_page_type_code;
             CLOSE c_page_type;
            -- Proceed forward only if page type is Team Home
            IF (l_page_type_code = 'TM') THEN
               OPEN c_profile_refernce;
               FETCH c_profile_refernce INTO l_dummy;
               IF (c_profile_refernce%FOUND) THEN
                  l_deletable_flag := 'N';
               END IF;
               CLOSE c_profile_refernce;
            END IF;
           END IF;
	   */
           return l_deletable_flag;
END CHECK_PAGE_LAYOUT_DELETABLE;

FUNCTION GET_PAGE_ID_FROM_FUNCTION(
			p_page_type_code	IN	VARCHAR2,
			p_pers_function_name	IN	VARCHAR2
			)
return NUMBER
IS
	Cursor c_get_page_id(v_page_type_code VARCHAR2, v_function_name VARCHAR2)
	Is
	Select page_id
	From pa_page_layouts
	Where page_type_code = v_page_type_code
	And pers_function_name = v_function_name;

	l_page_id NUMBER;
BEGIN
IF((p_page_type_code IS NULL)or(p_pers_function_name is null)) THEN
	return null;
END IF;

open c_get_page_id(p_page_type_code,p_pers_function_name);
fetch c_get_page_id into l_page_id;
close c_get_page_id;
return l_page_id;

END GET_PAGE_ID_FROM_FUNCTION;

PROCEDURE POPULATE_PERS_FUNCTIONS (p_page_type_code_tbl	   IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
				   p_function_name_tbl	   IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
				   x_return_status         OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			           x_msg_count             OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
			           x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				  )
IS
len NUMBER;
i NUMBER := 0;
l_debug_mode VARCHAR2(1);
g_module_name   VARCHAR2(100) := 'pa.plsql.POPULATE_PERS_FUNCTIONS';
l_debug_level5                   CONSTANT NUMBER := 5;
BEGIN
	x_msg_count := 0;
	x_return_status:=fnd_api.g_ret_sts_success;
	savepoint populate_pers_functions;

	l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

	IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'PERS_FUNCTIONS',
                                      p_debug_mode => l_debug_mode );
	END IF;

        DELETE FROM PA_PAGE_LAYOUTS_TMP;
	len := p_page_type_code_tbl.count;
	FORALL i in 1..len
		INSERT INTO PA_PAGE_LAYOUTS_TMP VALUES(p_page_type_code_tbl(i),p_function_name_tbl(i));

	EXCEPTION
	 WHEN OTHERS THEN
          ROLLBACK TO populate_pers_functions;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  x_msg_count     := 1;
	  x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg ( p_pkg_name	  => 'PA_page_layout_utils.populate_pers_functions',
                                    p_procedure_name => PA_DEBUG.G_Err_Stack );

           IF l_debug_mode = 'Y' THEN
	          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
	          pa_debug.reset_curr_function;
	   END IF;
	 RAISE;

END POPULATE_PERS_FUNCTIONS;

END PA_PAGE_LAYOUT_UTILS;

/
