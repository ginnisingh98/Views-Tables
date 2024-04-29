--------------------------------------------------------
--  DDL for Package Body IES_META_DATA_INSERTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_META_DATA_INSERTER" AS
     /* $Header: iesmdinb.pls 115.3 2003/06/06 20:16:30 prkotha noship $ */


    -- **********************************************************************
    --  API name    : insertObjPropertyValues
    --  Type        : Private
    --  Function    : This procedure inserts the property values of the object
    --                into  ies_meta_object_propvals table.
    -- **********************************************************************

    PROCEDURE insertObjPropertyValues(propval_tab IN propval_table, objId IN NUMBER) IS
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
           created_by) VALUES
           (:seq,
            :objId,
            :propValId,
            :agent)';

          execute immediate sqlStmt using  seqval, objId, propValId, 1;
       end loop;
    END insertObjPropertyValues;

    -- **********************************************************************
    --  API name    : insertPropertyValues
    --  Type        : Private
    --  Function    : This procedure inserts the properties into
    --                ies_meta_property_values table.  The inserted propval_ids
    --                are stored in a pl/sql table and all the propval_ids are
    --                later inserted into ies_meta_object_propvals table
    -- **********************************************************************


    PROCEDURE insertPropertyValues(element IN xmldom.DOMElement, objId IN NUMBER) IS
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
	    AND a.objtype_id IN ( SELECT type_id
	                            FROM ies_meta_object_types
	 	        CONNECT BY PRIOR parent_id = type_id
	  		      START WITH type_name = :typeName)' USING xmldom.getAttribute(element, 'CLASS');

          LOOP
	     FETCH props INTO propName, propId;
	     EXIT WHEN props%NOTFOUND;

             val := IES_META_DATA_UTIL.getProperty(element, propName);

             lookupId := IES_META_DATA_UTIL.getLookupId(propId, val);
             execute immediate 'select ies_meta_property_values_s.nextval from dual' into propValue_id ;

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
       insertObjPropertyValues(propval_tab, objId);
    END insertPropertyValues;


    -- **********************************************************************
    --  API name    : insertMetaObject
    --  Type        : Public
    --  Function    : This Function inserts meta object and returns the new
    --                object_id for the inserted object.
    -- **********************************************************************

    FUNCTION insertMetaObject(element IN xmldom.DOMElement) return NUMBER IS
       objId        NUMBER := -1;
       x_name       VARCHAR2(256);
       x_uid        VARCHAR2(256);
       objTypeId    NUMBER;

       sqlStmt      varchar2(2000);
    BEGIN
       x_name   :=  IES_META_DATA_UTIL.getProperty(element, 'name');
       if (x_name is null) then
           x_name := 'nullname';
       end if;

       x_uid    :=  IES_META_DATA_UTIL.getProperty(element, 'UID');
       objtypeId := IES_META_DATA_UTIL.getObjectTypeId(xmldom.getAttribute(element, 'CLASS'));

       sqlStmt := 'INSERT INTO ies_meta_objects (object_id,
                                     name,
                                     object_uid,
                                     type_id,
                                     created_by)
                             VALUES (:id,
                                     :a_name,
                                     :a_uid,
                                     :objTypeId,
                                     1)';

       execute immediate 'select ies_meta_objects_s.nextval from dual'  into objId ;

       EXECUTE IMMEDIATE sqlStmt USING objId, x_name, x_uid, objTypeId;

       insertPropertyValues(element, objId);
       return objId;
    END insertMetaObject;



END IES_META_DATA_INSERTER;

/
