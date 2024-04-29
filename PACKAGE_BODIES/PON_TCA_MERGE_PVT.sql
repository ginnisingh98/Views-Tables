--------------------------------------------------------
--  DDL for Package Body PON_TCA_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_TCA_MERGE_PVT" as
/* $Header: PONTCMGB.pls 120.5 2006/03/28 03:53:11 sapandey noship $ */

--
-- This is the basic signature required by the TCA Party Merge routine
--
-- PROCEDURE PARTY_MERGE(
--                    p_Entity_name	   IN VARCHAR2,
--		      p_from_id 	   IN NUMBER,
--		      x_to_id		   IN OUT NOCOPY NUMBER ,
--		      p_From_FK_id	   IN NUMBER,
--		      p_To_FK_id	   IN NUMBER,
--		      p_Parent_Entity_name IN VARCHAR2,
--		      p_batch_id	   IN NUMBER,
--		      p_Batch_Party_id	   IN NUMBER,
--		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
--

-- Start of comments
--      API name : VETO_ENTERPRISE_PARTY_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given trading_partmer_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the Trading Partner Id
--                        merge for Sourcing Buyer entities thus it will simply veto the
--                        accidental merge without checking any thing.
--
--                        So, DO NOT attach this procedure to any other Party Merge
--                        scenario apart from the Enterprise Buyer Party merge case
--                        for which it is designed
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE VETO_ENTERPRISE_PARTY_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
BEGIN
--{start of procedure

        --
        -- It does not check any thing and simply forwards
        -- a veto against the current Party Merge
        --
        FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;

--} end of procedure
END VETO_ENTERPRISE_PARTY_MERGE;


-- Start of comments
--      API name : CHECK_PERSON_PARTY_MERGE_TYPE
--
--      Type        : Private
--
--      Pre-reqs  : Given Party Id(p_from_id, to_from_id)
--                        must exists in the HZ_PARTIES table
--
--      Function  : This function will expect and accept to person party id
--                       (merge from party id and merge to party id) and it will
--                       return following values depending on the the situation
--                       given -
--
--     Scenario                       Return Value
--    --------------------------     -------------------------
--    From and To parties are
--    Buer Users                 -   BUYER
--
--    From and To parties are
--    Supplier Users            -  SELLER
--
--    From party is Buyer
--    and To party is Seller
--    user                           -   INCOMPATIBLE
--
--    From party is Seller
--    and To party is Buyer
--    user                           -   INCOMPATIBLE
--
--    From party is not
--    a Seller user and
--    From party is not
--    a Buyer user
--    But
--    To party is a Seller
--    user OR To party is
--    a Buyer user             -   INCOMPATIBLE
--
--    From party is not
--    a Seller or Buyer
--    user
--    AND
--    To party is not a
--    Buyer
--    OR Seller user            -  IRRELEVANT
--
--
--     Parameters:
--     IN     :      p_from_id             NUMBER   Required, the Merge From Party Id
--
--     IN     :      p_to_id                NUMBER   Required, the Merge To Party Id
--
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
FUNCTION CHECK_PERSON_PARTY_MERGE_TYPE (
		      p_from_id 	   IN NUMBER,
		      p_to_id         IN NUMBER
                  )
                  RETURN VARCHAR2
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_merge_type       VARCHAR2(20);
        l_from_user_type VARCHAR2(20);
        l_to_user_type     VARCHAR2(20);
        l_counter              NUMBER;

        CURSOR CHECK_USER_TYPE (p_user_party_id NUMBER)
        IS
            SELECT 'BUYER' AS USER_TYPE
	    FROM
	       HZ_PARTIES USER_PARTIES,
	       HZ_RELATIONSHIPS,
	       HZ_CODE_ASSIGNMENTS
	    WHERE USER_PARTIES.PARTY_ID = p_user_party_id
	      AND HZ_RELATIONSHIPS.SUBJECT_ID = USER_PARTIES.PARTY_ID
	      AND HZ_RELATIONSHIPS.RELATIONSHIP_TYPE = 'POS_EMPLOYMENT'
	      AND HZ_RELATIONSHIPS.RELATIONSHIP_CODE = 'EMPLOYEE_OF'
	      AND HZ_RELATIONSHIPS.START_DATE <= SYSDATE
	      AND HZ_RELATIONSHIPS.END_DATE >= SYSDATE
	      AND HZ_CODE_ASSIGNMENTS.OWNER_TABLE_ID = HZ_RELATIONSHIPS.OBJECT_ID
	      AND HZ_CODE_ASSIGNMENTS.OWNER_TABLE_NAME = 'HZ_PARTIES'
	      AND HZ_CODE_ASSIGNMENTS.CLASS_CATEGORY = 'POS_PARTICIPANT_TYPE'
	      AND HZ_CODE_ASSIGNMENTS.CLASS_CODE = 'ENTERPRISE'
            UNION
       	    SELECT 'SELLER' AS USER_TYPE
	    FROM
	       POS_SUPPLIER_USERS_V
	    WHERE PERSON_PARTY_ID = p_user_party_id;

BEGIN

        l_from_user_type := 'NONE';
        l_to_user_type := 'NONE';
        l_counter := 0;

        -- fnd_file.put_line (fnd_file.log,  '10 : Starting Party Comparion:');
        --
        -- open the user check cursor to determine user type
        --
        FOR user IN CHECK_USER_TYPE(p_from_id) LOOP
                l_from_user_type := user.USER_TYPE;
                l_counter := l_counter + 1;

                EXIT WHEN (l_counter = 1); -- May be I can do a better construct here
        END LOOP;

        -- fnd_file.put_line (fnd_file.log,  '20 : Merge From Party Type:'||l_from_user_type);

        l_counter := 0;
        FOR user IN CHECK_USER_TYPE(p_to_id) LOOP
                l_to_user_type := user.USER_TYPE;
                l_counter := l_counter + 1;

                EXIT WHEN (l_counter = 1); -- May be I can do a better construct here
        END LOOP;

        -- fnd_file.put_line (fnd_file.log,  '20 : Merge To Party Type:'||l_to_user_type);

        IF (l_from_user_type = 'BUYER') THEN

                IF (l_to_user_type = 'BUYER') THEN
                        l_merge_type := G_BUYER;
                ELSE
                        l_merge_type := G_INCOMPATIBLE;
                END IF;

        ELSIF (l_from_user_type = 'SELLER') THEN

                IF (l_to_user_type = 'SELLER') THEN
                        l_merge_type := G_SELLER;
                ELSE
                        l_merge_type := G_INCOMPATIBLE;
                END IF;

        ELSE

                IF (l_to_user_type = 'SELLER' OR l_to_user_type = 'BUYER') THEN
                        l_merge_type := G_INCOMPATIBLE;
                ELSE
                        l_merge_type := G_IRRELEVANT;
                END IF;

        END IF;

        RETURN l_merge_type;
END CHECK_PERSON_PARTY_MERGE_TYPE;

-- Start of comments
--      API name : CHECK_COMPANY_PARTY_MERGE_TYPE
--
--      Type        : Private
--
--      Pre-reqs  : Given Company Party Id(p_from_id, to_from_id)
--                        must exists in the HZ_PARTIES table
--
--      Function  : This function will expect and accept to company party id
--                       (merge from party id and merge to party id) and it will
--                       return following values depending on the the situation
--                       given -
--
--     Scenario                       Return Value
--    --------------------------     -------------------------
--    From and To parties are
--    Buer Companies         -   INCOMPATIBLE
--
--    From and To parties are
--    Supplier Companies   -  SELLER
--
--    From party is Buyer
--    and To party is Seller
--    Company                   -   INCOMPATIBLE
--
--    From party is Seller
--    and To party is Buyer
--    Companies                -   INCOMPATIBLE
--
--    From party is not
--    a Seller  and
--    From party is not
--    a Buyer Company
--    But
--    To party is a Seller
--    OR To party is
--    a Buyer Company     -   INCOMPATIBLE
--
--    From party is not
--    a Seller or Buyer
--    user
--    AND
--    To party is not a
--    Buyer
--    OR Seller
--    Companies               -  IRRELEVANT
--
--
--     Parameters:
--     IN     :      p_from_id             NUMBER   Required, the Merge From Party Id
--
--     IN     :      p_to_id                NUMBER   Required, the Merge To Party Id
--
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
FUNCTION CHECK_COMPANY_PARTY_MERGE_TYPE (
		      p_from_id 	   IN NUMBER,
		      p_to_id         IN NUMBER
                  )
                  RETURN VARCHAR2
IS
        l_merge_type       VARCHAR2(10);
        l_from_comp_type VARCHAR2(10);
        l_to_comp_type     VARCHAR2(10);
        l_counter              NUMBER;

        CURSOR CHECK_COMPANY_TYPE (p_party_id NUMBER)
        IS
            SELECT 'BUYER' AS COMPANY_TYPE
	    FROM
	       HZ_PARTIES USER_PARTIES,
	       HZ_CODE_ASSIGNMENTS
	    WHERE USER_PARTIES.PARTY_ID = p_party_id
                AND USER_PARTIES.PARTY_TYPE = 'ORGANIZATION'
	        AND HZ_CODE_ASSIGNMENTS.OWNER_TABLE_ID = USER_PARTIES.PARTY_ID
	        AND HZ_CODE_ASSIGNMENTS.OWNER_TABLE_NAME = 'HZ_PARTIES'
	        AND HZ_CODE_ASSIGNMENTS.CLASS_CATEGORY = 'POS_PARTICIPANT_TYPE'
	        AND HZ_CODE_ASSIGNMENTS.CLASS_CODE = 'ENTERPRISE'
            UNION
       	    SELECT 'SELLER' AS COMPANY_TYPE
	    FROM
	       PO_VENDORS
	    WHERE PARTY_ID = p_party_id;

BEGIN

        l_from_comp_type := 'NONE';
        l_to_comp_type := 'NONE';
        l_counter := 0;

        --
        -- open the user check cursor to determine user type
        --
        FOR comp IN CHECK_COMPANY_TYPE(p_from_id) LOOP
                l_from_comp_type := comp.COMPANY_TYPE;
                l_counter := l_counter + 1;

                EXIT WHEN (l_counter = 1); -- May be I can do a better construct here
        END LOOP;

        l_counter := 0;
        FOR comp IN CHECK_COMPANY_TYPE(p_to_id) LOOP
                l_to_comp_type := comp.COMPANY_TYPE;
                l_counter := l_counter + 1;

                EXIT WHEN (l_counter = 1); -- May be I can do a better construct here
        END LOOP;

        IF (l_from_comp_type = 'BUYER') THEN

                 l_merge_type := G_INCOMPATIBLE;

        ELSIF (l_from_comp_type = 'SELLER') THEN

                IF (l_to_comp_type = 'SELLER') THEN
                        l_merge_type := G_SELLER;
                ELSE
                        l_merge_type := G_INCOMPATIBLE;
                END IF;

        ELSE

                IF (l_to_comp_type = 'BUYER') THEN
                        l_merge_type := G_INCOMPATIBLE;
                --
                -- If it is not a Buyer/Seller to Seller merge then
                -- we have nothing to say as we will not have any transaction
                -- But, I dont know why this API will be called then?
                -- May be some data corruption hence raise veto
                --
                ELSIF (l_to_comp_type = 'SELLER' ) THEN
                        l_merge_type := G_INCOMPATIBLE;
                ELSE
                        l_merge_type := G_IRRELEVANT;
                END IF;

        END IF;

        RETURN l_merge_type;
END CHECK_COMPANY_PARTY_MERGE_TYPE;

-- Start of comments
--      API name : GET_USER_NAME
--
--      Type        : Private
--
--      Pre-reqs  : Given Company Party Id(p_user_party_id)
--                        must exists in the HZ_PARTIES table
--
--      Function  : This function will expect and accept to company party id
--                       (given user party id as present in HZ before merge) and it will
--                       return FND_USER.USER_NAME as it was BEFORE the merge
--                       operation started.
--                       It will reutn the FIRST user_name in case the given user party_id
--                       is mapped to more than one user in FND_USER table.
--                       It returns NULL if there are no user attached
--
--     Parameters:
--     IN     :      p_user_party_id        NUMBER   Required, the User Party Id
--
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
FUNCTION GET_USER_NAME (
		      p_user_party_id 	   IN NUMBER
                  )
                  RETURN VARCHAR2
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_user_name   FND_USER.USER_NAME%TYPE;
BEGIN

          BEGIN
                   SELECT
                      fu.USER_NAME
                   INTO
                      l_user_name
                   FROM FND_USER fu,
                   HZ_PARTIES hz
                   WHERE fu.PERSON_PARTY_ID=hz.PARTY_ID
                   AND hz.PARTY_ID= p_user_party_id
                   AND ROWNUM = 1;
          EXCEPTION
                   WHEN OTHERS THEN
                        l_user_name := NULL;
          END;

          RETURN l_user_name;
END GET_USER_NAME;

-- Start of comments
--      API name : GET_USER_ID
--
--      Type        : Private
--
--      Pre-reqs  : Given Company Party Id(p_user_party_id)
--                        must exists in the HZ_PARTIES table
--
--      Function  : This function will expect and accept to company party id
--                  (given user party id as present in HZ before merge) and it will
--                  return FND_USER.USER_ID as it was BEFORE the merge
--                  operation started.
--                  It will reutn the FIRST user_id in case the given user party_id
--                  is mapped to more than one user in FND_USER table.
--                  It returns NULL if there are no user attached
--
--     Parameters:
--     IN     :      p_user_party_id        NUMBER   Required, the User Party Id
--
--
--	Version	: Current version	1.0
--                Previous version 	1.0
--                Initial version 	1.0
--
-- End of comments
FUNCTION GET_USER_ID (
	          p_user_party_id 	   IN NUMBER
                  )
                  RETURN NUMBER
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_user_id   FND_USER.USER_ID%TYPE;
BEGIN

          BEGIN
                   SELECT
                      fu.USER_ID
                   INTO
                      l_user_id
                   FROM FND_USER fu,
                   HZ_PARTIES hz
                   WHERE fu.PERSON_PARTY_ID=hz.PARTY_ID
                   AND hz.PARTY_ID= p_user_party_id
                   AND ROWNUM = 1;
          EXCEPTION
                   WHEN OTHERS THEN
                        l_user_id := NULL;
          END;

          RETURN l_user_id;
END GET_USER_ID;

-- Start of comments
--      API name : HAS_MULTIPLE_FND_USERS
--
--      Type        : Private
--
--      Pre-reqs  : Given Company Party Id(p_user_party_id)
--                  must exists in the HZ_PARTIES table
--
--      Function  : This function will accept a user party id
--                  (given user party id as present in HZ before merge) and it will
--                  return true if there are multiple FND_USERs associated with
--                  given user party id (p_user_party_id)
--                  It will reutn false otherwise even if there are no FND_USER
--                  associated
--
--     Parameters:
--     IN     :      p_user_party_id        NUMBER   Required, the User Party Id
--
--
--	Version	: Current version	1.0
--                Previous version 	1.0
--	          Initial version 	1.0
--
-- End of comments
FUNCTION HAS_MULTIPLE_FND_USERS (
	          p_user_party_id 	   IN NUMBER
                  )
                  RETURN BOOLEAN
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        l_user_name_count   NUMBER;
BEGIN

          BEGIN
                   SELECT
                      COUNT(fu.USER_NAME)
                   INTO
                      l_user_name_count
                   FROM FND_USER fu,
                   HZ_PARTIES hz
                   WHERE fu.PERSON_PARTY_ID=hz.PARTY_ID
                   AND hz.PARTY_ID= p_user_party_id;
          EXCEPTION
                   WHEN OTHERS THEN
                        l_user_name_count := 0;
          END;

          IF (l_user_name_count > 1) THEN
                  RETURN TRUE;
          ELSE
                  RETURN FALSE;
          END IF;
END HAS_MULTIPLE_FND_USERS;


-- Start of comments
--      API name : MERGE_NEG_TEAM_FND_USER
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given trading_partner_contact_id
--                  (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the USER_ID
--                  column of PON_NEG_TEAM_MEMBERS table.
--
--                  It will NOT veto Party Merge in any case
--                  This will merge the all the PON_NEG_TEAM_MEMBERS records
--                  having USER_ID equals to the only FND_USER mapped to p_From_FK_id
--                  to only FND_USER mapped to party id having value (p_To_FK_id).
--                  It will NOT merge the USER_ID information if any of the merging parties
--                  have more than one FND_USER record mapped to one person in HZ_PARTIES.
--
--                  It will not trown any error/exception in such scenario and will silently ignore
--                  merge.
--
--                  The procedure will not update PON_NEG_TEAM_MEMBERS.USER_ID
--                  if there is a functional unique/primary key violation while updating the records.
--
--     Parameters:
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                  Party Site, etc.) when merge is executed
--
--	Version	: Current version	1.0
--                Previous version 	1.0
--	          Initial version 	1.0
--
-- End of comments
PROCEDURE MERGE_NEG_TEAM_FND_USER (
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER)
IS
        l_to_user_id         FND_USER.USER_ID%TYPE;
        l_from_user_id       FND_USER.USER_ID%TYPE;

BEGIN
--{start of procedure

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.MERGE_NEG_TEAM_FND_USER ');
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);

        --
        -- We will be updating the user_id column of pon_neg_team_members table
        -- if there are only one FND_USER associated with the merge from ot merge to party id.
        -- We will not touch the pon_neg_team_members otherwise.
        --
        fnd_file.put_line (fnd_file.log,  '10 : Buyer Merge - Calling HAS_MULTIPLE_FND_USERS function');

        IF (HAS_MULTIPLE_FND_USERS(p_To_FK_id) = FALSE  AND
             HAS_MULTIPLE_FND_USERS(p_From_FK_id) = FALSE) THEN
                fnd_file.put_line (fnd_file.log,  '20 : Buyer Merge - Merge From and Merge To Party has one FND_USER');
                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge - Merging PON_NEG_TEAM_MEMBERS table');

                l_from_user_id := GET_USER_ID(p_From_FK_id);
                l_to_user_id := GET_USER_ID(p_To_FK_id);

                IF (l_from_user_id IS NOT NULL   AND
                     l_to_user_id IS NOT NULL ) THEN

                        --
                        -- That means we have exactly only one fnd user for each of the merging parties
                        --
                        fnd_file.put_line (fnd_file.log,  '40 : Buyer Merge - Both the parties have only one fnd user each');

                        UPDATE PON_NEG_TEAM_MEMBERS pntm
                        SET pntm.USER_ID = l_to_user_id
                        WHERE pntm.USER_ID = l_from_user_id
                        AND   NOT EXISTS (SELECT 'DUPLICATE'
                                          FROM PON_NEG_TEAM_MEMBERS pntm1
                                          WHERE pntm.auction_header_id = pntm1.auction_header_id
                                          AND  pntm1.USER_ID = l_to_user_id);

                        fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated USER IDs in PON_NEG_TEAM_MEMBERS: '||sql%rowcount||' rows');

                END If;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        --
        -- We need add some Sourcing specific message for this
        --
        fnd_file.put_line (fnd_file.log,  '60 : Error in PON_TCA_PARTY_MERGE.MERGE_NEG_TEAM_FND_USER SQLERRM:'||SQLERRM);
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

--} end of procedure
END MERGE_NEG_TEAM_FND_USER;


