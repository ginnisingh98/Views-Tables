--------------------------------------------------------
--  DDL for Package HZ_COPY_REL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_COPY_REL_PVT" AUTHID CURRENT_USER AS
/* $Header: ARHCPRLS.pls 120.1 2005/06/16 21:09:38 jhuang noship $ */
--------------------------------------
-- AUTHOR :::::: COLATHUR VIJAYAN (VJN)
--------------------------------------


--------------------------------------------------------------------------------------
-- copy_rel_type_only ::: This will take a relationship type A and create a relationship
--                   type B, which is a copy of A in the following sense:
--                   B will be identical to A in terms of all the properties( phrase pairs,hierarchical type,
--                   circular flag etc., as seen in HZ_RELATIONSHIP_TYPES), that are
--                   associated with any relationship type.
--
--                   HOWEVER, THIS PROCEDURE WILL NOT COPY RELATIONSHIPS UNDER A TO B.
--------------------------------------------------------------------------------------

PROCEDURE copy_rel_type_only (
 -- in parameters
   p_source_rel_type            IN      VARCHAR2
  ,p_dest_rel_type              IN      VARCHAR2
  ,p_dest_rel_type_role_prefix  IN      VARCHAR2
  ,p_dest_rel_type_role_suffix  IN      VARCHAR2
  -- out NOCOPY parameters
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
  );

----------------------------------------------------------------------------------------------------
-- copy_rel_type_and_all_rels ::: This will take a relationship type A and create a relationship
--                   type B, which is a copy of A in the following sense:
--                   1. B will be identical to A in terms of all the properties( hierarchical type, circular flag
--                   etc., as seen in HZ_RELATIONSHIP_TYPES), that are
--                   associated with any relationship type.
--                   2. ALL THE RELATIONSHIPS UNDER A WILL BE CREATED UNDER B.
----------------------------------------------------------------------------------------------------

PROCEDURE copy_rel_type_and_all_rels (
 errbuf                       OUT     NOCOPY VARCHAR2
,Retcode                      OUT     NOCOPY VARCHAR2
,p_source_rel_type            IN      VARCHAR2
,p_dest_rel_type              IN      VARCHAR2
,p_dest_rel_type_role_prefix  IN      VARCHAR2
,p_dest_rel_type_role_suffix  IN      VARCHAR2
,p_rel_valid_date             IN      DATE DEFAULT SYSDATE
  );

----------------------------------------------------------------
-- WRAPPER ON TOP OF THE copy_rel_typ_and_all_relships PROCEDURE
-- SO THAT IT CAN BE CALLED AS A CONCURRENT PROGRAM
----------------------------------------------------------------

PROCEDURE submit_copy_rel_type_rels_conc (
  -- in parameters
   p_source_rel_type            IN      VARCHAR2
  ,p_dest_rel_type              IN      VARCHAR2
  ,p_dest_rel_type_role_prefix  IN      VARCHAR2
  ,p_dest_rel_type_role_suffix  IN      VARCHAR2
  ,p_rel_valid_date             IN      DATE DEFAULT SYSDATE
  ,x_request_id       OUT NOCOPY NUMBER
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2 );


----------------------------------------------------------------------------------------------------
--------  NOTE THAT A HAS TO BE A HIERARCHICAL RELATIONSHIP TYPE TO BEGIN WITH, FOR THIS PROCEDURE
----------------------------------------------------------------------------------------------------
-- copy_hierarchy ::: This will take 2 Hierarchical relationship types A, B and do the following:
--                    1. If B does not exist already, create B as a copy of A, in the sense of
--                       copy_rel_type_only, mentioned above.
--                    2. Given a party id P, copy the complete hierarchy tree under P in A, to B.
--                       In other words, copy all relationships under A, that pertain to P's
--                       Hierarchy tree ( ie., the tree starting from P and going down) to B.
--                       If B exists already, this would mean that, when ever we create relationships in B,
--                       we need to make sure, that they do not already exist in A.
--
--                       IT SHOULD BE NOTED THAT IF B EXISTS ALREADY, THEN ALL THE PHRASE PAIRS
--                       PERTAINING TO A THAT DO NOT ALREADY EXIST IN B, SHOULD BE FIRST CREATED IN B,
--                       BEFORE PROCEEDING TO STEP 2.
--------------------------------------------------------------------------------------

PROCEDURE copy_hierarchy (
   errbuf                       OUT     NOCOPY VARCHAR2
  ,Retcode                      OUT     NOCOPY VARCHAR2
  ,p_source_rel_type            IN      VARCHAR2
  ,p_dest_rel_type              IN      VARCHAR2
  ,p_dest_rel_type_role_prefix  IN      VARCHAR2
  ,p_dest_rel_type_role_suffix  IN      VARCHAR2
  ,p_rel_valid_date             IN      DATE DEFAULT SYSDATE
  ,p_party_id                   IN      NUMBER
  );

----------------------------------------------------------------
-- WRAPPER ON TOP OF THE copy_hierarchy PROCEDURE
-- SO THAT IT CAN BE CALLED AS A CONCURRENT PROGRAM
----------------------------------------------------------------

PROCEDURE submit_copy_hierarchy_conc (
  -- in parameters
   p_source_rel_type            IN      VARCHAR2
  ,p_dest_rel_type              IN      VARCHAR2
  ,p_dest_rel_type_role_prefix  IN      VARCHAR2
  ,p_dest_rel_type_role_suffix  IN      VARCHAR2
  ,p_rel_valid_date             IN      DATE DEFAULT SYSDATE
  ,p_party_id                   IN      NUMBER
  ,x_request_id       OUT NOCOPY NUMBER
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2 );

------------------------------------------------------------------------
-- This procedure will convert a non-hierarchical relationship type to a
-- hierarchical relationship type.
------------------------------------------------------------------------

PROCEDURE convert_rel_type(
    errbuf              OUT     NOCOPY VARCHAR2,
    Retcode             OUT     NOCOPY VARCHAR2,
    p_rel_type          IN      VARCHAR2
);

----------------------------------------------------------------
-- WRAPPER ON TOP OF THE convert_rel_type PROCEDURE
-- SO THAT IT CAN BE CALLED AS A CONCURRENT PROGRAM
----------------------------------------------------------------

PROCEDURE submit_convert_rel_type_conc (
  -- in parameters
    p_rel_type                   IN            VARCHAR2
    -- out NOCOPY parameters
    ,x_request_id                OUT NOCOPY    NUMBER
    ,x_return_status             OUT NOCOPY    VARCHAR2
    ,x_msg_count                 OUT NOCOPY    NUMBER
    ,x_msg_data                  OUT NOCOPY    VARCHAR2
);


END HZ_COPY_REL_PVT ;



 

/
