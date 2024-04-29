--------------------------------------------------------
--  DDL for Package HZ_PARTY_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2PASS.pls 120.13 2006/08/17 10:12:15 idali noship $ */
/*#
 * This package contains the public APIs to create and update persons, organizations, and groups.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Party
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:category BUSINESS_ENTITY HZ_GROUP
 * @rep:category BUSINESS_ENTITY HZ_PARTY
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Party APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

G_MISS_CONTENT_SOURCE_TYPE          CONSTANT VARCHAR2(30) := 'USER_ENTERED';
G_SST_SOURCE_TYPE                   CONSTANT VARCHAR2(30) := 'SST';

TYPE party_rec_type IS RECORD(
    party_id                        NUMBER,
    party_number                    VARCHAR2(30),
    validated_flag                  VARCHAR2(1),
    orig_system_reference           VARCHAR2(240),
    orig_system                     VARCHAR2(30),
    status                          VARCHAR2(1),
    category_code                   VARCHAR2(30),
    salutation                      VARCHAR2(60),
    attribute_category              VARCHAR2(30),
    attribute1                      VARCHAR2(150),
    attribute2                      VARCHAR2(150),
    attribute3                      VARCHAR2(150),
    attribute4                      VARCHAR2(150),
    attribute5                      VARCHAR2(150),
    attribute6                      VARCHAR2(150),
    attribute7                      VARCHAR2(150),
    attribute8                      VARCHAR2(150),
    attribute9                      VARCHAR2(150),
    attribute10                     VARCHAR2(150),
    attribute11                     VARCHAR2(150),
    attribute12                     VARCHAR2(150),
    attribute13                     VARCHAR2(150),
    attribute14                     VARCHAR2(150),
    attribute15                     VARCHAR2(150),
    attribute16                     VARCHAR2(150),
    attribute17                     VARCHAR2(150),
    attribute18                     VARCHAR2(150),
    attribute19                     VARCHAR2(150),
    attribute20                     VARCHAR2(150),
    attribute21                     VARCHAR2(150),
    attribute22                     VARCHAR2(150),
    attribute23                     VARCHAR2(150),
    attribute24                     VARCHAR2(150)
);

G_MISS_PARTY_REC                    PARTY_REC_TYPE;

TYPE person_rec_type IS RECORD(
    person_pre_name_adjunct         VARCHAR2(30),
    person_first_name               VARCHAR2(150),
    person_middle_name              VARCHAR2(60),
    person_last_name                VARCHAR2(150),
    person_name_suffix              VARCHAR2(30),
    person_title                    VARCHAR2(60),
    person_academic_title           VARCHAR2(30),
    person_previous_last_name       VARCHAR2(150),
    person_initials                 VARCHAR2(6),
    known_as                        VARCHAR2(240),
    known_as2                       VARCHAR2(240),
    known_as3                       VARCHAR2(240),
    known_as4                       VARCHAR2(240),
    known_as5                       VARCHAR2(240),
    person_name_phonetic            VARCHAR2(320),
    person_first_name_phonetic      VARCHAR2(60),
    person_last_name_phonetic       VARCHAR2(60),
    middle_name_phonetic            VARCHAR2(60),
    tax_reference                   VARCHAR2(50),
    jgzz_fiscal_code                VARCHAR2(20),
    person_iden_type                VARCHAR2(30),
    person_identifier               VARCHAR2(60),
    date_of_birth                   DATE,
    place_of_birth                  VARCHAR2(60),
    date_of_death                   DATE,
    deceased_flag                    VARCHAR2(1),
    gender                          VARCHAR2(30),
    declared_ethnicity              VARCHAR2(60),
    marital_status                  VARCHAR2(30),
    marital_status_effective_date   DATE,
    personal_income                 NUMBER,
    head_of_household_flag          VARCHAR2(1),
    household_income                NUMBER,
    household_size                  NUMBER,
    rent_own_ind                    VARCHAR2(30),
    last_known_gps                  VARCHAR2(60),
    content_source_type             VARCHAR2(30):= G_MISS_CONTENT_SOURCE_TYPE,
    internal_flag                   VARCHAR2(2),
    attribute_category              VARCHAR2(30),
    attribute1                      VARCHAR2(150) ,
    attribute2                      VARCHAR2(150) ,
    attribute3                      VARCHAR2(150) ,
    attribute4                      VARCHAR2(150) ,
    attribute5                      VARCHAR2(150) ,
    attribute6                      VARCHAR2(150) ,
    attribute7                      VARCHAR2(150) ,
    attribute8                      VARCHAR2(150) ,
    attribute9                      VARCHAR2(150) ,
    attribute10                     VARCHAR2(150) ,
    attribute11                     VARCHAR2(150) ,
    attribute12                     VARCHAR2(150) ,
    attribute13                     VARCHAR2(150) ,
    attribute14                     VARCHAR2(150) ,
    attribute15                     VARCHAR2(150) ,
    attribute16                     VARCHAR2(150) ,
    attribute17                     VARCHAR2(150) ,
    attribute18                     VARCHAR2(150) ,
    attribute19                     VARCHAR2(150) ,
    attribute20                     VARCHAR2(150) ,
    created_by_module               VARCHAR2(150),
    application_id                  NUMBER,
    actual_content_source           VARCHAR2(30) := G_SST_SOURCE_TYPE,
    party_rec                       PARTY_REC_TYPE := G_MISS_PARTY_REC
);

G_MISS_PERSON_REC                   PERSON_REC_TYPE;

TYPE group_rec_type IS RECORD(
    group_name                      VARCHAR2(255),
    group_type                      VARCHAR2(30),
    created_by_module               VARCHAR2(150),
    -- Bug 2467872
    mission_statement               VARCHAR2(2000),
    application_id                  NUMBER,
    party_rec                       PARTY_REC_TYPE := G_MISS_PARTY_REC
);

G_MISS_GROUP_REC                            GROUP_REC_TYPE;

TYPE organization_rec_type IS RECORD(
    organization_name               VARCHAR2(360),
    duns_number_c                   VARCHAR2(30),
    enquiry_duns                    VARCHAR2(15),
    ceo_name                        VARCHAR2(240),
    ceo_title                       VARCHAR2(240),
    principal_name                  VARCHAR2(240),
    principal_title                 VARCHAR2(240),
    legal_status                    VARCHAR2(30),
    control_yr                      NUMBER,
    employees_total                 NUMBER,
    hq_branch_ind                   VARCHAR2(30),
    branch_flag                     VARCHAR2(1),
    oob_ind                         VARCHAR2(30),
    line_of_business                VARCHAR2(240),
    cong_dist_code                  VARCHAR2(2),
    sic_code                        VARCHAR2(30),
    import_ind                      VARCHAR2(30),
    export_ind                      VARCHAR2(30),
    labor_surplus_ind               VARCHAR2(30),
    debarment_ind                   VARCHAR2(30),
    minority_owned_ind              VARCHAR2(30),
    minority_owned_type             VARCHAR2(30),
    woman_owned_ind                 VARCHAR2(30),
    disadv_8a_ind                   VARCHAR2(30),
    small_bus_ind                   VARCHAR2(30),
    rent_own_ind                    VARCHAR2(30),
    debarments_count                NUMBER,
    debarments_date                 DATE,
    failure_score                   VARCHAR2(30),
    failure_score_natnl_percentile  NUMBER,
    failure_score_override_code     VARCHAR2(30),
    failure_score_commentary        VARCHAR2(30),
    global_failure_score            VARCHAR2(5),
    db_rating                       VARCHAR2(5),
    credit_score                    VARCHAR2(30),
    credit_score_commentary         VARCHAR2(30),
    paydex_score                    VARCHAR2(3),
    paydex_three_months_ago         VARCHAR2(3),
    paydex_norm                     VARCHAR2(3),
    best_time_contact_begin         DATE,
    best_time_contact_end           DATE,
    organization_name_phonetic      VARCHAR2(320),
    tax_reference                   VARCHAR2(50),
    gsa_indicator_flag              VARCHAR2(1),
    jgzz_fiscal_code                VARCHAR2(20),
    analysis_fy                     VARCHAR2(5),
    fiscal_yearend_month            VARCHAR2(30),
    curr_fy_potential_revenue       NUMBER,
    next_fy_potential_revenue       NUMBER,
    year_established                NUMBER,
    mission_statement               VARCHAR2(2000),
    organization_type               VARCHAR2(30),
    business_scope                  VARCHAR2(20),
    corporation_class               VARCHAR2(60),
    known_as                        VARCHAR2(240),
    known_as2                       VARCHAR2(240),
    known_as3                       VARCHAR2(240),
    known_as4                       VARCHAR2(240),
    known_as5                       VARCHAR2(240),
    local_bus_iden_type             VARCHAR2(30),
    local_bus_identifier            VARCHAR2(60),
    pref_functional_currency        VARCHAR2(30),
    registration_type               VARCHAR2(30),
    total_employees_text            VARCHAR2(60),
    total_employees_ind             VARCHAR2(30),
    total_emp_est_ind               VARCHAR2(30),
    total_emp_min_ind               VARCHAR2(30),
    parent_sub_ind                  VARCHAR2(30),
    incorp_year                     NUMBER,
    sic_code_type                   VARCHAR2(30),
    public_private_ownership_flag   VARCHAR2(1),
    internal_flag                   VARCHAR2(30),
    local_activity_code_type        VARCHAR2(30),
    local_activity_code             VARCHAR2(30),
    emp_at_primary_adr              VARCHAR2(10),
    emp_at_primary_adr_text         VARCHAR2(12),
    emp_at_primary_adr_est_ind      VARCHAR2(30),
    emp_at_primary_adr_min_ind      VARCHAR2(30),
    high_credit                     NUMBER,
    avg_high_credit                 NUMBER,
    total_payments                  NUMBER,
    credit_score_class              NUMBER,
    credit_score_natl_percentile    NUMBER,
    credit_score_incd_default       NUMBER,
    credit_score_age                NUMBER,
    credit_score_date               DATE,
    credit_score_commentary2        VARCHAR2(30),
    credit_score_commentary3        VARCHAR2(30),
    credit_score_commentary4        VARCHAR2(30),
    credit_score_commentary5        VARCHAR2(30),
    credit_score_commentary6        VARCHAR2(30),
    credit_score_commentary7        VARCHAR2(30),
    credit_score_commentary8        VARCHAR2(30),
    credit_score_commentary9        VARCHAR2(30),
    credit_score_commentary10       VARCHAR2(30),
    failure_score_class             NUMBER,
    failure_score_incd_default      NUMBER,
    failure_score_age               NUMBER,
    failure_score_date              DATE,
    failure_score_commentary2       VARCHAR2(30),
    failure_score_commentary3       VARCHAR2(30),
    failure_score_commentary4       VARCHAR2(30),
    failure_score_commentary5       VARCHAR2(30),
    failure_score_commentary6       VARCHAR2(30),
    failure_score_commentary7       VARCHAR2(30),
    failure_score_commentary8       VARCHAR2(30),
    failure_score_commentary9       VARCHAR2(30),
    failure_score_commentary10      VARCHAR2(30),
    maximum_credit_recommendation   NUMBER,
    maximum_credit_currency_code    VARCHAR2(240),
    displayed_duns_party_id         NUMBER,
    content_source_type             VARCHAR2(30) := G_MISS_CONTENT_SOURCE_TYPE,
    content_source_number           VARCHAR2(30),
    attribute_category              VARCHAR2(30),
    attribute1                      VARCHAR2(150),
    attribute2                      VARCHAR2(150),
    attribute3                      VARCHAR2(150),
    attribute4                      VARCHAR2(150),
    attribute5                      VARCHAR2(150),
    attribute6                      VARCHAR2(150),
    attribute7                      VARCHAR2(150),
    attribute8                      VARCHAR2(150),
    attribute9                      VARCHAR2(150),
    attribute10                     VARCHAR2(150),
    attribute11                     VARCHAR2(150),
    attribute12                     VARCHAR2(150),
    attribute13                     VARCHAR2(150),
    attribute14                     VARCHAR2(150),
    attribute15                     VARCHAR2(150),
    attribute16                     VARCHAR2(150),
    attribute17                     VARCHAR2(150),
    attribute18                     VARCHAR2(150),
    attribute19                     VARCHAR2(150),
    attribute20                     VARCHAR2(150),
    created_by_module               VARCHAR2(150),
    application_id                  NUMBER,
    do_not_confuse_with             VARCHAR2(255),
    actual_content_source           VARCHAR2(30) := G_SST_SOURCE_TYPE,
    home_country                    VARCHAR2(2),
    party_rec                       PARTY_REC_TYPE:= G_MISS_PARTY_REC

);

G_MISS_ORGANIZATION_REC             ORGANIZATION_REC_TYPE;

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_person
 *
 * DESCRIPTION
 *     Creates person.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_rec                   Person record.
 *   IN/OUT:
 *   OUT:
 *     x_party_id                     Party ID.
 *     x_party_number                 Party number.
 *     x_profile_id                   Person profile ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to create information about a person. This API creates a record in the
 * HZ_PARTIES table with party type PERSON. The HZ_PARTIES table holds the basic
 * information about the party. The API also creates a record in the HZ_PERSON_PROFILES
 * table. That record holds more detailed and specific information about the person.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Person
 * @rep:businessevent oracle.apps.ar.hz.Person.create
 * @rep:doccd 120hztig.pdf Party APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_person (
    p_init_msg_list                    IN      VARCHAR2:= FND_API.G_FALSE,
    p_person_rec                       IN      PERSON_REC_TYPE,
    x_party_id                         OUT NOCOPY     NUMBER,
    x_party_number                     OUT NOCOPY     VARCHAR2,
    x_profile_id                       OUT NOCOPY     NUMBER,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE create_person
 *
 * DESCRIPTION
 *     Creates person.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_rec                   Person record.
 *     p_party_usage_code             Party Usage Code.
 *   IN/OUT:
 *   OUT:
 *     x_party_id                     Party ID.
 *     x_party_number                 Party number.
 *     x_profile_id                   Person profile ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-15-2005    Jianying Huang   o Created.
 *
 */

