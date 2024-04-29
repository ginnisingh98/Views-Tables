--------------------------------------------------------
--  DDL for Package Body PV_ENTY_ATTR_VALUE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTY_ATTR_VALUE_PUB" AS
 /* $Header: pvxvavpb.pls 120.6 2005/11/11 15:28:20 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ENTY_ATTR_VALUE_PUB
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


 G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_ENTY_ATTR_VALUE_PUB';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvavpb.pls';

 G_USER_ID         NUMBER := NVL(FND_GLOBAL.USER_ID,-1);
 G_LOGIN_ID        NUMBER := NVL(FND_GLOBAL.CONC_LOGIN_ID,-1);
 FUNCTION is_number (stg_in IN VARCHAR2)  RETURN BOOLEAN;
 FUNCTION sub_string(string_in IN VARCHAR2,upto_char IN VARCHAR2) RETURN VARCHAR2 ;
 FUNCTION MATCH_CODE_TO_VALUE(code IN VARCHAR2,lov_tbl IN PV_ATTRIBUTE_UTIL.lov_data_tbl_type) RETURN VARCHAR2;
 FUNCTION CHECK_CURRECY_FORMAT(  p_entity_attr_value   IN VARCHAR2 ) RETURN NUMBER;

-- Hint: Primary key needs to be returned.

PROCEDURE Upsert_Attr_Value(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attribute_id				  IN   NUMBER
	,p_entity                     IN   VARCHAR2
	,p_entity_id				  IN   NUMBER
	,p_version                    IN   NUMBER		:=0
	,p_attr_val_tbl               IN   attr_value_tbl_type  := g_miss_attr_value_tbl
    )



 IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Upsert_Attr_Value';
   l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_api_version_number        CONSTANT NUMBER       := 1.0;
   l_object_version_number              NUMBER       := 1;

   x_enty_attr_val_id                   NUMBER;
   x_object_version_number				NUMBER;
   l_attr_val_tbl						attr_value_tbl_type     := p_attr_val_tbl;
   l_attr_val_rec						attr_val_rec_type		:= g_miss_attr_val_rec;
   l_enty_attr_val_rec					PV_Enty_Attr_Value_PVT.enty_attr_val_rec_type  := PV_Enty_Attr_Value_PVT.g_miss_enty_attr_val_rec;
   l_version						    NUMBER      := FND_API.G_MISS_NUM;

   l_decimal_pts                        NUMBER;
   l_attribute_type						VARCHAR2(30);
   l_display_style						VARCHAR2(30);
   l_attribute_name                     VARCHAR2(60) ;
   l_external_update_text				VARCHAR2(2000);
   l_attr_data_type						VARCHAR2(30);
   l_value								VARCHAR2(2000);
   l_require_validation_flag		    VARCHAR2(1);
   l_lov_string                                VARCHAR2(2000);
   l_meaning					VARCHAR2(80);
   l_lead_record_exists                      VARCHAR2(1) := 'N';
   l_index					NUMBER :=0 ;
   l_lead_enty_attr_val_rec	PV_Enty_Attr_Value_PVT.enty_attr_val_rec_type := PV_Enty_Attr_Value_PVT.g_miss_enty_attr_val_rec;
   l_curr_row1			NUMBER;
   type cur_type			IS        REF CURSOR;
   lc_lov_cursor			cur_type;
   l_lov_values_table			JTF_VARCHAR2_TABLE_100;
   l_lov_data_rec  PV_ATTRIBUTE_UTIL.lov_data_rec_type := PV_ATTRIBUTE_UTIL.g_miss_lov_data_rec;
   l_lov_data_tbl  PV_ATTRIBUTE_UTIL.lov_data_tbl_type:= PV_ATTRIBUTE_UTIL.g_miss_lov_data_tbl;
   l_percentage_total            NUMBER := 0;
   l_perc_sum_profile_value      NUMBER := 100;
   l_character_width		 NUMBER;
   l_date			 DATE;

    CURSOR c_get_previous_version(cv_attribute_id NUMBER,cv_entity_id NUMBER, cv_entity VARCHAR2) IS
		SELECT distinct version
		FROM  PV_ENTY_ATTR_VALUES
		WHERE attribute_id = cv_attribute_id and
		      entity_id    = cv_entity_id and
			  entity       = cv_entity and
			  latest_flag  = 'Y';

   CURSOR c_get_enty_attr_value(cv_attribute_id NUMBER,cv_entity_id NUMBER, cv_entity VARCHAR2) IS
		SELECT *
		FROM  PV_ENTY_ATTR_VALUES
		WHERE attribute_id = cv_attribute_id and
		      entity_id    = cv_entity_id and
			  entity       = cv_entity and
			  latest_flag  = 'Y';

  CURSOR c_get_attr_details(cv_attribute_id NUMBER) IS
		SELECT attribute_type,display_style,DECIMAL_POINTS,name, character_width
		FROM  PV_ATTRIBUTES_VL
		WHERE attribute_id = cv_attribute_id
		      ;

 CURSOR c_get_attr_enty_details (pc_attribute_id IN NUMBER, pc_entity IN VARCHAR2) IS
      SELECT external_update_text, attr_data_type, require_validation_flag, lov_string
      FROM PV_ENTITY_ATTRS
      WHERE attribute_id = pc_attribute_id AND
			entity= pc_entity
			;

BEGIN
		-- Standard Start of API savepoint
		SAVEPOINT Upsert_Attr_Value_PUB;

		-- Standard call to check for call compatibility.
		IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE.
		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;

		-- Debug Message
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - start');
		END IF;

		-- Initialize API return status to SUCCESS
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('public API: '||l_full_name||' Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
		END IF;


	    --check for required items like attribute_id, entity, entity_id,versioin
		IF p_attribute_id IS NULL THEN
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','attribute_id');
			  FND_MSG_PUB.add;
			END IF;
			x_return_status := FND_API.g_ret_sts_error;
			RETURN;
		END IF;
		IF p_entity IS NULL THEN
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','entity type');
			  FND_MSG_PUB.add;
			END IF;
			x_return_status := FND_API.g_ret_sts_error;
			RETURN;
		END IF;
		IF p_entity_id IS NULL THEN
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','entity_id');
			  FND_MSG_PUB.add;
			END IF;
			x_return_status := FND_API.g_ret_sts_error;
			RETURN;
		END IF;



		--getting attribute details

		for x in c_get_attr_details(cv_attribute_id => p_attribute_id )
		loop
			l_attribute_type := x.attribute_type;
			l_display_style := x.display_style;
			l_decimal_pts   := x.decimal_points;
			l_attribute_name:= x.name;
			l_character_width := x.character_width;
		end loop;

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			PVX_Utility_PVT.debug_message('Attribute ID:' || p_attribute_id);
			PVX_Utility_PVT.debug_message('Attribute Type:' || l_attribute_type);
			PVX_Utility_PVT.debug_message('Display style:' || l_display_style);
			PVX_Utility_PVT.debug_message('Attribute Name:' || l_attribute_name);
			PVX_Utility_PVT.debug_message('Attribute character width:' || l_character_width);

		END IF;

		--getting attribute entity details

		for x in c_get_attr_enty_details (pc_attribute_id => p_attribute_id,
										  pc_entity       => p_entity)
		loop
			l_external_update_text := x.external_update_text;
			l_attr_data_type := x.attr_data_type;
			l_require_validation_flag := x.require_validation_flag;
			l_lov_string  := x.lov_string;
		end loop;

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			PVX_Utility_PVT.debug_message('entity:' || p_entity);
			PVX_Utility_PVT.debug_message('external update text:' || l_external_update_text);
			PVX_Utility_PVT.debug_message('attr data type:' || l_attr_data_type);
			PVX_Utility_PVT.debug_message('validation flag:' || l_require_validation_flag);
			PVX_Utility_PVT.debug_message('Lov String:' || l_lov_string);

		END IF;

		--if entity is LEAD (Opportunity), We are not dealing with all versioning and all.
		-- In this case we just simply insert and update

		if(p_entity='LEAD') then

			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				PVX_Utility_PVT.debug_message('public API: '||l_full_name||' - entity is opportunity');
			END IF;

			for x in c_get_enty_attr_value( cv_attribute_id => p_attribute_id,
							cv_entity_id    => p_entity_id,
							cv_entity	=> p_entity
													)
			loop
				l_lead_record_exists := 'Y';

			end loop;

			/*for x in c_get_enty_attr_value( cv_attribute_id => p_attribute_id,
							cv_entity_id    => p_entity_id,
							cv_entity	=> p_entity
													)
			loop

				l_lead_record_exists := 'Y';


				l_lead_enty_attr_val_rec.enty_attr_val_id       := x.enty_attr_val_id;
				l_lead_enty_attr_val_rec.object_version_number  := x.object_version_number;
				l_lead_enty_attr_val_rec.entity                 := x.entity;
				l_lead_enty_attr_val_rec.attribute_id           := x.attribute_id;
				l_lead_enty_attr_val_rec.party_id               := x.party_id;
				l_lead_enty_attr_val_rec.attr_value             := x.attr_value;
				l_lead_enty_attr_val_rec.score                  := x.score;
				l_lead_enty_attr_val_rec.enabled_flag           := x.enabled_flag;
				l_lead_enty_attr_val_rec.entity_id              := x.entity_id;

			end loop;
			*/


			IF (l_attr_val_tbl IS NULL OR
			    (l_attr_val_tbl IS NOT NULL AND l_attr_val_tbl.count = 0)

			    )
			THEN

				if(l_lead_record_exists = 'Y') then
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
						PVX_Utility_PVT.debug_message('public API: '||l_full_name||' -deleting act');
					END IF;

					for x in c_get_enty_attr_value( cv_attribute_id => p_attribute_id,
							cv_entity_id    => p_entity_id,
							cv_entity	=> p_entity
					)
					loop
						PV_Enty_Attr_Value_PVT.Delete_attr_value(

						   p_api_version_number		=> p_api_version_number
						  ,p_init_msg_list              => p_init_msg_list
						  ,p_commit                     => p_commit
						  ,p_validation_level           => p_validation_level

						  ,x_return_status              => x_return_status
						  ,x_msg_count                  => x_msg_count
						  ,x_msg_data                   => x_msg_data

						  ,p_enty_attr_val_id		=> x.enty_attr_val_id
						  ,p_object_version_number	=> x.object_version_number

						);


						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							RAISE FND_API.G_EXC_ERROR;
						END IF;
					end loop;
				end if;

			ELSE   --else of IF (l_attr_val_tbl IS NULL OR

				if(l_lead_record_exists = 'Y') then
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
						PVX_Utility_PVT.debug_message('public API: '||l_full_name||' -update act');
					END IF;
					--if you find any rows, firsdt delete and add the new ones
					for x in c_get_enty_attr_value( cv_attribute_id => p_attribute_id,
							cv_entity_id    => p_entity_id,
							cv_entity	=> p_entity
													)
					loop
						PV_Enty_Attr_Value_PVT.Delete_attr_value(

						   p_api_version_number		=> p_api_version_number
						  ,p_init_msg_list              => p_init_msg_list
						  ,p_commit                     => p_commit
						  ,p_validation_level           => p_validation_level
						  ,x_return_status              => x_return_status
						  ,x_msg_count                  => x_msg_count
						  ,x_msg_data                   => x_msg_data


						  ,p_enty_attr_val_id		=> x.enty_attr_val_id
						  ,p_object_version_number	=> x.object_version_number

						);
						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							RAISE FND_API.G_EXC_ERROR;
						END IF;
					end loop;

					FOR l_curr_row IN l_attr_val_tbl.first..l_attr_val_tbl.last LOOP

						l_attr_val_rec := l_attr_val_tbl(l_curr_row);


						--initialise it to null
						l_lead_enty_attr_val_rec      := PV_Enty_Attr_Value_PVT.g_miss_enty_attr_val_rec;

						--initialising standard columns  in the record
												--initialising in parameters to record fields
						l_lead_enty_attr_val_rec.entity		  := p_entity;
						l_lead_enty_attr_val_rec.attribute_id	  := p_attribute_id;

						l_lead_enty_attr_val_rec.attr_value	  := l_attr_val_rec.attr_value;
						l_lead_enty_attr_val_rec.enabled_flag     := 'Y';
						l_lead_enty_attr_val_rec.entity_id        := p_entity_id;


						PV_Enty_Attr_Value_PVT.Create_attr_value(

							   p_api_version_number		=> p_api_version_number
							  ,p_init_msg_list              => p_init_msg_list
							  ,p_commit                     => p_commit
							  ,p_validation_level		=> p_validation_level

							  ,x_return_status              => x_return_status
							  ,x_msg_count                  => x_msg_count
							  ,x_msg_data                   => x_msg_data


							  ,p_enty_attr_val_rec		=> l_lead_enty_attr_val_rec
							  ,x_enty_attr_val_id		=> x_enty_attr_val_id
						);
						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							RAISE FND_API.G_EXC_ERROR;
						END IF;

					END LOOP; --FOR l_curr_row IN 1..l_attr_val_tbl.count LOOP


				else
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
						PVX_Utility_PVT.debug_message('public API: '||l_full_name||' -creat act');
					END IF;

					FOR l_curr_row IN l_attr_val_tbl.first..l_attr_val_tbl.last LOOP

						l_attr_val_rec := l_attr_val_tbl(l_curr_row);


						--initialise it to null
						l_lead_enty_attr_val_rec      := PV_Enty_Attr_Value_PVT.g_miss_enty_attr_val_rec;

						--initialising standard columns  in the record
												--initialising in parameters to record fields
						l_lead_enty_attr_val_rec.entity		  := p_entity;
						l_lead_enty_attr_val_rec.attribute_id	  := p_attribute_id;

						l_lead_enty_attr_val_rec.attr_value	  := l_attr_val_rec.attr_value;
						l_lead_enty_attr_val_rec.enabled_flag     := 'Y';
						l_lead_enty_attr_val_rec.entity_id        := p_entity_id;


						IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
						PVX_Utility_PVT.debug_message('public API: '||l_full_name||' -creat act');
					END IF;




						PV_Enty_Attr_Value_PVT.Create_attr_value(

							   p_api_version_number		=> p_api_version_number
							  ,p_init_msg_list              => p_init_msg_list
							  ,p_commit                     => p_commit
							  ,p_validation_level		=> p_validation_level

							  ,x_return_status              => x_return_status
							  ,x_msg_count                  => x_msg_count
							  ,x_msg_data                   => x_msg_data


							  ,p_enty_attr_val_rec		=> l_lead_enty_attr_val_rec
							  ,x_enty_attr_val_id		=> x_enty_attr_val_id
						);
						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							RAISE FND_API.G_EXC_ERROR;
						END IF;

					END LOOP; --FOR l_curr_row IN 1..l_attr_val_tbl.count LOOP
				end if;  -- end of if(l_lead_record_exists = 'Y') then

			END IF; -- end of IF (l_attr_val_tbl IS NULL OR



                -- if entity is not LEAD, we just simply maintain all versioning and all.
		else
			-- If attribute type is EXTERNAL and EXT_INT, look for external_update_text and
		        -- see if it is not null. if it is not null, execute it .
			-- In all other cases insert in to pv_enty_attr_values.

			IF(l_attr_data_type in ('EXTERNAL','EXT_INT')  AND
			   l_external_update_text is not  null
			) THEN
				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - attr_data_type is :'|| l_attr_data_type);
				END IF;

				--if update text is not null , then call update API for each attribute
				--IF (l_external_update_text is not  null) THEN


					IF (l_attr_val_tbl IS NOT NULL AND l_attr_val_tbl.count <> 0
					) THEN

						FOR l_curr_row IN l_attr_val_tbl.first..l_attr_val_tbl.last LOOP
							l_attr_val_rec := l_attr_val_tbl(l_curr_row);

							l_value := l_attr_val_rec.attr_value;
							exit;
						END LOOP; --FOR l_curr_row IN 1..l_attr_val_tbl.count LOOP



						BEGIN

							EXECUTE IMMEDIATE l_external_update_text USING   p_api_version_number
																			,p_init_msg_list
																			,p_commit
																			,p_validation_level
																			,out x_return_status
																			,out x_msg_count
																			,out x_msg_data
																			,p_entity
																			,p_entity_id
																			,l_value;


							IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

								RAISE FND_API.G_EXC_ERROR;
							END IF;

						EXCEPTION
							WHEN OTHERS THEN
								IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
									FND_MESSAGE.set_name('PV', 'PV_API_EXECUTION_ERROR');
									FND_MESSAGE.set_token('TEXT', l_external_update_text);
									FND_MESSAGE.set_token('ID', TO_CHAR(p_attribute_id));
									FND_MESSAGE.set_token('NAME', l_attribute_name);
									FND_MESSAGE.set_token('ENTITY',p_entity);
									FND_MSG_PUB.add;
								END IF;
								RAISE FND_API.G_EXC_ERROR;
						END;

					END IF;

				--end if;

			ELSE
				  -- In all other cases than l_attr_data_type in ('EXTERNAL','EXT_INT')  and l_external_update_text is not  null
				  -- this else block will end at last line



					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
					PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - attr_data_type is :'|| l_attr_data_type);
					END IF;
					--check for version number
					--Here we are treating version as object_version_number. So we check this version with previous versions

					-- get previous version first

					for x in c_get_previous_version(cv_attribute_id => p_attribute_id,
													cv_entity_id    => p_entity_id,
													cv_entity		=> p_entity
													)
					loop
						l_version := x.version;
					end loop;

					--if no row for this attribute id, entity, the you will get version as null,
					--so you need to initialise version to 1

					IF l_version IS NULL OR l_version = FND_API.G_MISS_NUM THEN
						l_version := 0;
					END IF;

					-- Check Whether record has been changed by someone else
					PVX_Utility_PVT.debug_message('public API: '||l_full_name||' - l_version :' || l_version);

					If (l_version <> p_version) Then
					  -- IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
						IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

						   FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
						   FND_MESSAGE.set_token('VALUE','Attribute Entity Value');
						   FND_MSG_PUB.add;
					   END IF;
					   RAISE FND_API.G_EXC_ERROR;
					End if;


					IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
					THEN
						-- Debug message
						IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
						PVX_Utility_PVT.debug_message('public API: '||l_full_name||' - Validate_attr_value');
						END IF;


						--since validation procedures will be done in record level in private API, No need to do any thing here
						--We have done all validations that are to be done above.

					END IF;

					IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
						RAISE FND_API.G_EXC_ERROR;
					END IF;




				   --Update attribute_values with latest_flag = 'Y' before inserting new rows by changing latest_flag to 'N'

				   for x in c_get_enty_attr_value(cv_attribute_id => p_attribute_id,
													cv_entity_id    => p_entity_id,
													cv_entity		=> p_entity
													)
					loop
						IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
						PVX_Utility_PVT.debug_message('public API: '||l_full_name||' - Updating loop');
						END IF;
						l_enty_attr_val_rec      := PV_Enty_Attr_Value_PVT.g_miss_enty_attr_val_rec;

						--get all values from table and assign it to record and call update_attr_value of pv_enty_attr_value_pvt
						l_enty_attr_val_rec.enty_attr_val_id       := x.enty_attr_val_id;
						l_enty_attr_val_rec.object_version_number  := x.object_version_number;
						l_enty_attr_val_rec.entity                 := x.entity;
						l_enty_attr_val_rec.attribute_id           := x.attribute_id;
						l_enty_attr_val_rec.party_id               := x.party_id;
						l_enty_attr_val_rec.attr_value             := x.attr_value;
						l_enty_attr_val_rec.score                  := x.score;
						l_enty_attr_val_rec.enabled_flag           := x.enabled_flag;
						l_enty_attr_val_rec.entity_id              := x.entity_id;
						l_enty_attr_val_rec.version				   := x.version;
						--update latest flag with 'N'
						l_enty_attr_val_rec.latest_flag			   := 'N';
						l_enty_attr_val_rec.attr_value_extn		   := x.attr_value_extn;
						l_enty_attr_val_rec.validation_id          := x.validation_id;

						IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
						PVX_Utility_PVT.debug_message('public API: '||l_full_name||' - before calling pvt update method');
						END IF;
						PV_Enty_Attr_Value_PVT.Update_Attr_Value(

							 p_api_version_number         => p_api_version_number
							,p_init_msg_list              => p_init_msg_list
							,p_commit                     => p_commit
							,p_validation_level           => p_validation_level

							,x_return_status              => x_return_status
							,x_msg_count                  => x_msg_count
							,x_msg_data                   => x_msg_data

							,p_enty_attr_val_rec          => l_enty_attr_val_rec
							,x_object_version_number      => x_object_version_number

						);

						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							RAISE FND_API.G_EXC_ERROR;
						END IF;

					END LOOP; --for x in c_get_enty_attr_value

					--getting attribute details

					/*
					for x in c_get_attr_details(cv_attribute_id => p_attribute_id )
					loop
						l_attribute_type := x.attribute_type;
						l_display_style := x.display_style;
						l_decimal_pts   := x.decimal_points;
						l_attribute_name:= x.name;
					end loop;
					*/
					if(l_decimal_pts is null ) then
						l_decimal_pts :=2;  -- hardcodeing decimal pts to 2
					end if;
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
					PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' cursor c_get_attr_details closed');
					END IF;

					-- getting lov values table  for dropdown attributes

					IF(l_attribute_type = 'DROPDOWN') then
						IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
						PVX_Utility_PVT.debug_message('Getting lov values table for LOV String: '||l_lov_string);
						END IF;

						IF (l_lov_string IS NOT NULL OR LENGTH(l_lov_string) <> 0) THEN
							--replacing java bindings with pl/sql bindings.
						        BEGIN
								OPEN lc_lov_cursor FOR replace(l_lov_string,'?',':1') using p_attribute_id;
								LOOP
									FETCH lc_lov_cursor INTO l_lov_data_rec;
									EXIT WHEN lc_lov_cursor%NOTFOUND;
									l_index := l_index +1;
									l_lov_data_tbl(l_index) := l_lov_data_rec;
								END LOOP;
								CLOSE lc_lov_cursor;

								IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
									PVX_Utility_PVT.debug_message('l_index:'||l_index||':');
								END IF;

							EXCEPTION
							WHEN OTHERS THEN
								IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
									FND_MESSAGE.set_name('PV', 'PV_LOV_EXECUTION_ERROR');
									FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
									FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
									FND_MESSAGE.set_token('ENTITY',p_entity);
									FND_MSG_PUB.add;
								END IF;
								RAISE FND_API.G_EXC_ERROR;

							end;

						END IF;

					end if;


					begin  --start block for (catching Numberexceptions
						FOR l_curr_row IN 1..l_attr_val_tbl.count LOOP

							l_attr_val_rec := l_attr_val_tbl(l_curr_row);

						  IF(l_attribute_type = 'DROPDOWN') then
							IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
								PVX_Utility_PVT.debug_message('Performing all validatiosn for Dropdown attributes');
							END IF;
							--Checkign if Specified value(s) are in the look-up list of values
							IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
								PVX_Utility_PVT.debug_message('Checkign if Specified value(s) are in the look-up list of values');
							END IF;

							IF (l_attr_val_tbl(l_curr_row).attr_value <> null and
							     l_attr_val_tbl(l_curr_row).attr_value <> '' and
							     MATCH_CODE_TO_VALUE(l_attr_val_tbl(l_curr_row).attr_value,l_lov_data_tbl) = '$$INVALID*$VALUE$$' )
							THEN
								IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
									FND_MESSAGE.set_name('PV', 'PV_ATTR_VALUE_LOV_ERROR');
									FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
									FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
									FND_MSG_PUB.add;
								END IF;

								RAISE FND_API.G_EXC_ERROR;
							else
								IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
									PVX_Utility_PVT.debug_message('Match Found');
								END IF;

							END IF;

							IF( l_display_style= 'SINGLE' OR l_display_style= 'RADIO') THEN
								IF(l_curr_row > 1) THEN

									IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
										FND_MESSAGE.set_name('PV', 'PV_ATTR_ONLY_ONE_VALUE');
										FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
										FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
										FND_MSG_PUB.add;
									END IF;

									RAISE FND_API.G_EXC_ERROR;

								END IF;

							ELSIF( l_display_style= 'PERCENTAGE') THEN

								IF( NOT is_number (l_attr_val_rec.attr_value_extn) ) THEN
									IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
										FND_MESSAGE.set_name('PV', 'PV_ATTR_VALUE_NON_MUMERIC');
										FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
										FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
										FND_MSG_PUB.add;
									END IF;

									RAISE FND_API.G_EXC_ERROR;

								END IF;

								if(to_number(trim(l_attr_val_rec.attr_value_extn))<0) then

									x_return_status := FND_API.g_ret_sts_error;
									RAISE FND_API.G_EXC_ERROR;

								elsif(to_number(trim(l_attr_val_rec.attr_value_extn))=0) then

									l_attr_val_tbl.delete(l_curr_row);

								else
									l_attr_val_tbl(l_curr_row).attr_value_extn := ROUND(l_attr_val_tbl(l_curr_row).attr_value_extn,l_decimal_pts);

									BEGIN
										l_percentage_total := l_percentage_total + to_number(l_attr_val_tbl(l_curr_row).attr_value_extn);
									EXCEPTION
									WHEN OTHERS THEN
										l_percentage_total := 0;
										IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
											PVX_Utility_PVT.debug_message('Error in calculating percentage sum');
										END IF;
									END;

								end if;

							END IF;

						---- end of IF(l_attribute_type = 'DROPDOWN') then
						ELSIF (l_attribute_type = 'TEXT') THEN

							IF (l_display_style= 'NUMBER') THEN

								IF( NOT is_number (l_attr_val_rec.attr_value) ) THEN
									IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
										FND_MESSAGE.set_name('PV', 'PV_ATTR_VALUE_NON_NUMERIC');
										FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
										FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
										FND_MSG_PUB.add;
									END IF;

									RAISE FND_API.G_EXC_ERROR;
								END IF;

								l_attr_val_tbl(l_curr_row).attr_value := ROUND(l_attr_val_tbl(l_curr_row).attr_value,l_decimal_pts);
							ELSIF (l_display_style= 'PERCENTAGE') THEN

								IF( NOT is_number (l_attr_val_rec.attr_value) ) THEN
									IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
										FND_MESSAGE.set_name('PV', 'PV_ATTR_VALUE_NON_NUMERIC');
										FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
										FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
										FND_MSG_PUB.add;
									END IF;

									RAISE FND_API.G_EXC_ERROR;
								END IF;
							ELSIF (l_display_style= 'STRING') THEN

								IF( length(l_attr_val_rec.attr_value) > l_character_width) THEN
									IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
										FND_MESSAGE.set_name('PV', 'PV_ATTR_VALUE_TEXT_LIMIT');
										FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
										FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
										FND_MSG_PUB.add;
									END IF;

									RAISE FND_API.G_EXC_ERROR;
								END IF;

							ELSIF (l_display_style= 'DATE') THEN

								begin
									l_date := to_date(l_attr_val_tbl(l_curr_row).attr_value,'yyyymmddhh24miss');
								exception
								when others then

									IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
										FND_MESSAGE.set_name('PV', 'PV_ATTR_DATE_FORMAT_ERROR');
										FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
										FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
										FND_MSG_PUB.add;
									END IF;

									RAISE FND_API.G_EXC_ERROR;
								end;


							ELSIF (l_display_style= 'CURRENCY') THEN

									IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
									PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' CURRENCY' || sub_string(l_attr_val_rec.attr_value,':'));
									END IF;

								IF (--sub_string(l_attr_val_rec.attr_value,':') IS  NULL OR
									( sub_string(l_attr_val_rec.attr_value,':') IS NOT  NULL AND
									  NOT is_number (sub_string(l_attr_val_rec.attr_value,':'))
									  )
								   ) THEN

										IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
											FND_MESSAGE.set_name('PV', 'PV_ATTR_VALUE_NON_NUMERIC');
											FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
											FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
											FND_MSG_PUB.add;
										END IF;
										RAISE FND_API.G_EXC_ERROR;


								END IF;

								 IF(CHECK_CURRECY_FORMAT(l_attr_val_tbl(l_curr_row).attr_value) = 0) THEN
									IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
										FND_MESSAGE.set_name('PV', 'PV_ATTR_CURR_FORMAT_ERROR');
										FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
										FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
										FND_MSG_PUB.add;
									END IF;
										RAISE FND_API.G_EXC_ERROR;
								 END IF;



								 l_attr_val_tbl(l_curr_row).attr_value :=
									   ROUND(
											 SUBSTR(
											l_attr_val_tbl(l_curr_row).attr_value,
											1,
											INSTR(l_attr_val_tbl(l_curr_row).attr_value, ':', 1, 1)-1
											)
											,l_decimal_pts
										)

										||
										SUBSTR(
											l_attr_val_tbl(l_curr_row).attr_value,
											INSTR(l_attr_val_tbl(l_curr_row).attr_value, ':', 1, 1)

										)
											 ;
									IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
									PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' Val '||  l_attr_val_tbl(l_curr_row).attr_value);
									END IF;
							END IF;

						END IF; -- end of ELSIF (l_attribute_type = 'TEXT') THEN
					END LOOP;

					--Check the percentage sume validation
					IF (l_attribute_type='DROPDOWN' and
					    l_display_style= 'PERCENTAGE') THEN
						BEGIN

							l_perc_sum_profile_value:= to_number(nvl(fnd_profile.value('PV_ATTR_PERCENTAGE_TOTAL'), '100'));
						EXCEPTION
						WHEN OTHERS THEN
							IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
								PVX_Utility_PVT.debug_message('Error in getting profile option value PV_ATTR_PERCENTAGE_TOTAL');
							END IF;
							l_perc_sum_profile_value:=100;
						END;

						IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
							PVX_Utility_PVT.debug_message('profile option PV_ATTR_PERCENTAGE_TOTAL value:'|| l_perc_sum_profile_value);
						END IF;
						IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
							PVX_Utility_PVT.debug_message('Sum of all Percentage attr values:'|| l_percentage_total);
						END IF;

						IF(l_percentage_total < 0 or  l_percentage_total > l_perc_sum_profile_value) THEN

							IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
								FND_MESSAGE.set_name('PV', 'PV_ATTR_PERCENT_SUM_ERROR');
								FND_MESSAGE.set_token('TOTAL','' || l_perc_sum_profile_value);
								FND_MESSAGE.set_token('ATTRIBUTE_ID',p_attribute_id);
								FND_MESSAGE.set_token('ATTRIBUTE_NAME',l_attribute_name);
								FND_MSG_PUB.add;
							END IF;
							RAISE FND_API.G_EXC_ERROR;

						END IF;

					END IF; -- end of IF (l_attribute_type='DROPDOWN' and  l_display_style= 'CURRENCY') THEN

					EXCEPTION
							WHEN OTHERS THEN
								ROLLBACK TO Upsert_Attr_Value_PUB;
								x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
								/*IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
								THEN
									FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
								END IF;
								*/
								-- Standard call to get message count and if count=1, get the message
								FND_MSG_PUB.Count_And_Get (
									 p_encoded => FND_API.G_FALSE
									,p_count => x_msg_count
									,p_data  => x_msg_data
									);
								RAISE FND_API.G_EXC_ERROR;
					End;

					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
					PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' User Id:--' || fnd_global.user_id);
					END IF;
				-- calling notification API if validation rerquired for this attribute id
				-- We are calling validation API only for attributes of type TEXT and DROPDOWN
				-- We are skipping this call, if attribute is of type FUNCTION and not set validation flag

					if(l_require_validation_flag='Y' and
					   l_attribute_type <> 'FUNCTION') then

						PV_ATTR_VALIDATION_PUB.attribute_validate(
							 p_api_version_number         => p_api_version_number
							,p_init_msg_list              => p_init_msg_list
							,p_commit                     => p_commit
							,p_validation_level           => p_validation_level

							,p_attribute_id               => p_attribute_id
							,p_entity					  => p_entity
							,p_entity_id				  => p_entity_id
							--p_resource_id				     IN  VARCHAR2,
							,p_user_id					  => FND_GLOBAL.USER_ID

							,x_return_status              => x_return_status
							,x_msg_count                  => x_msg_count
							,x_msg_data                   => x_msg_data
						);


						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							RAISE FND_API.G_EXC_ERROR;
						END IF;

					end if;


				--end calling notification API


					-- Debug Message
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
					PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - Calling Create Private API');
					END IF;
					--if there are no records in p_attr_val_tbl, that means we have to create adummy row
					-- with higher version and latest_flag as 'Y' and attribute_value as null
					--just for the sake of tracking history

					IF (l_attr_val_tbl IS NULL OR
						--p_attr_val_tbl = g_miss_attr_value_tbl OR
						(l_attr_val_tbl IS NOT NULL AND l_attr_val_tbl.count = 0)
					) THEN

						IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
						PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - Value Table Null or Zero length');
						END IF;
						l_enty_attr_val_rec      := PV_Enty_Attr_Value_PVT.g_miss_enty_attr_val_rec;

						--initialising standard columns  in the record
						--l_enty_attr_val_rec.enty_attr_val_id      := l_enty_attr_val_id;
						/*l_enty_attr_val_rec.last_update_date      := SYSDATE;
						l_enty_attr_val_rec.last_updated_by       := G_USER_ID;
						l_enty_attr_val_rec.creation_date         := SYSDATE;
						l_enty_attr_val_rec.created_by            := G_USER_ID;
						l_enty_attr_val_rec.last_update_login     := G_LOGIN_ID;
						l_enty_attr_val_rec.object_version_number := l_object_version_number;
						*/
						--initialising in parameters to record fields
						l_enty_attr_val_rec.entity				  := p_entity;
						l_enty_attr_val_rec.attribute_id		  := p_attribute_id;
						--no party_id for record; not using thsi column

						--CHECK FOR ATTR_VALUE NULL
						l_enty_attr_val_rec.attr_value			  := null;
						--no score
						--no security_group_id
						l_enty_attr_val_rec.enabled_flag          := 'Y';
						l_enty_attr_val_rec.entity_id             := p_entity_id;
						--version need to be incremented by 1
						l_enty_attr_val_rec.version               := p_version+1;
						l_enty_attr_val_rec.latest_flag           := 'Y';
						l_enty_attr_val_rec.attr_value_extn       :=null;



						-- Invoke Private API(PV_ENTY_ATTR_VALUES_PVT.Create_Attr_Value
						PV_Enty_Attr_Value_PVT.Create_Attr_Value(
							 p_api_version_number         => p_api_version_number
							,p_init_msg_list              => p_init_msg_list
							,p_commit                     => p_commit
							,p_validation_level           => p_validation_level

							,x_return_status              => x_return_status
							,x_msg_count                  => x_msg_count
							,x_msg_data                   => x_msg_data

							,p_enty_attr_val_rec          => l_enty_attr_val_rec
							,x_enty_attr_val_id           => x_enty_attr_val_id
						);



						IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
							RAISE FND_API.G_EXC_ERROR;
						END IF;

					ELSE  -- there are records in l_attr_val_tbl


					-- User can not add multiple values for an attributes other than
					-- attribute type = Drop Down  and style= Percentage, Multi-Select, check-Box, External_LOV

						if(l_attr_val_tbl.count >= 2
						   and not (l_attribute_type = 'DROPDOWN'
							    and l_DISPLAY_STYLE in ('EXTERNAL_LOV','MULTI','CHECK','PERCENTAGE')
						       )
						   and not (l_attribute_type = 'FUNCTION')

						   ) then
							IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
								  Fnd_Message.set_name('PV', 'PV_ENTY_ATTR_VAL_MULTI_ERROR');


								  FOR x IN (select meaning from pv_lookups
									    where lookup_type = 'PV_ATTRIBUTE_TYPE'
									    and lookup_code = l_attribute_type
									   ) LOOP
									l_meaning := x.meaning;
								  END LOOP;
								  Fnd_Message.set_token('ATTR_TYPE',l_meaning);

								  FOR x IN (select meaning from pv_lookups
									    where lookup_type = 'PV_ATTR_DISPLAY_STYLE'
									    and lookup_code = l_display_style
									   ) LOOP
									l_meaning := x.meaning;
								  END LOOP;
								  Fnd_Message.set_token('ATTR_STYLE',l_meaning);


								  Fnd_Msg_Pub.ADD;
							  END IF;
							  RAISE Fnd_Api.G_EXC_ERROR;


						end if;


						--FOR l_curr_row IN l_attr_val_tbl.first..l_attr_val_tbl.last LOOP
						l_curr_row1 := l_attr_val_tbl.first;
						WHILE l_curr_row1 <= l_attr_val_tbl.last LOOP

							l_attr_val_rec := l_attr_val_tbl(l_curr_row1);

							IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
							PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' VAlue Table Not Null  ');
							END IF;
							--initialise it to null
							l_enty_attr_val_rec      := PV_Enty_Attr_Value_PVT.g_miss_enty_attr_val_rec;

							--initialising standard columns  in the record
							--l_enty_attr_val_rec.enty_attr_val_id      := l_enty_attr_val_id;
							l_enty_attr_val_rec.last_update_date      := SYSDATE;
							l_enty_attr_val_rec.last_updated_by       := G_USER_ID;
							l_enty_attr_val_rec.creation_date         := SYSDATE;
							l_enty_attr_val_rec.created_by            := G_USER_ID;
							l_enty_attr_val_rec.last_update_login     := G_LOGIN_ID;
							l_enty_attr_val_rec.object_version_number := l_object_version_number;

							--initialising in parameters to record fields
							l_enty_attr_val_rec.entity				  := p_entity;
							l_enty_attr_val_rec.attribute_id		  := p_attribute_id;
							--no party_id for record; not using thsi column

							--CHECK FOR ATTR_VALUE NULL
							l_enty_attr_val_rec.attr_value			  := l_attr_val_rec.attr_value;
							--no score
							--no security_group_id
							l_enty_attr_val_rec.enabled_flag          := 'Y';
							l_enty_attr_val_rec.entity_id             := p_entity_id;
							--version need to be incremented by 1
							l_enty_attr_val_rec.version               := p_version+1;
							l_enty_attr_val_rec.latest_flag           := 'Y';
							l_enty_attr_val_rec.attr_value_extn       :=l_attr_val_rec.attr_value_extn;

							PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - after  ');

							-- Invoke Private API(PV_ENTY_ATTR_VALUES_PVT.Create_Attr_Value
							PV_Enty_Attr_Value_PVT.Create_Attr_Value(
								 p_api_version_number         => p_api_version_number
								,p_init_msg_list              => p_init_msg_list
								,p_commit                     => p_commit
								,p_validation_level           => p_validation_level

								,x_return_status              => x_return_status
								,x_msg_count                  => x_msg_count
								,x_msg_data                   => x_msg_data

								,p_enty_attr_val_rec          => l_enty_attr_val_rec
								,x_enty_attr_val_id           => x_enty_attr_val_id
							);



							IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
								RAISE FND_API.G_EXC_ERROR;
							END IF;

							l_curr_row1:=l_attr_val_tbl.next(l_curr_row1);

						END LOOP; --WHILE LOOP --FOR l_curr_row IN 1..l_attr_val_tbl.count LOOP
					END IF; -- end of IF (p_attr_val_tbl IS NULL OR
			END IF; -- end of main if block IF(l_attr_data_type in ('EXTERNAL','EXT_INT') ) THEN
		END IF;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
       PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - end');
	   END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
          p_count          =>   x_msg_count
         ,p_data           =>   x_msg_data
         );

EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Upsert_Attr_Value_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Upsert_Attr_Value_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO Upsert_Attr_Value_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );
End Upsert_Attr_Value;

