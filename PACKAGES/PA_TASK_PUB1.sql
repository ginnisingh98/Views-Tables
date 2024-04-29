--------------------------------------------------------
--  DDL for Package PA_TASK_PUB1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_PUB1" AUTHID DEFINER AS
/* $Header: PATSK1PS.pls 120.7.12010000.3 2009/07/21 14:31:21 anuragar ship $ */

G_CALL_PJI_ROLLUP      VARCHAR2(1);   --bug 4075697

-- API name                      : Create_Task
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_object_type          IN    VARCHAR2    N   Not Null
-- p_project_id       IN    NUMBER  N   Not Null
-- p_task_number          IN    VARCHAR2    N   Not Null
-- p_task_name        IN    VARCHAR2    N   Not Null
-- p_task_description   IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_location_id          IN    NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_country          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_territory_code IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_state_region   IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_city               IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_task_manager_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_manager_name  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_carrying_out_org_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_carrying_out_org_name  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_priority_code  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_TYPE_ID          IN    NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_status_code          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_inc_proj_progress_flag IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_product_code    IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_task_reference  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_closed_date          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 --FP M development
-- p_structure_type        IN      VARCHAR2 := 'WORKPLAN',
-- p_financial_flag        IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --End FPM changes
-- x_task_id          OUT   NUMBER  N   Not Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Create_Task(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_object_type        IN    VARCHAR2,
 p_project_id         IN    NUMBER,
 p_structure_id         IN    NUMBER,
 p_structure_version_id IN    NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_number        IN    VARCHAR2,
 p_task_name          IN    VARCHAR2,
 p_ref_task_id          IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_peer_or_sub          IN    VARCHAR2    :='PEER',
 p_task_description IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_location_id        IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_country              IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_territory_code         IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_state_region           IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_city             IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_manager_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_manager_name    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_carrying_out_org_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_carrying_out_org_name    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_priority_code          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_TYPE_ID            IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_status_code        IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_inc_proj_progress_flag   IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_product_code  IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_task_reference    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_closed_date        IN    DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_start_date IN    DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_finish_date IN    DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_link_task_flag        IN   VARCHAR2 := 'N',
 p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_address_id    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_address1      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_type_id  IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_service_type_code IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_chargeable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_billable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_receive_project_invoice_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_task_weighting_deriv_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_item_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_uom_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_wq_actual_entry_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_progress_entry_page_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_progress_entry_page IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_parent_structure_id         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_phase_code                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_phase_version_id            IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 -- xxlu added task DFF attributes
 p_tk_attribute_category     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute1     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute2     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute3     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute4     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute5     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute6     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute7     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute8     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute9     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute10    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 -- end xxlu changes
 --FP M development bug 330119
 p_structure_type        IN      VARCHAR2 := 'WORKPLAN',
 p_financial_flag        IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_Base_Perc_Comp_Deriv_Code    IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --End FPM changes bug 330119
 x_task_id              IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Update_Task
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_id          IN    NUMBER  N   Not Null
-- p_task_number          IN    VARCHAR2    N   Not Null
-- p_task_name        IN    VARCHAR2    N   Not Null
-- p_task_description   IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_location_id          IN    NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_country          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_territory_code IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_state_region   IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_city               IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_task_manager_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_manager_name  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_carrying_out_org_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_carrying_out_org_name  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_priority_code  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_TYPE_ID          IN    NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_status_code          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_inc_proj_progress_flag IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_product_code    IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_pm_task_reference  IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_closed_date          IN    VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_transaction_start_date IN    DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_transaction_finish_date IN   DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_record_version_number  IN  NUMBER  N   Not Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--  31-JUL-02   H Siu                    -Added transaction dates
--
--

PROCEDURE Update_Task(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ref_task_id          IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_peer_or_sub          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_id              IN  NUMBER,
 p_task_number        IN    VARCHAR2,
 p_task_name          IN    VARCHAR2,
 p_task_description IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_location_id        IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_country              IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_territory_code         IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_state_region           IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_city             IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_manager_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_manager_name    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_carrying_out_org_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_carrying_out_org_name    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_priority_code          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_TYPE_ID            IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_status_code        IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_inc_proj_progress_flag   IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_product_code  IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_pm_task_reference    IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_closed_date        IN    DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_transaction_start_date IN    DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_transaction_finish_date IN   DATE    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_address_id    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_address1      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_type_id  IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_service_type_code IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_chargeable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_billable_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_receive_project_invoice_flag IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_task_weighting_deriv_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_item_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_uom_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_wq_actual_entry_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_task_progress_entry_page_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_progress_entry_page IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_parent_structure_id         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_phase_code                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_phase_version_id            IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,

 p_record_version_number    IN  NUMBER,
 -- xxlu added task DFF attributes
 p_tk_attribute_category     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute1     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute2     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute3     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute4     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute5     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute6     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute7     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute8     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute9     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_tk_attribute10    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 -- end xxlu changes
 p_Base_Perc_Comp_Deriv_Code    IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- This param added for FP_M changes 3305199
 p_gen_etc_src_code      IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 -- Bug#3491609 : Workflow Chanegs FP M
 p_wf_item_type          IN    pa_proj_elements.wf_item_type%TYPE       :=NULL,
 p_wf_process            IN    pa_proj_elements.wf_process%TYPE         :=NULL,
 p_wf_lead_days          IN    pa_proj_elements.wf_start_lead_days%TYPE :=NULL,
 p_wf_enabled_flag       IN    pa_proj_elements.enable_wf_flag%TYPE     :=NULL,
  -- Bug#3491609 : Workflow Chanegs FP M
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 p_shared                IN  VARCHAR2 := 'X'    -- Bug 3451073
);

-- API name                      : Create_Task_version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_ref_task_version_id    IN  NUMBER  N   Not Null
-- p_peer_or_sub    IN  VARCHAR2    N   Not Null
-- p_task_id    IN  NUMBER  N   Not Null
--   p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- x_task_version_id    OUT NUMBER  N   Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Create_Task_Version(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ref_task_version_id  IN  NUMBER,
 p_peer_or_sub        IN    VARCHAR2,
 p_task_id              IN  NUMBER,
 p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,

 p_WEIGHTING_PERCENTAGE IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_TASK_UNPUB_VER_STATUS_CODE IN VARCHAR2 := NULL,
--bug 3301192
 p_financial_task_flag                IN VARCHAR2 := 'N',
--bug 3301192
 x_task_version_id  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Update_Task_version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_version_id    IN  NUMBER  N   Null
-- p_record_version_number  IN  NUMBER
--   p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Update_Task_Version(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ref_task_version_id  IN  NUMBER,
 p_peer_or_sub        IN    VARCHAR2,
 p_task_version_id  IN  NUMBER,
 p_attribute_category    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_record_version_number    IN  NUMBER,
 p_action          IN    VARCHAR2 := 'NULL',

 p_WEIGHTING_PERCENTAGE IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_TASK_UNPUB_VER_STATUS_CODE IN VARCHAR2 := NULL,

 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Delete_Task_version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_version_id    IN  NUMBER  N   Null
-- p_record_version_number  IN  NUMBER
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Delete_Task_Version(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id  IN  NUMBER,
 p_record_version_number    IN  NUMBER,
 p_called_from_api      IN    VARCHAR2    := 'ABCD',
 p_structure_type       IN    VARCHAR2    := 'WORKPLAN',   --bug 3301192
 p_calling_from      IN    VARCHAR2    := 'XYZ',  -- Bug 6023347
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Create_Schedule_Version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_element_version_id IN  NUMBER  N   Not Null
-- p_calendar_id    IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_calendar_name  IN  VARCHAR2    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_scheduled_start_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_scheduled_end_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_start_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_end_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_start_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_finish_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_start_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_finish_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_duration   IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_early_start_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_early_end_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_start_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_end_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_milestone_flag IN  VARCHAR2    N   NULL    N
-- p_critical_flag  IN  VARCHAR2    N   NULL    N
-- x_pev_schedule_id    OUT NUMBER  N   NULL
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--  16-OCT-02   XXLU                     - Added DFF parameters.
--

PROCEDURE Create_Schedule_Version(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_element_version_id   IN  NUMBER,
 p_calendar_id        IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_calendar_name          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_scheduled_start_date IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_end_date   IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_start_date IN DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_end_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_start_date    IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_finish_date   IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_start_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_finish_date IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_duration             IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_early_start_date IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_early_end_date         IN    DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_start_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_end_date          IN    DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_milestone_flag         IN    VARCHAR2    :='N',
 p_critical_flag          IN    VARCHAR2    :='N',

 p_WQ_PLANNED_QUANTITY  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EFFORT IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EQUIP_EFFORT       IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,   --bug 3305199

 --bug 3305199 schedule options
 p_def_sch_tool_tsk_type       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_def_sch_tool_tsk_type_code  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_type_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_date             IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_free_slack                  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_total_slack                 IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_effort_driven_flag          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_level_assignments_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --end bug 3305199
 p_ext_act_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_remain_duration         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_sch_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_attribute_category     IN    pa_proj_elem_ver_schedule.attribute_category%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1             IN    pa_proj_elem_ver_schedule.attribute1%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2             IN    pa_proj_elem_ver_schedule.attribute2%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3             IN    pa_proj_elem_ver_schedule.attribute3%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4             IN    pa_proj_elem_ver_schedule.attribute4%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5             IN    pa_proj_elem_ver_schedule.attribute5%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6             IN    pa_proj_elem_ver_schedule.attribute6%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7             IN    pa_proj_elem_ver_schedule.attribute7%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8             IN    pa_proj_elem_ver_schedule.attribute8%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9             IN    pa_proj_elem_ver_schedule.attribute9%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10            IN    pa_proj_elem_ver_schedule.attribute10%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11            IN    pa_proj_elem_ver_schedule.attribute11%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12            IN    pa_proj_elem_ver_schedule.attribute12%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13            IN    pa_proj_elem_ver_schedule.attribute13%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14            IN    pa_proj_elem_ver_schedule.attribute14%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15            IN    pa_proj_elem_ver_schedule.attribute15%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 x_pev_schedule_id  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name                      : Update_Schedule_Version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_element_version_id IN  NUMBER  N   Not Null
-- p_calendar_id    IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_calendar_name  IN  VARCHAR2    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_scheduled_start_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_scheduled_end_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_start_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_obligation_end_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_start_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_actual_finish_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_start_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_estimate_finish_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_duration   IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_early_start_date   IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_early_end_date IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_start_date    IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_late_end_date  IN  DATE    N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
-- p_milestone_flag IN  VARCHAR2    N   NULL    N
-- p_critical_flag  IN  VARCHAR2    N   NULL    N
-- x_pev_schedule_id    OUT NUMBER  N   NULL
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--  16-OCT-02   XXLU                     - Added DFF parameters.
--

PROCEDURE Update_Schedule_Version(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_pev_schedule_id  IN  NUMBER,
 p_calendar_id        IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_calendar_name          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_scheduled_start_date IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_scheduled_end_date   IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_start_date IN DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_obligation_end_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_start_date    IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_actual_finish_date   IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_start_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_estimate_finish_date IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_duration             IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_early_start_date IN  DATE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_early_end_date         IN    DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_start_date  IN  DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_late_end_date          IN    DATE          :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_milestone_flag         IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 2791410
 p_critical_flag          IN    VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Bug 2791410

 p_WQ_PLANNED_QUANTITY  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EFFORT IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_PLANNED_EQUIP_EFFORT       IN NUMBER :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,   --bug 3305199

 --bug 3305199 schedule options
 p_def_sch_tool_tsk_type       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_def_sch_tool_tsk_type_code  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_type_code        IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_constraint_date             IN DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_free_slack                  IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_total_slack                 IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_effort_driven_flag          IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_level_assignments_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 --end bug 3305199

 p_record_version_number IN   NUMBER,
 p_ext_act_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_remain_duration         IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_ext_sch_duration            IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Bug no 3450684
 p_attribute_category     IN    pa_proj_elem_ver_schedule.attribute_category%TYPE :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute1             IN    pa_proj_elem_ver_schedule.attribute1%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute2             IN    pa_proj_elem_ver_schedule.attribute2%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute3             IN    pa_proj_elem_ver_schedule.attribute3%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute4             IN    pa_proj_elem_ver_schedule.attribute4%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute5             IN    pa_proj_elem_ver_schedule.attribute5%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute6             IN    pa_proj_elem_ver_schedule.attribute6%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute7             IN    pa_proj_elem_ver_schedule.attribute7%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute8             IN    pa_proj_elem_ver_schedule.attribute8%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute9             IN    pa_proj_elem_ver_schedule.attribute9%TYPE        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute10            IN    pa_proj_elem_ver_schedule.attribute10%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute11            IN    pa_proj_elem_ver_schedule.attribute11%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute12            IN    pa_proj_elem_ver_schedule.attribute12%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute13            IN    pa_proj_elem_ver_schedule.attribute13%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute14            IN    pa_proj_elem_ver_schedule.attribute14%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_attribute15            IN    pa_proj_elem_ver_schedule.attribute15%TYPE       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Copy_Task
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_project_id IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_project_name   IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_src_structure_id   IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_structure_name IN  VARCHAR2    N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_src_structure_version_id   IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_structure_version_name IN  VARCHAR2    N   null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_src_task_version_id    IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_task_name  IN  VARCHAR2    N   null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_dest_structure_id  IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_dest_structure_version_id  IN  NUMBER  N   NOT Null
-- p_dest_task_version_id   IN  NUMBER  N   Null    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_dest_project_id    IN      NUMBER  N       Null   PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_task_unpub_ver_status_code IN VARCHAR2     N       Null     PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--p_fin_task_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- p_sharing_enabled      IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- p_versioning_enabled   IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- p_copy_external_flag   IN  VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
-- p_copy_option    IN  VARCHAR2    N   NOT NULL
-- p_peer_or_sub    IN  VARCHAR2    N   Not Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Majid Ansari             -Created
--
--

PROCEDURE Copy_Task(
 p_api_version        IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit               IN  VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level IN  NUMBER  :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode         IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_project_id         IN    NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_project_name IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_structure_id IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_structure_name   IN  VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_structure_version_id IN NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_structure_version_name   IN  VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_task_version_id  IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_task_name          IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_dest_structure_id          IN        NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_dest_structure_version_id    IN  NUMBER,
 p_dest_task_version_id IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_dest_project_id        IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,  -- 4201927
 p_task_unpub_ver_status_code IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_fin_task_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_sharing_enabled      IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_versioning_enabled   IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_copy_external_flag   IN  VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_called_from_api      IN    VARCHAR2    := 'ABCD',
 p_copy_option        IN    VARCHAR2,
 p_peer_or_sub        IN    VARCHAR2,
 p_prefix               IN    VARCHAR2,
-- Added for FP_M changes. Refer to tracking Bug 3305199
p_structure_type              IN              VARCHAR2        :='WORKPLAN',
p_cp_dependency_flag          IN              VARCHAR2        :='N',
p_cp_deliverable_asso_flag    IN              VARCHAR2        :='N',
p_cp_tk_assignments_flag      IN              VARCHAR2        :='N',
p_cp_people_flag              IN              VARCHAR2        :='N',
p_cp_financial_elem_flag      IN              VARCHAR2        :='N',
p_cp_material_items_flag      IN              VARCHAR2        :='N',
p_cp_equipment_flag           IN              VARCHAR2        :='N',
-- End of FP_M changes
 p_called_from_bulk_api       IN        VARCHAR2        :='N',
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count          OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : Move_Task
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
-- p_task_version_id    IN  NUMBER  N   Not Null
-- p_ref_task_version_id    IN  NUMBER  N   Not Null
-- p_peer_or_sub    IN  VARCHAR2    N   Not Null
-- prefix   IN  VARCHAR2    N   Not Null
-- p_called_from_bulk_api  IN VARCHAR2 N Null 'N'
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  13-NOV-01   Andrew Lee             -Created
--
--

PROCEDURE MOVE_TASK_VERSION (
 p_api_version           IN NUMBER   := 1.0,
 p_init_msg_list     IN VARCHAR2 := FND_API.G_TRUE,
 p_commit            IN VARCHAR2 := FND_API.G_FALSE,
 p_validate_only     IN VARCHAR2 := FND_API.G_TRUE,
 p_validation_level  IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 p_calling_module    IN VARCHAR2 := 'SELF_SERVICE',
 p_debug_mode            IN VARCHAR2 := 'N',
 p_max_msg_count     IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id   IN NUMBER,
 p_ref_task_version_id   IN NUMBER,
/*4269830 : Performance Enhancements :  Start*/
 p_ref_project_id          IN   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_id            IN   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_published_version       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_shared                  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_sharing_code            IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_versioned               IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_wp_type                 IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_fin_type                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_weighting_basis_code    IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_check_third_party_flag  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
/*4269830 : Performance Enhancements : End */
 p_peer_or_sub           IN VARCHAR2,
 p_record_version_number IN     NUMBER,
 p_called_from_bulk_api  IN     VARCHAR2 := 'N',
 x_return_status    OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count            OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;
-- API name                      : Indent_Task_Version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
-- p_task_version_id    IN  NUMBER  N   Not Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Andrew Lee             -Created
--
--

PROCEDURE INDENT_TASK_VERSION (
 p_api_version            IN    NUMBER   :=1.0,
 p_init_msg_list          IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit             IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level       IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode             IN    VARCHAR2 :='N',
 p_max_msg_count          IN    NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id        IN    NUMBER,
 p_record_version_number  IN    NUMBER,
 x_return_status         OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count             OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data          OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

-- API name                      : Outdent_Task_Version
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version          IN    NUMBER  N   Not Null    1.0
-- p_init_msg_list  IN  VARCHAR2    N   Not Null    FND_API.TRUE
-- p_commit             IN  VARCHAR2    N   Not Null    FND_API.G_FALSE
-- p_validate_only  IN  VARCHAR2    N   Not Null    FND_API.G_TRUE
-- p_validation_level   IN  NUMBER  N   Null    FND_API.G_VALID_LEVEL_FULL
-- p_calling_module IN  VARCHAR2    N   Null    SELF_SERVICE
-- p_debug_mode       IN    VARCHAR2    N   Null    N
-- p_max_msg_count  IN  NUMBER  N   NULL    PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
-- p_task_version_id    IN  NUMBER  N   Not Null
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  13-OCT-01   Andrew Lee             -Created
--
--

PROCEDURE OUTDENT_TASK_VERSION (
 p_api_version            IN    NUMBER   :=1.0,
 p_init_msg_list          IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit             IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level       IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode             IN    VARCHAR2 :='N',
 p_max_msg_count          IN    NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id IN NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id        IN    NUMBER,
 p_record_version_number  IN    NUMBER,
 x_return_status         OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count             OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data          OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- API name                      : Create_tasks
-- Type                          : Wrapper Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id            IN NUMBER
-- p_ref_task_version_id   IN NUMBER
-- p_structure_id          IN NUMBER
-- p_structure_version_id  IN NUMBER
-- p_outline_level         IN PA_NUM_1000_NUM
-- p_task_number           IN PA_VC_1000_150
-- p_task_name             IN PA_VC_1000_2000
-- p_scheduled_start_date  IN PA_DATE_1000_DATE
-- p_scheduled_finish_date IN PA_DATE_1000_DATE
-- p_task_manager_id       IN PA_NUM_1000_NUM
-- p_task_manager_name     IN PA_VC_1000_150
  --FP M Development Changes
-- p_planned_effort              IN              PA_NUM_1000_NUM
-- p_dependencies                IN              PA_VC_1000_4000
-- p_dependency_ids              IN              PA_NUM_1000_NUM
-- p_structure_type              IN              VARCHAR2        :='WORKPLAN'
-- p_financial_flag              IN              VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- p_resources                   IN              PA_VC_1000_4000
-- p_resource_ids                IN              PA_NUM_1000_NUM
-- p_mapped_task                 IN              PA_VC_1000_4000
-- p_mapped_task_id              IN              PA_NUM_1000_NUM
  --End FP M Development Changes
-- x_msg_count             OUT NUMBER
-- x_msg_data              OUT VARCHAR2
-- x_return_status         OUT VARCHAR2
-- x_return_status  OUT     VARCHAR2    N   Null
-- x_msg_count        OUT   NUMBER  N   Null
-- x_msg_data         OUT   VARCHAR2    N   Null
--
--  History
--
--  23-OCT-01   Andrew Lee             -Created
--
--

PROCEDURE CREATE_TASKS
( p_project_id            IN NUMBER
 ,p_ref_task_version_id   IN NUMBER
 ,p_structure_id          IN NUMBER
 ,p_structure_version_id  IN NUMBER
 ,p_outline_level         IN PA_NUM_1000_NUM
 ,p_task_number           IN PA_VC_1000_150
 ,p_task_name             IN PA_VC_1000_2000
 ,p_scheduled_start_date  IN PA_DATE_1000_DATE
 ,p_scheduled_finish_date IN PA_DATE_1000_DATE
 ,p_task_manager_id       IN PA_NUM_1000_NUM
 ,p_task_manager_name     IN PA_VC_1000_150
 ,p_TYPE_ID               IN PA_NUM_1000_NUM
  --FP M Development Changes bug 330119
 ,p_planned_effort      IN      PA_NUM_1000_NUM
 ,p_planned_equip_effort        IN              PA_NUM_1000_NUM
 ,p_dependencies            IN      PA_VC_1000_4000
 ,p_dependency_ids      IN      PA_NUM_1000_NUM
 ,p_structure_type      IN      VARCHAR2        :='WORKPLAN'
 ,p_financial_flag      IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_use_in_fin_plan     IN      PA_VC_1000_10
 ,p_resources               IN      PA_VC_1000_4000
 ,p_resource_ids            IN      PA_NUM_1000_NUM
 ,p_mapped_task             IN      PA_VC_1000_4000
 ,p_mapped_task_id      IN      PA_NUM_1000_NUM
  --End FP M Development Changes bug 330119
 ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status         OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- anlee task weighting
-- API name                  : Calc_Task_Weights
-- Type                      : Utility
-- Pre-reqs                  : None
-- Return Value              : N/A
-- Prameters
-- p_commit                IN  VARCHAR2 := FND_API.G_FALSE
-- p_element_versions      IN  PA_NUM_1000_NUM
-- p_outline_level         IN  PA_NUM_1000_NUM
-- p_top_peer_count        IN  NUMBER
-- p_top_sub_count         IN  NUMBER
-- x_msg_count             OUT NUMBER
-- x_msg_data              OUT VARCHAR2
-- x_return_status         OUT VARCHAR2
--
--  History
--
--  17-SEP-02   Andrew Lee             -Created
--
--

PROCEDURE CALC_TASK_WEIGHTS
( p_element_versions      IN PA_NUM_1000_NUM
 ,p_outline_level         IN PA_NUM_1000_NUM
 ,p_top_sub_count         IN NUMBER
 ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status         OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--   API name                      : Update_Task_Weighting
--   Type                          : Public Procedure
--   Pre-reqs                      : None
--   Return Value                  : N/A
--   Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_object_relationship_id            IN  NUMBER
--   p_weighting_percentage              IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  20-SEP-02   hyau             -Created
--
--
  procedure Update_Task_Weighting
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_object_relationship_id            IN  NUMBER
   ,p_weighting_percentage              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- Amit : Following procedure added for Bug 2838700

 PROCEDURE INDENT_TASK_VERSION_BULK (
 p_api_version                IN    NUMBER   :=1.0,
 p_init_msg_list              IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit             IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only              IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level       IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode             IN    VARCHAR2 :='N',
 p_max_msg_count          IN    NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id       IN    NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id        IN    NUMBER,
 p_project_id             IN    NUMBER,
 p_record_version_number      IN    NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Amit : Following procedure added for Bug 2838700

 PROCEDURE OUTDENT_TASK_VERSION_BULK (
 p_api_version                IN    NUMBER   :=1.0,
 p_init_msg_list              IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit             IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only              IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level       IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode             IN    VARCHAR2 :='N',
 p_max_msg_count          IN    NUMBER   :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id       IN    NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_version_id        IN    NUMBER,
 p_project_id             IN    NUMBER,
 p_record_version_number      IN    NUMBER,
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE DELETE_TASK_VERSION_IN_BULK
(p_task_version_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE
,p_record_version_number_tbl   IN  SYSTEM.PA_NUM_TBL_TYPE
,p_structure_version_id        IN  NUMBER
,p_structure_type              IN  VARCHAR2 := 'WORKPLAN'  -- 3305199
,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

--margaret bug 3024607 add update task association
 PROCEDURE Update_Task_Association (
 p_api_version                    IN    NUMBER   :=1.0,
 p_init_msg_list                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit                         IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level               IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module                 IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode                     IN    VARCHAR2 :='N',
 p_max_msg_count                  IN    NUMBER   :=NULL,
 p_associated_project_id          IN    NUMBER  := NULL,
 p_associated_task_id             IN    NUMBER  := NULL,
 p_associated_project_name        IN    VARCHAR2 :=NULL,
 p_associated_task_name           IN    VARCHAR2 :=NULL,
 p_task_id                        IN    NUMBER ,
 p_relationship_type              IN    VARCHAR2 :='A',
 p_relationship_id                IN    NUMBER  := NULL,
 p_record_version_number          IN    NUMBER  := NULL,
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_relationship_id                OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
);



--margaret bug 3024607 delete task association
 PROCEDURE Delete_Task_Associations(
 p_api_version                    IN    NUMBER   :=1.0,
 p_init_msg_list                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit                         IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level               IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module                 IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode                     IN    VARCHAR2 :='N',
 p_max_msg_count                  IN    NUMBER   :=NULL,
 p_relationship_type              IN    VARCHAR2 :='A',
 p_relationship_id                IN    NUMBER  := NULL,
 p_task_id                        IN    NUMBER  := NULL,
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--Delete a single association - relationship_id required
--Only the association specified by relationship_id is deleted if it exists
 PROCEDURE Delete_Association(
 p_relationship_id                IN    NUMBER
 ,p_record_version_number         IN    NUMBER  :=NULL
 ,x_return_status                 OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


--margaret check if task has associations, returns Y/N
 FUNCTION has_Associations(
 p_task_id             IN    NUMBER
 ,p_relationship_type  VARCHAR2 :='A'
)return VARCHAR2;

--margaret check if project is associated to tasks, returns Y/N
FUNCTION proj_has_task_associations(
 p_project_id                 IN    NUMBER
 ,p_relationship_type         IN    VARCHAR2 :='A'
)return VARCHAR2;


 PROCEDURE Check_Task_Has_Association(
 p_task_id                  IN    NUMBER
 ,p_relationship_type  VARCHAR2 :='A'
 ,x_return_status            OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                 OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

);

--Check if project is associated tosks

PROCEDURE Check_Proj_Associated_To_Tasks(
  p_project_id               IN    NUMBER
 ,p_relationship_type        VARCHAR2 :='A'
 ,x_return_status            OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                 OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

);
PROCEDURE Delete_Proj_To_Task_Assoc(
 p_api_version                    IN    NUMBER   :=1.0,
 p_init_msg_list                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit                         IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_validation_level               IN    NUMBER   :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module                 IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode                     IN    VARCHAR2 :='N',
 p_max_msg_count                  IN    NUMBER   :=NULL,
 p_relationship_type              IN    VARCHAR2 :='A',
 p_relationship_id                IN    NUMBER  := NULL,
 p_project_id                     IN    NUMBER  := NULL,
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

);

--This procedure copies associations for tasks from p_project_id_from tasks
-- to p_project_id_to tasks
PROCEDURE Copy_Task_Associations(
 p_api_version                    IN    NUMBER   :=1.0,
 p_init_msg_list                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit                         IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_calling_module                 IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode                     IN    VARCHAR2 :='N',
 p_max_msg_count                  IN    NUMBER   := NULL,
 p_project_id_to                  IN    NUMBER   := NULL,
 p_project_id_from                IN    NUMBER   := NULL,
 p_relationship_type              IN    VARCHAR2 :='A',
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


--FPM  bug 3301192
--Planning and budget changes.
--This apis is called from CREATE_TASKS api and AMG create_project, update_prohject and add_task apis

PROCEDURE call_add_planning_txns(
 p_tasks_ver_ids                  IN    PA_NUM_1000_NUM,
 p_planned_effort                 IN    PA_NUM_1000_NUM,
 p_project_id                     IN    NUMBER,
 p_structure_version_id           IN    NUMBER,
 p_start_date                     IN    PA_DATE_1000_DATE,
 p_end_date                       IN    PA_DATE_1000_DATE,
 p_pm_product_code                IN    VARCHAR2  DEFAULT NULL, ---bug 3811243
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);



PROCEDURE update_task_det_sch_info(
 p_api_version                    IN    NUMBER   :=1.0,
 p_init_msg_list                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_commit                         IN    VARCHAR2 :=FND_API.G_FALSE,
 p_validate_only                  IN    VARCHAR2 :=FND_API.G_TRUE,
 p_calling_module                 IN    VARCHAR2 :='SELF_SERVICE',
 p_debug_mode                     IN    VARCHAR2 :='N',
 p_task_ver_id                    IN    NUMBER,
 p_project_id                     IN    NUMBER,
 p_planned_effort                 IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_ETC_effort                     IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_structure_version_id           IN    NUMBER,
 p_object_type            IN    VARCHAR2 := 'PA_TASKS',
 p_etc_cost           IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_actual_effort          IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_percent_complete       IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_res_assign_id                  IN    NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 x_return_status                  OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                      OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--FP M Bug 4201927
PROCEDURE Copy_Tasks_In_Bulk
(
 p_api_version            IN    NUMBER  :=1.0,
 p_init_msg_list          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_commit                 IN    VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only          IN    VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level   IN    NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module         IN    VARCHAR2    :='SELF_SERVICE',
 p_debug_mode             IN    VARCHAR2    :='N',
 p_max_msg_count          IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_project_id         IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_project_name       IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_structure_id       IN    NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_structure_name     IN    VARCHAR2    :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_structure_version_id IN NUMBER       :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_src_structure_version_name   IN VARCHAR2 :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_src_task_version_id_tbl  IN  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_src_task_name          IN    VARCHAR2     :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_dest_structure_version_id    IN  NUMBER,
 p_dest_task_version_id IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_dest_project_id      IN  NUMBER  :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_called_from_api      IN    VARCHAR2    := 'ABCD',
 p_copy_option        IN    VARCHAR2,
 p_peer_or_sub        IN    VARCHAR2,
 p_prefix             IN    VARCHAR2,
 p_structure_type              IN              VARCHAR2        :='WORKPLAN',
 p_cp_dependency_flag          IN              VARCHAR2        :='N',
 p_cp_deliverable_asso_flag    IN              VARCHAR2        :='N',
 p_cp_tk_assignments_flag      IN              VARCHAR2        :='N',
 p_cp_people_flag              IN              VARCHAR2        :='N',
 p_cp_financial_elem_flag      IN              VARCHAR2        :='N',
 p_cp_material_items_flag      IN              VARCHAR2        :='N',
 p_cp_equipment_flag           IN              VARCHAR2        :='N',
 x_return_status          OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE MOVE_TASK_VERSIONS_IN_BULK
   (
     p_api_version           IN     NUMBER   := 1.0,
     p_init_msg_list         IN     VARCHAR2 := FND_API.G_TRUE,
     p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
     p_validate_only         IN     VARCHAR2 := FND_API.G_TRUE,
     p_validation_level      IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     p_calling_module        IN     VARCHAR2 := 'SELF_SERVICE',
     p_debug_mode            IN     VARCHAR2 := 'N',
     p_max_msg_count         IN     NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
     p_structure_version_id  IN     NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
     p_task_version_id_tbl   IN     SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
     p_ref_task_version_id   IN     NUMBER,
     p_ref_project_id        IN     NUMBER, /*4269830*/
     p_peer_or_sub           IN     VARCHAR2,
     p_record_version_number_tbl     IN SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
     x_return_status                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

-- 4218932 Added below update api for update task page for  bulk approach

PROCEDURE Update_Task_All_Info(
 p_api_version                      IN      NUMBER      :=1.0,
 p_init_msg_list                    IN      VARCHAR2    :=FND_API.G_TRUE,
 p_commit                           IN      VARCHAR2    :=FND_API.G_FALSE,
 p_validate_only                    IN      VARCHAR2    :=FND_API.G_TRUE,
 p_validation_level                 IN      NUMBER      :=FND_API.G_VALID_LEVEL_FULL,
 p_calling_module                   IN      VARCHAR2    :='SELF_SERVICE',
 p_debug_mode                       IN      VARCHAR2    :='N',
 p_max_msg_count                    IN      NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_task_id_tbl                      IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 --Begin:5867373:p_task_number_tbl's data-type has been changed to varchar2(100)
 p_task_number_tbl                  IN      SYSTEM.PA_VARCHAR2_100_TBL_TYPE  := SYSTEM.PA_VARCHAR2_100_TBL_TYPE(),
 --End:5867373:
 p_task_name_tbl                    IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE(),
 p_task_description_tbl             IN      SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE(),
 p_task_manager_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_task_manager_name_tbl            IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE(),
 p_carrying_out_org_id_tbl          IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_carrying_out_org_name_tbl        IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE(),
 p_priority_code_tbl                IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
 p_TYPE_ID_tbl                      IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_status_code_tbl                  IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE(),
 p_inc_proj_progress_flag_tbl       IN      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE(),
 p_transaction_start_date_tbl       IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_transaction_finish_date_tbl      IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_work_type_id_tbl                 IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_service_type_code_tbl            IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
 p_work_item_code_tbl               IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
 p_uom_code_tbl                     IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
 p_record_version_number_tbl        IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 -- Update_Schedule_Version
 p_scheduled_start_date_tbl         IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_scheduled_end_date_tbl           IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_pev_schedule_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_milestone_flag_tbl               IN      SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE(),
 p_critical_flag_tbl                IN      SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM. PA_VARCHAR2_1_TBL_TYPE(),
 p_WQ_PLANNED_QUANTITY_tbl          IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_early_start_date_tbl             IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_early_end_date_tbl               IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_late_start_date_tbl              IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_late_end_date_tbl                IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_constraint_type_code_tbl         IN      SYSTEM.PA_VARCHAR2_30_TBL_TYPE  := SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
 p_constraint_date_tbl              IN      SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(),
 p_sch_rec_ver_num_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 -- update_task_det_sch_info
 p_task_version_id_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_percent_complete_tbl             IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_ETC_effort_tbl                   IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_structure_version_id_tbl         IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_project_id_tbl                   IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_planned_effort_tbl               IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_actual_effort_tbl                IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 -- Update_Task_Weighting
 p_object_relationship_id_tbl       IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_weighting_percentage_tbl         IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_obj_rec_ver_num_tbl              IN      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(),
 p_task_weight_method               IN      VARCHAR2,
 -- common
 x_return_status                    OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                        OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- 4429929 : Added  CANCEL_TASK
PROCEDURE CANCEL_TASK(
  p_calling_module		IN      VARCHAR2        :='SELF_SERVICE'
 ,p_api_version                 IN      NUMBER          :=1.0
 ,p_init_msg_list               IN      VARCHAR2        :=FND_API.G_TRUE
 ,p_validate_only               IN      VARCHAR2        :=FND_API.G_FALSE
 ,p_validation_level            IN      NUMBER          :=FND_API.G_VALID_LEVEL_FULL
 ,p_calling_mode		IN      VARCHAR2        :=null
 ,p_task_id			IN	NUMBER
 ,p_task_version_id		IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_cancel_status_code		IN	VARCHAR2
 ,x_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Bug Fix 5593736.

PROCEDURE INDENT_MULTI_TASK_VERSION
(p_api_version	          	IN   	NUMBER   	:= 1.0
,p_init_msg_list       	  	IN    	VARCHAR2 	:= FND_API.G_TRUE
,p_commit                 	IN    	VARCHAR2 	:= FND_API.G_FALSE
,p_validate_only       	  	IN    	VARCHAR2 	:= FND_API.G_TRUE
,p_validation_level   	  	IN    	NUMBER   	:= FND_API.G_VALID_LEVEL_FULL
,p_calling_module    	  	IN    	VARCHAR2 	:= 'SELF_SERVICE'
,p_debug_mode        	  	IN    	VARCHAR2 	:= 'N'
,p_max_msg_count   	  	IN   	NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_project_id             	IN    	NUMBER
,p_structure_version_id   	IN  	NUMBER
,p_structure_type         	IN  	VARCHAR2        :='WORKPLAN'
,p_task_version_id_tbl    	IN  	SYSTEM.PA_NUM_TBL_TYPE
,p_record_version_number_tbl    IN  	SYSTEM.PA_NUM_TBL_TYPE
,p_display_sequence_tbl   	IN  	SYSTEM.PA_NUM_TBL_TYPE
,x_return_status          	OUT 	NOCOPY VARCHAR2
,x_msg_count              	OUT 	NOCOPY NUMBER
,x_msg_data               	OUT 	NOCOPY VARCHAR2);

PROCEDURE OUTDENT_MULTI_TASK_VERSION
(p_api_version	          	IN   	NUMBER   	:= 1.0
,p_init_msg_list       	  	IN    	VARCHAR2 	:= FND_API.G_TRUE
,p_commit                 	IN    	VARCHAR2 	:= FND_API.G_FALSE
,p_validate_only       	  	IN    	VARCHAR2 	:= FND_API.G_TRUE
,p_validation_level   	  	IN    	NUMBER   	:= FND_API.G_VALID_LEVEL_FULL
,p_calling_module    	  	IN    	VARCHAR2 	:= 'SELF_SERVICE'
,p_debug_mode        	  	IN    	VARCHAR2 	:= 'N'
,p_max_msg_count   	  	IN   	NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_project_id             	IN    	NUMBER
,p_structure_version_id   	IN  	NUMBER
,p_structure_type         	IN  	VARCHAR2        :='WORKPLAN'
,p_task_version_id_tbl    	IN  	SYSTEM.PA_NUM_TBL_TYPE
,p_record_version_number_tbl    IN  	SYSTEM.PA_NUM_TBL_TYPE
,p_display_sequence_tbl   	IN  	SYSTEM.PA_NUM_TBL_TYPE
,x_return_status          	OUT 	NOCOPY VARCHAR2
,x_msg_count              	OUT 	NOCOPY NUMBER
,x_msg_data               	OUT 	NOCOPY VARCHAR2);

-- Bug 8566495 E&C enhancement
PROCEDURE APPROVE_TASKS_IN_BULK
(p_task_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE
,p_parent_task_id_tbl  IN SYSTEM.PA_NUM_TBL_TYPE
,p_task_name_tbl IN SYSTEM.PA_VARCHAR2_100_TBL_TYPE
,p_task_number_tbl IN   SYSTEM.PA_VARCHAR2_100_TBL_TYPE
,p_project_id        IN  NUMBER
,x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);
-- End of Bug Fix 5593736.

END PA_TASK_PUB1;

/
