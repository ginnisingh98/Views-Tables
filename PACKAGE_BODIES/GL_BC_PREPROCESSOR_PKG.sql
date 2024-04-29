--------------------------------------------------------
--  DDL for Package Body GL_BC_PREPROCESSOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BC_PREPROCESSOR_PKG" AS
/* $Header: glubcppb.pls 120.2 2005/05/05 01:35:23 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  --
  -- Procedure
  --   post_module_hook
  -- Purpose
  --   Hook into the funds check preprocessor for other products.
  --   This procedure is called at the last step of the preprocessor.
  --   It is called whether or not the funds check is successful.
  --   If you need to use this hook, please add a call to your own
  --   package before the return statement.  Please make sure to commit
  --   your changes in your package.
  -- Returns
  --   TRUE - upon success (causes the preprocessor to complete successfully)
  --   FALSE - upon failure (causes the preprocessor to display an error msg)
  -- History
  --   19-JUN-95  D. J. Ogg    Created
  -- Arguments
  --   sob_id           The set of books id
  --   pkt_id		The packet id
  --   je_source	The source name
  --   group_id		The group_id
  -- Example
  --   gl_bc_preprocessor_pkg.post_module_hook(2, 4, 'Other', 100, errbuf);
  -- Notes
  --
  FUNCTION post_module_hook(sob_id    IN NUMBER,
			    pkt_id    IN NUMBER,
			    je_source IN VARCHAR2,
			    group_id  IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    -- Please put your function call here.  Make it the following format:
    --    IF (NOT dummy(sob_id, pkt_id, je_source, group_id)) THEN
    --      RETURN(FALSE);
    --    END IF;

    RETURN(TRUE);
  END post_module_hook;

END gl_bc_preprocessor_pkg;

/
