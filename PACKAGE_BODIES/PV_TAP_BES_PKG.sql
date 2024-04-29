--------------------------------------------------------
--  DDL for Package Body PV_TAP_BES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_TAP_BES_PKG" AS
/* $Header: pvxtbesb.pls 120.4 2006/05/12 04:16:51 rdsharma ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_TAP_BES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- This package includes all the PRM related Territory Assignment
-- subscriptions for following modules -
--             * Organization Update
--             * Party Site Update
--             * Location Update
--             * Contact Point Update
-- ===============================================================


/*******************************************************************
* Comments:
*    This  package has  been  modified  to delete  the reference of
*    hz_param_pkg.param_tab_t variable which is no longer supported
*    by TCA in R12 release.
*    This issue reported by TCA in bug# 4528865. By removing the
*    reference we are going to ignore whether the change were in any
*    Territory related transaction qualifier or not. We will insert
*    that  organization record in PV_TAP_BATCH_CHG_PARTNERS table
*    for Channel team assignment.
*
*******************************************************************/

/***********************COMMENTS - STARTED ***************************
------------------------
-- The Nullify routines
------------------------
-- PROCEDURE Nullify_location_rec
-- PROCEDURE Nullify_contact_point_rec
-- PROCEDURE Nullify_organization_rec
-- PROCEDURE Nullify_party_site_rec
-------------------------

PROCEDURE Nullify_location_rec
( p_location_rec   IN OUT NOCOPY hz_location_v2pub.location_rec_type )
IS
BEGIN
    p_location_rec.location_id              := null;
    p_location_rec.orig_system_reference   := null;
    p_location_rec.country                 := null;
    p_location_rec.address1                := null;
    p_location_rec.address2                := null;
    p_location_rec.address3                := null;
    p_location_rec.address4                := null;
    p_location_rec.city                    := null;
    p_location_rec.postal_code             := null;
    p_location_rec.state                   := null;
    p_location_rec.province                := null;
    p_location_rec.county                  := null;
    p_location_rec.address_key             := null;
    p_location_rec.address_style           := null;
    p_location_rec.validated_flag	   := null;
    p_location_rec.address_lines_phonetic  := null;
    p_location_rec.po_box_number           := null;
    p_location_rec.house_number            := null;
    p_location_rec.street_suffix           := null;
    p_location_rec.street                  := null;
    p_location_rec.street_number           := null;
    p_location_rec.floor                   := null;
    p_location_rec.suite                   := null;
    p_location_rec.postal_plus4_code       := null;
    p_location_rec.position                := null;
    p_location_rec.location_directions     := null;
    p_location_rec.address_effective_date  := null;
    p_location_rec.address_expiration_date := null;
    p_location_rec.clli_code               := null;
    p_location_rec.language                := null;
    p_location_rec.short_description       := null;
    p_location_rec.description             := null;
    p_location_rec.loc_hierarchy_id	:= null;
    p_location_rec.sales_tax_geocode	:= null;
    p_location_rec.sales_tax_inside_city_limits := null;
    p_location_rec.fa_location_id		:= null;
    p_location_rec.content_source_type     := null;
    p_location_rec.attribute_category      := null;
    p_location_rec.attribute1              := null;
    p_location_rec.attribute2              := null;
    p_location_rec.attribute3              := null;
    p_location_rec.attribute4              := null;
    p_location_rec.attribute5              := null;
    p_location_rec.attribute6              := null;
    p_location_rec.attribute7              := null;
    p_location_rec.attribute8              := null;
    p_location_rec.attribute9              := null;
    p_location_rec.attribute10             := null;
    p_location_rec.attribute11             := null;
    p_location_rec.attribute12             := null;
    p_location_rec.attribute13             := null;
    p_location_rec.attribute14             := null;
    p_location_rec.attribute15             := null;
    p_location_rec.attribute16             := null;
    p_location_rec.attribute17             := null;
    p_location_rec.attribute18             := null;
    p_location_rec.attribute19             := null;
    p_location_rec.attribute20             := null;
    p_location_rec.timezone_id             := null;
END;

PROCEDURE Nullify_contact_point_rec
( p_contact_point_rec   IN OUT NOCOPY hz_contact_point_v2pub.contact_point_rec_type )
IS
BEGIN
    p_contact_point_rec.contact_point_id	:= null;
    p_contact_point_rec.contact_point_type	:= null;
    p_contact_point_rec.status		        := null;
    p_contact_point_rec.owner_table_name	:= null;
    p_contact_point_rec.owner_table_id		:= null;
    p_contact_point_rec.primary_flag		:= null;
    p_contact_point_rec.orig_system_reference	:= null;
    p_contact_point_rec.attribute_category	:= null;
    p_contact_point_rec.attribute1		:= null;
    p_contact_point_rec.attribute2		:= null;
    p_contact_point_rec.attribute3		:= null;
    p_contact_point_rec.attribute4		:= null;
    p_contact_point_rec.attribute5		:= null;
    p_contact_point_rec.attribute6		:= null;
    p_contact_point_rec.attribute7		:= null;
    p_contact_point_rec.attribute8		:= null;
    p_contact_point_rec.attribute9		:= null;
    p_contact_point_rec.attribute10		:= null;
    p_contact_point_rec.attribute11		:= null;
    p_contact_point_rec.attribute12		:= null;
    p_contact_point_rec.attribute13		:= null;
    p_contact_point_rec.attribute14		:= null;
    p_contact_point_rec.attribute15		:= null;
    p_contact_point_rec.attribute16		:= null;
    p_contact_point_rec.attribute17		:= null;
    p_contact_point_rec.attribute18		:= null;
    p_contact_point_rec.attribute19		:= null;
    p_contact_point_rec.attribute20		:= null;
END;

PROCEDURE Nullify_edi_rec
( p_edi_rec   IN OUT NOCOPY hz_contact_point_v2pub.edi_rec_type )
IS
BEGIN
p_edi_rec.edi_transaction_handling		:= null;
p_edi_rec.edi_id_number		:= null;
p_edi_rec.edi_payment_method		:= null;
p_edi_rec.edi_payment_format		:= null;
p_edi_rec.edi_remittance_method		:= null;
p_edi_rec.edi_remittance_instruction		:= null;
p_edi_rec.edi_tp_header_id		:= null;
p_edi_rec.edi_ece_tp_location_code		:= null;
END;


PROCEDURE Nullify_email_rec
( p_email_rec   IN OUT NOCOPY hz_contact_point_v2pub.email_rec_type )
IS
BEGIN
p_email_rec.email_format		:= null;
p_email_rec.email_address		:= null;
END;


PROCEDURE Nullify_phone_rec
( p_phone_rec   IN OUT NOCOPY hz_contact_point_v2pub.phone_rec_type )
IS
BEGIN
p_phone_rec.phone_calling_calendar		:= null;
p_phone_rec.last_contact_dt_time		:= null;
p_phone_rec.timezone_id		:= null;
p_phone_rec.phone_area_code		:= null;
p_phone_rec.phone_country_code		:= null;
p_phone_rec.phone_number		:= null;
p_phone_rec.phone_extension		:= null;
p_phone_rec.phone_line_type		:= null;
END;


PROCEDURE Nullify_telex_rec
( p_telex_rec   IN OUT NOCOPY hz_contact_point_v2pub.telex_rec_type )
IS
BEGIN
p_telex_rec.telex_number		:= null;
END;

PROCEDURE Nullify_web_rec
( p_web_rec   IN OUT NOCOPY hz_contact_point_v2pub.web_rec_type )
IS
BEGIN
p_web_rec.web_type		:= null;
p_web_rec.url		:= null;
END;

PROCEDURE Nullify_party_rec
( p_party_rec   IN OUT NOCOPY hz_party_v2pub.party_rec_type )
IS
BEGIN
   p_party_rec.party_id				:= NULL;
   p_party_rec.party_number			:= NULL;
   p_party_rec.validated_flag			:= NULL;
   p_party_rec.orig_system_reference		:= NULL;
   p_party_rec.status				:= NULL;
   p_party_rec.category_code			:= NULL;
   p_party_rec.salutation			:= NULL;
   p_party_rec.attribute_category		:= NULL;
   p_party_rec.attribute1			:= NULL;
   p_party_rec.attribute2			:= NULL;
   p_party_rec.attribute3			:= NULL;
   p_party_rec.attribute4			:= NULL;
   p_party_rec.attribute5			:= NULL;
   p_party_rec.attribute6			:= NULL;
   p_party_rec.attribute7			:= NULL;
   p_party_rec.attribute8			:= NULL;
   p_party_rec.attribute9			:= NULL;
   p_party_rec.attribute10			:= NULL;
   p_party_rec.attribute11			:= NULL;
   p_party_rec.attribute12			:= NULL;
   p_party_rec.attribute13			:= NULL;
   p_party_rec.attribute14			:= NULL;
   p_party_rec.attribute15			:= NULL;
   p_party_rec.attribute16			:= NULL;
   p_party_rec.attribute17			:= NULL;
   p_party_rec.attribute18			:= NULL;
   p_party_rec.attribute19			:= NULL;
   p_party_rec.attribute20			:= NULL;
   p_party_rec.attribute21			:= NULL;
   p_party_rec.attribute22			:= NULL;
   p_party_rec.attribute23			:= NULL;
   p_party_rec.attribute24			:= NULL;

  -- p_party_rec.global_attribute_category        := NULL;
  -- p_party_rec.global_attribute1		:= NULL;
  -- p_party_rec.global_attribute2		:= NULL;
  -- p_party_rec.global_attribute3		:= NULL;
  -- p_party_rec.global_attribute4		:= NULL;
  -- p_party_rec.global_attribute5		:= NULL;
  -- p_party_rec.global_attribute6		:= NULL;
  -- p_party_rec.global_attribute7		:= NULL;
  -- p_party_rec.global_attribute8		:= NULL;
  -- p_party_rec.global_attribute9		:= NULL;
  -- p_party_rec.global_attribute10		:= NULL;
  -- p_party_rec.global_attribute11		:= NULL;
  -- p_party_rec.global_attribute12		:= NULL;
  -- p_party_rec.global_attribute13		:= NULL;
  -- p_party_rec.global_attribute14		:= NULL;
  -- p_party_rec.global_attribute15		:= NULL;
  -- p_party_rec.global_attribute16		:= NULL;
  -- p_party_rec.global_attribute17		:= NULL;
  -- p_party_rec.global_attribute18		:= NULL;
  -- p_party_rec.global_attribute19		:= NULL;
  -- p_party_rec.global_attribute20		:= NULL;

  -- p_party_rec.wh_update_date			:= NULL;

END;

PROCEDURE Nullify_organization_rec
( p_organization_rec   IN OUT NOCOPY hz_party_v2pub.organization_rec_type )
IS
BEGIN
   p_organization_rec.organization_name		:=  null;
   p_organization_rec.duns_number_c		:=  null;
   p_organization_rec.enquiry_duns		:=  null;
   p_organization_rec.ceo_name			:=  null;
   p_organization_rec.ceo_title			:=  null;
   p_organization_rec.principal_name		:=  null;
   p_organization_rec.principal_title		:=  null;
   p_organization_rec.legal_status		:=  null;
   p_organization_rec.control_yr		:=  null;
   p_organization_rec.employees_total		:=  null;
   p_organization_rec.hq_branch_ind		:=  null;
   p_organization_rec.branch_flag		:=  null;
   p_organization_rec.oob_ind			:=  null;
   p_organization_rec.line_of_business		:=  null;
   p_organization_rec.cong_dist_code		:=  null;
   p_organization_rec.sic_code			:=  null;
   p_organization_rec.import_ind		:=  null;
   p_organization_rec.export_ind		:=  null;
   p_organization_rec.labor_surplus_ind		:=  null;
   p_organization_rec.debarment_ind		:=  null;
   p_organization_rec.minority_owned_ind	:=  null;
   p_organization_rec.minority_owned_type	:=  null;
   p_organization_rec.woman_owned_ind		:=  null;
   p_organization_rec.disadv_8a_ind		:=  null;
   p_organization_rec.small_bus_ind		:=  null;
   p_organization_rec.rent_own_ind              :=  null;
   p_organization_rec.debarments_count		:=  null;
   p_organization_rec.debarments_date		:=  null;
   p_organization_rec.failure_score		:=  null;
   p_organization_rec.failure_score_override_code    :=  null;
   p_organization_rec.failure_score_commentary	     :=  null;
   p_organization_rec.global_failure_score	     :=  null;
   p_organization_rec.db_rating			:=  null;
   p_organization_rec.credit_score		:=  null;
   p_organization_rec.credit_score_commentary	:=  null;
   p_organization_rec.paydex_score		:=  null;
   p_organization_rec.paydex_three_months_ago	:=  null;
   p_organization_rec.paydex_norm		:=  null;
   p_organization_rec.best_time_contact_begin	:=  null;
   p_organization_rec.best_time_contact_end	:=  null;
   p_organization_rec.organization_name_phonetic:=  null;
   p_organization_rec.tax_reference             :=  null;
   p_organization_rec.gsa_indicator_flag        :=  null;
   p_organization_rec.jgzz_fiscal_code          :=  null;
   p_organization_rec.analysis_fy		:=  null;
   p_organization_rec.fiscal_yearend_month	:=  null;
   p_organization_rec.curr_fy_potential_revenue	:=  null;
   p_organization_rec.next_fy_potential_revenue	:=  null;
   p_organization_rec.year_established		:=  null;
   p_organization_rec.mission_statement		:=  null;
   p_organization_rec.organization_type		:=  null;
   p_organization_rec.business_scope		:=  null;
   p_organization_rec.corporation_class		:=  null;
   p_organization_rec.known_as                  :=  null;
   p_organization_rec.known_as2                 :=  null;
   p_organization_rec.known_as3                 :=  null;
   p_organization_rec.known_as4                 :=  null;
   p_organization_rec.known_as5                 :=  null;
   p_organization_rec.local_bus_iden_type	:=  null;
   p_organization_rec.local_bus_identifier	:=  null;
   p_organization_rec.pref_functional_currency	:=  null;
   p_organization_rec.registration_type		:=  null;
   p_organization_rec.total_employees_text	:=  null;
   p_organization_rec.total_employees_ind	:=  null;
   p_organization_rec.total_emp_est_ind		:=  null;
   p_organization_rec.total_emp_min_ind		:=  null;
   p_organization_rec.parent_sub_ind		:=  null;
   p_organization_rec.incorp_year		:=  null;
   p_organization_rec.sic_code_type             :=  null;
   p_organization_rec.public_private_ownership_flag   :=  null;
   p_organization_rec.internal_flag		:=  null;
   p_organization_rec.local_activity_code_type  :=  null;
   p_organization_rec.local_activity_code       :=  null;
   p_organization_rec.emp_at_primary_adr        :=  null;
   p_organization_rec.emp_at_primary_adr_text   :=  null;
   p_organization_rec.emp_at_primary_adr_est_ind:=  null;
   p_organization_rec.emp_at_primary_adr_min_ind:=  null;
   p_organization_rec.high_credit		:=  null;
   p_organization_rec.avg_high_credit		:=  null;
   p_organization_rec.total_payments		:=  null;
   p_organization_rec.credit_score_class        :=  null;
   p_organization_rec.credit_score_natl_percentile:=  null;
   p_organization_rec.credit_score_incd_default :=  null;
   p_organization_rec.credit_score_age          :=  null;
   p_organization_rec.credit_score_date         :=  null;
   p_organization_rec.credit_score_commentary2  :=  null;
   p_organization_rec.credit_score_commentary3  :=  null;
   p_organization_rec.credit_score_commentary4        :=  null;
   p_organization_rec.credit_score_commentary5        :=  null;
   p_organization_rec.credit_score_commentary6        :=  null;
   p_organization_rec.credit_score_commentary7        :=  null;
   p_organization_rec.credit_score_commentary8        :=  null;
   p_organization_rec.credit_score_commentary9        :=  null;
   p_organization_rec.credit_score_commentary10       :=  null;
   p_organization_rec.failure_score_class             :=  null;
   p_organization_rec.failure_score_incd_default      :=  null;
   p_organization_rec.failure_score_age               :=  null;
   p_organization_rec.failure_score_date              :=  null;
   p_organization_rec.failure_score_commentary2       :=  null;
   p_organization_rec.failure_score_commentary3       :=  null;
   p_organization_rec.failure_score_commentary4       :=  null;
   p_organization_rec.failure_score_commentary5       :=  null;
   p_organization_rec.failure_score_commentary6       :=  null;
   p_organization_rec.failure_score_commentary7       :=  null;
   p_organization_rec.failure_score_commentary8       :=  null;
   p_organization_rec.failure_score_commentary9       :=  null;
   p_organization_rec.failure_score_commentary10      :=  null;
   p_organization_rec.maximum_credit_recommendation   :=  null;
   p_organization_rec.maximum_credit_currency_code    :=  null;
   p_organization_rec.displayed_duns_party_id         :=  null;
   p_organization_rec.content_source_type             :=  null;
   p_organization_rec.content_source_number           :=  null;

  -- p_organization_rec.attribute_category              :=  null;
  -- p_organization_rec.attribute1                      :=  null;
  -- p_organization_rec.attribute2                      :=  null;
  -- p_organization_rec.attribute3                      :=  null;
  -- p_organization_rec.attribute4                      :=  null;
  -- p_organization_rec.attribute5                      :=  null;
  -- p_organization_rec.attribute6                      :=  null;
  -- p_organization_rec.attribute7                      :=  null;
  -- p_organization_rec.attribute8                      :=  null;
  -- p_organization_rec.attribute9                      :=  null;
  -- p_organization_rec.attribute10                     :=  null;
  -- p_organization_rec.attribute11                     :=  null;
  -- p_organization_rec.attribute12                     :=  null;
  -- p_organization_rec.attribute13                     :=  null;
  -- p_organization_rec.attribute14                     :=  null;
  -- p_organization_rec.attribute15                     :=  null;
  -- p_organization_rec.attribute16                     :=  null;
  -- p_organization_rec.attribute17                     :=  null;
  -- p_organization_rec.attribute18                     :=  null;
  -- p_organization_rec.attribute19                     :=  null;
  -- p_organization_rec.attribute20                     :=  null;
  -- p_organization_rec.global_attribute_category       :=  null;
  -- p_organization_rec.global_attribute1               :=  null;
  -- p_organization_rec.global_attribute2               :=  null;
  -- p_organization_rec.global_attribute3               :=  null;
  -- p_organization_rec.global_attribute4               :=  null;
  -- p_organization_rec.global_attribute5               :=  null;
  -- p_organization_rec.global_attribute6               :=  null;
  -- p_organization_rec.global_attribute7               :=  null;
  -- p_organization_rec.global_attribute8               :=  null;
  -- p_organization_rec.global_attribute9               :=  null;
  -- p_organization_rec.global_attribute10              :=  null;
  -- p_organization_rec.global_attribute11              :=  null;
  -- p_organization_rec.global_attribute12              :=  null;
  -- p_organization_rec.global_attribute13              :=  null;
  -- p_organization_rec.global_attribute14              :=  null;
  -- p_organization_rec.global_attribute15              :=  null;
  -- p_organization_rec.global_attribute16              :=  null;
  -- p_organization_rec.global_attribute17              :=  null;
  -- p_organization_rec.global_attribute18              :=  null;
  -- p_organization_rec.global_attribute19              :=  null;
  -- p_organization_rec.global_attribute20              :=  null;
  -- p_organization_rec.wh_update_date                  :=  null;

   nullify_party_rec(p_organization_rec.party_rec);
END;


PROCEDURE Nullify_party_site_rec
( p_party_site_rec      IN OUT   NOCOPY hz_party_site_v2pub.party_site_rec_type )
IS
BEGIN
   p_party_site_rec.party_site_id		:= NULL;
   p_party_site_rec.party_id			:= NULL;
   p_party_site_rec.location_id			:= NULL;
   p_party_site_rec.party_site_number		:= NULL;
   p_party_site_rec.orig_system_reference       := NULL;
   p_party_site_rec.mailstop			:= NULL;
   p_party_site_rec.identifying_address_flag	:= NULL;
   p_party_site_rec.language			:= NULL;
   p_party_site_rec.status			:= NULL;
   p_party_site_rec.party_site_name		:= NULL;
   p_party_site_rec.attribute_category		:= NULL;
   p_party_site_rec.attribute1			:= NULL;
   p_party_site_rec.attribute2			:= NULL;
   p_party_site_rec.attribute3			:= NULL;
   p_party_site_rec.attribute4			:= NULL;
   p_party_site_rec.attribute5			:= NULL;
   p_party_site_rec.attribute6			:= NULL;
   p_party_site_rec.attribute7			:= NULL;
   p_party_site_rec.attribute8			:= NULL;
   p_party_site_rec.attribute9			:= NULL;
   p_party_site_rec.attribute10			:= NULL;
   p_party_site_rec.attribute11			:= NULL;
   p_party_site_rec.attribute12			:= NULL;
   p_party_site_rec.attribute13			:= NULL;
   p_party_site_rec.attribute14			:= NULL;
   p_party_site_rec.attribute15			:= NULL;
   p_party_site_rec.attribute16			:= NULL;
   p_party_site_rec.attribute17			:= NULL;
   p_party_site_rec.attribute18			:= NULL;
   p_party_site_rec.attribute19			:= NULL;
   p_party_site_rec.attribute20			:= NULL;

  -- p_party_site_rec.global_attribute_category	:= NULL;
  -- p_party_site_rec.global_attribute1		:= NULL;
  -- p_party_site_rec.global_attribute2		:= NULL;
  -- p_party_site_rec.global_attribute3		:= NULL;
  -- p_party_site_rec.global_attribute4		:= NULL;
  -- p_party_site_rec.global_attribute5		:= NULL;
  -- p_party_site_rec.global_attribute6		:= NULL;
  -- p_party_site_rec.global_attribute7		:= NULL;
  -- p_party_site_rec.global_attribute8		:= NULL;
  -- p_party_site_rec.global_attribute9		:= NULL;
  -- p_party_site_rec.global_attribute10		:= NULL;
  -- p_party_site_rec.global_attribute11		:= NULL;
  -- p_party_site_rec.global_attribute12		:= NULL;
  -- p_party_site_rec.global_attribute13		:= NULL;
  -- p_party_site_rec.global_attribute14		:= NULL;
  -- p_party_site_rec.global_attribute15		:= NULL;
  -- p_party_site_rec.global_attribute16		:= NULL;
  -- p_party_site_rec.global_attribute17		:= NULL;
  -- p_party_site_rec.global_attribute18		:= NULL;
  -- p_party_site_rec.global_attribute19		:= NULL;
  -- p_party_site_rec.global_attribute20		:= NULL;
  -- p_party_site_rec.wh_update_date		:= NULL;

   p_party_site_rec.ADDRESSEE 			:= NULL;
END Nullify_party_site_rec;

-----------------------------
-- Fill_rec_Routine
-----------------------------
-- PROCEDURE contact_point_rec_fill
-- PROCEDURE location_rec_fill
-- PROCEDURE party_site_rec_fill
-- PROCEDURE organization_rec_fill
------------------------------
PROCEDURE contact_point_rec_fill
( p_contact_point_rec    IN OUT NOCOPY hz_contact_point_v2pub.contact_point_rec_type,
  l_tab                 IN        hz_param_pkg.param_tab_t,
  p_ind                 IN        VARCHAR2  )
IS
l_count      NUMBER;
BEGIN
l_count := l_tab.count;
IF l_count > 0 THEN
  FOR i in 1 .. l_count LOOP
    IF l_tab(i).param_indicator = p_ind THEN
         IF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.CONTACT_POINT_ID' THEN
               P_CONTACT_POINT_REC.CONTACT_POINT_ID := l_tab(i).param_num;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.CONTACT_POINT_TYPE' THEN
               P_CONTACT_POINT_REC.CONTACT_POINT_TYPE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.STATUS' THEN
               P_CONTACT_POINT_REC.STATUS := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.OWNER_TABLE_NAME' THEN
               P_CONTACT_POINT_REC.OWNER_TABLE_NAME := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.OWNER_TABLE_ID' THEN
               P_CONTACT_POINT_REC.OWNER_TABLE_ID := l_tab(i).param_num;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.PRIMARY_FLAG' THEN
               P_CONTACT_POINT_REC.PRIMARY_FLAG := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ORIG_SYSTEM_REFERENCE' THEN
               P_CONTACT_POINT_REC.ORIG_SYSTEM_REFERENCE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.CONTENT_SOURCE_TYPE' THEN
               P_CONTACT_POINT_REC.CONTENT_SOURCE_TYPE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE_CATEGORY' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE_CATEGORY := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE1' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE1 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE2' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE2 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE3' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE3 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE4' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE4 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE5' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE5 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE6' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE6 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE7' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE7 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE8' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE8 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE9' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE9 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE10' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE10 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE11' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE11 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE12' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE12 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE13' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE13 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE14' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE14 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE15' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE15 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE16' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE16 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE17' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE17 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE18' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE18 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE19' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE19 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_CONTACT_POINT_REC.ATTRIBUTE20' THEN
               P_CONTACT_POINT_REC.ATTRIBUTE20 := l_tab(i).param_char;
         END IF;
   END IF;
END LOOP;
END IF;
END contact_point_rec_fill;

PROCEDURE edi_rec_fill
( p_edi_rec    IN OUT NOCOPY hz_contact_point_v2pub.edi_rec_type,
  l_tab        IN            hz_param_pkg.param_tab_t,
  p_ind        IN            VARCHAR2 )
IS
l_count      NUMBER;
BEGIN
l_count := l_tab.count;
IF l_count > 0 THEN
FOR i in 1 .. l_count LOOP
IF l_tab(i).param_indicator = p_ind THEN
 IF    l_tab(i).param_name = 'P_EDI_REC.EDI_TRANSACTION_HANDLING' THEN
    P_EDI_REC.EDI_TRANSACTION_HANDLING := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_EDI_REC.EDI_ID_NUMBER' THEN
    P_EDI_REC.EDI_ID_NUMBER := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_EDI_REC.EDI_PAYMENT_METHOD' THEN
    P_EDI_REC.EDI_PAYMENT_METHOD := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_EDI_REC.EDI_PAYMENT_FORMAT' THEN
    P_EDI_REC.EDI_PAYMENT_FORMAT := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_EDI_REC.EDI_REMITTANCE_METHOD' THEN
    P_EDI_REC.EDI_REMITTANCE_METHOD := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_EDI_REC.EDI_REMITTANCE_INSTRUCTION' THEN
    P_EDI_REC.EDI_REMITTANCE_INSTRUCTION := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_EDI_REC.EDI_TP_HEADER_ID' THEN
    P_EDI_REC.EDI_TP_HEADER_ID := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_EDI_REC.EDI_ECE_TP_LOCATION_CODE' THEN
   P_EDI_REC.EDI_ECE_TP_LOCATION_CODE := l_tab(i).param_char;
 END IF;
END IF;
END LOOP;
END IF;
END;


PROCEDURE email_rec_fill
( p_email_rec    IN OUT NOCOPY hz_contact_point_v2pub.email_rec_type,
  l_tab        IN            hz_param_pkg.param_tab_t,
  p_ind        IN            VARCHAR2 )
IS
l_count      NUMBER;
BEGIN
l_count := l_tab.count;
IF l_count > 0 THEN
FOR i in 1 .. l_count LOOP
IF l_tab(i).param_indicator = p_ind THEN
 IF    l_tab(i).param_name = 'P_EMAIL_REC.EMAIL_FORMAT' THEN
    P_EMAIL_REC.EMAIL_FORMAT := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_EMAIL_REC.EMAIL_ADDRESS' THEN
    P_EMAIL_REC.EMAIL_ADDRESS := l_tab(i).param_char;
 END IF;
END IF;
END LOOP;
END IF;
END;

PROCEDURE phone_rec_fill
( p_phone_rec    IN OUT NOCOPY hz_contact_point_v2pub.phone_rec_type,
  l_tab        IN            hz_param_pkg.param_tab_t,
  p_ind        IN            VARCHAR2 )
IS
l_count      NUMBER;
BEGIN
l_count := l_tab.count;
IF l_count > 0 THEN
FOR i in 1 .. l_count LOOP
IF l_tab(i).param_indicator = p_ind THEN
 IF    l_tab(i).param_name = 'P_PHONE_REC.PHONE_CALLING_CALENDAR' THEN
    P_PHONE_REC.PHONE_CALLING_CALENDAR := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PHONE_REC.LAST_CONTACT_DT_TIME' THEN
    P_PHONE_REC.LAST_CONTACT_DT_TIME := l_tab(i).param_date;
 ELSIF    l_tab(i).param_name = 'P_PHONE_REC.TIMEZONE_ID' THEN
    P_PHONE_REC.TIMEZONE_ID := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_PHONE_REC.PHONE_AREA_CODE' THEN
    P_PHONE_REC.PHONE_AREA_CODE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PHONE_REC.PHONE_COUNTRY_CODE' THEN
    P_PHONE_REC.PHONE_COUNTRY_CODE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PHONE_REC.PHONE_NUMBER' THEN
    P_PHONE_REC.PHONE_NUMBER := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PHONE_REC.PHONE_EXTENSION' THEN
    P_PHONE_REC.PHONE_EXTENSION := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PHONE_REC.PHONE_LINE_TYPE' THEN
    P_PHONE_REC.PHONE_LINE_TYPE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PHONE_REC.RAW_PHONE_NUMBER' THEN
    P_PHONE_REC.RAW_PHONE_NUMBER := l_tab(i).param_char;
 END IF;
END IF;
END LOOP;
END IF;
END;


PROCEDURE telex_rec_fill
( p_telex_rec    IN OUT NOCOPY hz_contact_point_v2pub.telex_rec_type,
  l_tab        IN            hz_param_pkg.param_tab_t,
  p_ind        IN            VARCHAR2 )
IS
l_count      NUMBER;
BEGIN
l_count := l_tab.count;
IF l_count > 0 THEN
FOR i in 1 .. l_count LOOP
IF l_tab(i).param_indicator = p_ind THEN
 IF    l_tab(i).param_name = 'P_TELEX_REC.TELEX_NUMBER' THEN
    P_TELEX_REC.TELEX_NUMBER := l_tab(i).param_char;
 END IF;
END IF;
END LOOP;
END IF;
END;

PROCEDURE web_rec_fill
( p_web_rec    IN OUT NOCOPY hz_contact_point_v2pub.web_rec_type,
  l_tab        IN            hz_param_pkg.param_tab_t,
  p_ind        IN            VARCHAR2 )
IS
l_count      NUMBER;
BEGIN
l_count := l_tab.count;
IF l_count > 0 THEN
FOR i in 1 .. l_count LOOP
IF l_tab(i).param_indicator = p_ind THEN
 IF    l_tab(i).param_name = 'P_WEB_REC.WEB_TYPE' THEN
    P_WEB_REC.WEB_TYPE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_WEB_REC.URL' THEN
    P_WEB_REC.URL := l_tab(i).param_char;
 END IF;
END IF;
END LOOP;
END IF;
END;

procedure location_rec_fill
( p_location_rec    IN OUT NOCOPY hz_location_v2pub.location_rec_type,
  l_tab                 IN        hz_param_pkg.param_tab_t,
  p_ind                 IN        VARCHAR2 )
IS
l_count      NUMBER;
BEGIN
l_count := l_tab.count;
IF l_count > 0 THEN
FOR i in 1 .. l_count LOOP
     IF l_tab(i).param_indicator = p_ind THEN
         IF    l_tab(i).param_name = 'P_LOCATION_REC.LOCATION_ID' THEN
                P_LOCATION_REC.LOCATION_ID := l_tab(i).param_num;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ORIG_SYSTEM_REFERENCE' THEN
                P_LOCATION_REC.ORIG_SYSTEM_REFERENCE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.COUNTRY' THEN
              P_LOCATION_REC.COUNTRY := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ADDRESS1' THEN
              P_LOCATION_REC.ADDRESS1 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ADDRESS2' THEN
              P_LOCATION_REC.ADDRESS2 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ADDRESS3' THEN
              P_LOCATION_REC.ADDRESS3 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ADDRESS4' THEN
              P_LOCATION_REC.ADDRESS4 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.CITY' THEN
              P_LOCATION_REC.CITY := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.POSTAL_CODE' THEN
              P_LOCATION_REC.POSTAL_CODE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.STATE' THEN
              P_LOCATION_REC.STATE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.PROVINCE' THEN
              P_LOCATION_REC.PROVINCE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.COUNTY' THEN
              P_LOCATION_REC.COUNTY := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ADDRESS_KEY' THEN
               P_LOCATION_REC.ADDRESS_KEY := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ADDRESS_STYLE' THEN
               P_LOCATION_REC.ADDRESS_STYLE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.VALIDATED_FLAG' THEN
               P_LOCATION_REC.VALIDATED_FLAG := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ADDRESS_LINES_PHONETIC' THEN
               P_LOCATION_REC.ADDRESS_LINES_PHONETIC := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.PO_BOX_NUMBER' THEN
               P_LOCATION_REC.PO_BOX_NUMBER := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.HOUSE_NUMBER' THEN
               P_LOCATION_REC.HOUSE_NUMBER := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.STREET_SUFFIX' THEN
               P_LOCATION_REC.STREET_SUFFIX := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.STREET' THEN
               P_LOCATION_REC.STREET := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.STREET_NUMBER' THEN
               P_LOCATION_REC.STREET_NUMBER := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.FLOOR' THEN
               P_LOCATION_REC.FLOOR := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.SUITE' THEN
               P_LOCATION_REC.SUITE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.POSTAL_PLUS4_CODE' THEN
               P_LOCATION_REC.POSTAL_PLUS4_CODE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.POSITION' THEN
               P_LOCATION_REC.POSITION := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.LOCATION_DIRECTIONS' THEN
               P_LOCATION_REC.LOCATION_DIRECTIONS := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ADDRESS_EFFECTIVE_DATE' THEN
               P_LOCATION_REC.ADDRESS_EFFECTIVE_DATE := l_tab(i).param_date;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ADDRESS_EXPIRATION_DATE' THEN
               P_LOCATION_REC.ADDRESS_EXPIRATION_DATE := l_tab(i).param_date;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.CLLI_CODE' THEN
               P_LOCATION_REC.CLLI_CODE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.LANGUAGE' THEN
               P_LOCATION_REC.LANGUAGE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.SHORT_DESCRIPTION' THEN
               P_LOCATION_REC.SHORT_DESCRIPTION := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.DESCRIPTION' THEN
               P_LOCATION_REC.DESCRIPTION := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.LOC_HIERARCHY_ID' THEN
               P_LOCATION_REC.LOC_HIERARCHY_ID := l_tab(i).param_num;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.SALES_TAX_GEOCODE' THEN
               P_LOCATION_REC.SALES_TAX_GEOCODE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.SALES_TAX_INSIDE_CITY_LIMITS' THEN
               P_LOCATION_REC.SALES_TAX_INSIDE_CITY_LIMITS := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.FA_LOCATION_ID' THEN
               P_LOCATION_REC.FA_LOCATION_ID := l_tab(i).param_num;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.CONTENT_SOURCE_TYPE' THEN
               P_LOCATION_REC.CONTENT_SOURCE_TYPE := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE_CATEGORY' THEN
               P_LOCATION_REC.ATTRIBUTE_CATEGORY := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE1' THEN
               P_LOCATION_REC.ATTRIBUTE1 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE2' THEN
               P_LOCATION_REC.ATTRIBUTE2 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE3' THEN
              P_LOCATION_REC.ATTRIBUTE3 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE4' THEN
              P_LOCATION_REC.ATTRIBUTE4 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE5' THEN
              P_LOCATION_REC.ATTRIBUTE5 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE6' THEN
              P_LOCATION_REC.ATTRIBUTE6 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE7' THEN
              P_LOCATION_REC.ATTRIBUTE7 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE8' THEN
              P_LOCATION_REC.ATTRIBUTE8 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE9' THEN
              P_LOCATION_REC.ATTRIBUTE9 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE10' THEN
              P_LOCATION_REC.ATTRIBUTE10 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE11' THEN
              P_LOCATION_REC.ATTRIBUTE11 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE12' THEN
              P_LOCATION_REC.ATTRIBUTE12 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE13' THEN
              P_LOCATION_REC.ATTRIBUTE13 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE14' THEN
              P_LOCATION_REC.ATTRIBUTE14 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE15' THEN
              P_LOCATION_REC.ATTRIBUTE15 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE16' THEN
              P_LOCATION_REC.ATTRIBUTE16 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE17' THEN
              P_LOCATION_REC.ATTRIBUTE17 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE18' THEN
              P_LOCATION_REC.ATTRIBUTE18 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE19' THEN
               P_LOCATION_REC.ATTRIBUTE19 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.ATTRIBUTE20' THEN
               P_LOCATION_REC.ATTRIBUTE20 := l_tab(i).param_char;
         ELSIF    l_tab(i).param_name = 'P_LOCATION_REC.TIMEZONE_ID' THEN
               P_LOCATION_REC.TIMEZONE_ID := l_tab(i).param_num;
         END IF;
  END IF;
END LOOP;
END IF;
END location_rec_fill;

PROCEDURE organization_rec_fill
( p_organization_rec  IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
  l_tab               IN            hz_param_pkg.param_tab_t,
  p_ind               IN            VARCHAR2 )
IS
l_count      NUMBER;
BEGIN
l_count := l_tab.count;
IF l_count > 0 THEN
FOR i in 1 .. l_count LOOP
IF l_tab(i).param_indicator = p_ind THEN
 IF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ORGANIZATION_NAME' THEN
    P_ORGANIZATION_REC.ORGANIZATION_NAME := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.DUNS_NUMBER_C' THEN
    P_ORGANIZATION_REC.DUNS_NUMBER_C := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ENQUIRY_DUNS' THEN
    P_ORGANIZATION_REC.ENQUIRY_DUNS := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CEO_NAME' THEN
   P_ORGANIZATION_REC.CEO_NAME := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CEO_TITLE' THEN
    P_ORGANIZATION_REC.CEO_TITLE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PRINCIPAL_NAME' THEN
    P_ORGANIZATION_REC.PRINCIPAL_NAME := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PRINCIPAL_TITLE' THEN
    P_ORGANIZATION_REC.PRINCIPAL_TITLE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.LEGAL_STATUS' THEN
    P_ORGANIZATION_REC.LEGAL_STATUS := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CONTROL_YR' THEN
    P_ORGANIZATION_REC.CONTROL_YR := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.EMPLOYEES_TOTAL' THEN
    P_ORGANIZATION_REC.EMPLOYEES_TOTAL := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.HQ_BRANCH_IND' THEN
    P_ORGANIZATION_REC.HQ_BRANCH_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.BRANCH_FLAG' THEN
    P_ORGANIZATION_REC.BRANCH_FLAG := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.OOB_IND' THEN
    P_ORGANIZATION_REC.OOB_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.LINE_OF_BUSINESS' THEN
    P_ORGANIZATION_REC.LINE_OF_BUSINESS := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CONG_DIST_CODE' THEN
    P_ORGANIZATION_REC.CONG_DIST_CODE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.SIC_CODE' THEN
    P_ORGANIZATION_REC.SIC_CODE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.IMPORT_IND' THEN
    P_ORGANIZATION_REC.IMPORT_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.EXPORT_IND' THEN
    P_ORGANIZATION_REC.EXPORT_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.LABOR_SURPLUS_IND' THEN
    P_ORGANIZATION_REC.LABOR_SURPLUS_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.DEBARMENT_IND' THEN
    P_ORGANIZATION_REC.DEBARMENT_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.MINORITY_OWNED_IND' THEN
    P_ORGANIZATION_REC.MINORITY_OWNED_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.MINORITY_OWNED_TYPE' THEN
    P_ORGANIZATION_REC.MINORITY_OWNED_TYPE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.WOMAN_OWNED_IND' THEN
    P_ORGANIZATION_REC.WOMAN_OWNED_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.DISADV_8A_IND' THEN
    P_ORGANIZATION_REC.DISADV_8A_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.SMALL_BUS_IND' THEN
    P_ORGANIZATION_REC.SMALL_BUS_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.RENT_OWN_IND' THEN
    P_ORGANIZATION_REC.RENT_OWN_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.DEBARMENTS_COUNT' THEN
    P_ORGANIZATION_REC.DEBARMENTS_COUNT := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.DEBARMENTS_DATE' THEN
    P_ORGANIZATION_REC.DEBARMENTS_DATE := l_tab(i).param_date;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE' THEN
    P_ORGANIZATION_REC.FAILURE_SCORE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_NATNL_PERCENTILE' THEN
    P_ORGANIZATION_REC.FAILURE_SCORE_NATNL_PERCENTILE := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_OVERRIDE_CODE' THEN
    P_ORGANIZATION_REC.FAILURE_SCORE_OVERRIDE_CODE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY' THEN
    P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.GLOBAL_FAILURE_SCORE' THEN
    P_ORGANIZATION_REC.GLOBAL_FAILURE_SCORE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.DB_RATING' THEN
    P_ORGANIZATION_REC.DB_RATING := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE' THEN
    P_ORGANIZATION_REC.CREDIT_SCORE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY' THEN
    P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PAYDEX_SCORE' THEN
    P_ORGANIZATION_REC.PAYDEX_SCORE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PAYDEX_THREE_MONTHS_AGO' THEN
    P_ORGANIZATION_REC.PAYDEX_THREE_MONTHS_AGO := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PAYDEX_NORM' THEN
    P_ORGANIZATION_REC.PAYDEX_NORM := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.BEST_TIME_CONTACT_BEGIN' THEN
    P_ORGANIZATION_REC.BEST_TIME_CONTACT_BEGIN := l_tab(i).param_date;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.BEST_TIME_CONTACT_END' THEN
    P_ORGANIZATION_REC.BEST_TIME_CONTACT_END := l_tab(i).param_date;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ORGANIZATION_NAME_PHONETIC' THEN
    P_ORGANIZATION_REC.ORGANIZATION_NAME_PHONETIC := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.TAX_REFERENCE' THEN
    P_ORGANIZATION_REC.TAX_REFERENCE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.GSA_INDICATOR_FLAG' THEN
    P_ORGANIZATION_REC.GSA_INDICATOR_FLAG := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.JGZZ_FISCAL_CODE' THEN
    P_ORGANIZATION_REC.JGZZ_FISCAL_CODE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ANALYSIS_FY' THEN
    P_ORGANIZATION_REC.ANALYSIS_FY := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FISCAL_YEAREND_MONTH' THEN
    P_ORGANIZATION_REC.FISCAL_YEAREND_MONTH := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CURR_FY_POTENTIAL_REVENUE' THEN
    P_ORGANIZATION_REC.CURR_FY_POTENTIAL_REVENUE := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.NEXT_FY_POTENTIAL_REVENUE' THEN
    P_ORGANIZATION_REC.NEXT_FY_POTENTIAL_REVENUE := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.YEAR_ESTABLISHED' THEN
    P_ORGANIZATION_REC.YEAR_ESTABLISHED := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.MISSION_STATEMENT' THEN
    P_ORGANIZATION_REC.MISSION_STATEMENT := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ORGANIZATION_TYPE' THEN
    P_ORGANIZATION_REC.ORGANIZATION_TYPE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.BUSINESS_SCOPE' THEN
    P_ORGANIZATION_REC.BUSINESS_SCOPE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CORPORATION_CLASS' THEN
    P_ORGANIZATION_REC.CORPORATION_CLASS := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.KNOWN_AS' THEN
    P_ORGANIZATION_REC.KNOWN_AS := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.KNOWN_AS2' THEN
    P_ORGANIZATION_REC.KNOWN_AS2 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.KNOWN_AS3' THEN
    P_ORGANIZATION_REC.KNOWN_AS3 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.KNOWN_AS4' THEN
    P_ORGANIZATION_REC.KNOWN_AS4 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.KNOWN_AS5' THEN
    P_ORGANIZATION_REC.KNOWN_AS5 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.LOCAL_BUS_IDEN_TYPE' THEN
    P_ORGANIZATION_REC.LOCAL_BUS_IDEN_TYPE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.LOCAL_BUS_IDENTIFIER' THEN
    P_ORGANIZATION_REC.LOCAL_BUS_IDENTIFIER := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PREF_FUNCTIONAL_CURRENCY' THEN
    P_ORGANIZATION_REC.PREF_FUNCTIONAL_CURRENCY := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.REGISTRATION_TYPE' THEN
    P_ORGANIZATION_REC.REGISTRATION_TYPE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.TOTAL_EMPLOYEES_TEXT' THEN
    P_ORGANIZATION_REC.TOTAL_EMPLOYEES_TEXT := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.TOTAL_EMPLOYEES_IND' THEN
    P_ORGANIZATION_REC.TOTAL_EMPLOYEES_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.TOTAL_EMP_EST_IND' THEN
    P_ORGANIZATION_REC.TOTAL_EMP_EST_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.TOTAL_EMP_MIN_IND' THEN
    P_ORGANIZATION_REC.TOTAL_EMP_MIN_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARENT_SUB_IND' THEN
    P_ORGANIZATION_REC.PARENT_SUB_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.INCORP_YEAR' THEN
    P_ORGANIZATION_REC.INCORP_YEAR := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.SIC_CODE_TYPE' THEN
    P_ORGANIZATION_REC.SIC_CODE_TYPE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PUBLIC_PRIVATE_OWNERSHIP_FLAG' THEN
    P_ORGANIZATION_REC.PUBLIC_PRIVATE_OWNERSHIP_FLAG := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.INTERNAL_FLAG' THEN
    P_ORGANIZATION_REC.INTERNAL_FLAG := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.LOCAL_ACTIVITY_CODE_TYPE' THEN
    P_ORGANIZATION_REC.LOCAL_ACTIVITY_CODE_TYPE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.LOCAL_ACTIVITY_CODE' THEN
    P_ORGANIZATION_REC.LOCAL_ACTIVITY_CODE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.EMP_AT_PRIMARY_ADR' THEN
    P_ORGANIZATION_REC.EMP_AT_PRIMARY_ADR := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.EMP_AT_PRIMARY_ADR_TEXT' THEN
    P_ORGANIZATION_REC.EMP_AT_PRIMARY_ADR_TEXT := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.EMP_AT_PRIMARY_ADR_EST_IND' THEN
    P_ORGANIZATION_REC.EMP_AT_PRIMARY_ADR_EST_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.EMP_AT_PRIMARY_ADR_MIN_IND' THEN
    P_ORGANIZATION_REC.EMP_AT_PRIMARY_ADR_MIN_IND := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.HIGH_CREDIT' THEN
    P_ORGANIZATION_REC.HIGH_CREDIT := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.AVG_HIGH_CREDIT' THEN
    P_ORGANIZATION_REC.AVG_HIGH_CREDIT := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.TOTAL_PAYMENTS' THEN
    P_ORGANIZATION_REC.TOTAL_PAYMENTS := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_CLASS' THEN
    P_ORGANIZATION_REC.CREDIT_SCORE_CLASS := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_NATL_PERCENTILE' THEN
    P_ORGANIZATION_REC.CREDIT_SCORE_NATL_PERCENTILE := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_INCD_DEFAULT' THEN
    P_ORGANIZATION_REC.CREDIT_SCORE_INCD_DEFAULT := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_AGE' THEN
    P_ORGANIZATION_REC.CREDIT_SCORE_AGE := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_DATE' THEN
    P_ORGANIZATION_REC.CREDIT_SCORE_DATE := l_tab(i).param_date;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY2' THEN
    P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY2 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY3' THEN
    P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY3 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY4' THEN
   P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY4 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY5' THEN
   P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY5 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY6' THEN
   P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY6 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY7' THEN
   P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY7 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY8' THEN
   P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY8 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY9' THEN
   P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY9 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY10' THEN
   P_ORGANIZATION_REC.CREDIT_SCORE_COMMENTARY10 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_CLASS' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_CLASS := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_INCD_DEFAULT' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_INCD_DEFAULT := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_AGE' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_AGE := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_DATE' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_DATE := l_tab(i).param_date;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY2' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY2 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY3' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY3 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY4' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY4 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY5' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY5 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY6' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY6 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY7' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY7 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY8' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY8 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY9' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY9 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY10' THEN
   P_ORGANIZATION_REC.FAILURE_SCORE_COMMENTARY10 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.MAXIMUM_CREDIT_RECOMMENDATION' THEN
   P_ORGANIZATION_REC.MAXIMUM_CREDIT_RECOMMENDATION := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.MAXIMUM_CREDIT_CURRENCY_CODE' THEN
   P_ORGANIZATION_REC.MAXIMUM_CREDIT_CURRENCY_CODE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.DISPLAYED_DUNS_PARTY_ID' THEN
   P_ORGANIZATION_REC.DISPLAYED_DUNS_PARTY_ID := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CONTENT_SOURCE_TYPE' THEN
   P_ORGANIZATION_REC.CONTENT_SOURCE_TYPE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.CONTENT_SOURCE_NUMBER' THEN
   P_ORGANIZATION_REC.CONTENT_SOURCE_NUMBER := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE_CATEGORY' THEN
   P_ORGANIZATION_REC.ATTRIBUTE_CATEGORY := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE1' THEN
   P_ORGANIZATION_REC.ATTRIBUTE1 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE2' THEN
   P_ORGANIZATION_REC.ATTRIBUTE2 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE3' THEN
   P_ORGANIZATION_REC.ATTRIBUTE3 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE4' THEN
   P_ORGANIZATION_REC.ATTRIBUTE4 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE5' THEN
   P_ORGANIZATION_REC.ATTRIBUTE5 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE6' THEN
   P_ORGANIZATION_REC.ATTRIBUTE6 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE7' THEN
   P_ORGANIZATION_REC.ATTRIBUTE7 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE8' THEN
   P_ORGANIZATION_REC.ATTRIBUTE8 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE9' THEN
   P_ORGANIZATION_REC.ATTRIBUTE9 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE10' THEN
   P_ORGANIZATION_REC.ATTRIBUTE10 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE11' THEN
   P_ORGANIZATION_REC.ATTRIBUTE11 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE12' THEN
   P_ORGANIZATION_REC.ATTRIBUTE12 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE13' THEN
   P_ORGANIZATION_REC.ATTRIBUTE13 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE14' THEN
   P_ORGANIZATION_REC.ATTRIBUTE14 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE15' THEN
   P_ORGANIZATION_REC.ATTRIBUTE15 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE16' THEN
   P_ORGANIZATION_REC.ATTRIBUTE16 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE17' THEN
   P_ORGANIZATION_REC.ATTRIBUTE17 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE18' THEN
   P_ORGANIZATION_REC.ATTRIBUTE18 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE19' THEN
   P_ORGANIZATION_REC.ATTRIBUTE19 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.ATTRIBUTE20' THEN
   P_ORGANIZATION_REC.ATTRIBUTE20 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.PARTY_ID' THEN
   P_ORGANIZATION_REC.PARTY_REC.PARTY_ID := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.PARTY_NUMBER' THEN
   P_ORGANIZATION_REC.PARTY_REC.PARTY_NUMBER := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.VALIDATED_FLAG' THEN
   P_ORGANIZATION_REC.PARTY_REC.VALIDATED_FLAG := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ORIG_SYSTEM_REFERENCE' THEN
   P_ORGANIZATION_REC.PARTY_REC.ORIG_SYSTEM_REFERENCE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.STATUS' THEN
   P_ORGANIZATION_REC.PARTY_REC.STATUS := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.CATEGORY_CODE' THEN
   P_ORGANIZATION_REC.PARTY_REC.CATEGORY_CODE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.SALUTATION' THEN
   P_ORGANIZATION_REC.PARTY_REC.SALUTATION := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE_CATEGORY' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE_CATEGORY := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE1' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE1 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE2' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE2 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE3' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE3 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE4' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE4 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE5' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE5 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE6' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE6 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE7' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE7 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE8' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE8 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE9' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE9 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE10' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE10 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE11' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE11 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE12' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE12 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE13' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE13 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE14' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE14 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE15' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE15 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE16' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE16 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE17' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE17 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE18' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE18 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE19' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE19 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE20' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE20 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE21' THEN
   P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE21 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE22' THEN
    P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE22 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE23' THEN
    P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE23 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE24' THEN
    P_ORGANIZATION_REC.PARTY_REC.ATTRIBUTE24 := l_tab(i).param_char;
 END IF;
END IF;
END LOOP;
END IF;
END organization_rec_fill;

PROCEDURE party_site_rec_fill
( p_party_site_rec    IN OUT NOCOPY hz_party_site_v2pub.party_site_rec_type,
  l_tab               IN        hz_param_pkg.param_tab_t,
  p_ind               IN        VARCHAR2 )
IS
 l_count NUMBER;
BEGIN
l_count := l_tab.count;
IF l_count > 0 THEN
FOR i in 1 .. l_count LOOP
IF l_tab(i).param_indicator = p_ind THEN
 IF    l_tab(i).param_name = 'P_PARTY_SITE_REC.PARTY_SITE_ID' THEN
   P_PARTY_SITE_REC.PARTY_SITE_ID := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.PARTY_ID' THEN
   P_PARTY_SITE_REC.PARTY_ID := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.LOCATION_ID' THEN
   P_PARTY_SITE_REC.LOCATION_ID := l_tab(i).param_num;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.PARTY_SITE_NUMBER' THEN
   P_PARTY_SITE_REC.PARTY_SITE_NUMBER := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ORIG_SYSTEM_REFERENCE' THEN
   P_PARTY_SITE_REC.ORIG_SYSTEM_REFERENCE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.MAILSTOP' THEN
   P_PARTY_SITE_REC.MAILSTOP := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.IDENTIFYING_ADDRESS_FLAG' THEN
   P_PARTY_SITE_REC.IDENTIFYING_ADDRESS_FLAG := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.STATUS' THEN
   P_PARTY_SITE_REC.STATUS := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.PARTY_SITE_NAME' THEN
   P_PARTY_SITE_REC.PARTY_SITE_NAME := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE_CATEGORY' THEN
   P_PARTY_SITE_REC.ATTRIBUTE_CATEGORY := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE1' THEN
   P_PARTY_SITE_REC.ATTRIBUTE1 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE2' THEN
   P_PARTY_SITE_REC.ATTRIBUTE2 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE3' THEN
   P_PARTY_SITE_REC.ATTRIBUTE3 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE4' THEN
   P_PARTY_SITE_REC.ATTRIBUTE4 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE5' THEN
   P_PARTY_SITE_REC.ATTRIBUTE5 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE6' THEN
   P_PARTY_SITE_REC.ATTRIBUTE6 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE7' THEN
   P_PARTY_SITE_REC.ATTRIBUTE7 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE8' THEN
   P_PARTY_SITE_REC.ATTRIBUTE8 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE9' THEN
   P_PARTY_SITE_REC.ATTRIBUTE9 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE10' THEN
   P_PARTY_SITE_REC.ATTRIBUTE10 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE11' THEN
   P_PARTY_SITE_REC.ATTRIBUTE11 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE12' THEN
   P_PARTY_SITE_REC.ATTRIBUTE12 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE13' THEN
   P_PARTY_SITE_REC.ATTRIBUTE13 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE14' THEN
   P_PARTY_SITE_REC.ATTRIBUTE14 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE15' THEN
   P_PARTY_SITE_REC.ATTRIBUTE15 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE16' THEN
   P_PARTY_SITE_REC.ATTRIBUTE16 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE17' THEN
   P_PARTY_SITE_REC.ATTRIBUTE17 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE18' THEN
   P_PARTY_SITE_REC.ATTRIBUTE18 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE19' THEN
   P_PARTY_SITE_REC.ATTRIBUTE19 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ATTRIBUTE20' THEN
   P_PARTY_SITE_REC.ATTRIBUTE20 := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.LANGUAGE' THEN
   P_PARTY_SITE_REC.LANGUAGE := l_tab(i).param_char;
 ELSIF    l_tab(i).param_name = 'P_PARTY_SITE_REC.ADDRESSEE' THEN
   P_PARTY_SITE_REC.ADDRESSEE := l_tab(i).param_char;
 END IF;
 END IF;
END LOOP;
END IF;
END party_site_rec_fill;

FUNCTION Is_Same_Value( old VARCHAR2, new VARCHAR2 ) Return BOOLEAN IS
BEGIN
   if( old = new ) then
     return TRUE;
   elsif( old is NULL and new is NULL ) then
     return TRUE;
   else
     return FALSE;
   end if;
END Is_Same_Value;


FUNCTION Is_Same_Value( old NUMBER, new NUMBER ) Return BOOLEAN IS
BEGIN
   if( old = new ) then
     return TRUE;
   elsif( old is NULL and new is NULL ) then
     return TRUE;
   else
     return FALSE;
   end if;
END Is_Same_Value;
*************************COMMENTS END ***************************************/

