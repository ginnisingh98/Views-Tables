--------------------------------------------------------
--  DDL for Package PV_PG_MEMBERSHIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_MEMBERSHIPS_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvmems.pls 120.1 2005/10/24 09:36:43 dgottlie noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Memberships_PVT
-- Purpose
--
-- History
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
--             memb_rec_type
--   -------------------------------------------------------
--   Parameters:
--       membership_id
--       object_version_number
--       partner_id
--       program_id
--       start_date
--       original_end_date
--       actual_end_date
--       membership_status_code
--       status_reason_code
--       enrl_request_id
--       created_by
--       creation_date
--       last_updated_by
--       last_update_date
--       last_update_login
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
TYPE memb_rec_type IS RECORD
(
       membership_id                   NUMBER,
       object_version_number           NUMBER,
       partner_id                      NUMBER,
       program_id                      NUMBER,
       start_date                      DATE,
       original_end_date               DATE,
       actual_end_date                 DATE,
       membership_status_code          VARCHAR2(30),
       status_reason_code              VARCHAR2(30),
       enrl_request_id                 NUMBER,
       created_by                      NUMBER,
       creation_date                   DATE,
       last_updated_by                 NUMBER,
       last_update_date                DATE,
       last_update_login               NUMBER,
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

g_miss_memb_rec          memb_rec_type := NULL;
TYPE  memb_tbl_type      IS TABLE OF memb_rec_type INDEX BY BINARY_INTEGER;
g_miss_memb_tbl          memb_tbl_type;

TYPE NUMBER_TABLE IS TABLE OF NUMBER;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Pg_Memberships
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
--       p_memb_rec            IN   memb_rec_type  Required
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

PROCEDURE Create_Pg_Memberships(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_memb_rec              IN   memb_rec_type  := g_miss_memb_rec,
    x_membership_id              OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Pg_Memberships
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
--       p_memb_rec            IN   memb_rec_type  Required
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

PROCEDURE Update_Pg_Memberships(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_memb_rec               IN    memb_rec_type
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Pg_Memberships
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
--       p_membership_id                IN   NUMBER
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

PROCEDURE Delete_Pg_Memberships(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_membership_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Pg_Memberships
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
--       p_memb_rec            IN   memb_rec_type  Required
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

PROCEDURE Lock_Pg_Memberships(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_membership_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Pg_Memberships
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


PROCEDURE Validate_Pg_Memberships(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_memb_rec               IN   memb_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Memb_Items
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


PROCEDURE Check_Memb_Items (
    P_memb_rec     IN    memb_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Memb_Rec
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


PROCEDURE Validate_Memb_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_memb_rec               IN    memb_rec_type
    );

--------------------------------------------------------------------------
-- PROCEDURE
--   PV_PG_MEMBERSHIPS_PVT.Terminate_ptr_memberships
--
-- PURPOSE
--   Terminate all memberships for a given partner. If the partner is
--   a global partner, terminate all its subsidiary memberships also

--
-- USED BY
--   called from change membership type api and can also be called independently
--   to terminate all partner memberships.
--
-- HISTORY
--           pukken        CREATION
--------------------------------------------------------------------------

PROCEDURE Terminate_ptr_memberships
(
    p_api_version_number         IN   NUMBER
   , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   , p_partner_id                 IN   NUMBER -- partner id for which all memberships need to be terminated
   , p_memb_type                  IN   VARCHAR  -- if not given, will get from profile, should be 'SUBSIDIARY','GLOBAL','STANDARD'
   , p_status_reason_code         IN   VARCHAR2 -- pass 'MEMBER_TYPE_CHANGE' if it is happening because of member type change -- it validates against PV_MEMB_STATUS_REASON_CODE
   , p_comments                   IN   VARCHAR2 DEFAULT NULL -- pass 'Membership terminated by system as member type is changed' if it is changed because of member type change
   , x_return_status              OUT  NOCOPY  VARCHAR2
   , x_msg_count                  OUT  NOCOPY  NUMBER
   , x_msg_data                   OUT  NOCOPY  VARCHAR2
);

--------------------------------------------------------------------------
-- PROCEDURE
--   Terminate_membership
--
-- PURPOSE
--   Terminate a  membership for a given partner. If the partner is
--   a global partner, terminate its appropraite subsidiary memberships also
--
-- USED BY
--
-- HISTORY
--           pukken        CREATION
--------------------------------------------------------------------------
PROCEDURE Terminate_membership
(
   p_api_version_number           IN  NUMBER
   , p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE
   , p_commit                     IN  VARCHAR2 := FND_API.G_FALSE
   , p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   , p_membership_id              IN  NUMBER
   , p_event_code                 IN  VARCHAR2
   , p_memb_type                  IN  VARCHAR
   , p_status_reason_code         IN  VARCHAR2
   , p_comments                   IN  VARCHAR2 DEFAULT NULL
   , x_return_status              OUT NOCOPY   VARCHAR2
   , x_msg_count                  OUT NOCOPY   NUMBER
   , x_msg_data                   OUT NOCOPY   VARCHAR2
);

--------------------------------------------------------------------------
-- PROCEDURE
--   Update_memb_end_date
--
-- PURPOSE

--
-- USED BY
--
-- HISTORY
--           pukken        CREATION
--------------------------------------------------------------------------

PROCEDURE  Update_membership_end_date
(
    p_api_version_number         IN   NUMBER
   , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   , p_membership_id              IN   NUMBER       -- membership_id for which end date needs to be updated
   , p_new_date                   IN   DATE
   , p_comments                   IN   VARCHAR2 DEFAULT NULL
   , x_return_status              OUT  NOCOPY  VARCHAR2
   , x_msg_count                  OUT  NOCOPY  NUMBER
   , x_msg_data                   OUT  NOCOPY  VARCHAR2
);

PROCEDURE downgrade_membership
(
   p_api_version_number          IN    NUMBER
   , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   , p_membership_id              IN   NUMBER   -- membership id of the program that you are dwongrading
   , p_status_reason_code         IN   VARCHAR2 -- reason for termoination or downgrade
   , p_comments                   IN   VARCHAR2 DEFAULT NULL
   , p_program_id_downgraded_to   IN   NUMBER   --programid into which the partner is downgraded to.
   , p_requestor_resource_id      IN   NUMBER   --resource_id of the user who's performing the action
   , x_new_memb_id                OUT  NOCOPY  NUMBER
   , x_return_status              OUT  NOCOPY  VARCHAR2
   , x_msg_count                  OUT  NOCOPY  NUMBER
   , x_msg_data                   OUT  NOCOPY  VARCHAR2
) ;

FUNCTION TERMINATE_PTR_MEMBERSHIPS
  (p_subscription_guid IN RAW,
   p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2;

END PV_Pg_Memberships_PVT;

 

/
