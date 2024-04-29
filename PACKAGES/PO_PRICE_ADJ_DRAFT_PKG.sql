--------------------------------------------------------
--  DDL for Package PO_PRICE_ADJ_DRAFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PRICE_ADJ_DRAFT_PKG" AUTHID CURRENT_USER AS
/* $Header: PO_PRICE_ADJ_DRAFT_PKG.pls 120.0.12010000.1 2009/06/01 23:28:40 ababujan noship $ */

---------------------------------------------------------------
-- Global constants and types.
---------------------------------------------------------------
TYPE NUMBER_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


PROCEDURE delete_rows
( p_draft_id IN NUMBER,
  p_price_adjustment_id IN NUMBER
);

PROCEDURE sync_draft_from_txn
( p_price_adjustment_id_tbl  IN PO_TBL_NUMBER,
  p_draft_id_tbl             IN PO_TBL_NUMBER,
  p_delete_flag_tbl          IN PO_TBL_VARCHAR1,
  x_record_already_exist_tbl OUT NOCOPY PO_TBL_VARCHAR1
);

PROCEDURE sync_draft_from_txn
( p_price_adjustment_id IN NUMBER,
  p_draft_id IN NUMBER,
  p_delete_flag IN VARCHAR2,
  x_record_already_exist OUT NOCOPY VARCHAR2
);

PROCEDURE sync_draft_from_txn
( p_draft_id IN NUMBER,
  p_order_header_id NUMBER,
  p_order_line_id IN NUMBER,
  p_delete_flag IN VARCHAR2
  --x_record_already_exist OUT NOCOPY VARCHAR2
);

PROCEDURE merge_changes
( p_draft_id IN NUMBER
);

PROCEDURE lock_draft_record
( p_price_adjustment_id IN NUMBER,
  p_draft_id        IN NUMBER
);

PROCEDURE lock_transaction_record
( p_price_adjustment_id IN NUMBER
);

END PO_PRICE_ADJ_DRAFT_PKG;

/
