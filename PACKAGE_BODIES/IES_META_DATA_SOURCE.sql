--------------------------------------------------------
--  DDL for Package Body IES_META_DATA_SOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_META_DATA_SOURCE" AS
     /* $Header: iesmdscb.pls 115.3 2003/01/06 20:41:16 appldev noship $ */

    xml_clob    CLOB;
    xml_buffer  VARCHAR2(32000);

    /************************ Private methods *******************************/

    -- **********************************************************************
    --  API name    : convertNullString
    --  Type        : Private
    --  Function    : This function checks if the arg IS NULL and returns ''
    --                if the arg is NULL.
    -- **********************************************************************

    FUNCTION convertNullString(s VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
	IF (S IS NULL) THEN
	   RETURN '';
	ELSE
	   RETURN s;
	END IF;
    END convertNullString;

    -- **********************************************************************
    --  API name    : appendXMLClob
    --  Type        : Private
    --  Function    : This procedure appends XML Doc string to the CLOB,
    --                Buffer used to cache the string until it reaches 32K
    --                before appending to the CLOB.
    -- **********************************************************************

    PROCEDURE appendXMLClob(buffer IN VARCHAR2) IS

    BEGIN
        if (nvl(length(xml_buffer), 0) + length(buffer) <= 32000) then
           xml_buffer := xml_buffer || buffer;
        else
	   DBMS_LOB.WRITEAPPEND(xml_clob, LENGTH(xml_buffer), xml_buffer);
           xml_buffer := buffer;
        end if;

    END appendXMLClob;


    -- **********************************************************************
    --  API name    : convertObjPropertiesToXML
    --  Type        : Private
    --  Function    : This procedure queries the metadata tables and retrieves
    --                properties of the given object and appends it to the
    --                xml_clob
    -- **********************************************************************

    PROCEDURE convertObjPropertiesToXML(objId IN NUMBER) IS
       TYPE   obj_prop_type IS REF CURSOR;
       obj_prop    obj_prop_type;

       key       VARCHAR2(256);
       type_name VARCHAR2(256);
       str_value VARCHAR2(2000);
    BEGIN
       OPEN obj_prop FOR
          'SELECT a.name key,
                  NVL(b.string_val, d.lookup_key) value,
                  e.type_name
	     FROM ies_meta_properties a,
	          ies_meta_property_values b,
	          ies_meta_object_propvals c,
	          ies_meta_property_lookups d,
	          ies_meta_prop_datatypes e
	    WHERE c.object_id = :object_Id
              AND c.propval_id = b.propval_id
	      AND b.property_id = a.property_id
	      AND a.datatype_id = e.type_id
	      AND b.lookup_id = d.prop_lookup_id (+)' USING objId;

	  LOOP
	     FETCH obj_prop INTO key, str_value, type_name;
	     EXIT WHEN obj_prop%NOTFOUND;
             appendXMLClob('    <Property NAME="'|| key || '" DATATYPE="' || type_name ||'"><![CDATA['||convertNullString(str_value)||']]></Property>"'||fnd_global.local_chr(10));
          END LOOP;
        CLOSE obj_prop;
    END convertObjPropertiesToXML;


    /************************ Public methods ********************************/

    -- **********************************************************************
    --  API name    : getObjectAsXML
    --  Type        : Public
    --  Function    : This function returns CLOB object with XML Doc for the
    --                given objId
    -- **********************************************************************

    FUNCTION getObjectAsXML(objId IN NUMBER) return CLOB IS
       len number;
    BEGIN
       xml_buffer := null;
       xml_clob   := null;
       DBMS_LOB.CreateTemporary(xml_clob, TRUE, DBMS_LOB.CALL);

       convertObjectToXML(objId);
       DBMS_LOB.WRITEAPPEND(xml_clob, LENGTH(xml_buffer), xml_buffer);
       --dbms_output.put_line('length is ' || to_char(dbms_lob.getlength(xml_clob)));
       return xml_clob;
    END getObjectAsXML;

    -- **********************************************************************
    --  API name    : convertObjectToXML
    --  Type        : Public
    --  Function    : This procedure queries metadata tables for all the object
    --                properties and creates a XML Document with these props
    -- **********************************************************************

    PROCEDURE convertObjectToXML(objId IN NUMBER) IS
       TYPE   obj_type IS REF CURSOR;
       obj    obj_type;

       buffer      VARCHAR2(2000);
       objName     VARCHAR2(256);
       objType     VARCHAR2(256);
       objectId    VARCHAR2(256);
       root        VARCHAR2(256);
       uid         VARCHAR2(256);
    BEGIN
        OPEN obj FOR
           'SELECT a.object_id object_id,
                   a.name name,
                   b.type_name type_name,
                   a.object_uid obj_uid
              FROM ies_meta_objects a,
                   ies_meta_object_types b
  	     WHERE a.object_id = :obj_id
               AND a.type_id = b.type_id' using objId;


      LOOP
         FETCH obj INTO objectId, objName, objType, uid;
         EXIT WHEN obj%NOTFOUND;

      	  appendXMLClob('<JavaBean CLASS="' || objType  || '">'||fnd_global.local_chr(10));
      	  appendXMLClob('  <Properties>'||fnd_global.local_chr(10));
  	  appendXMLClob('    <Property NAME="name" DATATYPE="String"><![CDATA['||objName||']]></Property>'||fnd_global.local_chr(10));
          appendXMLClob('    <Property NAME="objectId" DATATYPE="Integer"><![CDATA['||objectId||']]></Property>'||fnd_global.local_chr(10));
          appendXMLClob('    <Property NAME="UID" DATATYPE="String"><![CDATA['||uid||']]></Property>'||fnd_global.local_chr(10));
      END LOOP;
      CLOSE obj;


      IF (objectid IS NOT null) THEN
  	  convertObjPropertiesToXML(objectId);
  	  convertChildObjectsToXML(objectId);

  	  appendXMLClob('</Properties>'|| fnd_global.local_chr(10));
  	  appendXMLClob('</JavaBean>'|| fnd_global.local_chr(10));
      ELSE
          appendXMLClob('<DummyTag><Dummy></Dummy></DummyTag>');
      END IF;
    END convertObjectToXML;

    -- **********************************************************************
    --  API name    : convertChildObjectsToXML
    --  Type        : Public
    --  Function    : This procedure queries metadata tables for all the Child
    --                objects and its object properties, creates a XML Document
    --                with these props
    -- **********************************************************************

    PROCEDURE convertChildObjectsToXML(objId IN NUMBER) IS
      TYPE   child_obj_type  IS REF CURSOR;
      child_obj child_obj_type;

      secObjId  NUMBER;
      type_name VARCHAR2(256);
      relId     NUMBER;
    BEGIN
      OPEN child_obj FOR
        '  SELECT a.secondary_obj_id, c.type_name, c.list_relationship
             FROM ies_meta_obj_relationships a,
                  ies_meta_obj_relationships b,
                  ies_meta_relationship_types c
            WHERE a.deleted_status = 0
              AND a.primary_obj_id = :object_id
              AND a.primary_obj_id <> b.secondary_obj_id
              AND a.objrel_id = b.objrel_id
              AND a.type_id = c.type_id
         ORDER BY a.obj_order, a.secondary_obj_id' using objId;

       LOOP
          FETCH child_obj INTO secObjId, type_name, relId;
          EXIT WHEN child_obj%NOTFOUND;

          if (relId = 1) then
             appendXMLClob('<CCTPropertyList NAME="' || type_name || '">'|| fnd_global.local_chr(10));
	  elsif (relId = 2) then
	     appendXMLClob('<CCTPropertyMapList NAME="' || type_name || '">'|| fnd_global.local_chr(10));
	  end if;

          appendXMLClob('<Property NAME="' || type_name || '">'|| fnd_global.local_chr(10));
          convertObjectToXML(secObjid);
          appendXMLClob('</Property>'||fnd_global.local_chr(10));

          if (relId = 1) then
             appendXMLClob('</CCTPropertyList>'|| fnd_global.local_chr(10));
	  elsif (relId = 2) then
	     appendXMLClob('</CCTPropertyMapList>'|| fnd_global.local_chr(10));
	  end if;

        END LOOP;
        CLOSE child_obj;
    END convertChildObjectsToXML;

END IES_META_DATA_SOURCE;

/
