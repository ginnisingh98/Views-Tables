--------------------------------------------------------
--  DDL for Package Body PON_BIZ_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_BIZ_EVENTS_PVT" AS
--$Header: PONVEVTB.pls 120.0 2005/06/01 18:30:19 appldev noship $

g_pkg_name      CONSTANT VARCHAR2(25):='PON_BIZ_EVENTS_PVT';

g_err_loc       VARCHAR2(400);

-- Global variable for status which will be set in different sub-procedures
g_return_status VARCHAR2(50);

-- Indicate if the debug mode is on
g_debug_mode    VARCHAR2(10);

-- module name for logging message
g_module_prefix CONSTANT VARCHAR2(40) := 'pon.plsql.pon_biz_events_pvt.';

PROCEDURE RAISE_EVENT (
		    p_api_version      IN NUMBER,
                    p_init_msg_list    IN VARCHAR2,
		    p_event_name       IN VARCHAR2,
                    p_event_key        IN VARCHAR2,
		    p_parameter_list   IN WF_PARAMETER_LIST_T,
       		    x_return_status    IN OUT NOCOPY VARCHAR2,
		    x_msg_count        IN OUT NOCOPY NUMBER,
		    x_msg_data         IN OUT NOCOPY VARCHAR2);

PROCEDURE LOG_MESSAGE( p_module IN VARCHAR2, p_message IN VARCHAR2) ;

