--------------------------------------------------------
--  DDL for Package Body AMW_CONTROLS_PAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_CONTROLS_PAGE_PKG" as
/* $Header: amwcnpgb.pls 120.1 2005/11/10 05:09:10 appldev noship $ */

--NPANANDI 11.19.2004 BEGIN
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_CONTROLS_PAGE_PKG';
--NPANANDI 11.19.2004 END

FUNCTION OBJECTIVE_PRESENT (P_CONTROL_REV_ID IN NUMBER,
		            P_OBJECTIVE_CODE IN VARCHAR2) RETURN VARCHAR2 IS
n     number;
BEGIN
   select count(*)
   into n
   from amw_control_objectives
   where control_rev_id = P_CONTROL_REV_ID
   and   objective_code = P_OBJECTIVE_CODE;

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
END   OBJECTIVE_PRESENT;

FUNCTION new_OBJECTIVE_PRESENT (P_CONTROL_REV_ID IN NUMBER,
		                        P_OBJECTIVE_CODE IN VARCHAR2) RETURN VARCHAR2 IS
n     number;
yes   varchar2(80);
no    varchar2(80);
BEGIN
   select count(*)
   into n
   from amw_control_objectives
   where control_rev_id = P_CONTROL_REV_ID
   and   objective_code = P_OBJECTIVE_CODE;

   select meaning
   into yes
   from fnd_lookups
   where lookup_type='YES_NO'
   and lookup_code='Y';

   select meaning
   into no
   from fnd_lookups
   where lookup_type='YES_NO'
   and lookup_code='N';

   if n > 0 then
       ---return 'Y';
	   return yes;
   else
       ---return 'N';
	   return no;
   end if;
END   new_OBJECTIVE_PRESENT;


FUNCTION preventive_control_PRESENT (P_CONTROL_REV_ID IN NUMBER)
		 RETURN VARCHAR2 IS
n     varchar2(1);
BEGIN
   select preventive_control
   into n
   from amw_controls_all_vl
   where control_rev_id = P_CONTROL_REV_ID;
   ---and   objective_code = P_OBJECTIVE_CODE;

   ---if n > 0 then
   ---    return 'Y';
   ---else
   ---    return 'N';
   ---end if;
   return n;
END   preventive_control_PRESENT;

------------------------------------------------------------------------------------------------------------
FUNCTION GET_OBJ (P_CONTROL_REV_ID IN NUMBER,P_TAG_NUM IN NUMBER)
		 RETURN VARCHAR2 IS
N     varchar2(1);
BEGIN
   BEGIN
      SELECT 'Y'
	    INTO N
        FROM AMW_CONTROL_OBJECTIVES
	   WHERE CONTROL_REV_ID=P_CONTROL_REV_ID
	     AND OBJECTIVE_CODE IN (SELECT LOOKUP_CODE
		                          FROM AMW_LOOKUPS
								 WHERE LOOKUP_TYPE='AMW_CONTROL_OBJECTIVES'
								   AND TAG=P_TAG_NUM);
      RETURN N;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	     RETURN 'N';
   END;

   ---RETURN N;
END GET_OBJ;


------------------------------------------------------------------------------------------------------------
FUNCTION ASSERTION_PRESENT (P_CONTROL_REV_ID     IN NUMBER,
		            P_ASSERTION_CODE IN VARCHAR2) RETURN VARCHAR2 IS
n     number;
BEGIN
   select count(*)
   into n
   from amw_control_assertions
   where control_rev_id = P_CONTROL_REV_ID
   and   assertion_code = P_ASSERTION_CODE;

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
END   ASSERTION_PRESENT;

------------------------------------------------------------------------------------------------------------
FUNCTION new_ASSERTION_PRESENT (P_CONTROL_REV_ID     IN NUMBER,
		            P_ASSERTION_CODE IN VARCHAR2) RETURN VARCHAR2 IS
n     number;
yes   varchar2(80);
no    varchar2(80);
BEGIN
   select count(*)
   into n
   from amw_control_assertions
   where control_rev_id = P_CONTROL_REV_ID
   and   assertion_code = P_ASSERTION_CODE;

   select meaning
   into yes
   from fnd_lookups
   where lookup_type='YES_NO'
   and lookup_code='Y';

   select meaning
   into no
   from fnd_lookups
   where lookup_type='YES_NO'
   and lookup_code='N';

   if n > 0 then
       ---return 'Y';
	   return yes;
   else
       ---return 'N';
	   return no;
   end if;
END   new_ASSERTION_PRESENT;


------------------------------------------------------------------------------------------------------------
FUNCTION component_PRESENT (P_CONTROL_REV_ID     IN NUMBER,
		                    P_component_CODE IN VARCHAR2) RETURN VARCHAR2 IS
