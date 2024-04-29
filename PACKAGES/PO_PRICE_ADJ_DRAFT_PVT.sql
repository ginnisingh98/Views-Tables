--------------------------------------------------------
--  DDL for Package PO_PRICE_ADJ_DRAFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PRICE_ADJ_DRAFT_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PRICE_ADJ_DRAFT_PVT.pls 120.0.12010000.1 2009/06/01 23:32:04 ababujan noship $ */

FUNCTION draft_changes_exist
( p_draft_id_tbl IN PO_TBL_NUMBER,
  p_price_adjustment_id_tbl IN PO_TBL_NUMBER
) RETURN PO_TBL_VARCHAR1;

FUNCTION draft_changes_exist
( p_draft_id IN NUMBER,
  p_price_adjustment_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE apply_changes
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE
);

END PO_PRICE_ADJ_DRAFT_PVT;

/
