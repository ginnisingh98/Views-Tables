--------------------------------------------------------
--  DDL for Package Body HZ_MERGE_DUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MERGE_DUP_PVT" AS
/* $Header: ARHCMBAB.pls 120.87.12010000.3 2009/08/11 00:12:07 awu ship $ */

  --Declaration of Private procedures
  PROCEDURE insert_party_details( cp_batch_party_id IN NUMBER,
                                  cp_from_party_id IN NUMBER,
                                  cp_to_party_id   IN NUMBER,
                                  p_def_to_entity  IN VARCHAR2 DEFAULT 'N');

  PROCEDURE insert_reln_parties(  p_batch_party_id       IN NUMBER,
                                  p_batch_id IN NUMBER);

  PROCEDURE insert_party_site_details (
        p_from_party_id      IN NUMBER,
        p_to_party_id        IN NUMBER,
        p_batch_party_id     IN NUMBER,
        p_reln_parties       IN VARCHAR2 DEFAULT 'N');

  PROCEDURE insert_party_reln_details (
        p_from_party_id     IN  NUMBER,
        p_to_party_id       IN  NUMBER,
        p_batch_party_id    IN  NUMBER,
        p_def_mapping       IN VARCHAR2 DEFAULT 'N');

  PROCEDURE insert_sugg_reln_ps_details (
        p_from_party_id            IN NUMBER,
        p_to_party_id              IN NUMBER,
        p_batch_party_id           IN NUMBER,
        p_reln_parties             IN VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE insert_sugg_reln_party(
        p_batch_id                 IN NUMBER,
        p_from_rel_party_id        IN NUMBER,
        p_to_rel_party_id          IN NUMBER,
        x_batch_party_id           OUT NOCOPY NUMBER
  );

--
-- PROCEDURE Create_Merge_Batch
--
-- DESCRIPTION
--      Creates a merge batch from a dup set
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_dup_set_id       ID of the duplicate set identified by DQM
--                        Duplicate Identification program
--     p_default_mapping  Y/N if the DQM smart search has to be enabled
--     p_batch_name       Parameter for the Batch name
--   OUT:
--     x_merge_batch_id  Phone country code.
--     x_return_status       Return status after the call. The status can
--                           be fnd_api.g_ret_sts_success (success),
--                           fnd_api.g_ret_sts_error (error),
--                           fnd_api.g_ret_sts_unexp_error
--                           (unexpected error).
--     x_msg_count           Number of messages in message stack.
--     x_msg_data            Message text if x_msg_count is 1.
--
-- NOTES
--
-- MODIFICATION HISTORY
--
--   04/01/2002    Jyoti Pandey      o Created.
--
--

PROCEDURE Create_Merge_Batch(
  p_dup_set_id            IN NUMBER,
  p_default_mapping       IN VARCHAR2,
  p_object_version_number IN OUT NOCOPY  NUMBER,
  x_merge_batch_id        OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2 ) IS

  l_merge_from HZ_DUP_SET_PARTIES.DUP_PARTY_ID%TYPE;
  l_merge_to   HZ_DUP_SET_PARTIES.DUP_PARTY_ID%TYPE;
  l_merge_type   HZ_DUP_SETS.MERGE_TYPE%TYPE;
  l_merge_type2  HZ_DUP_SETS.MERGE_TYPE%TYPE;
  l_count         NUMBER := 0;
  l_dup_set_count NUMBER;
  l_default_mapping VARCHAR2(1);
  l_party_type VARCHAR2(255);

  l_batch_id       HZ_MERGE_BATCH.BATCH_ID%TYPE;
  l_batch_name       HZ_MERGE_BATCH.BATCH_NAME%TYPE;
  l_batch_party_id HZ_DUP_SET_PARTIES.DUP_PARTY_ID%TYPE;
  l_object_version_number NUMBER;
  db_object_version_number NUMBER;
  l_automerge_flag varchar2(1);
  l_addr_match_rule      NUMBER := 0;
  l_reln_match_rule      NUMBER := 0;

  CURSOR c_batch_name IS
    SELECT substrb(party_name, 1, 60) || ' (' || p_dup_set_id||')',
           winner_party_id, merge_type
    FROM HZ_DUP_SETS, HZ_PARTIES
    WHERE winner_party_id = party_id
    AND dup_set_id = p_dup_set_id;

  cursor get_automerge_flag_csr is
	select nvl(db.automerge_flag,'N')
	from hz_dup_batch db, hz_dup_sets ds
	where db.dup_batch_id = ds.dup_batch_id
	and ds.dup_set_id = p_dup_set_id
	and rownum=1;

--Cursor to get the parties to be merged
  CURSOR get_merge_parties_csr(cp_winner_party_id NUMBER) IS
    SELECT DUP_PARTY_ID
    FROM HZ_DUP_SET_PARTIES
    WHERE DUP_SET_ID = p_dup_set_id
    AND nvl(MERGE_FLAG,'Y')<>'N';

 cursor sugg_request_exist_csr is
	 select count(*)
	 from hz_dup_batch db, hz_dup_sets ds
         where db.dup_batch_id = ds.dup_batch_id
         and db.match_rule_id = -1
         and db.dup_batch_name like 'SUGG:%'
         and ds.dup_set_id = p_dup_set_id;

l_count1 number := 0;
l_created_by_module varchar2(30) := 'DL';

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  fnd_msg_pub.initialize;
  l_batch_id := null;

  SAVEPOINT create_merge_batch;

  --check if the dup_set_id is valid
  OPEN c_batch_name;
  FETCH c_batch_name INTO l_batch_name, l_merge_to, l_merge_type;
  IF c_batch_name%NOTFOUND THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_BATCH_PARAM');
     FND_MESSAGE.SET_TOKEN('PARAMETER','DUP_SET_ID' );
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_batch_name;

  IF p_default_mapping = null THEN
     l_default_mapping := 'N';
  ELSE l_default_mapping := p_default_mapping;
  END IF;


  l_batch_id:= p_dup_set_id;

  open sugg_request_exist_csr;
  fetch sugg_request_exist_csr into l_count1;
  close sugg_request_exist_csr;

  if l_count1 <> 0
  then
	l_batch_name := 'SUGG: '|| l_batch_name;
        l_created_by_module := 'DL_SUGG';
  end if;



  --Create a merge batch in HZ_MERGE_BATCH
  HZ_MERGE_BATCH_PKG.INSERT_ROW(
          px_BATCH_ID         => l_batch_id,
          p_RULE_SET_NAME     => 'DEFAULT',
          p_BATCH_NAME        =>  l_batch_name,
          p_REQUEST_ID        => NULL,
          p_BATCH_STATUS      => 'MAPPING_PENDING',
          p_BATCH_COMMIT      => 'B',
          p_BATCH_DELETE      => 'N',
          p_MERGE_REASON_CODE => 'DEDUPE',
          p_CREATED_BY        => HZ_UTILITY_V2PUB.CREATED_BY,
          p_CREATION_DATE     => HZ_UTILITY_V2PUB.CREATION_DATE,
          p_LAST_UPDATE_LOGIN => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
          p_LAST_UPDATE_DATE  => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
          p_LAST_UPDATED_BY   => HZ_UTILITY_V2PUB.LAST_UPDATED_BY);

  -- update the created_by_module to 'DL' since this api is only used by data librarian
  -- to create merge batch data
  UPDATE HZ_MERGE_BATCH
  SET CREATED_BY_MODULE = l_created_by_module
  WHERE batch_id = p_dup_set_id;

  IF l_merge_type='PARTY_MERGE' THEN
    --Get Parties Merging in that batch
    OPEN  get_merge_parties_csr(l_merge_to);
    LOOP
      FETCH  get_merge_parties_csr INTO l_merge_from;
      EXIT WHEN get_merge_parties_csr%NOTFOUND;

      l_batch_party_id := null;
      -- New for J minipack. Add master party
      IF l_merge_from = l_merge_to THEN
        l_merge_type2 := 'SAME_PARTY_MERGE';
      ELSE
        l_merge_type2 := 'PARTY_MERGE';
      END IF;

      -- call table-handler to insert the record in HZ_MERGE_PARTIES
      HZ_MERGE_PARTIES_PKG.INSERT_ROW(
          px_BATCH_PARTY_ID   => l_batch_party_id,
          p_batch_id          => l_batch_id,
          p_merge_type        => l_merge_type2,
          p_from_party_id     => l_merge_from,
          p_to_party_id       => l_merge_to,
          p_merge_reason_code => 'DEDUPE',
          p_merge_status      => 'PENDING',
          p_CREATED_BY        => HZ_UTILITY_V2PUB.CREATED_BY,
          p_CREATION_DATE     => HZ_UTILITY_V2PUB.CREATION_DATE,
          p_LAST_UPDATE_LOGIN => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
          p_LAST_UPDATE_DATE  => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
          p_LAST_UPDATED_BY   => HZ_UTILITY_V2PUB.LAST_UPDATED_BY);

      --Call to insert details
      IF l_default_mapping = 'Y' THEN
        insert_party_details(l_batch_party_id,
                             l_merge_from ,
                             l_merge_to ,
                             'Y' );
      ELSE
        insert_party_details(l_batch_party_id,
                             l_merge_from ,
                             l_merge_to);
      END IF;

      --Call to insert relationships
      insert_reln_parties(l_batch_party_id ,
                         l_batch_id      );

    END LOOP;
    CLOSE  get_merge_parties_csr;

    open get_automerge_flag_csr;
    fetch get_automerge_flag_csr into l_automerge_flag;
    close get_automerge_flag_csr;

    if l_automerge_flag = 'N' or (l_automerge_flag = 'Y' and  nvl(fnd_profile.value('HZ_PROF_ATTR_DEFAULT'), 'MASTER') <> 'MASTER')
    then

    	SELECT decode(party_type,'PERSON','HZ_PERSON_PROFILES',
             'ORGANIZATION','HZ_ORGANIZATION_PROFILES',
             'HZ_ORGANIZATION_PROFILES') INTO l_party_type
    	FROM HZ_PARTIES
    	WHERE party_id=l_merge_to;

    	HZ_MERGE_ENTITY_ATTRI_PVT.create_merge_attributes(
        l_batch_id, l_merge_to, l_party_type,
        x_return_status, x_msg_count, x_msg_data);

    	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      		ROLLBACK to create_merge_batch;
      		RETURN;
    	END IF;
    end if; -- if l_automerge_flag = 'N'
  ELSIF l_merge_type='SAME_PARTY_MERGE' THEN

    l_batch_party_id := null;
    l_merge_from := l_merge_to;

    -- call table-handler to insert the record in HZ_MERGE_PARTIES
    HZ_MERGE_PARTIES_PKG.INSERT_ROW(
          px_BATCH_PARTY_ID   => l_batch_party_id,
          p_batch_id          => l_batch_id,
          p_merge_type        => 'SAME_PARTY_MERGE',
          p_from_party_id     => l_merge_from,
          p_to_party_id       => l_merge_to,
          p_merge_reason_code => 'DEDUPE',
          p_merge_status      => 'PENDING',
          p_CREATED_BY        => HZ_UTILITY_V2PUB.CREATED_BY,
          p_CREATION_DATE     => HZ_UTILITY_V2PUB.CREATION_DATE,
          p_LAST_UPDATE_LOGIN => HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
          p_LAST_UPDATE_DATE  => HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
          p_LAST_UPDATED_BY   => HZ_UTILITY_V2PUB.LAST_UPDATED_BY);

  END IF;
 if p_default_mapping = 'Y'
 then
  -- call suggested default to populate suggested default mapping
  -- to temp table HZ_MERGE_PARTIES_SUGG and HZ_MERGE_PARTYDTLS_SUGG
  suggested_defaults(l_batch_id, x_return_status, x_msg_count, x_msg_data);

  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
    ROLLBACK to create_merge_batch;
    RETURN;
  END IF;

  -- based on the profile value to decide if the user want to show
  -- suggested default mapping at the beginning
  -- or if automerge profile is on(pass 'Y' to p_default_mapping)
  -- and it's an automerge dupset.

  l_addr_match_rule := fnd_profile.value('HZ_SUGG_ADDR_MATCH_RULE');
  l_reln_match_rule := fnd_profile.value('HZ_SUGG_RELN_MATCH_RULE');

  -- Address
  IF(fnd_profile.value('HZ_SHOW_SUGG_ADDR') = 'Y'
    or (l_automerge_flag = 'Y' and l_addr_match_rule <>0 and l_addr_match_rule is not null )) THEN
    apply_suggested_default(l_batch_id, 'HZ_PARTY_SITES', x_return_status, x_msg_count, x_msg_data);
  END IF;
    -- Relationship
  IF(fnd_profile.value('HZ_SHOW_SUGG_RELN') = 'Y'
   or (l_automerge_flag = 'Y' and l_reln_match_rule <>0 and l_reln_match_rule is not null)) THEN
    apply_suggested_default(l_batch_id, 'HZ_PARTY_RELATIONSHIPS', x_return_status, x_msg_count, x_msg_data);
  END IF;

  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
    ROLLBACK to create_merge_batch;
    RETURN;
  END IF;
end if; -- p_default_mapping = 'Y'

  --get the object_version_number of the record in hz_dup_sets
  --for locking purpose

  SELECT object_version_number
  INTO   db_object_version_number
  FROM   hz_dup_sets
  WHERE  dup_set_id =  p_dup_set_id
  FOR UPDATE OF dup_set_id;

  --if the 2 object version numbers are same then continue
  --else raise exception
  IF (
      (db_object_version_number IS NULL AND p_object_version_number IS NULL )
       OR ( db_object_version_number IS NOT NULL AND
          p_object_version_number IS NOT NULL AND
          db_object_version_number = p_object_version_number )
     ) THEN

         l_object_version_number := NVL(p_object_version_number, 1) + 1;

         --Update the dup set table status and merge_batch_id column
         UPDATE HZ_DUP_SETS
         SET object_version_number = l_object_version_number
         WHERE dup_set_id = p_dup_set_id;

         p_object_version_number := l_object_version_number;
  ELSE
         FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
         FND_MESSAGE.SET_TOKEN('TABLE', 'hz_dup_sets');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
  END IF;

  ---Default mapping of the entities
  IF p_default_mapping = 'Y' THEN
     --call the smart search API for default mapping
    null;
  END IF;

  x_merge_batch_id := l_batch_id;

  -- standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK to create_merge_batch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK to create_merge_batch;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK to create_merge_batch;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

END Create_Merge_Batch;

--Start of DLProject Changes
FUNCTION isContactGroupRelType(p_from_rel_id NUMBER,p_to_rel_id NUMBER)
RETURN boolean
IS

cursor c_contact_rel(p_relationship_id NUMBER) IS
         select count(distinct code.owner_table_id)
	 from hz_code_assignments code
	 where code.class_category = 'RELATIONSHIP_TYPE_GROUP'
	 and   code.class_code = 'PARTY_REL_GRP_CONTACTS'
	 and   code.owner_table_name = 'HZ_RELATIONSHIP_TYPES'
	 and   exists ( select 1 from   hz_relationship_types rt,
			 HZ_RELATIONSHIPS r
			where  r.relationship_id = p_relationship_id
			and   r.relationship_type = rt.relationship_type
			and   r.relationship_code = rt.forward_rel_code
			and   r.subject_type = rt.subject_type
			and   r.object_type = rt.object_type
			and   r.directional_flag = decode(rt.direction_code, 'N','F',
							  r.directional_flag)
			and  code.owner_table_id = rt.relationship_type_id
		      );

l_flag boolean;
l_count NUMBER;
BEGIN
 l_flag := false;

 open c_contact_rel(p_from_rel_id);
 fetch c_contact_rel into l_count;
 if(l_count >0)then
  close c_contact_rel;
  open c_contact_rel(p_to_rel_id);
  fetch c_contact_rel into l_count;
  if(l_count >0)then
   l_flag := true;
  end if;
 end if;
 close c_contact_rel;
 return l_flag;
END;
--End of DLProject Changes

--
-- PROCEDURE map_detail_record
--
-- DESCRIPTION
--      Specifies Merging or transfer of merge from to the merge to
--      record.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_batch_party_id    Batch_Party_id from the merge tables
--     p_entity            Name of the entity HZ_PARTY_SITES,
--                         HZ_PARTY_RELATIONSHIPS etc.
--     p_from_entity_id    ID of the from record
--     p_to_entity_id      ID of the to record

--   OUT:
--     x_return_status       Return status after the call. The status can
--                           be fnd_api.g_ret_sts_success (success),
--                           fnd_api.g_ret_sts_error (error),
--                           fnd_api.g_ret_sts_unexp_error
--                           (unexpected error).
--     x_msg_count           Number of messages in message stack.
--     x_msg_data            Message text if x_msg_count is 1.
--
-- NOTES
--
-- MODIFICATION HISTORY
--
--   04/01/2002    Jyoti Pandey      o Created.
--
--   05/10/2005    S V Sowjanya      o Bug 4569674: Modified Tax jurisdiction validation
--

PROCEDURE map_detail_record(
  p_batch_party_id        IN NUMBER,
  p_entity                IN VARCHAR2,
  p_from_entity_id        IN NUMBER,
  p_to_entity_id          IN NUMBER,
  p_object_version_number IN OUT NOCOPY  NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2) IS

  l_total_count           NUMBER;
  l_count                 NUMBER;
  l_batch_id              NUMBER;
  l_status                HZ_MERGE_BATCH.BATCH_STATUS%TYPE;
  l_loc                   NUMBER;
  l_org                   NUMBER;
  l_object_version_number NUMBER;
  db_object_version_number NUMBER;

  l_from_rel_type         HZ_RELATIONSHIPS.RELATIONSHIP_CODE%TYPE;  --4500011
  l_to_rel_type           HZ_RELATIONSHIPS.RELATIONSHIP_CODE%TYPE; --4500011
  rel_batch_party_id      NUMBER;
  l_from_rel_party_id     NUMBER;
  l_to_rel_party_id       NUMBER;
  l_rel_party_count       NUMBER;

  l_mm VARCHAR2(255);
  l_tmp NUMBER;
  l_tmp2 NUMBER;
  l_merge_to NUMBER;
  l_dup_set_id NUMBER;
  l_check NUMBER;
  l_cust_sites NUMBER;

CURSOR c_address (cp_ps_id number) is
SELECT l.country,
       l.city,
       l.state,
       l.county,
       l.province,
       l.postal_code,
       ps.status,
       ps.location_id   --bug 4569674
FROM   hz_locations l
,      hz_party_sites ps
WHERE  ps.party_site_id   = cp_ps_id
  AND  ps.location_id     = l.location_id;

CURSOR c_cust_site_check IS
		select 1 from hz_cust_acct_sites_all where party_site_id=p_from_entity_id;


l_from_country     HZ_LOCATIONS.COUNTRY%TYPE;
l_to_country       HZ_LOCATIONS.COUNTRY%TYPE;
l_from_city        HZ_LOCATIONS.CITY%TYPE;
l_to_city          HZ_LOCATIONS.CITY%TYPE;
l_from_state       HZ_LOCATIONS.STATE%TYPE;
l_to_state         HZ_LOCATIONS.CITY%TYPE;
l_from_county      HZ_LOCATIONS.COUNTY%TYPE;
l_to_county        HZ_LOCATIONS.COUNTY%TYPE;
l_from_province    HZ_LOCATIONS.PROVINCE%TYPE;
l_to_province      HZ_LOCATIONS.PROVINCE%TYPE;
l_from_postal_code HZ_LOCATIONS.postal_code%TYPE;
l_to_postal_code   HZ_LOCATIONS.postal_code%TYPE;
l_from_ps_status   varchar2(1);
l_to_ps_status     varchar2(1);
l_strucutre_id     NUMBER;
l_qualifier        VARCHAR2(30);
l_err_flg          VARCHAR2(1) := 'N';

--bug 4569674
l_merge_yn        VARCHAR2(2);
l_from_location_id NUMBER;
l_to_location_id   NUMBER;

--Start of DLProject Changes
l_rel_type_count            NUMBER;
--End of DLProject Changes

BEGIN

  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT map_detail_record;

  SELECT distinct(batch_id)
  INTO l_batch_id
  FROM hz_merge_parties
  WHERE batch_party_id = p_batch_party_id;

  IF    (p_batch_party_id  is null) OR (l_batch_id IS NULL )
      OR (p_entity is null) OR (p_from_entity_id IS NULL)     THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_BATCH_PARAM');
     FND_MESSAGE.SET_TOKEN('PARAMETER', 'BATCH_PARTY_ID');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  BEGIN
    SELECT mandatory_merge, merge_to_entity_id INTO l_mm, l_merge_to
    FROM hz_merge_party_details
    where batch_party_id=p_batch_party_id
    AND entity_name = p_entity
    AND merge_from_entity_id = p_from_entity_id;

    IF l_mm = 'Y' THEN
      FND_MESSAGE.set_name('AR','HZ_MAND_MERGE_ERROR');
      FND_MESSAGE.set_token('ENTITY1',p_from_entity_id);
      FND_MESSAGE.set_token('ENTITY2',p_to_entity_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_from_entity_id = l_merge_to THEN
      /* Check if any entity is merged to p_from_entity_id */
      SELECT count(1) INTO l_tmp
      FROM hz_merge_party_details md1, hz_merge_party_details md2,
           hz_merge_parties mp1, hz_merge_parties mp2
      where md1.batch_party_id=p_batch_party_id
      AND md1.batch_party_id = mp1.batch_party_id
      AND mp1.batch_id = mp2.batch_id
      AND md2.batch_party_id=mp2.batch_party_id
      AND md2.entity_name = p_entity
      AND md2.merge_to_entity_id = p_from_entity_id
      AND md2.merge_from_entity_id<>p_from_entity_id;

      /* Check if p_to_entity_id is merged to another entity */
      SELECT count(1) INTO l_tmp2
      FROM hz_merge_party_details md1, hz_merge_party_details md2,
           hz_merge_parties mp1, hz_merge_parties mp2
      where md1.batch_party_id=p_batch_party_id
      AND md1.batch_party_id = mp1.batch_party_id
      AND mp1.batch_id = mp2.batch_id
      AND md2.batch_party_id=mp2.batch_party_id
      AND md2.entity_name = p_entity
      AND md2.merge_from_entity_id = p_to_entity_id
      AND md2.merge_to_entity_id<>p_to_entity_id;

      IF l_tmp>0 OR l_tmp2>0 THEN
        FND_MESSAGE.set_name('AR','HZ_CANNOT_UNMAP_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_BATCH_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAMETER', 'MERGE_FROM_ENTITY_ID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END;

  ---Validation for locations/Party sites
  IF p_entity = 'HZ_PARTY_SITES' THEN
   IF p_to_entity_id IS NOT NULL THEN
     OPEN c_cust_site_check;
       Fetch c_cust_site_check into l_cust_sites;
     IF c_cust_site_check %NOTFOUND THEN
       null;
     ELSE
       OPEN  c_address (p_from_entity_id);
       FETCH c_address INTO l_from_country,l_from_city,l_from_state,
                            l_from_county,l_from_province,l_from_postal_code, l_from_ps_status, l_from_location_id;
       CLOSE c_address;

       OPEN  c_address (p_to_entity_id);
       FETCH c_address INTO l_to_country,l_to_city,l_to_state,
                            l_to_county,l_to_province,l_to_postal_code, l_to_ps_status, l_to_location_id;
       CLOSE c_address;

       if l_from_ps_status = 'A' and l_to_ps_status = 'I'
       then
	    FND_MESSAGE.set_name('AR','HZ_DL_ADDR_MASTER_ERR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       end if;
--bug 4569674
       l_merge_yn := null;

       ZX_MERGE_LOC_CHECK_PKG.CHECK_GNR(l_from_location_id,
                                 	 l_to_location_id,
                                      	 FND_API.G_FALSE,
                                       	 l_merge_yn,
              			 	 x_return_status,
              			 	 x_msg_count,
              			 	 x_msg_data);
       IF l_merge_yn = 'N' THEN
               FND_MESSAGE.set_name('AR','HZ_PS_LOC_ASSIGN_ERROR');
               FND_MSG_PUB.ADD;
       	       RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
        ELSIF  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
--bug 4569674
      END IF;
     END IF;
     CLOSE c_cust_site_check;
  ELSIF p_entity = 'HZ_PARTY_RELATIONSHIPS' then

     l_from_rel_party_id :=
                        HZ_MERGE_UTIL.get_reln_party_id(p_from_entity_id);
     l_to_rel_party_id   :=
                        HZ_MERGE_UTIL.get_reln_party_id(p_to_entity_id);

     SELECT count(*) into l_rel_party_count
     FROM hz_merge_parties
     WHERE batch_id = l_batch_id
     AND merge_type = 'PARTY_MERGE'
     AND from_party_id = l_from_rel_party_id;

     /* Clean up merge parties */
     DELETE FROM HZ_MERGE_PARTIES
     WHERE batch_id = l_batch_id
     AND merge_type = 'PARTY_MERGE'
     AND (from_party_id = l_from_rel_party_id
          OR to_party_id = l_from_rel_party_id);

     IF ( (p_to_entity_id is not null ) AND
          (p_from_entity_id <> p_to_entity_id) ) THEN
       --check if the relationship types are same
       select pr1.relationship_code from_rel_type,
              pr2.relationship_code to_rel_type
       into   l_from_rel_type,l_to_rel_type
       from hz_relationships pr1, hz_relationships pr2       --bug 4500011 replaced hz_party_relationships with hz_relationships
       where pr1.relationship_id = p_from_entity_id
       and   pr2.relationship_id = p_to_entity_id
       AND   pr1.subject_table_name = 'HZ_PARTIES'
       AND   pr1.object_table_name = 'HZ_PARTIES'
       AND   pr1.directional_flag = 'F'
       AND   pr2.subject_table_name = 'HZ_PARTIES'
       AND   pr2.object_table_name = 'HZ_PARTIES'
       AND   pr2.directional_flag = 'F';

       IF l_from_rel_type <> l_to_rel_type THEN

          --Don't raise the error , If both the relationships are in the contact relationship group

	  IF(NOT isContactGroupRelType(p_from_entity_id,p_to_entity_id)) THEN
            FND_MESSAGE.set_name('AR','HZ_REL_NOT_SIMILAR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

       END IF;

       IF l_from_rel_party_id IS NOT NULL AND
             l_to_rel_party_id IS NOT NULL THEN

             HZ_MERGE_PARTIES_PKG.Insert_Row(
                rel_batch_party_id,
                 l_BATCH_ID,
                'PARTY_MERGE',
                l_from_rel_party_id,
                l_to_rel_party_id,
                'DUPLICATE_RELN_PARTY',
                'PENDING',
                 HZ_UTILITY_V2PUB.CREATED_BY,
                 HZ_UTILITY_V2PUB.CREATION_DATE,
                 HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
                 HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
                 HZ_UTILITY_V2PUB.LAST_UPDATED_BY);

             --Also insert the Party sites for reln Party
             -- if there are any
             insert_party_site_details(l_from_rel_party_id,
                                   l_to_rel_party_id,
                                   rel_batch_party_id,
                                   'Y');
       END IF;  --l_rel_party_count

     ELSIF p_to_entity_id is null THEN

       IF l_rel_party_count > 0 THEN

         select batch_party_id into rel_batch_party_id
         from hz_merge_parties
         where batch_id = l_batch_id
         and merge_type = 'PARTY_MERGE'
         and from_party_id = l_from_rel_party_id;

         HZ_MERGE_PARTIES_PKG.delete_Row(rel_batch_party_id);

         DELETE FROM hz_merge_party_details
         WHERE batch_party_id = rel_batch_party_id;

       END IF; --l_rel_party_count

    END IF; --p_to_entity_id is not null
  END IF; --p_entity

  --get the object_version_number of the record in hz_merge_party_details
  --for locking purpose

  SELECT object_version_number
  INTO   db_object_version_number
  FROM   hz_merge_party_details
  WHERE  merge_from_entity_id = p_from_entity_id
  AND    batch_party_id = p_batch_party_id
  AND    entity_name = p_entity
  FOR UPDATE OF merge_from_entity_id, batch_party_id,entity_name nowait;


  IF(db_object_version_number IS NOT NULL AND p_object_version_number IS NULL) THEN
     p_object_version_number := db_object_version_number;
  END IF;

  --if the 2 object version numbers are same then continue
  --else raise exception

  IF (
      (db_object_version_number IS NULL AND p_object_version_number IS NULL )
       OR ( db_object_version_number IS NOT NULL AND
          p_object_version_number IS NOT NULL AND
          db_object_version_number = p_object_version_number )
     ) THEN

       ---Update the HZ_MERGE_PARTY_DETAILS table
       l_object_version_number := NVL(p_object_version_number, 1) + 1;

       UPDATE HZ_MERGE_PARTY_DETAILS
       SET    merge_to_entity_id = p_to_entity_id,
              object_version_number = l_object_version_number
       WHERE  merge_from_entity_id = p_from_entity_id
       AND    batch_party_id = p_batch_party_id
       AND    entity_name = p_entity;

       p_object_version_number := l_object_version_number;

       SELECT batch_id
       INTO l_dup_set_id
       FROM hz_merge_parties
       WHERE batch_party_id = p_batch_party_id
       AND ROWNUM = 1;

       UPDATE HZ_DUP_SETS
       SET STATUS = 'MAPPING',
           LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
           LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
       WHERE DUP_SET_ID = l_dup_set_id;

       UPDATE HZ_MERGE_BATCH
       SET batch_status = 'IN_PROCESS',
           LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
           LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
       WHERE BATCH_ID = l_dup_set_id;

   ELSE
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
     FND_MESSAGE.SET_TOKEN('TABLE', 'hz_merge_party_details');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;


   -- standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK to map_detail_record ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK to map_detail_record ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK to map_detail_record;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;


     FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

END map_detail_record;

--
-- PROCEDURE map_within_party
--
-- DESCRIPTION
--      Specifies Merging or transfer of merge from to the merge to
--      record for Party Merge within the same party.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_batch_party_id    Batch_Party_id from the merge tables
--     p_entity            Name of the entity HZ_PARTY_SITES,
--                         HZ_RELATIONSHIPS etc.
--     p_from_entity_id    ID of the from record
--     p_to_entity_id      ID of the to record

--   OUT:
--     x_return_status       Return status after the call. The status can
--                           be fnd_api.g_ret_sts_success (success),
--                           fnd_api.g_ret_sts_error (error),
--                           fnd_api.g_ret_sts_unexp_error
--                           (unexpected error).
--     x_msg_count           Number of messages in message stack.
--     x_msg_data            Message text if x_msg_count is 1.
--
-- NOTES
--
-- MODIFICATION HISTORY
--
--   04/01/2002    Jyoti Pandey      o Created.
--   05/10/2005    S V Sowjanya      o Bug 4569674: Modified Tax jurisdiction validation
PROCEDURE map_within_party(
  p_batch_party_id        IN NUMBER,
  p_entity                IN VARCHAR2,
  p_from_entity_id        IN NUMBER,
  p_to_entity_id          IN NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2) IS

l_batch_id              NUMBER;
l_from_party_id         NUMBER;
l_to_party_id           NUMBER;

l_merge_type            HZ_MERGE_PARTIES.MERGE_TYPE%TYPE;
l_status                HZ_MERGE_BATCH.BATCH_STATUS%TYPE;
l_from_site_party_id    NUMBER;
l_to_site_party_id      NUMBER;
l_from_rel_type         HZ_RELATIONSHIPS.RELATIONSHIP_TYPE%TYPE;
l_to_rel_type           HZ_RELATIONSHIPS.RELATIONSHIP_TYPE%TYPE;
l_from_dflag            HZ_RELATIONSHIPS.directional_flag%type;
l_to_dflag            HZ_RELATIONSHIPS.directional_flag%type;

l_map_dtl_count         NUMBER;
rel_batch_party_id      NUMBER;
l_from_rel_party_id     NUMBER;
l_to_rel_party_id       NUMBER;
l_rel_party_count       NUMBER;
l_loc                   NUMBER;
l_org                   NUMBER;
l_total_count		NUMBER;
l_cust_sites 		NUMBER;

  ----------------3738622-------------------------------------
/*CURSOR c_loc_assignments(cp_from_ps_id NUMBER, cp_to_ps_id NUMBER) IS
  SELECT la.loc_id, la.org_id
  FROM HZ_LOC_ASSIGNMENTS la, HZ_PARTY_SITES ps
  WHERE ps.party_site_id = cp_from_ps_id
  AND la.location_id = ps.location_id
  MINUS
  SELECT la.loc_id, la.org_id
  FROM HZ_LOC_ASSIGNMENTS la, HZ_PARTY_SITES ps
  WHERE ps.party_site_id = cp_to_ps_id
  AND la.location_id = ps.location_id;
  */

CURSOR c_address (cp_ps_id number) is
SELECT l.country,
       l.city,
       l.state,
       l.county,
       l.province,
       l.postal_code,
       ps.status,
       ps.location_id   --bug 4569674
FROM   hz_locations l
,      hz_party_sites ps
WHERE  ps.party_site_id   = cp_ps_id
  AND  ps.location_id     = l.location_id;

CURSOR c_cust_site_check IS
		select 1 from hz_cust_acct_sites_all where party_site_id=p_from_entity_id;


l_count            NUMBER;
l_from_country     HZ_LOCATIONS.COUNTRY%TYPE;
l_to_country       HZ_LOCATIONS.COUNTRY%TYPE;
l_from_city        HZ_LOCATIONS.CITY%TYPE;
l_to_city          HZ_LOCATIONS.CITY%TYPE;
l_from_state       HZ_LOCATIONS.STATE%TYPE;
l_to_state         HZ_LOCATIONS.CITY%TYPE;
l_from_county      HZ_LOCATIONS.COUNTY%TYPE;
l_to_county        HZ_LOCATIONS.COUNTY%TYPE;
l_from_province    HZ_LOCATIONS.PROVINCE%TYPE;
l_to_province      HZ_LOCATIONS.PROVINCE%TYPE;
l_from_postal_code HZ_LOCATIONS.postal_code%TYPE;
l_to_postal_code   HZ_LOCATIONS.postal_code%TYPE;
l_from_ps_status   varchar2(1);
l_to_ps_status     varchar2(1);
l_strucutre_id     NUMBER;
l_qualifier        VARCHAR2(30);
l_err_flg          VARCHAR2(1) := 'N';

--bug 4569674
l_merge_yn        VARCHAR2(2);
l_from_location_id NUMBER;
l_to_location_id   NUMBER;
----------------3738622-------------------------------------

CURSOR c_map_detail_record_exist(cp_batch_party_id IN NUMBER,
                                   cp_entity_name IN VARCHAR2,
                                   cp_from_entity_id IN NUMBER) IS
  SELECT count(1)
  FROM hz_merge_party_details
  WHERE batch_party_id = cp_batch_party_id
  AND entity_name = cp_entity_name
  AND merge_from_entity_id = cp_from_entity_id;


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.initialize;
  SAVEPOINT map_within_party;

  --Get the batch_id  and party_id for the same party merge
  SELECT DISTINCT batch_id, from_party_id, to_party_id ,merge_type
  INTO l_batch_id, l_from_party_id, l_to_party_id , l_merge_type
  FROM hz_merge_parties
  WHERE batch_party_id = p_batch_party_id;

  ---Check for valid batch id
  IF    (p_batch_party_id  is null) or (l_batch_id is null )
     OR (p_entity is null) or (p_from_entity_id is null)     THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_BATCH_PARAM');
    FND_MESSAGE.SET_TOKEN('PARAMETER', 'BATCH_PARTY_ID');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end if;

  --check if the from and to_party are the same
  IF l_from_party_id <> l_to_party_id then
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_BATCH_PARAM');
     FND_MESSAGE.SET_TOKEN('PARAMETER', 'BATCH_PARTY_ID');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF l_merge_type <> 'SAME_PARTY_MERGE' THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_BATCH_PARAM');
     FND_MESSAGE.SET_TOKEN('PARAMETER', 'BATCH_PARTY_ID');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  --check if the record already exists
  OPEN c_map_detail_record_exist(p_batch_party_id,p_entity,p_from_entity_id);
  FETCH c_map_detail_record_exist into l_map_dtl_count;
  CLOSE c_map_detail_record_exist;

  IF l_map_dtl_count > 0 AND p_to_entity_id IS NOT NULL THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_REC_PRESENT');
       FND_MESSAGE.SET_TOKEN('ID', p_from_entity_id);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF;



  ---Validation for locations/Party sites
  IF p_entity = 'HZ_PARTY_SITES' THEN

    IF p_to_entity_id IS NOT NULL THEN
     -----------Bug No: 3738622---------------------------------
      /*OPEN c_loc_assignments(p_from_entity_id,p_to_entity_id);
      FETCH c_loc_assignments INTO l_loc, l_org;
      IF c_loc_assignments%FOUND THEN
        CLOSE c_loc_assignments;
        FND_MESSAGE.set_name('AR','HZ_PS_LOC_ASSIGN_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      */
     OPEN c_cust_site_check;
       Fetch c_cust_site_check into l_cust_sites;
     IF c_cust_site_check %NOTFOUND THEN
       null;
     ELSE
       OPEN  c_address (p_from_entity_id);
       FETCH c_address INTO l_from_country,l_from_city,l_from_state,
                            l_from_county,l_from_province,l_from_postal_code, l_from_ps_status,l_from_location_id;
       CLOSE c_address;

       OPEN  c_address (p_to_entity_id);
       FETCH c_address INTO l_to_country,l_to_city,l_to_state,
                            l_to_county,l_to_province,l_to_postal_code, l_to_ps_status,l_to_location_id;
       CLOSE c_address;

       if l_from_ps_status = 'A' and l_to_ps_status = 'I'
       then
	    FND_MESSAGE.set_name('AR','HZ_DL_ADDR_MASTER_ERR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       end if;

--bug 4569674
       l_merge_yn := null;

       ZX_MERGE_LOC_CHECK_PKG.CHECK_GNR(l_from_location_id,
                                        l_to_location_id,
                                        FND_API.G_FALSE,
                                        l_merge_yn,
                    			x_return_status,
                    			x_msg_count,
                    			x_msg_data);
       IF l_merge_yn = 'N' THEN
               FND_MESSAGE.set_name('AR','HZ_PS_LOC_ASSIGN_ERROR');
               FND_MSG_PUB.ADD;
       	       RAISE FND_API.G_EXC_ERROR;
       END IF;


        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
        ELSIF  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
--4569674
       -----------Bug No: 3738622---------------------------------

      --check if the party sites are for the same party
      select ps1.party_id from_site_party_id ,
             ps2.party_id to_site_party_id
      into   l_from_site_party_id, l_to_site_party_id
      from hz_party_sites ps1 , hz_party_sites ps2
      where ps1.party_site_id = p_from_entity_id
      and   ps2.party_site_id = p_to_entity_id;

      --Both from and to party_site_id's should point to same party_id
      --and that party should be the one that is getting merged
      IF (  (l_from_site_party_id <> l_to_site_party_id) AND
            (l_from_site_party_id <> l_from_party_id)  ) THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_BATCH_PARAM');
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'BATCH_PARTY_ID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;
     CLOSE c_cust_site_check;
      HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
            p_batch_party_id,
    	  'HZ_PARTY_SITES',
  	  p_from_entity_id,
  	  p_to_entity_id,
            'N',
  	  hz_utility_v2pub.created_by,
  	  hz_utility_v2pub.creation_Date,
  	  hz_utility_v2pub.last_update_login,
  	  hz_utility_v2pub.last_update_date,
  	  hz_utility_v2pub.last_updated_by);

    ELSE
      IF l_map_dtl_count >0 THEN
        HZ_MERGE_PARTY_DETAILS_PKG.delete_row(
           p_batch_party_id, 'HZ_PARTY_SITES', p_from_entity_id);
      END IF;
    END IF;

  ELSIF p_entity = 'HZ_PARTY_RELATIONSHIPS' THEN

    IF p_to_entity_id IS NOT NULL THEN
      select r1.relationship_type from_rel_type ,
             r1.directional_flag from_dflag,
             r2.relationship_type to_rel_type,
             r2.directional_flag to_dflag
      into l_from_rel_type, l_from_dflag,
           l_to_rel_type  , l_to_dflag
      from hz_relationships r1, hz_relationships r2
      where r1.relationship_id = p_from_entity_id
      and   r1.object_id = l_from_party_id
      and   r2.relationship_id = p_to_entity_id
      and   r2.object_id = l_to_party_id;


     IF l_from_rel_type <> l_to_rel_type OR l_from_dflag <> l_to_dflag THEN
       IF(NOT isContactGroupRelType(p_from_entity_id,p_to_entity_id)) THEN
         FND_MESSAGE.set_name('AR','HZ_REL_NOT_SIMILAR');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

     HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
          p_batch_party_id,
          'HZ_PARTY_RELATIONSHIPS',
          p_from_entity_id,
          p_to_entity_id,
          'N',
          hz_utility_v2pub.created_by,
          hz_utility_v2pub.creation_Date,
          hz_utility_v2pub.last_update_login,
          hz_utility_v2pub.last_update_date,
          hz_utility_v2pub.last_updated_by);


     l_from_rel_party_id :=
                          HZ_MERGE_UTIL.get_reln_party_id(p_from_entity_id);
     l_to_rel_party_id   :=
                          HZ_MERGE_UTIL.get_reln_party_id(p_to_entity_id);

     SELECT count(1) INTO l_rel_party_count
     FROM hz_merge_parties
     WHERE batch_id = l_batch_id
     AND merge_type = 'PARTY_MERGE'
     AND from_party_id = l_from_rel_party_id;


     IF ( (l_from_rel_party_id is not null ) AND
          (l_to_rel_party_id is not null) AND
          (l_from_rel_party_id <> l_to_rel_party_id) ) THEN

       --Insert parties if the rel party is not present already
       IF l_rel_party_count = 0 THEN

             HZ_MERGE_PARTIES_PKG.Insert_Row(
                rel_batch_party_id,
                 l_batch_id,
                'PARTY_MERGE',
                l_from_rel_party_id,
                l_to_rel_party_id,
                'DUPLICATE_RELN_PARTY',
                'PENDING',
                 HZ_UTILITY_V2PUB.CREATED_BY,
                 HZ_UTILITY_V2PUB.CREATION_DATE,
                 HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
                 HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
                 HZ_UTILITY_V2PUB.LAST_UPDATED_BY);

            --Also insert the Party sites for reln Party
            -- if there are any
            insert_party_site_details(l_from_rel_party_id,
                                      l_to_rel_party_id,
                                      rel_batch_party_id,'Y');

       END IF;  --l_rel_party_count
     end if; --l_from_rel_party_id is not null
   ELSE
    IF l_map_dtl_count>0 THEN
      HZ_MERGE_PARTY_DETAILS_PKG.delete_row(
          p_batch_party_id, 'HZ_PARTY_RELATIONSHIPS', p_from_entity_id);

      l_from_rel_party_id :=
                          HZ_MERGE_UTIL.get_reln_party_id(p_from_entity_id);
      l_to_rel_party_id   :=
                          HZ_MERGE_UTIL.get_reln_party_id(p_to_entity_id);

      SELECT count(1) INTO l_rel_party_count
      FROM hz_merge_parties
      WHERE batch_id = l_batch_id
      AND merge_type = 'PARTY_MERGE'
      AND from_party_id = l_from_rel_party_id;


      IF l_rel_party_count > 0 THEN

        SELECT batch_party_id into rel_batch_party_id
        FROM hz_merge_parties
        WHERE batch_id = l_batch_id
        AND merge_type = 'PARTY_MERGE'
        AND from_party_id = l_from_rel_party_id;

        HZ_MERGE_PARTIES_PKG.delete_Row(rel_batch_party_id);

        DELETE FROM hz_merge_party_details
        WHERE batch_party_id = rel_batch_party_id;

      end if; --l_rel_party_count
    end if;  -- l_map_dtl_count
   end if; -- p_to_entity_id


  end if; --p_entity

  UPDATE HZ_DUP_SETS
  SET STATUS = 'MAPPING',
      LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
      LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
  WHERE DUP_SET_ID = (SELECT batch_id FROM hz_merge_parties
                      WHERE batch_party_id = p_batch_party_id
                      AND ROWNUM = 1);

  UPDATE HZ_MERGE_BATCH
  SET batch_status = 'IN_PROCESS',
      LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
      LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
  WHERE BATCH_ID = (SELECT batch_id FROM hz_merge_parties
                         WHERE batch_party_id = p_batch_party_id
                         AND ROWNUM = 1);

 -- standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK to map_within_party;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK to map_within_party;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK to map_within_party;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;


     FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

END map_within_party;


-- PROCEDURE submit_batch
--
-- DESCRIPTION
--      Submits a concurrent request for the batch if the mapping
--       is complete
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_batch_id          ID of the batch

--   OUT:
--     x_request_id          Request ID of the concurrent program
--     x_return_status       Return status after the call. The status can
--                           be fnd_api.g_ret_sts_success (success),
--                           fnd_api.g_ret_sts_error (error),
--                           fnd_api.g_ret_sts_unexp_error
--                           (unexpected error).
--     x_msg_count           Number of messages in message stack.
--     x_msg_data            Message text if x_msg_count is 1.
--
-- NOTES
--
-- MODIFICATION HISTORY
--
--   04/01/2002    Jyoti Pandey      o Created.
--
--

PROCEDURE submit_batch(
  p_batch_id        IN NUMBER,
  p_preview         IN VARCHAR2,
  x_request_id      OUT NOCOPY NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2 ) IS

l_request_id              NUMBER := NULL;
l_preview               VARCHAR2(1);

l_last_request_id       NUMBER;
l_conc_phase            VARCHAR2(80);
l_conc_status           VARCHAR2(80);
l_conc_dev_phase        VARCHAR2(30);
l_conc_dev_status       VARCHAR2(30);
l_message               VARCHAR2(240);
call_status             boolean;
l_batch_status          HZ_MERGE_BATCH.BATCH_STATUS%TYPE;
l_dup_set_status        VARCHAR2(30);
retcode number;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.initialize;

  SAVEPOINT submit_batch;

  IF p_preview is null THEN
     l_preview := 'Y';
  ELSE
     l_preview := p_preview;
  END IF;

  SELECT batch_status , request_id
  INTO  l_batch_status ,l_last_request_id
  FROM hz_merge_batch
  WHERE batch_id = p_batch_id;

  -- a data librarian dup set must have merge batch
  SELECT ds.status
  INTO  l_dup_set_status
  FROM hz_dup_sets ds, hz_merge_batch mb
  WHERE ds.dup_set_id = mb.batch_id
  AND ds.dup_set_id = p_batch_id;

  IF l_last_request_id IS NOT NULL THEN
     call_status := FND_CONCURRENT.GET_REQUEST_STATUS(
	       		request_id  => l_last_request_id,
       			phase       => l_conc_phase,
       			status      => l_conc_status,
       			dev_phase   => l_conc_dev_phase,
       			dev_status  => l_conc_dev_status,
       			message     => l_message ) ;

     IF l_conc_dev_phase <> 'COMPLETE' THEN
       FND_MESSAGE.set_name('AR', 'HZ_CANNOT_SUBMIT_PROCESSING');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     ELSE
       IF l_conc_dev_status <>'NORMAL' THEN
         l_request_id := fnd_request.submit_request('AR',
                    'ARHPMERGE',
                    'Party Merge Concurrent Request',
                    to_char(sysdate,'DD-MON-YY HH24:MI:SS'),
                    FALSE,
                    p_batch_id, l_preview );

         IF l_request_id = 0 THEN
           FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
          -- FND_MESSAGE.RETRIEVE(l_message);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
           retcode := 2;
           RETURN;
         END IF;

       ELSE  --if completed normally and the status of the dup sets is still ERROR
             -- Added MAPPING for bug 3327496
         IF l_dup_set_status in ('ERROR','MAPPING') THEN
           l_request_id := fnd_request.submit_request('AR',
                      'ARHPMERGE',
                      'Party Merge Concurrent Request',
                      to_char(sysdate,'DD-MON-YY HH24:MI:SS'),
                      FALSE,
                      p_batch_id, l_preview );
           IF l_request_id = 0 THEN
             FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
             retcode := 2;
             RETURN;
           END IF;
         ELSE
           FND_MESSAGE.set_name('AR', 'HZ_CANNOT_SUBMIT_REQUEST');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF; --l_conc_status
     END IF;     --l_conc_dev_phase

  ELSE      ---last_request_id is null
     l_request_id := fnd_request.submit_request('AR'
                  ,'ARHPMERGE'
                  ,'Party Merge Concurrent Request'
                  ,to_char(sysdate,'DD-MON-YY HH24:MI:SS')
                  ,FALSE,
                  to_char(p_batch_id), l_preview );

     IF l_request_id = 0 THEN
          FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
         -- FND_MESSAGE.RETRIEVE(l_message);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
         -- retcode := 2;
         -- RETURN;
     END IF;

   END IF; ---last_request_id

   -- if batch is resubmitted, update the status
   -- fix bug 3081305
     IF l_request_id is not null THen
         UPDATE HZ_MERGE_BATCH
         SET batch_status = 'SUBMITTED' ,
             request_id = l_request_id,
             LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
             LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
         WHERE  batch_id = p_batch_id;

         UPDATE HZ_DUP_SETS
         SET status = 'SUBMITTED',
             LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
             LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
         WHERE  dup_set_id = p_batch_id;
     END IF;

   x_request_id := l_request_id;

   -- standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK to submit_batch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK to submit_batch;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK to submit_batch;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
END submit_batch;


--Body of the Private procedures
PROCEDURE insert_party_details( cp_batch_party_id IN NUMBER,
                                cp_from_party_id IN NUMBER,
                                cp_to_party_id   IN NUMBER,
                                p_def_to_entity  IN VARCHAR2 DEFAULT 'N') IS
BEGIN

  -----Insert Party Site details
  insert_party_site_details(
         cp_from_party_id,
         cp_to_party_id,
         cp_batch_party_id,
         p_def_to_entity);

  -----Insert Party Relations details
  insert_party_reln_details(
         cp_from_party_id,
         cp_to_party_id,
         cp_batch_party_id,
         p_def_to_entity);

END insert_party_details;


PROCEDURE insert_reln_parties(p_batch_party_id IN NUMBER,
                              p_batch_id       IN NUMBER)IS

CURSOR merged_relns(cp_batch_party_id NUMBER) IS
    SELECT merge_from_entity_id, merge_to_entity_id,
    HZ_MERGE_UTIL.get_reln_party_id(merge_from_entity_id) from_reln_party_id,
    HZ_MERGE_UTIL.get_reln_party_id(merge_to_entity_id) to_reln_party_id
    FROM hz_merge_party_details
    WHERE batch_party_id = cp_batch_party_id
    AND entity_name = 'HZ_PARTY_RELATIONSHIPS'
    AND merge_to_entity_id IS NOT NULL
    AND merge_from_entity_id IS NOT NULL
    AND merge_from_entity_id <> merge_to_entity_id;

l_from_rel_id NUMBER := NULL;
l_to_rel_id NUMBER := NULL;
l_from_reln_party_id NUMBER := NULL;
l_to_reln_party_id NUMBER := NULL;

l_batch_party_id NUMBER := NULL;
l_rel_status varchar2(1);
l_id number;
l_from_rel_status VARCHAR2(1);--Bug6703948
BEGIN

  l_batch_party_id := p_batch_party_id;

  OPEN merged_relns(l_batch_party_id);
  LOOP
   FETCH merged_relns INTO l_from_rel_id, l_to_rel_id,
                       l_from_reln_party_id, l_to_reln_party_id;
    EXIT WHEN merged_relns%NOTFOUND;

    IF l_to_reln_party_id IS NOT NULL AND
         l_from_reln_party_id IS NOT NULL THEN

      l_batch_party_id := null;

	  -- 5194384
       	select status into l_rel_status
       	from  hz_parties
       	where party_id = l_to_reln_party_id;

	--Bug6703948
	select status into l_from_rel_status
       	from  hz_parties
       	where party_id = l_from_reln_party_id;

	IF l_from_rel_status <> 'I' THEN --Bug6703948

       	if l_rel_status = 'I' -- switch from id and to id
	then
		l_id := l_from_reln_party_id;
                l_from_reln_party_id := l_to_reln_party_id;
		l_to_reln_party_id := l_id;
	end if;
	END IF; --Bug6703948
         HZ_MERGE_PARTIES_PKG.Insert_Row(
                l_batch_party_id,
                 p_BATCH_ID,
                'PARTY_MERGE',
                l_from_reln_party_id,
                l_to_reln_party_id,
                'DUPLICATE_RELN_PARTY',
                'PENDING',
                 HZ_UTILITY_V2PUB.CREATED_BY,
                 HZ_UTILITY_V2PUB.CREATION_DATE,
                 HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
                 HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
                 HZ_UTILITY_V2PUB.LAST_UPDATED_BY);

         --Also insert the Party sites for reln Party
         -- if there are any
         insert_party_site_details(l_from_reln_party_id,
                                   l_to_reln_party_id,
                                   l_batch_party_id,
                                   'Y');

    END IF;
  END LOOP;
  CLOSE merged_relns;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    APP_EXCEPTION.RAISE_EXCEPTION;
END insert_reln_parties;


PROCEDURE insert_party_site_details (
	p_from_party_id	     IN	NUMBER,
	p_to_party_id	     IN	NUMBER,
	p_batch_party_id     IN	NUMBER,
        p_reln_parties       IN VARCHAR2 DEFAULT 'N'
) IS

  --Cursor for inserting Party sites that are non-DNB
  CURSOR c_from_ps_loc(merge_type VARCHAR2) IS
    SELECT party_site_id, ps.location_id
    FROM HZ_PARTY_SITES ps
    WHERE ps.party_id = p_from_party_id
    AND (merge_type = 'S' OR ps.actual_content_source <>'DNB')--Bug No.4114254
    AND nvl(status, 'A') in ('A','I');




  CURSOR c_dup_to_ps(cp_loc_id NUMBER,merge_type VARCHAR2) IS
    SELECT party_site_id
    FROM HZ_PARTY_SITES ps
    WHERE ps.party_id = p_to_party_id
    AND ps.location_id = cp_loc_id
    AND (merge_type = 'S' OR ps.actual_content_source <>'DNB')--Bug No. 4114254
    AND nvl(status, 'A') in ('A','I');




l_ps_id NUMBER;
l_loc_id NUMBER;
l_dup_ps_id NUMBER;
l_sqerr VARCHAR2(2000);
l_mandatory_merge VARCHAR2(1);
l_to_entity_id NUMBER;
l_merge_type VARCHAR2(2000);
l_case VARCHAR2(1);

BEGIN
  SELECT dset.merge_type INTO l_merge_type
   FROM HZ_DUP_SETS dset,HZ_MERGE_PARTIES mpar
   WHERE dset.dup_set_id = mpar.batch_id
   AND mpar.batch_party_id = p_batch_party_id;

IF l_merge_type = 'SAME_PARTY_MERGE' THEN
   l_case := 'S';
ELSE
   l_case := 'M';
END IF;

  OPEN c_from_ps_loc(l_case);
  LOOP
    FETCH c_from_ps_loc INTO l_ps_id, l_loc_id;
    EXIT WHEN c_from_ps_loc%NOTFOUND;
    IF p_from_party_id <> p_to_party_id THEN
      l_mandatory_merge := 'Y';
    ELSE
      l_mandatory_merge := 'N';
    END IF;

      OPEN c_dup_to_ps(l_loc_id,l_case);
      FETCH c_dup_to_ps INTO l_dup_ps_id;

      IF c_dup_to_ps%FOUND THEN
        IF (p_reln_parties = 'N') AND (l_mandatory_merge = 'N') THEN
          l_to_entity_id := l_ps_id;
        ELSE
          l_to_entity_id := l_dup_ps_id;
        END IF;

        HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
          p_batch_party_id,
  	  'HZ_PARTY_SITES',
	  l_ps_id,
	  l_to_entity_id,
          l_mandatory_merge,
	  hz_utility_v2pub.created_by,
	  hz_utility_v2pub.creation_Date,
	  hz_utility_v2pub.last_update_login,
	  hz_utility_v2pub.last_update_date,
	  hz_utility_v2pub.last_updated_by);
      ELSE
          l_to_entity_id := l_ps_id;

        HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
            p_batch_party_id,
            'HZ_PARTY_SITES',
            l_ps_id,
            l_to_entity_id,
            'N',
            hz_utility_v2pub.created_by,
            hz_utility_v2pub.creation_Date,
            hz_utility_v2pub.last_update_login,
            hz_utility_v2pub.last_update_date,
            hz_utility_v2pub.last_updated_by);
      END IF;
      CLOSE c_dup_to_ps;
  END LOOP;
  CLOSE c_from_ps_loc;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  APP_EXCEPTION.RAISE_EXCEPTION;
END insert_party_site_details;


PROCEDURE insert_party_reln_details (
	p_from_party_id	    IN	NUMBER,
	p_to_party_id	    IN	NUMBER,
	p_batch_party_id    IN	NUMBER,
        p_def_mapping       IN VARCHAR2 DEFAULT 'N'
) IS

  CURSOR c_from_reln(l_batch_id NUMBER,merge_type VARCHAR2) IS
    SELECT relationship_id, subject_id, object_id,
           relationship_code, actual_content_source, start_date, nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))
    FROM HZ_RELATIONSHIPS r
    WHERE (subject_id = p_from_party_id
           OR object_id = p_from_party_id)
    AND nvl(status, 'A') IN ('A','I')
    AND directional_flag = 'F'
    AND subject_table_name = 'HZ_PARTIES'
    AND object_table_name = 'HZ_PARTIES'
    AND (merge_type ='S' OR actual_content_source <> 'DNB')--Bug No. 4114254
    AND not exists
    ( select 1
      from HZ_MERGE_PARTIES a, HZ_MERGE_PARTY_DETAILS b
      where a.batch_party_id = b.batch_party_id
      and b.merge_from_entity_id = r.relationship_id
      and b.entity_name = 'HZ_PARTY_RELATIONSHIPS'
      and a.batch_id = l_batch_id );


    CURSOR c_dup_sub_reln(
      c_batch_id NUMBER,cp_party_rel_code VARCHAR2, cp_obj_id NUMBER,
      cp_subj_id NUMBER, from_start_date date, from_end_date date,merge_type VARCHAR2)
    IS
    SELECT relationship_id, start_date, nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))
    FROM HZ_RELATIONSHIPS r
    WHERE subject_id = cp_subj_id
    AND object_id = cp_obj_id
    AND relationship_code = cp_party_rel_code
    --OR exists (select 1 from hz_relationship_types where relationship_type = cp_party_relationship_type
                 --and forward_code=backward_code))
    AND ((start_date between from_start_date and from_end_date)
          or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
          or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date))
    AND nvl(status, 'A') IN ('A','I') --BugNo:2940087
    --AND directional_flag = 'F'      --BugNo:2940087
    AND subject_table_name = 'HZ_PARTIES'
    AND object_table_name = 'HZ_PARTIES'
    AND (merge_type ='S' OR actual_content_source <> 'DNB') --Bug No. 4114254
    AND not exists   --4651128
    ( select 1
      from HZ_MERGE_PARTIES a, HZ_MERGE_PARTY_DETAILS b
      where a.batch_party_id = b.batch_party_id
      and b.merge_from_entity_id = r.relationship_id
      and b.entity_name = 'HZ_PARTY_RELATIONSHIPS'
      and a.batch_id = c_batch_id );

