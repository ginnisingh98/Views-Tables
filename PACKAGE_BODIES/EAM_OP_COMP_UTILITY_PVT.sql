--------------------------------------------------------
--  DDL for Package Body EAM_OP_COMP_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OP_COMP_UTILITY_PVT" AS
/* $Header: EAMVOCUB.pls 120.2 2006/06/16 14:57:00 gbadoni noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVOCUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_OP_COMP_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/
 G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_OP_COMP_UTILITY_PVT';

PROCEDURE Perform_Writes
 (
	  p_eam_op_comp_rec	IN  EAM_PROCESS_WO_PUB.eam_op_comp_rec_type
	, x_return_status       OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
  )
IS
	  l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered Package EAM_OP_COMP_UTILITY_PVT.Perform_Writes procedure..'); END IF;

	IF p_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE OR
	   p_eam_op_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE
	THEN
		Insert_Row
		(  p_eam_op_comp_rec    => p_eam_op_comp_rec
		 , x_mesg_token_Tbl     => x_mesg_token_tbl
		 , x_return_Status      => l_return_status
		 );
	END IF;

	x_return_status := l_return_status;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Exiting Package EAM_OP_COMP_UTILITY_PVT.Perform_Writes procedure ...'); END IF;

END Perform_Writes;

PROCEDURE insert_row
   (
	  p_eam_op_comp_rec   IN  EAM_PROCESS_WO_PUB.eam_op_comp_rec_type
	, x_return_status     OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl    OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
   )
IS
    l_Mesg_Token_tbl          EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_return_status           VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
    l_status_id		      NUMBER;
    l_maintenance_object_id   NUMBER := NULL ;
    l_maintenance_object_type NUMBER := NULL ;
    l_asset_group_id	      NUMBER;
    l_asset_number	      VARCHAR2(30);

   BEGIN

     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered Package EAM_OP_COMP_UTILITY_PVT.insert_row procedure..'); END IF;

     INSERT INTO EAM_OP_COMPLETION_TXNS(  /* Insert statement from EAMOCMPB.pls  */
	transaction_id,
	transaction_date,
	transaction_type,
	wip_entity_id,
	organization_id,
	operation_seq_num,
	acct_period_id,
	qa_collection_id,
	reference,
	reconciliation_code,
	department_id,
	actual_start_date,
	actual_end_date,
	actual_duration,
	vendor_id,
	vendor_site_id,
	vendor_contact_id,
	reason_id,
	transaction_reference,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15

    ) VALUES (
	p_eam_op_comp_rec.transaction_id,
	p_eam_op_comp_rec.transaction_date,
	decode(p_eam_op_comp_rec.transaction_type,EAM_PROCESS_WO_PVT.G_OPR_COMPLETE,1,EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE,2),
	p_eam_op_comp_rec.wip_entity_id,
	p_eam_op_comp_rec.organization_id,
	p_eam_op_comp_rec.operation_seq_num,
	NULL,	-- acct_period_id
	p_eam_op_comp_rec.qa_collection_id,
	NULL,	-- reference
	p_eam_op_comp_rec.reconciliation_code,
	p_eam_op_comp_rec.department_id,
	p_eam_op_comp_rec.actual_start_date,
	p_eam_op_comp_rec.actual_end_date,
	p_eam_op_comp_rec.actual_duration,
	p_eam_op_comp_rec.vendor_id,
	p_eam_op_comp_rec.vendor_site_id,
	p_eam_op_comp_rec.vendor_contact_id,
	p_eam_op_comp_rec.reason_id,
	p_eam_op_comp_rec.reference,	-- transaction_reference
	FND_GLOBAL.user_id,
	sysdate,
	FND_GLOBAL.user_id,
	sysdate,
	FND_GLOBAL.login_id,
	p_eam_op_comp_rec.attribute_category,
	p_eam_op_comp_rec.attribute1,
	p_eam_op_comp_rec.attribute2,
	p_eam_op_comp_rec.attribute3,
	p_eam_op_comp_rec.attribute4,
	p_eam_op_comp_rec.attribute5,
	p_eam_op_comp_rec.attribute6,
	p_eam_op_comp_rec.attribute7,
	p_eam_op_comp_rec.attribute8,
	p_eam_op_comp_rec.attribute9,
	p_eam_op_comp_rec.attribute10,
	p_eam_op_comp_rec.attribute11,
	p_eam_op_comp_rec.attribute12,
	p_eam_op_comp_rec.attribute13,
	p_eam_op_comp_rec.attribute14,
	p_eam_op_comp_rec.attribute15
    );

  --
     -- SHUTDOWN History
  IF (p_eam_op_comp_rec.shutdown_start_date IS NOT NULL) OR
       (p_eam_op_comp_rec.shutdown_end_date IS NOT NULL) THEN

	  SELECT eam_asset_status_history_s.nextval
	    INTO l_status_id
	    FROM dual;

	--bug 3572376: pass maintenance object type and id
	BEGIN

	   SELECT nvl(wdj.rebuild_item_id, wdj.asset_number),
		  nvl(wdj.rebuild_serial_number, wdj.asset_group_id),
    	          wdj.maintenance_object_type,
		  wdj.maintenance_object_id
	    INTO  l_asset_group_id,
		  l_asset_number,
		  l_maintenance_object_type,
		  l_maintenance_object_id
	    FROM  wip_discrete_jobs wdj
	   WHERE  wdj.wip_entity_id = p_eam_op_comp_rec.wip_entity_id ;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_maintenance_object_type := NULL;
		l_maintenance_object_id := NULL;
  END;

  INSERT INTO EAM_ASSET_STATUS_HISTORY(
	asset_status_id,
	asset_group_id,
	asset_number,
	organization_id,
	start_date,
	end_date,
	wip_entity_id,
	operation_seq_num,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15
	,maintenance_object_type
	,maintenance_object_id
	,enable_flag		-- enhancemnet bug 3852846

  ) VALUES (
	l_status_id,
	l_asset_group_id,
	l_asset_number,
	p_eam_op_comp_rec.organization_id,
	p_eam_op_comp_rec.shutdown_start_date,
	p_eam_op_comp_rec.shutdown_end_date,
	p_eam_op_comp_rec.wip_entity_id,
	p_eam_op_comp_rec.operation_seq_num,
	FND_GLOBAL.user_id,
	SYSDATE,
	FND_GLOBAL.user_id,
	SYSDATE,
	FND_GLOBAL.login_id,
	p_eam_op_comp_rec.attribute_category,
	p_eam_op_comp_rec.attribute1,
	p_eam_op_comp_rec.attribute2,
	p_eam_op_comp_rec.attribute3,
	p_eam_op_comp_rec.attribute4,
	p_eam_op_comp_rec.attribute5,
	p_eam_op_comp_rec.attribute6,
	p_eam_op_comp_rec.attribute7,
	p_eam_op_comp_rec.attribute8,
	p_eam_op_comp_rec.attribute9,
	p_eam_op_comp_rec.attribute10,
	p_eam_op_comp_rec.attribute11,
	p_eam_op_comp_rec.attribute12,
	p_eam_op_comp_rec.attribute13,
	p_eam_op_comp_rec.attribute14,
	p_eam_op_comp_rec.attribute15
        ,l_maintenance_object_type
	,l_maintenance_object_id
	,'Y'			-- Enhancemnet Bug 3852846
  );

  END IF; -- history insert
  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_OP_COMP_UTILITY_PVT.update_row from EAM_OP_COMP_UTILITY_PVT.insert_row procedure'); END IF;

  update_row
	(  p_eam_op_comp_rec    => p_eam_op_comp_rec
	 , x_mesg_token_Tbl     => l_mesg_token_tbl
	 , x_return_Status      => l_return_status
	 );
  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Returned from EAM_OP_COMP_UTILITY_PVT.update_row to EAM_OP_COMP_UTILITY_PVT.insert_row procedure'); END IF;

  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Exiting Package EAM_OP_COMP_UTILITY_PVT.insert_row procedure with status:'||l_return_status); END IF;

  EXCEPTION
     WHEN OTHERS THEN
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Exception happened Package EAM_OP_COMP_UTILITY_PVT.insert_row procedure..' || SQLERRM); END IF;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||' :Inserting Record ' || SQLERRM
                         , x_mesg_token_Tbl     => l_Mesg_Token_tbl
                        );
	x_return_status  := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
	x_mesg_token_Tbl := l_Mesg_Token_tbl;

