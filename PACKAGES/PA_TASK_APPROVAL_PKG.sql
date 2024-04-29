--------------------------------------------------------
--  DDL for Package PA_TASK_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_APPROVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: PATSKPKS.pls 120.2.12010000.1 2009/07/21 14:19:49 anuragar noship $ */

  PROCEDURE Mark_CO_Status(p_ci_id         IN NUMBER
                          ,p_msg_count     OUT NOCOPY NUMBER
                          ,p_msg_data      OUT NOCOPY VARCHAR2
                          ,p_return_status OUT NOCOPY VARCHAR2) ;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is being invoked on Change Order workflow to verify if any of the used task is
    -- already approved.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_ci_id                  NUMBER          YES       Change document Id
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                     Valid values are:
    --                                                       S (API completed successfully),
    --                                                       E (business rule violation error) and
    --                                                       U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
    --                                                    table. Calling programs should use this as the
    --                                                    basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
    --                                                    one error/warning message Otherwise the column is
    --                                                    left blank.
  ----------------------------------------------------------------------------------------------------------*/
  PROCEDURE Check_UsedTask_Status
                          (p_ci_id         IN NUMBER
                          ,p_msg_count     OUT NOCOPY NUMBER
                          ,p_msg_data      OUT NOCOPY VARCHAR2
                          ,p_return_status OUT NOCOPY VARCHAR2);

  /*---------------------------------------------------------------------------------------------------------
    -- This Function is called from Task Workflow package to verify if the submitted task is a child task
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_project_id             NUMBER          YES       Identification of the project
    --  p_proj_element           NUMBER          YES       Task Id
    --  p_parent_struc_ver       NUMBER          YES       Parent task structure version id
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                     Valid values are:
    --                                                       S (API completed successfully),
    --                                                       E (business rule violation error) and
    --                                                       U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
    --                                                    table. Calling programs should use this as the
    --                                                    basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
    --                                                    one error/warning message Otherwise the column is
    --                                                    left blank.
  ----------------------------------------------------------------------------------------------------------*/
  FUNCTION Is_Child_Task
                         (p_project_id       IN NUMBER
                         ,p_proj_element     IN NUMBER
                         ,p_parent_struc_ver IN NUMBER
                         ,p_msg_count        OUT NOCOPY NUMBER
                         ,p_msg_data         OUT NOCOPY VARCHAR2
                         ,p_return_status    OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  /*---------------------------------------------------------------------------------------------------------
    -- This Function is called from Task Workflow package to verify if the parent task is already approved or not
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_project_id             NUMBER          YES       Identification of the project
    --  p_proj_element           NUMBER          YES       Task Id
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                     Valid values are:
    --                                                       S (API completed successfully),
    --                                                       E (business rule violation error) and
    --                                                       U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
    --                                                    table. Calling programs should use this as the
    --                                                    basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
    --                                                    one error/warning message Otherwise the column is
    --                                                    left blank.
  ----------------------------------------------------------------------------------------------------------*/
  FUNCTION Is_Parent_Task_Approved
                         (p_project_id      IN NUMBER
                         ,p_parent_task_id  IN NUMBER
                         ,p_task_id         IN NUMBER
                         ,p_parent_struc_ver IN NUMBER
                         ,p_msg_count       OUT NOCOPY NUMBER
                         ,p_msg_data        OUT NOCOPY VARCHAR2
                         ,p_return_status   OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is being invoked on Tasks Submission for approval.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_project_id             NUMBER          YES       Identification of the project
    --  p_task_id                NUMBER          YES       Task Identifier
    --  p_ref_task_id            NUMBER          YES       Reference Task Identifier (NOT USED)
    --  p_parent_struc_ver       NUMBER          YES       Parent task structure version id
    --  p_approver_user_id       NUMBER          YES       Approver user Id
    --  p_ci_id                  NUMBER          YES       Change document Id
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  p_return_status          VARCHAR2       YES       The return status of the APIs.
    --                                                     Valid values are:
    --                                                       S (API completed successfully),
    --                                                       E (business rule violation error) and
    --                                                       U(Unexpected error, such as an Oracle error.
    --  p_msg_count              NUMBER         YES       Holds the number of messages in the global message
    --                                                    table. Calling programs should use this as the
    --                                                    basis to fetch all the stored messages.
    --  p_msg_data               VARCHAR2       YES       Holds the message code, if the API returned only
    --                                                    one error/warning message Otherwise the column is
    --                                                    left blank.
  ----------------------------------------------------------------------------------------------------------*/

  PROCEDURE Submit_Task
                        (p_project_id           IN NUMBER
                        ,p_task_id              IN NUMBER
                        ,p_ref_task_id          IN NUMBER
                        ,p_parent_struc_ver     IN NUMBER
                        ,p_approver_user_id     IN NUMBER
                        ,p_ci_id                IN NUMBER
                        ,p_msg_count            OUT NOCOPY NUMBER
                        ,p_msg_data             OUT NOCOPY VARCHAR2
                        ,p_return_status        OUT NOCOPY VARCHAR2);

END PA_TASK_APPROVAL_PKG;

/
