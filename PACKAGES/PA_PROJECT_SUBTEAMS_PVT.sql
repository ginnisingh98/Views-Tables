--------------------------------------------------------
--  DDL for Package PA_PROJECT_SUBTEAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_SUBTEAMS_PVT" AUTHID CURRENT_USER AS
--$Header: PARTSTVS.pls 120.1 2005/08/19 17:02:13 mwasowic noship $

PROCEDURE Create_Subteam
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2                                        := FND_API.g_false,

 p_validate_only               IN     VARCHAR2                                        := FND_API.g_true,

 p_validation_level            IN     NUMBER                                        := FND_API.g_valid_level_full,

 p_calling_module              IN     VARCHAR2
     := 'SELF_SERVICE',

 p_debug_mode                  IN     VARCHAR2 := 'N',

 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_subteam_name                          IN     pa_project_subteams.name%TYPE              := FND_API.g_miss_char,
 p_object_type                          IN     pa_project_subteams.object_type%TYPE              := FND_API.g_miss_char,

 p_object_id                    IN     pa_project_subteams.object_id%TYPE                   := FND_API.g_miss_num,

 p_description                   IN     pa_project_subteams.description%TYPE                  := FND_API.g_miss_char,

 p_record_version_number         IN     pa_project_subteams.record_version_number%TYPE := FND_API.g_miss_num,

 p_attribute_category            IN     pa_project_subteams.attribute_category%TYPE           := FND_API.g_miss_char,

 p_attribute1                    IN pa_project_subteams.attribute1%TYPE                   := FND_API.G_MISS_CHAR,

 p_attribute2                    IN pa_project_subteams.attribute2%TYPE                   := FND_API.G_MISS_CHAR,

 p_attribute3                    IN pa_project_subteams.attribute3%TYPE                   := FND_API.G_MISS_CHAR,

 p_attribute4                    IN pa_project_subteams.attribute4%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute5                    IN pa_project_subteams.attribute5%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute6                    IN pa_project_subteams.attribute6%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute7                    IN pa_project_subteams.attribute7%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute8                    IN pa_project_subteams.attribute8%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute9                    IN pa_project_subteams.attribute9%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute10                    IN pa_project_subteams.attribute10%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute11                    IN pa_project_subteams.attribute11%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute12                    IN pa_project_subteams.attribute12%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute13                    IN pa_project_subteams.attribute13%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute14                    IN pa_project_subteams.attribute14%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute15                    IN pa_project_subteams.attribute15%TYPE                   := FND_API.G_MISS_CHAR,


 x_subteam_row_id              OUT    NOCOPY ROWID, --File.Sql.39 bug 4440895
 x_new_subteam_id              OUT    NOCOPY pa_project_subteams.project_subteam_id%TYPE, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
;

PROCEDURE Update_Subteam
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2                                        := FND_API.g_false,

 p_validate_only               IN     VARCHAR2                                        := FND_API.g_true,

 p_validation_level            IN     NUMBER                                        := FND_API.g_valid_level_full,

 p_calling_module              IN     VARCHAR2
     := 'SELF_SERVICE',

 p_debug_mode                  IN     VARCHAR2 := 'N',

 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_subteam_row_id              IN     ROWID := null,

 p_subteam_id                 IN     pa_project_subteams.project_subteam_id%TYPE := FND_API.g_miss_num,

 p_subteam_name                          IN     pa_project_subteams.name%TYPE              := FND_API.g_miss_char,
 p_object_type                          IN     pa_project_subteams.object_type%TYPE              := FND_API.g_miss_char,

 p_object_id                    IN     pa_project_subteams.object_id%TYPE                   := FND_API.g_miss_num,

 p_description                   IN     pa_project_subteams.description%TYPE                  := FND_API.g_miss_char,

 p_record_version_number         IN     pa_project_subteams.record_version_number%TYPE := FND_API.g_miss_num,

 p_attribute_category            IN     pa_project_subteams.attribute_category%TYPE           := FND_API.g_miss_char,

 p_attribute1                    IN pa_project_subteams.attribute1%TYPE                   := FND_API.G_MISS_CHAR,

 p_attribute2                    IN pa_project_subteams.attribute2%TYPE                   := FND_API.G_MISS_CHAR,

 p_attribute3                    IN pa_project_subteams.attribute3%TYPE                   := FND_API.G_MISS_CHAR,

 p_attribute4                    IN pa_project_subteams.attribute4%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute5                    IN pa_project_subteams.attribute5%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute6                    IN pa_project_subteams.attribute6%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute7                    IN pa_project_subteams.attribute7%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute8                    IN pa_project_subteams.attribute8%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute9                    IN pa_project_subteams.attribute9%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute10                    IN pa_project_subteams.attribute10%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute11                    IN pa_project_subteams.attribute11%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute12                    IN pa_project_subteams.attribute12%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute13                    IN pa_project_subteams.attribute13%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute14                    IN pa_project_subteams.attribute14%TYPE                   := FND_API.G_MISS_CHAR,


 p_attribute15                    IN pa_project_subteams.attribute15%TYPE                   := FND_API.G_MISS_CHAR,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
-- x_record_version_number       OUT    NUMBER ,
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);



PROCEDURE Delete_Subteam
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2                                        := FND_API.g_false,

 p_validate_only               IN     VARCHAR2                                        := FND_API.g_true,

 p_validation_level            IN     NUMBER                                        := FND_API.g_valid_level_full,

 p_calling_module              IN     VARCHAR2
     := 'SELF_SERVICE',

 p_debug_mode                  IN     VARCHAR2 := 'N',

 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_subteam_row_id              IN     ROWID := NULL,

 p_subteam_id                  IN     pa_project_subteams.project_subteam_id%TYPE := fnd_api.g_miss_num,

 p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

) ;

PROCEDURE Get_Subteam_Id
(
 p_subteam_name                IN     pa_project_subteams.name%TYPE := fnd_api.g_miss_char,
 p_object_type                IN     pa_project_subteams.object_type%TYPE := fnd_api.g_miss_char,
 p_object_id                  IN     pa_project_subteams.object_id%TYPE := fnd_api.g_miss_num,
 x_subteam_id                  OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

) ;

END pa_project_subteams_pvt;
 

/
