--------------------------------------------------------
--  DDL for Package IO_DIAGNOSTICS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IO_DIAGNOSTICS1" AUTHID CURRENT_USER AS
/* $Header: INVDIO1S.pls 120.0.12000000.1 2007/08/09 06:48:18 ssadasiv noship $ */

PROCEDURE req_num_sql( p_ou_id IN NUMBER , p_req_num IN VARCHAR2, p_sql IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list);
PROCEDURE req_line_sql( p_ou_id IN NUMBER, p_req_num IN VARCHAR2, p_line_num IN NUMBER, p_sql IN OUT NOCOPY
INV_DIAG_RCV_PO_COMMON.sqls_list);

END io_diagnostics1;

 

/