n     number;
BEGIN
   select count(*)
   into n
   from amw_assessment_components
   where object_type = 'CONTROL'
   and   object_id   = P_CONTROL_REV_ID
   and   component_code = P_component_CODE;

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
END   component_PRESENT;

------------------------------------------------------------------------------------------------------------
FUNCTION new_component_PRESENT (P_CONTROL_REV_ID     IN NUMBER,
		                        P_component_CODE     IN VARCHAR2) RETURN VARCHAR2 IS
n     number;
yes   varchar2(80);
no    varchar2(80);
BEGIN
   select count(*)
   into n
   from amw_assessment_components
   where object_type = 'CONTROL'
   and   object_id   = P_CONTROL_REV_ID
   and   component_code = P_component_CODE;

   select meaning
   into yes
   from fnd_lookups
   where lookup_type='YES_NO'
   and lookup_code='Y';

   select meaning
   into no
   from fnd_lookups
   where lookup_type='YES_NO'
   and lookup_code='N';

   if n > 0 then
       ---return 'Y';
	   return yes;
   else
       ---return 'N';
	   return no;
   end if;
END   new_component_PRESENT;


------------------------------------------------------------------------------------------------------------
FUNCTION association_exists (P_process_objective_ID IN NUMBER) RETURN VARCHAR2 IS
n     number;
BEGIN
   select count(*)
   into n
   from amw_objective_associations
   where process_objective_id = P_process_objective_ID;


   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
END association_exists;

-----------------------------------------------------------------------------------------------------------------
FUNCTION GET_LOOKUP_VALUE(p_lookup_type  in  varchar2,
                          p_lookup_code  in varchar2) return varchar2 is
l_meaning   varchar2(80);
begin
   select meaning
   into   l_meaning
   from   amw_lookups
   where  lookup_type = p_lookup_type
   and    lookup_code = p_lookup_code
   AND 	  enabled_flag ='Y'
   AND 	  (end_date_active > SYSDATE or end_date_active is null);

   return   l_meaning;
exception
    when no_data_found then
        return null;
    when others then
        return null;
end;

--------------------------------------------------------------------------------------------------------------------
FUNCTION GET_CONTROL_SOURCE (p_control_source_id   varchar2,
                             p_control_type        varchar2,
                             p_automation_type     varchar2,
                             p_application_id      number,
							 p_control_rev_id      number) return varchar2 is

 l_control_source_name   varchar2(240);
 l_ita_installed		 VARCHAR2(1);
 l_control_source_id     varchar2(240);
begin
   --npanandi 12.04.2004: added to handle conversion of ControlSource from char to varchar2
   if(p_control_source_id is not null)then
      l_control_source_id := trim(p_control_source_id);
   end if;
   ---npanandi 12.04.2004 end

   if ((p_control_type = 'A' or p_control_type = 'C') AND (p_automation_type = '1')) then
        select user_profile_option_name
        into l_control_source_name
        from fnd_profile_options_vl
        --where to_char(profile_option_id) = p_control_source_id
		where to_char(profile_option_id) = l_control_source_id
        and application_id = p_application_id;
   elsif ((p_control_type = 'A' or p_control_type = 'C') AND (p_automation_type = '2')) then
        /**select user_form_name
        into l_control_source_name
        from fnd_form_vl
        where to_char(form_id) = p_control_source_id
        and application_id = p_application_id;
		**/
		if(p_application_id is not null)then
	      select user_function_name
		  into l_control_source_name
		  from fnd_form_functions_vl
		  --where to_char(function_id) = p_control_source_id
		  where to_char(function_id) = l_control_source_id
		  and application_id = p_application_id;
		else
		  select user_function_name
		  into l_control_source_name
		  from fnd_form_functions_vl
		  --where to_char(function_id) = p_control_source_id
		  where to_char(function_id) = l_control_source_id
		  and application_id is null;
		end if;

   elsif ((p_control_type = 'A' or p_control_type = 'C') AND (p_automation_type = '5')) then
        select distinct display_name
        into l_control_source_name
        from wf_activities_vl
        --where name = p_control_source_id and type='PROCESS'
		where name = l_control_source_id and type='PROCESS'
        and end_date is null;
   elsif ((p_control_type = 'A' or p_control_type = 'C') AND (p_automation_type = '7')) then
        select fcpv.user_concurrent_program_name
        into l_control_source_name
        from fnd_concurrent_programs_vl fcpv
        ---where to_char(fcpv.concurrent_program_id) = p_control_source_id
		where to_char(fcpv.concurrent_program_id) = l_control_source_id
        and fcpv.application_id=p_application_id and fcpv.enabled_flag='Y';

