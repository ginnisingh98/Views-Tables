--------------------------------------------------------
--  DDL for Package PA_STRUCT_TASK_ROLLUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STRUCT_TASK_ROLLUP_PUB" AUTHID DEFINER as
/* $Header: PATKRUPS.pls 120.4 2007/03/08 09:21:13 maansari ship $ */

TYPE pa_element_version_id_tbl_typ IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

    Procedure Tasks_Rollup_Unlimited(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_element_versions                  IN  pa_element_version_id_tbl_typ
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


    Procedure Tasks_Rollup(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_element_versions                  IN  PA_NUM_1000_NUM
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


    Procedure Task_Status_Rollup(
     p_api_version              IN  NUMBER      := 1.0
    ,p_init_msg_list            IN  VARCHAR2    := FND_API.G_TRUE
    ,p_commit                   IN  VARCHAR2    := FND_API.G_FALSE
    ,p_validate_only            IN  VARCHAR2    := FND_API.G_TRUE
    ,p_validation_level         IN  VARCHAR2    := 100
    ,p_calling_module           IN  VARCHAR2    := 'SELF_SERVICE'
    ,p_debug_mode               IN  VARCHAR2    := 'N'
    ,p_max_msg_count            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_structure_version_id     IN  NUMBER
    ,p_element_version_id       IN  NUMBER      := NULL
    ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                 OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

    Procedure Task_Stat_Pushdown_Rollup(
     p_api_version              IN  NUMBER      := 1.0
    ,p_init_msg_list            IN  VARCHAR2    := FND_API.G_TRUE
    ,p_commit                   IN  VARCHAR2    := FND_API.G_FALSE
    ,p_validate_only            IN  VARCHAR2    := FND_API.G_TRUE
    ,p_validation_level         IN  VARCHAR2    := 100
    ,p_calling_module           IN  VARCHAR2    := 'SELF_SERVICE'
    ,p_debug_mode               IN  VARCHAR2    := 'N'
    ,p_max_msg_count            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_structure_version_id     IN  NUMBER
    ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                 OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

-- API name                      : Rollup_From_Subproject
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version                 IN  NUMBER      := 1.0
-- p_init_msg_list               IN  VARCHAR2    := FND_API.G_TRUE
-- p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                  IN  VARCHAR2    := 'N'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_element_versions            IN  PA_NUM_1000_NUM
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2
--
--
   PROCEDURE Rollup_From_Subproject(
    p_api_version               IN  NUMBER      := 1.0
   ,p_init_msg_list             IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                    IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only             IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level          IN  VARCHAR2    := 100
   ,p_calling_module            IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                IN  VARCHAR2    := 'N'
   ,p_max_msg_count             IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_element_versions          IN  PA_NUM_1000_NUM
   ,p_published_str_ver_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  --bug5861729
   ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );

-- API name                      : Program_Schedule_dates_rollup
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version                 IN  NUMBER      := 1.0
-- p_init_msg_list               IN  VARCHAR2    := FND_API.G_TRUE
-- p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                  IN  VARCHAR2    := 'N'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_structure_version_id        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2
--
--
   PROCEDURE Program_Schedule_dates_rollup(
    p_api_version               IN  NUMBER      := 1.0
   ,p_init_msg_list             IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                    IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only             IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level          IN  VARCHAR2    := 100
   ,p_calling_module            IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                IN  VARCHAR2    := 'N'
   ,p_max_msg_count             IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_published_str_ver_id      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );


END PA_STRUCT_TASK_ROLLUP_PUB;

/
