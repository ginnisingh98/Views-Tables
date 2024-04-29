--------------------------------------------------------
--  DDL for Package PA_TEAM_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TEAM_TEMPLATES_PUB" AUTHID CURRENT_USER AS
/*$Header: PARTPUBS.pls 120.1 2005/08/19 17:01:16 mwasowic noship $*/
--

TYPE team_template_rec IS RECORD
(team_template_id              pa_team_templates.team_template_id%TYPE                 := FND_API.G_MISS_NUM
 ,record_version_number        pa_team_templates.record_version_number%TYPE            := FND_API.G_MISS_NUM
 ,team_template_name           pa_team_templates.team_template_name%TYPE               := FND_API.G_MISS_CHAR
 ,start_date_active            pa_team_templates.start_date_active%TYPE                := FND_API.G_MISS_DATE
 ,end_date_active              pa_team_templates.end_date_active%TYPE                  := FND_API.G_MISS_DATE
 ,description                  pa_team_templates.description%TYPE                      := FND_API.G_MISS_CHAR
 ,role_list_id                 pa_team_templates.role_list_id%TYPE                     := FND_API.G_MISS_NUM
 ,calendar_id                  pa_team_templates.calendar_id%TYPE                      := FND_API.G_MISS_NUM
 ,work_type_id                 pa_team_templates.work_type_id%TYPE                     := FND_API.G_MISS_NUM
 ,team_start_date              pa_team_templates.team_start_date%TYPE                  := FND_API.G_MISS_DATE
 ,workflow_in_progress_flag    pa_team_templates.workflow_in_progress_flag%TYPE        := FND_API.G_MISS_CHAR
 ,attribute_category           pa_team_templates.attribute_category%TYPE               := FND_API.G_MISS_CHAR
 ,attribute1                   pa_team_templates.attribute1%TYPE                       := FND_API.G_MISS_CHAR
 ,attribute2                   pa_team_templates.attribute2%TYPE                       := FND_API.G_MISS_CHAR
 ,attribute3                   pa_team_templates.attribute3%TYPE                       := FND_API.G_MISS_CHAR
 ,attribute4                   pa_team_templates.attribute4%TYPE                       := FND_API.G_MISS_CHAR
 ,attribute5                   pa_team_templates.attribute5%TYPE                       := FND_API.G_MISS_CHAR
 ,attribute6                   pa_team_templates.attribute6%TYPE                       := FND_API.G_MISS_CHAR
 ,attribute7                   pa_team_templates.attribute7%TYPE                       := FND_API.G_MISS_CHAR
 ,attribute8                   pa_team_templates.attribute8%TYPE                       := FND_API.G_MISS_CHAR
 ,attribute9                   pa_team_templates.attribute9%TYPE                       := FND_API.G_MISS_CHAR
 ,attribute10                  pa_team_templates.attribute10%TYPE                      := FND_API.G_MISS_CHAR
 ,attribute11                  pa_team_templates.attribute11%TYPE                      := FND_API.G_MISS_CHAR
 ,attribute12                  pa_team_templates.attribute12%TYPE                      := FND_API.G_MISS_CHAR
 ,attribute13                  pa_team_templates.attribute13%TYPE                      := FND_API.G_MISS_CHAR
 ,attribute14                  pa_team_templates.attribute14%TYPE                      := FND_API.G_MISS_CHAR
 ,attribute15                  pa_team_templates.attribute15%TYPE                      := FND_API.G_MISS_CHAR );


TYPE team_template_id_rec IS RECORD(
     team_template_id   pa_team_templates.team_template_id%TYPE);

TYPE team_template_id_tbl IS TABLE OF team_template_id_rec
   INDEX BY BINARY_INTEGER;

g_team_template_id_tbl    team_template_id_tbl;

