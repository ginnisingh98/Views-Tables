--------------------------------------------------------
--  DDL for Package CS_COUNTERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_COUNTERS_PUB" AUTHID CURRENT_USER AS
/* $Header: cspctrs.pls 120.2.12000000.1 2007/01/17 01:54:01 appldev ship $ */

-- ---------------------------------------------------------
-- Declare Data Types
-- ---------------------------------------------------------

TYPE CtrGrp_Rec_Type IS RECORD
(
	name				VARCHAR2(30),  --	:= FND_API.G_MISS_CHAR,
	description			VARCHAR2(240), --	:= FND_API.G_MISS_CHAR,
	association_type		VARCHAR2(30), --	:= FND_API.G_MISS_CHAR,
	start_date_active		DATE, --		:= FND_API.G_MISS_DATE,
	end_date_active			DATE, --		:= FND_API.G_MISS_DATE,
	desc_flex				CS_COUNTERS_EXT_PVT.DFF_Rec_Type
);

TYPE Ctr_Rec_Type IS RECORD
(
        ctr_tbl_index                   NUMBER , --         := FND_API.G_MISS_NUM,
	counter_group_id		NUMBER , --		:= FND_API.G_MISS_NUM,
	name				VARCHAR2(30), --	:= FND_API.G_MISS_CHAR,
	description			VARCHAR2(240), --	:= FND_API.G_MISS_CHAR,
	type				VARCHAR2(30), --	:= FND_API.G_MISS_CHAR,
	step_value			NUMBER, --          := FND_API.G_MISS_NUM,
	initial_reading			NUMBER, --          := FND_API.G_MISS_NUM,
	rollover_last_reading		NUMBER, --          := FND_API.G_MISS_NUM,
	rollover_first_reading		NUMBER, --          := FND_API.G_MISS_NUM,
	uom_code			VARCHAR2(3), --	:= FND_API.G_MISS_CHAR,
	tolerance_plus			NUMBER, --		:= FND_API.G_MISS_NUM,
	tolerance_minus			NUMBER, --		:= FND_API.G_MISS_NUM,
	derive_function			VARCHAR2(30), --	:= FND_API.G_MISS_CHAR,
	derive_counter_id		NUMBER, --		:= FND_API.G_MISS_NUM,
	derive_property_id		NUMBER, --		:= FND_API.G_MISS_NUM,
	formula_text			VARCHAR2(1996), --	:= FND_API.G_MISS_CHAR,
	comments			VARCHAR2(1996), --	:= FND_API.G_MISS_CHAR,
	usage_item_id			NUMBER , --         := FND_API.G_MISS_NUM,
	start_date_active		DATE, --		:= FND_API.G_MISS_DATE,
	end_date_active			DATE, --		:= FND_API.G_MISS_DATE,
	desc_flex					CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	customer_view                   VARCHAR2(1), --	:= FND_API.G_MISS_CHAR,
        duration 			NUMBER, --		:= FND_API.G_MISS_NUM,
  	duration_uom  			VARCHAR2(3), --	:= FND_API.G_MISS_CHAR,
        direction                       VARCHAR2(1), --     := FND_API.G_MISS_CHAR,
        filter_reading_count            NUMBER , --         := FND_API.G_MISS_NUM,
        filter_type			VARCHAR2(1) , --    := FND_API.G_MISS_CHAR,
        filter_time_uom			VARCHAR2(30), --    := FND_API.G_MISS_CHAR,
        estimation_id			NUMBER  --        := FND_API.G_MISS_NUM
);

TYPE Ctr_Prop_Rec_Type IS RECORD
(
        ctr_tbl_index           NUMBER , --         := FND_API.G_MISS_NUM,
	counter_id		NUMBER, --		:= FND_API.G_MISS_NUM,
	name			VARCHAR2(30), --	:= FND_API.G_MISS_CHAR,
	description		VARCHAR2(240), --	:= FND_API.G_MISS_CHAR,
	property_data_type	VARCHAR2(30), --	:= FND_API.G_MISS_CHAR,
	is_nullable		VARCHAR2(1), --	:= FND_API.G_MISS_CHAR,
	default_value		VARCHAR2(240), --	:= FND_API.G_MISS_CHAR,
	minimum_value		VARCHAR2(240), --	:= FND_API.G_MISS_CHAR,
	maximum_value		VARCHAR2(240), --	:= FND_API.G_MISS_CHAR,
	uom_code		VARCHAR2(3), --	:= FND_API.G_MISS_CHAR,
	start_date_active	DATE, --		:= FND_API.G_MISS_DATE,
	end_date_active	DATE, --			:= FND_API.G_MISS_DATE,
	desc_flex			CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	property_lov_type       VARCHAR2(30)  --   := FND_API.G_MISS_CHAR
);

