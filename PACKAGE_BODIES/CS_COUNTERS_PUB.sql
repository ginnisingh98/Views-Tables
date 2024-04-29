--------------------------------------------------------
--  DDL for Package Body CS_COUNTERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_COUNTERS_PUB" AS
/* $Header: cspctrb.pls 120.5.12000000.4 2007/06/18 09:14:55 ngoutam ship $ */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME	CONSTANT	VARCHAR2(30)	:= 'CS_COUNTERS_PUB';
--G_USER		CONSTANT	VARCHAR2(30)	:= FND_GLOBAL.USER_ID;
--------------------------------------------------------------------------

-- ---------------------------------------------------------
-- Private program units
-- ---------------------------------------------------------

PROCEDURE Initialize_Desc_Flex_For_Upd
(
	p_desc_flex		IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	p_old_desc_flex	IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	x_desc_flex		OUT NOCOPY	CS_COUNTERS_EXT_PVT.DFF_Rec_Type
) IS
BEGIN
	x_desc_flex := p_desc_flex;
	IF p_desc_flex.attribute1 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute1 := p_old_desc_flex.attribute1;
	END IF;

	IF p_desc_flex.attribute2 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute2 := p_old_desc_flex.attribute2;
	END IF;

	IF p_desc_flex.attribute3 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute3 := p_old_desc_flex.attribute3;
	END IF;

	IF p_desc_flex.attribute4 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute4 := p_old_desc_flex.attribute4;
	END IF;

	IF p_desc_flex.attribute5 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute5 := p_old_desc_flex.attribute5;
	END IF;

	IF p_desc_flex.attribute6 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute6 := p_old_desc_flex.attribute6;
	END IF;

	IF p_desc_flex.attribute7 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute7 := p_old_desc_flex.attribute7;
	END IF;

	IF p_desc_flex.attribute8 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute8 := p_old_desc_flex.attribute8;
	END IF;

	IF p_desc_flex.attribute9 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute9 := p_old_desc_flex.attribute1;
	END IF;

	IF p_desc_flex.attribute10 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute10 := p_old_desc_flex.attribute10;
	END IF;

	IF p_desc_flex.attribute11 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute11 := p_old_desc_flex.attribute11;
	END IF;

	IF p_desc_flex.attribute12 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute12 := p_old_desc_flex.attribute12;
	END IF;

	IF p_desc_flex.attribute13 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute13 := p_old_desc_flex.attribute13;
	END IF;

	IF p_desc_flex.attribute14 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute14 := p_old_desc_flex.attribute14;
	END IF;

	IF p_desc_flex.attribute15 = FND_API.G_MISS_CHAR THEN
		x_desc_flex.attribute15 := p_old_desc_flex.attribute15;
	END IF;

        IF p_desc_flex.context = FND_API.G_MISS_CHAR THEN
                x_desc_flex.context := p_old_desc_flex.context;
        END IF;

END Initialize_Desc_Flex_For_Upd;

PROCEDURE Initialize_CtrRec_For_Upd
(
	p_ctr_rec		IN	Ctr_Rec_Type,
	p_old_ctr_rec	        IN	Ctr_Rec_Type,
	x_ctr_rec		OUT NOCOPY	Ctr_Rec_Type
) IS
BEGIN
	x_ctr_rec := p_ctr_rec;
	IF p_ctr_rec.counter_group_id = FND_API.G_MISS_NUM THEN
		x_ctr_rec.counter_group_id := p_old_ctr_rec.counter_group_id;
	END IF;

	IF p_ctr_rec.name = FND_API.G_MISS_CHAR THEN
		x_ctr_rec.name := p_old_ctr_rec.name;
	END IF;

	IF p_ctr_rec.type = FND_API.G_MISS_CHAR THEN
		x_ctr_rec.type := p_old_ctr_rec.type;
	END IF;

	IF p_ctr_rec.initial_reading = FND_API.G_MISS_NUM THEN
		x_ctr_rec.initial_reading := p_old_ctr_rec.initial_reading;
	END IF;

	IF p_ctr_rec.step_value = FND_API.G_MISS_NUM THEN
		x_ctr_rec.step_value := p_old_ctr_rec.step_value;
	END IF;

	IF p_ctr_rec.uom_code = FND_API.G_MISS_CHAR THEN
		x_ctr_rec.uom_code := p_old_ctr_rec.uom_code;
	END IF;

	IF p_ctr_rec.derive_function = FND_API.G_MISS_CHAR THEN
		x_ctr_rec.derive_function := p_old_ctr_rec.derive_function;
	END IF;

	IF p_ctr_rec.derive_counter_id = FND_API.G_MISS_NUM THEN
		x_ctr_rec.derive_counter_id := p_old_ctr_rec.derive_counter_id;
	END IF;

	IF p_ctr_rec.derive_property_id = FND_API.G_MISS_NUM THEN
		x_ctr_rec.derive_property_id := p_old_ctr_rec.derive_property_id;
	END IF;

	IF p_ctr_rec.formula_text = FND_API.G_MISS_CHAR THEN
		x_ctr_rec.formula_text := p_old_ctr_rec.formula_text;
	END IF;

	IF p_ctr_rec.usage_item_id = FND_API.G_MISS_NUM THEN
		x_ctr_rec.usage_item_id := p_old_ctr_rec.usage_item_id;
	END IF;

	IF p_ctr_rec.start_date_active = FND_API.G_MISS_DATE THEN
		x_ctr_rec.start_date_active := p_old_ctr_rec.start_date_active;
	END IF;

	IF p_ctr_rec.end_date_active = FND_API.G_MISS_DATE THEN
		x_ctr_rec.end_date_active := p_old_ctr_rec.end_date_active;
	END IF;

	IF p_ctr_rec.customer_view = FND_API.G_MISS_CHAR THEN
		x_ctr_rec.customer_view := p_old_ctr_rec.customer_view;
	END IF;

	IF p_ctr_rec.duration = FND_API.G_MISS_NUM THEN
		x_ctr_rec.duration := p_old_ctr_rec.duration;
	END IF;

	IF p_ctr_rec.duration_uom = FND_API.G_MISS_CHAR THEN
		x_ctr_rec.duration_uom := p_old_ctr_rec.duration_uom;
	END IF;

        IF p_ctr_rec.direction = FND_API.G_MISS_CHAR THEN
                x_ctr_rec.direction := p_old_ctr_rec.direction;
        END IF;

        IF p_ctr_rec.filter_reading_count = FND_API.G_MISS_NUM THEN
                x_ctr_rec.filter_reading_count := p_old_ctr_rec.filter_reading_count;
        END IF;

        IF p_ctr_rec.filter_type = FND_API.G_MISS_CHAR THEN
                x_ctr_rec.filter_type := p_old_ctr_rec.filter_type;
        END IF;

        IF p_ctr_rec.filter_time_uom = FND_API.G_MISS_CHAR THEN
                x_ctr_rec.filter_time_uom := p_old_ctr_rec.filter_time_uom;
        END IF;

        IF p_ctr_rec.estimation_id = FND_API.G_MISS_CHAR THEN
                x_ctr_rec.estimation_id := p_old_ctr_rec.estimation_id;
        END IF;


	Initialize_Desc_Flex_For_Upd
	(
		p_ctr_Rec.desc_flex,
		p_old_ctr_Rec.desc_flex,
		x_ctr_rec.desc_flex
	);

END Initialize_CtrRec_For_Upd;

PROCEDURE Initialize_CtrPropRec_For_Upd
(
	p_ctr_prop_rec		IN	Ctr_Prop_Rec_Type,
	p_old_ctr_prop_rec	IN	Ctr_Prop_Rec_Type,
	x_ctr_prop_rec		OUT NOCOPY	Ctr_Prop_Rec_Type
) IS
BEGIN
	x_ctr_prop_rec := p_ctr_prop_rec;
	IF p_ctr_prop_rec.counter_id = FND_API.G_MISS_NUM THEN
		x_ctr_prop_rec.counter_id := p_old_ctr_prop_rec.counter_id;
	END IF;

	IF p_ctr_prop_rec.name = FND_API.G_MISS_CHAR THEN
		x_ctr_prop_rec.name := p_old_ctr_prop_rec.name;
	END IF;

	IF p_ctr_prop_rec.property_data_type = FND_API.G_MISS_CHAR THEN
		x_ctr_prop_rec.property_data_type := p_old_ctr_prop_rec.property_data_type;
	END IF;

	IF p_ctr_prop_rec.default_value = FND_API.G_MISS_CHAR THEN
		x_ctr_prop_rec.default_value := p_old_ctr_prop_rec.default_value;
	END IF;

	IF p_ctr_prop_rec.maximum_value = FND_API.G_MISS_CHAR THEN
		x_ctr_prop_rec.maximum_value := p_old_ctr_prop_rec.default_value;
	END IF;

	IF p_ctr_prop_rec.minimum_value = FND_API.G_MISS_CHAR THEN
		x_ctr_prop_rec.minimum_value := p_old_ctr_prop_rec.minimum_value;
	END IF;

	IF p_ctr_prop_rec.start_date_active = FND_API.G_MISS_DATE THEN
		x_ctr_prop_rec.start_date_active := p_old_ctr_prop_rec.start_date_active;
	END IF;

	IF p_ctr_prop_rec.end_date_active = FND_API.G_MISS_DATE THEN
		x_ctr_prop_rec.end_date_active := p_old_ctr_prop_rec.end_date_active;
	END IF;

	IF p_ctr_prop_rec.property_lov_type = FND_API.G_MISS_CHAR THEN
		x_ctr_prop_rec.property_lov_type := p_old_ctr_prop_rec.property_lov_type;
	END IF;


	Initialize_Desc_Flex_For_Upd
	(
		p_ctr_prop_Rec.desc_flex,
		p_old_ctr_prop_Rec.desc_flex,
		x_ctr_prop_rec.desc_flex
	);

END Initialize_CtrPropRec_For_Upd;


-- ---------------------------------------------------------
-- Public program units
-- ---------------------------------------------------------

FUNCTION Ctr_Grp_Template_Exists
(
	p_item_id	NUMBER
) RETURN BOOLEAN IS

	l_return_value	BOOLEAN := TRUE;
	l_ctr_grp_id	NUMBER;

 Cursor Grp_Tmpl(p_inv_item_id NUMBER) IS
   SELECT group_id
   FROM csi_ctr_item_associations
   WHERE associated_to_group='Y'
   AND inventory_item_id = p_inv_item_id;

BEGIN
 open Grp_tmpl(p_item_id);
 fetch Grp_tmpl into l_ctr_grp_id;
 close Grp_tmpl;
 If l_ctr_grp_id is not null then
   l_return_value := TRUE;
 Else
   l_return_value := FALSE;
 End If;
   RETURN (l_return_value);
END;

PROCEDURE Create_Ctr_Grp_Template
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		        IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 :=  FND_API.G_FALSE,
	x_return_status		        OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_grp_rec			IN	CS_COUNTERS_PUB.CtrGrp_Rec_Type,
	x_ctr_grp_id			IN OUT NOCOPY	NUMBER,
	x_object_version_number	        OUT NOCOPY	NUMBER
) IS
	l_api_name     CONSTANT	VARCHAR2(30)	:= 'CREATE_CTR_GRP_TEMPLATE';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_ctr_groups_rec   CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec;
 l_ctr_item_associations_tbl  CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl;
 l_validation_level NUMBER;