--4651128
   CURSOR c_get_from_parties(c_batch_id NUMBER) IS
   SELECT dup_party_id
   FROM hz_dup_set_parties
   WHERE dup_set_id = c_batch_id
   AND  dup_party_id <> p_from_party_id
   AND  dup_party_id <> p_to_party_id;


   CURSOR check_dup_sub_reln(
      c_batch_id NUMBER, cp_party_rel_code VARCHAR2, cp_subj_id NUMBER,
      from_start_date date, from_end_date date)
    IS
    SELECT relationship_id, start_date, nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))
    FROM HZ_RELATIONSHIPS r
    WHERE
        relationship_id in (select distinct b.merge_to_entity_id
			    from HZ_MERGE_PARTIES a, HZ_MERGE_PARTY_DETAILS b
			    where a.batch_party_id = b.batch_party_id
			    and b.entity_name = 'HZ_PARTY_RELATIONSHIPS'
			    and a.batch_id = c_batch_id)
    AND subject_id = cp_subj_id
    AND relationship_code = cp_party_rel_code
    AND ((start_date between from_start_date and from_end_date)
          or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
          or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date))
    AND nvl(status, 'A') IN ('A','I')
    AND directional_flag = 'F'
    AND subject_table_name = 'HZ_PARTIES'
    AND object_table_name = 'HZ_PARTIES';

    CURSOR check_dup_obj_reln(
      c_batch_id NUMBER, cp_party_rel_code VARCHAR2, cp_obj_id NUMBER,
      from_start_date date, from_end_date date)
    IS
    SELECT relationship_id, start_date, nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))
    FROM HZ_RELATIONSHIPS r
    WHERE
        relationship_id in (select distinct b.merge_to_entity_id
			    from HZ_MERGE_PARTIES a, HZ_MERGE_PARTY_DETAILS b
			    where a.batch_party_id = b.batch_party_id
			    and b.entity_name = 'HZ_PARTY_RELATIONSHIPS'
			    and a.batch_id = c_batch_id)
    AND object_id = cp_obj_id
    AND relationship_code = cp_party_rel_code
    AND ((start_date between from_start_date and from_end_date)
          or (nvl(end_date,to_date('12/31/4712','MM/DD/YYYY')) between from_start_date and from_end_date)
          or(start_date<from_start_date and nvl(end_date,to_date('12/31/4712','MM/DD/YYYY'))>from_end_date))
    AND nvl(status, 'A') IN ('A','I')
    AND directional_flag = 'F'
    AND subject_table_name = 'HZ_PARTIES'
    AND object_table_name = 'HZ_PARTIES';
