--------------------------------------------------------
--  DDL for Package Body AMS_DMEXTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DMEXTRACT_PVT" AS
/* $Header: amsvdxtb.pls 120.2 2006/01/27 05:52:03 kbasavar noship $ */

G_MODE_UPDATE        CONSTANT VARCHAR2(30) := 'U';
-- start of changes by amisingh for campaign ScheduleLOV
G_MEDIA_EMAIL        CONSTANT NUMBER := 20;
G_MEDIA_TELEMARKETING        CONSTANT NUMBER := 460;
G_MEDIA_DIRECTMAIL        CONSTANT NUMBER := 480;
-- end of changes by amisingh

--
-- Foreward Declarations of Procedures
--
PROCEDURE analyze_mining_tables;

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE InsertDrvStgIns (
   p_object_id    IN NUMBER,
   p_object_type  IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE InsertGenStg(
   p_is_b2b IN BOOLEAN,
   p_model_type  IN VARCHAR2,
   p_is_org_prod IN BOOLEAN
);

PROCEDURE InsertExpStg(
  p_is_b2b IN BOOLEAN,
  p_model_type  IN VARCHAR2,
  p_is_org_prod IN BOOLEAN
);

PROCEDURE InsertAggStg(
   p_is_b2b IN BOOLEAN
);

PROCEDURE InsertAggStgOrg;

PROCEDURE InsertBICStg(
   p_is_b2b IN BOOLEAN,
   p_model_type  IN VARCHAR2,
   p_is_org_prod IN BOOLEAN
);

PROCEDURE InsertPartyDetails (x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE InsertPartyDetailsTime (x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE InsertDrvStgUpd (
   p_party_type  IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE UpdatePartyDetails;

PROCEDURE UpdatePartyDetailsTime;

-- kbasavar migrated chi's changes for bug 3089951
-- Synchronizes the records of both ams_dm_party_details
-- and ams_dm_party_details_time.  The commits done at
-- the end of each procedure to release rollback space
-- could cause the records to go out of sync if one table's
-- insert completes while the other fails.
PROCEDURE sync_party_tables;


--
-- Procedure Bodies
--
-- ******** OBSOLETED ***********
-- kbasavar migrated chi's changes for bug 3089951
-- nyostos - Sept 10, 2003 - Commented out procedure
--
-- Procedure DeleteStg
-- This has been added temporarily till we figure out how to
-- execute Truncate Table. This proc must be removed after
-- a truncate table procedure is resolved.

--PROCEDURE DeleteStg
--IS
--   l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Stg';
--   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
--   l_return_status   VARCHAR2(1);
--BEGIN

   --------------------- initialize -----------------------
--   SAVEPOINT Delete_Stg;

--   IF (AMS_DEBUG_HIGH_ON) THEN
--      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
--   END IF;

   -- Delete all staging tables

--   DELETE FROM ams_dm_drv_stg;
--   DELETE FROM ams_dm_gen_stg;
--   DELETE FROM ams_dm_agg_stg;
--   DELETE FROM ams_dm_bic_stg;
--   DELETE FROM ams_dm_perint_stg;
--   DELETE FROM ams_dm_finnum_stg;
--   DELETE FROM ams_dm_party_profile_stg;

   -------------------- finish --------------------------
--   IF (AMS_DEBUG_HIGH_ON) THEN
--      AMS_Utility_PVT.debug_message (l_full_name || ': End');
--   END IF;

--END DeleteStg;


PROCEDURE TruncateTable (
   p_table IN VARCHAR2
)
   IS
   -- Does the DDL for each table

   l_api_name     CONSTANT VARCHAR2(30) := 'TruncateTable';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_result          BOOLEAN;
   l_status          VARCHAR2(10);
   l_industry        VARCHAR2(10);
   l_ams_schema      VARCHAR2(30);
BEGIN
   --------------------perform truncate table---------------
   l_result := fnd_installation.get_app_info(
                  'AMS',
                  l_status,
                  l_industry,
                  l_ams_schema
               );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ':: table : ' || l_ams_schema || '.' || p_table);
   END IF;

   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || l_ams_schema || '.' || p_table);

END TruncateTable;

PROCEDURE TruncateStgTables
IS
-- TruncateStgTables
-- This procedure cleans up the staging area prior to performing any data
-- extraction. Run this proc before all data loads. Do not purge the
-- data after the load is complete. Purge just prior to next load.
   l_api_name     CONSTANT VARCHAR2(30) := 'TruncateStgTables';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN

   --------------------- initialize -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   -------------truncate all stage tables---------------------
   -- nyostos - Sep 11, 2002
   -- Changes related to parallel mining processes using Global Temporary Tables
   --TruncateTable ('AMS_DM_DRV_STG');
   --TruncateTable ('AMS_DM_GEN_STG');
   --TruncateTable ('AMS_DM_PERINT_STG');
   --TruncateTable ('AMS_DM_FINNUM_STG');
   --TruncateTable ('AMS_DM_PARTY_PROFILE_STG');
   --TruncateTable ('AMS_DM_AGG_STG');
   --TruncateTable ('AMS_DM_BIC_STG');

   TruncateTable ('AMS_DM_DRV_STG_GT');
   TruncateTable ('AMS_DM_GEN_STG_GT');
   TruncateTable ('AMS_DM_PERINT_STG_GT');
   TruncateTable ('AMS_DM_FINNUM_STG_GT');
   TruncateTable ('AMS_DM_PROFILE_STG_GT');
   TruncateTable ('AMS_DM_AGG_STG_GT');
   TruncateTable ('AMS_DM_BIC_STG_GT');

   -------------------- finish --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

END TruncateStgTables;
-- End of Purge of the staging area

PROCEDURE InsertDrvStgIns (
   p_object_id    IN NUMBER,
   p_object_type  IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'InsertDrvStgIns';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Insert_Drv_Stg_Ins;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   ----------------------- Insert ----------------------
   -- Insert new records in Driving Stage

   -- nyostos - Sept 11, 2003
   -- changes for parallel mining processes using global temporary tables
   --INSERT  -- /*+ APPEND PARALLEL(AMS_DM_DRV_STG,DEFAULT,DEFAULT)*/
   --INTO ams_dm_drv_stg (
   INSERT  -- /*+ APPEND PARALLEL(AMS_DM_DRV_STG_GT,DEFAULT,DEFAULT)*/
   INTO ams_dm_drv_stg_gt (party_id)
   SELECT ads.party_id  party_id
   FROM   ams_dm_source ads
   WHERE ads.used_for_object_id = p_object_id
    AND ads.arc_used_for_object = p_object_type
    AND NOT EXISTS (
        SELECT pdt.party_id party_id
        FROM ams_dm_party_details pdt
        WHERE ads.party_id = pdt.party_id
        );

   -------------------- finish --------------------------
   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Drv_Stg_Ins;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

END InsertDrvStgIns;
-- End inserting into Driving Stage for the Insert Process.

PROCEDURE InsertDrvStgUpd (
   p_party_type  IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2
)
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'InsertDrvStgUpd';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Insert_Drv_Stg_Upd;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   ----------------------- Insert ----------------------
   -- Insert party_ids in Driving Stage that have been updated since last load.

   -- nyostos - Sept 11, 2003
   -- changes for parallel mining processes using global temporary tables

   --INSERT -- /*+ APPEND PARALLEL(AMS_DM_DRV_STG,DEFAULT,DEFAULT)*/
   --INTO ams_dm_drv_stg (
   -- kbasavar 6/11/2004 Commented out the exists condition for bug 3278796
   -- This could be a candidate for a performance issue in the future.  As we will go against all parties in party details
   -- The table could grow significantly in time
   INSERT -- /*+ APPEND PARALLEL(AMS_DM_DRV_STG_GT,DEFAULT,DEFAULT)*/
   INTO ams_dm_drv_stg_gt (
       party_id)
   SELECT x.party_id
   FROM ams_dm_party_details x
   WHERE x.party_type = p_party_type
/*   AND EXISTS (
                 (SELECT a.party_id
                  FROM hz_parties a
                  WHERE a.last_update_date > x.last_update_date
                  AND a.party_id = x.party_id
                  AND a.status = 'A')
                  UNION ALL
                 (SELECT b.party_id
                  FROM hz_person_profiles b
                  WHERE b.last_update_date > x.last_update_date
                  AND b.party_id = x.party_id
                  AND SYSDATE BETWEEN b.effective_start_date AND NVL(b.effective_end_date,SYSDATE))
                  UNION ALL
                 (SELECT c.party_id
                  FROM hz_relationships c
                  WHERE c.last_update_date > x.last_update_date
                  AND c.subject_table_name = 'HZ_PARTIES'
                  AND c.object_table_name = 'HZ_PARTIES'
                  AND c.directional_flag = 'F'
                  AND c.party_id = x.party_id
                  AND c.status = 'A' AND SYSDATE BETWEEN c.start_date AND NVL(c.end_date,SYSDATE))
                  UNION ALL
                 (SELECT d.party_id
                  FROM hz_organization_profiles d
                  WHERE d.last_update_date > x.last_update_date
                  AND d.party_id = x.party_id
                  AND SYSDATE BETWEEN d.effective_start_date AND NVL(d.effective_end_date,SYSDATE))
		            UNION ALL
                 (SELECT e.party_id
                  FROM hz_employment_history e
                  WHERE e.last_update_date > x.last_update_date
                  AND e.party_id = x.party_id
                  AND e.status = 'A')
                  UNION ALL
                 (SELECT f.party_id
                  FROM hz_person_interest f
                  WHERE f.last_update_date > x.last_update_date
                  AND f.party_id = x.party_id
                  AND f.status = 'A')
                 )
*/
                 ;
   -------------------- finish --------------------------
   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Drv_Stg_Upd;
      -- kbasavar migrated chi's changes for 3089951
      x_return_status := FND_API.g_ret_sts_error;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
END InsertDrvStgUpd;
-- End of identifying changed party ids.

PROCEDURE InsertGenStg(
      p_is_b2b       IN BOOLEAN,
      p_model_type IN VARCHAR2,
      p_is_org_prod IN BOOLEAN
)
IS
-- Insert Data in staging area for simple 1-1 mapping..
   l_api_name     CONSTANT VARCHAR2(30) := 'InsertGenStg';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_is_b2b    BOOLEAN;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Insert_Gen_Stg;

   l_is_b2b:=p_is_b2b; --kbasavar 07/14/2003

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   ----------------------- Insert ----------------------
/*********** Correction made in code   krmukher 03/19/2001 ********************/
   IF l_is_b2b THEN
      -- Insert for B2B
      IF p_model_type = 'CUSTOMER_PROFITABILITY' OR p_is_org_prod THEN
         INSERT /*+ first_rows*/
--       INTO ams_dm_gen_stg (
         INTO ams_dm_gen_stg_gt (
            party_id,
            party_type,
            country,
            state,
            province,
            county,
            zip_code,
            paydex_score_year,
            paydex_score_3_month_ago,
            industry_paydex_median,
            global_failure_score,
            dnb_score,
            out_of_business_flag,
            customer_quality_rank,
            fortune_500_rank,
            num_of_employees,
            legal_status,
            year_established,
            sic_code1,
            minority_business_flag,
            small_business_flag,
            women_owned_bus_flag,
            gov_org_flag,
            hq_subsidiary_flag,
            foreign_owned_flag,
            import_export_bus_flag,
            email_address,
            address1,
            address2,
            competitor_flag,
            third_party_flag,
            control_yr,
            line_of_business,
            cong_dist_code,
            labor_surplus_flag,
            debarment_flag,
            disadv_8a_flag,
            debarments_count,
            months_since_last_debarment,
            gsa_indicator_flag,
            analysis_fy,
            fiscal_yearend_month,
            curr_fy_potential_revenue,
            next_fy_potential_revenue,
            organization_type,
            business_scope,
            corporation_class,
            registration_type,
            incorp_year,
            public_private_ownership_flag,
            internal_flag,
            high_credit,
            avg_high_credit,
            total_payments,
            credit_score_class,
            credit_score_natl_percentile,
            credit_score_incd_default,
            credit_score_age,
            failure_score_class,
            failure_score_incd_default,
            failure_score_age,
            maximum_credit_recommendation,
            maximum_credit_currency_code,
            party_name,
            city
            )
         SELECT
            drv.party_id party_id,
            hzp.party_type party_type,
            hzp.country country,
            hzp.state state,
            hzp.province     province,
            hzp.county county,
            hzp.postal_code zip_code,
            hop.paydex_score paydex_score_year,
            hop.paydex_three_months_ago paydex_score_3_month_avg,
            hop.paydex_norm     industry_paydex_median,
            hop.global_failure_score global_failure_score,
            hop.db_rating dnb_score,
            hop.oob_ind out_of_business_flag,
            NULL customer_quality_rank,
            NULL fortune_500_rank,
            hop.employees_total     num_of_employees,
            hop.legal_status legal_status,
            hop.year_established     year_established,
            hop.sic_code sic_code1,
            hop.minority_owned_ind     minority_business_flag,
            hop.small_bus_ind small_business_flag,
            hop.woman_owned_ind women_owned_bus_flag,
            NULL gov_org_flag,
            NULL hq_subsidiary_flag,
            NULL foreign_owned_flag,
            DECODE (hop.import_ind || hop.export_ind, 'YY', 'Y', 'YN', 'Y', 'NY', 'Y', 'Y', 'Y', NULL, NULL, 'N') import_export_bus_flag,
            hzp.email_address,
            hzp.address1,
            hzp.address2,
            hzp.competitor_flag,
            hzp.third_party_flag,
            hop.control_yr,
            hop.line_of_business,
            hop.cong_dist_code,
            hop.labor_surplus_ind,
            hop.debarment_ind,
            hop.disadv_8a_ind,
            hop.debarments_count,
            ABS (MONTHS_BETWEEN (SYSDATE, hop.debarments_date)),
            hop.gsa_indicator_flag,
            hop.analysis_fy,
            hop.fiscal_yearend_month,
            hop.curr_fy_potential_revenue,
            hop.next_fy_potential_revenue,
            hop.organization_type,
            hop.business_scope,
            hop.corporation_class,
            hop.registration_type,
            hop.incorp_year,
            hop.public_private_ownership_flag,
            hop.internal_flag,
            hop.high_credit,
            hop.avg_high_credit,
            hop.total_payments,
            hop.credit_score_class,
            hop.credit_score_natl_percentile,
            hop.credit_score_incd_default,
            hop.credit_score_age,
            hop.failure_score_class,
            hop.failure_score_incd_default,
            hop.failure_score_age,
            hop.maximum_credit_recommendation,
            hop.maximum_credit_currency_code,
            hzp.party_name,
            hzp.city
            FROM
--          ams_dm_drv_stg           drv,
            ams_dm_drv_stg_gt        drv,       -- nysotos - Sep 15, 2003 - Global Temp Table
            hz_organization_profiles hop,
            hz_parties               hzp
        WHERE
            drv.party_id = hzp.party_id
            AND  hzp.status = 'A'
            AND  hop.party_id(+) = hzp.party_id
            AND  hop.status(+) = 'A'
	    AND (SYSDATE BETWEEN hop.effective_start_date(+) and NVL(hop.effective_end_date(+),SYSDATE));
      ELSE
         INSERT /*+ first_rows*/
--       INTO ams_dm_gen_stg (
         INTO ams_dm_gen_stg_gt (               -- nysotos - Sep 15, 2003 - Global Temp Table
            party_id,
            party_type,
            gender,
            ethnicity,
            marital_status,
            personal_income,
            hoh_flag,
            household_income,
            household_size,
            rent_flag,
            degree_received,
            school_type,
            employed_flag,
            years_employed,
            occupation,
            military_branch,
            presence_of_children,
            country,
            state,
            province,
            county,
            zip_code,
            reference_use_flag,
            paydex_score_year,
            paydex_score_3_month_ago,
            industry_paydex_median,
            global_failure_score,
            dnb_score,
            out_of_business_flag,
            customer_quality_rank,
            fortune_500_rank,
            num_of_employees,
            legal_status,
            year_established,
            sic_code1,
            minority_business_flag,
            small_business_flag,
            women_owned_bus_flag,
            gov_org_flag,
            hq_subsidiary_flag,
            foreign_owned_flag,
            import_export_bus_flag,
            email_address,
            address1,
            address2,
            competitor_flag,
            third_party_flag,
            person_first_name,
            person_middle_name,
            person_last_name,
            person_name_suffix,
            person_title,
            person_academic_title,
            person_pre_name_adjunct,
            control_yr,
            line_of_business,
            cong_dist_code,
            labor_surplus_flag,
            debarment_flag,
            disadv_8a_flag,
            debarments_count,
            months_since_last_debarment,
            gsa_indicator_flag,
            analysis_fy,
            fiscal_yearend_month,
            curr_fy_potential_revenue,
            next_fy_potential_revenue,
            organization_type,
            business_scope,
            corporation_class,
            registration_type,
            incorp_year,
            public_private_ownership_flag,
            internal_flag,
            high_credit,
            avg_high_credit,
            total_payments,
            credit_score_class,
            credit_score_natl_percentile,
            credit_score_incd_default,
            credit_score_age,
            failure_score_class,
            failure_score_incd_default,
            failure_score_age,
            maximum_credit_recommendation,
            maximum_credit_currency_code,
            party_name,
            city
         )
         SELECT
            drv.party_id party_id,
            hzp.party_type party_type,
            hpp.gender     gender,
            hpp.declared_ethnicity ethnicity,
            hpp.marital_status marital_status,
            hpp.personal_income personal_income,
            hpp.head_of_household_flag hoh_flag,
            hpp.household_income household_income,
            hpp.household_size household_size,
            DECODE(hpp.rent_own_ind, 'RENT', 1, 0) rent_flag,
            NULL degree_received,
            NULL school_type,
            DECODE(heh.end_date, NULL, 1, 0) employed_flag,
            DECODE(heh.end_date, NULL, (SYSDATE - heh.begin_date)/365 , (heh.end_date - heh.begin_date)/365) years_employed,
            DECODE(heh.end_date, NULL, heh.employed_as_title, 'UNEMPLOYED') occupation,
            heh.branch military_branch,
            NULL  num_of_children,
            hzp.country country,
            hzp.state state,
            hzp.province     province,
            hzp.county county,
            hzp.postal_code zip_code,
            hoc.reference_use_flag     reference_use_flag,
            hop.paydex_score paydex_score_year,
            hop.paydex_three_months_ago paydex_score_3_month_avg,
            hop.paydex_norm     industry_paydex_median,
            hop.global_failure_score global_failure_score,
            hop.db_rating dnb_score,
            hop.oob_ind out_of_business_flag,
            NULL customer_quality_rank,
            NULL fortune_500_rank,
            hop.employees_total     num_of_employees,
            hop.legal_status legal_status,
            hop.year_established     year_established,
            hop.sic_code sic_code1,
            hop.minority_owned_ind     minority_business_flag,
            hop.small_bus_ind small_business_flag,
            hop.woman_owned_ind women_owned_bus_flag,
            NULL gov_org_flag,
            NULL hq_subsidiary_flag,
            NULL foreign_owned_flag,
            DECODE (hop.import_ind || hop.export_ind, 'YY', 'Y', 'YN', 'Y', 'NY', 'Y', 'Y', 'Y', NULL, NULL, 'N') import_export_bus_flag,
            hzp.email_address,
            hzp.address1,
            hzp.address2,
            hzp.competitor_flag,
            hzp.third_party_flag,
            hpp.person_first_name,
            hpp.person_middle_name,
            hpp.person_last_name,
            hpp.person_name_suffix,
            hpp.person_title,
            hpp.person_academic_title,
            hpp.person_pre_name_adjunct,
            hop.control_yr,
            hop.line_of_business,
            hop.cong_dist_code,
            hop.labor_surplus_ind,
            hop.debarment_ind,
            hop.disadv_8a_ind,
            hop.debarments_count,
            ABS (MONTHS_BETWEEN (SYSDATE, hop.debarments_date)),
            hop.gsa_indicator_flag,
            hop.analysis_fy,
            hop.fiscal_yearend_month,
            hop.curr_fy_potential_revenue,
            hop.next_fy_potential_revenue,
            hop.organization_type,
            hop.business_scope,
            hop.corporation_class,
            hop.registration_type,
            hop.incorp_year,
            hop.public_private_ownership_flag,
            hop.internal_flag,
            hop.high_credit,
            hop.avg_high_credit,
            hop.total_payments,
            hop.credit_score_class,
            hop.credit_score_natl_percentile,
            hop.credit_score_incd_default,
            hop.credit_score_age,
            hop.failure_score_class,
            hop.failure_score_incd_default,
            hop.failure_score_age,
            hop.maximum_credit_recommendation,
            hop.maximum_credit_currency_code,
            hzp.party_name,
            hzp.city
         FROM
--          ams_dm_drv_stg           drv,
            ams_dm_drv_stg_gt        drv,       -- nysotos - Sep 15, 2003 - Global Temp Table
            hz_person_profiles       hpp,
            hz_organization_profiles hop,
            hz_org_contacts             hoc,
            hz_employment_history    heh,
            hz_relationships            hpr,
            hz_parties                  hzp
         WHERE
            drv.party_id = hzp.party_id
            AND  hzp.status = 'A'
            AND  drv.party_id = hpr.party_id
            AND  hpr.status = 'A'
            AND  hpr.subject_table_name = 'HZ_PARTIES'
            AND  hpr.object_table_name = 'HZ_PARTIES'
            AND  hpr.directional_flag = 'F'
            AND  hpr.relationship_code IN ('CONTACT_OF' , 'EMPLOYEE_OF')
            AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
            AND  hpp.party_id(+) = hpr.subject_id
            AND (SYSDATE BETWEEN hpp.effective_start_date(+) and NVL(hpp.effective_end_date(+),SYSDATE))
            AND  hop.party_id(+) = hpr.object_id
            AND  hop.status(+) = 'A'
            AND (SYSDATE BETWEEN hop.effective_start_date(+) and NVL(hop.effective_end_date(+),SYSDATE))
            AND  hpr.relationship_id  = hoc.party_relationship_id(+)
            AND  heh.party_id(+) = hpr.subject_id
            AND  heh.status(+) = 'A';
      END IF;
   ELSE
        INSERT /*+ first_rows*/
--          INTO ams_dm_gen_stg (
            INTO ams_dm_gen_stg_gt (            -- nysotos - Sep 15, 2003 - Global Temp Table
            party_id,
            party_type,
            gender,
            ethnicity,
            marital_status,
            personal_income,
            hoh_flag,
            household_income,
            household_size,
            rent_flag,
            degree_received,
            school_type,
            employed_flag,
            years_employed,
            occupation,
            military_branch,
            presence_of_children,
            country,
            state,
            province,
            county,
            zip_code,
            email_address,
            address1,
            address2,
            competitor_flag,
            third_party_flag,
            person_first_name,
            person_middle_name,
            person_last_name,
            person_name_suffix,
            person_title,
            person_academic_title,
            person_pre_name_adjunct,
            party_name,
            city
      )
      SELECT
            drv.party_id party_id,
            hzp.party_type party_type,
            hpp.gender     gender,
            hpp.declared_ethnicity ethnicity,
            hpp.marital_status marital_status,
            hpp.personal_income personal_income,
            hpp.head_of_household_flag hoh_flag,
            hpp.household_income household_income,
            hpp.household_size household_size,
            DECODE(hpp.rent_own_ind, 'RENT', 1, 0) rent_flag,
            NULL degree_received,
            NULL school_type,
            DECODE(heh.end_date, NULL, 1, 0) employed_flag,
            DECODE(heh.end_date, NULL, (SYSDATE - heh.begin_date)/365 , (heh.end_date - heh.begin_date)/365) years_employed,
            DECODE(heh.end_date, NULL, heh.employed_as_title, 'UNEMPLOYED') occupation,
            heh.branch military_branch,
            NULL  num_of_children,
            hzp.country country,
            hzp.state state,
            hzp.province     province,
            hzp.county county,
            hzp.postal_code zip_code,
            hzp.email_address,
            hzp.address1,
            hzp.address2,
            hzp.competitor_flag,
            hzp.third_party_flag,
            hzp.person_first_name,
            hzp.person_middle_name,
            hzp.person_last_name,
            hzp.person_name_suffix,
            hzp.person_title,
            hzp.person_academic_title,
            hzp.person_pre_name_adjunct,
            hzp.party_name,
            hzp.city
      FROM
--          ams_dm_drv_stg           drv,
            ams_dm_drv_stg_gt        drv,          -- nysotos - Sep 15, 2003 - Global Temp Table
            hz_person_profiles       hpp,
            hz_employment_history    heh,
            hz_parties               hzp
      WHERE
            drv.party_id = hzp.party_id
            AND  hzp.status = 'A'
            AND  hpp.party_id(+) = hzp.party_id
            AND  heh.party_id(+) = hzp.party_id
            AND  heh.status(+) = 'A'
            AND (SYSDATE BETWEEN hpp.effective_start_date(+) and NVL(hpp.effective_end_date(+),SYSDATE));

   END IF;

   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Gen_Stg;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
END InsertGenStg;
-- End of 1-1 mapping

PROCEDURE InsertExpStg(
   p_is_b2b     IN BOOLEAN,
   p_model_type  IN VARCHAR2,
   p_is_org_prod IN BOOLEAN
)
IS

-- Proc to swap multiple rows to multiple columns
   l_api_name     CONSTANT VARCHAR2(30) := 'InsertExpStg';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_is_b2b        BOOLEAN;

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Insert_Exp_Stg;
   l_is_b2b:=p_is_b2b;  -- kbasavar 7/14/2003

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
      AMS_Utility_PVT.debug_message (l_full_name || ': Insert');
   END IF;

    IF l_is_b2b THEN
       IF p_model_type<>'CUSTOMER_PROFITABILITY' OR p_is_org_prod THEN
--        INSERT INTO ams_dm_perint_stg (
          INSERT INTO ams_dm_perint_stg_gt (    -- nysotos - Sep 15, 2003 - Global Temp Table
             party_id,
             --  interest related attributes
             interest_art_flag,
             interest_books_flag,
             interest_movies_flag,
             interest_music_flag,
             interest_theater_flag,
             interest_travel_flag,
             interest_drink_flag,
             interest_smoke_flag,
             interest_other_flag)
          SELECT
             drv.party_id party_id,
             -- interest attributes
             MAX (DECODE (hpi.interest_type_code, 'ART', 1, 0)) interest_art_flag,
             MAX (DECODE (hpi.interest_type_code, 'BOOKS',1,0)) interest_books_flag,
             MAX (DECODE (hpi.interest_type_code, 'MOVIES',1,0)) interest_movies_flag,
             MAX (DECODE (hpi.interest_type_code, 'MUSIC',1,0)) interest_music_flag,
             MAX (DECODE (hpi.interest_type_code, 'THEATER',1,0)) interest_theater_flag,
             MAX (DECODE (hpi.interest_type_code, 'TRAVEL',1,0)) interest_travel_flag,
             MAX (DECODE (hpi.interest_type_code, 'DRINK',1,0)) interest_drink_flag,
             MAX (DECODE (hpi.interest_type_code, 'SMOKE',1,0)) interest_smoke_flag,
             MAX (DECODE (hpi.interest_type_code, 'ART',0,
             					       'BOOKS',0,
						       'MOVIES',0,
						       'MUSIC',0,
						       'THEATER',0,
						       'TRAVEL',0,
						       'DRINK',0,
						       'SMOKE',0, 1)) interest_other_flag
--       FROM  ams_dm_drv_stg drv,
         FROM  ams_dm_drv_stg_gt drv,        -- nyostos - Sept 15, 2003 - Global Temp Table
                   hz_person_interest hpi,
                   hz_relationships         hpr
          WHERE drv.party_id = hpr.party_id   --it's the party of type relationship
             AND  hpr.status = 'A'
             AND  hpr.subject_table_name = 'HZ_PARTIES'
             AND  hpr.object_table_name = 'HZ_PARTIES'
             AND  hpr.directional_flag = 'F'
             AND  hpr.relationship_code IN ('CONTACT_OF' , 'EMPLOYEE_OF')
             AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
             AND  hpi.party_id(+) = hpr.subject_id
             AND   hpi.status(+) = 'A'
             GROUP BY drv.party_id
	  ;
     END IF;
   ELSE
--     INSERT INTO ams_dm_perint_stg (
       INSERT INTO ams_dm_perint_stg_gt (    -- nyostos - Sept 15, 2003 - Global Temp Table
          party_id,
          --  interest related attributes
          interest_art_flag,
          interest_books_flag,
          interest_movies_flag,
          interest_music_flag,
          interest_theater_flag,
          interest_travel_flag,
          interest_drink_flag,
          interest_smoke_flag,
          interest_other_flag)
      SELECT
          drv.party_id party_id,
          -- interest attributes
          MAX (DECODE (hpi.interest_type_code, 'ART', 1, 0)) interest_art_flag,
          MAX (DECODE (hpi.interest_type_code, 'BOOKS',1,0)) interest_books_flag,
          MAX (DECODE (hpi.interest_type_code, 'MOVIES',1,0)) interest_movies_flag,
          MAX (DECODE (hpi.interest_type_code, 'MUSIC',1,0)) interest_music_flag,
          MAX (DECODE (hpi.interest_type_code, 'THEATER',1,0)) interest_theater_flag,
          MAX (DECODE (hpi.interest_type_code, 'TRAVEL',1,0)) interest_travel_flag,
          MAX (DECODE (hpi.interest_type_code, 'DRINK',1,0)) interest_drink_flag,
          MAX (DECODE (hpi.interest_type_code, 'SMOKE',1,0)) interest_smoke_flag,
          MAX (DECODE (hpi.interest_type_code, 'ART',0,
                                                               'BOOKS',0,
                                                               'MOVIES',0,
                                                               'MUSIC',0,
                                                               'THEATER',0,
                                                               'TRAVEL',0,
                                                               'DRINK',0,
                                                               'SMOKE',0, 1)) interest_other_flag
--     FROM  ams_dm_drv_stg drv,
       FROM  ams_dm_drv_stg_gt drv,       -- nyostos - Sep 15, 2003 - Global Temp Table
                hz_person_interest hpi
       WHERE drv.party_id = hpi.party_id(+)
       AND   hpi.status(+) = 'A'
       GROUP BY drv.party_id
       ;

    END IF;

      -- financial number attributes
    IF l_is_b2b THEN --kbasavar
       IF p_model_type='CUSTOMER_PROFITABILITY' OR p_is_org_prod THEN
--          INSERT INTO ams_dm_finnum_stg (
            INSERT INTO ams_dm_finnum_stg_gt (     -- nyostos - Sep 15, 2003 -
               party_id,
               gross_annual_income,
               debt_to_income_ratio,
               net_worth,
               total_assets,
               tot_debt_outstanding,
               gross_annual_sales,
               current_assets,
               current_liabilities,
               net_profit,
               accounts_receivable,
               retained_earnings)
            SELECT
               drv.party_id,
               SUM(DECODE (hzf.financial_number_name,'GROSS_INCOME',hzf.financial_number,0)) gross_annual_income ,
               AVG(DECODE (hzf.financial_number_name,'LONG_TERM_DEBT',
                                                  hzf.financial_number,0) / DECODE (hzf.financial_number_name,'GROSS_INCOME',
                                                  hzf.financial_number,1)) debt_to_income_ratio ,
               SUM(DECODE (hzf.financial_number_name,'NET_WORTH',hzf.financial_number,0)) net_worth ,
               SUM(DECODE (hzf.financial_number_name,'TOTAL_ASSETS',hzf.financial_number,0)) total_assets ,
               SUM(DECODE (hzf.financial_number_name,'LONG_TERM_DEBT',hzf.financial_number,0)) tot_debt_outstanding ,
               SUM(DECODE (hzf.financial_number_name,'SALES',hzf.financial_number,0)) gross_annual_sales ,
               SUM(DECODE (hzf.financial_number_name,'TOTAL_CURRENT_ASSETS',hzf.financial_number,0)) current_assets   ,
               SUM(DECODE (hzf.financial_number_name,'TOTAL_CURR_LIABILITIES',hzf.financial_number,0)) current_liabilities ,
               SUM(DECODE (hzf.financial_number_name,'PROFIT_BEFORE_TAX',hzf.financial_number,0)) net_profit ,
               SUM(DECODE (hzf.financial_number_name,'ACCOUNTS_RECEIVABLE',hzf.financial_number,0)) accounts_receivable ,
               SUM(DECODE (hzf.financial_number_name,'RETAINED_EARNINGS',hzf.financial_number,0)) retained_earnings
--          nyostos - Sep 15, 2003 - Global Temp Table
--          FROM ams_dm_drv_stg drv, hz_financial_numbers hzf, hz_financial_reports hfr
            FROM ams_dm_drv_stg_gt drv, hz_financial_numbers hzf, hz_financial_reports hfr
            WHERE drv.party_id = hfr.party_id(+)
            AND   hfr.status(+) = 'A'
            AND   hfr.consolidated_ind(+) = 'C' -- wen only want consolidated reports
            AND   hfr.financial_report_id = hzf.financial_report_id(+)
            AND   hzf.status(+) = 'A'
            GROUP BY drv.party_id
	    ;
       ELSE
--          nyostos - Sep 15, 2003 - Global Temp Table
--          INSERT INTO ams_dm_finnum_stg (
            INSERT INTO ams_dm_finnum_stg_gt (
               party_id,
               gross_annual_income,
               debt_to_income_ratio,
               --     num_credit_lines,
               --     num_trade_lines,
               net_worth,
               total_assets,
               tot_debt_outstanding,
               --     bankruptcy_flag,
               --     high_risk_fraud_flag,
               gross_annual_sales,
               --     growth_rate_sales_year,
               --     growth_rate_net_prof_year,
               current_assets,
               current_liabilities,
               --     total_debts,
               net_profit,
               --     tangible_net_profit,
               --     capital_amount,
               --     capital_type_indicator,
               accounts_receivable,
               retained_earnings)
            SELECT
               drv.party_id, -- rectify this
               SUM(DECODE (hzf.financial_number_name,'GROSS_INCOME',hzf.financial_number,0)) gross_annual_income ,
               AVG(DECODE (hzf.financial_number_name,'LONG_TERM_DEBT',
                                                  hzf.financial_number,0) / DECODE (hzf.financial_number_name,'GROSS_INCOME',
                                                  hzf.financial_number,1)) debt_to_income_ratio ,
               --   NULL num_credit_lines   ,    --**CHECK!
               --   NULL num_trade_lines ,                --**CHECK!
               SUM(DECODE (hzf.financial_number_name,'NET_WORTH',hzf.financial_number,0)) net_worth ,
               SUM(DECODE (hzf.financial_number_name,'TOTAL_ASSETS',hzf.financial_number,0)) total_assets ,
               SUM(DECODE (hzf.financial_number_name,'LONG_TERM_DEBT',hzf.financial_number,0)) tot_debt_outstanding ,
               --   NULL bankruptcy_flag ,                           --**CHECK!
               --   NULL high_risk_fraud_flag ,                --**CHECK!
               SUM(DECODE (hzf.financial_number_name,'SALES',hzf.financial_number,0)) gross_annual_sales ,
               --    NULL  growth_rate_sales_year ,    --**CHECK!
               --    NULL  growth_rate_net_prof_year ,   --**CHECK!
               SUM(DECODE (hzf.financial_number_name,'TOTAL_CURRENT_ASSETS',hzf.financial_number,0)) current_assets   ,
               SUM(DECODE (hzf.financial_number_name,'TOTAL_CURR_LIABILITIES',hzf.financial_number,0)) current_liabilities ,
               --    NULL  total_debts ,
               SUM(DECODE (hzf.financial_number_name,'PROFIT_BEFORE_TAX',hzf.financial_number,0)) net_profit ,
               --    NULL  tangible_net_profit ,  --**CHECK!
               --    NULL  capital_amt ,               --**CHECK!
               --    NULL capital_type_indicator ,
               SUM(DECODE (hzf.financial_number_name,'ACCOUNTS_RECEIVABLE',hzf.financial_number,0)) accounts_receivable ,
               SUM(DECODE (hzf.financial_number_name,'RETAINED_EARNINGS',hzf.financial_number,0)) retained_earnings
--          nyostos - Sep 15, 2003 - Global Temp Table
--          FROM ams_dm_drv_stg drv, hz_financial_numbers hzf, hz_financial_reports hfr, hz_relationships hpr
            FROM ams_dm_drv_stg_gt drv, hz_financial_numbers hzf, hz_financial_reports hfr, hz_relationships hpr
           WHERE drv.party_id = hpr.party_id
            AND  hpr.status = 'A'
            AND  hpr.subject_table_name = 'HZ_PARTIES'
            AND  hpr.object_table_name = 'HZ_PARTIES'
            AND  hpr.directional_flag = 'F'
            AND  hpr.relationship_code IN ('CONTACT_OF' , 'EMPLOYEE_OF')
            AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
            AND  hfr.party_id(+) = hpr.object_id                 --the org's party id
            AND   hfr.status(+) = 'A'
            AND   hfr.consolidated_ind(+) = 'C' -- wen only want consolidated reports
            AND   hfr.financial_report_id = hzf.financial_report_id(+)
            AND   hzf.status(+) = 'A'
            GROUP BY drv.party_id
            ;
       END IF;
    END IF;


/******** OPEN: which account record do we use? ********/

    IF l_is_b2b THEN
       IF p_model_type='CUSTOMER_PROFITABILITY' OR p_is_org_prod THEN
--        INSERT INTO ams_dm_party_profile_stg (
          INSERT INTO ams_dm_profile_stg_gt (      -- nyostos - Sep 15, 2003 - Global Temp Table
             party_id,
             credit_check_flag,
             tolerance,
             discount_terms_flag,
             dunning_letters_flag,
             interest_charges_flag,
             send_statements_flag,
             credit_hold_flag,
             credit_rating,
             risk_code,
             interest_period_days,
             payment_grace_days)
          SELECT
             drv.party_id party_id,
             MAX(hcp.credit_checking) credit_check_flag,
             MAX(hcp.tolerance) tolerance,
             MAX(hcp.discount_terms) discount_terms_flag,
             MAX(hcp.dunning_letters)  dunning_letters_flag,
             MAX(hcp.interest_charges)  interest_charges_flag,
             MAX(hcp.send_statements)  send_statements_flag,
             MAX(hcp.credit_hold)  credit_hold_flag,
             MAX(hcp.credit_rating) credit_rating, -- may give erroneous results
             MAX(hcp.risk_code) risk_code, --may give erroneous results
             MAX(hcp.interest_period_days) interest_period_days,
             MAX(hcp.payment_grace_days) payment_grace_days
          FROM
--           ams_dm_drv_stg     drv,
             ams_dm_drv_stg_gt  drv,    -- nyostos - Sep 15, 2003 - Global Temp Tables
             hz_cust_accounts   hca,
             hz_customer_profiles  hcp
          WHERE drv.party_id = hca.party_id(+)
          AND   hca.status(+) = 'A'
          AND hcp.cust_account_id(+) = hca.cust_account_id
          AND   hcp.status(+) = 'A'
          GROUP BY drv.party_id
          ;
       ELSE
--       INSERT INTO ams_dm_party_profile_stg (
         INSERT INTO ams_dm_profile_stg_gt (   -- nyostos - Sep 15, 2003 - Global Temp Table
             party_id,
             credit_check_flag,
             tolerance,
             discount_terms_flag,
             dunning_letters_flag,
             interest_charges_flag,
             send_statements_flag,
             --     send_credit_balance_flag,
             credit_hold_flag,
             -- profile_class_code,
             credit_rating,
             risk_code,
             interest_period_days,
             payment_grace_days)
          SELECT
             drv.party_id party_id,
             MAX(hcp.credit_checking) credit_check_flag,
             MAX(hcp.tolerance) tolerance,
             MAX(hcp.discount_terms) discount_terms_flag,
             MAX(hcp.dunning_letters)  dunning_letters_flag,
             MAX(hcp.interest_charges)  interest_charges_flag,
             MAX(hcp.send_statements)  send_statements_flag,
             MAX(hcp.credit_hold)  credit_hold_flag,
             MAX(hcp.credit_rating) credit_rating, -- may give erroneous results
             MAX(hcp.risk_code) risk_code, --may give erroneous results
             MAX(hcp.interest_period_days) interest_period_days,
             MAX(hcp.payment_grace_days) payment_grace_days
          FROM
--           ams_dm_drv_stg     drv,
             ams_dm_drv_stg_gt  drv,    -- nyostos - Sep 15, 2003 - Global Temp Tables
             hz_cust_accounts   hca,
             hz_customer_profiles  hcp,
             hz_relationships   hpr
          WHERE drv.party_id = hpr.party_id
          AND  hpr.status = 'A'
          AND  hpr.subject_table_name = 'HZ_PARTIES'
          AND  hpr.object_table_name = 'HZ_PARTIES'
          AND  hpr.directional_flag = 'F'
          AND  hpr.relationship_code IN ('CONTACT_OF' , 'EMPLOYEE_OF')
          AND  (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
          AND  hca.party_id = hpr.object_id           --the org's party id
          AND   hca.status = 'A'
          AND hcp.cust_account_id(+) = hca.cust_account_id
          AND   hcp.status(+) = 'A'
          GROUP BY drv.party_id
          ;
      END IF;
  ELSE
--     INSERT INTO ams_dm_party_profile_stg (
       INSERT INTO ams_dm_profile_stg_gt (      -- nyostos - Sep 15, 2003 - Global Temp Table
          party_id,
          credit_check_flag,
          tolerance,
          discount_terms_flag,
          dunning_letters_flag,
          interest_charges_flag,
          send_statements_flag,
 --     send_credit_balance_flag,
          credit_hold_flag,
          -- profile_class_code,
          credit_rating,
          risk_code,
          interest_period_days,
          payment_grace_days)
       SELECT
          drv.party_id party_id,
          MAX(hcp.credit_checking) credit_check_flag,
          MAX(hcp.tolerance) tolerance,
          MAX(hcp.discount_terms) discount_terms_flag,
          MAX(hcp.dunning_letters)  dunning_letters_flag,
          MAX(hcp.interest_charges)  interest_charges_flag,
          MAX(hcp.send_statements)  send_statements_flag,
          MAX(hcp.credit_hold)  credit_hold_flag,
          MAX(hcp.credit_rating) credit_rating, -- may give erroneous results
          MAX(hcp.risk_code) risk_code, --may give erroneous results
          MAX(hcp.interest_period_days) interest_period_days,
          MAX(hcp.payment_grace_days) payment_grace_days
       FROM
--       ams_dm_drv_stg                drv,
         ams_dm_drv_stg_gt             drv,    -- nyostos - Sep 15, 2003 - Global Temp Table
         hz_cust_accounts              hca,
         hz_customer_profiles          hcp
       WHERE hcp.cust_account_id(+) = hca.cust_account_id
       AND   hcp.status(+) = 'A'
       AND   drv.party_id = hca.party_id
       AND   hca.status = 'A'
       GROUP BY drv.party_id
       ;
  END IF;

   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Exp_Stg;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
 END InsertExpStg;

PROCEDURE InsertAggStg(
p_is_b2b   IN BOOLEAN
)
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'InsertAggStg';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   TYPE AMS_DM_AGG_STG_REC_TYPE IS RECORD
   (
     PARTY_ID                     NUMBER(15),
     AGE                          NUMBER,
     DAYS_SINCE_LAST_SCHOOL       NUMBER,
     DAYS_SINCE_LAST_EVENT        NUMBER,
     NUM_TIMES_TARGETED           NUMBER,
     LAST_TARGETED_CHANNEL_CODE   VARCHAR2(30),
     TIMES_TARGETED_MONTH         NUMBER,
     TIMES_TARGETED_3_MONTHS      NUMBER,
     TIMES_TARGETED_6_MONTHS      NUMBER,
     TIMES_TARGETED_12_MONTHS     NUMBER,
     DAYS_SINCE_LAST_TARGETED     NUMBER,
     AVG_DISC_OFFERED             NUMBER,
     NUM_TYPES_DISC_OFFERED       NUMBER,
     DAYS_SINCE_FIRST_CONTACT     NUMBER,
     DAYS_SINCE_ACCT_ESTABLISHED  NUMBER,
     DAYS_SINCE_ACCT_TERM         NUMBER,
     DAYS_SINCE_ACCT_ACTIVATION   NUMBER,
     DAYS_SINCE_ACCT_SUSPENDED    NUMBER,
     NUM_TIMES_TARGETED_EMAIL     NUMBER,
     NUM_TIMES_TARGETED_TELEMKT   NUMBER,
     NUM_TIMES_TARGETED_DIRECT    NUMBER,
     NUM_TGT_BY_OFFR_TYP1         NUMBER,
     NUM_TGT_BY_OFFR_TYP2         NUMBER,
     NUM_TGT_BY_OFFR_TYP3         NUMBER,
     NUM_TGT_BY_OFFR_TYP4         NUMBER
   );

   -- age is in number of days
   CURSOR c_age IS
      SELECT SYSDATE - hpp.date_of_birth, drv.party_id
      FROM hz_person_profiles hpp, ams_dm_drv_stg_gt drv
      WHERE hpp.party_id = drv.party_id
   AND (SYSDATE BETWEEN hpp.effective_start_date AND NVL(hpp.effective_end_date,SYSDATE))
   GROUP BY drv.party_id,hpp.date_of_birth;

   CURSOR c_age_b2b IS
      SELECT SYSDATE - hpp.date_of_birth,drv.party_id
      FROM hz_person_profiles hpp,hz_relationships hpr,ams_dm_drv_stg_gt drv
      WHERE hpp.party_id = hpr.subject_id
      AND drv.party_id = hpr.party_id
      AND    hpr.status = 'A'
      AND    hpr.subject_table_name = 'HZ_PARTIES'
      AND    hpr.object_table_name = 'HZ_PARTIES'
      AND    hpr.directional_flag = 'F'
      AND    hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
      AND    (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
      AND (SYSDATE BETWEEN hpp.effective_start_date AND NVL(hpp.effective_end_date,SYSDATE))
      GROUP BY drv.party_id,hpp.date_of_birth;

   CURSOR c_days_since_last_school IS
      SELECT  SYSDATE - MAX(hze.last_date_attended), drv.party_id
      FROM hz_education hze, ams_dm_drv_stg_gt drv
      WHERE hze.party_id = drv.party_id
      AND   hze.status = 'A'
      GROUP BY drv.party_id;

   CURSOR c_days_since_last_school_b2b IS
      SELECT  SYSDATE - MAX(hze.last_date_attended), drv.party_id
      FROM hz_education hze, ams_dm_drv_stg_gt drv, hz_relationships hpr
      WHERE hze.party_id = hpr.subject_id
      AND drv.party_id = hpr.party_id
      AND    hpr.status = 'A'
      AND    hpr.subject_table_name = 'HZ_PARTIES'
      AND    hpr.object_table_name = 'HZ_PARTIES'
      AND    hpr.directional_flag = 'F'
      AND    hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
      AND    (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
      AND   hze.status = 'A'
      GROUP BY drv.party_id;

   CURSOR c_days_since_last_event IS
      SELECT  (SYSDATE - MAX(aeo.event_start_date)), drv.party_id
      FROM ams_event_offers_all_b aeo, ams_dm_drv_stg_gt drv
      WHERE aeo.event_offer_id IN (SELECT aer.event_offer_id
                    FROM ams_event_registrations aer
             --       WHERE aer.event_offer_id = aeo.event_offer_id
                    WHERE aer.attendant_party_id = drv.party_id)
   GROUP BY drv.party_id;

   CURSOR c_num_times_targeted IS
      SELECT  COUNT(DISTINCT ale.list_header_id), drv.party_id
      FROM ams_list_entries ale, ams_dm_drv_stg_gt drv,ams_list_headers_all hdr
      WHERE ale.party_id = drv.party_id
      AND hdr.list_header_id = ale.list_header_id
      AND hdr.list_type = 'TARGET'
   GROUP BY drv.party_id;

   -- change to use ams_act_lists
   CURSOR c_last_targeted_channel_code IS
      SELECT  aal.list_used_by_id, drv.party_id
      FROM ams_act_lists aal, ams_list_headers_all alh, ams_dm_drv_stg_gt drv
      WHERE aal.list_used_by = 'CSCH'
      AND   aal.list_act_type = 'TARGET'
      AND   alh.list_header_id = aal.list_header_id
      AND   alh.sent_out_date = (SELECT MAX(l.sent_out_date)
                                 FROM ams_list_headers_all l
                                 WHERE l.list_header_id IN (SELECT ale.list_header_id
                                                            FROM ams_list_entries ale
                                                            WHERE ale.party_id = drv.party_id))
     GROUP BY drv.party_id, aal.list_used_by_id ;
   --  modified krmukher 03/20/2001 per Chi's suggestion
   --  all references to party_id in ams_list_entries
   --  changed to  list_entry_source_system_id
   --l_last_targeted_channel_code VARCHAR2(30);
   CURSOR c_times_targeted IS
      SELECT  SUM(DECODE(SIGN(MONTHS_BETWEEN(SYSDATE, alh.sent_out_date) -1),1,0,1)),
             SUM(DECODE(SIGN(MONTHS_BETWEEN(SYSDATE, alh.sent_out_date) -3),1,0,1)),
             SUM(DECODE(SIGN(MONTHS_BETWEEN(SYSDATE, alh.sent_out_date) -9),1,0,1)),
             SUM(DECODE(SIGN(MONTHS_BETWEEN(SYSDATE, alh.sent_out_date) -12),1,0,1)), drv.party_id
      FROM ams_list_headers_all alh, ams_dm_drv_stg_gt drv
      WHERE alh.sent_out_date IS NOT NULL
      AND MONTHS_BETWEEN(sysdate, alh.sent_out_date) <= 12
      AND alh.list_header_id IN (SELECT ale.list_header_id
                  FROM ams_list_entries ale
   --             WHERE ale.list_header_id = alh.list_header_id
                  WHERE ale.party_id = drv.party_id)
   GROUP BY drv.party_id;
   --             AND ale.party_id = drv.party_id);
   --  modified krmukher 03/20/2001 per Chi's suggestion
   --  all references to party_id in ams_list_entries
   --  changed to  list_entry_source_system_id
   CURSOR c_days_since_last_targeted IS
      SELECT  (SYSDATE - MAX(aeo.event_start_date)), drv.party_id
      FROM ams_event_offers_all_b aeo, ams_dm_drv_stg_gt drv
      WHERE aeo.event_offer_id IN (SELECT aer.event_offer_id
                    FROM ams_event_registrations aer
            --        WHERE aer.event_offer_id = aeo.event_offer_id
                    WHERE  aer.attendant_party_id = drv.party_id)
      GROUP BY drv.party_id;

   CURSOR c_avg_disc_offered IS
      SELECT  AVG(aao.offer_amount), drv.party_id
      FROM ams_act_offers aao, ams_campaign_schedules acs, ams_dm_drv_stg_gt drv
      WHERE aao.arc_act_offer_used_by = 'CSCH'
      AND aao.activity_offer_id = acs.activity_offer_id
      AND acs.campaign_schedule_id IN (SELECT aal.list_used_by_id
                                       FROM ams_act_lists aal
                                       WHERE aal.list_used_by = 'CSCH'
                                       AND   aal.list_act_type = 'TARGET'
                                       AND   aal.list_header_id IN (SELECT ale.list_header_id
                                                                    FROM ams_list_entries ale
                       --                                           WHERE ale.list_header_id = alh.list_header_id
                                                                    WHERE ale.party_id = drv.party_id))
   GROUP BY drv.party_id;
   --                  AND ale.party_id = drv.party_id));
   --  modified krmukher 03/20/2001 per Chi's suggestion
   --  all references to party_id in ams_list_entries
   --  changed to  list_entry_source_system_id

   CURSOR c_num_types_disc_offered IS
   SELECT  COUNT(aao.offer_type), drv.party_id
   FROM   ams_act_offers aao, ams_campaign_schedules acs, ams_dm_drv_stg_gt drv
   WHERE  aao.arc_act_offer_used_by = 'CSCH'
   AND    aao.activity_offer_id = acs.activity_offer_id
   AND    acs.campaign_schedule_id IN (SELECT aal.list_used_by_id
                                       FROM ams_list_entries ale, ams_act_lists aal
                                       WHERE aal.list_header_id = ale.list_header_id
                                       AND   aal.list_used_by = 'CSCH'
                                       AND   aal.list_act_type = 'TARGET'
                                       AND   ale.party_id = drv.party_id)
   GROUP BY drv.party_id;

   CURSOR c_days_since_first_contact IS
      SELECT  (SYSDATE - MIN(aeo.event_start_date)), drv.party_id
      FROM ams_event_offers_all_b aeo,ams_dm_drv_stg_gt drv
      WHERE aeo.event_offer_id IN (SELECT 1
                    FROM ams_event_registrations aer
         --           WHERE aer.event_offer_id = aeo.event_offer_id
                    WHERE aer.attendant_party_id = drv.party_id)
      GROUP BY drv.party_id;

   CURSOR c_days_since_account  IS
      SELECT  SYSDATE - MAX(hca.account_established_date),
             0,--SYSDATE - MAX(hca.account_termination_date),
             0 --SYSDATE - MAX(hca.account_activation_date)
             , drv.party_id
 --            SYSDATE - MAX(hca.account_suspension_date)
      FROM hz_cust_accounts hca, ams_dm_drv_stg_gt drv
      WHERE hca.party_id = drv.party_id
      AND   hca.status = 'A'
   GROUP BY drv.party_id;

   CURSOR c_days_since_account_b2b  IS
      SELECT  SYSDATE - MAX(hca.account_established_date),
             0,--SYSDATE - MAX(hca.account_termination_date),
             0 --SYSDATE - MAX(hca.account_activation_date)
             , drv.party_id
 --            SYSDATE - MAX(hca.account_suspension_date)
      FROM hz_cust_accounts hca, ams_dm_drv_stg_gt drv, hz_relationships hpr
      WHERE hca.party_id = hpr.object_id
      AND drv.party_id = hpr.party_id
      AND    hpr.status = 'A'
      AND    hpr.subject_table_name = 'HZ_PARTIES'
      AND    hpr.object_table_name = 'HZ_PARTIES'
      AND    hpr.directional_flag = 'F'
      AND    hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
      AND    (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
      AND   hca.status = 'A'
      GROUP BY drv.party_id;

   CURSOR c_num_times_tgt_chnl IS
   /* commented out by amisingh
   SELECT SUM(DECODE(UPPER(ame.media_name), 'EMAIL',1,0)),
          SUM(DECODE(UPPER(ame.media_name), 'TELEMARKETING',1,0)),
          SUM(DECODE(UPPER(ame.media_name), 'DIRECT MAIL',1,0))
   */
   SELECT  SUM(DECODE(acs.activity_id, G_MEDIA_EMAIL,1,0)),
          SUM(DECODE(acs.activity_id, G_MEDIA_TELEMARKETING ,1,0)),
          SUM(DECODE(acs.activity_id, G_MEDIA_DIRECTMAIL ,1,0)), drv.party_id
   FROM ams_list_entries ale,
        ams_act_lists aal,
        ams_campaign_schedules_b acs,
        --ams_media_b ame,
        ams_dm_drv_stg_gt drv
   WHERE aal.list_used_by = 'CSCH'
   AND   aal.list_used_by_id = acs.schedule_id
   AND   aal.list_act_type = 'TARGET'
   AND   acs.activity_type_code = 'DIRECT_MARKETING'
   --AND   acs.activity_id = ame.media_id
   --AND   UPPER(ame.media_name) = 'TELEMARKETING' commented out by amisingh
   AND   aal.list_header_id = ale.list_header_id
   AND   ale.party_id = drv.party_id
   GROUP BY drv.party_id;

   CURSOR c_num_tgt_offr_typ IS
   SELECT  SUM(DECODE(UPPER(offer_type),'ACCRUAL',1,0)),
          SUM(DECODE(UPPER(offer_type),'LUMPSUM',1,0)),
          SUM(DECODE(UPPER(offer_type),'ORDER',1,0)),
          SUM(DECODE(UPPER(offer_type),'OFF_INVOICE',1,0)), drv.party_id
   FROM ams_list_entries ale,
        ams_act_lists aal,
        ams_campaign_schedules_b acs,
        ams_act_offers aao, ams_dm_drv_stg_gt drv
   WHERE aal.list_used_by = 'CSCH'
   AND   aal.list_used_by_id = acs.schedule_id
   AND   aal.list_act_type = 'TARGET'
   AND   acs.end_date_time <= SYSDATE
   AND   acs.activity_id = aao.activity_offer_id
   AND   aal.list_header_id = ale.list_header_id
   AND   ale. party_id = drv.party_id
   GROUP BY drv.party_id;

-- nyostos - Sep 15, 2003 - Use Global Temporary Table
--CURSOR cur_party IS SELECT party_id FROM ams_dm_drv_stg;
   CURSOR c_all_parties IS SELECT party_id FROM ams_dm_drv_stg_gt;

   c_party NUMBER;
   l_person_party_id   NUMBER;
   l_org_party_id        NUMBER;
   l_is_b2b        BOOLEAN;
   l_bs_rows   NUMBER;

   -- choang - 05-aug-2004 - bug 3816612 - changing to use index by binary integer
   TYPE l_master_table_type IS
        TABLE OF AMS_DM_AGG_STG_REC_TYPE INDEX BY BINARY_INTEGER;
       -- TABLE OF AMS_DM_AGG_STG_REC_TYPE INDEX BY VARCHAR2(15);

   TYPE t_number_table IS TABLE OF NUMBER(15)
                         INDEX BY BINARY_INTEGER;

   l_all_party_id_list     t_number_table;
   l_master_party_id_list     t_number_table;
   l_master_rec AMS_DM_AGG_STG_REC_TYPE;

   l_master_table l_master_table_type;
   l_party_list   t_number_table;

   l_age_list    dbms_sql.NUMBER_table;
   l_days_since_last_school_list    dbms_sql.NUMBER_table;
   l_days_since_last_event_list    dbms_sql.NUMBER_table;
   l_num_times_tgt_list    dbms_sql.NUMBER_table;
   l_last_targeted_ch_code_list    dbms_sql.VARCHAR2_table;
   l_times_tgt_month_list    dbms_sql.NUMBER_table;
   l_times_tgt_3months_list    dbms_sql.NUMBER_table;
   l_times_tgt_6months_list    dbms_sql.NUMBER_table;
   l_times_tgt_12months_list    dbms_sql.NUMBER_table;
   l_days_since_last_tgt_list    dbms_sql.NUMBER_table;
   l_avg_disc_offered_list     dbms_sql.NUMBER_table;
   l_num_types_disc_offered_list    dbms_sql.NUMBER_table;
   l_days_since_first_cnt_list    dbms_sql.NUMBER_table;
   l_days_since_acct_estb_list    dbms_sql.NUMBER_table;
   l_days_since_acct_term_list    dbms_sql.NUMBER_table;
   l_days_since_acct_act_list    dbms_sql.NUMBER_table;
   l_num_times_tgt_email_list    dbms_sql.NUMBER_table;
   l_num_times_tgt_telemkt_list    dbms_sql.NUMBER_table;
   l_num_times_tgt_direct_list    dbms_sql.NUMBER_table;
   l_num_tgt_by_offr_typ1_list    dbms_sql.NUMBER_table;
   l_num_tgt_by_offr_typ2_list    dbms_sql.NUMBER_table;
   l_num_tgt_by_offr_typ3_list    dbms_sql.NUMBER_table;
   l_num_tgt_by_offr_typ4_list    dbms_sql.NUMBER_table;

   l_count NUMBER := 1;

   l_return_status VARCHAR2(1);
 BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Insert_Agg_Stg;
   l_is_b2b:=p_is_b2b;
   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   l_bs_rows:= fnd_profile.value_specific('AMS_BATCH_SIZE');
   IF  (l_bs_rows  IS NULL  OR l_bs_rows < 1) THEN
      l_bs_rows :=1000;
   END IF;

   --get all the parties into the mater table.
   OPEN c_all_parties;
      LOOP
         FETCH c_all_parties BULK COLLECT INTO l_all_party_id_list  LIMIT l_bs_rows;
            FOR i IN 1..l_all_party_id_list.COUNT LOOP
               l_master_party_id_list(l_count) := l_all_party_id_list(i);
               l_count := l_count+1;
               l_master_rec.PARTY_ID := l_all_party_id_list(i);
               l_master_table(l_all_party_id_list(i)) :=  l_master_rec;
            END LOOP;
         EXIT WHEN c_all_parties%NOTFOUND;
      END LOOP;
   CLOSE c_all_parties;

   IF p_is_b2b THEN
      OPEN c_age_b2b;
         LOOP
            FETCH c_age_b2b BULK COLLECT INTO l_age_list,l_party_list  LIMIT l_bs_rows;
            FOR i IN 1..l_party_list.COUNT LOOP
               l_master_table(l_party_list(i)).AGE :=  l_age_list(i);
            END LOOP;
            EXIT WHEN c_age_b2b%NOTFOUND;
         END LOOP;
      CLOSE c_age_b2b;
   ELSE
      OPEN c_age;
         LOOP
            FETCH c_age BULK COLLECT INTO l_age_list,l_party_list  LIMIT l_bs_rows;
            FOR i IN 1..l_party_list.COUNT LOOP
               l_master_table(l_party_list(i)).AGE :=  l_age_list(i);
            END LOOP;
            EXIT WHEN c_age%NOTFOUND;
         END LOOP;
      CLOSE c_age;
   END IF ;

   l_party_list.delete;

   IF p_is_b2b THEN
      OPEN c_days_since_last_school_b2b;
         LOOP
            FETCH c_days_since_last_school_b2b BULK COLLECT INTO l_days_since_last_school_list,l_party_list  LIMIT l_bs_rows;
            FOR i IN 1..l_party_list.COUNT LOOP
               l_master_table(l_party_list(i)).DAYS_SINCE_LAST_SCHOOL :=  l_days_since_last_school_list(i);
            END LOOP;
            EXIT WHEN c_days_since_last_school_b2b%NOTFOUND;
         END LOOP;
      CLOSE c_days_since_last_school_b2b;
   ELSE
      OPEN c_days_since_last_school;
         LOOP
            FETCH c_days_since_last_school BULK COLLECT INTO l_days_since_last_school_list,l_party_list  LIMIT l_bs_rows;
            FOR i IN 1..l_party_list.COUNT LOOP
               l_master_table(l_party_list(i)).DAYS_SINCE_LAST_SCHOOL :=  l_days_since_last_school_list(i);
            END LOOP;
            EXIT WHEN c_days_since_last_school%NOTFOUND;
         END LOOP;
      CLOSE c_days_since_last_school;
   END IF;

   l_party_list.delete;

   OPEN c_days_since_last_event;
      LOOP
         FETCH c_days_since_last_event BULK COLLECT INTO l_days_since_last_event_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).DAYS_SINCE_LAST_EVENT :=  l_days_since_last_event_list(i);
         END LOOP;
         EXIT WHEN c_days_since_last_event%NOTFOUND;
      END LOOP;
   CLOSE c_days_since_last_event;

   l_party_list.delete;

   OPEN c_num_times_targeted;
      LOOP
         FETCH c_num_times_targeted BULK COLLECT INTO l_num_times_tgt_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).NUM_TIMES_TARGETED :=  l_num_times_tgt_list(i);
         END LOOP;
         EXIT WHEN c_num_times_targeted%NOTFOUND;
      END LOOP;
   CLOSE c_num_times_targeted;

   l_party_list.delete;

   /* --commented due to perf issue
   OPEN c_last_targeted_channel_code;
      LOOP
         FETCH c_last_targeted_channel_code BULK COLLECT INTO l_last_targeted_ch_code_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).LAST_TARGETED_CHANNEL_CODE :=  l_last_targeted_ch_code_list(i);
         END LOOP;
         EXIT WHEN c_last_targeted_channel_code%NOTFOUND;
      END LOOP;
   CLOSE c_last_targeted_channel_code;

   l_party_list.delete;
   */

   OPEN c_times_targeted;

      LOOP
         FETCH c_times_targeted
            BULK COLLECT
            INTO l_times_tgt_month_list,
               l_times_tgt_3months_list,
               l_times_tgt_6months_list,
               l_times_tgt_12months_list,
               l_party_list
            LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).TIMES_TARGETED_MONTH :=  l_times_tgt_month_list(i);
            l_master_table(l_party_list(i)).TIMES_TARGETED_3_MONTHS :=  l_times_tgt_3months_list(i);
            l_master_table(l_party_list(i)).TIMES_TARGETED_6_MONTHS :=  l_times_tgt_6months_list(i);
            l_master_table(l_party_list(i)).TIMES_TARGETED_12_MONTHS :=  l_times_tgt_12months_list(i);
         END LOOP;
         EXIT WHEN c_times_targeted%NOTFOUND;
      END LOOP;

   l_party_list.delete;

   OPEN c_days_since_last_targeted;
      LOOP
         FETCH c_days_since_last_targeted BULK COLLECT INTO l_days_since_last_tgt_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).DAYS_SINCE_LAST_TARGETED :=  l_days_since_last_tgt_list(i);
         END LOOP;
         EXIT WHEN c_days_since_last_targeted%NOTFOUND;
      END LOOP;
   CLOSE c_days_since_last_targeted;

   l_party_list.delete;

   OPEN c_avg_disc_offered;
      LOOP
         FETCH c_avg_disc_offered BULK COLLECT INTO l_avg_disc_offered_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).AVG_DISC_OFFERED :=  l_avg_disc_offered_list(i);
         END LOOP;
         EXIT WHEN c_avg_disc_offered%NOTFOUND;
      END LOOP;
   CLOSE c_avg_disc_offered;

   l_party_list.delete;

   OPEN c_num_types_disc_offered;
      LOOP
         FETCH c_num_types_disc_offered BULK COLLECT INTO l_num_types_disc_offered_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).NUM_TYPES_DISC_OFFERED :=  l_num_types_disc_offered_list(i);
         END LOOP;
         EXIT WHEN c_num_types_disc_offered%NOTFOUND;
      END LOOP;
   CLOSE c_num_types_disc_offered;

   l_party_list.delete;

   OPEN c_days_since_first_contact;
      LOOP
         FETCH c_days_since_first_contact BULK COLLECT INTO l_days_since_first_cnt_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).DAYS_SINCE_FIRST_CONTACT :=  l_days_since_first_cnt_list(i);
         END LOOP;
         EXIT WHEN c_days_since_first_contact%NOTFOUND;
      END LOOP;
   CLOSE c_days_since_first_contact;

   l_party_list.delete;

   IF p_is_b2b THEN
      OPEN c_days_since_account_b2b;
         LOOP
            FETCH c_days_since_account_b2b BULK COLLECT
            INTO l_days_since_acct_estb_list,
               l_days_since_acct_term_list,
               l_days_since_acct_act_list,
               l_party_list
            LIMIT l_bs_rows;
            FOR i IN 1..l_party_list.COUNT LOOP
               l_master_table(l_party_list(i)).DAYS_SINCE_ACCT_ESTABLISHED := l_days_since_acct_estb_list(i);
               l_master_table(l_party_list(i)).DAYS_SINCE_ACCT_TERM :=  l_days_since_acct_term_list(i);
               l_master_table(l_party_list(i)).DAYS_SINCE_ACCT_ACTIVATION :=  l_days_since_acct_act_list(i);
            END LOOP;
            EXIT WHEN c_days_since_account_b2b%NOTFOUND;
         END LOOP;
      CLOSE c_days_since_account_b2b;
   ELSE
      OPEN c_days_since_account;
         LOOP
            FETCH c_days_since_account BULK COLLECT
            INTO l_days_since_acct_estb_list,
               l_days_since_acct_term_list,
               l_days_since_acct_act_list,
               l_party_list
            LIMIT l_bs_rows;
            FOR i IN 1..l_party_list.COUNT LOOP
               l_master_table(l_party_list(i)).DAYS_SINCE_ACCT_ESTABLISHED := l_days_since_acct_estb_list(i);
               l_master_table(l_party_list(i)).DAYS_SINCE_ACCT_TERM :=  l_days_since_acct_term_list(i);
               l_master_table(l_party_list(i)).DAYS_SINCE_ACCT_ACTIVATION :=  l_days_since_acct_act_list(i);
            END LOOP;
            EXIT WHEN c_days_since_account%NOTFOUND;
         END LOOP;
      CLOSE c_days_since_account;

   END IF;

   l_party_list.delete;

   OPEN c_num_times_tgt_chnl;
      LOOP
         FETCH c_num_times_tgt_chnl BULK COLLECT
         INTO l_num_times_tgt_email_list,
           l_num_times_tgt_telemkt_list,
           l_num_times_tgt_direct_list,
           l_party_list
           LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).NUM_TIMES_TARGETED_EMAIL  := l_num_times_tgt_email_list(i);
            l_master_table(l_party_list(i)).NUM_TIMES_TARGETED_TELEMKT := l_num_times_tgt_telemkt_list(i);
            l_master_table(l_party_list(i)).NUM_TIMES_TARGETED_DIRECT := l_num_times_tgt_direct_list(i);
        END LOOP;
        EXIT WHEN c_num_times_tgt_chnl%NOTFOUND;
      END LOOP;
   CLOSE c_num_times_tgt_chnl;

   l_party_list.delete;

   OPEN c_num_tgt_offr_typ;
      LOOP
         FETCH c_num_tgt_offr_typ BULK COLLECT
         INTO l_num_tgt_by_offr_typ1_list,
           l_num_tgt_by_offr_typ2_list,
           l_num_tgt_by_offr_typ3_list,
           l_num_tgt_by_offr_typ4_list,
           l_party_list
           LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).NUM_TGT_BY_OFFR_TYP1  := l_num_tgt_by_offr_typ1_list(i);
            l_master_table(l_party_list(i)).NUM_TGT_BY_OFFR_TYP2 := l_num_tgt_by_offr_typ1_list(i);
            l_master_table(l_party_list(i)).NUM_TGT_BY_OFFR_TYP3 := l_num_tgt_by_offr_typ1_list(i);
            l_master_table(l_party_list(i)).NUM_TGT_BY_OFFR_TYP4 := l_num_tgt_by_offr_typ1_list(i);
        END LOOP;
        EXIT WHEN c_num_tgt_offr_typ%NOTFOUND;
      END LOOP;
   CLOSE c_num_tgt_offr_typ;

   l_party_list.delete;

   FOR k IN 1..l_master_party_id_list.COUNT LOOP
      INSERT INTO ams_dm_agg_stg_gt(
            party_id,
            age,
            days_since_last_school,
            days_since_last_event,
            num_times_targeted,
            last_targeted_channel_code,
            times_targeted_month,
            times_targeted_3_months,
            times_targeted_6_months,
            times_targeted_12_months,
            days_since_last_targeted,
            avg_disc_offered,
            num_types_disc_offered,
            days_since_first_contact,
            days_since_acct_established,
            days_since_acct_term,
            days_since_acct_activation,
            days_since_acct_suspended,
            num_times_targeted_email,
            num_times_targeted_telemkt,
            num_times_targeted_direct,
            num_tgt_by_offr_typ1,
            num_tgt_by_offr_typ2,
            num_tgt_by_offr_typ3,
            num_tgt_by_offr_typ4)
      VALUES
            (
             l_master_table(l_master_party_id_list(k)).PARTY_ID,
             l_master_table(l_master_party_id_list(k)).AGE,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_LAST_SCHOOL,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_LAST_EVENT,
             l_master_table(l_master_party_id_list(k)).NUM_TIMES_TARGETED,
             l_master_table(l_master_party_id_list(k)).LAST_TARGETED_CHANNEL_CODE,
             l_master_table(l_master_party_id_list(k)).TIMES_TARGETED_MONTH,
             l_master_table(l_master_party_id_list(k)).TIMES_TARGETED_3_MONTHS,
             l_master_table(l_master_party_id_list(k)).TIMES_TARGETED_6_MONTHS,
             l_master_table(l_master_party_id_list(k)).TIMES_TARGETED_12_MONTHS,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_LAST_TARGETED,
             l_master_table(l_master_party_id_list(k)).AVG_DISC_OFFERED,
             l_master_table(l_master_party_id_list(k)).NUM_TYPES_DISC_OFFERED,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_FIRST_CONTACT,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_ACCT_ESTABLISHED,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_ACCT_TERM,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_ACCT_ACTIVATION,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_ACCT_SUSPENDED,
             l_master_table(l_master_party_id_list(k)).NUM_TIMES_TARGETED_EMAIL,
             l_master_table(l_master_party_id_list(k)).NUM_TIMES_TARGETED_TELEMKT,
             l_master_table(l_master_party_id_list(k)).NUM_TIMES_TARGETED_DIRECT,
             l_master_table(l_master_party_id_list(k)).NUM_TGT_BY_OFFR_TYP1,
             l_master_table(l_master_party_id_list(k)).NUM_TGT_BY_OFFR_TYP2,
             l_master_table(l_master_party_id_list(k)).NUM_TGT_BY_OFFR_TYP3,
             l_master_table(l_master_party_id_list(k)).NUM_TGT_BY_OFFR_TYP4);
   END LOOP;
   l_master_table.delete;
   l_master_party_id_list.delete;

   -------------------- finish --------------------------
   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Agg_Stg;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
END InsertAggStg;

--kbasavar Added a new procedure for customer profitability
PROCEDURE InsertAggStgOrg
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'InsertAggStgOrg';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   TYPE AMS_DM_AGG_STG_ORG_REC_TYPE IS RECORD
   (
     PARTY_ID                     NUMBER(15),
     DAYS_SINCE_LAST_EVENT        NUMBER,
     NUM_TIMES_TARGETED           NUMBER,
     LAST_TARGETED_CHANNEL_CODE   VARCHAR2(30),
     TIMES_TARGETED_MONTH         NUMBER,
     TIMES_TARGETED_3_MONTHS      NUMBER,
     TIMES_TARGETED_6_MONTHS      NUMBER,
     TIMES_TARGETED_12_MONTHS     NUMBER,
     DAYS_SINCE_LAST_TARGETED     NUMBER,
     AVG_DISC_OFFERED             NUMBER,
     NUM_TYPES_DISC_OFFERED       NUMBER,
     DAYS_SINCE_FIRST_CONTACT     NUMBER,
     DAYS_SINCE_ACCT_ESTABLISHED  NUMBER,
     DAYS_SINCE_ACCT_TERM         NUMBER,
     DAYS_SINCE_ACCT_ACTIVATION   NUMBER,
     DAYS_SINCE_ACCT_SUSPENDED    NUMBER,
     NUM_TIMES_TARGETED_EMAIL     NUMBER,
     NUM_TIMES_TARGETED_TELEMKT   NUMBER,
     NUM_TIMES_TARGETED_DIRECT    NUMBER,
     NUM_TGT_BY_OFFR_TYP1         NUMBER,
     NUM_TGT_BY_OFFR_TYP2         NUMBER,
     NUM_TGT_BY_OFFR_TYP3         NUMBER,
     NUM_TGT_BY_OFFR_TYP4         NUMBER
   );

   CURSOR c_days_since_last_event IS
     SELECT (SYSDATE - MAX(aeo.event_start_date)), drv.party_id
      FROM ams_event_offers_all_b aeo, ams_dm_drv_stg_gt drv
      WHERE aeo.event_offer_id IN (SELECT aer.event_offer_id
            FROM ams_event_registrations aer
            WHERE aer.attendant_party_id in
               (select party_id
               from hz_relationships hpr
               where object_id=drv.party_id
               AND  hpr.status = 'A'
               AND  hpr.subject_table_name = 'HZ_PARTIES'
               AND  hpr.object_table_name = 'HZ_PARTIES'
               AND  hpr.directional_flag = 'F'
               AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
               AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
               )
             )
      group by drv.party_id;

   CURSOR c_num_times_targeted IS
      SELECT COUNT(DISTINCT ale.list_header_id),drv.party_id
      FROM ams_list_entries ale,  ams_dm_drv_stg_gt drv,ams_list_headers_all hdr
      WHERE ale.party_id in
         (select party_id
         from hz_relationships hpr
         where object_id=drv.party_id
         AND  hpr.status = 'A'
         AND  hpr.subject_table_name = 'HZ_PARTIES'
         AND  hpr.object_table_name = 'HZ_PARTIES'
         AND  hpr.directional_flag = 'F'
         AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
         AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
         )
      AND hdr.list_header_id = ale.list_header_id
      AND hdr.list_type = 'TARGET'
      GROUP BY drv.party_id;

   CURSOR c_last_targeted_channel_code IS
      SELECT aal.list_used_by_id, drv.party_id
      FROM ams_act_lists aal, ams_list_headers_all alh, ams_dm_drv_stg_gt drv
      WHERE aal.list_used_by = 'CSCH'
      AND   aal.list_act_type = 'TARGET'
      AND   alh.list_header_id = aal.list_header_id
      AND   alh.sent_out_date = (SELECT MAX(l.sent_out_date)
                                         FROM ams_list_headers_all l
                                         WHERE l.list_header_id IN
                                         (SELECT ale.list_header_id
                                           FROM ams_list_entries ale
                                           WHERE ale.party_id in
                                            (select party_id
                                            from hz_relationships hpr
                                            where object_id=drv.party_id
                                            AND  hpr.status = 'A'
                                            AND  hpr.subject_table_name = 'HZ_PARTIES'
                                            AND  hpr.object_table_name = 'HZ_PARTIES'
                                            AND  hpr.directional_flag = 'F'
                                            AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
                                            AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
                                            )
                                          ))
        group by drv.party_id,aal.list_used_by_id;

   CURSOR c_times_targeted IS
      SELECT SUM(DECODE(SIGN(MONTHS_BETWEEN(SYSDATE, alh.sent_out_date) -1),1,0,1)),
         SUM(DECODE(SIGN(MONTHS_BETWEEN(SYSDATE, alh.sent_out_date) -3),1,0,1)),
         SUM(DECODE(SIGN(MONTHS_BETWEEN(SYSDATE, alh.sent_out_date) -9),1,0,1)),
         SUM(DECODE(SIGN(MONTHS_BETWEEN(SYSDATE, alh.sent_out_date) -12),1,0,1)), drv.party_id
      FROM ams_list_headers_all alh,ams_dm_drv_stg_gt drv
      WHERE alh.sent_out_date IS NOT NULL
      AND MONTHS_BETWEEN(sysdate, alh.sent_out_date) <= 12
      AND alh.list_header_id IN (SELECT ale.list_header_id
      FROM ams_list_entries ale
      WHERE ale.party_id in
         (select party_id
      from hz_relationships hpr
      where object_id=drv.party_id
      AND  hpr.status = 'A'
      AND  hpr.subject_table_name = 'HZ_PARTIES'
      AND  hpr.object_table_name = 'HZ_PARTIES'
      AND  hpr.directional_flag = 'F'
      AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
      AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
      ))
      group by drv.party_id;

   CURSOR c_days_since_last_targeted IS
      SELECT (SYSDATE - MAX(aeo.event_start_date)), drv.party_id
      FROM ams_event_offers_all_b aeo, ams_dm_drv_stg_gt drv
      WHERE aeo.event_offer_id IN (SELECT aer.event_offer_id
      FROM ams_event_registrations aer
      WHERE  aer.attendant_party_id in
         (select party_id
         from hz_relationships hpr
         where object_id=drv.party_id
         AND  hpr.status = 'A'
         AND  hpr.subject_table_name = 'HZ_PARTIES'
         AND  hpr.object_table_name = 'HZ_PARTIES'
         AND  hpr.directional_flag = 'F'
         AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
         AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
         )
      )
     group by drv.party_id;

   CURSOR c_avg_disc_offered IS
     SELECT AVG(aao.offer_amount),drv.party_id
      FROM ams_act_offers aao, ams_campaign_schedules acs, ams_dm_drv_stg_gt drv
      WHERE aao.arc_act_offer_used_by = 'CSCH'
      AND aao.activity_offer_id = acs.activity_offer_id
      AND acs.campaign_schedule_id IN (SELECT aal.list_used_by_id
      FROM ams_act_lists aal
      WHERE aal.list_used_by = 'CSCH'
      AND   aal.list_act_type = 'TARGET'
      AND   aal.list_header_id IN (SELECT ale.list_header_id
	      FROM ams_list_entries ale
	      WHERE ale.party_id in
              (select party_id
               from hz_relationships hpr
               where object_id=drv.party_id
               AND  hpr.status = 'A'
               AND  hpr.subject_table_name = 'HZ_PARTIES'
               AND  hpr.object_table_name = 'HZ_PARTIES'
               AND  hpr.directional_flag = 'F'
               AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
               AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
              )
             ))
     group by drv.party_id;


   CURSOR c_num_types_disc_offered IS
      SELECT COUNT(aao.offer_type),drv.party_id
      FROM   ams_act_offers aao, ams_campaign_schedules acs,ams_dm_drv_stg_gt drv
      WHERE  aao.arc_act_offer_used_by = 'CSCH'
      AND    aao.activity_offer_id = acs.activity_offer_id
      AND    acs.campaign_schedule_id IN (SELECT aal.list_used_by_id
      FROM ams_list_entries ale, ams_act_lists aal
      WHERE aal.list_header_id = ale.list_header_id
      AND   aal.list_used_by = 'CSCH'
      AND   aal.list_act_type = 'TARGET'
      AND   ale.party_id in
      (select party_id
       from hz_relationships hpr
       where object_id=drv.party_id
       AND  hpr.status = 'A'
       AND  hpr.subject_table_name = 'HZ_PARTIES'
       AND  hpr.object_table_name = 'HZ_PARTIES'
       AND  hpr.directional_flag = 'F'
       AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
       AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
      )
      )
     group by drv.party_id;

   CURSOR c_days_since_first_contact IS
      SELECT (SYSDATE - MIN(aeo.event_start_date)),drv.party_id
      FROM ams_event_offers_all_b aeo, ams_dm_drv_stg_gt drv
      WHERE aeo.event_offer_id IN (SELECT 1
      FROM ams_event_registrations aer
      WHERE aer.attendant_party_id in
      (select party_id
       from hz_relationships hpr
       where object_id=drv.party_id
       AND  hpr.status = 'A'
       AND  hpr.subject_table_name = 'HZ_PARTIES'
       AND  hpr.object_table_name = 'HZ_PARTIES'
       AND  hpr.directional_flag = 'F'
       AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
       AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
      )
      )
      group by drv.party_id;

   CURSOR c_days_since_account IS
      SELECT SYSDATE - MAX(hca.account_established_date),
      0,--SYSDATE - MAX(hca.account_termination_date),
      0 --SYSDATE - MAX(hca.account_activation_date)
      ,drv.party_id
      FROM hz_cust_accounts hca, ams_dm_drv_stg_gt drv
      WHERE hca.party_id = drv.party_id
      AND   hca.status = 'A'
      group by drv.party_id;

   CURSOR c_num_times_tgt_chnl IS
      SELECT SUM(DECODE(acs.activity_id, G_MEDIA_EMAIL,1,0)),
      SUM(DECODE(acs.activity_id, G_MEDIA_TELEMARKETING ,1,0)),
      SUM(DECODE(acs.activity_id, G_MEDIA_DIRECTMAIL ,1,0)), drv.party_id
      FROM ams_list_entries ale,
      ams_act_lists aal,
      ams_campaign_schedules_b acs,
      --ams_media_b ame,
      ams_dm_drv_stg_gt drv
      WHERE aal.list_used_by = 'CSCH'
      AND   aal.list_used_by_id = acs.schedule_id
      AND   aal.list_act_type = 'TARGET'
      AND   acs.activity_type_code = 'DIRECT_MARKETING'
      --AND   acs.activity_id = ame.media_id
      AND   aal.list_header_id = ale.list_header_id
      AND   ale.party_id in
      (select party_id
       from hz_relationships hpr
       where object_id=drv.party_id
       AND  hpr.status = 'A'
       AND  hpr.subject_table_name = 'HZ_PARTIES'
       AND  hpr.object_table_name = 'HZ_PARTIES'
       AND  hpr.directional_flag = 'F'
       AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
       AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
      )
      group by drv.party_id;


   CURSOR c_num_tgt_offr_typ IS
      SELECT SUM(DECODE(UPPER(offer_type),'ACCRUAL',1,0)),
      SUM(DECODE(UPPER(offer_type),'LUMPSUM',1,0)),
      SUM(DECODE(UPPER(offer_type),'ORDER',1,0)),
      SUM(DECODE(UPPER(offer_type),'OFF_INVOICE',1,0)), drv.party_id
      FROM ams_list_entries ale,
      ams_act_lists aal,
      ams_campaign_schedules_b acs,
      ams_act_offers aao, ams_dm_drv_stg_gt drv
      WHERE aal.list_used_by = 'CSCH'
      AND   aal.list_used_by_id = acs.schedule_id
      AND   aal.list_act_type = 'TARGET'
      AND   acs.end_date_time <= SYSDATE
      AND   acs.activity_id = aao.activity_offer_id
      AND   aal.list_header_id = ale.list_header_id
      AND   ale. party_id in
      (select party_id
       from hz_relationships hpr
       where object_id=drv.party_id
       AND  hpr.status = 'A'
       AND  hpr.subject_table_name = 'HZ_PARTIES'
       AND  hpr.object_table_name = 'HZ_PARTIES'
       AND  hpr.directional_flag = 'F'
       AND  hpr.relationship_code IN ('CONTACT_OF' ,   'EMPLOYEE_OF')
       AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
      )
     group by drv.party_id;

-- nyostos - Sep 15, 2003 - Use Global Temporary Table
-- CURSOR cur_party IS SELECT party_id FROM AMS_DM_DRV_stg_gt;
   CURSOR c_all_parties IS SELECT party_id FROM AMS_DM_DRV_stg_gt;

   -- choang - 05-aug-2004 - bug 3816612 - changing to use index by binary integer
   TYPE l_master_table_type IS
        TABLE OF AMS_DM_AGG_STG_ORG_REC_TYPE INDEX BY BINARY_INTEGER;
--        TABLE OF AMS_DM_AGG_STG_ORG_REC_TYPE INDEX BY VARCHAR2(15);

   TYPE t_number_table IS TABLE OF NUMBER(15)
                         INDEX BY BINARY_INTEGER;

   l_bs_rows   NUMBER;
   l_all_party_id_list     dbms_sql.NUMBER_table;

   l_master_party_id_list     t_number_table;
   l_master_rec AMS_DM_AGG_STG_ORG_REC_TYPE;
   l_master_table l_master_table_type;

   l_party_list   t_number_table;
   l_days_since_last_event_list    dbms_sql.NUMBER_table;
   l_num_times_tgt_list    dbms_sql.NUMBER_table;
   l_last_targeted_ch_code_list    dbms_sql.VARCHAR2_table;
   l_times_tgt_month_list    dbms_sql.NUMBER_table;
   l_times_tgt_3months_list    dbms_sql.NUMBER_table;
   l_times_tgt_6months_list    dbms_sql.NUMBER_table;
   l_times_tgt_12months_list    dbms_sql.NUMBER_table;
   l_days_since_last_tgt_list    dbms_sql.NUMBER_table;
   l_avg_disc_offered_list     dbms_sql.NUMBER_table;
   l_num_types_disc_offered_list    dbms_sql.NUMBER_table;
   l_days_since_first_cnt_list    dbms_sql.NUMBER_table;
   l_days_since_acct_estb_list    dbms_sql.NUMBER_table;
   l_days_since_acct_term_list    dbms_sql.NUMBER_table;
   l_days_since_acct_act_list    dbms_sql.NUMBER_table;
   l_num_times_tgt_email_list    dbms_sql.NUMBER_table;
   l_num_times_tgt_telemkt_list    dbms_sql.NUMBER_table;
   l_num_times_tgt_direct_list    dbms_sql.NUMBER_table;
   l_num_tgt_by_offr_typ1_list    dbms_sql.NUMBER_table;
   l_num_tgt_by_offr_typ2_list    dbms_sql.NUMBER_table;
   l_num_tgt_by_offr_typ3_list    dbms_sql.NUMBER_table;
   l_num_tgt_by_offr_typ4_list    dbms_sql.NUMBER_table;

   l_count NUMBER := 1;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Insert_Agg_stg_Org;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   l_bs_rows:= fnd_profile.value_specific('AMS_BATCH_SIZE');
   IF  (l_bs_rows  IS NULL  OR l_bs_rows < 1) THEN
      l_bs_rows :=1000;
   END IF;

   --get all the parties into the mater table.
   OPEN c_all_parties;
      LOOP
        FETCH c_all_parties BULK COLLECT INTO l_all_party_id_list  LIMIT l_bs_rows;
            FOR i IN 1..l_all_party_id_list.COUNT LOOP
               l_master_party_id_list(l_count) := l_all_party_id_list(i);
               l_count := l_count+1;
               l_master_rec.PARTY_ID := l_all_party_id_list(i);
	       l_master_table(l_all_party_id_list(i)) :=  l_master_rec;
            END LOOP;
         EXIT WHEN c_all_parties%NOTFOUND;
      END LOOP;
   CLOSE c_all_parties;

   OPEN c_days_since_last_event;
      LOOP
         FETCH c_days_since_last_event BULK COLLECT INTO l_days_since_last_event_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).DAYS_SINCE_LAST_EVENT :=  l_days_since_last_event_list(i);
         END LOOP;
      EXIT WHEN c_days_since_last_event%NOTFOUND;
      END LOOP;
   CLOSE c_days_since_last_event;

   l_party_list.delete;

   OPEN c_num_times_targeted;
      LOOP
         FETCH c_num_times_targeted BULK COLLECT INTO l_num_times_tgt_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).NUM_TIMES_TARGETED :=  l_num_times_tgt_list(i);
         END LOOP;
         EXIT WHEN c_num_times_targeted%NOTFOUND;
      END LOOP;
   CLOSE c_num_times_targeted;

   l_party_list.delete;

   /*--commented due to perf issue
   OPEN c_last_targeted_channel_code;
      LOOP
         FETCH c_last_targeted_channel_code BULK COLLECT INTO l_last_targeted_ch_code_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).LAST_TARGETED_CHANNEL_CODE :=  l_last_targeted_ch_code_list(i);
         END LOOP;
         EXIT WHEN c_last_targeted_channel_code%NOTFOUND;
      END LOOP;
   CLOSE c_last_targeted_channel_code;

   l_party_list.delete;
   */

   OPEN c_times_targeted;

      LOOP
         FETCH c_times_targeted
            BULK COLLECT
            INTO l_times_tgt_month_list,
               l_times_tgt_3months_list,
               l_times_tgt_6months_list,
               l_times_tgt_12months_list,
               l_party_list
            LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).TIMES_TARGETED_MONTH :=  l_times_tgt_month_list(i);
            l_master_table(l_party_list(i)).TIMES_TARGETED_3_MONTHS :=  l_times_tgt_3months_list(i);
            l_master_table(l_party_list(i)).TIMES_TARGETED_6_MONTHS :=  l_times_tgt_6months_list(i);
            l_master_table(l_party_list(i)).TIMES_TARGETED_12_MONTHS :=  l_times_tgt_12months_list(i);
         END LOOP;
         EXIT WHEN c_times_targeted%NOTFOUND;
      END LOOP;

   l_party_list.delete;

   OPEN c_days_since_last_targeted;
      LOOP
         FETCH c_days_since_last_targeted BULK COLLECT INTO l_days_since_last_tgt_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).DAYS_SINCE_LAST_TARGETED :=  l_days_since_last_tgt_list(i);
         END LOOP;
         EXIT WHEN c_days_since_last_targeted%NOTFOUND;
      END LOOP;
   CLOSE c_days_since_last_targeted;

   l_party_list.delete;

   OPEN c_avg_disc_offered;
      LOOP
         FETCH c_avg_disc_offered BULK COLLECT INTO l_avg_disc_offered_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).AVG_DISC_OFFERED :=  l_avg_disc_offered_list(i);
         END LOOP;
         EXIT WHEN c_avg_disc_offered%NOTFOUND;
      END LOOP;
   CLOSE c_avg_disc_offered;

   l_party_list.delete;

   OPEN c_num_types_disc_offered;
      LOOP
         FETCH c_num_types_disc_offered BULK COLLECT INTO l_num_types_disc_offered_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).NUM_TYPES_DISC_OFFERED :=  l_num_types_disc_offered_list(i);
         END LOOP;
         EXIT WHEN c_num_types_disc_offered%NOTFOUND;
      END LOOP;
   CLOSE c_num_types_disc_offered;

   l_party_list.delete;

   OPEN c_days_since_first_contact;
      LOOP
         FETCH c_days_since_first_contact BULK COLLECT INTO l_days_since_first_cnt_list,l_party_list  LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).DAYS_SINCE_FIRST_CONTACT :=  l_days_since_first_cnt_list(i);
         END LOOP;
         EXIT WHEN c_days_since_first_contact%NOTFOUND;
      END LOOP;
   CLOSE c_days_since_first_contact;

   l_party_list.delete;

   OPEN c_days_since_account;
      LOOP
         FETCH c_days_since_account BULK COLLECT
         INTO l_days_since_acct_estb_list,
            l_days_since_acct_term_list,
            l_days_since_acct_act_list,
            l_party_list
         LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).DAYS_SINCE_ACCT_ESTABLISHED := l_days_since_acct_estb_list(i);
            l_master_table(l_party_list(i)).DAYS_SINCE_ACCT_TERM :=  l_days_since_acct_term_list(i);
            l_master_table(l_party_list(i)).DAYS_SINCE_ACCT_ACTIVATION :=  l_days_since_acct_act_list(i);
         END LOOP;
         EXIT WHEN c_days_since_account%NOTFOUND;
      END LOOP;
   CLOSE c_days_since_account;

   l_party_list.delete;

   OPEN c_num_times_tgt_chnl;
      LOOP
         FETCH c_num_times_tgt_chnl BULK COLLECT
         INTO l_num_times_tgt_email_list,
           l_num_times_tgt_telemkt_list,
           l_num_times_tgt_direct_list,
           l_party_list
           LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).NUM_TIMES_TARGETED_EMAIL  := l_num_times_tgt_email_list(i);
            l_master_table(l_party_list(i)).NUM_TIMES_TARGETED_TELEMKT := l_num_times_tgt_telemkt_list(i);
            l_master_table(l_party_list(i)).NUM_TIMES_TARGETED_DIRECT := l_num_times_tgt_direct_list(i);
        END LOOP;
        EXIT WHEN c_num_times_tgt_chnl%NOTFOUND;
      END LOOP;
   CLOSE c_num_times_tgt_chnl;

   l_party_list.delete;

   OPEN c_num_tgt_offr_typ;
      LOOP
         FETCH c_num_tgt_offr_typ BULK COLLECT
         INTO l_num_tgt_by_offr_typ1_list,
           l_num_tgt_by_offr_typ2_list,
           l_num_tgt_by_offr_typ3_list,
           l_num_tgt_by_offr_typ4_list,
           l_party_list
           LIMIT l_bs_rows;
         FOR i IN 1..l_party_list.COUNT LOOP
            l_master_table(l_party_list(i)).NUM_TGT_BY_OFFR_TYP1  := l_num_tgt_by_offr_typ1_list(i);
            l_master_table(l_party_list(i)).NUM_TGT_BY_OFFR_TYP2 := l_num_tgt_by_offr_typ1_list(i);
            l_master_table(l_party_list(i)).NUM_TGT_BY_OFFR_TYP3 := l_num_tgt_by_offr_typ1_list(i);
            l_master_table(l_party_list(i)).NUM_TGT_BY_OFFR_TYP4 := l_num_tgt_by_offr_typ1_list(i);
        END LOOP;
        EXIT WHEN c_num_tgt_offr_typ%NOTFOUND;
      END LOOP;
   CLOSE c_num_tgt_offr_typ;

   l_party_list.delete;

   FOR k IN 1..l_master_party_id_list.COUNT LOOP
      INSERT INTO ams_dm_agg_stg_gt(
            party_id,
            days_since_last_event,
            num_times_targeted,
            last_targeted_channel_code,
            times_targeted_month,
            times_targeted_3_months,
            times_targeted_6_months,
            times_targeted_12_months,
            days_since_last_targeted,
            avg_disc_offered,
            num_types_disc_offered,
            days_since_first_contact,
            days_since_acct_established,
            days_since_acct_term,
            days_since_acct_activation,
            days_since_acct_suspended,
            num_times_targeted_email,
            num_times_targeted_telemkt,
            num_times_targeted_direct,
            num_tgt_by_offr_typ1,
            num_tgt_by_offr_typ2,
            num_tgt_by_offr_typ3,
            num_tgt_by_offr_typ4)
      VALUES
            (
             l_master_table(l_master_party_id_list(k)).PARTY_ID,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_LAST_EVENT,
             l_master_table(l_master_party_id_list(k)).NUM_TIMES_TARGETED,
             l_master_table(l_master_party_id_list(k)).LAST_TARGETED_CHANNEL_CODE,
             l_master_table(l_master_party_id_list(k)).TIMES_TARGETED_MONTH,
             l_master_table(l_master_party_id_list(k)).TIMES_TARGETED_3_MONTHS,
             l_master_table(l_master_party_id_list(k)).TIMES_TARGETED_6_MONTHS,
             l_master_table(l_master_party_id_list(k)).TIMES_TARGETED_12_MONTHS,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_LAST_TARGETED,
             l_master_table(l_master_party_id_list(k)).AVG_DISC_OFFERED,
             l_master_table(l_master_party_id_list(k)).NUM_TYPES_DISC_OFFERED,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_FIRST_CONTACT,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_ACCT_ESTABLISHED,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_ACCT_TERM,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_ACCT_ACTIVATION,
             l_master_table(l_master_party_id_list(k)).DAYS_SINCE_ACCT_SUSPENDED,
             l_master_table(l_master_party_id_list(k)).NUM_TIMES_TARGETED_EMAIL,
             l_master_table(l_master_party_id_list(k)).NUM_TIMES_TARGETED_TELEMKT,
             l_master_table(l_master_party_id_list(k)).NUM_TIMES_TARGETED_DIRECT,
             l_master_table(l_master_party_id_list(k)).NUM_TGT_BY_OFFR_TYP1,
             l_master_table(l_master_party_id_list(k)).NUM_TGT_BY_OFFR_TYP2,
             l_master_table(l_master_party_id_list(k)).NUM_TGT_BY_OFFR_TYP3,
             l_master_table(l_master_party_id_list(k)).NUM_TGT_BY_OFFR_TYP4);
   END LOOP;
   l_master_table.delete;
   l_master_party_id_list.delete;

