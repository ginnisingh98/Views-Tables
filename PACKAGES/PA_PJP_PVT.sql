--------------------------------------------------------
--  DDL for Package PA_PJP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PJP_PVT" AUTHID CURRENT_USER as
/* $Header: PARPJPVS.pls 120.0 2005/05/29 20:40:09 appldev noship $ */
G_API_NAME         CONSTANT VARCHAR2(80) := 'PA_PJP_PVT';


/* ***********************************************************************
Desc:
parameters:
return:
***************************************************************************/

PROCEDURE Submit_Project_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_commit                IN              VARCHAR2,
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

FUNCTION proj_scorecard_link_enabled
(   p_function_name     IN  VARCHAR2,
    p_project_id        IN  NUMBER)
 RETURN VARCHAR2;

END PA_PJP_PVT;

 

/
