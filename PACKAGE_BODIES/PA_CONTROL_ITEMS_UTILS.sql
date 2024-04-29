--------------------------------------------------------
--  DDL for Package Body PA_CONTROL_ITEMS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CONTROL_ITEMS_UTILS" AS
--$Header: PACICIUB.pls 120.12.12010000.5 2009/10/23 17:04:27 rrambati ship $
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

G_user_id NUMBER:=-999;
G_party_id NUMBER:=-999;
G_party_name VARCHAR2(360):= NULL ;

G_status_type VARCHAR2(100) := NULL;
G_status_code VARCHAR2(100) := NULL;
G_action_code VARCHAR2(100) := NULL;
G_action_allowed VARCHAR2(1) := NULL;

function GET_OBJECT_NAME(
         p_project_id   IN  NUMBER
        ,p_object_id    IN  NUMBER   := NULL
        ,p_object_type  IN  VARCHAR2 := NULL
) RETURN VARCHAR2

IS

   l_rowid ROWID;
   l_object_name VARCHAR2(250) := NULL;

   -- cursor c_task_name is select 'Wait for fix from Sakthi' from dual;

  -- cursor c_task_name is select element_name from PA_LATEST_PUB_STRUC_TASKS_V
   cursor c_task_name is select element_name from PA_FIN_LATEST_PUB_TASKS_V
     where proj_element_id = p_object_id
       and project_id      = p_project_id;
       --and object_type     = p_object_type;

BEGIN
   if p_object_type is NULL or p_object_type <> 'PA_TASKS' then
	return NULL;
   end if;
  OPEN c_task_name;
  FETCH c_task_name INTO l_object_name;
  close c_task_name;
  RETURN l_object_name;

EXCEPTION

 WHEN NO_DATA_FOUND THEN
        RETURN NULL ;
 WHEN OTHERS THEN
       RETURN NULL;

end GET_OBJECT_NAME;


function GET_INITIAL_CI_STATUS(
         p_ci_type_id   IN NUMBER  := NULL
) RETURN VARCHAR2
IS
BEGIN
   return 'CI_WORKING';

end GET_INITIAL_CI_STATUS;

-- has been replaced by get_party_id in PA_UTILS
-- Function get_party_id (
--                        p_resource_id in number,
--                        p_resource_type_id in number )
-- return number
-- IS
--    Cursor external is
--    select customer_id from fnd_user
--
--    where user_id = p_resource_id;

--    Cursor internal is
--    select h.party_id
--    from hz_parties h
--    where h.orig_system_reference = CONCAT('PER:',p_resource_id);

--    l_party_id number;

--    Begin
--        if(p_resource_type_id = 101) then
--            Open internal;
--            fetch internal into l_party_id;
--            close internal;
--        end if;
--        if(p_resource_type_id = 112) then
--            Open external;
--            fetch external into l_party_id;
--            close external;
--        end if;
--        return l_party_id;
-- End get_party_id;

Function IsImpactOkToInclude(p_ci_type_id_1   IN   NUMBER,
                             p_ci_type_id_2   IN   NUMBER,
                             p_ci_id_2        IN   NUMBER) return VARCHAR2
IS

p_ci_type_id      number;
p_ci_id           number;
impact_bud_type_code  varchar2(30);
cursor ci_type_impact is
       select impact_Type_code
         from pa_ci_impact_type_usage
        where ci_type_id = p_ci_type_id;

cursor ci_impact is
       select impact_type_code
         from pa_ci_impacts
        where ci_id = p_ci_id;

cursor budget_type_code is
      SELECT impact_budget_type_code
      from pa_ci_types_b where ci_type_id=p_ci_type_id;

citypeimpact        ci_type_impact%rowtype;
ciimpact            ci_impact%rowtype;
impact_1            varchar2(1):= 'Y';
temp                varchar2(1);

Begin
p_ci_type_id := p_ci_type_id_1;
 /* bug 9044122 start */

   open budget_type_code;
   fetch budget_type_code into impact_bud_type_code;
   if(impact_bud_type_code = 'DIRECT_COST_ENTRY') then
     begin
      select 'Y'
      into temp
      from pa_control_items ci,pa_ci_types_b ci_type1 ,pa_ci_types_b ci_type2
      where ci.ci_type_id = ci_type2.ci_type_id
      and  ci_type2.impact_budget_type_code=impact_bud_type_code
      and ci.ci_id = p_ci_id_2
      and ci_type1.ci_type_id = p_ci_type_id_1
      and ci_type1.supp_cost_reg_flag = ci_type2.supp_cost_reg_flag
      and ci_type1.dir_cost_reg_flag = ci_type2.dir_cost_reg_flag ;
      return 'Y' ;
      exception when no_data_found then
       return 'N';
      end;
   else
       begin
        if(impact_bud_type_code = 'EDIT_PLANNED_AMOUNTS') then
         select 'Y'
         into temp
         from pa_control_items ci,pa_ci_types_b ci_type
         where ci.ci_type_id = ci_type.ci_type_id
         and  ci_type.impact_budget_type_code=impact_bud_type_code
         and ci.ci_id = p_ci_id_2;
        end if;
        exception when no_data_found then
         return 'N';
       end;

   end if;


 /* bug 9044122 end */



   open ci_type_impact;
   fetch ci_type_impact into citypeimpact;
   if (ci_type_impact%notfound) then
       impact_1 := 'N';
   else
       impact_1 := 'Y';
   end if;
   close ci_type_impact;

   if (p_ci_type_id_2 is not null) then
       p_ci_type_id := p_ci_type_id_2;
       open ci_type_impact;
       fetch ci_type_impact into citypeimpact;
       if (ci_type_impact%notfound) then
          return 'Y';
       elsif (ci_type_impact%found  and impact_1 = 'N') then
          return 'N';
       elsif (ci_type_impact%found  and impact_1 = 'Y') then
          begin
          select 'Y'
            into temp
            from pa_ci_impact_type_usage
           where ci_type_id = p_ci_type_id_2
	     and impact_type_code <> 'FINPLAN'   /* Bug# 3724520 */
             and impact_Type_code not in (select impact_Type_code
                                            from pa_ci_impact_type_usage
                                           where ci_type_id = p_ci_type_id_1
            	                             and impact_type_code <> 'FINPLAN');  /* Bug# 3724520 */
          return 'N';
          exception when no_data_found then
             return 'Y';
          when others then
             return 'N';
          end;
       end if;
       close ci_type_impact;
   elsif (p_ci_id_2 is not null) then
       p_ci_id := p_ci_id_2;
       open ci_impact;
       fetch ci_impact into ciimpact;
       if (ci_impact%notfound) then
          return 'Y';
       elsif (ci_impact%found  and impact_1 = 'N') then
          return 'N';
       elsif (ci_impact%found  and impact_1 = 'Y') then
          begin
          select 'Y'
            into temp
            from pa_ci_impacts
           where ci_id = p_ci_id_2
	     and impact_type_code <> 'FINPLAN'   /* Bug# 3724520 */
             and impact_Type_code not in (select impact_Type_code
                                            from pa_ci_impact_type_usage
                                           where ci_type_id = p_ci_type_id_1
					     and impact_type_code <> 'FINPLAN');  /* Bug# 3724520 */
          return 'N';
          exception when no_data_found then
             return 'Y';
          when others then
             return 'N';
          end;
       end if;
       close ci_impact;
   end if;
return 'N';
End IsImpactOkToInclude;

Function CheckCIActionAllowed(p_status_type   IN   VARCHAR2 default null,
                              p_status_code   IN   VARCHAR2 default null,
                              p_action_code   IN   VARCHAR2 default null,
			      p_ci_id IN NUMBER default null) return VARCHAR2
  IS
 l_status_type VARCHAR2(30);
 l_status_code VARCHAR2(30);


 Cursor C_USER_CONTROL is
  Select enabled_flag
  from pa_project_status_controls
  where status_type = l_status_type
  and project_status_code = l_status_code
  and action_code = p_action_code;

 Cursor C_SYS_CONTROL is
  Select enabled_flag
  from pa_project_status_controls sc
      ,pa_project_statuses ps
  where ps.project_status_code = l_status_code
  and   ps.project_system_status_code = sc.project_system_status_code
  and   sc.status_type = l_status_type
  and   sc.action_code = p_action_code;

 CURSOR get_current_status
   IS
      SELECT status_code
	FROM pa_control_items
	WHERE ci_id = p_ci_id;


BEGIN

   l_status_type := p_status_type;
   l_status_code := p_status_code;

   IF p_ci_id IS NOT NULL THEN
      -- get the current status
      l_status_type := 'CONTROL_ITEM';
      OPEN get_current_status ;
      FETCH get_current_status INTO l_status_code;
      IF get_current_status%notfound THEN
	 RETURN 'N';
      END IF;

      CLOSE get_current_status;

   END IF;

  IF G_status_code = l_status_code AND
     G_status_type = l_status_type AND
     G_action_code = p_action_code THEN
    RETURN G_action_allowed;
  END IF;

  open C_USER_CONTROL;
  fetch C_USER_CONTROL into G_action_allowed;
  if (C_USER_CONTROL%NOTFOUND) then
     open C_SYS_CONTROL;
     fetch C_SYS_CONTROL into G_action_allowed;
     close C_SYS_CONTROL;
   end if;
  close C_USER_CONTROL;

  G_status_code := l_status_code;
  G_status_type := l_status_type;
  G_action_code := p_action_code;

  return G_action_allowed;
 Exception
  when others then
    return 'N';
 End CheckCIActionAllowed;

 Function CheckValidNextCIStatus( p_ci_id       in Number
                                 ,p_next_status in varchar2)
 return Boolean
 is
 Cursor C_CI is
  select
         ci_id
        ,ci.ci_type_id
        ,status_code
        ,ps.project_system_status_code system_status_code
        ,cit.ci_type_class_code ci_type_class
        ,cit.approval_required_flag approval_required_flag
  from pa_control_items ci
      ,pa_ci_types_b cit
      ,pa_project_statuses ps
  where ci.ci_id = p_ci_id
  and   ci.ci_type_id = cit.ci_type_id
  and   ci.status_code     = ps.project_status_code;

 CI_REC  C_CI%ROWTYPE;
 Cursor C_NEXT_SYS_STAT is
  Select project_system_status_code
  from pa_project_statuses
  where project_status_code = p_next_status;

 l_return_value  boolean := false;
 l_curr_sys_status PA_PROJECT_STATUSES.PROJECT_SYSTEM_STATUS_CODE%TYPE;
 l_next_sys_status PA_PROJECT_STATUSES.PROJECT_SYSTEM_STATUS_CODE%TYPE;

 Begin
    open C_CI;
    fetch C_CI into CI_REC;
    close C_CI;

    open C_NEXT_SYS_STAT;
    fetch C_NEXT_SYS_STAT into l_next_sys_status;
    close C_NEXT_SYS_STAT;

    l_return_value := CheckValidNextCISysStatus
                     ( p_curr_sys_status => ci_rec.system_status_code
                      ,p_next_sys_status => l_next_sys_status
                      ,p_ci_type_class   => ci_rec.ci_type_class
		       ,p_approval_req_flag => ci_rec.approval_required_flag );


    return l_return_value;

  End CheckValidNextCIStatus;

  Function CheckValidNextCISysStatus( p_curr_sys_status in varchar2
                                     ,p_next_sys_status in varchar2
                                     ,p_ci_type_class   in varchar2
                                     ,p_approval_req_flag in varchar2)
 return Boolean
  is
     l_return_value  boolean := false;

  BEGIN


     IF (p_curr_sys_status = p_next_sys_status) THEN
	l_return_value := TRUE;
    elsIf (p_curr_sys_status = 'CI_DRAFT') then
       if (p_next_sys_status = 'CI_WORKING') then
           l_return_value := true;
       end if;
    elsif (p_curr_sys_status = 'CI_WORKING') then
       if (p_next_sys_status = 'CI_SUBMITTED') then
            if( (p_ci_type_class in ('CHANGE_ORDER','CHANGE_REQUEST'))
               OR (p_ci_type_class = 'ISSUE' AND p_approval_req_flag = 'Y')
              ) then
                l_return_value := true;
            end if;
       elsif (p_next_sys_status in ('CI_CANCELED','CI_CLOSED')) then
            l_return_value := true;
       end if;
    elsif (p_curr_sys_status = 'CI_SUBMITTED') then
       if (p_next_sys_status in ('CI_APPROVED','CI_REJECTED','CI_WORKING')) then
           l_return_value := true;
       end if;
    elsif (p_curr_sys_status = 'CI_APPROVED') then
       if (p_next_sys_status in ('CI_CLOSED','CI_CANCELED','CI_WORKING')) then
           /* Is it different for Included CRs? */
           l_return_value := true;
       end if;
    elsif (p_curr_sys_status = 'CI_REJECTED') then
       if (p_next_sys_status in ('CI_CANCELED','CI_WORKING')) then
           l_return_value := true;
       end if;
    elsif (p_curr_sys_status = 'CI_CLOSED') then
       if ( (p_next_sys_status = 'CI_APPROVED') AND
            (p_ci_type_class in ('CHANGE_ORDER','CHANGE_REQUEST'))
           ) then
	  l_return_value := true;
	ELSIF ( (p_next_sys_status = 'CI_WORKING') AND
            (p_ci_type_class in ('ISSUE'))
           ) then
	  l_return_value := true;
       end if;

     end if;



    return l_return_value;
 End CheckValidNextCISysStatus;

