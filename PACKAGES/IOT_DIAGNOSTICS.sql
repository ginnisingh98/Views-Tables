--------------------------------------------------------
--  DDL for Package IOT_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IOT_DIAGNOSTICS" AUTHID CURRENT_USER AS
/* $Header: INVDIOT1S.pls 120.0.12000000.1 2007/08/09 06:49:27 ssadasiv noship $ */

PROCEDURE shipment_num_sql(p_org_id IN NUMBER, p_shipment_num IN VARCHAR2, p_receipt_num  IN VARCHAR2, p_sql IN OUT
NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list);
PROCEDURE shipment_line_num_sql(p_org_id IN NUMBER, p_shipment_num IN VARCHAR2, p_shipment_line_num IN NUMBER,
p_receipt_num  IN VARCHAR2, p_sql IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list);
 END;

 

/
