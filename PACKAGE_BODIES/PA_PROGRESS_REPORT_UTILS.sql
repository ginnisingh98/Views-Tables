--------------------------------------------------------
--  DDL for Package Body PA_PROGRESS_REPORT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROGRESS_REPORT_UTILS" AS
 /* $Header: PAPRUTLB.pls 120.1 2005/08/19 16:45:25 mwasowic noship $ */
PROCEDURE GET_REPORT_START_END_DATES(
                p_Object_Type           IN  Varchar2,
                p_Object_Id             IN  Number,
                p_report_type_id        IN  Number,
                p_Reporting_Cycle_Id    IN  Number,
                p_Reporting_Offset_Days IN  Number,
		p_Publish_Report	IN  Varchar2,
                p_report_effective_from IN  Date := NULL,
	        x_Report_Start_Date     OUT NOCOPY Date, --File.Sql.39 bug 4440895
	        x_Report_End_Date       OUT NOCOPY Date) --File.Sql.39 bug 4440895

IS

Object_Type Varchar2(30) := p_Object_Type;
Object_Id Number := p_Object_Id;
Reporting_Cycle_Id Number := p_Reporting_Cycle_Id;
Reporting_Offset_Days Number := p_Reporting_Offset_Days;
Publish_Report_Flag Varchar2(1):= p_Publish_Report;
l_Last_Report_End_Date Date;
l_Report_End_Date Date;
l_Last_End_Date Date;
l_Project_Start_Date Date;
l_Report_Start_Date Date;

Cursor C is
select (MAX(Report_End_Date))
FROM PA_PROGRESS_REPORT_VERS
WHERE Object_Id = P_Object_Id
AND Object_Type = P_Object_Type
AND Report_Status_Code = decode(Publish_Report_Flag,'Y','PROGRESS_REPORT_PUBLISHED',Report_Status_Code);

Cursor C1 is
select (MAX(Report_End_Date))
FROM PA_PROGRESS_REPORT_VERS
WHERE Object_Id = P_Object_Id
AND Object_Type = P_Object_Type
AND report_type_id = p_report_type_id
AND Report_Status_Code = decode(Publish_Report_Flag,'Y','PROGRESS_REPORT_PUBLISHED',Report_Status_Code);

BEGIN
select NVL(Start_date, Creation_date)
INTO l_Project_Start_Date
FROM PA_PROJECTS_ALL
WHERE Project_Id = Object_Id;

if (p_report_type_id is null) then
   open C;
   fetch C into l_Last_Report_End_Date;
   close C;
else
   open C1;
   fetch C1 into l_Last_Report_End_Date;
   close C1;
end if;


IF l_Last_Report_End_Date IS NULL THEN
   if p_report_effective_from is not null then
                l_Report_Start_Date := p_report_effective_from;
                l_Report_End_Date := PA_Billing_Cycles_Pkg.Get_Billing_Date(Object_Id
                ,l_Report_Start_Date
                ,p_Reporting_Cycle_Id
                ,sysdate
                ,l_Last_Report_End_Date);
   elsif Object_Type = 'PA_PROJECTS' THEN

		l_Report_Start_Date := l_Project_Start_Date;
		l_Report_End_Date := NVL(l_Project_Start_Date, SYSDATE) + Reporting_Offset_Days;

   END IF;
ELSE
    l_Report_Start_Date := l_Last_Report_End_Date +1;
    l_Report_End_Date := PA_Billing_Cycles_Pkg.Get_Billing_Date(Object_Id
                                                        ,l_Report_Start_Date
                                                        ,p_Reporting_Cycle_Id
                                                        ,sysdate
                                                        ,l_Last_Report_End_Date);
END IF;

x_Report_Start_Date := l_Report_Start_Date;
x_Report_End_Date := l_Report_End_Date;

END GET_REPORT_START_END_DATES;

/* This function detremines the whether a particular action
   ia allowed or not on the progress report, based on the
   system status of the progres report
   IN PARAMETERS  p_current_rep_status - Current user status code of the report
                  p_action  - Action the user wants to perform.Possible values are
                            - 'REWORK'
                            - 'EDIT'
                            - 'SUBMIT'
                            - 'PUBLISH'
                            - 'CANCEL'
                   p_version_id - Version_id of the progress report
   OUT PARAMETERS x_ret_code - Y ; if action allowed, N- Action not allowed
                  x_retun_status - Success or Failure status
                  x_msg_count    - Exception message count
                  x_msg_data     - Exception message
    */