-- Start of Comments
--
--      API name  : CTeam_Org_Update
--      Type      : Private
--      Function  : This procedure is used to create a partner record in PV_TAP_BATCH_CHG_PARTNERS
--                  table, if any of the Organization related partner qualifier change. The Org.
--                  related partner qualifiers are as follows -
--                   *  Organization Name
--                   *  Customer Category Code
--                   *  Number of Employee
--                   *  Annual Revenue
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                 p_organization_rec     IN OUT  HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
--                 p_old_organization_rec IN 	HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
--      OUT
--                 x_return_status        OUT  VARCHAR2,
--                 x_msg_count            OUT NOCOPY NUMBER,
--                 x_msg_data             OUT NOCOPY VARCHAR2
--
--      Version :
--                 Initial version         1.0
--
--      Notes:
--
--
-- End of Comments

/****************** Commented out for bug # 4528865 *****************************
PROCEDURE CTeam_Org_Update (
  p_organization_rec     IN OUT NOCOPY  HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
  p_old_organization_rec IN 	HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2
)
*********************************************************************************/
PROCEDURE CTeam_Org_Update (
  p_party_id		 IN          NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2
) IS

  l_partner_id           NUMBER;
  -- l_chng_partner_exist   VARCHAR2(1) := 'N';
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR(2000);
  l_processed_flag       VARCHAR2(1);
  l_object_version       NUMBER;

  -- l_batch_chg_prtnrs_rec PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type:= PV_BATCH_CHG_PRTNR_PVT.g_miss_Batch_Chg_Prtnrs_rec;
  l_batch_chg_prtnrs_rec PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type;

  -- Cursor l_cust_is_partner_csr.
  CURSOR l_cust_is_partner_csr (cv_partner_party_id NUMBER) IS
    SELECT partner_id
    FROM   pv_partner_profiles
    WHERE  partner_party_id = cv_partner_party_id
    AND	   status = 'A';

  -- Cursor l_chng_partner_exist_csr.
  CURSOR l_chng_partner_exist_csr(cv_partner_id NUMBER) IS
    SELECT processed_flag, object_version_number
    FROM   pv_tap_batch_chg_partners
    WHERE  partner_id = cv_partner_id;

