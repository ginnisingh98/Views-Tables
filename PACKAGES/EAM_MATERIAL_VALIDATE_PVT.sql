--------------------------------------------------------
--  DDL for Package EAM_MATERIAL_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MATERIAL_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVMSCS.pls 120.0 2005/06/08 02:44:15 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMSCS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  02-FEB-2005    Girish Rajan     Initial Creation
***************************************************************************/

PROCEDURE Material_Shortage_CP
	( errbuf			OUT NOCOPY VARCHAR2
        , retcode		        OUT NOCOPY VARCHAR2
        , p_owning_department		IN  VARCHAR2
	, p_assigned_department         IN  NUMBER
	, p_asset_number	        IN  VARCHAR2
	, p_scheduled_start_date_from	IN  VARCHAR2
	, p_scheduled_start_date_to	IN  VARCHAR2
	, p_work_order_from		IN  VARCHAR2
	, p_work_order_to		IN  VARCHAR2
	, p_status_type			IN  NUMBER
	, p_horizon			IN  NUMBER
	, p_backlog_horizon		IN  NUMBER
	, p_organization_id		IN  NUMBER
	, p_project			IN  VARCHAR2
	, p_task			IN  VARCHAR2
        );

G_PKG_NAME CONSTANT VARCHAR2(30):='EAM_MATERIAL_VALIDATE_PVT';

END EAM_MATERIAL_VALIDATE_PVT;

 

/
