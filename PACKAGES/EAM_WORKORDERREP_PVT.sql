--------------------------------------------------------
--  DDL for Package EAM_WORKORDERREP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WORKORDERREP_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWRPS.pls 120.3.12010000.2 2010/04/27 04:52:36 mashah ship $ */
 /***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWRPS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WorkOrderRep_PVT
--
--  NOTES
--
--  HISTORY
--
--  02-MARCH-2006    Smriti Sharma     Initial Creation
***************************************************************************/



Function getWoReportXML
(
	p_wip_entity_id in system.eam_wipid_tab_type,
	p_operation_flag in int,
	p_material_flag in int,
	p_resource_flag in int,
	p_direct_material_flag in int,
  p_short_attachment_flag in int,
	p_long_attachment_flag in int,
	p_file_attachment_flag in int,
	p_work_request_flag in int,
	p_meter_flag in int,
	p_quality_plan_flag in int,
	p_asset_bom_flag in int,
  p_safety_permit_flag in int -- for permit report
)return CLOB;

Function getLong
(
	p_wip_id in number,
	p_org_id in  number,
	p_media_id in number,
	p_select in number

)return CLOB;

Function Convert_to_client_time
(
	p_server_time	in 	date
) return date;



END;


/
