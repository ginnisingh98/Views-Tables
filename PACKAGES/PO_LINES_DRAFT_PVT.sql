--------------------------------------------------------
--  DDL for Package PO_LINES_DRAFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_DRAFT_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_LINES_DRAFT_PVT.pls 120.2 2006/09/14 01:28:51 bao noship $ */

FUNCTION draft_changes_exist
( p_draft_id_tbl IN PO_TBL_NUMBER,
  p_po_line_id_tbl IN PO_TBL_NUMBER
) RETURN PO_TBL_VARCHAR1;

FUNCTION draft_changes_exist
( p_draft_id IN NUMBER,
  p_po_line_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE apply_changes
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE
);

-- bug4176111
PROCEDURE maintain_retroactive_change
( p_draft_info IN PO_DRAFTS_PVT.draft_info_rec_type
);

END PO_LINES_DRAFT_PVT;

 

/