/*----------------------------------------------------------------------------
  Function to return status of control Item
  -----------------------------------------------------------------------------*/
  FUNCTION getCIStatus ( p_CI_id IN NUMBER)
  return VARCHAR2
  is
  l_ci_status varchar2(30) := NULL ;

  BEGIN
     if p_ci_id is NULL then
        return NULL;
     end if;

     IF g_CI_id is NULL or g_CI_id <> p_ci_id then
        select status_code
          into l_ci_status
          from pa_control_items
        where ci_id = p_ci_id ;
        g_ci_status := l_ci_status ;
     END IF ;

       return g_ci_status ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL ;
    WHEN OTHERS THEN RAISE ;

  END getCIStatus ;

/*-----------------------------------------------------------------------------
  Function to check whether CI type has any impact
  -----------------------------------------------------------------------------*/
  FUNCTION isCITypehasimpact ( p_ci_id IN NUMBER)
  return VARCHAR2
  is
  l_ci_type_has_impact varchar2(1) := 'N';
BEGIN
     IF p_ci_id is null then
        return NULL;
     END IF;

     IF g_ci_id is null or g_CI_id <> p_ci_id  then
        select 'Y'
          into l_ci_type_has_impact
          from dual
        where exists ( select '1'
                        from  pa_ci_impact_type_usage CIIU
                             ,pa_control_items CI
                       where CIIU.ci_type_id= CI.ci_type_id
                         and CI.CI_id = p_ci_id ) ;
        g_ci_type_has_impact := l_ci_type_has_impact ;
     END IF ;


       return g_ci_type_has_impact ;
   Exception
   WHEN NO_DATA_FOUND THEN
        RETURN NULL ;
    When OTHERS THEN
        RAISE ;
   END isCITypehasimpact ;

/*-----------------------------------------------------------------------------
  Function to check whether a CI type has any impact
  This one checks impact flag for a given TYPE ID (not ci_id)
  -----------------------------------------------------------------------------*/
  FUNCTION TypeHasImpact ( p_ci_type_id IN NUMBER)
  return VARCHAR2
  is
  l_type_has_impact varchar2(1) := 'N';
BEGIN
     IF p_ci_type_id is null then
        return NULL;
     END IF;

     IF g_ci_type_id is null or g_ci_type_id <> p_ci_type_id  then
        select 'Y'
          into l_type_has_impact
          from dual
        where exists ( select '1'
                        from  pa_ci_impact_type_usage CIIU
                       where CIIU.ci_type_id = p_ci_type_id
                          ) ;
        g_type_has_impact := l_type_has_impact ;
     END IF ;
     return g_type_has_impact ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN NULL ;
    When OTHERS THEN
        RAISE ;
END TypeHasImpact ;

