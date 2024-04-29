--------------------------------------------------------
--  DDL for Package BOM_ROUTINGHEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_ROUTINGHEADER_PVT" AUTHID CURRENT_USER AS
-- $Header: BOMVRTGS.pls 120.3 2005/11/15 07:20:37 earumuga noship $
-- Start of comments
--	API name 	: AssignRouting
--	Type		: Private.
--	Function	: Populates IDs based on Flex values and codes.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--	  p_api_version       NUMBER	Required
--	  p_init_msg_list     VARCHAR2 	Optional  Default = FND_API.G_FALSE
--	  p_commit	      VARCHAR2	Optional  Default = FND_API.G_FALSE
--	  p_validation_level  NUMBER	Optional
--          Default = FND_API.G_VALID_LEVEL_FULL
--	  p_routing_rec	      ROUTING_REC_TYPE Default = G_MISS_ROUTING_REC
--				.
--	OUT		:
--        x_return_status	VARCHAR2(1)
--	  x_msg_count	    	NUMBER
--	  x_msg_data	    	VARCHAR2(2000)
--	  x_routing_rec	    	ROUTING_REC_TYPE
--	Version	: Current version	1.0
--	          previous version	none
--		  Initial version 	1.0
--
--	Notes		:
--
--	API name 	: ValidateRouting
--	Type		: Private.
--	Function	: Validates a row in BOM_OPERATIONAL_ROUTINGS
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--	  p_api_version       	NUMBER	  Required
--	  p_init_msg_list	VARCHAR2  Optional Default = FND_API.G_FALSE
--	  p_commit	    	VARCHAR2  Optional Default = FND_API.G_FALSE
--	  p_validation_level    NUMBER	  Optional
--	    Default = FND_API.G_VALID_LEVEL_FULL
--	  p_routing_rec	    	ROUTING_REC_TYPE   Default = G_MISS_ROUTING_REC
--
--	OUT		:
--	  x_return_status   VARCHAR2(1)
--	  x_msg_count	    NUMBER
--	  x_msg_data	    VARCHAR2(2000)
--	  x_routing_rec	    ROUTING_REC_TYPE
--	Version	: Current version	1.0
--	          previous version	none
--		  Initial version 	1.0
--
--	Notes		: Full validation level includes AssignRouting
--
--	API name 	: CreateRouting
--	Type		: Private.
--	Function	: Inserts a row into BOM_OPERATIONAL_ROUTINGS
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--	  p_api_version       	NUMBER	Required
--	  p_init_msg_list	VARCHAR2 Optional Default = FND_API.G_FALSE
--	  p_commit	    	VARCHAR2 Optional Default = FND_API.G_FALSE
--	  p_validation_level  	NUMBER	Optional
--	    Default = FND_API.G_VALID_LEVEL_FULL
--	  p_routing_rec	    	ROUTING_REC_TYPE  Default = G_MISS_ROUTING_REC
--
--	OUT		:
--	  x_return_status   VARCHAR2(1)
--	  x_msg_count	    NUMBER
--	  x_msg_data	    VARCHAR2(2000)
--	  x_routing_rec	    ROUTING_REC_TYPE
--	Version	: Current version	1.0
--	          previous version	none
--		  Initial version 	1.0
--
--	Notes		: Full validation level includes AssignRouting and
--			  ValidateRouting.
--
--	API name 	: UpdateRouting
--	Type		: Private.
--	Function	: Updates a row from BOM_OPERATIONAL_ROUTINGS
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
-- 	  p_api_version       NUMBER	Required
--	  p_init_msg_list     VARCHAR2 	Optional Default = FND_API.G_FALSE
--	  p_commit	      VARCHAR2	Optional Default = FND_API.G_FALSE
--	  p_validation_level  NUMBER	Optional
--	    Default = FND_API.G_VALID_LEVEL_FULL
--	  p_routing_rec	      ROUTING_REC_TYPE   Default = G_MISS_ROUTING_REC
--				.
--	OUT		:
--   	  x_return_status   VARCHAR2(1)
--	  x_msg_count	    NUMBER
--	  x_msg_data	    VARCHAR2(2000)
--	  x_routing_rec	    ROUTING_REC_TYPE
--
--	Version	: Current version	1.0
--	          previous version	none
--		  Initial version 	1.0
--
--	Notes		: Full validation level includes AssignRouting and
--			  ValidateRouting.
--
--	API name 	: DeleteRouting
--	Type		: Private.
--	Function	: Deletes a row from BOM_OPERATIONAL_ROUTINGS
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--	  p_api_version       	NUMBER	 Required
--	  p_init_msg_list	VARCHAR2 Optional Default = FND_API.G_FALSE
--	  p_commit	    	VARCHAR2 Optional Default = FND_API.G_FALSE
--	  p_validation_level 	NUMBER   Optional
--	    Default = FND_API.G_VALID_LEVEL_FULL
--	  p_delete_group	VARCHAR2
--        p_description		VARCHAR2 Default = Null
--	  p_routing_rec	    	ROUTING_REC_TYPE Default = G_MISS_ROUTING_REC,
--				.
--	OUT		:
--	  x_return_status   VARCHAR2(1)
--	  x_msg_count	    NUMBER
--	  x_msg_data	    VARCHAR2(2000)
--	  x_routing_rec	    ROUTING_REC_TYPE
--
--	Version	: Current version	1.0
--	          previous version	none
--		  Initial version 	1.0
--
--	Notes		: Full validation level includes AssignRouting
--
-- End of comments
TYPE routing_rec_type is record(
 routing_sequence_id  		 NUMBER         := FND_API.G_MISS_NUM,
 assembly_item_id  		 NUMBER         := FND_API.G_MISS_NUM,
 assembly_item_number            VARCHAR2(81)   := FND_API.G_MISS_CHAR,
 organization_id                 NUMBER         := FND_API.G_MISS_NUM,
 organization_code               VARCHAR2(3)    := FND_API.G_MISS_CHAR,
 alternate_routing_designator    VARCHAR2(10)   := FND_API.G_MISS_CHAR,
 routing_type                    NUMBER         := FND_API.G_MISS_NUM,
 common_assembly_item_id         NUMBER         := FND_API.G_MISS_NUM,
 common_item_number              VARCHAR2(81)   := FND_API.G_MISS_CHAR,
 common_routing_sequence_id      NUMBER         := FND_API.G_MISS_NUM,
 routing_comment                 VARCHAR2(240)  := FND_API.G_MISS_CHAR,
 completion_subinventory         VARCHAR2(10)   := FND_API.G_MISS_CHAR,
 completion_locator_id           NUMBER         := FND_API.G_MISS_NUM,
 location_name                   VARCHAR2(81)   := FND_API.G_MISS_CHAR,
 attribute_category              VARCHAR2(30)   := FND_API.G_MISS_CHAR,
 attribute1                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute2                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute3                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute4                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute5                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute6                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute7                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute8                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute9                      VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute10                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute11                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute12                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute13                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute14                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 attribute15                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
 line_id                         NUMBER         := FND_API.G_MISS_NUM,
 line_code                       VARCHAR2(10)   := FND_API.G_MISS_CHAR,
 mixed_model_map_flag            NUMBER         := FND_API.G_MISS_NUM,
 priority                        NUMBER         := FND_API.G_MISS_NUM,
 cfm_routing_flag                NUMBER         := FND_API.G_MISS_NUM,
 total_product_cycle_time	 NUMBER         := FND_API.G_MISS_NUM,
 ctp_flag		         NUMBER         := FND_API.G_MISS_NUM,
 -- Added as part of TTMO enh R12
 pending_from_ecn                VARCHAR2(10)   := FND_API.G_MISS_CHAR
);