TYPE CTR_Estimation_Rec_Type IS RECORD
(
        estimation_name         VARCHAR2(30), --    := FND_API.G_MISS_CHAR,
        estimation_description  VARCHAR2(240), --   := FND_API.G_MISS_CHAR,
        estimation_type         VARCHAR2(10), --    := FND_API.G_MISS_CHAR,
        estimation_avg_type     VARCHAR2(3), --     := FND_API.G_MISS_CHAR,
        fixed_Value             NUMBER , --         := FND_API.G_MISS_NUM,
        Usage_Markup            NUMBER , --         := FND_API.G_MISS_NUM,
        Default_Value           NUMBER , --         := FND_API.G_MISS_NUM,
        Counter_Group_id        NUMBER , --         := FND_API.G_MISS_NUM,
        Counter_id              NUMBER , --         := FND_API.G_MISS_NUM,
        start_date_active       DATE   , --         := FND_API.G_MISS_DATE,
        end_date_active         DATE  , --          := FND_API.G_MISS_DATE,
        ATTRIBUTE1              VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE2              VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE3              VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE4              VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE5              VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE6              VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE7              VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE8              VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE9              VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE10             VARCHAR2(150) , --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE11             VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE12             VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE13             VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE14             VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE15             VARCHAR2(150), --   := FND_API.G_MISS_CHAR,
        ATTRIBUTE_CATEGORY      VARCHAR2(30) --    := FND_API.G_MISS_CHAR
);

TYPE Ctr_Association_Rec_Type IS RECORD
(
	counter_group_id	NUMBER, --		:= FND_API.G_MISS_NUM,
	source_object_id        NUMBER, --		:= FND_API.G_MISS_NUM,
        desc_flex			CS_COUNTERS_EXT_PVT.DFF_Rec_Type
);

--
--
-------------------------------------------------------------------------------
--
-- Program Units
--
-------------------------------------------------------------------------------
--

FUNCTION Ctr_Grp_Template_Exists
(
	p_item_id	NUMBER
) RETURN BOOLEAN;


PROCEDURE Create_Ctr_Grp_Template
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY 	VARCHAR2,
	x_msg_count			OUT NOCOPY 	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_grp_rec			IN	CS_COUNTERS_PUB.CtrGrp_Rec_Type,
	x_ctr_grp_id			IN OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER
);

PROCEDURE Create_Ctr_Grp_Instance
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_grp_rec			IN	CS_COUNTERS_PUB.CtrGrp_Rec_Type,
	p_source_object_cd		IN	VARCHAR2,
	p_source_object_id		IN	NUMBER,
	x_ctr_grp_id			IN OUT NOCOPY	NUMBER,
	x_object_version_number	        OUT NOCOPY	NUMBER
);

PROCEDURE Create_Counter
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		  	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_rec			IN	CS_COUNTERS_PUB.Ctr_Rec_Type,
	x_ctr_id			IN OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER
);

PROCEDURE Create_Ctr_Prop
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_prop_rec			IN	Ctr_Prop_Rec_Type,
	x_ctr_prop_id			IN OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER
);

PROCEDURE Create_Formula_Ref
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_counter_id			IN	NUMBER,
	p_bind_var_name			IN	VARCHAR2,
	p_mapped_item_id		IN	NUMBER	default null,
	p_mapped_counter_id		IN	NUMBER,
	p_desc_flex			IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	x_ctr_formula_bvar_id		IN OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER,
	p_reading_type          	IN      VARCHAR2
);

PROCEDURE Create_GrpOp_Filter
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_seq_no		IN	NUMBER		DEFAULT null,
	p_counter_id		IN	NUMBER,
	p_left_paren		IN	VARCHAR2,
	p_ctr_prop_id		IN	NUMBER,
	p_rel_op		IN	VARCHAR2,
	p_right_val		IN	VARCHAR2,
	p_right_paren		IN	VARCHAR2,
	p_log_op		IN	VARCHAR2,
	p_desc_flex		IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	x_ctr_der_filter_id	IN OUT NOCOPY	NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Create_Ctr_Association
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_ctr_grp_id		IN	NUMBER,
	p_source_object_id	IN	NUMBER,
	p_desc_flex		IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	x_ctr_association_id	OUT NOCOPY	NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE AutoInstantiate_Counters
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_source_object_id_template    	IN	NUMBER,
	p_source_object_id_instance	IN	NUMBER,
	x_ctr_grp_id_template		IN OUT NOCOPY	NUMBER,
	x_ctr_grp_id_instance		IN OUT NOCOPY	NUMBER,
        p_organization_id               IN      NUMBER     DEFAULT cs_std.get_item_valdn_orgzn_id
);

PROCEDURE Update_Ctr_Grp
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_grp_id			IN	NUMBER,
	p_object_version_number		IN	NUMBER,
	p_ctr_grp_rec			IN	CS_COUNTERS_PUB.CtrGrp_Rec_Type,
	p_cascade_upd_to_instances	IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	x_object_version_number		OUT NOCOPY	NUMBER
);

