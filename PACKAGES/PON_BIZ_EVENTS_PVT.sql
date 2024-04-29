--------------------------------------------------------
--  DDL for Package PON_BIZ_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_BIZ_EVENTS_PVT" AUTHID CURRENT_USER AS
--$Header: PONVEVTS.pls 120.0 2005/06/01 13:34:11 appldev noship $



-- Start of comments
--      API name : RAISE_NEG_PUB_EVENT
--      Type        : Private
--      Pre-reqs  : Negotiation with the given auction_header_id
--                        (p_auction_header_id) must exists in the database
--      Function  : Calls Workflow API to raise a Business Event for Negotiation
--                        publication event for the given auction_header_id (p_auction_header_id)
--      Modifies  : None
--      Locks      : None
--
--     Parameters:
--     IN     :      p_api_version      NUMBER   Required
--     IN            p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_commit             VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_auction_header_id  NUMBER Required, auction_header_id
--                                                        of the negotiation published
--     OUT  :      x_return_status             VARCHAR2,     flag to indicate if the procedure
--                                              was successful or not; It can have
--                                              following values -
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_ERROR (Failed due to error)
--     OUT  :      x_msg_count                 NUMBER,    the number of warning of error messages due
--                                                        to this procedure call. It will have following
--                                                        values  -
--                                                     0 (for Success without warning)
--                                                     1 or more (for Error(s)/Warning(s)
--     OUT  :      x_msg_data                 VARCHAR2,    the standard message data output parameter
--                                                      used to return the first message of the stack
--	Version	: Current version	1.0
--                Previous version 	1.0
--		  Initial version 	1.0
--
-- End of comments


PROCEDURE RAISE_NEG_PUB_EVENT
(
    p_api_version      IN       NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT   FND_API.G_FALSE,
    p_commit    IN  VARCHAR2  DEFAULT FND_API.G_FALSE ,
    p_auction_header_id     IN            NUMBER,
    x_return_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count        IN OUT NOCOPY NUMBER,
    x_msg_data         IN OUT NOCOPY VARCHAR2
);

-- Start of comments
--      API name : RAISE_RESPNSE_PUB_EVENT
--      Type        : Private
--      Pre-reqs  : Response with the given bid_number
--                        (p_bid_number) must exists in the database
--      Function  : Calls Workflow API to raise a Business Event for Response
--                        publication event for the
--                        given bid_number (p_bid_number)
--      Modifies  : None
--      Locks      : None
--
--     Parameters:
--     IN     :      p_api_version      NUMBER   Required
--     IN            p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_commit             VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_bid_number  NUMBER Required, bid_number
--                                                        of the Response published
--     OUT  :      x_return_status             VARCHAR2,     flag to indicate if the procedure
--                                              was successful or not; It can have
--                                              following values -
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_ERROR (Failed due to error)
--     OUT  :      x_msg_count                 NUMBER,    the number of warning of error messages due
--                                                        to this procedure call. It will have following
--                                                        values  -
--                                                     0 (for Success without warning)
--                                                     1 or more (for Error(s)/Warning(s)
--     OUT  :      x_msg_data                 VARCHAR2,    the standard message data output parameter
--                                                      used to return the first message of the stack
--	Version	: Current version	1.0
--                Previous version 	1.0
--		  Initial version 	1.0
--
-- End of comments


PROCEDURE RAISE_RESPNSE_PUB_EVENT
(   p_api_version      IN       NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT   FND_API.G_FALSE,
    p_commit    IN  VARCHAR2  DEFAULT FND_API.G_FALSE ,
    p_bid_number     IN            NUMBER,
    x_return_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count        IN OUT NOCOPY NUMBER,
    x_msg_data         IN OUT NOCOPY VARCHAR2
);

-- Start of comments
--      API name : RAISE_RESPNSE_DISQ_EVENT
--      Type        : Private
--      Pre-reqs  : Response with the given bid_number
--                        (p_bid_number) must exists in the database
--      Function  : Calls Workflow API to raise a Business Event for Disqualification
--                        of Response event for the given bid_number (p_bid_number)
--      Modifies  : None
--      Locks      : None
--
--     Parameters:
--     IN     :      p_api_version      NUMBER   Required
--     IN            p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_commit             VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_bid_number  NUMBER Required, bid_number
--                                                        of the Response published
--     OUT  :      x_return_status             VARCHAR2,     flag to indicate if the procedure
--                                              was successful or not; It can have
--                                              following values -
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_ERROR (Failed due to error)
--     OUT  :      x_msg_count                 NUMBER,    the number of warning of error messages due
--                                                        to this procedure call. It will have following
--                                                        values  -
--                                                     0 (for Success without warning)
--                                                     1 or more (for Error(s)/Warning(s)
--     OUT  :      x_msg_data                 VARCHAR2,    the standard message data output parameter
--                                                      used to return the first message of the stack
--	Version	: Current version	1.0
--                Previous version 	1.0
--		  Initial version 	1.0
--
-- End of comments


PROCEDURE RAISE_RESPNSE_DISQ_EVENT
(
    p_api_version      IN       NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT   FND_API.G_FALSE,
    p_commit    IN  VARCHAR2  DEFAULT FND_API.G_FALSE ,
    p_bid_number     IN            NUMBER,
    x_return_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count        IN OUT NOCOPY NUMBER,
    x_msg_data         IN OUT NOCOPY VARCHAR2
);

-- Start of comments
--      API name : RAISE_NEG_AWD_APPR_STRT_EVENT
--      Type        : Private
--      Pre-reqs  : Negotiation with the given auction_header_id
--                        (p_auction_header_id) must exists in the database
--      Function  : Calls Workflow API to raise a Business Event for Submission
--                        of Award Approval  event for the given auction_header_id (p_auction_header_id)
--      Modifies  : None
--      Locks      : None
--
--     Parameters:
--     IN     :      p_api_version      NUMBER   Required
--     IN            p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_commit             VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_auction_header_id  NUMBER Required, p_auction_header_id
--                                                        of the Negotiation submitted
--     OUT  :      x_return_status             VARCHAR2,     flag to indicate if the procedure
--                                              was successful or not; It can have
--                                              following values -
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_ERROR (Failed due to error)
--     OUT  :      x_msg_count                 NUMBER,    the number of warning of error messages due
--                                                        to this procedure call. It will have following
--                                                        values  -
--                                                     0 (for Success without warning)
--                                                     1 or more (for Error(s)/Warning(s)
--     OUT  :      x_msg_data                 VARCHAR2,    the standard message data output parameter
--                                                      used to return the first message of the stack
--	Version	: Current version	1.0
--                Previous version 	1.0
--		  Initial version 	1.0
--
-- End of comments


PROCEDURE RAISE_NEG_AWD_APPR_STRT_EVENT
(
    p_api_version      IN       NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT   FND_API.G_FALSE,
    p_commit    IN  VARCHAR2  DEFAULT FND_API.G_FALSE ,
    p_auction_header_id     IN            NUMBER,
    x_return_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count        IN OUT NOCOPY NUMBER,
    x_msg_data         IN OUT NOCOPY VARCHAR2
);


-- Start of comments
--      API name : RAISE_NEG_AWRD_COMPLETE_EVENT
--      Type        : Private
--      Pre-reqs  : Negotiation with the given auction_header_id
--                        (p_auction_header_id) must exists in the database
--      Function  : Calls Workflow API to raise a Business Event for Completion
--                        of Award event for the given auction_header_id (p_auction_header_id)
--      Modifies  : None
--      Locks      : None
--
--     Parameters:
--     IN     :      p_api_version      NUMBER   Required
--     IN            p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_commit             VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_auction_header_id  NUMBER Required, p_auction_header_id
--                                                        of the Negotiation completed

--     IN     :      p_create_po_flag  VARCHAR2 Required, Flag to indicate if user has selected
--                                                         create PO option while completing the given Negotiation
--     OUT  :      x_return_status             VARCHAR2,     flag to indicate if the procedure
--                                              was successful or not; It can have
--                                              following values -
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_ERROR (Failed due to error)
--     OUT  :      x_msg_count                 NUMBER,    the number of warning of error messages due
--                                                        to this procedure call. It will have following
--                                                        values  -
--                                                     0 (for Success without warning)
--                                                     1 or more (for Error(s)/Warning(s)
--     OUT  :      x_msg_data                 VARCHAR2,    the standard message data output parameter
--                                                      used to return the first message of the stack
--	Version	: Current version	1.0
--                Previous version 	1.0
--		  Initial version 	1.0
--
-- End of comments


PROCEDURE RAISE_NEG_AWRD_COMPLETE_EVENT
(
    p_api_version      IN       NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT   FND_API.G_FALSE,
    p_commit    IN  VARCHAR2  DEFAULT FND_API.G_FALSE ,
    p_auction_header_id     IN            NUMBER,
    p_create_po_flag       IN  VARCHAR2,
    x_return_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count        IN OUT NOCOPY NUMBER,
    x_msg_data         IN OUT NOCOPY VARCHAR2
);

-- Start of comments
--      API name : RAISE_PO_CREATION_INIT_EVENT
--      Type        : Private
--      Pre-reqs  : Negotiation with the given auction_header_id
--                        (p_auction_header_id) must exists in the database
--      Function  : Calls Workflow API to raise a Business Event for PO Creation
--                        initiation event for the given Negotiation (p_auction_header_id)
--      Modifies  : None
--      Locks      : None
--
--     Parameters:
--     IN     :      p_api_version      NUMBER   Required
--     IN            p_init_msg_list     VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_commit             VARCHAR2   DEFAULT   FND_API.G_FALSE Optional
--     IN     :      p_auction_header_id  NUMBER Required, p_auction_header_id
--                                                        of the Negotiation for which PO creation is started
--     IN     :      p_user_name  VARCHAR2 Required, User Name
--                                                        of the Negotiation Creator who has initiated PO creation
--     IN     :      p_requisition_based_flag  VARCHAR2 Required, Flag to indicate if the
--                                                           Negotiation has some backing Requisition(s)
--     OUT  :      x_return_status             VARCHAR2,     flag to indicate if the procedure
--                                              was successful or not; It can have
--                                              following values -
--                                                         FND_API.G_RET_STS_SUCCESS (Success)
--                                                         FND_API.G_RET_STS_ERROR (Failed due to error)
--     OUT  :      x_msg_count                 NUMBER,    the number of warning of error messages due
--                                                        to this procedure call. It will have following
--                                                        values  -
--                                                     0 (for Success without warning)
--                                                     1 or more (for Error(s)/Warning(s)
--     OUT  :      x_msg_data                 VARCHAR2,    the standard message data output parameter
--                                                      used to return the first message of the stack
--	Version	: Current version	1.0
--                Previous version 	1.0
--		  Initial version 	1.0
--
-- End of comments

PROCEDURE RAISE_PO_CREATION_INIT_EVENT
(
    p_api_version      IN       NUMBER,
    p_init_msg_list    IN  VARCHAR2 DEFAULT   FND_API.G_FALSE,
    p_commit    IN  VARCHAR2  DEFAULT FND_API.G_FALSE ,
    p_auction_header_id     IN            NUMBER,
    p_user_name       IN  VARCHAR2,
    p_requisition_based_flag       IN  VARCHAR2,
    x_return_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count        IN OUT NOCOPY NUMBER,
    x_msg_data         IN OUT NOCOPY VARCHAR2
);

END PON_BIZ_EVENTS_PVT;

 

/
