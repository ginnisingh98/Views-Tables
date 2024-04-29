--------------------------------------------------------
--  DDL for Package INV_DIAG_RCV_RCV_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DIAG_RCV_RCV_COMMON" AUTHID CURRENT_USER AS
/* $Header: INVDPO3S.pls 120.0.12000000.1 2007/08/09 06:50:23 ssadasiv noship $ */

PROCEDURE build_rcv_sql(p_org_id      IN NUMBER,
                        p_receipt_num IN VARCHAR2,
                        p_sql         IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list);

PROCEDURE build_lookup_codes(p_sql     IN OUT NOCOPY INV_DIAG_RCV_PO_COMMON.sqls_list);

END;

 

/
