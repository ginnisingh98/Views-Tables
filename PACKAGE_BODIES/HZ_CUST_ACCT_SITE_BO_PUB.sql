--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCT_SITE_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCT_SITE_BO_PUB" AS
/*$Header: ARHBCSBB.pls 120.15.12010000.2 2008/10/16 22:27:31 awu ship $ */

  -- PRIVATE PROCEDURE assign_cust_acct_site_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account site object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_site_obj Customer account site object.
  --     p_party_site_id      Party site Id.
  --     p_cust_acct_id       Customer account Id.
  --     p_cust_acct_site_id  Customer account site Id.
  --     p_cust_acct_site_os  Customer account site original system.
  --     p_cust_acct_site_osr Customer account site original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_cust_acct_site_rec Customer Account Site plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_cust_acct_site_rec(
    p_cust_acct_site_obj         IN            HZ_CUST_ACCT_SITE_BO,
    p_party_site_id              IN            NUMBER,
    p_cust_acct_id               IN            NUMBER,
    p_cust_acct_site_id          IN            NUMBER,
    p_cust_acct_site_os          IN            VARCHAR2,
    p_cust_acct_site_osr         IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_cust_acct_site_rec        IN OUT NOCOPY HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_cust_acct_site_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account site object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_site_obj Customer account site object.
  --     p_party_site_id      Party site Id.
  --     p_cust_acct_id       Customer account Id.
  --     p_cust_acct_site_id  Customer account site Id.
  --     p_cust_acct_site_os  Customer account site original system.
  --     p_cust_acct_site_osr Customer account site original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_cust_acct_site_rec Customer Account Site plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_cust_acct_site_rec(
    p_cust_acct_site_obj         IN            HZ_CUST_ACCT_SITE_BO,
    p_party_site_id              IN            NUMBER,
    p_cust_acct_id               IN            NUMBER,
    p_cust_acct_site_id          IN            NUMBER,
    p_cust_acct_site_os          IN            VARCHAR2,
    p_cust_acct_site_osr         IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_cust_acct_site_rec        IN OUT NOCOPY HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE
  ) IS
  BEGIN
    px_cust_acct_site_rec.cust_acct_site_id    := p_cust_acct_site_id;
    px_cust_acct_site_rec.party_site_id        := p_party_site_id;
    px_cust_acct_site_rec.cust_account_id      := p_cust_acct_id;
    px_cust_acct_site_rec.attribute_category   := p_cust_acct_site_obj.attribute_category;
    px_cust_acct_site_rec.attribute1           := p_cust_acct_site_obj.attribute1;
    px_cust_acct_site_rec.attribute2           := p_cust_acct_site_obj.attribute2;
    px_cust_acct_site_rec.attribute3           := p_cust_acct_site_obj.attribute3;
    px_cust_acct_site_rec.attribute4           := p_cust_acct_site_obj.attribute4;
    px_cust_acct_site_rec.attribute5           := p_cust_acct_site_obj.attribute5;
    px_cust_acct_site_rec.attribute6           := p_cust_acct_site_obj.attribute6;
    px_cust_acct_site_rec.attribute7           := p_cust_acct_site_obj.attribute7;
    px_cust_acct_site_rec.attribute8           := p_cust_acct_site_obj.attribute8;
    px_cust_acct_site_rec.attribute9           := p_cust_acct_site_obj.attribute9;
    px_cust_acct_site_rec.attribute10          := p_cust_acct_site_obj.attribute10;
    px_cust_acct_site_rec.attribute11          := p_cust_acct_site_obj.attribute11;
    px_cust_acct_site_rec.attribute12          := p_cust_acct_site_obj.attribute12;
    px_cust_acct_site_rec.attribute13          := p_cust_acct_site_obj.attribute13;
    px_cust_acct_site_rec.attribute14          := p_cust_acct_site_obj.attribute14;
    px_cust_acct_site_rec.attribute15          := p_cust_acct_site_obj.attribute15;
    px_cust_acct_site_rec.attribute16          := p_cust_acct_site_obj.attribute16;
    px_cust_acct_site_rec.attribute17          := p_cust_acct_site_obj.attribute17;
    px_cust_acct_site_rec.attribute18          := p_cust_acct_site_obj.attribute18;
    px_cust_acct_site_rec.attribute19          := p_cust_acct_site_obj.attribute19;
    px_cust_acct_site_rec.attribute20          := p_cust_acct_site_obj.attribute20;
    px_cust_acct_site_rec.global_attribute_category   := p_cust_acct_site_obj.global_attribute_category;
    px_cust_acct_site_rec.global_attribute1    := p_cust_acct_site_obj.global_attribute1;
    px_cust_acct_site_rec.global_attribute2    := p_cust_acct_site_obj.global_attribute2;
    px_cust_acct_site_rec.global_attribute3    := p_cust_acct_site_obj.global_attribute3;
    px_cust_acct_site_rec.global_attribute4    := p_cust_acct_site_obj.global_attribute4;
    px_cust_acct_site_rec.global_attribute5    := p_cust_acct_site_obj.global_attribute5;
    px_cust_acct_site_rec.global_attribute6    := p_cust_acct_site_obj.global_attribute6;
    px_cust_acct_site_rec.global_attribute7    := p_cust_acct_site_obj.global_attribute7;
    px_cust_acct_site_rec.global_attribute8    := p_cust_acct_site_obj.global_attribute8;
    px_cust_acct_site_rec.global_attribute9    := p_cust_acct_site_obj.global_attribute9;
    px_cust_acct_site_rec.global_attribute10   := p_cust_acct_site_obj.global_attribute10;
    px_cust_acct_site_rec.global_attribute11   := p_cust_acct_site_obj.global_attribute11;
    px_cust_acct_site_rec.global_attribute12   := p_cust_acct_site_obj.global_attribute12;
    px_cust_acct_site_rec.global_attribute13   := p_cust_acct_site_obj.global_attribute13;
    px_cust_acct_site_rec.global_attribute14   := p_cust_acct_site_obj.global_attribute14;
    px_cust_acct_site_rec.global_attribute15   := p_cust_acct_site_obj.global_attribute15;
    px_cust_acct_site_rec.global_attribute16   := p_cust_acct_site_obj.global_attribute16;
    px_cust_acct_site_rec.global_attribute17   := p_cust_acct_site_obj.global_attribute17;
    px_cust_acct_site_rec.global_attribute18   := p_cust_acct_site_obj.global_attribute18;
    px_cust_acct_site_rec.global_attribute19   := p_cust_acct_site_obj.global_attribute19;
    px_cust_acct_site_rec.global_attribute20   := p_cust_acct_site_obj.global_attribute20;
    IF(p_cust_acct_site_obj.status in ('A','I')) THEN
      px_cust_acct_site_rec.status                 := p_cust_acct_site_obj.status;
    END IF;
    px_cust_acct_site_rec.customer_category_code := p_cust_acct_site_obj.customer_category_code;
    px_cust_acct_site_rec.language               := p_cust_acct_site_obj.language;
    px_cust_acct_site_rec.key_account_flag       := p_cust_acct_site_obj.key_account_flag;
    px_cust_acct_site_rec.tp_header_id           := p_cust_acct_site_obj.tp_header_id;
    px_cust_acct_site_rec.ece_tp_location_code   := p_cust_acct_site_obj.ece_tp_location_code;
    px_cust_acct_site_rec.primary_specialist_id  := p_cust_acct_site_obj.primary_specialist_id;
    px_cust_acct_site_rec.secondary_specialist_id  := p_cust_acct_site_obj.secondary_specialist_id;
    px_cust_acct_site_rec.territory_id           := p_cust_acct_site_obj.territory_id;
    px_cust_acct_site_rec.territory              := p_cust_acct_site_obj.territory;
    px_cust_acct_site_rec.translated_customer_name := p_cust_acct_site_obj.translated_customer_name;
    IF(p_create_or_update = 'C') THEN
      px_cust_acct_site_rec.orig_system            := p_cust_acct_site_os;
      px_cust_acct_site_rec.orig_system_reference  := p_cust_acct_site_osr;
      px_cust_acct_site_rec.created_by_module    := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_cust_acct_site_rec.org_id               := p_cust_acct_site_obj.org_id;
  END assign_cust_acct_site_rec;

  -- PROCEDURE do_create_cust_acct_site_bo
  --
  -- DESCRIPTION
  --     Create customer account site business object.
  PROCEDURE do_create_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_cust_acct_site_rec       HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE;

    l_ps_id                    NUMBER;
    l_ps_os                    VARCHAR2(30);
    l_ps_osr                   VARCHAR2(255);

    l_acct_party_id            NUMBER;
    l_acct_party_type          VARCHAR2(30);
    l_acct_party_os            VARCHAR2(30);
    l_acct_party_osr           VARCHAR2(255);

    l_valid_obj                BOOLEAN;
    l_bus_object               HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_cbm                      VARCHAR2(30);

    CURSOR get_acct_party(l_acct_id NUMBER) IS
    SELECT p.party_id, decode(p.party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON')
    FROM HZ_PARTIES p, HZ_CUST_ACCOUNTS a
    WHERE p.party_id = a.party_id
    AND a.cust_account_id = l_acct_id;

    CURSOR get_ps_id(l_os VARCHAR2, l_osr VARCHAR2) IS
    SELECT ps.party_site_id
    FROM HZ_PARTY_SITES ps, HZ_ORIG_SYS_REFERENCES ref
    WHERE ref.owner_table_id = ps.party_site_id
    AND ref.owner_table_name = 'HZ_PARTY_SITES'
    AND ref.orig_system = l_os
    AND ref.orig_system_reference = l_osr
    AND ref.status = 'A'
    AND rownum = 1;

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_cas_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Base on p_validate_bo_flag, check the completeness of business objects
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'CUST_ACCT_SITE',
        x_bus_object              => l_bus_object
      );
      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_cas_bo_comp(
                       p_cas_objs   => HZ_CUST_ACCT_SITE_BO_TBL(p_cust_acct_site_obj),
                       p_bus_object => l_bus_object
                     );
      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- check pass in parent_id and parent_os+osr
    hz_registry_validate_bo_pvt.validate_parent_id(
      px_parent_id      => px_parent_acct_id,
      px_parent_os      => px_parent_acct_os,
      px_parent_osr     => px_parent_acct_osr,
      p_parent_obj_type => 'CUST_ACCT',
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- check pass in party_site_id and party_site_os+osr
    l_ps_id := p_cust_acct_site_obj.party_site_id;
    l_ps_os := p_cust_acct_site_obj.party_site_os;
    l_ps_osr := p_cust_acct_site_obj.party_site_osr;

    hz_registry_validate_bo_pvt.validate_parent_id(
      px_parent_id      => l_ps_id,
      px_parent_os      => l_ps_os,
      px_parent_osr     => l_ps_osr,
      p_parent_obj_type => 'PARTY_SITE',
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cust_acct_site_id := p_cust_acct_site_obj.cust_acct_site_id;
    x_cust_acct_site_os := p_cust_acct_site_obj.orig_system;
    x_cust_acct_site_osr := p_cust_acct_site_obj.orig_system_reference;

    -- check if pass in cust_account_site_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cust_acct_site_id,
      px_os              => x_cust_acct_site_os,
      px_osr             => x_cust_acct_site_osr,
      p_org_id           => p_cust_acct_site_obj.org_id,
      p_obj_type         => 'HZ_CUST_ACCT_SITES_ALL',
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- from p_parent_acct_id, get parent party_id of the account, then
    -- use this party_id as px_parent_id of party site
    OPEN get_acct_party(px_parent_acct_id);
    FETCH get_acct_party INTO l_acct_party_id, l_acct_party_type;
    CLOSE get_acct_party;

    IF l_acct_party_id IS NULL THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ----------------------------------
    -- Assign cust account site record
    ----------------------------------
    assign_cust_acct_site_rec(
      p_cust_acct_site_obj        => p_cust_acct_site_obj,
      p_party_site_id             => l_ps_id,
      p_cust_acct_id              => px_parent_acct_id,
      p_cust_acct_site_id         => x_cust_acct_site_id,
      p_cust_acct_site_os         => x_cust_acct_site_os,
      p_cust_acct_site_osr        => x_cust_acct_site_osr,
      px_cust_acct_site_rec       => l_cust_acct_site_rec
    );

    HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site (
      p_cust_acct_site_rec        => l_cust_acct_site_rec,
      x_cust_acct_site_id         => x_cust_acct_site_id,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign cust_acct_site_id
    p_cust_acct_site_obj.cust_acct_site_id := x_cust_acct_site_id;
    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -------------------------------------
    -- Call cust account contact v2pub api
    -------------------------------------
    -- Parent of cust account contact is cust account site
    -- so pass x_cust_acct_site_id, x_cust_acct_site_os and x_cust_acct_site_osr
    IF((p_cust_acct_site_obj.cust_acct_contact_objs IS NOT NULL) AND
       (p_cust_acct_site_obj.cust_acct_contact_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_CONTACT_BO_PVT.save_cust_acct_contacts(
        p_cac_objs           => p_cust_acct_site_obj.cust_acct_contact_objs,
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_id          => x_cust_acct_site_id,
        p_parent_os          => x_cust_acct_site_os,
        p_parent_osr         => x_cust_acct_site_osr,
        p_parent_obj_type    => 'CUST_ACCT_SITE'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -------------------------------------
    -- Call cust account site use v2pub api
    -------------------------------------
    -- create cust account site uses will include cust acct site use plus site use profile
    -- need to put customer account id and customer account site id
    IF((p_cust_acct_site_obj.cust_acct_site_use_objs IS NOT NULL) AND
       (p_cust_acct_site_obj.cust_acct_site_use_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_SITE_BO_PVT.create_cust_site_uses(
        p_casu_objs          => p_cust_acct_site_obj.cust_acct_site_use_objs,
        p_ca_id              => px_parent_acct_id,
        p_cas_id             => x_cust_acct_site_id,
        p_parent_os          => x_cust_acct_site_os,
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_cas_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_cas_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_cas_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_cust_acct_site_bo;

  PROCEDURE create_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  ) IS
    l_cas_obj                 HZ_CUST_ACCT_SITE_BO;
  BEGIN
    l_cas_obj := p_cust_acct_site_obj;
    do_create_cust_acct_site_bo(
      p_init_msg_list           => p_init_msg_list,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_site_obj      => l_cas_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => null,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_cust_acct_site_id       => x_cust_acct_site_id,
      x_cust_acct_site_os       => x_cust_acct_site_os,
      x_cust_acct_site_osr      => x_cust_acct_site_osr,
      px_parent_acct_id         => px_parent_acct_id,
      px_parent_acct_os         => px_parent_acct_os,
      px_parent_acct_osr        => px_parent_acct_osr
    );
  END create_cust_acct_site_bo;

  PROCEDURE create_cust_acct_site_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_cas_obj                 HZ_CUST_ACCT_SITE_BO;
  BEGIN
    l_cas_obj := p_cust_acct_site_obj;
    do_create_cust_acct_site_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_site_obj      => l_cas_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_site_id       => x_cust_acct_site_id,
      x_cust_acct_site_os       => x_cust_acct_site_os,
      x_cust_acct_site_osr      => x_cust_acct_site_osr,
      px_parent_acct_id         => px_parent_acct_id,
      px_parent_acct_os         => px_parent_acct_os,
      px_parent_acct_osr        => px_parent_acct_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_cas_obj;
    END IF;
  END create_cust_acct_site_bo;

  -- PROCEDURE update_cust_acct_site_bo
  --
  -- DESCRIPTION
  --     Update customer account site business object.
  PROCEDURE update_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2
  )IS
    l_cas_obj                 HZ_CUST_ACCT_SITE_BO;
  BEGIN
    l_cas_obj := p_cust_acct_site_obj;
    do_update_cust_acct_site_bo(
      p_init_msg_list           => p_init_msg_list,
      p_cust_acct_site_obj      => l_cas_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => null,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_cust_acct_site_id       => x_cust_acct_site_id,
      x_cust_acct_site_os       => x_cust_acct_site_os,
      x_cust_acct_site_osr      => x_cust_acct_site_osr,
      p_parent_os               => NULL
    );
  END update_cust_acct_site_bo;

  PROCEDURE update_cust_acct_site_bo(
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_cas_obj                 HZ_CUST_ACCT_SITE_BO;
  BEGIN
    l_cas_obj := p_cust_acct_site_obj;
    do_update_cust_acct_site_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_cust_acct_site_obj      => l_cas_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_site_id       => x_cust_acct_site_id,
      x_cust_acct_site_os       => x_cust_acct_site_os,
      x_cust_acct_site_osr      => x_cust_acct_site_osr,
      p_parent_os               => NULL
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_cas_obj;
    END IF;
  END update_cust_acct_site_bo;

  -- PRIVATE PROCEDURE do_update_cust_acct_site_bo
  --
  -- DESCRIPTION
  --     Update customer account site business object.
  PROCEDURE do_update_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    p_parent_os               IN            VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_cust_acct_site_rec       HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE;
    l_cas_ovn                  NUMBER;
    l_create_update_flag       VARCHAR2(1);
    l_parent_os                VARCHAR2(30);
    l_party_site_id            NUMBER;
    l_ca_id                    NUMBER;
    l_ca_os                    VARCHAR2(30);
    l_ca_osr                   VARCHAR2(255);
    l_cbm                      VARCHAR2(30);

    CURSOR get_ovn(l_cas_id NUMBER) IS
    SELECT s.object_version_number, s.cust_account_id, s.party_site_id
    FROM HZ_CUST_ACCT_SITES s
    WHERE s.cust_acct_site_id = l_cas_id;

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_cas_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cas_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -------------------------------
    -- For Update cust acct site
    -------------------------------
    x_cust_acct_site_id := p_cust_acct_site_obj.cust_acct_site_id;
    x_cust_acct_site_os := p_cust_acct_site_obj.orig_system;
    x_cust_acct_site_osr := p_cust_acct_site_obj.orig_system_reference;

    -- validate ssm of cust account site
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cust_acct_site_id,
      px_os              => x_cust_acct_site_os,
      px_osr             => x_cust_acct_site_osr,
      p_org_id           => p_cust_acct_site_obj.org_id,
      p_obj_type         => 'HZ_CUST_ACCT_SITES_ALL',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get object version number of customer acct site
    OPEN get_ovn(x_cust_acct_site_id);
    FETCH get_ovn INTO l_cas_ovn, l_ca_id, l_party_site_id;
    CLOSE get_ovn;

    assign_cust_acct_site_rec(
      p_cust_acct_site_obj        => p_cust_acct_site_obj,
      p_party_site_id             => l_party_site_id,
      p_cust_acct_id              => l_ca_id,
      p_cust_acct_site_id         => x_cust_acct_site_id,
      p_cust_acct_site_os         => x_cust_acct_site_os,
      p_cust_acct_site_osr        => x_cust_acct_site_osr,
      p_create_or_update          => 'U',
      px_cust_acct_site_rec       => l_cust_acct_site_rec
    );

    HZ_CUST_ACCOUNT_SITE_V2PUB.update_cust_acct_site(
      p_cust_acct_site_rec          => l_cust_acct_site_rec,
      p_object_version_number       => l_cas_ovn,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign cust_acct_site_id
    p_cust_acct_site_obj.cust_acct_site_id := x_cust_acct_site_id;
    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -----------------------------------
    -- For cust account contact
    -----------------------------------
    IF((p_cust_acct_site_obj.cust_acct_contact_objs IS NOT NULL) AND
       (p_cust_acct_site_obj.cust_acct_contact_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_CONTACT_BO_PVT.save_cust_acct_contacts(
        p_cac_objs           => p_cust_acct_site_obj.cust_acct_contact_objs,
        p_create_update_flag  => 'U',
        p_obj_source         => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_parent_id           => x_cust_acct_site_id,
        p_parent_os           => x_cust_acct_site_os,
        p_parent_osr          => x_cust_acct_site_osr,
        p_parent_obj_type     => 'CUST_ACCT_SITE'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ----------------------------
    -- For cust account site use
    ----------------------------
    IF((p_cust_acct_site_obj.cust_acct_site_use_objs IS NOT NULL) AND
       (p_cust_acct_site_obj.cust_acct_site_use_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_SITE_BO_PVT.save_cust_site_uses(
        p_casu_objs          => p_cust_acct_site_obj.cust_acct_site_use_objs,
        p_ca_id              => l_ca_id,
        p_cas_id             => x_cust_acct_site_id,
        p_parent_os          => x_cust_acct_site_os,
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_cas_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_cas_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_cas_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_cust_acct_site_bo;

  -- PROCEDURE do_save_cust_acct_site_bo
  --
  -- DESCRIPTION
  --     Create or update customer account site business object.
  PROCEDURE do_save_cust_acct_site_bo(
    p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag         IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_BO,
    p_created_by_module        IN            VARCHAR2,
    p_obj_source               IN            VARCHAR2 := null,
    x_return_status            OUT NOCOPY    VARCHAR2,
    x_msg_count                OUT NOCOPY    NUMBER,
    x_msg_data                 OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id        OUT NOCOPY    NUMBER,
    x_cust_acct_site_os        OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr       OUT NOCOPY    VARCHAR2,
    px_parent_acct_id          IN OUT NOCOPY NUMBER,
    px_parent_acct_os          IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr         IN OUT NOCOPY VARCHAR2
  ) IS
    l_return_status            VARCHAR2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_create_update_flag       VARCHAR2(1);
    l_debug_prefix             VARCHAR2(30) := '';

    CURSOR get_cas_id(l_ps_id NUMBER, l_ca_id NUMBER, l_org_id NUMBER) IS
    SELECT cust_acct_site_id
    FROM HZ_CUST_ACCT_SITES_ALL
    WHERE cust_account_id = l_ca_id
    AND party_site_id = l_ps_id
    AND org_id = l_org_id
    AND rownum = 1;

  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_site_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_cust_acct_site_id := p_cust_acct_site_obj.cust_acct_site_id;
    x_cust_acct_site_os := p_cust_acct_site_obj.orig_system;
    x_cust_acct_site_osr := p_cust_acct_site_obj.orig_system_reference;

    -- AIA enh 7209179
    if p_cust_acct_site_obj.cust_acct_site_id is null and p_cust_acct_site_obj.orig_system = 'ORACLE_AIA'
    then
    	open get_cas_id(p_cust_acct_site_obj.party_site_id,p_cust_acct_site_obj.cust_acct_id,p_cust_acct_site_obj.org_id);
        fetch get_cas_id into x_cust_acct_site_id;
	close get_cas_id;
	if  x_cust_acct_site_id is not null
	then
		x_cust_acct_site_os := null;
		x_cust_acct_site_osr := null;
		p_cust_acct_site_obj.cust_acct_site_id :=  x_cust_acct_site_id;
	        p_cust_acct_site_obj.orig_system := null;
		p_cust_acct_site_obj.orig_system_reference := null;
	end if;
    end if;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => x_cust_acct_site_id,
                              p_entity_os      => x_cust_acct_site_os,
                              p_entity_osr     => x_cust_acct_site_osr,
                              p_entity_type    => 'HZ_CUST_ACCT_SITES_ALL',
                              p_parent_id      => px_parent_acct_id,
                              p_parent_obj_type => 'CUST_ACCT'
                            );
    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_cust_acct_site_bo(
        p_init_msg_list            => fnd_api.g_false,
        p_validate_bo_flag         => p_validate_bo_flag,
        p_cust_acct_site_obj       => p_cust_acct_site_obj,
        p_created_by_module        => p_created_by_module,
        p_obj_source               => p_obj_source,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data,
        x_cust_acct_site_id        => x_cust_acct_site_id,
        x_cust_acct_site_os        => x_cust_acct_site_os,
        x_cust_acct_site_osr       => x_cust_acct_site_osr,
        px_parent_acct_id          => px_parent_acct_id,
        px_parent_acct_os          => px_parent_acct_os,
        px_parent_acct_osr         => px_parent_acct_osr
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_cust_acct_site_bo(
        p_init_msg_list            => fnd_api.g_false,
        p_cust_acct_site_obj       => p_cust_acct_site_obj,
        p_created_by_module        => p_created_by_module,
        p_obj_source               => p_obj_source,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data,
        x_cust_acct_site_id        => x_cust_acct_site_id,
        x_cust_acct_site_os        => x_cust_acct_site_os,
        x_cust_acct_site_osr       => x_cust_acct_site_osr,
        p_parent_os                => px_parent_acct_os
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_site_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_site_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_site_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_cust_acct_site_bo;

  PROCEDURE save_cust_acct_site_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  ) IS
    l_cas_obj                 HZ_CUST_ACCT_SITE_BO;
  BEGIN
    l_cas_obj := p_cust_acct_site_obj;
    do_save_cust_acct_site_bo(
      p_init_msg_list           => p_init_msg_list,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_site_obj      => l_cas_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => null,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_cust_acct_site_id       => x_cust_acct_site_id,
      x_cust_acct_site_os       => x_cust_acct_site_os,
      x_cust_acct_site_osr      => x_cust_acct_site_osr,
      px_parent_acct_id         => px_parent_acct_id,
      px_parent_acct_os         => px_parent_acct_os,
      px_parent_acct_osr        => px_parent_acct_osr
    );
  END save_cust_acct_site_bo;

  PROCEDURE save_cust_acct_site_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_obj      IN            HZ_CUST_ACCT_SITE_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_cas_obj                 HZ_CUST_ACCT_SITE_BO;
  BEGIN
    l_cas_obj := p_cust_acct_site_obj;
    do_save_cust_acct_site_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_site_obj      => l_cas_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_site_id       => x_cust_acct_site_id,
      x_cust_acct_site_os       => x_cust_acct_site_os,
      x_cust_acct_site_osr      => x_cust_acct_site_osr,
      px_parent_acct_id         => px_parent_acct_id,
      px_parent_acct_os         => px_parent_acct_os,
      px_parent_acct_osr        => px_parent_acct_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_cas_obj;
    END IF;
  END save_cust_acct_site_bo;

 --------------------------------------
  --
  -- PROCEDURE get_cust_acct_site_bo
  --
  -- DESCRIPTION
  --     Get logical customer account site.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_parent_id          parent id.
--       p_cust_acct_site_id          customer account site ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_site_obj         Logical customer account site record.
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

The Get customer account site API Procedure is a retrieval service that returns a full customer account site business object.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's Source System
information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels. This includes the
set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments

Party Site			Y	N	get_party_site_bo
Customer Account Site Contact	N	Y	get_cust_acct_contact_bo
Customer Account Site Use	N	Y	Business Structure. Included entities and
						structures:HZ_CUST_SITE_USES_ALL,Customer
						Profile (Business Structure)


To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns all records
for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer account site	Y		N	HZ_CUST_ACCOUNTS
Bank account site Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/


PROCEDURE get_cust_acct_site_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_cust_acct_site_id	IN	NUMBER,
	p_cust_acct_site_os	IN	VARCHAR2,
	p_cust_acct_site_osr	IN	VARCHAR2,
	x_cust_acct_site_obj	OUT NOCOPY	HZ_CUST_ACCT_SITE_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_cust_acct_site_id  number;
  l_cust_acct_site_os  varchar2(30);
  l_cust_acct_site_osr varchar2(255);
  l_cust_acct_site_objs  HZ_CUST_ACCT_SITE_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_cust_acct_site_bo_pub.get_cust_acct_site_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_cust_acct_site_id := p_cust_acct_site_id;
    	l_cust_acct_site_os := p_cust_acct_site_os;
    	l_cust_acct_site_osr := p_cust_acct_site_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_cust_acct_site_id,
      		px_os              => l_cust_acct_site_os,
      		px_osr             => l_cust_acct_site_osr,
      		p_obj_type         => 'HZ_CUST_ACCT_SITES_ALL',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_ACCT_SITE_BO_PVT.get_cust_acct_site_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_parent_id => NULL,
		 p_cust_acct_site_id => l_cust_acct_site_id,
		 p_action_type => NULL,
		  x_cust_acct_site_objs => l_cust_acct_site_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_cust_acct_site_obj := l_cust_acct_site_objs(1);

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
        	hz_utility_v2pub.debug(p_message=>'hz_cust_acct_site_bo_pub.get_cust_acct_site_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_site_bo_pub.get_cust_acct_site_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_site_bo_pub.get_cust_acct_site_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_site_bo_pub.get_cust_acct_site_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_cust_acct_site_bo (
        p_cust_acct_site_id     IN      NUMBER,
        p_cust_acct_site_os     IN      VARCHAR2,
        p_cust_acct_site_osr    IN      VARCHAR2,
        x_cust_acct_site_obj    OUT NOCOPY      HZ_CUST_ACCT_SITE_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages              OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data                 VARCHAR2(2000);
    l_msg_count                NUMBER;
  BEGIN
    get_cust_acct_site_bo (
        p_init_msg_list         => FND_API.G_TRUE,
        p_cust_acct_site_id     => p_cust_acct_site_id,
        p_cust_acct_site_os     => p_cust_acct_site_os,
        p_cust_acct_site_osr    => p_cust_acct_site_osr,
        x_cust_acct_site_obj    => x_cust_acct_site_obj,
        x_return_status         => x_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_cust_acct_site_bo;

-- PRIVATE PROCEDURE assign_cust_acct_site_v2_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account site object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_site_v2_obj Customer account site object.
  --     p_party_site_id      Party site Id.
  --     p_cust_acct_id       Customer account Id.
  --     p_cust_acct_site_id  Customer account site Id.
  --     p_cust_acct_site_os  Customer account site original system.
  --     p_cust_acct_site_osr Customer account site original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_cust_acct_site_rec Customer Account Site plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-JAN-2008    vsegu          Created.
  --

  PROCEDURE assign_cust_acct_site_v2_rec(
    p_cust_acct_site_v2_obj         IN            HZ_CUST_ACCT_SITE_V2_BO,
    p_party_site_id              IN            NUMBER,
    p_cust_acct_id               IN            NUMBER,
    p_cust_acct_site_id          IN            NUMBER,
    p_cust_acct_site_os          IN            VARCHAR2,
    p_cust_acct_site_osr         IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_cust_acct_site_rec        IN OUT NOCOPY HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_cust_acct_site_v2_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account site object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_site_v2_obj Customer account site object.
  --     p_party_site_id      Party site Id.
  --     p_cust_acct_id       Customer account Id.
  --     p_cust_acct_site_id  Customer account site Id.
  --     p_cust_acct_site_os  Customer account site original system.
  --     p_cust_acct_site_osr Customer account site original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_cust_acct_site_rec Customer Account Site plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-JAN-2008    vsegu          Created.
  --

  PROCEDURE assign_cust_acct_site_v2_rec(
    p_cust_acct_site_v2_obj         IN            HZ_CUST_ACCT_SITE_V2_BO,
    p_party_site_id              IN            NUMBER,
    p_cust_acct_id               IN            NUMBER,
    p_cust_acct_site_id          IN            NUMBER,
    p_cust_acct_site_os          IN            VARCHAR2,
    p_cust_acct_site_osr         IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_cust_acct_site_rec        IN OUT NOCOPY HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE
  ) IS
  BEGIN
    px_cust_acct_site_rec.cust_acct_site_id    := p_cust_acct_site_id;
    px_cust_acct_site_rec.party_site_id        := p_party_site_id;
    px_cust_acct_site_rec.cust_account_id      := p_cust_acct_id;
    px_cust_acct_site_rec.attribute_category   := p_cust_acct_site_v2_obj.attribute_category;
    px_cust_acct_site_rec.attribute1           := p_cust_acct_site_v2_obj.attribute1;
    px_cust_acct_site_rec.attribute2           := p_cust_acct_site_v2_obj.attribute2;
    px_cust_acct_site_rec.attribute3           := p_cust_acct_site_v2_obj.attribute3;
    px_cust_acct_site_rec.attribute4           := p_cust_acct_site_v2_obj.attribute4;
    px_cust_acct_site_rec.attribute5           := p_cust_acct_site_v2_obj.attribute5;
    px_cust_acct_site_rec.attribute6           := p_cust_acct_site_v2_obj.attribute6;
    px_cust_acct_site_rec.attribute7           := p_cust_acct_site_v2_obj.attribute7;
    px_cust_acct_site_rec.attribute8           := p_cust_acct_site_v2_obj.attribute8;
    px_cust_acct_site_rec.attribute9           := p_cust_acct_site_v2_obj.attribute9;
    px_cust_acct_site_rec.attribute10          := p_cust_acct_site_v2_obj.attribute10;
    px_cust_acct_site_rec.attribute11          := p_cust_acct_site_v2_obj.attribute11;
    px_cust_acct_site_rec.attribute12          := p_cust_acct_site_v2_obj.attribute12;
    px_cust_acct_site_rec.attribute13          := p_cust_acct_site_v2_obj.attribute13;
    px_cust_acct_site_rec.attribute14          := p_cust_acct_site_v2_obj.attribute14;
    px_cust_acct_site_rec.attribute15          := p_cust_acct_site_v2_obj.attribute15;
    px_cust_acct_site_rec.attribute16          := p_cust_acct_site_v2_obj.attribute16;
    px_cust_acct_site_rec.attribute17          := p_cust_acct_site_v2_obj.attribute17;
    px_cust_acct_site_rec.attribute18          := p_cust_acct_site_v2_obj.attribute18;
    px_cust_acct_site_rec.attribute19          := p_cust_acct_site_v2_obj.attribute19;
    px_cust_acct_site_rec.attribute20          := p_cust_acct_site_v2_obj.attribute20;
    px_cust_acct_site_rec.global_attribute_category   := p_cust_acct_site_v2_obj.global_attribute_category;
    px_cust_acct_site_rec.global_attribute1    := p_cust_acct_site_v2_obj.global_attribute1;
    px_cust_acct_site_rec.global_attribute2    := p_cust_acct_site_v2_obj.global_attribute2;
    px_cust_acct_site_rec.global_attribute3    := p_cust_acct_site_v2_obj.global_attribute3;
    px_cust_acct_site_rec.global_attribute4    := p_cust_acct_site_v2_obj.global_attribute4;
    px_cust_acct_site_rec.global_attribute5    := p_cust_acct_site_v2_obj.global_attribute5;
    px_cust_acct_site_rec.global_attribute6    := p_cust_acct_site_v2_obj.global_attribute6;
    px_cust_acct_site_rec.global_attribute7    := p_cust_acct_site_v2_obj.global_attribute7;
    px_cust_acct_site_rec.global_attribute8    := p_cust_acct_site_v2_obj.global_attribute8;
    px_cust_acct_site_rec.global_attribute9    := p_cust_acct_site_v2_obj.global_attribute9;
    px_cust_acct_site_rec.global_attribute10   := p_cust_acct_site_v2_obj.global_attribute10;
    px_cust_acct_site_rec.global_attribute11   := p_cust_acct_site_v2_obj.global_attribute11;
    px_cust_acct_site_rec.global_attribute12   := p_cust_acct_site_v2_obj.global_attribute12;
    px_cust_acct_site_rec.global_attribute13   := p_cust_acct_site_v2_obj.global_attribute13;
    px_cust_acct_site_rec.global_attribute14   := p_cust_acct_site_v2_obj.global_attribute14;
    px_cust_acct_site_rec.global_attribute15   := p_cust_acct_site_v2_obj.global_attribute15;
    px_cust_acct_site_rec.global_attribute16   := p_cust_acct_site_v2_obj.global_attribute16;
    px_cust_acct_site_rec.global_attribute17   := p_cust_acct_site_v2_obj.global_attribute17;
    px_cust_acct_site_rec.global_attribute18   := p_cust_acct_site_v2_obj.global_attribute18;
    px_cust_acct_site_rec.global_attribute19   := p_cust_acct_site_v2_obj.global_attribute19;
    px_cust_acct_site_rec.global_attribute20   := p_cust_acct_site_v2_obj.global_attribute20;
    IF(p_cust_acct_site_v2_obj.status in ('A','I')) THEN
      px_cust_acct_site_rec.status                 := p_cust_acct_site_v2_obj.status;
    END IF;
    px_cust_acct_site_rec.customer_category_code := p_cust_acct_site_v2_obj.customer_category_code;
    px_cust_acct_site_rec.language               := p_cust_acct_site_v2_obj.language;
    px_cust_acct_site_rec.key_account_flag       := p_cust_acct_site_v2_obj.key_account_flag;
    px_cust_acct_site_rec.tp_header_id           := p_cust_acct_site_v2_obj.tp_header_id;
    px_cust_acct_site_rec.ece_tp_location_code   := p_cust_acct_site_v2_obj.ece_tp_location_code;
    px_cust_acct_site_rec.primary_specialist_id  := p_cust_acct_site_v2_obj.primary_specialist_id;
    px_cust_acct_site_rec.secondary_specialist_id  := p_cust_acct_site_v2_obj.secondary_specialist_id;
    px_cust_acct_site_rec.territory_id           := p_cust_acct_site_v2_obj.territory_id;
    px_cust_acct_site_rec.territory              := p_cust_acct_site_v2_obj.territory;
    px_cust_acct_site_rec.translated_customer_name := p_cust_acct_site_v2_obj.translated_customer_name;
    IF(p_create_or_update = 'C') THEN
      px_cust_acct_site_rec.orig_system            := p_cust_acct_site_os;
      px_cust_acct_site_rec.orig_system_reference  := p_cust_acct_site_osr;
      px_cust_acct_site_rec.created_by_module    := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_cust_acct_site_rec.org_id               := p_cust_acct_site_v2_obj.org_id;
  END assign_cust_acct_site_v2_rec;

 -- PROCEDURE do_create_cust_acct_site_v2_bo
  --
  -- DESCRIPTION
  --     Create customer account site business object.
  PROCEDURE do_create_cust_acct_site_v2_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_v2_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_cust_acct_site_rec       HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE;

    l_ps_id                    NUMBER;
    l_ps_os                    VARCHAR2(30);
    l_ps_osr                   VARCHAR2(255);

    l_acct_party_id            NUMBER;
    l_acct_party_type          VARCHAR2(30);
    l_acct_party_os            VARCHAR2(30);
    l_acct_party_osr           VARCHAR2(255);

    l_valid_obj                BOOLEAN;
    l_bus_object               HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_cbm                      VARCHAR2(30);

    CURSOR get_acct_party(l_acct_id NUMBER) IS
    SELECT p.party_id, decode(p.party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON')
    FROM HZ_PARTIES p, HZ_CUST_ACCOUNTS a
    WHERE p.party_id = a.party_id
    AND a.cust_account_id = l_acct_id;

    CURSOR get_ps_id(l_os VARCHAR2, l_osr VARCHAR2) IS
    SELECT ps.party_site_id
    FROM HZ_PARTY_SITES ps, HZ_ORIG_SYS_REFERENCES ref
    WHERE ref.owner_table_id = ps.party_site_id
    AND ref.owner_table_name = 'HZ_PARTY_SITES'
    AND ref.orig_system = l_os
    AND ref.orig_system_reference = l_osr
    AND ref.status = 'A'
    AND rownum = 1;

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_cas_v2_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site_v2_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Base on p_validate_bo_flag, check the completeness of business objects
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'CUST_ACCT_SITE',
        x_bus_object              => l_bus_object
      );
      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_cas_v2_bo_comp(
                       p_cas_v2_objs   => HZ_CUST_ACCT_SITE_V2_BO_TBL(p_cust_acct_site_v2_obj),
                       p_bus_object => l_bus_object
                     );
      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- check pass in parent_id and parent_os+osr
    hz_registry_validate_bo_pvt.validate_parent_id(
      px_parent_id      => px_parent_acct_id,
      px_parent_os      => px_parent_acct_os,
      px_parent_osr     => px_parent_acct_osr,
      p_parent_obj_type => 'CUST_ACCT',
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- check pass in party_site_id and party_site_os+osr
    l_ps_id := p_cust_acct_site_v2_obj.party_site_id;
    l_ps_os := p_cust_acct_site_v2_obj.party_site_os;
    l_ps_osr := p_cust_acct_site_v2_obj.party_site_osr;

    hz_registry_validate_bo_pvt.validate_parent_id(
      px_parent_id      => l_ps_id,
      px_parent_os      => l_ps_os,
      px_parent_osr     => l_ps_osr,
      p_parent_obj_type => 'PARTY_SITE',
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cust_acct_site_id := p_cust_acct_site_v2_obj.cust_acct_site_id;
    x_cust_acct_site_os := p_cust_acct_site_v2_obj.orig_system;
    x_cust_acct_site_osr := p_cust_acct_site_v2_obj.orig_system_reference;

    -- check if pass in cust_account_site_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cust_acct_site_id,
      px_os              => x_cust_acct_site_os,
      px_osr             => x_cust_acct_site_osr,
      p_org_id           => p_cust_acct_site_v2_obj.org_id,
      p_obj_type         => 'HZ_CUST_ACCT_SITES_ALL',
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- from p_parent_acct_id, get parent party_id of the account, then
    -- use this party_id as px_parent_id of party site
    OPEN get_acct_party(px_parent_acct_id);
    FETCH get_acct_party INTO l_acct_party_id, l_acct_party_type;
    CLOSE get_acct_party;

    IF l_acct_party_id IS NULL THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ----------------------------------
    -- Assign cust account site record
    ----------------------------------
    assign_cust_acct_site_v2_rec(
      p_cust_acct_site_v2_obj        => p_cust_acct_site_v2_obj,
      p_party_site_id             => l_ps_id,
      p_cust_acct_id              => px_parent_acct_id,
      p_cust_acct_site_id         => x_cust_acct_site_id,
      p_cust_acct_site_os         => x_cust_acct_site_os,
      p_cust_acct_site_osr        => x_cust_acct_site_osr,
      px_cust_acct_site_rec       => l_cust_acct_site_rec
    );

    HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site (
      p_cust_acct_site_rec        => l_cust_acct_site_rec,
      x_cust_acct_site_id         => x_cust_acct_site_id,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign cust_acct_site_id
    p_cust_acct_site_v2_obj.cust_acct_site_id := x_cust_acct_site_id;
    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -------------------------------------
    -- Call cust account contact v2pub api
    -------------------------------------
    -- Parent of cust account contact is cust account site
    -- so pass x_cust_acct_site_id, x_cust_acct_site_os and x_cust_acct_site_osr
    IF((p_cust_acct_site_v2_obj.cust_acct_contact_objs IS NOT NULL) AND
       (p_cust_acct_site_v2_obj.cust_acct_contact_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_CONTACT_BO_PVT.save_cust_acct_contacts(
        p_cac_objs           => p_cust_acct_site_v2_obj.cust_acct_contact_objs,
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_id          => x_cust_acct_site_id,
        p_parent_os          => x_cust_acct_site_os,
        p_parent_osr         => x_cust_acct_site_osr,
        p_parent_obj_type    => 'CUST_ACCT_SITE'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -------------------------------------
    -- Call cust account site use v2pub api
    -------------------------------------
    -- create cust account site uses will include cust acct site use plus site use profile
    -- need to put customer account id and customer account site id
    IF((p_cust_acct_site_v2_obj.cust_acct_site_use_objs IS NOT NULL) AND
       (p_cust_acct_site_v2_obj.cust_acct_site_use_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_SITE_BO_PVT.create_cust_site_v2_uses(
        p_casu_v2_objs          => p_cust_acct_site_v2_obj.cust_acct_site_use_objs,
        p_ca_id              => px_parent_acct_id,
        p_cas_id             => x_cust_acct_site_id,
        p_parent_os          => x_cust_acct_site_os,
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_cas_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_cas_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_cas_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_site_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_cust_acct_site_v2_bo;


 PROCEDURE create_cust_acct_site_v2_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_v2_obj      IN            HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_V2_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_cas_obj                 HZ_CUST_ACCT_SITE_V2_BO;
  BEGIN
    l_cas_obj := p_cust_acct_site_v2_obj;
    do_create_cust_acct_site_v2_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_site_v2_obj      => l_cas_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_site_id       => x_cust_acct_site_id,
      x_cust_acct_site_os       => x_cust_acct_site_os,
      x_cust_acct_site_osr      => x_cust_acct_site_osr,
      px_parent_acct_id         => px_parent_acct_id,
      px_parent_acct_os         => px_parent_acct_os,
      px_parent_acct_osr        => px_parent_acct_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_cas_obj;
    END IF;
  END create_cust_acct_site_v2_bo;

 -- PRIVATE PROCEDURE do_update_cust_acct_site_v2_bo
  --
  -- DESCRIPTION
  --     Update customer account site business object.
  PROCEDURE do_update_cust_acct_site_v2_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_v2_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    p_parent_os               IN            VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_cust_acct_site_rec       HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE;
    l_cas_ovn                  NUMBER;
    l_create_update_flag       VARCHAR2(1);
    l_parent_os                VARCHAR2(30);
    l_party_site_id            NUMBER;
    l_ca_id                    NUMBER;
    l_ca_os                    VARCHAR2(30);
    l_ca_osr                   VARCHAR2(255);
    l_cbm                      VARCHAR2(30);

    CURSOR get_ovn(l_cas_id NUMBER) IS
    SELECT s.object_version_number, s.cust_account_id, s.party_site_id
    FROM HZ_CUST_ACCT_SITES s
    WHERE s.cust_acct_site_id = l_cas_id;

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_cas_v2_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cas_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -------------------------------
    -- For Update cust acct site
    -------------------------------
    x_cust_acct_site_id := p_cust_acct_site_v2_obj.cust_acct_site_id;
    x_cust_acct_site_os := p_cust_acct_site_v2_obj.orig_system;
    x_cust_acct_site_osr := p_cust_acct_site_v2_obj.orig_system_reference;

    -- validate ssm of cust account site
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cust_acct_site_id,
      px_os              => x_cust_acct_site_os,
      px_osr             => x_cust_acct_site_osr,
      p_org_id           => p_cust_acct_site_v2_obj.org_id,
      p_obj_type         => 'HZ_CUST_ACCT_SITES_ALL',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get object version number of customer acct site
    OPEN get_ovn(x_cust_acct_site_id);
    FETCH get_ovn INTO l_cas_ovn, l_ca_id, l_party_site_id;
    CLOSE get_ovn;

    assign_cust_acct_site_v2_rec(
      p_cust_acct_site_v2_obj        => p_cust_acct_site_v2_obj,
      p_party_site_id             => l_party_site_id,
      p_cust_acct_id              => l_ca_id,
      p_cust_acct_site_id         => x_cust_acct_site_id,
      p_cust_acct_site_os         => x_cust_acct_site_os,
      p_cust_acct_site_osr        => x_cust_acct_site_osr,
      p_create_or_update          => 'U',
      px_cust_acct_site_rec       => l_cust_acct_site_rec
    );

    HZ_CUST_ACCOUNT_SITE_V2PUB.update_cust_acct_site(
      p_cust_acct_site_rec          => l_cust_acct_site_rec,
      p_object_version_number       => l_cas_ovn,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign cust_acct_site_id
    p_cust_acct_site_v2_obj.cust_acct_site_id := x_cust_acct_site_id;
    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -----------------------------------
    -- For cust account contact
    -----------------------------------
    IF((p_cust_acct_site_v2_obj.cust_acct_contact_objs IS NOT NULL) AND
       (p_cust_acct_site_v2_obj.cust_acct_contact_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_CONTACT_BO_PVT.save_cust_acct_contacts(
        p_cac_objs           => p_cust_acct_site_v2_obj.cust_acct_contact_objs,
        p_create_update_flag  => 'U',
        p_obj_source         => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_parent_id           => x_cust_acct_site_id,
        p_parent_os           => x_cust_acct_site_os,
        p_parent_osr          => x_cust_acct_site_osr,
        p_parent_obj_type     => 'CUST_ACCT_SITE'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ----------------------------
    -- For cust account site use
    ----------------------------
    IF((p_cust_acct_site_v2_obj.cust_acct_site_use_objs IS NOT NULL) AND
       (p_cust_acct_site_v2_obj.cust_acct_site_use_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_SITE_BO_PVT.save_cust_site_v2_uses(
        p_casu_v2_objs          => p_cust_acct_site_v2_obj.cust_acct_site_use_objs,
        p_ca_id              => l_ca_id,
        p_cas_id             => x_cust_acct_site_id,
        p_parent_os          => x_cust_acct_site_os,
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_site_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_cas_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_site_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_cas_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_site_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_cas_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_site_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_cust_acct_site_v2_bo;

PROCEDURE update_cust_acct_site_v2_bo(
    p_cust_acct_site_v2_obj      IN            HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_V2_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_cas_obj                 HZ_CUST_ACCT_SITE_V2_BO;
  BEGIN
    l_cas_obj := p_cust_acct_site_v2_obj;
    do_update_cust_acct_site_v2_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_cust_acct_site_v2_obj      => l_cas_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_site_id       => x_cust_acct_site_id,
      x_cust_acct_site_os       => x_cust_acct_site_os,
      x_cust_acct_site_osr      => x_cust_acct_site_osr,
      p_parent_os               => NULL
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_cas_obj;
    END IF;
  END update_cust_acct_site_v2_bo;

-- PROCEDURE do_save_cust_acct_site_v2_bo
  --
  -- DESCRIPTION
  --     Create or update customer account site business object.
  PROCEDURE do_save_cust_acct_site_v2_bo(
    p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag         IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_v2_obj      IN OUT NOCOPY HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module        IN            VARCHAR2,
    p_obj_source               IN            VARCHAR2 := null,
    x_return_status            OUT NOCOPY    VARCHAR2,
    x_msg_count                OUT NOCOPY    NUMBER,
    x_msg_data                 OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_id        OUT NOCOPY    NUMBER,
    x_cust_acct_site_os        OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr       OUT NOCOPY    VARCHAR2,
    px_parent_acct_id          IN OUT NOCOPY NUMBER,
    px_parent_acct_os          IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr         IN OUT NOCOPY VARCHAR2
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_site_v2_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_cust_acct_site_id := p_cust_acct_site_v2_obj.cust_acct_site_id;
    x_cust_acct_site_os := p_cust_acct_site_v2_obj.orig_system;
    x_cust_acct_site_osr := p_cust_acct_site_v2_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => x_cust_acct_site_id,
                              p_entity_os      => x_cust_acct_site_os,
                              p_entity_osr     => x_cust_acct_site_osr,
                              p_entity_type    => 'HZ_CUST_ACCT_SITES_ALL',
                              p_parent_id      => px_parent_acct_id,
                              p_parent_obj_type => 'CUST_ACCT'
                            );
    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT_SITE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_cust_acct_site_v2_bo(
        p_init_msg_list            => fnd_api.g_false,
        p_validate_bo_flag         => p_validate_bo_flag,
        p_cust_acct_site_v2_obj       => p_cust_acct_site_v2_obj,
        p_created_by_module        => p_created_by_module,
        p_obj_source               => p_obj_source,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data,
        x_cust_acct_site_id        => x_cust_acct_site_id,
        x_cust_acct_site_os        => x_cust_acct_site_os,
        x_cust_acct_site_osr       => x_cust_acct_site_osr,
        px_parent_acct_id          => px_parent_acct_id,
        px_parent_acct_os          => px_parent_acct_os,
        px_parent_acct_osr         => px_parent_acct_osr
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_cust_acct_site_v2_bo(
        p_init_msg_list            => fnd_api.g_false,
        p_cust_acct_site_v2_obj       => p_cust_acct_site_v2_obj,
        p_created_by_module        => p_created_by_module,
        p_obj_source               => p_obj_source,
        x_return_status            => x_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data,
        x_cust_acct_site_id        => x_cust_acct_site_id,
        x_cust_acct_site_os        => x_cust_acct_site_os,
        x_cust_acct_site_osr       => x_cust_acct_site_osr,
        p_parent_os                => px_parent_acct_os
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_site_v2_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_site_v2_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_site_v2_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_site_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_cust_acct_site_v2_bo;

PROCEDURE save_cust_acct_site_v2_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_site_v2_obj      IN            HZ_CUST_ACCT_SITE_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_SITE_V2_BO,
    x_cust_acct_site_id       OUT NOCOPY    NUMBER,
    x_cust_acct_site_os       OUT NOCOPY    VARCHAR2,
    x_cust_acct_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_acct_id         IN OUT NOCOPY NUMBER,
    px_parent_acct_os         IN OUT NOCOPY VARCHAR2,
    px_parent_acct_osr        IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_cas_obj                 HZ_CUST_ACCT_SITE_V2_BO;
  BEGIN
    l_cas_obj := p_cust_acct_site_v2_obj;
    do_save_cust_acct_site_v2_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_site_v2_obj      => l_cas_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_site_id       => x_cust_acct_site_id,
      x_cust_acct_site_os       => x_cust_acct_site_os,
      x_cust_acct_site_osr      => x_cust_acct_site_osr,
      px_parent_acct_id         => px_parent_acct_id,
      px_parent_acct_os         => px_parent_acct_os,
      px_parent_acct_osr        => px_parent_acct_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_cas_obj;
    END IF;
  END save_cust_acct_site_v2_bo;

 --------------------------------------
  --
  -- PROCEDURE get_cust_acct_site_v2_bo
  --
  -- DESCRIPTION
  --     Get logical customer account site.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_parent_id          parent id.
--       p_cust_acct_site_id          customer account site ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_site_v2_obj         Logical customer account site record.
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
  --   31-JUN-2008   vsegu                Created.
  --

/*

The Get customer account site API Procedure is a retrieval service that returns a full customer account site business object.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's Source System
information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels. This includes the
set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments

Party Site			Y	N	get_party_site_bo
Customer Account Site Contact	N	Y	get_cust_acct_contact_bo
Customer Account Site Use	N	Y	Business Structure. Included entities and
						structures:HZ_CUST_SITE_USES_ALL,Customer
						Profile (Business Structure)


To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns all records
for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer account site	Y		N	HZ_CUST_ACCOUNTS
Bank account site Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/


PROCEDURE get_cust_acct_site_v2_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_cust_acct_site_id	IN	NUMBER,
	p_cust_acct_site_os	IN	VARCHAR2,
	p_cust_acct_site_osr	IN	VARCHAR2,
	x_cust_acct_site_v2_obj	OUT NOCOPY	HZ_CUST_ACCT_SITE_V2_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_cust_acct_site_id  number;
  l_cust_acct_site_os  varchar2(30);
  l_cust_acct_site_osr varchar2(255);
  l_cust_acct_site_v2_objs  HZ_CUST_ACCT_SITE_V2_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_cust_acct_site_bo_pub.get_cust_acct_site_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_cust_acct_site_id := p_cust_acct_site_id;
    	l_cust_acct_site_os := p_cust_acct_site_os;
    	l_cust_acct_site_osr := p_cust_acct_site_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_cust_acct_site_id,
      		px_os              => l_cust_acct_site_os,
      		px_osr             => l_cust_acct_site_osr,
      		p_obj_type         => 'HZ_CUST_ACCT_SITES_ALL',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_ACCT_SITE_BO_PVT.get_cust_acct_site_v2_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_parent_id => NULL,
		 p_cust_acct_site_id => l_cust_acct_site_id,
		 p_action_type => NULL,
		  x_cust_acct_site_v2_objs => l_cust_acct_site_v2_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_cust_acct_site_v2_obj := l_cust_acct_site_v2_objs(1);

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
        	hz_utility_v2pub.debug(p_message=>'hz_cust_acct_site_bo_pub.get_cust_acct_site_v2_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_site_bo_pub.get_cust_acct_site_v2_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_site_bo_pub.get_cust_acct_site_v2_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_site_bo_pub.get_cust_acct_site_v2_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_cust_acct_site_v2_bo (
        p_cust_acct_site_id     IN      NUMBER,
        p_cust_acct_site_os     IN      VARCHAR2,
        p_cust_acct_site_osr    IN      VARCHAR2,
        x_cust_acct_site_v2_obj    OUT NOCOPY      HZ_CUST_ACCT_SITE_V2_BO,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages              OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data                 VARCHAR2(2000);
    l_msg_count                NUMBER;
  BEGIN
    get_cust_acct_site_v2_bo (
        p_init_msg_list         => FND_API.G_TRUE,
        p_cust_acct_site_id     => p_cust_acct_site_id,
        p_cust_acct_site_os     => p_cust_acct_site_os,
        p_cust_acct_site_osr    => p_cust_acct_site_osr,
        x_cust_acct_site_v2_obj    => x_cust_acct_site_v2_obj,
        x_return_status         => x_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_cust_acct_site_v2_bo;

END hz_cust_acct_site_bo_pub;

/
