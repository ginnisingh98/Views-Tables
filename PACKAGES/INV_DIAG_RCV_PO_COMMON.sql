--------------------------------------------------------
--  DDL for Package INV_DIAG_RCV_PO_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DIAG_RCV_PO_COMMON" AUTHID CURRENT_USER AS
/* $Header: INVDPO2S.pls 120.0.12000000.1 2007/08/09 06:50:02 ssadasiv noship $ */

-- Table of Varchar2
TYPE sqls_list IS TABLE OF VARCHAR2(6000) INDEX BY BINARY_INTEGER;

PROCEDURE build_po_all_sql(p_operating_id IN NUMBER,
                           p_po_number    IN VARCHAR2,
                           p_line_num     IN NUMBER,
                           p_line_loc_num IN NUMBER,
                           p_sql          IN OUT NOCOPY sqls_list);
PROCEDURE build_all_sql(p_operating_id IN NUMBER,
                        p_po_number    IN VARCHAR2,
                        p_line_num     IN NUMBER,
                        p_line_loc_num IN NUMBER,
                        p_org_id       IN NUMBER,
                        p_receipt_num  IN VARCHAR2,
                        p_sql          IN OUT NOCOPY sqls_list);
END;

 

/
