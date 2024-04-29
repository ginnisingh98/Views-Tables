--------------------------------------------------------
--  DDL for Package OKL_ACCOUNT_DIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ACCOUNT_DIST_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTDTS.pls 115.6 2003/07/24 00:37:19 santonyr noship $ */

SUBTYPE ctxt_val_tbl_type   IS Okl_Account_Dist_Pvt.CTXT_VAL_TBL_TYPE;

SUBTYPE tmpl_identify_rec_type  IS Okl_Account_Dist_Pvt.TMPL_IDENTIFY_REC_TYPE;
SUBTYPE dist_info_rec_type     IS Okl_Account_Dist_Pvt.dist_info_REC_TYPE;
SUBTYPE amount_tbl_type         IS Okl_Account_Dist_Pvt.AMOUNT_TBL_TYPE;

SUBTYPE tabv_rec_type       IS Okl_Trns_Acc_Dstrs_Pub.tabv_rec_type;
SUBTYPE tabv_tbl_type       IS Okl_Trns_Acc_Dstrs_Pub.tabv_tbl_type;

SUBTYPE avlv_rec_type       IS OKL_TMPT_SET_PUB.avlv_rec_type;
SUBTYPE avlv_tbl_type       IS OKL_TMPT_SET_PUB.avlv_tbl_type;

SUBTYPE acc_gen_primary_key IS Okl_Account_Generator_Pub.primary_key_tbl;


PROCEDURE  CREATE_ACCOUNTING_DIST(p_api_version              IN       NUMBER,
                                  p_init_msg_list            IN       VARCHAR2,
                                  x_return_status            OUT      NOCOPY VARCHAR2,
                                  x_msg_count                OUT      NOCOPY NUMBER,
                                  x_msg_data                 OUT      NOCOPY VARCHAR2,
                                  p_tmpl_identify_rec        IN       TMPL_IDENTIFY_REC_TYPE,
                                  p_dist_info_rec            IN       dist_info_REC_TYPE,
                                  p_ctxt_val_tbl             IN       CTXT_VAL_TBL_TYPE,
                                  p_acc_gen_primary_key_tbl  IN       acc_gen_primary_key,
                                  x_template_tbl             OUT      NOCOPY AVLV_TBL_TYPE,
                                  x_amount_tbl               OUT      NOCOPY AMOUNT_TBL_TYPE);

PROCEDURE  CREATE_ACCOUNTING_DIST(p_api_version              IN       NUMBER,
                                  p_init_msg_list            IN       VARCHAR2,
                                  x_return_status            OUT      NOCOPY VARCHAR2,
                                  x_msg_count                OUT      NOCOPY NUMBER,
                                  x_msg_data                 OUT      NOCOPY VARCHAR2,
                                  p_tmpl_identify_rec        IN       TMPL_IDENTIFY_REC_TYPE,
                                  p_dist_info_rec            IN       dist_info_REC_TYPE,
                                  p_ctxt_val_tbl             IN       CTXT_VAL_TBL_TYPE,
                                  p_acc_gen_primary_key_tbl  IN       acc_gen_primary_key,
                                  x_template_tbl             OUT      NOCOPY AVLV_TBL_TYPE,
                                  x_amount_tbl               OUT      NOCOPY AMOUNT_TBL_TYPE,
                                  x_gl_date                  OUT      NOCOPY DATE);

PROCEDURE  GET_TEMPLATE_INFO(p_api_version        IN      NUMBER,
                             p_init_msg_list      IN      VARCHAR2,
                             x_return_status      OUT     NOCOPY VARCHAR2,
                             x_msg_count          OUT     NOCOPY NUMBER,
                             x_msg_data           OUT     NOCOPY VARCHAR2,
                             p_tmpl_identify_rec  IN      TMPL_IDENTIFY_REC_TYPE,
                             x_template_tbl       OUT NOCOPY     AVLV_TBL_TYPE,
                             p_validity_date            IN      DATE DEFAULT sysdate);



PROCEDURE  UPDATE_POST_TO_GL(p_api_version          IN      NUMBER,
                             p_init_msg_list        IN      VARCHAR2,
                             x_return_status        OUT     NOCOPY VARCHAR2,
                             x_msg_count            OUT     NOCOPY NUMBER,
                             x_msg_data             OUT     NOCOPY VARCHAR2,
                             p_source_id            IN      NUMBER,
                             p_source_table         IN      VARCHAR2);

PROCEDURE  DELETE_ACCT_ENTRIES(p_api_version                IN         NUMBER,
                               p_init_msg_list              IN         VARCHAR2,
                               x_return_status              OUT        NOCOPY VARCHAR2,
                               x_msg_count                  OUT        NOCOPY NUMBER,
                               x_msg_data                   OUT        NOCOPY VARCHAR2,
                               p_source_id                  IN         NUMBER,
                               p_source_table               IN         VARCHAR2);


PROCEDURE  REVERSE_ENTRIES(p_api_version                IN         NUMBER,
                           p_init_msg_list              IN         VARCHAR2,
                           x_return_status              OUT        NOCOPY VARCHAR2,
                           x_msg_count                  OUT        NOCOPY NUMBER,
                           x_msg_data                   OUT        NOCOPY VARCHAR2,
                           p_source_id                  IN         NUMBER,
                           p_source_table               IN         VARCHAR2,
                           p_acct_date                  IN         DATE);


G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_ACCOUNT_DIST_PUB';
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;


END OKL_ACCOUNT_DIST_PUB;

 

/
