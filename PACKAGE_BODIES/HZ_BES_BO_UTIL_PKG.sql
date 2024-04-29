--------------------------------------------------------
--  DDL for Package Body HZ_BES_BO_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BES_BO_UTIL_PKG" AS
/*$Header: ARHBESUB.pls 120.9.12000000.2 2007/07/13 23:43:24 awu ship $ */
----------------------------------------------------------------------------
----------------------------------------------------------------------------

g_debug_prefix CONSTANT  VARCHAR2(30) := 'BOUTILPKG:';
-----------------------------------------------------------------
-- internal procedures
-----------------------------------------------------------------
/**
* Procedure to write text to the log file
**/
----------------------------------------------
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE,
   p_prefix     IN      VARCHAR2,
   p_module     IN      VARCHAR2 ) IS
   BEGIN
/*
	FND_FILE.LOG = 1 - means log file
	FND_FILE.LOG = 2 - means out file
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=> message,
  	  p_prefix=>p_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   => p_module);
  END IF;
  IF newline THEN
    FND_FILE.put_line(FND_FILE.LOG,message);
     FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSE
    FND_FILE.put_line(FND_FILE.LOG,message);
  END IF;
END log;
-----------------------------------------------------------------
/*
 the following procedures a.k.a explode procedures (exp_<table_name>
   are meant to write the parent node, child BO information to BOT
   <list the procedures here>
*/
-----------------------------------------------------------------
/*
Procedure name: ei_hz_contact_preferences()
Scope: external
Purpose: This procedure two activities on BOT table.
Writes the parent node record for HZ_CONTACT_PREFERENCE.
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------
PROCEDURE ei_HZ_CONTACT_PREFERENCES IS
	l_debug_prefix VARCHAR2(30) := 'EXP_CNT_PREF:';
BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'ei_HZ_CONTACT_PREFERENCES()+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_cpp');
  END IF;
/*
Following entities are parents of HZ_CONTACT_PREFERENCE
1. HZ_CONTACT_POINTS (Ph, Web, EFT, Email, SMS, TLX, EDI)
2. HZ_PARTIES (Org, Person, OrgContact)
3. HZ_PARTY_SITES

Contact Point has following parents
1. HZ_PARTIES (Org, Person, OrgContact)
2. HZ_PARTY_SITES

Party Site has following parents
1. HZ_PARTIES (Org, Person, OrgContact)

Hence, contact preference can exist in twenty five different scenarios.
The different combinations of (parent, grand parent) are :
1. (Phone, Org) 2. (Web, Org) 3. (TLX, Org) 4. (Email, Org) 5. (EDI, Org)
6. (EFT, Org) 7. (Phone, Person) 8. (Web, Person) 9. (Email, Person)
10. (SMS, Person) 11. (Phone, OrgContact)	12. (Web, OrgContact)
13. (TLX, OrgContact) 14. (Email, OrgContact) 15. (SMS, OrgContact)
16. (Phone, PS) 17.(TLX, PS) 18. (Email, PS) 19. (Web, PS) 20. (Org, null)
21. (Person, null) 22. (OrgContact, null) 23. (PS, Org) 24. (PS, Person)
25. (PS, OrgContact)

The following SQL gets the Parent and Grand parent info of each contact preference
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_CONTACT_PREFERENCE rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (any CP, Org) -- tested
2. (any CP, Person) -- tested
3. (any CP, OrgContact)
4. (any CP, PS) -- tested
5. (Org, null)  -- tested
6. (Person, null) -- tested
7. (OrgContact, null)
8. (PS, Org) -- tested
9. (PS, Person) -- tested
10. (PS, OrgContact) -- tested
11. (any CP, PS, Person) -- tested
12. (any CP, PS, Org)
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the parents duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

 child record:
   child_id: 123, child_entity_name: hz_contact_preferences,
   child_bo: null, parent_bo: null, parent_entity_name: PS,
   parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_PARTY_SITES
parent_bo aliased as child_bo: PS
grand_parent_id aliased as parent id: 456
grand_parent_entity_name aliased as parent_entity_name: HZ_PARTIES
grand_parent_bo aliased as parent_bo: Org

Insert statement will take this result and write it as
 child record:
   child_id: 234, child_entity_name: HZ_PARTY_SITES,
   child_bo: PS, parent_bo: Org, parent_entity_name: HZ_PARTIES,
   parent_id: 456
6. It is non-trivial to figure out the business object codes for both parent
and grand parent, grand parent identifier or grand parent entity name.
To do this, "inner select" uses case statement on parent_entity_name.
Some times, an embedded SQL is necessary to fgure out this.
Example:
Child is HZ_CONTACT_PREFERENCE.
Parent is HZ_CONTACT_POINTS and it's parent is Party.
To figure out the grand parent bo code, SQL is necessary to run against
hz_parties to figure out the party_type based on owner_table_id of the
hz_contact_points table.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
   CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
    PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
      CHILD_OPERATION_FLAG, POPULATED_FLAG, LAST_UPDATE_DATE,
      CHILD_BO_CODE, PARENT_ENTITY_NAME,
      PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
  FROM
   (SELECT                                      -- inner select
     PARENT_ENTITY_NAME child_entity_name
     ,PARENT_ID child_id
   ,PARENT_BO_CODE CHILD_BO_CODE
   ,'U' child_operation_flag
   ,'Y' populated_flag
   ,LAST_UPDATE_DATE
   ,RANK()
    OVER (PARTITION BY PARENT_ENTITY_NAME, PARENT_ID, CHILD_BO_CODE, PARENT_BO_CODE
       ORDER BY LAST_UPDATE_DATE) as cprank
   ,CASE PARENT_ENTITY_NAME
      WHEN 'HZ_CONTACT_POINTS' THEN -- identify GrandParentEntityName when CP is the parent of CPP
  	  (SELECT
	   CASE OWNER_TABLE_NAME
	     WHEN 'HZ_PARTIES' THEN -- identify GrandParentEntityName when CP is the parent of CPP, Party is parent of CP
		 (SELECT
		   CASE party_type
		  	WHEN 'ORGANIZATION' THEN 'HZ_PARTIES'
		  	WHEN 'PERSON' THEN 'HZ_PARTIES'
		  	WHEN 'PARTY_RELATIONSHIP' THEN 'HZ_ORG_CONTACTS'
		  	ELSE NULL
		  END
		  FROM hz_parties
		  WHERE party_id = owner_table_id)
	     WHEN 'HZ_PARTY_SITES' THEN -- identify GrandParentEntityName when CP is parent of CPP, PS is parent of CP
	       'HZ_PARTY_SITES'
	     ELSE NULL
	      END
	 FROM HZ_CONTACT_POINTS
	  WHERE contact_point_id =  PARENT_ID)
	WHEN 'HZ_PARTIES' THEN -- identify GrandParentEntityName when Party is parent of CPP
      NULL
	WHEN 'HZ_PARTY_SITES' THEN -- identify GrandParentEntityName when PS is parent of CPP
	 (SELECT
	   CASE party_type
	  	WHEN 'ORGANIZATION' THEN 'HZ_PARTIES'
	  	WHEN 'PERSON' THEN 'HZ_PARTIES'
	  	WHEN 'PARTY_RELATIONSHIP' THEN 'HZ_ORG_CONTACTS'
	  	ELSE NULL
	   END
		 FROM HZ_PARTIES
		 WHERE party_id = (SELECT ps.party_id
		   FROM   HZ_PARTY_SITES ps
		   WHERE  ps.party_site_id = PARENT_ID))
	 WHEN 'HZ_ORG_CONTACTS' THEN -- identify GrandParentEntityName when OrgContact is parent of CPP
		'HZ_PARTIES'
	 ELSE
	  NULL
	END parent_entity_name, -- this is the grand parent entity name of cont pref - written as parent entity
	CASE PARENT_ENTITY_NAME
	 WHEN 'HZ_CONTACT_POINTS' THEN -- identify GrandParentEntityId when CP is parent of CPP
	  (SELECT
	    CASE OWNER_TABLE_NAME
		 WHEN 'HZ_PARTIES' THEN -- identify GrandParentEntityId when CP is parent of CPP, party is parentOf CP
		 (SELECT
		   CASE party_type
		  	WHEN 'ORGANIZATION' THEN OWNER_TABLE_ID
			WHEN 'PERSON' THEN OWNER_TABLE_ID
			WHEN 'PARTY_RELATIONSHIP' THEN
			 (SELECT oc.org_contact_id
			    FROM hz_org_contacts oc,  HZ_RELATIONSHIPS r
				WHERE r.relationship_id = oc.party_relationship_id
				 AND r.subject_type = 'PERSON'
				 AND r.object_type = 'ORGANIZATION'
				 AND r.party_id = p.party_id)
			ELSE NULL
			END
		   FROM hz_parties p
		   WHERE p.party_id = owner_table_id)
		WHEN 'HZ_PARTY_SITES' THEN OWNER_TABLE_ID -- identify GrandParentEntityId when CP is parent of CPP, PS parentOf CP
		ELSE NULL
		END
		FROM HZ_CONTACT_POINTS
		WHERE  contact_point_id =  PARENT_ID)
	 WHEN 'HZ_PARTIES' THEN -- identify GrandParentEntityId when Party is parent of CPP
		NULL
	 WHEN 'HZ_PARTY_SITES' THEN -- identify GrandParentEntityId when PS is parent of CPP
	  (SELECT
		CASE p.party_type
		WHEN 'ORGANIZATION' THEN p.party_id -- identify GrandParentEntityId when PS is parent of CPP, Org parentOf PS
		WHEN 'PERSON' THEN p.party_id -- identify GrandParentEntityId when PS is parent of CPP, Per parentOf PS
		WHEN 'PARTY_RELATIONSHIP' THEN -- identify GrandParentEntityId when PS is parent of CPP, Rel parentOf PS
		 (SELECT oc.org_contact_id
		  FROM hz_org_contacts oc,  HZ_RELATIONSHIPS r
		  WHERE r.relationship_id = oc.party_relationship_id
		  AND r.party_id = p.party_id
		  AND r.subject_type = 'PERSON'
		  AND r.object_type = 'ORGANIZATION')
		ELSE NULL
		   END
		FROM hz_parties p
		WHERE p.party_id = (select ps.party_id
		                   from HZ_PARTY_SITES ps
					 where ps.party_site_id = PARENT_ID))
	 WHEN 'HZ_ORG_CONTACTS' THEN -- identify GrandParentEntityId when OrgContact is parent of CPP
      (SELECT r.object_id
	     FROM hz_relationships r, hz_org_contacts oc
		WHERE oc.org_contact_id = PARENT_ID
		AND oc.party_relationship_id = r.relationship_id
		AND subject_type ='PERSON'
		AND object_type = 'ORGANIZATION')
	 ELSE NULL
	 END parent_id, -- this is the grand parent id of cont pref - written as parent id
	CASE PARENT_ENTITY_NAME -- this case is for identifying the grand parent BO
	 WHEN 'HZ_CONTACT_POINTS' THEN -- identify GrandParentBO when CP is parent of CPP
	  (SELECT
	   CASE OWNER_TABLE_NAME
	   WHEN 'HZ_PARTIES' THEN -- identify GrandParentBO when CP is parent of CPP, party is parentOf CP
	    (SELECT
	      CASE party_type
		   WHEN 'ORGANIZATION' THEN 'ORG'
		   WHEN 'PERSON' THEN 'PERSON'
		   WHEN 'PARTY_RELATIONSHIP' THEN 'ORG_CONTACT'
		   ELSE NULL
		  END
		 FROM hz_parties
		 WHERE party_id = owner_table_id)
	   WHEN 'HZ_PARTY_SITES' THEN -- identify GrandParentBO when CP is parent of CPP, PS is parentOf CP
	  	   'PARTY_SITE'
	   ELSE NULL
	   END
	  FROM HZ_CONTACT_POINTS
	  WHERE contact_point_id =  PARENT_ID)
	WHEN 'HZ_PARTIES' THEN -- identify GrandParentBO when Party is parent of CPP
	  NULL
	WHEN 'HZ_PARTY_SITES' THEN -- identify GrandParentBO when PS is parent of CPP
     (SELECT
	   CASE party_type
  	    WHEN 'ORGANIZATION' THEN 'ORG'-- identify GrandParentBO when PS is parent of CPP, Org is parent of PS
	    WHEN 'PERSON' THEN 'PERSON' -- identify GrandParentBO when PS is parent of CPP, Per is parent of PS
		WHEN 'PARTY_RELATIONSHIP' THEN 'ORG_CONTACT' -- identify GrandParentBO when PS is parent of CPP, Rel is parent of PS
		ELSE NULL
		   END
	  FROM hz_parties
      WHERE party_id = (select party_id
	        from hz_party_sites
			where party_site_id = PARENT_ID))
    WHEN 'HZ_ORG_CONTACTS' THEN 'ORG' -- identify GrandParentBO when OrgContact is parent of CPP
	ELSE
	  NULL
	END parent_bo_code	-- this is the grand parent bo, written as parent bo
	FROM HZ_BUS_OBJ_TRACKING
	WHERE  CHILD_ENTITY_NAME = 'HZ_CONTACT_PREFERENCES'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND cprank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
  -- save the records populated
	COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'ei_HZ_CONTACT_PREFERENCES()-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_cpp');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message  => 'ei_HZ_CONTACT_PREFERENCES:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module    =>'ei_cpp');
	ROLLBACK;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ei_HZ_CONTACT_PREFERENCES;
-----------------------------------------------------------------
/*
Procedure name: ei_HZ_PARTY_SITES_EXT_VL()
Scope: external
Purpose: This procedure two activities on BOT table.
Writes the parent node record for HZ_PER_PROFILES_EXT_VL .
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------
PROCEDURE ei_HZ_PARTY_SITES_EXT_VL IS
	l_debug_prefix VARCHAR2(30) := 'PS_EXT:';
BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
	 (p_message=>'ei_HZ_PARTY_SITES_EXT_VL()+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_psext');
  END IF;
/*
  Following entities are parents of HZ_PARTY_SITES_EXT_VL
  1. HZ_PARTY_SITES

  Party Site has following parents
  1. HZ_PARTIES (Org, Person, OrgContact)

  Hence, HZ_PARTY_SITES_EXT_VL can exist in three different scenarios.
  The different combinations of (parent, grand parent) are :
  1. (PS, Org) 2. (PS, Person) 3. (PS, OrgContact)

  The following SQL gets the Parent and Grand parent info of each HZ_PARTY_SITES_EXT_VL
  record that was not already processed in BOT.

  Test Cases for the following SQL are:
  Create HZ_PARTY_SITES_EXT_VL rec in BOT with (Parent, Grand Parent)
	combinations existing in TCA data model
  1. (PS, Org) --
  2. (PS, Person) --
  3. (PS, OrgContact) --
*/
/* A note on the Structure of the insert statement
	 1. The parent record is tracked by the insert statement.
	 2. The "inner select" acts as a data source for "outer select"
	 3. The "outer select" uses "select to exclude the parents
	    that were already written to BOT"
	 4. There may be	duplicate rows for any given parent retured by the "inner select".
	    This is because, in a given execution of the following SQL,
			there may be multiple children for a given parent.

			Each child contributes in getting its parent. This is as per the design
			of "inner select".

			To avoid duplicate rows of a parent returned by the siblings,
			the inner select ranks all the parents duplicate parents.
			The "outer select" filters on parents with rank = 1.
			This clause helps to filter	out the duplicate parent rows,
			before data was inserted by insert statement.

	 5. The "inner select" is operating on the child record and trying to identify
	    the parent and grand parent information.
	    The parent information of the child record will be child
			(current/its) information for the parent record.
			The grand parent information of the child record will be parent info
			of the parent record.
			Because of this reason, "inner select" statement aliases the columns.

	6. It is non-trivial to figure out the business object codes for both parent
	   and grand parent, grand parent identifier or grand parent entity name.
  	 To do this, "inner select" uses case statement on parent_entity_name.
		 Some times, an embedded SQL is necessary to fgure out this.
	   Example:
	    Child is HZ_PARTY_SITES_EXT_VL.
	    Parent is PS  and it's parent is Party.
	    To figure out the grand parent bo code, SQL is necessary to run against
	    HZ_PARTIES to figure out the PARTY_TYPE based on PARTY_ID of the
	    HZ_PARTY_SITES table.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT    -- inner select
   PARENT_ENTITY_NAME child_entity_name
	 ,PARENT_ID child_id
   ,PARENT_BO_CODE CHILD_BO_CODE
   ,'U' child_operation_flag
   ,'Y' populated_flag
   ,LAST_UPDATE_DATE
	 ,RANK()
		 OVER (PARTITION BY PARENT_ENTITY_NAME, PARENT_ID
		       ORDER BY LAST_UPDATE_DATE, child_id) as psxrank
	,CASE PARENT_BO_CODE
	  WHEN 'PARTY_SITE' THEN
	 	(SELECT
		  CASE party_type
	 	  	WHEN 'ORGANIZATION' THEN 'HZ_PARTIES'
	 	  	WHEN 'PERSON' THEN 'HZ_PARTIES'
	 	  	WHEN 'PARTY_RELATIONSHIP' THEN 'HZ_ORG_CONTACTS'
	 	  	ELSE NULL
	 	  END
		 FROM HZ_PARTIES
		 WHERE party_id = (SELECT ps.party_id
		               FROM   HZ_PARTY_SITES ps
					 WHERE  ps.party_site_id = PARENT_ID))
		ELSE  NULL
		END parent_entity_name -- this is grand parent tbl name of CP - written as parent entity name
	,CASE PARENT_BO_CODE
     WHEN 'PARTY_SITE' THEN
     (SELECT
	   	CASE p.party_type
	  	  WHEN 'ORGANIZATION' THEN p.party_id
	  	  WHEN 'PERSON' THEN p.party_id
	  	  WHEN 'PARTY_RELATIONSHIP' THEN
		   (SELECT oc.org_contact_id
			  FROM hz_org_contacts oc,  HZ_RELATIONSHIPS r
			  WHERE r.relationship_id = oc.party_relationship_id
			  AND r.party_id = p.party_id
			  AND r.subject_type = 'PERSON'
			  AND r.object_type = 'ORGANIZATION')
	 	  ELSE NULL
	 	   END
	 	FROM hz_parties p
		WHERE p.party_id = (select ps.party_id
		                 from HZ_PARTY_SITES ps
						 where ps.party_site_id = PARENT_ID))
		ELSE  NULL
		END parent_id -- this is the grand parent id of ps extension - written as parent
	,CASE PARENT_BO_CODE
	  WHEN 'PARTY_SITE' THEN
      (SELECT
	   	CASE party_type
	 	  	  WHEN 'ORGANIZATION' THEN 'ORG'
	 	  	  WHEN 'PERSON' THEN 'PERSON'
	 	  	  WHEN 'PARTY_RELATIONSHIP' THEN 'ORG_CONTACT'
	 	  	  ELSE NULL
	 	 END
	 	FROM hz_parties
		WHERE party_id = (SELECT party_id
		                 FROM HZ_PARTY_SITES
						WHERE party_site_id = PARENT_ID))
		ELSE NULL
		END parent_bo_code	-- this is the grand parent bo, written as parent
	FROM HZ_BUS_OBJ_TRACKING
	WHERE CHILD_ENTITY_NAME = 'HZ_PARTY_SITES_EXT_VL'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND psxrank = 1
        AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
  -- save the records populated
	COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
	 (p_message=>'ei_HZ_PARTY_SITES_EXT_VL()-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_psext');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
     LOG( message  => 'ei_HZ_PARTY_SITES_EXT_VL:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module    =>'ei_psext');
	ROLLBACK;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ei_HZ_PARTY_SITES_EXT_VL;
-----------------------------------------------------------------
/*
Procedure name: ei_HZ_ORG_PROFILES_EXT_VL()
Scope: external
Purpose: This procedure two activities on BOT table.
Writes the parent node record for HZ_PER_PROFILES_EXT_VL .
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------
PROCEDURE ei_HZ_ORG_PROFILES_EXT_VL IS
	l_debug_prefix VARCHAR2(30) := 'ORG_PROF_EXT:';
BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'ei_HZ_ORG_PROFILES_EXT_VL()+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_oext');
  END IF;
/*
  Following entities are parents of HZ_ORG_PROFILES_EXT_VL
  1. HZ_PARTIES (Org)

  The following SQL gets the Parent and Grand parent info of each HZ_ORG_PROFILES_EXT_VL
  record that was not already processed in BOT.

  Test Cases for the following SQL are:
  Create HZ_ORG_PROFILES_EXT_VL rec in BOT with (Parent, Grand Parent)
	combinations existing in TCA data model
  1. (Org, null) --
*/

