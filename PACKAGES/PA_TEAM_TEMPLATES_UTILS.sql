--------------------------------------------------------
--  DDL for Package PA_TEAM_TEMPLATES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TEAM_TEMPLATES_UTILS" AUTHID CURRENT_USER AS
/*$Header: PARTUTLS.pls 120.1 2005/08/19 17:02:20 mwasowic noship $*/
--

FUNCTION Is_Team_Template_Name_Unique(p_team_template_name    IN    pa_team_templates.team_template_name%TYPE)
         RETURN VARCHAR2;
pragma RESTRICT_REFERENCES (Is_Team_Template_Name_Unique,WNDS, WNPS);

PROCEDURE Check_Team_Template_Name_Or_Id(
			p_team_template_id	IN	NUMBER,
			p_team_template_name	IN	VARCHAR2,
			p_check_id_flag		IN	VARCHAR2,
			x_team_template_id	OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			x_return_status		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_error_message_code	OUT	NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--- Added for bug 3919767

PROCEDURE CallbackFunction(	p_s_item_type      IN VARCHAR2,
                          	p_s_item_key       IN VARCHAR2,
                          	p_n_actid          IN NUMBER,
                          	p_s_command        IN VARCHAR2,
                          	p_s_result         OUT NOCOPY VARCHAR2);

END pa_team_templates_utils;



 

/
