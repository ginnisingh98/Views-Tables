--------------------------------------------------------
--  DDL for Package HZ_PARTY_INFO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_INFO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHPTISS.pls 120.3 2005/06/24 16:03:51 sponnamb ship $ */

G_MISS_CONTENT_SOURCE_TYPE      CONSTANT VARCHAR2(30) := 'USER_ENTERED';

-------------------------------------------------------------------------
TYPE credit_ratings_rec_type IS RECORD(
credit_rating_id                NUMBER         := FND_API.G_MISS_NUM,
description                     VARCHAR2(2000) := FND_API.G_MISS_CHAR,
party_id                        NUMBER         := FND_API.G_MISS_NUM,
rating                          VARCHAR2(60)   := FND_API.G_MISS_CHAR,
rated_as_of_date                DATE           := FND_API.G_MISS_DATE,
rating_organization             VARCHAR2(240)  := FND_API.G_MISS_CHAR,
wh_update_date                  DATE           := FND_API.G_MISS_DATE,
comments                        VARCHAR2(240)  := FND_API.G_MISS_CHAR,
det_history_ind                 VARCHAR2(5)    := FND_API.G_MISS_CHAR,
fincl_embt_ind                  VARCHAR2(5)    := FND_API.G_MISS_CHAR,
criminal_proceeding_ind         VARCHAR2(5)    := FND_API.G_MISS_CHAR,
suit_judge_ind                  VARCHAR2(5)    := FND_API.G_MISS_CHAR,
claims_ind                      VARCHAR2(5)    := FND_API.G_MISS_CHAR,
secured_flng_ind                VARCHAR2(5)    := FND_API.G_MISS_CHAR,
fincl_lgl_event_ind             VARCHAR2(5)    := FND_API.G_MISS_CHAR,
disaster_ind                    VARCHAR2(5)    := FND_API.G_MISS_CHAR,
oprg_spec_evnt_ind              VARCHAR2(5)    := FND_API.G_MISS_CHAR,
other_spec_evnt_ind             VARCHAR2(5)    := FND_API.G_MISS_CHAR,
content_source_type             VARCHAR2(30)   := G_MISS_CONTENT_SOURCE_TYPE,
status                          VARCHAR2(1)    := FND_API.G_MISS_CHAR,
avg_high_credit                 NUMBER         := FND_API.G_MISS_NUM,
credit_score                    VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_age                NUMBER         := FND_API.G_MISS_NUM,
credit_score_class              NUMBER         := FND_API.G_MISS_NUM,
credit_score_commentary         VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_commentary2        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_commentary3        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_commentary4        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_commentary5        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_commentary6        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_commentary7        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_commentary8        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_commentary9        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_commentary10       VARCHAR2(30)   := FND_API.G_MISS_CHAR,
credit_score_date               DATE           := FND_API.G_MISS_DATE,
credit_score_incd_default       NUMBER         := FND_API.G_MISS_NUM,
credit_score_natl_percentile    NUMBER         := FND_API.G_MISS_NUM,
failure_score                    VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_age                NUMBER         := FND_API.G_MISS_NUM,
failure_score_class              NUMBER         := FND_API.G_MISS_NUM,
failure_score_commentary         VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_commentary2        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_commentary3        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_commentary4        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_commentary5        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_commentary6        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_commentary7        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_commentary8        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_commentary9        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_commentary10       VARCHAR2(30)   := FND_API.G_MISS_CHAR,
failure_score_date               DATE           := FND_API.G_MISS_DATE,
failure_score_incd_default       NUMBER         := FND_API.G_MISS_NUM,
failure_score_natnl_percentile   NUMBER         := FND_API.G_MISS_NUM,
failure_score_override_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR,
global_failure_score             VARCHAR2(30)   := FND_API.G_MISS_CHAR,
debarment_ind                   VARCHAR2(30)   := FND_API.G_MISS_CHAR,
debarments_count                NUMBER         := FND_API.G_MISS_NUM,
debarments_date                 DATE           := FND_API.G_MISS_DATE,
high_credit                     NUMBER         := FND_API.G_MISS_NUM,
maximum_credit_currency_code    VARCHAR2(240)  := FND_API.G_MISS_CHAR,
maximum_credit_rcmd             NUMBER         := FND_API.G_MISS_NUM,
paydex_norm                     VARCHAR2(3)    := FND_API.G_MISS_CHAR,
paydex_score                    VARCHAR2(3)    := FND_API.G_MISS_CHAR,
paydex_three_months_ago         VARCHAR2(3)    := FND_API.G_MISS_CHAR,
credit_score_override_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR,
cr_scr_clas_expl                VARCHAR2(30)   := FND_API.G_MISS_CHAR,
low_rng_delq_scr                NUMBER         := FND_API.G_MISS_NUM,
high_rng_delq_scr               NUMBER         := FND_API.G_MISS_NUM,
delq_pmt_rng_prcnt              NUMBER         := FND_API.G_MISS_NUM,
delq_pmt_pctg_for_all_firms     NUMBER         := FND_API.G_MISS_NUM,
num_trade_experiences           NUMBER         := FND_API.G_MISS_NUM,
paydex_firm_days                VARCHAR2(15)   := FND_API.G_MISS_CHAR,
paydex_firm_comment             VARCHAR2(60)   := FND_API.G_MISS_CHAR,
paydex_industry_days            VARCHAR2(15)   := FND_API.G_MISS_CHAR,
paydex_industry_comment         VARCHAR2(50)   := FND_API.G_MISS_CHAR,
paydex_comment                  VARCHAR2(240)  := FND_API.G_MISS_CHAR,
suit_ind                        VARCHAR2(5)    := FND_API.G_MISS_CHAR,
lien_ind                        VARCHAR2(5)    := FND_API.G_MISS_CHAR,
judgement_ind                   VARCHAR2(5)    := FND_API.G_MISS_CHAR,
bankruptcy_ind                  VARCHAR2(5)    := FND_API.G_MISS_CHAR,
no_trade_ind                    VARCHAR2(5)    := FND_API.G_MISS_CHAR,
prnt_hq_bkcy_ind                VARCHAR2(5)    := FND_API.G_MISS_CHAR,
num_prnt_bkcy_filing            NUMBER         := FND_API.G_MISS_NUM,
prnt_bkcy_filg_type             VARCHAR2(20)   := FND_API.G_MISS_CHAR,
prnt_bkcy_filg_chapter          NUMBER         := FND_API.G_MISS_NUM,
prnt_bkcy_filg_date             DATE           := FND_API.G_MISS_DATE,
num_prnt_bkcy_convs             NUMBER         := FND_API.G_MISS_NUM,
prnt_bkcy_conv_date             DATE           := FND_API.G_MISS_DATE,
prnt_bkcy_chapter_conv          VARCHAR2(60)   := FND_API.G_MISS_CHAR,
slow_trade_expl                 VARCHAR2(100)  := FND_API.G_MISS_CHAR,
negv_pmt_expl                   VARCHAR2(150)  := FND_API.G_MISS_CHAR,
pub_rec_expl                    VARCHAR2(150)  := FND_API.G_MISS_CHAR,
business_discontinued           VARCHAR2(240)  := FND_API.G_MISS_CHAR,
spcl_event_comment              VARCHAR2(150)  := FND_API.G_MISS_CHAR,
num_spcl_event                  NUMBER         := FND_API.G_MISS_NUM,
spcl_event_update_date          DATE           := FND_API.G_MISS_DATE,
spcl_evnt_txt                   VARCHAR2(2000) := FND_API.G_MISS_CHAR,
actual_content_source           VARCHAR2(30)   := FND_API.G_MISS_CHAR
);