/* A note on the Structure of the insert statement
	 1. The parent record is tracked by the insert statement.
	 2. The "inner select" acts as a data source for "outer select"
	 3. The "outer select" uses "select to exclude the parents
	    that were already written to BOT"
	 4. There may be	duplicate rows for any given parent retured by the "inner select".
	    This is because, in a given execution of the following SQL,
			there may be multiple children for a given parent.

			Each child contributes in getting its parent. This is as per the design
			of "inner select".

			To avoid duplicate rows of a parent returned by the siblings,
			the inner select ranks all the parents duplicate parents.
			The "outer select" filters on parents with rank = 1.
			This clause helps to filter	out the duplicate parent rows,
			before data was inserted by insert statement.

	 5. The "inner select" is operating on the child record and trying to identify
	    the parent and grand parent information.
	    The parent information of the child record will be child
			(current/its) information for the parent record.
			The grand parent information of the child record will be parent info
			of the parent record.
			Because of this reason, "inner select" statement aliases the columns.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT   -- inner select
		PARENT_ENTITY_NAME child_entity_name
		,PARENT_ID child_id
		,PARENT_BO_CODE CHILD_BO_CODE
		,NULL parent_entity_name -- this is grand parent tbl name of acct site use, written as parent entity name
		,NULL parent_bo_code	-- this is the grand parent bo, written as parent
		,NULL parent_id -- this is grand parent id of acct roles, written as parent id
		,'U' child_operation_flag
		,'Y' populated_flag
		,t.LAST_UPDATE_DATE
		,RANK()
		OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
		     ORDER BY t.LAST_UPDATE_DATE, child_id) as ORGrank
		FROM HZ_BUS_OBJ_TRACKING t
		WHERE CHILD_ENTITY_NAME = 'HZ_ORG_PROFILES_EXT_VL'
		AND PARENT_BO_CODE = 'ORG'
		AND event_id IS NULL) temp
		WHERE NOT EXISTS
		(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
		  WHERE bot.event_id IS NULL
		    AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
		    AND bot.CHILD_ID = temp.child_id
		    AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND ORGrank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL     ;
  -- save the records populated
	COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'ei_HZ_ORG_PROFILES_EXT_VL()-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_oext');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message  => 'ei_HZ_ORG_PROFILES_EXT_VL:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module    =>'ei_oext');
	ROLLBACK;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ei_HZ_ORG_PROFILES_EXT_VL;
-----------------------------------------------------------------
/*
Procedure name: ei_HZ_PER_PROFILES_EXT_VL ()
Scope: external
Purpose: This procedure two activities on BOT table.
Writes the parent node record for HZ_PER_PROFILES_EXT_VL .
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------
PROCEDURE ei_HZ_PER_PROFILES_EXT_VL IS
	l_debug_prefix VARCHAR2(30) := 'PER_PROF_EXT:';
BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'ei_HZ_PER_PROFILES_EXT_VL()+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_pext');
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'pop per prof ext for person sharing',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_pext');
  END IF;
/*
The Person extenstion EO/API  will write
only one (HZ_PER_PROFILES_EXT_VL, Person) record in the BOT.

Because of Person Sharing concept in TCA Business Event System,
entries for HZ_PER_PROFILES_EXT_VL in BOT must be duplicated
as children Person_Contact.

This must be done before trying to figure out the missing links for
HZ_PER_PROFILES_EXT_VL.

Example:

Following record is written by Person extenstion EO/V2 API
Child id: 123  Child_entity_name: HZ_PER_PROFILES_EXT_VL
Parent id: 456 parent_entity_name: HZ_PARTIES, parent_bo: Person

This SQL writes:
Child id: 123  Child_entity_name: HZ_PER_PROFILES_EXT_VL
Parent id: 456 parent_entity_name: HZ_PARTIES, parent_bo: Person_contact

SQL Flow:
This SQL first identifies all those person parties that are contacts of
any organization and are parents of the HZ_PER_PROFILES_EXT_VL records in BOT.

/*
The Person extenstion EO/API  will write
only one (HZ_PER_PROFILES_EXT_VL, Person) record in the BOT.

Because of Person Sharing concept in TCA Business Event System,
entries for HZ_PER_PROFILES_EXT_VL in BOT must be duplicated
as children Person_Contact.

This must be done before trying to figure out the missing links for
HZ_PER_PROFILES_EXT_VL.

Example:

Following record is written by Person extenstion EO/V2 API
Child id: 123  Child_entity_name: HZ_PER_PROFILES_EXT_VL
Parent id: 456 parent_entity_name: HZ_PARTIES, parent_bo: Person

This SQL writes:
Child id: 123  Child_entity_name: HZ_PER_PROFILES_EXT_VL
Parent id: 456 parent_entity_name: HZ_PARTIES, parent_bo: Person_contact

SQL Flow:
This SQL first identifies all those person parties that are contacts of
any organization and are parents of the HZ_PER_PROFILES_EXT_VL records in BOT.

*/
INSERT INTO HZ_BUS_OBJ_TRACKING (
  CHILD_ID
  ,CHILD_BO_CODE
	,CHILD_ENTITY_NAME
	,CHILD_OPERATION_FLAG
	,POPULATED_FLAG
	,PARENT_ID
	,PARENT_ENTITY_NAME
	,PARENT_BO_CODE
	,LAST_UPDATE_DATE
	,CREATION_DATE)
SELECT DISTINCT
	p.CHILD_ID
	,p.CHILD_BO_CODE
	,p.CHILD_ENTITY_NAME
	,p.CHILD_OPERATION_FLAG
	,p.POPULATED_FLAG
	,p.PARENT_ID
	,p.PARENT_ENTITY_NAME
	,'PERSON_CONTACT' PARENT_BO_CODE
	,p.LAST_UPDATE_DATE
	,p.CREATION_DATE
	FROM
   (SELECT
		  CHILD_ID
		  ,CHILD_BO_CODE
			,CHILD_ENTITY_NAME
			,CHILD_OPERATION_FLAG
			,POPULATED_FLAG
			,PARENT_ID
			,PARENT_ENTITY_NAME
			,LAST_UPDATE_DATE
			,CREATION_DATE
		FROM	HZ_BUS_OBJ_TRACKING
		WHERE CHILD_ENTITY_NAME = 'HZ_PER_PROFILES_EXT_VL'
		AND parent_bo_code = 'PERSON'
		AND event_id IS NULL) p, hz_org_contacts oc, hz_relationships r
	WHERE p.PARENT_ID = r.subject_id
	AND r.subject_type = 'PERSON'
	AND r.object_type = 'ORGANIZATION'
	AND r.relationship_id = oc.party_relationship_id
	AND NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the records that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = p.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = p.child_id
	 AND bot.PARENT_ID  = 	 p.PARENT_ID
	 AND bot.PARENT_BO_CODE = 'PERSON_CONTACT');
 COMMIT;

/*
Following entities are parents of HZ_PER_PROFILES_EXT_VL
1. HZ_PARTIES (Person, Person_Contact)

Hence, HZ_PER_PROFILES_EXT_VL can exist in six different scenarios.
The different combinations of (parent, grand parent) are :
1. (Person, null) 2. (Person_Contact, OrgContact)

The following SQL gets the Parent and Grand parent info of each HZ_PER_PROFILES_EXT_VL
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_PER_PROFILES_EXT_VL rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (Person, null) -- Tested
2. (Person_Contact, OrgContact, Org) --
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the parents duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

 child record:
   child_id: 123, child_entity_name: HZ_PER_PROFILES_EXT_VL,
   child_bo: NULL, parent_bo: Person_Contact, parent_entity_name: HZ_PARTIES,
   parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_PARTIES
parent_bo aliased as child_bo: Person_Contact
grand_parent_id aliased as parent id: 456
grand_parent_entity_name aliased as parent_entity_name: HZ_ORG_CONTACTS
grand_parent_bo aliased as parent_bo: Org_Contact

Insert statement will take this result and write it as
 child record:
   child_id: 234, child_entity_name: HZ_PARTITES,
   child_bo: Person_Contact, parent_bo: Org_Contact, parent_entity_name: HZ_ORG_CONTACTS,
   parent_id: 456

Note: Two separate SQLs insert statements are necessary as a person can exist
  multiple times as an org_contact. So, when getting the org_contact_id,
  SQL will return the multiple rows. This makes is impossible to write
  it in one single SQL with CASE statements.

The following SQL is to generate all the parent and grand parent combination for
pp_extn entity which is a child of PERSON BO
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'pop missing lnks for per prof ext',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_pext');
  END IF;
  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
		 ,NULL parent_entity_name -- this is grand parent tbl name of acct site use, written as parent entity name
		 ,NULL parent_bo_code	-- this is the grand parent bo, written as parent
		 , NULL parent_id -- this is grand parent id of acct roles, written as parent id
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,t.LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY t.LAST_UPDATE_DATE, child_id) as acrrank
	FROM HZ_BUS_OBJ_TRACKING t
	WHERE  CHILD_ENTITY_NAME = 'HZ_PER_PROFILES_EXT_VL'
	AND PARENT_BO_CODE = 'PERSON'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
     AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
   AND acrrank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
COMMIT;
/* The following SQL is to generate all the parent and grand parent combination for
	 pp_extn entity which is a child of PERSON_CONTACT BO
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
		 ,'HZ_ORG_CONTACTS' parent_entity_name -- this is grand parent tbl name of acct site use, written as parent entity name
		 ,'ORG_CONTACT' parent_bo_code	-- this is the grand parent bo, written as parent
		 , oc.org_contact_id parent_id -- this is grand parent id of acct roles, written as parent id
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,t.LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY t.LAST_UPDATE_DATE, child_id) as acrrank
	FROM HZ_BUS_OBJ_TRACKING t, hz_relationships r, hz_org_contacts oc
	WHERE r.subject_id = PARENT_ID
	AND oc.party_relationship_id = r.relationship_id
	AND r.subject_type ='PERSON'
  AND r.object_type = 'ORGANIZATION'
	AND CHILD_ENTITY_NAME = 'HZ_PER_PROFILES_EXT_VL'
	AND PARENT_BO_CODE = 'PERSON_CONTACT'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND acrrank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
  -- save the records populated
	COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
	 (p_message=>'ei_HZ_PER_PROFILES_EXT_VL()-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_pext');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message  => 'ei_HZ_PER_PROFILES_EXT_VL:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_pext');
	ROLLBACK;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ei_HZ_PER_PROFILES_EXT_VL;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_PERSON_PROFILES()
Purpose: 	 Writes the parent node record for HZ_PERSON_PROFILES in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_PERSON_PROFILES IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_PERSON_PROFILES';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_PERSON_PROFILES+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_pp');
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'pop per prof ext for person sharing',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_pp');
  END IF;
/*
The Person Profile V2 API  will write
only one (HZ_PERSON_PROFILES, Person) record in the BOT.

Because of Person Sharing concept in TCA Business Event System,
entries for HZ_PERSON_PROFILES in BOT must be duplicated
as children Person_Contact.

This must be done before trying to figure out the missing links for
HZ_PERSON_PROFILES.

Example:

Following record is written by Person extenstion EO/V2 API
Child id: 123  Child_entity_name: HZ_PERSON_PROFILES
Parent id: 456 parent_entity_name: HZ_PARTIES, parent_bo: Person

This SQL writes:
Child id: 123  Child_entity_name: HZ_PERSON_PROFILES
Parent id: 456 parent_entity_name: HZ_PARTIES, parent_bo: Person_contact

SQL Flow:
This SQL first identifies all those person parties that are contacts of
any organization and are parents of the HZ_PERSON_PROFILES records in BOT.
*/

INSERT INTO HZ_BUS_OBJ_TRACKING (
  CHILD_ID
  ,CHILD_BO_CODE
	,CHILD_ENTITY_NAME
	,CHILD_OPERATION_FLAG
	,POPULATED_FLAG
	,PARENT_ID
	,PARENT_ENTITY_NAME
	,PARENT_BO_CODE
	,LAST_UPDATE_DATE
	,CREATION_DATE)
