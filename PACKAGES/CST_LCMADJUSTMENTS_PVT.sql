--------------------------------------------------------
--  DDL for Package CST_LCMADJUSTMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_LCMADJUSTMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTLCADS.pls 120.0.12010000.1 2008/11/12 18:48:43 mpuranik noship $ */

PROCEDURE Process_LcmAdjustments
(
    errbuf                          OUT     NOCOPY VARCHAR2,
    retcode                         OUT     NOCOPY NUMBER,
    p_group_id                      IN      NUMBER,
    p_organization_id               IN      NUMBER
);


PROCEDURE populate_lcm_adjustment_info
(
   p_api_version                   IN      NUMBER,
   p_init_msg_list                 IN      VARCHAR2,
   p_validation_level              IN      NUMBER,
   p_group_id                      IN      NUMBER,
   p_organization_id               IN      NUMBER,
   x_ledger_id                     OUT     NOCOPY NUMBER,
   x_primary_cost_method           OUT     NOCOPY NUMBER,
   x_wms_enabled_flag              OUT     NOCOPY VARCHAR2,
   x_return_status                 OUT     NOCOPY VARCHAR2
);


PROCEDURE populate_temp_adjustment_data
(
   p_api_version                   IN      NUMBER,
   p_init_msg_list                 IN      VARCHAR2,
   p_validation_level              IN      NUMBER,
   p_primary_cost_method           IN      NUMBER,
   p_wms_enabled_flag              IN      VARCHAR2,
   x_return_status                 OUT     NOCOPY VARCHAR2
);


PROCEDURE insert_adjustment_data
(
   p_api_version                   IN      NUMBER,
   p_init_msg_list                 IN      VARCHAR2,
   p_validation_level              IN      NUMBER,
   p_group_id                      IN      NUMBER,
   p_organization_id               IN      NUMBER,
   p_ledger_id                     IN      NUMBER,
   x_return_status                 OUT     NOCOPY VARCHAR2
);


PROCEDURE Validate_lc_interface
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,
    p_group_id                      IN      NUMBER,
    p_organization_id               IN      NUMBER,
    x_no_of_errored                 OUT     NOCOPY NUMBER,
    x_return_status                 OUT     NOCOPY VARCHAR2
);


END CST_LcmAdjustments_PVT;  -- end package body

/