BEGIN

	SAVEPOINT	Create_Ctr_Grp_Template_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	  -- Customer/Vertical Hookups
        /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Create_Ctr_Grp_Template_Pre (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_ctr_grp_rec         => p_ctr_grp_rec,
             x_ctr_grp_id          => x_ctr_grp_id,
             x_object_version_number => x_object_version_number
            );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Create_Ctr_Grp_Template_Pre (
              p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_ctr_grp_rec         => p_ctr_grp_rec,
             x_ctr_grp_id          => x_ctr_grp_id,
             x_object_version_number => x_object_version_number
            );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;


	-- Start of API Body
 l_ctr_groups_rec.COUNTER_GROUP_ID := x_ctr_grp_id;
 l_ctr_groups_rec.NAME             := p_ctr_grp_rec.NAME;
 l_ctr_groups_rec.DESCRIPTION      := p_ctr_grp_rec.DESCRIPTION;
 l_ctr_groups_rec.START_DATE_ACTIVE   := p_ctr_grp_rec.start_date_active;
 l_ctr_groups_rec.END_DATE_ACTIVE     := p_ctr_grp_rec.end_date_active;
 l_ctr_groups_rec.ATTRIBUTE1      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE1;
 l_ctr_groups_rec.ATTRIBUTE2      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE2;
 l_ctr_groups_rec.ATTRIBUTE3      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE3;
 l_ctr_groups_rec.ATTRIBUTE4      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE4;
 l_ctr_groups_rec.ATTRIBUTE5      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE5;
 l_ctr_groups_rec.ATTRIBUTE6      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE6;
 l_ctr_groups_rec.ATTRIBUTE7      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE7;
 l_ctr_groups_rec.ATTRIBUTE8      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE8;
 l_ctr_groups_rec.ATTRIBUTE9      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE9;
 l_ctr_groups_rec.ATTRIBUTE10     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE10;
 l_ctr_groups_rec.ATTRIBUTE11     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE11;
 l_ctr_groups_rec.ATTRIBUTE12     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE12;
 l_ctr_groups_rec.ATTRIBUTE13     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE13;
 l_ctr_groups_rec.ATTRIBUTE14     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE14;
 l_ctr_groups_rec.ATTRIBUTE15     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE15;
 l_ctr_groups_rec.CONTEXT         := p_ctr_grp_rec.DESC_FLEX.CONTEXT;
 l_ctr_groups_rec.ASSOCIATION_TYPE   :=  p_ctr_grp_rec.ASSOCIATION_TYPE;


 CSI_COUNTER_TEMPLATE_PUB.create_counter_group
 (
   p_api_version               =>  p_api_version
  ,p_commit                    =>  p_commit
  ,p_init_msg_list             =>  p_init_msg_list
  ,p_validation_level          =>  l_validation_level
  ,p_counter_groups_rec        =>  l_ctr_groups_rec
  ,p_ctr_item_associations_tbl =>  l_ctr_item_associations_tbl
  ,x_return_status             =>  x_return_status
  ,x_msg_count                 =>  x_msg_count
  ,x_msg_data                  =>  x_msg_data
 );

	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO Create_Ctr_Grp_Template_PUB;
	  RETURN;
	END IF;

	-- End of API Body
         -- Customer/Vertical Hookups
        /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Create_Ctr_Grp_Template_Post (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_ctr_grp_rec         => p_ctr_grp_rec,
             x_ctr_grp_id          => x_ctr_grp_id,
             x_object_version_number => x_object_version_number
            );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;
         /* 	Vertical post -processing  section - Mandatory  */
         IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
           CS_COUNTERS_VUHK.Create_Ctr_Grp_Template_Post (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_ctr_grp_rec         => p_ctr_grp_rec,
             x_ctr_grp_id          => x_ctr_grp_id,
             x_object_version_number => x_object_version_number
            );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Ctr_Grp_Template_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Ctr_Grp_Template_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Ctr_Grp_Template_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
END Create_Ctr_Grp_Template;

PROCEDURE Create_Ctr_Grp_Instance
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_grp_rec			IN	CS_COUNTERS_PUB.CtrGrp_Rec_Type,
	p_source_object_cd		IN	VARCHAR2,
	p_source_object_id		IN	NUMBER,
	x_ctr_grp_id			IN OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER
) IS
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'CREATE_CTR_GRP_INSTANCE';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

BEGIN
null;
END Create_Ctr_Grp_Instance;

PROCEDURE Create_Counter
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_rec			IN	CS_COUNTERS_PUB.Ctr_Rec_Type,
	x_ctr_id			IN OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER
) IS
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'CREATE_COUNTER';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_template_flag VARCHAR2(1);
 l_counter_template_rec      CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec;
 l_ctr_item_associations_tbl CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl;
 l_ctr_property_template_tbl CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl;
 l_counter_relationships_tbl CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl;
 l_ctr_derived_filters_tbl   CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl;
 l_validation_level NUMBER;
BEGIN

	SAVEPOINT	Create_Counter_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;


        /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Create_Counter_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_rec               => p_ctr_rec,
             x_ctr_id                => x_ctr_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Create_Counter_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_rec               => p_ctr_rec,
             x_ctr_id                => x_ctr_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Start of API Body
  l_counter_template_rec.COUNTER_ID     :=  x_ctr_id;
  l_counter_template_rec.GROUP_ID       :=  p_ctr_rec.counter_group_id;
  l_counter_template_rec.COUNTER_TYPE     :=  p_ctr_rec.type;
  l_counter_template_rec.INITIAL_READING   :=  p_ctr_rec.initial_reading;
  l_counter_template_rec.TOLERANCE_PLUS   :=  p_ctr_rec.tolerance_plus;
  l_counter_template_rec.TOLERANCE_MINUS  :=  p_ctr_rec.tolerance_minus;
  l_counter_template_rec.UOM_CODE         :=  p_ctr_rec.uom_code;
  l_counter_template_rec.DERIVE_COUNTER_ID   :=  p_ctr_rec.derive_counter_id;
  l_counter_template_rec.DERIVE_FUNCTION     :=  p_ctr_rec.derive_function;
  l_counter_template_rec.DERIVE_PROPERTY_ID  :=  p_ctr_rec.derive_property_id;
  l_counter_template_rec.FORMULA_TEXT      :=  p_ctr_rec.formula_text;
  l_counter_template_rec.ROLLOVER_LAST_READING   :=  p_ctr_rec.rollover_last_reading;
  l_counter_template_rec.ROLLOVER_FIRST_READING  :=  p_ctr_rec.rollover_first_reading;
  l_counter_template_rec.USAGE_ITEM_ID      :=  p_ctr_rec.usage_item_id;
  l_counter_template_rec.START_DATE_ACTIVE    :=  p_ctr_rec.start_date_active;
  l_counter_template_rec.END_DATE_ACTIVE    :=  p_ctr_rec.end_date_active;
  l_counter_template_rec.ATTRIBUTE1    :=  p_ctr_rec.desc_flex.ATTRIBUTE1;
  l_counter_template_rec.ATTRIBUTE2    :=  p_ctr_rec.desc_flex.ATTRIBUTE2;
  l_counter_template_rec.ATTRIBUTE3    :=  p_ctr_rec.desc_flex.ATTRIBUTE3;
  l_counter_template_rec.ATTRIBUTE4    :=  p_ctr_rec.desc_flex.ATTRIBUTE4;
  l_counter_template_rec.ATTRIBUTE5    :=  p_ctr_rec.desc_flex.ATTRIBUTE5;
  l_counter_template_rec.ATTRIBUTE6    :=  p_ctr_rec.desc_flex.ATTRIBUTE6;
  l_counter_template_rec.ATTRIBUTE7    :=  p_ctr_rec.desc_flex.ATTRIBUTE7;
  l_counter_template_rec.ATTRIBUTE8    :=  p_ctr_rec.desc_flex.ATTRIBUTE8;
  l_counter_template_rec.ATTRIBUTE9    :=  p_ctr_rec.desc_flex.ATTRIBUTE9;
  l_counter_template_rec.ATTRIBUTE10   :=  p_ctr_rec.desc_flex.ATTRIBUTE10;
  l_counter_template_rec.ATTRIBUTE11   :=  p_ctr_rec.desc_flex.ATTRIBUTE11;
  l_counter_template_rec.ATTRIBUTE12   :=  p_ctr_rec.desc_flex.ATTRIBUTE12;
  l_counter_template_rec.ATTRIBUTE13   :=  p_ctr_rec.desc_flex.ATTRIBUTE13;
  l_counter_template_rec.ATTRIBUTE14   :=  p_ctr_rec.desc_flex.ATTRIBUTE14;
  l_counter_template_rec.ATTRIBUTE15   :=  p_ctr_rec.desc_flex.ATTRIBUTE15;
  l_counter_template_rec.ATTRIBUTE_CATEGORY  :=  p_ctr_rec.desc_flex.CONTEXT;
  l_counter_template_rec.CUSTOMER_VIEW     :=  p_ctr_rec.customer_view;
  l_counter_template_rec.DIRECTION         :=  p_ctr_rec.direction;
  l_counter_template_rec.FILTER_TYPE       :=  p_ctr_rec.filter_type;
  l_counter_template_rec.FILTER_READING_COUNT   :=  p_ctr_rec.filter_reading_count;
  l_counter_template_rec.FILTER_TIME_UOM   :=  p_ctr_rec.filter_time_uom;
  l_counter_template_rec.ESTIMATION_ID     :=  p_ctr_rec.estimation_id;
  l_counter_template_rec.NAME            :=  p_ctr_rec.name;
  l_counter_template_rec.DESCRIPTION     :=  p_ctr_rec.description;
  l_counter_template_rec.COMMENTS        :=  p_ctr_rec.comments;
  l_counter_template_rec.READING_TYPE    := 1;
  IF p_ctr_rec.rollover_last_reading is not null and p_ctr_rec.rollover_first_reading is not null THEN
    l_counter_template_rec.AUTOMATIC_ROLLOVER := 'Y';
  ELSE
    l_counter_template_rec.AUTOMATIC_ROLLOVER := 'N';
  END IF;

  CSI_COUNTER_TEMPLATE_PUB.create_counter_template
  (
     p_api_version               =>  p_api_version
    ,p_commit                    =>  p_commit
    ,p_init_msg_list             =>  p_init_msg_list
    ,p_validation_level          =>  l_validation_level
    ,p_counter_template_rec      =>  l_counter_template_rec
    ,p_ctr_item_associations_tbl =>  l_ctr_item_associations_tbl
    ,p_ctr_property_template_tbl =>  l_ctr_property_template_tbl
    ,p_counter_relationships_tbl =>  l_counter_relationships_tbl
    ,p_ctr_derived_filters_tbl   =>  l_ctr_derived_filters_tbl
    ,x_return_status             =>  x_return_status
    ,x_msg_count                 =>  x_msg_count
    ,x_msg_data                  =>  x_msg_data
  );

	 IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	   ROLLBACK TO Create_Counter_PUB;
	   RETURN;
	 END IF;
	-- End of API Body
	--
	  -- Customer/Vertical Hookups
        /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Create_Counter_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_rec               => p_ctr_rec,
             x_ctr_id                => x_ctr_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical post -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
           CS_COUNTERS_VUHK.Create_Counter_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_rec               => p_ctr_rec,
             x_ctr_id                => x_ctr_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;


	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Counter_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Counter_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Counter_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
END Create_Counter;

PROCEDURE Create_Ctr_Prop
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_prop_rec			IN	Ctr_Prop_Rec_Type,
	x_ctr_prop_id			IN OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER
) is
	l_api_name     		CONSTANT	VARCHAR2(30)	:= 'CREATE_CTR_PROP';
	l_api_version		CONSTANT	NUMBER		:= 1.0;

 l_ctr_property_template_rec  CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec;
 l_validation_level NUMBER;

