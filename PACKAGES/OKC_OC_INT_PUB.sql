--------------------------------------------------------
--  DDL for Package OKC_OC_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OC_INT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPORDS.pls 120.0 2005/05/26 09:57:17 appldev noship $ */

-------------------------------------------------------------------------------
--
-- APIs: K->Q
--
-------------------------------------------------------------------------------

-- Procedure:       create_quote_for_renewal
-- Version:         1.0
-- Purpose:         Overloaded version designed to be called as an
--                  outcome from Events
--                  Hence input parameters need to be simpler,
--                  and no output parameters needed or useful
-- In Parameters:   p_contract_id   Contract for which to create quote
-- Out Parameters:  None

PROCEDURE create_quote_for_renewal(p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                                  ,x_return_status   OUT NOCOPY VARCHAR2
                                  ,x_msg_count       OUT NOCOPY NUMBER
                                  ,x_msg_data        OUT NOCOPY VARCHAR2
                                  ,p_contract_id     IN  OKC_K_HEADERS_B.ID%TYPE
				    ,p_trace_mode      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                                  );


-------------------------------------------------------------------------------
-- Procedure:       create_quote_from_k
-- Version:         1.0
-- Purpose:         The first one is planned to be called by a Conc. Prog.
--                  and calls itself the second one
--                  Create a quote from a contract as the initial
--                  stage in the renewal, or just as a copy of thew contract
--                  process.  Provides process 2.1 in data flow diagram in HLD.
--                  Create relationships from renewing contract to quote
--                  May also create subject-to relationship from quote
--                  to master contract if renewing contract is subject
--                  to a master contract
--                  Calls ASO_QUOTE_PUB.CREATE_QUOTE to create the quote
-- In Parameters:   p_contract_id   Contract for which to create quote
--                  p_rel_typ       Relation type to be created
-- Out Parameters:  x_quote_id      Id of created quote

PROCEDURE create_quote_from_k(ERRBUF              OUT NOCOPY VARCHAR2
			     ,RETCODE             OUT NOCOPY NUMBER
                             ,p_contract_category IN  OKC_K_HEADERS_B.SCS_CODE%TYPE DEFAULT OKC_API.g_miss_char
                             ,p_contract_number   IN  OKC_K_HEADERS_B.ID%TYPE
			     --p_contract_number is in fact equal to contract ID
			     ,p_rel_type          IN  FND_LOOKUPS.LOOKUP_CODE%TYPE DEFAULT OKC_API.g_miss_char
			     ,p_trace_mode        IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
                             );


PROCEDURE create_quote_from_k(p_api_version     IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                             ,p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,p_commit          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,x_return_status   OUT NOCOPY VARCHAR2
                             ,x_msg_count       OUT NOCOPY NUMBER
                             ,x_msg_data        OUT NOCOPY VARCHAR2
                             ,p_contract_id     IN  OKC_K_HEADERS_B.ID%TYPE
			     ,p_rel_type        IN  OKC_K_REL_OBJS.rty_code%TYPE DEFAULT OKC_API.g_miss_char
                             ,p_trace_mode      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,x_quote_id        OUT NOCOPY okx_quote_headers_v.id1%TYPE
                             );

-------------------------------------------------------------------------------
-- Procedure:       update_quote_from_k
-- Version:         1.0
-- Purpose:         The first one is planned to be called by a Conc. Prog.
--                  and calls itself the second one
--                  Update a quote from a contract as the initial
--                  stage in the renewal, or just as a copy of the contract
--                  process.  Provides process 2.1 in data flow diagram in HLD.
--                  Create relationships from renewing contract to quote
--                  May also create subject-to relationship from quote
--                  to master contract if renewing contract is subject
--                  to a master contract
--                  Calls ASO_QUOTE_PUB.UPDATE_QUOTE to update the quote
--
-- In Parameters:   p_contract_id   Contract for which the quote is to be renewed
--                  p_quote_id      Quote id of the quote to b renewed
--
PROCEDURE update_quote_from_k(ERRBUF              OUT NOCOPY VARCHAR2
			     ,RETCODE             OUT NOCOPY NUMBER
		--
                             ,p_contract_number   IN  OKC_K_HEADERS_B.ID%TYPE
			     -- p_contract_number is in fact equal to contract ID
		--
                             ,p_quote_number      IN  OKX_QUOTE_HEADERS_V.ID1%TYPE DEFAULT OKC_API.G_MISS_NUM
			     -- p_quote_number is in fact equal to quote ID
		--
			     ,p_trace_mode        IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
                             );


