--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCOUNT_MERGE_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCOUNT_MERGE_V2PVT" AS
/*$Header: ARHACTMB.pls 120.16.12010000.3 2009/05/26 09:27:09 vsegu ship $ */

  g_pkg_name CONSTANT VARCHAR2(30) := 'HZ_CUST_ACCOUNT_MERGE_V2PVT';

  g_pst_mixnmatch_enabled             VARCHAR2(1);
  g_pst_selected_datasources          VARCHAR2(255);
  g_pst_is_datasource_selected        VARCHAR2(1) := 'N';
  g_pst_entity_attr_id                NUMBER;


  g_cpt_mixnmatch_enabled              VARCHAR2(1);
  g_cpt_selected_datasources           VARCHAR2(255);
  g_cpt_is_datasource_selected         VARCHAR2(1) := 'N';
  g_cpt_entity_attr_id                 NUMBER;

  g_rel_mixnmatch_enabled             VARCHAR2(1);
  g_rel_selected_datasources          VARCHAR2(255);
  g_rel_is_datasource_selected        VARCHAR2(1) := 'N';
  g_rel_entity_attr_id                NUMBER;

  -----------------------------PARTY------------------------------------------

  TYPE party_dup_rec_type IS RECORD(
    sic_code                        VARCHAR2(30),
    sic_code_type                   VARCHAR2(30),
    hq_branch_ind                   VARCHAR2(2),
    tax_reference                   VARCHAR2(50),
    jgzz_fiscal_code                VARCHAR2(20),
    duns_number_c                   VARCHAR2(30),
    pre_name_adjunct                VARCHAR2(30),
    first_name                      VARCHAR2(150),
    middle_name                     VARCHAR2(60),
    last_name                       VARCHAR2(150),
    name_suffix                     VARCHAR2(30),
    title                           VARCHAR2(60),
    academic_title                  VARCHAR2(260),
    previous_last_name              VARCHAR2(150),
    known_as                        VARCHAR2(240),
    known_as2                       VARCHAR2(240),
    known_as3                       VARCHAR2(240),
    known_as4                       VARCHAR2(240),
    known_as5                       VARCHAR2(240),
    person_iden_type                VARCHAR2(5),
    person_identifier               VARCHAR2(60),
    country                         VARCHAR2(60),
    address1                        VARCHAR2(240),
    address2                        VARCHAR2(240),
    address3                        VARCHAR2(240),
    address4                        VARCHAR2(240),
    city                            VARCHAR2(60),
    postal_code                     VARCHAR2(60),
    state                           VARCHAR2(60),
    province                        VARCHAR2(60),
     county                          VARCHAR2(60),
    url                             VARCHAR2(2000),
    email_address                   VARCHAR2(2000),
    next_fy_potential_revenue       NUMBER,
    mission_statement               VARCHAR2(2000),
    organization_name_phonetic      VARCHAR2(320),
    person_first_name_phonetic      VARCHAR2(60),
    person_last_name_phonetic       VARCHAR2(60),
    middle_name_phonetic            VARCHAR2(60),
    language_name                   VARCHAR2(4),
    analysis_fy                     VARCHAR2(5),
    fiscal_yearend_month            VARCHAR2(30),
    employees_total                 NUMBER,
    curr_fy_potential_revenue       NUMBER,
    year_established                NUMBER,
    gsa_indicator_flag              VARCHAR2(1),
    created_by_module               VARCHAR2(150),
    application_id                  NUMBER
  );

  PROCEDURE get_party_rec (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_party_id                  IN     NUMBER,
    x_party_rec                 OUT    NOCOPY hz_party_v2pub.party_rec_type,
    x_return_status             OUT    NOCOPY VARCHAR2,
    x_msg_count                 OUT    NOCOPY NUMBER,
    x_msg_data                  OUT    NOCOPY VARCHAR2
  ) IS

    l_api_name                  CONSTANT VARCHAR2(30) := 'get_party_rec';
    x_party_dup_rec             party_dup_rec_type;
    l_party_name                hz_parties.party_name%TYPE;
    l_party_type                hz_parties.party_type%TYPE;
    l_customer_key              hz_parties.customer_key%TYPE;
    l_group_type                hz_parties.group_type%TYPE;
    l_country                   hz_parties.country%TYPE;
    l_address1                  hz_parties.address1%TYPE;
    l_address2                  hz_parties.address2%TYPE;
    l_address3                  hz_parties.address3%TYPE;
    l_address4                  hz_parties.address4%TYPE;
    l_city                      hz_parties.city%TYPE;
    l_state                     hz_parties.state%TYPE;
    l_postal_code               hz_parties.postal_code%TYPE;
    l_province                  hz_parties.province%TYPE;
    l_county                    hz_parties.county%TYPE;
    l_url                       hz_parties.url%TYPE;
    l_email_address             hz_parties.email_address%TYPE;
    l_language_name             hz_parties.language_name%TYPE;
    l_created_by_module         hz_parties.created_by_module%TYPE;
    l_application_id            NUMBER;

  BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --Check whether primary key has been passed in.
    IF p_party_id IS NULL OR
       p_party_id = fnd_api.g_miss_num THEN
        fnd_message.set_name( 'AR', 'HZ_API_MISSING_COLUMN' );
        fnd_message.set_token( 'COLUMN', 'party_id' );
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END IF;

    x_party_rec.party_id := p_party_id;

    hz_parties_pkg.select_row (
        X_PARTY_ID                              => x_party_rec.party_id,
        X_PARTY_NUMBER                          => x_party_rec.party_number,
        X_PARTY_NAME                            => l_party_name,
        X_PARTY_TYPE                            => l_party_type,
        X_VALIDATED_FLAG                        => x_party_rec.validated_flag,
        X_ATTRIBUTE_CATEGORY                    => x_party_rec.attribute_category,
        X_ATTRIBUTE1                            => x_party_rec.attribute1,
        X_ATTRIBUTE2                            => x_party_rec.attribute2,
        X_ATTRIBUTE3                            => x_party_rec.attribute3,
        X_ATTRIBUTE4                            => x_party_rec.attribute4,
        X_ATTRIBUTE5                            => x_party_rec.attribute5,
        X_ATTRIBUTE6                            => x_party_rec.attribute6,
        X_ATTRIBUTE7                            => x_party_rec.attribute7,
        X_ATTRIBUTE8                            => x_party_rec.attribute8,
        X_ATTRIBUTE9                            => x_party_rec.attribute9,
        X_ATTRIBUTE10                           => x_party_rec.attribute10,
        X_ATTRIBUTE11                           => x_party_rec.attribute11,
        X_ATTRIBUTE12                           => x_party_rec.attribute12,
        X_ATTRIBUTE13                           => x_party_rec.attribute13,
        X_ATTRIBUTE14                           => x_party_rec.attribute14,
        X_ATTRIBUTE15                           => x_party_rec.attribute15,
        X_ATTRIBUTE16                           => x_party_rec.attribute16,
        X_ATTRIBUTE17                           => x_party_rec.attribute17,
        X_ATTRIBUTE18                           => x_party_rec.attribute18,
        X_ATTRIBUTE19                           => x_party_rec.attribute19,
        X_ATTRIBUTE20                           => x_party_rec.attribute20,
        X_ATTRIBUTE21                           => x_party_rec.attribute21,
        X_ATTRIBUTE22                           => x_party_rec.attribute22,
        X_ATTRIBUTE23                           => x_party_rec.attribute23,
        X_ATTRIBUTE24                           => x_party_rec.attribute24,
        X_ORIG_SYSTEM_REFERENCE                 => x_party_rec.orig_system_reference,
        X_SIC_CODE                              => x_party_dup_rec.sic_code,
        X_HQ_BRANCH_IND                         => x_party_dup_rec.hq_branch_ind,
        X_CUSTOMER_KEY                          => l_customer_key,
        X_TAX_REFERENCE                         => x_party_dup_rec.tax_reference,
        X_JGZZ_FISCAL_CODE                      => x_party_dup_rec.jgzz_fiscal_code,
        X_PERSON_PRE_NAME_ADJUNCT               => x_party_dup_rec.pre_name_adjunct,
        X_PERSON_FIRST_NAME                     => x_party_dup_rec.first_name,
        X_PERSON_MIDDLE_NAME                    => x_party_dup_rec.middle_name,
        X_PERSON_LAST_NAME                      => x_party_dup_rec.last_name,
        X_PERSON_NAME_SUFFIX                    => x_party_dup_rec.name_suffix,
        X_PERSON_TITLE                          => x_party_dup_rec.title,
        X_PERSON_ACADEMIC_TITLE                 => x_party_dup_rec.academic_title,
        X_PERSON_PREVIOUS_LAST_NAME             => x_party_dup_rec.previous_last_name,
        X_KNOWN_AS                              => x_party_dup_rec.known_as,
        X_PERSON_IDEN_TYPE                      => x_party_dup_rec.person_iden_type,
        X_PERSON_IDENTIFIER                     => x_party_dup_rec.person_identifier,
        X_GROUP_TYPE                            => l_group_type,
        X_COUNTRY                               => l_country,
        X_ADDRESS1                              => l_address1,
        X_ADDRESS2                              => l_address2,
        X_ADDRESS3                              => l_address3,
        X_ADDRESS4                              => l_address4,
        X_CITY                                  => l_city,
        X_POSTAL_CODE                           => l_postal_code,
        X_STATE                                 => l_state,
        X_PROVINCE                              => l_province,
        X_STATUS                                => x_party_rec.status,
        X_COUNTY                                => l_county,
        X_SIC_CODE_TYPE                         => x_party_dup_rec.sic_code_type,
        X_URL                                   => l_url,
        X_EMAIL_ADDRESS                         => l_email_address,
        X_ANALYSIS_FY                           => x_party_dup_rec.analysis_fy,
        X_FISCAL_YEAREND_MONTH                  => x_party_dup_rec.fiscal_yearend_month,
        X_EMPLOYEES_TOTAL                       => x_party_dup_rec.employees_total,
        X_CURR_FY_POTENTIAL_REVENUE             => x_party_dup_rec.curr_fy_potential_revenue,
        X_NEXT_FY_POTENTIAL_REVENUE             => x_party_dup_rec.next_fy_potential_revenue,
        X_YEAR_ESTABLISHED                      => x_party_dup_rec.year_established,
        X_GSA_INDICATOR_FLAG                    => x_party_dup_rec.gsa_indicator_flag,
        X_MISSION_STATEMENT                     => x_party_dup_rec.mission_statement,
        X_ORGANIZATION_NAME_PHONETIC            => x_party_dup_rec.organization_name_phonetic,
        X_PERSON_FIRST_NAME_PHONETIC            => x_party_dup_rec.person_first_name_phonetic,
        X_PERSON_LAST_NAME_PHONETIC             => x_party_dup_rec.person_last_name_phonetic,
        X_LANGUAGE_NAME                         => l_language_name,
        X_CATEGORY_CODE                         => x_party_rec.category_code,
        X_SALUTATION                            => x_party_rec.salutation,
        X_KNOWN_AS2                             => x_party_dup_rec.known_as2,
        X_KNOWN_AS3                             => x_party_dup_rec.known_as3,
        X_KNOWN_AS4                             => x_party_dup_rec.known_as4,
        X_KNOWN_AS5                             => x_party_dup_rec.known_as5,
        X_DUNS_NUMBER_C                         => x_party_dup_rec.duns_number_c,
        X_CREATED_BY_MODULE                     => l_created_by_module,
        X_APPLICATION_ID                        => l_application_id
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

        fnd_message.set_name( 'AR', 'HZ_API_OTHERS_EXCEP' );
        fnd_message.set_token( 'ERROR' ,SQLERRM );
        fnd_msg_pub.add;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

  END get_party_rec;

---------------------------RELATIONSHIP----------------------------------------------------

PROCEDURE do_create_rel(
    p_relationship_rec      IN OUT  NOCOPY HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
    p_direction_code          IN      VARCHAR2,
    x_created_party         OUT     NOCOPY VARCHAR2,
    x_relationship_id       OUT     NOCOPY NUMBER,
    x_party_id              OUT     NOCOPY NUMBER,
    x_party_number          OUT     NOCOPY VARCHAR2,
    x_return_status         IN OUT  NOCOPY VARCHAR2
);

PROCEDURE do_create_party(
    p_party_type        IN      VARCHAR2,
    p_relationship_rec  IN      HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
    x_party_id          OUT     NOCOPY NUMBER,
    x_party_number      OUT     NOCOPY VARCHAR2,
    x_profile_id        OUT     NOCOPY NUMBER,
    x_return_status     IN OUT  NOCOPY VARCHAR2
);

PROCEDURE do_update_party_flags(
    p_relationship_rec              IN     HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
    p_party_id                      IN     NUMBER
);


PROCEDURE do_unmark_primary_per_type(
    p_party_id                      IN     NUMBER,
    p_party_site_id                 IN     NUMBER,
    p_site_use_type                 IN     VARCHAR2
);

-----------------------------
-- body of private procedures
-----------------------------

PROCEDURE do_create_rel(
    p_relationship_rec        IN OUT  NOCOPY HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
    p_direction_code          IN      VARCHAR2,
    x_created_party           OUT     NOCOPY VARCHAR2,
    x_relationship_id         OUT     NOCOPY NUMBER,
    x_party_id                OUT     NOCOPY NUMBER,
    x_party_number            OUT     NOCOPY VARCHAR2,
    x_return_status           IN OUT  NOCOPY VARCHAR2
) IS

   -- this cursor will uniquely identify a record
   -- in hz_relationship_types package
    CURSOR c_rel_type
    IS
    SELECT RELATIONSHIP_TYPE,
           FORWARD_REL_CODE,
           BACKWARD_REL_CODE,
           CREATE_PARTY_FLAG,
           ALLOW_RELATE_TO_SELF_FLAG,
           HIERARCHICAL_FLAG,
           ALLOW_CIRCULAR_RELATIONSHIPS,
           DIRECTION_CODE,
           RELATIONSHIP_TYPE_ID,
           MULTIPLE_PARENT_ALLOWED
    FROM   HZ_RELATIONSHIP_TYPES
    WHERE  RELATIONSHIP_TYPE = p_relationship_rec.relationship_type
    AND    FORWARD_REL_CODE = p_relationship_rec.relationship_code
    AND    SUBJECT_TYPE = p_relationship_rec.subject_type
    AND    OBJECT_TYPE = p_relationship_rec.object_type
    AND    STATUS = 'A';

    r_rel_type c_rel_type%ROWTYPE;

   -- this cursor retrieves all parents for a given child in a particular
   --hierarchy.
    -- it will be used for circularity check.
    CURSOR c_parent1 (p_parent_id NUMBER, p_parent_table_name VARCHAR2,
                      p_parent_object_type VARCHAR2)
    IS
    SELECT SUBJECT_ID,
           SUBJECT_TABLE_NAME,
           SUBJECT_TYPE
    FROM   HZ_RELATIONSHIPS
     START WITH OBJECT_ID = p_parent_id
    AND OBJECT_TABLE_NAME = p_parent_table_name
    AND OBJECT_TYPE = p_parent_object_type
    AND DIRECTION_CODE = 'P'
    AND RELATIONSHIP_TYPE = p_relationship_rec.relationship_type
    AND (  START_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE) AND
           NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00','DD-MM-YYYY HH24:MI:SS'))
      OR END_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
      AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS'))
      OR
      NVL(p_relationship_rec.start_date, SYSDATE) BETWEEN START_DATE AND END_DATE
      OR
      NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) BETWEEN START_DATE AND END_DATE)
    CONNECT BY OBJECT_ID = PRIOR SUBJECT_ID AND OBJECT_TYPE = PRIOR SUBJECT_TYPE AND OBJECT_TABLE_NAME = PRIOR SUBJECT_TABLE_NAME
      AND DIRECTION_CODE = 'P' AND RELATIONSHIP_TYPE =  p_relationship_rec.relationship_type
      AND (START_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
      AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS'))
      OR
       END_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
       AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS'))
       OR
      NVL(p_relationship_rec.start_date, SYSDATE) BETWEEN START_DATE AND END_DATE
      OR
      NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) BETWEEN START_DATE AND END_DATE);

  -- this cursor retrieves all child for a given parent in a particular hierarchy
  -- it will be used for circularity check.
    CURSOR c_child1 (p_child_id NUMBER, p_child_table_name VARCHAR2,
                     p_child_object_type VARCHAR2)
    IS
    SELECT OBJECT_ID,
           OBJECT_TABLE_NAME,
           OBJECT_TYPE
    FROM   HZ_RELATIONSHIPS
    START WITH SUBJECT_ID = p_child_id
   AND SUBJECT_TABLE_NAME = p_child_table_name
   AND SUBJECT_TYPE = p_child_object_type
   AND DIRECTION_CODE = 'P'
   AND RELATIONSHIP_TYPE = p_relationship_rec.relationship_type
   AND (START_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
   AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS'))
           OR
           END_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
                          AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS'))
           OR
           NVL(p_relationship_rec.start_date, SYSDATE) BETWEEN START_DATE AND END_DATE
           OR
           NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) BETWEEN START_DATE AND END_DATE)
    CONNECT BY SUBJECT_ID = PRIOR OBJECT_ID AND SUBJECT_TYPE = PRIOR OBJECT_TYPE AND SUBJECT_TABLE_NAME = PRIOR OBJECT_TABLE_NAME
           AND DIRECTION_CODE = 'P' AND RELATIONSHIP_TYPE =  p_relationship_rec.relationship_type
           AND (START_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
                          AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS'))
           OR
           END_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
                          AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS'))
           OR
           NVL(p_relationship_rec.start_date, SYSDATE) BETWEEN START_DATE AND END_DATE
           OR
           NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) BETWEEN START_DATE AND END_DATE);

     r_parent1 c_parent1%rowtype;
     r_child1  c_child1%rowtype;

    l_relationship_id  NUMBER := p_relationship_rec.relationship_id;
    l_rowid            ROWID := NULL;
    l_count            NUMBER;
    l_profile_id       NUMBER;
    l_directional_flag  VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_end_date          DATE;
    l_party_rel_rec     HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    l_dummy             VARCHAR2(1) := 'Y';
    l_debug_prefix      VARCHAR2(30) := '';
    l_back_direction    VARCHAR2(30);

    l_hierarchy_rec                   HZ_HIERARCHY_PUB.HIERARCHY_NODE_REC_TYPE;
    l_parent_id                       NUMBER;
    l_parent_object_type              VARCHAR2(30);
    l_parent_table_name               VARCHAR2(30);
    l_child_id                        NUMBER;
    l_child_object_type               VARCHAR2(30);
    l_child_table_name                VARCHAR2(30);
    l_parent_flag                     VARCHAR2(1);

    l_invalid_rel_type     VARCHAR2(1) := 'N';
    l_multiple_parent      VARCHAR2(1) := 'N';
    l_circular_flag        VARCHAR2(1) := 'N';
    l_invalid_rel_to_self  VARCHAR2(1) := 'N';


