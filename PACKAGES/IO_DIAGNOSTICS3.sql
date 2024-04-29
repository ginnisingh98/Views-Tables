--------------------------------------------------------
--  DDL for Package IO_DIAGNOSTICS3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IO_DIAGNOSTICS3" AUTHID CURRENT_USER AS
/* $Header: INVDIO3S.pls 120.0.12000000.1 2007/08/09 06:49:08 ssadasiv noship $ */

PROCEDURE req_receipt_shipment_sql( p_ou_id IN NUMBER, p_req_num IN VARCHAR2, p_shipment_num IN VARCHAR2, p_receipt_num
IN VARCHAR2, p_org_id IN NUMBER, p_sql IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list);

END io_diagnostics3;

 

/
