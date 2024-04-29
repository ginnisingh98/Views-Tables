--------------------------------------------------------
--  DDL for Package PA_PROJECT_SUBTEAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_SUBTEAMS_PKG" AUTHID CURRENT_USER AS
 /*$Header: PARTSTHS.pls 120.1 2005/08/19 17:01:58 mwasowic noship $*/

PROCEDURE Insert_Row
(
 p_subteam_name       IN   pa_project_subteams.name%TYPE := FND_API.g_miss_char ,
 p_object_type        IN   pa_project_subteams.object_type%TYPE := FND_API.g_miss_char,
 p_object_id          IN   pa_project_subteams.object_id%TYPE := FND_API.g_miss_num,
 p_description        IN   pa_project_subteams.description%TYPE        := FND_API.g_miss_char ,
 p_attribute_category IN   pa_project_subteams.attribute_category%TYPE := FND_API.g_miss_char ,
 p_attribute1         IN   pa_project_subteams.attribute1%TYPE   := FND_API.g_miss_char ,
 p_attribute2         IN   pa_project_subteams.attribute2%TYPE   := FND_API.g_miss_char ,
 p_attribute3         IN   pa_project_subteams.attribute3%TYPE   := FND_API.g_miss_char ,
 p_attribute4         IN   pa_project_subteams.attribute4%TYPE   := FND_API.g_miss_char ,
 p_attribute5         IN   pa_project_subteams.attribute5%TYPE   := FND_API.g_miss_char ,
 p_attribute6         IN   pa_project_subteams.attribute6%TYPE   := FND_API.g_miss_char ,
 p_attribute7         IN   pa_project_subteams.attribute7%TYPE                  := FND_API.g_miss_char ,
 p_attribute8         IN   pa_project_subteams.attribute8%TYPE                  := FND_API.g_miss_char ,
 p_attribute9         IN   pa_project_subteams.attribute9%TYPE                  := FND_API.g_miss_char ,
 p_attribute10        IN   pa_project_subteams.attribute10%TYPE                  := FND_API.g_miss_char ,
 p_attribute11        IN   pa_project_subteams.attribute11%TYPE                  := FND_API.g_miss_char ,
 p_attribute12        IN   pa_project_subteams.attribute12%TYPE                  := FND_API.g_miss_char ,
 p_attribute13        IN   pa_project_subteams.attribute13%TYPE                  := FND_API.g_miss_char ,
 p_attribute14        IN   pa_project_subteams.attribute14%TYPE                  := FND_API.g_miss_char ,
 p_attribute15        IN   pa_project_subteams.attribute15%TYPE                  := FND_API.g_miss_char ,
 x_subteam_row_id     OUT  NOCOPY ROWID, --File.Sql.39 bug 4440895
 x_new_subteam_id     OUT  NOCOPY pa_project_subteams.project_subteam_id%TYPE, --File.Sql.39 bug 4440895
 x_return_status      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Update_Row
(

 p_subteam_row_id           IN   ROWID :=NULL,
 p_subteam_id               IN   pa_project_subteams.project_subteam_id%TYPE,
 p_record_version_number       IN   NUMBER                                                  := NULL,
 p_subteam_name             IN   pa_project_subteams.name%TYPE:= FND_API.g_miss_char,
 p_object_type               IN   pa_project_subteams.object_type%TYPE              := FND_API.g_miss_char,
 p_object_id               IN   pa_project_subteams.object_id%TYPE                  := FND_API.g_miss_num,
 p_description              IN   pa_project_subteams.description%TYPE                 := FND_API.g_miss_char,
 p_attribute_category     IN   pa_project_subteams.attribute_category%TYPE                 := FND_API.g_miss_char ,
 p_attribute1             IN   pa_project_subteams.attribute1%TYPE                  := FND_API.g_miss_char ,
 p_attribute2             IN   pa_project_subteams.attribute2%TYPE                  := FND_API.g_miss_char ,
 p_attribute3             IN   pa_project_subteams.attribute3%TYPE                  := FND_API.g_miss_char ,
 p_attribute4             IN   pa_project_subteams.attribute4%TYPE                  := FND_API.g_miss_char ,
 p_attribute5             IN   pa_project_subteams.attribute5%TYPE                  := FND_API.g_miss_char ,
 p_attribute6             IN   pa_project_subteams.attribute6%TYPE                  := FND_API.g_miss_char ,
 p_attribute7             IN   pa_project_subteams.attribute7%TYPE                  := FND_API.g_miss_char ,
 p_attribute8             IN   pa_project_subteams.attribute8%TYPE                  := FND_API.g_miss_char ,
 p_attribute9             IN   pa_project_subteams.attribute9%TYPE                  := FND_API.g_miss_char ,
 p_attribute10           IN   pa_project_subteams.attribute10%TYPE                  := FND_API.g_miss_char ,
 p_attribute11           IN   pa_project_subteams.attribute11%TYPE                  := FND_API.g_miss_char ,
 p_attribute12           IN   pa_project_subteams.attribute12%TYPE                  := FND_API.g_miss_char ,
 p_attribute13           IN   pa_project_subteams.attribute13%TYPE                  := FND_API.g_miss_char ,
 p_attribute14           IN   pa_project_subteams.attribute14%TYPE                  := FND_API.g_miss_char ,
 p_attribute15           IN   pa_project_subteams.attribute15%TYPE                  := FND_API.g_miss_char ,
 x_return_status         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count             OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data              OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Delete_Row
( p_subteam_row_id           IN   ROWID
 ,p_subteam_id               IN   pa_project_subteams.project_subteam_id%TYPE
 ,p_record_version_number       IN   NUMBER                                                := NULL
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


END PA_PROJECT_SUBTEAMS_pkg;
 

/
