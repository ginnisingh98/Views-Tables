--------------------------------------------------------
--  DDL for Package PO_DRAFT_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DRAFT_EVENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: PO_DRAFT_EVENTS_PKG.pls 120.0.12010000.2 2012/07/02 14:38:49 sbontala noship $*/

  -------------------------------------------------------------------------------
  --Start of Comments
  --Name: delete_draft_events
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  -- This procedure will be used to delete invalid/draft events
  -- for all PO,PA and Requistion encumbrance events
  --Parameters:
  --IN:
  --  p_init_msg_list
  --  p_ledger_id
  --  p_start_date
  --  p_end_date
  --  p_calling_sequence
  --  p_currency_code_func: currency code of the functional currency.
  --IN OUT:
  --  None.
  --OUT:
  --  x_return_status
  --  x_msg_count
  --  x_msg_data
  --Notes:
  --  This procedure will be called from PSA BC optimizer to delete
  -- invalid/draft encumbrance events. This is required to avoid showing
  -- in subledger exception report.
  --Testing:
  --
  --End of Comments
  -------------------------------------------------------------------------------
PROCEDURE delete_draft_events (
			    p_init_msg_list    IN VARCHAR2,
			    p_ledger_id        IN NUMBER,
			    p_start_date       IN DATE,
			    p_end_date         IN DATE,
			    p_calling_sequence IN VARCHAR2,
			    x_return_status    OUT NOCOPY VARCHAR2,
			    x_msg_count        OUT NOCOPY NUMBER,
			    x_msg_data         OUT NOCOPY VARCHAR2
			  ) ;



END PO_DRAFT_EVENTS_PKG;

/
