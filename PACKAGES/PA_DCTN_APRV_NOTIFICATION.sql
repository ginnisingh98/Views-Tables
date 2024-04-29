--------------------------------------------------------
--  DDL for Package PA_DCTN_APRV_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DCTN_APRV_NOTIFICATION" AUTHID CURRENT_USER as
/* $Header: PADTNWFS.pls 120.0.12010000.1 2009/07/21 10:59:41 sosharma noship $ */


    CURSOR c_proj_info(p_project_id VARCHAR2) IS
      SELECT  project_id                      project_id
             ,segment1                        project_number
             ,name                            project_name
             ,start_date                      start_date
             ,completion_date                 end_date
             ,project_type                    project_type
             ,carrying_out_organization_id    organization_id
             ,project_status_code             project_status
        FROM  PA_PROJECTS
        WHERE project_id = p_project_id;

    CURSOR c_dctn_hdr(p_dctn_req_id NUMBER) IS
      SELECT *
        FROM  PA_DEDUCTIONS_ALL
        WHERE deduction_req_id = p_dctn_req_id;

    CURSOR  c_manager( p_manager_id NUMBER ) IS
      SELECT  f.user_id user_id
             ,f.user_name user_name
             ,e.first_name||' '||e.last_name full_name
      FROM   FND_USER f
            ,PA_EMPLOYEES e
      WHERE  f.employee_id = p_manager_id
      AND    f.employee_id = e.person_id;

    CURSOR c_proj_manager (l_project_id NUMBER) IS
    SELECT  ppp.resource_source_id manager_employee_id
      FROM   PA_PROJECT_PARTIES  ppp
            ,PER_ALL_PEOPLE_F pe
      WHERE  ppp.project_id = l_project_id
      AND    ppp.project_role_id = 1
      AND    ppp.resource_type_id = 101
      AND    ppp.resource_source_id = pe.person_id
      AND    TRUNC(SYSDATE) BETWEEN pe.effective_start_date AND pe.effective_end_date
      AND    ppp.object_type = 'PA_PROJECTS'
      AND    TRUNC(SYSDATE) BETWEEN ppp.start_date_active
                           AND NVL(ppp.end_date_active,TRUNC(SYSDATE)+1);

    PROCEDURE Start_Dctn_Aprv_Wf (p_dctn_req_id IN NUMBER
                                 ,x_err_stack IN OUT NOCOPY VARCHAR2
                                 ,x_err_stage IN OUT NOCOPY VARCHAR2
                                 ,x_err_code OUT NOCOPY NUMBER);

    PROCEDURE Select_Project_Manager (itemtype IN VARCHAR2
                                     ,itemkey IN VARCHAR2
                                     ,actid IN NUMBER
                                     ,funcmode IN VARCHAR2
                                     ,resultout OUT NOCOPY VARCHAR2);

    PROCEDURE Append_Varchar_To_Clob(p_varchar IN VARCHAR2
                                    ,p_clob IN OUT NOCOPY CLOB);

    PROCEDURE Show_Pwp_Notify_Preview (document_id IN VARCHAR2
                                      ,display_type IN VARCHAR2
                                      ,document IN OUT NOCOPY CLOB
                                      ,document_type IN OUT NOCOPY VARCHAR2);

    PROCEDURE Generate_Dctn_Aprv_Notify
                              (p_item_type IN VARCHAR2
                              ,p_item_key IN VARCHAR2
                              ,p_dctn_hdr_rec IN c_dctn_hdr%ROWTYPE
                              ,p_proj_info_rec IN c_proj_info%ROWTYPE
                              ,x_content_id OUT NOCOPY NUMBER);

    PROCEDURE Submit (itemtype IN VARCHAR2
                     ,itemkey IN VARCHAR2
                     ,actid IN NUMBER
                     ,funcmode IN VARCHAR2
                     ,resultout OUT NOCOPY VARCHAR2);

    FUNCTION show_error(p_error_stack   IN VARCHAR2,
                        p_error_stage   IN VARCHAR2,
                        p_error_message IN VARCHAR2,
                        p_arg1          IN VARCHAR2 DEFAULT null,
                        p_arg2          IN VARCHAR2 DEFAULT null) RETURN VARCHAR2;

END PA_DCTN_APRV_NOTIFICATION;

/