Function check_action_allowed
  (
   p_current_rep_status  IN  VARCHAR2,
   p_action_code         IN  VARCHAR2,
   p_version_id          IN  NUMBER ) return VARCHAR2 IS

   Cursor C is
   Select project_system_status_code
   from pa_project_statuses
   where project_status_code = p_current_rep_status;
   l_project_system_status_code pa_project_statuses.project_system_status_code%TYPE;

   Cursor C1 is
   Select nvl(approval_required,'N') approval_required
         -- ,nvl(auto_publish,'N') auto_publish
   from pa_object_page_layouts pop
        ,pa_progress_report_vers prv
   where pop.object_type = prv.object_type
   and   pop.object_id = prv.object_id
   and   pop.report_type_id = prv.report_type_id ---report_type_id will be there for PPR
   and   pop.page_type_code = prv.page_type_code
   and   prv.version_id = p_version_id;

    l_approval_required pa_object_page_layouts.approval_required%TYPE;
    l_auto_publish   VARCHAR2(1);
    x_ret_code       VARCHAR2(1); --FND_API.G_TRUE%TYPE;
    x_return_status  VARCHAR2(1); --FND_API.G_RET_STS_SUCCESS%TYPE;
BEGIN
   PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_UTILS_PKG.check_action_allowed');
   x_ret_code:= fnd_api.g_true;
   x_return_status:=fnd_api.g_ret_sts_success;
    -- Initialize the Error Stack
   PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAMS_PVT.Create_Subteam');

    -- Validation the INPUT parameters
    open C;
    fetch C into l_project_system_status_code;
    if (C%NOTFOUND) then
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PJX_INV_PRJ_REP_STATUS');
      x_return_status := FND_API.G_RET_STS_ERROR;
      --x_ret_code:= fnd_api.g_false;
      --return x_ret_code;
      --x_msg_count     := x_msg_count + 1;
    end if;
    close C;
    open C1;
    fetch C1 into l_approval_required; --,l_auto_publish;
    if (C1%NOTFOUND) then
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PJX_INV_REP_VERSION');
      x_return_status := FND_API.G_RET_STS_ERROR;
      --x_ret_code:= fnd_api.g_false;
      --x_msg_count     := x_msg_count + 1;
    end if;
    close C1;
     if (l_approval_required = 'A') then
        l_auto_publish := 'Y';
     else
       l_auto_publish := 'N';
     end if;
     if (p_action_code NOT IN ('REWORK','EDIT','SUBMIT','PUBLISH','CANCEL')) then
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_PJX_INV_ACTION_CODE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      --x_msg_count     := x_msg_count + 1;
     end if;
    /* Return False if any parameter validation fails */
     IF (x_return_status = FND_API.G_RET_STS_ERROR) then
        x_ret_code:= fnd_api.g_false;
        RETURN x_ret_code;
     END IF;

     IF (l_project_system_status_code = 'PROGRESS_REPORT_WORKING') then
        IF ( (p_action_code = 'EDIT') OR
             (p_action_code ='SUBMIT' AND l_approval_required = 'Y') OR
             (p_action_code ='PUBLISH' AND l_approval_required = 'N')   ) then
            x_ret_code:= fnd_api.g_true;
        ELSE
            x_ret_code:= fnd_api.g_false;
        END IF;
      ELSIF (l_project_system_status_code = 'PROGRESS_REPORT_SUBMITTED' OR
             l_project_system_status_code = 'PROGRESS_REPORT_REJECTED') then
         IF ( p_action_code = 'REWORK' ) THEN
            x_ret_code:= fnd_api.g_true;
        ELSE
            x_ret_code:= fnd_api.g_false;
        END IF;
      ELSIF (l_project_system_status_code = 'PROGRESS_REPORT_APPROVED') THEN
        IF ( (p_action_code ='REWORK' ) OR
             (p_action_code ='PUBLISH' AND l_auto_publish = 'N')   ) then
            x_ret_code:= fnd_api.g_true;
        ELSE
            x_ret_code:= fnd_api.g_false;
        END IF;
      ELSIF (l_project_system_status_code = 'PROGRESS_REPORT_PUBLISHED') THEN
        IF ( p_action_code ='CANCEL') then
            x_ret_code:= fnd_api.g_true;
        ELSE
            x_ret_code:= fnd_api.g_false;
        END IF;
      ELSIF (l_project_system_status_code = 'PROGRESS_REPORT_CANCELED') THEN
        x_ret_code:= fnd_api.g_false;
      END IF;
      return x_ret_code;
  EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_UTILS_PKG'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_ret_code:= fnd_api.g_false;
       return x_ret_code;
       --RAISE;  -- This is optional depending on the needs
  END check_action_allowed;