SELECT DISTINCT
	p.CHILD_ID
	,p.CHILD_BO_CODE
	,p.CHILD_ENTITY_NAME
	,p.CHILD_OPERATION_FLAG
	,p.POPULATED_FLAG
	,p.PARENT_ID
	,p.PARENT_ENTITY_NAME
	,'PERSON_CONTACT' PARENT_BO_CODE
	,p.LAST_UPDATE_DATE
	,p.CREATION_DATE
	FROM
   (SELECT
		  CHILD_ID
		  ,CHILD_BO_CODE
			,CHILD_ENTITY_NAME
			,CHILD_OPERATION_FLAG
			,POPULATED_FLAG
			,PARENT_ID
			,PARENT_ENTITY_NAME
			,LAST_UPDATE_DATE
			,CREATION_DATE
		FROM	HZ_BUS_OBJ_TRACKING
		WHERE CHILD_ENTITY_NAME = 'HZ_PERSON_PROFILES'
		AND parent_bo_code = 'PERSON'
		AND event_id IS NULL) p, hz_org_contacts oc, hz_relationships r
	WHERE p.PARENT_ID = r.subject_id
	AND r.subject_type = 'PERSON'
	AND r.object_type = 'ORGANIZATION'
	AND r.relationship_id = oc.party_relationship_id
	AND NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the records that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = p.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = p.child_id
	 AND bot.PARENT_ID  = 	 p.PARENT_ID
	 AND bot.PARENT_BO_CODE = 'PERSON_CONTACT');
	 COMMIT;

/*
Following entities are parents of HZ_PERSON_PROFILES
1. HZ_PARTIES (Person, Person_Contact)

Hence, HZ_PERSON_PROFILES can exist in 2 different scenarios.
The different combinations of (parent, grand parent) are :
1. (Person, null) 2. (Person_Contact, OrgContact)

The following SQL gets the Parent and Grand parent info of each HZ_PERSON_PROFILES
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_PERSON_PROFILES rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (Person, null) -- tested
2. (Person_Contact, OrgContact, Org) -- tested
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the parents duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

child record:
 child_id: 123, child_entity_name: HZ_PERSON_PROFILES,
 child_bo: NULL, parent_bo: Person_Contact, parent_entity_name: HZ_PARTIES,
 parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_PARTIES
parent_bo aliased as child_bo: Person_Contact
grand_parent_id aliased as parent id: 456
grand_parent_entity_name aliased as parent_entity_name: HZ_ORG_CONTACTS
grand_parent_bo aliased as parent_bo: Org_Contact

Insert statement will take this result and write it as
child record:
 child_id: 234, child_entity_name: HZ_PARTITES,
 child_bo: Person_Contact, parent_bo: Org_Contact, parent_entity_name: HZ_ORG_CONTACTS,
 parent_id: 456


Note: Two separate SQLs insert statements are necessary as a person can exist
multiple times as an org_contact. So, when getting the org_contact_id,
SQL will return the multiple rows. This makes is impossible to write
it in one single SQL with CASE statements.

The following SQL is to generate all the parent and grand parent combination for
person_profile entity which is a child of PERSON BO
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'pop missing lnks for per prof',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_pp');
  END IF;
  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
		 ,NULL parent_entity_name -- this is grand parent tbl name of acct site use, written as parent entity name
		 ,NULL parent_bo_code	-- this is the grand parent bo, written as parent
		 , NULL parent_id -- this is grand parent id of acct roles, written as parent id
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,t.LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY t.LAST_UPDATE_DATE, child_id) as pprank
	FROM HZ_BUS_OBJ_TRACKING t
	WHERE  CHILD_ENTITY_NAME = 'HZ_PERSON_PROFILES'
	AND PARENT_BO_CODE = 'PERSON'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
   AND pprank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
COMMIT;

/* The following SQL is to generate all the parent and grand parent combination for
	 person_profile entity which is a child of PERSON_CONTACT BO
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
		 ,'HZ_ORG_CONTACTS' parent_entity_name -- this is grand parent tbl name of acct site use, written as parent entity name
		 ,'ORG_CONTACT' parent_bo_code	-- this is the grand parent bo, written as parent
		 , oc.org_contact_id parent_id -- this is grand parent id of acct roles, written as parent id
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,t.LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY t.LAST_UPDATE_DATE, child_id) as pprank
	FROM HZ_BUS_OBJ_TRACKING t, hz_relationships r, hz_org_contacts oc
	WHERE r.subject_id = PARENT_ID
	AND oc.party_relationship_id = r.relationship_id
	AND r.subject_type ='PERSON'
  AND r.object_type = 'ORGANIZATION'
	AND CHILD_ENTITY_NAME = 'HZ_PERSON_PROFILES'
	AND PARENT_BO_CODE = 'PERSON_CONTACT'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND pprank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'ei_HZ_PERSON_PROFILES-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_pp');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message  => 'ei_HZ_PERSON_PROFILES:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_pp');
     ROLLBACK;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_PERSON_PROFILES;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_PARTY_SITE_USES()
Purpose: 	 Writes the parent node record for HZ_PARTY_SITE_USES in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_PARTY_SITE_USES IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_PARTY_SITE_USES';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_PARTY_SITE_USES+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_psu');
  END IF;
/*
Following entities are parents of HZ_PARTY_SITE_USES
1. HZ_PARTY_SITES (PARTY_SITE)

Hence, HZ_PARTY_SITE_USES can exist three different scenarios.
The different combinations of (parent, grand parent) are :
1. (PARTY_SITE, Person)
2. (PARTY_SITE, Organization)
3. (PARTY_SITE, OrgContact)

The following SQL gets the Parent and Grand parent info of each HZ_PARTY_SITE_USES
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_PARTY_SITE_USES rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (PARTY_SITE, Person) -- tested
2. (PARTY_SITE, Organization) -- tested
3. (PARTY_SITE, OrgContact, Org) -- tested
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the parents duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

child record:
 child_id: 123, child_entity_name: HZ_PARTY_SITE_USES,
 child_bo: NULL, parent_bo: PS, parent_entity_name: HZ_PARTY_SITES,
 parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_PARTY_SITES
parent_bo aliased as child_bo: PARTY_SITE
grand_parent_id aliased as parent id: 456
grand_parent_entity_name aliased as parent_entity_name: HZ_ORG_CONTACTS
grand_parent_bo aliased as parent_bo: Org_Contact

Insert statement will take this result and write it as
child record:
 child_id: 234, child_entity_name: HZ_PARTY_SITES,
 child_bo: PARTY_SITE, parent_bo: Org_Contact, parent_entity_name: HZ_ORG_CONTACTS,
 parent_id: 456

6. It is non-trivial to figure out the business object codes for both parent
and grand parent, grand parent identifier or grand parent entity name.
To do this, "inner select" uses case statement on parent_entity_name.
Some times, an embedded SQL is necessary to fgure out this.
Example:
Child is HZ_PARTY_SITE_USES.
Parent is PARTY_SITE  and it's parent is Org_Contact.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY LAST_UPDATE_DATE, child_id) as psurank
		,CASE PARENT_BO_CODE
			WHEN 'PARTY_SITE' THEN
			 	(SELECT
				  CASE party_type
			 	  	WHEN 'ORGANIZATION' THEN 'HZ_PARTIES'
			 	  	WHEN 'PERSON' THEN 'HZ_PARTIES'
			 	  	WHEN 'PARTY_RELATIONSHIP' THEN 'HZ_ORG_CONTACTS'
			 	  	ELSE NULL
			 	  END
				 FROM HZ_PARTIES
				 WHERE party_id = (SELECT ps.party_id
							               FROM   HZ_PARTY_SITES ps
														 WHERE  ps.party_site_id = PARENT_ID))
			ELSE NULL
			END parent_entity_name -- this is grand parent tbl name of Person extn - written as parent entity name
		,CASE PARENT_BO_CODE
			WHEN 'PARTY_SITE' THEN
	     (SELECT
			   	CASE p.party_type
		 	  	  WHEN 'ORGANIZATION' THEN p.party_id
		 	  	  WHEN 'PERSON' THEN p.party_id
		 	  	  WHEN 'PARTY_RELATIONSHIP' THEN
						 (SELECT oc.org_contact_id
						  FROM hz_org_contacts oc,  HZ_RELATIONSHIPS r
						  WHERE r.relationship_id = oc.party_relationship_id
						  AND r.party_id = p.party_id
						  AND r.subject_type = 'PERSON'
						  AND r.object_type = 'ORGANIZATION')
		 	  	  ELSE NULL
		 	    END
		 	  FROM hz_parties p
				WHERE p.party_id = (select ps.party_id
				                   from HZ_PARTY_SITES ps
													 where ps.party_site_id = PARENT_ID)
			 )
			ELSE  NULL
			END parent_id -- this is the grand parent id of Person extn - written as parent
		,CASE PARENT_BO_CODE
			WHEN 'PARTY_SITE' THEN
	     (SELECT
			   	CASE party_type
		 	  	  WHEN 'ORGANIZATION' THEN 'ORG'
		 	  	  WHEN 'PERSON' THEN 'PERSON'
		 	  	  WHEN 'PARTY_RELATIONSHIP' THEN 'ORG_CONTACT'
		 	  	  ELSE NULL
		 	    END
		 	  FROM hz_parties
				WHERE party_id = (SELECT party_id
				                  FROM HZ_PARTY_SITES
													WHERE party_site_id = PARENT_ID)
	     )
			ELSE  NULL
			END parent_bo_code	-- this is the grand parent bo, written as parent
	FROM HZ_BUS_OBJ_TRACKING
	WHERE  CHILD_ENTITY_NAME = 'HZ_PARTY_SITE_USES'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND psurank = 1
        AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_PARTY_SITE_USES-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_psu');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message  => 'ei_HZ_PARTY_SITE_USES:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_psu');
     ROLLBACK;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_PARTY_SITE_USES;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_PARTY_SITES()
Purpose: 	 Writes the parent node record for HZ_PARTY_SITES in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_PARTY_SITES IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_PARTY_SITES';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_PARTY_SITES+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_ps');
  END IF;
/*
Party Site has following parents
1. HZ_PARTIES (Org, Person, OrgContact)

Hence, HZ_PARTY_SITES can exist in 3 different scenarios.
The different combinations of (parent, grand parent) are :
1. (Org, null) 2. (Person, null) 3. (OrgContact, Org)

The following SQL gets the Parent and Grand parent info of each HZ_PARTY_SITES
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_PARTY_SITES rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (Org, null)  -- tested
2. (Person, null) -- tested
3. (OrgContact, Org) -- tested
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

child record:
 child_id: 123, child_entity_name: HZ_PARTY_SITES,
 child_bo: PS, parent_bo: OrgContact, parent_entity_name: OC,
 parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_ORG_CONTACTS
parent_bo aliased as child_bo: OrgContact
grand_parent_id aliased as parent id: 456
grand_parent_entity_name aliased as parent_entity_name: HZ_PARTIES
grand_parent_bo aliased as parent_bo: Org

Insert statement will take this result and write it as
child record:
 child_id: 234, child_entity_name: HZ_ORG_CONTACTS,
 child_bo: OrgContact, parent_bo: Org, parent_entity_name: HZ_PARTIES,
 parent_id: 456
6. It is non-trivial to figure out the business object codes for both parent
and grand parent, grand parent identifier or grand parent entity name.
To do this, "inner select" uses case statement on parent_entity_name.
Some times, an embedded SQL is necessary to fgure out this.
Example:
Child is HZ_PARTY_SITES.
Parent is OrgContact  and it's parent is an Org.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY LAST_UPDATE_DATE, child_id) as psrank
		,CASE PARENT_BO_CODE
			WHEN 'ORG' THEN NULL
			WHEN 'PERSON' THEN NULL
			WHEN 'ORG_CONTACT' THEN	'HZ_PARTIES'
			ELSE NULL
			END parent_entity_name -- this is grand parent tbl name of PS, written as parent entity name
		,CASE PARENT_BO_CODE
			WHEN 'ORG' THEN NULL
			WHEN 'PERSON' THEN NULL
			WHEN 'ORG_CONTACT' THEN
		   (SELECT r.object_id
			  FROM hz_relationships r, hz_org_contacts oc
				WHERE oc.org_contact_id = PARENT_ID
				  AND oc.party_relationship_id = r.relationship_id
				  AND subject_type ='PERSON'
					AND object_type = 'ORGANIZATION')
			ELSE NULL
			END parent_id -- this is grand parent id of PS, written as parent id
		,CASE PARENT_BO_CODE
			WHEN 'ORG' THEN NULL
			WHEN 'PERSON' THEN NULL
			WHEN 'ORG_CONTACT' THEN	'ORG'
			ELSE NULL
			END parent_bo_code	-- this is the grand parent bo, written as parent
	FROM HZ_BUS_OBJ_TRACKING
	WHERE  CHILD_ENTITY_NAME = 'HZ_PARTY_SITES'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND psrank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL     ;
   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_PARTY_SITES-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_ps');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message      => 'ei_HZ_PARTY_SITES:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_ps');
     ROLLBACK;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_PARTY_SITES;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_ORG_CONTACTS()
Purpose: 	 Writes the parent node record for HZ_ORG_CONTACTS in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_ORG_CONTACTS IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_ORG_CONTACTS';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_ORG_CONTACTS+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_oc');
  END IF;
/*
Party Site has following parents
1. HZ_PARTIES (Org)

The following SQL gets the Parent and Grand parent info of each HZ_ORG_CONTACTS
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_ORG_CONTACTS rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (Org, null)  -- tested
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
		(SELECT                                      -- inner select
			PARENT_ENTITY_NAME child_entity_name
			,PARENT_ID child_id
			,PARENT_BO_CODE CHILD_BO_CODE
			,'U' child_operation_flag
			,'Y' populated_flag
			,LAST_UPDATE_DATE
			,RANK()
				OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
				ORDER BY LAST_UPDATE_DATE, child_id) as ocrank
			, NULL parent_entity_name -- this is grand parent tbl name of PS, written as parent entity name
	  	, NULL parent_id -- this is grand parent id of PS, written as parent id
		  , NULL parent_bo_code	-- this is the grand parent bo, written as parent
		FROM HZ_BUS_OBJ_TRACKING
		WHERE  CHILD_ENTITY_NAME = 'HZ_ORG_CONTACTS'
		AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND ocrank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL     ;
   	   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_ORG_CONTACTS-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_oc');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message      => 'ei_HZ_ORG_CONTACTS:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_oc');
     ROLLBACK;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_ORG_CONTACTS;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_LOCATIONS_EXT()
Purpose: 	 Writes the parent node record for HZ_LOCATIONS_EXT_VL in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_LOCATIONS_ext IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'ei_HZ_LOCATIONS_EXT';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_LOCATIONS_ext+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_locext');
  END IF;
/*
  Following entities are parents of HZ_LOCATIONS_EXT_VL
  1. HZ_LOCATIONS (Location)

  The TCA Extensibility EOs will not write the parent (as child) record in BOT.

  The following SQL gets the Parent and Grand parent info of each HZ_LOCATIONS_EXT_VL
  record that was not already processed in BOT.

  Because of the requirment to support Location Sharing, there could be
  multiple parents for a given Location record.

  Test Cases for the following SQL are:
  Create HZ_LOCATIONS_EXT_VL rec in BOT with (Parent, Grand Parent)
	combinations existing in TCA data model
  1. (Location, Party Site 1) -- tested
  2. (Location, Party Site 2) -- tested
*/

