--------------------------------------------------------
--  DDL for Package BIS_PMV_PAGE_PARAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_PAGE_PARAMS_PUB" AUTHID CURRENT_USER as
/* $Header: BISPPAGS.pls 115.5 2002/12/03 22:18:38 kiprabha noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE

PROCEDURE RETRIEVE_LASTUPDATE_DATE
(p_user_name            IN  VARCHAR2
,p_page_id              IN  VARCHAR2
,p_session_id           IN  NUMBER default null
,x_last_update_date     OUT NOCOPY VARCHAR2
,x_return_Status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
);
PROCEDURE RETRIEVE_PARAMETER_STRING
(p_user_name            IN  VARCHAR2
,p_page_id              IN  VARCHAR2
,x_param_string         OUT NOCOPY VARCHAR2
,x_return_Status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
);
PROCEDURE RETRIEVE_PARAMSTR_BYUSERID
(p_user_id              IN  VARCHAR2
,p_page_id              IN  VARCHAR2
,x_param_string         OUT NOCOPY VARCHAR2
,x_return_Status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
);

PROCEDURE GET_HELP_TARGET
(p_function_name        IN  VARCHAR2
,p_function_parameters  IN  VARCHAR2
,p_web_html_call        IN  VARCHAR2
,x_region_application_id           OUT NOCOPY NUMBER
,x_help_target           OUT NOCOPY VARCHAR2
,x_return_Status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
) ;

END BIS_PMV_PAGE_PARAMS_PUB;

 

/