/*-------------------------------------------------------------------------------------
!!! NOT USED, replaced with CheckNextPageValid
  Function Name: CheckValidNextPage
  Usage: Used with with lookup type to determine valid list of next pages to navigate
  Rules: 1. If CI id is null it is the create page. Allow all Next page
         2. Exclude the current page from the next page list.
---------------------------------------------------------------------------------------*/
/*
 FUNCTION CheckValidNextPage( p_ci_id           IN NUMBER
                             ,p_type_id         IN VARCHAR2
                             ,p_status_control  IN VARCHAR2
                             ,p_page_code       IN VARCHAR2
                             ,p_currpage_code   IN VARCHAR2
                             ,p_action_list     IN VARCHAR2 := 'N')

 return VARCHAR2
 is


  l_ci_status            varchar2(30):= NULL ;
  l_ci_type_has_impact   varchar2(1) := 'N';
  l_check_update_access  varchar2(1) := 'F';
  l_stat_change          varchar2(1) := 'F';

 BEGIN
   IF p_page_code is NULL or  p_currpage_code is NULL then
      return 'N'   ;
   END IF ;

   IF p_page_code = p_currpage_code then
      return 'N'   ;
   END IF ;

   -- In Review page, don't show "Review and Submit" or "Review"
   IF substr(p_currpage_code,0,6)  = 'REVIEW' then
      if substr(p_page_code,0,6)  = 'REVIEW'then
         return 'N'   ;
      end if;
   END IF ;

   -- Always show "Return to List" OR "Return to Actions List" - but never both
   if p_page_code = 'RETURN_TO_ACT_LIST' then
      return p_action_list;
   end if;

   if p_page_code = 'RETURN_TO_LIST' then
     if p_action_list = 'Y' then
          return 'N';
     else
          return 'Y';
     end if;
  end if;


   -- "ADD ANOTHER" only in CI Create and Action Create page
   IF p_page_code = 'ADD_ANOTHER' then
      if p_currpage_code = 'CREATE_ACTION'
        OR  p_currpage_code = 'CREATE_PAGE' THEN
         return 'Y';
      else
         return 'N';
      end if;
   END IF;

  -- "Stay in this page" only in Update pages
   IF p_page_code = 'SAME_PAGE' then
      if (p_currpage_code = 'CI_DETAILS'
         OR p_currpage_code = 'UPDATE_STATUS_OVERVIEW'
         OR p_currpage_code = 'IMPACT_DETAILS'
         OR p_currpage_code = 'UPDATE_RESOLUTION' ) THEN
         return 'Y';
      else
         return 'N';
      end if;
   END IF;

   --return 'Y';

   IF p_ci_id is NULL  then  -- Create page.
     if p_page_code = 'REVIEW_CI' then   -- show "Review and Submit" in Create page
         return 'N';
     end if;
   END IF ;


   IF p_ci_id is NOT NULL
     AND p_page_code  = 'CREATE_ACTION' THEN
           l_check_update_access   := nvl(pa_ci_security_pkg.check_create_action(p_ci_id),'F');
           if l_check_update_access <> 'T' then
                     return 'N';
           end if;
   END IF;


   --l_check_view_access   := pa_ci_security_pkg.check_view_access(p_ci_id);

   -- Following pages require UPDATE access
  -- if p_page_code    = 'ADD_COMMENT'
   if p_ci_id is NOT NULL
    AND ( p_page_code  = 'CI_DETAILS'
     ---OR p_page_code  = 'CREATE_ACTION'
     OR p_page_code  = 'INCLUDE_CHANGE_REQUEST'
     OR p_page_code  = 'UPDATE_RESOLUTION'
     OR p_page_code  = 'UPDATE_STATUS_OVERVIEW'
     OR p_page_code  = 'RELATED_ITEM'
     OR p_page_code  = 'ADD_ATTACHMENTS')
                                        THEN
     l_check_update_access   := nvl(pa_ci_security_pkg.check_update_access(p_ci_id),'F');

     if l_check_update_access <> 'T' then
          return 'N';
     end if;
   end if;

   -- Only show either "Review" or "Review and Submit" selection (never both)
   -- based on status and security
   if p_ci_id is NOT NULL
      AND ( p_page_code = 'REVIEW_AND_SUB_CI'  OR  p_page_code = 'REVIEW_CI') then
          if  submitAllowed (NULL,NULL,NULL,getCISystemStatus(p_ci_id)) = 'Y' then
                l_stat_change := nvl(pa_ci_security_pkg.check_change_status_access(p_ci_id),'F');

                if l_stat_change = 'T' then
                      if p_page_code = 'REVIEW_CI' then
                           return 'N'; -- don't show "Review", allowed to change status
                   end if;
                else
                   if p_page_code = 'REVIEW_AND_SUB_CI' then
                      return 'N'; --don't show "Review and Submit", user not allowed to change status
                   end if;
                end if;
           else
                if p_page_code = 'REVIEW_AND_SUB_CI' then
                      return 'N'; --don't show "Review and Submit", user not allowed to change status
                end if;
           end if;
   end if;

   -- this logic executed for ALL pages, including CREATE page
   If ( p_page_code = 'IMPLEMENT_IMPACT'
           OR p_page_code ='IMPACT_DETAILS') then
           if (p_type_id is NULL) then
               l_ci_type_has_impact   :=  nvl(isCITypehasimpact(p_ci_id ),'N');
            else
               l_ci_type_has_impact   :=  nvl(TypeHasImpact(p_type_id ),'N');
           end if;

        if l_ci_type_has_impact ='Y' then
           if ( p_page_code = 'IMPLEMENT_IMPACT') then
               if pa_ci_security_pkg.check_implement_impact_access(p_ci_id) <> 'Y' THEN
                  return 'N';
               end if;
           end if;
        else
           return 'N';
        end if;
   END IF ;

   -- this logic NOT executed for CREATE page
   if p_ci_id is NOT NULL
      AND  p_status_control is not null then
     l_ci_status            :=  getCIStatus(p_ci_id) ;
     if pa_control_items_utils.CheckCIActionAllowed(
                 'CONTROL_ITEM',
                 l_ci_status ,
                 p_status_control ) <> 'Y'  then
          return 'N';
     end if;
   END IF;


   RETURN 'Y'  ;

 EXCEPTION
   WHEN OTHERS THEN
        RAISE ;
 END CheckValidNextPage ;*/

  PROCEDURE checkandstartworkflow
   (
    p_api_version			IN NUMBER :=  1.0,
    p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
    p_commit			IN VARCHAR2 := FND_API.g_false,
    p_validate_only		IN VARCHAR2 := FND_API.g_true,
    p_max_msg_count		IN NUMBER := FND_API.g_miss_num,

    p_ci_id       in NUMBER,
    p_status_code IN VARCHAR2,

    x_msg_count      out NOCOPY     NUMBER,
    x_msg_data       out NOCOPY      VARCHAR2,
    x_return_status    OUT NOCOPY    VARCHAR2
    ) is

       CURSOR get_wf_info
	 IS
	    SELECT workflow_item_type, workflow_process, enable_wf_flag
	      FROM pa_project_statuses
	      WHERE status_type = 'CONTROL_ITEM'
	      AND project_status_code = p_status_code;

       l_wf_item_type VARCHAR2(30);
       l_wf_process_name VARCHAR2(30);
       l_wf_enable VARCHAR2(1);
       l_item_key VARCHAR2(240);

 BEGIN

      -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then
      OPEN get_wf_info;
      FETCH get_wf_info INTO l_wf_item_type, l_wf_process_name, l_wf_enable;

       --debug_msg_s1 ('start workflow ' || p_status_code);
       IF get_wf_info%found AND l_wf_enable = 'Y'
	 AND l_wf_item_type IS NOT NULL AND
	   l_wf_process_name IS NOT NULL THEN

	 --debug_msg_s1 ('start workflow ' || l_wf_item_type || ':' || l_wf_process_name);

	  pa_control_items_workflow.start_workflow
		    (
		     l_wf_item_type
		     , l_wf_process_name
		     , p_ci_id
		     , l_item_key
		     , x_msg_count
		     , x_msg_data
		     , x_return_status
		     );

	   --debug_msg_s1 ('after start workflow ' || l_wf_item_type || ':' || l_wf_process_name);

      END IF;

      CLOSE get_wf_info;

    END IF;

 END;


 PROCEDURE CancelWorkflow
   (
    p_api_version			IN NUMBER :=  1.0,
    p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
    p_commit			IN VARCHAR2 := FND_API.g_false,
    p_validate_only		IN VARCHAR2 := FND_API.g_true,
    p_max_msg_count		IN NUMBER := FND_API.g_miss_num,

    p_ci_id       in NUMBER,

    x_msg_count      out NOCOPY     NUMBER,
    x_msg_data       out NOCOPY      VARCHAR2,
    x_return_status    OUT NOCOPY    VARCHAR2
    ) is



       l_wf_item_type VARCHAR2(30);
       l_item_key VARCHAR2(240);
       l_wf_status VARCHAR2(30);
       l_project_id NUMBER;


       CURSOR get_item_key IS
	  SELECT MAX(pwp.item_key), max(pwp.item_type)
	    from pa_wf_processes pwp, pa_project_statuses pps
	    where pwp.item_type = pps.WORKFLOW_ITEM_TYPE
	    and pps.status_type = 'CONTROL_ITEM'
	    and pps.project_status_code =  'CI_SUBMITTED'
	    AND entity_key2 = p_ci_id
	    AND pwp.wf_type_code  = 'Control Item'
	    AND pwp.entity_key1 = l_project_id;


       CURSOR get_wf_status IS
       select  'Y' FROM dual
	 WHERE exists
	 (SELECT *
	 from wf_item_activity_statuses wias, pa_project_statuses pps
	 WHERE wias.item_type = pps.WORKFLOW_ITEM_TYPE
	 AND wias.item_key = l_item_key
	  AND wias.activity_status = 'ACTIVE'
	  AND pps.status_type = 'CONTROL_ITEM'
	  AND pps.project_status_code =  'CI_SUBMITTED');

       CURSOR get_project_id
	 IS
	    SELECT project_id
	      FROM pa_control_items
	      WHERE ci_id = p_ci_id;

 BEGIN

      -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN get_project_id;
    FETCH get_project_id INTO l_project_id;
    CLOSE get_project_id;


    IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then
      OPEN get_item_key;
      FETCH get_item_key INTO l_item_key, l_wf_item_type;

      IF get_item_key%found THEN
	 OPEN get_wf_status;
	FETCH get_wf_status INTO l_wf_status;

	IF (get_wf_status%notfound or
	    l_wf_status <> 'Y' ) THEN
            NULL;

	 else

	   --debug_msg_s1 ('b4 canceling workflow ' || x_return_status);
	   pa_control_items_workflow.cancel_workflow
	     (
	      l_wf_item_type
	      , l_item_key
	      , x_msg_count
	      , x_msg_data
	      , x_return_status
	      );



	END IF;
        close get_wf_status;  /*Bug 3876221.Closing the cursor get_wf_status */

      END IF;

      CLOSE get_item_key;

      --debug_msg_s1 ('after canceling workflow ' || x_return_status);

    END IF;

 END;

  PROCEDURE ChangeCIStatus (
		 p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
		 ,p_commit               IN     VARCHAR2 := FND_API.g_false
		 ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
		 ,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num
		 ,p_ci_id    in number
		 ,p_status   in varchar2
		 ,p_comment   in VARCHAR2 := null
		 ,p_enforce_security  in Varchar2 DEFAULT 'Y'
		 ,p_record_version_number    IN NUMBER
		 ,x_num_of_actions    OUT NOCOPY  NUMBER
		 ,x_return_status        OUT NOCOPY    VARCHAR2
		 ,x_msg_count            OUT NOCOPY    NUMBER
		 ,x_msg_data             OUT NOCOPY    VARCHAR2 )
   IS
      CURSOR get_ci_info
	IS
	   SELECT pci.status_code, pci.project_id
	     FROM pa_control_items pci
	     WHERE ci_id = p_ci_id;

      CURSOR get_status_name(l_code varchar2)
	IS SELECT meaning
	  FROM pa_lookups
	  WHERE lookup_type = 'CONTROL_ITEM_SYSTEM_STATUS'
	  AND lookup_code = l_code;

        CURSOR get_control_item_type
	  IS
	     SELECT pl.meaning,pl.lookup_code
	       FROM pa_lookups pl, pa_control_items pci, pa_ci_types_b pcit
	       WHERE
	       pl.lookup_type = 'PA_CI_TYPE_CLASSES'
	       and pci.ci_type_id = pcit.ci_type_id
	       and pl.lookup_code = pcit.ci_type_class_code
	       AND pci.ci_id = p_ci_id;

	l_tp VARCHAR2(1);
	l_project_id NUMBER;

	CURSOR check_if_fin_impact_exists
	  is
	  SELECT 'Y' FROM dual
	    WHERE exists
	    (
	     SELECT * FROM pa_ci_impacts
	     WHERE ci_id = p_ci_id
	     AND impact_type_code = 'FINPLAN'
	     );

        CURSOR c_submit_status(p_project_status_code varchar2) is
         select 'Y', wf_success_status_code from pa_project_statuses
          where project_status_code = p_project_status_code
            and enable_wf_flag = 'Y'
            and workflow_item_type is not null
            and workflow_process is not null
            and wf_success_status_code is not null
            and wf_failure_status_code is not null;


      l_curr_status VARCHAR2(30);
      l_new_status VARCHAR2(30);
      l_ret boolean;
      l_msg_index_out        NUMBER;
      l_approval_required VARCHAR2(1);
      l_type VARCHAR2(30);
      l_temp VARCHAR2(1);
      l_t1 VARCHAR2(80);
      l_t2 VARCHAR2(80);
      l_t3 VARCHAR2(200);
      l_type_code VARCHAR2(80);
      l_start_wf VARCHAR2(1) := 'Y';

      l_curr_sys_status VARCHAR2(30);
      l_next_sys_status VARCHAR2(30);
      l_submit_status   VARCHAR2(30);
      l_submit_status_flag   VARCHAR2(1);
      l_resolution_req      VARCHAR2(1);
      l_resolution_req_cls  VARCHAR2(1);




 BEGIN

    IF p_init_msg_list = FND_API.G_TRUE THEN
       fnd_msg_pub.initialize;
    END IF;

    x_msg_count := 0;
    x_msg_data := '';

    -- Initialize the Error Stack
    IF P_PA_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_UTILS.ChangeCIStatus');
    END IF;

    pa_debug.write_file('ChangeCiStatus: p_pa_debug_mode :'||p_pa_debug_mode);

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN get_ci_info;
    FETCH get_ci_info INTO l_curr_status, l_project_id;
    CLOSE get_ci_info;

    l_new_status := p_status;

         ChangeCIStatusValidate (
                                  p_init_msg_list      => p_init_msg_list
                                 ,p_commit             => p_commit
                                 ,p_validate_only      => p_validate_only
                                 ,p_max_msg_count      => p_max_msg_count
                                 ,p_ci_id              => p_ci_id
                                 ,p_status             => p_status
                                 ,p_enforce_security   => p_enforce_security
                                 ,x_resolution_req     => l_resolution_req
                                 ,x_resolution_req_cls => l_resolution_req_cls
                                 ,x_start_wf           => l_start_wf
                                 ,x_new_status         => l_new_status
                                 ,x_num_of_actions     => x_num_of_actions
                                 ,x_return_status      => x_return_status
                                 ,x_msg_count          => x_msg_count
                                 ,x_msg_data           => x_msg_data);


      IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
--        debug_msg_s1 ('6 ' || x_return_status);

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('ChangeCiStatus: before call to pa_control_items_pvt.UPDATE_CONTROL_ITEM_STATUS');
         END IF;

         pa_control_items_pvt.UPDATE_CONTROL_ITEM_STATUS (
                                                          1.0,
                                                          p_init_msg_list,
                                                          p_commit,
                                                          p_validate_only,
                                                          p_max_msg_count,
                                                          p_ci_id,
                                                          l_new_status,
                                                          p_record_version_number,
                                                          x_return_status,
                                                          x_msg_count,
                                                          x_msg_data
                                                          );
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('ChangeCiStatus: after call to pa_control_items_pvt.UPDATE_CONTROL_ITEM_STATUS');
         END IF;


         --Bug # 4618856 - if statement is added to check the return status
         IF  (x_return_status = 'S') THEN

        /* Bug#3297238: call the insert table handlers of pa_obj_status_changes and pa_ci_comments here */
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('ChangeCiStatus: before call to ADD_STATUS_CHANGE_COMMENT');
               END IF;

               DBMS_LOCK.SLEEP(1);  -- Bug 7022037

               ADD_STATUS_CHANGE_COMMENT( p_object_type => 'PA_CI_TYPES'
                                         ,p_object_id   => p_ci_id
                                         ,p_type_code   => 'CHANGE_STATUS'
                                         ,p_status_type  => 'CONTROL_ITEM'
                                         ,p_new_project_status => l_new_status
                                         ,p_old_project_status => l_curr_status
                                         ,p_comment            => p_comment
                                         ,x_return_status      => x_return_status
                                         ,x_msg_count          => x_msg_count
                                         ,x_msg_data           => x_msg_data );

               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('ChangeCiStatus: after call to ADD_STATUS_CHANGE_COMMENT');
               END IF;
         END IF;

      END IF;


      --debug_msg_s1 ('after change the status ' || x_return_status);

      IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

                 PostChangeCIStatus (
                                          p_init_msg_list
                                         ,p_commit
                                         ,p_validate_only
                                         ,p_max_msg_count
                                         ,p_ci_id
                                         ,l_curr_status
                                         ,l_new_status
                                         ,l_start_wf
                                         ,p_enforce_security
                                         ,x_num_of_actions
                                         ,x_return_status
                                         ,x_msg_count
                                         ,x_msg_data    );



      END IF;

         -- Commit if the flag is set and there is no error
      IF (p_commit = FND_API.G_TRUE AND x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('ChangeCiStatus: before COMMIT');
         END IF;

         COMMIT;

      END IF;

      x_msg_count :=  FND_MSG_PUB.Count_Msg;

      IF x_msg_count = 1 THEN
         pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                               ,p_msg_index     => 1
                                               ,p_data          => x_msg_data
                                               ,p_msg_index_out => l_msg_index_out
                                               );
      END IF;

      Pa_Debug.Reset_Err_Stack;

