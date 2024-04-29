--------------------------------------------------------
--  DDL for Package IEC_RECOVER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_RECOVER_PVT" AUTHID CURRENT_USER AS
/* $Header: IECOCRCS.pls 115.16 2004/05/18 19:38:09 minwang ship $ */

/* Called by the Recover Plugin. */
PROCEDURE RECOVER_SCHED_ENTRIES
   ( P_SOURCE_ID            IN             NUMBER
	 , P_SCHED_ID             IN             NUMBER
   , P_LOST_INTERVAL        IN             NUMBER
   , X_ACTION_ID               OUT NOCOPY  NUMBER
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : RECOVER_LIST_ENTRIES
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Recover entries that have been checked out of AMS_LIST_ENTRIES for longer
--                than the time sent in as P_LOST_INTERVAL.
--  Parameters  : P_LOST_INTERVAL                IN     NUMBER                       Required
--                X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE RECOVER_LIST_ENTRIES
   ( P_SOURCE_ID            IN             NUMBER
   , P_LIST_ID              IN             NUMBER
   , P_LOST_INTERVAL        IN             NUMBER
   , X_ACTION_ID            IN  OUT NOCOPY  NUMBER
   );
END IEC_RECOVER_PVT;

 

/
