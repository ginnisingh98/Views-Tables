--------------------------------------------------------
--  DDL for Package BOM_OPRESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_OPRESOURCE_PVT" AUTHID CURRENT_USER AS
-- $Header: BOMVRESS.pls 120.1.12010000.2 2008/11/14 16:43:46 snandana ship $
-- Start of comments
--	API name 	: AssignResource
--	Type		: Private.
--	Function	: Populates Ids from values
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
--	  p_resource_rec	RESOURCE_REC_TYPE Required
--	    Default = G_MISS_RESOURCE_REC
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_resource_rec	RESOURCE_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--	API name 	: ValidateResource
--	Type		: Private.
--	Function	: Validates Operation Resource record
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
--	  p_resource_rec	RESOURCE_REC_TYPE Required
--	    Default = G_MISS_RESOURCE_REC
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_resource_rec	RESOURCE_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full Validation includes AssignResource
--
--	API name 	: CreateResource
--	Type		: Private.
--	Function	: Inserts row into Bom Operation Resources
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
--	  p_resource_rec	RESOURCE_REC_TYPE Required
--	    Default = G_MISS_RESOURCE_REC
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_resource_rec	RESOURCE_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full Validation includes AssignResource and
--			  ValidateResource
--
--	API name 	: UpdateResource
--	Type		: Private.
--	Function	: Updates row in Bom Operation Resources
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
--	  p_resource_rec	RESOURCE_REC_TYPE Required
--	    Default = G_MISS_RESOURCE_REC
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_resource_rec	RESOURCE_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full Validation includes AssignResource and
--			  ValidateResource
--
--	API name 	: DeleteResource
--	Type		: Private.
--	Function	: Deletes row from Bom Operation Resources
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
--	  p_resource_rec	RESOURCE_REC_TYPE Required
--	    Default = G_MISS_RESOURCE_REC
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_resource_rec	RESOURCE_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full Validation includes AssignResource
--
-- End of comments
TYPE resource_rec_type is record(
 operation_sequence_id           NUMBER          := Fnd_Api.G_Miss_Num,
 routing_sequence_id             NUMBER          := Fnd_Api.G_Miss_Num,
 assembly_item_id                NUMBER          := Fnd_Api.G_Miss_Num,
 assembly_item_number            VARCHAR2(81)    := Fnd_Api.G_Miss_Char,
 organization_id                 NUMBER          := Fnd_Api.G_Miss_Num,
 organization_code               VARCHAR2(3)     := Fnd_Api.G_Miss_Char,
 alternate_routing_designator    VARCHAR2(10)    := Fnd_Api.G_Miss_Char,
 operation_seq_num               NUMBER          := Fnd_Api.G_Miss_Num,
 effectivity_date                DATE            := Fnd_Api.G_Miss_Date,
 resource_seq_num                NUMBER          := Fnd_Api.G_Miss_Num,
 new_resource_seq_num            NUMBER          := Fnd_Api.G_Miss_Num,
 resource_id                     NUMBER          := Fnd_Api.G_Miss_Num,
 resource_code                   VARCHAR2(10)    := Fnd_Api.G_Miss_Char,
 activity_id                     NUMBER          := Fnd_Api.G_Miss_Num,
 activity                        VARCHAR2(10)    := Fnd_Api.G_Miss_Char,
 standard_rate_flag              NUMBER          := Fnd_Api.G_Miss_Num,
 assigned_units                  NUMBER          := Fnd_Api.G_Miss_Num,
 usage_rate_or_amount            NUMBER          := Fnd_Api.G_Miss_Num,
 usage_rate_or_amount_inverse    NUMBER          := Fnd_Api.G_Miss_Num,
 basis_type                      NUMBER          := Fnd_Api.G_Miss_Num,
 schedule_flag                   NUMBER          := Fnd_Api.G_Miss_Num,
 resource_offset_percent         NUMBER          := Fnd_Api.G_Miss_Num,
 autocharge_type                 NUMBER          := Fnd_Api.G_Miss_Num,
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
 attribute15                     VARCHAR2(150)   := Fnd_Api.G_Miss_Char,
 Principle_flag			 Number		 := Fnd_Api.G_Miss_Num,
 schedule_seq_num		 Number		 := Fnd_Api.G_Miss_Num
);

G_MISS_RESOURCE_REC RESOURCE_REC_TYPE;
G_VALID_LEVEL_NO_ASSIGN constant number := 5;
G_round_off_val number :=NVL(FND_PROFILE.VALUE('BOM:ROUND_OFF_VALUE'),6); /* Bug 7322996 */

PROCEDURE AssignResource(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status IN OUT NOCOPY VARCHAR2,
  x_msg_count	 IN OUT NOCOPY NUMBER,
  x_msg_data	 IN OUT NOCOPY VARCHAR2,
  p_resource_rec	IN	RESOURCE_REC_TYPE := G_MISS_RESOURCE_REC,
  x_resource_rec IN OUT NOCOPY RESOURCE_REC_TYPE
);
PROCEDURE ValidateResource(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status IN OUT NOCOPY VARCHAR2,
  x_msg_count	 IN OUT NOCOPY NUMBER,
  x_msg_data	 IN OUT NOCOPY VARCHAR2,
  p_resource_rec	IN	RESOURCE_REC_TYPE := G_MISS_RESOURCE_REC,
  x_resource_rec IN OUT NOCOPY RESOURCE_REC_TYPE
);
PROCEDURE CreateResource(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status IN OUT NOCOPY VARCHAR2,
  x_msg_count	 IN OUT NOCOPY NUMBER,
  x_msg_data	 IN OUT NOCOPY VARCHAR2,
  p_resource_rec	IN	RESOURCE_REC_TYPE := G_MISS_RESOURCE_REC,
  x_resource_rec IN OUT NOCOPY RESOURCE_REC_TYPE
);
PROCEDURE UpdateResource(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status IN OUT NOCOPY VARCHAR2,
  x_msg_count	 IN OUT NOCOPY NUMBER,
  x_msg_data	 IN OUT NOCOPY VARCHAR2,
  p_resource_rec	IN	RESOURCE_REC_TYPE := G_MISS_RESOURCE_REC,
  x_resource_rec IN OUT NOCOPY RESOURCE_REC_TYPE
);
PROCEDURE DeleteResource(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status IN OUT NOCOPY VARCHAR2,
  x_msg_count	 IN OUT NOCOPY NUMBER,
  x_msg_data	 IN OUT NOCOPY VARCHAR2,
  p_resource_rec	IN	RESOURCE_REC_TYPE := G_MISS_RESOURCE_REC,
  x_resource_rec IN OUT NOCOPY RESOURCE_REC_TYPE
);
END Bom_OpResource_Pvt;

/