EXCEPTION
  WHEN OTHERS THEN

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('ChangeCiStatus: in when others exception');
     END IF;

     ROLLBACK;

     x_return_status := 'U';
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_UTILS',
			     p_procedure_name => 'ChangeCIStatus',
                             p_error_text     => SUBSTRB(SQLERRM,1,240));

     fnd_msg_pub.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);

END;



/*-------------------------------------------------------------------------------------
 This function returns hz_parties.party_name for fnd_user.user_id  (IN parameter)
-------------------------------------------------------------------------------------*/
 FUNCTION GetUserName( p_user_id in Number)
 return Varchar2
 is
l_emp_id NUMBER;
l_party_id NUMBER;
 BEGIN
   if p_user_id is NULL then
     return NULL;
   end if;

   IF G_user_id=p_user_id AND
      G_party_name IS NOT NULL THEN
     RETURN G_party_name;
   END IF;


/*Addition for bug 3729296 starts*/

  -- SELECT employee_id,  NVL(customer_id, supplier_id) Commented for Bug 4527617
  SELECT employee_id,  NVL(person_party_id, supplier_id) -- For Bug 4527617
  INTO l_emp_id, l_party_id
  FROM fnd_user
  WHERE user_id = p_user_id;



IF (l_party_id > 0) THEN --If and ELSIF condtions interchanged for bug 8362886
   SELECT party_name
   INTO G_party_name
   FROM hz_parties
   WHERE party_id = l_party_id;
ELSIF l_emp_id>0 THEN
    SELECT full_name
    INTO G_party_name
    FROM per_all_people_f
    WHERE person_id = l_emp_id
    and trunc(sysdate) between trunc(EFFECTIVE_START_DATE) and trunc(EFFECTIVE_END_DATE)
    and (CURRENT_EMPLOYEE_FLAG = 'Y' or CURRENT_NPW_FLAG = 'Y'); /* Added OR condition for bug 7132968 */
END IF;
/*Addition for bug 3729296 ends*/

   G_user_id:=p_user_id;
   G_party_id := -999; --Resetting G_party_id to -999 value for bug#5676456
   RETURN G_party_name;
EXCEPTION

 WHEN TOO_MANY_ROWS THEN
        RETURN NULL ;
 WHEN NO_DATA_FOUND THEN
        RETURN NULL ;
 WHEN OTHERS THEN
       RETURN NULL;


 END GetUserName;

/*-------------------------------------------------------------------------------------
 This function returns hz_parties.party_id for fnd_user.user_id  (IN parameter)
-------------------------------------------------------------------------------------*/
 FUNCTION GetPartyId( p_user_id in Number)
 return NUMBER
is
  l_emp_id NUMBER:=-999;
BEGIN
  IF p_user_id IS NULL THEN
    RETURN NULL;
  END IF;

  IF G_user_id=p_user_id AND G_party_id <> -999 THEN --added second condition for bug#5676456
    RETURN G_party_id;
  END IF;

  -- SELECT employee_id,  NVL(customer_id, supplier_id) Commented for Bug 4527617
  SELECT employee_id,  NVL(person_party_id, supplier_id) -- For Bug 4527617
  INTO l_emp_id, G_party_id
  FROM fnd_user
  WHERE user_id = p_user_id;

  IF l_emp_id>0 THEN
    SELECT party_id
    INTO G_party_id
    FROM per_all_people_f
    WHERE person_id = l_emp_id
    AND ROWNUM=1;
  END IF;

  G_user_id:=p_user_id;
  G_party_name:=NULL;

  RETURN G_party_id;


EXCEPTION
 WHEN OTHERS THEN
        G_user_id:=-999;
        RETURN NULL;

END GetPartyId;




 FUNCTION CheckApprovalRequired(p_ci_id in Number)
 return Varchar2
 is
    l_approval_required varchar2(1) := 'N';
    l_type VARCHAR2(30);

 BEGIN
 if p_ci_id is NULL then
    return NULL;
 end if;

--start:    23-July-2009   cklee     Bug: 8580992 E&C enhancement
/***
 SELECT ci_type_class_code, approval_required_flag
   INTO l_type, l_approval_required
   FROM pa_ci_types_b cit,
        pa_control_items ci
 WHERE ci.ci_id = p_ci_id
   and cit.ci_type_id = ci.ci_type_id;

 IF l_type IN ('CHANGE_ORDER', 'CHANGE_REQUEST') THEN
   -- for change request and change order the approval_required flag means
   --  auto approval flag
   IF l_approval_required = 'N' THEN
     l_approval_required := 'Y';
   ELSE
     l_approval_required := 'A';
   END IF;
 END IF;
***/
 SELECT (case cit.approval_type_code
           when 'STANDARD' THEN 'Y'
           when 'EXTERNAL_APPROVAL' THEN 'Y'
           when 'AUTOMATIC_APPROVAL' THEN 'A'
           else 'A'
		 end ) l_approval_required
   INTO l_approval_required
   FROM pa_ci_types_b cit,
        pa_control_items ci
 WHERE ci.ci_id = p_ci_id
   and cit.ci_type_id = ci.ci_type_id
   and cit.ci_type_class_code IN ('CHANGE_ORDER', 'CHANGE_REQUEST');

--end:    23-July-2009   cklee     Bug: 8580992 E&C enhancement

 return l_approval_required;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END CheckApprovalRequired;



 FUNCTION CheckResolutionRequired(p_ci_id in Number)
 return Varchar2
 is
  l_resolution_required varchar2(1) := 'N';
 BEGIN
 if p_ci_id is NULL then
    return NULL;
 end if;

 select
    resolution_required_flag into l_resolution_required
 from pa_ci_types_b cit
     ,pa_control_items ci
 where ci.ci_id = p_ci_id
 and   cit.ci_type_id = ci.ci_type_id;

 return l_resolution_required;

EXCEPTION
 WHEN OTHERS THEN
       RETURN NULL;

END CheckResolutionRequired;

 FUNCTION CheckHasResolution(p_ci_id in Number)
 return Varchar2
 is
  cursor get_resolution_info is
 select
    resolution_required_flag, resolution_code_id, resolution
 from pa_ci_types_b cit
     ,pa_control_items ci
 where ci.ci_id = p_ci_id
 and   cit.ci_type_id = ci.ci_type_id;

  l_has_resolution varchar2(1) := 'Y';
  l_res_required  pa_ci_types_vl.resolution_required_flag%TYPE;
  l_res_code pa_control_items.resolution_code_id%TYPE;
  l_res_comment pa_control_items.resolution%TYPE;
 BEGIN
 if p_ci_id is NULL then
    return NULL;
 end if;

 OPEN get_resolution_info;
      FETCH get_resolution_info INTO l_res_required, l_res_code, l_res_comment;

      IF get_resolution_info%found AND l_res_required = 'Y'THEN
         if l_res_code is NULL or l_res_comment is NULL then
            l_has_resolution := 'N';
         end if;
      END IF;
      CLOSE get_resolution_info;

 return l_has_resolution;

END CheckHasResolution;

FUNCTION GetCITypeClassCode(p_ci_id in Number)
 return Varchar2
 is
  l_type_class_code pa_ci_types_vl.ci_type_class_code%TYPE;
 BEGIN
 if p_ci_id is NULL then
    return NULL;
 end if;

 select
    ci_type_class_code into l_type_class_code
 from pa_ci_types_b cit
     ,pa_control_items ci
 where ci.ci_id = p_ci_id
 and   cit.ci_type_id = ci.ci_type_id;

 return l_type_class_code;

EXCEPTION
 WHEN OTHERS THEN
       RETURN NULL;

END GetCITypeClassCode;

/*----------------------------------------------------------------------------
  Function to return SYSYEM status of control Item
  -----------------------------------------------------------------------------*/
  FUNCTION getCISystemStatus ( p_CI_id IN NUMBER)
  return VARCHAR2
  is
  l_ci_system_status pa_project_statuses.project_system_status_code%TYPE := NULL ;

  BEGIN
     IF p_CI_id is not NULL then
          select ps.project_system_status_code
          into l_ci_system_status
          from pa_control_items ci
              ,pa_project_statuses ps
        where ci_id = p_ci_id
          and ps.project_status_code = nvl(ci.status_code,' ');
     END IF ;

     return l_ci_system_status;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL ;
    WHEN OTHERS THEN RAISE ;

  END getCISystemStatus ;

/*----------------------------------------------------------------------------
  Function to return SYSYEM status for a ci statu_code
  -----------------------------------------------------------------------------*/
FUNCTION getSystemStatus ( p_status_code IN VARCHAR2)
  return VARCHAR2
  is
  l_ci_system_status pa_project_statuses.project_system_status_code%TYPE := NULL ;

  BEGIN
     IF p_status_code is  not NULL then
          select ps.project_system_status_code
          into l_ci_system_status
          from
              pa_project_statuses ps
          where  ps.project_status_code = nvl(p_status_code,' ');
     END IF ;

     return l_ci_system_status;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL ;
    WHEN OTHERS THEN RAISE ;

END getSystemStatus ;

FUNCTION deleteAllowed ( p_ci_id         IN NUMBER   := NULL
                        ,p_owner_id      IN NUMBER   := NULL
                        ,p_created_by_id IN NUMBER   := NULL
                        ,p_system_status IN VARCHAR2 := NULL)
  return VARCHAR2
  is
  l_system_status pa_project_statuses.project_system_status_code%TYPE := NULL ;
  BEGIN
     IF (p_system_status is not NULL AND p_system_status = 'CI_DRAFT') then
          return 'Y';
     END IF ;

     IF (p_ci_id is not null) then
        l_system_status := getCISystemStatus(p_ci_id);
        IF l_system_status is not NULL AND l_system_status = 'CI_DRAFT' then
          return 'Y';
        END IF ;
     END IF;

     return 'N';

  EXCEPTION
    WHEN OTHERS THEN RAISE ;
END deleteAllowed;


FUNCTION closeAllowed (  p_ci_id         IN NUMBER   := NULL
                        ,p_owner_id      IN NUMBER   := NULL
                        ,p_created_by_id IN NUMBER   := NULL
                        ,p_system_status IN VARCHAR2 := NULL)
  return VARCHAR2
  is

  l_type     VARCHAR2(30) := NULL;
  l_approval VARCHAR2(1)  := 'Y';

  BEGIN

     l_type := getcitypeclasscode(p_ci_id);

     -- Change Requests cannot be closed
     IF l_type is not null and l_type = 'CHANGE_REQUEST' THEN
          return 'N';
     END IF ;

     --approved Change Orders and Issues may be closed
     IF p_system_status is not NULL AND p_system_status = 'CI_APPROVED' then
          return 'Y';
     END IF ;

     --"WORKING" Issues may be closed when approval not required
     IF l_type is not null and l_type = 'ISSUE'
        AND p_system_status is not NULL
        AND p_system_status = 'CI_WORKING' THEN
        l_approval := CheckApprovalRequired(p_ci_id);
        IF l_approval is NOT NULL AND l_approval = 'N' THEN
             return 'Y';
        END IF;
     END IF;
     return 'N';

  EXCEPTION
    WHEN OTHERS THEN RAISE ;
END closeAllowed;