procedure Validate_Prog_Proj_Dates (p_project_id         IN   Number,
                                    p_scheduled_st_date  IN   Date,
                                    p_scheduled_ed_date  IN   Date,
                                    p_estimated_st_date  IN   Date,
                                    p_estimated_ed_date  IN   Date,
                                    p_actual_st_date     IN   Date,
                                    p_actual_ed_date     IN   Date,
                                    p_percent_complete   IN   Number,
                                    p_est_to_complete    IN   Number,
                                    x_return_status     OUT   NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                    x_msg_count         OUT   NOCOPY Number, --File.Sql.39 bug 4440895
                                    x_msg_data          OUT   NOCOPY Varchar2) is --File.Sql.39 bug 4440895
l_msg_index_out     Number;

begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   FND_MSG_PUB.initialize;

   if  p_estimated_ed_date < p_estimated_st_date then
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_EST_DATES_INV');
        x_return_status := FND_API.G_RET_STS_ERROR;
   end if;

   if p_actual_ed_date < p_actual_st_date then
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_ACT_DATES_INV');
        x_return_status := FND_API.G_RET_STS_ERROR;
   end if;

   -- if actual dates are given estimated are not required

/*   if p_estimated_st_date > get_earliest_task_st_date(p_project_id) then
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_EST_ST_DATE_INV');
        x_return_status := FND_API.G_RET_STS_ERROR;
   end if;

   if p_estimated_ed_date < get_latest_task_ed_date(p_project_id) then
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_EST_ED_DATE_INV');
        x_return_status := FND_API.G_RET_STS_ERROR;
   end if;

   if p_actual_st_date > get_earliest_task_st_date(p_project_id) then
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_ACT_ST_DATE_INV');
        x_return_status := FND_API.G_RET_STS_ERROR;
   end if;

   if p_actual_ed_date < get_latest_task_ed_date(p_project_id) then
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_ACT_ED_DATE_INV');
        x_return_status := FND_API.G_RET_STS_ERROR;
   end if;
*/

   if not (p_percent_complete between 0 and 100) then
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_PERC_COMP_INV');
        x_return_status := FND_API.G_RET_STS_ERROR;
   end if;

   if (p_est_to_complete < 0) then
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_EST_TO_COMP_INV');
        x_return_status := FND_API.G_RET_STS_ERROR;

   end if;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                             p_data  => x_msg_data);
end validate_prog_proj_dates;


PROCEDURE is_template_editable
  (
   p_page_id  NUMBER,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) IS

      Cursor c_page_type
      is select page_type_code
      from pa_object_page_layouts
      where page_id = p_page_id;

      CURSOR get_page_type_code
	IS
	   SELECT page_type_code
	     FROM pa_page_layouts
	     WHERE page_id = p_page_id;

      CURSOR check_update_report_ok
	IS SELECT 'N' FROM
	  dual
	  WHERE exists
	  (SELECT * FROM
	   pa_progress_report_vers
	   WHERE page_id = p_page_id
	   AND (report_status_code = 'PROGRESS_REPORT_PUBLISHED' OR
		report_status_code = 'PROGRESS_REPORT_SUBMITTED' OR
		report_status_code = 'PROGRESS_REPORT_APPROVED'));

      l_dummy VARCHAR2(1);
      l_ok_to_delete      VARCHAR2(1):= 'Y';
      l_msg_index_out     Number;
      l_page_type_code    varchar2(30);
      l_ret VARCHAR2(1);