BEGIN

   ---Initialize the created_by module
    p_relationship_rec.created_by_module           := 'HZ_TCA_CUSTOMER_MERGE';

    ---set the relationship_id to null
    p_relationship_rec.relationship_id := null;


    -- Generate primary key from sequence if not passed in. If this values already exists in
    -- the database, keep generating till a unique value is found.
    -- If primary key value is passed, check for uniqueness.

        WHILE l_dummy = 'Y' LOOP
            BEGIN
                SELECT HZ_RELATIONSHIPS_S.NEXTVAL
                INTO   l_relationship_id
                FROM   DUAL;

                SELECT 'Y'
                INTO   l_dummy
                FROM   HZ_RELATIONSHIPS
                WHERE  RELATIONSHIP_ID = l_relationship_id
                AND    DIRECTIONAL_FLAG = 'F';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_dummy := 'N';
            END;
        END LOOP;

    x_relationship_id := l_relationship_id;

    -- default end date to 31-DEC-4712
    IF p_relationship_rec.end_date IS NULL
       OR
       p_relationship_rec.end_date = FND_API.G_MISS_DATE
    THEN
        l_end_date := to_date('12/31/4712','MM/DD/YYYY');
    ELSE
        l_end_date := p_relationship_rec.end_date;
    END IF;

     -- Open the relationship_type record and get all the info
    OPEN c_rel_type;
    FETCH c_rel_type INTO r_rel_type;
    CLOSE c_rel_type;

    if  r_rel_type.relationship_type is null THEN
        l_invalid_rel_type := 'Y';
    end if;

  --create as long as valid
  if l_invalid_rel_type <> 'Y' then

    -- decide who is parent and who is child in this relationship.
    -- if relationship type record is 'P' type, then subject is parent, else object
    IF r_rel_type.direction_code = 'P' THEN
        l_parent_id := p_relationship_rec.subject_id;
        l_parent_table_name := p_relationship_rec.subject_table_name;
        l_parent_object_type := p_relationship_rec.subject_type;
        l_child_id := p_relationship_rec.object_id;
        l_child_table_name := p_relationship_rec.object_table_name;
        l_child_object_type := p_relationship_rec.object_type;
    ELSIF r_rel_type.direction_code = 'C' THEN
        l_parent_id := p_relationship_rec.object_id;
        l_parent_table_name := p_relationship_rec.object_table_name;
        l_parent_object_type := p_relationship_rec.object_type;
        l_child_id := p_relationship_rec.subject_id;
        l_child_table_name := p_relationship_rec.subject_table_name;
        l_child_object_type := p_relationship_rec.subject_type;
    END IF;

     -- if the relationship type is hierarchical, then we have to check
    -- whether there is already a parent present for the child in the same
    -- hierarchy/relationship type. if so, then we would not allow creation.
    IF r_rel_type.hierarchical_flag = 'Y' THEN
        -- it needs to be done if multiple_parent_allowed is 'N'
        IF r_rel_type.multiple_parent_allowed = 'N' THEN
            BEGIN
                SELECT 1 INTO l_count
                FROM   HZ_RELATIONSHIPS
                WHERE  OBJECT_ID = l_child_id
                AND    OBJECT_TABLE_NAME = l_child_table_name
                AND    OBJECT_TYPE = l_child_object_type
                AND    RELATIONSHIP_TYPE = p_relationship_rec.relationship_type
                AND    DIRECTION_CODE = 'P'
                AND    (START_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
                                      AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS'))
                       OR
                       END_DATE BETWEEN NVL(p_relationship_rec.start_date, SYSDATE)
                                      AND NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS'))
                       OR
                       NVL(p_relationship_rec.start_date, SYSDATE) BETWEEN START_DATE AND END_DATE
                       OR
                       NVL(p_relationship_rec.end_date, TO_DATE('31-12-4712 00:00:00', 'DD-MM-YYYY HH24:MI:SS')) BETWEEN START_DATE AND END_DATE
                       );

            l_multiple_parent := 'Y';

             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- no parent found, proceed
                 NULL;
           END;
        END IF;
     END IF;

   -- if the relationship type does not allow circular, then we
    -- have to check whether creation of the current relationship
    -- will introduce circularity in the tree. if so, we would
    -- prevent that by erroring out.
    IF r_rel_type.hierarchical_flag = 'Y' OR
       r_rel_type.allow_circular_relationships = 'N'
    THEN
        l_parent_flag := 'Y';
        OPEN c_parent1 (l_parent_id, l_parent_table_name, l_parent_object_type);
        FETCH c_parent1 INTO r_parent1;
        WHILE c_parent1%FOUND LOOP
            IF r_parent1.subject_id = l_child_id THEN
               l_circular_flag := 'Y';
                CLOSE c_parent1;
            END IF;
            FETCH c_parent1 INTO r_parent1;
        END LOOP;
        CLOSE c_parent1;
    END IF;

   IF r_rel_type.hierarchical_flag = 'Y' OR
       r_rel_type.allow_circular_relationships = 'N'
    THEN
        l_parent_flag := 'Y';
        OPEN c_child1 (l_child_id, l_child_table_name, l_child_object_type);
        FETCH c_child1 INTO r_child1;
        WHILE c_child1%FOUND LOOP
            IF r_child1.object_id = l_child_id THEN
               l_circular_flag := 'Y';
               CLOSE c_child1;
            END IF;
            FETCH c_child1 INTO r_child1;
        END LOOP;
        CLOSE c_child1;
    END IF;

    -- subject_id and object_id must not have the same value,
     -- unless relationship type allows
    IF r_rel_type.allow_relate_to_self_flag = 'N'
       AND
       p_relationship_rec.subject_id = p_relationship_rec.object_id
    THEN
       l_invalid_rel_to_self := 'Y';
    END IF;

END IF ; ---for valid rel_type

IF  (  l_invalid_rel_type <> 'Y'AND l_multiple_parent <> 'Y'
       AND l_circular_flag <> 'Y' AND  l_invalid_rel_to_self <> 'Y' ) THEN

    -- build the record for creation of relationship party record
    l_party_rel_rec.party_rec := p_relationship_rec.party_rec;
    l_party_rel_rec.subject_id := p_relationship_rec.subject_id;
    l_party_rel_rec.object_id := p_relationship_rec.object_id;
    l_party_rel_rec.created_by_module := p_relationship_rec.created_by_module;
    l_party_rel_rec.application_id := p_relationship_rec.application_id;


    -- the PARTY_RELATIONSHIP type party will be created if
    -- the relationship type has create_party_flag = 'Y' and
    -- both the subject_table_name and object_table_name are
    -- 'HZ_PARTIES'
    IF r_rel_type.create_party_flag = 'Y'
       AND
       p_relationship_rec.subject_table_name = 'HZ_PARTIES'
       AND
       p_relationship_rec.object_table_name = 'HZ_PARTIES'
    THEN
        x_created_party := 'Y';
        do_create_party(
            p_party_type       => 'PARTY_RELATIONSHIP',
            p_relationship_rec => l_party_rel_rec,
            x_party_id         => x_party_id,
            x_party_number     => x_party_number,
            x_profile_id       => l_profile_id,
            x_return_status    => x_return_status
           );
        p_relationship_rec.party_rec.party_id := x_party_id;
        p_relationship_rec.party_rec.party_number := x_party_number;

    ELSE
        x_created_party := 'N';
    END IF;

     -- Denormalize flags to HZ_PARTIES:
    --      COMPETITOR_FLAG
    --      REFERENCE_USE_FLAG
    --      THIRD_PARTY_FLAG
    -- Denormalization will be done only if content_source_type
    -- is 'USER_ENTERED' and both subject_table_name and
    -- object_table_name are 'HZ_PARTIES'

    -- Bug 2197181: added for mix-n-match project. Denormalize
    -- the three flags when the data source is visible (i.e.
    -- selected).

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    IF p_relationship_rec.relationship_code IN
             ('COMPETITOR_OF', 'REFERENCE_FOR', 'PARTNER_OF')
   --AND g_rel_is_datasource_selected = 'Y'
     AND p_relationship_rec.subject_table_name = 'HZ_PARTIES'
     AND p_relationship_rec.object_table_name = 'HZ_PARTIES' THEN

          do_update_party_flags(
                              p_relationship_rec,
                              p_relationship_rec.subject_id);
    END IF;



    p_relationship_rec.relationship_id := l_relationship_id;

    -- Call table-handler to create the forward record.
    HZ_RELATIONSHIPS_PKG.Insert_Row (
        X_RELATIONSHIP_ID             => p_relationship_rec.relationship_id,
        X_SUBJECT_ID                  => p_relationship_rec.subject_id,
        X_SUBJECT_TYPE                => p_relationship_rec.subject_type,
        X_SUBJECT_TABLE_NAME          => p_relationship_rec.subject_table_name,
        X_OBJECT_ID                   => p_relationship_rec.object_id,
        X_OBJECT_TYPE                 => p_relationship_rec.object_type,
        X_OBJECT_TABLE_NAME           => p_relationship_rec.object_table_name,
        X_PARTY_ID                    => x_party_id,
        X_RELATIONSHIP_CODE           => p_relationship_rec.relationship_code,
        X_DIRECTIONAL_FLAG            => 'F',
        X_COMMENTS                    => p_relationship_rec.comments,
        X_START_DATE                  => p_relationship_rec.start_date,
        X_END_DATE                    => l_end_date,
        X_STATUS                      => p_relationship_rec.status,
        X_ATTRIBUTE_CATEGORY          => p_relationship_rec.attribute_category,
        X_ATTRIBUTE1                  => p_relationship_rec.attribute1,
        X_ATTRIBUTE2                  => p_relationship_rec.attribute2,
        X_ATTRIBUTE3                  => p_relationship_rec.attribute3,
        X_ATTRIBUTE4                  => p_relationship_rec.attribute4,
        X_ATTRIBUTE5                  => p_relationship_rec.attribute5,
        X_ATTRIBUTE6                  => p_relationship_rec.attribute6,
        X_ATTRIBUTE7                  => p_relationship_rec.attribute7,
        X_ATTRIBUTE8                  => p_relationship_rec.attribute8,
        X_ATTRIBUTE9                  => p_relationship_rec.attribute9,
        X_ATTRIBUTE10                 => p_relationship_rec.attribute10,
        X_ATTRIBUTE11                 => p_relationship_rec.attribute11,
        X_ATTRIBUTE12                 => p_relationship_rec.attribute12,
        X_ATTRIBUTE13                 => p_relationship_rec.attribute13,
        X_ATTRIBUTE14                 => p_relationship_rec.attribute14,
        X_ATTRIBUTE15                 => p_relationship_rec.attribute15,
        X_ATTRIBUTE16                 => p_relationship_rec.attribute16,
        X_ATTRIBUTE17                 => p_relationship_rec.attribute17,
        X_ATTRIBUTE18                 => p_relationship_rec.attribute18,
        X_ATTRIBUTE19                 => p_relationship_rec.attribute19,
        X_ATTRIBUTE20                 => p_relationship_rec.attribute20,
        X_CONTENT_SOURCE_TYPE         => p_relationship_rec.content_source_type,
        X_RELATIONSHIP_TYPE           => p_relationship_rec.relationship_type,
        X_OBJECT_VERSION_NUMBER       => 1,
        X_CREATED_BY_MODULE           => p_relationship_rec.created_by_module,
        X_APPLICATION_ID              => p_relationship_rec.application_id,
        X_ADDITIONAL_INFORMATION1     => p_relationship_rec.additional_information1,
        X_ADDITIONAL_INFORMATION2     => p_relationship_rec.additional_information2,
        X_ADDITIONAL_INFORMATION3     => p_relationship_rec.additional_information3,
        X_ADDITIONAL_INFORMATION4     => p_relationship_rec.additional_information4,
        X_ADDITIONAL_INFORMATION5     => p_relationship_rec.additional_information5,
        X_ADDITIONAL_INFORMATION6     => p_relationship_rec.additional_information6,
        X_ADDITIONAL_INFORMATION7     => p_relationship_rec.additional_information7,
        X_ADDITIONAL_INFORMATION8     => p_relationship_rec.additional_information8,
        X_ADDITIONAL_INFORMATION9     => p_relationship_rec.additional_information9,
        X_ADDITIONAL_INFORMATION10     => p_relationship_rec.additional_information10,
        X_ADDITIONAL_INFORMATION11     => p_relationship_rec.additional_information11,
        X_ADDITIONAL_INFORMATION12     => p_relationship_rec.additional_information12,
        X_ADDITIONAL_INFORMATION13     => p_relationship_rec.additional_information13,
        X_ADDITIONAL_INFORMATION14     => p_relationship_rec.additional_information14,
        X_ADDITIONAL_INFORMATION15     => p_relationship_rec.additional_information15,
        X_ADDITIONAL_INFORMATION16     => p_relationship_rec.additional_information16,
        X_ADDITIONAL_INFORMATION17     => p_relationship_rec.additional_information17,
        X_ADDITIONAL_INFORMATION18     => p_relationship_rec.additional_information18,
        X_ADDITIONAL_INFORMATION19     => p_relationship_rec.additional_information19,
        X_ADDITIONAL_INFORMATION20     => p_relationship_rec.additional_information20,
        X_ADDITIONAL_INFORMATION21     => p_relationship_rec.additional_information21,
        X_ADDITIONAL_INFORMATION22     => p_relationship_rec.additional_information22,
        X_ADDITIONAL_INFORMATION23     => p_relationship_rec.additional_information23,
        X_ADDITIONAL_INFORMATION24     => p_relationship_rec.additional_information24,
        X_ADDITIONAL_INFORMATION25     => p_relationship_rec.additional_information25,
        X_ADDITIONAL_INFORMATION26     => p_relationship_rec.additional_information26,
        X_ADDITIONAL_INFORMATION27     => p_relationship_rec.additional_information27,
        X_ADDITIONAL_INFORMATION28     => p_relationship_rec.additional_information28,
        X_ADDITIONAL_INFORMATION29     => p_relationship_rec.additional_information29,
        X_ADDITIONAL_INFORMATION30     => p_relationship_rec.additional_information30,
        X_DIRECTION_CODE                => r_rel_type.direction_code,
        X_PERCENTAGE_OWNERSHIP          => p_relationship_rec.percentage_ownership,
        X_ACTUAL_CONTENT_SOURCE         => p_relationship_rec.ACTUAL_CONTENT_SOURCE
    );

    -- Call table-handler again to create the backward record.
    -- This is done because for every relationship we want to
    -- create both forward and backward relationship.

    --If there was no backward record originally do not create it

    -- determine the direction_code for the backward record
    IF r_rel_type.direction_code = 'P' THEN
        l_back_direction := 'C';
    ELSIF r_rel_type.direction_code = 'C' THEN
        l_back_direction := 'P';
    ELSE
        l_back_direction := 'N';
    END IF;

  IF  r_rel_type.BACKWARD_REL_CODE is not null THEN

    HZ_RELATIONSHIPS_PKG.Insert_Row (
        X_RELATIONSHIP_ID             => p_relationship_rec.relationship_id,
        X_SUBJECT_ID                  => p_relationship_rec.object_id,
        X_SUBJECT_TYPE                => p_relationship_rec.object_type,
        X_SUBJECT_TABLE_NAME          => p_relationship_rec.object_table_name,
        X_OBJECT_ID                   => p_relationship_rec.subject_id,
        X_OBJECT_TYPE                  => p_relationship_rec.subject_type,
        X_OBJECT_TABLE_NAME            => p_relationship_rec.subject_table_name,
        X_PARTY_ID                     => x_party_id,
        X_RELATIONSHIP_CODE            => r_rel_type.backward_rel_code,
        X_DIRECTIONAL_FLAG             => 'B',
        X_COMMENTS                     => p_relationship_rec.comments,
        X_START_DATE                   => p_relationship_rec.start_date,
        X_END_DATE                     => l_end_date,
        X_STATUS                       => p_relationship_rec.status,
        X_ATTRIBUTE_CATEGORY           => p_relationship_rec.attribute_category,
        X_ATTRIBUTE1                   => p_relationship_rec.attribute1,
        X_ATTRIBUTE2                   => p_relationship_rec.attribute2,
        X_ATTRIBUTE3                   => p_relationship_rec.attribute3,
        X_ATTRIBUTE4                   => p_relationship_rec.attribute4,
        X_ATTRIBUTE5                   => p_relationship_rec.attribute5,
        X_ATTRIBUTE6                   => p_relationship_rec.attribute6,
        X_ATTRIBUTE7                   => p_relationship_rec.attribute7,
        X_ATTRIBUTE8                   => p_relationship_rec.attribute8,
        X_ATTRIBUTE9                   => p_relationship_rec.attribute9,
        X_ATTRIBUTE10                  => p_relationship_rec.attribute10,
        X_ATTRIBUTE11                  => p_relationship_rec.attribute11,
        X_ATTRIBUTE12                  => p_relationship_rec.attribute12,
        X_ATTRIBUTE13                  => p_relationship_rec.attribute13,
        X_ATTRIBUTE14                  => p_relationship_rec.attribute14,
        X_ATTRIBUTE15                  => p_relationship_rec.attribute15,
        X_ATTRIBUTE16                  => p_relationship_rec.attribute16,
        X_ATTRIBUTE17                  => p_relationship_rec.attribute17,
        X_ATTRIBUTE18                  => p_relationship_rec.attribute18,
        X_ATTRIBUTE19                  => p_relationship_rec.attribute19,
        X_ATTRIBUTE20                  => p_relationship_rec.attribute20,
        X_CONTENT_SOURCE_TYPE          => p_relationship_rec.content_source_type,
        X_RELATIONSHIP_TYPE            => r_rel_type.relationship_type,
        X_OBJECT_VERSION_NUMBER        => 1,
        X_CREATED_BY_MODULE            => p_relationship_rec.created_by_module,
        X_APPLICATION_ID               => p_relationship_rec.application_id,
        X_ADDITIONAL_INFORMATION1      => p_relationship_rec.additional_information1,
        X_ADDITIONAL_INFORMATION2      => p_relationship_rec.additional_information2,
        X_ADDITIONAL_INFORMATION3      => p_relationship_rec.additional_information3,
        X_ADDITIONAL_INFORMATION4      => p_relationship_rec.additional_information4,
        X_ADDITIONAL_INFORMATION5      => p_relationship_rec.additional_information5,
        X_ADDITIONAL_INFORMATION6      => p_relationship_rec.additional_information6,
        X_ADDITIONAL_INFORMATION7      => p_relationship_rec.additional_information7,
        X_ADDITIONAL_INFORMATION8      => p_relationship_rec.additional_information8,
        X_ADDITIONAL_INFORMATION9      => p_relationship_rec.additional_information9,
        X_ADDITIONAL_INFORMATION10      => p_relationship_rec.additional_information10,
        X_ADDITIONAL_INFORMATION11      => p_relationship_rec.additional_information11,
        X_ADDITIONAL_INFORMATION12      => p_relationship_rec.additional_information12,
        X_ADDITIONAL_INFORMATION13      => p_relationship_rec.additional_information13,
        X_ADDITIONAL_INFORMATION14      => p_relationship_rec.additional_information14,
        X_ADDITIONAL_INFORMATION15      => p_relationship_rec.additional_information15,
        X_ADDITIONAL_INFORMATION16      => p_relationship_rec.additional_information16,
        X_ADDITIONAL_INFORMATION17      => p_relationship_rec.additional_information17,
        X_ADDITIONAL_INFORMATION18      => p_relationship_rec.additional_information18,
        X_ADDITIONAL_INFORMATION19      => p_relationship_rec.additional_information19,
        X_ADDITIONAL_INFORMATION20      => p_relationship_rec.additional_information20,
        X_ADDITIONAL_INFORMATION21      => p_relationship_rec.additional_information21,
        X_ADDITIONAL_INFORMATION22      => p_relationship_rec.additional_information22,
        X_ADDITIONAL_INFORMATION23      => p_relationship_rec.additional_information23,
        X_ADDITIONAL_INFORMATION24      => p_relationship_rec.additional_information24,
        X_ADDITIONAL_INFORMATION25      => p_relationship_rec.additional_information25,
        X_ADDITIONAL_INFORMATION26      => p_relationship_rec.additional_information26,
        X_ADDITIONAL_INFORMATION27      => p_relationship_rec.additional_information27,
        X_ADDITIONAL_INFORMATION28      => p_relationship_rec.additional_information28,
        X_ADDITIONAL_INFORMATION29      => p_relationship_rec.additional_information29,
        X_ADDITIONAL_INFORMATION30      => p_relationship_rec.additional_information30,
        X_DIRECTION_CODE                => l_back_direction,
        X_PERCENTAGE_OWNERSHIP          => p_relationship_rec.percentage_ownership,
        X_ACTUAL_CONTENT_SOURCE         => p_relationship_rec.ACTUAL_CONTENT_SOURCE
    );

  END IF;

    -- maintain hierarchy of relationships
    -- check if the relationship type is hierarchical
    IF r_rel_type.hierarchical_flag = 'Y' THEN
        -- check if relationship type is parent one
        IF r_rel_type.direction_code = 'P' THEN
            -- assign the subject to parent for hierarchy
            l_hierarchy_rec.hierarchy_type := r_rel_type.relationship_type;
            l_hierarchy_rec.parent_id := p_relationship_rec.subject_id;
            l_hierarchy_rec.parent_table_name := p_relationship_rec.subject_table_name;
            l_hierarchy_rec.parent_object_type := p_relationship_rec.subject_type;
            l_hierarchy_rec.child_id := p_relationship_rec.object_id;
            l_hierarchy_rec.child_table_name := p_relationship_rec.object_table_name;
            l_hierarchy_rec.child_object_type := p_relationship_rec.object_type;
            l_hierarchy_rec.effective_start_date := p_relationship_rec.start_date;
            l_hierarchy_rec.effective_end_date := l_end_date;
            l_hierarchy_rec.relationship_id := p_relationship_rec.relationship_id;
            l_hierarchy_rec.status := NVL(p_relationship_rec.status, 'A');
        ELSIF r_rel_type.direction_code = 'C' THEN
              -- assign the object to parent
            l_hierarchy_rec.hierarchy_type := r_rel_type.relationship_type;
            l_hierarchy_rec.parent_id := p_relationship_rec.object_id;
            l_hierarchy_rec.parent_table_name := p_relationship_rec.object_table_name;
            l_hierarchy_rec.parent_object_type := p_relationship_rec.object_type;
            l_hierarchy_rec.child_id := p_relationship_rec.subject_id;
            l_hierarchy_rec.child_table_name := p_relationship_rec.subject_table_name;
            l_hierarchy_rec.child_object_type := p_relationship_rec.subject_type;
            l_hierarchy_rec.effective_start_date := p_relationship_rec.start_date;
            l_hierarchy_rec.effective_end_date := l_end_date;
            l_hierarchy_rec.relationship_id := p_relationship_rec.relationship_id;
            l_hierarchy_rec.status := NVL(p_relationship_rec.status, 'A');
        END IF;

        HZ_HIERARCHY_PUB.create_link(
            p_init_msg_list           => FND_API.G_FALSE,
            p_hierarchy_node_rec      => l_hierarchy_rec,
            x_return_status           => x_return_status,
            x_msg_count               => l_msg_count,
            x_msg_data                => l_msg_data
           );
    END IF; --r_rel_type.hierarchical_flag  'Y'

 ELSE   --l_invalid_rel_type <> 'Y'AND l_multiple_parent <> 'Y'
    X_RELATIONSHIP_ID := NULL;     ---no rel was created
 END IF; --l_invalid_rel_type <> 'Y'AND l_multiple_parent <> 'Y'

