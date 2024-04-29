--------------------------------------------------------
--  DDL for Package Body HZ_ORGANIZATION_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORGANIZATION_PROFILES_PKG" AS
/*$Header: ARHORGTB.pls 120.6 2005/07/26 18:59:40 jhuang ship $ */

g_miss_content_source_type              CONSTANT VARCHAR2(30) := 'USER_ENTERED';
g_sst_source_type                       CONSTANT VARCHAR2(30) := 'SST';

  FUNCTION do_copy_duns_number(
    p_duns_number_c                     IN     VARCHAR2
  ) RETURN NUMBER IS

    l_char                              VARCHAR2(1);
    l_str                               HZ_ORGANIZATION_PROFILES.DUNS_NUMBER_C%TYPE;

  BEGIN

    -- if duns_number is null and duns_number_c is not null then get the
    -- value of duns_number_c, convert it to number and copy it to duns_number

 /* Bug 3435702.This check is done before calling this procedure and as such is redundant.
  |
  |  IF p_duns_number_c IS NOT NULL AND
  |     p_duns_number_c <> FND_API.G_MISS_CHAR
  |  THEN
  */
      FOR i IN 1..LENGTHB(p_duns_number_c) LOOP
        l_char := SUBSTRB(p_duns_number_c, i, 1);
        IF (l_char >= '0' AND l_char <= '9') THEN
          l_str  :=  l_str || l_char;
        END IF;
      END LOOP;
      RETURN TO_NUMBER(l_str);
   /* END IF;*/

    RETURN NULL;

  END do_copy_duns_number;


  PROCEDURE insert_row (
    x_rowid                             OUT NOCOPY    ROWID,
    x_organization_profile_id           IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_organization_name                 IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_enquiry_duns                      IN     VARCHAR2,
    x_ceo_name                          IN     VARCHAR2,
    x_ceo_title                         IN     VARCHAR2,
    x_principal_name                    IN     VARCHAR2,
    x_principal_title                   IN     VARCHAR2,
    x_legal_status                      IN     VARCHAR2,
    x_control_yr                        IN     NUMBER,
    x_employees_total                   IN     NUMBER,
    x_hq_branch_ind                     IN     VARCHAR2,
    x_branch_flag                       IN     VARCHAR2,
    x_oob_ind                           IN     VARCHAR2,
    x_line_of_business                  IN     VARCHAR2,
    x_cong_dist_code                    IN     VARCHAR2,
    x_sic_code                          IN     VARCHAR2,
    x_import_ind                        IN     VARCHAR2,
    x_export_ind                        IN     VARCHAR2,
    x_labor_surplus_ind                 IN     VARCHAR2,
    x_debarment_ind                     IN     VARCHAR2,
    x_minority_owned_ind                IN     VARCHAR2,
    x_minority_owned_type               IN     VARCHAR2,
    x_woman_owned_ind                   IN     VARCHAR2,
    x_disadv_8a_ind                     IN     VARCHAR2,
    x_small_bus_ind                     IN     VARCHAR2,
    x_rent_own_ind                      IN     VARCHAR2,
    x_debarments_count                  IN     NUMBER,
    x_debarments_date                   IN     DATE,
    x_failure_score                     IN     VARCHAR2,
    x_failure_score_override_code       IN     VARCHAR2,
    x_failure_score_commentary          IN     VARCHAR2,
    x_global_failure_score              IN     VARCHAR2,
    x_db_rating                         IN     VARCHAR2,
    x_credit_score                      IN     VARCHAR2,
    x_credit_score_commentary           IN     VARCHAR2,
    x_paydex_score                      IN     VARCHAR2,
    x_paydex_three_months_ago           IN     VARCHAR2,
    x_paydex_norm                       IN     VARCHAR2,
    x_best_time_contact_begin           IN     DATE,
    x_best_time_contact_end             IN     DATE,
    x_organization_name_phonetic        IN     VARCHAR2,
    x_tax_reference                     IN     VARCHAR2,
    x_gsa_indicator_flag                IN     VARCHAR2,
    x_jgzz_fiscal_code                  IN     VARCHAR2,
    x_analysis_fy                       IN     VARCHAR2,
    x_fiscal_yearend_month              IN     VARCHAR2,
    x_curr_fy_potential_revenue         IN     NUMBER,
    x_next_fy_potential_revenue         IN     NUMBER,
    x_year_established                  IN     NUMBER,
    x_mission_statement                 IN     VARCHAR2,
    x_organization_type                 IN     VARCHAR2,
    x_business_scope                    IN     VARCHAR2,
    x_corporation_class                 IN     VARCHAR2,
    x_known_as                          IN     VARCHAR2,
    x_local_bus_iden_type               IN     VARCHAR2,
    x_local_bus_identifier              IN     VARCHAR2,
    x_pref_functional_currency          IN     VARCHAR2,
    x_registration_type                 IN     VARCHAR2,
    x_total_employees_text              IN     VARCHAR2,
    x_total_employees_ind               IN     VARCHAR2,
    x_total_emp_est_ind                 IN     VARCHAR2,
    x_total_emp_min_ind                 IN     VARCHAR2,
    x_parent_sub_ind                    IN     VARCHAR2,
    x_incorp_year                       IN     NUMBER,
    x_content_source_type               IN     VARCHAR2,
    x_content_source_number             IN     VARCHAR2,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_sic_code_type                     IN     VARCHAR2,
    x_public_private_ownership          IN     VARCHAR2,
    x_local_activity_code_type          IN     VARCHAR2,
    x_local_activity_code               IN     VARCHAR2,
    x_emp_at_primary_adr                IN     VARCHAR2,
    x_emp_at_primary_adr_text           IN     VARCHAR2,
    x_emp_at_primary_adr_est_ind        IN     VARCHAR2,
    x_emp_at_primary_adr_min_ind        IN     VARCHAR2,
    x_internal_flag                     IN     VARCHAR2,
    x_high_credit                       IN     NUMBER,
    x_avg_high_credit                   IN     NUMBER,
    x_total_payments                    IN     NUMBER,
    x_known_as2                         IN     VARCHAR2,
    x_known_as3                         IN     VARCHAR2,
    x_known_as4                         IN     VARCHAR2,
    x_known_as5                         IN     VARCHAR2,
    x_credit_score_class                IN     NUMBER,
    x_credit_score_natl_percentile      IN     NUMBER,
    x_credit_score_incd_default         IN     NUMBER,
    x_credit_score_age                  IN     NUMBER,
    x_credit_score_date                 IN     DATE,
    x_failure_score_class               IN     NUMBER,
    x_failure_score_incd_default        IN     NUMBER,
    x_failure_score_age                 IN     NUMBER,
    x_failure_score_date                IN     DATE,
    x_failure_score_commentary2         IN     VARCHAR2,
    x_failure_score_commentary3         IN     VARCHAR2,
    x_failure_score_commentary4         IN     VARCHAR2,
    x_failure_score_commentary5         IN     VARCHAR2,
    x_failure_score_commentary6         IN     VARCHAR2,
    x_failure_score_commentary7         IN     VARCHAR2,
    x_failure_score_commentary8         IN     VARCHAR2,
    x_failure_score_commentary9         IN     VARCHAR2,
    x_failure_score_commentary10        IN     VARCHAR2,
    x_credit_score_commentary2          IN     VARCHAR2,
    x_credit_score_commentary3          IN     VARCHAR2,
    x_credit_score_commentary4          IN     VARCHAR2,
    x_credit_score_commentary5          IN     VARCHAR2,
    x_credit_score_commentary6          IN     VARCHAR2,
    x_credit_score_commentary7          IN     VARCHAR2,
    x_credit_score_commentary8          IN     VARCHAR2,
    x_credit_score_commentary9          IN     VARCHAR2,
    x_credit_score_commentary10         IN     VARCHAR2,
    x_maximum_credit_recomm             IN     NUMBER,
    x_maximum_credit_currency_code      IN     VARCHAR2,
    x_displayed_duns_party_id           IN     NUMBER,
    x_failure_score_natnl_perc          IN     NUMBER,
    x_duns_number_c                     IN     VARCHAR2,
    x_bank_or_branch_number             IN     VARCHAR2 := fnd_api.g_miss_char,
    x_bank_code                         IN     VARCHAR2 := fnd_api.g_miss_char,
    x_branch_code                       IN     VARCHAR2 := fnd_api.g_miss_char,
    x_object_version_number             IN     NUMBER,
    x_created_by_module                 IN     VARCHAR2,
    x_application_id                    IN     NUMBER,
    x_do_not_confuse_with               IN     VARCHAR2 := NULL,
    x_actual_content_source             IN     VARCHAR2,
    x_version_number                    IN     NUMBER DEFAULT 1,
    x_home_country                      IN     VARCHAR2 DEFAULT NULL
  ) IS

    l_duns_number                       NUMBER;
    l_success                           VARCHAR2(1) := 'N';
     l_duns_number_c                         HZ_PARTIES.duns_number_c%type := X_DUNS_NUMBER_C;
