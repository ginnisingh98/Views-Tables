--------------------------------------------------------
--  DDL for Package PV_PARTNER_PROGRAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_PROGRAM_PVT" AUTHID CURRENT_USER as
/* $Header: pvxvprgs.pls 120.0 2005/05/27 16:17:58 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Partner_Program_PVT
-- Purpose
--
-- History
--         28-FEB-2002    Ravi.Mikkilineni     Created
--          1-APR-2002    Peter.Nixon          Modified
--                   -    MEMBERSHIP columns (4) made nullable
--                   -    removed SOURCE_LANG column
--         22-APR-2002    Peter.Nixon          Modified
--                   -    restored SOURCE_LANG column
--                   -    removed PROGRAM_SHORT_NAME column
--                   -    changed PROGRAM_SETUP_TYPE column to PROGRAM_TYPE_ID
--                   -    added CUSTOM_SETUP_ID column
--                   -    added ENABLED_FLAG column
--                   -    added ATTRIBUTE_CATEGORY column
--                   -    added ATTRIBUTE1 thru ATTRIBUTE15 columns
--       09-Sep-2002 -    added columns  inventory_item_id ,inventory_item_org_id,
--                        bus_user_resp_id ,admin_resp_id,no_fee_flag,qsnr_ttl_all_page_dsp_flag  ,
--                        qsnr_hdr_all_page_dsp_flag ,qsnr_ftr_all_page_dsp_flag ,allow_enrl_wout_chklst_flag,
--                        qsnr_title ,qsnr_header,qsnr_footer
--      10-Sep-2002 -     removed columns membership_fees and membership_currency_names
--   12/04/2002  SVEERAVE  added Close_Ended_programs that will close the ended programs.
--   12/04/2002  SVEERAVE  added check_price_exists function.
--   01/21/2003  SVEERAVE  added Get_Object_Name procedure for integration with OCM
--   06/27/2003  pukken    Code changes for 3 new columns for 11.5.10 enhancements
--   07/24/2003  ktsao     Code changes for program copy functionality
--   04/11/2005  ktsao     Code changes for create_inv_item_if_not_exists
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
--   -------------------------------------------------------
--    Record name
--             ptr_prgm_rec_type
--   -------------------------------------------------------
--   Parameters:
--       program_id
--       PROGRAM_TYPE_ID
--       custom_setup_id
--       program_level_code
--       program_parent_id
--       program_owner_resource_id
--       program_start_date
--       program_end_date
--       allow_enrl_until_date
--       citem_version_id
--       membership_valid_period
--       membership_period_unit
--       process_rule_id
--       prereq_process_rule_Id
--       program_status_code
--       submit_child_nodes
--       inventory_item_id
--       inventory_item_org_id
--       bus_user_resp_id
--       admin_resp_id
--       no_fee_flag
--       vad_invite_allow_flag
--       global_mmbr_reqd_flag
--       waive_subsidiary_fee_flag
--       qsnr_ttl_all_page_dsp_flag
--       qsnr_hdr_all_page_dsp_flag
--       qsnr_ftr_all_page_dsp_flag
--       allow_enrl_wout_chklst_flag
--       user_status_id
--       enabled_flag
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
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       program_name
--       program_description
--       source_lang
--       qsnr_title
--       qsnr_header
--       qsnr_footer
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
TYPE ptr_prgm_rec_type IS RECORD
(

        program_id                      NUMBER
       ,PROGRAM_TYPE_ID           NUMBER
       ,custom_setup_id                 NUMBER
       ,program_level_code              VARCHAR2(15)
       ,program_parent_id               NUMBER
       ,program_owner_resource_id       NUMBER
       ,program_start_date              DATE
       ,program_end_date                DATE
       ,allow_enrl_until_date           DATE
       ,citem_version_id                NUMBER
       ,membership_valid_period         NUMBER
       ,membership_period_unit          VARCHAR2(30)
       ,process_rule_id                 NUMBER
       ,prereq_process_rule_Id                 NUMBER
       ,program_status_code             VARCHAR2(30)
       ,submit_child_nodes              VARCHAR2(1)
       ,inventory_item_id               NUMBER
       ,inventory_item_org_id           NUMBER
       ,bus_user_resp_id                NUMBER
       ,admin_resp_id                   NUMBER
       ,no_fee_flag                     VARCHAR2(1)
       ,vad_invite_allow_flag           VARCHAR2(1)
       ,global_mmbr_reqd_flag           VARCHAR2(1)
       ,waive_subsidiary_fee_flag       VARCHAR2(1)
       ,qsnr_ttl_all_page_dsp_flag     VARCHAR2(1)
       ,qsnr_hdr_all_page_dsp_flag  VARCHAR2(1)
       ,qsnr_ftr_all_page_dsp_flag   VARCHAR2(1)
       ,allow_enrl_wout_chklst_flag  VARCHAR2(1)
       ,user_status_id                  NUMBER
       ,enabled_flag                    VARCHAR2(1)
       ,attribute_category              VARCHAR2(30)
       ,attribute1                      VARCHAR2(150)
       ,attribute2                      VARCHAR2(150)
       ,attribute3                      VARCHAR2(150)
       ,attribute4                      VARCHAR2(150)
       ,attribute5                      VARCHAR2(150)
       ,attribute6                      VARCHAR2(150)
       ,attribute7                      VARCHAR2(150)
       ,attribute8                      VARCHAR2(150)
       ,attribute9                      VARCHAR2(150)
       ,attribute10                     VARCHAR2(150)
       ,attribute11                     VARCHAR2(150)
       ,attribute12                     VARCHAR2(150)
       ,attribute13                     VARCHAR2(150)
       ,attribute14                     VARCHAR2(150)
       ,attribute15                     VARCHAR2(150)
       ,last_update_date                DATE
       ,last_updated_by                 NUMBER
       ,creation_date                   DATE
       ,created_by                      NUMBER
       ,last_update_login               NUMBER
       ,object_version_number           NUMBER
       ,program_name                    VARCHAR2(60)
       ,program_description             VARCHAR2(240)
       ,source_lang                     VARCHAR2(60)
       ,qsnr_title                      VARCHAR2(200)
       ,qsnr_header                     VARCHAR2(1600)
       ,qsnr_footer                     VARCHAR2(1600)
-- added by sranka, for Inventory creation, but its not part of the Table
       ,membership_fees					NUMBER
       );

g_miss_ptr_prgm_rec                          ptr_prgm_rec_type;
TYPE  partner_program_tbl_type   IS TABLE OF ptr_prgm_rec_type INDEX BY BINARY_INTEGER;
g_miss_partner_program_tbl                   partner_program_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Partner_Program
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER             Required
--       p_init_msg_list           IN   VARCHAR2           Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2           Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER             Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ptr_prgm_rec            IN   ptr_prgm_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated PROCEDURE definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Create_Partner_Program(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER             := FND_API.G_VALID_LEVEL_FULL
    ,p_ptr_prgm_rec               IN   ptr_prgm_rec_type  := g_miss_ptr_prgm_rec
    ,p_identity_resource_id       IN   NUMBER
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,x_program_id                 OUT NOCOPY  NUMBER
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Partner_Program
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
--       p_ptr_prgm_rec            IN   ptr_prgm_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated PROCEDURE definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Update_Partner_Program(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_ptr_prgm_rec               IN   ptr_prgm_rec_type
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Partner_Program
--               This procedure performs a soft delete by calling the UPDATE table handler
--               and setting ENABLED_FLAG to 'N'.
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
--       p_program_id              IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated PROCEDURE definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Delete_Partner_Program(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_program_id                 IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Partner_Program
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
--       p_ptr_prgm_rec            IN   ptr_prgm_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated PROCEDURE definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Lock_Partner_Program(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,px_program_id                IN  NUMBER
    ,p_object_version             IN  NUMBER
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Validate_partner_program
--
--    p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--    Note: 1. This is automated generated item level validation PROCEDURE.
--             The actual validation detail is needed to be added.
--          2. We can also validate table instead of record. There will be an option for user to choose.
--   ==============================================================================
--    End of Comments
--   ==============================================================================
PROCEDURE Validate_partner_program(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     	:= FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER 		:= FND_API.G_VALID_LEVEL_FULL
    ,p_ptr_prgm_rec               IN   ptr_prgm_rec_type
    ,p_validation_mode            IN   VARCHAR2		:= JTF_PLSQL_API.G_UPDATE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    );



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Check_Items
--
--     p_validation_mode is a constant defined in null_UTILITY_PVT package
--              For create: G_CREATE, for update: G_UPDATE
--     Note: 1. This is automated generated item level validation PROCEDURE.
--              The actual validation detail is needed to be added.
--           2. Validate the unique keys, lookups here
--   ==============================================================================
--    End of Comments
--   ==============================================================================
PROCEDURE Check_Items (
     p_ptr_prgm_rec      IN    ptr_prgm_rec_type
    ,p_validation_mode   IN    VARCHAR2
    ,x_return_status     OUT NOCOPY   VARCHAR2
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Validate_Rec
--    Record level validation procedures
--
--    p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--    Note: 1. This is automated generated item level validation PROCEDURE.
--             The actual validation detail is needed to be added.
--          2. Developer can manually added inter-field level validation.
--   ==============================================================================
--    End of Comments
--   ==============================================================================
PROCEDURE Validate_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_ptr_prgm_rec               IN   ptr_prgm_rec_type
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.g_UPDATE
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Complete_Rec
--
--    p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--    Note: 1. This is automated generated item level validation PROCEDURE.
--             The actual validation detail is needed to be added.
--          2. Developer can manually added inter-field level validation.
--   ==============================================================================
--    End of Comments
--   ==============================================================================
  PROCEDURE Complete_Rec (
     p_ptr_prgm_rec               IN   ptr_prgm_rec_type
    ,x_complete_rec               OUT NOCOPY  ptr_prgm_rec_type
    );


PROCEDURE create_inventory_item(
   p_ptr_prgm_rec    IN  ptr_prgm_rec_type,
   x_Item_rec		 OUT NOCOPY INV_Item_GRP.Item_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_Error_tbl       OUT NOCOPY INV_Item_GRP.Error_tbl_type
);

PROCEDURE create_pricelist_line(
   p_ptr_prgm_rec      IN  ptr_prgm_rec_type,
   p_inventory_item_id IN  NUMBER,
   p_operation IN VARCHAR2,
-- The following two variables will be used in case of Update only
   p_list_header_id        IN NUMBER,
   p_pricing_attribute_id  IN NUMBER,

   x_return_status   OUT NOCOPY VARCHAR2,
   x_pricelist_line_id OUT NOCOPY NUMBER,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data  OUT NOCOPY VARCHAR2
);

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Close_Ended_programs
   --
   -- PURPOSE
   --   close all the partner programs which are end dated.
   -- IN
   --   std. conc. request parameters.
   --   ERRBUF
   --   RETCODE
   -- OUT
   -- USED BY
   --   Concurrent program
   -- HISTORY
   --   12/04/2002        sveerave        CREATION
   --------------------------------------------------------------------------


PROCEDURE Close_Ended_programs(
  ERRBUF                OUT NOCOPY VARCHAR2,
  RETCODE               OUT NOCOPY VARCHAR2 );

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   check_price_exists
   --
   -- PURPOSE
   --   Checks whether any price exists for a given program.
   -- IN
   --   program_id NUMBER
   -- OUT
   --   'Y' if exists
   --   'N' if not exists
   -- USED BY
   --   Program Approval API, and Activate API.
   -- HISTORY
   --   12/04/2002        sveerave        CREATION
   --------------------------------------------------------------------------

FUNCTION check_price_exists(p_program_id IN NUMBER)
RETURN VARCHAR2;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Get_Object_Name
   --
   -- PURPOSE
   --   Provides the program name to Oracle Content Manager given program_id.
   --   This is needed so that IBC can display correct program name in their UI.
   -- IN
   --   p_association_type_code -- should be the association type code for Program in IBC, 'PV_PRGM'
   --   p_associated_object_val_1  -- object_id, i.e. program_id
   --   p_associated_object_val_2 -- optional
   --   p_associated_object_val_3 -- optional
   --   p_associated_object_val_4 -- optional
   --   p_associated_object_val_5 -- optional

   -- OUT
   --   x_object_name   program_name
   --   x_object_code   None
   --   x_return_status   return status
   --   x_msg_count   std. out params
   --   x_msg_data   std. out params

   -- USED BY
   --   IBC User Interfaces
   -- HISTORY
   --   01/21/2003        sveerave        CREATION
   --------------------------------------------------------------------------
PROCEDURE Get_Object_Name
(
    p_association_type_code       IN    VARCHAR2
   ,p_associated_object_val_1     IN    VARCHAR2
   ,p_associated_object_val_2     IN    VARCHAR2 DEFAULT NULL
   ,p_associated_object_val_3     IN    VARCHAR2 DEFAULT NULL
   ,p_associated_object_val_4     IN    VARCHAR2 DEFAULT NULL
   ,p_associated_object_val_5     IN    VARCHAR2 DEFAULT NULL
   ,x_object_name                 OUT NOCOPY  VARCHAR2
   ,x_object_code                 OUT NOCOPY  VARCHAR2
   ,x_return_status               OUT NOCOPY  VARCHAR2
   ,x_msg_count                   OUT NOCOPY  NUMBER
   ,x_msg_data                    OUT NOCOPY  VARCHAR2
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Copy_Program
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
--       p_validation_level        IN   NUMBER    Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_source_object_id        IN   NUMBER
--       p_attributes_table        IN   AMS_CpyUtility_PVT.copy_attributes_table_type  Required
--       p_copy_columns_table      IN   AMS_CpyUtility_PVT.copy_columns_table_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_new_object_id           OUT  NUMBER
--       x_custom_setup_id         OUT  NUMBER
--
--   End of Comments
--   ==============================================================================

PROCEDURE Copy_Program
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_source_object_id     IN    NUMBER
   --,p_identity_resource_id IN    NUMBER
   ,p_attributes_table     IN    AMS_CpyUtility_PVT.copy_attributes_table_type
   ,p_copy_columns_table   IN    AMS_CpyUtility_PVT.copy_columns_table_type
   ,x_new_object_id        OUT   NOCOPY   NUMBER
   ,x_custom_setup_id      OUT   NOCOPY   NUMBER
);

PROCEDURE Copy_Qualifications
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
   ,p_identity_resource_id IN    NUMBER
);

PROCEDURE Copy_Benefits
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
);

PROCEDURE Copy_Payments
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
);

PROCEDURE Copy_Legal_Terms
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
);

PROCEDURE Copy_Questionnaire
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
);

PROCEDURE Copy_Notif_Rules
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
);

PROCEDURE Copy_Checklist
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
);

/*
PROCEDURE Copy_Team
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
);
*/
PROCEDURE create_prereqruleid(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_program_id                 IN   NUMBER
   ,p_identity_resource_id       IN   NUMBER
   ,l_prereq_rule_id             OUT NOCOPY  NUMBER
   ,x_return_status              OUT NOCOPY  VARCHAR2
   ,x_msg_count                  OUT NOCOPY  NUMBER
   ,x_msg_data                   OUT NOCOPY  VARCHAR2
);

PROCEDURE  create_inv_item_if_not_exists(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_program_id                 IN   NUMBER
   ,p_update_program_table       IN   VARCHAR2
   ,x_return_status              OUT NOCOPY  VARCHAR2
   ,x_msg_count                  OUT NOCOPY  NUMBER
   ,x_msg_data                   OUT NOCOPY  VARCHAR2
   ,x_inventory_item_id          OUT NOCOPY  NUMBER
   ,x_inventory_item_org_id      OUT NOCOPY  NUMBER
);

END PV_Partner_Program_PVT;

 

/
