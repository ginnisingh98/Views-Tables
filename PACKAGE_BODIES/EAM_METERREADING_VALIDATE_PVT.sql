--------------------------------------------------------
--  DDL for Package Body EAM_METERREADING_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_METERREADING_VALIDATE_PVT" AS
/* $Header: EAMVMTVB.pls 120.5.12010000.2 2008/10/27 22:37:37 rsinn ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMTVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_METERREADING_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

PROCEDURE CHECK_REQUIRED
 (
	  p_eam_meter_reading_rec      IN EAM_PROCESS_WO_PUB.eam_meter_reading_rec_type
	, x_return_status              OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl             OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
  )IS
      l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
      l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
      l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
      l_status_type	      number;

  BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered EAM_METERREADING_VALIDATE_PVT.CHECK_REQUIRED()..');
	END IF;

	IF p_eam_meter_reading_rec.meter_id IS NULL
		THEN
			IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
				EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('Error as p_eam_meter_reading_rec.meter_id is null in EAM_METERREADING_VALIDATE_PVT.CHECK_REQUIRED()');
			END IF;
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  p_eam_meter_reading_rec.WIP_ENTITY_ID;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_METERID_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status := FND_API.G_RET_STS_ERROR;
  	            return;
	END IF;

	IF p_eam_meter_reading_rec.current_reading IS NULL
		THEN
			IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
				EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('Error as p_eam_meter_reading_rec.current_reading is null in EAM_METERREADING_VALIDATE_PVT.CHECK_REQUIRED()');
			END IF;

		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  p_eam_meter_reading_rec.WIP_ENTITY_ID;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_CURRENTREAD_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status := FND_API.G_RET_STS_ERROR;
  	            return;
	END IF;

	IF p_eam_meter_reading_rec.wo_end_date IS NULL
		THEN
			IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
				EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('Error as p_eam_meter_reading_rec.wo_end_date is null in EAM_METERREADING_VALIDATE_PVT.CHECK_REQUIRED()');
			END IF;

		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  p_eam_meter_reading_rec.WIP_ENTITY_ID;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_ENDDATE_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status := FND_API.G_RET_STS_ERROR;
  	            return;
	END IF;

	IF p_eam_meter_reading_rec.reset_flag IS NOT NULL AND p_eam_meter_reading_rec.value_before_reset IS NULL
		THEN
			IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
				EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('Last Condition failed in EAM_METERREADING_VALIDATE_PVT.CHECK_REQUIRED()');
			END IF;

		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  p_eam_meter_reading_rec.WIP_ENTITY_ID;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_VALBRESET_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status := FND_API.G_RET_STS_ERROR;
  	            return;
	END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished EAM_METERREADING_VALIDATE_PVT.CHECK_REQUIRED()..Successfully');
	END IF;

  END CHECK_REQUIRED;

PROCEDURE MANDATORY_ENTERED (
	     p_wip_entity_id 		IN NUMBER
	   , p_instance_id		IN VARCHAR2
	   , p_eam_meter_reading_tbl  IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
	   , p_work_order_cmpl_date   IN DATE
           , x_return_status            OUT NOCOPY  VARCHAR2
           , x_man_reading_enter        OUT NOCOPY BOOLEAN
   )IS

   counter_id_tbl EAM_METERREADING_VALIDATE_PVT.counter_id_tbl_type;

   mandatory_counter_id_tbl EAM_METERREADING_VALIDATE_PVT.counter_id_tbl_type;

   is_meter_mandatory	BOOLEAN :=FALSE;

   loop_var NUMBER := 1;

   flag BOOLEAN :=FALSE;
   l_no_of_reading NUMBER;
   L_SOURCE_METER_ID number;
   L_SOURCE_METER_ID_P number;
  BEGIN

	x_man_reading_enter	:=TRUE;
	x_return_status		:= FND_API.G_RET_STS_SUCCESS;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered EAM_METERREADING_VALIDATE_PVT.MANDATORY_ENTERED()..');
	END IF;

/*
	Before processing the meter readings we will query eam_asset_meters table to get list of
	all meters associated with asset number. Then Eam_Meters_Util.is_meter_reading_mandatory
	(wip_entity_id, meter_id) is called to identify the list of meters, which are mandatory for
	work order completion. Then the input table of meters will be scanned to check if mandatory
	meter readings are entered. If some reading is not entered then throw error
*/


	/* SELECT  counter_id  bulk collect into counter_id_tbl
	  FROM 	csi_counter_associations cca
	 WHERE  source_object_id =     p_instance_id
	 and SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1)
	AND nvl(cca.end_date_active, SYSDATE+1);  */

  SELECT  cca.counter_id  bulk collect into counter_id_tbl                                     -- Bug 7323234
  FROM 	csi_counter_associations cca, csi_counters_b ccb
  WHERE  source_object_id =  p_instance_id
  AND SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1)
    and nvl(cca.end_date_active, SYSDATE+1)
  AND SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1)
    and nvl(ccb.end_date_active, SYSDATE+1)
  AND cca.counter_id = ccb.counter_id;


	 IF counter_id_tbl.COUNT > 0 THEN

		FOR I IN counter_id_tbl.FIRST..counter_id_tbl.LAST LOOP
    EAM_ERROR_MESSAGE_PVT.Write_Debug('Id of Meters' || I ||  'associated: ' || counter_id_tbl(I));
			is_meter_mandatory := Eam_Meters_Util.is_meter_reading_mandatory(
				p_wip_entity_id		=> p_wip_entity_id ,
				p_meter_id		=> counter_id_tbl(I)
			);

			IF is_meter_mandatory = TRUE THEN
      EAM_ERROR_MESSAGE_PVT.Write_Debug('This meter is mandatory! : ' || counter_id_tbl(I));
				mandatory_counter_id_tbl(loop_var) := counter_id_tbl(I);
				loop_var := loop_var + 1;
			END IF ;
		END LOOP;
	 END IF;

	IF mandatory_counter_id_tbl.COUNT > 0 THEN
		FOR J IN mandatory_counter_id_tbl.FIRST..mandatory_counter_id_tbl.LAST LOOP

			flag :=FALSE;

			select count(*) into l_no_of_reading
			from CSI_COUNTER_READINGS
			 where counter_id = mandatory_counter_id_tbl(J)
			   and value_timestamp  = p_work_order_cmpl_date ;
			   --and DISABLED_FLAG = 'N';

			IF L_NO_OF_READING = 0 THEN
				    /* WHEN COMING FROM WIRELESS,P_EAM_METER_READING_TBL HAS ALL THE SOURCE COUNTER ID'S
				    Added for Issue # 4 of Bug # 4932595*/
				    IF P_EAM_METER_READING_TBL.COUNT >0 THEN
				-- GET THE SOURE METER OF THE MANDATORY METER
					SELECT SOURCE_COUNTER_ID INTO L_SOURCE_METER_ID FROM CSI_COUNTER_RELATIONSHIPS WHERE OBJECT_COUNTER_ID = MANDATORY_COUNTER_ID_TBL(J)
					AND SYSDATE BETWEEN NVL(ACTIVE_START_DATE(+), SYSDATE-1) AND  NVL(ACTIVE_END_DATE(+), SYSDATE+1);
					-- LOOP THROUGH P_EAM_METER_READING_TBL TO CHECK WHETHER READINGS ARE ENTERED OR NOT
					FOR K IN P_EAM_METER_READING_TBL.FIRST..P_EAM_METER_READING_TBL.LAST LOOP
						-- IF SOURCE METER ID IS NULL THEN COMPARE P_EAM_METER_READING_TBL(K)
						IF  NVL(L_SOURCE_METER_ID,P_EAM_METER_READING_TBL(K).METER_ID) <> MANDATORY_COUNTER_ID_TBL(J) THEN
						    -- IF P_EAM_METER_READING_TBL HAS AN NON MANDATORY READING
						    SELECT SOURCE_COUNTER_ID INTO L_SOURCE_METER_ID_P FROM CSI_COUNTER_RELATIONSHIPS WHERE OBJECT_COUNTER_ID = P_EAM_METER_READING_TBL(K).METER_ID
						    AND SYSDATE BETWEEN NVL(ACTIVE_START_DATE(+), SYSDATE-1) AND  NVL(ACTIVE_END_DATE(+), SYSDATE+1);
						    IF L_SOURCE_METER_ID_P IS NOT NULL THEN
							FLAG := TRUE;
						    END IF;
						END IF;
					END LOOP;
				    ELSE
							X_MAN_READING_ENTER := FALSE;
							X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
							RETURN;
				    END IF;

					IF FLAG THEN
						    X_MAN_READING_ENTER := FALSE;
							X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
						RETURN;
					     END IF;
			END IF;

		END LOOP;
	END IF;
 EXCEPTION
	WHEN OTHERS THEN
	IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.WRITE_DEBUG('Exception FROM EAM_METERREADING_VALIDATE_PVT.MANDATORY_ENTERED()');
	END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished EAM_METERREADING_VALIDATE_PVT.MANDATORY_ENTERED()..');
	END IF;
  END MANDATORY_ENTERED;

END EAM_METERREADING_VALIDATE_PVT;

/
