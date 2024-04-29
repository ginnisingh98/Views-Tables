--------------------------------------------------------
--  DDL for Package Body HZ_DNB_HIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DNB_HIERARCHY_PVT" AS
/* $Header: ARHDNBHB.pls 120.19 2006/02/13 12:09:46 vravicha noship $ */
-------------------------------------------------------------------------------------------
-- AUTHOR :::::: COLATHUR VIJAYAN ("VJN")
-- ----------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- NOTE ::::: ALL THE SCENARIOS (RELATIONSHIPS BETWEEN PARTIES) THAT ARE DESCRIBED HERE
--            PERTAIN TO DATA THAT IS OBTAINED FROM DNB AND IMPORTED INTO TCA. SINCE NOT
--            ALL PARTIES NEED TO BE NECESSARILY PURCHASED BY A TYPICAL USER OF TCA, THE DIFFERENT
--            RELATIONSHIPS THAT EXIST BETWEEN PARTIES, IN THE HZ_RELATIONSHIPS TABLE, AT ANY TIME CANNOT
--            REPRESENT REALITY ( ALL POSSIBLE RELATIONSHIPS BETWEEN ALL KINDS OF PARTIES, THAT DNB HAS
--            IN ITS DATABASE).
--            SO THE QUESTION IS, HOW DO WE BEST REPRESENT THE DIFFERENT RELATIONSHIPS BETWEEN DNB IMPORTED
--            PARTIES, AS FOUND IN HZ_RELATIONSHIPS, IN A HIERARCHICAL FASHION, WITH THE UNDERSTANDING THAT
--            THE HZ_RELATIONSHIPS TABLE, MAY ONLY REPRESENT A SUBSET OF REALITY AT ANY GIVEN TIME.

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- SOME DEFINITIONS
-- TCA-DNB_HIERARCHY TREE :::: THIS IS THE TREE THAT WE WOULD LIKE TO SEE IN THE HIERARCHY VIEWER FOR DNB DATA.
--                     CONSIDERING THAT TCA MAY NOT HAVE ALL DNB DATA (SEE THE FIRST NOTE ABOVE), THE
--                     HIERARCHY TREE THAT WE WOULD BE BUILDING, MAY AT BEST, BE A SUBSET OF THE ACTUAL
--                     TREE. THE TREE WILL HAVE THE FOLLOWING PROPERTIES ::::::::
--                     1. IT WILL START FROM A LEAF NODE AND GO ALL THE WAY UP TO THE GLOBAL ULTIMATE.
--                     2. BETWEEN ANY PARTY (P1, SAY) AND A PARTY (P2, SAY) AT THE NEXT HIGHER LEVEL, THE RELATIONSHIP
--                        WOULD BE ONE OF THE FOLLOWING :
--                        a. A PARENT-SUBSIDIARY OR A HEADQUARTER-DIVISION.
--                        b. UNKNOWN
--                             ( THIS HAPPENS WHEN EVER --- P2 IS A GUP OF P1 OR P2 IS A DUP OF P1 AND THERE IS
--                               NO DIRECT PARENT_SUBSIDIARY OR A HEADQUARTER-DIVISION RELATIONSHIP BETWEEN
--                               P1 AND P2).
-- POSITIONAL/IMMEDIATE PARENT :::::::: A POSITIONAL/IMMEDIATE PARENT OF A PARTY IS A PARTY THAT IS ONE LEVEL
--                                      ABOVE IT, IN THE TCA_DNB_HIERARCHY TREE.
-- LEAF NODE PARTY ::::::: THIS IS A PARTY WHICH IS A CHILD OF SOME PARTY AND A PARENT OF NO PARTY.
-- ORPHAN PARTY ::::: THIS IS A PARTY WHICH HAS NO DIRECT DNB RELATIONSHIP OF THE TYPE
--                    DUP, GUP, PARENT/HQ WITH ANY OTHER PARTY. IT IS AN ORPHAN IN THE SENSE
--                    THAT IT HAS NO DIRECT POSITIONAL/IMMEDIATE PARENT. HOWEVER FOR THESE
--                    PARTIES WE COULD DERIVE POSITIONAL/IMMEDIATE PARENTS, BY USING THE INFORMATION
--                    FROM THEIR CHILDREN.
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

------------------------------
-- relationship_exists
------------------------------

FUNCTION relationship_exists
-- Return Y if there exists any relationship what so ever between subject and object,
-- under the passed in relationship type (NOTE: Relationship code is insignificant in this check !!!)
-- N otherwise
(p_subject_id NUMBER, p_object_id NUMBER, p_relationship_code VARCHAR2 , p_relationship_type VARCHAR2)
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where subject_id = p_subject_id
      and object_id = p_object_id
      and actual_content_source = 'DNB'
      and relationship_type = p_relationship_type
      and (end_date is null
        or end_date > sysdate)  ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN

 -- Force the function to return a 'Y' , when ever the subject and object are the same
 IF p_subject_id = p_object_id
 THEN
    RETURN 'Y' ;
 END IF;

 OPEN c0;
   FETCH c0 INTO l_yn;
   IF c0%NOTFOUND THEN
     result := 'N';
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END relationship_exists ;


------------------------------
-- get_parent_subject_id_info
-----------------------------


FUNCTION get_parent_subject_id_info
(p_subject_id NUMBER, p_relationship_type VARCHAR2 )
RETURN dnb_dfs_rec_type
IS
CURSOR c0
IS
    SELECT subject_id, start_date
    FROM hz_relationships
    WHERE relationship_code = 'PARENT_OF'
        and relationship_type = p_relationship_type
        and actual_content_source = 'DNB'
        and object_id = p_subject_id
        and object_id <> subject_id
        and (end_date is null
        or end_date > sysdate) ;
l_yn  DNB_DFS_REC_TYPE ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_parent_subject_id_info ;



------------------------------
-- get_parent_subject_id
-----------------------------


FUNCTION get_parent_subject_id
(p_subject_id NUMBER, p_relationship_type VARCHAR2 )
RETURN NUMBER
IS
CURSOR c0
IS
    SELECT subject_id
    FROM hz_relationships
    WHERE relationship_code = 'PARENT_OF'
        and relationship_type = p_relationship_type
        and actual_content_source = 'DNB'
        and object_id = p_subject_id
        and object_id <> subject_id
        and (end_date is null
        or end_date > sysdate) ;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_parent_subject_id ;


------------------------------
-- get_hq_subject_id_info
-----------------------------


FUNCTION get_hq_subject_id_info
(p_subject_id NUMBER, p_relationship_type VARCHAR2)
RETURN dnb_dfs_rec_type
IS
CURSOR c0
IS
    SELECT subject_id, start_date
    FROM hz_relationships
    WHERE relationship_code = 'HEADQUARTERS_OF'
        and relationship_type = p_relationship_type
        and actual_content_source = 'DNB'
        and object_id = p_subject_id
        and object_id <> subject_id
        and (end_date is null
        or end_date > sysdate) ;
l_yn  dnb_dfs_rec_type ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_hq_subject_id_info ;



------------------------------
-- get_hq_subject_id
-----------------------------


FUNCTION get_hq_subject_id
(p_subject_id NUMBER, p_relationship_type VARCHAR2)
RETURN NUMBER
IS
CURSOR c0
IS
    SELECT subject_id
    FROM hz_relationships
    WHERE relationship_code = 'HEADQUARTERS_OF'
        and relationship_type = p_relationship_type
        and actual_content_source = 'DNB'
        and object_id = p_subject_id
        and object_id <> subject_id
        and (end_date is null
        or end_date > sysdate) ;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_hq_subject_id ;