PROCEDURE Update_Counter
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_id			IN	NUMBER,
	p_object_version_number		IN	NUMBER,
	p_ctr_rec			IN	CS_COUNTERS_PUB.Ctr_Rec_Type,
	p_cascade_upd_to_instances	IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	x_object_version_number		OUT NOCOPY	NUMBER
);

PROCEDURE Update_Ctr_Prop
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_prop_id			IN	NUMBER,
	p_object_version_number		IN	NUMBER,
	p_ctr_prop_rec			IN	Ctr_Prop_Rec_Type,
	p_cascade_upd_to_instances	IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	x_object_version_number		OUT NOCOPY	NUMBER
);

PROCEDURE Update_Formula_Ref
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_formula_bvar_id		IN	NUMBER,
	p_object_version_number		IN	NUMBER,
	p_counter_id			IN	NUMBER,
	p_bind_var_name			IN	VARCHAR2,
	p_mapped_item_id		IN	NUMBER	default null,
	p_mapped_counter_id		IN	NUMBER,
	p_desc_flex			IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	p_cascade_upd_to_instances	IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	x_object_version_number		OUT NOCOPY	NUMBER,
	p_reading_type                  IN	VARCHAR2
);

PROCEDURE Update_GrpOp_Filter
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_der_filter_id		IN	NUMBER,
	p_object_version_number		IN	NUMBER,
	p_seq_no			IN	NUMBER		DEFAULT null,
	p_counter_id			IN	NUMBER,
	p_left_paren			IN	VARCHAR2,
	p_ctr_prop_id			IN	NUMBER,
	p_rel_op			IN	VARCHAR2,
	p_right_val			IN	VARCHAR2,
	p_right_paren			IN	VARCHAR2,
	p_log_op			IN	VARCHAR2,
	p_desc_flex			IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	p_cascade_upd_to_instances	IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	x_object_version_number		OUT NOCOPY	NUMBER
);

PROCEDURE Update_Ctr_Association
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_association_id		IN	NUMBER,
	p_object_version_number		IN	NUMBER,
	p_ctr_grp_id			IN	NUMBER,
	p_source_object_id		IN	NUMBER,
	p_desc_flex			IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	x_object_version_number		OUT NOCOPY	NUMBER
);

PROCEDURE Delete_Counter
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_id			IN	NUMBER
);

PROCEDURE Delete_Ctr_Prop
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_prop_id			IN	NUMBER
);

PROCEDURE Delete_Formula_Ref
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_formula_bvar_id		IN	NUMBER
);

PROCEDURE Delete_GrpOp_Filter
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_der_filter_id		IN	NUMBER
);

PROCEDURE Delete_Ctr_Association
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_association_id		IN	NUMBER
);

PROCEDURE Instantiate_Counters
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_counter_group_id_template   	IN	NUMBER,
	p_source_object_code_instance   IN      VARCHAR2,
	p_source_object_id_instance	IN	NUMBER,
	x_ctr_grp_id_template		OUT NOCOPY	NUMBER,
	x_ctr_grp_id_instance		OUT NOCOPY	NUMBER
);

PROCEDURE DELETE_COUNTER_INSTANCE(
  p_Api_Version                 IN   NUMBER,
  p_Init_Msg_List               IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN   VARCHAR2 := FND_API.G_FALSE,
  p_SOURCE_OBJECT_ID            IN   NUMBER,
  p_SOURCE_OBJECT_CODE          IN   VARCHAR2,
  x_Return_status               OUT NOCOPY  VARCHAR2,
  x_Msg_Count                   OUT NOCOPY  NUMBER,
  x_Msg_Data                    OUT NOCOPY  VARCHAR2,
  x_delete_status               OUT NOCOPY  VARCHAR2
  );

PROCEDURE Instantiate_single_Ctr
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2        := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2        := FND_API.G_FALSE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2,
        p_counter_id_template           IN      NUMBER,
        p_source_object_code_instance   IN      VARCHAR2,
        p_source_object_id_instance     IN      NUMBER,
        x_ctr_id_instance               OUT NOCOPY     NUMBER
);

PROCEDURE Create_Estimation_Method
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2,
        p_ctr_estimation_rec            IN      CS_COUNTERS_PUB.Ctr_Estimation_Rec_Type,
        x_estimation_id                 IN OUT NOCOPY   NUMBER,
        x_object_version_number         OUT NOCOPY      NUMBER
);

PROCEDURE Update_Estimation_Method
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        x_return_status                 OUT NOCOPY      VARCHAR2,
        x_msg_count                     OUT NOCOPY      NUMBER,
        x_msg_data                      OUT NOCOPY      VARCHAR2,
        p_estimation_id                 IN      NUMBER,
        p_object_version_number         IN      NUMBER,
        p_ctr_estimation_rec            IN      CS_COUNTERS_PUB.Ctr_Estimation_Rec_Type,
        x_object_version_number         OUT NOCOPY      NUMBER
);

END CS_Counters_PUB;

 

/
