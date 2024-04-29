--------------------------------------------------------
--  DDL for Package EAM_DOWNTIME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_DOWNTIME_PUB" AUTHID CURRENT_USER as
/* $Header: EAMPEQDS.pls 115.3 2002/12/06 00:33:01 dizhao noship $ */


/* ========================================================================== */
-- PROCEDURE
-- Process_Production_Downtime
--
-- Description
-- This procedure is called by the concurrent program Load Production
-- Maintenance Downtime.  The following parameters are passed by the
-- concurrent program:
--    . p_org_id
--         production organization to load maintenance downtime
--    . p_simulation_set
--         simulation set to load capacity reduction caused by downtime
--    . p_run_option
--         1 = load downtime
--         2 = purge all capacity change entries loaded by this process
--    . p_include_unreleased
--         1 (yes) = consider both released and unreleased work orders
--         2 (no)  = consider only released work orders
--    . p_firm_order_only
--         1 = consider only firm work orders
--         2 = consider both firm and non-firm work orders
--    . p_department_id
--         Compute downtime only for equipment instances associated to
--         resources owned by the specified department.
--    . p_resource_id
--         Compute downtime only for equipment instances associated to
--         the specified resource.

/* ========================================================================== */

PROCEDURE Process_Production_Downtime(
        errbuf                     OUT NOCOPY         VARCHAR2,
        retcode                    OUT NOCOPY         NUMBER,
        p_org_id                   IN           NUMBER,
        p_simulation_set           IN           VARCHAR2,
        p_run_option               IN           NUMBER,
        p_include_unreleased       IN           NUMBER,
        p_firm_order_only          IN           NUMBER,
        p_department_id            IN           NUMBER DEFAULT NULL,
        p_resource_id              IN           NUMBER DEFAULT NULL
        );
END EAM_Downtime_PUB;

 

/