-------------------- finish --------------------------
   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Agg_stg_Org;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

END InsertAggStgOrg;


-- End of complex transformations

PROCEDURE InsertBICStg(
   p_is_b2b   IN BOOLEAN,
   p_model_type  IN VARCHAR2,
   p_is_org_prod IN BOOLEAN
)
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'InsertBICStg';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_date DATE := TRUNC(TO_DATE(TO_CHAR(ADD_MONTHS(SYSDATE, 1),'DD-MM-YYYY'), 'DD-MM-YYYY'), 'MONTH');
   l_is_b2b       BOOLEAN;

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Insert_BIC_Stg;
   l_is_b2b:=p_is_b2b;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   ----------------------- Insert ----------------------
   IF l_is_b2b THEN
      IF p_model_type='CUSTOMER_PROFITABILITY' OR p_is_org_prod THEN
--       nyostos - Sep 15, 2003 - Use Global Temporary Table
--       INSERT -- /*+ APPEND PARALLEL(AMS_DM_BIC_STG,DEFAULT,DEFAULT)*/
--       INTO ams_dm_BIC_stg (
         INSERT -- /*+ APPEND PARALLEL(AMS_DM_BIC_STG_GT,DEFAULT,DEFAULT)*/
         INTO ams_dm_BIC_stg_GT (
            party_id,
            avg_talk_time,
            avg_order_amount,
            avg_units_per_order,
            tot_order_amount_year,
            tot_order_amount_9_months,
            tot_order_amount_6_months,
            tot_order_amount_3_months,
            tot_num_orders_year,
            tot_num_order_9_months,
            tot_num_order_6_months,
            tot_num_order_3_months,
            num_of_sr_year,
            num_of_sr_6_months,
            num_of_sr_3_months,
            num_of_sr_1_month,
            avg_resolve_days_year,
            avg_resolve_days_6_months,
            avg_resolve_days_3_months,
            avg_resolve_days_1_month,
            order_lines_delivered,
            order_lines_ontime,
            order_qty_cumul,
            order_recency,
            payments,
            returns,
            return_by_value,
            return_by_value_pct,
            ontime_payments,
            ontime_ship_pct,
            closed_srs,
            COGS,
            contracts_cuml,
            contract_amt,
            contract_duration,
            inactive_contracts,
            open_contracts,
            new_contracts,
            renewed_contracts,
            escalated_srs,
            first_call_cl_rate,
            num_of_complaints,
            num_of_interactions,
            num_of_transfers,
            open_srs,
            pct_call_rework,
            products,
            referals,
            reopened_srs,
            sales,
            total_sr_response_time,
            pct_first_closed_srs,
            avg_complaints,
            avg_hold_time,
            avg_len_of_emp,
            avg_transfers_per_sr,
            avg_workload,
            tot_calls,
            call_length,
            profitability)
         SELECT
            drv.party_id party_id,
            AVG(bps.avg_talk_time) avg_talk_time, -- Can we do avg of avg.. this may be wrong.
            SUM(bps.order_amt)/SUM(bps.order_num) avg_order_amount,
            SUM(bps.order_qty)/SUM(bps.order_num) avg_units_per_order,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,order_amt)) tot_order_amount_year,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 9),1,0,order_amt)) tot_order_amount_9_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,order_amt)) tot_order_amount_6_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,order_amt)) tot_order_amount_3_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,order_num)) tot_num_orders_year,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 9),1,0,order_num)) tot_num_order_9_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,order_num)) tot_num_order_6_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,order_num)) tot_num_order_3_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,srs_logged)) num_of_sr_year,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,srs_logged)) num_of_sr_6_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,srs_logged)) num_of_sr_3_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 1),1,0,srs_logged)) num_of_sr_1_month,
            AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,avg_sr_resl_time)) avg_resolve_days_year,
            AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,avg_sr_resl_time)) avg_resolve_days_6_months,
            AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,avg_sr_resl_time)) avg_resolve_days_3_months,
            AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 1),1,0,avg_sr_resl_time)) avg_resolve_days_1_month,
            SUM(bps.order_lines_delivered) order_lines_delivered,
            SUM(bps.order_lines_ontime) order_lines_ontime,
            SUM(bps.order_qty_cuml) order_qty_cuml,
            SUM(bps.order_recency) order_recency,
            SUM(bps.payments) payments,
            SUM(bps.returns) returns,
            SUM(bps.return_by_value) return_by_value,
            SUM(bps.return_by_value_pct) return_by_value_pct,
            SUM(bps.ontime_payments) ontime_payments,
            SUM(bps.ontime_ship_pct) ontime_ship_pct,
            SUM(bps.closed_srs) closed_srs,
            SUM(bps.COGS) COGS,
            SUM(bps.contracts_cuml) contracts_cuml,
            SUM(bps.contract_amt) contract_amt,
            SUM(bps.contract_duration) contract_duration,
            SUM(bps.inactive_contracts) inactive_contracts,
            SUM(bps.open_contracts) open_contracts,
            SUM(bps.new_contracts) new_contracts,
            SUM(bps.renewed_contracts) renewed_contracts,
            SUM(bps.esc_srs) escalated_srs,
            AVG(bps.first_call_cl_rate) first_call_cl_rate,
            SUM(bps.no_of_complaints) num_of_complaints,
            SUM(bps.no_of_interactions) num_of_interactions,
            SUM(bps.no_of_transfers) num_of_transfers,
            SUM(bps.open_srs) open_srs,
            AVG(bps.perct_call_rework) pct_call_rework,
            SUM(bps.products) products,
            SUM(bps.referals) referals,
            SUM(bps.reopened_srs) reopened_srs,
            SUM(bps.sales) sales,
            SUM(bps.total_sr_response_time) total_sr_response_time,
            AVG(bps.avg_closed_srs) pct_first_closed_srs, --note
            AVG(bps.avg_complaints) avg_complaints,
            AVG(bps.avg_hold_time) avg_hold_time,
            AVG(bps.avg_len_of_emp) avg_len_of_emp,
            AVG(bps.avg_transfers_per_sr) avg_transfers_per_sr,
            AVG(bps.avg_workload) avg_workload,
            SUM(bps.calls) tot_calls, --note
            AVG(bps.call_length) call_length,
            AVG(bps.profitability) profitability
	 FROM bic_party_summ bps,
