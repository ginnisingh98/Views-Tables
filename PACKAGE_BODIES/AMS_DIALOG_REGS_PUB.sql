--------------------------------------------------------
--  DDL for Package Body AMS_DIALOG_REGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DIALOG_REGS_PUB" AS
/* $Header: amspderb.pls 120.3 2006/08/16 04:49:37 rrajesh noship $ */
     -- This package is used in event registrion through scripting
   g_pkg_name   CONSTANT VARCHAR2(30):='AMS_Dialog_Regs_PUB';

Procedure transform_record(  p_reg_det_rec IN  RegistrationDetails
                           , x_reg_det_rec out NOCOPY AMS_Registrants_PUB.RegistrationDet
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

                   , x_return_status       OUT  NOCOPY  VARCHAR2
                   , x_msg_count           OUT  NOCOPY  NUMBER
                   , x_msg_data            OUT  NOCOPY  VARCHAR2

                   , p_reg_det_rec         IN   RegistrationDetails
                   , p_block_fulfillment   IN   VARCHAR2  := FND_API.G_TRUE
                   , p_owner_user_id       IN   NUMBER
                   , p_application_id      IN   NUMBER

                   , x_confirm_code        OUT  NOCOPY  VARCHAR2
                   , x_party_id            OUT  NOCOPY  NUMBER
                   , x_system_status_code  OUT  NOCOPY  VARCHAR2
                  )

IS

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Register';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_full_name                 CONSTANT VARCHAR2(60)  := G_PKG_NAME || '.' || l_api_name;

   l_return_status            VARCHAR2(1);
   l_reg_det_rec              AMS_Registrants_PUB.RegistrationDet;

   cursor c_get_extra_details(p_confirmation_code VARCHAR2) is
   select attendant_contact_id,
          system_status_code
   from ams_event_registrations
   where confirmation_code = p_confirmation_code;

BEGIN

   SAVEPOINT Register_Dialog_Regs_PUB;
   AMS_Utility_PVT.debug_message(l_full_name || ': start');

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_return_status := FND_API.g_ret_sts_success;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   transform_record(  p_reg_det_rec => p_reg_det_rec
                    , x_reg_det_rec => l_reg_det_rec
                   );

   AMS_Registrants_Pub.Register(  p_api_version_number  => 1.0
                                , p_init_msg_list       => FND_API.G_FALSE
                                , p_commit              => FND_API.G_FALSE
                                , p_validation_level    => p_validation_level

                                , x_return_status       => l_return_status
                                , x_msg_count           => x_msg_count
                                , x_msg_data            => x_msg_data

                                , p_reg_det_rec         => l_reg_det_rec
                                , p_block_fulfillment   => p_block_fulfillment
                                , p_owner_user_id       => p_owner_user_id
                                , p_application_id      => p_application_id

                                , x_confirm_code        => x_confirm_code
                               );

   IF (l_return_status = FND_API.g_ret_sts_unexp_error)
   THEN
      RAISE FND_API.g_exc_unexpected_error;
   ELSIF (l_return_status = FND_API.g_ret_sts_error)
   THEN
      RAISE FND_API.g_exc_error;
   END IF; -- l_return_status

   open c_get_extra_details(x_confirm_code);
   fetch c_get_extra_details
   into x_party_id,
        x_system_status_code;
   close c_get_extra_details;

   IF FND_API.to_boolean(p_commit)
   THEN
      COMMIT;
   END IF; -- p_commit

   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   x_return_status := l_return_status;

   AMS_Utility_PVT.debug_message(l_full_name || ': end');

EXCEPTION

   WHEN FND_API.g_exc_error
   THEN
      ROLLBACK TO Register_Registrants_PUB;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

      --sanshuma : temp soln
      fnd_message.set_encoded(fnd_msg_pub.get(x_msg_count));
      x_msg_data := fnd_message.get;


   WHEN FND_API.g_exc_unexpected_error
   THEN
      ROLLBACK TO Register_Registrants_PUB;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
      ROLLBACK TO Register_Registrants_PUB;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF (FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error))
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF; -- check_msg_level
      FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                                , p_count   => x_msg_count
                                , p_data    => x_msg_data
                               );

END Register;

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
                      )
