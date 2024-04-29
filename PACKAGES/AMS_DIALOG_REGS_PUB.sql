--------------------------------------------------------
--  DDL for Package AMS_DIALOG_REGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DIALOG_REGS_PUB" AUTHID CURRENT_USER AS
/* $Header: amspders.pls 120.3 2006/08/16 05:23:00 rrajesh noship $ */

TYPE RegistrationDetails IS RECORD(
   -- Who Columns
   /*last_update_date                   DATE := FND_API.G_MISS_DATE,
   last_updated_by                    NUMBER := FND_API.G_MISS_NUM,
   creation_date                      DATE := FND_API.G_MISS_DATE,
   created_by                         NUMBER := FND_API.G_MISS_NUM,
   last_update_login                  NUMBER := FND_API.G_MISS_NUM,*/

   last_update_date                   DATE,
   last_updated_by                    NUMBER,
   creation_date                      DATE,
   created_by                         NUMBER,
   last_update_login                  NUMBER,
   -- Event Details
   event_source_code                  VARCHAR2(100),
   registration_source_type           VARCHAR2(30),
   attendance_flag                    VARCHAR2(1),
   waitlisted_flag                    VARCHAR2(1),
   cancellation_flag                  VARCHAR2(1),
   cancellation_reason_code           VARCHAR2(30),
   confirmation_code                  VARCHAR2(30),
   original_system_reference          VARCHAR2(240),
   --Registrants Details
   reg_party_id                       NUMBER,
   reg_party_type                     VARCHAR2(30),
   reg_contact_id                     NUMBER,
   reg_party_name                     VARCHAR2(360),
   reg_title                          VARCHAR2(30),
   reg_first_name                     VARCHAR2(150),
   reg_middle_name                    VARCHAR2(60),
   reg_last_name                      VARCHAR2(150),
   reg_address1                       VARCHAR2(240),
   reg_address2                       VARCHAR2(240),
   reg_address3                       VARCHAR2(240),
   reg_address4                       VARCHAR2(240),
   reg_gender                         VARCHAR2(30),
   reg_address_line_phonetic          VARCHAR2(360),
   reg_analysis_fy                    VARCHAR2(5),
   reg_apt_flag                       VARCHAR2(1),
   reg_best_time_contact_begin        DATE,
   reg_best_time_contact_end          DATE,
   reg_category_code                  VARCHAR2(30),
   reg_ceo_name                       VARCHAR2(360),
   reg_city                           VARCHAR2(60),
   reg_country                        VARCHAR2(60),
   reg_county                         VARCHAR2(60),
   reg_current_fy_potential_rev       NUMBER,
   reg_next_fy_potential_rev          NUMBER,
   reg_household_income               NUMBER,
   reg_decision_maker_flag            VARCHAR2(1),
   reg_department                     VARCHAR2(360),
   reg_dun_no_c                       VARCHAR2(30),
   reg_email_address                  VARCHAR2(2000),
   reg_employee_total                 NUMBER,
   reg_fy_end_month                   VARCHAR2(30),
   reg_floor                          VARCHAR2(50),
   reg_gsa_indicator_flag             VARCHAR2(30),
   reg_house_number                   NUMBER,
   reg_identifying_address_flag       VARCHAR2(1),
   reg_jgzz_fiscal_code               VARCHAR2(20),
   reg_job_title                      VARCHAR2(100),
   reg_last_order_date                DATE,
   reg_org_legal_status               VARCHAR2(30),
   reg_line_of_business               VARCHAR2(240),
   reg_mission_statement              VARCHAR2(2000),
   reg_org_name_phonetic              VARCHAR2(320),
   reg_overseas_address_flag          VARCHAR2(1),
   reg_name_suffix                    VARCHAR2(30),
   reg_phone_area_code                VARCHAR2(10),
   reg_phone_country_code             VARCHAR2(10),
   reg_phone_extension                VARCHAR2(20),
   reg_phone_number                   VARCHAR2(40),
   reg_postal_code                    VARCHAR2(60),
   reg_postal_plus4_code              VARCHAR2(4),
   reg_po_box_no                      VARCHAR2(50),
   reg_province                       VARCHAR2(60),
   reg_rural_route_no                 VARCHAR2(50),
   reg_rural_route_type               VARCHAR2(30),
   reg_secondary_suffix_element       VARCHAR2(30),
   reg_sic_code                       VARCHAR2(30),
   reg_sic_code_type                  VARCHAR2(30),
   reg_site_use_code                  VARCHAR2(30),
   reg_state                          VARCHAR2(60),
   reg_street                         VARCHAR2(50),
   reg_street_number                  VARCHAR2(50),
   reg_street_suffix                  VARCHAR2(50),
   reg_suite                          VARCHAR2(50),
   reg_tax_name                       VARCHAR2(30),
   reg_tax_reference                  VARCHAR2(50),
   reg_timezone                       NUMBER,
   reg_total_no_of_orders             NUMBER,
   reg_total_order_amount             NUMBER,
   reg_year_established               NUMBER,
   reg_url                            VARCHAR2(2000),
   reg_survey_notes                   VARCHAR2(240),
   reg_contact_me_flag                VARCHAR2(1),
   reg_email_ok_flag                  VARCHAR2(1),
   -- Attendant Details
   att_party_id                       NUMBER,
   att_party_type                     VARCHAR2(30),
   att_contact_id                     NUMBER,
   att_party_name                     VARCHAR2(360),
   att_title                          VARCHAR2(30),
   att_first_name                     VARCHAR2(150),
   att_middle_name                    VARCHAR2(60),
   att_last_name                      VARCHAR2(150),
   att_address1                       VARCHAR2(240),
   att_address2                       VARCHAR2(240),
   att_address3                       VARCHAR2(240),
   att_address4                       VARCHAR2(240),
   att_gender                         VARCHAR2(30),
   att_address_line_phonetic          VARCHAR2(360),
   att_analysis_fy                    VARCHAR2(5),
   att_apt_flag                       VARCHAR2(1),
   att_best_time_contact_begin        DATE,
   att_best_time_contact_end          DATE,
   att_category_code                  VARCHAR2(30),
   att_ceo_name                       VARCHAR2(360),
   att_city                           VARCHAR2(60),
   att_country                        VARCHAR2(60),
   att_county                         VARCHAR2(60),
   att_current_fy_potential_rev       NUMBER,
   att_next_fy_potential_rev          NUMBER,
   att_household_income               NUMBER,
   att_decision_maker_flag            VARCHAR2(1),
   att_department                     VARCHAR2(360),
   att_dun_no_c                       VARCHAR2(30),    -- Verify
   att_email_address                  VARCHAR2(2000),
   att_employee_total                 NUMBER,
   att_fy_end_month                   VARCHAR2(30),
   att_floor                          NUMBER,    --Verify
   att_gsa_indicator_flag             VARCHAR2(30),
   att_house_number                   NUMBER,
   att_identifying_address_flag       VARCHAR2(1),
   att_jgzz_fiscal_code               VARCHAR2(20),
   att_job_title                      VARCHAR2(15),  -- Verify
   att_last_order_date                DATE,
   att_org_legal_status               VARCHAR2(30),  -- Verify
   att_line_of_business               VARCHAR2(360),  --  Verify
   att_mission_statement              VARCHAR2(2000),
   att_org_name_phonetic              VARCHAR2(320),
   att_overseas_address_flag          VARCHAR2(1),
   att_name_suffix                    VARCHAR2(30),
   att_phone_area_code                VARCHAR2(10),
   att_phone_country_code             VARCHAR2(10),
   att_phone_extension                VARCHAR2(20),
   att_phone_number                   VARCHAR2(40),
   att_postal_code                    VARCHAR2(60),
   att_postal_plus4_code              VARCHAR2(4),
   att_po_box_no                      NUMBER,    --Verity
   att_province                       VARCHAR2(60),
   att_rural_route_no                 VARCHAR2(60),   --Verify
   att_rural_route_type               VARCHAR2(30),
   att_secondary_suffix_element       VARCHAR2(30),
   att_sic_code                       VARCHAR2(30),
   att_sic_code_type                  VARCHAR2(30),
   att_site_use_code                  VARCHAR2(30), -- Verify
   att_state                          VARCHAR2(60),
   att_street                         VARCHAR2(30),  -- Verify
   att_street_number                  VARCHAR2(30),  -- Verify
   att_street_suffix                  VARCHAR2(30),  -- Verify
   att_suite                          VARCHAR2(30),  -- Verify
   att_tax_name                       VARCHAR2(30),
   att_tax_reference                  VARCHAR2(50),
   att_timezone                       NUMBER,
   att_total_no_of_orders             NUMBER,
   att_total_order_amount             NUMBER,
   att_year_established               NUMBER,
   att_url                            VARCHAR2(2000),
   att_survey_notes                   VARCHAR2(240),
   att_contact_me_flag                VARCHAR2(1),
   att_email_ok_flag                  VARCHAR2(1),
   update_reg_rec		      VARCHAR2(1)
   );

