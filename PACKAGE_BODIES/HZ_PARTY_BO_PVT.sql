--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_BO_PVT" AS
/*$Header: ARHBPTVB.pls 120.21 2008/03/25 23:16:38 awu ship $ */

  G_BO_EVENTS_FORMAT CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('HZ_BO_EVENTS_FORMAT_BULK');
  G_EVENT_TYPE       CONSTANT VARCHAR2(30) := FND_PROFILE.VALUE('HZ_EXECUTE_API_CALLOUTS');

  PROCEDURE log(
    message      IN VARCHAR2,
    newline      IN BOOLEAN DEFAULT TRUE);

  PROCEDURE add_cust_tracking(
    p_party_id          IN NUMBER,
    p_bo_code           IN VARCHAR2,
    p_create_or_update  IN VARCHAR2);

  -- PROCEDURE set_hz_parties_bo_ver
  --
  -- DESCRIPTION
  --     Set BO_VERSION_NUMBER in HZ_PARTIES table.  This procedure
  --     will be called from Organization, Organization Customer,
  --     Person, Person Customer BO create API.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_id           Party Id.
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-OCT-2005    Arnold Ng          Created.
  --

  PROCEDURE set_hz_parties_bo_ver(
    p_party_id       IN NUMBER,
    p_bo_code        IN VARCHAR2
  );

  -- PRIVATE PROCEDURE assign_certification_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from certification object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_certification_obj  Certification object.
  --     p_party_id           Party Id.
  --   IN/OUT:
  --     px_certification_rec Certification plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_certification_rec(
    p_certification_obj          IN            HZ_CERTIFICATION_OBJ,
    p_party_id                   IN            NUMBER,
    px_certification_rec         IN OUT NOCOPY HZ_ORG_INFO_PUB.certifications_rec_type
  );

  -- PRIVATE PROCEDURE assign_financial_prof_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from financial profile object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_financial_prof_obj Financial profile object.
  --     p_party_id           Party Id.
  --   IN/OUT:
  --     px_financial_prof_rec Financial profile plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_financial_prof_rec(
    p_financial_prof_obj         IN            HZ_FINANCIAL_PROF_OBJ,
    p_party_id                   IN            NUMBER,
    px_financial_prof_rec        IN OUT NOCOPY HZ_PARTY_INFO_PUB.financial_profile_rec_type
  );

  -- PRIVATE PROCEDURE assign_code_assign_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from classification object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_code_assign_obj    Classification object.
  --     p_owner_table_name   Owner table name.
  --     p_owner_table_id     Owner table Id.
  --   IN/OUT:
  --     px_code_assign_rec   Classification plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_code_assign_rec(
    p_code_assign_obj            IN            HZ_CODE_ASSIGNMENT_OBJ,
    p_owner_table_name           IN            VARCHAR2,
    p_owner_table_id             IN            NUMBER,
    px_code_assign_rec           IN OUT NOCOPY HZ_CLASSIFICATION_V2PUB.code_assignment_rec_type
  );

  -- PRIVATE PROCEDURE assign_relationship_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from relationship object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_relationship_obj   Relationship object.
  --     p_subject_id         Subject Id.
  --     p_subject_type       Subject type.
  --     p_object_id          Object Id.
  --     p_object_type        Object type.
  --   IN/OUT:
  --     px_relationship_rec  Relationship plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_relationship_rec(
    p_relationship_obj           IN            HZ_RELATIONSHIP_OBJ,
    p_subject_id                 IN            NUMBER,
    p_subject_type               IN            VARCHAR2,
    p_object_id                  IN            NUMBER,
    p_object_type                IN            VARCHAR2,
    px_relationship_rec          IN OUT NOCOPY HZ_RELATIONSHIP_V2PUB.relationship_rec_type
  );

  -- PRIVATE PROCEDURE assign_certification_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from certification object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_certifiation_obj   Certification object.
  --     p_party_id           Party Id.
  --   IN/OUT:
  --     px_certification_rec Certification plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_certification_rec(
    p_certification_obj          IN            HZ_CERTIFICATION_OBJ,
    p_party_id                   IN            NUMBER,
    px_certification_rec         IN OUT NOCOPY HZ_ORG_INFO_PUB.certifications_rec_type
  ) IS
  BEGIN
    px_certification_rec.certification_id    := p_certification_obj.certification_id;
    px_certification_rec.certification_name  := p_certification_obj.certification_name;
    px_certification_rec.party_id            := p_party_id;
    px_certification_rec.current_status      := p_certification_obj.current_status;
    px_certification_rec.expires_on_date     := p_certification_obj.expires_on_date;
    px_certification_rec.grade               := p_certification_obj.grade;
    px_certification_rec.issued_by_authority := p_certification_obj.issued_by_authority;
    px_certification_rec.issued_on_date      := p_certification_obj.issued_on_date;
    px_certification_rec.status              := p_certification_obj.status;
  END assign_certification_rec;

  -- PRIVATE PROCEDURE assign_financial_prof_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from financial profile object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_financial_prof_obj Financial profile object.
  --     p_party_id           Party Id.
  --   IN/OUT:
  --     px_financial_prof_rec Financial profile plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_financial_prof_rec(
    p_financial_prof_obj         IN            HZ_FINANCIAL_PROF_OBJ,
    p_party_id                   IN            NUMBER,
    px_financial_prof_rec        IN OUT NOCOPY HZ_PARTY_INFO_PUB.financial_profile_rec_type
  ) IS
  BEGIN
    px_financial_prof_rec.financial_profile_id        := p_financial_prof_obj.financial_profile_id;
    px_financial_prof_rec.access_authority_date       := p_financial_prof_obj.access_authority_date;
    px_financial_prof_rec.access_authority_granted    := p_financial_prof_obj.access_authority_granted;
    px_financial_prof_rec.balance_amount              := p_financial_prof_obj.balance_amount;
    px_financial_prof_rec.balance_verified_on_date    := p_financial_prof_obj.balance_verified_on_date;
    px_financial_prof_rec.financial_account_number    := p_financial_prof_obj.financial_account_number;
    px_financial_prof_rec.financial_account_type      := p_financial_prof_obj.financial_account_type;
    px_financial_prof_rec.financial_org_type          := p_financial_prof_obj.financial_org_type;
    px_financial_prof_rec.financial_organization_name := p_financial_prof_obj.financial_organization_name;
    px_financial_prof_rec.party_id                    := p_party_id;
    px_financial_prof_rec.status                      := p_financial_prof_obj.status;
  END assign_financial_prof_rec;

  -- PRIVATE PROCEDURE assign_code_assign_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from classification object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_code_assign_obj    Classification object.
  --     p_owner_table_name   Owner table name.
  --     p_owner_table_id     Owner table Id.
  --   IN/OUT:
  --     px_code_assign_rec   Classification plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_code_assign_rec(
    p_code_assign_obj            IN            HZ_CODE_ASSIGNMENT_OBJ,
    p_owner_table_name           IN            VARCHAR2,
    p_owner_table_id             IN            NUMBER,
    px_code_assign_rec           IN OUT NOCOPY HZ_CLASSIFICATION_V2PUB.code_assignment_rec_type
  ) IS
  BEGIN
    px_code_assign_rec.code_assignment_id    := p_code_assign_obj.code_assignment_id;
    px_code_assign_rec.owner_table_name      := p_owner_table_name;
    px_code_assign_rec.owner_table_id        := p_owner_table_id;
    px_code_assign_rec.class_category        := p_code_assign_obj.class_category;
    px_code_assign_rec.class_code            := p_code_assign_obj.class_code;
    px_code_assign_rec.primary_flag          := p_code_assign_obj.primary_flag;
    px_code_assign_rec.start_date_active     := p_code_assign_obj.start_date_active;
    px_code_assign_rec.end_date_active       := p_code_assign_obj.end_date_active;
    px_code_assign_rec.status                := p_code_assign_obj.status;
    px_code_assign_rec.actual_content_source := p_code_assign_obj.actual_content_source;
    px_code_assign_rec.created_by_module     := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    px_code_assign_rec.rank                  := p_code_assign_obj.rank;
  END assign_code_assign_rec;

  -- PRIVATE PROCEDURE assign_relationship_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from relationship object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_relationship_obj   Relationship object.
  --     p_subject_id         Subject Id.
  --     p_subject_type       Subject type.
  --     p_object_id          Object Id.
  --     p_object_type        Object type.
  --   IN/OUT:
  --     px_relationship_rec  Relationship plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_relationship_rec(
    p_relationship_obj           IN            HZ_RELATIONSHIP_OBJ,
    p_subject_id                 IN            NUMBER,
    p_subject_type               IN            VARCHAR2,
    p_object_id                  IN            NUMBER,
    p_object_type                IN            VARCHAR2,
    px_relationship_rec          IN OUT NOCOPY HZ_RELATIONSHIP_V2PUB.relationship_rec_type
  ) IS
  BEGIN
    px_relationship_rec.relationship_id   := p_relationship_obj.relationship_id;
    px_relationship_rec.subject_id        := p_subject_id;
    px_relationship_rec.subject_type      := p_subject_type;
    px_relationship_rec.subject_table_name:= 'HZ_PARTIES';
    px_relationship_rec.object_id         := p_object_id;
    px_relationship_rec.object_type       := p_object_type;
    px_relationship_rec.object_table_name := 'HZ_PARTIES';
    px_relationship_rec.relationship_code := p_relationship_obj.relationship_code;
    px_relationship_rec.relationship_type := p_relationship_obj.relationship_type;
    px_relationship_rec.comments          := p_relationship_obj.comments;
    px_relationship_rec.start_date        := p_relationship_obj.start_date;
    px_relationship_rec.end_date          := p_relationship_obj.end_date;
    IF(p_relationship_obj.status in ('A','I')) THEN
      px_relationship_rec.status            := p_relationship_obj.status;
    END IF;
    px_relationship_rec.attribute_category  := p_relationship_obj.attribute_category;
    px_relationship_rec.attribute1        := p_relationship_obj.attribute1;
    px_relationship_rec.attribute2        := p_relationship_obj.attribute2;
    px_relationship_rec.attribute3        := p_relationship_obj.attribute3;
    px_relationship_rec.attribute4        := p_relationship_obj.attribute4;
    px_relationship_rec.attribute5        := p_relationship_obj.attribute5;
    px_relationship_rec.attribute6        := p_relationship_obj.attribute6;
    px_relationship_rec.attribute7        := p_relationship_obj.attribute7;
    px_relationship_rec.attribute8        := p_relationship_obj.attribute8;
    px_relationship_rec.attribute9        := p_relationship_obj.attribute9;
    px_relationship_rec.attribute10       := p_relationship_obj.attribute10;
    px_relationship_rec.attribute11       := p_relationship_obj.attribute11;
    px_relationship_rec.attribute12       := p_relationship_obj.attribute12;
    px_relationship_rec.attribute13       := p_relationship_obj.attribute13;
    px_relationship_rec.attribute14       := p_relationship_obj.attribute14;
    px_relationship_rec.attribute15       := p_relationship_obj.attribute15;
    px_relationship_rec.attribute16       := p_relationship_obj.attribute16;
    px_relationship_rec.attribute17       := p_relationship_obj.attribute17;
    px_relationship_rec.attribute18       := p_relationship_obj.attribute18;
    px_relationship_rec.attribute19       := p_relationship_obj.attribute19;
    px_relationship_rec.attribute20       := p_relationship_obj.attribute20;
    px_relationship_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
