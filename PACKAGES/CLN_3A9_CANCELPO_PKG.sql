--------------------------------------------------------
--  DDL for Package CLN_3A9_CANCELPO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_3A9_CANCELPO_PKG" AUTHID CURRENT_USER AS
/* $Header: CLN3A9PS.pls 115.4 2003/06/27 04:16:44 vumapath noship $ */

/*
-- Name
--    RAISE_CANCEL_PO_EVENT
-- Purpose
--    Raise oracle.apps.cln.po.cancelpo event
-- Arguments
--    PO Header ID
--    PO Header Type
--    PO Header Sub Type
-- Notes
--    No specific notes


PROCEDURE RAISE_CANCEL_PO_EVENT(
   p_document_id   IN VARCHAR2,
   p_hdr_type      IN VARCHAR2,
   p_hdr_sub_type  IN VARCHAR2);

*/

-- Name
--    SETATTRIBUTES
-- Purpose
--    Based on the parameters passed, query PO base tables and populate item attribute values
-- Arguments
--    PO Header ID available as Item Attribute
-- Notes
--    No specific notes

PROCEDURE SETATTRIBUTES(
   p_itemtype        IN VARCHAR2,
   p_itemkey         IN VARCHAR2,
   p_actid           IN NUMBER,
   p_funcmode        IN VARCHAR2,
   x_resultout       IN OUT NOCOPY VARCHAR2);

-- Name
--    IS_XML_CHOSEN
-- Purpose
--    Checks if XML transaction is set/enabled for this PO
-- Arguments
--    PO Header ID available as Item Attribute
--    PO Type available as Item Attribute
-- Notes
--    No specific notes

PROCEDURE IS_XML_CHOSEN(
   p_itemtype        IN VARCHAR2,
   p_itemkey         IN VARCHAR2,
   p_actid           IN NUMBER,
   p_funcmode        IN VARCHAR2,
   x_resultout       OUT NOCOPY VARCHAR2);


END CLN_3A9_CANCELPO_PKG;

 

/
