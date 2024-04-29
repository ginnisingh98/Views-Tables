--------------------------------------------------------
--  DDL for Package HZ_PERSON_INFO_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PERSON_INFO_V2PUB" AUTHID CURRENT_USER AS
/* $Header: ARH2PISS.pls 120.11 2006/08/17 10:13:13 idali noship $ */
/*#
 * This package contains the public APIs for person-related entities.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Person Information
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE person_language_rec_type IS RECORD(
    language_use_reference_id               NUMBER,
    language_name                           VARCHAR2(4),
    party_id                                NUMBER,
    native_language                         VARCHAR2(1),
    primary_language_indicator              VARCHAR2(1),
    reads_level                             VARCHAR2(30),
    speaks_level                            VARCHAR2(30),
    writes_level                            VARCHAR2(30),
    spoken_comprehension_level              VARCHAR2(30),
    status                                  VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

TYPE citizenship_rec_type IS RECORD(
    citizenship_id                          NUMBER,
    party_id                                NUMBER,
    birth_or_selected			    VARCHAR(30),
    country_code                            VARCHAR2(2),
    date_recognized                         DATE,
    date_disowned                           DATE,
    end_date                                DATE,
    document_type                           VARCHAR2(30),
    document_reference                      VARCHAR2(60),
    status                                  VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);


TYPE education_rec_type IS RECORD(
    education_id                            NUMBER,
    party_id                                NUMBER,
    course_major 			    VARCHAR2(60),
    degree_received                         VARCHAR2(60),
    start_date_attended                     DATE,
    last_date_attended                      DATE,
    school_attended_name                    VARCHAR2(60),
    school_party_id                         NUMBER,
    -- Code modified for Bug 3473418 starts here
    type_of_school                          VARCHAR2(30),
    -- Code modified for Bug 3473418 ends here
    status                                  VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

TYPE employment_history_rec_type IS RECORD(
    employment_history_id                   NUMBER,
    party_id                                NUMBER,
    begin_date  			    DATE,
    end_date                                DATE,
    employment_type_code                    VARCHAR2(30),
    employed_as_title_code                  VARCHAR2(30),
    employed_as_title                       VARCHAR2(60),
    employed_by_name_company                VARCHAR2(60),
    employed_by_party_id                    NUMBER,
    employed_by_division_name               VARCHAR2(60),
    supervisor_name                         VARCHAR2(60),
    branch                                  VARCHAR2(80),
    military_rank                           VARCHAR2(240),
    served                                  VARCHAR2(240),
    station                                 VARCHAR2(240),
    responsibility                          VARCHAR2(240),
    weekly_work_hours                       NUMBER,
    reason_for_leaving                      VARCHAR2(240),
    faculty_position_flag                   VARCHAR2(1),
    tenure_code                             VARCHAR2(30),
    fraction_of_tenure                      NUMBER,
    comments                                VARCHAR2(2000),
    status                                  VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

TYPE work_class_rec_type IS RECORD(
    work_class_id 		            NUMBER,
    level_of_experience                     VARCHAR2(60),
    work_class_name                         VARCHAR2(240),
    employment_history_id                   NUMBER,
    status                                  VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

TYPE person_interest_rec_type IS RECORD(
    person_interest_id                      NUMBER,
    level_of_interest                       VARCHAR2(30),
    party_id                                NUMBER,
    level_of_participation                  VARCHAR2(30),
    interest_type_code                      VARCHAR2(30),
    comments                                VARCHAR2(240),
    sport_indicator                         VARCHAR2(1),
    sub_interest_type_code                  VARCHAR2(30),
    interest_name                           VARCHAR2(240),
    team                                    VARCHAR2(240),
    since				    DATE,
    status				    VARCHAR(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);


--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_person_language
 *
 * DESCRIPTION
 *     Creates person language.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_language_rec          Person language record.
 *   IN/OUT:
 *   OUT:
 *     x_language_use_reference_id    Language use reference ID.
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
 * Use this routine to create a language for a party. This API creates records in the
 * HZ_PERSON_LANGUAGE table. You must create the Person party before you can
 * create a language record for the party. You can create multiple language records with
 * different language names for a party. This API lets you flag one language record as the
 * person's primary language and one language record as the person's native language.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Person Language
 * @rep:businessevent oracle.apps.ar.hz.PersonLanguage.create
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_person_language(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_person_language_rec                   IN      PERSON_LANGUAGE_REC_TYPE,
    x_language_use_reference_id             OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_person_language
 *
 * DESCRIPTION
 *     Updates person language.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_language_rec          Person language record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
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
 * Use this routine to update the language record for a party. This API updates a record
 * in the HZ_PERSON_LANGUAGE table. You cannot update the language name, but you
 * can change other attributes of the language record.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Person Language
 * @rep:businessevent oracle.apps.ar.hz.PersonLanguage.update
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE  update_person_language(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_person_language_rec                   IN      PERSON_LANGUAGE_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE get_person_language_rec
 *
 * DESCRIPTION
 *     Gets person language record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_language_use_reference_id    Language use reference ID.
 *   IN/OUT:
 *   OUT:
 *     x_person_language_rec          Returned person language record.
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

PROCEDURE get_person_language_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_language_use_reference_id             IN     NUMBER,
    p_person_language_rec                   OUT    NOCOPY PERSON_LANGUAGE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE create_citizenship
 *
 * DESCRIPTION
 *     Creates citizenship.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_citizenship_rec              Citizenship record.
 *   IN/OUT:
 *   OUT:
 *     x_citizenship_id               Citizenship ID.
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
 *   31-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

/*#
 * Use this routine to create a citizenship record for a party. This API creates a
 * record in the HZ_CITIZENSHIP table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Citizenship
 * @rep:businessevent oracle.apps.ar.hz.Citizenship.create
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_citizenship(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_citizenship_rec                       IN      CITIZENSHIP_REC_TYPE,
    x_citizenship_id                        OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_citizenship
 *
 * DESCRIPTION
 *     Updates citizenship.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_citizenship_rec              citizenship record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
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
 *   31-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

/*#
 * Use this routine to update the citizenship record for a Person party.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Citizenship
 * @rep:businessevent oracle.apps.ar.hz.Citizenship.update
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE  update_citizenship(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_citizenship_rec                       IN      CITIZENSHIP_REC_TYPE,
    p_object_version_number                 IN  OUT NOCOPY  NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE get_citizenship_rec
 *
 * DESCRIPTION
 *     Gets citizenship record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_citizenship_id               Citizenship ID.
 *   IN/OUT:
 *   OUT:
 *     x_citizenship_rec              Returned citizenship record.
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
 *   31-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE get_citizenship_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_citizenship_id                        IN     NUMBER,
    x_citizenship_rec                       OUT NOCOPY    CITIZENSHIP_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);


/**
 * PROCEDURE create_education
 *
 * DESCRIPTION
 *     Creates education.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_education_rec                Education record.
 *   IN/OUT:
 *   OUT:
 *     x_education_id                 Education ID.
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
 *   31-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

/*#
 * Use this routine to create an education record for a Person party. This API creates a
 * record in the HZ_EDUCATION table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Education
 * @rep:businessevent oracle.apps.ar.hz.Education.create
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_education(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_education_rec                         IN      EDUCATION_REC_TYPE,
    x_education_id                          OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_education
 *
 * DESCRIPTION
 *     Updates Education.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_education_rec                Education record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
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
 *   31-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

/*#
 * Use this routine to update the education record for a Person party.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Education
 * @rep:businessevent oracle.apps.ar.hz.Education.update
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE  update_education(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_education_rec                         IN      EDUCATION_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY    NUMBER,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_education_rec
 *
 * DESCRIPTION
 *     Gets Education record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_education_id                 Education ID.
 *   IN/OUT:
 *   OUT:
 *     x_education_rec                Returned Education record.
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
 *   31-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE get_education_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_education_id                          IN     NUMBER,
    x_education_rec                         OUT NOCOPY     EDUCATION_REC_TYPE,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
);


/**
 * PROCEDURE create_employment_history
 *
 * DESCRIPTION
 *     Creates employment_history record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_employment_history_rec       Employment history record.
 *   IN/OUT:
 *   OUT:
 *     x_employment_history_id        Employment history ID.
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
 *   31-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

/*#
 * Use this routine to create an employment history for a party. This API
 * creates a record in the HZ_EMPLOYMENT_HISTORY table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Employment History
 * @rep:businessevent oracle.apps.ar.hz.EmploymentHistory.create
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_employment_history(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_employment_history_rec                IN      EMPLOYMENT_HISTORY_REC_TYPE,
    x_employment_history_id                 OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_employment_history
 *
 * DESCRIPTION
 *     Updates Employment history.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_employment_history_rec       Employment history record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
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
 *   31-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

/*#
 * Use this routine to update the employment history for a party.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Employment History
 * @rep:businessevent oracle.apps.ar.hz.EmploymentHistory.update
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE  update_employment_history(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_employment_history_rec                IN      EMPLOYMENT_HISTORY_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY    NUMBER,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_employment_history_rec
 *
 * DESCRIPTION
 *     Gets Employment history record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_employment_history_id        Employment history ID.
 *   IN/OUT:
 *   OUT:
 *     x_employment_history_rec       Returned Employment history record.
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
 *   31-Jan-2003  Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE get_employment_history_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_employment_history_id                 IN     NUMBER,
    x_employment_history_rec                   OUT NOCOPY EMPLOYMENT_HISTORY_REC_TYPE,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
);


/**
 * PROCEDURE create_work_class
 *
 * DESCRIPTION
 *     Creates work_class record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_work_class_rec               Work class record.
 *   IN/OUT:
 *   OUT:
 *     x_work_class_id                Work class ID.
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
 *   02-Feb-2003  Porkodi Chinnandar  o Created.
 *
 */