-- Start of comments
--      API name : NEG_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_HEADERS_ALL entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_AUCTION_HEADERS_ALL records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_TPC_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);
        l_user_name        FND_USER.USER_NAME%TYPE;
        l_to_user_id     FND_USER.USER_ID%TYPE;
        l_from_user_id     FND_USER.USER_ID%TYPE;

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_TPC_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Seller Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_AUCTION_HEADERS_ALL.TRADING_PARTNER_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN
                --
                -- Now transact the data we have
                --
                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge - Getting User Name from FND');

                l_user_name := GET_USER_NAME(p_To_FK_id);

                fnd_file.put_line (fnd_file.log,  '40 : Buyer Merge - User Name from FND:'||l_user_name);


                --
                -- If we do not get the l_user_name name then the
                -- following SQLs will not be executed. Moreover,
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_AUCTION_HEADERS_ALL
                        SET TRADING_PARTNER_CONTACT_ID = p_To_FK_id,
                        LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATED_BY = -1,
                        TRADING_PARTNER_CONTACT_NAME = l_user_name
                WHERE TRADING_PARTNER_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated TPC IDs in PON_AUCTION_HEADERS_ALL: '||sql%rowcount||' rows');

                UPDATE PON_DISCUSSIONS
                        SET OWNER_PARTY_ID = p_To_FK_id,
                        LAST_UPDATE_DATE = SYSDATE
                WHERE OWNER_PARTY_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '60 : Buyer Merge - Updated TPC IDs in PON_DISCUSSIONS');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '70 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '70 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        --
        -- We need add some Sourcing specific message for this
        --
        fnd_file.put_line (fnd_file.log,  '80 : Error in PON_TCA_PARTY_MERGE.NEG_TPC_MERGE SQLERRM:'||SQLERRM);
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_TPC_MERGE;