/***		select to_char(fcpv.concurrent_program_id) control_source_id,
fcpv.user_concurrent_program_name control_source_name,
fcpv.application_id application_id,
(select application_name from fnd_application_vl where application_id=fcpv.application_id) applicationName,
'REPORT' lov_type,
'A' control_type,
'7' automation_type
from amw_controls_all_vl acav, fnd_concurrent_programs_vl fcpv
where acav.application_id=fcpv.application_id and enabled_flag='Y'
	***/
   elsif ((p_control_type = 'A' or p_control_type = 'C') AND (p_automation_type = '9')) then
        select itl.NAME control_source_name
        into l_control_source_name
        from bis_application_measures am,
             bis_indicators i ,bis_indicators_tl itl,
			 fnd_application_vl a
        ---where to_char(am.indicator_id) = p_control_source_id
		where to_char(am.indicator_id) = l_control_source_id
        and am.indicator_id = i.INDICATOR_ID
        AND i.INDICATOR_ID = itl.INDICATOR_ID
        AND itl.LANGUAGE = USERENV('LANG')
        AND am.application_id = a.application_id
		and a.application_id = p_application_id;
   --psomanat 12.04.2004: added to support association of canstraint to Control
    elsif ((p_control_type = 'A' or p_control_type = 'C') AND (p_automation_type = 'SOD')) then
		select distinct ac.CONSTRAINT_NAME
        into l_control_source_name
        from AMW_Constraints_vl ac
        where to_char(ac.CONSTRAINT_ID) = l_control_source_id;
   elsif ((p_control_type = 'A' or p_control_type = 'C') AND (p_automation_type = '10')) then
      begin
         l_ita_installed := 'N';
		 select 'Y'
           into l_ita_installed
           from fnd_product_installations
          where application_id=438;
      exception
         when no_data_found then
		    l_ita_installed := 'N';
      end;

	  if(l_ita_installed = 'Y')then
	     ---03.07.2005 npanandi: changed below query bugfix 4192248
		 ---EXECUTE IMMEDIATE 'SELECT PARAMETER_NAME from ITA_SETUP_PARAMETERS_VL WHERE PARAMETER_CODE=:B1' INTO l_control_source_name USING l_CONTROL_SOURCE_ID;
		 EXECUTE IMMEDIATE 'SELECT isgv.SETUP_GROUP_NAME||'': ''||PARAMETER_NAME '
		        ||' from ITA_SETUP_PARAMETERS_VL ispv, ita_setup_groups_vl isgv WHERE ispv.AUDIT_ENABLED_FLAG=''Y'' and ispv.SETUP_GROUP_CODE=isgv.SETUP_GROUP_CODE and ispv.PARAMETER_CODE=:B1' INTO l_control_source_name USING l_CONTROL_SOURCE_ID;
	  else
	     l_control_source_name := null;
	  end if;
   end if;

   return l_control_source_name;
exception
   when others then
       l_control_source_name := null;
       return l_control_source_name;
end;



------------------------------------------------------------------------------------------------------------
PROCEDURE PROCESS_OBJECTIVE (p_init_msg_list       IN 		VARCHAR2,
 			     p_commit              IN 		VARCHAR2,
 			     p_validate_only       IN 		VARCHAR2,
			     p_select_flag         IN           VARCHAR2,
                             p_control_rev_id 	   IN 	        NUMBER,
                             p_objective_code      IN           VARCHAR2,
                             x_return_status       OUT NOCOPY   VARCHAR2,
 			     x_msg_count           OUT NOCOPY 	NUMBER,
 			     x_msg_data            OUT NOCOPY 	VARCHAR2) IS

      l_creation_date         date;
      l_created_by            number;
      l_last_update_date      date;
      l_last_updated_by       number;
      l_last_update_login     number;
      l_control_objective_id  number;
BEGIN

  -- create savepoint if p_commit is true
     IF p_commit = FND_API.G_TRUE THEN
          SAVEPOINT process_objective_save_point;
     END IF;

  -- initialize message list if p_init_msg_list is set to true
     if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
          fnd_msg_pub.initialize;
     end if;

  -- initialize return status to success
     x_return_status := fnd_api.g_ret_sts_success;


      delete from amw_control_objectives
      where control_rev_id = p_control_rev_id
      and   objective_code = p_objective_code;


      if (p_select_flag = 'Y') then

          l_creation_date := SYSDATE;
          l_created_by := FND_GLOBAL.USER_ID;
          l_last_update_date := SYSDATE;
          l_last_updated_by := FND_GLOBAL.USER_ID;
          l_last_update_login := FND_GLOBAL.USER_ID;

          select amw_control_objectives_s.nextval into l_control_objective_id from dual;

          insert into amw_control_objectives (control_objective_id,
                                              control_rev_id,
                                              objective_code,
                                              creation_date,
                                              created_by,
                                              last_update_date,
                                              last_updated_by,
                                              last_update_login)
          values (l_control_objective_id,
                  p_control_rev_id,
                  p_objective_code,
                  l_creation_date,
                  l_created_by,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login);

       end if;
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO process_objective_save_point;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO create_prop_person_support;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_CONTROLS_PKG',
                            p_procedure_name    =>    'PROCESS_OBJECTIVE',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END PROCESS_OBJECTIVE;

