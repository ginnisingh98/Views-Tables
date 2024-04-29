--------------------------------------------------------
--  DDL for Package GL_ENT_FUNC_BAL_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ENT_FUNC_BAL_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: gluefbus.pls 120.1 2005/05/05 01:37:53 kvora noship $ */
--
-- Package
--   gl_ent_func_bal_upgrade_pkg
-- Purpose
--   To contain routines to upgrade the balances tables and move/merge
--   interim tables to support entered functional balances.
-- History
--   03/10/2005   T Cheng      Created


  --
  -- Procedure
  --   upgrade_ent_func_bal
  -- Purpose
  --   The main routine for the concurrent request: Submits child requests
  --   to upgrade the balances tables and calls routines to upgrade
  --   move/merge interim tables.
  -- History
  --   03/10/2005   T Cheng      Created
  -- Arguments
  --   x_errbuf       Message when exiting a PL/SQL concurrent reequest
  --   x_retcode      Exit status for the concurrent request
  --   x_batchsize    Batch commit size
  --   x_num_workers  Number of workers to be used
  --
  PROCEDURE upgrade_ent_func_bal(
                  x_errbuf       OUT NOCOPY VARCHAR2,
                  x_retcode      OUT NOCOPY VARCHAR2,
                  x_batch_size              NUMBER,
                  x_num_workers             NUMBER);

  --
  -- Procedure
  --   upgrade_balance_tables
  -- Purpose
  --   Routine for the child requests that upgrade gl_balances and
  --   gl_daily_balances.
  -- History
  --   03/10/2005   T Cheng      Created
  -- Arguments
  --   x_errbuf       Message when exiting a PL/SQL concurrent reequest
  --   x_retcode      Exit status for the concurrent request
  --   x_batchsize    Batch commit size
  --   x_worker_id    ID for the worker, ranges from 1 to x_num_workers
  --   x_num_workers  Number of workers to be used
  --   x_argument4    Additional argument: gl schema
  --
  PROCEDURE upgrade_balance_tables(
                  x_errbuf       OUT NOCOPY VARCHAR2,
                  x_retcode      OUT NOCOPY VARCHAR2,
                  x_batch_size              NUMBER,
                  x_worker_Id               NUMBER,
                  x_num_workers             NUMBER,
                  x_argument4               VARCHAR2);

  --
  -- Procedure
  --   upgrade_movemerge_int_tables
  -- Purpose
  --   Routine for the child request that Upgrades the move/merge
  --   interim tables.
  -- History
  --   03/10/2005   T Cheng      Created
  -- Arguments
  --   x_errbuf         Message when exiting a PL/SQL concurrent reequest
  --   x_retcode        Exit status for the concurrent request
  --   x_gl_schema      GL schema
  --   x_applsys_schema FND schema
  --
  PROCEDURE upgrade_movemerge_int_tables(
                  x_errbuf         OUT NOCOPY VARCHAR2,
                  x_retcode        OUT NOCOPY VARCHAR2,
                  x_gl_schema                 VARCHAR2,
                  x_applsys_schema            VARCHAR2);

END GL_ENT_FUNC_BAL_UPGRADE_PKG;

 

/