-- Start of comments
--      API name : NEG_DRFT_LCK_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given draft_locked_by_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the DRAFT_LOCKED_BY_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_HEADERS_ALL entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_AUCTION_HEADERS_ALL records
--                        having DRAFT_LOCKED_BY_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_DRFT_LCK_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_DRFT_LCK_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Seller or Incompatible Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_AUCTION_HEADERS_ALL.DRAFT_LOCKED_BY_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN
                --
                -- Now transact the data we have
                --
                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge ');

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_AUCTION_HEADERS_ALL
                        SET LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATED_BY = -1,
                        DRAFT_LOCKED_BY_CONTACT_ID = p_To_FK_id
                WHERE DRAFT_LOCKED_BY_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '40 : Buyer Merge - Updated DRAFT_LOCKED_BY_CONTACT_IDs in PON_AUCTION_HEADERS_ALL: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '45 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '50 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        --
        -- We need add some Sourcing specific message for this
        --
        fnd_file.put_line (fnd_file.log,  '60 : Error in PON_TCA_PARTY_MERGE.NEG_DRFT_LCK_MERGE SQLERRM:'||SQLERRM);
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_DRFT_LCK_MERGE;

-- Start of comments
--      API name : NEG_DRFT_UNLCK_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given draft_unlocked_by_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the DRAFT_UNLOCKED_BY_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_HEADERS_ALL entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_AUCTION_HEADERS_ALL records
--                        having DRAFT_UNLOCKED_BY_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_DRFT_UNLCK_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_DRFT_UNLCK_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Seller or Incompatible Merge - Error');

                --
                -- This can not happen in any normal scenario as
                -- PON_AUCTION_HEADERS_ALL.DRAFT_UNLOCKED_BY_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge ');

                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_AUCTION_HEADERS_ALL
                        SET LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATED_BY = -1,
                        DRAFT_UNLOCKED_BY_CONTACT_ID = p_To_FK_id
                WHERE DRAFT_UNLOCKED_BY_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '40 : Buyer Merge - Updated DRAFT_UNLOCKED_BY_CONTACT_IDs in PON_AUCTION_HEADERS_ALL: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '45 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN

                fnd_file.put_line (fnd_file.log,  '50 : Irrelevent Merge');
                --
                -- Nothing to do
                --
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '60 : Error in PON_TCA_PARTY_MERGE.NEG_DRFT_UNLCK_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_DRFT_UNLCK_MERGE;


