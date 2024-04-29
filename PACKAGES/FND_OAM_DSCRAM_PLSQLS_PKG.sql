--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM_PLSQLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM_PLSQLS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSPLSS.pls 120.0 2005/09/27 12:45 ilawler noship $ */

   ------------
   -- Constants
   ------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- Accessor function to obtain plsql-related state
   -- Invariants:
   --   State must have been initialized by a prior call to one of the execute_plsql* procedures
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the currently executing PLSQL
   -- Exceptions:
   --   If a prior call to execute_plsql wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_PLSQL_ID
      RETURN NUMBER;

   -- This API is used to get the list of un-finished PLSQLs for a given unit id.
   -- Invariants:
   --   None.  Low enough level that there's no safety harness to higher state.
   -- Parameters:
   --   p_unit_id         DSCRAM_UNITS.UNIT_ID of the parent unit, not obtained from state to facilitate composite unit types
   --   x_work_queue:     Work queue containing plsqls found in the proper scheduling order
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE FETCH_PLSQL_IDS(p_unit_id          IN              NUMBER,
                             x_work_queue       OUT NOCOPY      FND_OAM_DSCRAM_UNITS_PKG.ordered_work_queue_type,
                             x_return_status    OUT NOCOPY      VARCHAR2,
                             x_return_msg       OUT NOCOPY      VARCHAR2);

   -- API used when processing a set of PLSQLs on a range of rowids.  No autonomous transaction
   -- and no calls to AD complete procedures to avoid any implicit commits that would make it
   -- harder to use this in a composite unit.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_plsql_ids:          DSCRAM_PLSQLS.PLSQL_ID of PLSQLs to execute
   --   px_arg_context:       Argument context for execution
   --   p_rowid_lbound:       Lower Bound ROWID to process (first arg of 'between')
   --   p_rowid_ubound:       Upper Bound ROWID to process (second arg of 'between')
   --   x_return_status:      FND_API-compliant return status
   --   x_return_msg:         Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE EXECUTE_PLSQL_ON_RANGE(p_plsql_id          IN NUMBER,
                                    px_arg_context      IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                    p_rowid_lbound      IN ROWID,
                                    p_rowid_ubound      IN ROWID,
                                    x_return_status     OUT NOCOPY VARCHAR2,
                                    x_return_msg        OUT NOCOPY VARCHAR2);

   -- API used by UNITS.EXECUTE_PLSQL_SET to perform an entire (hopefully small) PLSQL.
   -- An implicit COMPLETE_PLSQL is called to put the metadata in sync with the data change
   -- to facilitate autonomous commits.  No commit or rollback is done here.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_plsql_id:       DSCRAM_PLSQLS.PLSQL_ID of PLSQL to execute
   --   px_arg_context:   Arg context for execution
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE EXECUTE_PLSQL(p_plsql_id           IN NUMBER,
                           px_arg_context       IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                           x_return_status      OUT NOCOPY VARCHAR2,
                           x_return_msg         OUT NOCOPY VARCHAR2);

   -- Used by complete_unit to update the writable args for a completed PLSQL.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_plsql_id:        DSCRAM_PLSQLS.PLSQL_ID of PLSQL to update
   --   px_arg_context:    Arg context
   --   p_using_splitting  Boolean indicating whether the args should assume we're using AD Splitting
   --   x_return_status:   FND_API-compliant return status
   --   x_return_msg:      Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE UPDATE_COMP_PLS_WRITABLE_ARGS(p_plsql_id           IN NUMBER,
                                           px_arg_context       IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                           p_using_splitting    IN BOOLEAN,
                                           x_return_status      OUT NOCOPY VARCHAR2,
                                           x_return_msg         OUT NOCOPY VARCHAR2);

   -- Called internally and by _UNIT procedures to mark PLSQLs as completed.  When executing PLSQLs serially,
   -- this is called after each execute to allow incremental commits.  If the PLSQL was split, this won't
   -- get called until we're certain that all ranges have been completed and the last worker has succeeded.
   -- Invariants:
   --   Since workers_assigned is not provided, this call assumes it is the only and final complete call so it always
   --   updates the finished state.
   -- Parameters:
   --   p_plsql_id:        DSCRAM_PLSQLS.PLSQL_ID of PLSQL to complete
   --   p_finished_ret_sts Last Execute's return status of the PLSQL
   --   p_message          Last Execute's return msg
   --   p_workers_assigned The number of workers assigned to this PLSQL - determines if we should just modify our local
   --                      cache or make updates to the PLSQL tables.
   --   x_return_status:   FND_API-compliant return status
   --   x_return_msg:      Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE COMPLETE_PLSQL(p_plsql_id          IN NUMBER,
                            p_finished_ret_sts  IN VARCHAR2 DEFAULT NULL,
                            p_message           IN VARCHAR2 DEFAULT NULL,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_msg        OUT NOCOPY VARCHAR2);

   -- Removes the PLSQL cache entry for a plsql ID and cleans up all child entities
   -- such as the argument list and the PLSQL's cursor.  Also rolls the arg list into the arg context
   -- if p_update_context is true.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_plsql_id:        DSCRAM_PLSQLS.PLSQL_ID of DML to destroy
   --   px_arg_context:    Arg context
   --   p_update_context   Boolean indicating whether the arg list should be rolled into the context
   --   x_return_status:   FND_API-compliant return status
   --   x_return_msg:      Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE DESTROY_PLSQL_CACHE_ENTRY(p_plsql_id       IN NUMBER,
                                       px_arg_context   IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                       p_update_context IN BOOLEAN,
                                       x_return_status  OUT NOCOPY VARCHAR2,
                                       x_return_msg     OUT NOCOPY VARCHAR2);

   -- Convenience wrapper to destroy any open plsqls in the cache.  This is the fallback API which
   -- is always called by complete_unit to make sure that plsqls and arguments are cleaned up.  PLSQLs
   -- found by this API do not enjoy the privledge of rolling their values into the context.  PLSQLs
   -- must be specifically completed using the above API for that to happen.
   -- Invariants:
   --   None
   -- Parameters:
   --   px_arg_context:    Arg context
   --   x_return_status:   FND_API-compliant return status
   --   x_return_msg:      Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE DESTROY_PLSQL_CACHE(px_arg_context         IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_return_msg           OUT NOCOPY VARCHAR2);

END FND_OAM_DSCRAM_PLSQLS_PKG;

 

/
