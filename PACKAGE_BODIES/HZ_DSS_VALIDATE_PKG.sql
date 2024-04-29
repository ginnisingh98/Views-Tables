--------------------------------------------------------
--  DDL for Package Body HZ_DSS_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_VALIDATE_PKG" AS
/* $Header: ARHPDSVB.pls 120.2 2005/10/30 04:21:59 appldev noship $ */


-------------------------------------------------
-- public procedures and functions
-------------------------------------------------

--------------------------------------------
-- return_no_of_dss_groups
--------------------------------------------

FUNCTION return_no_of_dss_groups
-- Return number of rows in hz_dss_groups
RETURN NUMBER
IS
CURSOR c0
IS
SELECT count (*)
  FROM hz_dss_groups_b ;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END return_no_of_dss_groups ;

--------------------------------------------
-- get_object_id_entities
--------------------------------------------
FUNCTION get_object_id_entities
-- Return object_id from hz_dss_entities, based on the given entity id
(p_entity_id NUMBER)
RETURN NUMBER
IS
CURSOR c0
IS
SELECT object_id
FROM hz_dss_entities
WHERE entity_id = p_entity_id;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_object_id_entities ;


--------------------------------------------
-- get_instance_set_id_entities
--------------------------------------------
FUNCTION get_instance_set_id_entities
-- Return instance_set_id from hz_dss_entities, based on the given entity id
(p_entity_id NUMBER)
RETURN NUMBER
IS
CURSOR c0
IS
SELECT instance_set_id
FROM hz_dss_entities
WHERE entity_id = p_entity_id;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_instance_set_id_entities ;



--------------------------------------------
-- get_object_id_fnd_ins_sets
--------------------------------------------
FUNCTION get_object_id_fnd_ins_sets
-- Return object_id from fnd_grants based on the passed in instance_set_id
(p_instance_set_id NUMBER)
RETURN NUMBER
IS
CURSOR c0
IS
SELECT object_id
FROM fnd_object_instance_sets
WHERE instance_set_id = p_instance_set_id ;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_object_id_fnd_ins_sets ;


--------------------------------------------
-- exist_in_dss_groups
--------------------------------------------

