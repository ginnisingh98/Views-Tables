--------------------------------------------------------
--  DDL for Package GL_MOVEMERGE_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_MOVEMERGE_HOOK_PKG" AUTHID CURRENT_USER AS
/* $Header: glummhks.pls 120.3 2005/05/05 01:40:55 kvora ship $ */
--
-- Package
--   gl_movemerge_hook_pkg
-- Purpose
--
-- History
--   02-MAY-97  	W. Wong		Created

  --
  -- Function
  --   pre_validation_hook
  -- Purpose
  --   If you need to use this hook, please add a call to your own
  --   package before the return statement.  Please do NOT commit
  --   your changes in your package.
  -- Returns
  --   TRUE - upon success (allows Move/Merge to continue)
  --   FALSE - upon failure (causes Move/Merge to abort and display the
  --			     error in errbuf)
  -- History
  --   02-MAY-97  W.Wong    Created
  -- Arguments
  --   mm_req_id        Move/Merge request id
  --   mm_mode		Move/Merge mode
  --   event            Event calling pre-validation hook
  --   errbuf           Buffer to hold error message
  -- Example
  --   gl_movemerge_hook_pkg.pre_validation_hook(2, M, PRE_CC_CREATION,errbuf);
  -- Notes
  --
  FUNCTION pre_validation_hook(mm_req_id    IN     NUMBER,
			       mm_mode      IN     VARCHAR2,
	                       event        IN     VARCHAR2,
	                       errbuf       IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

END gl_movemerge_hook_pkg;

 

/
