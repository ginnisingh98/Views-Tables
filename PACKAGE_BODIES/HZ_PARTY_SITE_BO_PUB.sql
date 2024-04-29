--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_SITE_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_SITE_BO_PUB" AS
/*$Header: ARHBPSBB.pls 120.19 2006/05/18 22:27:56 acng noship $ */

  -- PRIVATE PROCEDURE assign_party_site_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from party site object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_site_obj     Party site business object.
  --     p_party_id           Party Id.
  --     p_location_id        Location Id.
  --     p_ps_id              Party site Id.
  --     p_ps_os              Party site original system.
  --     p_ps_osr             Party site original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_party_site_rec    Party site plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_party_site_rec(
    p_party_site_obj             IN            HZ_PARTY_SITE_BO,
    p_party_id                   IN            NUMBER,
    p_location_id                IN            NUMBER,
    p_ps_id                      IN            NUMBER,
    p_ps_os                      IN            VARCHAR2,
    p_ps_osr                     IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_party_site_rec            IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_party_site_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from party site object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_site_obj     Party site business object.
  --     p_party_id           Party Id.
  --     p_location_id        Location Id.
  --     p_ps_id              Party site Id.
  --     p_ps_os              Party site original system.
  --     p_ps_osr             Party site original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_party_site_rec    Party site plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_party_site_rec(
    p_party_site_obj             IN            HZ_PARTY_SITE_BO,
    p_party_id                   IN            NUMBER,
    p_location_id                IN            NUMBER,
    p_ps_id                      IN            NUMBER,
    p_ps_os                      IN            VARCHAR2,
    p_ps_osr                     IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_party_site_rec            IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE
  ) IS
  BEGIN
    px_party_site_rec.party_site_id := p_ps_id;
    px_party_site_rec.party_id := p_party_id;
    px_party_site_rec.location_id := p_location_id;
    px_party_site_rec.party_site_number := p_party_site_obj.party_site_number;
    px_party_site_rec.mailstop := p_party_site_obj.mailstop;
    IF(p_party_site_obj.identifying_address_flag in ('Y','N')) THEN
      px_party_site_rec.identifying_address_flag := p_party_site_obj.identifying_address_flag;
    END IF;
    IF(p_party_site_obj.status in ('A','I')) THEN
      px_party_site_rec.status := p_party_site_obj.status;
    END IF;
    px_party_site_rec.party_site_name := p_party_site_obj.party_site_name;
    px_party_site_rec.attribute_category := p_party_site_obj.attribute_category;
    px_party_site_rec.attribute1 := p_party_site_obj.attribute1;
    px_party_site_rec.attribute2 := p_party_site_obj.attribute2;
    px_party_site_rec.attribute3 := p_party_site_obj.attribute3;
    px_party_site_rec.attribute4 := p_party_site_obj.attribute4;
    px_party_site_rec.attribute5 := p_party_site_obj.attribute5;
    px_party_site_rec.attribute6 := p_party_site_obj.attribute6;
    px_party_site_rec.attribute7 := p_party_site_obj.attribute7;
    px_party_site_rec.attribute8 := p_party_site_obj.attribute8;
    px_party_site_rec.attribute9 := p_party_site_obj.attribute9;
    px_party_site_rec.attribute10 := p_party_site_obj.attribute10;
    px_party_site_rec.attribute11 := p_party_site_obj.attribute11;
    px_party_site_rec.attribute12 := p_party_site_obj.attribute12;
    px_party_site_rec.attribute13 := p_party_site_obj.attribute13;
    px_party_site_rec.attribute14 := p_party_site_obj.attribute14;
    px_party_site_rec.attribute15 := p_party_site_obj.attribute15;
    px_party_site_rec.attribute16 := p_party_site_obj.attribute16;
    px_party_site_rec.attribute17 := p_party_site_obj.attribute17;
    px_party_site_rec.attribute18 := p_party_site_obj.attribute18;
    px_party_site_rec.attribute19 := p_party_site_obj.attribute19;
    px_party_site_rec.attribute20 := p_party_site_obj.attribute20;
    px_party_site_rec.language := p_party_site_obj.language;
    px_party_site_rec.addressee := p_party_site_obj.addressee;
    IF(p_create_or_update = 'C') THEN
      px_party_site_rec.orig_system := p_ps_os;
      px_party_site_rec.orig_system_reference := p_ps_osr;
      px_party_site_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_party_site_rec.global_location_number := p_party_site_obj.global_location_number;
  END assign_party_site_rec;

  -- PROCEDURE create_party_site_bo
  --
  -- DESCRIPTION
  --     Create a party site business object.
  PROCEDURE do_create_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN OUT NOCOPY HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30);
    l_party_site_rec           HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
    l_location_rec             HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    l_party_site_use_rec       HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
    l_party_site_id            NUMBER;
    l_ps_number                VARCHAR2(30);
    l_location_id              NUMBER;
    l_valid_obj                BOOLEAN;
    l_bus_object               HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_errorcode                NUMBER;
    l_cbm                      VARCHAR2(30);
    l_edi_objs                 HZ_EDI_CP_BO_TBL;
    l_eft_objs                 HZ_EFT_CP_BO_TBL;
    l_sms_objs                 HZ_SMS_CP_BO_TBL;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_party_site_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list of p_init_msg_list is set to TRUE.
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
        hz_utility_v2pub.debug(p_message=>'do_create_party_site_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Base on p_validate_bo_flag, check the completeness of business objects
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'PARTY_SITE',
        x_bus_object              => l_bus_object
      );

      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_ps_bo_comp(
                       p_ps_objs    => HZ_PARTY_SITE_BO_TBL(p_party_site_obj),
                       p_bus_object => l_bus_object
                     );
      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- check pass in parent_id and parent_os+osr
    hz_registry_validate_bo_pvt.validate_parent_id(
      px_parent_id      => px_parent_id,
      px_parent_os      => px_parent_os,
      px_parent_osr     => px_parent_osr,
      p_parent_obj_type => px_parent_obj_type,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_party_site_id := p_party_site_obj.party_site_id;
    x_party_site_os := p_party_site_obj.orig_system;
    x_party_site_osr := p_party_site_obj.orig_system_reference;

    -- check if pass in contact_point_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_party_site_id,
      px_os              => x_party_site_os,
      px_osr             => x_party_site_osr,
      p_obj_type         => 'HZ_PARTY_SITES',
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ----------------------------
    -- For location record
    ----------------------------
    IF(p_party_site_obj.location_obj IS NULL) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
      fnd_message.set_token('ENTITY' ,'LOCATION');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    HZ_LOCATION_BO_PUB.assign_location_rec(
      p_location_obj  => p_party_site_obj.location_obj,
      p_loc_os        => p_party_site_obj.location_obj.orig_system,
      p_loc_osr       => p_party_site_obj.location_obj.orig_system_reference,
      px_location_rec => l_location_rec
    );

    HZ_LOCATION_V2PUB.create_location(
      p_location_rec              => l_location_rec,
      x_location_id               => l_location_id,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'LOCATION');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign location_id
    p_party_site_obj.location_obj.location_id := l_location_id;
    ----------------------------
    -- Create Location Ext Attrs
    ----------------------------
    IF((p_party_site_obj.location_obj.ext_attributes_objs IS NOT NULL) AND
       (p_party_site_obj.location_obj.ext_attributes_objs.COUNT > 0)) THEN
      HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
        p_ext_attr_objs             => p_party_site_obj.location_obj.ext_attributes_objs,
        p_parent_obj_id             => l_location_id,
        p_parent_obj_type           => 'LOCATION',
        p_create_or_update          => 'C',
        x_return_status             => x_return_status,
        x_errorcode                 => l_errorcode,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- For party site record
    ----------------------------
    assign_party_site_rec(
      p_party_site_obj  => p_party_site_obj,
      p_party_id        => px_parent_id,
      p_location_id     => l_location_id,
      p_ps_id           => x_party_site_id,
      p_ps_os           => x_party_site_os,
      p_ps_osr          => x_party_site_osr,
      px_party_site_rec => l_party_site_rec
    );

    HZ_PARTY_SITE_V2PUB.create_party_site(
      p_party_site_rec            => l_party_site_rec,
      x_party_site_id             => x_party_site_id,
      x_party_site_number         => l_ps_number,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign party_site_id
    p_party_site_obj.party_site_id := x_party_site_id;
    ------------------------------
    -- Create Party Site Ext Attrs
    ------------------------------
    IF((p_party_site_obj.ext_attributes_objs IS NOT NULL) AND
       (p_party_site_obj.ext_attributes_objs.COUNT > 0)) THEN
      HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
        p_ext_attr_objs             => p_party_site_obj.ext_attributes_objs,
        p_parent_obj_id             => x_party_site_id,
        p_parent_obj_type           => 'PARTY_SITE',
        p_create_or_update          => 'C',
        x_return_status             => x_return_status,
        x_errorcode                 => l_errorcode,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ------------------------
    -- For party site use
    ------------------------
    IF((p_party_site_obj.party_site_use_objs IS NOT NULL) AND
       (p_party_site_obj.party_site_use_objs.COUNT > 0)) THEN
      HZ_PARTY_SITE_BO_PVT.create_party_site_uses(
        p_psu_objs           => p_party_site_obj.party_site_use_objs,
        p_ps_id              => x_party_site_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    ----------------------------------------------------------
    -- For contact points - phone, telex, email and web
    ----------------------------------------------------------
    IF(((p_party_site_obj.phone_objs IS NOT NULL) AND (p_party_site_obj.phone_objs.COUNT > 0)) OR
       ((p_party_site_obj.telex_objs IS NOT NULL) AND (p_party_site_obj.telex_objs.COUNT > 0)) OR
       ((p_party_site_obj.email_objs IS NOT NULL) AND (p_party_site_obj.email_objs.COUNT > 0)) OR
       ((p_party_site_obj.web_objs IS NOT NULL) AND (p_party_site_obj.web_objs.COUNT > 0))) THEN
      HZ_CONTACT_POINT_BO_PVT.save_contact_points(
        p_phone_objs         => p_party_site_obj.phone_objs,
        p_telex_objs         => p_party_site_obj.telex_objs,
        p_email_objs         => p_party_site_obj.email_objs,
        p_web_objs           => p_party_site_obj.web_objs,
        p_edi_objs           => l_edi_objs,
        p_eft_objs           => l_eft_objs,
        p_sms_objs           => l_sms_objs,
        p_owner_table_id     => x_party_site_id,
        p_owner_table_os     => x_party_site_os,
        p_owner_table_osr    => x_party_site_osr,
        p_parent_obj_type    => 'PARTY_SITE',
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ----------------------------
    -- For contact preference
    ----------------------------
    IF((p_party_site_obj.contact_pref_objs IS NOT NULL) AND
       (p_party_site_obj.contact_pref_objs.COUNT > 0)) THEN
      HZ_CONTACT_PREFERENCE_BO_PVT.create_contact_preferences(
        p_cp_pref_objs       => p_party_site_obj.contact_pref_objs,
        p_contact_level_table_id => x_party_site_id,
        p_contact_level_table => 'HZ_PARTY_SITES',
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
        hz_utility_v2pub.debug(p_message=>'do_create_party_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_party_site_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PARTY_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_create_party_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_party_site_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PARTY_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_create_party_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_party_site_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PARTY_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_create_party_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_party_site_bo;

  PROCEDURE create_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_ps_obj              HZ_PARTY_SITE_BO;
  BEGIN
    l_ps_obj := p_party_site_obj;
    do_create_party_site_bo(
      p_init_msg_list       => p_init_msg_list,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_party_site_obj      => l_ps_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_party_site_id       => x_party_site_id,
      x_party_site_os       => x_party_site_os,
      x_party_site_osr      => x_party_site_osr,
      px_parent_id          => px_parent_id,
      px_parent_os          => px_parent_os,
      px_parent_osr         => px_parent_osr,
      px_parent_obj_type    => px_parent_obj_type
    );
  END create_party_site_bo;

  PROCEDURE create_party_site_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PARTY_SITE_BO,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_ps_obj              HZ_PARTY_SITE_BO;
  BEGIN
    l_ps_obj := p_party_site_obj;
    do_create_party_site_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_party_site_obj      => l_ps_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_party_site_id       => x_party_site_id,
      x_party_site_os       => x_party_site_os,
      x_party_site_osr      => x_party_site_osr,
      px_parent_id          => px_parent_id,
      px_parent_os          => px_parent_os,
      px_parent_osr         => px_parent_osr,
      px_parent_obj_type    => px_parent_obj_type
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_ps_obj;
    END IF;
  END create_party_site_bo;

  -- PROCEDURE update_party_site_bo
  --
  -- DESCRIPTION
  --     Update a party site business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_party_site_obj     Party site business object.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_party_site_id      Party Site ID.
  --     x_party_site_os      Party Site orig system.
  --     x_party_site_osr     Party Site orig system reference.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE update_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2
  )IS
    l_ps_obj              HZ_PARTY_SITE_BO;
  BEGIN
    l_ps_obj := p_party_site_obj;
    do_update_party_site_bo(
      p_init_msg_list       => p_init_msg_list,
      p_party_site_obj      => l_ps_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_party_site_id       => x_party_site_id,
      x_party_site_os       => x_party_site_os,
      x_party_site_osr      => x_party_site_osr,
      p_parent_os           => NULL );
  END update_party_site_bo;

  PROCEDURE update_party_site_bo(
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PARTY_SITE_BO,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2
  )IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_ps_obj              HZ_PARTY_SITE_BO;
  BEGIN
    l_ps_obj := p_party_site_obj;
    do_update_party_site_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_party_site_obj      => l_ps_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_party_site_id       => x_party_site_id,
      x_party_site_os       => x_party_site_os,
      x_party_site_osr      => x_party_site_osr,
      p_parent_os           => NULL
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_ps_obj;
    END IF;
  END update_party_site_bo;

  -- PRIVATE PROCEDURE do_update_party_site_bo
  --
  -- DESCRIPTION
  --     Update party site business object.
  PROCEDURE do_update_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_party_site_obj      IN OUT NOCOPY HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    p_parent_os           IN            VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30);
    l_party_site_rec           HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
    l_location_rec             HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    l_party_site_use_rec       HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
    l_ps_id                    NUMBER;
    l_ps_ovn                   NUMBER;
    l_loc_ovn                  NUMBER;
    l_location_id              NUMBER;
    l_party_id                 NUMBER;
    l_create_update_flag       VARCHAR2(1);
    l_errorcode                NUMBER;
    l_cbm                      VARCHAR2(30);
    l_edi_objs                 HZ_EDI_CP_BO_TBL;
    l_eft_objs                 HZ_EFT_CP_BO_TBL;
    l_sms_objs                 HZ_SMS_CP_BO_TBL;

    CURSOR get_ovn(l_ps_id  NUMBER) IS
    SELECT ps.object_version_number, loc.object_version_number, ps.party_id, loc.location_id
    FROM HZ_PARTY_SITES ps, HZ_LOCATIONS loc
    WHERE ps.party_site_id = l_ps_id
    AND ps.location_id = loc.location_id
    AND ps.status in ('A','I');

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_party_site_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list of p_init_msg_list is set to TRUE.
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
        hz_utility_v2pub.debug(p_message=>'do_update_party_site_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_party_site_id := p_party_site_obj.party_site_id;
    x_party_site_os := p_party_site_obj.orig_system;
    x_party_site_osr := p_party_site_obj.orig_system_reference;

    -- check if pass in party_site_id and ssm is
    -- valid for update
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_party_site_id,
      px_os              => x_party_site_os,
      px_osr             => x_party_site_osr,
      p_obj_type         => 'HZ_PARTY_SITES',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN get_ovn(x_party_site_id);
    FETCH get_ovn INTO l_ps_ovn, l_loc_ovn, l_party_id, l_location_id;
    CLOSE get_ovn;

    ------------------------
    -- For Party Site
    ------------------------
    assign_party_site_rec(
      p_party_site_obj  => p_party_site_obj,
      p_party_id        => l_party_id,
      p_location_id     => l_location_id,
      p_ps_id           => x_party_site_id,
      p_ps_os           => x_party_site_os,
      p_ps_osr          => x_party_site_osr,
      p_create_or_update => 'U',
      px_party_site_rec => l_party_site_rec
    );

    HZ_PARTY_SITE_V2PUB.update_party_site(
      p_party_site_rec            => l_party_site_rec,
      p_object_version_number     => l_ps_ovn,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign party_site_id
    p_party_site_obj.party_site_id := x_party_site_id;
    ------------------------------
    -- Create Party Site Ext Attrs
    ------------------------------
    IF((p_party_site_obj.ext_attributes_objs IS NOT NULL) AND
       (p_party_site_obj.ext_attributes_objs.COUNT > 0)) THEN
      HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
        p_ext_attr_objs             => p_party_site_obj.ext_attributes_objs,
        p_parent_obj_id             => x_party_site_id,
        p_parent_obj_type           => 'PARTY_SITE',
        p_create_or_update          => 'U',
        x_return_status             => x_return_status,
        x_errorcode                 => l_errorcode,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------
    -- For Location
    ----------------------
    -- If there is no change in location information, user won't pass in
    -- location object.  Therefore, don't do anything
    IF(p_party_site_obj.location_obj IS NOT NULL) THEN
      HZ_LOCATION_BO_PUB.assign_location_rec(
        p_location_obj  => p_party_site_obj.location_obj,
        p_loc_os        => p_party_site_obj.location_obj.orig_system,
        p_loc_osr       => p_party_site_obj.location_obj.orig_system_reference,
        p_create_or_update => 'U',
        px_location_rec => l_location_rec
      );

      l_location_rec.location_id := l_location_id;

      HZ_LOCATION_V2PUB.update_location(
        p_location_rec              => l_location_rec,
        p_object_version_number     => l_loc_ovn,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
        FND_MESSAGE.SET_TOKEN('OBJECT', 'LOCATION');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign location_id
      p_party_site_obj.location_obj.location_id := l_location_id;
      ----------------------------
      -- Create Location Ext Attrs
      ----------------------------
      IF((p_party_site_obj.location_obj.ext_attributes_objs IS NOT NULL) AND
         (p_party_site_obj.location_obj.ext_attributes_objs.COUNT > 0)) THEN
        HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
          p_ext_attr_objs             => p_party_site_obj.location_obj.ext_attributes_objs,
          p_parent_obj_id             => l_location_id,
          p_parent_obj_type           => 'LOCATION',
          p_create_or_update          => 'U',
          x_return_status             => x_return_status,
          x_errorcode                 => l_errorcode,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;

    ---------------------
    -- For Party Site Use
    ---------------------
    IF((p_party_site_obj.party_site_use_objs IS NOT NULL) AND
       (p_party_site_obj.party_site_use_objs.COUNT > 0)) THEN
      HZ_PARTY_SITE_BO_PVT.save_party_site_uses(
        p_psu_objs           => p_party_site_obj.party_site_use_objs,
        p_ps_id              => x_party_site_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    ---------------------
    -- For Contact Points
    ---------------------
    IF(((p_party_site_obj.phone_objs IS NOT NULL) AND (p_party_site_obj.phone_objs.COUNT > 0)) OR
       ((p_party_site_obj.telex_objs IS NOT NULL) AND (p_party_site_obj.telex_objs.COUNT > 0)) OR
       ((p_party_site_obj.email_objs IS NOT NULL) AND (p_party_site_obj.email_objs.COUNT > 0)) OR
       ((p_party_site_obj.web_objs IS NOT NULL) AND (p_party_site_obj.web_objs.COUNT > 0))) THEN
      HZ_CONTACT_POINT_BO_PVT.save_contact_points(
        p_phone_objs         => p_party_site_obj.phone_objs,
        p_telex_objs         => p_party_site_obj.telex_objs,
        p_email_objs         => p_party_site_obj.email_objs,
        p_web_objs           => p_party_site_obj.web_objs,
        p_edi_objs           => l_edi_objs,
        p_eft_objs           => l_eft_objs,
        p_sms_objs           => l_sms_objs,
        p_owner_table_id     => x_party_site_id,
        p_owner_table_os     => x_party_site_os,
        p_owner_table_osr    => x_party_site_osr,
        p_parent_obj_type    => 'PARTY_SITE',
        p_create_update_flag => 'U',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -------------------------
    -- For Contact Preference
    -------------------------
    IF((p_party_site_obj.contact_pref_objs IS NOT NULL) AND
       (p_party_site_obj.contact_pref_objs.COUNT > 0)) THEN
      HZ_CONTACT_PREFERENCE_BO_PVT.save_contact_preferences(
        p_cp_pref_objs       => p_party_site_obj.contact_pref_objs,
        p_contact_level_table_id => x_party_site_id,
        p_contact_level_table => 'HZ_PARTY_SITES',
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
        hz_utility_v2pub.debug(p_message=>'do_update_party_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_party_site_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PARTY_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_update_party_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_party_site_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PARTY_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_update_party_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_party_site_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PARTY_SITE');
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
        hz_utility_v2pub.debug(p_message=>'do_update_party_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_party_site_bo;

  -- PROCEDURE do_save_party_site_bo
  --
  -- DESCRIPTION
  --     Create or update a party site business object.
  PROCEDURE do_save_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN OUT NOCOPY HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_return_status            VARCHAR2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_create_update_flag       VARCHAR2(1);
    l_debug_prefix             VARCHAR2(30);
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list of p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_party_site_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_party_site_id := p_party_site_obj.party_site_id;
    x_party_site_os := p_party_site_obj.orig_system;
    x_party_site_osr := p_party_site_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => x_party_site_id,
                              p_entity_os      => x_party_site_os,
                              p_entity_osr     => x_party_site_osr,
                              p_entity_type    => 'HZ_PARTY_SITES',
                              p_parent_id      => px_parent_id,
                              p_parent_obj_type=> px_parent_obj_type);

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PARTY_SITE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_party_site_bo(
        p_init_msg_list      => fnd_api.g_false,
        p_validate_bo_flag   => p_validate_bo_flag,
        p_party_site_obj     => p_party_site_obj,
        p_created_by_module  => p_created_by_module,
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        x_party_site_id      => x_party_site_id,
        x_party_site_os      => x_party_site_os,
        x_party_site_osr     => x_party_site_osr,
        px_parent_id         => px_parent_id,
        px_parent_os         => px_parent_os,
        px_parent_osr        => px_parent_osr,
        px_parent_obj_type   => px_parent_obj_type
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_party_site_bo(
        p_init_msg_list      => fnd_api.g_false,
        p_party_site_obj     => p_party_site_obj,
        p_created_by_module  => p_created_by_module,
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        x_party_site_id      => x_party_site_id,
        x_party_site_os      => x_party_site_os,
        x_party_site_osr     => x_party_site_osr,
        p_parent_os          => px_parent_os );
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
        hz_utility_v2pub.debug(p_message=>'do_save_party_site_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_party_site_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_party_site_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_party_site_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_party_site_bo;

  PROCEDURE save_party_site_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_ps_obj              HZ_PARTY_SITE_BO;
  BEGIN
    l_ps_obj := p_party_site_obj;
    do_save_party_site_bo(
      p_init_msg_list       => p_init_msg_list,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_party_site_obj      => l_ps_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_party_site_id       => x_party_site_id,
      x_party_site_os       => x_party_site_os,
      x_party_site_osr      => x_party_site_osr,
      px_parent_id          => px_parent_id,
      px_parent_os          => px_parent_os,
      px_parent_osr         => px_parent_osr,
      px_parent_obj_type    => px_parent_obj_type
    );
  END save_party_site_bo;

 PROCEDURE save_party_site_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_party_site_obj      IN            HZ_PARTY_SITE_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PARTY_SITE_BO,
    x_party_site_id       OUT NOCOPY    NUMBER,
    x_party_site_os       OUT NOCOPY    VARCHAR2,
    x_party_site_osr      OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_ps_obj              HZ_PARTY_SITE_BO;
  BEGIN
    l_ps_obj := p_party_site_obj;
    do_save_party_site_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_party_site_obj      => l_ps_obj,
      p_created_by_module   => p_created_by_module,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_party_site_id       => x_party_site_id,
      x_party_site_os       => x_party_site_os,
      x_party_site_osr      => x_party_site_osr,
      px_parent_id          => px_parent_id,
      px_parent_os          => px_parent_os,
      px_parent_osr         => px_parent_osr,
      px_parent_obj_type    => px_parent_obj_type
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_ps_obj;
    END IF;
  END save_party_site_bo;

 --------------------------------------
  --
  -- PROCEDURE get_party_site_bo
  --
  -- DESCRIPTION
  --     Get a logical party site.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
 --       p_party_id          party ID.
 --       p_party_site_id     party site ID. If this id is not passed in, multiple site objects will be returned.
  --     p_party_site_os          party site orig system.
  --     p_party_site_osr         party site orig system reference.
  --
  --   OUT:
  --     x_party_site_objs         Logical party site records.
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
  --   1-JUNE-2005   AWU                Created.
  --

/*
The Get party site API Procedure is a retrieval service that returns a full party site business object.
The user identifies a particular party site business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full party site business object is returned. The object consists of all data included within
the party site business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the party site business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Phone			N	Y		get_phone_bos
Telex			N	Y		get_telex_bos
Email			N	Y		get_email_bos
Web			N	Y		get_web_bos

To retrieve the appropriate embedded entities within the party site business object,
the Get procedure returns all records for the particular party site from these TCA entity tables:

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Location		Y		N	HZ_LOCATIONS
Party Site		Y		N	HZ_PARTY_SITES
Party Site Use		N		Y	HZ_PARTY_SITE_USES
Contact Preference	N		Y	HZ_CONTACT_PREFERENCES
*/


PROCEDURE get_party_site_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_party_site_id		IN	NUMBER,
	p_party_site_os		IN	VARCHAR2,
	p_party_site_osr	IN	VARCHAR2,
	x_party_site_obj  	OUT NOCOPY	HZ_PARTY_SITE_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_party_site_id  number;
  l_party_site_os  varchar2(30);
  l_party_site_osr varchar2(255);
  l_party_site_objs  HZ_PARTY_SITE_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_party_site_bo_pub.get_party_site_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_party_site_id := p_party_site_id;
    	l_party_site_os := p_party_site_os;
    	l_party_site_osr := p_party_site_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_party_site_id,
      		px_os              => l_party_site_os,
      		px_osr             => l_party_site_osr,
      		p_obj_type         => 'HZ_PARTY_SITES',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_PARTY_SITE_BO_PVT.get_party_site_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_party_id => NULL,
		 p_party_site_id => l_party_site_id,
		 p_action_type => NULL,
		  x_party_site_objs => l_party_site_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_party_site_obj := l_party_site_objs(1);

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
        	hz_utility_v2pub.debug(p_message=>'hz_party_site_bo_pub.get_party_site_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_party_site_bo_pub.get_party_site_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_party_site_bo_pub.get_party_site_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_party_site_bo_pub.get_party_site_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_party_site_bo (
    p_party_site_id		IN	NUMBER,
    p_party_site_os		IN	VARCHAR2,
    p_party_site_osr	IN	VARCHAR2,
    x_party_site_obj  	OUT NOCOPY	HZ_PARTY_SITE_BO,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_messages		OUT NOCOPY	HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data              VARCHAR2(2000);
    l_msg_count             NUMBER;
  BEGIN
    get_party_site_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_party_site_id       => p_party_site_id,
      p_party_site_os       => p_party_site_os,
      p_party_site_osr      => p_party_site_osr,
      x_party_site_obj      => x_party_site_obj,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_party_site_bo;

END hz_party_site_bo_pub;

/
