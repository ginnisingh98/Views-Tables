--------------------------------------------------------
--  DDL for Package Body JDR_DOCBUILDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JDR_DOCBUILDER" AS
/* $Header: JDRDBEXB.pls 120.3 2005/10/26 06:15:23 akbansal noship $ */

  -----------------------------------------------------------------------------
  ---------------------------- PRIVATE TYPES ----------------------------------
  -----------------------------------------------------------------------------
  -- Use subtypes for less confusion between external and internal types.
  SUBTYPE ELEM_ID IS ELEMENT;
  SUBTYPE DOC_ID  IS DOCUMENT;

  -- Internal representation of a jrad attribute
  TYPE ATTRIBUTE IS RECORD ( elemId NUMBER,
                             name   jdr_attributes.att_name%TYPE,
                             value  jdr_attributes.att_value%TYPE );

  -- Internal representation of a jrad grouping
  TYPE GROUPING IS RECORD ( parentId  NUMBER,
                            ns        VARCHAR2(5),
                            tagName   jdr_components.comp_grouping%TYPE,
                            childId   NUMBER );

  -- Internal representation of a jrad component
  TYPE ELEM IS RECORD ( id        NUMBER,
                        ns        VARCHAR2(5),
                        tagName   jdr_components.comp_element%TYPE );

  -- Internal representation of a jrad document
  TYPE DOC IS RECORD ( id         NUMBER,
                       fullPath   jdr_components.comp_ref%TYPE,
                       lang       VARCHAR2(5),
                       topElemId  NUMBER,
                       parentId   NUMBER);

  -- Table of documents
  TYPE DOC_TABLE IS TABLE OF DOC;

  -- Table of elements
  TYPE ELEM_TABLE IS TABLE OF ELEM;

  -- Table of groupings
  TYPE GROUPING_TABLE IS TABLE OF GROUPING;

  -- Table of attributes
  TYPE ATTRIBUTE_TABLE IS TABLE OF ATTRIBUTE;

  -- Tables containing a database component's properties in bulk-insert
  -- compatible format
  TYPE DB_COMPONENT_L1  IS TABLE OF NUMBER;
  TYPE DB_COMPONENT_L2  IS TABLE OF jdr_components.comp_seq%TYPE;
  TYPE DB_COMPONENT_L3  IS TABLE OF jdr_components.comp_level%TYPE;
  TYPE DB_COMPONENT_L4  IS TABLE OF jdr_components.comp_grouping%TYPE;
  TYPE DB_COMPONENT_L5  IS TABLE OF jdr_components.comp_element%TYPE;
  TYPE DB_COMPONENT_L6  IS TABLE OF jdr_components.comp_id%TYPE;
  TYPE DB_COMPONENT_L7  IS TABLE OF jdr_components.comp_ref%TYPE;
  TYPE DB_COMPONENT_L8  IS TABLE OF jdr_components.comp_extends%TYPE;
  TYPE DB_COMPONENT_L9  IS TABLE OF jdr_components.comp_use%TYPE;
  TYPE DB_COMPONENT_L10 IS TABLE OF jdr_components.comp_comment%TYPE;

  -- Tables containing a database attribute's properties in bulk-insert
  -- compatible format
  TYPE DB_ATTRIBUTE_L1 IS TABLE OF jdr_attributes.att_comp_seq%TYPE;
  TYPE DB_ATTRIBUTE_L2 IS TABLE OF jdr_attributes.att_seq%TYPE;
  TYPE DB_ATTRIBUTE_L3 IS TABLE OF jdr_attributes.att_name%TYPE;
  TYPE DB_ATTRIBUTE_L4 IS TABLE OF jdr_attributes.att_value%TYPE;

  -----------------------------------------------------------------------------
  ---------------------------- PRIVATE VARIABLES ------------------------------
  -----------------------------------------------------------------------------

  mDocs       DOC_TABLE        := DOC_TABLE();
  mElems      ELEM_TABLE       := ELEM_TABLE();
  mGroupings  GROUPING_TABLE   := GROUPING_TABLE();
  mAttributes ATTRIBUTE_TABLE  := ATTRIBUTE_TABLE();

  compList1  DB_COMPONENT_L1  := DB_COMPONENT_L1();
  compList2  DB_COMPONENT_L2  := DB_COMPONENT_L2();
  compList3  DB_COMPONENT_L3  := DB_COMPONENT_L3();
  compList4  DB_COMPONENT_L4  := DB_COMPONENT_L4();
  compList5  DB_COMPONENT_L5  := DB_COMPONENT_L5();
  compList6  DB_COMPONENT_L6  := DB_COMPONENT_L6();
  compList7  DB_COMPONENT_L7  := DB_COMPONENT_L7();
  compList8  DB_COMPONENT_L8  := DB_COMPONENT_L8();
  compList9  DB_COMPONENT_L9  := DB_COMPONENT_L9();
  compList10 DB_COMPONENT_L10 := DB_COMPONENT_L10();

  attList1   DB_ATTRIBUTE_L1  := DB_ATTRIBUTE_L1();
  attList2   DB_ATTRIBUTE_L2  := DB_ATTRIBUTE_L2();
  attList3   DB_ATTRIBUTE_L3  := DB_ATTRIBUTE_L3();
  attList4   DB_ATTRIBUTE_L4  := DB_ATTRIBUTE_L4();

  JRAD_NS_URI CONSTANT VARCHAR2(30) := 'http://xmlns.oracle.com/jrad';
  OA_NS_URI   CONSTANT VARCHAR2(30) := 'http://xmlns.oracle.com/oa';
  UI_NS_URI   CONSTANT VARCHAR2(30) := 'http://xmlns.oracle.com/uix/ui';
  USER_NS_URI CONSTANT VARCHAR2(30) := 'http://xmlns.oracle.com/user';

  NULL_GROUPING_NAME CONSTANT VARCHAR2(30) := 'nullgrouping';
  NULL_GROUPING_NS   CONSTANT VARCHAR2(30) := 'null';

  -----------------------------------------------------------------------------
  ---------------------------- PRIVATE FUNCTIONS ------------------------------
  -----------------------------------------------------------------------------

  -- Add required attributes to the top-level element in the document.
  -- This includes namespace, version, and language declarations.
  --
  -- Parameters:
  --   p_doc      -  The document pertaining to the top-level element
  --   p_comp_num -  The index of the top level element in the compList tables
  --   p_seq      -  The next sequence number with which to add these attributes
  --   x_attList  - The list of attributes to which these extra attributes will
  --               be appended.
  --
  PROCEDURE addTopLevelAttributes(p_doc      IN     DOC,
                                  p_comp_num IN     NUMBER,
                                  p_seq      IN     PLS_INTEGER)
  IS
    seq		PLS_INTEGER := p_seq;
    l_comp_seq	jdr_components.comp_seq%TYPE := compList2(p_comp_num); --comp_seq
  BEGIN
    -- set xmlns
    attList1.EXTEND;
    attList2.EXTEND;
    attList3.EXTEND;
    attList4.EXTEND;
    attList1(attList1.LAST) := l_comp_seq;
    attList2(attList2.LAST) := seq;
    attList3(attList3.LAST) := 'xmlns';
    attList4(attList4.LAST) := JRAD_NS_URI;
    -- set xmlns:jrad
    attList1.EXTEND;
    attList2.EXTEND;
    attList3.EXTEND;
    attList4.EXTEND;
    attList1(attList1.LAST) := l_comp_seq;
    attList2(attList2.LAST) := seq + 1;
    attList3(attList3.LAST) := 'xmlns:jrad';
    attList4(attList4.LAST) := JRAD_NS_URI;
    -- set xmlns:ui
    attList1.EXTEND;
    attList2.EXTEND;
    attList3.EXTEND;
    attList4.EXTEND;
    attList1(attList1.LAST) := l_comp_seq;
    attList2(attList2.LAST) := seq + 2;
    attList3(attList3.LAST) := 'xmlns:ui';
    attList4(attList4.LAST) := UI_NS_URI;
    -- set xmlns:oa
    attList1.EXTEND;
    attList2.EXTEND;
    attList3.EXTEND;
    attList4.EXTEND;
    attList1(attList1.LAST) := l_comp_seq;
    attList2(attList2.LAST) := seq + 3;
    attList3(attList3.LAST) := 'xmlns:oa';
    attList4(attList4.LAST) := OA_NS_URI;
    -- set xmlns:user
    attList1.EXTEND;
    attList2.EXTEND;
    attList3.EXTEND;
    attList4.EXTEND;
    attList1(attList1.LAST) := l_comp_seq;
    attList2(attList2.LAST) := seq + 4;
    attList3(attList3.LAST) := 'xmlns:user';
    attList4(attList4.LAST) := USER_NS_URI;
    -- set version
    attList1.EXTEND;
    attList2.EXTEND;
    attList3.EXTEND;
    attList4.EXTEND;
    attList1(attList1.LAST) := l_comp_seq;
    attList2(attList2.LAST) := seq + 5;
    attList3(attList3.LAST) := 'version';
    attList4(attList4.LAST) := '9.0.3.8.0_588';
    -- set language
    attList1.EXTEND;
    attList2.EXTEND;
    attList3.EXTEND;
    attList4.EXTEND;
    attList1(attList1.LAST) := l_comp_seq;
    attList2(attList2.LAST) := seq + 6;
    attList3(attList3.LAST) := 'xml:lang';
    attList4(attList4.LAST) := p_doc.lang;
  END;

  -- Build the entire list of attributes for a given document. This list closely
  -- represents the jdr_attributes table structure in the repository. Some
  -- special attributes, such as id and extends, will be stored directly on the
  -- DBComponent itself, rather than as a DBAttribute.
  --
  -- Note: This function assumes that the ATTRIBUTE_TABLE mAttributes
  --       has been sorted by elemId.
  --
  -- Parameters:
  --   p_doc      -  The document corresponding to this list of attributes
  --
  -- Returns:
  --   The list of DBAttributes
  --
  PROCEDURE buildAttributeList(p_doc      IN     DOC)
  IS
    start_j     PLS_INTEGER := 1;
    i           PLS_INTEGER;
    j           PLS_INTEGER;
    currAtt     ATTRIBUTE;
    comp_elemId NUMBER;
    att_elemId  NUMBER;
    attName     jdr_attributes.att_name%TYPE;
    seq         PLS_INTEGER;
    foundElem   BOOLEAN := FALSE;
  BEGIN
    IF compList1.COUNT > 0 AND mAttributes.COUNT > 0
    THEN
      FOR i IN compList1.FIRST..compList1.LAST LOOP
        comp_elemId := compList1(i);
        -- initialize sequence to 0
        seq := 0;
        foundElem := FALSE;
        IF mAttributes.COUNT > 0
        THEN
          FOR j IN mAttributes.FIRST..mAttributes.LAST LOOP
            IF mAttributes.EXISTS(j)
            THEN
              currAtt := mAttributes(j);
              IF comp_elemId = currAtt.elemId
              THEN
                foundElem := TRUE;
                -- check if this is a special attribute that
                -- belongs in one of the component lists instead
                attName := currAtt.name;
                IF attName = 'extends'
                THEN
	     	          compList7(i) := currAtt.value;  --comp_ref
		              compList8(i) := 'Y';            --comp_extends
                ELSIF attName = 'use'
                THEN
		              compList9(i) := currAtt.value;  --comp_use
                ELSIF attName = 'id'
                THEN
		              compList6(i) := currAtt.value;  --comp_id
                ELSIF attName = 'comment'
                THEN
		              compList10(i) := currAtt.value; --comp_comment
                ELSE
             	    -- Otherwise, add this attribute to the attribute tables
  		            attList1.EXTEND;
          		    attList2.EXTEND;
		              attList3.EXTEND;
		              attList4.EXTEND;
		              attList1(attList1.LAST) := compList2(i); --comp_seq
		              attList2(attList2.LAST) := seq;
		              attList3(attList3.LAST) := currAtt.name;
		              attList4(attList4.LAST) := currAtt.value;
		              seq := seq + 1;
                END IF;
	              mAttributes.DELETE(j);
              ELSIF foundElem = TRUE
              THEN
                EXIT;
              END IF;
            END IF;
          END LOOP;
        END IF;
        -- find out if this is the top-level element, check comp_seq and comp_level
        IF ( compList2(i) = 0 ) AND
           ( compList3(i) = 0 )
        THEN
          -- Check if this is a top-level document, or a child document
          IF p_doc.parentId = -1
          THEN
            addTopLevelAttributes(p_doc, i, seq);
          END IF;
        END IF;
      END LOOP;
    END IF;
  END;


  -- Build the entire list of components, starting with a given element and
  -- recursing through all its children. This list closely represents the
  -- jdr_components table structure in the repository.
  --
  -- Note: This is a recursive procedure, which assumes that the ELEMENT_TABLE
  --       mElems has been sorted by elemId and grouping.
  --
  -- Parameters:
  --   p_elem      - The top-level element node
  --   p_grouping  - The grouping which p_elem belongs to. If p_elem is the
  --                 top-level component in the document, this will be NULL.
  --   p_initLevel - The level of p_elem in the document
  --   p_loopStart - The initial index from which to begin iterating through
  --                 the groupings table
  --   p_initSeq   - The sequence number of p_elem in the document
  --
  PROCEDURE buildComponentList(p_elem       IN     ELEM,
                               p_grouping   IN     GROUPING,
                               p_initLevel  IN     PLS_INTEGER,
			                         p_loopStart  IN	   PLS_INTEGER,
                               x_initSeq    IN OUT NOCOPY /* file.sql.39 change */ PLS_INTEGER)
  IS
    i              PLS_INTEGER;
    childElem      ELEM;
    currGrouping   GROUPING;
    lastGrouping   GROUPING;
    currParentId   NUMBER;
    seq            PLS_INTEGER := x_initSeq;
    lev            PLS_INTEGER := p_initLevel;
    foundParent    BOOLEAN := FALSE;
    foundChild     BOOLEAN := FALSE;
    l_loopStart    PLS_INTEGER;
    childLoopStart PLS_INTEGER;
    currLevel      PLS_INTEGER;
  BEGIN
    -- Extend all of the component lists for the new component
    compList1.EXTEND;
    compList2.EXTEND;
    compList3.EXTEND;
    compList4.EXTEND;
    compList5.EXTEND;
    compList6.EXTEND;
    compList7.EXTEND;
    compList8.EXTEND;
    compList9.EXTEND;
    compList10.EXTEND;

    -- Fill in component properties that we know
    compList1(compList1.LAST) := p_elem.id;
    compList2(compList2.LAST) := seq;
    compList3(compList3.LAST) := lev;
    -- Add the grouping if appropriate
    IF NOT p_grouping.ns IS NULL
       AND NOT p_grouping.ns = NULL_GROUPING_NS
    THEN
     -- #(3654464) No need to specify the JRAD namespace since it's the
      -- default namespace
      IF (p_grouping.ns = JRAD_NS) THEN
        compList4(compList4.LAST) := p_grouping.tagName;
      ELSE
        compList4(compList4.LAST) := p_grouping.ns || p_grouping.tagName;
      END IF;
    END IF;

    -- #(3654464) No need to specify the JRAD namespace since it's the
    -- default namespace
    IF (p_elem.ns = JRAD_NS) THEN
      compList5(compList5.LAST) := p_elem.tagName;
    ELSE
      compList5(compList5.LAST) := p_elem.ns || p_elem.tagName;
    END IF;

    -- Increment seq value
    seq := seq + 1;

    -- Find all groupings where parentId = p_elem
    IF mGroupings.COUNT > 0
    THEN
      IF mGroupings.EXISTS(p_loopStart) THEN
        l_loopStart := p_loopStart;
      ELSE
        l_loopStart := mGroupings.FIRST;
      END IF;
      FOR i IN l_loopStart..mGroupings.LAST LOOP
        IF mGroupings.EXISTS(i)
        THEN
          currGrouping := mGroupings(i);
          currParentId := currGrouping.parentId;
          IF currParentId = p_elem.id
          THEN
            foundParent := TRUE;
            childElem := mElems(currGrouping.childId);
            -- determine if this is a new grouping. If so, set foundChild to
            -- false, so we know to save the grouping on the dbcomponent
            IF (lastGrouping.ns IS NULL) OR
               (lastGrouping.ns <> currGrouping.ns) OR
               (lastGrouping.tagName <> currGrouping.tagName)
            THEN
              foundChild := FALSE;
            END IF;
	          --see if we can cheat on the recursive iteration
	          IF currParentId < childElem.id THEN
	            childLoopStart := i + 1;
	          ELSE
	            childLoopStart := 0;
	          END IF;
            lastGrouping := currGrouping;
            IF currGrouping.ns = NULL_GROUPING_NS
            THEN
              currLevel := lev + 1;
            ELSE
              currLevel := lev + 2;
            END IF;
            IF NOT foundChild
            THEN
              foundChild := TRUE;
            ELSE
              currGrouping := NULL;
            END IF;
            buildComponentList(childElem, currGrouping, currLevel, childLoopStart, seq);
	          mGroupings.DELETE(i);
          ELSIF foundParent = TRUE
          THEN
            EXIT; -- we've passed all groupings for the parent id
          END IF;
        END IF;
      END LOOP;
    END IF;
    x_initSeq := seq;
  END;


  -- Compares 2 different attributes, a and b. Returns true if a > b. Otherwise,
  -- returns false.
  --
  -- These attributes are compared based on the elemId. A larger elemId value
  -- gives an attribute more weight than the other.
  --
  -- Parameters:
  --   a  -  The first attribute being compared
  --   b  -  The second attribute being compared
  --
  -- Returns:
  --   True, if a > b. False otherwise.
  --
  FUNCTION compareAttributes(a ATTRIBUTE,
                             b ATTRIBUTE) RETURN BOOLEAN
  IS
  BEGIN
    IF a.elemId > b.elemId
    THEN
      RETURN (TRUE);
    END IF;
    RETURN (FALSE);
  END;


  -- Compares 2 different groupings, a and b. Returns true if a > b. Otherwise,
  -- returns false.
  --
  -- These groupings are compared based on the parentId, namespace, and tagName.
  -- A larger parentId value gives a grouping more weight than the other. If the
  -- parentId is the same, the namespace is compared based on its internal
  -- numeric value. If this is also equivalent, then the tagName is compared,
  -- also based on its internal numeric value.
  --
  -- Parameters:
  --   a  -  The first grouping being compared
  --   b  -  The second grouping being compared
  --
  -- Returns:
  --   True, if a > b. False otherwise.
  --
  FUNCTION compareGroupings(a GROUPING,
                            b GROUPING) RETURN BOOLEAN
  IS
  BEGIN
    IF a.parentId > b.parentId
    THEN
      RETURN (TRUE);
    ELSIF a.parentId < b.parentId
    THEN
      RETURN (FALSE);
    END IF;
    -- parentId's are equal
    IF a.ns > b.ns
    THEN
      RETURN (TRUE);
    ELSIF a.ns < b.ns
    THEN
      RETURN (FALSE);
    END IF;
    -- namespaces are equal
    IF a.tagName > b.tagName
    THEN
      RETURN (TRUE);
    ELSIF a.tagName < b.tagName
    THEN
      RETURN (FALSE);
    END IF;
    -- The groupings belong to the same parent, with the same
    -- namespace and tagName
    RETURN (FALSE);
  END;

  -- Create a document object
  FUNCTION createDocument(
    p_fullPathName VARCHAR2,
    p_language     VARCHAR2,
    p_parentId     NUMBER) RETURN DOCUMENT
  IS
  newDoc   DOC;
  d_id     DOC_ID;
  BEGIN
    mDocs.EXTEND;
    newDoc.id        := mDocs.LAST;
    newDoc.fullPath  := p_fullPathName;
    newDoc.lang      := p_language;
    newDoc.parentId  := p_parentId;
    mDocs(newDoc.id) := newDoc;
    d_id.id          := newDoc.id;
    RETURN (d_id);
  END;


  -- Bulk Insert the data in the attList tables into the repository
  --
  -- Parameters:
  --   p_docid   -  The document to which these attributes belong to
  --
  PROCEDURE insertAttributes(p_docid NUMBER)
  IS
    i PLS_INTEGER;
  BEGIN
     FORALL i in attList1.FIRST..attList1.LAST
	INSERT INTO jdr_attributes
	   (ATT_COMP_DOCID, ATT_COMP_SEQ, ATT_SEQ, ATT_NAME, ATT_VALUE)
	VALUES
	   (p_docid, attList1(i), attList2(i), attList3(i),attList4(i));
  END;


  -- Bulk Insert the data in the compList tables into the repository
  --
  -- Parameters:
  --   p_docid   -  The document to which these components belong to
  --
  PROCEDURE insertComponents(p_docid NUMBER)
  IS
    i PLS_INTEGER;
 BEGIN
    FORALL i in compList1.FIRST..compList1.LAST
       INSERT INTO jdr_components
	  (COMP_DOCID, COMP_SEQ , COMP_LEVEL, COMP_GROUPING, COMP_ELEMENT,
	   COMP_ID, COMP_REF, COMP_EXTENDS, COMP_USE, COMP_COMMENT)
       VALUES
	  (p_docid, compList2(i), compList3(i), compList4(i), compList5(i),
	   compList6(i), compList7(i), compList8(i), compList9(i), compList10(i));
  END;


  -- Sort the attributes in the attributes table from lowest to highest elemId.
  -- This procedure uses the compareAttributes() method to analyze the
  -- attributes. This is an implementation of insertion-sort.
  --
  PROCEDURE sortAttributesTable
  IS
    i NUMBER;
    j NUMBER;
    currAttribute ATTRIBUTE;
    attTable      ATTRIBUTE_TABLE := mAttributes;
  BEGIN
    IF attTable.COUNT > 1
    THEN
      FOR i IN 2..attTable.COUNT LOOP
        j := i;
        currAttribute := attTable(i);
        WHILE (j > 1) AND
             (compareAttributes(attTable(j-1), currAttribute)) LOOP
          attTable(j) := attTable(j-1);
          j := j - 1;
        END LOOP;
        attTable(j) := currAttribute;
      END LOOP;
    END IF;
    mAttributes := attTable;
  END;


  -- Sort the groupings in the groupings table in the following order:
  -- 1) From lowest to highest parentId.
  -- 2) By grouping namespace, in alphabetical order
  -- 3) By grouping tagName, in alphabetical order
  --
  -- This procedure uses the compareGroupings() method to analyze the
  -- groupings. This is an implementation of insertion-sort.
  --
  PROCEDURE sortGroupingsTable
  IS
    i NUMBER;
    j NUMBER;
    currGrouping GROUPING;
    groupTable   GROUPING_TABLE := mGroupings;
  BEGIN
    IF groupTable.COUNT > 1
    THEN
      FOR i IN 2..groupTable.COUNT LOOP
        j := i;
        currGrouping := groupTable(i);
        WHILE (j > 1) AND
             (compareGroupings(groupTable(j-1), currGrouping)) LOOP
          groupTable(j) := groupTable(j-1);
          j := j - 1;
        END LOOP;
        groupTable(j) := currGrouping;
      END LOOP;
    END IF;
    mGroupings := groupTable;
  END;

  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC FUNCTIONS -------------------------------
  -----------------------------------------------------------------------------


  PROCEDURE addChild(
      p_parent            ELEMENT,
      p_groupingNS        VARCHAR2,
      p_groupingTagName   VARCHAR2,
      p_child             ELEMENT)
  IS
    currGrouping GROUPING;
  BEGIN
    IF p_groupingNS = JRAD_NS OR
       p_groupingNS = OA_NS   OR
       p_groupingNS = UI_NS   OR
       p_groupingNS = USER_NS OR
       p_groupingNS = NULL_GROUPING_NS
    THEN
      currGrouping.parentId := p_parent.id;
      currGrouping.childId  := p_child.id;
      currGrouping.tagName  := p_groupingTagName;
      currGrouping.ns       := p_groupingNS;
      mGroupings.EXTEND;
      mGroupings(mGroupings.LAST) := currGrouping;
    ELSE
      RAISE INVALID_NAMESPACE;
    END IF;
  END;


  PROCEDURE addChild(
      p_parent            ELEMENT,
      p_child             ELEMENT)
  IS
  BEGIN
    addChild(p_parent, NULL_GROUPING_NS, NULL_GROUPING_NAME, p_child);
  END;


  FUNCTION createChildDocument(
    p_fullPathName VARCHAR2) RETURN DOCUMENT
  IS
  pkgDocId  NUMBER;
  pkgName   jdr_components.comp_ref%TYPE;
  BEGIN
    -- Determine whether the package file exists in the repository
    pkgName := substr(p_fullPathName,
                      1,
                      instr(p_fullPathName, '/', -1, 1) - 1);
    BEGIN
      SELECT path_docid INTO pkgDocId
        FROM jdr_paths
        WHERE jdr_mds_internal.getDocumentName(path_docid) = pkgName AND
              path_type = 'PACKAGE' AND
              path_seq  = 0;
    EXCEPTION
      -- No package file exists in the repository.
      WHEN NO_DATA_FOUND THEN
        RAISE REF_NOT_FOUND;
    END;
    RETURN createDocument(p_fullPathName, NULL, pkgDocId);
  END;


  FUNCTION createDocument(
    p_fullPathName VARCHAR2,
    p_language     VARCHAR2) RETURN DOCUMENT
  IS
  BEGIN
    RETURN createDocument(p_fullPathName, p_language, -1);
  END;


  FUNCTION createElement(
    p_namespace VARCHAR2,
    p_tagName   VARCHAR2) RETURN ELEMENT
  IS
  newElem ELEM;
  e_id ELEM_ID;
  BEGIN
    IF p_namespace = JRAD_NS OR
       p_namespace = OA_NS   OR
       p_namespace = UI_NS   OR
       p_namespace = USER_NS
    THEN
      mElems.EXTEND;
      newElem.id      := mElems.LAST;
      newElem.tagName := p_tagName;
      newElem.ns      := p_namespace;
      mElems(newElem.id) := newElem;
      e_id.id := newElem.id;
    ELSE
     RAISE INVALID_NAMESPACE;
    END IF;
    RETURN(e_id);
  END;


  PROCEDURE deleteDocument(
      p_fullPathName VARCHAR2)
  IS
    docid    NUMBER;
    pathType jdr_paths.path_type%TYPE;
  BEGIN
    docid := jdr_mds_internal.getDocumentID(p_fullPathName);
    IF docid = -1
    THEN
      RAISE REF_NOT_FOUND;
    ELSE
      SELECT path_type INTO pathType
        FROM jdr_paths
        WHERE path_docid = docid;
      IF pathType = 'DOCUMENT'
      THEN
        jdr_mds_internal.dropDocument(docid);
      ELSE
        RAISE NOT_DOCUMENT_REF;
      END IF;
    END IF;
  END;


  FUNCTION documentExists(
      p_fullPathName VARCHAR2) RETURN BOOLEAN
  IS
     docid    NUMBER;
  BEGIN
    docid := jdr_mds_internal.getDocumentID(p_fullPathName, 'DOCUMENT');
    IF docid = -1
    THEN
      RETURN(FALSE);
    ELSE
      RETURN(TRUE);
    END IF;
  END;


  PROCEDURE refresh
  IS
  BEGIN
    -- re-initialize all member variables
    mDocs       := DOC_TABLE();
    mElems      := ELEM_TABLE();
    mGroupings  := GROUPING_TABLE();
    mAttributes := ATTRIBUTE_TABLE();
  END;


  FUNCTION save RETURN PLS_INTEGER
  IS
    docid       PLS_INTEGER;
    db_docid    NUMBER;
    currDoc     DOC;
    topElem     ELEM;
    seq         PLS_INTEGER := 0;
    docSeq      jdr_paths.path_seq%TYPE;
    docName     jdr_paths.path_name%TYPE;
    isDuplicate BOOLEAN;
  BEGIN
    -- Sort the tables such that components, attributes can be found more easily
    sortAttributesTable();
    sortGroupingsTable();

    FOR docid IN mDocs.FIRST..mDocs.LAST LOOP
      IF mDocs.EXISTS(docid) THEN
   	    currDoc := mDocs(docid);
	      -- Retrieve the top-level element
	      topElem   := mElems(currDoc.topElemId);
        -- Clear the component list tables
	      compList1.DELETE;
	      compList2.DELETE;
	      compList3.DELETE;
	      compList4.DELETE;
	      compList5.DELETE;
	      compList6.DELETE;
	      compList7.DELETE;
	      compList8.DELETE;
	      compList9.DELETE;
	      compList10.DELETE;
        -- Build the component list for this document
	      buildComponentList(topElem, NULL, 0, 1, seq);
     	  -- Clear the attribute list tables
        attList1.DELETE;
	      attList2.DELETE;
	      attList3.DELETE;
	      attList4.DELETE;
	      -- Build the attribute list for this document
	      buildAttributeList(currDoc);
        -- Prepare to insert document.
        IF currDoc.parentId = -1
        THEN
      	  db_docid := jdr_mds_internal.prepareDocumentForInsert('INTERNAL',
	  			 		                                                currDoc.fullPath,
		  					                                              'DOCUMENT',
			  				                                              '1.0',
				  			                                              'UTF-8');
        ELSE
          -- This is a child document. Lock the package file document
          jdr_mds_internal.lockDocument(currDoc.parentId);
          -- Determine whether the document already exists in the repository
          docName := substr(currDoc.fullPath,
                            instr(currDoc.fullPath, '/', -1, 1) + 1);
          BEGIN
            SELECT path_seq INTO docSeq
              FROM jdr_paths
              WHERE path_name = docName AND
                    path_owner_docid = currDoc.parentId;
            isDuplicate := TRUE;
          EXCEPTION
            -- The document is unique
            WHEN NO_DATA_FOUND THEN
              SELECT max(path_seq) INTO docSeq
                FROM jdr_paths
                WHERE path_owner_docid = currDoc.parentId;
              docSeq := docSeq + 1;
              isDuplicate := FALSE;
          END;
          db_docid := jdr_mds_internal.prepareDocumentForInsert('INTERNAL',
                                                               docName,
                                                               currDoc.parentId,
                                                               docSeq,
                                                               'DOCUMENT');
          IF isDuplicate
          THEN
            -- Delete from jdr_attribute and jdr_components table
            DELETE jdr_attributes WHERE att_comp_docid = db_docid;
            DELETE jdr_components WHERE comp_docid = db_docid;
          END IF;
        END IF;
	      -- Bulk Insert the components/attributes
	      insertComponents(db_docid);
	      insertAttributes(db_docid);
      END IF;
      seq := 0;
    END LOOP;
    refresh();
    RETURN(SUCCESS);
  END;


  PROCEDURE setAttribute(
    p_elem       ELEMENT,
    p_attName    VARCHAR2,
    p_attValue   VARCHAR2)
  IS
    newAtt ATTRIBUTE;
  BEGIN
    newAtt.name   := p_attName;
    newAtt.value  := p_attValue;
    newAtt.elemId := p_elem.id;
    mAttributes.EXTEND;
    mAttributes(mAttributes.LAST) := newAtt;
  END;


  PROCEDURE setTopLevelElement(
    p_doc      DOCUMENT,
    p_elem     ELEMENT)
  IS
    docid   PLS_INTEGER;
    currDoc DOC;
  BEGIN
    docid   := p_doc.id;
    currDoc := mDocs(docid);
    currDoc.topElemId := p_elem.id;
    mDocs(docid) := currDoc;
  END;

END;

/
