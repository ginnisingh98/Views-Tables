--------------------------------------------------------
--  DDL for Package JTF_AMVIMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AMVIMT_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpimts.pls 115.8 2002/11/26 22:30:19 stopiwal ship $ */
-- NAME
--   jtfpimts.pls
--
-- DESCRIPTION
--   Package specifications for JTF_AMVIMT_PUB in support of rebuilding iMT
--   indexes on JTF ITEM tables jtf_amv_items_b and _tl.
--   Expected use of this package is either through Apps Concurrent Manager
--
-- NOTES
--
-- HISTORY
--   12/14/99	J Ray		Created.
--   02/15/00	slkrishn		Created.
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Optimize_JTF_IMT_Indexes
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an iMT Optimize on all indexes across
--                 all JTF iMT-indexed columns in a time-distributed fashion.
--    Parameters :
--
--    IN         : p_optimize_level                    IN  VARCHAR2    Optional
--                   Specifies the type of iMT index optimization to perform.
--                   Valid values are 'FAST','FULL', ctx_ddl.optlevel_fast or
--                   ctx_ddl.optlevel_full.
--
--                   Default is ctx_ddl.optlevel_full.
--
--               : p_runtime                           IN  NUMBER      Optional
--                   Integer that indicates the total run-time (in seconds) of
--                   this optimization function call.  This time will be
--                   divided equally amongst all indexes within the JTF
--                   subsystem.  A null value implies execution until
--                   completion of the task.
--
--                   Default is ctx_ddl.maxtime_unlimited.
--
--
--    Version    : Current version     1.0
--                    {add comments here}
--                 Previous version    1.0
--                 Initial version     1.0
--
-- End of comments
--


PROCEDURE Optimize_JTF_IMT_Indexes
          (ERRBUF				 OUT NOCOPY VARCHAR2,
		 RETCODE				 OUT NOCOPY NUMBER,
		 p_optimize_level         IN  VARCHAR2 := ctx_ddl.optlevel_full,
           p_runtime                IN  NUMBER   := ctx_ddl.maxtime_unlimited);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Sync_JTF_IMT_Indexes
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an iMT Sync on all indexes across
--                 all AMV iMT-indexed columns.
--
--    Parameters :  None
--
--
--    Version    : Current version     1.0
--                    {add comments here}
--                 Previous version    1.0
--                 Initial version     1.0
--
-- End of comments
--
PROCEDURE Sync_JTF_IMT_Indexes
          (ERRBUF                   OUT NOCOPY VARCHAR2,
		 RETCODE                  OUT NOCOPY NUMBER);

--
END JTF_AMVIMT_Pub;

 

/
