--------------------------------------------------------
--  DDL for Package Body OKC_OC_INT_QTK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OC_INT_QTK_PVT" AS
-- $Header: OKCRQTKB.pls 120.3 2005/10/04 19:36:17 smallya noship $

PROCEDURE print_error(pos IN NUMBER) IS
BEGIN
  null;
END print_error;

PROCEDURE cleanup(x_return_status OUT NOCOPY varchar2 ) IS
BEGIN
   NULL;
END cleanup;

PROCEDURE create_rule_group (p_level         IN VARCHAR2
                            ,p_rgd_type      IN VARCHAR2
                            ,p_chrv_rec      IN okc_contract_pub.chrv_rec_type
                            ,p_clev_rec      IN okc_contract_pub.clev_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2
                            ,x_rgpv_rec      OUT NOCOPY okc_rule_pub.rgpv_rec_type
                            ) IS

BEGIN
 NULL;
END create_rule_group;

PROCEDURE update_rule_group (p_level         IN VARCHAR2
                            ,p_rgd_type      IN VARCHAR2
                            ,p_chrv_rec      IN okc_contract_pub.chrv_rec_type
                            ,p_rgpv_rec      IN okc_rule_pub.rgpv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2
                            ,x_rgpv_rec      OUT NOCOPY okc_rule_pub.rgpv_rec_type
                            ) IS

BEGIN
 NULL;
END update_rule_group;

PROCEDURE delete_rule_group (p_rgpv_rec      IN okc_rule_pub.rgpv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2
                            ) IS

BEGIN
  NULL;
END delete_rule_group;

PROCEDURE create_rg_party_roles (p_chrv_rec      IN okc_contract_pub.chrv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2
                            ) IS

BEGIN
  NULL;
END create_rg_party_roles;

PROCEDURE create_rule (p_rgpv_rec      IN okc_rule_pub.rgpv_rec_type
                      ,p_chrv_rec      IN okc_contract_pub.chrv_rec_type
                      ,p_rulv_rec      IN okc_rule_pub.rulv_rec_type
                      ,x_return_status OUT NOCOPY VARCHAR2
                      ,x_rulv_rec      OUT NOCOPY okc_rule_pub.rulv_rec_type
                      ) IS
BEGIN
  NULL;
END create_rule;

PROCEDURE update_rule (p_rgpv_rec      IN okc_rule_pub.rgpv_rec_type
                      ,p_chrv_rec      IN okc_contract_pub.chrv_rec_type
                      ,p_rulv_rec      IN okc_rule_pub.rulv_rec_type
                      ,x_return_status OUT NOCOPY VARCHAR2
                      ,x_rulv_rec      OUT NOCOPY okc_rule_pub.rulv_rec_type
                      ) IS
BEGIN
  NULL;
END update_rule;

Procedure Line_level_rule_groups(x_return_status OUT NOCOPY VARCHAR2
                                ,x_rgpv_rec      OUT NOCOPY okc_rule_pub.rgpv_rec_type
                                ,p_rgd_type      IN  VARCHAR2
                                ,p_chrv_rec      IN  okc_contract_pub.chrv_rec_type
                                ,p_clev_rec      IN  okc_contract_pub.clev_rec_type) IS
BEGIN
  NULL;
END; -- line level rule groups

Procedure Line_level_rules(x_return_status OUT NOCOPY VARCHAR2
                          ,x_rulv_rec      OUT NOCOPY okc_rule_pub.rulv_rec_type
                          ,p_rgpv_rec      IN  okc_rule_pub.rgpv_rec_type
                          ,p_chrv_rec      IN  okc_contract_pub.chrv_rec_type
                          ,p_rulv_rec      IN  okc_rule_pub.rulv_rec_type) IS


-- Get description for rule type

BEGIN
  NULL;
END; -- line level rules

PROCEDURE update_kpr (p_scs_code      IN VARCHAR2
                     ,p_chr_id        IN NUMBER
                     ,p_org_id        IN NUMBER
                     ,p_party_id      IN NUMBER
                     ,x_return_status OUT NOCOPY VARCHAR2
                     ,x_cplv_rec      OUT NOCOPY okc_contract_party_pub.cplv_rec_type
                     ,x_ctcv_rec      OUT NOCOPY okc_contract_party_pub.ctcv_rec_type
                     ) IS
BEGIN
  NULL;
END update_kpr;

PROCEDURE get_line_style(p_item_id         IN VARCHAR2
                        ,p_organization_id IN VARCHAR2
                        ,p_line_style_tab  IN line_style_tab_type
	                ,x_return_status   OUT NOCOPY VARCHAR2
                        ,x_tab_idx         OUT NOCOPY BINARY_INTEGER
                        ) IS

BEGIN
  NULL;
END get_line_style;

PROCEDURE get_sub_line_style(p_org_id          IN NUMBER,
                             p_item_id         IN VARCHAR2
                            ,p_sub_line_style_tab  IN sub_line_style_tab_type
                            ,x_return_status   OUT NOCOPY VARCHAR2
                            ,x_tab_idx         OUT NOCOPY NUMBER    -- BINARY_INTEGER
                            ) IS