BEGIN

   --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( fnd_api.g_true ) THEN
    FND_MSG_PUB.initialize;
  END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Check it is a seeded template
   if (p_page_id < 1000) then
     l_ok_to_delete := 'N';

   --Bug 3684164. We would allow updation of status report page layouts even if
   --the page layout is associated to a project / report type.
   /*
   else
   --Bug#3302984 ,If  page type code is not PPR and association exist, set l_ok_to_delete as Y
     open c_page_type;
     fetch c_page_type into l_page_type_code;
     if (c_page_type%found) then
       if(l_page_type_code <> 'PPR') then
          l_ok_to_delete := 'Y';
       else
         OPEN check_update_report_ok;
         FETCH check_update_report_ok INTO l_dummy;
         IF (check_update_report_ok%found) THEN
           l_ok_to_delete := 'N';
         END IF;
         CLOSE check_update_report_ok;
       end if;
     end if;
     close c_page_type;
   */
   end if;

   --Bug 3684164.
   --Commenting out the code as currently we cannot update only the seeded page layouts.
   /*
   --- check if a page is attached to a report type
   if (pa_report_Types_utils.page_used_by_report_type(p_page_id) = 'Y') then
       l_ok_to_delete := 'N';
   end if;



   -- add for non-PPR report types
   OPEN get_page_type_code;
   FETCH get_page_type_code INTO l_page_type_code;
   CLOSE get_page_type_code;

   IF (l_page_type_code <> 'PPR') then
      l_ret := pa_page_layout_utils.check_page_layout_deletable(p_page_id);
      IF l_ret = 'N' THEN
	 l_ok_to_delete := 'N';
      END IF;
   END IF;
   */

   IF (l_ok_to_delete = 'N') then
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
   		          ,p_msg_name       => 'PA_EDIT_TEMPLATE_INV');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count :=  FND_MSG_PUB.Count_Msg;
      IF x_msg_count = 1 then
        pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
					  ,p_msg_index     => 1
					  ,p_data          => x_msg_data
					  ,p_msg_index_out => l_msg_index_out
						  );
      END IF;
    END IF;



END is_template_editable;


PROCEDURE update_perccomplete
  (
   p_object_id  NUMBER,
   p_object_type VARCHAR2,
   p_percent_complete NUMBER,
   p_asof_date   DATE,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) IS

      l_project_id NUMBER;
      l_task_id NUMBER;

      CURSOR get_project_id IS
	 SELECT project_id FROM pa_tasks
	   WHERE task_id = l_task_id;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_UTILS.update_perccomplete');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT update_perccomplete;

  --debug_msg( 'p_object_id' || To_char(p_object_id));
  --debug_msg('p_object_type' || p_object_type);
  --debug_msg('p_percent_complete' || To_char(p_percent_complete));

  IF p_object_type = 'PA_PROJECTS' THEN
     l_project_id := p_object_id;
     l_task_id := 0;
   ELSE
     l_task_id := p_object_id;

     OPEN get_project_id;
     fetch get_project_id INTO l_project_id;
     CLOSE get_project_id;
  END IF;



  IF (p_percent_complete > 100 or p_percent_complete< 0 )THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
			   ,p_msg_name       => 'PA_PR_PERCENT_COMPLETE_INV');       x_return_status := FND_API.G_RET_STS_ERROR;

   ELSE
     -- todo

     --debug_msg ('before get_percent_complete insert' || To_char(l_project_id) );
     --debug_msg ('before get_percent_complete insert' || To_char(l_task_id) );
     --debug_msg ('before get_percent_complete insert' || To_char(p_percent_complete) );


       pa_percent_complete_pkg.insert_row
       (
	l_project_id,
	l_task_id,
	p_percent_complete,
	p_asof_date,
	NULL,
	Sysdate,
	fnd_global.user_id,
	Sysdate,
	fnd_global.user_id,
	fnd_global.user_id,
	x_return_status,
	x_msg_data
	 );

          --debug_msg ('before get_percent_complete 3' );
  END IF;

  IF (x_return_status <> FND_API.g_ret_sts_success) THEN

     ROLLBACK TO update_perccomplete;
     RETURN;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO update_perccomplete;

       --
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_Progress_Report_Utils.update_perccomplete'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs


END update_perccomplete;


FUNCTION progress_report_exists
  (
   p_object_id  NUMBER,
   p_object_type VARCHAR2
   ) RETURN BOOLEAN

  IS

     CURSOR get_progress_report
       IS SELECT 'Y'
	 FROM dual
	 WHERE exists(
		      SELECT version_id
		      FROM pa_progress_report_vers
		      WHERE object_id = p_object_id
		      AND object_type = p_object_type
		      );

     l_result VARCHAR2(1);

BEGIN
   OPEN get_progress_report;
   FETCH get_progress_report INTO l_result;

   IF get_progress_report%notfound THEN
      CLOSE get_progress_report;
      RETURN FALSE;
    ELSE
      CLOSE get_progress_report;
      RETURN TRUE;
   END IF;

END progress_report_exists;