PROCEDURE update_quote_from_k(p_api_version     IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                             ,p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,p_commit          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,p_quote_id        IN  OKX_QUOTE_HEADERS_V.id1%TYPE DEFAULT OKC_API.G_MISS_NUM
                             ,p_contract_id     IN  OKC_K_HEADERS_B.ID%TYPE
                             ,p_trace_mode      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,x_return_status   OUT NOCOPY VARCHAR2
                             ,x_msg_count       OUT NOCOPY NUMBER
                             ,x_msg_data        OUT NOCOPY VARCHAR2
                             );


-------------------------------------------------------------------------------
--
-- APIs: K->O
--
-------------------------------------------------------------------------------

-- Procedure:       create_order_from_k
-- Version:         1.0
-- Purpose:         Create an order from a contract.
--                  The first one is planned to be called by a Conc. Prog.
--                  and calls itself the second one
--                  Provides process 7 in data flow diagram in HLD.
--                  Create relationships from contract to order
--                  May also create subject-to relationship from order
--                  to master contract if ordering contract is subject to
--                  a master contract
--                  Calls ASO_ORDER_PUB.CREATE_ORDER to create the order
-- In Parameters:   p_contract_id   Contract for which to create order
--                  p_rel_typ       Relation type to be created
-- Out Parameters:  x_order_id      Id of created order
--
-------------------------------------------------------------------------------

PROCEDURE create_order_from_k(ERRBUF              OUT NOCOPY VARCHAR2
			     ,RETCODE             OUT NOCOPY NUMBER
                             ,p_contract_category IN  OKC_K_HEADERS_B.SCS_CODE%TYPE DEFAULT OKC_API.g_miss_char
                             ,p_contract_number   IN  OKC_K_HEADERS_B.ID%TYPE
			  --
			  -- p_contract_number is in fact equal to contract ID
			  --
			     ,p_rel_type          IN  FND_LOOKUPS.LOOKUP_CODE%TYPE DEFAULT OKC_API.g_miss_char
			     ,p_trace_mode        IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
                             );


PROCEDURE create_order_from_k(p_api_version     IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                             ,p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,p_commit          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,x_return_status   OUT NOCOPY VARCHAR2
                             ,x_msg_count       OUT NOCOPY NUMBER
                             ,x_msg_data        OUT NOCOPY VARCHAR2
                             ,p_contract_id     IN  OKC_K_HEADERS_B.ID%TYPE
			     ,p_rel_type        IN  OKC_K_REL_OBJS.rty_code%TYPE DEFAULT OKC_API.g_miss_char
                             ,p_trace_mode      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,x_order_id        OUT NOCOPY okx_order_headers_v.id1%TYPE
                             );

-------------------------------------------------------------------------------
--
-- APIs: Q->K
--
-------------------------------------------------------------------------------


TYPE OKC_QUOTE_LINE_TAB IS TABLE OF OKX_QUOTE_LINES_V.ID1%TYPE INDEX BY BINARY_INTEGER;
G_MISS_QL_TAB OKC_QUOTE_LINE_TAB;

TYPE OKC_ORDER_LINE_TAB IS TABLE OF OKX_ORDER_LINES_V.ID1%TYPE INDEX BY BINARY_INTEGER;
G_MISS_OL_TAB  OKC_ORDER_LINE_TAB;


