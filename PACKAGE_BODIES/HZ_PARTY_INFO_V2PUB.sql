--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_INFO_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_INFO_V2PUB" AS
/* $Header: ARH2PRSB.pls 120.9 2005/12/07 19:31:20 acng noship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

--G_DEBUG             BOOLEAN := FALSE;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

PROCEDURE do_create_credit_rating(
    p_credit_rating_rec              IN OUT NOCOPY CREDIT_RATING_REC_TYPE,
    x_credit_rating_id                  OUT NOCOPY NUMBER,
    x_return_status                  IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_credit_rating(
    p_credit_rating_rec                 IN OUT NOCOPY  CREDIT_RATING_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
);

--------------------------------------
-- private procedures and functions
--------------------------------------

/**
 * PRIVATE PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Turn on debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.enable_debug
 *
 * MODIFICATION HISTORY
 *
 *    27-JAN-2003   Sreedhar Mohan        o Created.
 *
 */

/*PROCEDURE enable_debug IS

BEGIN

    IF FND_PROFILE.value( 'HZ_API_FILE_DEBUG_ON' ) = 'Y' OR
       FND_PROFILE.value( 'HZ_API_DBMS_DEBUG_ON' ) = 'Y'
    THEN
        HZ_UTILITY_V2PUB.enable_debug;
        G_DEBUG := TRUE;
    END IF;

END enable_debug;
*/

/**
 * PRIVATE PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Turn off debug mode.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_UTILITY_V2PUB.disable_debug
 *
 * MODIFICATION HISTORY
 *
 *    27-JAN-2003   Sreedhar Mohan        o Created.
 *
 */

/*PROCEDURE disable_debug IS

BEGIN

    IF G_DEBUG THEN
        HZ_UTILITY_V2PUB.disable_debug;
        G_DEBUG := FALSE;
    END IF;

END disable_debug;
*/


