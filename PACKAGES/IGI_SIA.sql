--------------------------------------------------------
--  DDL for Package IGI_SIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SIA" AUTHID CURRENT_USER AS
-- $Header: igisiaas.pls 120.2.12010000.2 2010/04/08 12:17:13 schakkin ship $
TYPE InvoiceTabType is table of number(15)
	index by binary_integer;
TYPE PRTableType is table of varchar2(1)
	index by binary_integer;
--
l_TableRow		NUMBER(15) := 0;
l_InvoiceIdTable	InvoiceTabType;
l_UpdatedByTable	InvoiceTabType;
l_StatusTable           InvoiceTabType;
l_PRTable		PRTableType;
G_QTY_REC_HOLD_RELEASED varchar2(1);
G_MATCH_PO_HOLD_RELEASED varchar2(1);

--
PROCEDURE SET_INVOICE_ID
		( p_inv_id		NUMBER
		, p_upd_by		NUMBER
                , p_status              NUMBER
		);

PROCEDURE PROCESS_INVOICE_HOLDS(p_inv_id NUMBER,
                        p_upd_by NUMBER
                       );

PROCEDURE REVERSE_HOLDS(p_inv_id NUMBER,
                        p_upd_by NUMBER
                       );

PROCEDURE PROCESS_HOLDS
		;

PROCEDURE RELEASE_HOLDS
		;
--
END;

/
