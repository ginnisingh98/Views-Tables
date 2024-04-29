--------------------------------------------------------
--  DDL for Package GL_ADD_RECON_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ADD_RECON_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: glurcnus.pls 120.1 2005/09/30 22:56:17 djogg noship $ */
--
-- Package
--   gl_add_recon_upgrade_pkg
-- Purpose
--   To add rows into gl_je_lines_recon from lines in
--   gl_je_lines.
-- History
--   08/26/2005   V Treiger      Created

  --
  -- Procedure
  --   upgrade_recon
  -- Purpose
  --   The main routine for the concurrent request: Submits child requests
  --   to upgrade the gl_je_lines_recon table.
  --
  -- History
  --   08/26/2005   V Treiger      Created
  -- Arguments
  --   x_errbuf       Message when exiting a PL/SQL concurrent reequest
  --   x_retcode      Exit status for the concurrent request
  --   x_batchsize    Batch commit size
  --   x_num_workers  Number of workers to be used
  --
  PROCEDURE upgrade_recon(
                  x_errbuf       OUT NOCOPY VARCHAR2,
                  x_retcode      OUT NOCOPY VARCHAR2,
                  x_batch_size              NUMBER,
                  x_num_workers             NUMBER);

  --
  -- Procedure
  --   update_gl_je_lines_recon_table
  -- Purpose
  --   Routine to add rows into gl_je_lines_recon from lines in
  --   gl_je_lines.
  -- History
  --   08/26/2005   V Treiger      Created
  -- Arguments
  --   x_errbuf       Message when exiting a PL/SQL concurrent reequest
  --   x_retcode      Exit status for the concurrent request
  --   x_batchsize    Batch commit size
  --   x_worker_id    ID for the worker, ranges from 1 to x_num_workers
  --   x_num_workers  Number of workers to be used
  --   x_argument4    Additional argument: gl schema
  --
  PROCEDURE update_gl_je_lines_recon_table(
                  x_errbuf       OUT NOCOPY VARCHAR2,
                  x_retcode      OUT NOCOPY VARCHAR2,
                  x_batch_size              NUMBER,
                  x_worker_Id               NUMBER,
                  x_num_workers             NUMBER,
                  x_argument4               VARCHAR2);

END GL_ADD_RECON_UPGRADE_PKG;

 

/
