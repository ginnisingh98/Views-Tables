--------------------------------------------------------
--  DDL for Package INV_DIAG_RCV_IPROC_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DIAG_RCV_IPROC_COMMON" AUTHID CURRENT_USER AS
/* $Header: INVREQ2S.pls 120.0.12000000.1 2007/08/09 06:53:21 ssadasiv noship $ */
PROCEDURE build_req_sql(p_operating_id IN NUMBER,
                           p_req_number    IN VARCHAR2,
                           p_line_num      IN NUMBER,
                           p_sql           IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list);
PROCEDURE build_req_rcv_sql(p_receipt_num  IN VARCHAR2,
                            p_org_id       IN NUMBER,
                            p_sql          IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list);
PROCEDURE build_req_all_sql(p_operating_id  IN NUMBER,
                           p_req_number     IN VARCHAR2,
                           p_line_num       IN NUMBER,
                           p_receipt_number IN VARCHAR2,
                           p_org_id         IN NUMBER,
                           p_sql            IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list);

END;

 

/
