--------------------------------------------------------
--  DDL for Package PO_REQ_DOCUMENT_LOCK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_DOCUMENT_LOCK_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGRLKS.pls 115.0 2003/08/28 06:04:48 bmunagal noship $*/

-- Detailed comments are in PVT Package Body PO_REQ_DOCUMENT_CHECKS_PVT.req_status_check
PROCEDURE lock_requisition (
  p_api_version     IN NUMBER,
  p_req_header_id   IN NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2
);

END PO_REQ_DOCUMENT_LOCK_GRP;

 

/
