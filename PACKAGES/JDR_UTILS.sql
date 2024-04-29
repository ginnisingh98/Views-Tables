--------------------------------------------------------
--  DDL for Package JDR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JDR_UTILS" AUTHID CURRENT_USER AS
/* $Header: JDRUTEXS.pls 120.3 2005/10/26 06:16:00 akbansal noship $ */

  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC VARIABLES -------------------------------
  -----------------------------------------------------------------------------
  MAX_LINE_SIZE CONSTANT NUMBER := 255;

  -----------------------------------------------------------------------------
  ------------------------------ PUBLIC TYPES ---------------------------------
  -----------------------------------------------------------------------------
  TYPE translation IS RECORD
  (
    lang      jdr_attributes_trans.atl_lang%TYPE,
    compref   jdr_attributes_trans.atl_comp_ref%TYPE,
    name      jdr_attributes_trans.atl_name%TYPE,
    value     jdr_attributes_trans.atl_value%TYPE
  );

  TYPE translationList IS TABLE OF translation;

  -- Exception raised when document does not exist
  no_such_document EXCEPTION;

  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC FUNCTIONS -------------------------------
  -----------------------------------------------------------------------------

  -- Deletes the document from the repository.
  --
  -- Parameters:
  --  p_document    - the fully qualified document name, which can represent
  --                  either a document or package file.
  --                  (i.e.  '/oracle/apps/ak/attributeSets')
  --
  PROCEDURE deleteDocument(p_document VARCHAR2);

  -- Deletes all empty customization documents from the repository. An empty
  -- customization document is a customization document that does not specify
  -- any modifications to the base metadata.
  --
  -- Example 1: /oracle/apps/hr/customizations/localization/US/page1
  -- <customization customizes="/oracle/apps/hr/page1"
  --                xmlns="http://xmlns.oracle.com/jrad"
  --                xmlns:ui="http://xmlns.oracle.com/uix/ui"
  --                xmlns:oa="http://xmlns.oracle.com/oa"
  --                xmlns:user="http://xmlns.oracle.com/jrad/user"
  --                file-version="$Header: JDRUTEXS.pls 120.3 2005/10/26 06:16:00 akbansal noship $" version="9.0.3.6.6_557"
  --                xml:lang="en-US">
  --    <modifications/>
  -- </customization>
  --
  -- Example 2: /oracle/apps/hr/customizations/user/100/page1
  -- <customization customizes="/oracle/apps/hr/page1"
  --                xmlns="http://xmlns.oracle.com/jrad"
  --                xmlns:ui="http://xmlns.oracle.com/uix/ui"
  --                xmlns:oa="http://xmlns.oracle.com/oa"
  --                xmlns:user="http://xmlns.oracle.com/jrad/user"
  --                file-version="$Header: JDRUTEXS.pls 120.3 2005/10/26 06:16:00 akbansal noship $" version="9.0.3.6.6_557"
  --                xml:lang="en-US">
  --   <views>
  --     <view name="MyTest10" description="my view"
  --           id="view1" element="Region1">
  --       <modifications/>
  --     </view>
  --   <views/>
  -- <customization/>
  --
  PROCEDURE deleteEmptyCustomizations;


  -- Deletes the package from the repository if the package is empty.  If the
  -- package is not empty (i.e. it contains either documents or packages), then
  -- an error will be issued indicated that non-empty packages can not be
  -- deleted.
  --
  -- Parameters:
  --  p_package    - the fully qualified package name
  --                 (i.e.  '/oracle/apps')
  --
  PROCEDURE deletePackage(p_package VARCHAR2);

  --
  -- Export the XML for a document and pass it back in 32k chunks.  This
  -- function will return XML chunks, with a maximum size of 32k.
  --
  -- Specifying a document name will initiate the export.  Thereafter, a NULL
  -- document name should be passed in until the export is complete.
  -- That is, to export an entire document, you should do:
  --
  -- firstChunk := jdr_utils.exportDocument('/oracle/apps/fnd/mydoc', isDone);
  -- WHILE (NOT isDone) LOOP
  --   nextChunk := jdr_utils.exportDocument(NULL, isDone);
  -- END LOOP;
  --
  -- Parameters:
  --   p_document       - the fully qualified name of the document.  However,
  --                      after the first chunk of text is exported, a NULL
  --                      value must be passed in to retrieve the next
  --                      chunks.
  --
  --   p_exportFinished - OUT parameter which indicates whether or not the export
  --                      is complete.  TRUE indicates the entire document is
  --                      exported, FALSE indicates that there are more chunks
  --                      remaining.
  --
  --   p_formatted      - TRUE indicates that the XML is formatted nicely
  --                      (i.e. whether or not the elements are indented).
  --                      This is defaulted to TRUE.
  --
  --
  -- Returns:
  --   The exported XML, in 32k chunks.
  --
  -- Notes:
  --   As this function relies on package state, it is not possible to export
  --   multiple documents at the same time.  A document must be finished
  --   exporting before a new document can be exported.
  --
  FUNCTION exportDocument(
    p_document           VARCHAR2,
    p_exportFinished OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
    p_formatted          BOOLEAN DEFAULT TRUE) RETURN VARCHAR2;


  -- Gets the fully qualified name of the component.
  --
  -- Parameters:
  --  p_docid       - the ID of the document which contains the component
  --
  --  p_compid      - the ID of the component (from comp_id in the
  --                  jdr_components table
  --
  FUNCTION getComponentName(
    p_docid  jdr_paths.path_docid%TYPE,
    p_compid jdr_components.comp_id%TYPE) RETURN VARCHAR2;


  -- Gets the fully qualified name of the document.
  --
  -- Parameters:
  --  p_docid       - the ID of the document
  FUNCTION getDocumentName(
    p_docid  jdr_paths.path_docid%TYPE) RETURN VARCHAR2;


  -- Gets all of the translations of the specified document.
  --
  -- Parameters:
  --  p_document    - the fully qualified document name
  --
  -- Raises NO_SUCH_DOCUMENT exception if the document does not exist.
  --
  FUNCTION getTranslations(
    p_document VARCHAR2) RETURN translationList;


  -- Prints the contents of a package.
  --
  -- For the non-recursive case, this will list the documents,
  -- package files and package directories.
  --
  -- For the recursive case, this will list the document, package files
  -- and empty package directories (i.e. packages which contain no documents
  -- or child packages).
  --
  -- In order to diferentiate documents from package directories, package
  -- directories will end with a '/'.
  --
  -- Parameters:
  --  p_path       - The path in which to list the documents.  To specify
  --                 the root directory, use '/'.
  --
  --  p_recursive  - If TRUE, recursively lists the contents of
  --                 sub-directories.  Defaults to FALSE.
  --
  -- To use this from SQL*Plus, do:
  --
  -- (1) set serveroutput on
  --     execute jdr_utils.listContents('/oracle/apps/ak');
  --     This will list the contents of the ak directory, without showing
  --     the contents of the sub-directories.
  --
  -- (2) set serveroutput on
  --     execute jdr_utils.listContents('/', TRUE);
  --     This will list the contents of the entire repository.
  --     sub-directories.
  --
  PROCEDURE listContents(p_path VARCHAR2, p_recursive BOOLEAN DEFAULT FALSE);


  -- List the customizations for the specified document.
  --
  -- Parameters:
  --  p_document    - the fully qualified document name, which can represent
  --                  either a document or package file.
  --                  (i.e.  '/oracle/apps/ak/attributeSets')
  --
  PROCEDURE listCustomizations(p_document VARCHAR2);


  -- List the contents of a package.
  -- DEPRECATED: This has been replaced by listContents
  PROCEDURE listDocuments(p_path VARCHAR2, p_recursive BOOLEAN DEFAULT FALSE);


  -- Lists the supported languages for the specified document.
  --
  -- Parameters:
  --  p_document    - the fully qualified document name, which can represent
  --                  either a document or package file.
  --                  (i.e.  '/oracle/apps/ak/attributeSets')
  --
  PROCEDURE listLanguages(p_document VARCHAR2);


  -- Prints the contents of a JRAD document to the console.
  --
  -- Parameters:
  --  p_document    - the fully qualified document name, which can represent
  --                  either a document or package file.
  --                  (i.e.  '/oracle/apps/ak/attributeSets')
  --
  --  p_maxLineSize - the maximum size of line.  This defaults to 255 which is
  --                  the maximim allowable size of a line (the 255 limit is
  --                  a limitation of the DBMS_OUPUT package).
  --
  -- Limitations:
  --  Documents larger than 1000000 bytes will fail as DBMS_OUPUT's maximim
  --  buffer is 1000000 bytes.
  --
  -- To use this from SQL*Plus, do:
  --   set serveroutput on format wrapped (this is needed for leading spaces)
  --   set linesize 100
  --   execute jdr_utils.printDocument('/oracle/apps/ak/attributeSets', 100);
  --
  -- To create an XML file, you can create the following SQL file:
  --   set feedback off
  --   set serveroutput on format wrapped
  --   set linesize 100
  --   spool (parameter 1)
  --   execute jdr_utils.printDocument('(parameter 2)', 100);
  --   spool off
  --
  -- and call the file with:
  --   sqlplus scott/tiger @export.sql myxml.xml /oracle/apps/ak/attributeSets
  PROCEDURE printDocument(p_document    VARCHAR2,
                          p_maxLineSize NUMBER DEFAULT MAX_LINE_SIZE);


  -- Prints the translations for the document in XLIFF format.
  --
  -- Parameters:
  --  p_document    - the fully qualified document name, which can represent
  --                  either a document or package file.
  --                  (i.e.  '/oracle/apps/ak/attributeSets')
  --
  --  p_language    - the language to use for the translations
  --
  --  p_maxLineSize - the maximum size of line.  This defaults to 255 which is
  --                  the maximim allowable size of a line (the 255 limit is
  --                  a limitation of the DBMS_OUPUT package).
  --
  -- To use this from SQL*Plus, do:
  --   set serveroutput on format wrapped (this is needed for leading spaces)
  --   set linesize 100
  --   execute jdr_utils.printTranslations('/oracle/apps/ak/attributeSets',
  --                                       'mylanguage', 100);
  --
  PROCEDURE printTranslations(p_document    VARCHAR2,
                              p_language    VARCHAR2,
                              p_maxLineSize NUMBER DEFAULT MAX_LINE_SIZE);


  -- Saves the specified translations for the specified document.
  --
  -- This procedure will do the following:
  --  (1) Lock the document so as to prevent multiple users attempting
  --      to modify translations at the same time
  --  (2) Delete all of the translations for the specified document
  --  (3) Insert the new translations
  --  (4) Commit the data unless p_commit set to FALSE
  --
  -- Please use this with care as it will delete all of the
  -- translations for the specified document.
  --
  -- Parameters:
  --  p_document     - the fully qualified document name
  --
  --  p_translations - the list of translations to insert
  --
  --  p_commit       - if TRUE, the data is committed.  Default is TRUE
  --
  -- NOTE: If p_commit is set to FALSE, then the document will remain locked
  -- after the call to saveTranslations.  In order to prevent a deadlock, a
  -- commit (or rollback) must occur to unlock the document.
  --
  -- Raises NO_SUCH_DOCUMENT exception if the document does not exist.
  --
  PROCEDURE saveTranslations(
    p_document     VARCHAR2,
    p_translations translationList,
    p_commit       BOOLEAN := TRUE);


  -----------------------------------------------------------------------------
  ---------------------------- TO BE IMPLEMENTED ------------------------------
  -----------------------------------------------------------------------------

  -- Moves the document to a different location
  --
  -- Parameters:
  --  p_src         - the fully qualified 'old' document name
  --
  --  p_dest        - the fully qualified 'new' document name
  --
  -- PROCEDURE moveDocument(p_src VARCHAR2, p_dest);

  -- Imports the document
  --
  -- Parameters:
  --  p_file        - the name of the XML file to import
  --
  -- Issues:
  --   There are a couple of issues with this.  One, the 'brains' of the
  --   importer currently reside in Java (i.e. Java does the parsing of the
  --   XML) and I don't think we want to have a different parser for Java and
  --   a different parser for PL/SQL.  Two, I am not aware of a way to acccess
  --   files which reside on the client machine (UTL_FILE works on files on
  --   the database server).
  -- PROCEDURE importDocument(p_file VARCHAR2);

  -- Imports the document
  --
  -- Parameters:
  --  p_file        - the name of the XLIFF file to import
  --
  -- Issues:
  --   See issues for importDocument
  -- PROCEDURE importTranslations(p_file VARCHAR2);

END;

 

/
