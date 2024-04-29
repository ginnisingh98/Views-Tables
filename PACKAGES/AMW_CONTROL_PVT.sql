--------------------------------------------------------
--  DDL for Package AMW_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_CONTROL_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvctls.pls 120.2.12010000.1 2008/07/28 08:35:50 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_Control_PVT
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

G_FALSE VARCHAr2(1) := FND_API.G_FALSE;
G_TRUE VARCHAr2(1) := FND_API.G_TRUE;

--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             control_rec_type
--   -------------------------------------------------------
--   Parameters:
--       control_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       control_type
--       category
--       attribute_category
--       source
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
--       security_group_id
--       control_location
--       automation_type
--       application_id
--       job_id
--       object_version_number
--       control_rev_id
--       rev_num
--       end_date
--       approval_status
--       approval_date
--       requestor_id
--       created_by_module
--       curr_approved_flag
--       latest_revision_flag
--       orig_system_reference
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
/*TYPE control_rec_type IS RECORD
(
       control_id                      NUMBER ,
       last_update_date                DATE ,
       last_updated_by                 NUMBER ,
       creation_date                   DATE ,
       created_by                      NUMBER ,
       last_update_login               NUMBER ,
       control_type                    VARCHAR2(30) ,
       category                        VARCHAR2(30) ,
       attribute_category              VARCHAR2(30) ,
       source                          VARCHAR2(30) ,
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
       security_group_id               NUMBER ,
       control_location                VARCHAR2(30) ,
       automation_type                 VARCHAR2(30) ,
       application_id                  NUMBER ,
       job_id                          NUMBER ,
       object_version_number           NUMBER ,
       control_rev_id                  NUMBER ,
       rev_num                         NUMBER ,
       end_date                        DATE ,
       approval_status                 VARCHAR2(30) ,
       approval_date                   DATE ,
       requestor_id                    NUMBER ,
       created_by_module               VARCHAR2(150) ,
       curr_approved_flag              VARCHAR2(1) ,
       latest_revision_flag            VARCHAR2(1) ,
       orig_system_reference           VARCHAR2(240) ,
	   name							   VARCHAR2(240) := null,
	   description					   varchar2(4000) := null,
	   language						   varchar2(4) := null,
	   source_lang					   varchar2(4) := null,
	   physical_evidence			   varchar2(240) := null
);
*/
TYPE control_rec_type IS RECORD
(
       control_id                      NUMBER := null,
       last_update_date                DATE := null ,
       last_updated_by                 NUMBER := null ,
       creation_date                   DATE := null ,
       created_by                      NUMBER := null ,
       last_update_login               NUMBER := null ,
       control_type                    VARCHAR2(30)  := null,
       category                        VARCHAR2(30)  := null,
       attribute_category              VARCHAR2(30)  := null,
       /*03.20.2007 npanandi: bug 4492239 fix -- increased the length of controlSource,
         to 240, to make it consistent with length of AmwControlsB.Source*/
       source                          VARCHAR2(240)  := null,
       attribute1                      VARCHAR2(150)  := null,
       attribute2                      VARCHAR2(150)  := null,
       attribute3                      VARCHAR2(150)  := null,
       attribute4                      VARCHAR2(150)  := null,
       attribute5                      VARCHAR2(150)  := null,
       attribute6                      VARCHAR2(150)  := null,
       attribute7                      VARCHAR2(150)  := null,
       attribute8                      VARCHAR2(150)  := null,
       attribute9                      VARCHAR2(150)  := null,
       attribute10                     VARCHAR2(150)  := null,
       attribute11                     VARCHAR2(150)  := null,
       attribute12                     VARCHAR2(150)  := null,
       attribute13                     VARCHAR2(150)  := null,
       attribute14                     VARCHAR2(150)  := null,
       attribute15                     VARCHAR2(150)  := null,
       security_group_id               NUMBER  := null,
       control_location                VARCHAR2(30)  := null,
       automation_type                 VARCHAR2(30)  := null,
       application_id                  NUMBER  := null,
       job_id                          NUMBER  := null,
       object_version_number           NUMBER  := null,
       control_rev_id                  NUMBER  := null,
       rev_num                         NUMBER  := null,
       end_date                        DATE  := null,
       approval_status                 VARCHAR2(30)  := null,
       approval_date                   DATE  := null,
       requestor_id                    NUMBER  := null,
       created_by_module               VARCHAR2(150)  := null,
       curr_approved_flag              VARCHAR2(1)  := null,
       latest_revision_flag            VARCHAR2(1)  := null,
       orig_system_reference           VARCHAR2(240)  := null,
	   name							   VARCHAR2(240)  := null,
	   description					   varchar2(4000) := null,
	   language						   varchar2(4)  := null,
	   source_lang					   varchar2(4)  := null,
	   physical_evidence			   varchar2(240)  := null,
	   preventive_control			   varchar2(1)	  := null,
	   detective_control			   varchar2(1)	  := null,
	   disclosure_control			   varchar2(1)	  := null,
	   key_mitigating			   	   varchar2(1)	  := null,
	   verification_source			   varchar2(1)	  := null,
	   verification_source_name		   varchar2(240)  := null,
	   verification_instruction		   varchar2(2000)  := null,
	   --- NPANANDI 04.08,2005: changed the length of uom_code column
	   ---below -- bug 4283757 fix
	   UOM_CODE						   VARCHAR2(30)    DEFAULT NULL
	  ,CONTROL_FREQUENCY			   NUMBER DEFAULT NULL
	  --NPANANDI 12.10.2004: ADDED BELOW FOR CTRL CLASSIFICATION
	  ,CLASSIFICATION		 	   	   NUMBER DEFAULT NULL
);

