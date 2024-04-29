--------------------------------------------------------
--  DDL for Package PO_APPROVAL_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_APPROVAL_ACTION" AUTHID CURRENT_USER AS
/* $Header: POXWPA9S.pls 115.3 2002/09/24 22:25:05 davidng noship $ */
 /*=======================================================================+
 | FILENAME
 |  POXWPA9S.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_APPROVAL_ACTION
 |
 | NOTES
 | CREATE
 | MODIFIED
 *=====================================================================*/

function req_state_check_approve( itemtype in VARCHAR2, itemkey in VARCHAR2)
RETURN VARCHAR2;

function po_state_check_approve( itemtype in VARCHAR2, itemkey in VARCHAR2, doctype in VARCHAR2)
RETURN VARCHAR2;

function req_complete_check(itemtype in VARCHAR2, itemkey in VARCHAR2)
RETURN VARCHAR2;

end PO_APPROVAL_ACTION;

 

/
