--------------------------------------------------------
--  DDL for Package PO_REQUISITION_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQUISITION_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXRQVLS.pls 120.0.12010000.7 2013/11/14 09:13:02 rkandima noship $ */
/*===========================================================================+
 |               Copyright (c) 2013, 2013 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
/*===========================================================================
  FILE NAMe    :        POXRQVLS.pls
  PACKAGE NAME:         PO_REQUISITION_VALIDATE_PVT

  DESCRIPTION:
      PO_REQUISITION_VALIDATE_PVT API performs all the validations on requisition
      header,lines and distributions before updation

 PROCEDURES:
     val_requisition_hdr -- Validate Requisition Header Data
     val_requisition_line -- Validate Requisition Line Data
     val_requisition_dist -- Validate Distribution Data
     check_dist_unreserve -- Unreserve Distribution Lines
     check_lines_unreserve -- Unreserve Requisition Line
     call_account_generator -- Call Account generator
     rebuild_accounts -- Rebuild Charge Accounts on requisition update

==============================================================================*/



PROCEDURE val_requisition_hdr (req_hdr IN OUT NOCOPY PO_REQUISITION_UPDATE_PUB.req_hdr,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY VARCHAR2 );

PROCEDURE LOG_INTERFACE_ERRORS(p_column_name IN VARCHAR2,
                               p_error_msg IN VARCHAR2,
                               p_transaction_id IN NUMBER,
                               p_table_name IN VARCHAR2,
                               p_line_id IN NUMBER  DEFAULT NULL,
                               p_distribution_id IN NUMBER DEFAULT NULL);

PROCEDURE validate_req_distribution (p_req_dist_rec IN  OUT NOCOPY PO_REQUISITION_UPDATE_PUB.req_dist,
                                x_return_status OUT NOCOPY VARCHAR2,
                                p_init_msg IN VARCHAR2,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                x_status OUT NOCOPY VARCHAR2);
PROCEDURE charge_account_update(p_req_dist IN OUT NOCOPY PO_REQUISITION_UPDATE_PUB.req_dist
                               ,p_chart_of_accounts_id IN NUMBER
                             -- ,x_account_id OUT NUMBER
                               ,x_error_msg OUT NOCOPY VARCHAR2
                               ,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE check_dist_unreserve(p_req_dist_rec PO_REQUISITION_UPDATE_PUB.req_dist,
                               x_error_msg OUT NOCOPY VARCHAR2,
                               x_ret_code OUT NOCOPY NUMBER);

PROCEDURE check_lines_unreserve(p_req_line_rec PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                                x_error_msg OUT NOCOPY VARCHAR2,
                                x_ret_code OUT NOCOPY VARCHAR2)    ;
PROCEDURE call_account_generator(p_req_dist_rec IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist,
                                 p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                                 p_coa_id NUMBER,
                                 p_ccid IN OUT NOCOPY NUMBER,
                                 x_error_msg OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2
                                 );

PROCEDURE val_requisition_line (p_req_line IN OUT NOCOPY PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                               p_accounts_tbl IN OUT NOCOPY  PO_REQUISITION_UPDATE_PVT.accounts_tbl,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY VARCHAR2 );
PROCEDURE rebuild_accounts(p_req_line IN OUT NOCOPY PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                                p_accounts_tbl IN OUT NOCOPY PO_REQUISITION_UPDATE_PVT.accounts_tbl,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY VARCHAR2 );
procedure document_submission_check(p_req_hdr PO_REQUISITION_UPDATE_PUB.req_hdr,
                                    x_return_status OUT NOCOPY varchar2,
                                    x_error_msg OUT NOCOPY varchar2);

END;

/
