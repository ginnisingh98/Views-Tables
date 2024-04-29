--------------------------------------------------------
--  DDL for Package PO_NOTIFICATION_CTRL_DRAFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NOTIFICATION_CTRL_DRAFT_PKG" AUTHID CURRENT_USER AS
/* $Header: PO_NOTIFICATION_CTRL_DRAFT_PKG.pls 120.1 2005/06/30 17:32 bao noship $ */

PROCEDURE delete_rows
( p_draft_id IN NUMBER,
  p_notification_id IN NUMBER
);

PROCEDURE sync_draft_from_txn
( p_notification_id_tbl      IN PO_TBL_NUMBER,
  p_draft_id_tbl             IN PO_TBL_NUMBER,
  p_delete_flag_tbl          IN PO_TBL_VARCHAR1,
  x_record_already_exist_tbl OUT NOCOPY PO_TBL_VARCHAR1
);

PROCEDURE sync_draft_from_txn
( p_notification_id IN NUMBER,
  p_draft_id IN NUMBER,
  p_delete_flag IN VARCHAR2,
  x_record_already_exist OUT NOCOPY VARCHAR2
);

PROCEDURE merge_changes
( p_draft_id IN NUMBER
);

PROCEDURE lock_draft_record
( p_notification_id IN NUMBER,
  p_draft_id        IN NUMBER
);

PROCEDURE lock_transaction_record
( p_notification_id IN NUMBER
);

END PO_NOTIFICATION_CTRL_DRAFT_PKG;

 

/