G_MISS_ROUTING_REC	ROUTING_REC_TYPE;
G_VALID_LEVEL_NO_ASSIGN constant number := 5;

PROCEDURE AssignRouting
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		IN OUT	NOCOPY VARCHAR2,
	x_msg_count		    IN OUT	NOCOPY NUMBER,
	x_msg_data		    IN OUT	NOCOPY VARCHAR2,
	p_routing_rec		IN	ROUTING_REC_TYPE := G_MISS_ROUTING_REC,
	x_routing_rec		IN OUT  NOCOPY ROUTING_REC_TYPE
);
PROCEDURE ValidateRouting
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		IN OUT	NOCOPY VARCHAR2,
	x_msg_count		    IN OUT	NOCOPY NUMBER,
	x_msg_data		    IN OUT	NOCOPY VARCHAR2,
	p_routing_rec		IN	ROUTING_REC_TYPE := G_MISS_ROUTING_REC,
	x_routing_rec		IN OUT  NOCOPY ROUTING_REC_TYPE
);
PROCEDURE CreateRouting
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		IN OUT	NOCOPY VARCHAR2,
	x_msg_count		    IN OUT	NOCOPY NUMBER,
	x_msg_data		    IN OUT	NOCOPY VARCHAR2,
	p_routing_rec		IN	ROUTING_REC_TYPE := G_MISS_ROUTING_REC,
	x_routing_rec		IN OUT     NOCOPY ROUTING_REC_TYPE
);
PROCEDURE UpdateRouting
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		IN OUT	NOCOPY VARCHAR2,
	x_msg_count		    IN OUT	NOCOPY NUMBER,
	x_msg_data		    IN OUT	NOCOPY VARCHAR2,
	p_routing_rec		IN	ROUTING_REC_TYPE := G_MISS_ROUTING_REC,
	x_routing_rec		IN OUT  NOCOPY ROUTING_REC_TYPE
);
PROCEDURE DeleteRouting
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		IN OUT	NOCOPY VARCHAR2,
	x_msg_count		    IN OUT	NOCOPY NUMBER,
	x_msg_data		    IN OUT	NOCOPY VARCHAR2,
	p_delete_group		IN	VARCHAR2,
        p_description		IN	VARCHAR2 := null,
	p_routing_rec		IN	ROUTING_REC_TYPE := G_MISS_ROUTING_REC,
	x_routing_rec		IN OUT     NOCOPY ROUTING_REC_TYPE
);

	-- Start of comments
	--	API name 	: createrouting
	--	Type		: private
	--	Pre-reqs	: None
	--	Function	: Creates the routing header
	--	Parameters	:
	--	IN		:	p_api_version IN NUMBER Required
	--				    Standard API Number
	--              p_description IN VARCHAR2 Required
	--                  Description for the routing header
	--              p_assembly_item_id IN NUMBER Required
	--                  Item Id for which the routing needs to be created
	--              p_organization_id IN NUMBER Required
	--                  Organization in which the routing needs to be created
	--              p_alt_rtg_desig  IN VARCHAR2 Required
	--                  Routing alternate designator
	--              p_routing_type  IN NUMBER Required
	--                  Type of the routing
	--              p_common_assembly_item_id IN NUMBER Required
	--                  Item from which this routing needs to create a reference
	--              p_common_rtg_seq_id IN NUMBER Required
	--                  Routing sequence Id of the source routing from which the
	--                  reference needs to be created
	--              p_routing_comment IN VARCHAR2 Optional
	--                  Comment for the routing
	--              p_change_notice IN VARCHAR2 Optional
	--                  Change Order Name for which the routing is created
	--  OUT      :  x_return_status OUT VARCHAR2
	--                  APIs return status
	--              x_msg_count OUT NUMBER
	--                  Number of messages added to the stack
	--              x_msg_data  OUT VARCHAR2
	--                  Error Message Data
	--              x_rtg_seq_id  OUT NUMBER
	--                  Routing sequence id of the newly created routing
	-- End of comments
PROCEDURE createrouting
(
	p_api_version		IN NUMBER,
	x_return_status		IN OUT NOCOPY VARCHAR2,
	x_msg_count			IN OUT NOCOPY NUMBER,
	x_msg_data			IN OUT	NOCOPY VARCHAR2,
	p_description		IN VARCHAR2,
	p_assembly_item_id	IN NUMBER,
	p_organization_id	IN NUMBER,
	p_alt_rtg_desig		IN VARCHAR2,
	p_routing_type		IN NUMBER,
	p_common_assembly_item_id IN NUMBER,
	p_common_rtg_seq_id IN NUMBER,
	p_routing_comment	IN VARCHAR2,
	p_copy_request_id   IN NUMBER,
	p_user_id           IN NUMBER,
	p_change_notice     IN VARCHAR2,
	x_rtg_seq_id		IN OUT NOCOPY NUMBER
);

END BOM_RoutingHeader_PVT;

 

/
