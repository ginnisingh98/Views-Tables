--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_LOCK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_LOCK_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGLOKS.pls 120.0.12010000.2 2012/06/28 09:09:33 vlalwani ship $*/

-------------------------------------------------------------------------------
--Start of Comments
--Name: lock_document
--Function:
--  Locks the document, including the header and all the lines, shipments,
--  and distributions, as appropriate.
--Notes:
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE lock_document (
  p_api_version     IN NUMBER,
  p_init_msg_list   IN VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2,
  p_document_type   IN VARCHAR2,
  p_document_id     IN NUMBER
);


-------------------------------------------------------------------------------
--<Bug 14207546 :Cancel Refactoring Project >
--Start of Comments
--Name: lock_document
--Function:
--  Locks all the document,including the header and all the lines, shipments,
--  and distributions, as appropriate .
--  documents to be locked are  available in po_session_gt with key =po_sesiongt_key
--Notes:
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE lock_document (
  p_online_report_id     IN NUMBER,
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2,
  p_user_id              IN po_lines.last_updated_by%TYPE,
  p_login_id             IN po_lines.last_update_login%TYPE,
  po_sesiongt_key        IN po_session_gt.key%TYPE
);

END PO_DOCUMENT_LOCK_GRP;

/
