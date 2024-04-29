--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_INFO_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_INFO_V2PVT" AS
/*$Header: ARHPRI1B.pls 120.1 2005/06/16 21:14:30 jhuang noship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

DEFAULT_CREATED_BY_MODULE              VARCHAR2(10) := 'TCA_V1_API';
x_msg_count                            NUMBER;
x_msg_data                             VARCHAR2(2000);

--------------------------------------
-- private procedures and functions
--------------------------------------

PROCEDURE v2_credit_rating_pre (
    p_create_update_flag                    IN         VARCHAR2,
    p_credit_rating_rec                     IN         HZ_PARTY_INFO_PUB.CREDIT_RATINGS_REC_TYPE,
    x_credit_rating_rec                     OUT NOCOPY HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE
) IS

BEGIN

        IF p_credit_rating_rec.credit_rating_id IS NULL THEN
            x_credit_rating_rec.credit_rating_id := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.credit_rating_id <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.credit_rating_id := p_credit_rating_rec.credit_rating_id;
        END IF;

        IF p_credit_rating_rec.description IS NULL THEN
            x_credit_rating_rec.description := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.description <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.description := p_credit_rating_rec.description;
        END IF;

        IF p_credit_rating_rec.party_id IS NULL THEN
            x_credit_rating_rec.party_id := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.party_id <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.party_id := p_credit_rating_rec.party_id;
        END IF;

        IF p_credit_rating_rec.rating IS NULL THEN
            x_credit_rating_rec.rating := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.rating <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.rating := p_credit_rating_rec.rating;
        END IF;

        IF p_credit_rating_rec.rated_as_of_date IS NULL THEN
            x_credit_rating_rec.rated_as_of_date := FND_API.G_MISS_DATE;
        ELSIF p_credit_rating_rec.rated_as_of_date <> FND_API.G_MISS_DATE THEN
            x_credit_rating_rec.rated_as_of_date := p_credit_rating_rec.rated_as_of_date;
        END IF;

        IF p_credit_rating_rec.rating_organization IS NULL THEN
            x_credit_rating_rec.rating_organization := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.rating_organization <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.rating_organization := p_credit_rating_rec.rating_organization;
        END IF;

        IF p_credit_rating_rec.comments IS NULL THEN
            x_credit_rating_rec.comments := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.comments <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.comments := p_credit_rating_rec.comments;
        END IF;

        IF p_credit_rating_rec.det_history_ind IS NULL THEN
            x_credit_rating_rec.det_history_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.det_history_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.det_history_ind := p_credit_rating_rec.det_history_ind;
        END IF;

        IF p_credit_rating_rec.fincl_embt_ind IS NULL THEN
            x_credit_rating_rec.fincl_embt_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.fincl_embt_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.fincl_embt_ind := p_credit_rating_rec.fincl_embt_ind;
        END IF;

        IF p_credit_rating_rec.criminal_proceeding_ind IS NULL THEN
            x_credit_rating_rec.criminal_proceeding_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.criminal_proceeding_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.criminal_proceeding_ind := p_credit_rating_rec.criminal_proceeding_ind;
        END IF;

        IF p_credit_rating_rec.claims_ind IS NULL THEN
            x_credit_rating_rec.claims_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.claims_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.claims_ind := p_credit_rating_rec.claims_ind;
        END IF;

        IF p_credit_rating_rec.secured_flng_ind IS NULL THEN
            x_credit_rating_rec.secured_flng_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.secured_flng_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.secured_flng_ind := p_credit_rating_rec.secured_flng_ind;
        END IF;

        IF p_credit_rating_rec.fincl_lgl_event_ind IS NULL THEN
            x_credit_rating_rec.fincl_lgl_event_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.fincl_lgl_event_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.fincl_lgl_event_ind := p_credit_rating_rec.fincl_lgl_event_ind;
        END IF;

        IF p_credit_rating_rec.disaster_ind IS NULL THEN
            x_credit_rating_rec.disaster_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.disaster_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.disaster_ind := p_credit_rating_rec.disaster_ind;
        END IF;

        IF p_credit_rating_rec.oprg_spec_evnt_ind IS NULL THEN
            x_credit_rating_rec.oprg_spec_evnt_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.oprg_spec_evnt_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.oprg_spec_evnt_ind := p_credit_rating_rec.oprg_spec_evnt_ind;
        END IF;

        IF p_credit_rating_rec.other_spec_evnt_ind IS NULL THEN
            x_credit_rating_rec.other_spec_evnt_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.other_spec_evnt_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.other_spec_evnt_ind := p_credit_rating_rec.other_spec_evnt_ind;
        END IF;

        IF p_credit_rating_rec.status IS NULL THEN
            x_credit_rating_rec.status := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.status <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.status := p_credit_rating_rec.status;
        END IF;

        IF p_credit_rating_rec.avg_high_credit IS NULL THEN
            x_credit_rating_rec.avg_high_credit := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.avg_high_credit <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.avg_high_credit := p_credit_rating_rec.avg_high_credit;
        END IF;

        IF p_credit_rating_rec.credit_score IS NULL THEN
            x_credit_rating_rec.credit_score := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score := p_credit_rating_rec.credit_score;
        END IF;

        IF p_credit_rating_rec.credit_score_age IS NULL THEN
            x_credit_rating_rec.credit_score_age := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.credit_score_age <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.credit_score_age := p_credit_rating_rec.credit_score_age;
        END IF;

        IF p_credit_rating_rec.credit_score_class IS NULL THEN
            x_credit_rating_rec.credit_score_class := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.credit_score_class <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.credit_score_class := p_credit_rating_rec.credit_score_class;
        END IF;

        IF p_credit_rating_rec.credit_score_commentary IS NULL THEN
            x_credit_rating_rec.credit_score_commentary := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_commentary <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_commentary := p_credit_rating_rec.credit_score_commentary;
        END IF;

        IF p_credit_rating_rec.credit_score_commentary2 IS NULL THEN
            x_credit_rating_rec.credit_score_commentary2 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_commentary2 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_commentary2 := p_credit_rating_rec.credit_score_commentary2;
        END IF;

        IF p_credit_rating_rec.credit_score_commentary3 IS NULL THEN
            x_credit_rating_rec.credit_score_commentary3 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_commentary3 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_commentary3 := p_credit_rating_rec.credit_score_commentary3;
        END IF;

        IF p_credit_rating_rec.credit_score_commentary4 IS NULL THEN
            x_credit_rating_rec.credit_score_commentary4 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_commentary4 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_commentary4 := p_credit_rating_rec.credit_score_commentary4;
        END IF;

        IF p_credit_rating_rec.credit_score_commentary5 IS NULL THEN
            x_credit_rating_rec.credit_score_commentary5 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_commentary5 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_commentary5 := p_credit_rating_rec.credit_score_commentary5;
        END IF;

        IF p_credit_rating_rec.credit_score_commentary6 IS NULL THEN
            x_credit_rating_rec.credit_score_commentary6 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_commentary6 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_commentary6 := p_credit_rating_rec.credit_score_commentary6;
        END IF;

        IF p_credit_rating_rec.credit_score_commentary7 IS NULL THEN
            x_credit_rating_rec.credit_score_commentary7 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_commentary7 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_commentary7 := p_credit_rating_rec.credit_score_commentary7;
        END IF;

        IF p_credit_rating_rec.credit_score_commentary8 IS NULL THEN
            x_credit_rating_rec.credit_score_commentary8 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_commentary8 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_commentary8 := p_credit_rating_rec.credit_score_commentary8;
        END IF;

        IF p_credit_rating_rec.credit_score_commentary9 IS NULL THEN
            x_credit_rating_rec.credit_score_commentary9 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_commentary9 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_commentary9 := p_credit_rating_rec.credit_score_commentary9;
        END IF;

        IF p_credit_rating_rec.credit_score_commentary10 IS NULL THEN
            x_credit_rating_rec.credit_score_commentary10 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_commentary10 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_commentary10 := p_credit_rating_rec.credit_score_commentary10;
        END IF;

        IF p_credit_rating_rec.credit_score_date IS NULL THEN
            x_credit_rating_rec.credit_score_date := FND_API.G_MISS_DATE;
        ELSIF p_credit_rating_rec.credit_score_date <> FND_API.G_MISS_DATE THEN
            x_credit_rating_rec.credit_score_date := p_credit_rating_rec.credit_score_date;
        END IF;

        IF p_credit_rating_rec.credit_score_incd_default IS NULL THEN
            x_credit_rating_rec.credit_score_incd_default := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.credit_score_incd_default <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.credit_score_incd_default := p_credit_rating_rec.credit_score_incd_default;
        END IF;

        IF p_credit_rating_rec.credit_score_natl_percentile IS NULL THEN
            x_credit_rating_rec.credit_score_natl_percentile := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.credit_score_natl_percentile <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.credit_score_natl_percentile := p_credit_rating_rec.credit_score_natl_percentile;
        END IF;

        IF p_credit_rating_rec.failure_score IS NULL THEN
            x_credit_rating_rec.failure_score := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score := p_credit_rating_rec.failure_score;
        END IF;

        IF p_credit_rating_rec.failure_score_age IS NULL THEN
            x_credit_rating_rec.failure_score_age := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.failure_score_age <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.failure_score_age := p_credit_rating_rec.failure_score_age;
        END IF;

        IF p_credit_rating_rec.failure_score_class IS NULL THEN
            x_credit_rating_rec.failure_score_class := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.failure_score_class <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.failure_score_class := p_credit_rating_rec.failure_score_class;
        END IF;

        IF p_credit_rating_rec.failure_score_commentary IS NULL THEN
            x_credit_rating_rec.failure_score_commentary := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_commentary <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_commentary := p_credit_rating_rec.failure_score_commentary;
        END IF;

        IF p_credit_rating_rec.failure_score_commentary2 IS NULL THEN
            x_credit_rating_rec.failure_score_commentary2 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_commentary2 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_commentary2 := p_credit_rating_rec.failure_score_commentary2;
        END IF;

        IF p_credit_rating_rec.failure_score_commentary3 IS NULL THEN
            x_credit_rating_rec.failure_score_commentary3 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_commentary3 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_commentary3 := p_credit_rating_rec.failure_score_commentary3;
        END IF;

        IF p_credit_rating_rec.failure_score_commentary4 IS NULL THEN
            x_credit_rating_rec.failure_score_commentary4 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_commentary4 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_commentary4 := p_credit_rating_rec.failure_score_commentary4;
        END IF;

        IF p_credit_rating_rec.failure_score_commentary5 IS NULL THEN
            x_credit_rating_rec.failure_score_commentary5 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_commentary5 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_commentary5 := p_credit_rating_rec.failure_score_commentary5;
        END IF;

        IF p_credit_rating_rec.failure_score_commentary6 IS NULL THEN
            x_credit_rating_rec.failure_score_commentary6 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_commentary6 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_commentary6 := p_credit_rating_rec.failure_score_commentary6;
        END IF;

        IF p_credit_rating_rec.failure_score_commentary7 IS NULL THEN
            x_credit_rating_rec.failure_score_commentary7 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_commentary7 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_commentary7 := p_credit_rating_rec.failure_score_commentary7;
        END IF;

        IF p_credit_rating_rec.failure_score_commentary8 IS NULL THEN
            x_credit_rating_rec.failure_score_commentary8 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_commentary8 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_commentary8 := p_credit_rating_rec.failure_score_commentary8;
        END IF;

        IF p_credit_rating_rec.failure_score_commentary9 IS NULL THEN
            x_credit_rating_rec.failure_score_commentary9 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_commentary9 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_commentary9 := p_credit_rating_rec.failure_score_commentary9;
        END IF;

        IF p_credit_rating_rec.failure_score_commentary10 IS NULL THEN
            x_credit_rating_rec.failure_score_commentary10 := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_commentary10 <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_commentary10 := p_credit_rating_rec.failure_score_commentary10;
        END IF;

        IF p_credit_rating_rec.failure_score_date IS NULL THEN
            x_credit_rating_rec.failure_score_date := FND_API.G_MISS_DATE;
        ELSIF p_credit_rating_rec.failure_score_date <> FND_API.G_MISS_DATE THEN
            x_credit_rating_rec.failure_score_date := p_credit_rating_rec.failure_score_date;
        END IF;

        IF p_credit_rating_rec.failure_score_incd_default IS NULL THEN
            x_credit_rating_rec.failure_score_incd_default := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.failure_score_incd_default <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.failure_score_incd_default := p_credit_rating_rec.failure_score_incd_default;
        END IF;

        IF p_credit_rating_rec.failure_score_natnl_percentile IS NULL THEN
            x_credit_rating_rec.failure_score_natnl_percentile := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.failure_score_natnl_percentile <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.failure_score_natnl_percentile := p_credit_rating_rec.failure_score_natnl_percentile;
        END IF;

        IF p_credit_rating_rec.failure_score_override_code IS NULL THEN
            x_credit_rating_rec.failure_score_override_code := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.failure_score_override_code <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.failure_score_override_code := p_credit_rating_rec.failure_score_override_code;
        END IF;

        IF p_credit_rating_rec.global_failure_score IS NULL THEN
            x_credit_rating_rec.global_failure_score := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.global_failure_score <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.global_failure_score := p_credit_rating_rec.global_failure_score;
        END IF;

        IF p_credit_rating_rec.debarment_ind IS NULL THEN
            x_credit_rating_rec.debarment_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.debarment_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.debarment_ind := p_credit_rating_rec.debarment_ind;
        END IF;

        IF p_credit_rating_rec.debarments_count IS NULL THEN
            x_credit_rating_rec.debarments_count := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.debarments_count <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.debarments_count := p_credit_rating_rec.debarments_count;
        END IF;

        IF p_credit_rating_rec.debarments_date IS NULL THEN
            x_credit_rating_rec.debarments_date := FND_API.G_MISS_DATE;
        ELSIF p_credit_rating_rec.debarments_date <> FND_API.G_MISS_DATE THEN
            x_credit_rating_rec.debarments_date := p_credit_rating_rec.debarments_date;
        END IF;

        IF p_credit_rating_rec.high_credit IS NULL THEN
            x_credit_rating_rec.high_credit := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.high_credit <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.high_credit := p_credit_rating_rec.high_credit;
        END IF;

        IF p_credit_rating_rec.maximum_credit_currency_code IS NULL THEN
            x_credit_rating_rec.maximum_credit_currency_code := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.maximum_credit_currency_code <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.maximum_credit_currency_code := p_credit_rating_rec.maximum_credit_currency_code;
        END IF;

        IF p_credit_rating_rec.maximum_credit_rcmd IS NULL THEN
            x_credit_rating_rec.maximum_credit_rcmd := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.maximum_credit_rcmd <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.maximum_credit_rcmd := p_credit_rating_rec.maximum_credit_rcmd;
        END IF;

        IF p_credit_rating_rec.paydex_norm IS NULL THEN
            x_credit_rating_rec.paydex_norm := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.paydex_norm <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.paydex_norm := p_credit_rating_rec.paydex_norm;
        END IF;

        IF p_credit_rating_rec.paydex_score IS NULL THEN
            x_credit_rating_rec.paydex_score := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.paydex_score <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.paydex_score := p_credit_rating_rec.paydex_score;
        END IF;

        IF p_credit_rating_rec.paydex_three_months_ago IS NULL THEN
            x_credit_rating_rec.paydex_three_months_ago := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.paydex_three_months_ago <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.paydex_three_months_ago := p_credit_rating_rec.paydex_three_months_ago;
        END IF;

        IF p_credit_rating_rec.credit_score_override_code IS NULL THEN
            x_credit_rating_rec.credit_score_override_code := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.credit_score_override_code <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.credit_score_override_code := p_credit_rating_rec.credit_score_override_code;
        END IF;

        IF p_credit_rating_rec.cr_scr_clas_expl IS NULL THEN
            x_credit_rating_rec.cr_scr_clas_expl := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.cr_scr_clas_expl <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.cr_scr_clas_expl := p_credit_rating_rec.cr_scr_clas_expl;
        END IF;

        IF p_credit_rating_rec.low_rng_delq_scr IS NULL THEN
            x_credit_rating_rec.low_rng_delq_scr := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.low_rng_delq_scr <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.low_rng_delq_scr := p_credit_rating_rec.low_rng_delq_scr;
        END IF;

        IF p_credit_rating_rec.high_rng_delq_scr IS NULL THEN
            x_credit_rating_rec.high_rng_delq_scr := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.high_rng_delq_scr <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.high_rng_delq_scr := p_credit_rating_rec.high_rng_delq_scr;
        END IF;

        IF p_credit_rating_rec.delq_pmt_rng_prcnt IS NULL THEN
            x_credit_rating_rec.delq_pmt_rng_prcnt := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.delq_pmt_rng_prcnt <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.delq_pmt_rng_prcnt := p_credit_rating_rec.delq_pmt_rng_prcnt;
        END IF;

        IF p_credit_rating_rec.delq_pmt_pctg_for_all_firms IS NULL THEN
            x_credit_rating_rec.delq_pmt_pctg_for_all_firms := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.delq_pmt_pctg_for_all_firms <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.delq_pmt_pctg_for_all_firms := p_credit_rating_rec.delq_pmt_pctg_for_all_firms;
        END IF;

        IF p_credit_rating_rec.num_trade_experiences IS NULL THEN
            x_credit_rating_rec.num_trade_experiences := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.num_trade_experiences <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.num_trade_experiences := p_credit_rating_rec.num_trade_experiences;
        END IF;

        IF p_credit_rating_rec.paydex_firm_days IS NULL THEN
            x_credit_rating_rec.paydex_firm_days := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.paydex_firm_days <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.paydex_firm_days := p_credit_rating_rec.paydex_firm_days;
        END IF;

        IF p_credit_rating_rec.paydex_firm_comment IS NULL THEN
            x_credit_rating_rec.paydex_firm_comment := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.paydex_firm_comment <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.paydex_firm_comment := p_credit_rating_rec.paydex_firm_comment;
        END IF;

        IF p_credit_rating_rec.paydex_industry_days IS NULL THEN
            x_credit_rating_rec.paydex_industry_days := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.paydex_industry_days <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.paydex_industry_days := p_credit_rating_rec.paydex_industry_days;
        END IF;

        IF p_credit_rating_rec.paydex_industry_comment IS NULL THEN
            x_credit_rating_rec.paydex_industry_comment := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.paydex_industry_comment <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.paydex_industry_comment := p_credit_rating_rec.paydex_industry_comment;
        END IF;

        IF p_credit_rating_rec.paydex_comment IS NULL THEN
            x_credit_rating_rec.paydex_comment := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.paydex_comment <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.paydex_comment := p_credit_rating_rec.paydex_comment;
        END IF;

        IF p_credit_rating_rec.suit_ind IS NULL THEN
            x_credit_rating_rec.suit_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.suit_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.suit_ind := p_credit_rating_rec.suit_ind;
        END IF;

        IF p_credit_rating_rec.lien_ind IS NULL THEN
            x_credit_rating_rec.lien_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.lien_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.lien_ind := p_credit_rating_rec.lien_ind;
        END IF;

        IF p_credit_rating_rec.judgement_ind IS NULL THEN
            x_credit_rating_rec.judgement_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.judgement_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.judgement_ind := p_credit_rating_rec.judgement_ind;
        END IF;

        IF p_credit_rating_rec.bankruptcy_ind IS NULL THEN
            x_credit_rating_rec.bankruptcy_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.bankruptcy_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.bankruptcy_ind := p_credit_rating_rec.bankruptcy_ind;
        END IF;

        IF p_credit_rating_rec.no_trade_ind IS NULL THEN
            x_credit_rating_rec.no_trade_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.no_trade_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.no_trade_ind := p_credit_rating_rec.no_trade_ind;
        END IF;

        IF p_credit_rating_rec.prnt_hq_bkcy_ind IS NULL THEN
            x_credit_rating_rec.prnt_hq_bkcy_ind := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.prnt_hq_bkcy_ind <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.prnt_hq_bkcy_ind := p_credit_rating_rec.prnt_hq_bkcy_ind;
        END IF;

        IF p_credit_rating_rec.num_prnt_bkcy_filing IS NULL THEN
            x_credit_rating_rec.num_prnt_bkcy_filing := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.num_prnt_bkcy_filing <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.num_prnt_bkcy_filing := p_credit_rating_rec.num_prnt_bkcy_filing;
        END IF;

        IF p_credit_rating_rec.prnt_bkcy_filg_type IS NULL THEN
            x_credit_rating_rec.prnt_bkcy_filg_type := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.prnt_bkcy_filg_type <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.prnt_bkcy_filg_type := p_credit_rating_rec.prnt_bkcy_filg_type;
        END IF;

        IF p_credit_rating_rec.prnt_bkcy_filg_chapter IS NULL THEN
            x_credit_rating_rec.prnt_bkcy_filg_chapter := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.prnt_bkcy_filg_chapter <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.prnt_bkcy_filg_chapter := p_credit_rating_rec.prnt_bkcy_filg_chapter;
        END IF;

        IF p_credit_rating_rec.prnt_bkcy_filg_date IS NULL THEN
            x_credit_rating_rec.prnt_bkcy_filg_date := FND_API.G_MISS_DATE;
        ELSIF p_credit_rating_rec.prnt_bkcy_filg_date <> FND_API.G_MISS_DATE THEN
            x_credit_rating_rec.prnt_bkcy_filg_date := p_credit_rating_rec.prnt_bkcy_filg_date;
        END IF;

        IF p_credit_rating_rec.num_prnt_bkcy_convs IS NULL THEN
            x_credit_rating_rec.num_prnt_bkcy_convs := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.num_prnt_bkcy_convs <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.num_prnt_bkcy_convs := p_credit_rating_rec.num_prnt_bkcy_convs;
        END IF;

        IF p_credit_rating_rec.prnt_bkcy_conv_date IS NULL THEN
            x_credit_rating_rec.prnt_bkcy_conv_date := FND_API.G_MISS_DATE;
        ELSIF p_credit_rating_rec.prnt_bkcy_conv_date <> FND_API.G_MISS_DATE THEN
            x_credit_rating_rec.prnt_bkcy_conv_date := p_credit_rating_rec.prnt_bkcy_conv_date;
        END IF;

        IF p_credit_rating_rec.prnt_bkcy_chapter_conv IS NULL THEN
            x_credit_rating_rec.prnt_bkcy_chapter_conv := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.prnt_bkcy_chapter_conv <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.prnt_bkcy_chapter_conv := p_credit_rating_rec.prnt_bkcy_chapter_conv;
        END IF;

        IF p_credit_rating_rec.slow_trade_expl IS NULL THEN
            x_credit_rating_rec.slow_trade_expl := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.slow_trade_expl <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.slow_trade_expl := p_credit_rating_rec.slow_trade_expl;
        END IF;

        IF p_credit_rating_rec.negv_pmt_expl IS NULL THEN
            x_credit_rating_rec.negv_pmt_expl := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.negv_pmt_expl <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.negv_pmt_expl := p_credit_rating_rec.negv_pmt_expl;
        END IF;

        IF p_credit_rating_rec.pub_rec_expl IS NULL THEN
            x_credit_rating_rec.pub_rec_expl := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.pub_rec_expl <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.pub_rec_expl := p_credit_rating_rec.pub_rec_expl;
        END IF;

        IF p_credit_rating_rec.business_discontinued IS NULL THEN
            x_credit_rating_rec.business_discontinued := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.business_discontinued <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.business_discontinued := p_credit_rating_rec.business_discontinued;
        END IF;

        IF p_credit_rating_rec.spcl_event_comment IS NULL THEN
            x_credit_rating_rec.spcl_event_comment := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.spcl_event_comment <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.spcl_event_comment := p_credit_rating_rec.spcl_event_comment;
        END IF;

        IF p_credit_rating_rec.num_spcl_event IS NULL THEN
            x_credit_rating_rec.num_spcl_event := FND_API.G_MISS_NUM;
        ELSIF p_credit_rating_rec.num_spcl_event <> FND_API.G_MISS_NUM THEN
            x_credit_rating_rec.num_spcl_event := p_credit_rating_rec.num_spcl_event;
        END IF;

        IF p_credit_rating_rec.spcl_event_update_date IS NULL THEN
            x_credit_rating_rec.spcl_event_update_date := FND_API.G_MISS_DATE;
        ELSIF p_credit_rating_rec.spcl_event_update_date <> FND_API.G_MISS_DATE THEN
            x_credit_rating_rec.spcl_event_update_date := p_credit_rating_rec.spcl_event_update_date;
        END IF;

        IF p_credit_rating_rec.spcl_evnt_txt IS NULL THEN
            x_credit_rating_rec.spcl_evnt_txt := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.spcl_evnt_txt <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.spcl_evnt_txt := p_credit_rating_rec.spcl_evnt_txt;
        END IF;

        IF p_credit_rating_rec.actual_content_source IS NULL THEN
            x_credit_rating_rec.actual_content_source := FND_API.G_MISS_CHAR;
        ELSIF p_credit_rating_rec.actual_content_source <> FND_API.G_MISS_CHAR THEN
            x_credit_rating_rec.actual_content_source := p_credit_rating_rec.actual_content_source;
        END IF;
        IF p_create_update_flag = 'C' THEN
            x_credit_rating_rec.created_by_module := DEFAULT_CREATED_BY_MODULE;
        END IF;

END v2_credit_rating_pre;

--------------------------------------------------
-- public procedures and functions
--------------------------------------------------

PROCEDURE v2_create_credit_rating (
    p_credit_rating_rec            IN     HZ_PARTY_INFO_PUB.CREDIT_RATINGS_REC_TYPE,
    x_return_status                IN OUT NOCOPY VARCHAR2,
    x_credit_rating_id                OUT NOCOPY NUMBER
) IS

    l_credit_rating_rec                   HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE;

BEGIN

    -- pre-process v1 and v2 record.
    v2_credit_rating_pre (
        'C',
        p_credit_rating_rec,
        l_credit_rating_rec );

    -- call V2 API.

    HZ_PARTY_INFO_V2PUB.create_credit_rating (
        p_credit_rating_rec                => l_credit_rating_rec,
        x_credit_rating_id                 => x_credit_rating_id,
        x_return_status                    => x_return_status,
        x_msg_count                        => x_msg_count,
        x_msg_data                         => x_msg_data );

END v2_create_credit_rating;


PROCEDURE v2_update_credit_rating (
    p_credit_rating_rec            IN     HZ_PARTY_INFO_PUB.CREDIT_RATINGS_REC_TYPE,
    p_last_update_date            IN OUT NOCOPY DATE,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

    l_credit_rating_rec                  HZ_PARTY_INFO_V2PUB.CREDIT_RATING_REC_TYPE;
    l_last_update_date                   DATE;
    l_rowid                              ROWID := NULL;
    l_object_version_number              NUMBER;

BEGIN

    -- check required fields:
    IF p_last_update_date IS NULL OR
       p_last_update_date = FND_API.G_MISS_DATE
    THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get object_version_number
    BEGIN

        SELECT ROWID, OBJECT_VERSION_NUMBER, LAST_UPDATE_DATE
        INTO l_rowid, l_object_version_number, l_last_update_date
        FROM HZ_CREDIT_RATINGS
        WHERE CREDIT_RATING_ID  = p_credit_rating_rec.credit_rating_id;

        IF TO_CHAR( p_last_update_date, 'DD-MON-YYYY HH:MI:SS') <>
           TO_CHAR( l_last_update_date, 'DD-MON-YYYY HH:MI:SS')
        THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_RECORD_CHANGED' );
            FND_MESSAGE.SET_TOKEN( 'TABLE', 'hz_credit_ratings' );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN( 'RECORD', 'credit ratings' );
            FND_MESSAGE.SET_TOKEN( 'VALUE',
                NVL( TO_CHAR( p_credit_rating_rec.credit_rating_id ), 'null' ) );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- pre-process v1 and v2 record.
    v2_credit_rating_pre (
        'U',
        p_credit_rating_rec,
        l_credit_rating_rec );

    -- call V2 API.

    HZ_PARTY_INFO_V2PUB.update_credit_rating (
        p_credit_rating_rec                 => l_credit_rating_rec,
        p_object_version_number             => l_object_version_number,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data
    );

END v2_update_credit_rating;

END HZ_PARTY_INFO_V2PVT;

/
