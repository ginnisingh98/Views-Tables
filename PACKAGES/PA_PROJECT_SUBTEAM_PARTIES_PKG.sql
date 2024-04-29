--------------------------------------------------------
--  DDL for Package PA_PROJECT_SUBTEAM_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_SUBTEAM_PARTIES_PKG" AUTHID CURRENT_USER AS
--$Header: PARTSPHS.pls 120.1 2005/08/19 17:01:41 mwasowic noship $


PROCEDURE Insert_Row
(
 p_project_subteam_id     IN pa_project_subteams.Project_subteam_id%TYPE := FND_API.g_miss_num,

 p_object_type            IN pa_project_subteam_parties.object_type%TYPE := FND_API.g_miss_char,

 p_object_id              IN pa_project_subteam_parties.object_id%TYPE := fnd_api.g_miss_num,

 p_primary_subteam_flag           IN pa_project_subteam_parties.primary_subteam_flag%TYPE := 'Y',

 x_project_subteam_party_row_id   OUT  NOCOPY ROWID, --File.Sql.39 bug 4440895

 x_project_subteam_party_id       OUT  NOCOPY pa_project_subteam_parties.project_subteam_party_id%TYPE, --File.Sql.39 bug 4440895

 x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895

 x_msg_count              OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895

 x_msg_data               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Update_Row
(
 p_project_subteam_party_row_id   IN   ROWID :=NULL,

 p_project_subteam_party_id       IN   pa_project_subteam_parties.project_subteam_party_id%TYPE,

 p_project_subteam_id     IN   pa_project_subteams.project_subteam_id%TYPE,

-- p_object_type            IN varchar2,

-- p_object_id              IN NUMBER := fnd_api.g_miss_num,

 p_primary_subteam_flag            IN  pa_project_subteam_parties.primary_subteam_flag%TYPE := 'Y',

 p_record_version_number  IN NUMBER   := NULL,

 x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895

 x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895

 x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Delete_Row
(
  p_project_subteam_party_row_id       IN   ROWID
 ,p_project_subteam_party_id            IN   pa_project_subteam_parties.project_subteam_party_id%TYPE
 ,p_record_version_number       IN   NUMBER  := NULL
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

END PA_PROJECT_SUBTEAM_PARTIES_pkg;
 

/
