--------------------------------------------------------
--  DDL for Package BOM_ROUTINGREVISION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_ROUTINGREVISION_PVT" AUTHID CURRENT_USER AS
-- $Header: BOMVRRVS.pls 115.1 99/07/16 05:17:22 porting ship $
-- Start of comments
--	API name 	: AssignRtgRevision
--	Type		: Private.
--	Function	: Assign ids based on values
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--	  p_api_version         NUMBER		Required
--	  p_init_msg_list	VARCHAR2 	Optional
--	    Default = FND_API.G_FALSE
--	  p_commit    		VARCHAR2	Optional
--	    Default = FND_API.G_FALSE
--	  p_validation_level	NUMBER		Optional
--	    Default = FND_API.G_VALID_LEVEL_FULL
--	  p_RtgRevision_rec	RTG_REVISION_REC_TYPE	Required
--	    Default = G_MISS_RTG_REVISION_REC
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_RtgRevision_rec	RTG_REVISION_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		:
--
--	API name 	: ValidateRtgRevision
--	Type		: Private.
--	Function	: Validate Routing Revision record
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--	  p_api_version         NUMBER		Required
--	  p_init_msg_list	VARCHAR2 	Optional
--	    Default = FND_API.G_FALSE
--	  p_commit    		VARCHAR2	Optional
--	    Default = FND_API.G_FALSE
--	  p_validation_level	NUMBER		Optional
--	    Default = FND_API.G_VALID_LEVEL_FULL
--	  p_RtgRevision_rec	RTG_REVISION_REC_TYPE	Required
--	    Default = G_MISS_RTG_REVISION_REC
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_RtgRevision_rec	RTG_REVISION_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full validation includes AssignRtgRevision
--
--	API name 	: CreateRtgRevision
--	Type		: Private.
--	Function	: Insert row into MTL_RTG_ITEM_REVISIONS
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--	  p_api_version         NUMBER		Required
--	  p_init_msg_list	VARCHAR2 	Optional
--	    Default = FND_API.G_FALSE
--	  p_commit    		VARCHAR2	Optional
--	    Default = FND_API.G_FALSE
--	  p_validation_level	NUMBER		Optional
--	    Default = FND_API.G_VALID_LEVEL_FULL
--	  p_RtgRevision_rec	RTG_REVISION_REC_TYPE	Required
--	    Default = G_MISS_RTG_REVISION_REC
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_RtgRevision_rec	RTG_REVISION_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full validation includes AssignRtgRevision and
--			  ValidateRtgRevision
--
--	API name 	: UpdateRtgRevision
--	Type		: Private.
--	Function	: Updates row in MTL_RTG_ITEM_REVISIONS
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--	  p_api_version         NUMBER		Required
--	  p_init_msg_list	VARCHAR2 	Optional
--	    Default = FND_API.G_FALSE
--	  p_commit    		VARCHAR2	Optional
--	    Default = FND_API.G_FALSE
--	  p_validation_level	NUMBER		Optional
--	    Default = FND_API.G_VALID_LEVEL_FULL
--	  p_RtgRevision_rec	RTG_REVISION_REC_TYPE	Required
--	    Default = G_MISS_RTG_REVISION_REC
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_RtgRevision_rec	RTG_REVISION_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full validation includes AssignRtgRevision and
--			  ValidateRtgRevision
--
--	API name 	: DeleteRtgRevision
--	Type		: Private.
--	Function	: Deletes row from MTL_RTG_ITEM_REVISIONS
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--	  p_api_version         NUMBER		Required
--	  p_init_msg_list	VARCHAR2 	Optional
--	    Default = FND_API.G_FALSE
--	  p_commit    		VARCHAR2	Optional
--	    Default = FND_API.G_FALSE
--	  p_validation_level	NUMBER		Optional
--	    Default = FND_API.G_VALID_LEVEL_FULL
--	  p_RtgRevision_rec	RTG_REVISION_REC_TYPE	Required
--	    Default = G_MISS_RTG_REVISION_REC
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_RtgRevision_rec	RTG_REVISION_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full validation includes AssignRtgRevision
--
-- End of comments
TYPE rtg_revision_rec_type is record(
 inventory_item_id               NUMBER          := Fnd_Api.G_Miss_Num,
 inventory_item_number           VARCHAR2(81)    := Fnd_Api.G_Miss_Char,
 organization_id                 NUMBER          := Fnd_Api.G_Miss_Num,
 organization_code               VARCHAR2(3)     := Fnd_Api.G_Miss_Char,
 process_revision                VARCHAR2(3)     := Fnd_Api.G_Miss_Char,
 change_notice                   VARCHAR2(10)    := Fnd_Api.G_Miss_Char,
 ecn_initiation_date             DATE            := Fnd_Api.G_Miss_Date,
 implementation_date             DATE            := Fnd_Api.G_Miss_Date,
 implemented_serial_number       VARCHAR2(30)    := Fnd_Api.G_Miss_Char,
 effectivity_date                DATE            := Fnd_Api.G_Miss_Date,
 attribute_category              VARCHAR2(30)    := Fnd_Api.G_Miss_Char,
 attribute1                      VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute2                      VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute3                      VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute4                      VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute5                      VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute6                      VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute7                      VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute8                      VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute9                      VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute10                     VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute11                     VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute12                     VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute13                     VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute14                     VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 attribute15                     VARCHAR2(150)   := Fnd_Api.G_Miss_Char
);