FUNCTION exist_in_dss_groups_b
-- Return Y if the group code exists in hz_dss_groups
--        N otherwise
(p_dss_group_code VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT 'Y'
  FROM hz_dss_groups_b
 WHERE dss_group_code = p_dss_group_code;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END exist_in_dss_groups_b ;

--------------------------------------------
-- exist_in_dss_groups_vl
--------------------------------------------

FUNCTION exist_in_dss_groups_vl
-- Return Y if the group name exists in hz_dss_groups_vl
--        N otherwise
(p_dss_group_name VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT 'Y'
  FROM hz_dss_groups_vl
 WHERE dss_group_name = p_dss_group_name;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END exist_in_dss_groups_vl ;


FUNCTION exist_in_dss_groups_vl
-- Return Y if the object name exists in hz_dss_groups_vl, for a row whose
-- primary key <> passed in primary key value
-- N otherwise
(p_dss_group_name VARCHAR2, p_dss_group_code VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT 'Y'
  FROM hz_dss_groups_vl
 WHERE dss_group_name = p_dss_group_name
       and dss_group_code <> p_dss_group_code ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END exist_in_dss_groups_vl ;


--------------------------------------------
-- exist_in_hz_class_categories
--------------------------------------------

FUNCTION exist_in_hz_class_categories
-- Return Y if the class code exists in hz_class_categories
--        N otherwise
(p_class_category VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT 'Y'
  FROM hz_class_categories
 WHERE class_category = p_class_category ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END exist_in_hz_class_categories ;

--------------------------------------------
-- exist_in_hz_relationship_types
--------------------------------------------

FUNCTION exist_in_hz_relationship_types
-- Return Y if the class code exists in hz_relationship_types
--        N otherwise
(p_relationship_type_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT 'Y'
  FROM hz_relationship_types
 WHERE relationship_type_id = p_relationship_type_id ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END exist_in_hz_relationship_types ;


--------------------------------------------
-- exist_in_dss_entities
--------------------------------------------

FUNCTION exist_in_dss_entities
-- Return Y if the assignment exists in hz_dss_entities
--        N otherwise
(p_database_object_name VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'y'
from fnd_objects FND , hz_dss_entities  ENT
where FND.database_object_name = p_database_object_name and
      FND.object_id = ENT.object_id and
      ENT.group_assignment_level = 'ASSIGN';
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END exist_in_dss_entities ;

--------------------------------------------
-- exist_in_dss_entities
--------------------------------------------

FUNCTION exist_in_dss_entities
-- Return Y if the assignment exists in hz_dss_entities
--        N otherwise
(p_entity_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'y'
from hz_dss_entities
where entity_id = p_entity_id ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END exist_in_dss_entities ;

--------------------------------------------
-- is_an_obj_id_in_dss_entities
--------------------------------------------

FUNCTION is_an_obj_id_in_dss_entities
-- Return Y if the passed in entity id corresponds to an object in hz_dss_entities
--        N otherwise
(p_entity_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'y'
from hz_dss_entities
where entity_id = p_entity_id
      and object_id is not null ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END is_an_obj_id_in_dss_entities ;



--------------------------------------------
-- exist_in_dss_assignments
--------------------------------------------

FUNCTION exist_in_dss_assignments
-- Return Y if the assignment code exists in hz_dss_assignments
--        N otherwise
(p_assignment_id VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
    SELECT 'Y'
    FROM hz_dss_assignments
    WHERE assignment_id = p_assignment_id ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END exist_in_dss_assignments ;


--------------------------------------
 -- exist_in_ar_lookups
 --------------------------------------
FUNCTION exist_in_ar_lookups
-- Return Y if lookup_code and lookup_type are found in AR_LOOKUPS
--        N otherwise
(p_lookup_code VARCHAR2, p_lookup_type VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from ar_lookups
where lookup_type = p_lookup_type
      and lookup_code = p_lookup_code
      and enabled_flag = 'Y' ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
 END exist_in_ar_lookups ;

--------------------------------------
 -- exist_in_ar_lookups_gl
 --------------------------------------
FUNCTION exist_in_ar_lookups_gl
-- Return Y if lookup_code and lookup_type are found in AR_LOOKUPS
--        N otherwise
(p_lookup_code VARCHAR2, p_lookup_type VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from ar_lookups
where lookup_type = p_lookup_type
      and lookup_code = p_lookup_code;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
 END exist_in_ar_lookups_gl ;

--------------------------------------
 -- exist_in_fnd_lookups
 --------------------------------------
FUNCTION exist_in_fnd_lookups
-- Return Y if lookup_code and lookup_type are found in FND_LOOKUP_VALUES
--        N otherwise
(p_lookup_code VARCHAR2, p_lookup_type VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from fnd_lookup_values
where lookup_type = p_lookup_type
      and lookup_code = p_lookup_code
      and enabled_flag = 'Y' ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
 END exist_in_fnd_lookups ;
 --------------------------------------------
-- exist_fnd_object_id
--------------------------------------------

FUNCTION exist_fnd_object_id
-- Return Y if the object id exists in FND
--        N otherwise
(p_object_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT 'Y'
  FROM fnd_objects
 WHERE object_id = p_object_id;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END exist_fnd_object_id ;


--------------------------------------------
-- exist_fnd_instance_set_id
--------------------------------------------


FUNCTION exist_fnd_instance_set_id
-- Return Y if the instance set id exists in FND
--        N otherwise
(p_instance_set_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT 'Y'
  FROM fnd_object_instance_sets
 WHERE instance_set_id = p_instance_set_id;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
 END exist_fnd_instance_set_id ;

--------------------------------------------
-- exist_entity_id
--------------------------------------------
 FUNCTION exist_entity_id
-- Return Y if the entity id exists in HZ_DSS_ENTITIES
--        N otherwise
(p_entity_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
SELECT 'Y'
  FROM hz_dss_entities
 WHERE entity_id = p_entity_id ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
 END exist_entity_id;


--------------------------------------------
-- exist_function_id
--------------------------------------------
FUNCTION exist_function_id
-- Return Y if function id exists in fnd_form_functions
--        N otherwise
(p_function_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from fnd_form_functions where function_id = p_function_id;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
 END exist_function_id ;

END HZ_DSS_VALIDATE_PKG;

/
