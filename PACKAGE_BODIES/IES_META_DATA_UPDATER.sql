--------------------------------------------------------
--  DDL for Package Body IES_META_DATA_UPDATER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_META_DATA_UPDATER" AS
   /* $Header: iesmdupb.pls 115.3 2003/06/06 20:16:26 prkotha noship $ */



    -- **********************************************************************
    --  API name    : getPropertiesElement
    --  Type        : Private
    --  Function    : This Function returns the xml element starting after
    --                <Properties..    tag
    -- **********************************************************************

    FUNCTION getPropertiesElement(element IN xmldom.DOMElement) RETURN xmldom.DOMElement IS
       nl  xmldom.DOMNodeList;
       len NUMBER;
       n   xmldom.DOMNode;
       e   xmldom.DOMElement;
       retElement xmldom.DOMElement;
    BEGIN
       n  := xmldom.getFirstChild(xmldom.makeNode(element));
       e  := xmldom.makeElement(n);
       if (xmldom.getTagName(e) <> 'Properties') then
           retElement := getPropertiesElement(e);
       else
           retElement := e;
       end if;

       return retElement;
    END getPropertiesElement;

    -- **********************************************************************
    --  API name    : childExists
    --  Type        : Private
    --  Function    : This Function returns true if an object (child) exists
    --                in the XML tree for a given object_uid and type
    -- **********************************************************************

    FUNCTION childExists(element IN xmldom.DOMElement, object_uid IN VARCHAR2, typeName IN VARCHAR2) RETURN BOOLEAN IS
       nl  xmldom.DOMNodeList;
       len number;
       n   xmldom.DOMNode;
       e   xmldom.DOMElement;
       result boolean := false;
       relUID      VARCHAR2(256);
       retTypeName VARCHAR2(256);
    BEGIN
       nl := xmldom.getChildNodes(xmldom.makeNode(element));
       len := xmldom.getLength(nl);

       for i in 0..len-1 loop
          n := xmldom.item(nl, i);
          e := xmldom.makeElement(n);

          if (xmldom.getTagName(e) = 'Properties') then
 	      result  := childExists(e, object_uid, typeName);
 	  end if;

 	  retTypeName := xmldom.getAttribute(e, 'NAME');

          if (xmldom.getTagName(e) = 'CCTPropertyList' OR xmldom.getTagName(e) = 'CCTPropertyMapList')
             AND (typeName = retTypeName) then
 	      e := getPropertiesElement(e);
 	      relUID := IES_META_DATA_UTIL.getProperty(e, 'UID');

 	      if (relUID IS NOT NULL AND relUID = object_uid) then
 	          result := true;
 	      end if;
 	  elsif (xmldom.getTagName(e) = 'ChildObject') AND (typeName = retTypeName) then
              relUID := IES_META_DATA_UTIL.getProperty(e, 'UID');

	      if (relUID IS NOT NULL AND relUID = object_uid) then
	       	 result := true;
 	      end if;
 	  end if;
       end loop;

       return result;
    END childExists;


    -- **********************************************************************
    --  API name    : deleteOldRelationships
    --  Type        : private
    --  Function    : This procedure deletes all obsolete relationship records.
    --                childExists function first checks if the record exists,
    --                if false, it deletes the record.
    -- **********************************************************************

    PROCEDURE deleteOldRelationships(element IN xmldom.DOMElement, objUID IN VARCHAR2) IS
       CURSOR getRelationships IS
          SELECT b.objrel_id, b.secondary_obj_id, a.object_uid, c.type_name
            FROM ies_meta_objects a,
                 ies_meta_obj_relationships b,
                 ies_meta_objects p,
                 ies_meta_relationship_types c
           WHERE p.object_uid = objUID
             AND a.object_id = b.secondary_obj_id
             AND p.object_id = b.primary_obj_id
             AND c.type_id =  b.type_id
             AND c.type_name <> 'self';

       sqlStmt VARCHAR2(256);
    BEGIN
       for i in getRelationships loop
          if NOT childExists(element, i.object_uid, i.type_name) then
             sqlStmt := 'DELETE FROM ies_meta_obj_relationships
                         WHERE objrel_id = :objectrel_id';
             EXECUTE IMMEDIATE sqlStmt USING i.objrel_id;
             sqlStmt := 'DELETE FROM ies_meta_obj_relationships
                         WHERE primary_obj_id = :objId
                         AND secondary_obj_id = :secObjId';
             EXECUTE IMMEDIATE sqlStmt USING i.secondary_obj_id, i.secondary_obj_id;
          end if;
       end loop;
    END deleteOldRelationships;

    -- **********************************************************************
    --  API name    : updatePropertyValues
    --  Type        : private
    --  Function    : This procedure updates the meta object prop values
    -- **********************************************************************

    PROCEDURE updatePropertyValues(element IN xmldom.DOMElement, uid IN varchar2) IS
       CURSOR getPropertiesForObject IS
         SELECT b.name, c.propval_id , b.property_id
           FROM ies_meta_objects o,
                ies_meta_object_propvals a,
                ies_meta_properties b,
                ies_meta_property_values c
          WHERE o.object_uid = uid
            AND a.propval_id = c.propval_id
            AND b.property_id = c.property_id
            AND o.object_id = a.object_id;

       val       VARCHAR2(256);
       propId    NUMBER;
       lookupId  NUMBER;
       sqlStmt   VARCHAR2(256);
    BEGIN
       for i in getPropertiesForObject loop
           val := IES_META_DATA_UTIL.getProperty(element, i.name);

           lookupId := IES_META_DATA_UTIL.getLookupId(i.property_id, val);
           if (lookupId = -1) then
               sqlStmt := 'UPDATE ies_meta_property_values
                              SET string_val = :value,
                                  last_update_date = sysdate
                            WHERE propval_id = :propvalue_id';
               EXECUTE IMMEDIATE sqlStmt USING val, i.propval_id;
           else
               sqlStmt := 'UPDATE ies_meta_property_values
                             SET lookup_id = :lookupId,
                                 last_update_date = sysdate
                           WHERE propval_id = :propvalue_id';
               EXECUTE IMMEDIATE sqlStmt USING lookupId, i.propval_id;
           end if;

       end loop;
    END updatePropertyValues;

  -- **********************************************************************
    --  API name    : insertObjPropertyValues
    --  Type        : Private
    --  Function    : This procedure inserts the property values of the object
    --                into  ies_meta_object_propvals table.
    -- **********************************************************************

    PROCEDURE insertObjPropertyValues(propval_tab IN propval_table, objUID IN VARCHAR2) IS
       propValId number;

       objPropValId number;
       sqlstmt   varchar2(2000);
       seqval number;
    BEGIN
       for i in 0..propval_tab.last loop
          propValId := propval_tab(i);

          execute immediate 'select ies_meta_object_propvals_s.nextval from dual' into seqval;
          sqlStmt :=
          'INSERT INTO ies_meta_object_propvals
          (objpropval_id,
           object_id,
           propval_id,
           created_by) SELECT :seq,
            object_id,
            :propValId,
            1 from ies_meta_objects where object_uid = :objuid';

          execute immediate sqlStmt using  seqval, propValId, objUID;
       end loop;
    END insertObjPropertyValues;

    -- **********************************************************************
    --  API name    : insertNewProperties
    --  Type        : Private
    --  Function    : This procedure inserts the properties into
    --                ies_meta_property_values table.  The inserted propval_ids
    --                are stored in a pl/sql table and all the propval_ids are
    --                later inserted into ies_meta_object_propvals table.  Filter
    --                records which already have been inserted.
    -- **********************************************************************


    PROCEDURE insertNewProperties(element IN xmldom.DOMElement, objUID IN VARCHAR2) IS
       type  props_type IS REF CURSOR;
       props props_type;

       val       VARCHAR2(256);
       propId    NUMBER;
       propName  VARCHAR2(256);
       lookupId  NUMBER;

       propval_tab propval_table;
       propvalue_id number;
       counter   NUMBER := 0;
       sqlStmt   varchar2(2000);
    BEGIN

    OPEN props FOR
    'SELECT b.name, a.property_id
      FROM ies_meta_obj_type_properties a,
           ies_meta_properties b
     WHERE a.property_id = b.property_id
       AND a.objtype_id IN (SELECT type_id
                           FROM ies_meta_object_types
                           CONNECT BY PRIOR parent_id = type_id
                           START WITH type_id IN (SELECT type_id
                                                    FROM ies_meta_objects
                                                   WHERE object_uid = :aUID))
      AND b.property_id NOT IN (SELECT b.property_id
               FROM ies_meta_objects o,
                    ies_meta_object_propvals a,
                    ies_meta_properties b,
                    ies_meta_property_values c
              WHERE o.object_uid = :bUID
                AND a.propval_id = c.propval_id
                AND b.property_id = c.property_id
            AND o.object_id = a.object_id)' USING objUID, objUID;

          LOOP
	     FETCH props INTO propName, propId;
	     EXIT WHEN props%NOTFOUND;

             val := IES_META_DATA_UTIL.getProperty(element, propName);

             lookupId := IES_META_DATA_UTIL.getLookupId(propId, val);
             select ies_meta_property_values_s.nextval into propValue_id from dual;

             if (lookupId = -1) then
                sqlStmt := 'INSERT INTO ies_meta_property_values (propval_id,
                                                     property_id,
                                                     string_val,
                                                     created_by)
                                             VALUES (:id,
                                                     :property_id,
                                                     :val,
                                                     1 )';

                execute immediate sqlStmt using propvalue_id, propId, val;
                propval_tab(counter) := propvalue_id;
             else
                sqlStmt := 'INSERT INTO ies_meta_property_values (propval_id,
	                                            property_id,
	                                            lookup_id,
	                                            created_by)
	                                     VALUES (:id,
	                                             :property_id,
	                                             :lookupId,
	                                             1 )';

              execute immediate sqlStmt using propvalue_id, propId, lookupId;
              propval_tab(counter) := propvalue_id;
           end if;
           counter := counter + 1;
       end loop;
       if (counter > 0) then
       insertObjPropertyValues(propval_tab, objUID);
       end if;
    END insertNewProperties;

    /************************ Public methods *******************************/

    -- **********************************************************************
    --  API name    : updateMetaObject
    --  Type        : public
    --  Function    : This function updates the meta object and its properties,
    --                returns object id.
    -- **********************************************************************

    FUNCTION updateMetaObject(element IN xmldom.DOMElement) return NUMBER IS
       objId        NUMBER := -1;
       objname      VARCHAR2(256);
       uid          VARCHAR2(256);
       objTypeId    NUMBER;
    BEGIN
       objname   :=  IES_META_DATA_UTIL.getProperty(element, 'name');

       if (objname is null) then
           objname := 'nullname';
       end if;

       uid       :=  IES_META_DATA_UTIL.getProperty(element, 'UID');
       objtypeId :=  IES_META_DATA_UTIL.getObjectTypeId(xmldom.getAttribute(element, 'CLASS'));
       objId     := to_number(IES_META_DATA_UTIL.getProperty(element, 'objectId'));


       execute immediate' UPDATE ies_meta_objects
          SET name             = :1,
              last_update_date = :2,
              type_id          = :3
        WHERE object_uid = :4 returning object_id INTO :5' using objname, sysdate, objTypeId, uid returning INTO objId;


       updatePropertyValues(element, uid);
       insertNewProperties(element, uid);
       deleteOldRelationships(element, uid);

       return objId;
    END updateMetaObject;







END IES_META_DATA_UPDATER;

/
