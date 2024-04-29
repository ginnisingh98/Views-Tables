--------------------------------------------------------
--  DDL for Package Body EAM_MAT_REQ_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MAT_REQ_UTILITY_PVT" AS
/* $Header: EAMVMRUB.pls 120.3 2005/11/17 22:26:34 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMRUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_MAT_REQ_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_MAT_REQ_UTILITY_PVT';

        /*********************************************************************
        * Procedure     : Query_Row
        * Parameters IN : wip entity id
        *                 organization Id
        *                 operation_seq_num
        *                 inventory_item_id
        * Parameters OUT NOCOPY: Material Requirements column record
        *                 Mesg token Table
        *                 Return Status
        * Purpose       : Procedure will query the database record
        *                 and return with those records.
        ***********************************************************************/

        PROCEDURE Query_Row
        (  p_wip_entity_id       IN  NUMBER
         , p_organization_id     IN  NUMBER
         , p_operation_seq_num   IN  NUMBER
         , p_inventory_item_id   IN  NUMBER
         , x_eam_mat_req_rec     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_Return_status       OUT NOCOPY VARCHAR2
        )
        IS
                l_eam_mat_req_rec       EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
                l_dummy                 varchar2(10);
        BEGIN

                SELECT
                         wip_entity_id
                       , operation_seq_num
                       , organization_id
                       , inventory_item_id
                       , quantity_per_assembly
                       , department_id
                       , wip_supply_type
                       , date_required
                       , required_quantity
                       , quantity_issued
                       , supply_subinventory
                       , supply_locator_id
                       , mrp_net_flag
                       , mps_required_quantity
                       , mps_date_required
                       , component_sequence_id
                       , comments
                       , attribute_category
                       , attribute1
                       , attribute2
                       , attribute3
                       , attribute4
                       , attribute5
                       , attribute6
                       , attribute7
                       , attribute8
                       , attribute9
                       , attribute10
                       , attribute11
                       , attribute12
                       , attribute13
                       , attribute14
                       , attribute15
                       , auto_request_material
                       , suggested_vendor_name
                       , vendor_id
                       , unit_price
		       , released_quantity
                INTO
                         l_eam_mat_req_rec.wip_entity_id
                       , l_eam_mat_req_rec.operation_seq_num
                       , l_eam_mat_req_rec.organization_id
                       , l_eam_mat_req_rec.inventory_item_id
                       , l_eam_mat_req_rec.quantity_per_assembly
                       , l_eam_mat_req_rec.department_id
                       , l_eam_mat_req_rec.wip_supply_type
                       , l_eam_mat_req_rec.date_required
                       , l_eam_mat_req_rec.required_quantity
                       , l_eam_mat_req_rec.quantity_issued
                       , l_eam_mat_req_rec.supply_subinventory
                       , l_eam_mat_req_rec.supply_locator_id
                       , l_eam_mat_req_rec.mrp_net_flag
                       , l_eam_mat_req_rec.mps_required_quantity
                       , l_eam_mat_req_rec.mps_date_required
                       , l_eam_mat_req_rec.component_sequence_id
                       , l_eam_mat_req_rec.comments
                       , l_eam_mat_req_rec.attribute_category
                       , l_eam_mat_req_rec.attribute1
                       , l_eam_mat_req_rec.attribute2
                       , l_eam_mat_req_rec.attribute3
                       , l_eam_mat_req_rec.attribute4
                       , l_eam_mat_req_rec.attribute5
                       , l_eam_mat_req_rec.attribute6
                       , l_eam_mat_req_rec.attribute7
                       , l_eam_mat_req_rec.attribute8
                       , l_eam_mat_req_rec.attribute9
                       , l_eam_mat_req_rec.attribute10
                       , l_eam_mat_req_rec.attribute11
                       , l_eam_mat_req_rec.attribute12
                       , l_eam_mat_req_rec.attribute13
                       , l_eam_mat_req_rec.attribute14
                       , l_eam_mat_req_rec.attribute15
                       , l_eam_mat_req_rec.auto_request_material
                       , l_eam_mat_req_rec.suggested_vendor_name
                       , l_eam_mat_req_rec.vendor_id
                       , l_eam_mat_req_rec.unit_price
		       , l_eam_mat_req_rec.released_quantity
                FROM  wip_requirement_operations wro
                WHERE wro.wip_entity_id = p_wip_entity_id
                AND   wro.organization_id = p_organization_id
                AND   wro.operation_seq_num = p_operation_seq_num
                AND   wro.inventory_item_id = p_inventory_item_id;

                x_return_status  := EAM_PROCESS_WO_PVT.G_RECORD_FOUND;
                x_eam_mat_req_rec     := l_eam_mat_req_rec;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND;
                        x_eam_mat_req_rec    := l_eam_mat_req_rec;

                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_eam_mat_req_rec    := l_eam_mat_req_rec;

        END Query_Row;


        /********************************************************************
        * Procedure     : Insert_Row
        * Parameters IN : Material Requirements column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 wip_operations table.
        *********************************************************************/

        PROCEDURE Insert_Row
        (  p_eam_mat_req_rec    IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
		l_return_status    VARCHAR2(30);
		l_msg_count        NUMBER       := 0;
		l_msg_data         VARCHAR2(2000);

		l_api_version	  CONSTANT NUMBER:=1;
		x_shortage_exists VARCHAR2(1);
		x_msg_count	  NUMBER;
		x_msg_data	  VARCHAR2(2000);

        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Writing Material Requirements rec for ' || p_eam_mat_req_rec.inventory_item_id); END IF;
--Bug3946253:Remove round() for the date_required


                INSERT INTO WIP_REQUIREMENT_OPERATIONS
                       ( wip_entity_id
                       , operation_seq_num
                       , organization_id
                       , inventory_item_id
                       , quantity_per_assembly
                       , department_id
                       , wip_supply_type
                       , date_required
                       , required_quantity
                       , quantity_issued
                       , supply_subinventory
                       , supply_locator_id
                       , mrp_net_flag
                       , mps_required_quantity
                       , mps_date_required
                       , component_sequence_id
                       , comments
                       , attribute_category
                       , attribute1
                       , attribute2
                       , attribute3
                       , attribute4
                       , attribute5
                       , attribute6
                       , attribute7
                       , attribute8
                       , attribute9
                       , attribute10
                       , attribute11
                       , attribute12
                       , attribute13
                       , attribute14
                       , attribute15
		       , released_quantity
                       , auto_request_material
                       , suggested_vendor_name
                       , vendor_id
                       , unit_price
                       , basis_type
                       , segment1
                       , segment2
                       , segment3
                       , segment4
                       , segment5
                       , segment6
                       , segment7
                       , segment8
                       , segment9
                       , segment10
                       , segment11
                       , segment12
                       , segment13
                       , segment14
                       , segment15
                       , segment16
                       , segment17
                       , segment18
                       , segment19
                       , segment20
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , last_update_login
                       , request_id
                       , program_application_id
                       , program_id
                       , program_update_date)
                SELECT
                         p_eam_mat_req_rec.wip_entity_id
                       , p_eam_mat_req_rec.operation_seq_num
                       , p_eam_mat_req_rec.organization_id
                       , p_eam_mat_req_rec.inventory_item_id
                       , p_eam_mat_req_rec.quantity_per_assembly
                       , p_eam_mat_req_rec.department_id
                       , p_eam_mat_req_rec.wip_supply_type
                       , p_eam_mat_req_rec.date_required
                       , p_eam_mat_req_rec.required_quantity
                       , p_eam_mat_req_rec.quantity_issued
                       , p_eam_mat_req_rec.supply_subinventory
                       , p_eam_mat_req_rec.supply_locator_id
                       , p_eam_mat_req_rec.mrp_net_flag
                       , p_eam_mat_req_rec.mps_required_quantity
                       , round(p_eam_mat_req_rec.mps_date_required,'DD')
                       , p_eam_mat_req_rec.component_sequence_id
                       , p_eam_mat_req_rec.comments
                       , p_eam_mat_req_rec.attribute_category
                       , p_eam_mat_req_rec.attribute1
                       , p_eam_mat_req_rec.attribute2
                       , p_eam_mat_req_rec.attribute3
                       , p_eam_mat_req_rec.attribute4
                       , p_eam_mat_req_rec.attribute5
                       , p_eam_mat_req_rec.attribute6
                       , p_eam_mat_req_rec.attribute7
                       , p_eam_mat_req_rec.attribute8
                       , p_eam_mat_req_rec.attribute9
                       , p_eam_mat_req_rec.attribute10
                       , p_eam_mat_req_rec.attribute11
                       , p_eam_mat_req_rec.attribute12
                       , p_eam_mat_req_rec.attribute13
                       , p_eam_mat_req_rec.attribute14
                       , p_eam_mat_req_rec.attribute15
		       , p_eam_mat_req_rec.released_quantity
                       , p_eam_mat_req_rec.auto_request_material
                       , p_eam_mat_req_rec.suggested_vendor_name
                       , p_eam_mat_req_rec.vendor_id
                       , p_eam_mat_req_rec.unit_price
                       , null
                       , msi.segment1
                       , msi.segment2
                       , msi.segment3
                       , msi.segment4
                       , msi.segment5
                       , msi.segment6
                       , msi.segment7
                       , msi.segment8
                       , msi.segment9
                       , msi.segment10
                       , msi.segment11
                       , msi.segment12
                       , msi.segment13
                       , msi.segment14
                       , msi.segment15
                       , msi.segment16
                       , msi.segment17
                       , msi.segment18
                       , msi.segment19
                       , msi.segment20
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , FND_GLOBAL.login_id
                       , p_eam_mat_req_rec.request_id
                       , p_eam_mat_req_rec.program_application_id
                       , p_eam_mat_req_rec.program_id
                       , SYSDATE
                FROM     mtl_system_items msi
                WHERE    msi.inventory_item_id = p_eam_mat_req_rec.inventory_item_id
                AND      msi.organization_id = p_eam_mat_req_rec.organization_id


                       ;--p_eam_mat_req_rec.program_update_date);


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Creating new Material Requirements') ; END IF;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- bug number 2251186
		  -- API is called to set the estimation_status
      --added for 3658112.do not call for unplanned materials
         IF(p_eam_mat_req_rec.released_quantity is null OR p_eam_mat_req_rec.released_quantity<>0) THEN
		  EAM_AutomaticEst.Auto_Reest_of_Cost(
		    p_wip_entity_id =>  p_eam_mat_req_rec.wip_entity_id,
		    p_api_name => 'EAM',
		    p_req_line_id => NULL,
		    p_po_dist_id => NULL,
		    p_po_line_id => NULL,
		    p_inv_item_id => NULL,
		    p_org_id => p_eam_mat_req_rec.organization_id,
		    p_resource_id => NULL,
		    x_return_status => l_return_status,
		    x_msg_count => l_msg_count,
		    x_msg_data => l_msg_data
		    );
            END IF;


        EXCEPTION
            WHEN OTHERS THEN
                        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||' :Inserting Record ' || SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
                        );

                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Insert_Row;

