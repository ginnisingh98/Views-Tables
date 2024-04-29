--------------------------------------------------------
--  DDL for Package PA_RES_ACCUMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_ACCUMS" AUTHID CURRENT_USER AS
/* $Header: PARESACS.pls 120.1 2005/08/19 16:50:41 mwasowic noship $ */

   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;


   TYPE resource_index IS RECORD
   (resource_list_id  NUMBER(15),
    location          NUMBER(15));

   TYPE resource_index_tbl IS TABLE OF resource_index
   INDEX BY BINARY_INTEGER;

   TYPE resources_in_rec_type IS RECORD
   (resource_list_assignment_id NUMBER(15),
    resource_list_id            NUMBER(15),
    resource_list_member_id     NUMBER(15),
    member_level                NUMBER(15),
    resource_id                 NUMBER(15),
    person_id                   NUMBER,
    job_id                      NUMBER,
    organization_id             NUMBER,
    vendor_id                   NUMBER,
    expenditure_type            VARCHAR2(30),
    event_type                  VARCHAR2(30),
    non_labor_resource          VARCHAR2(20),
    expenditure_category        VARCHAR2(30),
    revenue_category            VARCHAR2(30),
    non_labor_resource_org_id   NUMBER,
    event_type_classification   VARCHAR2(30),
    system_linkage_function     VARCHAR2(30),
    resource_format_id          NUMBER(15),
    resource_type_code          VARCHAR2(20)
    , job_group_id      NUMBER
        );

   TYPE resources_tbl_type IS TABLE OF resources_in_rec_type
           INDEX BY BINARY_INTEGER;