/*===========================================================================+
 | PROCEDURE
 |              do_create_credit_rating
 |
 | DESCRIPTION
 |              Creates credit rating
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    credit_rating_id
 |          IN/ OUT:
 |                    p_credit_rating_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_create_credit_rating(
    p_credit_rating_rec               IN OUT NOCOPY CREDIT_RATING_REC_TYPE,
    x_credit_rating_id                   OUT NOCOPY NUMBER,
    x_return_status                   IN OUT NOCOPY VARCHAR2
) IS

    l_dummy                             VARCHAR2(1);
    l_rowid                             ROWID;

BEGIN

    -- if primary key value is passed, check for uniqueness.
    IF p_credit_rating_rec.credit_rating_id IS NOT NULL AND
        p_credit_rating_rec.credit_rating_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y' INTO l_dummy
            FROM   HZ_CREDIT_RATINGS
            WHERE  CREDIT_RATING_ID = p_credit_rating_rec.credit_rating_id;

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'credit_rating_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    -- validate credit rating  record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_credit_rating(
        'C',
        p_credit_rating_rec,
        l_rowid,
        x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table handler to insert a row
    HZ_CREDIT_RATINGS_PKG.Insert_Row (
        x_rowid                                   => l_rowid,
        x_credit_rating_id                        => p_credit_rating_rec.credit_rating_id,
        x_description                             => p_credit_rating_rec.description,
        x_party_id                                => p_credit_rating_rec.party_id,
        x_rating                                  => p_credit_rating_rec.rating,
        x_rated_as_of_date                        => p_credit_rating_rec.rated_as_of_date,
        x_rating_organization                     => p_credit_rating_rec.rating_organization,
        x_comments                                => p_credit_rating_rec.comments,
        x_det_history_ind                         => p_credit_rating_rec.det_history_ind,
        x_fincl_embt_ind                          => p_credit_rating_rec.fincl_embt_ind,
        x_criminal_proceeding_ind                 => p_credit_rating_rec.criminal_proceeding_ind,
        x_suit_judge_ind                          => FND_API.G_MISS_CHAR,
        x_claims_ind                              => p_credit_rating_rec.claims_ind,
        x_secured_flng_ind                        => p_credit_rating_rec.secured_flng_ind,
        x_fincl_lgl_event_ind                     => p_credit_rating_rec.fincl_lgl_event_ind,
        x_disaster_ind                            => p_credit_rating_rec.disaster_ind,
        x_oprg_spec_evnt_ind                      => p_credit_rating_rec.oprg_spec_evnt_ind,
        x_other_spec_evnt_ind                     => p_credit_rating_rec.other_spec_evnt_ind,
        x_content_source_type                     => FND_API.G_MISS_CHAR,
        x_status                                  => p_credit_rating_rec.status,
        x_object_version_number                   => 1,
        x_created_by_module                       => p_credit_rating_rec.created_by_module,
        x_avg_high_credit                         => p_credit_rating_rec.avg_high_credit,
        x_credit_score                            => p_credit_rating_rec.credit_score,
        x_credit_score_age                        => p_credit_rating_rec.credit_score_age,
        x_credit_score_class                      => p_credit_rating_rec.credit_score_class,
        x_credit_score_commentary                 => p_credit_rating_rec.credit_score_commentary,
        x_credit_score_commentary2                => p_credit_rating_rec.credit_score_commentary2,
        x_credit_score_commentary3                => p_credit_rating_rec.credit_score_commentary3,
        x_credit_score_commentary4                => p_credit_rating_rec.credit_score_commentary4,
        x_credit_score_commentary5                => p_credit_rating_rec.credit_score_commentary5,
        x_credit_score_commentary6                => p_credit_rating_rec.credit_score_commentary6,
        x_credit_score_commentary7                => p_credit_rating_rec.credit_score_commentary7,
        x_credit_score_commentary8                => p_credit_rating_rec.credit_score_commentary8,
        x_credit_score_commentary9                => p_credit_rating_rec.credit_score_commentary9,
        x_credit_score_commentary10               => p_credit_rating_rec.credit_score_commentary10,
        x_credit_score_date                       => p_credit_rating_rec.credit_score_date,
        x_credit_score_incd_default               => p_credit_rating_rec.credit_score_incd_default,
        x_credit_score_natl_percentile            => p_credit_rating_rec.credit_score_natl_percentile,
        x_debarment_ind                           => p_credit_rating_rec.debarment_ind,
        x_debarments_count                        => p_credit_rating_rec.debarments_count,
        x_debarments_date                         => p_credit_rating_rec.debarments_date,
        x_high_credit                             => p_credit_rating_rec.high_credit,
        x_maximum_credit_currency_code            => p_credit_rating_rec.maximum_credit_currency_code,
        x_maximum_credit_rcmd                     => p_credit_rating_rec.maximum_credit_rcmd,
        x_paydex_norm                             => p_credit_rating_rec.paydex_norm,
        x_paydex_score                            => p_credit_rating_rec.paydex_score,
        x_paydex_three_months_ago                 => p_credit_rating_rec.paydex_three_months_ago,
        x_credit_score_override_code              => p_credit_rating_rec.credit_score_override_code,
        x_cr_scr_clas_expl                        => p_credit_rating_rec.cr_scr_clas_expl,
        x_low_rng_delq_scr                        => p_credit_rating_rec.low_rng_delq_scr,
        x_high_rng_delq_scr                       => p_credit_rating_rec.high_rng_delq_scr,
        x_delq_pmt_rng_prcnt                      => p_credit_rating_rec.delq_pmt_rng_prcnt,
        x_delq_pmt_pctg_for_all_firms             => p_credit_rating_rec.delq_pmt_pctg_for_all_firms,
        x_num_trade_experiences                   => p_credit_rating_rec.num_trade_experiences,
        x_paydex_firm_days                        => p_credit_rating_rec.paydex_firm_days,
        x_paydex_firm_comment                     => p_credit_rating_rec.paydex_firm_comment,
        x_paydex_industry_days                    => p_credit_rating_rec.paydex_industry_days,
        x_paydex_industry_comment                 => p_credit_rating_rec.paydex_industry_comment,
        x_paydex_comment                          => p_credit_rating_rec.paydex_comment,
        x_suit_ind                                => p_credit_rating_rec.suit_ind,
        x_lien_ind                                => p_credit_rating_rec.lien_ind,
        x_judgement_ind                           => p_credit_rating_rec.judgement_ind,
        x_bankruptcy_ind                          => p_credit_rating_rec.bankruptcy_ind,
        x_no_trade_ind                            => p_credit_rating_rec.no_trade_ind,
        x_prnt_hq_bkcy_ind                        => p_credit_rating_rec.prnt_hq_bkcy_ind,
        x_num_prnt_bkcy_filing                    => p_credit_rating_rec.num_prnt_bkcy_filing,
        x_prnt_bkcy_filg_type                     => p_credit_rating_rec.prnt_bkcy_filg_type,
        x_prnt_bkcy_filg_chapter                  => p_credit_rating_rec.prnt_bkcy_filg_chapter,
        x_prnt_bkcy_filg_date                     => p_credit_rating_rec.prnt_bkcy_filg_date,
        x_num_prnt_bkcy_convs                     => p_credit_rating_rec.num_prnt_bkcy_convs,
        x_prnt_bkcy_conv_date                     => p_credit_rating_rec.prnt_bkcy_conv_date,
        x_prnt_bkcy_chapter_conv                  => p_credit_rating_rec.prnt_bkcy_chapter_conv,
        x_slow_trade_expl                         => p_credit_rating_rec.slow_trade_expl,
        x_negv_pmt_expl                           => p_credit_rating_rec.negv_pmt_expl,
        x_pub_rec_expl                            => p_credit_rating_rec.pub_rec_expl,
        x_business_discontinued                   => p_credit_rating_rec.business_discontinued,
        x_spcl_event_comment                      => p_credit_rating_rec.spcl_event_comment,
        x_num_spcl_event                          => p_credit_rating_rec.num_spcl_event,
        x_spcl_event_update_date                  => p_credit_rating_rec.spcl_event_update_date,
        x_spcl_evnt_txt                           => p_credit_rating_rec.spcl_evnt_txt,
        x_failure_score                           => p_credit_rating_rec.failure_score,
        x_failure_score_age                       => p_credit_rating_rec.failure_score_age,
        x_failure_score_class                     => p_credit_rating_rec.failure_score_class,
        x_failure_score_commentary                => p_credit_rating_rec.failure_score_commentary,
        x_failure_score_commentary2               => p_credit_rating_rec.failure_score_commentary2,
        x_failure_score_commentary3               => p_credit_rating_rec.failure_score_commentary3,
        x_failure_score_commentary4               => p_credit_rating_rec.failure_score_commentary4,
        x_failure_score_commentary5               => p_credit_rating_rec.failure_score_commentary5,
        x_failure_score_commentary6               => p_credit_rating_rec.failure_score_commentary6,
        x_failure_score_commentary7               => p_credit_rating_rec.failure_score_commentary7,
        x_failure_score_commentary8               => p_credit_rating_rec.failure_score_commentary8,
        x_failure_score_commentary9               => p_credit_rating_rec.failure_score_commentary9,
        x_failure_score_commentary10              => p_credit_rating_rec.failure_score_commentary10,
        x_failure_score_date                      => p_credit_rating_rec.failure_score_date,
        x_failure_score_incd_default              => p_credit_rating_rec.failure_score_incd_default,
        x_fail_score_natnl_percentile             => p_credit_rating_rec.failure_score_natnl_percentile,
        x_failure_score_override_code             => p_credit_rating_rec.failure_score_override_code,
        x_global_failure_score                    => p_credit_rating_rec.global_failure_score,
        x_actual_content_source                   => p_credit_rating_rec.actual_content_source
    );

    -- assign the primary key back
    x_credit_rating_id := p_credit_rating_rec.credit_rating_id;

END do_create_credit_rating;


/*===========================================================================+
 | PROCEDURE
 |              do_update_credit_rating
 |
 | DESCRIPTION
 |              Updates credit rating
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_credit_rating_rec
 |                    p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_credit_rating(
    p_credit_rating_rec                 IN OUT  NOCOPY CREDIT_RATING_REC_TYPE,
    p_object_version_number             IN OUT NOCOPY  NUMBER,
    x_return_status                     IN OUT NOCOPY  VARCHAR2
) IS

    l_rowid                                     ROWID  := NULL;
    l_object_version_number                     NUMBER;
    l_party_id                                  NUMBER;
    l_description                               HZ_CREDIT_RATINGS.description%TYPE;
    l_rating                                    HZ_CREDIT_RATINGS.rating%TYPE;
    l_rated_as_of_date                          HZ_CREDIT_RATINGS.rated_as_of_date%TYPE;
    l_rating_organization                       HZ_CREDIT_RATINGS.rating_organization%TYPE;
 --  Bug 4693719 : Added for local assignment
     db_actual_content_source HZ_CREDIT_RATINGS.actual_content_source%TYPE;
     l_acs HZ_CREDIT_RATINGS.actual_content_source%TYPE;


BEGIN

    -- check whether record has been updated by another user
    BEGIN
        -- check object_version_number
        SELECT rowid, object_version_number, party_id,
               description, rating, rated_as_of_date, rating_organization
        INTO l_rowid, l_object_version_number, l_party_id,
             l_description, l_rating, l_rated_as_of_date, l_rating_organization
        FROM HZ_CREDIT_RATINGS
        WHERE credit_rating_id = p_credit_rating_rec.credit_rating_id
        FOR UPDATE NOWAIT;

        IF NOT
             (
              ( p_object_version_number IS NULL AND l_object_version_number IS NULL )
              OR
              ( p_object_version_number IS NOT NULL AND
                l_object_version_number IS NOT NULL AND
                p_object_version_number = l_object_version_number
              )
             )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_CREDIT_RATINGS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_CREDIT_RATINGS');
            FND_MESSAGE.SET_TOKEN('VALUE', NVL( TO_CHAR( p_credit_rating_rec.credit_rating_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- validate person interest record
    HZ_REGISTRY_VALIDATE_V2PUB.validate_credit_rating(
        'U',
        p_credit_rating_rec,
        l_rowid,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

 --  Bug 4693719 : pass NULL if the secure data is not updated
    IF HZ_UTILITY_V2PUB.G_UPDATE_ACS = 'Y' THEN
        l_acs := nvl(p_credit_rating_rec.actual_content_source, 'USER_ENTERED');
    ELSE
        l_acs := NULL;
    END IF;

    -- call table handler to update a row
    HZ_CREDIT_RATINGS_PKG.Update_Row (
        x_rowid                                   => l_rowid,
        x_credit_rating_id                        => p_credit_rating_rec.credit_rating_id,
        x_description                             => p_credit_rating_rec.description,
        x_party_id                                => p_credit_rating_rec.party_id,
        x_rating                                  => p_credit_rating_rec.rating,
        x_rated_as_of_date                        => p_credit_rating_rec.rated_as_of_date,
        x_rating_organization                     => p_credit_rating_rec.rating_organization,
        x_comments                                => p_credit_rating_rec.comments,
        x_det_history_ind                         => p_credit_rating_rec.det_history_ind,
        x_fincl_embt_ind                          => p_credit_rating_rec.fincl_embt_ind,
        x_criminal_proceeding_ind                 => p_credit_rating_rec.criminal_proceeding_ind,
        x_suit_judge_ind                          => FND_API.G_MISS_CHAR,
        x_claims_ind                              => p_credit_rating_rec.claims_ind,
        x_secured_flng_ind                        => p_credit_rating_rec.secured_flng_ind,
        x_fincl_lgl_event_ind                     => p_credit_rating_rec.fincl_lgl_event_ind,
        x_disaster_ind                            => p_credit_rating_rec.disaster_ind,
        x_oprg_spec_evnt_ind                      => p_credit_rating_rec.oprg_spec_evnt_ind,
        x_other_spec_evnt_ind                     => p_credit_rating_rec.other_spec_evnt_ind,
        x_content_source_type                     => FND_API.G_MISS_CHAR,
        x_status                                  => p_credit_rating_rec.status,
        x_object_version_number                   => p_object_version_number,
        x_created_by_module                       => p_credit_rating_rec.created_by_module,
        x_avg_high_credit                         => p_credit_rating_rec.avg_high_credit,
        x_credit_score                            => p_credit_rating_rec.credit_score,
        x_credit_score_age                        => p_credit_rating_rec.credit_score_age,
        x_credit_score_class                      => p_credit_rating_rec.credit_score_class,
        x_credit_score_commentary                 => p_credit_rating_rec.credit_score_commentary,
        x_credit_score_commentary2                => p_credit_rating_rec.credit_score_commentary2,
        x_credit_score_commentary3                => p_credit_rating_rec.credit_score_commentary3,
        x_credit_score_commentary4                => p_credit_rating_rec.credit_score_commentary4,
        x_credit_score_commentary5                => p_credit_rating_rec.credit_score_commentary5,
        x_credit_score_commentary6                => p_credit_rating_rec.credit_score_commentary6,
        x_credit_score_commentary7                => p_credit_rating_rec.credit_score_commentary7,
        x_credit_score_commentary8                => p_credit_rating_rec.credit_score_commentary8,
        x_credit_score_commentary9                => p_credit_rating_rec.credit_score_commentary9,
        x_credit_score_commentary10               => p_credit_rating_rec.credit_score_commentary10,
        x_credit_score_date                       => p_credit_rating_rec.credit_score_date,
        x_credit_score_incd_default               => p_credit_rating_rec.credit_score_incd_default,
        x_credit_score_natl_percentile            => p_credit_rating_rec.credit_score_natl_percentile,
        x_debarment_ind                           => p_credit_rating_rec.debarment_ind,
        x_debarments_count                        => p_credit_rating_rec.debarments_count,
        x_debarments_date                         => p_credit_rating_rec.debarments_date,
        x_high_credit                             => p_credit_rating_rec.high_credit,
        x_maximum_credit_currency_code            => p_credit_rating_rec.maximum_credit_currency_code,
        x_maximum_credit_rcmd                     => p_credit_rating_rec.maximum_credit_rcmd,
        x_paydex_norm                             => p_credit_rating_rec.paydex_norm,
        x_paydex_score                            => p_credit_rating_rec.paydex_score,
        x_paydex_three_months_ago                 => p_credit_rating_rec.paydex_three_months_ago,
        x_credit_score_override_code              => p_credit_rating_rec.credit_score_override_code,
        x_cr_scr_clas_expl                        => p_credit_rating_rec.cr_scr_clas_expl,
        x_low_rng_delq_scr                        => p_credit_rating_rec.low_rng_delq_scr,
        x_high_rng_delq_scr                       => p_credit_rating_rec.high_rng_delq_scr,
        x_delq_pmt_rng_prcnt                      => p_credit_rating_rec.delq_pmt_rng_prcnt,
        x_delq_pmt_pctg_for_all_firms             => p_credit_rating_rec.delq_pmt_pctg_for_all_firms,
        x_num_trade_experiences                   => p_credit_rating_rec.num_trade_experiences,
        x_paydex_firm_days                        => p_credit_rating_rec.paydex_firm_days,
        x_paydex_firm_comment                     => p_credit_rating_rec.paydex_firm_comment,
        x_paydex_industry_days                    => p_credit_rating_rec.paydex_industry_days,
        x_paydex_industry_comment                 => p_credit_rating_rec.paydex_industry_comment,
        x_paydex_comment                          => p_credit_rating_rec.paydex_comment,
        x_suit_ind                                => p_credit_rating_rec.suit_ind,
        x_lien_ind                                => p_credit_rating_rec.lien_ind,
        x_judgement_ind                           => p_credit_rating_rec.judgement_ind,
        x_bankruptcy_ind                          => p_credit_rating_rec.bankruptcy_ind,
        x_no_trade_ind                            => p_credit_rating_rec.no_trade_ind,
        x_prnt_hq_bkcy_ind                        => p_credit_rating_rec.prnt_hq_bkcy_ind,
        x_num_prnt_bkcy_filing                    => p_credit_rating_rec.num_prnt_bkcy_filing,
        x_prnt_bkcy_filg_type                     => p_credit_rating_rec.prnt_bkcy_filg_type,
        x_prnt_bkcy_filg_chapter                  => p_credit_rating_rec.prnt_bkcy_filg_chapter,
        x_prnt_bkcy_filg_date                     => p_credit_rating_rec.prnt_bkcy_filg_date,
        x_num_prnt_bkcy_convs                     => p_credit_rating_rec.num_prnt_bkcy_convs,
        x_prnt_bkcy_conv_date                     => p_credit_rating_rec.prnt_bkcy_conv_date,
        x_prnt_bkcy_chapter_conv                  => p_credit_rating_rec.prnt_bkcy_chapter_conv,
        x_slow_trade_expl                         => p_credit_rating_rec.slow_trade_expl,
        x_negv_pmt_expl                           => p_credit_rating_rec.negv_pmt_expl,
        x_pub_rec_expl                            => p_credit_rating_rec.pub_rec_expl,
        x_business_discontinued                   => p_credit_rating_rec.business_discontinued,
        x_spcl_event_comment                      => p_credit_rating_rec.spcl_event_comment,
        x_num_spcl_event                          => p_credit_rating_rec.num_spcl_event,
        x_spcl_event_update_date                  => p_credit_rating_rec.spcl_event_update_date,
        x_spcl_evnt_txt                           => p_credit_rating_rec.spcl_evnt_txt,
        x_failure_score                           => p_credit_rating_rec.failure_score,
        x_failure_score_age                       => p_credit_rating_rec.failure_score_age,
        x_failure_score_class                     => p_credit_rating_rec.failure_score_class,
        x_failure_score_commentary                => p_credit_rating_rec.failure_score_commentary,
        x_failure_score_commentary2               => p_credit_rating_rec.failure_score_commentary2,
        x_failure_score_commentary3               => p_credit_rating_rec.failure_score_commentary3,
        x_failure_score_commentary4               => p_credit_rating_rec.failure_score_commentary4,
        x_failure_score_commentary5               => p_credit_rating_rec.failure_score_commentary5,
        x_failure_score_commentary6               => p_credit_rating_rec.failure_score_commentary6,
        x_failure_score_commentary7               => p_credit_rating_rec.failure_score_commentary7,
        x_failure_score_commentary8               => p_credit_rating_rec.failure_score_commentary8,
        x_failure_score_commentary9               => p_credit_rating_rec.failure_score_commentary9,
        x_failure_score_commentary10              => p_credit_rating_rec.failure_score_commentary10,
        x_failure_score_date                      => p_credit_rating_rec.failure_score_date,
        x_failure_score_incd_default              => p_credit_rating_rec.failure_score_incd_default,
        x_fail_score_natnl_percentile             => p_credit_rating_rec.failure_score_natnl_percentile,
        x_failure_score_override_code             => p_credit_rating_rec.failure_score_override_code,
        x_global_failure_score                    => p_credit_rating_rec.global_failure_score,
        x_actual_content_source                   => l_acs
    );

END do_update_credit_rating;

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_credit_rating
 *
 * DESCRIPTION
 *     Creates credit rating.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.create_credit_rating_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_credit_rating_rec            Credit rating record.
 *   IN/OUT:
 *   OUT:
 *     credit_rating_id               Credit rating Id.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 * *   27-JAN-2003   Sreedhar Mohan        o Created.
 *     22-MAR-2005   Rajib Ranjan Borah    o Bug 4222898. Added the check for user
 *                                           creation privilege by checking against
 *                                           the user-creation rules.
 *
 */

