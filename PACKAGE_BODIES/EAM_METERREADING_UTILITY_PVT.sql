--------------------------------------------------------
--  DDL for Package Body EAM_METERREADING_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_METERREADING_UTILITY_PVT" AS
/* $Header: EAMVMTUB.pls 120.9 2006/06/16 13:31:30 sshahid noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMTUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_METERREADING_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

PROCEDURE Perform_Writes
(
	p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_meter_reading_rec_type
      , x_return_status                 OUT NOCOPY  VARCHAR2
     ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
) IS
BEGIN
	null;
END Perform_Writes;

PROCEDURE INSERT_ROW
(
	  p_eam_meter_reading_tbl  IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
   	 , p_eam_counter_prop_tbl  IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
	 , x_eam_meter_reading_tbl OUT NOCOPY EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
 	 , x_eam_counter_prop_tbl  OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
	 , x_return_status         OUT NOCOPY  VARCHAR2
	 , x_mesg_token_tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
) IS
	l_meter_reading_rec	 EAM_MeterReading_PUB.Meter_Reading_Rec_Type;
	l_counter_properties_tbl EAM_MeterReading_PUB.Ctr_Property_readings_Tbl;
	l_count			 NUMBER;

	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(2000);
	l_return_status		VARCHAR2(1);
	l_meter_reading_id	NUMBER;
	l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;


BEGIN
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered EAM_METERREADING_UTILITY_PVT.INSERT_ROW()..');
	END IF;

	x_return_status         := FND_API.G_RET_STS_SUCCESS;
	x_eam_meter_reading_tbl := p_eam_meter_reading_tbl;
	x_eam_counter_prop_tbl	:= p_eam_counter_prop_tbl;

	IF p_eam_meter_reading_tbl.COUNT > 0 THEN
		FOR ii in p_eam_meter_reading_tbl.FIRST..p_eam_meter_reading_tbl.LAST LOOP



			l_meter_reading_rec.meter_id			:= p_eam_meter_reading_tbl(ii).METER_ID;
			l_meter_reading_rec.meter_reading_id		:= p_eam_meter_reading_tbl(ii).METER_READING_ID;
			l_meter_reading_rec.current_reading		:= p_eam_meter_reading_tbl(ii).CURRENT_READING;
			l_meter_reading_rec.current_reading_date	:= p_eam_meter_reading_tbl(ii).current_reading_date;
			l_meter_reading_rec.reset_flag			:= p_eam_meter_reading_tbl(ii).RESET_FLAG;
			l_meter_reading_rec.wip_entity_id		:= p_eam_meter_reading_tbl(ii).WIP_ENTITY_ID;

      			l_meter_reading_rec.source_line_id		:= p_eam_meter_reading_tbl(ii).SOURCE_LINE_ID;
			l_meter_reading_rec.source_code			:= p_eam_meter_reading_tbl(ii).SOURCE_CODE;
			l_meter_reading_rec.wo_entry_fake_flag		:= p_eam_meter_reading_tbl(ii).WO_ENTRY_FAKE_FLAG;

			l_meter_reading_rec.attribute_category		:= p_eam_meter_reading_tbl(ii).ATTRIBUTE_CATEGORY;
			l_meter_reading_rec.attribute1			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE1;
			l_meter_reading_rec.attribute2			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE2;
			l_meter_reading_rec.attribute3			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE3;
			l_meter_reading_rec.attribute4			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE4;
			l_meter_reading_rec.attribute5			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE5;
			l_meter_reading_rec.attribute6			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE6;
			l_meter_reading_rec.attribute7			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE7;
			l_meter_reading_rec.attribute8			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE8;
			l_meter_reading_rec.attribute9			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE9;
			l_meter_reading_rec.attribute10			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE10;
			l_meter_reading_rec.attribute11			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE11;
			l_meter_reading_rec.attribute12			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE12;
			l_meter_reading_rec.attribute13			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE13;
			l_meter_reading_rec.attribute14			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE14;
			l_meter_reading_rec.attribute15			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE15;
			l_meter_reading_rec.attribute16            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE16;
			l_meter_reading_rec.attribute17			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE17;
			l_meter_reading_rec.attribute18            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE18;
			l_meter_reading_rec.attribute19            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE19;
			l_meter_reading_rec.attribute20            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE20;
			l_meter_reading_rec.attribute21			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE21;
			l_meter_reading_rec.attribute22            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE22;
			l_meter_reading_rec.attribute23            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE23;
			l_meter_reading_rec.attribute24            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE24;
			l_meter_reading_rec.attribute25			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE25;
			l_meter_reading_rec.attribute26            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE26;
			l_meter_reading_rec.attribute27            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE27;
			l_meter_reading_rec.attribute28            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE28;
			l_meter_reading_rec.attribute29			:= p_eam_meter_reading_tbl(ii).ATTRIBUTE29;
			l_meter_reading_rec.attribute30            	:= p_eam_meter_reading_tbl(ii).ATTRIBUTE30;

			l_count := 1;
			l_counter_properties_tbl.delete;

			IF p_eam_counter_prop_tbl.COUNT > 0 THEN

				for jj in p_eam_counter_prop_tbl.FIRST..p_eam_counter_prop_tbl.LAST LOOP
					IF l_meter_reading_rec.meter_id = p_eam_counter_prop_tbl(jj).counter_id THEN

						l_counter_properties_tbl(l_count).counter_property_id     :=	p_eam_counter_prop_tbl(jj).property_id;
						l_counter_properties_tbl(l_count).property_value          :=	p_eam_counter_prop_tbl(jj).property_value;
						l_counter_properties_tbl(l_count).value_timestamp         :=	p_eam_counter_prop_tbl(jj).value_timestamp;
						l_counter_properties_tbl(l_count).attribute_category      :=	p_eam_counter_prop_tbl(jj).attribute_category;
						l_counter_properties_tbl(l_count).attribute1              :=	p_eam_counter_prop_tbl(jj).attribute1;
						l_counter_properties_tbl(l_count).attribute2              :=	p_eam_counter_prop_tbl(jj).attribute2;
						l_counter_properties_tbl(l_count).attribute3              :=	p_eam_counter_prop_tbl(jj).attribute3;
						l_counter_properties_tbl(l_count).attribute4              :=	p_eam_counter_prop_tbl(jj).attribute4;
						l_counter_properties_tbl(l_count).attribute5              :=	p_eam_counter_prop_tbl(jj).attribute5;
						l_counter_properties_tbl(l_count).attribute6              :=	p_eam_counter_prop_tbl(jj).attribute6;
						l_counter_properties_tbl(l_count).attribute7              :=	p_eam_counter_prop_tbl(jj).attribute7;
						l_counter_properties_tbl(l_count).attribute8              :=	p_eam_counter_prop_tbl(jj).attribute8;
						l_counter_properties_tbl(l_count).attribute9              :=	p_eam_counter_prop_tbl(jj).attribute9;
						l_counter_properties_tbl(l_count).attribute10             :=	p_eam_counter_prop_tbl(jj).attribute10;
						l_counter_properties_tbl(l_count).attribute11             :=	p_eam_counter_prop_tbl(jj).attribute11;
						l_counter_properties_tbl(l_count).attribute12             :=	p_eam_counter_prop_tbl(jj).attribute12;
						l_counter_properties_tbl(l_count).attribute13             :=	p_eam_counter_prop_tbl(jj).attribute13;
						l_counter_properties_tbl(l_count).attribute14             :=	p_eam_counter_prop_tbl(jj).attribute14;
						l_counter_properties_tbl(l_count).attribute15             :=	p_eam_counter_prop_tbl(jj).attribute15;
						l_counter_properties_tbl(l_count).migrated_flag           :=	p_eam_counter_prop_tbl(jj).migrated_flag;

						l_count:=l_count+1;

					END IF;
				END LOOP;
			END IF;

      	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_METERREADING_PUB.create_meter_reading().. from EAM_METERREADING_UTILITY_PVT.INSERT_ROW()');
	END IF;
			EAM_METERREADING_PUB.create_meter_reading(

				p_api_version			 =>     1.0,
				x_msg_count			 =>	l_msg_count,
				x_msg_data			 =>     l_msg_data,
				x_return_status			 =>     l_return_status,
				x_meter_reading_id		 =>     l_meter_reading_id,
				p_meter_reading_rec		 =>     l_meter_reading_rec,
				p_value_before_reset		 =>     p_eam_meter_reading_tbl(ii).VALUE_BEFORE_RESET,
				p_ignore_warnings		 =>     p_eam_meter_reading_tbl(ii).IGNORE_METER_WARNINGS,
				p_ctr_property_readings_tbl	 =>     l_counter_properties_tbl
				);
      	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Returned from EAM_METERREADING_PUB.create_meter_reading() with return_status : ' || l_return_status);
	END IF;
			FOR MM IN x_eam_meter_reading_tbl.FIRST..x_eam_meter_reading_tbl.LAST LOOP
				IF x_eam_meter_reading_tbl(MM).meter_id = l_meter_reading_rec.meter_id THEN
					x_eam_meter_reading_tbl(MM).return_status := l_return_status;
				END IF;
			END LOOP;

			IF x_eam_counter_prop_tbl.COUNT > 0 THEN
				FOR NN IN x_eam_counter_prop_tbl.FIRST..x_eam_counter_prop_tbl.LAST LOOP
					IF x_eam_counter_prop_tbl(NN).counter_id = l_meter_reading_rec.meter_id THEN
						x_eam_counter_prop_tbl(NN).return_status := l_return_status;
					END IF;
				END LOOP;
			END IF;

			IF l_return_status <> 'S' THEN

			IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
				EAM_ERROR_MESSAGE_PVT.Write_Debug('Error returned from EAM_METERREADING_PUB.create_meter_reading()..: ' || l_msg_data);
			END IF;

				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name       => NULL
				 , p_message_text       => l_msg_data
				 , x_mesg_token_Tbl     => x_mesg_token_tbl
				);

				x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
				return;
			END IF;
		END LOOP; -- Meter Loop
	END IF; -- End of Meter Reading Count > 0
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished EAM_METERREADING_UTILITY_PVT.INSERT_ROW()..Successfully');
	END IF;
END INSERT_ROW;

PROCEDURE ENABLE_SOURCE_METER
(
	   p_eam_wo_comp_mr_read_tbl  IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
   	 , x_eam_wo_comp_mr_read_tbl  OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
	 , x_return_status         OUT NOCOPY  VARCHAR2
	 , x_mesg_token_tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
)IS
	l_return_status VARCHAR2(1);
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(2000);
BEGIN
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered EAM_METERREADING_UTILITY_PVT.ENABLE_SOURCE_METER()..');
	END IF;

	x_return_status		  := FND_API.G_RET_STS_SUCCESS;
	x_eam_wo_comp_mr_read_tbl := p_eam_wo_comp_mr_read_tbl;

	IF p_eam_wo_comp_mr_read_tbl.COUNT > 0 THEN
		 FOR ii in p_eam_wo_comp_mr_read_tbl.FIRST..p_eam_wo_comp_mr_read_tbl.LAST LOOP

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_METER_PUB.update_meter().. from EAM_METERREADING_UTILITY_PVT.ENABLE_SOURCE_METER()');
	END IF;

			EAM_METER_PUB.update_meter
			(
				p_api_version		=> 1.0,
				p_meter_id		=> p_eam_wo_comp_mr_read_tbl(ii).meter_issued_serial,
				p_source_meter_id	=> p_eam_wo_comp_mr_read_tbl(ii).source_meter,
				p_factor => 1, -- Added for bug #5255445
				x_return_status		=> l_return_status,
				x_msg_count		=> l_msg_count,
				x_msg_data		=> l_msg_data
			);
      	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Returned from EAM_METER_PUB.update_meter() with return_status : ' || l_return_status);
	END IF;
			x_eam_wo_comp_mr_read_tbl(ii).return_status := l_return_status;

			IF l_return_status <> 'S' THEN

			IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
				EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('ERROR RETURNED FROM EAM_METER_PUB.update_meter().. : ' || l_msg_data);
			END IF;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name       => NULL
				 , p_message_text       => l_msg_data
				 , x_mesg_token_Tbl     => x_mesg_token_tbl
				);

				x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
				return;
			END IF;
		END LOOP;
	END IF;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished EAM_METERREADING_UTILITY_PVT.ENABLE_SOURCE_METER()..Successfully');
	END IF;

END ENABLE_SOURCE_METER;

PROCEDURE DISABLE_COUNTER_HIERARCHY
(
	   p_eam_wo_comp_rebuild_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
	 , p_subinventory_id             IN VARCHAR2
         , p_wip_entity_id               IN NUMBER := NULL
         , x_eam_wo_comp_rebuild_tbl     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
	 , x_return_status         OUT NOCOPY  VARCHAR2
	 , x_mesg_token_tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
)IS
	l_return_status		VARCHAR2(1);
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(2000);
	TYPE counter_tbl IS   TABLE OF INTEGER INDEX BY BINARY_INTEGER;
	l_counter_tbl         counter_tbl;
	l_instance_id		NUMBER;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_count			NUMBER := 0;

        /* Bug # 5255459 : Disable meter hiearchy for instances which are already removed */
	CURSOR cur_replaced_instance IS
        SELECT wdj.maintenance_object_id instance_id
 	  FROM wip_discrete_jobs wdj
	 WHERE wdj.maintenance_object_type = 3 AND wdj.manual_rebuild_flag = 'N'
	   AND wdj.parent_wip_entity_id = p_wip_entity_id;

