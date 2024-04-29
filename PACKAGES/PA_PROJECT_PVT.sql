--------------------------------------------------------
--  DDL for Package PA_PROJECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_PVT" AUTHID DEFINER as
/*$Header: PAPMPRVS.pls 120.2 2007/02/06 10:26:44 dthakker ship $*/

 -- Required for the Special Task number change handling in
 -- Update_Project

TYPE task_number_upd_rec_type IS RECORD
(task_index  NUMBER ,
 task_id     NUMBER);
TYPE task_number_upd_tbl_type IS TABLE OF task_number_upd_rec_type
        INDEX BY BINARY_INTEGER;

G_task_num_updated_index_tbl  task_number_upd_tbl_type;

G_index_counter      NUMBER := 0;
G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;
--Locking exception
ROW_ALREADY_LOCKED	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);

PROCEDURE add_key_members
( p_return_status			OUT	NOCOPY	VARCHAR2				,		--Bug: 4537865
  p_pa_source_template_id		IN	NUMBER					,
  p_project_id				IN	NUMBER					,
  p_key_members				IN	pa_project_pub.project_role_tbl_type	);

PROCEDURE add_class_categories
( p_return_status			OUT	NOCOPY  VARCHAR2				,		--Bug: 4537865
  p_pa_source_template_id		IN	NUMBER					,
  p_project_id				IN	NUMBER					,
  p_class_categories			IN	pa_project_pub.class_category_tbl_type	);

PROCEDURE add_task_round_one
(p_return_status			OUT	NOCOPY  VARCHAR2						--Bug: 4537865
,p_project_rec				IN	pa_projects%rowtype
,p_task_rec				IN	pa_project_pub.task_in_rec_type
,p_project_type_class_code		IN	pa_project_types.project_type_class_code%type
,p_service_type_code			IN	pa_project_types.service_type_code%type
,p_task_id				OUT	NOCOPY  NUMBER						);	--Bug: 4537865

PROCEDURE add_task_round_two
(p_return_status			OUT	NOCOPY  VARCHAR2						--Bug: 4537865
,p_project_rec				IN	pa_projects%rowtype
,p_task_id				IN	NUMBER
,p_task_rec				IN	pa_project_pub.task_in_rec_type
--Project Structures
,p_ref_task_id                          IN      NUMBER
,p_tasks_in			        IN	pa_project_pub.task_in_tbl_type
,p_tasks_out			        IN	pa_project_pub.task_out_tbl_type
,p_task_version_id                      OUT     NOCOPY  NUMBER							--Bug: 4537865
,p_create_task_structure         IN     VARCHAR2  := 'Y'  --Bug 2931183
--Project Structures
	);

FUNCTION Fetch_project_id
(p_pm_project_reference 		IN 	VARCHAR2 )
RETURN  NUMBER;

FUNCTION Fetch_task_id
(p_pa_project_id        		IN 	NUMBER
,p_pm_task_reference    		IN 	VARCHAR2 )
RETURN NUMBER;

Procedure Convert_pm_projref_to_id
(p_pm_project_reference 		IN 	VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_pa_project_id        		IN 	NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_out_project_id       		OUT 	NOCOPY  NUMBER							--Bug: 4537865
,p_return_status        		OUT 	NOCOPY  VARCHAR2 				);		--Bug: 4537865

Procedure Convert_pm_taskref_to_id
(p_pa_project_id        		IN 	NUMBER
,p_pa_task_id           		IN 	NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_pm_task_reference    		IN 	VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_out_task_id         			OUT 	NOCOPY   NUMBER							--Bug: 4537865
,p_return_status        		OUT 	NOCOPY   VARCHAR2 				);		--Bug: 4537865

Procedure Convert_pm_taskref_to_id_all (
 p_pa_project_id        IN NUMBER,
 p_structure_type       IN VARCHAR2 := 'FINANCIAL',
 p_pa_task_id           IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_pm_task_reference    IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_out_task_id          OUT NOCOPY   NUMBER,									--Bug: 4537865
 p_return_status        OUT NOCOPY   VARCHAR2 );								--Bug: 4537865

FUNCTION check_valid_message (p_message IN VARCHAR2)
RETURN BOOLEAN ;

FUNCTION check_valid_org (p_org_id IN NUMBER )
RETURN VARCHAR2;

