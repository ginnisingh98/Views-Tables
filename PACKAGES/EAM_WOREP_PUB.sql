--------------------------------------------------------
--  DDL for Package EAM_WOREP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WOREP_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPWORS.pls 120.0.12010000.2 2010/06/17 09:57:31 somitra ship $ */
 /***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMPWORS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WOREP_PUB
--
--  NOTES
--
--  HISTORY
--
--  20-MARCH-2006    Smriti Sharma     Initial Creation
***************************************************************************/


PROCEDURE Work_Order_CP
        (errbuf                        OUT NOCOPY VARCHAR2
        , retcode                       OUT NOCOPY VARCHAR2
	, p_work_order_from             IN  VARCHAR2
        , p_work_order_to               IN  VARCHAR2
	, p_scheduled_start_date_from   IN  VARCHAR2
        , p_scheduled_start_date_to     IN  VARCHAR2
	, p_asset_area_from             IN  VARCHAR2
	, p_asset_area_to               IN  VARCHAR2
        , p_asset_number                IN  VARCHAR2
	, p_status_type                 IN  NUMBER
        , p_assigned_department         IN  NUMBER
       	, p_organization_id             IN  NUMBER
        , p_operation                   IN  NUMBER
        , p_resource                    IN  NUMBER
        , p_material                    IN  NUMBER
        , p_direct_item                 IN  NUMBER
    	, p_work_request                IN  NUMBER
        , p_meter                       IN  NUMBER
        , p_quality_plan                IN  NUMBER
	, p_mandatory                   IN  NUMBER
	, p_attachment                  IN  NUMBER
	, p_asset_bom                   IN  NUMBER
	, p_permit                      IN  NUMBER --added bug 9812863
        );



END;


/
