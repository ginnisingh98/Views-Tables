--------------------------------------------------------
--  DDL for Package Body IES_SAVE_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_SAVE_METADATA" AS
/* $Header: iessmetb.pls 115.6 2003/06/06 20:16:15 prkotha noship $ */

Procedure  insert_meta_object_types(p_obj_name IN VARCHAR2, p_parent_name IN VARCHAR2) IS
   parentId NUMBER := null;
begin
   if (p_parent_name IS NOT NULL) then
       parentId := get_obj_id(p_parent_name);
   end if;
   INSERT INTO IES_META_OBJECT_TYPES (type_id, type_name, parent_id, created_by)
    SELECT ies_meta_object_types_s.nextval, p_obj_name, parentId, 1
      FROM dual
     WHERE NOT EXISTS (SELECT 1
                         FROM ies_meta_object_types
                        WHERE type_name = p_obj_name);
end insert_meta_object_types;

Procedure  insert_meta_obj_type_props(p_obj_name IN VARCHAR2, p_prop_name IN VARCHAR2) IS
    objId  NUMBER;
    propId NUMBER;
begin
    objId := get_obj_id(p_obj_name);
    propId := get_prop_id(p_prop_name);

    INSERT INTO IES_META_OBJ_TYPE_PROPERTIES
      (typeprop_id, created_by, objtype_id, property_id)
      SELECT ies_meta_obj_type_properties_s.nextval, 1, objId, propId
        FROM dual
       WHERE NOT EXISTS (SELECT 1
                           FROM IES_META_OBJ_TYPE_PROPERTIES
                          WHERE objType_id = objId
                            AND property_id = propId);
end insert_meta_obj_type_props;

Procedure  insert_meta_prop_lookups(p_prop_name IN VARCHAR2, p_prop_key IN NUMBER, p_prop_val IN VARCHAR2) IS
  propId NUMBER;
begin
    propId := get_prop_id(p_prop_name);

    INSERT INTO IES_META_PROPERTY_LOOKUPS
     (prop_lookup_id, property_id, lookup_key, lookup_value, created_by)
      SELECT ies_meta_property_lookups_s.nextval, propId, p_prop_key, p_prop_val, 1
        FROM dual
       WHERE NOT EXISTS (SELECT 1
                           FROM IES_META_PROPERTY_LOOKUPS
                          WHERE lookup_key = p_prop_key
                            AND lookup_value = p_prop_val
                            AND property_id = propId);

end insert_meta_prop_lookups;

Procedure  insert_meta_props(p_prop_name IN VARCHAR2, p_datatype IN VARCHAR2) IS
   dataTypeId NUMBER;
begin
    dataTypeId := get_prop_datatype_id(p_datatype);
    INSERT INTO IES_META_PROPERTIES (property_id, name, datatype_id, created_by)
      SELECT ies_meta_properties_s.nextval, p_prop_name, datatypeId, 1
        FROM dual
       WHERE NOT EXISTS (SELECT 1
                           FROM IES_META_PROPERTIES
                          WHERE name = p_prop_name
                            AND datatype_id = datatypeId);
end insert_meta_props;

Procedure insert_meta_prop_datatypes(p_datatype IN VARCHAR2) IS
begin
     INSERT INTO IES_META_PROP_DATATYPES (type_id, type_name, created_by)
       SELECT ies_meta_prop_datatypes_s.nextval, p_datatype, 1
         FROM dual
        WHERE NOT EXISTS (SELECT 1
                            FROM IES_META_PROP_DATATYPES
                           WHERE type_name = p_datatype);
end insert_meta_prop_datatypes;

Procedure  insert_meta_relationship_types(p_type_name IN VARCHAR2) IS
begin
   insert_meta_relationship_types(p_type_name, 0);
end insert_meta_relationship_types;

Procedure  insert_meta_relationship_types(p_type_name IN VARCHAR2, list_relationship IN NUMBER) IS
begin
     INSERT INTO IES_META_RELATIONSHIP_TYPES (type_id, type_name, created_by, list_relationship)
        SELECT ies_meta_relationship_types_s.nextval, p_type_name, 1 , list_relationship
          FROM dual
         WHERE NOT EXISTS (SELECT 1
                             FROM IES_META_RELATIONSHIP_TYPES
                            WHERE type_name = p_type_name);
end insert_meta_relationship_types;

Function   get_prop_id(p_prop_name IN VARCHAR2) return NUMBER IS
   propId NUMBER;
begin
   SELECT property_id
     INTO propId
     FROM ies_meta_properties
    WHERE name = p_prop_name;

    RETURN propId;
end get_prop_id;

Function   get_obj_id(p_obj_name IN VARCHAR2) return NUMBER IS
   objId NUMBER;
begin
   SELECT type_id
     INTO objId
     FROM ies_meta_object_types
    WHERE type_name = p_obj_name;

  RETURN objId;
end get_obj_id;

Function   get_prop_datatype_id(p_datatype IN VARCHAR2) return NUMBER IS
   datatypeId NUMBER;
begin
   SELECT type_id
     INTO datatypeId
     FROM ies_meta_prop_datatypes
    WHERE type_name = p_datatype;

   RETURN datatypeId;
end get_prop_datatype_id;

END; -- Package body

/