-- Procedure:       create_k_from_quote
-- Version:         1.0
-- Purpose:         Create a contract from a quote.
--                  Provides process 3.2.2 in data flow diagram in HLD.
--                  Create relationships from quote to contract
--                  The first one is planned to be called by a Conc. Prog.
--                  and calls itself the second one
-- In Parameters:   p_quote_id      Quote for which to create contract
--                  p_template_id   Template contract to use in creating
--                                  contract
--                  p_template_version  Template contract current version to use in creating
--                                      contract
--                  p_template_previous_version  Template contract previous version to use in creating
--                                      contract
-- Out Parameters:  x_contract_id   Id of created contract
--                  x_contract_number contract number of newly created contract

-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
PROCEDURE create_k_from_quote(ERRBUF              OUT NOCOPY VARCHAR2
                          ,RETCODE             OUT NOCOPY NUMBER
                          ,p_quote_id          IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                          ,p_contract_category IN  OKC_K_HEADERS_B.SCS_CODE%TYPE DEFAULT OKC_API.g_miss_char
                          ,p_template_id       IN  OKC_K_HEADERS_B.ID%TYPE
                          ,p_template_version  IN  NUMBER DEFAULT OKC_API.G_MISS_NUM
                          ,p_rel_type          IN  FND_LOOKUPS.LOOKUP_CODE%TYPE DEFAULT OKC_API.g_miss_char
                          ,p_trace_mode        IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
                          );


PROCEDURE create_k_from_quote(p_api_version     IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                          ,p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,p_commit          IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,p_quote_id        IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                          ,p_template_id     IN OKC_K_HEADERS_B.ID%TYPE DEFAULT OKC_API.G_MISS_NUM
                          ,p_template_version  IN NUMBER DEFAULT OKC_API.G_MISS_NUM
			  ,p_rel_type        IN OKC_K_REL_OBJS.RTY_CODE%TYPE DEFAULT OKC_API.G_MISS_CHAR
			  ,p_terms_agreed_flag IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,p_trace_mode      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,x_contract_id     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE
			  ,x_contract_number OUT NOCOPY OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
                          ,x_return_status   OUT NOCOPY VARCHAR2
                          ,x_msg_count       OUT NOCOPY NUMBER
                          ,x_msg_data        OUT NOCOPY VARCHAR2
                          );


-- Procedure:       create_k_from_quote
-- Version:         1.0
-- Purpose:         Create a contract from a quote.  Overloaded Procedure
--                  of the previous one for backward compatibility
--                  Does NOT return contract number
--                  Provides process 3.2.2 in data flow diagram in HLD.
--                  Create relationships from quote to contract
-- In Parameters:   p_quote_id      Quote for which to create contract
--                  p_template_id   Template contract to use in creating
--                                  contract
--                  p_template_version  Template contract current version to use in creating
--                                      contract
--                  p_template_previous_version  Template contract previous version to use in creating
--                                      contract
-- Out Parameters:  x_contract_id   Id of created contract

PROCEDURE create_k_from_quote(p_api_version     IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                          ,p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,p_commit          IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,p_quote_id        IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                          ,p_template_id     IN OKC_K_HEADERS_B.ID%TYPE DEFAULT OKC_API.G_MISS_NUM
                          ,p_template_version  IN  NUMBER DEFAULT OKC_API.G_MISS_NUM
			  ,p_rel_type        IN OKC_K_REL_OBJS.RTY_CODE%TYPE DEFAULT OKC_API.G_MISS_CHAR
                          ,p_trace_mode      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                          ,x_contract_id     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE
                          ,x_return_status   OUT NOCOPY VARCHAR2
                          ,x_msg_count       OUT NOCOPY NUMBER
                          ,x_msg_data        OUT NOCOPY VARCHAR2
                          );


