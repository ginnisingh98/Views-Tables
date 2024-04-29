--------------------------------------------------------
--  DDL for Package PA_PROJ_STRUCTURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_STRUCTURE_PVT" AUTHID CURRENT_USER as
/* $Header: PAXSTRVS.pls 120.1 2005/08/19 17:20:34 mwasowic noship $ */

function CHECK_ASSO_PROJ_OK
(
	p_task_id						IN		NUMBER,
	p_project_id				IN		NUMBER
)
return VARCHAR2;

procedure CREATE_RELATIONSHIP
(
	p_api_version				IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit						IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode				IN		VARCHAR2	:= 'N',
	p_task_id						IN		NUMBER,
	p_project_id				IN		NUMBER,
	x_return_status			OUT		NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count					OUT		NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data					OUT		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

procedure DELETE_RELATIONSHIP
(
	p_api_version				IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit						IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode				IN		VARCHAR2	:= 'N',
	p_task_id						IN		NUMBER,
	p_project_id				IN		NUMBER,
	x_return_status			OUT		NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count					OUT		NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data					OUT		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

end PA_PROJ_STRUCTURE_PVT;

 

/