BEGIN
  NULL;
END get_sub_line_style;

PROCEDURE instantiate_counters_events (x_return_status                OUT NOCOPY VARCHAR2
                                      ,p_start_date                   IN  DATE
                                      ,p_END_date                     IN  DATE
							   ,p_inv_org_id                   IN  NUMBER
                                      ,p_cle_id                       IN  NUMBER) IS
BEGIN
   null;
END instantiate_counters_events;

PROCEDURE create_k_rel_objs ( x_return_status    OUT NOCOPY VARCHAR2
                             ,x_crj_rel_hdr_rec  OUT NOCOPY OKC_K_REL_OBJS_PUB.CRJ_REL_HDR_REC_TYPE
                             ,x_crj_rel_line_tbl OUT NOCOPY OKC_K_REL_OBJS_PUB.CRJ_REL_LINE_TBL_TYPE
                             ,p_rel_type         IN  OKC_K_REL_OBJS.RTY_CODE%TYPE
                             ,p_rel_hdr          IN  OKC_K_REL_OBJS_PUB.CRJ_REL_HDR_REC_TYPE
                             ,p_rel_line_tab     IN  OKC_K_REL_OBJS_PUB.CRJ_REL_LINE_TBL_TYPE
                            ) IS

BEGIN
  NULL;
END create_k_rel_objs;

PROCEDURE validate_quote_ktemplate_rel (p_k_template_id        IN  NUMBER
                                   ,p_k_template_version       IN  NUMBER
                                   ,p_quote_id                 IN  NUMBER
                                   ,p_rel_type                 IN  VARCHAR2
                                   ,x_k_template_scs_code      OUT NOCOPY VARCHAR2
                                   ,x_k_template_number        OUT NOCOPY VARCHAR2
                                   ,x_k_template_currency_code OUT NOCOPY VARCHAR2
                                   ,x_quote_number             OUT NOCOPY NUMBER
                                   ,x_quote_version            OUT NOCOPY NUMBER
                                   ,x_quote_currency_code      OUT NOCOPY VARCHAR2
                                   ,x_return_status            OUT NOCOPY VARCHAR2
                                   ) IS
BEGIN
  NULL;
END validate_quote_ktemplate_rel;

PROCEDURE update_k_header(x_return_status OUT NOCOPY VARCHAR2
                         ,p_context       IN  VARCHAR2
                         ,p_chr_id        IN  NUMBER
                         ,p_qte_id        IN  NUMBER) IS
BEGIN
 null;
END update_k_header;

PROCEDURE create_new_line(x_return_status  OUT NOCOPY VARCHAR2
                         ,x_cle_id         OUT NOCOPY NUMBER
                         ,p_context        IN VARCHAR2
                         ,p_line_style_tab IN line_style_tab_type) IS
BEGIN
  null;
END create_new_line;

PROCEDURE renew_line(x_return_status  OUT NOCOPY VARCHAR2
                    ,x_cle_id         OUT NOCOPY NUMBER
                    ,p_cle_id         IN  NUMBER  -- line being renewed
                    ,p_context        IN VARCHAR2
                    ,p_line_style_tab IN  OKC_OC_INT_QTK_PVT.line_style_tab_type) IS

BEGIN
  null;
END; -- Renew_line;

PROCEDURE create_k_lines(x_return_status OUT NOCOPY VARCHAR2
                        ,p_context       IN  VARCHAR2
                        ,p_chr_id        IN  NUMBER
                        ,p_qte_id        IN  NUMBER
                        ,p_k_template_id IN  NUMBER) IS
BEGIN
   NULL;
END create_k_lines;

PROCEDURE create_k_from_q(x_return_status OUT NOCOPY VARCHAR2
                         ,p_context       IN  VARCHAR2
                         ,p_chr_id        IN  NUMBER  ) IS
BEGIN
   NULL;
END; -- create_k_from_q;

PROCEDURE create_new_k( x_return_status OUT NOCOPY VARCHAR2
                       ,x_chr_id        OUT NOCOPY NUMBER
                       ,p_rel_type      IN  OKC_K_REL_OBJS.RTY_CODE%TYPE
                       ,p_k_template_id IN  NUMBER
                       ,p_k_template_version IN  NUMBER
                       ,p_qte_id        IN  NUMBER  ) IS
BEGIN
  NULL;
END create_new_k;

PROCEDURE renew_k( x_return_status OUT NOCOPY VARCHAR2
                  ,x_chr_id        OUT NOCOPY NUMBER
                  ,p_rel_type      IN  OKC_K_REL_OBJS.RTY_CODE%TYPE
                  ,p_k_template_id IN  NUMBER
                  ,p_qte_id        IN  NUMBER  ) IS
BEGIN
 NULL;
END renew_k;

