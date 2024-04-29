--------------------------------------------------------
--  DDL for Package PO_NEGOTIATIONS4_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NEGOTIATIONS4_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGNG4S.pls 120.1 2005/07/12 10:54:37 ksareddy noship $ */

PROCEDURE Split_RequisitionLines
(   p_api_version		IN		NUMBER			    ,
    p_init_msg_list		IN    		VARCHAR2  :=FND_API.G_FALSE ,
    p_commit			IN    		VARCHAR2  :=FND_API.G_FALSE ,
    x_return_status		OUT NOCOPY   	VARCHAR2  		    ,
    x_msg_count			OUT NOCOPY   	NUMBER   		    ,
    x_msg_data			OUT NOCOPY   	VARCHAR2 		    ,
    p_auction_header_id		IN  		NUMBER
);

--Catalog Convergence 12.0 Sourcing impact
Procedure insert_attributes (p_api_version           IN  NUMBER,
                             p_commit                IN  VARCHAR2 default FND_API.G_FALSE,
                             p_init_msg_list         IN  VARCHAR2 default FND_API.G_FALSE,
                             p_validation_level      IN  NUMBER default FND_API.G_VALID_LEVEL_FULL,
                             p_auction_header_id     IN  NUMBER,
                             x_return_status         OUT NOCOPY VARCHAR2,
                             x_msg_count             OUT NOCOPY NUMBER,
                             x_msg_data              OUT NOCOPY VARCHAR2
);


END PO_NEGOTIATIONS4_GRP;

 

/
