--------------------------------------------------------
--  DDL for Package Body HZ_AIA_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_AIA_CUSTOM_PKG" AS
/* $Header: ARHAIACB.pls 120.0.12010000.3 2009/08/06 03:24:42 vsegu ship $ */
  PROCEDURE remove_gmiss(
    px_org_cust  IN OUT NOCOPY  HZ_ORG_CUST_BO);

  PROCEDURE remove_gmiss(
    px_org_cust   IN OUT NOCOPY  HZ_ORG_CUST_BO) IS
  BEGIN
    IF(px_org_cust.organization_obj.duns_number_c = FND_API.G_MISS_CHAR) THEN
      px_org_cust.organization_obj.duns_number_c := NULL;
    END IF;
    IF(px_org_cust.organization_obj.contact_objs IS NOT NULL AND
      px_org_cust.organization_obj.contact_objs.COUNT > 0) THEN
      FOR i IN 1..px_org_cust.organization_obj.contact_objs.COUNT LOOP
        IF(px_org_cust.organization_obj.contact_objs(i).job_title = FND_API.G_MISS_CHAR) THEN
          px_org_cust.organization_obj.contact_objs(i).job_title := null;
        END IF;
        -- clear g_miss_char in person profile object
        IF(px_org_cust.organization_obj.contact_objs(i).person_profile_obj IS NOT NULL) THEN
          IF(px_org_cust.organization_obj.contact_objs(i).person_profile_obj.person_pre_name_adjunct = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.contact_objs(i).person_profile_obj.person_pre_name_adjunct:= null;
          END IF;
          IF(px_org_cust.organization_obj.contact_objs(i).person_profile_obj.person_middle_name = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.contact_objs(i).person_profile_obj.person_middle_name := null;
          END IF;
          IF(px_org_cust.organization_obj.contact_objs(i).person_profile_obj.person_title = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.contact_objs(i).person_profile_obj.person_title := null;
          END IF;
          IF(px_org_cust.organization_obj.contact_objs(i).person_profile_obj.known_as = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.contact_objs(i).person_profile_obj.known_as := null;
          END IF;
          IF(px_org_cust.organization_obj.contact_objs(i).person_profile_obj.gender = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.contact_objs(i).person_profile_obj.gender := null;
          END IF;
        END IF;
        -- clear g_miss_char in contact's email
        IF(px_org_cust.organization_obj.contact_objs(i).email_objs IS NOT NULL AND
          px_org_cust.organization_obj.contact_objs(i).email_objs.COUNT > 0) THEN
          FOR j IN 1..px_org_cust.organization_obj.contact_objs(i).email_objs.COUNT LOOP
            IF(px_org_cust.organization_obj.contact_objs(i).email_objs(j).email_address = FND_API.G_MISS_CHAR) THEN
              px_org_cust.organization_obj.contact_objs(i).email_objs(j).email_address := NULL;
            END IF;
          END LOOP;
        END IF;
        -- clear g_miss_char in contact's web
        IF(px_org_cust.organization_obj.contact_objs(i).web_objs IS NOT NULL AND
          px_org_cust.organization_obj.contact_objs(i).web_objs.COUNT > 0) THEN
          FOR j IN 1..px_org_cust.organization_obj.contact_objs(i).web_objs.COUNT LOOP
            IF(px_org_cust.organization_obj.contact_objs(i).web_objs(j).url = FND_API.G_MISS_CHAR) THEN
              px_org_cust.organization_obj.contact_objs(i).web_objs(j).url := NULL;
            END IF;
          END LOOP;
        END IF;
      END LOOP;
    END IF;
    IF(px_org_cust.organization_obj.party_site_objs IS NOT NULL AND
      px_org_cust.organization_obj.party_site_objs.COUNT > 0) THEN
      FOR i IN 1..px_org_cust.organization_obj.party_site_objs.COUNT LOOP
        IF(px_org_cust.organization_obj.party_site_objs(i).location_obj IS NOT NULL) THEN
          IF(px_org_cust.organization_obj.party_site_objs(i).location_obj.address2 = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.party_site_objs(i).location_obj.address2 := NULL;
          END IF;
          IF(px_org_cust.organization_obj.party_site_objs(i).location_obj.address3 = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.party_site_objs(i).location_obj.address3 := NULL;
          END IF;
          IF(px_org_cust.organization_obj.party_site_objs(i).location_obj.address4 = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.party_site_objs(i).location_obj.address4 := NULL;
          END IF;
          IF(px_org_cust.organization_obj.party_site_objs(i).location_obj.city = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.party_site_objs(i).location_obj.city := NULL;
          END IF;
          IF(px_org_cust.organization_obj.party_site_objs(i).location_obj.county = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.party_site_objs(i).location_obj.county := NULL;
          END IF;
          IF(px_org_cust.organization_obj.party_site_objs(i).location_obj.postal_code = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.party_site_objs(i).location_obj.postal_code := NULL;
          END IF;
          IF(px_org_cust.organization_obj.party_site_objs(i).location_obj.state = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.party_site_objs(i).location_obj.state := NULL;
          END IF;
          IF(px_org_cust.organization_obj.party_site_objs(i).location_obj.province = FND_API.G_MISS_CHAR) THEN
            px_org_cust.organization_obj.party_site_objs(i).location_obj.province := NULL;
          END IF;
        END IF;
      END LOOP;
    END IF;
    IF(px_org_cust.organization_obj.email_objs IS NOT NULL AND
      px_org_cust.organization_obj.email_objs.COUNT > 0) THEN
      FOR i IN 1..px_org_cust.organization_obj.email_objs.COUNT LOOP
        IF(px_org_cust.organization_obj.email_objs(i).email_address = FND_API.G_MISS_CHAR) THEN
          px_org_cust.organization_obj.email_objs(i).email_address := NULL;
        END IF;
      END LOOP;
    END IF;
    IF(px_org_cust.organization_obj.web_objs IS NOT NULL AND
      px_org_cust.organization_obj.web_objs.COUNT > 0) THEN
      FOR i IN 1..px_org_cust.organization_obj.web_objs.COUNT LOOP
        IF(px_org_cust.organization_obj.web_objs(i).url = FND_API.G_MISS_CHAR) THEN
          px_org_cust.organization_obj.web_objs(i).url := NULL;
        END IF;
      END LOOP;
    END IF;
    IF(px_org_cust.organization_obj.duns_number_c = FND_API.G_MISS_CHAR) THEN
      px_org_cust.organization_obj.duns_number_c := NULL;
    END IF;
  END remove_gmiss;

  PROCEDURE log(
    message      IN      VARCHAR2,
    newline      IN      BOOLEAN DEFAULT TRUE);

  PROCEDURE log(
    message      IN      VARCHAR2,
    newline      IN      BOOLEAN DEFAULT TRUE) IS
  BEGIN
    IF message = 'NEWLINE' THEN
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
    ELSIF (newline) THEN
      FND_FILE.put_line(fnd_file.log,message);
    ELSE
      FND_FILE.put_line(fnd_file.log,message);
    END IF;
  END log;

  PROCEDURE get_acct_merge_obj(
    p_customer_merge_header_id        IN NUMBER,
    x_account_merge_obj               OUT NOCOPY CRMINTEG_HZ_MERGE_OBJ
  ) IS
    CURSOR account_merge_details(l_customer_merge_header_id NUMBER) IS
    SELECT CRMINTEG_HZ_MERGE_OBJ(
           decode(mh.customer_type, 'CUSTOMER_ORG', 'ORGANIZATION', 'CUSTOMER_PERSON', 'PERSON'),-- party_type
           mh.duplicate_id, -- from cust_acct_id
           ca.party_id,     -- from party_id
           null,            -- from common_obj_id
           mh.customer_id,  -- to cust_acct_id
           ca2.party_id,    -- to party_id
           null,            -- to common_obj_id
           'N',             -- keep account flag
           CAST(MULTISET(
             SELECT CRMINTEG_HZ_MRGDTIL_OBJ(
               'ADDRESS',
               'N',
               rm.duplicate_address_id,        -- from cust_acct_site_id
               cas.party_site_id,              -- from party_site_id
               null,                           -- from common_obj_id
               rm.customer_address_id,         -- to cust_acct_site_id
               cas2.party_site_id,             -- to party_site_id
               null )                          -- to common_obj_id
             from RA_CUSTOMER_MERGES rm, HZ_CUST_ACCT_SITES_ALL cas, HZ_CUST_ACCT_SITES_ALL cas2
             where rm.customer_merge_header_id = p_customer_merge_header_id
             and rm.duplicate_address_id = cas.cust_acct_site_id(+)
             and rm.customer_address_id = cas2.cust_acct_site_id(+)
             group by rm.duplicate_address_id, rm.customer_address_id,
                      cas.party_site_id, cas2.party_site_id
             ) AS CRMINTEG_HZ_MRGDTIL_OBJ_TBL ),
           CAST(MULTISET(
             SELECT CRMINTEG_HZ_MRGDTIL_OBJ(
               'CONTACT',
               'N',
               carm.cust_account_role_id,      -- from cust_acct_role_id
               ocm.org_contact_id,             -- from org_contact_id
               null,                           -- from common_obj_id
               car.cust_account_role_id,       -- to cust_acct_role_id
               oc.org_contact_id,              -- to org_contact_id
               null )                          -- to common_obj_id
             from RA_CUSTOMER_MERGES rm, HZ_CUST_ACCOUNT_ROLES_M carm, HZ_CUST_ACCOUNT_ROLES car, HZ_RELATIONSHIPS relm, HZ_RELATIONSHIPS rel, HZ_ORG_CONTACTS ocm, HZ_ORG_CONTACTS oc
             where rm.customer_merge_header_id = p_customer_merge_header_id
             and rm.customer_merge_header_id = carm.customer_merge_header_id(+)
             and carm.party_id = relm.party_id(+)
             and relm.relationship_id = ocm.party_relationship_id(+)
             and carm.cust_account_role_id = car.cust_account_role_id(+)
             and car.party_id = rel.party_id(+)
             and rel.relationship_id = oc.party_relationship_id(+)
             group by carm.cust_account_role_id, car.cust_account_role_id,
                      ocm.org_contact_id, oc.org_contact_id
             ) AS CRMINTEG_HZ_MRGDTIL_OBJ_TBL ))
    from RA_CUSTOMER_MERGE_HEADERS mh, HZ_CUST_ACCOUNTS ca, HZ_CUST_ACCOUNTS ca2
    where mh.customer_merge_header_id = l_customer_merge_header_id
    and mh.process_flag = 'Y'
    and mh.duplicate_id = ca.cust_account_id(+)
    and mh.customer_id = ca2.cust_account_id;

    CURSOR other_ou(l_ca_id NUMBER, l_cas_id NUMBER, l_ps_id NUMBER) IS
    SELECT 'Y'
    FROM HZ_CUST_ACCT_SITES_ALL
    WHERE cust_account_id = l_ca_id
    AND cust_acct_site_id <> l_cas_id
    AND party_site_id = l_ps_id
    AND rownum = 1;

    CURSOR is_acct_exist(l_cust_acct_id NUMBER) IS
    SELECT decode(status, 'A', 'Y', 'N')
    FROM HZ_CUST_ACCOUNTS
    WHERE cust_account_id = l_cust_acct_id;

    CURSOR get_deleted_acct_pid(l_cmhdr_id NUMBER, l_cust_acct_id NUMBER) IS
    SELECT party_id
    FROM HZ_CUST_ACCOUNTS_M
    WHERE cust_account_id = l_cust_acct_id
    AND customer_merge_header_id = l_cmhdr_id
    AND rownum = 1;

    CURSOR get_deleted_cs_psid(l_cmhdr_id NUMBER, l_cust_acct_site_id NUMBER) IS
    SELECT party_site_id
    FROM HZ_CUST_ACCT_SITES_ALL_M
    WHERE cust_acct_site_id = l_cust_acct_site_id
    AND customer_merge_header_id = l_cmhdr_id
    AND rownum = 1;

    l_debug_prefix         VARCHAR2(30);
  BEGIN
    OPEN account_merge_details(p_customer_merge_header_id);
    FETCH account_merge_details INTO x_account_merge_obj;
    CLOSE account_merge_details;

    -- set keep account flag to 'Y'
    -- case 1
    -- if same from and to account, then the event is merge address
    -- case 2
    -- if from party_id is null, then the account merge has deleted the from account already
    -- if an account is deleted, then it means only 1 OU is associated with its acct site
    -- therefore, this account can be removed
    -- otherwise, keep the account
    IF(x_account_merge_obj.from_cust_acct_id = x_account_merge_obj.to_cust_acct_id) THEN
      x_account_merge_obj.keep_account_flag := 'Y';
    ELSIF(x_account_merge_obj.from_party_id IS NULL) THEN
      x_account_merge_obj.keep_account_flag := 'N';
      -- get deleted account party_id
      OPEN get_deleted_acct_pid(p_customer_merge_header_id, x_account_merge_obj.from_cust_acct_id);
      FETCh get_deleted_acct_pid INTO x_account_merge_obj.from_party_id;
      CLOSE get_deleted_acct_pid;
    ELSIF(x_account_merge_obj.from_party_id IS NOT NULL) THEN
      OPEN is_acct_exist(x_account_merge_obj.from_cust_acct_id);
      FETCH is_acct_exist INTO x_account_merge_obj.keep_account_flag;
      CLOSE is_acct_exist;
    END IF;

    -- get missing party_site_id
    IF(x_account_merge_obj.merge_address_objs IS NOT NULL and x_account_merge_obj.merge_address_objs.COUNT > 0) THEN
      FOR k IN 1..x_account_merge_obj.merge_address_objs.COUNT LOOP
        IF(x_account_merge_obj.merge_address_objs(k).from_party_object_id IS NULL) THEN
          OPEN get_deleted_cs_psid(p_customer_merge_header_id, x_account_merge_obj.merge_address_objs(k).from_acct_object_id);
          FETCH get_deleted_cs_psid INTO x_account_merge_obj.merge_address_objs(k).from_party_object_id;
          CLOSE get_deleted_cs_psid;
        END IF;
      END LOOP;
    END IF;

    -- if more than 1 org_id associated with cust acct site of the same party site
    -- set keep_xref_flag for acct site
    IF(x_account_merge_obj.merge_address_objs IS NOT NULL and
       x_account_merge_obj.merge_address_objs.COUNT > 0) THEN
      FOR i IN 1..x_account_merge_obj.merge_address_objs.COUNT LOOP
        OPEN other_ou(x_account_merge_obj.from_cust_acct_id,
                      x_account_merge_obj.merge_address_objs(i).from_acct_object_id,
                      x_account_merge_obj.merge_address_objs(i).from_party_object_id);
        FETCH other_ou INTO x_account_merge_obj.merge_address_objs(i).keep_xref_flag;
        CLOSE other_ou;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_acct_merge_obj(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_acct_merge_obj(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_acct_merge_obj(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END get_acct_merge_obj;

  PROCEDURE get_related_org_cust_objs(
    p_batch_id                IN NUMBER,
    p_merge_to_party_id       IN NUMBER,
    x_org_cust_objs           OUT NOCOPY    HZ_ORG_CUST_BO_TBL
  ) IS
    CURSOR get_related_org_cust(l_batch_id NUMBER) IS
      SELECT distinct cr.cust_account_id, r2.object_id
      from HZ_MERGE_BATCH mb, HZ_MERGE_PARTIES mp, HZ_MERGE_PARTY_HISTORY mph,
           HZ_MERGE_DICTIONARY md, HZ_CUST_ACCOUNT_ROLES cr, HZ_RELATIONSHIPS r, HZ_ORG_CONTACTS oc,
           HZ_RELATIONSHIPS r2, HZ_ORG_CONTACTS oc2
      where mb.batch_id = l_batch_id
      and mb.batch_id = mp.batch_id
      and mp.merge_reason_code = 'DUPLICATE_RELN_PARTY'
      and mp.batch_party_id = mph.batch_party_id
      and mph.merge_dict_id = md.merge_dict_id
      and cr.cust_account_role_id = mph.from_entity_id
      and r.party_id = mp.from_party_id
      and r.relationship_id = oc.party_relationship_id
      and r.subject_Type = 'PERSON' and r.object_type = 'ORGANIZATION'
      and r2.party_id = mp.to_party_id
      and r2.relationship_id = oc2.party_relationship_id
      and r2.subject_Type = 'PERSON' and r2.object_type = 'ORGANIZATION'
      and md.entity_name = 'HZ_CUST_ACCOUNT_ROLES';

    l_ca_id                NUMBER;
    l_org_id               NUMBER;
    i                      NUMBER;
    l_return_status        VARCHAR2(30);
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    l_debug_prefix         VARCHAR2(30);
  BEGIN
    x_org_cust_objs := HZ_ORG_CUST_BO_TBL();
    i := 1;
    OPEN get_related_org_cust(p_batch_id);
    LOOP
      FETCH get_related_org_cust INTO l_ca_id, l_org_id;
      EXIT WHEN get_related_org_cust%NOTFOUND;

      x_org_cust_objs.EXTEND;
      x_org_cust_objs(i) := HZ_ORG_CUST_BO(null, null, null);

      HZ_EXTRACT_ORGANIZATION_BO_PVT.get_organization_bo(
        p_init_msg_list   => fnd_api.g_false,
        p_organization_id => l_org_id,
        p_action_type	  => null,
        x_organization_obj => x_org_cust_objs(i).organization_obj,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      HZ_EXTRACT_CUST_ACCT_BO_PVT.get_cust_acct_bos(
        p_init_msg_list    => fnd_api.g_false,
        p_parent_id        => l_org_id,
        p_cust_acct_id     => l_ca_id,
        p_action_type	   => null,
        x_cust_acct_objs   => x_org_cust_objs(i).account_objs,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      i := i + 1;
    END LOOP;
    CLOSE get_related_org_cust;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_related_org_cust_objs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_related_org_cust_objs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_related_org_cust_objs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END get_related_org_cust_objs;

  PROCEDURE get_party_merge_objs(
    p_batch_id                IN NUMBER,
    p_merge_to_party_id       IN NUMBER,
    x_party_merge_objs        OUT NOCOPY CRMINTEG_HZ_MERGE_OBJ_TBL
  ) IS
    CURSOR get_merge_type IS
    SELECT party_type
    FROM HZ_PARTIES
    WHERE party_id = p_merge_to_party_id;

    CURSOR get_merge_parties(l_batch_id NUMBER) IS
    SELECT p.party_type, from_parent_entity_id, from_entity_id, to_parent_entity_id
    from HZ_MERGE_BATCH mb, HZ_MERGE_PARTIES mp, HZ_MERGE_PARTY_HISTORY mph, HZ_MERGE_DICTIONARY md, HZ_PARTIES p
    where mb.batch_id = l_batch_id
    and mb.batch_id = mp.batch_id
    and mp.batch_party_id = mph.batch_party_id
    and mph.merge_dict_id = md.merge_dict_id
    and p.party_id = mph.to_parent_entity_id
    and md.entity_name = 'HZ_CUST_ACCOUNTS';

    CURSOR get_merge_detail(l_batch_id NUMBER, l_party_type VARCHAR2, l_fpid NUMBER, l_fcaid NUMBER, l_tpid NUMBER) IS
    SELECT CRMINTEG_HZ_MERGE_OBJ(
           l_party_type,   -- party_type
           l_fcaid,        -- from cust_acct_id
           l_fpid,         -- from party_id
           null,           -- from common_obj_id
           l_fcaid,        -- to cust_acct_id
           l_tpid,         -- to party_id
           null,           -- to common_obj_id
           'N',
           CAST(MULTISET(
             SELECT CRMINTEG_HZ_MRGDTIL_OBJ(
               'ADDRESS',
               'N',
               cs.cust_account_id,             -- from cust_acct_id
               mph.from_parent_entity_id,      -- from party_site_id
               null,                           -- from common_obj_id
               cs.cust_account_id,             -- to cust_acct_id
               mph.to_parent_entity_id,        -- to party_site_id
               null )                          -- to common_obj_id
             from HZ_MERGE_BATCH mb, HZ_MERGE_PARTIES mp, HZ_MERGE_PARTY_HISTORY mph,
                  HZ_MERGE_DICTIONARY md, HZ_CUST_ACCT_SITES_ALL cs
             where mb.batch_id = l_batch_id
             and mb.batch_id = mp.batch_id
             and mp.batch_party_id = mph.batch_party_id
             and mph.merge_dict_id = md.merge_dict_id
             and cs.cust_acct_site_id = mph.from_entity_id
             and cs.cust_account_id = l_fcaid
             and md.entity_name = 'HZ_CUST_ACCT_SITES_ALL'
             ) AS CRMINTEG_HZ_MRGDTIL_OBJ_TBL ),
           CAST(MULTISET(
             SELECT CRMINTEG_HZ_MRGDTIL_OBJ(
               'CONTACT',
               'N',
               cr.cust_account_id,             -- from cust_acct_site_id
               oc.org_contact_id,              -- from party_site_id
               null,                           -- from common_obj_id
               cr.cust_account_id,             -- to cust_acct_site_id
               oc2.org_contact_id,             -- to party_site_id
               null )                          -- to common_obj_id
             from HZ_MERGE_BATCH mb, HZ_MERGE_PARTIES mp, HZ_MERGE_PARTY_HISTORY mph,
                  HZ_MERGE_DICTIONARY md, HZ_CUST_ACCOUNT_ROLES cr, HZ_RELATIONSHIPS r, HZ_ORG_CONTACTS oc,
                  HZ_RELATIONSHIPS r2, HZ_ORG_CONTACTS oc2
             where mb.batch_id = l_batch_id
             and mb.batch_id = mp.batch_id
             and mp.batch_party_id = mph.batch_party_id
             and mph.merge_dict_id = md.merge_dict_id
             and cr.cust_account_role_id = mph.from_entity_id
             and cr.cust_account_id = l_fcaid
             and r.party_id = mph.from_parent_entity_id
             and r.relationship_id = oc.party_relationship_id
             and r.subject_Type = 'PERSON' and r.object_type = 'ORGANIZATION'
             and r2.party_id = mph.to_parent_entity_id
             and r2.relationship_id = oc2.party_relationship_id
             and r2.subject_Type = 'PERSON' and r2.object_type = 'ORGANIZATION'
             and md.entity_name = 'HZ_CUST_ACCOUNT_ROLES'
             ) AS CRMINTEG_HZ_MRGDTIL_OBJ_TBL ))
    from dual;

    CURSOR get_person_merge_detail(l_batch_id NUMBER, l_party_type VARCHAR2) IS
    SELECT CRMINTEG_HZ_MERGE_OBJ(
           l_party_type,   -- party_type
           null,           -- from cust_acct_id
           null,           -- from party_id
           null,           -- from common_obj_id
           null,           -- to cust_acct_id
           null,           -- to party_id
           null,           -- to common_obj_id
           'N',
           CRMINTEG_HZ_MRGDTIL_OBJ_TBL(),
           CAST(MULTISET(
             SELECT CRMINTEG_HZ_MRGDTIL_OBJ(
               'CONTACT',
               'N',
               cr.cust_account_id,             -- from cust_acct_site_id
               oc.org_contact_id,              -- from org_contact_id
               null,                           -- from common_obj_id
               cr.cust_account_id,             -- to cust_acct_site_id
               oc2.org_contact_id,             -- to org_contact_id
               r2.object_id)                   -- to party_id
             from HZ_MERGE_BATCH mb, HZ_MERGE_PARTIES mp, HZ_MERGE_PARTY_HISTORY mph,
                  HZ_MERGE_DICTIONARY md, HZ_CUST_ACCOUNT_ROLES cr, HZ_RELATIONSHIPS r, HZ_ORG_CONTACTS oc,
                  HZ_RELATIONSHIPS r2, HZ_ORG_CONTACTS oc2
             where mb.batch_id = l_batch_id
             and mb.batch_id = mp.batch_id
             and mp.merge_reason_code = 'DUPLICATE_RELN_PARTY'
             and mp.batch_party_id = mph.batch_party_id
             and mph.merge_dict_id = md.merge_dict_id
             and cr.cust_account_role_id = mph.from_entity_id
             and r.party_id = mp.from_party_id
             and r.relationship_id = oc.party_relationship_id
             and r.subject_Type = 'PERSON' and r.object_type = 'ORGANIZATION'
             and r2.party_id = mp.to_party_id
             and r2.relationship_id = oc2.party_relationship_id
             and r2.subject_Type = 'PERSON' and r2.object_type = 'ORGANIZATION'
             and md.entity_name = 'HZ_CUST_ACCOUNT_ROLES'
             ) AS CRMINTEG_HZ_MRGDTIL_OBJ_TBL ))
    from dual;

    l_debug_prefix         VARCHAR2(30);
    l_party_type           VARCHAR2(30);
    l_from_party_id        NUMBER;
    l_from_ca_id           NUMBER;
    l_to_party_id          NUMBER;
    i                      NUMBER;
  BEGIN
    x_party_merge_objs := CRMINTEG_HZ_MERGE_OBJ_TBL();

    OPEN get_merge_type;
    FETCH get_merge_type INTO l_party_type;
    CLOSE get_merge_type;

    IF(l_party_type = 'PERSON') THEN
      x_party_merge_objs.EXTEND;
      OPEN get_person_merge_detail(p_batch_id, l_party_type);
      FETCH get_person_merge_detail INTO x_party_merge_objs(1);
      CLOSE get_person_merge_detail;
    ELSIF(l_party_type = 'ORGANIZATION') THEN
      i := 1;
      OPEN get_merge_parties(p_batch_id);
      LOOP
        FETCH get_merge_parties INTO l_party_type, l_from_party_id, l_from_ca_id, l_to_party_id;
        EXIT WHEN get_merge_parties%NOTFOUND;
        x_party_merge_objs.EXTEND;

        OPEN get_merge_detail(p_batch_id, l_party_type, l_from_party_id, l_from_ca_id, l_to_party_id);
        FETCH get_merge_detail INTO x_party_merge_objs(i);
        CLOSE get_merge_detail;
        i := i + 1;
      END LOOP;
      CLOSE get_merge_parties;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_party_merge_objs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_party_merge_objs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_party_merge_objs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END get_party_merge_objs;

  PROCEDURE sync_acct_update(
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_org_cust_obj         IN            HZ_ORG_CUST_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_ORG_CUST_BO
  ) IS
    l_organization_id      NUMBER;
    l_organization_os      VARCHAR2(30);
    l_organization_osr     VARCHAR2(255);
    l_debug_prefix         VARCHAR2(30);
    l_org_obj              HZ_ORGANIZATION_BO;
    l_return_obj           HZ_ORG_CUST_BO;
    l_return_org_obj       HZ_ORGANIZATION_BO;
    l_input_acct_obj       HZ_CUST_ACCT_BO;
    l_org_cust_bo          HZ_ORG_CUST_BO;

    CURSOR get_cp_id(l_org_id NUMBER) IS
    SELECT contact_point_id
    FROM HZ_CONTACT_POINTS
    WHERE owner_table_name = 'HZ_PARTIES'
    AND contact_point_type = 'WEB'
    AND owner_table_id = l_org_id
    AND primary_flag = 'Y';

    CURSOR get_occp_id(l_oc_id NUMBER) IS
    SELECT cp.contact_point_id
    FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r, HZ_CONTACT_POINTS cp
    WHERE cp.owner_table_name = 'HZ_PARTIES'
    AND cp.contact_point_type = 'EMAIL'
    AND cp.owner_table_id = r.party_id
    AND cp.primary_flag = 'Y'
    AND oc.org_contact_id = l_oc_id
    AND oc.party_relationship_id = r.relationship_id
    AND rownum = 1;

    CURSOR get_cas_id(l_ps_id NUMBER, l_ca_id NUMBER, l_org_id NUMBER) IS
    SELECT cust_acct_site_id
    FROM HZ_CUST_ACCT_SITES_ALL
    WHERE cust_account_id = l_ca_id
    AND party_site_id = l_ps_id
    AND org_id = l_org_id
    AND rownum = 1;

    CURSOR get_casu_id(l_cas_id NUMBER, l_su_code VARCHAR2, l_org_id NUMBER) IS
    SELECT site_use_id
    FROM HZ_CUST_SITE_USES_ALL
    WHERE cust_acct_site_id = l_cas_id
    AND site_use_code = l_su_code
    AND status = 'A'
    AND org_id = l_org_id
    AND rownum = 1;
  BEGIN
    SAVEPOINT do_sync_acct_update;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(p_message=>'sync_acct_update(+)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_return_obj := HZ_ORG_CUST_BO(null, null, HZ_CUST_ACCT_BO_TBL());
    l_org_obj := p_org_cust_obj.organization_obj;


    -- update organization business object
    HZ_ORGANIZATION_BO_PUB.update_organization_bo(
      p_organization_obj    => l_org_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      p_return_obj_flag     => fnd_api.g_true,
      x_return_status       => x_return_status,
      x_messages            => x_messages,
      x_return_obj          => l_return_org_obj,
      x_organization_id     => l_organization_id,
      x_organization_os     => l_organization_os,
      x_organization_osr    => l_organization_osr
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_input_acct_obj := p_org_cust_obj.account_objs(1);

    -- get cust acct site and site use id
    IF(l_input_acct_obj.cust_acct_site_objs IS NOT NULL AND
       l_input_acct_obj.cust_acct_site_objs.COUNT > 0) THEN
      FOR k IN 1..l_input_acct_obj.cust_acct_site_objs.COUNT LOOP
        OPEN get_cas_id(l_input_acct_obj.cust_acct_site_objs(k).party_site_id,
                        l_input_acct_obj.cust_acct_id,
                        l_input_acct_obj.cust_acct_site_objs(k).org_id);
        FETCH get_cas_id INTO l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_id;
        CLOSE get_cas_id;
        IF(l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs IS NOT NULL AND
           l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs.COUNT > 0) THEN
          FOR l IN 1..l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs.COUNT LOOP
            OPEN get_casu_id(l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_id,
                             l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs(l).site_use_code,
                             l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs(l).org_id);
            FETCH get_casu_id INTO l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs(l).site_use_id;
            CLOSE get_casu_id;
          END LOOP;
        END IF;
      END LOOP;
    END IF;

    l_org_cust_bo := HZ_ORG_CUST_BO(null,null,HZ_CUST_ACCT_BO_TBL());
    l_org_obj := HZ_ORGANIZATION_BO.create_object(
                   p_organization_id => l_organization_id);
    l_org_cust_bo.organization_obj := l_org_obj;
    l_org_cust_bo.account_objs.EXTEND;
    l_org_cust_bo.account_objs(1) := l_input_acct_obj;

    -- call update_org_cust_bo
    HZ_ORG_CUST_BO_PUB.update_org_cust_bo(
      p_org_cust_obj         => l_org_cust_bo,
      p_created_by_module    => p_created_by_module,
      p_obj_source           => p_obj_source,
      p_return_obj_flag      => fnd_api.g_true,
      x_return_status        => x_return_status,
      x_messages             => x_messages,
      x_return_obj           => l_return_obj,
      x_organization_id      => l_organization_id
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    x_return_obj := l_return_obj;
    x_return_obj.organization_obj := l_return_org_obj;
    remove_gmiss(
      px_org_cust  => x_return_obj);

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(p_message=>'sync_acct_update(-)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_sync_acct_update;

      x_return_status := fnd_api.g_ret_sts_error;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'sync_acct_update(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_sync_acct_update;

      x_return_status := fnd_api.g_ret_sts_error;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'sync_acct_update(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO do_sync_acct_update;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'sync_acct_update(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END sync_acct_update;

  PROCEDURE sync_acct_order(
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_org_cust_obj         IN            HZ_ORG_CUST_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_ORG_CUST_BO
  ) IS
    l_organization_id      NUMBER;
    l_organization_os      VARCHAR2(30);
    l_organization_osr     VARCHAR2(255);
    l_cust_acct_id         NUMBER;
    l_cust_acct_os         VARCHAR2(30);
    l_cust_acct_osr        VARCHAR2(255);
    l_obj_type             VARCHAR2(30);
    l_debug_prefix         VARCHAR2(30);
    l_input_acct_obj       HZ_CUST_ACCT_BO;
    l_org_obj              HZ_ORGANIZATION_BO;
    l_return_org_obj       HZ_ORGANIZATION_BO;
    l_return_acct_obj      HZ_CUST_ACCT_BO;
    l_dummy                VARCHAR2(1) := NULL;
    l_an_profile           AR_SYSTEM_PARAMETERS.generate_customer_number%TYPE;
    l_su_profile           AR_SYSTEM_PARAMETERS.auto_site_numbering%TYPE;
    l_org_cust_bo          HZ_ORG_CUST_BO;
    l_return_obj           HZ_ORG_CUST_BO;

    CURSOR get_cp_id(l_org_id NUMBER) IS
    SELECT contact_point_id
    FROM HZ_CONTACT_POINTS
    WHERE owner_table_name = 'HZ_PARTIES'
    AND contact_point_type = 'WEB'
    AND owner_table_id = l_org_id
    AND primary_flag = 'Y';

    CURSOR get_occp_id(l_oc_id NUMBER) IS
    SELECT cp.contact_point_id
    FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r, HZ_CONTACT_POINTS cp
    WHERE cp.owner_table_name = 'HZ_PARTIES'
    AND cp.contact_point_type = 'EMAIL'
    AND cp.owner_table_id = r.party_id
    AND cp.primary_flag = 'Y'
    AND oc.org_contact_id = l_oc_id
    AND oc.party_relationship_id = r.relationship_id
    AND rownum = 1;

    CURSOR get_cas_id(l_ps_id NUMBER, l_ca_id NUMBER, l_org_id NUMBER) IS
    SELECT cust_acct_site_id
    FROM HZ_CUST_ACCT_SITES_ALL
    WHERE cust_account_id = l_ca_id
    AND party_site_id = l_ps_id
    AND org_id = l_org_id
    AND rownum = 1;

    CURSOR get_casu_id(l_cas_id NUMBER, l_su_code VARCHAR2, l_org_id NUMBER) IS
    SELECT site_use_id
    FROM HZ_CUST_SITE_USES_ALL
    WHERE cust_acct_site_id = l_cas_id
    AND site_use_code = l_su_code
    AND status = 'A'
    AND org_id = l_org_id
    AND rownum = 1;

    CURSOR get_cac_id(l_per_id NUMBER, l_ca_id NUMBER) IS
    SELECT car.cust_account_role_id
    FROM HZ_CUST_ACCOUNT_ROLES car, HZ_RELATIONSHIPS r
    WHERE car.cust_account_id = l_ca_id
    AND car.party_id = r.party_id
    AND r.subject_id = l_per_id
    AND r.subject_type = 'PERSON'
    AND r.object_type = 'ORGANIZATION'
    AND car.cust_acct_site_id IS NULL
    AND rownum = 1;

  BEGIN
    SAVEPOINT do_sync_acct_order;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(p_message=>'sync_acct_order(+)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_return_obj := HZ_ORG_CUST_BO(null, null, HZ_CUST_ACCT_BO_TBL());
    l_org_obj := p_org_cust_obj.organization_obj;

    -- create/update organization business object
    HZ_ORGANIZATION_BO_PUB.save_organization_bo(
      p_validate_bo_flag    => p_validate_bo_flag,
      p_organization_obj    => l_org_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      p_return_obj_flag     => fnd_api.g_true,
      x_return_status       => x_return_status,
      x_messages            => x_messages,
      x_return_obj          => l_return_org_obj,
      x_organization_id     => l_organization_id,
      x_organization_os     => l_organization_os,
      x_organization_osr    => l_organization_osr
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    x_return_obj.organization_obj := l_return_org_obj;

    l_input_acct_obj := p_org_cust_obj.account_objs(1);


    -- for each party site, set party_site_id for cust acct site under acct
    IF(x_return_obj.organization_obj.party_site_objs IS NOT NULL AND
       x_return_obj.organization_obj.party_site_objs.COUNT > 0) THEN
      FOR i IN 1..x_return_obj.organization_obj.party_site_objs.COUNT LOOP
        FOR j IN 1..l_input_acct_obj.cust_acct_site_objs.COUNT LOOP
          IF(l_input_acct_obj.cust_acct_site_objs(j).party_site_id IS NULL AND l_input_acct_obj.cust_acct_site_objs(j).common_obj_id = x_return_obj.organization_obj.party_site_objs(i).common_obj_id) THEN
            l_input_acct_obj.cust_acct_site_objs(j).party_site_id := x_return_obj.organization_obj.party_site_objs(i).party_site_id;
          END IF;
        END LOOP;
      END LOOP;
    END IF;

    -- for each org contact, add contact_person_id, relationship_type, relationship_code
    -- start_date and role_type for cust acct contact under acct
    IF(x_return_obj.organization_obj.contact_objs IS NOT NULL AND
       x_return_obj.organization_obj.contact_objs.COUNT > 0) THEN
      FOR i IN 1..x_return_obj.organization_obj.contact_objs.COUNT LOOP
        FOR j IN 1..l_input_acct_obj.cust_acct_contact_objs.COUNT LOOP
          IF(l_input_acct_obj.cust_acct_contact_objs(j).contact_person_id IS NULL AND l_input_acct_obj.cust_acct_contact_objs(j).common_obj_id = x_return_obj.organization_obj.contact_objs(i).common_obj_id) THEN
            l_input_acct_obj.cust_acct_contact_objs(j).contact_person_id := x_return_obj.organization_obj.contact_objs(i).person_profile_obj.person_id;
            l_input_acct_obj.cust_acct_contact_objs(j).relationship_code := x_return_obj.organization_obj.contact_objs(i).relationship_code;
            l_input_acct_obj.cust_acct_contact_objs(j).relationship_type := x_return_obj.organization_obj.contact_objs(i).relationship_type;
            l_input_acct_obj.cust_acct_contact_objs(j).start_date := x_return_obj.organization_obj.contact_objs(i).start_date;
          END IF;
        END LOOP;
      END LOOP;
    END IF;

    -- if organization already exists, try to get cust_acct_site_id
    IF(p_org_cust_obj.organization_obj.organization_id IS NOT NULL AND
       l_input_acct_obj.cust_acct_site_objs IS NOT NULL AND
       l_input_acct_obj.cust_acct_site_objs.COUNT > 0) THEN
      FOR k IN 1..l_input_acct_obj.cust_acct_site_objs.COUNT LOOP
        OPEN get_cas_id(l_input_acct_obj.cust_acct_site_objs(k).party_site_id,
                        l_input_acct_obj.cust_acct_id,
                        l_input_acct_obj.cust_acct_site_objs(k).org_id);
        FETCH get_cas_id INTO l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_id;
        CLOSE get_cas_id;
        IF(l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs IS NOT NULL AND
           l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs.COUNT > 0) THEN
          FOR l IN 1..l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs.COUNT LOOP
            OPEN get_casu_id(l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_id,
                             l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs(l).site_use_code,
                             l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs(l).org_id);
            FETCH get_casu_id INTO l_input_acct_obj.cust_acct_site_objs(k).cust_acct_site_use_objs(l).site_use_id;
            CLOSE get_casu_id;
          END LOOP;
        END IF;
      END LOOP;
     END IF; --8745333

      FOR l IN 1..l_input_acct_obj.cust_acct_contact_objs.COUNT LOOP
        OPEN get_cac_id(l_input_acct_obj.cust_acct_contact_objs(l).contact_person_id,
                        l_input_acct_obj.cust_acct_id);
        FETCH get_cac_id INTO l_input_acct_obj.cust_acct_contact_objs(l).cust_acct_contact_id;
        CLOSE get_cac_id;
      END LOOP;

    l_org_cust_bo := HZ_ORG_CUST_BO(null,null,HZ_CUST_ACCT_BO_TBL());
    l_org_obj := HZ_ORGANIZATION_BO.create_object(
                   p_organization_id => l_organization_id);
    l_org_cust_bo.organization_obj := l_org_obj;
    l_org_cust_bo.account_objs.EXTEND;
    l_org_cust_bo.account_objs(1) := l_input_acct_obj;

    UPDATE HZ_PARTIES
    set ORG_CUST_BO_VERSION = ( SELECT BO_VERSION_NUMBER
                                FROM HZ_BUS_OBJ_DEFINITIONS
                                WHERE BUSINESS_OBJECT_CODE = 'ORG_CUST'
                                AND ENTITY_NAME = 'HZ_PARTIES'
                                AND CHILD_BO_CODE IS NULL )
    WHERE party_id = l_organization_id;

    -- call save_org_cust_bo
    HZ_ORG_CUST_BO_PUB.save_org_cust_bo(
      p_validate_bo_flag     => p_validate_bo_flag,
      p_org_cust_obj         => l_org_cust_bo,
      p_created_by_module    => p_created_by_module,
      p_obj_source           => p_obj_source,
      p_return_obj_flag      => fnd_api.g_true,
      x_return_status        => x_return_status,
      x_messages             => x_messages,
      x_return_obj           => l_return_obj,
      x_organization_id      => l_organization_id
    );

    x_return_obj := l_return_obj;
    x_return_obj.organization_obj := l_return_org_obj;
/*
    l_obj_type := 'ORG';

    -- create/update org cust acct business object then
    HZ_CUST_ACCT_BO_PUB.save_cust_acct_bo(
      p_validate_bo_flag     => p_validate_bo_flag,
      p_cust_acct_obj        => l_input_acct_obj,
      p_created_by_module    => p_created_by_module,
      p_obj_source           => p_obj_source,
      p_return_obj_flag      => fnd_api.g_true,
      x_return_status        => x_return_status,
      x_messages             => x_messages,
      x_return_obj           => l_return_acct_obj,
      x_cust_acct_id         => l_cust_acct_id,
      x_cust_acct_os         => l_cust_acct_os,
      x_cust_acct_osr        => l_cust_acct_osr,
      px_parent_id           => l_organization_id,
      px_parent_os           => l_organization_os,
      px_parent_osr          => l_organization_osr,
      px_parent_obj_type     => l_obj_type
    );
*/
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;
/*
    x_return_obj.account_objs.EXTEND;
    x_return_obj.account_objs(1) := l_return_acct_obj;
    remove_gmiss(
      px_org_cust  => x_return_obj);
*/

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(p_message=>'sync_acct_order(-)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_sync_acct_order;

      x_return_status := fnd_api.g_ret_sts_error;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'sync_acct_order(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_sync_acct_order;

      x_return_status := fnd_api.g_ret_sts_error;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'sync_acct_order(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO do_sync_acct_order;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'sync_acct_order(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END sync_acct_order;


  PROCEDURE get_merge_org_custs(
    p_init_msg_list        IN            VARCHAR2 := FND_API.G_FALSE,
    p_from_org_id          IN            NUMBER,
    p_to_org_id            IN            NUMBER,
    p_from_acct_id         IN            NUMBER,
    p_to_acct_id           IN            NUMBER,
    x_org_cust_objs        OUT NOCOPY    HZ_ORG_CUST_BO_TBL,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_debug_prefix         VARCHAR2(30) := '';
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_org_id               NUMBER;
    l_acct_id              NUMBER;
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(p_message=>'get_merge_org_custs(+)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_org_cust_objs := HZ_ORG_CUST_BO_TBL();

    FOR i IN 1..2 LOOP
      -- If same from to account and same from to org
      -- quit the 2nd loop
      IF i = 2 AND p_from_org_id = p_to_org_id AND p_from_acct_id = p_to_acct_id THEN
        EXIT;
      END IF;

      x_org_cust_objs.EXTEND;
      x_org_cust_objs(i) := HZ_ORG_CUST_BO(NULL, NULL, NULL);
      IF i = 1 THEN
        l_org_id := p_from_org_id;
        l_acct_id := p_from_acct_id;
      ELSE
        l_org_id := p_to_org_id;
        l_acct_id := p_to_acct_id;
      END IF;

      HZ_EXTRACT_ORGANIZATION_BO_PVT.get_organization_bo(
        p_init_msg_list   => fnd_api.g_false,
        p_organization_id => l_org_id,
        p_action_type     => NULL,
        x_organization_obj => x_org_cust_objs(i).organization_obj,
        x_return_status => x_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
/*
    IF(x_org_cust_obj.organization_obj IS NULL OR x_org_cust_obj.organization_obj.organization_id IS NULL)THEN
      fnd_message.set_name('AR', 'HZ_API_INVALID_TCA_ID');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => l_msg_count,
                                p_data  => l_msg_data);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
      HZ_EXTRACT_CUST_ACCT_BO_PVT.get_cust_acct_bos(
        p_init_msg_list    => fnd_api.g_false,
        p_parent_id        => l_org_id,
        p_cust_acct_id     => l_acct_id,
        p_action_type      => NULL,
        x_cust_acct_objs   => x_org_cust_objs(i).account_objs,
        x_return_status => x_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
/*
    IF(x_org_cust_obj.account_objs IS NULL OR x_org_cust_obj.account_objs.COUNT < 1)THEN
      fnd_message.set_name('AR', 'HZ_API_INVALID_TCA_ID');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => l_msg_count,
                                p_data  => l_msg_data);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 */
    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug_return_messages(p_msg_count=>l_msg_count,
                                             p_msg_data=>l_msg_data,
                                             p_msg_type=>'WARNING',
                                             p_msg_level=>fnd_log.level_exception);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_merge_org_custs(-)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                      x_return_status   => x_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>l_msg_count,
                               p_msg_data=>l_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_merge_org_custs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                      x_return_status   => x_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>l_msg_count,
                               p_msg_data=>l_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_merge_org_custs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => l_msg_count,
                                p_data  => l_msg_data);
      x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                      x_return_status   => x_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>l_msg_count,
                               p_msg_data=>l_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_merge_org_custs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END get_merge_org_custs;

END HZ_AIA_CUSTOM_PKG;

/
