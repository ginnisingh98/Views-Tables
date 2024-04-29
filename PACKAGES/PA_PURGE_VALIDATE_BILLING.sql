--------------------------------------------------------
--  DDL for Package PA_PURGE_VALIDATE_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_VALIDATE_BILLING" AUTHID CURRENT_USER as
/* $Header: PAXBIVTS.pls 120.1 2005/08/19 17:09:28 mwasowic noship $ */

-- Start of comments
-- API name         : Validate_Billing
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Validates the data in billing tables before purge for a project
--                    and reports the invalid data conditions
--                    The following validations are performed
--
--                    1.All the expenditure items should be revenue distributed.
--                    2.All the draft revenues are transferred and accepted in GL.
--                    3.All the draft invoices are transferred and accepted in AR.
--                    4.All revenue are summarized.
--                    5.Unbilled Recievables and Unearned Revenue should be zero.
--                    6.Events having completion date should be processed
--
--
-- Parameters         p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
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
 procedure validate_billing ( p_project_id                     in NUMBER,
                              p_txn_to_date                    in DATE,
                              p_active_flag                    in VARCHAR2,
                              x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_err_stage                      in OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

END pa_purge_validate_billing;
 

/