--	        ams_dm_drv_stg    drv
	        ams_dm_drv_stg_gt drv    -- nyostos - Sep 15, 2003 - Global Temp Table
	 WHERE drv.party_id = bps.party_id(+)
	 AND  bps.period_start_date(+) > l_date - 365
         GROUP BY drv.party_id
	 ;
      ELSE
--       nyostos - Sep 15, 2003 - Use Global Temporary Table
--       INSERT -- /*+ APPEND PARALLEL(AMS_DM_BIC_STG,DEFAULT,DEFAULT)*/
--       INTO ams_dm_BIC_stg (
         INSERT -- /*+ APPEND PARALLEL(AMS_DM_BIC_STG_GT,DEFAULT,DEFAULT)*/
         INTO ams_dm_BIC_stg_GT (
            party_id,
            avg_talk_time,
            avg_order_amount,
            avg_units_per_order,
            tot_order_amount_year,
            tot_order_amount_9_months,
            tot_order_amount_6_months,
            tot_order_amount_3_months,
            tot_num_orders_year,
            tot_num_order_9_months,
            tot_num_order_6_months,
            tot_num_order_3_months,
            num_of_sr_year,
            num_of_sr_6_months,
            num_of_sr_3_months,
            num_of_sr_1_month,
            avg_resolve_days_year,
            avg_resolve_days_6_months,
            avg_resolve_days_3_months,
            avg_resolve_days_1_month,
            order_lines_delivered,
            order_lines_ontime,
            order_qty_cumul,
            order_recency,
            payments,
            returns,
            return_by_value,
            return_by_value_pct,
            ontime_payments,
            ontime_ship_pct,
            closed_srs,
            COGS,
            contracts_cuml,
            contract_amt,
            contract_duration,
            inactive_contracts,
            open_contracts,
            new_contracts,
            renewed_contracts,
            escalated_srs,
            first_call_cl_rate,
            num_of_complaints,
            num_of_interactions,
            num_of_transfers,
            open_srs,
            pct_call_rework,
            products,
            referals,
            reopened_srs,
            sales,
            total_sr_response_time,
            pct_first_closed_srs,
            avg_complaints,
            avg_hold_time,
            avg_len_of_emp,
            avg_transfers_per_sr,
            avg_workload,
            tot_calls,
            call_length,
            profitability)
         SELECT
            drv.party_id party_id,
            AVG(bps.avg_talk_time) avg_talk_time, -- Can we do avg of avg.. this may be wrong.
            SUM(bps.order_amt)/SUM(bps.order_num) avg_order_amount,
            SUM(bps.order_qty)/SUM(bps.order_num) avg_units_per_order,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,order_amt)) tot_order_amount_year,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 9),1,0,order_amt)) tot_order_amount_9_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,order_amt)) tot_order_amount_6_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,order_amt)) tot_order_amount_3_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,order_num)) tot_num_orders_year,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 9),1,0,order_num)) tot_num_order_9_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,order_num)) tot_num_order_6_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,order_num)) tot_num_order_3_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,srs_logged)) num_of_sr_year,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,srs_logged)) num_of_sr_6_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,srs_logged)) num_of_sr_3_months,
            SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 1),1,0,srs_logged)) num_of_sr_1_month,
            AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,avg_sr_resl_time)) avg_resolve_days_year,
            AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,avg_sr_resl_time)) avg_resolve_days_6_months,
            AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,avg_sr_resl_time)) avg_resolve_days_3_months,
            AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 1),1,0,avg_sr_resl_time)) avg_resolve_days_1_month,
            SUM(bps.order_lines_delivered) order_lines_delivered,
            SUM(bps.order_lines_ontime) order_lines_ontime,
            SUM(bps.order_qty_cuml) order_qty_cuml,
            SUM(bps.order_recency) order_recency,
            SUM(bps.payments) payments,
            SUM(bps.returns) returns,
            SUM(bps.return_by_value) return_by_value,
            SUM(bps.return_by_value_pct) return_by_value_pct,
            SUM(bps.ontime_payments) ontime_payments,
            SUM(bps.ontime_ship_pct) ontime_ship_pct,
            SUM(bps.closed_srs) closed_srs,
            SUM(bps.COGS) COGS,
            SUM(bps.contracts_cuml) contracts_cuml,
            SUM(bps.contract_amt) contract_amt,
            SUM(bps.contract_duration) contract_duration,
            SUM(bps.inactive_contracts) inactive_contracts,
            SUM(bps.open_contracts) open_contracts,
            SUM(bps.new_contracts) new_contracts,
            SUM(bps.renewed_contracts) renewed_contracts,
            SUM(bps.esc_srs) escalated_srs,
            AVG(bps.first_call_cl_rate) first_call_cl_rate,
            SUM(bps.no_of_complaints) num_of_complaints,
            SUM(bps.no_of_interactions) num_of_interactions,
            SUM(bps.no_of_transfers) num_of_transfers,
            SUM(bps.open_srs) open_srs,
            AVG(bps.perct_call_rework) pct_call_rework,
            SUM(bps.products) products,
            SUM(bps.referals) referals,
            SUM(bps.reopened_srs) reopened_srs,
            SUM(bps.sales) sales,
            SUM(bps.total_sr_response_time) total_sr_response_time,
            AVG(bps.avg_closed_srs) pct_first_closed_srs, --note
            AVG(bps.avg_complaints) avg_complaints,
            AVG(bps.avg_hold_time) avg_hold_time,
            AVG(bps.avg_len_of_emp) avg_len_of_emp,
            AVG(bps.avg_transfers_per_sr) avg_transfers_per_sr,
            AVG(bps.avg_workload) avg_workload,
            SUM(bps.calls) tot_calls, --note
            AVG(bps.call_length) call_length,
            AVG(bps.profitability) profitability
         FROM bic_party_summ bps,
