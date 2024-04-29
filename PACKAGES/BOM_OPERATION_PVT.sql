--------------------------------------------------------
--  DDL for Package BOM_OPERATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_OPERATION_PVT" AUTHID CURRENT_USER AS
-- $Header: BOMVOPRS.pls 120.1 2005/06/21 03:04:16 appldev ship $
-- Start of comments
--	API name 	: AssignOperation
--	Type		: Private.
--	Function	: Populate Ids from values
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
--	  p_operation_rec	OPERATION_REC_TYPE	Optional
--	    Default = G_MISS_OPERATION_REC
--
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_operation_rec	OPERATION_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		:
--
--	API name 	: ValidateOperation
--	Type		: Private.
--	Function	: Validate Operation
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
--	  p_operation_rec	OPERATION_REC_TYPE	Optional
--	    Default = G_MISS_OPERATION_REC
--
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_operation_rec	OPERATION_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full validation includes assign
--
--	API name 	: CreateOperation
--	Type		: Private.
--	Function	: Insert row into BOM_OPERATION_SEQUENCES
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
--	  p_operation_rec	OPERATION_REC_TYPE	Optional
--	    Default = G_MISS_OPERATION_REC
--
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_operation_rec	OPERATION_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full validation includes assign and validate
--
--	API name 	: UpdateOperation
--	Type		: Private.
--	Function	: Update a row in BOM_OPERATION_SEQUENCES
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
--	  p_operation_rec	OPERATION_REC_TYPE	Optional
--	    Default = G_MISS_OPERATION_REC
--
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_operation_rec	OPERATION_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full validation includes assign and validate
--
--	API name 	: DeleteOperation
--	Type		: Private.
--	Function	: Insert operation into a Delete Group
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
--        p_delete_group        VARCHAR2
--        p_description         VARCHAR2 Default = Null
--	  p_operation_rec	OPERATION_REC_TYPE	Optional
--	    Default = G_MISS_OPERATION_REC
--
--	OUT		:
--	  x_return_status	VARCHAR2(1)
--	  x_msg_count		NUMBER
--	  x_msg_data		VARCHAR2(2000)
--	  x_operation_rec	OPERATION_REC_TYPE
--
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Full validation includes assign
--
-- End of comments
TYPE operation_rec_type is record(
  operation_sequence_id          number          := Fnd_Api.G_Miss_Num,
  routing_sequence_id            number          := Fnd_Api.G_Miss_Num,
  assembly_item_id               number          := Fnd_Api.G_Miss_Num,
  assembly_item_number           varchar2(81)    := Fnd_Api.G_Miss_Char,
  organization_id                number          := Fnd_Api.G_Miss_Num,
  organization_code              varchar2(3)     := Fnd_Api.G_Miss_Char,
  alternate_routing_designator   varchar2(10)    := Fnd_Api.G_Miss_Char,
  operation_seq_num              number          := Fnd_Api.G_Miss_Num,
  new_operation_seq_num          number          := Fnd_Api.G_Miss_Num,
  standard_operation_id          number          := Fnd_Api.G_Miss_Num,
  operation_code                 varchar2(4)     := Fnd_Api.G_Miss_Char,
  department_id                  number          := Fnd_Api.G_Miss_Num,
  department_code                varchar2(10)    := Fnd_Api.G_Miss_Char,
  operation_lead_time_percent    number          := Fnd_Api.G_Miss_Num,
  minimum_transfer_quantity      number          := Fnd_Api.G_Miss_Num,
  count_point_type               number          := Fnd_Api.G_Miss_Num,
  operation_description          varchar2(240)   := Fnd_Api.G_Miss_Char,
  effectivity_date               date            := Fnd_Api.G_Miss_Date,
  new_effectivity_date           date            := Fnd_Api.G_Miss_Date,
  disable_date                   date            := Fnd_Api.G_Miss_Date,
  backflush_flag                 number          := Fnd_Api.G_Miss_Num,
  option_dependent_flag          number          := Fnd_Api.G_Miss_Num,
  attribute_category             varchar2(30)    := Fnd_Api.G_Miss_Char,
  attribute1                     varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute2                     varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute3                     varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute4                     varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute5                     varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute6                     varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute7                     varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute8                     varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute9                     varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute10                    varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute11                    varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute12                    varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute13                    varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute14                    varchar2(150)   := Fnd_Api.G_Miss_Char,
  attribute15                    varchar2(150)   := Fnd_Api.G_Miss_Char,
  operation_type                 number          := Fnd_Api.G_Miss_Num,
  reference_flag                 number          := Fnd_Api.G_Miss_Num,
  process_op_seq_id              number          := Fnd_Api.G_Miss_Num,
  line_op_seq_id                 number          := Fnd_Api.G_Miss_Num,
  yield                          number          := Fnd_Api.G_Miss_Num,
  cumulative_yield               number          := Fnd_Api.G_Miss_Num,
  reverse_cumulative_yield       number          := Fnd_Api.G_Miss_Num,
  labor_time_calc                number          := Fnd_Api.G_Miss_Num,
  machine_time_calc              number          := Fnd_Api.G_Miss_Num,
  total_time_calc                number          := Fnd_Api.G_Miss_Num,
  labor_time_user                number          := Fnd_Api.G_Miss_Num,
  machine_time_user              number          := Fnd_Api.G_Miss_Num,
  total_time_user                number          := Fnd_Api.G_Miss_Num,
  net_planning_percent           number          := Fnd_Api.G_Miss_Num,
  include_in_rollup              number          := Fnd_Api.G_Miss_Num,
  operation_yield_enabled        number          := Fnd_Api.G_Miss_Num
);

G_MISS_OPERATION_REC operation_rec_type;
G_VALID_LEVEL_NO_ASSIGN constant number := 5;

PROCEDURE AssignOperation(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY 	VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_operation_rec	IN	OPERATION_REC_TYPE := G_MISS_OPERATION_REC,
  x_operation_rec	IN OUT NOCOPY OPERATION_REC_TYPE
);

PROCEDURE ValidateOperation(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_operation_rec	IN	OPERATION_REC_TYPE := G_MISS_OPERATION_REC,
  x_operation_rec	IN OUT NOCOPY OPERATION_REC_TYPE
);

PROCEDURE CreateOperation(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_operation_rec	IN	OPERATION_REC_TYPE := G_MISS_OPERATION_REC,
  x_operation_rec	IN OUT NOCOPY OPERATION_REC_TYPE
);

PROCEDURE UpdateOperation(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_operation_rec	IN	OPERATION_REC_TYPE := G_MISS_OPERATION_REC,
  x_operation_rec	IN OUT NOCOPY OPERATION_REC_TYPE
);

PROCEDURE DeleteOperation(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_delete_group        IN	VARCHAR2,
  p_description         IN	VARCHAR2 := Null,
  p_operation_rec	IN	OPERATION_REC_TYPE := G_MISS_OPERATION_REC,
  x_operation_rec	IN OUT NOCOPY OPERATION_REC_TYPE
);

END BOM_Operation_Pvt;

 

/
