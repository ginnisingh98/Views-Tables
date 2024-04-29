--------------------------------------------------------
--  DDL for Package EAM_SAFETY_REPORTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_SAFETY_REPORTS_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVSRPS.pls 120.0.12010000.2 2010/04/16 11:04:46 somitra noship $ */
/***************************************************************************
--
--  Copyright (c) 2010 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVSRPS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_SAFETY_REPORTS_PVT
--
--  NOTES
--
--  HISTORY
--
--  07-APRIL-2008    Madhuri Shah     Initial Creation
***************************************************************************/


/********************************************************************
* Procedure     : getWorkPermitReportXML
* Purpose       : This procedure generate xml data for work permits
*********************************************************************/
TYPE eam_permit_record_type IS RECORD (
permit_id INT
);

TYPE eam_permit_tab_type IS TABLE OF eam_permit_record_type;

Function getWorkPermitReportXML
                    (  p_permit_ids   in eam_permit_tab_type,
                       p_file_attachment_flag in NUMBER,
                       p_work_order_flag in NUMBER
                    )  return CLOB;


/********************************************************************
* Procedure     : Convert_to_client_time
* Purpose       : This procedure coverts date from Server Time zone to Client Time Zone
*********************************************************************/
Function Convert_to_client_time
(
	p_server_time	in 	date
) return date;

/********************************************************************
* Procedure     : getWorkClearanceReportXML
* Purpose       : This procedure generate xml data for work clearances

*********************************************************************/
/*Function getWorkClearanceReportXML
               ( p_work_clearance_id in system.eam_wipid_tab_type,
                  p_short_attachment_flag in int,
                  p_long_attachment_flag in int,
                  p_file_attachment_flag in int,
                  p_work_request_flag in int,
                  p_asset_bom_flag in int
               )return CLOB;*/


END EAM_SAFETY_REPORTS_PVT;


/
