--------------------------------------------------------
--  DDL for Package PA_XC_PROJECT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_XC_PROJECT_PUB" AUTHID DEFINER as
/*$Header: PAXCPR1S.pls 120.2 2006/06/01 22:48:43 sliburd noship $*/

--Package constant used for package version validation

G_API_VERSION_NUMBER    CONSTANT NUMBER := 1.0;

--Locking exception
ROW_ALREADY_LOCKED   EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);

--Counters
G_tasks_tbl_count             NUMBER:=0;

-- Procedure Import Project.

-- Task Record structure

TYPE task_in_rec_type IS RECORD
(task_id                NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 task_reference         NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 task_name              VARCHAR2(150)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 task_start_date        DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 task_end_date          DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 task_number            VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 wbs_level              NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 task_description       VARCHAR2(250)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 parent_task_reference  NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 early_start_date       DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 early_finish_date      DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 late_start_date        DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 late_finish_date       DATE           := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 attribute1             VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute2             VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute3             VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute5             VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- AJL
 login_user_name        VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute4             VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute6             VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute7             VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute8             VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute9             VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 attribute10            VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 progress_report        VARCHAR2(4000) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 progress_status        VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 progress_comments      VARCHAR2(150)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 progress_asof_date     VARCHAR2(10)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 predecessors           VARCHAR2(2000) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR );
-- AJL

-- Creating plsql table task.

TYPE task_in_tbl_type IS TABLE OF task_in_rec_type INDEX BY BINARY_INTEGER;

-- Global plsql task.

G_tasks_in_tbl       task_in_tbl_type;

-- Procedure Import Task.

PROCEDURE import_task
( p_project_id                IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_reference            IN  PA_VC_1000_25
 ,p_task_name                 IN  PA_VC_1000_150
 ,p_task_start_date           IN  PA_VC_1000_10
 ,p_task_end_date             IN  PA_VC_1000_10
 ,p_parent_task_reference     IN  PA_VC_1000_25
 ,p_task_number               IN  PA_VC_1000_25
 ,p_wbs_level                 IN  PA_NUM_1000_NUM
 ,p_milestone                 IN  PA_VC_1000_150
 ,p_duration                  IN  PA_VC_1000_150
 ,p_duration_unit             IN  PA_VC_1000_150
 ,p_early_start_date          IN  PA_VC_1000_10
 ,p_early_finish_date         IN  PA_VC_1000_10
 ,p_late_start_date           IN  PA_VC_1000_10
 ,p_late_finish_date          IN  PA_VC_1000_10
 ,p_display_seq               IN  PA_VC_1000_150
-- AJL
 ,p_login_user_name           IN  PA_VC_1000_150 := PA_VC_1000_150(PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
 ,p_critical_path             IN  PA_VC_1000_150
 ,p_sub_project_id            IN  PA_VC_1000_150
 ,p_attribute7                IN  PA_VC_1000_150
 ,p_attribute8                IN  PA_VC_1000_150
 ,p_attribute9                IN  PA_VC_1000_150
 ,p_attribute10               IN  PA_VC_1000_150
 ,p_progress_report           IN  PA_VC_1000_4000
 ,p_progress_status           IN  PA_VC_1000_150
 ,p_progress_comments         IN  PA_VC_1000_150
 ,p_progress_asof_date        IN  PA_VC_1000_10
 ,p_predecessors              IN  PA_VC_1000_2000
 ,p_language                  IN  VARCHAR2 default 'US'
 ,p_delimiter                 IN  VARCHAR2 default ','

-- Structure sync up
 ,p_structure_version_id      IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_calling_mode              IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 -- Structure sync up
 );
-- AJL

PROCEDURE import_project
( p_user_id                   IN  NUMBER
 ,p_commit                    IN  VARCHAR2 default 'N'
 ,p_debug_mode                IN  VARCHAR2 default 'N'
 ,p_project_id                IN  NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_mpx_start_date    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_mpx_end_date      IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- AJL
 ,p_task_mgr_override         IN  VARCHAR2 default 'N'
 ,p_task_pgs_override         IN  VARCHAR2 default 'N'
-- AJL
 ,p_process_id                IN  NUMBER default -1
 ,p_language                  IN  VARCHAR2 default 'US'
 ,p_delimiter                 IN  VARCHAR2 default ','
 ,p_responsibility_id         IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_id              IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_version_id      IN  NUMBER
 ,p_calling_mode              IN  VARCHAR2
 ,p_resp_appl_id              IN  NUMBER default 275 --   5233777
 ,x_msg_count                 IN OUT    NOCOPY NUMBER  --File.Sql.39 bug 4440895
 ,x_msg_data                  IN OUT    NOCOPY PA_VC_1000_2000 --File.Sql.39 bug 4440895
 ,x_return_status             IN OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION is_number
( value_in          IN        VARCHAR2)
RETURN BOOLEAN;

PROCEDURE fetch_task_id
( p_task_index             IN    VARCHAR2     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR --Bug 3302732
 ,p_project_id             IN    NUMBER
 ,p_pm_task_reference      IN    VARCHAR2
 ,x_task_id    		  OUT    NOCOPY NUMBER); --File.Sql.39 bug 4440895

-- Bug 3302732
FUNCTION generate_new_task_reference
(p_project_id              IN    NUMBER,
 p_proj_element_id         IN    NUMBER)
RETURN VARCHAR2;

-- Bug 3302732
FUNCTION check_ref_unique
(p_project_id              IN    NUMBER,
 p_new_task_reference      IN    VARCHAR2)
RETURN VARCHAR2;

end PA_XC_PROJECT_PUB;

 

/
