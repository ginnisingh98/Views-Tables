--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_ACTION_AUTH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_ACTION_AUTH" AUTHID CURRENT_USER AS
-- $Header: POXDAAPS.pls 120.0.12010000.2 2012/01/06 12:42:21 venuthot ship $

-- Methods

PROCEDURE approve(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

PROCEDURE reject(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

PROCEDURE forward(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

PROCEDURE return_action(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

-- As part of the bug fix 13507482 changed this procedure from private to public
PROCEDURE get_supply_action_name(
   p_action            IN          VARCHAR2
,  p_document_type     IN          VARCHAR2
,  p_document_subtype  IN          VARCHAR2
,  x_supply_action     OUT NOCOPY  VARCHAR2
,  x_return_status     OUT NOCOPY  VARCHAR2
);

END PO_DOCUMENT_ACTION_AUTH;

/
