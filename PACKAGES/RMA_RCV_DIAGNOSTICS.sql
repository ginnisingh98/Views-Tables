--------------------------------------------------------
--  DDL for Package RMA_RCV_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RMA_RCV_DIAGNOSTICS" AUTHID CURRENT_USER AS
/* $Header: INVDRMA2S.pls 120.0.12000000.1 2007/08/09 06:52:31 ssadasiv noship $ */

PROCEDURE rma_line_receipt_sql(p_operating_id IN NUMBER,p_rma_number IN VARCHAR2,p_line_num IN NUMBER,
                                         p_receipt_number IN NUMBER, p_org_id IN NUMBER, p_sql IN OUT NOCOPY
INV_DIAG_RCV_PO_COMMON.sqls_list);
PROCEDURE receipt_sql(p_receipt_number IN NUMBER, p_org_id IN NUMBER, p_sql IN OUT NOCOPY
INV_DIAG_RCV_PO_COMMON.sqls_list);

END RMA_RCV_DIAGNOSTICS;

 

/