------------------------------
-- get_dup_subject_id_info
-----------------------------

FUNCTION get_dup_subject_id_info
(p_subject_id NUMBER, p_relationship_type VARCHAR2)
RETURN dnb_dfs_rec_type
IS
CURSOR c0
IS
    SELECT subject_id, start_date
    FROM hz_relationships
    WHERE relationship_code = 'DOMESTIC_ULTIMATE_OF'
        and relationship_type = p_relationship_type
        and actual_content_source = 'DNB'
        and object_id = p_subject_id
        and (end_date is null
        or end_date > sysdate)  ;
l_yn  dnb_dfs_rec_type ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_dup_subject_id_info ;




------------------------------
-- get_dup_subject_id
-----------------------------

FUNCTION get_dup_subject_id
(p_subject_id NUMBER, p_relationship_type VARCHAR2)
RETURN NUMBER
IS
CURSOR c0
IS
    SELECT subject_id
    FROM hz_relationships
    WHERE relationship_code = 'DOMESTIC_ULTIMATE_OF'
        and relationship_type = p_relationship_type
        and actual_content_source = 'DNB'
        and object_id = p_subject_id
        and (end_date is null
        or end_date > sysdate)  ;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_dup_subject_id ;


------------------------------
-- get_gup_subject_id_info
-----------------------------
FUNCTION get_gup_subject_id_info
(p_subject_id NUMBER, p_relationship_type VARCHAR2 )
RETURN dnb_dfs_rec_type
IS
CURSOR c0
IS
    SELECT subject_id, start_date
    FROM hz_relationships
    WHERE relationship_code = 'GLOBAL_ULTIMATE_OF'
        and relationship_type = p_relationship_type
        and actual_content_source = 'DNB'
        and object_id = p_subject_id
        and (end_date is null
        or end_date > sysdate)  ;
l_yn  dnb_dfs_rec_type ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_gup_subject_id_info ;



------------------------------
-- get_gup_subject_id
-----------------------------
FUNCTION get_gup_subject_id
(p_subject_id NUMBER, p_relationship_type VARCHAR2 )
RETURN NUMBER
IS
CURSOR c0
IS
    SELECT subject_id
    FROM hz_relationships
    WHERE relationship_code = 'GLOBAL_ULTIMATE_OF'
        and relationship_type = p_relationship_type
        and actual_content_source = 'DNB'
        and object_id = p_subject_id
        and (end_date is null
        or end_date > sysdate)  ;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_gup_subject_id ;


------------------------------
-- get_child_subject_id
-----------------------------
FUNCTION get_child_subject_id
(p_subject_id NUMBER, p_relationship_type VARCHAR2)
RETURN NUMBER
IS
CURSOR c0
IS
    SELECT subject_id
    FROM hz_relationships
    WHERE relationship_code = 'SUBSIDIARY_OF'
        and relationship_type = p_relationship_type
        and actual_content_source = 'DNB'
        and object_id = p_subject_id
        and object_id <> subject_id
        and (end_date is null
        or end_date > sysdate) ;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_child_subject_id ;

------------------------------
-- get_division_subject_id
-----------------------------
FUNCTION get_division_subject_id
(p_subject_id NUMBER, p_relationship_type VARCHAR2)
RETURN NUMBER
IS
CURSOR c0
IS
    SELECT subject_id
    FROM hz_relationships
    WHERE relationship_code = 'DIVISION_OF'
        and relationship_type = p_relationship_type
        and actual_content_source = 'DNB'
        and object_id = p_subject_id
        and object_id <> subject_id
        and (end_date is null
        or end_date > sysdate)  ;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_division_subject_id ;



------------------------------
-- get_party_subordinate_to
-----------------------------
FUNCTION get_party_subordinate_to
(p_subject_id NUMBER, p_relationship_type VARCHAR2 )
RETURN NUMBER
IS
CURSOR c0
IS
    SELECT object_id
    FROM hz_relationships
    WHERE relationship_type = p_relationship_type
         and (relationship_code = 'GLOBAL_SUBSIDIARY_OF'
         or relationship_code = 'DOMESTIC_SUBSIDIARY_OF'
         or relationship_code = 'DIVISION_OF'
         or relationship_code = 'SUBSIDIARY_OF')
         and actual_content_source = 'DNB'
         and subject_id = p_subject_id
         and (end_date is null
         or end_date > sysdate)  ;
l_yn  number ;
result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_party_subordinate_to ;


--------------------------------------------
-- party_exists
--------------------------------------------

