--------------------------------------------------------
--  DDL for Package PO_REQUISITION_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_UPDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXRQUPVTS.pls 120.0.12010000.3 2013/08/19 03:03:03 uchennam noship $ */
/*===========================================================================
  FILE NAME    :         POXRQUPVTS.pls
  PACKAGE NAME:         PO_REQUISITION_UPDATE_PVT

  DESCRIPTION:
      PO_REQUISITION_UPDATE_PVT API performs update operations on Requisition
      header,line and distribution. It allows updation on requisition that is
      in Incomplete status or Approved without attached PO.

 PROCEDURES:
     update_requisition_header
     update_requisition_line
     update_requisition_dist

==============================================================================*/
TYPE accounts_rec IS RECORD
(distribution_id NUMBER,
 req_line_id NUMBER,
 ccid NUMBER,
 budget_account_id NUMBER,
 variance_account_id NUMBER,
 accrual_account_id NUMBER);

TYPE accounts_tbl IS TABLE OF accounts_rec INDEX BY BINARY_INTEGER;

TYPE dist_quantity_rec IS RECORD
(distribution_id NUMBER,
 req_line_id NUMBER,
 req_line_quantity NUMBER);

TYPE dist_quantity_tbl IS TABLE OF dist_quantity_rec INDEX BY BINARY_INTEGER;

PROCEDURE update_requisition_header ( p_req_hdr IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_hdr,
                               x_return_status OUT NOCOPY    VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2,
                               p_submit_approval IN VARCHAR2,
                               p_commit IN VARCHAR2
                               );

PROCEDURE submit_for_approval(p_req_hdr_id IN NUMBER,
                              p_preparer_id IN NUMBER,
                              p_forward_to_id IN NUMBER,
                               p_note_to_approver IN VARCHAR2,
                               x_return_status OUT NOCOPY  VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2);

PROCEDURE update_requisition_line ( p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2,
                               p_submit_approval IN VARCHAR2,
                               p_commit IN VARCHAR2);

PROCEDURE update_requisition_line ( p_req_line_tbl IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_tbl,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2 ,
                               p_req_line_tbl_out OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_tbl,
                               p_req_line_err_tbl OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_tbl,
                               p_submit_approval IN VARCHAR2,
                               p_commit IN VARCHAR2);


PROCEDURE update_req_distribution (p_req_dist_rec IN  OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist,
                                x_return_status OUT NOCOPY    VARCHAR2,
                                p_init_msg IN VARCHAR2,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                p_submit_approval IN VARCHAR2,
                               p_commit IN VARCHAR2);

PROCEDURE update_req_distribution (p_req_dist_tbl IN  OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist_tbl,
                                x_return_status OUT NOCOPY VARCHAR2,
                                p_init_msg IN VARCHAR2,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                p_req_dist_tbl_out OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist_tbl,
                               p_req_dist_err_tbl OUT NOCOPY PO_REQUISITION_UPDATE_PUB.req_dist_tbl,
                               p_submit_approval IN VARCHAR2,
                               p_commit IN VARCHAR2);

PROCEDURE update_requisition_header ( p_req_hdr_tbl IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_hdr_tbl,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2 ,
                               p_req_hdr_tbl_out OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_hdr_tbl,
                               p_req_hdr_err_tbl OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_hdr_tbl,
                               p_submit_approval IN VARCHAR2 ,
                               p_commit IN VARCHAR2);
END;

/