-- Start of comments
--      API name : NEG_SCORE_LCK_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation with the given scoring_lock_tp_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the SCORING_LOCK_TP_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_HEADERS_ALL entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_AUCTION_HEADERS_ALL records
--                        having SCORING_LOCK_TP_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_SCORE_LCK_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_SCORE_LCK_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                 fnd_file.put_line (fnd_file.log,  '20 : Seller Merge - Error');

                --
                -- This can not happen in any normal scenario as
                -- PON_AUCTION_HEADERS_ALL.SCORING_LOCK_TP_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN
                --
                -- Now transact the data we have
                --
                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge ');

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_AUCTION_HEADERS_ALL
                        SET LAST_UPDATE_DATE = SYSDATE,
                        LAST_UPDATED_BY = -1,
                        SCORING_LOCK_TP_CONTACT_ID = p_To_FK_id
                WHERE SCORING_LOCK_TP_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '40 : Buyer Merge - Updated SCORING_LOCK_TP_CONTACT_IDs in PON_AUCTION_HEADERS_ALL: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '45 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);


        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '50 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '60 : Error in PON_TCA_PARTY_MERGE.NEG_SCORE_LCK_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_SCORE_LCK_MERGE;


-- Start of comments
--      API name : NEG_EVENT_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotiation Event with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_EVENTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_AUCTION_EVENTS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_EVENT_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);
        l_person_name VARCHAR2(300);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_EVENT_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Seller Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_AUCTION_EVENTS.TRADING_PARTNER_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge - Getting Person Name from HZ_PARTIES');
                --
                -- Now transact the data we have
                --
		SELECT
                        hz.person_first_name ||' '|| hz.person_last_name as person_name
                INTO
                        l_person_name
                FROM HZ_PARTIES hz
                WHERE hz.PARTY_ID= p_To_FK_id;

                fnd_file.put_line (fnd_file.log,  '40 : Buyer Merge - Person Name from HZ:'|| l_person_name);
                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_AUCTION_EVENTS
	                SET TRADING_PARTNER_CONTACT_ID = p_To_FK_id,
                                LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
	                        TRADING_PARTNER_CONTACT_NAME = l_person_name
	        WHERE TRADING_PARTNER_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated TRADING_PARTNER_CONTACT_IDs in PON_AUCTION_EVENTS: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.NEG_EVENT_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_EVENT_MERGE;

-- Start of comments
--      API name : BIDDER_LST_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Bidders List with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_BIDDERS_LISTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_BIDDERS_LISTS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE BIDDER_LST_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.BIDDER_LST_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

         fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Seller Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_BIDDERS_LISTS.TRADING_PARTNER_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN
                --
                -- Now transact the data we have
                --
                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge ');
                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                -- TRADING_PARTNER_CONTACT_NAME field is always null
                -- in the table hence it is not updated here to maintain the
                -- consistency
                --
                UPDATE PON_BIDDERS_LISTS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                TRADING_PARTNER_CONTACT_ID = p_To_FK_id
	        WHERE TRADING_PARTNER_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated TPC IDs in PON_BIDDERS_LISTS: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.BIDDER_LST_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END BIDDER_LST_MERGE;


-- Start of comments
--      API name : NEG_ATTR_LST_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Attributes List with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_ATTRIBUTE_LISTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_ATTRIBUTE_LISTS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_ATTR_LST_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_ATTR_LST_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Seller Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_ATTRIBUTE_LISTS.TRADING_PARTNER_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge');

                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_ATTRIBUTE_LISTS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                TRADING_PARTNER_CONTACT_ID = p_To_FK_id
	        WHERE TRADING_PARTNER_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated TPC IDs in PON_ATTRIBUTE_LISTS: '||sql%rowcount||' rows');


        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.NEG_ATTR_LST_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_ATTR_LST_MERGE;

