--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SUBTEAM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SUBTEAM_UTILS" AS
  /*$Header: PARTSTUB.pls 120.2 2007/02/06 09:58:17 dthakker ship $ */

 /***************************************************************
  PROCEDURE
              Check_Subteam_Name_Or_Id
  PURPOSE
              This procedure does the following
              If subteam name is passed, converts it to the id
		        If subteam id is passed,
		        validates it
  ***************************************************************/

procedure Check_Subteam_Name_Or_Id (
			p_subteam_name		IN	VARCHAR2 :=FND_API.G_MISS_CHAR,
			p_object_type		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
			p_object_id		IN	NUMBER := FND_API.G_MISS_NUM,
			p_check_id_flag		IN	VARCHAR2 := 'A',
			x_subteam_id		IN OUT	NOCOPY NUMBER , --File.Sql.39 bug 4440895
			x_return_status		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_error_message_code	OUT	NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
            IS

BEGIN

    IF (x_subteam_id IS NOT NULL) then
       If (x_subteam_id >0 AND p_check_id_flag = 'Y') THEN
			SELECT project_subteam_id
	      	  	INTO   x_subteam_id
	        	FROM   pa_project_subteams
	        	WHERE  project_subteam_id = x_subteam_id
                        AND    object_type = decode(p_object_type, FND_API.G_MISS_CHAR, object_type, null, object_type, p_object_type)  -- 5130421
                        AND    object_id = decode(p_object_id, FND_API.G_MISS_NUM, object_id, null, object_id, p_object_id)  -- 5130421
                        ;
       elsif (p_check_id_flag = 'N') then
           -- No ID validation is required
              x_subteam_id := x_subteam_id;
       elsif(p_check_id_flag = 'A') then
         if (p_subteam_name is null) then
            x_subteam_id := null;
         else
           --Find the Id for the name
            SELECT project_subteam_id
                INTO   x_subteam_id
                FROM   pa_project_subteams
                WHERE  name = p_subteam_name
                AND    object_type = p_object_type
                AND    object_id = p_object_id;
         end if;
       end if;
    ELSE
       if (p_subteam_name is not null) then
		SELECT project_subteam_id
        	INTO   x_subteam_id
        	FROM   pa_project_subteams
        	WHERE  name = p_subteam_name
		AND    object_type = p_object_type
		AND    object_id = p_object_id;
       else
          x_subteam_id := null;
       end if;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
	        x_return_status := FND_API.G_RET_STS_ERROR;
    		x_error_message_code := 'PA_SBT_ID_INV';
        WHEN TOO_MANY_ROWS THEN
	        x_return_status := FND_API.G_RET_STS_ERROR;
    		x_error_message_code := 'PA_SBT_ID_INV';
        WHEN OTHERS THEN
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Check_Subteam_Name_Or_Id;

procedure get_object_id(p_object_type IN varchar2
                       ,p_object_id   IN OUT NOCOPY number --File.Sql.39 bug 4440895
                       ,p_object_name IN varchar2
                       ,x_return_status         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                       ,x_error_message_code    OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  cursor c_project is
    select project_id
     from pa_projects_all
    where name = p_object_name;

  cursor c_team_template is
   select team_template_id
   from pa_team_templates
   where team_template_name=p_object_name;
  BEGIN
    if (p_object_type = 'PA_PROJECTS') then
     open c_project;
     fetch c_project into p_object_id;
     if (c_project%NOTFOUND) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_SBT_PRJID_INV';
      close c_project;
      return;
     end if;
     close c_project;
    elsif (p_object_type = 'PA_TEAM_TEMPLATES') then
     open c_team_template;
     fetch c_team_template into p_object_id;
     if (c_team_template%NOTFOUND) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_SBT_TEAMTEMPLID_INV';
      close c_team_template;
      return;
     end if;
     close c_team_template;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;
  END get_object_id;
end pa_project_subteam_utils;

/
