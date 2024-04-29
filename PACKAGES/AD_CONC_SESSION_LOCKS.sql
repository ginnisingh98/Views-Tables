--------------------------------------------------------
--  DDL for Package AD_CONC_SESSION_LOCKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_CONC_SESSION_LOCKS" AUTHID CURRENT_USER as
/* $Header: adcslcks.pls 115.2 2004/02/05 15:17:06 pzanwar ship $ */
--
-- Procedure
--   get_admin_lock
--
-- Purpose
--   Lock the DB admin objects used in ad_concurrent_sessions
-- Usage
--
--
--
procedure get_admin_lock(status out nocopy number);


--
-- Procedure
--   get_admin_lock
--
-- Purpose
--   Lock the DB admin objects used in ad_concurrent_sessions with timeout
-- Usage
--
--
--
procedure get_admin_lock_with_timeout(status out nocopy number,
                                      timeout_period in integer);
--
--
--
--
-- Procedure
--   release_admin_lock
--
-- Purpose
--   Release the DB admin objects used in ad_concurrent_sessions
-- Usage
--
--
--
procedure release_admin_lock(status out nocopy number);

--
--
--
procedure  reset_session_info(sess_id in number,
                              process_id number ,
                              appltop_path in varchar2,
                              node_name in varchar2,
                              inactive_flag out nocopy varchar2,
                              p_invokdir in varchar2);
--
--
--
procedure  set_session_info(sess_id    in number  ,process_id    in number,
                            utility_nm in varchar2,appltop_id    in number,
                            priority_value in number,osuser_name in varchar2,
                            invokedir in varchar2, appltop_path in varchar2,
                            node_name in varchar2, p_topdir in varchar2);
--
--
procedure  deactivate_session_row(sess_id in number,
                                  get_lock_with_timeout in number,
                                  row_count out nocopy number);
--
--


type conflict_sessions_t is table of number index by binary_integer;


-- Procedure
--     check_compatibility_with_fifo
-- Arguments
--     1) session_id
--     2) x_conflict_session_ids - Out parameter
--                                 List of conflict session ids.
--     3) error_code             - Out parameter
--            0                  --> Success
--            BASE_ERROR + 1     --> Invalid Argument
--            BASE_ERROR + 2     --> Unhandled exception
-- Purpose
--     This procedures does compatibility checks in DB. It checks set
--     of locks requested can be acquired (together) or not. It also
--     forces FIFO algorithm amoung same priority sessions
-- Notes

procedure check_compatibility_with_fifo (session_id in number,
                                         x_conflict_session_ids out
                                         nocopy conflict_sessions_t,
                                         error_code out nocopy number);

-- Procedure
--     check_compatibility
-- Arguments
--     1) session_id
--     2) x_conflict_session_ids - Out parameter
--                                 List of conflict session ids.
--     3) error_code             - Out parameter
--            0                  --> Success
--            BASE_ERROR + 1     --> Invalid Argument
--            BASE_ERROR + 2     --> Unhandled exception
-- Purpose
--     This procedures does compatibility checks in DB. It checks set
--     of locks requested can be acquired (together) or not.
-- Notes

procedure check_compatibility  (session_id in number,
                                x_conflict_session_ids out
                                nocopy conflict_sessions_t,
                                error_code out nocopy number);

-- Procedure
--     do_deadlock_detection
-- Arguments
--     1) root_session_id
--     2) error_code          -   Out parameter
--             0              --> Success
--             BASE_ERROR + 1 --> Deadlock detected, abort (caller is
--                                the least priority process in the list
--                                of process that caused the deadlock)
--             BASE_ERROR + 2 --> Deadlock detected, continue (caller is
--                                not the least priority process)
--             BASE_ERROR + 3 --> No conflicting sessions found for root
--                                session id.
--             BASE_ERROR + 4 --> Invalid Argument
--             BASE_ERROR + 5 --> check_compatibility  failed
--             BASE_ERROR + 6 --> Reading ad_sessions failed
--             BASE_ERROR + 7 --> Unhandled exception
--             BASE_ERROR + 8 --> Logic error,tree nodes are not proper
-- Purpose
--     Deadlocks are detected in this procedure. See the various return
--     values (above) for exact functionality.
-- Notes

procedure do_deadlock_detection(root_session_id in number,
                                error_code out nocopy number);

