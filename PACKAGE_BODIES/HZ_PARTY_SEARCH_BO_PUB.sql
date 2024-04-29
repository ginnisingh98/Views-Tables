--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_SEARCH_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_SEARCH_BO_PUB" AS
/*$Header: ARHDBOSB.pls 120.2 2007/02/23 11:37:58 rarajend ship $ */

  PROCEDURE find_party_bos (
    p_init_msg_list		      IN          VARCHAR2 := fnd_api.g_false,
    p_within_os               IN          VARCHAR2,
    p_rule_id                 IN          NUMBER,
    p_search_attr_obj         IN          HZ_SEARCH_ATTR_OBJ_TBL,
    p_party_status            IN          VARCHAR2,
    p_restrict_sql            IN          VARCHAR2,
    p_match_type              IN          VARCHAR2,
    x_search_results_obj      OUT NOCOPY  HZ_MATCHED_PARTY_OBJ_TBL,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2
  )
    IS
      --l_search_results_obj_tbl  HZ_MATCHED_PARTY_OBJ_TBL;
      l_search_attr_obj         HZ_SEARCH_ATTR_OBJ_TBL;
      l_return_status           VARCHAR2(1);
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2(2000);
      l_search_ctx_id           NUMBER;
      l_num_matches             NUMBER;
      l_count                   NUMBER;
      l_restrict_sql            VARCHAR2(2000);
      l_within_sql              VARCHAR2(2000);
      l_api_name                VARCHAR2(80) := 'FIND_PARTIES';


      -- Cursor to select all the matching parties without 'within' clause
      CURSOR c_matched_party_tbl  (l_search_ctx_id IN NUMBER) IS
        SELECT HZ_MATCHED_PARTY_OBJ (
           hzp.party_id
          ,mpgt.score
          ,hzp.party_number
          ,hzp.party_name
          ,hzp.party_type
          ,hzp.address1
          ,hzp.address2
          ,hzp.address3
          ,hzp.address4
          ,hzp.city
          ,hzp.state
          ,hzp.country
          ,hzp.primary_phone_country_code
          ,hzp.primary_phone_area_code
          ,hzp.primary_phone_number
          ,hzp.email_address
          ,CAST (MULTISET (
		     SELECT HZ_ORIG_SYS_REF_OBJ(
               NULL, --P_ACTION_TYPE,
                 ORIG_SYSTEM_REF_ID,
                 ORIG_SYSTEM,
                 ORIG_SYSTEM_REFERENCE,
                 HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(OWNER_TABLE_NAME,OWNER_TABLE_ID),
                 OWNER_TABLE_ID,
                 STATUS,
                 REASON_CODE,
                 OLD_ORIG_SYSTEM_REFERENCE,
                 START_DATE_ACTIVE,
                 END_DATE_ACTIVE,
                 PROGRAM_UPDATE_DATE,
                 CREATED_BY_MODULE,
                 HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
                 CREATION_DATE,
                 LAST_UPDATE_DATE,
                 HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 ATTRIBUTE16,
                 ATTRIBUTE17,
                 ATTRIBUTE18,
                 ATTRIBUTE19,
                 ATTRIBUTE20)
               FROM  HZ_ORIG_SYS_REFERENCES OSR
               WHERE OSR.OWNER_TABLE_ID = HZP.PARTY_ID
               AND OWNER_TABLE_NAME = 'HZ_PARTIES'
               AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL)
        ) AS HZ_MATCHED_PARTY_OBJ_TBL
        FROM hz_matched_parties_gt mpgt, hz_parties hzp
        WHERE mpgt.party_id = hzp.party_id
        AND   mpgt.search_context_id = l_search_ctx_id;

      -- Cursor to select all the matching parties with 'within' clause
      CURSOR c_matched_party_orig_tbl
            (l_search_ctx_id IN NUMBER, l_within_os IN VARCHAR2) IS
        SELECT HZ_MATCHED_PARTY_OBJ (
           hzp.party_id
          ,mpgt.score
          ,hzp.party_number
          ,hzp.party_name
          ,hzp.party_type
          ,hzp.address1
          ,hzp.address2
          ,hzp.address3
          ,hzp.address4
          ,hzp.city
          ,hzp.state
          ,hzp.country
          ,hzp.primary_phone_country_code
          ,hzp.primary_phone_area_code
          ,hzp.primary_phone_number
          ,hzp.email_address
          ,CAST (MULTISET (
		     SELECT HZ_ORIG_SYS_REF_OBJ(
               NULL, --P_ACTION_TYPE,
                 ORIG_SYSTEM_REF_ID,
                 ORIG_SYSTEM,
                 ORIG_SYSTEM_REFERENCE,
                 HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(OWNER_TABLE_NAME,OWNER_TABLE_ID),
                 OWNER_TABLE_ID,
                 STATUS,
                 REASON_CODE,
                 OLD_ORIG_SYSTEM_REFERENCE,
                 START_DATE_ACTIVE,
                 END_DATE_ACTIVE,
                 PROGRAM_UPDATE_DATE,
                 CREATED_BY_MODULE,
                 HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
                 CREATION_DATE,
                 LAST_UPDATE_DATE,
                 HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
                 ATTRIBUTE_CATEGORY,
                 ATTRIBUTE1,
                 ATTRIBUTE2,
                 ATTRIBUTE3,
                 ATTRIBUTE4,
                 ATTRIBUTE5,
                 ATTRIBUTE6,
                 ATTRIBUTE7,
                 ATTRIBUTE8,
                 ATTRIBUTE9,
                 ATTRIBUTE10,
                 ATTRIBUTE11,
                 ATTRIBUTE12,
                 ATTRIBUTE13,
                 ATTRIBUTE14,
                 ATTRIBUTE15,
                 ATTRIBUTE16,
                 ATTRIBUTE17,
                 ATTRIBUTE18,
                 ATTRIBUTE19,
                 ATTRIBUTE20)
               FROM  HZ_ORIG_SYS_REFERENCES OSR
               WHERE OSR.OWNER_TABLE_ID = HZP.PARTY_ID
               AND OWNER_TABLE_NAME = 'HZ_PARTIES'
               AND OSR.ORIG_SYSTEM = l_within_os
               AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL)
        ) AS HZ_MATCHED_PARTY_OBJ_TBL
        FROM hz_matched_parties_gt mpgt, hz_parties hzp
        WHERE mpgt.party_id = hzp.party_id
        AND   mpgt.search_context_id = l_search_ctx_id;

   BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

     -- Check if the 'p_within_os' parameter passed has a value
     IF p_within_os IS NOT NULL THEN
       l_within_sql := ' EXISTS (SELECT 1 FROM hz_orig_sys_references o
                                  WHERE o.orig_system      = '''||p_within_os||'''
                                  AND   o.owner_table_name = ''HZ_PARTIES''
                                  AND   o.owner_table_id   = stage.party_id)';

       -- If restrict sql has a value
       IF p_restrict_sql IS NOT NULL THEN
         -- Concatenate the passed in restrict sql with the with clause
         l_restrict_sql := p_restrict_sql || ' AND ' ||l_within_sql;
       ELSE
         -- Restrict sql is just the within clause
         l_restrict_sql := l_within_sql;
       END IF;

     ELSE -- p_within_os is passed as null
       l_restrict_sql := p_restrict_sql;
     END IF;

     -- Get the count of passed in search attributes
     l_count := p_search_attr_obj.COUNT;

       -- Initialze a new search object table with 20 null values
         l_search_attr_obj := HZ_SEARCH_ATTR_OBJ_TBL();
       FOR I IN 1..20 LOOP
         l_search_attr_obj.extend;
         l_search_attr_obj(i) := HZ_SEARCH_PARTY_OBJ(NULL,NULL);
       END LOOP;

       -- Loop through the count of search attributes passed in
       -- and populate the new search object table created.
       FOR I IN 1..l_count LOOP
         -- If the count of passed in attributes is more than 20
         -- exit and ignore the rest.
         EXIT WHEN I >20;
         l_search_attr_obj(i).ATTRIBUTE_NAME := p_search_attr_obj(i).ATTRIBUTE_NAME;
         l_search_attr_obj(i).ATTRIBUTE_VALUE := p_search_attr_obj(i).ATTRIBUTE_VALUE;
         -- IF one of the attribute name is Party Type and attribute value
         -- is Person, then we need to populate and pass 'FIND_PERSONS' API.
         IF l_search_attr_obj(i).ATTRIBUTE_NAME = 'PARTY.PARTY_TYPE' AND
            l_search_attr_obj(i).ATTRIBUTE_VALUE = 'PERSON' THEN
            l_api_name := 'FIND_PERSONS';
         END IF;
       END LOOP;

     -- Call the Party Search Main API.
     HZ_PARTY_SEARCH.call_api_dynamic_names (
      p_init_msg_list           => p_init_msg_list,
      p_rule_id                 => p_rule_id,
      p_attrib_name1            => l_search_attr_obj(1).attribute_name,
      p_attrib_name2            => l_search_attr_obj(2).attribute_name,
      p_attrib_name3            => l_search_attr_obj(3).attribute_name,
      p_attrib_name4            => l_search_attr_obj(4).attribute_name,
      p_attrib_name5            => l_search_attr_obj(5).attribute_name,
      p_attrib_name6            => l_search_attr_obj(6).attribute_name,
      p_attrib_name7            => l_search_attr_obj(7).attribute_name,
      p_attrib_name8            => l_search_attr_obj(8).attribute_name,
      p_attrib_name9            => l_search_attr_obj(9).attribute_name,
      p_attrib_name10           => l_search_attr_obj(10).attribute_name,
      p_attrib_name11           => l_search_attr_obj(11).attribute_name,
      p_attrib_name12           => l_search_attr_obj(12).attribute_name,
      p_attrib_name13           => l_search_attr_obj(13).attribute_name,
      p_attrib_name14           => l_search_attr_obj(14).attribute_name,
      p_attrib_name15           => l_search_attr_obj(15).attribute_name,
      p_attrib_name16           => l_search_attr_obj(16).attribute_name,
      p_attrib_name17           => l_search_attr_obj(17).attribute_name,
      p_attrib_name18           => l_search_attr_obj(18).attribute_name,
      p_attrib_name19           => l_search_attr_obj(19).attribute_name,
      p_attrib_name20           => l_search_attr_obj(20).attribute_name,
      p_attrib_val1             => l_search_attr_obj(1).attribute_value,
      p_attrib_val2             => l_search_attr_obj(2).attribute_value,
      p_attrib_val3             => l_search_attr_obj(3).attribute_value,
      p_attrib_val4             => l_search_attr_obj(4).attribute_value,
      p_attrib_val5             => l_search_attr_obj(5).attribute_value,
      p_attrib_val6             => l_search_attr_obj(6).attribute_value,
      p_attrib_val7             => l_search_attr_obj(7).attribute_value,
      p_attrib_val8             => l_search_attr_obj(8).attribute_value,
      p_attrib_val9             => l_search_attr_obj(9).attribute_value,
      p_attrib_val10            => l_search_attr_obj(10).attribute_value,
      p_attrib_val11            => l_search_attr_obj(11).attribute_value,
      p_attrib_val12            => l_search_attr_obj(12).attribute_value,
      p_attrib_val13            => l_search_attr_obj(13).attribute_value,
      p_attrib_val14            => l_search_attr_obj(14).attribute_value,
      p_attrib_val15            => l_search_attr_obj(15).attribute_value,
      p_attrib_val16            => l_search_attr_obj(16).attribute_value,
      p_attrib_val17            => l_search_attr_obj(17).attribute_value,
      p_attrib_val18            => l_search_attr_obj(18).attribute_value,
      p_attrib_val19            => l_search_attr_obj(19).attribute_value,
      p_attrib_val20            => l_search_attr_obj(20).attribute_value,
      p_restrict_sql            => l_restrict_sql,
      p_api_name                => l_api_name,
      p_match_type              => p_match_type,
      p_party_id                => NULL,
      p_search_merged           => p_party_status,
      x_search_ctx_id           => l_search_ctx_id,
      x_num_matches             => l_num_matches,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data
    );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      RAISE FND_API.G_EXC_ERROR;
    -- IF this API returns successfully then populate the results
    -- into the output object table.
    ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

      -- check if p_within_os parameter has a value
      IF p_within_os IS NULL THEN

        OPEN c_matched_party_tbl(l_search_ctx_id);
        -- Populate the l_search_results_obj_tbl table without 'within' clause
        FETCH c_matched_party_tbl BULK COLLECT INTO x_search_results_obj;
        CLOSE c_matched_party_tbl;

      ELSIF p_within_os IS NOT NULL THEN

        OPEN c_matched_party_orig_tbl(l_search_ctx_id, p_within_os);
        -- Populate the l_search_results_obj_tbl table with 'within' clause
        FETCH c_matched_party_orig_tbl BULK COLLECT INTO x_search_results_obj;
        CLOSE c_matched_party_orig_tbl;

      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   END find_party_bos;

END HZ_PARTY_SEARCH_BO_PUB;

/
