--------------------------------------------------------
--  DDL for Package RCV_LCM_WEB_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_LCM_WEB_SERVICE" AUTHID CURRENT_USER AS
/* $Header: RCVLCMWS.pls 120.0.12010000.6 2013/12/31 07:14:08 zhlee noship $ */

   PROCEDURE Get_Landed_Cost (p_group_id IN NUMBER,p_processing_mode IN VARCHAR2);

   --Bug 18017375

   --cursor only for non OPM orgs
   cursor rti_cur(l_group_id IN NUMBER,l_processing_mode IN VARCHAR2) is
      SELECT distinct rti.lcm_shipment_line_id line_id
      FROM   rcv_transactions_interface rti,
             mtl_parameters mp
      WHERE  rti.processing_status_code = 'RUNNING'
      AND    rti.transaction_status_code = 'PENDING'
      AND    rti.processing_mode_code = l_processing_mode
      AND    rti.group_id = nvl(l_group_id, group_id)
      AND    mo_global.check_access(rti.org_id) = 'Y'
      AND    rti.source_document_code = 'PO'
      AND    rti.to_organization_id = mp.organization_id
      AND    rti.lcm_shipment_line_id is not null
      AND    mp.lcm_enabled_flag = 'Y'
      --non OPM only
      AND    NVL(mp.process_enabled_flag,'N') = 'N'
      --
      AND    EXISTS  ( SELECT 'pll is lcm enabled'
                       FROM    po_line_locations_all pll
                       WHERE   pll.po_line_id = rti.po_line_id
                       AND     pll.po_header_id = rti.po_header_id
                       AND     pll.line_location_id = rti.po_line_location_id
                       AND     pll.lcm_flag = 'Y');

  TYPE rti_cur_table IS table of rti_cur%rowtype;


   -- cursor only for OPM orgs
   cursor rti_opm_cur(l_group_id IN NUMBER,l_processing_mode IN VARCHAR2) is
      SELECT
      distinct
       rti.lcm_shipment_line_id line_id,
       rti.interface_transaction_id,
			 rti.transaction_date
      FROM   rcv_transactions_interface rti,
             mtl_parameters mp
      WHERE  rti.processing_status_code = 'RUNNING'
      AND    rti.transaction_status_code = 'PENDING'
      AND    rti.processing_mode_code = l_processing_mode
      AND    rti.group_id = nvl(l_group_id, group_id)
      AND    mo_global.check_access(rti.org_id) = 'Y'
      AND    rti.source_document_code = 'PO'
      AND    rti.to_organization_id = mp.organization_id
      AND    rti.lcm_shipment_line_id is not null
      AND    mp.lcm_enabled_flag = 'Y'
      --OPM only
      AND    NVL(mp.process_enabled_flag,'Y') = 'Y'
      --
      AND    EXISTS  ( SELECT 'pll is lcm enabled'
                       FROM    po_line_locations_all pll
                       WHERE   pll.po_line_id = rti.po_line_id
                       AND     pll.po_header_id = rti.po_header_id
                       AND     pll.line_location_id = rti.po_line_location_id
                       AND     pll.lcm_flag = 'Y');

TYPE rti_opm_cur_table IS table of rti_opm_cur%rowtype;

    --Bug 18017375

END RCV_LCM_WEB_SERVICE;

/