-------------------------------------------------------------------------------------------------------------------
PROCEDURE PROCESS_ASSERTION (p_init_msg_list       IN 		VARCHAR2,
 			     p_commit              IN 		VARCHAR2,
 			     p_validate_only       IN 		VARCHAR2,
			     p_select_flag         IN           VARCHAR2,
                             p_control_rev_id 	   IN 	        NUMBER,
                             p_assertion_code      IN           VARCHAR2,
                             x_return_status       OUT NOCOPY   VARCHAR2,
 			     x_msg_count           OUT NOCOPY 	NUMBER,
 			     x_msg_data            OUT NOCOPY 	VARCHAR2) IS

      l_creation_date         date;
      l_created_by            number;
      l_last_update_date      date;
      l_last_updated_by       number;
      l_last_update_login     number;
      l_control_assertion_id  number;
BEGIN

  -- create savepoint if p_commit is true
     IF p_commit = FND_API.G_TRUE THEN
          SAVEPOINT process_assertion_save_point;
     END IF;

  -- initialize message list if p_init_msg_list is set to true
     if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
          fnd_msg_pub.initialize;
     end if;

  -- initialize return status to success
     x_return_status := fnd_api.g_ret_sts_success;


      delete from amw_control_assertions
      where control_rev_id = p_control_rev_id
      and   assertion_code = p_assertion_code;


      if (p_select_flag = 'Y') then

          l_creation_date := SYSDATE;
          l_created_by := FND_GLOBAL.USER_ID;
          l_last_update_date := SYSDATE;
          l_last_updated_by := FND_GLOBAL.USER_ID;
          l_last_update_login := FND_GLOBAL.USER_ID;

          select amw_control_assertions_s.nextval into l_control_assertion_id from dual;

          insert into amw_control_assertions (control_assertion_id,
                                              control_rev_id,
                                              assertion_code,
                                              creation_date,
                                              created_by,
                                              last_update_date,
                                              last_updated_by,
                                              last_update_login)
          values (l_control_assertion_id,
                  p_control_rev_id,
                  p_assertion_code,
                  l_creation_date,
                  l_created_by,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login);

       end if;
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO process_assertion_save_point;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO create_prop_person_support;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_CONTROLS_PKG',
                            p_procedure_name    =>    'PROCESS_ASSERTION',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END PROCESS_ASSERTION;

-------------------------------------------------------------------------------------------------------------------
PROCEDURE PROCESS_component (p_init_msg_list      IN 			VARCHAR2,
 			     			p_commit              IN 			VARCHAR2,
 			     			p_validate_only       IN 			VARCHAR2,
			     			p_select_flag         IN           	VARCHAR2,
                            p_control_rev_id 	  IN 	        NUMBER,
                            p_component_code      IN           	VARCHAR2,
                            x_return_status       OUT NOCOPY   	VARCHAR2,
 			     			x_msg_count           OUT NOCOPY 	NUMBER,
 			     			x_msg_data            OUT NOCOPY 	VARCHAR2) IS

      l_creation_date         					  date;
      l_created_by            					  number;
      l_last_update_date      					  date;
      l_last_updated_by       					  number;
      l_last_update_login     					  number;
      l_assessment_component_id  				  number;
BEGIN

  -- create savepoint if p_commit is true
     IF p_commit = FND_API.G_TRUE THEN
          SAVEPOINT process_component_save_point;
     END IF;

  -- initialize message list if p_init_msg_list is set to true
     if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
          fnd_msg_pub.initialize;
     end if;

  -- initialize return status to success
     x_return_status := fnd_api.g_ret_sts_success;


      delete from amw_assessment_components
      where object_id = p_control_rev_id
	  and	object_type = 'CONTROL'
      and   component_code = p_component_code;


      if (p_select_flag = 'Y') then

          l_creation_date 	   := SYSDATE;
          l_created_by 		   := FND_GLOBAL.USER_ID;
          l_last_update_date   := SYSDATE;
          l_last_updated_by    := FND_GLOBAL.USER_ID;
          l_last_update_login  := FND_GLOBAL.USER_ID;

          select amw_assessment_components_s.nextval into l_assessment_component_id from dual;

          insert into amw_assessment_components (assessment_component_id,
                                              component_code,
											  object_type,
											  object_id,
                                              creation_date,
                                              created_by,
                                              last_update_date,
                                              last_updated_by,
                                              last_update_login,
											  object_version_number)
          values (l_assessment_component_id,
                  p_component_code,
				  'CONTROL',
				  p_control_rev_id,
                  l_creation_date,
                  l_created_by,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login,
				  1);
       end if;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO process_component_save_point;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          			  p_data	=>	x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO create_prop_person_support;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_CONTROLS_PKG',
                            p_procedure_name    =>    'PROCESS_COMPONENT',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END PROCESS_component;

