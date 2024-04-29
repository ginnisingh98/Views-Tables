--------------------------------------------------------
--  DDL for Package PV_PG_ENRL_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_ENRL_REQUESTS_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvpers.pls 120.2 2005/10/24 08:31:35 dgottlie ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Enrl_Requests_PVT
-- Purpose
--
-- History
--          20-OCT-2002    Karen.Tsao      Created
--          27-NOV-2002    Karen.Tsao      1. Modified to change datatype for order_header_id.
--                                         2. Debug message to be wrapped with IF check.
--                                         3. Replace of COPY with NOCOPY string.
--          27-AUG-2003    Karen.Tsao      Update the enrl_request_rec_type with two new columns in
--                                         pv_pg_enrl_requests: membership_fee, transactional_curr_code
--          29-AUG-2003    Karen.Tsao      Modified for column name change: transactional_curr_code to trans_curr_code
--          26-SEP-2003    pukken	       Added dependent_program_id column in  pv_pg_enrl_requests record
--          20-APR-2005    Karen.Tsao      Modified for R12.
--	    05-JUL-2005    kvattiku	   Added trxn_extension_id column in  pv_pg_enrl_requests record
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             enrl_request_rec_type
--   -------------------------------------------------------
--   Parameters:
--       enrl_request_id
--       object_version_number
--       program_id
--       partner_id
--       custom_setup_id
--       requestor_resource_id
--       request_status_code
--       enrollment_type_code
--       request_submission_date
--       contract_id
--       request_initiated_by_code
--       invite_header_id
--       tentative_start_date
--       tentative_end_date
--       contract_status_code
--       payment_status_code
--       score_result_code
--       created_by
--       creation_date
--       last_updated_by
--       last_update_date
--       last_update_login
--       order_header_id
--       membership_fee
--       dependent_program_id
--       trans_curr_code
--       contract_binding_contact_id
--       contract_signed_date
--       trxn_extension_id
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
TYPE enrl_request_rec_type IS RECORD
(
       enrl_request_id                 NUMBER,
       object_version_number           NUMBER,
       program_id                      NUMBER,
       partner_id                      NUMBER,
       custom_setup_id                 NUMBER,
       requestor_resource_id           NUMBER,
       request_status_code             VARCHAR2(30),
       enrollment_type_code            VARCHAR2(30),
       request_submission_date         DATE,
       contract_id                     NUMBER,
       request_initiated_by_code       VARCHAR2(30),
       invite_header_id                NUMBER,
       tentative_start_date            DATE,
       tentative_end_date              DATE,
       contract_status_code            VARCHAR2(30),
       payment_status_code             VARCHAR2(30),
       score_result_code               VARCHAR2(30),
       created_by                      NUMBER,
       creation_date                   DATE,
       last_updated_by                 NUMBER,
       last_update_date                DATE,
       last_update_login               NUMBER,
       order_header_id                 NUMBER,
       membership_fee                  NUMBER,
       dependent_program_id            NUMBER,
       trans_curr_code                 VARCHAR2(15),
       contract_binding_contact_id     NUMBER,
       contract_signed_date            DATE,
       trxn_extension_id	       NUMBER,
       attribute1		       VARCHAR2(240),
       attribute2		       VARCHAR2(240),
       attribute3		       VARCHAR2(240),
       attribute4		       VARCHAR2(240),
       attribute5		       VARCHAR2(240),
       attribute6		       VARCHAR2(240),
       attribute7		       VARCHAR2(240),
       attribute8		       VARCHAR2(240),
       attribute9		       VARCHAR2(240),
       attribute10		       VARCHAR2(240),
       attribute11		       VARCHAR2(240),
       attribute12		       VARCHAR2(240),
       attribute13		       VARCHAR2(240),
       attribute14		       VARCHAR2(240),
       attribute15		       VARCHAR2(240)
);

g_miss_enrl_request_rec          enrl_request_rec_type := NULL;
TYPE  enrl_request_tbl_type      IS TABLE OF enrl_request_rec_type INDEX BY BINARY_INTEGER;
g_miss_enrl_request_tbl          enrl_request_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Pg_Enrl_Requests
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
--       p_enrl_request_rec            IN   enrl_request_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Pg_Enrl_Requests(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrl_request_rec              IN   enrl_request_rec_type  := g_miss_enrl_request_rec,
    x_enrl_request_id              OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Pg_Enrl_Requests
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
--       p_enrl_request_rec            IN   enrl_request_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Pg_Enrl_Requests(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrl_request_rec               IN    enrl_request_rec_type
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Pg_Enrl_Requests
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
--       p_enrl_request_id                IN   NUMBER
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
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Pg_Enrl_Requests(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_enrl_request_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Pg_Enrl_Requests
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
--       p_enrl_request_rec            IN   enrl_request_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Pg_Enrl_Requests(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrl_request_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Pg_Enrl_Requests
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in PV_UTILITY_PVT package
--           For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--           2. We can also validate table instead of record. There will be an option for user to choose.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================


PROCEDURE Validate_Pg_Enrl_Requests(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_enrl_request_rec               IN   enrl_request_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Enrl_Request_Items
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in PV_UTILITY_PVT package
--           For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--           2. Validate the unique keys, lookups here
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================


PROCEDURE Check_Enrl_Request_Items (
    P_enrl_request_rec     IN    enrl_request_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Enrl_Request_Rec
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in PV_UTILITY_PVT package
--           For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--           2. Developer can manually added inter-field level validation.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================


PROCEDURE Validate_Enrl_Request_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_enrl_request_rec               IN    enrl_request_rec_type
    );

END PV_Pg_Enrl_Requests_PVT;

 

/
