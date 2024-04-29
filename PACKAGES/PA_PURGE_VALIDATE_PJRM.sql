--------------------------------------------------------
--  DDL for Package PA_PURGE_VALIDATE_PJRM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_VALIDATE_PJRM" AUTHID CURRENT_USER as
/* $Header: PAXRMVTS.pls 120.2 2005/08/19 17:19:22 mwasowic noship $ */

g_purge_summary_flag VARCHAR2(1);
-- Start of comments
-- API name         : Validate_pjrm
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the project resource management details
--                    and a project is not purged if there exists any
--                    PJRM transactions for a project.
--                    Following validations are performed.
--                    1. If there exists any assignment or requirement.
--                    2. If the project is of unassigned time or
--                       an administrative type.
--
--
-- Parameters
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_Active_Flag		        IN     VARCHAR2,
--                              Indicates if batch contains ACTIVE or CLOSED projects
--                              ( 'A' - Active , 'C' - Closed)
--		      p_Txn_To_Date			IN     DATE,
--                              Date on or before which all transactions are to be purged
--                              (Will be used by Costing only)
--		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER
--                              Error code returned from the procedure
--                              = 0 SUCCESS
--                              > 0 Application error
--                              < 0 Oracle error
-- End of comments
 procedure    validate_pjrm ( p_project_id                     in NUMBER,
                              p_txn_to_date                    in DATE,
                              p_active_flag                    in VARCHAR2,
                              x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage                      in OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

/*The below procedure is added for PJR related archive purge enhancement --phase III
created by  :   Rajnish
*/
-- Start of comments
-- API name         : Validate_Requirement
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the project resource management details for requirements
--                    The proceduire do following validations
--                    1.In case of closed project purge,if there exist any requirement in open
--                      status, do not purge the project and PJR transactions.
--                    2 In case of open Indirect project  if there exists any requirement in OPEN status before the purge
--                      till date,Project and PJR transactions will not be purged.
--                      In both the above validations, the procedure will return error message if validation fails.
--
--

-- Parameters
--                    p_project_Id       IN     NUMBER              The project id for which records have
--                                                                  to be purged/archived.
--                    p_Active_Flag      IN     VARCHAR2            Indicates if batch contains ACTIVE or CLOSED projects
--                                                                  ( 'A' - Active , 'C' - Closed)
--                    p_Txn_To_Date      IN     DATE                 Date on or before which all transactions are to be purged
--
--                    X_Err_Stack      IN OUT   VARCHAR2            Error stack
--
--                    X_Err_Stage      IN OUT   VARCHAR2            Stage in the procedure where error occurred
--
--                    X_Err_Code       IN OUT   NUMBER              Error code returned from the procedure
--                                                                    = 0 SUCCESS
--                                                                    > 0 Application error
--                                                                    < 0 Oracle error
-- End of comments


Procedure    Validate_Requirement ( p_project_id                     in NUMBER,
                                    p_txn_to_date                    in DATE,
                                    p_active_flag                    in VARCHAR2,
                                    x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_err_stage                      in OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895



/*The below procedure is added for PJR related archive purge enhancement --phase III
created by  :   Rajnish
*/
-- Start of comments
-- API name         : Validate_Assignment_
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the project resource management details for requirements
--                    The proceduire do following validations
--                    1.In case of closed project purge,if there exist any assignment whose end date
--                      is greater than project closed date,then pjr assignment and project will not be purged.
--                      In above validation, the procedure will return error message if validation fails.
--

-- Parameters
--                    p_project_Id       IN     NUMBER              The project id for which records have
--                                                                  to be purged/archived.
--                    p_Active_Flag      IN     VARCHAR2            Indicates if batch contains ACTIVE or CLOSED projects
--                                                                  ( 'A' - Active , 'C' - Closed)
--                    p_Txn_To_Date      IN     DATE                 Date on or before which all transactions are to be purged
--
--                    X_Err_Stack      IN OUT   VARCHAR2            Error stack
--
--                    X_Err_Stage      IN OUT   VARCHAR2            Stage in the procedure where error occurred
--
--                    X_Err_Code       IN OUT   NUMBER              Error code returned from the procedure
--                                                                    = 0 SUCCESS
--                                                                    > 0 Application error
--                                                                    < 0 Oracle error
-- End of comments


Procedure    Validate_Assignment ( p_project_id                     in NUMBER,
                                   p_txn_to_date                    in DATE,
                                   p_active_flag                    in VARCHAR2,
                                   x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_stage                      in OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895


/* The below procedure is added for bug 2962582
   Created By: Vinay */

-- Start of comments
-- API name         : Validate_PJI
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the PJI details for the project.
--                    The procedure does the following validations
--                    1. In case PJI is installed and the project has unsummarized transactions, then it returns
--                       error message.
--

-- Parameters
--                    p_project_Id       IN     NUMBER              The project id for which records have
--                                                                  to be purged/archived.
--                    p_project_end_date IN     DATE                End date of the project to be purged.
--
--                    X_Err_Stack      IN OUT   VARCHAR2            Error stack
--
--                    X_Err_Stage      IN OUT   VARCHAR2            Stage in the procedure where error occurred
--
--                    X_Err_Code       IN OUT   NUMBER              Error code returned from the procedure
--                                                                    = 0 SUCCESS
--                                                                    > 0 Application error
--                                                                    < 0 Oracle error
-- End of comments

Procedure Validate_PJI ( p_project_id       IN NUMBER,
                         p_project_end_date IN DATE,
                         x_err_code         IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_err_stack        IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_err_stage        IN OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

/* The below procedure is added for bug  4255353
   Created By: Ajdas */
-- Start of comments
-- API name         : Validate_Perf_reporting
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the New Summarization model migration of th eprojects
--                    The procedure does the following validations
--

-- Parameters
--                    p_project_Id       IN     NUMBER              The project id for which records have
--                                                                  to be purged/archived.
--                    X_Err_Stack      IN OUT   VARCHAR2            Error stack
--
--                    X_Err_Stage      IN OUT   VARCHAR2            Stage in the procedure where error occurred
--
--                    X_Err_Code       IN OUT   NUMBER              Error code returned from the procedure
--                                                                    = 0 SUCCESS
--                                                                    > 0 Application error
--                                                                    < 0 Oracle error
-- End of comments

Procedure Validate_Perf_reporting ( p_project_id       IN NUMBER,
                        x_err_code         IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_err_stack        IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_err_stage        IN OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

END pa_purge_validate_pjrm;

 

/