/* A note on the Structure of the insert statement
	 1. The parent record is tracked by the insert statement.
	 2. The "inner select" acts as a data source for "outer select"
	 3. The "outer select" uses "select to exclude the parents
	    that were already written to BOT"
	 4. There may be	duplicate rows for any given parent retured by the "inner select".
	    This is because, in a given execution of the following SQL,
			there may be multiple children for a given parent.

			Each child contributes in getting its parent. This is as per the design
			of "inner select".

			To avoid duplicate rows of a parent returned by the siblings,
			the inner select ranks all the parents duplicate parents.
			The "outer select" filters on parents with rank = 1.
			This clause helps to filter	out the duplicate parent rows,
			before data was inserted by insert statement.

	 5. The "inner select" is operating on the child record and trying to identify
	    the parent and grand parent information.
	    The parent information of the child record will be child
			(current/its) information for the parent record.
			The grand parent information of the child record will be parent info
			of the parent record.
			Because of this reason, "inner select" statement aliases the columns.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
    (SELECT   -- inner select
     t.PARENT_ENTITY_NAME child_entity_name
    ,t.PARENT_ID child_id
    ,t.PARENT_BO_CODE CHILD_BO_CODE
    ,'U' child_operation_flag
    ,'Y' populated_flag
    ,t.LAST_UPDATE_DATE
    ,RANK()
    OVER (PARTITION BY PARENT_ENTITY_NAME, PARENT_ID
         ORDER BY t.LAST_UPDATE_DATE, child_id) as locxrank
    ,'HZ_PARTY_SITES' parent_entity_name -- this is grand parent tbl name of CP - written as parent entity name
    , 'PARTY_SITE' parent_bo_code	-- this is the grand parent bo, written as parent
    , ps.party_site_id parent_id
    FROM  HZ_BUS_OBJ_TRACKING t, hz_party_sites ps
    WHERE t.CHILD_ENTITY_NAME = 'HZ_LOCATIONS_EXT_VL'
    AND t.event_id IS NULL
    AND t.parent_id = ps.location_id) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE
   AND bot.parent_id = temp.parent_id)
	 AND locxrank = 1
        AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_LOCATIONS_ext-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_locext');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message      => 'ei_HZ_LOCATIONS_ext:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_locext');
     ROLLBACK;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_LOCATIONS_ext;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_LOCATIONS()
Purpose: 	 Writes the parent node record for HZ_LOCATIONS in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_LOCATIONS IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_LOCATIONS';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_LOCATIONS+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_loc');
  END IF;
/*
Following entities are parents of HZ_LOCATIONS
1. HZ_PARTY_SITES (PARTY_SITE)

Hence, HZ_LOCATIONS can exist three different scenarios.
The different combinations of (parent, grand parent) are :
1. (PARTY_SITE, Person)
2. (PARTY_SITE, Organization)
3. (PARTY_SITE, OrgContact)

The following SQL gets the Parent and Grand parent info of each HZ_LOCATIONS
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_LOCATIONS rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (PARTY_SITE, Person) -- tested
2. (PARTY_SITE, Organization) -- tested
3. (PARTY_SITE, OrgContact, Org) --tested
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the parents duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

child record:
 child_id: 123, child_entity_name: HZ_LOCATIONS,
 child_bo: LOCATION, parent_bo: PS, parent_entity_name: HZ_PARTY_SITES,
 parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_PARTY_SITES
parent_bo aliased as child_bo: PARTY_SITE
grand_parent_id aliased as parent id: 456
grand_parent_entity_name aliased as parent_entity_name: HZ_ORG_CONTACTS
grand_parent_bo aliased as parent_bo: Org_Contact

Insert statement will take this result and write it as
child record:
 child_id: 234, child_entity_name: HZ_PARTY_SITES,
 child_bo: PARTY_SITE, parent_bo: Org_Contact, parent_entity_name: HZ_ORG_CONTACTS,
 parent_id: 456

6. It is non-trivial to figure out the business object codes for both parent
and grand parent, grand parent identifier or grand parent entity name.
To do this, "inner select" uses case statement on parent_entity_name.
Some times, an embedded SQL is necessary to fgure out this.
Example:
Child is HZ_LOCATIONS.
Parent is PARTY_SITE  and it's parent is Org_Contact.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY LAST_UPDATE_DATE, child_id) as psurank
		,CASE PARENT_BO_CODE
			WHEN 'PARTY_SITE' THEN
			 	(SELECT
				  CASE party_type
			 	  	WHEN 'ORGANIZATION' THEN 'HZ_PARTIES'
			 	  	WHEN 'PERSON' THEN 'HZ_PARTIES'
			 	  	WHEN 'PARTY_RELATIONSHIP' THEN 'HZ_ORG_CONTACTS'
			 	  	ELSE NULL
			 	  END
				 FROM HZ_PARTIES
				 WHERE party_id = (SELECT ps.party_id
	               FROM   HZ_PARTY_SITES ps
				 WHERE  ps.party_site_id = PARENT_ID))
			ELSE NULL
			END parent_entity_name -- this is grand parent tbl name of Person extn - written as parent entity name
		,CASE PARENT_BO_CODE
			WHEN 'PARTY_SITE' THEN
	     (SELECT
		   	CASE p.party_type
	 	  	  WHEN 'ORGANIZATION' THEN p.party_id
	 	  	  WHEN 'PERSON' THEN p.party_id
	 	  	  WHEN 'PARTY_RELATIONSHIP' THEN
				 (SELECT oc.org_contact_id
				  FROM hz_org_contacts oc,  HZ_RELATIONSHIPS r
				  WHERE r.relationship_id = oc.party_relationship_id
				  AND r.party_id = p.party_id
				  AND r.subject_type = 'PERSON'
				  AND r.object_type = 'ORGANIZATION')
		 	  	  ELSE NULL
		 	    END
		 	  FROM hz_parties p
				WHERE p.party_id = (select ps.party_id
                   from HZ_PARTY_SITES ps
				 where ps.party_site_id = PARENT_ID)
			 )
			ELSE  NULL
			END parent_id -- this is the grand parent id of Person extn - written as parent
		,CASE PARENT_BO_CODE
			WHEN 'PARTY_SITE' THEN
	     (SELECT
			   	CASE party_type
		 	  	  WHEN 'ORGANIZATION' THEN 'ORG'
		 	  	  WHEN 'PERSON' THEN 'PERSON'
		 	  	  WHEN 'PARTY_RELATIONSHIP' THEN 'ORG_CONTACT'
		 	  	  ELSE NULL
		 	    END
		 	  FROM hz_parties
				WHERE party_id = (SELECT party_id
				                  FROM HZ_PARTY_SITES
													WHERE party_site_id = PARENT_ID)
	     )
			ELSE  NULL
			END parent_bo_code	-- this is the grand parent bo, written as parent
	FROM HZ_BUS_OBJ_TRACKING
	WHERE  CHILD_ENTITY_NAME = 'HZ_LOCATIONS'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND psurank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL     ;
   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_LOCATIONS-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_loc');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message      => 'ei_HZ_LOCATIONS:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_loc');
     ROLLBACK;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_LOCATIONS;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_CUST_SITE_USES_ALL()
Purpose: 	 Writes the parent node record for HZ_CUST_SITE_USES_ALL in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_CUST_SITE_USES_ALL IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_CUST_SITE_USES_ALL';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_CUST_SITE_USES_ALL+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_actsiteuse');
  END IF;
/*
HZ_CUST_SITE_USES_ALL has following parent
1. HZ_CUST_ACCT_SITES_ALL (CUST_ACCT_SITE)

Hence, HZ_CUST_SITE_USES_ALL can exist in 3 different scenarios.
The different combinations of (parent, grand parent) are :
1. (CUST_ACCT_SITE, CUST_ACCT)
2. (CUST_ACCT, PERSON_CUST)
3. (CUST_ACCT, ORG_CUST)

The following SQL gets the Parent and Grand parent info of each HZ_CUST_SITE_USES_ALL
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_CUST_SITE_USES_ALL rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (CUST_ACCT_SITE, CUST_ACCT) -- tested
2. (CUST_ACCT, PERSON_CUST) --  tested
3. (CUST_ACCT, ORG_CUST) -- tested
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

child record:
 child_id: 123, child_entity_name: HZ_CUST_SITE_USES_ALL,
 child_bo: CUST_ACCT_SITE_USE, parent_bo: CUST_ACCT_SITE, parent_entity_name: HZ_CUST_ACCT_SITES_ALL,
 parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_CUST_ACCT_SITES_ALL
parent_bo aliased as child_bo: CUST_ACCT_SITE
grand_parent_id aliased as parent id: 456
grand_parent_entity_name aliased as parent_entity_name: HZ_CUST_ACCOUNTS
grand_parent_bo aliased as parent_bo: CUST_ACCT

Insert statement will take this result and write it as
child record:
 child_id: 234, child_entity_name: HZ_CUST_ACCT_SITES_ALL,
 child_bo: CUST_ACCT_SITE, parent_bo: CUST_ACCT, parent_entity_name: HZ_CUST_ACCOUNTS,
 parent_id: 456
6. It is non-trivial to figure out the business object codes for both parent
and grand parent, grand parent identifier or grand parent entity name.
To do this, "inner select" uses case statement on parent_entity_name.
Some times, an embedded SQL is necessary to fgure out this.
Example:
Child is CUST_ACCT_SITE.
Parent is CUST_ACCT  and it's parent is ORG_CUST.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
		 ,'HZ_CUST_ACCOUNTS' parent_entity_name -- this is grand parent tbl name of acct site use, written as parent entity name
		 ,'CUST_ACCT' parent_bo_code	-- this is the grand parent bo, written as parent
		 , CUST_ACCOUNT_ID parent_id -- this is grand parent id of acct roles, written as parent id
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,t.LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY t.LAST_UPDATE_DATE, child_id) as acrrank
	FROM HZ_BUS_OBJ_TRACKING t, HZ_CUST_ACCT_SITES_ALL s
	WHERE  t.CHILD_ENTITY_NAME = 'HZ_CUST_SITE_USES_ALL'
	AND t.event_id IS NULL
	AND t.parent_id = s.CUST_ACCT_SITE_ID) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND acrrank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_CUST_SITE_USES_ALL-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_actsiteuse');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message      => 'ei_HZ_CUST_SITE_USES_ALL:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_actsiteuse');
     ROLLBACK;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_CUST_SITE_USES_ALL;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_CUST_ACCT_SITES_ALL()
Purpose: 	 Writes the parent node record for HZ_CUST_ACCT_SITES_ALL in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_CUST_ACCT_SITES_ALL IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_CUST_ACCT_SITES_ALL';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_CUST_ACCT_SITES_ALL+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_actsite');
  END IF;
/*
HZ_CUST_ACCT_SITES_ALL has following parent
1. HZ_CUST_ACCOUNTS (CUST_ACCT)

Hence, HZ_CUST_ACCT_SITES_ALL can exist in 2 different scenarios.
The different combinations of (parent, grand parent) are :
1. (CUST_ACCT, PERSON_CUST) --  tested
2. (CUST_ACCT, ORG_CUST) -- tested

The following SQL gets the Parent and Grand parent info of each HZ_CUST_ACCT_SITES_ALL
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_CUST_ACCT_SITES_ALL rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (CUST_ACCT, PERSON_CUST) --  tested
2. (CUST_ACCT, ORG_CUST) -- tested
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

child record:
 child_id: 123, child_entity_name: HZ_CUST_ACCT_SITES_ALL,
 child_bo: CUST_ACCT_SITE, parent_bo: CUST_ACCT, parent_entity_name: HZ_CUST_ACCOUNTS,
 parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_CUST_ACCOUNTS
parent_bo aliased as child_bo: CUST_ACCT
grand_parent_id aliased as parent id: 456
grand_parent_entity_name aliased as parent_entity_name: HZ_PARTIES
grand_parent_bo aliased as parent_bo: ORG_CUST

Insert statement will take this result and write it as
child record:
 child_id: 234, child_entity_name: HZ_CUST_ACCOUNTS,
 child_bo: CUST_ACCT, parent_bo: ORG_CUST, pa1rent_entity_name: HZ_PARTIES,
 parent_id: 456
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
		 ,'HZ_PARTIES' parent_entity_name -- this is grand parent tbl name of acct site use, written as parent entity name
		 ,DECODE(P.PARTY_TYPE, 'ORGANIZATION','ORG_CUST','PERSON','PERSON_CUST', NULL) parent_bo_code	-- this is the grand parent bo, written as parent
		 , ac.party_id parent_id -- this is grand parent id of acct roles, written as parent id
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,t.LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY t.LAST_UPDATE_DATE, child_id) as acrrank
	FROM HZ_BUS_OBJ_TRACKING t, HZ_CUST_ACCOUNTS ac, HZ_PARTIES p
	WHERE  t.CHILD_ENTITY_NAME = 'HZ_CUST_ACCT_SITES_ALL'
	AND t.event_id IS NULL
	AND t.parent_id = ac.CUST_ACCOUNT_ID
	AND ac.party_id = p.party_id) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND acrrank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
   	   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_CUST_ACCT_SITES_ALL-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_actsite');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
     ROLLBACK;
    LOG( message      => 'ei_HZ_CUST_ACCT_SITES_ALL:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_actsite');
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_CUST_ACCT_SITES_ALL;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_CUST_ACCOUNT_ROLES()
Purpose: 	 Writes the parent node record for HZ_CUST_ACCOUNT_ROLES in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_CUST_ACCOUNT_ROLES IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_CUST_ACCOUNT_ROLES';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_CUST_ACCOUNT_ROLES+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_actroles');
  END IF;
/*
Party Site has following parents
1. HZ_CUST_ACCT_SITES_ALL (CUST_ACCT_SITE)
2. HZ_CUST_ACCOUNTS (CUST_ACCT)

Hence, HZ_CUST_ACCOUNT_ROLES can exist in 3 different scenarios.
The different combinations of (parent, grand parent) are :
1. (CUST_ACCT_SITE, CUST_ACCT)
2. (CUST_ACCT, PERSON_CUST)
3. (CUST_ACCT, ORG_CUST)

The following SQL gets the Parent and Grand parent info of each HZ_CUST_ACCOUNT_ROLES
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_CUST_ACCOUNT_ROLES rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (CUST_ACCT_SITE, CUST_ACCT)  -- tested
2. (CUST_ACCT, PERSON_CUST) -- tested
3. (CUST_ACCT, ORG_CUST)  -- tested
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

child record:
 child_id: 123, child_entity_name: HZ_CUST_ACCOUNT_ROLES,
 child_bo: CUST_ACCT_CONTACT, parent_bo: CUST_ACCT_SITE, parent_entity_name: HZ_CUST_ACCT_SITES_ALL,
 parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_CUST_ACCT_SITES_ALL
parent_bo aliased as child_bo: CUST_ACCT_SITE
grand_parent_id aliased as parent id: 456
grand_parent_entity_name aliased as parent_entity_name: HZ_CUST_ACCOUNTS
grand_parent_bo aliased as parent_bo: CUST_ACCT

Insert statement will take this result and write it as
child record:
 child_id: 234, child_entity_name: HZ_CUST_ACCT_SITES_ALL,
 child_bo: CUST_ACCT_SITE, parent_bo: CUST_ACCT, parent_entity_name: HZ_CUST_ACCOUNTS,
 parent_id: 456
6. It is non-trivial to figure out the business object codes for both parent
and grand parent, grand parent identifier or grand parent entity name.
To do this, "inner select" uses case statement on parent_entity_name.
Some times, an embedded SQL is necessary to fgure out this.
Example:
Child is HZ_CUST_ACCOUNT_ROLES.
Parent is CUST_ACCT_SITE  and it's parent is CUST_ACCT.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
   CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
   PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
    CHILD_OPERATION_FLAG, POPULATED_FLAG,
    LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
   FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY LAST_UPDATE_DATE, child_id) as acrrank
		,CASE PARENT_BO_CODE
			WHEN 'CUST_ACCT_SITE' THEN 'HZ_CUST_ACCOUNTS'
			WHEN 'CUST_ACCT' THEN 'HZ_PARTIES'
			ELSE NULL
			END parent_entity_name -- this is grand parent tbl name of acct roles, written as parent entity name
		,CASE PARENT_BO_CODE
			WHEN 'CUST_ACCT_SITE' THEN
			(SELECT CUST_ACCOUNT_ID
			 FROM HZ_CUST_ACCT_SITES_ALL
			 WHERE CUST_ACCT_SITE_ID = PARENT_ID)
			WHEN 'CUST_ACCT' THEN
		   (SELECT PARTY_ID
			  FROM HZ_CUST_ACCOUNTS
				WHERE CUST_ACCOUNT_ID = PARENT_ID)
			ELSE NULL
			END parent_id -- this is grand parent id of acct roles, written as parent id
		,CASE PARENT_BO_CODE
			WHEN 'CUST_ACCT_SITE' THEN 'CUST_ACCT'
			WHEN 'CUST_ACCT' THEN
             (SELECT
			   	CASE p.party_type
		 	  	  WHEN 'ORGANIZATION' THEN 'ORG_CUST'
		 	  	  WHEN 'PERSON' THEN 'PERSON_CUST'
		 	  	  ELSE NULL
		 	    END
		 	  FROM hz_parties p, HZ_CUST_ACCOUNTS c
				WHERE p.party_id = c.party_id
				AND c.CUST_ACCOUNT_ID = PARENT_ID)
			ELSE NULL
			END parent_bo_code	-- this is the grand parent bo, written as parent
	FROM HZ_BUS_OBJ_TRACKING
	WHERE  CHILD_ENTITY_NAME = 'HZ_CUST_ACCOUNT_ROLES'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
     AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
     AND acrrank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_CUST_ACCOUNT_ROLES-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_actroles');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
     ROLLBACK;
    LOG( message      => 'ei_HZ_CUST_ACCOUNT_ROLES:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_actroles');
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_CUST_ACCOUNT_ROLES;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_CUST_ACCOUNTS()
Purpose: 	 Writes the parent node record for HZ_CUST_ACCOUNTS in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_CUST_ACCOUNTS IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_CUST_ACCOUNTS';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_CUST_ACCOUNTS+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_act');
  END IF;
/*
HZ_CUST_ACCOUNTS has following parents
1. HZ_PARTIES (ORG_CUST)
2. HZ_PARTIES (PERSON_CUST)

Hence, HZ_CUST_ACCOUNTS can exist in 2 different scenarios.
The different combinations of (parent, grand parent) are :
1. (ORG_CUST, NULL)
2. (PERSON_CUST, NULL)

The following SQL gets the Parent and Grand parent info of each HZ_CUST_ACCOUNTS
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_CUST_ACCOUNTS rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (ORG_CUST, NULL) -- tested
2. (PERSON_CUST, NULL) -- tested
*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

child record:
 child_id: 123, child_entity_name: HZ_CUST_ACCOUNTS,
 child_bo: CUST_ACCT, parent_bo: ORG_CUST_ACCT, parent_entity_name: HZ_PARTIES,
 parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_PARTIES
parent_bo aliased as child_bo: ORG_CUST
grand_parent_id aliased as parent id: null
grand_parent_entity_name aliased as parent_entity_name: null
grand_parent_bo aliased as parent_bo: null

Insert statement will take this result and write it as
child record:
 child_id: 234, child_entity_name: HZ_PARTIES,
 child_bo: ORG_CUST, parent_bo: NULL, pa1rent_entity_name: NULL,
 parent_id: NULL
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
	 FROM
	(SELECT                                      -- inner select
	   PARENT_ENTITY_NAME child_entity_name
		 ,PARENT_ID child_id
	   ,PARENT_BO_CODE CHILD_BO_CODE
		 ,NULL parent_entity_name -- this is grand parent tbl name of acct site use, written as parent entity name
		 ,NULL parent_bo_code	-- this is the grand parent bo, written as parent
		 , NULL parent_id -- this is grand parent id of acct roles, written as parent id
     ,'U' child_operation_flag
	   ,'Y' populated_flag
	   ,t.LAST_UPDATE_DATE
		 ,RANK()
			 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
			       ORDER BY t.LAST_UPDATE_DATE, child_id) as acrrank
	FROM HZ_BUS_OBJ_TRACKING t
	WHERE  t.CHILD_ENTITY_NAME = 'HZ_CUST_ACCOUNTS'
	AND t.event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
     AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
     AND acrrank = 1
     AND temp.child_id IS NOT NULL
     AND temp.CHILD_ENTITY_NAME IS NOT NULL
     AND temp.CHILD_BO_CODE IS NOT NULL;
   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_CUST_ACCOUNTS-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_act');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
   LOG( message      => 'ei_HZ_CUST_ACCOUNTS:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'ei_act');
     ROLLBACK;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_CUST_ACCOUNTS;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_CUSTOMER_PROFILES()
Purpose: 	 Writes the parent node record for HZ_CUSTOMER_PROFILES in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_CUSTOMER_PROFILES IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_CUSTOMER_PROFILES';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_CUSTOMER_PROFILES+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_custprof');
  END IF;
/*
Party Site has following parents
1. HZ_CUST_ACCT_SITE_USES_ALL (CUST_ACCT_SITE_USE)
2. HZ_CUST_ACCOUNTS (CUST_ACCT)

Hence, HZ_CUSTOMER_PROFILES can exist in 4 different scenarios.
The different combinations of (parent, grand parent) are :
1. (CUST_ACCT_SITE_USE, CUST_ACCT_SITE)
2. (CUST_ACCT, PERSON_CUST)
3. (CUST_ACCT, ORG_CUST)
4. (CUST_ACCT_SITE,CUST_ACCT)

The following SQL gets the Parent and Grand parent info of each HZ_CUSTOMER_PROFILES
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_CUSTOMER_PROFILES rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (CUST_ACCT_SITE_USE, CUST_ACCT_SITE) -- tested
2. (CUST_ACCT, PERSON_CUST) -- tested
3. (CUST_ACCT, ORG_CUST) -- tested
4. (CUST_ACCT_SITE,CUST_ACCT) -- tested

*/

