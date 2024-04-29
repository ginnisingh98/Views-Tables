--------------------------------------------------------
--  DDL for Package Body IES_META_DATA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_META_DATA_UTIL" AS
     /* $Header: iesmdutb.pls 115.2 2003/01/06 20:41:17 appldev noship $ */

    -- **********************************************************************
    --  API name    : getObjectTypeId
    --  Type        : Private
    --  Function    : This Function returns the object Type id given the object
    --                type.
    -- **********************************************************************

    FUNCTION getObjectTypeId(x_name IN VARCHAR2) return NUMBER IS
       TYPE   obj_type IS REF CURSOR;
       obj    obj_type;

       typeId NUMBER := -1;
    BEGIN
      OPEN obj FOR
       'SELECT type_id
          FROM ies_meta_object_types
         WHERE type_name = :name' using x_name;

        FETCH obj INTO typeId;
        CLOSE obj;

        if (typeId = -1) then
            raise_application_error(-20101, 'name is missing'||x_name);
        end if;

        return typeId;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20101, sqlerrm||' Error in getting objectTypeId for ' ||x_name);
    END getObjectTypeId;

     -- **********************************************************************
     --  API name    : getRelationshipTypeId
     --  Type        : Private
     --  Function    : This function returns relationship_id for a given
     --                relationship type name
     -- **********************************************************************

     FUNCTION getRelationshipTypeId(typeName VARCHAR2) RETURN NUMBER IS
        TYPE   relId_type IS REF CURSOR;
        relid  relId_type;

        typeId NUMBER := -1;
     BEGIN
       OPEN relId  FOR
        'SELECT type_id
           FROM ies_meta_relationship_types
          WHERE type_name = :typeName' using typeName;

         FETCH relid INTO typeId;
         CLOSE relid;
         if (typeId = -1) then
             raise_application_error(-20110, 'Error in getting relationship type id for ' || typeName);
         end if;
         return typeId;
     END getRelationshipTypeId;

    -- **********************************************************************
    --  API name    : getLookupId
    --  Type        : Private
    --  Function    : This Function returns the lookupId for the given
    --                propId and property name
    -- **********************************************************************



    FUNCTION  getLookupId(propId IN NUMBER, key IN VARCHAR2) return NUMBER IS
       TYPE   lookup_type IS REF CURSOR;
       lookup_x lookup_type;

       lookupId NUMBER := -1;
    BEGIN
       OPEN lookup_x FOR
       'SELECT a.prop_lookup_id
          FROM IES_META_PROPERTY_LOOKUPS a
         WHERE a.property_id = :propId
           AND a.lookup_key = :key' using propId, key;

        FETCH lookup_x INTO lookupId;
        CLOSE lookup_x;

        return lookupId;
    exception when no_data_found then return -1;
    END;


    -- **********************************************************************
    --  API name    : getProperty
    --  Type        : Private
    --  Function    : This Function navigates the XML tree and finds out the
    --                value of the given key in the tree.
    -- **********************************************************************

    /* '<JavaBean CLASS="JavaCommand"> Sample xml doc used for saving metadata object
          <Properties>
            <Property NAME="command" ><![CDATA[myApp.CustomJavaClass::isValid]]></Property>
            <Property NAME="name" ><![CDATA[firstCmd]]></Property>
            <Property NAME="propertyMapIndex"><![CDATA[11]]></Property>
            <CCTPropertyList NAME="parameters">
               <Property NAME="parameters">
                 <JavaBean CLASS="Command$CommandParameter">
                  <Properties>
		     <Property NAME="paramType" ><![CDATA[class java.lang.String]]></Property>
		     <Property NAME="name" ><![CDATA[Untitled]]></Property>
		     <Property NAME="UID" ><![CDATA[1e0278:eb09c9e0e1:-7fc9]]></Property>
		     <Property NAME="paramVal" ><![CDATA[hello]]></Property>
		     <Property NAME="paramName" ><![CDATA[param1]]></Property>
                  </Properties>
                 </JavaBean>
               </Property>
             </CCTPropertyList>
             <Property NAME="UID" ><![CDATA[1e0278:eb09c9e0e1:-7fc8]]></Property>
           </Properties>
         </JavaBean>'; */

    FUNCTION getProperty(element IN xmldom.DOMElement, key IN VARCHAR2) return VARCHAR2 IS
       nl  xmldom.DOMNodeList;
       len number;
       n   xmldom.DOMNode;
       dummyElem xmldom.DOMElement;
       child xmldom.DOMNode;
    BEGIN
       nl  := xmldom.getChildNodes(xmldom.makeNode(element));  /* Get all childNodes for the element */
       len := xmldom.getLength(nl);

       for i in 0..len-1 loop                                      /* Iterate thru the child nodes */
          n := xmldom.item(nl, i);
          dummyElem := xmldom.makeElement(n);

          if (xmldom.getTagName(dummyElem) = 'Properties') then    /* Still inspect the children of Properties */
 	      return getProperty(dummyElem, key);
 	  elsif (xmldom.getAttribute(dummyElem,'NAME') = key) then /* if key matches value of NAME attr */
              child := xmldom.getFirstChild(n);                    /* this is how the node is retrieved for the NAME key */
              if NOT (xmldom.isNull(child)) then
                 return xmldom.getNodeValue(child);
              else
                 return NULL;
              end if;
 	  end if;
        end loop;
        return NULL;                                                /* No match found */
    END getProperty;


END IES_META_DATA_UTIL;

/
