--------------------------------------------------------
--  DDL for Package Body JDR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JDR_UTILS" AS
/* $Header: JDRUTEXB.pls 120.3 2005/10/26 06:15:47 akbansal noship $ */

  NEWLINE CONSTANT VARCHAR2(1) := '
';

  -----------------------------------------------------------------------------
  ---------------------------- PRIVATE METHODS --------------------------------
  -----------------------------------------------------------------------------

  -- Gets the document ID for a fully qualified document name.
  --
  -- Parameters:
  --  p_document        - fully qualified name
  --
  --  p_type            - the type of document to search for.  In the jrad
  --                      repository, there are the following types of
  --                      jrad paths.
  --                      (1) Document file - XML file representing a document
  --                      (2) Package file - XML file representing a package
  --                      (3) Child document - document inside a package file
  --                      (4) Package directory - a directory
  --
  --                      This parameter can be one of the following:
  --                      DOCUMENT - matches (1) and (3) above
  --                      PACKAGE  - matches (2) and (4) above
  --                      FILE     - matches (1) and (2) above
  --                      NONPATH  - matches (1) and (2) and (3)
  --                      PATH     - matches (4) above
  --                      ANY      - matches (1) and (2) and (3) and (4) above
  FUNCTION getDocumentID(
    p_document VARCHAR2,
    p_type     VARCHAR2 DEFAULT 'ANY') RETURN jdr_paths.path_docid%TYPE
  IS
    docID    jdr_paths.path_docid%TYPE;
    pathType jdr_paths.path_type%TYPE;
    pathSeq  jdr_paths.path_seq%TYPE;
  BEGIN
    -- Get the ID of the document
    docID := jdr_mds_internal.getDocumentID(p_document);

    -- Verify that we have found a document of the correct type
    IF ((docID <> -1) AND (p_type <> 'ANY')) THEN
      SELECT path_type, path_seq INTO pathType, pathSeq
      FROM jdr_paths WHERE path_docid = docID;

      IF (p_type = 'FILE') THEN
        -- Make sure we are dealing with a document or package file
        IF ((pathType = 'DOCUMENT' AND pathSeq = -1) OR
            (pathType = 'PACKAGE' AND pathSeq = 0)) THEN
          RETURN (docID);
        END IF;
      ELSIF (p_type = 'DOCUMENT') THEN
        -- Make sure we are dealing with a document
        IF (pathType = 'DOCUMENT') THEN
          RETURN (docID);
        END IF;
      ELSIF (p_type = 'PACKAGE') THEN
        IF (pathType = 'PACKAGE') THEN
          RETURN (docID);
        END IF;
      ELSIF (p_type = 'PATH') THEN
        IF ((pathType = 'PACKAGE') AND (pathSeq = -1)) THEN
          RETURN (docID);
        END IF;
      ELSIF (p_type = 'NONPATH') THEN
        IF ((pathType <> 'PACKAGE') OR (pathSeq = 0)) THEN
          RETURN (docID);
        END IF;
      END IF;

      -- No match found
      RETURN (-1);
    END IF;

    RETURN (docID);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN (-1);
  END;


  -- Prints a chunk of JRAD XML.  Since we are using DBMS_OUPUT to print
  -- the document to the console and since DBMS_OUPUT has lots of limitations,
  -- this procedure is a lot more complicated that it should be.
  --
  -- Parameters:
  --  p_chunk           - the chunk of XML to print
  --
  --  p_maxLineSize     - the maximum allowable size for the line.
  --
  --  p_unclosedQuote  - TRUE indicates that the previous line was in the
  --                     middle of a name/value pair.  Also, if the current
  --                     line is in the middle of a name/value pair, this
  --                     will be set to TRUE; if not, this will be set to
  --                     FALSE.
  --
  --  p_indent         - amount of whitespace which the current line should be
  --                     indented.  ALso, this will be set to the amount of
  --                     whitespace the next line should be indented.  This
  --                     is needed for when an element does not completely
  --                     fit on one line.
  --
  PROCEDURE printChunk(
    p_chunk         IN     VARCHAR2,
    p_maxLineSize   IN     NUMBER,
    p_unclosedQuote IN OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
    p_indent        IN OUT NOCOPY /* file.sql.39 change */ NUMBER)
  IS
    left                   VARCHAR2(255);
    right                  VARCHAR2(32767);
    tmppos                 NUMBER;
    pos                    NUMBER;
    len                    NUMBER;
  BEGIN
    -- If the chunk is less than the maximum line size (including the
    -- starting position), then all we need to do is simply print the chunk
    -- and reset the starting position.
    len := LENGTH(p_chunk) + p_indent;
    IF (len <= p_maxLineSize) THEN
      DBMS_OUTPUT.PUT_LINE(LPAD(p_chunk, len));

      -- As we are "ending" an element, we can safely reset the "state"
      p_indent := 0;
      p_unclosedQuote := FALSE;

      RETURN;
    END IF;

    -- We could not put the chunk in one line, so we have some work to do.
    -- Here is an explanation of the general algorithm...
    --
    -- (1) Find the position in which the element ends.  If it ends before
    --     the maximum line size is ended, then we can print the element here
    --     and recursively call printChunk() to print the remaining portion
    --     of the chunk.
    --
    -- (2) If the element can not fit on the line, then we will print as
    --     many name/value pairs of the element which will fit on the line.
    --     And to make the printing "prettier", we will indent the next line
    --     to the beginning of where the first name/value pair started.
    --
    -- (3) If not a single name/value pair can fit on the line, then we attempt
    --     to break up the name/value pair using whitespace; and set the
    --     p_unclosedQuote parameter to indicate we are in the middle of a
    --     name/value pair.
    --
    -- (4) If we can not even break up the name/value pair using whitespace,
    --     then we simply print as much of the value as we can and hope that
    --     it will look ok.
    pos := INSTR(p_chunk, NEWLINE, 1);
    IF (pos = 0) THEN
      pos := INSTR(p_chunk, '>', 1);
    ELSE
      pos := pos - 1;
    END IF;

    -- There should always be an end tag.  If not something is very wrong.
    IF (pos = 0) THEN
      DBMS_OUTPUT.PUT_LINE('Error printing document, no end tag encountered.');
      RETURN;
    END IF;

    -- If the current element can not fit on the line, so we will have to put
    -- part of the element on this line, and the rest on future lines.
    IF ((pos + p_indent) > p_maxLineSize) THEN
      tmppos := 0;
      pos := 0;
      left := SUBSTR(p_chunk, 1, p_maxLineSize - p_indent);
      LOOP
        -- Find as many name/value pairs as will fit on this line.  If
        -- p_unclosedQuote is TRUE, then the previous line did not complete
        -- the name/value pair, so we just need to look for one double quote.
        -- Otherwise, two double quotes indicate that a name/value pair is
        -- ended.
        IF (p_unclosedQuote) THEN
          tmppos := INSTR(left, '"', pos + 1, 1);
        ELSE
          tmppos := INSTR(left, '"', pos + 1, 2);
        END IF;

        -- Look for another name/value pair if we found a match.
        IF (tmppos = 0) THEN
          IF (pos > 0) THEN
            -- If we found at least one name/value pair, then we are ok to
            -- print the parial element.  This corresponds to (2) above.
            p_unclosedQuote := FALSE;
            EXIT;
          ELSE
            -- We are not able to put a name/value pair on the current line.
            -- This is likely because of a very long value.  The best thing we
            -- can do is try to end the line on a space.  If we do find a
            -- space, this will correspond to (3) above.
            pos := INSTR(left, ' ', -1);
            IF (pos = 0) THEN
              -- We have a very long value with no spaces in it - this
              -- corresponds to (4) above.
              pos := p_maxLineSize - p_indent;
            END IF;
            p_unclosedQuote := TRUE;
            EXIT;
          END IF;
        END IF;

     	  -- A name/value pair which fits on the current line has been found.
        -- Save the position and check if any more name/value pairs can fit on
        -- this line.
        pos := tmppos;
      END LOOP;

      -- Print the partial element
      left := LPAD(SUBSTR(p_chunk, 1, pos), pos + p_indent);
      DBMS_OUTPUT.PUT_LINE(left);

      -- Remember indentation for the next line
      IF (p_indent = 0) THEN
        p_indent := LENGTH(left) -
                    LENGTH(LTRIM(left)) +
                    INSTR(LTRIM(left), ' ', 1);
      END IF;

      -- Get the remaining portion of the chunk
      right := LTRIM(SUBSTR(p_chunk, pos + 1));
    ELSE
      -- This corresponds to (1) above, the element fitting on one line.
      -- Print the element
      left := LPAD(SUBSTR(p_chunk, 1, pos), pos + p_indent);
      DBMS_OUTPUT.PUT_LINE(left);

      -- As we are "ending" an element, we can safely reset the "state"
      p_indent := 0;
      p_unclosedQuote := FALSE;

      -- Get the remaining portion of the chunk
      tmppos := INSTR(p_chunk, NEWLINE, pos + 1);
      right := SUBSTR(p_chunk, tmppos + 1);
    END IF;

    -- Print the remaining string
    printChunk(right, p_maxLineSize, p_unclosedQuote, p_indent);
  END;


  PROCEDURE printChunk(p_chunk IN VARCHAR2, p_maxLineSize NUMBER)
  IS
    unclosedQuote  BOOLEAN := FALSE;
    indent         NUMBER  := 0;
  BEGIN
    printChunk(p_chunk, p_maxLineSize, unclosedQuote, indent);
  END;


  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC METHODS ---------------------------------
  -----------------------------------------------------------------------------

  -- Deletes the document from the repository.
  --
  -- Parameters:
  --  p_document    - the fully qualified document name, which can represent
  --                  either a document or package file.
  --                  (i.e.  '/oracle/apps/ak/attributeSets')
  --
  PROCEDURE deleteDocument(p_document VARCHAR2)
  IS
    docID    JDR_PATHS.PATH_DOCID%TYPE;
  BEGIN
    -- Get the ID of the document
    docID := getDocumentID(p_document, 'FILE');
    IF (docID = -1) THEN
      dbms_output.put_line('Error: Could not find document ' || p_document);
      RETURN;
    END IF;

    -- Drop the document
    jdr_mds_internal.dropDocument(docID);
    dbms_output.put_line('Successfully deleted document ' || p_document || '.');
  END;

  -- Deletes all empty customization documents from the repository
  PROCEDURE deleteEmptyCustomizations
  IS
    CURSOR c_docs IS
      SELECT path_docid
      FROM jdr_paths
      WHERE jdr_mds_internal.getDocumentName(path_docid)
            LIKE '%/customizations/%' AND
            path_type = 'DOCUMENT';
    CURSOR c_comps(docID JDR_COMPONENTS.COMP_DOCID%TYPE) IS
      SELECT comp_element
      FROM jdr_components
      WHERE comp_docid = docID;
    CURSOR c_atts(docID  JDR_ATTRIBUTES.ATT_COMP_DOCID%TYPE,
                  compID JDR_ATTRIBUTES.ATT_COMP_SEQ%TYPE) IS
      SELECT att_name
      FROM jdr_attributes
      WHERE att_comp_docid = docID AND
            att_comp_seq = compID;
    docID     JDR_PATHS.PATH_DOCID%TYPE;
    compElem  JDR_COMPONENTS.COMP_ELEMENT%TYPE;
    attName   JDR_ATTRIBUTES.ATT_NAME%TYPE;
    compsIsEmpty BOOLEAN;
    attsIsEmpty  BOOLEAN;
  BEGIN
    dbms_output.enable(1000000);
    -- Loop through all customization documents in the repository
    OPEN c_docs;
    LOOP
      FETCH c_docs INTO docID;
      IF (c_docs%NOTFOUND) THEN
        CLOSE c_docs;
        EXIT;
      END IF;
      compsIsEmpty := TRUE;
      attsIsEmpty  := FALSE;
      -- For each document, loop through all component names
      OPEN c_comps(docID);
      LOOP
        FETCH c_comps INTO compElem;
        IF (c_comps%NOTFOUND) THEN
          CLOSE c_comps;
          EXIT;
        END IF;
        -- If the component name is not 'customization', 'modifications', or
        -- 'view', then this is not an empty customization document.
        -- Modifications may be an element, rather than a grouping, if it
        -- appears in the form <modifications/>
        IF compElem <> 'customization' AND
           compElem <> 'modifications'  AND
           compElem <> 'view' THEN
          compsIsEmpty := FALSE;
          CLOSE c_comps;
          EXIT;
        END IF;
      END LOOP;
      IF compsIsEmpty THEN
        attsIsEmpty := TRUE;
        -- Look at all attributes of the <customization> element.
        OPEN c_atts(docID, 0);
        LOOP
          FETCH c_atts INTO attName;
          IF (c_atts%NOTFOUND) THEN
            CLOSE c_atts;
            EXIT;
          END IF;
          IF attName <> 'customizes'    AND
             attName <> 'xml:lang'      AND
             attName <> 'version'       AND
             attName <> 'file-version'  AND
             attName <> 'developerMode' AND
             attName <> 'MDSActiveDoc'  AND
             instr(attName, 'xmlns') <> 1  THEN
            attsIsEmpty := FALSE;
            CLOSE c_atts;
            EXIT;
          END IF;
        END LOOP;
      END IF;
      IF attsIsEmpty THEN
        -- This is an empty customization document
        dbms_output.put_line('Deleting ' ||
                             jdr_mds_internal.getDocumentName(docID));
        jdr_mds_internal.dropDocument(docID);
      END IF;
    END LOOP;
  END;


  -- Deletes the package from the repository if the package is empty.
  --
  -- Parameters:
  --  p_package    - the fully qualified package name
  --                 (i.e.  '/oracle/apps')
  --
  PROCEDURE deletePackage(p_package VARCHAR2)
  IS
    docID    JDR_PATHS.PATH_DOCID%TYPE;
    contents INTEGER;
  BEGIN
    -- Get the ID of the document
    docID := getDocumentID(p_package, 'PATH');
    IF (docID = -1) THEN
      dbms_output.put_line('Error: Could not find package ' || p_package);
      RETURN;
    END IF;

    -- Make sure that the package is empty
    SELECT COUNT(*) INTO contents
    FROM jdr_paths
    WHERE path_owner_docid = docID;

    IF (contents <> 0) THEN
      dbms_output.put_line('Error: Unable to delete ' || p_package ||
                           ' since it contains documents and/or packages.');
      RETURN;
    END IF;

    jdr_mds_internal.dropDocument(docID);
    dbms_output.put_line('Successfully deleted package ' || p_package || '.');
  END;


  --
  -- Export the XML for a document and pass it back in 32k chunks.  This
  -- function will return XML chunks, with a maximum size of 32k.
  FUNCTION exportDocument(
    p_document           VARCHAR2,
    p_exportFinished OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
    p_formatted          BOOLEAN DEFAULT TRUE) RETURN VARCHAR2
  IS
    chunk          VARCHAR2(32000);
    exportFinished INTEGER;
    formatted      INTEGER;
  BEGIN
    IF (p_formatted) THEN
      formatted := 1;
    ELSE
      formatted := 0;
    END IF;

    -- Get the the contents of the XML document.  If p_document is not null,
    -- this will retrieve the first chunk of the document.  If p_document is
    -- null, then we are retrieving a subsequent chunk of the document.
    --
    -- It's a little ugly that we have to switch between INTEGERs and BOOLEANs,
    -- but jdr_mds_internal.exportDocumentAsXML is called from JDBC and,
    -- unfortunately, JDBC does not have support for BOOLEAN parameters, so
    -- that's why we have to do the conversion.
    chunk := jdr_mds_internal.exportDocumentAsXML(exportFinished,
                                                  p_document,
                                                  formatted);

    p_exportFinished := (exportFinished = 1);

    return (chunk);
  END;


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
    p_compid jdr_components.comp_id%TYPE) RETURN VARCHAR2
  IS
    separator  VARCHAR2(1) := NULL;
  BEGIN
    IF (p_compid IS NOT NULL) THEN
      separator := '.';
    END IF;

    RETURN (getDocumentName(p_docid)||separator||p_compid);
  END;


  -- Gets the fully qualified name of the document.
  --
  -- Parameters:
  --  p_docid       - the ID of the document
  FUNCTION getDocumentName(
    p_docid  jdr_paths.path_docid%TYPE) RETURN VARCHAR2
  IS
  BEGIN
    RETURN (jdr_mds_internal.getDocumentName(p_docid));
  END;


  -- Gets all of the translations of the specified document.
  FUNCTION getTranslations(
    p_document VARCHAR2) RETURN translationList
  IS
    CURSOR cTrans(p_docID jdr_paths.path_docid%TYPE) IS
      SELECT
        atl_lang, atl_comp_ref, atl_name, atl_value
      FROM
        jdr_attributes_trans
      WHERE
        atl_comp_docid = p_docID
      ORDER BY
        atl_lang;

    docID      jdr_paths.path_docid%TYPE;
    trans      translationList;
    pos        BINARY_INTEGER;
  BEGIN
    -- Get the document ID for this document
    docID := getDocumentID(p_document, 'FILE');
    IF (docID = -1) THEN
      RAISE no_such_document;
    END IF;

    -- Fetch all of the translations into the translation list
    pos := 0;
    FOR tranRec IN cTrans(docID) LOOP
      IF (pos = 0) THEN
        -- Initialize the translation list
        trans := translationList(NULL);
      ELSE
        -- Extend the list to make room for this translation
        trans.EXTEND;
      END IF;

      pos := pos + 1;
      trans(pos) := tranRec;

      -- Since the compref attribute can not be NULL (as it is part of an index),
      -- we have to save NULL values as '.' in the database.  As this might
      -- be confusing to users, we revert the '.' back to NULL.
      IF (tranRec.atl_comp_ref = '.') THEN
        trans(pos).compref := '';
      END IF;
    END LOOP;

    RETURN (trans);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (NULL);
  END;


  -- Lists the contents of a package.
  PROCEDURE listContents(p_path VARCHAR2, p_recursive BOOLEAN DEFAULT FALSE)
  IS
    -- Selects documents in the current directory
    CURSOR c_docs(docid JDR_PATHS.PATH_DOCID%TYPE) IS
      SELECT
        jdr_mds_internal.getDocumentName(path_docid), path_type, path_seq
      FROM
        jdr_paths
      WHERE
        path_owner_docid = docid AND
        ((path_type = 'DOCUMENT' AND path_seq = -1) OR
         (path_type = 'PACKAGE' AND (path_seq = 0 OR path_seq = -1)));

    -- Selects documents in the current directory, plus its children
    CURSOR c_alldocs(docid JDR_PATHS.PATH_DOCID%TYPE) IS
      SELECT
        jdr_mds_internal.getDocumentName(path_docid), path_type, path_seq
      FROM
        (SELECT path_docid, path_type, path_seq
         FROM jdr_paths
         START WITH path_owner_docid = docid
         CONNECT BY PRIOR path_docid = path_owner_docid) paths
      WHERE
        (path_type = 'DOCUMENT' AND path_seq = -1) OR
        (path_type = 'PACKAGE' AND path_seq = 0) OR
        (path_type = 'PACKAGE' AND path_seq = -1 AND
         NOT EXISTS (SELECT * FROM jdr_paths
                     WHERE path_owner_docid = paths.path_docid));

    docID    JDR_PATHS.PATH_DOCID%TYPE;
    pathSeq  JDR_PATHS.PATH_SEQ%TYPE;
    pathType JDR_PATHS.PATH_TYPE%TYPE;
    docname  VARCHAR2(1024);
  BEGIN
    dbms_output.enable(1000000);

    docID := getDocumentID(p_path, 'ANY');

    -- Nothing to do if the path does not exist
    IF (docID = -1) THEN
      dbms_output.put_line('Error: Could not find path ' || p_path);
      RETURN;
    END IF;

    IF (p_recursive) THEN
      dbms_output.put_line('Printing contents of ' || p_path || ' recursively');
      OPEN c_alldocs(docID);
      LOOP
        FETCH c_alldocs INTO docname, pathType, pathSeq;
        IF (c_alldocs%NOTFOUND) THEN
          CLOSE c_alldocs;
          EXIT;
        END IF;

        -- Make package directories distinct from files.  Note that when
        -- listing the document recursively, the only packages that are
        -- listed are the ones which contain no child documents or packages
        IF ((pathType = 'PACKAGE') AND (pathSeq = -1)) THEN
          docname := docname || '/';
        END IF;

        -- Print the document, but make sure it does not exceed 255 characters
        -- or else dbms_output will fail
        WHILE (length(docname) > 255) LOOP
          dbms_output.put_line(substr(docname, 1, 255));
          docname := substr(docname, 256);
        END LOOP;
        dbms_output.put_line(docname);
      END LOOP;
    ELSE
      dbms_output.put_line('Printing contents of ' || p_path);
      OPEN c_docs(docID);
      LOOP
        FETCH c_docs INTO docname, pathType, pathSeq;
        IF (c_docs%NOTFOUND) THEN
          CLOSE c_docs;
          EXIT;
        END IF;

        -- Make package directories distinct from files.
        IF ((pathType = 'PACKAGE') AND (pathSeq = -1)) THEN
          docname := docname || '/';
        END IF;

        -- Print the document, but make sure it does not exceed 255 characters
        -- or else dbms_output will fail
        WHILE (length(docname) > 255) LOOP
          dbms_output.put_line(substr(docname, 1, 255));
          docname := substr(docname, 256);
        END LOOP;
        dbms_output.put_line(docname);
      END LOOP;
    END IF;
  END;


  -- List the customizations for the specified document.
  PROCEDURE listCustomizations(p_document VARCHAR2)
  IS
    CURSOR c(pathName VARCHAR2, docName VARCHAR2) IS
      SELECT jdr_mds_internal.getDocumentName(path_docid)
      FROM jdr_paths, jdr_attributes
      WHERE path_docid   = att_comp_docid AND
            path_name    = pathName       AND
            att_comp_seq = 0              AND
            att_name     = 'customizes'   AND
            att_value    = docName;
    pathName     JDR_PATHS.PATH_NAME%TYPE;
    oldCustName  VARCHAR2(1024);
    startDoc     VARCHAR2(1024);
    endDoc       VARCHAR2(1024);
    name         VARCHAR2(1024);
    lenApp       NUMBER;
    lenPkg       NUMBER;
    lenRoot      NUMBER;
  BEGIN
    -- First determine the pathName of the base document
    -- i.e. baseDocName - /oracle/apps/ak/pages/page1
    --      pathName    - page1
    lenPkg  := INSTR(p_document, '/', -1, 1);
    IF lenPkg = 0 OR
       lenPkg = LENGTH(p_document)
    THEN
      RETURN;
    END IF;
    pathName := SUBSTR(p_document, lenPkg + 1);
    OPEN c(pathName, p_document);
    LOOP
      FETCH c INTO name;
      IF (c%NOTFOUND) THEN
        CLOSE c;
        EXIT;
      END IF;
      dbms_output.put_line(name);
    END LOOP;
  END;


  -- Lists the contents of a package.
  PROCEDURE listDocuments(p_path VARCHAR2, p_recursive BOOLEAN DEFAULT FALSE)
  IS
  BEGIN
    listContents(p_path, p_recursive);
  END;


  -- Lists the supported languages for the specified document.
  --
  -- Parameters:
  --  p_document    - the fully qualified document name, which can represent
  --                  either a document or package file.
  --                  (i.e.  '/oracle/apps/ak/attributeSets')
  --
  PROCEDURE listLanguages(p_document VARCHAR2)
  IS
    CURSOR c_languages(docid jdr_paths.path_docid%TYPE) IS
      SELECT DISTINCT(atl_lang) FROM jdr_attributes_trans
      WHERE atl_comp_docid IN (SELECT path_docid FROM jdr_paths
                               START WITH path_docid = docID
                               CONNECT BY PRIOR path_docid=path_owner_docid);

    lang     jdr_attributes_trans.atl_lang%TYPE;
    docID    jdr_paths.path_docid%TYPE;
  BEGIN
    dbms_output.enable(1000000);

    docID := getDocumentID(p_document, 'FILE');

    -- Nothing to do if the path does not exist
    IF (docID = -1) THEN
      dbms_output.put_line('Error: Could not find document ' || p_document);
      RETURN;
    END IF;

    dbms_output.put_line('Printing languages for document ' || p_document);
    OPEN c_languages(docID);
    LOOP
      FETCH c_languages INTO lang;
      IF (c_languages%NOTFOUND) THEN
        CLOSE c_languages;
        EXIT;
      END IF;

      dbms_output.put_line(lang);
    END LOOP;
  END;


  -- Prints the contents of a JRAD document to the console.
  PROCEDURE printDocument(p_document    VARCHAR2,
                          p_maxLineSize NUMBER DEFAULT MAX_LINE_SIZE)
  IS
    chunk       VARCHAR2(32000);
    maxLineSize NUMBER := p_maxLineSize;
  BEGIN
    dbms_output.enable(1000000);

    IF (p_maxLineSize > MAX_LINE_SIZE) THEN
      maxLineSize := MAX_LINE_SIZE;
    END IF;

    chunk := jdr_mds_internal.exportDocumentAsXML(p_document);

    IF chunk IS NULL THEN
      dbms_output.put_line('Error: Could not find document ' || p_document);
    ELSE
      printChunk(chunk, maxLineSize);
      LOOP
        chunk := jdr_mds_internal.exportDocumentAsXML(NULL);
        EXIT WHEN chunk IS NULL;
        printChunk(chunk, maxLineSize);
      END LOOP;
    END IF;
  END;


  -- Prints the translations for the document in XLIFF format.
  PROCEDURE printTranslations(p_document    VARCHAR2,
                              p_language    VARCHAR2,
                              p_maxLineSize NUMBER DEFAULT MAX_LINE_SIZE)
  IS
    chunk          VARCHAR2(32000);
    maxLineSize    NUMBER := p_maxLineSize;
    exportFinished INTEGER;
  BEGIN
    dbms_output.enable(1000000);

    IF (p_maxLineSize > MAX_LINE_SIZE) THEN
      maxLineSize := MAX_LINE_SIZE;
    END IF;

    chunk := jdr_mds_internal.exportXLIFFDocument(exportFinished,
                                                  p_document,
                                                  p_language);

    IF chunk IS NULL THEN
      dbms_output.put_line('Error: Could not find document ' || p_document);
    ELSE
      printChunk(chunk, maxLineSize);
      WHILE (exportFinished = 0) LOOP
        chunk := jdr_mds_internal.exportXLIFFDocument(exportFinished,
                                                      NULL,
                                                      NULL);
        IF (chunk IS NOT NULL) THEN
          printChunk(chunk, maxLineSize);
        END IF;
      END LOOP;
    END IF;
  END;

  PROCEDURE saveTranslations(
    p_document     VARCHAR2,
    p_translations translationList,
    p_commit       BOOLEAN := TRUE)
  IS
    docID      jdr_paths.path_docid%TYPE;
    lang       jdr_attributes_trans.atl_lang%TYPE;
    pos        BINARY_INTEGER;
    dashpos    BINARY_INTEGER;
  BEGIN
    -- Get the document ID for this document
    docID := getDocumentID(p_document, 'FILE');
    IF (docID = -1) THEN
      RAISE no_such_document;
    END IF;

    -- Create a savepoint in case of an exception
    SAVEPOINT saveTranslations_1;

    -- Lock the document
    jdr_mds_internal.lockDocument(docID, 100);

    -- Delete all of the translations
    DELETE FROM jdr_attributes_trans WHERE atl_comp_docid = docID;

    -- Insert the new translations
    FOR pos IN 1..p_translations.COUNT LOOP

      -- Insure that the language is in the form 'xx-YY'.  That is, the first
      -- part must be in lower case and the latter part in uppercase.
      IF (UPPER(NVL(lang, 'INVALID')) <> UPPER(p_translations(pos).lang)) THEN
        dashpos := INSTR(p_translations(pos).lang, '-');
        lang := LOWER(SUBSTR(p_translations(pos).lang, 1, dashpos)) ||
                UPPER(SUBSTR(p_translations(pos).lang, dashpos + 1));
      END IF;

      INSERT
        INTO jdr_attributes_trans
          (atl_comp_docid,
           atl_lang,
           atl_comp_ref,
           atl_name,
           atl_value)
        VALUES
          (docID,
           lang,
           NVL(p_translations(pos).compref, '.'),
           p_translations(pos).name,
           p_translations(pos).value);
    END LOOP;

    -- Commit the data (if requested to)
    IF (p_commit) THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO saveTranslations_1;
      RAISE;
  END;

END;

/
