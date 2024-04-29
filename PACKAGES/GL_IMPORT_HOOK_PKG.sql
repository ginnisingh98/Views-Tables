--------------------------------------------------------
--  DDL for Package GL_IMPORT_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_IMPORT_HOOK_PKG" AUTHID CURRENT_USER AS
/* $Header: glujihks.pls 120.4 2005/05/05 01:40:01 kvora ship $ */
--
-- Package
--   gl_import_hook_pkg
-- Purpose
--   Handles hooks into the funds check preprocessor from other products
-- History
--   19-JUN-95  	D. J. Ogg	Created
--   28-FEB-00          D. J. Ogg       Added post_module_hook

  --
  -- Procedure
  --   pre_module_hook
  -- Purpose
  --   Hook into journal import for other products.
  --   This procedure is called after journal import has selected
  --   the sources to process, but before it has started processing the data.
  --   If you need to use this hook, please add a call to your own
  --   package before the return statement.  Please do NOT commit
  --   your changes in your package.
  -- Returns
  --   TRUE - upon success (allows journal import to continue)
  --   FALSE - upon failure (causes journal import to abort and display the
  --			     error in errbuf)
  -- History
  --   19-JUN-95  D. J. Ogg    Created
  -- Arguments
  --   run_id		The import run id
  --   errbuf		The error message printed upon error
  -- Example
  --   gl_import_hook_pkg.pre_module_hook(2, 100, errbuf);
  -- Notes
  --
  FUNCTION pre_module_hook(run_id    IN     NUMBER,
			   errbuf    IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

  --
  -- Procedure
  --   post_module_hook
  -- Purpose
  --   Hook into journal import for other products.
  --   This procedure is called after journal import has inserted all of the
  --   data into gl_je_batches, gl_je_headers, and gl_je_lines, but before
  --   it does the final commit.
  --   This routine is called once per 100 batches.
  --   If you need to use this hook, please add a call to your own
  --   package before the return statement.  Please do NOT commit
  --   your changes in your package.
  -- Returns
  --   TRUE - upon success (allows journal import to continue)
  --   FALSE - upon failure (causes journal import to abort and display the
  --			     error in errbuf)
  -- History
  --   28-FEB-00  D. J. Ogg    Created
  -- Arguments
  --   batch_ids        A list of batch ids, separated by the separator
  --   separator        The separator
  --   last_set         Indicates whether or not this is the last set
  --   errbuf		The error message printed upon error
  -- Example
  --   gl_import_hook_pkg.post_module_hook(2, 100, errbuf);
  -- Notes
  --
  FUNCTION post_module_hook(batch_ids  IN     VARCHAR2,
                            separator  IN     VARCHAR2,
                            last_set   IN     BOOLEAN,
			    errbuf     IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

END gl_import_hook_pkg;

 

/