-------------------------------------------------------------------------------------------------------------------
PROCEDURE delete_control_association (p_init_msg_list     		IN 			VARCHAR2,
		 			     			p_commit              		IN 			VARCHAR2,
		 			     			p_object_type         		IN 			VARCHAR2,
					     			p_risk_association_id 		IN 	        NUMBER,
									p_orig_control_id			in			number,
		                            x_return_status       		OUT NOCOPY  VARCHAR2,
		 			     			x_msg_count           		OUT NOCOPY 	NUMBER,
		 			     			x_msg_data            		OUT NOCOPY 	VARCHAR2) IS

----String pObjectType,String pRiskId, String pProcessOrgId, String pControlId)

      l_creation_date         					  date;
      l_created_by            					  number;
      l_last_update_date      					  date;
      l_last_updated_by       					  number;
      l_last_update_login     					  number;

	  cursor get_association_row(l_object_type in varchar2,l_control_id in varchar2, l_pk1 in varchar2) is
	    select control_association_id from amw_control_associations
		 where object_type =  l_object_type
		   and pk1 = l_pk1
		   and control_id = l_control_id;

	  l_control_association_id 	get_association_row%rowtype;

BEGIN

  -- create savepoint if p_commit is true
     IF p_commit = FND_API.G_TRUE THEN
          SAVEPOINT update_association_save_point;
     END IF;

  -- initialize message list if p_init_msg_list is set to true
     if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
          fnd_msg_pub.initialize;
     end if;

  -- initialize return status to success
     x_return_status := fnd_api.g_ret_sts_success;

	 OPEN get_association_row(p_object_type,p_orig_control_id,p_risk_association_id);
         FETCH get_association_row INTO l_control_association_id;
     CLOSE get_association_row;

	 if(l_control_association_id.control_association_id is not null)then
	   	delete from amw_control_associations
		      where control_association_id = l_control_association_id.control_association_id;

		  if (sql%notfound) then
    	  	 raise no_data_found;
  		  end if;
	 else
	 	raise fnd_api.g_exc_error;
	 end if;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_association_save_point;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          			  p_data	=>	x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO create_prop_person_support;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_CONTROLS_PKG',
                            p_procedure_name    =>    'UPDATE_CONTROL_ASSOCIATION',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          			 p_data		=>	x_msg_data);

END delete_control_association;

-------------------------------------------------------------------------------------------------------------------
PROCEDURE delete_obj_assert_comp (p_init_msg_list     		IN 			VARCHAR2,
		 			     		  p_commit              	IN 			VARCHAR2,
		 			     		  p_control_rev_id			in			number,
		                          x_return_status       	OUT NOCOPY  VARCHAR2,
		 			     		  x_msg_count           	OUT NOCOPY 	NUMBER,
		 			     		  x_msg_data            	OUT NOCOPY 	VARCHAR2) IS

----String pObjectType,String pRiskId, String pProcessOrgId, String pControlId)

      l_creation_date         					  date;
      l_created_by            					  number;
      l_last_update_date      					  date;
      l_last_updated_by       					  number;
      l_last_update_login     					  number;

	  cursor get_association_row(l_object_type in varchar2,l_control_id in varchar2, l_pk1 in varchar2) is
	    select control_association_id from amw_control_associations
		 where object_type =  l_object_type
		   and pk1 = l_pk1
		   and control_id = l_control_id;

	  l_control_association_id 	get_association_row%rowtype;

BEGIN

  -- create savepoint if p_commit is true
     IF p_commit = FND_API.G_TRUE THEN
          SAVEPOINT delete_save_point;
     END IF;

  -- initialize message list if p_init_msg_list is set to true
     if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
          fnd_msg_pub.initialize;
     end if;

  -- initialize return status to success
     x_return_status := fnd_api.g_ret_sts_success;
	 delete from amw_control_objectives where control_rev_id = p_control_rev_id;

	 /*
	 if (sql%notfound) then
  	  	 raise no_data_found;
	 end if;
	 */
	 ---if(x_return_status = fnd_api.g_ret_sts_success) then
	   delete from amw_control_assertions where control_rev_id = p_control_rev_id;
	   /*
	   if(sql%notfound) then
	       raise no_data_found;
       end if;
	   */
	 ---end if;
	 ---if(x_return_status = fnd_api.g_ret_sts_success) then
	   delete from amw_assessment_components
	         where object_id = p_control_rev_id
			   and object_type = 'CONTROL';
	   /*
	   if(sql%notfound) then
	       raise no_data_found;
       end if;
	   */
	 ---end if;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO delete_save_point;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          			  p_data	=>	x_msg_data);

  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO create_prop_person_support;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'AMW_CONTROLS_PKG',
                            p_procedure_name    =>    'UPDATE_CONTROL_ASSOCIATION',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));
       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          			 p_data		=>	x_msg_data);

