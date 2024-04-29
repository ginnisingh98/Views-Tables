--------------------------------------------------------
--  DDL for Package IES_META_OBJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_META_OBJ_PKG" AUTHID CURRENT_USER as
/* $Header: iesmbjs.pls 120.1 2005/09/02 13:54:09 appldev ship $ */

  procedure UploadMetaObject(
    x_object_uid                   in varchar2,
    x_object_name                  in varchar2,
    x_object_type                  in varchar2,
    x_user_id                      in varchar2,
    x_last_update_date             in varchar2,
    x_custom_mode                  in varchar2
  ) ;

  procedure UploadMetaLibrary(
    x_object_uid                   in varchar2,
    x_object_name                  in varchar2,
    x_user_id                      in varchar2,
    x_last_update_date             in varchar2
  );

  procedure UploadMetaPropValues(
    x_object_uid                   in varchar2,
    x_prop_name                    in varchar2,
    x_prop_value                   in varchar2,
    x_lookup_key                   in number,
    x_user_id                      in varchar2,
    x_last_update_date             in varchar2,
    x_custom_mode                  in varchar2
  );

  procedure UploadMetaObjRelationships (
    x_object_uid                 in varchar2
  );

  procedure UploadMetaRelationships (
    x_prim_obj_uid                 in varchar2,
    x_sec_obj_uid                  in varchar2,
    x_type_name                    in varchar2,
    x_obj_order                    in number,
    x_user_id                      in varchar2,
    x_last_update_date             in varchar2,
    x_custom_mode                  in varchar2
  );

end IES_META_OBJ_PKG;

 

/