--4651128




--bug 4867151 start
    CURSOR c_self_reln(rel_id NUMBER, batch_id NUMBER, to_id NUMBER) IS
        select 'Y' from hz_relationships where relationship_id=rel_id
    and (subject_id IN (SELECT dup_party_id FROM HZ_dup_set_PARTIES WHERE dup_set_id=batch_id))
    and (object_id IN (SELECT dup_party_id FROM HZ_dup_set_PARTIES WHERE dup_set_id=batch_id))
    AND directional_flag='F';
--bug 4867151 end

  /* Commented out for BugNo:2940087 */
  /*CURSOR c_dup_ob_reln(cp_party_relationship_type VARCHAR2, cp_subj_id NUMBER)
   IS
    SELECT relationship_id
    FROM HZ_RELATIONSHIPS
    WHERE object_id = p_to_party_id
    AND subject_id = cp_subj_id
    AND relationship_code = cp_party_relationship_type
    AND nvl(status, 'A') = 'A'
    AND directional_flag = 'F'
    AND subject_table_name = 'HZ_PARTIES'
    AND object_table_name = 'HZ_PARTIES'
    AND actual_content_source <> 'DNB';
 */
l_pr_id NUMBER;
l_dup_pr_id NUMBER;
l_dup_start_date HZ_RELATIONSHIPS.start_date%TYPE;
l_dup_end_date HZ_RELATIONSHIPS.end_date%TYPE;