-- Procedure:       create_k_relationships
-- Version:         1.0
-- Purpose:         1. Creates a relationship between the related sales
--                     contract and the new order.
--                     This is done at the header and line levels.
--                  2. Create the relationships between the related sales
--                     contract and the
--                     new service contract (created from the original order).
--                     This is done at the header and line levels.
--
-- In Parameters:   p_api_version         API version (to be initialized to 1)
--                  p_init_msg_list       Flag to reset the error message stack
--                  p_commit              Commit flag for the transaction
--                  p_sales_contract_id   Sales Contract header id as
--                                        created from Quote header id
--                  p_service_contract_id Service Contract header id as
--                                        created from Order header id
--                  p_quote_id            Quote header id
--                  p_quote_line_tab      Quote line ids  (PL/SQL table)
--                  p_order_id            Order header id as created from
--                                        Quote header id
--                  p_order_line_tab      Order line ids  (PL/SQL table)
--                  p_trace_mode          Trace mode option to generate
--                                        a trace file
--
-- Out Parameters:  x_return_status       Final status of the O-K relationship
--                                        creation API:
--                                        -OKC_API.G_RET_STS_SUCCESS
--                                        -OKC_API.G_RET_STS_ERROR
--                                        -OKC_API.G_RET_STS_UNEXP_ERROR
--  THIS IS A WRAPPER FOR OKC_OC_INT_KTO_PVT.create_k_relationships

PROCEDURE create_k_relationships(p_api_version       IN  NUMBER DEFAULT OKC_API.G_MISS_NUM
                               ,p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                               ,p_commit             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                               ,p_sales_contract_id  IN  OKC_K_HEADERS_B.ID%TYPE DEFAULT OKC_API.G_MISS_NUM
                               ,p_service_contract_id IN OKC_K_HEADERS_B.ID%TYPE DEFAULT OKC_API.G_MISS_NUM
                               ,p_quote_id           IN  OKX_QUOTE_HEADERS_V.ID1%TYPE DEFAULT OKC_API.G_MISS_NUM
                               ,p_quote_line_tab     IN  OKC_OC_INT_PUB.OKC_QUOTE_LINE_TAB DEFAULT OKC_OC_INT_PUB.G_MISS_QL_TAB
                               ,p_order_id           IN  OKX_ORDER_HEADERS_V.ID1%TYPE DEFAULT OKC_API.G_MISS_NUM
                               ,p_order_line_tab     IN  OKC_OC_INT_PUB.OKC_ORDER_LINE_TAB DEFAULT OKC_OC_INT_PUB.G_MISS_OL_TAB
                               ,p_trace_mode         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                               ,x_return_status      OUT NOCOPY VARCHAR2
                               ,x_msg_count          OUT NOCOPY NUMBER
                               ,x_msg_data           OUT NOCOPY VARCHAR2);


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
-- THIS IS A WRAPPER FOR OKC_OC_INT_QTK_PVT.create_interaction_history

PROCEDURE create_interaction_history(p_api_version    IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                               ,p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                               ,p_commit              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                               ,p_contract_id         IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                               ,p_party_id            IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                               ,p_interaction_subject IN  VARCHAR2
                               ,p_interaction_body    IN  VARCHAR2
                               ,p_trace_mode          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
			       ,x_return_status       OUT NOCOPY VARCHAR2
                               ,x_msg_count           OUT NOCOPY NUMBER
                               ,x_msg_data            OUT NOCOPY VARCHAR2);


-- Procedure:       notify_k_admin
-- Version:         1.0
-- ...

--  Modified by Igor Filimonov 10-04-2001
--  Bug : 1905226  OKC, ISTORE TESTING: K ALERT RESULTS GRID SHOULD POPULATE K# FIELD
--  Problem : Notifications in Launchpad's Inbox don't show KNUMBER in subject
--            and 'Contract Number' column
--  Fix:  p_contract_id was added into parameter list of notify_k_adm procedure

