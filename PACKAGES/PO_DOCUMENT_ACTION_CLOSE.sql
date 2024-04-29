--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_ACTION_CLOSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_ACTION_CLOSE" AUTHID CURRENT_USER AS
-- $Header: POXDACLS.pls 120.0 2005/06/01 20:32:17 appldev noship $

-- Methods

PROCEDURE manual_close_po(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

PROCEDURE auto_close_po(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

END PO_DOCUMENT_ACTION_CLOSE;

 

/