PROCEDURE Execute_Apply_Team_Template
(p_team_template_id                IN     pa_team_templates.team_template_id%TYPE
,p_project_id                      IN     pa_projects_all.project_id%TYPE
,p_project_start_date              IN     pa_projects_all.start_date%TYPE
,p_team_start_date                 IN     pa_team_templates.team_start_date%TYPE      := FND_API.G_MISS_DATE
,p_use_project_location            IN     VARCHAR2                                    := 'N'
,p_project_location_id             IN     pa_projects_all.location_id%TYPE            := NULL
,p_use_project_calendar            IN     VARCHAR2                                    := 'N'
,p_project_calendar_id             IN     pa_projects_all.calendar_id%TYPE            := NULL
,p_apply                           IN     VARCHAR2                                    := 'Y'
,p_api_version                     IN     NUMBER                                      := 1.0
,p_init_msg_list                   IN     VARCHAR2                                    := FND_API.G_TRUE
,p_commit                          IN     VARCHAR2                                    := FND_API.G_FALSE
,p_validate_only                   IN     VARCHAR2                                    := FND_API.G_FALSE
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_data                        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Apply_Team_Template
(p_team_template_id_tbl            IN     team_template_id_tbl
,p_project_id                      IN     pa_projects_all.project_id%TYPE
,p_project_start_date              IN     pa_projects_all.start_date%TYPE
,p_team_start_date                 IN     pa_team_templates.team_start_date%TYPE      := FND_API.G_MISS_DATE
,p_use_project_location            IN     VARCHAR2                                    := 'N'
,p_project_location_id             IN     pa_projects_all.location_id%TYPE            := NULL
,p_use_project_calendar            IN     VARCHAR2                                    := 'N'
,p_project_calendar_id             IN     pa_projects_all.calendar_id%TYPE            := NULL
,p_api_version                     IN     NUMBER                                      := 1.0
,p_init_msg_list                   IN     VARCHAR2                                    := FND_API.G_TRUE
,p_commit                          IN     VARCHAR2                                    := FND_API.G_FALSE
,p_validate_only                   IN     VARCHAR2                                    := FND_API.G_FALSE
,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_data                        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Execute_Create_Team_Template
(p_team_template_name              IN     pa_team_templates.team_template_name%TYPE
 ,p_description                    IN     pa_team_templates.description%TYPE           := FND_API.G_MISS_CHAR
 ,p_start_date_active              IN     pa_team_templates.start_date_active%TYPE
 ,p_end_date_active                IN     pa_team_templates.end_date_active%TYPE       := FND_API.G_MISS_DATE
 ,p_calendar_name                  IN     jtf_calendars_tl.calendar_name%TYPE          := FND_API.G_MISS_CHAR
 ,p_calendar_id                    IN     pa_team_templates.calendar_id%TYPE           := FND_API.G_MISS_NUM
 ,p_work_type_name                 IN     pa_work_types_vl.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_work_type_id                   IN     pa_team_templates.work_type_id%TYPE          := FND_API.G_MISS_NUM
 ,p_role_list_name                 IN     pa_role_lists.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_role_list_id                   IN     pa_team_templates.role_list_id%TYPE          := FND_API.G_MISS_NUM
 ,p_team_start_date                IN     pa_team_templates.team_start_date%TYPE
 ,p_attribute_category             IN     pa_team_templates.attribute_category%TYPE    := FND_API.G_MISS_CHAR
 ,p_attribute1                     IN     pa_team_templates.attribute1%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute2                     IN     pa_team_templates.attribute2%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute3                     IN     pa_team_templates.attribute3%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute4                     IN     pa_team_templates.attribute4%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute5                     IN     pa_team_templates.attribute5%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute6                     IN     pa_team_templates.attribute6%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute7                     IN     pa_team_templates.attribute7%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute8                     IN     pa_team_templates.attribute8%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute9                     IN     pa_team_templates.attribute9%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute10                    IN     pa_team_templates.attribute10%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute11                    IN     pa_team_templates.attribute11%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute12                    IN     pa_team_templates.attribute12%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute13                    IN     pa_team_templates.attribute13%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute14                    IN     pa_team_templates.attribute14%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute15                    IN     pa_team_templates.attribute15%TYPE           := FND_API.G_MISS_CHAR
 ,p_api_version                    IN     NUMBER                                       := 1.0
 ,p_init_msg_list                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_max_msg_count                  IN     NUMBER                                       := FND_API.G_MISS_NUM
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_FALSE
 ,x_team_template_id               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Create_Team_Template
( p_team_template_rec              IN     team_template_rec
 ,p_calendar_name                  IN     jtf_calendars_tl.calendar_name%TYPE          := FND_API.G_MISS_CHAR
 ,p_work_type_name                 IN     pa_work_types_vl.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_role_list_name                 IN     pa_role_lists.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_api_version                    IN     NUMBER                                       := 1.0
 ,p_init_msg_list                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_max_msg_count                  IN     NUMBER                                       := FND_API.G_MISS_NUM
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_FAlSE
 ,x_team_template_id               OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE Execute_Update_Team_Template
( p_team_template_id               IN     pa_team_templates.team_template_id%TYPE
 ,p_record_version_number          IN     pa_team_templates.record_version_number%TYPE
 ,p_team_template_name             IN     pa_team_templates.team_template_name%TYPE    := FND_API.G_MISS_CHAR
 ,p_description                    IN     pa_team_templates.description%TYPE           := FND_API.G_MISS_CHAR
 ,p_start_date_active              IN     pa_team_templates.start_date_active%TYPE     := FND_API.G_MISS_DATE
 ,p_end_date_active                IN     pa_team_templates.end_date_active%TYPE       := FND_API.G_MISS_DATE
 ,p_calendar_name                  IN     jtf_calendars_tl.calendar_name%TYPE          := FND_API.G_MISS_CHAR
 ,p_calendar_id                    IN     pa_team_templates.calendar_id%TYPE           := FND_API.G_MISS_NUM
 ,p_work_type_name                 IN     pa_work_types_vl.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_work_type_id                   IN     pa_team_templates.work_type_id%TYPE          := FND_API.G_MISS_NUM
 ,p_role_list_name                 IN     pa_role_lists.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_role_list_id                   IN     pa_team_templates.role_list_id%TYPE          := FND_API.G_MISS_NUM
 ,p_team_start_date                IN     pa_team_templates.team_start_date%TYPE       := FND_API.G_MISS_DATE
 ,p_workflow_in_progress_flag      IN     pa_team_templates.workflow_in_progress_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_attribute_category             IN     pa_team_templates.attribute_category%TYPE    := FND_API.G_MISS_CHAR
 ,p_attribute1                     IN     pa_team_templates.attribute1%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute2                     IN     pa_team_templates.attribute2%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute3                     IN     pa_team_templates.attribute3%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute4                     IN     pa_team_templates.attribute4%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute5                     IN     pa_team_templates.attribute5%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute6                     IN     pa_team_templates.attribute6%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute7                     IN     pa_team_templates.attribute7%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute8                     IN     pa_team_templates.attribute8%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute9                     IN     pa_team_templates.attribute9%TYPE            := FND_API.G_MISS_CHAR
 ,p_attribute10                    IN     pa_team_templates.attribute10%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute11                    IN     pa_team_templates.attribute11%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute12                    IN     pa_team_templates.attribute12%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute13                    IN     pa_team_templates.attribute13%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute14                    IN     pa_team_templates.attribute14%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute15                    IN     pa_team_templates.attribute15%TYPE           := FND_API.G_MISS_CHAR
 ,p_api_version                    IN     NUMBER                                       := 1.0
 ,p_init_msg_list                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_max_msg_count                  IN     NUMBER                                       := FND_API.G_MISS_NUM
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_FALSE
 ,x_return_status                  OUT    NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Update_Team_Template
( p_team_template_rec              IN     team_template_rec
 ,p_calendar_name                  IN     jtf_calendars_tl.calendar_name%TYPE          := FND_API.G_MISS_CHAR
 ,p_work_type_name                 IN     pa_work_types_vl.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_role_list_name                 IN     pa_role_lists.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_api_version                    IN     NUMBER                                       := 1.0
 ,p_init_msg_list                  IN     VARCHAR2                                     := FND_API.G_TRUE
 ,p_commit                         IN     VARCHAR2                                     := FND_API.G_FALSE
 ,p_max_msg_count                  IN     NUMBER                                       := FND_API.G_MISS_NUM
 ,p_validate_only                  IN     VARCHAR2                                     := FND_API.G_FALSE
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Delete_Team_Template
( p_team_template_id            IN     pa_team_templates.team_template_id%TYPE
 ,p_record_version_number       IN     NUMBER
 ,p_api_version                 IN     NUMBER                                          := 1
 ,p_init_msg_list               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_max_msg_count               IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_FALSE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
 );

END pa_team_templates_pub;
 

/
