--------------------------------------------------------
--  DDL for Package Body GL_MOVEMERGE_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_MOVEMERGE_HOOK_PKG" AS
/* $Header: glummhkb.pls 120.3 2005/05/05 01:40:49 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  --
  -- FUNCTION
  --   pre_validation_hook
  -- Purpose
  --   This procedure is called before or after the creation of any
  --   new code combinations depending on the 'event' that was passed in.
  --   If you need to use this hook, please add a call to your own
  --   package before the return statement.  Please do NOT commit
  --   your changes in your package.
  -- Returns
  --   TRUE - upon success (allows Move/Merge to continue)
  --   FALSE - upon failure (causes Move/Merge to abort and display the
  --			     error in errbuf)
  -- History
  --   02-MAY-97  W. Wong	Created
  -- Arguments
  --   mm_req_id        Move/Merge request id
  --   mm_mode		Mode of the Move/Merge program
  --   event		PRE_CC_CREATION or POST_CC_CREATION
  --   errbuf           Buffer to hold error message
  -- Example
  --   gl_movemerge_hook_pkg.pre_validation_hook(2, 100, errbuf);
  -- Notes
  --
  FUNCTION pre_validation_hook(mm_req_id IN     NUMBER,
			       mm_mode   IN     VARCHAR2,
			       event     IN     VARCHAR2,
	                       errbuf    IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    -- Please put your function call here.  Make it the following format:
    --    IF (NOT dummy(mm_req_id, mode, event, errbuf)) THEN
    --      RETURN(FALSE);
    --    END IF;

    RETURN( TRUE );
  END pre_validation_hook;

END gl_movemerge_hook_pkg;

/
