--------------------------------------------------------
--  DDL for Package Body AMS_IMP_REG_DETAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_REG_DETAIL_PVT" as
/* $Header: amsvimrb.pls 115.26 2004/01/07 18:59:18 soagrawa ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'ams_imp_reg_detail_pvt';
G_ARC_IMPORT_HEADER  CONSTANT VARCHAR2(30) := 'IMPH';

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE LoadProcess(  errbuf OUT NOCOPY VARCHAR2
                      , retcode OUT NOCOPY NUMBER
                      , p_list_header_id IN NUMBER := NULL
                     )
IS
   CURSOR c_get_header_id IS
   -- soagrawa 05-feb-2003 fixed bug# 2773827
   SELECT IMPORT_LIST_HEADER_ID, PROCESSED_ROWS, NUMBER_OF_FAILED_RECORDS, record_update_flag
   from AMS_IMP_LIST_HEADERS_ALL
   where IMPORT_TYPE = 'EVENT'
   and nvl(PROCESSED_ROWS, -1) < nvl(LOADED_NO_OF_ROWS, 0);

   CURSOR c_get_row_metadata(p_list_header_id in NUMBER) IS
   -- soagrawa 05-feb-2003 fixed bug# 2773827
   SELECT PROCESSED_ROWS, NUMBER_OF_FAILED_RECORDS, record_update_flag
   from AMS_IMP_LIST_HEADERS_ALL
   where IMPORT_TYPE = 'EVENT'
     and import_list_header_id = p_list_header_id;
     --and nvl(PROCESSED_ROWS, -1) < nvl(LOADED_NO_OF_ROWS, 0);

   cursor c_get_lines (id_in IN NUMBER) is
   select   import_source_line_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            -- Event Details
            event_source_code,
            registration_source_type,
            attendance_flag,
            waitlisted_flag,
            cancellation_flag,
            cancellation_reason_code,
            confirmation_code,
            original_system_reference,
              --Registrants Details,
            reg_party_id,
            reg_party_type,
            reg_contact_id,
            reg_party_name,
            reg_title,
            reg_first_name,
            reg_middle_name,
            reg_last_name,
            reg_address1,
            reg_address2,
            reg_address3,
            reg_address4,
            reg_gender,
            reg_address_line_phoenetic,
            reg_analysis_fy,
            reg_apt_flag,
            reg_best_time_contact_begin,
            reg_best_time_contact_end,
            reg_category_code,
            reg_ceo_name,
            reg_city,
            reg_country,
            reg_county,
            reg_current_fy_potential_rev,
            reg_next_fy_potential_rev,
            reg_household_income,
            reg_decision_maker_flag,
            reg_department,
            reg_dun_no_c,
            reg_email_address,
            reg_employee_total,
            reg_fy_end_month,
            reg_floor,
            reg_gsa_indicator_flag,
            reg_house_number,
            reg_identifying_address_flag,
            reg_jgzz_fiscal_code,
            reg_job_title,
            reg_last_order_date,
            reg_org_legal_status,
            reg_line_of_business,
            reg_mission_statement,
            reg_org_name_phoenetic,
            reg_overseas_address_flag,
            reg_name_suffix,
            reg_phone_area_code,
            reg_phone_country_code,
            reg_phone_extension,
            reg_phone_number,
            reg_postal_code,
            reg_postal_plus4_code,
            reg_po_box_no,
            reg_province,
            reg_rural_route_no,
            reg_rural_route_type,
            reg_secondary_suffix_element,
            reg_sic_code,
            reg_sic_code_type,
            reg_site_use_code,
            reg_state,
            reg_street,
            reg_street_number,
            reg_street_suffix,
            reg_suite,
            reg_tax_name,
            reg_tax_reference,
            reg_timezone,
            reg_total_no_of_orders,
            reg_total_order_amount,
            reg_year_establised,
            reg_url,
            reg_servey_notes,
            reg_contact_me_flag,
            reg_email_ok_flag,
              -- Attendent Details,
            att_party_id,
            att_party_type,
            att_contact_id,
            att_party_name,
            att_title,
            att_first_name,
            att_middle_name,
            att_last_name,
            att_address1,
            att_address2,
            att_address3,
            att_address4,
            att_gender,
            att_address_line_phoenetic,
            att_analysis_fy,
            att_apt_flag,
            att_best_time_contact_begin,
            att_best_time_contact_end,
            att_category_code,
            att_ceo_name,
            att_city,
            att_country,
            att_county,
            att_current_fy_potential_rev,
            att_next_fy_potential_rev,
            att_household_income,
            att_decision_maker_flag,
            att_department,
            att_dun_no,
            att_email_address,
            att_employee_total,
            att_fy_end_month,
            att_floor,
            att_gsa_indicator_flag,
            att_house_number,
            att_identifying_address_flag,
            att_jgzz_fiscal_code,
            att_job_title,
            att_last_order_date,
            att_legal_status,
            att_line_of_business,
            att_mission_statement,
            att_org_name_phoenetic,
            att_overseas_address_flag,
            att_name_suffix,
            att_phone_area_code,
            att_phone_country_code,
            att_phone_extension,
            att_phone_number,
            att_postal_code,
            att_postal_plus4_code,
            att_po_box_no,
            att_province,
            att_rural_route_no,
            att_rural_route_type,
            att_secondary_suffix_element,
            att_sic_code,
            att_sic_code_type,
            att_site_use_code,
            att_state,
            att_street,
            att_street_number,
            att_street_suffix,
            att_suite,
            att_tax_name,
            att_tax_reference,
            att_timezone,
            att_total_no_of_orders,
            att_total_order_amount,
            att_year_establised,
            att_url,
            att_servey_notes,
            att_contact_me_flag,
            att_email_ok_flag
      from AMS_EVENT_MAPPING_V
      where IMPORT_LIST_HEADER_ID = id_in
        and IMPORT_SUCCESSFUL_FLAG = 'N'
        and load_status in ('ACTIVE', 'RELOAD');
      -- end of c_get_lines

   -- soagrawa 05-feb-2003 fixed bug# 2773827
   l_upd_flag    VARCHAR2(1);
   l_imp_rec   c_get_lines%ROWTYPE;
   l_reg_rec   AMS_Registrants_PUB.RegistrationDet;
   l_hdr_id    NUMBER := p_list_header_id;
   l_processed_rows NUMBER ;
   l_failed_rows  NUMBER;
   l_reg_id NUMBER;
   l_return_status         VARCHAR2(1);
   l_out_status         VARCHAR2(1);
   l_msg_count            NUMBER;
   l_msg_data            VARCHAR2(2000);
   --l_system_status_code    VARCHAR2(30);
   l_conf_code           ams_event_registrations.confirmation_code%type;
   l_cnt1   NUMBER;
   l_cnt2   NUMBER;
   l_request_id  NUMBER;
   l_used_by varchar2(30);
   l_return_status_log varchar2(30);
   l_notfound NUMBER := 0;
--   error_threshold_exc exception;
BEGIN
   l_cnt1 := 0;
   l_cnt2 := 0;
   l_used_by := 'IMPH';
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
   --FND_FILE.PUT_LINE(FND_FILE.LOG,'Start of import Event registrations Record');
   --FND_FILE.PUT_LINE(FND_FILE.LOG,'requestid :'||l_request_id);
   IF (p_list_header_id is null)
   THEN
      OPEN c_get_header_id;
      FETCH c_get_header_id
   -- soagrawa 05-feb-2003 fixed bug# 2773827
      INTO l_hdr_id,l_processed_rows,l_failed_rows, l_upd_flag;
      IF c_get_header_id%NOTFOUND
      THEN
         CLOSE c_get_header_id;
         l_notfound := 1;
      END IF;
   ELSE
      OPEN c_get_row_metadata(l_hdr_id);
      FETCH c_get_row_metadata
   -- soagrawa 05-feb-2003 fixed bug# 2773827
      INTO l_processed_rows,l_failed_rows, l_upd_flag;
      IF c_get_row_metadata%NOTFOUND
      THEN
         CLOSE c_get_row_metadata;
         l_notfound := 1;
      END IF;
   END IF;
   IF (l_notfound = 0)
   THEN
      Ams_Utility_PVT.Create_Log (
         x_return_status   => l_return_status_log,
         p_arc_log_used_by => l_used_by,
         p_log_used_by_id  => l_hdr_id,
         p_msg_data        => 'Start of import Event registrations Record'
      );
      Ams_Utility_PVT.Create_Log (
         x_return_status   => l_return_status_log,
         p_arc_log_used_by => l_used_by,
         p_log_used_by_id  => l_hdr_id,
         p_msg_data        => 'Concurrent Program started the Id is ' || to_char(l_request_id)
      );
      IF p_list_header_id IS NULL THEN
            LOOP
               --DBMS_OUTPUT.put_line('In side first loop'||l_cnt1||' '||l_cnt2);
               exit WHEN c_get_header_id%NOTFOUND;
              -- dbiswas replaced nvl values for l_processed_rows and l_failed_rows with 0 initial val on
              -- 14-apr-2003 to fix bug 2834282
              -- l_processed_rows := nvl(l_processed_rows, 0);
              -- l_failed_rows := nvl(l_failed_rows, 0);
               l_processed_rows := 0;
               l_failed_rows :=  0 ;


               open c_get_lines(l_hdr_id);
               fetch c_get_lines into l_imp_rec;
               IF c_get_lines%NOTFOUND THEN
                  CLOSE c_get_lines;
                  --FND_FILE.PUT_LINE(FND_FILE.LOG,'No Line RECORD TO Process at this time');
                  Ams_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status_log,
                     p_arc_log_used_by => l_used_by,
                     p_log_used_by_id  => l_hdr_id,
                     p_msg_data        => 'No Line RECORD TO Process at this time'
                  );
                  --DBMS_OUTPUT.put_line('No line RECORD available Process');
               ELSE
                  LOOP
                     exit WHEN c_get_lines%NOTFOUND;
                     --DBMS_OUTPUT.put_line('In side second loop'||l_cnt1||' ' ||l_cnt2);
                     Ams_Utility_PVT.Create_Log(  x_return_status   => l_return_status_log
                                                , p_arc_log_used_by => l_used_by
                                                , p_log_used_by_id  => l_hdr_id
                                                , p_msg_data        => '----Processing the record whose source Line Id is '
                                                                       || to_char(l_imp_rec.import_source_line_id) || '----'
                                               );

      /*
                     --l_reg_rec.EVENT_REGISTRATION_ID := to_number(l_imp_rec.EVENT_REGISTRATION_ID);
                     l_reg_rec.LAST_UPDATE_DATE:= l_imp_rec.LAST_UPDATE_DATE;
                     l_reg_rec.LAST_UPDATED_BY := l_imp_rec.LAST_UPDATED_BY;
                     l_reg_rec.CREATION_DATE  := l_imp_rec.CREATION_DATE;
                     l_reg_rec.CREATED_BY := l_imp_rec.CREATED_BY ;
                     l_reg_rec.LAST_UPDATE_LOGIN := l_imp_rec.LAST_UPDATE_LOGIN ;
                     l_reg_rec.OBJECT_VERSION_NUMBER := 1;-- l_imp_rec.OBJECT_VERSION_NUMBER ,
                     l_reg_rec.EVENT_OFFER_ID := to_number(l_imp_rec.EVENT_OFFER_ID);
                     l_reg_rec.APPLICATION_ID := 530; --l_imp_rec.G_APPLICATION_ID;
                     l_reg_rec.ACTIVE_FLAG := l_imp_rec.ACTIVE_FLAG;
                     l_reg_rec.OWNER_USER_ID := l_imp_rec.OWNER_USER_ID;
                     l_reg_rec.SYSTEM_STATUS_CODE:= l_imp_rec.SYSTEM_STATUS_CODE;
                     l_reg_rec.DATE_REGISTRATION_PLACED:= to_date(l_imp_rec.DATE_REGISTRATION_PLACED);
                     l_reg_rec. USER_STATUS_ID:= to_number(l_imp_rec.USER_STATUS_ID) ;
                     l_reg_rec.LAST_REG_STATUS_DATE := to_date (l_imp_rec.LAST_REG_STATUS_DATE) ;
                     l_reg_rec.REG_SOURCE_TYPE_CODE := l_imp_rec.REG_SOURCE_TYPE_CODE;
                     l_reg_rec.REGISTRATION_SOURCE_ID := to_number(l_imp_rec.REGISTRATION_SOURCE_ID);
                     --l_reg_rec.CONFIRMATION_CODE := l_imp_rec.CONFIRMATION_CODE;
                     l_reg_rec.SOURCE_CODE := l_imp_rec.SOURCE_CODE ;
                     l_reg_rec.REGISTRATION_GROUP_ID :=to_number(l_imp_rec.REGISTRATION_GROUP_ID);
                     l_reg_rec.REGISTRANT_PARTY_ID := to_number(l_imp_rec.REGISTRANT_PARTY_ID);
                     l_reg_rec.REGISTRANT_CONTACT_ID := to_number(l_imp_rec.REGISTRANT_CONTACT_ID) ;
                     l_reg_rec.REGISTRANT_ACCOUNT_ID:= to_number(l_imp_rec.REGISTRANT_ACCOUNT_ID);
                     l_reg_rec.ATTENDANT_PARTY_ID := to_number(l_imp_rec.ATTENDANT_PARTY_ID);
                     l_reg_rec.ATTENDANT_CONTACT_ID := to_number(l_imp_rec.ATTENDANT_CONTACT_ID);
                     l_reg_rec.ATTENDANT_ACCOUNT_ID := to_number(l_imp_rec.ATTENDANT_ACCOUNT_ID);
                     l_reg_rec.ORIGINAL_REGISTRANT_CONTACT_ID := to_number(l_imp_rec.ORIGINAL_REGISTRANT_CONTACT_ID);
                     l_reg_rec.PROSPECT_FLAG := l_imp_rec.PROSPECT_FLAG ;
                     l_reg_rec.ATTENDED_FLAG := l_imp_rec.ATTENDED_FLAG ;
                     l_reg_rec.CONFIRMED_FLAG := l_imp_rec.CONFIRMED_FLAG ;
                     l_reg_rec.EVALUATED_FLAG := l_imp_rec.EVALUATED_FLAG ;
                     l_reg_rec.ATTENDANCE_RESULT_CODE := l_imp_rec.ATTENDANCE_RESULT_CODE ;
                     l_reg_rec.WAITLISTED_PRIORITY := to_number(l_imp_rec.WAITLISTED_PRIORITY);
                     l_reg_rec.TARGET_LIST_ID := to_number(l_imp_rec.TARGET_LIST_ID) ;
                     l_reg_rec.INBOUND_MEDIA_ID := to_number(l_imp_rec.INBOUND_MEDIA_ID);
                     l_reg_rec.INBOUND_CHANNEL_ID := to_number(l_imp_rec.INBOUND_CHANNEL_ID) ;
                     l_reg_rec.CANCELLATION_CODE := l_imp_rec.CANCELLATION_CODE ;
                     l_reg_rec.CANCELLATION_REASON_CODE := l_imp_rec.CANCELLATION_REASON_CODE ;
                     l_reg_rec.ATTENDANCE_FAILURE_REASON := l_imp_rec.ATTENDANCE_FAILURE_REASON ;
                     l_reg_rec.ATTENDANT_LANGUAGE := l_imp_rec.ATTENDANT_LANGUAGE ;
                     l_reg_rec.SALESREP_ID := to_number(l_imp_rec.SALESREP_ID) ;
                     l_reg_rec.ORDER_HEADER_ID := to_number(l_imp_rec.ORDER_HEADER_ID) ;
                     l_reg_rec.ORDER_LINE_ID := to_number(l_imp_rec.ORDER_LINE_ID);
                     l_reg_rec.DESCRIPTION := l_imp_rec.DESCRIPTION;
                     l_reg_rec.MAX_ATTENDEE_OVERRIDE_FLAG := l_imp_rec.MAX_ATTENDEE_OVERRIDE_FLAG ;
                     l_reg_rec.INVITE_ONLY_OVERRIDE_FLAG := l_imp_rec.INVITE_ONLY_OVERRIDE_FLAG;
                     l_reg_rec.PAYMENT_STATUS_CODE:= l_imp_rec.PAYMENT_STATUS_CODE;
                     l_reg_rec.AUTO_REGISTER_FLAG:= l_imp_rec.AUTO_REGISTER_FLAG;
                     l_reg_rec.ATTRIBUTE_CATEGORY := l_imp_rec.ATTRIBUTE_CATEGORY ;
                     l_reg_rec.ATTRIBUTE1 := l_imp_rec.ATTRIBUTE1;
                     l_reg_rec.ATTRIBUTE2 := l_imp_rec.ATTRIBUTE2 ;
                     l_reg_rec.ATTRIBUTE3 := l_imp_rec.ATTRIBUTE3;
                     l_reg_rec.ATTRIBUTE4 := l_imp_rec.ATTRIBUTE4;
                     l_reg_rec.ATTRIBUTE5 := l_imp_rec.ATTRIBUTE5;
                     l_reg_rec.ATTRIBUTE6 := l_imp_rec.ATTRIBUTE6;
                     l_reg_rec.ATTRIBUTE7 := l_imp_rec.ATTRIBUTE7;
                     l_reg_rec.ATTRIBUTE8 := l_imp_rec.ATTRIBUTE8;
                     l_reg_rec.ATTRIBUTE9 := l_imp_rec.ATTRIBUTE9;
                     l_reg_rec.ATTRIBUTE10 := l_imp_rec.ATTRIBUTE10;
                     l_reg_rec.ATTRIBUTE11 := l_imp_rec.ATTRIBUTE11;
                     l_reg_rec.ATTRIBUTE12  := l_imp_rec.ATTRIBUTE12;
                     l_reg_rec.ATTRIBUTE13 := l_imp_rec.ATTRIBUTE13;
                     l_reg_rec.ATTRIBUTE14 := l_imp_rec.ATTRIBUTE14;
                     l_reg_rec.ATTRIBUTE15 := l_imp_rec.ATTRIBUTE15;
      */
                     l_reg_rec.last_update_date := l_imp_rec.last_update_date;
                     l_reg_rec.last_updated_by := l_imp_rec.last_updated_by;
                     l_reg_rec.creation_date := l_imp_rec.creation_date;
                     l_reg_rec.created_by := l_imp_rec.created_by;
                     l_reg_rec.last_update_login := l_imp_rec.last_update_login;
                     -- Event Details
                     l_reg_rec.event_source_code := l_imp_rec.event_source_code;
                     l_reg_rec.registration_source_type := l_imp_rec.registration_source_type;
                     l_reg_rec.attendance_flag := l_imp_rec.attendance_flag;
                     l_reg_rec.waitlisted_flag := l_imp_rec.waitlisted_flag;
                     l_reg_rec.cancellation_flag := l_imp_rec.cancellation_flag;
                     l_reg_rec.cancellation_reason_code := l_imp_rec.cancellation_reason_code;
                     l_reg_rec.confirmation_code := l_imp_rec.confirmation_code;
                     l_reg_rec.original_system_reference := l_imp_rec.original_system_reference;
                       --Registrant Details
                     l_reg_rec.reg_party_id := l_imp_rec.reg_party_id;
                     l_reg_rec.reg_party_type := l_imp_rec.reg_party_type;
                     l_reg_rec.reg_contact_id := l_imp_rec.reg_contact_id;
                     l_reg_rec.reg_party_name := l_imp_rec.reg_party_name;
                     l_reg_rec.reg_title := l_imp_rec.reg_title;
                     l_reg_rec.reg_first_name := l_imp_rec.reg_first_name;
                     l_reg_rec.reg_middle_name := l_imp_rec.reg_middle_name;
                     l_reg_rec.reg_last_name := l_imp_rec.reg_last_name;
                     l_reg_rec.reg_address1 := l_imp_rec.reg_address1;
                     l_reg_rec.reg_address2 := l_imp_rec.reg_address2;
                     l_reg_rec.reg_address3 := l_imp_rec.reg_address3;
                     l_reg_rec.reg_address4 := l_imp_rec.reg_address4;
                     l_reg_rec.reg_gender := l_imp_rec.reg_gender;
                     l_reg_rec.reg_address_line_phonetic := l_imp_rec.reg_address_line_phoenetic;
                     l_reg_rec.reg_analysis_fy := l_imp_rec.reg_analysis_fy;
                     l_reg_rec.reg_apt_flag := l_imp_rec.reg_apt_flag;
                     l_reg_rec.reg_best_time_contact_begin := l_imp_rec.reg_best_time_contact_begin;
                     l_reg_rec.reg_best_time_contact_end := l_imp_rec.reg_best_time_contact_end;
                     l_reg_rec.reg_category_code := l_imp_rec.reg_category_code;
                     l_reg_rec.reg_ceo_name := l_imp_rec.reg_ceo_name;
                     l_reg_rec.reg_city := l_imp_rec.reg_city;
                     l_reg_rec.reg_country := l_imp_rec.reg_country;
                     l_reg_rec.reg_county := l_imp_rec.reg_county;
                     l_reg_rec.reg_current_fy_potential_rev := l_imp_rec.reg_current_fy_potential_rev;
                     l_reg_rec.reg_next_fy_potential_rev := l_imp_rec.reg_next_fy_potential_rev;
                     l_reg_rec.reg_household_income := l_imp_rec.reg_household_income;
                     l_reg_rec.reg_decision_maker_flag := l_imp_rec.reg_decision_maker_flag;
                     l_reg_rec.reg_department := l_imp_rec.reg_department;
                     l_reg_rec.reg_dun_no_c := l_imp_rec.reg_dun_no_c;
                     l_reg_rec.reg_email_address := l_imp_rec.reg_email_address;
                     l_reg_rec.reg_employee_total := l_imp_rec.reg_employee_total;
                     l_reg_rec.reg_fy_end_month := l_imp_rec.reg_fy_end_month;
                     l_reg_rec.reg_floor := l_imp_rec.reg_floor;
                     l_reg_rec.reg_gsa_indicator_flag := l_imp_rec.reg_gsa_indicator_flag;
                     l_reg_rec.reg_house_number := l_imp_rec.reg_house_number;
                     l_reg_rec.reg_identifying_address_flag := l_imp_rec.reg_identifying_address_flag;
                     l_reg_rec.reg_jgzz_fiscal_code := l_imp_rec.reg_jgzz_fiscal_code;
                     l_reg_rec.reg_job_title := l_imp_rec.reg_job_title;
                     l_reg_rec.reg_last_order_date := l_imp_rec.reg_last_order_date;
                     l_reg_rec.reg_org_legal_status := l_imp_rec.reg_org_legal_status;
                     l_reg_rec.reg_line_of_business := l_imp_rec.reg_line_of_business;
                     l_reg_rec.reg_mission_statement := l_imp_rec.reg_mission_statement;
                     l_reg_rec.reg_org_name_phonetic := l_imp_rec.reg_org_name_phoenetic;
                     l_reg_rec.reg_overseas_address_flag := l_imp_rec.reg_overseas_address_flag;
                     l_reg_rec.reg_name_suffix := l_imp_rec.reg_name_suffix;
                     l_reg_rec.reg_phone_area_code := l_imp_rec.reg_phone_area_code;
                     l_reg_rec.reg_phone_country_code := l_imp_rec.reg_phone_country_code;
                     l_reg_rec.reg_phone_extension := l_imp_rec.reg_phone_extension;
                     l_reg_rec.reg_phone_number := l_imp_rec.reg_phone_number;
                     l_reg_rec.reg_postal_code := l_imp_rec.reg_postal_code;
                     l_reg_rec.reg_postal_plus4_code := l_imp_rec.reg_postal_plus4_code;
                     l_reg_rec.reg_po_box_no := l_imp_rec.reg_po_box_no;
                     l_reg_rec.reg_province := l_imp_rec.reg_province;
                     l_reg_rec.reg_rural_route_no := l_imp_rec.reg_rural_route_no;
                     l_reg_rec.reg_rural_route_type := l_imp_rec.reg_rural_route_type;
                     l_reg_rec.reg_secondary_suffix_element := l_imp_rec.reg_secondary_suffix_element;
                     l_reg_rec.reg_sic_code := l_imp_rec.reg_sic_code;
                     l_reg_rec.reg_sic_code_type := l_imp_rec.reg_sic_code_type;
                     l_reg_rec.reg_site_use_code := l_imp_rec.reg_site_use_code;
                     l_reg_rec.reg_state := l_imp_rec.reg_state;
                     l_reg_rec.reg_street := l_imp_rec.reg_street;
                     l_reg_rec.reg_street_number := l_imp_rec.reg_street_number;
                     l_reg_rec.reg_street_suffix := l_imp_rec.reg_street_suffix;
                     l_reg_rec.reg_suite := l_imp_rec.reg_suite;
                     l_reg_rec.reg_tax_name := l_imp_rec.reg_tax_name;
                     l_reg_rec.reg_tax_reference := l_imp_rec.reg_tax_reference;
                     l_reg_rec.reg_timezone := l_imp_rec.reg_timezone;
                     l_reg_rec.reg_total_no_of_orders := l_imp_rec.reg_total_no_of_orders;
                     l_reg_rec.reg_total_order_amount := l_imp_rec.reg_total_order_amount;
                     l_reg_rec.reg_year_established := l_imp_rec.reg_year_establised;
                     l_reg_rec.reg_url := l_imp_rec.reg_url;
                     l_reg_rec.reg_survey_notes := l_imp_rec.reg_servey_notes;
                     l_reg_rec.reg_contact_me_flag := l_imp_rec.reg_contact_me_flag;
                     l_reg_rec.reg_email_ok_flag := l_imp_rec.reg_email_ok_flag;
                       -- Attendent Details
                     l_reg_rec.att_party_id := l_imp_rec.att_party_id;
                     l_reg_rec.att_party_type := l_imp_rec.att_party_type;
                     l_reg_rec.att_contact_id := l_imp_rec.att_contact_id;
                     l_reg_rec.att_party_name := l_imp_rec.att_party_name;
                     l_reg_rec.att_title := l_imp_rec.att_title;
                     l_reg_rec.att_first_name := l_imp_rec.att_first_name;
                     l_reg_rec.att_middle_name := l_imp_rec.att_middle_name;
                     l_reg_rec.att_last_name := l_imp_rec.att_last_name;
                     l_reg_rec.att_address1 := l_imp_rec.att_address1;
                     l_reg_rec.att_address2 := l_imp_rec.att_address2;
                     l_reg_rec.att_address3 := l_imp_rec.att_address3;
                     l_reg_rec.att_address4 := l_imp_rec.att_address4;
                     l_reg_rec.att_gender := l_imp_rec.att_gender;
                     l_reg_rec.att_address_line_phonetic := l_imp_rec.att_address_line_phoenetic;
                     l_reg_rec.att_analysis_fy := l_imp_rec.att_analysis_fy;
                     l_reg_rec.att_apt_flag := l_imp_rec.att_apt_flag;
                     l_reg_rec.att_best_time_contact_begin := l_imp_rec.att_best_time_contact_begin;
                     l_reg_rec.att_best_time_contact_end := l_imp_rec.att_best_time_contact_end;
                     l_reg_rec.att_category_code := l_imp_rec.att_category_code;
                     l_reg_rec.att_ceo_name := l_imp_rec.att_ceo_name;
                     l_reg_rec.att_city := l_imp_rec.att_city;
                     l_reg_rec.att_country := l_imp_rec.att_country;
                     l_reg_rec.att_county := l_imp_rec.att_county;
                     l_reg_rec.att_current_fy_potential_rev := l_imp_rec.att_current_fy_potential_rev;
                     l_reg_rec.att_next_fy_potential_rev := l_imp_rec.att_next_fy_potential_rev;
                     l_reg_rec.att_household_income := l_imp_rec.att_household_income;
                     l_reg_rec.att_decision_maker_flag := l_imp_rec.att_decision_maker_flag;
                     l_reg_rec.att_department := l_imp_rec.att_department;
                     l_reg_rec.att_dun_no_c := l_imp_rec.att_dun_no;
                     l_reg_rec.att_email_address := l_imp_rec.att_email_address;
                     l_reg_rec.att_employee_total := l_imp_rec.att_employee_total;
                     l_reg_rec.att_fy_end_month := l_imp_rec.att_fy_end_month;
                     l_reg_rec.att_floor := l_imp_rec.att_floor;
                     l_reg_rec.att_gsa_indicator_flag := l_imp_rec.att_gsa_indicator_flag;
                     l_reg_rec.att_house_number := l_imp_rec.att_house_number;
                     l_reg_rec.att_identifying_address_flag := l_imp_rec.att_identifying_address_flag;
                     l_reg_rec.att_jgzz_fiscal_code := l_imp_rec.att_jgzz_fiscal_code;
                     l_reg_rec.att_job_title := l_imp_rec.att_job_title;
                     l_reg_rec.att_last_order_date := l_imp_rec.att_last_order_date;
                     l_reg_rec.att_org_legal_status := l_imp_rec.att_legal_status;
                     l_reg_rec.att_line_of_business := l_imp_rec.att_line_of_business;
                     l_reg_rec.att_mission_statement := l_imp_rec.att_mission_statement;
                     l_reg_rec.att_org_name_phonetic := l_imp_rec.att_org_name_phoenetic;
                     l_reg_rec.att_overseas_address_flag := l_imp_rec.att_overseas_address_flag;
                     l_reg_rec.att_name_suffix := l_imp_rec.att_name_suffix;
                     l_reg_rec.att_phone_area_code := l_imp_rec.att_phone_area_code;
                     l_reg_rec.att_phone_country_code := l_imp_rec.att_phone_country_code;
                     l_reg_rec.att_phone_extension := l_imp_rec.att_phone_extension;
                     l_reg_rec.att_phone_number := l_imp_rec.att_phone_number;
                     l_reg_rec.att_postal_code := l_imp_rec.att_postal_code;
                     l_reg_rec.att_postal_plus4_code := l_imp_rec.att_postal_plus4_code;
                     l_reg_rec.att_po_box_no := l_imp_rec.att_po_box_no;
                     l_reg_rec.att_province := l_imp_rec.att_province;
                     l_reg_rec.att_rural_route_no := l_imp_rec.att_rural_route_no;
                     l_reg_rec.att_rural_route_type := l_imp_rec.att_rural_route_type;
                     l_reg_rec.att_secondary_suffix_element := l_imp_rec.att_secondary_suffix_element;
                     l_reg_rec.att_sic_code := l_imp_rec.att_sic_code;
                     l_reg_rec.att_sic_code_type := l_imp_rec.att_sic_code_type;
                     l_reg_rec.att_site_use_code := l_imp_rec.att_site_use_code;
                     l_reg_rec.att_state := l_imp_rec.att_state;
                     l_reg_rec.att_street := l_imp_rec.att_street;
                     l_reg_rec.att_street_number := l_imp_rec.att_street_number;
                     l_reg_rec.att_street_suffix := l_imp_rec.att_street_suffix;
                     l_reg_rec.att_suite := l_imp_rec.att_suite;
                     l_reg_rec.att_tax_name := l_imp_rec.att_tax_name;
                     l_reg_rec.att_tax_reference := l_imp_rec.att_tax_reference;
                     l_reg_rec.att_timezone := l_imp_rec.att_timezone;
                     l_reg_rec.att_total_no_of_orders := l_imp_rec.att_total_no_of_orders;
                     l_reg_rec.att_total_order_amount := l_imp_rec.att_total_order_amount;
                     l_reg_rec.att_year_established := l_imp_rec.att_year_establised;
                     l_reg_rec.att_url := l_imp_rec.att_url;
                     l_reg_rec.att_survey_notes := l_imp_rec.att_servey_notes;
                     l_reg_rec.att_contact_me_flag := l_imp_rec.att_contact_me_flag;
                     l_reg_rec.att_email_ok_flag := l_imp_rec.att_email_ok_flag;
                     -- soagrawa 27-feb-2003 bug# 2824593
                     IF l_upd_flag IS NOT null
                     THEN
                        IF l_upd_flag = 'Y'
                        THEN
                           l_reg_rec.update_reg_rec := 'Y';
                        ELSIF l_upd_flag = 'N'
                        THEN
                           l_reg_rec.update_reg_rec := 'C';
                        END IF;
                     END IF;

                     AMS_Registrants_PUB.Register(  p_api_version_number      => 1.0
                                                  , p_init_msg_list           => FND_API.G_FALSE
                                                  , p_commit                  => FND_API.G_FALSE
                                                  , x_return_status           => l_return_status
                                                  , x_msg_count               => l_msg_count
                                                  , x_msg_data                => l_msg_data
                                                  , p_reg_det_rec             => l_reg_rec
-- soagrawa 30-jan-2003  bug# 2769511
--                                                  , p_owner_user_id           => -1 -- what do we do with this?
                                                  , p_owner_user_id           => ams_utility_pvt.get_resource_id(FND_GLOBAL.user_id)
                                                  , p_application_id          => 530
                                                  , x_confirm_code            => l_conf_code
                                                 );
                     l_processed_rows := l_processed_rows+1;
                     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        l_failed_rows := l_failed_rows+1;
                     END IF;

