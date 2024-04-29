--------------------------------------------------------
--  DDL for Package Body ARH_DQM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_DQM_PKG" AS
/*$Header: ARHDQMFB.pls 120.4 2005/06/16 21:11:00 jhuang noship $*/
FUNCTION AddList
( p_dsplist1     dsplist,
  p_dsplist2     dsplist)
RETURN dsplist
IS
  l_dsplist   dsplist;
  i           NUMBER;
  j           NUMBER;
BEGIN
  l_dsplist := p_dsplist1;
  i  := p_dsplist1.COUNT;
  j  := p_dsplist2.COUNT;
  IF j > 0 THEN
    FOR k IN 1..j LOOP
      l_dsplist(i+k) := p_dsplist2(j);
    END LOOP;
  END IF;
  RETURN l_dsplist;
END;

FUNCTION IsNull
-- Return TRUE if the dqm record type argument has all its attributes to NULL
( p_party         IN hz_party_search.party_search_rec_type)
RETURN BOOLEAN
IS
BEGIN
  IF    p_party.line_of_business               IS NULL
    AND p_party.local_activity_code            IS NULL
    AND p_party.local_activity_code_type       IS NULL
    AND p_party.local_bus_identifier           IS NULL
    AND p_party.local_bus_iden_type            IS NULL
    AND p_party.maximum_credit_currency_code   IS NULL
    AND p_party.maximum_credit_recommendation  IS NULL
    AND p_party.minority_owned_ind             IS NULL
    AND p_party.minority_owned_type            IS NULL
    AND p_party.next_fy_potential_revenue      IS NULL
    AND p_party.oob_ind                        IS NULL
    AND p_party.organization_name              IS NULL
    AND p_party.organization_name_phonetic     IS NULL
    AND p_party.organization_type              IS NULL
    AND p_party.parent_sub_ind                 IS NULL
    AND p_party.paydex_norm                    IS NULL
    AND p_party.paydex_score                   IS NULL
    AND p_party.paydex_three_months_ago        IS NULL
    AND p_party.pref_functional_currency       IS NULL
    AND p_party.principal_name                 IS NULL
    AND p_party.principal_title                IS NULL
    AND p_party.public_private_ownership_flag  IS NULL
    AND p_party.registration_type              IS NULL
    AND p_party.rent_own_ind                   IS NULL
    AND p_party.sic_code                       IS NULL
    AND p_party.sic_code_type                  IS NULL
    AND p_party.small_bus_ind                  IS NULL
    AND p_party.tax_name                       IS NULL
    AND p_party.tax_reference                  IS NULL
    AND p_party.total_employees_text           IS NULL
    AND p_party.total_emp_est_ind              IS NULL
    AND p_party.total_emp_min_ind              IS NULL
    AND p_party.total_employees_ind            IS NULL
    AND p_party.total_payments                 IS NULL
    AND p_party.woman_owned_ind                IS NULL
    AND p_party.year_established               IS NULL
    AND p_party.category_code                  IS NULL
    AND p_party.competitor_flag                IS NULL
    AND p_party.do_not_mail_flag               IS NULL
    AND p_party.group_type                     IS NULL
    AND p_party.language_name                  IS NULL
    AND p_party.party_name                     IS NULL
    AND p_party.party_number                   IS NULL
    AND p_party.party_type                     IS NULL
    AND p_party.reference_use_flag             IS NULL
    AND p_party.salutation                     IS NULL
    AND p_party.status                         IS NULL
    AND p_party.third_party_flag               IS NULL
    AND p_party.validated_flag                 IS NULL
    AND p_party.date_of_birth                  IS NULL
    AND p_party.date_of_death                  IS NULL
    AND p_party.effective_start_date           IS NULL
    AND p_party.effective_end_date             IS NULL
    AND p_party.declared_ethnicity             IS NULL
    AND p_party.gender                         IS NULL
    AND p_party.head_of_household_flag         IS NULL
    AND p_party.household_income               IS NULL
    AND p_party.household_size                 IS NULL
    AND p_party.last_known_gps                 IS NULL
    AND p_party.marital_status                 IS NULL
    AND p_party.marital_status_effective_date  IS NULL
    AND p_party.middle_name_phonetic           IS NULL
    AND p_party.personal_income                IS NULL
    AND p_party.person_academic_title          IS NULL
    AND p_party.person_first_name              IS NULL
    AND p_party.person_first_name_phonetic     IS NULL
    AND p_party.person_identifier              IS NULL
    AND p_party.person_iden_type               IS NULL
    AND p_party.person_initials                IS NULL
    AND p_party.person_last_name               IS NULL
    AND p_party.person_last_name_phonetic      IS NULL
    AND p_party.person_middle_name             IS NULL
    AND p_party.person_name                    IS NULL
    AND p_party.person_name_phonetic           IS NULL
    AND p_party.person_name_suffix             IS NULL
    AND p_party.person_previous_last_name      IS NULL
    AND p_party.person_pre_name_adjunct        IS NULL
    AND p_party.person_title                   IS NULL
    AND p_party.place_of_birth                 IS NULL
    AND p_party.all_account_names              IS NULL
    AND p_party.all_account_numbers            IS NULL
    AND p_party.custom_attribute1              IS NULL
    AND p_party.custom_attribute10             IS NULL
    AND p_party.custom_attribute11             IS NULL
    AND p_party.custom_attribute12             IS NULL
    AND p_party.custom_attribute13             IS NULL
    AND p_party.custom_attribute14             IS NULL
    AND p_party.custom_attribute15             IS NULL
    AND p_party.custom_attribute16             IS NULL
    AND p_party.custom_attribute17             IS NULL
    AND p_party.custom_attribute18             IS NULL
    AND p_party.custom_attribute19             IS NULL
    AND p_party.custom_attribute2              IS NULL
    AND p_party.custom_attribute20             IS NULL
    AND p_party.custom_attribute21             IS NULL
    AND p_party.custom_attribute22             IS NULL
    AND p_party.custom_attribute23             IS NULL
    AND p_party.custom_attribute24             IS NULL
    AND p_party.custom_attribute25             IS NULL
    AND p_party.custom_attribute26             IS NULL
    AND p_party.custom_attribute27             IS NULL
    AND p_party.custom_attribute28             IS NULL
    AND p_party.custom_attribute29             IS NULL
    AND p_party.custom_attribute3              IS NULL
    AND p_party.custom_attribute30             IS NULL
    AND p_party.custom_attribute4              IS NULL
    AND p_party.custom_attribute5              IS NULL
    AND p_party.custom_attribute6              IS NULL
    AND p_party.custom_attribute7              IS NULL
    AND p_party.custom_attribute8              IS NULL
    AND p_party.custom_attribute9              IS NULL
    AND p_party.analysis_fy                    IS NULL
    AND p_party.avg_high_credit                IS NULL
    AND p_party.best_time_contact_begin        IS NULL
    AND p_party.best_time_contact_end          IS NULL
    AND p_party.branch_flag                    IS NULL
    AND p_party.business_scope                 IS NULL
    AND p_party.ceo_name                       IS NULL
    AND p_party.ceo_title                      IS NULL
    AND p_party.cong_dist_code                 IS NULL
    AND p_party.content_source_number          IS NULL
    AND p_party.content_source_type            IS NULL
    AND p_party.control_yr                     IS NULL
    AND p_party.corporation_class              IS NULL
    AND p_party.credit_score                   IS NULL
    AND p_party.credit_score_age               IS NULL
    AND p_party.credit_score_class             IS NULL
    AND p_party.credit_score_commentary        IS NULL
    AND p_party.credit_score_commentary10      IS NULL
    AND p_party.credit_score_commentary2       IS NULL
    AND p_party.credit_score_commentary3       IS NULL
    AND p_party.credit_score_commentary4       IS NULL
    AND p_party.credit_score_commentary5       IS NULL
    AND p_party.credit_score_commentary6       IS NULL
    AND p_party.credit_score_commentary7       IS NULL
    AND p_party.credit_score_commentary8       IS NULL
    AND p_party.credit_score_commentary9       IS NULL
    AND p_party.credit_score_date              IS NULL
    AND p_party.credit_score_incd_default      IS NULL
    AND p_party.credit_score_natl_percentile   IS NULL
    AND p_party.curr_fy_potential_revenue      IS NULL
    AND p_party.db_rating                      IS NULL
    AND p_party.debarments_count               IS NULL
    AND p_party.debarments_date                IS NULL
    AND p_party.debarment_ind                  IS NULL
    AND p_party.disadv_8a_ind                  IS NULL
    AND p_party.duns_number_c                  IS NULL
    AND p_party.employees_total                IS NULL
    AND p_party.emp_at_primary_adr             IS NULL
    AND p_party.emp_at_primary_adr_est_ind     IS NULL
    AND p_party.emp_at_primary_adr_min_ind     IS NULL
    AND p_party.emp_at_primary_adr_text        IS NULL
    AND p_party.enquiry_duns                   IS NULL
    AND p_party.export_ind                     IS NULL
    AND p_party.failure_score                  IS NULL
    AND p_party.failure_score_age              IS NULL
    AND p_party.failure_score_class            IS NULL
    AND p_party.failure_score_commentary       IS NULL
    AND p_party.failure_score_commentary10     IS NULL
    AND p_party.failure_score_commentary2      IS NULL
    AND p_party.failure_score_commentary3      IS NULL
    AND p_party.failure_score_commentary4      IS NULL
    AND p_party.failure_score_commentary5      IS NULL
    AND p_party.failure_score_commentary6      IS NULL
    AND p_party.failure_score_commentary7      IS NULL
    AND p_party.failure_score_commentary8      IS NULL
    AND p_party.failure_score_commentary9      IS NULL
    AND p_party.failure_score_date             IS NULL
    AND p_party.failure_score_incd_default     IS NULL
    AND p_party.failure_score_override_code    IS NULL
    AND p_party.fiscal_yearend_month           IS NULL
    AND p_party.global_failure_score           IS NULL
    AND p_party.gsa_indicator_flag             IS NULL
    AND p_party.high_credit                    IS NULL
    AND p_party.hq_branch_ind                  IS NULL
    AND p_party.import_ind                     IS NULL
    AND p_party.incorp_year                    IS NULL
    AND p_party.internal_flag                  IS NULL
    AND p_party.jgzz_fiscal_code               IS NULL
    AND p_party.party_all_names                IS NULL
    AND p_party.known_as                       IS NULL
    AND p_party.known_as2                      IS NULL
    AND p_party.known_as3                      IS NULL
    AND p_party.known_as4                      IS NULL
    AND p_party.known_as5                      IS NULL
    AND p_party.labor_surplus_ind              IS NULL
    AND p_party.legal_status                   IS NULL
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

