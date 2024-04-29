--------------------------------------------------------
--  DDL for Package PA_TASKS_MAINT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASKS_MAINT_UTILS" AUTHID CURRENT_USER as
/*$Header: PATSKSUS.pls 120.1 2005/08/19 17:05:34 mwasowic noship $*/



  procedure CHECK_TASK_MGR_NAME_OR_ID
  (
     p_task_mgr_name             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_mgr_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_project_id                IN  NUMBER      := NULL
    ,p_check_id_flag             IN  VARCHAR2    := 'A'
    ,p_calling_module            IN  VARCHAR2    := 'SELF_SERVICE'
    ,x_task_mgr_id               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


  procedure CHECK_TASK_NAME_OR_ID
  (
     p_project_id                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_task_name                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_id                   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_check_id_flag             IN  VARCHAR2    := 'A'
    ,x_task_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure CHECK_PROJECT_NAME_OR_ID
  (
     p_project_name              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_project_id                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_check_id_flag             IN  VARCHAR2    := 'A'
    ,x_project_id                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


  function Get_Sequence_Number(p_peer_or_sub IN VARCHAR2,
                               p_project_id  IN NUMBER,
                               p_task_id     IN NUMBER)
  return NUMBER;

  FUNCTION default_address_id(p_proj_id IN NUMBER)
  RETURN NUMBER;

  PROCEDURE CHECK_TASK_NUMBER_DISP(p_project_id IN NUMBER,
                                   p_task_id IN NUMBER,
                                   p_task_number IN VARCHAR2,
                                   p_rowid IN VARCHAR2);

  procedure Check_Start_Date(p_project_id      IN NUMBER,
                             p_parent_task_id  IN NUMBER,
                             p_task_id         IN NUMBER,
                             p_start_date      IN DATE,
                             x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  procedure Check_End_Date(  p_project_id      IN NUMBER,
                             p_parent_task_id  IN NUMBER,
                             p_task_id         IN NUMBER,
                             p_end_date        IN DATE,
                             x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


  procedure Check_Chargeable_Flag( p_chargeable_flag IN VARCHAR2,
                             p_receive_project_invoice_flag IN VARCHAR2,
                             p_project_type    IN VARCHAR2,
			     p_project_id      IN number,  -- Added for bug#3512486
                             x_receive_project_invoice_flag OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


  PROCEDURE CHECK_SCHEDULE_DATES(p_project_id IN NUMBER,
                                 p_sch_start_date IN DATE,
                                 p_sch_end_date IN DATE,
                                 x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


  PROCEDURE CHECK_ESTIMATE_DATES(p_project_id IN NUMBER,
                                 p_estimate_start_date IN DATE,
                                 p_estimate_end_date IN DATE,
                                 x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE CHECK_ACTUAL_DATES(p_project_id IN NUMBER,
                               p_actual_start_date IN DATE,
                               p_actual_end_date IN DATE,
                               x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               x_msg_data OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


  PROCEDURE SET_ORG_ID(p_project_id IN NUMBER);

  FUNCTION rearrange_display_seq (p_display_seq     IN     NUMBER,
                                  p_above_seq       IN     NUMBER,
                                  p_number_tasks    IN     NUMBER,
                                  p_mode            IN     VARCHAR2,
                                  p_operation       IN     VARCHAR2) RETURN  NUMBER;


-- API name                      : DEFAULT_TASK_ATTRIBUTES
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_reference_task_id          IN  NUMBER    REQUIRED
-- p_task_type                  IN  VARCHAR2  REQUIRED
-- x_carrying_out_org_id        OUT NUMBER    REQUIRED
-- x_carrying_out_org_name      OUT VARCHAR2  REQUIRED
-- x_work_type_id               OUT NUMBER    REQUIRED
-- x_work_type_name             OUT VARCHAR2  REQUIRED
-- x_service_type_code          OUT VARCHAR2    REQUIRED
-- x_service_type_name          OUT VARCHAR2  REQUIRED
-- x_return_status         OUT VARCHAR2  REQUIRED
-- x_error_msg_code        OUT VARCHAR2  REQUIRED
--
--  History
--
--  14-JUN-01   Majid Ansari             -Created
--
--

    PROCEDURE DEFAULT_TASK_ATTRIBUTES(
       p_reference_task_id          IN  NUMBER,
       p_task_type                  IN  VARCHAR2,
       x_carrying_out_org_id        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_carrying_out_org_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_work_type_id               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_work_type_name             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_code          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_name          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_error_msg_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );


-- API name                      : FETCH_TASK_ATTIBUTES
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_task_id                    IN  NUMBER    REQUIRED
-- x_carrying_out_org_id        OUT NUMBER    REQUIRED
-- x_carrying_out_org_name      OUT VARCHAR2  REQUIRED
-- x_work_type_id               OUT NUMBER    REQUIRED
-- x_work_type_name             OUT VARCHAR2  REQUIRED
-- x_service_type_code          OUT VARCHAR2    REQUIRED
-- x_service_type_name          OUT VARCHAR2  REQUIRED
-- x_return_status         OUT VARCHAR2  REQUIRED
-- x_error_msg_code        OUT VARCHAR2  REQUIRED
--
--  History
--
--  14-JUN-01   Majid Ansari             -Created
--
--

   PROCEDURE FETCH_TASK_ATTIBUTES(
       p_task_id                 IN NUMBER,
       x_carrying_out_org_id        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_carrying_out_org_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_work_type_id               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_work_type_name             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_code          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_name          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_error_msg_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );

-- API name                      : FETCH_PROJECT_ATTIBUTES
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                 IN  NUMBER    REQUIRED
-- x_carrying_out_org_id        OUT NUMBER    REQUIRED
-- x_carrying_out_org_name      OUT VARCHAR2  REQUIRED
-- x_work_type_id               OUT NUMBER    REQUIRED
-- x_work_type_name             OUT VARCHAR2  REQUIRED
-- x_service_type_code          OUT VARCHAR2    REQUIRED
-- x_service_type_name          OUT VARCHAR2  REQUIRED
-- x_return_status         OUT VARCHAR2  REQUIRED
-- x_error_msg_code        OUT VARCHAR2  REQUIRED
--
--  History
--
--  14-JUN-01   Majid Ansari             -Created
--
--

   PROCEDURE FETCH_PROJECT_ATTIBUTES(
       p_project_id                 IN NUMBER,
       x_carrying_out_org_id        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_carrying_out_org_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_work_type_id               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_work_type_name             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_code          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_name          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_error_msg_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );

   function IsSummaryTask(p_project_id IN NUMBER,
                       p_task_id    IN NUMBER)
   return varchar2;


-- API name                      : GetWbsLevel
-- Type                          : Utility Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                 IN  NUMBER    REQUIRED
-- p_task_id                    IN  NUMBER    REQUIRED
-- x_task_level                 OUT NUMBER    REQUIRED
-- x_task_level_above           OUT NUMBER    REQUIRED
-- x_task_id_above              OUT NUMBER    REQ
-- x_return_status         OUT VARCHAR2  REQUIRED
-- x_error_msg_code        OUT VARCHAR2  REQUIRED
--
--  History
--
--  25-JUN-01   Majid Ansari             -Created
--
--

   PROCEDURE GetWbsLevel(
       p_project_id                 IN NUMBER,
       p_task_id                    IN NUMBER,

       x_task_level                 OUT NOCOPY NUMBER,     --File.Sql.39 bug 4440895
       x_parent_task_id             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_top_task_id                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_display_sequence           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895

       x_task_level_above           OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
       x_parent_task_id_above       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_top_task_id_above          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_display_sequence_above     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895

       x_task_id_above              OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
       x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_error_msg_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );

-- API name                      : REF_PRJ_TASK_ID_REQ_CHECK
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_reference_project_id      IN    NUMBER     REQUIRED
-- p_reference_task_id         IN    NUMBER     REQUIRED
-- x_return_status         OUT      VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  REF_PRJ_TASK_ID_REQ_CHECK(
 p_reference_project_id      IN    NUMBER   ,
 p_reference_task_id         IN    NUMBER    ,
 x_return_status               OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);


-- API name                      : SRC_PRJ_TASK_ID_REQ_CHECK
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id      IN    NUMBER     REQUIRED
-- p_task_id         IN    NUMBER     REQUIRED
-- x_return_status         OUT      VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  SRC_PRJ_TASK_ID_REQ_CHECK(
 p_project_id      IN    NUMBER   ,
 p_task_id         IN    NUMBER    ,
 x_return_status               OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
) ;


PROCEDURE check_start_end_date
( p_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_context                 IN  VARCHAR2 := 'START'
 ,p_old_start_date          IN  DATE
 ,p_new_start_date          IN  DATE
 ,p_old_end_date            IN  DATE
 ,p_new_end_date            IN  DATE
 ,p_update_start_date_flag  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_update_end_date_flag    OUT NOCOPY VARCHAR2          ); --File.Sql.39 bug 4440895

-- API name                      : LOCK_PROJECT
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_validate_only             IN  VARCHAR2    := FND_API.G_TRUE
-- p_project_id                IN    NUMBER     REQUIRED
-- p_wbs_record_version_number IN    NUMBER     REQUIRED
-- x_return_status         OUT      VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  LOCK_PROJECT(
 p_validate_only             IN  VARCHAR2 := FND_API.G_TRUE,
 p_calling_module            IN  VARCHAR2 := 'SELF_SERVICE',
 p_project_id                IN  NUMBER,
 p_wbs_record_version_number IN  NUMBER,
 x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_data                  OUT NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
);

-- API name                      : INCREMENT_WBS_REC_VER_NUM
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                IN    NUMBER     REQUIRED
-- p_wbs_record_version_number IN NUMBER
-- x_return_status         OUT      VARCHAR2   REQUIRED
--
--  History
--
--  16-JUL-01   Majid Ansari             -Created
--
--

PROCEDURE INCREMENT_WBS_REC_VER_NUM(
 p_project_id                 IN NUMBER,
 p_wbs_record_version_number  IN NUMBER,
 x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- API name                      : GET_TASK_MANAGER_PROFILE
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : Y or N
-- Parameters                    : N/A
--
--  History
--
--  21-NOV-02   hubert siu            -Created
--
--
FUNCTION GET_TASK_MANAGER_PROFILE RETURN VARCHAR2;

-- Begin add by rtarway FP.M Development
-- TYPE  TASK_VERSION_ID_TABLE_TYPE IS TABLE OF pa_proj_element_versions.element_version_id%TYPE INDEX BY BINARY_INTEGER;

PROCEDURE CHECK_WORKPLAN_TASK_EXISTS
    (
       p_api_version         IN   NUMBER   :=  1.0
     , p_calling_module      IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode          IN   NUMBER   := 'N'
     , p_task_version_id     IN   NUMBER
     , x_return_status       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count           OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data            OUT  NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
     , x_error_msg_code      OUT  NOCOPY VARCHAR2          --File.Sql.39 bug 4440895
   );

PROCEDURE CHECK_MOVE_FINANCIAL_TASK_OK

   (   p_api_version            IN   NUMBER   := 1.0
     , p_calling_module         IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode             IN   VARCHAR2 := 'N'
     , p_task_version_id        IN   NUMBER
     , p_ref_task_version_id    IN   NUMBER
     , x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data               OUT  NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
     , x_error_msg_code         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );
-- End add by rtarway FP.M Development
--BUG 4081329, rtarway
procedure Check_Start_Date_EI(  p_project_id      IN NUMBER,
                             p_task_id         IN NUMBER,
                             p_start_date        IN DATE,
                             x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
procedure Check_End_Date_EI(  p_project_id      IN NUMBER,
                             p_task_id         IN NUMBER,
                             p_end_date        IN DATE,
                             x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--BUG 4081329, rtarway
end PA_TASKS_MAINT_UTILS;

 

/