/* A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
This is because, in a given execution of the following SQL,
there may be multiple children for a given parent.

Each child contributes in getting its parent. This is as per the design
of "inner select".

To avoid duplicate rows of a parent returned by the siblings,
the inner select ranks all the duplicate parents.
The "outer select" filters on parents with rank = 1.
This clause helps to filter	out the duplicate parent rows,
before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
the parent and grand parent information.
The parent information of the child record will be child
(current/its) information for the parent record.
The grand parent information of the child record will be parent info
of the parent record.
Because of this reason, "inner select" statement aliases the columns.

example:

child record:
 child_id: 123, child_entity_name: HZ_CUSTOMER_PROFILES,
 child_bo: CUST_PROFILE, parent_bo: CUST_ACCT_SITE_USE, parent_entity_name: HZ_CUST_ACCT_SITE_USES_ALL,
 parent_id: 234

The "inner select"  fetches above record from BOT and identifies
its parent, grand parent information and present it as follows:

parent_id aliased as child_id: 234
parent_entity_name aliased as child_entity_name: HZ_CUST_ACCT_SITE_USES_ALL
parent_bo aliased as child_bo: CUST_ACCT_SITE_USE
grand_parent_id aliased as parent id: 456
grand_parent_entity_name aliased as parent_entity_name: HZ_CUST_ACCT_SITES_ALL
grand_parent_bo aliased as parent_bo: CUST_ACCT_SITE

Insert statement will take this result and write it as
child record:
 child_id: 234, child_entity_name: HZ_CUST_ACCT_SITE_USES_ALL,
 child_bo: CUST_ACCT_SITE_USE, parent_bo: CUST_ACCT_SITE, parent_entity_name: HZ_CUST_ACCT_SITES_ALL,
 parent_id: 456
6. It is non-trivial to figure out the business object codes for both parent
and grand parent, grand parent identifier or grand parent entity name.
To do this, "inner select" uses case statement on parent_entity_name.
Some times, an embedded SQL is necessary to fgure out this.
Example:
Child is HZ_CUSTOMER_PROFILES.
Parent is CUST_ACCT_SITE_USE  and it's parent is CUST_ACCT_SITE.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
	 PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
  FROM
	(SELECT                                      -- inner select
	  PARENT_ENTITY_NAME child_entity_name
	 ,PARENT_ID child_id
	  ,PARENT_BO_CODE CHILD_BO_CODE
     ,'U' child_operation_flag
	  ,'Y' populated_flag
	  ,LAST_UPDATE_DATE
	 ,RANK()
		 OVER (PARTITION BY PARENT_BO_CODE, PARENT_ID
	       ORDER BY LAST_UPDATE_DATE, child_id) as acrrank
	,CASE PARENT_BO_CODE
		WHEN 'CUST_ACCT_SITE_USE' THEN 'HZ_CUST_ACCT_SITES_ALL'
		WHEN 'CUST_ACCT' THEN 'HZ_PARTIES'
		ELSE NULL
		END parent_entity_name -- this is grand parent tbl name of acct roles, written as parent entity name
	,CASE PARENT_BO_CODE
		WHEN 'CUST_ACCT_SITE_USE' THEN
		(SELECT CUST_ACCT_SITE_ID
		 FROM HZ_CUST_SITE_USES_ALL
		 WHERE SITE_USE_ID = PARENT_ID)
		WHEN 'CUST_ACCT' THEN
	   (SELECT PARTY_ID
		  FROM HZ_CUST_ACCOUNTS
			WHERE CUST_ACCOUNT_ID = PARENT_ID)
		ELSE NULL
		END parent_id -- this is grand parent id of acct roles, written as parent id
	,CASE PARENT_BO_CODE
		WHEN 'CUST_ACCT_SITE_USE' THEN 'CUST_ACCT_SITE'
		WHEN 'CUST_ACCT' THEN
           (SELECT
		   	CASE p.party_type
		  	  WHEN 'ORGANIZATION' THEN 'ORG_CUST'
		  	  WHEN 'PERSON' THEN 'PERSON_CUST'
		  	  ELSE NULL
		     END
		     FROM hz_parties p, HZ_CUST_ACCOUNTS c
			 WHERE p.party_id = c.party_id
			 AND c.CUST_ACCOUNT_ID = PARENT_ID)
		 ELSE NULL
		END parent_bo_code	-- this is the grand parent bo, written as parent
	FROM HZ_BUS_OBJ_TRACKING
	WHERE  CHILD_ENTITY_NAME = 'HZ_CUSTOMER_PROFILES'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
	 AND acrrank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL     ;
   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'ei_HZ_CUSTOMER_PROFILES-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_custprof');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
   LOG( message      => 'ei_HZ_CUSTOMER_PROFILES:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   => 'ei_custprof');
     ROLLBACK;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_CUSTOMER_PROFILES;
-----------------------------------------------------------------
/*
Procedure name:  PROCEDURE ei_HZ_CONTACT_POINTS()
Purpose: 	 Writes the parent node record for HZ_CONTACT_POINTS in BOT
Scope: internal
Called From: This pkg
Called By: populate_missing_links()
*/
-----------------------------------------------------------------

  PROCEDURE ei_HZ_CONTACT_POINTS IS

 -- local variables
 l_debug_prefix VARCHAR2(40) := 'EI_HZ_CONTACT_POINTS';
	l_module VARCHAR2(30) := 'ei_cp';
 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'ei_HZ_CONTACT_POINTS+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_cp');
  END IF;

/*
Following entities are parents of HZ_CONTACT_POINTS
1. HZ_PARTIES (Org, Person, OrgContact)
2. HZ_PARTY_SITES

Party Site has following parents
1. HZ_PARTIES (Org, Person, OrgContact)

Hence, contact point can exist in six different scenarios.
The different combinations of (parent, grand parent) are :
1. (Org, null) 2. (Person, null) 3. (OrgContact, Org) 4. (PS, Org) 5. (PS, Person)
6. (PS, OrgContact)

The following SQL gets the Parent and Grand parent info of each HZ_CONTACT_POINTS
record that was not already processed in BOT.

Test Cases for the following SQL are:
Create HZ_CONTACT_POINTS rec in BOT with (Parent, Grand Parent)
combinations existing in TCA data model
1. (Org, null)  -- tested
2. (Person, null) -- tested
3. (OrgContact, Org) -- tested
4. (PS, Org) -- tested
5. (PS, Person) -- tested
6. (PS, OrgContact) -- tested

A note on the Structure of the insert statement
1. The parent record is tracked by the insert statement.
2. The "inner select" acts as a data source for "outer select"
3. The "outer select" uses "select to exclude the parents
  that were already written to BOT"
4. There may be	duplicate rows for any given parent retured by the "inner select".
  This is because, in a given execution of the following SQL,
	there may be multiple children for a given parent.

	Each child contributes in getting its parent. This is as per the design
	of "inner select".

	To avoid duplicate rows of a parent returned by the siblings,
	the inner select ranks all the parents duplicate parents.
	The "outer select" filters on parents with rank = 1.
	This clause helps to filter	out the duplicate parent rows,
	before data was inserted by insert statement.

5. The "inner select" is operating on the child record and trying to identify
  the parent and grand parent information.
  The parent information of the child record will be child
	(current/its) information for the parent record.
	The grand parent information of the child record will be parent info
	of the parent record.
	Because of this reason, "inner select" statement aliases the columns.

	example:

	 child record:
	   child_id: 123, child_entity_name: HZ_CONTACT_POINTS,
	   child_bo: Phone, parent_bo: PS, parent_entity_name: PS,
	   parent_id: 234

  The "inner select"  fetches above record from BOT and identifies
  its parent, grand parent information and present it as follows:

  parent_id aliased as child_id: 234
  parent_entity_name aliased as child_entity_name: HZ_PARTY_SITES
  parent_bo aliased as child_bo: PS
  grand_parent_id aliased as parent id: 456
  grand_parent_entity_name aliased as parent_entity_name: HZ_PARTIES
  grand_parent_bo aliased as parent_bo: Org

  Insert statement will take this result and write it as
	 child record:
	   child_id: 234, child_entity_name: HZ_PARTY_SITES,
	   child_bo: PS, parent_bo: Org, parent_entity_name: HZ_PARTIES,
	   parent_id: 456
6. It is non-trivial to figure out the business object codes for both parent
 and grand parent, grand parent identifier or grand parent entity name.
 To do this, "inner select" uses case statement on parent_entity_name.
 Some times, an embedded SQL is necessary to fgure out this.
 Example:
  Child is HZ_CONTACT_POINTS.
  Parent is PS  and it's parent is Party.
  To figure out the grand parent bo code, SQL is necessary to run against
  HZ_PARTIES to figure out the PARTY_TYPE based on PARTY_ID of the
  HZ_PARTY_SITES table.
*/

  INSERT INTO HZ_BUS_OBJ_TRACKING
  (CHILD_ENTITY_NAME, CHILD_ID,
	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE,
	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, CREATION_DATE)
  SELECT CHILD_ENTITY_NAME, CHILD_ID,  -- outer select
   CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, PARENT_ENTITY_NAME,
   PARENT_ID, PARENT_BO_CODE, G_CREATION_DATE CREATION_DATE
  FROM
  (SELECT                                      -- inner select
    PARENT_ENTITY_NAME child_entity_name
   ,PARENT_ID child_id
   ,PARENT_BO_CODE CHILD_BO_CODE
   ,'U' child_operation_flag
   ,'Y' populated_flag
   ,LAST_UPDATE_DATE
   ,RANK()
	 OVER (PARTITION BY PARENT_ENTITY_NAME, PARENT_ID
	       ORDER BY LAST_UPDATE_DATE, child_id) as cprank
   ,CASE PARENT_BO_CODE
	WHEN 'ORG' THEN NULL -- identify the GrandParentEntityName when Org is parentBO of CP
	WHEN 'PERSON' THEN NULL -- identify the GrandParentEntityName when Per is parentBO of CP
	WHEN 'ORG_CONTACT' THEN -- identify the GrandParentEntityName when orgContact is parentBO of CP
		'HZ_PARTIES'
	WHEN 'PARTY_SITE' THEN -- identify the GrandParentEntityName when PS is parentBO of CP
     (SELECT
       CASE party_type
        WHEN 'ORGANIZATION' THEN 'HZ_PARTIES' -- identify the GrandParentEntityName when PS is parentBO of CP, when Org is parentOf PS
        WHEN 'PERSON' THEN 'HZ_PARTIES' -- identify the GrandParentEntityName when PS is parentBO of CP, when Per is parentOf PS
        WHEN 'PARTY_RELATIONSHIP' THEN 'HZ_ORG_CONTACTS' -- identify the GrandParentEntityName when PS is parentBO of CP, when orgContact is parentOf PS
        ELSE NULL
       END
      FROM HZ_PARTIES
      WHERE party_id = (SELECT ps.party_id
         FROM   HZ_PARTY_SITES ps
		 WHERE  ps.party_site_id = PARENT_ID))
    ELSE	 NULL
	END parent_entity_name -- this is grand parent tbl name of CP - written as parent entity name
   ,CASE PARENT_BO_CODE -- to identify the grandParentEntityId of CP
  	 WHEN 'ORG' THEN NULL -- to identify the grandParentEntityId of CP when Org is parentOf CP
	 WHEN 'PERSON' THEN NULL -- to identify the grandParentEntityId of CP when Per is parentOf CP
	 WHEN 'ORG_CONTACT' THEN -- to identify the grandParentEntityId of CP when Rel is parentOf CP
	 (SELECT r.object_id
	  FROM hz_relationships r, hz_org_contacts oc
	  WHERE oc.org_contact_id = PARENT_ID
	  AND oc.party_relationship_id = r.relationship_id
	  AND subject_type ='PERSON'
	  AND object_type = 'ORGANIZATION')
	 WHEN 'PARTY_SITE' THEN -- to identify the grandParentEntityId of CP when PS is parentOf CP
      (SELECT
	   	CASE p.party_type
	     WHEN 'ORGANIZATION' THEN p.party_id -- to identify the grandParentEntityId of CP when PS is parentOf CP, when Org is parentOF PS
         WHEN 'PERSON' THEN p.party_id -- to identify the grandParentEntityId of CP when PS is parentOf CP, when Per is parentOF PS
		 WHEN 'PARTY_RELATIONSHIP' THEN -- to identify the grandParentEntityId of CP when PS is parentOf CP, when Rel is parentOF PS
		  (SELECT oc.org_contact_id
		    FROM hz_org_contacts oc,  HZ_RELATIONSHIPS r
			WHERE r.relationship_id = oc.party_relationship_id
			 AND r.party_id = p.party_id
			 AND r.subject_type = 'PERSON'
			 AND r.object_type = 'ORGANIZATION')
		 ELSE NULL
	      END
        FROM hz_parties p
		WHERE p.party_id = (select ps.party_id
           from HZ_PARTY_SITES ps
		   where ps.party_site_id = PARENT_ID))
     ELSE  NULL
		END parent_id -- this is the grand parent id of cont pref - written as parent
    ,CASE PARENT_BO_CODE -- to identify the grandParentBO of CP
     WHEN 'ORG' THEN NULL -- to identify the grandParentBO of CP when Org is Parent
	 WHEN 'PERSON' THEN NULL -- to identify the grandParentBO of CP when Per is Parent
	 WHEN 'ORG_CONTACT' THEN 'ORG' -- to identify the grandParentBO of CP when OrgConatct is Parent
	 WHEN 'PARTY_SITE' THEN -- to identify the grandParentBO of CP when PS is Parent
	  (SELECT
	   	CASE party_type
	  	  WHEN 'ORGANIZATION' THEN 'ORG'
	  	  WHEN 'PERSON' THEN 'PERSON'
 	  	  WHEN 'PARTY_RELATIONSHIP' THEN 'ORG_CONTACT'
 	  	  ELSE NULL
	 	  END
 	   FROM hz_parties
       WHERE party_id = (SELECT party_id
		  FROM HZ_PARTY_SITES
		  WHERE party_site_id = PARENT_ID))
	 ELSE  NULL
		END parent_bo_code	-- this is the grand parent bo, written as parent
	FROM HZ_BUS_OBJ_TRACKING
	WHERE  CHILD_ENTITY_NAME = 'HZ_CONTACT_POINTS'
	AND event_id IS NULL) temp
	WHERE NOT EXISTS
	(SELECT 1 FROM HZ_BUS_OBJ_TRACKING bot --select to exclude the parents that were already written to BOT
	 WHERE bot.event_id IS NULL
	 AND bot.CHILD_ENTITY_NAME = temp.CHILD_ENTITY_NAME
	 AND bot.CHILD_ID = temp.child_id
   AND bot.CHILD_BO_CODE = temp.CHILD_BO_CODE)
   AND cprank = 1
   AND temp.child_id IS NOT NULL
   AND temp.CHILD_ENTITY_NAME IS NOT NULL
   AND temp.CHILD_BO_CODE IS NOT NULL;
   -- save the records populated
   COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'ei_HZ_CONTACT_POINTS-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'ei_cp');
  END IF;

