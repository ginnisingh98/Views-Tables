--------------------------------------------------------
--  DDL for Package PO_NOTIFICATION_CTRL_DRAFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NOTIFICATION_CTRL_DRAFT_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_NOTIFICATION_CTRL_DRAFT_PVT.pls 120.1 2005/06/30 17:32 bao noship $ */

FUNCTION draft_changes_exist
( p_draft_id_tbl IN PO_TBL_NUMBER,
  p_notification_id_tbl IN PO_TBL_NUMBER
) RETURN PO_TBL_VARCHAR1;

FUNCTION draft_changes_exist
( p_draft_id IN NUMBER,
  p_notification_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE apply_changes
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE
);

END PO_NOTIFICATION_CTRL_DRAFT_PVT;

 

/
