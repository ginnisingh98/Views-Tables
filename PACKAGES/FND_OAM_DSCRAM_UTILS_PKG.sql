--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSUTILS.pls 120.6 2006/05/16 01:31:35 ilawler noship $ */

   ------------
   -- Constants
   ------------

   --prefix used for all global objects
   G_DSCRAM_GLOBAL_PREFIX       CONSTANT VARCHAR2(30) := 'FND_OAM_DSCRAM__';

   -- Object types used in _STATS as the source_object_type
   G_MODE_NORMAL        CONSTANT VARCHAR2(30) := 'NORMAL';       --real run, do work
   G_MODE_TEST          CONSTANT VARCHAR2(30) := 'TEST';         --real run, just test, only ok if no side effects
   G_MODE_TEST_NO_EXEC  CONSTANT VARCHAR2(30) := 'TEST_NO_EXEC'; --real run, test prep but don't do physical DMLs/PLSQLs
   G_MODE_DIAGNOSTIC    CONSTANT VARCHAR2(30) := 'DIAGNOSTIC';   --diagnostic run

   -- Object types used in _STATS as the source_object_type
   G_TYPE_GLOBAL        CONSTANT VARCHAR2(30) := 'GLOBAL';
   G_TYPE_RUN           CONSTANT VARCHAR2(30) := 'RUN';
   G_TYPE_BUNDLE        CONSTANT VARCHAR2(30) := 'BUNDLE';
   G_TYPE_TASK          CONSTANT VARCHAR2(30) := 'TASK';
   G_TYPE_UNIT          CONSTANT VARCHAR2(30) := 'UNIT';
   G_TYPE_DML           CONSTANT VARCHAR2(30) := 'DML';
   G_TYPE_PLSQL         CONSTANT VARCHAR2(30) := 'PLSQL';
   G_TYPE_WORKER        CONSTANT VARCHAR2(30) := 'WORKER'; --used by arg_values
   G_TYPE_RANGE         CONSTANT VARCHAR2(30) := 'RANGE';  --used by arg_values

   -- Unit Types
   G_UNIT_TYPE_CONC_GROUP       CONSTANT VARCHAR2(30) := 'CONC_GROUP';
   G_UNIT_TYPE_DML_SET          CONSTANT VARCHAR2(30) := 'DML_SET';
   G_UNIT_TYPE_PLSQL_SET        CONSTANT VARCHAR2(30) := 'PLSQL_SET';

   -- Entity Statuses: for run, bundle, task, task unit
   G_STATUS_UNPROCESSED         CONSTANT VARCHAR2(30) := 'UNPROCESSED';
   G_STATUS_PROCESSING          CONSTANT VARCHAR2(30) := 'PROCESSING';
   G_STATUS_FINISHING           CONSTANT VARCHAR2(30) := 'FINISHING';
   G_STATUS_PROCESSED           CONSTANT VARCHAR2(30) := 'PROCESSED';
   G_STATUS_STOPPING            CONSTANT VARCHAR2(30) := 'STOPPING';            --Run and Bundle only before being set to STOPPED
   G_STATUS_STOPPED             CONSTANT VARCHAR2(30) := 'STOPPED';
   G_STATUS_SKIPPED             CONSTANT VARCHAR2(30) := 'SKIPPED';
   G_STATUS_RESTARTABLE         CONSTANT VARCHAR2(30) := 'RESTARTABLE';
   G_STATUS_ERROR_FATAL         CONSTANT VARCHAR2(30) := 'ERROR_FATAL';
   G_STATUS_ERROR_UNKNOWN       CONSTANT VARCHAR2(30) := 'ERROR_UNKNOWN';
   G_STATUS_NO_STATUS           CONSTANT VARCHAR2(30) := 'NO_STATUS';           --Child units, we need a dummy value that doesn't get updated

   -- Custom Return Statuses: used by execute, validate, fetch APIs of run/bundle/task/unit to augment standard FND return statuses
   G_RET_STS_EMPTY      CONSTANT VARCHAR2(6) := FND_API.G_RET_STS_ERROR||'E'; --returned by calls to fetch: task, unit
   G_RET_STS_FULL       CONSTANT VARCHAR2(6) := FND_API.G_RET_STS_ERROR||'F'; --returned by calls to fetch: unit||assign: bundle, unit
   G_RET_STS_STOPPED    CONSTANT VARCHAR2(6) := FND_API.G_RET_STS_ERROR||'S'; --returned by calls to fetch: task||execute: run, bundle
   G_RET_STS_SKIPPED    CONSTANT VARCHAR2(6) := FND_API.G_RET_STS_ERROR||'K'; --returned by calls to validate_start: task
   G_RET_STS_PROCESSED  CONSTANT VARCHAR2(6) := FND_API.G_RET_STS_ERROR||'P'; --returned by calls to execute: run, bundle
   G_RET_STS_ERROR_FATAL CONSTANT VARCHAR2(6) := FND_API.G_RET_STS_ERROR||'Z'; --returned by calls to execute:
   G_RET_STS_ERROR_UNKNOWN CONSTANT VARCHAR2(6) := FND_API.G_RET_STS_ERROR||'U'; --returned by calls to execute:
   G_RET_STS_MISSING_BINDS CONSTANT VARCHAR2(6) := FND_API.G_RET_STS_ERROR||'B'; --returned by calls to arg.get_value and its variants
   G_RET_STS_MISSING_STATE CONSTANT VARCHAR2(6) := FND_API.G_RET_STS_ERROR||'C'; --returned by calls to arg.get_value and its variants

   -- Argument Source Types
   G_SOURCE_CONSTANT              CONSTANT VARCHAR2(30) := 'CONSTANT';                  --source_text is a flat value
   G_SOURCE_STATE                 CONSTANT VARCHAR2(30) := 'STATE';                     --source_text is the name of a state key
   G_SOURCE_EXECUTION_CURSOR      CONSTANT VARCHAR2(30) := 'EXECUTION_CURSOR';          --source_text is ignored, fetch value using bind var with arg_name
                                                                                        --from the just executed cursor.
   G_SOURCE_SQL                   CONSTANT VARCHAR2(30) := 'SQL';                       --source_text is a sql requiring no binds or clauses
   G_SOURCE_SQL_RESTRICTABLE      CONSTANT VARCHAR2(30) := 'SQL_RESTRICTABLE';          --source_text is a sql that allows the ROWID_CLAUSE to be appended
                                                                                        --when splitting

   -- Argument Permissions
   G_PERMISSION_READ       CONSTANT VARCHAR2(30) := 'READ';
   G_PERMISSION_READ_WRITE CONSTANT VARCHAR2(30) := 'READ_WRITE';
   G_PERMISSION_WRITE      CONSTANT VARCHAR2(30) := 'WRITE';

   -- Argument Write Policies
   G_WRITE_POLICY_ONCE          CONSTANT VARCHAR2(30) := 'ONCE';
   G_WRITE_POLICY_PER_WORKER    CONSTANT VARCHAR2(30) := 'PER_WORKER';
   G_WRITE_POLICY_PER_RANGE     CONSTANT VARCHAR2(30) := 'PER_RANGE';
   G_WRITE_POLICY_ALWAYS        CONSTANT VARCHAR2(30) := 'ALWAYS';

   -- Argument Supported Datatypes
   G_DATATYPE_VARCHAR2  CONSTANT VARCHAR2(30) := 'VARCHAR2';
   G_DATATYPE_NUMBER    CONSTANT VARCHAR2(30) := 'NUMBER';
   G_DATATYPE_DATE      CONSTANT VARCHAR2(30) := 'DATE';
   --G_DATATYPE_BOOLEAN CONSTANT VARCHAR2(30) := 'BOOLEAN'; --not a supported SQL type, could store but couldn't query/bind
   G_DATATYPE_ROWID     CONSTANT VARCHAR2(30) := 'ROWID';

   -- Constants used for binding rowid ranges
   G_ARG_INTERNAL_PREFIX        CONSTANT VARCHAR2(30) := 'DS__';
   G_ARG_ROWID_LBOUND_NAME      CONSTANT VARCHAR2(30) := G_ARG_INTERNAL_PREFIX||'ROWID_LBOUND';
   G_ARG_ROWID_UBOUND_NAME      CONSTANT VARCHAR2(30) := G_ARG_INTERNAL_PREFIX||'ROWID_UBOUND';

   -- Prefix and Suffix prepended and appended to plsql procedures to make them compliant with dbms_sql
   G_PLSQL_PREFIX               CONSTANT VARCHAR2(60) := 'BEGIN ';
   G_PLSQL_SUFFIX               CONSTANT VARCHAR2(60) := 'END;';

   -- Constants representing the various, supported argument state keys
   G_KEY_RUN_ID                 CONSTANT VARCHAR2(30) := 'RUN_ID';
   G_KEY_RUN_MODE               CONSTANT VARCHAR2(30) := 'RUN_MODE';
   G_KEY_BUNDLE_ID              CONSTANT VARCHAR2(30) := 'BUNDLE_ID';
   G_KEY_BUNDLE_WORKERS_ALLOWED CONSTANT VARCHAR2(30) := 'BUNDLE_WORKERS_ALLOWED';
   G_KEY_BUNDLE_BATCH_SIZE      CONSTANT VARCHAR2(30) := 'BUNDLE_BATCH_SIZE';
   G_KEY_WORKER_ID              CONSTANT VARCHAR2(30) := 'WORKER_ID';
   G_KEY_TASK_ID                CONSTANT VARCHAR2(30) := 'TASK_ID';
   G_KEY_UNIT_ID                CONSTANT VARCHAR2(30) := 'UNIT_ID';
   G_KEY_USING_SPLITTING        CONSTANT VARCHAR2(30) := 'USING_SPLITTING';
   G_KEY_ROWID_LBOUND           CONSTANT VARCHAR2(30) := 'ROWID_LBOUND';
   G_KEY_ROWID_UBOUND           CONSTANT VARCHAR2(30) := 'ROWID_UBOUND';
   G_KEY_UNIT_OBJECT_OWNER      CONSTANT VARCHAR2(30) := 'UNIT_OBJECT_OWNER';
   G_KEY_UNIT_OBJECT_NAME       CONSTANT VARCHAR2(30) := 'UNIT_OBJECT_NAME';
   G_KEY_UNIT_WORKERS_ALLOWED   CONSTANT VARCHAR2(30) := 'UNIT_WORKERS_ALLOWED';
   G_KEY_UNIT_BATCH_SIZE        CONSTANT VARCHAR2(30) := 'UNIT_BATCH_SIZE';
   G_KEY_DML_ID                 CONSTANT VARCHAR2(30) := 'DML_ID';
   G_KEY_PLSQL_ID               CONSTANT VARCHAR2(30) := 'PLSQL_ID';
   G_KEY_ARGUMENT_ID            CONSTANT VARCHAR2(30) := 'ARGUMENT_ID';
   G_KEY_WORKERS_ALLOWED        CONSTANT VARCHAR2(30) := 'WORKERS_ALLOWED'; --unit's workers allowed or bundle's if null
   G_KEY_BATCH_SIZE             CONSTANT VARCHAR2(30) := 'BATCH_SIZE';      --unit's batch size or bundle's if null

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- When a VALIDATE_START_EXECUTION procedure sees a non-normal status, it uses this to reduce it to
   -- a return status code for the procedure.
   FUNCTION CONV_VALIDATE_START_STS_TO_RET(p_status IN VARCHAR2)
      RETURN VARCHAR2;

   -- When a VALIDATE_CONTINUED_EXECUTION procedure sees a non-normal status, it uses this to reduce it to
   -- a return status code for the procedure.
   FUNCTION CONV_VALIDATE_CONT_STS_TO_RET(p_status IN VARCHAR2)
      RETURN VARCHAR2;

   -- Used to convert one of the many possible return status codes into a full custom status for storage in the DB.
   FUNCTION CONV_RET_STS_TO_COMPL_STATUS(p_ret_sts IN VARCHAR2)
      RETURN VARCHAR2;

   -- Check if the entity is in a state which can be executed
   FUNCTION STATUS_IS_EXECUTABLE(p_status IN VARCHAR2)
      RETURN BOOLEAN;

   -- See if the unit is in progress, this includes the finishing status.
   FUNCTION STATUS_IS_PROCESSING(p_status IN VARCHAR2)
      RETURN BOOLEAN;

   -- Tell us when the status is an end state, that is a state that can't be changed by another worker.
   FUNCTION STATUS_IS_FINAL(p_status IN VARCHAR2)
      RETURN BOOLEAN;

   -- See if the entity's status is in one of the few possible error statuses
   FUNCTION STATUS_IS_ERROR(p_status IN VARCHAR2)
      RETURN BOOLEAN;

   -- See if the return_status code is an error status
   FUNCTION RET_STS_IS_ERROR(p_ret_sts IN VARCHAR2)
      RETURN BOOLEAN;

   -- When a worker is completing its work on an entity, certain
   -- transitions in status should be supressed like Stopping->Processed. This procedure
   -- brokers these transactions by converting proposed statuses/return status codes into
   -- final statuses/return status codes to keep the state transitions valid for our
   -- scheduling(run/bundle/task/unit) entities.
   PROCEDURE TRANSLATE_COMPLETED_STATUS(p_current_status        IN VARCHAR2,
                                        p_workers_assigned      IN NUMBER,
                                        p_proposed_status       IN VARCHAR2,
                                        p_proposed_ret_sts      IN VARCHAR2,
                                        x_final_status          OUT NOCOPY VARCHAR2,
                                        x_final_ret_sts         OUT NOCOPY VARCHAR2);

   -- To detect asynchronous stops and fatally errored work, we make use of periodic status
   -- checks.  This function determines if its time for one of those checks.
   FUNCTION VALIDATION_DUE(p_last_validated     IN DATE)
      RETURN BOOLEAN;

   -- Similar to fnd_api.to_boolean but without the raise and fnd_msg call.  Null becomes false.
   FUNCTION FLAG_TO_BOOLEAN(p_flag      IN VARCHAR2)
      RETURN BOOLEAN;

   -- Inverse of FLAG_TO_BOOLEAN
   FUNCTION BOOLEAN_TO_FLAG(p_bool      IN BOOLEAN)
      RETURN VARCHAR2;

   -- Currently used by UNITS_PKG to stop a parent object, task/bundle/run when an error occurs
   -- in a unit with a fatality_level set.  This method is here to facilitate propogation
   -- if other entities support the fatality level concept.
   PROCEDURE PROPOGATE_FATALITY_LEVEL(p_fatality_level  IN VARCHAR2);

   -- Used as part of the primary key when initializing the AD infrastructure.  The key is
   -- composed of a prefix, the run id and the unit id.
   FUNCTION MAKE_AD_SCRIPT_KEY(p_run_id         IN NUMBER,
                               p_unit_id        IN NUMBER)
      RETURN VARCHAR2;

   --Wrapper for above, assumes run_id from run_pkg state
   FUNCTION MAKE_AD_SCRIPT_KEY(p_unit_id        IN NUMBER)
      RETURN VARCHAR2;

   -- Used to lock a run independent of whether it exists yet or not.  Allocates a handle and uses
   -- dbms_lock to control contention.
   FUNCTION LOCK_RUN(p_run_id           IN NUMBER,
                     x_lock_handle      OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN;

   -- Used to lock an argument independent of the arg's write location and the transaction's status.
   -- Also uses DBMS_LOCK.
   FUNCTION LOCK_ARG(p_arg_id           IN NUMBER,
                     x_lock_handle      OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN;

   -- Used to delete a run and all of its sub-entites down to and including AD entities.  Should
   -- be consumed with care.
   FUNCTION DELETE_RUN(p_run_id         IN NUMBER)
      RETURN BOOLEAN;

   --used as a common predicate for determining whether we should proceed normally and commit results
   FUNCTION RUN_IS_NORMAL
      RETURN BOOLEAN;

   --used as a common predicate for determining whether diagnostic actions should
   --be taken.  In diagnostic modes, some warnings become errors and there are more prints.
   FUNCTION RUN_IS_DIAGNOSTIC
      RETURN BOOLEAN;

   -- checks if an arg's source type is sql-based so it can set up the cursor
   FUNCTION SOURCE_TYPE_USES_SQL(p_source_type IN VARCHAR2)
      RETURN BOOLEAN;

   -- Used by the DML prep and ARG init to create the final statement which may or may not
   -- append the rowid_clause depending on whether they're using AD splitting.
   PROCEDURE MAKE_FINAL_SQL_STMT(px_arg_context         IN FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                 p_stmt                 IN VARCHAR2,
                                 p_where_clause         IN VARCHAR2,
                                 p_use_splitting        IN BOOLEAN,
                                 x_final_stmt           OUT NOCOPY VARCHAR2,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_return_msg           OUT NOCOPY VARCHAR2);

   -- Used by the BUNDLES_PKG to block when there are no available tasks until a unit has been
   -- finished by another worker signaling progress
   PROCEDURE WAIT_FOR_PROGRESS_ALERT;

   -- Used by the UNITS_PKG to signal a progress alert whenever a unit finishes.
   PROCEDURE SIGNAL_PROGRESS_ALERT;

   -- Alerts need a commit to be sent, this is a convenience method to force send a signal.
   PROCEDURE SIGNAL_AUT_PROGRESS_ALERT;

   -- This procedure prepares to retry a run by updating its status to RESTARTABLE.  It can also optionally
   -- prepare its children. Throws exceptions on error.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_run_id:               The run ID to prepare
   --   p_recurse_children:     FND_API.G_TRUE/G_FALSE indicating whether to recurse and prepare child entities.
   PROCEDURE PREPARE_RUN_FOR_RETRY(p_run_id             IN NUMBER,
                                   p_recurse_children   IN VARCHAR2 DEFAULT NULL);

END FND_OAM_DSCRAM_UTILS_PKG;

 

/