FUNCTION is_number (stg_in IN VARCHAR2)
   RETURN BOOLEAN
IS
   val NUMBER;
BEGIN
   val := TO_NUMBER (stg_in);
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN RETURN FALSE;
END is_number;

FUNCTION CHECK_CURRECY_FORMAT(
   p_entity_attr_value   IN VARCHAR2
 )
RETURN NUMBER
AS
	l_api_name               VARCHAR2(30) := 'CHECK_CURRECY_FORMAT';
	l_entity_attr_value      NUMBER;
	l_entity_currency_code   VARCHAR2(10);
	l_currency_date          DATE;
	l_num_of_tokens          NUMBER;

BEGIN
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('Private API: '||l_api_name );
	END IF;

	l_num_of_tokens := (LENGTH(p_entity_attr_value) -
                       LENGTH(REPLACE(p_entity_attr_value, ':::', '')))
                      /LENGTH(':::')
                      + 1;
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('l_num_of_tokens: '||l_num_of_tokens);
	END IF;

	IF (l_num_of_tokens <> 3) THEN
		return 0;
	END IF;

	l_entity_attr_value := TO_NUMBER(PV_CHECK_MATCH_PUB.Retrieve_Token (
                                       p_delimiter         => ':::',
                                       p_attr_value_string => p_entity_attr_value,
                                       p_input_type        => 'IN TOKEN',
                                       p_index             => 1
				    ),
                                    '999999999999.99999999999999999999'
                          );

	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('l_entity_attr_value: '||l_entity_attr_value);
	END IF;

	l_entity_currency_code := PV_CHECK_MATCH_PUB.Retrieve_Token (
                                p_delimiter         => ':::',
                                p_attr_value_string => p_entity_attr_value,
                                p_input_type        => 'IN TOKEN',
                                p_index             => 2
                             );
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('l_entity_currency_code: '||l_entity_currency_code);
	END IF;
	IF (l_entity_currency_code IS NULL) THEN
		return 0;
	END IF;

	l_currency_date := TO_DATE(PV_CHECK_MATCH_PUB.Retrieve_Token (
                                p_delimiter         => ':::',
                                p_attr_value_string => p_entity_attr_value,
                                p_input_type        => 'IN TOKEN',
                                p_index             => 3
                              ),
                              'yyyymmddhh24miss');
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('l_currency_date: '||l_currency_date);
	END IF;
	IF (l_currency_date IS NULL) THEN
		return 0;
	END IF;

