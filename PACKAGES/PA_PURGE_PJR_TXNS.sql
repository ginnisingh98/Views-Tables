--------------------------------------------------------
--  DDL for Package PA_PURGE_PJR_TXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_PJR_TXNS" AUTHID CURRENT_USER AS
/* $Header: PAXPJRPS.pls 120.1 2005/08/19 17:16:59 mwasowic noship $ */
-- Start of comments
-- API name         : PA_REQUIREMENTS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records related to Requirements for project
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

Procedure PA_REQUIREMENTS_PURGE ( p_purge_batch_id                 in NUMBER,
                                  p_project_id                     in NUMBER,
                                  p_purge_release                  in VARCHAR2,
                                  p_txn_to_date                    in DATE,
                                  p_archive_flag                   in VARCHAR2,
                                  p_commit_size                    in NUMBER,
                                  x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895




-- Start of comments
-- API name         : PA_ASSIGNMENTS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records related to Assignments for project
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


Procedure PA_ASSIGNMENTS_PURGE ( p_purge_batch_id                 in NUMBER,
                                 p_project_id                     in NUMBER,
                                 p_purge_release                  in VARCHAR2,
                                 p_txn_to_date                    in DATE,
                                 p_archive_flag                   in VARCHAR2,
                                 p_commit_size                    in NUMBER,
                                 x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895


-- Start of comments
-- API name         : PA_FORECAST_ITEMS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Purge procedure for Purging records from tables PA_FORECAST_ITEMS and PA_FORECAST_ITEM_DETAILS
-- Parameters       :
--        l            p_purge_batch_id      -> Purge batch Id
--                     p_project_id          -> Project Id
--                     p_purge_release       -> The release during which it is
--                                              purged
--                     p_archive_flag        -> This flag will indicate if the
--                                              records need to be archived
--                                              before they are purged.
--                     p_assignment_id_tab   -> Assignments for which Forecast items
--                                              need to be deleted
-- End of comments


Procedure PA_FORECAST_ITEMS_PURGE ( p_purge_batch_id                 in NUMBER,
                                    p_project_id                     in NUMBER,
                                    p_purge_release                  in VARCHAR2,
                                    p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                    p_archive_flag                   in VARCHAR2,
                                    x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895


-- Start of comments
-- API name         : PA_SCHEDULES_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Purge procedure for Purging records from tables PA_Schedules, pa_schedules_history and
--                    pa_schedule_except_history tables.
-- Parameters       :
--        l            p_purge_batch_id      -> Purge batch Id
--                     p_project_id          -> Project Id
--                     p_purge_release       -> The release during which it is
--                                              purged
--                     p_archive_flag        -> This flag will indicate if the
--                                              records need to be archived
--                                              before they are purged.
--                     p_assignment_id_tab   -> Assignments for which Forecast items
--                                              need to be deleted
-- End of comments


Procedure PA_SCHEDULES_PURGE ( p_purge_batch_id                 in NUMBER,
                               p_project_id                     in NUMBER,
                               p_purge_release                  in VARCHAR2,
                               p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                               p_archive_flag                   in VARCHAR2,
                               x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895


-- Start of comments
-- API name         : PA_CANDIDATES_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from PA_CANDIDATES and PA_CANDIDATE_REVIEWS table


Procedure PA_CANDIDATES_PURGE ( p_purge_batch_id                 in NUMBER,
                                p_project_id                     in NUMBER,
                                p_purge_release                  in VARCHAR2,
                                p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                p_archive_flag                   in VARCHAR2,
                                x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

-- Start of comments
-- API name         : PA_ASSIGNMENT_CONFLICTS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from PA_ASSIGNMENT_CONFLICT_HIST  table


Procedure PA_ASSIGNMENT_CONFLICTS_PURGE ( p_purge_batch_id                 in NUMBER,
                                          p_project_id                     in NUMBER,
                                          p_purge_release                  in VARCHAR2,
                                          p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                          p_archive_flag                   in VARCHAR2,
                                          x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                          x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                          x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895



-- Start of comments
-- API name         : PA_PROJECT_ASSIGNMENT_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from PA_PROJECT_ASSIGNMENTS  table


Procedure PA_PROJECT_ASSIGNMENT_PURGE   ( p_purge_batch_id                 in NUMBER,
                                          p_project_id                     in NUMBER,
                                          p_purge_release                  in VARCHAR2,
                                          p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                          p_archive_flag                   in VARCHAR2,
                                          x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                          x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                          x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895


-- Start of comments
-- API name         : PA_PROJECT_PARTIES_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from PA_PROJECT_PARTIES table


Procedure PA_PROJECT_PARTIES_PURGE   ( p_purge_batch_id                 in NUMBER,
                                       p_project_id                     in NUMBER,
                                       p_purge_release                  in VARCHAR2,
                                       p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                       p_archive_flag                   in VARCHAR2,
                                       x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

-- Start of comments
-- API name         : PA_ADVERTISEMENTS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from Advertisements related tables:
--                             PA_ACTION_SETS,
--                             PA_ACTION_SET_LINES,
--                             PA_ACTION_SET_LINE_COND
--                             PA_ACTION_SET_LINE_AUD


Procedure PA_ADVERTISEMENTS_PURGE   ( p_purge_batch_id                 in NUMBER,
                                      p_project_id                     in NUMBER,
                                      p_purge_release                  in VARCHAR2,
                                      p_assignment_id_tab              in PA_PLSQL_DATATYPES.IdTabTyp,
                                      p_archive_flag                   in VARCHAR2,
                                      x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895


-- Start of comments
-- API name         : PA_WF_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Main purge procedure for Purging records from Workflow related tables:
-- Note             : Argument p_entity_key_tab can have the following values-
--                       pa_wf_processes.entity_key2
--                       pa_wf_process_details.object_id1.
--                       pa_wf_ntf_performers.object_id1.

PROCEDURE PA_WF_PURGE ( p_purge_batch_id                 IN NUMBER,
                        p_project_id                     IN NUMBER,
                        p_purge_release                  IN VARCHAR2,
                        p_entity_key_tab                 IN PA_PLSQL_DATATYPES.IdTabTyp,
                        p_wf_type_code                   in VARCHAR2,
                        p_item_type                      IN VARCHAR2,
                        p_archive_flag                   IN VARCHAR2,
                        x_err_stack                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_err_stage                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_err_code                       IN OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

-- Start of comments
-- API name         : PA_WF_MASS_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Procedure for Purging records from Workflow related tables for item_type 'PARMATRX':

PROCEDURE PA_WF_MASS_PURGE ( p_purge_batch_id                 IN NUMBER,
                             p_project_id                     IN NUMBER,
                             p_purge_release                  IN VARCHAR2,
                             p_object_id_tab                  IN Pa_Plsql_Datatypes.IdTabTyp,
                             p_item_type                      IN VARCHAR2,
                             p_archive_flag                   IN VARCHAR2,
                             x_err_stack                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_err_stage                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_err_code                       IN OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

-- Start of comments
-- API name         : PA_WF_MASS_ASGN_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Procedure for Purging records from Workflow related tables for item_type 'PARMAAP':

PROCEDURE PA_WF_MASS_ASGN_PURGE ( p_purge_batch_id                 IN NUMBER,
                                  p_project_id                     IN NUMBER,
                                  p_purge_release                  IN VARCHAR2,
                                  p_object_id_tab                  IN Pa_Plsql_Datatypes.IdTabTyp,
                                  p_wf_type_code                   IN VARCHAR2,
                                  p_archive_flag                   IN VARCHAR2,
                                  x_err_stack                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_err_stage                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_err_code                       IN OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

-- Start of comments
-- API name         : PA_WF_KEY_PURGE
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Procedure for Purging records from Workflow related tables where
--                    pa_wf_processes.entity_key2 does not store assignment_id

PROCEDURE PA_WF_KEY_PURGE ( p_purge_batch_id                 IN NUMBER,
                            p_project_id                     IN NUMBER,
                            p_purge_release                  IN VARCHAR2,
                            p_entity_key2                    IN VARCHAR2,
                            p_wf_type_code                   IN VARCHAR2,
                            p_item_type                      IN VARCHAR2,
                            p_archive_flag                   IN VARCHAR2,
                            x_err_stack                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_err_stage                      IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_err_code                       IN OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

END PA_PURGE_PJR_TXNS;
 

/