l_subj_id NUMBER;
l_obj_id NUMBER;
l_reltype HZ_RELATIONSHIPS.relationship_code%TYPE;
l_relcode HZ_RELATIONSHIPS.relationship_code%TYPE;
l_contype HZ_RELATIONSHIPS.actual_content_source%TYPE;
l_start_date HZ_RELATIONSHIPS.start_date%TYPE;
l_end_date HZ_RELATIONSHIPS.end_date%TYPE;

l_batch_id NUMBER;
l_batch_party_id NUMBER;
l_mandatory_merge VARCHAR2(1);
l_case VARCHAR2(1);
l_merge_type VARCHAR2(2000);
l_party_id HZ_MERGE_PARTIES.from_party_id%TYPE;
l_temp_flag varchar2(1);--bug 4867151
---Bug No.5400786
l_temp VARCHAR2(1);
----Bug No. 5400786

-- bug 5194384
l_rel_status varchar2(1);
l_id number;
l_to_id number;
l_to_rel_status VARCHAR2(1); --6703948
cursor c_get_rel_status(cp_id number) is
         select status
	     from  hz_relationships
	     where relationship_id = cp_id
         and rownum = 1;

cursor c_check_inactive_to_id(cp_id number) is
         select merge_to_entity_id
         from hz_merge_party_details
         where merge_from_entity_id = merge_to_entity_id
         and merge_from_entity_id = cp_id;


BEGIN
l_temp := 'N';
  SELECT dset.merge_type, mpar.batch_id INTO l_merge_type, l_batch_id
   FROM HZ_DUP_SETS dset,HZ_MERGE_PARTIES mpar
   WHERE dset.dup_set_id = mpar.batch_id
   AND mpar.batch_party_id = p_batch_party_id;

IF l_merge_type = 'SAME_PARTY_MERGE' THEN
   l_case := 'S';
ELSE
   l_case := 'M';
END IF;
    --get relationship in which from_party_id is either subject or object
    OPEN c_from_reln(l_batch_id,l_case);
    LOOP
      l_dup_pr_id := -1;
      l_temp := 'N'; --6082014
      FETCH c_from_reln INTO l_pr_id, l_subj_id, l_obj_id, l_relcode,
            l_contype, l_start_date, l_end_date;
      EXIT WHEN c_from_reln%NOTFOUND;

     -- IF l_contype <> 'DNB' THEN--Bug No.4114254

        --if the from party is the subject in reln.
        IF l_subj_id=p_from_party_id THEN

	  OPEN c_dup_sub_reln(l_batch_id,l_relcode, l_obj_id, p_to_party_id,l_start_date,l_end_date,l_case);
           FETCH c_dup_sub_reln INTO l_dup_pr_id,l_dup_start_date,l_dup_end_date;
           IF c_dup_sub_reln%NOTFOUND THEN
            l_dup_pr_id := -1;
          END IF;
          CLOSE c_dup_sub_reln;
-- start 4651128
	  IF l_dup_pr_id = -1 THEN
		OPEN check_dup_obj_reln(l_batch_id, l_relcode,l_obj_id,l_start_date,l_end_date);
	        FETCH check_dup_obj_reln INTO l_dup_pr_id,l_dup_start_date,l_dup_end_date;
		IF check_dup_obj_reln%NOTFOUND THEN
			l_dup_pr_id := -1;
		END IF;
		CLOSE check_dup_obj_reln;
          END IF;

          IF l_dup_pr_id = -1 THEN
	          OPEN c_get_from_parties(l_batch_id); --4651128
        	  LOOP
          	  	FETCH c_get_from_parties INTO l_party_id;
          		EXIT WHEN c_get_from_parties%NOTFOUND;
             		OPEN c_dup_sub_reln(l_batch_id,l_relcode, l_obj_id, l_party_id,l_start_date,l_end_date,l_case);
             		FETCH c_dup_sub_reln INTO l_dup_pr_id,l_dup_start_date,l_dup_end_date;
             		IF c_dup_sub_reln%FOUND THEN
             		 CLOSE c_dup_sub_reln;
                         EXIT;
             		ELSE
            			l_dup_pr_id := -1;
             		END IF;
             		CLOSE c_dup_sub_reln;
          	END LOOP;
          	CLOSE c_get_from_parties;
          END IF;
--end 4651128
        ELSIF l_obj_id=p_from_party_id THEN

          OPEN c_dup_sub_reln(l_batch_id,l_relcode,p_to_party_id,l_subj_id,l_start_date,l_end_date,l_case);
           FETCH c_dup_sub_reln INTO l_dup_pr_id,l_dup_start_date,l_dup_end_date;
           IF c_dup_sub_reln%NOTFOUND THEN
            l_dup_pr_id := -1;
          END IF;
          CLOSE c_dup_sub_reln;

-- start 4651128

	  IF l_dup_pr_id = -1 THEN
                OPEN check_dup_sub_reln(l_batch_id,l_relcode,l_subj_id,l_start_date,l_end_date);
                FETCH check_dup_sub_reln INTO l_dup_pr_id,l_dup_start_date,l_dup_end_date;
                IF check_dup_sub_reln%NOTFOUND THEN
                        l_dup_pr_id := -1;
                END IF;
                CLOSE check_dup_sub_reln;
          END IF;


	  IF l_dup_pr_id = -1 THEN
		  OPEN c_get_from_parties(l_batch_id); --4651128
        	  LOOP
          		FETCH c_get_from_parties INTO l_party_id;
          		EXIT WHEN c_get_from_parties%NOTFOUND;
             		OPEN c_dup_sub_reln(l_batch_id,l_relcode, l_party_id, l_subj_id,l_start_date,l_end_date,l_case);
             		FETCH c_dup_sub_reln INTO l_dup_pr_id,l_dup_start_date,l_dup_end_date;
             		IF c_dup_sub_reln%FOUND THEN
                            CLOSE c_dup_sub_reln;
				EXIT;
	     		ELSE
           			--Transfer
            			l_dup_pr_id := -1;
             		END IF;
             		CLOSE c_dup_sub_reln;
          	END LOOP;
          	CLOSE c_get_from_parties;
	END IF;
--end 4651128
        END IF;
    -- END IF;
     --bug 4867151 start

      l_temp_flag := 'N';

      OPEN c_self_reln(l_pr_id, l_batch_id, p_to_party_id);
      FETCH c_self_reln INTO l_temp_flag;
      CLOSE c_self_reln;
     --bug 4867151 end

-- bug 5194384
      open c_get_rel_status(l_dup_pr_id);
      fetch c_get_rel_status into l_rel_status;
      close c_get_rel_status;

--bug6703948
      open c_get_rel_status(l_pr_id);
      fetch c_get_rel_status into l_to_rel_status;
      close c_get_rel_status;

	IF l_to_rel_status <> 'I' THEN --bug6703948
      if l_rel_status = 'I' -- switch from id and to id
      then
		l_id := l_pr_id;
              	l_pr_id := l_dup_pr_id;
		      l_dup_pr_id := l_id;
      end if;
	END IF;--bug6703948

    IF l_temp_flag<>'Y' THEN --bug 4867151

      IF l_dup_pr_id <> -1 THEN

        IF p_from_party_id <> p_to_party_id AND l_pr_id <> l_dup_pr_id THEN
          l_mandatory_merge := 'Y';
        ELSE
          l_mandatory_merge := 'N';
        END IF;

        HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
           p_batch_party_id,
     	   'HZ_PARTY_RELATIONSHIPS',
   	   l_pr_id,
	   l_dup_pr_id,
           l_mandatory_merge,
           hz_utility_v2pub.created_by,
           hz_utility_v2pub.creation_Date,
           hz_utility_v2pub.last_update_login,
           hz_utility_v2pub.last_update_date,
           hz_utility_v2pub.last_updated_by);

      ELSE

       	--5400786
          l_temp := 'Y';
       ---5400786
          HZ_MERGE_PARTY_DETAILS_PKG.Insert_Row(
             p_batch_party_id,
             'HZ_PARTY_RELATIONSHIPS',
             l_pr_id,
             l_pr_id,
             'N',
             hz_utility_v2pub.created_by,
             hz_utility_v2pub.creation_Date,
             hz_utility_v2pub.last_update_login,
             hz_utility_v2pub.last_update_date,
             hz_utility_v2pub.last_updated_by);

      END IF;
    END IF;--l_temp_flag-- bug 4867151
    -- bug 5194384
      open c_check_inactive_to_id(l_pr_id);
      fetch c_check_inactive_to_id into l_to_id;
      close c_check_inactive_to_id;
      --5400786
      if l_to_id = l_pr_id AND l_temp <> 'Y' -- inactive id
      --5400786
      then
      update HZ_MERGE_PARTY_DETAILS
          set
             merge_from_entity_id = l_dup_pr_id,
             merge_to_entity_id = l_dup_pr_id
           where merge_to_entity_id = l_pr_id
           and merge_from_entity_id = merge_to_entity_id; --bug 608201
      end if;
    END LOOP;
    CLOSE c_from_reln;
EXCEPTION
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     APP_EXCEPTION.RAISE_EXCEPTION;
END insert_party_reln_details;

/*=======================================================================+
 | DESCRIPTION                                                           |
 |   Suggested default will be run when creating new batch               |
 |   For same party merge, only mapped records exist in merge party      |
 |   For multiple parties merge, all records exist.  To identify which   |
 |   record is merged, merge_from_entity_id <> merge_to_entity_id        |
 *=======================================================================*/

