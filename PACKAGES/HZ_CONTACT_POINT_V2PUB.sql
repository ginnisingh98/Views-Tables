--------------------------------------------------------
--  DDL for Package HZ_CONTACT_POINT_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CONTACT_POINT_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2CPSS.pls 120.9 2006/08/17 10:14:51 idali ship $ */
/*#
 * This package contains the public APIs for contact points.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Contact Point
 * @rep:category BUSINESS_ENTITY HZ_CONTACT_POINT
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Contact Point APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */

  G_MISS_CONTENT_SOURCE_TYPE                CONSTANT VARCHAR2(30) := 'USER_ENTERED';

  --------------------------------------
  -- declaration of record type
  --------------------------------------

  TYPE contact_point_rec_type IS RECORD (
    contact_point_id                        NUMBER,
    contact_point_type                      VARCHAR2(30),
    status                                  VARCHAR2(30),
    owner_table_name                        VARCHAR2(30),
    owner_table_id                          NUMBER,
    primary_flag                            VARCHAR2(1),
    orig_system_reference                   VARCHAR2(240),
    orig_system				    VARCHAR2(30),
    content_source_type                     VARCHAR2(30) := G_MISS_CONTENT_SOURCE_TYPE,
    attribute_category                      VARCHAR2(30),
    attribute1                              VARCHAR2(150),
    attribute2                              VARCHAR2(150),
    attribute3                              VARCHAR2(150),
    attribute4                              VARCHAR2(150),
    attribute5                              VARCHAR2(150),
    attribute6                              VARCHAR2(150),
    attribute7                              VARCHAR2(150),
    attribute8                              VARCHAR2(150),
    attribute9                              VARCHAR2(150),
    attribute10                             VARCHAR2(150),
    attribute11                             VARCHAR2(150),
    attribute12                             VARCHAR2(150),
    attribute13                             VARCHAR2(150),
    attribute14                             VARCHAR2(150),
    attribute15                             VARCHAR2(150),
    attribute16                             VARCHAR2(150),
    attribute17                             VARCHAR2(150),
    attribute18                             VARCHAR2(150),
    attribute19                             VARCHAR2(150),
    attribute20                             VARCHAR2(150),
    contact_point_purpose                   VARCHAR2(30),
    primary_by_purpose                      VARCHAR2(30),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER,
    actual_content_source                   VARCHAR2(30)
  );

  TYPE edi_rec_type IS RECORD (
    edi_transaction_handling                VARCHAR2(25),
    edi_id_number                           VARCHAR2(30),
    edi_payment_method                      VARCHAR2(30),
    edi_payment_format                      VARCHAR2(30),
    edi_remittance_method                   VARCHAR2(30),
    edi_remittance_instruction              VARCHAR2(30),
    edi_tp_header_id                        NUMBER,
    edi_ece_tp_location_code                VARCHAR2(40)
  );

  g_miss_edi_rec                              edi_rec_type;

  TYPE eft_rec_type IS RECORD (
    eft_transmission_program_id              NUMBER,
    eft_printing_program_id                  NUMBER,
    eft_user_number                          VARCHAR2(30),
    eft_swift_code                           VARCHAR2(30)
  );

  G_MISS_EFT_REC                              eft_rec_type;

  TYPE email_rec_type IS RECORD (
    email_format                            VARCHAR2(30),
    email_address                           VARCHAR2(2000)
  );

  g_miss_email_rec                            email_rec_type;

  TYPE phone_rec_type IS RECORD (
    phone_calling_calendar                  VARCHAR2(30),
    last_contact_dt_time                    DATE,
    timezone_id                             NUMBER,
    phone_area_code                         VARCHAR2(10),
    phone_country_code                      VARCHAR2(10),
    phone_number                            VARCHAR2(40),
    phone_extension                         VARCHAR2(20),
    phone_line_type                         VARCHAR2(30),
    raw_phone_number                        VARCHAR2(60)
  );

  g_miss_phone_rec                            phone_rec_type;

  TYPE telex_rec_type IS RECORD (
    telex_number                            VARCHAR2(50)
  );

  g_miss_telex_rec                            telex_rec_type;

  TYPE web_rec_type IS RECORD (
    web_type                                VARCHAR2(60),
    url                                     VARCHAR2(2000)
  );

  g_miss_web_rec                              web_rec_type;

  --------------------------------------
  -- declaration of public procedures and functions
  --------------------------------------

  --
  -- PROCEDURE create_contact_point
  --
  -- DESCRIPTION
  --     Creates a contact point.  Still here for backward compatibility.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_contact_point_rec  Contact point record.
  --     p_edi_rec            EDI record.
  --     p_email_rec          Email record.
  --     p_phone_rec          Phone record.
  --     p_telex_rec          Telex record.
  --     p_web_rec            Web record.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_id   Contact point ID.
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
  --   07-23-2001    Jianying Huang      Created.
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

