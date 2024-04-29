--------------------------------------------------------
--  DDL for Package PA_TEAM_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TEAM_TEMPLATES_PKG" AUTHID CURRENT_USER AS
/*$Header: PARTPKGS.pls 120.1 2005/08/19 17:01:07 mwasowic noship $*/
--

PROCEDURE Insert_Row
 (p_team_template_name          IN   pa_team_templates.team_template_name%TYPE
 ,p_description                 IN   pa_team_templates.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_start_date_active           IN   pa_team_templates.start_date_active%TYPE
 ,p_end_date_active             IN   pa_team_templates.end_date_active%TYPE              := FND_API.G_MISS_DATE
 ,p_calendar_id                 IN   pa_team_templates.calendar_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_work_type_id                IN   pa_team_templates.work_type_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_role_list_id                IN   pa_team_templates.role_list_id%TYPE                := FND_API.G_MISS_NUM
 ,p_team_start_date             IN   pa_team_templates.team_start_date%TYPE
 ,p_attribute_category          IN   pa_team_templates.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN   pa_team_templates.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN   pa_team_templates.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN   pa_team_templates.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN   pa_team_templates.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN   pa_team_templates.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN   pa_team_templates.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN   pa_team_templates.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN   pa_team_templates.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN   pa_team_templates.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN   pa_team_templates.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN   pa_team_templates.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN   pa_team_templates.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN   pa_team_templates.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN   pa_team_templates.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN   pa_team_templates.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 ,x_team_template_id            OUT        NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status               OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
;

PROCEDURE Update_Row
 (p_team_template_id            IN   pa_team_templates.team_template_id%TYPE
 ,p_record_version_number       IN   pa_team_templates.record_version_number%TYPE
 ,p_team_template_name          IN   pa_team_templates.team_template_name%TYPE           := FND_API.G_MISS_CHAR
 ,p_description                 IN   pa_team_templates.description %TYPE                 := FND_API.G_MISS_CHAR
 ,p_start_date_active           IN   pa_team_templates.start_date_active%TYPE            := FND_API.G_MISS_DATE
 ,p_end_date_active             IN   pa_team_templates.end_date_active%TYPE              := FND_API.G_MISS_DATE
 ,p_calendar_id                 IN   pa_team_templates.calendar_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_work_type_id                IN   pa_team_templates.work_type_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_role_list_id                IN   pa_team_templates.role_list_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_team_start_date             IN   pa_team_templates.team_start_date%TYPE              := FND_API.G_MISS_DATE
 ,p_workflow_in_progress_flag   IN   pa_team_templates.workflow_in_progress_flag%TYPE    := FND_API.G_MISS_CHAR
 ,p_attribute_category          IN   pa_team_templates.attribute_category%TYPE           := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN   pa_team_templates.attribute1%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN   pa_team_templates.attribute2%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN   pa_team_templates.attribute3%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN   pa_team_templates.attribute4%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN   pa_team_templates.attribute5%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN   pa_team_templates.attribute6%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN   pa_team_templates.attribute7%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN   pa_team_templates.attribute8%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN   pa_team_templates.attribute9%TYPE                   := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN   pa_team_templates.attribute10%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN   pa_team_templates.attribute11%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN   pa_team_templates.attribute12%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN   pa_team_templates.attribute13%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN   pa_team_templates.attribute14%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN   pa_team_templates.attribute15%TYPE                  := FND_API.G_MISS_CHAR
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Delete_Row
( p_team_template_id               IN    pa_team_templates.team_template_id%TYPE
 ,p_record_version_number          IN    NUMBER
 ,x_return_status                  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END pa_team_templates_pkg;
 

/