/*#
 * Use this routine to create a work class record for a party. This API create records in
 * the HZ_WORK_CLASS table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Work Class
 * @rep:businessevent oracle.apps.ar.hz.WorkClass.create
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_work_class(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_work_class_rec                        IN      WORK_CLASS_REC_TYPE,
    x_work_class_id                         OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_work_class
 *
 * DESCRIPTION
 *     Updates Work_class.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_work_class_rec               Work class record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
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
 *   02-Feb-2003  Porkodi Chinnandar  o Created.
 *
 */

/*#
 * Use this routine to update the work class record for a party.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Work Class
 * @rep:businessevent oracle.apps.ar.hz.WorkClass.update
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE  update_work_class(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_work_class_rec                        IN      WORK_CLASS_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY    NUMBER,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_work_class_rec
 *
 * DESCRIPTION
 *     Gets Work class record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_work_class_id                Work class ID.
 *   IN/OUT:
 *   OUT:
 *     x_work_class_rec               Returned Work class record.
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
 *   02-Feb-2003  Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE get_work_class_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_work_class_id                         IN     NUMBER,
    x_work_class_rec                        OUT NOCOPY WORK_CLASS_REC_TYPE,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE create_person_interest
 *
 * DESCRIPTION
 *     Creates person_interest record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_interest_rec          Person interest record.
 *   IN/OUT:
 *   OUT:
 *     x_person_interest_id           Person interest ID.
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
 *   02-Feb-2003  Porkodi Chinnandar  o Created.
 *
 */