BEGIN
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered EAM_METERREADING_UTILITY_PVT.DISABLE_COUNTER_HIERARCHY()..');
	END IF;

	x_return_status			:= FND_API.G_RET_STS_SUCCESS;
	x_eam_wo_comp_rebuild_tbl	:= p_eam_wo_comp_rebuild_tbl;

	l_eam_wo_comp_rebuild_tbl := p_eam_wo_comp_rebuild_tbl;
        l_count := p_eam_wo_comp_rebuild_tbl.count;

	FOR i in cur_replaced_instance LOOP
 	   l_count := l_count + 1;
	   l_eam_wo_comp_rebuild_tbl(l_count).wip_entity_id := p_wip_entity_id;
	   l_eam_wo_comp_rebuild_tbl(l_count).instance_id_removed := i.instance_id;
	   /* set org as -1, so that csi_eam_interface_grp.rebuildable_return is not called */
	   l_eam_wo_comp_rebuild_tbl(l_count).organization_id := -1;
	END LOOP;

	IF l_count > 0 THEN
		 FOR ii in l_eam_wo_comp_rebuild_tbl.FIRST..l_eam_wo_comp_rebuild_tbl.LAST LOOP

			l_counter_tbl.delete;

			SELECT maintenance_object_id into l_instance_id
			  FROM wip_discrete_jobs wdj
			 WHERE wip_entity_id = l_eam_wo_comp_rebuild_tbl(ii).wip_entity_id;

		        SELECT  cca.counter_id
			  BULK COLLECT INTO l_counter_tbl
			  FROM CSI_COUNTER_ASSOCIATIONS cca
			 WHERE cca.source_object_id =  l_eam_wo_comp_rebuild_tbl(ii).instance_id_removed
			   AND (cca.end_date_active IS NULL OR cca.end_date_active > sysdate)
			   AND exists
			   (
			   SELECT '1'
			     FROM CSI_COUNTER_ASSOCIATIONS ccas, CSI_COUNTER_RELATIONSHIPS ccr
                            WHERE ccas.source_object_id =  l_instance_id
			      AND (ccas.end_date_active IS NULL OR ccas.end_date_active > sysdate)
			      AND ccr.object_counter_id = cca.COUNTER_ID
			      AND ccr.source_counter_id = ccas.counter_id
			   );

			 IF  l_counter_tbl.COUNT > 0 THEN
				FOR K IN l_counter_tbl.FIRST..l_counter_tbl.LAST LOOP

      	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_METER_PUB.update_meter().. from EAM_METERREADING_UTILITY_PVT.DISABLE_COUNTER_HIERARCHY()');
	END IF;
					EAM_METER_PUB.update_meter
					(
						p_api_version		=> 1.0,
						p_meter_id		=> l_counter_tbl(K),
						p_source_meter_id	=> null,
						p_from_eam		=> 'Y',
						x_return_status		=> l_return_status,
						x_msg_count		=> l_msg_count,
						x_msg_data		=> l_msg_data
					);
      	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Returned from EAM_METER_PUB.update_meter() with return_status : ' || l_return_status);
	END IF;

					x_eam_wo_comp_rebuild_tbl(ii).return_status := l_return_status;

					IF l_return_status <> 'S' THEN

	IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('ERROR RETURNED FROM EAM_METER_PUB.update_meter()..: ' || l_msg_data);
	END IF;
						EAM_ERROR_MESSAGE_PVT.Add_Error_Token
						(  p_message_name       => NULL
						 , p_message_text       => l_msg_data
						 , x_mesg_token_Tbl     => x_mesg_token_tbl
						);

						x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
						return;
					END IF;
				END LOOP;
			 END IF;
		IF p_subinventory_id IS NULL AND l_eam_wo_comp_rebuild_tbl(ii).organization_id <> -1 THEN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling csi_eam_interface_grp.rebuildable_return().. from EAM_METERREADING_UTILITY_PVT.DISABLE_COUNTER_HIERARCHY()');
	END IF;
			csi_eam_interface_grp.rebuildable_return
			(
			     p_wip_entity_id    => l_eam_wo_comp_rebuild_tbl(ii).wip_entity_id ,
			     p_organization_id  => l_eam_wo_comp_rebuild_tbl(ii).organization_id ,
			     p_instance_id      => l_eam_wo_comp_rebuild_tbl(ii).instance_id_removed ,
			     x_return_status    => l_msg_data ,
			     x_error_message    => l_msg_count
			);
      	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Returned from csi_eam_interface_grp.rebuildable_return() with return_status : ' || l_msg_data);
	END IF;

		END IF;


		END LOOP;
	END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished EAM_METERREADING_UTILITY_PVT.DISABLE_COUNTER_HIERARCHY()..Successfully');
	END IF;

