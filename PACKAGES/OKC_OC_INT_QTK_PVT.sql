--------------------------------------------------------
--  DDL for Package OKC_OC_INT_QTK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OC_INT_QTK_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRQTKS.pls 120.1 2005/10/04 18:24:53 smallya noship $ */

--
-- Global constants
--

g_support                       CONSTANT VARCHAR2(1)   := 'S';

g_q2k_terms                     CONSTANT OKC_K_REL_OBJS.RTY_CODE%TYPE  := 'CONTRACTISTERMSFORQUOTE';
g_q2k_neg                       CONSTANT OKC_K_REL_OBJS.RTY_CODE%TYPE  := 'CONTRACTNEGOTIATESQUOTE';
g_q2k_ren                       CONSTANT OKC_K_REL_OBJS.RTY_CODE%TYPE  := 'CONTRACTRENEWSQUOTE';
g_k2q_ren                       CONSTANT OKC_K_REL_OBJS.RTY_CODE%TYPE  := 'QUOTERENEWSCONTRACT';

g_ctrol_type                    fnd_lookups.lookup_type%TYPE := 'OKC_CONTACT_ROLE';
g_admin_ctrol                   fnd_lookups.lookup_code%TYPE := 'ADMIN';
g_salesrep_ctrol                fnd_lookups.lookup_code%TYPE := 'SALESPERSON'; --ABHAY: new

g_custcont_ctrol                fnd_lookups.lookup_code%TYPE := 'CUST_CONTACT';

g_relobj_type                   fnd_lookups.lookup_type%TYPE := 'OKC_REL_OBJ';

g_chrsrc_type                   fnd_lookups.lookup_type%TYPE := 'OKC_CONTRACT_SOURCES';
g_ibe_hsrc                      fnd_lookups.lookup_code%TYPE := 'IBE_HDR';
g_ibe_lsrc                      fnd_lookups.lookup_code%TYPE := 'IBE_LINE';
g_aso_hsrc                      fnd_lookups.lookup_code%TYPE := 'ASO_HDR';
g_aso_lsrc                      fnd_lookups.lookup_code%TYPE := 'ASO_LINE';

g_jtot_qte_hdr                  CONSTANT VARCHAR2(30) := 'OKX_QUOTEHEAD';
g_jtot_qte_line                 CONSTANT VARCHAR2(30) := 'OKX_QUOTELINE';
g_entered                       CONSTANT VARCHAR2(30) := 'ENTERED' ;
g_approved                      CONSTANT VARCHAR2(30) := 'CONTRACT_APPROVED';----'APPROVED';
g_cancelled                     CONSTANT VARCHAR2(30) := 'CONTRACT_CANCELED';-----'CANCELLED';
g_rejected                      CONSTANT VARCHAR2(30) := 'CONTRACT_REJECTED';----'REJECTED';
g_invalid_value                 CONSTANT VARCHAR2(200):= OKC_API.G_INVALID_VALUE ;
g_col_name_token                CONSTANT VARCHAR2(200):= OKC_API.G_COL_NAME_TOKEN ;

g_aso_model_item                CONSTANT VARCHAR2(30) := 'MDL';
g_aso_config_item               CONSTANT VARCHAR2(30) := 'CFG';
--added for configuration

--
-- Global variables
--

l_contract_number          okc_k_headers_b.contract_number%TYPE;
l_contract_number_modifier okc_k_headers_b.contract_number_modifier%TYPE;
l_quote_number             okx_quote_headers_v.quote_number%TYPE;
l_order_number             okx_order_headers_v.order_number%TYPE;


-- type declaration to be used in quote-to-contract scenario
-- helps figure out what line style to use