END delete_obj_assert_comp;

--npanandi 11.16.2004
--enhancement bugfix: 3391157
------------------------------------------------------------------------------------------------------------
FUNCTION IS_CONTROL_EFFECTIVE(
   P_ORGANIZATION_ID IN NUMBER
  ,P_CONTROL_ID IN NUMBER
) RETURN VARCHAR2 IS

CTRL_EFF VARCHAR2(2);

BEGIN
   BEGIN
      SELECT DECODE(aov.audit_result_code,'EFFECTIVE','Y','N')
        INTO CTRL_EFF
     FROM AMW_OPINIONS_V aov
    WHERE aov.object_name = 'AMW_ORG_CONTROL'
      AND aov.opinion_type_code = 'EVALUATION'
      AND aov.pk3_value = P_ORGANIZATION_ID
      AND aov.pk1_value = P_CONTROL_ID
      AND aov.authored_date = (select max(aov2.authored_date)
                                 from AMW_OPINIONS  aov2
                                where aov2.object_opinion_type_id = aov.object_opinion_type_id
							      and aov2.pk3_value = aov.pk3_value
                                  and aov2.pk1_value = aov.pk1_value);
      ---AND aov.audit_result_code <> 'EFFECTIVE';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	     CTRL_EFF := 'NT';
	  WHEN TOO_MANY_ROWS THEN
	     CTRL_EFF := 'N';
   END;

   RETURN CTRL_EFF;
END IS_CONTROL_EFFECTIVE;

FUNCTION GET_POLICY(P_CONTROL_ID IN NUMBER) RETURN VARCHAR2
IS
   L_POLICY_NAME VARCHAR2(240);
   L_IS_ITA_INSTALLED VARCHAR2(1);
BEGIN
   BEGIN
      SELECT 'Y'
	    INTO L_IS_ITA_INSTALLED
		FROM FND_PRODUCT_INSTALLATIONS
	   WHERE APPLICATION_ID=438;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	     L_IS_ITA_INSTALLED := 'N';
   END;

   ---NPANANDI 11.29.2004: HANDLING CALL TO ITA_POLICY_VL DYNAMICALLY
   IF(L_IS_ITA_INSTALLED IS NOT NULL AND L_IS_ITA_INSTALLED = 'Y')THEN
      BEGIN
         EXECUTE IMMEDIATE 'SELECT POLICY_NAME FROM ITA_POLICY_VL WHERE CONTROL_ID=:B1' INTO L_POLICY_NAME USING P_CONTROL_ID;
      EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		    L_POLICY_NAME := NULL;
	     WHEN OTHERS THEN
		 	L_POLICY_NAME := NULL;
	  END;
   END IF;

   RETURN L_POLICY_NAME;
END GET_POLICY;