END DISABLE_COUNTER_HIERARCHY;

PROCEDURE UPDATE_ACTIVITY
(
	 p_eam_wo_comp_rebuild_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_eam_wo_comp_rebuild_tbl     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
	 , x_return_status         OUT NOCOPY  VARCHAR2
	 , x_mesg_token_tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
)IS

	l_return_status			VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(2000);
	l_scheduled_start_date		DATE;
	l_scheduled_completion_date	DATE;
	l_primary_item_id		NUMBER;
	l_Mesg_Token_Tbl		EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_out_Mesg_Token_Tbl		EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_Token_Tbl			EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered EAM_METERREADING_UTILITY_PVT.UPDATE_ACTIVITY()..');
	END IF;

	x_return_status		  := FND_API.G_RET_STS_SUCCESS;
	x_eam_wo_comp_rebuild_tbl := p_eam_wo_comp_rebuild_tbl;

	IF p_eam_wo_comp_rebuild_tbl.COUNT > 0 THEN
		 FOR ii in p_eam_wo_comp_rebuild_tbl.FIRST..p_eam_wo_comp_rebuild_tbl.LAST LOOP
			IF p_eam_wo_comp_rebuild_tbl(ii).ACTIVITY_ID IS NOT NULL THEN

				SELECT REQUESTED_START_DATE,due_date,primary_item_id
				  INTO l_scheduled_start_date,l_scheduled_completion_date,l_primary_item_id
				  FROM wip_discrete_jobs
				 WHERE wip_entity_id = p_eam_wo_comp_rebuild_tbl(ii).rebuild_wip_entity_id
				   AND organization_id = p_eam_wo_comp_rebuild_tbl(ii).organization_id;

				IF l_primary_item_id IS NULL THEN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_PROCESS_WO_PUB.EXPLODE_ACTIVITY().. from EAM_METERREADING_UTILITY_PVT.UPDATE_ACTIVITY()');
	END IF;

					EAM_PROCESS_WO_PUB.EXPLODE_ACTIVITY
					(
					   p_organization_id         => p_eam_wo_comp_rebuild_tbl(ii).organization_id
					 , p_asset_activity_id       => p_eam_wo_comp_rebuild_tbl(ii).activity_id
					 , p_wip_entity_id           => p_eam_wo_comp_rebuild_tbl(ii).rebuild_wip_entity_id
					 , p_start_date              => l_scheduled_start_date
					 , p_completion_date         => l_scheduled_completion_date
					 , x_return_status           => l_return_status
					 , x_msg_count               => l_msg_count
					 , x_msg_data                => l_msg_data
					 );
      	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Returned from EAM_PROCESS_WO_PUB.EXPLODE_ACTIVITY() with return_status : ' || l_return_status);
	END IF;

					 x_eam_wo_comp_rebuild_tbl(ii).return_status := l_return_status;

					IF l_return_status <> 'S' THEN
	IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('ERROR RETURNED FROM EAM_PROCESS_WO_PUB.EXPLODE_ACTIVITY()..: ' || l_msg_data);
	END IF;
						EAM_ERROR_MESSAGE_PVT.Add_Error_Token
						(  p_message_name       => NULL
						 , p_message_text       => l_msg_data
						 , x_mesg_token_Tbl     => x_mesg_token_tbl
						);

						x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
						return;
					END IF;
				ELSE

					 x_eam_wo_comp_rebuild_tbl(ii).return_status := l_return_status;
					l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
					l_token_tbl(1).token_value :=  p_eam_wo_comp_rebuild_tbl(ii).WIP_ENTITY_ID;

					    l_out_mesg_token_tbl  := l_mesg_token_tbl;
					    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
					    (  p_message_name	=> 'EAM_WCMP_ACT_EXISTS'
					     , p_token_tbl	=> l_Token_tbl
					     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
					     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
					     );
					    l_mesg_token_tbl      := l_out_mesg_token_tbl;
					    x_mesg_token_tbl	  := l_mesg_token_tbl ;
					    x_return_status := FND_API.G_RET_STS_ERROR;
					    return;
				END IF;

			END IF;
		END LOOP;
	END IF;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished EAM_METERREADING_UTILITY_PVT.UPDATE_ACTIVITY()..Successfully');
	END IF;

