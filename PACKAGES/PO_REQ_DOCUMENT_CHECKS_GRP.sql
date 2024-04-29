--------------------------------------------------------
--  DDL for Package PO_REQ_DOCUMENT_CHECKS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_DOCUMENT_CHECKS_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGRCKS.pls 115.1 2003/09/10 02:11:18 bmunagal noship $*/

-- The new overloaded procedures req_status_check added in DropShip FPJ project

-- Detailed comments are in PVT Package Body PO_REQ_DOCUMENT_CHECKS_PVT.req_status_check
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

-- Detailed comments are in PVT Package Body PO_REQ_DOCUMENT_CHECKS_PVT.req_status_check
PROCEDURE req_status_check (
    p_api_version         IN NUMBER,
    p_req_header_id       IN NUMBER,
    p_req_line_id         IN NUMBER := NULL,
    p_req_distribution_id IN NUMBER := NULL,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_req_status_rec      OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
);


END PO_REQ_DOCUMENT_CHECKS_GRP;

 

/
