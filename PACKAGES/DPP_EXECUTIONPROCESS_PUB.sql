--------------------------------------------------------
--  DDL for Package DPP_EXECUTIONPROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_EXECUTIONPROCESS_PUB" AUTHID CURRENT_USER AS
/* $Header: dpppexcs.pls 120.1.12010000.4 2009/06/08 09:15:14 rvkondur ship $ */

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_ExecutionProcess
--
-- PURPOSE
--    Initiate Execution Process
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

  PROCEDURE Initiate_ExecutionProcess(
                                       errbuff    OUT  NOCOPY VARCHAR2,
                                       retcode    OUT  NOCOPY VARCHAR2,
                                       p_in_org_id     IN   NUMBER,
                                       p_in_txn_number  IN VARCHAR2
                                       );

END DPP_EXECUTIONPROCESS_PUB;

/