-- Start of comments
--      API name : RES_SURROG_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given surrog_bid_created_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the SURROG_BID_CREATED_CONTACT_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having SURROG_BID_CREATED_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_SURROG_MERGE  (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.RES_SURROG_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Seller Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_BID_HEADERS.SURROG_BID_CREATED_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN
                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge ');
                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_BID_HEADERS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                SURROG_BID_CREATED_CONTACT_ID = p_To_FK_id
	        WHERE SURROG_BID_CREATED_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated SURROG_BID_CREATED_CONTACT_IDs in PON_BID_HEADERS: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '55 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);


        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN


        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.RES_SURROG_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END RES_SURROG_MERGE;

-- Start of comments
--      API name : RES_SCORE_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given score_override_tp_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the SCORE_OVERRIDE_TP_CONTACT_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having SCORE_OVERRIDE_TP_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_SCORE_MERGE  (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.RES_SCORE_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Seller Merge - Error');

                --
                -- This can not happen in any normal scenario as
                -- PON_BID_HEADERS.SCORE_OVERRIDE_TP_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge ');

                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_BID_HEADERS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                SCORE_OVERRIDE_TP_CONTACT_ID = p_To_FK_id
	        WHERE SCORE_OVERRIDE_TP_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated SCORE_OVERRIDE_TP_CONTACT_IDs in PON_BID_HEADERS: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '55 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.RES_SCORE_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END RES_SCORE_MERGE;


-- Start of comments
--      API name : RES_SHRT_LIST_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given shortlist_tpc_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the SHORTLIST_TPC_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having SHORTLIST_TPC_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_SHRT_LIST_MERGE  (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.RES_SHRT_LIST_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Seller Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_BID_HEADERS.SHORTLIST_TPC_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN
                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge ');
                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_BID_HEADERS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                SHORTLIST_TPC_ID = p_To_FK_id
	        WHERE SHORTLIST_TPC_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated SHORTLIST_TPC_IDs in PON_BID_HEADERS: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '55 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.RES_SHRT_LIST_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END RES_SHRT_LIST_MERGE;

-- Start of comments
--      API name : NEG_CONTRCT_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Negotitions with the given authoring_party_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the AUTHORING_PARTY_CONTACT_ID
--                        merge for Sourcing PON_CONTRACTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_CONTRACTS records
--                        having AUTHORING_PARTY_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_CONTRCT_MERGE   (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_CONTRCT_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Seller Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_CONTRACTS.AUTHORING_PARTY_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge ');
                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_CONTRACTS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                AUTHORING_PARTY_CONTACT_ID = p_To_FK_id
	        WHERE AUTHORING_PARTY_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated AUTHORING_PARTY_CONTACT_IDs in PON_CONTRACTS: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '55 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.NEG_CONTRCT_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_CONTRCT_MERGE;


-- Start of comments
--      API name : NEG_DISC_THR_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Discussion Messages with the given owner_party_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the OWNER_PARTY_ID
--                        merge for Sourcing PON_THREADS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--                               OR
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_THREADS records
--                        having OWNER_PARTY_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_DISC_THR_MERGE (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_DISC_THR_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Incompatible Merge - Error');
                --
                -- This can not be passed. Thus, raising a veto.
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER OR l_merge_scenario = G_BUYER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Buyer or Seller Merge ');
                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --

                UPDATE PON_THREADS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                OWNER_PARTY_ID = p_To_FK_id
	        WHERE OWNER_PARTY_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated OWNER_PARTY_IDs in PON_THREADS: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.NEG_DISC_THR_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_DISC_THR_MERGE;

-- Start of comments
--      API name : NEG_DISC_THR_ENTRY_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Discussion Message Entries with the given from_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the FROM_ID
--                        merge for Sourcing PON_THREAD_ENTRIES entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--                               OR
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_THREAD_ENTRIES records
--                        having FROM_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_DISC_THR_ENTRY_MERGE  (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);
        l_first_name         HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
        l_last_name         HZ_PARTIES.PERSON_LAST_NAME%TYPE;

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_DISC_THR_ENTRY_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Incompatible Merge - Error');

                --
                -- This can not be passed. Thus, raising a veto.
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER OR l_merge_scenario = G_BUYER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Buyer or Seller Merge - Getting Person Name from HZ');

                SELECT
                        hz.PERSON_FIRST_NAME,
                        hz.PERSON_LAST_NAME
                INTO
                        l_first_name,
                        l_last_name
                FROM HZ_PARTIES hz
                WHERE hz.PARTY_ID= p_To_FK_id;

                fnd_file.put_line (fnd_file.log,  '40 : Buyer or Seller Merge - Person Name from HZ:'|| l_first_name||','||l_last_name);

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --

                --
                -- NOTE: There is no WHO columns in this table
                --
                UPDATE PON_THREAD_ENTRIES
	                SET FROM_ID = p_To_FK_id,
                               FROM_FIRST_NAME= l_first_name,
                               FROM_LAST_NAME=l_last_name
	        WHERE FROM_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated FROM_IDs in PON_THREAD_ENTRIES: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '55 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                IF ( l_merge_scenario = G_BUYER) THEN
                        MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                                 p_To_FK_id     => p_To_FK_id);
                END IF;


        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.NEG_DISC_THR_ENTRY_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_DISC_THR_ENTRY_MERGE;


-- Start of comments
--      API name : NEG_COMP_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Trading Partner ID entries with the given from_company_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_ID (p_From_FK_id)
--                        merge for different Sourcing entities (like PON_THREAD_ENTRIES etc.).
--
--                        It will veto Party Merge if -
--                               p_From_FK_id or p_To_FK_id is/are Buyer company party
--                               OR
--                               p_From_FK_id is Seller but p_To_FK_id is not Buyer or Seller party
--                               OR
--                               p_To_FK_id is Seller but p_From_FK_id is not Buyer or Seller party
--
--                        This will check the merge possibility for the entities
--                        having TRADING_PARTNER_ID equals to p_From_FK_id
--                        to TRADING_PARTNER_ID having value (p_To_FK_id). This will raise veto
--                        if the merge is not possible.
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_COMP_MERGE  (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);
        l_first_name         HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
        l_last_name         HZ_PARTIES.PERSON_LAST_NAME%TYPE;

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_COMP_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_COMPANY_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Incompatible Merge - Error');
                --
                -- This can not be passed. Thus, raising a veto.
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER OR l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Case 1. Both are Seller Companies - In that case the vendor merge routine
                --              must have been executed (ASSUMPTION) and AP will veto merge
                --              otherwise. Hence, we have nothing to do here.
                --
                -- Case 2. Both are Non Buyer/Seller Companies - In that case
                -- we dont care about the merge
                --
                fnd_file.put_line (fnd_file.log,  '30 : Buyer or Seller Merge - Ignore');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '40 : Error in PON_TCA_PARTY_MERGE.NEG_COMP_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_COMP_MERGE;

-- Start of comments
--      API name : NEG_DISC_TE_RCP_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Discussion Message Thread Entries with the given to_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TO_ID
--                        merge for Sourcing PON_TE_RECIPIENTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--                               OR
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_TE_RECIPIENTS records
--                        having TO_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_DISC_TE_RCP_MERGE   (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);
        l_first_name         HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
        l_last_name         HZ_PARTIES.PERSON_LAST_NAME%TYPE;

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_DISC_TE_RCP_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Incompatible Merge - Error');
                --
                -- This can not be passed. Thus, raising a veto.
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER OR l_merge_scenario = G_BUYER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Buyer or Seller Merge - Getting Person Name from HZ');

                SELECT
                        hz.PERSON_FIRST_NAME,
                        hz.PERSON_LAST_NAME
                INTO
                        l_first_name,
                        l_last_name
                FROM HZ_PARTIES hz
                WHERE hz.PARTY_ID= p_To_FK_id;

                fnd_file.put_line (fnd_file.log,  '40 : Buyer or Seller Merge - Person Name from HZ:'|| l_first_name||','||l_last_name);

                --
                -- there is no chance of unique key constraint violation
                -- due to the following constraints. We will not update
                -- the to_id where a {entry_id, to_id} violation is possible
                --

                --
                -- NOTE: There is no WHO columns in this table
                --
                UPDATE PON_TE_RECIPIENTS te
                        SET  te.TO_ID = p_To_FK_id,
                                te.TO_FIRST_NAME = l_first_name,
                                te.TO_LAST_NAME = l_last_name
                WHERE    te.TO_ID = p_From_FK_id
                AND      NOT EXISTS (SELECT 'duplicate'
                                        FROM PON_TE_RECIPIENTS te1
                                        WHERE te1.ENTRY_ID = te.ENTRY_ID
                                        AND   te1.TO_ID = p_To_FK_id);

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated TO_IDs in PON_TE_RECIPIENTS: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '55 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.NEG_DISC_TE_RCP_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_DISC_TE_RCP_MERGE;


--      API name : RES_SURR_ACK_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given surrog_bid_ack_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the SURROG_BID_ACK_CONTACT_ID
--                        merge for Sourcing PON_ACKNOWLEDGEMENTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_ACKNOWLEDGEMENTS records
--                        having SURROG_BID_ACK_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_SURR_ACK_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.RES_SURR_ACK_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Incompatible or Seller Merge - Error');

                --
                -- This can not happen in any normal scenario as
                -- PON_ACKNOWLEDGEMENTS.SURROG_BID_ACK_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge ');
                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_ACKNOWLEDGEMENTS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                SURROG_BID_ACK_CONTACT_ID = p_To_FK_id
	        WHERE SURROG_BID_ACK_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated SURROG_BID_ACK_CONTACT_IDs in PON_ACKNOWLEDGEMENTS: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '55 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.RES_SURR_ACK_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END RES_SURR_ACK_MERGE;

-- Start of comments
--      API name : NEG_SUPP_ACC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Supplier Access Lock entries with the given buyer_tp_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the BUYER_TP_CONTACT_ID
--                        merge for Sourcing PON_SUPPLIER_ACCESS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Buyer user party
--
--                        This will merge the all the PON_SUPPLIER_ACCESS records
--                        having BUYER_TP_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE NEG_SUPP_ACC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.NEG_SUPP_ACC_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_SELLER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Incompatible or Seller Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_SUPPLIER_ACCESS.BUYER_TP_CONTACT_ID
                -- can never contain a seller user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_BUYER) THEN
                fnd_file.put_line (fnd_file.log,  '30 : Buyer Merge ');
                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_SUPPLIER_ACCESS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                BUYER_TP_CONTACT_ID = p_To_FK_id
	        WHERE BUYER_TP_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Buyer Merge - Updated BUYER_TP_CONTACT_IDs in PON_SUPPLIER_ACCESS: '||sql%rowcount||' rows');

                --
                -- We will be updating the user_id column of pon_neg_team_members table
                -- if there are only one FND_USER associated with the merge from ot merge to party id.
                -- We will not touch the pon_neg_team_members otherwise.
                --
                fnd_file.put_line (fnd_file.log,  '55 : Buyer Merge - Calling MERGE_NEG_TEAM_FND_USER procedure');

                MERGE_NEG_TEAM_FND_USER (p_From_FK_id => p_From_FK_id,
                                         p_To_FK_id     => p_To_FK_id);

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.NEG_SUPP_ACC_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END NEG_SUPP_ACC_MERGE;

-- Start of comments
--      API name : BID_PARTY_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Invitation List entries with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_BIDDING_PARTIES entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_BIDDING_PARTIES records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE BID_PARTY_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);
        l_person_name VARCHAR2(300);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.BID_PARTY_TPC_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        fnd_file.put_line (fnd_file.log,  '10.1 : Going to check merge scenario:');
        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_BUYER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Buyer Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_BIDDING_PARTIES.TRADING_PARTNER_CONTACT_ID
                -- can never contain a buyer user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Seller Merge - Getting Person Name from HZ');

                SELECT
                        hz.person_last_name  ||', '|| hz.person_first_name as person_name
                INTO
                        l_person_name
                FROM HZ_PARTIES hz
                WHERE hz.PARTY_ID= p_To_FK_id;

                fnd_file.put_line (fnd_file.log,  '40 : Seller Merge - Person Name from HZ:'|| l_person_name);
                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_BIDDING_PARTIES
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                TRADING_PARTNER_CONTACT_ID = p_To_FK_id,
                               TRADING_PARTNER_CONTACT_NAME = l_person_name
	        WHERE TRADING_PARTNER_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Seller Merge - Updated TRADING_PARTNER_CONTACT_IDs in PON_BIDDING_PARTIES: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                NULL;
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.BID_PARTY_TPC_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END BID_PARTY_TPC_MERGE;

-- Start of comments
--      API name : BID_PARTY_ACK_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Invitation List entries with the given ack_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the ACK_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_BIDDING_PARTIES entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_BIDDING_PARTIES records
--                        having ACK_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE BID_PARTY_ACK_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);
        l_person_name VARCHAR2(300);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.BID_PARTY_ACK_TPC_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_BUYER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Buyer or Incompatible Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_BIDDING_PARTIES.ACK_PARTNER_CONTACT_ID
                -- can never contain a buyer user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Seller Merge - Getting Person Name from HZ');

                SELECT
                        hz.person_last_name  ||', '|| hz.person_first_name as person_name
                INTO
                        l_person_name
                FROM HZ_PARTIES hz
                WHERE hz.PARTY_ID= p_To_FK_id;

                fnd_file.put_line (fnd_file.log,  '40 : Seller Merge - Person Name from HZ:'|| l_person_name);
                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_BIDDING_PARTIES
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                ACK_PARTNER_CONTACT_ID = p_To_FK_id,
                                ACK_PARTNER_CONTACT_NAME = l_person_name
	        WHERE ACK_PARTNER_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Seller Merge - Updated ACK_PARTNER_CONTACT_IDs in PON_BIDDING_PARTIES: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.BID_PARTY_ACK_TPC_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END BID_PARTY_ACK_TPC_MERGE;

-- Start of comments
--      API name : RES_UNLCK_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given draft_unlocked_by_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the DRAFT_UNLOCKED_BY_CONTACT_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller or Buyer user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having DRAFT_UNLOCKED_BY_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_UNLCK_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.RES_UNLCK_TPC_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id    => p_From_FK_id,
                                                              p_to_id      => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Incompatible Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_BID_HEADERS.DRAFT_UNLOCKED_BY_CONTACT_ID
                -- can never contain a buyer user id which is merged to a seller user.
                -- Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER OR l_merge_scenario = G_BUYER ) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Seller Merge ');
                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_BID_HEADERS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                DRAFT_UNLOCKED_BY_CONTACT_ID = p_To_FK_id
	        WHERE DRAFT_UNLOCKED_BY_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Seller Merge - Updated DRAFT_UNLOCKED_BY_CONTACT_IDs in PON_BID_HEADERS: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.RES_UNLCK_TPC_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END RES_UNLCK_TPC_MERGE;


