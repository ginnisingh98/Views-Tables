--------------------------------------------------------
--  DDL for Package PA_TEAM_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TEAM_TEMPLATES_PVT" AUTHID CURRENT_USER AS
/*$Header: PARTPVTS.pls 120.1 2005/08/19 17:01:24 mwasowic noship $*/
--
PROCEDURE Start_Apply_Team_Template_WF
(p_team_template_id_tbl            IN     PA_TEAM_TEMPLATES_PUB.team_template_id_tbl
,p_project_id                      IN     pa_projects_all.project_id%TYPE
,p_project_start_date              IN     pa_projects_all.start_date%TYPE
,p_team_start_date                 IN     pa_team_templates.team_start_date%TYPE      := FND_API.G_MISS_DATE
,p_use_project_location            IN     VARCHAR2                                    := 'N'
,p_project_location_id             IN     pa_projects_all.location_id%TYPE            := NULL
,p_use_project_calendar            IN     VARCHAR2                                    := 'N'
,p_project_calendar_id             IN     pa_projects_all.calendar_id%TYPE            := NULL
,p_commit                          IN     VARCHAR2                                    := FND_API.G_FALSE
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Apply_Team_Template_WF
(p_item_type     IN        VARCHAR2,
 p_item_key      IN        VARCHAR2,
 p_actid         IN        NUMBER,
 p_funcmode      IN        VARCHAR2,
 p_result        OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE Apply_Team_Template
(p_team_template_id                IN     pa_team_templates.team_template_id%TYPE
,p_project_id                      IN     pa_projects_all.project_id%TYPE
,p_project_start_date              IN     pa_projects_all.start_date%TYPE
,p_team_start_date                 IN     pa_team_templates.team_start_date%TYPE      := FND_API.G_MISS_DATE
,p_use_project_location            IN     VARCHAR2                                    := 'N'
,p_project_location_id             IN     pa_projects_all.location_id%TYPE            := NULL
,p_use_project_calendar            IN     VARCHAR2                                    := 'N'
,p_project_calendar_id             IN     pa_projects_all.calendar_id%TYPE            := NULL
,p_commit                          IN     VARCHAR2                                    := FND_API.G_FALSE
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Create_Team_Template
( p_team_template_rec              IN     PA_TEAM_TEMPLATES_PUB.team_template_rec
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,x_team_template_id               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Update_Team_Template
( p_team_template_rec              IN     PA_TEAM_TEMPLATES_PUB.team_template_rec
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Delete_Team_Template
( p_team_template_id            IN     pa_team_templates.team_template_id%TYPE
 ,p_record_version_number       IN     NUMBER
 ,p_commit                      IN     VARCHAR2                                     := FND_API.G_FALSE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

END pa_team_templates_pvt;
 

/