-- create records in dup batch, dup set and dup set parties
PROCEDURE suggested_defaults (
   p_batch_id                  IN      NUMBER
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

  l_merge_type           VARCHAR2(30);
  l_addr_match_rule      NUMBER := 0;
  l_reln_match_rule      NUMBER := 0;
  l_default_addr_rule    NUMBER := 0;
  l_default_relat_rule   NUMBER := 0;

  cursor get_dup_sets_info(l_dup_set_id NUMBER) is
  select merge_type
  from HZ_DUP_SETS
  where dup_set_id = l_dup_set_id;

BEGIN

  savepoint suggested_defaults;

  fnd_msg_pub.initialize;
--Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(p_batch_id IS NULL OR
    p_batch_id = FND_API.G_MISS_NUM) THEN
    FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
    FND_MESSAGE.SET_TOKEN('COLUMN' ,'DUP_SET_ID');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  open get_dup_sets_info(p_batch_id);
  fetch get_dup_sets_info into l_merge_type;
  close get_dup_sets_info;

-- clean up temporary table for suggested defaults
  DELETE FROM HZ_MERGE_PARTYDTLS_SUGG
  WHERE batch_party_id in
  ( SELECT batch_party_id
    FROM HZ_MERGE_PARTIES_SUGG
    WHERE batch_id = p_batch_id );

  DELETE FROM HZ_MERGE_PARTIES_SUGG
  WHERE batch_id = p_batch_id;

  INSERT INTO HZ_MERGE_PARTIES_SUGG
  (
     batch_party_id
    ,batch_id
    ,merge_type
    ,from_party_id
    ,to_party_id
    ,merge_reason_code
    ,merge_status
    ,created_by
    ,creation_date
    ,last_update_login
    ,last_update_date
    ,last_updated_by
  )
  SELECT
     batch_party_id
    ,batch_id
    ,merge_type
    ,from_party_id
    ,to_party_id
    ,merge_reason_code
    ,merge_status
    ,created_by
    ,creation_date
    ,last_update_login
    ,last_update_date
    ,last_updated_by
  FROM HZ_MERGE_PARTIES
  WHERE batch_id = p_batch_id;

  INSERT INTO HZ_MERGE_PARTYDTLS_SUGG
  (
     batch_party_id
    ,entity_name
    ,merge_from_entity_id
    ,merge_to_entity_id
    ,mandatory_merge
    ,created_by
    ,creation_date
    ,last_update_login
    ,last_update_date
    ,last_updated_by
    ,object_version_number
  )
  SELECT
     batch_party_id
    ,entity_name
    ,merge_from_entity_id
    ,merge_to_entity_id
    ,mandatory_merge
    ,created_by
    ,creation_date
    ,last_update_login
    ,last_update_date
    ,last_updated_by
    ,object_version_number
  FROM HZ_MERGE_PARTY_DETAILS
  WHERE batch_party_id IN
  ( SELECT batch_party_id
    FROM HZ_MERGE_PARTIES_SUGG
    WHERE batch_id = p_batch_id );

  -- get match_rule_id from profile

  select min(match_rule_id) into l_default_addr_rule
  from HZ_MATCH_RULES_VL
  where rule_name = 'DL ADDRESS DEFAULT';

  select min(match_rule_id) into l_default_relat_rule
  from HZ_MATCH_RULES_VL
  where rule_name = 'DL RELATIONSHIP DEFAULT';

  l_addr_match_rule := nvl(fnd_profile.value('HZ_SUGG_ADDR_MATCH_RULE'),l_default_addr_rule);
  l_reln_match_rule := nvl(fnd_profile.value('HZ_SUGG_RELN_MATCH_RULE'),l_default_relat_rule);

  if((l_addr_match_rule = 0) OR (l_reln_match_rule = 0)) then
     FND_MESSAGE.SET_NAME('AR', 'HZ_NO_MATCH_RULE');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  end if;

  -- call suggested defaults for address and relationship
  suggested_party_sites(p_batch_id, l_merge_type, l_addr_match_rule);
  suggested_party_reln(p_batch_id, l_merge_type, l_reln_match_rule);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO suggested_defaults;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO suggested_defaults;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN OTHERS THEN
   ROLLBACK TO suggested_defaults;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
   FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.Count_And_Get(
     p_encoded => FND_API.G_FALSE,
     p_count => x_msg_count,
     p_data  => x_msg_data);

END suggested_defaults;

PROCEDURE suggested_party_sites (
   p_batch_id                  IN      NUMBER
  ,p_merge_type                IN      VARCHAR2
  ,p_rule_id                   IN      NUMBER
) IS

  -- this is for merge multiple parties, get all sites which are not mandatory merge
  -- should not add condition merge_type = 'PARTY_MERGE'.  For multiple parties merge,
  -- merge_type may be 'SAME_PARTY_MERGE'.  It is because for master party sites in
  -- merge party details table, the merge_type is 'SAME_PARTY_MERGE'
  cursor not_mandatory_sites_mp is
  select merge_from_entity_id
  from HZ_MERGE_PARTYDTLS_SUGG mpd
     , HZ_MERGE_PARTIES_SUGG mp
     , hz_party_sites ps
  where mpd.batch_party_id = mp.batch_party_id
  and mp.batch_id = p_batch_id
  and ps.party_id = mp.from_party_id
  and ps.party_site_id = mpd.merge_from_entity_id
  and mpd.entity_name = 'HZ_PARTY_SITES'
  and mpd.merge_to_entity_id = mpd.merge_from_entity_id
  order by ps.status,mp.merge_type desc; -- make sure to process active sites first;

  -- this is for cleanse single party, find out the batch_party_id
  cursor get_merge_party_id is
  select batch_party_id, from_party_id
  from HZ_MERGE_PARTIES_SUGG
  where batch_id = p_batch_id
  and merge_type = 'SAME_PARTY_MERGE';

  -- this is for cleanse single party, get all sites which are not mandatory merge
  cursor not_mandatory_sites_sp(l_master_party NUMBER) is
  select party_site_id
  from HZ_PARTY_SITES ps
  where party_id = l_master_party
  and status in ('A','I')
  and not exists
  ( select 1
    from HZ_MERGE_PARTIES_SUGG mp
       , HZ_MERGE_PARTYDTLS_SUGG mpd
    where mp.batch_id = p_batch_id
    and mp.batch_party_id = mpd.batch_party_id
    and mpd.entity_name = 'HZ_PARTY_SITES'
    and mpd.merge_from_entity_id = ps.party_site_id)
  order by ps.status,decode(ps.actual_content_source,'DNB',1,2); -- make sure to process active sites first;

  -- for merge multiple parties
  -- check if the site is already mapped to some other site
  cursor check_mapped_sites_mp(l_from_site_id NUMBER) is
  select 'X'
  from HZ_MERGE_PARTIES_SUGG mp
     , HZ_MERGE_PARTYDTLS_SUGG mpd
  where mpd.merge_from_entity_id = l_from_site_id
  and mpd.merge_from_entity_id <> mpd.merge_to_entity_id
  and mpd.batch_party_id = mp.batch_party_id
  and mp.batch_id = p_batch_id
  and mpd.entity_name = 'HZ_PARTY_SITES';

  -- this is for cleanse single party
  -- since l_master_party is passed for the DQM search, we can assume that all matched party sites
  -- will be from the same l_master_party
  -- need to check if the matched addr is already mapped by other sites
  -- therefore, check if the site_id = merge_to_entity_id
  cursor get_suggested_addr(l_search_ctx_id NUMBER, l_master_site NUMBER) is
  select party_site_id
  from HZ_MATCHED_PARTY_SITES_GT mps
  where mps.search_context_id = l_search_ctx_id
  and mps.party_site_id <> l_master_site
  and not exists
  ( select 1
    from HZ_MERGE_PARTIES_SUGG mp
       , HZ_MERGE_PARTYDTLS_SUGG mpd
    where mpd.merge_to_entity_id = mps.party_site_id
    and mpd.batch_party_id = mp.batch_party_id
    and mp.batch_id = p_batch_id
    and mpd.entity_name = 'HZ_PARTY_SITES');

  -- for cleanse single party
  -- need to check if sites is already mapped to other site
  -- only mapped sites appear in HZ_MERGE_PARTYDTLS_SUGG, therefore if
  -- merge_from_entity_id = pass in site_id, then this site is mapped
  cursor check_mapped_sites_sp(l_from_site_id NUMBER) is
  select 'X'
  from HZ_MERGE_PARTIES_SUGG mp
     , HZ_MERGE_PARTYDTLS_SUGG mpd
  where mpd.merge_from_entity_id = l_from_site_id
  and mpd.batch_party_id = mp.batch_party_id
  and mp.batch_id = p_batch_id
  and mpd.entity_name = 'HZ_PARTY_SITES';

  CURSOR c_get_matched_ps(l_search_context_id NUMBER) IS
  SELECT party_site_id
  FROM HZ_MATCHED_PARTY_SITES_GT
  WHERE search_context_id = l_search_context_id;

CURSOR c_cust_site_check(p_from_entity_id NUMBER) IS
	select 1 from hz_cust_acct_sites_all where party_site_id=p_from_entity_id;

--4114254
CURSOR c_get_orig_system(p_party_site_id NUMBER) IS
        select o.orig_system
        from hz_party_sites ps, hz_orig_systems_b o
        where ps.party_site_id = p_party_site_id
        and   o.orig_system = ps.actual_content_source
        and   o.orig_system_type = 'PURCHASED';



  l_dummy            VARCHAR2(1);
  l_master_party     NUMBER;
  l_batch_party_id   NUMBER;
  l_master_site      NUMBER;
  l_merge_from_site  NUMBER;
  l_search_ctx_id    NUMBER;
  l_num_matches      NUMBER;
  l_return_status    VARCHAR2(30);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_loc              NUMBER;
  l_org              NUMBER;
  l_temp_from_site   NUMBER;
  l_count            NUMBER;

  l_from_country     HZ_LOCATIONS.COUNTRY%TYPE;
  l_to_country       HZ_LOCATIONS.COUNTRY%TYPE;
  l_from_city        HZ_LOCATIONS.CITY%TYPE;
  l_to_city          HZ_LOCATIONS.CITY%TYPE;
  l_from_state       HZ_LOCATIONS.STATE%TYPE;
  l_to_state         HZ_LOCATIONS.CITY%TYPE;
  l_from_county      HZ_LOCATIONS.COUNTY%TYPE;
  l_to_county        HZ_LOCATIONS.COUNTY%TYPE;
  l_from_province    HZ_LOCATIONS.PROVINCE%TYPE;
  l_to_province      HZ_LOCATIONS.PROVINCE%TYPE;
  l_from_postal_code HZ_LOCATIONS.postal_code%TYPE;
  l_to_postal_code   HZ_LOCATIONS.postal_code%TYPE;
  l_structure_id     NUMBER;
  l_qualifier        VARCHAR2(30);
  l_err_flg          VARCHAR2(1) := 'N';
  l_cust_sites		 NUMBER;

--4569674
l_merge_yn        VARCHAR2(2);
l_from_location_id NUMBER;
l_to_location_id   NUMBER;

--4114254
l_from_orig_system HZ_ORIG_SYSTEMS_B.ORIG_SYSTEM%TYPE;
l_to_orig_system HZ_ORIG_SYSTEMS_B.ORIG_SYSTEM%TYPE;
l_flag_merge varchar2(1);

BEGIN

  IF(p_merge_type = 'PARTY_MERGE') THEN
    -- get all sites that are not set to mandatory merge at the beginning
    OPEN not_mandatory_sites_mp;
    LOOP
      FETCH not_mandatory_sites_mp into l_master_site;
      EXIT WHEN not_mandatory_sites_mp%NOTFOUND;
      -- call DQM search to find duplicate addr for l_master_site
      -- restrict the search on those party sites among those merge parties

      -- if site is not merged, create the mapping
      OPEN check_mapped_sites_mp(l_master_site);
      FETCH check_mapped_sites_mp into l_dummy;
      IF (check_mapped_sites_mp%NOTFOUND) THEN

        HZ_PARTY_SEARCH.find_duplicate_party_sites
        (
           p_init_msg_list => FND_API.G_TRUE
          ,p_rule_id => p_rule_id
          ,p_party_site_id => l_master_site
          ,p_party_id => NULL
          ,p_restrict_sql => ' PARTY_SITE_ID IN (SELECT /*+ SELECTIVE_PS */ MERGE_FROM_ENTITY_ID' ||
                             ' FROM HZ_MERGE_PARTYDTLS_SUGG mpd, HZ_MERGE_PARTIES_SUGG mp' ||
                             ' WHERE mpd.MERGE_TO_ENTITY_ID = mpd.MERGE_FROM_ENTITY_ID' ||
                             ' AND mpd.BATCH_PARTY_ID =  mp.BATCH_PARTY_ID' ||
                             ' AND mpd.ENTITY_NAME = ''HZ_PARTY_SITES''' ||
                             ' AND mp.BATCH_ID = '|| p_batch_id ||')'
          ,p_match_type => 'OR'
          ,x_search_ctx_id => l_search_ctx_id
          ,x_num_matches => l_num_matches
          ,x_return_status => l_return_status
          ,x_msg_count => l_msg_count
          ,x_msg_data => l_msg_data
        );

        -- check loc assignment if number of match is greater than 0
        IF (l_num_matches > 0) THEN
          OPEN c_get_matched_ps(l_search_ctx_id);
          LOOP
            FETCH c_get_matched_ps INTO l_temp_from_site;
            EXIT WHEN c_get_matched_ps%NOTFOUND;
            l_merge_yn := null;

            --check if the party site has account sites
            OPEN c_cust_site_check(l_temp_from_site);
          	 Fetch c_cust_site_check into l_cust_sites;
        	IF c_cust_site_check %NOTFOUND THEN
                   null;
        	ELSE
--4569674
    		   SELECT location_id into l_from_location_id
		   FROM hz_party_sites
		   WHERE party_site_id = l_temp_from_site;

		   SELECT location_id into l_to_location_id
                   FROM hz_party_sites
                   WHERE party_site_id = l_master_site;


		   ZX_MERGE_LOC_CHECK_PKG.CHECK_GNR(l_from_location_id,
                                             	 l_to_location_id,
                                         	 FND_API.G_FALSE,
                                         	 l_merge_yn,
                    			 	 l_return_status,
                    			 	 l_msg_count,
                    			 	 l_msg_data);
		   IF l_merge_yn = 'N' THEN
	                DELETE FROM HZ_MATCHED_PARTY_SITES_GT
              		WHERE search_context_id = l_search_ctx_id
	                AND party_site_id = l_temp_from_site;
          		l_num_matches := l_num_matches - 1;
	 	   END IF;


	           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        	      RAISE FND_API.G_EXC_ERROR;
	           END IF;

--4569674
           END IF;
           CLOSE c_cust_site_check;

--4114254
           IF NVL(l_merge_yn,'Y') <> 'N' THEN

             OPEN c_get_orig_system(l_temp_from_site);
             FETCH c_get_orig_system INTO l_from_orig_system;

               IF c_get_orig_system%FOUND THEN
                  CLOSE c_get_orig_system;
                  OPEN c_get_orig_system(l_master_site);
                  FETCH c_get_orig_system INTO l_to_orig_system;

                    IF (c_get_orig_system%FOUND AND l_to_orig_system <> l_from_orig_system) OR
                        (c_get_orig_system%NOTFOUND) THEN

                        DELETE FROM HZ_MATCHED_PARTY_SITES_GT
                        WHERE search_context_id = l_search_ctx_id
                        AND party_site_id = l_temp_from_site;

                        l_num_matches := l_num_matches - 1;
                    END IF;
                  CLOSE c_get_orig_system;
               ELSE
                CLOSE c_get_orig_system;
              END IF;
           END IF;
--4114254
          END LOOP;
          CLOSE c_get_matched_ps;
        END IF;

        -- if found any match, update the merge party details temp table
        IF (l_num_matches > 0) THEN

          UPDATE HZ_MERGE_PARTYDTLS_SUGG
          SET merge_to_entity_id = l_master_site
            , mandatory_merge = 'N'
            , last_update_date = hz_utility_v2pub.last_update_date
            , last_updated_by = hz_utility_v2pub.last_updated_by
            , last_update_login = hz_utility_v2pub.last_update_login
          WHERE batch_party_id IN
          ( SELECT batch_party_id
            FROM HZ_MERGE_PARTIES_SUGG
            WHERE batch_id = p_batch_id )
          AND merge_from_entity_id IN
          ( SELECT party_site_id
            FROM HZ_MATCHED_PARTY_SITES_GT matchps
               , HZ_MERGE_PARTYDTLS_SUGG mpd
               , HZ_MERGE_PARTIES_SUGG mps
            WHERE matchps.search_context_id = l_search_ctx_id
            AND matchps.party_site_id = mpd.merge_from_entity_id
            AND mpd.entity_name = 'HZ_PARTY_SITES'
            AND mpd.merge_to_entity_id = mpd.merge_from_entity_id
            AND mpd.batch_party_id = mps.batch_party_id
            AND mps.batch_id = p_batch_id
            AND NOT EXISTS
            ( SELECT 1
              FROM HZ_MERGE_PARTYDTLS_SUGG mpdi
              WHERE mpdi.batch_party_id = mpd.batch_party_id
              AND mpdi.merge_to_entity_id = matchps.party_site_id
              AND mpdi.merge_to_entity_id <> mpdi.merge_from_entity_id
            )
          );
        END IF; -- l_num_matches > 0
      END IF; -- check_mapped_sites_mp
      CLOSE check_mapped_sites_mp;
    END LOOP; -- not_mandatory_sites_mp
    CLOSE not_mandatory_sites_mp;
  ELSIF(p_merge_type = 'SAME_PARTY_MERGE') THEN
    -- get batch_party_id and master party_id of the merge request, only one record for same party merge
    OPEN get_merge_party_id;
    FETCH get_merge_party_id INTO l_batch_party_id, l_master_party;
    CLOSE get_merge_party_id;
    -- find out all not mandatory merge sites
    OPEN not_mandatory_sites_sp(l_master_party);
    LOOP
      FETCH not_mandatory_sites_sp into l_master_site;
      EXIT WHEN not_mandatory_sites_sp%NOTFOUND;

      HZ_PARTY_SEARCH.find_duplicate_party_sites
      (
         p_init_msg_list => FND_API.G_TRUE
        ,p_rule_id => p_rule_id
        ,p_party_site_id => l_master_site
        ,p_party_id => l_master_party
        ,p_restrict_sql => NULL
        ,p_match_type => 'OR'
        ,x_search_ctx_id => l_search_ctx_id
        ,x_num_matches => l_num_matches
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
      );

      IF (l_num_matches > 0) THEN
        -- find out all matched sites from HZ_MATCHED_PARTY_SITES_GT
        OPEN get_suggested_addr(l_search_ctx_id, l_master_site);
        LOOP
          FETCH get_suggested_addr into l_merge_from_site;
          EXIT WHEN get_suggested_addr%NOTFOUND;

          l_merge_yn := null;

          -- if site is not merged, create the mapping
          OPEN check_mapped_sites_sp(l_merge_from_site);
          FETCH check_mapped_sites_sp into l_dummy;
          IF (check_mapped_sites_sp%NOTFOUND) THEN

--4569674
  	        SELECT location_id into l_from_location_id
		FROM hz_party_sites
		WHERE party_site_id = l_merge_from_site;

		SELECT location_id into l_to_location_id
                FROM hz_party_sites
                WHERE party_site_id = l_master_site;

		ZX_MERGE_LOC_CHECK_PKG.CHECK_GNR(l_from_location_id,
                                         	 l_to_location_id,
                                         	 FND_API.G_FALSE,
                                         	 l_merge_yn,
                    			 	 l_return_status,
                    			 	 l_msg_count,
                    			 	 l_msg_data);


               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
	       END IF;

              IF NVL(l_merge_yn,'Y') = 'Y' THEN

                 l_flag_merge := 'Y';
		     OPEN  c_get_orig_system(l_merge_from_site);
                 FETCH c_get_orig_system INTO l_from_orig_system;

                 IF    c_get_orig_system%FOUND THEN
                       CLOSE c_get_orig_system;
                       OPEN c_get_orig_system(l_master_site);
                       FETCH c_get_orig_system INTO l_to_orig_system;

                       IF (c_get_orig_system%FOUND AND
                           l_to_orig_system <> l_from_orig_system
                          ) OR
                          (c_get_orig_system%NOTFOUND)
                       THEN
                           l_flag_merge :='N';
                       END IF;
                         CLOSE c_get_orig_system;
                  ELSE                                  /* c_get_orig_system%NOTFOUND */
                         CLOSE c_get_orig_system;
                  END IF;                               /* c_get_orig_system%FOUND    */

			IF	l_flag_merge = 'Y' THEN
			      INSERT INTO HZ_MERGE_PARTYDTLS_SUGG
			      (
				 batch_party_id
				,entity_name
				,merge_from_entity_id
				,merge_to_entity_id
				,mandatory_merge
				,created_by
				,creation_date
				,last_update_login
				,last_update_date
				,last_updated_by
				,object_version_number
			      )
			      VALUES
			      (
				 l_batch_party_id
				,'HZ_PARTY_SITES'
				,l_merge_from_site
				,l_master_site
				,'N'
				,hz_utility_v2pub.created_by
				,hz_utility_v2pub.creation_date
				,hz_utility_v2pub.last_update_login
				,hz_utility_v2pub.last_update_date
				,hz_utility_v2pub.last_updated_by
				,1
			      );
                  END IF;--l_flag_merge
            END IF; --l_merge_yn
--4569674
          END IF; -- check_mapped_sites
          CLOSE check_mapped_sites_sp;
        END LOOP;
        CLOSE get_suggested_addr;
      END IF; -- l_num_matches > 0
    END LOOP; -- not_mandatory_sites_sp
    CLOSE not_mandatory_sites_sp;
  END IF;

EXCEPTION

   WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     APP_EXCEPTION.RAISE_EXCEPTION;

END suggested_party_sites;

PROCEDURE suggested_party_reln (
   p_batch_id                  IN      NUMBER
  ,p_merge_type                IN      VARCHAR2
  ,p_rule_id                   IN      NUMBER
) IS

  -- this is for merge multiple parties, get all relationships which are not mapped
  -- as mandatory merge
  -- all merge parties are the subject of the relationship
  -- e.g.  Oracle       Contact      Peter
  --       Oracle Corp  Contact      Peter
  --       Oracle Inc   Contact      Peter
  --       Assume Oracle Corp and Oracle Inc ---merge---> Oracle
  --       Then all relationships retrieved will be based on subject_id = Oracle,
  --       Oracle Corp and Oracle Inc
  cursor not_mandatory_reln_mp is
  select rel.relationship_id, rel.relationship_type, rel.relationship_code, rel.object_id, rel.subject_id, rel.subject_type, rel.object_type
  from HZ_MERGE_PARTYDTLS_SUGG mpd
     , HZ_MERGE_PARTIES_SUGG mp
     , HZ_RELATIONSHIPS rel
  where mpd.batch_party_id = mp.batch_party_id
  and mp.batch_id = p_batch_id
  and mpd.entity_name = 'HZ_PARTY_RELATIONSHIPS'
  and mpd.merge_from_entity_id = mpd.merge_to_entity_id
  and mpd.merge_from_entity_id = rel.relationship_id
  and rel.subject_id in (
    select dup_party_id
    from HZ_DUP_SET_PARTIES
    where dup_set_id = p_batch_id
    and nvl(merge_flag,'Y') <> 'N'
  )  ;

  -- this is for cleanse single party, pass in subject master which is the party to be cleansed
  cursor not_mandatory_reln_sp(l_master_party_id NUMBER) is
  select rel.relationship_id, rel.relationship_type, rel.relationship_code, rel.object_id, rel.subject_type, rel.object_type
  from HZ_RELATIONSHIPS rel
  where subject_id = l_master_party_id
  and not exists
  ( select 1
    from HZ_MERGE_PARTIES_SUGG mp
       , HZ_MERGE_PARTYDTLS_SUGG mpd
       , HZ_RELATIONSHIPS rel2
    where mp.batch_id = p_batch_id
    and mp.batch_party_id = mpd.batch_party_id
    and mpd.entity_name = 'HZ_PARTY_RELATIONSHIPS'
    and mpd.merge_from_entity_id = rel2.relationship_id
    and rel2.relationship_id = rel.relationship_id
    and rel2.object_id = rel.object_id
    and rel2.subject_id = rel.subject_id
    and rel2.subject_type = rel.subject_type
    and rel2.object_Type = rel.object_type
    and rel2.relationship_code = rel.relationship_code ) order by decode(rel.actual_content_source,'DNB',1,2);

  -- this is for cleanse single party, since relationship may have party record and each party record will have
  -- corresponding party sites to merge.  Those batch_party_id will be different.  Therefore, we need to filter
  -- by merge_type = 'SAME_PARTY_MERGE'
  cursor get_merge_party_id is
  select batch_party_id, from_party_id
  from HZ_MERGE_PARTIES_SUGG
  where batch_id = p_batch_id
  and merge_type = 'SAME_PARTY_MERGE';

  -- this is for cleanse single party, check if the matched parties is already mapped
  cursor get_suggested_reln(l_search_ctx_id NUMBER, l_reln_obj_id NUMBER, l_master_party NUMBER
                          , l_reln_type VARCHAR2, l_reln_code VARCHAR2, l_reln_sbj_type VARCHAR2
                          , l_reln_obj_type VARCHAR2) is
  select relationship_id
  from HZ_MATCHED_PARTIES_GT mpgt, HZ_RELATIONSHIPS rel
  where mpgt.search_context_id = l_search_ctx_id
  and mpgt.party_id <> l_reln_obj_id
  and mpgt.party_id = rel.object_id
  and rel.subject_id = l_master_party
  and rel.relationship_code = l_reln_code
  and rel.relationship_type = l_reln_type
  and not exists
  ( select 1
    from HZ_MERGE_PARTIES_SUGG mp
       , HZ_MERGE_PARTYDTLS_SUGG mpd
    where mpd.merge_to_entity_id = rel.relationship_id
    and mpd.batch_party_id = mp.batch_party_id
    and mp.batch_id = p_batch_id
    and mpd.entity_name = 'HZ_PARTY_RELATIONSHIPS');

  -- need to check if relationship is already mapped as merge_from_entity_id
  cursor check_mapped_reln(l_from_rel_id NUMBER) is
  select 'X'
  from HZ_MERGE_PARTIES_SUGG mp
     , HZ_MERGE_PARTYDTLS_SUGG mpd
  where mpd.merge_from_entity_id = l_from_rel_id
  and mpd.batch_party_id = mp.batch_party_id
  and mp.batch_id = p_batch_id
  and mpd.entity_name = 'HZ_PARTY_RELATIONSHIPS';

  --4114254
   CURSOR c_get_orig_system_r(rel_id NUMBER) IS
          select o.orig_system
          from hz_orig_systems_b o,hz_relationships r
          where r.relationship_id = rel_id
          and o.orig_system = r.actual_content_source
          and o.orig_system_type = 'PURCHASED'
          and directional_flag = 'F';
--4114254

 cursor c_get_rel_status(cp_id number) is
         select status
	     from  hz_relationships
	     where relationship_id = cp_id
         and rownum = 1;

  TYPE merge_from_reln_tbl IS TABLE OF NUMBER;
  l_merge_from_reln_tbl  merge_from_reln_tbl;

  l_dummy            VARCHAR2(1);
  l_reln_id          NUMBER;
  l_reln_obj_id      NUMBER;
  l_reln_sbj_id      NUMBER;
  l_reln_type        VARCHAR2(30);
  l_reln_code        VARCHAR2(30);
  l_reln_bpty_id     NUMBER;
  l_reln_sbj_type    VARCHAR2(30);
  l_reln_obj_type    VARCHAR2(30);
  l_rel_party_count  NUMBER;
  l_batch_party_id   NUMBER;
  l_from_rel_party_id NUMBER;
  l_to_rel_party_id   NUMBER;
  l_merge_from_reln  NUMBER;
  l_master_party     NUMBER;
  l_dup_set_id       NUMBER;
  l_search_ctx_id    NUMBER;
  l_num_matches      NUMBER;
  l_return_status    VARCHAR2(30);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);

--4114254
  l_from_orig_system HZ_ORIG_SYSTEMS_B.ORIG_SYSTEM%TYPE;
  l_to_orig_system HZ_ORIG_SYSTEMS_B.ORIG_SYSTEM%TYPE;
  l_to_orig_system_type HZ_ORIG_SYSTEMS_B.ORIG_SYSTEM_TYPE%TYPE;
  l_flag_merge VARCHAR2(1);
  l_rel_status varchar2(1);