BEGIN

	SAVEPOINT	Create_Ctr_Prop_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	  /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Create_Ctr_Prop_Pre (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_ctr_prop_rec        => p_ctr_prop_rec,
             x_ctr_prop_id         => x_ctr_prop_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Create_Ctr_Prop_Pre (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_ctr_prop_rec        => p_ctr_prop_rec,
             x_ctr_prop_id         => x_ctr_prop_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Start of API Body
 l_ctr_property_template_rec.COUNTER_PROPERTY_ID        := x_ctr_prop_id;
 l_ctr_property_template_rec.COUNTER_ID                 := p_ctr_prop_rec.counter_id;
 l_ctr_property_template_rec.PROPERTY_DATA_TYPE         := p_ctr_prop_rec.property_data_type;
 l_ctr_property_template_rec.IS_NULLABLE                := p_ctr_prop_rec.is_nullable;
 l_ctr_property_template_rec.DEFAULT_VALUE              := p_ctr_prop_rec.default_value;
 l_ctr_property_template_rec.MINIMUM_VALUE              := p_ctr_prop_rec.minimum_value;
 l_ctr_property_template_rec.MAXIMUM_VALUE              := p_ctr_prop_rec.maximum_value;
 l_ctr_property_template_rec.UOM_CODE                   := p_ctr_prop_rec.uom_code;
 l_ctr_property_template_rec.START_DATE_ACTIVE          := p_ctr_prop_rec.start_date_active;
 l_ctr_property_template_rec.END_DATE_ACTIVE            := p_ctr_prop_rec.end_date_active;
 l_ctr_property_template_rec.ATTRIBUTE1                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE1;
 l_ctr_property_template_rec.ATTRIBUTE2                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE2;
 l_ctr_property_template_rec.ATTRIBUTE3                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE3;
 l_ctr_property_template_rec.ATTRIBUTE4                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE4;
 l_ctr_property_template_rec.ATTRIBUTE5                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE5;
 l_ctr_property_template_rec.ATTRIBUTE6                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE6;
 l_ctr_property_template_rec.ATTRIBUTE7                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE7;
 l_ctr_property_template_rec.ATTRIBUTE8                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE8;
 l_ctr_property_template_rec.ATTRIBUTE9                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE9;
 l_ctr_property_template_rec.ATTRIBUTE10                := p_ctr_prop_rec.desc_flex.ATTRIBUTE10;
 l_ctr_property_template_rec.ATTRIBUTE11                := p_ctr_prop_rec.desc_flex.ATTRIBUTE11;
 l_ctr_property_template_rec.ATTRIBUTE12                := p_ctr_prop_rec.desc_flex.ATTRIBUTE12;
 l_ctr_property_template_rec.ATTRIBUTE13                := p_ctr_prop_rec.desc_flex.ATTRIBUTE13;
 l_ctr_property_template_rec.ATTRIBUTE14                := p_ctr_prop_rec.desc_flex.ATTRIBUTE14;
 l_ctr_property_template_rec.ATTRIBUTE15                := p_ctr_prop_rec.desc_flex.ATTRIBUTE15;
 l_ctr_property_template_rec.ATTRIBUTE_CATEGORY         := p_ctr_prop_rec.desc_flex.CONTEXT;
 l_ctr_property_template_rec.PROPERTY_LOV_TYPE          := p_ctr_prop_rec.property_lov_type;
 l_ctr_property_template_rec.NAME                       := p_ctr_prop_rec.name;
 l_ctr_property_template_rec.DESCRIPTION                := p_ctr_prop_rec.description;

 CSI_COUNTER_TEMPLATE_PUB.create_ctr_property_template
 (
     p_api_version               =>  p_api_version
    ,p_commit                    =>  p_commit
    ,p_init_msg_list             =>  p_init_msg_list
    ,p_validation_level          =>  l_validation_level
    ,p_ctr_property_template_rec =>  l_ctr_property_template_rec
    ,x_return_status             =>  x_return_status
    ,x_msg_count                 =>  x_msg_count
    ,x_msg_data                  =>  x_msg_data
 );

	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO Create_Ctr_Prop_PUB;
	  RETURN;
	END IF;
	--
	-- End of API Body
	--
	  -- Customer/Vertical Hookups
        /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Create_Ctr_Prop_Post (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_ctr_prop_rec        => p_ctr_prop_rec,
             x_ctr_prop_id         => x_ctr_prop_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        /* 	Vertical post -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
           CS_COUNTERS_VUHK.Create_Ctr_Prop_Post (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_ctr_prop_rec        => p_ctr_prop_rec,
             x_ctr_prop_id         => x_ctr_prop_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;


	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Ctr_Prop_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Ctr_Prop_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Ctr_Prop_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
end Create_Ctr_Prop;

PROCEDURE Create_Formula_Ref
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_counter_id			IN	NUMBER,
	p_bind_var_name			IN	VARCHAR2,
	p_mapped_item_id		IN	NUMBER	:= null,
	p_mapped_counter_id		IN	NUMBER,
	p_desc_flex			IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	x_ctr_formula_bvar_id		IN OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER,
	p_reading_type          	IN      VARCHAR2
) is
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'CREATE_FORMULA_REF';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_counter_relationships_rec  CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec;
 l_validation_level NUMBER;

 cursor ctr_associations IS
 SELECT ctr_association_id, inventory_item_id
 FROM csi_ctr_item_associations
 WHERE counter_id = p_counter_id;
 l_ctr_association_id number;
 l_inventory_item_id number;

 cursor src_ctr_associations(p_inv_item_id number) IS
 SELECT ctr_association_id
 FROM csi_ctr_item_associations
 WHERE counter_id = p_mapped_counter_id
 AND inventory_item_id = p_inv_item_id;
 l_src_ctr_association_id number;

BEGIN

	SAVEPOINT	Create_Formula_Ref_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	     /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Create_Formula_Ref_Pre (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_counter_id          => p_counter_id,
             p_bind_var_name       => p_bind_var_name,
             p_mapped_item_id      => p_mapped_item_id,
             p_mapped_counter_id   => p_mapped_counter_id,
             x_ctr_formula_bvar_id => x_ctr_formula_bvar_id,
             x_object_version_number => x_object_version_number,
             p_reading_type        => p_reading_type
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Create_Formula_Ref_Pre (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_counter_id          => p_counter_id,
             p_bind_var_name       => p_bind_var_name,
             p_mapped_item_id      => p_mapped_item_id,
             p_mapped_counter_id   => p_mapped_counter_id,
             x_ctr_formula_bvar_id => x_ctr_formula_bvar_id,
             x_object_version_number => x_object_version_number,
             p_reading_type        => p_reading_type
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
	-- Start of API Body
 --this is a template, insert one reference for each ctr association id of the formula counter.
  FOR ctr_associations_rec in ctr_associations LOOP
   l_src_ctr_association_id := null;
   l_counter_relationships_rec.RELATIONSHIP_ID         := x_ctr_formula_bvar_id;
   l_counter_relationships_rec.CTR_ASSOCIATION_ID      := ctr_associations_rec.ctr_association_id;
   l_counter_relationships_rec.RELATIONSHIP_TYPE_CODE  := 'FORMULA';
   l_counter_relationships_rec.SOURCE_COUNTER_ID       := p_mapped_counter_id;
   l_counter_relationships_rec.OBJECT_COUNTER_ID       := p_counter_id;
   l_counter_relationships_rec.ATTRIBUTE_CATEGORY      := p_desc_flex.CONTEXT;
   l_counter_relationships_rec.ATTRIBUTE1       := p_desc_flex.ATTRIBUTE1;
   l_counter_relationships_rec.ATTRIBUTE2       := p_desc_flex.ATTRIBUTE2;
   l_counter_relationships_rec.ATTRIBUTE3       := p_desc_flex.ATTRIBUTE3;
   l_counter_relationships_rec.ATTRIBUTE4       := p_desc_flex.ATTRIBUTE4;
   l_counter_relationships_rec.ATTRIBUTE5       := p_desc_flex.ATTRIBUTE5;
   l_counter_relationships_rec.ATTRIBUTE6       := p_desc_flex.ATTRIBUTE6;
   l_counter_relationships_rec.ATTRIBUTE7       := p_desc_flex.ATTRIBUTE7;
   l_counter_relationships_rec.ATTRIBUTE8       := p_desc_flex.ATTRIBUTE8;
   l_counter_relationships_rec.ATTRIBUTE9       := p_desc_flex.ATTRIBUTE9;
   l_counter_relationships_rec.ATTRIBUTE10      := p_desc_flex.ATTRIBUTE10;
   l_counter_relationships_rec.ATTRIBUTE11      := p_desc_flex.ATTRIBUTE11;
   l_counter_relationships_rec.ATTRIBUTE12      := p_desc_flex.ATTRIBUTE12;
   l_counter_relationships_rec.ATTRIBUTE13      := p_desc_flex.ATTRIBUTE13;
   l_counter_relationships_rec.ATTRIBUTE14      := p_desc_flex.ATTRIBUTE14;
   l_counter_relationships_rec.ATTRIBUTE15      := p_desc_flex.ATTRIBUTE15;
   l_counter_relationships_rec.BIND_VARIABLE_NAME       := p_bind_var_name;
   l_counter_relationships_rec.FACTOR    := 1;

   open src_ctr_associations(ctr_associations_rec.inventory_item_id);
   fetch src_ctr_associations into l_src_ctr_association_id;
   close src_ctr_associations;

   If l_src_ctr_association_id is not null then

    CSI_COUNTER_TEMPLATE_PUB.create_counter_relationship
    (
     p_api_version               =>  p_api_version
    ,p_commit                    =>  p_commit
    ,p_init_msg_list             =>  p_init_msg_list
    ,p_validation_level          =>  l_validation_level
    ,p_counter_relationships_rec =>  l_counter_relationships_rec
    ,x_return_status             =>  x_return_status
    ,x_msg_count                 =>  x_msg_count
    ,x_msg_data                  =>  x_msg_data
    );

   	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	    ROLLBACK TO Create_Formula_Ref_PUB;
	    RETURN;
    End if;
	  END IF;
  END LOOP;
	--
	-- End of API Body
	--

    -- Customer/Vertical Hookups
        /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Create_Formula_Ref_Post (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_counter_id          => p_counter_id,
             p_bind_var_name       => p_bind_var_name,
             p_mapped_item_id      => p_mapped_item_id,
             p_mapped_counter_id   => p_mapped_counter_id,
             x_ctr_formula_bvar_id => x_ctr_formula_bvar_id,
             x_object_version_number => x_object_version_number,
             p_reading_type        => p_reading_type
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical post -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
           CS_COUNTERS_VUHK.Create_Formula_Ref_Post (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_counter_id          => p_counter_id,
             p_bind_var_name       => p_bind_var_name,
             p_mapped_item_id      => p_mapped_item_id,
             p_mapped_counter_id   => p_mapped_counter_id,
             x_ctr_formula_bvar_id => x_ctr_formula_bvar_id,
             x_object_version_number => x_object_version_number,
             p_reading_type        => p_reading_type
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;


	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Formula_Ref_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Formula_Ref_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Formula_Ref_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end Create_Formula_Ref;

PROCEDURE Create_GrpOp_Filter
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_seq_no		IN	NUMBER		:= null,
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
) is
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'CREATE_GRPOP_FILTER';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_ctr_derived_filters_tbl CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl;
 l_validation_level NUMBER;

BEGIN

	SAVEPOINT	Create_GrpOp_Filter_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	   /*   Customer / Vertical Hookups
        /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Create_GrpOp_Filter_Pre (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_seq_no              => p_seq_no,
             p_counter_id          => p_counter_id,
             p_left_paren          => p_left_paren,
             p_ctr_prop_id         => p_ctr_prop_id,
             p_rel_op              => p_rel_op,
             p_right_val           => p_right_val,
             p_right_paren         => p_right_paren,
             p_log_op              => p_log_op,
             x_ctr_der_filter_id   => x_ctr_der_filter_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Create_GrpOp_Filter_Pre (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_seq_no              => p_seq_no,
             p_counter_id          => p_counter_id,
             p_left_paren          => p_left_paren,
             p_ctr_prop_id         => p_ctr_prop_id,
             p_rel_op              => p_rel_op,
             p_right_val           => p_right_val,
             p_right_paren         => p_right_paren,
             p_log_op              => p_log_op,
             x_ctr_der_filter_id   => x_ctr_der_filter_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
	-- Start of API Body
 l_ctr_derived_filters_tbl(1).COUNTER_DERIVED_FILTER_ID := x_ctr_der_filter_id;
 l_ctr_derived_filters_tbl(1).COUNTER_ID   :=  p_counter_id;
 l_ctr_derived_filters_tbl(1).SEQ_NO     :=  p_seq_no;
 l_ctr_derived_filters_tbl(1).LEFT_PARENT   :=  p_left_paren;
 l_ctr_derived_filters_tbl(1).COUNTER_PROPERTY_ID   :=  p_ctr_prop_id;
 l_ctr_derived_filters_tbl(1).RELATIONAL_OPERATOR   :=  p_rel_op;
 l_ctr_derived_filters_tbl(1).RIGHT_VALUE         :=  p_right_val;
 l_ctr_derived_filters_tbl(1).RIGHT_PARENT      :=  p_right_paren;
 l_ctr_derived_filters_tbl(1).LOGICAL_OPERATOR   :=  p_log_op;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE1         := p_desc_flex.ATTRIBUTE1;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE2         := p_desc_flex.ATTRIBUTE2;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE3         := p_desc_flex.ATTRIBUTE3;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE4         := p_desc_flex.ATTRIBUTE4;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE5         := p_desc_flex.ATTRIBUTE5;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE6         := p_desc_flex.ATTRIBUTE6;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE7         := p_desc_flex.ATTRIBUTE7;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE8         := p_desc_flex.ATTRIBUTE8;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE9         := p_desc_flex.ATTRIBUTE9;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE10        := p_desc_flex.ATTRIBUTE10;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE11        := p_desc_flex.ATTRIBUTE11;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE12        := p_desc_flex.ATTRIBUTE12;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE13        := p_desc_flex.ATTRIBUTE13;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE14        := p_desc_flex.ATTRIBUTE14;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE15        := p_desc_flex.ATTRIBUTE15;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE_CATEGORY  := p_desc_flex.CONTEXT;

 CSI_COUNTER_TEMPLATE_PUB.create_derived_filters
 (
     p_api_version               =>  p_api_version
    ,p_commit                    =>  p_commit
    ,p_init_msg_list             =>  p_init_msg_list
    ,p_validation_level          =>  l_validation_level
    ,p_ctr_derived_filters_tbl   =>  l_ctr_derived_filters_tbl
    ,x_return_status             =>  x_return_status
    ,x_msg_count                 =>  x_msg_count
    ,x_msg_data                  =>  x_msg_data
 );

	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO Create_GrpOp_Filter_PUB;
	  RETURN;
	END IF;
	--
	-- End of API Body
	--
	--
        -- Customer/Vertical Hookups
        /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Create_GrpOp_Filter_Post (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_seq_no              => p_seq_no,
             p_counter_id          => p_counter_id,
             p_left_paren          => p_left_paren,
             p_ctr_prop_id         => p_ctr_prop_id,
             p_rel_op              => p_rel_op,
             p_right_val           => p_right_val,
             p_right_paren         => p_right_paren,
             p_log_op              => p_log_op,
             x_ctr_der_filter_id   => x_ctr_der_filter_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical post -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
           CS_COUNTERS_VUHK.Create_GrpOp_Filter_Post (
             p_api_version         => l_api_version,
             p_init_msg_list       => p_init_msg_list,
             p_commit              => p_commit,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data,
             p_seq_no              => p_seq_no,
             p_counter_id          => p_counter_id,
             p_left_paren          => p_left_paren,
             p_ctr_prop_id         => p_ctr_prop_id,
             p_rel_op              => p_rel_op,
             p_right_val           => p_right_val,
             p_right_paren         => p_right_paren,
             p_log_op              => p_log_op,
             x_ctr_der_filter_id   => x_ctr_der_filter_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_GrpOp_Filter_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_GrpOp_Filter_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_GrpOp_Filter_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end Create_GrpOp_Filter;

PROCEDURE Create_Ctr_Association
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_grp_id			IN	NUMBER,
	p_source_object_id		IN	NUMBER,
	p_desc_flex			IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	x_ctr_association_id		OUT NOCOPY	NUMBER,
	x_object_version_number		OUT NOCOPY	NUMBER
) is
	l_api_name    	CONSTANT	VARCHAR2(30)	:= 'CREATE_CTR_ASSOCIATION';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_association_type		VARCHAR2(30);
 l_ctr_item_associations_rec CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec;
 l_validation_level NUMBER;
BEGIN
	SAVEPOINT	Create_Ctr_Association_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	   /*    Customer/Vertical Hookups
        /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Create_Ctr_Association_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_source_object_id      => p_source_object_id,
             x_ctr_association_id    => x_ctr_association_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Create_Ctr_Association_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_source_object_id      => p_source_object_id,
             x_ctr_association_id    => x_ctr_association_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- Start of API Body
/*
 BEGIN
		SELECT association_type
		INTO l_association_type
		FROM cs_counter_groups
		WHERE counter_group_id = p_ctr_grp_id;
--		and	  template_flag = 'Y';

	EXCEPTION WHEN NO_DATA_FOUND THEN
		CS_Counters_PVT.ExitWithErrMsg('CS_API_CTR_GRP_INVALID');
	END;
*/
 l_ctr_item_associations_rec.CTR_ASSOCIATION_ID     := x_ctr_association_id;
 l_ctr_item_associations_rec.GROUP_ID               := p_ctr_grp_id;
 l_ctr_item_associations_rec.INVENTORY_ITEM_ID      := p_source_object_id;
 l_ctr_item_associations_rec.ATTRIBUTE1             := p_desc_flex.ATTRIBUTE1;
 l_ctr_item_associations_rec.ATTRIBUTE2             := p_desc_flex.ATTRIBUTE2;
 l_ctr_item_associations_rec.ATTRIBUTE3             := p_desc_flex.ATTRIBUTE3;
 l_ctr_item_associations_rec.ATTRIBUTE4             := p_desc_flex.ATTRIBUTE4;
 l_ctr_item_associations_rec.ATTRIBUTE5             := p_desc_flex.ATTRIBUTE5;
 l_ctr_item_associations_rec.ATTRIBUTE6             := p_desc_flex.ATTRIBUTE6;
 l_ctr_item_associations_rec.ATTRIBUTE7             := p_desc_flex.ATTRIBUTE7;
 l_ctr_item_associations_rec.ATTRIBUTE8             := p_desc_flex.ATTRIBUTE8;
 l_ctr_item_associations_rec.ATTRIBUTE9             := p_desc_flex.ATTRIBUTE9;
 l_ctr_item_associations_rec.ATTRIBUTE10            := p_desc_flex.ATTRIBUTE10;
 l_ctr_item_associations_rec.ATTRIBUTE11            := p_desc_flex.ATTRIBUTE11;
 l_ctr_item_associations_rec.ATTRIBUTE12            := p_desc_flex.ATTRIBUTE12;
 l_ctr_item_associations_rec.ATTRIBUTE13            := p_desc_flex.ATTRIBUTE13;
 l_ctr_item_associations_rec.ATTRIBUTE14            := p_desc_flex.ATTRIBUTE14;
 l_ctr_item_associations_rec.ATTRIBUTE15            := p_desc_flex.ATTRIBUTE15;
 l_ctr_item_associations_rec.ATTRIBUTE_CATEGORY     := p_desc_flex.CONTEXT;
 --convert association type 'PROD_ITEM' TO 'TRACKABLE', AND SERVICE ITEM
/*
 IF l_association_type = 'PROD_ITEM' THEN
   l_ctr_item_associations_rec.ASSOCIATION_TYPE       := 'TRACKABLE';
 ELSIF l_association_type = 'SVC_ITEM' THEN
   l_ctr_item_associations_rec.ASSOCIATION_TYPE       := 'CONTRACT';
 END IF;
*/
 l_ctr_item_associations_rec.ASSOCIATED_TO_GROUP    := 'Y';

 CSI_COUNTER_TEMPLATE_PUB.create_item_association
 (
    p_api_version               =>  p_api_version
   ,p_commit                    =>  p_commit
   ,p_init_msg_list             =>  p_init_msg_list
   ,p_validation_level          =>  l_validation_level
   ,p_ctr_item_associations_rec =>  l_ctr_item_associations_rec
   ,x_return_status             =>  x_return_status
   ,x_msg_count                 =>  x_msg_count
   ,x_msg_data                  =>  x_msg_data
 );

 IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO 	Create_Ctr_Association_PUB;
	  RETURN;
	END IF;

	-- End of API Body
	--
	 -- Customer/Vertical Hookups
        /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Create_Ctr_Association_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_source_object_id      => p_source_object_id,
             x_ctr_association_id    => l_ctr_item_associations_rec.CTR_ASSOCIATION_ID,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical post -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Create_Ctr_Association_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_source_object_id      => p_source_object_id,
             x_ctr_association_id    => l_ctr_item_associations_rec.CTR_ASSOCIATION_ID,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Ctr_Association_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Ctr_Association_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Ctr_Association_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end Create_Ctr_Association;

PROCEDURE AutoInstantiate_Counters
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_source_object_id_template	IN	NUMBER,
	p_source_object_id_instance	IN	NUMBER,
	x_ctr_grp_id_template		IN OUT NOCOPY	NUMBER,
	x_ctr_grp_id_instance		IN OUT NOCOPY	NUMBER,
 p_organization_id               IN      NUMBER      := cs_std.get_item_valdn_orgzn_id
) is
	l_api_name    	CONSTANT	VARCHAR2(30)	:= 'AUTOINSTANTIATE_COUNTERS';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
        l_ctr_template_autoinst_tbl     CSI_COUNTER_TEMPLATE_PUB.ctr_template_autoinst_tbl;
        l_counter_autoinstantiate_tbl   CSI_COUNTER_TEMPLATE_PUB.counter_autoinstantiate_tbl;
        l_msg_index     NUMBER;
        l_msg_count     NUMBER;
BEGIN
	SAVEPOINT	AutoInstantiate_Counters_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

        /*    Customer/Vertical Hookups
        /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.AutoInstantiate_Counters_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_source_object_id_template => p_source_object_id_template,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_grp_id_template   => x_ctr_grp_id_template,
             x_ctr_grp_id_instance   => x_ctr_grp_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.AutoInstantiate_Counters_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_source_object_id_template => p_source_object_id_template,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_grp_id_template   => x_ctr_grp_id_template,
             x_ctr_grp_id_instance   => x_ctr_grp_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- Start of API Body
        CSI_COUNTER_TEMPLATE_PUB.AutoInstantiate_Counters
        (
         p_api_version               => p_api_version
         ,p_commit                    => p_commit
         ,p_init_msg_list             => p_init_msg_list
         ,x_return_status             => x_return_status
         ,x_msg_count                 => x_msg_count
         ,x_msg_data                  => x_msg_data
         ,p_source_object_id_template => p_source_object_id_template
         ,p_source_object_id_instance => p_source_object_id_instance
         ,x_ctr_id_template	      => l_ctr_template_autoinst_tbl
         ,x_ctr_id_instance	      => l_counter_autoinstantiate_tbl
         ,x_ctr_grp_id_template       => x_ctr_grp_id_template
         ,x_ctr_grp_id_instance       => x_ctr_grp_id_instance
         ,p_organization_id           => p_organization_id
        );

        IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	   l_msg_index := 1;
           l_msg_count := x_msg_count;

           WHILE l_msg_count > 0 LOOP
              x_msg_data := FND_MSG_PUB.GET
                             (l_msg_index,
                              FND_API.G_FALSE);
              csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.AutoInstantiate_Counters');
              csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
           END LOOP;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

	-- End of API Body
	--
        -- Customer/Vertical Hookups
        /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.AutoInstantiate_Counters_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_source_object_id_template => p_source_object_id_template,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_grp_id_template   => x_ctr_grp_id_template,
             x_ctr_grp_id_instance   => x_ctr_grp_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical post -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  )  THEN
           CS_COUNTERS_VUHK.AutoInstantiate_Counters_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_source_object_id_template => p_source_object_id_template,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_grp_id_template   => x_ctr_grp_id_template,
             x_ctr_grp_id_instance   => x_ctr_grp_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	-- IF FND_API.To_Boolean( p_commit ) THEN
	IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		ROLLBACK TO AutoInstantiate_Counters_PUB;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO AutoInstantiate_Counters_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO AutoInstantiate_Counters_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end AutoInstantiate_Counters;

PROCEDURE Instantiate_Counters
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2        := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2        := FND_API.G_FALSE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2,
        p_counter_group_id_template     IN      NUMBER,
        p_source_object_code_instance   IN      VARCHAR2,
        p_source_object_id_instance     IN      NUMBER,
        x_ctr_grp_id_template           OUT NOCOPY     NUMBER,
        x_ctr_grp_id_instance           OUT NOCOPY     NUMBER
) is
        l_api_name      CONSTANT        VARCHAR2(30)    := 'INSTANTIATE_COUNTERS';
        l_api_version   CONSTANT        NUMBER          := 1.0;
        l_ctr_grp_id_instance   NUMBER;
        l_ctr_id_template NUMBER;
        l_ctr_id_instance NUMBER;


BEGIN

        SAVEPOINT       Instantiate_Counters_PUB;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version ,
                                                                 p_api_version ,
                                                                 l_api_name ,
                                                                 G_PKG_NAME )   THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        /*   Customer/Vertical Hookups
        /*      Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Instantiate_Counters_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_counter_group_id_template => p_counter_group_id_template,
             p_source_object_code_instance => p_source_object_code_instance,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_grp_id_template   => x_ctr_grp_id_template,
             x_ctr_grp_id_instance   => x_ctr_grp_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /*      Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Instantiate_Counters_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_counter_group_id_template => p_counter_group_id_template,
             p_source_object_code_instance => p_source_object_code_instance,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_grp_id_template   => x_ctr_grp_id_template,
             x_ctr_grp_id_instance   => x_ctr_grp_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- Start of API Body
       CSI_COUNTER_TEMPLATE_PUB.instantiate_grp_counters
        (
          p_api_version,
          p_init_msg_list,
          p_commit,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_counter_group_id_template,
          p_source_object_code_instance,
          p_source_object_id_instance,
          x_ctr_grp_id_instance,
          p_maint_org_id=>NULL,
          p_primary_failure_flag=>NULL
          );
        -- End of API Body
        --
        -- Customer/Vertical Hookups
        /*      Customer post -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Instantiate_Counters_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_counter_group_id_template => p_counter_group_id_template,
             p_source_object_code_instance => p_source_object_code_instance,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_grp_id_template   => x_ctr_grp_id_template,
             x_ctr_grp_id_instance   => l_ctr_grp_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /*      Vertical post -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Instantiate_Counters_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_counter_group_id_template => p_counter_group_id_template,
             p_source_object_code_instance => p_source_object_code_instance,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_grp_id_template   => x_ctr_grp_id_template,
             x_ctr_grp_id_instance   => l_ctr_grp_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
              p_data => x_msg_data
                );

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Instantiate_Counters_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Instantiate_Counters_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
                 p_data => x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO Instantiate_Counters_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
                END IF;
                FND_MSG_PUB.Count_And_Get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

end Instantiate_Counters;

PROCEDURE Update_Ctr_Grp
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_grp_id			IN	NUMBER,
	p_object_version_number		IN	NUMBER,
	p_ctr_grp_rec			IN	CS_COUNTERS_PUB.CtrGrp_Rec_Type,
	p_cascade_upd_to_instances	IN	VARCHAR2 := FND_API.G_FALSE,
	x_object_version_number		OUT NOCOPY	NUMBER
) is
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'UPDATE_CTR_GRP';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_ctr_groups_rec   CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec;
 l_ctr_item_associations_tbl  CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl;
 l_validation_level NUMBER;

BEGIN

	SAVEPOINT	Update_Ctr_Grp_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	 /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Update_Ctr_Grp_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_object_version_number => p_object_version_number,
             p_ctr_grp_rec           => p_ctr_grp_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Update_Ctr_Grp_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_object_version_number => p_object_version_number,
             p_ctr_grp_rec           => p_ctr_grp_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
	-- Start of API Body
 l_ctr_groups_rec.COUNTER_GROUP_ID := p_ctr_grp_id;
 l_ctr_groups_rec.NAME             := p_ctr_grp_rec.NAME;
 l_ctr_groups_rec.DESCRIPTION      := p_ctr_grp_rec.DESCRIPTION;
 l_ctr_groups_rec.START_DATE_ACTIVE   := p_ctr_grp_rec.start_date_active;
 l_ctr_groups_rec.END_DATE_ACTIVE     := p_ctr_grp_rec.end_date_active;
 l_ctr_groups_rec.ATTRIBUTE1      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE1;
 l_ctr_groups_rec.ATTRIBUTE2      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE2;
 l_ctr_groups_rec.ATTRIBUTE3      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE3;
 l_ctr_groups_rec.ATTRIBUTE4      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE4;
 l_ctr_groups_rec.ATTRIBUTE5      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE5;
 l_ctr_groups_rec.ATTRIBUTE6      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE6;
 l_ctr_groups_rec.ATTRIBUTE7      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE7;
 l_ctr_groups_rec.ATTRIBUTE8      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE8;
 l_ctr_groups_rec.ATTRIBUTE9      := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE9;
 l_ctr_groups_rec.ATTRIBUTE10     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE10;
 l_ctr_groups_rec.ATTRIBUTE11     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE11;
 l_ctr_groups_rec.ATTRIBUTE12     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE12;
 l_ctr_groups_rec.ATTRIBUTE13     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE13;
 l_ctr_groups_rec.ATTRIBUTE14     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE14;
 l_ctr_groups_rec.ATTRIBUTE15     := p_ctr_grp_rec.DESC_FLEX.ATTRIBUTE15;
 l_ctr_groups_rec.CONTEXT         := p_ctr_grp_rec.DESC_FLEX.CONTEXT;
 l_ctr_groups_rec.ASSOCIATION_TYPE     :=  p_ctr_grp_rec.ASSOCIATION_TYPE;
 l_ctr_groups_rec.OBJECT_VERSION_NUMBER :=  p_object_version_number;

 CSI_COUNTER_TEMPLATE_PUB.update_counter_group
  (
     p_api_version               =>  p_api_version
    ,p_commit                    =>  p_commit
    ,p_init_msg_list             =>  p_init_msg_list
    ,p_validation_level          =>  l_validation_level
    ,p_counter_groups_rec        =>  l_ctr_groups_rec
    ,p_ctr_item_associations_tbl =>  l_ctr_item_associations_tbl
    ,x_return_status             =>  x_return_status
    ,x_msg_count                 =>  x_msg_count
    ,x_msg_data                  =>  x_msg_data
 );

	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO Update_Ctr_Grp_PUB;
	  RETURN;
	END IF;

	-- End of API Body
	--
	  -- Customer/Vertical Hookups
        /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Update_Ctr_Grp_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_object_version_number => p_object_version_number,
             p_ctr_grp_rec           => p_ctr_grp_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical post -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Update_Ctr_Grp_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_object_version_number => p_object_version_number,
             p_ctr_grp_rec           => p_ctr_grp_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;


	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_Ctr_Grp_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Ctr_Grp_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Ctr_Grp_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end Update_Ctr_Grp;

PROCEDURE Update_Counter
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_id			IN	NUMBER,
	p_object_version_number		IN	NUMBER,
	p_ctr_rec			IN	CS_COUNTERS_PUB.Ctr_Rec_Type,
	p_cascade_upd_to_instances	IN	VARCHAR2 := FND_API.G_FALSE,
	x_object_version_number		OUT NOCOPY	NUMBER
) is
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'UPDATE_COUNTER';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_counter_template_rec      CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec;
 l_ctr_item_associations_tbl CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl;
 l_ctr_property_template_tbl CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl;
 l_counter_relationships_tbl CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl;
 l_ctr_derived_filters_tbl   CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl;
 l_validation_level NUMBER;

BEGIN

	SAVEPOINT	Update_Counter_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	    /*   Customer/Vertical Hookups
        /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Update_Counter_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_id                => p_ctr_id,
             p_object_version_number => p_object_version_number,
             p_ctr_rec               => p_ctr_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Update_Counter_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_id                => p_ctr_id,
             p_object_version_number => p_object_version_number,
             p_ctr_rec               => p_ctr_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
	-- Start of API Body

 l_counter_template_rec.COUNTER_ID     :=  p_ctr_id;
 l_counter_template_rec.GROUP_ID       :=  p_ctr_rec.counter_group_id;
 l_counter_template_rec.COUNTER_TYPE     :=  p_ctr_rec.type;
 l_counter_template_rec.INITIAL_READING   :=  p_ctr_rec.initial_reading;
 l_counter_template_rec.TOLERANCE_PLUS   :=  p_ctr_rec.tolerance_plus;
 l_counter_template_rec.TOLERANCE_MINUS  :=  p_ctr_rec.tolerance_minus;
 l_counter_template_rec.UOM_CODE         :=  p_ctr_rec.uom_code;
 l_counter_template_rec.DERIVE_COUNTER_ID   :=  p_ctr_rec.derive_counter_id;
 l_counter_template_rec.DERIVE_FUNCTION     :=  p_ctr_rec.derive_function;
 l_counter_template_rec.DERIVE_PROPERTY_ID  :=  p_ctr_rec.derive_property_id;
 l_counter_template_rec.FORMULA_TEXT      :=  p_ctr_rec.formula_text;
 l_counter_template_rec.ROLLOVER_LAST_READING   :=  p_ctr_rec.rollover_last_reading;
 l_counter_template_rec.ROLLOVER_FIRST_READING  :=  p_ctr_rec.rollover_first_reading;
 l_counter_template_rec.USAGE_ITEM_ID      :=  p_ctr_rec.usage_item_id;
 l_counter_template_rec.START_DATE_ACTIVE    :=  p_ctr_rec.start_date_active;
 l_counter_template_rec.END_DATE_ACTIVE    :=  p_ctr_rec.end_date_active;
 l_counter_template_rec.ATTRIBUTE1    :=  p_ctr_rec.desc_flex.ATTRIBUTE1;
 l_counter_template_rec.ATTRIBUTE2    :=  p_ctr_rec.desc_flex.ATTRIBUTE2;
 l_counter_template_rec.ATTRIBUTE3    :=  p_ctr_rec.desc_flex.ATTRIBUTE3;
 l_counter_template_rec.ATTRIBUTE4    :=  p_ctr_rec.desc_flex.ATTRIBUTE4;
 l_counter_template_rec.ATTRIBUTE5    :=  p_ctr_rec.desc_flex.ATTRIBUTE5;
 l_counter_template_rec.ATTRIBUTE6    :=  p_ctr_rec.desc_flex.ATTRIBUTE6;
 l_counter_template_rec.ATTRIBUTE7    :=  p_ctr_rec.desc_flex.ATTRIBUTE7;
 l_counter_template_rec.ATTRIBUTE8    :=  p_ctr_rec.desc_flex.ATTRIBUTE8;
 l_counter_template_rec.ATTRIBUTE9    :=  p_ctr_rec.desc_flex.ATTRIBUTE9;
 l_counter_template_rec.ATTRIBUTE10   :=  p_ctr_rec.desc_flex.ATTRIBUTE10;
 l_counter_template_rec.ATTRIBUTE11   :=  p_ctr_rec.desc_flex.ATTRIBUTE11;
 l_counter_template_rec.ATTRIBUTE12   :=  p_ctr_rec.desc_flex.ATTRIBUTE12;
 l_counter_template_rec.ATTRIBUTE13   :=  p_ctr_rec.desc_flex.ATTRIBUTE13;
 l_counter_template_rec.ATTRIBUTE14   :=  p_ctr_rec.desc_flex.ATTRIBUTE14;
 l_counter_template_rec.ATTRIBUTE15   :=  p_ctr_rec.desc_flex.ATTRIBUTE15;
 l_counter_template_rec.ATTRIBUTE_CATEGORY  :=  p_ctr_rec.desc_flex.CONTEXT;
 l_counter_template_rec.CUSTOMER_VIEW     :=  p_ctr_rec.customer_view;
 l_counter_template_rec.DIRECTION         :=  p_ctr_rec.direction;
 l_counter_template_rec.FILTER_TYPE       :=  p_ctr_rec.filter_type;
 l_counter_template_rec.FILTER_READING_COUNT   :=  p_ctr_rec.filter_reading_count;
 l_counter_template_rec.FILTER_TIME_UOM   :=  p_ctr_rec.filter_time_uom;
 l_counter_template_rec.ESTIMATION_ID     :=  p_ctr_rec.estimation_id;
 l_counter_template_rec.NAME            :=  p_ctr_rec.name;
 l_counter_template_rec.DESCRIPTION     :=  p_ctr_rec.description;
 l_counter_template_rec.COMMENTS        :=  p_ctr_rec.comments;
 l_counter_template_rec.OBJECT_VERSION_NUMBER :=  p_object_version_number;

 CSI_COUNTER_TEMPLATE_PUB.update_counter_template
 (
    p_api_version               =>  p_api_version
   ,p_commit                    =>  p_commit
   ,p_init_msg_list             =>  p_init_msg_list
   ,p_validation_level          =>  l_validation_level
   ,p_counter_template_rec      =>  l_counter_template_rec
   ,p_ctr_item_associations_tbl =>  l_ctr_item_associations_tbl
   ,p_ctr_property_template_tbl =>  l_ctr_property_template_tbl
   ,p_counter_relationships_tbl =>  l_counter_relationships_tbl
   ,p_ctr_derived_filters_tbl   =>  l_ctr_derived_filters_tbl
   ,x_return_status             =>  x_return_status
   ,x_msg_count                 =>  x_msg_count
   ,x_msg_data                  =>  x_msg_data
 );

	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO Update_Counter_PUB;
	  RETURN;
	END IF;

	-- End of API Body
	--
	--
        -- Customer/Vertical Hookups
        /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Update_Counter_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_id                => p_ctr_id,
             p_object_version_number => p_object_version_number,
             p_ctr_rec               => p_ctr_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /*      Vertical post -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
            CS_COUNTERS_VUHK.Update_Counter_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_id                => p_ctr_id,
             p_object_version_number => p_object_version_number,
             p_ctr_rec               => p_ctr_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_Counter_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Counter_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Counter_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end Update_Counter;

PROCEDURE Update_Ctr_Prop
(
	p_api_version		IN	NUMBER,
	p_init_msg_list	        IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status	        OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_ctr_prop_id		IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_ctr_prop_rec		IN	Ctr_Prop_Rec_Type,
	p_cascade_upd_to_instances	IN	VARCHAR2 := FND_API.G_FALSE,
	x_object_version_number	OUT NOCOPY	NUMBER
) is
	l_api_name     CONSTANT	VARCHAR2(30)	:= 'UPDATE_CTR_PROP';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_ctr_property_template_rec  CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec;
 l_validation_level NUMBER;

BEGIN

	SAVEPOINT	Update_Ctr_Prop_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;


        /*   Customer/Vertical Hookups
        /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Update_Ctr_Prop_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_prop_id           => p_ctr_prop_id,
             p_object_version_number => p_object_version_number,
             p_ctr_prop_rec          => p_ctr_prop_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Update_Ctr_Prop_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_prop_id           => p_ctr_prop_id,
             p_object_version_number => p_object_version_number,
             p_ctr_prop_rec          => p_ctr_prop_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
	-- Start of API Body
 l_ctr_property_template_rec.COUNTER_PROPERTY_ID        := p_ctr_prop_id;
 l_ctr_property_template_rec.COUNTER_ID                 := p_ctr_prop_rec.counter_id;
 l_ctr_property_template_rec.PROPERTY_DATA_TYPE         := p_ctr_prop_rec.property_data_type;
 l_ctr_property_template_rec.IS_NULLABLE                := p_ctr_prop_rec.is_nullable;
 l_ctr_property_template_rec.DEFAULT_VALUE              := p_ctr_prop_rec.default_value;
 l_ctr_property_template_rec.MINIMUM_VALUE              := p_ctr_prop_rec.minimum_value;
 l_ctr_property_template_rec.MAXIMUM_VALUE              := p_ctr_prop_rec.maximum_value;
 l_ctr_property_template_rec.UOM_CODE                   := p_ctr_prop_rec.uom_code;
 l_ctr_property_template_rec.START_DATE_ACTIVE          := p_ctr_prop_rec.start_date_active;
 l_ctr_property_template_rec.END_DATE_ACTIVE            := p_ctr_prop_rec.end_date_active;
 l_ctr_property_template_rec.ATTRIBUTE1                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE1;
 l_ctr_property_template_rec.ATTRIBUTE2                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE2;
 l_ctr_property_template_rec.ATTRIBUTE3                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE3;
 l_ctr_property_template_rec.ATTRIBUTE4                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE4;
 l_ctr_property_template_rec.ATTRIBUTE5                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE5;
 l_ctr_property_template_rec.ATTRIBUTE6                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE6;
 l_ctr_property_template_rec.ATTRIBUTE7                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE7;
 l_ctr_property_template_rec.ATTRIBUTE8                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE8;
 l_ctr_property_template_rec.ATTRIBUTE9                 := p_ctr_prop_rec.desc_flex.ATTRIBUTE9;
 l_ctr_property_template_rec.ATTRIBUTE10                := p_ctr_prop_rec.desc_flex.ATTRIBUTE10;
 l_ctr_property_template_rec.ATTRIBUTE11                := p_ctr_prop_rec.desc_flex.ATTRIBUTE11;
 l_ctr_property_template_rec.ATTRIBUTE12                := p_ctr_prop_rec.desc_flex.ATTRIBUTE12;
 l_ctr_property_template_rec.ATTRIBUTE13                := p_ctr_prop_rec.desc_flex.ATTRIBUTE13;
 l_ctr_property_template_rec.ATTRIBUTE14                := p_ctr_prop_rec.desc_flex.ATTRIBUTE14;
 l_ctr_property_template_rec.ATTRIBUTE15                := p_ctr_prop_rec.desc_flex.ATTRIBUTE15;
 l_ctr_property_template_rec.ATTRIBUTE_CATEGORY         := p_ctr_prop_rec.desc_flex.CONTEXT;
 l_ctr_property_template_rec.PROPERTY_LOV_TYPE          := p_ctr_prop_rec.property_lov_type;
 l_ctr_property_template_rec.NAME                       := p_ctr_prop_rec.name;
 l_ctr_property_template_rec.DESCRIPTION                := p_ctr_prop_rec.description;
 l_ctr_property_template_rec.OBJECT_VERSION_NUMBER      :=  p_object_version_number;

 CSI_COUNTER_TEMPLATE_PUB.update_ctr_property_template
 (
    p_api_version               =>  p_api_version
   ,p_commit                    =>  p_commit
   ,p_init_msg_list             =>  p_init_msg_list
   ,p_validation_level          =>  l_validation_level
   ,p_ctr_property_template_rec =>  l_ctr_property_template_rec
   ,x_return_status             =>  x_return_status
   ,x_msg_count                 =>  x_msg_count
   ,x_msg_data                  =>  x_msg_data
 );

	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO Update_Ctr_Prop_PUB;
	  RETURN;
	END IF;

	-- End of API Body
	--
	   /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Update_Ctr_Prop_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_prop_id           => p_ctr_prop_id,
             p_object_version_number => p_object_version_number,
             p_ctr_prop_rec          => p_ctr_prop_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /*      Vertical post -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
            CS_COUNTERS_VUHK.Update_Ctr_Prop_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_prop_id           => p_ctr_prop_id,
             p_object_version_number => p_object_version_number,
             p_ctr_prop_rec          => p_ctr_prop_rec,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_Ctr_Prop_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Ctr_Prop_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Ctr_Prop_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end Update_Ctr_Prop;

PROCEDURE Update_Formula_Ref
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_formula_bvar_id		IN	NUMBER,
	p_object_version_number		IN	NUMBER,
	p_counter_id			IN	NUMBER,
	p_bind_var_name			IN	VARCHAR2,
	p_mapped_item_id		IN	NUMBER	:= null,
	p_mapped_counter_id		IN	NUMBER,
	p_desc_flex			IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	p_cascade_upd_to_instances	IN	VARCHAR2 := FND_API.G_FALSE,
	x_object_version_number		OUT NOCOPY	NUMBER,
	p_reading_type                  IN   VARCHAR2
) is
	l_api_name     CONSTANT	VARCHAR2(30)	:= 'UPDATE_FORMULA_REF';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_counter_relationships_rec  CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec;
 l_validation_level NUMBER;

BEGIN

	SAVEPOINT	Update_Formula_Ref_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	     /*   Customer/Vertical Hookups
        /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Update_Formula_Ref_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_formula_bvar_id   => p_ctr_formula_bvar_id,
             p_object_version_number => p_object_version_number,
             p_counter_id            => p_counter_id,
             p_bind_var_name         => p_bind_var_name,
             p_mapped_item_id        => p_mapped_item_id,
             p_mapped_counter_id     => p_mapped_counter_id,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number,
             p_reading_type          => p_reading_type
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Update_Formula_Ref_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_formula_bvar_id   => p_ctr_formula_bvar_id,
             p_object_version_number => p_object_version_number,
             p_counter_id            => p_counter_id,
             p_bind_var_name         => p_bind_var_name,
             p_mapped_item_id        => p_mapped_item_id,
             p_mapped_counter_id     => p_mapped_counter_id,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number,
             p_reading_type          => p_reading_type
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
	-- Start of API Body
   l_counter_relationships_rec.RELATIONSHIP_ID         := p_ctr_formula_bvar_id;
   --l_counter_relationships_rec.CTR_ASSOCIATION_ID      := ctr_associations_rec.ctr_association_id;
   --l_counter_relationships_rec.RELATIONSHIP_TYPE_CODE  := 'FORMULA';
   l_counter_relationships_rec.SOURCE_COUNTER_ID       := p_mapped_counter_id;
   l_counter_relationships_rec.OBJECT_COUNTER_ID       := p_counter_id;
   l_counter_relationships_rec.ATTRIBUTE_CATEGORY      := p_desc_flex.CONTEXT;
   l_counter_relationships_rec.ATTRIBUTE1       := p_desc_flex.ATTRIBUTE1;
   l_counter_relationships_rec.ATTRIBUTE2       := p_desc_flex.ATTRIBUTE2;
   l_counter_relationships_rec.ATTRIBUTE3       := p_desc_flex.ATTRIBUTE3;
   l_counter_relationships_rec.ATTRIBUTE4       := p_desc_flex.ATTRIBUTE4;
   l_counter_relationships_rec.ATTRIBUTE5       := p_desc_flex.ATTRIBUTE5;
   l_counter_relationships_rec.ATTRIBUTE6       := p_desc_flex.ATTRIBUTE6;
   l_counter_relationships_rec.ATTRIBUTE7       := p_desc_flex.ATTRIBUTE7;
   l_counter_relationships_rec.ATTRIBUTE8       := p_desc_flex.ATTRIBUTE8;
   l_counter_relationships_rec.ATTRIBUTE9       := p_desc_flex.ATTRIBUTE9;
   l_counter_relationships_rec.ATTRIBUTE10      := p_desc_flex.ATTRIBUTE10;
   l_counter_relationships_rec.ATTRIBUTE11      := p_desc_flex.ATTRIBUTE11;
   l_counter_relationships_rec.ATTRIBUTE12      := p_desc_flex.ATTRIBUTE12;
   l_counter_relationships_rec.ATTRIBUTE13      := p_desc_flex.ATTRIBUTE13;
   l_counter_relationships_rec.ATTRIBUTE14      := p_desc_flex.ATTRIBUTE14;
   l_counter_relationships_rec.ATTRIBUTE15      := p_desc_flex.ATTRIBUTE15;
   l_counter_relationships_rec.BIND_VARIABLE_NAME       := p_bind_var_name;
   l_counter_relationships_rec.OBJECT_VERSION_NUMBER  := p_object_version_number;

    CSI_COUNTER_TEMPLATE_PUB.create_counter_relationship
    (
     p_api_version               =>  p_api_version
    ,p_commit                    =>  p_commit
    ,p_init_msg_list             =>  p_init_msg_list
    ,p_validation_level          =>  l_validation_level
    ,p_counter_relationships_rec =>  l_counter_relationships_rec
    ,x_return_status             =>  x_return_status
    ,x_msg_count                 =>  x_msg_count
    ,x_msg_data                  =>  x_msg_data
    );

   	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	    ROLLBACK TO Create_Formula_Ref_PUB;
	    RETURN;
    End if;

	-- End of API Body
	--
	--
        /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Update_Formula_Ref_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_formula_bvar_id   => p_ctr_formula_bvar_id,
             p_object_version_number => p_object_version_number,
             p_counter_id            => p_counter_id,
             p_bind_var_name         => p_bind_var_name,
             p_mapped_item_id        => p_mapped_item_id,
             p_mapped_counter_id     => p_mapped_counter_id,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number,
             p_reading_type          => p_reading_type
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /*      Vertical post -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
            CS_COUNTERS_VUHK.Update_Formula_Ref_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_formula_bvar_id   => p_ctr_formula_bvar_id,
             p_object_version_number => p_object_version_number,
             p_counter_id            => p_counter_id,
             p_bind_var_name         => p_bind_var_name,
             p_mapped_item_id        => p_mapped_item_id,
             p_mapped_counter_id     => p_mapped_counter_id,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number,
             p_reading_type          => p_reading_type
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_Formula_Ref_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Formula_Ref_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Formula_Ref_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end Update_Formula_Ref;


PROCEDURE Update_GrpOp_Filter
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_ctr_der_filter_id	IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_seq_no		IN	NUMBER		:= null,
	p_counter_id		IN	NUMBER,
	p_left_paren		IN	VARCHAR2,
	p_ctr_prop_id		IN	NUMBER,
	p_rel_op		IN	VARCHAR2,
	p_right_val		IN	VARCHAR2,
	p_right_paren		IN	VARCHAR2,
	p_log_op		IN	VARCHAR2,
	p_desc_flex		IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	p_cascade_upd_to_instances	IN	VARCHAR2 := FND_API.G_FALSE,
	x_object_version_number	OUT NOCOPY	NUMBER
) is
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'UPDATE_GRPOP_FILTER';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_ctr_derived_filters_tbl CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl;
 l_validation_level NUMBER;

BEGIN

	SAVEPOINT	Update_GrpOp_Filter_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	   /*   Customer/Vertical Hookups
        /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Update_GrpOp_Filter_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_der_filter_id     => p_ctr_der_filter_id,
             p_object_version_number => p_object_version_number,
             p_seq_no                => p_seq_no,
             p_counter_id            => p_counter_id,
             p_left_paren            => p_left_paren,
             p_ctr_prop_id           => p_ctr_prop_id,
             p_rel_op                => p_rel_op,
             p_right_val             => p_right_val,
             p_right_paren           => p_right_paren,
             p_log_op                => p_log_op,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Update_GrpOp_Filter_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_der_filter_id     => p_ctr_der_filter_id,
             p_object_version_number => p_object_version_number,
             p_seq_no                => p_seq_no,
             p_counter_id            => p_counter_id,
             p_left_paren            => p_left_paren,
             p_ctr_prop_id           => p_ctr_prop_id,
             p_rel_op                => p_rel_op,
             p_right_val             => p_right_val,
             p_right_paren           => p_right_paren,
             p_log_op                => p_log_op,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
	-- Start of API Body

 l_ctr_derived_filters_tbl(1).COUNTER_DERIVED_FILTER_ID := p_ctr_der_filter_id;
 l_ctr_derived_filters_tbl(1).COUNTER_ID   :=  p_counter_id;
 l_ctr_derived_filters_tbl(1).SEQ_NO     :=  p_seq_no;
 l_ctr_derived_filters_tbl(1).LEFT_PARENT   :=  p_left_paren;
 l_ctr_derived_filters_tbl(1).COUNTER_PROPERTY_ID   :=  p_ctr_prop_id;
 l_ctr_derived_filters_tbl(1).RELATIONAL_OPERATOR   :=  p_rel_op;
 l_ctr_derived_filters_tbl(1).RIGHT_VALUE         :=  p_right_val;
 l_ctr_derived_filters_tbl(1).RIGHT_PARENT      :=  p_right_paren;
 l_ctr_derived_filters_tbl(1).LOGICAL_OPERATOR   :=  p_log_op;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE1         := p_desc_flex.ATTRIBUTE1;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE2         := p_desc_flex.ATTRIBUTE2;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE3         := p_desc_flex.ATTRIBUTE3;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE4         := p_desc_flex.ATTRIBUTE4;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE5         := p_desc_flex.ATTRIBUTE5;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE6         := p_desc_flex.ATTRIBUTE6;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE7         := p_desc_flex.ATTRIBUTE7;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE8         := p_desc_flex.ATTRIBUTE8;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE9         := p_desc_flex.ATTRIBUTE9;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE10        := p_desc_flex.ATTRIBUTE10;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE11        := p_desc_flex.ATTRIBUTE11;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE12        := p_desc_flex.ATTRIBUTE12;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE13        := p_desc_flex.ATTRIBUTE13;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE14        := p_desc_flex.ATTRIBUTE14;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE15        := p_desc_flex.ATTRIBUTE15;
 l_ctr_derived_filters_tbl(1).ATTRIBUTE_CATEGORY  := p_desc_flex.CONTEXT;
 l_ctr_derived_filters_tbl(1).OBJECT_VERSION_NUMBER := p_object_version_number;

 CSI_COUNTER_TEMPLATE_PUB.update_derived_filters
 (
    p_api_version               =>  p_api_version
   ,p_commit                    =>  p_commit
   ,p_init_msg_list             =>  p_init_msg_list
   ,p_validation_level          =>  l_validation_level
   ,p_ctr_derived_filters_tbl   =>  l_ctr_derived_filters_tbl
   ,x_return_status             =>  x_return_status
   ,x_msg_count                 =>  x_msg_count
   ,x_msg_data                  =>  x_msg_data
 );

	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO Update_GrpOp_Filter_PUB;
	  RETURN;
	END IF;

	-- End of API Body
	--
	    /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Update_GrpOp_Filter_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_der_filter_id     => p_ctr_der_filter_id,
             p_object_version_number => p_object_version_number,
             p_seq_no                => p_seq_no,
             p_counter_id            => p_counter_id,
             p_left_paren            => p_left_paren,
             p_ctr_prop_id           => p_ctr_prop_id,
             p_rel_op                => p_rel_op,
             p_right_val             => p_right_val,
             p_right_paren           => p_right_paren,
             p_log_op                => p_log_op,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /*      Vertical post -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
            CS_COUNTERS_VUHK.Update_GrpOp_Filter_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_der_filter_id     => p_ctr_der_filter_id,
             p_object_version_number => p_object_version_number,
             p_seq_no                => p_seq_no,
             p_counter_id            => p_counter_id,
             p_left_paren            => p_left_paren,
             p_ctr_prop_id           => p_ctr_prop_id,
             p_rel_op                => p_rel_op,
             p_right_val             => p_right_val,
             p_right_paren           => p_right_paren,
             p_log_op                => p_log_op,
             p_cascade_upd_to_instances => p_cascade_upd_to_instances,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;


	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_GrpOp_Filter_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_GrpOp_Filter_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_GrpOp_Filter_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end Update_GrpOp_Filter;

PROCEDURE Update_Ctr_Association
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_association_id		IN	NUMBER,
	p_object_version_number		IN	NUMBER,
	p_ctr_grp_id			IN	NUMBER,
	p_source_object_id		IN	NUMBER,
	p_desc_flex			IN	CS_COUNTERS_EXT_PVT.DFF_Rec_Type,
	x_object_version_number		OUT NOCOPY	NUMBER
) is
	l_api_name      CONSTANT	VARCHAR2(30)	:= 'UPDATE_CTR_ASSOCIATION';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_ctr_item_associations_rec CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec;
 l_validation_level NUMBER;

BEGIN

	SAVEPOINT	Update_Ctr_Association_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	     /*   Customer/Vertical Hookups
        /*  	Customer pre -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
           CS_COUNTERS_CUHK.Update_Ctr_Association_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_association_id    => p_ctr_association_id,
             p_object_version_number => p_object_version_number,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_source_object_id      => p_source_object_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /* 	Vertical pre -processing  section - Mandatory */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Update_Ctr_Association_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_association_id    => p_ctr_association_id,
             p_object_version_number => p_object_version_number,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_source_object_id      => p_source_object_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
	-- Start of API Body
 l_ctr_item_associations_rec.CTR_ASSOCIATION_ID     := p_ctr_association_id;
 l_ctr_item_associations_rec.GROUP_ID               := p_ctr_grp_id;
 l_ctr_item_associations_rec.INVENTORY_ITEM_ID      := p_source_object_id;
 l_ctr_item_associations_rec.ATTRIBUTE1             := p_desc_flex.ATTRIBUTE1;
 l_ctr_item_associations_rec.ATTRIBUTE2             := p_desc_flex.ATTRIBUTE2;
 l_ctr_item_associations_rec.ATTRIBUTE3             := p_desc_flex.ATTRIBUTE3;
 l_ctr_item_associations_rec.ATTRIBUTE4             := p_desc_flex.ATTRIBUTE4;
 l_ctr_item_associations_rec.ATTRIBUTE5             := p_desc_flex.ATTRIBUTE5;
 l_ctr_item_associations_rec.ATTRIBUTE6             := p_desc_flex.ATTRIBUTE6;
 l_ctr_item_associations_rec.ATTRIBUTE7             := p_desc_flex.ATTRIBUTE7;
 l_ctr_item_associations_rec.ATTRIBUTE8             := p_desc_flex.ATTRIBUTE8;
 l_ctr_item_associations_rec.ATTRIBUTE9             := p_desc_flex.ATTRIBUTE9;
 l_ctr_item_associations_rec.ATTRIBUTE10            := p_desc_flex.ATTRIBUTE10;
 l_ctr_item_associations_rec.ATTRIBUTE11            := p_desc_flex.ATTRIBUTE11;
 l_ctr_item_associations_rec.ATTRIBUTE12            := p_desc_flex.ATTRIBUTE12;
 l_ctr_item_associations_rec.ATTRIBUTE13            := p_desc_flex.ATTRIBUTE13;
 l_ctr_item_associations_rec.ATTRIBUTE14            := p_desc_flex.ATTRIBUTE14;
 l_ctr_item_associations_rec.ATTRIBUTE15            := p_desc_flex.ATTRIBUTE15;
 l_ctr_item_associations_rec.ATTRIBUTE_CATEGORY     := p_desc_flex.CONTEXT;
 --l_ctr_item_associations_rec.ASSOCIATION_TYPE       := l_association_type;
 --l_ctr_item_associations_rec.ASSOCIATED_TO_GROUP    := 'Y';
 l_ctr_item_associations_rec.OBJECT_VERSION_NUMBER:=  p_object_version_number;

 CSI_COUNTER_TEMPLATE_PUB.update_item_association
 (
    p_api_version               =>  p_api_version
   ,p_commit                    =>  p_commit
   ,p_init_msg_list             =>  p_init_msg_list
   ,p_validation_level          =>  l_validation_level
   ,p_ctr_item_associations_rec =>  l_ctr_item_associations_rec
   ,x_return_status             =>  x_return_status
   ,x_msg_count                 =>  x_msg_count
   ,x_msg_data                  =>  x_msg_data
 );


	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO Update_Ctr_Association_PUB;
	  RETURN;
	END IF;

	-- End of API Body
	--
	   /*  	Customer post -processing  section - Mandatory 	*/
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Update_Ctr_Association_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_association_id    => p_ctr_association_id,
             p_object_version_number => p_object_version_number,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_source_object_id      => p_source_object_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /*      Vertical post -processing  section - Mandatory  */
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
            CS_COUNTERS_VUHK.Update_Ctr_Association_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_ctr_association_id    => p_ctr_association_id,
             p_object_version_number => p_object_version_number,
             p_ctr_grp_id            => p_ctr_grp_id,
             p_source_object_id      => p_source_object_id,
             x_object_version_number => x_object_version_number
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_Ctr_Association_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Ctr_Association_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Ctr_Association_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end Update_Ctr_Association;

PROCEDURE Delete_Counter
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_id			IN	NUMBER
) is
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'DELETE_COUNTER';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

BEGIN
null;
end Delete_Counter;

PROCEDURE Delete_Ctr_Prop
(
	p_api_version		IN	NUMBER,
	p_init_msg_list	        IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit	        IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status	        OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_ctr_prop_id		IN	NUMBER
) is
	l_api_name     CONSTANT	VARCHAR2(30)	:= 'DELETE_CTR_PROP';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

BEGIN
null;
end Delete_Ctr_Prop;


PROCEDURE Delete_Formula_Ref
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_formula_bvar_id		IN	NUMBER
) is
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'DELETE_FORMULA_REF';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