FUNCTION submitAllowed ( p_ci_id         IN NUMBER   := NULL
                        ,p_owner_id      IN NUMBER   := NULL
                        ,p_created_by_id IN NUMBER   := NULL
                        ,p_system_status IN VARCHAR2 := NULL)

  return VARCHAR2
  is

  l_approval VARCHAR2(1) := 'N';

  BEGIN

     if p_ci_id is NULL then
        return 'N';
     end if;

     l_approval := CheckApprovalRequired(p_ci_id);
     IF l_approval is not NULL and l_approval <> 'N' THEN
         IF p_system_status is not NULL AND p_system_status = 'CI_WORKING' then
              return 'Y';
         END IF ;
     END IF;
     return 'N';

  EXCEPTION
    WHEN OTHERS THEN RAISE ;
END submitAllowed;


/*----------------------------------------------------------------------------
Function returns Y when there are non-DRAFT control items in a project.
         returns N when there are NO control items OR all all project control
         items are in DRAFT status, i.e. may be deleted.
NOTE:    this function returns NULL when IN parm, p_project_id, is NULL.
  -----------------------------------------------------------------------------*/

FUNCTION CheckNonDraftCI(p_project_id in Number)
return Varchar2

  is
  cursor c_non_draft_ci is
      select
      ci_id
     from pa_control_items
     ,pa_project_statuses
     where pa_control_items.project_id = p_project_id
     and   pa_control_items.status_code = pa_project_statuses.project_status_code
     and   pa_project_statuses.project_system_status_code <> 'CI_DRAFT';

  publishedCI        c_non_draft_ci%rowtype;
  hasNonDraftCI      VARCHAR2(1) := 'Y';

BEGIN
  if p_project_id is NULL then
     return NULL;
  end if;
  open c_non_draft_ci;
  fetch c_non_draft_ci into publishedCI;
  if (c_non_draft_ci%NOTFOUND) then
     hasNonDraftCI := 'N';
  end if;
  close c_non_draft_ci;

  return hasNonDraftCI;

EXCEPTION

 WHEN NO_DATA_FOUND THEN
        RETURN NULL ;
 WHEN OTHERS THEN
       RETURN NULL;

END CheckNonDraftCI;

/*----------------------------------------------------------------------
 This function retrieves hz_party.party_id for a given name
 Obsoleted by MTHAI
----------------------------------------------------------------------*/
function GET_PARTY_ID_FROM_NAME(p_name IN VARCHAR2
) return NUMBER is
BEGIN
     return -999;
END GET_PARTY_ID_FROM_NAME;


FUNCTION check_control_item_exists(
  p_project_id IN NUMBER,
  p_task_id IN NUMBER default NULL)
RETURN NUMBER
IS
  tmp NUMBER;
BEGIN
  SELECT 1
  INTO tmp
  FROM pa_control_items
  WHERE project_id = p_project_id
    AND (   (    p_task_id IS NOT NULL
             AND object_type='PA_TASKS'
             AND object_id=p_task_id)
         OR p_task_id IS NULL)
    AND ROWNUM = 1;

  RETURN 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END check_control_item_exists;

FUNCTION check_class_category_in_use(
  p_class_category IN VARCHAR2)
RETURN NUMBER
IS
  tmp NUMBER;
BEGIN
  SELECT 1
  INTO tmp
  FROM pa_ci_types_b
  WHERE (   classification_category = p_class_category
         OR reason_category = p_class_category
         OR resolution_category = p_class_category)
    AND ROWNUM = 1;

  RETURN 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END check_class_category_in_use;

FUNCTION check_class_code_in_use(
  p_class_category IN VARCHAR2,
  p_class_code IN VARCHAR2)
RETURN NUMBER
IS
  tmp NUMBER;
BEGIN
  SELECT 1
  INTO tmp
  FROM pa_control_items ci,
       pa_class_codes cc
  WHERE cc.class_category = p_class_category
    AND cc.class_code = p_class_code
    AND (   ci.classification_code_id = cc.class_code_id
         OR ci.reason_code_id         = cc.class_code_id
         OR ci.resolution_code_id     = cc.class_code_id)
    AND ROWNUM = 1;

  RETURN 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END check_class_code_in_use;

FUNCTION check_role_in_use(
  p_project_role_id IN NUMBER)
RETURN NUMBER
IS
  tmp NUMBER;
BEGIN
  SELECT 1
  INTO tmp
  FROM pa_ci_types_b cit,
       pa_object_dist_lists odl,
       pa_dist_list_items dli
  WHERE odl.object_type = 'PA_CI_TYPES'
    AND odl.object_id = cit.ci_type_id
    AND dli.list_id = odl.list_id
    AND dli.recipient_type = 'PROJECT_ROLE'
    AND dli.recipient_id = p_project_role_id
    AND ROWNUM = 1;

  RETURN 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END check_role_in_use;

FUNCTION check_project_type_in_use(
  p_project_type_id IN NUMBER)
RETURN NUMBER
IS
  tmp NUMBER;
BEGIN
  SELECT 1
  INTO tmp
  FROM pa_ci_type_usage
  WHERE project_type_id = p_project_type_id
    AND ROWNUM = 1;

  RETURN 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END check_project_type_in_use;

/*-------------------------------------------------------------------------------------
  Function Name: CheckNextPageValid
  Usage: Used with with lookup type to determine valid list of next pages to navigate
  Rules: 1. If CI id is null it is the create page.
         2. Exclude the current page from the next page list.
---------------------------------------------------------------------------------------*/

 FUNCTION CheckNextPageValid( p_ci_id           IN NUMBER  := NULL
                             ,p_type_id         IN VARCHAR2
                             ,p_status_control  IN VARCHAR2
                             ,p_page_code       IN VARCHAR2
                             ,p_currpage_code   IN VARCHAR2
                             ,p_type_class_code IN VARCHAR2)


 return VARCHAR2
 is


  l_ci_status            varchar2(30):= NULL ;
  l_ci_type_has_impact   varchar2(1) := 'N';
  l_check_update_access  varchar2(1) := 'F';
  --l_stat_change          varchar2(1) := 'F';

 BEGIN
   IF p_page_code is NULL or  p_currpage_code is NULL then
      return 'N'   ;
   END IF ;

   IF p_page_code = p_currpage_code then
      return 'N'   ;
   END IF ;

   -- "ADD ANOTHER" only in CI Create page
   IF p_page_code = 'ADD_ANOTHER' THEN
-- requirement change: we now have a button (not a drop-down selection)
-- in CREATE page to Add Another
--        if  p_currpage_code = 'CREATE_PAGE' then
--         return 'Y';
--        else
     return 'N';
--        end if;
   END IF;

   IF  p_currpage_code = 'CREATE_PAGE' THEN
       if    p_page_code = 'RESOLUTION'
          OR p_page_code = 'PROGRESS_OVERVIEW'
          OR p_page_code = 'INTERACTION_HISTORY' then
          return 'N';
        end if;
   END IF;


  -- Following pages require UPDATE access
    IF (p_page_code  = 'CO_DETAILS'
     OR p_page_code  = 'ISSUE_DETAILS'
     OR p_page_code  = 'CR_DETAILS'
                                       ) THEN
     if p_currpage_code = 'CI_DETAILS' then
        return 'N';
     end if;
     if p_type_class_code is NULL then
        return 'N';
     end if;
     if    (p_page_code  = 'CO_DETAILS'    and p_type_class_code <> 'CHANGE_ORDER')
        or (p_page_code  = 'CR_DETAILS'    and p_type_class_code <> 'CHANGE_REQUEST')
        or (p_page_code  = 'ISSUE_DETAILS' and p_type_class_code <> 'ISSUE') then
        return 'N';
     end if;

     if p_ci_id is NOT NULL then
        l_check_update_access   := nvl(pa_ci_security_pkg.check_update_access(p_ci_id),'F');
        if l_check_update_access <> 'T' then
          return 'N';
        end if;
     end if;

   end if;

   IF  p_page_code ='IMPACT_DETAILS' then
           if p_currpage_code = 'IMPLEMENT_IMPACT' then
                return 'N';
           end if;

           if (p_type_id is NULL) then
               l_ci_type_has_impact   :=  nvl(isCITypehasimpact(p_ci_id ),'N');
            else
               l_ci_type_has_impact   :=  nvl(TypeHasImpact(p_type_id ),'N');
           end if;

        if l_ci_type_has_impact ='Y' then
           return 'Y';
        else
           return 'N';
        end if;
   END IF ;
   -- this logic NOT executed for CREATE or LIST page
   if p_ci_id is NOT NULL
      AND  p_status_control is not null then
     l_ci_status            :=  getCIStatus(p_ci_id) ;
     if pa_control_items_utils.CheckCIActionAllowed(
                 'CONTROL_ITEM',
                 l_ci_status ,
                 p_status_control ) <> 'Y'  then
          return 'N';
     end if;
   END IF;

   RETURN 'Y'  ;

 EXCEPTION
   WHEN OTHERS THEN
        RAISE ;
 END CheckNextPageValid ;

function get_open_control_items(p_project_id   IN NUMBER,
                                p_object_type  IN VARCHAR2,
                                p_object_id    IN NUMBER,
                                p_item_type    IN VARCHAR2) return number is

  tot_num        NUMBER;
begin

   /*code changes  for bug 5611926 starts here
   merged the similar select for change order/request/issue using the bind variable p_item_type*/
  if (p_item_type = 'ISSUE' or p_item_type = 'CHANGE_ORDER' or p_item_type = 'CHANGE_REQUEST') then
     select count(*)
       into tot_num
       from pa_control_items pci, pa_ci_types_b pctb
      where pci.project_id = p_project_id
        and pci.object_type = p_object_type
        and pci.object_id = p_object_id
        and pci.ci_type_id = pctb.ci_type_id
        and pctb.ci_type_class_Code = p_item_type    --'ISSUE'
        and pci.status_code not in (select project_status_code    /* changes start for Bug 5050836 */
                          from pa_project_statuses
                         where status_type = 'CONTROL_ITEM'
                           and project_system_status_code
                                   in ('CI_DRAFT','CI_CLOSED','CI_CANCELED'));   /*  changes end for Bug 5050836 */

   elsif (p_item_type = 'CHANGE') then
     select count(*)
       into tot_num
       from pa_control_items pci, pa_ci_types_b pctb
      where pci.project_id = p_project_id
        and pci.object_type = p_object_type
        and pci.object_id = p_object_id
        and pci.ci_type_id = pctb.ci_type_id
        and pctb.ci_type_class_Code in ('CHANGE_ORDER','CHANGE_REQUEST')
        and pci.status_code not in (select project_status_code               /* changes start for Bug 5050836 */
                          from pa_project_statuses
                         where status_type = 'CONTROL_ITEM'
                           and project_system_status_code
                                   in ('CI_DRAFT','CI_CLOSED','CI_CANCELED'));    /* changes end for Bug 5050836 */

--   elsif (p_item_type = 'CHANGE_ORDER') then
--     select count(*)
--       into tot_num
--       from pa_control_items pci, pa_ci_types_b pctb
--      where pci.project_id = p_project_id
--        and pci.object_type = p_object_type
--        and pci.object_id = p_object_id
--        and pci.ci_type_id = pctb.ci_type_id
--        and pctb.ci_type_class_Code = 'CHANGE_ORDER'
--        and pci.status_code not in (select project_status_code        /*  changes start for Bug 5050836 */
--                          from pa_project_statuses
--                         where status_type = 'CONTROL_ITEM'
--                           and project_system_status_code
--                                   in ('CI_DRAFT','CI_CLOSED','CI_CANCELED'));    /* changes end for Bug 5050836 */

