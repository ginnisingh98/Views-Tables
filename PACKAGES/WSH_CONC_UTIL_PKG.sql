--------------------------------------------------------
--  DDL for Package WSH_CONC_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CONC_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHCPUTS.pls 120.2 2006/05/05 14:56:13 wrudge noship $ */


-- Description: This procedure updates transactions with the new/valid
--              Freight Code/Carrier id after upgrade. It updates the
--              Old/Invalid Fgt.Code with the new/valid Fgt. Code, where
--              ever the Old Fgt.Code-Ship.Method Combination is non-exis
--              -tant after the upgrade.
--              This uses LTU architecture to exucute the updgrade in
--              parallel
-- Parameters:  p_batch_commit_size  - batch size < 1000
--              p_numworkers - Number of workers.
--              p_logical_worker_id - Worker id.

Procedure Worker_Upgrade_Closed_Orders(
                                errbuf    OUT NOCOPY   VARCHAR2,
                                retcode    OUT NOCOPY   VARCHAR2,
                                p_batch_commit_size IN NUMBER,
                                p_logical_worker_id IN NUMBER,
                                p_numworkers IN NUMBER);



-- Description: This is a wrapper around AD_Conc_Utils_PKG.Submit_Subrequests
-- Parameters : p_worker_conc_appsshortname - Shortname for the application
--              owning the worker concurrent program
--              p_worker_conc_program - Worker concurrent program that will
--              will be run in parallel using LTU architecture.
--              p_batch_commit_size - batch size < 1000
--              p_numworkers - Number of workers.

Procedure Master_Conc_Parallel_Upgrade(
                                       errbuf    OUT NOCOPY   VARCHAR2,
                                       retcode    OUT NOCOPY   VARCHAR2,
                                       p_worker_conc_appsshortname IN VARCHAR2,
                                       p_worker_conc_program IN VARCHAR2,
                                       p_batch_commit_size IN NUMBER,
                                       p_numworkers IN NUMBER);



-- Description: Update Ship Method SRS for ECO 5069719
--              This will upgrade open shipping data with mode of transport
--              and service level that are entered on ship methods upgraded
--              from 11.0 or 10.7
-- PARAMETERS: errbuf                  Used by the concurrent program for error
--                                     messages.
--             retcode                 Used by the concurrent program for
--                                     return code.
PROCEDURE update_ship_method_SRS(
                  errbuf      OUT NOCOPY  VARCHAR2,
                  retcode     OUT NOCOPY  VARCHAR2);

END WSH_CONC_UTIL_PKG;


 

/
