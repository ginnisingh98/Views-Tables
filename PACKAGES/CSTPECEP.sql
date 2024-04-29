--------------------------------------------------------
--  DDL for Package CSTPECEP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPECEP" AUTHID CURRENT_USER AS
/* $Header: CSTECEPS.pls 120.1.12010000.2 2012/03/23 01:39:40 fayang ship $*/

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       estimate_wip_jobs                                                    |
|                                                                            |
|  p_job_otion  :                                                            |
|             1:  All Jobs                                                   |
|             2:  Specific job                                               |
|             3:  All Jobs for an asset                                      |
|             4:  All Jobs for an department                                 |
|                                                                            |
|  Estimation Status    :                                                    |
|             NULL,1:  Pending                                               |
|             -ve   :  Running                                               |
|                  3:  Error                                                 |
|                  7:  Complete                                              |
|                                                                            |
|  PARAMETERS                                                                |
|             p_organization_id                                              |
|             p_entity_type                                                  |
|             p_job_option                                                   |
|             p_wip_entity_id                                                |
|             p_asset_group_id                                               |
|             p_asset_number                                                 |
|             p_owning_department_id                                         |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE estimate_wip_jobs(
        errbuf                     OUT NOCOPY          VARCHAR2,
        retcode                    OUT NOCOPY          NUMBER,
        p_organization_id          IN           NUMBER,
        p_entity_type              IN           NUMBER   DEFAULT 6,
        p_job_option               IN           NUMBER   DEFAULT 1,
        p_item_dummy               IN           NUMBER   DEFAULT NULL,
        p_job_dummy                IN           NUMBER   DEFAULT NULL,
        p_owning_department_dummy  IN           NUMBER   DEFAULT NULL,
        p_wip_entity_id            IN           NUMBER   DEFAULT NULL,
        p_inventory_item_id        IN           NUMBER   DEFAULT NULL,
        p_asset_number             IN           VARCHAR2 DEFAULT NULL,
        p_owning_department_id     IN           NUMBER   DEFAULT NULL
);

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       Estimate_WorkOrder_GRP                                               |
|                                                                            |
|       API provided for online estimation of workorder.                     |
|       WDJ.estimation_status should be set to Running and Committed         |
|       before calling this API. This is to prevent concurrency issues       |
|       if there is a Cost Estimation Concurrent request currently           |
|       running.                                                             |
|                                                                            |
|       This API has been added as part of estimation enhancements for       |
|       Patchset I.                                                          |
|                                                                            |
|                                                                            |
|  PARAMETERS                                                                |
|             p_organization_id                                              |
|             p_wip_entity_id                                                |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE Estimate_WorkOrder_GRP(
        p_api_version		IN		NUMBER,
	p_init_msg_list		IN 		VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN		VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN		NUMBER := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
        p_organization_id       IN           	NUMBER,
        p_wip_entity_id         IN           	NUMBER,
        p_delete_only           IN              VARCHAR2 := 'N'
);

/*------------------------------------------------------------------------------------*
Declaring a table type to be used to get wip_entity_id for processing during estimation
*-------------------------------------------------------------------------------------*/
TYPE wip_entity_id_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

END CSTPECEP;

/