FUNCTION IsNull
( p_party_site    IN hz_party_search.party_site_search_rec_type)
RETURN BOOLEAN
IS
BEGIN
  IF    p_party_site.party_site_number              IS NULL
    AND p_party_site.custom_attribute16             IS NULL
    AND p_party_site.custom_attribute17             IS NULL
    AND p_party_site.custom_attribute18             IS NULL
    AND p_party_site.custom_attribute19             IS NULL
    AND p_party_site.custom_attribute2              IS NULL
    AND p_party_site.custom_attribute20             IS NULL
    AND p_party_site.custom_attribute21             IS NULL
    AND p_party_site.custom_attribute22             IS NULL
    AND p_party_site.custom_attribute23             IS NULL
    AND p_party_site.custom_attribute24             IS NULL
    AND p_party_site.custom_attribute25             IS NULL
    AND p_party_site.custom_attribute26             IS NULL
    AND p_party_site.custom_attribute27             IS NULL
    AND p_party_site.custom_attribute28             IS NULL
    AND p_party_site.custom_attribute29             IS NULL
    AND p_party_site.custom_attribute3              IS NULL
    AND p_party_site.custom_attribute30             IS NULL
    AND p_party_site.custom_attribute4              IS NULL
    AND p_party_site.custom_attribute5              IS NULL
    AND p_party_site.custom_attribute6              IS NULL
    AND p_party_site.custom_attribute7              IS NULL
    AND p_party_site.custom_attribute8              IS NULL
    AND p_party_site.custom_attribute9              IS NULL
    AND p_party_site.address1                       IS NULL
    AND p_party_site.address2                       IS NULL
    AND p_party_site.address3                       IS NULL
    AND p_party_site.address4                       IS NULL
    AND p_party_site.floor                          IS NULL
    AND p_party_site.house_number                   IS NULL
    AND p_party_site.language                       IS NULL
    AND p_party_site.clli_code                      IS NULL
    AND p_party_site.content_source_type            IS NULL
    AND p_party_site.country                        IS NULL
    AND p_party_site.county                         IS NULL
    AND p_party_site.trailing_directory_code        IS NULL
    AND p_party_site.validated_flag                 IS NULL
    AND p_party_site.identifying_address_flag       IS NULL
    AND p_party_site.mailstop                       IS NULL
    AND p_party_site.party_site_name                IS NULL
    AND p_party_site.address                        IS NULL
    AND p_party_site.custom_attribute1              IS NULL
    AND p_party_site.custom_attribute10             IS NULL
    AND p_party_site.custom_attribute11             IS NULL
    AND p_party_site.custom_attribute12             IS NULL
    AND p_party_site.custom_attribute13             IS NULL
    AND p_party_site.custom_attribute14             IS NULL
    AND p_party_site.custom_attribute15             IS NULL
    AND p_party_site.city                           IS NULL
    AND p_party_site.address_effective_date         IS NULL
    AND p_party_site.address_expiration_date        IS NULL
    AND p_party_site.address_lines_phonetic         IS NULL
    AND p_party_site.position                       IS NULL
    AND p_party_site.postal_code                    IS NULL
    AND p_party_site.postal_plus4_code              IS NULL
    AND p_party_site.po_box_number                  IS NULL
    AND p_party_site.province                       IS NULL
    AND p_party_site.sales_tax_geocode              IS NULL
    AND p_party_site.sales_tax_inside_city_limits   IS NULL
    AND p_party_site.state                          IS NULL
    AND p_party_site.street                         IS NULL
    AND p_party_site.street_number                  IS NULL
    AND p_party_site.street_suffix                  IS NULL
    AND p_party_site.suite                          IS NULL
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

FUNCTION IsNull
( p_contact       IN hz_party_search.contact_search_rec_type)
RETURN BOOLEAN
IS
BEGIN
  IF    p_contact.directional_flag               IS NULL
    AND p_contact.native_language                IS NULL
    AND p_contact.other_language_1               IS NULL
    AND p_contact.title                          IS NULL
    AND p_contact.custom_attribute1              IS NULL
    AND p_contact.custom_attribute10             IS NULL
    AND p_contact.custom_attribute11             IS NULL
    AND p_contact.custom_attribute12             IS NULL
    AND p_contact.custom_attribute13             IS NULL
    AND p_contact.custom_attribute14             IS NULL
    AND p_contact.custom_attribute15             IS NULL
    AND p_contact.custom_attribute16             IS NULL
    AND p_contact.custom_attribute17             IS NULL
    AND p_contact.custom_attribute18             IS NULL
    AND p_contact.custom_attribute19             IS NULL
    AND p_contact.custom_attribute2              IS NULL
    AND p_contact.custom_attribute20             IS NULL
    AND p_contact.custom_attribute21             IS NULL
    AND p_contact.custom_attribute22             IS NULL
    AND p_contact.custom_attribute23             IS NULL
    AND p_contact.custom_attribute24             IS NULL
    AND p_contact.custom_attribute25             IS NULL
    AND p_contact.custom_attribute26             IS NULL
    AND p_contact.custom_attribute27             IS NULL
    AND p_contact.custom_attribute28             IS NULL
    AND p_contact.custom_attribute29             IS NULL
    AND p_contact.custom_attribute3              IS NULL
    AND p_contact.custom_attribute30             IS NULL
    AND p_contact.custom_attribute4              IS NULL
    AND p_contact.custom_attribute5              IS NULL
    AND p_contact.custom_attribute6              IS NULL
    AND p_contact.mail_stop                      IS NULL
    AND p_contact.best_time_contact_end          IS NULL
    AND p_contact.job_title_code                 IS NULL
    AND p_contact.relationship_type              IS NULL
    AND p_contact.other_language_2               IS NULL
    AND p_contact.rank                           IS NULL
    AND p_contact.reference_use_flag             IS NULL
    AND p_contact.date_of_birth                  IS NULL
    AND p_contact.date_of_death                  IS NULL
    AND p_contact.jgzz_fiscal_code               IS NULL
    AND p_contact.known_as                       IS NULL
    AND p_contact.person_academic_title          IS NULL
    AND p_contact.person_first_name              IS NULL
    AND p_contact.person_first_name_phonetic     IS NULL
    AND p_contact.person_identifier              IS NULL
    AND p_contact.person_iden_type               IS NULL
    AND p_contact.person_initials                IS NULL
    AND p_contact.person_last_name               IS NULL
    AND p_contact.person_last_name_phonetic      IS NULL
    AND p_contact.person_middle_name             IS NULL
    AND p_contact.person_name                    IS NULL
    AND p_contact.person_name_phonetic           IS NULL
    AND p_contact.person_name_suffix             IS NULL
    AND p_contact.person_previous_last_name      IS NULL
    AND p_contact.person_title                   IS NULL
    AND p_contact.place_of_birth                 IS NULL
    AND p_contact.tax_name                       IS NULL
    AND p_contact.tax_reference                  IS NULL
    AND p_contact.content_source_type            IS NULL
    AND p_contact.job_title                      IS NULL
    AND p_contact.custom_attribute7              IS NULL
    AND p_contact.custom_attribute8              IS NULL
    AND p_contact.custom_attribute9              IS NULL
    AND p_contact.contact_number                 IS NULL
    AND p_contact.contact_name                   IS NULL
    AND p_contact.decision_maker_flag            IS NULL
    AND p_contact.best_time_contact_begin        IS NULL
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

FUNCTION IsNull
( p_contact_point IN hz_party_search.contact_point_search_rec_type)
RETURN BOOLEAN
IS
BEGIN
  IF    p_contact_point.phone_line_type                IS NULL
    AND p_contact_point.phone_number                   IS NULL
    AND p_contact_point.primary_flag                   IS NULL
    AND p_contact_point.raw_phone_number               IS NULL
    AND p_contact_point.telephone_type                 IS NULL
    AND p_contact_point.telex_number                   IS NULL
    AND p_contact_point.time_zone                      IS NULL
    AND p_contact_point.url                            IS NULL
    AND p_contact_point.web_type                       IS NULL
    AND p_contact_point.contact_point_type             IS NULL
    AND p_contact_point.custom_attribute1              IS NULL
    AND p_contact_point.custom_attribute10             IS NULL
    AND p_contact_point.edi_tp_header_id               IS NULL
    AND p_contact_point.custom_attribute5              IS NULL
    AND p_contact_point.custom_attribute6              IS NULL
    AND p_contact_point.custom_attribute4              IS NULL
    AND p_contact_point.edi_remittance_instruction     IS NULL
    AND p_contact_point.edi_transaction_handling       IS NULL
    AND p_contact_point.custom_attribute8              IS NULL
    AND p_contact_point.custom_attribute9              IS NULL
    AND p_contact_point.content_source_type            IS NULL
    AND p_contact_point.edi_ece_tp_location_code       IS NULL
    AND p_contact_point.edi_id_number                  IS NULL
    AND p_contact_point.edi_payment_format             IS NULL
    AND p_contact_point.custom_attribute12             IS NULL
    AND p_contact_point.custom_attribute13             IS NULL
    AND p_contact_point.custom_attribute14             IS NULL
    AND p_contact_point.custom_attribute15             IS NULL
    AND p_contact_point.custom_attribute16             IS NULL
    AND p_contact_point.custom_attribute17             IS NULL
    AND p_contact_point.custom_attribute18             IS NULL
    AND p_contact_point.custom_attribute19             IS NULL
    AND p_contact_point.custom_attribute2              IS NULL
    AND p_contact_point.custom_attribute20             IS NULL
    AND p_contact_point.custom_attribute21             IS NULL
    AND p_contact_point.custom_attribute22             IS NULL
    AND p_contact_point.custom_attribute23             IS NULL
    AND p_contact_point.custom_attribute24             IS NULL
    AND p_contact_point.custom_attribute25             IS NULL
    AND p_contact_point.custom_attribute26             IS NULL
    AND p_contact_point.custom_attribute27             IS NULL
    AND p_contact_point.custom_attribute28             IS NULL
    AND p_contact_point.custom_attribute29             IS NULL
    AND p_contact_point.custom_attribute3              IS NULL
    AND p_contact_point.custom_attribute30             IS NULL
    AND p_contact_point.custom_attribute11             IS NULL
    AND p_contact_point.email_address                  IS NULL
    AND p_contact_point.email_format                   IS NULL
    AND p_contact_point.flex_format_phone_number       IS NULL
    AND p_contact_point.last_contact_dt_time           IS NULL
    AND p_contact_point.phone_area_code                IS NULL
    AND p_contact_point.phone_calling_calendar         IS NULL
    AND p_contact_point.phone_country_code             IS NULL
    AND p_contact_point.phone_extension                IS NULL
    AND p_contact_point.edi_remittance_method          IS NULL
    AND p_contact_point.custom_attribute7              IS NULL
    AND p_contact_point.edi_payment_method             IS NULL
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

FUNCTION Contact_point_list
----------------------------------------------
-- Return a list of contact_point_search_rec by defaulting the contact_type
-- split 1 contact_point_search_rec into a list of record for different contact_type
-- Return an empty list if the in record type argument is null
----------------------------------------------
( p_contact_point  IN   hz_party_search.contact_point_search_rec_type,
  p_default_type   IN   VARCHAR2  DEFAULT 'PHONE')
RETURN hz_party_search.contact_point_list
IS
  l_list      hz_party_search.contact_point_list;
  l_reset_rec hz_party_search.contact_point_search_rec_type;
  l_rec       hz_party_search.contact_point_search_rec_type;
  l_init_rec  hz_party_search.contact_point_search_rec_type;
  i           NUMBER := 0;