TYPE line_style_rec_type IS RECORD (lty_code         okc_line_styles_v.lty_code%TYPE
                                   ,priced_yn        okc_line_styles_v.priced_yn%TYPE
                                   ,service_item_yn  okc_line_styles_v.service_item_yn%TYPE -- GF bug=2291968

                                   --new pricing columns
                                   ,item_to_price_yn okc_line_styles_v.item_to_price_yn%TYPE
                                   ,price_basis_yn   okc_line_styles_v.price_basis_yn%TYPE

                                   ,lse_id           okc_line_styles_v.id%TYPE
                                   ,lse_name         okc_line_styles_v.name%TYPE
                                   ,object_code      jtf_objects_b.object_code%TYPE
                                   ,where_clause     jtf_objects_b.where_clause%TYPE
                                   ,from_table       jtf_objects_b.from_table%TYPE --Added by RG 04/20/2000

                                   ,recursive_yn     okc_line_styles_v.recursive_yn%TYPE
                                                           --added for configurator model line
                                   );

TYPE line_style_tab_type IS TABLE OF line_style_rec_type INDEX BY BINARY_INTEGER;

--
-- sub line style record definition

TYPE sub_line_style_rec_type is RECORD (lty_code         okc_line_styles_v.lty_code%TYPE
                                       ,priced_yn        okc_line_styles_v.priced_yn%TYPE
                                       ,service_item_yn  okc_line_styles_v.service_item_yn%TYPE -- GF bug=2291968
                                       ,lse_id           okc_line_styles_v.id%TYPE
                                       ,lse_name         okc_line_styles_v.name%TYPE
                                       ,object_code      jtf_objects_b.object_code%TYPE
                                       ,from_table       jtf_objects_b.from_table%TYPE
                                       ,where_clause     jtf_objects_b.where_clause%TYPE );

-- create pl/ql table to hold all sub linestyles for template/contract

TYPE sub_line_style_tab_type IS TABLE OF sub_line_style_rec_type INDEX BY BINARY_INTEGER;


-- needed to keep track of what contract line points to what index entry
-- in the table of to-be quote lines
TYPE line_rel_rec_type IS RECORD (k_line_id     okc_k_lines_b.id%TYPE
                                 ,tab_idx       BINARY_INTEGER
                                 );

TYPE line_rel_tab_type IS TABLE OF line_rel_rec_type INDEX BY BINARY_INTEGER;

G_MISS_KL_REL_TAB line_rel_tab_type;



-- needed to keep track of what contract line points to what index entry
-- in the table of to-be quote lines

-- Bug : 1686001 Changed references aso_quote_lines_v.quote_line_id  to  okx_quote_lines_v.id1
TYPE line_inf_rec IS RECORD(-----line_id       okc_k_lines_b.id%TYPE
                            cle_id       okc_k_lines_b.id%TYPE
                           ,lse_id        okc_k_lines_b.lse_id%TYPE
                           ,lty_code      okc_line_styles_b.lty_code%TYPE
                           ------,qte_line_id   aso_quote_lines_all.quote_line_id%TYPE
                           ,object1_id1   okx_quote_lines_v.id1%TYPE
                           ,line_num      NUMBER
                           ,subline       NUMBER
                           ,line_qty      okx_quote_lines_v.quantity%TYPE
                           ,line_uom      okx_quote_lines_v.uom_code%TYPE
                           ,line_type     okc_k_lines_b.config_item_type%TYPE
                            );
TYPE line_inf_tab IS TABLE OF line_inf_rec INDEX BY BINARY_INTEGER;



-------------------------------------------------------------------------------
-- Procedure:       create_k_from_quote
-- Version:         1.0
-- Purpose:         Create a contract from a quote.
--                  Create relationships from quote to contract
--                  The quote to contract process should not be used to create a-- service contract (OKS).
--                  It should be used to create a new (not renewed) Core
--                  contract from a quote.
-- In Parameters:   p_quote_id      Quote for which to create contract
--                  p_template_id   Template contract to use in creating Sales K
--                  p_rel_type      Q-Sales K relationship type to be used
--                  p_terms_agreed_flag Flag to indicate if contract has to be
--                                  created as signed (buyer agreed) or as
--                                  entered
--  Out Parameters: x_contract_id   Id of created contract
--                  x_contract_number Number of created contract
-------------------------------------------------------------------------------