BEGIN

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if the supplied party_id point to a Partner or a Customer.
  -- If it's point to a PARTNER Org, then there should be a record exists in
  -- PV_PARTNER_PROFILES table.

  OPEN l_cust_is_partner_csr(p_party_id );
  FETCH l_cust_is_partner_csr INTO l_partner_id;

  IF l_cust_is_partner_csr%FOUND THEN
     CLOSE l_cust_is_partner_csr;

     -- Check any of the Organization qualifier enabled.
     IF ( (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_partner_name)= 'Y') OR
          (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_cust_catgy_code)= 'Y') OR
          (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_number_of_employee)= 'Y') OR
          (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_Annual_Revenue)= 'Y') ) THEN

        OPEN l_chng_partner_exist_csr(l_partner_id);
        FETCH l_chng_partner_exist_csr INTO l_processed_flag, l_object_version;
        l_batch_chg_prtnrs_rec.partner_id := l_partner_id;
        l_batch_chg_prtnrs_rec.processed_flag := 'P';
        IF l_chng_partner_exist_csr%NOTFOUND THEN

           CLOSE l_chng_partner_exist_csr;

           -- Store this partner_id in PV_TAP_BATCH_CHG_PARTNERS table for later processing
	   -- for channel team assignment.
           PV_BATCH_CHG_PRTNR_PVT.Create_Batch_Chg_Partners(
              p_api_version_number    => 1.0 ,
              p_init_msg_list         => FND_API.G_FALSE,
              p_commit                => FND_API.G_FALSE,
              p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data,
              p_batch_chg_prtnrs_rec  => l_batch_chg_prtnrs_rec,
              x_partner_id            => l_partner_id );

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
           END IF;
        ELSE
           CLOSE l_chng_partner_exist_csr;
           IF (l_processed_flag <> 'P') THEN
               l_batch_chg_prtnrs_rec.object_version_number := l_object_version;
               PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners(
                  p_api_version_number    => 1.0
                  ,p_init_msg_list        => FND_API.G_FALSE
                  ,p_commit               => FND_API.G_FALSE
                  ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
                  ,x_return_status        => l_return_status
                  ,x_msg_count            => l_msg_count
                  ,x_msg_data             => l_msg_data
                  ,p_batch_chg_prtnrs_rec => l_batch_chg_prtnrs_rec);

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                      FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                      FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners');
                      FND_MSG_PUB.Add;
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
               END IF;

           END IF; --l_processed_flag <> 'P'
        END IF;  -- l_chng_partner_exist_csr%NOTFOUND
     END IF; -- Check any of the Organization qualifier enabled.

  ELSE
     CLOSE l_cust_is_partner_csr;
  END IF; -- l_cust_is_partner_csr%FOUND
EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_error;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('Update_Channel_Team (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('Update_Channel_Team (-)');
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('Update_Channel_Team (-)');
      END IF;
END CTeam_Org_Update;

-- Start of Comments
--
--      API name  : CTeam_PartySite_Update
--      Type      : Private
--      Function  : This procedure is used to create a partner record in PV_TAP_BATCH_CHG_PARTNERS
--                  table, if any of the Party Site related partner qualifier change. The Party Site
--                  related partner qualifiers is as follows -
--                   * Identifying_address_flag
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                 p_party_site_rec     IN OUT  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
--                 p_old_party_site_rec IN 	HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
--      OUT
--                 x_return_status        IN OUT  VARCHAR2,
--                 x_msg_count            OUT NOCOPY NUMBER,
--                 x_msg_data             OUT NOCOPY VARCHAR2
--
--      Version :
--                 Initial version         1.0
--
--      Notes:
--
--
-- End of Comments
/****************** Commented out for bug # 4528865 *****************************
PROCEDURE CTeam_PartySite_Update (
  p_party_site_rec       IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  p_old_party_site_rec   IN 	 HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  x_return_status        IN OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2
  )
*********************************************************************************/
  PROCEDURE CTeam_PartySite_Update (
  p_party_site_id        IN      NUMBER,
  x_return_status        IN OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2
  ) IS

  l_partner_id           NUMBER;
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR(2000);
  l_processed_flag       VARCHAR2(1);
  l_object_version       NUMBER;

  -- l_batch_chg_prtnrs_rec PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type:= PV_BATCH_CHG_PRTNR_PVT.g_miss_Batch_Chg_Prtnrs_rec;
  l_batch_chg_prtnrs_rec PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type;

  -- Cursor l_cust_is_partner_csr.
  CURSOR l_cust_is_partner_csr (cv_party_site_id NUMBER) IS
    SELECT partner_id
    FROM   hz_party_sites hzps,
           pv_partner_profiles ppp
    WHERE  hzps.party_site_id = cv_party_site_id
    AND    hzps.status = 'A'
    AND    ppp.partner_party_id = hzps.party_id
    AND	   ppp.status = 'A';

  -- Cursor l_chng_partner_exist_csr.
  CURSOR l_chng_partner_exist_csr(cv_partner_id NUMBER) IS
    SELECT processed_flag, object_version_number
    FROM   pv_tap_batch_chg_partners
    WHERE  partner_id = cv_partner_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT CTeam_PartySite_Update_pub;

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if the supplied party_site_id point to a Partner or a Customer.
  -- If it's point to a PARTNER Org, then there should be a record exists in
  -- PV_PARTNER_PROFILES table.

  OPEN l_cust_is_partner_csr(p_party_site_id );
  FETCH l_cust_is_partner_csr INTO l_partner_id;

  IF l_cust_is_partner_csr%FOUND THEN
     CLOSE l_cust_is_partner_csr;

      OPEN l_chng_partner_exist_csr(l_partner_id);
      FETCH l_chng_partner_exist_csr INTO l_processed_flag, l_object_version;
      l_batch_chg_prtnrs_rec.partner_id := l_partner_id;
      l_batch_chg_prtnrs_rec.processed_flag := 'P';
      IF l_chng_partner_exist_csr%NOTFOUND THEN
         CLOSE l_chng_partner_exist_csr;

         -- Call Channel_Team_Organization_Update to re-assign the Channel team
         PV_BATCH_CHG_PRTNR_PVT.Create_Batch_Chg_Partners(
           p_api_version_number    => 1.0 ,
           p_init_msg_list         => FND_API.G_FALSE,
           p_commit                => FND_API.G_FALSE,
           p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
           x_return_status         => l_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data,
           p_batch_chg_prtnrs_rec  => l_batch_chg_prtnrs_rec,
           x_partner_id            => l_partner_id );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      ELSE
         CLOSE l_chng_partner_exist_csr;
         IF (l_processed_flag <> 'P') THEN
             l_batch_chg_prtnrs_rec.object_version_number := l_object_version;
             PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners(
                p_api_version_number    => 1.0
                ,p_init_msg_list        => FND_API.G_FALSE
                ,p_commit               => FND_API.G_FALSE
                ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
                ,x_return_status        => l_return_status
                ,x_msg_count            => l_msg_count
                ,x_msg_data             => l_msg_data
                ,p_batch_chg_prtnrs_rec => l_batch_chg_prtnrs_rec);

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                    FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                    FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners');
                    FND_MSG_PUB.Add;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
             END IF;

         END IF; --l_processed_flag <> 'P'
      END IF;  -- l_chng_partner_exist_csr%NOTFOUND
  ELSE
     CLOSE l_cust_is_partner_csr;
  END IF; -- l_cust_is_partner_csr%FOUND

EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO CTeam_PartySite_Update_pub;
      x_return_status := FND_API.g_ret_sts_error;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('CTeam_PartySite_Update (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO CTeam_PartySite_Update_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('CTeam_PartySite_Update (-)');
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('CTeam_PartySite_Update (-)');
      END IF;
END CTeam_PartySite_Update;

-- Start of Comments
--
--      API name  : CTeam_Location_Update
--      Type      : Private
--      Function  : This procedure is used to create a partner record in PV_TAP_BATCH_CHG_PARTNERS
--                  table, if any of the Location related partner qualifier change. The location
--                  related partner qualifiers are as follows -
--                   *  City
--                   *  State
--                   *  Postal Code
--                   *  County
--                   *  Province
--                   *  Country
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                 p_location_id         IN NUMBER,
--      OUT
--                 x_return_status        IN OUT  VARCHAR2,
--                 x_msg_count            OUT NOCOPY NUMBER,
--                 x_msg_data             OUT NOCOPY VARCHAR2
--
--      Version :
--                 Initial version         1.0
--
--      Notes:
--
--
-- End of Comments
/****************** Commented out for bug # 4528865 *****************************
PROCEDURE CTeam_Location_Update (
  p_location_rec         IN OUT NOCOPY HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
  p_old_location_rec     IN      HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
  x_return_status        IN OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2
*********************************************************************************/
PROCEDURE CTeam_Location_Update (
  p_location_id          IN  NUMBER,
  x_return_status        IN  OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2
) IS

  l_partner_id           NUMBER;
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR(2000);
  l_processed_flag       VARCHAR2(1);
  l_object_version       NUMBER;

  --l_batch_chg_prtnrs_rec PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type:= PV_BATCH_CHG_PRTNR_PVT.g_miss_Batch_Chg_Prtnrs_rec;
  l_batch_chg_prtnrs_rec PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type;

  -- Cursor l_cust_is_partner_csr.
  CURSOR l_cust_is_partner_csr (cv_location_id NUMBER) IS
     SELECT ppp.partner_id
     FROM   hz_party_sites hps,
            pv_partner_profiles ppp
 -- Fixed the isse by pointing the LOCATION_ID to partner's party.
 --    WHERE  ppp.partner_id = hps.party_id
     WHERE  ppp.partner_party_id = hps.party_id
     AND    ppp.status = 'A'
     AND    hps.location_id = cv_location_id
     AND    hps.identifying_address_flag = 'Y'
     AND    hps.status = 'A';

  -- Cursor l_chng_partner_exist_csr.
  CURSOR l_chng_partner_exist_csr(cv_partner_id NUMBER) IS
    SELECT processed_flag, object_version_number
    FROM   pv_tap_batch_chg_partners
    WHERE  partner_id = cv_partner_id;

BEGIN

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if the supplied party_id point to a Partner or a Customer.
  -- If it's point to a PARTNER Org, then there should be a record exists in
  -- PV_PARTNER_PROFILES table.

  OPEN l_cust_is_partner_csr(p_location_id );
  FETCH l_cust_is_partner_csr INTO l_partner_id;

  IF l_cust_is_partner_csr%FOUND THEN
     CLOSE l_cust_is_partner_csr;

     -- Check any of the Location qualifier enabled.
     IF ( (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_city)= 'Y') OR
          (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_county)= 'Y') OR
	  (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_country)= 'Y') OR
	  (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_state)= 'Y') OR
          (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_postal_code)= 'Y') OR
          (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_province)= 'Y') ) THEN

           OPEN l_chng_partner_exist_csr(l_partner_id);
           FETCH l_chng_partner_exist_csr INTO l_processed_flag, l_object_version;
           l_batch_chg_prtnrs_rec.partner_id := l_partner_id;
           l_batch_chg_prtnrs_rec.processed_flag := 'P';
           IF l_chng_partner_exist_csr%NOTFOUND THEN

              CLOSE l_chng_partner_exist_csr;

              -- Call Channel_Team_Organization_Update to re-assign the Channel team
              PV_BATCH_CHG_PRTNR_PVT.Create_Batch_Chg_Partners(
                 p_api_version_number    => 1.0 ,
                 p_init_msg_list         => FND_API.G_FALSE,
                 p_commit                => FND_API.G_FALSE,
                 p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                 x_return_status         => l_return_status,
                 x_msg_count             => l_msg_count,
                 x_msg_data              => l_msg_data,
                 p_batch_chg_prtnrs_rec  => l_batch_chg_prtnrs_rec,
                 x_partner_id            => l_partner_id );

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
              END IF;
           ELSE
              CLOSE l_chng_partner_exist_csr;
              IF (l_processed_flag <> 'P') THEN
                  l_batch_chg_prtnrs_rec.object_version_number := l_object_version;
                  PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners(
                     p_api_version_number    => 1.0
                     ,p_init_msg_list        => FND_API.G_FALSE
                     ,p_commit               => FND_API.G_FALSE
                     ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
                     ,x_return_status        => l_return_status
                     ,x_msg_count            => l_msg_count
                     ,x_msg_data             => l_msg_data
                     ,p_batch_chg_prtnrs_rec => l_batch_chg_prtnrs_rec);

                  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                         RAISE FND_API.G_EXC_ERROR;
                      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                         FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                         FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners');
                         FND_MSG_PUB.Add;
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                  END IF;

              END IF; --l_processed_flag <> 'P'
           END IF;  -- l_chng_partner_exist_csr%NOTFOUND
     END IF; -- Check any of the Location related partner qualifier enabled.
  ELSE
     CLOSE l_cust_is_partner_csr;
  END IF; -- l_cust_is_partner_csr%FOUND
EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_error;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('CTeam_Location_Update (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('CTeam_Location_Update (-)');
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('CTeam_Location_Update (-)');
      END IF;
END CTeam_Location_Update;

--
--      API name  : CTeam_ContPoint_Update
--      Type      : Private
--      Function  : This procedure is used to create a partner record in PV_TAP_BATCH_CHG_PARTNERS
--                  table, if any of the Contact Point related partner qualifier change. The contact
--                  point related partner qualifiers are as follows -
--                   *  Area code
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                 p_contact_point_id         IN NUMBER,
--      OUT
--                 x_return_status        IN OUT  VARCHAR2,
--                 x_msg_count            OUT NOCOPY NUMBER,
--                 x_msg_data             OUT NOCOPY VARCHAR2
--
--      Version :
--                 Initial version         1.0
--
--      Notes:
--
--
-- End of Comments
/****************** Commented out for bug # 4528865 *****************************
PROCEDURE CTeam_ContPoint_Update (
   p_contact_points_rec     IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE,
   p_old_contact_points_rec IN  HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE,
   p_edi_rec                IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE,
   p_old_edi_rec            IN   HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE,
   p_email_rec              IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE,
   p_old_email_rec          IN   HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE,
   p_phone_rec              IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE,
   p_old_phone_rec          IN  HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE,
   p_telex_rec              IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE,
   p_old_telex_rec          IN  HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE,
   p_web_rec                IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE,
   p_old_web_rec            IN  HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE,
   x_return_status          IN OUT NOCOPY     VARCHAR2,
   x_msg_count              OUT NOCOPY     NUMBER,
   x_msg_data               OUT NOCOPY     VARCHAR2
*********************************************************************************/

   PROCEDURE CTeam_ContPoint_Update (
   p_contact_point_id       IN NUMBER,
   x_return_status          IN OUT NOCOPY     VARCHAR2,
   x_msg_count              OUT NOCOPY     NUMBER,
   x_msg_data               OUT NOCOPY     VARCHAR2
) IS

  l_partner_id           NUMBER;
  -- l_chng_partner_exist   VARCHAR2(1) := 'N';
  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR(2000);
  l_processed_flag       VARCHAR2(1);
  l_object_version       NUMBER;

  -- l_batch_chg_prtnrs_rec PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type:= PV_BATCH_CHG_PRTNR_PVT.g_miss_Batch_Chg_Prtnrs_rec;
  l_batch_chg_prtnrs_rec PV_BATCH_CHG_PRTNR_PVT.Batch_Chg_Prtnrs_Rec_Type;

  -- Cursor l_cust_is_partner_csr.
  CURSOR l_cust_is_partner_csr (cv_contact_point_id NUMBER) IS
        SELECT /*+ index(p) */ partner_id
        FROM    HZ_CONTACT_POINTS CP,
                HZ_PARTIES PARTY,
                pv_partner_profiles p
        WHERE  CP.CONTACT_POINT_ID = cv_contact_Point_id
        AND    CP.owner_table_id = p.partner_party_id
        AND    CP.owner_table_name(+) = 'HZ_PARTIES'
        AND    CP.status(+) = 'A'
        AND    CP.primary_flag(+) = 'Y'
        AND    CP.contact_point_type(+) = 'PHONE'
        AND    CP.owner_table_id(+) = PARTY.party_id
        AND    PARTY.party_type = 'ORGANIZATION'
        AND    PARTY.status = 'A'
        AND    p.status = 'A';


-- Commented for the bug fix # 4141409.
--  SELECT /*+ index(p) */ partner_id
--   FROM   pv_partner_profiles p
--   WHERE  exists ( SELECT 'Y'
--                    FROM   HZ_CONTACT_POINTS CP,
--                           HZ_PARTIES PARTY
--                    WHERE  CP.CONTACT_POINT_ID = cv_contact_Point_id
--                    AND    CP.owner_table_id = p.partner_party_id
--                    AND    CP.owner_table_name(+) = 'HZ_PARTIES'
--                    AND    CP.status(+) = 'A'
--                    AND    CP.primary_flag(+) = 'Y'
--                    AND    CP.contact_point_type(+) = 'PHONE'
--                    AND    CP.owner_table_id(+) = PARTY.party_id
--                    AND    PARTY.party_type = 'ORGANIZATION'
--                    AND    PARTY.status = 'A')
--    AND	   status = 'A';

  -- Cursor l_chng_partner_exist_csr.
  CURSOR l_chng_partner_exist_csr(cv_partner_id NUMBER) IS
    SELECT processed_flag, object_version_number
    FROM   pv_tap_batch_chg_partners
    WHERE  partner_id = cv_partner_id;

BEGIN

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if the supplied party_id point to a Partner or a Customer.
  -- If it's point to a PARTNER Org, then there should be a record exists in
  -- PV_PARTNER_PROFILES table.

  OPEN l_cust_is_partner_csr(p_contact_point_id );
  FETCH l_cust_is_partner_csr INTO l_partner_id;
  IF l_cust_is_partner_csr%FOUND THEN
     CLOSE l_cust_is_partner_csr;

     -- Check any of the Contact Point qualifier enabled.
     IF ( (PV_TERR_ASSIGN_PUB.chk_prtnr_qflr_enabled(PV_TERR_ASSIGN_PUB.g_area_code )= 'Y') ) THEN

	   OPEN l_chng_partner_exist_csr(l_partner_id);
           FETCH l_chng_partner_exist_csr INTO l_processed_flag, l_object_version;
           l_batch_chg_prtnrs_rec.partner_id := l_partner_id;
           l_batch_chg_prtnrs_rec.processed_flag := 'P';
           IF l_chng_partner_exist_csr%NOTFOUND THEN
              CLOSE l_chng_partner_exist_csr;

              -- Call Channel_Team_Organization_Update to re-assign the Channel team
              PV_BATCH_CHG_PRTNR_PVT.Create_Batch_Chg_Partners(
                 p_api_version_number    => 1.0 ,
                 p_init_msg_list         => FND_API.G_FALSE,
                 p_commit                => FND_API.G_FALSE,
                 p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                 x_return_status         => l_return_status,
                 x_msg_count             => l_msg_count,
                 x_msg_data              => l_msg_data,
                 p_batch_chg_prtnrs_rec  => l_batch_chg_prtnrs_rec,
                 x_partner_id            => l_partner_id );

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
              END IF;
           ELSE
              CLOSE l_chng_partner_exist_csr;

	      IF (l_processed_flag <> 'P') THEN
                  l_batch_chg_prtnrs_rec.object_version_number := l_object_version;

		  PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners(
                     p_api_version_number    => 1.0
                     ,p_init_msg_list        => FND_API.G_FALSE
                     ,p_commit               => FND_API.G_FALSE
                     ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
                     ,x_return_status        => l_return_status
                     ,x_msg_count            => l_msg_count
                     ,x_msg_data             => l_msg_data
                     ,p_batch_chg_prtnrs_rec => l_batch_chg_prtnrs_rec);

                  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                         RAISE FND_API.G_EXC_ERROR;
                      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                         FND_MESSAGE.SET_NAME('PV', 'PV_API_FAILED');
                         FND_MESSAGE.SET_TOKEN('API_NAME', 'PV_BATCH_CHG_PRTNR_PVT.Update_Batch_Chg_Partners');
                         FND_MSG_PUB.Add;
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;
                  END IF;

              END IF; --l_processed_flag <> 'P'
           END IF;  -- l_chng_partner_exist_csr%NOTFOUND

     END IF; -- Check any of the Contact Point related partner qualifier enabled.

  ELSE
     CLOSE l_cust_is_partner_csr;
  END IF; -- l_cust_is_partner_csr%FOUND
EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_error;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'ERROR');
         hz_utility_v2pub.debug('CTeam_ContPoint_Update (-)');
      END IF;

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'UNEXPECTED ERROR');
         hz_utility_v2pub.debug('CTeam_ContPoint_Update (-)');
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO Update_Channel_Team_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

            -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
         hz_utility_v2pub.debug_return_messages (
          x_msg_count, x_msg_data, 'SQL ERROR');
         hz_utility_v2pub.debug('CTeam_ContPoint_Update (-)');
      END IF;