return 1;

EXCEPTION
WHEN OTHERS THEN
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('Exception in checking the currency format ');
	END IF;
	return 0;
END CHECK_CURRECY_FORMAT;




FUNCTION MATCH_CODE_TO_VALUE (        code     VARCHAR2,
                                    lov_tbl      PV_ATTRIBUTE_UTIL.lov_data_tbl_type
			    )
RETURN VARCHAR2
AS

BEGIN
	FOR i in 1..lov_tbl.count LOOP

		if(rtrim(lov_tbl(i).code) = rtrim(code)) then
			return rtrim(lov_tbl(i).meaning);
		end if;

	END LOOP;

	--if(rtrim(code) = '' or code = null) then
	--	return '';
	--else
		return '$$INVALID*$VALUE$$';
	--end if;

END MATCH_CODE_TO_VALUE;


FUNCTION sub_string (string_in IN VARCHAR2 , upto_char IN VARCHAR2)
   RETURN VARCHAR2
IS
   string_out       VARCHAR2(100);


   WORD_LENGTH      number;
   CHAR_POS         number;
BEGIN
   if(string_in is null) then
      return string_in;
   end if;

   WORD_LENGTH := LENGTH(string_in);
   for CHAR_POS in 1..WORD_LENGTH loop
      if(SUBSTR(string_in, CHAR_POS, 1) = upto_char) THEN
			return string_out;
	  else
	  		string_out := string_out ||  SUBSTR(string_in, CHAR_POS, 1);
      end if;
   end loop;
   return string_out;
