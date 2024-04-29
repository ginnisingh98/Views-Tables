--------------------------------------------------------
--  DDL for Package Body IES_META_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_META_DATA_PKG" AS
     /* $Header: iesmdpkb.pls 120.2 2006/05/30 22:08:43 prkotha noship $ */

     -- Private methods

     -- **********************************************************************
     --  API name    : metaRelationshipExists
     --  Type        : Private
     --  Function    : This function returns True if the relationship
     --                exists for a given primary_obj_id, secondary_obj_id
     --                and type_id
     -- **********************************************************************

     FUNCTION metaRelationshipExists(primObjId IN NUMBER,
                                     secObjId  IN NUMBER,
                                     typeId    IN NUMBER)
     RETURN Boolean IS
        TYPE rel_type IS REF CURSOR;
        rel  rel_type;

        object_Id NUMBER := -1;
     BEGIN
       OPEN rel FOR
        'SELECT a.primary_obj_id
          FROM ies_meta_obj_relationships a
         WHERE a.primary_obj_id = :primObjId
           AND a.secondary_obj_id = :secObjId
           AND a.type_id = :typeId' using primObjId, secObjId, typeId;

        FETCH rel INTO object_id;
        CLOSE rel;

        return (object_id <> -1);
     END metaRelationshipExists;


     -- **********************************************************************
     --  API name    : existsObject
     --  Type        : Private
     --  Function    : This function returns true if the object exists with the
     --                UID passed in as argument
     -- **********************************************************************

     FUNCTION existsObject(uid VARCHAR2) RETURN BOOLEAN IS
        type objs_type IS REF CURSOR;
        obj  objs_type;

        objId number := -1;
     BEGIN
        OPEN obj FOR
         'SELECT object_id
            FROM ies_meta_objects
           WHERE object_uid = :x_uid' using uid;

        FETCH obj INTO objId;
        CLOSE obj;

        return (objId <> -1);
     END existsObject;

     -- **********************************************************************
     --  API name    : objectExistsInLibrary
     --  Type        : Private
     --  Function    : This function returns true if the object exists in
     --                the IES_META_LIBRARY table
     -- **********************************************************************

     FUNCTION objectExistsInLibrary(objectId NUMBER) RETURN BOOLEAN IS
        type objs_type IS REF CURSOR;
        obj  objs_type;

        objId number := -1;
     BEGIN
        OPEN obj FOR
         'SELECT 1
            FROM ies_meta_library
           WHERE object_id = :x_id' using objectId;

        FETCH obj INTO objId;
        CLOSE obj;

        return (objId <> -1);
     END objectExistsInLibrary;

     -- **********************************************************************
     --  API name    : writeLibraryRecord
     --  Type        : Private
     --  Function    : This procedure inserts a record in IES_META_LIBRARY
     --                table
     -- **********************************************************************

     PROCEDURE writeLibraryRecord(objectId NUMBER) IS
        insertStmt varchar2(2000);
        seqval number;
     BEGIN
       if NOT (objectExistsInLibrary(objectId)) then /* If object does not exist in library */
          execute immediate 'SELECT ies_meta_library_s.nextval from dual' into seqval;
          insertStmt := 'INSERT INTO ies_meta_library(libobj_id,
 	                                             object_id,
 	                                             created_by)
 	                                     VALUES (:seq,
 	                                             :x_objId,
                                                      1)';
           EXECUTE IMMEDIATE insertStmt using seqval, objectId;
       end if;
     END writeLibraryRecord;


     -- **********************************************************************
     --  API name    : getChildEntities
     --  Type        : Private
     --  Function    : This function navigates the XML Tree and gets all the
     --                children for a given element
     -- **********************************************************************

     FUNCTION  getChildEntities(e IN xmldom.DOMElement) return childEntities_table IS
        childEntities_tab childEntities_table; /* childEntities_table is table of xmldom.DOMNode */
        nl        xmldom.DOMNodeList;
        len       number;
        n         xmldom.DOMNode;
        counter   number := 0; /* represents index in table */
        dummyNode xmldom.DOMNode;
        dummyElem xmldom.DOMElement;
        s         varchar2(256);
     BEGIN
        if NOT (xmldom.isnull(e)) then  /* Navigate tree only if element IS NOT NULL */
           nl  := xmldom.getChildNodes(xmldom.makeNode(e));
           len := xmldom.getLength(nl);

           for i in 0..len-1 loop /* For all child nodes of root element */
               n := xmldom.item(nl, i);

               dummyElem := xmldom.makeElement(n);

               if (xmldom.getTagName(dummyElem) = 'Properties') then /* Still in root's properties */
  	         childEntities_tab  := getChildEntities(dummyElem);
  	      end if;

               if (xmldom.getTagName(dummyElem) = 'CCTPropertyList') then /* Child named CCTPropertyList */
  	         childEntities_tab(counter) := xmldom.getFirstChild(n); /* Node starting with <Property .. */
  	         counter := counter + 1;
  	      elsif (xmldom.getTagName(dummyElem) = 'CCTPropertyMapList') then /* Child named CCTPropertyMapList */
  	         childEntities_tab(counter) := xmldom.getFirstChild(n);  /* Node starting with <Property .. */
  	         counter := counter + 1;
  	      elsif (xmldom.getTagName(dummyElem) = 'ChildObject') then /* ChildObject */
  	         childEntities_tab(counter) := n; /* Node starting with <ChildObject NAME=... */
  	         counter := counter + 1;
  	      end if;
           end loop;
        end if;
        return childEntities_tab;
     END getChildEntities;

     -- **********************************************************************
     --  API name    : saveChildObjectsToDB
     --  Type        : Private
     --  Function    : This procedure saves children objects by calling
     --                saveObjectTobDB recursively in the tree
     -- **********************************************************************

     PROCEDURE saveChildObjectsToDB(element IN xmldom.DOMElement, rootObjId IN NUMBER) IS
        namedMap  xmldom.DOMNamedNodeMap;
        childEntities_tab childEntities_table;
        child      xmldom.DOMElement;
        objId      number;
        objOrder   number;
     BEGIN
        childEntities_tab := getChildEntities(element); /* Get all child elements */

        for i in 0..childEntities_tab.count-1 loop
            child := xmldom.makeElement(childEntities_tab(i));
            objOrder := xmldom.getAttribute(child, 'OBJECT_ORDER'); /* Elements like CCTPropertyList and CCTPropertyMapList have this attribute */
            objId := saveObjectToDB(child, rootObjId, objOrder);    /* rootObjId is the parents object id */
        end loop;
     END saveChildObjectsToDB;

     -- **********************************************************************
     --  API name    : writeDataIntoMetaRelationships
     --  Type        : Private
     --  Function    : This procedure inserts/updates record in
     --                ies_meta_obj_relationships table
     -- **********************************************************************

     PROCEDURE writeDataIntoMetaRelationships(primObjId IN NUMBER, secObjId IN NUMBER, typeId IN NUMBER, objOrder IN NUMBER) IS
        sqlStmt varchar2(2000);
        seqval  number;
     BEGIN
        if NOT (metaRelationshipExists(primObjId, secObjId, typeId)) then
             execute immediate 'select ies_meta_obj_relationships_s.nextval from dual' into seqval;
             sqlStmt := 'INSERT INTO ies_meta_obj_relationships (
                                                   objrel_id,
                                                   obj_Order,
                                                   primary_obj_id,
                                                   secondary_obj_id,
                                                   type_id,
                                                   created_by)
                                           VALUES (:seq,
                                                   :objectOrder,
                                                   :primObjId,
                                                   :secObjId,
                                                   :typeId,
                                                   1)';
            EXECUTE IMMEDIATE sqlStmt using seqval, objOrder, primObjId, secObjId, typeId;
        else
            sqlStmt  := 'UPDATE ies_meta_obj_relationships SET obj_order = :objectOrder
                          WHERE primary_obj_id = :primObjId
                            AND secondary_obj_id = :secObjId
                            AND type_id          = :typeId';
            EXECUTE IMMEDIATE sqlStmt using objOrder, primObjId, secObjId, typeId;
        end if;


     EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20101, sqlerrm||' Error in writing data to MetaRelationships');
     END writeDataIntoMetaRelationships;

     -- **********************************************************************
     --  API name    : saveMetaRelationships
     --  Type        : Private
     --  Function    : This procedure saves record in ies_meta_obj_relationships
     --                table, first inserts self relationship record
     -- **********************************************************************

     PROCEDURE saveMetaRelationships(rootObjId IN NUMBER, objId IN NUMBER, typeName IN VARCHAR2, objOrder IN NUMBER) IS
        rootId NUMBER;
     BEGIN
        writeDataIntoMetaRelationships(objId, objId, IES_META_DATA_UTIL.getRelationshipTypeId('self'), null);
        if (rootObjId <> -1) then /* Self relationship */
            writeDataIntoMetaRelationships(rootObjId, objId, IES_META_DATA_UTIL.getRelationshipTypeId(typeName), objOrder);
        end if;
     END saveMetaRelationships;

     /******************* PUBLIC METHODS ************************************/

     -- **********************************************************************
     --  API name    : saveObjectToDB
     --  Type        : Public
     --  Function    : This function navigates the DOM Tree and saves the
     --                object and its children in IES_META_OBJECTS table.
     --                Also the properties and relationships are saved into the
     --                appropriate tables
     -- **********************************************************************


     FUNCTION saveObjectToDB(element IN xmldom.DOMElement, rootObjId IN NUMBER, objOrder IN NUMBER) return NUMBER IS
        objId        NUMBER := -1; /* for the parent, rootObjId is -1 */
        name         VARCHAR2(256);
        objUID       VARCHAR2(256);

        relationship VARCHAR2(256);
        e            xmldom.DOMElement;
        n            xmldom.DOMNode;
     BEGIN
        relationship := xmldom.getAttribute(element, 'NAME');  /* It does not exist for parent */

        /* The first if check is for child elements which are CCTPropertyList/CCTPropertyMapList OR
           ChildObject, the next line starts with <JavaBean .. > which is parsed */

        if (xmldom.getTagName(element) = 'Property' OR xmldom.getTagName(element) = 'ChildObject') then
           n :=  xmldom.makeNode(element);
           e :=  xmldom.makeElement(xmldom.getFirstChild(n));
        else
           e :=  element;
        end if;

        if NOT (xmldom.isNull(e)) then
           name     := IES_META_DATA_UTIL.getProperty(e, 'name');
           objUID   := IES_META_DATA_UTIL.getProperty(e, 'UID');

           if NOT (existsObject(objUID)) then
              objId := IES_META_DATA_INSERTER.insertMetaObject(e); /* If object does not exist, insert record */
           else
              objId := IES_META_DATA_UPDATER.updateMetaObject(e);  /* Otherwise update existing record */
           end if;

           saveMetaRelationships(rootObjId, objId, relationship, objOrder);  /* Save object relationships */
           saveChildObjectsToDB(e, objId);                                   /* Save Child objects */
        end if;
        return objId;
     END saveObjectToDB;

     -- **********************************************************************
     --  API name    : getTemporaryCLOB
     --  Type        : Public
     --  Function    : This function called from Author and is used to return
     --                a CLOB type.  CLOB used to pass XML Document from Author.
     -- **********************************************************************

     FUNCTION getTemporaryCLOB return CLOB IS
        xml_clob CLOB;
     BEGIN
        DBMS_LOB.CreateTemporary(xml_clob, TRUE, DBMS_LOB.CALL);
        return xml_clob;
     END getTemporaryCLOB;

     -- **********************************************************************
     --  API name    : writeMetaDataObject
     --  Type        : Public
     --  Function    : This procedure called from Author to save the object and
     --                children meta objects.  CLOB contains the xml document.
     -- **********************************************************************

     PROCEDURE writeMetaDataObject(obj IN Clob) IS
        objId   NUMBER := -1;
        parser  xmlparser.parser;
        doc     xmldom.DOMDocument;
        element xmlDom.DOMElement;
     BEGIN
        parser := xmlparser.newParser;

        xmlparser.setValidationMode(parser, FALSE);
        xmlparser.showWarnings(parser, TRUE);
        xmlparser.parseClob(parser, obj);

        doc := xmlparser.getDocument(parser);
        element := xmldom.getDocumentElement(doc);

        objId := saveObjectToDB(element, -1, null);
        writeLibraryRecord(objId);
     END writeMetaDataObject;

     -- **********************************************************************
     --  API name    : writeMetaDataObjectDebug
     --  Type        : Public
     --  Function    : Debug procedure similar to above, used for debugging in
     --                pl/sql where VARCHAR xml doc can be passed as an argument
     -- **********************************************************************

     PROCEDURE writeMetaDataObjectDebug(obj IN VARCHAR2) IS
        objId   NUMBER := -1;
        parser  xmlparser.parser;
        doc     xmldom.DOMDocument;
        element xmlDom.DOMElement;
     BEGIN
        parser := xmlparser.newParser;

        xmlparser.setValidationMode(parser, FALSE);
        xmlparser.showWarnings(parser, TRUE);
        xmlparser.parseBuffer(parser, obj);

        doc := xmlparser.getDocument(parser);
        element := xmldom.getDocumentElement(doc);

        objId := saveObjectToDB(element, -1, null);
        writeLibraryRecord(objId);
     END writeMetaDataObjectDebug;

     -- **********************************************************************
     --  API name    : getMetaDataObject
     --  Type        : Public
     --  Function    : Function returning object as XMLDocument for a given
     --                objectId
     -- **********************************************************************

     FUNCTION  getMetaDataObject(objectId IN NUMBER) return CLOB IS
     BEGIN
        RETURN IES_META_DATA_SOURCE.getObjectAsXML(objectId);
     END getMetaDataObject;
END IES_META_DATA_PKG;

/