END UPDATE_ACTIVITY;

PROCEDURE UPDATE_GENEALOGY
(
	 p_eam_wo_comp_rebuild_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_eam_wo_comp_rebuild_tbl     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_return_status               OUT NOCOPY  VARCHAR2
       , x_mesg_token_tbl              OUT NOCOPY  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
)IS
	l_return_status		VARCHAR2(1);
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(2000);
	l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered EAM_METERREADING_UTILITY_PVT.UPDATE_GENEALOGY()..');
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_eam_wo_comp_rebuild_tbl := p_eam_wo_comp_rebuild_tbl;

	IF p_eam_wo_comp_rebuild_tbl.COUNT > 0 THEN
			 FOR ii in p_eam_wo_comp_rebuild_tbl.FIRST..p_eam_wo_comp_rebuild_tbl.LAST LOOP

			   IF p_eam_wo_comp_rebuild_tbl(ii).uninst_serial_removed IS NOT NULL THEN

      	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling wip_eam_genealogy_pvt.update_eam_genealogy().. from EAM_METERREADING_UTILITY_PVT.UPDATE_GENEALOGY()');
	END IF;

			 	wip_eam_genealogy_pvt.update_eam_genealogy
				(
					p_api_version => 1.0,
					p_object_type => 2,
					p_serial_number => p_eam_wo_comp_rebuild_tbl(ii).UNINST_SERIAL_REMOVED,
					p_inventory_item_id => p_eam_wo_comp_rebuild_tbl(ii).ITEM_REMOVED,
					p_organization_id => p_eam_wo_comp_rebuild_tbl(ii).ORGANIZATION_ID,
					p_genealogy_type => 5, /* asset item relationship*/
					p_end_date_active => sysdate,
					x_return_status => l_return_status,
					x_msg_count => l_msg_count,
					x_msg_data => l_msg_data
				);
      	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Returned from wip_eam_genealogy_pvt.update_eam_genealogy() with return_status : ' || l_return_status);
	END IF;

				x_eam_wo_comp_rebuild_tbl(ii).return_status := l_return_status;

				IF l_return_status <> 'S' THEN

	IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('ERROR RETURNED FROM wip_eam_genealogy_pvt.update_eam_genealogy()..: ' || l_msg_data);
	END IF;
					EAM_ERROR_MESSAGE_PVT.Add_Error_Token
					(  p_message_name       => NULL
					 , p_message_text       => l_msg_data
					 , x_mesg_token_Tbl     => x_mesg_token_tbl
					);

					x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
					return;
				END IF;
			   END IF;
			END LOOP;
	END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished EAM_METERREADING_UTILITY_PVT.UPDATE_GENEALOGY()..Successfully');
	END IF;

