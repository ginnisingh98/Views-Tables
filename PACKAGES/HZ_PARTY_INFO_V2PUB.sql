--------------------------------------------------------
--  DDL for Package HZ_PARTY_INFO_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_INFO_V2PUB" AUTHID CURRENT_USER AS
/* $Header: ARH2PRSS.pls 120.6 2006/08/17 10:19:44 idali noship $ */
/*#
 * The Credit Request Creation API creates a credit request in the  Credit
 * Management system based on the specified parameters. After the credit request
 * is created with minimal validations, an asynchronous workflow is initiated
 * that starts processing the credit request.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Credit Request Creation
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */


--------------------------------------
-- declaration of record type
--------------------------------------

TYPE credit_rating_rec_type IS RECORD(
     credit_rating_id                NUMBER,
     description                     VARCHAR2(2000),
     party_id                        NUMBER,
     rating                          VARCHAR2(60),
     rated_as_of_date                DATE,
     rating_organization             VARCHAR2(240),
     comments                        VARCHAR2(240),
     det_history_ind                 VARCHAR2(5),
     fincl_embt_ind                  VARCHAR2(5),
     criminal_proceeding_ind         VARCHAR2(5),
     claims_ind                      VARCHAR2(5),
     secured_flng_ind                VARCHAR2(5),
     fincl_lgl_event_ind             VARCHAR2(5),
     disaster_ind                    VARCHAR2(5),
     oprg_spec_evnt_ind              VARCHAR2(5),
     other_spec_evnt_ind             VARCHAR2(5),
     status                          VARCHAR2(1),
     avg_high_credit                 NUMBER,
     credit_score                    VARCHAR2(30),
     credit_score_age                NUMBER,
     credit_score_class              NUMBER,
     credit_score_commentary         VARCHAR2(30),
     credit_score_commentary2        VARCHAR2(30),
     credit_score_commentary3        VARCHAR2(30),
     credit_score_commentary4        VARCHAR2(30),
     credit_score_commentary5        VARCHAR2(30),
     credit_score_commentary6        VARCHAR2(30),
     credit_score_commentary7        VARCHAR2(30),
     credit_score_commentary8        VARCHAR2(30),
     credit_score_commentary9        VARCHAR2(30),
     credit_score_commentary10       VARCHAR2(30),
     credit_score_date               DATE,
     credit_score_incd_default       NUMBER,
     credit_score_natl_percentile    NUMBER,
     failure_score                   VARCHAR2(30),
     failure_score_age               NUMBER,
     failure_score_class             NUMBER,
     failure_score_commentary        VARCHAR2(30),
     failure_score_commentary2       VARCHAR2(30),
     failure_score_commentary3       VARCHAR2(30),
     failure_score_commentary4       VARCHAR2(30),
     failure_score_commentary5       VARCHAR2(30),
     failure_score_commentary6       VARCHAR2(30),
     failure_score_commentary7       VARCHAR2(30),
     failure_score_commentary8       VARCHAR2(30),
     failure_score_commentary9       VARCHAR2(30),
     failure_score_commentary10      VARCHAR2(30),
     failure_score_date              DATE,
     failure_score_incd_default      NUMBER,
     failure_score_natnl_percentile  NUMBER,
     failure_score_override_code     VARCHAR2(30),
     global_failure_score            VARCHAR2(30),
     debarment_ind                   VARCHAR2(30),
     debarments_count                NUMBER,
     debarments_date                 DATE,
     high_credit                     NUMBER,
     maximum_credit_currency_code    VARCHAR2(240),
     maximum_credit_rcmd             NUMBER,
     paydex_norm                     VARCHAR2(3),
     paydex_score                    VARCHAR2(3),
     paydex_three_months_ago         VARCHAR2(3),
     credit_score_override_code      VARCHAR2(30),
     cr_scr_clas_expl                VARCHAR2(30),
     low_rng_delq_scr                NUMBER,
     high_rng_delq_scr               NUMBER,
     delq_pmt_rng_prcnt              NUMBER,
     delq_pmt_pctg_for_all_firms     NUMBER,
     num_trade_experiences           NUMBER,
     paydex_firm_days                VARCHAR2(15),
     paydex_firm_comment             VARCHAR2(60),
     paydex_industry_days            VARCHAR2(15),
     paydex_industry_comment         VARCHAR2(50),
     paydex_comment                  VARCHAR2(240),
     suit_ind                        VARCHAR2(5),
     lien_ind                        VARCHAR2(5),
     judgement_ind                   VARCHAR2(5),
     bankruptcy_ind                  VARCHAR2(5),
     no_trade_ind                    VARCHAR2(5),
     prnt_hq_bkcy_ind                VARCHAR2(5),
     num_prnt_bkcy_filing            NUMBER,
     prnt_bkcy_filg_type             VARCHAR2(20),
     prnt_bkcy_filg_chapter          NUMBER,
     prnt_bkcy_filg_date             DATE,
     num_prnt_bkcy_convs             NUMBER,
     prnt_bkcy_conv_date             DATE,
     prnt_bkcy_chapter_conv          VARCHAR2(60),
     slow_trade_expl                 VARCHAR2(100),
     negv_pmt_expl                   VARCHAR2(150),
     pub_rec_expl                    VARCHAR2(150),
     business_discontinued           VARCHAR2(240),
     spcl_event_comment              VARCHAR2(150),
     num_spcl_event                  NUMBER,
     spcl_event_update_date          DATE,
     spcl_evnt_txt                   VARCHAR2(2000),
     actual_content_source           VARCHAR2(30),
     created_by_module               VARCHAR2(150)
);

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_credit_rating
 *
 * DESCRIPTION
 *     Creates credit rating.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_credit_rating_rec            credit rating record.
 *   IN/OUT:
 *   OUT:
 *     x_credit_rating_id             Credit rating Id.
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
 *   27-JAN-2003   Sreedhar Mohan        o Created.
 *
 */

/*#
 * Creates a credit rating for initiating a credit review for a party
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Credit Rating
 * @rep:businessevent oracle.apps.ar.hz.CreditRating.create
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_credit_rating(
    p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
    p_credit_rating_rec        IN  CREDIT_RATING_REC_TYPE,
    x_credit_rating_id         OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_count                OUT NOCOPY NUMBER,
    x_msg_data                 OUT NOCOPY VARCHAR2
);


/**
 * PROCEDURE update_credit_rating
 *
 * DESCRIPTION
 *     Updates credit rating.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_credit_rating_rec            credit rating record.
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
 *   27-JAN-2003   Sreedhar Mohan        o Created.
 *
 */

/*#
 * Update credit rating for initiating a credit review for a party
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Credit Rating
 * @rep:businessevent oracle.apps.ar.hz.CreditRating.update
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE update_credit_rating(
    p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
    p_credit_rating_rec         IN     CREDIT_RATING_REC_TYPE,
    p_object_version_number     IN  OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);


/**
 * PROCEDURE get_credit_rating_rec
 *
 * DESCRIPTION
 *     Gets credit rating record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     x_credit_rating_id             Credit rating id.
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
 *   27-JAN-2003   Sreedhar Mohan        o Created.
 *
 */

PROCEDURE get_credit_rating_rec(
    p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
    p_credit_rating_id          IN     NUMBER,
    x_credit_rating_rec         OUT NOCOPY CREDIT_RATING_REC_TYPE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);


END HZ_PARTY_INFO_V2PUB;

 

/
