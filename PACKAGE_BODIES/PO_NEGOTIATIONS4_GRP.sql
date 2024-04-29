--------------------------------------------------------
--  DDL for Package Body PO_NEGOTIATIONS4_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NEGOTIATIONS4_GRP" AS
/* $Header: POXGNG4B.pls 120.1 2005/07/12 10:56:05 ksareddy noship $ */

/**
 * Group Procedure: Split_RequisitionLines
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: Inserts new req lines and their distributions, For parent
 *   req lines, update requisition_lines table to modified_by_agent_flag='Y'.
 *   Also sets prevent encumbrace flag to 'Y' in the po_req_distributions table.
 * Effects: This api split the requisition lines, if needed, depending on the
 *   allocation done by the sourcing user. This api uses a global temp. table
 *   to massage the input given by sourcing and inserts records into
 *   po_requisition_lines and po_req_distributions table. This api also handles
 *   the encumbrace effect of splitting requisition lines. This api would be
 *   called from ORacle sourcing workflow.
 *
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if action succeeds
 *                     FND_API.G_RET_STS_ERROR if  action fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *                     x_msg_count returns count of messages in the stack.
 *                     x_msg_data returns message only if 1 message.
 */


PROCEDURE Split_RequisitionLines
(   p_api_version		IN		NUMBER			    ,
    p_init_msg_list		IN    		VARCHAR2  :=FND_API.G_FALSE ,
    p_commit			IN    		VARCHAR2  :=FND_API.G_FALSE ,
    x_return_status		OUT NOCOPY   	VARCHAR2  		    ,
    x_msg_count			OUT NOCOPY   	NUMBER   		    ,
    x_msg_data			OUT NOCOPY   	VARCHAR2 		    ,
    p_auction_header_id		IN  		NUMBER
)
IS

BEGIN

  PO_NEGOTIATIONS4_PVT.Split_RequisitionLines
  (   p_api_version		=>	    p_api_version	,
      p_init_msg_list		=>	    p_init_msg_list	,
      p_commit			=>	    p_commit		,
      x_return_status		=>	    x_return_status	,
      x_msg_count		=>	    x_msg_count		,
      x_msg_data		=>	    x_msg_data		,
      p_auction_header_id	=>	    p_auction_header_id
  );

EXCEPTION
	WHEN OTHERS THEN
	     --no rollback as there is no data base change in the procedure.
	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	     FND_MSG_PUB.Count_And_Get
	     ( 	p_count  =>  x_msg_count ,
		p_data 	 =>  x_msg_data
	     );

END Split_RequisitionLines;


--< Catalog Convergence 12.0 Sourcing impact START>
Procedure insert_attributes (
                     p_api_version           IN  NUMBER,
                     p_commit                IN  VARCHAR2 default FND_API.G_FALSE,
                     p_init_msg_list         IN  VARCHAR2 default FND_API.G_FALSE,
                     p_validation_level      IN  NUMBER default FND_API.G_VALID_LEVEL_FULL,
                     p_auction_header_id     IN  NUMBER,
                     x_return_status         OUT NOCOPY VARCHAR2,
                     x_msg_count             OUT NOCOPY NUMBER,
                     x_msg_data              OUT NOCOPY VARCHAR2
               )
IS
BEGIN

  PO_ATTRIBUTE_VALUES_PVT.handle_attributes( p_interface_header_id => p_auction_header_id);

EXCEPTION
       WHEN OTHERS THEN NULL; --TODO proper exception handling

END insert_attributes;
--<Catalog Convergence 12.0 Sourcing impact END>

END PO_NEGOTIATIONS4_GRP;

/