END do_create_rel;


PROCEDURE do_create_party(
    p_party_type                IN      VARCHAR2,
    p_relationship_rec          IN      HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
    x_party_id                 OUT      NOCOPY NUMBER,
    x_party_number             OUT      NOCOPY VARCHAR2,
    x_profile_id               OUT      NOCOPY NUMBER,
    x_return_status         IN OUT      NOCOPY VARCHAR2
) IS

    l_party_id                NUMBER;
    l_party_number            VARCHAR2(30);
    l_generate_party_number    VARCHAR2(1);
    l_rowid                    ROWID := NULL;
    l_count                    NUMBER;
    l_party_rec                HZ_PARTY_V2PUB.PARTY_REC_TYPE := p_relationship_rec.party_rec;
    l_party_name               hz_parties.PARTY_NAME%TYPE;
    l_subject_name             hz_parties.PARTY_NAME%TYPE;
    l_object_name              hz_parties.PARTY_NAME%TYPE;
    l_customer_key             hz_parties.CUSTOMER_KEY%TYPE;
    l_code_assignment_id       NUMBER;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_dummy                    VARCHAR2(1);
    l_debug_prefix             VARCHAR2(30) := '';
    l_orig_sys_reference_rec    HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

BEGIN

    l_party_rec.orig_system_reference := null;
    l_party_rec.party_id := null;

    -- build the party_name for relationship party
    SELECT PARTY_NAME
    INTO   l_subject_name
    FROM   hz_parties
    WHERE  PARTY_ID = p_relationship_rec.subject_id;

    SELECT PARTY_NAME
    INTO   l_object_name
    FROM   hz_parties
    WHERE  PARTY_ID = p_relationship_rec.object_id;

    l_party_name := SUBSTRB(l_subject_name || '-' ||
                                l_object_name  || '-' ||
                                l_party_number, 1, 360);



    hz_parties_PKG.Insert_Row (
        X_PARTY_ID                              => l_party_rec.party_id,
        X_PARTY_NUMBER                          => l_party_rec.party_number,
        X_PARTY_NAME                            => l_party_name,
        X_PARTY_TYPE                            => p_party_type,
        X_VALIDATED_FLAG                        => l_party_rec.validated_flag,
        X_ATTRIBUTE_CATEGORY                    => l_party_rec.attribute_category,
        X_ATTRIBUTE1                            => l_party_rec.attribute1,
        X_ATTRIBUTE2                            => l_party_rec.attribute2,
        X_ATTRIBUTE3                            => l_party_rec.attribute3,
        X_ATTRIBUTE4                            => l_party_rec.attribute4,
        X_ATTRIBUTE5                            => l_party_rec.attribute5,
        X_ATTRIBUTE6                            => l_party_rec.attribute6,
        X_ATTRIBUTE7                            => l_party_rec.attribute7,
        X_ATTRIBUTE8                            => l_party_rec.attribute8,
        X_ATTRIBUTE9                            => l_party_rec.attribute9,
        X_ATTRIBUTE10                           => l_party_rec.attribute10,
        X_ATTRIBUTE11                           => l_party_rec.attribute11,
        X_ATTRIBUTE12                           => l_party_rec.attribute12,
        X_ATTRIBUTE13                           => l_party_rec.attribute13,
        X_ATTRIBUTE14                           => l_party_rec.attribute14,
        X_ATTRIBUTE15                           => l_party_rec.attribute15,
        X_ATTRIBUTE16                           => l_party_rec.attribute16,
        X_ATTRIBUTE17                           => l_party_rec.attribute17,
        X_ATTRIBUTE18                           => l_party_rec.attribute18,
        X_ATTRIBUTE19                           => l_party_rec.attribute19,
        X_ATTRIBUTE20                           => l_party_rec.attribute20,
        X_ATTRIBUTE21                           => l_party_rec.attribute21,
        X_ATTRIBUTE22                           => l_party_rec.attribute22,
        X_ATTRIBUTE23                           => l_party_rec.attribute23,
        X_ATTRIBUTE24                           => l_party_rec.attribute24,
        X_ORIG_SYSTEM_REFERENCE                 => l_party_rec.orig_system_reference,
        X_SIC_CODE                              => null,
        X_HQ_BRANCH_IND                         => null,
        X_CUSTOMER_KEY                          => null,
        X_TAX_REFERENCE                         => null,
        X_JGZZ_FISCAL_CODE                      => null,
        X_PERSON_PRE_NAME_ADJUNCT               => null,
        X_PERSON_FIRST_NAME                     => null,
        X_PERSON_MIDDLE_NAME                    => null,
        X_PERSON_LAST_NAME                      => null,
        X_PERSON_NAME_SUFFIX                    => null,
        X_PERSON_TITLE                          => null,
        X_PERSON_ACADEMIC_TITLE                 => null,
        X_PERSON_PREVIOUS_LAST_NAME             => null,
        X_KNOWN_AS                              => null,
        X_PERSON_IDEN_TYPE                      => null,
        X_PERSON_IDENTIFIER                     => null,
        X_GROUP_TYPE                            => null,
        X_COUNTRY                               => NULL,
        X_ADDRESS1                              => NULL,
        X_ADDRESS2                              => NULL,
        X_ADDRESS3                              => NULL,
        X_ADDRESS4                              => NULL,
        X_CITY                                  => NULL,
        X_POSTAL_CODE                           => NULL,
        X_STATE                                 => NULL,
        X_PROVINCE                              => NULL,
        X_STATUS                                => l_party_rec.status,
        X_COUNTY                                => NULL,
        X_SIC_CODE_TYPE                         => null,
        X_URL                                   => NULL,
        X_EMAIL_ADDRESS                         => NULL,
        X_ANALYSIS_FY                           => null,
        X_FISCAL_YEAREND_MONTH                  => null,
        X_EMPLOYEES_TOTAL                       => null,
        X_CURR_FY_POTENTIAL_REVENUE             => null,
        X_NEXT_FY_POTENTIAL_REVENUE             => null,
        X_YEAR_ESTABLISHED                      => null,
        X_GSA_INDICATOR_FLAG                    => null,
        X_MISSION_STATEMENT                     => null,
        X_ORGANIZATION_NAME_PHONETIC            => null,
        X_PERSON_FIRST_NAME_PHONETIC            => null,
        X_PERSON_LAST_NAME_PHONETIC             => null,
        X_LANGUAGE_NAME                         => NULL,
        X_CATEGORY_CODE                         => l_party_rec.category_code,
        X_SALUTATION                            => l_party_rec.salutation,
        X_KNOWN_AS2                             => null,
        X_KNOWN_AS3                             => null,
        X_KNOWN_AS4                             => null,
        X_KNOWN_AS5                             => null,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_DUNS_NUMBER_C                         => null,
        X_CREATED_BY_MODULE                     => p_relationship_rec.created_by_module,
        X_APPLICATION_ID                        => p_relationship_rec.application_id
    );

/*
    per HLD,mosr record should not be created for copy case, since old osr is still active
    hz_orig_system_ref_pvt.create_mosr_for_merge(
                                        FND_API.G_FALSE,
                                        'HZ_PARTIES',
                                        l_party_rec.party_id,
                                        x_return_status,
                                        l_msg_count,
                                        l_msg_data);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
   END IF;
*/
    x_party_id := l_party_rec.party_id;
    x_party_number := l_party_rec.party_number;

        -- update the party_name
    l_party_name := SUBSTRB(l_subject_name || '-' ||
                                l_object_name  || '-' ||
                                x_party_number, 1, 360);

    UPDATE hz_parties SET PARTY_NAME = l_party_name WHERE PARTY_ID = x_party_id;

END do_create_party;

PROCEDURE do_update_party_flags(
    p_relationship_rec      IN      HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
    p_party_id              IN      NUMBER
) IS

    l_party_id                      NUMBER;
    l_reference_use_flag            VARCHAR2(1) := 'N';
    l_third_party_flag              VARCHAR2(1) := 'N';
    l_competitor_flag               VARCHAR2(1) := 'N';
    l_end_date                      DATE := p_relationship_rec.end_date;
    l_status                        VARCHAR2(1) := p_relationship_rec.status;
    l_record_locked                 VARCHAR2(1) := 'N';

BEGIN

    --check if party record is locked by any one else.
    BEGIN
        SELECT party_id INTO l_party_id
        FROM hz_parties
        WHERE party_id = p_party_id
        FOR UPDATE NOWAIT;
    EXCEPTION WHEN OTHERS THEN
     l_record_locked := 'Y';
    END;

     IF l_end_date IS NULL
       OR l_end_date = FND_API.G_MISS_DATE
    THEN
        l_end_date := to_date('31-12-4712', 'DD-MM-YYYY');
    ELSIF l_end_date = sysdate THEN
        l_end_date := sysdate-1;
    END IF;

    IF l_status IS NULL
       OR l_status = FND_API.G_MISS_CHAR
    THEN
       l_status := 'A';
    END IF;

    IF p_relationship_rec.relationship_code = 'COMPETITOR_OF' THEN
        IF l_status = 'A'
           AND
           (SYSDATE BETWEEN p_relationship_rec.start_date AND l_end_date)
        THEN
            l_competitor_flag := 'Y';
        END IF;

        UPDATE HZ_PARTIES
        SET    COMPETITOR_FLAG         = l_competitor_flag
        WHERE  PARTY_ID = p_party_id;

   ELSIF p_relationship_rec.relationship_code = 'REFERENCE_FOR' THEN
        IF l_status = 'A'
           AND
           (SYSDATE BETWEEN p_relationship_rec.start_date AND l_end_date)
        THEN
            l_reference_use_flag := 'Y';
        END IF;

        UPDATE HZ_PARTIES
        SET    REFERENCE_USE_FLAG    = l_reference_use_flag
        WHERE  PARTY_ID = p_party_id;

    ELSIF p_relationship_rec.relationship_code = 'PARTNER_OF' THEN
        IF l_status = 'A'
           AND (SYSDATE BETWEEN p_relationship_rec.start_date AND l_end_date)
        THEN
            l_third_party_flag := 'Y';
        END IF;

        UPDATE HZ_PARTIES
        SET    THIRD_PARTY_FLAG      = l_third_party_flag
        WHERE  PARTY_ID = p_party_id;

    END IF;

END do_update_party_flags;




PROCEDURE create_relationship (
    p_init_msg_list              IN    VARCHAR2:= FND_API.G_FALSE,
    p_relationship_rec           IN    HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
    p_direction_code             IN    VARCHAR2,
    x_relationship_id            OUT   NOCOPY NUMBER,
    x_party_id                   OUT   NOCOPY NUMBER,
    x_party_number               OUT   NOCOPY VARCHAR2,
    x_return_status              OUT   NOCOPY VARCHAR2,
    x_msg_count                  OUT   NOCOPY NUMBER,
    x_msg_data                   OUT   NOCOPY VARCHAR2
) IS

    l_rel_rec        HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE := p_relationship_rec;
    l_created_party  VARCHAR2(1);

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_relationship;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.

    IF g_rel_mixnmatch_enabled IS NULL THEN
      HZ_MIXNM_UTILITY.LoadDataSources(
        p_entity_name                    => 'HZ_RELATIONSHIPS',
        p_entity_attr_id                 => g_rel_entity_attr_id,
        p_mixnmatch_enabled              => g_rel_mixnmatch_enabled,
        p_selected_datasources           => g_rel_selected_datasources );
    END IF;
*/
    HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation (
      p_entity_name                    => 'HZ_RELATIONSHIPS',
      p_entity_attr_id                 => g_rel_entity_attr_id,
      p_mixnmatch_enabled              => g_rel_mixnmatch_enabled,
      p_selected_datasources           => g_rel_selected_datasources,
      p_content_source_type            => l_rel_rec.content_source_type,
      p_actual_content_source          => l_rel_rec.actual_content_source,
      x_is_datasource_selected         => g_rel_is_datasource_selected,
      x_return_status                  => x_return_status );


    -- Call to business logic.
    do_create_rel(
                  l_rel_rec,
                  p_direction_code,
                  l_created_party,
                  x_relationship_id,
                  x_party_id,
                  x_party_number,
                  x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
    HZ_BUSINESS_EVENT_V2PVT.create_relationship_event (
        l_rel_rec,
        l_created_party );
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_relationship;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_relationship;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_relationship;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
        fnd_message.set_token('ERROR' ,SQLERRM);
        fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END create_relationship;

PROCEDURE get_relationship_rec (
    p_init_msg_list               IN     VARCHAR2 := FND_API.G_FALSE,
    p_relationship_id             IN     NUMBER,
    p_directional_flag            IN     VARCHAR2 := 'F',
    x_rel_rec                     OUT    NOCOPY HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
    x_direction_code              OUT    NOCOPY VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    l_party_id                                       NUMBER;
    l_directional_flag                               VARCHAR2(1);
    l_direction_code                               VARCHAR2(255);

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_relationship_id IS NULL OR
       p_relationship_id = FND_API.G_MISS_NUM THEN
        fnd_message.set_name( 'AR', 'HZ_API_MISSING_COLUMN' );
        fnd_message.set_token( 'COLUMN', 'relationship_id' );
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_rel_rec.relationship_id := p_relationship_id;
    IF p_directional_flag <> 'F'
       AND
       p_directional_flag <> 'B'
    THEN
        l_directional_flag := 'F';
    ELSE
        l_directional_flag := NVL(p_directional_flag, 'F');
    END IF;

    HZ_RELATIONSHIPS_PKG.Select_Row (
        X_RELATIONSHIP_ID                       => x_rel_rec.relationship_id,
        X_DIRECTIONAL_FLAG                      => l_directional_flag,
        X_SUBJECT_ID                            => x_rel_rec.subject_id,
        X_SUBJECT_TYPE                          => x_rel_rec.subject_type,
        X_SUBJECT_TABLE_NAME                    => x_rel_rec.subject_table_name,
        X_OBJECT_ID                             => x_rel_rec.object_id,
        X_OBJECT_TYPE                           => x_rel_rec.object_type,
        X_OBJECT_TABLE_NAME                     => x_rel_rec.object_table_name,
        X_PARTY_ID                              => l_party_id,
        X_RELATIONSHIP_CODE                     => x_rel_rec.relationship_code,
        X_COMMENTS                              => x_rel_rec.comments,
        X_START_DATE                            => x_rel_rec.start_date,
        X_END_DATE                              => x_rel_rec.end_date,
        X_STATUS                                => x_rel_rec.status,
        X_ATTRIBUTE_CATEGORY                    => x_rel_rec.attribute_category,
        X_ATTRIBUTE1                            => x_rel_rec.attribute1,
        X_ATTRIBUTE2                            => x_rel_rec.attribute2,
        X_ATTRIBUTE3                            => x_rel_rec.attribute3,
        X_ATTRIBUTE4                            => x_rel_rec.attribute4,
        X_ATTRIBUTE5                            => x_rel_rec.attribute5,
        X_ATTRIBUTE6                            => x_rel_rec.attribute6,
        X_ATTRIBUTE7                            => x_rel_rec.attribute7,
        X_ATTRIBUTE8                            => x_rel_rec.attribute8,
        X_ATTRIBUTE9                            => x_rel_rec.attribute9,
        X_ATTRIBUTE10                           => x_rel_rec.attribute10,
        X_ATTRIBUTE11                           => x_rel_rec.attribute11,
        X_ATTRIBUTE12                           => x_rel_rec.attribute12,
        X_ATTRIBUTE13                           => x_rel_rec.attribute13,
        X_ATTRIBUTE14                           => x_rel_rec.attribute14,
        X_ATTRIBUTE15                           => x_rel_rec.attribute15,
        X_ATTRIBUTE16                           => x_rel_rec.attribute16,
        X_ATTRIBUTE17                           => x_rel_rec.attribute17,
        X_ATTRIBUTE18                           => x_rel_rec.attribute18,
        X_ATTRIBUTE19                           => x_rel_rec.attribute19,
        X_ATTRIBUTE20                           => x_rel_rec.attribute20,
        X_CONTENT_SOURCE_TYPE                   => x_rel_rec.content_source_type,
        X_RELATIONSHIP_TYPE                     => x_rel_rec.relationship_type,
        X_CREATED_BY_MODULE                     => x_rel_rec.created_by_module,
        X_APPLICATION_ID                        => x_rel_rec.application_id,
        X_ADDITIONAL_INFORMATION1               => x_rel_rec.additional_information1,
        X_ADDITIONAL_INFORMATION2               => x_rel_rec.additional_information2,
        X_ADDITIONAL_INFORMATION3               => x_rel_rec.additional_information3,
        X_ADDITIONAL_INFORMATION4               => x_rel_rec.additional_information4,
        X_ADDITIONAL_INFORMATION5               => x_rel_rec.additional_information5,
        X_ADDITIONAL_INFORMATION6               => x_rel_rec.additional_information6,
        X_ADDITIONAL_INFORMATION7               => x_rel_rec.additional_information7,
        X_ADDITIONAL_INFORMATION8               => x_rel_rec.additional_information8,
        X_ADDITIONAL_INFORMATION9               => x_rel_rec.additional_information9,
        X_ADDITIONAL_INFORMATION10               => x_rel_rec.additional_information10,
        X_ADDITIONAL_INFORMATION11               => x_rel_rec.additional_information11,
        X_ADDITIONAL_INFORMATION12               => x_rel_rec.additional_information12,
        X_ADDITIONAL_INFORMATION13               => x_rel_rec.additional_information13,
        X_ADDITIONAL_INFORMATION14               => x_rel_rec.additional_information14,
        X_ADDITIONAL_INFORMATION15               => x_rel_rec.additional_information15,
        X_ADDITIONAL_INFORMATION16               => x_rel_rec.additional_information16,
        X_ADDITIONAL_INFORMATION17               => x_rel_rec.additional_information17,
        X_ADDITIONAL_INFORMATION18               => x_rel_rec.additional_information18,
        X_ADDITIONAL_INFORMATION19               => x_rel_rec.additional_information19,
        X_ADDITIONAL_INFORMATION20               => x_rel_rec.additional_information20,
        X_ADDITIONAL_INFORMATION21               => x_rel_rec.additional_information21,
        X_ADDITIONAL_INFORMATION22               => x_rel_rec.additional_information22,
        X_ADDITIONAL_INFORMATION23               => x_rel_rec.additional_information23,
        x_ADDITIONAL_INFORMATION24               => x_rel_rec.additional_information24,
        X_ADDITIONAL_INFORMATION25               => x_rel_rec.additional_information25,
        X_ADDITIONAL_INFORMATION26               => x_rel_rec.additional_information26,
        X_ADDITIONAL_INFORMATION27               => x_rel_rec.additional_information27,
        X_ADDITIONAL_INFORMATION28               => x_rel_rec.additional_information28,
        X_ADDITIONAL_INFORMATION29               => x_rel_rec.additional_information29,
        X_ADDITIONAL_INFORMATION30               => x_rel_rec.additional_information30,
        X_DIRECTION_CODE                         => x_direction_code,
        X_PERCENTAGE_OWNERSHIP                   => x_rel_rec.percentage_ownership,
        X_ACTUAL_CONTENT_SOURCE              => x_rel_rec.ACTUAL_CONTENT_SOURCE

    );

    IF l_party_id IS NOT NULL
       AND
       l_party_id <> FND_API.G_MISS_NUM
    THEN
        get_party_rec (
                p_party_id                         => l_party_id,
                x_party_rec                        => x_rel_rec.party_rec,
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

        fnd_message.set_name( 'AR', 'HZ_API_OTHERS_EXCEP' );
        fnd_message.set_token( 'ERROR' ,SQLERRM );
        fnd_msg_pub.add;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );


END get_relationship_rec;

--------------------PARTY_CONTACT--------------------------------------------

------------------------------------
-- declaration of private procedures
------------------------------------


PROCEDURE do_create_org_contact(
    p_org_contact_rec      IN OUT  NOCOPY HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE,
    p_direction_code       IN      VARCHAR2,
    x_return_status        IN OUT  NOCOPY VARCHAR2,
    x_org_contact_id       OUT     NOCOPY NUMBER,
    x_party_rel_id         OUT     NOCOPY NUMBER,
    x_party_id             OUT     NOCOPY NUMBER,
    x_party_number         OUT     NOCOPY VARCHAR2
) IS

    l_org_contact_id       NUMBER := p_org_contact_rec.org_contact_id;
    l_rowid                ROWID := NULL;
    l_count                NUMBER;
    l_gen_contact_number   VARCHAR2(1);
    l_contact_number       VARCHAR2(30) := p_org_contact_rec.contact_number;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_dummy                VARCHAR2(1);
    l_debug_prefix         VARCHAR2(30);
     l_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
BEGIN

--Initialize the created by module
p_org_contact_rec.created_by_module     := 'HZ_TCA_CUSTOMER_MERGE';
p_org_contact_rec.orig_system_reference := null;

---Set the contact_number to null so that it is generated
p_org_contact_rec.contact_number := null;
p_org_contact_rec.org_contact_id := null;

--- Retain the application ID of the org contact rec in party reln rec and party rec
p_org_contact_rec.party_rel_rec.application_id := p_org_contact_rec.application_id;

p_org_contact_rec.party_rel_rec.party_rec.party_number := null;

    --
    -- create party relationship.
    --
    create_relationship (
        p_relationship_rec            => p_org_contact_rec.party_rel_rec,
        p_direction_code              => p_direction_code,
        x_relationship_id             => x_party_rel_id,
        x_party_id                    => x_party_id,
        x_party_number                => x_party_number,
        x_return_status               => x_return_status,
        x_msg_count                   => l_msg_count,
        x_msg_data                    => l_msg_data
       );


    p_org_contact_rec.party_rel_rec.party_rec.party_id := x_party_id;
    p_org_contact_rec.party_rel_rec.party_rec.party_number := x_party_number;
    p_org_contact_rec.party_rel_rec.relationship_id := x_party_rel_id;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
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
        X_STATUS                                => p_org_contact_rec.party_rel_rec.status
    );
/*
     per HLD,mosr record should not be created for copy case, since old osr is still active
    hz_orig_system_ref_pvt.create_mosr_for_merge(
                                        FND_API.G_FALSE,
                                        'HZ_ORG_CONTACTS',
                                        p_org_contact_rec.org_contact_id,
                                        x_return_status,
                                        l_msg_count,
                                        l_msg_data);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
   END IF;
*/
   x_org_contact_id := p_org_contact_rec.org_contact_id;
END do_create_org_contact;

PROCEDURE create_org_contact (
    p_init_msg_list             IN     VARCHAR2:= FND_API.G_FALSE,
    p_org_contact_rec           IN     HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE,
    p_direction_code            IN     VARCHAR2,
    x_org_contact_id            OUT    NOCOPY NUMBER,
    x_party_rel_id              OUT    NOCOPY NUMBER,
    x_party_id                  OUT    NOCOPY NUMBER,
    x_party_number              OUT    NOCOPY VARCHAR2,
    x_return_status             OUT    NOCOPY VARCHAR2,
    x_msg_count                 OUT    NOCOPY NUMBER,
    x_msg_data                  OUT    NOCOPY VARCHAR2
) IS

    l_api_name              CONSTANT   VARCHAR2(30) := 'create_org_contact';
    l_api_version           CONSTANT   NUMBER       := 1.0;
    l_org_contact_rec       HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE := p_org_contact_rec;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_org_contact;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_org_contact(
                          l_org_contact_rec,
                          p_direction_code,
                          x_return_status,
                          x_org_contact_id,
                          x_party_rel_id,
                          x_party_id,
                          x_party_number
                         );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
    HZ_BUSINESS_EVENT_V2PVT.create_org_contact_event (
        l_org_contact_rec );
   END IF;

    -- Call to indicate Org Contact creation to DQM
    HZ_DQM_SYNC.sync_contact(l_org_contact_rec.org_contact_id, 'C');

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_org_contact;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_org_contact;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);


    WHEN OTHERS THEN
        ROLLBACK TO create_org_contact;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
        fnd_message.set_token('ERROR' ,SQLERRM);
        fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

