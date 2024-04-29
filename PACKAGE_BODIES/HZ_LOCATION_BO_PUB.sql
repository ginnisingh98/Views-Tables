--------------------------------------------------------
--  DDL for Package Body HZ_LOCATION_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_LOCATION_BO_PUB" AS
/*$Header: ARHBLCBB.pls 120.5 2006/05/18 22:25:40 acng noship $ */

  PROCEDURE do_create_location_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj        IN OUT NOCOPY HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  );

  PROCEDURE do_update_location_bo(
    p_init_msg_list     IN            VARCHAR2 := fnd_api.g_false,
    p_location_obj      IN OUT NOCOPY HZ_LOCATION_OBJ,
    p_created_by_module IN            VARCHAR2,
    p_obj_source        IN            VARCHAR2 := null,
    x_return_status     OUT NOCOPY    VARCHAR2,
    x_msg_count         OUT NOCOPY    NUMBER,
    x_msg_data          OUT NOCOPY    VARCHAR2,
    x_location_id       OUT NOCOPY    NUMBER,
    x_location_os       OUT NOCOPY    VARCHAR2,
    x_location_osr      OUT NOCOPY    VARCHAR2
  );

  PROCEDURE do_save_location_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj        IN OUT NOCOPY HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  );

  -- PUBLIC PROCEDURE assign_location_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from location object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_location_obj       Location object.
  --     p_loc_os             Location original system.
  --     p_loc_osr            Location original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_location_rec      Location plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_location_rec(
    p_location_obj               IN            HZ_LOCATION_OBJ,
    p_loc_os                     IN            VARCHAR2,
    p_loc_osr                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_location_rec              IN OUT NOCOPY HZ_LOCATION_V2PUB.LOCATION_REC_TYPE
  ) IS
  BEGIN
    px_location_rec.location_id:= p_location_obj.location_id;
    px_location_rec.country:= p_location_obj.country;
    px_location_rec.address1:= p_location_obj.address1;
    px_location_rec.address2:= p_location_obj.address2;
    px_location_rec.address3:= p_location_obj.address3;
    px_location_rec.address4:= p_location_obj.address4;
    px_location_rec.city:= p_location_obj.city;
    px_location_rec.postal_code:= p_location_obj.postal_code;
    px_location_rec.state:= p_location_obj.state;
    px_location_rec.province:= p_location_obj.province;
    px_location_rec.county:= p_location_obj.county;
    px_location_rec.address_key:= p_location_obj.address_key;
    px_location_rec.address_style:= p_location_obj.address_style;
    px_location_rec.validated_flag:= p_location_obj.validated_flag;
    px_location_rec.address_lines_phonetic:= p_location_obj.address_lines_phonetic;
    px_location_rec.postal_plus4_code:= p_location_obj.postal_plus4_code;
    px_location_rec.position:= p_location_obj.position;
    px_location_rec.location_directions:= p_location_obj.location_directions;
    px_location_rec.address_effective_date:= p_location_obj.address_effective_date;
    px_location_rec.address_expiration_date:= p_location_obj.address_expiration_date;
    px_location_rec.clli_code:= p_location_obj.clli_code;
    px_location_rec.language:= p_location_obj.language;
    px_location_rec.short_description:= p_location_obj.short_description;
    px_location_rec.description:= p_location_obj.description;
    px_location_rec.geometry:= p_location_obj.geometry;
    px_location_rec.geometry_status_code:= p_location_obj.geometry_status_code;
    px_location_rec.loc_hierarchy_id:= p_location_obj.loc_hierarchy_id;
    px_location_rec.sales_tax_geocode:= p_location_obj.sales_tax_geocode;
    px_location_rec.sales_tax_inside_city_limits:= p_location_obj.sales_tax_inside_city_limits;
    px_location_rec.fa_location_id:= p_location_obj.fa_location_id;
    px_location_rec.attribute_category:= p_location_obj.attribute_category;
    px_location_rec.attribute1:= p_location_obj.attribute1;
    px_location_rec.attribute2:= p_location_obj.attribute2;
    px_location_rec.attribute3:= p_location_obj.attribute3;
    px_location_rec.attribute4:= p_location_obj.attribute4;
    px_location_rec.attribute5:= p_location_obj.attribute5;
    px_location_rec.attribute6:= p_location_obj.attribute6;
    px_location_rec.attribute7:= p_location_obj.attribute7;
    px_location_rec.attribute8:= p_location_obj.attribute8;
    px_location_rec.attribute9:= p_location_obj.attribute9;
    px_location_rec.attribute10:= p_location_obj.attribute10;
    px_location_rec.attribute11:= p_location_obj.attribute11;
    px_location_rec.attribute12:= p_location_obj.attribute12;
    px_location_rec.attribute13:= p_location_obj.attribute13;
    px_location_rec.attribute14:= p_location_obj.attribute14;
    px_location_rec.attribute15:= p_location_obj.attribute15;
    px_location_rec.attribute16:= p_location_obj.attribute16;
    px_location_rec.attribute17:= p_location_obj.attribute17;
    px_location_rec.attribute18:= p_location_obj.attribute18;
    px_location_rec.attribute19:= p_location_obj.attribute19;
    px_location_rec.attribute20:= p_location_obj.attribute20;
    px_location_rec.timezone_id:= p_location_obj.timezone_id;
    IF(p_create_or_update = 'C') THEN
      px_location_rec.orig_system:= p_loc_os;
      px_location_rec.orig_system_reference:= p_loc_osr;
      px_location_rec.created_by_module:= HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_location_rec.actual_content_source:= p_location_obj.actual_content_source;
    px_location_rec.delivery_point_code:= p_location_obj.delivery_point_code;
  END assign_location_rec;

  -- PROCEDURE do_create_location_bo
  --
  -- DESCRIPTION
  --     Create a location business object.
  PROCEDURE do_create_location_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj      IN OUT NOCOPY  HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_location_id       OUT NOCOPY    NUMBER,
    x_location_os       OUT NOCOPY    VARCHAR2,
    x_location_osr      OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix           VARCHAR2(30);
    l_location_rec           HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    l_location_id            NUMBER;
    l_location_id            NUMBER;
    l_valid_obj              BOOLEAN;
    l_bus_object             HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_errorcode              NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_location_bo_pub;

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
        hz_utility_v2pub.debug(p_message=>'do_create_location_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

/* Currently, business object definition cannot be altered.  The seeded completeness
   for LOCATION business object has no mandatory embedded objects.  So, comment out
   this line of code
    -- Base on p_validate_bo_flag, check the completeness of business objects
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'LOCATION',
        x_bus_object              => l_bus_object
      );

      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_loc_bo_comp(
                       p_ps_objs    => p_location_obj,
                       p_bus_object => l_bus_object
                     );
      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
*/
    x_location_id := p_location_obj.location_id;
    x_location_os := p_location_obj.orig_system;
    x_location_osr := p_location_obj.orig_system_reference;

    -- check if pass in location_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_location_id,
      px_os              => x_location_os,
      px_osr             => x_location_osr,
      p_obj_type         => 'HZ_LOCATIONS',
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    assign_location_rec(
      p_location_obj  => p_location_obj,
      p_loc_os        => x_location_os,
      p_loc_osr       => x_location_osr,
      px_location_rec => l_location_rec
    );

    HZ_LOCATION_V2PUB.create_location(
      p_location_rec              => l_location_rec,
      x_location_id               => x_location_id,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign location_id
    p_location_obj.location_id := x_location_id;
    ----------------------------
    -- Create Location Ext Attrs
    ----------------------------
    IF((p_location_obj.ext_attributes_objs IS NOT NULL) AND
       (p_location_obj.ext_attributes_objs.COUNT > 0)) THEN
      HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
        p_ext_attr_objs             => p_location_obj.ext_attributes_objs,
        p_parent_obj_id             => x_location_id,
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
        hz_utility_v2pub.debug(p_message=>'do_create_location_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_location_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'LOCATION');
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
        hz_utility_v2pub.debug(p_message=>'do_create_location_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_location_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'LOCATION');
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
        hz_utility_v2pub.debug(p_message=>'do_create_location_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_location_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'LOCATION');
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
        hz_utility_v2pub.debug(p_message=>'do_create_location_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_location_bo;

  PROCEDURE create_location_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_location_id       OUT NOCOPY    NUMBER,
    x_location_os       OUT NOCOPY    VARCHAR2,
    x_location_osr      OUT NOCOPY    VARCHAR2
  ) IS
    l_location_obj          HZ_LOCATION_OBJ;
  BEGIN
    l_location_obj := p_location_obj;
    do_create_location_bo(
      p_init_msg_list       => p_init_msg_list,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_location_obj        => l_location_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_location_id         => x_location_id,
      x_location_os         => x_location_os,
      x_location_osr        => x_location_osr
    );
  END create_location_bo;

  PROCEDURE create_location_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_LOCATION_OBJ,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  ) IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_location_obj        HZ_LOCATION_OBJ;
  BEGIN
    l_location_obj := p_location_obj;
    do_create_location_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_location_obj        => l_location_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_location_id         => x_location_id,
      x_location_os         => x_location_os,
      x_location_osr        => x_location_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_location_obj;
    END IF;
  END create_location_bo;

  -- PROCEDURE do_update_location_bo
  --
  -- DESCRIPTION
  --     Update a location business object.
  PROCEDURE do_update_location_bo(
    p_init_msg_list     IN            VARCHAR2 := fnd_api.g_false,
    p_location_obj      IN OUT NOCOPY HZ_LOCATION_OBJ,
    p_created_by_module IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status     OUT NOCOPY    VARCHAR2,
    x_msg_count         OUT NOCOPY    NUMBER,
    x_msg_data          OUT NOCOPY    VARCHAR2,
    x_location_id       OUT NOCOPY    NUMBER,
    x_location_os       OUT NOCOPY    VARCHAR2,
    x_location_osr      OUT NOCOPY    VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30);
    l_location_rec             HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    l_loc_ovn                  NUMBER;
    l_location_id              NUMBER;
    l_create_update_flag       VARCHAR2(1);
    l_errorcode                NUMBER;

    CURSOR get_ovn(l_loc_id  NUMBER) IS
    SELECT loc.object_version_number
    FROM HZ_LOCATIONS loc
    WHERE loc.location_id = l_loc_id;

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_location_bo_pub;

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
        hz_utility_v2pub.debug(p_message=>'do_update_location_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_location_id := p_location_obj.location_id;
    x_location_os := p_location_obj.orig_system;
    x_location_osr := p_location_obj.orig_system_reference;

    -- check if pass in location_id and ssm is
    -- valid for update
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_location_id,
      px_os              => x_location_os,
      px_osr             => x_location_osr,
      p_obj_type         => 'HZ_LOCATIONS',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN get_ovn(x_location_id);
    FETCH get_ovn INTO l_loc_ovn;
    CLOSE get_ovn;

    ----------------------
    -- For Location
    ----------------------
    assign_location_rec(
      p_location_obj     => p_location_obj,
      p_loc_os           => x_location_os,
      p_loc_osr          => x_location_osr,
      p_create_or_update => 'U',
      px_location_rec    => l_location_rec
    );

    l_location_rec.location_id := x_location_id;

    HZ_LOCATION_V2PUB.update_location(
      p_location_rec              => l_location_rec,
      p_object_version_number     => l_loc_ovn,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign location_id
    p_location_obj.location_id := x_location_id;
    ----------------------------
    -- Create Location Ext Attrs
    ----------------------------
    IF((p_location_obj.ext_attributes_objs IS NOT NULL) AND
       (p_location_obj.ext_attributes_objs.COUNT > 0)) THEN
      HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
        p_ext_attr_objs             => p_location_obj.ext_attributes_objs,
        p_parent_obj_id             => x_location_id,
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
        hz_utility_v2pub.debug(p_message=>'do_update_location_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_location_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'LOCATION');
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
        hz_utility_v2pub.debug(p_message=>'do_update_location_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_location_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'LOCATION');
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
        hz_utility_v2pub.debug(p_message=>'do_update_location_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_location_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'LOCATION');
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
        hz_utility_v2pub.debug(p_message=>'do_update_location_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_location_bo;

  PROCEDURE update_location_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  ) IS
    l_location_obj        HZ_LOCATION_OBJ;
  BEGIN
    l_location_obj := p_location_obj;
    do_update_location_bo(
      p_init_msg_list       => p_init_msg_list,
      p_location_obj        => l_location_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_location_id         => x_location_id,
      x_location_os         => x_location_os,
      x_location_osr        => x_location_osr
    );
  END update_location_bo;

  PROCEDURE update_location_bo(
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_LOCATION_OBJ,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  ) IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_location_obj        HZ_LOCATION_OBJ;
  BEGIN
    l_location_obj := p_location_obj;
    do_update_location_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_location_obj        => l_location_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_location_id         => x_location_id,
      x_location_os         => x_location_os,
      x_location_osr        => x_location_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_location_obj;
    END IF;
  END update_location_bo;

  -- PROCEDURE do_save_location_bo
  --
  -- DESCRIPTION
  --     Create or update a location business object.
  PROCEDURE do_save_location_bo(
    p_init_msg_list     IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag  IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj      IN OUT NOCOPY HZ_LOCATION_OBJ,
    p_created_by_module IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status     OUT NOCOPY    VARCHAR2,
    x_msg_count         OUT NOCOPY    NUMBER,
    x_msg_data          OUT NOCOPY    VARCHAR2,
    x_location_id       OUT NOCOPY    NUMBER,
    x_location_os       OUT NOCOPY    VARCHAR2,
    x_location_osr      OUT NOCOPY    VARCHAR2
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
        hz_utility_v2pub.debug(p_message=>'do_save_location_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_location_id := p_location_obj.location_id;
    x_location_os := p_location_obj.orig_system;
    x_location_osr := p_location_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id       => x_location_id,
                              p_entity_os       => x_location_os,
                              p_entity_osr      => x_location_osr,
                              p_entity_type     => 'HZ_LOCATIONS',
                              p_parent_id       => NULL,
                              p_parent_obj_type => NULL);

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'LOCATION');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_location_bo(
        p_init_msg_list     => fnd_api.g_false,
        p_validate_bo_flag  => p_validate_bo_flag,
        p_location_obj      => p_location_obj,
        p_created_by_module => p_created_by_module,
        p_obj_source        => p_obj_source,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        x_location_id       => x_location_id,
        x_location_os       => x_location_os,
        x_location_osr      => x_location_osr);
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_location_bo(
        p_init_msg_list     => fnd_api.g_false,
        p_location_obj      => p_location_obj,
        p_created_by_module => p_created_by_module,
        p_obj_source        => p_obj_source,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        x_location_id       => x_location_id,
        x_location_os       => x_location_os,
        x_location_osr      => x_location_osr);
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
        hz_utility_v2pub.debug(p_message=>'do_save_location_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_location_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_location_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_location_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_location_bo;

  PROCEDURE save_location_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  ) IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_location_obj        HZ_LOCATION_OBJ;
  BEGIN
    l_location_obj := p_location_obj;
    do_save_location_bo(
      p_init_msg_list       => p_init_msg_list,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_location_obj        => l_location_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_location_id         => x_location_id,
      x_location_os         => x_location_os,
      x_location_osr        => x_location_osr
    );
  END save_location_bo;

  PROCEDURE save_location_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_location_obj        IN            HZ_LOCATION_OBJ,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_LOCATION_OBJ,
    x_location_id         OUT NOCOPY    NUMBER,
    x_location_os         OUT NOCOPY    VARCHAR2,
    x_location_osr        OUT NOCOPY    VARCHAR2
  ) IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_location_obj        HZ_LOCATION_OBJ;
  BEGIN
    l_location_obj := p_location_obj;
    do_save_location_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_location_obj        => l_location_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_location_id         => x_location_id,
      x_location_os         => x_location_os,
      x_location_osr        => x_location_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_location_obj;
    END IF;
  END save_location_bo;

 --------------------------------------
  --
  -- PROCEDURE get_location_bo
  --
  -- DESCRIPTION
  --     Get a logical location.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
 --       p_party_id          party ID.
 --       p_location_id     location ID. If this id is not passed in, multiple site objects will be returned.
  --     p_location_os          location orig system.
  --     p_location_osr         location orig system reference.
  --
  --   OUT:
  --     x_location_objs         Logical location records.
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
The Get location API Procedure is a retrieval service that returns a full location business object.
The user identifies a particular location business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full location business object is returned. The object consists of all data included within
the location business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the location business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

To retrieve the appropriate embedded entities within the location business object,
the Get procedure returns all records for the particular location from these TCA entity tables:

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Location		Y		N	HZ_LOCATIONS
*/

  PROCEDURE get_location_bo (
    p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
    p_location_id     IN  NUMBER,
    p_location_os     IN  VARCHAR2,
    p_location_osr    IN  VARCHAR2,
    x_location_obj    OUT NOCOPY	HZ_LOCATION_OBJ,
    x_return_status   OUT NOCOPY	VARCHAR2,
    x_msg_count       OUT NOCOPY	NUMBER,
    x_msg_data        OUT NOCOPY	VARCHAR2
  ) IS
    l_debug_prefix    VARCHAR2(30) := '';
    l_location_id     NUMBER;
    l_location_os     VARCHAR2(30);
    l_location_osr    VARCHAR2(255);

    CURSOR c1(l_loc_id NUMBER) IS
      SELECT HZ_LOCATION_OBJ(
        NULL, --P_ACTION_TYPE,
        NULL, --COMMON_OBJ_ID
        LOC.LOCATION_ID,
        NULL, --ORIG_SYSTEM,
        NULL, --ORIG_SYSTEM_REFERENCE,
        LOC.COUNTRY,
        LOC.ADDRESS1,
        LOC.ADDRESS2,
        LOC.ADDRESS3,
        LOC.ADDRESS4,
        LOC.CITY,
        LOC.POSTAL_CODE,
        LOC.STATE,
        LOC.PROVINCE,
        LOC.COUNTY,
        LOC.ADDRESS_KEY,
        LOC.ADDRESS_STYLE,
        LOC.VALIDATED_FLAG,
        LOC.ADDRESS_LINES_PHONETIC,
        LOC.POSTAL_PLUS4_CODE,
        LOC.POSITION,
        LOC.LOCATION_DIRECTIONS,
        LOC.ADDRESS_EFFECTIVE_DATE,
        LOC.ADDRESS_EXPIRATION_DATE,
        LOC.CLLI_CODE,
        LOC.LANGUAGE,
        LOC.SHORT_DESCRIPTION,
        LOC.DESCRIPTION,
        LOC_HIERARCHY_ID,
        LOC.SALES_TAX_GEOCODE,
        LOC.SALES_TAX_INSIDE_CITY_LIMITS,
        LOC.FA_LOCATION_ID,
        LOC.TIMEZONE_ID,
        LOC.ATTRIBUTE_CATEGORY,
        LOC.ATTRIBUTE1, LOC.ATTRIBUTE2, LOC.ATTRIBUTE3, LOC.ATTRIBUTE4,
        LOC.ATTRIBUTE5, LOC.ATTRIBUTE6, LOC.ATTRIBUTE7, LOC.ATTRIBUTE8,
        LOC.ATTRIBUTE9, LOC.ATTRIBUTE10, LOC.ATTRIBUTE11, LOC.ATTRIBUTE12,
        LOC.ATTRIBUTE13, LOC.ATTRIBUTE14, LOC.ATTRIBUTE15, LOC.ATTRIBUTE16,
        LOC.ATTRIBUTE17, LOC.ATTRIBUTE18, LOC.ATTRIBUTE19, LOC.ATTRIBUTE20,
        LOC.PROGRAM_UPDATE_DATE,
        LOC.CREATED_BY_MODULE,
        HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LOC.CREATED_BY),
        LOC.CREATION_DATE,
        LOC.LAST_UPDATE_DATE,
        HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LOC.LAST_UPDATED_BY),
        LOC.ACTUAL_CONTENT_SOURCE,
        LOC.DELIVERY_POINT_CODE,
        LOC.GEOMETRY_STATUS_CODE,
        LOC.GEOMETRY,
        HZ_ORIG_SYS_REF_OBJ_TBL(),
        HZ_EXT_ATTRIBUTE_OBJ_TBL())
      FROM HZ_LOCATIONS LOC
      WHERE LOCATION_ID = l_loc_id;

  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(p_message=>'hz_location_bo_pub.get_location_bo(+)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check if pass in contact_point_id and/or os+osr
    -- extraction validation logic is same as update

    l_location_id := p_location_id;
    l_location_os := p_location_os;
    l_location_osr := p_location_osr;

    HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      px_id              => l_location_id,
      px_os              => l_location_os,
      px_osr             => l_location_osr,
      p_obj_type         => 'HZ_LOCATIONS',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    OPEN c1(l_location_id);
    FETCH c1 into x_location_obj;
    CLOSE c1;

    hz_extract_ext_attri_bo_pvt.get_ext_attribute_bos(
      p_init_msg_list      => fnd_api.g_false,
      p_ext_object_id      => x_location_obj.location_id,
      p_ext_object_name    => 'HZ_LOCATIONS',
      p_action_type        => NULL,
      x_ext_attribute_objs => x_location_obj.ext_attributes_objs,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data);

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
      hz_utility_v2pub.debug(p_message=>'hz_location_bo_pub.get_location_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_location_bo_pub.get_location_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_location_bo_pub.get_location_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_location_bo_pub.get_location_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END get_location_bo;

  PROCEDURE get_location_bo (
        p_location_id           IN      NUMBER,
        p_location_os           IN      VARCHAR2,
        p_location_osr          IN      VARCHAR2,
        x_location_obj          OUT NOCOPY      HZ_LOCATION_OBJ,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_messages              OUT NOCOPY      HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
  BEGIN
    get_location_bo(
      p_init_msg_list   => FND_API.g_true,
      p_location_id     => p_location_id,
      p_location_os     => p_location_os,
      p_location_osr    => p_location_osr,
      x_location_obj    => x_location_obj,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_location_bo;

END hz_location_bo_pub;

/