--            ams_dm_drv_stg    drv,
              ams_dm_drv_stg_gt drv,      -- nyostos - Sep 15, 2003 - Global Temp Table
             hz_relationships hpr
         WHERE drv.party_id = hpr.party_id
         AND  hpr.status = 'A'
         AND  hpr.subject_table_name = 'HZ_PARTIES'
         AND  hpr.object_table_name = 'HZ_PARTIES'
         AND  hpr.directional_flag = 'F'
         AND  hpr.relationship_code IN ('CONTACT_OF' , 'EMPLOYEE_OF')
         AND (SYSDATE BETWEEN hpr.start_date and NVL(hpr.end_date,SYSDATE))
         AND  bps.party_id(+) = hpr.object_id        --the org's party id
         AND  bps.period_start_date(+) > l_date - 365
         GROUP BY drv.party_id
         ;
   END IF;
ELSE
--       nyostos - Sep 15, 2003 - Use Global Temporary Table
--   INSERT -- /*+ APPEND PARALLEL(AMS_DM_BIC_STG,DEFAULT,DEFAULT)*/
--   INTO ams_dm_BIC_stg (
     INSERT -- /*+ APPEND PARALLEL(AMS_DM_BIC_STG_GT,DEFAULT,DEFAULT)*/
     INTO ams_dm_BIC_stg_GT (
     party_id,
     avg_talk_time,
     avg_order_amount,
     avg_units_per_order,
     tot_order_amount_year,
     tot_order_amount_9_months,
     tot_order_amount_6_months,
     tot_order_amount_3_months,
     tot_num_orders_year,
     tot_num_order_9_months,
     tot_num_order_6_months,
     tot_num_order_3_months,
     num_of_sr_year,
     num_of_sr_6_months,
     num_of_sr_3_months,
     num_of_sr_1_month,
     avg_resolve_days_year,
     avg_resolve_days_6_months,
     avg_resolve_days_3_months,
     avg_resolve_days_1_month,
     order_lines_delivered,
     order_lines_ontime,
     order_qty_cumul,
     order_recency,
     payments,
     returns,
     return_by_value,
     return_by_value_pct,
     ontime_payments,
     ontime_ship_pct,
     closed_srs,
     COGS,
     contracts_cuml,
     contract_amt,
     contract_duration,
     inactive_contracts,
     open_contracts,
     new_contracts,
     renewed_contracts,
     escalated_srs,
     first_call_cl_rate,
     num_of_complaints,
     num_of_interactions,
     num_of_transfers,
     open_srs,
     pct_call_rework,
     products,
     referals,
     reopened_srs,
     sales,
     total_sr_response_time,
     pct_first_closed_srs,
     avg_complaints,
     avg_hold_time,
     avg_len_of_emp,
     avg_transfers_per_sr,
     avg_workload,
     tot_calls,
     call_length,
     profitability)
   SELECT
     drv.party_id party_id,
     AVG(bps.avg_talk_time) avg_talk_time, -- Can we do avg of avg.. this may be wrong.
     SUM(bps.order_amt)/SUM(bps.order_num) avg_order_amount,
     SUM(bps.order_qty)/SUM(bps.order_num) avg_units_per_order,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,order_amt)) tot_order_amount_year,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 9),1,0,order_amt)) tot_order_amount_9_months,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,order_amt)) tot_order_amount_6_months,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,order_amt)) tot_order_amount_3_months,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,order_num)) tot_num_orders_year,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 9),1,0,order_num)) tot_num_order_9_months,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,order_num)) tot_num_order_6_months,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,order_num)) tot_num_order_3_months,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,srs_logged)) num_of_sr_year,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,srs_logged)) num_of_sr_6_months,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,srs_logged)) num_of_sr_3_months,
     SUM(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 1),1,0,srs_logged)) num_of_sr_1_month,
     AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) -12),1,0,avg_sr_resl_time)) avg_resolve_days_year,
     AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 6),1,0,avg_sr_resl_time)) avg_resolve_days_6_months,
     AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 3),1,0,avg_sr_resl_time)) avg_resolve_days_3_months,
     AVG(DECODE(SIGN(ROUND(MONTHS_BETWEEN(l_date, period_start_date)) - 1),1,0,avg_sr_resl_time)) avg_resolve_days_1_month,
     SUM(bps.order_lines_delivered) order_lines_delivered,
     SUM(bps.order_lines_ontime) order_lines_ontime,
     SUM(bps.order_qty_cuml) order_qty_cuml,
     SUM(bps.order_recency) order_recency,
     SUM(bps.payments) payments,
     SUM(bps.returns) returns,
     SUM(bps.return_by_value) return_by_value,
     SUM(bps.return_by_value_pct) return_by_value_pct,
     SUM(bps.ontime_payments) ontime_payments,
     SUM(bps.ontime_ship_pct) ontime_ship_pct,
     SUM(bps.closed_srs) closed_srs,
     SUM(bps.COGS) COGS,
     SUM(bps.contracts_cuml) contracts_cuml,
     SUM(bps.contract_amt) contract_amt,
     SUM(bps.contract_duration) contract_duration,
     SUM(bps.inactive_contracts) inactive_contracts,
     SUM(bps.open_contracts) open_contracts,
     SUM(bps.new_contracts) new_contracts,
     SUM(bps.renewed_contracts) renewed_contracts,
     SUM(bps.esc_srs) escalated_srs,
     AVG(bps.first_call_cl_rate) first_call_cl_rate,
     SUM(bps.no_of_complaints) num_of_complaints,
     SUM(bps.no_of_interactions) num_of_interactions,
     SUM(bps.no_of_transfers) num_of_transfers,
     SUM(bps.open_srs) open_srs,
     AVG(bps.perct_call_rework) pct_call_rework,
     SUM(bps.products) products,
     SUM(bps.referals) referals,
     SUM(bps.reopened_srs) reopened_srs,
     SUM(bps.sales) sales,
     SUM(bps.total_sr_response_time) total_sr_response_time,
     AVG(bps.avg_closed_srs) pct_first_closed_srs, --note
     AVG(bps.avg_complaints) avg_complaints,
     AVG(bps.avg_hold_time) avg_hold_time,
     AVG(bps.avg_len_of_emp) avg_len_of_emp,
     AVG(bps.avg_transfers_per_sr) avg_transfers_per_sr,
     AVG(bps.avg_workload) avg_workload,
     SUM(bps.calls) tot_calls, --note
     AVG(bps.call_length) call_length,
     AVG(bps.profitability) profitability
     FROM bic_party_summ bps,
