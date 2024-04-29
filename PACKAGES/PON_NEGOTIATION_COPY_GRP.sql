--------------------------------------------------------
--  DDL for Package PON_NEGOTIATION_COPY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_NEGOTIATION_COPY_GRP" AUTHID CURRENT_USER AS
--$Header: PONGCPYS.pls 120.1.12010000.2 2009/09/06 08:13:21 atjen ship $


--
-- Different Copy types
--

-- Copy type for New round Creation
g_new_rnd_copy       VARCHAR2(15) := 'NEW_ROUND';

-- Copy type for Active and Published Negotiation
g_active_neg_copy    VARCHAR2(15) := 'COPY_ACTIVE';

-- Copy type for Draft Negotiaiton Copy
g_draft_neg_copy     VARCHAR2(15) := 'COPY_DRAFT';

-- Copy type for Amendment Creation
g_amend_copy         VARCHAR2(15) := 'AMENDMENT';

-- Copy type for RFI to Auction/RFQ Creation
g_rfi_to_other_copy  VARCHAR2(15) := 'COPY_TO_DOC';




-- Start of comments
--      API name  : COPY_NEGOTIATION
--
--      Type      : Group
--
--      Pre-reqs  : Negotiation with the given auction_header_id
--                        (p_source_auction_header_id) must exists in the database
--
--      Function  : Creates a negotiation from copying the negotiation
--                        with given auction_header_id (p_source_auction_header_id)
--
--     Parameters:
--     IN   :      p_api_version       NUMBER   Required
--     IN   :      p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_TRUE Optional
--     IN   :      p_is_conc_call            VARCHAR2   Required This indicates if the
--                                      procedure is called online or via a concurrent program
--     IN   :      p_source_auction_header_id  NUMBER Required, auction_header_id
--                                                      of the source negotiation
--     IN   :      p_trading_partner_id    NUMBER Required,  trading_partner_id of user
--                                                      for which the reultant negotiation will be created
--     IN   :      p_trading_partner_contact_id     NUMBER Required,
--                                                      trading_partner_contact_id of user for which the
--                                                      reultant negotiation will be created
--     IN   :      p_language         VARCHAR2 Required, language of the resultant negotiation
--     IN   :      p_user_id          NUMBER Required, user_id (FND) of the calling user;
--                                                      It will used for WHO informations also
--     IN   :      p_doctype_id       NUMBER Required, doctype_id of the output negotiation
--     IN   :      p_copy_type        VARCHAR2 Required, Type of Copy action;
--                                                      It should be one of the following -
--                                                      g_new_rnd_copy (NEW_ROUND)
--                                                      g_active_neg_copy (COPY_ACTIVE)
--                                                      g_draft_neg_copy (COPY_DRAFT)
--                                                      g_amend_copy (AMENDMENT)
--                                                      g_rfi_to_other_copy (COPY_TO_DOC)
--     IN   :      p_is_award_approval_reqd     VARCHAR2 Required, flag to decide if
--                                                      award approval is required;
--                                                      Permissible values are Y or N
--
--     IN   :      p_user_name      VARCHAR2 Required, user name of the caller in
--                                                     the PON_NEG_TEAM_MEMBERS.USER_NAME format
--
--     IN   :      p_mgr_id       NUMBER Required, manager id of the caller in
--                                                     the PON_NEG_TEAM_MEMBERS.USER_ID format
--
--     IN   :      p_retain_clause  VARCHAR2 Required, flag to carry forward the
--                                                      Contracts related information;
--                                                      Permissible values are Y or N
--     IN   :      p_update_clause  VARCHAR2 Required, flag to ue/updatedate the Contracts
--                                                      related information from library;
--                                                      Permissible values are Y or N
--     IN   :      p_retain_attachments      VARCHAR2 Required, flag to carry forward the
--                                                      attachments related to negotiation;
--                                                      Permissible values are Y or N
--     IN   :      p_large_auction_header_id NUMBER Optional, In the case of the
--                                                      source auction being a super large one,
--                                                      non null value of this parameter
--                                                      corresponds to the header id of the new
--                                                      auction whose header has been created.
--                                                      Non null values of this parameter
--                                                      indicate that this procedure is called from
--                                                      a concurrent procedure
--     IN   :      p_style_id         NUMBER Optional    This parameter gives the
--                                                      style id of the
--                                                      destination auction
--     OUT  :      x_auction_header_id      NUMBER,     auction_header_id of the
--                                                      generated negotiation;
--
--     OUT  :      x_document_number        NUMBER,       document number of the
--                                                      generated negotiation;
--
--     OUT  :      x_request_id             NUMBER,       id of the  concurrent
--                                                      request generated;
--
--     OUT  :      x_return_status          VARCHAR2, flag to indicate if the copy procedure
--                                                       was successful or not; It can have
--                                                      following values -
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_ERROR  (Success with warning)
--                                                         FND_API.G_RET_STS_UNEXP_ERROR (Failed due to error)
--
--     OUT  :      x_msg_count              NUMBER,   the number of warning of error messages due
--                                                       to this procedure call. It will have following
--                                                       values  -
--                                                       0 (for Success without warning)
--                                                       1 (for failure with error, check the
--                                                       x_return_status if it is error or waring)
--                                                       1 or more (for Success with warning, check the x_return_status)
--
--     OUT  :      x_msg_data               VARCHAR2,  the standard message data output parameter
--                                                       used to return the first message of the stack
--
--    Version    : Current version    1.0
--                 Previous version   1.0
--                 Initial version    1.0
--
-- End of comments