/*#
 * Use this routine to create a contact point for a party or a party site. The supported
 * types of contact points are PHONE, PAGER, EMAIL, TELEX, WEB, EFT, and EDI. This routine
 * creates a record in the HZ_CONTACT_POINTS table. Each contact point type has a
 * corresponding API. You must call the relevant interface and pass the corresponding
 * record, which depends on the type of contact point that you create. You should use the
 * contact type-dependent APIs. The Create Contact Point API, a generic API, is available,
 * but the generic API does not handle EFT contact points or any future contact point
 * types. The Create Contact Point API requires that you pass the appropriate record along
 * with the proper contact point type for the contact point that you need to create. If
 * orig_system is passed in, then the API also creates a record in the
 * HZ_ORIG_SYS_REFERENCES table to store the mapping between the source system
 * reference and the TCA primary key. If timezone_id is not passed in, then the API
 * generates a time zone value based on the phone components and time zone setup. However,
 * if the user passes in the time zone, then the API retains that time zone value.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Contact Point
 * @rep:businessevent oracle.apps.ar.hz.ContactPoint.create
 * @rep:doccd 120hztig.pdf Contact Point APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_contact_point (
    p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec           IN     contact_point_rec_type,
    p_edi_rec                     IN     edi_rec_type := g_miss_edi_rec,
    p_email_rec                   IN     email_rec_type := g_miss_email_rec,
    p_phone_rec                   IN     phone_rec_type := g_miss_phone_rec,
    p_telex_rec                   IN     telex_rec_type := g_miss_telex_rec,
    p_web_rec                     IN     web_rec_type := g_miss_web_rec,
    x_contact_point_id            OUT NOCOPY    NUMBER,
    x_return_status               OUT NOCOPY    VARCHAR2,
    x_msg_count                   OUT NOCOPY    NUMBER,
    x_msg_data                    OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE create_edi_contact_point
  --
  -- DESCRIPTION
  --     Creates an EDI contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_contact_point_rec  Contact point record.
  --     p_edi_rec            EDI record.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_id   Contact point ID.
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
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added to support
  --                                     enhanced backward compatibility.
  --

  PROCEDURE create_edi_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_edi_rec                   IN     edi_rec_type := g_miss_edi_rec,
    x_contact_point_id          OUT NOCOPY    NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE create_web_contact_point
  --
  -- DESCRIPTION
  --     Creates a Web contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_contact_point_rec  Contact point record.
  --     p_web_rec            Web record.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_id   Contact point ID.
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
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

  PROCEDURE create_web_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_web_rec                   IN     web_rec_type := g_miss_web_rec,
    x_contact_point_id          OUT NOCOPY    NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE create_eft_contact_point
  --
  -- DESCRIPTION
  --     Creates an EFT contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_contact_point_rec  Contact point record.
  --     p_eft_rec            EFT record.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_id   Contact point ID.
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
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --                                     Bug 2100992: Added for bank
  --                                     consolidation support.
  --

  PROCEDURE create_eft_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_eft_rec                   IN     eft_rec_type := g_miss_eft_rec,
    x_contact_point_id          OUT NOCOPY    NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE create_phone_contact_point
  --
  -- DESCRIPTION
  --     Creates a phone contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_contact_point_rec  Contact point record.
  --     p_phone_rec          Phone record.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_id   Contact point ID.
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
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

  PROCEDURE create_phone_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_phone_rec                 IN     phone_rec_type := g_miss_phone_rec,
    x_contact_point_id          OUT NOCOPY    NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE create_telex_contact_point
  --
  -- DESCRIPTION
  --     Creates a telex contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_contact_point_rec  Contact point record.
  --     p_telex_rec          Telex record.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_id   Contact point ID.
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
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

  PROCEDURE create_telex_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_telex_rec                 IN     telex_rec_type := g_miss_telex_rec,
    x_contact_point_id          OUT NOCOPY    NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE create_email_contact_point
  --
  -- DESCRIPTION
  --     Creates a email contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_contact_point_rec  Contact point record.
  --     p_email_rec          Email record.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_id   Contact point ID.
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
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

  PROCEDURE create_email_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_email_rec                 IN     email_rec_type := g_miss_email_rec,
    x_contact_point_id          OUT NOCOPY    NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PRIVATE PROCEDURE update_contact_point
  --
  -- DESCRIPTION
  --     Updates the given contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list          Initialize message stack if it is set to
  --                              FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_rec      Contact point record.
  --     p_edi_rec                EDI record.
  --     p_email_rec              Email record.
  --     p_phone_rec              Phone record.
  --     p_telex_rec              Telex record.
  --     p_web_rec                Web record.
  --   IN/OUT:
  --     p_object_version_number  Used for locking the being updated record.
  --   OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be fnd_api.g_ret_sts_success (success),
  --                              fnd_api.g_ret_sts_error (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count              Number of messages in message stack.
  --     x_msg_data               Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      Created.
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

/*#
 * Use this routine to update a contact point for a party or a party site. The supported
 * types of contact points are PHONE, PAGER, EMAIL, TELEX, WEB, EFT, and EDI. This API
 * updates records in the HZ_CONTACT_POINTS table. Each contact point type has a
 * corresponding API. You must call the relevant interface and pass the corresponding
 * record, which depends on the type of contact point you create.You should use the
 * contact type-dependent APIs. The Update Contact Point, a generic API, is available, but
 * the generic API does not handle EFT contact points or any future contact point types.
 * The Update Contact Point API requires that you pass the appropriate record along with
 * the proper contact point type for the contact point that you need to create.If the
 * primary key is not passed in, get the primary key from the HZ_ORIG_SYS_REFERENCES table
 * based on orig_system and orig_system_reference if they are not null and unique. If
 * timezone_id is not passed in, then the API generates a time zone value based on the
 * changes of the phone components and time zone setup, even if a time zone already exists
 * in the database. However, if the user passes in the time zone, then the API retains
 * that time zone value.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Contact Point
 * @rep:businessevent oracle.apps.ar.hz.ContactPoint.update
 * @rep:doccd 120hztig.pdf Contact Point APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_contact_point (
    p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec           IN     contact_point_rec_type,
    p_edi_rec                     IN     edi_rec_type := g_miss_edi_rec,
    p_email_rec                   IN     email_rec_type := g_miss_email_rec,
    p_phone_rec                   IN     phone_rec_type := g_miss_phone_rec,
    p_telex_rec                   IN     telex_rec_type := g_miss_telex_rec,
    p_web_rec                     IN     web_rec_type := g_miss_web_rec,
    p_object_version_number       IN OUT NOCOPY NUMBER,
    x_return_status               OUT NOCOPY    VARCHAR2,
    x_msg_count                   OUT NOCOPY    NUMBER,
    x_msg_data                    OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE update_edi_contact_point
  --
  -- DESCRIPTION
  --     Updates the given EDI contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list          Initialize message stack if it is set to
  --                              FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_rec      Contact point record.
  --     p_edi_rec                EDI record.
  --   IN/OUT:
  --     p_object_version_number  Used for locking the being updated record.
  --   OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be fnd_api.g_ret_sts_success (success),
  --                              fnd_api.g_ret_sts_error (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count              Number of messages in message stack.
  --     x_msg_data               Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added to support
  --                                     enhanced backward compatibility.
  --

  PROCEDURE update_edi_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_edi_rec                   IN     edi_rec_type := g_miss_edi_rec,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE update_web_contact_point
  --
  -- DESCRIPTION
  --     Updates the given Web contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list          Initialize message stack if it is set to
  --                              FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_rec      Contact point record.
  --     p_web_rec                WEB record.
  --   IN/OUT:
  --     p_object_version_number  Used for locking the being updated record.
  --   OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be fnd_api.g_ret_sts_success (success),
  --                              fnd_api.g_ret_sts_error (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count              Number of messages in message stack.
  --     x_msg_data               Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added to support
  --                                     enhanced backward compatibility.
  --

  PROCEDURE update_web_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_web_rec                   IN     web_rec_type := g_miss_web_rec,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE update_eft_contact_point
  --
  -- DESCRIPTION
  --     Updates the given EFT contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list          Initialize message stack if it is set to
  --                              FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_rec      Contact point record.
  --     p_eft_rec                EFT record.
  --   IN/OUT:
  --     p_object_version_number  Used for locking the being updated record.
  --   OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be fnd_api.g_ret_sts_success (success),
  --                              fnd_api.g_ret_sts_error (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count              Number of messages in message stack.
  --     x_msg_data               Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   19-NOV-2001   Joe del Callar      Bug 2116225: Added to support
  --                                     Bank Consolidation.
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added to support
  --                                     enhanced backward compatibility.
  --

  PROCEDURE update_eft_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_eft_rec                   IN     eft_rec_type := g_miss_eft_rec,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE update_phone_contact_point
  --
  -- DESCRIPTION
  --     Updates the given phone contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list          Initialize message stack if it is set to
  --                              FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_rec      Contact point record.
  --     p_phone_rec              Phone record.
  --   IN/OUT:
  --     p_object_version_number  Used for locking the being updated record.
  --   OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be fnd_api.g_ret_sts_success (success),
  --                              fnd_api.g_ret_sts_error (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count              Number of messages in message stack.
  --     x_msg_data               Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added to support
  --                                     enhanced backward compatibility.
  --

  PROCEDURE update_phone_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_phone_rec                   IN     phone_rec_type := g_miss_phone_rec,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE update_telex_contact_point
  --
  -- DESCRIPTION
  --     Updates the given telex contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list          Initialize message stack if it is set to
  --                              FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_rec      Contact point record.
  --     p_telex_rec              Telex record.
  --   IN/OUT:
  --     p_object_version_number  Used for locking the being updated record.
  --   OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be fnd_api.g_ret_sts_success (success),
  --                              fnd_api.g_ret_sts_error (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count              Number of messages in message stack.
  --     x_msg_data               Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added to support
  --                                     enhanced backward compatibility.
  --

  PROCEDURE update_telex_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_telex_rec                   IN     telex_rec_type := g_miss_telex_rec,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE update_email_contact_point
  --
  -- DESCRIPTION
  --     Updates the given email contact point.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list          Initialize message stack if it is set to
  --                              FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_rec      Contact point record.
  --     p_email_rec              Email record.
  --   IN/OUT:
  --     p_object_version_number  Used for locking the being updated record.
  --   OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be fnd_api.g_ret_sts_success (success),
  --                              fnd_api.g_ret_sts_error (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count              Number of messages in message stack.
  --     x_msg_data               Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added to support
  --                                     enhanced backward compatibility.
  --

  PROCEDURE update_email_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec         IN     contact_point_rec_type,
    p_email_rec                 IN     email_rec_type := g_miss_email_rec,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE get_contact_point_rec
  --
  -- DESCRIPTION
  --     Cets contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list          Initialize message stack if it is set to
  --                              fnd_api.g_true. Default is fnd_api.g_false.
  --     p_contact_point_id       Contact point ID.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_rec      Returned contact point record.
  --     x_edi_rec                Returned EDI record.
  --     x_email_rec              Returned email record.
  --     x_phone_rec              Returned phone record.
  --     x_telex_rec              Returned telex record.
  --     x_web_rec                Returned web record.
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected
  --                              error).
  --     x_msg_count              Number of messages in message stack.
  --     x_msg_data               Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      o Created.
  --   19-NOV-2001   Joe del Callar      Bug 2116225: Added support for
  --                                     Bank Consolidation.
  --
  --

  PROCEDURE get_contact_point_rec (
    p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_id            IN     NUMBER,
    x_contact_point_rec           OUT    NOCOPY contact_point_rec_type,
    x_edi_rec                     OUT    NOCOPY edi_rec_type,
    x_email_rec                   OUT    NOCOPY email_rec_type,
    x_phone_rec                   OUT    NOCOPY phone_rec_type,
    x_telex_rec                   OUT    NOCOPY telex_rec_type,
    x_web_rec                     OUT    NOCOPY web_rec_type,
    x_return_status               OUT NOCOPY    VARCHAR2,
    x_msg_count                   OUT NOCOPY    NUMBER,
    x_msg_data                    OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE get_edi_contact_point
  --
  -- DESCRIPTION
  --     Gets EDI contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_id   Contact point ID.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_rec  Returned contact point record.
  --     x_edi_rec            Returned EDI record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          fnd_api.g_ret_sts_unexp_error (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      o Created.
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

  PROCEDURE get_edi_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_id          IN     NUMBER,
    x_contact_point_rec         OUT    NOCOPY contact_point_rec_type,
    x_edi_rec                   OUT    NOCOPY edi_rec_type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE get_eft_contact_point
  --
  -- DESCRIPTION
  --     Gets EFT contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_id   Contact point ID.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_rec  Returned contact point record.
  --     x_eft_rec            Returned EFT record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          fnd_api.g_ret_sts_unexp_error (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      o Created.
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

  PROCEDURE get_eft_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_id          IN     NUMBER,
    x_contact_point_rec         OUT    NOCOPY contact_point_rec_type,
    x_eft_rec                   OUT    NOCOPY eft_rec_type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE get_web_contact_point
  --
  -- DESCRIPTION
  --     Gets Web contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_id   Contact point ID.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_rec  Returned contact point record.
  --     x_web_rec            Returned Web record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          fnd_api.g_ret_sts_unexp_error (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      o Created.
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

  PROCEDURE get_web_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_id          IN     NUMBER,
    x_contact_point_rec         OUT    NOCOPY contact_point_rec_type,
    x_web_rec                   OUT    NOCOPY web_rec_type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE get_phone_contact_point
  --
  -- DESCRIPTION
  --     Gets phone contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_id   Contact point ID.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_rec  Returned contact point record.
  --     x_phone_rec          Returned phone record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          fnd_api.g_ret_sts_unexp_error (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      o Created.
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

  PROCEDURE get_phone_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_id          IN     NUMBER,
    x_contact_point_rec         OUT    NOCOPY contact_point_rec_type,
    x_phone_rec                   OUT    NOCOPY phone_rec_type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE get_telex_contact_point
  --
  -- DESCRIPTION
  --     Gets telex contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_id   Contact point ID.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_rec  Returned contact point record.
  --     x_telex_rec          Returned telex record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          fnd_api.g_ret_sts_unexp_error (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      o Created.
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

  PROCEDURE get_telex_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_id          IN     NUMBER,
    x_contact_point_rec         OUT    NOCOPY contact_point_rec_type,
    x_telex_rec                   OUT    NOCOPY telex_rec_type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE get_email_contact_point
  --
  -- DESCRIPTION
  --     Gets email contact point record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is fnd_api.g_false.
  --     p_contact_point_id   Contact point ID.
  --   IN/OUT:
  --   OUT:
  --     x_contact_point_rec  Returned contact point record.
  --     x_email_rec          Returned email record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          fnd_api.g_ret_sts_unexp_error (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      o Created.
  --   04-DEC-2001   Joe del Callar      Bug 2136283: Added support for
  --                                     enhanced backward compatibility.
  --

  PROCEDURE get_email_contact_point (
    p_init_msg_list             IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_id          IN     NUMBER,
    x_contact_point_rec         OUT    NOCOPY contact_point_rec_type,
    x_email_rec                   OUT    NOCOPY email_rec_type,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
  );

  --
  -- PROCEDURE phone_format
  --
  -- DESCRIPTION
  --      formats a phone number
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list          Initialize message stack if it is set to
  --                              fnd_api.g_true.  Default is fnd_api.g_false.
  --     p_raw_phone_number       Raw phone number.
  --     p_territory_code         Territory code.
  --   IN/OUT:
  --     x_phone_country_code     Phone country code.
  --     x_phone_area_code        Phone area code.
  --     x_phone_number           Phone number.
  --   OUT:
  --     x_formatted_phone_number Formatted phone number.
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected
  --                              error).
  --     x_msg_count              Number of messages in message stack.
  --     x_msg_data               Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   07-23-2001    Jianying Huang      o Created.
  --

  PROCEDURE phone_format (
    p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false,
    p_raw_phone_number            IN     VARCHAR2 := fnd_api.g_miss_char,
    p_territory_code              IN     VARCHAR2 := fnd_api.g_miss_char,
    x_formatted_phone_number      OUT NOCOPY    VARCHAR2,
    x_phone_country_code          IN OUT NOCOPY VARCHAR2,
    x_phone_area_code             IN OUT NOCOPY VARCHAR2,
    x_phone_number                IN OUT NOCOPY VARCHAR2,
    x_return_status               OUT NOCOPY    VARCHAR2,
    x_msg_count                   OUT NOCOPY    NUMBER,
    x_msg_data                    OUT NOCOPY    VARCHAR2
  );

END hz_contact_point_v2pub;

 

/
