--------------------------------------------------------
--  DDL for Package Body HZ_CREDIT_RATINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CREDIT_RATINGS_PKG" as
/* $Header: ARHPCRTB.pls 120.11 2005/10/30 04:21:33 appldev ship $ */

g_miss_content_source_type              CONSTANT VARCHAR2(30) := 'USER_ENTERED';

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_credit_rating_id                      IN OUT NOCOPY NUMBER,
    x_description                           IN     VARCHAR2,
    x_party_id                              IN     NUMBER,
    x_rating                                IN     VARCHAR2,
    x_rated_as_of_date                      IN     DATE,
    x_rating_organization                   IN     VARCHAR2,
    x_comments                              IN     VARCHAR2,
    x_det_history_ind                       IN     VARCHAR2,
    x_fincl_embt_ind                        IN     VARCHAR2,
    x_criminal_proceeding_ind               IN     VARCHAR2,
    x_suit_judge_ind                        IN     VARCHAR2,
    x_claims_ind                            IN     VARCHAR2,
    x_secured_flng_ind                      IN     VARCHAR2,
    x_fincl_lgl_event_ind                   IN     VARCHAR2,
    x_disaster_ind                          IN     VARCHAR2,
    x_oprg_spec_evnt_ind                    IN     VARCHAR2,
    x_other_spec_evnt_ind                   IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_avg_high_credit                       IN     NUMBER,
    x_credit_score                          IN     VARCHAR2,
    x_credit_score_age                      IN     NUMBER,
    x_credit_score_class                    IN     NUMBER,
    x_credit_score_commentary               IN     VARCHAR2,
    x_credit_score_commentary2              IN     VARCHAR2,
    x_credit_score_commentary3              IN     VARCHAR2,
    x_credit_score_commentary4              IN     VARCHAR2,
    x_credit_score_commentary5              IN     VARCHAR2,
    x_credit_score_commentary6              IN     VARCHAR2,
    x_credit_score_commentary7              IN     VARCHAR2,
    x_credit_score_commentary8              IN     VARCHAR2,
    x_credit_score_commentary9              IN     VARCHAR2,
    x_credit_score_commentary10             IN     VARCHAR2,
    x_credit_score_date                     IN     DATE,
    x_credit_score_incd_default             IN     NUMBER,
    x_credit_score_natl_percentile          IN     NUMBER,
    x_debarment_ind                         IN     VARCHAR2,
    x_debarments_count                      IN     NUMBER,
    x_debarments_date                       IN     DATE,
    x_high_credit                           IN     NUMBER,
    x_maximum_credit_currency_code          IN     VARCHAR2,
    x_maximum_credit_rcmd                   IN     NUMBER,
    x_paydex_norm                           IN     VARCHAR2,
    x_paydex_score                          IN     VARCHAR2,
    x_paydex_three_months_ago               IN     VARCHAR2,
    x_credit_score_override_code            IN     VARCHAR2,
    x_cr_scr_clas_expl                      IN     VARCHAR2,
    x_low_rng_delq_scr                      IN     NUMBER,
    x_high_rng_delq_scr                     IN     NUMBER,
    x_delq_pmt_rng_prcnt                    IN     NUMBER,
    x_delq_pmt_pctg_for_all_firms           IN     NUMBER,
    x_num_trade_experiences                 IN     NUMBER,
    x_paydex_firm_days                      IN     VARCHAR2,
    x_paydex_firm_comment                   IN     VARCHAR2,
    x_paydex_industry_days                  IN     VARCHAR2,
    x_paydex_industry_comment               IN     VARCHAR2,
    x_paydex_comment                        IN     VARCHAR2,
    x_suit_ind                              IN     VARCHAR2,
    x_lien_ind                              IN     VARCHAR2,
    x_judgement_ind                         IN     VARCHAR2,
    x_bankruptcy_ind                        IN     VARCHAR2,
    x_no_trade_ind                          IN     VARCHAR2,
    x_prnt_hq_bkcy_ind                      IN     VARCHAR2,
    x_num_prnt_bkcy_filing                  IN     NUMBER,
    x_prnt_bkcy_filg_type                   IN     VARCHAR2,
    x_prnt_bkcy_filg_chapter                IN     NUMBER,
    x_prnt_bkcy_filg_date                   IN     DATE,
    x_num_prnt_bkcy_convs                   IN     NUMBER,
    x_prnt_bkcy_conv_date                   IN     DATE,
    x_prnt_bkcy_chapter_conv                IN     VARCHAR2,
    x_slow_trade_expl                       IN     VARCHAR2,
    x_negv_pmt_expl                         IN     VARCHAR2,
    x_pub_rec_expl                          IN     VARCHAR2,
    x_business_discontinued                 IN     VARCHAR2,
    x_spcl_event_comment                    IN     VARCHAR2,
    x_num_spcl_event                        IN     NUMBER,
    x_spcl_event_update_date                IN     DATE,
    x_spcl_evnt_txt                         IN     VARCHAR2,
    x_failure_score                         IN     VARCHAR2,
    x_failure_score_age                     IN     NUMBER,
    x_failure_score_class                   IN     NUMBER,
    x_failure_score_commentary              IN     VARCHAR2,
    x_failure_score_commentary2             IN     VARCHAR2,
    x_failure_score_commentary3             IN     VARCHAR2,
    x_failure_score_commentary4             IN     VARCHAR2,
    x_failure_score_commentary5             IN     VARCHAR2,
    x_failure_score_commentary6             IN     VARCHAR2,
    x_failure_score_commentary7             IN     VARCHAR2,
    x_failure_score_commentary8             IN     VARCHAR2,
    x_failure_score_commentary9             IN     VARCHAR2,
    x_failure_score_commentary10            IN     VARCHAR2,
    x_failure_score_date                    IN     DATE,
    x_failure_score_incd_default            IN     NUMBER,
    x_fail_score_natnl_percentile        IN     NUMBER,
    x_failure_score_override_code           IN     VARCHAR2,
    x_global_failure_score                  IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
      INSERT INTO HZ_CREDIT_RATINGS (
        credit_rating_id,
        description,
        party_id,
        rating,
        rated_as_of_date,
        rating_organization,
        created_by,
        creation_date,
        last_update_login,
        last_update_date,
        last_updated_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        wh_update_date,
        comments,
        det_history_ind,
        fincl_embt_ind,
        criminal_proceeding_ind,
        suit_judge_ind,
        claims_ind,
        secured_flng_ind,
        fincl_lgl_event_ind,
        disaster_ind,
        oprg_spec_evnt_ind,
        other_spec_evnt_ind,
        content_source_type,
        status,
        object_version_number,
        created_by_module,
        application_id,
        avg_high_credit,
        credit_score,
        credit_score_age,
        credit_score_class,
        credit_score_commentary,
        credit_score_commentary2,
        credit_score_commentary3,
        credit_score_commentary4,
        credit_score_commentary5,
        credit_score_commentary6,
        credit_score_commentary7,
        credit_score_commentary8,
        credit_score_commentary9,
        credit_score_commentary10,
        credit_score_date,
        credit_score_incd_default,
        credit_score_natl_percentile,
        debarment_ind,
        debarments_count,
        debarments_date,
        high_credit,
        maximum_credit_currency_code,
        maximum_credit_recommendation,
        paydex_norm,
        paydex_score,
        paydex_three_months_ago,
        credit_score_override_code,
        cr_scr_clas_expl,
        low_rng_delq_scr,
        high_rng_delq_scr,
        delq_pmt_rng_prcnt,
        delq_pmt_pctg_for_all_firms,
        num_trade_experiences,
        paydex_firm_days,
        paydex_firm_comment,
        paydex_industry_days,
        paydex_industry_comment,
        paydex_comment,
        suit_ind,
        lien_ind,
        judgement_ind,
        bankruptcy_ind,
        no_trade_ind,
        prnt_hq_bkcy_ind,
        num_prnt_bkcy_filing,
        prnt_bkcy_filg_type,
        prnt_bkcy_filg_chapter,
        prnt_bkcy_filg_date,
        num_prnt_bkcy_convs,
        prnt_bkcy_conv_date,
        prnt_bkcy_chapter_conv,
        slow_trade_expl,
        negv_pmt_expl,
        pub_rec_expl,
        business_discontinued,
        spcl_event_comment,
        num_spcl_event,
        spcl_event_update_date,
        spcl_evnt_txt,
        failure_score,
        failure_score_age,
        failure_score_class,
        failure_score_commentary,
        failure_score_commentary2,
        failure_score_commentary3,
        failure_score_commentary4,
        failure_score_commentary5,
        failure_score_commentary6,
        failure_score_commentary7,
        failure_score_commentary8,
        failure_score_commentary9,
        failure_score_commentary10,
        failure_score_date,
        failure_score_incd_default,
        failure_score_natnl_percentile,
        failure_score_override_code,
        global_failure_score,
        actual_content_source
      )
      VALUES (
        DECODE(x_credit_rating_id,
               FND_API.G_MISS_NUM, HZ_CREDIT_RATINGS_S.NEXTVAL,
               NULL, HZ_CREDIT_RATINGS_S.NEXTVAL,
               x_credit_rating_id),
        DECODE(x_description,
               FND_API.G_MISS_CHAR, NULL,
               x_description),
        DECODE(x_party_id,
               FND_API.G_MISS_NUM, NULL,
               x_party_id),
        DECODE(x_rating,
               FND_API.G_MISS_CHAR, NULL,
               x_rating),
        --Bug 3090928
	trunc(DECODE(x_rated_as_of_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_rated_as_of_date)),
        DECODE(x_rating_organization,
               FND_API.G_MISS_CHAR, NULL,
               x_rating_organization),
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.last_update_login,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.request_id,
        hz_utility_v2pub.program_application_id,
        hz_utility_v2pub.program_id,
        hz_utility_v2pub.program_update_date,
        FND_API.G_MISS_DATE,
        DECODE(x_comments,
               FND_API.G_MISS_CHAR, NULL,
               x_comments),
        DECODE(x_det_history_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_det_history_ind),
        DECODE(x_fincl_embt_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_fincl_embt_ind),
        DECODE(x_criminal_proceeding_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_criminal_proceeding_ind),
        DECODE(x_suit_judge_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_suit_judge_ind),
        DECODE(x_claims_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_claims_ind),
        DECODE(x_secured_flng_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_secured_flng_ind),
        DECODE(x_fincl_lgl_event_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_fincl_lgl_event_ind),
        DECODE(x_disaster_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_disaster_ind),
        DECODE(x_oprg_spec_evnt_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_oprg_spec_evnt_ind),
        DECODE(x_other_spec_evnt_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_other_spec_evnt_ind),
        DECODE(x_content_source_type,
               FND_API.G_MISS_CHAR, G_MISS_CONTENT_SOURCE_TYPE,
               NULL, G_MISS_CONTENT_SOURCE_TYPE,
               x_content_source_type),
        DECODE(x_status,
               FND_API.G_MISS_CHAR, 'A',
               NULL, 'A',
               x_status),
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
        DECODE(x_created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
        hz_utility_v2pub.application_id,
        DECODE(x_avg_high_credit,
               FND_API.G_MISS_NUM, NULL,
               x_avg_high_credit),
        DECODE(x_credit_score,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score),
        DECODE(x_credit_score_age,
               FND_API.G_MISS_NUM, NULL,
               x_credit_score_age),
        DECODE(x_credit_score_class,
               FND_API.G_MISS_NUM, NULL,
               x_credit_score_class),
        DECODE(x_credit_score_commentary,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary),
        DECODE(x_credit_score_commentary2,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary2),
        DECODE(x_credit_score_commentary3,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary3),
        DECODE(x_credit_score_commentary4,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary4),
        DECODE(x_credit_score_commentary5,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary5),
        DECODE(x_credit_score_commentary6,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary6),
        DECODE(x_credit_score_commentary7,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary7),
        DECODE(x_credit_score_commentary8,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary8),
        DECODE(x_credit_score_commentary9,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary9),
        DECODE(x_credit_score_commentary10,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary10),
        DECODE(x_credit_score_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_credit_score_date),
        DECODE(x_credit_score_incd_default,
               FND_API.G_MISS_NUM, NULL,
               x_credit_score_incd_default),
        DECODE(x_credit_score_natl_percentile,
               FND_API.G_MISS_NUM, NULL,
               x_credit_score_natl_percentile),
        DECODE(x_debarment_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_debarment_ind),
        DECODE(x_debarments_count,
               FND_API.G_MISS_NUM, NULL,
               x_debarments_count),
        DECODE(x_debarments_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_debarments_date),
        DECODE(x_high_credit,
               FND_API.G_MISS_NUM, NULL,
               x_high_credit),
        DECODE(x_maximum_credit_currency_code,
               FND_API.G_MISS_CHAR, NULL,
               x_maximum_credit_currency_code),
        DECODE(x_maximum_credit_rcmd,
               FND_API.G_MISS_NUM, NULL,
               x_maximum_credit_rcmd),
        DECODE(x_paydex_norm,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_norm),
        DECODE(x_paydex_score,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_score),
        DECODE(x_paydex_three_months_ago,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_three_months_ago),
        DECODE(x_credit_score_override_code,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_override_code),
        DECODE(x_cr_scr_clas_expl,
               FND_API.G_MISS_CHAR, NULL,
               x_cr_scr_clas_expl),
        DECODE(x_low_rng_delq_scr,
               FND_API.G_MISS_NUM, NULL,
               x_low_rng_delq_scr),
        DECODE(x_high_rng_delq_scr,
               FND_API.G_MISS_NUM, NULL,
               x_high_rng_delq_scr),
        DECODE(x_delq_pmt_rng_prcnt,
               FND_API.G_MISS_NUM, NULL,
               x_delq_pmt_rng_prcnt),
        DECODE(x_delq_pmt_pctg_for_all_firms,
               FND_API.G_MISS_NUM, NULL,
               x_delq_pmt_pctg_for_all_firms),
        DECODE(x_num_trade_experiences,
               FND_API.G_MISS_NUM, NULL,
               x_num_trade_experiences),
        DECODE(x_paydex_firm_days,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_firm_days),
        DECODE(x_paydex_firm_comment,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_firm_comment),
        DECODE(x_paydex_industry_days,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_industry_days),
        DECODE(x_paydex_industry_comment,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_industry_comment),
        DECODE(x_paydex_comment,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_comment),
        DECODE(x_suit_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_suit_ind),
        DECODE(x_lien_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_lien_ind),
        DECODE(x_judgement_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_judgement_ind),
        DECODE(x_bankruptcy_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_bankruptcy_ind),
        DECODE(x_no_trade_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_no_trade_ind),
        DECODE(x_prnt_hq_bkcy_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_prnt_hq_bkcy_ind),
        DECODE(x_num_prnt_bkcy_filing,
               FND_API.G_MISS_NUM, NULL,
               x_num_prnt_bkcy_filing),
        DECODE(x_prnt_bkcy_filg_type,
               FND_API.G_MISS_CHAR, NULL,
               x_prnt_bkcy_filg_type),
        DECODE(x_prnt_bkcy_filg_chapter,
               FND_API.G_MISS_NUM, NULL,
               x_prnt_bkcy_filg_chapter),
        DECODE(x_prnt_bkcy_filg_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_prnt_bkcy_filg_date),
        DECODE(x_num_prnt_bkcy_convs,
               FND_API.G_MISS_NUM, NULL,
               x_num_prnt_bkcy_convs),
        DECODE(x_prnt_bkcy_conv_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_prnt_bkcy_conv_date),
        DECODE(x_prnt_bkcy_chapter_conv,
               FND_API.G_MISS_CHAR, NULL,
               x_prnt_bkcy_chapter_conv),
        DECODE(x_slow_trade_expl,
               FND_API.G_MISS_CHAR, NULL,
               x_slow_trade_expl),
        DECODE(x_negv_pmt_expl,
               FND_API.G_MISS_CHAR, NULL,
               x_negv_pmt_expl),
        DECODE(x_pub_rec_expl,
               FND_API.G_MISS_CHAR, NULL,
               x_pub_rec_expl),
        DECODE(x_business_discontinued,
               FND_API.G_MISS_CHAR, NULL,
               x_business_discontinued),
        DECODE(x_spcl_event_comment,
               FND_API.G_MISS_CHAR, NULL,
               x_spcl_event_comment),
        DECODE(x_num_spcl_event,
               FND_API.G_MISS_NUM, NULL,
               x_num_spcl_event),
        DECODE(x_spcl_event_update_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_spcl_event_update_date),
        DECODE(x_spcl_evnt_txt,
               FND_API.G_MISS_CHAR, NULL,
               x_spcl_evnt_txt),
        DECODE(x_failure_score,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score),
        DECODE(x_failure_score_age,
               FND_API.G_MISS_NUM, NULL,
               x_failure_score_age),
        DECODE(x_failure_score_class,
               FND_API.G_MISS_NUM, NULL,
               x_failure_score_class),
        DECODE(x_failure_score_commentary,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary),
        DECODE(x_failure_score_commentary2,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary2),
        DECODE(x_failure_score_commentary3,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary3),
        DECODE(x_failure_score_commentary4,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary4),
        DECODE(x_failure_score_commentary5,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary5),
        DECODE(x_failure_score_commentary6,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary6),
        DECODE(x_failure_score_commentary7,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary7),
        DECODE(x_failure_score_commentary8,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary8),
        DECODE(x_failure_score_commentary9,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary9),
        DECODE(x_failure_score_commentary10,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary10),
        DECODE(x_failure_score_date,
               FND_API.G_MISS_DATE, TO_DATE(NULL),
               x_failure_score_date),
        DECODE(x_failure_score_incd_default,
               FND_API.G_MISS_NUM, NULL,
               x_failure_score_incd_default),
        DECODE(x_fail_score_natnl_percentile,
               FND_API.G_MISS_NUM, NULL,
               x_fail_score_natnl_percentile),
        DECODE(x_failure_score_override_code,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_override_code),
        DECODE(x_global_failure_score,
               FND_API.G_MISS_CHAR, NULL,
               x_global_failure_score),
        DECODE(x_actual_content_source,
               FND_API.G_MISS_CHAR, G_MISS_CONTENT_SOURCE_TYPE,
               NULL, G_MISS_CONTENT_SOURCE_TYPE,
               x_actual_content_source)
      ) RETURNING
        rowid,
        credit_rating_id
      INTO
        x_rowid,
        x_credit_rating_id;

      l_success := 'Y';

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        IF INSTR(SQLERRM, 'HZ_CREDIT_RATINGS_U1') <> 0 THEN
          DECLARE
            l_count             NUMBER;
            l_dummy             VARCHAR2(1);
          BEGIN
            l_count := 1;
            WHILE l_count > 0 LOOP
              SELECT HZ_CREDIT_RATINGS_S.NEXTVAL
              INTO x_credit_rating_id FROM dual;
              BEGIN
                SELECT 'Y' INTO l_dummy
                FROM HZ_CREDIT_RATINGS
                WHERE credit_rating_id = x_credit_rating_id;
                l_count := 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_count := 0;
              END;
            END LOOP;
          END;
        END IF;
	--Bug 3090928
        IF INSTR(SQLERRM,'HZ_CREDIT_RATINGS_U2') <> 0 THEN
	   fnd_message.set_name('AR', 'HZ_API_DUP_CREDIT_RATING_REC');
	   fnd_msg_pub.add;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
    END;
    END LOOP;

END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_credit_rating_id                      IN     NUMBER,
    x_description                           IN     VARCHAR2,
    x_party_id                              IN     NUMBER,
    x_rating                                IN     VARCHAR2,
    x_rated_as_of_date                      IN     DATE,
    x_rating_organization                   IN     VARCHAR2,
    x_comments                              IN     VARCHAR2,
    x_det_history_ind                       IN     VARCHAR2,
    x_fincl_embt_ind                        IN     VARCHAR2,
    x_criminal_proceeding_ind               IN     VARCHAR2,
    x_suit_judge_ind                        IN     VARCHAR2,
    x_claims_ind                            IN     VARCHAR2,
    x_secured_flng_ind                      IN     VARCHAR2,
    x_fincl_lgl_event_ind                   IN     VARCHAR2,
    x_disaster_ind                          IN     VARCHAR2,
    x_oprg_spec_evnt_ind                    IN     VARCHAR2,
    x_other_spec_evnt_ind                   IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_avg_high_credit                       IN     NUMBER,
    x_credit_score                          IN     VARCHAR2,
    x_credit_score_age                      IN     NUMBER,
    x_credit_score_class                    IN     NUMBER,
    x_credit_score_commentary               IN     VARCHAR2,
    x_credit_score_commentary2              IN     VARCHAR2,
    x_credit_score_commentary3              IN     VARCHAR2,
    x_credit_score_commentary4              IN     VARCHAR2,
    x_credit_score_commentary5              IN     VARCHAR2,
    x_credit_score_commentary6              IN     VARCHAR2,
    x_credit_score_commentary7              IN     VARCHAR2,
    x_credit_score_commentary8              IN     VARCHAR2,
    x_credit_score_commentary9              IN     VARCHAR2,
    x_credit_score_commentary10             IN     VARCHAR2,
    x_credit_score_date                     IN     DATE,
    x_credit_score_incd_default             IN     NUMBER,
    x_credit_score_natl_percentile          IN     NUMBER,
    x_debarment_ind                         IN     VARCHAR2,
    x_debarments_count                      IN     NUMBER,
    x_debarments_date                       IN     DATE,
    x_high_credit                           IN     NUMBER,
    x_maximum_credit_currency_code          IN     VARCHAR2,
    x_maximum_credit_rcmd                   IN     NUMBER,
    x_paydex_norm                           IN     VARCHAR2,
    x_paydex_score                          IN     VARCHAR2,
    x_paydex_three_months_ago               IN     VARCHAR2,
    x_credit_score_override_code            IN     VARCHAR2,
    x_cr_scr_clas_expl                      IN     VARCHAR2,
    x_low_rng_delq_scr                      IN     NUMBER,
    x_high_rng_delq_scr                     IN     NUMBER,
    x_delq_pmt_rng_prcnt                    IN     NUMBER,
    x_delq_pmt_pctg_for_all_firms           IN     NUMBER,
    x_num_trade_experiences                 IN     NUMBER,
    x_paydex_firm_days                      IN     VARCHAR2,
    x_paydex_firm_comment                   IN     VARCHAR2,
    x_paydex_industry_days                  IN     VARCHAR2,
    x_paydex_industry_comment               IN     VARCHAR2,
    x_paydex_comment                        IN     VARCHAR2,
    x_suit_ind                              IN     VARCHAR2,
    x_lien_ind                              IN     VARCHAR2,
    x_judgement_ind                         IN     VARCHAR2,
    x_bankruptcy_ind                        IN     VARCHAR2,
    x_no_trade_ind                          IN     VARCHAR2,
    x_prnt_hq_bkcy_ind                      IN     VARCHAR2,
    x_num_prnt_bkcy_filing                  IN     NUMBER,
    x_prnt_bkcy_filg_type                   IN     VARCHAR2,
    x_prnt_bkcy_filg_chapter                IN     NUMBER,
    x_prnt_bkcy_filg_date                   IN     DATE,
    x_num_prnt_bkcy_convs                   IN     NUMBER,
    x_prnt_bkcy_conv_date                   IN     DATE,
    x_prnt_bkcy_chapter_conv                IN     VARCHAR2,
    x_slow_trade_expl                       IN     VARCHAR2,
    x_negv_pmt_expl                         IN     VARCHAR2,
    x_pub_rec_expl                          IN     VARCHAR2,
    x_business_discontinued                 IN     VARCHAR2,
    x_spcl_event_comment                    IN     VARCHAR2,
    x_num_spcl_event                        IN     NUMBER,
    x_spcl_event_update_date                IN     DATE,
    x_spcl_evnt_txt                         IN     VARCHAR2,
    x_failure_score                         IN     VARCHAR2,
    x_failure_score_age                     IN     NUMBER,
    x_failure_score_class                   IN     NUMBER,
    x_failure_score_commentary              IN     VARCHAR2,
    x_failure_score_commentary2             IN     VARCHAR2,
    x_failure_score_commentary3             IN     VARCHAR2,
    x_failure_score_commentary4             IN     VARCHAR2,
    x_failure_score_commentary5             IN     VARCHAR2,
    x_failure_score_commentary6             IN     VARCHAR2,
    x_failure_score_commentary7             IN     VARCHAR2,
    x_failure_score_commentary8             IN     VARCHAR2,
    x_failure_score_commentary9             IN     VARCHAR2,
    x_failure_score_commentary10            IN     VARCHAR2,
    x_failure_score_date                    IN     DATE,
    x_failure_score_incd_default            IN     NUMBER,
    x_fail_score_natnl_percentile        IN     NUMBER,
    x_failure_score_override_code           IN     VARCHAR2,
    x_global_failure_score                  IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
) IS
BEGIN

    UPDATE HZ_CREDIT_RATINGS
    SET
      credit_rating_id =
        DECODE(x_credit_rating_id,
               NULL, credit_rating_id,
               FND_API.G_MISS_NUM, NULL,
               x_credit_rating_id),
      description =
        DECODE(x_description,
               NULL, description,
               FND_API.G_MISS_CHAR, NULL,
               x_description),
      party_id =
        DECODE(x_party_id,
               NULL, party_id,
               FND_API.G_MISS_NUM, NULL,
               x_party_id),
      rating =
        DECODE(x_rating,
               NULL, rating,
               FND_API.G_MISS_CHAR, NULL,
               x_rating),
      rated_as_of_date =
       --Bug 3090928
       trunc( DECODE(x_rated_as_of_date,
               NULL, rated_as_of_date,
               FND_API.G_MISS_DATE, NULL,
               x_rated_as_of_date)),
      rating_organization =
        DECODE(x_rating_organization,
               NULL, rating_organization,
               FND_API.G_MISS_CHAR, NULL,
               x_rating_organization),
      created_by = created_by,
      creation_date = creation_date,
      last_update_login = hz_utility_v2pub.last_update_login,
      last_update_date = hz_utility_v2pub.last_update_date,
      last_updated_by = hz_utility_v2pub.last_updated_by,
      request_id = hz_utility_v2pub.request_id,
      program_application_id = hz_utility_v2pub.program_application_id,
      program_id = hz_utility_v2pub.program_id,
      wh_update_date = FND_API.G_MISS_DATE,
      comments =
        DECODE(x_comments,
               NULL, comments,
               FND_API.G_MISS_CHAR, NULL,
               x_comments),
      det_history_ind =
        DECODE(x_det_history_ind,
               NULL, det_history_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_det_history_ind),
      fincl_embt_ind =
        DECODE(x_fincl_embt_ind,
               NULL, fincl_embt_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_fincl_embt_ind),
      criminal_proceeding_ind =
        DECODE(x_criminal_proceeding_ind,
               NULL, criminal_proceeding_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_criminal_proceeding_ind),
      suit_judge_ind =
        DECODE(x_suit_judge_ind,
               NULL, suit_judge_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_suit_judge_ind),
      claims_ind =
        DECODE(x_claims_ind,
               NULL, claims_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_claims_ind),
      secured_flng_ind =
        DECODE(x_secured_flng_ind,
               NULL, secured_flng_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_secured_flng_ind),
      fincl_lgl_event_ind =
        DECODE(x_fincl_lgl_event_ind,
               NULL, fincl_lgl_event_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_fincl_lgl_event_ind),
      disaster_ind =
        DECODE(x_disaster_ind,
               NULL, disaster_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_disaster_ind),
      oprg_spec_evnt_ind =
        DECODE(x_oprg_spec_evnt_ind,
               NULL, oprg_spec_evnt_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_oprg_spec_evnt_ind),
      other_spec_evnt_ind =
        DECODE(x_other_spec_evnt_ind,
               NULL, other_spec_evnt_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_other_spec_evnt_ind),
      content_source_type =
        DECODE(x_content_source_type,
               NULL, G_MISS_CONTENT_SOURCE_TYPE,
               FND_API.G_MISS_CHAR, G_MISS_CONTENT_SOURCE_TYPE,
               x_content_source_type),
      program_update_date = hz_utility_v2pub.program_update_date,
      status =
        DECODE(x_status,
               NULL, status,
               FND_API.G_MISS_CHAR, NULL,
               x_status),
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
      created_by_module =
        DECODE(x_created_by_module,
               NULL, created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
      application_id = hz_utility_v2pub.application_id,
      avg_high_credit =
        DECODE(x_avg_high_credit,
               NULL, avg_high_credit,
               FND_API.G_MISS_NUM, NULL,
               x_avg_high_credit),
      credit_score =
        DECODE(x_credit_score,
               NULL, credit_score,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score),
      credit_score_age =
        DECODE(x_credit_score_age,
               NULL, credit_score_age,
               FND_API.G_MISS_NUM, NULL,
               x_credit_score_age),
      credit_score_class =
        DECODE(x_credit_score_class,
               NULL, credit_score_class,
               FND_API.G_MISS_NUM, NULL,
               x_credit_score_class),
      credit_score_commentary =
        DECODE(x_credit_score_commentary,
               NULL, credit_score_commentary,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary),
      credit_score_commentary2 =
        DECODE(x_credit_score_commentary2,
               NULL, credit_score_commentary2,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary2),
      credit_score_commentary3 =
        DECODE(x_credit_score_commentary3,
               NULL, credit_score_commentary3,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary3),
      credit_score_commentary4 =
        DECODE(x_credit_score_commentary4,
               NULL, credit_score_commentary4,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary4),
      credit_score_commentary5 =
        DECODE(x_credit_score_commentary5,
               NULL, credit_score_commentary5,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary5),
      credit_score_commentary6 =
        DECODE(x_credit_score_commentary6,
               NULL, credit_score_commentary6,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary6),
      credit_score_commentary7 =
        DECODE(x_credit_score_commentary7,
               NULL, credit_score_commentary7,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary7),
      credit_score_commentary8 =
        DECODE(x_credit_score_commentary8,
               NULL, credit_score_commentary8,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary8),
      credit_score_commentary9 =
        DECODE(x_credit_score_commentary9,
               NULL, credit_score_commentary9,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary9),
      credit_score_commentary10 =
        DECODE(x_credit_score_commentary10,
               NULL, credit_score_commentary10,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_commentary10),
      credit_score_date =
        DECODE(x_credit_score_date,
               NULL, credit_score_date,
               FND_API.G_MISS_DATE, NULL,
               x_credit_score_date),
      credit_score_incd_default =
        DECODE(x_credit_score_incd_default,
               NULL, credit_score_incd_default,
               FND_API.G_MISS_NUM, NULL,
               x_credit_score_incd_default),
      credit_score_natl_percentile =
        DECODE(x_credit_score_natl_percentile,
               NULL, credit_score_natl_percentile,
               FND_API.G_MISS_NUM, NULL,
               x_credit_score_natl_percentile),
      debarment_ind =
        DECODE(x_debarment_ind,
               NULL, debarment_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_debarment_ind),
      debarments_count =
        DECODE(x_debarments_count,
               NULL, debarments_count,
               FND_API.G_MISS_NUM, NULL,
               x_debarments_count),
      debarments_date =
        DECODE(x_debarments_date,
               NULL, debarments_date,
               FND_API.G_MISS_DATE, NULL,
               x_debarments_date),
      high_credit =
        DECODE(x_high_credit,
               NULL, high_credit,
               FND_API.G_MISS_NUM, NULL,
               x_high_credit),
      maximum_credit_currency_code =
        DECODE(x_maximum_credit_currency_code,
               NULL, maximum_credit_currency_code,
               FND_API.G_MISS_CHAR, NULL,
               x_maximum_credit_currency_code),
      maximum_credit_recommendation =
        DECODE(x_maximum_credit_rcmd,
               NULL, maximum_credit_recommendation,
               FND_API.G_MISS_NUM, NULL,
               x_maximum_credit_rcmd),
      paydex_norm =
        DECODE(x_paydex_norm,
               NULL, paydex_norm,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_norm),
      paydex_score =
        DECODE(x_paydex_score,
               NULL, paydex_score,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_score),
      paydex_three_months_ago =
        DECODE(x_paydex_three_months_ago,
               NULL, paydex_three_months_ago,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_three_months_ago),
      credit_score_override_code =
        DECODE(x_credit_score_override_code,
               NULL, credit_score_override_code,
               FND_API.G_MISS_CHAR, NULL,
               x_credit_score_override_code),
      cr_scr_clas_expl =
        DECODE(x_cr_scr_clas_expl,
               NULL, cr_scr_clas_expl,
               FND_API.G_MISS_CHAR, NULL,
               x_cr_scr_clas_expl),
      low_rng_delq_scr =
        DECODE(x_low_rng_delq_scr,
               NULL, low_rng_delq_scr,
               FND_API.G_MISS_NUM, NULL,
               x_low_rng_delq_scr),
      high_rng_delq_scr =
        DECODE(x_high_rng_delq_scr,
               NULL, high_rng_delq_scr,
               FND_API.G_MISS_NUM, NULL,
               x_high_rng_delq_scr),
      delq_pmt_rng_prcnt =
        DECODE(x_delq_pmt_rng_prcnt,
               NULL, delq_pmt_rng_prcnt,
               FND_API.G_MISS_NUM, NULL,
               x_delq_pmt_rng_prcnt),
      delq_pmt_pctg_for_all_firms =
        DECODE(x_delq_pmt_pctg_for_all_firms,
               NULL, delq_pmt_pctg_for_all_firms,
               FND_API.G_MISS_NUM, NULL,
               x_delq_pmt_pctg_for_all_firms),
      num_trade_experiences =
        DECODE(x_num_trade_experiences,
               NULL, num_trade_experiences,
               FND_API.G_MISS_NUM, NULL,
               x_num_trade_experiences),
      paydex_firm_days =
        DECODE(x_paydex_firm_days,
               NULL, paydex_firm_days,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_firm_days),
      paydex_firm_comment =
        DECODE(x_paydex_firm_comment,
               NULL, paydex_firm_comment,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_firm_comment),
      paydex_industry_days =
        DECODE(x_paydex_industry_days,
               NULL, paydex_industry_days,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_industry_days),
      paydex_industry_comment =
        DECODE(x_paydex_industry_comment,
               NULL, paydex_industry_comment,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_industry_comment),
      paydex_comment =
        DECODE(x_paydex_comment,
               NULL, paydex_comment,
               FND_API.G_MISS_CHAR, NULL,
               x_paydex_comment),
      suit_ind =
        DECODE(x_suit_ind,
               NULL, suit_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_suit_ind),
      lien_ind =
        DECODE(x_lien_ind,
               NULL, lien_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_lien_ind),
      judgement_ind =
        DECODE(x_judgement_ind,
               NULL, judgement_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_judgement_ind),
      bankruptcy_ind =
        DECODE(x_bankruptcy_ind,
               NULL, bankruptcy_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_bankruptcy_ind),
      no_trade_ind =
        DECODE(x_no_trade_ind,
               NULL, no_trade_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_no_trade_ind),
      prnt_hq_bkcy_ind =
        DECODE(x_prnt_hq_bkcy_ind,
               NULL, prnt_hq_bkcy_ind,
               FND_API.G_MISS_CHAR, NULL,
               x_prnt_hq_bkcy_ind),
      num_prnt_bkcy_filing =
        DECODE(x_num_prnt_bkcy_filing,
               NULL, num_prnt_bkcy_filing,
               FND_API.G_MISS_NUM, NULL,
               x_num_prnt_bkcy_filing),
      prnt_bkcy_filg_type =
        DECODE(x_prnt_bkcy_filg_type,
               NULL, prnt_bkcy_filg_type,
               FND_API.G_MISS_CHAR, NULL,
               x_prnt_bkcy_filg_type),
      prnt_bkcy_filg_chapter =
        DECODE(x_prnt_bkcy_filg_chapter,
               NULL, prnt_bkcy_filg_chapter,
               FND_API.G_MISS_NUM, NULL,
               x_prnt_bkcy_filg_chapter),
      prnt_bkcy_filg_date =
        DECODE(x_prnt_bkcy_filg_date,
               NULL, prnt_bkcy_filg_date,
               FND_API.G_MISS_DATE, NULL,
               x_prnt_bkcy_filg_date),
      num_prnt_bkcy_convs =
        DECODE(x_num_prnt_bkcy_convs,
               NULL, num_prnt_bkcy_convs,
               FND_API.G_MISS_NUM, NULL,
               x_num_prnt_bkcy_convs),
      prnt_bkcy_conv_date =
        DECODE(x_prnt_bkcy_conv_date,
               NULL, prnt_bkcy_conv_date,
               FND_API.G_MISS_DATE, NULL,
               x_prnt_bkcy_conv_date),
      prnt_bkcy_chapter_conv =
        DECODE(x_prnt_bkcy_chapter_conv,
               NULL, prnt_bkcy_chapter_conv,
               FND_API.G_MISS_CHAR, NULL,
               x_prnt_bkcy_chapter_conv),
      slow_trade_expl =
        DECODE(x_slow_trade_expl,
               NULL, slow_trade_expl,
               FND_API.G_MISS_CHAR, NULL,
               x_slow_trade_expl),
      negv_pmt_expl =
        DECODE(x_negv_pmt_expl,
               NULL, negv_pmt_expl,
               FND_API.G_MISS_CHAR, NULL,
               x_negv_pmt_expl),
      pub_rec_expl =
        DECODE(x_pub_rec_expl,
               NULL, pub_rec_expl,
               FND_API.G_MISS_CHAR, NULL,
               x_pub_rec_expl),
      business_discontinued =
        DECODE(x_business_discontinued,
               NULL, business_discontinued,
               FND_API.G_MISS_CHAR, NULL,
               x_business_discontinued),
      spcl_event_comment =
        DECODE(x_spcl_event_comment,
               NULL, spcl_event_comment,
               FND_API.G_MISS_CHAR, NULL,
               x_spcl_event_comment),
      num_spcl_event =
        DECODE(x_num_spcl_event,
               NULL, num_spcl_event,
               FND_API.G_MISS_NUM, NULL,
               x_num_spcl_event),
      spcl_event_update_date =
        DECODE(x_spcl_event_update_date,
               NULL, spcl_event_update_date,
               FND_API.G_MISS_DATE, NULL,
               x_spcl_event_update_date),
      spcl_evnt_txt =
        DECODE(x_spcl_evnt_txt,
               NULL, spcl_evnt_txt,
               FND_API.G_MISS_CHAR, NULL,
               x_spcl_evnt_txt),
      failure_score =
        DECODE(x_failure_score,
               NULL, failure_score,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score),
      failure_score_age =
        DECODE(x_failure_score_age,
               NULL, failure_score_age,
               FND_API.G_MISS_NUM, NULL,
               x_failure_score_age),
      failure_score_class =
        DECODE(x_failure_score_class,
               NULL, failure_score_class,
               FND_API.G_MISS_NUM, NULL,
               x_failure_score_class),
      failure_score_commentary =
        DECODE(x_failure_score_commentary,
               NULL, failure_score_commentary,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary),
      failure_score_commentary2 =
        DECODE(x_failure_score_commentary2,
               NULL, failure_score_commentary2,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary2),
      failure_score_commentary3 =
        DECODE(x_failure_score_commentary3,
               NULL, failure_score_commentary3,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary3),
      failure_score_commentary4 =
        DECODE(x_failure_score_commentary4,
               NULL, failure_score_commentary4,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary4),
      failure_score_commentary5 =
        DECODE(x_failure_score_commentary5,
               NULL, failure_score_commentary5,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary5),
      failure_score_commentary6 =
        DECODE(x_failure_score_commentary6,
               NULL, failure_score_commentary6,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary6),
      failure_score_commentary7 =
        DECODE(x_failure_score_commentary7,
               NULL, failure_score_commentary7,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary7),
      failure_score_commentary8 =
        DECODE(x_failure_score_commentary8,
               NULL, failure_score_commentary8,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary8),
      failure_score_commentary9 =
        DECODE(x_failure_score_commentary9,
               NULL, failure_score_commentary9,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary9),
      failure_score_commentary10 =
        DECODE(x_failure_score_commentary10,
               NULL, failure_score_commentary10,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_commentary10),
      failure_score_date =
        DECODE(x_failure_score_date,
               NULL, failure_score_date,
               FND_API.G_MISS_DATE, NULL,
               x_failure_score_date),
      failure_score_incd_default =
        DECODE(x_failure_score_incd_default,
               NULL, failure_score_incd_default,
               FND_API.G_MISS_NUM, NULL,
               x_failure_score_incd_default),
      failure_score_natnl_percentile =
        DECODE(x_fail_score_natnl_percentile,
               NULL, failure_score_natnl_percentile,
               FND_API.G_MISS_NUM, NULL,
               x_fail_score_natnl_percentile),
      failure_score_override_code =
        DECODE(x_failure_score_override_code,
               NULL, failure_score_override_code,
               FND_API.G_MISS_CHAR, NULL,
               x_failure_score_override_code),
      global_failure_score =
        DECODE(x_global_failure_score,
               NULL, global_failure_score,
               FND_API.G_MISS_CHAR, NULL,
               x_global_failure_score)/*,

      ** SSM SST Integration and Extension
      ** actual_content_source will not be updateable for non-SSM enabled entities.

      actual_content_source =
        DECODE(x_actual_content_source,
               NULL, actual_content_source,
               FND_API.G_MISS_CHAR, NULL,
               x_actual_content_source) */
    WHERE rowid = x_rowid;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_credit_rating_id                      IN     NUMBER,
    x_description                           IN     VARCHAR2,
    x_party_id                              IN     NUMBER,
    x_rating                                IN     VARCHAR2,
    x_rated_as_of_date                      IN     DATE,
    x_rating_organization                   IN     VARCHAR2,
    x_created_by                            IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_request_id                            IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_update_date                   IN     DATE,
    x_wh_update_date                        IN     DATE,
    x_comments                              IN     VARCHAR2,
    x_det_history_ind                       IN     VARCHAR2,
    x_fincl_embt_ind                        IN     VARCHAR2,
    x_criminal_proceeding_ind               IN     VARCHAR2,
    x_suit_judge_ind                        IN     VARCHAR2,
    x_claims_ind                            IN     VARCHAR2,
    x_secured_flng_ind                      IN     VARCHAR2,
    x_fincl_lgl_event_ind                   IN     VARCHAR2,
    x_disaster_ind                          IN     VARCHAR2,
    x_oprg_spec_evnt_ind                    IN     VARCHAR2,
    x_other_spec_evnt_ind                   IN     VARCHAR2,
    x_content_source_type                   IN     VARCHAR2,
    x_status                                IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_avg_high_credit                       IN     NUMBER,
    x_credit_score                          IN     VARCHAR2,
    x_credit_score_age                      IN     NUMBER,
    x_credit_score_class                    IN     NUMBER,
    x_credit_score_commentary               IN     VARCHAR2,
    x_credit_score_commentary2              IN     VARCHAR2,
    x_credit_score_commentary3              IN     VARCHAR2,
    x_credit_score_commentary4              IN     VARCHAR2,
    x_credit_score_commentary5              IN     VARCHAR2,
    x_credit_score_commentary6              IN     VARCHAR2,
    x_credit_score_commentary7              IN     VARCHAR2,
    x_credit_score_commentary8              IN     VARCHAR2,
    x_credit_score_commentary9              IN     VARCHAR2,
    x_credit_score_commentary10             IN     VARCHAR2,
    x_credit_score_date                     IN     DATE,
    x_credit_score_incd_default             IN     NUMBER,
    x_credit_score_natl_percentile          IN     NUMBER,
    x_debarment_ind                         IN     VARCHAR2,
    x_debarments_count                      IN     NUMBER,
    x_debarments_date                       IN     DATE,
    x_high_credit                           IN     NUMBER,
    x_maximum_credit_currency_code          IN     VARCHAR2,
    x_maximum_credit_rcmd                   IN     NUMBER,
    x_paydex_norm                           IN     VARCHAR2,
    x_paydex_score                          IN     VARCHAR2,
    x_paydex_three_months_ago               IN     VARCHAR2,
    x_credit_score_override_code            IN     VARCHAR2,
    x_cr_scr_clas_expl                      IN     VARCHAR2,
    x_low_rng_delq_scr                      IN     NUMBER,
    x_high_rng_delq_scr                     IN     NUMBER,
    x_delq_pmt_rng_prcnt                    IN     NUMBER,
    x_delq_pmt_pctg_for_all_firms           IN     NUMBER,
    x_num_trade_experiences                 IN     NUMBER,
    x_paydex_firm_days                      IN     VARCHAR2,
    x_paydex_firm_comment                   IN     VARCHAR2,
    x_paydex_industry_days                  IN     VARCHAR2,
    x_paydex_industry_comment               IN     VARCHAR2,
    x_paydex_comment                        IN     VARCHAR2,
    x_suit_ind                              IN     VARCHAR2,
    x_lien_ind                              IN     VARCHAR2,
    x_judgement_ind                         IN     VARCHAR2,
    x_bankruptcy_ind                        IN     VARCHAR2,
    x_no_trade_ind                          IN     VARCHAR2,
    x_prnt_hq_bkcy_ind                      IN     VARCHAR2,
    x_num_prnt_bkcy_filing                  IN     NUMBER,
    x_prnt_bkcy_filg_type                   IN     VARCHAR2,
    x_prnt_bkcy_filg_chapter                IN     NUMBER,
    x_prnt_bkcy_filg_date                   IN     DATE,
    x_num_prnt_bkcy_convs                   IN     NUMBER,
    x_prnt_bkcy_conv_date                   IN     DATE,
    x_prnt_bkcy_chapter_conv                IN     VARCHAR2,
    x_slow_trade_expl                       IN     VARCHAR2,
    x_negv_pmt_expl                         IN     VARCHAR2,
    x_pub_rec_expl                          IN     VARCHAR2,
    x_business_discontinued                 IN     VARCHAR2,
    x_spcl_event_comment                    IN     VARCHAR2,
    x_num_spcl_event                        IN     NUMBER,
    x_spcl_event_update_date                IN     DATE,
    x_spcl_evnt_txt                         IN     VARCHAR2,
    x_failure_score                         IN     VARCHAR2,
    x_failure_score_age                     IN     NUMBER,
    x_failure_score_class                   IN     NUMBER,
    x_failure_score_commentary              IN     VARCHAR2,
    x_failure_score_commentary2             IN     VARCHAR2,
    x_failure_score_commentary3             IN     VARCHAR2,
    x_failure_score_commentary4             IN     VARCHAR2,
    x_failure_score_commentary5             IN     VARCHAR2,
    x_failure_score_commentary6             IN     VARCHAR2,
    x_failure_score_commentary7             IN     VARCHAR2,
    x_failure_score_commentary8             IN     VARCHAR2,
    x_failure_score_commentary9             IN     VARCHAR2,
    x_failure_score_commentary10            IN     VARCHAR2,
    x_failure_score_date                    IN     DATE,
    x_failure_score_incd_default            IN     NUMBER,
    x_fail_score_natnl_percentile        IN     NUMBER,
    x_failure_score_override_code           IN     VARCHAR2,
    x_global_failure_score                  IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
) IS

    CURSOR c IS
      SELECT * FROM hz_credit_ratings
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;
    Recinfo c%ROWTYPE;

