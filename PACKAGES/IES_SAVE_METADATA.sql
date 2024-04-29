--------------------------------------------------------
--  DDL for Package IES_SAVE_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_SAVE_METADATA" AUTHID CURRENT_USER AS
/* $Header: iessmets.pls 115.4 2003/01/06 20:42:00 appldev noship $ */

Procedure  insert_meta_object_types(p_obj_name IN VARCHAR2, p_parent_name IN VARCHAR2);
Procedure  insert_meta_obj_type_props(p_obj_name IN VARCHAR2, p_prop_name IN VARCHAR2);
Procedure  insert_meta_prop_lookups(p_prop_name IN VARCHAR2, p_prop_key IN NUMBER, p_prop_val IN VARCHAR2);
Procedure  insert_meta_props(p_prop_name IN VARCHAR2, p_datatype IN VARCHAR2);
Procedure  insert_meta_relationship_types(p_type_name IN VARCHAR2);
Procedure  insert_meta_relationship_types(p_type_name IN VARCHAR2, list_relationship IN NUMBER);
Procedure  insert_meta_prop_datatypes(p_datatype IN VARCHAR2);

Function   get_prop_id(p_prop_name IN VARCHAR2) return NUMBER;
Function   get_obj_id(p_obj_name IN VARCHAR2) return NUMBER;
Function   get_prop_datatype_id(p_datatype IN VARCHAR2) return NUMBER;

END; -- Package spec

 

/
