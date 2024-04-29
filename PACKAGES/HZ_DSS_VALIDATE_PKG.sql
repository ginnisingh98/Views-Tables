--------------------------------------------------------
--  DDL for Package HZ_DSS_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHPDSVS.pls 120.2 2005/10/30 04:22:01 appldev noship $ */

--------------------------------------------
-- return_no_of_dss_groups
--------------------------------------------


FUNCTION return_no_of_dss_groups
-- Return number of rows in hz_dss_groups
RETURN NUMBER;

--------------------------------------------
-- get_object_id_entities
--------------------------------------------


FUNCTION get_object_id_entities
-- Return object_id from hz_dss_entities, based on the given entity id
(p_entity_id NUMBER)
RETURN NUMBER;

--------------------------------------------
-- get_instance_set_id_entities
--------------------------------------------
FUNCTION get_instance_set_id_entities
-- Return instance_set_id from hz_dss_entities, based on the given entity id
(p_entity_id NUMBER)
RETURN NUMBER;

--------------------------------------------
-- get_object_id_fnd_ins_sets
--------------------------------------------

FUNCTION get_object_id_fnd_ins_sets
-- Return object_id from fnd_grants based on the passed in instance_set_id
(p_instance_set_id NUMBER)
RETURN NUMBER;

--------------------------------------------
-- exist_in_dss_groups_b
--------------------------------------------

FUNCTION exist_in_dss_groups_b
-- Return Y if the group code exists in hz_dss_groups
--        N otherwise
(p_dss_group_code VARCHAR2 )
RETURN VARCHAR2;

--------------------------------------------
-- exist_in_dss_groups_vl
--------------------------------------------

FUNCTION exist_in_dss_groups_vl
-- Return Y if the object id exists in hz_dss_groups_vl
--        N otherwise
(p_dss_group_name VARCHAR2 )
RETURN VARCHAR2;

FUNCTION exist_in_dss_groups_vl
-- Return Y if the object name exists in hz_dss_groups_vl, for a row whose
-- primary key <> passed in primary key value
-- N otherwise
(p_dss_group_name VARCHAR2, p_dss_group_code VARCHAR2 )
RETURN VARCHAR2;


--------------------------------------------
-- exist_in_hz_class_categories
--------------------------------------------

FUNCTION exist_in_hz_class_categories
-- Return Y if the class code exists in hz_class_categories
--        N otherwise
(p_class_category VARCHAR2 )
RETURN VARCHAR2;

--------------------------------------------
-- exist_in_hz_relationship_types
--------------------------------------------

FUNCTION exist_in_hz_relationship_types
-- Return Y if the class code exists in hz_relationship_types
--        N otherwise
(p_relationship_type_id NUMBER )
RETURN VARCHAR2;


--------------------------------------------
-- exist_in_dss_entities
--------------------------------------------

FUNCTION exist_in_dss_entities
-- Return Y if the assignment exists in hz_dss_entities
--        N otherwise
(p_database_object_name VARCHAR2 )
RETURN VARCHAR2;


FUNCTION exist_in_dss_entities
-- Return Y if the assignment exists in hz_dss_entities
--        N otherwise
(p_entity_id NUMBER )
RETURN VARCHAR2;



FUNCTION is_an_obj_id_in_dss_entities
-- Return Y if the passed in entity id corresponds to an object in hz_dss_entities
--        N otherwise
(p_entity_id NUMBER )
RETURN VARCHAR2;


--------------------------------------------
-- exist_in_dss_assignments
--------------------------------------------

FUNCTION exist_in_dss_assignments
-- Return Y if the assignment code exists in hz_dss_assignments
--        N otherwise
(p_assignment_id VARCHAR2 )
RETURN VARCHAR2;


--------------------------------------
 -- exist_in_ar_lookups
 --------------------------------------
FUNCTION exist_in_ar_lookups
-- Return Y if lookup_code and lookup_type are found in AR_LOOKUPS
--        N otherwise
(p_lookup_code VARCHAR2, p_lookup_type VARCHAR2 )
RETURN VARCHAR2;

--------------------------------------
 -- exist_in_ar_lookups_gl
 --------------------------------------
FUNCTION exist_in_ar_lookups_gl
-- Return Y if lookup_code and lookup_type are found in AR_LOOKUPS
--        N otherwise
(p_lookup_code VARCHAR2, p_lookup_type VARCHAR2 )
RETURN VARCHAR2;

 --------------------------------------
 -- exist_in_fnd_lookups
 --------------------------------------
FUNCTION exist_in_fnd_lookups
-- Return Y if lookup_code and lookup_type are found in FND_LOOKUP_VALUES
--        N otherwise
(p_lookup_code VARCHAR2, p_lookup_type VARCHAR2 )
RETURN VARCHAR2;

--------------------------------------------
-- exist_fnd_object_id
--------------------------------------------

FUNCTION exist_fnd_object_id
-- Return Y if the object id exists in FND
--        N otherwise
(p_object_id NUMBER )
RETURN VARCHAR2;

--------------------------------------------
-- exist_fnd_instance_set_id
--------------------------------------------


FUNCTION exist_fnd_instance_set_id
-- Return Y if the instance set id exists in FND
--        N otherwise
(p_instance_set_id NUMBER )
RETURN VARCHAR2;

--------------------------------------------
-- exist_entity_id
--------------------------------------------
 FUNCTION exist_entity_id
-- Return Y if the entity id exists in HZ_DSS_ENTITIES
--        N otherwise
(p_entity_id NUMBER )
RETURN VARCHAR2;

--------------------------------------------
-- exist_function_id
--------------------------------------------
FUNCTION exist_function_id
-- Return Y if function id exists in fnd_form_functions
--        N otherwise
(p_function_id NUMBER )
RETURN VARCHAR2;

END HZ_DSS_VALIDATE_PKG ;

 

/