PROCEDURE create_person (
    p_init_msg_list                    IN     VARCHAR2:= FND_API.G_FALSE,
    p_person_rec                       IN     PERSON_REC_TYPE,
    p_party_usage_code                 IN     VARCHAR2,
    x_party_id                         OUT    NOCOPY NUMBER,
    x_party_number                     OUT    NOCOPY VARCHAR2,
    x_profile_id                       OUT    NOCOPY NUMBER,
    x_return_status                    OUT    NOCOPY VARCHAR2,
    x_msg_count                        OUT    NOCOPY NUMBER,
    x_msg_data                         OUT    NOCOPY VARCHAR2
);

/**
 * PROCEDURE update_person
 *
 * DESCRIPTION
 *     Updates person.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_rec                   Person record.
 *   IN/OUT:
 *     p_party_object_version_number  Used for locking the being updated record.
 *   OUT:
 *     x_profile_id                   Person profile ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to update information about a person. This API updates the party record
 * for a person in the HZ_PARTIES table. The API also creates or updates a record in the
 * HZ_PERSON_PROFILES table. If the record about a person is updated on the same day that
 * the record is created, then the active profile record is updated. Otherwise, a new
 * profile record is created, and an end date is assigned to the old profile record.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Person
 * @rep:businessevent oracle.apps.ar.hz.Person.update
 * @rep:doccd 120hztig.pdf Party APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_person (
    p_init_msg_list                    IN      VARCHAR2:= FND_API.G_FALSE,
    p_person_rec                       IN      PERSON_REC_TYPE,
    p_party_object_version_number      IN OUT NOCOPY  NUMBER,
    x_profile_id                       OUT NOCOPY     NUMBER,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE create_group
 *
 * DESCRIPTION
 *     Creates group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_group_rec                    Group record.
 *   IN/OUT:
 *   OUT:
 *     x_party_id                     Party ID.
 *     x_party_number                 Party number.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to create a record about a group. This API creates records in the
 * HZ_PARTIES table with the GROUP party type. The HZ_PARTIES table stores basic
 * information about the party. Unlike an Organization or Person party, there is no profile
 * information for a Group party.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Group
 * @rep:businessevent oracle.apps.ar.hz.Group.create
 * @rep:doccd 120hztig.pdf Party APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_group (
    p_init_msg_list                    IN      VARCHAR2:= FND_API.G_FALSE,
    p_group_rec                        IN      GROUP_REC_TYPE,
    x_party_id                         OUT NOCOPY     NUMBER,
    x_party_number                     OUT NOCOPY     VARCHAR2,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_group
 *
 * DESCRIPTION
 *     Updates group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_group_rec                    Group record.
 *   IN/OUT:
 *     p_party_object_version_number  Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to update a record about a group. This API updates the party record for
 * the group in the HZ_PARTIES table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Group
 * @rep:businessevent oracle.apps.ar.hz.Group.update
 * @rep:doccd 120hztig.pdf Party APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_group (
    p_init_msg_list                    IN      VARCHAR2:= FND_API.G_FALSE,
    p_group_rec                        IN      GROUP_REC_TYPE,
    p_party_object_version_number      IN OUT NOCOPY  NUMBER,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE create_organization
 *
 * DESCRIPTION
 *     Creates organization.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_organization_rec             Organization record.
 *   IN/OUT:
 *   OUT:
 *     x_party_id                     Party ID.
 *     x_party_number                 Party number.
 *     x_profile_id                   Organization profile ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to create a record about an organization. This API creates records in
 * the HZ_PARTIES table with Organization party type. The HZ_PARTIES table stores basic
 * information about the party. The API also creates a record in the
 * HZ_ORGANIZATION_PROFILES table. That record holds more detailed and specific information
 * about the organization.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Organization
 * @rep:businessevent oracle.apps.ar.hz.Organization.create
 * @rep:doccd 120hztig.pdf Party APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_organization (
    p_init_msg_list                    IN      VARCHAR2:= FND_API.G_FALSE,
    p_organization_rec                 IN      ORGANIZATION_REC_TYPE,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2,
    x_party_id                         OUT NOCOPY     NUMBER,
    x_party_number                     OUT NOCOPY     VARCHAR2,
    x_profile_id                       OUT NOCOPY     NUMBER
);

/**
 * PROCEDURE create_organization
 *
 * DESCRIPTION
 *     Creates organization.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_organization_rec             Organization record.
 *     p_party_usage_code             Party Usage Code.
 *   IN/OUT:
 *   OUT:
 *     x_party_id                     Party ID.
 *     x_party_number                 Party number.
 *     x_profile_id                   Organization profile ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-15-2005    Jianying Huang   o Created.
 *
 */

