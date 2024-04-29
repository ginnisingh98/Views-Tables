--------------------------------------------------------
--  DDL for Package PA_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SEARCH_PVT" AUTHID CURRENT_USER AS
--$Header: PARISPVS.pls 120.1 2005/08/19 16:54:54 mwasowic noship $
--

  PROCEDURE Run_Search             ( p_search_mode          IN  VARCHAR2
                                   , p_search_criteria      IN  PA_SEARCH_GLOB.Search_Criteria_Rec_Type
                                   , p_competence_criteria  IN  PA_SEARCH_GLOB.Competence_Criteria_Tbl_Type
                                   , p_commit               IN  VARCHAR2
                                   , p_validate_only        IN  VARCHAR2
                                   , x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   );

  PROCEDURE Run_Auto_Search(errbuf                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            retcode                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_auto_search_mode      IN VARCHAR2,
                            p_project_id            IN NUMBER,
                            p_project_number_from   IN VARCHAR2,
                            p_project_number_to     IN VARCHAR2,
                            p_proj_start_date_days  IN NUMBER,
                            p_req_start_date_days   IN NUMBER,
                            p_project_status_code   IN VARCHAR2,
                            p_debug_mode            IN VARCHAR2
                            );


  FUNCTION Show_Req_In_Search(p_assignment_id pa_project_assignments.assignment_id%TYPE,
                              p_status_code   pa_project_statuses.project_status_code%TYPE)
      RETURN VARCHAR2;


END PA_SEARCH_PVT;
 

/
