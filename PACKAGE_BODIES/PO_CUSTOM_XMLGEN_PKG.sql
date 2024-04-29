--------------------------------------------------------
--  DDL for Package Body PO_CUSTOM_XMLGEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CUSTOM_XMLGEN_PKG" AS
/* $Header: PO_CUSTOM_XMLGEN_PKG.plb 120.0.12010000.2 2012/09/28 07:26:36 yuandli noship $ */

--========================================================================
-- PROCEDURE : generate_xml_fragment       PUBLIC
-- PARAMETERS: p_document_id         document id
--           : p_revision_num        revision num of the document
--           : p_document_type       document type of the document
--           : p_document_subtype    document subtype of the document
--           : x_custom_xml          output of xml
-- COMMENT   : Custom hook to generate XML fragment for document,
--             called by PO Output for Communication
-- PRE-COND  : NONE
-- EXCEPTIONS: NONE
-- EXAMPLE CODES: Here is an example of how to program custom code.
PROCEDURE generate_xml_fragment
(p_document_id IN NUMBER
, p_revision_num IN NUMBER
, p_document_type IN VARCHAR2
, p_document_subtype IN VARCHAR2
, x_custom_xml OUT NOCOPY CLOB)
IS
  --1). Declare context
  context DBMS_XMLGEN.ctxHandle;
BEGIN
  IF p_document_subtype = 'BLANKET' THEN
    --2). Init context with custom query sql statement
    context := dbms_xmlgen.newContext('
      SELECT loc.address_line_1
      , loc.postal_code
      , loc.town_or_city
      , ft1.territory_short_name t1
      , ft2.territory_short_name t2
      , loc.loc_information13
      , loc.loc_information14
      , loc.loc_information16
      , loc.loc_information17
      FROM po_headers_all head
      , hr_all_organization_units hou
      , hr_locations loc
      , fnd_territories_vl ft1
      , fnd_territories_vl ft2
      WHERE head.org_id = hou.organization_id
      AND hou.location_id = loc.location_id
      AND ft1.territory_code (+) = loc.country
      AND ft2.territory_code (+) = loc.loc_information15
      AND head.po_header_id = PO_COMMUNICATION_PVT.getDocumentId() ' );

    --3). Set XML tag of the XML fragment for the result set
    dbms_xmlgen.setRowsetTag(context,'CUSTOM_RESULT');

    --4). Set XML tag for each row of the result set
    dbms_xmlgen.setRowTag(context,NULL);

    dbms_xmlgen.setConvertSpecialChars (context, TRUE);

    --5). Call dbms_xmlgen to get XML and assign it to output CLOB
    x_custom_xml := dbms_xmlgen.getXML(context,DBMS_XMLGEN.NONE);

    dbms_xmlgen.closeContext(context);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  --6). Capture any exceptions and handle them properly
    NULL;
END generate_xml_fragment;

END PO_CUSTOM_XMLGEN_PKG;

/