--                     BEGIN
                     update_imp_src_line_rec(  p_imp_src_id    => l_imp_rec.import_source_line_id
                                             , p_imp_hdr_id    => l_hdr_id
                                             , p_return_status => l_return_status
                                             , p_msg_data      => l_msg_data
                                             , p_msg_count     => l_msg_count  -- Added by ptendulk on 21-Dec-2002
                                             , p_out_status    => l_out_status
                                            );
-- soagrawa added out status on 03-feb-2003 for error threshold
                     IF (l_out_status = FND_API.G_RET_STS_ERROR) THEN
                        RETURN;
                     END IF;
--                     EXCEPTION
--                        WHEN error_threshold_exc THEN
--                          RAISE error_threshold_exc;
--                     END;

                     fetch c_get_lines
                     into l_imp_rec;
                     l_cnt2 := l_cnt2 + 1;
                  END LOOP; -- Inner LOOP for line rec
                  CLOSE c_get_lines;
               END IF;
               update_imp_hdr_rec(  p_imp_hdr_id     => l_hdr_id
                                  , p_processed_rows => l_processed_rows
                                  , p_failed_rows    => l_failed_rows
                                 );
               IF (p_list_header_id is null)
               THEN
                  FETCH c_get_header_id
                  into l_hdr_id,
                       l_processed_rows,
                       l_failed_rows,
   -- soagrawa 05-feb-2003 fixed bug# 2773827
                       l_upd_flag;
               ELSE
                  FETCH c_get_row_metadata
                  into l_processed_rows,
                       l_failed_rows,
   -- soagrawa 05-feb-2003 fixed bug# 2773827
                       l_upd_flag;
               END IF;
               l_cnt1 := l_cnt1 + 1;
            END LOOP;
         ELSE
             -- dbiswas replaced nvl values for l_processed_rows and l_failed_rows with 0 initial val on
             -- 14-apr-2003 to fix bug 2834282
             -- l_processed_rows := nvl(l_processed_rows, 0);
             -- l_failed_rows := nvl(l_failed_rows, 0);
               l_processed_rows := 0;
               l_failed_rows := 0;

               open c_get_lines(p_list_header_id);
               fetch c_get_lines into l_imp_rec;
               IF c_get_lines%NOTFOUND THEN
                  CLOSE c_get_lines;
                  --FND_FILE.PUT_LINE(FND_FILE.LOG,'No Line RECORD TO Process at this time');
                  Ams_Utility_PVT.Create_Log (
                     x_return_status   => l_return_status_log,
                     p_arc_log_used_by => l_used_by,
                     p_log_used_by_id  => p_list_header_id,
                     p_msg_data        => 'No Line RECORD TO Process at this time'
                  );
                  --DBMS_OUTPUT.put_line('No line RECORD available Process');
               ELSE
                  LOOP
                     exit WHEN c_get_lines%NOTFOUND;
                     --DBMS_OUTPUT.put_line('In side second loop'||l_cnt1||' ' ||l_cnt2);
                     Ams_Utility_PVT.Create_Log(  x_return_status   => l_return_status_log
                                                , p_arc_log_used_by => l_used_by
                                                , p_log_used_by_id  => p_list_header_id
                                                , p_msg_data        => '----Processing the record whose source Line Id is '
                                                                       || to_char(l_imp_rec.import_source_line_id) || '----'
                                               );
      /*
                     --l_reg_rec.EVENT_REGISTRATION_ID := to_number(l_imp_rec.EVENT_REGISTRATION_ID);
                     l_reg_rec.LAST_UPDATE_DATE:= l_imp_rec.LAST_UPDATE_DATE;
                     l_reg_rec.LAST_UPDATED_BY := l_imp_rec.LAST_UPDATED_BY;
                     l_reg_rec.CREATION_DATE  := l_imp_rec.CREATION_DATE;
                     l_reg_rec.CREATED_BY := l_imp_rec.CREATED_BY ;
                     l_reg_rec.LAST_UPDATE_LOGIN := l_imp_rec.LAST_UPDATE_LOGIN ;
                     l_reg_rec.OBJECT_VERSION_NUMBER := 1;-- l_imp_rec.OBJECT_VERSION_NUMBER ,
                     l_reg_rec.EVENT_OFFER_ID := to_number(l_imp_rec.EVENT_OFFER_ID);
                     l_reg_rec.APPLICATION_ID := 530; --l_imp_rec.G_APPLICATION_ID;
                     l_reg_rec.ACTIVE_FLAG := l_imp_rec.ACTIVE_FLAG;
                     l_reg_rec.OWNER_USER_ID := l_imp_rec.OWNER_USER_ID;
                     l_reg_rec.SYSTEM_STATUS_CODE:= l_imp_rec.SYSTEM_STATUS_CODE;
                     l_reg_rec.DATE_REGISTRATION_PLACED:= to_date(l_imp_rec.DATE_REGISTRATION_PLACED);
                     l_reg_rec. USER_STATUS_ID:= to_number(l_imp_rec.USER_STATUS_ID) ;
                     l_reg_rec.LAST_REG_STATUS_DATE := to_date (l_imp_rec.LAST_REG_STATUS_DATE) ;
                     l_reg_rec.REG_SOURCE_TYPE_CODE := l_imp_rec.REG_SOURCE_TYPE_CODE;
                     l_reg_rec.REGISTRATION_SOURCE_ID := to_number(l_imp_rec.REGISTRATION_SOURCE_ID);
                     --l_reg_rec.CONFIRMATION_CODE := l_imp_rec.CONFIRMATION_CODE;
                     l_reg_rec.SOURCE_CODE := l_imp_rec.SOURCE_CODE ;
                     l_reg_rec.REGISTRATION_GROUP_ID :=to_number(l_imp_rec.REGISTRATION_GROUP_ID);
                     l_reg_rec.REGISTRANT_PARTY_ID := to_number(l_imp_rec.REGISTRANT_PARTY_ID);
                     l_reg_rec.REGISTRANT_CONTACT_ID := to_number(l_imp_rec.REGISTRANT_CONTACT_ID) ;
                     l_reg_rec.REGISTRANT_ACCOUNT_ID:= to_number(l_imp_rec.REGISTRANT_ACCOUNT_ID);
                     l_reg_rec.ATTENDANT_PARTY_ID := to_number(l_imp_rec.ATTENDANT_PARTY_ID);
                     l_reg_rec.ATTENDANT_CONTACT_ID := to_number(l_imp_rec.ATTENDANT_CONTACT_ID);
                     l_reg_rec.ATTENDANT_ACCOUNT_ID := to_number(l_imp_rec.ATTENDANT_ACCOUNT_ID);
                     l_reg_rec.ORIGINAL_REGISTRANT_CONTACT_ID := to_number(l_imp_rec.ORIGINAL_REGISTRANT_CONTACT_ID);
                     l_reg_rec.PROSPECT_FLAG := l_imp_rec.PROSPECT_FLAG ;
                     l_reg_rec.ATTENDED_FLAG := l_imp_rec.ATTENDED_FLAG ;
                     l_reg_rec.CONFIRMED_FLAG := l_imp_rec.CONFIRMED_FLAG ;
                     l_reg_rec.EVALUATED_FLAG := l_imp_rec.EVALUATED_FLAG ;
                     l_reg_rec.ATTENDANCE_RESULT_CODE := l_imp_rec.ATTENDANCE_RESULT_CODE ;
                     l_reg_rec.WAITLISTED_PRIORITY := to_number(l_imp_rec.WAITLISTED_PRIORITY);
                     l_reg_rec.TARGET_LIST_ID := to_number(l_imp_rec.TARGET_LIST_ID) ;
                     l_reg_rec.INBOUND_MEDIA_ID := to_number(l_imp_rec.INBOUND_MEDIA_ID);
                     l_reg_rec.INBOUND_CHANNEL_ID := to_number(l_imp_rec.INBOUND_CHANNEL_ID) ;
                     l_reg_rec.CANCELLATION_CODE := l_imp_rec.CANCELLATION_CODE ;
                     l_reg_rec.CANCELLATION_REASON_CODE := l_imp_rec.CANCELLATION_REASON_CODE ;
                     l_reg_rec.ATTENDANCE_FAILURE_REASON := l_imp_rec.ATTENDANCE_FAILURE_REASON ;
                     l_reg_rec.ATTENDANT_LANGUAGE := l_imp_rec.ATTENDANT_LANGUAGE ;
                     l_reg_rec.SALESREP_ID := to_number(l_imp_rec.SALESREP_ID) ;
                     l_reg_rec.ORDER_HEADER_ID := to_number(l_imp_rec.ORDER_HEADER_ID) ;
                     l_reg_rec.ORDER_LINE_ID := to_number(l_imp_rec.ORDER_LINE_ID);
                     l_reg_rec.DESCRIPTION := l_imp_rec.DESCRIPTION;
                     l_reg_rec.MAX_ATTENDEE_OVERRIDE_FLAG := l_imp_rec.MAX_ATTENDEE_OVERRIDE_FLAG ;
                     l_reg_rec.INVITE_ONLY_OVERRIDE_FLAG := l_imp_rec.INVITE_ONLY_OVERRIDE_FLAG;
                     l_reg_rec.PAYMENT_STATUS_CODE:= l_imp_rec.PAYMENT_STATUS_CODE;
                     l_reg_rec.AUTO_REGISTER_FLAG:= l_imp_rec.AUTO_REGISTER_FLAG;
                     l_reg_rec.ATTRIBUTE_CATEGORY := l_imp_rec.ATTRIBUTE_CATEGORY ;
                     l_reg_rec.ATTRIBUTE1 := l_imp_rec.ATTRIBUTE1;
                     l_reg_rec.ATTRIBUTE2 := l_imp_rec.ATTRIBUTE2 ;
                     l_reg_rec.ATTRIBUTE3 := l_imp_rec.ATTRIBUTE3;
                     l_reg_rec.ATTRIBUTE4 := l_imp_rec.ATTRIBUTE4;
                     l_reg_rec.ATTRIBUTE5 := l_imp_rec.ATTRIBUTE5;
                     l_reg_rec.ATTRIBUTE6 := l_imp_rec.ATTRIBUTE6;
                     l_reg_rec.ATTRIBUTE7 := l_imp_rec.ATTRIBUTE7;
                     l_reg_rec.ATTRIBUTE8 := l_imp_rec.ATTRIBUTE8;
                     l_reg_rec.ATTRIBUTE9 := l_imp_rec.ATTRIBUTE9;
                     l_reg_rec.ATTRIBUTE10 := l_imp_rec.ATTRIBUTE10;
                     l_reg_rec.ATTRIBUTE11 := l_imp_rec.ATTRIBUTE11;
                     l_reg_rec.ATTRIBUTE12  := l_imp_rec.ATTRIBUTE12;
                     l_reg_rec.ATTRIBUTE13 := l_imp_rec.ATTRIBUTE13;
                     l_reg_rec.ATTRIBUTE14 := l_imp_rec.ATTRIBUTE14;
                     l_reg_rec.ATTRIBUTE15 := l_imp_rec.ATTRIBUTE15;
      */
                     l_reg_rec.last_update_date := l_imp_rec.last_update_date;
                     l_reg_rec.last_updated_by := l_imp_rec.last_updated_by;
                     l_reg_rec.creation_date := l_imp_rec.creation_date;
                     l_reg_rec.created_by := l_imp_rec.created_by;
                     l_reg_rec.last_update_login := l_imp_rec.last_update_login;
                     -- Event Details
                     l_reg_rec.event_source_code := l_imp_rec.event_source_code;
                     l_reg_rec.registration_source_type := l_imp_rec.registration_source_type;
                     l_reg_rec.attendance_flag := l_imp_rec.attendance_flag;
                     l_reg_rec.waitlisted_flag := l_imp_rec.waitlisted_flag;
                     l_reg_rec.cancellation_flag := l_imp_rec.cancellation_flag;
                     l_reg_rec.cancellation_reason_code := l_imp_rec.cancellation_reason_code;
                     l_reg_rec.confirmation_code := l_imp_rec.confirmation_code;
                     l_reg_rec.original_system_reference := l_imp_rec.original_system_reference;
                       --Registrant Details
                     l_reg_rec.reg_party_id := l_imp_rec.reg_party_id;
                     l_reg_rec.reg_party_type := l_imp_rec.reg_party_type;
                     l_reg_rec.reg_contact_id := l_imp_rec.reg_contact_id;
                     l_reg_rec.reg_party_name := l_imp_rec.reg_party_name;
                     l_reg_rec.reg_title := l_imp_rec.reg_title;
                     l_reg_rec.reg_first_name := l_imp_rec.reg_first_name;
                     l_reg_rec.reg_middle_name := l_imp_rec.reg_middle_name;
                     l_reg_rec.reg_last_name := l_imp_rec.reg_last_name;
                     l_reg_rec.reg_address1 := l_imp_rec.reg_address1;
                     l_reg_rec.reg_address2 := l_imp_rec.reg_address2;
                     l_reg_rec.reg_address3 := l_imp_rec.reg_address3;
                     l_reg_rec.reg_address4 := l_imp_rec.reg_address4;
                     l_reg_rec.reg_gender := l_imp_rec.reg_gender;
                     l_reg_rec.reg_address_line_phonetic := l_imp_rec.reg_address_line_phoenetic;
                     l_reg_rec.reg_analysis_fy := l_imp_rec.reg_analysis_fy;
                     l_reg_rec.reg_apt_flag := l_imp_rec.reg_apt_flag;
                     l_reg_rec.reg_best_time_contact_begin := l_imp_rec.reg_best_time_contact_begin;
                     l_reg_rec.reg_best_time_contact_end := l_imp_rec.reg_best_time_contact_end;
                     l_reg_rec.reg_category_code := l_imp_rec.reg_category_code;
                     l_reg_rec.reg_ceo_name := l_imp_rec.reg_ceo_name;
                     l_reg_rec.reg_city := l_imp_rec.reg_city;
                     l_reg_rec.reg_country := l_imp_rec.reg_country;
                     l_reg_rec.reg_county := l_imp_rec.reg_county;
                     l_reg_rec.reg_current_fy_potential_rev := l_imp_rec.reg_current_fy_potential_rev;
                     l_reg_rec.reg_next_fy_potential_rev := l_imp_rec.reg_next_fy_potential_rev;
                     l_reg_rec.reg_household_income := l_imp_rec.reg_household_income;
                     l_reg_rec.reg_decision_maker_flag := l_imp_rec.reg_decision_maker_flag;
                     l_reg_rec.reg_department := l_imp_rec.reg_department;
                     l_reg_rec.reg_dun_no_c := l_imp_rec.reg_dun_no_c;
                     l_reg_rec.reg_email_address := l_imp_rec.reg_email_address;
                     l_reg_rec.reg_employee_total := l_imp_rec.reg_employee_total;
                     l_reg_rec.reg_fy_end_month := l_imp_rec.reg_fy_end_month;
                     l_reg_rec.reg_floor := l_imp_rec.reg_floor;
                     l_reg_rec.reg_gsa_indicator_flag := l_imp_rec.reg_gsa_indicator_flag;
                     l_reg_rec.reg_house_number := l_imp_rec.reg_house_number;
                     l_reg_rec.reg_identifying_address_flag := l_imp_rec.reg_identifying_address_flag;
                     l_reg_rec.reg_jgzz_fiscal_code := l_imp_rec.reg_jgzz_fiscal_code;
                     l_reg_rec.reg_job_title := l_imp_rec.reg_job_title;
                     l_reg_rec.reg_last_order_date := l_imp_rec.reg_last_order_date;
                     l_reg_rec.reg_org_legal_status := l_imp_rec.reg_org_legal_status;
                     l_reg_rec.reg_line_of_business := l_imp_rec.reg_line_of_business;
                     l_reg_rec.reg_mission_statement := l_imp_rec.reg_mission_statement;
                     l_reg_rec.reg_org_name_phonetic := l_imp_rec.reg_org_name_phoenetic;
                     l_reg_rec.reg_overseas_address_flag := l_imp_rec.reg_overseas_address_flag;
                     l_reg_rec.reg_name_suffix := l_imp_rec.reg_name_suffix;
                     l_reg_rec.reg_phone_area_code := l_imp_rec.reg_phone_area_code;
                     l_reg_rec.reg_phone_country_code := l_imp_rec.reg_phone_country_code;
                     l_reg_rec.reg_phone_extension := l_imp_rec.reg_phone_extension;
                     l_reg_rec.reg_phone_number := l_imp_rec.reg_phone_number;
                     l_reg_rec.reg_postal_code := l_imp_rec.reg_postal_code;
                     l_reg_rec.reg_postal_plus4_code := l_imp_rec.reg_postal_plus4_code;
                     l_reg_rec.reg_po_box_no := l_imp_rec.reg_po_box_no;
                     l_reg_rec.reg_province := l_imp_rec.reg_province;
                     l_reg_rec.reg_rural_route_no := l_imp_rec.reg_rural_route_no;
                     l_reg_rec.reg_rural_route_type := l_imp_rec.reg_rural_route_type;
                     l_reg_rec.reg_secondary_suffix_element := l_imp_rec.reg_secondary_suffix_element;
                     l_reg_rec.reg_sic_code := l_imp_rec.reg_sic_code;
                     l_reg_rec.reg_sic_code_type := l_imp_rec.reg_sic_code_type;
                     l_reg_rec.reg_site_use_code := l_imp_rec.reg_site_use_code;
                     l_reg_rec.reg_state := l_imp_rec.reg_state;
                     l_reg_rec.reg_street := l_imp_rec.reg_street;
                     l_reg_rec.reg_street_number := l_imp_rec.reg_street_number;
                     l_reg_rec.reg_street_suffix := l_imp_rec.reg_street_suffix;
                     l_reg_rec.reg_suite := l_imp_rec.reg_suite;
                     l_reg_rec.reg_tax_name := l_imp_rec.reg_tax_name;
                     l_reg_rec.reg_tax_reference := l_imp_rec.reg_tax_reference;
                     l_reg_rec.reg_timezone := l_imp_rec.reg_timezone;
                     l_reg_rec.reg_total_no_of_orders := l_imp_rec.reg_total_no_of_orders;
                     l_reg_rec.reg_total_order_amount := l_imp_rec.reg_total_order_amount;
                     l_reg_rec.reg_year_established := l_imp_rec.reg_year_establised;
                     l_reg_rec.reg_url := l_imp_rec.reg_url;
                     l_reg_rec.reg_survey_notes := l_imp_rec.reg_servey_notes;
                     l_reg_rec.reg_contact_me_flag := l_imp_rec.reg_contact_me_flag;
                     l_reg_rec.reg_email_ok_flag := l_imp_rec.reg_email_ok_flag;
                       -- Attendent Details
                     l_reg_rec.att_party_id := l_imp_rec.att_party_id;
                     l_reg_rec.att_party_type := l_imp_rec.att_party_type;
                     l_reg_rec.att_contact_id := l_imp_rec.att_contact_id;
                     l_reg_rec.att_party_name := l_imp_rec.att_party_name;
                     l_reg_rec.att_title := l_imp_rec.att_title;
                     l_reg_rec.att_first_name := l_imp_rec.att_first_name;
                     l_reg_rec.att_middle_name := l_imp_rec.att_middle_name;
                     l_reg_rec.att_last_name := l_imp_rec.att_last_name;
                     l_reg_rec.att_address1 := l_imp_rec.att_address1;
                     l_reg_rec.att_address2 := l_imp_rec.att_address2;
                     l_reg_rec.att_address3 := l_imp_rec.att_address3;
                     l_reg_rec.att_address4 := l_imp_rec.att_address4;
                     l_reg_rec.att_gender := l_imp_rec.att_gender;
                     l_reg_rec.att_address_line_phonetic := l_imp_rec.att_address_line_phoenetic;
                     l_reg_rec.att_analysis_fy := l_imp_rec.att_analysis_fy;
                     l_reg_rec.att_apt_flag := l_imp_rec.att_apt_flag;
                     l_reg_rec.att_best_time_contact_begin := l_imp_rec.att_best_time_contact_begin;
                     l_reg_rec.att_best_time_contact_end := l_imp_rec.att_best_time_contact_end;
                     l_reg_rec.att_category_code := l_imp_rec.att_category_code;
                     l_reg_rec.att_ceo_name := l_imp_rec.att_ceo_name;
                     l_reg_rec.att_city := l_imp_rec.att_city;
                     l_reg_rec.att_country := l_imp_rec.att_country;
                     l_reg_rec.att_county := l_imp_rec.att_county;
                     l_reg_rec.att_current_fy_potential_rev := l_imp_rec.att_current_fy_potential_rev;
                     l_reg_rec.att_next_fy_potential_rev := l_imp_rec.att_next_fy_potential_rev;
                     l_reg_rec.att_household_income := l_imp_rec.att_household_income;
                     l_reg_rec.att_decision_maker_flag := l_imp_rec.att_decision_maker_flag;
                     l_reg_rec.att_department := l_imp_rec.att_department;
                     l_reg_rec.att_dun_no_c := l_imp_rec.att_dun_no;
                     l_reg_rec.att_email_address := l_imp_rec.att_email_address;
                     l_reg_rec.att_employee_total := l_imp_rec.att_employee_total;
                     l_reg_rec.att_fy_end_month := l_imp_rec.att_fy_end_month;
                     l_reg_rec.att_floor := l_imp_rec.att_floor;
                     l_reg_rec.att_gsa_indicator_flag := l_imp_rec.att_gsa_indicator_flag;
                     l_reg_rec.att_house_number := l_imp_rec.att_house_number;
                     l_reg_rec.att_identifying_address_flag := l_imp_rec.att_identifying_address_flag;
                     l_reg_rec.att_jgzz_fiscal_code := l_imp_rec.att_jgzz_fiscal_code;
                     l_reg_rec.att_job_title := l_imp_rec.att_job_title;
                     l_reg_rec.att_last_order_date := l_imp_rec.att_last_order_date;
                     l_reg_rec.att_org_legal_status := l_imp_rec.att_legal_status;
                     l_reg_rec.att_line_of_business := l_imp_rec.att_line_of_business;
                     l_reg_rec.att_mission_statement := l_imp_rec.att_mission_statement;
                     l_reg_rec.att_org_name_phonetic := l_imp_rec.att_org_name_phoenetic;
                     l_reg_rec.att_overseas_address_flag := l_imp_rec.att_overseas_address_flag;
                     l_reg_rec.att_name_suffix := l_imp_rec.att_name_suffix;
                     l_reg_rec.att_phone_area_code := l_imp_rec.att_phone_area_code;
                     l_reg_rec.att_phone_country_code := l_imp_rec.att_phone_country_code;
                     l_reg_rec.att_phone_extension := l_imp_rec.att_phone_extension;
                     l_reg_rec.att_phone_number := l_imp_rec.att_phone_number;
                     l_reg_rec.att_postal_code := l_imp_rec.att_postal_code;
                     l_reg_rec.att_postal_plus4_code := l_imp_rec.att_postal_plus4_code;
                     l_reg_rec.att_po_box_no := l_imp_rec.att_po_box_no;
                     l_reg_rec.att_province := l_imp_rec.att_province;
                     l_reg_rec.att_rural_route_no := l_imp_rec.att_rural_route_no;
                     l_reg_rec.att_rural_route_type := l_imp_rec.att_rural_route_type;
                     l_reg_rec.att_secondary_suffix_element := l_imp_rec.att_secondary_suffix_element;
                     l_reg_rec.att_sic_code := l_imp_rec.att_sic_code;
                     l_reg_rec.att_sic_code_type := l_imp_rec.att_sic_code_type;
                     l_reg_rec.att_site_use_code := l_imp_rec.att_site_use_code;
                     l_reg_rec.att_state := l_imp_rec.att_state;
                     l_reg_rec.att_street := l_imp_rec.att_street;
                     l_reg_rec.att_street_number := l_imp_rec.att_street_number;
                     l_reg_rec.att_street_suffix := l_imp_rec.att_street_suffix;
                     l_reg_rec.att_suite := l_imp_rec.att_suite;
                     l_reg_rec.att_tax_name := l_imp_rec.att_tax_name;
                     l_reg_rec.att_tax_reference := l_imp_rec.att_tax_reference;
                     l_reg_rec.att_timezone := l_imp_rec.att_timezone;
                     l_reg_rec.att_total_no_of_orders := l_imp_rec.att_total_no_of_orders;
                     l_reg_rec.att_total_order_amount := l_imp_rec.att_total_order_amount;
                     l_reg_rec.att_year_established := l_imp_rec.att_year_establised;
                     l_reg_rec.att_url := l_imp_rec.att_url;
                     l_reg_rec.att_survey_notes := l_imp_rec.att_servey_notes;
                     l_reg_rec.att_contact_me_flag := l_imp_rec.att_contact_me_flag;
                     l_reg_rec.att_email_ok_flag := l_imp_rec.att_email_ok_flag;
                     -- soagrawa 27-feb-2003 bug# 2824593
                     IF l_upd_flag IS NOT null
                     THEN
                        IF l_upd_flag = 'Y'
                        THEN
                           l_reg_rec.update_reg_rec := 'Y';
                        ELSIF l_upd_flag = 'N'
                        THEN
                           l_reg_rec.update_reg_rec := 'C';
                        END IF;
                     END IF;

                     AMS_Registrants_PUB.Register(  p_api_version_number      => 1.0
                                                  , p_init_msg_list           => FND_API.G_FALSE
                                                  , p_commit                  => FND_API.G_FALSE
                                                  , x_return_status           => l_return_status
                                                  , x_msg_count               => l_msg_count
                                                  , x_msg_data                => l_msg_data
                                                  , p_reg_det_rec             => l_reg_rec
-- soagrawa 30-jan-2003  bug# 2769511
--                                                  , p_owner_user_id           => -1 -- what do we do with this?
                                                  , p_owner_user_id           => ams_utility_pvt.get_resource_id(FND_GLOBAL.user_id)
                                                  , p_application_id          => 530
                                                  , x_confirm_code            => l_conf_code
                                                 );
                     l_processed_rows := l_processed_rows+1;
                     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        l_failed_rows := l_failed_rows+1;
                     END IF;