PROCEDURE COPY_NEGOTIATION(
                    p_api_version                 IN          NUMBER,
                    p_init_msg_list               IN          VARCHAR2,
                    p_is_conc_call                IN          VARCHAR2,
                    p_source_auction_header_id    IN          NUMBER,
                    p_trading_partner_id          IN          NUMBER ,
                    p_trading_partner_contact_id  IN          NUMBER ,
                    p_language                    IN          VARCHAR2,
                    p_user_id                     IN          NUMBER,
                    p_doctype_id                  IN          NUMBER,
                    p_copy_type                   IN          VARCHAR2,
                    p_is_award_approval_reqd      IN          VARCHAR2,
                    p_user_name                   IN          VARCHAR2,
                    p_mgr_id                      IN          NUMBER,
                    p_retain_clause               IN          VARCHAR2,
                    p_update_clause               IN          VARCHAR2,
                    p_retain_attachments          IN          VARCHAR2,
                    p_large_auction_header_id     IN         NUMBER,
                    p_style_id                    IN         NUMBER,
                    x_auction_header_id           OUT NOCOPY  NUMBER,
                    x_document_number             OUT NOCOPY VARCHAR2,
                    x_request_id                  OUT NOCOPY  NUMBER,
                    x_return_status               OUT NOCOPY  VARCHAR2,
                    x_msg_count                   OUT NOCOPY  NUMBER,
                    x_msg_data                    OUT NOCOPY  VARCHAR2
                    );


--
-- This is a function required for the COPY_NEGOTIATION procedure
-- and shouldn't be used any where validates negotiation team members
--
-- CAUTION: This function may get removed. So, consult it before use.

FUNCTION HAS_NEED_TO_COPY_MEMBER ( p_login_user_id           NUMBER,
                                   p_login_manager_id        NUMBER,
                                   p_copy_type               VARCHAR2,
                                   p_memeber_id              NUMBER,
                                   p_memeber_type            VARCHAR2,
                                   p_busines_group_id        NUMBER,
                                   p_member_busines_group_id NUMBER,
                                   p_member_eff_start_date   DATE,
                                   p_member_eff_end_date     DATE,
                                   p_member_user_start_date  DATE,
                                   p_member_user_end_date    DATE) RETURN VARCHAR2;



