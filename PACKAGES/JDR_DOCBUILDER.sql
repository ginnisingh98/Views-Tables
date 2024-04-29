--------------------------------------------------------
--  DDL for Package JDR_DOCBUILDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JDR_DOCBUILDER" AUTHID CURRENT_USER AS
/* $Header: JDRDBEXS.pls 115.6 2004/07/23 05:16:20 nigoel noship $ */

  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC VARIABLES -------------------------------
  -----------------------------------------------------------------------------
  -- Valid Namespaces
  JRAD_NS CONSTANT VARCHAR2(5) := 'jrad:';
  OA_NS   CONSTANT VARCHAR2(5) := 'oa:';
  UI_NS   CONSTANT VARCHAR2(5) := 'ui:';
  USER_NS CONSTANT VARCHAR2(5) := 'user:';

  -- Save Constants
  SUCCESS CONSTANT PLS_INTEGER := 1;
  FAILURE CONSTANT PLS_INTEGER := 0;

  -- Types
  TYPE ELEMENT  IS RECORD ( id PLS_INTEGER );
  TYPE DOCUMENT IS RECORD ( id PLS_INTEGER );

  -- User-defined Exceptions

  -- INVALID_NAMESPACE exception is thrown when an invalid namespace is
  -- provided as a parameter. The namespace must be JRAD_NS, OA_NS, UI_NS,
  -- or USER_NS. These constants are defined as part of the jdr_docbuilder
  -- package
  INVALID_NAMESPACE  EXCEPTION;

  -- REF_NOT_FOUND exception is thrown when the given reference does not
  -- exist in the MDS repository.
  REF_NOT_FOUND      EXCEPTION;

  -- NOT_DOCUMENT_REF exception is thrown when the given reference exists
  -- in the MDS repository, however it is not a MDS document. For example,
  -- the reference could correspond to a MDS package.
  NOT_DOCUMENT_REF   EXCEPTION;

  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC FUNCTIONS -------------------------------
  -----------------------------------------------------------------------------


  -- Add a child to the element, into the specified grouping.
  --
  -- Parameters:
  --  p_parent     - The parent element
  --  p_groupingNS - The namespace of the grouping. This value should be one of
  --               the following constants: JRAD_NS, OA_NS, UI_NS, USER_NS.
  --  p_groupingTagName - The name of the grouping.
  --  p_child      - The child element
  --
  -- Exceptions:
  --    Raises INVALID_NAMESPACE exception if an invalid namespace is specified.
  --
  PROCEDURE addChild(
      p_parent            ELEMENT,
      p_groupingNS        VARCHAR2,
      p_groupingTagName   VARCHAR2,
      p_child             ELEMENT);


  -- Add a child directly to the element, without a grouping.
  --
  -- Parameters:
  --  p_parent     - The parent element
  --  p_child      - The child element
  --
  --
  PROCEDURE addChild(
      p_parent            ELEMENT,
      p_child             ELEMENT);


  --
  -- Creates an MDS Document object. The full name of the document must be
  -- specified, as well as the base language of the document. If no base
  -- language is provided, the default language is English-US.
  --
  -- Parameters:
  --   p_fullPathName - the complete path name of the document
  --   p_language     - the language of the document
  --
  -- Returns:
  --   the document object
  --
  FUNCTION createDocument(
    p_fullPathName VARCHAR2,
    p_language     VARCHAR2 DEFAULT 'en-US') RETURN DOCUMENT;


  --
  -- Creates an MDS Document object that is a child document within an
  -- existing package file. The full name of the document must be specified.
  -- The base language of the document will be the same as its package file.
  --
  -- ex.  If the p_fullPathName is /oracle/apps/hr/regionMap/region1, then
  --      the package file name is /oracle/apps/hr/regionMap
  --      and the document name is region1.
  --
  -- Parameters:
  --   p_fullPathName - the complete path name of the document
  --
  -- Returns:
  --   the document object
  --
  -- Exception:
  --   Raises REF_NOT_FOUND exception if the package file reference does not
  --   exist in the repository, or the reference corresponds to a document
  --   rather than a package file.
  --
  FUNCTION createChildDocument(
    p_fullPathName VARCHAR2) RETURN DOCUMENT;


  --
  -- Creates an MDS Element object. The full name of the document must be
  -- specified, as well as the base language of the document.
  --
  -- Parameters:
  --   p_namespace - the namespace of the element. This value should be one of
  --               the following constants: JRAD_NS, OA_NS, UI_NS, USER_NS.
  --   p_tagName   - the type of element, i.e. table, messageTextInput
  --
  -- Returns:
  --   the element object
  --
  -- Exceptions:
  --   Raises INVALID_NAMESPACE exception if an invalid namespace is specified.
  --
  FUNCTION createElement(
    p_namespace VARCHAR2,
    p_tagName   VARCHAR2) RETURN ELEMENT;


  -- Delete a document from the repository. If the provided path name is not
  -- associated with a document (i.e. the path refers to a package),
  -- an exception will be raised.
  --
  -- Parameters:
  --   p_fullPathName - the full document reference
  --
  -- Exception:
  --   Raises REF_NOT_FOUND exception if the reference does not exist in the
  --     MDS repository.
  --   Raises NOT_DOCUMENT_REF exception if the reference does exist in the
  --   repository, but does not refer to a document (i.e. the reference
  --   is a package).
  --
  PROCEDURE deleteDocument(
      p_fullPathName VARCHAR2);


  -- Determine if a document exists in the MDS Repository. The document is
  -- identified by its full reference path.
  --
  -- Parameters:
  --   p_fullPathName - the full document reference
  --
  -- Returns:
  --   TRUE if the document exists in the repository, FALSE otherwise.
  --
  FUNCTION documentExists(
      p_fullPathName VARCHAR2) RETURN BOOLEAN;


  -- Refreshes the document builder utility.  Deletes all documents and elements
  -- which have been created in this package.
  --
  PROCEDURE refresh;


  -- Save all documents which have been created since the last save. If a
  -- document already exists in the repository with the same full reference,
  -- it will be replaced. Any new child documents will be added to the end of
  -- the package file. Any dangling references (i.e. elements created but
  -- never associated with a document) will be lost. At the end of the save,
  -- a refresh is performed.
  --
  -- Returns: SUCCESS or FAILURE
  --
  FUNCTION save RETURN PLS_INTEGER;


  --
  -- Sets the value of the attribute for this element.
  --
  -- Parameters:
  --   p_elem     - The element
  --   p_attName  - The name of the attribute
  --   p_attValue - The attribute value
  --
  PROCEDURE setAttribute(
    p_elem       ELEMENT,
    p_attName    VARCHAR2,
    p_attValue   VARCHAR2);


  --
  -- Set the top-level element in the document.
  --
  -- Parameters:
  --   p_doc  - The document
  --   p_elem - The top-level element
  --
  PROCEDURE setTopLevelElement(
    p_doc      DOCUMENT,
    p_elem     ELEMENT);

END;

 

/