--                     BEGIN
                     update_imp_src_line_rec(  p_imp_src_id    => l_imp_rec.import_source_line_id
                                             , p_imp_hdr_id    => p_list_header_id
                                             , p_return_status => l_return_status
                                             , p_msg_data      => l_msg_data
                                             , p_msg_count     => l_msg_count -- Added by ptendulk on 21-Dec-2002
                                             , p_out_status    => l_out_status
                                            );
-- soagrawa added out status on 03-feb-2003 for error threshold
                     IF (l_out_status = FND_API.G_RET_STS_ERROR) THEN
                        RETURN;
                     END IF;

--                     EXCEPTION
--                        WHEN error_threshold_exc THEN
--                          RAISE error_threshold_exc;
--                     END;

                     fetch c_get_lines
                     into l_imp_rec;
                     l_cnt2 := l_cnt2 + 1;
                  END LOOP; -- Inner LOOP for line rec
                  CLOSE c_get_lines;
               END IF;
               update_imp_hdr_rec(  p_imp_hdr_id     => p_list_header_id
                                  , p_processed_rows => l_processed_rows
                                  , p_failed_rows    => l_failed_rows
                                 );

         END IF;
         IF (p_list_header_id is null)
         THEN
            CLOSE c_get_header_id;
         ELSE
            CLOSE c_get_row_metadata;
         END IF;
   END IF;
   errbuf := SUBSTR(FND_MESSAGE.GET,1,240);
   retcode := 0;
   RETURN;


