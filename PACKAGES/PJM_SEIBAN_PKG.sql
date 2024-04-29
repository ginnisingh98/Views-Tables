--------------------------------------------------------
--  DDL for Package PJM_SEIBAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_SEIBAN_PKG" AUTHID CURRENT_USER AS
/* $Header: PJMSEBNS.pls 115.6 2002/10/29 20:14:07 alaw ship $ */

-- Procedure Name : project_number_dup
--
-- Checks for the project_number if it already exists in PJM_PROJECTS_V

PROCEDURE project_number_dup
( X_project_number      IN         VARCHAR2
, X_dup_number_flag     OUT NOCOPY VARCHAR2
);


-- Procedure Name : project_name_dup
--
-- Checks for the project_name if it already exists in PJM_PROJECTS_V

PROCEDURE project_name_dup
( X_project_name        IN         VARCHAR2
, X_dup_name_flag       OUT NOCOPY VARCHAR2
);

FUNCTION check_dup_project_num
( X_project_number      IN  VARCHAR2
, X_project_id          IN  NUMBER    DEFAULT NULL
) RETURN VARCHAR2;

FUNCTION check_dup_project_name
( X_project_name        IN  VARCHAR2
, X_project_id          IN  NUMBER    DEFAULT NULL
) RETURN VARCHAR2;

--
-- Create_amg_project procedure can be used to create a project in
-- Oracle Projects. This uses AMG's API named create_project.
--
-- This procedure takes the following IN parameters:
--
--        Project_created_from    source (template) project_id
--        Project_number          target project_number
--        Project_name            target project_name
--        start_date              start date for the new project
--        end_date                end date for the new project
--        Submit_Workflow         'Y' or 'N'
--        Project_id              ID of the target project
--        Return_status           status of the project creation
--
PROCEDURE create_amg_project
( X_project_created_from  IN         NUMBER
, X_project_number        IN         VARCHAR2
, X_project_name          IN         VARCHAR2
, X_start_date            IN         DATE
, X_end_date              IN         DATE
, X_submit_workflow       IN         VARCHAR2
, X_project_id            OUT NOCOPY NUMBER
, X_return_status         OUT NOCOPY VARCHAR2
);


--
-- Procedure Name : create_amg_task
--
-- Create_amg_task procedure can be used to create a task in
-- Oracle projects. This uses AMG's API named add_task.
--
-- This procedure accepts the following parameters:
--
--        Project_id              project_id of project under which the task
--                                needs to be created
--        Project_number          Corresponding project_number for the above
--                                project
--        Task_number             Task number for the task to be created
--        Task_id                 ID of the task that has been created
--        Return_status           status of the Task creation
--
PROCEDURE create_amg_task
( X_project_id          IN         NUMBER
, X_project_number      IN         VARCHAR2
, X_task_number         IN         VARCHAR2
, X_task_id             OUT NOCOPY NUMBER
, X_return_status       OUT NOCOPY VARCHAR2
);


PROCEDURE Conc_Create
( ERRBUF                  OUT NOCOPY    VARCHAR2
, RETCODE                 OUT NOCOPY    NUMBER
, X_Create_or_Add         IN            NUMBER    DEFAULT 1
, X_Project_Template      IN            NUMBER    DEFAULT NULL
, X_Project_Number        IN            VARCHAR2  DEFAULT NULL
, X_Project_Name          IN            VARCHAR2  DEFAULT NULL
, X_start_date            IN            VARCHAR2  DEFAULT NULL
, X_end_date              IN            VARCHAR2  DEFAULT NULL
, X_submit_workflow       IN            VARCHAR2  DEFAULT 'Y'
, X_Project_ID            IN            NUMBER    DEFAULT NULL
, X_Prefix                IN            VARCHAR2  DEFAULT NULL
, X_Suffix                IN            VARCHAR2  DEFAULT NULL
, X_From_Task             IN            NUMBER
, X_To_Task               IN            NUMBER
, X_Increment_By          IN            NUMBER    DEFAULT 1
, X_numeric_width         IN            NUMBER    DEFAULT NULL
);

END PJM_SEIBAN_PKG;

 

/