BEGIN

    OPEN c;
    FETCH c INTO Recinfo;
    IF ( c%NOTFOUND ) THEN
      CLOSE c;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF (
        ( ( Recinfo.credit_rating_id = x_credit_rating_id )
        OR ( ( Recinfo.credit_rating_id IS NULL )
          AND (  x_credit_rating_id IS NULL ) ) )
    AND ( ( Recinfo.description = x_description )
        OR ( ( Recinfo.description IS NULL )
          AND (  x_description IS NULL ) ) )
    AND ( ( Recinfo.party_id = x_party_id )
        OR ( ( Recinfo.party_id IS NULL )
          AND (  x_party_id IS NULL ) ) )
    AND ( ( Recinfo.rating = x_rating )
        OR ( ( Recinfo.rating IS NULL )
          AND (  x_rating IS NULL ) ) )
    AND ( ( Recinfo.rated_as_of_date = x_rated_as_of_date )
        OR ( ( Recinfo.rated_as_of_date IS NULL )
          AND (  x_rated_as_of_date IS NULL ) ) )
    AND ( ( Recinfo.rating_organization = x_rating_organization )
        OR ( ( Recinfo.rating_organization IS NULL )
          AND (  x_rating_organization IS NULL ) ) )
    AND ( ( Recinfo.created_by = x_created_by )
        OR ( ( Recinfo.created_by IS NULL )
          AND (  x_created_by IS NULL ) ) )
    AND ( ( Recinfo.creation_date = x_creation_date )
        OR ( ( Recinfo.creation_date IS NULL )
          AND (  x_creation_date IS NULL ) ) )
    AND ( ( Recinfo.last_update_login = x_last_update_login )
        OR ( ( Recinfo.last_update_login IS NULL )
          AND (  x_last_update_login IS NULL ) ) )
    AND ( ( Recinfo.last_update_date = x_last_update_date )
        OR ( ( Recinfo.last_update_date IS NULL )
          AND (  x_last_update_date IS NULL ) ) )
    AND ( ( Recinfo.last_updated_by = x_last_updated_by )
        OR ( ( Recinfo.last_updated_by IS NULL )
          AND (  x_last_updated_by IS NULL ) ) )
    AND ( ( Recinfo.request_id = x_request_id )
        OR ( ( Recinfo.request_id IS NULL )
          AND (  x_request_id IS NULL ) ) )
    AND ( ( Recinfo.program_application_id = x_program_application_id )
        OR ( ( Recinfo.program_application_id IS NULL )
          AND (  x_program_application_id IS NULL ) ) )
    AND ( ( Recinfo.program_id = x_program_id )
        OR ( ( Recinfo.program_id IS NULL )
          AND (  x_program_id IS NULL ) ) )
    AND ( ( Recinfo.program_update_date = x_program_update_date )
        OR ( ( Recinfo.program_update_date IS NULL )
          AND (  x_program_update_date IS NULL ) ) )
    AND ( ( Recinfo.wh_update_date = x_wh_update_date )
        OR ( ( Recinfo.wh_update_date IS NULL )
          AND (  x_wh_update_date IS NULL ) ) )
    AND ( ( Recinfo.comments = x_comments )
        OR ( ( Recinfo.comments IS NULL )
          AND (  x_comments IS NULL ) ) )
    AND ( ( Recinfo.det_history_ind = x_det_history_ind )
        OR ( ( Recinfo.det_history_ind IS NULL )
          AND (  x_det_history_ind IS NULL ) ) )
    AND ( ( Recinfo.fincl_embt_ind = x_fincl_embt_ind )
        OR ( ( Recinfo.fincl_embt_ind IS NULL )
          AND (  x_fincl_embt_ind IS NULL ) ) )
    AND ( ( Recinfo.criminal_proceeding_ind = x_criminal_proceeding_ind )
        OR ( ( Recinfo.criminal_proceeding_ind IS NULL )
          AND (  x_criminal_proceeding_ind IS NULL ) ) )
    AND ( ( Recinfo.suit_judge_ind = x_suit_judge_ind )
        OR ( ( Recinfo.suit_judge_ind IS NULL )
          AND (  x_suit_judge_ind IS NULL ) ) )
    AND ( ( Recinfo.claims_ind = x_claims_ind )
        OR ( ( Recinfo.claims_ind IS NULL )
          AND (  x_claims_ind IS NULL ) ) )
    AND ( ( Recinfo.secured_flng_ind = x_secured_flng_ind )
        OR ( ( Recinfo.secured_flng_ind IS NULL )
          AND (  x_secured_flng_ind IS NULL ) ) )
    AND ( ( Recinfo.fincl_lgl_event_ind = x_fincl_lgl_event_ind )
        OR ( ( Recinfo.fincl_lgl_event_ind IS NULL )
          AND (  x_fincl_lgl_event_ind IS NULL ) ) )
    AND ( ( Recinfo.disaster_ind = x_disaster_ind )
        OR ( ( Recinfo.disaster_ind IS NULL )
          AND (  x_disaster_ind IS NULL ) ) )
    AND ( ( Recinfo.oprg_spec_evnt_ind = x_oprg_spec_evnt_ind )
        OR ( ( Recinfo.oprg_spec_evnt_ind IS NULL )
          AND (  x_oprg_spec_evnt_ind IS NULL ) ) )
    AND ( ( Recinfo.other_spec_evnt_ind = x_other_spec_evnt_ind )
        OR ( ( Recinfo.other_spec_evnt_ind IS NULL )
          AND (  x_other_spec_evnt_ind IS NULL ) ) )
    AND ( ( Recinfo.content_source_type = x_content_source_type )
        OR ( ( Recinfo.content_source_type IS NULL )
          AND (  x_content_source_type IS NULL ) ) )
    AND ( ( Recinfo.status = x_status )
        OR ( ( Recinfo.status IS NULL )
          AND (  x_status IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number )
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    AND ( ( Recinfo.created_by_module = x_created_by_module )
        OR ( ( Recinfo.created_by_module IS NULL )
          AND (  x_created_by_module IS NULL ) ) )
    AND ( ( Recinfo.application_id = x_application_id )
        OR ( ( Recinfo.application_id IS NULL )
          AND (  x_application_id IS NULL ) ) )
    AND ( ( Recinfo.avg_high_credit = x_avg_high_credit )
        OR ( ( Recinfo.avg_high_credit IS NULL )
          AND (  x_avg_high_credit IS NULL ) ) )
    AND ( ( Recinfo.credit_score = x_credit_score )
        OR ( ( Recinfo.credit_score IS NULL )
          AND (  x_credit_score IS NULL ) ) )
    AND ( ( Recinfo.credit_score_age = x_credit_score_age )
        OR ( ( Recinfo.credit_score_age IS NULL )
          AND (  x_credit_score_age IS NULL ) ) )
    AND ( ( Recinfo.credit_score_class = x_credit_score_class )
        OR ( ( Recinfo.credit_score_class IS NULL )
          AND (  x_credit_score_class IS NULL ) ) )
    AND ( ( Recinfo.credit_score_commentary = x_credit_score_commentary )
        OR ( ( Recinfo.credit_score_commentary IS NULL )
          AND (  x_credit_score_commentary IS NULL ) ) )
    AND ( ( Recinfo.credit_score_commentary2 = x_credit_score_commentary2 )
        OR ( ( Recinfo.credit_score_commentary2 IS NULL )
          AND (  x_credit_score_commentary2 IS NULL ) ) )
    AND ( ( Recinfo.credit_score_commentary3 = x_credit_score_commentary3 )
        OR ( ( Recinfo.credit_score_commentary3 IS NULL )
          AND (  x_credit_score_commentary3 IS NULL ) ) )
    AND ( ( Recinfo.credit_score_commentary4 = x_credit_score_commentary4 )
        OR ( ( Recinfo.credit_score_commentary4 IS NULL )
          AND (  x_credit_score_commentary4 IS NULL ) ) )
    AND ( ( Recinfo.credit_score_commentary5 = x_credit_score_commentary5 )
        OR ( ( Recinfo.credit_score_commentary5 IS NULL )
          AND (  x_credit_score_commentary5 IS NULL ) ) )
    AND ( ( Recinfo.credit_score_commentary6 = x_credit_score_commentary6 )
        OR ( ( Recinfo.credit_score_commentary6 IS NULL )
          AND (  x_credit_score_commentary6 IS NULL ) ) )
    AND ( ( Recinfo.credit_score_commentary7 = x_credit_score_commentary7 )
        OR ( ( Recinfo.credit_score_commentary7 IS NULL )
          AND (  x_credit_score_commentary7 IS NULL ) ) )
    AND ( ( Recinfo.credit_score_commentary8 = x_credit_score_commentary8 )
        OR ( ( Recinfo.credit_score_commentary8 IS NULL )
          AND (  x_credit_score_commentary8 IS NULL ) ) )
    AND ( ( Recinfo.credit_score_commentary9 = x_credit_score_commentary9 )
        OR ( ( Recinfo.credit_score_commentary9 IS NULL )
          AND (  x_credit_score_commentary9 IS NULL ) ) )
    AND ( ( Recinfo.credit_score_commentary10 = x_credit_score_commentary10 )
        OR ( ( Recinfo.credit_score_commentary10 IS NULL )
          AND (  x_credit_score_commentary10 IS NULL ) ) )
    AND ( ( Recinfo.credit_score_date = x_credit_score_date )
        OR ( ( Recinfo.credit_score_date IS NULL )
          AND (  x_credit_score_date IS NULL ) ) )
    AND ( ( Recinfo.credit_score_incd_default = x_credit_score_incd_default )
        OR ( ( Recinfo.credit_score_incd_default IS NULL )
          AND (  x_credit_score_incd_default IS NULL ) ) )
    AND ( ( Recinfo.credit_score_natl_percentile = x_credit_score_natl_percentile )
        OR ( ( Recinfo.credit_score_natl_percentile IS NULL )
          AND (  x_credit_score_natl_percentile IS NULL ) ) )
    AND ( ( Recinfo.debarment_ind = x_debarment_ind )
        OR ( ( Recinfo.debarment_ind IS NULL )
          AND (  x_debarment_ind IS NULL ) ) )
    AND ( ( Recinfo.debarments_count = x_debarments_count )
        OR ( ( Recinfo.debarments_count IS NULL )
          AND (  x_debarments_count IS NULL ) ) )
    AND ( ( Recinfo.debarments_date = x_debarments_date )
        OR ( ( Recinfo.debarments_date IS NULL )
          AND (  x_debarments_date IS NULL ) ) )
    AND ( ( Recinfo.high_credit = x_high_credit )
        OR ( ( Recinfo.high_credit IS NULL )
          AND (  x_high_credit IS NULL ) ) )
    AND ( ( Recinfo.maximum_credit_currency_code = x_maximum_credit_currency_code )
        OR ( ( Recinfo.maximum_credit_currency_code IS NULL )
          AND (  x_maximum_credit_currency_code IS NULL ) ) )
    AND ( ( Recinfo.maximum_credit_recommendation = x_maximum_credit_rcmd )
        OR ( ( Recinfo.maximum_credit_recommendation IS NULL )
          AND (  x_maximum_credit_rcmd IS NULL ) ) )
    AND ( ( Recinfo.paydex_norm = x_paydex_norm )
        OR ( ( Recinfo.paydex_norm IS NULL )
          AND (  x_paydex_norm IS NULL ) ) )
    AND ( ( Recinfo.paydex_score = x_paydex_score )
        OR ( ( Recinfo.paydex_score IS NULL )
          AND (  x_paydex_score IS NULL ) ) )
    AND ( ( Recinfo.paydex_three_months_ago = x_paydex_three_months_ago )
        OR ( ( Recinfo.paydex_three_months_ago IS NULL )
          AND (  x_paydex_three_months_ago IS NULL ) ) )
    AND ( ( Recinfo.credit_score_override_code = x_credit_score_override_code )
        OR ( ( Recinfo.credit_score_override_code IS NULL )
          AND (  x_credit_score_override_code IS NULL ) ) )
    AND ( ( Recinfo.cr_scr_clas_expl = x_cr_scr_clas_expl )
        OR ( ( Recinfo.cr_scr_clas_expl IS NULL )
          AND (  x_cr_scr_clas_expl IS NULL ) ) )
    AND ( ( Recinfo.low_rng_delq_scr = x_low_rng_delq_scr )
        OR ( ( Recinfo.low_rng_delq_scr IS NULL )
          AND (  x_low_rng_delq_scr IS NULL ) ) )
    AND ( ( Recinfo.high_rng_delq_scr = x_high_rng_delq_scr )
        OR ( ( Recinfo.high_rng_delq_scr IS NULL )
          AND (  x_high_rng_delq_scr IS NULL ) ) )
    AND ( ( Recinfo.delq_pmt_rng_prcnt = x_delq_pmt_rng_prcnt )
        OR ( ( Recinfo.delq_pmt_rng_prcnt IS NULL )
          AND (  x_delq_pmt_rng_prcnt IS NULL ) ) )
    AND ( ( Recinfo.delq_pmt_pctg_for_all_firms = x_delq_pmt_pctg_for_all_firms )
        OR ( ( Recinfo.delq_pmt_pctg_for_all_firms IS NULL )
          AND (  x_delq_pmt_pctg_for_all_firms IS NULL ) ) )
    AND ( ( Recinfo.num_trade_experiences = x_num_trade_experiences )
        OR ( ( Recinfo.num_trade_experiences IS NULL )
          AND (  x_num_trade_experiences IS NULL ) ) )
    AND ( ( Recinfo.paydex_firm_days = x_paydex_firm_days )
        OR ( ( Recinfo.paydex_firm_days IS NULL )
          AND (  x_paydex_firm_days IS NULL ) ) )
    AND ( ( Recinfo.paydex_firm_comment = x_paydex_firm_comment )
        OR ( ( Recinfo.paydex_firm_comment IS NULL )
          AND (  x_paydex_firm_comment IS NULL ) ) )
    AND ( ( Recinfo.paydex_industry_days = x_paydex_industry_days )
        OR ( ( Recinfo.paydex_industry_days IS NULL )
          AND (  x_paydex_industry_days IS NULL ) ) )
    AND ( ( Recinfo.paydex_industry_comment = x_paydex_industry_comment )
        OR ( ( Recinfo.paydex_industry_comment IS NULL )
          AND (  x_paydex_industry_comment IS NULL ) ) )
    AND ( ( Recinfo.paydex_comment = x_paydex_comment )
        OR ( ( Recinfo.paydex_comment IS NULL )
          AND (  x_paydex_comment IS NULL ) ) )
    AND ( ( Recinfo.suit_ind = x_suit_ind )
        OR ( ( Recinfo.suit_ind IS NULL )
          AND (  x_suit_ind IS NULL ) ) )
    AND ( ( Recinfo.lien_ind = x_lien_ind )
        OR ( ( Recinfo.lien_ind IS NULL )
          AND (  x_lien_ind IS NULL ) ) )
    AND ( ( Recinfo.judgement_ind = x_judgement_ind )
        OR ( ( Recinfo.judgement_ind IS NULL )
          AND (  x_judgement_ind IS NULL ) ) )
    AND ( ( Recinfo.bankruptcy_ind = x_bankruptcy_ind )
        OR ( ( Recinfo.bankruptcy_ind IS NULL )
          AND (  x_bankruptcy_ind IS NULL ) ) )
    AND ( ( Recinfo.no_trade_ind = x_no_trade_ind )
        OR ( ( Recinfo.no_trade_ind IS NULL )
          AND (  x_no_trade_ind IS NULL ) ) )
    AND ( ( Recinfo.prnt_hq_bkcy_ind = x_prnt_hq_bkcy_ind )
        OR ( ( Recinfo.prnt_hq_bkcy_ind IS NULL )
          AND (  x_prnt_hq_bkcy_ind IS NULL ) ) )
    AND ( ( Recinfo.num_prnt_bkcy_filing = x_num_prnt_bkcy_filing )
        OR ( ( Recinfo.num_prnt_bkcy_filing IS NULL )
          AND (  x_num_prnt_bkcy_filing IS NULL ) ) )
    AND ( ( Recinfo.prnt_bkcy_filg_type = x_prnt_bkcy_filg_type )
        OR ( ( Recinfo.prnt_bkcy_filg_type IS NULL )
          AND (  x_prnt_bkcy_filg_type IS NULL ) ) )
    AND ( ( Recinfo.prnt_bkcy_filg_chapter = x_prnt_bkcy_filg_chapter )
        OR ( ( Recinfo.prnt_bkcy_filg_chapter IS NULL )
          AND (  x_prnt_bkcy_filg_chapter IS NULL ) ) )
    AND ( ( Recinfo.prnt_bkcy_filg_date = x_prnt_bkcy_filg_date )
        OR ( ( Recinfo.prnt_bkcy_filg_date IS NULL )
          AND (  x_prnt_bkcy_filg_date IS NULL ) ) )
    AND ( ( Recinfo.num_prnt_bkcy_convs = x_num_prnt_bkcy_convs )
        OR ( ( Recinfo.num_prnt_bkcy_convs IS NULL )
          AND (  x_num_prnt_bkcy_convs IS NULL ) ) )
    AND ( ( Recinfo.prnt_bkcy_conv_date = x_prnt_bkcy_conv_date )
        OR ( ( Recinfo.prnt_bkcy_conv_date IS NULL )
          AND (  x_prnt_bkcy_conv_date IS NULL ) ) )
    AND ( ( Recinfo.prnt_bkcy_chapter_conv = x_prnt_bkcy_chapter_conv )
        OR ( ( Recinfo.prnt_bkcy_chapter_conv IS NULL )
          AND (  x_prnt_bkcy_chapter_conv IS NULL ) ) )
    AND ( ( Recinfo.slow_trade_expl = x_slow_trade_expl )
        OR ( ( Recinfo.slow_trade_expl IS NULL )
          AND (  x_slow_trade_expl IS NULL ) ) )
    AND ( ( Recinfo.negv_pmt_expl = x_negv_pmt_expl )
        OR ( ( Recinfo.negv_pmt_expl IS NULL )
          AND (  x_negv_pmt_expl IS NULL ) ) )
    AND ( ( Recinfo.pub_rec_expl = x_pub_rec_expl )
        OR ( ( Recinfo.pub_rec_expl IS NULL )
          AND (  x_pub_rec_expl IS NULL ) ) )
    AND ( ( Recinfo.business_discontinued = x_business_discontinued )
        OR ( ( Recinfo.business_discontinued IS NULL )
          AND (  x_business_discontinued IS NULL ) ) )
    AND ( ( Recinfo.spcl_event_comment = x_spcl_event_comment )
        OR ( ( Recinfo.spcl_event_comment IS NULL )
          AND (  x_spcl_event_comment IS NULL ) ) )
    AND ( ( Recinfo.num_spcl_event = x_num_spcl_event )
        OR ( ( Recinfo.num_spcl_event IS NULL )
          AND (  x_num_spcl_event IS NULL ) ) )
    AND ( ( Recinfo.spcl_event_update_date = x_spcl_event_update_date )
        OR ( ( Recinfo.spcl_event_update_date IS NULL )
          AND (  x_spcl_event_update_date IS NULL ) ) )
    AND ( ( Recinfo.spcl_evnt_txt = x_spcl_evnt_txt )
        OR ( ( Recinfo.spcl_evnt_txt IS NULL )
          AND (  x_spcl_evnt_txt IS NULL ) ) )
    AND ( ( Recinfo.failure_score = x_failure_score )
        OR ( ( Recinfo.failure_score IS NULL )
          AND (  x_failure_score IS NULL ) ) )
    AND ( ( Recinfo.failure_score_age = x_failure_score_age )
        OR ( ( Recinfo.failure_score_age IS NULL )
          AND (  x_failure_score_age IS NULL ) ) )
    AND ( ( Recinfo.failure_score_class = x_failure_score_class )
        OR ( ( Recinfo.failure_score_class IS NULL )
          AND (  x_failure_score_class IS NULL ) ) )
    AND ( ( Recinfo.failure_score_commentary = x_failure_score_commentary )
        OR ( ( Recinfo.failure_score_commentary IS NULL )
          AND (  x_failure_score_commentary IS NULL ) ) )
    AND ( ( Recinfo.failure_score_commentary2 = x_failure_score_commentary2 )
        OR ( ( Recinfo.failure_score_commentary2 IS NULL )
          AND (  x_failure_score_commentary2 IS NULL ) ) )
    AND ( ( Recinfo.failure_score_commentary3 = x_failure_score_commentary3 )
        OR ( ( Recinfo.failure_score_commentary3 IS NULL )
          AND (  x_failure_score_commentary3 IS NULL ) ) )
    AND ( ( Recinfo.failure_score_commentary4 = x_failure_score_commentary4 )
        OR ( ( Recinfo.failure_score_commentary4 IS NULL )
          AND (  x_failure_score_commentary4 IS NULL ) ) )
    AND ( ( Recinfo.failure_score_commentary5 = x_failure_score_commentary5 )
        OR ( ( Recinfo.failure_score_commentary5 IS NULL )
          AND (  x_failure_score_commentary5 IS NULL ) ) )
    AND ( ( Recinfo.failure_score_commentary6 = x_failure_score_commentary6 )
        OR ( ( Recinfo.failure_score_commentary6 IS NULL )
          AND (  x_failure_score_commentary6 IS NULL ) ) )
    AND ( ( Recinfo.failure_score_commentary7 = x_failure_score_commentary7 )
        OR ( ( Recinfo.failure_score_commentary7 IS NULL )
          AND (  x_failure_score_commentary7 IS NULL ) ) )
    AND ( ( Recinfo.failure_score_commentary8 = x_failure_score_commentary8 )
        OR ( ( Recinfo.failure_score_commentary8 IS NULL )
          AND (  x_failure_score_commentary8 IS NULL ) ) )
    AND ( ( Recinfo.failure_score_commentary9 = x_failure_score_commentary9 )
        OR ( ( Recinfo.failure_score_commentary9 IS NULL )
          AND (  x_failure_score_commentary9 IS NULL ) ) )
    AND ( ( Recinfo.failure_score_commentary10 = x_failure_score_commentary10 )
        OR ( ( Recinfo.failure_score_commentary10 IS NULL )
          AND (  x_failure_score_commentary10 IS NULL ) ) )
    AND ( ( Recinfo.failure_score_date = x_failure_score_date )
        OR ( ( Recinfo.failure_score_date IS NULL )
          AND (  x_failure_score_date IS NULL ) ) )
    AND ( ( Recinfo.failure_score_incd_default = x_failure_score_incd_default )
        OR ( ( Recinfo.failure_score_incd_default IS NULL )
          AND (  x_failure_score_incd_default IS NULL ) ) )
    AND ( ( Recinfo.failure_score_natnl_percentile = x_fail_score_natnl_percentile )
        OR ( ( Recinfo.failure_score_natnl_percentile IS NULL )
          AND (  x_fail_score_natnl_percentile IS NULL ) ) )
    AND ( ( Recinfo.failure_score_override_code = x_failure_score_override_code )
        OR ( ( Recinfo.failure_score_override_code IS NULL )
          AND (  x_failure_score_override_code IS NULL ) ) )
    AND ( ( Recinfo.global_failure_score = x_global_failure_score )
        OR ( ( Recinfo.global_failure_score IS NULL )
          AND (  x_global_failure_score IS NULL ) ) )
    AND ( ( Recinfo.actual_content_source = x_actual_content_source )
        OR ( ( Recinfo.actual_content_source IS NULL )
          AND (  x_actual_content_source IS NULL ) ) )
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    x_credit_rating_id                      IN OUT NOCOPY NUMBER,
    x_description                           OUT    NOCOPY VARCHAR2,
    x_party_id                              OUT    NOCOPY NUMBER,
    x_rating                                OUT    NOCOPY VARCHAR2,
    x_rated_as_of_date                      OUT    NOCOPY DATE,
    x_rating_organization                   OUT    NOCOPY VARCHAR2,
    x_comments                              OUT    NOCOPY VARCHAR2,
    x_det_history_ind                       OUT    NOCOPY VARCHAR2,
    x_fincl_embt_ind                        OUT    NOCOPY VARCHAR2,
    x_criminal_proceeding_ind               OUT    NOCOPY VARCHAR2,
    x_claims_ind                            OUT    NOCOPY VARCHAR2,
    x_secured_flng_ind                      OUT    NOCOPY VARCHAR2,
    x_fincl_lgl_event_ind                   OUT    NOCOPY VARCHAR2,
    x_disaster_ind                          OUT    NOCOPY VARCHAR2,
    x_oprg_spec_evnt_ind                    OUT    NOCOPY VARCHAR2,
    x_other_spec_evnt_ind                   OUT    NOCOPY VARCHAR2,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_avg_high_credit                       OUT    NOCOPY NUMBER,
    x_credit_score                          OUT    NOCOPY VARCHAR2,
    x_credit_score_age                      OUT    NOCOPY NUMBER,
    x_credit_score_class                    OUT    NOCOPY NUMBER,
    x_credit_score_commentary               OUT    NOCOPY VARCHAR2,
    x_credit_score_commentary2              OUT    NOCOPY VARCHAR2,
    x_credit_score_commentary3              OUT    NOCOPY VARCHAR2,
    x_credit_score_commentary4              OUT    NOCOPY VARCHAR2,
    x_credit_score_commentary5              OUT    NOCOPY VARCHAR2,
    x_credit_score_commentary6              OUT    NOCOPY VARCHAR2,
    x_credit_score_commentary7              OUT    NOCOPY VARCHAR2,
    x_credit_score_commentary8              OUT    NOCOPY VARCHAR2,
    x_credit_score_commentary9              OUT    NOCOPY VARCHAR2,
    x_credit_score_commentary10             OUT    NOCOPY VARCHAR2,
    x_credit_score_date                     OUT    NOCOPY DATE,
    x_credit_score_incd_default             OUT    NOCOPY NUMBER,
    x_credit_score_natl_percentile          OUT    NOCOPY NUMBER,
    x_debarment_ind                         OUT    NOCOPY VARCHAR2,
    x_debarments_count                      OUT    NOCOPY NUMBER,
    x_debarments_date                       OUT    NOCOPY DATE,
    x_high_credit                           OUT    NOCOPY NUMBER,
    x_maximum_credit_currency_code          OUT    NOCOPY VARCHAR2,
    x_maximum_credit_rcmd                   OUT    NOCOPY NUMBER,
    x_paydex_norm                           OUT    NOCOPY VARCHAR2,
    x_paydex_score                          OUT    NOCOPY VARCHAR2,
    x_paydex_three_months_ago               OUT    NOCOPY VARCHAR2,
    x_credit_score_override_code            OUT    NOCOPY VARCHAR2,
    x_cr_scr_clas_expl                      OUT    NOCOPY VARCHAR2,
    x_low_rng_delq_scr                      OUT    NOCOPY NUMBER,
    x_high_rng_delq_scr                     OUT    NOCOPY NUMBER,
    x_delq_pmt_rng_prcnt                    OUT    NOCOPY NUMBER,
    x_delq_pmt_pctg_for_all_firms           OUT    NOCOPY NUMBER,
    x_num_trade_experiences                 OUT    NOCOPY NUMBER,
    x_paydex_firm_days                      OUT    NOCOPY VARCHAR2,
    x_paydex_firm_comment                   OUT    NOCOPY VARCHAR2,
    x_paydex_industry_days                  OUT    NOCOPY VARCHAR2,
    x_paydex_industry_comment               OUT    NOCOPY VARCHAR2,
    x_paydex_comment                        OUT    NOCOPY VARCHAR2,
    x_suit_ind                              OUT    NOCOPY VARCHAR2,
    x_lien_ind                              OUT    NOCOPY VARCHAR2,
    x_judgement_ind                         OUT    NOCOPY VARCHAR2,
    x_bankruptcy_ind                        OUT    NOCOPY VARCHAR2,
    x_no_trade_ind                          OUT    NOCOPY VARCHAR2,
    x_prnt_hq_bkcy_ind                      OUT    NOCOPY VARCHAR2,
    x_num_prnt_bkcy_filing                  OUT    NOCOPY NUMBER,
    x_prnt_bkcy_filg_type                   OUT    NOCOPY VARCHAR2,
    x_prnt_bkcy_filg_chapter                OUT    NOCOPY NUMBER,
    x_prnt_bkcy_filg_date                   OUT    NOCOPY DATE,
    x_num_prnt_bkcy_convs                   OUT    NOCOPY NUMBER,
    x_prnt_bkcy_conv_date                   OUT    NOCOPY DATE,
    x_prnt_bkcy_chapter_conv                OUT    NOCOPY VARCHAR2,
    x_slow_trade_expl                       OUT    NOCOPY VARCHAR2,
    x_negv_pmt_expl                         OUT    NOCOPY VARCHAR2,
    x_pub_rec_expl                          OUT    NOCOPY VARCHAR2,
    x_business_discontinued                 OUT    NOCOPY VARCHAR2,
    x_spcl_event_comment                    OUT    NOCOPY VARCHAR2,
    x_num_spcl_event                        OUT    NOCOPY NUMBER,
    x_spcl_event_update_date                OUT    NOCOPY DATE,
    x_spcl_evnt_txt                         OUT    NOCOPY VARCHAR2,
    x_failure_score                         OUT    NOCOPY VARCHAR2,
    x_failure_score_age                     OUT    NOCOPY NUMBER,
    x_failure_score_class                   OUT    NOCOPY NUMBER,
    x_failure_score_commentary              OUT    NOCOPY VARCHAR2,
    x_failure_score_commentary2             OUT    NOCOPY VARCHAR2,
    x_failure_score_commentary3             OUT    NOCOPY VARCHAR2,
    x_failure_score_commentary4             OUT    NOCOPY VARCHAR2,
    x_failure_score_commentary5             OUT    NOCOPY VARCHAR2,
    x_failure_score_commentary6             OUT    NOCOPY VARCHAR2,
    x_failure_score_commentary7             OUT    NOCOPY VARCHAR2,
    x_failure_score_commentary8             OUT    NOCOPY VARCHAR2,
    x_failure_score_commentary9             OUT    NOCOPY VARCHAR2,
    x_failure_score_commentary10            OUT    NOCOPY VARCHAR2,
    x_failure_score_date                    OUT    NOCOPY DATE,
    x_failure_score_incd_default            OUT    NOCOPY NUMBER,
    x_fail_score_natnl_percentile           OUT    NOCOPY NUMBER,
    x_failure_score_override_code           OUT    NOCOPY VARCHAR2,
    x_global_failure_score                  OUT    NOCOPY VARCHAR2,
    x_actual_content_source                 OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(credit_rating_id, FND_API.G_MISS_NUM),
      NVL(description, FND_API.G_MISS_CHAR),
      NVL(party_id, FND_API.G_MISS_NUM),
      NVL(rating, FND_API.G_MISS_CHAR),
      NVL(rated_as_of_date, FND_API.G_MISS_DATE),
      NVL(rating_organization, FND_API.G_MISS_CHAR),
      NVL(comments, FND_API.G_MISS_CHAR),
      NVL(det_history_ind, FND_API.G_MISS_CHAR),
      NVL(fincl_embt_ind, FND_API.G_MISS_CHAR),
      NVL(criminal_proceeding_ind, FND_API.G_MISS_CHAR),
      NVL(claims_ind, FND_API.G_MISS_CHAR),
      NVL(secured_flng_ind, FND_API.G_MISS_CHAR),
      NVL(fincl_lgl_event_ind, FND_API.G_MISS_CHAR),
      NVL(disaster_ind, FND_API.G_MISS_CHAR),
      NVL(oprg_spec_evnt_ind, FND_API.G_MISS_CHAR),
      NVL(other_spec_evnt_ind, FND_API.G_MISS_CHAR),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(created_by_module, FND_API.G_MISS_CHAR),
      NVL(avg_high_credit, FND_API.G_MISS_NUM),
      NVL(credit_score, FND_API.G_MISS_CHAR),
      NVL(credit_score_age, FND_API.G_MISS_NUM),
      NVL(credit_score_class, FND_API.G_MISS_NUM),
      NVL(credit_score_commentary, FND_API.G_MISS_CHAR),
      NVL(credit_score_commentary2, FND_API.G_MISS_CHAR),
      NVL(credit_score_commentary3, FND_API.G_MISS_CHAR),
      NVL(credit_score_commentary4, FND_API.G_MISS_CHAR),
      NVL(credit_score_commentary5, FND_API.G_MISS_CHAR),
      NVL(credit_score_commentary6, FND_API.G_MISS_CHAR),
      NVL(credit_score_commentary7, FND_API.G_MISS_CHAR),
      NVL(credit_score_commentary8, FND_API.G_MISS_CHAR),
      NVL(credit_score_commentary9, FND_API.G_MISS_CHAR),
      NVL(credit_score_commentary10, FND_API.G_MISS_CHAR),
      NVL(credit_score_date, FND_API.G_MISS_DATE),
      NVL(credit_score_incd_default, FND_API.G_MISS_NUM),
      NVL(credit_score_natl_percentile, FND_API.G_MISS_NUM),
      NVL(debarment_ind, FND_API.G_MISS_CHAR),
      NVL(debarments_count, FND_API.G_MISS_NUM),
      NVL(debarments_date, FND_API.G_MISS_DATE),
      NVL(high_credit, FND_API.G_MISS_NUM),
      NVL(maximum_credit_currency_code, FND_API.G_MISS_CHAR),
      NVL(maximum_credit_recommendation, FND_API.G_MISS_NUM),
      NVL(paydex_norm, FND_API.G_MISS_CHAR),
      NVL(paydex_score, FND_API.G_MISS_CHAR),
      NVL(paydex_three_months_ago, FND_API.G_MISS_CHAR),
      NVL(credit_score_override_code, FND_API.G_MISS_CHAR),
      NVL(cr_scr_clas_expl, FND_API.G_MISS_CHAR),
      NVL(low_rng_delq_scr, FND_API.G_MISS_NUM),
      NVL(high_rng_delq_scr, FND_API.G_MISS_NUM),
      NVL(delq_pmt_rng_prcnt, FND_API.G_MISS_NUM),
      NVL(delq_pmt_pctg_for_all_firms, FND_API.G_MISS_NUM),
      NVL(num_trade_experiences, FND_API.G_MISS_NUM),
      NVL(paydex_firm_days, FND_API.G_MISS_CHAR),
      NVL(paydex_firm_comment, FND_API.G_MISS_CHAR),
      NVL(paydex_industry_days, FND_API.G_MISS_CHAR),
      NVL(paydex_industry_comment, FND_API.G_MISS_CHAR),
      NVL(paydex_comment, FND_API.G_MISS_CHAR),
      NVL(suit_ind, FND_API.G_MISS_CHAR),
      NVL(lien_ind, FND_API.G_MISS_CHAR),
      NVL(judgement_ind, FND_API.G_MISS_CHAR),
      NVL(bankruptcy_ind, FND_API.G_MISS_CHAR),
      NVL(no_trade_ind, FND_API.G_MISS_CHAR),
      NVL(prnt_hq_bkcy_ind, FND_API.G_MISS_CHAR),
      NVL(num_prnt_bkcy_filing, FND_API.G_MISS_NUM),
      NVL(prnt_bkcy_filg_type, FND_API.G_MISS_CHAR),
      NVL(prnt_bkcy_filg_chapter, FND_API.G_MISS_NUM),
      NVL(prnt_bkcy_filg_date, FND_API.G_MISS_DATE),
      NVL(num_prnt_bkcy_convs, FND_API.G_MISS_NUM),
      NVL(prnt_bkcy_conv_date, FND_API.G_MISS_DATE),
      NVL(prnt_bkcy_chapter_conv, FND_API.G_MISS_CHAR),
      NVL(slow_trade_expl, FND_API.G_MISS_CHAR),
      NVL(negv_pmt_expl, FND_API.G_MISS_CHAR),
      NVL(pub_rec_expl, FND_API.G_MISS_CHAR),
      NVL(business_discontinued, FND_API.G_MISS_CHAR),
      NVL(spcl_event_comment, FND_API.G_MISS_CHAR),
      NVL(num_spcl_event, FND_API.G_MISS_NUM),
      NVL(spcl_event_update_date, FND_API.G_MISS_DATE),
      NVL(spcl_evnt_txt, FND_API.G_MISS_CHAR),
      NVL(failure_score, FND_API.G_MISS_CHAR),
      NVL(failure_score_age, FND_API.G_MISS_NUM),
      NVL(failure_score_class, FND_API.G_MISS_NUM),
      NVL(failure_score_commentary, FND_API.G_MISS_CHAR),
      NVL(failure_score_commentary2, FND_API.G_MISS_CHAR),
      NVL(failure_score_commentary3, FND_API.G_MISS_CHAR),
      NVL(failure_score_commentary4, FND_API.G_MISS_CHAR),
      NVL(failure_score_commentary5, FND_API.G_MISS_CHAR),
      NVL(failure_score_commentary6, FND_API.G_MISS_CHAR),
      NVL(failure_score_commentary7, FND_API.G_MISS_CHAR),
      NVL(failure_score_commentary8, FND_API.G_MISS_CHAR),
      NVL(failure_score_commentary9, FND_API.G_MISS_CHAR),
      NVL(failure_score_commentary10, FND_API.G_MISS_CHAR),
      NVL(failure_score_date, FND_API.G_MISS_DATE),
      NVL(failure_score_incd_default, FND_API.G_MISS_NUM),
      NVL(failure_score_natnl_percentile, FND_API.G_MISS_NUM),
      NVL(failure_score_override_code, FND_API.G_MISS_CHAR),
      NVL(global_failure_score, FND_API.G_MISS_CHAR),
      NVL(actual_content_source, FND_API.G_MISS_CHAR)
    INTO
      x_credit_rating_id,
      x_description,
      x_party_id,
      x_rating,
      x_rated_as_of_date,
      x_rating_organization,
      x_comments,
      x_det_history_ind,
      x_fincl_embt_ind,
      x_criminal_proceeding_ind,
      x_claims_ind,
      x_secured_flng_ind,
      x_fincl_lgl_event_ind,
      x_disaster_ind,
      x_oprg_spec_evnt_ind,
      x_other_spec_evnt_ind,
      x_status,
      x_created_by_module,
      x_avg_high_credit,
      x_credit_score,
      x_credit_score_age,
      x_credit_score_class,
      x_credit_score_commentary,
      x_credit_score_commentary2,
      x_credit_score_commentary3,
      x_credit_score_commentary4,
      x_credit_score_commentary5,
      x_credit_score_commentary6,
      x_credit_score_commentary7,
      x_credit_score_commentary8,
      x_credit_score_commentary9,
      x_credit_score_commentary10,
      x_credit_score_date,
      x_credit_score_incd_default,
      x_credit_score_natl_percentile,
      x_debarment_ind,
      x_debarments_count,
      x_debarments_date,
      x_high_credit,
      x_maximum_credit_currency_code,
      x_maximum_credit_rcmd,
      x_paydex_norm,
      x_paydex_score,
      x_paydex_three_months_ago,
      x_credit_score_override_code,
      x_cr_scr_clas_expl,
      x_low_rng_delq_scr,
      x_high_rng_delq_scr,
      x_delq_pmt_rng_prcnt,
      x_delq_pmt_pctg_for_all_firms,
      x_num_trade_experiences,
      x_paydex_firm_days,
      x_paydex_firm_comment,
      x_paydex_industry_days,
      x_paydex_industry_comment,
      x_paydex_comment,
      x_suit_ind,
      x_lien_ind,
      x_judgement_ind,
      x_bankruptcy_ind,
      x_no_trade_ind,
      x_prnt_hq_bkcy_ind,
      x_num_prnt_bkcy_filing,
      x_prnt_bkcy_filg_type,
      x_prnt_bkcy_filg_chapter,
      x_prnt_bkcy_filg_date,
      x_num_prnt_bkcy_convs,
      x_prnt_bkcy_conv_date,
      x_prnt_bkcy_chapter_conv,
      x_slow_trade_expl,
      x_negv_pmt_expl,
      x_pub_rec_expl,
      x_business_discontinued,
      x_spcl_event_comment,
      x_num_spcl_event,
      x_spcl_event_update_date,
      x_spcl_evnt_txt,
      x_failure_score,
      x_failure_score_age,
      x_failure_score_class,
      x_failure_score_commentary,
      x_failure_score_commentary2,
      x_failure_score_commentary3,
      x_failure_score_commentary4,
      x_failure_score_commentary5,
      x_failure_score_commentary6,
      x_failure_score_commentary7,
      x_failure_score_commentary8,
      x_failure_score_commentary9,
      x_failure_score_commentary10,
      x_failure_score_date,
      x_failure_score_incd_default,
      x_fail_score_natnl_percentile,
      x_failure_score_override_code,
      x_global_failure_score,
      x_actual_content_source
    FROM HZ_CREDIT_RATINGS
    WHERE credit_rating_id = x_credit_rating_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'credit_rating_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_credit_rating_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_credit_rating_id                      IN     NUMBER
) IS
BEGIN

    DELETE FROM HZ_CREDIT_RATINGS
    WHERE credit_rating_id = x_credit_rating_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_CREDIT_RATINGS_PKG;

/
