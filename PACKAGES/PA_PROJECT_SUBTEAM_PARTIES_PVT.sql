--------------------------------------------------------
--  DDL for Package PA_PROJECT_SUBTEAM_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_SUBTEAM_PARTIES_PVT" AUTHID CURRENT_USER AS
--$Header: PARTSPVS.pls 120.1 2005/08/19 17:01:49 mwasowic noship $

g_error_exists  VARCHAR2(1) := FND_API.G_FALSE;

PROCEDURE Create_Subteam_Party
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

 p_project_subteam_id          IN     pa_project_subteams.Project_subteam_id%TYPE := FND_API.g_miss_num,

 p_object_type                 IN varchar2,

 p_object_id                   IN NUMBER := fnd_api.g_miss_num,

 p_primary_subteam_flag                 IN VARCHAR2 := 'Y',

 x_project_subteam_party_row_id  OUT    NOCOPY ROWID, --File.Sql.39 bug 4440895
 x_project_subteam_party_id      OUT    NOCOPY pa_project_subteam_parties.project_subteam_party_id%TYPE, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Update_Subteam_Party
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

 p_project_subteam_party_row_id        IN     ROWID := null,

 p_project_subteam_party_id            IN     pa_project_subteam_parties.project_subteam_party_id%TYPE := FND_API.g_miss_num,

 p_project_subteam_id          IN     pa_project_subteam_parties.project_subteam_id%TYPE              := FND_API.g_miss_num,

 p_object_type                 IN varchar2,

 p_object_id                   IN NUMBER := fnd_api.g_miss_num,

 p_primary_subteam_flag                IN     VARCHAR2 := fnd_api.g_miss_char,

 p_record_version_number         IN     pa_project_subteams.record_version_number%TYPE := FND_API.g_miss_num,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_record_version_number       OUT    NOCOPY NUMBER , --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Update_SPT_Assgn
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

 p_project_subteam_party_row_id        IN     ROWID := null,

 p_project_subteam_party_id            IN     pa_project_subteam_parties.project_subteam_party_id%TYPE := NULL,

 p_project_subteam_id          IN     pa_project_subteam_parties.project_subteam_id%TYPE              := NULL,

 p_object_type                 IN varchar2,

 p_object_id                   IN NUMBER := fnd_api.g_miss_num,

 p_primary_subteam_flag                IN     VARCHAR2 := fnd_api.g_miss_char,

 p_record_version_number         IN     pa_project_subteams.record_version_number%TYPE := FND_API.g_miss_num,

 p_get_subteam_party_id_flag     IN VARCHAR2 := 'N',

 x_project_subteam_party_id      OUT    NOCOPY pa_project_subteam_parties.project_subteam_party_id%TYPE, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_record_version_number       OUT    NOCOPY NUMBER , --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Delete_Subteam_Party
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

 p_project_subteam_party_row_id              IN     ROWID := NULL,

 p_project_subteam_party_id                  IN     pa_project_subteams.project_subteam_id%TYPE := fnd_api.g_miss_num,

 p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Delete_SubteamParty_By_Obj
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2                                        := FND_API.g_false,

 p_validate_only               IN     VARCHAR2                                        := FND_API.g_true,

 p_validation_level            IN     NUMBER                                        := FND_API.g_valid_level_full,

 p_calling_module              IN     VARCHAR2
     := NULL,

 p_debug_mode                  IN     VARCHAR2 := 'N',

 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_object_type                 IN varchar2,

 p_object_id                   IN NUMBER := fnd_api.g_miss_num,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

);

--
END PA_PROJECT_SUBTEAM_PARTIES_PVT;
 

/