BEGIN
  IF NOT IsNull(p_contact_point) THEN
    l_init_rec.primary_flag                   := p_contact_point.primary_flag;
    l_init_rec.time_zone                      := p_contact_point.time_zone;
    l_init_rec.custom_attribute1              := p_contact_point.custom_attribute1;
    l_init_rec.custom_attribute10             := p_contact_point.custom_attribute10;
    l_init_rec.custom_attribute5              := p_contact_point.custom_attribute5;
    l_init_rec.custom_attribute6              := p_contact_point.custom_attribute6;
    l_init_rec.custom_attribute4              := p_contact_point.custom_attribute4;
    l_init_rec.custom_attribute8              := p_contact_point.custom_attribute8;
    l_init_rec.custom_attribute9              := p_contact_point.custom_attribute9;
    l_init_rec.content_source_type            := p_contact_point.content_source_type;
    l_init_rec.custom_attribute12             := p_contact_point.custom_attribute12;
    l_init_rec.custom_attribute13             := p_contact_point.custom_attribute13;
    l_init_rec.custom_attribute14             := p_contact_point.custom_attribute14;
    l_init_rec.custom_attribute15             := p_contact_point.custom_attribute15;
    l_init_rec.custom_attribute16             := p_contact_point.custom_attribute16;
    l_init_rec.custom_attribute17             := p_contact_point.custom_attribute17;
    l_init_rec.custom_attribute18             := p_contact_point.custom_attribute18;
    l_init_rec.custom_attribute19             := p_contact_point.custom_attribute19;
    l_init_rec.custom_attribute2              := p_contact_point.custom_attribute2;
    l_init_rec.custom_attribute20             := p_contact_point.custom_attribute20;
    l_init_rec.custom_attribute21             := p_contact_point.custom_attribute21;
    l_init_rec.custom_attribute22             := p_contact_point.custom_attribute22;
    l_init_rec.custom_attribute23             := p_contact_point.custom_attribute23;
    l_init_rec.custom_attribute24             := p_contact_point.custom_attribute24;
    l_init_rec.custom_attribute25             := p_contact_point.custom_attribute25;
    l_init_rec.custom_attribute26             := p_contact_point.custom_attribute26;
    l_init_rec.custom_attribute27             := p_contact_point.custom_attribute27;
    l_init_rec.custom_attribute28             := p_contact_point.custom_attribute28;
    l_init_rec.custom_attribute29             := p_contact_point.custom_attribute29;
    l_init_rec.custom_attribute3              := p_contact_point.custom_attribute3;
    l_init_rec.custom_attribute30             := p_contact_point.custom_attribute30;
    l_init_rec.custom_attribute11             := p_contact_point.custom_attribute11;
    l_init_rec.last_contact_dt_time           := p_contact_point.last_contact_dt_time;
    l_init_rec.custom_attribute7              := p_contact_point.custom_attribute7;

    -- Phone type
    IF    p_contact_point.phone_line_type  IS NOT NULL
       OR p_contact_point.phone_number     IS NOT NULL
       OR p_contact_point.raw_phone_number IS NOT NULL
       OR p_contact_point.telephone_type   IS NOT NULL
       OR p_contact_point.flex_format_phone_number IS NOT NULL
       OR p_contact_point.phone_area_code  IS NOT NULL
       OR p_contact_point.phone_calling_calendar IS NOT NULL
       OR p_contact_point.phone_country_code IS NOT NULL
       OR p_contact_point.phone_extension  IS NOT NULL
    THEN
      l_rec                                := l_reset_rec;
      l_rec                                := l_init_rec;
      l_rec.contact_point_type             := 'PHONE';
      l_rec.phone_line_type                := p_contact_point.phone_line_type;
      l_rec.phone_number                   := p_contact_point.phone_number;
      l_rec.raw_phone_number               := p_contact_point.raw_phone_number;
      l_rec.telephone_type                 := p_contact_point.telephone_type;
      l_rec.flex_format_phone_number       := p_contact_point.flex_format_phone_number;
      l_rec.phone_area_code                := p_contact_point.phone_area_code;
      l_rec.phone_calling_calendar         := p_contact_point.phone_calling_calendar;
      l_rec.phone_country_code             := p_contact_point.phone_country_code;
      l_rec.phone_extension                := p_contact_point.phone_extension;
      i          :=  i + 1;
      l_list(i)  :=  l_rec;
    END IF;

    -- Telex type
    IF   p_contact_point.telex_number   IS NOT NULL THEN
      l_rec                                := l_reset_rec;
      l_rec                                := l_init_rec;
      l_rec.contact_point_type             := 'TLX';
      l_rec.telex_number                   := p_contact_point.telex_number;
      i          :=  i + 1;
      l_list(i)  :=  l_rec;
    END IF;

    -- Web type
    IF   p_contact_point.url      IS NOT NULL
      OR p_contact_point.web_type IS NOT NULL
    THEN
      l_rec                                := l_reset_rec;
      l_rec                                := l_init_rec;
      l_rec.contact_point_type             := 'WEB';
      l_rec.url                            := p_contact_point.url;
      l_rec.web_type                       := p_contact_point.web_type;
      i          :=  i + 1;
      l_list(i)  :=  l_rec;
    END IF;

    -- Edi type
    IF   p_contact_point.edi_tp_header_id         IS NOT NULL
      OR p_contact_point.edi_remittance_instruction IS NOT NULL
      OR p_contact_point.edi_transaction_handling IS NOT NULL
      OR p_contact_point.edi_ece_tp_location_code IS NOT NULL
      OR p_contact_point.edi_id_number            IS NOT NULL
      OR p_contact_point.edi_payment_format       IS NOT NULL
      OR p_contact_point.edi_remittance_method    IS NOT NULL
      OR p_contact_point.edi_payment_method       IS NOT NULL
    THEN
      l_rec                                := l_reset_rec;
      l_rec                                := l_init_rec;
      l_rec.contact_point_type             := 'EDI';
      l_rec.edi_tp_header_id               := p_contact_point.edi_tp_header_id;
      l_rec.edi_remittance_instruction     := p_contact_point.edi_remittance_instruction;
      l_rec.edi_transaction_handling       := p_contact_point.edi_transaction_handling;
      l_rec.edi_ece_tp_location_code       := p_contact_point.edi_ece_tp_location_code;
      l_rec.edi_id_number                  := p_contact_point.edi_id_number;
      l_rec.edi_payment_format             := p_contact_point.edi_payment_format;
      l_rec.edi_remittance_method          := p_contact_point.edi_remittance_method;
      l_rec.edi_payment_method             := p_contact_point.edi_payment_method;
      i          :=  i + 1;
      l_list(i)  :=  l_rec;
    END IF;

    -- Email type
    IF   p_contact_point.email_address  IS NOT NULL
      OR p_contact_point.email_format   IS NOT NULL
    THEN
      l_rec                                := l_reset_rec;
      l_rec                                := l_init_rec;
      l_rec.contact_point_type             := 'EMAIL';
      l_rec.email_address                  := p_contact_point.email_address;
      l_rec.email_format                   := p_contact_point.email_format;
      i          :=  i + 1;
      l_list(i)  :=  l_rec;
    END IF;

    IF l_list.COUNT = 0 THEN
      l_rec                                := l_reset_rec;
      l_rec                                := l_init_rec;
      l_rec.contact_point_type             := p_default_type;
      i          :=  i + 1;
      l_list(i)  :=  l_rec;
    END IF;
  END IF;
  RETURN l_list;
END Contact_point_list;