--     Parameters:
--     IN   :      p_api_version               NUMBER   Required
--     IN   :      p_init_msg_list             VARCHAR2 DEFAULT   FND_API.G_TRUE Optional
--     IN   :      p_source_auction_header_id  NUMBER Required, auction_header_id of the source negotiation
--     IN   :      p_trading_partner_id        NUMBER Required,  trading_partner_id of user
--                                                      for which the reultant negotiation will be created
--     IN   :      p_trading_partner_contact_id NUMBER Required,  trading_partner_contact_id of
--                                                       user for which the reultant negotiation will be created
--     IN   :      p_language                  VARCHAR2 Required, language of the resultant negotiation
--     IN   :      p_user_id                   NUMBER Required, user_id (FND) of the calling user;
--                                                          It will used for WHO informations also
--     IN   :      p_doctype_id                NUMBER Required, doctype_id of the output negotiation
--     IN   :      p_copy_type                 VARCHAR2 Required, Type of Copy action;
--                                                   It should be one of the following -
--                                                        g_new_rnd_copy (NEW_ROUND)
--                                                        g_active_neg_copy (COPY_ACTIVE)
--                                                        g_draft_neg_copy (COPY_DRAFT)
--                                                        g_amend_copy (AMENDMENT)
--                                                        g_rfi_to_other_copy (COPY_TO_DOC)
--     IN   :      p_is_award_approval_reqd    VARCHAR2 Required, flag to decide if
--                                                         award approval is required;
--                                                         Permissible values are Y or N
--
--     IN   :      p_user_name                 VARCHAR2 Required, user name of the caller in
--                                                     the PON_NEG_TEAM_MEMBERS.USER_NAME format
--
--     IN   :      p_mgr_id                  NUMBER Required, manager id of the caller in
--                                                     the PON_NEG_TEAM_MEMBERS.USER_ID format
--
--     IN   :      p_retain_clause             VARCHAR2 Required, flag to carry forward the
--                                                       Contracts related information;
--                                                       Permissible values are Y or N
--     IN   :      p_update_clause             VARCHAR2 Required, flag to update the Contracts
--                                                       related information from library;
--                                                          Permissible values are Y or N
--     IN   :      p_retain_attachments        VARCHAR2 Required, flag to carry forward the
--                                                       attachments related to negotiation;
--                                                       Permissible values are Y or N
--     IN   :      p_large_auction_header_id NUMBER Optional, In the case of the
--                                                      source auction being a
--                                                      super large one,
--                                                      non null value of this
--                                                      parameter
--                                                      corresponds to the
--                                                      header id of the new
--                                                      auction whose header has
--                                                      been created.
--                                                      Non null values of this
--                                                      parameter
--                                                      indicate that this
--                                                      procedure is called from
--                                                      a concurrent procedure
--                                                      and null
--                                                      values of this parameter
--                                                      indicates the
--                                                      procedure being called
--                                                      online.
--     IN   :      p_style_id         NUMBER Optional    This parameter gives
--                                                       the
--                                                      style id of the
--                                                      destination auction
PROCEDURE PON_CONC_COPY_SUPER_LARGE_NEG (
                    EFFBUF           OUT NOCOPY VARCHAR2,
                    RETCODE          OUT NOCOPY VARCHAR2,
                    p_api_version                IN         NUMBER,
                    p_init_msg_list              IN         VARCHAR2 DEFAULT FND_API.G_TRUE,
                    p_source_auction_header_id   IN         NUMBER,
                    p_trading_partner_id         IN         NUMBER ,
                    p_trading_partner_contact_id IN         NUMBER ,
                    p_language                   IN         VARCHAR2,
                    p_user_id                    IN         NUMBER,
                    p_doctype_id                 IN         NUMBER,
                    p_copy_type                  IN         VARCHAR2,
                    p_is_award_approval_reqd     IN         VARCHAR2,
                    p_user_name                  IN         VARCHAR2,
                    p_mgr_id                     IN         NUMBER,
                    p_retain_clause              IN         VARCHAR2,
                    p_update_clause              IN         VARCHAR2,
                    p_retain_attachments         IN         VARCHAR2,
                    p_large_auction_header_id    IN         NUMBER,
                    p_style_id                   IN         NUMBER);

--PROCEDURE NAME: PON_LRG_DRAFT_TO_ORD_PF_COPY
--
--This procedure creates the relevant records for a large destination
--auction in the case of a copy from a large DRAFT to a normal auction.
--
--p_source_auction_hdr_id    IN
--DATATYPE: pon_large_neg_pf_values.AUCTION_HEADER_ID%type
--This parameter is the auction_header_id of the source auction
--
--p_destination_auction_hdr_id    IN
--DATATYPE: pon_large_neg_pf_values.AUCTION_HEADER_ID%type
--This parameter is the auction_header_id of the destination auction
--
--p_user_id    IN
--DATATYPE: NUMBER
--This parameter is the id of the user invoking the procedure

PROCEDURE  PON_LRG_DRAFT_TO_ORD_PF_COPY (
                p_source_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                p_destination_auction_hdr_id IN pon_large_neg_pf_values.AUCTION_HEADER_ID%type,
                p_user_id IN number,
                p_from_line_number         IN NUMBER,
                p_to_line_number           IN NUMBER);

--
-- TEAM SCORING PROCEDURE TO COPY SCORING TEAMS, MEMBERS AND ASSIGNMENTS
--

--------------------------------------------------------------------------
--
-- This procedure copies the details of the scoring teams
--
--  Tables handled here:
--
--  PON_SCORING_TEAMS   : Stores name of team, instructions
--  PON_SCORING_TEAM_MEMBERS  : Stores the members of the team
--  PON_SCORING_TEAM_SECTIONS : Stores the sections that the team has to score
--
-- Business rules:
--
--  1.  If the negotiation style of the target document does not allow
--      scoring teams, then do not copy any rows
--
--  2.  If the source auction does not have any scoring teams
-- 		do not attempt to copy teams or children over.
--
--  3.  If a collaboration team member is invalid at the time of copying
--      do not add him as a member
--
--------------------------------------------------------------------------

PROCEDURE COPY_SCORING_TEAMS(
    p_source_auction_header_id        	IN NUMBER,
    p_auction_header_id               	IN NUMBER,
    p_user_id                      		IN NUMBER
    );

--
-- END TEAM SCORING
--

-- Begin Supplier Management: Evaluation Team
--
-- This procedure copies the details of the evaluation teams
--
PROCEDURE COPY_EVALUATION_TEAMS(
    p_source_auction_header_id    IN NUMBER,
    p_auction_header_id           IN NUMBER,
    p_user_id                     IN NUMBER
    );
-- End Supplier Management: Evaluation Team

END PON_NEGOTIATION_COPY_GRP;

/