END create_org_contact;


PROCEDURE get_org_contact_rec (
    p_init_msg_list               IN     VARCHAR2 := FND_API.G_FALSE,
    p_org_contact_id              IN     NUMBER,
    x_org_contact_rec             OUT    NOCOPY HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE,
    x_direction_code              OUT    NOCOPY VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    l_api_name                    CONSTANT VARCHAR2(30) := 'get_org_contact_rec';
    l_api_version                 CONSTANT NUMBER := 1.0;
    l_party_relationship_id       NUMBER;

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
        fnd_message.set_name( 'AR', 'HZ_API_MISSING_COLUMN' );
        fnd_message.set_token( 'COLUMN', 'org_contact_id' );
        fnd_msg_pub.add;
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


   IF l_party_relationship_id IS NOT NULL
       AND
       l_party_relationship_id <> FND_API.G_MISS_NUM
    THEN
        get_relationship_rec (
                p_relationship_id                  => l_party_relationship_id,
                p_directional_flag                 => 'F',
                x_rel_rec                          => x_org_contact_rec.party_rel_rec,
                x_direction_code                   => x_direction_code,
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
        fnd_message.set_name( 'AR', 'HZ_API_OTHERS_EXCEP' );
        fnd_message.set_token( 'ERROR' ,SQLERRM );
        fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_org_contact_rec;

--------------------PARTY_SITE--------------------------------------------------

--------------------------------------------------
-- declaration of private procedures and functions
--------------------------------------------------


PROCEDURE do_create_party_site (
    p_party_site_rec     IN OUT  NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
    p_actual_cont_source IN VARCHAR2,
    x_party_site_id      OUT     NOCOPY NUMBER,
    x_party_site_number  OUT     NOCOPY VARCHAR2,
    x_return_status      IN OUT  NOCOPY VARCHAR2
);

PROCEDURE do_update_address(
    p_party_id                      IN      NUMBER,
    p_location_id                   IN      NUMBER
);

PROCEDURE do_unmark_address_flag(
    p_party_id                      IN     NUMBER,
    p_party_site_id                 IN     NUMBER := NULL
);


-----------------------------
-- body of private procedures
-----------------------------


PROCEDURE do_create_party_site(
    p_party_site_rec     IN OUT  NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
    p_actual_cont_source IN       VARCHAR2,
    x_party_site_id      OUT     NOCOPY NUMBER,
    x_party_site_number  OUT     NOCOPY VARCHAR2,
    x_return_status      IN OUT  NOCOPY VARCHAR2
) IS

    l_party_site_id                 NUMBER := p_party_site_rec.party_site_id;
    l_party_site_number    VARCHAR2(30) :=  p_party_site_rec.party_site_number;
    l_gen_party_site_number VARCHAR2(1);
    l_rowid                 ROWID        := NULL;
    l_count                 NUMBER;
    l_exist                 VARCHAR2(1)  := 'N';
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_dummy                       VARCHAR2(1);
    l_debug_prefix                VARCHAR2(30) := '';

     -- Bug 2197181
    l_loc_actual_content_source      hz_locations.actual_content_source%TYPE;
    l_orig_sys_reference_rec HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
BEGIN

  --Initialize the created by module
   p_party_site_rec.created_by_module     := 'HZ_TCA_CUSTOMER_MERGE';

   p_party_site_rec.orig_system_reference := null;
   p_party_site_rec.party_site_number := null;
   p_party_site_rec.party_site_id := null;

   -- Bug 2197181
   select actual_content_source
   into l_loc_actual_content_source
   from hz_locations
   where location_id = p_party_site_rec.location_id;

/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    g_pst_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_pst_selected_datasources,
        p_actual_content_source          => l_loc_actual_content_source );
*/
     -- if this is the first active, visible party site,
     -- we need to  mark it with identifying flag = 'Y'.

    BEGIN
        -- Bug 2197181: Added the checking if the party site is visible
        -- or not. The identifying address should be visible.

        -- SSM SST Integration and Extension
        -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
        -- There is no need to check if the data-source is selected.

        SELECT 'Y' INTO l_dummy
        FROM HZ_PARTY_SITES
        WHERE PARTY_ID = p_party_site_rec.party_id
        AND STATUS = 'A'
     /*   AND HZ_MIXNM_UTILITY.isDataSourceSelected (
              g_pst_selected_datasources, actual_content_source ) = 'Y'*/
        AND ROWNUM = 1;

        -- no exception raise, means 'a primary party site exist'
        -- if the current party site is to be identifying, then unmark
        -- the previous party sites with identifying flag = 'Y'.

        -- Bug 2197181: added for mix-n-match project: the identifying_flag
        -- can be set to 'Y' only if the party site will be visible. If it
        -- is not visible, the flag must be reset to 'N'.

        -- SSM SST Integration and Extension
        -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
        -- There is no need to check if the data-source is selected.

        IF p_party_site_rec.identifying_address_flag = 'Y' /*AND
           g_pst_is_datasource_selected = 'Y'*/
        THEN
          do_unmark_address_flag(p_party_site_rec.party_id);
        ELSE
          p_party_site_rec.identifying_address_flag := 'N';
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- this is the first visible, active address, so this will be
            -- set as identifying address.

            -- Bug 2197181: added for mix-n-match project: the identifying_flag
            -- can be set to 'Y' only if the party site will be visible. If it i
            -- not visible, the flag must be reset to 'N'.

            -- SSM SST Integration and Extension
            -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
            -- There is no need to check if the data-source is selected.

            IF (NVL(p_party_site_rec.status, 'A') = 'A' OR
                p_party_site_rec.status = FND_API.G_MISS_CHAR)/* AND
               g_pst_is_datasource_selected = 'Y'*/
            THEN
              p_party_site_rec.identifying_address_flag := 'Y';
            ELSE
              p_party_site_rec.identifying_address_flag := 'N';
            END IF;
    END;

    --denormalize primary address
    IF p_party_site_rec.identifying_address_flag = 'Y' THEN
        IF p_party_site_rec.party_id <> -1 THEN
            do_update_address(
                              p_party_site_rec.party_id,
                              p_party_site_rec.location_id);
        END IF;

    END IF;


    p_party_site_rec.party_site_id := l_party_site_id;
    p_party_site_rec.party_site_number := l_party_site_number;

   -- this is for orig_system_defaulting
    IF p_party_site_rec.party_site_id = FND_API.G_MISS_NUM THEN
        p_party_site_rec.party_site_id := NULL;
    END IF;


    -- call table-handler.
    HZ_PARTY_SITES_PKG.Insert_Row (
        X_PARTY_SITE_ID             => p_party_site_rec.party_site_id,
        X_PARTY_ID                  => p_party_site_rec.party_id,
        X_LOCATION_ID               => p_party_site_rec.location_id,
        X_PARTY_SITE_NUMBER         => p_party_site_rec.party_site_number,
        X_ATTRIBUTE_CATEGORY        => p_party_site_rec.attribute_category,
        X_ATTRIBUTE1                => p_party_site_rec.attribute1,
        X_ATTRIBUTE2                => p_party_site_rec.attribute2,
        X_ATTRIBUTE3                => p_party_site_rec.attribute3,
        X_ATTRIBUTE4                => p_party_site_rec.attribute4,
        X_ATTRIBUTE5                => p_party_site_rec.attribute5,
        X_ATTRIBUTE6                => p_party_site_rec.attribute6,
        X_ATTRIBUTE7                => p_party_site_rec.attribute7,
        X_ATTRIBUTE8                => p_party_site_rec.attribute8,
        X_ATTRIBUTE9                => p_party_site_rec.attribute9,
        X_ATTRIBUTE10               => p_party_site_rec.attribute10,
        X_ATTRIBUTE11               => p_party_site_rec.attribute11,
        X_ATTRIBUTE12               => p_party_site_rec.attribute12,
        X_ATTRIBUTE13               => p_party_site_rec.attribute13,
        X_ATTRIBUTE14               => p_party_site_rec.attribute14,
        X_ATTRIBUTE15               => p_party_site_rec.attribute15,
        X_ATTRIBUTE16               => p_party_site_rec.attribute16,
        X_ATTRIBUTE17               => p_party_site_rec.attribute17,
        X_ATTRIBUTE18               => p_party_site_rec.attribute18,
        X_ATTRIBUTE19               => p_party_site_rec.attribute19,
        X_ATTRIBUTE20               => p_party_site_rec.attribute20,
        X_ORIG_SYSTEM_REFERENCE    => p_party_site_rec.orig_system_reference,
        X_LANGUAGE                  => p_party_site_rec.language,
        X_MAILSTOP                  => p_party_site_rec.mailstop,
        X_IDENTIFYING_ADDRESS_FLAG => p_party_site_rec.identifying_address_flag,
        X_STATUS                    => p_party_site_rec.status,
        X_PARTY_SITE_NAME           => p_party_site_rec.party_site_name,
        X_ADDRESSEE                 => p_party_site_rec.addressee,
        X_OBJECT_VERSION_NUMBER     => 1,
        X_CREATED_BY_MODULE         => p_party_site_rec.created_by_module,
        X_APPLICATION_ID            => p_party_site_rec.application_id,
        X_ACTUAL_CONTENT_SOURCE     => p_actual_cont_source,
        X_GLOBAL_LOCATION_NUMBER    => p_party_site_rec.global_location_number,
        X_DUNS_NUMBER_C             => p_party_site_rec.duns_number_c
    );
/*
 per HLD,mosr record should not be created for copy case, since old osr is still active
    hz_orig_system_ref_pvt.create_mosr_for_merge(
                                        FND_API.G_FALSE,
                                        'HZ_PARTY_SITES',
                                    p_party_site_rec.party_site_id,
                                        x_return_status,
                                        l_msg_count,
                                        l_msg_data);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
   END IF;
*/
    x_party_site_id := p_party_site_rec.party_site_id;
    x_party_site_number := p_party_site_rec.party_site_number;


END do_create_party_site;

procedure do_update_address(
    p_party_id                    IN    NUMBER,
    p_location_id                 IN    NUMBER
) IS

      CURSOR c_loc IS
      SELECT * FROM hz_locations
      WHERE location_id = p_location_id;

    CURSOR c_party IS
      SELECT 'Y'
      FROM hz_parties
      WHERE party_id = p_party_id
      FOR UPDATE NOWAIT;

    l_location_rec                  c_loc%ROWTYPE;
    l_exists                        VARCHAR2(1);
    l_do_not_normalize              VARCHAR2(1):= 'N';

BEGIN

    --check if party record is locked by any one else.
    BEGIN
      OPEN c_party;
      FETCH c_party INTO l_exists;
      CLOSE c_party;
    EXCEPTION
      WHEN OTHERS THEN
      l_do_not_normalize := 'Y';
    END;


    -- if location_id is null, we will null out the location
    -- components in hz_parties.

    IF p_location_id IS NULL THEN
      l_location_rec.country     := NULL;
      l_location_rec.address1    := NULL;
      l_location_rec.address2    := NULL;
      l_location_rec.address3    := NULL;
      l_location_rec.address4    := NULL;
      l_location_rec.city        := NULL;
      l_location_rec.postal_code := NULL;
      l_location_rec.state       := NULL;
      l_location_rec.province    := NULL;
      l_location_rec.county      := NULL;
   ELSE
      --Open the cursor and fetch location components and
      --content_source_type.

      OPEN c_loc;
      FETCH c_loc INTO l_location_rec;
      CLOSE c_loc;
    END IF;

    if l_do_not_normalize <>  'Y' then

      UPDATE hz_parties
      SET    country     = l_location_rec.country,
           address1    = l_location_rec.address1,
           address2    = l_location_rec.address2,
           address3    = l_location_rec.address3,
           address4    = l_location_rec.address4,
           city        = l_location_rec.city,
           postal_code = l_location_rec.postal_code,
           state       = l_location_rec.state,
           province    = l_location_rec.province,
           county      = l_location_rec.county
      WHERE party_id = p_party_id;

  end if;


END do_update_address;

PROCEDURE do_unmark_address_flag(
    p_party_id                      IN     NUMBER,
    p_party_site_id                 IN     NUMBER := NULL
) IS

    CURSOR c_party_sites IS
      SELECT rowid
      FROM hz_party_sites
      WHERE party_id = p_party_id
      AND party_site_id <> nvl(p_party_site_id,-999)
      AND identifying_address_flag = 'Y'
      AND rownum = 1
      FOR UPDATE NOWAIT;

    l_rowid                    VARCHAR2(100);
    l_record_locked            VARCHAR2(1) := 'N';

BEGIN

    --check if party record is locked by any one else.
    BEGIN
      OPEN c_party_sites;
      FETCH c_party_sites INTO l_rowid;
      CLOSE c_party_sites;
    EXCEPTION
      WHEN OTHERS THEN
      l_record_locked := 'Y';
    END;

    IF l_rowid IS NOT NULL AND l_record_locked <> 'Y' THEN
      UPDATE hz_party_sites
      SET identifying_address_flag = 'N'
      WHERE rowid = l_rowid;
    END IF;

END do_unmark_address_flag;



----------------------------
-- body of public procedures
----------------------------

PROCEDURE create_party_site (
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_party_site_rec        IN      HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
    p_actual_cont_source    IN      VARCHAR2,
    x_party_site_id         OUT     NOCOPY NUMBER,
    x_party_site_number     OUT     NOCOPY VARCHAR2,
    x_return_status         OUT     NOCOPY VARCHAR2,
    x_msg_count             OUT     NOCOPY NUMBER,
    x_msg_data              OUT     NOCOPY VARCHAR2
) IS

    l_api_name             CONSTANT VARCHAR2(30) := 'create_party_site';
    l_api_version          CONSTANT NUMBER       := 1.0;
    l_party_site_rec       HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE := p_party_site_rec;

BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_party_site;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity.
/*
    IF g_pst_mixnmatch_enabled IS NULL THEN
      HZ_MIXNM_UTILITY.LoadDataSources(
        p_entity_name                    => 'HZ_LOCATIONS',
        p_entity_attr_id                 => g_pst_entity_attr_id,
        p_mixnmatch_enabled              => g_pst_mixnmatch_enabled,
        p_selected_datasources           => g_pst_selected_datasources );
    END IF;
*/
    -- call to business logic.
    do_create_party_site(
                         l_party_site_rec,
                         p_actual_cont_source,
                         x_party_site_id,
                         x_party_site_number,
                         x_return_status
                        );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
    HZ_BUSINESS_EVENT_V2PVT.create_party_site_event (
        l_party_site_rec );
   END IF;

    -- Call to indicate Party Site creation to DQM
    HZ_DQM_SYNC.sync_party_site(l_party_site_rec.party_site_id,'C');

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_party_site;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_party_site;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO create_party_site;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
        fnd_message.set_token('ERROR' ,SQLERRM);
        fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

END create_party_site;


PROCEDURE get_party_site_rec (
    p_init_msg_list               IN     VARCHAR2 := FND_API.G_FALSE,
    p_party_site_id               IN     NUMBER,
    x_party_site_rec              OUT    NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
    x_actual_cont_source          OUT    NOCOPY VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2

) IS

    l_api_name                    CONSTANT VARCHAR2(30) := 'get_party_site_rec';
    l_api_version                 CONSTANT NUMBER := 1.0;

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_party_site_id IS NULL OR
       p_party_site_id = FND_API.G_MISS_NUM THEN
        fnd_message.set_name( 'AR', 'HZ_API_MISSING_COLUMN' );
        fnd_message.set_token( 'COLUMN', 'party_site_id' );
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_party_site_rec.party_site_id := p_party_site_id;

    HZ_PARTY_SITES_PKG.Select_Row (
        X_PARTY_SITE_ID                         => x_party_site_rec.party_site_id,
        X_PARTY_ID                              => x_party_site_rec.party_id,
        X_LOCATION_ID                           => x_party_site_rec.location_id,
        X_PARTY_SITE_NUMBER                     => x_party_site_rec.party_site_number,
        X_ATTRIBUTE_CATEGORY                    => x_party_site_rec.attribute_category,
        X_ATTRIBUTE1                            => x_party_site_rec.attribute1,
        X_ATTRIBUTE2                            => x_party_site_rec.attribute2,
        X_ATTRIBUTE3                            => x_party_site_rec.attribute3,
        X_ATTRIBUTE4                            => x_party_site_rec.attribute4,
        X_ATTRIBUTE5                            => x_party_site_rec.attribute5,
        X_ATTRIBUTE6                            => x_party_site_rec.attribute6,
        X_ATTRIBUTE7                            => x_party_site_rec.attribute7,
        X_ATTRIBUTE8                            => x_party_site_rec.attribute8,
        X_ATTRIBUTE9                            => x_party_site_rec.attribute9,
        X_ATTRIBUTE10                           => x_party_site_rec.attribute10,
        X_ATTRIBUTE11                           => x_party_site_rec.attribute11,
        X_ATTRIBUTE12                           => x_party_site_rec.attribute12,
        X_ATTRIBUTE13                           => x_party_site_rec.attribute13,
        X_ATTRIBUTE14                           => x_party_site_rec.attribute14,
        X_ATTRIBUTE15                           => x_party_site_rec.attribute15,
        X_ATTRIBUTE16                           => x_party_site_rec.attribute16,
        X_ATTRIBUTE17                           => x_party_site_rec.attribute17,
        X_ATTRIBUTE18                           => x_party_site_rec.attribute18,
        X_ATTRIBUTE19                           => x_party_site_rec.attribute19,
        X_ATTRIBUTE20                           => x_party_site_rec.attribute20,
        X_ORIG_SYSTEM_REFERENCE                 => x_party_site_rec.orig_system_reference,
        X_LANGUAGE                              => x_party_site_rec.language,
        X_MAILSTOP                              => x_party_site_rec.mailstop,
        X_IDENTIFYING_ADDRESS_FLAG              => x_party_site_rec.identifying_address_flag,
        X_STATUS                                => x_party_site_rec.status,
        X_PARTY_SITE_NAME                       => x_party_site_rec.party_site_name,
        X_ADDRESSEE                             => x_party_site_rec.addressee,
        X_CREATED_BY_MODULE                     => x_party_site_rec.created_by_module,
        X_APPLICATION_ID                        => x_party_site_rec.application_id,
        X_ACTUAL_CONTENT_SOURCE                 => x_actual_cont_source,
        X_GLOBAL_LOCATION_NUMBER                => x_party_site_rec.global_location_number,
        X_DUNS_NUMBER_C                         => x_party_site_rec.duns_number_c
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
        fnd_message.set_name( 'AR', 'HZ_API_OTHERS_EXCEP' );
        fnd_message.set_token( 'ERROR' ,SQLERRM );
        fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_party_site_rec;

------------------ACCOUNT_SITE_-----------------------------------------------

PROCEDURE do_create_cust_acct_site (
    p_cust_acct_site_rec IN OUT NOCOPY
                         HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE,
    p_org_id             IN     NUMBER DEFAULT null,
    x_cust_acct_site_id  OUT    NOCOPY NUMBER,
    x_return_status      IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_create_cust_site_use (
    p_cust_site_use_rec      IN OUT NOCOPY HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE,
    p_customer_profile_rec   IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile         IN     VARCHAR2 := FND_API.G_TRUE,
    p_create_profile_amt     IN     VARCHAR2 := FND_API.G_TRUE,
    p_org_id                 IN     NUMBER DEFAULT null,
    x_site_use_id            OUT    NOCOPY NUMBER,
    x_return_status          IN OUT NOCOPY VARCHAR2
);

PROCEDURE denormalize_site_use_flag (
    p_cust_acct_site_id      IN     NUMBER,
    p_site_use_code          IN     VARCHAR2,
    p_flag                   IN     VARCHAR2
);

--------------------------------------
-- private procedures and functions
--------------------------------------


PROCEDURE do_create_cust_acct_site (
    p_cust_acct_site_rec  IN OUT NOCOPY
                          HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE,
    p_org_id              IN     NUMBER DEFAULT null,
    x_cust_acct_site_id   OUT    NOCOPY NUMBER,
    x_return_status       IN OUT NOCOPY VARCHAR2
) IS

    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);

    l_location_id    NUMBER;
    l_loc_id         NUMBER;
    l_orig_sys_reference_rec    HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

BEGIN

   --Initialize the created by module
   p_cust_acct_site_rec.created_by_module     := 'HZ_TCA_CUSTOMER_MERGE';

   p_cust_acct_site_rec.orig_system_reference := null;
   p_cust_acct_site_rec.cust_acct_site_id := null;


    -- Call table-handler.
    HZ_CUST_ACCT_SITES_PKG.Insert_Row (
     X_CUST_ACCT_SITE_ID    => p_cust_acct_site_rec.cust_acct_site_id,
     X_CUST_ACCOUNT_ID      => p_cust_acct_site_rec.cust_account_id,
     X_PARTY_SITE_ID        => p_cust_acct_site_rec.party_site_id,
     X_ATTRIBUTE_CATEGORY   => p_cust_acct_site_rec.attribute_category,
     X_ATTRIBUTE1           => p_cust_acct_site_rec.attribute1,
     X_ATTRIBUTE2           => p_cust_acct_site_rec.attribute2,
     X_ATTRIBUTE3           => p_cust_acct_site_rec.attribute3,
     X_ATTRIBUTE4           => p_cust_acct_site_rec.attribute4,
     X_ATTRIBUTE5           => p_cust_acct_site_rec.attribute5,
     X_ATTRIBUTE6           => p_cust_acct_site_rec.attribute6,
     X_ATTRIBUTE7           => p_cust_acct_site_rec.attribute7,
     X_ATTRIBUTE8           => p_cust_acct_site_rec.attribute8,
     X_ATTRIBUTE9           => p_cust_acct_site_rec.attribute9,
     X_ATTRIBUTE10          => p_cust_acct_site_rec.attribute10,
     X_ATTRIBUTE11          => p_cust_acct_site_rec.attribute11,
     X_ATTRIBUTE12          => p_cust_acct_site_rec.attribute12,
     X_ATTRIBUTE13          => p_cust_acct_site_rec.attribute13,
     X_ATTRIBUTE14          => p_cust_acct_site_rec.attribute14,
     X_ATTRIBUTE15          => p_cust_acct_site_rec.attribute15,
     X_ATTRIBUTE16          => p_cust_acct_site_rec.attribute16,
     X_ATTRIBUTE17          => p_cust_acct_site_rec.attribute17,
     X_ATTRIBUTE18          => p_cust_acct_site_rec.attribute18,
     X_ATTRIBUTE19          => p_cust_acct_site_rec.attribute19,
     X_ATTRIBUTE20          => p_cust_acct_site_rec.attribute20,
     X_GLOBAL_ATTRIBUTE_CATEGORY=>p_cust_acct_site_rec.global_attribute_category,
     X_GLOBAL_ATTRIBUTE1    => p_cust_acct_site_rec.global_attribute1,
     X_GLOBAL_ATTRIBUTE2    => p_cust_acct_site_rec.global_attribute2,
     X_GLOBAL_ATTRIBUTE3    => p_cust_acct_site_rec.global_attribute3,
     X_GLOBAL_ATTRIBUTE4    => p_cust_acct_site_rec.global_attribute4,
     X_GLOBAL_ATTRIBUTE5    => p_cust_acct_site_rec.global_attribute5,
     X_GLOBAL_ATTRIBUTE6    => p_cust_acct_site_rec.global_attribute6,
     X_GLOBAL_ATTRIBUTE7    => p_cust_acct_site_rec.global_attribute7,
     X_GLOBAL_ATTRIBUTE8    => p_cust_acct_site_rec.global_attribute8,
     X_GLOBAL_ATTRIBUTE9    => p_cust_acct_site_rec.global_attribute9,
     X_GLOBAL_ATTRIBUTE10   => p_cust_acct_site_rec.global_attribute10,
     X_GLOBAL_ATTRIBUTE11   => p_cust_acct_site_rec.global_attribute11,
     X_GLOBAL_ATTRIBUTE12   => p_cust_acct_site_rec.global_attribute12,
     X_GLOBAL_ATTRIBUTE13   => p_cust_acct_site_rec.global_attribute13,
     X_GLOBAL_ATTRIBUTE14   => p_cust_acct_site_rec.global_attribute14,
     X_GLOBAL_ATTRIBUTE15   => p_cust_acct_site_rec.global_attribute15,
     X_GLOBAL_ATTRIBUTE16   => p_cust_acct_site_rec.global_attribute16,
     X_GLOBAL_ATTRIBUTE17   => p_cust_acct_site_rec.global_attribute17,
     X_GLOBAL_ATTRIBUTE18   => p_cust_acct_site_rec.global_attribute18,
     X_GLOBAL_ATTRIBUTE19   => p_cust_acct_site_rec.global_attribute19,
     X_GLOBAL_ATTRIBUTE20   => p_cust_acct_site_rec.global_attribute20,
     X_ORIG_SYSTEM_REFERENCE => p_cust_acct_site_rec.orig_system_reference,
     X_STATUS               => p_cust_acct_site_rec.status,
     X_CUSTOMER_CATEGORY_CODE => p_cust_acct_site_rec.customer_category_code,
     X_LANGUAGE             => p_cust_acct_site_rec.language,
     X_KEY_ACCOUNT_FLAG     => p_cust_acct_site_rec.key_account_flag,
     X_TP_HEADER_ID         => p_cust_acct_site_rec.tp_header_id,
     X_ECE_TP_LOCATION_CODE => p_cust_acct_site_rec.ece_tp_location_code,
     X_PRIMARY_SPECIALIST_ID=> p_cust_acct_site_rec.primary_specialist_id,
     X_SECONDARY_SPECIALIST_ID => p_cust_acct_site_rec.secondary_specialist_id,
     X_TERRITORY_ID         => p_cust_acct_site_rec.territory_id,
     X_TERRITORY            => p_cust_acct_site_rec.territory,
     X_TRANSLATED_CUSTOMER_NAME =>p_cust_acct_site_rec.translated_customer_name,
     X_OBJECT_VERSION_NUMBER  => 1,
     X_CREATED_BY_MODULE    => p_cust_acct_site_rec.created_by_module,
     X_APPLICATION_ID       => p_cust_acct_site_rec.application_id,
     X_ORG_ID               => p_org_id
    );
/*
     per HLD,mosr record should not be created for copy case, since old osr is still active
    hz_orig_system_ref_pvt.create_mosr_for_merge(
                                        FND_API.G_FALSE,
                                        'HZ_CUST_ACCT_SITES_ALL',
                                        p_cust_acct_site_rec.cust_acct_site_id,
                                        x_return_status,
                                        l_msg_count,
                                        l_msg_data);
   IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
   END IF;
*/
    x_cust_acct_site_id := p_cust_acct_site_rec.cust_acct_site_id;

END do_create_cust_acct_site;


PROCEDURE do_create_cust_site_use (
    p_cust_site_use_rec     IN OUT NOCOPY HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE,
    p_customer_profile_rec  IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile        IN     VARCHAR2 := FND_API.G_TRUE,
    p_create_profile_amt    IN     VARCHAR2 := FND_API.G_TRUE,
    p_org_id                IN     NUMBER DEFAULT null,
    x_site_use_id           OUT    NOCOPY NUMBER,
    x_return_status         IN OUT NOCOPY VARCHAR2
) IS


    l_dummy                       VARCHAR2(1);
    l_message_count               NUMBER;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_flag                        VARCHAR2(1);

    l_party_site_use_rec          HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
    l_party_site_id               NUMBER;
    l_party_site_use_id           NUMBER;
    l_cust_account_profile_id     NUMBER;
    l_bill_to_flag                HZ_CUST_ACCT_SITES_ALL.bill_to_flag%TYPE;
    l_ship_to_flag                HZ_CUST_ACCT_SITES_ALL.ship_to_flag%TYPE;
    l_market_flag                 HZ_CUST_ACCT_SITES_ALL.market_flag%TYPE;

BEGIN

   p_cust_site_use_rec.created_by_module    := 'HZ_TCA_CUSTOMER_MERGE';
   p_cust_site_use_rec.site_use_id := null;
   p_cust_site_use_rec.orig_system_reference := null;


    -- Call table-handler.

    HZ_CUST_SITE_USES_PKG.Insert_Row (
     X_SITE_USE_ID                 => p_cust_site_use_rec.site_use_id,
     X_CUST_ACCT_SITE_ID           => p_cust_site_use_rec.cust_acct_site_id,
     X_SITE_USE_CODE               => p_cust_site_use_rec.site_use_code,
     X_PRIMARY_FLAG                => p_cust_site_use_rec.primary_flag,
     X_STATUS                      => p_cust_site_use_rec.status,
     X_LOCATION                    => p_cust_site_use_rec.location,
     X_CONTACT_ID                  => p_cust_site_use_rec.contact_id,
     X_BILL_TO_SITE_USE_ID         => p_cust_site_use_rec.bill_to_site_use_id,
     X_ORIG_SYSTEM_REFERENCE       => p_cust_site_use_rec.orig_system_reference,
     X_SIC_CODE                    => p_cust_site_use_rec.sic_code,
     X_PAYMENT_TERM_ID             => p_cust_site_use_rec.payment_term_id,
     X_GSA_INDICATOR               => p_cust_site_use_rec.gsa_indicator,
     X_SHIP_PARTIAL                => p_cust_site_use_rec.ship_partial,
     X_SHIP_VIA                    => p_cust_site_use_rec.ship_via,
     X_FOB_POINT                   => p_cust_site_use_rec.fob_point,
     X_ORDER_TYPE_ID               => p_cust_site_use_rec.order_type_id,
     X_PRICE_LIST_ID               => p_cust_site_use_rec.price_list_id,
     X_FREIGHT_TERM                => p_cust_site_use_rec.freight_term,
     X_WAREHOUSE_ID                => p_cust_site_use_rec.warehouse_id,
     X_TERRITORY_ID                => p_cust_site_use_rec.territory_id,
     X_ATTRIBUTE_CATEGORY          => p_cust_site_use_rec.attribute_category,
     X_ATTRIBUTE1                  => p_cust_site_use_rec.attribute1,
     X_ATTRIBUTE2                  => p_cust_site_use_rec.attribute2,
     X_ATTRIBUTE3                  => p_cust_site_use_rec.attribute3,
     X_ATTRIBUTE4                  => p_cust_site_use_rec.attribute4,
     X_ATTRIBUTE5                  => p_cust_site_use_rec.attribute5,
     X_ATTRIBUTE6                  => p_cust_site_use_rec.attribute6,
     X_ATTRIBUTE7                  => p_cust_site_use_rec.attribute7,
     X_ATTRIBUTE8                  => p_cust_site_use_rec.attribute8,
     X_ATTRIBUTE9                  => p_cust_site_use_rec.attribute9,
     X_ATTRIBUTE10                 => p_cust_site_use_rec.attribute10,
     X_TAX_REFERENCE               => p_cust_site_use_rec.tax_reference,
     X_SORT_PRIORITY               => p_cust_site_use_rec.sort_priority,
     X_TAX_CODE                    => p_cust_site_use_rec.tax_code,
     X_ATTRIBUTE11                 => p_cust_site_use_rec.attribute11,
     X_ATTRIBUTE12                 => p_cust_site_use_rec.attribute12,
     X_ATTRIBUTE13                 => p_cust_site_use_rec.attribute13,
     X_ATTRIBUTE14                 => p_cust_site_use_rec.attribute14,
     X_ATTRIBUTE15                 => p_cust_site_use_rec.attribute15,
     X_ATTRIBUTE16                 => p_cust_site_use_rec.attribute16,
     X_ATTRIBUTE17                 => p_cust_site_use_rec.attribute17,
     X_ATTRIBUTE18                 => p_cust_site_use_rec.attribute18,
     X_ATTRIBUTE19                 => p_cust_site_use_rec.attribute19,
     X_ATTRIBUTE20                 => p_cust_site_use_rec.attribute20,
     X_ATTRIBUTE21                 => p_cust_site_use_rec.attribute21,
     X_ATTRIBUTE22                 => p_cust_site_use_rec.attribute22,
     X_ATTRIBUTE23                 => p_cust_site_use_rec.attribute23,
     X_ATTRIBUTE24                 => p_cust_site_use_rec.attribute24,
     X_ATTRIBUTE25                 => p_cust_site_use_rec.attribute25,
     X_DEMAND_CLASS_CODE           => p_cust_site_use_rec.demand_class_code,
     X_TAX_HEADER_LEVEL_FLAG       => p_cust_site_use_rec.tax_header_level_flag,
     X_TAX_ROUNDING_RULE           => p_cust_site_use_rec.tax_rounding_rule,
     X_GLOBAL_ATTRIBUTE1           => p_cust_site_use_rec.global_attribute1,
     X_GLOBAL_ATTRIBUTE2           => p_cust_site_use_rec.global_attribute2,
     X_GLOBAL_ATTRIBUTE3           => p_cust_site_use_rec.global_attribute3,
     X_GLOBAL_ATTRIBUTE4           => p_cust_site_use_rec.global_attribute4,
     X_GLOBAL_ATTRIBUTE5           => p_cust_site_use_rec.global_attribute5,
     X_GLOBAL_ATTRIBUTE6           => p_cust_site_use_rec.global_attribute6,
     X_GLOBAL_ATTRIBUTE7           => p_cust_site_use_rec.global_attribute7,
     X_GLOBAL_ATTRIBUTE8           => p_cust_site_use_rec.global_attribute8,
     X_GLOBAL_ATTRIBUTE9           => p_cust_site_use_rec.global_attribute9,
     X_GLOBAL_ATTRIBUTE10          =>p_cust_site_use_rec.global_attribute10,
     X_GLOBAL_ATTRIBUTE11          => p_cust_site_use_rec.global_attribute11,
     X_GLOBAL_ATTRIBUTE12          => p_cust_site_use_rec.global_attribute12,
     X_GLOBAL_ATTRIBUTE13          => p_cust_site_use_rec.global_attribute13,
     X_GLOBAL_ATTRIBUTE14          => p_cust_site_use_rec.global_attribute14,
     X_GLOBAL_ATTRIBUTE15          => p_cust_site_use_rec.global_attribute15,
     X_GLOBAL_ATTRIBUTE16          => p_cust_site_use_rec.global_attribute16,
     X_GLOBAL_ATTRIBUTE17          => p_cust_site_use_rec.global_attribute17,
     X_GLOBAL_ATTRIBUTE18          => p_cust_site_use_rec.global_attribute18,
     X_GLOBAL_ATTRIBUTE19          => p_cust_site_use_rec.global_attribute19,
     X_GLOBAL_ATTRIBUTE20          => p_cust_site_use_rec.global_attribute20,
     X_GLOBAL_ATTRIBUTE_CATEGORY=>p_cust_site_use_rec.global_attribute_category,
     X_PRIMARY_SALESREP_ID      => p_cust_site_use_rec.primary_salesrep_id,
   X_FINCHRG_RECEIVABLES_TRX_ID=>p_cust_site_use_rec.finchrg_receivables_trx_id,
     X_DATES_NEGATIVE_TOLERANCE=> p_cust_site_use_rec.dates_negative_tolerance,
     X_DATES_POSITIVE_TOLERANCE=> p_cust_site_use_rec.dates_positive_tolerance,
     X_DATE_TYPE_PREFERENCE        => p_cust_site_use_rec.date_type_preference,
     X_OVER_SHIPMENT_TOLERANCE => p_cust_site_use_rec.over_shipment_tolerance,
     X_UNDER_SHIPMENT_TOLERANCE=> p_cust_site_use_rec.under_shipment_tolerance,
     X_ITEM_CROSS_REF_PREF     => p_cust_site_use_rec.item_cross_ref_pref,
     X_OVER_RETURN_TOLERANCE   => p_cust_site_use_rec.over_return_tolerance,
     X_UNDER_RETURN_TOLERANCE  => p_cust_site_use_rec.under_return_tolerance,
   X_SHIP_SETS_INCLUDE_LINES_FLAG=>p_cust_site_use_rec.ship_sets_include_lines_flag,
     X_ARRIVALSETS_INCLUDE_LINES_FG=> p_cust_site_use_rec.arrivalsets_include_lines_flag,
     X_SCHED_DATE_PUSH_FLAG        => p_cust_site_use_rec.sched_date_push_flag,
     X_INVOICE_QUANTITY_RULE       => p_cust_site_use_rec.invoice_quantity_rule,
     X_PRICING_EVENT               => p_cust_site_use_rec.pricing_event,
     X_GL_ID_REC                   => p_cust_site_use_rec.gl_id_rec,
     X_GL_ID_REV                   => p_cust_site_use_rec.gl_id_rev,
     X_GL_ID_TAX                   => p_cust_site_use_rec.gl_id_tax,
     X_GL_ID_FREIGHT               => p_cust_site_use_rec.gl_id_freight,
     X_GL_ID_CLEARING              => p_cust_site_use_rec.gl_id_clearing,
     X_GL_ID_UNBILLED              => p_cust_site_use_rec.gl_id_unbilled,
     X_GL_ID_UNEARNED              => p_cust_site_use_rec.gl_id_unearned,
     X_GL_ID_UNPAID_REC            => p_cust_site_use_rec.gl_id_unpaid_rec,
     X_GL_ID_REMITTANCE            => p_cust_site_use_rec.gl_id_remittance,
     X_GL_ID_FACTOR                => p_cust_site_use_rec.gl_id_factor,
     X_TAX_CLASSIFICATION          => p_cust_site_use_rec.tax_classification,
     X_OBJECT_VERSION_NUMBER       => 1,
     X_CREATED_BY_MODULE           => p_cust_site_use_rec.created_by_module,
     X_APPLICATION_ID              => p_cust_site_use_rec.application_id,
     X_ORG_ID                      => p_org_id
    );

    -- If this is a active bill_to or ship_to or market,
    -- set the appropriate denormalized flag in hz_cust_acct_sites_all.

    IF p_cust_site_use_rec.site_use_code IN ('BILL_TO', 'SHIP_TO', 'MARKET' ) THEN
    ----Bug No.5211233
      IF p_cust_site_use_rec.primary_flag = 'Y' THEN
               l_flag := 'P';
    ----Bug No. 5211233

       ELSIF p_cust_site_use_rec.status = 'A' OR
          p_cust_site_use_rec.status IS NULL OR
          p_cust_site_use_rec.status = FND_API.G_MISS_CHAR
       THEN
              l_flag := 'Y';
       ELSE
          l_flag := NULL;
       END IF;

       denormalize_site_use_flag (
           p_cust_site_use_rec.cust_acct_site_id,
           p_cust_site_use_rec.site_use_code,
           l_flag );

    END IF;

    IF p_create_profile = FND_API.G_TRUE THEN

        -- Create the profile for the site use

        p_customer_profile_rec.site_use_id := p_cust_site_use_rec.site_use_id;
        p_customer_profile_rec.created_by_module := p_cust_site_use_rec.created_by_module;
        p_customer_profile_rec.application_id := p_cust_site_use_rec.application_id;

        SELECT CUST_ACCOUNT_ID INTO p_customer_profile_rec.cust_account_id
        FROM HZ_CUST_ACCT_SITES_ALL
        WHERE CUST_ACCT_SITE_ID = p_cust_site_use_rec.cust_acct_site_id;

        create_customer_profile (
            p_customer_profile_rec       => p_customer_profile_rec,
            p_create_profile_amt         => p_create_profile_amt,
            x_return_status              => x_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data,
            x_cust_account_profile_id    => l_cust_account_profile_id );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

    END IF;
/*
     per HLD,mosr record should not be created for copy case, since old osr is still active
    hz_orig_system_ref_pvt.create_mosr_for_merge(
                                        FND_API.G_FALSE,
                                        'HZ_CUST_SITE_USES_ALL',
                                        p_cust_site_use_rec.site_use_id,
                                        x_return_status,
                                        l_msg_count,
                                        l_msg_data);
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
   END IF;
*/
    x_site_use_id := p_cust_site_use_rec.site_use_id;

END do_create_cust_site_use;


PROCEDURE denormalize_site_use_flag (
    p_cust_acct_site_id                     IN     NUMBER,
    p_site_use_code                         IN     VARCHAR2,
    p_flag                                  IN     VARCHAR2
) IS

    l_debug_prefix                          VARCHAR2(30) := ''; --'denormalize_site_use_flag'

BEGIN


    IF p_site_use_code = 'BILL_TO' THEN
        UPDATE HZ_CUST_ACCT_SITES_ALL
        SET BILL_TO_FLAG = p_flag
        WHERE CUST_ACCT_SITE_ID = p_cust_acct_site_id;
    ELSIF p_site_use_code = 'SHIP_TO' THEN
        UPDATE HZ_CUST_ACCT_SITES_ALL
        SET SHIP_TO_FLAG = p_flag
        WHERE CUST_ACCT_SITE_ID = p_cust_acct_site_id;
    ELSIF p_site_use_code = 'MARKET' THEN
        UPDATE HZ_CUST_ACCT_SITES_ALL
        SET MARKET_FLAG = p_flag
        WHERE CUST_ACCT_SITE_ID = p_cust_acct_site_id;
    END IF;


END denormalize_site_use_flag;

--------------------------------------
-- public procedures and functions
--------------------------------------

PROCEDURE create_cust_acct_site (
    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
    p_cust_acct_site_rec IN HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE,
    p_org_id             IN NUMBER ,
    x_cust_acct_site_id  OUT    NOCOPY NUMBER,
    x_return_status      OUT    NOCOPY VARCHAR2,
    x_msg_count          OUT    NOCOPY NUMBER,
    x_msg_data           OUT    NOCOPY VARCHAR2
) IS

    l_cust_acct_site_rec  HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE :=
                          p_cust_acct_site_rec;

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_cust_acct_site;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_cust_acct_site (
        l_cust_acct_site_rec,
        p_org_id,
        x_cust_acct_site_id,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
    HZ_BUSINESS_EVENT_V2PVT.create_cust_acct_site_event (
        l_cust_acct_site_rec );
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_cust_acct_site;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_cust_acct_site;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        ROLLBACK TO create_cust_acct_site;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_message.set_name( 'AR', 'HZ_API_OTHERS_EXCEP' );
        fnd_message.set_token( 'ERROR' ,SQLERRM );
        fnd_msg_pub.add;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );


END create_cust_acct_site;

PROCEDURE create_cust_site_use (
    p_init_msg_list               IN     VARCHAR2 := FND_API.G_FALSE,
    p_cust_site_use_rec           IN     HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE,
    p_customer_profile_rec        IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile              IN     VARCHAR2 := FND_API.G_TRUE,
    p_create_profile_amt          IN     VARCHAR2 := FND_API.G_TRUE,
    p_org_id                      IN     NUMBER ,
    x_site_use_id                 OUT    NOCOPY NUMBER,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    l_cust_site_use_rec     HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE
                                                  := p_cust_site_use_rec;
    l_customer_profile_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE
                                                 := p_customer_profile_rec;

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_cust_site_use;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_cust_site_use (
        l_cust_site_use_rec,
        l_customer_profile_rec,
        p_create_profile,
        p_create_profile_amt,
        p_org_id,
        x_site_use_id,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
    HZ_BUSINESS_EVENT_V2PVT.create_cust_site_use_event (
        l_cust_site_use_rec,
        l_customer_profile_rec,
        p_create_profile,
        p_create_profile_amt );
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_cust_site_use;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_cust_site_use;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );


    WHEN OTHERS THEN
        ROLLBACK TO create_cust_site_use;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_message.set_name( 'AR', 'HZ_API_OTHERS_EXCEP' );
        fnd_message.set_token( 'ERROR' ,SQLERRM );
        fnd_msg_pub.add;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END create_cust_site_use;

----------------CUST_PROFILE-----------------------------------------------------

----Private procedures
PROCEDURE do_create_customer_profile (
    p_customer_profile_rec IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt   IN     VARCHAR2,
    x_cust_account_profile_id   OUT    NOCOPY NUMBER,
    x_return_status             IN OUT NOCOPY VARCHAR2
);


PROCEDURE do_create_cust_profile_amt (
p_check_foreign_key    IN     VARCHAR2,
p_cust_profile_amt_rec IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE,
x_cust_acct_profile_amt_id    OUT    NOCOPY NUMBER,
x_return_status               IN OUT NOCOPY VARCHAR2
);

---Definition

PROCEDURE do_create_customer_profile (
p_customer_profile_rec   IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
p_create_profile_amt     IN     VARCHAR2,
x_cust_account_profile_id  OUT    NOCOPY NUMBER,
x_return_status            IN OUT NOCOPY VARCHAR2
) IS

    l_is_first                   BOOLEAN := TRUE;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);

    l_status                     HZ_CUST_PROFILE_CLASSES.status%TYPE;
    l_profile_class_name         HZ_CUST_PROFILE_CLASSES.name%TYPE;
    l_profile_class_id           NUMBER;


BEGIN

     p_customer_profile_rec.cust_account_profile_id := null;
     p_customer_profile_rec.created_by_module := 'HZ_TCA_CUSTOMER_MERGE';

    -- Call table-handler.
    -- Table_handler is taking care of default customer profile to profile class.
    -- HYU modification of Table Handler add column review_cycle, last_credit_review_date, party_id

    HZ_CUSTOMER_PROFILES_PKG.Insert_Row (
     X_CUST_ACCOUNT_PROFILE_ID=> p_customer_profile_rec.cust_account_profile_id,
     X_CUST_ACCOUNT_ID        => p_customer_profile_rec.cust_account_id,
     X_STATUS                 => p_customer_profile_rec.status,
     X_COLLECTOR_ID           => p_customer_profile_rec.collector_id,
     X_CREDIT_ANALYST_ID      => p_customer_profile_rec.credit_analyst_id,
     X_CREDIT_CHECKING        => p_customer_profile_rec.credit_checking,
     X_NEXT_CREDIT_REVIEW_DATE=> p_customer_profile_rec.next_credit_review_date,
     X_TOLERANCE              => p_customer_profile_rec.tolerance,
     X_DISCOUNT_TERMS         => p_customer_profile_rec.discount_terms,
     X_DUNNING_LETTERS        => p_customer_profile_rec.dunning_letters,
     X_INTEREST_CHARGES       => p_customer_profile_rec.interest_charges,
     X_SEND_STATEMENTS        => p_customer_profile_rec.send_statements,
     X_CREDIT_BALANCE_STATEMENTS=> p_customer_profile_rec.credit_balance_statements,
     X_CREDIT_HOLD            => p_customer_profile_rec.credit_hold,
     X_PROFILE_CLASS_ID       => p_customer_profile_rec.profile_class_id,
     X_SITE_USE_ID            => p_customer_profile_rec.site_use_id,
     X_CREDIT_RATING          => p_customer_profile_rec.credit_rating,
     X_RISK_CODE              => p_customer_profile_rec.risk_code,
     X_STANDARD_TERMS         => p_customer_profile_rec.standard_terms,
     X_OVERRIDE_TERMS         => p_customer_profile_rec.override_terms,
     X_DUNNING_LETTER_SET_ID  => p_customer_profile_rec.dunning_letter_set_id,
     X_INTEREST_PERIOD_DAYS   => p_customer_profile_rec.interest_period_days,
     X_PAYMENT_GRACE_DAYS     => p_customer_profile_rec.payment_grace_days,
     X_DISCOUNT_GRACE_DAYS    => p_customer_profile_rec.discount_grace_days,
     X_STATEMENT_CYCLE_ID     => p_customer_profile_rec.statement_cycle_id,
     X_ACCOUNT_STATUS         => p_customer_profile_rec.account_status,
     X_PERCENT_COLLECTABLE    => p_customer_profile_rec.percent_collectable,
     X_AUTOCASH_HIERARCHY_ID  => p_customer_profile_rec.autocash_hierarchy_id,
     X_ATTRIBUTE_CATEGORY     => p_customer_profile_rec.attribute_category,
     X_ATTRIBUTE1             => p_customer_profile_rec.attribute1,
     X_ATTRIBUTE2             => p_customer_profile_rec.attribute2,
     X_ATTRIBUTE3             => p_customer_profile_rec.attribute3,
     X_ATTRIBUTE4             => p_customer_profile_rec.attribute4,
     X_ATTRIBUTE5             => p_customer_profile_rec.attribute5,
     X_ATTRIBUTE6             => p_customer_profile_rec.attribute6,
     X_ATTRIBUTE7             => p_customer_profile_rec.attribute7,
     X_ATTRIBUTE8             => p_customer_profile_rec.attribute8,
     X_ATTRIBUTE9             => p_customer_profile_rec.attribute9,
     X_ATTRIBUTE10            => p_customer_profile_rec.attribute10,
     X_ATTRIBUTE11            => p_customer_profile_rec.attribute11,
     X_ATTRIBUTE12            => p_customer_profile_rec.attribute12,
     X_ATTRIBUTE13            => p_customer_profile_rec.attribute13,
     X_ATTRIBUTE14            => p_customer_profile_rec.attribute14,
     X_ATTRIBUTE15            => p_customer_profile_rec.attribute15,
     X_AUTO_REC_INCL_DISPUTED_FLAG  => p_customer_profile_rec.auto_rec_incl_disputed_flag,
     X_TAX_PRINTING_OPTION    => p_customer_profile_rec.tax_printing_option,
     X_CHARGE_ON_FINANCE_CHARGE_FG => p_customer_profile_rec.charge_on_finance_charge_flag,
     X_GROUPING_RULE_ID       => p_customer_profile_rec.grouping_rule_id,
     X_CLEARING_DAYS          => p_customer_profile_rec.clearing_days,
     X_JGZZ_ATTRIBUTE_CATEGORY=> p_customer_profile_rec.jgzz_attribute_category,
     X_JGZZ_ATTRIBUTE1        => p_customer_profile_rec.jgzz_attribute1,
     X_JGZZ_ATTRIBUTE2        => p_customer_profile_rec.jgzz_attribute2,
     X_JGZZ_ATTRIBUTE3        => p_customer_profile_rec.jgzz_attribute3,
     X_JGZZ_ATTRIBUTE4        => p_customer_profile_rec.jgzz_attribute4,
     X_JGZZ_ATTRIBUTE5        => p_customer_profile_rec.jgzz_attribute5,
     X_JGZZ_ATTRIBUTE6        => p_customer_profile_rec.jgzz_attribute6,
     X_JGZZ_ATTRIBUTE7        => p_customer_profile_rec.jgzz_attribute7,
     X_JGZZ_ATTRIBUTE8        => p_customer_profile_rec.jgzz_attribute8,
     X_JGZZ_ATTRIBUTE9        => p_customer_profile_rec.jgzz_attribute9,
     X_JGZZ_ATTRIBUTE10       => p_customer_profile_rec.jgzz_attribute10,
     X_JGZZ_ATTRIBUTE11       => p_customer_profile_rec.jgzz_attribute11,
     X_JGZZ_ATTRIBUTE12       => p_customer_profile_rec.jgzz_attribute12,
     X_JGZZ_ATTRIBUTE13       => p_customer_profile_rec.jgzz_attribute13,
     X_JGZZ_ATTRIBUTE14       => p_customer_profile_rec.jgzz_attribute14,
     X_JGZZ_ATTRIBUTE15       => p_customer_profile_rec.jgzz_attribute15,
     X_GLOBAL_ATTRIBUTE1      => p_customer_profile_rec.global_attribute1,
     X_GLOBAL_ATTRIBUTE2      => p_customer_profile_rec.global_attribute2,
     X_GLOBAL_ATTRIBUTE3      => p_customer_profile_rec.global_attribute3,
     X_GLOBAL_ATTRIBUTE4      => p_customer_profile_rec.global_attribute4,
     X_GLOBAL_ATTRIBUTE5      => p_customer_profile_rec.global_attribute5,
     X_GLOBAL_ATTRIBUTE6      => p_customer_profile_rec.global_attribute6,
     X_GLOBAL_ATTRIBUTE7      => p_customer_profile_rec.global_attribute7,
     X_GLOBAL_ATTRIBUTE8      => p_customer_profile_rec.global_attribute8,
     X_GLOBAL_ATTRIBUTE9      => p_customer_profile_rec.global_attribute9,
     X_GLOBAL_ATTRIBUTE10     => p_customer_profile_rec.global_attribute10,
     X_GLOBAL_ATTRIBUTE11     => p_customer_profile_rec.global_attribute11,
     X_GLOBAL_ATTRIBUTE12     => p_customer_profile_rec.global_attribute12,
     X_GLOBAL_ATTRIBUTE13     => p_customer_profile_rec.global_attribute13,
     X_GLOBAL_ATTRIBUTE14     => p_customer_profile_rec.global_attribute14,
     X_GLOBAL_ATTRIBUTE15     => p_customer_profile_rec.global_attribute15,
     X_GLOBAL_ATTRIBUTE16     => p_customer_profile_rec.global_attribute16,
     X_GLOBAL_ATTRIBUTE17     => p_customer_profile_rec.global_attribute17,
     X_GLOBAL_ATTRIBUTE18     => p_customer_profile_rec.global_attribute18,
     X_GLOBAL_ATTRIBUTE19     => p_customer_profile_rec.global_attribute19,
     X_GLOBAL_ATTRIBUTE20     => p_customer_profile_rec.global_attribute20,
     X_GLOBAL_ATTRIBUTE_CATEGORY=> p_customer_profile_rec.global_attribute_category,
     X_CONS_INV_FLAG          => p_customer_profile_rec.cons_inv_flag,
     X_CONS_INV_TYPE          => p_customer_profile_rec.cons_inv_type,
     X_AUTOCASH_HIERARCHY_ID_ADR  => p_customer_profile_rec.autocash_hierarchy_id_for_adr,
     X_LOCKBOX_MATCHING_OPTION=> p_customer_profile_rec.lockbox_matching_option,
     X_OBJECT_VERSION_NUMBER  => 1,
     X_CREATED_BY_MODULE      => p_customer_profile_rec.created_by_module,
     X_APPLICATION_ID         => p_customer_profile_rec.application_id,
     X_REVIEW_CYCLE           => p_customer_profile_rec.review_cycle,
     X_LAST_CREDIT_REVIEW_DATE=> p_customer_profile_rec.last_credit_review_date,
     X_PARTY_ID               => p_customer_profile_rec.party_id,
     X_CREDIT_CLASSIFICATION  => p_customer_profile_rec.credit_classification,
     X_CONS_BILL_LEVEL        => p_customer_profile_rec.cons_bill_level,
     X_LATE_CHARGE_CALCULATION_TRX           => p_customer_profile_rec.late_charge_calculation_trx,
     X_CREDIT_ITEMS_FLAG                     => p_customer_profile_rec.credit_items_flag,
     X_DISPUTED_TRANSACTIONS_FLAG            => p_customer_profile_rec.disputed_transactions_flag,
     X_LATE_CHARGE_TYPE                      => p_customer_profile_rec.late_charge_type,
     X_LATE_CHARGE_TERM_ID                   => p_customer_profile_rec.late_charge_term_id,
     X_INTEREST_CALCULATION_PERIOD           => p_customer_profile_rec.interest_calculation_period,
     X_HOLD_CHARGED_INVOICES_FLAG            => p_customer_profile_rec.hold_charged_invoices_flag,
     X_MESSAGE_TEXT_ID                       => p_customer_profile_rec.message_text_id,
     X_MULTIPLE_INTEREST_RATES_FLAG          => p_customer_profile_rec.multiple_interest_rates_flag,
     X_CHARGE_BEGIN_DATE                     => p_customer_profile_rec.charge_begin_date,
     X_AUTOMATCH_SET_ID			     => p_customer_profile_rec.automatch_set_id
    );

    x_cust_account_profile_id := p_customer_profile_rec.cust_account_profile_id;

    -- No need to create profile amt as this logic is present in
    -- p_create_profile_amt is TRUE. Otherwise, simply return.

END do_create_customer_profile;


PROCEDURE do_create_cust_profile_amt (
p_check_foreign_key    IN     VARCHAR2,
p_cust_profile_amt_rec IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE,
x_cust_acct_profile_amt_id    OUT    NOCOPY NUMBER,
x_return_status               IN OUT NOCOPY VARCHAR2
) IS


BEGIN

    p_cust_profile_amt_rec.created_by_module := 'HZ_TCA_CUSTOMER_MERGE';
    p_cust_profile_amt_rec.cust_acct_profile_amt_id := null;


   -- Call table-handler.
    HZ_CUST_PROFILE_AMTS_PKG.Insert_Row (
    X_CUST_ACCT_PROFILE_AMT_ID=>p_cust_profile_amt_rec.cust_acct_profile_amt_id,
    X_CUST_ACCOUNT_PROFILE_ID => p_cust_profile_amt_rec.cust_account_profile_id,
     X_CURRENCY_CODE          => p_cust_profile_amt_rec.currency_code,
     X_TRX_CREDIT_LIMIT       => p_cust_profile_amt_rec.trx_credit_limit,
     X_OVERALL_CREDIT_LIMIT   => p_cust_profile_amt_rec.overall_credit_limit,
     X_MIN_DUNNING_AMOUNT     => p_cust_profile_amt_rec.min_dunning_amount,
     X_MIN_DUNNING_INVOICE_AMOUNT=> p_cust_profile_amt_rec.min_dunning_invoice_amount,
     X_MAX_INTEREST_CHARGE    => p_cust_profile_amt_rec.max_interest_charge,
     X_MIN_STATEMENT_AMOUNT   => p_cust_profile_amt_rec.min_statement_amount,
     X_AUTO_REC_MIN_RECEIPT_AMOUNT => p_cust_profile_amt_rec.auto_rec_min_receipt_amount,
     X_INTEREST_RATE          => p_cust_profile_amt_rec.interest_rate,
     X_ATTRIBUTE_CATEGORY     => p_cust_profile_amt_rec.attribute_category,
     X_ATTRIBUTE1             => p_cust_profile_amt_rec.attribute1,
     X_ATTRIBUTE2             => p_cust_profile_amt_rec.attribute2,
     X_ATTRIBUTE3             => p_cust_profile_amt_rec.attribute3,
     X_ATTRIBUTE4             => p_cust_profile_amt_rec.attribute4,
     X_ATTRIBUTE5             => p_cust_profile_amt_rec.attribute5,
     X_ATTRIBUTE6             => p_cust_profile_amt_rec.attribute6,
     X_ATTRIBUTE7             => p_cust_profile_amt_rec.attribute7,
     X_ATTRIBUTE8             => p_cust_profile_amt_rec.attribute8,
     X_ATTRIBUTE9             => p_cust_profile_amt_rec.attribute9,
     X_ATTRIBUTE10            => p_cust_profile_amt_rec.attribute10,
     X_ATTRIBUTE11            => p_cust_profile_amt_rec.attribute11,
     X_ATTRIBUTE12            => p_cust_profile_amt_rec.attribute12,
     X_ATTRIBUTE13            => p_cust_profile_amt_rec.attribute13,
     X_ATTRIBUTE14            => p_cust_profile_amt_rec.attribute14,
     X_ATTRIBUTE15            => p_cust_profile_amt_rec.attribute15,
     X_MIN_FC_BALANCE_AMOUNT  => p_cust_profile_amt_rec.min_fc_balance_amount,
     X_MIN_FC_INVOICE_AMOUNT  => p_cust_profile_amt_rec.min_fc_invoice_amount,
     X_CUST_ACCOUNT_ID        => p_cust_profile_amt_rec.cust_account_id,
     X_SITE_USE_ID            => p_cust_profile_amt_rec.site_use_id,
     X_EXPIRATION_DATE        => p_cust_profile_amt_rec.expiration_date,
     X_JGZZ_ATTRIBUTE_CATEGORY=> p_cust_profile_amt_rec.jgzz_attribute_category,
     X_JGZZ_ATTRIBUTE1        => p_cust_profile_amt_rec.jgzz_attribute1,
     X_JGZZ_ATTRIBUTE2        => p_cust_profile_amt_rec.jgzz_attribute2,
     X_JGZZ_ATTRIBUTE3        => p_cust_profile_amt_rec.jgzz_attribute3,
     X_JGZZ_ATTRIBUTE4        => p_cust_profile_amt_rec.jgzz_attribute4,
     X_JGZZ_ATTRIBUTE5        => p_cust_profile_amt_rec.jgzz_attribute5,
     X_JGZZ_ATTRIBUTE6        => p_cust_profile_amt_rec.jgzz_attribute6,
     X_JGZZ_ATTRIBUTE7        => p_cust_profile_amt_rec.jgzz_attribute7,
     X_JGZZ_ATTRIBUTE8        => p_cust_profile_amt_rec.jgzz_attribute8,
     X_JGZZ_ATTRIBUTE9        => p_cust_profile_amt_rec.jgzz_attribute9,
     X_JGZZ_ATTRIBUTE10       => p_cust_profile_amt_rec.jgzz_attribute10,
     X_JGZZ_ATTRIBUTE11       => p_cust_profile_amt_rec.jgzz_attribute11,
     X_JGZZ_ATTRIBUTE12       => p_cust_profile_amt_rec.jgzz_attribute12,
     X_JGZZ_ATTRIBUTE13       => p_cust_profile_amt_rec.jgzz_attribute13,
     X_JGZZ_ATTRIBUTE14       => p_cust_profile_amt_rec.jgzz_attribute14,
     X_JGZZ_ATTRIBUTE15       => p_cust_profile_amt_rec.jgzz_attribute15,
     X_GLOBAL_ATTRIBUTE1      => p_cust_profile_amt_rec.global_attribute1,
     X_GLOBAL_ATTRIBUTE2      => p_cust_profile_amt_rec.global_attribute2,
     X_GLOBAL_ATTRIBUTE3      => p_cust_profile_amt_rec.global_attribute3,
     X_GLOBAL_ATTRIBUTE4      => p_cust_profile_amt_rec.global_attribute4,
     X_GLOBAL_ATTRIBUTE5      => p_cust_profile_amt_rec.global_attribute5,
     X_GLOBAL_ATTRIBUTE6      => p_cust_profile_amt_rec.global_attribute6,
     X_GLOBAL_ATTRIBUTE7      => p_cust_profile_amt_rec.global_attribute7,
     X_GLOBAL_ATTRIBUTE8      => p_cust_profile_amt_rec.global_attribute8,
     X_GLOBAL_ATTRIBUTE9      => p_cust_profile_amt_rec.global_attribute9,
     X_GLOBAL_ATTRIBUTE10     => p_cust_profile_amt_rec.global_attribute10,
     X_GLOBAL_ATTRIBUTE11     => p_cust_profile_amt_rec.global_attribute11,
     X_GLOBAL_ATTRIBUTE12     => p_cust_profile_amt_rec.global_attribute12,
     X_GLOBAL_ATTRIBUTE13     => p_cust_profile_amt_rec.global_attribute13,
     X_GLOBAL_ATTRIBUTE14     => p_cust_profile_amt_rec.global_attribute14,
     X_GLOBAL_ATTRIBUTE15     => p_cust_profile_amt_rec.global_attribute15,
     X_GLOBAL_ATTRIBUTE16     => p_cust_profile_amt_rec.global_attribute16,
     X_GLOBAL_ATTRIBUTE17     => p_cust_profile_amt_rec.global_attribute17,
     X_GLOBAL_ATTRIBUTE18     => p_cust_profile_amt_rec.global_attribute18,
     X_GLOBAL_ATTRIBUTE19     => p_cust_profile_amt_rec.global_attribute19,
     X_GLOBAL_ATTRIBUTE20     => p_cust_profile_amt_rec.global_attribute20,
     X_GLOBAL_ATTRIBUTE_CATEGORY=> p_cust_profile_amt_rec.global_attribute_category,
     X_OBJECT_VERSION_NUMBER  => 1,
     X_CREATED_BY_MODULE      => p_cust_profile_amt_rec.created_by_module,
     X_APPLICATION_ID         => p_cust_profile_amt_rec.application_id,
     X_EXCHANGE_RATE_TYPE                    => p_cust_profile_amt_rec.exchange_rate_type,
     X_MIN_FC_INVOICE_OVERDUE_TYPE           => p_cust_profile_amt_rec.min_fc_invoice_overdue_type,
     X_MIN_FC_INVOICE_PERCENT                => p_cust_profile_amt_rec.min_fc_invoice_percent,
     X_MIN_FC_BALANCE_OVERDUE_TYPE           => p_cust_profile_amt_rec.min_fc_balance_overdue_type,
     X_MIN_FC_BALANCE_PERCENT                => p_cust_profile_amt_rec.min_fc_balance_percent,
     X_INTEREST_TYPE                         => p_cust_profile_amt_rec.interest_type,
     X_INTEREST_FIXED_AMOUNT                 => p_cust_profile_amt_rec.interest_fixed_amount,
     X_INTEREST_SCHEDULE_ID                  => p_cust_profile_amt_rec.interest_schedule_id,
     X_PENALTY_TYPE                          => p_cust_profile_amt_rec.penalty_type,
     X_PENALTY_RATE                          => p_cust_profile_amt_rec.penalty_rate,
     X_MIN_INTEREST_CHARGE                   => p_cust_profile_amt_rec.min_interest_charge,
     X_PENALTY_FIXED_AMOUNT                  => p_cust_profile_amt_rec.penalty_fixed_amount,
     X_PENALTY_SCHEDULE_ID                   => p_cust_profile_amt_rec.penalty_schedule_id
    );

    x_cust_acct_profile_amt_id := p_cust_profile_amt_rec.cust_acct_profile_amt_id;


END do_create_cust_profile_amt;



--------------------------------------
-- public procedures and functions
--------------------------------------
PROCEDURE create_customer_profile (
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_customer_profile_rec     IN     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE,
    p_create_profile_amt       IN     VARCHAR2 := FND_API.G_TRUE,
    x_cust_account_profile_id  OUT    NOCOPY NUMBER,
    x_return_status            OUT    NOCOPY VARCHAR2,
    x_msg_count                OUT    NOCOPY NUMBER,
    x_msg_data                 OUT    NOCOPY VARCHAR2
) IS

    l_customer_profile_rec     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE
                                     := p_customer_profile_rec;

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_customer_profile;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_customer_profile (
        l_customer_profile_rec,
        p_create_profile_amt,
        x_cust_account_profile_id,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
    HZ_BUSINESS_EVENT_V2PVT.create_customer_profile_event (
        l_customer_profile_rec,
        p_create_profile_amt );
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_customer_profile;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_customer_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );


    WHEN OTHERS THEN
        ROLLBACK TO create_customer_profile;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_message.set_name( 'AR', 'HZ_API_OTHERS_EXCEP' );
        fnd_message.set_token( 'ERROR' ,SQLERRM );
        fnd_msg_pub.add;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );


END create_customer_profile;



PROCEDURE create_cust_profile_amt (
    p_init_msg_list               IN     VARCHAR2 := FND_API.G_FALSE,
    p_check_foreign_key           IN     VARCHAR2 := FND_API.G_TRUE,
    p_cust_profile_amt_rec        IN     HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE,
    x_cust_acct_profile_amt_id    OUT    NOCOPY NUMBER,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    l_cust_profile_amt_rec        HZ_CUSTOMER_PROFILE_V2PUB.CUST_PROFILE_AMT_REC_TYPE :=
                                                    p_cust_profile_amt_rec;

BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_cust_profile_amt;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_cust_profile_amt (
        p_check_foreign_key,
        l_cust_profile_amt_rec,
        x_cust_acct_profile_amt_id,
        x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
    HZ_BUSINESS_EVENT_V2PVT.create_cust_profile_amt_event (
        l_cust_profile_amt_rec );
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_cust_profile_amt;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_cust_profile_amt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        ROLLBACK TO create_cust_profile_amt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        fnd_message.set_name( 'AR', 'HZ_API_OTHERS_EXCEP' );
        fnd_message.set_token( 'ERROR' ,SQLERRM );
        fnd_msg_pub.add;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END create_cust_profile_amt;

  ------------------------CONTACT_POINTS------------------------

  --------------------------------------
  -- declaration of private procedures and functions
  --------------------------------------

  PROCEDURE do_create_contact_point (
    p_contact_point_rec IN OUT NOCOPY hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec           IN OUT NOCOPY hz_contact_point_v2pub.edi_rec_type,
    p_eft_rec           IN OUT NOCOPY hz_contact_point_v2pub.eft_rec_type,
    p_email_rec         IN OUT NOCOPY hz_contact_point_v2pub.email_rec_type,
    p_phone_rec         IN OUT NOCOPY hz_contact_point_v2pub.phone_rec_type,
    p_telex_rec         IN OUT NOCOPY hz_contact_point_v2pub.telex_rec_type,
    p_web_rec           IN OUT NOCOPY hz_contact_point_v2pub.web_rec_type,
    x_contact_point_id  OUT    NOCOPY NUMBER,
    x_return_status     IN OUT NOCOPY VARCHAR2
  );

  PROCEDURE do_denormalize_contact_point (
    p_party_id              IN     NUMBER,
    p_contact_point_type    IN     VARCHAR2,
    p_url                   IN     VARCHAR2,
    p_email_address         IN     VARCHAR2
  );

   PROCEDURE do_unset_prim_contact_point (
    p_owner_table_name                 IN     VARCHAR2,
    p_owner_table_id                   IN     NUMBER,
    p_contact_point_type               IN     VARCHAR2,
    p_contact_point_id                 IN     NUMBER
  );

 PROCEDURE do_unset_primary_by_purpose (
    p_owner_table_name                 IN     VARCHAR2,
    p_owner_table_id                   IN     NUMBER,
    p_contact_point_type               IN     VARCHAR2,
    p_contact_point_purpose            IN     VARCHAR2,
    p_contact_point_id                 IN     NUMBER
  );

  --------------------------------------
  -- body of private procedures
  --------------------------------------


  PROCEDURE do_create_contact_point (
    p_contact_point_rec   IN OUT NOCOPY hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec             IN OUT NOCOPY hz_contact_point_v2pub.edi_rec_type,
    p_eft_rec             IN OUT NOCOPY hz_contact_point_v2pub.eft_rec_type,
    p_email_rec           IN OUT NOCOPY hz_contact_point_v2pub.email_rec_type,
    p_phone_rec           IN OUT NOCOPY hz_contact_point_v2pub.phone_rec_type,
    p_telex_rec           IN OUT NOCOPY hz_contact_point_v2pub.telex_rec_type,
    p_web_rec             IN OUT NOCOPY hz_contact_point_v2pub.web_rec_type,
    x_contact_point_id    OUT    NOCOPY NUMBER,
    x_return_status       IN OUT NOCOPY VARCHAR2
  ) IS

    l_dummy                     VARCHAR2(1);
    l_message_count             NUMBER;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_formatted_phone_number    VARCHAR2(100);
    l_country_code              hz_locations.country%TYPE;
    l_transposed_phone_number   hz_contact_points.transposed_phone_number%TYPE;

    l_edi_rec                   hz_contact_point_v2pub.edi_rec_type;
    l_eft_rec                   hz_contact_point_v2pub.eft_rec_type;
    l_email_rec                 hz_contact_point_v2pub.email_rec_type;
    l_phone_rec                 hz_contact_point_v2pub.phone_rec_type;
    l_telex_rec                 hz_contact_point_v2pub.telex_rec_type;
    l_web_rec                   hz_contact_point_v2pub.web_rec_type;
    l_orig_sys_reference_rec  HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

  -- Bug 2197181: added for mix-n-match project: the contact point
    -- must be visible.

  -- SSM SST Integration and Extension
  -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
  -- There is no need to check if the data-source is selected.

    CURSOR c_cp (p_owner_table_name   IN VARCHAR2,
                 p_owner_table_id     IN NUMBER,
                 p_contact_point_type IN VARCHAR2) IS
      SELECT 'Y'
      FROM   hz_contact_points
      WHERE  owner_table_name = p_owner_table_name
      AND owner_table_id = p_owner_table_id
      AND contact_point_type = p_contact_point_type
/*      AND HZ_MIXNM_UTILITY.isDataSourceSelected (
            g_cpt_selected_datasources, actual_content_source ) = 'Y'*/
      AND status = 'A'
      AND rownum = 1;


  BEGIN

    p_contact_point_rec.created_by_module := 'HZ_TCA_CUSTOMER_MERGE';
    p_contact_point_rec.contact_point_id := NULL;
    p_contact_point_rec.orig_system_reference := NULL;

    IF p_contact_point_rec.contact_point_type = 'EDI' THEN
      l_edi_rec := p_edi_rec;
    ELSIF p_contact_point_rec.contact_point_type = 'EFT' THEN
      l_eft_rec := p_eft_rec;
    ELSIF p_contact_point_rec.contact_point_type = 'EMAIL' THEN
      l_email_rec := p_email_rec;
    ELSIF p_contact_point_rec.contact_point_type = 'PHONE' THEN
      l_phone_rec := p_phone_rec;
    ELSIF p_contact_point_rec.contact_point_type = 'TLX' THEN
      l_telex_rec := p_telex_rec;
    ELSIF p_contact_point_rec.contact_point_type = 'WEB' THEN
      l_web_rec := p_web_rec;
    ELSE
      l_edi_rec := p_edi_rec;
      l_eft_rec := p_eft_rec;
      l_email_rec := p_email_rec;
      l_phone_rec := p_phone_rec;
      l_telex_rec := p_telex_rec;
      l_web_rec := p_web_rec;
    END IF;


    -- If this is the first active contact point for the combination of
    -- owner_table_name, owner_table_id, contact_point_type, we need to
    -- mark it as primary no matter the value of primary_flag,
    -- If primary_flag = 'Y', we need to unmark the previous primary.
    -- Please note, if status is NULL or MISSING, we treat it as 'A'
    -- and in validation part, we already checked that primary_flag = 'Y'
    -- and status = 'I' can not both be set.

    -- Bug 2197181: added for mix-n-match project: the primary flag
    -- can be set to 'Y' only if the contact point will be visible. If
    -- it is not visible, the flag must be reset to 'N'.


    IF p_contact_point_rec.status IS NULL OR
       p_contact_point_rec.status = fnd_api.g_miss_char OR
       p_contact_point_rec.status = 'A'
    THEN
      IF p_contact_point_rec.primary_flag = 'Y' THEN
        -- Bug 2197181: added for mix-n-match project

    -- SSM SST Integration and Extension
    -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
    -- There is no need to check if the data-source is selected.

    --    IF g_cpt_is_datasource_selected = 'Y' THEN
          -- Unmark previous primary contact point.
          do_unset_prim_contact_point(p_contact_point_rec.owner_table_name,
                                       p_contact_point_rec.owner_table_id,
                                       p_contact_point_rec.contact_point_type,
                                       p_contact_point_rec.contact_point_id);
    --    ELSE
    --      p_contact_point_rec.primary_flag := 'N';
    --    END IF;
      ELSE
        -- Bug 2117973: modified to conform to Applications PL/SQL standards.
        OPEN c_cp (p_contact_point_rec.owner_table_name,
                    p_contact_point_rec.owner_table_id,
                    p_contact_point_rec.contact_point_type);
        FETCH c_cp INTO l_dummy;

        IF c_cp%NOTFOUND /*AND
           -- Bug 2197181: added for mix-n-match project
           g_cpt_is_datasource_selected = 'Y'*/
        THEN
          -- First active and visible contact point per type for this entity
          p_contact_point_rec.primary_flag := 'Y';
        ELSE
          p_contact_point_rec.primary_flag := 'N';
        END IF;
        CLOSE c_cp;
      END IF;

    -- De-normalize primary contact point to hz_parties.
    -- url is mandatory if contact_point_type = 'WEB'.
    -- email_address is mandatory if contact_point_type = 'EMAIL'.

    IF p_contact_point_rec.primary_flag = 'Y' AND
       p_contact_point_rec.owner_table_name = 'HZ_PARTIES' AND
       (p_contact_point_rec.contact_point_type = 'WEB' OR
        p_contact_point_rec.contact_point_type = 'EMAIL')
    THEN
      do_denormalize_contact_point(p_contact_point_rec.owner_table_id,
                                   p_contact_point_rec.contact_point_type,
                                   l_web_rec.url,
                                   l_email_rec.email_address);
    END IF;
  END IF;

   -- There is only one primary per purpose contact point exist for
    -- the combination of owner_table_name, owner_table_id, contact_point_type
    -- and contact_point_purpose. If primary_by_purpose is set to 'Y',
    -- we need to unset the previous primary per purpose contact point to
    -- non-primary. Since setting primary_by_purpose is only making
    -- sense when contact_point_purpose has some value, we ignore
    -- the primary_by_purpose (setting it to 'N') if contact_point_purpose
    -- is NULL.

    -- Bug 2197181: added for mix-n-match project: the primary by purpose
    -- flag can be set to 'Y' only if the contact point will be visible.
    -- If it is not visible, the flag must be reset to 'N'.

    IF p_contact_point_rec.contact_point_purpose IS NOT NULL AND
       p_contact_point_rec.contact_point_purpose <> fnd_api.g_miss_char
    THEN
      IF p_contact_point_rec.primary_by_purpose = 'Y' THEN
        -- Bug 2197181: added for mix-n-match project

        -- SSM SST Integration and Extension
        -- For non-profile entities, the concept of select/de-select data-sources is obsoleted.
        -- There is no need to check if the data-source is selected.

     -- IF g_cpt_is_datasource_selected = 'Y' THEN
          do_unset_primary_by_purpose (p_contact_point_rec.owner_table_name,
                                       p_contact_point_rec.owner_table_id,
                                       p_contact_point_rec.contact_point_type,
                                       p_contact_point_rec.contact_point_purpose,
                                       p_contact_point_rec.contact_point_id);
     -- ELSE
     --   p_contact_point_rec.primary_by_purpose := 'N';
     -- END IF;
      END IF;
    ELSE
      p_contact_point_rec.primary_by_purpose := 'N';
    END IF;
    --Start of bug 7299887
-- Populate transposed_phone_number
	IF p_contact_point_rec.contact_point_type = 'PHONE' THEN
		IF l_phone_rec.phone_country_code IS NOT NULL AND
		   l_phone_rec.phone_country_code <> fnd_api.g_miss_char    THEN

			l_transposed_phone_number := l_phone_rec.phone_country_code;
		END IF;

		IF l_phone_rec.phone_area_code IS NOT NULL AND
	   	   l_phone_rec.phone_area_code <> fnd_api.g_miss_char   THEN

			l_transposed_phone_number := l_transposed_phone_number ||l_phone_rec.phone_area_code;

		END IF;

		-- phone_number is mandatory
		l_transposed_phone_number := hz_phone_number_pkg.transpose(
							l_transposed_phone_number || l_phone_rec.phone_number);
	END IF;
--End of bug 7299887

    -- Call table-handler.
    hz_contact_points_pkg.insert_row (
      x_contact_point_id          => p_contact_point_rec.contact_point_id,
      x_contact_point_type        => p_contact_point_rec.contact_point_type,
      x_status                    => p_contact_point_rec.status,
      x_owner_table_name          => p_contact_point_rec.owner_table_name,
      x_owner_table_id            => p_contact_point_rec.owner_table_id,
      x_primary_flag              => p_contact_point_rec.primary_flag,
      x_orig_system_reference     => p_contact_point_rec.orig_system_reference,
      x_attribute_category        => p_contact_point_rec.attribute_category,
      x_attribute1                => p_contact_point_rec.attribute1,
      x_attribute2                => p_contact_point_rec.attribute2,
      x_attribute3                => p_contact_point_rec.attribute3,
      x_attribute4                => p_contact_point_rec.attribute4,
      x_attribute5                => p_contact_point_rec.attribute5,
      x_attribute6                => p_contact_point_rec.attribute6,
      x_attribute7                => p_contact_point_rec.attribute7,
      x_attribute8                => p_contact_point_rec.attribute8,
      x_attribute9                => p_contact_point_rec.attribute9,
      x_attribute10               => p_contact_point_rec.attribute10,
      x_attribute11               => p_contact_point_rec.attribute11,
      x_attribute12               => p_contact_point_rec.attribute12,
      x_attribute13               => p_contact_point_rec.attribute13,
      x_attribute14               => p_contact_point_rec.attribute14,
      x_attribute15               => p_contact_point_rec.attribute15,
      x_attribute16               => p_contact_point_rec.attribute16,
      x_attribute17               => p_contact_point_rec.attribute17,
      x_attribute18               => p_contact_point_rec.attribute18,
      x_attribute19               => p_contact_point_rec.attribute19,
      x_attribute20               => p_contact_point_rec.attribute20,
      x_edi_transaction_handling  => l_edi_rec.edi_transaction_handling,
      x_edi_id_number             => l_edi_rec.edi_id_number,
      x_edi_payment_method        => l_edi_rec.edi_payment_method,
      x_edi_payment_format        => l_edi_rec.edi_payment_format,
      x_edi_remittance_method     => l_edi_rec.edi_remittance_method,
      x_edi_remittance_instruction => l_edi_rec.edi_remittance_instruction,
      x_edi_tp_header_id          => l_edi_rec.edi_tp_header_id,
      x_edi_ece_tp_location_code  => l_edi_rec.edi_ece_tp_location_code,
      x_eft_transmission_program_id => l_eft_rec.eft_transmission_program_id,
      x_eft_printing_program_id   => l_eft_rec.eft_printing_program_id,
      x_eft_user_number           => l_eft_rec.eft_user_number,
      x_eft_swift_code            => l_eft_rec.eft_swift_code,
      x_email_format              => l_email_rec.email_format,
      x_email_address             => l_email_rec.email_address,
      x_phone_calling_calendar    => l_phone_rec.phone_calling_calendar,
      x_last_contact_dt_time      => l_phone_rec.last_contact_dt_time,
      x_timezone_id               => l_phone_rec.timezone_id,
      x_phone_area_code           => l_phone_rec.phone_area_code,
      x_phone_country_code        => l_phone_rec.phone_country_code,
      x_phone_number              => l_phone_rec.phone_number,
      x_phone_extension           => l_phone_rec.phone_extension,
      x_phone_line_type           => l_phone_rec.phone_line_type,
      x_telex_number              => l_telex_rec.telex_number,
      x_web_type                  => l_web_rec.web_type,
      x_url                       => l_web_rec.url,
      x_content_source_type       => p_contact_point_rec.content_source_type,
      x_raw_phone_number          => l_phone_rec.raw_phone_number,
      x_object_version_number     => 1,
      x_contact_point_purpose     => p_contact_point_rec.contact_point_purpose,
      x_primary_by_purpose        => p_contact_point_rec.primary_by_purpose,
      x_created_by_module         => p_contact_point_rec.created_by_module,
      x_application_id            => p_contact_point_rec.application_id,
      x_transposed_phone_number   => l_transposed_phone_number,
      x_actual_content_source   => p_contact_point_rec.actual_content_source
    );

    x_contact_point_id := p_contact_point_rec.contact_point_id;
/*
 per HLD,mosr record should not be created for copy case, since old osr is still active
   hz_orig_system_ref_pvt.create_mosr_for_merge(
                                        FND_API.G_FALSE,
                                        'HZ_CONTACT_POINTS',
                                        p_contact_point_rec.contact_point_id,
                                        x_return_status,
                                        l_msg_count,
                                        l_msg_data);

   IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
   END IF;
*/
  END do_create_contact_point;

  PROCEDURE do_unset_prim_contact_point (
    p_owner_table_name                      IN     VARCHAR2,
    p_owner_table_id                        IN     NUMBER,
    p_contact_point_type                    IN     VARCHAR2,
    p_contact_point_id                      IN     NUMBER
  ) IS

    l_contact_point_id                      NUMBER;

  BEGIN


    -- Check during insert.
    IF p_contact_point_id IS NULL THEN
      l_contact_point_id := fnd_api.g_miss_num;
    ELSE
      l_contact_point_id := p_contact_point_id;
    END IF;

    UPDATE hz_contact_points
    SET    primary_flag = 'N'
    WHERE  owner_table_name = p_owner_table_name
    AND owner_table_id = p_owner_table_id
    AND contact_point_type = p_contact_point_type
    AND contact_point_id <> l_contact_point_id
    -- AND content_source_type = hz_party_v2pub.g_miss_content_source_type
    AND primary_flag = 'Y';


  END do_unset_prim_contact_point;


  PROCEDURE do_denormalize_contact_point (
    p_party_id                              IN     NUMBER,
    p_contact_point_type                    IN     VARCHAR2,
    p_url                                   IN     VARCHAR2,
    p_email_address                         IN     VARCHAR2
  ) IS
  BEGIN
    IF p_contact_point_type = 'WEB' THEN
      UPDATE hz_parties
      SET    url = p_url
      WHERE  party_id = p_party_id;
    ELSIF p_contact_point_type = 'EMAIL' THEN
      UPDATE hz_parties
      SET    email_address = p_email_address
      WHERE  party_id = p_party_id;
    END IF;
  END do_denormalize_contact_point;

  PROCEDURE do_unset_primary_by_purpose (
    p_owner_table_name                      IN     VARCHAR2,
    p_owner_table_id                        IN     NUMBER,
    p_contact_point_type                    IN     VARCHAR2,
    p_contact_point_purpose                 IN     VARCHAR2,
    p_contact_point_id                      IN     NUMBER
  ) IS

    l_contact_point_id                      NUMBER;

  BEGIN


    -- Check during insert.
    IF p_contact_point_id IS NULL THEN
      l_contact_point_id := FND_API.G_MISS_NUM;
    ELSE
      l_contact_point_id := p_contact_point_id;
    END IF;

    UPDATE hz_contact_points
    SET    primary_by_purpose = 'N'
    WHERE  owner_table_name = p_owner_table_name
    AND owner_table_id = p_owner_table_id
    AND contact_point_type = p_contact_point_type
    AND contact_point_purpose = p_contact_point_purpose
    AND contact_point_id <> l_contact_point_id
    -- AND content_source_type = hz_party_v2pub.g_miss_content_source_type
    AND primary_by_purpose = 'Y';

 END do_unset_primary_by_purpose;

  --------------------------------------
  -- public procedures and functions
  --------------------------------------


  PROCEDURE create_contact_point (
    p_init_msg_list     IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec    IN  hz_contact_point_v2pub.edi_rec_type := g_miss_edi_rec,
    p_eft_rec    IN  hz_contact_point_v2pub.eft_rec_type := g_miss_eft_rec,
    p_email_rec  IN  hz_contact_point_v2pub.email_rec_type := g_miss_email_rec,
    p_phone_rec  IN  hz_contact_point_v2pub.phone_rec_type := g_miss_phone_rec,
    p_telex_rec  IN  hz_contact_point_v2pub.telex_rec_type := g_miss_telex_rec,
    p_web_rec    IN  hz_contact_point_v2pub.web_rec_type := g_miss_web_rec,
    x_contact_point_id  OUT NOCOPY NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
  ) IS

    l_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type :=
                          p_contact_point_rec;
    l_edi_rec           hz_contact_point_v2pub.edi_rec_type := p_edi_rec;
    l_eft_rec           hz_contact_point_v2pub.eft_rec_type := p_eft_rec;
    l_email_rec         hz_contact_point_v2pub.email_rec_type := p_email_rec;
    l_phone_rec         hz_contact_point_v2pub.phone_rec_type := p_phone_rec;
    l_telex_rec         hz_contact_point_v2pub.telex_rec_type := p_telex_rec;
    l_web_rec           hz_contact_point_v2pub.web_rec_type := p_web_rec;

  BEGIN

    -- Standard start of API savepoint
    SAVEPOINT create_contact_point;

    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

/* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.

     IF g_cpt_mixnmatch_enabled IS NULL THEN
      HZ_MIXNM_UTILITY.LoadDataSources(
        p_entity_name                    => 'HZ_CONTACT_POINTS',
        p_entity_attr_id                 => g_cpt_entity_attr_id,
        p_mixnmatch_enabled              => g_cpt_mixnmatch_enabled,
        p_selected_datasources           => g_cpt_selected_datasources );
    END IF;
*/

   HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation (
      p_entity_name                    => 'HZ_CONTACT_POINTS',
      p_entity_attr_id                 => g_cpt_entity_attr_id,
      p_mixnmatch_enabled              => g_cpt_mixnmatch_enabled,
      p_selected_datasources           => g_cpt_selected_datasources,
      p_content_source_type            => l_contact_point_rec.content_source_type,
      p_actual_content_source          => l_contact_point_rec.actual_content_source,
      x_is_datasource_selected         => g_cpt_is_datasource_selected,
      x_return_status                  => x_return_status );



    -- Call to business logic.
    do_create_contact_point(l_contact_point_rec,
                            l_edi_rec,
                            l_eft_rec,
                            l_email_rec,
                            l_phone_rec,
                            l_telex_rec,
                            l_web_rec,
                            x_contact_point_id,
                            x_return_status);

    IF x_return_status = fnd_api.g_ret_sts_success THEN
      -- Invoke business event system.
      hz_business_event_v2pvt.create_contact_point_event(
        l_contact_point_rec,
        l_edi_rec,
        l_eft_rec,
        l_email_rec,
        l_phone_rec,
        l_telex_rec,
        l_web_rec);
    END IF;

    -- Call to indicate contact point creation to DQM
    hz_dqm_sync.sync_contact_point(l_contact_point_rec.contact_point_id, 'C');

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data);


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

        fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
        fnd_message.set_token('ERROR' ,SQLERRM);
        fnd_msg_pub.add;

        fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data);

  END create_contact_point;


  PROCEDURE get_contact_point_rec (
    p_init_msg_list     IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_id  IN     NUMBER,
    x_contact_point_rec OUT    NOCOPY hz_contact_point_v2pub.contact_point_rec_type,
    x_edi_rec           OUT    NOCOPY hz_contact_point_v2pub.edi_rec_type,
    x_eft_rec           OUT    NOCOPY hz_contact_point_v2pub.eft_rec_type,
    x_email_rec         OUT    NOCOPY hz_contact_point_v2pub.email_rec_type,
    x_phone_rec         OUT    NOCOPY hz_contact_point_v2pub.phone_rec_type,
    x_telex_rec         OUT    NOCOPY hz_contact_point_v2pub.telex_rec_type,
    x_web_rec           OUT    NOCOPY hz_contact_point_v2pub.web_rec_type,
    x_return_status     OUT    NOCOPY VARCHAR2,
    x_msg_count         OUT    NOCOPY NUMBER,
    x_msg_data          OUT    NOCOPY VARCHAR2
  ) IS

    l_transposed_phone_number   hz_contact_points.transposed_phone_number%TYPE;

  BEGIN

    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- Check whether primary key has been passed in.
    IF p_contact_point_id IS NULL OR
       p_contact_point_id = FND_API.G_MISS_NUM THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
      fnd_message.set_token('COLUMN', 'contact_point_id');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    x_contact_point_rec.contact_point_id := p_contact_point_id;

    -- Call table-handler
    hz_contact_points_pkg.select_row(
      x_contact_point_id          => x_contact_point_rec.contact_point_id,
      x_contact_point_type        => x_contact_point_rec.contact_point_type,
      x_status                    => x_contact_point_rec.status,
      x_owner_table_name          => x_contact_point_rec.owner_table_name,
      x_owner_table_id            => x_contact_point_rec.owner_table_id,
      x_primary_flag              => x_contact_point_rec.primary_flag,
      x_orig_system_reference     => x_contact_point_rec.orig_system_reference,
      x_attribute_category        => x_contact_point_rec.attribute_category,
      x_attribute1                => x_contact_point_rec.attribute1,
      x_attribute2                => x_contact_point_rec.attribute2,
      x_attribute3                => x_contact_point_rec.attribute3,
      x_attribute4                => x_contact_point_rec.attribute4,
      x_attribute5                => x_contact_point_rec.attribute5,
      x_attribute6                => x_contact_point_rec.attribute6,
      x_attribute7                => x_contact_point_rec.attribute7,
      x_attribute8                => x_contact_point_rec.attribute8,
      x_attribute9                => x_contact_point_rec.attribute9,
      x_attribute10               => x_contact_point_rec.attribute10,
      x_attribute11               => x_contact_point_rec.attribute11,
      x_attribute12               => x_contact_point_rec.attribute12,
      x_attribute13               => x_contact_point_rec.attribute13,
      x_attribute14               => x_contact_point_rec.attribute14,
      x_attribute15               => x_contact_point_rec.attribute15,
      x_attribute16               => x_contact_point_rec.attribute16,
      x_attribute17               => x_contact_point_rec.attribute17,
      x_attribute18               => x_contact_point_rec.attribute18,
      x_attribute19               => x_contact_point_rec.attribute19,
      x_attribute20               => x_contact_point_rec.attribute20,
      x_edi_transaction_handling  => x_edi_rec.edi_transaction_handling,
      x_edi_id_number             => x_edi_rec.edi_id_number,
      x_edi_payment_method        => x_edi_rec.edi_payment_method,
      x_edi_payment_format        => x_edi_rec.edi_payment_format,
      x_edi_remittance_method     => x_edi_rec.edi_remittance_method,
      x_edi_remittance_instruction => x_edi_rec.edi_remittance_instruction,
      x_edi_tp_header_id          => x_edi_rec.edi_tp_header_id,
      x_edi_ece_tp_location_code  => x_edi_rec.edi_ece_tp_location_code,
      x_eft_transmission_program_id => x_eft_rec.eft_transmission_program_id,
      x_eft_printing_program_id   => x_eft_rec.eft_printing_program_id,
      x_eft_user_number           => x_eft_rec.eft_user_number,
      x_eft_swift_code            => x_eft_rec.eft_swift_code,
      x_email_format              => x_email_rec.email_format,
      x_email_address             => x_email_rec.email_address,
      x_phone_calling_calendar    => x_phone_rec.phone_calling_calendar,
      x_last_contact_dt_time      => x_phone_rec.last_contact_dt_time,
      x_timezone_id               => x_phone_rec.timezone_id,
      x_phone_area_code           => x_phone_rec.phone_area_code,
      x_phone_country_code        => x_phone_rec.phone_country_code,
      x_phone_number              => x_phone_rec.phone_number,
      x_phone_extension           => x_phone_rec.phone_extension,
      x_phone_line_type           => x_phone_rec.phone_line_type,
      x_telex_number              => x_telex_rec.telex_number,
      x_web_type                  => x_web_rec.web_type,
      x_url                       => x_web_rec.url,
      x_content_source_type       => x_contact_point_rec.content_source_type,
      x_raw_phone_number          => x_phone_rec.raw_phone_number,
      x_contact_point_purpose     => x_contact_point_rec.contact_point_purpose,
      x_primary_by_purpose        => x_contact_point_rec.primary_by_purpose,
      x_created_by_module         => x_contact_point_rec.created_by_module,
      x_application_id            => x_contact_point_rec.application_id,
      x_transposed_phone_number   => l_transposed_phone_number,
      x_actual_content_source   => x_contact_point_rec.actual_content_source
    );


    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END get_contact_point_rec;

------------------ PARTY_SITE_USE -------------------------------------



/*===========================================================================+
 | PROCEDURE
 |              get_party_site_use_rec
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
 |                    p_party_site_id
 |              OUT:
 |                    x_party_site_rec
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

PROCEDURE get_party_site_use_rec (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_use_id             IN          NUMBER,
    x_party_site_use_rec            OUT         NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE,
    x_return_status                 OUT         NOCOPY VARCHAR2,
    x_msg_count                     OUT         NOCOPY NUMBER,
    x_msg_data                      OUT         NOCOPY VARCHAR2
) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_party_site_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_party_site_use_id IS NULL OR
       p_party_site_use_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'p_party_site_use_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_party_site_use_rec.party_site_use_id := p_party_site_use_id;

    HZ_PARTY_SITE_USES_PKG.Select_Row (
        X_PARTY_SITE_USE_ID                     => x_party_site_use_rec.party_site_use_id,
        X_COMMENTS                              => x_party_site_use_rec.comments,
        X_PARTY_SITE_ID                         => x_party_site_use_rec.party_site_id,
        X_SITE_USE_TYPE                         => x_party_site_use_rec.site_use_type,
        X_PRIMARY_PER_TYPE                      => x_party_site_use_rec.primary_per_type,
        X_STATUS                                => x_party_site_use_rec.status,
        X_CREATED_BY_MODULE                     => x_party_site_use_rec.created_by_module,
        X_APPLICATION_ID                        => x_party_site_use_rec.application_id
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

END get_party_site_use_rec;


/*===========================================================================+
 | PROCEDURE
 |              do_unmark_primary_per_type
 |
 | DESCRIPTION
 |              unmark the primary_per_type in hz_party_site_uses
 |              for those site uses that are not primary for
 |              each party.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_party_id
 |                    p_party_site_id
 |                    p_site_use_type
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   20-May-2004     Ramesh Ch       Created.
 |
 +===========================================================================*/

PROCEDURE do_unmark_primary_per_type(
    p_party_id                      IN     NUMBER,
    p_party_site_id                 IN     NUMBER,
    p_site_use_type                 IN     VARCHAR2
) IS

    CURSOR c_party_site_uses IS
      SELECT ROWID
      FROM   HZ_PARTY_SITE_USES SU
      WHERE  SU.PARTY_SITE_ID IN (
               SELECT PS.PARTY_SITE_ID
               FROM   HZ_PARTY_SITES PS
               WHERE  PARTY_ID = p_party_id )
      AND    SU.PARTY_SITE_ID <> p_party_site_id
      AND    SU.SITE_USE_TYPE = p_site_use_type
      AND    SU.PRIMARY_PER_TYPE = 'Y'
      AND    ROWNUM = 1
      FOR UPDATE NOWAIT;

    l_rowid               VARCHAR2(100);

BEGIN

    -- check if party site use record is locked by any one else.
    -- notice the combination of party_site_id and site_use_type
    -- is unique.

    BEGIN
      OPEN c_party_site_uses;
      FETCH c_party_site_uses INTO l_rowid;
      CLOSE c_party_site_uses;
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PARTY_SITE_USES');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF l_rowid IS NOT NULL THEN
      UPDATE HZ_PARTY_SITE_USES
      SET    PRIMARY_PER_TYPE = 'N',
             last_update_date     = hz_utility_v2pub.last_update_date,
             last_updated_by      = hz_utility_v2pub.last_updated_by,
             last_update_login    = hz_utility_v2pub.last_update_login,
             request_id           = hz_utility_v2pub.request_id,
             program_id           = hz_utility_v2pub.program_id,
             program_application_id = hz_utility_v2pub.program_application_id,
             program_update_date  = hz_utility_v2pub.program_update_date
      WHERE  ROWID = l_rowid;
    END IF;

END do_unmark_primary_per_type;


/*===========================================================================+
 | PROCEDURE
 |              do_create_party_site_use
 |
 | DESCRIPTION
 |              Creates party_site_use.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_party_site_use_id
 |          IN/ OUT:
 |                    p_party_site_use_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_party_site_use(
    p_party_site_use_rec    IN OUT  NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE,
    x_party_site_use_id     OUT     NOCOPY NUMBER,
    x_return_status         IN OUT  NOCOPY VARCHAR2
) IS

    l_party_site_use_id             NUMBER := p_party_site_use_rec.party_site_use_id;
    l_rowid                         ROWID := NULL;
    l_count                         NUMBER;
    l_exist                         VARCHAR2(1) := 'N';
    l_party_id                      NUMBER;
    l_primary_per_type              VARCHAR2(1) := p_party_site_use_rec.primary_per_type;
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);
    l_dummy                         VARCHAR2(1);
    l_debug_prefix                  VARCHAR2(30) := '';

BEGIN

    -- if this is the first party site use per type,,
    -- we need to  mark it with primary_per_type = 'Y'.
    SELECT PARTY_ID
    INTO   l_party_id
    FROM   HZ_PARTY_SITES
    WHERE  PARTY_SITE_ID = p_party_site_use_rec.party_site_id;

    IF p_party_site_use_rec.primary_per_type  = 'Y' THEN  --Bug No:3560167
      do_unmark_primary_per_type(l_party_id,p_party_site_use_rec.party_site_id,p_party_site_use_rec.site_use_type); --Bug No:3560167
    ELSE
      l_primary_per_type := 'N';
      BEGIN
          SELECT 'Y'
          INTO   l_exist
          FROM   HZ_PARTY_SITE_USES SU
          WHERE  PARTY_SITE_ID IN (
                                   SELECT PARTY_SITE_ID
                                   FROM   HZ_PARTY_SITES PS
                                   WHERE  PS.PARTY_ID = l_party_id )
          AND    SU.SITE_USE_TYPE = p_party_site_use_rec.site_use_type
          AND ROWNUM = 1;

      EXCEPTION

          --this is a new site use type
          WHEN NO_DATA_FOUND THEN
              l_primary_per_type := 'Y';
      END;
      p_party_site_use_rec.primary_per_type := l_primary_per_type;
    END IF;
    -- call table-handler.
    HZ_PARTY_SITE_USES_PKG.Insert_Row (
        X_PARTY_SITE_USE_ID                     => p_party_site_use_rec.party_site_use_id,
        X_COMMENTS                              => p_party_site_use_rec.comments,
        X_PARTY_SITE_ID                         => p_party_site_use_rec.party_site_id,
        X_SITE_USE_TYPE                         => p_party_site_use_rec.site_use_type,
        X_PRIMARY_PER_TYPE                      => p_party_site_use_rec.primary_per_type,
        X_STATUS                                => p_party_site_use_rec.status,
        X_OBJECT_VERSION_NUMBER                 => 1,
        X_CREATED_BY_MODULE                     => p_party_site_use_rec.created_by_module,
        X_APPLICATION_ID                        => p_party_site_use_rec.application_id
    );

    x_party_site_use_id := p_party_site_use_rec.party_site_use_id;

END do_create_party_site_use;


/*===========================================================================+
 | PROCEDURE
 |              create_party_site_use
 |
 | DESCRIPTION
 |              Creates party_site_use.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_party_site_use_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_party_site_use_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rashmi Goyal   31-AUG-99  Created
 |
 +===========================================================================*/

PROCEDURE create_party_site_use (
    p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
    p_party_site_use_rec    IN     HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE,
    x_party_site_use_id     OUT    NOCOPY NUMBER,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2
) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'create_party_site_use';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_party_site_use_rec           HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE := p_party_site_use_rec;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_party_site_use;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_party_site_use(
                             l_party_site_use_rec,
                             x_party_site_use_id,
                             x_return_status
                            );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
    HZ_BUSINESS_EVENT_V2PVT.create_party_site_use_event (
        l_party_site_use_rec );
   END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_party_site_use;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_party_site_use;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_party_site_use;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);


END create_party_site_use;

END hz_cust_account_merge_v2pvt;

/