IS

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'IsRegistered';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_full_name                 CONSTANT VARCHAR2(60)  := G_PKG_NAME || '.' || l_api_name;

   l_status_code               VARCHAR2(30);
   l_return_status             VARCHAR2(1);

   cursor c_get_status_code(p_confirmation_code VARCHAR2) is
   select system_status_code
   from ams_event_registrations
   where confirmation_code = p_confirmation_code;

BEGIN

   SAVEPOINT IsRegistered_Dialog_Regs_PUB;
   AMS_Utility_PVT.debug_message(l_full_name || ': start');

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_return_status := FND_API.g_ret_sts_success;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   open c_get_status_code(p_confirm_code);
   fetch c_get_status_code
   into l_status_code;
   close c_get_status_code;

   if (nvl(l_status_code, 'X') = 'REGISTERED')
   then
      x_is_registered := 'Y';
   else
      x_is_registered := 'N';
   end if;

   IF FND_API.to_boolean(p_commit)
   THEN
      COMMIT;
   END IF; -- p_commit

   FND_MSG_PUB.count_and_get(  p_encoded => FND_API.g_false
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data
                            );

   x_return_status := l_return_status;

   AMS_Utility_PVT.debug_message(l_full_name || ': end');

END IsRegistered;

Procedure transform_record(  p_reg_det_rec IN  RegistrationDetails
                           , x_reg_det_rec out NOCOPY AMS_Registrants_PUB.RegistrationDet
                          )
IS