END sub_string;


PROCEDURE Copy_Partner_Attr_Values(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_attr_id_tbl				  IN   NUMBER_TABLE
	,p_entity                     IN   VARCHAR2
	,p_entity_id			      IN   NUMBER
	,p_partner_id			      IN   NUMBER

    )

IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Copy_Partner_Attr_Values';
   l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_api_version_number        CONSTANT NUMBER       := 1.0;
   l_object_version_number              NUMBER       := 1;

   l_attr_count             NUMBER;
   l_attr_data_type	VARCHAR2(30);
   l_version				NUMBER;

   l_attr_val_tbl						attr_value_tbl_type := g_miss_attr_value_tbl;
   l_sql_text				VARCHAR2(2000);
   l_index                 NUMBER;
   l_attr_value                      VARCHAR2(2000);

   type cur_type			IS        REF CURSOR;
   lc_ext_cursor			cur_type;

   CURSOR c_attr_data_type(cv_attribute_id NUMBER, cv_entity_id NUMBER) IS
		SELECT distinct enty.attr_data_type, ENTY.SQL_TEXT -- VAL.version,
		FROM  PV_ATTRIBUTES_VL ATTR, PV_ENTITY_ATTRS ENTY, PV_ENTY_ATTR_VALUES VAL
		WHERE ATTR.attribute_id = cv_attribute_id  AND
		      ENTY.ATTRIBUTE_ID = ATTR.attribute_id AND
              ENTY.ENTITY = 'PARTNER' AND
              VAL.ATTRIBUTE_ID (+) =  ENTY.ATTRIBUTE_ID AND
              VAL.ENTITY (+) = ENTY.ENTITY AND
              VAL.ENTITY_ID (+) = cv_entity_id
		     ;

   CURSOR c_enty_attr_int_values(cv_attribute_id NUMBER, cv_entity_id NUMBER) IS

		select enty.attr_value, enty.Attr_Value_Extn
		from pv_enty_attr_values enty
		where enty.attribute_id = cv_attribute_id
		and enty.entity = 'PARTNER' and
		enty.entity_id = cv_entity_id AND
		enty.LATEST_FLAG = 'Y' AND
		enty.ATTR_VALUE is not null
		;

	 CURSOR c_get_previous_version(cv_attribute_id NUMBER,cv_entity_id NUMBER, cv_entity VARCHAR2) IS
		SELECT distinct version
		FROM  PV_ENTY_ATTR_VALUES
		WHERE attribute_id = cv_attribute_id and
		      entity_id    = cv_entity_id and
			  entity       = cv_entity and
			  latest_flag  = 'Y';