-- Bug : 1686001 Changed references aso_quote_headers_v.quote_header_id  to  okx_quote_headers_v.id1
PROCEDURE create_k_from_quote(p_api_version     IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                             ,p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,p_quote_id        IN OKX_QUOTE_HEADERS_V.id1%TYPE
                             ,p_template_id     IN OKC_K_HEADERS_B.ID%TYPE
                             ,p_template_version IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                             ,p_rel_type        IN OKC_K_REL_OBJS.RTY_CODE%TYPE
                             ,p_terms_agreed_flag IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,x_contract_id     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE
                             ,x_contract_number OUT NOCOPY OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
                             ,x_return_status   OUT NOCOPY VARCHAR2
                             ,x_msg_count       OUT NOCOPY NUMBER
                             ,x_msg_data        OUT NOCOPY VARCHAR2
                             );

-------------------------------------------------------------------------------
-- Procedure:       create_k_from_q
-- Version:         1.0
-- Purpose:         Updates Contract Header
--                  Create relationships from quote to contract
--                  Creates or Updates Header Level Rule Groups and Rules
--                  If K is new, create new lines using template linestyles
--                  If K is renewal,  update line prices and rules for matching
--                  Q-K lines, else
--                  create new K lines from Quote using matching
--                  linestyles on the K and template, delete k lines that have
--                  been deleted from quote.
--
-- In Parameters:   p_context       New or renewal( = rel type )
--                  p_chr_id        Contract id
--
-- Out parameters:  x_chr_id   Contract id of the new contract
-- ----------------------------------------------------------------------------

PROCEDURE create_k_from_q(x_return_status OUT NOCOPY VARCHAR2
                         ,p_context       IN  VARCHAR2
                         ,p_chr_id        IN  NUMBER
                         );


-------------------------------------------------------------------------------
-- Procedure:       get_k_number
-- ...
-- ----------------------------------------------------------------------------

PROCEDURE get_k_number (p_api_version IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                 ,p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                 ,p_contract_id       IN NUMBER
                 ,x_contract_number   OUT NOCOPY OKC_K_HEADERS_B.contract_number%TYPE
                 ,x_contract_number_modifier OUT NOCOPY OKC_K_HEADERS_B.contract_number_modifier%TYPE
                 ,x_return_status     OUT NOCOPY VARCHAR2
                 ,x_msg_count         OUT NOCOPY NUMBER
                 ,x_msg_data          OUT NOCOPY VARCHAR2);



-------------------------------------------------------------------------------
-- Procedure:       set_notification_msg
-- Version:         1.0
-- ...
-------------------------------------------------------------------------------