PROCEDURE Exec_Dqm_Api
( p_line_of_business               VARCHAR2,
  p_local_activity_code            VARCHAR2,
  p_local_activity_code_type       VARCHAR2,
  p_local_bus_identifier           VARCHAR2,
  p_local_bus_iden_type            VARCHAR2,
  p_max_credit_currency_code   VARCHAR2,
  p_max_credit_recommendation  NUMBER,
  p_minority_owned_ind             VARCHAR2,
  p_minority_owned_type            VARCHAR2,
  p_next_fy_potential_revenue      NUMBER,
  p_oob_ind                        VARCHAR2,
  p_organization_name              VARCHAR2,
  p_organization_name_phonetic     VARCHAR2,
  p_organization_type              VARCHAR2,
  p_parent_sub_ind                 VARCHAR2,
  p_paydex_norm                    VARCHAR2,
  p_paydex_score                   VARCHAR2,
  p_paydex_three_months_ago        VARCHAR2,
  p_pref_functional_currency       VARCHAR2,
  p_principal_name                 VARCHAR2,
  p_principal_title                VARCHAR2,
  p_public_private_ownership_fg  VARCHAR2,
  p_registration_type              VARCHAR2,
  p_rent_own_ind                   VARCHAR2,
  p_sic_code                       VARCHAR2,
  p_sic_code_type                  VARCHAR2,
  p_small_bus_ind                  VARCHAR2,
  p_tax_name                       VARCHAR2,
  p_tax_reference                  VARCHAR2,
  p_total_employees_text           VARCHAR2,
  p_total_emp_est_ind              VARCHAR2,
  p_total_emp_min_ind              VARCHAR2,
  p_total_employees_ind            VARCHAR2,
  p_total_payments                 NUMBER,
  p_woman_owned_ind                VARCHAR2,
  p_year_established               NUMBER,
  p_category_code                  VARCHAR2,
  p_competitor_fg                VARCHAR2,
  p_do_not_mail_fg               VARCHAR2,
  p_group_type                     VARCHAR2,
  p_language_name                  VARCHAR2,
  p_party_name                     VARCHAR2,
  p_party_number                   VARCHAR2,
  p_party_type                     VARCHAR2,
  p_reference_use_fg             VARCHAR2,
  p_salutation                     VARCHAR2,
  p_status                         VARCHAR2,
  p_third_party_fg               VARCHAR2,
  p_validated_fg                 VARCHAR2,
  p_date_of_birth                  DATE,
  p_date_of_death                  DATE,
  p_effective_start_date           DATE,
  p_effective_end_date             DATE,
  p_declared_ethnicity             VARCHAR2,
  p_gender                         VARCHAR2,
  p_head_of_household_fg         VARCHAR2,
  p_household_income               NUMBER,
  p_household_size                 NUMBER,
  p_last_known_gps                 VARCHAR2,
  p_mar_status                 VARCHAR2,
  p_mar_status_effective_date  DATE,
  p_middle_name_phonetic           VARCHAR2,
  p_personal_income                NUMBER,
  p_person_academic_title          VARCHAR2,
  p_person_first_name              VARCHAR2,
  p_person_first_name_phonetic     VARCHAR2,
  p_person_identifier              VARCHAR2,
  p_person_iden_type               VARCHAR2,
  p_person_initials                VARCHAR2,
  p_person_last_name               VARCHAR2,
  p_person_last_name_phonetic      VARCHAR2,
  p_person_middle_name             VARCHAR2,
  p_person_name                    VARCHAR2,
  p_person_name_phonetic           VARCHAR2,
  p_person_name_suffix             VARCHAR2,
  p_person_previous_last_name      VARCHAR2,
  p_person_pre_name_adjunct        VARCHAR2,
  p_person_title                   VARCHAR2,
  p_place_of_birth                 VARCHAR2,
  p_all_account_names              VARCHAR2,
  p_all_account_numbers            VARCHAR2,
  p_custom_attribute1              VARCHAR2,
  p_custom_attribute10             VARCHAR2,
  p_custom_attribute11             VARCHAR2,
  p_custom_attribute12             VARCHAR2,
  p_custom_attribute13             VARCHAR2,
  p_custom_attribute14             VARCHAR2,
  p_custom_attribute15             VARCHAR2,
  p_custom_attribute16             VARCHAR2,
  p_custom_attribute17             VARCHAR2,
  p_custom_attribute18             VARCHAR2,
  p_custom_attribute19             VARCHAR2,
  p_custom_attribute2              VARCHAR2,
  p_custom_attribute20             VARCHAR2,
  p_custom_attribute21             VARCHAR2,
  p_custom_attribute22             VARCHAR2,
  p_custom_attribute23             VARCHAR2,
  p_custom_attribute24             VARCHAR2,
  p_custom_attribute25             VARCHAR2,
  p_custom_attribute26             VARCHAR2,
  p_custom_attribute27             VARCHAR2,
  p_custom_attribute28             VARCHAR2,
  p_custom_attribute29             VARCHAR2,
  p_custom_attribute3              VARCHAR2,
  p_custom_attribute30             VARCHAR2,
  p_custom_attribute4              VARCHAR2,
  p_custom_attribute5              VARCHAR2,
  p_custom_attribute6              VARCHAR2,
  p_custom_attribute7              VARCHAR2,
  p_custom_attribute8              VARCHAR2,
  p_custom_attribute9              VARCHAR2,
  p_analysis_fy                    VARCHAR2,
  p_avg_high_credit                NUMBER,
  p_best_time_contact_begin        DATE,
  p_best_time_contact_end          DATE,
  p_branch_fg                    VARCHAR2,
  p_business_scope                 VARCHAR2,
  p_ceo_name                       VARCHAR2,
  p_ceo_title                      VARCHAR2,
  p_cong_dist_code                 VARCHAR2,
  p_content_source_number          VARCHAR2,
  p_content_source_type            VARCHAR2,
  p_control_yr                     NUMBER,
  p_corporation_class              VARCHAR2,
  p_credit_score                   VARCHAR2,
  p_credit_score_age               NUMBER,
  p_credit_score_class             NUMBER,
  p_credit_score_commentary        VARCHAR2,
  p_credit_score_commentary10      VARCHAR2,
  p_credit_score_commentary2       VARCHAR2,
  p_credit_score_commentary3       VARCHAR2,
  p_credit_score_commentary4       VARCHAR2,
  p_credit_score_commentary5       VARCHAR2,
  p_credit_score_commentary6       VARCHAR2,
  p_credit_score_commentary7       VARCHAR2,
  p_credit_score_commentary8       VARCHAR2,
  p_credit_score_commentary9       VARCHAR2,
  p_credit_score_date              DATE,
  p_credit_score_incd_default      NUMBER,
  p_credit_score_natl_percentile   NUMBER,
  p_curr_fy_potential_revenue      NUMBER,
  p_db_rating                      VARCHAR2,
  p_debarments_count               NUMBER,
  p_debarments_date                DATE,
  p_debarment_ind                  VARCHAR2,
  p_disadv_8a_ind                  VARCHAR2,
  p_duns_number_c                  VARCHAR2,
  p_employees_total                NUMBER,
  p_emp_at_primary_adr             VARCHAR2,
  p_emp_at_primary_adr_est_ind     VARCHAR2,
  p_emp_at_primary_adr_min_ind     VARCHAR2,
  p_emp_at_primary_adr_text        VARCHAR2,
  p_enquiry_duns                   VARCHAR2,
  p_export_ind                     VARCHAR2,
  p_failure_score                  VARCHAR2,
  p_failure_score_age              NUMBER,
  p_failure_score_class            NUMBER,
  p_failure_score_commentary       VARCHAR2,
  p_failure_score_commentary10     VARCHAR2,
  p_failure_score_commentary2      VARCHAR2,
  p_failure_score_commentary3      VARCHAR2,
  p_failure_score_commentary4      VARCHAR2,
  p_failure_score_commentary5      VARCHAR2,
  p_failure_score_commentary6      VARCHAR2,
  p_failure_score_commentary7      VARCHAR2,
  p_failure_score_commentary8      VARCHAR2,
  p_failure_score_commentary9      VARCHAR2,
  p_failure_score_date             DATE,
  p_failure_score_incd_default     NUMBER,
  p_failure_score_override_code    VARCHAR2,
  p_fiscal_yearend_month           VARCHAR2,
  p_global_failure_score           VARCHAR2,
  p_gsa_indicator_fg             VARCHAR2,
  p_high_credit                    NUMBER,
  p_hq_branch_ind                  VARCHAR2,
  p_import_ind                     VARCHAR2,
  p_incorp_year                    NUMBER,
  p_internal_fg                  VARCHAR2,
  p_jgzz_fiscal_code               VARCHAR2,
  p_party_all_names                VARCHAR2,
  p_known_as                       VARCHAR2,
  p_known_as2                      VARCHAR2,
  p_known_as3                      VARCHAR2,
  p_known_as4                      VARCHAR2,
  p_known_as5                      VARCHAR2,
  p_labor_surplus_ind              VARCHAR2,
  p_legal_status                   VARCHAR2,
--PS
  s_party_site_number              VARCHAR2,
  s_custom_attribute16             VARCHAR2,
  s_custom_attribute17             VARCHAR2,
  s_custom_attribute18             VARCHAR2,
  s_custom_attribute19             VARCHAR2,
  s_custom_attribute2              VARCHAR2,
  s_custom_attribute20             VARCHAR2,
  s_custom_attribute21             VARCHAR2,
  s_custom_attribute22             VARCHAR2,
  s_custom_attribute23             VARCHAR2,
  s_custom_attribute24             VARCHAR2,
  s_custom_attribute25             VARCHAR2,
  s_custom_attribute26             VARCHAR2,
  s_custom_attribute27             VARCHAR2,
  s_custom_attribute28             VARCHAR2,
  s_custom_attribute29             VARCHAR2,
  s_custom_attribute3              VARCHAR2,
  s_custom_attribute30             VARCHAR2,
  s_custom_attribute4              VARCHAR2,
  s_custom_attribute5              VARCHAR2,
  s_custom_attribute6              VARCHAR2,
  s_custom_attribute7              VARCHAR2,
  s_custom_attribute8              VARCHAR2,
  s_custom_attribute9              VARCHAR2,
  s_address1                       VARCHAR2,
  s_address2                       VARCHAR2,
  s_address3                       VARCHAR2,
  s_address4                       VARCHAR2,
  s_floor                          VARCHAR2,
  s_house_number                   VARCHAR2,
  s_language                       VARCHAR2,
  s_clli_code                      VARCHAR2,
  s_content_source_type            VARCHAR2,
  s_country                        VARCHAR2,
  s_county                         VARCHAR2,
  s_trailing_directory_code        VARCHAR2,
  s_validated_fg                 VARCHAR2,
  s_identifying_address_fg       VARCHAR2,
  s_mailstop                       VARCHAR2,
  s_party_site_name                VARCHAR2,
  s_address                        VARCHAR2,
  s_custom_attribute1              VARCHAR2,
  s_custom_attribute10             VARCHAR2,
  s_custom_attribute11             VARCHAR2,
  s_custom_attribute12             VARCHAR2,
  s_custom_attribute13             VARCHAR2,
  s_custom_attribute14             VARCHAR2,
  s_custom_attribute15             VARCHAR2,
  s_city                           VARCHAR2,
  s_address_effective_date         DATE,
  s_address_expiration_date        DATE,
  s_address_lines_phonetic         VARCHAR2,
  s_position                       VARCHAR2,
  s_postal_code                    VARCHAR2,
  s_postal_plus4_code              VARCHAR2,
  s_po_box_number                  VARCHAR2,
  s_province                       VARCHAR2,
  s_sales_tax_geocode              VARCHAR2,
  s_sales_tax_inside_city_limits   VARCHAR2,
  s_state                          VARCHAR2,
  s_street                         VARCHAR2,
  s_street_number                  VARCHAR2,
  s_street_suffix                  VARCHAR2,
  s_suite                          VARCHAR2,
--CT
  c_directional_fg               VARCHAR2,
  c_native_language                VARCHAR2,
  c_other_language_1               VARCHAR2,
  c_title                          VARCHAR2,
  c_custom_attribute1              VARCHAR2,
  c_custom_attribute10             VARCHAR2,
  c_custom_attribute11             VARCHAR2,
  c_custom_attribute12             VARCHAR2,
  c_custom_attribute13             VARCHAR2,
  c_custom_attribute14             VARCHAR2,
  c_custom_attribute15             VARCHAR2,
  c_custom_attribute16             VARCHAR2,
  c_custom_attribute17             VARCHAR2,
  c_custom_attribute18             VARCHAR2,
  c_custom_attribute19             VARCHAR2,
  c_custom_attribute2              VARCHAR2,
  c_custom_attribute20             VARCHAR2,
  c_custom_attribute21             VARCHAR2,
  c_custom_attribute22             VARCHAR2,
  c_custom_attribute23             VARCHAR2,
  c_custom_attribute24             VARCHAR2,
  c_custom_attribute25             VARCHAR2,
  c_custom_attribute26             VARCHAR2,
  c_custom_attribute27             VARCHAR2,
  c_custom_attribute28             VARCHAR2,
  c_custom_attribute29             VARCHAR2,
  c_custom_attribute3              VARCHAR2,
  c_custom_attribute30             VARCHAR2,
  c_custom_attribute4              VARCHAR2,
  c_custom_attribute5              VARCHAR2,
  c_custom_attribute6              VARCHAR2,
  c_mail_stop                      VARCHAR2,
  c_best_time_contact_end          DATE,
  c_job_title_code                 VARCHAR2,
  c_relationship_type              VARCHAR2,
  c_other_language_2               VARCHAR2,
  c_rank                           VARCHAR2,
  c_reference_use_fg             VARCHAR2,
  c_date_of_birth                  DATE,
  c_date_of_death                  DATE,
  c_jgzz_fiscal_code               VARCHAR2,
  c_known_as                       VARCHAR2,
  c_person_academic_title          VARCHAR2,
  c_person_first_name              VARCHAR2,
  c_person_first_name_phonetic     VARCHAR2,
  c_person_identifier              VARCHAR2,
  c_person_iden_type               VARCHAR2,
  c_person_initials                VARCHAR2,
  c_person_last_name               VARCHAR2,
  c_person_last_name_phonetic      VARCHAR2,
  c_person_middle_name             VARCHAR2,
  c_person_name                    VARCHAR2,
  c_person_name_phonetic           VARCHAR2,
  c_person_name_suffix             VARCHAR2,
  c_person_previous_last_name      VARCHAR2,
  c_person_title                   VARCHAR2,
  c_place_of_birth                 VARCHAR2,
  c_tax_name                       VARCHAR2,
  c_tax_reference                  VARCHAR2,
  c_content_source_type            VARCHAR2,
  c_job_title                      VARCHAR2,
  c_custom_attribute7              VARCHAR2,
  c_custom_attribute8              VARCHAR2,
  c_custom_attribute9              VARCHAR2,
  c_contact_number                 VARCHAR2,
  c_contact_name                   VARCHAR2,
  c_decision_maker_fg            VARCHAR2,
  c_best_time_contact_begin        DATE,
--CPT
  t_phone_line_type                VARCHAR2,
  t_phone_number                   VARCHAR2,
  t_primary_fg                   VARCHAR2,
  t_raw_phone_number               VARCHAR2,
  t_telephone_type                 VARCHAR2,
  t_telex_number                   VARCHAR2,
  t_time_zone                      NUMBER,
  t_url                            VARCHAR2,
  t_web_type                       VARCHAR2,
  t_contact_point_type             VARCHAR2,
  t_custom_attribute1              VARCHAR2,
  t_custom_attribute10             VARCHAR2,
  t_edi_tp_header_id               NUMBER,
  t_custom_attribute5              VARCHAR2,
  t_custom_attribute6              VARCHAR2,
  t_custom_attribute4              VARCHAR2,
  t_edi_remittance_instruction     VARCHAR2,
  t_edi_transaction_handling       VARCHAR2,
  t_custom_attribute8              VARCHAR2,
  t_custom_attribute9              VARCHAR2,
  t_content_source_type            VARCHAR2,
  t_edi_ece_tp_location_code       VARCHAR2,
  t_edi_id_number                  VARCHAR2,
  t_edi_payment_format             VARCHAR2,
  t_custom_attribute12             VARCHAR2,
  t_custom_attribute13             VARCHAR2,
  t_custom_attribute14             VARCHAR2,
  t_custom_attribute15             VARCHAR2,
  t_custom_attribute16             VARCHAR2,
  t_custom_attribute17             VARCHAR2,
  t_custom_attribute18             VARCHAR2,
  t_custom_attribute19             VARCHAR2,
  t_custom_attribute2              VARCHAR2,
  t_custom_attribute20             VARCHAR2,
  t_custom_attribute21             VARCHAR2,
  t_custom_attribute22             VARCHAR2,
  t_custom_attribute23             VARCHAR2,
  t_custom_attribute24             VARCHAR2,
  t_custom_attribute25             VARCHAR2,
  t_custom_attribute26             VARCHAR2,
  t_custom_attribute27             VARCHAR2,
  t_custom_attribute28             VARCHAR2,
  t_custom_attribute29             VARCHAR2,
  t_custom_attribute3              VARCHAR2,
  t_custom_attribute30             VARCHAR2,
  t_custom_attribute11             VARCHAR2,
  t_email_address                  VARCHAR2,
  t_email_format                   VARCHAR2,
  t_flex_format_phone_number       VARCHAR2,
  t_last_contact_dt_time           DATE,
  t_phone_area_code                VARCHAR2,
  t_phone_calling_calendar         VARCHAR2,
  t_phone_country_code             VARCHAR2,
  t_phone_extension                VARCHAR2,
  t_edi_remittance_method          VARCHAR2,
  t_custom_attribute7              VARCHAR2,
  t_edi_payment_method             VARCHAR2,
--other parameter
  p_cur_all                        VARCHAR2  DEFAULT 'ALL',
  x_status                         VARCHAR2  DEFAULT 'ALL',
  x_rule_id                     IN OUT NOCOPY NUMBER,
  x_search_ctx_id               IN OUT NOCOPY NUMBER,
  x_num_matches                 IN OUT NOCOPY NUMBER,
  x_msg_count                   IN OUT NOCOPY NUMBER,
  x_msg_data                    IN OUT NOCOPY varchar2,
  x_return_status               IN OUT NOCOPY VARCHAR2)