BEGIN
null;
end Delete_Formula_Ref;


PROCEDURE Delete_GrpOp_Filter
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_ctr_der_filter_id	IN	NUMBER
) is
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'DELETE_GRPOP_FILTER';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

BEGIN
null;
end Delete_GrpOp_Filter;


PROCEDURE Delete_Ctr_Association
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	:= FND_API.G_FALSE,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ctr_association_id		IN	NUMBER
) is
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'DELETE_CTR_ASSOCIATION';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

BEGIN
null;
end Delete_Ctr_Association;

PROCEDURE DELETE_COUNTER_INSTANCE(
       p_Api_Version              IN   NUMBER,
       p_Init_Msg_List            IN   VARCHAR2    := FND_API.G_FALSE,
       p_Commit                   IN   VARCHAR2    := FND_API.G_FALSE,
       p_SOURCE_OBJECT_ID         IN   NUMBER,
       p_SOURCE_OBJECT_CODE       IN   VARCHAR2,
       x_Return_status            OUT NOCOPY  VARCHAR2,
       x_Msg_Count                OUT NOCOPY  NUMBER,
       x_Msg_Data                 OUT NOCOPY  VARCHAR2,
       x_delete_status            OUT NOCOPY  VARCHAR2
  ) IS
       l_api_name           CONSTANT   VARCHAR2(30) := 'DELETE_COUNTER_INSTANCE';
       l_api_version        CONSTANT   NUMBER       := 1.0;
       l_ctr_group_id  NUMBER;
 BEGIN
 null;
 END  DELETE_COUNTER_INSTANCE;

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
) is
        l_api_name      CONSTANT        VARCHAR2(30)    := 'Instantiate_single_Ctr';
        l_api_version   CONSTANT        NUMBER          := 1.0;
        x_ctr_id_template NUMBER;                       -- Added for bug #5983441