-- Start of comments
--      API name : RES_LCK_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given draft_locked_by_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the DRAFT_LOCKED_BY_CONTACT_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller or Buyer user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having DRAFT_LOCKED_BY_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_LCK_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.RES_LCK_TPC_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id    => p_From_FK_id,
                                                              p_to_id      => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Incompatible Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_BID_HEADERS.DRAFT_LOCKED_BY_CONTACT_ID
                -- can never contain a buyer user id which is merged to a seller user id.
                -- Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER OR l_merge_scenario = G_BUYER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Seller Merge ');
                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_BID_HEADERS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                DRAFT_LOCKED_BY_CONTACT_ID = p_To_FK_id
	        WHERE DRAFT_LOCKED_BY_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Seller Merge - Updated DRAFT_LOCKED_BY_CONTACT_IDs in PON_BID_HEADERS: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.RES_LCK_TPC_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END RES_LCK_TPC_MERGE;

-- Start of comments
--      API name : RES_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Responses with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_BID_HEADERS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_BID_HEADERS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);
        l_user_name        FND_USER.USER_NAME%TYPE;

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.RES_TPC_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_BUYER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Buyer or Incompatible Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_BID_HEADERS.TRADING_PARTNER_CONTACT_ID
                -- can never contain a buyer user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Seller Merge - Getting User Name from FND');

                l_user_name := GET_USER_NAME(p_To_FK_id);

                fnd_file.put_line (fnd_file.log,  '40 : Seller Merge - User Name from FND:'||l_user_name);

                --
                -- Now transact the data we have
                --

                --
                -- there is no chance of unique key constraint violation
                -- due to the following constraints. We should not produce
                -- two active bids from the same supplier but different trading
                -- partner contact id
                --

                UPDATE PON_BID_HEADERS  pb
	                SET  pb.LAST_UPDATE_DATE = SYSDATE,
                                pb.LAST_UPDATED_BY = -1,
                                pb.TRADING_PARTNER_CONTACT_ID = p_To_FK_id,
                                pb.TRADING_PARTNER_CONTACT_NAME = l_user_name
	        WHERE pb.TRADING_PARTNER_CONTACT_ID = p_From_FK_id
                AND   NOT EXISTS (SELECT 'DUPLICATE'
                                  FROM PON_BID_HEADERS pb1
                                  WHERE pb1.AUCTION_HEADER_ID = pb.AUCTION_HEADER_ID
                                  AND      pb1.TRADING_PARTNER_ID <> pb.TRADING_PARTNER_ID
                                  AND      pb1.TRADING_PARTNER_CONTACT_ID = p_To_FK_id
                                  AND      pb1.BID_STATUS = 'ACTIVE');


                fnd_file.put_line (fnd_file.log,  '50 : Seller Merge - Updated TRADING_PARTNER_CONTACT_IDs in PON_BID_HEADERS: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.RES_TPC_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END RES_TPC_MERGE;

-- Start of comments
--      API name : OPTMZ_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Optimization Scenario with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_OPTIMIZE_CONSTRAINTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_OPTIMIZE_CONSTRAINTS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE OPTMZ_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.OPTMZ_TPC_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_BUYER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Buyer or Incompatible Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_OPTIMIZE_CONSTRAINTS.TRADING_PARTNER_CONTACT_ID
                -- can never contain a buyer user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Seller Merge ');

                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --
                UPDATE PON_OPTIMIZE_CONSTRAINTS
	                SET  LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATED_BY = -1,
                                TRADING_PARTNER_CONTACT_ID = p_To_FK_id
	        WHERE TRADING_PARTNER_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Seller Merge - Updated TRADING_PARTNER_CONTACT_IDs in PON_OPTIMIZE_CONSTRAINTS: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.OPTMZ_TPC_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END OPTMZ_TPC_MERGE;

-- Start of comments
--      API name : RES_ACK_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Invitation Response  with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_ACKNOWLEDGEMENTS entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_ACKNOWLEDGEMENTS records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE RES_ACK_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.RES_ACK_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_BUYER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Buyer or Incompatible Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_ACKNOWLEDGEMENTS.TRADING_PARTNER_CONTACT_ID
                -- can never contain a buyer user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Seller Merge ');
                --
                -- there is no chance of unique key constraint violation
                -- due to the following logic - trading_partner_contact_id should not
                -- clash in an auction_header_id (PON_ACKNOWLEDGEMENTS_U1 violation)
                --
                UPDATE PON_ACKNOWLEDGEMENTS pa
                        SET  pa.LAST_UPDATE_DATE = SYSDATE,
                                pa.LAST_UPDATED_BY = -1,
                                pa.TRADING_PARTNER_CONTACT_ID = p_To_FK_id
                WHERE pa.TRADING_PARTNER_CONTACT_ID = p_From_FK_id
                AND   NOT EXISTS ( SELECT 'DUPLICATE'
                                   FROM PON_ACKNOWLEDGEMENTS pa1
                                   WHERE pa1.AUCTION_HEADER_ID = pa.AUCTION_HEADER_ID
                                   AND pa1.TRADING_PARTNER_CONTACT_ID = p_To_FK_id );


                fnd_file.put_line (fnd_file.log,  '50 : Seller Merge - Updated TRADING_PARTNER_CONTACT_IDs in PON_ACKNOWLEDGEMENTS: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.RES_ACK_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END RES_ACK_MERGE;

-- Start of comments
--      API name : AUC_SUMM_TPC_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Award Summary records with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_AUCTION_SUMMARY entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_AUCTION_SUMMARY records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE AUC_SUMM_TPC_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.AUC_SUMM_TPC_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_BUYER  OR l_merge_scenario = G_INCOMPATIBLE) THEN
                fnd_file.put_line (fnd_file.log,  '20 : Buyer or Incompatible Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_AUCTION_SUMMARY.TRADING_PARTNER_CONTACT_ID
                -- can never contain a buyer user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Seller Merge ');
                --
                -- there is no chance of unique key constraint violation
                -- due to the following updates
                --

                --
                -- NOTE: The table does not have WHO columns
                --
                UPDATE PON_AUCTION_SUMMARY
	                SET  TRADING_PARTNER_CONTACT_ID = p_To_FK_id
	        WHERE TRADING_PARTNER_CONTACT_ID = p_From_FK_id;

                fnd_file.put_line (fnd_file.log,  '50 : Seller Merge - Updated TRADING_PARTNER_CONTACT_IDs in PON_AUCTION_SUMMARY: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.AUC_SUMM_TPC_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END AUC_SUMM_TPC_MERGE;


-- Start of comments
--      API name : SUP_ACT_MERGE
--
--      Type        : Group
--
--      Pre-reqs  : Supplier Activity records with the given trading_partner_contact_id
--                        (p_From_FK_id) must exists in the database
--
--      Function  : This procedure will be attached to the TRADING_PARTNER_CONTACT_ID
--                        merge for Sourcing PON_SUPPLIER_ACTIVITIES entity.
--
--                        It will veto Party Merge if -
--                               p_From_FK_id and p_To_FK_id both are not Seller user party
--
--                        This will merge the all the PON_SUPPLIER_ACTIVITIES records
--                        having TRADING_PARTNER_CONTACT_ID equals to p_From_FK_id
--                        to party id having value (p_To_FK_id)
--
--     Parameters:
--     IN     :      p_Entity_name      VARCHAR2   Required, the Entity name from
--                                                  TCA Merge Dictionary that is going to merge
--
--     IN     :      p_from_id              NUMBER   Required, the value of PK of the record
--                                                   which is going to be merged
--
--     IN OUT :   x_to_id                  NUMBER   Required, the value of PK of the record
--                                                   to which the p_from_id party is going to be merged
--
--     IN     :      p_From_FK_id        NUMBER   Required,  value of the from ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_To_FK_id            NUMBER   Required, 	Value of the to ID (e.g. Party,
--                                                   Party Site, etc.) when merge is executed
--
--     IN     :      p_Entity_name       VARCHAR2   Required, 	Name of parent HZ
--                                                   table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
--
--     IN     :      p_batch_id            NUMBER   Required,  ID of the batch in which the
--                                                   Party Merge is executed
--
--     IN     :      p_Batch_Party_id  NUMBER   Required,  	ID of the batch and Party record
--                                                   for which the Party Merge is executed
--
--     IN OUT :  x_return_status     VARCHAR2,  flag to indicate if the Party Merge procedure
--                                                  was successful or not; It can have the following values -
--
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR  (Not vetoed but
--                                                                                             failed due to Unexpected error)
--                                                         FND_API.G_RET_STS_ERROR (Failed as the procedure
--                                                                                             vetod the Party Merge)
--
--	Version	: Current version	1.0
--                        Previous version 	1.0
--		          Initial version 	1.0
--
-- End of comments
PROCEDURE SUP_ACT_MERGE    (
                      p_Entity_name	   IN VARCHAR2,
		      p_from_id 	   IN NUMBER,
		      x_to_id		   IN OUT NOCOPY NUMBER ,
		      p_From_FK_id	   IN NUMBER,
		      p_To_FK_id	   IN NUMBER,
		      p_Parent_Entity_name IN VARCHAR2,
		      p_batch_id	   IN NUMBER,
		      p_Batch_Party_id	   IN NUMBER,
		      x_return_status	   IN OUT NOCOPY VARCHAR2 )
IS
        l_merge_scenario VARCHAR2(20);

BEGIN
--{start of procedure

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        fnd_file.put_line (fnd_file.log,  'Start : PON_TCA_MERGE_PVT.SUP_ACT_MERGE ');
        fnd_file.put_line (fnd_file.log, ' p_Entity_name      '  || p_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_from_id  '  || p_from_id);
        fnd_file.put_line (fnd_file.log,  ' p_From_FK_id     '  || p_From_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_To_FK_id '  || p_To_FK_id);
        fnd_file.put_line (fnd_file.log, ' p_Parent_Entity_name       '  || p_Parent_Entity_name);
        fnd_file.put_line (fnd_file.log, ' p_batch_id   '  || p_batch_id);
        fnd_file.put_line (fnd_file.log,  ' p_Batch_Party_id  '  || p_Batch_Party_id);
        fnd_file.put_line (fnd_file.log, ' x_return_status  '  || x_return_status   );

        --
        -- check the merge scenario
        --
        l_merge_scenario := CHECK_PERSON_PARTY_MERGE_TYPE (
                                                              p_from_id 	   => p_From_FK_id,
                                                              p_to_id         => p_To_FK_id);

        fnd_file.put_line (fnd_file.log,  '10 : l_merge_scenario:'||l_merge_scenario);

        IF (l_merge_scenario = G_BUYER  OR l_merge_scenario = G_INCOMPATIBLE) THEN

                fnd_file.put_line (fnd_file.log,  '20 : Buyer or Incompatible Merge - Error');
                --
                -- This can not happen in any normal scenario as
                -- PON_SUPPLIER_ACTIVITIES.TRADING_PARTNER_CONTACT_ID
                -- can never contain a buyer user id. Thus, raising a veto though
                -- it will possibly never be called
                --
                FND_MESSAGE.SET_NAME('AR', 'PON_TCA_MRG_ERR'); -- Need to put some Sourcing Specific Error Message
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF (l_merge_scenario = G_SELLER) THEN

                fnd_file.put_line (fnd_file.log,  '30 : Seller Merge ');
                --
                -- there is no chance of unique key constraint violation
                -- due to the following logic
                --
                UPDATE PON_SUPPLIER_ACTIVITIES psa1
                       SET psa1.TRADING_PARTNER_CONTACT_ID = p_To_FK_id,
                              psa1.LAST_UPDATED_BY = -1,
                              psa1.LAST_UPDATE_DATE = sysdate
                WHERE psa1.TRADING_PARTNER_CONTACT_ID = p_From_FK_id
                AND   NOT EXISTS (SELECT 'DUPLICATE'
                                  FROM PON_SUPPLIER_ACTIVITIES psa2
                                  WHERE psa2.AUCTION_HEADER_ID_ORIG_AMEND = psa1.AUCTION_HEADER_ID_ORIG_AMEND
                                  AND      psa2.LAST_ACTIVITY_TIME = psa1.LAST_ACTIVITY_TIME
                                  AND      psa2.TRADING_PARTNER_ID = psa1.TRADING_PARTNER_ID
                                  AND      psa2.TRADING_PARTNER_CONTACT_ID = p_To_FK_id );


                fnd_file.put_line (fnd_file.log,  '50 : Seller Merge - Updated TRADING_PARTNER_CONTACT_IDs in PON_SUPPLIER_ACTIVITIES: '||sql%rowcount||' rows');

        ELSIF (l_merge_scenario = G_IRRELEVANT) THEN
                --
                -- Nothing to do
                --
                fnd_file.put_line (fnd_file.log,  '60 : Irrelevent Merge');
                NULL;
        END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_file.put_line (fnd_file.log,  '70 : Error in PON_TCA_PARTY_MERGE.SUP_ACT_MERGE SQLERRM:'||SQLERRM);
        --
        -- We need add some Sourcing specific message for this
        --
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--} end of procedure
END SUP_ACT_MERGE;



END PON_TCA_MERGE_PVT; --}

/
