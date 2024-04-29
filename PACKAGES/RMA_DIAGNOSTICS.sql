--------------------------------------------------------
--  DDL for Package RMA_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RMA_DIAGNOSTICS" AUTHID CURRENT_USER AS
/* $Header: INVDRMA1S.pls 120.0.12000000.1 2007/08/09 06:51:55 ssadasiv noship $ */

PROCEDURE rma_sql(p_operating_id IN NUMBER, p_rma_number IN NUMBER, p_sql IN OUT NOCOPY
INV_DIAG_RCV_PO_COMMON.sqls_list);
PROCEDURE rma_line_sql(p_operating_id IN NUMBER,p_rma_number IN VARCHAR2, p_line_num IN NUMBER, p_sql IN OUT NOCOPY
                                                                                                 INV_DIAG_RCV_PO_COMMON.sqls_list);
PROCEDURE rma_receipt_sql(p_operating_id IN NUMBER,p_rma_number IN VARCHAR2,
                                         p_receipt_number IN NUMBER, p_org_id IN NUMBER, p_sql IN OUT NOCOPY
INV_DIAG_RCV_PO_COMMON.sqls_list );
END RMA_DIAGNOSTICS ;

 

/