PROCEDURE set_notification_msg (p_api_version           IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                      ,p_init_msg_list                  IN VARCHAR2 DEFAULT OKC_API.G_FALSE
		      ,p_application_name               IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_subject                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body 	                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token1 		IN VARCHAR2 DEFAULT NULL
		      ,p_message_body_token1_value 	IN VARCHAR2 DEFAULT NULL
		      ,p_message_body_token2 		IN VARCHAR2 DEFAULT NULL
		      ,p_message_body_token2_value 	IN VARCHAR2 DEFAULT NULL
		      ,p_message_body_token3 		IN VARCHAR2 DEFAULT NULL
		      ,p_message_body_token3_value 	IN VARCHAR2 DEFAULT NULL
                      ,x_return_status   	 OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------
-- Procedure:       notify_k_admin
-- Version:         1.0
-- ...
-------------------------------------------------------------------------------

--  Modified by Igor Filimonov 10-04-2001
--  Bug : 1905226  OKC, ISTORE TESTING: K ALERT RESULTS GRID SHOULD POPULATE K# FIELD
--  Problem : Notifications in Launchpad's Inbox don't show KNUMBER in subject
--            and 'Contract Number' column
--  Fix:  p_contract_id was added into parameter list of notify_k_adm procedure

PROCEDURE notify_k_adm(p_api_version                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                      ,p_init_msg_list                  IN VARCHAR2 DEFAULT OKC_API.G_FALSE
		      ,p_application_name               IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_subject               IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body 	               IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token1 		IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token1_value 	IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token2 		IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token2_value 	IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token3 		IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token3_value 	IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
                      ,p_contract_id                    IN OKC_K_HEADERS_B.ID%TYPE DEFAULT NULL
                      ,x_k_admin_user_name              OUT NOCOPY VARCHAR2
                      ,x_return_status   	 OUT NOCOPY VARCHAR2
                      ,x_msg_count                      OUT NOCOPY NUMBER
                      ,x_msg_data                       OUT NOCOPY VARCHAR2);


-------------------------------------------------------------------------------
-- Procedure:       create_interaction_history
-- Version:         1.0
-- Purpose:         1. In the event of a new contract's terms and conditions
--                     not being approved by the customer, fresh negotiations
--                     of the terms and conditions is undertaken and the
--                     contract administrator notified.
--                     Following the fresh negotiations, the customer may or
--                     may not approve. If the customer still does not approve,
--                     the contract has to be set back to an ENTERED state.
--
--                     This procedure records the information used for the
--                     these negotiations.
--
-- In Parameters:   p_api_version         API version (to be initialized to 1)
--                  p_init_msg_list       Flag to reset the error message stack
--                  p_commit              Commit flag for the transaction
--                  p_contract_id         Contract header id of the contract
--                                        whose TsandCs need to be negotiated
--                  p_party_id            Initiator of the Interaction
--                                        history as party id of person type
--                                        or as party id of a 'contact of' or
--                                        'employee of' relationship between
--                                        the customer and his contact or his
--                                        employee
--                  p_interaction_subject Short message to introduce the
--                                        interaction, like
--                                        Terms and conditions of a contract
--                  p_interaction_body    Message body to be used to build
--                                        the interaction
--                  p_trace_mode          Trace mode option to generate a
--                                        trace file
--
-- Out Parameters:  x_return_status       Final status of notification
--                                        sending API:
--                                        -OKC_API.G_RET_STS_SUCCESS
--                                        -OKC_API.G_RET_STS_ERROR
--                                        -OKC_API.G_RET_STS_UNEXP_ERROR
--                  x_msg_count           Number of messages set on the stack
--                  x_msg_data            Message info id x_msg_count = 1
-------------------------------------------------------------------------------

PROCEDURE create_interaction_history(p_api_version    IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                               ,p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                               ,p_contract_id         IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                               ,p_party_id            IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                               ,p_interaction_subject IN  VARCHAR2
                               ,p_interaction_body    IN  VARCHAR2
			       ,x_return_status       OUT NOCOPY VARCHAR2
                               ,x_msg_count           OUT NOCOPY NUMBER
                               ,x_msg_data            OUT NOCOPY VARCHAR2);


-------------------------------------------------------------------------------
-- Procedure:       get_articles
-- Version:         1.0
-- Purpose:         API is used to retrive Standard and Non-standard Articles
--
-- IN Parameters   : p_contract_id     Contract Id
--
-- OUT Parameters  : x_articles
-------------------------------------------------------------------------------

PROCEDURE get_articles (p_api_version     IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                       ,p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                       ,p_contract_id     IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
		       ,p_release_id      IN   NUMBER DEFAULT NULL
                       ,x_articles        OUT NOCOPY OKC_K_ARTICLES_TL.TEXT%TYPE
                       ,x_return_status   OUT NOCOPY VARCHAR2
                       ,x_msg_count       OUT NOCOPY NUMBER
                       ,x_msg_data        OUT NOCOPY VARCHAR2);


-------------------------------------------------------------------------------
-- Procedure:       notify_sales_rep
-- Version:         1.0
-- ...
-------------------------------------------------------------------------------

PROCEDURE notify_sales_rep (p_api_version     IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                           ,p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,p_contract_id     IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                           ,p_contract_status IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
                           ,x_return_status   OUT NOCOPY VARCHAR2
                           ,x_msg_count       OUT NOCOPY NUMBER
                           ,x_msg_data        OUT NOCOPY VARCHAR2);



-------------------------------------------------------------------------------
-- Procedure:       create_rule_group
-- Purpose:         Create a rule group or Update an existing rule group.
-- In Parameters:   p_level             'H' for header level, 'L' for line level
--                  p_rgd_type          A rule group definition code
--                  p_chrv_rec          Contract header record
-- Out Parameters:  x_return_status     Return status
--                  x_rgpv_rec          Output rule group record
-------------------------------------------------------------------------------
PROCEDURE create_rule_group (p_level         IN VARCHAR2
                            ,p_rgd_type      IN VARCHAR2
                            ,p_chrv_rec      IN okc_contract_pub.chrv_rec_type
                            ,p_clev_rec      IN okc_contract_pub.clev_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2
                            ,x_rgpv_rec      OUT NOCOPY okc_rule_pub.rgpv_rec_type
                            );


-------------------------------------------------------------------------------
-- Procedure:       Update_rule_group
-- Purpose:         Update an existing rule group.
-- In Parameters:   p_level             'H' for header level only
--                  p_rgd_type          A rule group definition code
--                  p_chrv_rec          Contract header record
-- Out Parameters:  x_return_status     Return status
--                  x_rgpv_rec          Output rule group record
-------------------------------------------------------------------------------
PROCEDURE update_rule_group (p_level         IN VARCHAR2
                            ,p_rgd_type      IN VARCHAR2
                            ,p_chrv_rec      IN okc_contract_pub.chrv_rec_type
                            ,p_rgpv_rec      IN okc_rule_pub.rgpv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2
                            ,x_rgpv_rec      OUT NOCOPY okc_rule_pub.rgpv_rec_type
                            );



-------------------------------------------------------------------------------
-- Procedure:       create_rule
-- Purpose:         Create a rule OR Update an existing rule.
-- In Parameters:
-- Out Parameters:  x_return_status     Return status
--                  x_rgpv_rec          Output rule group record
-------------------------------------------------------------------------------
PROCEDURE create_rule (p_rgpv_rec      IN okc_rule_pub.rgpv_rec_type
                      ,p_chrv_rec      IN okc_contract_pub.chrv_rec_type
                      ,p_rulv_rec      IN okc_rule_pub.rulv_rec_type
                      ,x_return_status OUT NOCOPY VARCHAR2
                      ,x_rulv_rec      OUT NOCOPY okc_rule_pub.rulv_rec_type
                      );



-------------------------------------------------------------------------------
-- Procedure:       update_rule
-- Purpose:         Update an existing rule.
-- In Parameters:
-- Out Parameters:  x_return_status     Return status
--                  x_rgpv_rec          Output rule group record
-------------------------------------------------------------------------------
PROCEDURE update_rule (p_rgpv_rec      IN okc_rule_pub.rgpv_rec_type
                      ,p_chrv_rec      IN okc_contract_pub.chrv_rec_type
                      ,p_rulv_rec      IN okc_rule_pub.rulv_rec_type
                      ,x_return_status OUT NOCOPY VARCHAR2
                      ,x_rulv_rec      OUT NOCOPY okc_rule_pub.rulv_rec_type
                      );


-------------------------------------------------------------------------------
-- Procedure:       create_rg_party_roles
-- Purpose:         Create a rule group party role.
-- In Parameters:   p_chrv_rec_         Contract_header record
-- Out Parameters:  x_return_status     Return status
--                  x_rmpv_tbl          Output rule group party roles table
-------------------------------------------------------------------------------
PROCEDURE create_rg_party_roles (p_chrv_rec      IN okc_contract_pub.chrv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2
                            );



-------------------------------------------------------------------------------
-- Procedure:       instantiate_counter_events
-- Purpose:         Initializes Counters, Events and Coverage templates for a
--                  service line
--                  Used when creating a contract from a quote
-- In Parameters:   p_start_date        Start date of the service line
--                  p_END_date          End Date for the service line
--                  p_cle_id            Service line ID
--
-- Out Parameters:  x_return_status     Return status
-------------------------------------------------------------------------------
PROCEDURE instantiate_counters_events (x_return_status                OUT NOCOPY VARCHAR2
                                      ,p_start_date                   IN  DATE
                                      ,p_END_date                     IN  DATE
				      ,p_inv_org_id                   IN  NUMBER
                                      ,p_cle_id                       IN  NUMBER);


-------------------------------------------------------------------------------
-- Procedure:           print_error
-- Returns:
-- Purpose:             Print the last error which occured
-- In Parameters:       pos    position on the line to print the message
-- Out Parameters:
-------------------------------------------------------------------------------
PROCEDURE print_error(pos IN NUMBER);


END OKC_OC_INT_QTK_PVT;

 

/