g_control_rec          	control_rec_type;
TYPE  control_tbl_type      IS TABLE OF control_rec_type INDEX BY BINARY_INTEGER;
g_control_tbl          	control_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Load_Control
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_control_rec            IN   control_rec_type  Required
--		 p_load_control_mode      IN    VARCHAR2    Required
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
/*
PROCEDURE Load1_Control(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT  nocopy VARCHAR2,
    x_msg_count                  OUT  nocopy NUMBER,
    x_msg_data                   OUT  nocopy VARCHAR2,

    x_create_control_rev_id      out nocopy number,
    x_update_control_rev_id      out nocopy number,
    x_revise_control_rev_id      out nocopy number,
    x_mode_affected              out nocopy varchar2,

    p_control_rec               IN   control_rec_type,
    ----p_load_control_mode         IN VARCHAR2,
	p_party_id                  in number
    );
	*/
	procedure load_Control(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2  := G_FALSE,
    p_commit                     IN   VARCHAR2  := G_FALSE,
    p_validation_level           IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT  nocopy VARCHAR2,
    x_msg_count                  OUT  nocopy NUMBER,
    x_msg_data                   OUT  nocopy VARCHAR2,

    ---x_create_control_rev_id      out number,
    ---x_update_control_rev_id      out number,
    ---x_revision_control_rev_id    out number,
	x_control_rev_id			 out nocopy number,
	x_control_id				 out nocopy number,
    x_mode_affected              out nocopy varchar2,

    p_control_rec               IN   control_rec_type ----- := g_miss_control_rec,
    -----p_load_control_mode         IN VARCHAR2,
	-----p_party_id					in number
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Control
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_control_rec            IN   control_rec_type  Required
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

PROCEDURE Create_Control(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT  nocopy VARCHAR2,
    x_msg_count                  OUT  nocopy NUMBER,
    x_msg_data                   OUT  nocopy VARCHAR2,

    ---p_control_rec               IN   control_rec_type  := g_miss_control_rec,
	p_control_rec               IN   control_rec_type, ---- := g_miss_control_rec,
    x_control_rev_id                   OUT  nocopy NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Control
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_control_rec            IN   control_rec_type  Required
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

PROCEDURE Update_Control(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT  nocopy VARCHAR2,
    x_msg_count                  OUT  nocopy NUMBER,
    x_msg_data                   OUT  nocopy VARCHAR2,

    p_control_rec               IN    control_rec_type,
    x_object_version_number      OUT  nocopy NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Control
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_CONTROL_REV_ID                IN   NUMBER
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

PROCEDURE Delete_Control(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT  nocopy VARCHAR2,
    x_msg_count                  OUT  nocopy NUMBER,
    x_msg_data                   OUT  nocopy VARCHAR2,
    p_control_rev_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Control
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_control_rec            IN   control_rec_type  Required
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

PROCEDURE Lock_Control(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  nocopy VARCHAR2,
    x_msg_count                  OUT  nocopy NUMBER,
    x_msg_data                   OUT  nocopy VARCHAR2,

    p_control_rev_id             IN  NUMBER,
    p_object_version             IN  NUMBER
    );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_control(
    p_mode 				   		 in varchar2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_control_rec                IN  out nocopy control_rec_type,
    x_return_status              OUT  nocopy VARCHAR2,
    x_msg_count                  OUT  nocopy NUMBER,
    x_msg_data                   OUT  nocopy VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_control_Items (
    P_control_rec     IN    control_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT   nocopy VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_control_rec(
    p_mode					     in   varchar2     := 'CREATE',
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT  nocopy VARCHAR2,
    x_msg_count                  OUT  nocopy NUMBER,
    x_msg_data                   OUT  nocopy VARCHAR2,
    p_control_rec               IN    control_rec_type
    );
END AMW_Control_PVT;

/
