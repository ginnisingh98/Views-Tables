--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_ACTION_HOLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_ACTION_HOLD" AUTHID CURRENT_USER AS
-- $Header: POXDAHFS.pls 120.0 2005/06/01 23:24:36 appldev noship $

-- Methods

PROCEDURE freeze_unfreeze(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

PROCEDURE hold_unhold(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);


END PO_DOCUMENT_ACTION_HOLD;

 

/