-- Procedure
--     acquire_promote_db_locks
-- Arguments
--     1) session_id
--     2) stage_code
--     3) acquire_admin_flag  -   If this flag is set to 1,ADMIN lock is
--                                acquired at the beginning.
--                                Otherwise, it is assumed that caller
--                                has already acquired the lock.
--     4) release_admin_flag  -   If this flag is set to 1,ADMIN lock is
--                                released at the end.
--                                Otherwise, it is assumed that caller
--                                will release the lock later. (this
--                                procedure retains ADMIN lock, only if
--                                the return status is success)
--     5) error_code          -   Out parameter
--            0               --> Success
--            BASE_ERROR + 1  --> This stage is already done.
--            BASE_ERROR + 2  --> Deadlock detected, abort (caller is
--                                the least priority process in the list
--                                of processes that caused the deadlock)
--            BASE_ERROR + 3  --> Invalid argument.
--            BASE_ERROR + 4  --> Lock rows are not prestaged.
--            BASE_ERROR + 5  --> Inconsistency state (some of the lock
--                                rows have done_flag='Y' and others
--                                have done_flag='N')
--                                It shouldn't happen.
--            BASE_ERROR + 6  --> Exception,reading ad_planned_res_lock
--            BASE_ERROR + 7  --> Exception, reading ad_sessions.
--            BASE_ERROR + 8  --> Exception, inserting row in
--                                ad_working_res_locks.
--            BASE_ERROR + 9  --> Exception updating ad_sessions.
--            BASE_ERROR + 10 --> Error, do_compatibility check failed
--            BASE_ERROR + 11 --> Stage_code = 'ACQUIRE_HELD' and
--                                compatibility check -> incompatibility
--            BASE_ERROR + 12 --> Exception, updating ad_sessions,
--                                ad_working_res_locks
--            BASE_ERROR + 13 --> Exception, reading ad_sessions
--            BASE_ERROR + 14 --> Adctrl says to quit
--            BASE_ERROR + 15 --> Exception, updating ad_sessions,
--                                ad_working_res_locks
--            BASE_ERROR + 16 --> Error calling do_deadlock_detection.
--            BASE_ERROR + 17 --> Exception, updating ad_sessions.
--            BASE_ERROR + 18 --> Exception, updating ad_sessions,
--                                ad_working_res_locks
--            BASE_ERROR + 19 --> Exception, updating ad_sessions,
--                                ad_working_res_locks
--            BASE_ERROR + 20 --> Unhandled exception
--            BASE_ERROR + 21 --> Error, Current Mode = X and Requested
--                                mode = S in Promotion
--            BASE_ERROR + 22 --> Error, Locks need to be promoted is
--                                not at all held.
--            BASE_ERROR + 23 --> Error, reading ad_essions
--            BASE_ERROR + 24 --> Special return value, Acquire lock
--                                loop exhausted
--     6) warning_code        -   Out parameter
--             0              --> No warning
--             1              --> ADMIN db lock is held already by this
--                                connection. But an attempt is made to
--                                acquire once again.
--             2              --> ADMIN db lock is not at all held. But
--                                an attempt is made to release it.
--     7) error_message       -   Out parameter
--                            -   SQL errors are returned to the caller
--                                using this variable.
-- Purpose
--     This procedures acquires and promotes locks for a stage (of a
--     session_id). This API also handles a special stage "ACQUIRE_HELD"
--     differently. In this special stage, this API simply tries to
--     reacquire all already held locks.
-- Notes


procedure acquire_promote_db_locks (session_id in number,
                                    stage_code in varchar2,
                                    acquire_admin_flag in number,
                                    release_admin_flag in number,
                                    sleep_duration_in_ms in number,
                                    try_again_flag in number,
                                    error_code out nocopy number,
                                    warning_code out nocopy number,
                                    error_message out nocopy varchar2);
-- Procedure
--     release_demote_db_locks
-- Arguments
--     1) session_id
--     2) stage_code
--     3) acquire_admin_flag  -   If this flag is set to 1,ADMIN lock is
--                                acquired at the beginning.
--                                Otherwise, it is assumed that caller
--                                has already acquired the lock.
--     4) release_admin_flag  -   If this flag is set to 1,ADMIN lock is
--                                released at the end.
--                                Otherwise, it is assumed that caller
--                                will release the lock later. (this
--                                procedure retains ADMIN lock, only if
--                                the return status is success)
--     4) error_code          -   Out parameter
--            0               --> Success
--            BASE_ERROR + 1  --> This stage is already done.
--            BASE_ERROR + 2  --> Invalid argument.
--            BASE_ERROR + 3  --> Exception,reading ad_planned_res_locks
--            BASE_ERROR + 4  --> Inconsistency state (some of the lock
--                                rows have done_flag='Y' and others
--                                have done_flag='N')
--                                It shouldn't happen.
--            BASE_ERROR + 5  --> Exception,reading ad_planned_res_locks
--            BASE_ERROR + 6  --> Unhandled exception
--            BASE_ERROR + 7  --> Lock rows are not prestaged.
--            BASE_ERROR + 8  --> Data error.Demote to 'X' is not valid
--            BASE_ERROR + 9  --> Error, Locks need to be promoted is
--                                not at all held.
--     5) warning_code        -   Out parameter
--             0              --> No warning
--             1              --> ADMIN db lock is held already by this
--                                connection. But an attempt is made to
--                                acquire once again.
--             2              --> ADMIN db lock is not at all held. But
--                                an attempt is made to release it.
--     6) error_message       -   Out parameter
--                            -   SQL errors are returned to the caller
--                                using this variable.
-- Purpose
--     This procedure releases and demotes locks for a stage.
-- Notes

procedure release_demote_db_locks (session_id in number,
                                   stage_code in varchar2,
                                   acquire_admin_flag in number,
                                   release_admin_flag in number,
                                   error_code out nocopy number,
                                   warning_code out nocopy number,
                                   error_message out nocopy varchar2);


procedure set_task_completed(p_session_id        in number ,
                             p_task_id           in number ,
                             p_completion_status in varchar2,
                             p_end_stage_cd      in varchar2,
                             p_begin_stage_cd    in varchar2);


procedure mv_sessinfo_to_history(p_sess_id in number,
                                 p_complete_status in varchar2,
                                 p_error_code out nocopy number);


end ad_conc_session_locks;

 

/