FUNCTION party_exists
-- Return Y if the passed in subject id exists in new rel types
--        N otherwise
(p_subject_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where subject_id = p_subject_id
      and relationship_type = 'DNB_HIERARCHY'
      and rownum = 1
      and (end_date is null
        or end_date > sysdate)  ;
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
END party_exists ;

--------------------------------------------
-- gup_of_party_exists
--------------------------------------------

FUNCTION gup_of_party_exists
-- Return Y if the passed in gup_subject_id exists in new rel types
--        N otherwise
(gup_subject_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where subject_id = gup_subject_id
      and relationship_type = 'DNB_HIERARCHY'
      and rownum = 1
      and (end_date is null
        or end_date > sysdate)  ;
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
END gup_of_party_exists ;

--------------------------------------------
-- party_has_hq
--------------------------------------------

FUNCTION party_has_hq
-- Return Y if the passed in p_subject_id has a HQ in new rel types
--        N otherwise
(p_subject_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where object_id = p_subject_id
      and relationship_code = 'HEADQUARTERS_OF'
      and relationship_type = 'DNB_HIERARCHY'
      and (end_date is null
        or end_date > sysdate)  ;
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
END party_has_hq ;

--------------------------------------------
-- party_has_parent
--------------------------------------------

FUNCTION party_has_parent
-- Return Y if the passed in p_subject_id has a PARENT in new rel types
--        N otherwise
(p_subject_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where object_id = p_subject_id
      and relationship_code = 'PARENT_OF'
      and relationship_type = 'DNB_HIERARCHY'
      and (end_date is null
        or end_date > sysdate)  ;
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
END party_has_parent ;

--------------------------------------------
-- party_has_gup_relationship
--------------------------------------------

FUNCTION party_has_gup_relationship
-- Return Y if the passed in p_subject_id has a GLOBAL SUBSIDIARY RELATIONSHIP
-- with the pased in GUP in new rel types
--        N otherwise
(p_subject_id NUMBER, gup_subject_id NUMBER )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where subject_id = p_subject_id
      and object_id = gup_subject_id
      and relationship_code = 'GLOBAL_SUBSIDIARY_OF'
      and relationship_type = 'DNB_HIERARCHY'
      and (end_date is null
        or end_date > sysdate)  ;
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
END party_has_gup_relationship ;

--------------------------------------------
-- party_has_dup_relationship
--------------------------------------------

FUNCTION party_has_dup_relationship
-- Return Y if the passed in p_subject_id participates in a
-- DOMESTIC SUBSIDIARY RELATIONSHIP in new rel types
--        N otherwise
(p_subject_id NUMBER)
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where subject_id = p_subject_id
      and relationship_code = 'DOMESTIC_SUBSIDIARY_OF'
      and relationship_type = 'DNB_HIERARCHY'
      and (end_date is null
        or end_date > sysdate)  ;
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
END party_has_dup_relationship ;

--------------------------------------------
-- party_is_a_gup
--------------------------------------------

FUNCTION party_is_a_gup
-- Return Y if the passed in p_subject_id is a GUP
-- in new rel types
--        N otherwise
(p_subject_id NUMBER)
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where subject_id = p_subject_id
      and relationship_code = 'GLOBAL_ULTIMATE_OF'
      and relationship_type = 'DNB_HIERARCHY'
      and (end_date is null
        or end_date > sysdate)  ;
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
END party_is_a_gup ;

--------------------------------------------
-- is_a_gup
--------------------------------------------

FUNCTION is_a_gup
-- Return Y if the passed in subject id is a GUP
--        N otherwise
(p_subject_id NUMBER, p_relationship_type VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where subject_id = p_subject_id
      and relationship_type = p_relationship_type
      and relationship_code = 'GLOBAL_ULTIMATE_OF'
      and (end_date is null
        or end_date > sysdate)  ;
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
END is_a_gup ;


--------------------------------------------
-- is_a_dup
--------------------------------------------

FUNCTION is_a_dup
-- Return Y if the passed in subject id is a DUP
--        N otherwise
(p_subject_id NUMBER, p_relationship_type VARCHAR2 )
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where subject_id = p_subject_id
      and relationship_type = p_relationship_type
      and relationship_code = 'DOMESTIC_ULTIMATE_OF'
      and (end_date is null
        or end_date > sysdate)  ;
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
END is_a_dup ;


--------------------------------------------
-- get_country
--------------------------------------------

FUNCTION get_country
-- Return the country to which this party id belongs to
(p1 NUMBER)
RETURN VARCHAR2
IS
CURSOR c0
IS
    select hl.country from
    hz_locations hl, hz_party_sites hps
    where hl.location_id=hps.location_id
    and hps.party_id = p1;
l_yn   VARCHAR2(20);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_country ;


------------------------------
-- get_relationship_id
-----------------------------

FUNCTION get_relationship_id
-- get relationship id, when given 2 parties and a relationship between them
(p_subject_id NUMBER, p_object_id NUMBER, p_relationship_code VARCHAR2, p_relationship_type VARCHAR2)
RETURN NUMBER
IS
CURSOR c0
IS
    select relationship_id
    from hz_relationships
    where subject_id = p_subject_id
    and relationship_type = p_relationship_type
    and object_id = p_object_id
    and relationship_code = p_relationship_code ;
l_yn  NUMBER;
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_relationship_id ;



------------------------------
-- create_rel
-----------------------------

FUNCTION create_rel
-- create relationship between two parties, by calling the create relationship API
-- using DNB_HIERARCHY, as the default relationship type.
-- NOTE:: By virtue of the fact that the new relationship type 'DNB_HIERARCHY' should create
--        a true Hierarchy, we make sure that this function will create one and only one
--        pair (forward and backward) of relationships between the passed in subject and
--        object.
(p_subject_id NUMBER, p_object_id NUMBER, p_relationship_code VARCHAR2, p_start_date DATE)
RETURN NUMBER
IS
 /***** FOR CREATING RELATIONSHIPS  **********/
    p_relationship_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    x_relationship_id NUMBER;
    x_party_id NUMBER;
    x_party_number VARCHAR2(2000);
    x_return_status VARCHAR2(2000);
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
BEGIN
                    p_relationship_rec.subject_id := p_subject_id ;
                    p_relationship_rec.subject_type := 'ORGANIZATION';
                    p_relationship_rec.subject_table_name := 'HZ_PARTIES';
                    p_relationship_rec.object_id := p_object_id ;
                    p_relationship_rec.object_type := 'ORGANIZATION';
                    p_relationship_rec.object_table_name := 'HZ_PARTIES';
                    p_relationship_rec.relationship_code := p_relationship_code ;
                    p_relationship_rec.relationship_type := 'DNB_HIERARCHY';
                    p_relationship_rec.comments := 'DNB DFS CREATED';
                    --3903207: commented code that passes content_source_type
                    -- and added code to pass actual_content_source
                    --p_relationship_rec.content_source_type := 'DNB';
                    p_relationship_rec.actual_content_source := 'DNB';
                    p_relationship_rec.created_by_module :='DNB_DFS'; /* DFS = Data Fix script */
                    p_relationship_rec.start_date:= nvl(p_start_date, SYSDATE) ;

                    -- CALL RELATIONSHIP API, AFTER MAKING SURE THAT THE RELATIONSHIP WE ARE
                    -- TRYING TO CREATE, DOES NOT EXIST ALREADY UNDER THE 'DNB_HIERARCHY'
                    -- RELATIONSHIP TYPE
                    IF relationship_exists( p_subject_id, p_object_id, p_relationship_code, 'DNB_HIERARCHY' ) = 'N'
                    THEN
                        hz_relationship_v2pub.create_relationship('T',p_relationship_rec,
                             x_relationship_id,x_party_id,x_party_number,x_return_status,x_msg_count,x_msg_data,'');
                    END IF;
                    return 0 ;
END create_rel ;

------------------------------
-- create_rel_cps
-----------------------------

FUNCTION create_rel_cps
-- create relationship between two parties, by calling the create relationship API
-- using DNB_HIERARCHY, as the default relationship type.
-- NOTE:: By virtue of the fact that the new relationship type 'DNB_HIERARCHY' should create
--        a true Hierarchy, we make sure that this function will create one and only one
--        pair (forward and backward) of relationships between the passed in subject and
--        object.
(p_subject_id NUMBER, p_object_id NUMBER, p_relationship_code VARCHAR2, p_start_date DATE)
RETURN NUMBER
IS
 /***** FOR CREATING RELATIONSHIPS  **********/
    p_relationship_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    x_relationship_id NUMBER;
    x_party_id NUMBER;
    x_party_number VARCHAR2(2000);
    x_return_status VARCHAR2(2000);
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
BEGIN
                    p_relationship_rec.subject_id := p_subject_id ;
                    p_relationship_rec.subject_type := 'ORGANIZATION';
                    p_relationship_rec.subject_table_name := 'HZ_PARTIES';
                    p_relationship_rec.object_id := p_object_id ;
                    p_relationship_rec.object_type := 'ORGANIZATION';
                    p_relationship_rec.object_table_name := 'HZ_PARTIES';
                    p_relationship_rec.relationship_code := p_relationship_code ;
                    p_relationship_rec.relationship_type := 'DNB_HIERARCHY';
                    p_relationship_rec.comments := 'DNB CPS CREATED';
                    --3903207: commented code that passes content_source_type
                    --and added code to pass actual_content_source
                    --p_relationship_rec.content_source_type := 'DNB';
                    p_relationship_rec.actual_content_source := 'DNB';
                    /* Fix bug 4659246: Change DNB_CPS to TCA_DNB_MAPPING.
                       DNB_CPS was not seeded as a lookup code of HZ_CREATED_BY_MODULES */
                    p_relationship_rec.created_by_module :='TCA_DNB_MAPPING';

                    -- we always delay the start date time by 2 mins, so that we can avoid overlaps
                    -- for example when A -- B has to be end dated and A -- C has to created,
                    -- the creation time of A -- C , will always be 2 mins past the end dation of
                    -- A -- B.
                    IF p_start_date is null
                    THEN
                      p_relationship_rec.start_date:=  sysdate + 120/(24*60*60);
                    ELSE
                      p_relationship_rec.start_date:= p_start_date + 120/(24*60*60);
                    END IF;


                    -- CALL RELATIONSHIP API, AFTER MAKING SURE THAT THE RELATIONSHIP WE ARE
                    -- TRYING TO CREATE, DOES NOT EXIST ALREADY UNDER THE 'DNB_HIERARCHY'
                    -- RELATIONSHIP TYPE
                    IF relationship_exists( p_subject_id, p_object_id, p_relationship_code, 'DNB_HIERARCHY' ) = 'N'
                    THEN
                        hz_relationship_v2pub.create_relationship('T',p_relationship_rec,
                             x_relationship_id,x_party_id,x_party_number,x_return_status,x_msg_count,x_msg_data,'');
                    END IF;


                    -- RAISE HELL WHEN return status is not success
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                    THEN
                      FND_MESSAGE.SET_NAME('AR', 'HZ_CREATE_REL_SUB_OBJ_ERROR');
                      FND_MESSAGE.SET_TOKEN('RELATIONSHIP' ,p_relationship_code);
                      FND_MESSAGE.SET_TOKEN('REL_TYPE' , 'DNB_HIERARCHY');
                      FND_MESSAGE.SET_TOKEN('SUB' , to_char(p_subject_id));
                      FND_MESSAGE.SET_TOKEN('OBJ' , to_char(p_object_id));
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    END IF;
                    return 0 ;
END create_rel_cps ;

------------------------------
-- end_date_rel
-----------------------------

FUNCTION end_date_rel
-- end date relationship between two parties, by calling the update relationship API
(p_subject_id NUMBER, p_object_id NUMBER, p_relationship_code VARCHAR2 )
RETURN NUMBER
IS
    x_relationship_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    x_relationship_id NUMBER;
    x_directional_flag VARCHAR2(1);
    x_object_version_number NUMBER;
    x_party_object_version_number NUMBER;
    x_return_status VARCHAR2(2000);
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
BEGIN
    -- GET THE RELATIONSHIP ID FOR THE RELATIONSHIP
    x_relationship_id := get_relationship_id(p_subject_id, p_object_id, p_relationship_code, 'DNB_HIERARCHY');

    -- GET OBJECT VERSION NUMBER FOR THE FETCHED RELATIONSHIP ID
   SELECT object_version_number INTO x_object_version_number
   FROM   hz_relationships
   WHERE  relationship_id = x_relationship_id
   AND    subject_table_name = 'HZ_PARTIES'
   AND    object_table_name = 'HZ_PARTIES'
   AND    directional_flag = 'F';

    -- CALL THE GET RELATIONSHIP API TO GET THE CORRESPONDING RELATIONSHIP RECORD
    hz_relationship_v2pub.get_relationship_rec ('T', x_relationship_id, x_directional_flag, x_relationship_rec,
                                                x_return_status, x_msg_count, x_msg_data );
    -- UPDATE THE CORRESPONDING RELATIONSHIP RECORD, BY END DATING IT AND CALLING THE UPDATE RELATIONSHIP API
    x_relationship_rec.end_date := sysdate;
    hz_relationship_v2pub.update_relationship ('T', x_relationship_rec,
                    x_object_version_number, x_party_object_version_number,x_return_status, x_msg_count, x_msg_data );
    return 0;

END end_date_rel ;


-------------------------------------
-- is_a_descendant
-- Given two parties A,B this recursive function would, figure out NOCOPY if B is a descendant of A
-- ie., if B lies on the same branch as A and is at a lower level than A
-------------------------------------

FUNCTION is_a_descendant
(p_subject_id NUMBER, p_object_id NUMBER)
-- p_subject_id -- is the purchased party.
-- p_object_id -- is the party we are checking, if it is a descendant of P.
RETURN VARCHAR2
IS
    ret_value VARCHAR2(1) ;
    temp number;
BEGIN
    -- p_subject_id = A, p_object_id = B.

    -- If B is a GLOBAL ULTIMATE, there is no way B could be at a lower level than P
    -- Just return a NO in this case
    IF is_a_gup (p_object_id, 'GLOBAL_ULTIMATE') = 'N'
    THEN
        return 'N';

    -- If B has a headquarter see, if it is A, else continue the recursion
    ELSIF (temp = get_hq_subject_id ( p_object_id, 'DNB_HIERARCHY') ) is not null
    THEN
        IF temp = p_subject_id
        THEN
            return 'Y';
        ELSE
            return is_a_descendant(p_subject_id, temp) ;
        END IF;
    -- Else if B has a parent see, if it is A, else continue the recursion
    ELSIF (temp = get_parent_subject_id ( p_object_id, 'DNB_HIERARCHY') ) is not null
    THEN
            IF temp = p_subject_id
            THEN
                return 'Y';
            ELSE
                return is_a_descendant(p_subject_id, temp) ;
            END IF;
    -- Else if B has a domestic ultimate see, if it is A, else continue the recursion
    ELSIF (temp = get_dup_subject_id ( p_object_id, 'DNB_HIERARCHY')) is not null
    THEN
            IF temp = p_subject_id
            THEN
                return 'Y';
            ELSE
                return is_a_descendant(p_subject_id, temp) ;
            END IF;
    -- Else if B has a global ultimate see, if it is A, else continue the recursion
    ELSIF (temp = get_gup_subject_id ( p_object_id, 'DNB_HIERARCHY')) is not null
    THEN
            IF temp = p_subject_id
            THEN
                return 'Y';
            ELSE
                return is_a_descendant(p_subject_id, temp) ;
            END IF;
     END IF;

     -- IF IT GETS THIS FAR RETURN N
     return 'N';

END is_a_descendant ;



-------------------------------------
-- is_party_dangling
-- Given a party A, this function will find out NOCOPY if A participates in any relationship
-- whatsoever, in which it is subordinate to some other party.
-------------------------------------

FUNCTION is_party_dangling
(p_subject_id NUMBER)
-- p_subject_id -- is the party.
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where subject_id = p_subject_id
      and actual_content_source = 'DNB'
      and relationship_type = 'DNB_HIERARCHY'
      and (relationship_code = 'GLOBAL_SUBSIDIARY_OF'
         or relationship_code = 'DOMESTIC_SUBSIDIARY_OF'
         or relationship_code = 'DIVISION_OF'
         or relationship_code = 'SUBSIDIARY_OF')
      and (end_date is null
        or end_date > sysdate)  ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN


 OPEN c0;
   FETCH c0 INTO l_yn;
   -- if no matches found, the party is dangling.
   IF c0%NOTFOUND THEN
     result := 'Y';
   -- else it is not dangling
   ELSE
     result := 'N';
   END IF;
 CLOSE c0;
 RETURN result;
END is_party_dangling ;






-------------------------------------
-- is_penultimate_node
-- Given a party A and the global ultimate party, this function will find out NOCOPY if A is
-- a penultimate node -- ITS IMMEDIATE PARENT IS THE GLOBAL ULTIMATE
------------------------------------

FUNCTION is_penultimate_node
(p_subject_id NUMBER, gup_subject_id NUMBER)
-- p_subject_id -- is the party.
-- gup_subject_id -- the global ultimate party.
RETURN VARCHAR2
IS
CURSOR c0
IS
select 'Y'
from hz_relationships
where subject_id = p_subject_id
      and object_id = gup_subject_id
      and actual_content_source = 'DNB'
      and relationship_type = 'DNB_HIERARCHY'
      and (relationship_code = 'GLOBAL_SUBSIDIARY_OF'
         or relationship_code = 'DOMESTIC_SUBSIDIARY_OF'
         or relationship_code = 'DIVISION_OF'
         or relationship_code = 'SUBSIDIARY_OF')
      and (end_date is null
        or end_date > sysdate)  ;
l_yn   VARCHAR2(1);
result VARCHAR2(1);
BEGIN


 OPEN c0;
   FETCH c0 INTO l_yn;
   -- if no matches found, the party is not a penultimate node
   IF c0%NOTFOUND THEN
     result := 'N';
   -- else it is not dangling
   ELSE
     result := 'Y';
   END IF;
 CLOSE c0;
 RETURN result;
END is_penultimate_node ;



-------------------------------------
-- unlink_immediate_children
-- Given a party A, find all its children, unlink all the immediate children and connect them
-- to the global ultimate.
------------------------------------

FUNCTION unlink_immediate_children
(p_subject_id NUMBER, gup_subject_id NUMBER)
-- p_subject_id -- is the party.
-- gup_subject_id -- global ultimate of purchased party.
RETURN NUMBER
IS
CURSOR c0
IS
select subject_id, relationship_code
from hz_relationships
where object_id = p_subject_id
      and actual_content_source = 'DNB'
      and relationship_type = 'DNB_HIERARCHY'
      and (relationship_code = 'GLOBAL_SUBSIDIARY_OF'
         or relationship_code = 'DOMESTIC_SUBSIDIARY_OF'
         or relationship_code = 'DIVISION_OF'
         or relationship_code = 'SUBSIDIARY_OF')
      and (end_date is null
        or end_date > sysdate)  ;

ret_value NUMBER;

BEGIN
    FOR party_rec IN c0
    LOOP
        -- END DATE THE RELATIONSHIP BETWEEN THE PARTY AND ITS IMMEDIATE CHILD
        ret_value := end_date_rel (p_subject_id, party_rec.subject_id, party_rec.relationship_code );
        -- CREATE RELATIONSHIP BETWEEN IMMEDIATE CHILD AND THE GLOBAL ULTIMATE
        ret_value := create_rel_cps(party_rec.subject_id, gup_subject_id, 'GLOBAL_SUBSIDIARY_OF', SYSDATE );
    END LOOP;

    -- JUST TO MAKE SURE FUNCTION RETURNS A VALUE
    return 0;

    -- THROW EXCEPTIONS UP TO THE CALLER WHEN CREATING RELATIONSHIPS FAIL
    EXCEPTION
    WHEN OTHERS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END unlink_immediate_children ;


---------------------------------------------------------------
-- conform_dom_ult_of_party
-- Given a purchased party A, conform its DUP to the Hierarchy.
---------------------------------------------------------------

FUNCTION conform_dom_ult_of_party
(p_subject_id NUMBER, parent_subject_id NUMBER, dup_subject_id NUMBER, gup_subject_id NUMBER)
-- p_subject_id -- is the purchased party.
-- parent_subject_id -- parent of the purchased party.
-- dup_subject_id -- domestic ultimate of the purchased party.
-- gup_subject_id -- global ultimate of purchased party.
RETURN NUMBER
IS
ret_value NUMBER;

BEGIN
    -- NOTE::: SINCE THE DUP OF P, NEED NOT HAVE BEEN ITS DOMESTIC ULTIMATE IN A PREVIOUS PURCHASE
    --         WE NEED TO TAKE CARE OF THIS PRETTY ELABORATELY, BY UNDOING THINGS
    --         THAT WERE DONE BEFORE.

    -- CONFORM DUP, IF PASSED IN DUP IS NOT THE SAME AS THE PARTY.
    IF dup_subject_id <> p_subject_id
    THEN
            -- IF THE DOMESTIC ULTIMATE IS AT A LOWER LEVEL THAN P, ON THE SAME BRANCH, FIX IT.
            IF is_a_descendant(p_subject_id, dup_subject_id) = 'Y'
            THEN
                ret_value := unlink_immediate_children(p_subject_id, gup_subject_id);
            ELSE
                -- IF THE DOMESTIC ULTIMATE IS NOT AT A LOWER LEVEL, CREATE APPROPRIATE RELATIONSHIPS
                -- OFCOURSE, AFTER MAKING SURE THAT IT IS NOT ALREADY SUBORDINATE TO SOME OTHER PARTY

                IF get_party_subordinate_to(dup_subject_id, 'DNB_HIERARCHY') is null
                THEN
                    ret_value := create_rel_cps(dup_subject_id, gup_subject_id, 'GLOBAL_SUBSIDIARY_OF', SYSDATE );
                END IF;

                -- NEED TO BE ELABORATE IF THE DUP IS NOT THE SAME AS THE PARENT, ELSE THE WORK IS ALREADY DONE
                IF parent_subject_id <> dup_subject_id
                THEN
                        -- CREATE THE DOMESTIC SUBSIDIARY RELATIONSHIP BASED ON THE PARENT BEING SUBORDINATE
                        -- TO ANOTHER PARTY (UNDER DNB_HIERARCHY RELATIONSHIP TYPE) AND THE SAME COUNTRY CHECK.

                        -- PARENT IS NOT SUBORDINATE TO ANY PARTY
                        IF get_party_subordinate_to(parent_subject_id, 'DNB_HIERARCHY') is null
                        THEN
                            -- SAME COUNTRY CHECK
                            IF get_country(parent_subject_id) = get_country(p_subject_id)
                            THEN
                                ret_value := create_rel_cps(parent_subject_id, dup_subject_id, 'DOMESTIC_SUBSIDIARY_OF', SYSDATE );
                            END IF;
                        -- PARENT IS SUBORDINATE TO THE GUP
                        ELSIF get_gup_subject_id(parent_subject_id, 'DNB_HIERARCHY') = gup_subject_id
                        THEN
                            -- SAME COUNTRY CHECK
                            IF get_country(parent_subject_id) = get_country(p_subject_id)
                            THEN
                                ret_value := end_date_rel(parent_subject_id, gup_subject_id, 'GLOBAL_SUBSIDIARY_OF');
                                ret_value := create_rel_cps(parent_subject_id, dup_subject_id, 'DOMESTIC_SUBSIDIARY_OF', SYSDATE );
                            END IF;
                   END IF;
                END IF;
             END IF;

     END IF;


      -- CONFORM PARENT IF NECESSARY
      -- WE BASICALLY SEE IF PARENT IS DANGLING AND FIX IT, BY CREATING A RELATIONSHIP BETWEEN ITSELF AND THE GUP.
      IF get_party_subordinate_to(parent_subject_id, 'DNB_HIERARCHY') is null
      THEN
          ret_value := create_rel_cps(parent_subject_id, gup_subject_id, 'GLOBAL_SUBSIDIARY_OF', SYSDATE );
      END IF;


    -- JUST TO MAKE SURE FUNCTION RETURNS A VALUE
    return 0;

    -- THROW EXCEPTIONS UP TO THE CALLER WHEN CREATING RELATIONSHIPS FAIL
    EXCEPTION
    WHEN OTHERS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END conform_dom_ult_of_party ;










-------------------------------------
-- create_hierarchy_tree
-- The recursive function that would create the hierarchy tree,
-- given the leaf node.
-- Please note that recursion would stop if a party is either a
-- global ultimate or if it is an orphan.
-------------------------------------

FUNCTION create_hierarchy_tree
(p_subject_id NUMBER, p_gup_party_id NUMBER, p_child_party_id NUMBER)
RETURN NUMBER
IS
    ret_value number;
    gup_party_id number;
    parent_dnb_dfs_rec_type dnb_dfs_rec_type;
    hq_dnb_dfs_rec_type dnb_dfs_rec_type;
    dup_dnb_dfs_rec_type dnb_dfs_rec_type;
    gup_dnb_dfs_rec_type dnb_dfs_rec_type;
BEGIN

    -- IN THE FIRST CALL TO THIS FUNCTION, FOR A PARTICULAR RECURSION, THE GUP WILL BE CALCULATED,
    -- BUT WILL BE RETAINED FOR ALL SUBSEQUENT RECURSIONS.
    IF p_gup_party_id = -1
    THEN
        gup_party_id := get_gup_subject_id(p_subject_id, 'GLOBAL_ULTIMATE' );
    ELSE
        gup_party_id := p_gup_party_id ;
    END IF;

    -- Get PARENT/HQ info about the passed in party
    -- At any point of time, one and only one of these record types should have data.
    parent_dnb_dfs_rec_type :=  get_parent_subject_id_info(p_subject_id, 'PARENT/SUBSIDIARY');
    hq_dnb_dfs_rec_type := get_hq_subject_id_info(p_subject_id, 'HEADQUARTERS/DIVISION' );

    -- The passed in party is a GUP. Get the hell out of here.........
    IF is_a_gup(p_subject_id, 'GLOBAL_ULTIMATE') = 'Y'
    THEN
        -- NO NEED FOR RECURSION ::::: EXIT
        RETURN 0;


    -- OBSERVATION::: Any party that is not a GUP, has to fall into the following mutually exclusive categories:
    -- It has a parent.
    -- It has a HQ.
    -- It has neither a parent nor a HQ.

    -- The passed in party has a parent
    ELSIF parent_dnb_dfs_rec_type.party_id is not null
    THEN
        -- CREATE THE PARENT RELATIONSHIP
        ret_value := create_rel(parent_dnb_dfs_rec_type.party_id, p_subject_id, 'PARENT_OF',
                                parent_dnb_dfs_rec_type.start_date );


        -- USE THE DUP INFORMATION !!!!!!!!!
        -- CREATE THE GUP RELATIONSHIP DIRECTLY BETWEEN THE GUP AND THE DOMESTIC ULTIMATE, OF THE PASSED IN PARTY,
        -- IF IN CASE THE DUP IS NEITHER EQUAL TO THE PARENT NOR EQUAL TO THE PASSED IN PARTY.

        dup_dnb_dfs_rec_type := get_dup_subject_id_info ( p_subject_id, 'DOMESTIC_ULTIMATE' );
        IF dup_dnb_dfs_rec_type.party_id <> parent_dnb_dfs_rec_type.party_id and
           dup_dnb_dfs_rec_type.party_id <> p_subject_id
        THEN
            -- CREATE THE GUP RELATIONSHIP BETWEEN THE PASSED IN GUP AND THE DUP OF THE PASSED IN PARTY
            ret_value := create_rel( gup_party_id, dup_dnb_dfs_rec_type.party_id, 'GLOBAL_ULTIMATE_OF',
                                     dup_dnb_dfs_rec_type.start_date );
        END IF;
        -- RECURSION
        RETURN create_hierarchy_tree(parent_dnb_dfs_rec_type.party_id, gup_party_id, p_subject_id );

     -- The passed in party has a headquarters
     ELSIF hq_dnb_dfs_rec_type.party_id is not null
     THEN

        -- CREATE THE HEAD QUARTERS RELATIONSHIP
        ret_value := create_rel(hq_dnb_dfs_rec_type.party_id, p_subject_id, 'HEADQUARTERS_OF',
                                hq_dnb_dfs_rec_type.start_date );


        -- USE THE DUP INFORMATION !!!!!!!!!
        -- CREATE THE GUP RELATIONSHIP DIRECTLY BETWEEN THE GUP AND THE DOMESTIC ULTIMATE, OF THE PASSED IN PARTY,
        -- IF IN CASE THE DUP IS NEITHER EQUAL TO THE HQ NOR EQUAL TO THE PASSED IN PARTY.

        dup_dnb_dfs_rec_type := get_dup_subject_id_info ( p_subject_id, 'DOMESTIC_ULTIMATE' );
        IF dup_dnb_dfs_rec_type.party_id <> hq_dnb_dfs_rec_type.party_id and
           dup_dnb_dfs_rec_type.party_id <> p_subject_id
        THEN
            -- CREATE THE GUP RELATIONSHIP BETWEEN THE PASSED IN GUP AND THE DUP OF THE PASSED IN PARTY
            ret_value := create_rel( gup_party_id, dup_dnb_dfs_rec_type.party_id, 'GLOBAL_ULTIMATE_OF',
                                     dup_dnb_dfs_rec_type.start_date );
        END IF;
        -- RECURSION
        RETURN create_hierarchy_tree(hq_dnb_dfs_rec_type.party_id, gup_party_id, p_subject_id );

      -- The passed in party is an orphan -- no parent and no HQ.
      -- For this case, we derive the relationships, through its child.
      ELSE
            -- GET THE DOMESTIC ULTIMATE OF THE PASSED IN CHILD PARTY
            dup_dnb_dfs_rec_type := get_dup_subject_id_info ( p_child_party_id, 'DOMESTIC_ULTIMATE' );

            -- VERY WEIRD IF THIS HAPPENS -- BAD DATA
            IF dup_dnb_dfs_rec_type.party_id is null
            THEN
                  RETURN 0;
            END IF;

            -- DO THE DERIVATION (IE., EXTRACTING INFORMATION FROM THE IMMEDIATE CHILD)OF THE DUP,
            -- ONLY IF THE DUP OF THE CHILD IS NEITHER THE CHILD NOR THE PASSED IN PARTY
            IF dup_dnb_dfs_rec_type.party_id <> p_child_party_id and dup_dnb_dfs_rec_type.party_id <> p_subject_id
            THEN

                    -- CREATE THE GUP RELATIONSHIP BETWEEN THE PASSED IN GUP AND CHILD's DUP
                    ret_value := create_rel(gup_party_id, dup_dnb_dfs_rec_type.party_id, 'GLOBAL_ULTIMATE_OF',
                                            dup_dnb_dfs_rec_type.start_date );

                    -- ORPHAN AND ITS CHILD ARE IN THE SAME COUNTRY
                    IF get_country(p_subject_id) = get_country(p_child_party_id)
                    THEN
                            -- THE DERIVED (CHILD's) DUP WOULD BE THE DUP OF THE PASSED IN PARTY
                            ret_value := create_rel(dup_dnb_dfs_rec_type.party_id, p_subject_id, 'DOMESTIC_ULTIMATE_OF',
                                                    dup_dnb_dfs_rec_type.start_date );
                    ELSE
                            -- THE PASSED IN GUP WOULD BE THE GUP OF THE PASSED IN PARTY
                            ret_value := create_rel(gup_party_id, p_subject_id, 'GLOBAL_ULTIMATE_OF',
                                                    dup_dnb_dfs_rec_type.start_date );

                    END IF;
              ELSE
                            -- THE GUP OF THE CHILD WOULD BE THE GUP OF THE PASSED IN PARTY
                            -- ALTHOUGH THE GUP IS PASSED IN IN THE RECURSION, WE NEED TO DO THIS
                            -- MANUEVOUR, TO GET THE START DATE
                            gup_dnb_dfs_rec_type := get_gup_subject_id_info ( p_child_party_id, 'GLOBAL_ULTIMATE' );
                            ret_value := create_rel(gup_party_id, p_subject_id, 'GLOBAL_ULTIMATE_OF',
                                                    gup_dnb_dfs_rec_type.start_date );

             END IF;

         -- NO RECURSION REQUIRED
         RETURN 0;


      END IF;

      -- JUST TO MAKE SURE FUNCTION RETURNS A VALUE
      return 0;
END create_hierarchy_tree ;


/**
 * PROCEDURE create_dnb_hierarchy
 *
 * DESCRIPTION
 *
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   12-13-2002    Colathur Vijayan       o Created.
 *
 */

-------------------------------------
-- create_dnb_hierarchy
-- Main Procedure::: This would first do a clean up, by clearing up the existing hz_dnb_hierarchy_dump table,
--                   find all root parties and for every root party construct the hierarchy tree by
--                   finding successive parents through recursion.
-------------------------------------
PROCEDURE create_dnb_hierarchy (
-- input parameters
 	p_init_msg_list			IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
-- output parameters
    x_return_status			OUT NOCOPY VARCHAR2,
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2
) IS
  l_root_object_id NUMBER;
  ret_value NUMBER;

  -- THE CURSOR THAT WILL GET ALL ROOT PARTIES. A ROOT PARTY IS A PARTY THAT HAS NO CHILDREN, BUT ALWAYS HAS A PARENT.

-- Bug 4945516
CURSOR c_get_root_parties is
select subject_id
from hz_relationships rel
where rel.actual_content_source = 'DNB'
  and rel.relationship_type in ( 'PARENT/SUBSIDIARY' , 'HEADQUARTERS/DIVISION' )
  and rel.relationship_code in ( 'SUBSIDIARY_OF' , 'DIVISION_OF' )
  and ( rel.end_date is null
     or rel.end_date > sysdate )
  and rel.object_table_name='HZ_PARTIES'
  and rel.object_type='ORGANIZATION'
  and rel.subject_table_name='HZ_PARTIES'
  and rel.subject_type='ORGANIZATION'
  and rel.directional_flag in ('F','B')
  and rel.status='A'
  and not exists ( select 1
              from hz_relationships
              where relationship_type in ( 'PARENT/SUBSIDIARY' , 'HEADQUARTERS/DIVISION' )
                and relationship_code in ( 'PARENT_OF' , 'HEADQUARTERS_OF' )
                and subject_table_name='HZ_PARTIES'
                and subject_type='ORGANIZATION'
                and ( end_date is null
                   or end_date > sysdate )
                and actual_content_source = 'DNB'
                and status='A'
		and subject_id=rel.subject_id);

BEGIN

  -- initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- BEFORE WE MESS WITH ANY DNB DATA WE NEED TO CALL THE DNB POLICY FUNCTION
  hz_common_pub.disable_cont_source_security;

  -- OPEN THE CURSOR THAT WILL GET YOU ALL ROOT PARTIES
  OPEN c_get_root_parties ;

  -- LOOP THROUGH
  LOOP
  FETCH c_get_root_parties INTO l_root_object_id ;

   -- CONSTRUCT THE TREE FOR EVERY ROOT PARTY
  ret_value := create_hierarchy_tree(l_root_object_id, -1, l_root_object_id );

  EXIT WHEN c_get_root_parties%NOTFOUND ;
  END LOOP;

  -- CLOSE CURSOR
  CLOSE c_get_root_parties;



   -- standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
END create_dnb_hierarchy ;


/**
 * PROCEDURE create_dnb_hierarchy
 *
 * DESCRIPTION
 *
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   12-13-2002    Colathur Vijayan       o Created.
 *
 */

-------------------------------------
-- create_dnb_hierarchy
-- Main Procedure::: The overloaded procedure, that could be called from the concurrent program
-------------------------------------
PROCEDURE create_dnb_hierarchy (
    errbuf              OUT     NOCOPY VARCHAR2,
    Retcode             OUT     NOCOPY VARCHAR2,
    cleanup_required	IN      VARCHAR2  DEFAULT 'N'
) IS
  l_root_object_id NUMBER;
  ret_value NUMBER;

  -- THE CURSOR THAT WILL GET ALL ROOT PARTIES. A ROOT PARTY IS A PARTY THAT HAS NO CHILDREN, BUT ALWAYS HAS A PARENT.

-- Bug 4945516
CURSOR c_get_root_parties is
select rel.subject_id
from hz_relationships rel
where rel.actual_content_source = 'DNB'
  and rel.relationship_code in ( 'SUBSIDIARY_OF' , 'DIVISION_OF' )
  and ( rel.end_date is null
     or rel.end_date > sysdate )
  and rel.object_table_name='HZ_PARTIES'
  and rel.object_type='ORGANIZATION'
  and rel.subject_table_name='HZ_PARTIES'
  and rel.subject_type='ORGANIZATION'
  and rel.directional_flag in ('F','B')
  and not exists ( select 1
              from hz_relationships
              where relationship_code in ( 'PARENT_OF' , 'HEADQUARTERS_OF' )
                and subject_table_name='HZ_PARTIES'
                and subject_type='ORGANIZATION'
                and ( end_date is null
                   or end_date > sysdate )
                and actual_content_source = 'DNB'
                and subject_id=rel.subject_id );

BEGIN


  -- BEFORE WE MESS WITH ANY DNB DATA WE NEED TO CALL THE DNB POLICY FUNCTION
  hz_common_pub.disable_cont_source_security;


  FND_FILE.put_line(FND_FILE.log,'Start time to create DNB Hierarchy '||to_char(sysdate,'hh24:mi:ss'));

  -- OPEN THE CURSOR THAT WILL GET YOU ALL ROOT PARTIES
  OPEN c_get_root_parties ;

  -- LOOP THROUGH
  LOOP
  FETCH c_get_root_parties INTO l_root_object_id ;

   -- CONSTRUCT THE TREE FOR EVERY ROOT PARTY
  ret_value := create_hierarchy_tree(l_root_object_id, -1, l_root_object_id );

  EXIT WHEN c_get_root_parties%NOTFOUND ;
  END LOOP;

  -- CLOSE CURSOR
  CLOSE c_get_root_parties;

  FND_FILE.put_line(FND_FILE.log,'End time to create DNB Hierarchy '||to_char(sysdate,'hh24:mi:ss'));



END create_dnb_hierarchy ;



/**
 * PROCEDURE:: conform_party_to_dnb_hierarchy
 *
 * DESCRIPTION
 *
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   1-28-2003    Colathur Vijayan       o Created.
 *
 */

-------------------------------------
-- conform_party_to_dnb_hierarchy
-- Main Procedure::: This procedure, will conform a purchased party to the DNB Hierarchy (created by
--                   running the DATA FIX SCRIPT).
--
-------------------------------------
PROCEDURE conform_party_to_dnb_hierarchy (
-- input parameters
 	p_init_msg_list			IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
    party_id                IN NUMBER,
    parent_party_id         IN NUMBER,
    dup_party_id            IN NUMBER,
    gup_party_id            IN NUMBER,
    parent_type_flag        IN VARCHAR2,
-- output parameters
 	x_return_status			OUT NOCOPY VARCHAR2,
    x_msg_count				OUT NOCOPY NUMBER,
    x_msg_data				OUT NOCOPY VARCHAR2
)
IS
    ret_value NUMBER;
    temp NUMBER;
BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- If any of the passed in party ids or the parent type flag is null return the hell out of here
    IF party_id IS NULL
       OR
       parent_party_id IS NULL
       OR
       dup_party_id IS NULL
       OR
       gup_party_id IS NULL
       OR
       parent_type_flag is NULL
    THEN
        -- dbms_output.put_line ('One of the ids or the parent type flag is null');
        RETURN;
    END IF;

    -- PARTY ALREADY EXISTS IN SOME BRANCH
    IF party_exists(party_id) = 'Y'
    THEN
            -- IF PARTY IS GUP, DO NOTHING
            IF party_is_a_gup(party_id) = 'Y'
            THEN
                NULL;
            -- PARTY HAS A HQ UNDER NEW REL TYPES
            ELSIF party_has_hq(party_id) = 'Y'
            THEN
                temp := get_hq_subject_id(party_id, 'DNB_HIERARCHY');
                IF parent_party_id = temp
                THEN
                    ret_value := conform_dom_ult_of_party(party_id, parent_party_id, dup_party_id, gup_party_id);
                ELSE
                    ret_value := end_date_rel(party_id, temp, 'DIVISION_OF');
                    ret_value := create_rel_cps(party_id, parent_party_id, 'DIVISION_OF', SYSDATE );
                    ret_value := conform_dom_ult_of_party(party_id, parent_party_id, dup_party_id, gup_party_id);
                    IF  is_a_descendant(party_id, parent_party_id) = 'Y'
                    THEN
                        ret_value := unlink_immediate_children(party_id, gup_party_id);
                    END IF;

                END IF;
              -- PARTY HAS A PARENT UNDER NEW REL TYPES
              ELSIF party_has_parent(party_id) = 'Y'
              THEN
                  temp := get_parent_subject_id(party_id, 'DNB_HIERARCHY');
                  IF parent_party_id = temp
                  THEN
                      ret_value := conform_dom_ult_of_party(party_id, parent_party_id, dup_party_id, gup_party_id);
                  ELSE
                      ret_value := end_date_rel(party_id, temp, 'SUBSIDIARY_OF');
                      ret_value := create_rel_cps(party_id, parent_party_id, 'SUBSIDIARY_OF', SYSDATE );
                      ret_value := conform_dom_ult_of_party(party_id, parent_party_id, dup_party_id, gup_party_id);
                      IF  is_a_descendant(party_id, parent_party_id) = 'Y'
                      THEN
                          ret_value := unlink_immediate_children(party_id, gup_party_id);
                      END IF;

                  END IF;
              -- PARTY HAS A GLOBAL SUBSIDIARY RELATIONSHIP WITH ITS GUP UNDER NEW REL TYPES
              ELSIF party_has_gup_relationship(party_id, gup_party_id) = 'Y'
              THEN
                  ret_value := end_date_rel(party_id, gup_party_id, 'GLOBAL_SUBSIDIARY_OF');
                  IF parent_party_id = gup_party_id
                  THEN
                      IF parent_type_flag = 'P'
                      THEN
                        ret_value := create_rel_cps(party_id, gup_party_id, 'SUBSIDIARY_OF', SYSDATE );
                      ELSIF parent_type_flag = 'H'
                      THEN
                        ret_value := create_rel_cps(party_id, gup_party_id, 'DIVISION_OF', SYSDATE );
                      END IF;
                  ELSE
                      IF parent_type_flag = 'P'
                      THEN
                        ret_value := create_rel_cps(party_id, parent_party_id, 'SUBSIDIARY_OF', SYSDATE );
                      ELSIF parent_type_flag = 'H'
                      THEN
                        ret_value := create_rel_cps(party_id, parent_party_id, 'DIVISION_OF',SYSDATE );
                      END IF;

                      ret_value := conform_dom_ult_of_party(party_id, parent_party_id, dup_party_id, gup_party_id);
                      IF  is_a_descendant(party_id, parent_party_id) = 'Y'
                      THEN
                          ret_value := unlink_immediate_children(party_id, gup_party_id);
                      END IF;

                  END IF;

              -- PARTY HAS A DOMESTIC SUBSIDIARY RELATIONSHIP WITH ITS IMMEDIATE PARENT UNDER NEW REL TYPES
              ELSIF party_has_dup_relationship(party_id) = 'Y'
              THEN
                  temp := get_dup_subject_id(party_id, 'DNB_HIERARCHY');
                  ret_value := end_date_rel(party_id, temp, 'DOMESTIC_SUBSIDIARY_OF');

                  IF parent_party_id = temp
                  THEN
                      IF parent_type_flag = 'P'
                      THEN
                        ret_value := create_rel_cps(party_id, temp, 'SUBSIDIARY_OF', SYSDATE );
                      ELSIF parent_type_flag = 'H'
                      THEN
                        ret_value := create_rel_cps(party_id, temp, 'DIVISION_OF', SYSDATE );
                      END IF;
                      ret_value := conform_dom_ult_of_party(party_id, parent_party_id, dup_party_id, gup_party_id);
                  ELSE
                      IF parent_type_flag = 'P'
                      THEN
                        ret_value := create_rel_cps(party_id, parent_party_id, 'SUBSIDIARY_OF', SYSDATE );
                      ELSIF parent_type_flag = 'H'
                      THEN
                        ret_value := create_rel_cps(party_id, parent_party_id, 'DIVISION_OF', SYSDATE );
                      END IF;

                      ret_value := conform_dom_ult_of_party(party_id, parent_party_id, dup_party_id, gup_party_id);
                      IF  is_a_descendant(party_id, parent_party_id) = 'Y'
                      THEN
                          ret_value := unlink_immediate_children(party_id, gup_party_id);
                      END IF;

                  END IF;



            END IF;
    -- PARTY DOES NOT EXIST IN ANY BRANCH
    ELSE
                -- DEPENDING ON THE FLAG, CREATE APPROPRIATE RELATIONSHIPS -- PARENT/HEADQUARTERS.
                IF parent_type_flag = 'H'
                THEN
                    ret_value := create_rel_cps(party_id, parent_party_id, 'DIVISION_OF', SYSDATE );
                    ret_value := conform_dom_ult_of_party(party_id, parent_party_id, dup_party_id, gup_party_id);
                ELSIF parent_type_flag = 'P'
                THEN
                    ret_value := create_rel_cps(party_id, parent_party_id, 'SUBSIDIARY_OF', SYSDATE );
                    ret_value := conform_dom_ult_of_party(party_id, parent_party_id, dup_party_id, gup_party_id);
                END IF;

    END IF;


    -- CATCH ANY EXCEPTIONS THROWN WHEN RELATIONSHIPS ARE CREATED
    EXCEPTION
              WHEN OTHERS
              THEN
                    x_return_status := FND_API.G_RET_STS_ERROR ;
                    -- standard call to get message count and if count is 1, get message info.
                    FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END conform_party_to_dnb_hierarchy ;


END; -- Package Body HZ_DNB_HIERARCHY_PVT




/