/********************************************************************
* Procedure     : Update_Row
* Parameters IN : Material Requirements column record
* Parameters OUT NOCOPY: Message Token Table
*                 Return Status
* Purpose       : Procedure will perfrom an Update on the
*                 wip_operations table.
*********************************************************************/

PROCEDURE Update_Row
(  p_eam_mat_req_rec    IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
 , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
 , x_return_Status      OUT NOCOPY VARCHAR2
 )
IS
		l_return_status    VARCHAR2(30) ;
		l_msg_count        NUMBER       := 0;
		l_msg_data         VARCHAR2(2000);
		l_req_qty          NUMBER       := 0;
		l_api_version	  CONSTANT NUMBER:=1;
		x_shortage_exists VARCHAR2(1);
 BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Updating Material Requirements '|| p_eam_mat_req_rec.inventory_item_id); END IF;



   SELECT required_quantity
    INTO l_req_qty
    FROM WIP_REQUIREMENT_OPERATIONS
   WHERE wip_entity_id     = p_eam_mat_req_rec.wip_entity_id
     AND ( operation_seq_num = p_eam_mat_req_rec.operation_seq_num
				            OR operation_seq_num = 1 )
     AND inventory_item_id = p_eam_mat_req_rec.inventory_item_id;
--Bug3946253:Remove round() for the date_required
      UPDATE WIP_REQUIREMENT_OPERATIONS
                SET    quantity_per_assembly       = p_eam_mat_req_rec.quantity_per_assembly
		       , operation_seq_num           = p_eam_mat_req_rec.operation_seq_num  /* Added the column so that op seq num can be changed if it is 1 */
                       , department_id               = p_eam_mat_req_rec.department_id
                       , wip_supply_type             = p_eam_mat_req_rec.wip_supply_type
                       , date_required               = p_eam_mat_req_rec.date_required
                       , required_quantity           = p_eam_mat_req_rec.required_quantity
                       , quantity_issued             = p_eam_mat_req_rec.quantity_issued
                       , supply_subinventory         = p_eam_mat_req_rec.supply_subinventory
                       , supply_locator_id           = p_eam_mat_req_rec.supply_locator_id
                       , mrp_net_flag                = p_eam_mat_req_rec.mrp_net_flag
                       , mps_required_quantity       = p_eam_mat_req_rec.mps_required_quantity
                       , mps_date_required           = round(p_eam_mat_req_rec.mps_date_required, 'DD')
                       , component_sequence_id       = p_eam_mat_req_rec.component_sequence_id
                       , comments                    = p_eam_mat_req_rec.comments
                       , attribute_category          = p_eam_mat_req_rec.attribute_category
                       , attribute1                  = p_eam_mat_req_rec.attribute1
                       , attribute2                  = p_eam_mat_req_rec.attribute2
                       , attribute3                  = p_eam_mat_req_rec.attribute3
                       , attribute4                  = p_eam_mat_req_rec.attribute4
                       , attribute5                  = p_eam_mat_req_rec.attribute5
                       , attribute6                  = p_eam_mat_req_rec.attribute6
                       , attribute7                  = p_eam_mat_req_rec.attribute7
                       , attribute8                  = p_eam_mat_req_rec.attribute8
                       , attribute9                  = p_eam_mat_req_rec.attribute9
                       , attribute10                 = p_eam_mat_req_rec.attribute10
                       , attribute11                 = p_eam_mat_req_rec.attribute11
                       , attribute12                 = p_eam_mat_req_rec.attribute12
                       , attribute13                 = p_eam_mat_req_rec.attribute13
                       , attribute14                 = p_eam_mat_req_rec.attribute14
                       , attribute15                 = p_eam_mat_req_rec.attribute15
		       , released_quantity           = p_eam_mat_req_rec.released_quantity
                       , auto_request_material       = p_eam_mat_req_rec.auto_request_material
                       , suggested_vendor_name       = p_eam_mat_req_rec.suggested_vendor_name
                       , vendor_id                   = p_eam_mat_req_rec.vendor_id
                       , unit_price                  = p_eam_mat_req_rec.unit_price
                       , last_update_date            = SYSDATE
                       , last_updated_by             = FND_GLOBAL.user_id
                       , last_update_login           = FND_GLOBAL.login_id
                       , request_id                  = p_eam_mat_req_rec.request_id
                       , program_application_id      = p_eam_mat_req_rec.program_application_id
                       , program_id                  = p_eam_mat_req_rec.program_id
                       , program_update_date         = SYSDATE
                WHERE    organization_id   = p_eam_mat_req_rec.organization_id
                  AND    wip_entity_id     = p_eam_mat_req_rec.wip_entity_id
                  AND  ( operation_seq_num = p_eam_mat_req_rec.operation_seq_num
				            OR operation_seq_num = 1 )                                                /* Added the check operation_seq_num = 1 so that op seq num can be changed if it is 1 */
                  AND    inventory_item_id = p_eam_mat_req_rec.inventory_item_id;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

 --added for 3658112.do not call for unplanned materials
         IF(p_eam_mat_req_rec.released_quantity is null OR p_eam_mat_req_rec.released_quantity<>0) THEN
		    -- comparing new quantity with existing quantity
		   IF ( p_eam_mat_req_rec.required_quantity <> l_req_qty )THEN

		      -- API is called to set the estimation_status
		      EAM_AutomaticEst.Auto_Reest_of_Cost(
			p_wip_entity_id => p_eam_mat_req_rec.wip_entity_id,
			p_api_name => 'EAM',
			p_req_line_id => NULL,
			p_po_dist_id => NULL,
			p_po_line_id => NULL,
			p_inv_item_id => NULL,
			p_org_id => p_eam_mat_req_rec.organization_id,
			p_resource_id => NULL,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data
			);

		    END IF; /* ENDIF of comparing quantity IF */
          END IF;

        END Update_Row;



        /********************************************************************
        * Procedure     : Delete_Row
        * Parameters IN : Material Requirements column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Delete on the
        *                 wip_operations table.
        *********************************************************************/

        PROCEDURE Delete_Row
        (  p_eam_mat_req_rec    IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS

		l_return_status    VARCHAR2(30);
		l_msg_count        NUMBER       := 0;
		l_msg_data         VARCHAR2(2000);

		l_api_version	  CONSTANT NUMBER:=1;
		x_shortage_exists VARCHAR2(1);

        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Deleting Material Requirements '|| p_eam_mat_req_rec.inventory_item_id); END IF;

      DELETE FROM WIP_REQUIREMENT_OPERATIONS
                WHERE    organization_id   = p_eam_mat_req_rec.organization_id
                  AND    wip_entity_id     = p_eam_mat_req_rec.wip_entity_id
                  AND    operation_seq_num = p_eam_mat_req_rec.operation_seq_num
                  AND    inventory_item_id = p_eam_mat_req_rec.inventory_item_id;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

        --added for 3658112.do not call for unplanned materials
         IF(p_eam_mat_req_rec.released_quantity is null OR p_eam_mat_req_rec.released_quantity<>0) THEN
		      -- API is called to set the estimation_status
		      EAM_AutomaticEst.Auto_Reest_of_Cost(
			p_wip_entity_id => p_eam_mat_req_rec.wip_entity_id,
			p_api_name => 'EAM',
			p_req_line_id => NULL,
			p_po_dist_id => NULL,
			p_po_line_id => NULL,
			p_inv_item_id => NULL,
			p_org_id => p_eam_mat_req_rec.organization_id,
			p_resource_id => NULL,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data
			);
	END IF;

        END Delete_Row;


        /*********************************************************************
        * Procedure     : Perform_Writes
        * Parameters IN : Material Requirements Record
        * Parameters OUT NOCOPY: Messgae Token Table
        *                 Return Status
        * Purpose       : This is the only procedure that the user will have
        *                 access to when he/she needs to perform any kind of
        *                 writes to the wip_operations.
        *********************************************************************/

        PROCEDURE Perform_Writes
        (  p_eam_mat_req_rec    IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
        )
        IS
                l_Mesg_Token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN

                IF p_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                        Insert_Row
                        (  p_eam_mat_req_rec    => p_eam_mat_req_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                ELSIF p_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                THEN
                        Update_Row
                        (  p_eam_mat_req_rec    => p_eam_mat_req_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

                ELSIF p_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE
                THEN
                        Delete_Row
                        (  p_eam_mat_req_rec    => p_eam_mat_req_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

                END IF;

                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Perform_Writes;


       FUNCTION  NUM_OF_ROW
       ( p_wip_entity_id  NUMBER
	   , p_organization_id NUMBER
	   , p_operation_seq_num NUMBER
	   ) RETURN BOOLEAN IS

	   l_count NUMBER := 0 ;

	   BEGIN
		   SELECT  count(*)  into l_count
	       FROM dual
	       WHERE exists (
	                         SELECT 1
							 FROM wip_requirement_operations
							 WHERE operation_seq_num = p_operation_seq_num
							 and wip_entity_id = p_wip_entity_id
							 and organization_id = p_organization_id
						   ) ;

		   IF ( l_count = 0 ) THEN
		       return FALSE ;
		   ELSE
			   return TRUE ;
		   END IF;

      END NUM_OF_ROW;



END EAM_MAT_REQ_UTILITY_PVT;

/