--   elsif (p_item_type = 'CHANGE_REQUEST') then
--     select count(*)
--       into tot_num
--       from pa_control_items pci, pa_ci_types_b pctb
--      where pci.project_id = p_project_id
--        and pci.object_type = p_object_type
--        and pci.object_id = p_object_id
--        and pci.ci_type_id = pctb.ci_type_id
--        and pctb.ci_type_class_Code = 'CHANGE_REQUEST'
--        and pci.status_code not in (select project_status_code       /* changes start for Bug 5050836 */
--                          from pa_project_statuses
--                         where status_type = 'CONTROL_ITEM'
--                           and project_system_status_code
--                                   in ('CI_DRAFT','CI_CLOSED','CI_CANCELED'));    /* changes end for Bug 5050836 */
   /*code changes  for bug 5611926 ends here*/
   end if;

   return tot_num;

exception when others then
   return 0;
end get_open_control_items;


PROCEDURE GetDiagramUrl(p_project_id    IN  NUMBER,
                        p_ci_id         IN  NUMBER,
                        x_diagramurl    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 	x_return_status OUT NOCOPY VARCHAR2,
                 	x_msg_count     OUT NOCOPY NUMBER,
                 	x_msg_data      OUT NOCOPY VARCHAR2)
IS

	cursor c_wf_type is
	SELECT ps.workflow_item_type,
	       ps.workflow_process
	  FROM pa_project_statuses ps,
	       pa_control_items ci
	 WHERE ci.ci_id = p_ci_id
	   and ci.status_code = ps.project_status_code
	   and ps.enable_wf_flag = 'Y'
	   and ps.wf_success_status_code is NOT NULL
	   and ps.wf_failure_status_code is NOT NULL;

	 CURSOR get_last_workflow_info(p_wf_item_type IN VARCHAR2, p_wf_process IN VARCHAR2) IS
	 SELECT MAX(item_key)
	   FROM pa_wf_processes
	  WHERE item_type = p_wf_item_type
	    AND description = p_wf_process
	    AND entity_key2 = p_ci_id
	    AND entity_key1 = p_project_id
	    AND wf_type_code  = 'Control Item';

	l_diagramUrl 	VARCHAR2(2000);
	l_wf_item_type  pa_project_statuses.workflow_item_type%TYPE;
	l_wf_process    pa_project_statuses.workflow_process%TYPE;
	l_item_key      pa_wf_processes.item_key%TYPE;

BEGIN

	OPEN c_wf_type;
	FETCH c_wf_type INTO l_wf_item_type, l_wf_process;
	CLOSE c_wf_type;

	OPEN get_last_workflow_info(l_wf_item_type, l_wf_process);
	FETCH get_last_workflow_info INTO l_item_key;
	CLOSE get_last_workflow_info;

	l_diagramUrl :=  WF_MONITOR.GetDiagramURL
					(x_agent	=> WF_CORE.TRANSLATE('WF_WEB_AGENT'),
					 x_item_type	=> l_wf_item_type,
				 	 x_item_key	=> l_item_key);
        x_diagramUrl := l_diagramUrl;

EXCEPTION
  WHEN OTHERS THEN

     x_return_status := 'U';
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_UTILS',
                             p_procedure_name => 'GetDiagramUrl',
                             p_error_text     => SUBSTRB(SQLERRM,1,240));

     fnd_msg_pub.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
END GetDiagramUrl;


PROCEDURE AbortWorkflow(p_project_id    IN  NUMBER,
                        p_ci_id         IN  NUMBER,
			p_record_version_number IN NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2)
IS
        cursor c_wf_type is
        SELECT ps.workflow_item_type,
               ps.workflow_process
          FROM pa_project_statuses ps,
               pa_control_items ci
         WHERE ci.ci_id = p_ci_id
           and ci.status_code = ps.project_status_code
           and ps.enable_wf_flag = 'Y'
           and ps.wf_success_status_code is NOT NULL
           and ps.wf_failure_status_code is NOT NULL;

         CURSOR get_last_workflow_info(p_wf_item_type IN VARCHAR2, p_wf_process IN VARCHAR2) IS
         SELECT MAX(item_key)
           FROM pa_wf_processes
          WHERE item_type = p_wf_item_type
            AND description = p_wf_process
            AND entity_key2 = p_ci_id
            AND entity_key1 = p_project_id
            AND wf_type_code  = 'Control Item';

         CURSOR get_prev_status(p_ci_id IN VARCHAR2) is
	 select a.old_project_status_code, a.new_project_status_code
	   from (select obj_status_change_id,
  	        	old_project_status_code,
  	        	new_project_status_code
		   from pa_obj_status_changes
		 where object_type = 'PA_CI_TYPES'
		   and object_id = p_ci_id
               order by obj_status_change_id desc) a
         where rownum = 1;

        l_diagramUrl    VARCHAR2(2000);
        l_wf_item_type  pa_project_statuses.workflow_item_type%TYPE;
        l_wf_process    pa_project_statuses.workflow_process%TYPE;
        l_item_key      pa_wf_processes.item_key%TYPE;
        l_prev_status   pa_obj_status_changes.old_project_status_code%TYPE;
        l_curr_status   pa_obj_status_changes.new_project_status_code%TYPE;
        l_comment       pa_ci_comments.comment_text%TYPE;
BEGIN

        OPEN c_wf_type;
        FETCH c_wf_type INTO l_wf_item_type, l_wf_process;
        CLOSE c_wf_type;

        OPEN get_last_workflow_info(l_wf_item_type, l_wf_process);
        FETCH get_last_workflow_info INTO l_item_key;
        CLOSE get_last_workflow_info;

        OPEN get_prev_status(p_ci_id);
        FETCH get_prev_status INTO l_prev_status, l_curr_status;
        CLOSE get_prev_status;

	pa_control_items_workflow.cancel_workflow
             (l_wf_item_type,
              l_item_key,
              x_msg_count,
              x_msg_data,
              x_return_status);

	/* call pa_control_items_utils.changecistatus  api to revert the status;
        PA_CONTROL_ITEMS_UTILS.ChangeCIStatus (
                          p_init_msg_list         => FND_API.G_TRUE
                         ,p_validate_only         => FND_API.G_FALSE
                         ,p_ci_id                 => p_ci_id
                         ,p_status                => l_prev_status
                         ,p_record_version_number => p_record_version_number
                         ,x_num_of_actions        => l_open_actions_num
                         ,x_return_status         => x_return_status
                         ,x_msg_count             => x_msg_count
                         ,x_msg_data              => x_msg_data);
	*/

         pa_control_items_pvt.UPDATE_CONTROL_ITEM_STATUS (
                          p_api_version 	  => 1.0
                         ,p_init_msg_list         => FND_API.G_TRUE
                         ,p_validate_only         => FND_API.G_FALSE
                         ,p_ci_id		  => p_ci_id
                         ,p_status_code 	  => l_prev_status
			 ,p_record_version_number => p_record_version_number
                         ,x_return_status         => x_return_status
                         ,x_msg_count             => x_msg_count
                         ,x_msg_data              => x_msg_data);

        /* Bug#3297238: call the insert table handlers of pa_obj_status_changes and pa_ci_comments here */

	    fnd_message.set_name('PA', 'PA_CI_ABORT_WF_COMMENT');
	    l_comment := fnd_message.get;

               ADD_STATUS_CHANGE_COMMENT( p_object_type => 'PA_CI_TYPES'
                                         ,p_object_id   => p_ci_id
                                         ,p_type_code   => 'CHANGE_STATUS'
                                         ,p_status_type  => 'CONTROL_ITEM'
                                         ,p_new_project_status => l_prev_status
                                         ,p_old_project_status => l_curr_status
                                         ,p_comment            => l_comment
                                         ,x_return_status      => x_return_status
                                         ,x_msg_count          => x_msg_count
                                         ,x_msg_data           => x_msg_data );


EXCEPTION
  WHEN OTHERS THEN

     x_return_status := 'U';
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_UTILS',
                             p_procedure_name => 'AbortWorkflow',
                             p_error_text     => SUBSTRB(SQLERRM,1,240));

     fnd_msg_pub.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
END AbortWorkflow;


PROCEDURE ADD_STATUS_CHANGE_COMMENT (
                  p_object_type 	IN VARCHAR2
                 ,p_object_id   	IN NUMBER
                 ,p_type_code   	IN VARCHAR2
                 ,p_status_type 	IN VARCHAR2
                 ,p_new_project_status  IN VARCHAR2
                 ,p_old_project_status  IN VARCHAR2
                 ,p_comment   		IN VARCHAR2 := null
                 ,P_CREATED_BY          IN NUMBER default fnd_global.user_id
                 ,P_CREATION_DATE       IN DATE default sysdate
                 ,P_LAST_UPDATED_BY     IN NUMBER default fnd_global.user_id
                 ,P_LAST_UPDATE_DATE    IN DATE default sysdate
                 ,P_LAST_UPDATE_LOGIN   IN NUMBER default fnd_global.user_id
                 ,x_return_status       OUT NOCOPY    VARCHAR2
                 ,x_msg_count           OUT NOCOPY    NUMBER
                 ,x_msg_data            OUT NOCOPY    VARCHAR2 )
IS

    cursor c_status_name(p_status VARCHAR2) is
       select project_status_name
	 from pa_project_statuses
	where status_type = 'CONTROL_ITEM'
	  and project_status_code = p_status;

    l_error_msg_code 	varchar2(30);
    l_ci_comment_id  	NUMBER;
    l_ci_action_id  	NUMBER;
    l_rowid 		VARCHAR2(255);
    l_new_sysstatus     pa_project_statuses.project_system_status_code%TYPE;
    l_old_sysstatus     pa_project_statuses.project_system_status_code%TYPE;
    l_comment_text      pa_ci_comments.comment_text%TYPE;
    l_obj_status_change_id NUMBER;
    l_new_status_name   pa_project_statuses.project_status_name%TYPE;
    l_old_status_name   pa_project_statuses.project_status_name%TYPE;

BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        x_msg_data := 0;

	l_new_sysstatus := getSystemStatus(p_new_project_status);
	l_old_sysstatus := getSystemStatus(p_old_project_status);

	open c_status_name(p_new_project_status);
        fetch c_status_name into l_new_status_name;
	close c_status_name;

	open c_status_name(p_old_project_status);
        fetch c_status_name into l_old_status_name;
	close c_status_name;

        fnd_message.set_name('PA', 'PA_CI_LOG_STATUS_CHANGE');
	fnd_message.set_token('OLD_STATUS', l_old_status_name);
	fnd_message.set_token('NEW_STATUS', l_new_status_name);
	fnd_message.set_token('COMMENT', p_comment);
        l_comment_text := fnd_message.get;

	    SELECT pa_obj_status_changes_s.NEXTVAL
              INTO l_obj_status_change_id
	      FROM dual;

	PA_OBJ_STATUS_CHANGES_PKG.INSERT_ROW (
		  X_ROWID => l_rowid,
		  X_OBJ_STATUS_CHANGE_ID => l_obj_status_change_id,
		  X_OBJECT_TYPE => p_object_type,
		  X_OBJECT_ID => p_object_id,
		  X_STATUS_TYPE => p_status_type,
		  X_NEW_PROJECT_STATUS_CODE => p_new_project_status,
		  X_NEW_PROJECT_SYSTEM_STATUS_CO => l_new_sysstatus,
		  X_OLD_PROJECT_STATUS_CODE => p_old_project_status,
		  X_OLD_PROJECT_SYSTEM_STATUS_CO => l_old_sysstatus,
		  X_CHANGE_COMMENT => p_comment,
                  X_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
                  X_CREATED_BY => P_CREATED_BY,
                  X_CREATION_DATE => P_CREATION_DATE,
                  X_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
                  X_LAST_UPDATE_LOGIN     => P_LAST_UPDATE_LOGIN);

        PA_CI_COMMENTS_PKG.INSERT_ROW(
                P_CI_COMMENT_ID => L_CI_COMMENT_ID,
                P_CI_ID => P_OBJECT_ID,
                P_TYPE_CODE => P_TYPE_CODE,
                P_COMMENT_TEXT => L_COMMENT_TEXT,
                P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
                P_CREATED_BY => P_CREATED_BY,
                P_CREATION_DATE => P_CREATION_DATE,
                P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
                P_LAST_UPDATE_LOGIN     => P_LAST_UPDATE_LOGIN,
                P_CI_ACTION_ID => L_CI_ACTION_ID);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := 'E';
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_UTILS',
                               p_procedure_name => 'ADD_STATUS_CHANGE_COMMENT',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
