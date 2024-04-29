--------------------------------------------------------
--  DDL for Package AS_TAP_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_TAP_PURGE_PUB" AUTHID CURRENT_USER as
/* $Header: asxtprgs.pls 120.2 2005/08/21 08:40:07 appldev noship $ */

-- Start of Comments
-- Package name     : AS_TAP_PURGE_PUB
--
-- Purpose          : Purge AS_ACCESSES_ALL and AS_TERRITORY_ACCESSES tables
--
-- NOTES
--
-- HISTORY
--   09/16/03  FFANG    Created.
--
--


PROCEDURE Purge_Access_Tables (
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_debug_mode          IN  VARCHAR2,
    p_trace_mode          IN  VARCHAR2
);

PROCEDURE Prepare_Parallel_Processing(
    P_Count               IN  NUMBER,
    P_MinNumParallelProc  IN  NUMBER,
    P_NumChildWorker      IN  NUMBER,
    X_ActualWorkersUsed   OUT NOCOPY NUMBER
);

PROCEDURE Delete_Access_Records (
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_debug_mode          IN  VARCHAR2,
    p_trace_mode          IN  VARCHAR2,
    p_worker_id           IN  NUMBER
);

END AS_TAP_PURGE_PUB;

 

/
