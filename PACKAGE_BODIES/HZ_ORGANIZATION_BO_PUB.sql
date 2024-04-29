--------------------------------------------------------
--  DDL for Package Body HZ_ORGANIZATION_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORGANIZATION_BO_PUB" AS
/*$Header: ARHBPOBB.pls 120.21.12010000.8 2009/10/28 18:04:00 awu ship $ */

  -- PRIVATE PROCEDURE assign_organization_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from organization business object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_organization_obj   Organization object.
  --     p_organization_id    Organization Id.
  --     p_organization_os    Organization original system.
  --     p_organization_osr   Organization original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_organization_rec  Organization plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE assign_organization_rec(
    p_organization_obj                 IN            HZ_ORGANIZATION_BO,
    p_organization_id                  IN            NUMBER,
    p_organization_os                  IN            VARCHAR2,
    p_organization_osr                 IN            VARCHAR2,
    p_create_or_update                 IN            VARCHAR2 := 'C',
    px_organization_rec                IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_credit_rating_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from credit rating object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_credit_rating_obj  Credit rating object.
  --     p_party_id           Party Id.
  --   IN/OUT:
  --     px_credit_rating_rec Credit rating plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE assign_credit_rating_rec(
    p_credit_rating_obj                IN            HZ_CREDIT_RATING_OBJ,
    p_party_id                         IN            NUMBER,
    px_credit_rating_rec               IN OUT NOCOPY HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_financial_report_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from financial report object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_fin_report_obj     Financial report object.
  --     p_party_id           Party Id.
  --   IN/OUT:
  --     px_fin_report_rec    Financial report plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE assign_financial_report_rec(
    p_fin_report_obj                   IN            HZ_FINANCIAL_BO,
    p_party_id                         IN            NUMBER,
    px_fin_report_rec                  IN OUT NOCOPY HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_financial_number_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from financial number object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_fin_number_obj     Financial number object.
  --     p_fin_report_id      Financial report Id.
  --   IN/OUT:
  --     px_fin_number_rec    Financial number plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE assign_financial_number_rec(
    p_fin_number_obj                   IN            HZ_FINANCIAL_NUMBER_OBJ,
    p_fin_report_id                    IN            NUMBER,
    px_fin_number_rec                  IN OUT NOCOPY HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE
  );

  -- PRIVATE PROCEDURE create_credit_ratings
  --
  -- DESCRIPTION
  --     Create credit ratings.
  PROCEDURE create_credit_ratings(
    p_credit_rating_objs               IN OUT NOCOPY HZ_CREDIT_RATING_OBJ_TBL,
    p_organization_id                  IN         NUMBER,
    x_return_status                    OUT NOCOPY VARCHAR2,
    x_msg_count                        OUT NOCOPY NUMBER,
    x_msg_data                         OUT NOCOPY VARCHAR2
  );

  -- PRIVATE PROCEDURE save_credit_ratings
  --
  -- DESCRIPTION
  --     Create or update credit ratings.
  PROCEDURE save_credit_ratings(
    p_credit_rating_objs               IN OUT NOCOPY HZ_CREDIT_RATING_OBJ_TBL,
    p_organization_id                  IN         NUMBER,
    x_return_status                    OUT NOCOPY VARCHAR2,
    x_msg_count                        OUT NOCOPY NUMBER,
    x_msg_data                         OUT NOCOPY VARCHAR2
  );

  -- PRIVATE PROCEDURE create_financial_reports
  --
  -- DESCRIPTION
  --     Create financial reports.
  PROCEDURE create_financial_reports(
    p_fin_objs                         IN OUT NOCOPY HZ_FINANCIAL_BO_TBL,
    p_organization_id                  IN         NUMBER,
    x_return_status                    OUT NOCOPY VARCHAR2,
    x_msg_count                        OUT NOCOPY NUMBER,
    x_msg_data                         OUT NOCOPY VARCHAR2
  );

  -- PRIVATE PROCEDURE save_financial_reports
  --
  -- DESCRIPTION
  --     Create or update financial reports.
  PROCEDURE save_financial_reports(
    p_fin_objs                         IN OUT NOCOPY HZ_FINANCIAL_BO_TBL,
    p_organization_id                  IN         NUMBER,
    x_return_status                    OUT NOCOPY VARCHAR2,
    x_msg_count                        OUT NOCOPY NUMBER,
    x_msg_data                         OUT NOCOPY VARCHAR2
  );

  -- PRIVATE PROCEDURE assign_organization_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from organization business object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_organization_obj   Organization object.
  --     p_organization_id    Organization Id.
  --     p_organization_os    Organization original system.
  --     p_organization_osr   Organization original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_organization_rec  Organization plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE assign_organization_rec(
    p_organization_obj                 IN            HZ_ORGANIZATION_BO,
    p_organization_id                  IN            NUMBER,
    p_organization_os                  IN            VARCHAR2,
    p_organization_osr                 IN            VARCHAR2,
    p_create_or_update                 IN            VARCHAR2 := 'C',
    px_organization_rec                IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
  ) IS
  BEGIN
    px_organization_rec.organization_name:=  p_organization_obj.organization_name;
    px_organization_rec.duns_number_c:=  p_organization_obj.duns_number_c;
    px_organization_rec.enquiry_duns:=  p_organization_obj.enquiry_duns;
    px_organization_rec.ceo_name:=  p_organization_obj.ceo_name;
    px_organization_rec.ceo_title:=  p_organization_obj.ceo_title;
    px_organization_rec.principal_name:=  p_organization_obj.principal_name;
    px_organization_rec.principal_title:=  p_organization_obj.principal_title;
    px_organization_rec.legal_status:=  p_organization_obj.legal_status;
    px_organization_rec.control_yr:=  p_organization_obj.control_yr;
    px_organization_rec.employees_total:=  p_organization_obj.employees_total;
    px_organization_rec.hq_branch_ind:=  p_organization_obj.hq_branch_ind;
    IF(p_organization_obj.branch_flag in ('Y','N')) THEN
      px_organization_rec.branch_flag:=  p_organization_obj.branch_flag;
    END IF;
    IF(p_organization_obj.oob_ind in ('Y','N')) THEN
      px_organization_rec.oob_ind:=  p_organization_obj.oob_ind;
    END IF;
    px_organization_rec.line_of_business:=  p_organization_obj.line_of_business;
    px_organization_rec.cong_dist_code:=  p_organization_obj.cong_dist_code;
    px_organization_rec.sic_code:=  p_organization_obj.sic_code;
    IF(p_organization_obj.import_ind in ('Y','N')) THEN
      px_organization_rec.import_ind:=  p_organization_obj.import_ind;
    END IF;
    IF(p_organization_obj.export_ind in ('Y','N')) THEN
      px_organization_rec.export_ind:=  p_organization_obj.export_ind;
    END IF;
    IF(p_organization_obj.labor_surplus_ind in ('Y','N')) THEN
      px_organization_rec.labor_surplus_ind:=  p_organization_obj.labor_surplus_ind;
    END IF;
    IF(p_organization_obj.debarment_ind in ('Y','N')) THEN
      px_organization_rec.debarment_ind:=  p_organization_obj.debarment_ind;
    END IF;
    IF(p_organization_obj.minority_owned_ind in ('Y','N')) THEN
      px_organization_rec.minority_owned_ind:=  p_organization_obj.minority_owned_ind;
    END IF;
    px_organization_rec.minority_owned_type:=  p_organization_obj.minority_owned_type;
    IF(p_organization_obj.woman_owned_ind in ('Y','N')) THEN
      px_organization_rec.woman_owned_ind:=  p_organization_obj.woman_owned_ind;
    END IF;
    IF(p_organization_obj.disadv_8a_ind in ('Y','N')) THEN
      px_organization_rec.disadv_8a_ind:=  p_organization_obj.disadv_8a_ind;
    END IF;
    IF(p_organization_obj.small_bus_ind in ('Y','N')) THEN
      px_organization_rec.small_bus_ind:=  p_organization_obj.small_bus_ind;
    END IF;
    px_organization_rec.rent_own_ind:=  p_organization_obj.rent_own_ind;
    px_organization_rec.debarments_count:=  p_organization_obj.debarments_count;
    px_organization_rec.debarments_date:=  p_organization_obj.debarments_date;
    px_organization_rec.failure_score:=  p_organization_obj.failure_score;
    px_organization_rec.failure_score_natnl_percentile:=  p_organization_obj.failure_score_natnl_per;
    px_organization_rec.failure_score_override_code:=  p_organization_obj.failure_score_override_code;
    px_organization_rec.failure_score_commentary:=  p_organization_obj.failure_score_commentary;
    px_organization_rec.global_failure_score:=  p_organization_obj.global_failure_score;
    px_organization_rec.db_rating:=  p_organization_obj.db_rating;
    px_organization_rec.credit_score:=  p_organization_obj.credit_score;
    px_organization_rec.credit_score_commentary:=  p_organization_obj.credit_score_commentary;
    px_organization_rec.paydex_score:=  p_organization_obj.paydex_score;
    px_organization_rec.paydex_three_months_ago:=  p_organization_obj.paydex_three_months_ago;
    px_organization_rec.paydex_norm:=  p_organization_obj.paydex_norm;
    px_organization_rec.best_time_contact_begin:=  p_organization_obj.best_time_contact_begin;
    px_organization_rec.best_time_contact_end:=  p_organization_obj.best_time_contact_end;
    px_organization_rec.organization_name_phonetic:=  p_organization_obj.organization_name_phonetic;
    px_organization_rec.tax_reference:=  p_organization_obj.tax_reference;
    IF(p_organization_obj.gsa_indicator_flag in ('Y','N')) THEN
      px_organization_rec.gsa_indicator_flag:=  p_organization_obj.gsa_indicator_flag;
    END IF;
    px_organization_rec.jgzz_fiscal_code:=  p_organization_obj.jgzz_fiscal_code;
    px_organization_rec.analysis_fy:=  p_organization_obj.analysis_fy;
    px_organization_rec.fiscal_yearend_month:=  p_organization_obj.fiscal_yearend_month;
    px_organization_rec.curr_fy_potential_revenue:=  p_organization_obj.curr_fy_potential_revenue;
    px_organization_rec.next_fy_potential_revenue:=  p_organization_obj.next_fy_potential_revenue;
    px_organization_rec.year_established:=  p_organization_obj.year_established;
    px_organization_rec.mission_statement:=  p_organization_obj.mission_statement;
    px_organization_rec.organization_type:=  p_organization_obj.organization_type;
    px_organization_rec.business_scope:=  p_organization_obj.business_scope;
    px_organization_rec.corporation_class:=  p_organization_obj.corporation_class;
    px_organization_rec.known_as:=  p_organization_obj.known_as;
    px_organization_rec.known_as2:=  p_organization_obj.known_as2;
    px_organization_rec.known_as3:=  p_organization_obj.known_as3;
    px_organization_rec.known_as4:=  p_organization_obj.known_as4;
    px_organization_rec.known_as5:=  p_organization_obj.known_as5;
    px_organization_rec.local_bus_iden_type:=  p_organization_obj.local_bus_iden_type;
    px_organization_rec.local_bus_identifier:=  p_organization_obj.local_bus_identifier;
    px_organization_rec.pref_functional_currency:=  p_organization_obj.pref_functional_currency;
    px_organization_rec.registration_type:=  p_organization_obj.registration_type;
    px_organization_rec.total_employees_text:=  p_organization_obj.total_employees_text;
    px_organization_rec.total_employees_ind:=  p_organization_obj.total_employees_ind;
    px_organization_rec.total_emp_est_ind:=  p_organization_obj.total_emp_est_ind;
    px_organization_rec.total_emp_min_ind:=  p_organization_obj.total_emp_min_ind;
    IF(p_organization_obj.parent_sub_ind in ('Y','N')) THEN
      px_organization_rec.parent_sub_ind:=  p_organization_obj.parent_sub_ind;
    END IF;
    px_organization_rec.incorp_year:=  p_organization_obj.incorp_year;
    px_organization_rec.sic_code_type:=  p_organization_obj.sic_code_type;
    IF(p_organization_obj.public_private_owner_flag in ('Y','N')) THEN
      px_organization_rec.public_private_ownership_flag:=  p_organization_obj.public_private_owner_flag;
    END IF;
    IF(p_organization_obj.internal_flag in ('Y','N')) THEN
      px_organization_rec.internal_flag:=  p_organization_obj.internal_flag;
    END IF;
    px_organization_rec.local_activity_code_type:=  p_organization_obj.local_activity_code_type;
    px_organization_rec.local_activity_code:=  p_organization_obj.local_activity_code;
    px_organization_rec.emp_at_primary_adr:=  p_organization_obj.emp_at_primary_adr;
    px_organization_rec.emp_at_primary_adr_text:=  p_organization_obj.emp_at_primary_adr_text;
    px_organization_rec.emp_at_primary_adr_est_ind:=  p_organization_obj.emp_at_primary_adr_est_ind;
    px_organization_rec.emp_at_primary_adr_min_ind:=  p_organization_obj.emp_at_primary_adr_min_ind;
    px_organization_rec.high_credit:=  p_organization_obj.high_credit;
    px_organization_rec.avg_high_credit:=  p_organization_obj.avg_high_credit;
    px_organization_rec.total_payments:=  p_organization_obj.total_payments;
    px_organization_rec.credit_score_class:=  p_organization_obj.credit_score_class;
    px_organization_rec.credit_score_natl_percentile:=  p_organization_obj.credit_score_natl_percentile;
    px_organization_rec.credit_score_incd_default:=  p_organization_obj.credit_score_incd_default;
    px_organization_rec.credit_score_age:=  p_organization_obj.credit_score_age;
    px_organization_rec.credit_score_date:=  p_organization_obj.credit_score_date;
    px_organization_rec.credit_score_commentary2:=  p_organization_obj.credit_score_commentary2;
    px_organization_rec.credit_score_commentary3:=  p_organization_obj.credit_score_commentary3;
    px_organization_rec.credit_score_commentary4:=  p_organization_obj.credit_score_commentary4;
    px_organization_rec.credit_score_commentary5:=  p_organization_obj.credit_score_commentary5;
    px_organization_rec.credit_score_commentary6:=  p_organization_obj.credit_score_commentary6;
    px_organization_rec.credit_score_commentary7:=  p_organization_obj.credit_score_commentary7;
    px_organization_rec.credit_score_commentary8:=  p_organization_obj.credit_score_commentary8;
    px_organization_rec.credit_score_commentary9:=  p_organization_obj.credit_score_commentary9;
    px_organization_rec.credit_score_commentary10:=  p_organization_obj.credit_score_commentary10;
    px_organization_rec.failure_score_class:=  p_organization_obj.failure_score_class;
    px_organization_rec.failure_score_incd_default:=  p_organization_obj.failure_score_incd_default;
    px_organization_rec.failure_score_age:=  p_organization_obj.failure_score_age;
    px_organization_rec.failure_score_date:=  p_organization_obj.failure_score_date;
    px_organization_rec.failure_score_commentary2:=  p_organization_obj.failure_score_commentary2;
    px_organization_rec.failure_score_commentary3:=  p_organization_obj.failure_score_commentary3;
    px_organization_rec.failure_score_commentary4:=  p_organization_obj.failure_score_commentary4;
    px_organization_rec.failure_score_commentary5:=  p_organization_obj.failure_score_commentary5;
    px_organization_rec.failure_score_commentary6:=  p_organization_obj.failure_score_commentary6;
    px_organization_rec.failure_score_commentary7:=  p_organization_obj.failure_score_commentary7;
    px_organization_rec.failure_score_commentary8:=  p_organization_obj.failure_score_commentary8;
    px_organization_rec.failure_score_commentary9:=  p_organization_obj.failure_score_commentary9;
    px_organization_rec.failure_score_commentary10:=  p_organization_obj.failure_score_commentary10;
    px_organization_rec.maximum_credit_recommendation:=  p_organization_obj.maximum_credit_recommend;
    px_organization_rec.maximum_credit_currency_code:=  p_organization_obj.maximum_credit_currency_code;
    px_organization_rec.displayed_duns_party_id:=  p_organization_obj.displayed_duns_party_id;
    IF(p_create_or_update = 'C') THEN
      px_organization_rec.party_rec.orig_system:= p_organization_os;
      px_organization_rec.party_rec.orig_system_reference:= p_organization_osr;
      px_organization_rec.created_by_module:=  HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_organization_rec.do_not_confuse_with:=  p_organization_obj.do_not_confuse_with;
    px_organization_rec.actual_content_source:=  p_organization_obj.actual_content_source;
    px_organization_rec.party_rec.party_id:= p_organization_id;
    px_organization_rec.party_rec.party_number:= p_organization_obj.party_number;
    px_organization_rec.party_rec.validated_flag:= p_organization_obj.validated_flag;
    px_organization_rec.party_rec.status:= p_organization_obj.status;
    px_organization_rec.party_rec.category_code:= p_organization_obj.category_code;
    px_organization_rec.party_rec.salutation:= p_organization_obj.salutation;
    px_organization_rec.party_rec.attribute_category:= p_organization_obj.attribute_category;
    px_organization_rec.party_rec.attribute1:= p_organization_obj.attribute1;
    px_organization_rec.party_rec.attribute2:= p_organization_obj.attribute2;
    px_organization_rec.party_rec.attribute3:= p_organization_obj.attribute3;
    px_organization_rec.party_rec.attribute4:= p_organization_obj.attribute4;
    px_organization_rec.party_rec.attribute5:= p_organization_obj.attribute5;
    px_organization_rec.party_rec.attribute6:= p_organization_obj.attribute6;
    px_organization_rec.party_rec.attribute7:= p_organization_obj.attribute7;
    px_organization_rec.party_rec.attribute8:= p_organization_obj.attribute8;
    px_organization_rec.party_rec.attribute9:= p_organization_obj.attribute9;
    px_organization_rec.party_rec.attribute10:= p_organization_obj.attribute10;
    px_organization_rec.party_rec.attribute11:= p_organization_obj.attribute11;
    px_organization_rec.party_rec.attribute12:= p_organization_obj.attribute12;
    px_organization_rec.party_rec.attribute13:= p_organization_obj.attribute13;
    px_organization_rec.party_rec.attribute14:= p_organization_obj.attribute14;
    px_organization_rec.party_rec.attribute15:= p_organization_obj.attribute15;
    px_organization_rec.party_rec.attribute16:= p_organization_obj.attribute16;
    px_organization_rec.party_rec.attribute17:= p_organization_obj.attribute17;
    px_organization_rec.party_rec.attribute18:= p_organization_obj.attribute18;
    px_organization_rec.party_rec.attribute19:= p_organization_obj.attribute19;
    px_organization_rec.party_rec.attribute20:= p_organization_obj.attribute20;
    px_organization_rec.party_rec.attribute21:= p_organization_obj.attribute21;
    px_organization_rec.party_rec.attribute22:= p_organization_obj.attribute22;
    px_organization_rec.party_rec.attribute23:= p_organization_obj.attribute23;
    px_organization_rec.party_rec.attribute24:= p_organization_obj.attribute24;
  END assign_organization_rec;

  -- PRIVATE PROCEDURE assign_credit_rating_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from credit rating object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_credit_rating_obj  Credit rating object.
  --     p_party_id           Party Id.
  --   IN/OUT:
  --     px_credit_rating_rec Credit rating plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE assign_credit_rating_rec(
    p_credit_rating_obj                IN            HZ_CREDIT_RATING_OBJ,
    p_party_id                         IN            NUMBER,
    px_credit_rating_rec               IN OUT NOCOPY HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE
  ) IS
  BEGIN
    px_credit_rating_rec.credit_rating_id:=  p_credit_rating_obj.credit_rating_id;
    px_credit_rating_rec.description:=  p_credit_rating_obj.description;
    px_credit_rating_rec.party_id:=  p_party_id;
    px_credit_rating_rec.rating:=  p_credit_rating_obj.rating;
    px_credit_rating_rec.rated_as_of_date:=  p_credit_rating_obj.rated_as_of_date;
    px_credit_rating_rec.rating_organization:=  p_credit_rating_obj.rating_organization;
    px_credit_rating_rec.comments:=  p_credit_rating_obj.comments;
    px_credit_rating_rec.det_history_ind:=  p_credit_rating_obj.det_history_ind;
    IF(p_credit_rating_obj.fincl_embt_ind in ('Y','N')) THEN
      px_credit_rating_rec.fincl_embt_ind:=  p_credit_rating_obj.fincl_embt_ind;
    END IF;
    px_credit_rating_rec.criminal_proceeding_ind:=  p_credit_rating_obj.criminal_proceeding_ind;
    px_credit_rating_rec.claims_ind:=  p_credit_rating_obj.claims_ind;
    px_credit_rating_rec.secured_flng_ind:=  p_credit_rating_obj.secured_flng_ind;
    px_credit_rating_rec.fincl_lgl_event_ind:=  p_credit_rating_obj.fincl_lgl_event_ind;
    px_credit_rating_rec.disaster_ind:=  p_credit_rating_obj.disaster_ind;
    px_credit_rating_rec.oprg_spec_evnt_ind:=  p_credit_rating_obj.oprg_spec_evnt_ind;
    px_credit_rating_rec.other_spec_evnt_ind:=  p_credit_rating_obj.other_spec_evnt_ind;
    IF(p_credit_rating_obj.status in ('A','I')) THEN
      px_credit_rating_rec.status:=  p_credit_rating_obj.status;
    END IF;
    px_credit_rating_rec.avg_high_credit:=  p_credit_rating_obj.avg_high_credit;
    px_credit_rating_rec.credit_score:=  p_credit_rating_obj.credit_score;
    px_credit_rating_rec.credit_score_age:=  p_credit_rating_obj.credit_score_age;
    px_credit_rating_rec.credit_score_class:=  p_credit_rating_obj.credit_score_class;
    px_credit_rating_rec.credit_score_commentary:=  p_credit_rating_obj.credit_score_commentary;
    px_credit_rating_rec.credit_score_commentary2:=  p_credit_rating_obj.credit_score_commentary2;
    px_credit_rating_rec.credit_score_commentary3:=  p_credit_rating_obj.credit_score_commentary3;
    px_credit_rating_rec.credit_score_commentary4:=  p_credit_rating_obj.credit_score_commentary4;
    px_credit_rating_rec.credit_score_commentary5:=  p_credit_rating_obj.credit_score_commentary5;
    px_credit_rating_rec.credit_score_commentary6:=  p_credit_rating_obj.credit_score_commentary6;
    px_credit_rating_rec.credit_score_commentary7:=  p_credit_rating_obj.credit_score_commentary7;
    px_credit_rating_rec.credit_score_commentary8:=  p_credit_rating_obj.credit_score_commentary8;
    px_credit_rating_rec.credit_score_commentary9:=  p_credit_rating_obj.credit_score_commentary9;
    px_credit_rating_rec.credit_score_commentary10:=  p_credit_rating_obj.credit_score_commentary10;
    px_credit_rating_rec.credit_score_date:=  p_credit_rating_obj.credit_score_date;
    px_credit_rating_rec.credit_score_incd_default:=  p_credit_rating_obj.credit_score_incd_default;
    px_credit_rating_rec.credit_score_natl_percentile:=  p_credit_rating_obj.credit_score_natl_percentile;
    px_credit_rating_rec.failure_score:=  p_credit_rating_obj.failure_score;
    px_credit_rating_rec.failure_score_age:=  p_credit_rating_obj.failure_score_age;
    px_credit_rating_rec.failure_score_class:=  p_credit_rating_obj.failure_score_class;
    px_credit_rating_rec.failure_score_commentary:=  p_credit_rating_obj.failure_score_commentary;
    px_credit_rating_rec.failure_score_commentary2:=  p_credit_rating_obj.failure_score_commentary2;
    px_credit_rating_rec.failure_score_commentary3:=  p_credit_rating_obj.failure_score_commentary3;
    px_credit_rating_rec.failure_score_commentary4:=  p_credit_rating_obj.failure_score_commentary4;
    px_credit_rating_rec.failure_score_commentary5:=  p_credit_rating_obj.failure_score_commentary5;
    px_credit_rating_rec.failure_score_commentary6:=  p_credit_rating_obj.failure_score_commentary6;
    px_credit_rating_rec.failure_score_commentary7:=  p_credit_rating_obj.failure_score_commentary7;
    px_credit_rating_rec.failure_score_commentary8:=  p_credit_rating_obj.failure_score_commentary8;
    px_credit_rating_rec.failure_score_commentary9:=  p_credit_rating_obj.failure_score_commentary9;
    px_credit_rating_rec.failure_score_commentary10:=  p_credit_rating_obj.failure_score_commentary10;
    px_credit_rating_rec.failure_score_date:=  p_credit_rating_obj.failure_score_date;
    px_credit_rating_rec.failure_score_incd_default:=  p_credit_rating_obj.failure_score_incd_default;
    px_credit_rating_rec.failure_score_natnl_percentile:=  p_credit_rating_obj.failure_score_natnl_per;
    px_credit_rating_rec.failure_score_override_code:=  p_credit_rating_obj.failure_score_override_code;
    px_credit_rating_rec.global_failure_score:=  p_credit_rating_obj.global_failure_score;
    IF(p_credit_rating_obj.debarment_ind in ('Y','N')) THEN
      px_credit_rating_rec.debarment_ind:=  p_credit_rating_obj.debarment_ind;
    END IF;
    px_credit_rating_rec.debarments_count:=  p_credit_rating_obj.debarments_count;
    px_credit_rating_rec.debarments_date:=  p_credit_rating_obj.debarments_date;
    px_credit_rating_rec.high_credit:=  p_credit_rating_obj.high_credit;
    px_credit_rating_rec.maximum_credit_currency_code:=  p_credit_rating_obj.maximum_credit_currency_code;
    px_credit_rating_rec.maximum_credit_rcmd:=  p_credit_rating_obj.maximum_credit_rcmd;
    px_credit_rating_rec.paydex_norm:=  p_credit_rating_obj.paydex_norm;
    px_credit_rating_rec.paydex_score:=  p_credit_rating_obj.paydex_score;
    px_credit_rating_rec.paydex_three_months_ago:=  p_credit_rating_obj.paydex_three_months_ago;
    px_credit_rating_rec.credit_score_override_code:=  p_credit_rating_obj.credit_score_override_code;
    px_credit_rating_rec.cr_scr_clas_expl:=  p_credit_rating_obj.cr_scr_clas_expl;
    px_credit_rating_rec.low_rng_delq_scr:=  p_credit_rating_obj.low_rng_delq_scr;
    px_credit_rating_rec.high_rng_delq_scr:=  p_credit_rating_obj.high_rng_delq_scr;
    px_credit_rating_rec.delq_pmt_rng_prcnt:=  p_credit_rating_obj.delq_pmt_rng_prcnt;
    px_credit_rating_rec.delq_pmt_pctg_for_all_firms:=  p_credit_rating_obj.delq_pmt_pctg_for_all_firms;
    px_credit_rating_rec.num_trade_experiences:=  p_credit_rating_obj.num_trade_experiences;
    px_credit_rating_rec.paydex_firm_days:=  p_credit_rating_obj.paydex_firm_days;
    px_credit_rating_rec.paydex_firm_comment:=  p_credit_rating_obj.paydex_firm_comment;
    px_credit_rating_rec.paydex_industry_days:=  p_credit_rating_obj.paydex_industry_days;
    px_credit_rating_rec.paydex_industry_comment:=  p_credit_rating_obj.paydex_industry_comment;
    px_credit_rating_rec.paydex_comment:=  p_credit_rating_obj.paydex_comment;
    IF(p_credit_rating_obj.suit_ind in ('Y','N')) THEN
      px_credit_rating_rec.suit_ind:=  p_credit_rating_obj.suit_ind;
    END IF;
    IF(p_credit_rating_obj.lien_ind in ('Y','N')) THEN
      px_credit_rating_rec.lien_ind:=  p_credit_rating_obj.lien_ind;
    END IF;
    IF(p_credit_rating_obj.judgement_ind in ('Y','N')) THEN
      px_credit_rating_rec.judgement_ind:=  p_credit_rating_obj.judgement_ind;
    END IF;
    px_credit_rating_rec.bankruptcy_ind:=  p_credit_rating_obj.bankruptcy_ind;
    IF(p_credit_rating_obj.no_trade_ind in ('Y','N')) THEN
      px_credit_rating_rec.no_trade_ind:=  p_credit_rating_obj.no_trade_ind;
    END IF;
    px_credit_rating_rec.prnt_hq_bkcy_ind:=  p_credit_rating_obj.prnt_hq_bkcy_ind;
    px_credit_rating_rec.num_prnt_bkcy_filing:=  p_credit_rating_obj.num_prnt_bkcy_filing;
    px_credit_rating_rec.prnt_bkcy_filg_type:=  p_credit_rating_obj.prnt_bkcy_filg_type;
    px_credit_rating_rec.prnt_bkcy_filg_chapter:=  p_credit_rating_obj.prnt_bkcy_filg_chapter;
    px_credit_rating_rec.prnt_bkcy_filg_date:=  p_credit_rating_obj.prnt_bkcy_filg_date;
    px_credit_rating_rec.num_prnt_bkcy_convs:=  p_credit_rating_obj.num_prnt_bkcy_convs;
    px_credit_rating_rec.prnt_bkcy_conv_date:=  p_credit_rating_obj.prnt_bkcy_conv_date;
    px_credit_rating_rec.prnt_bkcy_chapter_conv:=  p_credit_rating_obj.prnt_bkcy_chapter_conv;
    px_credit_rating_rec.slow_trade_expl:=  p_credit_rating_obj.slow_trade_expl;
    px_credit_rating_rec.negv_pmt_expl:=  p_credit_rating_obj.negv_pmt_expl;
    px_credit_rating_rec.pub_rec_expl:=  p_credit_rating_obj.pub_rec_expl;
    px_credit_rating_rec.business_discontinued:=  p_credit_rating_obj.business_discontinued;
    px_credit_rating_rec.spcl_event_comment:=  p_credit_rating_obj.spcl_event_comment;
    px_credit_rating_rec.num_spcl_event:=  p_credit_rating_obj.num_spcl_event;
    px_credit_rating_rec.spcl_event_update_date:=  p_credit_rating_obj.spcl_event_update_date;
    px_credit_rating_rec.spcl_evnt_txt:=  p_credit_rating_obj.spcl_evnt_txt;
    px_credit_rating_rec.actual_content_source:=  p_credit_rating_obj.actual_content_source;
    px_credit_rating_rec.created_by_module:= HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_credit_rating_rec;

  -- PRIVATE PROCEDURE assign_financial_report_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from financial report object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_fin_report_obj     Financial report object.
  --     p_party_id           Party Id.
  --   IN/OUT:
  --     px_fin_report_rec    Financial report plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE assign_financial_report_rec(
    p_fin_report_obj                   IN            HZ_FINANCIAL_BO,
    p_party_id                         IN            NUMBER,
    px_fin_report_rec                  IN OUT NOCOPY HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE
  ) IS
  BEGIN
    px_fin_report_rec.financial_report_id       := p_fin_report_obj.financial_report_id;
    px_fin_report_rec.party_id                  := p_party_id;
    px_fin_report_rec.type_of_financial_report  := p_fin_report_obj.type_of_financial_report;
    px_fin_report_rec.document_reference        := p_fin_report_obj.document_reference;
    px_fin_report_rec.date_report_issued        := p_fin_report_obj.date_report_issued;
    px_fin_report_rec.issued_period             := p_fin_report_obj.issued_period;
    px_fin_report_rec.report_start_date         := p_fin_report_obj.report_start_date;
    px_fin_report_rec.report_end_date           := p_fin_report_obj.report_end_date;
    px_fin_report_rec.requiring_authority       := p_fin_report_obj.requiring_authority;
    IF(p_fin_report_obj.audit_ind in ('Y','N')) THEN
      px_fin_report_rec.audit_ind                 := p_fin_report_obj.audit_ind;
    END IF;
    IF(p_fin_report_obj.consolidated_ind in ('Y','N')) THEN
      px_fin_report_rec.consolidated_ind          := p_fin_report_obj.consolidated_ind;
    END IF;
    IF(p_fin_report_obj.estimated_ind in ('Y','N')) THEN
      px_fin_report_rec.estimated_ind             := p_fin_report_obj.estimated_ind;
    END IF;
    IF(p_fin_report_obj.fiscal_ind in ('Y','N')) THEN
      px_fin_report_rec.fiscal_ind                := p_fin_report_obj.fiscal_ind;
    END IF;
    IF(p_fin_report_obj.final_ind in ('Y','N')) THEN
      px_fin_report_rec.final_ind                 := p_fin_report_obj.final_ind;
    END IF;
    IF(p_fin_report_obj.forecast_ind in ('Y','N')) THEN
      px_fin_report_rec.forecast_ind              := p_fin_report_obj.forecast_ind;
    END IF;
    IF(p_fin_report_obj.opening_ind in ('Y','N')) THEN
      px_fin_report_rec.opening_ind               := p_fin_report_obj.opening_ind;
    END IF;
    IF(p_fin_report_obj.proforma_ind in ('Y','N')) THEN
      px_fin_report_rec.proforma_ind              := p_fin_report_obj.proforma_ind;
    END IF;
    IF(p_fin_report_obj.qualified_ind in ('Y','N')) THEN
      px_fin_report_rec.qualified_ind             := p_fin_report_obj.qualified_ind;
    END IF;
    IF(p_fin_report_obj.restated_ind in ('Y','N')) THEN
      px_fin_report_rec.restated_ind              := p_fin_report_obj.restated_ind;
    END IF;
    IF(p_fin_report_obj.signed_by_principals_ind in ('Y','N')) THEN
      px_fin_report_rec.signed_by_principals_ind  := p_fin_report_obj.signed_by_principals_ind;
    END IF;
    IF(p_fin_report_obj.trial_balance_ind in ('Y','N')) THEN
      px_fin_report_rec.trial_balance_ind         := p_fin_report_obj.trial_balance_ind;
    END IF;
    IF(p_fin_report_obj.unbalanced_ind in ('Y','N')) THEN
      px_fin_report_rec.unbalanced_ind            := p_fin_report_obj.unbalanced_ind;
    END IF;
    IF(p_fin_report_obj.status in ('A','I')) THEN
      px_fin_report_rec.status                    := p_fin_report_obj.status;
    END IF;
    px_fin_report_rec.created_by_module         := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_financial_report_rec;

  -- PRIVATE PROCEDURE assign_financial_number_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from financial number object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_fin_number_obj     Financial number object.
  --     p_fin_report_id      Financial report Id.
  --   IN/OUT:
  --     px_fin_number_rec    Financial number plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE assign_financial_number_rec(
    p_fin_number_obj                   IN            HZ_FINANCIAL_NUMBER_OBJ,
    p_fin_report_id                    IN            NUMBER,
    px_fin_number_rec                  IN OUT NOCOPY HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE
  ) IS
  BEGIN
    px_fin_number_rec.financial_number_id       := p_fin_number_obj.financial_number_id;
    px_fin_number_rec.financial_report_id       := p_fin_report_id;
    px_fin_number_rec.financial_number          := p_fin_number_obj.financial_number;
    px_fin_number_rec.financial_number_name     := p_fin_number_obj.financial_number_name;
    px_fin_number_rec.financial_units_applied   := p_fin_number_obj.financial_units_applied;
    px_fin_number_rec.financial_number_currency := p_fin_number_obj.financial_number_currency;
    px_fin_number_rec.projected_actual_flag     := p_fin_number_obj.projected_actual_flag;
    IF(p_fin_number_obj.status in ('A','I')) THEN
      px_fin_number_rec.status                    := p_fin_number_obj.status;
    END IF;
    px_fin_number_rec.created_by_module         := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_financial_number_rec;

  -- PRIVATE PROCEDURE create_credit_ratings
  --
  -- DESCRIPTION
  --     Create credit ratings.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_credit_rating_objs List of credit rating objects.
  --     p_organization_id    Organization Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE create_credit_ratings(
    p_credit_rating_objs               IN OUT NOCOPY HZ_CREDIT_RATING_OBJ_TBL,
    p_organization_id                  IN         NUMBER,
    x_return_status                    OUT NOCOPY VARCHAR2,
    x_msg_count                        OUT NOCOPY NUMBER,
    x_msg_data                         OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_credit_rating_rec   HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE;
    l_dummy_id            NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_credit_ratings_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_credit_ratings(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --------------------------------
    -- Assign credit rating record
    --------------------------------
    FOR i IN 1..p_credit_rating_objs.COUNT LOOP
      assign_credit_rating_rec(
        p_credit_rating_obj         => p_credit_rating_objs(i),
        p_party_id                  => p_organization_id,
        px_credit_rating_rec        => l_credit_rating_rec
      );

      HZ_PARTY_INFO_V2PUB.create_credit_rating(
        p_credit_rating_rec         => l_credit_rating_rec,
        x_credit_rating_id          => l_dummy_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_organization_bo_pub.create_credit_ratings, organization id: '||p_organization_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign credit_rating_id
      p_credit_rating_objs(i).credit_rating_id := l_dummy_id;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_credit_ratings(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_credit_ratings_pub;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CREDIT_RATINGS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_credit_ratings(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_credit_ratings_pub;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CREDIT_RATINGS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_credit_ratings(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO create_credit_ratings_pub;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CREDIT_RATINGS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_credit_ratings(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_credit_ratings;

  -- PRIVATE PROCEDURE save_credit_ratings
  --
  -- DESCRIPTION
  --     Create or update credit ratings.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_credit_rating_objs List of credit rating objects.
  --     p_organization_id    Organization Id.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   02-MAR-2005    Arnold Ng          Created.

  PROCEDURE save_credit_ratings(
    p_credit_rating_objs               IN OUT NOCOPY HZ_CREDIT_RATING_OBJ_TBL,
    p_organization_id                  IN         NUMBER,
    x_return_status                    OUT NOCOPY VARCHAR2,
    x_msg_count                        OUT NOCOPY NUMBER,
    x_msg_data                         OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_credit_rating_rec   HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE;
    l_dummy_id            NUMBER;
    l_ovn                 NUMBER := NULL;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_credit_ratings_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_credit_ratings(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    --------------------------------
    -- Create/Update credit rating
    --------------------------------
    FOR i IN 1..p_credit_rating_objs.COUNT LOOP
      assign_credit_rating_rec(
        p_credit_rating_obj         => p_credit_rating_objs(i),
        p_party_id                  => p_organization_id,
        px_credit_rating_rec        => l_credit_rating_rec
      );

      hz_registry_validate_bo_pvt.check_credit_rating_op(
        p_party_id            => p_organization_id,
        px_credit_rating_id   => l_credit_rating_rec.credit_rating_id,
        p_rating_organization => l_credit_rating_rec.rating_organization,
        p_rated_as_of_date    => l_credit_rating_rec.rated_as_of_date,
        x_object_version_number => l_ovn
      );

      IF(l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Credit Ratings - Error occurred at hz_organization_bo_pub.check_credit_rating_op, organization id: '||p_organization_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_PARTY_INFO_V2PUB.create_credit_rating(
          p_credit_rating_rec         => l_credit_rating_rec,
          x_credit_rating_id          => l_dummy_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign credit_rating_id
        p_credit_rating_objs(i).credit_rating_id := l_dummy_id;
      ELSE
        -- clean up created_by_module for update
        l_credit_rating_rec.created_by_module := NULL;
        HZ_PARTY_INFO_V2PUB.update_credit_rating(
          p_credit_rating_rec         => l_credit_rating_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign credit_rating_id
        p_credit_rating_objs(i).credit_rating_id := l_credit_rating_rec.credit_rating_id;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_organization_bo_pub.create_credit_ratings, organization id: '||p_organization_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_credit_rating(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_credit_ratings_pub;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CREDIT_RATINGS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_credit_ratings(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_credit_ratings_pub;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CREDIT_RATINGS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_credit_ratings(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO save_credit_ratings_pub;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CREDIT_RATINGS');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_credit_ratings(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_credit_ratings;

  -- PRIVATE PROCEDURE create_financial_reports
  --
  -- DESCRIPTION
  --     Create financial reports.
  PROCEDURE create_financial_reports(
    p_fin_objs                         IN OUT NOCOPY HZ_FINANCIAL_BO_TBL,
    p_organization_id                  IN         NUMBER,
    x_return_status                    OUT NOCOPY VARCHAR2,
    x_msg_count                        OUT NOCOPY NUMBER,
    x_msg_data                         OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_fin_report_rec      HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE;
    l_fin_number_rec      HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE;
    l_dummy_id            NUMBER;
  BEGIN
    -- Standard start of API savepoint
    --SAVEPOINT create_credit_ratings_pub; --Bug 6619304
    SAVEPOINT create_financial_reports_pub; --Bug 6619304

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_financial_reports(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    ---------------------------------
    -- Assign financial report record
    ---------------------------------
    FOR i IN 1..p_fin_objs.COUNT LOOP
      assign_financial_report_rec(
        p_fin_report_obj            => p_fin_objs(i),
        p_party_id                  => p_organization_id,
        px_fin_report_rec           => l_fin_report_rec
      );

      HZ_ORGANIZATION_INFO_V2PUB.create_financial_report(
        p_financial_report_rec      => l_fin_report_rec,
        x_financial_report_id       => l_dummy_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_organization_bo_pub.create_financial_reports, org id: '||p_organization_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
        FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_FINANCIAL_REPORTS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        -- assign financial_number_id
        p_fin_objs(i).financial_report_id := l_dummy_id;

        -- Call financial number v2api if financial report record is created successfully
        -------------------------------------------------
        -- Assign financial number of financial report record
        -------------------------------------------------
        IF((p_fin_objs(i).financial_number_objs IS NOT NULL) AND --Bug 6619304
	    (p_fin_objs(i).financial_number_objs.COUNT > 0)) THEN --Bug 6619304
	FOR j IN 1..p_fin_objs(i).financial_number_objs.COUNT LOOP
          assign_financial_number_rec(
            p_fin_number_obj            => p_fin_objs(i).financial_number_objs(j),
            p_fin_report_id             => l_dummy_id,
            px_fin_number_rec           => l_fin_number_rec
          );

          HZ_ORGANIZATION_INFO_V2PUB.create_financial_number(
            p_financial_number_rec      => l_fin_number_rec,
            x_financial_number_id       => l_dummy_id,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Error occurred at hz_organization_bo_pub.create_financial_reports, fin_number_id: '||l_dummy_id,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_FINANCIAL_NUMBERS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- assign financial_number_id
          p_fin_objs(i).financial_number_objs(j).financial_number_id := l_dummy_id;
        END LOOP;
	END IF; --Bug 6619304
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_financial_reports(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_financial_reports_pub;
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_financial_reports(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_financial_reports_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_financial_reports(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO create_financial_reports_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_financial_reports(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_financial_reports;

  -- PRIVATE PROCEDURE save_financial_reports
  --
  -- DESCRIPTION
  --     Create or update financial reports.
  PROCEDURE save_financial_reports(
    p_fin_objs                         IN OUT NOCOPY HZ_FINANCIAL_BO_TBL,
    p_organization_id                  IN         NUMBER,
    x_return_status                    OUT NOCOPY VARCHAR2,
    x_msg_count                        OUT NOCOPY NUMBER,
    x_msg_data                         OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_fin_report_rec      HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_REPORT_REC_TYPE;
    l_fin_number_rec      HZ_ORGANIZATION_INFO_V2PUB.FINANCIAL_NUMBER_REC_TYPE;
    l_dummy_id            NUMBER;
    l_ovn                 NUMBER := NULL;
  BEGIN
    -- Standard start of API savepoint
    --SAVEPOINT save_credit_ratings_pub; --Bug 6619304
        SAVEPOINT save_financial_reports_pub; --Bug 6619304

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_financial_reports(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -----------------------------------
    -- Create/Update financial reports
    -----------------------------------
    FOR i IN 1..p_fin_objs.COUNT LOOP
      assign_financial_report_rec(
        p_fin_report_obj            => p_fin_objs(i),
        p_party_id                  => p_organization_id,
        px_fin_report_rec           => l_fin_report_rec
      );

      hz_registry_validate_bo_pvt.check_fin_report_op(
        p_party_id            => p_organization_id,
        px_fin_report_id      => l_fin_report_rec.financial_report_id,
        p_type_of_financial_report  => l_fin_report_rec.type_of_financial_report,
        p_document_reference  => l_fin_report_rec.document_reference,
        p_date_report_issued  => l_fin_report_rec.date_report_issued,
        p_issued_period       => l_fin_report_rec.issued_period,
        x_object_version_number => l_ovn
      );

      IF(l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Save Financial Report - Error occurred at hz_organization_bo_pub.check_fin_report_op, organization id: '||p_organization_id||' '||' ovn:'||l_ovn,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
        FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_FINANCIAL_REPORTS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_ORGANIZATION_INFO_V2PUB.create_financial_report(
          p_financial_report_rec      => l_fin_report_rec,
          x_financial_report_id       => l_dummy_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign financial_report_id
        p_fin_objs(i).financial_report_id := l_dummy_id;
      ELSE
        -- clean up created_by_module for update
        l_fin_report_rec.created_by_module := NULL;
        HZ_ORGANIZATION_INFO_V2PUB.update_financial_report(
          p_financial_report_rec      => l_fin_report_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );
        l_dummy_id := l_fin_report_rec.financial_report_id;

        -- assign financial_report_id
        p_fin_objs(i).financial_report_id := l_dummy_id;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_organization_bo_pub.save_financial_reports, org id: '||p_organization_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
        FND_MESSAGE.SET_TOKEN('STRUCTURE', 'HZ_FINANCIAL_REPORTS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        ---------------------------------
        -- Create/Update financial number
        ---------------------------------
	 IF((p_fin_objs(i).financial_number_objs IS NOT NULL) AND --Bug 6619304
	    (p_fin_objs(i).financial_number_objs.COUNT > 0)) THEN --Bug 6619304
        FOR j IN 1..p_fin_objs(i).financial_number_objs.COUNT LOOP
          assign_financial_number_rec(
            p_fin_number_obj            => p_fin_objs(i).financial_number_objs(j),
            p_fin_report_id             => l_dummy_id,
            px_fin_number_rec           => l_fin_number_rec
          );

          hz_registry_validate_bo_pvt.check_fin_number_op(
            p_fin_report_id       => l_dummy_id,
            px_fin_number_id      => l_fin_number_rec.financial_number_id,
            p_financial_number_name => l_fin_number_rec.financial_number_name,
            x_object_version_number => l_ovn
          );

          IF(l_ovn = -1) THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Save Financial Number - Error occurred at hz_organization_bo_pub.check_fin_number_op, organization id: '||p_organization_id||' '||' ovn:'||l_ovn,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
            FND_MSG_PUB.ADD;
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_FINANCIAL_NUMBERS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF(l_ovn IS NULL) THEN
            HZ_ORGANIZATION_INFO_V2PUB.create_financial_number(
              p_financial_number_rec      => l_fin_number_rec,
              x_financial_number_id       => l_dummy_id,
              x_return_status             => x_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data
            );

            -- assign financial_number_id
            p_fin_objs(i).financial_number_objs(j).financial_number_id := l_dummy_id;
          ELSE
            -- clean up created_by_module for update
            l_fin_number_rec.created_by_module := NULL;
            HZ_ORGANIZATION_INFO_V2PUB.update_financial_number(
              p_financial_number_rec      => l_fin_number_rec,
              p_object_version_number     => l_ovn,
              x_return_status             => x_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data
            );

            -- assign financial_number_id
            p_fin_objs(i).financial_number_objs(j).financial_number_id := l_fin_number_rec.financial_number_id;
          END IF;
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Error occurred at hz_organization_bo_pub.save_financial_reports, fin_number_id: '||l_dummy_id,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
            FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_FINANCIAL_NUMBERS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;
	END IF; --Bug 6619304
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_financial_reports(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_financial_reports_pub;
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_financial_reports(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_financial_reports_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_financial_reports(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO save_financial_reports_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_financial_reports(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_financial_reports;

  -- PROCEDURE do_create_organization_bo
  --
  -- DESCRIPTION
  --     Create organization business object.
  PROCEDURE do_create_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN OUT NOCOPY HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30);
    l_organization_rec         HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
    l_profile_id               NUMBER;
    l_party_number             VARCHAR2(30);
    l_dummy_id                 NUMBER;
    l_valid_obj                BOOLEAN;
    l_bus_object               HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_errorcode                NUMBER;
    l_raise_event              BOOLEAN := FALSE;
    l_cbm                      VARCHAR2(30);
    l_event_id                 NUMBER;
    l_sms_objs                 HZ_SMS_CP_BO_TBL;
    l_party_search_rec         HZ_PARTY_SEARCH.PARTY_SEARCH_REC_TYPE;
    l_party_site_list          HZ_PARTY_SEARCH.PARTY_SITE_LIST;
    l_contact_list             HZ_PARTY_SEARCH.CONTACT_LIST;
    l_contact_point_list       HZ_PARTY_SEARCH.CONTACT_POINT_LIST;
    l_match_rule_id number;
    l_search_ctx_id NUMBER;
    l_num_matches NUMBER;
    l_party_id NUMBER;
    l_match_score NUMBER;
    l_tmp_score NUMBER;
    l_match_threshold NUMBER;
    l_automerge_threshold NUMBER;
    l_dup_batch_id NUMBER;
    l_dup_set_id NUMBER;
    l_request_id NUMBER;
    l_dup_batch_rec  HZ_DUP_PVT.DUP_BATCH_REC_TYPE;
    l_dup_set_rec    HZ_DUP_PVT.DUP_SET_REC_TYPE;
    l_dup_party_tbl  HZ_DUP_PVT.DUP_PARTY_TBL_TYPE;
    l_party_name     varchar2(360);
    l_overlap_merge_req_id NUMBER;
    l_object_version_number NUMBER;
    l_batch_id NUMBER;
    l_cpt_count NUMBER;

    cursor get_obj_version_csr(cp_dup_set_id number) is
		SELECT object_version_number
  		FROM   hz_dup_sets
  		WHERE  dup_set_id = cp_dup_set_id;

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_organization_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_organization_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Base on p_validate_bo_flag to check completeness of business object
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'ORG',
        x_bus_object              => l_bus_object
      );
      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_org_bo_comp(
                       p_organization_obj => p_organization_obj,
                       p_bus_object       => l_bus_object
                     );
      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- find out if raise event at the end
      l_raise_event := HZ_PARTY_BO_PVT.is_raising_create_event(
                         p_obj_complete_flag => l_valid_obj );

      IF(l_raise_event) THEN
        -- get event_id and set global variable to event_id for
        -- BOT populate function
        SELECT HZ_BUS_OBJ_TRACKING_S.nextval
        INTO l_event_id
        FROM DUAL;
      END IF;
    ELSE
      l_raise_event := FALSE;
    END IF;

    x_organization_id := p_organization_obj.organization_id;
    x_organization_os := p_organization_obj.orig_system;
    x_organization_osr:= p_organization_obj.orig_system_reference;

    -- check input person party id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_organization_id,
      px_os              => x_organization_os,
      px_osr             => x_organization_osr,
      p_obj_type         => 'ORGANIZATION',
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    ---------------------------------------
    -- Assign organization and party record
    ---------------------------------------
    assign_organization_rec(
      p_organization_obj  => p_organization_obj,
      p_organization_id   => x_organization_id,
      p_organization_os   => x_organization_os,
      p_organization_osr  => x_organization_osr,
      px_organization_rec => l_organization_rec
    );

    HZ_PARTY_V2PUB.create_organization(
      p_organization_rec          => l_organization_rec,
      x_party_id                  => x_organization_id,
      x_party_number              => l_party_number,
      x_profile_id                => l_profile_id,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign organization party_id
    p_organization_obj.organization_id := x_organization_id;
    p_organization_obj.party_number := l_party_number;
    --------------------------
    -- Create Org Ext Attrs
    --------------------------
    IF((p_organization_obj.ext_attributes_objs IS NOT NULL) AND
       (p_organization_obj.ext_attributes_objs.COUNT > 0)) THEN
      HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
        p_ext_attr_objs             => p_organization_obj.ext_attributes_objs,
        p_parent_obj_id             => l_profile_id,
        p_parent_obj_type           => 'ORG',
        p_create_or_update          => 'C',
        x_return_status             => x_return_status,
        x_errorcode                 => l_errorcode,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Party Preferences
    ----------------------------
    IF((p_organization_obj.preference_objs IS NOT NULL) AND
       (p_organization_obj.preference_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_party_preferences(
        p_party_pref_objs           => p_organization_obj.preference_objs,
        p_party_id                  => x_organization_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Contact Preferences
    ----------------------------
    IF((p_organization_obj.contact_pref_objs IS NOT NULL) AND
       (p_organization_obj.contact_pref_objs.COUNT > 0)) THEN
      HZ_CONTACT_PREFERENCE_BO_PVT.create_contact_preferences(
        p_cp_pref_objs           => p_organization_obj.contact_pref_objs,
        p_contact_level_table_id => x_organization_id,
        p_contact_level_table    => 'HZ_PARTIES',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Relationship api
    ----------------------------
    IF((p_organization_obj.relationship_objs IS NOT NULL) AND
       (p_organization_obj.relationship_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.create_relationships(
        p_rel_objs                  => p_organization_obj.relationship_objs,
        p_subject_id                => x_organization_id,
        p_subject_type              => 'ORGANIZATION',
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Classification api
    ----------------------------
    IF((p_organization_obj.class_objs IS NOT NULL) AND
       (p_organization_obj.class_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.create_classifications(
        p_code_assign_objs          => p_organization_obj.class_objs,
        p_owner_table_name          => 'HZ_PARTIES',
        p_owner_table_id            => x_organization_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -----------------------------
    -- Create logical org contact
    -----------------------------
    IF((p_organization_obj.contact_objs IS NOT NULL) AND
       (p_organization_obj.contact_objs.COUNT > 0)) THEN
      HZ_ORG_CONTACT_BO_PVT.save_org_contacts(
        p_oc_objs            => p_organization_obj.contact_objs,
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_org_id      => x_organization_id,
        p_parent_org_os      => x_organization_os,
        p_parent_org_osr     => x_organization_osr
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ----------------------------
    -- Create logical party site
    ----------------------------
    IF((p_organization_obj.party_site_objs IS NOT NULL) AND
       (p_organization_obj.party_site_objs.COUNT > 0)) THEN
      HZ_PARTY_SITE_BO_PVT.save_party_sites(
        p_ps_objs            => p_organization_obj.party_site_objs,
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_id          => x_organization_id,
        p_parent_os          => x_organization_os,
        p_parent_osr         => x_organization_osr,
        p_parent_obj_type    => 'ORG'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ------------------------
    -- Create contact points
    ------------------------
    IF(((p_organization_obj.phone_objs IS NOT NULL) AND (p_organization_obj.phone_objs.COUNT > 0)) OR
       ((p_organization_obj.telex_objs IS NOT NULL) AND (p_organization_obj.telex_objs.COUNT > 0)) OR
       ((p_organization_obj.email_objs IS NOT NULL) AND (p_organization_obj.email_objs.COUNT > 0)) OR
       ((p_organization_obj.web_objs IS NOT NULL) AND (p_organization_obj.web_objs.COUNT > 0)) OR
       ((p_organization_obj.edi_objs IS NOT NULL) AND (p_organization_obj.edi_objs.COUNT > 0)) OR
       ((p_organization_obj.eft_objs IS NOT NULL) AND (p_organization_obj.eft_objs.COUNT > 0))) THEN
      HZ_CONTACT_POINT_BO_PVT.save_contact_points(
        p_phone_objs         => p_organization_obj.phone_objs,
        p_telex_objs         => p_organization_obj.telex_objs,
        p_email_objs         => p_organization_obj.email_objs,
        p_web_objs           => p_organization_obj.web_objs,
        p_edi_objs           => p_organization_obj.edi_objs,
        p_eft_objs           => p_organization_obj.eft_objs,
        p_sms_objs           => l_sms_objs,
        p_owner_table_id     => x_organization_id,
        p_owner_table_os     => x_organization_os,
        p_owner_table_osr    => x_organization_osr,
        p_parent_obj_type    => 'ORG',
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ----------------------------
    -- Certifications
    ----------------------------
    IF((p_organization_obj.certification_objs IS NOT NULL) AND
       (p_organization_obj.certification_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.create_certifications(
        p_cert_objs                 => p_organization_obj.certification_objs,
        p_party_id                  => x_organization_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Financial Profiles
    ----------------------------
    IF((p_organization_obj.financial_prof_objs IS NOT NULL) AND
       (p_organization_obj.financial_prof_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.create_financial_profiles(
        p_fin_prof_objs             => p_organization_obj.financial_prof_objs,
        p_party_id                  => x_organization_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  ----------------------------------
  --  Party Usages -------
  ----------------------------------
   IF ((p_organization_obj.party_usage_objs IS NOT NULL) AND
      (p_organization_obj.party_usage_objs.COUNT > 0 )) THEN
       HZ_PARTY_BO_PVT.create_party_usage_assgmnt(
	   p_party_usg_objs				=> p_organization_obj.party_usage_objs,
	   p_party_id					=> x_organization_id,
	   x_return_status				=> x_return_status,
	   x_msg_count					=> x_msg_count,
	   x_msg_data					=> x_msg_data
	   );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;


    ----------------------------
    -- Credit Ratings
    ----------------------------
    IF((p_organization_obj.credit_rating_objs IS NOT NULL) AND
       (p_organization_obj.credit_rating_objs.COUNT > 0)) THEN
      create_credit_ratings(
        p_credit_rating_objs        => p_organization_obj.credit_rating_objs,
        p_organization_id           => x_organization_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Financial Reports
    ----------------------------
    IF((p_organization_obj.financial_report_objs IS NOT NULL) AND
       (p_organization_obj.financial_report_objs.COUNT > 0)) THEN
      create_financial_reports(
        p_fin_objs                  => p_organization_obj.financial_report_objs,
        p_organization_id           => x_organization_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- raise event
    IF(l_raise_event) THEN
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_organization_id,
        p_bo_code          => 'ORG',
        p_create_or_update => 'C',
        p_obj_source       => p_obj_source,
        p_event_id         => l_event_id
      );
    END IF;

    -- Enh: check if DQM is enabled
    if nvl(fnd_profile.value('HZ_BO_ENABLE_DQ'),'N') = 'Y'
    then
	-- call DQM search API

        l_match_rule_id := nvl(fnd_profile.value('HZ_BO_ORG_MATCH_RULE'), 238); -- 238: new org match rule

        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'Enable DQ on Integration Services: START ',p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
      		hz_utility_v2pub.debug(p_message=>'Match Rule ID '||l_match_rule_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
		hz_utility_v2pub.debug(p_message=>'Newly Created Party Id: '||x_organization_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        END IF;
	l_party_search_rec.ANALYSIS_FY := l_organization_rec.ANALYSIS_FY;
  	l_party_search_rec.AVG_HIGH_CREDIT := l_organization_rec.AVG_HIGH_CREDIT;
  	l_party_search_rec.BEST_TIME_CONTACT_BEGIN := l_organization_rec.BEST_TIME_CONTACT_BEGIN;
  	l_party_search_rec.BEST_TIME_CONTACT_END := l_organization_rec.BEST_TIME_CONTACT_END;
  	l_party_search_rec.BRANCH_FLAG := l_organization_rec.BRANCH_FLAG;
  	l_party_search_rec.BUSINESS_SCOPE := l_organization_rec.BUSINESS_SCOPE;
  	l_party_search_rec.CEO_NAME := l_organization_rec.CEO_NAME;
  	l_party_search_rec.CEO_TITLE := l_organization_rec.CEO_TITLE;
  	l_party_search_rec.CONG_DIST_CODE := l_organization_rec.CONG_DIST_CODE;
  	l_party_search_rec.CONTENT_SOURCE_NUMBER := l_organization_rec.CONTENT_SOURCE_NUMBER;
  	l_party_search_rec.CONTROL_YR := l_organization_rec.CONTROL_YR;
  	l_party_search_rec.CORPORATION_CLASS := l_organization_rec.CORPORATION_CLASS;
  	l_party_search_rec.CREDIT_SCORE := l_organization_rec.CREDIT_SCORE;
  	l_party_search_rec.CREDIT_SCORE_AGE := l_organization_rec.CREDIT_SCORE_AGE;
  	l_party_search_rec.CREDIT_SCORE_CLASS := l_organization_rec.CREDIT_SCORE_CLASS;
  	l_party_search_rec.CREDIT_SCORE_COMMENTARY := l_organization_rec.CREDIT_SCORE_COMMENTARY;
  	l_party_search_rec.CREDIT_SCORE_COMMENTARY10 := l_organization_rec.CREDIT_SCORE_COMMENTARY10;
  	l_party_search_rec.CREDIT_SCORE_COMMENTARY2 := l_organization_rec.CREDIT_SCORE_COMMENTARY2;
  	l_party_search_rec.CREDIT_SCORE_COMMENTARY3 := l_organization_rec.CREDIT_SCORE_COMMENTARY3;
  	l_party_search_rec.CREDIT_SCORE_COMMENTARY4 := l_organization_rec.CREDIT_SCORE_COMMENTARY4;
  	l_party_search_rec.CREDIT_SCORE_COMMENTARY5 := l_organization_rec.CREDIT_SCORE_COMMENTARY5;
  	l_party_search_rec.CREDIT_SCORE_COMMENTARY6 := l_organization_rec.CREDIT_SCORE_COMMENTARY6;
  	l_party_search_rec.CREDIT_SCORE_COMMENTARY7 := l_organization_rec.CREDIT_SCORE_COMMENTARY7;
  	l_party_search_rec.CREDIT_SCORE_COMMENTARY8 := l_organization_rec.CREDIT_SCORE_COMMENTARY8;
  	l_party_search_rec.CREDIT_SCORE_COMMENTARY9 := l_organization_rec.CREDIT_SCORE_COMMENTARY9;
  	l_party_search_rec.CREDIT_SCORE_DATE := l_organization_rec.CREDIT_SCORE_DATE;
  	l_party_search_rec.CREDIT_SCORE_INCD_DEFAULT := l_organization_rec.CREDIT_SCORE_INCD_DEFAULT;
  	l_party_search_rec.CREDIT_SCORE_NATL_PERCENTILE := l_organization_rec.CREDIT_SCORE_NATL_PERCENTILE;
  	l_party_search_rec.CURR_FY_POTENTIAL_REVENUE := l_organization_rec.CURR_FY_POTENTIAL_REVENUE;
  	l_party_search_rec.DB_RATING := l_organization_rec.DB_RATING;
  	l_party_search_rec.DEBARMENTS_COUNT := l_organization_rec.DEBARMENTS_COUNT;
  	l_party_search_rec.DEBARMENTS_DATE := l_organization_rec.DEBARMENTS_DATE;
  	l_party_search_rec.DEBARMENT_IND := l_organization_rec.DEBARMENT_IND;
  	l_party_search_rec.DISADV_8A_IND := l_organization_rec.DISADV_8A_IND;
  	l_party_search_rec.DUNS_NUMBER_C := l_organization_rec.DUNS_NUMBER_C;
  	l_party_search_rec.EMPLOYEES_TOTAL := l_organization_rec.EMPLOYEES_TOTAL;
  	l_party_search_rec.EMP_AT_PRIMARY_ADR := l_organization_rec.EMP_AT_PRIMARY_ADR;
  	l_party_search_rec.EMP_AT_PRIMARY_ADR_EST_IND := l_organization_rec.EMP_AT_PRIMARY_ADR_EST_IND;
  	l_party_search_rec.EMP_AT_PRIMARY_ADR_MIN_IND := l_organization_rec.EMP_AT_PRIMARY_ADR_MIN_IND;
  	l_party_search_rec.EMP_AT_PRIMARY_ADR_TEXT := l_organization_rec.EMP_AT_PRIMARY_ADR_TEXT;
  	l_party_search_rec.ENQUIRY_DUNS := l_organization_rec.ENQUIRY_DUNS;
  	l_party_search_rec.EXPORT_IND := l_organization_rec.EXPORT_IND;
  	l_party_search_rec.FAILURE_SCORE := l_organization_rec.FAILURE_SCORE;
  	l_party_search_rec.FAILURE_SCORE_AGE := l_organization_rec.FAILURE_SCORE_AGE;
  	l_party_search_rec.FAILURE_SCORE_CLASS := l_organization_rec.FAILURE_SCORE_CLASS;
  	l_party_search_rec.FAILURE_SCORE_COMMENTARY := l_organization_rec.FAILURE_SCORE_COMMENTARY;
  	l_party_search_rec.FAILURE_SCORE_COMMENTARY10 := l_organization_rec.FAILURE_SCORE_COMMENTARY10;
  	l_party_search_rec.FAILURE_SCORE_COMMENTARY2 := l_organization_rec.FAILURE_SCORE_COMMENTARY2;
  	l_party_search_rec.FAILURE_SCORE_COMMENTARY3 := l_organization_rec.FAILURE_SCORE_COMMENTARY3;
  	l_party_search_rec.FAILURE_SCORE_COMMENTARY4 := l_organization_rec.FAILURE_SCORE_COMMENTARY4;
  	l_party_search_rec.FAILURE_SCORE_COMMENTARY5 := l_organization_rec.FAILURE_SCORE_COMMENTARY5;
  	l_party_search_rec.FAILURE_SCORE_COMMENTARY6 := l_organization_rec.FAILURE_SCORE_COMMENTARY6;
  	l_party_search_rec.FAILURE_SCORE_COMMENTARY7 := l_organization_rec.FAILURE_SCORE_COMMENTARY7;
  	l_party_search_rec.FAILURE_SCORE_COMMENTARY8 := l_organization_rec.FAILURE_SCORE_COMMENTARY8;
  	l_party_search_rec.FAILURE_SCORE_COMMENTARY9 := l_organization_rec.FAILURE_SCORE_COMMENTARY9;
  	l_party_search_rec.FAILURE_SCORE_DATE := l_organization_rec.FAILURE_SCORE_DATE;
  	l_party_search_rec.FAILURE_SCORE_INCD_DEFAULT := l_organization_rec.FAILURE_SCORE_INCD_DEFAULT;
  	l_party_search_rec.FAILURE_SCORE_OVERRIDE_CODE := l_organization_rec.FAILURE_SCORE_OVERRIDE_CODE;
  	l_party_search_rec.FISCAL_YEAREND_MONTH := l_organization_rec.FISCAL_YEAREND_MONTH;
  	l_party_search_rec.GLOBAL_FAILURE_SCORE := l_organization_rec.GLOBAL_FAILURE_SCORE;
  	l_party_search_rec.GSA_INDICATOR_FLAG := l_organization_rec.GSA_INDICATOR_FLAG;
  	l_party_search_rec.HIGH_CREDIT := l_organization_rec.HIGH_CREDIT;
  	l_party_search_rec.HQ_BRANCH_IND := l_organization_rec.HQ_BRANCH_IND;
  	l_party_search_rec.IMPORT_IND := l_organization_rec.IMPORT_IND;
  	l_party_search_rec.INCORP_YEAR := l_organization_rec.INCORP_YEAR;
  	l_party_search_rec.INTERNAL_FLAG := l_organization_rec.INTERNAL_FLAG;
  	l_party_search_rec.JGZZ_FISCAL_CODE := l_organization_rec.JGZZ_FISCAL_CODE;
  	l_party_search_rec.PARTY_ALL_NAMES := l_organization_rec.ORGANIZATION_NAME|| ' ' ||
						l_organization_rec.KNOWN_AS|| ' ' ||
						l_organization_rec.KNOWN_AS2|| ' ' ||
						l_organization_rec.KNOWN_AS3|| ' ' ||
						l_organization_rec.KNOWN_AS4|| ' ' ||
						l_organization_rec.KNOWN_AS5;
  	l_party_search_rec.KNOWN_AS := l_organization_rec.KNOWN_AS;
  	l_party_search_rec.KNOWN_AS2 := l_organization_rec.KNOWN_AS2;
  	l_party_search_rec.KNOWN_AS3 := l_organization_rec.KNOWN_AS3;
  	l_party_search_rec.KNOWN_AS4 := l_organization_rec.KNOWN_AS4;
  	l_party_search_rec.KNOWN_AS5 := l_organization_rec.KNOWN_AS5;
  	l_party_search_rec.LABOR_SURPLUS_IND := l_organization_rec.LABOR_SURPLUS_IND;
  	l_party_search_rec.LEGAL_STATUS := l_organization_rec.LEGAL_STATUS;
  	l_party_search_rec.LINE_OF_BUSINESS := l_organization_rec.LINE_OF_BUSINESS;
  	l_party_search_rec.LOCAL_ACTIVITY_CODE := l_organization_rec.LOCAL_ACTIVITY_CODE;
  	l_party_search_rec.LOCAL_ACTIVITY_CODE_TYPE := l_organization_rec.LOCAL_ACTIVITY_CODE_TYPE;
  	l_party_search_rec.LOCAL_BUS_IDENTIFIER := l_organization_rec.LOCAL_BUS_IDENTIFIER;
  	l_party_search_rec.LOCAL_BUS_IDEN_TYPE := l_organization_rec.LOCAL_BUS_IDEN_TYPE;
  	l_party_search_rec.MAXIMUM_CREDIT_CURRENCY_CODE := l_organization_rec.MAXIMUM_CREDIT_CURRENCY_CODE;
  	l_party_search_rec.MAXIMUM_CREDIT_RECOMMENDATION := l_organization_rec.MAXIMUM_CREDIT_RECOMMENDATION;
  	l_party_search_rec.MINORITY_OWNED_IND := l_organization_rec.MINORITY_OWNED_IND;
  	l_party_search_rec.MINORITY_OWNED_TYPE := l_organization_rec.MINORITY_OWNED_TYPE;
  	l_party_search_rec.NEXT_FY_POTENTIAL_REVENUE := l_organization_rec.NEXT_FY_POTENTIAL_REVENUE;
  	l_party_search_rec.OOB_IND := l_organization_rec.OOB_IND;
  	l_party_search_rec.ORGANIZATION_NAME := l_organization_rec.ORGANIZATION_NAME;
  	l_party_search_rec.ORGANIZATION_NAME_PHONETIC := l_organization_rec.ORGANIZATION_NAME_PHONETIC;
  	l_party_search_rec.ORGANIZATION_TYPE := l_organization_rec.ORGANIZATION_TYPE;
  	l_party_search_rec.PARENT_SUB_IND := l_organization_rec.PARENT_SUB_IND;
  	l_party_search_rec.PAYDEX_NORM := l_organization_rec.PAYDEX_NORM;
  	l_party_search_rec.PAYDEX_SCORE := l_organization_rec.PAYDEX_SCORE;
  	l_party_search_rec.PAYDEX_THREE_MONTHS_AGO := l_organization_rec.PAYDEX_THREE_MONTHS_AGO;
  	l_party_search_rec.PREF_FUNCTIONAL_CURRENCY := l_organization_rec.PREF_FUNCTIONAL_CURRENCY;
  	l_party_search_rec.PRINCIPAL_NAME := l_organization_rec.PRINCIPAL_NAME;
  	l_party_search_rec.PRINCIPAL_TITLE := l_organization_rec.PRINCIPAL_TITLE;
  	l_party_search_rec.PUBLIC_PRIVATE_OWNERSHIP_FLAG := l_organization_rec.PUBLIC_PRIVATE_OWNERSHIP_FLAG;
  	l_party_search_rec.REGISTRATION_TYPE := l_organization_rec.REGISTRATION_TYPE;
  	l_party_search_rec.RENT_OWN_IND := l_organization_rec.RENT_OWN_IND;
  	l_party_search_rec.SIC_CODE := l_organization_rec.SIC_CODE;
  	l_party_search_rec.SIC_CODE_TYPE := l_organization_rec.SIC_CODE_TYPE;
  	l_party_search_rec.SMALL_BUS_IND := l_organization_rec.SMALL_BUS_IND;
  	l_party_search_rec.TAX_REFERENCE := l_organization_rec.TAX_REFERENCE;
  	l_party_search_rec.TOTAL_EMPLOYEES_TEXT := l_organization_rec.TOTAL_EMPLOYEES_TEXT;
  	l_party_search_rec.TOTAL_EMP_EST_IND := l_organization_rec.TOTAL_EMP_EST_IND;
  	l_party_search_rec.TOTAL_EMP_MIN_IND := l_organization_rec.TOTAL_EMP_MIN_IND;
  	l_party_search_rec.TOTAL_EMPLOYEES_IND := l_organization_rec.TOTAL_EMPLOYEES_IND;
  	l_party_search_rec.TOTAL_PAYMENTS := l_organization_rec.TOTAL_PAYMENTS;
  	l_party_search_rec.WOMAN_OWNED_IND := l_organization_rec.WOMAN_OWNED_IND;
  	l_party_search_rec.YEAR_ESTABLISHED := l_organization_rec.YEAR_ESTABLISHED;
  	l_party_search_rec.CATEGORY_CODE := p_organization_obj.CATEGORY_CODE;
  	l_party_search_rec.PARTY_NAME := l_organization_rec.ORGANIZATION_NAME;
  	l_party_search_rec.PARTY_NUMBER := p_organization_obj.PARTY_NUMBER;
  	l_party_search_rec.PARTY_TYPE := 'ORGANIZATION';
  	l_party_search_rec.STATUS := p_organization_obj.STATUS;
	l_party_search_rec.PARTY_SOURCE_SYSTEM_REF := p_organization_obj.orig_system|| ' ' ||p_organization_obj.orig_system_reference||' ';


     IF((p_organization_obj.party_site_objs IS NOT NULL) AND (p_organization_obj.party_site_objs.COUNT > 0)) THEN
      for i in 1..p_organization_obj.party_site_objs.COUNT loop
	l_party_site_list(i).ADDR_SOURCE_SYSTEM_REF := p_organization_obj.party_site_objs(i).orig_system|| ' ' ||p_organization_obj.party_site_objs(i).orig_system_reference||' ';
	l_party_site_list(i).address := p_organization_obj.party_site_objs(i).location_obj.ADDRESS1|| ' ' ||
     					p_organization_obj.party_site_objs(i).location_obj.ADDRESS2|| ' ' ||
     					p_organization_obj.party_site_objs(i).location_obj.ADDRESS3|| ' ' ||
     					p_organization_obj.party_site_objs(i).location_obj.ADDRESS4;

 	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'l_party_site_list('||i||').address: '||l_party_site_list(i).ADDRESS,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        END IF;
	l_party_site_list(i).ADDRESS1 := p_organization_obj.party_site_objs(i).location_obj.ADDRESS1;
  	l_party_site_list(i).ADDRESS2 := p_organization_obj.party_site_objs(i).location_obj.ADDRESS2;
  	l_party_site_list(i).ADDRESS3 := p_organization_obj.party_site_objs(i).location_obj.ADDRESS3;
  	l_party_site_list(i).ADDRESS4 := p_organization_obj.party_site_objs(i).location_obj.ADDRESS4;
  	l_party_site_list(i).ADDRESS_EFFECTIVE_DATE := p_organization_obj.party_site_objs(i).location_obj.ADDRESS_EFFECTIVE_DATE;
  	l_party_site_list(i).ADDRESS_EXPIRATION_DATE := p_organization_obj.party_site_objs(i).location_obj.ADDRESS_EXPIRATION_DATE;
  	l_party_site_list(i).ADDRESS_LINES_PHONETIC := p_organization_obj.party_site_objs(i).location_obj.ADDRESS_LINES_PHONETIC;
  	l_party_site_list(i).CITY := p_organization_obj.party_site_objs(i).location_obj.CITY;
  	l_party_site_list(i).CLLI_CODE := p_organization_obj.party_site_objs(i).location_obj.CLLI_CODE;
  	l_party_site_list(i).COUNTRY := p_organization_obj.party_site_objs(i).location_obj.COUNTRY;
  	l_party_site_list(i).COUNTY := p_organization_obj.party_site_objs(i).location_obj.COUNTY;
  	l_party_site_list(i).LANGUAGE := p_organization_obj.party_site_objs(i).LANGUAGE;
  	l_party_site_list(i).POSITION := p_organization_obj.party_site_objs(i).location_obj.POSITION;
  	l_party_site_list(i).POSTAL_CODE := p_organization_obj.party_site_objs(i).location_obj.POSTAL_CODE;
  	l_party_site_list(i).POSTAL_PLUS4_CODE := p_organization_obj.party_site_objs(i).location_obj.POSTAL_PLUS4_CODE;

  	l_party_site_list(i).PROVINCE := p_organization_obj.party_site_objs(i).location_obj.PROVINCE;
  	l_party_site_list(i).SALES_TAX_GEOCODE := p_organization_obj.party_site_objs(i).location_obj.SALES_TAX_GEOCODE;
  	l_party_site_list(i).SALES_TAX_INSIDE_CITY_LIMITS := p_organization_obj.party_site_objs(i).location_obj.SALES_TAX_INSIDE_CITY_LIMITS;
  	l_party_site_list(i).STATE := p_organization_obj.party_site_objs(i).location_obj.STATE;
  	l_party_site_list(i).IDENTIFYING_ADDRESS_FLAG := p_organization_obj.party_site_objs(i).IDENTIFYING_ADDRESS_FLAG;
  	l_party_site_list(i).MAILSTOP := p_organization_obj.party_site_objs(i).MAILSTOP;
  	l_party_site_list(i).PARTY_SITE_NAME := p_organization_obj.party_site_objs(i).PARTY_SITE_NAME;
  	l_party_site_list(i).PARTY_SITE_NUMBER := p_organization_obj.party_site_objs(i).PARTY_SITE_NUMBER;
  	l_party_site_list(i).STATUS := p_organization_obj.party_site_objs(i).STATUS;
      end loop;
    end if;

    IF((p_organization_obj.contact_objs IS NOT NULL) AND (p_organization_obj.contact_objs.COUNT > 0)) THEN
     for i in 1..p_organization_obj.contact_objs.COUNT loop
	l_contact_list(i).CONTACT_SOURCE_SYSTEM_REF :=p_organization_obj.contact_objs(i).orig_system|| ' ' ||p_organization_obj.contact_objs(i).orig_system_reference||' ';
     	l_contact_list(i).CONTACT_NUMBER := p_organization_obj.contact_objs(i).CONTACT_NUMBER;
  	l_contact_list(i).CONTACT_NAME := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_FIRST_NAME||' '||p_organization_obj.contact_objs(i).person_profile_obj.PERSON_LAST_NAME;
  	l_contact_list(i).DECISION_MAKER_FLAG := p_organization_obj.contact_objs(i).DECISION_MAKER_FLAG;
  	l_contact_list(i).JOB_TITLE := p_organization_obj.contact_objs(i).JOB_TITLE;
  	l_contact_list(i).JOB_TITLE_CODE := p_organization_obj.contact_objs(i).JOB_TITLE_CODE;
  	l_contact_list(i).RANK := p_organization_obj.contact_objs(i).RANK;
  	l_contact_list(i).REFERENCE_USE_FLAG := p_organization_obj.contact_objs(i).REFERENCE_USE_FLAG;
  	l_contact_list(i).TITLE := p_organization_obj.contact_objs(i).TITLE;
  	l_contact_list(i).RELATIONSHIP_TYPE := p_organization_obj.contact_objs(i).RELATIONSHIP_TYPE;
  	l_contact_list(i).DATE_OF_BIRTH := p_organization_obj.contact_objs(i).person_profile_obj.DATE_OF_BIRTH;
  	l_contact_list(i).DATE_OF_DEATH := p_organization_obj.contact_objs(i).person_profile_obj.DATE_OF_DEATH;
  	l_contact_list(i).JGZZ_FISCAL_CODE := p_organization_obj.contact_objs(i).person_profile_obj.JGZZ_FISCAL_CODE;
  	l_contact_list(i).KNOWN_AS := p_organization_obj.contact_objs(i).person_profile_obj.KNOWN_AS;
  	l_contact_list(i).PERSON_ACADEMIC_TITLE := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_ACADEMIC_TITLE;
  	l_contact_list(i).PERSON_FIRST_NAME := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_FIRST_NAME;
  	l_contact_list(i).PERSON_FIRST_NAME_PHONETIC := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_FIRST_NAME_PHONETIC;
  	l_contact_list(i).PERSON_IDENTIFIER := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_IDENTIFIER;
  	l_contact_list(i).PERSON_IDEN_TYPE := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_IDEN_TYPE;
  	l_contact_list(i).PERSON_INITIALS := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_INITIALS;
  	l_contact_list(i).PERSON_LAST_NAME := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_LAST_NAME;
  	l_contact_list(i).PERSON_LAST_NAME_PHONETIC := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_LAST_NAME_PHONETIC;
  	l_contact_list(i).PERSON_MIDDLE_NAME := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_MIDDLE_NAME;
  	l_contact_list(i).PERSON_NAME := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_FIRST_NAME||' '||p_organization_obj.contact_objs(i).person_profile_obj.PERSON_LAST_NAME;
  	l_contact_list(i).PERSON_NAME_PHONETIC := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_NAME_PHONETIC;
  	l_contact_list(i).PERSON_NAME_SUFFIX := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_NAME_SUFFIX;
  	l_contact_list(i).PERSON_PREVIOUS_LAST_NAME := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_PREVIOUS_LAST_NAME;
  	l_contact_list(i).PERSON_TITLE := p_organization_obj.contact_objs(i).person_profile_obj.PERSON_TITLE;
  	l_contact_list(i).PLACE_OF_BIRTH := p_organization_obj.contact_objs(i).person_profile_obj.PLACE_OF_BIRTH;
  --	l_contact_list(i).TAX_NAME := p_organization_obj.contact_objs(i).person_profile_obj.TAX_NAME;
  	l_contact_list(i).TAX_REFERENCE := p_organization_obj.contact_objs(i).person_profile_obj.TAX_REFERENCE;

       end loop;
     end if;

     IF((p_organization_obj.phone_objs IS NOT NULL) AND (p_organization_obj.phone_objs.COUNT > 0))
     then
      for i in 1..p_organization_obj.phone_objs.COUNT loop
	l_contact_point_list(i).CPT_SOURCE_SYSTEM_REF := p_organization_obj.phone_objs(i).orig_system|| ' ' ||p_organization_obj.phone_objs(i).orig_system_reference||' ';
        l_contact_point_list(i).CONTACT_POINT_TYPE := 'PHONE';
	l_contact_point_list(i).PRIMARY_FLAG := p_organization_obj.phone_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(i).STATUS := p_organization_obj.phone_objs(i).STATUS;
  	l_contact_point_list(i).CONTACT_POINT_PURPOSE := p_organization_obj.phone_objs(i).CONTACT_POINT_PURPOSE;
  	l_contact_point_list(i).LAST_CONTACT_DT_TIME := p_organization_obj.phone_objs(i).LAST_CONTACT_DT_TIME;
  	l_contact_point_list(i).PHONE_AREA_CODE := p_organization_obj.phone_objs(i).PHONE_AREA_CODE;
  	l_contact_point_list(i).PHONE_CALLING_CALENDAR := p_organization_obj.phone_objs(i).PHONE_CALLING_CALENDAR;
  	l_contact_point_list(i).PHONE_COUNTRY_CODE := p_organization_obj.phone_objs(i).PHONE_COUNTRY_CODE;
  	l_contact_point_list(i).PHONE_EXTENSION := p_organization_obj.phone_objs(i).PHONE_EXTENSION;
  	l_contact_point_list(i).PHONE_LINE_TYPE := p_organization_obj.phone_objs(i).PHONE_LINE_TYPE;
  	l_contact_point_list(i).PHONE_NUMBER := p_organization_obj.phone_objs(i).PHONE_NUMBER;
  	l_contact_point_list(i).PRIMARY_FLAG := p_organization_obj.phone_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(i).RAW_PHONE_NUMBER := p_organization_obj.phone_objs(i).RAW_PHONE_NUMBER;
  	l_contact_point_list(i).TELEPHONE_TYPE := p_organization_obj.phone_objs(i).PHONE_LINE_TYPE;
  	l_contact_point_list(i).TIME_ZONE := p_organization_obj.phone_objs(i).TIMEZONE_ID;
        -- Per DQM, flex_formatted_phone_number is the concate of country code, area code and phone number
	if p_organization_obj.phone_objs(i).PHONE_NUMBER is not null
	then
          l_contact_point_list(i).FLEX_FORMAT_PHONE_NUMBER := p_organization_obj.phone_objs(i).PHONE_COUNTRY_CODE ||p_organization_obj.phone_objs(i).PHONE_AREA_CODE||p_organization_obj.phone_objs(i).PHONE_NUMBER;

	elsif l_contact_point_list(i).RAW_PHONE_NUMBER is not null
	then
		 hz_contact_point_v2pub.phone_format (
                                 p_raw_phone_number       => p_organization_obj.phone_objs(i).RAW_PHONE_NUMBER,
                                 p_territory_code         => p_organization_obj.phone_objs(i).PHONE_COUNTRY_CODE,
                                 x_formatted_phone_number => l_contact_point_list(i).FLEX_FORMAT_PHONE_NUMBER,
                                 x_phone_country_code     => l_contact_point_list(i).PHONE_COUNTRY_CODE,
                                 x_phone_area_code        => l_contact_point_list(i).PHONE_AREA_CODE,
                                 x_phone_number           => l_contact_point_list(i).PHONE_NUMBER,
                                 x_return_status          => x_return_status,
                                 x_msg_count              => x_msg_count,
                                 x_msg_data               => x_msg_data);
		 l_contact_point_list(i).FLEX_FORMAT_PHONE_NUMBER := l_contact_point_list(i).PHONE_COUNTRY_CODE ||l_contact_point_list(i).PHONE_AREA_CODE||l_contact_point_list(i).PHONE_NUMBER;

	end if;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'l_contact_point_list('||i||').flex_format_phone_number: '||l_contact_point_list(i).FLEX_FORMAT_PHONE_NUMBER,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
	        hz_utility_v2pub.debug(p_message=>'l_contact_point_list('||i||').phone_number: '||l_contact_point_list(i).PHONE_NUMBER,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        END IF;

       end loop;
     end if;

     l_cpt_count := l_contact_point_list.COUNT;
    IF((p_organization_obj.email_objs IS NOT NULL) AND (p_organization_obj.email_objs.COUNT > 0))
    then
      for i in 1..p_organization_obj.email_objs.COUNT loop
	l_contact_point_list(i).CPT_SOURCE_SYSTEM_REF := p_organization_obj.phone_objs(i).orig_system|| ' ' ||p_organization_obj.phone_objs(i).orig_system_reference||' ';
        l_contact_point_list(l_cpt_count+i).CONTACT_POINT_TYPE := 'EMAIL';
	l_contact_point_list(l_cpt_count+i).PRIMARY_FLAG := p_organization_obj.email_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(l_cpt_count+i).STATUS := p_organization_obj.email_objs(i).STATUS;
  	l_contact_point_list(l_cpt_count+i).CONTACT_POINT_PURPOSE := p_organization_obj.email_objs(i).CONTACT_POINT_PURPOSE;
	l_contact_point_list(l_cpt_count+i).EMAIL_ADDRESS := p_organization_obj.email_objs(i).EMAIL_ADDRESS;
        l_contact_point_list(l_cpt_count+i).EMAIL_FORMAT := p_organization_obj.email_objs(i).EMAIL_FORMAT;

      end loop;
    end if;

    l_cpt_count := l_contact_point_list.COUNT;
    IF((p_organization_obj.web_objs IS NOT NULL) AND (p_organization_obj.web_objs.COUNT > 0))
    then
      for i in 1..p_organization_obj.web_objs.COUNT loop
	l_contact_point_list(i).CPT_SOURCE_SYSTEM_REF := p_organization_obj.phone_objs(i).orig_system|| ' ' ||p_organization_obj.phone_objs(i).orig_system_reference||' ';
        l_contact_point_list(l_cpt_count+i).CONTACT_POINT_TYPE := 'WEB';
	l_contact_point_list(l_cpt_count+i).PRIMARY_FLAG := p_organization_obj.web_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(l_cpt_count+i).STATUS := p_organization_obj.web_objs(i).STATUS;
  	l_contact_point_list(l_cpt_count+i).CONTACT_POINT_PURPOSE := p_organization_obj.web_objs(i).CONTACT_POINT_PURPOSE;
	l_contact_point_list(l_cpt_count+i).URL := p_organization_obj.web_objs(i).URL ;
  	l_contact_point_list(l_cpt_count+i).WEB_TYPE := p_organization_obj.web_objs(i).WEB_TYPE;

      end loop;
    end if;

    l_cpt_count := l_contact_point_list.COUNT;
    IF((p_organization_obj.telex_objs IS NOT NULL) AND (p_organization_obj.telex_objs.COUNT > 0))
    then
      for i in 1..p_organization_obj.telex_objs.COUNT loop
	l_contact_point_list(i).CPT_SOURCE_SYSTEM_REF := p_organization_obj.phone_objs(i).orig_system|| ' ' ||p_organization_obj.phone_objs(i).orig_system_reference||' ';
        l_contact_point_list(l_cpt_count+i).CONTACT_POINT_TYPE := 'TLX';
	l_contact_point_list(l_cpt_count+i).PRIMARY_FLAG := p_organization_obj.telex_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(l_cpt_count+i).STATUS := p_organization_obj.telex_objs(i).STATUS;
  	l_contact_point_list(l_cpt_count+i).CONTACT_POINT_PURPOSE := p_organization_obj.telex_objs(i).CONTACT_POINT_PURPOSE;
      end loop;
    end if;

    l_cpt_count := l_contact_point_list.COUNT;
    IF((p_organization_obj.edi_objs IS NOT NULL) AND (p_organization_obj.edi_objs.COUNT > 0))
    then
      for i in 1..p_organization_obj.edi_objs.COUNT loop
	l_contact_point_list(i).CPT_SOURCE_SYSTEM_REF := p_organization_obj.phone_objs(i).orig_system|| ' ' ||p_organization_obj.phone_objs(i).orig_system_reference||' ';
        l_contact_point_list(l_cpt_count+i).CONTACT_POINT_TYPE := 'EDI';
	l_contact_point_list(l_cpt_count+i).PRIMARY_FLAG := p_organization_obj.edi_objs(i).PRIMARY_FLAG;
  	l_contact_point_list(l_cpt_count+i).STATUS := p_organization_obj.edi_objs(i).STATUS;
        l_contact_point_list(l_cpt_count+i).EDI_ECE_TP_LOCATION_CODE := P_ORGANIZATION_OBJ.EDI_OBJS(I).EDI_ECE_TP_LOCATION_CODE;
  	l_contact_point_list(l_cpt_count+i).EDI_ID_NUMBER := P_ORGANIZATION_OBJ.EDI_OBJS(I).EDI_ID_NUMBER;
  	l_contact_point_list(l_cpt_count+i).EDI_PAYMENT_FORMAT := P_ORGANIZATION_OBJ.EDI_OBJS(I).EDI_PAYMENT_FORMAT;
  	l_contact_point_list(l_cpt_count+i).EDI_PAYMENT_METHOD := P_ORGANIZATION_OBJ.EDI_OBJS(I).EDI_PAYMENT_METHOD;
  	l_contact_point_list(l_cpt_count+i).EDI_REMITTANCE_INSTRUCTION := P_ORGANIZATION_OBJ.EDI_OBJS(I).EDI_REMITTANCE_INSTRUCTION;
  	l_contact_point_list(l_cpt_count+i).EDI_REMITTANCE_METHOD := P_ORGANIZATION_OBJ.EDI_OBJS(I).EDI_REMITTANCE_METHOD;
  	l_contact_point_list(l_cpt_count+i).EDI_TP_HEADER_ID := P_ORGANIZATION_OBJ.EDI_OBJS(I).EDI_TP_HEADER_ID;
  	l_contact_point_list(l_cpt_count+i).EDI_TRANSACTION_HANDLING := P_ORGANIZATION_OBJ.EDI_OBJS(I).EDI_TRANSACTION_HANDLING;
      end loop;
    end if;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'Calling DQM API HZ_PARTY_SEARCH.find_parties ',p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
	hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SEARCH.find_parties Start time: '||TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'),p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
    END IF;

    HZ_PARTY_SEARCH.find_parties (
	     p_init_msg_list     => FND_API.G_FALSE,
	     x_rule_id           => l_match_rule_id,
	     p_party_search_rec  => l_party_search_rec,
	     p_party_site_list   => l_party_site_list,
	     p_contact_list      => l_contact_list,
	     p_contact_point_list=> l_contact_point_list,
	     p_restrict_sql      => null,
	     p_search_merged     => 'N', -- return only active
	     x_search_ctx_id     => l_search_ctx_id,
	     x_num_matches       => l_num_matches,
	     x_return_status     => x_return_status,
 	     x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data

    );

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_PARTY_SEARCH.find_parties end time: '||TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'),p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
	hz_utility_v2pub.debug(p_message=>'return status of find_parties: '||x_return_status,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
	hz_utility_v2pub.debug(p_message=>'search_ctx_id: '||l_search_ctx_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        if l_num_matches = 0
        then
          hz_utility_v2pub.debug(p_message=>'# of Matches: '||l_num_matches,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        end if;
    END IF;

   if l_num_matches > 0 then

     hz_dup_pvt.get_most_matching_party(p_search_ctx_id => l_search_ctx_id,
					p_new_party_id =>  x_organization_id,
				       x_party_id => l_party_id,
				       x_match_score => l_match_score,
				       x_party_name => l_party_name);
     if l_party_id is null
     then
		 IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 	hz_utility_v2pub.debug(p_message=>'# of Matches: 0 ',p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
		 end if;
     else

         IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'# of Matches: '||l_num_matches,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        	hz_utility_v2pub.debug(p_message=>'Most matching Party Id: '||l_party_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
	        hz_utility_v2pub.debug(p_message=>'Most matching Party Name: '||l_party_name,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        	hz_utility_v2pub.debug(p_message=>'Match score: '||l_match_score,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
    	 END IF;

	hz_dup_pvt.get_match_rule_thresholds(p_match_rule_id => l_match_rule_id,
				    x_match_threshold => l_match_threshold,
				    x_automerge_threshold => l_automerge_threshold);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'Match Threshold: '||l_match_threshold,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        	hz_utility_v2pub.debug(p_message=>'Automerge Threshold: '||l_automerge_threshold,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');

    	 END IF;

	if l_match_score >= l_match_threshold
	then
		hz_dup_pvt.validate_master_party_id(px_party_id => l_party_id,
					x_overlap_merge_req_id => l_overlap_merge_req_id);



		if l_overlap_merge_req_id is not null
		then
			l_tmp_score := l_match_score;
			begin
				SELECT score, party_name into l_match_score, l_party_name
				FROM hz_matched_parties_gt mpg, hz_parties p
				WHERE mpg.party_id = p.party_id
				and mpg.party_id = l_party_id
				and mpg.search_context_id = l_search_ctx_id
				and rownum = 1;
			EXCEPTION
       				WHEN NO_DATA_FOUND THEN
				l_match_score := 0;
				IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_message=>'The changed party is not a duplicate with the newly created party' ,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
				end if;
			END;
			IF l_match_score > 0 and fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
				hz_utility_v2pub.debug(p_message=>'Winner Party ID is changed. Overlapping Merge Req ID: '||l_overlap_merge_req_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');

        		hz_utility_v2pub.debug(p_message=>'Winner Party Id: '||l_party_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
				hz_utility_v2pub.debug(p_message=>'Winner Party Id match score: '||l_match_score,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
		      end if;
    	        END IF;

	     if l_match_score >= l_match_threshold
	     then -- match score might get reset due to overlapping req, need to check this again.

		l_dup_batch_rec.dup_batch_name := l_party_name||'-'|| to_char(sysdate);
    		l_dup_batch_rec.match_rule_id := l_match_rule_id;
    		l_dup_batch_rec.application_id := 222;
    		l_dup_batch_rec.request_type := 'USER_ENTERED';
    		l_dup_batch_id := NULL;
    		l_dup_set_rec.winner_party_id := l_party_id;
    		l_dup_set_rec.status := 'SYSBATCH';
    		l_dup_set_rec.assigned_to_user_id := fnd_global.user_id;
		l_dup_set_rec.merge_type := 'PARTY_MERGE';

		l_dup_party_tbl(1).party_id := l_party_id;
      		l_dup_party_tbl(1).score := l_match_score;
      		l_dup_party_tbl(1).merge_flag := 'Y';

	 	l_dup_party_tbl(2).party_id := x_organization_id; -- newly created org id
      		l_dup_party_tbl(2).score := 0;
      		l_dup_party_tbl(2).merge_flag := 'Y';

		HZ_DUP_PVT.create_dup_batch(
         	p_dup_batch_rec             => l_dup_batch_rec
        	,p_dup_set_rec               => l_dup_set_rec
        	,p_dup_party_tbl             => l_dup_party_tbl
        	,x_dup_batch_id              => l_dup_batch_id
        	,x_dup_set_id                => l_dup_set_id
        	,x_return_status             => x_return_status
        	,x_msg_count                 => x_msg_count
        	,x_msg_data                  => x_msg_data );


      		IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
      		END IF;

		IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        			hz_utility_v2pub.debug(p_message=>'Created dup batch: dup_set_id: '||l_dup_set_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');

    	        END IF;


		if l_dup_set_id is not null
		then
		  if l_match_score < l_automerge_threshold -- create merge request
		  then
			hz_dup_pvt.submit_dup (
   					p_dup_set_id    => l_dup_set_id
  					,x_request_id    => l_request_id
  					,x_return_status => x_return_status
  					,x_msg_count     => x_msg_count
  					,x_msg_data      => x_msg_data);

		        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        				hz_utility_v2pub.debug(p_message=>'Merge Request Created with merge request id: '||l_dup_set_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        				hz_utility_v2pub.debug(p_message=>'Create Merge Request conc request id: '||l_request_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');

			end if;
		  end if; --if l_match_score < l_automerge_threshold
                 end if; --if l_match_score >= l_match_threshold then

		  if l_match_score >= l_automerge_threshold
    		  then
				open get_obj_version_csr(l_dup_set_id);
				fetch get_obj_version_csr into l_object_version_number;
	        		close get_obj_version_csr;

				hz_merge_dup_pvt.Create_Merge_Batch(  -- need to create merge in real time.
  					p_dup_set_id    => l_dup_set_id,
  					p_default_mapping  => 'Y',
  					p_object_version_number => l_object_version_number,
  					x_merge_batch_id     => l_batch_id,
					x_return_status => x_return_status,
  					x_msg_count     => x_msg_count,
  					x_msg_data      => x_msg_data);


	            		--submit Party Merge concurrent program
                                     hz_merge_dup_pvt.submit_batch(
  					p_batch_id      => l_dup_set_id,
  					p_preview       => 'N',
  					x_request_id    => l_request_id,
  					x_return_status => x_return_status,
  					x_msg_count     => x_msg_count,
  					x_msg_data      => x_msg_data);
				IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
					hz_utility_v2pub.debug(p_message=>'Party Merge request status: '||x_return_status,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
        				hz_utility_v2pub.debug(p_message=>'Party Merge request submitted with conc request_id: '||l_request_id,p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
                        	end if;

    	          end if; -- if l_match_score >= l_automerge_threshold
		end if; --if l_dup_set_id is not null
	end if;	-- if l_match_score >= l_match_threshold
    end if; -- if l_party_id = x_organization_id
   end if;  -- if l_num_matches > 0 then
   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'Enable DQ on Integration Services: End ',p_prefix=>'DEBUG: ',p_msg_level=>fnd_log.level_statement, p_module=>'HZ_Module.enableDQ');
   end if;
end if;  -- if nvl(fnd_profile.value('HZ_BO_ENABLE_DQ'),'N') = 'Y'
    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_organization_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_organization_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_organization_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_organization_bo;

  PROCEDURE create_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  ) IS
    l_org_obj             HZ_ORGANIZATION_BO;
  BEGIN
    l_org_obj := p_organization_obj;
    do_create_organization_bo(
      p_init_msg_list       => p_init_msg_list,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_organization_obj    => l_org_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_organization_id     => x_organization_id,
      x_organization_os     => x_organization_os,
      x_organization_osr    => x_organization_osr
    );
  END create_organization_bo;

  PROCEDURE create_organization_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_org_obj             HZ_ORGANIZATION_BO;
  BEGIN
    l_org_obj := p_organization_obj;
    do_create_organization_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_organization_obj    => l_org_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_organization_id     => x_organization_id,
      x_organization_os     => x_organization_os,
      x_organization_osr    => x_organization_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_org_obj;
    END IF;
  END create_organization_bo;

  -- PROCEDURE do_update_organization_bo
  --
  -- DESCRIPTION
  --     Update organization business object.
  PROCEDURE do_update_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_obj    IN OUT NOCOPY HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30);
    l_organization_rec         HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
    l_create_update_flag       VARCHAR2(1);
    l_ovn                      NUMBER;
    l_dummy_id                 NUMBER;
    l_profile_id               NUMBER;
    l_errorcode                NUMBER;
    l_org_raise_event          BOOLEAN := FALSE;
    l_oc_raise_event           BOOLEAN := FALSE;
    l_cbm                      VARCHAR2(30);
    l_org_event_id             NUMBER;
    l_oc_event_id              NUMBER;
    l_sms_objs                 HZ_SMS_CP_BO_TBL;
    l_party_number             VARCHAR2(30);

    CURSOR get_ovn(l_party_id  NUMBER) IS
    SELECT p.object_version_number, p.party_number
    FROM HZ_PARTIES p
    WHERE p.party_id = l_party_id
    AND p.party_type = 'ORGANIZATION'
    AND p.status in ('A','I');

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_organization_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_organization_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_organization_id := p_organization_obj.organization_id;
    x_organization_os := p_organization_obj.orig_system;
    x_organization_osr:= p_organization_obj.orig_system_reference;

    -- check input party_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_organization_id,
      px_os              => x_organization_os,
      px_osr             => x_organization_osr,
      p_obj_type         => 'ORGANIZATION',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- must check after calling validate_ssm_id because
    -- if user pass os+osr and no id, validate_ssm_id will
    -- populate x_organization_id based on os+osr
    -- find out if raise event at the end

    -- if this procedure is called from org cust bo, set l_raise_event to false
    -- otherwise, call is_raising_update_event
    IF(HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO IS NOT NULL) THEN
      l_org_raise_event := FALSE;
      l_oc_raise_event := FALSE;
    ELSE
      l_org_raise_event := HZ_PARTY_BO_PVT.is_raising_update_event(
                             p_party_id          => x_organization_id,
                             p_bo_code           => 'ORG'
                           );

      l_oc_raise_event := HZ_PARTY_BO_PVT.is_raising_update_event(
                            p_party_id          => x_organization_id,
                            p_bo_code           => 'ORG_CUST'
                          );

      IF(l_org_raise_event) THEN
        -- Get event_id for org
        SELECT HZ_BUS_OBJ_TRACKING_S.nextval
        INTO l_org_event_id
        FROM DUAL;
      END IF;

      IF(l_oc_raise_event) THEN
        -- Get event_id for org customer
        SELECT HZ_BUS_OBJ_TRACKING_S.nextval
        INTO l_oc_event_id
        FROM DUAL;
      END IF;
    END IF;

    OPEN get_ovn(x_organization_id);
    FETCH get_ovn INTO l_ovn, l_party_number;
    CLOSE get_ovn;

    --------------------------
    -- For Update Organization
    --------------------------
    -- Assign organization record
    assign_organization_rec(
      p_organization_obj  => p_organization_obj,
      p_organization_id   => x_organization_id,
      p_organization_os   => x_organization_os,
      p_organization_osr  => x_organization_osr,
      p_create_or_update  => 'U',
      px_organization_rec => l_organization_rec
    );

    HZ_PARTY_V2PUB.update_organization(
      p_organization_rec          => l_organization_rec,
      p_party_object_version_number  => l_ovn,
      x_profile_id                => l_profile_id,
      x_return_status             => x_return_status,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign organization party_id
    p_organization_obj.organization_id := x_organization_id;
    p_organization_obj.party_number := l_party_number;
    -----------------------------
    -- For Organization Ext Attrs
    -----------------------------
    IF((p_organization_obj.ext_attributes_objs IS NOT NULL) AND
       (p_organization_obj.ext_attributes_objs.COUNT > 0)) THEN
      HZ_EXT_ATTRIBUTE_BO_PVT.save_ext_attributes(
        p_ext_attr_objs             => p_organization_obj.ext_attributes_objs,
        p_parent_obj_id             => l_profile_id,
        p_parent_obj_type           => 'ORG',
        p_create_or_update          => 'U',
        x_return_status             => x_return_status,
        x_errorcode                 => l_errorcode,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Party Preferences
    ----------------------------
    IF((p_organization_obj.preference_objs IS NOT NULL) AND
       (p_organization_obj.preference_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_party_preferences(
        p_party_pref_objs           => p_organization_obj.preference_objs,
        p_party_id                  => x_organization_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Contact Preferences
    ----------------------------
    IF((p_organization_obj.contact_pref_objs IS NOT NULL) AND
       (p_organization_obj.contact_pref_objs.COUNT > 0)) THEN
      HZ_CONTACT_PREFERENCE_BO_PVT.save_contact_preferences(
        p_cp_pref_objs           => p_organization_obj.contact_pref_objs,
        p_contact_level_table_id => x_organization_id,
        p_contact_level_table    => 'HZ_PARTIES',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Relationship api
    ----------------------------
    IF((p_organization_obj.relationship_objs IS NOT NULL) AND
       (p_organization_obj.relationship_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_relationships(
        p_rel_objs                  => p_organization_obj.relationship_objs,
        p_subject_id                => x_organization_id,
        p_subject_type              => 'ORGANIZATION',
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Classification api
    ----------------------------
    IF((p_organization_obj.class_objs IS NOT NULL) AND
       (p_organization_obj.class_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_classifications(
        p_code_assign_objs          => p_organization_obj.class_objs,
        p_owner_table_name          => 'HZ_PARTIES',
        p_owner_table_id            => x_organization_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -----------------------------
    -- Create logical org contact
    -----------------------------
    IF((p_organization_obj.contact_objs IS NOT NULL) AND
       (p_organization_obj.contact_objs.COUNT > 0)) THEN
      HZ_ORG_CONTACT_BO_PVT.save_org_contacts(
        p_oc_objs            => p_organization_obj.contact_objs,
        p_create_update_flag => 'U',
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_org_id      => x_organization_id,
        p_parent_org_os      => x_organization_os,
        p_parent_org_osr     => x_organization_osr
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -----------------
    -- For Party Site
    -----------------
    IF((p_organization_obj.party_site_objs IS NOT NULL) AND
       (p_organization_obj.party_site_objs.COUNT > 0)) THEN
      HZ_PARTY_SITE_BO_PVT.save_party_sites(
        p_ps_objs            => p_organization_obj.party_site_objs,
        p_create_update_flag => 'U',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_id          => x_organization_id,
        p_parent_os          => x_organization_os,
        p_parent_osr         => x_organization_osr,
        p_parent_obj_type    => 'ORG'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ---------------------
    -- For Contact Points
    ---------------------
    IF(((p_organization_obj.phone_objs IS NOT NULL) AND (p_organization_obj.phone_objs.COUNT > 0)) OR
       ((p_organization_obj.telex_objs IS NOT NULL) AND (p_organization_obj.telex_objs.COUNT > 0)) OR
       ((p_organization_obj.email_objs IS NOT NULL) AND (p_organization_obj.email_objs.COUNT > 0)) OR
       ((p_organization_obj.web_objs IS NOT NULL) AND (p_organization_obj.web_objs.COUNT > 0)) OR
       ((p_organization_obj.edi_objs IS NOT NULL) AND (p_organization_obj.edi_objs.COUNT > 0)) OR
       ((p_organization_obj.eft_objs IS NOT NULL) AND (p_organization_obj.eft_objs.COUNT > 0))) THEN
      HZ_CONTACT_POINT_BO_PVT.save_contact_points(
        p_phone_objs         => p_organization_obj.phone_objs,
        p_telex_objs         => p_organization_obj.telex_objs,
        p_email_objs         => p_organization_obj.email_objs,
        p_web_objs           => p_organization_obj.web_objs,
        p_edi_objs           => p_organization_obj.edi_objs,
        p_eft_objs           => p_organization_obj.eft_objs,
        p_sms_objs           => l_sms_objs,
        p_owner_table_id     => x_organization_id,
        p_owner_table_os     => x_organization_os,
        p_owner_table_osr    => x_organization_osr,
        p_parent_obj_type    => 'ORG',
        p_create_update_flag => 'U',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ---------------------
    -- Certifications
    ---------------------
    IF((p_organization_obj.certification_objs IS NOT NULL) AND
       (p_organization_obj.certification_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_certifications(
        p_cert_objs          => p_organization_obj.certification_objs,
        p_party_id           => x_organization_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ---------------------
    -- Financial Profiles
    ---------------------
    IF((p_organization_obj.financial_prof_objs IS NOT NULL) AND
       (p_organization_obj.financial_prof_objs.COUNT > 0)) THEN
      HZ_PARTY_BO_PVT.save_financial_profiles(
        p_fin_prof_objs      => p_organization_obj.financial_prof_objs,
        p_party_id           => x_organization_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;


    ----------------------------------
  --  Party Usages -------
  ----------------------------------
   IF ((p_organization_obj.party_usage_objs IS NOT NULL) AND
      (p_organization_obj.party_usage_objs.COUNT > 0 )) THEN
       HZ_PARTY_BO_PVT.save_party_usage_assgmnt(
	   p_party_usg_objs				=> p_organization_obj.party_usage_objs,
	   p_party_id					=> x_organization_id,
	   x_return_status				=> x_return_status,
	   x_msg_count					=> x_msg_count,
	   x_msg_data					=> x_msg_data
	   );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;


    ----------------------------
    -- Credit Ratings
    ----------------------------
    IF((p_organization_obj.credit_rating_objs IS NOT NULL) AND
       (p_organization_obj.credit_rating_objs.COUNT > 0)) THEN
      save_credit_ratings(
        p_credit_rating_objs        => p_organization_obj.credit_rating_objs,
        p_organization_id           => x_organization_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    ----------------------------
    -- Financial Reports
    ----------------------------
    IF((p_organization_obj.financial_report_objs IS NOT NULL) AND
       (p_organization_obj.financial_report_objs.COUNT > 0)) THEN
      save_financial_reports(
        p_fin_objs                  => p_organization_obj.financial_report_objs,
        p_organization_id           => x_organization_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- raise update org event
    IF(l_org_raise_event) THEN
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_organization_id,
        p_bo_code          => 'ORG',
        p_create_or_update => 'U',
        p_obj_source       => p_obj_source,
        p_event_id         => l_org_event_id
      );
    END IF;

    -- raise update org cust event
    IF(l_oc_raise_event) THEN
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_organization_id,
        p_bo_code          => 'ORG_CUST',
        p_create_or_update => 'U',
        p_obj_source       => p_obj_source,
        p_event_id         => l_oc_event_id
      );
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_organization_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_organization_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO do_update_organization_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_organization_bo;

  PROCEDURE update_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  ) IS
    l_org_obj             HZ_ORGANIZATION_BO;
  BEGIN
    l_org_obj := p_organization_obj;
    do_update_organization_bo(
      p_init_msg_list       => p_init_msg_list,
      p_organization_obj    => l_org_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => NULL,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_organization_id     => x_organization_id,
      x_organization_os     => x_organization_os,
      x_organization_osr    => x_organization_osr
    );
  END update_organization_bo;

  PROCEDURE update_organization_bo(
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_org_obj             HZ_ORGANIZATION_BO;
  BEGIN
    l_org_obj := p_organization_obj;
    do_update_organization_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_organization_obj    => l_org_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_organization_id     => x_organization_id,
      x_organization_os     => x_organization_os,
      x_organization_osr    => x_organization_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_org_obj;
    END IF;
  END update_organization_bo;

  -- PROCEDURE do_save_organization_bo
  --
  -- DESCRIPTION
  --     Create or update organization business object.
  PROCEDURE do_save_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN OUT NOCOPY HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  ) IS
    l_return_status            VARCHAR2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_create_update_flag       VARCHAR2(1);
    l_debug_prefix             VARCHAR2(30);
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_organization_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_organization_id := p_organization_obj.organization_id;
    x_organization_os := p_organization_obj.orig_system;
    x_organization_osr:= p_organization_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => x_organization_id,
                              p_entity_os      => x_organization_os,
                              p_entity_osr     => x_organization_osr,
                              p_entity_type    => 'HZ_PARTIES',
                              p_parent_id      => NULL,
                              p_parent_obj_type=> NULL );

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'ORG');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_organization_bo(
        p_init_msg_list      => fnd_api.g_false,
        p_validate_bo_flag   => p_validate_bo_flag,
        p_organization_obj   => p_organization_obj,
        p_created_by_module  => p_created_by_module,
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        x_organization_id    => x_organization_id,
        x_organization_os    => x_organization_os,
        x_organization_osr   => x_organization_osr
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_organization_bo(
        p_init_msg_list      => fnd_api.g_false,
        p_organization_obj   => p_organization_obj,
        p_created_by_module  => p_created_by_module,
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        x_organization_id    => x_organization_id,
        x_organization_os    => x_organization_os,
        x_organization_osr   => x_organization_osr
      );
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_organization_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_organization_bo;

  PROCEDURE save_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  ) IS
    l_org_obj             HZ_ORGANIZATION_BO;
  BEGIN
    l_org_obj := p_organization_obj;
    do_save_organization_bo(
      p_init_msg_list       => p_init_msg_list,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_organization_obj    => l_org_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_organization_id     => x_organization_id,
      x_organization_os     => x_organization_os,
      x_organization_osr    => x_organization_osr
    );
  END save_organization_bo;

  PROCEDURE save_organization_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_organization_obj    IN            HZ_ORGANIZATION_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_organization_id     OUT NOCOPY    NUMBER,
    x_organization_os     OUT NOCOPY    VARCHAR2,
    x_organization_osr    OUT NOCOPY    VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_org_obj             HZ_ORGANIZATION_BO;
  BEGIN
    l_org_obj := p_organization_obj;
    do_save_organization_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_organization_obj    => l_org_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_organization_id     => x_organization_id,
      x_organization_os     => x_organization_os,
      x_organization_osr    => x_organization_osr
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_org_obj;
    END IF;
  END save_organization_bo;

 --------------------------------------
  --
  -- PROCEDURE get_organization_bo
  --
  -- DESCRIPTION
  --     Get a logical organization.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to   FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_organization_id          Organization ID.
 --     p_person_os           Org orig system.
  --     p_person_osr         Org orig system reference.
  --   OUT:
  --     x_organization_obj         Logical organization record.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --
  --   06-JUN-2005   AWU                Created.
  --

/*
The Get Organization API Procedure is a retrieval service that returns a full Organization business object.
The user identifies a particular Organization business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Organization business object is returned. The object consists of all data included within
the Organization business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Organization business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Org Contact	N	Y	get_contact_bo
Party Site	N	Y	get_party_site_bo
Phone	N	Y	get_phone_bo
Telex	N	Y	get_telex_bo
Email	N	Y	get_email_bo
Web	N	Y	get_web_bo
EDI	N	Y	get_edi_bo
EFT	N	Y	get_eft_bo
Financial Report	N	Y		Business Structure. Included entities: HZ_FINANCIAL_REPORTS, HZ_FINANCIAL_NUMBERS


To retrieve the appropriate embedded entities within the Organization business object,
the Get procedure returns all records for the particular organization from these TCA entity tables:

Embedded TCA Entity	Mandatory    Multiple	TCA Table Entities

Party, Org Profile	Y		N	HZ_PARTIES, HZ_ORGANIZATION_PROFILES
Org Preference		N		Y	HZ_PARTY_PREFERENCES
Relationship		N		Y	HZ_RELATIONSHIPS
Classification		N		Y	HZ_CODE_ASSIGNMENTS
Credit Rating		N		Y	HZ_CREDIT_RATINGS
Certification		N		Y	HZ_CERTIFICATIONS
Financial Profile	N		Y	HZ_FINANCIAL_PROFILE

*/


 PROCEDURE get_organization_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_id           IN            NUMBER,
    p_organization_os		IN	VARCHAR2,
    p_organization_osr		IN	VARCHAR2,
    x_organization_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_organization_id  number;
  l_organization_os  varchar2(30);
  l_organization_osr varchar2(255);
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organization_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_organization_id := p_organization_id;
    	l_organization_os := p_organization_os;
    	l_organization_osr := p_organization_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_organization_id,
      		px_os              => l_organization_os,
      		px_osr             => l_organization_osr,
      		p_obj_type         => 'ORGANIZATION',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_ORGANIZATION_BO_PVT.get_organization_bo(
    		p_init_msg_list   => fnd_api.g_false,
    		p_organization_id => l_organization_id,
    		p_action_type	  => NULL,
    		x_organization_obj => x_organization_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organization_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organization_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organization_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organization_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

 PROCEDURE get_organization_bo(
    p_organization_id           IN            NUMBER,
    p_organization_os           IN      VARCHAR2,
    p_organization_osr          IN      VARCHAR2,
    x_organization_obj          OUT NOCOPY    HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_organization_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_organization_id     => p_organization_id,
      p_organization_os     => p_organization_os,
      p_organization_osr    => p_organization_osr,
      x_organization_obj    => x_organization_obj,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_organization_bo;

 --------------------------------------
  --
  -- PROCEDURE get_organizations_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations created business event and
  --the procedure returns database objects of the type HZ_ORGANIZATION_BO for all of
  --the Organization business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   06-JUN-2005    AWU                Created.
  --



/*
The Get Organizations Created procedure is a service to retrieve all of the Organization business objects
whose creations have been captured by a logical business event. Each Organizations Created
business event signifies that one or more Organization business objects have been created.
The caller provides an identifier for the Organizations Created business event and the procedure
returns all of the Organization business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_ORGANIZATION_BO_PVT.get_organization_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_organizations_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_organization_objs         OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
l_debug_prefix              VARCHAR2(30) := '';
begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organizations_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'C',
			    p_bo_code => 'ORG',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_ORGANIZATION_BO_PVT.get_organizations_created(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		x_organization_objs  => x_organization_objs,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;



	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organizations_created (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organizations_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organizations_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organizations_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_organizations_created(
    p_event_id            IN            NUMBER,
    x_organization_objs   OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) is
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_organizations_created(
      p_init_msg_list       => fnd_api.g_true,
      p_event_id            => p_event_id,
      x_organization_objs   => x_organization_objs,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_organizations_created;



--------------------------------------
  --
  -- PROCEDURE get_organizations_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations update business event and
  --the procedure returns database objects of the type HZ_ORGANIZATION_BO for all of
  --the Organization business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   06-JUN-2005     AWU                Created.
  --



/*
The Get Organizations Updated procedure is a service to retrieve all of the Organization business objects
whose updates have been captured by the logical business event. Each Organizations Updated business event
signifies that one or more Organization business objects have been updated.
The caller provides an identifier for the Organizations Update business event and the procedure returns
database objects of the type HZ_ORGANIZATION_BO for all of the Organization business objects from the
business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table
structure and returns them to the caller.
*/

 PROCEDURE get_organizations_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_organization_objs         OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

l_debug_prefix              VARCHAR2(30) := '';
begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organizations_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'U',
			    p_bo_code => 'ORG',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_ORGANIZATION_BO_PVT.get_organizations_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		x_organization_objs  => x_organization_objs,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;



	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organizations_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_organizations_updated(
    p_event_id            IN            NUMBER,
    x_organization_objs   OUT NOCOPY    HZ_ORGANIZATION_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_organizations_updated(
      p_init_msg_list       => fnd_api.g_true,
      p_event_id            => p_event_id,
      x_organization_objs   => x_organization_objs,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_organizations_updated;



--------------------------------------
  --
  -- PROCEDURE get_organization_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Organizations update business event and organization id
  --the procedure returns one database object of the type HZ_ORGANIZATION_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_organization_objs        One or more created logical organization.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   06-JUN-2005     AWU                Created.
  --

PROCEDURE get_organization_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_organization_id     IN           NUMBER,
    x_organization_obj    OUT NOCOPY   HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  )  is
l_debug_prefix              VARCHAR2(30) := '';
begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organization_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => p_organization_id,
			    p_event_type => 'U',
			    p_bo_code => 'ORG',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_ORGANIZATION_BO_PVT.get_organization_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
		p_organization_id  => p_organization_id,
    		x_organization_obj  => x_organization_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;



	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organization_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organization_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organization_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_organization_bo_pub.get_organization_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_organization_updated(
    p_event_id            IN            NUMBER,
    p_organization_id     IN           NUMBER,
    x_organization_obj    OUT NOCOPY   HZ_ORGANIZATION_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_organization_updated(
      p_init_msg_list       => fnd_api.g_true,
      p_event_id            => p_event_id,
      p_organization_id     => p_organization_id,
      x_organization_obj    => x_organization_obj,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_organization_updated;



-- get TCA identifiers for create event
PROCEDURE get_ids_organizations_created (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_organization_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
  	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2

) is
l_debug_prefix              VARCHAR2(30) := '';

begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_ids_organizations_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'C',
			    p_bo_code => 'ORG',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => x_organization_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_ids_organizations_created (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_organizations_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_organizations_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_organizations_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


-- get TCA identifiers for update event
PROCEDURE get_ids_organizations_updated (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_organization_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
  	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
) is
l_debug_prefix              VARCHAR2(30) := '';

begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_ids_organizations_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'U',
			    p_bo_code => 'ORG',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => x_organization_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_ids_organizations_updated (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_ids_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;




END hz_organization_bo_pub;

/
