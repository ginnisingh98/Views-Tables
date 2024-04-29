--------------------------------------------------------
--  DDL for Package CN_WKSHT_CT_UP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_WKSHT_CT_UP_PUB" AUTHID CURRENT_USER as
-- $Header: cnvwkcds.pls 115.6 2002/11/21 21:20:12 hlchen ship $
--============================================================================
TYPE srp_pmt_plans_rec_type IS RECORD
  (PMT_PLAN_NAME           cn_pmt_plans.name%TYPE := CN_API.G_MISS_CHAR,
   SALESREP_TYPE           VARCHAR2(100)  := CN_API.G_MISS_CHAR,
   EMP_NUM                 VARCHAR2(30)   := CN_API.G_MISS_CHAR,
   START_DATE              cn_srp_pmt_plans.start_date%TYPE
                                       := CN_API.G_MISS_DATE,
   END_DATE                cn_srp_pmt_plans.end_date%TYPE
                                       := CN_API.G_MISS_DATE,
   MINIMUM_AMOUNT          cn_srp_pmt_plans.minimum_amount%TYPE
                                       := CN_API.G_MISS_NUM,
   MAXIMUM_AMOUNT          cn_srp_pmt_plans.maximum_amount%TYPE
                                       := CN_API.G_MISS_NUM,
   MAX_RECOVERY_AMOUNT     cn_srp_pmt_plans.max_recovery_amount%TYPE
                                       := CN_API.G_MISS_NUM,
   ATTRIBUTE_CATEGORY      cn_srp_pmt_plans.attribute_category%TYPE
                           := CN_API.G_MISS_CHAR,
   ATTRIBUTE1              cn_srp_pmt_plans.attribute1%TYPE
                           := CN_API.G_MISS_CHAR,
   ATTRIBUTE2              cn_srp_pmt_plans.attribute2%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE3              cn_srp_pmt_plans.attribute3%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE4              cn_srp_pmt_plans.attribute4%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE5              cn_srp_pmt_plans.attribute5%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE6              cn_srp_pmt_plans.attribute6%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE7              cn_srp_pmt_plans.attribute7%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE8              cn_srp_pmt_plans.attribute8%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE9              cn_srp_pmt_plans.attribute9%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE10             cn_srp_pmt_plans.attribute10%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE11             cn_srp_pmt_plans.attribute11%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE12             cn_srp_pmt_plans.attribute12%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE13             cn_srp_pmt_plans.attribute13%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE14             cn_srp_pmt_plans.attribute14%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE15             cn_srp_pmt_plans.attribute15%TYPE
                            := CN_API.G_MISS_CHAR
  );

 G_MISS_SRP_PMT_PLANS_REC srp_pmt_plans_rec_type;

Procedure Create_delete_Wrkhst
   ( p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     p_commit              IN   VARCHAR2,
     p_validation_level    IN   NUMBER,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     p_salesrep_id         IN   NUMBER,
     p_srp_pmt_asgn_id     IN   NUMBER,
     p_payrun_id           IN   NUMBER,
     x_status             OUT NOCOPY  VARCHAR2,
     x_loading_status     OUT NOCOPY  VARCHAR2
     )  ;
Procedure Apply_payment_plan_upd
   ( p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     p_commit              IN   VARCHAR2,
     p_validation_level    IN   NUMBER,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     p_salesrep_id         IN   NUMBER,
     p_srp_pmt_asgn_id     IN   NUMBER,
     p_payrun_id           IN   NUMBER,
     p_old_srp_pmt_plans_rec IN  srp_pmt_plans_rec_type := G_MISS_SRP_PMT_PLANS_REC,
     p_srp_pmt_plans_rec  IN  srp_pmt_plans_rec_type :=G_MISS_SRP_PMT_PLANS_REC,
     x_status             OUT NOCOPY  VARCHAR2,
     x_loading_status     OUT NOCOPY  VARCHAR2
     )  ;
Procedure Apply_payment_plan_cre
   ( p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     p_commit              IN   VARCHAR2,
     p_validation_level    IN   NUMBER,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     p_salesrep_id         IN   NUMBER,
     p_srp_pmt_asgn_id     IN   NUMBER,
     p_payrun_id           IN   NUMBER,
     p_srp_pmt_plans_rec  IN  srp_pmt_plans_rec_type := G_MISS_SRP_PMT_PLANS_REC,
     x_status             OUT NOCOPY  VARCHAR2,
     x_loading_status     OUT NOCOPY  VARCHAR2
     )  ;

Procedure Apply_payment_plan_del
   ( p_api_version         IN   NUMBER,
     p_init_msg_list       IN   VARCHAR2,
     p_commit              IN   VARCHAR2,
     p_validation_level    IN   NUMBER,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY  NUMBER,
     x_msg_data            OUT NOCOPY  VARCHAR2,
     p_salesrep_id         IN   NUMBER,
     p_srp_pmt_asgn_id     IN   NUMBER,
     p_payrun_id           IN   NUMBER,
     p_srp_pmt_plans_rec  IN  srp_pmt_plans_rec_type := G_MISS_SRP_PMT_PLANS_REC,
     x_status             OUT NOCOPY  VARCHAR2,
     x_loading_status     OUT NOCOPY  VARCHAR2
     )  ;


END CN_WKSHT_CT_UP_PUB;

 

/
