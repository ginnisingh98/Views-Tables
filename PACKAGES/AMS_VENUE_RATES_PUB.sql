--------------------------------------------------------
--  DDL for Package AMS_VENUE_RATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_VENUE_RATES_PUB" AUTHID CURRENT_USER AS
/* $Header: amspvrts.pls 115.4 2002/11/16 00:48:09 dbiswas ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Venue_Rates_PUB
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
--             venue_rates_rec_type
--   -------------------------------------------------------
--   Parameters:
--       rate_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       active_flag
--       venue_id
--       metric_id
--       transactional_value
--       transactional_currency_code
--       functional_value
--       functional_currency_code
--       uom_code
--       attribute_category
--       attribute1
--       attribute2
--       attribute3
--       attribute4
--       attribute5
--       attribute6
--       attribute7
--       attribute8
--       attribute9
--       attribute10
--       attribute11
--       attribute12
--       attribute13
--       attribute14
--       attribute15
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
TYPE venue_rates_rec_type IS RECORD
(
       rate_id                         NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE   := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE   := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       active_flag                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       venue_id                        NUMBER := FND_API.G_MISS_NUM,
       metric_id                       NUMBER := FND_API.G_MISS_NUM,
       transactional_value             NUMBER := FND_API.G_MISS_NUM,
       transactional_currency_code     VARCHAR2(15)   := FND_API.G_MISS_CHAR,
       functional_value                NUMBER         := FND_API.G_MISS_NUM,
       functional_currency_code        VARCHAR2(15)   := FND_API.G_MISS_CHAR,
       uom_code                        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
       rate_code                       VARCHAR2(30)   := FND_API.G_MISS_CHAR,
       attribute_category              VARCHAR2(30)   := FND_API.G_MISS_CHAR,
       attribute1                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute2                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute3                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute4                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute5                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute6                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute7                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute8                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute9                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute10                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute11                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute12                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute13                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute14                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       attribute15                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
       description                     VARCHAR2(4000) := FND_API.G_MISS_CHAR
);

g_miss_venue_rates_rec          venue_rates_rec_type;
TYPE  venue_rates_tbl_type      IS TABLE OF venue_rates_rec_type INDEX BY BINARY_INTEGER;
g_miss_venue_rates_tbl          venue_rates_tbl_type;

TYPE venue_rates_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      last_update_date   NUMBER := NULL
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Venue_Rates
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_venue_rates_rec            IN   venue_rates_rec_type  Required
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

PROCEDURE Create_Venue_Rates(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_venue_rates_rec               IN   venue_rates_rec_type  := g_miss_venue_rates_rec,
    x_rate_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Venue_Rates
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_venue_rates_rec            IN   venue_rates_rec_type  Required
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

PROCEDURE Update_Venue_Rates(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_venue_rates_rec               IN    venue_rates_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Venue_Rates
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_RATE_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
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

PROCEDURE Delete_Venue_Rates(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_rate_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Venue_Rates
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_venue_rates_rec            IN   venue_rates_rec_type  Required
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

PROCEDURE Lock_Venue_Rates(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_rate_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );

END AMS_Venue_Rates_PUB;

 

/