-- Start of comments
--      API name  : RAISE_NEG_PUB_EVENT
--      Type      : Private
--      Pre-reqs  : Negotiation with the given auction_header_id
--                  (p_source_auction_header_id) must exists in the database and it
--                  should be published in the current transaction context
--      Function  : Calls Workflow API to raise a Business Event for Negotiation
--                  publication event for the given auction_header_id (p_auction_header_id)
--      Modifies  : None
--      Locks     : None
--
--     Parameters :
--         IN     :      p_api_version       NUMBER   Required
--         IN            p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_TRUE Optional
--         IN     :      p_commit            VARCHAR2   DEFAULT   FND_API.G_TRUE Optional
--         IN     :      p_auction_header_id NUMBER Required, auction_header_id
--                                           of the negotiation published
--         OUT    :      x_return_status     VARCHAR2,     flag to indicate if the procedure
--                                           was successful or not; It can have
--                                           following values -
--                                               FND_API.G_RET_STS_SUCCESS (Success)
--                                               FND_API.G_RET_STS_ERROR (Failed due to error)
--         OUT    :      x_msg_count         NUMBER,    the number of warning of error messages due
--                                           to this procedure call. It will have following
--                                           values  -
--                                               0 (for Success without warning)
--                                               1 or more (for Error(s)/Warning(s)
--         OUT    :      x_msg_data          VARCHAR2,    the standard message data output parameter
--                                           used to return the first message of the stack
--	 Version  : Current version	1.0
--                  Previous version 	1.0
--		  Initial version 	1.0
--
-- End of comments
PROCEDURE RAISE_NEG_PUB_EVENT (
                   p_api_version       IN NUMBER,
	           p_init_msg_list     IN VARCHAR2  ,
		   p_commit            IN VARCHAR2 ,
		   p_auction_header_id IN NUMBER,
		   x_return_status     IN OUT NOCOPY VARCHAR2,
		   x_msg_count         IN OUT NOCOPY NUMBER,
		   x_msg_data          IN OUT NOCOPY VARCHAR2)
IS
	l_auction_header_id   PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID%TYPE;
	l_document_number     PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
	l_auction_title       PON_AUCTION_HEADERS_ALL.AUCTION_TITLE%TYPE;
	l_open_bidding_date   VARCHAR2(100);
	l_close_bidding_date  VARCHAR2(100);
	l_publish_date        VARCHAR2(100);

	l_parameter_list      WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();

BEGIN
 -- { Start of RAISE_NEG_PUB_EVENT

        BEGIN
                g_debug_mode := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
        EXCEPTION
                WHEN OTHERS THEN
                    g_debug_mode := 'N';
        END;

        LOG_MESSAGE('raise_neg_pub_event','is being called');

        --
        -- Populate the Business Event parameters
        --
	SELECT
		AUCTION_HEADER_ID,
		DOCUMENT_NUMBER ,
		AUCTION_TITLE,
		TO_CHAR(OPEN_BIDDING_DATE,'dd-mm-yyyy hh24:mi:ss'),
		TO_CHAR(CLOSE_BIDDING_DATE,'dd-mm-yyyy hh24:mi:ss'),
		TO_CHAR(PUBLISH_DATE,'dd-mm-yyyy hh24:mi:ss')
	INTO
		l_auction_header_id,
		l_document_number,
		l_auction_title,
		l_open_bidding_date,
		l_close_bidding_date,
		l_publish_date
	 FROM PON_AUCTION_HEADERS_ALL
	 WHERE AUCTION_HEADER_ID = p_auction_header_id;

	--
	-- Add the parameters
	--
	wf_event.AddParameterToList( p_name => 'auction_header_id',
			             p_value => l_auction_header_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'document_number',
				     p_value => l_document_number,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'auction_title',
				     p_value => l_auction_title,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'open_bidding_date',
				     p_value => l_open_bidding_date,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'close_bidding_date',
				     p_value => l_close_bidding_date,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'publish_date',
				     p_value => l_publish_date,
				     p_parameterlist => l_parameter_list);

	RAISE_EVENT (
		    p_api_version     => p_api_version,
                    p_init_msg_list   => p_init_msg_list,
		    p_event_name      => 'oracle.apps.pon.event.negotiation.publish',
		    p_event_key       => to_char(l_auction_header_id),
		    p_parameter_list  =>  l_parameter_list,
       		    x_return_status   => x_return_status,
		    x_msg_count       => x_msg_count,
		    x_msg_data        => x_msg_data);

 END;
-- } End of RAISE_NEG_PUB_EVENT


-- Start of comments
--      API name    : RAISE_RESPNSE_PUB_EVENT
--      Type        : Private
--      Pre-reqs    : Response with the given bid_number
--                   (p_bid_number) must exists in the database
--      Function    : Calls Workflow API to raise a Business Event for Negotiation
--                    publication of Response event for the
--                    given bid_number (p_bid_number)
--      Modifies    : None
--      Locks       : None
--
--     Parameters   :
--           IN     :      p_api_version   NUMBER   Required
--           IN     :      p_init_msg_list VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--           IN     :      p_commit        VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--           IN     :      p_bid_number    NUMBER Required, bid_number
--                                         of the Response published
--           OUT    :      x_return_status VARCHAR2,     flag to indicate if the procedure
--                                         was successful or not; It can have
--                                         following values -
--                                              FND_API.G_RET_STS_SUCCESS (Success)
--                                              FND_API.G_RET_STS_ERROR (Failed due to error)
--           OUT    :      x_msg_count     NUMBER,    the number of warning of error messages due
--                                         to this procedure call. It will have following
--                                         values  -
--                                              0 (for Success without warning)
--                                              1 or more (for Error(s)/Warning(s)
--           OUT    :      x_msg_data      VARCHAR2,    the standard message data output parameter
--                                         used to return the first message of the stack
--	   Version  : Current version	1.0
--                    Previous version 	1.0
--		      Initial version 	1.0
--
-- End of comments

PROCEDURE RAISE_RESPNSE_PUB_EVENT(
                p_api_version      IN  NUMBER,
                p_init_msg_list    IN  VARCHAR2 ,
                p_commit           IN  VARCHAR2,
                p_bid_number       IN  NUMBER,
                x_return_status    IN  OUT NOCOPY VARCHAR2,
                x_msg_count        IN  OUT NOCOPY NUMBER,
                x_msg_data         IN  OUT NOCOPY VARCHAR2
)
IS
	l_bid_number                 PON_BID_HEADERS. BID_NUMBER%TYPE;
	l_auction_header_id          PON_BID_HEADERS. AUCTION_HEADER_ID%TYPE;
	l_document_number            PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
	l_trading_partner_contact_id PON_BID_HEADERS.TRADING_PARTNER_CONTACT_ID%TYPE;
	l_trading_partner_id         PON_BID_HEADERS.TRADING_PARTNER_ID%TYPE;
	l_publish_date               VARCHAR2(100);
	l_surr_bid_created_contct_id PON_BID_HEADERS.SURROG_BID_CREATED_CONTACT_ID%TYPE;
	l_surrog_bid_created_tp_id   PON_BID_HEADERS.SURROG_BID_CREATED_TP_ID%TYPE;

	l_parameter_list             WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();

BEGIN
 -- { Start of RAISE_RESPNSE_PUB_EVENT

        BEGIN
                g_debug_mode := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
        EXCEPTION
                WHEN OTHERS THEN
                    g_debug_mode := 'N';
        END;

        LOG_MESSAGE('raise_neg_pub_event','is being called');

        --
        -- Populate the Business Event parameters
        --
	SELECT
		B.BID_NUMBER,
		B.AUCTION_HEADER_ID,
		A.DOCUMENT_NUMBER,
		B.TRADING_PARTNER_CONTACT_ID,
		B.TRADING_PARTNER_ID,
		TO_CHAR(B.PUBLISH_DATE,'dd-mm-yyyy hh24:mi:ss'),
		B.SURROG_BID_CREATED_CONTACT_ID,
		B.SURROG_BID_CREATED_TP_ID
	INTO
		l_bid_number,
		l_auction_header_id,
		l_document_number,
		l_trading_partner_contact_id,
		l_trading_partner_id,
		l_publish_date,
		l_surr_bid_created_contct_id,
		l_surrog_bid_created_tp_id
	 FROM PON_BID_HEADERS B, PON_AUCTION_HEADERS_ALL A
	 WHERE B.BID_NUMBER = p_bid_number
	 AND A.AUCTION_HEADER_ID = B.AUCTION_HEADER_ID;

	--
	-- Add the parameters
	--
	wf_event.AddParameterToList( p_name => 'bid_number',
				     p_value => l_bid_number,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'auction_header_id',
				     p_value => l_auction_header_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'document_number',
				     p_value => l_document_number,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'bidder_tp_contact_id',
				     p_value => l_trading_partner_contact_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'bidder_tp_id',
				     p_value => l_trading_partner_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'publish_date',
				     p_value => l_publish_date,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'surrog_tp_contact_id',
				     p_value => l_surr_bid_created_contct_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'surrog_tp_id',
				     p_value => l_surrog_bid_created_tp_id,
				     p_parameterlist => l_parameter_list);


	RAISE_EVENT (
		    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
		    p_event_name     => 'oracle.apps.pon.event.response.publish',
                    p_event_key      => to_char(l_bid_number),
		    p_parameter_list =>  l_parameter_list,
       		    x_return_status  => x_return_status,
		    x_msg_count      => x_msg_count,
		    x_msg_data       => x_msg_data);

 END;
-- } End of RAISE_RESPNSE_PUB_EVENT


-- Start of comments
--      API name   : RAISE_RESPNSE_DISQ_EVENT
--      Type       : Private
--      Pre-reqs   : Response with the given bid_number
--                   (p_bid_number) must exists in the database
--      Function   : Calls Workflow API to raise a Business Event for Disqualification
--                   of Response event for the given bid_number (p_bid_number)
--      Modifies   : None
--      Locks      : None
--
--     Parameters  :
--          IN     :      p_api_version    NUMBER   Required
--          IN     :      p_init_msg_list  VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--          IN     :      p_commit         VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--          IN     :      p_bid_number     NUMBER Required, bid_number
--                                         of the Response published
--          OUT    :      x_return_status  VARCHAR2,     flag to indicate if the procedure
--                                         was successful or not; It can have
--                                         following values -
--                                            FND_API.G_RET_STS_SUCCESS (Success)
--                                            FND_API.G_RET_STS_ERROR (Failed due to error)
--          OUT    :      x_msg_count      NUMBER,    the number of warning of error messages due
--                                         to this procedure call. It will have following
--                                         values  -
--                                            0 (for Success without warning)
--                                            1 or more (for Error(s)/Warning(s)
--          OUT    :      x_msg_data       VARCHAR2,    the standard message data output parameter
--                                         used to return the first message of the stack
--	  Versioni : Current version	1.0
--                   Previous version 	1.0
--		     Initial version 	1.0
--
-- End of comments


PROCEDURE RAISE_RESPNSE_DISQ_EVENT
(
    p_api_version      IN NUMBER,
    p_init_msg_list    IN VARCHAR2 ,
    p_commit           IN VARCHAR2 ,
    p_bid_number       IN NUMBER,
    x_return_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count        IN OUT NOCOPY NUMBER,
    x_msg_data         IN OUT NOCOPY VARCHAR2
)
IS
	l_bid_number                 PON_BID_HEADERS. BID_NUMBER%TYPE;
	l_auction_header_id          PON_BID_HEADERS. AUCTION_HEADER_ID%TYPE;
	l_document_number            PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
	l_trading_partner_contact_id PON_BID_HEADERS.TRADING_PARTNER_CONTACT_ID%TYPE;
	l_trading_partner_id         PON_BID_HEADERS.TRADING_PARTNER_ID%TYPE;
	l_publish_date               VARCHAR2(100);
	l_last_update_date           VARCHAR2(100);
	l_disqualify_reason          PON_BID_HEADERS.DISQUALIFY_REASON%TYPE;

	l_parameter_list             WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();

BEGIN
 -- { Start of RAISE_RESPNSE_DISQ_EVENT

        BEGIN
                g_debug_mode := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
        EXCEPTION
                WHEN OTHERS THEN
                    g_debug_mode := 'N';
        END;

        LOG_MESSAGE('raise_neg_pub_event','is being called');

        --
        -- Populate the Business Event parameters
        --
	SELECT
		B.BID_NUMBER,
		B.AUCTION_HEADER_ID,
		A.DOCUMENT_NUMBER,
		B.TRADING_PARTNER_CONTACT_ID,
		B.TRADING_PARTNER_ID,
		TO_CHAR(B.PUBLISH_DATE,'dd-mm-yyyy hh24:mi:ss'),
		TO_CHAR(B.LAST_UPDATE_DATE,'dd-mm-yyyy hh24:mi:ss'),
		B.DISQUALIFY_REASON
	INTO
		l_bid_number,
		l_auction_header_id,
		l_document_number,
		l_trading_partner_contact_id,
		l_trading_partner_id,
		l_publish_date,
		l_last_update_date,
		l_disqualify_reason
	 FROM PON_BID_HEADERS B, PON_AUCTION_HEADERS_ALL A
	 WHERE B.BID_NUMBER = p_bid_number
	 AND A.AUCTION_HEADER_ID = B.AUCTION_HEADER_ID;


	--
	-- Add the parameters
	--
	wf_event.AddParameterToList( p_name => 'bid_number',
				     p_value => l_bid_number,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'auction_header_id',
				     p_value => l_auction_header_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'document_number',
				     p_value => l_document_number,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'bidder_tp_contact_id',
				     p_value => l_trading_partner_contact_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'bidder_tp_id',
				     p_value => l_trading_partner_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'publish_date',
				     p_value => l_publish_date,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'disqualify_date',
				     p_value => l_last_update_date,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'disqualify_reason',
				     p_value => l_disqualify_reason,
				     p_parameterlist => l_parameter_list);


	RAISE_EVENT (
		    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
		    p_event_name     => 'oracle.apps.pon.event.response.disqualify',
                    p_event_key      => to_char(l_bid_number),
		    p_parameter_list =>  l_parameter_list,
       		    x_return_status  => x_return_status,
		    x_msg_count      => x_msg_count,
		    x_msg_data       => x_msg_data);

 END;
-- } End of RAISE_RESPNSE_DISQ_EVENT


-- Start of comments
--      API name   : RAISE_NEG_AWD_APPR_STRT_EVENT
--      Type       : Private
--      Pre-reqs   : Negotiation with the given auction_header_id
--                   (p_auction_header_id) must exists in the database
--      Function   : Calls Workflow API to raise a Business Event for Submission
--                   of Award Approval  event for the given auction_header_id (p_auction_header_id)
--      Modifies   : None
--      Locks      : None
--
--     Parameters  :
--          IN     :      p_api_version       NUMBER   Required
--          IN     :      p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--          IN     :      p_commit            VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--          IN     :      p_auction_header_id NUMBER Required, auction_header_id
--                                            of the Negotiation submitted
--          OUT    :      x_return_status     VARCHAR2,     flag to indicate if the procedure
--                                            was successful or not; It can have
--                                            following values -
--                                                  FND_API.G_RET_STS_SUCCESS (Success)
--                                                  FND_API.G_RET_STS_ERROR (Failed due to error)
--          OUT    :      x_msg_count         NUMBER,    the number of warning of error messages due
--                                            to this procedure call. It will have following
--                                            values  -
--                                                  0 (for Success without warning)
--                                                  1 or more (for Error(s)/Warning(s)
--          OUT    :      x_msg_data          VARCHAR2,    the standard message data output parameter
--                                            used to return the first message of the stack
--	  Version  : Current version	1.0
--                   Previous version 	1.0
--		     Initial version 	1.0
--
-- End of comments


PROCEDURE RAISE_NEG_AWD_APPR_STRT_EVENT(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2,
    p_commit            IN  VARCHAR2,
    p_auction_header_id IN  NUMBER,
    x_return_status     IN OUT NOCOPY VARCHAR2,
    x_msg_count         IN OUT NOCOPY NUMBER,
    x_msg_data          IN OUT NOCOPY VARCHAR2
)
IS
	l_auction_header_id          PON_AUCTION_HEADERS_ALL. AUCTION_HEADER_ID%TYPE;
	l_document_number 	     PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
	l_award_appr_ame_trans_id    PON_AUCTION_HEADERS_ALL.AWARD_APPR_AME_TRANS_ID%TYPE;
	l_award_appr_ame_txn_date    VARCHAR2(100);
	l_award_approval_status	     PON_AUCTION_HEADERS_ALL.AWARD_APPROVAL_STATUS%TYPE;
	l_wf_award_approval_item_key PON_AUCTION_HEADERS_ALL.WF_AWARD_APPROVAL_ITEM_KEY%TYPE;

	l_parameter_list             WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();

BEGIN
 -- { Start of RAISE_NEG_AWD_APPR_START_EVENT

        BEGIN
                g_debug_mode := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
        EXCEPTION
                WHEN OTHERS THEN
                    g_debug_mode := 'N';
        END;

        LOG_MESSAGE('RAISE_NEG_AWRD_APPR_START_EVENT','is being called');

        --
        -- Populate the Business Event parameters
        --
	SELECT
		AUCTION_HEADER_ID,
		DOCUMENT_NUMBER ,
		AWARD_APPR_AME_TRANS_ID,
		TO_CHAR(AWARD_APPR_AME_TXN_DATE,'dd-mm-yyyy hh24:mi:ss'),
		AWARD_APPROVAL_STATUS,
		WF_AWARD_APPROVAL_ITEM_KEY
	INTO
		l_auction_header_id,
		l_document_number,
		l_award_appr_ame_trans_id,
		l_award_appr_ame_txn_date,
		l_award_approval_status,
		l_wf_award_approval_item_key
	 FROM PON_AUCTION_HEADERS_ALL
	 WHERE AUCTION_HEADER_ID = p_auction_header_id;

	--
	-- Add the parameters
	--
	wf_event.AddParameterToList( p_name => 'auction_header_id',
				     p_value => l_auction_header_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'document_number',
				     p_value => l_document_number,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'ame_transaction_id',
				     p_value => l_award_appr_ame_trans_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'ame_last_trans_date',
				     p_value => l_award_appr_ame_txn_date,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'award_approval_status',
				     p_value => l_award_approval_status,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'wf_award_appr_item_key',
				     p_value => l_wf_award_approval_item_key,
				     p_parameterlist => l_parameter_list);

	RAISE_EVENT (
		    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
		    p_event_name     => 'oracle.apps.pon.event.negotiation.award_approval_start',
                    p_event_key      => to_char(l_auction_header_id)||'-'||to_char(l_award_appr_ame_trans_id),
		    p_parameter_list => l_parameter_list,
       		    x_return_status  => x_return_status,
		    x_msg_count      => x_msg_count,
		    x_msg_data       => x_msg_data);

 END;
-- } End of RAISE_NEG_AWD_APPR_START_EVENT



-- Start of comments
--      API name   : RAISE_NEG_AWRD_COMPLETE_EVENT
--      Type       : Private
--      Pre-reqs   : Negotiation with the given auction_header_id
--                   (p_auction_header_id) must exists in the database
--      Function   : Calls Workflow API to raise a Business Event for Completion
--                   of Award event for the given auction_header_id (p_auction_header_id)
--      Modifies   : None
--      Locks      : None
--
--     Parameters  :
--          IN     :      p_api_version        NUMBER   Required
--          IN     :      p_init_msg_list      VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--          IN     :      p_commit             VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--          IN     :      p_auction_header_id  NUMBER Required, p_auction_header_id
--                                             of the Negotiation completed
--          IN     :      p_create_po_flag     VARCHAR2 Required, Flag to indicate if the user
--                                             has decided to create PO after the completion of
--                                             of the Award of the given Negotiation
--          OUT    :      x_return_status      VARCHAR2,     flag to indicate if the procedure
--                                             was successful or not; It can have
--                                             following values -
--                                                  FND_API.G_RET_STS_SUCCESS (Success)
--                                                  FND_API.G_RET_STS_ERROR (Failed due to error)
--          OUT    :      x_msg_count                 NUMBER,    the number of warning of error messages due
--                                             to this procedure call. It will have following
--                                             values  -
--                                                  0 (for Success without warning)
--                                                  1 or more (for Error(s)/Warning(s)
--          OUT    :      x_msg_data           VARCHAR2,    the standard message data output parameter
--                                             used to return the first message of the stack
--	Version	   : Current version	1.0
--                   Previous version 	1.0
--	             Initial version 	1.0
--
-- End of comments


PROCEDURE RAISE_NEG_AWRD_COMPLETE_EVENT(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 ,
    p_commit             IN  VARCHAR2 ,
    p_auction_header_id IN  NUMBER,
    p_create_po_flag     IN  VARCHAR2,
    x_return_status      IN OUT NOCOPY VARCHAR2,
    x_msg_count          IN OUT NOCOPY NUMBER,
    x_msg_data           IN OUT NOCOPY VARCHAR2
)
IS
	l_auction_header_id     PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID%TYPE;
	l_document_number       PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER%TYPE;
	l_outcome_status        PON_AUCTION_HEADERS_ALL.OUTCOME_STATUS%TYPE;
	l_source_reqs_flag	PON_AUCTION_HEADERS_ALL.SOURCE_REQS_FLAG%TYPE;
	l_share_award_decision	PON_AUCTION_HEADERS_ALL.SHARE_AWARD_DECISION%TYPE;
	l_award_complete_date   VARCHAR2(100);
        l_requisition_based_flag VARCHAR2(3);

	l_parameter_list        WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();

BEGIN
 -- { Start of RAISE_NEG_AWRD_COMPLETE_EVENT

        BEGIN
                g_debug_mode := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
        EXCEPTION
                WHEN OTHERS THEN
                    g_debug_mode := 'N';
        END;

        LOG_MESSAGE('RAISE_NEG_AWRD_COMPLETE_EVENT','is being called');

        --
        -- Populate the Business Event parameters
        --
	SELECT
		AUCTION_HEADER_ID,
		DOCUMENT_NUMBER ,
		OUTCOME_STATUS,
		SOURCE_REQS_FLAG,
		SHARE_AWARD_DECISION,
		TO_CHAR(AWARD_COMPLETE_DATE,'dd-mm-yyyy hh24:mi:ss'),
	        DECODE(NVL(AUCTION_ORIGINATION_CODE,'N'),'REQUISITION','Y','N')
	INTO
		l_auction_header_id ,
		l_document_number ,
		l_outcome_status,
		l_source_reqs_flag,
		l_share_award_decision,
		l_award_complete_date,
                l_requisition_based_flag
	 FROM PON_AUCTION_HEADERS_ALL
	 WHERE AUCTION_HEADER_ID = p_auction_header_id;

	--
	-- Add the parameters
	--
	wf_event.AddParameterToList( p_name => 'auction_header_id',
				     p_value => l_auction_header_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'document_number',
				     p_value => l_document_number,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'outcome_status',
				     p_value => l_outcome_status,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'create_po_flag',
				     p_value => p_create_po_flag,
				     p_parameterlist => l_parameter_list);

        wf_event.AddParameterToList( p_name => 'has_requisition_flag',
                                     p_value => l_requisition_based_flag,
                                     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'source_backing_req_lines',
				     p_value => l_source_reqs_flag,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'share_award_decision_flag',
				     p_value => l_share_award_decision,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'award_complete_date',
				     p_value => l_award_complete_date,
				     p_parameterlist => l_parameter_list);


	RAISE_EVENT (
		    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
		    p_event_name     => 'oracle.apps.pon.event.negotiation.award_complete',
                    p_event_key      => to_char(l_auction_header_id),
		    p_parameter_list =>  l_parameter_list,
       		    x_return_status  => x_return_status,
		    x_msg_count      => x_msg_count,
		    x_msg_data       => x_msg_data);

 END;
-- } End of RAISE_NEG_AWRD_COMPLETE_EVENT



-- Start of comments
--      API name   : RAISE_PO_CREATION_INIT_EVENT
--      Type       : Private
--      Pre-reqs   : Negotiation with the given auction_header_id
--                   (p_auction_header_id) must exists in the database
--      Function   : Calls Workflow API to raise a Business Event for PO Creation
--                   initiation event for the given Negotiation (p_auction_header_id)
--      Modifies   : None
--      Locks      : None
--
--      Parameters :
--          IN     :      p_api_version            NUMBER   Required
--          IN     :      p_init_msg_list          VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--          IN     :      p_commit                 VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--          IN     :      p_auction_header_id      NUMBER Required, p_auction_header_id
--                                                 of the Negotiation for which PO creation is started
--          IN     :      p_user_name              VARCHAR2 Required, User Name
--                                                 of the Negotiation Creator who has initiated PO creation
--          IN     :      p_requisition_based_flag  VARCHAR2 Required, Flag to indicate if the
--                                                 Negotiation has some backing Requisition(s)
--          OUT    :      x_return_status          VARCHAR2,     flag to indicate if the procedure
--                                                 was successful or not; It can have
--                                                 following values -
--                                                     FND_API.G_RET_STS_SUCCESS (Success)
--                                                     FND_API.G_RET_STS_ERROR (Failed due to error)
--          OUT    :      x_msg_count              NUMBER,    the number of warning of error messages due
--                                                 to this procedure call. It will have following
--                                                 values  -
--                                                     0 (for Success without warning)
--                                                     1 or more (for Error(s)/Warning(s)
--          OUT    :      x_msg_data               VARCHAR2,    the standard message data output parameter
--                                                 used to return the first message of the stack
--	Version    : Current version	1.0
--                   Previous version 	1.0
--		     Initial version 	1.0
--
-- End of comments

PROCEDURE RAISE_PO_CREATION_INIT_EVENT
(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    p_commit                IN VARCHAR2 ,
    p_auction_header_id     IN NUMBER,
    p_user_name             IN VARCHAR2,
    p_requisition_based_flag IN VARCHAR2,
    x_return_status         IN OUT NOCOPY VARCHAR2,
    x_msg_count             IN OUT NOCOPY NUMBER,
    x_msg_data              IN OUT NOCOPY VARCHAR2
)
IS
	l_auction_header_id           PON_AUCTION_HEADERS_ALL.AUCTION_HEADER_ID%TYPE;
	l_document_number 	      PON_AUCTION_HEADERS_ALL.DOCUMENT_NUMBER %TYPE;
	l_doctype_id		      PON_AUCTION_HEADERS_ALL.DOCTYPE_ID%TYPE;
	l_contract_type		      PON_AUCTION_HEADERS_ALL.CONTRACT_TYPE%TYPE;
	l_outcome_status	      PON_AUCTION_HEADERS_ALL.OUTCOME_STATUS%TYPE;
	l_wf_poncompl_item_key	      PON_AUCTION_HEADERS_ALL.WF_PONCOMPL_ITEM_KEY%TYPE;
	l_wf_poncompl_current_round   PON_AUCTION_HEADERS_ALL.WF_PONCOMPL_CURRENT_ROUND%TYPE;
	l_last_update_date	      VARCHAR2(100);
	l_source_reqs_flag            PON_AUCTION_HEADERS_ALL.SOURCE_REQS_FLAG%TYPE;
        l_requisition_based_flag       VARCHAR2(3);

        l_parameter_list              WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();

BEGIN
 -- { Start of RAISE_PO_CREATION_INIT_EVENT

        BEGIN
                g_debug_mode := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
        EXCEPTION
                WHEN OTHERS THEN
                    g_debug_mode := 'N';
        END;

        LOG_MESSAGE('RAISE_PO_CREATION_INIT_EVENT','is being called');

        IF (p_requisition_based_flag <> 'REQUISITION') THEN
           l_requisition_based_flag := 'N';
        ELSE
           l_requisition_based_flag := 'Y';
        END IF;

        --
        -- Populate the Business Event parameters
        --
	SELECT
		AUCTION_HEADER_ID,
		DOCUMENT_NUMBER ,
		DOCTYPE_ID,
		CONTRACT_TYPE,
		OUTCOME_STATUS,
		WF_PONCOMPL_ITEM_KEY,
		WF_PONCOMPL_CURRENT_ROUND,
		TO_CHAR(LAST_UPDATE_DATE,'dd-mm-yyyy hh24:mi:ss'),
	        NVL(SOURCE_REQS_FLAG,'N')
	INTO
		l_auction_header_id,
		l_document_number,
		l_doctype_id,
		l_contract_type,
		l_outcome_status,
		l_wf_poncompl_item_key,
		l_wf_poncompl_current_round,
		l_last_update_date,
                l_source_reqs_flag
 	 FROM PON_AUCTION_HEADERS_ALL
	 WHERE AUCTION_HEADER_ID = p_auction_header_id;

	--
	-- Add the parameters
	--
	wf_event.AddParameterToList( p_name => 'auction_header_id',
				     p_value => l_auction_header_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'document_number',
				     p_value => l_document_number,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'doctype_id',
				     p_value => l_doctype_id,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'contract_type',
				     p_value => l_contract_type,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'user_name',
				     p_value => p_user_name,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'outcome_status',
				     p_value => l_outcome_status,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'has_requisition_flag',
				     p_value => l_requisition_based_flag,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'wf_poncompl_item_key',
				     p_value => l_wf_poncompl_item_key,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'wf_poncompl_current_round',
				     p_value => l_wf_poncompl_current_round,
				     p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList( p_name => 'po_initiation_date',
				     p_value => l_last_update_date,
				     p_parameterlist => l_parameter_list);

        wf_event.AddParameterToList( p_name => 'source_backing_req_lines',
                                     p_value => l_source_reqs_flag,
                                     p_parameterlist => l_parameter_list);


	RAISE_EVENT (
		    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
		    p_event_name     => 'oracle.apps.pon.event.purchaseorder.initiate',
                    p_event_key      => to_char(l_auction_header_id)||'-'||to_char(l_wf_poncompl_current_round),
		    p_parameter_list => l_parameter_list,
       		    x_return_status  => x_return_status,
		    x_msg_count      => x_msg_count,
		    x_msg_data       => x_msg_data);

 END;
-- } End of RAISE_PO_CREATION_INIT_EVENT


--
-- Procedure to call Workflow API to raise a Business Event for Negotiation
-- events for the given event name (p_event_name)
--

PROCEDURE RAISE_EVENT (
		    p_api_version      IN NUMBER,
                    p_init_msg_list    IN VARCHAR2,
		    p_event_name       IN VARCHAR2,
                    p_event_key        IN VARCHAR2,
		    p_parameter_list   IN WF_PARAMETER_LIST_T,
       		    x_return_status    IN OUT NOCOPY VARCHAR2,
		    x_msg_count        IN OUT NOCOPY NUMBER,
		    x_msg_data         IN OUT NOCOPY VARCHAR2)
IS
        --
        -- Remember to change the l_api_version for change in the API
        --
        l_api_version       CONSTANT  NUMBER := 1.0;
        l_api_name          CONSTANT  VARCHAR2(30) := 'PON_BIZ_EVENTS_PVT';

	l_parameter_list    WF_PARAMETER_LIST_T := NULL;

	l_org_id            NUMBER;
	l_user_id           NUMBER;
	l_resp_id           NUMBER;
	l_resp_appl_id      NUMBER;

        l_exist             VARCHAR2(30);

BEGIN
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard Start of API savepoint
    SAVEPOINT  pon_biz_event_raise_event;

    g_err_loc := '10.0 Going to start in RAISE_EVENT call';
    LOG_MESSAGE('raise_event', g_err_loc);
    --
    -- Standard call to check for call compatibility
    --
    IF NOT FND_API.COMPATIBLE_API_CALL ( l_api_version,
			                 p_api_version,
				         l_api_name,
				         g_pkg_name )
    THEN
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    g_err_loc := '10.1 Checked the FND_API.COMPATIBLE_API_CALL';
    LOG_MESSAGE('raise_event', g_err_loc);

    --
    -- Initialize message list if p_init_msg_list is set to TRUE
    -- We initialize the list by default. User should pass proper
    -- value to p_init_msg_list in case this initialization is not
    -- wanted
    --
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
        FND_MSG_PUB.INITIALIZE;
    END IF;

    g_err_loc := '10.2 Checked and called FND_MSG_PUB.INITIALIZE';
    LOG_MESSAGE('raise_event', g_err_loc);

    -- Get the db session context
    l_org_id       := FND_PROFILE.VALUE( NAME => 'ORG_ID' );
    l_user_id      := FND_PROFILE.VALUE( NAME => 'USER_ID');
    l_resp_id      := FND_PROFILE.VALUE( NAME => 'RESP_ID');
    l_resp_appl_id := FND_PROFILE.VALUE( NAME => 'RESP_APPL_ID');

    g_err_loc := '10.3 Fetched the FND_PROFILE.VALUEs';
    LOG_MESSAGE('raise_event', g_err_loc);

    --Check the event is registered and enabled
    l_exist :=WF_EVENT.TEST(p_event_name);

    g_err_loc := '10.4 Called the WF_EVENT.TEST';
    LOG_MESSAGE('raise_event', g_err_loc|| 'l_exist:'||l_exist);

    IF (p_parameter_list IS NULL) THEN
        l_parameter_list := WF_PARAMETER_LIST_T();
    ELSE
        l_parameter_list := p_parameter_list;
    END IF;

    g_err_loc := '10.5 l_parameter_list is initialized';
    LOG_MESSAGE('raise_event', g_err_loc);

    IF (l_exist <> 'NONE') THEN
    --{
            -- Add extra context values to the list

            wf_event.AddParameterToList( p_name => 'org_id',
                                         p_value => l_org_id,
                                         p_parameterlist => l_parameter_list);
            wf_event.AddParameterToList( p_name => 'user_id',
                                         p_value => l_user_id,
                                         p_parameterlist => l_parameter_list);
            wf_event.AddParameterToList( p_name => 'resp_id',
                                         p_value => l_resp_id,
                                         p_parameterlist => l_parameter_list);
            wf_event.AddParameterToList( p_name => 'resp_appl_id',
                                         p_value => l_resp_appl_id,
                                         p_parameterlist => l_parameter_list);

            g_err_loc := '10.6 End of wf_event.AddParameterToList calls';
            LOG_MESSAGE('raise_event', g_err_loc);

            --
            -- Set Everything to defer mode for a better performance
            --
            WF_EVENT.SetDispatchMode('ASYNC');


            -- Raise Event
            WF_EVENT.RAISE(p_event_name    =>    p_event_name,
                           p_event_key     =>    p_event_key,
                           p_parameters    =>    l_parameter_list
                           );
            g_err_loc := '10.7 Called WF_EVENT.RAISE';
            LOG_MESSAGE('raise_event', g_err_loc);
   --}
   ELSE
           -- We are not raising any exception if the event does not exist
           LOG_MESSAGE('raise_event', 'There is no such event by name: '||p_event_name||'. Business Event is not raised');
   END IF;

   -- Clear the parameter list
   l_parameter_list.DELETE;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        ROLLBACK TO pon_biz_event_raise_event;

        FND_MESSAGE.SET_NAME('PON','PON_GENERIC_ERR');
        FND_MESSAGE.SET_TOKEN('TOKEN', g_err_loc|| ' :' || SQLCODE || ' :' || SQLERRM);
        FND_MSG_PUB.ADD;
        LOG_MESSAGE('raise_event', 'An error in the raise_event procedure. Error at:'||g_err_loc || ' :' || SQLCODE || ' :' || SQLERRM);

        FND_MSG_PUB.COUNT_AND_GET( p_count    => x_msg_count,
                                   p_data     =>  x_msg_data);

END RAISE_EVENT;

-- ======================================================================
--   PROCEDURE  :  LOG_MESSAGE   PRIVATE
--   PARAMETERS :
--     p_module :  IN pass the module name
--     p_message:  IN the string to be logged
--
--   COMMENT    :  Common procedure to log messages in FND_LOG.
-- ======================================================================
PROCEDURE LOG_MESSAGE( p_module  IN VARCHAR2,
                       p_message IN VARCHAR2)
IS
BEGIN
  IF (g_debug_mode = 'Y') THEN
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

          FND_LOG.string(log_level  => FND_LOG.level_statement,
                         module     => g_module_prefix || p_module,
                         message    => p_message);

      END IF;
   END IF;
END LOG_MESSAGE;


END PON_BIZ_EVENTS_PVT;

/