--==============================================================================
-- Start of Comments
--==============================================================================
--API Name
--   Register
--Type
--   Public
--Pre-Req
--
--Parameters
--
--IN
--    p_api_version_number      IN   NUMBER     Required
--    p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--    p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--    p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--    p_reg_det_rec             IN   RegistrationDetails  Required
--
--OUT
--    x_return_status           OUT  VARCHAR2
--    x_msg_count               OUT  NUMBER
--    x_msg_data                OUT  VARCHAR2
--    x_confirm_code            OUT  VARCHAR2  (the confirmation code)
--    x_party_id                OUT  NUMBER    (the attendant contact id - maps to a party_id in hz_parties)
--    x_system_status_code      OUT  VARCHAR2  (the status code of the registration)
--Version : Current version 1.0
--
--End of Comments
--==============================================================================
PROCEDURE Register(  p_api_version_number  IN   NUMBER
                   , p_init_msg_list       IN   VARCHAR2  := FND_API.G_FALSE
                   , p_commit              IN   VARCHAR2  := FND_API.G_FALSE
                   , p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL

                   , x_return_status       OUT  NOCOPY   VARCHAR2
                   , x_msg_count           OUT  NOCOPY   NUMBER
                   , x_msg_data            OUT  NOCOPY   VARCHAR2

                   , p_reg_det_rec         IN   RegistrationDetails
                   , p_block_fulfillment   IN   VARCHAR2  := FND_API.G_TRUE
                   , p_owner_user_id       IN   NUMBER
                   , p_application_id      IN   NUMBER

                   , x_confirm_code        OUT  NOCOPY   VARCHAR2
                   , x_party_id            OUT  NOCOPY   NUMBER
                   , x_system_status_code  OUT  NOCOPY   VARCHAR2
                  );