BEGIN

/*


 SAVEPOINT       Instantiate_Counters_PUB;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version ,
                                                                 p_api_version ,
                                                                 l_api_name ,
                                                                 G_PKG_NAME )   THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

	 --BigDecimal [] x_ctr_grp_id_template = new BigDecimal[]{new BigDecimal(0)};
       --x_ctr_grp_id_template NUMBER;

        /*   Customer/Vertical Hookups
        /*      Customer pre -processing  section - Mandatory  */
        /*
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Instantiate_Counters_Pre (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_counter_group_id_template => p_counter_group_id_template,
             p_source_object_code_instance => p_source_object_code_instance,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_grp_id_template   => x_ctr_grp_id_template,
             x_ctr_grp_id_instance   => x_ctr_grp_id_instance
           );

           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /*      Vertical pre -processing  section - Mandatory */
       /*
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Instantiate_Counters_Pre (
             p_api_version=> l_api_version,
             p_init_msg_list=> p_init_msg_list,
             p_commit => p_commit,
             x_return_status=> x_return_status,
             x_msg_count=> x_msg_count,
             x_msg_data=> x_msg_data,
             p_counter_id_template => p_counter_id_template,
             p_source_object_code_instance => p_source_object_code_instance,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_id_template  => x_ctr_id_template,
             x_ctr_id_instance   => x_ctr_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- Start of API Body

        */

       --Code Added for bug #5983441 starts here

       CSI_COUNTER_TEMPLATE_PUB.Instantiate_Counters
        (
          p_api_version,
          p_init_msg_list,
          p_commit,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_counter_id_template,
          p_source_object_code_instance,
          p_source_object_id_instance,
          x_ctr_id_template,
          x_ctr_id_instance

          );

        --Code Added for bug #5983441 ends here

        -- End of API Body
        --
        -- Customer/Vertical Hookups
        /*      Customer post -processing  section - Mandatory  */
        /*
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
            CS_COUNTERS_CUHK.Instantiate_Counters_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_counter_id_template => p_counter_id_template,
             p_source_object_code_instance => p_source_object_code_instance,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_id_template   => x_ctr_id_template,
             x_ctr_id_instance   => l_ctr_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
        /*      Vertical post -processing  section - Mandatory */
       /*
        IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  )  THEN
           CS_COUNTERS_VUHK.Instantiate_Counters_Post (
             p_api_version           => l_api_version,
             p_init_msg_list         => p_init_msg_list,
             p_commit                => p_commit,
             x_return_status         => x_return_status,
             x_msg_count             => x_msg_count,
             x_msg_data              => x_msg_data,
             p_counter_id_template => p_counter_id_template,
             p_source_object_code_instance => p_source_object_code_instance,
             p_source_object_id_instance => p_source_object_id_instance,
             x_ctr_id_template   => x_ctr_id_template,
             x_ctr_id_instance   => l_ctr_id_instance
           );
           IF (x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                 RAISE FND_API.G_EXC_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
              p_data => x_msg_data
                );

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Instantiate_Counters_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Instantiate_Counters_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count ,
                 p_data => x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO Instantiate_Counters_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
                END IF;
                FND_MSG_PUB.Count_And_Get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
--null;

*/

