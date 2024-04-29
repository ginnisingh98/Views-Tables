--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_ACTION_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_ACTION_CHECK" AUTHID CURRENT_USER AS
-- $Header: POXDACKS.pls 120.0 2005/06/01 23:24:46 appldev noship $

-- Methods

PROCEDURE approve_status_check(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

PROCEDURE reject_status_check(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

PROCEDURE authority_check(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

END PO_DOCUMENT_ACTION_CHECK;

 

/