G_MISS_RTG_REVISION_REC rtg_revision_rec_type;
G_VALID_LEVEL_NO_ASSIGN constant number := 5;

PROCEDURE AssignRtgRevision(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	OUT	VARCHAR2,
  x_msg_count		OUT	NUMBER,
  x_msg_data		OUT	VARCHAR2,
  p_RtgRevision_rec	IN 	RTG_REVISION_REC_TYPE :=
				  G_MISS_RTG_REVISION_REC,
  x_RtgRevision_rec	OUT 	RTG_REVISION_REC_TYPE
);
PROCEDURE ValidateRtgRevision(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	OUT	VARCHAR2,
  x_msg_count		OUT	NUMBER,
  x_msg_data		OUT	VARCHAR2,
  p_RtgRevision_rec	IN 	RTG_REVISION_REC_TYPE :=
				  G_MISS_RTG_REVISION_REC,
  x_RtgRevision_rec	OUT 	RTG_REVISION_REC_TYPE
);
PROCEDURE CreateRtgRevision(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	OUT	VARCHAR2,
  x_msg_count		OUT	NUMBER,
  x_msg_data		OUT	VARCHAR2,
  p_RtgRevision_rec	IN 	RTG_REVISION_REC_TYPE :=
				  G_MISS_RTG_REVISION_REC,
  x_RtgRevision_rec	OUT 	RTG_REVISION_REC_TYPE
);
PROCEDURE UpdateRtgRevision(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	OUT	VARCHAR2,
  x_msg_count		OUT	NUMBER,
  x_msg_data		OUT	VARCHAR2,
  p_RtgRevision_rec	IN 	RTG_REVISION_REC_TYPE :=
				  G_MISS_RTG_REVISION_REC,
  x_RtgRevision_rec	OUT 	RTG_REVISION_REC_TYPE
);
PROCEDURE DeleteRtgRevision(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	OUT	VARCHAR2,
  x_msg_count		OUT	NUMBER,
  x_msg_data		OUT	VARCHAR2,
  p_RtgRevision_rec	IN 	RTG_REVISION_REC_TYPE :=
				  G_MISS_RTG_REVISION_REC,
  x_RtgRevision_rec	OUT 	RTG_REVISION_REC_TYPE
);

END Bom_RoutingRevision_Pvt;

 

/