/*
    px_relationship_rec.party_rec.party_id       := p_relationship_obj.party_obj.party_id;
    px_relationship_rec.party_rec.party_number   := p_relationship_obj.party_obj.party_number;
    px_relationship_rec.party_rec.validated_flag := p_relationship_obj.party_obj.validated_flag;
    px_relationship_rec.party_rec.status         := p_relationship_obj.party_obj.status;
    px_relationship_rec.party_rec.category_code  := p_relationship_obj.party_obj.category_code;
    px_relationship_rec.party_rec.salutation     := p_relationship_obj.party_obj.salutation;
    px_relationship_rec.party_rec.attribute_category  := p_relationship_obj.party_obj.attribute_category;
    px_relationship_rec.party_rec.attribute1     := p_relationship_obj.party_obj.attribute1;
    px_relationship_rec.party_rec.attribute2     := p_relationship_obj.party_obj.attribute2;
    px_relationship_rec.party_rec.attribute3     := p_relationship_obj.party_obj.attribute3;
    px_relationship_rec.party_rec.attribute4     := p_relationship_obj.party_obj.attribute4;
    px_relationship_rec.party_rec.attribute5     := p_relationship_obj.party_obj.attribute5;
    px_relationship_rec.party_rec.attribute6     := p_relationship_obj.party_obj.attribute6;
    px_relationship_rec.party_rec.attribute7     := p_relationship_obj.party_obj.attribute7;
    px_relationship_rec.party_rec.attribute8     := p_relationship_obj.party_obj.attribute8;
    px_relationship_rec.party_rec.attribute9     := p_relationship_obj.party_obj.attribute9;
    px_relationship_rec.party_rec.attribute10    := p_relationship_obj.party_obj.attribute10;
    px_relationship_rec.party_rec.attribute11    := p_relationship_obj.party_obj.attribute11;
    px_relationship_rec.party_rec.attribute12    := p_relationship_obj.party_obj.attribute12;
    px_relationship_rec.party_rec.attribute13    := p_relationship_obj.party_obj.attribute13;
    px_relationship_rec.party_rec.attribute14    := p_relationship_obj.party_obj.attribute14;
    px_relationship_rec.party_rec.attribute15    := p_relationship_obj.party_obj.attribute15;
    px_relationship_rec.party_rec.attribute16    := p_relationship_obj.party_obj.attribute16;
    px_relationship_rec.party_rec.attribute17    := p_relationship_obj.party_obj.attribute17;
    px_relationship_rec.party_rec.attribute18    := p_relationship_obj.party_obj.attribute18;
    px_relationship_rec.party_rec.attribute19    := p_relationship_obj.party_obj.attribute19;
    px_relationship_rec.party_rec.attribute20    := p_relationship_obj.party_obj.attribute20;
    px_relationship_rec.party_rec.attribute21    := p_relationship_obj.party_obj.attribute21;
    px_relationship_rec.party_rec.attribute22    := p_relationship_obj.party_obj.attribute22;
    px_relationship_rec.party_rec.attribute23    := p_relationship_obj.party_obj.attribute23;
    px_relationship_rec.party_rec.attribute24    := p_relationship_obj.party_obj.attribute24;
    --px_relationship_rec.party_rec.orig_system    := p_relationship_obj.party_obj.source_system_objs(1).orig_system;
    --px_relationship_rec.party_rec.orig_system_reference := p_relationship_obj.party_obj.source_system_objs(1).orig_system_reference;
*/
    px_relationship_rec.additional_information1  := p_relationship_obj.additional_information1;
    px_relationship_rec.additional_information2  := p_relationship_obj.additional_information2;
    px_relationship_rec.additional_information3  := p_relationship_obj.additional_information3;
    px_relationship_rec.additional_information4  := p_relationship_obj.additional_information4;
    px_relationship_rec.additional_information5  := p_relationship_obj.additional_information5;
    px_relationship_rec.additional_information6  := p_relationship_obj.additional_information6;
    px_relationship_rec.additional_information7  := p_relationship_obj.additional_information7;
    px_relationship_rec.additional_information8  := p_relationship_obj.additional_information8;
    px_relationship_rec.additional_information9  := p_relationship_obj.additional_information9;
    px_relationship_rec.additional_information10 := p_relationship_obj.additional_information10;
    px_relationship_rec.additional_information11 := p_relationship_obj.additional_information11;
    px_relationship_rec.additional_information12 := p_relationship_obj.additional_information12;
    px_relationship_rec.additional_information13 := p_relationship_obj.additional_information13;
    px_relationship_rec.additional_information14 := p_relationship_obj.additional_information14;
    px_relationship_rec.additional_information15 := p_relationship_obj.additional_information15;
    px_relationship_rec.additional_information16 := p_relationship_obj.additional_information16;
    px_relationship_rec.additional_information17 := p_relationship_obj.additional_information17;
    px_relationship_rec.additional_information18 := p_relationship_obj.additional_information18;
    px_relationship_rec.additional_information19 := p_relationship_obj.additional_information19;
    px_relationship_rec.additional_information20 := p_relationship_obj.additional_information20;
    px_relationship_rec.additional_information21 := p_relationship_obj.additional_information21;
    px_relationship_rec.additional_information22 := p_relationship_obj.additional_information22;
    px_relationship_rec.additional_information23 := p_relationship_obj.additional_information23;
    px_relationship_rec.additional_information24 := p_relationship_obj.additional_information24;
    px_relationship_rec.additional_information25 := p_relationship_obj.additional_information25;
    px_relationship_rec.additional_information26 := p_relationship_obj.additional_information26;
    px_relationship_rec.additional_information27 := p_relationship_obj.additional_information27;
    px_relationship_rec.additional_information28 := p_relationship_obj.additional_information28;
    px_relationship_rec.additional_information29 := p_relationship_obj.additional_information29;
    px_relationship_rec.additional_information30 := p_relationship_obj.additional_information30;
    px_relationship_rec.percentage_ownership     := p_relationship_obj.percentage_ownership;
    px_relationship_rec.actual_content_source    := p_relationship_obj.actual_content_source;
  END assign_relationship_rec;

  -- PROCEDURE create_relationships
  --
  -- DESCRIPTION
  --     Create relationships.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_rel_objs           List of relationship objects.
  --     p_subject_id         Subject Id.
  --     p_subject_type       Subject type.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_relationships(
    p_rel_objs                   IN OUT NOCOPY HZ_RELATIONSHIP_OBJ_TBL,
    p_subject_id                 IN         NUMBER,
    p_subject_type               IN         VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_rel_id              NUMBER;
    l_party_id            NUMBER;
    l_party_number        VARCHAR2(30);
    l_rel_rec             HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    l_obj_id              NUMBER;
    l_obj_os              VARCHAR2(30);
    l_obj_osr             VARCHAR2(255);
    l_obj_type            VARCHAR2(30);
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_relationships_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_relationships(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create relationships
    FOR i IN 1..p_rel_objs.COUNT LOOP
      -- Get object id and os+osr
      l_obj_id := p_rel_objs(i).related_object_id;
      l_obj_os := p_rel_objs(i).related_object_os;
      l_obj_osr := p_rel_objs(i).related_object_osr;
      IF(p_rel_objs(i).related_object_type = 'ORG') THEN
        l_obj_type := 'ORGANIZATION';
      ELSE
        l_obj_type := 'PERSON';
      END IF;

      -- check if object id or os+osr is valid
      hz_registry_validate_bo_pvt.validate_ssm_id(
        px_id                => l_obj_id,
        px_os                => l_obj_os,
        px_osr               => l_obj_osr,
        p_obj_type           => l_obj_type,
        p_create_or_update   => 'U',
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data);

      IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        assign_relationship_rec(
          p_relationship_obj   => p_rel_objs(i),
          p_subject_id         => p_subject_id,
          p_subject_type       => p_subject_type,
          p_object_id          => l_obj_id,
          p_object_type        => l_obj_type,
          px_relationship_rec  => l_rel_rec
        );

        HZ_RELATIONSHIP_V2PUB.create_relationship(
          p_relationship_rec          => l_rel_rec,
          x_relationship_id           => l_rel_id,
          x_party_id                  => l_party_id,
          x_party_number              => l_party_number,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.create_relationships, subject id: '||p_subject_id||' object id: '||p_rel_objs(i).related_object_id,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- assign relationship_id and party_id
        p_rel_objs(i).relationship_id := l_rel_id;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_relationships(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_relationships_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'create_relationships(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_relationships_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'create_relationships(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_relationships_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'create_relationships(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_relationships;

  -- PROCEDURE save_relationships
  --
  -- DESCRIPTION
  --     Create or update relationships.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_rel_objs           List of relationship objects.
  --     p_subject_id         Subject Id.
  --     p_subject_type       Subject type.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_relationships(
    p_rel_objs                   IN OUT NOCOPY HZ_RELATIONSHIP_OBJ_TBL,
    p_subject_id                 IN         NUMBER,
    p_subject_type               IN         VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_rel_id              NUMBER;
    l_party_id            NUMBER;
    l_party_number        VARCHAR2(30);
    l_rel_rec             HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    l_ovn                 NUMBER := NULL;
    l_povn                NUMBER := NULL;
    l_obj_id              NUMBER;
    l_obj_os              VARCHAR2(30);
    l_obj_osr             VARCHAR2(255);
    l_obj_type            VARCHAR2(30);
/*
    CURSOR get_rel_party_ovn(l_subject_id NUMBER, l_object_id NUMBER,
                             l_relationship_type VARCHAR2, l_relationship_code VARCHAR2) IS
    SELECT p.object_version_number
    FROM HZ_RELATIONSHIPS rel, HZ_PARTIES p
    WHERE rel.subject_id = l_subject_id
    AND rel.object_id = l_object_id
    AND rel.relationship_type = l_relationship_type
    AND rel.relationship_code = l_relationship_code
    AND sysdate between rel.start_date and nvl(rel.end_date, sysdate)
    AND rel.party_id = p.party_id
    AND p.status in ('A','I');
*/
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_relationships_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_relationships(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update relationship
    FOR i IN 1..p_rel_objs.COUNT LOOP
      -- Get object id and os+osr
      l_obj_id := p_rel_objs(i).related_object_id;
      l_obj_os := p_rel_objs(i).related_object_os;
      l_obj_osr := p_rel_objs(i).related_object_osr;
      IF(p_rel_objs(i).related_object_type = 'ORG') THEN
        l_obj_type := 'ORGANIZATION';
      ELSE
        l_obj_type := 'PERSON';
      END IF;

      -- check if object id or os+osr is valid
      hz_registry_validate_bo_pvt.validate_ssm_id(
        px_id                => l_obj_id,
        px_os                => l_obj_os,
        px_osr               => l_obj_osr,
        p_obj_type           => l_obj_type,
        p_create_or_update   => 'U',
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data);

      IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        assign_relationship_rec(
          p_relationship_obj   => p_rel_objs(i),
          p_subject_id         => p_subject_id,
          p_subject_type       => p_subject_type,
          p_object_id          => l_obj_id,
          p_object_type        => l_obj_type,
          px_relationship_rec  => l_rel_rec
        );

        -- check if the relationship record is create or update
        hz_registry_validate_bo_pvt.check_relationship_op(
          p_subject_id          => p_subject_id,
          p_object_id           => l_rel_rec.object_id,
          px_relationship_id    => l_rel_rec.relationship_id,
          p_relationship_type   => l_rel_rec.relationship_type,
          p_relationship_code   => l_rel_rec.relationship_code,
          x_object_version_number => l_ovn,
          x_party_obj_version_number => l_povn
        );

        IF(l_rel_rec.relationship_id IS NULL) THEN
          HZ_RELATIONSHIP_V2PUB.create_relationship(
            p_relationship_rec          => l_rel_rec,
            x_relationship_id           => l_rel_id,
            x_party_id                  => l_party_id,
            x_party_number              => l_party_number,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
          );

          -- assign relationship_id and party_id
          p_rel_objs(i).relationship_id := l_rel_id;
        ELSE
          -- clean up created_by_module for update
          l_rel_rec.created_by_module := NULL;
          HZ_RELATIONSHIP_V2PUB.update_relationship(
            p_relationship_rec            => l_rel_rec,
            p_object_version_number       => l_ovn,
            p_party_object_version_number => l_povn,
            x_return_status               => x_return_status,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data
          );

          -- assign relationship_id and party_id
          p_rel_objs(i).relationship_id := l_rel_rec.relationship_id;
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.save_relationships, subject id: '||p_subject_id||' object id: '||p_rel_objs(i).related_object_id,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_relationships(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_relationships_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'save_relationships(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_relationships_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'save_relationships(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_relationships_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'save_relationships(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_relationships;

  PROCEDURE create_relationship_obj(
    p_init_msg_list       IN         VARCHAR2 := fnd_api.g_false,
    p_rel_obj             IN OUT NOCOPY HZ_RELATIONSHIP_OBJ,
    p_created_by_module   IN         VARCHAR2,
    x_relationship_id     OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_rel_rec             HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    l_subject_type        VARCHAR2(30);
    l_object_type         VARCHAR2(30);
    l_party_id            NUMBER;
    l_party_number        VARCHAR2(30);
    l_created_by_module   VARCHAR2(30);

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_relatobj_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_relatobj_pvt(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    IF(p_created_by_module IS NULL) THEN
       l_created_by_module := 'BO_API';
    ELSE
       l_created_by_module := p_created_by_module;
    END IF;

    IF(p_rel_obj.parent_object_type = 'ORG') THEN
      l_subject_type := 'ORGANIZATION';
    ELSE
      l_subject_type := p_rel_obj.parent_object_type;
    END IF;
    IF(p_rel_obj.related_object_type = 'ORG') THEN
      l_object_type := 'ORGANIZATION';
    ELSE
      l_object_type := p_rel_obj.related_object_type;
    END IF;

    assign_relationship_rec(
      p_relationship_obj   => p_rel_obj,
      p_subject_id         => p_rel_obj.parent_object_id,
      p_subject_type       => l_subject_type,
      p_object_id          => p_rel_obj.related_object_id,
      p_object_type        => l_object_type,
      px_relationship_rec  => l_rel_rec
    );
    l_rel_rec.created_by_module := l_created_by_module;

    HZ_RELATIONSHIP_V2PUB.create_relationship(
      p_relationship_rec   => l_rel_rec,
      x_relationship_id    => x_relationship_id,
      x_party_id           => l_party_id,
      x_party_number       => l_party_number,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.create_relationship_obj, subject id: '||p_rel_obj.parent_object_id||' object id: '||p_rel_obj.related_object_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign relationship_id and party_id
    p_rel_obj.relationship_id := x_relationship_id;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_relatobj_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'create_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_relatobj_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'create_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_relatobj_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'create_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_relationship_obj;

  PROCEDURE update_relationship_obj(
    p_init_msg_list       IN         VARCHAR2 := fnd_api.g_false,
    p_rel_obj             IN OUT NOCOPY HZ_RELATIONSHIP_OBJ,
    x_relationship_id     OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_rel_id              NUMBER;
    l_party_id            NUMBER;
    l_party_number        VARCHAR2(30);
    l_rel_rec             HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    l_subject_type        VARCHAR2(30);
    l_object_type         VARCHAR2(30);
    l_ovn                 NUMBER;
    l_povn                NUMBER;
    l_subject_id          NUMBER;
    l_object_id           NUMBER;

    CURSOR get_rel_by_id(l_rel_id NUMBER) IS
    SELECT relationship_id, nvl(rel.object_version_number,1), nvl(p.object_version_number,1)
    FROM HZ_RELATIONSHIPS rel, HZ_PARTIES p
    WHERE rel.relationship_id = l_rel_id
    AND rel.party_id = p.party_id
    AND rel.status in ('A','I')
    AND rownum = 1;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT update_relatobj_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_relatobj_pvt(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    IF(p_rel_obj.parent_object_type = 'ORG') THEN
      l_subject_type := 'ORGANIZATION';
    ELSE
      l_subject_type := p_rel_obj.parent_object_type;
    END IF;
    IF(p_rel_obj.related_object_type = 'ORG') THEN
      l_object_type := 'ORGANIZATION';
    ELSE
      l_object_type := p_rel_obj.related_object_type;
    END IF;

    -- user must pass in relationship_id
    OPEN get_rel_by_id(p_rel_obj.relationship_id);
    FETCH get_rel_by_id INTO x_relationship_id, l_ovn, l_povn;
    CLOSE get_rel_by_id;

    assign_relationship_rec(
      p_relationship_obj   => p_rel_obj,
      p_subject_id         => p_rel_obj.parent_object_id,
      p_subject_type       => l_subject_type,
      p_object_id          => p_rel_obj.related_object_id,
      p_object_type        => l_object_type,
      px_relationship_rec  => l_rel_rec
    );

    HZ_RELATIONSHIP_V2PUB.update_relationship(
      p_relationship_rec            => l_rel_rec,
      p_object_version_number       => l_ovn,
      p_party_object_version_number => l_povn,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
    );

    -- assign relationship_id
    p_rel_obj.relationship_id := x_relationship_id;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.update_relationship_obj, subject id: '||p_rel_obj.parent_object_id||' object id: '||p_rel_obj.related_object_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
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
        hz_utility_v2pub.debug(p_message=>'update_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_relatobj_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'update_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_relatobj_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'update_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO update_relatobj_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'update_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END update_relationship_obj;

  PROCEDURE save_relationship_obj(
    p_init_msg_list       IN         VARCHAR2 := fnd_api.g_false,
    p_rel_obj             IN OUT NOCOPY HZ_RELATIONSHIP_OBJ,
    p_created_by_module   IN         VARCHAR2,
    x_relationship_id     OUT NOCOPY NUMBER,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_rel_rec             HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    l_subject_type        VARCHAR2(30);
    l_object_type         VARCHAR2(30);
    l_ovn                 NUMBER;
    l_povn                NUMBER;
    l_party_id            NUMBER;
    l_party_number        VARCHAR2(30);
    l_subject_id          NUMBER;
    l_object_id           NUMBER;
    l_created_by_module   VARCHAR2(30);

    CURSOR get_rel_by_id(l_rel_id NUMBER) IS
    SELECT relationship_id, nvl(rel.object_version_number,1), nvl(p.object_version_number,1)
    FROM HZ_RELATIONSHIPS rel, HZ_PARTIES p
    WHERE rel.relationship_id = l_rel_id
    AND rel.party_id = p.party_id
    AND rel.status in ('A','I')
    AND rownum = 1;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_relatobj_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;


    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_relatobj_pvt(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    IF(p_created_by_module IS NULL) THEN
       l_created_by_module := 'BO_API';
    ELSE
       l_created_by_module := p_created_by_module;
    END IF;

    IF(p_rel_obj.parent_object_type = 'ORG') THEN
      l_subject_type := 'ORGANIZATION';
    ELSE
      l_subject_type := p_rel_obj.parent_object_type;
    END IF;
    IF(p_rel_obj.related_object_type = 'ORG') THEN
      l_object_type := 'ORGANIZATION';
    ELSE
      l_object_type := p_rel_obj.related_object_type;
    END IF;

    IF(p_rel_obj.relationship_id IS NOT NULL) THEN
      -- for update, get object version number of relationship and relationship party
      OPEN get_rel_by_id(p_rel_obj.relationship_id);
      FETCH get_rel_by_id INTO x_relationship_id, l_ovn, l_povn;
      CLOSE get_rel_by_id;
    END IF;

    assign_relationship_rec(
      p_relationship_obj   => p_rel_obj,
      p_subject_id         => p_rel_obj.parent_object_id,
      p_subject_type       => l_subject_type,
      p_object_id          => p_rel_obj.related_object_id,
      p_object_type        => l_object_type,
      px_relationship_rec  => l_rel_rec
    );

    IF(p_rel_obj.relationship_id IS NULL) THEN
      l_rel_rec.created_by_module := l_created_by_module;
      HZ_RELATIONSHIP_V2PUB.create_relationship(
        p_relationship_rec   => l_rel_rec,
        x_relationship_id    => x_relationship_id,
        x_party_id           => l_party_id,
        x_party_number       => l_party_number,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      -- assign relationship_id
      p_rel_obj.relationship_id := x_relationship_id;
    ELSE
      HZ_RELATIONSHIP_V2PUB.update_relationship(
        p_relationship_rec            => l_rel_rec,
        p_object_version_number       => l_ovn,
        p_party_object_version_number => l_povn,
        x_return_status               => x_return_status,
        x_msg_count                   => x_msg_count,
        x_msg_data                    => x_msg_data
      );

      -- assign relationship_id
      p_rel_obj.relationship_id := x_relationship_id;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.save_relationship_obj, subject id: '||p_rel_obj.parent_object_id||' object id: '||p_rel_obj.related_object_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
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
        hz_utility_v2pub.debug(p_message=>'save_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_relatobj_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'save_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_relatobj_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'save_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_relatobj_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_RELATIONSHIPS');
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
        hz_utility_v2pub.debug(p_message=>'save_relatobj_pvt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_relationship_obj;

  -- PROCEDURE get_relationship_obj
  --
  -- DESCRIPTION
  --     Get relationship.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_relationship_id    Relationship Id.
  --   OUT:
  --     x_relationship_obj   Relationship object.
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
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE get_relationship_obj(
    p_init_msg_list		 IN         VARCHAR2 := FND_API.G_FALSE,
    p_relationship_id            IN         NUMBER,
    x_relationship_obj           OUT NOCOPY HZ_RELATIONSHIP_OBJ,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix    VARCHAR2(30) := '';

    CURSOR c1(l_relationship_id NUMBER) IS
      SELECT HZ_RELATIONSHIP_OBJ(
        NULL, -- ACTION_TYPE
        NULL, --COMMON_OBJ_ID
        RELATIONSHIP_ID,
        DECODE(SUBJECT_TYPE, 'ORGANIZATION', 'ORG', SUBJECT_TYPE),
        SUBJECT_ID,
        OBJECT_ID,
        DECODE(OBJECT_TYPE, 'ORGANIZATION', 'ORG', OBJECT_TYPE),
        NULL, --OBJECT_ORIG_SYSTEM_REFERENCE,
        NULL, --OBJECT_ORIG_SYSTEM,
        RELATIONSHIP_CODE,
        RELATIONSHIP_TYPE,
        COMMENTS,
        START_DATE,
        END_DATE,
        STATUS,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
        ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
        ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
        ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19, ATTRIBUTE20,
        PROGRAM_UPDATE_DATE,
        CREATED_BY_MODULE,
        HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
        CREATION_DATE,
        LAST_UPDATE_DATE,
        HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
        ADDITIONAL_INFORMATION1, ADDITIONAL_INFORMATION2,
        ADDITIONAL_INFORMATION3, ADDITIONAL_INFORMATION4,
        ADDITIONAL_INFORMATION5, ADDITIONAL_INFORMATION6,
        ADDITIONAL_INFORMATION7, ADDITIONAL_INFORMATION8,
        ADDITIONAL_INFORMATION9, ADDITIONAL_INFORMATION10,
        ADDITIONAL_INFORMATION11, ADDITIONAL_INFORMATION12,
        ADDITIONAL_INFORMATION13, ADDITIONAL_INFORMATION14,
        ADDITIONAL_INFORMATION15, ADDITIONAL_INFORMATION16,
        ADDITIONAL_INFORMATION17, ADDITIONAL_INFORMATION18,
        ADDITIONAL_INFORMATION19, ADDITIONAL_INFORMATION20,
        ADDITIONAL_INFORMATION21, ADDITIONAL_INFORMATION22,
        ADDITIONAL_INFORMATION23, ADDITIONAL_INFORMATION24,
        ADDITIONAL_INFORMATION25, ADDITIONAL_INFORMATION26,
        ADDITIONAL_INFORMATION27, ADDITIONAL_INFORMATION28,
        ADDITIONAL_INFORMATION29, ADDITIONAL_INFORMATION30,
        PERCENTAGE_OWNERSHIP,
        ACTUAL_CONTENT_SOURCE,
        CAST(MULTISET (
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
          ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
          ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
          ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
          ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19, ATTRIBUTE20)
          FROM HZ_ORIG_SYS_REFERENCES OSR
          WHERE OSR.OWNER_TABLE_ID = REL.SUBJECT_ID
          AND OWNER_TABLE_NAME = 'HZ_PARTIES'
          AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL))
        FROM HZ_RELATIONSHIPS REL
        WHERE RELATIONSHIP_ID = l_relationship_id
        AND DIRECTIONAL_FLAG = 'F';

  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(p_message=>'hz_party_bo_pvt.get_relationship_obj (+)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;

    OPEN c1(p_relationship_id);
    FETCH c1 into x_relationship_obj;
    CLOSE c1;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                                             p_msg_data=>x_msg_data,
                                             p_msg_type=>'WARNING',
                                             p_msg_level=>fnd_log.level_exception);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(p_message=>'hz_party_bo_pvt.get_relationship_obj (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_relationship_obj (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_relationship_obj (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_relationship_obj (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END get_relationship_obj;

  -- PROCEDURE create_classifications
  --
  -- DESCRIPTION
  --     Create classifications.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_code_assign_objs   List of classification objects.
  -- PROCEDURE create_classifications
  --
  -- DESCRIPTION
  --     Create classifications.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_code_assign_objs   List of classification objects.
  --     p_owner_table_name   Owner table name.
  --     p_owner_table_id     Owner table Id.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_classifications(
    p_code_assign_objs           IN OUT NOCOPY hz_code_assignment_obj_tbl,
    p_owner_table_name           IN         VARCHAR2,
    p_owner_table_id             IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_code_assign_id      NUMBER;
    l_code_assign_rec     HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_classifications_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_classifications(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create code assignments
    FOR i IN 1..p_code_assign_objs.COUNT LOOP
      assign_code_assign_rec(
        p_code_assign_obj    => p_code_assign_objs(i),
        p_owner_table_name   => p_owner_table_name,
        p_owner_table_id     => p_owner_table_id,
        px_code_assign_rec   => l_code_assign_rec
      );

      HZ_CLASSIFICATION_V2PUB.create_code_assignment(
        p_code_assignment_rec       => l_code_assign_rec,
        x_code_assignment_id        => l_code_assign_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.create_classifications, owner table name: '||p_owner_table_name||' owner table id: '||p_owner_table_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign code_assignment_id
      p_code_assign_objs(i).code_assignment_id := l_code_assign_id;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_classifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_classifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CODE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'create_classifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_classifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CODE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'create_classifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_classifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CODE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'create_classifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_classifications;

  -- PROCEDURE save_classifications
  --
  -- DESCRIPTION
  --     Create or update classifications.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_code_assign_objs   List of classification objects.
  --     p_owner_table_name   Owner table name.
  --     p_owner_table_id     Owner table Id.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_classifications(
    p_code_assign_objs           IN OUT NOCOPY hz_code_assignment_obj_tbl,
    p_owner_table_name           IN         VARCHAR2,
    p_owner_table_id             IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_code_assign_id      NUMBER;
    l_code_assign_rec     HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE;
    l_ovn                 NUMBER := NULL;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_classifications_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_classifications(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update classification
    FOR i IN 1..p_code_assign_objs.COUNT LOOP
      assign_code_assign_rec(
        p_code_assign_obj    => p_code_assign_objs(i),
        p_owner_table_name   => p_owner_table_name,
        p_owner_table_id     => p_owner_table_id,
        px_code_assign_rec   => l_code_assign_rec
      );

      -- check if the code assignment record is create or update
      hz_registry_validate_bo_pvt.check_code_assign_op(
        p_owner_table_name    => p_owner_table_name,
        p_owner_table_id      => p_owner_table_id,
        px_code_assignment_id => l_code_assign_rec.code_assignment_id,
        p_class_category      => l_code_assign_rec.class_category,
        p_class_code          => l_code_assign_rec.class_code,
        x_object_version_number => l_ovn
      );

      IF (l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.check_code_assign_op, owner table name: '||p_owner_table_name||' owner table id: '||p_owner_table_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CODE_ASSIGNMENTS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_CLASSIFICATION_V2PUB.create_code_assignment(
          p_code_assignment_rec       => l_code_assign_rec,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data,
          x_code_assignment_id        => l_code_assign_id
        );

        -- assign code_assignment_id
        p_code_assign_objs(i).code_assignment_id := l_code_assign_id;
      ELSE
        -- clean up created_by_module for update
        l_code_assign_rec.created_by_module := NULL;
        HZ_CLASSIFICATION_V2PUB.update_code_assignment(
          p_code_assignment_rec       => l_code_assign_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign code_assignment_id
        p_code_assign_objs(i).code_assignment_id := l_code_assign_rec.code_assignment_id;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.save_classifications, owner table name: '||p_owner_table_name||' owner table id: '||p_owner_table_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_classifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_classifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CODE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'save_classifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_classifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CODE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'save_classifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO save_classifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CODE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'save_classifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_classifications;

  -- PROCEDURE create_certifications
  --
  -- DESCRIPTION
  --     Create certifications.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cert_objs          List of certification objects.
  --     p_party_id           Party Id.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_certifications(
    p_cert_objs                  IN OUT NOCOPY hz_certification_obj_tbl,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_cert_id             NUMBER;
    l_cert_rec            HZ_ORG_INFO_PUB.CERTIFICATIONS_REC_TYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_certifications_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_certifications(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create certification
    FOR i IN 1..p_cert_objs.COUNT LOOP
      assign_certification_rec(
        p_certification_obj  => p_cert_objs(i),
        p_party_id           => p_party_id,
        px_certification_rec => l_cert_rec
      );

      HZ_ORG_INFO_PUB.create_certifications(
        p_api_version               => 1.0,
        p_certifications_rec        => l_cert_rec,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data,
        x_certification_id          => l_cert_id
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.create_certifications, party id: '||p_party_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign certification_id
      p_cert_objs(i).certification_id := l_cert_id;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_certifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_certifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CERTIFICATIONS');
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
        hz_utility_v2pub.debug(p_message=>'create_certifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_certifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CERTIFICATIONS');
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
        hz_utility_v2pub.debug(p_message=>'create_certifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_certifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CERTIFICATIONS');
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
        hz_utility_v2pub.debug(p_message=>'create_certifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_certifications;

  -- PROCEDURE save_certifications
  --
  -- DESCRIPTION
  --     Create or update certifications.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cert_objs          List of certification objects.
  --     p_party_id           Party Id.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_certifications(
    p_cert_objs                  IN OUT NOCOPY hz_certification_obj_tbl,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_cert_id             NUMBER;
    l_cert_rec            HZ_ORG_INFO_PUB.CERTIFICATIONS_REC_TYPE;
    l_lud                 DATE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_certifications_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_certifications(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update classification
    FOR i IN 1..p_cert_objs.COUNT LOOP
      assign_certification_rec(
        p_certification_obj  => p_cert_objs(i),
        p_party_id           => p_party_id,
        px_certification_rec => l_cert_rec
      );

      -- check if the code assignment record is create or update
      hz_registry_validate_bo_pvt.check_certification_op(
        p_party_id            => p_party_id,
        px_certification_id   => l_cert_rec.certification_id,
        p_certification_name  => l_cert_rec.certification_name,
        x_last_update_date    => l_lud,
        x_return_status       => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.check_certification_op, party id: '||p_party_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CERTIFICATIONS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_lud IS NULL) THEN
        HZ_ORG_INFO_PUB.create_certifications(
          p_api_version               => 1.0,
          p_certifications_rec        => l_cert_rec,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data,
          x_certification_id          => l_cert_id
        );

        -- assign certification_id
        p_cert_objs(i).certification_id := l_cert_id;
      ELSE
        HZ_ORG_INFO_PUB.update_certifications(
          p_api_version               => 1.0,
          p_certifications_rec        => l_cert_rec,
          p_last_update_date          => l_lud,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign certification_id
        p_cert_objs(i).certification_id := l_cert_rec.certification_id;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.save_certifications, party id: '||p_party_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_certifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_certifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CERTIFICATIONS');
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
        hz_utility_v2pub.debug(p_message=>'save_certifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_certifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CERTIFICATIONS');
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
        hz_utility_v2pub.debug(p_message=>'save_certifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO save_certifications_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CERTIFICATIONS');
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
        hz_utility_v2pub.debug(p_message=>'save_certifications(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_certifications;

  -- PROCEDURE create_financial_profiles
  --
  -- DESCRIPTION
  --     Create financial profiles.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_fin_prof_objs      List of financial profile objects.
  --     p_party_id           Party Id.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_financial_profiles(
    p_fin_prof_objs              IN OUT NOCOPY hz_financial_prof_obj_tbl,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_fin_prof_id         NUMBER;
    l_fin_prof_rec        HZ_PARTY_INFO_PUB.FINANCIAL_PROFILE_REC_TYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_financial_profiles_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_financial_profiles(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create financial profiles
    FOR i IN 1..p_fin_prof_objs.COUNT LOOP
      assign_financial_prof_rec(
        p_financial_prof_obj => p_fin_prof_objs(i),
        p_party_id           => p_party_id,
        px_financial_prof_rec => l_fin_prof_rec
      );

      HZ_PARTY_INFO_PUB.create_financial_profile(
        p_api_version               => 1.0,
        p_financial_profile_rec     => l_fin_prof_rec,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data,
        x_financial_profile_id      => l_fin_prof_id
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.create_financial_profiles, party id: '||p_party_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign financial profile id
      p_fin_prof_objs(i).financial_profile_id := l_fin_prof_id;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_financial_profiles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_financial_profiles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_FINANCIAL_PROFILE');
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
        hz_utility_v2pub.debug(p_message=>'create_financial_profiles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_financial_profiles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_FINANCIAL_PROFILE');
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
        hz_utility_v2pub.debug(p_message=>'create_financial_profiles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_financial_profiles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_FINANCIAL_PROFILE');
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
        hz_utility_v2pub.debug(p_message=>'create_financial_profiles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_financial_profiles;

  -- PROCEDURE save_financial_profiles
  --
  -- DESCRIPTION
  --     Create or update financial profiles.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_fin_prof_objs      List of financial profile objects.
  --     p_party_id           Party Id.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_financial_profiles(
    p_fin_prof_objs              IN OUT NOCOPY hz_financial_prof_obj_tbl,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_fin_prof_id         NUMBER;
    l_fin_prof_rec        HZ_PARTY_INFO_PUB.FINANCIAL_PROFILE_REC_TYPE;
    l_lud                 DATE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_financial_profiles_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_financial_profiles(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update financial profiles
    FOR i IN 1..p_fin_prof_objs.COUNT LOOP
      assign_financial_prof_rec(
        p_financial_prof_obj => p_fin_prof_objs(i),
        p_party_id           => p_party_id,
        px_financial_prof_rec=> l_fin_prof_rec
      );

      -- check if the financial profile record is create or update
      hz_registry_validate_bo_pvt.check_financial_prof_op(
        p_party_id             => p_party_id,
        p_financial_profile_id => l_fin_prof_rec.financial_profile_id,
        x_last_update_date     => l_lud,
        x_return_status        => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.check_financial_prof_op, financial profile id: '||l_fin_prof_rec.financial_profile_id||', party id: '||p_party_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_FINANCIAL_PROFILE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_lud IS NULL) THEN
        HZ_PARTY_INFO_PUB.create_financial_profile(
          p_api_version               => 1.0,
          p_financial_profile_rec     => l_fin_prof_rec,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data,
          x_financial_profile_id      => l_fin_prof_id
        );

        -- assign financial_profile_id
        p_fin_prof_objs(i).financial_profile_id := l_fin_prof_id;
      ELSE
        HZ_PARTY_INFO_PUB.update_financial_profile(
          p_api_version               => 1.0,
          p_financial_profile_rec     => l_fin_prof_rec,
          p_last_update_date          => l_lud,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign financial_profile_id
        p_fin_prof_objs(i).financial_profile_id := l_fin_prof_rec.financial_profile_id;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.save_financial_profiles, party id: '||p_party_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_financial_profiles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_financial_profiles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_FINANCIAL_PROFILE');
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
        hz_utility_v2pub.debug(p_message=>'save_financial_profiles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_financial_profiles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_FINANCIAL_PROFILE');
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
        hz_utility_v2pub.debug(p_message=>'save_financial_profiles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO save_financial_profiles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_FINANCIAL_PROFILE');
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
        hz_utility_v2pub.debug(p_message=>'save_financial_profiles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_financial_profiles;

  -- PROCEDURE save_party_preferences
  --
  -- DESCRIPTION
  --     Create or update party preferences.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_pref_objs    List of party preference objects.
  --     p_party_id           Party Id.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_party_preferences(
    p_party_pref_objs            IN OUT NOCOPY hz_party_pref_obj_tbl,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_ovn                 NUMBER := NULL;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_party_preferences_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_party_preferences(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update party preferences
    FOR i IN 1..p_party_pref_objs.COUNT LOOP
      -- check if the code assignment record is create or update
      hz_registry_validate_bo_pvt.check_party_pref_op(
        p_party_id            => p_party_id,
        p_module              => p_party_pref_objs(i).module,
        p_category            => p_party_pref_objs(i).category,
        p_preference_code     => p_party_pref_objs(i).preference_code,
        x_object_version_number     => l_ovn
      );

      HZ_PREFERENCE_PUB.Put(
        p_party_id                  => p_party_id,
        p_category                  => p_party_pref_objs(i).category,
        p_preference_code           => p_party_pref_objs(i).preference_code,
        p_value_varchar2            => p_party_pref_objs(i).value_varchar2,
        p_value_number              => p_party_pref_objs(i).value_number,
        p_value_date                => p_party_pref_objs(i).value_date,
        p_value_name                => p_party_pref_objs(i).value_name,
        p_module                    => p_party_pref_objs(i).module,
        p_additional_value1         => p_party_pref_objs(i).additional_value1,
        p_additional_value2         => p_party_pref_objs(i).additional_value2,
        p_additional_value3         => p_party_pref_objs(i).additional_value3,
        p_additional_value4         => p_party_pref_objs(i).additional_value4,
        p_additional_value5         => p_party_pref_objs(i).additional_value5,
        p_object_version_number     => l_ovn,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.save_party_preferences, party id: '||p_party_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_party_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_party_preferences_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_PREFERENCES');
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
        hz_utility_v2pub.debug(p_message=>'save_party_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_party_preferences_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_PREFERENCES');
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
        hz_utility_v2pub.debug(p_message=>'save_party_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO save_party_preferences_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_PREFERENCES');
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
        hz_utility_v2pub.debug(p_message=>'save_party_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_party_preferences;


  --  PRIVATE PROCEDURE assign_party_usge_assgmnt_rec
  --
  -- DESCRIPTION
  --     Assign HZ_PARTY_USAGE_OBJ to HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_usage_obj           HZ_PARTY_USAGE_OBJ.
  --     p_party_id                  Party Id.
  --   OUT:
  --     px_party_usage_assignment_rec         OUT  HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-Mar-2006   Hadi Alatasi           Created.
  --

 PROCEDURE assign_party_usge_assgmnt_rec(
    p_party_usage_obj         IN            HZ_PARTY_USAGE_OBJ,
    p_party_id                   IN            NUMBER,
    px_party_usage_assignment_rec             IN OUT NOCOPY HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type
  ) is
  begin
    px_party_usage_assignment_rec.party_id               := p_party_id;
    px_party_usage_assignment_rec.party_usage_code     := p_party_usage_obj.party_usage_code;
    px_party_usage_assignment_rec.effective_start_date := p_party_usage_obj.effective_start_date ;
    px_party_usage_assignment_rec.effective_end_date   := p_party_usage_obj.effective_end_date ;
    px_party_usage_assignment_rec.comments             := p_party_usage_obj.comments;
    px_party_usage_assignment_rec.attribute_category    := p_party_usage_obj.attribute_category;
    px_party_usage_assignment_rec.attribute1    := p_party_usage_obj.attribute1;
    px_party_usage_assignment_rec.attribute2    := p_party_usage_obj.attribute2;
    px_party_usage_assignment_rec.attribute3    := p_party_usage_obj.attribute3;
    px_party_usage_assignment_rec.attribute4    := p_party_usage_obj.attribute4;
    px_party_usage_assignment_rec.attribute5    := p_party_usage_obj.attribute5;
    px_party_usage_assignment_rec.attribute6    := p_party_usage_obj.attribute6;
    px_party_usage_assignment_rec.attribute7    := p_party_usage_obj.attribute7;
    px_party_usage_assignment_rec.attribute8    := p_party_usage_obj.attribute8;
    px_party_usage_assignment_rec.attribute9    := p_party_usage_obj.attribute9;
    px_party_usage_assignment_rec.attribute10    := p_party_usage_obj.attribute10;
    px_party_usage_assignment_rec.attribute11    := p_party_usage_obj.attribute11;
    px_party_usage_assignment_rec.attribute12    := p_party_usage_obj.attribute12;
    px_party_usage_assignment_rec.attribute13    := p_party_usage_obj.attribute13;
    px_party_usage_assignment_rec.attribute14    := p_party_usage_obj.attribute14;
    px_party_usage_assignment_rec.attribute15    := p_party_usage_obj.attribute15;
    px_party_usage_assignment_rec.attribute16    := p_party_usage_obj.attribute16;
    px_party_usage_assignment_rec.attribute17    := p_party_usage_obj.attribute17;
    px_party_usage_assignment_rec.attribute18    := p_party_usage_obj.attribute18;
    px_party_usage_assignment_rec.attribute19    := p_party_usage_obj.attribute19;
    px_party_usage_assignment_rec.attribute20    := p_party_usage_obj.attribute20;
     ------------------ set up created_by_module --------------------------
    px_party_usage_assignment_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

  end assign_party_usge_assgmnt_rec;


-- PROCEDURE create_party_usage_assgmnt
  --
  -- DESCRIPTION
  --     Create Party Usage Assignment.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_usg_objs       List of Party Usage objects.
  --     p_party_id           Party Id.
  --   OUT:
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
  --   01-Mar-2006   Hadi Alatasi           Created.
  --

    PROCEDURE create_party_usage_assgmnt(
    p_party_usg_objs              IN OUT NOCOPY HZ_PARTY_USAGE_OBJ_TBL,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_count                  OUT    NOCOPY NUMBER,
    x_msg_data                   OUT    NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_party_usg_rec        HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_party_usage_assgmnt_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'assign_party_usage(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

   FOR i IN 1..p_party_usg_objs.COUNT LOOP
      assign_party_usge_assgmnt_rec(
        p_party_usage_obj => p_party_usg_objs(i),
        p_party_id           => p_party_id,
        px_party_usage_assignment_rec => l_party_usg_rec
      );
       HZ_PARTY_USG_ASSIGNMENT_PUB.assign_party_usage (
         p_init_msg_list              => FND_API.G_FALSE,
         p_party_usg_assignment_rec   => l_party_usg_rec,
         x_return_status              => x_return_status,
         x_msg_count                  => x_msg_count,
         x_msg_data                   => x_msg_data
       );

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.create_party_usage_assignment, party id: '||p_party_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

     -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_party_usage_assgmnt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_party_usage_assgmnt_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_USAGE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'create_party_usage_assgmnt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_party_usage_assgmnt_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_USAGE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'create_party_usage_assgmnt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_party_usage_assgmnt_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_USAGE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'create_party_usage_assgmnt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

  end create_party_usage_assgmnt;


  -- PROCEDURE Save_party_usage_assgmnt
  --
  -- DESCRIPTION
  --     Create or update Party Usage Assignment.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_usg_objs       List of Party Usage objects.
  --     p_party_id           Party Id.
  --   OUT:
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
  --   01-Mar-2006   Hadi Alatasi           Created.
  --

 PROCEDURE save_party_usage_assgmnt(
    p_party_usg_objs             IN OUT NOCOPY HZ_PARTY_USAGE_OBJ_TBL,
    p_party_id                   IN         NUMBER,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_count                  OUT    NOCOPY NUMBER,
    x_msg_data                   OUT    NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_party_usg_assignment_id         NUMBER;
    l_party_usg_rec        HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
    l_lud                 DATE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_party_usage_assgmnt_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'assign_party_usage(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

   FOR i IN 1..p_party_usg_objs.COUNT LOOP
      --hz_registry_validate_bo_pvt.assign_party_usge_assgmnt_rec(
      assign_party_usge_assgmnt_rec(
        p_party_usage_obj => p_party_usg_objs(i),
        p_party_id           => p_party_id,
        px_party_usage_assignment_rec => l_party_usg_rec
      );

      -- check if the party usage assignment record is create or update
     HZ_REGISTRY_VALIDATE_BO_PVT.check_party_usage_op(
       p_party_id           => p_party_id,
       p_party_usage_code   => l_party_usg_rec.party_usage_code,
       x_last_update_date         => l_lud,
       x_return_status            => x_return_status
      );
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.check_party_usage_op,  party_usage_code ' || l_party_usg_rec.party_usage_code||', party id: '||p_party_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_USAGE_ASSIGNMENTS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_lud IS NULL) THEN
         HZ_PARTY_USG_ASSIGNMENT_PUB.assign_party_usage (
           p_init_msg_list              => FND_API.G_FALSE,
           p_party_usg_assignment_rec   => l_party_usg_rec,
           x_return_status              => x_return_status,
           x_msg_count                  => x_msg_count,
           x_msg_data                   => x_msg_data
         );
      ELSE
       HZ_PARTY_USG_ASSIGNMENT_PUB.update_usg_assignment (
           p_init_msg_list              =>   FND_API.G_FALSE,
           p_party_usg_assignment_rec   =>   l_party_usg_rec,
           x_return_status              =>   x_return_status,
           x_msg_count                  =>   x_msg_count,
           x_msg_data                   =>   x_msg_data
       ) ;
      ENd IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_bo_pvt.save_party_usage_assgmnt,party_usage_code ' || l_party_usg_rec.party_usage_code||', party id: '||p_party_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
      END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

       -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_party_usage_assgmnt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_party_usage_assgmnt_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_USAGE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'save_party_usage_assgmnt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_party_usage_assgmnt_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_USAGE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'save_party_usage_assgmnt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO save_party_usage_assgmnt_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_USAGE_ASSIGNMENTS');
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
        hz_utility_v2pub.debug(p_message=>'save_party_usage_assgmnt(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_party_usage_assgmnt;

  -- PROCEDURE call_bes
  --
  -- DESCRIPTION
  --     Call business event.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_id           Party Id.
  --     p_bo_code            Business Object Code.
  --     p_create_or_update   Create or Update Flag.
  --     p_event_id           Business event ID.
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-OCT-2005    Arnold Ng          Created.
  --   15-DEC-2005    Arnold Ng          Add p_event_id.
  --

  PROCEDURE call_bes(
    p_party_id          IN NUMBER,
    p_bo_code           IN VARCHAR2,
    p_create_or_update  IN VARCHAR2,
    p_obj_source        IN VARCHAR2,
    p_event_id          IN NUMBER
  ) IS
    l_paramlist      WF_PARAMETER_LIST_T;
    l_key            VARCHAR2(240);
    l_event_name     VARCHAR2(240);
  BEGIN
    log('Cleanse duplicate root node');
    BEGIN
      DELETE FROM HZ_BUS_OBJ_TRACKING
      WHERE rowid IN
      ( SELECT bo_row FROM
        ( SELECT rowid bo_row, child_entity_name, child_id, child_bo_code, parent_entity_name, parent_id, parent_bo_code
               , min(rowid) over (PARTITION BY child_id, child_entity_name, child_bo_code, parent_entity_name, parent_id, parent_bo_code ORDER BY rowid RANGE UNBOUNDED PRECEDING) as min_row
          FROM HZ_BUS_OBJ_TRACKING
          WHERE child_id = p_party_id
          AND child_entity_name = 'HZ_PARTIES'
          AND nvl(child_bo_code, 'X') = nvl(p_bo_code, 'X')
          --AND nvl(parent_entity_name, 'X') = nvl(p_pentity_name, 'X')
          --AND nvl(parent_id, -99) = nvl(p_parent_id, -99)
          --AND nvl(parent_bo_code, 'X') = nvl(p_pbo_code, 'X')
          AND event_id IS NULL
        )
        WHERE bo_row <> min_row
      );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF(p_bo_code in ('ORG_CUST', 'PERSON_CUST')) THEN
      add_cust_tracking(
        p_party_id         => p_party_id,
        p_bo_code          => p_bo_code,
        p_create_or_update => p_create_or_update);
    END IF;

    log('Prepare to raise event');
    log('Get Event Id: '||p_event_id);

    CASE
      WHEN p_bo_code = 'PERSON' AND p_create_or_update = 'C' THEN
        l_event_name := 'oracle.apps.ar.hz.PersonBO.create';
      WHEN p_bo_code = 'PERSON' AND p_create_or_update = 'U' THEN
        l_event_name := 'oracle.apps.ar.hz.PersonBO.update';
      WHEN p_bo_code = 'ORG' AND p_create_or_update = 'C' THEN
        l_event_name := 'oracle.apps.ar.hz.OrgBO.create';
      WHEN p_bo_code = 'ORG' AND p_create_or_update = 'U' THEN
        l_event_name := 'oracle.apps.ar.hz.OrgBO.update';
      WHEN p_bo_code = 'PERSON_CUST' AND p_create_or_update = 'C' THEN
        l_event_name := 'oracle.apps.ar.hz.PersonCustBO.create';
      WHEN p_bo_code = 'PERSON_CUST' AND p_create_or_update = 'U' THEN
        l_event_name := 'oracle.apps.ar.hz.PersonCustBO.update';
      WHEN p_bo_code = 'ORG_CUST' AND p_create_or_update = 'C' THEN
        l_event_name := 'oracle.apps.ar.hz.OrgCustBO.create';
      WHEN p_bo_code = 'ORG_CUST' AND p_create_or_update = 'U' THEN
        l_event_name := 'oracle.apps.ar.hz.OrgCustBO.update';
      ELSE
        log('Unexpected event name');
        RAISE FND_API.G_EXC_ERROR;
    END CASE;
    l_key        := l_event_name||p_event_id;
    l_paramlist  := WF_PARAMETER_LIST_T();

    log('Event Name  : '||l_event_name);
    log('Event Key   : '||l_key);
    log('Adding parameters');

    wf_event.addParameterToList(
      p_name  => 'CDH_EVENT_ID',
      p_value => p_event_id,
      p_parameterlist => l_paramlist);

    wf_event.addParameterToList(
      p_name  => 'CDH_OBJECT_ID',
      p_value => p_party_id,
      p_parameterlist => l_paramlist);

    wf_event.addParameterToList(
      p_name  => 'CDH_OBJ_SOURCE',
      p_value => p_obj_source,
      p_parameterlist => l_paramlist);

    log('Raise business event: '||l_event_name);
    HZ_EVENT_PKG.raise_event(
      p_event_name        => l_event_name,
      p_event_key         => l_key,
      p_parameters        => l_paramlist);

    log('Remove parameter list');
    l_paramlist.DELETE;

    log('Update BOT Event Id');
    -- update BOT event id here
    HZ_BES_BO_UTIL_PKG.upd_bot_evtid_dt(
      p_bulk_evt        => FALSE,
      p_evt_id          => p_event_id,
      p_child_id        => p_party_id,
      p_child_bo_code   => p_bo_code,
      p_creation_date   => sysdate,
      p_evt_type        => p_create_or_update,
      p_commit          => FALSE,
      p_per_ins_evt_id  => NULL,
      p_per_upd_evt_id  => NULL,
      p_org_ins_evt_id  => NULL,
      p_org_upd_evt_id  => NULL,
      p_perc_ins_evt_id => NULL,
      p_perc_upd_evt_id => NULL,
      p_orgc_ins_evt_id => NULL,
      p_orgc_upd_evt_id => NULL
    );
    log('Done raising event');

    IF(p_create_or_update = 'C') THEN
      log('Set BO version number');
      set_hz_parties_bo_ver(
        p_party_id      => p_party_id,
        p_bo_code       => p_bo_code
      );
    END IF;
    log('Exit procedure');
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      log('Expected error');
      l_paramlist.DELETE;
      RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
      log(SQLERRM);
      l_paramlist.DELETE;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END call_bes;

  -- PROCEDURE set_hz_parties_bo_ver
  --
  -- DESCRIPTION
  --     Set BO_VERSION_NUMBER in HZ_PARTIES table.  This procedure
  --     will be called from Organization, Organization Customer,
  --     Person, Person Customer BO create API.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_id           Party Id.
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-OCT-2005    Arnold Ng          Created.
  --

  PROCEDURE set_hz_parties_bo_ver(
    p_party_id       IN NUMBER,
    p_bo_code        IN VARCHAR2
  ) IS
  BEGIN
    IF(p_bo_code = 'PERSON') THEN
      UPDATE HZ_PARTIES
      SET PERSON_BO_VERSION = (SELECT BO_VERSION_NUMBER
                               FROM HZ_BUS_OBJ_DEFINITIONS
                               WHERE BUSINESS_OBJECT_CODE = 'PERSON'
                               AND ENTITY_NAME = 'HZ_PARTIES')
      WHERE PARTY_ID = p_party_id;
    ELSIF(p_bo_code = 'PERSON_CUST') THEN
      UPDATE HZ_PARTIES
      SET PERSON_CUST_BO_VERSION = (SELECT BO_VERSION_NUMBER
                                    FROM HZ_BUS_OBJ_DEFINITIONS
                                    WHERE BUSINESS_OBJECT_CODE = 'PERSON_CUST'
                                    AND ENTITY_NAME = 'HZ_PARTIES'
                                    AND CHILD_BO_CODE IS NULL)
      WHERE PARTY_ID = p_party_id;
    ELSIF(p_bo_code = 'ORG') THEN
      UPDATE HZ_PARTIES
      SET ORG_BO_VERSION = (SELECT BO_VERSION_NUMBER
                            FROM HZ_BUS_OBJ_DEFINITIONS
                            WHERE BUSINESS_OBJECT_CODE = 'ORG'
                            AND ENTITY_NAME = 'HZ_PARTIES')
      WHERE PARTY_ID = p_party_id;
    ELSIF(p_bo_code = 'ORG_CUST') THEN
      UPDATE HZ_PARTIES
      SET ORG_CUST_BO_VERSION = (SELECT BO_VERSION_NUMBER
                                 FROM HZ_BUS_OBJ_DEFINITIONS
                                 WHERE BUSINESS_OBJECT_CODE = 'ORG_CUST'
                                 AND ENTITY_NAME = 'HZ_PARTIES'
                                 AND CHILD_BO_CODE IS NULL)
      WHERE PARTY_ID = p_party_id;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END set_hz_parties_bo_ver;

  -- FUNCTION is_raising_create_event
  --
  -- DESCRIPTION
  --     Return true if raise BES event per object for create.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_obj_complete_flag  Flag indicates if object is complete
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-OCT-2005    Arnold Ng          Created.
  --

  FUNCTION is_raising_create_event(
    p_obj_complete_flag       IN BOOLEAN
  ) RETURN BOOLEAN IS
  BEGIN
    IF(p_obj_complete_flag) AND
      (G_BO_EVENTS_FORMAT = 'N') AND
      (G_EVENT_TYPE in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_raising_create_event;

  FUNCTION is_raising_update_event(
    p_party_id       IN NUMBER,
    p_bo_code        IN VARCHAR2
  ) RETURN BOOLEAN IS
    CURSOR get_party_bo_version IS
    SELECT nvl(PERSON_BO_VERSION, 0), nvl(PERSON_CUST_BO_VERSION, 0),
           nvl(ORG_BO_VERSION, 0), nvl(ORG_CUST_BO_VERSION, 0)
    FROM HZ_PARTIES
    WHERE party_id = p_party_id;

    CURSOR get_def_bo_version IS
    SELECT nvl(BO_VERSION_NUMBER, 0)
    FROM HZ_BUS_OBJ_DEFINITIONS
    WHERE BUSINESS_OBJECT_CODE = p_bo_code
    AND ENTITY_NAME = 'HZ_PARTIES'
    AND CHILD_BO_CODE IS NULL;

    l_per_bo_ver           NUMBER;
    l_pc_bo_ver            NUMBER;
    l_org_bo_ver           NUMBER;
    l_oc_bo_ver            NUMBER;
    l_bo_ver               NUMBER;
  BEGIN
    OPEN get_party_bo_version;
    FETCH get_party_bo_version INTO l_per_bo_ver, l_pc_bo_ver, l_org_bo_ver, l_oc_bo_ver;
    CLOSE get_party_bo_version;

    OPEN get_def_bo_version;
    FETCH get_def_bo_version INTO l_bo_ver;
    CLOSE get_def_bo_version;

    IF(p_bo_code = 'PERSON') AND
      (l_per_bo_ver = l_bo_ver) AND
      (G_BO_EVENTS_FORMAT = 'N') AND
      (G_EVENT_TYPE in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
      RETURN TRUE;
    ELSIF(p_bo_code = 'PERSON_CUST') AND
      (l_pc_bo_ver = l_bo_ver) AND
      (G_BO_EVENTS_FORMAT = 'N') AND
      (G_EVENT_TYPE in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
      RETURN TRUE;
    ELSIF(p_bo_code = 'ORG') AND
      (l_org_bo_ver = l_bo_ver) AND
      (G_BO_EVENTS_FORMAT = 'N') AND
      (G_EVENT_TYPE in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
      RETURN TRUE;
    ELSIF(p_bo_code = 'ORG_CUST') AND
      (l_oc_bo_ver = l_bo_ver) AND
      (G_BO_EVENTS_FORMAT = 'N') AND
      (G_EVENT_TYPE in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END is_raising_update_event;

  PROCEDURE log(
    message      IN VARCHAR2,
    newline      IN BOOLEAN DEFAULT TRUE) IS
    l_prefix VARCHAR2(20) := 'V3API_BO_RAISE';
  BEGIN
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.DEBUG (p_message=>message,
                              p_prefix=>l_prefix,
                              p_msg_level=>fnd_log.level_procedure);
    END IF ;

    IF newline THEN
      FND_FILE.put_line(FND_FILE.LOG,message);
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
    ELSE
      FND_FILE.put_line(FND_FILE.LOG,message);
    END IF;
  END log;

  PROCEDURE add_cust_tracking(
    p_party_id          IN NUMBER,
    p_bo_code           IN VARCHAR2,
    p_create_or_update  IN VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30);
    l_date                    DATE;
    l_child_rec_exists_no     NUMBER;
    l_child_code              VARCHAR2(30);
    l_insert_or_update        VARCHAR2(1);
  BEGIN
    l_date := sysdate;
    l_child_rec_exists_no := 0;

    IF(p_bo_code = 'PERSON_CUST') THEN
      l_child_code := 'PERSON';
    ELSIF(p_bo_code = 'ORG_CUST') THEN
      l_child_code := 'ORG';
    END IF;

    IF(p_create_or_update = 'C') THEN
      l_insert_or_update := 'I';
    ELSE
      l_insert_or_update := 'U';
    END IF;

    -- insert person_cust/org_cust record
    BEGIN
      SELECT child_id INTO  l_child_rec_exists_no
      FROM  HZ_BUS_OBJ_TRACKING
      WHERE event_id IS NULL
      AND CHILD_ENTITY_NAME = 'HZ_PARTIES'
      AND CHILD_BO_CODE = p_bo_code
      AND CHILD_ID = p_party_id
      AND PARENT_ID IS NULL
      AND PARENT_BO_CODE IS NULL
      AND PARENT_ENTITY_NAME IS NULL
      AND rownum = 1;

      IF l_child_rec_exists_no <> 0 THEN
        -- data already exists, no need to write
        hz_utility_v2pub.DEBUG(p_message=> 'Record already exists in BOT',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO HZ_BUS_OBJ_TRACKING
        ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
          LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
        ) VALUES (
          'Y', l_insert_or_update, p_party_id, 'HZ_PARTIES', p_bo_code,
          l_date, l_date, NULL, NULL, NULL);
    END;

    l_child_rec_exists_no := 0;

    -- insert person/org record with parent equals to person_cust/org_cust
    BEGIN
      SELECT child_id INTO  l_child_rec_exists_no
      FROM  HZ_BUS_OBJ_TRACKING
      WHERE event_id IS NULL
      AND CHILD_ENTITY_NAME = 'HZ_PARTIES'
      AND CHILD_BO_CODE = l_child_code
      AND CHILD_ID = p_party_id
      AND PARENT_ID = p_party_id
      AND PARENT_BO_CODE = p_bo_code
      AND PARENT_ENTITY_NAME = 'HZ_PARTIES'
      AND rownum = 1;

      IF l_child_rec_exists_no <> 0 THEN
        -- data already exists, no need to write
        hz_utility_v2pub.DEBUG(p_message=> 'Record already exists in BOT',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO HZ_BUS_OBJ_TRACKING
        ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
          LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
        ) VALUES (
          'Y', l_insert_or_update, p_party_id, 'HZ_PARTIES', l_child_code,
          l_date, l_date, 'HZ_PARTIES', p_party_id, p_bo_code);
    END;
  END add_cust_tracking;

  FUNCTION return_all_messages(
    x_return_status  IN VARCHAR2,
    x_msg_count      IN NUMBER,
    x_msg_data       IN VARCHAR2
  ) RETURN HZ_MESSAGE_OBJ_TBL IS
    l_msg_data    HZ_MESSAGE_OBJ_TBL;
  BEGIN
    l_msg_data := HZ_MESSAGE_OBJ_TBL();
    IF(x_msg_count > 1 AND x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
        l_msg_data.EXTEND;
        l_msg_data(I) := HZ_MESSAGE_OBJ(FND_MSG_PUB.Get(I, p_encoded => FND_API.G_FALSE));
      END LOOP;
    ELSE
      l_msg_data.EXTEND;
      l_msg_data(1) := HZ_MESSAGE_OBJ(x_msg_data);
    END IF;
    RETURN l_msg_data;
  END return_all_messages;

END HZ_PARTY_BO_PVT;

/
