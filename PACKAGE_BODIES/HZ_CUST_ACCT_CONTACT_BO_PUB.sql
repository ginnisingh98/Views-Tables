--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCT_CONTACT_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCT_CONTACT_BO_PUB" AS
/*$Header: ARHBCRBB.pls 120.17 2008/02/20 19:27:26 awu ship $ */

  -- PRIVATE PROCEDURE assign_cust_acct_role_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account contact object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_role_obj Customer account contact object.
  --     p_party_id           Party Id.
  --     p_cust_acct_id       Customer account Id.
  --     p_cust_acct_site_id  Customer account site Id.
  --     p_cust_acct_contact_id  Customer account contact Id.
  --     p_cust_acct_contact_os  Customer account contact original system.
  --     p_cust_acct_contact_osr Customer account contact original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_cust_acct_role_rec   Customer Account Contact plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_cust_acct_role_rec(
    p_cust_acct_role_obj         IN            HZ_CUST_ACCT_CONTACT_BO,
    p_party_id                   IN            NUMBER,
    p_cust_acct_id               IN            NUMBER,
    p_cust_acct_site_id          IN            NUMBER,
    p_cust_acct_contact_id       IN            NUMBER,
    p_cust_acct_contact_os       IN            VARCHAR2,
    p_cust_acct_contact_osr      IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_cust_account_role_rec     IN OUT NOCOPY HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_cust_acct_role_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account contact object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_role_obj Customer account contact object.
  --     p_party_id           Party Id.
  --     p_cust_acct_id       Customer account Id.
  --     p_cust_acct_site_id  Customer account site Id.
  --     p_cust_acct_contact_id  Customer account contact Id.
  --     p_cust_acct_contact_os  Customer account contact original system.
  --     p_cust_acct_contact_osr Customer account contact original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_cust_acct_role_rec   Customer Account Contact plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_cust_acct_role_rec(
    p_cust_acct_role_obj         IN            HZ_CUST_ACCT_CONTACT_BO,
    p_party_id                   IN            NUMBER,
    p_cust_acct_id               IN            NUMBER,
    p_cust_acct_site_id          IN            NUMBER,
    p_cust_acct_contact_id       IN            NUMBER,
    p_cust_acct_contact_os       IN            VARCHAR2,
    p_cust_acct_contact_osr      IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_cust_account_role_rec     IN OUT NOCOPY HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE
  ) IS
  BEGIN
    px_cust_account_role_rec.cust_account_role_id := p_cust_acct_contact_id;
    px_cust_account_role_rec.party_id             := p_party_id;
    px_cust_account_role_rec.cust_account_id      := p_cust_acct_id;
    px_cust_account_role_rec.cust_acct_site_id    := p_cust_acct_site_id;
    IF(p_cust_acct_role_obj.primary_flag in ('Y','N')) THEN
      px_cust_account_role_rec.primary_flag         := p_cust_acct_role_obj.primary_flag;
    END IF;
    px_cust_account_role_rec.role_type            := p_cust_acct_role_obj.role_type;
    px_cust_account_role_rec.source_code          := p_cust_acct_role_obj.source_code;
    px_cust_account_role_rec.attribute_category   := p_cust_acct_role_obj.attribute_category;
    px_cust_account_role_rec.attribute1           := p_cust_acct_role_obj.attribute1;
    px_cust_account_role_rec.attribute2           := p_cust_acct_role_obj.attribute2;
    px_cust_account_role_rec.attribute3           := p_cust_acct_role_obj.attribute3;
    px_cust_account_role_rec.attribute4           := p_cust_acct_role_obj.attribute4;
    px_cust_account_role_rec.attribute5           := p_cust_acct_role_obj.attribute5;
    px_cust_account_role_rec.attribute6           := p_cust_acct_role_obj.attribute6;
    px_cust_account_role_rec.attribute7           := p_cust_acct_role_obj.attribute7;
    px_cust_account_role_rec.attribute8           := p_cust_acct_role_obj.attribute8;
    px_cust_account_role_rec.attribute9           := p_cust_acct_role_obj.attribute9;
    px_cust_account_role_rec.attribute10          := p_cust_acct_role_obj.attribute10;
    px_cust_account_role_rec.attribute11          := p_cust_acct_role_obj.attribute11;
    px_cust_account_role_rec.attribute12          := p_cust_acct_role_obj.attribute12;
    px_cust_account_role_rec.attribute13          := p_cust_acct_role_obj.attribute13;
    px_cust_account_role_rec.attribute14          := p_cust_acct_role_obj.attribute14;
    px_cust_account_role_rec.attribute15          := p_cust_acct_role_obj.attribute15;
    px_cust_account_role_rec.attribute16          := p_cust_acct_role_obj.attribute16;
    px_cust_account_role_rec.attribute17          := p_cust_acct_role_obj.attribute17;
    px_cust_account_role_rec.attribute18          := p_cust_acct_role_obj.attribute18;
    px_cust_account_role_rec.attribute19          := p_cust_acct_role_obj.attribute19;
    px_cust_account_role_rec.attribute20          := p_cust_acct_role_obj.attribute20;
    px_cust_account_role_rec.attribute21          := p_cust_acct_role_obj.attribute21;
    px_cust_account_role_rec.attribute22          := p_cust_acct_role_obj.attribute22;
    px_cust_account_role_rec.attribute23          := p_cust_acct_role_obj.attribute23;
    px_cust_account_role_rec.attribute24          := p_cust_acct_role_obj.attribute24;
    px_cust_account_role_rec.attribute25          := p_cust_acct_role_obj.attribute25;
    IF(p_cust_acct_role_obj.status in ('A','I')) THEN
      px_cust_account_role_rec.status               := p_cust_acct_role_obj.status;
    END IF;
    IF(p_create_or_update = 'C') THEN
      px_cust_account_role_rec.orig_system          := p_cust_acct_contact_os;
      px_cust_account_role_rec.orig_system_reference := p_cust_acct_contact_osr;
      px_cust_account_role_rec.created_by_module    := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
  END assign_cust_acct_role_rec;

  -- PROCEDURE do_create_cac_bo
  --
  -- DESCRIPTION
  --     Create customer account contact business object.
  PROCEDURE do_create_cac_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj   IN OUT NOCOPY HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_cust_acct_role_rec       HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE;
    l_role_responsibility_rec  HZ_CUST_ACCOUNT_ROLE_V2PUB.ROLE_RESPONSIBILITY_REC_TYPE;
    l_oc_id                    NUMBER;
    l_oc_os                    VARCHAR2(30);
    l_oc_osr                   VARCHAR2(255);
    l_per_id                   NUMBER;
    l_obj_party_id             NUMBER;
    l_party_type               VARCHAR2(30);
    l_ca_id                    NUMBER;
    l_cas_id                   NUMBER;
    l_rel_party_id             NUMBER;
    l_rel_ovn                  NUMBER;
    l_valid_obj                BOOLEAN;
    l_bus_object               HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_rel_obj                  HZ_RELATIONSHIP_OBJ_TBL;
    l_valid_per                VARCHAR2(1);

    CURSOR get_cas_party_id(l_cas_id NUMBER) IS
    SELECT ca.cust_account_id, cas.cust_acct_site_id, ca.party_id, p.party_type
    FROM HZ_CUST_ACCT_SITES cas, HZ_CUST_ACCOUNTS ca, HZ_PARTIES p
    WHERE cas.cust_acct_site_id = l_cas_id
    AND cas.cust_account_id = ca.cust_account_id
    AND ca.party_id = p.party_id
    AND p.status in ('A','I')
    AND rownum = 1;

    CURSOR get_ca_party_id(l_ca_id NUMBER) IS
    SELECT ca.cust_account_id, ca.party_id, p.party_type
    FROM HZ_CUST_ACCOUNTS ca, HZ_PARTIES p
    WHERE ca.cust_account_id = l_ca_id
    AND ca.party_id = p.party_id
    AND p.status in ('A','I')
    AND rownum = 1;

    CURSOR get_contact_rel_noid(l_per_id NUMBER, l_obj_id NUMBER, l_rel_code VARCHAR2, l_rel_type VARCHAR2) IS
    SELECT r.party_id
    FROM HZ_RELATIONSHIPS r
    WHERE r.subject_id = l_per_id
    AND r.subject_type = 'PERSON'
    AND r.object_id = l_obj_id
    AND r.relationship_type = l_rel_type
    AND r.relationship_code = l_rel_code
    AND sysdate between r.start_date and nvl(r.end_date, sysdate);

    CURSOR get_contact_rel(l_per_id NUMBER, l_obj_id NUMBER, l_rel_id NUMBER) IS
    SELECT r.party_id
    FROM HZ_RELATIONSHIPS r
    WHERE r.relationship_id = l_rel_id
    AND r.subject_id = l_per_id
    AND r.subject_type = 'PERSON'
    AND r.object_id = l_obj_id
    AND sysdate between r.start_date and nvl(r.end_date, sysdate);
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_cac_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cac_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Base on p_validate_bo_flag, check the completeness of business objects
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'CUST_ACCT_CONTACT',
        x_bus_object              => l_bus_object
      );
      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_cac_bo_comp(
                       p_cac_objs   => HZ_CUST_ACCT_CONTACT_BO_TBL(p_cust_acct_contact_obj),
                       p_bus_object => l_bus_object
                     );
      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- check pass in parent_id and parent_os+osr
    hz_registry_validate_bo_pvt.validate_parent_id(
      px_parent_id       => px_parent_id,
      px_parent_os       => px_parent_os,
      px_parent_osr      => px_parent_osr,
      p_parent_obj_type  => px_parent_obj_type,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cust_acct_contact_id := p_cust_acct_contact_obj.cust_acct_contact_id;
    x_cust_acct_contact_os := p_cust_acct_contact_obj.orig_system;
    x_cust_acct_contact_osr := p_cust_acct_contact_obj.orig_system_reference;
    l_cas_id := p_cust_acct_contact_obj.cust_acct_site_id;

    -- check if pass in cust_account_role_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cust_acct_contact_id,
      px_os              => x_cust_acct_contact_os,
      px_osr             => x_cust_acct_contact_osr,
      p_obj_type         => 'HZ_CUST_ACCOUNT_ROLES',
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- From px_parent_id, get parent party_id

      OPEN get_ca_party_id(px_parent_id);
      FETCH get_ca_party_id INTO l_ca_id, l_obj_party_id, l_party_type;
      CLOSE get_ca_party_id;


    -- check if the relationship already exist
    l_per_id := p_cust_acct_contact_obj.contact_person_id;
    IF(l_per_id IS NULL) THEN
      l_per_id := HZ_REGISTRY_VALIDATE_BO_PVT.get_id_from_ososr(
                    p_os => p_cust_acct_contact_obj.contact_person_os,
                    p_osr => p_cust_acct_contact_obj.contact_person_osr,
                    p_owner_table_name => 'HZ_PARTIES'
                  );
    END IF;

    IF(p_cust_acct_contact_obj.relationship_id IS NOT NULL) THEN
      OPEN get_contact_rel(l_per_id, l_obj_party_id,
                           p_cust_acct_contact_obj.relationship_id);
      FETCH get_contact_rel INTO l_rel_party_id;
      CLOSE get_contact_rel;
    ELSE
      OPEN get_contact_rel_noid(l_per_id, l_obj_party_id,
                                p_cust_acct_contact_obj.relationship_code,
                                p_cust_acct_contact_obj.relationship_type);
      FETCH get_contact_rel_noid INTO l_rel_party_id;
      CLOSE get_contact_rel_noid;
    END IF;

    IF(l_rel_party_id IS NULL) THEN
      FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_FK');
      FND_MESSAGE.SET_TOKEN('FK','RELATIONSHIP');
      FND_MESSAGE.SET_TOKEN('COLUMN','RELATIONSHIIP_ID, RELATIONSHIP_CODE, RELATIONSHIP_TYPE');
      FND_MESSAGE.SET_TOKEN('TABLE','HZ_RELATIONSHIPS');
      FND_MSG_PUB.ADD();
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ----------------------------------
    -- Assign cust account role record
    ----------------------------------
    -- party_id is the party_id of the org contact relationship --

    assign_cust_acct_role_rec(
      p_cust_acct_role_obj        => p_cust_acct_contact_obj,
      p_party_id                  => l_rel_party_id,
      p_cust_acct_id              => l_ca_id,
      p_cust_acct_site_id         => l_cas_id,
      p_cust_acct_contact_id      => x_cust_acct_contact_id,
      p_cust_acct_contact_os      => x_cust_acct_contact_os,
      p_cust_acct_contact_osr     => x_cust_acct_contact_osr,
      px_cust_account_role_rec    => l_cust_acct_role_rec
    );

    HZ_CUST_ACCOUNT_ROLE_V2PUB.create_cust_account_role (
      p_cust_account_role_rec     => l_cust_acct_role_rec,
      x_cust_account_role_id      => x_cust_acct_contact_id,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign cust_acct_contact_id
    p_cust_acct_contact_obj.cust_acct_contact_id := x_cust_acct_contact_id;
    -------------------------------------
    -- Call role responsibility v2pub api
    -------------------------------------
    IF((p_cust_acct_contact_obj.contact_role_objs IS NOT NULL) AND
       (p_cust_acct_contact_obj.contact_role_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_CONTACT_BO_PVT.create_role_responsibilities(
        p_rr_objs            => p_cust_acct_contact_obj.contact_role_objs,
        p_cac_id             => x_cust_acct_contact_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_cac_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_CONTACT');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_cac_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_CONTACT');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_cac_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_CONTACT');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_cac_bo;

  PROCEDURE create_cust_acct_contact_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_cac_obj                 HZ_CUST_ACCT_CONTACT_BO;
  BEGIN
    l_cac_obj := p_cust_acct_contact_obj;
    do_create_cac_bo(
      p_init_msg_list           => p_init_msg_list,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_contact_obj   => l_cac_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => null,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_cust_acct_contact_id    => x_cust_acct_contact_id,
      x_cust_acct_contact_os    => x_cust_acct_contact_os,
      x_cust_acct_contact_osr   => x_cust_acct_contact_osr,
      px_parent_id              => px_parent_id,
      px_parent_os              => px_parent_os,
      px_parent_osr             => px_parent_osr,
      px_parent_obj_type        => px_parent_obj_type
    );
  END create_cust_acct_contact_bo;

  PROCEDURE create_cust_acct_contact_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_CONTACT_BO,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_cac_obj                 HZ_CUST_ACCT_CONTACT_BO;
  BEGIN
    l_cac_obj := p_cust_acct_contact_obj;
    do_create_cac_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_contact_obj   => l_cac_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => null,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_contact_id    => x_cust_acct_contact_id,
      x_cust_acct_contact_os    => x_cust_acct_contact_os,
      x_cust_acct_contact_osr   => x_cust_acct_contact_osr,
      px_parent_id              => px_parent_id,
      px_parent_os              => px_parent_os,
      px_parent_osr             => px_parent_osr,
      px_parent_obj_type        => px_parent_obj_type
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_cac_obj;
    END IF;
  END create_cust_acct_contact_bo;

  -- PROCEDURE update_cust_acct_contact_bo
  --
  -- DESCRIPTION
  --     Update customer account contact business object.
  PROCEDURE update_cust_acct_contact_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2
  )IS
    l_cac_obj                 HZ_CUST_ACCT_CONTACT_BO;
  BEGIN
    l_cac_obj := p_cust_acct_contact_obj;
    do_update_cac_bo(
      p_init_msg_list           => p_init_msg_list,
      p_cust_acct_contact_obj   => l_cac_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => null,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_cust_acct_contact_id    => x_cust_acct_contact_id,
      x_cust_acct_contact_os    => x_cust_acct_contact_os,
      x_cust_acct_contact_osr   => x_cust_acct_contact_osr,
      p_parent_os               => NULL
    );
  END update_cust_acct_contact_bo;

  PROCEDURE update_cust_acct_contact_bo(
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_CONTACT_BO,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_cac_obj                 HZ_CUST_ACCT_CONTACT_BO;
  BEGIN
    l_cac_obj := p_cust_acct_contact_obj;
    do_update_cac_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_cust_acct_contact_obj   => l_cac_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_contact_id    => x_cust_acct_contact_id,
      x_cust_acct_contact_os    => x_cust_acct_contact_os,
      x_cust_acct_contact_osr   => x_cust_acct_contact_osr,
      p_parent_os               => NULL
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_cac_obj;
    END IF;
  END update_cust_acct_contact_bo;

  PROCEDURE do_update_cac_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_contact_obj   IN OUT NOCOPY HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    p_parent_os               IN            VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_cust_acct_role_rec       HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE;
    l_role_responsibility_rec  HZ_CUST_ACCOUNT_ROLE_V2PUB.ROLE_RESPONSIBILITY_REC_TYPE;
    l_car_ovn                  NUMBER;
    l_create_update_flag       VARCHAR2(1);
    l_parent_os                VARCHAR2(30);
    l_org_contact_id           NUMBER;
    l_org_contact_os           VARCHAR2(30);
    l_org_contact_osr          VARCHAR2(255);

    l_party_id                 NUMBER;
    l_ca_id                    NUMBER;
    l_cas_id                   NUMBER;

    CURSOR get_ovn(l_car_id NUMBER) IS
    SELECT r.object_version_number, r.party_id, r.cust_account_id, r.cust_acct_site_id
    FROM HZ_CUST_ACCOUNT_ROLES r
    WHERE r.cust_account_role_id = l_car_id;
  BEGIN
    -- Standard start of API savepoint
    -- SAVEPOINT update_logical_cac_pub;
    SAVEPOINT do_update_cac_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cac_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_cust_acct_contact_id := p_cust_acct_contact_obj.cust_acct_contact_id;
    x_cust_acct_contact_os := p_cust_acct_contact_obj.orig_system;
    x_cust_acct_contact_osr := p_cust_acct_contact_obj.orig_system_reference;

    -- check if pass in org_contact_id and ssm is valid for update
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cust_acct_contact_id,
      px_os              => x_cust_acct_contact_os,
      px_osr             => x_cust_acct_contact_osr,
      p_obj_type         => 'HZ_CUST_ACCOUNT_ROLES',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN get_ovn(x_cust_acct_contact_id);
    FETCH get_ovn INTO l_car_ovn, l_party_id, l_ca_id, l_cas_id;
    CLOSE get_ovn;

    -------------------------------
    -- For Update Cust Account Role
    -------------------------------
    assign_cust_acct_role_rec(
      p_cust_acct_role_obj        => p_cust_acct_contact_obj,
      p_party_id                  => l_party_id,
      p_cust_acct_id              => l_ca_id,
      p_cust_acct_site_id         => l_cas_id,
      p_cust_acct_contact_id      => x_cust_acct_contact_id,
      p_cust_acct_contact_os      => x_cust_acct_contact_os,
      p_cust_acct_contact_osr     => x_cust_acct_contact_osr,
      p_create_or_update          => 'U',
      px_cust_account_role_rec    => l_cust_acct_role_rec
    );

    HZ_CUST_ACCOUNT_ROLE_V2PUB.update_cust_account_role(
      p_cust_account_role_rec       => l_cust_acct_role_rec,
      p_object_version_number       => l_car_ovn,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign cust_acct_contact_id
    p_cust_acct_contact_obj.cust_acct_contact_id := x_cust_acct_contact_id;
    ----------------------------
    -- For Role Responsibilities
    ----------------------------
    IF((p_cust_acct_contact_obj.contact_role_objs IS NOT NULL) AND
       (p_cust_acct_contact_obj.contact_role_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_CONTACT_BO_PVT.save_role_responsibilities(
        p_rr_objs            => p_cust_acct_contact_obj.contact_role_objs,
        p_cac_id             => x_cust_acct_contact_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_cac_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_CONTACT');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_cac_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_CONTACT');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_cac_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_CONTACT');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_cac_bo;

  -- PROCEDURE do_save_cac_bo
  --
  -- DESCRIPTION
  --     Create or update customer account contact business object.
  PROCEDURE do_save_cac_bo(
    p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag         IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj    IN OUT NOCOPY HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module        IN            VARCHAR2,
    p_obj_source               IN            VARCHAR2 := null,
    x_return_status            OUT NOCOPY    VARCHAR2,
    x_msg_count                OUT NOCOPY    NUMBER,
    x_msg_data                 OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id     OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os     OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr    OUT NOCOPY    VARCHAR2,
    px_parent_id               IN OUT NOCOPY NUMBER,
    px_parent_os               IN OUT NOCOPY VARCHAR2,
    px_parent_osr              IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type         IN OUT NOCOPY VARCHAR2
  ) IS
    l_return_status            VARCHAR2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_create_update_flag       VARCHAR2(1);
    l_debug_prefix             VARCHAR2(30) := '';
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_cac_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_cust_acct_contact_id := p_cust_acct_contact_obj.cust_acct_contact_id;
    x_cust_acct_contact_os := p_cust_acct_contact_obj.orig_system;
    x_cust_acct_contact_osr := p_cust_acct_contact_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => x_cust_acct_contact_id,
                              p_entity_os      => x_cust_acct_contact_os,
                              p_entity_osr     => x_cust_acct_contact_osr,
                              p_entity_type    => 'HZ_CUST_ACCOUNT_ROLES',
                              p_parent_id      => px_parent_id,
                              p_parent_obj_type => px_parent_obj_type
                            );

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_CONTACT');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_cac_bo(
        p_init_msg_list            => fnd_api.g_false,
        p_validate_bo_flag         => p_validate_bo_flag,
        p_cust_acct_contact_obj    => p_cust_acct_contact_obj,
        p_created_by_module        => p_created_by_module,
        p_obj_source               => p_obj_source,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data,
        x_cust_acct_contact_id     => x_cust_acct_contact_id,
        x_cust_acct_contact_os     => x_cust_acct_contact_os,
        x_cust_acct_contact_osr    => x_cust_acct_contact_osr,
        px_parent_id               => px_parent_id,
        px_parent_os               => px_parent_os,
        px_parent_osr              => px_parent_osr,
        px_parent_obj_type         => px_parent_obj_type
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_cac_bo(
        p_init_msg_list            => fnd_api.g_false,
        p_cust_acct_contact_obj    => p_cust_acct_contact_obj,
        p_created_by_module        => p_created_by_module,
        p_obj_source               => p_obj_source,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data,
        x_cust_acct_contact_id     => x_cust_acct_contact_id,
        x_cust_acct_contact_os     => x_cust_acct_contact_os,
        x_cust_acct_contact_osr    => x_cust_acct_contact_osr,
        p_parent_os                => px_parent_os
      );
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      FND_MESSAGE.SET_NAME('AR', 'HZ_SAVE_API_ERROR');
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_cac_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_cac_bo;

  PROCEDURE save_cust_acct_contact_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_cac_obj                 HZ_CUST_ACCT_CONTACT_BO;
  BEGIN
    l_cac_obj := p_cust_acct_contact_obj;
    do_save_cac_bo(
      p_init_msg_list           => p_init_msg_list,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_contact_obj   => l_cac_obj,
      p_created_by_module       => p_created_by_module,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_cust_acct_contact_id    => x_cust_acct_contact_id,
      x_cust_acct_contact_os    => x_cust_acct_contact_os,
      x_cust_acct_contact_osr   => x_cust_acct_contact_osr,
      px_parent_id              => px_parent_id,
      px_parent_os              => px_parent_os,
      px_parent_osr             => px_parent_osr,
      px_parent_obj_type        => px_parent_obj_type
    );
  END save_cust_acct_contact_bo;

  PROCEDURE save_cust_acct_contact_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_contact_obj   IN            HZ_CUST_ACCT_CONTACT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_CONTACT_BO,
    x_cust_acct_contact_id    OUT NOCOPY    NUMBER,
    x_cust_acct_contact_os    OUT NOCOPY    VARCHAR2,
    x_cust_acct_contact_osr   OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_cac_obj                 HZ_CUST_ACCT_CONTACT_BO;
  BEGIN
    l_cac_obj := p_cust_acct_contact_obj;
    do_save_cac_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_contact_obj   => l_cac_obj,
      p_created_by_module       => p_created_by_module,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_contact_id    => x_cust_acct_contact_id,
      x_cust_acct_contact_os    => x_cust_acct_contact_os,
      x_cust_acct_contact_osr   => x_cust_acct_contact_osr,
      px_parent_id              => px_parent_id,
      px_parent_os              => px_parent_os,
      px_parent_osr             => px_parent_osr,
      px_parent_obj_type        => px_parent_obj_type
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_cac_obj;
    END IF;
  END save_cust_acct_contact_bo;

 --------------------------------------
  --
  -- PROCEDURE get_cust_acct_contact_bos
  --
  -- DESCRIPTION
  --     Get logical customer account contacts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
 --      p_parent_id          parent id.
--       p_cust_acct_contact_id          customer account contact ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_contact_objs         Logical customer account contact records.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --
  --   8-JUN-2005   AWU                Created.
  --

/*

The Get customer account contact API Procedure is a retrieval service that returns a full customer account contact business object.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's Source System
information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels. This includes the
set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments

Org Contact		Y		N	get_org_contact_bo


To retrieve the appropriate embedded entities within the 'Customer Account Contact' business object, the Get procedure returns all
records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account Role	N	N	HZ_CUST_ACCOUNT_ROLES
Role Responsibility	N	Y	HZ_ROLE_RESPONSIBILITY

*/


PROCEDURE get_cust_acct_contact_bo (
	p_init_msg_list		IN	VARCHAR2:=FND_API.G_FALSE,
	p_cust_acct_contact_id	IN	NUMBER,
	p_cust_acct_contact_os	IN	VARCHAR2,
	p_cust_acct_contact_osr	IN	VARCHAR2,
	x_cust_acct_contact_obj	OUT NOCOPY	HZ_CUST_ACCT_CONTACT_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_cust_acct_contact_id  number;
  l_cust_acct_contact_os  varchar2(30);
  l_cust_acct_contact_osr varchar2(255);
  l_cust_acct_contact_objs  HZ_CUST_ACCT_CONTACT_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_cust_acct_contact_bo_pub.get_cust_acct_contact_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_cust_acct_contact_id := p_cust_acct_contact_id;
    	l_cust_acct_contact_os := p_cust_acct_contact_os;
    	l_cust_acct_contact_osr := p_cust_acct_contact_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_cust_acct_contact_id,
      		px_os              => l_cust_acct_contact_os,
      		px_osr             => l_cust_acct_contact_osr,
      		p_obj_type         => 'HZ_CUST_ACCOUNT_ROLES',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_ACCT_CONT_BO_PVT.get_cust_acct_contact_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_parent_id => NULL,
		 p_cust_acct_contact_id => l_cust_acct_contact_id,
		 p_action_type => NULL,
		  x_cust_acct_contact_objs => l_cust_acct_contact_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_cust_acct_contact_obj := l_cust_acct_contact_objs(1);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_cust_acct_contact_bo_pub.get_cust_acct_contact_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_contact_bo_pub.get_cust_acct_contact_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_contact_bo_pub.get_cust_acct_contact_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_contact_bo_pub.get_cust_acct_contact_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_cust_acct_contact_bo (
        p_cust_acct_contact_id  IN      NUMBER,
        p_cust_acct_contact_os  IN      VARCHAR2,
        p_cust_acct_contact_osr IN      VARCHAR2,
        x_cust_acct_contact_obj OUT NOCOPY      HZ_CUST_ACCT_CONTACT_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages                      OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data                 VARCHAR2(2000);
    l_msg_count                NUMBER;
  BEGIN
    get_cust_acct_contact_bo (
        p_init_msg_list         => FND_API.G_TRUE,
        p_cust_acct_contact_id  => p_cust_acct_contact_id,
        p_cust_acct_contact_os  => p_cust_acct_contact_os,
        p_cust_acct_contact_osr => p_cust_acct_contact_osr,
        x_cust_acct_contact_obj => x_cust_acct_contact_obj,
        x_return_status         => x_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_cust_acct_contact_bo;

END hz_cust_acct_contact_bo_pub;

/