TYPE financial_profile_rec_type IS RECORD(
financial_profile_id             NUMBER        := FND_API.G_MISS_NUM,
access_authority_date            DATE          := FND_API.G_MISS_DATE,
access_authority_granted         VARCHAR2(1)   := FND_API.G_MISS_CHAR,
balance_amount                   NUMBER        := FND_API.G_MISS_NUM,
balance_verified_on_date         DATE          := FND_API.G_MISS_DATE,
financial_account_number         VARCHAR2(60)  := FND_API.G_MISS_CHAR,
financial_account_type           VARCHAR2(30)  := FND_API.G_MISS_CHAR,
financial_org_type               VARCHAR2(30)  := FND_API.G_MISS_CHAR,
financial_organization_name      VARCHAR2(240) := FND_API.G_MISS_CHAR,
party_id                         NUMBER        := FND_API.G_MISS_NUM,
wh_update_date                   DATE          := FND_API.G_MISS_DATE,
status                           varchar2(1)   := FND_API.G_MISS_CHAR);

----------------------------------------------------------------------------
/* Obsolete V1 API
procedure create_credit_ratings(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_credit_ratings_rec    IN      CREDIT_RATINGS_REC_TYPE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_credit_rating_id      OUT     NOCOPY NUMBER,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);


procedure update_credit_ratings(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
        p_credit_ratings_rec    IN      CREDIT_RATINGS_REC_TYPE,
        p_last_update_date      IN OUT  NOCOPY DATE,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_validation_level      IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);

*/
procedure create_financial_profile(
        p_api_version             IN      NUMBER,
        p_init_msg_list           IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                  IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_profile_rec   IN      FINANCIAL_PROFILE_REC_TYPE,
        x_return_status           OUT     NOCOPY VARCHAR2,
        x_msg_count               OUT     NOCOPY NUMBER,
        x_msg_data                OUT     NOCOPY VARCHAR2,
        x_financial_profile_id    OUT     NOCOPY NUMBER,
        p_validation_level        IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);


procedure update_financial_profile(
        p_api_version             IN      NUMBER,
        p_init_msg_list           IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                  IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_profile_rec   IN      FINANCIAL_PROFILE_REC_TYPE,
        p_last_update_date        IN OUT  NOCOPY DATE,
        x_return_status           OUT     NOCOPY VARCHAR2,
        x_msg_count               OUT     NOCOPY NUMBER,
        x_msg_data                OUT     NOCOPY VARCHAR2,
        p_validation_level         IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
);


procedure get_current_credit_rating(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_credit_rating_id      IN      NUMBER,
        x_credit_ratings_rec    OUT     NOCOPY CREDIT_RATINGS_REC_TYPE,
        x_return_status         IN OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
);


END HZ_PARTY_INFO_PUB;

 

/