PROCEDURE IS_WKFLW_APPR_DISBLD(
   P_CONTROL_REV_ID IN NUMBER
  ,P_PROFILE_OPTION OUT NOCOPY VARCHAR2
  ,p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE
  ,x_return_status  OUT NOCOPY   VARCHAR2
  ,x_msg_count      OUT NOCOPY 	NUMBER
  ,x_msg_data       OUT NOCOPY 	VARCHAR2
)
IS
   CURSOR c_old_appr_CTRL(p_CTRL_rev_id In NUMBER) IS
      SELECT CTRL2.Control_REV_ID
        FROM amw_controls_b CTRL1 , amw_controls_b CTRL2
       WHERE CTRL1.Control_id = CTRL2.control_id
         AND CTRL1.control_rev_id = p_CTRL_rev_id
         AND CTRL2.curr_approved_flag= 'Y'
		 and CTRL2.latest_revision_flag = 'N';

   L_PROFILE_OPTION_VALUE VARCHAR2(1);
   L_WKFLW_APPR_DISBLD 	  VARCHAR2(1);
   L_OLD_APPR_CTRL_REV_ID NUMBER;

   L_API_NAME CONSTANT VARCHAR2(30) := 'IS_WKFLW_APPR_DISBLD';
   L_DATE DATE;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF FND_API.to_Boolean( p_init_msg_list )  THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF FND_GLOBAL.User_Id IS NULL THEN
      AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   L_PROFILE_OPTION_VALUE := NVL(fnd_profile.VALUE('AMW_DISABLE_WORKFLOW_APPROVAL'),'N');
   --HARDCODING PURELY FOR TESTINGP PURPOSES!! REMOVE THIS ASAP!!!
   --L_PROFILE_OPTION_VALUE := 'Y';

   IF(L_PROFILE_OPTION_VALUE = 'N')THEN
      L_WKFLW_APPR_DISBLD := 'N';
   ELSE
      L_WKFLW_APPR_DISBLD := 'Y';
      ---DO THE PROCESSING HERE
	  OPEN c_old_appr_CTRL(P_CONTROL_REV_ID) ;
          FETCH c_old_appr_CTRL INTO l_old_appr_CTRL_rev_id;
      CLOSE c_old_appr_CTRL;

	  update amw_controls_b
         set approval_status='A'
            --,object_version_number=object_version_number+1
            ,curr_approved_flag='Y'
            ,latest_revision_flag ='Y'
            ,approval_date=SYSDATE
			,LAST_UPDATE_DATE=SYSDATE
			,LAST_UPDATED_BY=G_USER_ID
			,LAST_UPDATE_LOGIN=G_LOGIN_ID
       where control_rev_id=P_CONTROL_REV_ID;

	  IF (l_old_appr_CTRL_rev_id IS NOT NULL) THEN
	     UPDATE AMW_CONTROLS_B
		    SET END_DATE=SYSDATE
			   ,CURR_APPROVED_FLAG='N'
			   ,LATEST_REVISION_FLAG='N'
			   --,OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1
			   ,LAST_UPDATE_DATE=SYSDATE
			   ,LAST_UPDATED_BY=G_USER_ID
			   ,LAST_UPDATE_LOGIN=G_LOGIN_ID
		  WHERE CONTROL_REV_ID=l_old_appr_CTRL_rev_id;
      END IF;
   END IF;

   p_profile_option := L_WKFLW_APPR_DISBLD;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END IS_WKFLW_APPR_DISBLD;

---------------------------------------------------------------------
----npanandi 12.02.2004: Added below function to get UnitOfMeasureTL
----given UoM_Code, and UoM_Class (from Profile Option)
---------------------------------------------------------------------
---- modified by qliu to get the uom from amw_lookups
FUNCTION GET_UOM_TL(P_UOM_CODE IN VARCHAR2) RETURN VARCHAR2
IS
--   L_UOM_CLASS MTL_UNITS_OF_MEASURE_VL.UOM_CLASS%TYPE;
--   LX_UNIT_OF_MEASURE_TL MTL_UNITS_OF_MEASURE_VL.UNIT_OF_MEASURE_TL%TYPE;
   L_UOM_CLASS AMW_LOOKUPS.LOOKUP_CODE%TYPE;
   LX_UNIT_OF_MEASURE_TL AMW_LOOKUPS.MEANING%TYPE;
BEGIN
/*
   L_UOM_CLASS := FND_PROFILE.VALUE('AMW_CTRL_UOM_CLASS');

   BEGIN
   SELECT UNIT_OF_MEASURE_TL
     INTO LX_UNIT_OF_MEASURE_TL
	 FROM MTL_UNITS_OF_MEASURE_VL
	WHERE UOM_CLASS=L_UOM_CLASS
	  AND UOM_CODE=P_UOM_CODE;
	  --AND BASE_UOM_FLAG='Y';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	     LX_UNIT_OF_MEASURE_TL := NULL;
	  WHEN OTHERS THEN
	     LX_UNIT_OF_MEASURE_TL := NULL;
   END;
*/
   BEGIN
   SELECT meaning
     INTO LX_UNIT_OF_MEASURE_TL
	 FROM AMW_LOOKUPS
	WHERE lookup_type='AMW_CONTROL_FREQUENCY'
	  AND lookup_code=P_UOM_CODE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	     LX_UNIT_OF_MEASURE_TL := NULL;
	  WHEN OTHERS THEN
	     LX_UNIT_OF_MEASURE_TL := NULL;
   END;

   RETURN LX_UNIT_OF_MEASURE_TL;
END GET_UOM_TL;

---------------------------------------------------------------------
----npanandi 12.03.2004: Added below function to check
----if this Ctrl contains this CtrlPurposeCode or not
---------------------------------------------------------------------
FUNCTION PURPOSE_PRESENT (
   P_CONTROL_REV_ID     IN NUMBER,
   P_PURPOSE_CODE 	IN VARCHAR2) RETURN VARCHAR2
IS
   n number;