BEGIN

  IF(p_merge_type = 'PARTY_MERGE') THEN
    -- find out all not mandatory merge relationships
    -- Need to get subject_id, object_id of the relationship
    -- Subject_id will be the merge parties
    -- Object_id will be the related parties
    -- By passing object_id to DQM and return matched related parties which are related to merge parties
    OPEN not_mandatory_reln_mp;
    LOOP
      FETCH not_mandatory_reln_mp into l_reln_id, l_reln_type, l_reln_code, l_reln_obj_id, l_reln_sbj_id, l_reln_sbj_type, l_reln_obj_type;
      EXIT WHEN not_mandatory_reln_mp%NOTFOUND;

      -- call DQM search to find out matched parties
      HZ_PARTY_SEARCH.find_duplicate_parties
      (
         p_init_msg_list => FND_API.G_TRUE
        ,p_rule_id => p_rule_id
        ,p_party_id => l_reln_obj_id
        ,p_restrict_sql => 'stage.PARTY_ID IN (SELECT /*+ SELECTIVE */ OBJECT_ID' ||
                           ' FROM HZ_RELATIONSHIPS rel' ||
                           ' WHERE rel.SUBJECT_TYPE = '''||l_reln_sbj_type||''''||
                           ' AND rel.OBJECT_TYPE = '''||l_reln_obj_type||''''||
                           ' AND rel.RELATIONSHIP_TYPE = '''||l_reln_type||''''||
                           ' AND rel.SUBJECT_ID IN (select dup_party_id' ||
                           ' from HZ_DUP_SET_PARTIES where dup_set_id = '|| p_batch_id||
                           ' and nvl(merge_flag,''Y'''||')'||' <> ''N'''||')'||
                           ' AND rel.RELATIONSHIP_CODE = '''|| l_reln_code||''' )'
        ,p_match_type => 'OR'
        ,p_dup_batch_id => NULL
        ,p_search_merged => 'N'
        ,x_dup_set_id => l_dup_set_id
        ,x_search_ctx_id => l_search_ctx_id
        ,x_num_matches => l_num_matches
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
      );

      -- if found any matches
      IF (l_num_matches > 0) THEN

        select o.orig_system,o.orig_system_type into  l_to_orig_system,l_to_orig_system_type
        from hz_orig_systems_b o,hz_relationships r
        where r.relationship_id = l_reln_id
        and   o.orig_system = r.actual_content_source
        and   directional_flag = 'F';

   -- start bug 5194384
        open c_get_rel_status(l_reln_id);
        fetch c_get_rel_status into l_rel_status;
        close c_get_rel_status;

        if l_num_matches = 1 and l_rel_status = 'I'
        then
          begin
           select relationship_id into l_reln_id --get active rel id
           from hz_relationships
           where object_id = l_reln_obj_id
           and status = 'A'
           and rownum = 1;
         exception WHEN NO_DATA_FOUND THEN null;
         end;
        end if;
      if not(l_num_matches > 1 and l_rel_status = 'I')
      then
  -- end bug 5194384

        UPDATE HZ_MERGE_PARTYDTLS_SUGG
        SET merge_to_entity_id = l_reln_id
          , mandatory_merge = 'N'
          , last_update_date = hz_utility_v2pub.last_update_date
          , last_updated_by = hz_utility_v2pub.last_updated_by
          , last_update_login = hz_utility_v2pub.last_update_login
        WHERE batch_party_id in
        ( SELECT batch_party_id
          FROM HZ_MERGE_PARTIES_SUGG
          WHERE batch_id = p_batch_id )
        AND merge_from_entity_id IN
        ( SELECT rel.relationship_id
          FROM HZ_MATCHED_PARTIES_GT matchpty
             , HZ_MERGE_PARTYDTLS_SUGG mpd
             , HZ_MERGE_PARTIES_SUGG mps
             , HZ_RELATIONSHIPS rel
             , HZ_ORIG_SYSTEMS_B O
          WHERE matchpty.search_context_id = l_search_ctx_id
          AND matchpty.party_id = rel.object_id
          AND rel.relationship_code = l_reln_code
          AND rel.relationship_type = l_reln_type
          AND rel.relationship_id = mpd.merge_from_entity_id
          AND rel.subject_type = l_reln_sbj_type
          AND rel.object_type = l_reln_obj_type
          AND mpd.entity_name = 'HZ_PARTY_RELATIONSHIPS'
          AND mpd.merge_to_entity_id = mpd.merge_from_entity_id
          AND mpd.batch_party_id = mps.batch_party_id
          AND mps.batch_id = p_batch_id
          AND o.orig_system = rel.actual_content_source
	  AND decode(o.orig_system_type,'PURCHASED',(decode(l_to_orig_system_type,'PURCHASED',(decode(o.orig_system,l_to_orig_system,1,0)),0)),1)= 1
          AND NOT EXISTS
          ( SELECT 1
            FROM HZ_MERGE_PARTYDTLS_SUGG mpdi,
                 HZ_MERGE_PARTIES_SUGG mpsi
            WHERE mpdi.batch_party_id = mpsi.batch_party_id
            AND mpsi.batch_id = mps.batch_id
            AND mpdi.merge_to_entity_id = rel.relationship_id
            AND mpdi.merge_to_entity_id <> mpdi.merge_from_entity_id
          )
        ) RETURNING merge_from_entity_id BULK COLLECT INTO l_merge_from_reln_tbl;

        -- as merge multiple party may find more than 1 duplicate reln parties
        -- we need to loop through all parties and check for relationship party
        FOR i IN 1..l_merge_from_reln_tbl.COUNT LOOP

          -- check to see if there exist any relationship party, then do the party merge
          l_from_rel_party_id := hz_merge_util.get_reln_party_id(l_merge_from_reln_tbl(i));
          l_to_rel_party_id := hz_merge_util.get_reln_party_id(l_reln_id);

          select count(1) into l_rel_party_count
          from HZ_MERGE_PARTIES
          where batch_id = p_batch_id
          and merge_type = 'PARTY_MERGE'
          and merge_reason_code = 'DUPLICATE_RELN_PARTY'
          and from_party_id = l_from_rel_party_id;

          -- if not found any DUPLICATE_RELN_PARTY for the merge batch, create one
          IF l_rel_party_count = 0 AND l_from_rel_party_id IS NOT NULL AND l_to_rel_party_id IS NOT NULL THEN
            insert_sugg_reln_party(p_batch_id
                                  ,l_from_rel_party_id
                                  ,l_to_rel_party_id
                                  ,l_reln_bpty_id);
            -- check to see if those relationship party has party_site, merge it as mandatory
            -- Also insert the Party sites for reln Party if there are any
            insert_sugg_reln_ps_details(l_from_rel_party_id
                                       ,l_to_rel_party_id
                                       ,l_reln_bpty_id, 'Y');
          END IF;  --l_rel_party_count
        END LOOP; --count the number of reln_id and loop to insert relationship's party
      end if; -- not (l_num_matches > 1...
      END IF; -- l_num_matches > 0
    END LOOP; -- not_mandatory_reln_mp
    CLOSE not_mandatory_reln_mp;
  ELSIF (p_merge_type = 'SAME_PARTY_MERGE') THEN
    -- get batch_party_id and master party_id of the merge request, only one record for same party merge
    OPEN get_merge_party_id;
    FETCH get_merge_party_id INTO l_batch_party_id, l_master_party;
    CLOSE get_merge_party_id;

    -- find out all not mandatory merge relationships
    OPEN not_mandatory_reln_sp(l_master_party);
    LOOP
      FETCH not_mandatory_reln_sp into l_reln_id, l_reln_type, l_reln_code, l_reln_obj_id, l_reln_sbj_type, l_reln_obj_type;
      EXIT WHEN not_mandatory_reln_sp%NOTFOUND;

      HZ_PARTY_SEARCH.find_duplicate_parties
      (
         p_init_msg_list => FND_API.G_TRUE
        ,p_rule_id => p_rule_id
        ,p_party_id => l_reln_obj_id
        ,p_restrict_sql => 'stage.PARTY_ID IN (SELECT /*+ SELECTIVE */ OBJECT_ID' ||
                           ' FROM HZ_RELATIONSHIPS rel' ||
                           ' WHERE rel.SUBJECT_ID = '|| l_master_party||
                           ' AND rel.SUBJECT_TYPE = '''||l_reln_sbj_type||''''||
                           ' AND rel.OBJECT_TYPE = '''||l_reln_obj_type||''''||
                           ' AND rel.relationship_type = '''||l_reln_type||''''||
                           ' AND rel.relationship_code = '''|| l_reln_code||''' )'
        ,p_match_type => 'OR'
        ,p_dup_batch_id => NULL
        ,p_search_merged => 'N'
        ,x_dup_set_id => l_dup_set_id
        ,x_search_ctx_id => l_search_ctx_id
        ,x_num_matches => l_num_matches
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
      );

      IF (l_num_matches > 0) THEN
        OPEN get_suggested_reln(l_search_ctx_id, l_reln_obj_id, l_master_party, l_reln_type, l_reln_code, l_reln_sbj_type, l_reln_obj_type);
        LOOP
          FETCH get_suggested_reln into l_merge_from_reln;
          EXIT WHEN get_suggested_reln%NOTFOUND;

          -- if relationship is not mapped, then create mapping
          OPEN check_mapped_reln(l_merge_from_reln);
          FETCH check_mapped_reln into l_dummy;
          IF (check_mapped_reln%NOTFOUND) THEN

--4114254
          l_flag_merge := 'Y';
	    OPEN  c_get_orig_system_r(l_merge_from_reln);
  	    FETCH c_get_orig_system_r INTO l_from_orig_system;

	    IF    c_get_orig_system_r%FOUND THEN
	          CLOSE c_get_orig_system_r;
	          OPEN c_get_orig_system_r(l_reln_id);
	          FETCH c_get_orig_system_r INTO l_to_orig_system;

  	          IF (c_get_orig_system_r%FOUND AND
		     l_to_orig_system <> l_from_orig_system
		     ) OR
		     (c_get_orig_system_r%NOTFOUND)
	          THEN
                 l_flag_merge := 'N';
                 END IF;
                  CLOSE c_get_orig_system_r;
            ELSE                                  /* c_get_orig_system%NOTFOUND */
                  CLOSE c_get_orig_system_r;
            END IF;                               /* c_get_orig_system%FOUND    */

		IF l_flag_merge = 'Y' THEN
		    INSERT INTO HZ_MERGE_PARTYDTLS_SUGG
		    (
		       batch_party_id
		      ,entity_name
		      ,merge_from_entity_id
		      ,merge_to_entity_id
		      ,mandatory_merge
		      ,created_by
		      ,creation_date
		      ,last_update_login
		      ,last_update_date
		      ,last_updated_by
		      ,object_version_number
		    )
		    VALUES
		    (
		       l_batch_party_id
		      ,'HZ_PARTY_RELATIONSHIPS'
		      ,l_merge_from_reln
		      ,l_reln_id
		      ,'N'
		      ,hz_utility_v2pub.created_by
		      ,hz_utility_v2pub.creation_date
		      ,hz_utility_v2pub.last_update_login
		      ,hz_utility_v2pub.last_update_date
		      ,hz_utility_v2pub.last_updated_by
		      ,1
		    );

		    -- find out those related party sites
		    l_from_rel_party_id := hz_merge_util.get_reln_party_id(l_merge_from_reln);
		    l_to_rel_party_id := hz_merge_util.get_reln_party_id(l_reln_id);

		    select count(1) into l_rel_party_count
		    from HZ_MERGE_PARTIES
		    where batch_id = p_batch_id
		    and merge_type = 'PARTY_MERGE'
		    and merge_reason_code = 'DUPLICATE_RELN_PARTY'
		    and from_party_id = l_from_rel_party_id;

		    -- if the relationship has party record, then do merge on those relationship party
		    if((l_from_rel_party_id is not null) and
		       (l_to_rel_party_id is not null) and
		       (l_from_rel_party_id <> l_to_rel_party_id)) then
		      if(l_rel_party_count = 0) then
			-- insert party relationship merge record
			insert_sugg_reln_party(p_batch_id
					      ,l_from_rel_party_id
					      ,l_to_rel_party_id
					      ,l_reln_bpty_id);
			-- insert relationship party's sites record
			insert_sugg_reln_ps_details(l_from_rel_party_id
						   ,l_to_rel_party_id
						   ,l_reln_bpty_id, 'Y');
		      end if; -- check if the relationship party record has been added to HZ_MERGE_PARTIES
		    end if; -- check if there exist relationship party

            END IF;--l_merge_flag
          END IF; -- check_mapped_reln
          CLOSE check_mapped_reln;
        END LOOP; -- get_suggested_addr
        CLOSE get_suggested_reln;
      END IF; -- l_num_matches > 0
    END LOOP; -- not_mandatory_reln_sp
    CLOSE not_mandatory_reln_sp;
  END IF; -- p_merge_type = 'SAME_PARTY_MERGE'

EXCEPTION

   WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     APP_EXCEPTION.RAISE_EXCEPTION;

END suggested_party_reln;

PROCEDURE insert_sugg_reln_ps_details (
  p_from_party_id	     IN	NUMBER,
  p_to_party_id	     IN	NUMBER,
  p_batch_party_id     IN	NUMBER,
  p_reln_parties       IN VARCHAR2 DEFAULT 'N'
) IS

  --Cursor for inserting Party sites that are non-DNB
  CURSOR c_from_ps_loc IS
    SELECT party_site_id, ps.location_id
    FROM HZ_PARTY_SITES ps
    WHERE ps.party_id = p_from_party_id
    AND ps.actual_content_source <>'DNB'
    AND nvl(status, 'A') in ('A','I');

  CURSOR c_dup_to_ps(cp_loc_id NUMBER) IS
    SELECT party_site_id
    FROM HZ_PARTY_SITES ps
    WHERE ps.party_id = p_to_party_id
    AND ps.location_id = cp_loc_id
    AND ps.actual_content_source <>'DNB'
    AND nvl(status, 'A') in ('A','I');

  l_ps_id NUMBER;
  l_loc_id NUMBER;
  l_dup_ps_id NUMBER;
  l_sqerr VARCHAR2(2000);
  l_mandatory_merge VARCHAR2(1);

BEGIN

  OPEN c_from_ps_loc;
  LOOP
    FETCH c_from_ps_loc INTO l_ps_id, l_loc_id;
    EXIT WHEN c_from_ps_loc%NOTFOUND;
    IF p_from_party_id <> p_to_party_id THEN
      l_mandatory_merge := 'Y';
    ELSE
      l_mandatory_merge := 'N';
    END IF;

    OPEN c_dup_to_ps(l_loc_id);
    FETCH c_dup_to_ps INTO l_dup_ps_id;
    IF c_dup_to_ps%FOUND THEN
      INSERT INTO HZ_MERGE_PARTYDTLS_SUGG
      (
         batch_party_id
        ,entity_name
        ,merge_from_entity_id
        ,merge_to_entity_id
        ,mandatory_merge
        ,created_by
        ,creation_date
        ,last_update_login
        ,last_update_date
        ,last_updated_by
        ,object_version_number
      )
      VALUES
      (
         p_batch_party_id
        ,'HZ_PARTY_SITES'
        ,l_ps_id
        ,l_dup_ps_id
        ,l_mandatory_merge
        ,hz_utility_v2pub.created_by
        ,hz_utility_v2pub.creation_date
        ,hz_utility_v2pub.last_update_login
        ,hz_utility_v2pub.last_update_date
        ,hz_utility_v2pub.last_updated_by
        ,1
      );
    ELSE
      IF p_reln_parties = 'N' THEN
        INSERT INTO HZ_MERGE_PARTYDTLS_SUGG
        (
           batch_party_id
          ,entity_name
          ,merge_from_entity_id
          ,merge_to_entity_id
          ,mandatory_merge
          ,created_by
          ,creation_date
          ,last_update_login
          ,last_update_date
          ,last_updated_by
          ,object_version_number
        )
        VALUES
        (
           p_batch_party_id
          ,'HZ_PARTY_SITES'
          ,l_ps_id
          ,null
          ,'N'
          ,hz_utility_v2pub.created_by
          ,hz_utility_v2pub.creation_date
          ,hz_utility_v2pub.last_update_login
          ,hz_utility_v2pub.last_update_date
          ,hz_utility_v2pub.last_updated_by
          ,1
        );
      ELSE
        INSERT INTO HZ_MERGE_PARTYDTLS_SUGG
        (
           batch_party_id
          ,entity_name
          ,merge_from_entity_id
          ,merge_to_entity_id
          ,mandatory_merge
          ,created_by
          ,creation_date
          ,last_update_login
          ,last_update_date
          ,last_updated_by
          ,object_version_number
        )
        VALUES
        (
           p_batch_party_id
          ,'HZ_PARTY_SITES'
          ,l_ps_id
          ,l_ps_id
          ,'N'
          ,hz_utility_v2pub.created_by
          ,hz_utility_v2pub.creation_date
          ,hz_utility_v2pub.last_update_login
          ,hz_utility_v2pub.last_update_date
          ,hz_utility_v2pub.last_updated_by
          ,1
        );
      END IF; -- p_reln_parties = 'N'
    END IF;
    CLOSE c_dup_to_ps;
  END LOOP;
  CLOSE c_from_ps_loc;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  APP_EXCEPTION.RAISE_EXCEPTION;
END insert_sugg_reln_ps_details;

PROCEDURE insert_sugg_reln_party(
  p_batch_id           IN NUMBER,
  p_from_rel_party_id  IN NUMBER,
  p_to_rel_party_id    IN NUMBER,
  x_batch_party_id     OUT NOCOPY NUMBER
) IS

BEGIN

  select HZ_MERGE_PARTIES_S.nextval into x_batch_party_id
  from dual;

  INSERT INTO HZ_MERGE_PARTIES_SUGG
  (
     BATCH_PARTY_ID
    ,BATCH_ID
    ,MERGE_TYPE
    ,FROM_PARTY_ID
    ,TO_PARTY_ID
    ,MERGE_REASON_CODE
    ,MERGE_STATUS
    ,created_by
    ,creation_date
    ,last_update_login
    ,last_update_date
    ,last_updated_by
  )
  VALUES
  (
     x_batch_party_id
    ,p_batch_id
    ,'PARTY_MERGE'
    ,p_from_rel_party_id
    ,p_to_rel_party_id
    ,'DUPLICATE_RELN_PARTY'
    ,'PENDING'
    ,hz_utility_v2pub.created_by
    ,hz_utility_v2pub.creation_date
    ,hz_utility_v2pub.last_update_login
    ,hz_utility_v2pub.last_update_date
    ,hz_utility_v2pub.last_updated_by
  );

EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
  FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
  APP_EXCEPTION.RAISE_EXCEPTION;
END insert_sugg_reln_party;

--
-- PROCEDURE apply_suggested_default
--
-- DESCRIPTION
--      Copy suggested default mapping to HZ_MERGE_PARTY_DETAILS
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_batch_id          ID of the merge batch
--     p_entity_name       HZ_PARTY_SITES - Addresses or HZ_RELATIONSHIPS - Relationships
--     p_merge_type        Merge type of the dup set
--
--   OUT:
--     x_return_status       Return status after the call. The status can
--                           be fnd_api.g_ret_sts_success (success),
--                           fnd_api.g_ret_sts_error (error),
--                           fnd_api.g_ret_sts_unexp_error
--                           (unexpected error).
--     x_msg_count           Number of messages in message stack.
--     x_msg_data            Message text if x_msg_count is 1.
--
-- NOTES
--
-- MODIFICATION HISTORY
--
--   10/09/2002    Arnold Ng         o Created.
--
--
PROCEDURE apply_suggested_default (
   p_batch_id                  IN      NUMBER
  ,p_entity_name               IN      VARCHAR2
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS
BEGIN

  savepoint apply_suggested_default;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM HZ_MERGE_PARTY_DETAILS
  WHERE BATCH_PARTY_ID IN
  ( SELECT BATCH_PARTY_ID
    FROM HZ_MERGE_PARTIES
    WHERE BATCH_ID = p_batch_id )
  AND ENTITY_NAME = p_entity_name;

  INSERT INTO HZ_MERGE_PARTY_DETAILS
  (
    batch_party_id
   ,entity_name
   ,merge_from_entity_id
   ,merge_to_entity_id
   ,mandatory_merge
   ,created_by
   ,creation_date
   ,last_update_login
   ,last_updated_by
   ,last_update_date
   ,object_version_number
  )
  SELECT
    batch_party_id
   ,entity_name
   ,merge_from_entity_id
   ,merge_to_entity_id
   ,mandatory_merge
   ,hz_utility_v2pub.created_by
   ,hz_utility_v2pub.creation_date
   ,hz_utility_v2pub.last_update_login
   ,hz_utility_v2pub.last_updated_by
   ,hz_utility_v2pub.last_update_date
   ,1
  FROM HZ_MERGE_PARTYDTLS_SUGG
  WHERE entity_name = p_entity_name
  AND batch_party_id IN
  ( SELECT batch_party_id
    FROM HZ_MERGE_PARTIES_SUGG
    WHERE batch_id = p_batch_id );

  -- if entity is HZ_RELATIONSHIPS, insert DUPLICATE_RELN_PARTY record to
  -- HZ_MERGE_PARTIES table as well

  IF(p_entity_name = 'HZ_PARTY_RELATIONSHIPS') THEN

    DELETE FROM HZ_MERGE_PARTIES
    WHERE batch_id = p_batch_id
    AND merge_reason_code = 'DUPLICATE_RELN_PARTY';

    INSERT INTO HZ_MERGE_PARTIES
    (
      batch_party_id
     ,batch_id
     ,merge_type
     ,from_party_id
     ,to_party_id
     ,merge_reason_code
     ,merge_status
     ,created_by
     ,creation_date
     ,last_update_login
     ,last_updated_by
     ,last_update_date
    )
    SELECT
      batch_party_id
     ,batch_id
     ,merge_type
     ,from_party_id
     ,to_party_id
     ,merge_reason_code
     ,merge_status
     ,created_by
     ,creation_date
     ,last_update_login
     ,last_updated_by
     ,last_update_date
    FROM HZ_MERGE_PARTIES_SUGG mp
    WHERE mp.batch_id = p_batch_id
    AND mp.merge_reason_code = 'DUPLICATE_RELN_PARTY';

  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO apply_suggested_default;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO apply_suggested_default;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO apply_suggested_default;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
     p_encoded => FND_API.G_FALSE,
     p_count => x_msg_count,
     p_data  => x_msg_data);

END apply_suggested_default;

--
-- PROCEDURE clear_suggested_default
--
-- DESCRIPTION
--      Clear address/relationship mapping
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_batch_id          ID of the merge batch
--     p_entity_name       HZ_PARTY_SITES - Addresses or HZ_RELATIONSHIPS - Relationships
--     p_merge_type        Merge type of the dup set
--
--   OUT:
--     x_return_status       Return status after the call. The status can
--                           be fnd_api.g_ret_sts_success (success),
--                           fnd_api.g_ret_sts_error (error),
--                           fnd_api.g_ret_sts_unexp_error
--                           (unexpected error).
--     x_msg_count           Number of messages in message stack.
--     x_msg_data            Message text if x_msg_count is 1.
--
-- NOTES
--
-- MODIFICATION HISTORY
--
--   10/09/2002    Arnold Ng         o Created.
--
--
PROCEDURE clear_suggested_default (
   p_batch_id                  IN      NUMBER
  ,p_entity_name               IN      VARCHAR2
  ,p_merge_type                IN      VARCHAR2
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

  CURSOR find_mand_reln IS
  SELECT HZ_MERGE_UTIL.get_reln_party_id(a.merge_from_entity_id)
       , HZ_MERGE_UTIL.get_reln_party_id(a.merge_from_entity_id)
  FROM HZ_MERGE_PARTYDTLS_SUGG a
     , HZ_MERGE_PARTIES_SUGG b
  WHERE b.batch_id = p_batch_id
  AND a.entity_name = 'HZ_PARTY_RELATIONSHIPS'
  AND a.batch_party_id = b.batch_party_id
  AND a.mandatory_merge = 'Y';

  l_reln_from_pid    NUMBER;
  l_reln_to_pid      NUMBER;
  l_reln_bpty_id     NUMBER;

BEGIN


  savepoint clear_suggested_default;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(p_merge_type = 'PARTY_MERGE') THEN


    -- copy mapping from suggested defaults table
    UPDATE HZ_MERGE_PARTY_DETAILS mpd
    SET mpd.merge_from_entity_id =
        ( SELECT merge_from_entity_id
          FROM HZ_MERGE_PARTYDTLS_SUGG mps
          WHERE mpd.batch_party_id = mps.batch_party_id
          AND mpd.merge_from_entity_id = mps.merge_from_entity_id
          AND mpd.entity_name = mps.entity_name ),
        mpd.mandatory_merge =
        ( SELECT mandatory_merge
          FROM HZ_MERGE_PARTYDTLS_SUGG mps
          WHERE mpd.batch_party_id = mps.batch_party_id
          AND mpd.merge_from_entity_id = mps.merge_from_entity_id
          AND mpd.entity_name = mps.entity_name ),
        mpd.last_update_login = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN ,
        mpd.last_updated_by = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        mpd.last_update_date = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        mpd.object_version_number = nvl(mpd.object_version_number,1)+1
    WHERE entity_name = p_entity_name
    AND batch_party_id IN
    ( SELECT batch_party_id
      FROM HZ_MERGE_PARTIES_SUGG
      WHERE batch_id = p_batch_id );



    -- clean up all non-mandatory merge sites and reln mapping in merge party details
    UPDATE HZ_MERGE_PARTY_DETAILS
    SET merge_to_entity_id = merge_from_entity_id
    WHERE mandatory_merge <> 'Y'
    AND entity_name = p_entity_name
    AND batch_party_id IN
    ( SELECT batch_party_id
      FROM HZ_MERGE_PARTIES
      WHERE batch_id = p_batch_id );


  ELSIF(p_merge_type = 'SAME_PARTY_MERGE') THEN

    -- remove all mapping
    DELETE HZ_MERGE_PARTY_DETAILS
    WHERE entity_name = p_entity_name
    AND batch_party_id IN
    ( SELECT batch_party_id
      FROM HZ_MERGE_PARTIES
      WHERE batch_id = p_batch_id );

    -- only insert those mandatory merge mapping
    INSERT INTO HZ_MERGE_PARTY_DETAILS
    (
      batch_party_id
     ,entity_name
     ,merge_from_entity_id
     ,merge_to_entity_id
     ,mandatory_merge
     ,created_by
     ,creation_date
     ,last_update_login
     ,last_updated_by
     ,last_update_date
     ,object_version_number
    )
    SELECT
      batch_party_id
     ,entity_name
     ,merge_from_entity_id
     ,merge_to_entity_id
     ,mandatory_merge
     ,hz_utility_v2pub.created_by
     ,hz_utility_v2pub.creation_date
     ,hz_utility_v2pub.last_update_login
     ,hz_utility_v2pub.last_updated_by
     ,hz_utility_v2pub.last_update_date
     ,1
    FROM HZ_MERGE_PARTYDTLS_SUGG
    WHERE mandatory_merge = 'Y'
    AND entity_name = p_entity_name
    AND batch_party_id IN
    ( SELECT batch_party_id
      FROM HZ_MERGE_PARTIES_SUGG
      WHERE batch_id = p_batch_id );

  END IF;

  IF(p_entity_name = 'HZ_PARTY_RELATIONSHIPS') THEN

    -- remove all DUPLICATE_RELN_PARTY record in HZ_MERGE_PARTIES first
    -- then recreate them by finding out all relationship mandatory
    -- merge at HZ_MERGE_PARTY_DETAILS


    DELETE FROM HZ_MERGE_PARTIES mp
    WHERE mp.batch_id = p_batch_id
    AND mp.merge_reason_code = 'DUPLICATE_RELN_PARTY';


    OPEN find_mand_reln;
    LOOP
      FETCH find_mand_reln INTO l_reln_from_pid, l_reln_to_pid;
      EXIT WHEN find_mand_reln%NOTFOUND;


      insert_sugg_reln_party(p_batch_id
                       ,l_reln_from_pid
                       ,l_reln_to_pid
                       ,l_reln_bpty_id);


      -- check to see if those relationship party has party_site, merge it as mandatory
      -- Also insert the Party sites for reln Party if there are any
      insert_sugg_reln_ps_details(l_reln_from_pid
                                 ,l_reln_to_pid
                                 ,l_reln_bpty_id, 'Y');


    END LOOP;


    CLOSE find_mand_reln;

  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO clear_suggested_default;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO clear_suggested_default;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO clear_suggested_default;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
     p_encoded => FND_API.G_FALSE,
     p_count => x_msg_count,
     p_data  => x_msg_data);

END clear_suggested_default;

--
-- PROCEDURE create_reln_sysbatch
--
-- DESCRIPTION
--      Create dup batch based on relationship merge of a merge batch
--      If there exists relationship mapping, this procedure will create
--      dup batch for both parties involved in the relationship merge
--      E.g.: Peter-Contact Of-Oracle  merge to  Peter2-Contact Of-Oracle
--      Then, create dup batch for Peter merge to Peter2
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_batch_id          ID of the merge batch
--     p_merge_type        Merge type of the dup set
--
--   OUT:
--     x_return_status       Return status after the call. The status can
--                           be fnd_api.g_ret_sts_success (success),
--                           fnd_api.g_ret_sts_error (error),
--                           fnd_api.g_ret_sts_unexp_error
--                           (unexpected error).
--     x_msg_count           Number of messages in message stack.
--     x_msg_data            Message text if x_msg_count is 1.
--
-- NOTES
--
-- MODIFICATION HISTORY
--
--   10/09/2002    Arnold Ng         o Created.
--
--
PROCEDURE create_reln_sysbatch (
   p_batch_id                  IN      NUMBER
  ,p_merge_type                IN      VARCHAR2
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2
) IS

  CURSOR get_reln_party_sp IS
  select to_rel.subject_id, count(1)
  from HZ_MERGE_PARTY_DETAILS mpd, HZ_MERGE_PARTIES mp
     , HZ_RELATIONSHIPS from_rel, HZ_RELATIONSHIPS to_rel
     , HZ_PARTIES from_pty, HZ_PARTIES to_pty
  where mpd.batch_party_id = mp.batch_party_id
  and mp.batch_id = p_batch_id
  and mpd.entity_name = 'HZ_PARTY_RELATIONSHIPS'
  and mpd.merge_from_entity_id = from_rel.relationship_id
  and mpd.merge_to_entity_id = to_rel.relationship_id
  and from_rel.object_id =
    ( select winner_party_id
      from HZ_DUP_SETS where dup_set_id = p_batch_id )
  and to_rel.object_id =
    ( select winner_party_id
      from HZ_DUP_SETS where dup_set_id = p_batch_id )
  and from_rel.subject_id = from_pty.party_id
  and to_rel.subject_id = to_pty.party_id
  group by to_rel.subject_id;

  CURSOR get_reln_party_mp IS
  select to_rel.subject_id, count(1)
  from HZ_MERGE_PARTY_DETAILS mpd, HZ_MERGE_PARTIES mp
     , HZ_RELATIONSHIPS from_rel, HZ_RELATIONSHIPS to_rel
     , HZ_PARTIES from_pty, HZ_PARTIES to_pty
  where mpd.batch_party_id = mp.batch_party_id
  and mpd.merge_from_entity_id <> mpd.merge_to_entity_id
  and mp.batch_id = p_batch_id
  and mpd.entity_name = 'HZ_PARTY_RELATIONSHIPS'
  and mpd.merge_from_entity_id = from_rel.relationship_id
  and mpd.merge_to_entity_id = to_rel.relationship_id
  and from_rel.object_id in
  ( select dup_party_id
    from HZ_DUP_SET_PARTIES
    where dup_set_id = p_batch_id
    and nvl(merge_flag,'Y') <> 'N' )
  and to_rel.object_id in
  ( select dup_party_id
    from HZ_DUP_SET_PARTIES
    where dup_set_id = p_batch_id
    and nvl(merge_flag,'Y') <> 'N' )
  and from_rel.subject_id = from_pty.party_id
  and to_rel.subject_id = to_pty.party_id
  group by to_rel.subject_id;

  CURSOR get_reln_from_party_sp(l_to_party_id NUMBER) IS
  select from_rel.subject_id
  from HZ_MERGE_PARTY_DETAILS mpd, HZ_MERGE_PARTIES mp
     , HZ_RELATIONSHIPS from_rel, HZ_RELATIONSHIPS to_rel
     , HZ_PARTIES from_pty, HZ_PARTIES to_pty
  where mpd.batch_party_id = mp.batch_party_id
  and mp.batch_id = p_batch_id
  and mpd.entity_name = 'HZ_PARTY_RELATIONSHIPS'
  and mpd.merge_from_entity_id = from_rel.relationship_id
  and mpd.merge_to_entity_id = to_rel.relationship_id
  and from_rel.object_id =
    ( select winner_party_id
      from HZ_DUP_SETS where dup_set_id = p_batch_id )
  and to_rel.object_id =
    ( select winner_party_id
      from HZ_DUP_SETS where dup_set_id = p_batch_id )
  and from_rel.subject_id = from_pty.party_id
  and to_rel.subject_id = l_to_party_id
  and to_rel.subject_id = to_pty.party_id;

  CURSOR get_reln_from_party_mp(l_to_party_id NUMBER) IS
  select from_rel.subject_id
  from HZ_MERGE_PARTY_DETAILS mpd, HZ_MERGE_PARTIES mp
     , HZ_RELATIONSHIPS from_rel, HZ_RELATIONSHIPS to_rel
     , HZ_PARTIES from_pty, HZ_PARTIES to_pty
  where mpd.batch_party_id = mp.batch_party_id
  and mpd.merge_from_entity_id <> mpd.merge_to_entity_id
  and mp.batch_id = p_batch_id
  and mpd.entity_name = 'HZ_PARTY_RELATIONSHIPS'
  and mpd.merge_from_entity_id = from_rel.relationship_id
  and mpd.merge_to_entity_id = to_rel.relationship_id
  and from_rel.object_id in
  ( select dup_party_id
    from HZ_DUP_SET_PARTIES
    where dup_set_id = p_batch_id
    and nvl(merge_flag,'Y') <> 'N' )
  and to_rel.object_id in
  ( select dup_party_id
    from HZ_DUP_SET_PARTIES
    where dup_set_id = p_batch_id
    and nvl(merge_flag,'Y') <> 'N' )
  and from_rel.subject_id = from_pty.party_id
  and to_rel.subject_id = to_pty.party_id
  and to_rel.subject_id = l_to_party_id;

  CURSOR get_master_party is
  select party_name
  from HZ_DUP_SETS a, HZ_PARTIES b
  where a.winner_party_id = b.party_id
  and a.dup_set_id = p_batch_id;

  CURSOR get_cand_party(l_party_id NUMBER) is
  select party_name
  from HZ_PARTIES
  where party_id = l_party_id;

  cursor is_sugg_request_done_csr is
	select count(*)
        from hz_merge_batch
        where batch_id = p_batch_id
        and created_by_module = 'DL_DONESUGG';


  l_from_party_id  NUMBER;
  l_to_party_id    NUMBER;

  l_dup_batch_rec  HZ_DUP_PVT.DUP_BATCH_REC_TYPE;
  l_dup_set_rec    HZ_DUP_PVT.DUP_SET_REC_TYPE;
  l_dup_party_tbl  HZ_DUP_PVT.DUP_PARTY_TBL_TYPE;
  l_dup_batch_id   NUMBER;
  l_dup_set_id     NUMBER;
  l_return_status  VARCHAR2(30);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_set_count      NUMBER;
  l_count          NUMBER;
  l_party_name     VARCHAR2(360);
  l_master_party   VARCHAR2(360);
  l_cand_party     VARCHAR2(360);
  l_set_obj_version_number NUMBER;
  l_merge_batch_id         NUMBER;
  l_request_id number;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF (NVL(FND_PROFILE.VALUE('HZ_DL_CREATE_SUGG_MERGE_REQ'), 'Y') = 'Y') THEN

  open is_sugg_request_done_csr;
  fetch is_sugg_request_done_csr into l_count;
  close is_sugg_request_done_csr;

  if l_count <>0
  then return;
  end if;

  fnd_msg_pub.initialize;

  savepoint create_reln_sysbatch;

  update hz_merge_batch
  set created_by_module = 'DL_DONESUGG'
  where batch_id = p_batch_id;


  OPEN get_master_party;
  FETCH get_master_party into l_master_party;
  CLOSE get_master_party;

  IF(p_merge_type = 'PARTY_MERGE') THEN
    OPEN get_reln_party_mp;
    LOOP
      FETCH get_reln_party_mp INTO l_to_party_id, l_set_count;
      EXIT WHEN get_reln_party_mp%NOTFOUND;

      OPEN get_cand_party(l_to_party_id);
      FETCH get_cand_party INTO l_cand_party;
      CLOSE get_cand_party;

       -- initialize the table in each loop

      IF ( l_dup_party_tbl.COUNT > 0 ) THEN
            l_dup_party_tbl.DELETE ;
      END IF ;

      l_dup_batch_rec.dup_batch_name := 'SUGG: '||l_cand_party||' - '||l_master_party||'('||p_batch_id||')';
      l_dup_batch_rec.match_rule_id := -1;
      l_dup_batch_rec.application_id := 222;
      l_dup_batch_rec.request_type := 'SYSTEM_GENERATED';
      l_dup_batch_id := NULL;
      l_dup_set_rec.winner_party_id := l_to_party_id;
      l_dup_set_rec.status := 'SYSBATCH';
      l_dup_set_rec.assigned_to_user_id := NULL;
      l_dup_set_rec.merge_type := 'PARTY_MERGE';
      l_dup_party_tbl(1).party_id := l_to_party_id;
      l_dup_party_tbl(1).score := -1;
      l_dup_party_tbl(1).merge_flag := NULL;

      l_count := 2;

      OPEN get_reln_from_party_mp(l_to_party_id);
      LOOP
        FETCH get_reln_from_party_mp INTO l_from_party_id;
        EXIT WHEN get_reln_from_party_mp%NOTFOUND;

        l_dup_party_tbl(l_count).party_id := l_from_party_id;
        l_dup_party_tbl(l_count).score := -1;
        l_dup_party_tbl(l_count).merge_flag := 'Y';
        l_count := l_count + 1;

      END LOOP;
      CLOSE get_reln_from_party_mp;

      if l_from_party_id <> l_to_party_id
      then
        HZ_DUP_PVT.create_dup_batch(
         p_dup_batch_rec             => l_dup_batch_rec
        ,p_dup_set_rec               => l_dup_set_rec
        ,p_dup_party_tbl             => l_dup_party_tbl
        ,x_dup_batch_id              => l_dup_batch_id
        ,x_dup_set_id                => l_dup_set_id
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data );
      end if;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
        ROLLBACK to create_reln_sysbatch;
        RETURN;
      END IF;

   	 hz_dup_pvt.submit_dup (
   		p_dup_set_id    => l_dup_set_id
  		,x_request_id    => l_request_id
  		,x_return_status => l_return_status
  		,x_msg_count     => l_msg_count
  		,x_msg_data      => l_msg_data);

    END LOOP;
    CLOSE get_reln_party_mp;
  ELSIF(p_merge_type = 'SAME_PARTY_MERGE') THEN
    OPEN get_reln_party_sp;
    LOOP
      FETCH get_reln_party_sp INTO l_to_party_id, l_set_count;
      EXIT WHEN get_reln_party_sp%NOTFOUND;

      OPEN get_cand_party(l_to_party_id);
      FETCH get_cand_party INTO l_cand_party;
      CLOSE get_cand_party;

      -- initialize the table in each loop

      IF ( l_dup_party_tbl.COUNT > 0 ) THEN
            l_dup_party_tbl.DELETE ;
      END IF ;

      l_dup_batch_rec.dup_batch_name := 'SUGG: '||l_cand_party||' - '||l_master_party||'('||p_batch_id||')';
      l_dup_batch_rec.match_rule_id := -1;
      l_dup_batch_rec.application_id := 222;
      l_dup_batch_rec.request_type := 'SYSTEM_GENERATED';
      l_dup_batch_id := NULL;
      l_dup_set_rec.winner_party_id := l_to_party_id;
      l_dup_set_rec.status := 'SYSBATCH';
      l_dup_set_rec.assigned_to_user_id := NULL;
      l_dup_set_rec.merge_type := 'PARTY_MERGE';
      l_dup_party_tbl(1).party_id := l_to_party_id;
      l_dup_party_tbl(1).score := -1;
      l_dup_party_tbl(1).merge_flag := NULL;

      l_count := 2;

      OPEN get_reln_from_party_sp(l_to_party_id);
      LOOP
        FETCH get_reln_from_party_sp INTO l_from_party_id;
        EXIT WHEN get_reln_from_party_sp%NOTFOUND;

        l_dup_party_tbl(l_count).party_id := l_from_party_id;
        l_dup_party_tbl(l_count).score := -1;
        l_dup_party_tbl(l_count).merge_flag := 'Y';
        l_count := l_count + 1;

      END LOOP;
      CLOSE get_reln_from_party_sp;
      if l_from_party_id <> l_to_party_id
      then
        HZ_DUP_PVT.create_dup_batch(
         p_dup_batch_rec             => l_dup_batch_rec
        ,p_dup_set_rec               => l_dup_set_rec
        ,p_dup_party_tbl             => l_dup_party_tbl
        ,x_dup_batch_id              => l_dup_batch_id
        ,x_dup_set_id                => l_dup_set_id
        ,x_return_status             => x_return_status
        ,x_msg_count                 => x_msg_count
        ,x_msg_data                  => x_msg_data );
      end if;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
        ROLLBACK to create_reln_sysbatch;
        RETURN;
      end if;

      hz_dup_pvt.submit_dup (
   		p_dup_set_id    => l_dup_set_id
  		,x_request_id    => l_request_id
  		,x_return_status => l_return_status
  		,x_msg_count     => l_msg_count
  		,x_msg_data      => l_msg_data);

    END LOOP;
    CLOSE get_reln_party_sp;
  END IF;
end if; -- (NVL(FND_PROFILE.VALUE('HZ_DL_CREATE_SUGG_MERGE_REQ')

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_reln_sysbatch;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_reln_sysbatch;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO create_reln_sysbatch;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

END create_reln_sysbatch;

--
-- PROCEDURE delete_mapping
--
-- DESCRIPTION
--      Remove all profile attributes/address/relationship mapping.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_batch_id          ID of the merge batch
--     p_merge_type        Merge type of the dup set
--
--   OUT:
--     x_return_status       Return status after the call. The status can
--                           be fnd_api.g_ret_sts_success (success),
--                           fnd_api.g_ret_sts_error (error),
--                           fnd_api.g_ret_sts_unexp_error
--                           (unexpected error).
--     x_msg_count           Number of messages in message stack.
--     x_msg_data            Message text if x_msg_count is 1.
--
-- NOTES
--
-- MODIFICATION HISTORY
--
--   10/09/2002    Arnold Ng         o Created.
--
--
PROCEDURE delete_mapping (
   p_batch_id                  IN      NUMBER
  ,p_merge_type                IN      VARCHAR2
  ,x_return_status             OUT NOCOPY     VARCHAR2
  ,x_msg_count                 OUT NOCOPY     NUMBER
  ,x_msg_data                  OUT NOCOPY     VARCHAR2 )
IS

  l_batch_id         NUMBER;
  l_merge_type       VARCHAR2(30);
  l_party_type       VARCHAR2(30);
  l_merge_to         NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.initialize;

  savepoint delete_mapping;

  l_batch_id := p_batch_id;
  l_merge_type := p_merge_type;

  IF(p_merge_type = 'PARTY_MERGE') THEN
    -- remove all attribute mapping
    DELETE FROM HZ_MERGE_ENTITY_ATTRIBUTES
    WHERE merge_batch_id = l_batch_id;

    -- repopulate all attribute default data
    SELECT decode(pty.party_type,'PERSON','HZ_PERSON_PROFILES',
           'ORGANIZATION','HZ_ORGANIZATION_PROFILES',
           'HZ_ORGANIZATION_PROFILES'),
           a.winner_party_id
    INTO l_party_type, l_merge_to
    FROM HZ_DUP_SETS a, HZ_PARTIES pty
    WHERE a.dup_set_id = p_batch_id
    AND a.winner_party_id = pty.party_id;

    HZ_MERGE_ENTITY_ATTRI_PVT.create_merge_attributes(
      p_batch_id, l_merge_to, l_party_type,
      x_return_status, x_msg_count, x_msg_data);

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      ROLLBACK to delete_mapping;
      RETURN;
    END IF;
  END IF;

  -- remove all party sites mapping
  clear_suggested_default (
     p_batch_id        => l_batch_id
    ,p_entity_name     => 'HZ_PARTY_SITES'
    ,p_merge_type      => l_merge_type
    ,x_return_status   => x_return_status
    ,x_msg_count       => x_msg_count
    ,x_msg_data        => x_msg_data );

  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
    ROLLBACK to delete_mapping;
    RETURN;
  END IF;

  -- remove all party relationships mapping
  clear_suggested_default (
     p_batch_id        => l_batch_id
    ,p_entity_name     => 'HZ_PARTY_RELATIONSHIPS'
    ,p_merge_type      => l_merge_type
    ,x_return_status   => x_return_status
    ,x_msg_count       => x_msg_count
    ,x_msg_data        => x_msg_data );

  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
    ROLLBACK to delete_mapping;
    RETURN;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_mapping;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_mapping;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO delete_mapping;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

END delete_mapping;

--
-- PROCEDURE unmap_child_records
--
-- DESCRIPTION
--      Unmap all child entities and make them transferred.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_merge_batch_id    ID of the merge batch
--     p_entity            Name of the entity HZ_PARTY_SITES,
--                         HZ_RELATIONSHIPS etc.
--     p_entity_id         ID of the entity
--     p_merge_type        Merge type of the dup set
--
--   OUT:
--     x_return_status       Return status after the call. The status can
--                           be fnd_api.g_ret_sts_success (success),
--                           fnd_api.g_ret_sts_error (error),
--                           fnd_api.g_ret_sts_unexp_error
--                           (unexpected error).
--     x_msg_count           Number of messages in message stack.
--     x_msg_data            Message text if x_msg_count is 1.
--
-- NOTES
--
-- MODIFICATION HISTORY
--
--   10/09/2002    Tasman Tang       o Created.
--
--

PROCEDURE unmap_child_records(
  p_merge_batch_id        IN NUMBER,
  p_entity                IN VARCHAR2,
  p_entity_id             IN NUMBER,
  p_merge_type            IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2) IS

  l_batch_id    NUMBER;
  l_child_entity_id       NUMBER;
  l_batch_party_id        NUMBER;
  l_obj_ver_number        NUMBER;

CURSOR c_children(cp_merge_batch_id NUMBER, cp_entity VARCHAR2, cp_entity_id NUMBER) IS
  SELECT mpd.merge_from_entity_id, mpd.batch_party_id, mpd.object_version_number
  from hz_merge_parties mp, hz_merge_party_details mpd
  WHERE mp.batch_id=cp_merge_batch_id
  AND mpd.entity_name = p_entity
  AND mp.batch_party_id = mpd.batch_party_id
  AND mpd.merge_from_entity_id <> cp_entity_id
  AND mpd.merge_to_entity_id = cp_entity_id;

BEGIN

  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT unmap_child_records;

  IF    (p_merge_batch_id  is null) OR (p_merge_type IS NULL )
      OR (p_entity is null) OR (p_entity_id IS NULL)     THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_BATCH_PARAM');
     FND_MESSAGE.SET_TOKEN('PARAMETER', 'BATCH_PARTY_ID');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN c_children(p_merge_batch_id, p_entity, p_entity_id);
  FETCH c_children INTO l_child_entity_id, l_batch_party_id, l_obj_ver_number;

  IF c_children%NOTFOUND THEN
    -- No need to unmap children if there is no child
    RETURN;

  ELSE
    LOOP
      IF p_merge_type = 'PARTY_MERGE' THEN
        map_detail_record(
          l_batch_party_id,
          p_entity,
          l_child_entity_id,
          l_child_entity_id,
          l_obj_ver_number,
          x_return_status,
          x_msg_count,
          x_msg_data);
      ELSIF p_merge_type = 'SAME_PARTY_MERGE' THEN
        map_within_party(
          l_batch_party_id,
          p_entity,
          l_child_entity_id,
          null,
          x_return_status,
          x_msg_count,
          x_msg_data);
      END IF;

      FETCH c_children INTO l_child_entity_id, l_batch_party_id, l_obj_ver_number;
      EXIT WHEN c_children%NOTFOUND;
    END LOOP;

  END IF;

   -- standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK to unmap_child_records ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK to unmap_child_records ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK to unmap_child_records;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;


     FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

END unmap_child_records;

function get_party_number(p_party_id in number) return varchar2 is

	cursor get_party_number_csr is
		select party_number
		from hz_parties
		where party_id = p_party_id;
l_party_number varchar2(30);
begin
	open get_party_number_csr;
	fetch get_party_number_csr into l_party_number;
	close get_party_number_csr;
	return l_party_number;
end get_party_number;


-- Check existing overlapped merge batch is coming from FORM UI('F') or Data Librarian UI('D')
function get_merge_batch_data_source(p_merge_batch_id in number) return varchar2 is

	cursor get_form_merge_batch_csr is
	/*	select 'x'
		from hz_merge_parties mp
		where mp.batch_id = p_merge_batch_id
		and not exists ( select 'x'
		from hz_dup_set_parties dsp
		where dsp.dup_set_id = mp.batch_id
		and mp.batch_id = p_merge_batch_id); */
	-- Added new column created_by_module in hz_merge_batch instead of above checking
		select 'x'
		from hz_merge_batch
		where batch_id = p_merge_batch_id
		and nvl(created_by_module,'##') <> 'DL';

l_tmp varchar2(1);
begin
	open get_form_merge_batch_csr;
	fetch get_form_merge_batch_csr into l_tmp;
	if get_form_merge_batch_csr%FOUND
	then
		close get_form_merge_batch_csr;
		return 'F';
	else
		close get_form_merge_batch_csr;
		return 'D';
	end if;
end get_merge_batch_data_source;


-- If it has been called from DL project, pass in p_dup_set_id
-- if it has been called from party merge concurrent, pass in merge_batch_id only
-- and pass in null for p_dup_set_id
-- set p_reject_req_flag = 'N' if call this procedure from DL UI.
procedure validate_overlapping_merge_req(
  p_dup_set_id            IN NUMBER,
  p_merge_batch_id        IN NUMBER,
  p_init_msg_list         IN VARCHAR2,
  p_reject_req_flag       IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2 ) is

	cursor dset_overlap_merged_party_csr is
		select party.party_number,ds.object_version_number
		from hz_parties party, hz_dup_sets ds, hz_dup_set_parties dsp, hz_dup_batch db
		where party.party_id =dsp.dup_party_id
		and db.dup_batch_id = ds.dup_batch_id
		and ds.dup_set_id = dsp.dup_set_id
		and party.status = 'M'
		and ds.dup_set_id = p_dup_set_id;

	cursor dset_overlap_req_party_csr is
		select distinct mp.batch_id,dsp.dup_party_id,ds.object_version_number
		from hz_merge_batch mb, hz_merge_parties mp,
                     hz_dup_sets ds, hz_dup_set_parties dsp, hz_dup_batch db
		where mp.batch_id <> ds.dup_set_id
		and mb.batch_id = mp.batch_id
		and db.dup_batch_id = ds.dup_batch_id
		and ds.dup_set_id = dsp.dup_set_id
		and dsp.dup_party_id = mp.from_party_id -- check only from id overlapping
		and nvl(dsp.merge_flag,'Y') <> 'N'
		and mb.batch_status not in ('COMPLETE','PART_COMPLETE')
		and ds.dup_set_id = p_dup_set_id;

	cursor batch_overlap_merged_party_csr is
		select distinct party.party_number
		from hz_parties party, hz_merge_parties mp, hz_merge_batch mb
		where (party.party_id = mp.from_party_id or party.party_id = mp.to_party_id)
		and party.status = 'M'
		and mp.batch_id = p_merge_batch_id
                and mb.batch_id = mp.batch_id
                and mb.batch_status not in ('COMPLETE','PART_COMPLETE'); --4114041

	/* from DL UI merge_batch_id = dup_set_id */
	cursor batch_dset_obj_ver_num_csr is
	       select object_version_number
	       from hz_dup_sets
	       where dup_set_id = p_merge_batch_id;

		cursor get_merged_rel_party_csr is
		select mp2.batch_party_id
    		from hz_parties p1, hz_merge_parties mp2
    		where p1.party_id = mp2.from_party_id
    		and p1.status = 'M'
    		and mp2.merge_reason_code = 'DUPLICATE_RELN_PARTY'
    		and mp2.batch_id = p_merge_batch_id;

l_batch_id number;
l_party_id number;
l_party_number varchar2(30);
l_object_version_number number;
l_err_reported number := 0;
l_batch_party_id number;

begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
		FND_MSG_PUB.initialize;
        END IF;
    if HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE <> 'BO_API' -- BO API handled overlapping logic already. Skip it here.
    then
	if p_dup_set_id is not null -- data passed in from Data librarian(DL) UI
			            -- or sys dup identification from FORM
	then
		open dset_overlap_merged_party_csr;
		loop
			fetch dset_overlap_merged_party_csr into l_party_number,
								 l_object_version_number;
			exit when dset_overlap_merged_party_csr%NOTFOUND;
			if l_party_number is not null
			then
				x_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('AR', 'HZ_DL_PARTY_ALREADY_MERGED');
				FND_MESSAGE.SET_TOKEN('ID', l_party_number );
				FND_MSG_PUB.ADD;
			end if;
		end loop;
		close dset_overlap_merged_party_csr;

		open dset_overlap_req_party_csr;
		loop
			fetch dset_overlap_req_party_csr into l_batch_id,l_party_id,l_object_version_number;
			exit when dset_overlap_req_party_csr%NOTFOUND;
			if l_batch_id is not null
			then
				l_party_number := get_party_number(l_party_id);
				x_return_status := FND_API.G_RET_STS_ERROR;
				if get_merge_batch_data_source(l_batch_id) = 'D' -- from DL UI
				then
					FND_MESSAGE.SET_NAME('AR', 'HZ_PM_MR_EXIST_DL');
					FND_MESSAGE.SET_TOKEN('ID', l_party_number );
					FND_MESSAGE.SET_TOKEN('REQUEST_ID', l_batch_id);
					FND_MSG_PUB.ADD;
				else   -- from FORM UI
					FND_MESSAGE.SET_NAME('AR', 'HZ_DL_MR_EXIST_FORM_WARNING');
					FND_MESSAGE.SET_TOKEN('ID', l_party_number );
					FND_MESSAGE.SET_TOKEN('BATCH_ID', l_batch_id);
					FND_MSG_PUB.ADD;
				end if;
			end if;
		end loop;
		close dset_overlap_req_party_csr;

		IF (p_reject_req_flag = 'Y' and x_return_status<>FND_API.G_RET_STS_SUCCESS)
                THEN

                        /*
			HZ_DUP_PVT.reject_merge (
			p_dup_set_id	=> p_dup_set_id
			,px_set_obj_version_number  => l_object_version_number
                        ,p_init_msg_list => FND_API.G_FALSE
			,x_return_status => x_return_status
			,x_msg_count	 => x_msg_count
			,x_msg_data      => x_msg_data);
                        */

			-- Update dup set status to 'Error'
			UPDATE HZ_DUP_SETS
			SET STATUS = 'ERROR',
			OBJECT_VERSION_NUMBER = nvl(OBJECT_VERSION_NUMBER,1)+1,
			LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
			LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
			LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY
			WHERE DUP_SET_ID = p_dup_set_id;

		        x_return_status := FND_API.G_RET_STS_ERROR;
		end if;

        	FND_MSG_PUB.Count_And_Get(
        	p_encoded => FND_API.G_FALSE,
        	p_count => x_msg_count,
        	p_data  => x_msg_data);

	elsif p_merge_batch_id is not null -- data passed in from party merge
					   -- concurrent program
        then

			-- bug 5094383: delete merged relationship parties
		open get_merged_rel_party_csr;
		loop
            		fetch get_merged_rel_party_csr into l_batch_party_id;
			exit when get_merged_rel_party_csr%NOTFOUND;

          		if l_batch_party_id is not null
            		then
                		delete from hz_merge_parties where batch_party_id = l_batch_party_id;
				delete from hz_merge_party_details where batch_party_id = l_batch_party_id;

             		end if;
		end loop;
		close get_merged_rel_party_csr;

		open batch_overlap_merged_party_csr;
		loop
			fetch batch_overlap_merged_party_csr into l_party_number;
			exit when batch_overlap_merged_party_csr%NOTFOUND;
			if l_party_number is not null
			then
			        FND_FILE.put_line(fnd_file.log,'The Party with Registry ID ' || l_party_number || ' has already been merged.');

				if l_err_reported = 0 then
  				  x_return_status := FND_API.G_RET_STS_ERROR;
				  FND_MESSAGE.SET_NAME('AR', 'HZ_DL_PARTY_ALREADY_MERGED');
				  FND_MESSAGE.SET_TOKEN('ID', l_party_number );
				  FND_MSG_PUB.ADD;
				  l_err_reported := 1;
				end if;
			end if;
		end loop;
		close batch_overlap_merged_party_csr;

	end if;
     end if; --HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE <> 'BO_API'
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

end validate_overlapping_merge_req;

--private function
function get_addresses(p_to_site_id in number, get_from_addr_flag in varchar2) return varchar2
is
	cursor get_to_addr_csr is
	       select hz_format_pub.format_address(l.location_id,null,null,', ')
	       from hz_party_sites ps, hz_locations l
	       where ps.location_id = l.location_id
	       and ps.party_site_id = p_to_site_id;

	cursor get_from_addr_csr is
	       select hz_format_pub.format_address(l.location_id,null,null,', ')
	       from hz_merge_parties p,
		    hz_merge_party_details pd,
		    hz_party_sites s,
		    hz_locations l,
		    hz_parties hp
	       where p.batch_party_id = pd.batch_party_id
	       and pd.entity_name = 'HZ_PARTY_SITES'
	       and pd.merge_from_entity_id = s.party_site_id
	       and s.location_id = l.location_id
	       and hp.party_id = p.from_party_id
	       and pd.merge_to_entity_id = p_to_site_id;

l_addr varchar2(2000);
l_to_addr varchar2(2000);
l_concat_addr varchar2(2000):='';

begin
	open get_to_addr_csr;
	fetch get_to_addr_csr into l_to_addr;
	close get_to_addr_csr;

	if get_from_addr_flag = 'N'
	then

		return l_to_addr;
	else
		open get_from_addr_csr;
		loop
			fetch get_from_addr_csr into l_addr;
			exit when get_from_addr_csr%NOTFOUND;
			l_concat_addr := l_concat_addr ||'"'||l_addr||'"'||', ';

		end loop;
		close get_from_addr_csr;
		return l_concat_addr||'"'||l_to_addr||'"';
	end if;

end get_addresses;

-- Only called from Data Librarian UI
function is_acct_site_merge_required(p_merge_batch_id in number) return varchar2 is

	 cursor acct_site_merge_required_csr is
	     SELECT 'Y'
             FROM   hz_party_sites ps1,
                    hz_cust_acct_sites_all as1,
		    hz_cust_accounts ca1,
		    hz_merge_parties p1,
	            hz_merge_party_details pd1
             WHERE  p1.batch_id   = p_merge_batch_id
              AND   ps1.party_site_id   = as1.party_site_id
              and   ca1.cust_account_id = as1.cust_account_id
	      and   p1.batch_party_id = pd1.batch_party_id
	      and   pd1.entity_name = 'HZ_PARTY_SITES'
	      and   pd1.merge_from_entity_id = ps1.party_site_id
	      and   pd1.merge_from_entity_id <> pd1.merge_to_entity_id
              AND   exists
                    ( select 1 from hz_party_sites ps2,
                                    hz_cust_acct_sites_all as2,
				    hz_merge_parties p2,
	      			    hz_merge_party_details pd2
                              where p2.batch_id  = p_merge_batch_id
                                and ps2.party_site_id   = as2.party_site_id
                                and as2.cust_account_id = as1.cust_account_id
                                and as2.org_id          = as1.org_id
				and   p2.batch_party_id = pd2.batch_party_id
	      			and   pd2.entity_name = 'HZ_PARTY_SITES'
	      			and   pd2.merge_to_entity_id = ps2.party_site_id
	      			and   pd2.merge_from_entity_id <> pd2.merge_to_entity_id
                                and  rownum = 1);
l_required varchar2(1);
begin
	open acct_site_merge_required_csr;
	fetch acct_site_merge_required_csr into l_required;
	close acct_site_merge_required_csr;
	if l_required = 'Y'
	then return ('Y');
	else return ('N');
	end if;
end;

-- Only called from Data Librarian UI
procedure site_merge_warning(
  p_merge_batch_id        IN NUMBER,
  p_generate_note_flag    IN VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2 ) is


    CURSOR check_site_merge_csr IS
	    SELECT distinct ca1.account_number, pd1.merge_to_entity_id
             FROM   hz_party_sites ps1,
                    hz_cust_acct_sites_all as1,
		    hz_cust_accounts ca1,
		    hz_merge_parties p1,
	            hz_merge_party_details pd1
             WHERE  p1.batch_id   = p_merge_batch_id
              AND   ps1.party_site_id   = as1.party_site_id
              and   ca1.cust_account_id = as1.cust_account_id
	      and   p1.batch_party_id = pd1.batch_party_id
	      and   pd1.entity_name = 'HZ_PARTY_SITES'
	      and   pd1.merge_from_entity_id = ps1.party_site_id
	      and   pd1.merge_from_entity_id <> pd1.merge_to_entity_id
              AND   exists
                    ( select 1 from hz_party_sites ps2,
                                    hz_cust_acct_sites_all as2,
				    hz_merge_parties p2,
	      			    hz_merge_party_details pd2
                              where p2.batch_id  = p_merge_batch_id
                                and ps2.party_site_id   = as2.party_site_id
                                and as2.cust_account_id = as1.cust_account_id
                                and as2.org_id          = as1.org_id
				and   p2.batch_party_id = pd2.batch_party_id
	      			and   pd2.entity_name = 'HZ_PARTY_SITES'
	      			and   pd2.merge_to_entity_id = ps2.party_site_id
	      			and   pd2.merge_from_entity_id <> pd2.merge_to_entity_id
                                and  rownum = 1);

l_from_addr varchar2(2000) :='';
l_from_id number;
l_to_id number;
l_account_number varchar2(30);
l_note_text varchar2(2000);
str varchar2(2000);
l_jtf_note_id number;
l_concat_addr varchar2(2000);
l_to_entity_id number;
l_to_addr varchar2(2000);
l_msg varchar2(2000);
l_messages varchar2(2000) :='';

begin
	FND_MSG_PUB.initialize; -- make sure only show warning messages
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	open check_site_merge_csr;
	loop
	     fetch check_site_merge_csr into l_account_number, l_to_entity_id;
	     exit when check_site_merge_csr%NOTFOUND;
	     if l_account_number is not null
	     then
		if p_generate_note_flag = 'N'
                then
			l_concat_addr := get_addresses(l_to_entity_id,'Y');

			FND_MESSAGE.SET_NAME('AR', 'HZ_DL_ACCTSITEDUP_INFO');
			FND_MESSAGE.SET_TOKEN('ACCTNUM', l_account_number);
			FND_MESSAGE.SET_TOKEN('CONCAT_DUP_ADDR', l_concat_addr);
			FND_MSG_PUB.ADD;

		elsif p_generate_note_flag = 'Y'
		then
			l_to_addr := get_addresses(l_to_entity_id,'N');

			FND_MSG_PUB.initialize;-- only want the current message
			FND_MESSAGE.SET_NAME('AR', 'HZ_DL_ACCTSITEDUP_NOTE');
			FND_MESSAGE.SET_TOKEN('ACCTNUM', l_account_number);
			FND_MESSAGE.SET_TOKEN('MERGETO_ADDR', l_to_addr);
			FND_MSG_PUB.ADD;

			l_note_text := fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);

			str := 'BEGIN '||
			'JTF_NOTES_PUB.Create_note(null,null,1,FND_API.g_false,FND_API.g_true,100,'
			||':x_return_status,:x_msg_count,:x_msg_data,'||'null,'||':p_merge_batch_id,'
			||'''MERGE_DUP_SET'''||','||':l_note_text,'
			||'null,''I'',0,SYSDATE,'||':l_jtf_note_id'||',SYSDATE,0,SYSDATE,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'||'''GENERAL'''||');'||'END;';
			--fnd_file.put_line(fnd_file.log, str);
			EXECUTE IMMEDIATE str USING
			out x_return_status,out x_msg_count, out x_msg_data,p_merge_batch_id,
			l_note_text, out l_jtf_note_id;

		 end if;
	    end if;
       end loop;
       close check_site_merge_csr;

       if p_generate_note_flag = 'N'
       then
		FND_MSG_PUB.Count_And_Get(
        	p_encoded => FND_API.G_FALSE,
        	p_count => x_msg_count,
        	p_data  => x_msg_data);

		if x_msg_count = 1
		then
			l_messages :=  fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
		else
			FOR l_index IN 1..x_msg_count LOOP
			    l_msg := FND_MSG_PUB.Get(
			      p_msg_index   =>  l_index,
			      p_encoded     =>  FND_API.G_FALSE);
			 --l_messages:=l_messages||fnd_global.local_chr(10)||l_msg||fnd_global.local_chr(10);
			l_messages:=l_messages||' <br> '||l_msg||' <br> ';
			END LOOP;
		end if;
		x_msg_data := ' <html> '||l_messages||' </html> ';
		--fnd_file.put_line(fnd_file.log, x_msg_data);
      end if;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

end site_merge_warning;


END HZ_MERGE_DUP_PVT;

/
