--------------------------------------------------------
--  DDL for Package AMV_IMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_IMT_PUB" AUTHID CURRENT_USER AS
/* $Header: amvpimts.pls 120.1 2005/06/22 16:35:51 appldev ship $ */
-- NAME
--   amvpimts.pls
--
-- DESCRIPTION
--   Package specifications for AMV_IMT_PUB in support of rebuilding iMT
--   indexes on AMV table amv_c_channels_tl.  Expected use of this package
--   is either through Apps Concurrent Manager or package DBMS_JOBS.
--
-- NOTES
--
-- HISTORY
--   12/14/99	J Ray		Created.
--   02/15/00	slkrishn		Created.
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Optimize_AMV_IMT_Indexes
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an iMT Optimize on all indexes across
--                 all AMV iMT-indexed columns in a time-distributed fashion.
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
--                   divided equally amongst all indexes within the AMV
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


PROCEDURE Optimize_AMV_IMT_Indexes
		(ERRBUF				 OUT NOCOPY  VARCHAR2,
		 RETCODE				 OUT NOCOPY  NUMBER,
           p_optimize_level         IN  VARCHAR2 := ctx_ddl.optlevel_full,
           p_runtime                IN  NUMBER   := ctx_ddl.maxtime_unlimited);

--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Sync_AMV_IMT_Indexes
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
PROCEDURE Sync_AMV_IMT_Indexes
		(ERRBUF				 OUT NOCOPY  VARCHAR2,
		 RETCODE				 OUT NOCOPY  NUMBER );

--
END AMV_IMT_Pub;

 

/
