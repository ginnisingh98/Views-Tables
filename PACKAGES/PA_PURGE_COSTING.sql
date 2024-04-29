--------------------------------------------------------
--  DDL for Package PA_PURGE_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_COSTING" AUTHID CURRENT_USER as
/* $Header: PAXCSPRS.pls 120.1 2005/08/02 10:58:57 aaggarwa noship $ */

-- Start of comments
-- API name         : Pa_Costing_Main_Purge
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure is the main purge procedure for costing
--                    tables. This procedure calls a procedure that purges
--                    each of the individual tables.
--
-- Parameters       : p_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_txn_to_date			IN     DATE,
--                              If the purging is being done on projects
--                              that are active then this parameter is
--                              determine the date to which the transactions
--                              need to be purged.
--		      p_Commit_Size			IN     NUMBER,
--                              The number of records that can be allowed to
--                              remain uncommited. If the number of records
--                              goes byond this number then the process is
--                              commited.
--		      p_Archive_Flag			IN OUT VARCHAR2,
--                              This flag determines if the records need to
--                              be archived before they are purged
--		      p_Purge_Release			IN OUT VARCHAR2,
--                              The version of the application on which the
--                              purge process is run.
--		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER
--                              Error code returned from the procedure
-- End of comments

 procedure pa_costing_main_purge (
			p_purge_batch_id      in            NUMBER,
                        p_project_id          in            NUMBER,
                        p_purge_release       in            VARCHAR2,
                        p_txn_to_date         in            DATE,
                        p_archive_flag        in            VARCHAR2,
                        p_commit_size         in            NUMBER,
                        x_err_stack           in OUT NOCOPY VARCHAR2,
                        x_err_stage           in OUT NOCOPY VARCHAR2,
                        x_err_code            in OUT NOCOPY NUMBER ) ;

 procedure PA_CostDistLines (
			p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_txn_to_date        IN            DATE,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2 ) ;

 procedure PA_CcDistLines (
                            p_purge_batch_id     IN            NUMBER,
                            p_project_id         IN            NUMBER,
                            p_txn_to_date        IN            DATE,
                            p_purge_release      IN            VARCHAR2,
                            p_archive_flag       IN            VARCHAR2,
                            p_commit_size        IN            NUMBER,
                            x_err_code           IN OUT NOCOPY NUMBER,
                            x_err_stack          IN OUT NOCOPY VARCHAR2,
                            x_err_stage          IN OUT NOCOPY VARCHAR2);

 procedure PA_ExpenditureComments (
			p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_txn_to_date        IN            DATE,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2 ) ;


 procedure PA_ExpendItemAdjActivities (
			p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_txn_to_date        IN            DATE,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2 ) ;

procedure PA_EiDenorm  (
			p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_txn_to_date        IN            DATE,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2 ) ;

 procedure PA_ExpenditureHistory  (
			p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_txn_to_date        IN            DATE,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2 ) ;

 procedure PA_ExpenditureItems (
			p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_txn_to_date        IN            DATE,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2 ) ;

 procedure PA_ExpItemsSrcPurge (
			p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_txn_to_date        IN            DATE,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2 ) ;

 procedure PA_ExpItemsDestPurge(
			p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_txn_to_date        IN            DATE,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2 ) ;

 procedure PA_Routings1 (
			p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2 ) ;

 procedure PA_Expenditures1  (
			p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2 ) ;

 procedure PA_MRCExpenditureItems(
                        p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_txn_to_date        IN            DATE,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2,
			x_MRC_NoOfRecordsIns    OUT NOCOPY NUMBER ) ;

 procedure PA_MRCCostDistLines(
                        p_purge_batch_id     IN            NUMBER,
                        p_project_id         IN            NUMBER,
                        p_txn_to_date        IN            DATE,
                        p_purge_release      IN            VARCHAR2,
                        p_archive_flag       IN            VARCHAR2,
                        p_commit_size        IN            NUMBER,
                        x_err_code           IN OUT NOCOPY NUMBER,
                        x_err_stack          IN OUT NOCOPY VARCHAR2,
                        x_err_stage          IN OUT NOCOPY VARCHAR2,
                        x_MRC_NoOfRecordsIns    OUT NOCOPY NUMBER ) ;

 PROCEDURE PA_MRCCcDistLines( p_purge_batch_id  IN            NUMBER,
                             p_project_id       IN            NUMBER,
                             p_txn_to_date      IN            DATE,
                             p_purge_release    IN            VARCHAR2,
                             p_archive_flag     IN            VARCHAR2,
                             p_commit_size      IN            NUMBER,
                             x_err_code         IN OUT NOCOPY NUMBER,
                             x_err_stack        IN OUT NOCOPY VARCHAR2,
                             x_err_stage        IN OUT NOCOPY VARCHAR2,
                             x_MRC_NoOfRecordsIns  OUT NOCOPY NUMBER );

END pa_purge_costing;
 

/
