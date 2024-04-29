--------------------------------------------------------
--  DDL for Package XNP_XML_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_XML_UTILS" AUTHID CURRENT_USER AS
/* $Header: XNPXMLPS.pls 120.2 2006/02/13 07:59:53 dputhiye ship $ */

-- Provides a tag value lookup
--
PROCEDURE decode
(
	p_msg_text IN VARCHAR2
	,p_tag IN VARCHAR2
	,x_value OUT NOCOPY VARCHAR2
);

-- Append the xml document to the existing document
--
PROCEDURE append
(
	p_xml_doc IN VARCHAR2
);

-- Overloaded version
--
PROCEDURE append
(
	p_xml_doc IN NUMBER
);

-- Overloaded version
--
PROCEDURE append
(
	p_xml_doc IN DATE
);

-- Initializes the global XML document variable
--
PROCEDURE initialize_doc
(
	p_msg_code IN VARCHAR2
	,p_dtd_url IN VARCHAR2
);

-- Overloaded version
--
PROCEDURE initialize_doc ;

-- Declaration for an XML
--
PROCEDURE xml_decl ;

-- Retrieves the constructed XML document
--
PROCEDURE get_document
(
	p_xml_doc OUT NOCOPY VARCHAR2
);

-- Writes a character element to an XML document
--
PROCEDURE write_element
(
	p_tag IN VARCHAR2
	,x_value IN VARCHAR2
);

-- Writes a date element to an XML document
--
PROCEDURE write_element
(
	P_TAG IN VARCHAR2
	,x_value IN DATE
 );

-- Writes a numeric element tot an XML document
--
PROCEDURE write_element
(
	p_tag IN VARCHAR2
	,x_value IN NUMBER
);


-- Writes a leaf  character element to an XML document
--
PROCEDURE write_leaf_element
(
	p_tag IN VARCHAR2
	,x_value IN VARCHAR2
);


-- Writes a leaf date element to an XML document
--
PROCEDURE write_leaf_element
(
	P_TAG IN VARCHAR2
	,x_value IN DATE
 );

-- Writes a leaf numeric element tot an XML document
--
PROCEDURE write_leaf_element
(
	p_tag IN VARCHAR2
	,x_value IN NUMBER
);

-- Adds an end tag to the element being specified
--
PROCEDURE end_segment
(
	p_tag IN VARCHAR2
);

-- Adds a start tag for the XML element being constructed
--
PROCEDURE begin_segment
(
	p_tag IN VARCHAR2
);


--  Procedure:    CONVERT()
--  Purpose:      Converts a character string to xml CDATA


FUNCTION convert ( p_value IN VARCHAR2) RETURN VARCHAR2 ;

-- Global variable to hold the XML document
--

g_XML_document         VARCHAR2 (32767) ;
g_remove_empty_nodes   VARCHAR2(1) := 'N';

END xnp_xml_utils;

 

/
