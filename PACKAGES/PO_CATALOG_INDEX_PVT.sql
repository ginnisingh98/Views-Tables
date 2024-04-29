--------------------------------------------------------
--  DDL for Package PO_CATALOG_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CATALOG_INDEX_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_CATALOG_INDEX_PVT.pls 120.2 2006/01/30 17:43:25 pthapliy noship $ */

PROCEDURE rebuild_index
(
   p_type               IN VARCHAR2
,  p_po_header_id       IN NUMBER DEFAULT NULL
,  p_po_header_ids      IN PO_TBL_NUMBER DEFAULT NULL
,  p_reqexpress_name    IN VARCHAR2 DEFAULT NULL
,  p_org_id             IN NUMBER DEFAULT NULL
);

  -- Constants used for 'p_type' parameter in rebuid_index API.
  TYPE_BLANKET         CONSTANT VARCHAR2(20) := 'BLANKET';
  TYPE_BLANKET_BULK    CONSTANT VARCHAR2(20) := 'BLANKET_BULK';
  TYPE_QUOTATION       CONSTANT VARCHAR2(20) := 'QUOTATION';
  TYPE_REQ_TEMPLATE    CONSTANT VARCHAR2(20) := 'REQ_TEMPLATE';

END PO_CATALOG_INDEX_PVT;

 

/
