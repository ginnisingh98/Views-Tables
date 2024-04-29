--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM_DMLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM_DMLS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSDMLS.pls 120.3 2005/09/27 12:00 ilawler noship $ */

   ------------
   -- Constants
   ------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- Accessor function to obtain dml-related state
   -- Invariants:
   --   State must have been initialized by a prior call to one of the execute_dml* procedures
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the currently executing DML
   -- Exceptions:
   --   If a prior call to execute_dml wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_DML_ID
      RETURN NUMBER;

   -- This API is used to get the list of unfinished DMLs for a given unit id.
   -- Invariants:
   --   None.  Low enough level that there's no safety harness to higher state.
   -- Parameters:
   --   p_unit_id         DSCRAM_UNITS.UNIT_ID of the parent unit, not obtained from state to facilitate composite unit types
   --   x_work_queue:     Work queue containing the fetched DMLs in the proper order
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE FETCH_DML_IDS(p_unit_id            IN              NUMBER,
                           x_work_queue         OUT NOCOPY      FND_OAM_DSCRAM_UNITS_PKG.ordered_work_queue_type,
                           x_return_status      OUT NOCOPY      VARCHAR2,
                           x_return_msg         OUT NOCOPY      VARCHAR2);

   -- API used when processing a DML on a range of rowids.  No autonomous transaction
   -- and no calls to AD complete procedures to avoid any implicit commits that would make it
   -- harder to use this in a composite unit.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_dml_ids:            DSCRAM_DMLS.DML_ID of DMLs to execute
   --   px_arg_context:       Argument context for execution
   --   p_rowid_lbound:       Lower Bound ROWID to process (first arg of 'between')
   --   p_rowid_ubound:       Upper Bound ROWID to process (second arg of 'between')
   --   x_rows_processed:     Reporting stat returned for use by parent in calling AD complete procedure
   --   x_return_status:      FND_API-compliant return status
   --   x_return_msg:         Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE EXECUTE_DML_ON_RANGE(p_dml_id              IN NUMBER,
                                  px_arg_context        IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                  p_rowid_lbound        IN ROWID,
                                  p_rowid_ubound        IN ROWID,
                                  x_rows_processed      OUT NOCOPY NUMBER,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_msg          OUT NOCOPY VARCHAR2);

   -- API used by UNITS_PKG.INTERNAL_EXECUTE to perform an entire (hopefully small) DML.
   -- An implicit COMPLETE_DML is called to put the metadata in sync with the data change
   -- to facilitate autonomous commits.  No commit or rollback is done here.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_dml_id:         DSCRAM_DMLS.DML_ID of DML to execute
   --   px_arg_context:   Arg context for execution
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE EXECUTE_DML(p_dml_id               IN NUMBER,
                         px_arg_context         IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         x_return_msg           OUT NOCOPY VARCHAR2);

   -- Used by complete_unit to update the writable args for a completed DML
   -- Invariants:
   --   None
   -- Parameters:
   --   p_dml_id:          DSCRAM_DMLS.DML_ID of DML to update
   --   px_arg_context:    Arg context
   --   p_using_splitting  Boolean indicating whether the args should assume we're using AD Splitting
   --   x_return_status:   FND_API-compliant return status
   --   x_return_msg:      Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE UPDATE_COMP_DML_WRITABLE_ARGS(p_dml_id             IN NUMBER,
                                           px_arg_context       IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                           p_using_splitting    IN BOOLEAN,
                                           x_return_status      OUT NOCOPY VARCHAR2,
                                           x_return_msg         OUT NOCOPY VARCHAR2);

   -- Called internally and by _UNIT procedures to mark DMLs as completed.  When executing DMLs serially,
   -- this is called after each execute to allow incremental commits.  If the DML was split, this will
   -- get called by each worker when completing the unit so that n-1 workers can submit the number of rows
   -- they processed and the last worker can also submit the the dml's finished state.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_dml_id:          DSCRAM_DMLS.DML_ID of DML to complete
   --   p_finished_ret_sts Last Execute's return status of the DML
   --   p_message          Last Execute's return msg
   --   p_workers_assigned The number of workers assigned to this DML - determines if we should just modify our local
   --                      cache or make updates to the DML tables.
   --   x_return_status:   FND_API-compliant return status
   --   x_return_msg:      Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE COMPLETE_DML(p_dml_id              IN NUMBER,
                          p_finished_ret_sts    IN VARCHAR2 DEFAULT NULL,
                          p_message             IN VARCHAR2 DEFAULT NULL,
                          p_workers_assigned    IN NUMBER   DEFAULT NULL,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_return_msg          OUT NOCOPY VARCHAR2);

   -- Removes the DML cache entry for a dml ID and cleans up all child entities
   -- such as the argument list and the DML's cursor.  If p_update_context is true,
   -- also rolls the arg list into the context.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_dml_id:          DSCRAM_DMLS.DML_ID of DML to destroy
   --   px_arg_context:    Arg context
   --   p_update_context   Boolean indicating whether the arg list should be rolled into the context
   --   x_return_status:   FND_API-compliant return status
   --   x_return_msg:      Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE DESTROY_DML_CACHE_ENTRY(p_dml_id           IN NUMBER,
                                     px_arg_context     IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                     p_update_context   IN BOOLEAN,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2);

   -- Convenience wrapper to destroy any open dmls in the cache.  This is the fallback API which
   -- is always called by complete_unit to make sure that dmls and arguments are cleaned up.  DMLs
   -- found by this API do not enjoy the privledge of rolling their values into the context.  DMLs
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
   PROCEDURE DESTROY_DML_CACHE(px_arg_context   IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_return_msg     OUT NOCOPY VARCHAR2);

END FND_OAM_DSCRAM_DMLS_PKG;

 

/