FUNCTION pagelayout_exists
  (
   p_object_id  NUMBER,
   p_object_type VARCHAR2
   ) RETURN BOOLEAN

  IS

     CURSOR get_page_layout
       IS SELECT 'Y'
	 FROM dual
	 WHERE exists(
		      SELECT page_id
		      FROM pa_object_page_layouts
		      WHERE object_id = p_object_id
		      AND object_type = p_object_type
		      );

      CURSOR get_obj_region
       IS SELECT 'Y'
	 FROM dual
	 WHERE exists(
		      SELECT placeholder_reg_code
		      FROM pa_object_regions
		      WHERE object_id = p_object_id
		      AND object_type = p_object_type
		      		      );
     l_result VARCHAR2(1);

BEGIN
   OPEN get_page_layout;
   FETCH get_page_layout INTO l_result;

   IF get_page_layout%notfound THEN
      CLOSE get_page_layout;
      RETURN FALSE;
    ELSE
      CLOSE get_page_layout;

      OPEN get_obj_region;
      FETCH get_obj_region INTO l_result;
      IF get_obj_region%notfound THEN
	 CLOSE get_obj_region;
	 RETURN FALSE;
      END IF;
       RETURN TRUE;
   END IF;

END pagelayout_exists;

PROCEDURE remove_progress_report_setup
  (
   p_object_id                   IN     NUMBER := NULL,
   p_object_type                 IN     VARCHAR2 := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) IS

BEGIN

    -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_UTILS.remove_progress_report_setup');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT remove_progress_report_setup;

   pa_progress_report_pkg.delete_object_page_layouts
     (
      p_object_id,
      p_object_type,

      x_return_status,
      x_msg_count,
      x_msg_data
      );

    IF (x_return_status <> FND_API.g_ret_sts_success) THEN

     ROLLBACK TO remove_progress_report_setup;
     RETURN;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO remove_progress_report_setup;

       --
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_Progress_Report_Utils.remove_progress_report_setup'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END remove_progress_report_setup;

/* This is the function to get the page_id for the specified objcet of given
    page type.The function will try to get the page id for the object in the
    following order.
    1. Find any page_id associted to the object_id.
       Association exists at object level?
        Yes - Use the page id associted at the object level
        No  -
    2. Find the page associated at the project type level
       Association exists?
       Yes - Use the association at Project Type level.
       No ?
     3. Get the default page associated at the page type level
        This is stored in attribute3 in fnd_lookup_values of
        lookup_code='PA_PAGE_TYPES' and lookup_code = page_type_code
        Each page type owners must seed a default layout for the page
        and populate the attribute3 with that value.
     If the defaulting logic is going to be different, plrease use your own
     method to derive the page_id for the object.
 */
 FUNCTION get_object_page_id (
          p_page_type_code IN varchar2,
          p_object_type    IN varchar2,
          p_object_id      IN NUMBER,
          p_report_Type_id IN NUMBER := null)
 return   number
 IS
 l_page_id  NUMBER := null;
 l_page_id_tmp VARCHAR2(100) := null;
 l_model VARCHAR2(10) := null;
 l_page_id_s VARCHAR2(10) := null;
 cursor C1
 is
  select page_id from pa_object_page_layouts
  where page_type_code = p_page_type_code
  and   object_type = p_object_type
  and   object_id = p_object_id;

 cursor C3
 is
  select page_id from pa_object_page_layouts
  where object_id = p_object_id
  and   object_type = p_object_type
  and   report_type_id = p_report_Type_id
  and   page_type_code = p_page_type_code;

 /* Cursor to get the default page layout associated with the page type */
  Cursor C2 is
   select to_number(attribute3)
   from pa_lookups
   where lookup_type = 'PA_PAGE_TYPES'
     and lookup_code = p_page_type_code;

  CURSOR get_ai_page_id IS
     select task_progress_entry_page_id
    from pa_proj_elements ppe
    where ppe.proj_element_id = p_object_id
       and ppe.object_type = 'PA_TASKS';

  CURSOR task_type_page_id IS
     select ptt.task_progress_entry_page_id
      from  pa_proj_elements ppe,
            pa_task_types ptt
      where ppe.type_id = ptt.task_type_id
        and ppe.proj_element_id = p_object_id
        and ppe.object_type = 'PA_TASKS';

 BEGIN


  if (p_report_Type_id is null) then
   open C1;
   fetch C1 into l_page_id;
   close C1;
  else
   open C3;
   fetch C3 into l_page_id;
   close C3;
  end if;
   if (l_page_id is null) then   ---------(c1%NOTFOUND) then
      if (PA_INSTALL.is_prm_licensed = 'Y'
	  AND p_object_type = 'PA_PROJECTS'
	  AND p_object_id IS NOT null
           and PA_PROJECT_UTILS.Is_Admin_Project(p_object_id)='N'
           and p_page_type_code = 'PH'
	   ) then
           l_page_id := 10;
       ELSE

       --Bug#3302984

	 IF p_page_type_code = 'TM' THEN
	    fnd_profile.get('PA_TEAM_HOME_PAGELAYOUT',l_page_id_tmp);
	    IF l_page_id_tmp IS NULL THEN
			open C2;
			fetch C2 into l_page_id;
			close C2;
	    ELSE
		    -- Bug 3875716. handle the case where the profile value
			--doesnot contain PAGE prefix.
			if instr(l_page_id_tmp,':',1,1) = 0 then
				l_page_id := to_number(l_page_id_tmp);
			else
				IF (substr(l_page_id_tmp,1,4)='PAGE') THEN
					l_page_id := to_number(substr(l_page_id_tmp,6));
				else
				    --This case should not arise. To be on safer side let us
					--return the default page id in this case.
					open C2;
					fetch C2 into l_page_id;
					close C2;
				END IF;
			end if;
		   /*
	       select substr(l_page_id_tmp,1,4) into l_model from dual;
	       IF (l_model='PAGE') THEN
		select substr(l_page_id_tmp,6) into l_page_id_s from dual;
		l_page_id := to_number(l_page_id_s);
	       END IF;
		   */
	    END IF;

	  ELSIF p_page_type_code = 'AI' THEN

        /*
        the query to get page_id for this page type should try to
	get from pa_task_types if it is null in pa_proj_elements. If it is null in
	pa_task_types then it should get the default.
	*/
	    open get_ai_page_id;
	    fetch get_ai_page_id into l_page_id;
	    close get_ai_page_id;

	    IF l_page_id IS NULL THEN
		open task_type_page_id;
		fetch task_type_page_id into l_page_id;
		close task_type_page_id;
	    END IF;

	    IF l_page_id IS NULL THEN
	        open C2;
		fetch C2 into l_page_id;
		close C2;
	    END IF;

	  ELSE

	    open C2;
	    fetch C2 into l_page_id;
	    close C2;
	 END IF;


       end if;
   end if;
   return l_page_id;
 END get_object_page_id;

