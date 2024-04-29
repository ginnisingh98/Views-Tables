--------------------------------------------------------
--  DDL for Package FPA_PROJECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_PROJECT_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVPRJS.pls 120.3 2006/01/03 14:02:17 appldev ship $ */
G_API_NAME         CONSTANT VARCHAR2(80) := 'FPA_PROJECT_PVT';

/* ***********************************************************************
Desc:
parameters:
return:
***************************************************************************/

FUNCTION Valid_Project(
    p_project_id            IN              NUMBER
) RETURN VARCHAR2;


/* ***********************************************************************
Desc:
parameters:
return:
***************************************************************************/

PROCEDURE Submit_Project_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_project_id            IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

/* ***********************************************************************
Desc:
parameters:
return:
***************************************************************************/

PROCEDURE Get_Project_Details
(
    p_project_id            IN              NUMBER,
    x_proj_portfolio        OUT NOCOPY      NUMBER,
    x_proj_pc               OUT NOCOPY      NUMBER,
    x_class_code_id         OUT NOCOPY      NUMBER,
    x_valid_project         OUT NOCOPY      VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

/* ***********************************************************************
Desc:
parameters:
return:
***************************************************************************/

PROCEDURE Load_Project_Details_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_type                  IN              VARCHAR2,
    p_scenario_id           IN              NUMBER,
    p_projects              IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

FUNCTION Verify_Budget_Versions
(
    p_scenario_id     IN              NUMBER,
    p_project_id      IN              NUMBER
)RETURN VARCHAR2;




FUNCTION get_config_page_function
(
    p_planning_cycle_id     IN              NUMBER
)RETURN VARCHAR2;


FUNCTION get_config_page_id
(
    p_planning_cycle_id     IN              NUMBER
)RETURN NUMBER;

PROCEDURE UPDATE_PROJ_FUNDING_STATUS
(   p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_commit                IN              VARCHAR2,
    p_appr_scenario_id      IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2);



END FPA_PROJECT_PVT;

 

/
