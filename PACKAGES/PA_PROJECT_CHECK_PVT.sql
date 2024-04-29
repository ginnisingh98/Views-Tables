--------------------------------------------------------
--  DDL for Package PA_PROJECT_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_CHECK_PVT" AUTHID DEFINER as
/*$Header: PAPMPCVS.pls 120.2 2007/02/06 10:24:39 dthakker ship $*/


--Package constant used for package version validation

G_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;
-- Package variable to indicate whether some date checks in Update_task
-- need to be deferred until all tasks have been processed
G_ParChildTsk_chks_deferred  VARCHAR2(1) := 'N';

 -- Required for the Special Task number change handling in
 -- Update_Project

TYPE task_number_upd_rec_type IS RECORD
(task_index  NUMBER ,
 task_id     NUMBER);
TYPE task_number_upd_tbl_type IS TABLE OF task_number_upd_rec_type
        INDEX BY BINARY_INTEGER;

G_task_num_updated_index_tbl  task_number_upd_tbl_type;

G_index_counter      NUMBER := 0;

--Locking exception

ROW_ALREADY_LOCKED   EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);

G_PROJECT_NUMBER_GEN_MODE  VARCHAR2(30) := PA_PROJECT_UTILS.GetProjNumMode;
G_PROJECT_NUMBER_TYPE      VARCHAR2(30) := PA_PROJECT_UTILS.GetProjNumType;

PROCEDURE Check_Delete_Task_OK_Pvt
( p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Project Structure changes done for bug 2765115
, p_structure_type              IN      VARCHAR2        := 'FINANCIAL'
, p_task_version_id             IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--END Project Structure changes done for bug 2765115
, p_delete_task_ok_flag		OUT	NOCOPY VARCHAR2				);  --File.Sql.39 bug 4440895

PROCEDURE Check_Add_Subtask_OK_Pvt
(p_api_version_number		IN	NUMBER
,p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_add_subtask_ok_flag		OUT	NOCOPY VARCHAR2				); --File.Sql.39 bug 4440895

PROCEDURE Check_Unique_Task_Ref_Pvt
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_pm_task_reference		IN	VARCHAR2
, p_unique_task_ref_flag	OUT	NOCOPY VARCHAR2				); --File.Sql.39 bug 4440895

PROCEDURE Check_Unique_Project_Ref_Pvt
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_pm_project_reference	IN	VARCHAR2
, p_unique_project_ref_flag	OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Check_Delete_Project_OK_Pvt
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_delete_project_ok_flag	OUT	NOCOPY VARCHAR2				); --File.Sql.39 bug 4440895

PROCEDURE Check_Change_Parent_OK_Pvt
(p_api_version_number		 IN	NUMBER
, p_init_msg_list		 IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		 OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			 OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			 OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			 IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	 IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			 IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		 IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_new_parent_task_id		 IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_new_parent_task_reference IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_change_parent_ok_flag	 OUT	NOCOPY VARCHAR2				); --File.Sql.39 bug 4440895

PROCEDURE Check_Change_Proj_Org_OK_Pvt
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_change_project_org_ok_flag	OUT	NOCOPY VARCHAR2				); --File.Sql.39 bug 4440895

PROCEDURE Check_Unique_Task_Number_Pvt
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_number			IN	VARCHAR2
, p_unique_task_number_flag	OUT	NOCOPY VARCHAR2				); --File.Sql.39 bug 4440895

PROCEDURE Check_Task_Numb_Change_Ok_Pvt
( p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_number_change_Ok_flag	OUT	NOCOPY VARCHAR2				); --File.Sql.39 bug 4440895

PROCEDURE Validate_billing_info_Pvt
          (p_project_id             IN    NUMBER, -- Added for Bug 5643876
	   p_project_class_code     IN    VARCHAR2,
           p_in_task_rec            IN    pa_project_pub.task_in_rec_type,
           p_return_status         OUT    NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

PROCEDURE check_start_end_date_Pvt
( p_return_status			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_old_start_date			IN	DATE
 ,p_new_start_date			IN	DATE
 ,p_old_end_date			IN	DATE
 ,p_new_end_date			IN	DATE
 ,p_update_start_date_flag		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_update_end_date_flag		OUT	NOCOPY VARCHAR2		); --File.Sql.39 bug 4440895

Procedure check_for_one_manager_Pvt
                (p_project_id   IN NUMBER,
                 p_person_id    IN NUMBER,
                 p_key_members  IN pa_project_pub.project_role_tbl_type,
                 p_start_date   IN DATE,
                 p_end_date     IN DATE,
                 p_return_status OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

Procedure handle_task_number_change_Pvt
          (p_project_id                   IN NUMBER,
           p_task_id                      IN NUMBER,
           p_array_cell_number            IN NUMBER,
           p_in_task_number               IN VARCHAR2,
           p_in_task_tbl                  IN pa_project_pub.task_in_tbl_type,
           p_proceed_with_update_flag    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
           p_return_status               OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

Procedure check_parent_child_tk_dts_Pvt
          (p_project_id                   IN NUMBER,
           p_return_status               OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/* Added the following procedure for bug #2111806 */
Procedure CHECK_MANAGER_DATE_RANGE
          (p_project_id                   IN NUMBER,
           p_return_status               OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

end PA_PROJECT_CHECK_PVT;

/