END UPDATE_GENEALOGY;


PROCEDURE UPDATE_LAST_SERVICE_READING
(
	  p_eam_meter_reading_tbl  IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
   	 , x_eam_meter_reading_tbl OUT NOCOPY EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
 	 , x_return_status         OUT NOCOPY  VARCHAR2
	 , x_mesg_token_tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
)IS
	l_return_status		VARCHAR2(1);
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(2000);
	l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered EAM_METERREADING_UTILITY_PVT.UPDATE_LAST_SERVICE_READING()..');
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_eam_meter_reading_tbl	:= p_eam_meter_reading_tbl;

	FOR I IN p_eam_meter_reading_tbl.FIRST..p_eam_meter_reading_tbl.LAST LOOP

		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
			EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_METERS_UTIL.update_last_service_reading_wo().. from EAM_METERREADING_UTILITY_PVT.UPDATE_LAST_SERVICE_READING()');
		END IF;

			 EAM_METERS_UTIL.update_last_service_reading_wo(
			   p_wip_entity_id      => p_eam_meter_reading_tbl(i).wip_entity_id ,
			   p_meter_id		=> p_eam_meter_reading_tbl(i).meter_id ,
			   p_meter_reading	=> p_eam_meter_reading_tbl(i).meter_reading_id ,
			   p_wo_end_date	=> p_eam_meter_reading_tbl(i).wo_end_date ,
			   x_return_status      => l_return_status,
			   x_msg_count          => l_msg_count,
			   x_msg_data           => l_msg_data
			);
      	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Returned from EAM_METERS_UTIL.update_last_service_reading_wo() with return_status : ' || l_return_status);
	END IF;

			x_eam_meter_reading_tbl(i).return_status := l_return_status;

			IF l_return_status <> 'S' THEN
	IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('ERROR RETURNED FROM EAM_METERS_UTIL.update_last_service_reading_wo()..: ' || l_msg_data);
	END IF;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name       => NULL
				 , p_message_text       => l_msg_data
				 , x_mesg_token_Tbl     => x_mesg_token_tbl
				);

				x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
				return;
			END IF;
	END LOOP;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished EAM_METERREADING_UTILITY_PVT.UPDATE_LAST_SERVICE_READING()..Successfully');
	END IF;