BEGIN
		-- Standard Start of API savepoint
		SAVEPOINT Copy_Partner_Attr_Values_PUB;

		-- Standard call to check for call compatibility.
		IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE.
		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;

		-- Debug Message
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - start');
		END IF;


		-- Initialize API return status to SUCCESS
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('public API: '||l_full_name||' Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
		END IF;

		--check for required columns

		IF p_attr_id_tbl IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','p_attr_id_tbl');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
		END IF;
		IF p_entity_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','p_entity_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
		END IF;
		IF p_entity IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','p_entity');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
		END IF;
		IF p_partner_id IS NULL THEN
          IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','p_partner_id');
			  FND_MSG_PUB.add;
		  END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
		END IF;


		IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
		THEN
			-- Debug message
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			PVX_Utility_PVT.debug_message('public API: '||l_full_name||' - Validate_attr_value');
			END IF;

			--since validation procedures will be done in record level in private API, No need to do any thing here
			--all validations would be done in inner API calls

		END IF;

		IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;


		-- Debug Message
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - Before copying......');
		END IF;
		--if there are no records in p_attr_val_tbl, that means we have to create adummy row
		-- with higher version and latest_flag as 'Y' and attribute_value as null
		--just for the sake of tracking history

		IF (p_attr_id_tbl is not null and p_attr_id_tbl.count > 0  ) THEN

			l_attr_count := 1;
			LOOP

			EXIT WHEN l_attr_count = p_attr_id_tbl.count+1;
				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				PVX_Utility_PVT.debug_message('Public API:'||l_full_name||'  attr id: ' ||  p_attr_id_tbl(l_attr_count) );
				END IF;

				for x in c_get_previous_version(cv_attribute_id => p_attr_id_tbl(l_attr_count),
										cv_entity_id    => p_entity_id,
										cv_entity		=> p_entity
										)
				loop
					l_version := x.version;
				end loop;

				if(l_version is null) then
					l_version :=0;
				end if;

				for x in c_attr_data_type(cv_attribute_id => p_attr_id_tbl(l_attr_count),
												cv_entity_id    => p_partner_id)
				loop
					l_attr_data_type := x.attr_data_type;
					--l_version := x.version;
					l_sql_text := x.sql_text;
				end loop;


				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				PVX_Utility_PVT.debug_message('Public API: '||l_full_name||'l_version: '||l_version ||
				 'l_attr_data_type: ' || l_attr_data_type);
				 END IF;


				if(l_attr_data_type is null) then
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
					PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - No Attribute Type entities');
					END IF;
				elsif(l_attr_data_type = 'INTERNAL' or l_attr_data_type = 'INT_EXT') then
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
					PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - Internal sql_text entities');
					END IF;
					l_index :=1;
					l_attr_val_tbl			:= g_miss_attr_value_tbl;

					for x in c_enty_attr_int_values(cv_attribute_id => p_attr_id_tbl(l_attr_count),
												cv_entity_id    => p_partner_id)
					loop

						--Attr_Value_Extn
						--attr_value
						l_attr_val_tbl(l_index).attr_value := x.attr_value;
						l_attr_val_tbl(l_index).attr_value_extn := x.Attr_Value_Extn;

					l_index := l_index +1;
					end loop;

					if(l_attr_val_tbl is not null) then
						IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
						PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - inserting Internal ...');
						END IF;
						Upsert_Attr_Value(
							 p_api_version_number         => p_api_version_number
							,p_init_msg_list              => p_init_msg_list
							,p_commit                     => p_commit
							,p_validation_level           => p_validation_level

							,x_return_status              => x_return_status
							,x_msg_count                  => x_msg_count
							,x_msg_data                   => x_msg_data

							,p_attribute_id				  => p_attr_id_tbl(l_attr_count)
							,p_entity                     => p_entity
							,p_entity_id				  => p_entity_id
							,p_version                    => l_version
							,p_attr_val_tbl               => l_attr_val_tbl
						);
					end if;
					IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
						RAISE FND_API.G_EXC_ERROR;
					END IF;

				elsif(l_attr_data_type = 'EXTERNAL' or l_attr_data_type = 'EXT_INT') then
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
					PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - External sql_text entities');
					END IF;
					l_index :=1;
					l_attr_val_tbl			:= g_miss_attr_value_tbl;

					IF (l_sql_text IS NOT NULL OR LENGTH(l_sql_text) <> 0) THEN
						OPEN lc_ext_cursor FOR l_sql_text USING p_attr_id_tbl(l_attr_count),p_entity, p_entity_id;
						LOOP
							FETCH lc_ext_cursor INTO l_attr_value;
							EXIT WHEN lc_ext_cursor%NOTFOUND;
							l_attr_val_tbl(l_index).attr_value := l_attr_value;
							l_attr_val_tbl(l_index).attr_value_extn := null;

							l_index := l_index +1;

						END LOOP;
						CLOSE lc_ext_cursor;
					END IF;

					if(l_attr_val_tbl is not null) then
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
					PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - inserting External ...');
					END IF;
						Upsert_Attr_Value(
							 p_api_version_number         => p_api_version_number
							,p_init_msg_list              => p_init_msg_list
							,p_commit                     => p_commit
							,p_validation_level           => p_validation_level

							,x_return_status              => x_return_status
							,x_msg_count                  => x_msg_count
							,x_msg_data                   => x_msg_data

							,p_attribute_id				  => p_attr_id_tbl(l_attr_count)
							,p_entity                     => p_entity
							,p_entity_id				  => p_entity_id
							,p_version                    => l_version
							,p_attr_val_tbl               => l_attr_val_tbl
						);
					end if;
				else
					IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
					PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - In Else Block');
					END IF;

				END IF;

				l_attr_count := l_attr_count + 1;


			END LOOP; -- end of main loop

		END IF;  -- end of IF (p_attr_id_tbl is not null and p_attr_id_tbl.count > 0  ) THEN


		--
		-- End of API body
		--

		-- Standard check for p_commit
		IF FND_API.to_Boolean( p_commit )
		THEN
			COMMIT WORK;
		END IF;


		-- Debug Message
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - end');
		END IF;

		-- Standard call to get message count and if count is 1, get message info.
		FND_MSG_PUB.Count_And_Get (
			p_count          =>   x_msg_count
			,p_data           =>   x_msg_data
        );

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Copy_Partner_Attr_Values_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
        );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Copy_Partner_Attr_Values_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
        );

	WHEN OTHERS THEN
		ROLLBACK TO Copy_Partner_Attr_Values_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
        );