END insert_row;

PROCEDURE update_row
(
	 p_eam_op_comp_rec     IN  EAM_PROCESS_WO_PUB.eam_op_comp_rec_type
        , x_return_status      OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
)
IS
	l_shutdown_type VARCHAR2(30) :=NULL;
BEGIN

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Entered Package EAM_OP_COMP_UTILITY_PVT.update_row procedure..'); END IF;

	SELECT 	wo.shutdown_type INTO l_shutdown_type
	  FROM 	wip_operations wo
         WHERE  wo.wip_entity_id     = p_eam_op_comp_rec.wip_entity_id
  	   AND  wo.operation_seq_num = p_eam_op_comp_rec.operation_seq_num;

	 -- Enhancemnet Bug 3852846
	 IF NVL(to_number(l_shutdown_type),1) = 2 THEN
		    UPDATE eam_asset_status_history
		       SET enable_flag = 'N'
			,  last_update_date  = SYSDATE
			,  last_updated_by   = FND_GLOBAL.user_id
			,  last_update_login = FND_GLOBAL.login_id
		     WHERE organization_id   = p_eam_op_comp_rec.organization_id
		       AND wip_entity_id     = p_eam_op_comp_rec.wip_entity_id
		       AND operation_seq_num = p_eam_op_comp_rec.operation_seq_num
		       AND enable_flag       = 'Y' OR enable_flag IS NULL;
	 END IF;

         UPDATE wip_operations
            SET
		operation_completed 		= decode(p_eam_op_comp_rec.transaction_type,EAM_PROCESS_WO_PVT.G_OPR_COMPLETE,'Y',EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE,'N'),
		quantity_completed		= 1,
		last_updated_by 		= FND_GLOBAL.user_id,
		last_update_date 		= sysdate,
		last_update_login 		= FND_GLOBAL.login_id
         WHERE
      		wip_entity_id = p_eam_op_comp_rec.wip_entity_id
	   AND  operation_seq_num = p_eam_op_comp_rec.operation_seq_num;
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Exiting Package EAM_OP_COMP_UTILITY_PVT.update_row procedure'); END IF;

END update_row;


END EAM_OP_COMP_UTILITY_PVT;

/
