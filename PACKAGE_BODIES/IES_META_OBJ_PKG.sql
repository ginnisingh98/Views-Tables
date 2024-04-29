--------------------------------------------------------
--  DDL for Package Body IES_META_OBJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_META_OBJ_PKG" as
/* $Header: iesmbjb.pls 120.1 2005/09/02 13:54:14 appldev ship $ */

 --
  --   getObjectTypeId  )
  --   Get Object Type Id for a given object Type
  --
  function getObjectTypeId (
    x_object_type in varchar2
  ) return number is
    typeId NUMBER;
  begin
    execute immediate
    'select TYPE_ID
      from IES_META_OBJECT_TYPES
     where TYPE_NAME = :type' into typeId using x_object_type;

    return typeId;
  end getObjectTypeId;

  --
  -- InsertMetaObject  )
  -- Add a new record into IES_META_OBJECTS. This is only called after checking
  -- there is no such object exists in UploadMetaObject().
  --
  procedure InsertMetaObject (
    x_object_uid                   in varchar2,
    x_object_name                  in varchar2,
    x_object_type                  in varchar2,
    x_user_id                      in number,
    x_date                         in date
  ) is
    typeId NUMBER;
    insertStmt varchar2(2000);
    seqval number;
  begin
    typeId := getObjectTypeId(x_object_type);

    execute immediate 'select IES_META_OBJECTS_S.NEXTVAL from dual' into seqval;

    insertStmt := 'insert into IES_META_OBJECTS (
      OBJECT_ID,
      OBJECT_UID,
      NAME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      TYPE_ID)
    values (
      :seq,
      :1,
      :2,
      :3,
      :4,
      :5,
      :6,
      :7,
      :8)';

    execute immediate insertStmt using seqval,
      x_object_uid,
      x_object_name,
      x_user_id,
      x_date,
      x_date,
      x_user_id,
      120,
      typeId;
  end InsertMetaObject;

  --
  --   getObjectId  )
  --
  function getObjectId (
    x_object_uid     in varchar2
  ) return number is
    objectId NUMBER;
  begin
    select OBJECT_ID
      into objectId
      from IES_META_OBJECTS
     where OBJECT_UID = x_object_uid
          and rownum < 2; -- see comments #2 above for details

    return objectId;
    exception when no_data_found then
      return -1;
  end getObjectId;

  function getPropValCount(
     x_object_uid in varchar2,
     x_prop_name  in varchar2) return number is
     propValCount number := 0;
  begin
     select count(B.PROPVAL_ID)
	   into propValCount
      from IES_META_OBJECTS A, IES_META_OBJECT_PROPVALS B,
           IES_META_PROPERTY_VALUES C,
           IES_META_PROPERTIES D
    where A.OBJECT_UID =  X_OBJECT_UID
      and A.OBJECT_ID  = B.OBJECT_ID
      and C.PROPERTY_ID = D.PROPERTY_ID
      and b.PROPVAL_ID = C.PROPVAL_ID
      AND D.NAME = x_prop_name;

     return propValCount;
  end getPropValCount;

  procedure deletePropVals(x_propval_id in number,
                           x_prop_name in varchar2) IS
    deleteStmt varchar2(2000);
  begin
    deleteStmt := 'delete from IES_META_PROPERTY_VALUES
         where propval_id = :1
        and property_id IN (select property_id
			      from IES_META_PROPERTIES
		             where NAME = :2)';
    execute immediate deleteStmt using 	x_propval_id, x_prop_name;
  end;

  procedure deleteObjectPropVals(x_object_uid in varchar2,
                                 x_prop_name in varchar2) IS
	TYPE   obj_prop_val_type  IS REF CURSOR;
	propval obj_prop_val_type;

	propValId  NUMBER;
  BEGIN
    OPEN propval FOR
    'select B.PROPVAL_ID
      from IES_META_OBJECTS A, IES_META_OBJECT_PROPVALS B,
           IES_META_PROPERTY_VALUES C,
           IES_META_PROPERTIES D
    where A.OBJECT_UID =  :1
      and A.OBJECT_ID  = B.OBJECT_ID
      and C.PROPERTY_ID = D.PROPERTY_ID
      and b.PROPVAL_ID = C.PROPVAL_ID
      AND D.NAME = :2' using x_object_uid, x_prop_name;

	 LOOP
	    FETCH propval INTO propValId;
	    EXIT WHEN propval%NOTFOUND;

	    deletePropVals(propValId, x_prop_name);
	    execute immediate 'delete from IES_META_OBJECT_PROPVALS where propval_id = :id' using propValId;
	 END LOOP;
    CLOSE propval;
  END deleteObjectPropVals;
    --
    -- UpdateMetaObject  )
    --   Update record in IES_META_OBJECTS. This is only called after checking
    --   that the object exists in UploadMetaObject().
    --
    procedure UpdateMetaObject (
      x_object_uid                   in varchar2,
      x_object_name                  in varchar2,
      x_object_type                  in varchar2,
      x_user_id                      in number,
      x_date                         in date
    ) is
      typeId NUMBER;
      updateStmt varchar2(2000);
    begin
      typeId := getObjectTypeId(x_object_type);

      updateStmt := 'update IES_META_OBJECTS set
        NAME = :name,
        TYPE_ID = :id,
        LAST_UPDATE_DATE = :updateDate,
        LAST_UPDATED_BY = :last_updated_by
      where OBJECT_UID = :objUid';

      execute immediate updateStmt using x_object_name, typeId, x_date, x_user_id, x_object_uid;

  end UpdateMetaObject;


  --
  --   getObjectTypeId  )
  --   Get Object Type Id for a given object Type
  --
  function metaObjectExists (
    x_object_uid in varchar2
  ) return boolean is
    objectId number := -1;
  begin
    objectId := getObjectId(x_object_uid);
    return (objectId <> -1);
  end metaObjectExists;



  --
  --   UploadMetaObject(PUBLIC))
  --   Public procedure for iesmobj.lct to call when uploading meta objects using
  --   using iesmobj.lct. It calls InsertMetaObject() when needed.
  --
  procedure UploadMetaObject (
    x_object_uid                   in varchar2,
    x_object_name                  in varchar2,
    x_object_type                  in varchar2,
    x_user_id                      in varchar2,
    x_last_update_date             in varchar2,
    x_custom_mode                  in varchar2
  ) is
    f_luby number;
    f_ludate date;
    db_luby number;
    db_ludate date;

    CURSOR metaObj_curs IS
     select last_updated_by, last_update_date
         from ies_meta_objects
	   where object_uid = x_object_uid
	     and rownum < 2;
  begin

    if (x_user_id = 'SEED') then
        f_luby := 1;
    else
        f_luby := 120;
    end if;

    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

    open metaObj_curs;
    fetch metaObj_curs into db_luby, db_ludate;

    if (metaObj_curs%notfound) then
         insertMetaObject(x_object_uid,
		         x_object_name,
		         x_object_type,
		         f_luby,
		         f_ludate);
    else
        if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
	                                   db_ludate, x_custom_mode)) then
     	   updateMetaObject(x_object_uid,
        	     x_object_name,
		         x_object_type,
		         f_luby,
		         f_ludate);
	    end if;
    end if;
  end UploadMetaObject;

  --+++++++++++ End of Upload Meta Object procedure +++++++++++++++++++++--



  --
  -- InsertMetaLibrary  )
  --   Add a new record into IES_META_LIBRARY. This is only called after checking
  --   there is no such object exists in UploadMetaLibrary().
  --
  procedure InsertMetaLibrary (
    x_object_uid                   in varchar2,
    x_user_id                      in number,
    x_date                         in date
  ) is
    objId NUMBER;
    seqval number;
    insertStmt varchar2(2000);
  begin
    objId := getObjectId(x_object_uid);

    execute immediate 'select IES_META_LIBRARY_S.NEXTVAL from dual' into seqval;

    insertStmt := 'insert into IES_META_LIBRARY (
      LIBOBJ_ID,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_ID)
    values (
      :seq,
      :1,
      :2,
      :3,
      :4,
      :5,
      :6)';
    execute immediate insertStmt using seqval, x_user_id, x_date, x_date, x_user_id, 120, objId;
  end InsertMetaLibrary;

  --
  --   UploadMetaLibrary(PUBLIC))
  --   Public procedure for iesmobj.lct to call when uploading meta
  --   library using iesmobj.lct. It calls InsertMetaLibrary() when needed.
  --

  procedure UploadMetaLibrary (
    x_object_uid                   in varchar2,
    x_object_name                  in varchar2,
    x_user_id                      in varchar2,
    x_last_update_date             in varchar2
  ) is
    f_luby number;
    f_ludate date;
    libobj_id number;

    CURSOR metalib_curs IS
    SELECT libobj_id
      FROM ies_meta_library
     WHERE object_id = (select OBJECT_ID
                          from IES_META_OBJECTS
                         where OBJECT_UID = x_object_uid
                           and rownum < 2);
  begin

    if (x_user_id = 'SEED') then
        f_luby := 1;
    else
        f_luby := 120;
    end if;

    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);


    open metalib_curs;
    fetch metalib_curs into libobj_id;

    if (metalib_curs%notfound) then
       insertMetaLibrary(x_object_uid,
                         f_luby,
                         f_ludate);
    end if;

  end UploadMetaLibrary;


  --+++++++++++ End of Upload Meta Library procedure +++++++++++++++++++++--

  function getPropertyValueId (
    x_object_uid in varchar2,
    x_prop_name  in varchar2
    )
    return number is
      propValId number;
      propValCount number;
  begin
    propValCount := getPropValCount(x_object_uid, x_prop_name);
    if (propValCount > 1) then
        deleteObjectPropVals(x_object_uid, x_prop_name);
    end if;

    select B.PROPVAL_ID
      into propValId
      from IES_META_OBJECTS A, IES_META_OBJECT_PROPVALS B,
           IES_META_PROPERTY_VALUES C,
           IES_META_PROPERTIES D
    where A.OBJECT_UID =  X_OBJECT_UID
      and A.OBJECT_ID  = B.OBJECT_ID
      and C.PROPERTY_ID = D.PROPERTY_ID
      and b.PROPVAL_ID = C.PROPVAL_ID
      AND D.NAME = x_prop_name;

    return propValId;
    exception when no_data_found then
      return -1;
  end getPropertyValueId;

  function getLookupId (
    x_prop_id in number,
    x_lookup_key  in number
    )
    return number is
      lookupId number;
  begin
    select PROP_LOOKUP_ID
      into lookupId
      from IES_META_PROPERTY_LOOKUPS
     where PROPERTY_ID = x_prop_id
       and LOOKUP_KEY = x_lookup_key;

     return lookupId;
  end;

  function getPropertyId (
    x_object_uid in varchar2,
    x_prop_name  in varchar2
    )
    return number is
      propId number;
  begin
    select A.PROPERTY_ID
      into propid
      from IES_META_OBJ_TYPE_PROPERTIES A,
           IES_META_PROPERTIES B
     where A.PROPERTY_ID = B.PROPERTY_ID
       and B.NAME = X_PROP_NAME
       and A.OBJTYPE_ID IN (select TYPE_ID
                              from IES_META_OBJECT_TYPES
                           connect by prior PARENT_ID = TYPE_ID
                             start with TYPE_ID = (select TYPE_ID
                                                     from IES_META_OBJECTS c
                                                    where C.OBJECT_UID = X_OBJECT_UID));
    return propId;
  end getPropertyId;

  procedure updateMetaPropertyValues (
    x_object_uid                   in varchar2,
    x_prop_name                    in varchar2,
    x_prop_value                   in varchar2,
    x_lookup_key                   in number,
    x_user_id                      in number,
    x_date                         in date)
  is
     propValId number;
     propId   number;
     lookupId number;
  begin
     propValId := getPropertyValueId(x_object_uid,
                                     x_prop_name);
     propId := getPropertyId(x_object_uid,
                             x_prop_name);
     if (x_lookup_key IS NOT NULL) then
         lookupId  := getLookupId(propId, x_lookup_key);
     end if;

     execute immediate 'update IES_META_PROPERTY_VALUES set
       LAST_UPDATE_DATE = :1,
       LAST_UPDATED_BY = :2,
       STRING_VAL = :3,
       LOOKUP_ID = :4
     where PROPVAL_ID = :5' using x_date, x_user_id, x_prop_value, lookupId, propValId;
  end updateMetaPropertyValues;

  procedure insertMetaObjPropValues (
     x_object_uid                   in varchar2,
     x_propValId                    in number,
     x_user_id                      in number,
     x_date                         in date)
  is
     objId number;
     seqVal number;
     insertStmt varchar2(2000);
  begin
     objId := getObjectId(x_object_uid);

     execute immediate 'select IES_META_OBJECT_PROPVALS_S.NEXTVAL from dual' into seqVal;

     insertStmt := 'insert into IES_META_OBJECT_PROPVALS(
       OBJPROPVAL_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       PROPVAL_ID,
       OBJECT_ID)
     values (
       :1,
       :2,
       :3,
       :4,
       :5,
       :6,
       :7,
       :8)';
     execute immediate insertStmt using seqval, x_date, x_user_id,  x_date, x_user_id, 120, x_propValId, objId;
  end insertMetaObjPropValues;

  procedure insertMetaPropertyValues (
     x_object_uid                   in varchar2,
     x_prop_name                    in varchar2,
     x_prop_value                   in varchar2,
     x_lookup_key                   in number,
     x_user_id                      in number,
     x_date                         in date)
  is
     propId number;
     propValId number;
     lookupId number;

     seqval number;
     insertStmt varchar2(2000);
  begin
     propId := getPropertyId(x_object_uid,
                             x_prop_name);
     if (x_lookup_key IS NOT NULL) then
         lookupId  := getLookupId(propId, x_lookup_key);
     end if;

     execute immediate 'select IES_META_PROPERTY_VALUES_S.NEXTVAL from dual' into seqval;

     insertStmt := 'insert into IES_META_PROPERTY_VALUES (
       PROPVAL_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       PROPERTY_ID,
       STRING_VAL,
       LOOKUP_ID)
     values (
       :1,
       :2,
       :3,
       :4,
       :5,
       :6,
       :7,
       :8,
       :9) returning propval_id INTO :10';

     execute immediate insertStmt using seqval, x_date, x_user_id, x_date, x_user_id, 120, propId, x_prop_value, lookupId returning into propValId ;
     insertMetaObjPropValues(x_object_uid, propValId, x_user_id, x_date);
  end insertMetaPropertyValues;

  procedure UploadMetaPropValues(
    x_object_uid                   in varchar2,
    x_prop_name                    in varchar2,
    x_prop_value                   in varchar2,
    x_lookup_key                   in number,
    x_user_id                      in varchar2,
    x_last_update_date             in varchar2,
    x_custom_mode                  in varchar2)
  is
    f_luby number;
    f_ludate date;
    db_luby number;
    db_ludate date;


    CURSOR propvals_curs IS
     select b.last_updated_by, b.last_update_date
      from IES_META_OBJECTS A, IES_META_OBJECT_PROPVALS B,
           IES_META_PROPERTY_VALUES C,
           IES_META_PROPERTIES D
    where A.OBJECT_UID =  X_OBJECT_UID
      and A.OBJECT_ID  = B.OBJECT_ID
      and C.PROPERTY_ID = D.PROPERTY_ID
      and b.PROPVAL_ID = C.PROPVAL_ID
      AND D.NAME = x_prop_name;
  begin
    if (x_user_id = 'SEED') then
        f_luby := 1;
    else
        f_luby := 120;
    end if;

    f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

    open propvals_curs;
    fetch propvals_curs into db_luby, db_ludate;

    if (propvals_curs%notfound) then
        insertMetaPropertyValues(x_object_uid,
                             x_prop_name,
                             x_prop_value,
                             x_lookup_key,
                             f_luby,
                             f_ludate);
    else
        if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
	                                   db_ludate, x_custom_mode)) then
            updateMetaPropertyValues(x_object_uid,
                                x_prop_name,
                                x_prop_value,
                                x_lookup_key,
                                f_luby,
                                f_ludate);
        end if;

    end if;
  end;

  --*********** End of Upload Meta Prop Values Procedure ************

  function getRelationshipId (
      x_prim_obj_uid                 in varchar2,
      x_sec_obj_uid                  in varchar2,
      x_type_name                    in varchar2
  )  return number is
      objRelId number := -1;
  begin
    select OBJREL_ID
      into objRelId
      from IES_META_OBJ_RELATIONSHIPS C,
           IES_META_RELATIONSHIP_TYPES D
     where PRIMARY_OBJ_ID = (select OBJECT_ID
                                from IES_META_OBJECTS
                               where OBJECT_UID = x_prim_obj_uid
                                 and rownum < 2)
       and SECONDARY_OBJ_ID = (select OBJECT_ID
                                from IES_META_OBJECTS
                               where OBJECT_UID = x_sec_obj_uid
                                 and rownum < 2)
       and C.TYPE_ID = D.TYPE_ID
	  and D.TYPE_NAME = x_type_name;


    return objRelId;
    exception when no_data_found then
      return -1;
  end getRelationshipId;

 function metaObjRelationshipExists (
    x_prim_obj_uid                 in varchar2,
    x_sec_obj_uid                  in varchar2,
    x_type_name                    in varchar2
 )  return boolean is
      objRelId number := -1;
 begin
    objRelId := getRelationshipId(x_prim_obj_uid,
                                  x_sec_obj_uid,
                                  x_type_name);

    return (objRelId <> -1);
  end metaObjRelationshipExists;

  function getRelationshipTypeId (
     x_type_name  in varchar2
   ) return number is
       typeId number := -1;
   begin
     select TYPE_ID
       into typeId
       from IES_META_RELATIONSHIP_TYPES
      where TYPE_NAME = x_type_name;

     return typeId;
  end getRelationshipTypeId;



  procedure updateMetaObjRelationships (
    x_prim_obj_uid                 in varchar2,
    x_sec_obj_uid                  in varchar2,
    x_type_name                    in varchar2,
    x_obj_order                       in number,
    x_user_id                      in number,
    x_date                         in date
  ) is
     typeId number;
     relId  number;
  begin
     typeId := getRelationshipTypeId(x_type_name);
     relId  := getRelationshipId(x_prim_obj_uid,
                                 x_sec_obj_uid,
                                 x_type_name);

     execute immediate 'update IES_META_OBJ_RELATIONSHIPS set
       LAST_UPDATE_DATE = :1,
       LAST_UPDATED_BY = :2,
       DELETED_STATUS = :3,
       TYPE_ID = :4,
       OBJ_ORDER = :5
     where OBJREL_ID =  :6' using x_date, x_user_id, 0, typeId, x_obj_order, relId;
  end updateMetaObjRelationships;

  procedure insertMetaObjRelationships (
    x_prim_obj_uid                 in varchar2,
    x_sec_obj_uid                  in varchar2,
    x_type_name                    in varchar2,
    x_obj_order                       in number,
    x_user_id                      in number,
    x_date                         in date
  ) is
     typeId number;
     primObjId number;
     secObjId  number;

     seqval number;
     insertStmt varchar2(2000);
  begin
     typeId := getRelationshipTypeId(x_type_name);
     primObjId := getObjectId(x_prim_obj_uid);
     secObjId := getObjectId(x_sec_obj_uid);

     execute immediate 'select IES_META_OBJ_RELATIONSHIPS_S.NEXTVAL from dual' into seqval;

     insertStmt := 'insert into IES_META_OBJ_RELATIONSHIPS (
       OBJREL_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       TYPE_ID,
       PRIMARY_OBJ_ID,
       SECONDARY_OBJ_ID,
       OBJ_ORDER,
       DELETED_STATUS)
     values (
       :1,
       :2,
       :3,
       :4,
       :5,
       :6,
       :7,
       :8,
       :9,
       :10,
       :11)';
     execute immediate insertStmt using seqval, x_date, x_user_id, x_date, x_user_id, 120, typeId, primObjId, secObjId, x_obj_order, 0;
  end insertMetaObjRelationships;


  procedure UploadMetaRelationships (
    x_prim_obj_uid                 in varchar2,
    x_sec_obj_uid                  in varchar2,
    x_type_name                    in varchar2,
    x_obj_order                       in number,
    x_user_id                      in varchar2,
    x_last_update_date             in varchar2,
    x_custom_mode                  in varchar2
  )
  IS
    objRelId number;
    f_luby number;
    f_ludate date;
    db_luby number;
    db_ludate date;

    CURSOR rels_curs IS
    select c.last_updated_by, c.last_update_date
      from IES_META_OBJ_RELATIONSHIPS C,
           IES_META_RELATIONSHIP_TYPES D
     where PRIMARY_OBJ_ID = (select OBJECT_ID
                                from IES_META_OBJECTS
                               where OBJECT_UID = x_prim_obj_uid
                                 and rownum < 2)
       and SECONDARY_OBJ_ID = (select OBJECT_ID
                                from IES_META_OBJECTS
                               where OBJECT_UID = x_sec_obj_uid
                                 and rownum < 2)
       and C.TYPE_ID = D.TYPE_ID
	  and D.TYPE_NAME = x_type_name;
    begin
      if (x_user_id = 'SEED') then
        f_luby := 1;
      else
        f_luby := 120;
      end if;

      f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

      open rels_curs;
      fetch rels_curs into db_luby, db_ludate;

      if (rels_curs%notfound) then
         insertMetaObjRelationships(x_prim_obj_uid,
                                  x_sec_obj_uid,
                                  x_type_name,
                                  x_obj_order,
                                  f_luby,
                                  f_ludate);
      else
         if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
	                                   db_ludate, x_custom_mode)) then
            updateMetaObjRelationships(x_prim_obj_uid,
                                  x_sec_obj_uid,
                                  x_type_name,
                                  x_obj_order,
                                  f_luby,
                                  f_ludate);
            end if;

      end if;
  end UploadMetaRelationships;

  --*********** End of Upload Meta Obj Relationships procedure *******

  procedure UploadMetaObjRelationships (
    x_object_uid                 in varchar2
  ) is
    begin
       null; -- do nothing.. R12 change.
    end UploadMetaObjRelationships;

  --*********** End of Upload Meta Relationship procedure *******
end IES_META_OBJ_PKG;

/