/*#
 * Use this routine to create a person interest record for a party. This API creates
 * records in the HZ_PERSON_INTEREST table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Person Interest
 * @rep:businessevent oracle.apps.ar.hz.PersonInterest.create
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_person_interest(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_person_interest_rec                   IN      PERSON_INTEREST_REC_TYPE,
    x_person_interest_id                    OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_person_interest
 *
 * DESCRIPTION
 *     Updates person interest.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_interest_rec          person interest record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
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
 *   02-Feb-2003  Porkodi Chinnandar  o Created.
 *
 */

/*#
 * Use this routine to update the person interest record for a party.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Person Interest
 * @rep:businessevent oracle.apps.ar.hz.PersonInterest.update
 * @rep:doccd 120hztig.pdf Person Info APIs, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE  update_person_interest(
    p_init_msg_list                         IN      VARCHAR2 := FND_API.G_FALSE,
    p_person_interest_rec                   IN      PERSON_INTEREST_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY    NUMBER,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE get_person_interest_rec
 *
 * DESCRIPTION
 *     Gets Person interest record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_person_interest_id           Person interest ID.
 *   IN/OUT:
 *   OUT:
 *     x_person_interest_rec          Returned person interest record.
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
 *   02-Feb-2003  Porkodi Chinnandar  o Created.
 *
 */

PROCEDURE get_person_interest_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_person_interest_id                    IN     NUMBER,
    x_person_interest_rec                      OUT NOCOPY    PERSON_INTEREST_REC_TYPE,
    x_return_status                            OUT NOCOPY    VARCHAR2,
    x_msg_count                                OUT NOCOPY    NUMBER,
    x_msg_data                                 OUT NOCOPY    VARCHAR2
);


END HZ_PERSON_INFO_V2PUB;

 

/