BEGIN

   x_reg_det_rec.last_update_date := p_reg_det_rec.last_update_date;
   x_reg_det_rec.last_updated_by := p_reg_det_rec.last_updated_by;
   x_reg_det_rec.creation_date := p_reg_det_rec.creation_date;
   x_reg_det_rec.created_by := p_reg_det_rec.created_by;
   x_reg_det_rec.last_update_login := p_reg_det_rec.last_update_login;
   x_reg_det_rec.event_source_code := p_reg_det_rec.event_source_code;
   x_reg_det_rec.registration_source_type := p_reg_det_rec.registration_source_type;
   x_reg_det_rec.attendance_flag := p_reg_det_rec.attendance_flag;
   x_reg_det_rec.waitlisted_flag := p_reg_det_rec.waitlisted_flag;
   x_reg_det_rec.cancellation_flag := p_reg_det_rec.cancellation_flag;
   x_reg_det_rec.cancellation_reason_code := p_reg_det_rec.cancellation_reason_code;
   x_reg_det_rec.confirmation_code := p_reg_det_rec.confirmation_code;
   x_reg_det_rec.original_system_reference := p_reg_det_rec.original_system_reference;
   x_reg_det_rec.reg_party_id := p_reg_det_rec.reg_party_id;
   x_reg_det_rec.reg_party_type := p_reg_det_rec.reg_party_type;
   x_reg_det_rec.reg_contact_id := p_reg_det_rec.reg_contact_id;
   x_reg_det_rec.reg_party_name := p_reg_det_rec.reg_party_name;
   x_reg_det_rec.reg_title := p_reg_det_rec.reg_title;
   x_reg_det_rec.reg_first_name := p_reg_det_rec.reg_first_name;
   x_reg_det_rec.reg_middle_name := p_reg_det_rec.reg_middle_name;
   x_reg_det_rec.reg_last_name := p_reg_det_rec.reg_last_name;
   x_reg_det_rec.reg_address1 := p_reg_det_rec.reg_address1;
   x_reg_det_rec.reg_address2 := p_reg_det_rec.reg_address2;
   x_reg_det_rec.reg_address3 := p_reg_det_rec.reg_address3;
   x_reg_det_rec.reg_address4 := p_reg_det_rec.reg_address4;
   x_reg_det_rec.reg_gender := p_reg_det_rec.reg_gender;
   x_reg_det_rec.reg_address_line_phonetic := p_reg_det_rec.reg_address_line_phonetic;
   x_reg_det_rec.reg_analysis_fy := p_reg_det_rec.reg_analysis_fy;
   x_reg_det_rec.reg_apt_flag := p_reg_det_rec.reg_apt_flag;
   x_reg_det_rec.reg_best_time_contact_begin := p_reg_det_rec.reg_best_time_contact_begin;
   x_reg_det_rec.reg_best_time_contact_end := p_reg_det_rec.reg_best_time_contact_end;
   x_reg_det_rec.reg_category_code := p_reg_det_rec.reg_category_code;
   x_reg_det_rec.reg_ceo_name := p_reg_det_rec.reg_ceo_name;
   x_reg_det_rec.reg_city := p_reg_det_rec.reg_city;
   x_reg_det_rec.reg_country := p_reg_det_rec.reg_country;
   x_reg_det_rec.reg_county := p_reg_det_rec.reg_county;
   x_reg_det_rec.reg_current_fy_potential_rev := p_reg_det_rec.reg_current_fy_potential_rev;
   x_reg_det_rec.reg_next_fy_potential_rev := p_reg_det_rec.reg_next_fy_potential_rev;
   x_reg_det_rec.reg_household_income := p_reg_det_rec.reg_household_income;
   x_reg_det_rec.reg_decision_maker_flag := p_reg_det_rec.reg_decision_maker_flag;
   x_reg_det_rec.reg_department := p_reg_det_rec.reg_department;
   x_reg_det_rec.reg_dun_no_c := p_reg_det_rec.reg_dun_no_c;
   x_reg_det_rec.reg_email_address := p_reg_det_rec.reg_email_address;
   x_reg_det_rec.reg_employee_total := p_reg_det_rec.reg_employee_total;
   x_reg_det_rec.reg_fy_end_month := p_reg_det_rec.reg_fy_end_month;
   x_reg_det_rec.reg_floor := p_reg_det_rec.reg_floor;
   x_reg_det_rec.reg_gsa_indicator_flag := p_reg_det_rec.reg_gsa_indicator_flag;
   x_reg_det_rec.reg_house_number := p_reg_det_rec.reg_house_number;
   x_reg_det_rec.reg_identifying_address_flag := p_reg_det_rec.reg_identifying_address_flag;
   x_reg_det_rec.reg_jgzz_fiscal_code := p_reg_det_rec.reg_jgzz_fiscal_code;
   x_reg_det_rec.reg_job_title := p_reg_det_rec.reg_job_title;
   x_reg_det_rec.reg_last_order_date := p_reg_det_rec.reg_last_order_date;
   x_reg_det_rec.reg_org_legal_status := p_reg_det_rec.reg_org_legal_status;
   x_reg_det_rec.reg_line_of_business := p_reg_det_rec.reg_line_of_business;
   x_reg_det_rec.reg_mission_statement := p_reg_det_rec.reg_mission_statement;
   x_reg_det_rec.reg_org_name_phonetic := p_reg_det_rec.reg_org_name_phonetic;
   x_reg_det_rec.reg_overseas_address_flag := p_reg_det_rec.reg_overseas_address_flag;
   x_reg_det_rec.reg_name_suffix := p_reg_det_rec.reg_name_suffix;
   x_reg_det_rec.reg_phone_area_code := p_reg_det_rec.reg_phone_area_code;
   x_reg_det_rec.reg_phone_country_code := p_reg_det_rec.reg_phone_country_code;
   x_reg_det_rec.reg_phone_extension := p_reg_det_rec.reg_phone_extension;
   x_reg_det_rec.reg_phone_number := p_reg_det_rec.reg_phone_number;
   x_reg_det_rec.reg_postal_code := p_reg_det_rec.reg_postal_code;
   x_reg_det_rec.reg_postal_plus4_code := p_reg_det_rec.reg_postal_plus4_code;
   x_reg_det_rec.reg_po_box_no := p_reg_det_rec.reg_po_box_no;
   x_reg_det_rec.reg_province := p_reg_det_rec.reg_province;
   x_reg_det_rec.reg_rural_route_no := p_reg_det_rec.reg_rural_route_no;
   x_reg_det_rec.reg_rural_route_type := p_reg_det_rec.reg_rural_route_type;
   x_reg_det_rec.reg_secondary_suffix_element := p_reg_det_rec.reg_secondary_suffix_element;
   x_reg_det_rec.reg_sic_code := p_reg_det_rec.reg_sic_code;
   x_reg_det_rec.reg_sic_code_type := p_reg_det_rec.reg_sic_code_type;
   x_reg_det_rec.reg_site_use_code := p_reg_det_rec.reg_site_use_code;
   x_reg_det_rec.reg_state := p_reg_det_rec.reg_state;
   x_reg_det_rec.reg_street := p_reg_det_rec.reg_street;
   x_reg_det_rec.reg_street_number := p_reg_det_rec.reg_street_number;
   x_reg_det_rec.reg_street_suffix := p_reg_det_rec.reg_street_suffix;
   x_reg_det_rec.reg_suite := p_reg_det_rec.reg_suite;
   x_reg_det_rec.reg_tax_name := p_reg_det_rec.reg_tax_name;
   x_reg_det_rec.reg_tax_reference := p_reg_det_rec.reg_tax_reference;
   x_reg_det_rec.reg_timezone := p_reg_det_rec.reg_timezone;
   x_reg_det_rec.reg_total_no_of_orders := p_reg_det_rec.reg_total_no_of_orders;
   x_reg_det_rec.reg_total_order_amount := p_reg_det_rec.reg_total_order_amount;
   x_reg_det_rec.reg_year_established := p_reg_det_rec.reg_year_established;
   x_reg_det_rec.reg_url := p_reg_det_rec.reg_url;
   x_reg_det_rec.reg_survey_notes := p_reg_det_rec.reg_survey_notes;
   x_reg_det_rec.reg_contact_me_flag := p_reg_det_rec.reg_contact_me_flag;
   x_reg_det_rec.reg_email_ok_flag := p_reg_det_rec.reg_email_ok_flag;
   x_reg_det_rec.att_party_id := p_reg_det_rec.att_party_id;
   x_reg_det_rec.att_party_type := p_reg_det_rec.att_party_type;
   x_reg_det_rec.att_contact_id := p_reg_det_rec.att_contact_id;
   x_reg_det_rec.att_party_name := p_reg_det_rec.att_party_name;
   x_reg_det_rec.att_title := p_reg_det_rec.att_title;
   x_reg_det_rec.att_first_name := p_reg_det_rec.att_first_name;
   x_reg_det_rec.att_middle_name := p_reg_det_rec.att_middle_name;
   x_reg_det_rec.att_last_name := p_reg_det_rec.att_last_name;
   x_reg_det_rec.att_address1 := p_reg_det_rec.att_address1;
   x_reg_det_rec.att_address2 := p_reg_det_rec.att_address2;
   x_reg_det_rec.att_address3 := p_reg_det_rec.att_address3;
   x_reg_det_rec.att_address4 := p_reg_det_rec.att_address4;
   x_reg_det_rec.att_gender := p_reg_det_rec.att_gender;
   x_reg_det_rec.att_address_line_phonetic := p_reg_det_rec.att_address_line_phonetic;
   x_reg_det_rec.att_analysis_fy := p_reg_det_rec.att_analysis_fy;
   x_reg_det_rec.att_apt_flag := p_reg_det_rec.att_apt_flag;
   x_reg_det_rec.att_best_time_contact_begin := p_reg_det_rec.att_best_time_contact_begin;
   x_reg_det_rec.att_best_time_contact_end := p_reg_det_rec.att_best_time_contact_end;
   x_reg_det_rec.att_category_code := p_reg_det_rec.att_category_code;
   x_reg_det_rec.att_ceo_name := p_reg_det_rec.att_ceo_name;
   x_reg_det_rec.att_city := p_reg_det_rec.att_city;
   x_reg_det_rec.att_country := p_reg_det_rec.att_country;
   x_reg_det_rec.att_county := p_reg_det_rec.att_county;
   x_reg_det_rec.att_current_fy_potential_rev := p_reg_det_rec.att_current_fy_potential_rev;
   x_reg_det_rec.att_next_fy_potential_rev := p_reg_det_rec.att_next_fy_potential_rev;
   x_reg_det_rec.att_household_income := p_reg_det_rec.att_household_income;
   x_reg_det_rec.att_decision_maker_flag := p_reg_det_rec.att_decision_maker_flag;
   x_reg_det_rec.att_department := p_reg_det_rec.att_department;
   x_reg_det_rec.att_dun_no_c := p_reg_det_rec.att_dun_no_c;
   x_reg_det_rec.att_email_address := p_reg_det_rec.att_email_address;
   x_reg_det_rec.att_employee_total := p_reg_det_rec.att_employee_total;
   x_reg_det_rec.att_fy_end_month := p_reg_det_rec.att_fy_end_month;
   x_reg_det_rec.att_floor := p_reg_det_rec.att_floor;
   x_reg_det_rec.att_gsa_indicator_flag := p_reg_det_rec.att_gsa_indicator_flag;
   x_reg_det_rec.att_house_number := p_reg_det_rec.att_house_number;
   x_reg_det_rec.att_identifying_address_flag := p_reg_det_rec.att_identifying_address_flag;
   x_reg_det_rec.att_jgzz_fiscal_code := p_reg_det_rec.att_jgzz_fiscal_code;
   x_reg_det_rec.att_job_title := p_reg_det_rec.att_job_title;
   x_reg_det_rec.att_last_order_date := p_reg_det_rec.att_last_order_date;
   x_reg_det_rec.att_org_legal_status := p_reg_det_rec.att_org_legal_status;
   x_reg_det_rec.att_line_of_business := p_reg_det_rec.att_line_of_business;
   x_reg_det_rec.att_mission_statement := p_reg_det_rec.att_mission_statement;
   x_reg_det_rec.att_org_name_phonetic := p_reg_det_rec.att_org_name_phonetic;
   x_reg_det_rec.att_overseas_address_flag := p_reg_det_rec.att_overseas_address_flag;
   x_reg_det_rec.att_name_suffix := p_reg_det_rec.att_name_suffix;
   x_reg_det_rec.att_phone_area_code := p_reg_det_rec.att_phone_area_code;
   x_reg_det_rec.att_phone_country_code := p_reg_det_rec.att_phone_country_code;
   x_reg_det_rec.att_phone_extension := p_reg_det_rec.att_phone_extension;
   x_reg_det_rec.att_phone_number := p_reg_det_rec.att_phone_number;
   x_reg_det_rec.att_postal_code := p_reg_det_rec.att_postal_code;
   x_reg_det_rec.att_postal_plus4_code := p_reg_det_rec.att_postal_plus4_code;
   x_reg_det_rec.att_po_box_no := p_reg_det_rec.att_po_box_no;
   x_reg_det_rec.att_province := p_reg_det_rec.att_province;
   x_reg_det_rec.att_rural_route_no := p_reg_det_rec.att_rural_route_no;
   x_reg_det_rec.att_rural_route_type := p_reg_det_rec.att_rural_route_type;
   x_reg_det_rec.att_secondary_suffix_element := p_reg_det_rec.att_secondary_suffix_element;
   x_reg_det_rec.att_sic_code := p_reg_det_rec.att_sic_code;
   x_reg_det_rec.att_sic_code_type := p_reg_det_rec.att_sic_code_type;
   x_reg_det_rec.att_site_use_code := p_reg_det_rec.att_site_use_code;
   x_reg_det_rec.att_state := p_reg_det_rec.att_state;
   x_reg_det_rec.att_street := p_reg_det_rec.att_street;
   x_reg_det_rec.att_street_number := p_reg_det_rec.att_street_number;
   x_reg_det_rec.att_street_suffix := p_reg_det_rec.att_street_suffix;
   x_reg_det_rec.att_suite := p_reg_det_rec.att_suite;
   x_reg_det_rec.att_tax_name := p_reg_det_rec.att_tax_name;
   x_reg_det_rec.att_tax_reference := p_reg_det_rec.att_tax_reference;
   x_reg_det_rec.att_timezone := p_reg_det_rec.att_timezone;
   x_reg_det_rec.att_total_no_of_orders := p_reg_det_rec.att_total_no_of_orders;
   x_reg_det_rec.att_total_order_amount := p_reg_det_rec.att_total_order_amount;
   x_reg_det_rec.att_year_established := p_reg_det_rec.att_year_established;
   x_reg_det_rec.att_url := p_reg_det_rec.att_url;
   x_reg_det_rec.att_survey_notes := p_reg_det_rec.att_survey_notes;
   x_reg_det_rec.att_contact_me_flag := p_reg_det_rec.att_contact_me_flag;
   x_reg_det_rec.att_email_ok_flag := p_reg_det_rec.att_email_ok_flag;
   x_reg_det_rec.update_reg_rec := p_reg_det_rec.update_reg_rec;

END transform_record;

END AMS_Dialog_Regs_PUB;

/
