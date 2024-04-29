--------------------------------------------------------
--  DDL for Package PA_ASSIGNMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASSIGNMENTS_PVT" AUTHID CURRENT_USER AS
/*$Header: PARAPVTS.pls 120.1 2005/08/19 16:47:44 mwasowic noship $*/
--
PROCEDURE Create_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_creation_mode          IN     VARCHAR2                                        := 'FULL'
 ,p_unfilled_assignment_status  IN     pa_project_assignments.status_code%TYPE         := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN     pa_project_subteams.project_subteam_id%TYPE     := FND_API.G_MISS_NUM
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
 ,x_resource_id                 OUT    NOCOPY pa_resources.resource_id%TYPE --File.Sql.39 bug 4440895
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );



PROCEDURE Update_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_project_subteam_id          IN     pa_project_subteams.project_subteam_id%TYPE     := FND_API.G_MISS_NUM
 ,p_project_subteam_party_id    IN     pa_project_subteam_parties.project_subteam_party_id%TYPE   := FND_API.G_MISS_NUM
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Delete_Assignment
( p_assignment_row_id           IN     ROWID                                           := NULL
 ,p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE       := FND_API.G_MISS_NUM
 ,p_assignment_type             IN     pa_project_assignments.assignment_type%TYPE     := FND_API.G_MISS_CHAR
 ,p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_assignment_number           IN     pa_project_assignments.assignment_number%TYPE   := FND_API.G_MISS_NUM
 ,p_calling_module              IN     VARCHAR2                                        := FND_API.G_MISS_CHAR
 ,p_project_party_id            IN     pa_project_parties.project_party_id%TYPE        := FND_API.G_MISS_NUM
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

 PROCEDURE Update_Revenue_Bill_Rate
( p_assignment_id_tbl           IN     PA_PLSQL_DATATYPES.IdTabTyp
 ,p_revenue_bill_rate_tbl       IN     PA_PLSQL_DATATYPES.NumTabTyp
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/* Added procedure Update_Transfer_Price  for bug 3051110*/
PROCEDURE Update_Transfer_Price
( p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE
 ,p_transfer_price_rate         IN     pa_project_assignments.transfer_price_rate%TYPE
 ,p_transfer_pr_rate_curr       IN     pa_project_assignments.transfer_pr_rate_curr%TYPE
 ,p_debug_mode        IN         VARCHAR2 DEFAULT 'N'
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/* Added procedure Calc_Init_Transfer_Price for bug 3051110*/
PROCEDURE Calc_Init_Transfer_Price
( p_assignment_id     IN         pa_project_assignments.assignment_id%TYPE
 ,p_start_date        IN         pa_project_assignments.start_date%TYPE
 ,p_debug_mode        IN         VARCHAR2 DEFAULT 'N'
 ,x_return_status     OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_data          OUT        NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count         OUT        NOCOPY Number --File.Sql.39 bug 4440895
);

PROCEDURE Update_Task_Assignments
( p_mode  					IN  VARCHAR2  		  	   := 'UPDATE'
 ,p_task_assignment_id_tbl	IN 	system.pa_num_tbl_type
 ,p_task_version_id_tbl		IN  system.pa_num_tbl_type
 ,p_budget_version_id_tbl	IN  system.pa_num_tbl_type
 ,p_struct_version_id_tbl	IN  system.pa_num_tbl_type
 ,p_project_assignment_id 	IN  NUMBER 				   := NULL
 ,p_resource_list_member_id IN  NUMBER				   := NULL
 ,p_resource_class_flag		IN 	VARCHAR2			   := NULL
 ,p_resource_class_code		IN 	VARCHAR2			   := NULL
 ,p_resource_class_id		IN 	NUMBER				   := NULL
 ,p_res_type_code			IN 	VARCHAR2			   := NULL
 ,p_incur_by_res_type		IN 	VARCHAR2			   := NULL
 ,p_person_id				IN 	NUMBER				   := NULL
 ,p_job_id					IN 	NUMBER				   := NULL
 ,p_person_type_code		IN 	VARCHAR2			   := NULL
 ,p_named_role				IN 	VARCHAR2			   := NULL
 ,p_bom_resource_id			IN 	NUMBER				   := NULL
 ,p_non_labor_resource		IN 	VARCHAR2			   := NULL
 ,p_inventory_item_id		IN 	NUMBER				   := NULL
 ,p_item_category_id		IN 	NUMBER				   := NULL
 ,p_project_role_id			IN  NUMBER				   := NULL
 ,p_organization_id			IN 	NUMBER				   := NULL
 ,p_fc_res_type_code		IN 	VARCHAR2			   := NULL
 ,p_expenditure_type		IN 	VARCHAR2			   := NULL
 ,p_expenditure_category	IN 	VARCHAR2			   := NULL
 ,p_event_type				IN 	VARCHAR2			   := NULL
 ,p_revenue_category_code	IN 	VARCHAR2			   := NULL
 ,p_supplier_id				IN 	NUMBER				   := NULL
 ,p_spread_curve_id			IN 	NUMBER				   := NULL
 ,p_etc_method_code			IN 	VARCHAR2			   := NULL
 ,p_mfc_cost_type_id		IN 	NUMBER				   := NULL
 ,p_incurred_by_res_flag	IN 	VARCHAR2			   := NULL
 ,p_incur_by_res_class_code	IN 	VARCHAR2			   := NULL
 ,p_incur_by_role_id		IN 	NUMBER				   := NULL
 ,p_unit_of_measure			IN 	VARCHAR2			   := NULL
 ,p_org_id					IN 	NUMBER				   := NULL
 ,p_rate_based_flag			IN 	VARCHAR2			   := NULL
 ,p_rate_expenditure_type	IN 	VARCHAR2			   := NULL
 ,p_rate_func_curr_code		IN 	VARCHAR2			   := NULL
 ,p_rate_incurred_by_org_id	IN 	NUMBER				   := NULL
 ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END pa_assignments_pvt;

 

/
