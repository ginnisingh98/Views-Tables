--------------------------------------------------------
--  DDL for Package PA_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE" AUTHID CURRENT_USER as
/* $Header: PAXPRMNS.pls 120.1 2005/08/19 17:17:39 mwasowic noship $ */

-- Start of comments
-- API name         : Purge
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure is called from the form.
--                    Main purge procedure.
--                    Invokes the purge_project procedure for each project
--                    in the purge batch
-- Parameters         p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
--		      p_Commit_Size			IN     NUMBER,
--                              The commit size
--		      errbuf 			        IN OUT VARCHAR2,
--                              error buffer containing the SQLERRM
--		      ret_code 		                IN OUT NUMBER
--                              Standard error code returned from the procedure
--                              = 0 SUCCESS
--                              < 0 Oracle error
-- End of comments
Procedure Purge (
		p_Batch_Id		IN     NUMBER ,
		p_Commit_Size		IN     NUMBER ,
                ret_code                IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                errbuf                  IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Start of comments
-- API name         : Purge_Project
-- Type             : Private
-- Pre-reqs         : None
-- Function         : Invokes the procedure for purge for a specific project for the
--                    various modules ( Costing , billing ,Project tracking , capital
--                    projects) based on the option selection during the purge batch
--                    creation.
--                    In addition also invokes a client extension
--                    for any customer specific purge procedures
--
-- Parameters         p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_Active_Closed_Flag		IN     VARCHAR2,
--                              Indicates if batch contains ACTIVE or CLOSED projects
--                              ( 'A' - Active , 'C' - Closed)
--		      p_Purge_Release                   IN     VARCHAR2,
--                              Oracle Projects release (10.7 , 11.0)
--		      p_Purge_Summary_Flag		IN     VARCHAR2,
--                              Purge Summary tables data
--		      p_Purge_Capital_Flag		IN     VARCHAR2,
--                              Purge Capital projects tables data
--		      p_Purge_Budgets_Flag		IN     VARCHAR2,
--                              Purge Budget tables data
--		      p_Purge_Actuals_Flag		IN     VARCHAR2,
--                              Purge Actuals tables data i.e. Costing and Billing tables
--		      p_Archive_Summary_Flag		IN     VARCHAR2,
--                              Archive Summary tables data
--		      p_Archive_Capital_Flag 		IN     VARCHAR2,
--                              Purge Capital projects tables data
--		      p_Archive_Budgets_Flag		IN     VARCHAR2,
--                              Archive Budget tables data
--		      p_Archive_Actuals_Flag 	 	IN     VARCHAR2,
--                              Archive Actuals tables data i.e. Costing and Billing tables
--		      p_Txn_To_Date			IN     DATE,
--                              Date on or before which all transactions are to be purged
--                              (Will be used by Costing only)
--		      p_Commit_Size			IN     NUMBER,
--                              The commit size
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
 Procedure Purge_Project(
		p_batch_id			IN     NUMBER,
		p_project_Id			IN     NUMBER,
		p_Active_Closed_Flag		IN     VARCHAR2,
		p_Purge_release                 IN     VARCHAR2,
		p_Purge_Summary_Flag		IN     VARCHAR2,
		p_Purge_Capital_Flag		IN     VARCHAR2,
		p_Purge_Budgets_Flag		IN     VARCHAR2,
		p_Purge_Actuals_Flag		IN     VARCHAR2,
		p_Archive_Summary_Flag		IN     VARCHAR2,
		p_Archive_Capital_Flag 		IN     VARCHAR2,
		p_Archive_Budgets_Flag		IN     VARCHAR2,
		p_Archive_Actuals_Flag 	 	IN     VARCHAR2,
		p_Txn_To_Date			IN     DATE,
		p_Commit_Size			IN     NUMBER,
		X_Err_Stack			IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		X_Err_Stage		        IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		X_Err_Code		        IN OUT NOCOPY NUMBER) ; --File.Sql.39 bug 4440895


-- Start of comments
-- API name         : CommitProcess
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Common procedure for commit.
--                    Will be invoked from the various purge procedures
--
-- Parameters         p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              been purged/archived.
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              been purged/archived.
--		      p_Commit_Size			IN     NUMBER,
--                              The commit size
--                    p_table_name		        IN VARCHAR2,
--                              The table for which rows have been purged
--                    p_NoOfRecordsIns                  IN NUMBER,
--                              No. of records inserted into the archive table
--                    p_NoOfRecordsDel                  IN NUMBER,
--                              No. of records deleted from table
-- 		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER,
--                              Error code returned from the procedure
--                              = 0 SUCCESS
--                              > 0 Application error
--                              < 0 Oracle error
--                    p_MRC_table_name                      IN VARCHAR2,
--                              The MRC table for which rows have been purged
--                    p_MRC_NoOfRecordsIns                  IN NUMBER,
--                              No. of records inserted into the MRC archive table
--                    p_MRC_NoOfRecordsDel                  IN NUMBER
--                              No. of records deleted from MRC table
-- End of comments
 Procedure  CommitProcess(p_purge_batch_id              IN NUMBER,
                          p_project_id                  IN NUMBER,
                          p_table_name	                IN VARCHAR2,
                          p_NoOfRecordsIns              IN NUMBER,
                          p_NoOfRecordsDel              IN NUMBER,
                          x_err_code                    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_MRC_table_name              IN VARCHAR2  DEFAULT NULL,
                          p_MRC_NoOfRecordsIns          IN NUMBER    DEFAULT NULL,
                          p_MRC_NoOfRecordsDel          IN NUMBER    DEFAULT NULL
                          );

-- Start of comments
-- API name         : get_post_purge_status
-- Type             : Private
-- Pre-reqs         : None
-- Function         : This function checks if the project is fully purged or
--                    partially purged for close projects and returns
--                    Returns the project status code ' Fully_Purged' or 'Partially_Purged'
--                    For active projects returns the old project status code
-- Parameters
--		      p_project_Id			IN     NUMBER,
--                              The project id for which purge status is to be determined
--                    p_batch_id                        IN     NUMBER,
--                              The purge batch id
-- End of comments

 Function get_post_purge_status ( p_project_id IN NUMBER , p_batch_id IN NUMBER) Return VARCHAR2;

end pa_purge; /*Specification*/
 

/
