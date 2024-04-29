--------------------------------------------------------
--  DDL for Package Body JDR_CUSTOM_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JDR_CUSTOM_INTERNAL" AS
/* $Header: JDRCTINB.pls 120.3 2005/10/26 06:14:58 akbansal noship $ */
  -----------------------------------------------------------------------------
  ---------------------------- PRIVATE VARIABLES ------------------------------
  -----------------------------------------------------------------------------

  APPS_ROOTDIR   CONSTANT VARCHAR2(30) := '/oracle/apps/';
  PORTLET        CONSTANT VARCHAR2(10) := 'PORTLET';

  -- Constants for layer precedence order
  FUNCTION_LEVEL         CONSTANT NUMBER := 1;
  VERTICALIZATION_LEVEL  CONSTANT NUMBER := 2;
  LOCALIZATION_LEVEL     CONSTANT NUMBER := 3;
  SITE_LEVEL             CONSTANT NUMBER := 4;
  ORG_LEVEL              CONSTANT NUMBER := 5;
  RESPONSIBILITY_LEVEL   CONSTANT NUMBER := 6;
  SEEDED_DEV_USER_LEVEL  CONSTANT NUMBER := 7;
  SEEDED_CUST_USER_LEVEL CONSTANT NUMBER := 8;
  END_USER_LEVEL         CONSTANT NUMBER := 9;
  PORTLET_LEVEL          CONSTANT NUMBER := 10;

  -----------------------------------------------------------------------------
  ----------------------------- PRIVATE FUNCTIONS -----------------------------
  -----------------------------------------------------------------------------

  -- Add the attributes of the region customization document to the page
  -- customization document.
  --
  -- Parameters:
  --   pageCustDocID    Document ID of the page customization document
  --   pageCompSeq      Component sequence of the page component (destination)
  --   regionCustDocID  Document ID of the region customization document
  --   regionCompSeq    Component sequence of the region component (source)
  --   extendingRegion  Component ID of the extending region
  --   needElementAtt   Is an element attribute needed?
  PROCEDURE addAttributes(pageCustDocID    jdr_paths.path_docid%TYPE,
                          pageCompSeq      jdr_attributes.att_comp_seq%TYPE,
                          regionCustDocID  jdr_paths.path_docid%TYPE,
                          regionCompSeq    jdr_attributes.att_comp_seq%TYPE,
                          extendingRegion  jdr_components.comp_id%TYPE,
                          needElementAtt   BOOLEAN)
  IS
    CURSOR c_attributes(docID   jdr_paths.path_docid%TYPE,
                        compSeq jdr_components.comp_seq%TYPE) IS
      SELECT att_seq, att_name, att_value
      FROM jdr_attributes
      WHERE att_comp_docid = docID AND
            att_comp_seq = compSeq;

    attRec           c_attributes%ROWTYPE;
    nextAttSequence  jdr_attributes.att_seq%TYPE;
    addElementAtt    BOOLEAN := needElementAtt;
  BEGIN
    nextAttSequence := 0;

    -- Retrieve the attributes from the region document and insert them
    -- into the page document
    OPEN c_attributes(regionCustDocID, regionCompSeq);
    LOOP
      FETCH c_attributes INTO attRec;

      IF c_attributes%NOTFOUND THEN
        CLOSE c_attributes;
        EXIT;
      END IF;

      -- If the attribute is a component reference, then need to add the
      -- per instance prefix
      IF (attRec.att_name IN ('element', 'parent', 'after', 'before')) THEN
        attRec.att_value := extendingRegion || '.' || attRec.att_value;
      END IF;

      -- Do not need an element attribute if we already have one
      IF (attRec.att_name = 'element') THEN
        addElementAtt := FALSE;
      END IF;

      -- Insert the component into the per instance view
      INSERT INTO jdr_attributes
        (att_comp_docid, att_comp_seq, att_seq, att_name, att_value)
      VALUES
        (pageCustDocID, pageCompSeq,
         attRec.att_seq, attRec.att_name, attRec.att_value);

      nextAttSequence := attRec.att_seq + 1;
    END LOOP;

    -- Add the element attribute if necessary.  This will occur when the
    -- reference (in the region customization document) was to the top-level
    -- component (i.e. the region) and so was implicit.  But since the
    -- customization is moving from a top-level component to a non top-level
    -- component, we now must specify the element attribute.
    IF (addElementAtt = TRUE) THEN
      INSERT INTO jdr_attributes
        (att_comp_docid, att_comp_seq, att_seq, att_name, att_value)
      VALUES
        (pageCustDocID, pageCompSeq,
         nextAttSequence, 'element', extendingRegion);
    END IF;
  END;


  -- Add the components of the region customization document to the page
  -- customization document.
  --
  -- Parameters:
  --   pageCustDocID    Document ID of the page customization document
  --   pageStartSeq     Start sequence of the page components (destination)
  --   regionCustDocID  Document ID of the region customization document
  --   regionStartSeq   Start sequence of the region components (source)
  --   regionEndSeq     End sequence of the region components
  --   extendingRegion  Component ID of the extending region
  PROCEDURE addComponents(pageCustDocID    jdr_paths.path_docid%TYPE,
                          pageStartSeq     jdr_components.comp_seq%TYPE,
                          regionCustDocID  jdr_paths.path_docid%TYPE,
                          regionStartSeq   jdr_components.comp_seq%TYPE,
                          regionEndSeq     jdr_components.comp_seq%TYPE,
                          extendingRegion  jdr_components.comp_id%TYPE)
  IS
    CURSOR c_components(docID    jdr_paths.path_docid%TYPE,
                        startSeq jdr_components.comp_seq%TYPE,
                        endSeq   jdr_components.comp_seq%TYPE) IS
      SELECT comp_seq, comp_level, comp_grouping, comp_element, comp_id
      FROM jdr_components
      WHERE comp_docid = docID AND
            comp_seq >= startSeq AND
            comp_seq <= endSeq;

    pageSeq          jdr_components.comp_seq%TYPE := pageStartSeq;
    compRec          c_components%ROWTYPE;
    needElementAtt   BOOLEAN;
  BEGIN
    -- Retrieve all of the components from the region document and insert
    -- them into the page document
    OPEN c_components(regionCustDocID, regionStartSeq, regionEndSeq);
    LOOP
      FETCH c_components INTO compRec;

      IF c_components%NOTFOUND THEN
        CLOSE c_components;
        EXIT;
      END IF;

      -- Do not move initial 'views' or 'modifications' grouping unless this is
      -- the first customization of the page
      IF (pageSeq <> 1 AND compRec.comp_seq = 1) THEN
        compRec.comp_grouping := NULL;
      END IF;

      -- In the case where we are adding the contents of the view from the
      -- region to an existing view on the page, we do not want to move the
      -- 'modifications' grouping as it already exists for the view on the
      -- page.
      IF (compRec.comp_seq = regionStartSeq AND
          compRec.comp_grouping = 'modifications' AND
          pageSeq <> 1) THEN
        compRec.comp_grouping := NULL;
      END IF;

      INSERT INTO jdr_components
        (comp_docid, comp_seq, comp_level, comp_grouping, comp_element, comp_id)
      VALUES
        (pageCustDocID, pageSeq, compRec.comp_level,
         compRec.comp_grouping, compRec.comp_element, compRec.comp_id);

      -- If this row can contain a reference to the customized component, and
      -- if the shared view references a top-level component, then it
      -- previously would not have had an 'element' attribute which indicated
      -- which component to customize (because top-level attributes are
      -- implicitly referenced).  However, in propagating the view, the
      -- component may not be a top-level component anymore, and, if so, we
      -- will need to add an attribute for the reference to the component.
      IF compRec.comp_element IN ('modify', 'view')  THEN
        needElementAtt := TRUE;
      ELSE
        needElementAtt := FALSE;
      END IF;

      addAttributes(pageCustDocID,
                    pageSeq,
                    regionCustDocID,
                    comprec.comp_seq,
                    extendingRegion,
                    needElementAtt);


      -- Prepare for the next component
      pageSeq := pageSeq + 1;
    END LOOP;
  END;


  -- Append the modifications customizations from the region document to the
  -- end of the page document.
  --
  -- Parameters:
  --   pageCustDocID    Document ID of the page customization document
  --   regionCustDocID  Document ID of the region customization document
  --   extendingRegion  Component ID of the extending region
  PROCEDURE appendModifications(pageCustDocID    jdr_paths.path_docid%TYPE,
                                regionCustDocID  jdr_paths.path_docid%TYPE,
                                extendingRegion  jdr_components.comp_id%TYPE)

  IS
    pageStartSeq     jdr_components.comp_seq%TYPE;
    regionEndSeq     jdr_components.comp_seq%TYPE;
  BEGIN
    -- Get the starting sequence for the new customizations for the page
    SELECT MAX(comp_seq) + 1 INTO pageStartSeq
    FROM jdr_components
    WHERE comp_docid = pageCustDocID;

    -- Get the number of components which need to be added from the region
    SELECT MAX(comp_seq) INTO regionEndSeq
    FROM jdr_components
    WHERE comp_docid = regionCustDocID;

    addComponents(pageCustDocID,
                  pageStartSeq,
                  regionCustDocID,
                  1,
                  regionEndSeq,
                  extendingRegion);
  END;


  -- Append the view customizations from the region document to the
  -- page document.
  --
  -- Parameters:
  --   pageCustDocID    Document ID of the page customization document
  --   regionCustDocID  Document ID of the region customization document
  --   extendingRegion  Component ID of the extending region
  --   viewID           ID of the view
  PROCEDURE appendView(pageCustDocID    jdr_paths.path_docid%TYPE,
                       regionCustDocID  jdr_paths.path_docid%TYPE,
                       extendingRegion  jdr_components.comp_id%TYPE,
                       viewID           jdr_components.comp_id%TYPE)
  IS
    pageStartSeq      jdr_components.comp_seq%TYPE;
    pageEndSeq        jdr_components.comp_seq%TYPE;
    pageCompLevel     jdr_components.comp_level%TYPE;
    regionStartSeq    jdr_components.comp_seq%TYPE;
    regionEndSeq      jdr_components.comp_seq%TYPE;
    regionCompLevel   jdr_components.comp_level%TYPE;

    componentsAdded   jdr_components.comp_seq%TYPE;
  BEGIN
    -- Get the start sequence of the view
    SELECT comp_seq, comp_level INTO regionStartSeq, regionCompLevel
    FROM jdr_components
    WHERE comp_docid = regionCustDocID AND
          comp_element = 'view' AND
          comp_id = viewID;

    -- Get the end sequence of the view
    SELECT MIN(comp_seq) - 1  INTO regionEndSeq
    FROM jdr_components
    WHERE comp_docid =  regionCustDocID AND
          comp_seq > regionStartSeq AND
          comp_level <= regionCompLevel;

    -- If this is the last view in the document, the end sequence will be the
    -- last component in the document
    IF (regionEndSeq IS NULL) THEN
      SELECT MAX(comp_seq) INTO regionEndSeq
      FROM jdr_components
      WHERE comp_docid = regionCustDocID;
    END IF;

    -- Check if this view already exists in the page.  If so, we will need
    -- to append the contents of the region view to the page view
    BEGIN
      -- Get the start sequence of the view for the page (if the view exists)
      SELECT comp_seq, comp_level INTO pageStartSeq, pageCompLevel
      FROM jdr_components
      WHERE comp_docid = pageCustDocID AND
            comp_element = 'view' AND
            comp_id = viewID;

      -- Get the end sequence of the view for the page (if the view exists)
      SELECT MIN(comp_seq) - 1  INTO pageEndSeq
      FROM jdr_components
      WHERE comp_docid =  pageCustDocID AND
            comp_seq > pageStartSeq AND
            comp_level <= pageCompLevel;

      -- If this is the last view in the document, the end sequence will be the
      -- last component in the document
      IF (pageEndSeq IS NULL) THEN
        SELECT MAX(comp_seq) INTO pageEndSeq
        FROM jdr_components
        WHERE comp_docid = pageCustDocID;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- If the view does not exist in the page already, then we will append
        -- the view to the end of the page customization document.
        SELECT MAX(comp_seq) + 1 INTO pageStartSeq
        FROM jdr_components
        WHERE comp_docid = pageCustDocID;
    END;

    IF (pageEndSeq IS NULL) THEN
      -- A null pageEndSeq indicates that the view does not exist in the page,
      -- so we can append the view to the end of the page customization
      -- document
      addComponents(pageCustDocID,
                    pageStartSeq,
                    regionCustDocID,
                    regionStartSeq,
                    regionEndSeq,
                    extendingRegion);
    ELSE
      -- The view already exists in the page document, so we need to append the
      -- contents of the region view to the page view of the same name.  To
      -- do this, we will shift all of the components after the page view up,
      -- to make room for the contents of the region view.
      componentsAdded := regionEndSeq - regionStartSeq + 1;

      -- Shift the components to make room for the region view
      UPDATE jdr_components
      SET comp_seq = comp_seq + componentsAdded
      WHERE comp_docid = pageCustDocID AND
            comp_seq > pageEndSeq;

      -- Shift the attributes to make room for the region view
      UPDATE jdr_attributes
      SET att_comp_seq = att_comp_seq + componentsAdded
      WHERE att_comp_docid = pageCustDocID AND
            att_comp_seq > pageEndSeq;

      -- Now that we have made room for the view, we can safely add the
      -- components.
      addComponents(pageCustDocID,
                    pageEndSeq + 1,
                    regionCustDocID,
                    regionStartSeq + 1,
                    regionEndSeq,
                    extendingRegion);
    END IF;
  END;

  --
  -- Get precedence order of a customization layer type
  --
  FUNCTION getPrecedence(type  VARCHAR2,
                         value VARCHAR2 DEFAULT NULL) RETURN NUMBER
  IS
    upperType  VARCHAR2(100);
    upperValue VARCHAR2(100);
  BEGIN
    upperType := upper(type);
    IF (upperType = 'FUNCTION')
    THEN
      RETURN(FUNCTION_LEVEL);
    END IF;
    IF (upperType = 'VERTICALIZATION')
    THEN
      RETURN(VERTICALIZATION_LEVEL);
    END IF;
    IF (upperType = 'LOCALIZATION')
    THEN
      RETURN(LOCALIZATION_LEVEL);
    END IF;
    IF (upperType = 'SITE')
    THEN
      RETURN(SITE_LEVEL);
    END IF;
    IF (upperType = 'ORG')
    THEN
      RETURN(ORG_LEVEL);
    END IF;
    IF (upperType = 'RESPONSIBILITY')
    THEN
      RETURN(RESPONSIBILITY_LEVEL);
    END IF;
    IF (upperType = 'USER')
    THEN
      IF value IS NOT NULL
      THEN
        upperValue := upper(value);
        IF (upperValue = 'SEEDEDCUSTOMER')
        THEN
          RETURN(SEEDED_CUST_USER_LEVEL);
        ELSIF (upperValue = 'SEEDEDDEVELOPER')
        THEN
          RETURN(SEEDED_DEV_USER_LEVEL);
        END IF;
      END IF;
      RETURN(END_USER_LEVEL);
    END IF;
    IF (upperType = PORTLET)
    THEN
      RETURN(PORTLET_LEVEL);
    END IF;
  END;

  --
  -- Sorts the layers into precedence order, from lowest to highest
  -- Currently using insertion sort. At the same time, sort customization
  -- documents to match layer precedence.
  --
  PROCEDURE sortLayersWithDocs(lyrTypes  IN OUT NOCOPY /* file.sql.39 change */ jdr_stringArray,
                               lyrValues IN OUT NOCOPY /* file.sql.39 change */ jdr_stringArray,
                               custDocs  IN OUT NOCOPY /* file.sql.39 change */ jdr_stringArray)
  IS
    i NUMBER;
    j NUMBER;
    currType  VARCHAR2(50);
    currValue VARCHAR2(100);
    currDoc VARCHAR2(512);
    currPrecedence NUMBER;
    typeArray jdr_stringArray := lyrTypes;
    valArray  jdr_stringArray := lyrValues;
    docArray  jdr_stringArray := custDocs;
  BEGIN
    IF typeArray.COUNT > 1
    THEN
      FOR i IN 2..typeArray.COUNT LOOP
        j := i;
        currType  := typeArray(i);
        currValue := valArray(i);
        currDoc   := docArray(i);
        currPrecedence := getPrecedence(currType, currValue);
        WHILE (j > 1) AND
            (getPrecedence(typeArray(j-1), valArray(j-1)) > currPrecedence) LOOP
          typeArray(j) := typeArray(j-1);
          valArray(j)  := valArray(j-1);
          docArray(j)  := docArray(j-1);
          j := j - 1;
        END LOOP;
        typeArray(j) := currType;
        valArray(j)  := currValue;
        docArray(j)  := currDoc;
      END LOOP;
    END IF;
    lyrTypes  := typeArray;
    lyrValues := valArray;
    custDocs  := docArray;
  END;


 -- Returns the full name of the customization document
  --
  -- baseDocName is the full name of the base document
  -- layerType is the type of customization layer - i.e. Site, Localization
  -- layerValue is the value of the layer type - i.e. Sears, US
  --
  -- returns docname = <fullBasePackage>/customizations/<layerName>/
  --                   <layerValue>/<docName>
  -- where <fullBasePacakge> is the full name of the package containing the
  -- base document.
  -- ex. base page - /oracle/apps/hr/pages/page1
  --     cust page - /oracle/apps/hr/pages/customizations/site/sears/page1
  --
  FUNCTION getCustomizationDocName(
    baseDocName       VARCHAR2,
    layerType         VARCHAR2,
    layerValue        VARCHAR2) RETURN VARCHAR2
  IS
    custDocName VARCHAR2(512);
    lenPkg      NUMBER;
    lenApp      NUMBER;
    pkgName     VARCHAR2(512);
    baseName    VARCHAR2(512);
  BEGIN
    lenPkg  := INSTR(baseDocName, '/', -1, 1);
    IF lenPkg = 0 OR
       lenPkg = LENGTH(baseDocName)
    THEN
      RETURN NULL;
    END IF;
    IF lenPkg = 1
    THEN
      pkgName  := '';
    ELSE
      pkgName  := SUBSTR(baseDocName, 1, lenPkg - 1);
    END IF;
    baseName := SUBSTR(baseDocName, lenPkg + 1);
    custDocName := pkgName || '/customizations/' || layerType  || '/'
                           || layerValue        || '/'        || baseName;
    RETURN(custDocName);
  END;


  -- Returns the full name of the customization document, using the old
  -- customization directory structure
  --
  -- baseDocName is the full name of the base document
  -- layerType is the type of customization layer - i.e. Site, Localization
  -- layerValue is the value of the layer type - i.e. Sears, US
  --
  -- returns docname = /oracle/apps/<productname>/customizations/<layertype>/
  --                   <layervalue>/<remainder of base docname>
  -- ex. base page - /oracle/apps/hr/pages/page1
  --     cust page - /oracle/apps/hr/customizations/site/sears/pages/page1
  --
  FUNCTION getOldCustomizationDocName(
    baseDocName       VARCHAR2,
    layerType         VARCHAR2,
    layerValue        VARCHAR2) RETURN VARCHAR2
  IS
    custDocName VARCHAR2(512);
    lenRoot NUMBER;
    lenApp NUMBER;
    startDoc VARCHAR2(512);
    endDoc VARCHAR2(512);
  BEGIN
    lenRoot := LENGTH(APPS_ROOTDIR);
    IF SUBSTR(baseDocName, 1, lenRoot) = APPS_ROOTDIR
    THEN
      startDoc := APPS_ROOTDIR;
      endDoc := substr(baseDocName, lenRoot+1);
      lenApp := instr(endDoc, '/');
      IF NOT lenApp = 0
      THEN
        startDoc := startDoc || substr(endDoc, 1, lenApp);
        endDoc := substr(endDoc, lenApp+1);
        custDocName := startDoc || 'customizations/'
                       || layerType || '/'
                       || layerValue || '/'
                       || endDoc;
      END IF;
    END IF;
    RETURN(custDocName);
  END;


  -- Returns the full reference to the portlet customization document, using
  -- the old method of using <portletReferencePath> as the layer value.
  -- The new method, using <userId_portletReferencePath> as the layer value,
  -- was developed to resolve bug 2587054.  However, the old reference still
  -- is used to find any portlet customizations which were created before Apps
  -- introduced the userId dependency.
  --
  -- baseDocName is the full name of the base document
  -- layerType is the portlet customization layer
  -- portletVal is the customization layer value of the portlet
  --
  FUNCTION getOldPortletReference(
    baseDocName       VARCHAR2,
    layerType         VARCHAR2,
    portletVal        VARCHAR2,
    newCustDirectory  BOOLEAN DEFAULT TRUE) RETURN VARCHAR2
  IS
    portletRef    VARCHAR2(512);
    newPortletVal VARCHAR2(512);
    userIdx       NUMBER;
  BEGIN
    userIdx := instr(portletVal, '_');
    IF NOT userIdx = 0
    THEN
      newPortletVal  := substr(portletVal, userIdx + 1);
      IF ( newCustDirectory )
      THEN
        portletRef     := getCustomizationDocName(baseDocName,
                                                  layerType,
                                                  newPortletVal);
      ELSE
        portletRef     := getOldCustomizationDocName(baseDocName,
                                                     layerType,
                                                     newPortletVal);
      END IF;
    END IF;
    RETURN(portletRef);
  END;

  PROCEDURE getLayers(baseDoc    IN  VARCHAR2,
                      lyrTypes   IN  jdr_stringArray,
                      lyrValues  IN  jdr_stringArray,
                      validTypes OUT NOCOPY /* file.sql.39 change */ jdr_stringArray,
                      custDocs   OUT NOCOPY /* file.sql.39 change */ jdr_stringArray,
                      activeOnly IN  BOOLEAN DEFAULT FALSE)
  IS
    valid jdr_stringArray := jdr_stringArray(null);
    lvals jdr_stringArray := jdr_stringArray(null);
    docs jdr_stringArray := jdr_stringArray(null);
    custName    VARCHAR2(512);
    tmpCustName VARCHAR2(512);
    custDocID NUMBER;
    cnt NUMBER := 1;
    isActive VARCHAR2(10);
  BEGIN
    FOR i IN 1..lyrTypes.COUNT LOOP
      -- For each layer, attempt to find the customization document
      custName := getCustomizationDocName(baseDoc,
                                          lyrTypes(i),
                                          lyrValues(i));
      IF NOT custName IS NULL
      THEN
        custDocID := jdr_mds_internal.getDocumentID(custName, 'DOCUMENT');
        IF (custDocID = -1)
        THEN
          IF (upper(lyrTypes(i)) = PORTLET)
          THEN
            -- Assuming that the portlet value is <userid>_<referencepath>,
            -- try using value <referencepath> if no customization doc was found
            tmpCustName := getOldPortletReference(baseDoc,
                                                  lyrTypes(i),
                                                  lyrValues(i));
            custDocID := jdr_mds_internal.getDocumentID(tmpCustName,
                                                        'DOCUMENT');
            IF ( custDocID <> -1 )
            THEN
              custName  := tmpCustName;
            END IF;
          END IF;
          IF ( custDocID = -1 )
          THEN
            -- We haven't found a customization document yet. Some
            -- customizations may have been migrated using the old customization
            -- directory structure (before the fix for bug 2849379).
            tmpCustName := getOldCustomizationDocName(baseDoc,
                                                      lyrTypes(i),
                                                      lyrValues(i));
            custDocID := jdr_mds_internal.getDocumentID(tmpcustName,
                                                        'DOCUMENT');
            IF ( custDocID <> -1 )
            THEN
              custName := tmpCustName;
            ELSE
              IF (upper(lyrTypes(i)) = PORTLET)
              THEN
                -- Assuming that the portlet value is <userid>_<referencepath>,
                -- try using value <referencepath> in the old customization
                -- directory structure
                tmpCustName := getOldPortletReference(baseDoc,
                                                      lyrTypes(i),
                                                      lyrValues(i),
                                                      FALSE);
                custDocID := jdr_mds_internal.getDocumentID(tmpCustName,
                                                            'DOCUMENT');
                IF ( custDocID <> -1 )
                THEN
                  custName  := tmpCustName;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
        IF NOT custDocID = -1
        THEN
          isActive := 'true';  -- by default, all docs are active
          IF activeOnly
          THEN
            BEGIN
              SELECT  att_value INTO isActive
                FROM  jdr_attributes
                WHERE att_comp_docid = custDocID AND
                      att_comp_seq   = 0         AND
                      att_name = 'MDSActiveDoc';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                isActive := 'true';
            END;
          END IF;
          IF isActive = 'true'
          THEN
            IF (cnt <> 1)
            THEN
              valid.extend;
              lvals.extend;
              docs.extend;
            END IF;
            valid(valid.COUNT) := lyrTypes(i);
            lvals(lvals.COUNT) := lyrValues(i);
            docs(docs.COUNT) := custName;
            cnt := cnt + 1;
          END IF;
        END IF;
      END IF;
      END LOOP;
    sortLayersWithDocs(valid, lvals, docs);
    validTypes := valid;
    custDocs := docs;
  END;


  -----------------------------------------------------------------------------
  ---------------------------- PUBLIC FUNCTIONS -------------------------------
  -----------------------------------------------------------------------------

  PROCEDURE migrateCustomizationsToPage(regionCustDocName   IN VARCHAR2,
                                        extendingRegionName IN VARCHAR2)
  IS
    CURSOR c_translations(docID jdr_paths.path_docid%TYPE) IS
     SELECT  atl_lang, atl_comp_ref, atl_name, atl_value
     FROM jdr_attributes_trans
     WHERE atl_comp_docid = docID;

    CURSOR c_views(docID jdr_paths.path_docid%TYPE) IS
      SELECT comp_id
      FROM jdr_components
      WHERE comp_docid = docID and
            comp_element = 'view'
      ORDER BY comp_seq;

    tranRec            c_translations%ROWTYPE;
    pageBaseDocName    VARCHAR2(512);
    pageCustDocName    VARCHAR2(512);
    pageCustDocID      jdr_paths.path_docid%TYPE;
    regionBaseDocName  VARCHAR2(512);
    regionCustDocID    jdr_paths.path_docid%TYPE;
    regionBaseDocID    jdr_paths.path_docid%TYPE;
    custType           jdr_components.comp_grouping%TYPE;
    extendingRegion    jdr_components.comp_id%TYPE;
    viewID             jdr_components.comp_id%TYPE;
    pos1               INTEGER;
    pos2               INTEGER;
    tempStr            VARCHAR2(1);
    migrateCusts       BOOLEAN := FALSE;
  BEGIN
    -- This will be called when a region has been refactored from inside a
    -- page to its own document; and when we need the shared customizations on
    -- the region to be migrated as per instance customizations on the page.

    -- Create savepoint so we have something to rollback to if an error occurs
    SAVEPOINT sp;
    -- Construct the name of the page customization document
    --
    -- Suppose the extending region is:
    --   /oracle/apps/hr/webui/musicpage.extendingRegion
    -- and the region customization document is:
    --   /oracle/apps/hr/customizations/site/tower/region
    -- then the page customization document will be:
    --  /oracle/apps/hr/customizations/site/tower/webui/musicpage
    --
    -- Get the name of the page document and the extending region
    pos1 := INSTR(extendingRegionName, '.', -1);
    pageBaseDocName := SUBSTR(extendingRegionName, 1, pos1 - 1);
    extendingRegion := SUBSTR(extendingRegionName, pos1 + 1);

    -- Get the "/oracle/apps/hr" portion
    -- page cust doc -> /oracle/apps/hr
    pos1 := INSTR(pageBaseDocName, '/', 1, 4);
    pageCustDocName := SUBSTR(pageBaseDocName, 1, pos1 - 1);

    -- Add the customizations package
    -- page cust doc -> /oracle/apps/hr/customizations
    pageCustDocName := pageCustDocName || '/customizations';

    -- Add the layer type and layer value
    -- page cust doc -> /oracle/apps/hr/customizations/site/tower
    pos1 := INSTR(regionCustDocName, '/customizations');
    pos1 := INSTR(regionCustDocName, '/', pos1 + 1);
    pos2 := INSTR(regionCustDocName, '/', pos1 + 1, 2);
    pageCustDocName := pageCustDocName ||
                       SUBSTR(regionCustDocName, pos1, pos2 - pos1);

    -- Add the webui portion and document name
    -- page cust doc -> /oracle/apps/hr/customizations/site/tower/webui/musicpage
    pos1 := INSTR(pageBaseDocName, '/', 1, 4);
    pageCustDocName := pageCustDocName || SUBSTR(pageBaseDocName, pos1);

    -- Construct the name of the base document of the region.  We need this
    -- as we will need the children of the region to determine if there are
    -- any existing customizations on the region from the page customization
    -- document.
    pos1 := INSTR(regionCustDocName, '/customizations');
    pos2 := INSTR(regionCustDocName, '/', pos1 + 1, 3);
    regionBaseDocName := SUBSTR(regionCustDocName, 1, pos1) ||
                         SUBSTR(regionCustDocName, pos2 + 1);
    regionBaseDocID := jdr_mds_internal.getDocumentID(regionBaseDocName, 'DOCUMENT');
    regionCustDocID := jdr_mds_internal.getDocumentID(regionCustDocName, 'DOCUMENT');


    -- Check if there are any existing customizations
    pageCustDocID := jdr_mds_internal.getDocumentID(pageCustDocName, 'DOCUMENT');
    IF (pageCustDocID > 0) THEN
      -- The page customization document exists, so we need to check if it
      -- contains any references to the region
      BEGIN
        SELECT 'x' INTO tempStr FROM DUAL WHERE EXISTS (
          SELECT *
          FROM jdr_components, jdr_attributes
          WHERE comp_docid = pageCustDocID AND
                att_comp_docid = pageCustDocID AND
                att_comp_seq = comp_seq AND
                comp_element IN ('view', 'modify', 'move', 'insert', 'criterion') AND
                att_name IN ('element', 'before', 'after', 'parent') AND
                (
                  att_value = extendingRegion OR
                  att_value LIKE extendingRegion||'.%' OR
                  att_value IN (SELECT comp_id
                                FROM jdr_components
                                WHERE comp_docid = regionBaseDocID AND
                                      comp_id IS NOT NULL)
                )
          );

        -- Since the NO_DATA_FOUND exception did not occur, we know that the
        -- page customization document already contains customizations on the
        -- region, so we do NOT want to migrate the customizations.
        migrateCusts := FALSE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          migrateCusts := TRUE;
      END;
    ELSE
      -- The page customization document does not exist, so we need to migrate
      -- the customizations
      migrateCusts := TRUE;
    END IF;

    IF (migrateCusts = TRUE) THEN
      -- Create the customization document if it does not already exist
      IF (pageCustDocID < 1) THEN
        DECLARE
          doc   jdr_docbuilder.document;
          elem  jdr_docbuilder.element;
        BEGIN
          jdr_docbuilder.refresh;
          doc := jdr_docbuilder.createDocument(pageCustDocName);
          elem := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'customization');

          jdr_docbuilder.setattribute(elem, 'customizes', pageBaseDocName);
          jdr_docbuilder.settoplevelelement(doc, elem);
          IF jdr_docbuilder.save <> jdr_docbuilder.SUCCESS THEN
            goto error;
          END IF;
          pageCustDocID := jdr_mds_internal.getDocumentID(pageCustDocName, 'DOCUMENT');
        END;
      END IF;


      -- Lock the document prior to modifying it
      jdr_mds_internal.lockDocument(pageCustDocID);

      -- Customizations views and non-view customizations need to be
      -- handled differently, since views are a little more complex.
      -- Determine what type of customization document we are dealing with.
      SELECT comp_grouping INTO custType
      FROM jdr_components
      WHERE comp_docid = regionCustDocID AND
            comp_seq = 1;

      IF (custType = 'modifications') THEN
        appendModifications(pageCustDocID, regionCustDocID, extendingRegion);
      ELSE
        -- Since the page customization document may contain views of the same
        -- name as the region customization document, we need to deal with one
        -- view at a time.  If the page customization document does not
        -- contain a view with the same name, we will simply append the view
        -- to the end of the page document.  If the page does contain a view
        -- with the same name, then we will append the contents of the view
        -- of the region to the view of the page.
        OPEN c_views(regionCustDocID);
        LOOP
          FETCH c_views INTO viewID;

          IF c_views%NOTFOUND THEN
            CLOSE c_views;
            EXIT;
          END IF;

          -- Add the view to the page customization document
          appendView(pageCustDocID, regionCustDocID, extendingRegion, viewID);
        END LOOP;
      END IF;

      -- Update the translations
      OPEN c_translations(regionCustDocID);
      LOOP
        FETCH c_translations INTO tranRec;

        IF c_translations%NOTFOUND THEN
          CLOSE c_translations;
          EXIT;
        END IF;

        -- Convert the reference appropriately using the following:
        --   . -> extendingRegion
        --   :viewID -> :viewID.extendingRegion
        --   :viewID.child -> :viewID.extendingRegion.child
        --   child -> extendingRegion.child
        IF tranRec.atl_comp_ref = '.' THEN
          tranRec.atl_comp_ref := extendingRegion;
        ELSIF INSTR(tranRec.atl_comp_ref, ':') <> 1 THEN
          tranRec.atl_comp_ref := extendingRegion || '.' || tranRec.atl_comp_ref;
        ELSE
          pos1 := INSTR(tranRec.atl_comp_ref, '.');
          IF (pos1 = 0) THEN
            tranRec.atl_comp_ref := tranRec.atl_comp_ref || '.' || extendingRegion;
          ELSE
            tranRec.atl_comp_ref := SUBSTR(tranRec.atl_comp_ref, 1, pos1) ||
                                    extendingRegion ||
                                    SUBSTR(tranRec.atl_comp_ref, pos1);
          END IF;
        END IF;

        INSERT INTO jdr_attributes_trans
          (atl_comp_docid, atl_lang, atl_comp_ref, atl_name, atl_value)
        VALUES
          (pageCustDocID,
           tranRec.atl_lang, tranRec.atl_comp_ref,
           tranRec.atl_name, tranRec.atl_value);
      END LOOP;
    END IF;

    -- Delete the document and remove any translations
    jdr_mds_internal.deleteDocument(regionCustDocID, TRUE);

    DELETE jdr_attributes_trans WHERE atl_comp_docid = regionCustDocID;

    COMMIT;

  <<cleanup>>
    RETURN;

  <<error>>
    ROLLBACK TO SAVEPOINT sp;
    GOTO cleanup;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT sp;
  END;



  PROCEDURE getCustomizationDocs(baseDoc    IN  VARCHAR2,
                                 custDocs   OUT NOCOPY /* file.sql.39 change */ jdr_stringArray)
  IS
    oldRef       VARCHAR2(512);
    newRef       VARCHAR2(512);
    currDoc      VARCHAR2(512);
    currLayer    VARCHAR2(100);
    pathName     JDR_PATHS.PATH_NAME%TYPE;
    custIndex    NUMBER;
    layerIndex   NUMBER;
    cntDocs      NUMBER  := 1;
    cntLayers    NUMBER  := 1;
    layerExists  BOOLEAN := FALSE;
    getOldRefs   BOOLEAN := TRUE;
    docs         jdr_stringArray := jdr_stringArray(null);
    layers       jdr_stringArray := jdr_stringArray(null);
    CURSOR c(custDocLike VARCHAR2, pathName VARCHAR2) IS
      SELECT jdr_mds_internal.getDocumentName(path_docid)
      FROM jdr_paths
      WHERE path_type = 'DOCUMENT' AND
            path_name = pathName   AND
            path_seq  = -1         AND
            jdr_mds_internal.getDocumentName(path_docid) like custDocLike;
  BEGIN
    newRef := getCustomizationDocName(baseDoc, '%', '%');
    oldRef := getOldCustomizationDocName(baseDoc, '%', '%');
    IF oldRef IS NULL THEN
      getOldRefs := FALSE;
    END IF;
    IF ( newRef = oldRef ) THEN
      getOldRefs := FALSE;
    END IF;
    -- Get path name of base document
    pathName := substr(baseDoc, instr(baseDoc, '/', -1) + 1);
    -- Look for all customization docs using the new reference
    OPEN c(newRef, pathName);
    LOOP
      FETCH c INTO currDoc;
      IF (c%NOTFOUND) THEN
        CLOSE c;
        EXIT;
      END IF;
      IF (cntDocs <> 1 ) THEN
        docs.extend;
      END IF;
      docs(docs.COUNT) := currDoc;
      cntDocs := cntDocs + 1;
      IF getOldRefs THEN
      -- Extract the customization layer from the document
        custIndex := instr(currDoc, '/customizations/');
        currLayer := substr(currDoc,
                            custIndex,
                            instr(currDoc, '/', custIndex, 4) - custIndex);
        IF ( cntLayers <> 1 ) THEN
          layers.extend;
        END IF;
        layers(layers.COUNT) := currLayer;
        cntLayers := cntLayers + 1;
      END IF;
    END LOOP;
    IF ( getOldRefs ) THEN
      -- Look for all customization docs using the old reference;
      OPEN c(oldRef, pathName);
      LOOP
        FETCH c INTO currDoc;
        IF (c%NOTFOUND) THEN
          CLOSE c;
          EXIT;
        END IF;
        -- Check whether this customization document is obsolete, i.e. that
        -- the same document exists under the new reference
        layerIndex   := layers.FIRST;
        layerExists := FALSE;
        WHILE layerIndex IS NOT NULL LOOP
          IF instr(currDoc, layers(layerIndex)) <> 0 THEN
            -- This layer already exists
            layerExists := TRUE;
            EXIT;
          END IF;
          layerIndex := layers.NEXT(layerIndex);
        END LOOP;
        IF layerExists = FALSE THEN
          IF (cntDocs <> 1 ) THEN
            docs.extend;
          END IF;
          docs(docs.COUNT) := currDoc;
          cntDocs := cntDocs + 1;
        END IF;
      END LOOP;
    END IF;
    custDocs := docs;
  END;

  PROCEDURE getActiveLayers(baseDoc   IN  VARCHAR2,
                           lyrTypes   IN  jdr_stringArray,
                           lyrValues  IN  jdr_stringArray,
                           validTypes OUT NOCOPY /* file.sql.39 change */ jdr_stringArray,
                           custDocs   OUT NOCOPY /* file.sql.39 change */ jdr_stringArray)
  IS
  BEGIN
    getLayers(baseDoc, lyrTypes, lyrValues, validTypes, custDocs, TRUE);
  END;

  PROCEDURE getLayers(baseDoc    IN  VARCHAR2,
                      lyrTypes   IN  jdr_stringArray,
                      lyrValues  IN  jdr_stringArray,
                      validTypes OUT NOCOPY /* file.sql.39 change */ jdr_stringArray,
                      custDocs   OUT NOCOPY /* file.sql.39 change */ jdr_stringArray)
  IS
  BEGIN
    getLayers(baseDoc, lyrTypes, lyrValues, validTypes, custDocs, FALSE);
  END;

  --
  -- Sorts the layers into precedence order, from lowest to highest
  -- Currently using insertion sort.
  --
  PROCEDURE sortLayers(lyrTypes IN OUT NOCOPY /* file.sql.39 change */ jdr_stringArray)
  IS
    i NUMBER;
    j NUMBER;
    currLayer VARCHAR2(50);
    currPrecedence NUMBER;
    typeArray jdr_stringArray := lyrTypes;
  BEGIN
    IF typeArray.COUNT > 1
    THEN
      FOR i IN 2..typeArray.COUNT LOOP
        j := i;
        currLayer := typeArray(i);
        currPrecedence := getPrecedence(currLayer);
        WHILE (j > 1) AND
             (getPrecedence(typeArray(j-1)) > currPrecedence) LOOP
          typeArray(j) := typeArray(j-1);
          j := j - 1;
        END LOOP;
        typeArray(j) := currLayer;
      END LOOP;
    END IF;
    lyrTypes := typeArray;
  END;

END;

/
