--------------------------------------------------------
--  DDL for Package HZ_CREDIT_RATINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CREDIT_RATINGS_PKG" AUTHID CURRENT_USER as
/* $Header: ARHPCRTS.pls 115.12 2003/04/17 20:39:58 sponnamb ship $ */

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
    x_fail_score_natnl_percentile           IN     NUMBER,
    x_failure_score_override_code           IN     VARCHAR2,
    x_global_failure_score                  IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
);

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
    x_fail_score_natnl_percentile           IN     NUMBER,
    x_failure_score_override_code           IN     VARCHAR2,
    x_global_failure_score                  IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
);

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
    x_fail_score_natnl_percentile           IN     NUMBER,
    x_failure_score_override_code           IN     VARCHAR2,
    x_global_failure_score                  IN     VARCHAR2,
    x_actual_content_source                 IN     VARCHAR2
);

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
);

PROCEDURE Delete_Row (
    x_credit_rating_id                      IN     NUMBER
);

END HZ_CREDIT_RATINGS_PKG;

 

/