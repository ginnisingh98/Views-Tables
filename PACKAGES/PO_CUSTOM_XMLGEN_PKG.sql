--------------------------------------------------------
--  DDL for Package PO_CUSTOM_XMLGEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CUSTOM_XMLGEN_PKG" AUTHID CURRENT_USER AS
/* $Header: PO_CUSTOM_XMLGEN_PKG.pls 120.0.12010000.2 2012/09/28 07:23:24 yuandli noship $ */
------------------------------------------------------------------------------
   -- Declare public procedures.
------------------------------------------------------------------------------

--Custom hook to generate XML fragment in PO Output for Communication
PROCEDURE generate_xml_fragment
(p_document_id IN NUMBER
, p_revision_num IN NUMBER
, p_document_type IN VARCHAR2
, p_document_subtype IN VARCHAR2
, x_custom_xml OUT NOCOPY CLOB);

END PO_CUSTOM_XMLGEN_PKG;

/
