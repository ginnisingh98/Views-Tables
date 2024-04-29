--------------------------------------------------------
--  DDL for Package PA_PURGE_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_BILLING" AUTHID CURRENT_USER as
/*$Header: PAXBIPRS.pls 120.1 2005/08/19 17:09:21 mwasowic noship $*/

-- Start of comments
-- API name         : PA_Billing_Main_Purge
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for billing tables.
--                    Calls a seperate procedure to purge each billing table
-- Parameters       :
--        l            p_purge_batch_id  -> Purge batch Id
--                     p_project_id      -> Project Id
--                     p_purge_release   -> The release during which it is
--                                          purged
--                     p_archive_flag    -> This flag will indicate if the
--                                          records need to be archived
--                                          before they are purged.
--                     p_txn_to_date     -> Date through which the transactions
--                                          need to be purged. This value will
--                                          be NULL if the purge batch is for
--                                          active projects.
--                     p_commit_size     -> The maximum number of records that
--                                          can be allowed to remain uncommited.
--                                          If the number of records processed
--                                          goes byond this number then the
--                                          process is commited.
-- End of comments
 procedure pa_billing_main_purge ( p_purge_batch_id                 in NUMBER,
                                   p_project_id                     in NUMBER,
                                   p_purge_release                  in VARCHAR2,
                                   p_txn_to_date                    in DATE,
                                   p_archive_flag                   in VARCHAR2,
                                   p_commit_size                    in NUMBER,
                                   x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

END pa_purge_billing;
 

/