--      ams_dm_drv_stg    drv
        ams_dm_drv_stg_gt drv       -- nyostos - Sep 15, 2003 - Global Temp Table
   WHERE bps.period_start_date(+) > l_date - 365
   AND   bps.party_id(+)  = drv.party_id
   GROUP BY drv.party_id
   ;

   END IF;
   -------------------- finish --------------------------
   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Insert_BIC_Stg;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
END InsertBICStg;
-- End of staging Cust Intelligence data

-- End of all Staging PRocedures

PROCEDURE InsertPartyDetails(x_return_status OUT NOCOPY VARCHAR2)
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'InsertPartyDetails';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Insert_Party_Details;

   x_return_status := FND_API.g_ret_sts_success;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   ----------------------- Insert ----------------------
-- Move Data from Staging to Party Details (Insert Process)
   INSERT -- /*+ APPEND PARALLEL(AMS_DM_PARTY_DETAILS,DEFAULT,DEFAULT)*/
   INTO ams_dm_party_details (
     party_id,
     created_by,
     creation_date,
     last_updated_by,
     last_update_date,
     last_update_login,
     object_version_number,
     party_type,
     gender,
     ethnicity,
     marital_status,
     personal_income,
     hoh_flag,
     household_income,
     household_size,
     apartment_flag,
     rent_flag,
     degree_received,
     school_type,
     interest_art_flag,
     interest_books_flag,
     interest_movies_flag,
     interest_music_flag,
     interest_theater_flag,
     interest_travel_flag,
     interest_drink_flag,
     interest_smoke_flag,
     interest_other_flag,
     employed_flag,
     years_employed,
     occupation,
     military_branch,
     residence_type,
     resident_length,
     presence_of_children, -- num_of_children?
     country,
     state,
     province,
     county,
     zip_code,
     Reference_use_flag,
     gross_annual_income,
     debt_to_income_ratio,
     num_credit_lines,
     num_trade_lines,
     net_worth,
     total_assets,
     tot_debt_outstanding,
     bankruptcy_flag,
     high_risk_fraud_flag,
     gross_annual_sales,
     growth_rate_sales_year,
     growth_rate_net_prof_year,
     current_assets,
     current_liabilities,
     total_debts,
     net_profit,
     tangible_net_profit,
     capital_amount,
     capital_type_indicator,
     accounts_receivable,
     retained_earnings,
     paydex_score_year,
     paydex_score_3_month_ago,
     industry_paydex_median,
     global_failure_score,
     dnb_score,
     out_of_business_flag,
     customer_quality_rank,
     fortune_500_rank,
     num_of_employees,
     legal_status,
     year_established,
     sic_code1,
     minority_business_flag,
     small_business_flag,
     women_owned_bus_flag,
     gov_org_flag,
     hq_subsidiary_flag,
     foreign_owned_flag,
     import_export_bus_flag,
     credit_check_flag,
     tolerance,
     discount_terms_flag,
     dunning_letters_flag,
     interest_charges_flag,
     send_statements_flag,
--     send_credit_balance_flag,
     credit_hold_flag,
--     profile_class_code,
     credit_rating,
     risk_code,
--     standard_terms,
--     override_terms,
      interest_period_days,
      payment_grace_days,
      business_scope,
      email_address,
      address1,
      address2,
      competitor_flag,
      third_party_flag,
      person_first_name,
      person_middle_name,
      person_last_name,
      person_name_suffix,
      person_title,
      person_academic_title,
      person_pre_name_adjunct,
      control_yr,
      line_of_business,
      cong_dist_code,
      labor_surplus_flag,
      debarment_flag,
      disadv_8a_flag,
      debarments_count,
      months_since_last_debarment,
      gsa_indicator_flag,
      analysis_fy,
      fiscal_yearend_month,
      curr_fy_potential_revenue,
      next_fy_potential_revenue,
      organization_type,
      corporation_class,
      registration_type,
      incorp_year,
      public_private_ownership_flag,
      internal_flag,
      high_credit,
      avg_high_credit,
      total_payments,
      credit_score_class,
      credit_score_natl_percentile,
      credit_score_incd_default,
      credit_score_age,
      failure_score_class,
      failure_score_incd_default,
      failure_score_age,
      maximum_credit_recommendation,
      maximum_credit_currency_code,
      party_name,
      city
   )
   SELECT
     drv.party_id                     party_id,
     FND_GLOBAL.USER_ID               created_by,     ---------------> FND_GLOBAL
     SYSDATE                          creation_date,
     fnd_global.user_id               last_updated_by,
     SYSDATE                          last_update_date,
     fnd_global.conc_login_id         last_update_login,
     1                                object_version_number,
     gen.party_type                   party_type,  ---------------> 1-1
     gen.gender                       gender,
     gen.ethnicity                    ethnicity,
     gen.marital_status               marital_status,
     gen.personal_income              personal_income,
     gen.hoh_flag                     hoh_flag,
     gen.household_income             household_income,
     gen.household_size               household_size,
     gen.apartment_flag               apartment_flag,
     gen.rent_flag                    rent_flag,
     gen.degree_received              degree_received,
     gen.school_type                  school_type, ------------> 1-1
     int.interest_art_flag            interest_art_flag,
     int.interest_books_flag          interest_books_flag,
     int.interest_movies_flag         interest_movies_flag,
     int.interest_music_flag          interest_music_flag,
     int.interest_theater_flag        interest_theater_flag,
     int.interest_travel_flag         interest_travel_flag,
     int.interest_drink_flag          interest_drink_flag,
     int.interest_smoke_flag          interest_smoke_flag,
     int.interest_other_flag          interest_other_flag,  -- person_interest
     gen.employed_flag                employed_flag,       --------------------------1-
     gen.years_employed               years_employed,
     gen.occupation                   occupation,
     gen.military_branch              military_branch,
     gen.residence_type               residence_type,
     gen.resident_length              resident_length,
     gen.presence_of_children         presence_of_children, -- num_of_children?
     gen.country                      country,
     gen.state                        state,
     gen.province                     province,
     gen.county                       county,
     gen.zip_code                     zip_code,
     gen.reference_use_flag           Reference_use_flag, --------------------------1-1
     fin.gross_annual_income          gross_annual_income, ----------> Financial Number
     fin.debt_to_income_ratio         debt_to_income_ratio,
     fin.num_credit_lines             num_credit_lines,
     fin.num_trade_lines              num_trade_lines,
     fin.net_worth                    net_worth,
     fin.total_assets                 total_assets,
     fin.tot_debt_outstanding         tot_debt_outstanding,
     fin.bankruptcy_flag              bankruptcy_flag,
     fin.high_risk_fraud_flag         high_risk_fraud_flag,
     fin.gross_annual_sales           gross_annual_sales,
     fin.growth_rate_sales_year       growth_rate_sales_year,
     fin.growth_rate_net_prof_year    growth_rate_net_prof_year,
     fin.current_assets               current_assets,
     fin.current_liabilities          current_liabilities,
     fin.total_debts                  total_debts,
     fin.net_profit                   net_profit,
     fin.tangible_net_profit          tangible_net_profit,
     fin.capital_amount               capital_amount,
     fin.capital_type_indicator       capital_type_indicator,
     fin.accounts_receivable           accounts_receivable,
     fin.retained_earnings            retained_earnings,   ----------> Financial Number
     gen.paydex_score_year            paydex_score_year, -----------> 1-1
     gen.paydex_score_3_month_ago     paydex_score_3_month_ago,
     gen.industry_paydex_median       industry_paydex_median,
     gen.global_failure_score         global_failure_score,
     gen.dnb_score                    dnb_score,
     gen.out_of_business_flag         out_of_business_flag,
     gen.customer_quality_rank        customer_quality_rank,
     gen.fortune_500_rank             fortune_500_rank,
     gen.num_of_employees             num_of_employees,
     gen.legal_status                 legal_status,
     gen.year_established             year_established,
     gen.sic_code1                    sic_code1,
     gen.minority_business_flag       minority_business_flag,
     gen.small_business_flag          small_business_flag,
     gen.women_owned_bus_flag         women_owned_bus_flag,
     gen.gov_org_flag                 gov_org_flag,
     gen.hq_subsidiary_flag           hq_subsidiary_flag,
     gen.foreign_owned_flag           foreign_owned_flag,
     gen.import_export_bus_flag       import_export_bus_flag,
     ppf.credit_check_flag            credit_check_flag,
     ppf.tolerance                    tolerance,
     ppf.discount_terms_flag          discount_terms_flag,
     ppf.dunning_letters_flag         dunning_letters_flag,
     ppf.interest_charges_flag        interest_charges_flag,
     ppf.send_statements_flag         send_statements_flag,
