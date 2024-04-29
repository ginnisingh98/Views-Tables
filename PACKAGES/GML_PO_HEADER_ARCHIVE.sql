--------------------------------------------------------
--  DDL for Package GML_PO_HEADER_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_PO_HEADER_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: GMLPOHAS.pls 120.0 2005/05/25 16:09:54 appldev noship $ */

 PROCEDURE store(p_segment1 IN VARCHAR2, p_revision_num IN NUMBER,
            p_agent_id IN PO_HEADERS_ALL.AGENT_ID%TYPE,
            p_bill_to_location_id IN PO_HEADERS_ALL.BILL_TO_LOCATION_ID%TYPE,
            p_terms_id IN  PO_HEADERS_ALL.TERMS_ID%TYPE,
            p_freight_code IN PO_HEADERS_ALL.FREIGHT_TERMS_LOOKUP_CODE%TYPE,
            p_fob_code IN PO_HEADERS_ALL.FOB_LOOKUP_CODE%TYPE,
            p_carrier_code IN PO_HEADERS_ALL.SHIP_VIA_LOOKUP_CODE%TYPE,
            p_po_header_id IN PO_LINE_LOCATIONS_ARCHIVE_ALL.po_header_id%TYPE);

 PROCEDURE process;

END GML_PO_HEADER_ARCHIVE;

 

/