end Instantiate_single_Ctr;

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
) IS
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'CREATE_ESTIMATION_METHOD';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_ctr_estimation_methods_rec   CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec;
 l_validation_level NUMBER;

BEGIN
        SAVEPOINT	Create_Ctr_Estimation_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Start of API Body

 l_ctr_estimation_methods_rec.ESTIMATION_ID           := x_estimation_id;
 l_ctr_estimation_methods_rec.ESTIMATION_TYPE         := p_ctr_estimation_rec.estimation_type;
 l_ctr_estimation_methods_rec.FIXED_VALUE             := p_ctr_estimation_rec.fixed_Value;
 l_ctr_estimation_methods_rec.USAGE_MARKUP            := p_ctr_estimation_rec.Usage_Markup;
 l_ctr_estimation_methods_rec.DEFAULT_VALUE           := p_ctr_estimation_rec.Default_Value;
 l_ctr_estimation_methods_rec.ESTIMATION_AVG_TYPE     := p_ctr_estimation_rec.estimation_avg_type;
 l_ctr_estimation_methods_rec.START_DATE_ACTIVE       := p_ctr_estimation_rec.start_date_active;
 l_ctr_estimation_methods_rec.END_DATE_ACTIVE         := p_ctr_estimation_rec.end_date_active;
 l_ctr_estimation_methods_rec.ATTRIBUTE1              := p_ctr_estimation_rec.ATTRIBUTE1;
 l_ctr_estimation_methods_rec.ATTRIBUTE2              := p_ctr_estimation_rec.ATTRIBUTE2;
 l_ctr_estimation_methods_rec.ATTRIBUTE3              := p_ctr_estimation_rec.ATTRIBUTE3;
 l_ctr_estimation_methods_rec.ATTRIBUTE4              := p_ctr_estimation_rec.ATTRIBUTE4;
 l_ctr_estimation_methods_rec.ATTRIBUTE5              := p_ctr_estimation_rec.ATTRIBUTE5;
 l_ctr_estimation_methods_rec.ATTRIBUTE6              := p_ctr_estimation_rec.ATTRIBUTE6;
 l_ctr_estimation_methods_rec.ATTRIBUTE7              := p_ctr_estimation_rec.ATTRIBUTE7;
 l_ctr_estimation_methods_rec.ATTRIBUTE8              := p_ctr_estimation_rec.ATTRIBUTE8;
 l_ctr_estimation_methods_rec.ATTRIBUTE9              := p_ctr_estimation_rec.ATTRIBUTE9;
 l_ctr_estimation_methods_rec.ATTRIBUTE10             := p_ctr_estimation_rec.ATTRIBUTE10;
 l_ctr_estimation_methods_rec.ATTRIBUTE11             := p_ctr_estimation_rec.ATTRIBUTE11;
 l_ctr_estimation_methods_rec.ATTRIBUTE12             := p_ctr_estimation_rec.ATTRIBUTE12;
 l_ctr_estimation_methods_rec.ATTRIBUTE13             := p_ctr_estimation_rec.ATTRIBUTE13;
 l_ctr_estimation_methods_rec.ATTRIBUTE14             := p_ctr_estimation_rec.ATTRIBUTE14;
 l_ctr_estimation_methods_rec.ATTRIBUTE15             := p_ctr_estimation_rec.ATTRIBUTE15;
 l_ctr_estimation_methods_rec.ATTRIBUTE_CATEGORY      := p_ctr_estimation_rec.ATTRIBUTE_CATEGORY;
 l_ctr_estimation_methods_rec.NAME                    := p_ctr_estimation_rec.estimation_name;
 l_ctr_estimation_methods_rec.DESCRIPTION             := p_ctr_estimation_rec.estimation_description;

 CSI_COUNTER_TEMPLATE_PUB.create_estimation_method