--     ppf.send_credit_balance_flag     send_credit_balance_flag,
     ppf.credit_hold_flag             credit_hold_flag,
--     ppf.profile_class_code           profile_class_code,
     ppf.credit_rating                credit_rating,
     ppf.risk_code                    risk_code,
--     ppf.standard_terms               standard_terms,
--     ppf.override_terms               override_terms,
      ppf.interest_period_days         interest_period_days,
      ppf.payment_grace_days           payment_grace_days,
      gen.business_scope,
      gen.email_address,
      gen.address1,
      gen.address2,
      gen.competitor_flag,
      gen.third_party_flag,
      gen.person_first_name,
      gen.person_middle_name,
      gen.person_last_name,
      gen.person_name_suffix,
      gen.person_title,
      gen.person_academic_title,
      gen.person_pre_name_adjunct,
      gen.control_yr,
      gen.line_of_business,
      gen.cong_dist_code,
      gen.labor_surplus_flag,
      gen.debarment_flag,
      gen.disadv_8a_flag,
      gen.debarments_count,
      gen.months_since_last_debarment,
      gen.gsa_indicator_flag,
      gen.analysis_fy,
      gen.fiscal_yearend_month,
      gen.curr_fy_potential_revenue,
      gen.next_fy_potential_revenue,
      gen.organization_type,
      gen.corporation_class,
      gen.registration_type,
      gen.incorp_year,
      gen.public_private_ownership_flag,
      gen.internal_flag,
      gen.high_credit,
      gen.avg_high_credit,
      gen.total_payments,
      gen.credit_score_class,
      gen.credit_score_natl_percentile,
      gen.credit_score_incd_default,
      gen.credit_score_age,
      gen.failure_score_class,
      gen.failure_score_incd_default,
      gen.failure_score_age,
      gen.maximum_credit_recommendation,
      gen.maximum_credit_currency_code,
      gen.party_name,
      gen.city
   FROM