--   TYPE resource_list_asgn_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE resource_list_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE member_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE member_level_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE resource_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE person_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE job_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE organization_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE vendor_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE expenditure_type_tabtype IS TABLE OF
--        pa_txn_accum.expenditure_type%TYPE INDEX BY BINARY_INTEGER;
--   TYPE event_type_tabtype IS TABLE OF
--        pa_txn_accum.event_type%TYPE INDEX BY BINARY_INTEGER;
--   TYPE non_labor_resource_tabtype IS TABLE OF
--        pa_txn_accum.non_labor_resource%TYPE INDEX BY BINARY_INTEGER;
--   TYPE expenditure_category_tabtype IS TABLE OF
--        pa_txn_accum.expenditure_category%TYPE INDEX BY BINARY_INTEGER;
--   TYPE revenue_category_tabtype IS TABLE OF
--        pa_txn_accum.revenue_category%TYPE INDEX BY BINARY_INTEGER;
--   TYPE nlr_org_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE event_type_class_tabtype IS TABLE OF
--        pa_txn_accum.event_type_classification%TYPE INDEX BY BINARY_INTEGER;
--   TYPE system_linkage_tabtype IS TABLE OF
--        pa_txn_accum.system_linkage_function%TYPE INDEX BY BINARY_INTEGER;
--   TYPE resource_format_id_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--   TYPE resource_type_code_tabtype IS TABLE OF
--        pa_resource_types.resource_type_code%TYPE INDEX BY BINARY_INTEGER;

   FUNCTION Initialize RETURN NUMBER;

   PROCEDURE get_resource_map
           (x_resource_list_id             IN NUMBER,
            x_resource_list_assignment_id  IN NUMBER,
            x_person_id                    IN NUMBER,
            x_job_id                       IN NUMBER,
            x_organization_id              IN NUMBER,
            x_vendor_id                    IN NUMBER,
            x_expenditure_type             IN VARCHAR2,
            x_event_type                   IN VARCHAR2,
            x_non_labor_resource           IN VARCHAR2,
            x_expenditure_category         IN VARCHAR2,
            x_revenue_category             IN VARCHAR2,
            x_non_labor_resource_org_id    IN NUMBER,
            x_event_type_classification    IN VARCHAR2,
            x_system_linkage_function      IN VARCHAR2,
            x_resource_list_member_id   IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_resource_id               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_resource_map_found        IN OUT NOCOPY BOOLEAN, --File.Sql.39 bug 4440895
            x_err_stage                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                  IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE get_resource_map_new
           (x_resource_list_id             IN NUMBER,
            x_person_id                    IN NUMBER,
            x_job_id                       IN NUMBER,
            x_organization_id              IN NUMBER,
            x_vendor_id                    IN NUMBER,
            x_expenditure_type             IN VARCHAR2,
            x_event_type                   IN VARCHAR2,
            x_non_labor_resource           IN VARCHAR2,
            x_expenditure_category         IN VARCHAR2,
            x_revenue_category             IN VARCHAR2,
            x_non_labor_resource_org_id    IN NUMBER,
            x_event_type_classification    IN VARCHAR2,
            x_system_linkage_function      IN VARCHAR2,
            x_resource_list_member_id   IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_resource_id               IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_resource_map_found        IN OUT NOCOPY BOOLEAN, --File.Sql.39 bug 4440895
            x_err_stage                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                  IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   -- deleting the resource maps

   PROCEDURE delete_res_maps_on_asgn_id
           (x_resource_list_assignment_id  IN NUMBER,
            x_err_stage                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                  IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE delete_res_maps_on_prj_id
           (x_project_id                   IN NUMBER,
            x_resource_list_id             IN NUMBER,
            x_err_stage                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                  IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   -- the function given below creates a resource map

   PROCEDURE create_resource_map
           (x_resource_list_id            IN NUMBER,
            x_resource_list_assignment_id IN NUMBER,
            x_resource_list_member_id     IN NUMBER,
            x_resource_id                 IN NUMBER,
            x_person_id                   IN NUMBER,
            x_job_id                      IN NUMBER,
            x_organization_id             IN NUMBER,
            x_vendor_id                   IN NUMBER,
            x_expenditure_type            IN VARCHAR2,
            x_event_type                  IN VARCHAR2,
            x_non_labor_resource          IN VARCHAR2,
            x_expenditure_category        IN VARCHAR2,
            x_revenue_category            IN VARCHAR2,
            x_non_labor_resource_org_id   IN NUMBER,
            x_event_type_classification   IN VARCHAR2,
            x_system_linkage_function     IN VARCHAR2,
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   -- change resource list assignment

   PROCEDURE change_resource_list_status
           (x_resource_list_assignment_id IN NUMBER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   FUNCTION get_resource_list_status
          (x_resource_list_assignment_id IN NUMBER)
          RETURN VARCHAR2 ;

   FUNCTION get_resource_rank
          (x_resource_format_id IN NUMBER,
           x_txn_class_code     IN VARCHAR2)
          RETURN NUMBER ;

   FUNCTION get_group_resource_type_code
          (x_resource_list_id IN NUMBER)
          RETURN VARCHAR2 ;

   PROCEDURE create_resource_accum_details
           (x_resource_list_id            IN NUMBER,
            x_resource_list_assignment_id IN NUMBER,
            x_resource_list_member_id     IN NUMBER,
            x_resource_id                 IN NUMBER,
            x_txn_accum_id                IN NUMBER,
            x_project_id                  IN NUMBER,
            x_task_id                     IN NUMBER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE delete_resource_accum_details
           (x_resource_list_assignment_id IN NUMBER,
            x_resource_list_id            IN NUMBER,
            x_project_id                  IN NUMBER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE get_mappable_resources
           (x_project_id                     IN  NUMBER,
            x_res_list_id                    IN  NUMBER,
            x_resource_ind                IN OUT NOCOPY resource_index_tbl, /*Added nocopy for bug 2674619*/
            x_resources_in                IN OUT  NOCOPY resources_tbl_type, /*Added nocopy for bug 2674619*/
            x_no_of_resources             IN OUT  NOCOPY BINARY_INTEGER, --File.Sql.39 bug 4440895
            x_index                       IN OUT NOCOPY BINARY_INTEGER, --File.Sql.39 bug 4440895
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

--          x_resource_list_id            IN OUT  resource_list_id_tabtype,
--          x_resource_list_assignment_id IN OUT  resource_list_asgn_id_tabtype,
--          x_resource_list_member_id     IN OUT  member_id_tabtype,
--          x_resource_id                 IN OUT  resource_id_tabtype,
--          x_member_level                IN OUT member_level_tabtype,
--          x_person_id                   IN OUT  person_id_tabtype,
--          x_job_id                      IN OUT job_id_tabtype,
--          x_organization_id             IN OUT  organization_id_tabtype,
--          x_vendor_id                   IN OUT  vendor_id_tabtype,
--          x_expenditure_type            IN OUT  expenditure_type_tabtype,
--          x_event_type                  IN OUT event_type_tabtype,
--          x_non_labor_resource          IN OUT non_labor_resource_tabtype,
--          x_expenditure_category        IN OUT expenditure_category_tabtype,
--          x_revenue_category            IN OUT revenue_category_tabtype,
--          x_non_labor_resource_org_id   IN OUT nlr_org_id_tabtype,
--          x_event_type_classification   IN OUT event_type_class_tabtype,
--          x_system_linkage_function     IN OUT system_linkage_tabtype,
--          x_resource_format_id          IN OUT resource_format_id_tabtype,
--          x_resource_type_code          IN OUT resource_type_code_tabtype,

   PROCEDURE old_map_txns
           (x_project_id                  IN     NUMBER,
            x_res_list_id                 IN     NUMBER,
            x_mode                        IN     VARCHAR2 DEFAULT 'I',
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE map_txns
           (x_project_id                  IN     NUMBER,
            x_res_list_id                 IN     NUMBER,
            x_mode                        IN     VARCHAR2 DEFAULT 'I',
            x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_err_code                    IN OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE new_map_txns /* Created for bug# 1889671 */
            (x_resource_list_id           IN     NUMBER,
             x_error_stage                   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_error_code                    OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE update_parents_mem_id /* Created for bug# 1889671 */
            (x_res_list_id IN  pa_resource_lists_all_bg.resource_list_id%type,
             x_err_stage   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_err_code    OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE ins_temp_res_map_grp /* Created for bug# 1889671 */
            (x_res_list_id     IN  pa_resource_lists_all_bg.resource_list_id%type,
             x_rl_job_grp_id   IN  pa_resource_lists_all_bg.job_group_id%type,
             x_err_stage       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_err_code        OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   PROCEDURE ins_temp_res_map_ungrp /* Created for bug# 1889671 */
            (x_res_list_id     IN  pa_resource_lists_all_bg.resource_list_id%type,
             x_rl_job_grp_id   IN  pa_resource_lists_all_bg.job_group_id%type,
             x_err_stage       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
             x_err_code        OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

END PA_RES_ACCUMS;

 

/