--==============================================================================
-- Start of Comments
--==============================================================================
--API Name
--   IsRegistered
--Type
--   Public
--Pre-Req
--
--Parameters
--
--IN
--    p_api_version_number      IN   NUMBER     Required
--    p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--    p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--    p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--    p_confirm_code            IN   RegistrationDetails  Required
--
--OUT
--    x_return_status           OUT  VARCHAR2
--    x_msg_count               OUT  NUMBER
--    x_msg_data                OUT  VARCHAR2
--    x_is_registered           OUT  VARCHAR2  ('Y' if registrant has status REGISTERED, 'N' otherwise)
--Version : Current version 1.0
--
--End of Comments
--==============================================================================
Procedure IsRegistered(  p_api_version_number  IN   NUMBER
                       , p_init_msg_list       IN   VARCHAR2  := FND_API.G_FALSE
                       , p_commit              IN   VARCHAR2  := FND_API.G_FALSE
                       , p_validation_level    IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL

                       , x_return_status       OUT  NOCOPY  VARCHAR2
                       , x_msg_count           OUT  NOCOPY  NUMBER
                       , x_msg_data            OUT  NOCOPY  VARCHAR2

                       , p_confirm_code        IN   VARCHAR2
                       , x_is_registered       OUT  NOCOPY  VARCHAR2
                      );

END AMS_Dialog_Regs_PUB;

 

/