FUNCTION check_valid_project_status( p_project_status IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION check_valid_dist_rule (p_project_type IN VARCHAR2,
                                p_dist_rule IN VARCHAR2,
                                p_en_top_task_inv_mth_flag IN VARCHAR2 := 'N' )
RETURN VARCHAR2;

FUNCTION check_valid_employee (p_person_id IN NUMBER )
RETURN VARCHAR2;

FUNCTION check_class_code_valid (p_class_category IN VARCHAR2,
                                 p_class_code     IN VARCHAR2 )
RETURN VARCHAR2;

PROCEDURE Delete_One_Task
          (p_task_id             IN NUMBER,
           p_return_status      OUT NOCOPY VARCHAR2,							--Bug: 4537865
           p_msg_count	        OUT NOCOPY NUMBER,							--Bug: 4537865
           p_msg_data	        OUT NOCOPY VARCHAR2 );							--Bug: 4537865

PROCEDURE Validate_billing_info
          (p_project_id             IN    NUMBER, -- Added for Bug: 5643876
	   p_project_class_code     IN    VARCHAR2,
           p_in_task_rec            IN    pa_project_pub.task_in_rec_type,
           p_return_status          OUT NOCOPY    VARCHAR2 ) ;						--Bug: 4537865

PROCEDURE check_start_end_date
( p_return_status			OUT NOCOPY	VARCHAR2					--Bug: 4537865
 ,p_old_start_date			IN	DATE
 ,p_new_start_date			IN	DATE
 ,p_old_end_date			IN	DATE
 ,p_new_end_date			IN	DATE
 ,p_update_start_date_flag		OUT NOCOPY	VARCHAR2					--Bug: 4537865
 ,p_update_end_date_flag		OUT NOCOPY	VARCHAR2		);			--Bug: 4537865

Procedure check_for_one_manager
                (p_project_id   IN NUMBER,
                 p_person_id    IN NUMBER,
                 p_key_members  IN pa_project_pub.project_role_tbl_type,
                 p_start_date   IN DATE,
                 p_end_date     IN DATE,
                 p_return_status OUT NOCOPY VARCHAR2 );							--Bug: 4537865

Procedure handle_task_number_change
          (p_project_id                   IN NUMBER,
           p_task_id                      IN NUMBER,
           p_array_cell_number            IN NUMBER,
           p_in_task_number               IN VARCHAR2,
           p_in_task_tbl                  IN pa_project_pub.task_in_tbl_type,
           p_proceed_with_update_flag     OUT NOCOPY VARCHAR2,						--Bug: 4537865
           p_return_status                OUT NOCOPY VARCHAR2 ) ;					--Bug: 4537865

Procedure check_parent_child_task_dates
          (p_project_id                   IN NUMBER,
           p_return_status                OUT NOCOPY VARCHAR2 );					--Bug: 4537865

Procedure Update_One_Task
( p_api_version_number		   	IN	NUMBER		:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_commit			   	IN	VARCHAR2	:= FND_API.G_FALSE,
  p_init_msg_list		   	IN	VARCHAR2	:= FND_API.G_FALSE,
  p_msg_count			   	OUT	NOCOPY  NUMBER,						--Bug: 4537865
  p_msg_data			   	OUT	NOCOPY  VARCHAR2,					--Bug: 4537865
  p_return_status		   	OUT	NOCOPY  VARCHAR2,					--Bug: 4537865
  p_pm_product_code		   	IN	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pm_project_reference           	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pa_project_id                  	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_pm_task_reference              	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_number                    	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pa_task_id                     	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_task_name                      	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_long_task_name                     	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_description               	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_start_date                	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_task_completion_date           	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_pm_parent_task_reference       	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pa_parent_task_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_address_id				IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_carrying_out_organization_id   	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_service_type_code              	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_manager_person_id         	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_billable_flag                  	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_chargeable_flag                	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_ready_to_bill_flag             	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_ready_to_distribute_flag       	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_limit_to_txn_controls_flag     	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_labor_bill_rate_org_id         	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_labor_std_bill_rate_schdl      	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_labor_schedule_fixed_date      	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_labor_schedule_discount        	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_nl_bill_rate_org_id            	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_nl_std_bill_rate_schdl         	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_nl_schedule_fixed_date         	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_nl_schedule_discount           	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_labor_cost_multiplier_name     	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_cost_ind_rate_sch_id           	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_rev_ind_rate_sch_id            	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_inv_ind_rate_sch_id            	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_cost_ind_sch_fixed_date        	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_rev_ind_sch_fixed_date         	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_inv_ind_sch_fixed_date         	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_labor_sch_type                 	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_nl_sch_type                    	IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_actual_start_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_actual_finish_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_early_start_date                    IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_early_finish_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_late_start_date                     IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_late_finish_date                    IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_scheduled_start_date                IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_scheduled_finish_date               IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_attribute_category			IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute1				IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute2				IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute3				IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute4				IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute5				IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute6				IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute7				IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute8				IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute9				IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute10				IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_allow_cross_charge_flag IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_project_rate_date       IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_project_rate_type       IN VARCHAR2    :=
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_cc_process_labor_flag  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_labor_tp_schedule_id   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_labor_tp_fixed_date    IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_cc_process_nl_flag     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_nl_tp_schedule_id      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_nl_tp_fixed_date       IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_receive_project_invoice_flag IN VARCHAR2 :=
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_type_id   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_emp_bill_rate_schedule_id  IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_job_bill_rate_schedule_id  IN NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
--Sakthi  MCB
 p_non_lab_std_bill_rt_sch_id  IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_taskfunc_cost_rate_type     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_taskfunc_cost_rate_date     IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
--Sakthi  MCB
 p_labor_disc_reason_code       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_non_labor_disc_reason_code   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--PA L changes -- bug 2872708  --update_task
 p_retirement_cost_flag          VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_cint_eligible_flag            VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_cint_stop_date                DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
--end PA L changes -- bug 2872708

--(Begin Venkat) FP_M changes ----------------------------------------------
 p_invoice_method                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_customer_id                   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_gen_etc_source_code           IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--(End Venkat) FP_M changes ------------------------------------------------

  p_out_pa_task_id                 	OUT  	NOCOPY  NUMBER,						--Bug: 4537865
  p_out_pm_task_reference          	OUT  	NOCOPY  VARCHAR2			);		--Bug: 4537865

PROCEDURE delete_task1
( p_api_version_number		IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit			IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count			OUT	NOCOPY NUMBER  							--Bug: 4537865
 ,p_msg_data			OUT	NOCOPY VARCHAR2							--Bug: 4537865
 ,p_return_status		OUT	NOCOPY VARCHAR2 						--Bug: 4537865
 ,p_pm_product_code		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id		IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_cascaded_delete_flag	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_id			OUT	NOCOPY NUMBER							--Bug: 4537865
 ,p_task_id			OUT	NOCOPY NUMBER							--Bug: 4537865
 ,p_task_version_id             IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_type              IN      VARCHAR2        := 'FINANCIAL'
);

PROCEDURE approve_project1
( p_api_version_number     IN NUMBER
 ,p_commit        IN VARCHAR2 := FND_API.G_FALSE
 ,p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE
 ,p_msg_count        OUT   NOCOPY NUMBER								--Bug: 4537865
 ,p_msg_data         OUT   NOCOPY VARCHAR2								--Bug: 4537865
 ,p_return_status    OUT   NOCOPY VARCHAR2 								--Bug: 4537865
 ,p_pm_product_code     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id    IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 );

PROCEDURE delete_project1
( p_api_version_number     IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit        IN VARCHAR2 := FND_API.G_FALSE
 ,p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE
 ,p_msg_count        OUT   NOCOPY  NUMBER								--Bug: 4537865
 ,p_msg_data         OUT   NOCOPY  VARCHAR2								--Bug: 4537865
 ,p_return_status    OUT   NOCOPY  VARCHAR2								--Bug: 4537865
 ,p_pm_product_code     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id    IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 );

-- anlee org role changes
PROCEDURE add_org_roles
( p_return_status			OUT	NOCOPY   VARCHAR2			,		--Bug: 4537865
  p_pa_source_template_id		IN	NUMBER					,
  p_project_id				IN	NUMBER					,
  p_org_roles				IN	pa_project_pub.project_role_tbl_type	);

-- anlee org role changes
FUNCTION check_valid_organization (p_party_id IN NUMBER )
RETURN VARCHAR2;

--Project Connect 4.0
PROCEDURE get_structure_version(
   p_project_id              IN NUMBER
  ,p_structure_versions_out  OUT NOCOPY PA_PROJECT_PUB.struc_out_tbl_type );
--Project Connect 4.0

/*Added the below two procedures for the bug 2802984*/
PROCEDURE Check_Schedule_type
     (p_pa_task_id     	        IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_pa_project_id           IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_in_labor_sch_type       IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_in_nl_sch_type          IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_task_name               IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_pm_task_reference       IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_out_labor_sch_type      OUT NOCOPY VARCHAR,							--Bug: 4537865
      p_out_nl_labor_sch_type   OUT NOCOPY VARCHAR,							--Bug: 4537865
      p_return_status           OUT NOCOPY VARCHAR2 							--Bug: 4537865
      );

PROCEDURE validate_schedule_values
   (p_pa_project_id                     IN   	NUMBER    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_pa_task_id                        IN   	NUMBER    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_task_name                         IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_pm_task_reference                 IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_lab_db_sch_type                   IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_nl_db_sch_type                    IN   	VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_labor_sch_type                    IN      VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_nl_sch_type                       IN      VARCHAR2    	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_emp_bill_rate_schedule_id         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_job_bill_rate_schedule_id         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_labor_schedule_fixed_date      	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
    p_labor_schedule_discount        	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_labor_disc_reason_code            IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_nl_bill_rate_org_id            	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_non_lab_std_bill_rt_sch_id        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_nl_schedule_fixed_date         	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
    p_nl_schedule_discount           	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_non_labor_disc_reason_code        IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_rev_ind_rate_sch_id            	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_inv_ind_rate_sch_id            	IN   	NUMBER      	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_rev_ind_sch_fixed_date         	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
    p_inv_ind_sch_fixed_date         	IN   	DATE        	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
    p_return_status                     OUT     NOCOPY VARCHAR2						--Bug: 4537865
    );

PROCEDURE VALIDATE_DATA
   (p_project_id          IN         NUMBER                                         ,
    p_calling_context     IN         VARCHAR2                                       ,
    x_return_status       OUT NOCOPY VARCHAR2                                       ,
    X_MSG_COUNT           OUT NOCOPY NUMBER                                         ,
    X_MSG_DATA            OUT NOCOPY VARCHAR2
    );


end PA_PROJECT_PVT;

/
