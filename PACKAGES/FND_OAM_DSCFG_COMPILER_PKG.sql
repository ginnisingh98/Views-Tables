--------------------------------------------------------
--  DDL for Package FND_OAM_DSCFG_COMPILER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCFG_COMPILER_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSCCOMPS.pls 120.2 2006/05/16 00:59:37 ilawler noship $ */

   ---------------
   -- Constants --
   ---------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- This is the primary entrypoint for kicking off a compile or re-compile of a DSCFG configuration instance.
   -- Invariants:
   --   Should only be called after a configuration instance has been created or set.
   -- Parameters:
   --   None, config_instance_id pulled from INSTANCES_PKG state.
   -- Return Statuses:
   --   None, status written to ERRORS_FOUND_FLAG/MESSAGE of failed objects
   PROCEDURE COMPILE_CONFIG_INSTANCE(x_run_id   OUT NOCOPY NUMBER);

   -- Getter for the default number of workers allowed in a bundle.
   -- Invariants:
   --   None, may be called with or without a config instance in context.
   -- Parameters:
   --   None
   -- Returns:
   --   Default number of workers allowed.
   FUNCTION GET_DEFAULT_NUM_WORKERS
      RETURN NUMBER;

   -- Getter for the default batch size used by the AD splitting architecture to divide a large table.
   -- Invariants:
   --   None, may be called with or without a config instance in context.
   -- Parameters:
   --   None
   -- Returns:
   --   Default batch size in number of rows.
   FUNCTION GET_DEFAULT_BATCH_SIZE
      RETURN NUMBER;

   -- Getter for the default interval (in seconds) between queries of parent state to check that
   -- it's still valid.
   -- Invariants:
   --   None, may be called with or without a config instance in context.
   -- Parameters:
   --   None
   -- Returns:
   --   Default valid check interval for a bundle.
   FUNCTION GET_DFLT_VALID_CHECK_INTERVAL
      RETURN NUMBER;

   -- Getter for the default minimum weight (currently in number of blocks) required for a unit to be
   -- parallelized using the AD splitting architecture.
   -- Invariants:
   --   None, may be called with or without a config instance in context.
   -- Parameters:
   --   None
   -- Returns:
   --   Default minimum parallel weight for a bundle.
   FUNCTION GET_DFLT_MIN_PARALLEL_WEIGHT
      RETURN NUMBER;

END FND_OAM_DSCFG_COMPILER_PKG;

 

/

  GRANT EXECUTE ON "APPS"."FND_OAM_DSCFG_COMPILER_PKG" TO "EM_OAM_MONITOR_ROLE";