PROCEDURE notify_k_adm(p_api_version                    IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                      ,p_init_msg_list                  IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                      ,p_commit                         IN VARCHAR2 DEFAULT OKC_API.G_FALSE
		      ,p_application_name               IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_subject                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body 	                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token1 		IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token1_value 	IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token2 		IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token2_value 	IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token3 		IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      ,p_message_body_token3_value 	IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
                      ,p_trace_mode      		IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                      ,p_contract_id                    IN OKC_K_HEADERS_B.ID%TYPE DEFAULT NULL
                      ,x_k_admin_user_name   	 OUT NOCOPY VARCHAR2
                      ,x_return_status   	 OUT NOCOPY VARCHAR2
                      ,x_msg_count                      OUT NOCOPY NUMBER
                      ,x_msg_data                       OUT NOCOPY VARCHAR2
                        );


--  Added by Igor Filimonov 03-15-2002
-------------------------------------------------------------------------------
-- Procedure:       notify_sales_rep
-- Version:         1.0
-- Purpose:         API is used to retrive Quotation , contract status
--                  (If required) and generate notification to Order Capture
--                  and Istore
--                  THIS API IS CALLED FROM OKC_WF_K_APPROVE.NOTIFY_SALES_REP_W
-- IN Parameters   : p_contract_id, p_contract_status, p_trace_mode
--
-- OUT Parameters  : x_return_status
-------------------------------------------------------------------------------

PROCEDURE notify_sales_rep (p_api_version     IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                           ,p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,p_contract_id     IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                           ,p_contract_status IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
                           ,p_trace_mode      IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,p_commit          IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,x_return_status   OUT NOCOPY VARCHAR2
                           ,x_msg_count       OUT NOCOPY NUMBER
                           ,x_msg_data        OUT NOCOPY VARCHAR2
                           );

-- Procedure:       get_k_number
-- Version:         1.0
-- ...

PROCEDURE get_k_number(p_api_version IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                 ,p_init_msg_list    IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                 ,p_commit           IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                 ,p_contract_id      IN NUMBER
                 ,p_trace_mode       IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                 ,x_contract_number OUT NOCOPY OKC_K_HEADERS_B.contract_number%TYPE
                 ,x_contract_number_modifier OUT NOCOPY OKC_K_HEADERS_B.contract_number_modifier%TYPE
                 ,x_return_status   OUT NOCOPY VARCHAR2
                 ,x_msg_count       OUT NOCOPY NUMBER
                 ,x_msg_data        OUT NOCOPY VARCHAR2);


-- Procedure:       k_signed
-- Version:         1.0
-- Purpose:         While creating a contract from a quote, the contract is
--                  set within an ENTERED status. If the customer agrees
--                  with the standard TsandCs, this status has to be
--                  changed at its creation time from ENTERED to SIGNED.
--
--                  This procedure changes the status of the contract,
--                  either from an ENTERED status to a SIGNED status, or
--                  from an APPROVED status to a SIGNED status.
--
--                  This API will be called either directly from the creation
--                  contract API (ENTERED to SIGNED), or later by Order
--                  Capture/iStore (APPROVED to SIGNED)
--
--
-- In Parameters:   p_party_id        Contract header id
--                  p_date_signed     Signing date of the contract
--
-- Out Parameters:  x_return_status   Final status of the contract status update
--                                    -OKC_API.G_RET_STS_SUCCESS
--                                    -OKC_API.G_RET_STS_ERROR
--                                    -OKC_API.G_RET_STS_UNEXP_ERROR
-- THIS IS A PLAIN BARE-BONES WRAPPER FOR OKC_CONTRACT_APPROVAL_PUB.k_signed

PROCEDURE k_signed(p_api_version    IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                  ,p_init_msg_list  IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                  ,p_commit         IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                  ,p_contract_id    IN  NUMBER
                  ,p_date_signed    IN  DATE     DEFAULT SYSDATE
                  ,p_trace_mode     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
		  ,x_return_status  OUT NOCOPY VARCHAR2
                  ,x_msg_count      OUT NOCOPY NUMBER
                  ,x_msg_data       OUT NOCOPY VARCHAR2);


