--------------------------------------------------------
--  DDL for Package PA_PROJECT_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_SETS_PVT" AUTHID CURRENT_USER AS
/*$Header: PAPPSPVS.pls 120.1 2005/08/19 16:43:52 mwasowic noship $*/
--+

PROCEDURE create_project_set
( p_project_set_name       IN    pa_project_sets_tl.name%TYPE
 ,p_party_id               IN    pa_project_sets_b.party_id%TYPE
 ,p_effective_start_date   IN    pa_project_sets_b.effective_start_date%TYPE
 ,p_effective_end_date     IN    pa_project_sets_b.effective_end_date%TYPE
 ,p_access_level           IN    pa_project_sets_b.access_level%TYPE
 ,p_description            IN    pa_project_sets_tl.description%TYPE
 ,p_party_name             IN    hz_parties.party_name%TYPE
 ,p_attribute_category     IN    pa_project_sets_b.attribute_category%TYPE
 ,p_attribute1             IN    pa_project_sets_b.attribute1%TYPE
 ,p_attribute2             IN    pa_project_sets_b.attribute2%TYPE
 ,p_attribute3             IN    pa_project_sets_b.attribute3%TYPE
 ,p_attribute4             IN    pa_project_sets_b.attribute4%TYPE
 ,p_attribute5             IN    pa_project_sets_b.attribute5%TYPE
 ,p_attribute6             IN    pa_project_sets_b.attribute6%TYPE
 ,p_attribute7             IN    pa_project_sets_b.attribute7%TYPE
 ,p_attribute8             IN    pa_project_sets_b.attribute8%TYPE
 ,p_attribute9             IN    pa_project_sets_b.attribute9%TYPE
 ,p_attribute10            IN    pa_project_sets_b.attribute10%TYPE
 ,p_attribute11            IN    pa_project_sets_b.attribute11%TYPE
 ,p_attribute12            IN    pa_project_sets_b.attribute12%TYPE
 ,p_attribute13            IN    pa_project_sets_b.attribute13%TYPE
 ,p_attribute14            IN    pa_project_sets_b.attribute14%TYPE
 ,p_attribute15            IN    pa_project_sets_b.attribute15%TYPE
 ,x_project_set_id        OUT    NOCOPY pa_project_sets_b.project_set_id%TYPE           --File.Sql.39 bug 4440895
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE update_project_set
( p_project_set_id         IN    pa_project_sets_b.project_set_id%TYPE
 ,p_project_set_name       IN    pa_project_sets_tl.name%TYPE
 ,p_party_id               IN    pa_project_sets_b.party_id%TYPE
 ,p_effective_start_date   IN    pa_project_sets_b.effective_start_date%TYPE
 ,p_effective_end_date     IN    pa_project_sets_b.effective_end_date%TYPE
 ,p_access_level           IN    pa_project_sets_b.access_level%TYPE
 ,p_description            IN    pa_project_sets_tl.description%TYPE
 ,p_party_name             IN    hz_parties.party_name%TYPE
 ,p_attribute_category     IN    pa_project_sets_b.attribute_category%TYPE
 ,p_attribute1             IN    pa_project_sets_b.attribute1%TYPE
 ,p_attribute2             IN    pa_project_sets_b.attribute2%TYPE
 ,p_attribute3             IN    pa_project_sets_b.attribute3%TYPE
 ,p_attribute4             IN    pa_project_sets_b.attribute4%TYPE
 ,p_attribute5             IN    pa_project_sets_b.attribute5%TYPE
 ,p_attribute6             IN    pa_project_sets_b.attribute6%TYPE
 ,p_attribute7             IN    pa_project_sets_b.attribute7%TYPE
 ,p_attribute8             IN    pa_project_sets_b.attribute8%TYPE
 ,p_attribute9             IN    pa_project_sets_b.attribute9%TYPE
 ,p_attribute10            IN    pa_project_sets_b.attribute10%TYPE
 ,p_attribute11            IN    pa_project_sets_b.attribute11%TYPE
 ,p_attribute12            IN    pa_project_sets_b.attribute12%TYPE
 ,p_attribute13            IN    pa_project_sets_b.attribute13%TYPE
 ,p_attribute14            IN    pa_project_sets_b.attribute14%TYPE
 ,p_attribute15            IN    pa_project_sets_b.attribute15%TYPE
 ,p_record_version_number  IN    pa_project_sets_b.record_version_number%TYPE
 ,x_return_status         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE delete_project_set
(  p_project_set_id        IN  pa_project_sets_b.project_set_id%TYPE
  ,p_record_version_number IN  pa_project_sets_b.record_version_number%TYPE
  ,x_return_status        OUT  NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
);


PROCEDURE create_project_set_line
(  p_project_set_id     IN   pa_project_set_lines.project_set_id%TYPE
  ,p_project_id         IN   pa_project_set_lines.project_id%TYPE
  ,x_return_status     OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);


PROCEDURE delete_project_set_line
(  p_project_set_id     IN   pa_project_set_lines.project_set_id%TYPE
  ,p_project_id         IN   pa_project_set_lines.project_id%TYPE
  ,x_return_status     OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);

PROCEDURE delete_proj_from_proj_set
(  p_project_id         IN   pa_project_set_lines.project_id%TYPE
  ,x_return_status     OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END PA_PROJECT_SETS_PVT;
 

/