END CTeam_ContPoint_Update;

-- Start of Comments
--
--      API name  : organization_update_post
--      Type      : Public
--      Function  : This function is used as a subscription for Organization
--                  update business event attached to following event -
--                      - oracle.apps.ar.hz.Organization.update
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                p_subscription_guid      IN raw
--                p_event                  IN out NOCOPY wf_event_t
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:   Subscription attach to 'oracle.apps.ar.hz.Organization.update'
--               event.
--
--
-- End of Comments
 FUNCTION organization_update_post
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 RETURN VARCHAR2
 IS
   -- Declaration of local variables
   l_party_id		    NUMBER;
   l_count	            NUMBER;
   x_return_status          VARCHAR2(10) ;
   x_msg_count              NUMBER;
   x_msg_data               VARCHAR2(2000);
   exc                      EXCEPTION;

begin


   -- Get the value for the party_id
   l_party_id := p_event.GetValueForParameter('PARTY_ID');

   -- Set the value of the x_return_status
   x_return_status := 'S';

/****************** Commented out for bug # 4528865 ********
  CTeam_Org_Update(
      p_organization_rec      => p_organization_rec,
      p_old_organization_rec  => p_old_organization_rec,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data );
 ***********************************************************/

  IF ( l_party_id is not NULL ) THEN
       CTeam_Org_Update(
	 p_party_id              => l_party_id,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data );

       IF x_return_status <> 'S' THEN
          RAISE EXC;
       END IF;
  END IF;
  -- FND_MSG_PUB.initialize;
  RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
     WF_CORE.CONTEXT('PV_TAP_BES_PKG', 'Organization_Update_Post', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('PV_TAP_BES_PKG', 'Organization_Update_Post', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
END Organization_Update_Post;


-- Start of Comments
--
--      API name  : partysite_update_post
--      Type      : Public
--      Function  : This function is used as a subscription for Party Site
--                  update business event attached to following event -
--                      - oracle.apps.ar.hz.PartySite.update
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                p_subscription_guid      IN raw
--                p_event                  IN out NOCOPY wf_event_t
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:   Subscription attach to 'oracle.apps.ar.hz.PartySite.update'
--               event.
--
--
-- End of Comments
 FUNCTION partysite_update_post
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 RETURN VARCHAR2
 IS

   -- Declaration of local variables
   l_party_site_id          NUMBER;
   x_return_status          VARCHAR2(10);
   x_msg_count              NUMBER;
   x_msg_data               VARCHAR2(2000);
   exc                      EXCEPTION;

begin

   -- Get the value for the party_site_id
   l_party_site_id := p_event.GetValueForParameter('PARTY_SITE_ID');

   -- Set the value of the x_return_status
   x_return_status := 'S';

/****************** Commented out for bug # 4528865 ********
  CTeam_PartySite_Update (
      p_party_site_rec      => p_party_site_rec,
      p_old_party_site_rec  => p_old_party_site_rec,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data );
 ***********************************************************/
  IF ( l_party_site_id is NOT NULL ) THEN

       CTeam_PartySite_Update (
          p_party_site_id         => l_party_site_id,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data );

      IF x_return_status <> 'S' THEN
         RAISE EXC;
      END IF;
  END IF;
  -- FND_MSG_PUB.initialize;
  RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
     WF_CORE.CONTEXT('PV_TAP_BES_PKG', 'partysite_Update_Post', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('PV_TAP_BES_PKG', 'partysite_Update_Post', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
END partysite_Update_Post;

-- Start of Comments
--
--      API name  : location_update_post
--      Type      : Public
--      Function  : This function is used as a subscription for location
--                  update business event attached to following event -
--                      - oracle.apps.ar.hz.Location.update
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                p_subscription_guid      IN raw
--                p_event                  IN out NOCOPY wf_event_t
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:   Subscription attach to 'oracle.apps.ar.hz.Location.update'
--               event.
--
--
-- End of Comments
 FUNCTION location_update_post
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 RETURN VARCHAR2
 IS


   l_location_id            NUMBER;
   l_count	            NUMBER;
   x_return_status          VARCHAR2(10) ;
   x_msg_count              NUMBER;
   x_msg_data               VARCHAR2(2000);
   exc                      EXCEPTION;

begin

   -- Get the value for the location_id
   l_location_id := p_event.GetValueForParameter('LOCATION_ID');

   -- Set the value of the x_return_status
   x_return_status := 'S';

/****************** Commented out for bug # 4528865 ********
   CTeam_Location_Update (
      p_location_rec        => p_location_rec,
      p_old_location_rec    => p_old_location_rec,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data );
 ***********************************************************/
   CTeam_Location_Update (
      p_location_id         => l_location_id,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data );


  IF x_return_status <> 'S' THEN
     RAISE EXC;
  END IF;
  -- FND_MSG_PUB.initialize;
  RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
     WF_CORE.CONTEXT('PV_TAP_BES_PKG', 'location_Update_Post', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('PV_TAP_BES_PKG', 'location_Update_Post', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
END location_Update_Post;

--
--      API name  : contactpoint_update_post
--      Type      : Public
--      Function  : This function is used as a subscription for Contact point
--                  update business event attached to following event -
--                      - oracle.apps.ar.hz.ContactPoint.update
--
--      Pre-reqs  :
--
--      Paramaeters     :
--      IN              :
--                p_subscription_guid      IN raw
--                p_event                  IN out NOCOPY wf_event_t
--      OUT             :
--
--      Version :
--                      Initial version         1.0
--
--      Notes:   Subscription attach to 'oracle.apps.ar.hz.ContactPoint.update'
--               event.
--
--
-- End of Comments
 FUNCTION contactpoint_update_post
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 RETURN VARCHAR2
 IS

   l_contact_point_id	    NUMBER;
   l_count	            NUMBER;
   x_return_status          VARCHAR2(10) ;
   x_msg_count              NUMBER;
   x_msg_data               VARCHAR2(2000);
   exc                      EXCEPTION;

begin

   -- Get the value for the contact_point_id
   l_contact_point_id := p_event.GetValueForParameter('CONTACT_POINT_ID');

   -- Set the value of the x_return_status
   x_return_status := 'S';

  CTeam_ContPoint_Update (
     p_contact_point_id       => l_contact_point_id,
     x_return_status          => x_return_status,
     x_msg_count              => x_msg_count,
     x_msg_data               => x_msg_data  );

  IF x_return_status <> 'S' THEN
     RAISE EXC;
  END IF;
  -- FND_MSG_PUB.initialize;
  RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
     WF_CORE.CONTEXT('PV_TAP_BES_PKG', 'contactpoint_Update_Post', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('PV_TAP_BES_PKG', 'contactpoint_Update_Post', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
END contactpoint_Update_Post;

END PV_TAP_BES_PKG;

/