PROCEDURE create_credit_rating(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_credit_rating_rec                     IN      CREDIT_RATING_REC_TYPE,
    x_credit_rating_id                      OUT NOCOPY     NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_api_name                       CONSTANT     VARCHAR2(30) := 'create_credit_rating';
    l_credit_rating_rec                           CREDIT_RATING_REC_TYPE := p_credit_rating_rec;
    dummy_content_source_type         VARCHAR2(30);
    dummy_entity_attr_id              NUMBER;
    dummy_is_datasource_selected      VARCHAR2(1);
BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_credit_rating;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Bug 4222898
    HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation (
      p_entity_name                    => 'HZ_CREDIT_RATINGS',
      p_entity_attr_id                 => dummy_entity_attr_id,
      p_mixnmatch_enabled              => NULL,
      p_selected_datasources           => NULL,
      p_content_source_type            => dummy_content_source_type,
      p_actual_content_source          => l_credit_rating_rec.actual_content_source,
      x_is_datasource_selected         => dummy_is_datasource_selected,
      x_return_status                  => x_return_status,
      p_api_version                    => 'V2');


    -- Call to business logic.
    do_create_credit_rating(
        l_credit_rating_rec,
        x_credit_rating_id,
        x_return_status);


   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       HZ_BUSINESS_EVENT_V2PVT.create_credit_ratings_event(l_credit_rating_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_credit_ratings(
         p_operation        => 'I',
         p_credit_rating_id => x_credit_rating_id);
     END IF;
   END IF;


    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_credit_rating;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_credit_rating;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_credit_rating;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

END create_credit_rating;

/**
 * PROCEDURE update_credit_rating
 *
 * DESCRIPTION
 *     Updates credit rating.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_BUSINESS_EVENT_V2PVT.update_credit_rating_event
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_credit_rating_rec            Credit rating record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 * *   27-JAN-2003   Sreedhar Mohan        o Created.
 *
 */

PROCEDURE  update_credit_rating(
    p_init_msg_list                         IN      VARCHAR2:= FND_API.G_FALSE,
    p_credit_rating_rec                     IN      CREDIT_RATING_REC_TYPE,
    p_object_version_number                 IN OUT NOCOPY  NUMBER,
    x_return_status                         OUT NOCOPY     VARCHAR2,
    x_msg_count                             OUT NOCOPY     NUMBER,
    x_msg_data                              OUT NOCOPY     VARCHAR2
) IS

    l_api_name                       CONSTANT     VARCHAR2(30) := 'update_credit_rating';
    l_credit_rating_rec                           CREDIT_RATING_REC_TYPE := p_credit_rating_rec;
    l_old_credit_rating_rec                       CREDIT_RATING_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_credit_rating;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_credit_rating_rec (
     p_credit_rating_id           => p_credit_rating_rec.credit_rating_id,
     x_credit_rating_rec          => l_old_credit_rating_rec,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call to business logic.
    do_update_credit_rating(
        l_credit_rating_rec,
        p_object_version_number,
        x_return_status);


   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Invoke business event system.
      --Bug 2979651: Since 2907261 made to HZ.K, keeping back the changes of 115.4 version.
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       HZ_BUSINESS_EVENT_V2PVT.update_credit_ratings_event(
         l_credit_rating_rec,
         l_old_credit_rating_rec );
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_credit_ratings(
         p_operation        => 'U',
         p_credit_rating_id => l_credit_rating_rec.credit_rating_id);
     END IF;
   END IF;
HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_credit_rating;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_credit_rating;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_credit_rating;
        HZ_UTILITY_V2PUB.G_UPDATE_ACS := NULL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

END update_credit_rating;

/**
 * PROCEDURE get_credit_rating_rec
 *
 * DESCRIPTION
 *     Gets credit rating record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_CREDIT_RATINGS_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_credit_rating_id             Credit rating Id.
 *   IN/OUT:
 *   OUT:
 *     x_credit_rating_rec            Returned credit rating record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   01-23-2001    Sreedhar Mohan        o Created.
 *
 */

PROCEDURE get_credit_rating_rec (
    p_init_msg_list                         IN          VARCHAR2 := FND_API.G_FALSE,
    p_credit_rating_id                      IN          NUMBER,
    x_credit_rating_rec                     OUT NOCOPY  CREDIT_RATING_REC_TYPE,
    x_return_status                         OUT NOCOPY  VARCHAR2,
    x_msg_count                             OUT NOCOPY  NUMBER,
    x_msg_data                              OUT NOCOPY  VARCHAR2
) IS

    l_api_name                              CONSTANT VARCHAR2(30) := 'get_credit_rating_rec';

BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_credit_rating_id IS NULL OR
       p_credit_rating_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'credit_rating_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- The x_credit_rating_rec.credit_rating_id must be initiated to p_credit_rating_id
    x_credit_rating_rec.credit_rating_id := p_credit_rating_id;

    HZ_CREDIT_RATINGS_PKG.Select_Row (
         x_credit_rating_id                       => x_credit_rating_rec.credit_rating_id,
         x_description                            => x_credit_rating_rec.description,
         x_party_id                               => x_credit_rating_rec.party_id,
         x_rating                                 => x_credit_rating_rec.rating,
         x_rated_as_of_date                       => x_credit_rating_rec.rated_as_of_date,
         x_rating_organization                    => x_credit_rating_rec.rating_organization,
         x_comments                               => x_credit_rating_rec.comments,
         x_det_history_ind                        => x_credit_rating_rec.det_history_ind,
         x_fincl_embt_ind                         => x_credit_rating_rec.fincl_embt_ind,
         x_criminal_proceeding_ind                => x_credit_rating_rec.criminal_proceeding_ind,
         x_claims_ind                             => x_credit_rating_rec.claims_ind,
         x_secured_flng_ind                       => x_credit_rating_rec.secured_flng_ind,
         x_fincl_lgl_event_ind                    => x_credit_rating_rec.fincl_lgl_event_ind,
         x_disaster_ind                           => x_credit_rating_rec.disaster_ind,
         x_oprg_spec_evnt_ind                     => x_credit_rating_rec.oprg_spec_evnt_ind,
         x_other_spec_evnt_ind                    => x_credit_rating_rec.other_spec_evnt_ind,
         x_status                                 => x_credit_rating_rec.status,
         x_created_by_module                      => x_credit_rating_rec.created_by_module,
         x_avg_high_credit                        => x_credit_rating_rec.avg_high_credit,
         x_credit_score                           => x_credit_rating_rec.credit_score,
         x_credit_score_age                       => x_credit_rating_rec.credit_score_age,
         x_credit_score_class                     => x_credit_rating_rec.credit_score_class,
         x_credit_score_commentary                => x_credit_rating_rec.credit_score_commentary,
         x_credit_score_commentary2               => x_credit_rating_rec.credit_score_commentary2,
         x_credit_score_commentary3               => x_credit_rating_rec.credit_score_commentary3,
         x_credit_score_commentary4               => x_credit_rating_rec.credit_score_commentary4,
         x_credit_score_commentary5               => x_credit_rating_rec.credit_score_commentary5,
         x_credit_score_commentary6               => x_credit_rating_rec.credit_score_commentary6,
         x_credit_score_commentary7               => x_credit_rating_rec.credit_score_commentary7,
         x_credit_score_commentary8               => x_credit_rating_rec.credit_score_commentary8,
         x_credit_score_commentary9               => x_credit_rating_rec.credit_score_commentary9,
         x_credit_score_commentary10              => x_credit_rating_rec.credit_score_commentary10,
         x_credit_score_date                      => x_credit_rating_rec.credit_score_date,
         x_credit_score_incd_default              => x_credit_rating_rec.credit_score_incd_default,
         x_credit_score_natl_percentile           => x_credit_rating_rec.credit_score_natl_percentile,
         x_debarment_ind                          => x_credit_rating_rec.debarment_ind,
         x_debarments_count                       => x_credit_rating_rec.debarments_count,
         x_debarments_date                        => x_credit_rating_rec.debarments_date,
         x_high_credit                            => x_credit_rating_rec.high_credit,
         x_maximum_credit_currency_code           => x_credit_rating_rec.maximum_credit_currency_code,
         x_maximum_credit_rcmd                    => x_credit_rating_rec.maximum_credit_rcmd,
         x_paydex_norm                            => x_credit_rating_rec.paydex_norm,
         x_paydex_score                           => x_credit_rating_rec.paydex_score,
         x_paydex_three_months_ago                => x_credit_rating_rec.paydex_three_months_ago,
         x_credit_score_override_code             => x_credit_rating_rec.credit_score_override_code,
         x_cr_scr_clas_expl                       => x_credit_rating_rec.cr_scr_clas_expl,
         x_low_rng_delq_scr                       => x_credit_rating_rec.low_rng_delq_scr,
         x_high_rng_delq_scr                      => x_credit_rating_rec.high_rng_delq_scr,
         x_delq_pmt_rng_prcnt                     => x_credit_rating_rec.delq_pmt_rng_prcnt,
         x_delq_pmt_pctg_for_all_firms            => x_credit_rating_rec.delq_pmt_pctg_for_all_firms,
         x_num_trade_experiences                  => x_credit_rating_rec.num_trade_experiences,
         x_paydex_firm_days                       => x_credit_rating_rec.paydex_firm_days,
         x_paydex_firm_comment                    => x_credit_rating_rec.paydex_firm_comment,
         x_paydex_industry_days                   => x_credit_rating_rec.paydex_industry_days,
         x_paydex_industry_comment                => x_credit_rating_rec.paydex_industry_comment,
         x_paydex_comment                         => x_credit_rating_rec.paydex_comment,
         x_suit_ind                               => x_credit_rating_rec.suit_ind,
         x_lien_ind                               => x_credit_rating_rec.lien_ind,
         x_judgement_ind                          => x_credit_rating_rec.judgement_ind,
         x_bankruptcy_ind                         => x_credit_rating_rec.bankruptcy_ind,
         x_no_trade_ind                           => x_credit_rating_rec.no_trade_ind,
         x_prnt_hq_bkcy_ind                       => x_credit_rating_rec.prnt_hq_bkcy_ind,
         x_num_prnt_bkcy_filing                   => x_credit_rating_rec.num_prnt_bkcy_filing,
         x_prnt_bkcy_filg_type                    => x_credit_rating_rec.prnt_bkcy_filg_type,
         x_prnt_bkcy_filg_chapter                 => x_credit_rating_rec.prnt_bkcy_filg_chapter,
         x_prnt_bkcy_filg_date                    => x_credit_rating_rec.prnt_bkcy_filg_date,
         x_num_prnt_bkcy_convs                    => x_credit_rating_rec.num_prnt_bkcy_convs,
         x_prnt_bkcy_conv_date                    => x_credit_rating_rec.prnt_bkcy_conv_date,
         x_prnt_bkcy_chapter_conv                 => x_credit_rating_rec.prnt_bkcy_chapter_conv,
         x_slow_trade_expl                        => x_credit_rating_rec.slow_trade_expl,
         x_negv_pmt_expl                          => x_credit_rating_rec.negv_pmt_expl,
         x_pub_rec_expl                           => x_credit_rating_rec.pub_rec_expl,
         x_business_discontinued                  => x_credit_rating_rec.business_discontinued,
         x_spcl_event_comment                     => x_credit_rating_rec.spcl_event_comment,
         x_num_spcl_event                         => x_credit_rating_rec.num_spcl_event,
         x_spcl_event_update_date                 => x_credit_rating_rec.spcl_event_update_date,
         x_spcl_evnt_txt                          => x_credit_rating_rec.spcl_evnt_txt,
         x_failure_score                          => x_credit_rating_rec.failure_score,
         x_failure_score_age                      => x_credit_rating_rec.failure_score_age,
         x_failure_score_class                    => x_credit_rating_rec.failure_score_class,
         x_failure_score_commentary               => x_credit_rating_rec.failure_score_commentary,
         x_failure_score_commentary2              => x_credit_rating_rec.failure_score_commentary2,
         x_failure_score_commentary3              => x_credit_rating_rec.failure_score_commentary3,
         x_failure_score_commentary4              => x_credit_rating_rec.failure_score_commentary4,
         x_failure_score_commentary5              => x_credit_rating_rec.failure_score_commentary5,
         x_failure_score_commentary6              => x_credit_rating_rec.failure_score_commentary6,
         x_failure_score_commentary7              => x_credit_rating_rec.failure_score_commentary7,
         x_failure_score_commentary8              => x_credit_rating_rec.failure_score_commentary8,
         x_failure_score_commentary9              => x_credit_rating_rec.failure_score_commentary9,
         x_failure_score_commentary10             => x_credit_rating_rec.failure_score_commentary10,
         x_failure_score_date                     => x_credit_rating_rec.failure_score_date,
         x_failure_score_incd_default             => x_credit_rating_rec.failure_score_incd_default,
         x_fail_score_natnl_percentile            => x_credit_rating_rec.failure_score_natnl_percentile,
         x_failure_score_override_code            => x_credit_rating_rec.failure_score_override_code,
         x_global_failure_score                   => x_credit_rating_rec.global_failure_score,
         x_actual_content_source                  => x_credit_rating_rec.actual_content_source
    );

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_credit_rating_rec;

END HZ_PARTY_INFO_V2PUB;

/