-- Procedure:       k_erase_approved
-- Version:         1.0
-- ...

PROCEDURE k_erase_approved(p_api_version     IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                  ,p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                  ,p_commit          IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                  ,p_contract_id    IN  NUMBER
                  ,p_trace_mode     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
		  ,x_return_status  OUT NOCOPY VARCHAR2
                  ,x_msg_count      OUT NOCOPY NUMBER
                  ,x_msg_data       OUT NOCOPY VARCHAR2);


-- Procedure:       get_articles
-- Version:         1.0
-- Purpose:         This is the public API which intent to call private API
--                  to select all articles for the contract.
-- In Parameters :  P_contract_id Id of the contract
-- Out Parameters:  x_articles    contract articles (clob datatype)

PROCEDURE get_articles (p_api_version     IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                       ,p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                       ,p_commit          IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                       ,p_contract_id     IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
		       ,p_release_id      IN   NUMBER DEFAULT NULL
                       ,p_trace_mode      IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                       ,x_articles        OUT NOCOPY OKC_K_ARTICLES_TL.TEXT%TYPE
                       ,x_return_status   OUT NOCOPY VARCHAR2
                       ,x_msg_count       OUT NOCOPY NUMBER
                       ,x_msg_data        OUT NOCOPY VARCHAR2);


-- Procedure:       Submit_Request
-- Version:         1.0
-- Purpose:         Outcome to submit concurrent requests
-- Arguments
--   application	- Short name of application under which the program
--			- is registered
--   program		- concurrent program name for which the request has
--			- to be submitted
--   description	- Optional. Will be displayed along with user
--			- concurrent program name
--   start_time	- Optional. Time at which the request has to start
--			- running
--   sub_request	- Optional. Set to TRUE if the request is submitted
--   			- from another running request and has to be treated
--			- as a sub request. Default is FALSE
--   argument1..100	- Optional. Arguments for the concurrent request
--

PROCEDURE submit_request (
			  application IN varchar2 default NULL,
			  program     IN varchar2 default NULL,
			  description IN varchar2 default NULL,
			  start_time  IN varchar2 default NULL,
			  sub_request IN boolean  default FALSE,
			  argument1   IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument2   IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument3   IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument4   IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument5   IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument6   IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument7   IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument8   IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument9   IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument10  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument11  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument12  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument13  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument14  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument15  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument16  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument17  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument18  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument19  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument20  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument21  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument22  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument23  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument24  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument25  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument26  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument27  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument28  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument29  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument30  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument31  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument32  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument33  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument34  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument35  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument36  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument37  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument38  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument39  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument40  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument41  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument42  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument43  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument44  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument45  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument46  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument47  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument48  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument49  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument50  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument51  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument52  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument53  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument54  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument55  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument56  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument57  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument58  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument59  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument60  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument61  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument62  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument63  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument64  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument65  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument66  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument67  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument68  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument69  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument70  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument71  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument72  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument73  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument74  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument75  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument76  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument77  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument78  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument79  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument80  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument81  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument82  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument83  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument84  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument85  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument86  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument87  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument88  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument89  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument90  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument91  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument92  IN varchar2 default OKC_API.G_MISS_CHAR,
  			  argument93  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument94  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument95  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument96  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument97  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument98  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument99  IN varchar2 default OKC_API.G_MISS_CHAR,
			  argument100  IN varchar2 default OKC_API.G_MISS_CHAR,
                          p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                         ,x_return_status   OUT NOCOPY VARCHAR2
                         ,x_msg_count       OUT NOCOPY NUMBER
                         ,x_msg_data        OUT NOCOPY VARCHAR2);
END OKC_OC_INT_PUB;

 

/
