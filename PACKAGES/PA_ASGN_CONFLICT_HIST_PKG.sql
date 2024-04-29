--------------------------------------------------------
--  DDL for Package PA_ASGN_CONFLICT_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASGN_CONFLICT_HIST_PKG" AUTHID CURRENT_USER as
/* $Header: PARGASNS.pls 120.1.12000000.2 2008/08/04 12:15:01 amehrotr ship $ */

--
-- Procedure            : Insert_rows
-- Purpose              : Create Rows in PA_ASSIGNMENT_CONFLICT_HIST.
--
PROCEDURE insert_rows
      ( p_conflict_group_id                IN Number  := NULL               ,
        p_assignment_id                    IN Number                        ,
        p_conflict_assignment_id           IN Number                        ,
        p_resolve_conflict_action_code     IN VARCHAR2                      ,
        p_intra_txn_conflict_flag          IN VARCHAR2                      ,
        p_processed_flag                   IN VARCHAR2 := 'N'               ,
        p_self_conflict_flag               IN VARCHAR2                      ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : Insert_rows (Overloaded) for single transaction.
-- Purpose              : Create Rows in PA_ASSIGNMENT_CONFLICT_HIST.
--
PROCEDURE insert_rows
      ( p_conflict_group_id                IN NUMBER := NULL                ,
        p_assignment_id                    IN NUMBER                        ,
        p_conflict_assignment_id_tbl       IN PA_PLSQL_DATATYPES.NumTabTyp  ,
        p_resolve_conflict_action_code     IN VARCHAR2                      ,
        p_intra_txn_conflict_flag_tbl      IN SYSTEM.PA_VARCHAR2_1_TBL_TYPE:=NULL,
        p_processed_flag                   IN VARCHAR2 := 'N'               ,
        x_conflict_group_id                OUT NOCOPY NUMBER                       , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : update_rows (overloaded)
-- Purpose              : Update rows in pa_assignment_conflict_hist with
--                        p_resolve_conflict_action_code only. This is
--                        overloaded procedure.
--
PROCEDURE update_rows
      ( p_conflict_group_id                IN Number                        ,
        p_assignment_id                    IN Number                        ,
        p_conflict_assignment_id           IN Number                        ,
        p_resolve_conflict_action_code     IN VARCHAR2                      ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : update_rows (overloaded)
-- Purpose              : Update rows in pa_assignment_conflict_hist with
--                        p_resolve_conflict_action_code only for the whole
--                        conflict group. This is overloaded procedure. This
--                        is called from the Resource Overcommitment page.
PROCEDURE update_rows
      ( p_conflict_group_id                IN Number                        ,
        p_resolve_conflict_action_code     IN VARCHAR2                      ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : update_rows (overloaded)
-- Purpose              : Update rows in pa_assignment_conflict_hist with
--                        p_resolve_conflict_action_code only for the whole
--                        conflict group. This is overloaded procedure. This
--                        is called from the View Conflicts page.
PROCEDURE update_rows
      ( p_conflict_group_id                IN Number                        ,
        p_assignment_id_arr                IN SYSTEM.PA_NUM_TBL_TYPE              ,
        p_action_code_arr                  IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE      ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : update_rows (overloaded)
-- Purpose              : Update rows in pa_assignment_conflict_hist with
--                        p_processed_flag  only. This is an overloaded
--                        procedure.
--
PROCEDURE update_rows
      ( p_conflict_group_id                IN Number                        ,
        p_assignment_id                    IN Number                        ,
        p_processed_flag                   IN VARCHAR2                      ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : delete_rows
-- Purpose              : Deletes rows in PA_ASSIGNMENT_CONFLICT_HIST.
--
PROCEDURE delete_rows
        ( p_conflict_group_id          IN NUMBER,
          p_assignment_id              IN NUMBER,
          p_conflict_assignment_id     IN NUMBER,
          x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE delete_rows                 --bug 7118933
        ( p_assignment_id              IN NUMBER,
          x_return_status              OUT  NOCOPY VARCHAR2,
          x_msg_count                  OUT  NOCOPY NUMBER,
          x_msg_data                   OUT  NOCOPY VARCHAR2 );


END PA_ASGN_CONFLICT_HIST_PKG;

 

/
