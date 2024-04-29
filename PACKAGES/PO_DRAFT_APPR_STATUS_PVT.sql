--------------------------------------------------------
--  DDL for Package PO_DRAFT_APPR_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DRAFT_APPR_STATUS_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_DRAFT_APPR_STATUS_PVT.pls 120.1 2006/08/09 00:07:32 vkartik noship $ */

PROCEDURE update_approval_status
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_rebuild_attribs OUT NOCOPY BOOLEAN
);

END PO_DRAFT_APPR_STATUS_PVT;

 

/