PROCEDURE create_k_from_quote(p_api_version     IN NUMBER
                             ,p_init_msg_list   IN VARCHAR2
                             ,p_quote_id        IN OKX_QUOTE_HEADERS_V.id1%TYPE
                             ,p_template_id     IN OKC_K_HEADERS_B.ID%TYPE
                             ,p_template_version IN NUMBER
                             ,p_rel_type        IN OKC_K_REL_OBJS.RTY_CODE%TYPE
                             ,p_terms_agreed_flag IN VARCHAR2
                             ,x_contract_id     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE
                             ,x_contract_number OUT NOCOPY OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
                             ,x_return_status   OUT NOCOPY VARCHAR2
                             ,x_msg_count       OUT NOCOPY NUMBER
                             ,x_msg_data        OUT NOCOPY VARCHAR2
                             ) IS
BEGIN
 null;
END create_k_from_quote;

PROCEDURE get_k_number (p_api_version IN NUMBER
                 ,p_init_msg_list     IN VARCHAR2
                 ,p_contract_id       IN NUMBER
                 ,x_contract_number   OUT NOCOPY OKC_K_HEADERS_B.contract_number%TYPE
                 ,x_contract_number_modifier OUT NOCOPY OKC_K_HEADERS_B.contract_number_modifier%TYPE
                 ,x_return_status     OUT NOCOPY VARCHAR2
                 ,x_msg_count         OUT NOCOPY NUMBER
                 ,x_msg_data          OUT NOCOPY VARCHAR2) IS

BEGIN
 NULL;
END get_k_number;

PROCEDURE set_notification_msg (p_api_version           IN NUMBER
                      ,p_init_msg_list                  IN VARCHAR2
		      ,p_application_name               IN VARCHAR2
		      ,p_message_subject                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		      ,p_message_body 	                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		      ,p_message_body_token1 		IN VARCHAR2
		      ,p_message_body_token1_value 	IN VARCHAR2
		      ,p_message_body_token2 		IN VARCHAR2
		      ,p_message_body_token2_value 	IN VARCHAR2
		      ,p_message_body_token3 		IN VARCHAR2
		      ,p_message_body_token3_value 	IN VARCHAR2
                      ,x_return_status   	 OUT NOCOPY VARCHAR2) IS

BEGIN
 NULL;
END set_notification_msg;

PROCEDURE notify_k_adm(
                       p_api_version                    IN NUMBER
                      ,p_init_msg_list                  IN VARCHAR2
		      ,p_application_name               IN VARCHAR2
		      ,p_message_subject                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		      ,p_message_body 	                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		      ,p_message_body_token1 		IN VARCHAR2
		      ,p_message_body_token1_value 	IN VARCHAR2
		      ,p_message_body_token2 		IN VARCHAR2
		      ,p_message_body_token2_value 	IN VARCHAR2
		      ,p_message_body_token3 		IN VARCHAR2
		      ,p_message_body_token3_value 	IN VARCHAR2
                      ,p_contract_id                    IN OKC_K_HEADERS_B.ID%TYPE
                      ,x_k_admin_user_name              OUT NOCOPY VARCHAR2
                      ,x_return_status   	 OUT NOCOPY VARCHAR2
                      ,x_msg_count                      OUT NOCOPY NUMBER
                      ,x_msg_data                       OUT NOCOPY VARCHAR2) IS

BEGIN
  NULL;
END notify_k_adm;

PROCEDURE create_interaction_history(p_api_version    IN  NUMBER
                               ,p_init_msg_list       IN  VARCHAR2
                               ,p_contract_id         IN  NUMBER
                               ,p_party_id            IN  NUMBER
                               ,p_interaction_subject IN  VARCHAR2
                               ,p_interaction_body    IN  VARCHAR2
                               ,x_return_status       OUT NOCOPY VARCHAR2
                               ,x_msg_count           OUT NOCOPY NUMBER
                               ,x_msg_data            OUT NOCOPY VARCHAR2) IS
BEGIN
 NULL;
END create_interaction_history;

PROCEDURE get_articles (p_api_version     IN NUMBER
                       ,p_init_msg_list   IN VARCHAR2
                       ,p_contract_id     IN NUMBER
		       ,p_release_id      IN   NUMBER
                       ,x_articles        OUT NOCOPY OKC_K_ARTICLES_TL.TEXT%TYPE
                       ,x_return_status   OUT NOCOPY VARCHAR2
                       ,x_msg_count       OUT NOCOPY NUMBER
                       ,x_msg_data        OUT NOCOPY VARCHAR2) IS
BEGIN
  NULL;
END get_articles;

PROCEDURE notify_sales_rep (p_api_version     IN NUMBER
                           ,p_init_msg_list   IN VARCHAR2
                           ,p_contract_id     IN NUMBER
                           ,p_contract_status IN VARCHAR2
                           ,x_return_status   OUT NOCOPY VARCHAR2
                           ,x_msg_count       OUT NOCOPY NUMBER
                           ,x_msg_data        OUT NOCOPY VARCHAR2) IS

BEGIN
 NULL;
END notify_sales_rep;

END OKC_OC_INT_QTK_PVT;

/