End Copy_Partner_Attr_Values;

PROCEDURE Upsert_Partner_Types (
    p_api_version_number  	IN   NUMBER
   ,p_init_msg_list             IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                    IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level         	IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status             OUT NOCOPY  VARCHAR2
   ,x_msg_count                 OUT NOCOPY  NUMBER
   ,x_msg_data                  OUT NOCOPY  VARCHAR2
   ,p_entity_id			IN   NUMBER
   ,p_version                   IN   NUMBER		:=0
   ,p_attr_val_tbl              IN   attr_value_tbl_type  := g_miss_attr_value_tbl
    )
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Upsert_Partner_Types';
   l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_api_version_number        CONSTANT NUMBER       := 1.0;
   l_object_version_number     NUMBER       := 1;

   l_attr_val_tbl	       attr_value_tbl_type   := p_attr_val_tbl;
   l_attr_val_rec	       attr_val_rec_type     := g_miss_attr_val_rec;


   -- validation variables
   l_is_primary_partner_type   VARCHAR2(1)    ;
   --initially it would be null, as soon as it finds primary partner type, it becomes 'Y'
   --l_is_primary_partner_type is N --> throw error
   l_are_same_partner_types     VARCHAR2(1)           := 'N';
   --l_are_same_partner_types is Y   --> throw error

  l_attr_value_extn         VARCHAR2(30);
  l_attr_value		    VARCHAR2(500);
  l_primary_partner_type    VARCHAR2(500);
   -- end of validation variables
  l_attr_values_table JTF_VARCHAR2_TABLE_500;
  l_index number := 1;