IS
  -- DQM record types
  l_party             hz_party_search.party_search_rec_type;
  l_party_site        hz_party_search.party_site_search_rec_type;
  l_contact           hz_party_search.contact_search_rec_type;
  l_contact_point     hz_party_search.contact_point_search_rec_type;
  -- DQM list type
  l_party_site_list    hz_party_search.party_site_list;
  l_contact_list       hz_party_search.contact_list;
  l_contact_point_list hz_party_search.contact_point_list;
  -- for error usage
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
  l_party_id           NUMBER;
  l_score              NUMBER;

  -- Cursor for details
  CURSOR matched_parties(i_ctx_id IN NUMBER) IS
  SELECT party_id,
         score
    FROM hz_matched_parties_gt
   WHERE search_context_id = i_ctx_id
   ORDER BY SCORE;

  -- Cursor for details
  CURSOR matched_cpts(i_ctx_id IN NUMBER) IS
  SELECT party_id,
         contact_point_id,
         score
    FROM hz_matched_cpts_gt
   WHERE search_context_id = i_ctx_id
   ORDER BY SCORE;

  l_cpt_rec  matched_cpts%ROWTYPE;

  --
  CURSOR matched_contacts(i_ctx_id IN NUMBER) IS
  SELECT party_id,
         org_contact_id,
         score
    FROM hz_matched_contacts_gt
   WHERE search_context_id = i_ctx_id
   ORDER BY SCORE;

  l_contact_rec  matched_contacts%ROWTYPE;

  l_cur_all   VARCHAR2(3);