END ADD_STATUS_CHANGE_COMMENT;

--Bug 4716789 Added an API to delete the data from pa_obj_status_changes
PROCEDURE DELETE_OBJ_STATUS_CHANGES(
		  p_object_type         IN     VARCHAR2
		 ,p_object_id           IN     NUMBER
		 ,x_return_status       OUT NOCOPY    VARCHAR2
                 ,x_msg_count           OUT NOCOPY    NUMBER
                 ,x_msg_data            OUT NOCOPY    VARCHAR2 )
IS
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

       DELETE FROM pa_obj_status_changes
                WHERE object_type = p_object_type
                AND object_id = p_object_id;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_UTILS',
                               p_procedure_name => 'DELETE_OBJ_STATUS_CHANGES',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
   RAISE;
END DELETE_OBJ_STATUS_CHANGES;

PROCEDURE ChangeCIStatusValidate (
                  p_init_msg_list        IN  VARCHAR2 := fnd_api.g_true
                 ,p_commit               IN  VARCHAR2 := FND_API.g_false
                 ,p_validate_only        IN  VARCHAR2 := FND_API.g_true
                 ,p_max_msg_count        IN  NUMBER   := FND_API.g_miss_num
                 ,p_ci_id                IN  NUMBER
                 ,p_status               IN  VARCHAR2
                 ,p_enforce_security     IN  VARCHAR2 DEFAULT 'Y'
                 ,p_resolution_check     IN  VARCHAR2 DEFAULT 'UI'
                 ,x_resolution_req       OUT NOCOPY VARCHAR2
                 ,x_resolution_req_cls   OUT NOCOPY VARCHAR2
                 ,x_start_wf             OUT NOCOPY VARCHAR2
                 ,x_new_status           OUT NOCOPY VARCHAR2
                 ,x_num_of_actions       OUT NOCOPY NUMBER
                 ,x_return_status        OUT NOCOPY VARCHAR2
                 ,x_msg_count            OUT NOCOPY NUMBER
                 ,x_msg_data             OUT NOCOPY VARCHAR2 )
   IS
      CURSOR get_ci_info
        IS
           SELECT pci.status_code, pci.project_id
             FROM pa_control_items pci
             WHERE ci_id = p_ci_id;


      CURSOR get_status_name(l_code varchar2)
        IS SELECT meaning
          FROM pa_lookups
          WHERE lookup_type = 'CONTROL_ITEM_SYSTEM_STATUS'
          AND lookup_code = l_code;

        CURSOR get_control_item_type
          IS
             SELECT pl.meaning,pl.lookup_code
               FROM pa_lookups pl, pa_control_items pci, pa_ci_types_b pcit
               WHERE
               pl.lookup_type = 'PA_CI_TYPE_CLASSES'
               and pci.ci_type_id = pcit.ci_type_id
               and pl.lookup_code = pcit.ci_type_class_code
               AND pci.ci_id = p_ci_id;

        l_tp VARCHAR2(1);
        l_project_id NUMBER;

        CURSOR check_if_fin_impact_exists
          is
          SELECT 'Y' FROM dual
            WHERE exists
            (
             SELECT * FROM pa_ci_impacts
             WHERE ci_id = p_ci_id
             AND impact_type_code like 'FINPLAN%'
             );

        CURSOR c_submit_status(p_project_status_code varchar2) is
         select 'Y', wf_success_status_code from pa_project_statuses
          where project_status_code = p_project_status_code
            and enable_wf_flag = 'Y'
            and workflow_item_type is not null
            and workflow_process is not null
            and wf_success_status_code is not null
            and wf_failure_status_code is not null;


      l_status VARCHAR2(30);
      l_new_status VARCHAR2(30);
      l_ret boolean;
      l_msg_index_out        NUMBER;
      l_approval_required VARCHAR2(1);
      l_type VARCHAR2(30);
      l_temp VARCHAR2(1);
      l_t1 VARCHAR2(80);
      l_t2 VARCHAR2(80);
      l_t3 VARCHAR2(200);
      l_type_code VARCHAR2(80);
      l_start_wf VARCHAR2(1) := 'Y';

      l_curr_sys_status VARCHAR2(30);
      l_next_sys_status VARCHAR2(30);
      l_submit_status   VARCHAR2(30);
      l_submit_status_flag   VARCHAR2(1);



 BEGIN

    IF p_init_msg_list = FND_API.G_TRUE THEN
       fnd_msg_pub.initialize;
    END IF;

    x_msg_count := 0;
    x_msg_data := '';
    x_start_wf := l_start_wf;

    -- Initialize the Error Stack
    IF P_PA_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_UTILS.ChangeCIStatus');
    END IF;

    pa_debug.write_file('ChangeCiStatusValidate: p_pa_debug_mode :'||p_pa_debug_mode);

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN get_ci_info;
    FETCH get_ci_info INTO l_status, l_project_id;
    CLOSE get_ci_info;

    if l_status is NOT NULL and
       p_status is NOT NULL and
       p_status = l_status  then
       return;
    end if;

    l_curr_sys_status := getSystemStatus(l_status);
    l_next_sys_status := getSystemStatus(p_status);

    OPEN get_control_item_type;
    FETCH get_control_item_type INTO l_t3, l_type_code;
    CLOSE get_control_item_type;

    l_new_status := p_status;
    x_new_status := l_new_status;


    IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
         -- Check Security Access for Update
         -- bug fix
         -- do not call secruity check for CR when from APPROVED to CLOSED
         -- or from CLOSED to APPROVED (added by MSU)

         IF (    l_type_code = 'CHANGE_REQUEST'
             AND (   (l_next_sys_status = 'CI_CLOSED' AND l_curr_sys_status = 'CI_APPROVED')
                  OR (l_curr_sys_status = 'CI_CLOSED' AND l_next_sys_status = 'CI_APPROVED') )
             ) then
            NULL;
         ELSE

            l_temp := pa_ci_security_pkg.check_change_status_access(p_ci_id,
                                                                    fnd_global.user_id);

            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('ChangeCiStatusValidate: pa_ci_security_pkg.check_change_status_access :'||l_temp);
            END IF;

            IF (l_temp <> 'T')  THEN
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('ChangeCiStatusValidate: PA_CI_STATUS_UPDATE_INV');
              END IF;
              PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                   ,p_msg_name       => 'PA_CI_STATUS_UPDATE_INV');
              x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
         END IF;
    END IF;


    IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

         OPEN c_submit_status(p_status);
         FETCH c_submit_status INTO l_submit_status_flag, l_submit_status;
         CLOSE c_submit_status;

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('ChangeCiStatusValidate: l_submit_status_flag :'||l_submit_status_flag);
            pa_debug.write_file('ChangeCiStatusValidate: l_submit_status:'||l_submit_status);
         END IF;

         IF l_submit_status_flag = 'Y' THEN

               l_approval_required := checkapprovalrequired (p_ci_id);
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('ChangeCiStatusValidate: l_approval_required :'||l_approval_required);
               END IF;

               IF l_approval_required = 'Y' or l_approval_required = 'A' THEN
                  -- check the type is CR, CO, ISSUE
                  l_type := getcitypeclasscode(p_ci_id);

                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('ChangeCiStatusValidate: l_type :'||l_type);
                  END IF;

                  IF l_type = 'CHANGE_ORDER' OR l_type = 'CHANGE_REQUEST' OR l_type = 'ISSUE' THEN

                     IF (l_type = 'CHANGE_ORDER' OR l_type = 'CHANGE_REQUEST') AND l_approval_required = 'A' THEN
                        OPEN c_submit_status(p_status);
                        FETCH c_submit_status INTO l_submit_status_flag, l_submit_status;
                        CLOSE c_submit_status;

                        l_new_status := l_submit_status;
                        l_start_wf := 'N';
                        x_start_wf := l_start_wf;
                        x_new_status := l_new_status;

                        IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.write_file('ChangeCiStatusValidate: l_new_status :'||l_new_status);
                           pa_debug.write_file('ChangeCiStatusValidate: l_start_wf :'||l_start_wf);
                        END IF;

                     END IF;

                     l_temp := pa_ci_actions_util.check_open_actions_exist (p_ci_id);

                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write_file('ChangeCiStatusValidate: pa_ci_actions_util.check_open_actions_exist :'||l_temp);

                     END IF;

                     IF l_temp = 'Y' THEN
                         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                              ,p_msg_name       => 'PA_CI_OPEN_ACTION_EXISTS');
                         IF P_PA_DEBUG_MODE = 'Y' THEN
                            pa_debug.write_file('ChangeCiStatus: PA_CI_OPEN_ACTION_EXIST');
                         END IF;
                         x_return_status := FND_API.G_RET_STS_ERROR;
                     ELSE
                        -- check resolution is provided
                         IF p_resolution_check = 'UI' THEN
                                IF P_PA_DEBUG_MODE = 'Y' THEN
                                   pa_debug.write_file('ChangeCiStatus: checkresolutionrequired :'||checkresolutionrequired(p_ci_id));
                                END IF;
                                IF checkresolutionrequired(p_ci_id) = 'Y' THEN

                                   IF P_PA_DEBUG_MODE = 'Y' THEN
                                      pa_debug.write_file('ChangeCiStatusValidate: checkhasresolution :'||checkhasresolution (p_ci_id));
                                   END IF;
                                   IF checkhasresolution (p_ci_id) = 'Y' THEN
                                      IF l_type = 'CHANGE_ORDER' OR l_type = 'CHANGE_REQUEST' OR l_type = 'ISSUE' THEN
                                         NULL;
                                      END IF;
                                   ELSE
                                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                                           ,p_msg_name       => 'PA_CI_RESOLUTION_OPEN');
                                      IF P_PA_DEBUG_MODE = 'Y' THEN
                                         pa_debug.write_file('ChangeCiStatus: PA_CI_RESOLUTION_OPEN');
                                      END IF;
                                      x_return_status := FND_API.G_RET_STS_ERROR;
                                   END IF;
                                END IF;
                         ELSIF p_resolution_check = 'AMG' THEN
                                IF P_PA_DEBUG_MODE = 'Y' THEN
                                   pa_debug.write_file('ChangeCiStatus: AMG checkresolutionrequired :'||checkresolutionrequired(p_ci_id));
                                END IF;
                                IF checkresolutionrequired(p_ci_id) = 'Y' THEN
                                   x_resolution_req := 'Y';
                                   IF P_PA_DEBUG_MODE = 'Y' THEN
                                      pa_debug.write_file('ChangeCiStatusValidate: AMG checkhasresolution :'||checkhasresolution (p_ci_id));
                                   END IF;
                                END IF;
                         END IF;  /* IF p_resolution_check = 'UI'  */
                     END IF;  /* if l_temp = 'Y' */

                   ELSE
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_CI_SUBMIT_INV');
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write_file('ChangeCiStatus: PA_CI_SUBMIT_INV');
                      END IF;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;

                ELSE
                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_CI_APPROVAL_NOT_REQ');
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('ChangeCiStatusValidate: PA_CI_APPROVAL_NOT_REQ');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;  /* IF l_approval_required = 'Y' or l_approval_required = 'A' THEN */

            IF  (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               -- check if submit is OK for finacial impact

               OPEN check_if_fin_impact_exists;
               FETCH check_if_fin_impact_exists INTO l_tp;
               CLOSE check_if_fin_impact_exists;

               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('ChangeCiStatusValidate: check_if_fin_impact_exists: '||l_tp);
               END IF;

               IF l_tp = 'Y' THEN

                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write_file('ChangeCiStatus: before call to Pa_Fp_Control_Items_Utils.Fp_Ci_Impact_Submit_Chk');

                     END IF;

                     Pa_Fp_Control_Items_Utils.Fp_Ci_Impact_Submit_Chk
                       ( p_project_id     => l_project_id
                         ,p_ci_id         => p_ci_id
                         ,x_return_status => x_return_status
                         ,x_msg_count    => x_msg_count
                         ,x_msg_data     => x_msg_data) ;

                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write_file('ChangeCiStatusValidate: after call to Pa_Fp_Control_Items_Utils.Fp_Ci_Impact_Submit_Chk');

                     END IF;

               END IF;
            END IF;

      END IF;    /*  IF l_submit_status_flag = 'Y' THEN  */

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write_file('ChangeCiStatusValidate: end of <IF l_submit_status_flag = Y > ');
      END IF;

     IF l_next_sys_status = 'CI_CANCELED' THEN

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('ChangeCiStatusValidate: in <l_next_sys_status = CI_CANCELED> ');
           END IF;
           l_type := getcitypeclasscode(p_ci_id);

           IF l_type = 'CHANGE_ORDER' OR l_type = 'CHANGE_REQUEST' THEN
            -- check if any impact is implemented
                  l_ret := pa_ci_impacts_util.is_any_impact_implemented(p_ci_id);


                  IF (l_ret ) THEN
                     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CANCEL_INV_IMP');
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write_file('ChangeCiStatusValidate: in <l_next_sys_status = CI_CANCELED> PA_CI_CANCEL_INV_IMP');

                     END IF;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
           END IF;

           IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
                   -- cancel workflow
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write_file('ChangeCiStatusValidate: in <l_next_sys_status = CI_CANCELED> before cancelworkflow');

                   END IF;
                   cancelworkflow
                     (
                      1.0,
                      p_init_msg_list           ,
                      p_commit                  ,
                      p_validate_only           ,
                      p_max_msg_count           ,
                      p_ci_id       ,
                      x_msg_count      ,
                      x_msg_data       ,
                      x_return_status
                      );
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write_file('ChangeCiStatusValidate: in <l_next_sys_status = CI_CANCELED> after cancelworkflow');

                   END IF;

           END IF;

     ELSIF l_next_sys_status = 'CI_CLOSED' THEN

            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write_file('ChangeCiStatusValidate: in <l_next_sys_status = CI_CLOSED>');
            END IF;

            l_type := getcitypeclasscode(p_ci_id);

            IF l_type = 'CHANGE_ORDER'  THEN
                -- check if any impact is implemented

                l_ret := pa_ci_impacts_util.is_all_impact_implemented(p_ci_id);

                IF (NOT l_ret ) THEN
                     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_IMP');
                     IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.write_file('ChangeCiStatusValidate: in <l_next_sys_status = CI_CLOSED> PA_CI_CLOSE_INV_IMP');

                     END IF;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
            END IF;

            IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
                l_temp := pa_ci_actions_util.check_open_actions_exist (p_ci_id);

                 IF l_temp = 'Y' THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_ACT');
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write_file('ChangeCiStatusValidate: in <l_next_sys_status = CI_CLOSED> PA_CI_CLOSE_INV_ACT');

                      END IF;
                     x_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;

                 IF p_resolution_check = 'UI' THEN
                         IF checkresolutionrequired(p_ci_id) = 'Y' THEN
                            IF checkhasresolution (p_ci_id) = 'Y' THEN
                               NULL;
                             ELSE
                                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                                   ,p_msg_name       => 'PA_CI_CLOSE_INV_RES');
                                IF P_PA_DEBUG_MODE = 'Y' THEN
                                   pa_debug.write_file('ChangeCiStatus: in <l_next_sys_status = CI_CLOSED> PA_CI_CLOSE_INV_RES');
                                END IF;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                            END IF;
                         END IF;
                 ELSIF p_resolution_check = 'AMG' THEN
                         IF checkresolutionrequired(p_ci_id) = 'Y' THEN
                            x_resolution_req_cls := 'Y';
                         END IF;
                 END IF;

             END IF;


       END IF;

       IF l_curr_sys_status = 'CI_APPROVED' THEN

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('ChangeCiStatus: in <l_curr_sys_status = CI_APPROVED> and');
           END IF;

           IF l_next_sys_status = 'CI_WORKING' THEN
               -- check no impact is implemented
               l_ret := pa_ci_impacts_util.is_any_impact_implemented(p_ci_id);

               IF (l_ret ) THEN
                    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_CI_WORKING_INV_IMP');
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write_file('ChangeCiStatus: in <l_next_sys_status = CI_WORKING> PA_CI_WORKING_INV_IMP');


                    END IF;
                    x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;

            ELSIF l_next_sys_status = 'CI_CLOSED' THEN

               l_type := getcitypeclasscode(p_ci_id);

               -- check all impact are implemented
                IF l_type = 'CHANGE_ORDER' then
                    l_ret := pa_ci_impacts_util.is_all_impact_implemented(p_ci_id);

                   IF (NOT l_ret ) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_IMP');
                      IF P_PA_DEBUG_MODE = 'Y' THEN
                         pa_debug.write_file('ChangeCiStatus: in <l_next_sys_status = CI_CLOSED> PA_CI_CLOSE_INV_IMP');
                      END IF;
                      x_return_status := FND_API.G_RET_STS_ERROR;
                   END IF;
                END IF;

             ELSIF l_next_sys_status = 'CI_CANCELED' THEN
               -- check no impact is implemented

               l_ret := pa_ci_impacts_util.is_any_impact_implemented
                    (p_ci_id);

               IF (l_ret ) THEN
                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_CI_CANCEL_INV_IMP');
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('ChangeCiStatus: in <l_next_sys_status = CI_CANCELED> PA_CI_CANCEL_INV_IMP');
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
             END IF;

       END IF;   /* IF l_curr_sys_status = 'CI_APPROVED' THEN  */

    END if;