FUNCTION get_object_region (
          p_object_type    IN varchar2,
          p_object_id      IN NUMBER ,
          p_placeholder_reg_code varchar2)
 return   varchar2
 is
 l_return_reg_code varchar2(250) := null;
 Cursor C is
 select replacement_reg_code
 from pa_object_regions
 where object_type = p_object_type
 and object_id = p_object_id
 and placeholder_reg_code = p_placeholder_reg_code;
 Begin
  Open C;
  fetch C into l_return_reg_code;
  if (C%NOTFOUND) then
   l_return_reg_code := p_placeholder_reg_code;
  end if;
  close C;
  return l_return_reg_code;
 Exception
  when others then
  l_return_reg_code := p_placeholder_reg_code;
  return l_return_reg_code;
 End get_object_region;

 FUNCTION is_delete_page_layout_ok(
				   p_page_type_code IN varchar2,
				   p_object_type    IN varchar2,
				   p_object_id      IN NUMBER,
                                   p_report_type_id IN NUMBER
				   )
   RETURN VARCHAR2 is

      -- can not delere the ppr pagelayout when there is any report
      -- which is not published nor cancelled

      CURSOR get_ppr_pagelayout_delete_ok IS
	 select 'N'
	   from dual
	   where exists
	   (
	    select version_id
	    FROM PA_PROGRESS_REPORT_VERS
	    WHERE Object_Id = p_object_id
	    AND Object_Type = p_object_type
            AND report_Type_id = p_report_Type_id ); --- report_Type_id will be there