BEGIN

    IF x_duns_number_c IS NOT NULL AND
       x_duns_number_c <> FND_API.G_MISS_CHAR
    THEN
      l_duns_number := do_copy_duns_number(x_duns_number_c);
    END IF;

   IF x_duns_number_c IS NOT NULL AND
      x_duns_number_c <> FND_API.G_MISS_CHAR AND
      LENGTHB(x_duns_number_c)<9
   THEN
      l_duns_number_c:=lpad(x_duns_number_c,9,'0');
   END IF;


    WHILE l_success = 'N' LOOP
      BEGIN
        INSERT INTO hz_organization_profiles (
          organization_profile_id,
          party_id,
          organization_name,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          enquiry_duns,
          ceo_name,
          ceo_title,
          principal_name,
          principal_title,
          legal_status,
          control_yr,
          employees_total,
          hq_branch_ind,
          branch_flag,
          oob_ind,
          line_of_business,
          cong_dist_code,
          sic_code,
          import_ind,
          export_ind,
          labor_surplus_ind,
          debarment_ind,
          minority_owned_ind,
          minority_owned_type,
          woman_owned_ind,
          disadv_8a_ind,
          small_bus_ind,
          rent_own_ind,
          debarments_count,
          debarments_date,
          failure_score,
          failure_score_override_code,
          failure_score_commentary,
          global_failure_score,
          db_rating,
          credit_score,
          credit_score_commentary,
          paydex_score,
          paydex_three_months_ago,
          paydex_norm,
          best_time_contact_begin,
          best_time_contact_end,
          organization_name_phonetic,
          tax_reference,
          gsa_indicator_flag,
          jgzz_fiscal_code,
          analysis_fy,
          fiscal_yearend_month,
          curr_fy_potential_revenue,
          next_fy_potential_revenue,
          year_established,
          mission_statement,
          organization_type,
          business_scope,
          corporation_class,
          known_as,
          local_bus_iden_type,
          local_bus_identifier,
          pref_functional_currency,
          registration_type,
          total_employees_text,
          total_employees_ind,
          total_emp_est_ind,
          total_emp_min_ind,
          parent_sub_ind,
          incorp_year,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          content_source_type,
          content_source_number,
          effective_start_date,
          effective_end_date,
          sic_code_type,
          public_private_ownership_flag,
          local_activity_code_type,
          local_activity_code,
          emp_at_primary_adr,
          emp_at_primary_adr_text,
          emp_at_primary_adr_est_ind,
          emp_at_primary_adr_min_ind,
          internal_flag,
          high_credit,
          avg_high_credit,
          total_payments,
          known_as2,
          known_as3,
          known_as4,
          known_as5,
          credit_score_class,
          credit_score_natl_percentile,
          credit_score_incd_default,
          credit_score_age,
          credit_score_date,
          failure_score_class,
          failure_score_incd_default,
          failure_score_age,
          failure_score_date,
          failure_score_commentary2,
          failure_score_commentary3,
          failure_score_commentary4,
          failure_score_commentary5,
          failure_score_commentary6,
          failure_score_commentary7,
          failure_score_commentary8,
          failure_score_commentary9,
          failure_score_commentary10,
          credit_score_commentary2,
          credit_score_commentary3,
          credit_score_commentary4,
          credit_score_commentary5,
          credit_score_commentary6,
          credit_score_commentary7,
          credit_score_commentary8,
          credit_score_commentary9,
          credit_score_commentary10,
          maximum_credit_recommendation,
          maximum_credit_currency_code,
          displayed_duns_party_id,
          failure_score_natnl_percentile,
          duns_number_c,
          duns_number,
          bank_or_branch_number,
          bank_code,
          branch_code,
          object_version_number,
          created_by_module,
          application_id,
          do_not_confuse_with,
          actual_content_source,
          version_number,
          home_country
        )
        VALUES (
          DECODE(x_organization_profile_id,
                 fnd_api.g_miss_num, hz_organization_profiles_s.NEXTVAL,
                 NULL, hz_organization_profiles_s.NEXTVAL,
                 x_organization_profile_id),
          DECODE(x_party_id, fnd_api.g_miss_num, NULL, x_party_id),
          DECODE(x_organization_name,
                 fnd_api.g_miss_char, NULL,
                 x_organization_name),
          DECODE(x_attribute_category,
                 fnd_api.g_miss_char, NULL,
                 x_attribute_category),
          DECODE(x_attribute1, fnd_api.g_miss_char, NULL, x_attribute1),
          DECODE(x_attribute2, fnd_api.g_miss_char, NULL, x_attribute2),
          DECODE(x_attribute3, fnd_api.g_miss_char, NULL, x_attribute3),
          DECODE(x_attribute4, fnd_api.g_miss_char, NULL, x_attribute4),
          DECODE(x_attribute5, fnd_api.g_miss_char, NULL, x_attribute5),
          DECODE(x_attribute6, fnd_api.g_miss_char, NULL, x_attribute6),
          DECODE(x_attribute7, fnd_api.g_miss_char, NULL, x_attribute7),
          DECODE(x_attribute8, fnd_api.g_miss_char, NULL, x_attribute8),
          DECODE(x_attribute9, fnd_api.g_miss_char, NULL, x_attribute9),
          DECODE(x_attribute10, fnd_api.g_miss_char, NULL, x_attribute10),
          DECODE(x_attribute11, fnd_api.g_miss_char, NULL, x_attribute11),
          DECODE(x_attribute12, fnd_api.g_miss_char, NULL, x_attribute12),
          DECODE(x_attribute13, fnd_api.g_miss_char, NULL, x_attribute13),
          DECODE(x_attribute14, fnd_api.g_miss_char, NULL, x_attribute14),
          DECODE(x_attribute15, fnd_api.g_miss_char, NULL, x_attribute15),
          DECODE(x_attribute16, fnd_api.g_miss_char, NULL, x_attribute16),
          DECODE(x_attribute17, fnd_api.g_miss_char, NULL, x_attribute17),
          DECODE(x_attribute18, fnd_api.g_miss_char, NULL, x_attribute18),
          DECODE(x_attribute19, fnd_api.g_miss_char, NULL, x_attribute19),
          DECODE(x_attribute20, fnd_api.g_miss_char, NULL, x_attribute20),
          DECODE(x_enquiry_duns, fnd_api.g_miss_char, NULL, x_enquiry_duns),
          DECODE(x_ceo_name, fnd_api.g_miss_char, NULL, x_ceo_name),
          DECODE(x_ceo_title, fnd_api.g_miss_char, NULL, x_ceo_title),
          DECODE(x_principal_name,
                 fnd_api.g_miss_char, NULL,
                 x_principal_name),
          DECODE(x_principal_title,
                 fnd_api.g_miss_char, NULL,
                 x_principal_title),
          DECODE(x_legal_status, fnd_api.g_miss_char, NULL, x_legal_status),
          DECODE(x_control_yr, fnd_api.g_miss_num, NULL, x_control_yr),
          DECODE(x_employees_total,
                 fnd_api.g_miss_num, NULL,
                 x_employees_total),
          DECODE(x_hq_branch_ind, fnd_api.g_miss_char, NULL, x_hq_branch_ind),
          DECODE(x_branch_flag, fnd_api.g_miss_char, NULL, x_branch_flag),
          DECODE(x_oob_ind, fnd_api.g_miss_char, NULL, x_oob_ind),
          DECODE(x_line_of_business,
                 fnd_api.g_miss_char, NULL,
                 x_line_of_business),
          DECODE(x_cong_dist_code,
                 fnd_api.g_miss_char, NULL,
                 x_cong_dist_code),
          DECODE(x_sic_code, fnd_api.g_miss_char, NULL, x_sic_code),
          DECODE(x_import_ind, fnd_api.g_miss_char, NULL, x_import_ind),
          DECODE(x_export_ind, fnd_api.g_miss_char, NULL, x_export_ind),
          DECODE(x_labor_surplus_ind,
                 fnd_api.g_miss_char, NULL,
                 x_labor_surplus_ind),
          DECODE(x_debarment_ind, fnd_api.g_miss_char, NULL, x_debarment_ind),
          DECODE(x_minority_owned_ind,
                 fnd_api.g_miss_char, NULL,
                 x_minority_owned_ind),
          DECODE(x_minority_owned_type,
                 fnd_api.g_miss_char, NULL,
                 x_minority_owned_type),
          DECODE(x_woman_owned_ind,
                 fnd_api.g_miss_char, NULL,
                 x_woman_owned_ind),
          DECODE(x_disadv_8a_ind, fnd_api.g_miss_char, NULL, x_disadv_8a_ind),
          DECODE(x_small_bus_ind, fnd_api.g_miss_char, NULL, x_small_bus_ind),
          DECODE(x_rent_own_ind, fnd_api.g_miss_char, NULL, x_rent_own_ind),
          DECODE(x_debarments_count,
                 fnd_api.g_miss_num, NULL,
                 x_debarments_count),
          DECODE(x_debarments_date,
                 fnd_api.g_miss_date, to_date(NULL),
                 x_debarments_date),
          DECODE(x_failure_score, fnd_api.g_miss_char, NULL, x_failure_score),
          DECODE(x_failure_score_override_code,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_override_code),
          DECODE(x_failure_score_commentary,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_commentary),
          DECODE(x_global_failure_score,
                 fnd_api.g_miss_char, NULL,
                 x_global_failure_score),
          DECODE(x_db_rating, fnd_api.g_miss_char, NULL, x_db_rating),
          DECODE(x_credit_score, fnd_api.g_miss_char, NULL, x_credit_score),
          DECODE(x_credit_score_commentary,
                 fnd_api.g_miss_char, NULL,
                 x_credit_score_commentary),
          DECODE(x_paydex_score,
                 fnd_api.g_miss_char, NULL,
                 x_paydex_score),
          DECODE(x_paydex_three_months_ago,
                 fnd_api.g_miss_char, NULL,
                 x_paydex_three_months_ago),
          DECODE(x_paydex_norm, fnd_api.g_miss_char, NULL, x_paydex_norm),
          DECODE(x_best_time_contact_begin,
                 fnd_api.g_miss_date, TO_DATE(NULL),
                 x_best_time_contact_begin),
          DECODE(x_best_time_contact_end,
                 fnd_api.g_miss_date, TO_DATE(NULL),
                 x_best_time_contact_end),
          DECODE(x_organization_name_phonetic,
                 fnd_api.g_miss_char, NULL,
                 x_organization_name_phonetic),
          DECODE(x_tax_reference, fnd_api.g_miss_char, NULL, x_tax_reference),
          DECODE(x_gsa_indicator_flag,
                 fnd_api.g_miss_char, NULL,
                 x_gsa_indicator_flag),
          DECODE(x_jgzz_fiscal_code,
                 fnd_api.g_miss_char, NULL,
                 x_jgzz_fiscal_code),
          DECODE(x_analysis_fy, fnd_api.g_miss_char, NULL, x_analysis_fy),
          DECODE(x_fiscal_yearend_month,
                 fnd_api.g_miss_char, NULL,
                 x_fiscal_yearend_month),
          DECODE(x_curr_fy_potential_revenue,
                 fnd_api.g_miss_num, NULL,
                 x_curr_fy_potential_revenue),
          DECODE(x_next_fy_potential_revenue,
                 fnd_api.g_miss_num, NULL,
                 x_next_fy_potential_revenue),
          DECODE(x_year_established,
                 fnd_api.g_miss_num, NULL,
                 x_year_established),
          DECODE(x_mission_statement,
                 fnd_api.g_miss_char, NULL,
                 x_mission_statement),
          DECODE(x_organization_type,
                 fnd_api.g_miss_char, NULL,
                 x_organization_type),
          DECODE(x_business_scope,
                 fnd_api.g_miss_char, NULL,
                 x_business_scope),
          DECODE(x_corporation_class,
                 fnd_api.g_miss_char, NULL,
                 x_corporation_class),
          DECODE(x_known_as, fnd_api.g_miss_char, NULL, x_known_as),
          DECODE(x_local_bus_iden_type,
                 fnd_api.g_miss_char, NULL,
                 x_local_bus_iden_type),
          DECODE(x_local_bus_identifier,
                 fnd_api.g_miss_char, NULL,
                 x_local_bus_identifier),
          DECODE(x_pref_functional_currency,
                 fnd_api.g_miss_char, NULL,
                 x_pref_functional_currency),
          DECODE(x_registration_type,
                 fnd_api.g_miss_char, NULL,
                 x_registration_type),
          DECODE(x_total_employees_text,
                 fnd_api.g_miss_char, NULL,
                 x_total_employees_text),
          DECODE(x_total_employees_ind,
                 fnd_api.g_miss_char, NULL,
                 x_total_employees_ind),
          DECODE(x_total_emp_est_ind,
                 fnd_api.g_miss_char, NULL,
                 x_total_emp_est_ind),
          DECODE(x_total_emp_min_ind,
                 fnd_api.g_miss_char, NULL,
                 x_total_emp_min_ind),
          DECODE(x_parent_sub_ind,
                 fnd_api.g_miss_char, NULL,
                 x_parent_sub_ind),
          DECODE(x_incorp_year, fnd_api.g_miss_num, NULL, x_incorp_year),
          hz_utility_v2pub.last_update_date,
          hz_utility_v2pub.last_updated_by,
          hz_utility_v2pub.creation_date,
          hz_utility_v2pub.created_by,
          hz_utility_v2pub.last_update_login,
          hz_utility_v2pub.request_id,
          hz_utility_v2pub.program_application_id,
          hz_utility_v2pub.program_id,
          hz_utility_v2pub.program_update_date,
          DECODE(x_content_source_type,
                 fnd_api.g_miss_char, g_miss_content_source_type,
                 NULL, g_miss_content_source_type,
                 x_content_source_type),
          DECODE(x_content_source_number,
                 fnd_api.g_miss_char, NULL,
                 x_content_source_number),
          DECODE(x_effective_start_date,
                 fnd_api.g_miss_date, TRUNC(hz_utility_v2pub.creation_date),
                 NULL, TRUNC(hz_utility_v2pub.creation_date),
                 x_effective_start_date),
          DECODE(x_effective_end_date,
                 fnd_api.g_miss_date, TO_DATE(NULL),
                 x_effective_end_date),
          DECODE(x_sic_code_type, fnd_api.g_miss_char, NULL, x_sic_code_type),
          DECODE(x_public_private_ownership,
                 fnd_api.g_miss_char, NULL,
                 x_public_private_ownership),
          DECODE(x_local_activity_code_type,
                 fnd_api.g_miss_char, NULL,
                 x_local_activity_code_type),
          DECODE(x_local_activity_code,
                 fnd_api.g_miss_char, NULL,
                 x_local_activity_code),
          DECODE(x_emp_at_primary_adr,
                 fnd_api.g_miss_char, NULL,
                 x_emp_at_primary_adr),
          DECODE(x_emp_at_primary_adr_text,
                 fnd_api.g_miss_char, NULL,
                 x_emp_at_primary_adr_text),
          DECODE(x_emp_at_primary_adr_est_ind,
                 fnd_api.g_miss_char, NULL,
                 x_emp_at_primary_adr_est_ind),
          DECODE(x_emp_at_primary_adr_min_ind,
                 fnd_api.g_miss_char, NULL,
                 x_emp_at_primary_adr_min_ind),
          DECODE(x_internal_flag,
                 fnd_api.g_miss_char, 'N',
                 NULL, 'N',
                 x_internal_flag),
          DECODE(x_high_credit,
                 fnd_api.g_miss_num, NULL,
                 x_high_credit),
          DECODE(x_avg_high_credit,
                 fnd_api.g_miss_num, NULL,
                 x_avg_high_credit),
          DECODE(x_total_payments,
                 fnd_api.g_miss_num, NULL, x_total_payments),
          DECODE(x_known_as2, fnd_api.g_miss_char, NULL, x_known_as2),
          DECODE(x_known_as3, fnd_api.g_miss_char, NULL, x_known_as3),
          DECODE(x_known_as4, fnd_api.g_miss_char, NULL, x_known_as4),
          DECODE(x_known_as5, fnd_api.g_miss_char, NULL, x_known_as5),
          DECODE(x_credit_score_class,
                 fnd_api.g_miss_num, NULL,
                 x_credit_score_class),
          DECODE(x_credit_score_natl_percentile,
                 fnd_api.g_miss_num, NULL,
                 x_credit_score_natl_percentile),
          DECODE(x_credit_score_incd_default,
                 fnd_api.g_miss_num, NULL,
                 x_credit_score_incd_default),
          DECODE(x_credit_score_age,
                 fnd_api.g_miss_num, NULL,
                 x_credit_score_age),
          DECODE(x_credit_score_date,
                  fnd_api.g_miss_date, TO_DATE(NULL), x_credit_score_date),
          DECODE(x_failure_score_class,
                 fnd_api.g_miss_num, NULL,
                 x_failure_score_class),
          DECODE(x_failure_score_incd_default,
                 fnd_api.g_miss_num, NULL,
                 x_failure_score_incd_default),
          DECODE(x_failure_score_age,
                 fnd_api.g_miss_num, NULL,
                 x_failure_score_age),
          DECODE(x_failure_score_date,
                  fnd_api.g_miss_date, TO_DATE(NULL), x_failure_score_date),
          DECODE(x_failure_score_commentary2,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_commentary2),
          DECODE(x_failure_score_commentary3,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_commentary3),
          DECODE(x_failure_score_commentary4,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_commentary4),
          DECODE(x_failure_score_commentary5,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_commentary5),
          DECODE(x_failure_score_commentary6,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_commentary6),
          DECODE(x_failure_score_commentary7,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_commentary7),
          DECODE(x_failure_score_commentary8,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_commentary8),
          DECODE(x_failure_score_commentary9,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_commentary9),
          DECODE(x_failure_score_commentary10,
                 fnd_api.g_miss_char, NULL,
                 x_failure_score_commentary10),
          DECODE(x_credit_score_commentary2,
                 fnd_api.g_miss_char, NULL,
                 x_credit_score_commentary2),
          DECODE(x_credit_score_commentary3,
                 fnd_api.g_miss_char, NULL,
                 x_credit_score_commentary3),
          DECODE(x_credit_score_commentary4,
                 fnd_api.g_miss_char, NULL,
                 x_credit_score_commentary4),
          DECODE(x_credit_score_commentary5,
                 fnd_api.g_miss_char, NULL,
                 x_credit_score_commentary5),
          DECODE(x_credit_score_commentary6,
                 fnd_api.g_miss_char, NULL,
                 x_credit_score_commentary6),
          DECODE(x_credit_score_commentary7,
                 fnd_api.g_miss_char, NULL,
                 x_credit_score_commentary7),
          DECODE(x_credit_score_commentary8,
                 fnd_api.g_miss_char, NULL,
                 x_credit_score_commentary8),
          DECODE(x_credit_score_commentary9,
                 fnd_api.g_miss_char, NULL,
                 x_credit_score_commentary9),
          DECODE(x_credit_score_commentary10,
                 fnd_api.g_miss_char, NULL,
                 x_credit_score_commentary10),
          DECODE(x_maximum_credit_recomm,
                 fnd_api.g_miss_num, NULL,
                 x_maximum_credit_recomm),
          DECODE(x_maximum_credit_currency_code,
                 fnd_api.g_miss_char, NULL,
                 x_maximum_credit_currency_code),
          DECODE(x_displayed_duns_party_id,
                 fnd_api.g_miss_num, NULL,
                 x_displayed_duns_party_id),
          DECODE(x_failure_score_natnl_perc,
                 fnd_api.g_miss_num, NULL,
                 x_failure_score_natnl_perc),
          DECODE(x_duns_number_c, fnd_api.g_miss_char, NULL,/*Bug 3435702*/ UPPER(l_duns_number_c)),
          /* Bug 3435702.This is not necessary because if x_duns_number_c is null or
          fnd_api.g_miss_char , then l_duns_number will be NULL.
          DECODE(x_duns_number_c, fnd_api.g_miss_char,
                 NULL, NULL, NULL, l_duns_number),*/
          l_duns_number,
          DECODE(x_bank_or_branch_number,
                 fnd_api.g_miss_char, NULL,
                 x_bank_or_branch_number),
          DECODE(x_bank_code, fnd_api.g_miss_char, NULL, x_bank_code),
          DECODE(x_branch_code, fnd_api.g_miss_char, NULL, x_branch_code),
          DECODE(x_object_version_number,
                 fnd_api.g_miss_num, NULL,
                 x_object_version_number),
          DECODE(x_created_by_module,
                 fnd_api.g_miss_char, NULL,
                 x_created_by_module),
          DECODE(x_application_id, fnd_api.g_miss_num, NULL, x_application_id ),
          DECODE(x_do_not_confuse_with, fnd_api.g_miss_char, NULL, x_do_not_confuse_with),
          DECODE(x_actual_content_source,
                 fnd_api.g_miss_char, g_sst_source_type,
                 NULL, g_sst_source_type,
                 x_actual_content_source),
          DECODE(x_version_number,fnd_api.g_miss_num, NULL,x_version_number),
          DECODE(x_home_country, fnd_api.g_miss_char, NULL, x_home_country)
        ) RETURNING
          ROWID, organization_profile_id
        INTO
          x_rowid, x_organization_profile_id;

          l_success := 'Y';

      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          IF INSTRB(SQLERRM, 'HZ_ORGANIZATION_PROFILES_U1') <> 0 OR
             INSTRB(SQLERRM, 'HZ_ORGANIZATION_PROFILES_PK') <> 0
          THEN
            DECLARE
              l_count             NUMBER;
              l_dummy             VARCHAR2(1);
              -- Bug 2117973: changed select...intos into cursors.
              CURSOR c_seq IS
                SELECT hz_organization_profiles_s.NEXTVAL
                FROM   dual;
              CURSOR c_dupchk IS
                SELECT 'Y'
                FROM   hz_organization_profiles hop
                WHERE  hop.organization_profile_id = x_organization_profile_id;
            BEGIN
              l_count := 1;
              WHILE l_count > 0 LOOP
                -- get the next profile ID.
                OPEN c_seq;
                FETCH c_seq INTO x_organization_profile_id;
                IF c_seq%NOTFOUND THEN
                  CLOSE c_seq;
                  RAISE NO_DATA_FOUND;
                END IF;
                CLOSE c_seq;

                -- check for dups
                OPEN c_dupchk;
                FETCH c_dupchk INTO l_dummy;
                IF c_dupchk%FOUND THEN
                  -- continue the loop if there is a duplicate record.
                  l_count := 1;
                ELSE
                  -- terminate the loop if there is no duplicate record.
                  l_count := 0;
                END IF;
                CLOSE c_dupchk;
              END LOOP;
            END;
          ELSE
            RAISE;
          END IF;
      END;
    END LOOP;
  END insert_row;

  PROCEDURE update_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_organization_profile_id           IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_organization_name                 IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_enquiry_duns                      IN     VARCHAR2,
    x_ceo_name                          IN     VARCHAR2,
    x_ceo_title                         IN     VARCHAR2,
    x_principal_name                    IN     VARCHAR2,
    x_principal_title                   IN     VARCHAR2,
    x_legal_status                      IN     VARCHAR2,
    x_control_yr                        IN     NUMBER,
    x_employees_total                   IN     NUMBER,
    x_hq_branch_ind                     IN     VARCHAR2,
    x_branch_flag                       IN     VARCHAR2,
    x_oob_ind                           IN     VARCHAR2,
    x_line_of_business                  IN     VARCHAR2,
    x_cong_dist_code                    IN     VARCHAR2,
    x_sic_code                          IN     VARCHAR2,
    x_import_ind                        IN     VARCHAR2,
    x_export_ind                        IN     VARCHAR2,
    x_labor_surplus_ind                 IN     VARCHAR2,
    x_debarment_ind                     IN     VARCHAR2,
    x_minority_owned_ind                IN     VARCHAR2,
    x_minority_owned_type               IN     VARCHAR2,
    x_woman_owned_ind                   IN     VARCHAR2,
    x_disadv_8a_ind                     IN     VARCHAR2,
    x_small_bus_ind                     IN     VARCHAR2,
    x_rent_own_ind                      IN     VARCHAR2,
    x_debarments_count                  IN     NUMBER,
    x_debarments_date                   IN     DATE,
    x_failure_score                     IN     VARCHAR2,
    x_failure_score_override_code       IN     VARCHAR2,
    x_failure_score_commentary          IN     VARCHAR2,
    x_global_failure_score              IN     VARCHAR2,
    x_db_rating                         IN     VARCHAR2,
    x_credit_score                      IN     VARCHAR2,
    x_credit_score_commentary           IN     VARCHAR2,
    x_paydex_score                      IN     VARCHAR2,
    x_paydex_three_months_ago           IN     VARCHAR2,
    x_paydex_norm                       IN     VARCHAR2,
    x_best_time_contact_begin           IN     DATE,
    x_best_time_contact_end             IN     DATE,
    x_organization_name_phonetic        IN     VARCHAR2,
    x_tax_reference                     IN     VARCHAR2,
    x_gsa_indicator_flag                IN     VARCHAR2,
    x_jgzz_fiscal_code                  IN     VARCHAR2,
    x_analysis_fy                       IN     VARCHAR2,
    x_fiscal_yearend_month              IN     VARCHAR2,
    x_curr_fy_potential_revenue         IN     NUMBER,
    x_next_fy_potential_revenue         IN     NUMBER,
    x_year_established                  IN     NUMBER,
    x_mission_statement                 IN     VARCHAR2,
    x_organization_type                 IN     VARCHAR2,
    x_business_scope                    IN     VARCHAR2,
    x_corporation_class                 IN     VARCHAR2,
    x_known_as                          IN     VARCHAR2,
    x_local_bus_iden_type               IN     VARCHAR2,
    x_local_bus_identifier              IN     VARCHAR2,
    x_pref_functional_currency          IN     VARCHAR2,
    x_registration_type                 IN     VARCHAR2,
    x_total_employees_text              IN     VARCHAR2,
    x_total_employees_ind               IN     VARCHAR2,
    x_total_emp_est_ind                 IN     VARCHAR2,
    x_total_emp_min_ind                 IN     VARCHAR2,
    x_parent_sub_ind                    IN     VARCHAR2,
    x_incorp_year                       IN     NUMBER,
    x_content_source_type               IN     VARCHAR2,
    x_content_source_number             IN     VARCHAR2,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_sic_code_type                     IN     VARCHAR2,
    x_public_private_ownership          IN     VARCHAR2,
    x_local_activity_code_type          IN     VARCHAR2,
    x_local_activity_code               IN     VARCHAR2,
    x_emp_at_primary_adr                IN     VARCHAR2,
    x_emp_at_primary_adr_text           IN     VARCHAR2,
    x_emp_at_primary_adr_est_ind        IN     VARCHAR2,
    x_emp_at_primary_adr_min_ind        IN     VARCHAR2,
    x_internal_flag                     IN     VARCHAR2,
    x_high_credit                       IN     NUMBER,
    x_avg_high_credit                   IN     NUMBER,
    x_total_payments                    IN     NUMBER,
    x_known_as2                         IN     VARCHAR2,
    x_known_as3                         IN     VARCHAR2,
    x_known_as4                         IN     VARCHAR2,
    x_known_as5                         IN     VARCHAR2,
    x_credit_score_class                IN     NUMBER,
    x_credit_score_natl_percentile      IN     NUMBER,
    x_credit_score_incd_default         IN     NUMBER,
    x_credit_score_age                  IN     NUMBER,
    x_credit_score_date                 IN     DATE,
    x_failure_score_class               IN     NUMBER,
    x_failure_score_incd_default        IN     NUMBER,
    x_failure_score_age                 IN     NUMBER,
    x_failure_score_date                IN     DATE,
    x_failure_score_commentary2         IN     VARCHAR2,
    x_failure_score_commentary3         IN     VARCHAR2,
    x_failure_score_commentary4         IN     VARCHAR2,
    x_failure_score_commentary5         IN     VARCHAR2,
    x_failure_score_commentary6         IN     VARCHAR2,
    x_failure_score_commentary7         IN     VARCHAR2,
    x_failure_score_commentary8         IN     VARCHAR2,
    x_failure_score_commentary9         IN     VARCHAR2,
    x_failure_score_commentary10        IN     VARCHAR2,
    x_credit_score_commentary2          IN     VARCHAR2,
    x_credit_score_commentary3          IN     VARCHAR2,
    x_credit_score_commentary4          IN     VARCHAR2,
    x_credit_score_commentary5          IN     VARCHAR2,
    x_credit_score_commentary6          IN     VARCHAR2,
    x_credit_score_commentary7          IN     VARCHAR2,
    x_credit_score_commentary8          IN     VARCHAR2,
    x_credit_score_commentary9          IN     VARCHAR2,
    x_credit_score_commentary10         IN     VARCHAR2,
    x_maximum_credit_recomm             IN     NUMBER,
    x_maximum_credit_currency_code      IN     VARCHAR2,
    x_displayed_duns_party_id           IN     NUMBER,
    x_failure_score_natnl_perc          IN     NUMBER,
    x_duns_number_c                     IN     VARCHAR2,
    x_bank_or_branch_number             IN     VARCHAR2 := NULL,
    x_bank_code                         IN     VARCHAR2 := NULL,
    x_branch_code                       IN     VARCHAR2 := NULL,
    x_object_version_number             IN     NUMBER,
    x_created_by_module                 IN     VARCHAR2,
    x_application_id                    IN     NUMBER,
    x_do_not_confuse_with               IN     VARCHAR2 := NULL,
    x_actual_content_source             IN     VARCHAR2 DEFAULT NULL,
    x_version_number                    IN     NUMBER DEFAULT NULL,
    x_home_country                      IN     VARCHAR2 DEFAULT NULL
  ) IS

    l_duns_number                       NUMBER;
    l_duns_number_c                         HZ_PARTIES.duns_number_c%type := X_DUNS_NUMBER_C;
