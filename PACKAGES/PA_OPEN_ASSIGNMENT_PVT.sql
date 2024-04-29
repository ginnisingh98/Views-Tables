--------------------------------------------------------
--  DDL for Package PA_OPEN_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_OPEN_ASSIGNMENT_PVT" AUTHID CURRENT_USER AS
/*$Header: PAROPVTS.pls 120.1 2005/08/19 16:57:38 mwasowic noship $*/
--
PROCEDURE Create_Open_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_creation_mode          IN     VARCHAR2
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_adv_action_set_id           IN    NUMBER                                           := FND_API.G_MISS_NUM
 ,p_start_adv_action_set_flag   IN    VARCHAR2                                         := FND_API.G_MISS_CHAR
 ,p_sum_tasks_flag				IN     VARCHAR2										   := FND_API.G_FALSE  -- FP.M Development
 ,p_budget_version_id			IN	   pa_resource_assignments.budget_version_id%TYPE  := FND_API.G_MISS_NUM
 ,p_number_of_requirements      IN     NUMBER                                          := 1
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_new_assignment_id           OUT    NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT    NOCOPY pa_project_assignments.assignment_number%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT    NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );



PROCEDURE Update_Open_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Delete_Open_Assignment
( p_assignment_row_id           IN     ROWID
 ,p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE       := FND_API.G_MISS_NUM
 ,p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_calling_module              IN     VARCHAR2                                        := FND_API.G_MISS_NUM
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

END pa_open_assignment_pvt;

 

/