---------	    AND Report_Status_Code <> 'PROGRESS_REPORT_PUBLISHED'
---------	    and Report_Status_Code <> 'PROGRESS_REPORT_CANCELED');
      l_return VARCHAR2 (1) := 'N';
 BEGIN
    -- check if there is any non published or obsoleted report available
    IF p_page_type_code = 'PPR' then
       OPEN get_ppr_pagelayout_delete_ok;
       FETCH get_ppr_pagelayout_delete_ok INTO l_return;

       IF get_ppr_pagelayout_delete_ok%notfound THEN
	  l_return := 'Y';
       END IF;

       CLOSE get_ppr_pagelayout_delete_ok;

    END IF;

    RETURN l_return;

 END is_delete_page_layout_ok;

 FUNCTION is_edit_page_layout_ok(
                                   p_page_type_code IN varchar2,
                                   p_object_type    IN varchar2,
                                   p_object_id      IN NUMBER,
                                   p_report_type_id IN NUMBER
                                   )
   RETURN VARCHAR2 is

      -- can not delere the ppr pagelayout when there is any report
      -- which is not published nor cancelled

      CURSOR get_ppr_pagelayout_edit_ok IS
         select 'N'
           from dual
           where exists
           (
            select version_id
            FROM PA_PROGRESS_REPORT_VERS
            WHERE Object_Id = p_object_id
            AND Object_Type = p_object_type
            AND report_Type_id = p_report_Type_id
            AND Report_Status_Code <> 'PROGRESS_REPORT_PUBLISHED'
            and Report_Status_Code <> 'PROGRESS_REPORT_CANCELED');
      l_return VARCHAR2 (1) := 'N';
 BEGIN
    -- check if there is any non published or obsoleted report available
    IF p_page_type_code = 'PPR' then
       OPEN get_ppr_pagelayout_edit_ok;
       FETCH get_ppr_pagelayout_edit_ok INTO l_return;

       IF get_ppr_pagelayout_edit_ok%notfound THEN
          l_return := 'Y';
       END IF;

       CLOSE get_ppr_pagelayout_edit_ok;

    END IF;

    RETURN l_return;

 END is_edit_page_layout_ok;

 /* Bug 2798485 - Following function has been fixed to check security
    in the following order.
     1> Based in user's privilege PA_PROGRESS_REPORT_EDIT (return 2 if true)
     2> Based on user's privilege in the  ACCESS_LIST (return if 1 or 2 i.e. user has view or edit privilege)
     3> Based in user's privilege PA_PROGRESS_REPORT_VIEW (return 1 if true) */

/* Old Function */
/* Function Check_Security_For_ProgRep(p_object_Type    IN VARCHAR2,
                                    p_object_Id      IN NUMBER,
                                    p_report_type_id IN NUMBER) return NUMBER Is

  l_object_page_layout_id number;
  x_return_code           varchar2(2000);
  x_return_status         varchar2(1);
  x_msg_count             number;
  x_msg_data              varchar2(2000);
Begin
   pa_security_pvt.check_user_privilege(x_ret_code      => x_return_code,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_privilege      => 'PA_PROGRESS_REPORT_EDIT',
                                       p_object_name    => 'PA_PROJECTS',
                                       p_object_key     => p_object_id);
  if (x_return_code = 'T') then
       return 2;
  else
   pa_security_pvt.check_user_privilege(x_ret_code      => x_return_code,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_privilege      => 'PA_PROGRESS_REPORT_VIEW',
                                       p_object_name    => 'PA_PROJECTS',
                                       p_object_key     => p_object_id);
   if (x_return_code = 'T') then
       return 1;
   end if;
  end if;

  begin
   select object_page_layout_id
     into l_object_page_layout_id
     from pa_object_page_layouts
    where object_id = p_object_id and
          object_type = p_object_type and
          report_Type_id = p_report_Type_id;
   exception when others then
      return 0;
  end;

  return pa_distribution_list_utils.get_access_level(p_object_Type => 'PA_OBJECT_PAGE_LAYOUT',
                                                p_object_id   => l_object_page_layout_id,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data);
End Check_Security_For_ProgRep; */


/* New Function */

 Function Check_Security_For_ProgRep(p_object_Type    IN VARCHAR2,
                                     p_object_Id      IN NUMBER,
                                     p_report_type_id IN NUMBER) return NUMBER Is

  l_object_page_layout_id number;
  access_level            number;
  x_return_code           varchar2(2000);
  x_return_status         varchar2(1);
  x_msg_count             number;
  x_msg_data              varchar2(2000);


Begin

 begin
  select object_page_layout_id
    into l_object_page_layout_id
    from pa_object_page_layouts
   where object_id = p_object_id and
         object_type = p_object_type and
         report_Type_id = p_report_Type_id;
 exception when others then
   l_object_page_layout_id := -9999;
 end;

   pa_security_pvt.check_user_privilege(x_ret_code      => x_return_code,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_privilege      => 'PA_PROGRESS_REPORT_EDIT',
                                       p_object_name    => 'PA_PROJECTS',
                                       p_object_key     => p_object_id);
  if (x_return_code = 'T') then
       return 2;
  else
       if (l_object_page_layout_id <> -9999) then
       access_level := pa_distribution_list_utils.get_access_level(p_object_Type => 'PA_OBJECT_PAGE_LAYOUT',
                                                p_object_id   => l_object_page_layout_id,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data);
       else
            access_level := 0;
       end if;
       if ( access_level <> 0 ) then
            return access_level;
       else

           pa_security_pvt.check_user_privilege(x_ret_code      => x_return_code,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_privilege      => 'PA_PROGRESS_REPORT_VIEW',
                                       p_object_name    => 'PA_PROJECTS',
                                       p_object_key     => p_object_id);
            if (x_return_code = 'T') then
                return 1;
            end if;
       end if;
  end if;

  return 0;