PROCEDURE create_organization (
    p_init_msg_list                    IN     VARCHAR2:= FND_API.G_FALSE,
    p_organization_rec                 IN     ORGANIZATION_REC_TYPE,
    p_party_usage_code                 IN     VARCHAR2,
    x_return_status                    OUT    NOCOPY VARCHAR2,
    x_msg_count                        OUT    NOCOPY NUMBER,
    x_msg_data                         OUT    NOCOPY VARCHAR2,
    x_party_id                         OUT    NOCOPY NUMBER,
    x_party_number                     OUT    NOCOPY VARCHAR2,
    x_profile_id                       OUT    NOCOPY NUMBER
);

/**
 * PROCEDURE update_organization
 *
 * DESCRIPTION
 *     Updates organization.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_organization_rec             Organization record.
 *   IN/OUT:
 *     p_party_object_version_number  Used for locking the being updated record.
 *   OUT:
 *     x_profile_id                   Organization profile ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to update a record about an organization. This API updates the party
 * record for the organization in the HZ_PARTIES table. The API also creates or updates a
 * record in the HZ_ORGANIZATION_PROFILES table. If the record about an organization is
 * updated on the same day that it is created, then the active profile record is updated.
 * Otherwise, a new profile record that is created and an end date is assigned to the old
 * profile record.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Organization
 * @rep:businessevent oracle.apps.ar.hz.Organization.update
 * @rep:doccd 120hztig.pdf Party APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_organization (
    p_init_msg_list                    IN      VARCHAR2:= FND_API.G_FALSE,
    p_organization_rec                 IN      ORGANIZATION_REC_TYPE,
    p_party_object_version_number      IN OUT NOCOPY  NUMBER,
    x_profile_id                       OUT NOCOPY     NUMBER,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE get_party_rec
 *
 * DESCRIPTION
 *     Gets party record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_party_id                     Party ID.
 *   IN/OUT:
 *   OUT:
 *     x_party_rec                    Returned party record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_party_rec (
    p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_party_id                         IN      NUMBER,
    x_party_rec                        OUT     NOCOPY PARTY_REC_TYPE,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE get_organization_rec
 *
 * DESCRIPTION
 *     Gets organization record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_party_id                     Party ID.
 *     p_content_source_type          Content source type.
 *   IN/OUT:
 *   OUT:
 *     x_organization_rec             Returned organization record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_organization_rec (
    p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_party_id                         IN      NUMBER,
    p_content_source_type              IN      VARCHAR2 := G_MISS_CONTENT_SOURCE_TYPE,
    x_organization_rec                 OUT     NOCOPY ORGANIZATION_REC_TYPE,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE get_person_rec
 *
 * DESCRIPTION
 *     Gets person record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_party_id                     Party ID.
 *     p_content_source_type          Content source type.
 *   IN/OUT:
 *   OUT:
 *     x_person_rec                   Returned person record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_person_rec (
    p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_party_id                         IN      NUMBER,
    p_content_source_type              IN      VARCHAR2 := G_MISS_CONTENT_SOURCE_TYPE,
    x_person_rec                       OUT     NOCOPY PERSON_REC_TYPE,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
);

  /**
   * PROCEDURE get_group_rec
   *
   * DESCRIPTION
   *     Gets group record.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_init_msg_list      Initialize message stack if it is set to
   *                          FND_API.G_TRUE. Default is fnd_api.g_false.
   *     p_party_id           Party ID.
   *   IN/OUT:
   *   OUT:
   *     x_group_rec          Returned group record.
   *     x_return_status      Return status after the call. The status can
   *                          be fnd_api.g_ret_sts_success (success),
   *                          fnd_api.g_ret_sts_error (error),
   *                          fnd_api.g_ret_sts_unexp_error (unexpected error).
   *     x_msg_count          Number of messages in message stack.
   *     x_msg_data           Message text if x_msg_count is 1.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *   04-25-2002    Jianying Huang    o Created.
   *
   */

  PROCEDURE get_group_rec (
    p_init_msg_list                    IN     VARCHAR2 := fnd_api.g_false,
    p_party_id                         IN     NUMBER,
    x_group_rec                        OUT    NOCOPY GROUP_REC_TYPE,
    x_return_status                    OUT NOCOPY    VARCHAR2,
    x_msg_count                        OUT NOCOPY    NUMBER,
    x_msg_data                         OUT NOCOPY    VARCHAR2
  );

END HZ_PARTY_V2PUB;

 

/
