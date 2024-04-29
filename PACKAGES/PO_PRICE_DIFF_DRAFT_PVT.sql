--------------------------------------------------------
--  DDL for Package PO_PRICE_DIFF_DRAFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PRICE_DIFF_DRAFT_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PRICE_DIFF_DRAFT_PVT.pls 120.1 2005/06/30 17:30 bao noship $ */

FUNCTION draft_changes_exist
( p_draft_id_tbl IN PO_TBL_NUMBER,
  p_price_differential_id_tbl IN PO_TBL_NUMBER
) RETURN PO_TBL_VARCHAR1;

FUNCTION draft_changes_exist
( p_draft_id IN NUMBER,
  p_price_differential_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE apply_changes
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE
);

END PO_PRICE_DIFF_DRAFT_PVT;

 

/