BEGIN
  l_party.line_of_business               := p_line_of_business;
  l_party.local_activity_code            := p_local_activity_code;
  l_party.local_activity_code_type       := p_local_activity_code_type;
  l_party.local_bus_identifier           := p_local_bus_identifier;
  l_party.local_bus_iden_type            := p_local_bus_iden_type;
  l_party.maximum_credit_currency_code   := p_max_credit_currency_code;
  l_party.maximum_credit_recommendation  := p_max_credit_recommendation;
  l_party.minority_owned_ind             := p_minority_owned_ind;
  l_party.minority_owned_type            := p_minority_owned_type;
  l_party.next_fy_potential_revenue      := p_next_fy_potential_revenue;
  l_party.oob_ind                        := p_oob_ind;
  l_party.organization_name              := p_organization_name;
  l_party.organization_name_phonetic     := p_organization_name_phonetic;
  l_party.organization_type              := p_organization_type;
  l_party.parent_sub_ind                 := p_parent_sub_ind;
  l_party.paydex_norm                    := p_paydex_norm;
  l_party.paydex_score                   := p_paydex_score;
  l_party.paydex_three_months_ago        := p_paydex_three_months_ago;
  l_party.pref_functional_currency       := p_pref_functional_currency;
  l_party.principal_name                 := p_principal_name;
  l_party.principal_title                := p_principal_title;
  l_party.public_private_ownership_flag  := p_public_private_ownership_fg;
  l_party.registration_type              := p_registration_type;
  l_party.rent_own_ind                   := p_rent_own_ind;
  l_party.sic_code                       := p_sic_code;
  l_party.sic_code_type                  := p_sic_code_type;
  l_party.small_bus_ind                  := p_small_bus_ind;
  l_party.tax_name                       := p_tax_name;
  l_party.tax_reference                  := p_tax_reference;
  l_party.total_employees_text           := p_total_employees_text;
  l_party.total_emp_est_ind              := p_total_emp_est_ind;
  l_party.total_emp_min_ind              := p_total_emp_min_ind;
  l_party.total_employees_ind            := p_total_employees_ind;
  l_party.total_payments                 := p_total_payments;
  l_party.woman_owned_ind                := p_woman_owned_ind;
  l_party.year_established               := p_year_established;
  l_party.category_code                  := p_category_code;
  l_party.competitor_flag                := p_competitor_fg;
  l_party.do_not_mail_flag               := p_do_not_mail_fg;
  l_party.group_type                     := p_group_type;
  l_party.language_name                  := p_language_name;
  l_party.party_name                     := p_party_name;
  l_party.party_number                   := p_party_number;
  l_party.party_type                     := p_party_type;
  l_party.reference_use_flag             := p_reference_use_fg;
  l_party.salutation                     := p_salutation;
  l_party.status                         := p_status;
  l_party.third_party_flag               := p_third_party_fg;
  l_party.validated_flag                 := p_validated_fg;
  l_party.date_of_birth                  := p_date_of_birth;
  l_party.date_of_death                  := p_date_of_death;
  l_party.effective_start_date           := p_effective_start_date;
  l_party.effective_end_date             := p_effective_end_date;
  l_party.declared_ethnicity             := p_declared_ethnicity;
  l_party.gender                         := p_gender;
  l_party.head_of_household_flag         := p_head_of_household_fg;
  l_party.household_income               := p_household_income;
  l_party.household_size                 := p_household_size;
  l_party.last_known_gps                 := p_last_known_gps;
  l_party.marital_status                 := p_mar_status;
  l_party.marital_status_effective_date  := p_mar_status_effective_date;
  l_party.middle_name_phonetic           := p_middle_name_phonetic;
  l_party.personal_income                := p_personal_income;
  l_party.person_academic_title          := p_person_academic_title;
  l_party.person_first_name              := p_person_first_name;
  l_party.person_first_name_phonetic     := p_person_first_name_phonetic;
  l_party.person_identifier              := p_person_identifier;
  l_party.person_iden_type               := p_person_iden_type;
  l_party.person_initials                := p_person_initials;
  l_party.person_last_name               := p_person_last_name;
  l_party.person_last_name_phonetic      := p_person_last_name_phonetic;
  l_party.person_middle_name             := p_person_middle_name;
  l_party.person_name                    := p_person_name;
  l_party.person_name_phonetic           := p_person_name_phonetic;
  l_party.person_name_suffix             := p_person_name_suffix;
  l_party.person_previous_last_name      := p_person_previous_last_name;
  l_party.person_pre_name_adjunct        := p_person_pre_name_adjunct;
  l_party.person_title                   := p_person_title;
  l_party.place_of_birth                 := p_place_of_birth;
  l_party.all_account_names              := p_all_account_names;
  l_party.all_account_numbers            := p_all_account_numbers;
  l_party.custom_attribute1              := p_custom_attribute1;
  l_party.custom_attribute10             := p_custom_attribute10;
  l_party.custom_attribute11             := p_custom_attribute11;
  l_party.custom_attribute12             := p_custom_attribute12;
  l_party.custom_attribute13             := p_custom_attribute13;
  l_party.custom_attribute14             := p_custom_attribute14;
  l_party.custom_attribute15             := p_custom_attribute15;
  l_party.custom_attribute16             := p_custom_attribute16;
  l_party.custom_attribute17             := p_custom_attribute17;
  l_party.custom_attribute18             := p_custom_attribute18;
  l_party.custom_attribute19             := p_custom_attribute19;
  l_party.custom_attribute2              := p_custom_attribute2;
  l_party.custom_attribute20             := p_custom_attribute20;
  l_party.custom_attribute21             := p_custom_attribute21;
  l_party.custom_attribute22             := p_custom_attribute22;
  l_party.custom_attribute23             := p_custom_attribute23;
  l_party.custom_attribute24             := p_custom_attribute24;
  l_party.custom_attribute25             := p_custom_attribute25;
  l_party.custom_attribute26             := p_custom_attribute26;
  l_party.custom_attribute27             := p_custom_attribute27;
  l_party.custom_attribute28             := p_custom_attribute28;
  l_party.custom_attribute29             := p_custom_attribute29;
  l_party.custom_attribute3              := p_custom_attribute3;
  l_party.custom_attribute30             := p_custom_attribute30;
  l_party.custom_attribute4              := p_custom_attribute4;
  l_party.custom_attribute5              := p_custom_attribute5;
  l_party.custom_attribute6              := p_custom_attribute6;
  l_party.custom_attribute7              := p_custom_attribute7;
  l_party.custom_attribute8              := p_custom_attribute8;
  l_party.custom_attribute9              := p_custom_attribute9;
  l_party.analysis_fy                    := p_analysis_fy;
  l_party.avg_high_credit                := p_avg_high_credit;
  l_party.best_time_contact_begin        := p_best_time_contact_begin;
  l_party.best_time_contact_end          := p_best_time_contact_end;
  l_party.branch_flag                    := p_branch_fg;
  l_party.business_scope                 := p_business_scope;
  l_party.ceo_name                       := p_ceo_name;
  l_party.ceo_title                      := p_ceo_title;
  l_party.cong_dist_code                 := p_cong_dist_code;
  l_party.content_source_number          := p_content_source_number;
  l_party.content_source_type            := p_content_source_type;
  l_party.control_yr                     := p_control_yr;
  l_party.corporation_class              := p_corporation_class;
  l_party.credit_score                   := p_credit_score;
  l_party.credit_score_age               := p_credit_score_age;
  l_party.credit_score_class             := p_credit_score_class;
  l_party.credit_score_commentary        := p_credit_score_commentary;
  l_party.credit_score_commentary10      := p_credit_score_commentary10;
  l_party.credit_score_commentary2       := p_credit_score_commentary2;
  l_party.credit_score_commentary3       := p_credit_score_commentary3;
  l_party.credit_score_commentary4       := p_credit_score_commentary4;
  l_party.credit_score_commentary5       := p_credit_score_commentary5;
  l_party.credit_score_commentary6       := p_credit_score_commentary6;
  l_party.credit_score_commentary7       := p_credit_score_commentary7;
  l_party.credit_score_commentary8       := p_credit_score_commentary8;
  l_party.credit_score_commentary9       := p_credit_score_commentary9;
  l_party.credit_score_date              := p_credit_score_date;
  l_party.credit_score_incd_default      := p_credit_score_incd_default;
  l_party.credit_score_natl_percentile   := p_credit_score_natl_percentile;
  l_party.curr_fy_potential_revenue      := p_curr_fy_potential_revenue;
  l_party.db_rating                      := p_db_rating;
  l_party.debarments_count               := p_debarments_count;
  l_party.debarments_date                := p_debarments_date;
  l_party.debarment_ind                  := p_debarment_ind;
  l_party.disadv_8a_ind                  := p_disadv_8a_ind;
  l_party.duns_number_c                  := p_duns_number_c;
  l_party.employees_total                := p_employees_total;
  l_party.emp_at_primary_adr             := p_emp_at_primary_adr;
  l_party.emp_at_primary_adr_est_ind     := p_emp_at_primary_adr_est_ind;
  l_party.emp_at_primary_adr_min_ind     := p_emp_at_primary_adr_min_ind;
  l_party.emp_at_primary_adr_text        := p_emp_at_primary_adr_text;
  l_party.enquiry_duns                   := p_enquiry_duns;
  l_party.export_ind                     := p_export_ind;
  l_party.failure_score                  := p_failure_score;
  l_party.failure_score_age              := p_failure_score_age;
  l_party.failure_score_class            := p_failure_score_class;
  l_party.failure_score_commentary       := p_failure_score_commentary;
  l_party.failure_score_commentary10     := p_failure_score_commentary10;
  l_party.failure_score_commentary2      := p_failure_score_commentary2;
  l_party.failure_score_commentary3      := p_failure_score_commentary3;
  l_party.failure_score_commentary4      := p_failure_score_commentary4;
  l_party.failure_score_commentary5      := p_failure_score_commentary5;
  l_party.failure_score_commentary6      := p_failure_score_commentary6;
  l_party.failure_score_commentary7      := p_failure_score_commentary7;
  l_party.failure_score_commentary8      := p_failure_score_commentary8;
  l_party.failure_score_commentary9      := p_failure_score_commentary9;
  l_party.failure_score_date             := p_failure_score_date;
  l_party.failure_score_incd_default     := p_failure_score_incd_default;
  l_party.failure_score_override_code    := p_failure_score_override_code;
  l_party.fiscal_yearend_month           := p_fiscal_yearend_month;
  l_party.global_failure_score           := p_global_failure_score;
  l_party.gsa_indicator_flag             := p_gsa_indicator_fg;
  l_party.high_credit                    := p_high_credit;
  l_party.hq_branch_ind                  := p_hq_branch_ind;
  l_party.import_ind                     := p_import_ind;
  l_party.incorp_year                    := p_incorp_year;
  l_party.internal_flag                  := p_internal_fg;
  l_party.jgzz_fiscal_code               := p_jgzz_fiscal_code;
  l_party.party_all_names                := p_party_all_names;
  l_party.known_as                       := p_known_as;
  l_party.known_as2                      := p_known_as2;
  l_party.known_as3                      := p_known_as3;
  l_party.known_as4                      := p_known_as4;
  l_party.known_as5                      := p_known_as5;
  l_party.labor_surplus_ind              := p_labor_surplus_ind;
  l_party.legal_status                   := p_legal_status;

  l_party_site.party_site_number              := s_party_site_number;
  l_party_site.custom_attribute16             := s_custom_attribute16;
  l_party_site.custom_attribute17             := s_custom_attribute17;
  l_party_site.custom_attribute18             := s_custom_attribute18;
  l_party_site.custom_attribute19             := s_custom_attribute19;
  l_party_site.custom_attribute2              := s_custom_attribute2;
  l_party_site.custom_attribute20             := s_custom_attribute20;
  l_party_site.custom_attribute21             := s_custom_attribute21;
  l_party_site.custom_attribute22             := s_custom_attribute22;
  l_party_site.custom_attribute23             := s_custom_attribute23;
  l_party_site.custom_attribute24             := s_custom_attribute24;
  l_party_site.custom_attribute25             := s_custom_attribute25;
  l_party_site.custom_attribute26             := s_custom_attribute26;
  l_party_site.custom_attribute27             := s_custom_attribute27;
  l_party_site.custom_attribute28             := s_custom_attribute28;
  l_party_site.custom_attribute29             := s_custom_attribute29;
  l_party_site.custom_attribute3              := s_custom_attribute3;
  l_party_site.custom_attribute30             := s_custom_attribute30;
  l_party_site.custom_attribute4              := s_custom_attribute4;
  l_party_site.custom_attribute5              := s_custom_attribute5;
  l_party_site.custom_attribute6              := s_custom_attribute6;
  l_party_site.custom_attribute7              := s_custom_attribute7;
  l_party_site.custom_attribute8              := s_custom_attribute8;
  l_party_site.custom_attribute9              := s_custom_attribute9;
  l_party_site.address1                       := s_address1;
  l_party_site.address2                       := s_address2;
  l_party_site.address3                       := s_address3;
  l_party_site.address4                       := s_address4;
  l_party_site.floor                          := s_floor;
  l_party_site.house_number                   := s_house_number;
  l_party_site.language                       := s_language;
  l_party_site.clli_code                      := s_clli_code;
  l_party_site.content_source_type            := s_content_source_type;
  l_party_site.country                        := s_country;
  l_party_site.county                         := s_county;
  l_party_site.trailing_directory_code        := s_trailing_directory_code;
  l_party_site.validated_flag                 := s_validated_fg;
  l_party_site.identifying_address_flag       := s_identifying_address_fg;
  l_party_site.mailstop                       := s_mailstop;
  l_party_site.party_site_name                := s_party_site_name;
  l_party_site.address                        := s_address;
  l_party_site.custom_attribute1              := s_custom_attribute1;
  l_party_site.custom_attribute10             := s_custom_attribute10;
  l_party_site.custom_attribute11             := s_custom_attribute11;
  l_party_site.custom_attribute12             := s_custom_attribute12;
  l_party_site.custom_attribute13             := s_custom_attribute13;
  l_party_site.custom_attribute14             := s_custom_attribute14;
  l_party_site.custom_attribute15             := s_custom_attribute15;
  l_party_site.city                           := s_city;
  l_party_site.address_effective_date         := s_address_effective_date;
  l_party_site.address_expiration_date        := s_address_expiration_date;
  l_party_site.address_lines_phonetic         := s_address_lines_phonetic;
  l_party_site.position                       := s_position;
  l_party_site.postal_code                    := s_postal_code;
  l_party_site.postal_plus4_code              := s_postal_plus4_code;
  l_party_site.po_box_number                  := s_po_box_number;
  l_party_site.province                       := s_province;
  l_party_site.sales_tax_geocode              := s_sales_tax_geocode;
  l_party_site.sales_tax_inside_city_limits   := s_sales_tax_inside_city_limits;
  l_party_site.state                          := s_state;
  l_party_site.street                         := s_street;
  l_party_site.street_number                  := s_street_number;
  l_party_site.street_suffix                  := s_street_suffix;
  l_party_site.suite                          := s_suite;

  l_contact.directional_flag               := c_directional_fg;
  l_contact.native_language                := c_native_language;
  l_contact.other_language_1               := c_other_language_1;
  l_contact.title                          := c_title;
  l_contact.custom_attribute1              := c_custom_attribute1;
  l_contact.custom_attribute10             := c_custom_attribute10;
  l_contact.custom_attribute11             := c_custom_attribute11;
  l_contact.custom_attribute12             := c_custom_attribute12;
  l_contact.custom_attribute13             := c_custom_attribute13;
  l_contact.custom_attribute14             := c_custom_attribute14;
  l_contact.custom_attribute15             := c_custom_attribute15;
  l_contact.custom_attribute16             := c_custom_attribute16;
  l_contact.custom_attribute17             := c_custom_attribute17;
  l_contact.custom_attribute18             := c_custom_attribute18;
  l_contact.custom_attribute19             := c_custom_attribute19;
  l_contact.custom_attribute2              := c_custom_attribute2;
  l_contact.custom_attribute20             := c_custom_attribute20;
  l_contact.custom_attribute21             := c_custom_attribute21;
  l_contact.custom_attribute22             := c_custom_attribute22;
  l_contact.custom_attribute23             := c_custom_attribute23;
  l_contact.custom_attribute24             := c_custom_attribute24;
  l_contact.custom_attribute25             := c_custom_attribute25;
  l_contact.custom_attribute26             := c_custom_attribute26;
  l_contact.custom_attribute27             := c_custom_attribute27;
  l_contact.custom_attribute28             := c_custom_attribute28;
  l_contact.custom_attribute29             := c_custom_attribute29;
  l_contact.custom_attribute3              := c_custom_attribute3;
  l_contact.custom_attribute30             := c_custom_attribute30;
  l_contact.custom_attribute4              := c_custom_attribute4;
  l_contact.custom_attribute5              := c_custom_attribute5;
  l_contact.custom_attribute6              := c_custom_attribute6;
  l_contact.mail_stop                      := c_mail_stop;
  l_contact.best_time_contact_end          := c_best_time_contact_end;
  l_contact.job_title_code                 := c_job_title_code;
  l_contact.relationship_type              := c_relationship_type;
  l_contact.other_language_2               := c_other_language_2;
  l_contact.rank                           := c_rank;
  l_contact.reference_use_flag             := c_reference_use_fg;
  l_contact.date_of_birth                  := c_date_of_birth;
  l_contact.date_of_death                  := c_date_of_death;
  l_contact.jgzz_fiscal_code               := c_jgzz_fiscal_code;
  l_contact.known_as                       := c_known_as;
  l_contact.person_academic_title          := c_person_academic_title;
  l_contact.person_first_name              := c_person_first_name;
  l_contact.person_first_name_phonetic     := c_person_first_name_phonetic;
  l_contact.person_identifier              := c_person_identifier;
  l_contact.person_iden_type               := c_person_iden_type;
  l_contact.person_initials                := c_person_initials;
  l_contact.person_last_name               := c_person_last_name;
  l_contact.person_last_name_phonetic      := c_person_last_name_phonetic;
  l_contact.person_middle_name             := c_person_middle_name;
  l_contact.person_name                    := c_person_name;
  l_contact.person_name_phonetic           := c_person_name_phonetic;
  l_contact.person_name_suffix             := c_person_name_suffix;
  l_contact.person_previous_last_name      := c_person_previous_last_name;
  l_contact.person_title                   := c_person_title;
  l_contact.place_of_birth                 := c_place_of_birth;
  l_contact.tax_name                       := c_tax_name;
  l_contact.tax_reference                  := c_tax_reference;
  l_contact.content_source_type            := c_content_source_type;
  l_contact.job_title                      := c_job_title;
  l_contact.custom_attribute7              := c_custom_attribute7;
  l_contact.custom_attribute8              := c_custom_attribute8;
  l_contact.custom_attribute9              := c_custom_attribute9;
  l_contact.contact_number                 := c_contact_number;
  l_contact.contact_name                   := c_contact_name;
  l_contact.decision_maker_flag            := c_decision_maker_fg;
  l_contact.best_time_contact_begin        := c_best_time_contact_begin;

  l_contact_point.phone_line_type                := t_phone_line_type;
  l_contact_point.phone_number                   := t_phone_number;
  l_contact_point.primary_flag                   := t_primary_fg;
  l_contact_point.raw_phone_number               := t_raw_phone_number;
  l_contact_point.telephone_type                 := t_telephone_type;
  l_contact_point.telex_number                   := t_telex_number;
  l_contact_point.time_zone                      := t_time_zone;
  l_contact_point.url                            := t_url;
  l_contact_point.web_type                       := t_web_type;
  l_contact_point.contact_point_type             := t_contact_point_type;
  l_contact_point.custom_attribute1              := t_custom_attribute1;
  l_contact_point.custom_attribute10             := t_custom_attribute10;
  l_contact_point.edi_tp_header_id               := t_edi_tp_header_id;
  l_contact_point.custom_attribute5              := t_custom_attribute5;
  l_contact_point.custom_attribute6              := t_custom_attribute6;
  l_contact_point.custom_attribute4              := t_custom_attribute4;
  l_contact_point.edi_remittance_instruction     := t_edi_remittance_instruction;
  l_contact_point.edi_transaction_handling       := t_edi_transaction_handling;
  l_contact_point.custom_attribute8              := t_custom_attribute8;
  l_contact_point.custom_attribute9              := t_custom_attribute9;
  l_contact_point.content_source_type            := t_content_source_type;
  l_contact_point.edi_ece_tp_location_code       := t_edi_ece_tp_location_code;
  l_contact_point.edi_id_number                  := t_edi_id_number;
  l_contact_point.edi_payment_format             := t_edi_payment_format;
  l_contact_point.custom_attribute12             := t_custom_attribute12;
  l_contact_point.custom_attribute13             := t_custom_attribute13;
  l_contact_point.custom_attribute14             := t_custom_attribute14;
  l_contact_point.custom_attribute15             := t_custom_attribute15;
  l_contact_point.custom_attribute16             := t_custom_attribute16;
  l_contact_point.custom_attribute17             := t_custom_attribute17;
  l_contact_point.custom_attribute18             := t_custom_attribute18;
  l_contact_point.custom_attribute19             := t_custom_attribute19;
  l_contact_point.custom_attribute2              := t_custom_attribute2;
  l_contact_point.custom_attribute20             := t_custom_attribute20;
  l_contact_point.custom_attribute21             := t_custom_attribute21;
  l_contact_point.custom_attribute22             := t_custom_attribute22;
  l_contact_point.custom_attribute23             := t_custom_attribute23;
  l_contact_point.custom_attribute24             := t_custom_attribute24;
  l_contact_point.custom_attribute25             := t_custom_attribute25;
  l_contact_point.custom_attribute26             := t_custom_attribute26;
  l_contact_point.custom_attribute27             := t_custom_attribute27;
  l_contact_point.custom_attribute28             := t_custom_attribute28;
  l_contact_point.custom_attribute29             := t_custom_attribute29;
  l_contact_point.custom_attribute3              := t_custom_attribute3;
  l_contact_point.custom_attribute30             := t_custom_attribute30;
  l_contact_point.custom_attribute11             := t_custom_attribute11;
  l_contact_point.email_address                  := t_email_address;
  l_contact_point.email_format                   := t_email_format;
  l_contact_point.flex_format_phone_number       := t_flex_format_phone_number;
  l_contact_point.last_contact_dt_time           := t_last_contact_dt_time;
  l_contact_point.phone_area_code                := t_phone_area_code;
  l_contact_point.phone_calling_calendar         := t_phone_calling_calendar;
  l_contact_point.phone_country_code             := t_phone_country_code;
  l_contact_point.phone_extension                := t_phone_extension;
  l_contact_point.edi_remittance_method          := t_edi_remittance_method;
  l_contact_point.custom_attribute7              := t_custom_attribute7;
  l_contact_point.edi_payment_method             := t_edi_payment_method;