--EXCEPTION

--     WHEN error_threshold_exc THEN
--         RETURN;

END LoadProcess;

-- soagrawa added out status on 03-feb-2003 for error threshold
PROCEDURE update_imp_src_line_rec(p_imp_src_id IN NUMBER
         , p_imp_hdr_id         IN NUMBER
         , p_return_status    IN  VARCHAR2
         , p_msg_data         IN  VARCHAR2
         , p_msg_count        IN  NUMBER
         , p_out_status       OUT NOCOPY VARCHAR2 )
IS
   l_msg_count NUMBER;
   l_return_status_log varchar2(30);
   l_used_by varchar2(30);
   l_msg_data  varchar2(2000);
   l_return_status_ec varchar2(1);
   l_msg_count_ec number;
   l_msg_data_ec varchar2(2000);
   l_tmp_var VARCHAR2(2000);
--   error_threshold_exc exception;
BEGIN
   p_out_status := FND_API.g_ret_sts_success;
   l_used_by := 'IMPH';   --'EVENT_REG_IMPORT';
   --DBMS_OUTPUT.put_line('Inside update_imp_src_line_rec' || p_return_status || ' ' || p_imp_src_id );
   IF (p_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      --FND_FILE.PUT_LINE(FND_FILE.LOG,'Record proceesed sucessfully = ' || p_imp_src_id );
      l_msg_data := 'Record proceesed sucessfully ';
      Ams_Utility_PVT.Create_Log (
            x_return_status   => l_return_status_log,
             p_arc_log_used_by => l_used_by,
            p_log_used_by_id  => p_imp_hdr_id,
             p_msg_data        => l_msg_data
         );
      UPDATE ams_imp_source_lines
      SET    import_successful_flag = 'Y',
             load_status = 'SUCCESS'    -- This line is added by ptendulk on 13-Jun-02
      WHERE  import_source_line_id = p_imp_src_id;
   ELSE
      -- The following code is modified by ptendulk on 21-Dec-2002 to capture error in one variable
      -- instead of stack and then send it to error_capture process.
      --FND_FILE.PUT_LINE(FND_FILE.LOG,'Record Not proceesed = ' || p_imp_src_id );
      /*
      l_msg_data := 'Processing failed for the record whose sourceline Id is ' || p_imp_src_id || '. Check the log table for detail error message';
      Ams_Utility_PVT.Create_Log (
            x_return_status   => l_return_status_log,
             p_arc_log_used_by => l_used_by,
            p_log_used_by_id  => p_imp_hdr_id,
             p_msg_data        => l_msg_data
         );

      AMS_List_Import_PUB.error_capture(  p_api_version           => 1.0
                                        , x_return_status         => l_return_status_ec
                                        , x_msg_count             => l_msg_count_ec
                                        , x_msg_data              => l_msg_data_ec
                                        , p_import_list_header_id => p_imp_hdr_id
                                        , p_import_source_line_id => p_imp_src_id
                                        , p_imp_xml_element_id    => null
                                        , p_imp_xml_attribute_id  => null
                                        , p_field_name            => null
                                        , p_error_text            => l_msg_data
                                       );
      --FND_FILE.PUT_LINE(FND_FILE.LOG,'check the log table for detail error message ');
      l_msg_count := FND_MSG_PUB.count_msg;
      FOR i IN 1..FND_MSG_PUB.count_msg LOOP
         l_msg_data := FND_MSG_PUB.get(i, FND_API.G_FALSE);
         AMS_List_Import_PUB.error_capture(  p_api_version           => 1.0
                                           , x_return_status         => l_return_status_ec
                                           , x_msg_count             => l_msg_count_ec
                                           , x_msg_data              => l_msg_data_ec
                                           , p_import_list_header_id => p_imp_hdr_id
                                           , p_import_source_line_id => p_imp_src_id
                                           , p_imp_xml_element_id    => null
                                           , p_imp_xml_attribute_id  => null
                                           , p_field_name            => null
                                           , p_error_text            => l_msg_data
                                          ); */
/*
         Ams_Utility_PVT.Create_Log (
            x_return_status   => l_return_status_log,
             p_arc_log_used_by => l_used_by,
            p_log_used_by_id  => p_imp_hdr_id,
             p_msg_data        => l_msg_data
         );
         END LOOP;
      FND_MSG_PUB.initialize;
*/


      FOR i IN 1..p_msg_count  LOOP
         -- soagrawa 17-feb-2003   now passing index to fnd msg pub get for bug# 2769511
         l_tmp_var := fnd_msg_pub.get(i, p_encoded => fnd_api.g_false);
         l_msg_data := SUBSTR((l_msg_data || (i ||'. ')|| l_tmp_var),1,2000);
      END LOOP;
      AMS_List_Import_PUB.error_capture(  p_api_version           => 1.0
                                           , x_return_status         => l_return_status_ec
                                           , x_msg_count             => l_msg_count_ec
                                           , x_msg_data              => l_msg_data_ec
                                           , p_import_list_header_id => p_imp_hdr_id
                                           , p_import_source_line_id => p_imp_src_id
                                           , p_imp_xml_element_id    => null
                                           , p_imp_xml_attribute_id  => null
                                           , p_field_name            => null
                                           , p_error_text            => l_msg_data
                                          );

-- soagrawa added out status on 03-feb-2003 for error threshold
      IF l_return_status_ec  = FND_API.G_RET_STS_ERROR THEN
            p_out_status := FND_API.G_RET_STS_ERROR;
      END IF;

      UPDATE ams_imp_source_lines
      SET import_successful_flag = 'N',
          load_status = 'ERROR',   -- This line is added by ptendulk on 13-Jun-2002
          import_failure_reason = p_msg_data
      where import_source_line_id = p_imp_src_id;
      FND_MSG_PUB.initialize;
   END IF;
END;

PROCEDURE update_imp_hdr_rec(p_imp_hdr_id IN NUMBER
         , p_processed_rows    IN  NUMBER
         , p_failed_rows       IN  NUMBER)
IS
l_return_status         VARCHAR2(1);
BEGIN
   --FND_FILE.PUT_LINE(FND_FILE.LOG,'No RECORD TO Processed = ' || p_processed_rows );
   Ams_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
             p_arc_log_used_by => G_ARC_IMPORT_HEADER,
            p_log_used_by_id  => p_imp_hdr_id,
             p_msg_data        => '----No RECORD TO Processed = ' || p_processed_rows
         );
   IF (p_failed_rows > 0) THEN
      --FND_FILE.PUT_LINE(FND_FILE.LOG,'No of Failed Records' || p_failed_rows || '----');
      Ams_Utility_PVT.Create_Log (
            x_return_status   => l_return_status,
             p_arc_log_used_by => G_ARC_IMPORT_HEADER,
            p_log_used_by_id  => p_imp_hdr_id,
             p_msg_data        => 'No of Failed Records' || p_failed_rows
         );
      --FND_FILE.PUT_LINE(FND_FILE.LOG,'check the log table for detail error message');
   END IF;
   --DBMS_OUTPUT.put_line('Inside update_imp_hdr_line_rec');
   UPDATE ams_imp_list_headers_all
   SET processed_rows = p_processed_rows,
       number_of_failed_records = p_failed_rows
   WHERE import_list_header_id = p_imp_hdr_id;
END;


END ams_imp_reg_detail_pvt;

/
