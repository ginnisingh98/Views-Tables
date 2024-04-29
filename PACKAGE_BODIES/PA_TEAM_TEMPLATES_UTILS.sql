--------------------------------------------------------
--  DDL for Package Body PA_TEAM_TEMPLATES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TEAM_TEMPLATES_UTILS" AS
/*$Header: PARTUTLB.pls 120.1 2005/08/19 17:02:16 mwasowic noship $*/
--



FUNCTION Is_Team_Template_Name_Unique(p_team_template_name    IN    pa_team_templates.team_template_name%TYPE)
  RETURN VARCHAR2
IS

l_validate_team_template_name     VARCHAR2(1);
l_return_value VARCHAR2(1);

CURSOR validate_team_template_name IS
SELECT 'X'
  FROM pa_team_templates
 WHERE team_template_name = p_team_template_name;

BEGIN
/*
  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_TEAM_TEMPLATE_UTILS.Is_Team_Template_Name_Unique');

  --Log Message
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_UTILS.Is_Team_Template_Name_Unique.begin'
                     ,x_msg         => 'Beginning of Is_Team_Template_Name_Unique'
                     ,x_log_level   => 5);
*/
  l_return_value := 'Y';
  OPEN validate_team_template_name;

  FETCH validate_team_template_name into l_validate_team_template_name;

  IF validate_team_template_name%FOUND THEN
     l_return_value := 'N';
  END IF;

  CLOSE validate_team_template_name;
  RETURN l_return_value;

  EXCEPTION
    WHEN OTHERS THEN
/*        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATES_UTILS.Is_Team_Template_Name_Unique'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
*/      RAISE;

END Is_Team_Template_Name_Unique;

PROCEDURE Check_Team_Template_Name_Or_Id(
			p_team_template_id	IN	NUMBER,
			p_team_template_name	IN	VARCHAR2,
			p_check_id_flag		IN	VARCHAR2,
			x_team_template_id	OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			x_return_status		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_error_message_code	OUT	NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
  IS
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
 BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_TEAM_TEMPLATE_UTILS.Check_Team_Template_Name_Or_Id');

  --Log Message
  IF (P_DEBUG_MODE ='Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_TEAM_TEMPLATES_UTILS.Check_Team_Template_Name_Or_Id.begin'
                     ,x_msg         => 'Beginning of Is_Team_Template_Name_Unique'
                     ,x_log_level   => 5);
  END IF;

	IF p_team_template_id IS NOT NULL AND p_team_template_id<>FND_API.G_MISS_NUM THEN
		IF p_check_id_flag = 'Y' THEN
			SELECT team_template_id
			INTO   x_team_template_id
			FROM   pa_team_templates tt
			WHERE  tt.team_template_id = p_team_template_id;
		ELSE
			x_team_template_id := p_team_template_id;
		END IF;
	ELSE
			SELECT team_template_id
			INTO   x_team_template_id
			FROM   pa_team_templates tt
			WHERE  tt.team_template_name = p_team_template_name;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_error_message_code := 'PA_TEAM_TEMPLATE_INV_AMG';
	WHEN TOO_MANY_ROWS THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_error_message_code := 'PA_TEAM_TEMPLATE_INV_AMG';
	WHEN OTHERS THEN
          -- Set the excetption Message and the stack
          FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TEAM_TEMPLATES_UTILS.Check_Team_Template_Name_Or_Id'
                                   ,p_procedure_name => PA_DEBUG.G_Err_Stack );

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

 END Check_Team_Template_Name_Or_Id;

---Procedure Added for 3919767

PROCEDURE CallbackFunction(	p_s_item_type      IN VARCHAR2,
                          	p_s_item_key       IN VARCHAR2,
                          	p_n_actid          IN NUMBER,
                          	p_s_command        IN VARCHAR2,
                          	p_s_result         OUT NOCOPY VARCHAR2) IS
----------------------------------------------------------------------
  l_n_user_id 			Number;
  l_n_resp_id 			Number;
  l_n_resp_appl_id 		Number;

BEGIN
 IF (p_s_command = 'TEST_CTX') THEN
      p_s_result := 'FALSE';
 ELSIF (p_s_command = 'SET_CTX') THEN
   begin

      l_n_user_id := WF_ENGINE.GetItemAttrNumber(p_s_item_type,
  						   p_s_item_key,
  						   'USER_ID');
      l_n_resp_id := WF_ENGINE.GetItemAttrNumber(p_s_item_type,
  						   p_s_item_key,
  						   'RESPONSIBILITY_ID');
      l_n_resp_appl_id := WF_ENGINE.GetItemAttrNumber(p_s_item_type,
  				      		    p_s_item_key,
  						    'APPLICATION_ID');
      -- Set the context
      FND_GLOBAL.APPS_INITIALIZE(  USER_ID => l_n_user_id,
				 RESP_ID => l_n_resp_id,
				 RESP_APPL_ID => l_n_resp_appl_id
				 );
       exception
	when others then
	  if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
	    null;
	  else
	    raise;
	  end if;
    end;
 END IF;

END CallbackFunction;

END pa_team_templates_utils;


/
