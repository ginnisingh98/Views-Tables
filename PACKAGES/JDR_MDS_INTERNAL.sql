--------------------------------------------------------
--  DDL for Package JDR_MDS_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JDR_MDS_INTERNAL" AUTHID CURRENT_USER AS
/* $Header: JDRMDINS.pls 120.3 2005/10/26 06:15:35 akbansal noship $ */
  -----------------------------------------------------------------------------
  ---------------------------- PRIVATE VARIABLES ------------------------------
  -----------------------------------------------------------------------------
  -- Maximum # of attempts to try when locking
  MAX_SECONDS_TO_WAIT_FOR_LOCK CONSTANT INTEGER := 10;

  --
  -- Creates an entry in the jdr_paths table for the document or package.
  -- The full name of the document/package must be specified.  Any packages
  -- which do not already exist will be created as well.
  --
  -- Parameters:
  --   username     - user who is creating the document
  --   fullPathName - the complete path name of the document or package
  --   docType      - either 'PACKAGE' or 'DOCUMENT'
  --   xmlversion   - xml version
  --   xmlencoding  - xml encoding
  --
  -- Returns:
  --   the ID of the created path
  --
  FUNCTION createPath(
    username     VARCHAR2,
    fullPathName VARCHAR2,
    docType      VARCHAR2,
    xmlversion   VARCHAR2,
    xmlencoding  VARCHAR2) RETURN NUMBER;


  --
  -- Creates an entry in the jdr_paths document.
  --
  -- Parameters:
  --   username     - user who is creating the document
  --   pathname     - the name of the document/package (not fully qualified)
  --   ownerID      - the ID of the owning package
  --   pathSeq      - sequence of the path
  --   docType      - either 'DOCUMENT' or 'PACKAGE'
  --   xmlversion   - xml version, which can be null for "child" documents
  --   xmlencoding  - xml encoding, which can be null for "child" documents
  --
  -- Returns:
  --   the ID of the created path

  --
  FUNCTION createPath(
    username    VARCHAR2,
    pathname    VARCHAR2,
    ownerID     JDR_PATHS.PATH_OWNER_DOCID%TYPE,
    pathSeq     JDR_PATHS.PATH_SEQ%TYPE,
    docType     VARCHAR2,
    xmlversion  VARCHAR2 DEFAULT NULL,
    xmlencoding VARCHAR2 DEFAULT NULL) RETURN NUMBER;


  --
  -- Delete the document.
  --
  -- Parameters:
  --   docID  - ID of the document to delete
  --   isDrop - should the document be dropped as well.  If TRUE, then the
  --            document will be completely removed.  If FALSE, then only
  --            the contents of the document will be deleted, and the entry
  --            in the jdr_paths table will remain.
  --
  -- Notes:
  --   If the document is a package document, then the "child" documents will
  --   be deleted as well.
  --
  PROCEDURE deleteDocument(
    docID      JDR_PATHS.PATH_DOCID%TYPE,
    isDrop     BOOLEAN DEFAULT FALSE);

  --
  -- Drops the document and the document's contents from the repository.
  -- If the document is a package document, the "child" documents of the
  -- package document will be dropped as well.
  --
  PROCEDURE dropDocument(
    docID      JDR_PATHS.PATH_DOCID%TYPE);


  --
  -- This method has been deprecated.  Please use the function which
  -- has a return value which indicates whether or not the export is
  -- complete.
  --
  -- Export the XML for a document and pass it back in 32k chunks.  This
  -- function will return XML chunks, with a maximum size of 32k.  When
  -- the entire document has been exported, this function will return NULL.
  --
  -- Specifying a document name will initiate the export.  Thereafter, a NULL
  -- document name should be passed in until the export is complete.
  -- That is, to export an entire document, you should do:
  --
  -- firstChunk := jdr_mds_internal.exportDocumentAsXML('/oracle/apps/fnd/mydoc');
  -- LOOP
  --   nextChunk := jdr_mds_internal.exportDocumentAsXML(NULL);
  --   EXIT WHEN nextChunk IS NULL;
  -- END LOOP;
  --
  -- Parameters:
  --   fullName  - the fully qualifued name of the document.  however,
  --               after the first chunk of text is exported, a NULL value
  --               should be passed in.
  --
  --   formatted - a non-zero value indicates that the XML is formatted nicely
  --               (i.e. whether or not the elements are indented)
  --
  --   allowChildDoc - a non-zero value indicates that "child" documents
  --                   can be exported, where child documents are documents
  --                   which exist as part of a package document
  --
  --   includePackage - a non-zero value indicates that, if this is a "child"
  --                    document and it allowChildDoc is TRUE, then the entire
  --                    package document should be exported; otherwise, only
  --                    the XML for the child document will be exported.
  --
  -- Returns:
  --   The exported XML, in 32k chunks.
  --
  FUNCTION exportDocumentAsXML(
    fullName       VARCHAR2,
    formatted      INTEGER DEFAULT 1,
    allowChildDoc  INTEGER DEFAULT 0,
    includePackage INTEGER DEFAULT 0) RETURN VARCHAR2;


  --
  -- Export the XML for a document and pass it back in 32k chunks.  This
  -- function will return XML chunks, with a maximum size of 32k.
  --
  -- Specifying a document name will initiate the export.  Thereafter, a NULL
  -- document name should be passed in until the export is complete.
  -- That is, to export an entire document, you should do:
  --
  -- firstChunk := jdr_mds_internal.exportDocumentAsXML(isDone,
  --                                                    '/oracle/apps/fnd/mydoc');
  -- WHILE (isDone = 0)
  --   nextChunk := jdr_mds_internal.exportDocumentAsXML(isDone, NULL);
  -- END LOOP;
  --
  -- Parameters:
  --   exportFinished - OUT parameter which indicates whether or not the export
  --                    is complete.  1 indicates the entire document is
  --                    exported, 0 indicates that there are more chunks
  --                    remaining.
  --
  --   fullName  - the fully qualifued name of the document.  however,
  --               after the first chunk of text is exported, a NULL value
  --               should be passed in.
  --
  --   formatted - a non-zero value indicates that the XML is formatted nicely
  --               (i.e. whether or not the elements are indented)
  --
  --   allowChildDoc - a non-zero value indicates that "child" documents
  --                   can be exported, where child documents are documents
  --                   which exist as part of a package document
  --
  --   includePackage - a non-zero value indicates that, if this is a "child"
  --                    document and it allowChildDoc is TRUE, then the entire
  --                    package document should be exported; otherwise, only
  --                    the XML for the child document will be exported.
  --
  -- Returns:
  --   The exported XML, in 32k chunks.
  --
  FUNCTION exportDocumentAsXML(
    exportFinished OUT NOCOPY /* file.sql.39 change */ INTEGER,
    fullName           VARCHAR2,
    formatted          INTEGER DEFAULT 1,
    allowChildDoc      INTEGER DEFAULT 0,
    includePackage     INTEGER DEFAULT 0) RETURN VARCHAR2;


  --
  -- Export the translations in XLIFF format.  The document will be
  -- exported in 32k chunks.
  --
  -- Specifying a document name will initiate the export.  Thereafter, a NULL
  -- document name should be passed in until the export is complete.
  -- That is, to export an entire document, you should do:
  --
  -- firstChunk := jdr_mds_internal.exportXLIFFDocument(isDone,
  --                                                    '/oracle/apps/mydoc',
  --                                                    'mylanguage');
  --
  -- WHILE (isDone = 0) LOOP
  --   nextChunk := jdr_mds_internal.exportXLIFFDocument(isDone, NULL, NULL);
  -- END LOOP;
  --
  FUNCTION exportXLIFFDocument(
    exportFinished OUT NOCOPY /* file.sql.39 change */ INTEGER,
    document           VARCHAR2,
    language           VARCHAR2)  RETURN VARCHAR2;

  --
  -- Retrieves the document id for the specified fully qualified path name.
  -- The pathname must begin with a '/' and should look something like:
  --   /oracle/apps/AK/mydocument
  --
  -- Parameters:
  --   fullPathName  - the fully qualified name of the document
  --   pathType      - the type of the document, either 'DOCUMENT' or 'PACKAGE'
  --                   if no type is specified, and there happens to be a path
  --                   of both 'DOCUMENT' and 'PACKAGE' (which is unlikely),
  --                   then the id of the DOCUMENT will be returned
  --
  -- Returns:
  --   Returns the ID of the path or -1 if no such path exists
  --
  FUNCTION getDocumentID(
    fullPathName VARCHAR2,
    pathType     VARCHAR2 DEFAULT NULL) RETURN NUMBER;


  --
  -- Retrieves the document id for the specified attributes.  This is
  -- typically used when attempting to find the id of a path which is
  -- owned by a package document.
  --
  -- Note that this will return the docID which matches the specified
  -- name, ownerID and docType (not pathSeq).  For the pathSeq, it will
  -- update the database path_seq to the value specified in pathSeq.
  --
  -- Parameters:
  --   name          - the name of the document (not fully qualified)
  --   ownerID       - the ID of the owning package
  --   pathSeq       - the path sequence
  --   docType       - either 'DOCUMENT' or 'PACKAGE'
  --
  -- Returns:
  --   Returns the ID of the path or -1 if no such path exists
  --
  FUNCTION getDocumentID(
    name       VARCHAR2,
    ownerID    JDR_PATHS.PATH_OWNER_DOCID%TYPE,
    pathSeq    JDR_PATHS.PATH_SEQ%TYPE,
    docType    JDR_PATHS.PATH_TYPE%TYPE) RETURN NUMBER;


  --
  -- For each document name, retrieve the corresponding document ID.
  -- The document ID for docs[i] is in docIDs[i]
  --
  PROCEDURE getDocumentIDs(docs   IN   jdr_stringArray,
                           docIDs OUT NOCOPY /* file.sql.39 change */  jdr_numArray);


  --
  -- Given the document id, find the fully qualified document name
  --
  -- Parameters:
  --   docID   - the ID of the document
  --
  -- Returns:
  --   the fully qualified document name
  --
  FUNCTION getDocumentName(
    docID NUMBER) RETURN VARCHAR2;

  --
  -- Given the document id of a child document, find the id for the
  -- owning package document.
  --
  -- Parameters:
  --   docID         - the ID of the child document
  --
  -- Returns:
  --   Returns the ID of the package document or -1 if not found
  --
  FUNCTION getPackageDocument(
    docID NUMBER) RETURN NUMBER;


  --
  -- Gets the minimun version of JRAD with which the repository API is
  -- compatible.  That is, the actual JRAD version must be >= to the
  -- minimum version of JRAD in order for the repositroy API and java code to
  -- be compatible.
  --
  -- Returns:
  --   Returns the mimumum version of JRAD
  --
  FUNCTION getMinJRADVersion RETURN VARCHAR2;


  --
  -- Gets the version of the repository API.  This API version must >= to the
  -- java constant CompatibleVersions.MIN_REPOS_VERSION.
  --
  -- Returns:
  --   Returns the version of the repository
  --
  FUNCTION getRepositoryVersion RETURN VARCHAR2;


  --
  -- Lock the document.  Before updating/saving a document, the document needs
  -- to be locked to insure that it is not updated simultaneously by multiple
  -- users.  If the document is already locked, we will continue to attempt to
  -- lock the document for a user-specified number of seconds, or
  -- MAX_SECONDS_TO_WAIT_FOR_LOCK by default, before giving up.
  -- If, after that time, we have still not locked the document, a
  -- "RESOURCEBUSY" exception will be raised.
  --
  -- Parameters:
  --   docID    - ID of the document to lock
  --   attempts - number of seconds to wait for a lock
  --
  PROCEDURE lockDocument(
    docID      JDR_PATHS.PATH_DOCID%TYPE,
    attempts   INTEGER DEFAULT MAX_SECONDS_TO_WAIT_FOR_LOCK);


  --
  -- Performs all steps that are necessary before a top-level document is
  -- saved/updated which includes:
  -- (1) If the document already exists, updates the "who" columns in
  --     JDR_PATHS and deletes the contents of the document
  -- (2) If the document does not exist yet, creates a new entry in the
  --     JDR_PATHS table
  --
  -- Parameters:
  --   username     - user who is updating/inserting the document
  --   fullPathName - fully qualified name of the document/package file
  --   pathType     - 'DOCUMENT' for document or 'PACKAGE' for package
  --                  file
  --   xmlversion   - xml version
  --   xmlencoding  - xml encoding
  --
  -- Returns:
  --   Returns the ID of the document or -1 if an error occurred
  --
  FUNCTION prepareDocumentForInsert(
    username     VARCHAR2,
    fullPathName VARCHAR2,
    pathType     VARCHAR2,
    xmlversion   VARCHAR2,
    xmlencoding  VARCHAR2) RETURN NUMBER;


  --
  -- Performs all steps that are necessary before a package document is
  -- saved/updated which includes:
  -- (1) If the document already exists, updates the "who" columns in
  --     JDR_PATHS
  -- (2) If the document does not exist yet, creates a new entry in the
  --     JDR_PATHS table
  --
  -- Parameters:
  --   username     - user who is updating/inserting the document
  --   pathname     - name of the document/package
  --   ownerID      - ID of the owning package
  --   pathSeq      - path sequence
  --   pathType     - 'DOCUMENT' or 'PACKAGE'
  --
  -- Returns:
  --   Returns the ID of the document or -1 if an error occurred
  --
  FUNCTION prepareDocumentForInsert(
    username   VARCHAR2,
    pathname   VARCHAR2,
    ownerID    JDR_PATHS.PATH_OWNER_DOCID%TYPE,
    pathSeq    JDR_PATHS.PATH_SEQ%TYPE,
    pathType   JDR_PATHS.PATH_TYPE%TYPE) RETURN NUMBER;


  --
  -- Refactors the specified component/document by making the necessary
  -- changes to any customized documents which customized the "old" document;
  -- and by making the necessary changes (if p_translations is
  -- TRUE) to translations as well.
  --
  -- For more information on the type of changes which are necessary, please
  -- refer to the refactoring document.
  --
  -- Parameters:
  --   p_oldName      - the original name of the component/document
  --   p_newName      - the new name of the component/document
  --   p_translations - make necessary changes to translations if TRUE
  --
  -- Returns:
  --   Returns the number of changes which were made, and 0 if no changes
  --   were necessary
  --
  FUNCTION refactor(
    p_oldName      VARCHAR2,
    p_newName      VARCHAR2,
    p_translations INTEGER DEFAULT 1) RETURN INTEGER;


  --
  -- Remove any dangling references of the document.  This is only necessary
  -- for package documents.  Here's a scenario where this is relevant.
  -- Suppose you have a package document FOO which has child documents A, B and
  -- C.  Now suppose you are updating FOO, this time removing document C.
  -- In order make sure that all references to C are destroyed, this needs to
  -- be called after saving FOO.
  --
  PROCEDURE removeDanglingReferences(
    docID      JDR_PATHS.PATH_DOCID%TYPE);

END;

 

/
