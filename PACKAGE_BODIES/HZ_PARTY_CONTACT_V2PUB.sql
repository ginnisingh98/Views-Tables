--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_CONTACT_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_CONTACT_V2PUB" AS
/*$Header: ARH2PCSB.pls 120.18.12000000.5 2007/09/28 11:55:04 nshinde ship $ */

--------------------------------------------
-- declaration of global variables and types
--------------------------------------------

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'HZ_PARTY_CONTACT_V2PUB';
G_DEBUG_COUNT             NUMBER := 0;
--G_DEBUG                   BOOLEAN := FALSE;

------------------------------------
-- declaration of private procedures
------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE do_create_org_contact (
    p_org_contact_rec               IN OUT   NOCOPY ORG_CONTACT_REC_TYPE,
    x_return_status                 IN OUT NOCOPY   VARCHAR2,
    x_org_contact_id                OUT NOCOPY      NUMBER,
    x_party_rel_id                  OUT NOCOPY      NUMBER,
    x_party_id                      OUT NOCOPY      NUMBER,
    x_party_number                  OUT NOCOPY      VARCHAR2
);

PROCEDURE do_update_org_contact(
    p_org_contact_rec               IN OUT  NOCOPY ORG_CONTACT_REC_TYPE,
    p_cont_object_version_number    IN OUT NOCOPY  NUMBER,
    p_rel_object_version_number     IN OUT NOCOPY  NUMBER,
    p_party_object_version_number   IN OUT NOCOPY  NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_create_org_contact_role(
    p_org_contact_role_rec          IN OUT  NOCOPY ORG_CONTACT_ROLE_REC_TYPE,
    x_org_contact_role_id           OUT NOCOPY     NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
);

PROCEDURE do_update_org_contact_role(
    p_org_contact_role_rec          IN OUT  NOCOPY ORG_CONTACT_ROLE_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY  NUMBER,
    x_return_status                 IN OUT NOCOPY  VARCHAR2
);

PROCEDURE check_obsolete_columns (
    p_create_update_flag          IN     VARCHAR2,
    p_org_contact_rec             IN     org_contact_rec_type,
    p_old_org_contact_rec         IN     org_contact_rec_type DEFAULT NULL,
    x_return_status               IN OUT NOCOPY VARCHAR2
);

-----------------------------
-- body of private procedures
-----------------------------

/**
 * PRIVATE PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Turn on debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.enable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

/*PROCEDURE enable_debug IS

BEGIN

    G_DEBUG_COUNT := G_DEBUG_COUNT + 1;

    IF G_DEBUG_COUNT = 1 THEN
        IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
           FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
        THEN
           HZ_UTILITY_V2PUB.enable_debug;
           G_DEBUG := TRUE;
        END IF;
    END IF;

END enable_debug;
*/


/**
 * PRIVATE PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Turn off debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        G_DEBUG_COUNT := G_DEBUG_COUNT - 1;

        IF G_DEBUG_COUNT = 0 THEN
            HZ_UTILITY_V2PUB.disable_debug;
            G_DEBUG := FALSE;
        END IF;
    END IF;

END disable_debug;
*/


/*===========================================================================+
 | PROCEDURE
 |              do_create_org_contact
 |
 | DESCRIPTION
 |              Creates org_contact, party relationship and party.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_org_contact_id
 |              x_party_rel_id
 |                    x_party_id
 |              x_party_number
 |          IN/ OUT:
 |                    p_org_contact_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_org_contact(
    p_org_contact_rec      IN OUT  NOCOPY ORG_CONTACT_REC_TYPE,
    x_return_status        IN OUT NOCOPY  VARCHAR2,
    x_org_contact_id       OUT NOCOPY     NUMBER,
    x_party_rel_id         OUT NOCOPY     NUMBER,
    x_party_id             OUT NOCOPY     NUMBER,
    x_party_number         OUT NOCOPY     VARCHAR2
) IS

    l_org_contact_id               NUMBER := p_org_contact_rec.org_contact_id;
    l_rowid                        ROWID := NULL;
    l_count                        NUMBER;
    l_gen_contact_number           VARCHAR2(1);
    l_contact_number               VARCHAR2(30) := p_org_contact_rec.contact_number;
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);
    l_dummy                        VARCHAR2(1);
    l_debug_prefix                 VARCHAR2(30);
    l_org_status                   VARCHAR2(1);
    l_object_id                    NUMBER;
    l_person_pre_name              HZ_PARTIES.PERSON_PRE_NAME_ADJUNCT%TYPE := NULL;
    l_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

    CURSOR c_rel IS
    SELECT BACKWARD_REL_CODE
    FROM   HZ_RELATIONSHIP_TYPES
    WHERE  RELATIONSHIP_TYPE = p_org_contact_rec.party_rel_rec.relationship_type
    AND    FORWARD_REL_CODE  = p_org_contact_rec.party_rel_rec.relationship_code
    AND    SUBJECT_TYPE      = p_org_contact_rec.party_rel_rec.subject_type
    AND    OBJECT_TYPE      = p_org_contact_rec.party_rel_rec.object_type
    AND    STATUS = 'A';

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_org_contact (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- if primary key value is passed, check for uniqueness.
    IF l_org_contact_id IS NOT NULL AND
        l_org_contact_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   HZ_ORG_CONTACTS
            WHERE  ORG_CONTACT_ID = l_org_contact_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'org_contact_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    l_gen_contact_number := fnd_profile.value('HZ_GENERATE_CONTACT_NUMBER');

    IF l_gen_contact_number = 'Y' OR l_gen_contact_number IS NULL THEN
        IF l_contact_number = FND_API.G_MISS_CHAR OR l_contact_number IS NULL THEN
            l_count := 1;

            WHILE l_count > 0 LOOP
                SELECT to_char(hz_contact_numbers_s.nextval)
                INTO l_contact_number FROM dual;

                BEGIN
                    SELECT 1
                    INTO   l_count
                    FROM   HZ_ORG_CONTACTS
                    WHERE  CONTACT_NUMBER = l_contact_number;
                    l_count := 1;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_count := 0;
                END;

            END LOOP;
        END IF;
    END IF;

    HZ_REGISTRY_VALIDATE_V2PUB.validate_org_contact(
                                            'C',
                                            p_org_contact_rec,
                                            l_rowid,
                                            x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_object_id := p_org_contact_rec.party_rel_rec.object_id;
    p_org_contact_rec.party_rel_rec.created_by_module := p_org_contact_rec.created_by_module;
    p_org_contact_rec.party_rel_rec.application_id := p_org_contact_rec.application_id;

    /* Bug No : 2359461 */
    IF p_org_contact_rec.party_rel_rec.object_type = 'PERSON' AND
       p_org_contact_rec.party_rel_rec.subject_type = 'ORGANIZATION'
    THEN
    OPEN  c_rel;
    FETCH c_rel INTO p_org_contact_rec.party_rel_rec.relationship_code;
    IF c_rel%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
        FND_MESSAGE.SET_TOKEN('FK', 'relationship_code, subject_type, object_type');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'forward_rel_code, subject_type, object_type');
        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_relationship_types');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_rel;

       p_org_contact_rec.party_rel_rec.object_id   := p_org_contact_rec.party_rel_rec.subject_id;
       p_org_contact_rec.party_rel_rec.object_type := 'ORGANIZATION';
       p_org_contact_rec.party_rel_rec.subject_id  := l_object_id;
       p_org_contact_rec.party_rel_rec.subject_type := 'PERSON';
    END IF;

    /*     Bug Fix : 2500275     */
      IF p_org_contact_rec.party_rel_rec.subject_type = 'PERSON' AND
         p_org_contact_rec.title IS NOT NULL AND
         p_org_contact_rec.title <> FND_API.G_MISS_CHAR
      THEN
         /* HZ_PARTIES */
        BEGIN
          SELECT person_pre_name_adjunct
          INTO   l_person_pre_name
          FROM   hz_parties
          WHERE  party_id   = p_org_contact_rec.party_rel_rec.subject_id
          AND    party_type = 'PERSON'
          FOR UPDATE NOWAIT;
        EXCEPTION
          WHEN OTHERS THEN
            fnd_message.set_name('AR', 'HZ_API_RECORD_CHANGED');
            fnd_message.set_token('TABLE', 'HZ_PARTIES');
            fnd_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;
        END;
        IF l_person_pre_name IS NULL THEN
           UPDATE hz_parties
           SET    person_pre_name_adjunct = p_org_contact_rec.title
           WHERE  party_id   = p_org_contact_rec.party_rel_rec.subject_id
           AND    party_type = 'PERSON';

        /* HZ_PERSON_PROFILES */
        BEGIN
          SELECT 'Y'
          INTO   l_dummy
          FROM   hz_person_profiles
          WHERE  party_id   = p_org_contact_rec.party_rel_rec.subject_id
          AND    effective_end_date IS NULL
          FOR UPDATE NOWAIT;
        EXCEPTION
          WHEN OTHERS THEN
            fnd_message.set_name('AR', 'HZ_API_RECORD_CHANGED');
            fnd_message.set_token('TABLE', 'HZ_PERSON_PROFILES');
            fnd_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;
        END;
           UPDATE hz_person_profiles
           SET    person_pre_name_adjunct = p_org_contact_rec.title
           WHERE  party_id   = p_org_contact_rec.party_rel_rec.subject_id
           AND    effective_end_date IS NULL;
        END IF;
    END IF;
    --
    -- create party relationship.
    --
    HZ_RELATIONSHIP_V2PUB.create_relationship (
        p_relationship_rec            => p_org_contact_rec.party_rel_rec,
        x_relationship_id             => x_party_rel_id,
        x_party_id                    => x_party_id,
        x_party_number                => x_party_number,
        x_return_status               => x_return_status,
        x_msg_count                   => l_msg_count,
        x_msg_data                    => l_msg_data,
        p_create_org_contact          => 'N'
       );

    p_org_contact_rec.party_rel_rec.party_rec.party_id := x_party_id;
    p_org_contact_rec.party_rel_rec.party_rec.party_number := x_party_number;
    p_org_contact_rec.party_rel_rec.relationship_id := x_party_rel_id;
    l_org_status := p_org_contact_rec.party_rel_rec.status;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- this is for orig_system_reference defaulting
    IF p_org_contact_rec.org_contact_id = FND_API.G_MISS_NUM THEN
        p_org_contact_rec.org_contact_id := NULL;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_ORG_CONTACTS_PKG.Insert_Row (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- call table-handler.
    HZ_ORG_CONTACTS_PKG.Insert_Row (
        X_ORG_CONTACT_ID                        => p_org_contact_rec.org_contact_id,
        X_PARTY_RELATIONSHIP_ID                 => x_party_rel_id,
        X_COMMENTS                              => p_org_contact_rec.comments,
        X_CONTACT_NUMBER                        => l_contact_number,
        X_DEPARTMENT_CODE                       => p_org_contact_rec.department_code,
        X_DEPARTMENT                            => p_org_contact_rec.department,
        X_TITLE                                 => p_org_contact_rec.title,
        X_JOB_TITLE                             => p_org_contact_rec.job_title,
        X_DECISION_MAKER_FLAG                   => p_org_contact_rec.decision_maker_flag,
        X_JOB_TITLE_CODE                        => p_org_contact_rec.job_title_code,
        X_REFERENCE_USE_FLAG                    => p_org_contact_rec.reference_use_flag,
        X_RANK                                  => p_org_contact_rec.rank,
        X_ORIG_SYSTEM_REFERENCE                 => p_org_contact_rec.orig_system_reference,
        X_ATTRIBUTE_CATEGORY                    => p_org_contact_rec.attribute_category,
        X_ATTRIBUTE1                            => p_org_contact_rec.attribute1,
        X_ATTRIBUTE2                            => p_org_contact_rec.attribute2,
        X_ATTRIBUTE3                            => p_org_contact_rec.attribute3,
        X_ATTRIBUTE4                            => p_org_contact_rec.attribute4,
        X_ATTRIBUTE5                            => p_org_contact_rec.attribute5,
        X_ATTRIBUTE6                            => p_org_contact_rec.attribute6,
        X_ATTRIBUTE7                            => p_org_contact_rec.attribute7,
        X_ATTRIBUTE8                            => p_org_contact_rec.attribute8,
        X_ATTRIBUTE9                            => p_org_contact_rec.attribute9,
        X_ATTRIBUTE10                           => p_org_contact_rec.attribute10,
        X_ATTRIBUTE11                           => p_org_contact_rec.attribute11,
        X_ATTRIBUTE12                           => p_org_contact_rec.attribute12,
        X_ATTRIBUTE13                           => p_org_contact_rec.attribute13,
        X_ATTRIBUTE14                           => p_org_contact_rec.attribute14,
        X_ATTRIBUTE15                           => p_org_contact_rec.attribute15,
        X_ATTRIBUTE16                           => p_org_contact_rec.attribute16,
        X_ATTRIBUTE17                           => p_org_contact_rec.attribute17,
        X_ATTRIBUTE18                           => p_org_contact_rec.attribute18,
        X_ATTRIBUTE19                           => p_org_contact_rec.attribute19,
        X_ATTRIBUTE20                           => p_org_contact_rec.attribute20,
        X_ATTRIBUTE21                           => p_org_contact_rec.attribute21,
        X_ATTRIBUTE22                           => p_org_contact_rec.attribute22,
        X_ATTRIBUTE23                           => p_org_contact_rec.attribute23,
        X_ATTRIBUTE24                           => p_org_contact_rec.attribute24,
        X_PARTY_SITE_ID                         => p_org_contact_rec.party_site_id,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_org_contact_rec.created_by_module,
        X_APPLICATION_ID                        => p_org_contact_rec.application_id,
        X_STATUS                                => l_org_status
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_ORG_CONTACTS_PKG.Insert_Row (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;



    if p_org_contact_rec.orig_system is not null
         and p_org_contact_rec.orig_system <>fnd_api.g_miss_char
    then
                l_orig_sys_reference_rec.orig_system := p_org_contact_rec.orig_system;
                l_orig_sys_reference_rec.orig_system_reference := p_org_contact_rec.orig_system_reference;
                l_orig_sys_reference_rec.owner_table_name := 'HZ_ORG_CONTACTS';
                l_orig_sys_reference_rec.owner_table_id := p_org_contact_rec.org_contact_id;
                l_orig_sys_reference_rec.created_by_module := p_org_contact_rec.created_by_module;

                hz_orig_system_ref_pub.create_orig_system_reference(
                        FND_API.G_FALSE,
                        l_orig_sys_reference_rec,
                        x_return_status,
                        l_msg_count,
                        l_msg_data);
                 IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
      end if;

    x_org_contact_id := p_org_contact_rec.org_contact_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_org_contact;

/*===========================================================================+
 | PROCEDURE
 |              do_update_org_contact
 |
 | DESCRIPTION
 |              Updates org_contact, party relationship and party.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_org_contact_rec
 |                    p_org_contact_last_update_date
 |              p_party_rel_last_update_date
 |                    p_party_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 28-SEP-2007		Neeraj Shinde	BUG# 6335274:1.relationship_id is non-updatable field.
 |                                      If relationship_id is not supplied,
 |                                      do not fetch it from HZ_ORG_CONTACTS.
 |                                      2.If update_relationship API results
 |                                      in error, Error has to be raised.
 +===========================================================================*/

PROCEDURE do_update_org_contact(
    p_org_contact_rec                   IN OUT  NOCOPY ORG_CONTACT_REC_TYPE,
    p_cont_object_version_number        IN OUT NOCOPY  NUMBER,
    p_rel_object_version_number         IN OUT NOCOPY  NUMBER,
    p_party_object_version_number       IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_rowid                                     ROWID;
    l_party_relationship_id                     NUMBER := p_org_contact_rec.party_rel_rec.relationship_id;
    l_api_version                     CONSTANT  NUMBER := 1.0;
    l_old_org_contact_rec                       ORG_CONTACT_REC_TYPE;
    l_msg_count                                 NUMBER;
    l_msg_data                                  VARCHAR2(2000);
    l_object_version_number                     NUMBER;
    l_debug_prefix                              VARCHAR2(30);
    l_object_id                                 NUMBER;
    l_org_status                                VARCHAR2(1);
    l_person_pre_name              HZ_PERSON_PROFILES.PERSON_PRE_NAME_ADJUNCT%TYPE := NULL;
    l_party_id                     HZ_PARTIES.PARTY_ID%TYPE := NULL;
BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT ROWID,
               OBJECT_VERSION_NUMBER
        INTO   l_rowid,
               l_object_version_number
        FROM   HZ_ORG_CONTACTS
        WHERE  ORG_CONTACT_ID = p_org_contact_rec.org_contact_id
        FOR UPDATE OF ORG_CONTACT_ID NOWAIT;

        IF NOT (
            ( p_cont_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_cont_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_cont_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_org_contacts' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_cont_object_version_number := NVL( l_object_version_number, 1 ) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'org contact' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_org_contact_rec.org_contact_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;
--Bug Fix 2188731
    IF p_org_contact_rec.party_rel_rec.relationship_id IS NOT NULL THEN

   BEGIN

        SELECT OBJECT_ID
        INTO   l_object_id
        FROM   HZ_RELATIONSHIPS
        WHERE  RELATIONSHIP_ID = p_org_contact_rec.party_rel_rec.relationship_id
        AND    DIRECTIONAL_FLAG = 'F';


    IF p_org_contact_rec.party_rel_rec.object_id IS NULL
    THEN
    p_org_contact_rec.party_rel_rec.object_id := l_object_id;
    END IF;


   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'party relationship' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_org_contact_rec.party_rel_rec.relationship_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;
    END IF;
    -- call for validations.
    HZ_REGISTRY_VALIDATE_V2PUB.validate_org_contact(
                                            'U',
                                            p_org_contact_rec,
                                            l_rowid,
                                            x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_org_status :=  p_org_contact_rec.party_rel_rec.status  ;

    --BUG# 6335274: Start
    --If relationship_id is NOT supplied,do not fetch it from the table.
    -- select rowid and other fields for later uses.
    /*
    SELECT ROWID,
           PARTY_RELATIONSHIP_ID
    INTO   l_rowid, l_party_relationship_id
    FROM   HZ_ORG_CONTACTS
    WHERE  ORG_CONTACT_ID = p_org_contact_rec.org_contact_id;*/

    IF (l_party_relationship_id IS NOT NULL) THEN
      --user passes optional relationship_id
       SELECT ROWID,
              PARTY_RELATIONSHIP_ID
         INTO l_rowid, l_party_relationship_id
         FROM HZ_ORG_CONTACTS
        WHERE ORG_CONTACT_ID = p_org_contact_rec.org_contact_id;
    END IF;
    --BUG# 6335274: End


/*  Bug No : 2500275 */

    IF p_org_contact_rec.title IS NOT NULL AND
       p_org_contact_rec.title <> FND_API.G_MISS_CHAR
    THEN
     BEGIN
      SELECT P.PERSON_PRE_NAME_ADJUNCT,P.PARTY_ID INTO
             l_person_pre_name,l_party_id
      FROM   HZ_PARTIES P, HZ_RELATIONSHIPS R, HZ_ORG_CONTACTS C
      WHERE
             C.ORG_CONTACT_ID   = p_org_contact_rec.org_contact_id
       AND   R.RELATIONSHIP_ID  = C.PARTY_RELATIONSHIP_ID
       AND   R.DIRECTIONAL_FLAG = 'F'
       AND   R.SUBJECT_ID       = P.PARTY_ID
       AND   P.PARTY_TYPE       = 'PERSON';

      IF l_person_pre_name IS NULL THEN
         UPDATE HZ_PARTIES
         SET    PERSON_PRE_NAME_ADJUNCT = p_org_contact_rec.title
         WHERE  PARTY_ID                = l_party_id;

         UPDATE HZ_PERSON_PROFILES
         SET    PERSON_PRE_NAME_ADJUNCT = p_org_contact_rec.title
         WHERE  PARTY_ID                = l_party_id
         AND    EFFECTIVE_END_DATE IS NULL;
      END IF;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            NULL;
     END;
    END IF;

     if (p_org_contact_rec.orig_system is not null
         and p_org_contact_rec.orig_system <>fnd_api.g_miss_char)
        and (p_org_contact_rec.orig_system_reference is not null
         and p_org_contact_rec.orig_system_reference <>fnd_api.g_miss_char)
      then
                p_org_contact_rec.orig_system_reference := null;
                -- In mosr, we have bypassed osr nonupdateable validation
                -- but we should not update existing osr, set it to null
      end if;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_ORG_CONTACTS_PKG.Update_Row (+) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    -- call to table-handler
    HZ_ORG_CONTACTS_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_ORG_CONTACT_ID                        => p_org_contact_rec.org_contact_id,
        X_PARTY_RELATIONSHIP_ID                 => p_org_contact_rec.party_rel_rec.relationship_id,
        X_COMMENTS                              => p_org_contact_rec.comments,
        X_CONTACT_NUMBER                        => p_org_contact_rec.contact_number,
        X_DEPARTMENT_CODE                       => p_org_contact_rec.department_code,
        X_DEPARTMENT                            => p_org_contact_rec.department,
        X_TITLE                                 => p_org_contact_rec.title,
        X_JOB_TITLE                             => p_org_contact_rec.job_title,
        X_DECISION_MAKER_FLAG                   => p_org_contact_rec.decision_maker_flag,
        X_JOB_TITLE_CODE                        => p_org_contact_rec.job_title_code,
        X_REFERENCE_USE_FLAG                    => p_org_contact_rec.reference_use_flag,
        X_RANK                                  => p_org_contact_rec.rank,
        X_ORIG_SYSTEM_REFERENCE                 => p_org_contact_rec.orig_system_reference,
        X_ATTRIBUTE_CATEGORY                    => p_org_contact_rec.attribute_category,
        X_ATTRIBUTE1                            => p_org_contact_rec.attribute1,
        X_ATTRIBUTE2                            => p_org_contact_rec.attribute2,
        X_ATTRIBUTE3                            => p_org_contact_rec.attribute3,
        X_ATTRIBUTE4                            => p_org_contact_rec.attribute4,
        X_ATTRIBUTE5                            => p_org_contact_rec.attribute5,
        X_ATTRIBUTE6                            => p_org_contact_rec.attribute6,
        X_ATTRIBUTE7                            => p_org_contact_rec.attribute7,
        X_ATTRIBUTE8                            => p_org_contact_rec.attribute8,
        X_ATTRIBUTE9                            => p_org_contact_rec.attribute9,
        X_ATTRIBUTE10                           => p_org_contact_rec.attribute10,
        X_ATTRIBUTE11                           => p_org_contact_rec.attribute11,
        X_ATTRIBUTE12                           => p_org_contact_rec.attribute12,
        X_ATTRIBUTE13                           => p_org_contact_rec.attribute13,
        X_ATTRIBUTE14                           => p_org_contact_rec.attribute14,
        X_ATTRIBUTE15                           => p_org_contact_rec.attribute15,
        X_ATTRIBUTE16                           => p_org_contact_rec.attribute16,
        X_ATTRIBUTE17                           => p_org_contact_rec.attribute17,
        X_ATTRIBUTE18                           => p_org_contact_rec.attribute18,
        X_ATTRIBUTE19                           => p_org_contact_rec.attribute19,
        X_ATTRIBUTE20                           => p_org_contact_rec.attribute20,
        X_ATTRIBUTE21                           => p_org_contact_rec.attribute21,
        X_ATTRIBUTE22                           => p_org_contact_rec.attribute22,
        X_ATTRIBUTE23                           => p_org_contact_rec.attribute23,
        X_ATTRIBUTE24                           => p_org_contact_rec.attribute24,
        X_PARTY_SITE_ID                         => p_org_contact_rec.party_site_id,
        X_OBJECT_VERSION_NUMBER                 => p_cont_object_version_number,
        X_CREATED_BY_MODULE                     => p_org_contact_rec.created_by_module,
        X_APPLICATION_ID                        => p_org_contact_rec.application_id,
        X_STATUS                                => l_org_status
    );
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_ORG_CONTACTS_PKG.Update_Row (-) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- update party relationship. party_relationship_id in hz_org_contacts is
    -- non-updateable and l_party_relationship_id is selected from table.
    IF nvl(p_rel_object_version_number, 1) <> FND_API.G_MISS_NUM
    THEN
        IF l_party_relationship_id IS NOT NULL THEN
            p_org_contact_rec.party_rel_rec.relationship_id := l_party_relationship_id;
            p_org_contact_rec.party_rel_rec.created_by_module := p_org_contact_rec.created_by_module;
            p_org_contact_rec.party_rel_rec.application_id := p_org_contact_rec.application_id;

            /* Bug No : 2408693 */
            /* Bug No : 5080436 .Commented the code for toggling*/
        /*  IF p_org_contact_rec.party_rel_rec.object_type = 'PERSON' AND
               p_org_contact_rec.party_rel_rec.subject_type = 'ORGANIZATION'
            THEN
              BEGIN
                SELECT SUBJECT_ID,OBJECT_ID
                INTO   p_org_contact_rec.party_rel_rec.object_id,
                       p_org_contact_rec.party_rel_rec.subject_id
                FROM   HZ_RELATIONSHIPS
                WHERE  RELATIONSHIP_ID  = p_org_contact_rec.party_rel_rec.relationship_id
                AND    DIRECTIONAL_FLAG = 'F';

               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
                      FND_MESSAGE.SET_TOKEN( 'RECORD', 'party relationship' );
                      FND_MESSAGE.SET_TOKEN( 'VALUE', NVL( TO_CHAR( p_org_contact_rec.party_rel_rec.relationship_id ), 'null' ) );
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_ERROR;
              END;

                    p_org_contact_rec.party_rel_rec.object_type := 'ORGANIZATION';
                    p_org_contact_rec.party_rel_rec.subject_type := 'PERSON';
            END IF; */

            HZ_RELATIONSHIP_V2PUB.update_relationship (
                p_relationship_rec            => p_org_contact_rec.party_rel_rec,
                p_object_version_number       => p_rel_object_version_number,
                p_party_object_version_number => p_party_object_version_number,
                x_return_status               => x_return_status,
                x_msg_count                   => l_msg_count,
                x_msg_data                    => l_msg_data
        );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	          RAISE FND_API.G_EXC_ERROR; --BUG# 6335274
            END IF;
        END IF;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_org_contact;


/*===========================================================================+
 | PROCEDURE
 |              do_create_org_contact_role
 |
 | DESCRIPTION
 |              Creates org_contact_role.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_org_contact_role_id
 |          IN/ OUT:
 |                    p_org_contact_role_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_org_contact_role(
    p_org_contact_role_rec        IN OUT  NOCOPY ORG_CONTACT_ROLE_REC_TYPE,
    x_org_contact_role_id         OUT NOCOPY     NUMBER,
    x_return_status               IN OUT NOCOPY  VARCHAR2
) IS

    l_org_contact_role_id                 NUMBER := p_org_contact_role_rec.org_contact_role_id;
    l_rowid                               ROWID := NULL;
    l_count                               NUMBER;
    l_msg_count                           NUMBER;
    l_msg_data                            VARCHAR2(2000);
    l_dummy                               VARCHAR2(1);
    l_debug_prefix                        VARCHAR2(30);
    l_orig_sys_reference_rec  HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
    l_object_version_number               NUMBER; -- Added: Bug#6411541
BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_org_contact_role (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- if primary key value is passed, check for uniqueness.
    IF l_org_contact_role_id IS NOT NULL AND
        l_org_contact_role_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   HZ_ORG_CONTACT_ROLES
            WHERE  ORG_CONTACT_ROLE_ID = l_org_contact_role_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'org_contact_role_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    HZ_REGISTRY_VALIDATE_V2PUB.validate_org_contact_role(
                                                 'C',
                                                 p_org_contact_role_rec,
                                                 l_rowid,
                                                 x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- this is for orig_system_reference defaulting
    IF p_org_contact_role_rec.org_contact_role_id = FND_API.G_MISS_NUM THEN
        p_org_contact_role_rec.org_contact_role_id := NULL;
    END IF;

    /* Bug#6411541: Start of changes made by Neeraj Shinde
       If the role was previously defined for the contact then a
       record exists in Inactive status. This record needs to be updated to Active. */

    -- If the record exist, update status = 'Active', Else continue with Insert

    IF (p_org_contact_role_rec.org_contact_id IS NOT NULL AND
        p_org_contact_role_rec.role_type IS NOT NULL) THEN

        BEGIN
             SELECT ORG_CONTACT_ROLE_ID,
                    OBJECT_VERSION_NUMBER,
                    ROWID
             INTO   l_org_contact_role_id,
                    l_object_version_number,
                    l_rowid
             FROM   HZ_ORG_CONTACT_ROLES
             WHERE  ORG_CONTACT_ID = p_org_contact_role_rec.org_contact_id
             AND    ROLE_TYPE = p_org_contact_role_rec.role_type
             AND    STATUS = 'I';

             l_object_version_number := nvl(l_object_version_number, 1) + 1;

             -- call to table-handler to update the staus to active
	     HZ_ORG_CONTACT_ROLES_PKG.Update_Row (
	         X_Rowid                                 => l_rowid,
	         X_ORG_CONTACT_ROLE_ID                   => l_org_contact_role_id,
	         X_ORG_CONTACT_ID                        => p_org_contact_role_rec.org_contact_id,
	         X_ROLE_TYPE                             => p_org_contact_role_rec.role_type,
	         X_ROLE_LEVEL                            => p_org_contact_role_rec.role_level,
	         X_PRIMARY_FLAG                          => p_org_contact_role_rec.primary_flag,
	         X_ORIG_SYSTEM_REFERENCE                 => p_org_contact_role_rec.orig_system_reference,
	         X_PRIMARY_CON_PER_ROLE_TYPE             => p_org_contact_role_rec.primary_contact_per_role_type,
	         X_STATUS                                => 'A',
	         X_OBJECT_VERSION_NUMBER                 => l_object_version_number,
	         X_CREATED_BY_MODULE                     => p_org_contact_role_rec.created_by_module,
	         X_APPLICATION_ID                        => p_org_contact_role_rec.application_id
                      );

             x_org_contact_role_id := l_org_contact_role_id;

        EXCEPTION
             WHEN NO_DATA_FOUND THEN

		    -- Debug info.
		    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(p_message=>'HZ_ORG_CONTACT_ROLES_PKG.Insert_Row (+)',
					       p_prefix=>l_debug_prefix,
					       p_msg_level=>fnd_log.level_procedure);
		    END IF;

		    -- call table-handler.
		    HZ_ORG_CONTACT_ROLES_PKG.Insert_Row (
			X_ORG_CONTACT_ROLE_ID                   => p_org_contact_role_rec.org_contact_role_id,
			X_ORG_CONTACT_ID                        => p_org_contact_role_rec.org_contact_id,
			X_ROLE_TYPE                             => p_org_contact_role_rec.role_type,
			X_ROLE_LEVEL                            => p_org_contact_role_rec.role_level,
			X_PRIMARY_FLAG                          => p_org_contact_role_rec.primary_flag,
			X_ORIG_SYSTEM_REFERENCE                 => p_org_contact_role_rec.orig_system_reference,
			X_PRIMARY_CON_PER_ROLE_TYPE             => p_org_contact_role_rec.primary_contact_per_role_type,
			X_STATUS                                => p_org_contact_role_rec.status,
			X_OBJECT_VERSION_NUMBER                 => 1,
			X_CREATED_BY_MODULE                     => p_org_contact_role_rec.created_by_module,
			X_APPLICATION_ID                        => p_org_contact_role_rec.application_id
		    );

		    x_org_contact_role_id := p_org_contact_role_rec.org_contact_role_id;

		    -- Debug info.
		    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.debug(p_message=>'HZ_ORG_CONTACT_ROLES_PKG.Insert_Row (-) ' ||
			    'x_org_contact_role_id = ' || x_org_contact_role_id,
					       p_prefix=>l_debug_prefix,
					       p_msg_level=>fnd_log.level_procedure);
		    END IF;
	END;
    END IF;

    -- Bug#6411541: End of changes made by Neeraj

     if p_org_contact_role_rec.orig_system is not null
         and p_org_contact_role_rec.orig_system <>fnd_api.g_miss_char
    then
                l_orig_sys_reference_rec.orig_system := p_org_contact_role_rec.orig_system;
                l_orig_sys_reference_rec.orig_system_reference := p_org_contact_role_rec.orig_system_reference;
                l_orig_sys_reference_rec.owner_table_name := 'HZ_ORG_CONTACT_ROLES';
                l_orig_sys_reference_rec.owner_table_id := p_org_contact_role_rec.org_contact_role_id;
                -- Bug# 6338010: Start changes made by Neeraj
		-- Created by module should not be null
		l_orig_sys_reference_rec.created_by_module := p_org_contact_role_rec.created_by_module;
                -- End changes made by Neeraj

                hz_orig_system_ref_pub.create_orig_system_reference(
                        FND_API.G_FALSE,
                        l_orig_sys_reference_rec,
                        x_return_status,
                        l_msg_count,
                        l_msg_data);
                 IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
      end if;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_org_contact_role (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_create_org_contact_role;


/*===========================================================================+
 | PROCEDURE
 |              do_update_org_contact_role
 |
 | DESCRIPTION
 |              Updates org_contact_role.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_org_contact_role_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_org_contact_role(
    p_org_contact_role_rec          IN OUT    NOCOPY ORG_CONTACT_ROLE_REC_TYPE,
    p_object_version_number         IN OUT NOCOPY    NUMBER,
    x_return_status                 IN OUT NOCOPY    VARCHAR2
) IS

    l_object_version_number                   NUMBER;
    l_rowid                                   ROWID;
    l_msg_count                               NUMBER;
    l_msg_data                                VARCHAR2(2000);
    l_debug_prefix                            VARCHAR2(30);

BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_org_contact_role (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID
        INTO   l_object_version_number,
               l_rowid
        FROM   HZ_ORG_CONTACT_ROLES
        WHERE  ORG_CONTACT_ROLE_ID = p_org_contact_role_rec.org_contact_role_id
        FOR UPDATE OF ORG_CONTACT_ROLE_ID NOWAIT;

        IF NOT (
            ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_org_contact_roles');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'contact role');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL( TO_CHAR(p_org_contact_role_rec.org_contact_role_id ), 'null' ) );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- call for validations.
    HZ_REGISTRY_VALIDATE_V2PUB.validate_org_contact_role(
                                                 'U',
                                                 p_org_contact_role_rec,
                                                 l_rowid,
                                                 x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

      if (p_org_contact_role_rec.orig_system is not null
         and p_org_contact_role_rec.orig_system <>fnd_api.g_miss_char)
        and (p_org_contact_role_rec.orig_system_reference is not null
         and p_org_contact_role_rec.orig_system_reference <>fnd_api.g_miss_char)
      then
                p_org_contact_role_rec.orig_system_reference := null;
                -- In mosr, we have bypassed osr nonupdateable validation
                -- but we should not update existing osr, set it to null
      end if;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_ORG_CONTACT_ROLES_PKG.Update_Row (+) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- call to table-handler
    HZ_ORG_CONTACT_ROLES_PKG.Update_Row (
        X_Rowid                                 => l_rowid,
        X_ORG_CONTACT_ROLE_ID                   => p_org_contact_role_rec.org_contact_role_id,
        X_ORG_CONTACT_ID                        => p_org_contact_role_rec.org_contact_id,
        X_ROLE_TYPE                             => p_org_contact_role_rec.role_type,
        X_ROLE_LEVEL                            => p_org_contact_role_rec.role_level,
        X_PRIMARY_FLAG                          => p_org_contact_role_rec.primary_flag,
        X_ORIG_SYSTEM_REFERENCE                 => p_org_contact_role_rec.orig_system_reference,
        X_PRIMARY_CON_PER_ROLE_TYPE             => p_org_contact_role_rec.primary_contact_per_role_type,
        X_STATUS                                => p_org_contact_role_rec.status,
        X_OBJECT_VERSION_NUMBER                 => p_object_version_number,
        X_CREATED_BY_MODULE                     => p_org_contact_role_rec.created_by_module,
        X_APPLICATION_ID                        => p_org_contact_role_rec.application_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_ORG_CONTACT_ROLES_PKG.Update_Row (-) ',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_org_contact_role (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_org_contact_role;


----------------------------
-- body of public procedures
----------------------------

/*===========================================================================+
 | PROCEDURE
 |              create_org_contact
 |
 | DESCRIPTION
 |              Creates org_contact and party for org_contact.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_org_contact_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_org_contact_id
 |                    x_party_rel_id
 |                    x_party_id
 |                    x_party_number
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE create_org_contact (
    p_init_msg_list             IN     VARCHAR2:= FND_API.G_FALSE,
    p_org_contact_rec           IN     ORG_CONTACT_REC_TYPE,
    x_org_contact_id            OUT NOCOPY    NUMBER,
    x_party_rel_id              OUT NOCOPY    NUMBER,
    x_party_id                  OUT NOCOPY    NUMBER,
    x_party_number              OUT NOCOPY    VARCHAR2,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

    l_api_name              CONSTANT   VARCHAR2(30) := 'create_org_contact';
    l_api_version           CONSTANT   NUMBER       := 1.0;
    l_org_contact_rec                  ORG_CONTACT_REC_TYPE := p_org_contact_rec;
    l_debug_prefix                     VARCHAR2(30) := '';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_org_contact;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_org_contact (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- report error on obsolete columns based on profile
    IF NVL(FND_PROFILE.VALUE('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'Y') = 'Y' THEN
      check_obsolete_columns (
        p_create_update_flag         => 'C',
        p_org_contact_rec            => l_org_contact_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- call to business logic.
    do_create_org_contact(
                          l_org_contact_rec,
                          x_return_status,
                          x_org_contact_id,
                          x_party_rel_id,
                          x_party_id,
                          x_party_number
                         );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.create_org_contact_event (
         l_org_contact_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_org_contacts(
         p_operation      => 'I',
         p_org_contact_id => x_org_contact_id);
     END IF;
   END IF;

    -- Call to indicate Org Contact creation to DQM
    --Bug 4866187
    --Bug 5370799
    IF (p_org_contact_rec.orig_system IS NULL OR  p_org_contact_rec.orig_system=FND_API.G_MISS_CHAR) THEN
        HZ_DQM_SYNC.sync_contact(l_org_contact_rec.org_contact_id, 'C');
    END IF;
    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_org_contact;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
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
            hz_utility_v2pub.debug(p_message=>'create_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;


        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_org_contact;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
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
           hz_utility_v2pub.debug(p_message=>'create_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_org_contact;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
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
            hz_utility_v2pub.debug(p_message=>'create_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_org_contact;


/*===========================================================================+
 | PROCEDURE
 |              update_org_contact
 |
 | DESCRIPTION
 |              Updates org_contact, party relationship for org_contact and
 |        party for party relationship.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_org_contact_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_org_contact_last_update_date
 |                    p_party_rel_last_update_date
 |                    p_party_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE update_org_contact (
    p_init_msg_list                 IN        VARCHAR2:= FND_API.G_FALSE,
    p_org_contact_rec               IN        ORG_CONTACT_REC_TYPE,
    p_cont_object_version_number    IN OUT NOCOPY    NUMBER,
    p_rel_object_version_number     IN OUT NOCOPY    NUMBER,
    p_party_object_version_number   IN OUT NOCOPY    NUMBER,
    x_return_status                 OUT NOCOPY       VARCHAR2,
    x_msg_count                     OUT NOCOPY       NUMBER,
    x_msg_data                      OUT NOCOPY       VARCHAR2
) IS

    l_api_name                      CONSTANT  VARCHAR2(30) := 'update_org_contact';
    l_api_version                   CONSTANT  NUMBER       := 1.0;
    l_org_contact_rec                         ORG_CONTACT_REC_TYPE := p_org_contact_rec;
    l_old_org_contact_rec                     ORG_CONTACT_REC_TYPE;
    l_org_status                              VARCHAR2(1);
    l_debug_prefix                     VARCHAR2(30) := '';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_org_contact;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_org_contact (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (p_org_contact_rec.orig_system is not null
         and p_org_contact_rec.orig_system <>fnd_api.g_miss_char)
       and (p_org_contact_rec.orig_system_reference is not null
         and p_org_contact_rec.orig_system_reference <>fnd_api.g_miss_char)
       and (p_org_contact_rec.org_contact_id = FND_API.G_MISS_NUM or p_org_contact_rec.org_contact_id is null) THEN
           hz_orig_system_ref_pub.get_owner_table_id
                        (p_orig_system => p_org_contact_rec.orig_system,
                        p_orig_system_reference => p_org_contact_rec.orig_system_reference,
                        p_owner_table_name => 'HZ_ORG_CONTACTS',
                        x_owner_table_id => l_org_contact_rec.org_contact_id,
                        x_return_status => x_return_status);
            IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
      END IF;


    -- Get old records. Will be used by business event system.
    get_org_contact_rec (
        p_org_contact_id                     => l_org_contact_rec.org_contact_id,
        x_org_contact_rec                    => l_old_org_contact_rec,
        x_return_status                      => x_return_status,
        x_msg_count                          => x_msg_count,
        x_msg_data                           => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- report error on obsolete columns based on profile
    IF NVL(FND_PROFILE.VALUE('HZ_API_ERR_ON_OBSOLETE_COLUMN'), 'Y') = 'Y' THEN
      check_obsolete_columns (
        p_create_update_flag         => 'U',
        p_org_contact_rec            => l_org_contact_rec,
        p_old_org_contact_rec        => l_old_org_contact_rec,
        x_return_status              => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- call to business logic.
    do_update_org_contact(
                          l_org_contact_rec,
                          p_cont_object_version_number,
                          p_rel_object_version_number,
                          p_party_object_version_number,
                          x_return_status
                         );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     l_old_org_contact_rec.orig_system := p_org_contact_rec.orig_system;
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
       -- Invoke business event system.
       HZ_BUSINESS_EVENT_V2PVT.update_org_contact_event (
         l_org_contact_rec,
         l_old_org_contact_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_org_contacts(
         p_operation      => 'U',
         p_org_contact_id => l_org_contact_rec.org_contact_id);
     END IF;
   END IF;

    -- Call to indicate Org Contact update to DQM
    HZ_DQM_SYNC.sync_contact(l_org_contact_rec.org_contact_id, 'U');

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_org_contact;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
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
            hz_utility_v2pub.debug(p_message=>'update_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_org_contact;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
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
           hz_utility_v2pub.debug(p_message=>'update_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_org_contact;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
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
            hz_utility_v2pub.debug(p_message=>'update_org_contact (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_org_contact;


/*===========================================================================+
 | PROCEDURE
 |              create_org_contact_role
 |
 | DESCRIPTION
 |              Creates org_contact_role.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_org_contact_role_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_org_contact_role_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE create_org_contact_role (
    p_init_msg_list               IN     VARCHAR2:= FND_API.G_FALSE,
    p_org_contact_role_rec        IN     ORG_CONTACT_ROLE_REC_TYPE,
    x_org_contact_role_id         OUT NOCOPY    NUMBER,
    x_return_status               OUT NOCOPY    VARCHAR2,
    x_msg_count                   OUT NOCOPY    NUMBER,
    x_msg_data                    OUT NOCOPY    VARCHAR2
) IS

    l_api_name                 CONSTANT  VARCHAR2(30) := 'create_org_contact_role';
    l_api_version              CONSTANT  NUMBER       := 1.0;
    l_org_contact_role_rec               ORG_CONTACT_ROLE_REC_TYPE := p_org_contact_role_rec;
    l_debug_prefix                       VARCHAR2(30) := '';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_org_contact_role;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_org_contact_role (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_org_contact_role(
                               l_org_contact_role_rec,
                               x_org_contact_role_id,
                               x_return_status
                              );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     -- Invoke business event system.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
       HZ_BUSINESS_EVENT_V2PVT.create_org_contact_role_event (
         l_org_contact_role_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_org_contact_roles(
         p_operation           => 'I',
         p_org_contact_role_id => x_org_contact_role_id );
     END IF;
   END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_org_contact_role (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_org_contact_role;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
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
            hz_utility_v2pub.debug(p_message=>'create_org_contact_role (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_org_contact_role;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
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
           hz_utility_v2pub.debug(p_message=>'create_org_contact_role (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_org_contact_role;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
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
            hz_utility_v2pub.debug(p_message=>'create_org_contact_role (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END create_org_contact_role;


/*===========================================================================+
 | PROCEDURE
 |              update_org_contact_role
 |
 | DESCRIPTION
 |              Updates org_contact_role.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_org_contact_role_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE update_org_contact_role (
    p_init_msg_list              IN        VARCHAR2:= FND_API.G_FALSE,
    p_org_contact_role_rec       IN        ORG_CONTACT_ROLE_REC_TYPE,
    p_object_version_number      IN OUT NOCOPY    NUMBER,
    x_return_status              OUT NOCOPY       VARCHAR2,
    x_msg_count                  OUT NOCOPY       NUMBER,
    x_msg_data                   OUT NOCOPY       VARCHAR2
) IS

    l_api_name                   CONSTANT  VARCHAR2(30) := 'update_org_contact_role';
    l_api_version                CONSTANT  NUMBER       := 1.0;
    l_org_contact_role_rec                 ORG_CONTACT_ROLE_REC_TYPE := p_org_contact_role_rec;
    l_old_org_contact_role_rec             ORG_CONTACT_ROLE_REC_TYPE ;
    l_debug_prefix                       VARCHAR2(30) := '';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_org_contact_role;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_org_contact_role (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_org_contact_role_rec.orig_system is not null
         and p_org_contact_role_rec.orig_system <>fnd_api.g_miss_char)
       and (p_org_contact_role_rec.orig_system_reference is not null
         and p_org_contact_role_rec.orig_system_reference <>fnd_api.g_miss_char)
       and (p_org_contact_role_rec.org_contact_role_id = FND_API.G_MISS_NUM or p_org_contact_role_rec.org_contact_role_id is null) THEN
           hz_orig_system_ref_pub.get_owner_table_id
                        (p_orig_system => p_org_contact_role_rec.orig_system,
                        p_orig_system_reference => p_org_contact_role_rec.orig_system_reference,
                        p_owner_table_name => 'HZ_ORG_CONTACT_ROLES',
                        x_owner_table_id => l_org_contact_role_rec.org_contact_role_id,
                        x_return_status => x_return_status);
            IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
      END IF;

    --2290537
    get_org_contact_role_rec (
      p_org_contact_role_id    => l_org_contact_role_rec.org_contact_role_id,
      x_org_contact_role_rec   => l_old_org_contact_role_rec,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call to business logic.
    do_update_org_contact_role(
                               l_org_contact_role_rec,
                               p_object_version_number,
                               x_return_status
                              );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     -- Invoke business event system.
     l_old_org_contact_role_rec.orig_system := p_org_contact_role_rec.orig_system;
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'Y')) THEN
       HZ_BUSINESS_EVENT_V2PVT.update_org_contact_role_event (
         l_org_contact_role_rec , l_old_org_contact_role_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       HZ_POPULATE_BOT_PKG.pop_hz_org_contact_roles(
         p_operation           => 'U',
         p_org_contact_role_id => l_org_contact_role_rec.org_contact_role_id );
     END IF;
   END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_org_contact_role (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_org_contact_role;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
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
            hz_utility_v2pub.debug(p_message=>'update_org_contact_role (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_org_contact_role;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
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
           hz_utility_v2pub.debug(p_message=>'update_org_contact_role (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_org_contact_role;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
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
            hz_utility_v2pub.debug(p_message=>'update_org_contact_role (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

END update_org_contact_role;

/*===========================================================================+
 | PROCEDURE
 |              get_org_contact_rec
 |
 | DESCRIPTION
 |              Gets current record.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_org_contact_id
 |              OUT:
 |                    x_org_contact_rec
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |                   Jyoti Pandey   Bug: 2084351
 |                    HZ_PARTY_CONTACT_V2PUB.GET_ORG_CONTACT_REC SHOULD
 |                    RETURN THE RELATIONSHIP REC
 |
 +===========================================================================*/

PROCEDURE get_org_contact_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_org_contact_id                        IN     NUMBER,
    x_org_contact_rec                       OUT    NOCOPY ORG_CONTACT_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_org_contact_rec';
    l_api_version                           CONSTANT NUMBER := 1.0;
    l_party_relationship_id                 NUMBER;

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --Check whether primary key has been passed in.
    IF p_org_contact_id IS NULL OR
       p_org_contact_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'org_contact_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_org_contact_rec.org_contact_id := p_org_contact_id;

    HZ_ORG_CONTACTS_PKG.Select_Row (
        X_ORG_CONTACT_ID                        => x_org_contact_rec.org_contact_id,
        X_PARTY_RELATIONSHIP_ID                 => l_party_relationship_id,
        X_COMMENTS                              => x_org_contact_rec.comments,
        X_CONTACT_NUMBER                        => x_org_contact_rec.contact_number,
        X_DEPARTMENT_CODE                       => x_org_contact_rec.department_code,
        X_DEPARTMENT                            => x_org_contact_rec.department,
        X_TITLE                                 => x_org_contact_rec.title,
        X_JOB_TITLE                             => x_org_contact_rec.job_title,
        X_DECISION_MAKER_FLAG                   => x_org_contact_rec.decision_maker_flag,
        X_JOB_TITLE_CODE                        => x_org_contact_rec.job_title_code,
        X_REFERENCE_USE_FLAG                    => x_org_contact_rec.reference_use_flag,
        X_RANK                                  => x_org_contact_rec.rank,
        X_ORIG_SYSTEM_REFERENCE                 => x_org_contact_rec.orig_system_reference,
        X_ATTRIBUTE_CATEGORY                    => x_org_contact_rec.attribute_category,
        X_ATTRIBUTE1                            => x_org_contact_rec.attribute1,
        X_ATTRIBUTE2                            => x_org_contact_rec.attribute2,
        X_ATTRIBUTE3                            => x_org_contact_rec.attribute3,
        X_ATTRIBUTE4                            => x_org_contact_rec.attribute4,
        X_ATTRIBUTE5                            => x_org_contact_rec.attribute5,
        X_ATTRIBUTE6                            => x_org_contact_rec.attribute6,
        X_ATTRIBUTE7                            => x_org_contact_rec.attribute7,
        X_ATTRIBUTE8                            => x_org_contact_rec.attribute8,
        X_ATTRIBUTE9                            => x_org_contact_rec.attribute9,
        X_ATTRIBUTE10                           => x_org_contact_rec.attribute10,
        X_ATTRIBUTE11                           => x_org_contact_rec.attribute11,
        X_ATTRIBUTE12                           => x_org_contact_rec.attribute12,
        X_ATTRIBUTE13                           => x_org_contact_rec.attribute13,
        X_ATTRIBUTE14                           => x_org_contact_rec.attribute14,
        X_ATTRIBUTE15                           => x_org_contact_rec.attribute15,
        X_ATTRIBUTE16                           => x_org_contact_rec.attribute16,
        X_ATTRIBUTE17                           => x_org_contact_rec.attribute17,
        X_ATTRIBUTE18                           => x_org_contact_rec.attribute18,
        X_ATTRIBUTE19                           => x_org_contact_rec.attribute19,
        X_ATTRIBUTE20                           => x_org_contact_rec.attribute20,
        X_ATTRIBUTE21                           => x_org_contact_rec.attribute21,
        X_ATTRIBUTE22                           => x_org_contact_rec.attribute22,
        X_ATTRIBUTE23                           => x_org_contact_rec.attribute23,
        X_ATTRIBUTE24                           => x_org_contact_rec.attribute24,
        X_PARTY_SITE_ID                         => x_org_contact_rec.party_site_id,
        X_CREATED_BY_MODULE                     => x_org_contact_rec.created_by_module,
        X_APPLICATION_ID                        => x_org_contact_rec.application_id
    );

   ---Bug: 2084351 HZ_PARTY_CONTACT_V2PUB.GET_ORG_CONTACT_REC SHOULD
   ---             RETURN THE RELATIONSHIP REC

   IF l_party_relationship_id IS NOT NULL
       AND
       l_party_relationship_id <> FND_API.G_MISS_NUM
    THEN
        HZ_RELATIONSHIP_V2PUB.get_relationship_rec (
                p_relationship_id                  => l_party_relationship_id,
                p_directional_flag                 => 'F',
                x_rel_rec                          => x_org_contact_rec.party_rel_rec,
                x_return_status                    => x_return_status,
                x_msg_count                        => x_msg_count,
                x_msg_data                         => x_msg_data
            );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_org_contact_rec;

/*===========================================================================+
 | PROCEDURE
 |              get_org_contact_role_rec
 |
 | DESCRIPTION
 |              Gets current record.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_org_contact_id
 |              OUT:
 |                    x_org_contact_rec
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE get_org_contact_role_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_org_contact_role_id                   IN     NUMBER,
    x_org_contact_role_rec                  OUT    NOCOPY ORG_CONTACT_ROLE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_org_contact_role_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_org_contact_role_id IS NULL OR
       p_org_contact_role_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'org_contact_role_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_org_contact_role_rec.org_contact_role_id := p_org_contact_role_id;

    HZ_ORG_CONTACT_ROLES_PKG.Select_Row (
        X_ORG_CONTACT_ROLE_ID                   => x_org_contact_role_rec.org_contact_role_id,
        X_ORG_CONTACT_ID                        => x_org_contact_role_rec.org_contact_id,
        X_ROLE_TYPE                             => x_org_contact_role_rec.role_type,
        X_ROLE_LEVEL                            => x_org_contact_role_rec.role_level,
        X_PRIMARY_FLAG                          => x_org_contact_role_rec.primary_flag,
        X_ORIG_SYSTEM_REFERENCE                 => x_org_contact_role_rec.orig_system_reference,
        X_PRIMARY_CON_PER_ROLE_TYPE             => x_org_contact_role_rec.primary_contact_per_role_type,
        X_STATUS                                => x_org_contact_role_rec.status,
        X_CREATED_BY_MODULE                     => x_org_contact_role_rec.created_by_module,
        X_APPLICATION_ID                        => x_org_contact_role_rec.application_id
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_org_contact_role_rec;

/**
 * PRIVATE PROCEDURE check_obsolete_columns
 *
 * DESCRIPTION
 *     Check if user is using obsolete columns.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * MODIFICATION HISTORY
 *
 *   07-25-2005    Jianying Huang      o Created.
 *
 */

PROCEDURE check_obsolete_columns (
    p_create_update_flag          IN     VARCHAR2,
    p_org_contact_rec             IN     org_contact_rec_type,
    p_old_org_contact_rec         IN     org_contact_rec_type DEFAULT NULL,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

BEGIN

    -- check title
    IF (p_create_update_flag = 'C' AND
        p_org_contact_rec.title IS NOT NULL AND
        p_org_contact_rec.title <> FND_API.G_MISS_CHAR) OR
       (p_create_update_flag = 'U' AND
        p_org_contact_rec.title IS NOT NULL AND
        p_org_contact_rec.title <> p_old_org_contact_rec.title)
    THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OBSOLETE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'title');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

END check_obsolete_columns;

END HZ_PARTY_CONTACT_V2PUB;

/
