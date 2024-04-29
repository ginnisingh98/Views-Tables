--------------------------------------------------------
--  DDL for Package AMS_CONTACT_POINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CONTACT_POINT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcpts.pls 115.4 2002/11/22 08:55:19 jieli ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CONTACT_POINT_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             contact_point_rec_type
--   -------------------------------------------------------
--   Parameters:
--
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
 G_MISS_CONTENT_SOURCE_TYPE                CONSTANT VARCHAR2(30) := 'USER_ENTERED';

 TYPE contact_point_rec_type IS RECORD (
    contact_point_id                        NUMBER,
    contact_point_type                      VARCHAR2(30),
    status                                  VARCHAR2(30),
    owner_table_name                        VARCHAR2(30),
    owner_table_id                          NUMBER,
    primary_flag                            VARCHAR2(1),
    orig_system_reference                   VARCHAR2(240),
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


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           create_contact_POINT
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ams_contact_pref_rec            IN   ams_contact_pref_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--


PROCEDURE create_contact_POINT(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_contact_point_rec       IN     contact_POINT_rec_type ,
    p_ams_edi_rec                 IN     edi_rec_type := g_miss_edi_rec,
    p_ams_email_rec               IN     email_rec_type := g_miss_email_rec,
    p_ams_phone_rec               IN     phone_rec_type := g_miss_phone_rec,
    p_ams_telex_rec               IN     telex_rec_type := g_miss_telex_rec,
    p_ams_web_rec                 IN     web_rec_type := g_miss_web_rec,

    x_contact_POINT_id      OUT NOCOPY  NUMBER

     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           update_contact_POINT
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ams_contact_point_rec    IN  contact_point_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--


PROCEDURE update_contact_POINT(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_contact_point_rec       IN   contact_POINT_rec_type ,
    p_ams_edi_rec                 IN     edi_rec_type := g_miss_edi_rec,
    p_ams_email_rec               IN     email_rec_type := g_miss_email_rec,
    p_ams_phone_rec               IN     phone_rec_type := g_miss_phone_rec,
    p_ams_telex_rec               IN     telex_rec_type := g_miss_telex_rec,
    p_ams_web_rec                 IN     web_rec_type := g_miss_web_rec,

    px_object_version_number     IN OUT NOCOPY  NUMBER
    );


END AMS_CONTACT_POINT_PVT;

 

/