--fnd_client_info.set_org_context('458');

  -------------------------------------
  -- Put Record type variables in lists
  -------------------------------------
  IF NOT arh_dqm_pkg.IsNull(l_party_site) THEN
    l_party_site_list(1)      := l_party_site;
  END IF;

  IF NOT arh_dqm_pkg.IsNull(l_contact) THEN
    l_contact_list(1)         := l_contact;
  END IF;

  l_contact_point_list      := arh_dqm_pkg.Contact_point_list( p_contact_point =>l_contact_point);

/*
  hz_party_search.find_parties (
        x_rule_id               => x_rule_id,
        p_party_search_rec      => l_party,
        p_party_site_list       => l_party_site_list,
        p_contact_list	        => l_contact_list,
        p_contact_point_list    => l_contact_point_list,
        p_restrict_sql          => NULL,
        p_search_merged         => NULL,
        x_search_ctx_id         => x_search_ctx_id,
        x_num_matches           => x_num_matches,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);
*/

  hz_party_search.find_party_details (
      p_rule_id               => x_rule_id,
      p_party_search_rec      => l_party,
      p_party_site_list       => l_party_site_list,
      p_contact_list          => l_contact_list,
      p_contact_point_list    => l_contact_point_list,
      p_restrict_sql          => NULL,
      p_match_type            => NULL,
      p_search_merged         => 'N',
      x_search_ctx_id         => x_search_ctx_id,
      x_num_matches           => x_num_matches,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data);


   IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
   END IF;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
   END IF;

/*
   OPEN matched_parties(x_search_ctx_id);
   LOOP
     FETCH  matched_parties INTO l_party_id, l_score;
     EXIT WHEN matched_parties%NOTFOUND;

      hz_party_search.get_party_score_details (
        p_rule_id               => x_rule_id,
        p_party_id              => l_party_id,
        p_search_ctx_id         => x_search_ctx_id,
        p_party_search_rec      => l_party,
        p_party_site_list       => l_party_site_list,
        p_contact_list	        => l_contact_list,
        p_contact_point_list    => l_contact_point_list,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);

     IF x_msg_count > 1 THEN
       FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
       END LOOP;
       x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       CLOSE matched_parties;
       RETURN;
    END IF;

  END LOOP;
  CLOSE matched_parties;
*/

  OPEN matched_cpts(x_search_ctx_id);
  LOOP
    FETCH  matched_cpts INTO l_cpt_rec;
    EXIT WHEN matched_cpts%NOTFOUND;
    arh_dqm_tree_helper.cpt_treatment( p_cpt_id => l_cpt_rec.contact_point_id,
                                      p_pty_id => l_cpt_rec.party_id,
                                      p_ctx_id => x_search_ctx_id,
                                      x_return_status=> x_return_status,
                                      x_msg_count=> x_msg_count,
                                      x_msg_data => x_msg_data);
  END LOOP;
  CLOSE matched_cpts;


  OPEN matched_contacts(x_search_ctx_id);
  LOOP
    FETCH  matched_contacts INTO l_contact_rec;
    EXIT WHEN matched_contacts%NOTFOUND;
    arh_dqm_tree_helper.contact_treatment(p_contact_id => l_contact_rec.org_contact_id,
                                      p_pty_id     => l_contact_rec.party_id,
                                      p_ctx_id     => x_search_ctx_id,
                                      x_return_status=> x_return_status,
                                      x_msg_count=> x_msg_count,
                                      x_msg_data => x_msg_data);
  END LOOP;
  CLOSE matched_contacts;

-- Treatment for CUST ACCOUNT

--   IF  fnd_profile.value('HZ_ALL_ORG') = 'Y' THEN
--     l_cur_all := 'ALL';
--   ELSE
--     l_cur_all := 'CUR';
--   END IF;

   l_cur_all   :=  p_cur_all;

   arh_dqm_cust_helper.car_oc_treatment(p_ctx_id  => x_search_ctx_id,
                                       p_cur_all => l_cur_all,
                                       p_status  => x_status);


   arh_dqm_cust_helper.as_ps_treatment(p_ctx_id => x_search_ctx_id,
                                      p_cur_all => l_cur_all,
                                      p_status  => x_status);


   arh_dqm_cust_helper.ac_pty_treatment(p_ctx_id => x_search_ctx_id,
                                       p_cur_all => l_cur_all,
                                       p_status  => x_status);

END Exec_Dqm_Api;


PROCEDURE Get_Dqm_Exec_Details
(p_party_id           IN NUMBER,
 p_rule_id            IN NUMBER,
 p_search_ctx_id      IN NUMBER,
 p_party_search_rec   IN HZ_PARTY_SEARCH.party_search_rec_type,
 p_party_site_list    IN HZ_PARTY_SEARCH.party_site_list,
 p_contact_list       IN HZ_PARTY_SEARCH.contact_list,
 p_contact_point_list IN HZ_PARTY_SEARCH.contact_point_list,
 x_msg_count          IN OUT NOCOPY NUMBER,
 x_msg_data           IN OUT NOCOPY varchar2,
 x_return_status      IN OUT NOCOPY VARCHAR2)
IS
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
  x_party_search_rec      HZ_PARTY_SEARCH.party_search_rec_type;
  x_party_site_list       HZ_PARTY_SEARCH.party_site_list;
  x_contact_list          HZ_PARTY_SEARCH.contact_list;
  x_contact_point_list    HZ_PARTY_SEARCH.contact_point_list;