-- nyostos - Sep 15, 2003 - Use Global Temporary Tables
--   ams_dm_drv_stg drv,
--   ams_dm_gen_stg gen,
--   ams_dm_perint_stg int,
--   ams_dm_finnum_stg fin,
--   ams_dm_party_profile_stg ppf
     ams_dm_drv_stg_gt drv,
     ams_dm_gen_stg_gt gen,
     ams_dm_perint_stg_gt int,
     ams_dm_finnum_stg_gt fin,
     ams_dm_profile_stg_gt ppf
   WHERE
        drv.party_id  = gen.party_id (+)
   AND  drv.party_id  = int.party_id (+)
   AND  drv.party_id  = fin.party_id (+)
   AND  drv.party_id  = ppf.party_id (+)
     ;
/*   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name ('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
*/
   -------------------- finish --------------------------
   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Party_Details;

      x_return_status := FND_API.g_ret_sts_error;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
END InsertPartyDetails;
-- End of moving data from Staging to Party Details

PROCEDURE InsertPartyDetailsTime(x_return_status OUT NOCOPY VARCHAR2)
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'InsertPartyDetailsTime';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Insert_Party_Details_Time;

   x_return_status := FND_API.g_ret_sts_success;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   ----------------------- Insert ----------------------
-- Move Data from Staging to Party Details Time (Insert Process)

     INSERT -- /*+ APPEND PARALLEL(AMS_DM_PARTY_DETAILS_TIME,DEFAULT,DEFAULT)*/
     INTO ams_dm_party_details_time (
     party_id,
     created_by,
     creation_date,
     last_updated_by,
     last_update_date,
     last_update_login,
     object_version_number,
     age, ------------------------------ to be mapped into agg staging
     days_since_last_school,
     days_since_last_event,
     num_times_targeted,
     last_targeted_channel_code,
     times_targeted_month,
     times_targeted_3_months,
     times_targeted_6_months,
     times_targeted_12_months,
     days_since_last_targeted,
     avg_disc_offered,
     num_types_disc_offered,
     days_since_first_contact,
     days_since_acct_established,
     days_since_acct_term,
     days_since_acct_activation,
     days_since_acct_suspended,
     num_times_targeted_email,
     num_times_targeted_telemkt,
     num_times_targeted_direct,
     num_tgt_by_offr_typ1,
     num_tgt_by_offr_typ2,
     num_tgt_by_offr_typ3,
     num_tgt_by_offr_typ4, --------------------- agg
     avg_talk_time,   ------------------------------ bic
     avg_order_amount,
     avg_units_per_order,
     tot_order_amount_year,
     tot_order_amount_9_months,
     tot_order_amount_6_months,
     tot_order_amount_3_months,
     tot_num_orders_year,
     tot_num_order_9_months,
     tot_num_order_6_months,
     tot_num_order_3_months,
     num_of_sr_year,
     num_of_sr_6_months,
     num_of_sr_3_months,
     num_of_sr_1_month,
     avg_resolve_days_year,
     avg_resolve_days_6_months,
     avg_resolve_days_3_months,
     avg_resolve_days_1_month,
     order_lines_delivered,
     order_lines_ontime,
     order_qty_cumul,
     order_recency,
     payments,
     returns,
     return_by_value,
     return_by_value_pct,
     ontime_payments,
     ontime_ship_pct,
     closed_srs,
     COGS,
     contracts_cuml,
     contract_amt,
     contract_duration,
     inactive_contracts,
     open_contracts,
     new_contracts,
     renewed_contracts,
     escalated_srs,
     first_call_cl_rate,
     num_of_complaints,
     num_of_interactions,
     num_of_transfers,
     open_srs,
     pct_call_rework,
     products,
     referals,
     reopened_srs,
     sales,
     total_sr_response_time,
     pct_first_closed_srs,
     avg_complaints,
     avg_hold_time,
     avg_len_of_emp,
     avg_transfers_per_sr,
     avg_workload,
     tot_calls,
     call_length,
     profitability)
     SELECT
     drv.party_id                        party_id,
     FND_GLOBAL.USER_ID                  created_by,
     SYSDATE                             creation_date,
     fnd_global.user_id                  last_updated_by,
     SYSDATE                             last_update_date,
     fnd_global.conc_login_id            last_update_login,
     1                                   object_version_number,
     agg.age                             age, --------------- to be mapped
     agg.days_since_last_school days_since_last_school,
     agg.days_since_last_event           days_since_last_event,
     agg.num_times_targeted              num_times_targeted,
     agg.last_targeted_channel_code      last_targeted_channel_code,
     agg.times_targeted_month            times_targeted_month,
     agg.times_targeted_3_months         times_targeted_3_months,
     agg.times_targeted_6_months         times_targeted_6_months,
     agg.times_targeted_12_months        times_targeted_12_months,
     agg.days_since_last_targeted        days_since_last_targeted,
     agg.avg_disc_offered                avg_disc_offered,
     agg.num_types_disc_offered          num_types_disc_offered,
     agg.days_since_first_contact        days_since_first_contact,
     agg.days_since_acct_established     days_since_acct_established,
     agg.days_since_acct_term            days_since_acct_term,
     agg.days_since_acct_activation      days_since_acct_activation,
     agg.days_since_acct_suspended       days_since_acct_suspended,
     agg.num_times_targeted_email        num_times_targeted_email,
     agg.num_times_targeted_telemkt      num_times_targeted_telemkt,
     agg.num_times_targeted_direct       num_times_targeted_direct  ,
     agg.num_tgt_by_offr_typ1     num_tgt_by_offr_typ1,
     agg.num_tgt_by_offr_typ2     num_tgt_by_offr_typ2,
     agg.num_tgt_by_offr_typ3     num_tgt_by_offr_typ3,
     agg.num_tgt_by_offr_typ4     num_tgt_by_offr_typ4, -------- agg
     bic.avg_talk_time                   avg_talk_time,   ---------------- bic
     bic.avg_order_amount                avg_order_amount,
     bic.avg_units_per_order             avg_units_per_order,
     bic.tot_order_amount_year           tot_order_amount_year,
     bic.tot_order_amount_9_months       tot_order_amount_9_months,
     bic.tot_order_amount_6_months       tot_order_amount_6_months,
     bic.tot_order_amount_3_months       tot_order_amount_3_months,
     bic.tot_num_orders_year             tot_num_orders_year,
     bic.tot_num_order_9_months          tot_num_order_9_months,
     bic.tot_num_order_6_months          tot_num_order_6_months,
     bic.tot_num_order_3_months          tot_num_order_3_months,
     bic.num_of_sr_year                  num_of_sr_year,
     bic.num_of_sr_6_months              num_of_sr_6_months,
     bic.num_of_sr_3_months              num_of_sr_3_months,
     bic.num_of_sr_1_month               num_of_sr_1_month,
     bic.avg_resolve_days_year           avg_resolve_days_year,
     bic.avg_resolve_days_6_months       avg_resolve_days_6_months,
     bic.avg_resolve_days_3_months       avg_resolve_days_3_months,
     bic.avg_resolve_days_1_month        avg_resolve_days_1_month,
     bic.order_lines_delivered           order_lines_delivered,
     bic.order_lines_ontime              order_lines_ontime,
     bic.order_qty_cumul                 order_qty_cumul,
     bic.order_recency                   order_recency,
     bic.payments                        payments,
     bic.returns                         returns,
     bic.return_by_value                 return_by_value,
     bic.return_by_value_pct             return_by_value_pct,
     bic.ontime_payments                 ontime_payments,
     bic.ontime_ship_pct                 ontime_ship_pct,
     bic.closed_srs                      closed_srs,
     bic.COGS                            COGS,
     bic.contracts_cuml                  contracts_cuml,
     bic.contract_amt                    contract_amt,
     bic.contract_duration               contract_duration,
     bic.inactive_contracts              inactive_contracts,
     bic.open_contracts                  open_contracts,
     bic.new_contracts                   new_contracts,
     bic.renewed_contracts               renewed_contracts,
     bic.escalated_srs                   escalated_srs,
     bic.first_call_cl_rate              first_call_cl_rate,
     bic.num_of_complaints               num_of_complaints,
     bic.num_of_interactions             num_of_interactions,
     bic.num_of_transfers                num_of_transfers,
     bic.open_srs                        open_srs,
     bic.pct_call_rework                 pct_call_rework,
     bic.products                        products,
     bic.referals                        referals,
     bic.reopened_srs                    reopened_srs,
     bic.sales                           sales,
     bic.total_sr_response_time          total_sr_response_time,
     bic.pct_first_closed_srs            pct_first_closed_srs,
     bic.avg_complaints                  avg_complaints,
     bic.avg_hold_time                   avg_hold_time,
     bic.avg_len_of_emp                  avg_len_of_emp,
     bic.avg_transfers_per_sr            avg_transfers_per_sr,
     bic.avg_workload                    avg_workload,
     bic.tot_calls                       tot_calls,
     bic.call_length                     call_length,
     bic.profitability                   profitability
     FROM
-- nyostos - Sep 15, 2003 - Global Temp Tables
--   ams_dm_drv_stg drv,
--   ams_dm_agg_stg agg,
--   ams_dm_bic_stg bic
     ams_dm_drv_stg_gt drv,
     ams_dm_agg_stg_gt agg,
     ams_dm_bic_stg_gt bic
     WHERE drv.party_id = agg.party_id (+)
     AND   drv.party_id = bic.party_id (+)
     ;
   -------------------- finish --------------------------
   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Party_Details_Time;

      x_return_status := FND_API.g_ret_sts_error;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
END InsertPartyDetailsTime;
-- End of moving data from Staging to Party Details

PROCEDURE UpdatePartyDetails
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'UpdatePartyDetails';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_Party_Details;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   ----------------------- Update ----------------------
     -- Update Party Details with changed data from Staging Area
     UPDATE /*+ PARALLEL(AMS_DM_PARTY_DETAILS)*/
     ams_dm_party_details pdt  SET (
     last_updated_by,
     last_update_date,
     last_update_login,
     gender,
     ethnicity,
     marital_status,
     personal_income,
     hoh_flag,
     household_income,
     household_size,
     apartment_flag,
     rent_flag,
     degree_received,
     school_type,
     interest_art_flag,
     interest_books_flag,
     interest_movies_flag,
     interest_music_flag,
     interest_theater_flag,
     interest_travel_flag,
     interest_drink_flag,
     interest_smoke_flag,
     interest_other_flag,
     employed_flag,
     years_employed,
     occupation,
     military_branch,
     residence_type,
     resident_length,
     presence_of_children,
     country,
     state,
     province,
     county,
     zip_code,
     Reference_use_flag,
     gross_annual_income,
     debt_to_income_ratio,
     num_credit_lines,
     num_trade_lines,
     net_worth,
     total_assets,
     tot_debt_outstanding,
     bankruptcy_flag,
     high_risk_fraud_flag,
     gross_annual_sales,
     growth_rate_sales_year,
     growth_rate_net_prof_year,
     current_assets,
     current_liabilities,
     total_debts,
     net_profit,
     tangible_net_profit,
     capital_amount,
     capital_type_indicator,
     accounts_receivable,
     retained_earnings,
     paydex_score_year,
     paydex_score_3_month_ago,
     industry_paydex_median,
     global_failure_score,
     dnb_score,
     out_of_business_flag,
     customer_quality_rank,
     fortune_500_rank,
     num_of_employees,
     legal_status,
     year_established,
     sic_code1,
     minority_business_flag,
     small_business_flag,
     women_owned_bus_flag,
     gov_org_flag,
     hq_subsidiary_flag,
     foreign_owned_flag,
     import_export_bus_flag,
     credit_check_flag,
     tolerance,
     discount_terms_flag,
     dunning_letters_flag,
     interest_charges_flag,
     send_statements_flag,
     credit_hold_flag,
     credit_rating,
     risk_code,
     interest_period_days,
     payment_grace_days
     ) = ( SELECT
     fnd_global.user_id               last_updated_by,
     SYSDATE                          last_update_date,
     fnd_global.conc_login_id         last_update_login,
     gen.gender                       gender,
     gen.ethnicity                    ethnicity,
     gen.marital_status               marital_status,
     gen.personal_income              personal_income,
     gen.hoh_flag                     hoh_flag,
     gen.household_income             household_income,
     gen.household_size               household_size,
     gen.apartment_flag               apartment_flag,
     gen.rent_flag                    rent_flag,
     gen.degree_received              degree_received,
     gen.school_type                  school_type,
     int.interest_art_flag            interest_art_flag,
     int.interest_books_flag          interest_books_flag,
     int.interest_movies_flag         interest_movies_flag,
     int.interest_music_flag          interest_music_flag,
     int.interest_theater_flag        interest_theater_flag,
     int.interest_travel_flag         interest_travel_flag,
     int.interest_drink_flag          interest_drink_flag,
     int.interest_smoke_flag          interest_smoke_flag,
     int.interest_other_flag          interest_other_flag,
     gen.employed_flag                employed_flag,
     gen.years_employed               years_employed,
     gen.occupation                   occupation,
     gen.military_branch              military_branch,
     gen.residence_type               residence_type,
     gen.resident_length              resident_length,
     gen.presence_of_children         presence_of_children,
     gen.country                      country,
     gen.state                        state,
     gen.province                     province,
     gen.county                       county,
     gen.zip_code                     zip_code,
     gen.reference_use_flag           Reference_use_flag,
     fin.gross_annual_income          gross_annual_income,
     fin.debt_to_income_ratio         debt_to_income_ratio,
     fin.num_credit_lines             num_credit_lines,
     fin.num_trade_lines              num_trade_lines,
     fin.net_worth                    net_worth,
     fin.total_assets                 total_assets,
     fin.tot_debt_outstanding         tot_debt_outstanding,
     fin.bankruptcy_flag              bankruptcy_flag,
     fin.high_risk_fraud_flag         high_risk_fraud_flag,
     fin.gross_annual_sales           gross_annual_sales,
     fin.growth_rate_sales_year       growth_rate_sales_year,
     fin.growth_rate_net_prof_year    growth_rate_net_prof_year,
     fin.current_assets               current_assets,
     fin.current_liabilities          current_liabilities,
     fin.total_debts                  total_debts,
     fin.net_profit                   net_profit,
     fin.tangible_net_profit          tangible_net_profit,
     fin.capital_amount               capital_amount,
     fin.capital_type_indicator       capital_type_indicator,
     fin.accounts_receivable           accounts_receivable,
     fin.retained_earnings            retained_earnings,
     gen.paydex_score_year            paydex_score_year,
     gen.paydex_score_3_month_ago     paydex_score_3_month_ago,
     gen.industry_paydex_median       industry_paydex_median,
     gen.global_failure_score         global_failure_score,
     gen.dnb_score                    dnb_score,
     gen.out_of_business_flag         out_of_business_flag,
     gen.customer_quality_rank        customer_quality_rank,
     gen.fortune_500_rank             fortune_500_rank,
     gen.num_of_employees             num_of_employees,
     gen.legal_status                 legal_status,
     gen.year_established             year_established,
     gen.sic_code1                    sic_code1,
     gen.minority_business_flag       minority_business_flag,
     gen.small_business_flag          small_business_flag,
     gen.women_owned_bus_flag         women_owned_bus_flag,
     gen.gov_org_flag                 gov_org_flag,
     gen.hq_subsidiary_flag           hq_subsidiary_flag,
     gen.foreign_owned_flag           foreign_owned_flag,
     gen.import_export_bus_flag       import_export_bus_flag,
     ppf.credit_check_flag            credit_check_flag,
     ppf.tolerance                    tolerance,
     ppf.discount_terms_flag          discount_terms_flag,
     ppf.dunning_letters_flag         dunning_letters_flag,
     ppf.interest_charges_flag        interest_charges_flag,
     ppf.send_statements_flag         send_statements_flag,
     ppf.credit_hold_flag             credit_hold_flag,
     ppf.credit_rating                credit_rating,
     ppf.risk_code                    risk_code,
     ppf.interest_period_days         interest_period_days,
     ppf.payment_grace_days           payment_grace_days
     FROM
     ams_dm_drv_stg_gt drv,
     ams_dm_gen_stg_gt gen,
     ams_dm_perint_stg_gt int,
     ams_dm_finnum_stg_gt fin,
     ams_dm_profile_stg_gt ppf
     WHERE
          drv.party_id  = pdt.party_id
     AND  drv.party_id  = gen.party_id (+)
     AND  drv.party_id  = int.party_id (+)
     AND  drv.party_id  = fin.party_id (+)
     AND  drv.party_id  = ppf.party_id (+)
     )
    WHERE pdt.party_id IN (SELECT /*+ INDEX_FFS(AMS_DM_DRV_STG_GT_U1)*/ party_id FROM ams_dm_drv_stg_gt)
     ;

   -------------------- finish --------------------------
   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Update_Party_Details;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      RAISE FND_API.g_exc_unexpected_error;