End Check_Security_For_ProgRep;

Function Check_Security_For_ProgRep(p_object_Type    IN VARCHAR2,
                                    p_object_Id      IN NUMBER,
                                    p_report_type_id IN NUMBER,
                                    p_Action         IN VARCHAR) return VARCHAR2 Is
  ret                     number;
  privilege               varchar2(30);
  x_return_code           varchar2(2000);
  x_return_status         varchar2(1);
  x_msg_count             number;
  x_msg_data              varchar2(2000);

Begin

  /* if (p_action = 'EDIT') then
       privilege := 'PA_PROGRESS_REPORT_EDIT';
   else
       privilege := 'PA_PROGRESS_REPORT_VIEW';
   end if;
   pa_security_pvt.check_user_privilege(x_ret_code      => x_return_code,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       p_privilege      => privilege,
                                       p_object_name    => 'PA_PROJECTS',
                                       p_object_key     => p_object_id);
   if (x_return_code = 'T') then
       return x_return_code;
   else */

       ret := Check_Security_For_ProgRep(p_object_type => p_object_type,
                                     p_object_id   => p_object_id,
                                     p_report_Type_id => p_report_Type_id);

       if (p_action = 'EDIT' and ret = 2) then
           return 'T';
       elsif (p_action = 'VIEW' and (ret = 1 or ret = 2)) then
           return 'T';
       else
           return 'F';
       end if;
   ---end if;

return 'F';

End Check_Security_For_ProgRep;

Function is_cycle_ok_to_delete(p_reporting_cycle_id  IN  NUMBER) return varchar2
IS
   cursor rep_cycle is
   select 'N'
    from pa_object_page_layouts
   where reporting_cycle_id = p_reporting_cycle_id;

   retval   varchar2(1);
   l_rep_cycle  rep_cycle%rowtype;

Begin
  open rep_cycle;
  fetch rep_cycle into l_rep_cycle;
  if rep_cycle%found then
      close rep_cycle;
      return 'N';
  else
      close rep_cycle;
      return 'Y';
  end if;
End is_cycle_ok_to_delete;

Function get_latest_working_report_id(p_object_Type    IN VARCHAR2,
                                      p_object_Id      IN NUMBER,
                                      p_report_type_id IN  NUMBER) return NUMBER IS
  l_version_id     number;
BEGIN
  select version_id
    into l_version_id
    from pa_progress_report_vers
   where object_id = p_object_id
     and object_Type = p_object_Type
     and report_Type_id = p_report_Type_id
     and report_status_code = 'PROGRESS_REPORT_WORKING'
     and (report_end_date, last_update_date) = (select max(report_end_Date), max(last_update_date)
                              from pa_progress_report_vers
                             where object_id = p_object_id
                               and object_Type = p_object_Type
                               and report_Type_id = p_report_Type_id
                               and report_status_code = 'PROGRESS_REPORT_WORKING');
   return l_version_id;

exception when others then
   return -999;

END get_latest_working_report_id;

FUNCTION get_tab_menu_name(p_project_id IN NUMBER) RETURN VARCHAR2
IS
  l_menu_name VARCHAR2(100);
BEGIN
  SELECT menu_name
  INTO l_menu_name
  FROM fnd_menus m, pa_object_page_layouts o
  WHERE m.menu_id=o.page_id
    AND o.page_type_code='TAB_MENU'
    AND o.object_type='PA_PROJECTS'
    AND o.object_id=p_project_id;

  RETURN l_menu_name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'PA_SINGLE_TAB_MENU';
END get_tab_menu_name;

--  Notes: Due to bug 3620190 this api is no longer in used.  The tab setup is
--  already copied as part of pa_object_page_layouts table.
PROCEDURE copy_project_tab_menu(
	p_src_project_id IN NUMBER,
	p_dest_project_id IN NUMBER,
	x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_return_status OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := NULL;
END copy_project_tab_menu;

END PA_Progress_Report_Utils;

/
