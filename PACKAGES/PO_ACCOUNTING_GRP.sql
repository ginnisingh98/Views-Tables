--------------------------------------------------------
--  DDL for Package PO_ACCOUNTING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ACCOUNTING_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGACTS.pls 115.1 2003/08/01 00:42:10 tpoon noship $*/

-------------------------------------------------------------------------------
--Start of Comments
--Name: build_offset_account
--Function:
--  Given the base account and the overlay account, this procedure builds a
--  new offset account by overlaying them in the appropriate way determined
--  by the Purchasing option "Automatic Offset Method".
--Notes:
--  For details, see the package body comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE build_offset_account (
  p_api_version     IN NUMBER,
  p_init_msg_list   IN VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2,
  p_base_ccid       IN NUMBER,
  p_overlay_ccid    IN NUMBER,
  p_accounting_date IN DATE,
  p_org_id          IN NUMBER,
  x_result_ccid     OUT NOCOPY NUMBER
);

END PO_ACCOUNTING_GRP;

 

/
