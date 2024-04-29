--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM_DIAG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM_DIAG_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSDIAGS.pls 120.3 2005/11/01 17:00 ilawler noship $ */

   ------------
   -- Constants
   ------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------
   -- Deletes all runs with ids in the diagnostic range, includes delete of all dependent
   -- entities by using UTILS_PKG.DELETE_RUN.
   PROCEDURE DELETE_ALL_DIAGNOSTIC_RUNS(x_verdict OUT NOCOPY VARCHAR2);

   -- Test 1: create run, bundle, task with no units, sanity check traversal
   -- of higher level entities;
   PROCEDURE EXECUTE_TEST1(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2);

   -- Test 2: create run, bundle, task, dml unit with no associated DMLs, make sure
   -- it does all the queries down to the lowest entity and finds no work so it sets
   -- all entities to processed on the way out.
   PROCEDURE EXECUTE_TEST2(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2);

   -- Test 3: creates a global arg and multiple run args, some dynamic. Since the
   -- test is in a diagnostic mode, print_arg_context is called to initialize and print
   -- all the args to the log.  Make sure the read-only dynamic args have different values
   -- for each worker and the read-write dynamic args have the same value.  Tests the
   -- different datatypes for args as well. Args get more serious, checked testing later
   -- on, this is meant as a sanity check.
   PROCEDURE EXECUTE_TEST3(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2);

   -- Test 4: creates 5 tasks, each task containing between 0 and 4 units.  Each unit
   -- has a suggested number of workers of 1 or 2.  More exacting test of the scheduling logic
   -- including handling FULL tasks.
   PROCEDURE EXECUTE_TEST4(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2);

   -- Test 5: creates a test table and a simple update DML which is forced to
   -- execute serially.  No input arguments, but sql output
   -- arguments are used to check the results of the update.
   PROCEDURE EXECUTE_TEST5(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2);

   -- Test 6: creates a test table and a simple update DML which is forced to
   -- execute using ranges.  No input arguments, but output arguments are used
   -- to check the results of the update dml per range along with outputs to fetch the c2 sum
   -- at the end and roll that into a run context arg.
   PROCEDURE EXECUTE_TEST6(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2);

   -- Test 7: creates a test table and executes 2 DML statements, a delete of
   -- all the odd numbered rows and an update of the remaining rows to have
   -- c2 = c2 + c1 + ARG(val=3).  Final C2 sum should be ((N*(N+2))/4 + 2N).
   -- Also updates c3 to an ARG-sourced static string, c4 to an ARG-sourced static date. C3's value
   -- is sourced from a readable run context arg executed on a range.
   PROCEDURE EXECUTE_TEST7(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2);

   -- Test 8: Creates a single run/bundle/task/unit with a plsql (TEST8_PROC1) that runs serially and requires
   -- args with all the state args.  The procedure returns a single FND_API flag for success/failure
   -- into an argument which is checked on execute completion. Tests serial pl/sql unit execution.
   PROCEDURE EXECUTE_TEST8(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2);

   -- Procedure used by TEST8 to validate unsplit PLSQL execution and the STATE-typed arguments.  Performes
   -- queries on the runtime datamodel to verify that the values provided are consistent with each other.
   PROCEDURE TEST8_PROC1(p_run_id               IN NUMBER,
                         p_run_mode             IN VARCHAR2,
                         p_bundle_id            IN NUMBER,
                         p_bundle_workers_allowed       IN NUMBER,
                         p_bundle_batch_size    IN NUMBER,
                         p_worker_id            IN NUMBER,
                         p_task_id              IN NUMBER,
                         p_unit_id              IN NUMBER,
                         p_using_splitting      IN VARCHAR2,
                         p_rowid_lbound         IN ROWID,
                         p_rowid_ubound         IN ROWID,
                         p_unit_object_owner    IN VARCHAR2,
                         p_unit_object_name     IN VARCHAR2,
                         p_unit_workers_allowed IN NUMBER,
                         p_unit_batch_size      IN NUMBER,
                         p_plsql_id             IN NUMBER,
                         p_arg_id               IN NUMBER,
                         p_workers_allowed      IN NUMBER,
                         p_batch_size           IN NUMBER,
                         x_verdict              OUT NOCOPY VARCHAR2,
                         x_return_msg           OUT NOCOPY VARCHAR2);

   -- Test 9: Creates a run/bundle/task/unit with a plsql (TEST9_PROC1) in phase 1 that uses
   -- splitting to modify a table.  Also creates a second unit without a phase
   -- under the same task which is a DML that uses an arg context value set by the plsql to
   -- test dependency handling and pl/sql splitting.
   PROCEDURE EXECUTE_TEST9(p_run_id             IN NUMBER DEFAULT 1,
                           p_bundle_id          IN NUMBER DEFAULT 1,
                           p_num_bundles        IN NUMBER DEFAULT 1,
                           p_num_workers        IN NUMBER DEFAULT 1,
                           x_verdict            OUT NOCOPY VARCHAR2);

   -- Procedure used by TEST9 to modify a test table.
   PROCEDURE TEST9_PROC1(p_using_splitting      IN VARCHAR2,
                         p_rowid_lbound         IN ROWID,
                         p_rowid_ubound         IN ROWID,
                         p_unit_object_owner    IN VARCHAR2,
                         p_unit_object_name     IN VARCHAR2,
                         x_verdict              OUT NOCOPY VARCHAR2,
                         x_return_msg           OUT NOCOPY VARCHAR2);

   -- Test 10: Creates a single run/bundle/task with a single concurrent meta-unit.  This
   -- meta-unit has 3 child units, 2 PLSQLs and a DML unit.  Each child unit has 2 operations
   -- with different priorities, weights.  The goal is to test all parts of the concurrent
   -- meta-unit processing by providing a test case where each range should execute the work
   -- items in the order 3.2, 3.1, 2.2, 1.1, 1.2, 2.1.  Each work item modifies C2 in such a
   -- way that the final sum must be a certain value.  Also tests a SQL_RESTRICTABLE argument
   -- that also uses STATE-provided rowids to check consistency.
   PROCEDURE EXECUTE_TEST10(p_run_id            IN NUMBER DEFAULT 1,
                            p_bundle_id         IN NUMBER DEFAULT 1,
                            p_num_bundles       IN NUMBER DEFAULT 1,
                            p_num_workers       IN NUMBER DEFAULT 1,
                            x_verdict           OUT NOCOPY VARCHAR2);

   -- Procedure used by TEST10
   PROCEDURE TEST10_PROC1_1(p_using_splitting           IN VARCHAR2,
                            p_rowid_lbound              IN ROWID,
                            p_rowid_ubound              IN ROWID,
                            p_unit_object_owner         IN VARCHAR2,
                            p_unit_object_name          IN VARCHAR2);

   -- Procedure used by TEST10
   PROCEDURE TEST10_PROC1_2(p_using_splitting           IN VARCHAR2,
                            p_rowid_lbound              IN ROWID,
                            p_rowid_ubound              IN ROWID,
                            p_unit_object_owner         IN VARCHAR2,
                            p_unit_object_name          IN VARCHAR2);

   -- Function used by TEST10
   FUNCTION TEST10_FUNC2_2(p_using_splitting            IN VARCHAR2,
                           p_rowid_lbound               IN ROWID,
                           p_rowid_ubound               IN ROWID,
                           p_unit_object_owner          IN VARCHAR2,
                           p_unit_object_name           IN VARCHAR2)
      RETURN NUMBER;

   -- Procedure used by TEST10
   PROCEDURE TEST10_PROC3_1(p_using_splitting           IN VARCHAR2,
                            p_rowid_lbound              IN ROWID,
                            p_rowid_ubound              IN ROWID,
                            p_unit_object_owner         IN VARCHAR2,
                            p_unit_object_name          IN VARCHAR2);

   -- Procedure used by TEST10
   PROCEDURE TEST10_PROC3_2(p_using_splitting           IN VARCHAR2,
                            p_rowid_lbound              IN ROWID,
                            p_rowid_ubound              IN ROWID,
                            p_unit_object_owner         IN VARCHAR2,
                            p_unit_object_name          IN VARCHAR2);

   --Execute all configured tests
   PROCEDURE EXECUTE_ALL_TESTS(p_run_id                         IN NUMBER DEFAULT 1,
                               p_bundle_id                      IN NUMBER DEFAULT 1,
                               p_num_bundles                    IN NUMBER DEFAULT 1,
                               p_num_workers                    IN NUMBER DEFAULT 1,
                               p_fail_fast                      IN VARCHAR2 DEFAULT NULL,
                               p_execute_real_table_tests       IN VARCHAR2 DEFAULT NULL,
                               x_verdict                        OUT NOCOPY VARCHAR2);

END FND_OAM_DSCRAM_DIAG_PKG;

 

/