EXCEPTION
 WHEN OTHERS THEN
  LOG( message      => 'ei_HZ_CONTACT_POINTS:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
  ROLLBACK;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END ei_HZ_CONTACT_POINTS;
------------------------------------------------------------------------------
	PROCEDURE set_prof_var IS
   BEGIN
   	IF G_BO_PROF_VAL IS NULL THEN
		 G_BO_PROF_VAL :=  FND_PROFILE.value('HZ_EXECUTE_API_CALLOUTS');
    END IF;
   EXCEPTION
	 WHEN others THEN
		hz_utility_v2pub.debug(p_message=>sqlerrm,
		                       p_prefix=>g_debug_prefix,
	    			               p_msg_level=>fnd_log.level_procedure);
   END set_prof_var; -- set_prof_var


FUNCTION get_prof_val RETURN VARCHAR2 IS
BEGIN
  RETURN FND_PROFILE.value( 'HZ_EXECUTE_API_CALLOUTS');
EXCEPTION
 WHEN others THEN
  hz_utility_v2pub.debug(p_message=>sqlerrm,
	p_prefix=>g_debug_prefix,
	p_msg_level=>fnd_log.level_procedure);
END get_prof_val; -- get_prof_val
----------------------------------------------------------------------
/*
Procedure name: entity_in_bo
Scope: external
Purpose: Given a Top level BO (Org, Person, Org Cust, Person Cust),
an EBO and child entity name, this function will return TRUE if teh EBO
and entity combination is mandatory child of the BO.
Called From: BOD package
Called By:  This is called from BOD Update API.
Note: Based on the response from this function, BOD Update API will
decide whether to update the BO version of the top level BO.
*/
----------------------------------------------------------------------
procedure entity_in_bo (p_bo_code      IN VARCHAR2,
                       p_ebo_code      IN VARCHAR2,
	               p_child_bo_code IN VARCHAR2,
	               p_entity_name   IN VARCHAR2,
                       x_return_status OUT NOCOPY  BOOLEAN) IS

  CURSOR c_chk_entity (c_bo_code      IN VARCHAR2,
                       c_entity_name  IN VARCHAR2,
                       c_node_path    IN VARCHAR2) IS

  SELECT 1
   FROM (
    SELECT	BUSINESS_OBJECT_CODE bo_code, CHILD_BO_CODE,ENTITY_NAME,
        sys_connect_by_path(BUSINESS_OBJECT_CODE, '/') node_path,
    CONNECT_BY_ISLEAF isleaf
	FROM hz_bus_obj_definitions
	START WITH BUSINESS_OBJECT_CODE = c_bo_code
	CONNECT BY PRIOR CHILD_BO_CODE  = BUSINESS_OBJECT_CODE
  )
	WHERE
  isleaf = 1
 AND entity_name  = c_entity_name
 AND node_path LIKE c_node_path
 AND ROWNUM <2;

  -- local variables
  l_num NUMBER;
  l_node VARCHAR2(500);
  l_debug_prefix VARCHAR2(30) := 'idntfyEntyInBO:';
  l_module VARCHAR2(30) := 'entity_in_bo';
  l_cbo_null_flag BOOLEAN := FALSE;
  l_samebo_flag BOOLEAN := FALSE;

BEGIN
  -- check to see all the following parameters are passed or not.
  -- p_bo_code - this is high level BO object PERSON, PERSON_CUST, ORG, ORG_CUST
  -- p_ebo_code -- this is the EBO code.
  -- p_child_bo_code -- this is the EBO code. This is not mandatory
  -- p_entity_name -- this is the entity name
/*
 logic:
   Idea here is to check if the entire object hierarchy exists in a given high
   level Business Object (PERSON, PERSON_CUST, ORG, ORG_CUST).
   This can only be checked if all the available nodes in the hierarchy are given.

Example - A
  Object hieararchy given is, Org_Contact->Party_Site->Location->HZ_LOCATIONS_EXT_VL
  If the entire hierarchy must be validated for high level Business Object BO_CODE passed.
  If the BO_CODE is Person, this function must return FALSE.
Example - B
  Object hieararchy given is, Person->HZ_EDUCATION

-- flow
1. check if all the mandatory parameters are passed
2. check to see if the EBO and CHILD_BO combination exists in the BO_CODE.
   2.1 if the combination exists then
         check if CHILD_BO, ENTITY_NAME combo exists in BO_CODE
          IF TRUE - RETURN TRUE. IF FALSE, RETURN FALSE.
   2.2  if the combination does not exist, return FALSE
3. if the CHILD_BO is null, check if EBO, ENTITY_NAME combo exists in BO_CODE
   3.1 if the combination exists then, RETURN TRUE.
   3.2  if the combination does not exist, return FALSE
*/

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'entity_in_bo()+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr validating parameters',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;
  -- P_BO_CODE, p_ebo_code, p_entity_name must be not null
  IF (p_bo_code IS NULL) THEN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    	hz_utility_v2pub.DEBUG
    	 (p_message=>'p_bo_code mandatory param is null',
    	  p_prefix=>l_debug_prefix,
    	  p_msg_level=>fnd_log.level_procedure,
        p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
        p_module   =>l_module);
    	hz_utility_v2pub.DEBUG
    	 (p_message=>'entity_in_bo()-',
    	  p_prefix=>l_debug_prefix,
    	  p_msg_level=>fnd_log.level_procedure,
        p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
        p_module   =>l_module);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (p_ebo_code IS NULL) THEN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    	hz_utility_v2pub.DEBUG
    	 (p_message=>'p_ebo_code mandatory param is null',
    	  p_prefix=>l_debug_prefix,
    	  p_msg_level=>fnd_log.level_procedure,
        p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
        p_module   =>l_module);
    	hz_utility_v2pub.DEBUG
    	 (p_message=>'entity_in_bo()-',
    	  p_prefix=>l_debug_prefix,
    	  p_msg_level=>fnd_log.level_procedure,
        p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
        p_module   =>l_module);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (p_entity_name IS NULL) THEN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    	hz_utility_v2pub.DEBUG
    	 (p_message=>'p_entity_name mandatory param is null',
    	  p_prefix=>l_debug_prefix,
    	  p_msg_level=>fnd_log.level_procedure,
        p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
        p_module   =>l_module);
    	hz_utility_v2pub.DEBUG
    	 (p_message=>'entity_in_bo()-',
    	  p_prefix=>l_debug_prefix,
    	  p_msg_level=>fnd_log.level_procedure,
        p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
        p_module   =>l_module);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
/*
  -- construct the node path
  Entity_name is not part of the node path.
  If high level BO code and p_ebo_code are same - mention any one of them only.
  Handle the case where p_child_bo_code is null.
*/

  IF p_bo_code = p_ebo_code THEN
    l_samebo_flag := TRUE;
  END IF;
  IF p_child_bo_code IS NULL THEN
      l_cbo_null_flag := TRUE;
  END IF;

  -- WHEN HIGH LEVEL bo AND EBO_CODE ARE SAME AND CHILD_BO_CODE IS NULL
  IF l_samebo_flag AND l_cbo_null_flag THEN
    l_node := '/'||p_bo_code;
  END IF;
  -- WHEN HIGH LEVEL BO AND EBO_CODE ARE different AND CHILD_BO_CODE IS NULL
  IF ((NOT(l_samebo_flag)) AND l_cbo_null_flag) THEN
    l_node := '/'||p_bo_code||'%/'||p_ebo_code;
  END IF;
  -- WHEN HIGH LEVEL bo AND EBO_CODE ARE SAME AND CHILD_BO_CODE IS NOT NULL
  IF (l_samebo_flag AND (NOT(l_cbo_null_flag))) THEN
    l_node := '/'||p_bo_code||'%/'||p_child_bo_code;
  END IF;
  -- WHEN HIGH LEVEL BO AND EBO_CODE ARE different AND CHILD_BO_CODE IS NOT NULL
  IF ((NOT(l_samebo_flag)) AND (NOT(l_cbo_null_flag))) THEN
    l_node := '/'||p_bo_code||'%/'||p_ebo_code||'/'||p_child_bo_code;
  END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    	hz_utility_v2pub.DEBUG
    	 (p_message=>'node path is:'||l_node,
    	  p_prefix=>l_debug_prefix,
    	  p_msg_level=>fnd_log.level_procedure,
        p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
        p_module   =>l_module);
    END IF;
--  OPEN c_chk_entity (p_bo_code, p_ebo_code, p_child_bo_code, p_entity_name);
  OPEN c_chk_entity (p_bo_code, p_entity_name, l_node);
  FETCH c_chk_entity INTO l_num;
  CLOSE c_chk_entity;
  IF l_num = 1 THEN
    x_return_status := TRUE;
--   RETURN TRUE;
  ELSE
    x_return_status := FALSE;
--   RETURN FALSE;
  END IF;
EXCEPTION
WHEN OTHERS THEN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>sqlerrm,
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'entity_in_bo()-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;
END entity_in_bo;
-----------------------------------------------------------------
/*
Procedure name: populate_missing_links  ()
Scope: external
Purpose: This is an umbrella procedure to call all the
  explode entity procedures that populate the parent record
	and update the current record with BO codes etc.
	This must be done in order to reach the root node of Org, Person,
	Org Cust and Person Cust BOs.
Called From: This is called from HZ_BES_BO_RAISE_PKG
Called By: bes_main()
*/
-----------------------------------------------------------------
PROCEDURE populate_missing_links
	( p_creation_date IN DATE )IS
	l_debug_prefix VARCHAR2(30) := 'EXP_HZ_TBLS:'; -- explode hz tables
	l_module VARCHAR2(30) := 'pop_missing_lnks';
BEGIN
 LOG( message      => 'populate_missing_links()+',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
	-- set the global variable with the p_creation_date. This is to
	-- avoid passing the parameter for each insert procedure.
	-- Each of the insert procedures, need to populate the BOT creation_date
	-- with the value the p_creation_date value.
	G_CREATION_DATE := p_creation_date;
/* A note on insert and update procedures.

Insert Procedures:
The functional reason for these insert procedures to exist is to identify
and track the parent of each child entity. The parent record is
needed in order for the following functions to work properly.
 1. Business Object Completeness Check
 2. To identify Business Object Event Type - whether to raise create or update event
 3. To extract the Business Object

In all the three functionalities above will only have knowledge of
Business Object root node. To get to the leaf node, all the intermediate
nodes must be present in the BOT table. Hence this insert procedures.

Update Procedures:
	In order to link the parent record and child record, it is mandatory for
	the child record to contain the information for parent in addition to
	having its (childs) information in it.

Only when both parent record (insert procedure) and child record contains
parent info (update procedure), it is possible to sucessfuly do
the three functions mentioned above.

*/
/*
	 Note 1.
	 ONLY following entities are exploded as part of the concurrent program.
	 Remaing entities are handled by the populate functions.
	 Note 2.
	 As populate function write the PARENT_BO_CODE as part of populating the
	 child record, there is no need of calling any update procedures
	 as described earlier. Only insert procedures are called.

1.  HZ_CONTACT_PREFERENCES
2.  HZ_PER_PROFILES_EXT_VL
3.  HZ_PERSON_PROFILES
4.  HZ_PARTY_SITE_USES
5.  HZ_CONTACT_POINTS
6.  HZ_PARTY_SITES_EXT_VL
7.  HZ_LOCATIONS_EXT_VL
8.  HZ_LOCATIONS
9.  HZ_PARTY_SITES
10. HZ_ORG_CONTACTS
11. HZ_ORG_PROFILES_EXT_VL
12. HZ_CUST_ACCOUNT_ROLES
13. HZ_CUSTOMER_PROFILES
14. HZ_CUST_SITE_USES_ALL
15. HZ_CUST_ACCT_SITES_ALL
16. HZ_CUST_ACCOUNTS
*/
	-- Insert the parent record
	-- 1.	HZ_CONTACT_PREFERENCES
/* LOG(
      message      => 'bfr calling ei_HZ_CONTACT_PREFERENCES()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_CONTACT_PREFERENCES()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

	ei_HZ_CONTACT_PREFERENCES;
	-- 2.	HZ_PER_PROFILES_EXT_VL
/* LOG(
      message      => 'bfr calling ei_HZ_PER_PROFILES_EXT_VL()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_PER_PROFILES_EXT_VL()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

  ei_HZ_PER_PROFILES_EXT_VL;
	-- 3.	HZ_PERSON_PROFILES
/* LOG(
      message      => 'bfr calling ei_HZ_PERSON_PROFILES()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_PERSON_PROFILES()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

	ei_HZ_PERSON_PROFILES;
	-- 4.	HZ_PARTY_SITE_USES
/* LOG(
      message      => 'bfr calling ei_HZ_PARTY_SITE_USES()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_PARTY_SITE_USES()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

	ei_HZ_PARTY_SITE_USES;
	-- 5.	HZ_CONTACT_POINTS
/* LOG(
      message      => 'bfr calling ei_HZ_CONTACT_POINTS()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_CONTACT_POINTS()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

	ei_HZ_CONTACT_POINTS;
  -- 6.  HZ_PARTY_SITES_EXT_VL
/* LOG(
      message      => 'bfr calling ei_HZ_PARTY_SITES_EXT_VL()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_PARTY_SITES_EXT_VL()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

  ei_HZ_PARTY_SITES_EXT_VL;
  -- 7.  HZ_LOCATIONS_EXT_VL
/* LOG(
      message      => 'bfr calling ei_HZ_LOCATIONS_EXT()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_LOCATIONS_EXT()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

  ei_HZ_LOCATIONS_EXT;
	-- 8.	HZ_LOCATIONS
/* LOG(
      message      => 'bfr calling ei_HZ_LOCATIONS()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_LOCATIONS()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

	ei_HZ_LOCATIONS;
	-- 9.	HZ_PARTY_SITES
/* LOG(
      message      => 'bfr calling ei_HZ_PARTY_SITES()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_PARTY_SITES()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

	ei_HZ_PARTY_SITES;
	-- 10.	HZ_ORG_CONTACTS
/* LOG(
      message      => 'bfr calling ei_HZ_ORG_CONTACTS()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_ORG_CONTACTS()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

	ei_HZ_ORG_CONTACTS;
  -- 11. HZ_ORG_PROFILES_EXT_VL
/* LOG(
      message      => 'bfr calling ei_HZ_ORG_PROFILES_EXT_VL()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_ORG_PROFILES_EXT_VL()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

  ei_HZ_ORG_PROFILES_EXT_VL;
	-- 12.	HZ_CUST_ACCOUNT_ROLES
/* LOG(
      message      => 'bfr calling ei_HZ_CUST_ACCOUNT_ROLES()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_CUST_ACCOUNT_ROLES()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

  ei_HZ_CUST_ACCOUNT_ROLES;
	-- 13.	HZ_CUSTOMER_PROFILES
/* LOG(
      message      => 'bfr calling ei_HZ_CUSTOMER_PROFILES()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_CUSTOMER_PROFILES()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

  ei_HZ_CUSTOMER_PROFILES;
	-- 14.	HZ_CUST_SITE_USES_ALL
/*	 LOG(
      message      => 'bfr calling ei_HZ_CUST_SITE_USES_ALL()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_CUST_SITE_USES_ALL()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

	ei_HZ_CUST_SITE_USES_ALL;
	-- 15.	HZ_CUST_ACCT_SITES_ALL
/*
 LOG(
      message      => 'bfr calling ei_HZ_CUST_ACCT_SITES_ALL()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_CUST_ACCT_SITES_ALL()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

  ei_HZ_CUST_ACCT_SITES_ALL;
	-- 16.	HZ_CUST_ACCOUNTS
/*
 LOG(
      message      => 'bfr calling ei_HZ_CUST_ACCOUNTS()',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'bfr calling ei_HZ_CUST_ACCOUNTS()',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'pop_missing_lnks');
  END IF;

  ei_HZ_CUST_ACCOUNTS;
	COMMIT;
 LOG( message      => 'populate_missing_links()-',
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
EXCEPTION
WHEN OTHERS THEN
 LOG( message      => 'populate_missing_links:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   => l_module);
	ROLLBACK;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END populate_missing_links;
------------------------------------------------------------------------
/*
*/
PROCEDURE upd_bot_evt_id (
	 p_bulk_evt in BOOLEAN, -- whether bulk event was raised (TRUE) or not (FALSE)
	 p_evt_id IN NUMBER,  -- only used for one event per object instance
	 p_child_id IN NUMBER,  -- only used for one event per object instance
	 p_child_bo_code IN VARCHAR2, -- only used for one event per object instance
	 p_per_ins_evt_id IN NUMBER,
	 p_per_upd_evt_id IN NUMBER,
	 p_org_ins_evt_id IN NUMBER,
	 p_org_upd_evt_id IN NUMBER,
	 p_perc_ins_evt_id IN NUMBER,
	 p_perc_upd_evt_id IN NUMBER,
	 p_orgc_ins_evt_id IN NUMBER,
	 p_orgc_upd_evt_id IN NUMBER) IS

	 -- cursor to select the root node identifier (child_id) and the
	 -- appropriate event id.
	 CURSOR c_bulk_bo_gt (
	   cp_per_ins_evt_id IN NUMBER,
	   cp_per_upd_evt_id IN NUMBER,
	   cp_org_ins_evt_id IN NUMBER,
	   cp_org_upd_evt_id IN NUMBER,
	   cp_perc_ins_evt_id IN NUMBER,
	   cp_perc_upd_evt_id IN NUMBER,
	   cp_orgc_ins_evt_id IN NUMBER,
	   cp_orgc_upd_evt_id IN NUMBER) IS
	 SELECT t.child_id, tmp.bo_code,
     CASE tmp.bo_code
       WHEN 'PERSON' THEN
         DECODE ( tmp.event_type_flag, 'U', cp_per_upd_evt_id, cp_per_ins_evt_id)
       WHEN 'ORG' THEN
         DECODE ( tmp.event_type_flag, 'U', cp_org_upd_evt_id, cp_org_ins_evt_id)
       WHEN 'PERSON_CUST' THEN
         DECODE ( tmp.event_type_flag, 'U', cp_perc_upd_evt_id, cp_perc_ins_evt_id)
      WHEN 'ORG_CUST' THEN
         DECODE ( tmp.event_type_flag, 'U', cp_orgc_upd_evt_id, cp_orgc_ins_evt_id)
    END  eventid
   FROM HZ_BUS_OBJ_TRACKING t,  hz_bes_gt tmp
   WHERE t.child_id = tmp.party_id
   AND t.child_bo_code = tmp.bo_code
   AND t.child_entity_name = 'HZ_PARTIES'
   AND t.parent_bo_code IS NULL
   AND t.event_id IS NULL;

	 -- local variables
   l_debug_prefix VARCHAR2 (10):= 'updbot';
	 l_rtids NUMBER_TBLTYPE;
	 l_evtids NUMBER_TBLTYPE;
	 l_bo_codes VCHAR2_30_TBLTYPE;

BEGIN
 /* Logic flow
	  Check if the VBulk event was raised or not.
	  If the bulk event is raised
	    open c_bulk_bo_gt with all 8 event id params
	    do forall update of on BOT using the retrun values
	    commit;
	  If the individual event is raised
 */
  hz_utility_v2pub.DEBUG
   (p_message=>'upd_bot_evt_id()+',
    p_prefix=>l_debug_prefix,
    p_msg_level=>fnd_log.level_procedure);
  IF p_bulk_evt THEN
    -- The event was raised in bulk i.e., One event was raised for a set of
    -- Business Objects of the same type with same operation.
    OPEN c_bulk_bo_gt(
    p_per_ins_evt_id,
    p_per_upd_evt_id,
    p_org_ins_evt_id,
    p_org_upd_evt_id,
    p_perc_ins_evt_id,
    p_perc_upd_evt_id,
    p_orgc_ins_evt_id,
    p_orgc_upd_evt_id );
    FETCH c_bulk_bo_gt BULK COLLECT INTO l_rtids, l_bo_codes, l_evtids;
    CLOSE c_bulk_bo_gt;
    FORALL i IN l_rtids.FIRST..l_rtids.LAST
      UPDATE HZ_BUS_OBJ_TRACKING
      SET event_id = l_evtids(i)
      WHERE ROWID IN (
        SELECT ROWID FROM HZ_BUS_OBJ_TRACKING
        START WITH child_id = l_rtids(i)
        AND child_entity_name = 'HZ_PARTIES'
        AND parent_BO_CODE IS NULL
        AND event_id IS NULL
        AND CHILD_BO_CODE = l_bo_codes(i)
        CONNECT BY PARENT_ENTITY_NAME = PRIOR CHILD_ENTITY_NAME
        AND PARENT_ID = PRIOR CHILD_ID
        AND parent_bo_code = PRIOR child_bo_code) ;
  ELSE
    -- one event per object instance was raised.
      UPDATE HZ_BUS_OBJ_TRACKING
      SET event_id = p_evt_id
      WHERE ROWID IN (
        SELECT ROWID FROM HZ_BUS_OBJ_TRACKING
        START WITH child_id = p_child_id
        AND child_entity_name = 'HZ_PARTIES'
        AND parent_BO_CODE IS NULL
        AND event_id IS NULL
        AND CHILD_BO_CODE = p_child_bo_code
        CONNECT BY PARENT_ENTITY_NAME = PRIOR CHILD_ENTITY_NAME
        AND PARENT_ID = PRIOR CHILD_ID
        AND parent_bo_code = PRIOR child_bo_code) ;
  END IF;
  -- commit the changes
  COMMIT;
  hz_utility_v2pub.DEBUG
  (p_message=>'upd_bot_evt_id()-',
  p_prefix=>l_debug_prefix,
  p_msg_level=>fnd_log.level_procedure);
EXCEPTION
WHEN OTHERS THEN
	ROLLBACK;
	hz_utility_v2pub.DEBUG
	 (p_message=>SQLERRM,
	  p_prefix=>l_debug_prefix,
	  p_msg_level=>fnd_log.level_procedure);
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END upd_bot_evt_id;
-------------------------------------------------------------------------------
PROCEDURE upd_bot_evtid_dt (
	 p_bulk_evt in BOOLEAN, -- whether bulk event was raised (TRUE) or not (FALSE)
	 p_evt_id IN NUMBER,  -- only used for one event per object instance
	 p_child_id IN NUMBER,  -- only used for one event per object instance
	 p_child_bo_code IN VARCHAR2, -- only used for one event per object instance
	 p_creation_date IN DATE, -- used to update the creation_date column in BOT
	 p_evt_type IN VARCHAR2, -- this is to pass the event type (Bug4773627)
  	 p_commit  IN BOOLEAN, -- to control commit or rolllback when called from v3 api(Bug4957408)
	 p_per_ins_evt_id IN NUMBER,
	 p_per_upd_evt_id IN NUMBER,
	 p_org_ins_evt_id IN NUMBER,
	 p_org_upd_evt_id IN NUMBER,
	 p_perc_ins_evt_id IN NUMBER,
	 p_perc_upd_evt_id IN NUMBER,
	 p_orgc_ins_evt_id IN NUMBER,
	 p_orgc_upd_evt_id IN NUMBER) IS

-- cursor to select the root node identifier (child_id) and the
-- appropriate event id.
   CURSOR c_bulk_bo_gt (
	   cp_per_ins_evt_id IN NUMBER,
	   cp_per_upd_evt_id IN NUMBER,
	   cp_org_ins_evt_id IN NUMBER,
	   cp_org_upd_evt_id IN NUMBER,
	   cp_perc_ins_evt_id IN NUMBER,
	   cp_perc_upd_evt_id IN NUMBER,
	   cp_orgc_ins_evt_id IN NUMBER,
	   cp_orgc_upd_evt_id IN NUMBER) IS
    SELECT t.child_id, tmp.bo_code,
     CASE tmp.bo_code
       WHEN 'PERSON' THEN
         DECODE ( tmp.event_type_flag, 'U', cp_per_upd_evt_id, cp_per_ins_evt_id)
       WHEN 'ORG' THEN
         DECODE ( tmp.event_type_flag, 'U', cp_org_upd_evt_id, cp_org_ins_evt_id)
       WHEN 'PERSON_CUST' THEN
         DECODE ( tmp.event_type_flag, 'U', cp_perc_upd_evt_id, cp_perc_ins_evt_id)
      WHEN 'ORG_CUST' THEN
         DECODE ( tmp.event_type_flag, 'U', cp_orgc_upd_evt_id, cp_orgc_ins_evt_id)
    END  eventid,
    NVL(tmp.EVENT_TYPE_FLAG, 'C')
   FROM HZ_BUS_OBJ_TRACKING t,  hz_bes_gt tmp
   WHERE t.child_id = tmp.party_id
   AND t.child_bo_code = tmp.bo_code
   AND t.child_entity_name = 'HZ_PARTIES'
   AND t.parent_bo_code IS NULL
   AND t.event_id IS NULL;
/*
   -- To support population of event flag in case of raising (Bug4773627)
   -- one event per BO instance or from raising events from V3 a.k.a Logical APIs.
   CURSOR c_get_evttype (
    cp_evt_id     IN NUMBER,
    cp_rt_node_id IN NUMBER,
    cp_bo_code    IN VARCHAR2) IS
   SELECT NVL(tmp.EVENT_TYPE_FLAG, 'C')
     from  hz_bes_gt tmp
     where  tmp.bo_code  = cp_bo_code
       and  tmp.party_id = cp_rt_node_id
       and  tmp.event_id = cp_evt_id;
*/
   -- local variables
   l_debug_prefix VARCHAR2 (10):= 'updbot';
   l_rtids NUMBER_TBLTYPE;
   l_evtids NUMBER_TBLTYPE;
   l_bo_codes VCHAR2_30_TBLTYPE;
   l_evtTypes VCHAR2_30_TBLTYPE; -- added to support Bug4773627

BEGIN
 /* Logic flow
	  Check if the VBulk event was raised or not.
	  If the bulk event is raised
	    open c_bulk_bo_gt with all 8 event id params
	    do forall update of on BOT using the retrun values
	    commit;
	  If the individual event is raised
 */
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
     (p_message=>'upd_bot_evtid_dt()+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'updbot');
  END IF;

  IF p_bulk_evt THEN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    	hz_utility_v2pub.DEBUG
       (p_message=>'for bulk event',
    	  p_prefix=>l_debug_prefix,
    	  p_msg_level=>fnd_log.level_procedure,
        p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
        p_module   =>'updbot');
    END IF;
    -- The event was raised in bulk i.e., One event was raised for a set of
    -- Business Objects of the same type with same operation.
    OPEN c_bulk_bo_gt(
    p_per_ins_evt_id,
    p_per_upd_evt_id,
    p_org_ins_evt_id,
    p_org_upd_evt_id,
    p_perc_ins_evt_id,
    p_perc_upd_evt_id,
    p_orgc_ins_evt_id,
    p_orgc_upd_evt_id );
    FETCH c_bulk_bo_gt BULK COLLECT INTO l_rtids, l_bo_codes, l_evtids, l_evtTypes;
    CLOSE c_bulk_bo_gt;
    FORALL i IN l_rtids.FIRST..l_rtids.LAST
      UPDATE HZ_BUS_OBJ_TRACKING
      SET event_id = l_evtids(i),
          creation_date = p_creation_date,
          PARENT_EVENT_FLAG = nvl2(PARENT_BO_CODE, NULL, l_evtTypes(i))
      WHERE event_id is null and ROWID IN (
        SELECT ROWID FROM HZ_BUS_OBJ_TRACKING
        START WITH child_id = l_rtids(i)
        AND child_entity_name = 'HZ_PARTIES'
        AND parent_BO_CODE IS NULL
        AND event_id IS NULL
        AND CHILD_BO_CODE = l_bo_codes(i)
        CONNECT BY PARENT_ENTITY_NAME = PRIOR CHILD_ENTITY_NAME
        AND PARENT_ID = PRIOR CHILD_ID
        AND parent_bo_code = PRIOR child_bo_code) ;
  ELSE
    -- one event per object instance was raised.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    	hz_utility_v2pub.DEBUG
       (p_message=>'for one event per object instance',
    	  p_prefix=>l_debug_prefix,
    	  p_msg_level=>fnd_log.level_procedure,
        p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
        p_module   =>'updbot');
    END IF;
      UPDATE HZ_BUS_OBJ_TRACKING
      SET event_id = p_evt_id,
      creation_date = p_creation_date,
      PARENT_EVENT_FLAG = nvl2(PARENT_BO_CODE, NULL, p_evt_type)
      WHERE event_id is null and ROWID IN (
        SELECT ROWID FROM HZ_BUS_OBJ_TRACKING
        START WITH child_id = p_child_id
        AND child_entity_name = 'HZ_PARTIES'
        AND parent_BO_CODE IS NULL
        AND event_id IS NULL
        AND CHILD_BO_CODE = p_child_bo_code
        CONNECT BY PARENT_ENTITY_NAME = PRIOR CHILD_ENTITY_NAME
        AND PARENT_ID = PRIOR CHILD_ID
        AND parent_bo_code = PRIOR child_bo_code
	AND event_id is null) ;
/*
      OPEN c_get_evttype ( p_evt_id, p_child_id, p_child_bo_code);
      FETCH c_get_evttype BULK COLLECT INTO l_evtTypes;
      CLOSE c_get_evttype ;
      -- To support population of event flag in case of raising (Bug4773627)
      -- one event per BO instance or raising events from V3 a.k.a Logical APIs.
       UPDATE HZ_BUS_OBJ_TRACKING
         SET  PARENT_EVENT_FLAG = l_evtTypes(1)
        where event_id = p_evt_id
          AND parent_BO_CODE IS NULL
          AND CHILD_BO_CODE = p_child_bo_code
          AND child_entity_name = 'HZ_PARTIES'
          AND  child_id = p_child_id;
*/
  END IF;
  if p_commit then
    -- commit the changes only when conc program calls
    COMMIT;
  end if;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.DEBUG
      (p_message=>'upd_bot_evtid_dt()-',
      p_prefix=>l_debug_prefix,
      p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'updbot');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message  => 'upd_bot_evtid_dt:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'updbot');
    if p_commit then
      -- rollback the changes only when conc program calls
	  ROLLBACK;
    end if;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END upd_bot_evtid_dt;
------------------------------------------------------------------------------

/*
Procedure name: upd_hzp_bo_ver  ()
Scope: external
Purpose: This procedure will update the hz_parties table with all the
  latest bo_version_numbers. This must be done to short circuit the
  process for figuring out event type when the object is touched next time.
Called From: This is called from HZ_BES_BO_RAISE_PKG
Called By: bes_main()
Input parameters:
	 p_per_bo_ver IN NUMBER   -- for passing the person bo version number
	 p_org_bo_ver IN NUMBER   -- for passing the org bo version number
	 p_perc_bo_ver IN NUMBER  -- for passing the person cust bo version number
	 p_orgc_bo_ver IN NUMBER  -- for passing the org cust bo version number
*/
----------------------------------------------------------------------------
	PROCEDURE upd_hzp_bo_ver (
	 p_per_bo_ver IN NUMBER,   -- for passing the person bo version number
	 p_org_bo_ver IN NUMBER,   -- for passing the org bo version number
	 p_perc_bo_ver IN NUMBER, -- for passing the person cust bo version number
	 p_orgc_bo_ver IN NUMBER) IS -- for passing the org cust bo version number
	 -- local variables
   l_debug_prefix VARCHAR2 (10):= 'updhzp';

BEGIN
 /* Logic flow
    Select all the rows from GT, from the list, update the hz_parties table for all the
    rows that do not have correct BO version number
 */
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.DEBUG
     (p_message=>'upd_hzp_bo_ver()+',
      p_prefix=>l_debug_prefix,
      p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'updp');
  END IF;

UPDATE HZ_PARTIES
SET PERSON_BO_VERSION = p_per_bo_ver
WHERE  party_id IN
(SELECT t.party_id
 FROM  HZ_BES_GT t
 WHERE t.BO_CODE = 'PERSON')
AND (PERSON_BO_VERSION <> p_per_bo_ver
OR  PERSON_BO_VERSION IS NULL)  ;

UPDATE HZ_PARTIES
SET    ORG_BO_VERSION = p_org_bo_ver
WHERE  party_id IN
(SELECT t.party_id
 FROM  HZ_BES_GT t
 WHERE t.BO_CODE = 'ORG')
AND (ORG_BO_VERSION  <>p_org_bo_ver
     OR ORG_BO_VERSION IS NULL);

UPDATE HZ_PARTIES
SET PERSON_CUST_BO_VERSION  = p_perc_bo_ver
WHERE  party_id IN
(SELECT t.party_id
 FROM  HZ_BES_GT t
 WHERE t.BO_CODE = 'PERSON_CUST')
AND (PERSON_CUST_BO_VERSION <> p_perc_bo_ver
 OR PERSON_CUST_BO_VERSION IS NULL);

UPDATE HZ_PARTIES
SET ORG_CUST_BO_VERSION  = p_orgc_bo_ver
WHERE  party_id IN
(SELECT t.party_id
 FROM  HZ_BES_GT t
 WHERE t.BO_CODE = 'ORG_CUST')
AND   (ORG_CUST_BO_VERSION  <>p_orgc_bo_ver
OR  ORG_CUST_BO_VERSION  IS NULL);

  -- commit the changes
  COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.DEBUG
     (p_message=>'upd_hzp_bo_ver()-',
      p_prefix=>l_debug_prefix,
      p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'updp');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    LOG( message  => 'upd_hzp_bo_ver:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'updp');
	ROLLBACK;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END upd_hzp_bo_ver;
----------------------------------------------------------------------------
/*
Procedure name: del_bot()
Scope: external
Purpose: This procedure will delete the records that were already processed
 by subscriptions.
Input parameters:
	 p_cutoff_dt IN DATE);-- for passing the cutoff date for deleting the recs in BOT
*/
----------------------------------------------------------------------------
PROCEDURE del_bot (p_cutoff_dt IN DATE)IS
l_debug_prefix VARCHAR2(20) := 'del_bot';
BEGIN
/*
  Goal:
    To delete the records that were identified for deletion.
  Who Calls this procedure:
    Cleanse concurrent program will call this procedure.
  Logic:
  Delete all the processed records that for which event is raised
  before given date.

*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'del_bot()+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'del_bot');
  	hz_utility_v2pub.DEBUG
     (p_message=>'cutoff date is:'||TO_CHAR(p_cutoff_dt),
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'del_bot');
  END IF;

  DELETE FROM  HZ_BUS_OBJ_TRACKING
  WHERE event_id IS NOT NULL
  AND creation_date < p_cutoff_dt;

  -- commit the changes
  COMMIT;
  /* CASE 1: In cases, where Party Purge Conc Program purges the
   records, BOT table will some time have entire hierarchy of
   records that are to be deleted.
   Identify such records and delete them from BOT.
   To be done. Srikanth Jan 24th 2006.
  */
  COMMIT;
  /* CASE 2: In cases where Account Merge Conc Program purges the
  Account hieararchy from TCA Schema and not from BOT,
  These records have to be removed from BOT.
  Identify such records and delete them from BOT.
  To be done. Srikanth Jan 24th 2006.
  */
  COMMIT;
  /*CASE 3: In cases where Party Merge Conc Program
  merges the underlying entities of a party into another party
  and BOT only has those effected entities and not the parent
  then, CASE1 AND CASE2  cannot catch such orphan records.

  Identify all such records from BOT that do not have corresponding
  row in TCA Schema and delete them.

  This case works as an umbrella case wherein, all those records that
  were not identified by CASE1, CASE2 are caught here.

  The reason to do this as the last option instead of first or the
  only option is, by taking care of first two cases, many of the
  effected records may be deleted. Leaving only a handful of records to
  be deleted for CASE3. This might enhance the performance.
  TO be Done - Srikanth Jan 24th 2006
  */
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'del_bot()-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'del_bot');
  END IF;

EXCEPTION
WHEN OTHERS THEN
      LOG( message  => 'del_bot:'||SQLERRM,
	    p_prefix    =>l_debug_prefix,
      p_module   =>'delbot');
	ROLLBACK;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END del_bot;
----------------------------------------------------------------------------
/*
  This is an overloaded procedure.
Procedure: del_duplicate_rows
Scope: external - called only by the concurrent program.
Purpose: This procedure
  selects duplicate records from BOT that were not yet processed and
  deletes one of the rows (row with max rowid).
*/
----------------------------------------------------------------------------
PROCEDURE del_duplicate_rows IS

-- local variables
  l_debug_prefix VARCHAR2(40) := 'DEL_DUPLICATE_ROWS2';
  l_module VARCHAR2(30) := 'del_dup2';

 BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'del_duplicate_rows2+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'del_dup');
  END IF;

DELETE FROM HZ_BUS_OBJ_TRACKING
WHERE ROWID IN (
SELECT bo_row
FROM (
    SELECT rowid bo_row,
    RANK() over (PARTITION BY child_id, child_entity_name,
            child_bo_code, parent_entity_name, parent_id, parent_bo_code
            ORDER BY rowid) ROWRANK
     FROM HZ_BUS_OBJ_TRACKING a
     WHERE a.event_id IS NULL)
    WHERE ROWRANK >1);
COMMIT;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'del_duplicate_rows2-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>'del_dup');
  END IF;


EXCEPTION
 WHEN NO_DATA_FOUND THEN
  -- no need of any action.
   NULL;
END del_duplicate_rows;
----------------------------------------------------------------------------
/*
Procedure name: del_obj_hierarchy()
Scope: external
Purpose: Given a root object identifier, this procedure
 will delete the entire hierarchy.
 This procedure is called from
 1. party purge concurrent program
 2. account merge concurrent program with delete option.

In these two cases, as the entire party and its detailed records are
purged, there is no use of maintaining those records in the BOT.
If the purged records are left in BOT without deleting:
 1. There is a chance that an event may be raised for already
    purged record. Functionally, this would be incorrect.
 2. The Raise Events concurrent program may error out
    as it cannot find the party record in TCA Registry.
    This is needed for updating the party BO_VERSION columns to
    be updated after raising the event.

Called By:
 1. party purge concurrent program
 2. account merge concurrent program with delete option.

Input:
  BO Code: PERSON for Person BO,
           ORG for Organization BO,
           PERSON_CUST for Person Customer BO
           ORG_CUST for Organization Customer BO
  Object Identifier: Root Object Id (party id).

*/
procedure del_obj_hierarchy
 ( P_OBJ_ID  IN NUMBER) IS

 cursor c1_ptype (cp_party_id in number) is
 select party_type
 from hz_parties
 where party_id = cp_party_id;

-- local variables
  l_debug_prefix VARCHAR2(20) := 'del_obj:';
  l_module VARCHAR2(30) := 'del_obj_hierarchy';
  l_bo_code VARCHAR2(20);


BEGIN

/*
  Flow:
   Figure out the party type based on partyId
   For BO code Person or Person Customers
     delete the Person and Person Customer hierarchies for a given partyId
     -- This is because, the person bo might have corresponding
     -- Person Customer BO in BOT
   For BO code Org or Org Customers
     delete the Org and Org Customer hierarchies for a given partyId
     -- This is because, the Org bo might have corresponding
     -- Org Customer BO in BOT
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'del_obj_hierarchy+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;

  OPEN c1_ptype (P_OBJ_ID );
  FETCH c1_ptype INTO l_bo_code;
  CLOSE c1_ptype;
 IF l_BO_CODE = 'PERSON'  THEN
  -- for Person
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'deleting '||l_BO_CODE||' HIERARCHY corresponds to partyId:'||P_OBJ_ID,
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;
  DELETE FROM HZ_BUS_OBJ_TRACKING
  WHERE ROWID IN (
    SELECT ROWID  FROM HZ_BUS_OBJ_TRACKING
    START WITH
      event_id IS NULL AND child_id = P_OBJ_ID AND CHILD_BO_CODE = 'PERSON' AND
      child_entity_name = 'HZ_PARTIES' AND parent_id IS NULL AND
      PARENT_ENTITY_NAME is NULL
    CONNECT BY
      PARENT_BO_CODE = PRIOR CHILD_BO_CODE AND PARENT_ID = PRIOR CHILD_ID);
  -- for Person Customer
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'deleting '||l_bo_code||' Customer HIERARCHY corresponds to partyId:'||P_OBJ_ID,
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;
  DELETE FROM HZ_BUS_OBJ_TRACKING
  WHERE ROWID IN (
    SELECT ROWID  FROM HZ_BUS_OBJ_TRACKING
    START WITH
      event_id IS NULL AND child_id = P_OBJ_ID AND CHILD_BO_CODE = 'PERSON_CUST' AND
      child_entity_name = 'HZ_PARTIES' AND parent_id IS NULL AND
      PARENT_ENTITY_NAME is NULL
    CONNECT BY
      PARENT_BO_CODE = PRIOR CHILD_BO_CODE AND PARENT_ID = PRIOR CHILD_ID);
 ELSIF l_bo_code = 'ORGANIZATION' THEN
  -- for Org
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'deleting '||l_bo_code||' HIERARCHY corresponds to partyId:'||P_OBJ_ID,
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;
  DELETE FROM HZ_BUS_OBJ_TRACKING
  WHERE ROWID IN (
    SELECT ROWID  FROM HZ_BUS_OBJ_TRACKING
    START WITH
      event_id IS NULL AND child_id = P_OBJ_ID AND CHILD_BO_CODE = 'ORG' AND
      child_entity_name = 'HZ_PARTIES' AND parent_id IS NULL AND
      PARENT_ENTITY_NAME is NULL
    CONNECT BY
      PARENT_BO_CODE = PRIOR CHILD_BO_CODE AND PARENT_ID = PRIOR CHILD_ID);
  -- for Org Customer
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'deleting '||l_bo_code||' Customer HIERARCHY corresponds to partyId:'||P_OBJ_ID,
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;
  DELETE FROM HZ_BUS_OBJ_TRACKING
  WHERE ROWID IN (
    SELECT ROWID  FROM HZ_BUS_OBJ_TRACKING
    START WITH
      event_id IS NULL AND child_id = P_OBJ_ID AND CHILD_BO_CODE = 'ORG_CUST' AND
      child_entity_name = 'HZ_PARTIES' AND parent_id IS NULL AND
      PARENT_ENTITY_NAME is NULL
    CONNECT BY
      PARENT_BO_CODE = PRIOR CHILD_BO_CODE AND PARENT_ID = PRIOR CHILD_ID);
 ELSE
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'incorrect BO Code:'||l_bo_code,
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;
END IF;
/*
   Not issuing the commit stmt after deleting the records.
   This is because, commit is handled by the caller of this procedure.
*/
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'del_obj_hierarchy-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  -- no need of any action.
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'No data to delete',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;
END del_obj_hierarchy;
----------------------------------------------------------------------------
/*
Procedure name: upd_entity_ids()
Scope: external
Purpose: Given a root object identifier, this procedure
 will delete the entire hierarchy.
 This procedure is called from
 1. party merge concurrent program
 2. account merge concurrent program

In these two cases, the entity ids are changed in TCA REgistry by
the above concurrent programs.
This procedure reflects the id changes in the BOT.
This changed ids will enable the BO extraction API to get to the
action types of the changed entities in BOT.

Note - this method does not handle RA_CUST_RECEIPT_METHODS and
       IBY_FNDCPT_PAYER_ASSGN_INSTR_V.
  This method only handles update of identifiers for HZ tables.
Called By:
 1. party merge concurrent program
 2. account merge concurrent program

Input:
  request id: Concurrent Request Identifier
*/
procedure upd_entity_ids
 ( P_request_id IN NUMBER) IS

-- cursor declaration
 CURSOR c_enty_ids (cp_request_id IN NUMBER) IS
  SELECT l.FROM_ENTITY_ID, l.TO_ENTITY_ID, d.entity_name
   FROM hz_merge_party_log l, hz_merge_dictionary d
   WHERE  l.request_id = cp_request_id
   AND l.MERGE_DICT_ID = d.MERGE_DICT_ID
   AND d.entity_name LIKE 'HZ%'
   AND l.to_entity_id IS NOT null
   AND l.FROM_ENTITY_ID <> l.TO_ENTITY_ID
   ORDER BY 3 desc;

-- local variables
  l_debug_prefix VARCHAR2(20) := 'upd_ids:';
  l_module VARCHAR2(30) := 'upd_entity_ids';

   l_from_ids     NUMBER_TBLTYPE;
   l_to_ids       NUMBER_TBLTYPE;
   l_entity_names VCHAR2_30_TBLTYPE;

BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'upd_entity_ids+',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;

/* Flow
   1. identify the fromId, ToId and entittyName from merge log table.
   2. then update the bot table
*/

 OPEN c_enty_ids (P_request_id );
 FETCH c_enty_ids BULK COLLECT INTO l_from_ids, l_to_ids, l_entity_names;
 CLOSE c_enty_ids;

 FORALL i IN l_from_ids.FIRST..l_from_ids.LAST
  UPDATE HZ_BUS_OBJ_TRACKING
     SET CHILD_ID = l_to_ids(i)
   WHERE event_id IS NULL
    AND CHILD_ENTITY_NAME = l_entity_names(i)
    AND CHILD_ID = l_from_ids(i);

 FORALL i IN l_from_ids.FIRST..l_from_ids.LAST
  UPDATE HZ_BUS_OBJ_TRACKING
     SET PARENT_ID = l_to_ids(i)
   WHERE event_id IS NULL
    AND PARENT_ENTITY_NAME = l_entity_names(i)
    AND PARENT_ID = l_from_ids(i);

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
  	hz_utility_v2pub.DEBUG
  	 (p_message=>'upd_entity_ids-',
  	  p_prefix=>l_debug_prefix,
  	  p_msg_level=>fnd_log.level_procedure,
      p_module_prefix => 'HZ_BES_BO_UTIL_PKG',
      p_module   =>l_module);
  END IF;
END upd_entity_ids;
----------------------------------------------------------------------------
----------------------------------------------------------------------------
END HZ_BES_BO_UTIL_PKG; -- pkg

/