BEGIN

	-- Standard Start of API savepoint
	SAVEPOINT Upsert_Partner_Types_pub;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
				   p_api_version_number,
				   l_api_name,
				   G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Debug Message
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - start');
	END IF;


	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	PVX_Utility_PVT.debug_message('public API: '||l_full_name||' Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
	END IF;

	--check for required columns

	IF p_entity_id IS NULL THEN
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','p_entity_id');
			  FND_MSG_PUB.add;
		END IF;
		x_return_status := FND_API.g_ret_sts_error;
		RETURN;
	END IF;
	IF p_version IS NULL THEN
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
			  FND_MESSAGE.set_token('COLUMN','p_version');
			  FND_MSG_PUB.add;
		END IF;
		x_return_status := FND_API.g_ret_sts_error;
		RETURN;
	END IF;

	IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
	THEN
		-- Debug message
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			PVX_Utility_PVT.debug_message('public API: '||l_full_name||' - Validate_attr_value');
		END IF;

		--since validation procedures will be done in record level in private API,
		--No need to do any thing here
		--all validations would be done in inner API calls

	END IF;

	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;


	-- Debug Message
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - Before Checking validations......');
	END IF;

	-- At least one partner type should be there as partner type is mandatory
	-- If table is null, error should be thrown.

	IF ( l_attr_val_tbl IS NULL  OR
	    (l_attr_val_tbl IS NOT NULL AND l_attr_val_tbl.count = 0)
	    )
	THEN
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_ATLEASTONE_PRTNR_TYPE');
			  --FND_MESSAGE.set_token('COLUMN','p_attr_val_tbl');
			  FND_MSG_PUB.add;
		END IF;
		x_return_status := FND_API.g_ret_sts_error;
		RETURN;
	END IF;

	--Only one partner type should be there

	IF ( l_attr_val_tbl IS NULL  OR
	    (l_attr_val_tbl IS NOT NULL AND l_attr_val_tbl.count >1 )
	    )
	THEN
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			  FND_MESSAGE.set_name('PV', 'PV_ONLYONE_PRTNR_TYPE');
			  --FND_MESSAGE.set_token('COLUMN','p_attr_val_tbl');
			  FND_MSG_PUB.add;
		END IF;
		x_return_status := FND_API.g_ret_sts_error;
		RETURN;
	END IF;

	--Checking if the partner type attribute value extension is Y or not.

	FOR l_curr_row IN l_attr_val_tbl.first..l_attr_val_tbl.last LOOP
		l_attr_val_rec := l_attr_val_tbl(l_curr_row);
		l_attr_value := l_attr_val_rec.attr_value ;
		l_attr_value_extn := l_attr_val_rec.attr_value_extn;

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			PVX_Utility_PVT.debug_message('Attr Value Rec: attr_value:' || l_attr_value || '::::attr _value_extn:' ||  l_attr_value_extn );
		END IF;

		IF(l_attr_value_extn  is not null and
		   l_attr_value_extn = 'Y' )
		THEN
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				PVX_Utility_PVT.debug_message('Primary Partner Type found');
			END IF;
			l_is_primary_partner_type := 'Y';

		else --if (l_attr_value_extn is null) then
			l_is_primary_partner_type := 'N';
		END IF;
	END LOOP; --FOR l_curr_row IN 1..l_attr_val_tbl.count LOOP

	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('l_is_primary_partner_type:' || l_is_primary_partner_type);
	END IF;

	--Checkif primary partner type exists
	IF( l_is_primary_partner_type  is null or
	   (l_is_primary_partner_type is not null and l_is_primary_partner_type <> 'Y')
	   ) then
		--Throw error no primary partner types is there
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			FND_MESSAGE.set_name('PV', 'PV_ONLYONE_PRTNR_TYPE');
			FND_MSG_PUB.add;
		END IF;
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	/*
	--initialising l_attr_values_table
	l_attr_values_table := JTF_VARCHAR2_TABLE_500();
	FOR l_curr_row IN l_attr_val_tbl.first..l_attr_val_tbl.last LOOP
		l_attr_val_rec := l_attr_val_tbl(l_curr_row);
		l_attr_value := l_attr_val_rec.attr_value ;
		l_attr_value_extn := l_attr_val_rec.attr_value_extn;

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			PVX_Utility_PVT.debug_message('Attr Value Rec: attr_value:' || l_attr_value || '::::attr _value_extn:' ||  l_attr_value_extn );
		END IF;

		IF(l_attr_value_extn  is not null and
		   l_attr_value_extn = 'Y' )
		THEN
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				PVX_Utility_PVT.debug_message('Primary Partner Type found');
			END IF;

			if(l_is_primary_partner_type is null) then
				l_is_primary_partner_type := 'Y';
				l_primary_partner_type := l_attr_value;
			elsif(l_is_primary_partner_type = 'Y' ) then
				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
					PVX_Utility_PVT.debug_message('duplicate primary partner type found');
				END IF;
				--Throw error multiple primary partner types can not be there
				IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
					FND_MESSAGE.set_name('PV', 'PV_NO_MULTI_PRIM_PRTNR_TYPES');
					FND_MSG_PUB.add;
				END IF;
				RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
			end if;
		else --if (l_attr_value_extn is null) then
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
				PVX_Utility_PVT.debug_message('inserting it as additional partner type:'|| l_attr_value);
			END IF;
			l_attr_values_table.extend;
			l_attr_values_table(l_index) := l_attr_value;
			l_index := l_index + 1;
		END IF;


	END LOOP; --FOR l_curr_row IN 1..l_attr_val_tbl.count LOOP

	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('l_is_primary_partner_type:' || l_is_primary_partner_type);
	END IF;

	--Checkif primary partner type exists
	IF( l_is_primary_partner_type  is null or
	   (l_is_primary_partner_type is not null and l_is_primary_partner_type <> 'Y')
	   ) then
		--Throw error no primary partner types is there
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			FND_MESSAGE.set_name('PV', 'PV_NO_PRIM_PRTNR_TYPES');
			FND_MSG_PUB.add;
		END IF;
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	--Checking if any of the additional partner types is primary partner type
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
		PVX_Utility_PVT.debug_message('Checking if any of the additional partner types is primary partner type');
	END IF;


	FOR i in 1 .. l_attr_values_table.count LOOP
		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			PVX_Utility_PVT.debug_message('l_attr_values_table('|| i ||'):' || l_attr_values_table(i) );
		END IF;
		if (l_primary_partner_type = l_attr_values_table(i) ) then
			--Throw error ::
			--The Additional Partner Type selected has already been selected as Primary Partner Type.
			--Please select different partner type
			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
			PVX_Utility_PVT.debug_message('One of the the additional partner types is primary partner type');
			END IF;

			IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
				FND_MESSAGE.set_name('PV', 'PV_INVALID_ADDTNL_PRTNR_TYPES');
			--FND_MESSAGE.set_token('COLUMN','p_attr_val_tbl');
				FND_MSG_PUB.add;
			END IF;
			RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;

	END LOOP;
	*/

       --No errors
       --Call Upsert API now

	Upsert_Attr_Value(
		 p_api_version_number         => p_api_version_number
		,p_init_msg_list              => p_init_msg_list
		,p_commit                     => p_commit
		,p_validation_level           => p_validation_level

		,x_return_status              => x_return_status
		,x_msg_count                  => x_msg_count
		,x_msg_data                   => x_msg_data

		,p_attribute_id		      => 3
		,p_entity                     => 'PARTNER'
		,p_entity_id		      => p_entity_id
		,p_version                    => p_version
		,p_attr_val_tbl               => l_attr_val_tbl
	);


	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;


	-- End of API body
	-- Standard check for p_commit

	IF FND_API.to_Boolean( p_commit )
	THEN
		COMMIT WORK;
	END IF;

	-- Debug Message
	IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
	PVX_Utility_PVT.debug_message('Public API: '||l_full_name||' - end');
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get (
		p_count          =>   x_msg_count
		,p_data           =>   x_msg_data
	);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Upsert_Partner_Types_pub;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Upsert_Partner_Types_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO Upsert_Partner_Types_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );
End Upsert_Partner_Types;



END PV_ENTY_ATTR_VALUE_PUB;

/