END UpdatePartyDetails;
-- End of Updating Party Details

PROCEDURE UpdatePartyDetailsTime
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'UpdatePartyDetailsTime';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Update_Party_Details_Time;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   ----------------------- Insert ----------------------
-- Update Party Details Time with changed data from Staging Area

     UPDATE /*+ PARALLEL(AMS_DM_PARTY_DETAILS_TIME)*/
     ams_dm_party_details_time pdtt  SET (
     last_updated_by,
     last_update_date,
     last_update_login,
     age,
     days_since_last_school,
     days_since_last_event,
     num_times_targeted,
     last_targeted_channel_code,
     times_targeted_month,
     times_targeted_3_months,
     times_targeted_6_months,
     times_targeted_12_months,
     days_since_last_targeted,
     avg_disc_offered,
     num_types_disc_offered,
     days_since_first_contact,
     days_since_acct_established,
     days_since_acct_term,
     days_since_acct_activation,
     days_since_acct_suspended,
     num_times_targeted_email,
     num_times_targeted_telemkt,
     num_times_targeted_direct,
     num_tgt_by_offr_typ1,
     num_tgt_by_offr_typ2,
     num_tgt_by_offr_typ3,
     num_tgt_by_offr_typ4,
     avg_talk_time,
     avg_order_amount,
     avg_units_per_order,
     tot_order_amount_year,
     tot_order_amount_9_months,
     tot_order_amount_6_months,
     tot_order_amount_3_months,
     tot_num_orders_year,
     tot_num_order_9_months,
     tot_num_order_6_months,
     tot_num_order_3_months,
     num_of_sr_year,
     num_of_sr_6_months,
     num_of_sr_3_months,
     num_of_sr_1_month,
     avg_resolve_days_year,
     avg_resolve_days_6_months,
     avg_resolve_days_3_months,
     avg_resolve_days_1_month,
     order_lines_delivered,
     order_lines_ontime,
     order_qty_cumul,
     order_recency,
     payments,
     returns,
     return_by_value,
     return_by_value_pct,
     ontime_payments,
     ontime_ship_pct,
     closed_srs,
     COGS,
     contracts_cuml,
     contract_amt,
     contract_duration,
     inactive_contracts,
     open_contracts,
     new_contracts,
     renewed_contracts,
     escalated_srs,
     first_call_cl_rate,
     num_of_complaints,
     num_of_interactions,
     num_of_transfers,
     open_srs,
     pct_call_rework,
     products,
     referals,
     reopened_srs,
     sales,
     total_sr_response_time,
     pct_first_closed_srs,
     avg_complaints,
     avg_hold_time,
     avg_len_of_emp,
     avg_transfers_per_sr,
     avg_workload,
     tot_calls,
     call_length,
     profitability
     ) = ( SELECT
     fnd_global.user_id                  last_updated_by,
     SYSDATE                             last_update_date,
     fnd_global.conc_login_id            last_update_login,
     agg.age                             age,
     agg.days_since_last_school days_since_last_school,
     agg.days_since_last_event           days_since_last_event,
     agg.num_times_targeted              num_times_targeted,
     agg.last_targeted_channel_code      last_targeted_channel_code,
     agg.times_targeted_month            times_targeted_month,
     agg.times_targeted_3_months         times_targeted_3_months,
     agg.times_targeted_6_months         times_targeted_6_months,
     agg.times_targeted_12_months        times_targeted_12_months,
     agg.days_since_last_targeted        days_since_last_targeted,
     agg.avg_disc_offered                avg_disc_offered,
     agg.num_types_disc_offered          num_types_disc_offered,
     agg.days_since_first_contact        days_since_first_contact,
     agg.days_since_acct_established     days_since_acct_established,
     agg.days_since_acct_term            days_since_acct_term,
     agg.days_since_acct_activation      days_since_acct_activation,
     agg.days_since_acct_suspended       days_since_acct_suspended,
     agg.num_times_targeted_email        num_times_targeted_email,
     agg.num_times_targeted_telemkt      num_times_targeted_telemkt,
     agg.num_times_targeted_direct       num_times_targeted_direct  ,
     agg.num_tgt_by_offr_typ1            num_tgt_by_offr_typ1,
     agg.num_tgt_by_offr_typ2            num_tgt_by_offr_typ2,
     agg.num_tgt_by_offr_typ3            num_tgt_by_offr_typ3,
     agg.num_tgt_by_offr_typ4            num_tgt_by_offr_typ4,
     bic.avg_talk_time                   avg_talk_time,
     bic.avg_order_amount                avg_order_amount,
     bic.avg_units_per_order             avg_units_per_order,
     bic.tot_order_amount_year           tot_order_amount_year,
     bic.tot_order_amount_9_months       tot_order_amount_9_months,
     bic.tot_order_amount_6_months       tot_order_amount_6_months,
     bic.tot_order_amount_3_months       tot_order_amount_3_months,
     bic.tot_num_orders_year             tot_num_orders_year,
     bic.tot_num_order_9_months          tot_num_order_9_months,
     bic.tot_num_order_6_months          tot_num_order_6_months,
     bic.tot_num_order_3_months          tot_num_order_3_months,
     bic.num_of_sr_year                  num_of_sr_year,
     bic.num_of_sr_6_months              num_of_sr_6_months,
     bic.num_of_sr_3_months              num_of_sr_3_months,
     bic.num_of_sr_1_month               num_of_sr_1_month,
     bic.avg_resolve_days_year           avg_resolve_days_year,
     bic.avg_resolve_days_6_months       avg_resolve_days_6_months,
     bic.avg_resolve_days_3_months       avg_resolve_days_3_months,
     bic.avg_resolve_days_1_month        avg_resolve_days_1_month,
     bic.order_lines_delivered           order_lines_delivered,
     bic.order_lines_ontime              order_lines_ontime,
     bic.order_qty_cumul                 order_qty_cumul,
     bic.order_recency                   order_recency,
     bic.payments                        payments,
     bic.returns                         returns,
     bic.return_by_value                 return_by_value,
     bic.return_by_value_pct             return_by_value_pct,
     bic.ontime_payments                 ontime_payments,
     bic.ontime_ship_pct                 ontime_ship_pct,
     bic.closed_srs                      closed_srs,
     bic.COGS                            COGS,
     bic.contracts_cuml                  contracts_cuml,
     bic.contract_amt                    contract_amt,
     bic.contract_duration               contract_duration,
     bic.inactive_contracts              inactive_contracts,
     bic.open_contracts                  open_contracts,
     bic.new_contracts                   new_contracts,
     bic.renewed_contracts               renewed_contracts,
     bic.escalated_srs                   escalated_srs,
     bic.first_call_cl_rate              first_call_cl_rate,
     bic.num_of_complaints               num_of_complaints,
     bic.num_of_interactions             num_of_interactions,
     bic.num_of_transfers                num_of_transfers,
     bic.open_srs                        open_srs,
     bic.pct_call_rework                 pct_call_rework,
     bic.products                        products,
     bic.referals                        referals,
     bic.reopened_srs                    reopened_srs,
     bic.sales                           sales,
     bic.total_sr_response_time          total_sr_response_time,
     bic.pct_first_closed_srs            pct_first_closed_srs,
     bic.avg_complaints                  avg_complaints,
     bic.avg_hold_time                   avg_hold_time,
     bic.avg_len_of_emp                  avg_len_of_emp,
     bic.avg_transfers_per_sr            avg_transfers_per_sr,
     bic.avg_workload                    avg_workload,
     bic.tot_calls                       tot_calls,
     bic.call_length                     call_length,
     bic.profitability                   profitability
     FROM
     ams_dm_drv_stg_gt drv,
     ams_dm_agg_stg_gt agg,
     ams_dm_bic_stg_gt bic
     WHERE drv.party_id = pdtt.party_id
     AND   drv.party_id = agg.party_id (+)
     AND   drv.party_id = bic.party_id (+)
     )
     WHERE pdtt.party_id IN (SELECT /*+ INDEX_FFS(AMS_DM_DRV_STG_GT_U1)*/ party_id FROM ams_dm_drv_stg_gt)
;

   -------------------- finish --------------------------
   COMMIT;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO Update_Party_Details_Time;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      RAISE FND_API.g_exc_unexpected_error;

END UpdatePartyDetailsTime;
-- End of Updating Party Details Time

PROCEDURE ExtractMain (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_job IN VARCHAR2 DEFAULT 'NULL',
   p_mode IN VARCHAR2,
   p_model_id IN NUMBER DEFAULT NULL,
   p_model_type IN VARCHAR2 DEFAULT 'NULL'
)
  IS
-- This is the main driving procedure for the extraction process. It calls all
-- the other procedures as required.
-- p_mode: Parameter specifying whether this is an Insert or an Update process
--         Values: 'I' --> Insert Process
--                 'U' --> Update Process
-- (the following are valid only if p_mode is 'I')
-- p_model_id: Model ID for the data mining model to be built or scored
-- p_model_type: Whether this extraction process is for model building ('MODL')
--               or scoring the model ('SCOR')
--

   --kbasavar 8/4/2003
   CURSOR c_model_type(p_model_id IN NUMBER) is
      SELECT model_type
      FROM ams_dm_models_vl
      WHERE model_id=p_model_id
      ;

 -- kbasavar 12/29/2003 get model_id if it is Score
   CURSOR c_model_id (p_score_id IN NUMBER) IS
         SELECT model_id
         FROM   ams_dm_scores_all_b
         WHERE  score_id = p_score_id
    ;

   l_api_version  CONSTANT NUMBER := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'ExtractMain';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
   l_return_status   VARCHAR2(1);

   l_mode         VARCHAR2(1);
   l_object_id    NUMBER ;
   l_object_type  VARCHAR2(30);
   l_is_b2b        BOOLEAN;

   l_model_type    VARCHAR2(30);
   l_is_org_prod   BOOLEAN;
   l_model_id      NUMBER;
   l_party_type   VARCHAR2(30);
   l_index    NUMBER;
BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Extract_Main;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   -- truncate staging tables
   TruncateStgTables;

   l_mode := p_mode;
   l_object_id := p_model_id;
   l_object_type := p_model_type;

   IF l_object_type = 'SCOR' THEN
      OPEN c_model_id(l_object_id);
      FETCH c_model_id INTO l_model_id;
      CLOSE c_model_id;
   ELSE
      l_model_id := l_object_id;
   END IF;


   AMS_DMSelection_PVT.is_org_prod_affn(
      p_model_id => l_model_id,
      x_is_org_prod     => l_is_org_prod
   );

   AMS_DMSelection_PVT.is_b2b_data_source(
      p_model_id => l_model_id,
      x_is_b2b     => l_is_b2b
   );

   OPEN c_model_type(l_model_id);
   FETCH c_model_type into l_model_type;
   CLOSE c_model_type;

   IF l_mode = 'I' THEN  -- insert mode
      -- insert new records into driving table
      InsertDrvStgIns (
         p_object_id    => l_object_id,
         p_object_type  => l_object_type,
         x_return_status   => x_return_status
      );

      IF x_return_status <> FND_API.g_ret_sts_success THEN
          RAISE FND_API.g_exc_error;
      END IF;

      -- load into staging tables
      InsertGenStg (
        p_is_b2b => l_is_b2b,
	p_model_type => l_model_type,
	p_is_org_prod => l_is_org_prod
      );
      InsertExpStg(
        p_is_b2b => l_is_b2b,
	p_model_type => l_model_type,
	p_is_org_prod => l_is_org_prod
      );

      IF l_is_b2b AND ( l_model_type='CUSTOMER_PROFITABILITY' OR l_is_org_prod)THEN
         InsertAggStgOrg;
      ELSE
         InsertAggStg(
            p_is_b2b => l_is_b2b
         );
      END IF;

      InsertBICStg(
        p_is_b2b => l_is_b2b,
        p_model_type => l_model_type,
	p_is_org_prod => l_is_org_prod
      );

      -- load into targets
      InsertPartyDetails(x_return_status);

      IF x_return_status <> FND_API.g_ret_sts_success THEN
         RAISE FND_API.g_exc_error;
      END IF;

      InsertPartyDetailsTime(x_return_status);

      IF x_return_status <> FND_API.g_ret_sts_success THEN
         -- kbasavar migrated chi's changes for bug 3089951
         sync_party_tables;
         RAISE FND_API.g_exc_error;
      END IF;

   /*
      The extraction process is driven by various criteria like if its a B2B model or is it a customer profitability etc.
      If the mode is update then the model id will be null and hence l_is_b2b and the model type will have invalid values.
      In order to tackle this situation, if the mode is update, perform the extraction process separately for each party type.
      In future if there is any new party_type introduced then it should be handled explicitly.
   */
   ELSIF l_mode = G_MODE_UPDATE THEN -- update mode
      -- insert changed records into driving table

      FOR l_index IN 1..3 LOOP
         IF l_index = 1 then
            l_party_type := 'ORGANIZATION';
            l_is_b2b := TRUE ;
            l_model_type := 'CUSTOMER_PROFITABILITY';
            l_is_org_prod := FALSE;
         ELSIF l_index = 2 THEN
            l_party_type := 'PARTY_RELATIONSHIP';
            l_is_b2b := TRUE;
            l_model_type := 'EMAIL';
            l_is_org_prod := FALSE;
         ELSE
            l_party_type := 'PERSON';
            l_is_b2b := FALSE;
            l_model_type := 'EMAIL';
            l_is_org_prod := FALSE;
         END IF;

         AMS_Utility_PVT.create_log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'MODL',
            p_log_used_by_id  => -1,   -- party update is for all of party details, so no specific id
            p_msg_data        =>l_full_name ||  '::' || l_party_type,
            p_msg_type        => ''
         );

         InsertDrvStgUpd(
            p_party_type => l_party_type,
            x_return_status => x_return_status
         );

         IF x_return_status <> FND_API.g_ret_sts_success THEN
            RAISE FND_API.g_exc_error;
         END IF;

      -- insert into staging tables
         InsertGenStg (
           p_is_b2b => l_is_b2b,
           p_model_type => l_model_type,
           p_is_org_prod => l_is_org_prod
         );
         InsertExpStg(
            p_is_b2b => l_is_b2b,
            p_model_type => l_model_type,
            p_is_org_prod => l_is_org_prod
         );

         IF l_is_b2b AND ( l_model_type='CUSTOMER_PROFITABILITY' OR l_is_org_prod) THEN
            InsertAggStgOrg;
         ELSE
            InsertAggStg(
               p_is_b2b => l_is_b2b
            );
         END IF;


         InsertBICStg(
            p_is_b2b => l_is_b2b,
            p_model_type => l_model_type,
            p_is_org_prod => l_is_org_prod
         );

         -- load into targets
         UpdatePartyDetails;
         UpdatePartyDetailsTime;

         TruncateTable ('AMS_DM_DRV_STG_GT');

      END LOOP;

   END IF;

--   analyze_mining_tables;

     -------------------- finish --------------------------
   IF FND_API.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message (l_full_name || ': End');
   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Extract_Main;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Extract_Main;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Extract_Main;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END ExtractMain;
-- End of Main Extract Procedure


-- History
-- 06-Mar-2001 choang   Created.
--
PROCEDURE schedule_update_parties (
   errbuf   OUT NOCOPY VARCHAR2,
   retcode  OUT NOCOPY VARCHAR2
)
IS
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(4000);
BEGIN
   retcode := 0;

   ExtractMain (
      p_api_version     => 1.0,
      p_init_msg_list   => FND_API.G_TRUE,
      p_commit          => FND_API.G_TRUE,

      x_return_status   => l_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      p_mode            => G_MODE_UPDATE
   );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FOR i IN 1 .. l_msg_count LOOP
         AMS_Utility_PVT.create_log (
            x_return_status   => l_return_status,
            p_arc_log_used_by => 'MODL',
            p_log_used_by_id  => -1,   -- party update is for all of party details, so no specific id
            p_msg_data        => FND_MSG_PUB.get(i, FND_API.g_false),
            p_msg_type        => 'ERROR'
         );
      END LOOP;
      retcode := 2;
   END IF;
END schedule_update_parties;


PROCEDURE analyze_mining_tables
IS
   -- for table analyzing
   l_result          BOOLEAN;
   l_status          VARCHAR2(10);
   l_industry        VARCHAR2(10);
   l_ams_schema      VARCHAR2(30);
BEGIN
   -- gather table statistics
   -- this is needed for the ODM build
   -- process to complete successfully
   l_result := fnd_installation.get_app_info(
                  'AMS',
                  l_status,
                  l_industry,
                  l_ams_schema
               );

   DBMS_STATS.gather_table_stats (
      ownname           => l_ams_schema,
      tabname           => 'AMS_DM_PARTY_DETAILS',
      estimate_percent  => 99,
      cascade           => TRUE
   );

   DBMS_STATS.gather_table_stats (
      ownname           => l_ams_schema,
      tabname           => 'AMS_DM_PARTY_DETAILS_TIME',
      estimate_percent  => 99,
      cascade           => TRUE
   );

   DBMS_STATS.gather_table_stats (
      ownname           => l_ams_schema,
      tabname           => 'AMS_DM_SOURCE',
      estimate_percent  => 99,
      cascade           => TRUE
   );
END analyze_mining_tables;

--
-- PROCEDURE
--    sync_party_tables
--
-- DESCRIPTION
--    Synchronizes the party records of ams_dm_party_details
--    and ams_dm_party_details_time by deleting from party
--    details.  This procedure is meant to be called if the
--    insert for party details time fails.
--
-- HISTORY
-- 08-aug-2003 choang   Created for bug 3089951
-- 10-Sep-2003 kbasavar migrated to mainline
PROCEDURE sync_party_tables
IS
BEGIN
   DELETE FROM ams_dm_party_details d
   WHERE NOT EXISTS (SELECT 1 FROM ams_dm_party_details_time t
                     WHERE t.party_id = d.party_id)
   ;
END;


END ams_DMExtract_pvt ; -- END OF PACKAGE BODY

/
