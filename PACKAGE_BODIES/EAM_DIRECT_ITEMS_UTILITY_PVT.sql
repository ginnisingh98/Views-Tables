--------------------------------------------------------
--  DDL for Package Body EAM_DIRECT_ITEMS_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_DIRECT_ITEMS_UTILITY_PVT" AS
/* $Header: EAMVDIUB.pls 115.1 2004/04/08 11:54:30 rethakur noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVDIUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_DIRECT_ITEMS_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  15-SEP-2003    Basanth Roy     Initial Creation
***************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_DIRECT_ITEMS_UTILITY_PVT';

        /*********************************************************************
        * Procedure     : Query_Row
        * Parameters IN : wip entity id
        *                 organization Id
        *                 operation_seq_num
        *                 direct_items_sequence_id
        * Parameters OUT NOCOPY: Direct Items column record
        *                 Mesg token Table
        *                 Return Status
        * Purpose       : Procedure will query the database record
        *                 and return with those records.
        ***********************************************************************/

        PROCEDURE Query_Row
        (  p_wip_entity_id       IN  NUMBER
         , p_organization_id     IN  NUMBER
         , p_operation_seq_num   IN  NUMBER
         , p_direct_item_sequence_id   IN  NUMBER
         , x_eam_direct_items_rec     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_Return_status       OUT NOCOPY VARCHAR2
        )
        IS
                l_eam_direct_items_rec       EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
                l_dummy                 varchar2(10);
        BEGIN

                SELECT
                  DESCRIPTION
                 ,PURCHASING_CATEGORY_ID
                 ,DIRECT_ITEM_SEQUENCE_ID
                 ,OPERATION_SEQ_NUM
                 ,DEPARTMENT_ID
                 ,WIP_ENTITY_ID
                 ,ORGANIZATION_ID
                 ,SUGGESTED_VENDOR_NAME
                 ,SUGGESTED_VENDOR_ID
                 ,SUGGESTED_VENDOR_SITE
                 ,SUGGESTED_VENDOR_SITE_ID
                 ,SUGGESTED_VENDOR_CONTACT
                 ,SUGGESTED_VENDOR_CONTACT_ID
                 ,SUGGESTED_VENDOR_PHONE
                 ,SUGGESTED_VENDOR_ITEM_NUM
                 ,UNIT_PRICE
                 ,AUTO_REQUEST_MATERIAL
                 ,REQUIRED_QUANTITY
                 ,UOM
                 ,NEED_BY_DATE
                 ,ATTRIBUTE_CATEGORY
                 ,ATTRIBUTE1
                 ,ATTRIBUTE2
                 ,ATTRIBUTE3
                 ,ATTRIBUTE4
                 ,ATTRIBUTE5
                 ,ATTRIBUTE6
                 ,ATTRIBUTE7
                 ,ATTRIBUTE8
                 ,ATTRIBUTE9
                 ,ATTRIBUTE10
                 ,ATTRIBUTE11
                 ,ATTRIBUTE12
                 ,ATTRIBUTE13
                 ,ATTRIBUTE14
                 ,ATTRIBUTE15
                INTO
                  l_eam_direct_items_rec.DESCRIPTION
                 ,l_eam_direct_items_rec.PURCHASING_CATEGORY_ID
                 ,l_eam_direct_items_rec.Direct_Item_Sequence_Id
                 ,l_eam_direct_items_rec.Operation_Seq_Num
                 ,l_eam_direct_items_rec.Department_id
                 ,l_eam_direct_items_rec.Wip_entity_id
                 ,l_eam_direct_items_rec.Organization_id
                 ,l_eam_direct_items_rec.Suggested_Vendor_Name
                 ,l_eam_direct_items_rec.Suggested_Vendor_Id
                 ,l_eam_direct_items_rec.Suggested_Vendor_Site
                 ,l_eam_direct_items_rec.Suggested_Vendor_Site_Id
                 ,l_eam_direct_items_rec.Suggested_Vendor_Contact
                 ,l_eam_direct_items_rec.Suggested_Vendor_Contact_Id
                 ,l_eam_direct_items_rec.Suggested_Vendor_Phone
                 ,l_eam_direct_items_rec.Suggested_Vendor_Item_Num
                 ,l_eam_direct_items_rec.Unit_Price
                 ,l_eam_direct_items_rec.Auto_request_Material
                 ,l_eam_direct_items_rec.Required_Quantity
                 ,l_eam_direct_items_rec.UOM
                 ,l_eam_direct_items_rec.Need_By_Date
                 ,l_eam_direct_items_rec.ATTRIBUTE_CATEGORY
                 ,l_eam_direct_items_rec.ATTRIBUTE1
                 ,l_eam_direct_items_rec.ATTRIBUTE2
                 ,l_eam_direct_items_rec.ATTRIBUTE3
                 ,l_eam_direct_items_rec.ATTRIBUTE4
                 ,l_eam_direct_items_rec.ATTRIBUTE5
                 ,l_eam_direct_items_rec.ATTRIBUTE6
                 ,l_eam_direct_items_rec.ATTRIBUTE7
                 ,l_eam_direct_items_rec.ATTRIBUTE8
                 ,l_eam_direct_items_rec.ATTRIBUTE9
                 ,l_eam_direct_items_rec.ATTRIBUTE10
                 ,l_eam_direct_items_rec.ATTRIBUTE11
                 ,l_eam_direct_items_rec.ATTRIBUTE12
                 ,l_eam_direct_items_rec.ATTRIBUTE13
                 ,l_eam_direct_items_rec.ATTRIBUTE14
                 ,l_eam_direct_items_rec.ATTRIBUTE15
                FROM  wip_eam_direct_items wedi
                WHERE wedi.wip_entity_id = p_wip_entity_id
                AND   wedi.organization_id = p_organization_id
                AND   wedi.operation_seq_num = p_operation_seq_num
                AND   wedi.direct_item_sequence_id = p_direct_item_sequence_id;

                x_return_status  := EAM_PROCESS_WO_PVT.G_RECORD_FOUND;
                x_eam_direct_items_rec     := l_eam_direct_items_rec;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND;
                        x_eam_direct_items_rec    := l_eam_direct_items_rec;

                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_eam_direct_items_rec    := l_eam_direct_items_rec;

        END Query_Row;


        /********************************************************************
        * Procedure     : Insert_Row
        * Parameters IN : Direct Items column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 wip_eam_direct_items table.
        *********************************************************************/

        PROCEDURE Insert_Row
        (  p_eam_direct_items_rec    IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
		l_return_status    VARCHAR2(30) := '';
		l_msg_count        NUMBER       := 0;
		l_msg_data         VARCHAR2(2000) := '';

	BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Writing Direct Items rec for ' || p_eam_direct_items_rec.direct_item_sequence_id); END IF;

                INSERT INTO WIP_EAM_DIRECT_ITEMS
                       (
                  	DESCRIPTION
            	       ,PURCHASING_CATEGORY_ID
                       ,DIRECT_ITEM_SEQUENCE_ID
                       ,OPERATION_SEQ_NUM
                       ,DEPARTMENT_ID
                       ,WIP_ENTITY_ID
                       ,ORGANIZATION_ID
                       ,SUGGESTED_VENDOR_NAME
                       ,SUGGESTED_VENDOR_ID
                       ,SUGGESTED_VENDOR_SITE
                       ,SUGGESTED_VENDOR_SITE_ID
                       ,SUGGESTED_VENDOR_CONTACT
                       ,SUGGESTED_VENDOR_CONTACT_ID
                       ,SUGGESTED_VENDOR_PHONE
                       ,SUGGESTED_VENDOR_ITEM_NUM
                       ,UNIT_PRICE
                       ,AUTO_REQUEST_MATERIAL
                       ,REQUIRED_QUANTITY
                       ,UOM
                       ,NEED_BY_DATE
                       ,ATTRIBUTE_CATEGORY
                       ,ATTRIBUTE1
                       ,ATTRIBUTE2
                       ,ATTRIBUTE3
                       ,ATTRIBUTE4
                       ,ATTRIBUTE5
                       ,ATTRIBUTE6
                       ,ATTRIBUTE7
                       ,ATTRIBUTE8
                       ,ATTRIBUTE9
                       ,ATTRIBUTE10
                       ,ATTRIBUTE11
                       ,ATTRIBUTE12
                       ,ATTRIBUTE13
                       ,ATTRIBUTE14
                       ,ATTRIBUTE15
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , last_update_login
                       , request_id
                       , program_application_id
                       , program_id
                       , program_update_date)
                VALUES (

                  p_eam_direct_items_rec.DESCRIPTION
                 ,p_eam_direct_items_rec.PURCHASING_CATEGORY_ID
                 ,p_eam_direct_items_rec.Direct_Item_Sequence_Id
                 ,p_eam_direct_items_rec.Operation_Seq_Num
                 ,p_eam_direct_items_rec.Department_id
                 ,p_eam_direct_items_rec.Wip_entity_id
                 ,p_eam_direct_items_rec.Organization_id
                 ,p_eam_direct_items_rec.Suggested_Vendor_Name
                 ,p_eam_direct_items_rec.Suggested_Vendor_Id
                 ,p_eam_direct_items_rec.Suggested_Vendor_Site
                 ,p_eam_direct_items_rec.Suggested_Vendor_Site_Id
                 ,p_eam_direct_items_rec.Suggested_Vendor_Contact
                 ,p_eam_direct_items_rec.Suggested_Vendor_Contact_Id
                 ,p_eam_direct_items_rec.Suggested_Vendor_Phone
                 ,p_eam_direct_items_rec.Suggested_Vendor_Item_Num
                 ,p_eam_direct_items_rec.Unit_Price
                 ,p_eam_direct_items_rec.Auto_request_Material
                 ,p_eam_direct_items_rec.Required_Quantity
                 ,p_eam_direct_items_rec.UOM
                 ,p_eam_direct_items_rec.Need_By_Date
                 ,p_eam_direct_items_rec.ATTRIBUTE_CATEGORY
                 ,p_eam_direct_items_rec.ATTRIBUTE1
                 ,p_eam_direct_items_rec.ATTRIBUTE2
                 ,p_eam_direct_items_rec.ATTRIBUTE3
                 ,p_eam_direct_items_rec.ATTRIBUTE4
                 ,p_eam_direct_items_rec.ATTRIBUTE5
                 ,p_eam_direct_items_rec.ATTRIBUTE6
                 ,p_eam_direct_items_rec.ATTRIBUTE7
                 ,p_eam_direct_items_rec.ATTRIBUTE8
                 ,p_eam_direct_items_rec.ATTRIBUTE9
                 ,p_eam_direct_items_rec.ATTRIBUTE10
                 ,p_eam_direct_items_rec.ATTRIBUTE11
                 ,p_eam_direct_items_rec.ATTRIBUTE12
                 ,p_eam_direct_items_rec.ATTRIBUTE13
                 ,p_eam_direct_items_rec.ATTRIBUTE14
                 ,p_eam_direct_items_rec.ATTRIBUTE15
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , FND_GLOBAL.login_id
                       , p_eam_direct_items_rec.request_id
                       , p_eam_direct_items_rec.program_application_id
                       , p_eam_direct_items_rec.program_id
                       , SYSDATE);


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Creating new Direct Items') ; END IF;

                x_return_status := FND_API.G_RET_STS_SUCCESS;
		      -- API is called to set the estimation_status
		      EAM_AutomaticEst.Auto_Reest_of_Cost(
			p_wip_entity_id =>p_eam_direct_items_rec.wip_entity_id,
			p_api_name => 'EAM',
			p_req_line_id => NULL,
			p_po_dist_id => NULL,
			p_po_line_id => NULL,
			p_inv_item_id => NULL,
			p_org_id => p_eam_direct_items_rec.organization_id,
			p_resource_id => NULL,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data
			);


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
        * Parameters IN : Direct Items column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update on the
        *                 wip_eam_direct_items
        *********************************************************************/

        PROCEDURE Update_Row
        (  p_eam_direct_items_rec    IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
		l_return_status    VARCHAR2(30) := '';
		l_msg_count        NUMBER       := 0;
		l_msg_data         VARCHAR2(2000) := '';
		l_req_qty          NUMBER       := 0;

        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Updating Direct Items '|| p_eam_direct_items_rec.direct_item_sequence_id); END IF;

	  SELECT required_quantity
	    INTO l_req_qty
	    FROM WIP_EAM_DIRECT_ITEMS
	    WHERE organization_id   = p_eam_direct_items_rec.organization_id
              AND    wip_entity_id     = p_eam_direct_items_rec.wip_entity_id
              AND  ( operation_seq_num = p_eam_direct_items_rec.operation_seq_num
				            OR operation_seq_num = 1 )                                                /* Added the check operation_seq_num = 1 so that op seq num can be changed if it is 1 */
              AND    direct_item_sequence_id = p_eam_direct_items_rec.direct_item_sequence_id;

      UPDATE WIP_EAM_DIRECT_ITEMS
                SET
                  DESCRIPTION = p_eam_direct_items_rec.DESCRIPTION
                 ,PURCHASING_CATEGORY_ID = p_eam_direct_items_rec.PURCHASING_CATEGORY_ID
                 ,Direct_Item_Sequence_Id =  p_eam_direct_items_rec.Direct_Item_Sequence_Id
                 ,Operation_Seq_Num = p_eam_direct_items_rec.Operation_Seq_Num
                 ,Department_id = p_eam_direct_items_rec.Department_id
                 ,Wip_entity_id = p_eam_direct_items_rec.Wip_entity_id
                 ,Organization_id = p_eam_direct_items_rec.Organization_id
                 ,Suggested_Vendor_Name = p_eam_direct_items_rec.Suggested_Vendor_Name
                 ,Suggested_Vendor_Id = p_eam_direct_items_rec.Suggested_Vendor_Id
                 ,Suggested_Vendor_Site = p_eam_direct_items_rec.Suggested_Vendor_Site
                 ,Suggested_Vendor_Site_Id = p_eam_direct_items_rec.Suggested_Vendor_Site_Id
                 ,Suggested_Vendor_Contact = p_eam_direct_items_rec.Suggested_Vendor_Contact
                 ,Suggested_Vendor_Contact_Id = p_eam_direct_items_rec.Suggested_Vendor_Contact_Id
                 ,Suggested_Vendor_Phone = p_eam_direct_items_rec.Suggested_Vendor_Phone
                 ,Suggested_Vendor_Item_Num = p_eam_direct_items_rec.Suggested_Vendor_Item_Num
                 ,Unit_Price = p_eam_direct_items_rec.Unit_Price
                 ,Auto_request_Material = p_eam_direct_items_rec.Auto_request_Material
                 ,Required_Quantity = p_eam_direct_items_rec.Required_Quantity
                 ,UOM = p_eam_direct_items_rec.UOM
                 ,Need_By_Date = p_eam_direct_items_rec.Need_By_Date
                       , attribute_category          = p_eam_direct_items_rec.attribute_category
                       , attribute1                  = p_eam_direct_items_rec.attribute1
                       , attribute2                  = p_eam_direct_items_rec.attribute2
                       , attribute3                  = p_eam_direct_items_rec.attribute3
                       , attribute4                  = p_eam_direct_items_rec.attribute4
                       , attribute5                  = p_eam_direct_items_rec.attribute5
                       , attribute6                  = p_eam_direct_items_rec.attribute6
                       , attribute7                  = p_eam_direct_items_rec.attribute7
                       , attribute8                  = p_eam_direct_items_rec.attribute8
                       , attribute9                  = p_eam_direct_items_rec.attribute9
                       , attribute10                 = p_eam_direct_items_rec.attribute10
                       , attribute11                 = p_eam_direct_items_rec.attribute11
                       , attribute12                 = p_eam_direct_items_rec.attribute12
                       , attribute13                 = p_eam_direct_items_rec.attribute13
                       , attribute14                 = p_eam_direct_items_rec.attribute14
                       , attribute15                 = p_eam_direct_items_rec.attribute15
                       , last_update_date            = SYSDATE
                       , last_updated_by             = FND_GLOBAL.user_id
                       , last_update_login           = FND_GLOBAL.login_id
                       , request_id                  = p_eam_direct_items_rec.request_id
                       , program_application_id      = p_eam_direct_items_rec.program_application_id
                       , program_id                  = p_eam_direct_items_rec.program_id
                       , program_update_date         = SYSDATE
                WHERE    organization_id   = p_eam_direct_items_rec.organization_id
                  AND    wip_entity_id     = p_eam_direct_items_rec.wip_entity_id
                  AND  ( operation_seq_num = p_eam_direct_items_rec.operation_seq_num
				            OR operation_seq_num = 1 )                                                /* Added the check operation_seq_num = 1 so that op seq num can be changed if it is 1 */
                  AND    direct_item_sequence_id = p_eam_direct_items_rec.direct_item_sequence_id;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

		    -- comparing new quantity with existing quantity
		    IF ( p_eam_direct_items_rec.required_quantity <> l_req_qty )THEN

		      -- API is called to set the estimation_status
		      EAM_AutomaticEst.Auto_Reest_of_Cost(
			p_wip_entity_id => p_eam_direct_items_rec.wip_entity_id,
			p_api_name => 'EAM',
			p_req_line_id => NULL,
			p_po_dist_id => NULL,
			p_po_line_id => NULL,
			p_inv_item_id => NULL,
			p_org_id => p_eam_direct_items_rec.organization_id,
			p_resource_id => NULL,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data
			);

		    END IF; /* ENDIF of comparing quantity IF */


        END Update_Row;



        /********************************************************************
        * Procedure     : Delete_Row
        * Parameters IN : Direct Items column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Delete on the
        *                 wip_eam_direct_items
        *********************************************************************/

        PROCEDURE Delete_Row
        (  p_eam_direct_items_rec    IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
		l_return_status    VARCHAR2(30) := '';
		l_msg_count        NUMBER       := 0;
		l_msg_data         VARCHAR2(2000) := '';
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Deleting Direct Items '|| p_eam_direct_items_rec.direct_item_sequence_id); END IF;

      DELETE FROM WIP_EAM_DIRECT_ITEMS
                WHERE    organization_id   = p_eam_direct_items_rec.organization_id
                  AND    wip_entity_id     = p_eam_direct_items_rec.wip_entity_id
                  AND    operation_seq_num = p_eam_direct_items_rec.operation_seq_num
                  AND    direct_item_sequence_id = p_eam_direct_items_rec.direct_item_sequence_id;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

		      -- API is called to set the estimation_status
		      EAM_AutomaticEst.Auto_Reest_of_Cost(
			p_wip_entity_id => p_eam_direct_items_rec.wip_entity_id,
			p_api_name => 'EAM',
			p_req_line_id => NULL,
			p_po_dist_id => NULL,
			p_po_line_id => NULL,
			p_inv_item_id => NULL,
			p_org_id => p_eam_direct_items_rec.organization_id,
			p_resource_id => NULL,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data
			);


        END Delete_Row;


        /*********************************************************************
        * Procedure     : Perform_Writes
        * Parameters IN : Direct Items Record
        * Parameters OUT NOCOPY: Messgae Token Table
        *                 Return Status
        * Purpose       : This is the only procedure that the user will have
        *                 access to when he/she needs to perform any kind of
        *                 writes to the wip_operations.
        *********************************************************************/

        PROCEDURE Perform_Writes
        (  p_eam_direct_items_rec    IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
        )
        IS
                l_Mesg_Token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN

                IF p_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                        Insert_Row
                        (  p_eam_direct_items_rec    => p_eam_direct_items_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                ELSIF p_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                THEN
                        Update_Row
                        (  p_eam_direct_items_rec    => p_eam_direct_items_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

                ELSIF p_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE
                THEN
                        Delete_Row
                        (  p_eam_direct_items_rec    => p_eam_direct_items_rec
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
							 FROM wip_eam_direct_items
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



END EAM_DIRECT_ITEMS_UTILITY_PVT;

/
