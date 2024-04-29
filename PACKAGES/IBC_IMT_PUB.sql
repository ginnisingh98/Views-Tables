--------------------------------------------------------
--  DDL for Package IBC_IMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_IMT_PUB" AUTHID CURRENT_USER AS
/* $Header: ibcpimts.pls 115.2 2003/11/08 06:53:53 srrangar noship $ */
-- NAME
--   ibcpimts.pls
--
-- DESCRIPTION
--   Package body for IBC_IMT_PUB in support of rebuilding IMT
--   indexes on IBC table IBC_Attribute_bundles.  Expected use of this package
--   is either through Apps Concurrent Manager or package DBMS_JOBS.
--
-- NOTES
--
-- HISTORY
-- Marzia Usman and Sri Rangarajan	Created		11/07/2003
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : OPTIMIZE_IBC_IMT_INDEXES
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an IMT Optimize on all indexes across
--                 all IBC IMT-indexed columns in a time-distributed fashion.
--    Parameters :
--
--    IN         : p_optimize_level                    IN  VARCHAR2    Optional
--                   Specifies the type of IMT index optimization to perform.
--                   Valid values are 'FAST','FULL', ctx_ddl.optlevel_fast or
--                   ctx_ddl.optlevel_full.
--
--                   Default is ctx_ddl.optlevel_full.
--
--               : p_runtime                           IN  NUMBER      Optional
--                   Integer that indicates the total run-time (in seconds) of
--                   this optimization function call.  This time will be
--                   divided equally amongst all indexes within the IBC
--                   subsystem.  A null value implies execution until
--                   completion of the task.
--
--                   Default is ctx_ddl.maxtime_unlimited.
--
--    Version    : Current version     1.0
--                    {add comments here}
--                 Previous version    1.0
--                 Initial version     1.0
--
-- End of comments
--

PROCEDURE OPTIMIZE_IBC_IMT_INDEXES
          (ERRBUF                   OUT NOCOPY VARCHAR2,
	   RETCODE                  OUT NOCOPY NUMBER,
           p_optimize_level         IN  VARCHAR2 := ctx_ddl.optlevel_full,
           p_runtime                IN  NUMBER   := ctx_ddl.maxtime_unlimited);
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : SYNC_IBC_IMT_INDEXES
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs an IMT Sync on all indexes across
--                 all IBC IMT-indexed columns.
--
--    Parameters : None.
--
--    Version    : Current version     1.0
--                    {add comments here}
--                 Previous version    1.0
--                 Initial version     1.0
--
-- End of comments
--

PROCEDURE SYNC_IBC_IMT_INDEXES
          (ERRBUF                   OUT NOCOPY VARCHAR2,
     	   RETCODE                  OUT NOCOPY NUMBER );

END IBC_IMT_PUB;

 

/
