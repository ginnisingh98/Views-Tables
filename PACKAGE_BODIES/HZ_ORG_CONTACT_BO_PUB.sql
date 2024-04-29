--------------------------------------------------------
--  DDL for Package Body HZ_ORG_CONTACT_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORG_CONTACT_BO_PUB" AS
/*$Header: ARHBOCBB.pls 120.19.12000000.2 2007/02/22 20:03:21 awu ship $ */

  -- PRIVATE PROCEDURE assign_person_profile_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from person profile object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_person_obj         Contact information object.
  --     p_person_os          Person original system.
  --     p_person_osr         Person original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN OUT:
  --     px_person_rec        Person plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_person_profile_rec(
    p_person_obj                 IN            HZ_PERSON_PROFILE_OBJ,
    p_person_id                  IN            NUMBER,
    p_person_os                  IN            VARCHAR2,
    p_person_osr                 IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_person_rec                IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_org_contact_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from org contact business object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_org_contact_obj    Organization contact business object.
  --     p_person_id          Person Id.
  --     p_related_org_id     Related organization Id.
  --     p_oc_id              Org contact Id.
  --     p_oc_os              Org contact original system.
  --     p_oc_osr             Org contact original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN OUT:
  --     px_org_contact_rec   Org contact plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_org_contact_rec(
    p_org_contact_obj            IN            HZ_ORG_CONTACT_BO,
    p_person_id                  IN            NUMBER,
    p_related_org_id             IN            NUMBER,
    p_oc_id                      IN            NUMBER,
    p_oc_os                      IN            VARCHAR2,
    p_oc_osr                     IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_org_contact_rec           IN OUT NOCOPY HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_person_profile_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from person profile object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_person_obj         Contact information object.
  --     p_person_os          Person original system.
  --     p_person_osr         Person original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN OUT:
  --     px_person_rec        Person plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_person_profile_rec(
    p_person_obj                 IN            HZ_PERSON_PROFILE_OBJ,
    p_person_id                  IN            NUMBER,
    p_person_os                  IN            VARCHAR2,
    p_person_osr                 IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_person_rec                IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE
  ) IS
  BEGIN
    px_person_rec.person_pre_name_adjunct := p_person_obj.person_pre_name_adjunct;
    px_person_rec.person_first_name := p_person_obj.person_first_name;
    px_person_rec.person_middle_name := p_person_obj.person_middle_name;
    px_person_rec.person_last_name := p_person_obj.person_last_name;
    px_person_rec.person_name_suffix := p_person_obj.person_name_suffix;
    px_person_rec.person_title := p_person_obj.person_title;
    px_person_rec.person_academic_title := p_person_obj.person_academic_title;
    px_person_rec.person_previous_last_name := p_person_obj.person_previous_last_name;
    px_person_rec.person_initials := p_person_obj.person_initials;
    px_person_rec.known_as  := p_person_obj.known_as;
    px_person_rec.known_as2 := p_person_obj.known_as2;
    px_person_rec.known_as3 := p_person_obj.known_as3;
    px_person_rec.known_as4 := p_person_obj.known_as4;
    px_person_rec.known_as5 := p_person_obj.known_as5;
    px_person_rec.person_name_phonetic := p_person_obj.person_name_phonetic;
    px_person_rec.person_first_name_phonetic := p_person_obj.person_first_name_phonetic;
    px_person_rec.person_last_name_phonetic := p_person_obj.person_last_name_phonetic;
    px_person_rec.middle_name_phonetic := p_person_obj.middle_name_phonetic;
    px_person_rec.tax_reference := p_person_obj.tax_reference;
    px_person_rec.jgzz_fiscal_code := p_person_obj.jgzz_fiscal_code;
    px_person_rec.person_iden_type := p_person_obj.person_iden_type;
    px_person_rec.person_identifier := p_person_obj.person_identifier;
    px_person_rec.date_of_birth := p_person_obj.date_of_birth;
    px_person_rec.place_of_birth := p_person_obj.place_of_birth;
    px_person_rec.date_of_death := p_person_obj.date_of_death;
    IF(p_person_obj.deceased_flag in ('Y','N')) THEN
      px_person_rec.deceased_flag := p_person_obj.deceased_flag;
    END IF;
    px_person_rec.gender := p_person_obj.gender;
    px_person_rec.declared_ethnicity := p_person_obj.declared_ethnicity;
    px_person_rec.marital_status := p_person_obj.marital_status;
    px_person_rec.marital_status_effective_date := p_person_obj.marital_status_eff_date;
    px_person_rec.personal_income := p_person_obj.personal_income;
    IF(p_person_obj.head_of_household_flag in ('Y','N')) THEN
      px_person_rec.head_of_household_flag := p_person_obj.head_of_household_flag;
    END IF;
    px_person_rec.household_income := p_person_obj.household_income;
    px_person_rec.household_size := p_person_obj.household_size;
    px_person_rec.rent_own_ind := p_person_obj.rent_own_ind;
    px_person_rec.last_known_gps:= p_person_obj.last_known_gps;
    px_person_rec.internal_flag:= p_person_obj.internal_flag;
    IF(p_create_or_update = 'C') THEN
      px_person_rec.party_rec.orig_system:= p_person_os;
      px_person_rec.party_rec.orig_system_reference:= p_person_osr;
      px_person_rec.created_by_module:= HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_person_rec.actual_content_source:= p_person_obj.actual_content_source;
    px_person_rec.party_rec.party_id:= p_person_id;
    px_person_rec.party_rec.party_number:= p_person_obj.party_number;
    px_person_rec.party_rec.validated_flag:= p_person_obj.validated_flag;
    px_person_rec.party_rec.status:= p_person_obj.status;
    px_person_rec.party_rec.category_code:= p_person_obj.category_code;
    px_person_rec.party_rec.salutation:= p_person_obj.salutation;
    px_person_rec.party_rec.attribute_category:= p_person_obj.attribute_category;
    px_person_rec.party_rec.attribute1:= p_person_obj.attribute1;
    px_person_rec.party_rec.attribute2:= p_person_obj.attribute2;
    px_person_rec.party_rec.attribute3:= p_person_obj.attribute3;
    px_person_rec.party_rec.attribute4:= p_person_obj.attribute4;
    px_person_rec.party_rec.attribute5:= p_person_obj.attribute5;
    px_person_rec.party_rec.attribute6:= p_person_obj.attribute6;
    px_person_rec.party_rec.attribute7:= p_person_obj.attribute7;
    px_person_rec.party_rec.attribute8:= p_person_obj.attribute8;
    px_person_rec.party_rec.attribute9:= p_person_obj.attribute9;
    px_person_rec.party_rec.attribute10:= p_person_obj.attribute10;
    px_person_rec.party_rec.attribute11:= p_person_obj.attribute11;
    px_person_rec.party_rec.attribute12:= p_person_obj.attribute12;
    px_person_rec.party_rec.attribute13:= p_person_obj.attribute13;
    px_person_rec.party_rec.attribute14:= p_person_obj.attribute14;
    px_person_rec.party_rec.attribute15:= p_person_obj.attribute15;
    px_person_rec.party_rec.attribute16:= p_person_obj.attribute16;
    px_person_rec.party_rec.attribute17:= p_person_obj.attribute17;
    px_person_rec.party_rec.attribute18:= p_person_obj.attribute18;
    px_person_rec.party_rec.attribute19:= p_person_obj.attribute19;
    px_person_rec.party_rec.attribute20:= p_person_obj.attribute20;
    px_person_rec.party_rec.attribute21:= p_person_obj.attribute21;
    px_person_rec.party_rec.attribute22:= p_person_obj.attribute22;
    px_person_rec.party_rec.attribute23:= p_person_obj.attribute23;
    px_person_rec.party_rec.attribute24:= p_person_obj.attribute24;
  END assign_person_profile_rec;

  -- PRIVATE PROCEDURE assign_org_contact_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from org contact business object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_org_contact_obj    Organization contact business object.
  --     p_person_id          Person Id.
  --     p_related_org_id     Related organization Id.
  --     p_oc_id              Org contact Id.
  --     p_oc_os              Org contact original system.
  --     p_oc_osr             Org contact original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN OUT:
  --     px_org_contact_rec   Org contact plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_org_contact_rec(
    p_org_contact_obj            IN            HZ_ORG_CONTACT_BO,
    p_person_id                  IN            NUMBER,
    p_related_org_id             IN            NUMBER,
    p_oc_id                      IN            NUMBER,
    p_oc_os                      IN            VARCHAR2,
    p_oc_osr                     IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_org_contact_rec           IN OUT NOCOPY HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE
  ) IS
  BEGIN
    px_org_contact_rec.org_contact_id        := p_oc_id;
    px_org_contact_rec.comments              := p_org_contact_obj.comments;
    px_org_contact_rec.contact_number        := p_org_contact_obj.contact_number;
    px_org_contact_rec.department_code       := p_org_contact_obj.department_code;
    px_org_contact_rec.department            := p_org_contact_obj.department;
    px_org_contact_rec.title                 := p_org_contact_obj.title;
    px_org_contact_rec.job_title             := p_org_contact_obj.job_title;
    IF(p_org_contact_obj.decision_maker_flag in ('Y','N')) THEN
      px_org_contact_rec.decision_maker_flag   := p_org_contact_obj.decision_maker_flag;
    END IF;
    px_org_contact_rec.job_title_code        := p_org_contact_obj.job_title_code;
    IF(p_org_contact_obj.reference_use_flag in ('Y','N')) THEN
      px_org_contact_rec.reference_use_flag    := p_org_contact_obj.reference_use_flag;
    END IF;
    px_org_contact_rec.rank                  := p_org_contact_obj.rank;
    px_org_contact_rec.party_site_id         := p_org_contact_obj.party_site_id;
    px_org_contact_rec.attribute_category    := p_org_contact_obj.attribute_category;
    px_org_contact_rec.attribute1            := p_org_contact_obj.attribute1;
    px_org_contact_rec.attribute2            := p_org_contact_obj.attribute2;
    px_org_contact_rec.attribute3            := p_org_contact_obj.attribute3;
    px_org_contact_rec.attribute4            := p_org_contact_obj.attribute4;
    px_org_contact_rec.attribute5            := p_org_contact_obj.attribute5;
    px_org_contact_rec.attribute6            := p_org_contact_obj.attribute6;
    px_org_contact_rec.attribute7            := p_org_contact_obj.attribute7;
    px_org_contact_rec.attribute8            := p_org_contact_obj.attribute8;
    px_org_contact_rec.attribute9            := p_org_contact_obj.attribute9;
    px_org_contact_rec.attribute10           := p_org_contact_obj.attribute10;
    px_org_contact_rec.attribute11           := p_org_contact_obj.attribute11;
    px_org_contact_rec.attribute12           := p_org_contact_obj.attribute12;
    px_org_contact_rec.attribute13           := p_org_contact_obj.attribute13;
    px_org_contact_rec.attribute14           := p_org_contact_obj.attribute14;
    px_org_contact_rec.attribute15           := p_org_contact_obj.attribute15;
    px_org_contact_rec.attribute16           := p_org_contact_obj.attribute16;
    px_org_contact_rec.attribute17           := p_org_contact_obj.attribute17;
    px_org_contact_rec.attribute18           := p_org_contact_obj.attribute18;
    px_org_contact_rec.attribute19           := p_org_contact_obj.attribute19;
    px_org_contact_rec.attribute20           := p_org_contact_obj.attribute20;
    px_org_contact_rec.attribute21           := p_org_contact_obj.attribute21;
    px_org_contact_rec.attribute22           := p_org_contact_obj.attribute22;
    px_org_contact_rec.attribute23           := p_org_contact_obj.attribute23;
    px_org_contact_rec.attribute24           := p_org_contact_obj.attribute24;
    IF(p_create_or_update = 'C') THEN
      px_org_contact_rec.orig_system           := p_oc_os;
      px_org_contact_rec.orig_system_reference := p_oc_osr;
      px_org_contact_rec.created_by_module     := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_org_contact_rec.party_rel_rec.subject_id          := p_person_id;
    px_org_contact_rec.party_rel_rec.subject_type        := 'PERSON';
    px_org_contact_rec.party_rel_rec.subject_table_name  := 'HZ_PARTIES';
    px_org_contact_rec.party_rel_rec.object_id           := p_related_org_id;
    px_org_contact_rec.party_rel_rec.object_type         := 'ORGANIZATION';
    px_org_contact_rec.party_rel_rec.object_table_name   := 'HZ_PARTIES';
    px_org_contact_rec.party_rel_rec.relationship_code   := p_org_contact_obj.relationship_code;
    px_org_contact_rec.party_rel_rec.relationship_type   := p_org_contact_obj.relationship_type;
    px_org_contact_rec.party_rel_rec.comments            := p_org_contact_obj.relationship_comments;
    px_org_contact_rec.party_rel_rec.start_date          := p_org_contact_obj.start_date;
    px_org_contact_rec.party_rel_rec.end_date            := p_org_contact_obj.end_date;
    px_org_contact_rec.party_rel_rec.status              := p_org_contact_obj.status;
    IF(p_create_or_update = 'C') THEN
      px_org_contact_rec.party_rel_rec.created_by_module   := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
  END assign_org_contact_rec;

  -- PROCEDURE do_create_org_contact_bo
  --
  -- DESCRIPTION
  --     Creates org contact business object.
  PROCEDURE do_create_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN OUT NOCOPY HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30);
    l_org_contact_rec          HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
    l_org_contact_role_rec     HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE;
    l_party_rel_id             NUMBER;
    l_party_id                 NUMBER;         -- party_id of the relationship for org contact
    l_party_os                 VARCHAR2(30);
    l_party_osr                VARCHAR2(255);
    l_party_number             VARCHAR2(30);
    l_per_party_id             NUMBER;         -- party_id of the person when create org contact
    l_per_party_os             VARCHAR2(30);
    l_per_party_osr            VARCHAR2(255);
    l_per_party_num            VARCHAR2(30);
    l_parent_os                VARCHAR2(30);
    l_valid_obj                BOOLEAN;
    l_person_rec               HZ_PARTY_V2PUB.PERSON_REC_TYPE;
    l_profile_id               NUMBER;
    l_valid_per                VARCHAR2(1);
    l_bus_object               HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_errorcode                NUMBER;
    l_cbm                      VARCHAR2(30);
    l_edi_objs                 HZ_EDI_CP_BO_TBL;
    l_eft_objs                 HZ_EFT_CP_BO_TBL;

    CURSOR get_per_id(l_os VARCHAR2, l_osr VARCHAR2) IS
    SELECT per.party_id
    FROM HZ_PARTIES per, HZ_ORIG_SYS_REFERENCES ref
    WHERE ref.owner_table_id = per.party_id
    AND ref.owner_table_name = 'HZ_PARTIES'
    AND ref.orig_system = l_os
    AND ref.orig_system_reference = l_osr
    AND ref.status = 'A'
    AND rownum = 1;

    CURSOR validate_per_id(l_per_id NUMBER) IS
    SELECT 'X'
    FROM HZ_PARTIES
    WHERE party_id = l_per_id
    AND party_type = 'PERSON'
    AND status in ('A','I');
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_org_contact_bo_pub;

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
        hz_utility_v2pub.debug(p_message=>'do_create_org_contact_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Base on p_validate_bo_flag check completeness of business object
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'ORG_CONTACT',
        x_bus_object              => l_bus_object
      );
      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_oc_bo_comp(
                       p_oc_objs    => HZ_ORG_CONTACT_BO_TBL(p_org_contact_obj),
                       p_bus_object => l_bus_object
                     );
      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- check pass in parent_id and parent_os+osr
    -- parent of org contact is always ORGANIZATION
    hz_registry_validate_bo_pvt.validate_parent_id(
      px_parent_id      => px_parent_org_id,
      px_parent_os      => px_parent_org_os,
      px_parent_osr     => px_parent_org_osr,
      p_parent_obj_type => 'ORG',
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_org_contact_id := p_org_contact_obj.org_contact_id;
    x_org_contact_os := p_org_contact_obj.orig_system;
    x_org_contact_osr := p_org_contact_obj.orig_system_reference;

    -- check if pass in org_contact_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_org_contact_id,
      px_os              => x_org_contact_os,
      px_osr             => x_org_contact_osr,
      p_obj_type         => 'HZ_ORG_CONTACTS',
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(p_org_contact_obj.person_profile_obj IS NULL) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
      fnd_message.set_token('ENTITY' ,'PERSON_CONTACT');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_per_party_id := p_org_contact_obj.person_profile_obj.person_id;
    l_per_party_os := p_org_contact_obj.person_profile_obj.orig_system;
    l_per_party_osr := p_org_contact_obj.person_profile_obj.orig_system_reference;

    IF(l_per_party_id IS NULL) THEN
      OPEN get_per_id(l_per_party_os, l_per_party_osr);
      FETCH get_per_id INTO l_per_party_id;
      CLOSE get_per_id;
    ELSE
      OPEN validate_per_id(l_per_party_id);
      FETCH validate_per_id INTO l_valid_per;
      CLOSE validate_per_id;
      IF(l_valid_per IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_CANNOT_PASS_PK');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- IF l_per_party_id does not exist, can create person
    -- IF l_per_party_id exist, use per_party_id when create org contact
    IF(l_per_party_id IS NULL) THEN
      ------------------------
      -- Call person bo_pub api
      ------------------------
      assign_person_profile_rec(
        p_person_obj         => p_org_contact_obj.person_profile_obj,
        p_person_id          => l_per_party_id,
        p_person_os          => l_per_party_os,
        p_person_osr         => l_per_party_osr,
        px_person_rec        => l_person_rec
      );

      HZ_PARTY_V2PUB.create_person(
        p_person_rec                => l_person_rec,
        x_party_id                  => l_per_party_id,
        x_party_number              => l_per_party_num,
        x_profile_id                => l_profile_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign person_id
      p_org_contact_obj.person_profile_obj.person_id := l_per_party_id;
      --------------------------
      -- Create Person Ext Attrs
      --------------------------
      IF((p_org_contact_obj.person_profile_obj.ext_attributes_objs IS NOT NULL) AND
         (p_org_contact_obj.person_profile_obj.ext_attributes_objs.COUNT > 0)) THEN
        HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
          p_ext_attr_objs             => p_org_contact_obj.person_profile_obj.ext_attributes_objs,
          p_parent_obj_id             => l_per_party_id,
          p_parent_obj_type           => 'PERSON',
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
    END IF;

    ----------------------------
    -- Assign org contact record
    ----------------------------
    assign_org_contact_rec(
      p_org_contact_obj           => p_org_contact_obj,
      p_person_id                 => l_per_party_id,
      p_related_org_id            => px_parent_org_id,
      p_oc_id                     => x_org_contact_id,
      p_oc_os                     => x_org_contact_os,
      p_oc_osr                    => x_org_contact_osr,
      px_org_contact_rec          => l_org_contact_rec
    );

    HZ_PARTY_CONTACT_V2PUB.create_org_contact(
      p_org_contact_rec           => l_org_contact_rec,
      x_org_contact_id            => x_org_contact_id,
      x_party_rel_id              => l_party_rel_id,
      x_party_id                  => l_party_id,
      x_party_number              => l_party_number,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign org_contact_id
    p_org_contact_obj.org_contact_id := x_org_contact_id;
    ---------------------------
    -- Create org contact roles
    ---------------------------
    IF((p_org_contact_obj.org_contact_role_objs IS NOT NULL) AND
       (p_org_contact_obj.org_contact_role_objs.COUNT > 0)) THEN
      HZ_ORG_CONTACT_BO_PVT.create_org_contact_roles(
        p_ocr_objs           => p_org_contact_obj.org_contact_role_objs,
        p_oc_id              => x_org_contact_id,
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
    -- Create party sites
    ---------------------
    IF((p_org_contact_obj.party_site_objs IS NOT NULL) AND
       (p_org_contact_obj.party_site_objs.COUNT > 0)) THEN
      HZ_PARTY_SITE_BO_PVT.save_party_sites(
        p_ps_objs            => p_org_contact_obj.party_site_objs,
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_id          => l_party_id,
        p_parent_os          => l_party_os,
        p_parent_osr         => l_party_osr,
        p_parent_obj_type    => 'ORG_CONTACT'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ----------------------------------------------------------
    -- Create all contact points - phone, telex, email and web
    ----------------------------------------------------------
    IF(((p_org_contact_obj.phone_objs IS NOT NULL) AND (p_org_contact_obj.phone_objs.COUNT > 0)) OR
       ((p_org_contact_obj.telex_objs IS NOT NULL) AND (p_org_contact_obj.telex_objs.COUNT > 0)) OR
       ((p_org_contact_obj.email_objs IS NOT NULL) AND (p_org_contact_obj.email_objs.COUNT > 0)) OR
       ((p_org_contact_obj.web_objs IS NOT NULL) AND (p_org_contact_obj.web_objs.COUNT > 0)) OR
       ((p_org_contact_obj.sms_objs IS NOT NULL) AND (p_org_contact_obj.sms_objs.COUNT > 0))) THEN
      HZ_CONTACT_POINT_BO_PVT.save_contact_points(
        p_phone_objs         => p_org_contact_obj.phone_objs,
        p_telex_objs         => p_org_contact_obj.telex_objs,
        p_email_objs         => p_org_contact_obj.email_objs,
        p_web_objs           => p_org_contact_obj.web_objs,
        p_edi_objs           => l_edi_objs,
        p_eft_objs           => l_eft_objs,
        p_sms_objs           => p_org_contact_obj.sms_objs,
        p_owner_table_id     => l_party_id,
        p_owner_table_os     => l_party_os,
        p_owner_table_osr    => l_party_osr,
        p_parent_obj_type    => 'ORG_CONTACT',
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
    -- Create contact preference
    ----------------------------
    IF((p_org_contact_obj.contact_pref_objs IS NOT NULL) AND
       (p_org_contact_obj.contact_pref_objs.COUNT > 0)) THEN
      HZ_CONTACT_PREFERENCE_BO_PVT.create_contact_preferences(
        p_cp_pref_objs           => p_org_contact_obj.contact_pref_objs,
        p_contact_level_table_id => l_party_id,
        p_contact_level_table    => 'HZ_PARTIES',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
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
        hz_utility_v2pub.debug(p_message=>'do_create_org_contact_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_org_contact_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG_CONTACT');
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
        hz_utility_v2pub.debug(p_message=>'do_create_org_contact_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_org_contact_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG_CONTACT');
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
        hz_utility_v2pub.debug(p_message=>'do_create_org_contact_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_org_contact_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG_CONTACT');
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
        hz_utility_v2pub.debug(p_message=>'do_create_org_contact_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_org_contact_bo;

  PROCEDURE create_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  ) IS
    l_oc_obj              HZ_ORG_CONTACT_BO;
  BEGIN
    l_oc_obj := p_org_contact_obj;
    do_create_org_contact_bo(
      p_init_msg_list       => p_init_msg_list,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_org_contact_obj     => l_oc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_org_contact_id      => x_org_contact_id,
      x_org_contact_os      => x_org_contact_os,
      x_org_contact_osr     => x_org_contact_osr,
      px_parent_org_id      => px_parent_org_id,
      px_parent_org_os      => px_parent_org_os,
      px_parent_org_osr     => px_parent_org_osr
    );
  END create_org_contact_bo;

  PROCEDURE create_org_contact_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORG_CONTACT_BO,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_oc_obj              HZ_ORG_CONTACT_BO;
  BEGIN
    l_oc_obj := p_org_contact_obj;
    do_create_org_contact_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_org_contact_obj     => l_oc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_org_contact_id      => x_org_contact_id,
      x_org_contact_os      => x_org_contact_os,
      x_org_contact_osr     => x_org_contact_osr,
      px_parent_org_id      => px_parent_org_id,
      px_parent_org_os      => px_parent_org_os,
      px_parent_org_osr     => px_parent_org_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_oc_obj;
    END IF;
  END create_org_contact_bo;

  -- PROCEDURE update_org_contact_bo
  --
  -- DESCRIPTION
  --     Update org contact business object.
  PROCEDURE update_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2
  )IS
    l_oc_obj              HZ_ORG_CONTACT_BO;
  BEGIN
    l_oc_obj := p_org_contact_obj;
    do_update_org_contact_bo(
      p_init_msg_list       => p_init_msg_list,
      p_org_contact_obj     => l_oc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_org_contact_id      => x_org_contact_id,
      x_org_contact_os      => x_org_contact_os,
      x_org_contact_osr     => x_org_contact_osr,
      p_parent_os           => NULL
    );
  END update_org_contact_bo;

  PROCEDURE update_org_contact_bo(
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORG_CONTACT_BO,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_oc_obj              HZ_ORG_CONTACT_BO;
  BEGIN
    l_oc_obj := p_org_contact_obj;
    do_update_org_contact_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_org_contact_obj     => l_oc_obj,
      p_created_by_module   => p_created_by_module,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_org_contact_id      => x_org_contact_id,
      x_org_contact_os      => x_org_contact_os,
      x_org_contact_osr     => x_org_contact_osr,
      p_parent_os           => NULL
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_oc_obj;
    END IF;
  END update_org_contact_bo;

  -- PRIVATE PROCEDURE do_update_org_contact_bo
  --
  -- DESCRIPTION
  --     Update org contact business object.
  PROCEDURE do_update_org_contact_bo(
    p_init_msg_list       IN         VARCHAR2 := fnd_api.g_false,
    p_org_contact_obj     IN OUT NOCOPY HZ_ORG_CONTACT_BO,
    p_created_by_module   IN         VARCHAR2,
    p_obj_source          IN         VARCHAR2 := null,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_org_contact_id      OUT NOCOPY NUMBER,
    x_org_contact_os      OUT NOCOPY VARCHAR2,
    x_org_contact_osr     OUT NOCOPY VARCHAR2,
    p_parent_os           IN         VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30);
    l_org_contact_rec          HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
    l_oc_id                    NUMBER;
    l_oc_ovn                   NUMBER;
    l_rel_ovn                  NUMBER;
    l_pty_ovn                  NUMBER;
    l_create_update_flag       VARCHAR2(1);
    l_person_id                NUMBER;
    l_person_os                VARCHAR2(30);
    l_person_osr               VARCHAR2(255);
    l_oc_party_id              NUMBER;
    l_oc_party_os              VARCHAR2(30);
    l_oc_party_osr             VARCHAR2(255);
    l_parent_os                VARCHAR2(30);
    l_person_rec               HZ_PARTY_V2PUB.PERSON_REC_TYPE;
    l_profile_id               NUMBER;
    l_per_ovn                  NUMBER;
    l_related_org_id           NUMBER;
    l_errorcode                NUMBER;
    l_cbm                      VARCHAR2(30);
    l_edi_objs                 HZ_EDI_CP_BO_TBL;
    l_eft_objs                 HZ_EFT_CP_BO_TBL;

    CURSOR get_ovn(l_oc_id  NUMBER) IS
    SELECT oc.object_version_number, rel.object_version_number, p.object_version_number,
           p.party_id, rel.object_id, rel.subject_id
    FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS rel, HZ_PARTIES p
    WHERE oc.org_contact_id = l_oc_id
    AND oc.party_relationship_id = rel.relationship_id
    AND rel.party_id = p.party_id
    AND rel.subject_type = 'PERSON'
    AND rel.object_type = 'ORGANIZATION'
    AND rel.status in ('A','I')
    AND p.status in ('A','I');

    CURSOR get_per_ovn(l_per_id NUMBER) IS
    SELECT object_version_number
    FROM HZ_PARTIES
    WHERE party_id = l_per_id
    AND status in ('A','I');

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_org_contact_bo_pub;

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
        hz_utility_v2pub.debug(p_message=>'do_update_org_contact_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_org_contact_id := p_org_contact_obj.org_contact_id;
    x_org_contact_os := p_org_contact_obj.orig_system;
    x_org_contact_osr := p_org_contact_obj.orig_system_reference;

    -- check if pass in org_contact_id and ssm is
    -- valid for update
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_org_contact_id,
      px_os              => x_org_contact_os,
      px_osr             => x_org_contact_osr,
      p_obj_type         => 'HZ_ORG_CONTACTS',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN get_ovn(x_org_contact_id);
    FETCH get_ovn INTO l_oc_ovn, l_rel_ovn, l_pty_ovn, l_oc_party_id, l_related_org_id, l_person_id;
    CLOSE get_ovn;

    -------------
    -- For Person
    -------------
    IF(p_org_contact_obj.person_profile_obj IS NOT NULL) THEN
      -- check if pass in person_id and ssm is valid for update
      --l_person_id := p_org_contact_obj.person_profile_obj.person_id;
      l_person_os := p_org_contact_obj.person_profile_obj.orig_system;
      l_person_osr := p_org_contact_obj.person_profile_obj.orig_system_reference;

      IF(l_person_id IS NOT NULL OR
        (l_person_os IS NOT NULL AND l_person_osr IS NOT NULL)) THEN
        hz_registry_validate_bo_pvt.validate_ssm_id(
          px_id              => l_person_id,
          px_os              => l_person_os,
          px_osr             => l_person_osr,
          p_obj_type         => 'PERSON',
          p_create_or_update => 'U',
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- call v2api to update
        assign_person_profile_rec(
          p_person_obj         => p_org_contact_obj.person_profile_obj,
          p_person_id          => l_person_id,
          p_person_os          => l_person_os,
          p_person_osr         => l_person_osr,
          p_create_or_update   => 'U',
          px_person_rec        => l_person_rec
        );

        OPEN get_per_ovn(l_person_id);
        FETCH get_per_ovn INTO l_per_ovn;
        CLOSE get_per_ovn;

        HZ_PARTY_V2PUB.update_person(
          p_person_rec                => l_person_rec,
          p_party_object_version_number  => l_per_ovn,
          x_profile_id                => l_profile_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -----------------------
        -- For Person Ext Attrs
        -----------------------
        IF((p_org_contact_obj.person_profile_obj.ext_attributes_objs IS NOT NULL) AND
           (p_org_contact_obj.person_profile_obj.ext_attributes_objs.COUNT > 0)) THEN
          HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
            p_ext_attr_objs             => p_org_contact_obj.person_profile_obj.ext_attributes_objs,
            p_parent_obj_id             => l_person_id,
            p_parent_obj_type           => 'PERSON',
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
    END IF;

    -------------------------
    -- For Update Org Contact
    -------------------------
    -- Assign org contact record
    assign_org_contact_rec(
      p_org_contact_obj   => p_org_contact_obj,
      p_person_id         => l_person_id,
      p_related_org_id    => l_related_org_id,
      p_oc_id             => x_org_contact_id,
      p_oc_os             => x_org_contact_os,
      p_oc_osr            => x_org_contact_osr,
      p_create_or_update  => 'U',
      px_org_contact_rec  => l_org_contact_rec
    );

    HZ_PARTY_CONTACT_V2PUB.update_org_contact(
      p_org_contact_rec             => l_org_contact_rec,
      p_cont_object_version_number  => l_oc_ovn,
      p_rel_object_version_number   => l_rel_ovn,
      p_party_object_version_number => l_pty_ovn,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign org_contact_id
    p_org_contact_obj.org_contact_id := x_org_contact_id;
    ------------------------
    -- For Org Contact Roles
    ------------------------
    IF((p_org_contact_obj.org_contact_role_objs IS NOT NULL) AND
       (p_org_contact_obj.org_contact_role_objs.COUNT > 0)) THEN
      HZ_ORG_CONTACT_BO_PVT.save_org_contact_roles(
        p_ocr_objs           => p_org_contact_obj.org_contact_role_objs,
        p_oc_id              => x_org_contact_id,
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
    -- Update party sites
    ---------------------
    IF((p_org_contact_obj.party_site_objs IS NOT NULL) AND
       (p_org_contact_obj.party_site_objs.COUNT > 0)) THEN
      HZ_PARTY_SITE_BO_PVT.save_party_sites(
        p_ps_objs            => p_org_contact_obj.party_site_objs,
        p_create_update_flag => 'U',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_id          => l_oc_party_id,
        p_parent_os          => NULL,
        p_parent_osr         => NULL,
        p_parent_obj_type    => 'ORG_CONTACT'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -- Owner table id of contact point should be the party of the relationship for org contact
    -- Therefore, should pass in party_id as p_owner_table_id
    -- Same situation apply to p_owner_table_os, p_owner_table_osr
    ---------------------
    -- For Contact Points
    ---------------------
    IF(((p_org_contact_obj.phone_objs IS NOT NULL) AND (p_org_contact_obj.phone_objs.COUNT > 0)) OR
       ((p_org_contact_obj.telex_objs IS NOT NULL) AND (p_org_contact_obj.telex_objs.COUNT > 0)) OR
       ((p_org_contact_obj.email_objs IS NOT NULL) AND (p_org_contact_obj.email_objs.COUNT > 0)) OR
       ((p_org_contact_obj.web_objs IS NOT NULL) AND (p_org_contact_obj.web_objs.COUNT > 0)) OR
       ((p_org_contact_obj.sms_objs IS NOT NULL) AND (p_org_contact_obj.sms_objs.COUNT > 0))) THEN
      HZ_CONTACT_POINT_BO_PVT.save_contact_points(
        p_phone_objs         => p_org_contact_obj.phone_objs,
        p_telex_objs         => p_org_contact_obj.telex_objs,
        p_email_objs         => p_org_contact_obj.email_objs,
        p_web_objs           => p_org_contact_obj.web_objs,
        p_edi_objs           => l_edi_objs,
        p_eft_objs           => l_eft_objs,
        p_sms_objs           => p_org_contact_obj.sms_objs,
        p_owner_table_id     => l_oc_party_id,
        p_owner_table_os     => NULL,
        p_owner_table_osr    => NULL,
        p_parent_obj_type    => 'ORG_CONTACT',
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
    IF((p_org_contact_obj.contact_pref_objs IS NOT NULL) AND
       (p_org_contact_obj.contact_pref_objs.COUNT > 0)) THEN
      HZ_CONTACT_PREFERENCE_BO_PVT.save_contact_preferences(
        p_cp_pref_objs           => p_org_contact_obj.contact_pref_objs,
        p_contact_level_table_id => l_oc_party_id,
        p_contact_level_table    => 'HZ_PARTIES',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
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
        hz_utility_v2pub.debug(p_message=>'do_update_org_contact_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_org_contact_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG_CONTACT');
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
        hz_utility_v2pub.debug(p_message=>'do_update_org_contact_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_org_contact_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG_CONTACT');
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
        hz_utility_v2pub.debug(p_message=>'do_update_org_contact_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_org_contact_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG_CONTACT');
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
        hz_utility_v2pub.debug(p_message=>'do_update_org_contact_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_org_contact_bo;

  -- PROCEDURE do_save_org_contact_bo
  --
  -- DESCRIPTION
  --     Creates or update org contact business object.
  PROCEDURE do_save_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN OUT NOCOPY HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN         VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  ) IS
    l_return_status            VARCHAR2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_create_update_flag       VARCHAR2(1);
    l_debug_prefix             VARCHAR2(30);
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_org_contact_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_org_contact_id := p_org_contact_obj.org_contact_id;
    x_org_contact_os := p_org_contact_obj.orig_system;
    x_org_contact_osr := p_org_contact_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => x_org_contact_id,
                              p_entity_os      => x_org_contact_os,
                              p_entity_osr     => x_org_contact_osr,
                              p_entity_type    => 'HZ_ORG_CONTACTS',
                              p_parent_id      => px_parent_org_id,
                              p_parent_obj_type => 'ORG'
                            );

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG_CONTACT');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_org_contact_bo(
        p_init_msg_list      => fnd_api.g_false,
        p_validate_bo_flag   => p_validate_bo_flag,
        p_org_contact_obj    => p_org_contact_obj,
        p_created_by_module  => p_created_by_module,
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        x_org_contact_id     => x_org_contact_id,
        x_org_contact_os     => x_org_contact_os,
        x_org_contact_osr    => x_org_contact_osr,
        px_parent_org_id     => px_parent_org_id,
        px_parent_org_os     => px_parent_org_os,
        px_parent_org_osr    => px_parent_org_osr
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_org_contact_bo(
        p_init_msg_list      => fnd_api.g_false,
        p_org_contact_obj    => p_org_contact_obj,
        p_created_by_module  => p_created_by_module,
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        x_org_contact_id     => x_org_contact_id,
        x_org_contact_os     => x_org_contact_os,
        x_org_contact_osr    => x_org_contact_osr,
        p_parent_os          => px_parent_org_os );
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
        hz_utility_v2pub.debug(p_message=>'do_save_org_contact_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_org_contact_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_org_contact_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_org_contact_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_org_contact_bo;

  PROCEDURE save_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  ) IS
    l_oc_obj              HZ_ORG_CONTACT_BO;
  BEGIN
    l_oc_obj := p_org_contact_obj;
    do_save_org_contact_bo(
      p_init_msg_list       => p_init_msg_list,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_org_contact_obj     => l_oc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_org_contact_id      => x_org_contact_id,
      x_org_contact_os      => x_org_contact_os,
      x_org_contact_osr     => x_org_contact_osr,
      px_parent_org_id      => px_parent_org_id,
      px_parent_org_os      => px_parent_org_os,
      px_parent_org_osr     => px_parent_org_osr
    );
  END save_org_contact_bo;

  PROCEDURE save_org_contact_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_org_contact_obj     IN            HZ_ORG_CONTACT_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORG_CONTACT_BO,
    x_org_contact_id      OUT NOCOPY    NUMBER,
    x_org_contact_os      OUT NOCOPY    VARCHAR2,
    x_org_contact_osr     OUT NOCOPY    VARCHAR2,
    px_parent_org_id      IN OUT NOCOPY NUMBER,
    px_parent_org_os      IN OUT NOCOPY VARCHAR2,
    px_parent_org_osr     IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_oc_obj              HZ_ORG_CONTACT_BO;
  BEGIN
    l_oc_obj := p_org_contact_obj;
    do_save_org_contact_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_org_contact_obj     => l_oc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_org_contact_id      => x_org_contact_id,
      x_org_contact_os      => x_org_contact_os,
      x_org_contact_osr     => x_org_contact_osr,
      px_parent_org_id      => px_parent_org_id,
      px_parent_org_os      => px_parent_org_os,
      px_parent_org_osr     => px_parent_org_osr);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_oc_obj;
    END IF;
  END save_org_contact_bo;

 --------------------------------------
  --
  -- PROCEDURE get_org_contact_bos
  --
  -- DESCRIPTION
  --     Get org contact information.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --       p_org_contact_id       Org Contact id.
 --     p_org_contact_os           Org contact orig system.
  --     p_org_contact_osr         Org contact orig system reference.
  --
  --   OUT:
  --     x_org contact_objs  Table of org contact objects.
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
  --   15-June-2005   AWU                Created.
  --



 PROCEDURE get_org_contact_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_org_contact_id		IN	NUMBER,
    p_org_contact_os		IN	VARCHAR2,
    p_org_contact_osr		IN	VARCHAR2,
    x_org_contact_obj    OUT NOCOPY    HZ_ORG_CONTACT_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_org_contact_id  number;
  l_org_contact_os  varchar2(30);
  l_org_contact_osr varchar2(255);
  l_org_contact_objs HZ_ORG_CONTACT_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_org_contact_bo_pub.get_org_contact_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_org_contact_id := p_org_contact_id;
    	l_org_contact_os := p_org_contact_os;
    	l_org_contact_osr := p_org_contact_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_org_contact_id,
      		px_os              => l_org_contact_os,
      		px_osr             => l_org_contact_osr,
      		p_obj_type         => 'HZ_ORG_CONTACTS',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_ORG_CONT_BO_PVT.get_org_contact_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_organization_id => NULL,
		 p_org_contact_id => l_org_contact_id,
		 p_action_type => NULL,
		  x_org_contact_objs => l_org_contact_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_org_contact_obj := l_org_contact_objs(1);
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
        	hz_utility_v2pub.debug(p_message=>'hz_org_contact_bo_pub.get_org_contact_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_org_contact_bo_pub.get_org_contact_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_org_contact_bo_pub.get_org_contact_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_org_contact_bo_pub.get_org_contact_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_org_contact_bo(
    p_org_contact_id            IN      NUMBER,
    p_org_contact_os            IN      VARCHAR2,
    p_org_contact_osr           IN      VARCHAR2,
    x_org_contact_obj    OUT NOCOPY    HZ_ORG_CONTACT_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
  BEGIN
    get_org_contact_bo(
      p_init_msg_list   => fnd_api.g_true,
      p_org_contact_id  => p_org_contact_id,
      p_org_contact_os  => p_org_contact_os,
      p_org_contact_osr => p_org_contact_osr,
      x_org_contact_obj => x_org_contact_obj,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_org_contact_bo;

END hz_org_contact_bo_pub;

/