(
   p_api_version               =>  p_api_version
  ,p_commit                    =>  p_commit
  ,p_init_msg_list             =>  p_init_msg_list
  ,p_validation_level          =>  l_validation_level
  ,x_return_status             =>  x_return_status
  ,x_msg_count                 =>  x_msg_count
  ,x_msg_data                  =>  x_msg_data
  ,p_ctr_estimation_rec        => l_ctr_estimation_methods_rec
);

	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO Create_Ctr_Estimation_PUB;
	  RETURN;
	END IF;
	-- End of API Body

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Create_Ctr_Estimation_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Ctr_Estimation_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Create_Ctr_Estimation_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
END Create_Estimation_Method;

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
) is
	l_api_name     	CONSTANT	VARCHAR2(30)	:= 'UPDATE_ESTIMATION_METHOD';
	l_api_version	CONSTANT	NUMBER		:= 1.0;

 l_ctr_estimation_methods_rec   CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec;
 l_validation_level NUMBER;
BEGIN

	SAVEPOINT	Update_Estimation_Method_PUB;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--
	-- Start of API Body
 l_ctr_estimation_methods_rec.ESTIMATION_ID           := p_estimation_id;
 l_ctr_estimation_methods_rec.ESTIMATION_TYPE         := p_ctr_estimation_rec.estimation_type;
 l_ctr_estimation_methods_rec.FIXED_VALUE             := p_ctr_estimation_rec.fixed_Value;
 l_ctr_estimation_methods_rec.USAGE_MARKUP            := p_ctr_estimation_rec.Usage_Markup;
 l_ctr_estimation_methods_rec.DEFAULT_VALUE           := p_ctr_estimation_rec.Default_Value;
 l_ctr_estimation_methods_rec.ESTIMATION_AVG_TYPE     := p_ctr_estimation_rec.estimation_avg_type;
 l_ctr_estimation_methods_rec.START_DATE_ACTIVE       := p_ctr_estimation_rec.start_date_active;
 l_ctr_estimation_methods_rec.END_DATE_ACTIVE         := p_ctr_estimation_rec.end_date_active;
 l_ctr_estimation_methods_rec.ATTRIBUTE1              := p_ctr_estimation_rec.ATTRIBUTE1;
 l_ctr_estimation_methods_rec.ATTRIBUTE2              := p_ctr_estimation_rec.ATTRIBUTE2;
 l_ctr_estimation_methods_rec.ATTRIBUTE3              := p_ctr_estimation_rec.ATTRIBUTE3;
 l_ctr_estimation_methods_rec.ATTRIBUTE4              := p_ctr_estimation_rec.ATTRIBUTE4;
 l_ctr_estimation_methods_rec.ATTRIBUTE5              := p_ctr_estimation_rec.ATTRIBUTE5;
 l_ctr_estimation_methods_rec.ATTRIBUTE6              := p_ctr_estimation_rec.ATTRIBUTE6;
 l_ctr_estimation_methods_rec.ATTRIBUTE7              := p_ctr_estimation_rec.ATTRIBUTE7;
 l_ctr_estimation_methods_rec.ATTRIBUTE8              := p_ctr_estimation_rec.ATTRIBUTE8;
 l_ctr_estimation_methods_rec.ATTRIBUTE9              := p_ctr_estimation_rec.ATTRIBUTE9;
 l_ctr_estimation_methods_rec.ATTRIBUTE10             := p_ctr_estimation_rec.ATTRIBUTE10;
 l_ctr_estimation_methods_rec.ATTRIBUTE11             := p_ctr_estimation_rec.ATTRIBUTE11;
 l_ctr_estimation_methods_rec.ATTRIBUTE12             := p_ctr_estimation_rec.ATTRIBUTE12;
 l_ctr_estimation_methods_rec.ATTRIBUTE13             := p_ctr_estimation_rec.ATTRIBUTE13;
 l_ctr_estimation_methods_rec.ATTRIBUTE14             := p_ctr_estimation_rec.ATTRIBUTE14;
 l_ctr_estimation_methods_rec.ATTRIBUTE15             := p_ctr_estimation_rec.ATTRIBUTE15;
 l_ctr_estimation_methods_rec.ATTRIBUTE_CATEGORY      := p_ctr_estimation_rec.ATTRIBUTE_CATEGORY;
 l_ctr_estimation_methods_rec.NAME                    := p_ctr_estimation_rec.estimation_name;
 l_ctr_estimation_methods_rec.DESCRIPTION             := p_ctr_estimation_rec.estimation_description;


 CSI_COUNTER_TEMPLATE_PUB.Update_Estimation_Method
(
   p_api_version               =>  p_api_version
  ,p_commit                    =>  p_commit
  ,p_init_msg_list             =>  p_init_msg_list
  ,p_validation_level          =>  l_validation_level
  ,x_return_status             =>  x_return_status
  ,x_msg_count                 =>  x_msg_count
  ,x_msg_data                  =>  x_msg_data
  ,p_ctr_estimation_rec        =>  l_ctr_estimation_methods_rec
);

	IF NOT (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	  ROLLBACK TO Update_Estimation_Method_PUB;
	  RETURN;
	END IF;

	-- End of API Body

        IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Update_Estimation_Method_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Update_Estimation_Method_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		ROLLBACK TO Update_Estimation_Method_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

end Update_Estimation_Method;

END CS_Counters_PUB;

/