BEGIN

    IF x_duns_number_c IS NOT NULL AND
       x_duns_number_c <> FND_API.G_MISS_CHAR
    THEN
      l_duns_number := do_copy_duns_number(x_duns_number_c);
    END IF;

   IF x_duns_number_c IS NOT NULL AND
      x_duns_number_c <> FND_API.G_MISS_CHAR AND
      LENGTHB(x_duns_number_c)<9
   THEN
      l_duns_number_c:=lpad(x_duns_number_c,9,'0');
   END IF;


    UPDATE hz_organization_profiles hop
    SET    hop.organization_profile_id =
             DECODE(x_organization_profile_id,
                    NULL, hop.organization_profile_id,
                    fnd_api.g_miss_num, NULL, x_organization_profile_id),
           hop.party_id =
             DECODE(x_party_id,
                    NULL, hop.party_id,
                    fnd_api.g_miss_num, NULL,
                    x_party_id),
           hop.organization_name =
             DECODE(x_organization_name,
                    NULL, hop.organization_name,
                    fnd_api.g_miss_char, NULL,
                    x_organization_name),
           hop.attribute_category =
             DECODE(x_attribute_category,
                    NULL, hop.attribute_category,
                    fnd_api.g_miss_char, NULL,
                    x_attribute_category),
           hop.attribute1 =
             DECODE(x_attribute1,
                    NULL, hop.attribute1,
                    fnd_api.g_miss_char, NULL,
                    x_attribute1),
           hop.attribute2 =
             DECODE(x_attribute2,
                    NULL, hop.attribute2,
                    fnd_api.g_miss_char, NULL,
                    x_attribute2),
           hop.attribute3 =
             DECODE(x_attribute3,
                    NULL, hop.attribute3,
                    fnd_api.g_miss_char, NULL,
                    x_attribute3),
           hop.attribute4 =
             DECODE(x_attribute4,
                    NULL, hop.attribute4,
                    fnd_api.g_miss_char, NULL,
                    x_attribute4),
           hop.attribute5 =
             DECODE(x_attribute5,
                    NULL, hop.attribute5,
                    fnd_api.g_miss_char, NULL,
                    x_attribute5),
           hop.attribute6 =
             DECODE(x_attribute6,
                    NULL, hop.attribute6,
                    fnd_api.g_miss_char, NULL,
                    x_attribute6),
           hop.attribute7 =
             DECODE(x_attribute7,
                    NULL, hop.attribute7,
                    fnd_api.g_miss_char, NULL,
                    x_attribute7),
           hop.attribute8 =
             DECODE(x_attribute8,
                    NULL, hop.attribute8,
                    fnd_api.g_miss_char, NULL,
                    x_attribute8),
           hop.attribute9 =
             DECODE(x_attribute9,
                    NULL, hop.attribute9,
                    fnd_api.g_miss_char, NULL,
                    x_attribute9),
           hop.attribute10 =
             DECODE(x_attribute10,
                    NULL, hop.attribute10,
                    fnd_api.g_miss_char, NULL,
                    x_attribute10),
           hop.attribute11 =
             DECODE(x_attribute11,
                    NULL, hop.attribute11,
                    fnd_api.g_miss_char, NULL,
                    x_attribute11),
           hop.attribute12 =
             DECODE(x_attribute12,
                    NULL, hop.attribute12,
                    fnd_api.g_miss_char, NULL,
                    x_attribute12),
           hop.attribute13 =
             DECODE(x_attribute13,
                    NULL, hop.attribute13,
                    fnd_api.g_miss_char, NULL,
                    x_attribute13),
           hop.attribute14 =
             DECODE(x_attribute14,
                    NULL, hop.attribute14,
                    fnd_api.g_miss_char, NULL,
                    x_attribute14),
           hop.attribute15 =
             DECODE(x_attribute15,
                    NULL, hop.attribute15,
                    fnd_api.g_miss_char, NULL,
                    x_attribute15),
           hop.attribute16 =
             DECODE(x_attribute16,
                    NULL, hop.attribute16,
                    fnd_api.g_miss_char, NULL,
                    x_attribute16),
           hop.attribute17 =
             DECODE(x_attribute17,
                    NULL, hop.attribute17,
                    fnd_api.g_miss_char, NULL,
                    x_attribute17),
           hop.attribute18 =
             DECODE(x_attribute18,
                    NULL, hop.attribute18,
                    fnd_api.g_miss_char, NULL,
                    x_attribute18),
           hop.attribute19 =
             DECODE(x_attribute19,
                    NULL, hop.attribute19,
                    fnd_api.g_miss_char, NULL,
                    x_attribute19),
           hop.attribute20 =
             DECODE(x_attribute20,
                    NULL, hop.attribute20,
                    fnd_api.g_miss_char, NULL,
                    x_attribute20),
           hop.enquiry_duns =
             DECODE(x_enquiry_duns,
                    NULL, hop.enquiry_duns,
                    fnd_api.g_miss_char, NULL,
                    x_enquiry_duns),
           hop.ceo_name =
             DECODE(x_ceo_name,
                    NULL, hop.ceo_name,
                    fnd_api.g_miss_char, NULL,
                    x_ceo_name),
           hop.ceo_title =
             DECODE(x_ceo_title,
                    NULL, hop.ceo_title,
                    fnd_api.g_miss_char, NULL,
                    x_ceo_title),
           hop.principal_name =
             DECODE(x_principal_name,
                    NULL, hop.principal_name,
                    fnd_api.g_miss_char, NULL,
                    x_principal_name),
           hop.principal_title =
             DECODE(x_principal_title,
                    NULL, hop.principal_title,
                    fnd_api.g_miss_char, NULL,
                    x_principal_title),
           hop.legal_status =
             DECODE(x_legal_status,
                    NULL, hop.legal_status,
                    fnd_api.g_miss_char, NULL,
                    x_legal_status),
           hop.control_yr =
             DECODE(x_control_yr,
                    NULL, hop.control_yr,
                    fnd_api.g_miss_num, NULL,
                    x_control_yr),
           hop.employees_total =
             DECODE(x_employees_total,
                    NULL, hop.employees_total,
                    fnd_api.g_miss_num, NULL,
                    x_employees_total),
           hop.hq_branch_ind =
             DECODE(x_hq_branch_ind,
                    NULL, hop.hq_branch_ind,
                    fnd_api.g_miss_char, NULL,
                    x_hq_branch_ind),
           hop.branch_flag =
             DECODE(x_branch_flag,
                    NULL, hop.branch_flag,
                    fnd_api.g_miss_char, NULL,
                    x_branch_flag),
           hop.oob_ind =
             DECODE(x_oob_ind,
                    NULL, hop.oob_ind,
                    fnd_api.g_miss_char, NULL,
                    x_oob_ind),
           hop.line_of_business =
             DECODE(x_line_of_business,
                    NULL, hop.line_of_business,
                    fnd_api.g_miss_char, NULL,
                    x_line_of_business),
           hop.cong_dist_code =
             DECODE(x_cong_dist_code,
                    NULL, hop.cong_dist_code,
                    fnd_api.g_miss_char, NULL,
                    x_cong_dist_code),
           hop.sic_code =
             DECODE(x_sic_code,
                    NULL, hop.sic_code,
                    fnd_api.g_miss_char, NULL,
                    x_sic_code),
           hop.import_ind =
             DECODE(x_import_ind,
                    NULL, hop.import_ind,
                    fnd_api.g_miss_char, NULL,
                    x_import_ind),
           hop.export_ind =
             DECODE(x_export_ind,
                    NULL, hop.export_ind,
                    fnd_api.g_miss_char, NULL,
                    x_export_ind),
           hop.labor_surplus_ind =
             DECODE(x_labor_surplus_ind,
                    NULL, hop.labor_surplus_ind,
                    fnd_api.g_miss_char, NULL,
                    x_labor_surplus_ind),
           hop.debarment_ind =
             DECODE(x_debarment_ind,
                    NULL, hop.debarment_ind,
                    fnd_api.g_miss_char, NULL,
                    x_debarment_ind),
           hop.minority_owned_ind =
             DECODE(x_minority_owned_ind,
                    NULL, hop.minority_owned_ind,
                    fnd_api.g_miss_char, NULL,
                    x_minority_owned_ind),
           hop.minority_owned_type =
             DECODE(x_minority_owned_type,
                    NULL, hop.minority_owned_type,
                    fnd_api.g_miss_char, NULL,
                    x_minority_owned_type),
           hop.woman_owned_ind =
             DECODE(x_woman_owned_ind,
                    NULL, hop.woman_owned_ind,
                    fnd_api.g_miss_char, NULL,
                    x_woman_owned_ind),
           hop.disadv_8a_ind =
             DECODE(x_disadv_8a_ind,
                    NULL, hop.disadv_8a_ind,
                    fnd_api.g_miss_char, NULL,
                    x_disadv_8a_ind),
           hop.small_bus_ind =
             DECODE(x_small_bus_ind,
                    NULL, hop.small_bus_ind,
                    fnd_api.g_miss_char, NULL,
                    x_small_bus_ind),
           hop.rent_own_ind =
             DECODE(x_rent_own_ind,
                    NULL, hop.rent_own_ind,
                    fnd_api.g_miss_char, NULL,
                    x_rent_own_ind),
           hop.debarments_count =
             DECODE(x_debarments_count,
                    NULL, hop.debarments_count,
                    fnd_api.g_miss_num, NULL,
                    x_debarments_count),
           hop.debarments_date =
             DECODE(x_debarments_date,
                    NULL, hop.debarments_date,
                    fnd_api.g_miss_date, NULL,
                    x_debarments_date),
           hop.failure_score =
             DECODE(x_failure_score,
                    NULL, hop.failure_score,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score),
           hop.failure_score_override_code =
             DECODE(x_failure_score_override_code,
                    NULL, hop.failure_score_override_code,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_override_code),
           hop.failure_score_commentary =
             DECODE(x_failure_score_commentary,
                    NULL, hop.failure_score_commentary,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_commentary),
           hop.global_failure_score =
             DECODE(x_global_failure_score,
                    NULL, hop.global_failure_score,
                    fnd_api.g_miss_char, NULL,
                    x_global_failure_score),
           hop.db_rating =
             DECODE(x_db_rating,
                    NULL, hop.db_rating,
                    fnd_api.g_miss_char, NULL,
                    x_db_rating),
           hop.credit_score =
             DECODE(x_credit_score,
                    NULL, hop.credit_score,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score),
           hop.credit_score_commentary =
             DECODE(x_credit_score_commentary,
                    NULL, hop.credit_score_commentary,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score_commentary),
           hop.paydex_score =
             DECODE(x_paydex_score,
                    NULL, hop.paydex_score,
                    fnd_api.g_miss_char, NULL,
                    x_paydex_score),
           hop.paydex_three_months_ago =
             DECODE(x_paydex_three_months_ago,
                    NULL, hop.paydex_three_months_ago,
                    fnd_api.g_miss_char, NULL,
                    x_paydex_three_months_ago),
           hop.paydex_norm =
             DECODE(x_paydex_norm,
                    NULL, hop.paydex_norm,
                    fnd_api.g_miss_char, NULL,
                    x_paydex_norm),
           hop.best_time_contact_begin =
             DECODE(x_best_time_contact_begin,
                    NULL, hop.best_time_contact_begin,
                    fnd_api.g_miss_date, NULL,
                    x_best_time_contact_begin),
           hop.best_time_contact_end =
             DECODE(x_best_time_contact_end,
                    NULL, hop.best_time_contact_end,
                    fnd_api.g_miss_date, NULL,
                    x_best_time_contact_end),
           hop.organization_name_phonetic =
             DECODE(x_organization_name_phonetic,
                    NULL, hop.organization_name_phonetic,
                    fnd_api.g_miss_char, NULL,
                    x_organization_name_phonetic),
           hop.tax_reference =
             DECODE(x_tax_reference,
                    NULL, hop.tax_reference,
                    fnd_api.g_miss_char, NULL,
                    x_tax_reference),
           hop.gsa_indicator_flag =
             DECODE(x_gsa_indicator_flag,
                    NULL, hop.gsa_indicator_flag,
                    fnd_api.g_miss_char, NULL,
                    x_gsa_indicator_flag),
           hop.jgzz_fiscal_code =
             DECODE(x_jgzz_fiscal_code,
                    NULL, hop.jgzz_fiscal_code,
                    fnd_api.g_miss_char, NULL,
                    x_jgzz_fiscal_code),
           hop.analysis_fy =
             DECODE(x_analysis_fy,
                    NULL, hop.analysis_fy,
                    fnd_api.g_miss_char, NULL,
                    x_analysis_fy),
           hop.fiscal_yearend_month =
             DECODE(x_fiscal_yearend_month,
                    NULL, hop.fiscal_yearend_month,
                    fnd_api.g_miss_char, NULL,
                    x_fiscal_yearend_month),
           hop.curr_fy_potential_revenue =
             DECODE(x_curr_fy_potential_revenue,
                    NULL, hop.curr_fy_potential_revenue,
                    fnd_api.g_miss_num, NULL,
                    x_curr_fy_potential_revenue),
           hop.next_fy_potential_revenue =
             DECODE(x_next_fy_potential_revenue,
                    NULL, hop.next_fy_potential_revenue,
                    fnd_api.g_miss_num, NULL,
                    x_next_fy_potential_revenue),
           hop.year_established =
             DECODE(x_year_established,
                    NULL, hop.year_established,
                    fnd_api.g_miss_num, NULL,
                    x_year_established),
           hop.mission_statement =
             DECODE(x_mission_statement,
                    NULL, hop.mission_statement,
                    fnd_api.g_miss_char, NULL,
                    x_mission_statement),
           hop.organization_type =
             DECODE(x_organization_type,
                    NULL, hop.organization_type,
                    fnd_api.g_miss_char, NULL,
                    x_organization_type),
           hop.business_scope =
             DECODE(x_business_scope,
                    NULL, hop.business_scope,
                    fnd_api.g_miss_char, NULL,
                    x_business_scope),
           hop.corporation_class =
             DECODE(x_corporation_class,
                    NULL, hop.corporation_class,
                    fnd_api.g_miss_char, NULL,
                    x_corporation_class),
           hop.known_as =
             DECODE(x_known_as,
                    NULL, hop.known_as,
                    fnd_api.g_miss_char, NULL,
                    x_known_as),
           hop.local_bus_iden_type =
             DECODE(x_local_bus_iden_type,
                    NULL, hop.local_bus_iden_type,
                    fnd_api.g_miss_char, NULL,
                    x_local_bus_iden_type),
           hop.local_bus_identifier =
             DECODE(x_local_bus_identifier,
                    NULL, hop.local_bus_identifier,
                    fnd_api.g_miss_char, NULL,
                    x_local_bus_identifier),
           hop.pref_functional_currency =
             DECODE(x_pref_functional_currency,
                    NULL, hop.pref_functional_currency,
                    fnd_api.g_miss_char, NULL,
                    x_pref_functional_currency),
           hop.registration_type =
             DECODE(x_registration_type,
                    NULL, hop.registration_type,
                    fnd_api.g_miss_char, NULL,
                    x_registration_type),
           hop.total_employees_text =
             DECODE(x_total_employees_text,
                    NULL, hop.total_employees_text,
                    fnd_api.g_miss_char, NULL,
                    x_total_employees_text),
           hop.total_employees_ind =
             DECODE(x_total_employees_ind,
                    NULL, hop.total_employees_ind,
                    fnd_api.g_miss_char, NULL,
                    x_total_employees_ind),
           hop.total_emp_est_ind =
             DECODE(x_total_emp_est_ind,
                    NULL, hop.total_emp_est_ind,
                    fnd_api.g_miss_char, NULL,
                    x_total_emp_est_ind),
           hop.total_emp_min_ind =
             DECODE(x_total_emp_min_ind,
                    NULL, hop.total_emp_min_ind,
                    fnd_api.g_miss_char, NULL,
                    x_total_emp_min_ind),
           hop.parent_sub_ind =
             DECODE(x_parent_sub_ind,
                    NULL, hop.parent_sub_ind,
                    fnd_api.g_miss_char, NULL,
                    x_parent_sub_ind),
           hop.incorp_year =
             DECODE(x_incorp_year,
                    NULL, hop.incorp_year,
                    fnd_api.g_miss_num, NULL,
                    x_incorp_year),
           hop.last_update_date = hz_utility_v2pub.last_update_date,
           hop.last_updated_by = hz_utility_v2pub.last_updated_by,
           hop.creation_date = creation_date,
           hop.created_by = created_by,
           hop.last_update_login = hz_utility_v2pub.last_update_login,
           hop.request_id = hz_utility_v2pub.request_id,
           hop.program_application_id =
             hz_utility_v2pub.program_application_id,
           hop.program_id = hz_utility_v2pub.program_id,
           hop.program_update_date = hz_utility_v2pub.program_update_date,
           hop.content_source_type =
             DECODE(x_content_source_type,
                    NULL, hop.content_source_type,
                    fnd_api.g_miss_char, NULL,
                    x_content_source_type),
           hop.content_source_number =
             DECODE(x_content_source_number,
                    NULL, hop.content_source_number,
                    fnd_api.g_miss_char, NULL,
                    x_content_source_number),
           hop.effective_start_date =
             DECODE(x_effective_start_date,
                    NULL, hop.effective_start_date,
                    fnd_api.g_miss_date, NULL,
                    x_effective_start_date),
           hop.effective_end_date =
             DECODE(x_effective_end_date,
                    NULL, hop.effective_end_date,
                    fnd_api.g_miss_date, NULL,
                    x_effective_end_date),
           hop.sic_code_type =
             DECODE(x_sic_code_type,
                    NULL, hop.sic_code_type,
                    fnd_api.g_miss_char, NULL,
                    x_sic_code_type),
           hop.public_private_ownership_flag =
             DECODE(x_public_private_ownership,
                    NULL, hop.public_private_ownership_flag,
                    fnd_api.g_miss_char, NULL,
                    x_public_private_ownership),
           hop.local_activity_code_type =
             DECODE(x_local_activity_code_type,
                    NULL, hop.local_activity_code_type,
                    fnd_api.g_miss_char, NULL,
                    x_local_activity_code_type),
           hop.local_activity_code =
             DECODE(x_local_activity_code,
                    NULL, hop.local_activity_code,
                    fnd_api.g_miss_char, NULL,
                    x_local_activity_code),
           hop.emp_at_primary_adr =
             DECODE(x_emp_at_primary_adr,
                    NULL, hop.emp_at_primary_adr,
                    fnd_api.g_miss_char, NULL,
                    x_emp_at_primary_adr),
           hop.emp_at_primary_adr_text =
             DECODE(x_emp_at_primary_adr_text,
                    NULL, hop.emp_at_primary_adr_text,
                    fnd_api.g_miss_char, NULL,
                    x_emp_at_primary_adr_text),
           hop.emp_at_primary_adr_est_ind =
             DECODE(x_emp_at_primary_adr_est_ind,
                    NULL, hop.emp_at_primary_adr_est_ind,
                    fnd_api.g_miss_char, NULL,
                    x_emp_at_primary_adr_est_ind),
           hop.emp_at_primary_adr_min_ind =
             DECODE(x_emp_at_primary_adr_min_ind,
                    NULL, hop.emp_at_primary_adr_min_ind,
                    fnd_api.g_miss_char, NULL,
                    x_emp_at_primary_adr_min_ind),
           hop.internal_flag =
             DECODE(x_internal_flag,
                    NULL, hop.internal_flag,
                    fnd_api.g_miss_char, 'N',
                    x_internal_flag),
           hop.high_credit =
             DECODE(x_high_credit,
                    NULL, hop.high_credit,
                    fnd_api.g_miss_num, NULL,
                    x_high_credit),
           hop.avg_high_credit =
             DECODE(x_avg_high_credit,
                    NULL, hop.avg_high_credit,
                    fnd_api.g_miss_num, NULL,
                    x_avg_high_credit),
           hop.total_payments =
             DECODE(x_total_payments,
                    NULL, hop.total_payments,
                    fnd_api.g_miss_num, NULL,
                    x_total_payments),
           hop.known_as2 =
             DECODE(x_known_as2,
                    NULL, hop.known_as2,
                    fnd_api.g_miss_char, NULL,
                    x_known_as2),
           hop.known_as3 =
             DECODE(x_known_as3,
                    NULL, hop.known_as3,
                    fnd_api.g_miss_char, NULL,
                    x_known_as3),
           hop.known_as4 =
             DECODE(x_known_as4,
                    NULL, hop.known_as4,
                    fnd_api.g_miss_char, NULL,
                    x_known_as4),
           hop.known_as5 =
             DECODE(x_known_as5,
                    NULL, hop.known_as5,
                    fnd_api.g_miss_char, NULL,
                    x_known_as5),
           hop.credit_score_class =
             DECODE(x_credit_score_class,
                    NULL, hop.credit_score_class,
                    fnd_api.g_miss_num, NULL,
                    x_credit_score_class),
           hop.credit_score_natl_percentile =
             DECODE(x_credit_score_natl_percentile,
                    NULL, hop.credit_score_natl_percentile,
                    fnd_api.g_miss_num, NULL,
                    x_credit_score_natl_percentile),
           hop.credit_score_incd_default =
             DECODE(x_credit_score_incd_default,
                    NULL, hop.credit_score_incd_default,
                    fnd_api.g_miss_num, NULL,
                    x_credit_score_incd_default),
           hop.credit_score_age =
             DECODE(x_credit_score_age,
                    NULL, hop.credit_score_age,
                    fnd_api.g_miss_num, NULL,
                    x_credit_score_age),
           hop.credit_score_date =
             DECODE(x_credit_score_date,
                    NULL, hop.credit_score_date,
                    fnd_api.g_miss_date, NULL,
                    x_credit_score_date),
           hop.failure_score_class =
             DECODE(x_failure_score_class,
                    NULL, hop.failure_score_class,
                    fnd_api.g_miss_num, NULL,
                    x_failure_score_class),
           hop.failure_score_incd_default =
             DECODE(x_failure_score_incd_default,
                    NULL, hop.failure_score_incd_default,
                    fnd_api.g_miss_num, NULL,
                    x_failure_score_incd_default),
           hop.failure_score_age =
             DECODE(x_failure_score_age,
                    NULL, hop.failure_score_age,
                    fnd_api.g_miss_num, NULL,
                    x_failure_score_age),
           hop.failure_score_date =
             DECODE(x_failure_score_date,
                    NULL, hop.failure_score_date,
                    fnd_api.g_miss_date, NULL,
                    x_failure_score_date),
           hop.failure_score_commentary2 =
             DECODE(x_failure_score_commentary2,
                    NULL, hop.failure_score_commentary2,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_commentary2),
           hop.failure_score_commentary3 =
             DECODE(x_failure_score_commentary3,
                    NULL, hop.failure_score_commentary3,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_commentary3),
           hop.failure_score_commentary4 =
             DECODE(x_failure_score_commentary4,
                    NULL, hop.failure_score_commentary4,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_commentary4),
           hop.failure_score_commentary5 =
             DECODE(x_failure_score_commentary5,
                    NULL, hop.failure_score_commentary5,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_commentary5),
           hop.failure_score_commentary6 =
             DECODE(x_failure_score_commentary6,
                    NULL, hop.failure_score_commentary6,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_commentary6),
           hop.failure_score_commentary7 =
             DECODE(x_failure_score_commentary7,
                    NULL, hop.failure_score_commentary7,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_commentary7),
           hop.failure_score_commentary8 =
             DECODE(x_failure_score_commentary8,
                    NULL, hop.failure_score_commentary8,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_commentary8),
           hop.failure_score_commentary9 =
             DECODE(x_failure_score_commentary9,
                    NULL, hop.failure_score_commentary9,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_commentary9),
           hop.failure_score_commentary10 =
             DECODE(x_failure_score_commentary10,
                    NULL, hop.failure_score_commentary10,
                    fnd_api.g_miss_char, NULL,
                    x_failure_score_commentary10),
           hop.credit_score_commentary2 =
             DECODE(x_credit_score_commentary2,
                    NULL, hop.credit_score_commentary2,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score_commentary2),
           hop.credit_score_commentary3 =
             DECODE(x_credit_score_commentary3,
                    NULL, hop.credit_score_commentary3,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score_commentary3),
           hop.credit_score_commentary4 =
             DECODE(x_credit_score_commentary4,
                    NULL, hop.credit_score_commentary4,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score_commentary4),
           hop.credit_score_commentary5 =
             DECODE(x_credit_score_commentary5,
                    NULL, hop.credit_score_commentary5,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score_commentary5),
           hop.credit_score_commentary6 =
             DECODE(x_credit_score_commentary6,
                    NULL, hop.credit_score_commentary6,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score_commentary6),
           hop.credit_score_commentary7 =
             DECODE(x_credit_score_commentary7,
                    NULL, hop.credit_score_commentary7,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score_commentary7),
           hop.credit_score_commentary8 =
             DECODE(x_credit_score_commentary8,
                    NULL, hop.credit_score_commentary8,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score_commentary8),
           hop.credit_score_commentary9 =
             DECODE(x_credit_score_commentary9,
                    NULL, hop.credit_score_commentary9,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score_commentary9),
           hop.credit_score_commentary10 =
             DECODE(x_credit_score_commentary10,
                    NULL, hop.credit_score_commentary10,
                    fnd_api.g_miss_char, NULL,
                    x_credit_score_commentary10),
           hop.maximum_credit_recommendation =
             DECODE(x_maximum_credit_recomm,
                    NULL, hop.maximum_credit_recommendation,
                    fnd_api.g_miss_num, NULL,
                    x_maximum_credit_recomm),
           hop.maximum_credit_currency_code =
             DECODE(x_maximum_credit_currency_code,
                    NULL, hop.maximum_credit_currency_code,
                    fnd_api.g_miss_char, NULL,
                    x_maximum_credit_currency_code),
           hop.displayed_duns_party_id =
             DECODE(x_displayed_duns_party_id,
                    NULL, hop.displayed_duns_party_id,
                    fnd_api.g_miss_num, NULL,
                    x_displayed_duns_party_id),
           hop.failure_score_natnl_percentile =
             DECODE(x_failure_score_natnl_perc,
                    NULL, hop.failure_score_natnl_percentile,
                    fnd_api.g_miss_num, NULL,
                    x_failure_score_natnl_perc),
           hop.duns_number_c =
             DECODE(x_duns_number_c,
                    NULL, hop.duns_number_c,
                    fnd_api.g_miss_char, NULL,
                    /*Bug 3435702*/ UPPER(l_duns_number_c)),
           hop.duns_number =
             DECODE(x_duns_number_c,
                    NULL, hop.duns_number,
                    /*Bug 3435702.This is redundant because if x_duns_number_c = fnd_api.g_miss_char,
                      then l_duns_number = NULL.
                    fnd_api.g_miss_char, NULL,
                    */
                    l_duns_number ),
           hop.object_version_number =
             DECODE(x_object_version_number,
                    NULL, hop.object_version_number,
                    fnd_api.g_miss_num, NULL,
                    x_object_version_number),
           hop.created_by_module =
             DECODE(x_created_by_module,
                    NULL, hop.created_by_module,
                    fnd_api.g_miss_char, NULL,
                    x_created_by_module),
           hop.application_id =
             DECODE(x_application_id,
                    NULL, hop.application_id,
                    fnd_api.g_miss_num, NULL,
                    x_application_id),
           hop.bank_or_branch_number =
             DECODE(x_bank_or_branch_number,
                    NULL, hop.bank_or_branch_number,
                    fnd_api.g_miss_char, NULL,
                    x_bank_or_branch_number),
           hop.bank_code =
             DECODE(x_bank_code,
                    NULL, hop.bank_code,
                    fnd_api.g_miss_char, NULL,
                    x_bank_code),
           hop.branch_code =
             DECODE(x_branch_code,
                    NULL, hop.branch_code,
                    fnd_api.g_miss_char, NULL,
                    x_branch_code),
           hop.do_not_confuse_with =
             DECODE(x_do_not_confuse_with,
                    NULL, hop.do_not_confuse_with,
                    fnd_api.g_miss_char, NULL,
                    x_do_not_confuse_with),
           hop.actual_content_source =
             DECODE(x_actual_content_source,
                    NULL, hop.actual_content_source,
                    fnd_api.g_miss_char, NULL,
                    x_actual_content_source),
           hop.version_number =
             DECODE(x_version_number,
                    NULL, hop.version_number,
                    fnd_api.g_miss_num, NULL,
                    x_version_number),
           hop.home_country =
             DECODE(x_home_country,
                    NULL, hop.home_country,
                    fnd_api.g_miss_char, NULL,
                    x_home_country)
    WHERE hop.ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;

  PROCEDURE lock_row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_organization_profile_id               IN     NUMBER,
    x_party_id                              IN     NUMBER,
    x_organization_name                     IN     VARCHAR2,
    x_attribute_category                    IN     VARCHAR2,
    x_attribute1                            IN     VARCHAR2,
    x_attribute2                            IN     VARCHAR2,
    x_attribute3                            IN     VARCHAR2,
    x_attribute4                            IN     VARCHAR2,
    x_attribute5                            IN     VARCHAR2,
    x_attribute6                            IN     VARCHAR2,
    x_attribute7                            IN     VARCHAR2,
    x_attribute8                            IN     VARCHAR2,
    x_attribute9                            IN     VARCHAR2,
    x_attribute10                           IN     VARCHAR2,
    x_attribute11                           IN     VARCHAR2,
    x_attribute12                           IN     VARCHAR2,
    x_attribute13                           IN     VARCHAR2,
    x_attribute14                           IN     VARCHAR2,
    x_attribute15                           IN     VARCHAR2,
    x_attribute16                           IN     VARCHAR2,
    x_attribute17                           IN     VARCHAR2,
    x_attribute18                           IN     VARCHAR2,
    x_attribute19                           IN     VARCHAR2,
    x_attribute20                           IN     VARCHAR2,
    x_enquiry_duns                          IN     VARCHAR2,
    x_ceo_name                              IN     VARCHAR2,
    x_ceo_title                             IN     VARCHAR2,
    x_principal_name                        IN     VARCHAR2,
    x_principal_title                       IN     VARCHAR2,
    x_legal_status                          IN     VARCHAR2,
    x_control_yr                            IN     NUMBER,
    x_employees_total                       IN     NUMBER,
    x_hq_branch_ind                         IN     VARCHAR2,
    x_branch_flag                           IN     VARCHAR2,
    x_oob_ind                               IN     VARCHAR2,
    x_line_of_business                      IN     VARCHAR2,
    x_cong_dist_code                        IN     VARCHAR2,
    x_sic_code                              IN     VARCHAR2,
    x_import_ind                            IN     VARCHAR2,
    x_export_ind                            IN     VARCHAR2,
    x_labor_surplus_ind                     IN     VARCHAR2,
    x_debarment_ind                         IN     VARCHAR2,
    x_minority_owned_ind                    IN     VARCHAR2,
    x_minority_owned_type                   IN     VARCHAR2,
    x_woman_owned_ind                       IN     VARCHAR2,
    x_disadv_8a_ind                         IN     VARCHAR2,
    x_small_bus_ind                         IN     VARCHAR2,
    x_rent_own_ind                          IN     VARCHAR2,
    x_debarments_count                      IN     NUMBER,
    x_debarments_date                       IN     DATE,
    x_failure_score                         IN     VARCHAR2,
    x_failure_score_override_code           IN     VARCHAR2,
    x_failure_score_commentary              IN     VARCHAR2,
    x_global_failure_score                  IN     VARCHAR2,
    x_db_rating                             IN     VARCHAR2,
    x_credit_score                          IN     VARCHAR2,
    x_credit_score_commentary               IN     VARCHAR2,
    x_paydex_score                          IN     VARCHAR2,
    x_paydex_three_months_ago               IN     VARCHAR2,
    x_paydex_norm                           IN     VARCHAR2,
    x_best_time_contact_begin               IN     DATE,
    x_best_time_contact_end                 IN     DATE,
    x_organization_name_phonetic            IN     VARCHAR2,
    x_tax_reference                         IN     VARCHAR2,
    x_gsa_indicator_flag                    IN     VARCHAR2,
    x_jgzz_fiscal_code                      IN     VARCHAR2,
    x_analysis_fy                           IN     VARCHAR2,
    x_fiscal_yearend_month                  IN     VARCHAR2,
    x_curr_fy_potential_revenue             IN     NUMBER,
    x_next_fy_potential_revenue             IN     NUMBER,
    x_year_established                      IN     NUMBER,
    x_mission_statement                     IN     VARCHAR2,
    x_organization_type                     IN     VARCHAR2,
    x_business_scope                        IN     VARCHAR2,
    x_corporation_class                     IN     VARCHAR2,
    x_known_as                              IN     VARCHAR2,
    x_local_bus_iden_type                   IN     VARCHAR2,
    x_local_bus_identifier                  IN     VARCHAR2,
    x_pref_functional_currency              IN     VARCHAR2,
    x_registration_type                     IN     VARCHAR2,
    x_total_employees_text                  IN     VARCHAR2,
    x_total_employees_ind                   IN     VARCHAR2,
    x_total_emp_est_ind                     IN     VARCHAR2,
    x_total_emp_min_ind                     IN     VARCHAR2,
    x_parent_sub_ind                        IN     VARCHAR2,
    x_incorp_year                           IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_request_id                            IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_update_date                   IN     DATE,
    x_content_source_type                   IN     VARCHAR2,
    x_content_source_number                 IN     VARCHAR2,
    x_effective_start_date                  IN     DATE,
    x_effective_end_date                    IN     DATE,
    x_sic_code_type                         IN     VARCHAR2,
    x_public_private_ownership              IN     VARCHAR2,
    x_local_activity_code_type              IN     VARCHAR2,
    x_local_activity_code                   IN     VARCHAR2,
    x_emp_at_primary_adr                    IN     VARCHAR2,
    x_emp_at_primary_adr_text               IN     VARCHAR2,
    x_emp_at_primary_adr_est_ind            IN     VARCHAR2,
    x_emp_at_primary_adr_min_ind            IN     VARCHAR2,
    x_internal_flag                         IN     VARCHAR2,
    x_high_credit                           IN     NUMBER,
    x_avg_high_credit                       IN     NUMBER,
    x_total_payments                        IN     NUMBER,
    x_known_as2                             IN     VARCHAR2,
    x_known_as3                             IN     VARCHAR2,
    x_known_as4                             IN     VARCHAR2,
    x_known_as5                             IN     VARCHAR2,
    x_credit_score_class                    IN     NUMBER,
    x_credit_score_natl_percentile          IN     NUMBER,
    x_credit_score_incd_default             IN     NUMBER,
    x_credit_score_age                      IN     NUMBER,
    x_credit_score_date                     IN     DATE,
    x_failure_score_class                   IN     NUMBER,
    x_failure_score_incd_default            IN     NUMBER,
    x_failure_score_age                     IN     NUMBER,
    x_failure_score_date                    IN     DATE,
    x_failure_score_commentary2             IN     VARCHAR2,
    x_failure_score_commentary3             IN     VARCHAR2,
    x_failure_score_commentary4             IN     VARCHAR2,
    x_failure_score_commentary5             IN     VARCHAR2,
    x_failure_score_commentary6             IN     VARCHAR2,
    x_failure_score_commentary7             IN     VARCHAR2,
    x_failure_score_commentary8             IN     VARCHAR2,
    x_failure_score_commentary9             IN     VARCHAR2,
    x_failure_score_commentary10            IN     VARCHAR2,
    x_credit_score_commentary2              IN     VARCHAR2,
    x_credit_score_commentary3              IN     VARCHAR2,
    x_credit_score_commentary4              IN     VARCHAR2,
    x_credit_score_commentary5              IN     VARCHAR2,
    x_credit_score_commentary6              IN     VARCHAR2,
    x_credit_score_commentary7              IN     VARCHAR2,
    x_credit_score_commentary8              IN     VARCHAR2,
    x_credit_score_commentary9              IN     VARCHAR2,
    x_credit_score_commentary10             IN     VARCHAR2,
    x_maximum_credit_recomm                 IN     NUMBER,
    x_maximum_credit_currency_code          IN     VARCHAR2,
    x_displayed_duns_party_id               IN     NUMBER,
    x_failure_score_natnl_perc              IN     NUMBER,
    x_duns_number_c                         IN     VARCHAR2,
    x_bank_or_branch_number                 IN     VARCHAR2,
    x_bank_code                             IN     VARCHAR2,
    x_branch_code                           IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_do_not_confuse_with                   IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2 DEFAULT NULL
  ) IS

    CURSOR c IS
      SELECT *
      FROM   hz_organization_profiles hop
      WHERE  hop.ROWID = x_Rowid
      FOR UPDATE NOWAIT;
    recinfo c%ROWTYPE;

  BEGIN

    OPEN c;
    FETCH c INTO recinfo;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;
    CLOSE c;

    IF (((recinfo.organization_profile_id = x_organization_profile_id)
         OR ((recinfo.organization_profile_id IS NULL)
             AND (x_organization_profile_id IS NULL)))
        AND ((recinfo.party_id = x_party_id)
             OR ((recinfo.party_id IS NULL)
                 AND (x_party_id IS NULL)))
        AND ((recinfo.organization_name = x_organization_name)
             OR ((recinfo.organization_name IS NULL)
                 AND (x_organization_name IS NULL)))
        AND ((recinfo.attribute_category = x_attribute_category)
             OR ((recinfo.attribute_category IS NULL)
                 AND (x_attribute_category IS NULL)))
        AND ((recinfo.attribute1 = x_attribute1)
             OR ((recinfo.attribute1 IS NULL)
                 AND (x_attribute1 IS NULL)))
        AND ((recinfo.attribute2 = x_attribute2)
             OR ((recinfo.attribute2 IS NULL)
                 AND (x_attribute2 IS NULL)))
        AND ((recinfo.attribute3 = x_attribute3)
             OR ((recinfo.attribute3 IS NULL)
                 AND (x_attribute3 IS NULL)))
        AND ((recinfo.attribute4 = x_attribute4)
             OR ((recinfo.attribute4 IS NULL)
                 AND (x_attribute4 IS NULL)))
        AND ((recinfo.attribute5 = x_attribute5)
             OR ((recinfo.attribute5 IS NULL)
                 AND (x_attribute5 IS NULL)))
        AND ((recinfo.attribute6 = x_attribute6)
             OR ((recinfo.attribute6 IS NULL)
                 AND (x_attribute6 IS NULL)))
        AND ((recinfo.attribute7 = x_attribute7)
             OR ((recinfo.attribute7 IS NULL)
                 AND (x_attribute7 IS NULL)))
        AND ((recinfo.attribute8 = x_attribute8)
             OR ((recinfo.attribute8 IS NULL)
                 AND (x_attribute8 IS NULL)))
        AND ((recinfo.attribute9 = x_attribute9)
             OR ((recinfo.attribute9 IS NULL)
                 AND (x_attribute9 IS NULL)))
        AND ((recinfo.attribute10 = x_attribute10)
             OR ((recinfo.attribute10 IS NULL)
                 AND (x_attribute10 IS NULL)))
        AND ((recinfo.attribute11 = x_attribute11)
             OR ((recinfo.attribute11 IS NULL)
                 AND (x_attribute11 IS NULL)))
        AND ((recinfo.attribute12 = x_attribute12)
             OR ((recinfo.attribute12 IS NULL)
                 AND (x_attribute12 IS NULL)))
        AND ((recinfo.attribute13 = x_attribute13)
             OR ((recinfo.attribute13 IS NULL)
                 AND (x_attribute13 IS NULL)))
        AND ((recinfo.attribute14 = x_attribute14)
             OR ((recinfo.attribute14 IS NULL)
                 AND (x_attribute14 IS NULL)))
        AND ((recinfo.attribute15 = x_attribute15)
             OR ((recinfo.attribute15 IS NULL)
                 AND (x_attribute15 IS NULL)))
        AND ((recinfo.attribute16 = x_attribute16)
             OR ((recinfo.attribute16 IS NULL)
                 AND (x_attribute16 IS NULL)))
        AND ((recinfo.attribute17 = x_attribute17)
             OR ((recinfo.attribute17 IS NULL)
                 AND (x_attribute17 IS NULL)))
        AND ((recinfo.attribute18 = x_attribute18)
             OR ((recinfo.attribute18 IS NULL)
                 AND (x_attribute18 IS NULL)))
        AND ((recinfo.attribute19 = x_attribute19)
             OR ((recinfo.attribute19 IS NULL)
                 AND (x_attribute19 IS NULL)))
        AND ((recinfo.attribute20 = x_attribute20)
             OR ((recinfo.attribute20 IS NULL)
                 AND (x_attribute20 IS NULL)))
        AND ((recinfo.enquiry_duns = x_enquiry_duns)
             OR ((recinfo.enquiry_duns IS NULL)
                 AND (x_enquiry_duns IS NULL)))
        AND ((recinfo.ceo_name = x_ceo_name)
             OR ((recinfo.ceo_name IS NULL)
                 AND (x_ceo_name IS NULL)))
        AND ((recinfo.ceo_title = x_ceo_title)
             OR ((recinfo.ceo_title IS NULL)
                 AND (x_ceo_title IS NULL)))
        AND ((recinfo.principal_name = x_principal_name)
             OR ((recinfo.principal_name IS NULL)
                 AND (x_principal_name IS NULL)))
        AND ((recinfo.principal_title = x_principal_title)
             OR ((recinfo.principal_title IS NULL)
                 AND (x_principal_title IS NULL)))
        AND ((recinfo.legal_status = x_legal_status)
             OR ((recinfo.legal_status IS NULL)
                 AND (x_legal_status IS NULL)))
        AND ((recinfo.control_yr = x_control_yr)
             OR ((recinfo.control_yr IS NULL)
                 AND (x_control_yr IS NULL)))
        AND ((recinfo.employees_total = x_employees_total)
             OR ((recinfo.employees_total IS NULL)
                 AND (x_employees_total IS NULL)))
        AND ((recinfo.hq_branch_ind = x_hq_branch_ind)
             OR ((recinfo.hq_branch_ind IS NULL)
                 AND (x_hq_branch_ind IS NULL)))
        AND ((recinfo.branch_flag = x_branch_flag)
             OR ((recinfo.branch_flag IS NULL)
                 AND (x_branch_flag IS NULL)))
        AND ((recinfo.oob_ind = x_oob_ind)
             OR ((recinfo.oob_ind IS NULL)
                 AND (x_oob_ind IS NULL)))
        AND ((recinfo.line_of_business = x_line_of_business)
             OR ((recinfo.line_of_business IS NULL)
                 AND (x_line_of_business IS NULL)))
        AND ((recinfo.cong_dist_code = x_cong_dist_code)
             OR ((recinfo.cong_dist_code IS NULL)
                 AND (x_cong_dist_code IS NULL)))
        AND ((recinfo.sic_code = x_sic_code)
             OR ((recinfo.sic_code IS NULL)
                 AND (x_sic_code IS NULL)))
        AND ((recinfo.import_ind = x_import_ind)
             OR ((recinfo.import_ind IS NULL)
                 AND (x_import_ind IS NULL)))
        AND ((recinfo.export_ind = x_export_ind)
             OR ((recinfo.export_ind IS NULL)
                 AND (x_export_ind IS NULL)))
        AND ((recinfo.labor_surplus_ind = x_labor_surplus_ind)
             OR ((recinfo.labor_surplus_ind IS NULL)
                 AND (x_labor_surplus_ind IS NULL)))
        AND ((recinfo.debarment_ind = x_debarment_ind)
             OR ((recinfo.debarment_ind IS NULL)
                 AND (x_debarment_ind IS NULL)))
        AND ((recinfo.minority_owned_ind = x_minority_owned_ind)
             OR ((recinfo.minority_owned_ind IS NULL)
                 AND (x_minority_owned_ind IS NULL)))
        AND ((recinfo.minority_owned_type = x_minority_owned_type)
             OR ((recinfo.minority_owned_type IS NULL)
                 AND (x_minority_owned_type IS NULL)))
        AND ((recinfo.woman_owned_ind = x_woman_owned_ind)
             OR ((recinfo.woman_owned_ind IS NULL)
                 AND (x_woman_owned_ind IS NULL)))
        AND ((recinfo.disadv_8a_ind = x_disadv_8a_ind)
             OR ((recinfo.disadv_8a_ind IS NULL)
                 AND (x_disadv_8a_ind IS NULL)))
        AND ((recinfo.small_bus_ind = x_small_bus_ind)
             OR ((recinfo.small_bus_ind IS NULL)
                 AND (x_small_bus_ind IS NULL)))
        AND ((recinfo.rent_own_ind = x_rent_own_ind)
             OR ((recinfo.rent_own_ind IS NULL)
                 AND (x_rent_own_ind IS NULL)))
        AND ((recinfo.debarments_count = x_debarments_count)
             OR ((recinfo.debarments_count IS NULL)
                 AND (x_debarments_count IS NULL)))
        AND ((recinfo.debarments_date = x_debarments_date)
             OR ((recinfo.debarments_date IS NULL)
                 AND (x_debarments_date IS NULL)))
        AND ((recinfo.failure_score = x_failure_score)
             OR ((recinfo.failure_score IS NULL)
                 AND (x_failure_score IS NULL)))
        AND ((recinfo.failure_score_override_code =
              x_failure_score_override_code)
             OR ((recinfo.failure_score_override_code IS NULL)
                 AND (x_failure_score_override_code IS NULL)))
        AND ((recinfo.failure_score_commentary = x_failure_score_commentary)
             OR ((recinfo.failure_score_commentary IS NULL)
                 AND (x_failure_score_commentary IS NULL)))
        AND ((recinfo.global_failure_score = x_global_failure_score)
             OR ((recinfo.global_failure_score IS NULL)
                 AND (x_global_failure_score IS NULL)))
        AND ((recinfo.db_rating = x_db_rating)
             OR ((recinfo.db_rating IS NULL)
                 AND (x_db_rating IS NULL)))
        AND ((recinfo.credit_score = x_credit_score)
             OR ((recinfo.credit_score IS NULL)
                 AND (x_credit_score IS NULL)))
        AND ((recinfo.credit_score_commentary = x_credit_score_commentary)
             OR ((recinfo.credit_score_commentary IS NULL)
                 AND (x_credit_score_commentary IS NULL)))
        AND ((recinfo.paydex_score = x_paydex_score)
             OR ((recinfo.paydex_score IS NULL)
                 AND (x_paydex_score IS NULL)))
        AND ((recinfo.paydex_three_months_ago = x_paydex_three_months_ago)
             OR ((recinfo.paydex_three_months_ago IS NULL)
                 AND (x_paydex_three_months_ago IS NULL)))
        AND ((recinfo.paydex_norm = x_paydex_norm)
             OR ((recinfo.paydex_norm IS NULL)
                 AND (x_paydex_norm IS NULL)))
        AND ((recinfo.best_time_contact_begin = x_best_time_contact_begin)
             OR ((recinfo.best_time_contact_begin IS NULL)
                 AND (x_best_time_contact_begin IS NULL)))
        AND ((recinfo.best_time_contact_end = x_best_time_contact_end)
             OR ((recinfo.best_time_contact_end IS NULL)
                 AND (x_best_time_contact_end IS NULL)))
        AND ((recinfo.organization_name_phonetic =
              x_organization_name_phonetic)
             OR ((recinfo.organization_name_phonetic IS NULL)
                 AND (x_organization_name_phonetic IS NULL)))
        AND ((recinfo.tax_reference = x_tax_reference)
             OR ((recinfo.tax_reference IS NULL)
                 AND (x_tax_reference IS NULL)))
        AND ((recinfo.gsa_indicator_flag = x_gsa_indicator_flag)
             OR ((recinfo.gsa_indicator_flag IS NULL)
                 AND (x_gsa_indicator_flag IS NULL)))
        AND ((recinfo.jgzz_fiscal_code = x_jgzz_fiscal_code)
             OR ((recinfo.jgzz_fiscal_code IS NULL)
                 AND (x_jgzz_fiscal_code IS NULL)))
        AND ((recinfo.analysis_fy = x_analysis_fy)
             OR ((recinfo.analysis_fy IS NULL)
                 AND (x_analysis_fy IS NULL)))
        AND ((recinfo.fiscal_yearend_month = x_fiscal_yearend_month)
             OR ((recinfo.fiscal_yearend_month IS NULL)
                 AND (x_fiscal_yearend_month IS NULL)))
        AND ((recinfo.curr_fy_potential_revenue = x_curr_fy_potential_revenue)
             OR ((recinfo.curr_fy_potential_revenue IS NULL)
                 AND (x_curr_fy_potential_revenue IS NULL)))
        AND ((recinfo.next_fy_potential_revenue = x_next_fy_potential_revenue)
             OR ((recinfo.next_fy_potential_revenue IS NULL)
                 AND (x_next_fy_potential_revenue IS NULL)))
        AND ((recinfo.year_established = x_year_established)
             OR ((recinfo.year_established IS NULL)
                 AND (x_year_established IS NULL)))
        AND ((recinfo.mission_statement = x_mission_statement)
             OR ((recinfo.mission_statement IS NULL)
                 AND (x_mission_statement IS NULL)))
        AND ((recinfo.organization_type = x_organization_type)
             OR ((recinfo.organization_type IS NULL)
                 AND (x_organization_type IS NULL)))
        AND ((recinfo.business_scope = x_business_scope)
             OR ((recinfo.business_scope IS NULL)
                 AND (x_business_scope IS NULL)))
        AND ((recinfo.corporation_class = x_corporation_class)
             OR ((recinfo.corporation_class IS NULL)
                 AND (x_corporation_class IS NULL)))
        AND ((recinfo.known_as = x_known_as)
             OR ((recinfo.known_as IS NULL)
                 AND (x_known_as IS NULL)))
        AND ((recinfo.local_bus_iden_type = x_local_bus_iden_type)
             OR ((recinfo.local_bus_iden_type IS NULL)
                 AND (x_local_bus_iden_type IS NULL)))
        AND ((recinfo.local_bus_identifier = x_local_bus_identifier)
             OR ((recinfo.local_bus_identifier IS NULL)
                 AND (x_local_bus_identifier IS NULL)))
        AND ((recinfo.pref_functional_currency = x_pref_functional_currency)
             OR ((recinfo.pref_functional_currency IS NULL)
                 AND (x_pref_functional_currency IS NULL)))
        AND ((recinfo.registration_type = x_registration_type)
             OR ((recinfo.registration_type IS NULL)
                 AND (x_registration_type IS NULL)))
        AND ((recinfo.total_employees_text = x_total_employees_text)
             OR ((recinfo.total_employees_text IS NULL)
                 AND (x_total_employees_text IS NULL)))
        AND ((recinfo.total_employees_ind = x_total_employees_ind)
             OR ((recinfo.total_employees_ind IS NULL)
                 AND (x_total_employees_ind IS NULL)))
        AND ((recinfo.total_emp_est_ind = x_total_emp_est_ind)
             OR ((recinfo.total_emp_est_ind IS NULL)
                 AND (x_total_emp_est_ind IS NULL)))
        AND ((recinfo.total_emp_min_ind = x_total_emp_min_ind)
             OR ((recinfo.total_emp_min_ind IS NULL)
                 AND (x_total_emp_min_ind IS NULL)))
        AND ((recinfo.parent_sub_ind = x_parent_sub_ind)
             OR ((recinfo.parent_sub_ind IS NULL)
                 AND (x_parent_sub_ind IS NULL)))
        AND ((recinfo.incorp_year = x_incorp_year)
             OR ((recinfo.incorp_year IS NULL)
                 AND (x_incorp_year IS NULL)))
        AND ((recinfo.last_update_date = x_last_update_date)
             OR ((recinfo.last_update_date IS NULL)
                 AND (x_last_update_date IS NULL)))
        AND ((recinfo.last_updated_by = x_last_updated_by)
             OR ((recinfo.last_updated_by IS NULL)
                 AND (x_last_updated_by IS NULL)))
        AND ((recinfo.creation_date = x_creation_date)
             OR ((recinfo.creation_date IS NULL)
                 AND (x_creation_date IS NULL)))
        AND ((recinfo.created_by = x_created_by)
             OR ((recinfo.created_by IS NULL)
                 AND (x_created_by IS NULL)))
        AND ((recinfo.last_update_login = x_last_update_login)
             OR ((recinfo.last_update_login IS NULL)
                 AND (x_last_update_login IS NULL)))
        AND ((recinfo.request_id = x_request_id)
             OR ((recinfo.request_id IS NULL)
                 AND (x_request_id IS NULL)))
        AND ((recinfo.program_application_id = x_program_application_id)
             OR ((recinfo.program_application_id IS NULL)
                 AND (x_program_application_id IS NULL)))
        AND ((recinfo.program_id = x_program_id)
             OR ((recinfo.program_id IS NULL)
                 AND (x_program_id IS NULL)))
        AND ((recinfo.program_update_date = x_program_update_date)
             OR ((recinfo.program_update_date IS NULL)
                 AND (x_program_update_date IS NULL)))
        AND ((recinfo.content_source_type = x_content_source_type)
             OR ((recinfo.content_source_type IS NULL)
                 AND (x_content_source_type IS NULL)))
        AND ((recinfo.content_source_number = x_content_source_number)
             OR ((recinfo.content_source_number IS NULL)
                 AND (x_content_source_number IS NULL)))
        AND ((recinfo.effective_start_date = x_effective_start_date)
             OR ((recinfo.effective_start_date IS NULL)
                 AND (x_effective_start_date IS NULL)))
        AND ((recinfo.effective_end_date = x_effective_end_date)
             OR ((recinfo.effective_end_date IS NULL)
                 AND (x_effective_end_date IS NULL)))
        AND ((recinfo.sic_code_type = x_sic_code_type)
             OR ((recinfo.sic_code_type IS NULL)
                 AND (x_sic_code_type IS NULL)))
        AND ((recinfo.public_private_ownership_flag =
              x_public_private_ownership)
             OR ((recinfo.public_private_ownership_flag IS NULL)
                 AND (x_public_private_ownership IS NULL)))
        AND ((recinfo.local_activity_code_type = x_local_activity_code_type)
             OR ((recinfo.local_activity_code_type IS NULL)
                 AND (x_local_activity_code_type IS NULL)))
        AND ((recinfo.local_activity_code = x_local_activity_code)
             OR ((recinfo.local_activity_code IS NULL)
                 AND (x_local_activity_code IS NULL)))
        AND ((recinfo.emp_at_primary_adr = x_emp_at_primary_adr)
             OR ((recinfo.emp_at_primary_adr IS NULL)
                 AND (x_emp_at_primary_adr IS NULL)))
        AND ((recinfo.emp_at_primary_adr_text = x_emp_at_primary_adr_text)
             OR ((recinfo.emp_at_primary_adr_text IS NULL)
                 AND (x_emp_at_primary_adr_text IS NULL)))
        AND ((recinfo.emp_at_primary_adr_est_ind =
              x_emp_at_primary_adr_est_ind)
             OR ((recinfo.emp_at_primary_adr_est_ind IS NULL)
                 AND (x_emp_at_primary_adr_est_ind IS NULL)))
        AND ((recinfo.emp_at_primary_adr_min_ind =
              x_emp_at_primary_adr_min_ind)
             OR ((recinfo.emp_at_primary_adr_min_ind IS NULL)
                 AND (x_emp_at_primary_adr_min_ind IS NULL)))
        AND ((recinfo.internal_flag = x_internal_flag)
             OR ((recinfo.internal_flag IS NULL)
                 AND (x_internal_flag IS NULL)))
        AND ((recinfo.high_credit = x_high_credit)
             OR ((recinfo.high_credit IS NULL)
                 AND (x_high_credit IS NULL)))
        AND ((recinfo.avg_high_credit = x_avg_high_credit)
             OR ((recinfo.avg_high_credit IS NULL)
                 AND (x_avg_high_credit IS NULL)))
        AND ((recinfo.total_payments = x_total_payments)
             OR ((recinfo.total_payments IS NULL)
                 AND (x_total_payments IS NULL)))
        AND ((recinfo.known_as2 = x_known_as2)
             OR ((recinfo.known_as2 IS NULL)
                 AND (x_known_as2 IS NULL)))
        AND ((recinfo.known_as3 = x_known_as3)
             OR ((recinfo.known_as3 IS NULL)
                 AND (x_known_as3 IS NULL)))
        AND ((recinfo.known_as4 = x_known_as4)
             OR ((recinfo.known_as4 IS NULL)
                 AND (x_known_as4 IS NULL)))
        AND ((recinfo.known_as5 = x_known_as5)
             OR ((recinfo.known_as5 IS NULL)
                 AND (x_known_as5 IS NULL)))
        AND ((recinfo.credit_score_class = x_credit_score_class)
             OR ((recinfo.credit_score_class IS NULL)
                 AND (x_credit_score_class IS NULL)))
        AND ((recinfo.credit_score_natl_percentile =
              x_credit_score_natl_percentile)
             OR ((recinfo.credit_score_natl_percentile IS NULL)
                 AND (x_credit_score_natl_percentile IS NULL)))
        AND ((recinfo.credit_score_incd_default = x_credit_score_incd_default)
             OR ((recinfo.credit_score_incd_default IS NULL)
                 AND (x_credit_score_incd_default IS NULL)))
        AND ((recinfo.credit_score_age = x_credit_score_age)
             OR ((recinfo.credit_score_age IS NULL)
                 AND (x_credit_score_age IS NULL)))
        AND ((recinfo.credit_score_date = x_credit_score_date)
             OR ((recinfo.credit_score_date IS NULL)
                 AND (x_credit_score_date IS NULL)))
        AND ((recinfo.failure_score_class = x_failure_score_class)
             OR ((recinfo.failure_score_class IS NULL)
                 AND (x_failure_score_class IS NULL)))
        AND ((recinfo.failure_score_incd_default =
              x_failure_score_incd_default)
             OR ((recinfo.failure_score_incd_default IS NULL)
                 AND (x_failure_score_incd_default IS NULL)))
        AND ((recinfo.failure_score_age = x_failure_score_age)
             OR ((recinfo.failure_score_age IS NULL)
                 AND (x_failure_score_age IS NULL)))
        AND ((recinfo.failure_score_date = x_failure_score_date)
             OR ((recinfo.failure_score_date IS NULL)
                 AND (x_failure_score_date IS NULL)))
        AND ((recinfo.failure_score_commentary2 = x_failure_score_commentary2)
             OR ((recinfo.failure_score_commentary2 IS NULL)
                 AND (x_failure_score_commentary2 IS NULL)))
        AND ((recinfo.failure_score_commentary3 = x_failure_score_commentary3)
             OR ((recinfo.failure_score_commentary3 IS NULL)
                 AND (x_failure_score_commentary3 IS NULL)))
        AND ((recinfo.failure_score_commentary4 = x_failure_score_commentary4)
             OR ((recinfo.failure_score_commentary4 IS NULL)
                 AND (x_failure_score_commentary4 IS NULL)))
        AND ((recinfo.failure_score_commentary5 = x_failure_score_commentary5)
             OR ((recinfo.failure_score_commentary5 IS NULL)
                 AND (x_failure_score_commentary5 IS NULL)))
        AND ((recinfo.failure_score_commentary6 = x_failure_score_commentary6)
             OR ((recinfo.failure_score_commentary6 IS NULL)
                 AND (x_failure_score_commentary6 IS NULL)))
        AND ((recinfo.failure_score_commentary7 = x_failure_score_commentary7)
             OR ((recinfo.failure_score_commentary7 IS NULL)
                 AND (x_failure_score_commentary7 IS NULL)))
        AND ((recinfo.failure_score_commentary8 = x_failure_score_commentary8)
             OR ((recinfo.failure_score_commentary8 IS NULL)
                 AND (x_failure_score_commentary8 IS NULL)))
        AND ((recinfo.failure_score_commentary9 = x_failure_score_commentary9)
             OR ((recinfo.failure_score_commentary9 IS NULL)
                 AND (x_failure_score_commentary9 IS NULL)))
        AND ((recinfo.failure_score_commentary10 =
              x_failure_score_commentary10)
             OR ((recinfo.failure_score_commentary10 IS NULL)
                 AND (x_failure_score_commentary10 IS NULL)))
        AND ((recinfo.credit_score_commentary2 = x_credit_score_commentary2)
             OR ((recinfo.credit_score_commentary2 IS NULL)
                 AND (x_credit_score_commentary2 IS NULL)))
        AND ((recinfo.credit_score_commentary3 = x_credit_score_commentary3)
             OR ((recinfo.credit_score_commentary3 IS NULL)
                 AND (x_credit_score_commentary3 IS NULL)))
        AND ((recinfo.credit_score_commentary4 = x_credit_score_commentary4)
             OR ((recinfo.credit_score_commentary4 IS NULL)
                 AND (x_credit_score_commentary4 IS NULL)))
        AND ((recinfo.credit_score_commentary5 = x_credit_score_commentary5)
             OR ((recinfo.credit_score_commentary5 IS NULL)
                 AND (x_credit_score_commentary5 IS NULL)))
        AND ((recinfo.credit_score_commentary6 = x_credit_score_commentary6)
             OR ((recinfo.credit_score_commentary6 IS NULL)
                 AND (x_credit_score_commentary6 IS NULL)))
        AND ((recinfo.credit_score_commentary7 = x_credit_score_commentary7)
             OR ((recinfo.credit_score_commentary7 IS NULL)
                 AND (x_credit_score_commentary7 IS NULL)))
        AND ((recinfo.credit_score_commentary8 = x_credit_score_commentary8)
             OR ((recinfo.credit_score_commentary8 IS NULL)
                 AND (x_credit_score_commentary8 IS NULL)))
        AND ((recinfo.credit_score_commentary9 = x_credit_score_commentary9)
             OR ((recinfo.credit_score_commentary9 IS NULL)
                 AND (x_credit_score_commentary9 IS NULL)))
        AND ((recinfo.credit_score_commentary10 = x_credit_score_commentary10)
             OR ((recinfo.credit_score_commentary10 IS NULL)
                 AND (x_credit_score_commentary10 IS NULL)))
        AND ((recinfo.maximum_credit_recommendation = x_maximum_credit_recomm)
             OR ((recinfo.maximum_credit_recommendation IS NULL)
                 AND (x_maximum_credit_recomm IS NULL)))
        AND ((recinfo.maximum_credit_currency_code =
              x_maximum_credit_currency_code)
             OR ((recinfo.maximum_credit_currency_code IS NULL)
                 AND (x_maximum_credit_currency_code IS NULL)))
        AND ((recinfo.displayed_duns_party_id = x_displayed_duns_party_id)
             OR ((recinfo.displayed_duns_party_id IS NULL)
                 AND (x_displayed_duns_party_id IS NULL)))
        AND ((recinfo.failure_score_natnl_percentile =
              x_failure_score_natnl_perc)
             OR ((recinfo.failure_score_natnl_percentile IS NULL)
                 AND (x_failure_score_natnl_perc IS NULL)))
        AND ((recinfo.duns_number_c = x_duns_number_c)
             OR ((recinfo.duns_number_c IS NULL)
                 AND (x_duns_number_c IS NULL)))
        AND ((recinfo.bank_or_branch_number = x_bank_or_branch_number)
             OR ((recinfo.bank_or_branch_number IS NULL)
                 AND (x_bank_or_branch_number IS NULL)))
        AND ((recinfo.bank_code = x_bank_code)
             OR ((recinfo.bank_code IS NULL)
                 AND (x_bank_code IS NULL)))
        AND ((recinfo.branch_code = x_branch_code)
             OR ((recinfo.branch_code IS NULL)
                 AND (x_branch_code IS NULL)))
        AND ((recinfo.object_version_number = x_object_version_number)
             OR ((recinfo.object_version_number IS NULL)
                 AND (x_object_version_number IS NULL)))
        AND ((recinfo.created_by_module = x_created_by_module)
             OR ((recinfo.created_by_module IS NULL)
                 AND (x_created_by_module IS NULL)))
        AND ((recinfo.application_id = x_application_id)
             OR ((recinfo.application_id IS NULL)
                 AND (x_application_id IS NULL)))
        AND ((recinfo.do_not_confuse_with = x_do_not_confuse_with)
             OR ((recinfo.do_not_confuse_with IS NULL)
                 AND (x_do_not_confuse_with IS NULL)))
        AND ((recinfo.actual_content_source = x_actual_content_source)
             OR ((recinfo.actual_content_source IS NULL)
                 AND (x_actual_content_source IS NULL))))
    THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;

  END lock_row;

  PROCEDURE select_row (
    x_organization_profile_id               IN OUT NOCOPY NUMBER,
    x_party_id                              OUT NOCOPY    NUMBER,
    x_organization_name                     OUT NOCOPY    VARCHAR2,
    x_attribute_category                    OUT NOCOPY    VARCHAR2,
    x_attribute1                            OUT NOCOPY    VARCHAR2,
    x_attribute2                            OUT NOCOPY    VARCHAR2,
    x_attribute3                            OUT NOCOPY    VARCHAR2,
    x_attribute4                            OUT NOCOPY    VARCHAR2,
    x_attribute5                            OUT NOCOPY    VARCHAR2,
    x_attribute6                            OUT NOCOPY    VARCHAR2,
    x_attribute7                            OUT NOCOPY    VARCHAR2,
    x_attribute8                            OUT NOCOPY    VARCHAR2,
    x_attribute9                            OUT NOCOPY    VARCHAR2,
    x_attribute10                           OUT NOCOPY    VARCHAR2,
    x_attribute11                           OUT NOCOPY    VARCHAR2,
    x_attribute12                           OUT NOCOPY    VARCHAR2,
    x_attribute13                           OUT NOCOPY    VARCHAR2,
    x_attribute14                           OUT NOCOPY    VARCHAR2,
    x_attribute15                           OUT NOCOPY    VARCHAR2,
    x_attribute16                           OUT NOCOPY    VARCHAR2,
    x_attribute17                           OUT NOCOPY    VARCHAR2,
    x_attribute18                           OUT NOCOPY    VARCHAR2,
    x_attribute19                           OUT NOCOPY    VARCHAR2,
    x_attribute20                           OUT NOCOPY    VARCHAR2,
    x_enquiry_duns                          OUT NOCOPY    VARCHAR2,
    x_ceo_name                              OUT NOCOPY    VARCHAR2,
    x_ceo_title                             OUT NOCOPY    VARCHAR2,
    x_principal_name                        OUT NOCOPY    VARCHAR2,
    x_principal_title                       OUT NOCOPY    VARCHAR2,
    x_legal_status                          OUT NOCOPY    VARCHAR2,
    x_control_yr                            OUT NOCOPY    NUMBER,
    x_employees_total                       OUT NOCOPY    NUMBER,
    x_hq_branch_ind                         OUT NOCOPY    VARCHAR2,
    x_branch_flag                           OUT NOCOPY    VARCHAR2,
    x_oob_ind                               OUT NOCOPY    VARCHAR2,
    x_line_of_business                      OUT NOCOPY    VARCHAR2,
    x_cong_dist_code                        OUT NOCOPY    VARCHAR2,
    x_sic_code                              OUT NOCOPY    VARCHAR2,
    x_import_ind                            OUT NOCOPY    VARCHAR2,
    x_export_ind                            OUT NOCOPY    VARCHAR2,
    x_labor_surplus_ind                     OUT NOCOPY    VARCHAR2,
    x_debarment_ind                         OUT NOCOPY    VARCHAR2,
    x_minority_owned_ind                    OUT NOCOPY    VARCHAR2,
    x_minority_owned_type                   OUT NOCOPY    VARCHAR2,
    x_woman_owned_ind                       OUT NOCOPY    VARCHAR2,
    x_disadv_8a_ind                         OUT NOCOPY    VARCHAR2,
    x_small_bus_ind                         OUT NOCOPY    VARCHAR2,
    x_rent_own_ind                          OUT NOCOPY    VARCHAR2,
    x_debarments_count                      OUT NOCOPY    NUMBER,
    x_debarments_date                       OUT NOCOPY    DATE,
    x_failure_score                         OUT NOCOPY    VARCHAR2,
    x_failure_score_override_code           OUT NOCOPY    VARCHAR2,
    x_failure_score_commentary              OUT NOCOPY    VARCHAR2,
    x_global_failure_score                  OUT NOCOPY    VARCHAR2,
    x_db_rating                             OUT NOCOPY    VARCHAR2,
    x_credit_score                          OUT NOCOPY    VARCHAR2,
    x_credit_score_commentary               OUT NOCOPY    VARCHAR2,
    x_paydex_score                          OUT NOCOPY    VARCHAR2,
    x_paydex_three_months_ago               OUT NOCOPY    VARCHAR2,
    x_paydex_norm                           OUT NOCOPY    VARCHAR2,
    x_best_time_contact_begin               OUT NOCOPY    DATE,
    x_best_time_contact_end                 OUT NOCOPY    DATE,
    x_organization_name_phonetic            OUT NOCOPY    VARCHAR2,
    x_tax_reference                         OUT NOCOPY    VARCHAR2,
    x_gsa_indicator_flag                    OUT NOCOPY    VARCHAR2,
    x_jgzz_fiscal_code                      OUT NOCOPY    VARCHAR2,
    x_analysis_fy                           OUT NOCOPY    VARCHAR2,
    x_fiscal_yearend_month                  OUT NOCOPY    VARCHAR2,
    x_curr_fy_potential_revenue             OUT NOCOPY    NUMBER,
    x_next_fy_potential_revenue             OUT NOCOPY    NUMBER,
    x_year_established                      OUT NOCOPY    NUMBER,
    x_mission_statement                     OUT NOCOPY    VARCHAR2,
    x_organization_type                     OUT NOCOPY    VARCHAR2,
    x_business_scope                        OUT NOCOPY    VARCHAR2,
    x_corporation_class                     OUT NOCOPY    VARCHAR2,
    x_known_as                              OUT NOCOPY    VARCHAR2,
    x_local_bus_iden_type                   OUT NOCOPY    VARCHAR2,
    x_local_bus_identifier                  OUT NOCOPY    VARCHAR2,
    x_pref_functional_currency              OUT NOCOPY    VARCHAR2,
    x_registration_type                     OUT NOCOPY    VARCHAR2,
    x_total_employees_text                  OUT NOCOPY    VARCHAR2,
    x_total_employees_ind                   OUT NOCOPY    VARCHAR2,
    x_total_emp_est_ind                     OUT NOCOPY    VARCHAR2,
    x_total_emp_min_ind                     OUT NOCOPY    VARCHAR2,
    x_parent_sub_ind                        OUT NOCOPY    VARCHAR2,
    x_incorp_year                           OUT NOCOPY    NUMBER,
    x_content_source_type                   OUT NOCOPY    VARCHAR2,
    x_content_source_number                 OUT NOCOPY    VARCHAR2,
    x_effective_start_date                  OUT NOCOPY    DATE,
    x_effective_end_date                    OUT NOCOPY    DATE,
    x_sic_code_type                         OUT NOCOPY    VARCHAR2,
    x_public_private_ownership              OUT NOCOPY    VARCHAR2,
    x_local_activity_code_type              OUT NOCOPY    VARCHAR2,
    x_local_activity_code                   OUT NOCOPY    VARCHAR2,
    x_emp_at_primary_adr                    OUT NOCOPY    VARCHAR2,
    x_emp_at_primary_adr_text               OUT NOCOPY    VARCHAR2,
    x_emp_at_primary_adr_est_ind            OUT NOCOPY    VARCHAR2,
    x_emp_at_primary_adr_min_ind            OUT NOCOPY    VARCHAR2,
    x_internal_flag                         OUT NOCOPY    VARCHAR2,
    x_high_credit                           OUT NOCOPY    NUMBER,
    x_avg_high_credit                       OUT NOCOPY    NUMBER,
    x_total_payments                        OUT NOCOPY    NUMBER,
    x_known_as2                             OUT NOCOPY    VARCHAR2,
    x_known_as3                             OUT NOCOPY    VARCHAR2,
    x_known_as4                             OUT NOCOPY    VARCHAR2,
    x_known_as5                             OUT NOCOPY    VARCHAR2,
    x_credit_score_class                    OUT NOCOPY    NUMBER,
    x_credit_score_natl_percentile          OUT NOCOPY    NUMBER,
    x_credit_score_incd_default             OUT NOCOPY    NUMBER,
    x_credit_score_age                      OUT NOCOPY    NUMBER,
    x_credit_score_date                     OUT NOCOPY    DATE,
    x_failure_score_class                   OUT NOCOPY    NUMBER,
    x_failure_score_incd_default            OUT NOCOPY    NUMBER,
    x_failure_score_age                     OUT NOCOPY    NUMBER,
    x_failure_score_date                    OUT NOCOPY    DATE,
    x_failure_score_commentary2             OUT NOCOPY    VARCHAR2,
    x_failure_score_commentary3             OUT NOCOPY    VARCHAR2,
    x_failure_score_commentary4             OUT NOCOPY    VARCHAR2,
    x_failure_score_commentary5             OUT NOCOPY    VARCHAR2,
    x_failure_score_commentary6             OUT NOCOPY    VARCHAR2,
    x_failure_score_commentary7             OUT NOCOPY    VARCHAR2,
    x_failure_score_commentary8             OUT NOCOPY    VARCHAR2,
    x_failure_score_commentary9             OUT NOCOPY    VARCHAR2,
    x_failure_score_commentary10            OUT NOCOPY    VARCHAR2,
    x_credit_score_commentary2              OUT NOCOPY    VARCHAR2,
    x_credit_score_commentary3              OUT NOCOPY    VARCHAR2,
    x_credit_score_commentary4              OUT NOCOPY    VARCHAR2,
    x_credit_score_commentary5              OUT NOCOPY    VARCHAR2,
    x_credit_score_commentary6              OUT NOCOPY    VARCHAR2,
    x_credit_score_commentary7              OUT NOCOPY    VARCHAR2,
    x_credit_score_commentary8              OUT NOCOPY    VARCHAR2,
    x_credit_score_commentary9              OUT NOCOPY    VARCHAR2,
    x_credit_score_commentary10             OUT NOCOPY    VARCHAR2,
    x_maximum_credit_recomm                 OUT NOCOPY    NUMBER,
    x_maximum_credit_currency_code          OUT NOCOPY    VARCHAR2,
    x_displayed_duns_party_id               OUT NOCOPY    NUMBER,
    x_failure_score_natnl_perc              OUT NOCOPY    NUMBER,
    x_duns_number_c                         OUT NOCOPY    VARCHAR2,
    x_bank_or_branch_number                 OUT NOCOPY    VARCHAR2,
    x_bank_code                             OUT NOCOPY    VARCHAR2,
    x_branch_code                           OUT NOCOPY    VARCHAR2,
    x_created_by_module                     OUT NOCOPY    VARCHAR2,
    x_application_id                        OUT NOCOPY    NUMBER,
    x_do_not_confuse_with                   OUT NOCOPY    VARCHAR2,
    x_actual_content_source                 OUT NOCOPY    VARCHAR2,
    x_home_country                          OUT NOCOPY    VARCHAR2
  ) IS
    CURSOR c_orgprof IS
      SELECT NVL(hop.organization_profile_id, fnd_api.g_miss_num),
             NVL(hop.party_id, fnd_api.g_miss_num),
             NVL(hop.organization_name, fnd_api.g_miss_char),
             NVL(hop.attribute_category, fnd_api.g_miss_char),
             NVL(hop.attribute1, fnd_api.g_miss_char),
             NVL(hop.attribute2, fnd_api.g_miss_char),
             NVL(hop.attribute3, fnd_api.g_miss_char),
             NVL(hop.attribute4, fnd_api.g_miss_char),
             NVL(hop.attribute5, fnd_api.g_miss_char),
             NVL(hop.attribute6, fnd_api.g_miss_char),
             NVL(hop.attribute7, fnd_api.g_miss_char),
             NVL(hop.attribute8, fnd_api.g_miss_char),
             NVL(hop.attribute9, fnd_api.g_miss_char),
             NVL(hop.attribute10, fnd_api.g_miss_char),
             NVL(hop.attribute11, fnd_api.g_miss_char),
             NVL(hop.attribute12, fnd_api.g_miss_char),
             NVL(hop.attribute13, fnd_api.g_miss_char),
             NVL(hop.attribute14, fnd_api.g_miss_char),
             NVL(hop.attribute15, fnd_api.g_miss_char),
             NVL(hop.attribute16, fnd_api.g_miss_char),
             NVL(hop.attribute17, fnd_api.g_miss_char),
             NVL(hop.attribute18, fnd_api.g_miss_char),
             NVL(hop.attribute19, fnd_api.g_miss_char),
             NVL(hop.attribute20, fnd_api.g_miss_char),
             NVL(hop.enquiry_duns, fnd_api.g_miss_char),
             NVL(hop.ceo_name, fnd_api.g_miss_char),
             NVL(hop.ceo_title, fnd_api.g_miss_char),
             NVL(hop.principal_name, fnd_api.g_miss_char),
             NVL(hop.principal_title, fnd_api.g_miss_char),
             NVL(hop.legal_status, fnd_api.g_miss_char),
             NVL(hop.control_yr, fnd_api.g_miss_num),
             NVL(hop.employees_total, fnd_api.g_miss_num),
             NVL(hop.hq_branch_ind, fnd_api.g_miss_char),
             NVL(hop.branch_flag, fnd_api.g_miss_char),
             NVL(hop.oob_ind, fnd_api.g_miss_char),
             NVL(hop.line_of_business, fnd_api.g_miss_char),
             NVL(hop.cong_dist_code, fnd_api.g_miss_char),
             NVL(hop.sic_code, fnd_api.g_miss_char),
             NVL(hop.import_ind, fnd_api.g_miss_char),
             NVL(hop.export_ind, fnd_api.g_miss_char),
             NVL(hop.labor_surplus_ind, fnd_api.g_miss_char),
             NVL(hop.debarment_ind, fnd_api.g_miss_char),
             NVL(hop.minority_owned_ind, fnd_api.g_miss_char),
             NVL(hop.minority_owned_type, fnd_api.g_miss_char),
             NVL(hop.woman_owned_ind, fnd_api.g_miss_char),
             NVL(hop.disadv_8a_ind, fnd_api.g_miss_char),
             NVL(hop.small_bus_ind, fnd_api.g_miss_char),
             NVL(hop.rent_own_ind, fnd_api.g_miss_char),
             NVL(hop.debarments_count, fnd_api.g_miss_num),
             NVL(hop.debarments_date, fnd_api.g_miss_date),
             NVL(hop.failure_score, fnd_api.g_miss_char),
             NVL(hop.failure_score_override_code, fnd_api.g_miss_char),
             NVL(hop.failure_score_commentary, fnd_api.g_miss_char),
             NVL(hop.global_failure_score, fnd_api.g_miss_char),
             NVL(hop.db_rating, fnd_api.g_miss_char),
             NVL(hop.credit_score, fnd_api.g_miss_char),
             NVL(hop.credit_score_commentary, fnd_api.g_miss_char),
             NVL(hop.paydex_score, fnd_api.g_miss_char),
             NVL(hop.paydex_three_months_ago, fnd_api.g_miss_char),
             NVL(hop.paydex_norm, fnd_api.g_miss_char),
             NVL(hop.best_time_contact_begin, fnd_api.g_miss_date),
             NVL(hop.best_time_contact_end, fnd_api.g_miss_date),
             NVL(hop.organization_name_phonetic, fnd_api.g_miss_char),
             NVL(hop.tax_reference, fnd_api.g_miss_char),
             NVL(hop.gsa_indicator_flag, fnd_api.g_miss_char),
             NVL(hop.jgzz_fiscal_code, fnd_api.g_miss_char),
             NVL(hop.analysis_fy, fnd_api.g_miss_char),
             NVL(hop.fiscal_yearend_month, fnd_api.g_miss_char),
             NVL(hop.curr_fy_potential_revenue, fnd_api.g_miss_num),
             NVL(hop.next_fy_potential_revenue, fnd_api.g_miss_num),
             NVL(hop.year_established, fnd_api.g_miss_num),
             NVL(hop.mission_statement, fnd_api.g_miss_char),
             NVL(hop.organization_type, fnd_api.g_miss_char),
             NVL(hop.business_scope, fnd_api.g_miss_char),
             NVL(hop.corporation_class, fnd_api.g_miss_char),
             NVL(hop.known_as, fnd_api.g_miss_char),
             NVL(hop.local_bus_iden_type, fnd_api.g_miss_char),
             NVL(hop.local_bus_identifier, fnd_api.g_miss_char),
             NVL(hop.pref_functional_currency, fnd_api.g_miss_char),
             NVL(hop.registration_type, fnd_api.g_miss_char),
             NVL(hop.total_employees_text, fnd_api.g_miss_char),
             NVL(hop.total_employees_ind, fnd_api.g_miss_char),
             NVL(hop.total_emp_est_ind, fnd_api.g_miss_char),
             NVL(hop.total_emp_min_ind, fnd_api.g_miss_char),
             NVL(hop.parent_sub_ind, fnd_api.g_miss_char),
             NVL(hop.incorp_year, fnd_api.g_miss_num),
             NVL(hop.content_source_type, fnd_api.g_miss_char),
             NVL(hop.content_source_number, fnd_api.g_miss_char),
             NVL(hop.effective_start_date, fnd_api.g_miss_date),
             NVL(hop.effective_end_date, fnd_api.g_miss_date),
             NVL(hop.sic_code_type, fnd_api.g_miss_char),
             NVL(hop.public_private_ownership_flag, fnd_api.g_miss_char),
             NVL(hop.local_activity_code_type, fnd_api.g_miss_char),
             NVL(hop.local_activity_code, fnd_api.g_miss_char),
             NVL(hop.emp_at_primary_adr, fnd_api.g_miss_char),
             NVL(hop.emp_at_primary_adr_text, fnd_api.g_miss_char),
             NVL(hop.emp_at_primary_adr_est_ind, fnd_api.g_miss_char),
             NVL(hop.emp_at_primary_adr_min_ind, fnd_api.g_miss_char),
             NVL(hop.internal_flag, fnd_api.g_miss_char),
             NVL(hop.high_credit, fnd_api.g_miss_num),
             NVL(hop.avg_high_credit, fnd_api.g_miss_num),
             NVL(hop.total_payments, fnd_api.g_miss_num),
             NVL(hop.known_as2, fnd_api.g_miss_char),
             NVL(hop.known_as3, fnd_api.g_miss_char),
             NVL(hop.known_as4, fnd_api.g_miss_char),
             NVL(hop.known_as5, fnd_api.g_miss_char),
             NVL(hop.credit_score_class, fnd_api.g_miss_num),
             NVL(hop.credit_score_natl_percentile, fnd_api.g_miss_num),
             NVL(hop.credit_score_incd_default, fnd_api.g_miss_num),
             NVL(hop.credit_score_age, fnd_api.g_miss_num),
             NVL(hop.credit_score_date, fnd_api.g_miss_date),
             NVL(hop.failure_score_class, fnd_api.g_miss_num),
             NVL(hop.failure_score_incd_default, fnd_api.g_miss_num),
             NVL(hop.failure_score_age, fnd_api.g_miss_num),
             NVL(hop.failure_score_date, fnd_api.g_miss_date),
             NVL(hop.failure_score_commentary2, fnd_api.g_miss_char),
             NVL(hop.failure_score_commentary3, fnd_api.g_miss_char),
             NVL(hop.failure_score_commentary4, fnd_api.g_miss_char),
             NVL(hop.failure_score_commentary5, fnd_api.g_miss_char),
             NVL(hop.failure_score_commentary6, fnd_api.g_miss_char),
             NVL(hop.failure_score_commentary7, fnd_api.g_miss_char),
             NVL(hop.failure_score_commentary8, fnd_api.g_miss_char),
             NVL(hop.failure_score_commentary9, fnd_api.g_miss_char),
             NVL(hop.failure_score_commentary10, fnd_api.g_miss_char),
             NVL(hop.credit_score_commentary2, fnd_api.g_miss_char),
             NVL(hop.credit_score_commentary3, fnd_api.g_miss_char),
             NVL(hop.credit_score_commentary4, fnd_api.g_miss_char),
             NVL(hop.credit_score_commentary5, fnd_api.g_miss_char),
             NVL(hop.credit_score_commentary6, fnd_api.g_miss_char),
             NVL(hop.credit_score_commentary7, fnd_api.g_miss_char),
             NVL(hop.credit_score_commentary8, fnd_api.g_miss_char),
             NVL(hop.credit_score_commentary9, fnd_api.g_miss_char),
             NVL(hop.credit_score_commentary10, fnd_api.g_miss_char),
             NVL(hop.maximum_credit_recommendation, fnd_api.g_miss_num),
             NVL(hop.maximum_credit_currency_code, fnd_api.g_miss_char),
             NVL(hop.displayed_duns_party_id, fnd_api.g_miss_num),
             NVL(hop.failure_score_natnl_percentile, fnd_api.g_miss_num),
             NVL(hop.duns_number_c, fnd_api.g_miss_char),
             NVL(hop.bank_or_branch_number, fnd_api.g_miss_char),
             NVL(hop.bank_code, fnd_api.g_miss_char),
             NVL(hop.branch_code, fnd_api.g_miss_char),
             NVL(hop.created_by_module, fnd_api.g_miss_char),
             NVL(hop.application_id, fnd_api.g_miss_num),
             NVL(hop.do_not_confuse_with, fnd_api.g_miss_char),
             NVL(hop.actual_content_source, fnd_api.g_miss_char),
             NVL(hop.home_country, fnd_api.g_miss_char)
      FROM   hz_organization_profiles hop
      WHERE  hop.organization_profile_id = x_organization_profile_id;
  BEGIN
    OPEN c_orgprof;
    FETCH c_orgprof
    INTO  x_organization_profile_id,
          x_party_id,
          x_organization_name,
          x_attribute_category,
          x_attribute1,
          x_attribute2,
          x_attribute3,
          x_attribute4,
          x_attribute5,
          x_attribute6,
          x_attribute7,
          x_attribute8,
          x_attribute9,
          x_attribute10,
          x_attribute11,
          x_attribute12,
          x_attribute13,
          x_attribute14,
          x_attribute15,
          x_attribute16,
          x_attribute17,
          x_attribute18,
          x_attribute19,
          x_attribute20,
          x_enquiry_duns,
          x_ceo_name,
          x_ceo_title,
          x_principal_name,
          x_principal_title,
          x_legal_status,
          x_control_yr,
          x_employees_total,
          x_hq_branch_ind,
          x_branch_flag,
          x_oob_ind,
          x_line_of_business,
          x_cong_dist_code,
          x_sic_code,
          x_import_ind,
          x_export_ind,
          x_labor_surplus_ind,
          x_debarment_ind,
          x_minority_owned_ind,
          x_minority_owned_type,
          x_woman_owned_ind,
          x_disadv_8a_ind,
          x_small_bus_ind,
          x_rent_own_ind,
          x_debarments_count,
          x_debarments_date,
          x_failure_score,
          x_failure_score_override_code,
          x_failure_score_commentary,
          x_global_failure_score,
          x_db_rating,
          x_credit_score,
          x_credit_score_commentary,
          x_paydex_score,
          x_paydex_three_months_ago,
          x_paydex_norm,
          x_best_time_contact_begin,
          x_best_time_contact_end,
          x_organization_name_phonetic,
          x_tax_reference,
          x_gsa_indicator_flag,
          x_jgzz_fiscal_code,
          x_analysis_fy,
          x_fiscal_yearend_month,
          x_curr_fy_potential_revenue,
          x_next_fy_potential_revenue,
          x_year_established,
          x_mission_statement,
          x_organization_type,
          x_business_scope,
          x_corporation_class,
          x_known_as,
          x_local_bus_iden_type,
          x_local_bus_identifier,
          x_pref_functional_currency,
          x_registration_type,
          x_total_employees_text,
          x_total_employees_ind,
          x_total_emp_est_ind,
          x_total_emp_min_ind,
          x_parent_sub_ind,
          x_incorp_year,
          x_content_source_type,
          x_content_source_number,
          x_effective_start_date,
          x_effective_end_date,
          x_sic_code_type,
          x_public_private_ownership,
          x_local_activity_code_type,
          x_local_activity_code,
          x_emp_at_primary_adr,
          x_emp_at_primary_adr_text,
          x_emp_at_primary_adr_est_ind,
          x_emp_at_primary_adr_min_ind,
          x_internal_flag,
          x_high_credit,
          x_avg_high_credit,
          x_total_payments,
          x_known_as2,
          x_known_as3,
          x_known_as4,
          x_known_as5,
          x_credit_score_class,
          x_credit_score_natl_percentile,
          x_credit_score_incd_default,
          x_credit_score_age,
          x_credit_score_date,
          x_failure_score_class,
          x_failure_score_incd_default,
          x_failure_score_age,
          x_failure_score_date,
          x_failure_score_commentary2,
          x_failure_score_commentary3,
          x_failure_score_commentary4,
          x_failure_score_commentary5,
          x_failure_score_commentary6,
          x_failure_score_commentary7,
          x_failure_score_commentary8,
          x_failure_score_commentary9,
          x_failure_score_commentary10,
          x_credit_score_commentary2,
          x_credit_score_commentary3,
          x_credit_score_commentary4,
          x_credit_score_commentary5,
          x_credit_score_commentary6,
          x_credit_score_commentary7,
          x_credit_score_commentary8,
          x_credit_score_commentary9,
          x_credit_score_commentary10,
          x_maximum_credit_recomm,
          x_maximum_credit_currency_code,
          x_displayed_duns_party_id,
          x_failure_score_natnl_perc,
          x_duns_number_c,
          x_bank_or_branch_number,
          x_bank_code,
          x_branch_code,
          x_created_by_module,
          x_application_id,
          x_do_not_confuse_with,
          x_actual_content_source,
          x_home_country;
    IF c_orgprof%NOTFOUND THEN
      CLOSE c_orgprof;
      fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
      fnd_message.set_token('RECORD', 'organization_rec');
      fnd_message.set_token('VALUE', TO_CHAR(x_organization_profile_id));
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_orgprof;
  END select_row;

  PROCEDURE delete_row (x_organization_profile_id IN NUMBER) IS
  BEGIN

    DELETE FROM hz_organization_profiles hop
    WHERE  hop.organization_profile_id = x_organization_profile_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END Delete_Row;

END HZ_organization_profiles_pkg;

/
