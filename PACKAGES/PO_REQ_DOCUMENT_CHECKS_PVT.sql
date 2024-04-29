--------------------------------------------------------
--  DDL for Package PO_REQ_DOCUMENT_CHECKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_DOCUMENT_CHECKS_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVRCKS.pls 115.2 2003/09/25 03:00:58 bmunagal noship $*/

-----------------------------------------------------------------------------
-- Public variables
-----------------------------------------------------------------------------

--<DropShip FPJ Start>
--The following constants are possible values
--  for p_mode input parameter of po_status_check Procedure
G_CHECK_UPDATEABLE   CONSTANT VARCHAR2(30) := 'CHECK_UPDATEABLE';
G_GET_STATUS         CONSTANT VARCHAR2(30) := 'GET_STATUS';
G_CHECK_RESERVABLE   CONSTANT VARCHAR2(30) := 'CHECK_RESERVABLE';
G_CHECK_UNRESERVABLE CONSTANT VARCHAR2(30) := 'CHECK_UNRESERVABLE';
--<DropShip FPJ End>


-----------------------------------------------------------------------------
-- Public subprograms
-----------------------------------------------------------------------------


-- Detailed comments maintained in the Package Body PO_REQ_DOCUMENT_CHECKS_PVT.req_status_check
PROCEDURE req_status_check (
    p_api_version         IN NUMBER,
    p_req_header_id       IN PO_TBL_NUMBER,
    p_req_line_id         IN PO_TBL_NUMBER,
    p_req_distribution_id IN PO_TBL_NUMBER,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_req_status_rec      OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
);

END PO_REQ_DOCUMENT_CHECKS_PVT;

 

/