BEGIN
   select count(*)
     into n
     from amw_control_purposes
    where control_rev_id = P_CONTROL_REV_ID
      and PURPOSE_code = P_PURPOSE_CODE;

   if n > 0 then
       return 'Y';
   else
       return 'N';
   end if;
END PURPOSE_PRESENT;

------------------------------------------------------------------------------------------------------------
FUNCTION NEW_PURPOSE_PRESENT (
   P_CONTROL_REV_ID     IN NUMBER,
   P_PURPOSE_CODE 	IN VARCHAR2) RETURN VARCHAR2
IS
   n     number;
   yes   varchar2(80);
   no    varchar2(80);
BEGIN
   select count(*)
     into n
     from amw_control_PURPOSES
    where control_rev_id = P_CONTROL_REV_ID
      and PURPOSE_code = P_PURPOSE_CODE;

   select meaning
     into yes
     from fnd_lookups
    where lookup_type='YES_NO'
      and lookup_code='Y';

   select meaning
     into no
     from fnd_lookups
    where lookup_type='YES_NO'
      and lookup_code='N';

   if n > 0 then
       return yes;
   else
       return no;
   end if;
END NEW_PURPOSE_PRESENT;

---------------------------------------------------------------------
----npanandi 12.03.2004: Added below function to insert
----CtrlPurposeCode for this CtrlRevId
---------------------------------------------------------------------
PROCEDURE PROCESS_PURPOSE(
   p_init_msg_list       IN 		VARCHAR2,
   p_commit              IN 		VARCHAR2,
   p_validate_only       IN 		VARCHAR2,
   p_select_flag         IN           VARCHAR2,
   p_control_rev_id 	 IN 	        NUMBER,
   p_PURPOSE_code      	 IN           VARCHAR2,
   x_return_status       OUT NOCOPY   VARCHAR2,
   x_msg_count           OUT NOCOPY 	NUMBER,
   x_msg_data            OUT NOCOPY 	VARCHAR2)
IS
   l_creation_date         date;
   l_created_by            number;
   l_last_update_date      date;
   l_last_updated_by       number;
   l_last_update_login     number;
   l_control_PURPOSE_id  number;
BEGIN
   -- create savepoint if p_commit is true
   IF p_commit = FND_API.G_TRUE THEN
      SAVEPOINT process_PURPOSE_save_point;
   END IF;

   -- initialize message list if p_init_msg_list is set to true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
      fnd_msg_pub.initialize;
   end if;

   -- initialize return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   delete from amw_control_PURPOSES
    where control_rev_id = p_control_rev_id
	  and PURPOSE_code = p_PURPOSE_code;

   if (p_select_flag = 'Y') then
      insert into amw_control_PURPOSES(
	     control_PURPOSE_id
        ,control_rev_id
        ,PURPOSE_codE
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login) values (
		 AMW_CONTROL_PURPOSES_S.NEXTVAL
        ,p_control_rev_id
        ,p_PURPOSE_code
        ,SYSDATE
        ,FND_GLOBAL.USER_ID
        ,SYSDATE
        ,FND_GLOBAL.USER_ID
        ,FND_GLOBAL.LOGIN_ID);
   end if;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF p_commit = FND_API.G_TRUE THEN
         ROLLBACK TO process_PURPOSE_save_point;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,p_data	=>	x_msg_data);
   WHEN OTHERS THEN
      IF p_commit = FND_API.G_TRUE THEN
         ROLLBACK TO process_PURPOSE_save_point;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'AMW_CONTROLS_PAGE_PKG',
                              p_procedure_name => 'PROCESS_PURPOSE',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,p_data	=>	x_msg_data);
END PROCESS_PURPOSE;



FUNCTION get_control_objective_rl(
            p_process_id in number,
            p_risk_id in number,
            p_control_id in number,
            p_rev in number) RETURN VARCHAR2
IS
l_obj varchar2(2000);
BEGIN
    select vl.name
    into l_obj
    from amw_process ap,
         amw_objective_associations ao,
         amw_process_objectives_vl vl
    where ao.object_type = 'CONTROL'
    and   ao.pk1 = p_process_id
    and   ao.pk2 = p_risk_id
    and   ao.pk3 = p_control_id
    and   ap.process_id = p_process_id
    and   ap.revision_number = p_rev
    and   ((ap.approval_date is null and ap.end_date is null and ao.deletion_date is null) OR
           (ap.approval_date is not null and ao.approval_date <= ap.approval_date and
             (ao.deletion_approval_date is null or ao.deletion_approval_date >= ap.approval_end_date)))
    and vl.process_objective_id = ao.process_objective_id;

    RETURN l_obj;

EXCEPTION
	  WHEN OTHERS THEN
	     return null;

END get_control_objective_rl;

END AMW_CONTROLS_PAGE_PKG;

/