EXCEPTION
  WHEN OTHERS THEN

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('ChangeCiStatus: in when others exception');
     END IF;

     ROLLBACK;

     x_return_status := 'U';
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_UTILS',
                             p_procedure_name => 'ChangeCIStatus',
                             p_error_text     => SUBSTRB(SQLERRM,1,240));

     fnd_msg_pub.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);

END ChangeCIStatusValidate;


PROCEDURE PostChangeCIStatus (
                  p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
                 ,p_commit               IN     VARCHAR2 := FND_API.g_false
                 ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
                 ,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num
                 ,p_ci_id        in number
                 ,p_curr_status   in varchar2
                 ,p_new_status   in varchar2
                 ,p_start_wf     in VARCHAR2
                 ,p_enforce_security  in Varchar2 DEFAULT 'Y'
                 ,x_num_of_actions    OUT NOCOPY  NUMBER
                 ,x_return_status        OUT NOCOPY    VARCHAR2
                 ,x_msg_count            OUT NOCOPY    NUMBER
                 ,x_msg_data             OUT NOCOPY    VARCHAR2 )
   IS

  l_start_wf            VARCHAR2(1) := 'Y';
  l_curr_sys_status     VARCHAR2(30);

  l_next_sys_status     VARCHAR2(30);


BEGIN

    l_start_wf := p_start_wf;
    l_curr_sys_status := getSystemStatus(p_curr_status);
    l_next_sys_status := getSystemStatus(p_new_status);


    IF p_init_msg_list = FND_API.G_TRUE THEN
       fnd_msg_pub.initialize;
    END IF;

    x_msg_count := 0;
    x_msg_data := '';

    -- Initialize the Error Stack
    IF P_PA_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_UTILS.ChangeCIStatus');
    END IF;

    pa_debug.write_file('ChangeCiStatusValidate: p_pa_debug_mode :'||p_pa_debug_mode);

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

         IF l_curr_sys_status = 'CI_APPROVED' or l_curr_sys_status = 'CI_SUBMITTED' or l_curr_sys_status = 'CI_WORKING' THEN

            IF l_next_sys_status = 'CI_CANCELED' THEN
               -- set included CR status to APPROVED

               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('ChangeCiStatus: before call to pa_control_items_pvt.change_included_cr_status');
               END IF;

               pa_control_items_pvt.change_included_cr_status
                 (p_ci_id,
                  x_return_status,
                  x_msg_count,
                  x_msg_data
                  );

               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('ChangeCiStatus: after call to pa_control_items_pvt.change_included_cr_status');
               END IF;

            -----  call delete included items api here

               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('ChangeCiStatus: before call to pa_control_items_pvt.delete_all_included_crs');
               END IF;

               pa_control_items_pvt.delete_all_included_crs
                               (p_validate_only => 'F',
                                p_init_msg_list => 'F',
                                p_ci_id         => p_ci_id,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);

               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write_file('ChangeCiStatus: after call to pa_control_items_pvt.delete_all_included_crs');
               END IF;

               -- cancel open actions
               IF (l_curr_sys_status = 'CI_WORKING' and p_validate_only <> fnd_api.g_true AND x_return_status = 'S') then

                    pa_ci_actions_pvt.cancel_all_actions
                            (
                             p_init_msg_list=> p_init_msg_list,
                             p_commit    =>    p_commit,
                             p_validate_only =>   p_validate_only,
                             p_max_msg_count =>  p_max_msg_count,
                             p_ci_id           =>p_ci_id,
                             p_cancel_comment => FND_MESSAGE.GET_STRING('PA','PA_CI_CANCELED'),
                             x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data =>x_msg_data
                             );

               END if;

            END IF;

        END IF;
     END IF;

      IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('ChangeCiStatus: l_start_wf :'||l_start_wf);
         END IF;

         IF (l_start_wf = 'Y') then

          IF P_PA_DEBUG_MODE = 'Y' THEN

             pa_debug.write_file('ChangeCiStatus: before call to checkandstartworkflow');
          END IF;

          checkandstartworkflow
                                   (
                                    1.0    ,
                                    p_init_msg_list         ,
                                    p_commit               ,
                                    p_validate_only            ,
                                    p_max_msg_count       ,
                                    p_ci_id    ,
                                    p_new_status,
                                    x_msg_count   ,
                                    x_msg_data     ,
                                    x_return_status
                                    );

          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('ChangeCiStatus: after call to checkandstartworkflow');
          END IF;

         END IF;

      END if;



EXCEPTION
  WHEN OTHERS THEN

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('ChangeCiStatus: in when others exception');
     END IF;

     ROLLBACK;

     x_return_status := 'U';
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_UTILS',
                             p_procedure_name => 'ChangeCIStatus',
                             p_error_text     => SUBSTRB(SQLERRM,1,240));

     fnd_msg_pub.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);

END PostChangeCIStatus;


END  PA_CONTROL_ITEMS_UTILS;

/