END UPDATE_LAST_SERVICE_READING;

PROCEDURE UPDATE_REBUILD_WORK_ORDER
(
	 p_eam_wo_comp_rebuild_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_eam_wo_comp_rebuild_tbl     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
       , x_return_status	       OUT NOCOPY  VARCHAR2
       , x_mesg_token_tbl	       OUT NOCOPY  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
)IS
BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered EAM_METERREADING_UTILITY_PVT.UPDATE_REBUILD_WORK_ORDER()..');
	END IF;

	x_return_status			:= FND_API.G_RET_STS_SUCCESS;
	x_eam_wo_comp_rebuild_tbl	:= p_eam_wo_comp_rebuild_tbl;

	FOR I IN p_eam_wo_comp_rebuild_tbl.FIRST..p_eam_wo_comp_rebuild_tbl.LAST LOOP

		UPDATE wip_discrete_jobs
		   SET maintenance_object_type = 3 ,
		       maintenance_object_id = p_eam_wo_comp_rebuild_tbl(i).instance_id_removed,
		       rebuild_serial_number = ( select serial_number
						   from csi_item_instances
						  where instance_id = p_eam_wo_comp_rebuild_tbl(i).instance_id_removed
						)
		 WHERE wip_entity_id = p_eam_wo_comp_rebuild_tbl(i).rebuild_wip_entity_id;

	END LOOP;

EXCEPTION
	WHEN OTHERS THEN
	IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('Exception in EAM_METERREADING_UTILITY_PVT.UPDATE_REBUILD_WORK_ORDER()');
	END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished EAM_METERREADING_UTILITY_PVT.UPDATE_REBUILD_WORK_ORDER()..Successfully');
	END IF;

END UPDATE_REBUILD_WORK_ORDER;

END EAM_METERREADING_UTILITY_PVT;

/
