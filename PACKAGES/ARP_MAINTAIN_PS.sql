--------------------------------------------------------
--  DDL for Package ARP_MAINTAIN_PS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_MAINTAIN_PS" AUTHID CURRENT_USER AS
/* $Header: ARTEMPSS.pls 120.3.12010000.1 2008/07/24 16:56:24 appldev ship $ */

--
-- global error buffer
--
g_error_buffer			VARCHAR2(1000);

--
-- Public cursors
--
doc_combo_select_c		INTEGER;
doc_update_adj_c		INTEGER;
doc_insert_audit_c		INTEGER;

--
-- Public user-defined exceptions
--


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  maintain_payment_schedules
--
-- DECSRIPTION:
--   Server-side entry point for the Maintain Payment Schedules.
--
-- ARGUMENTS:
--      IN:
--	  mode			(I)nsert, (D)elete or (U)pdate
--	  customer_trx_id	Transaction's payment sched to be modified
--	  payment_schedule_id	Specific id to be changed.
--				For U mode only and regular CM only.
--				Must pass value for amount parameters.
--	  line_amount		New CM line amount
--	  tax_amount		New CM tax amount
--	  freight_amount	New CM freight amount
--	  charge_amount		New CM charges amount
--	  reversed_cash_receipt_id	For DM reversals, I mode only
--
--      IN/OUT:
--	  applied_commitment_amount	Amount of invoice applied to commitment
--
--      OUT:
--
-- NOTES:
--   Exception raised if Oracle error.
--   App_exception is raised for all other fatal errors and a message
--   is put on the AOL stack.  The public variable g_error_buffer is
--   populated for both types of errors.
--
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE maintain_payment_schedules(
	p_mode			IN VARCHAR2,
	p_customer_trx_id	IN NUMBER,
	p_payment_schedule_id	IN NUMBER,
	p_line_amount		IN NUMBER,
	p_tax_amount		IN NUMBER,
	p_freight_amount	IN NUMBER,
	p_charge_amount		IN NUMBER,
	p_applied_commitment_amount	IN OUT NOCOPY NUMBER,
	p_reversed_cash_receipt_id	IN NUMBER DEFAULT NULL
);

PROCEDURE test_build_doc_combo_sql;
PROCEDURE test_build_doc_update_adj_sql( p_where_clause VARCHAR2 );
PROCEDURE test_build_doc_ins_audit_sql( p_where_clause VARCHAR2 );
PROCEDURE test_update_adj_doc_number(
		p_customer_trx_id 	BINARY_INTEGER,
		p_update_where_clause	VARCHAR2 ) ;


PROCEDURE init;

END arp_maintain_ps;

/