BEGIN
  hz_party_search.get_party_score_details (
        p_rule_id               => p_rule_id,
        p_party_id              => p_party_id,
        p_search_ctx_id         => p_search_ctx_id,
        p_party_search_rec      => p_party_search_rec,
        p_party_site_list       => p_party_site_list,
        p_contact_list	        => p_contact_list,
        p_contact_point_list    => p_contact_point_list,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);
   IF x_msg_count > 1 THEN
     FOR i IN 1..x_msg_count  LOOP
       tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
       tmp_var1 := tmp_var1 || ' '|| tmp_var;
     END LOOP;
     x_msg_data := tmp_var1;
   END IF;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RETURN;
   END IF;
END;

PROCEDURE Exec_Dqm_Dup_Api
(p_party_id                    IN NUMBER,
 p_need_details                IN VARCHAR2 DEFAULT 'N',
 p_rule_id                     IN OUT NOCOPY NUMBER,
 x_status                      VARCHAR2  DEFAULT 'ALL',
 x_search_ctx_id               IN OUT NOCOPY NUMBER,
 x_num_matches                 IN OUT NOCOPY NUMBER,
 x_msg_count                   IN OUT NOCOPY NUMBER,
 x_msg_data                    IN OUT NOCOPY varchar2,
 x_return_status               IN OUT NOCOPY VARCHAR2)
IS
  p_party_site_ids        HZ_PARTY_SEARCH.IDList;
  p_contact_ids           HZ_PARTY_SEARCH.IDList;
  p_contact_pt_ids        HZ_PARTY_SEARCH.IDList;
  x_party_search_rec      HZ_PARTY_SEARCH.party_search_rec_type;
  x_party_site_list       HZ_PARTY_SEARCH.party_site_list;
  x_contact_list          HZ_PARTY_SEARCH.contact_list;
  x_contact_point_list    HZ_PARTY_SEARCH.contact_point_list;
  CURSOR c_ps
  IS
  SELECT party_site_id
    FROM hz_party_sites
   WHERE party_id = p_party_id
     AND identifying_address_flag = 'Y';

  CURSOR c_ct
  IS
  SELECT b.org_contact_id
    FROM hz_relationships  a,
         hz_org_contacts   b
   WHERE a.object_id        = p_party_id
     AND a.directional_flag = 'F'
     AND a.relationship_id  = b.party_relationship_id
     AND rownum <5
   ORDER BY b.last_update_date;

  CURSOR c_cpt
  IS
  SELECT a.contact_point_id,
         a.last_update_date
    FROM hz_contact_points a
   WHERE a.owner_table_name = 'HZ_PARTIES'
     AND a.owner_table_id   = p_party_id
  UNION ALL
  SELECT a.contact_point_id,
         a.last_update_date
    FROM hz_contact_points a,
         hz_party_sites    b
   WHERE a.owner_table_name = 'HZ_PARTY_SITES'
     AND a.owner_table_id   = b.party_site_id
     AND b.party_id       = p_party_id
  UNION ALL
  SELECT a.contact_point_id,
         a.last_update_date
    FROM hz_contact_points a,
         hz_relationships  b,
         hz_org_contacts   c
   WHERE b.object_id             = p_party_id
     AND b.directional_flag      = 'F'
     AND b.party_id              = a.owner_table_id
     AND a.owner_table_name      = 'HZ_PARTIES'
     AND c.party_relationship_id = b.relationship_id
   ORDER BY last_update_date;

  l_id NUMBER;
  l_date DATE;

  -- Cursor for details
  CURSOR matched_parties(i_ctx_id IN NUMBER) IS
  SELECT party_id,
         score
    FROM hz_matched_parties_gt
   WHERE search_context_id = i_ctx_id
   ORDER BY SCORE;

  -- Cursor for details
  CURSOR matched_cpts(i_ctx_id IN NUMBER) IS
  SELECT party_id,
         contact_point_id,
         score
    FROM hz_matched_cpts_gt
   WHERE search_context_id = i_ctx_id
   ORDER BY SCORE;
  l_cpt_rec  matched_cpts%ROWTYPE;

  CURSOR matched_contacts(i_ctx_id IN NUMBER) IS
  SELECT party_id,
         org_contact_id,
         score
    FROM hz_matched_contacts_gt
   WHERE search_context_id = i_ctx_id
   ORDER BY SCORE;

  l_contact_rec  matched_contacts%ROWTYPE;
  l_cur_all      varchar2(3);
  i              number := 0;
  l_party_id           NUMBER;
  l_score              NUMBER;
  tmp_var              VARCHAR2(2000);
  tmp_var1             VARCHAR2(2000);
BEGIN
  i := 0;
  OPEN c_ps;
  LOOP
    FETCH c_ps INTO l_id;
    EXIT WHEN c_ps%NOTFOUND;
    i := i + 1;
    p_party_site_ids(i) := l_id;
  END LOOP;
  CLOSE c_ps;
  i := 0;
  OPEN c_ct;
  LOOP
    FETCH c_ct INTO l_id;
    EXIT WHEN c_ct%NOTFOUND;
    i := i + 1;
    p_contact_ids(i) := l_id;
  END LOOP;
  CLOSE c_ct;
  i := 0;
  OPEN c_cpt;
  LOOP
    FETCH c_cpt INTO l_id, l_date;
    EXIT WHEN c_cpt%NOTFOUND;
    i := i + 1;
    IF i > 5 THEN
      EXIT;
    END IF;
    p_contact_pt_ids(i) := l_id;
  END LOOP;
  CLOSE c_cpt;

  HZ_PARTY_SEARCH.get_search_criteria
    (p_init_msg_list      => FND_API.G_TRUE,
     p_rule_id            => p_rule_id,
     p_party_id           => p_party_id,
     p_party_site_ids     => p_party_site_ids,
     p_contact_ids        => p_contact_ids,
     p_contact_pt_ids     => p_contact_pt_ids,
     x_party_search_rec   => x_party_search_rec,
     x_party_site_list    => x_party_site_list,
     x_contact_list       => x_contact_list,
     x_contact_point_list => x_contact_point_list,
     x_return_status      => x_return_status,
     x_msg_count          => x_msg_count,
     x_msg_data           => x_msg_data);

   IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
   END IF;
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
   END IF;

  hz_party_search.find_party_details (
      p_init_msg_list         => FND_API.G_TRUE,
      p_rule_id               => p_rule_id,
      p_party_search_rec      => x_party_search_rec,
      p_party_site_list       => x_party_site_list,
      p_contact_list          => x_contact_list,
      p_contact_point_list    => x_contact_point_list,
      p_restrict_sql          => 'party_id <> '||p_party_id,
      p_match_type            => NULL,
      p_search_merged         => NULL,
      x_search_ctx_id         => x_search_ctx_id,
      x_num_matches           => x_num_matches,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data);

   IF x_msg_count > 1 THEN
     FOR i IN 1..x_msg_count  LOOP
       tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
       tmp_var1 := tmp_var1 || ' '|| tmp_var;
     END LOOP;
     x_msg_data := tmp_var1;
   END IF;
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
   END IF;

   IF p_need_details = 'Y' THEN
     OPEN matched_parties(x_search_ctx_id);
     LOOP
       FETCH  matched_parties INTO l_party_id, l_score;
       EXIT WHEN matched_parties%NOTFOUND;

       hz_party_search.get_party_score_details (
        p_rule_id               => p_rule_id,
        p_party_id              => l_party_id,
        p_search_ctx_id         => x_search_ctx_id,
        p_party_search_rec      => x_party_search_rec,
        p_party_site_list       => x_party_site_list,
        p_contact_list	        => x_contact_list,
        p_contact_point_list    => x_contact_point_list,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);

      IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
        END LOOP;
        x_msg_data := tmp_var1;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        CLOSE matched_parties;
        RETURN;
      END IF;

    END LOOP;
    CLOSE matched_parties;
   END IF;

  /*
  HZ_BATCH_DUPLICATE.find_party_dups (
        p_rule_id               => p_rule_id,
        p_party_id              => p_party_id,
        p_party_site_ids        => p_party_site_ids,
        p_contact_ids           => p_contact_ids,
        p_contact_pt_ids        => p_contact_pt_ids,
        x_party_search_rec      => x_party_search_rec,
        x_party_site_list       => x_party_site_list,
        x_contact_list          => x_contact_list,
        x_contact_point_list    => x_contact_point_list,
        x_search_ctx_id         => x_search_ctx_id,
        x_num_matches           => x_num_matches,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);

   IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
   END IF;
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
   END IF;

   OPEN matched_parties(x_search_ctx_id);
   LOOP
     FETCH  matched_parties INTO l_party_id, l_score;
     EXIT WHEN matched_parties%NOTFOUND;

      hz_party_search.get_party_score_details (
        p_rule_id               => p_rule_id,
        p_party_id              => l_party_id,
        p_search_ctx_id         => x_search_ctx_id,
        p_party_search_rec      => x_party_search_rec,
        p_party_site_list       => x_party_site_list,
        p_contact_list	        => x_contact_list,
        p_contact_point_list    => x_contact_point_list,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);

     IF x_msg_count > 1 THEN
       FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
       END LOOP;
       x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       CLOSE matched_parties;
       RETURN;
    END IF;

  END LOOP;
  CLOSE matched_parties;
*/


  OPEN matched_cpts(x_search_ctx_id);
  LOOP
      FETCH  matched_cpts INTO l_cpt_rec;
      EXIT WHEN matched_cpts%NOTFOUND;
      arh_dqm_tree_helper.cpt_treatment( p_cpt_id => l_cpt_rec.contact_point_id,
                                         p_pty_id => l_cpt_rec.party_id,
                                         p_ctx_id => x_search_ctx_id,
                                         x_return_status=> x_return_status,
                                         x_msg_count=> x_msg_count,
                                         x_msg_data => x_msg_data);
  END LOOP;
  CLOSE matched_cpts;

  OPEN matched_contacts(x_search_ctx_id);
  LOOP
      FETCH  matched_contacts INTO l_contact_rec;
      EXIT WHEN matched_contacts%NOTFOUND;
      arh_dqm_tree_helper.contact_treatment(p_contact_id => l_contact_rec.org_contact_id,
                                        p_pty_id     => l_contact_rec.party_id,
                                        p_ctx_id     => x_search_ctx_id,
                                        x_return_status=> x_return_status,
                                        x_msg_count=> x_msg_count,
                                        x_msg_data => x_msg_data);
  END LOOP;
  CLOSE matched_contacts;
    -- Treatment for CUST ACCOUNT
  arh_dqm_cust_helper.car_oc_treatment(p_ctx_id  => x_search_ctx_id,
                                          p_cur_all => 'ALL',
                                          p_status  => 'A');
  arh_dqm_cust_helper.as_ps_treatment(p_ctx_id => x_search_ctx_id,
                                        p_cur_all => 'ALL',
                                        p_status  => 'A');
  arh_dqm_cust_helper.ac_pty_treatment(p_ctx_id => x_search_ctx_id,
                                       p_cur_all => 'ALL',
                                       p_status  => 'A');

END;

END;

/
