--------------------------------------------------------
--  DDL for Package Body EAM_MAT_REQ_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MAT_REQ_DEFAULT_PVT" AS
/* $Header: EAMVMRDB.pls 120.1 2005/11/08 02:35:11 mkishore noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMRDB.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_MAT_REQ_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_MAT_REQ_DEFAULT_PVT';


        /********************************************************************
        * Procedure     : get_flex_eam_mat_req
        * Return        : NUMBER
        **********************************************************************/


        PROCEDURE get_flex_eam_mat_req
          (  p_eam_mat_req_rec IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
           , x_eam_mat_req_rec OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
          )
        IS
        BEGIN

            --  In the future call Flex APIs for defaults
                x_eam_mat_req_rec := p_eam_mat_req_rec;

                IF p_eam_mat_req_rec.attribute_category =FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute_category := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute1  := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute2 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute2  := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute3  := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute4  := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute5  := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute6  := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute7  := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute8  := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute9  := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute10 := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute11 := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute12 := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute13 := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute14 := NULL;
                END IF;

                IF p_eam_mat_req_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                        x_eam_mat_req_rec.attribute15 := NULL;
                END IF;

        END get_flex_eam_mat_req;


        /*********************************************************************
        * Procedure     : Attribute_Defaulting
        * Parameters IN : Material Requirements record
        * Parameters OUT NOCOPY: Material Requirements record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Attribute Defaulting will default the necessary null
        *                 attribute with appropriate values.
        **********************************************************************/

        PROCEDURE Attribute_Defaulting
        (  p_eam_mat_req_rec              IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_eam_mat_req_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         )
        IS
          l_out_eam_mat_req_rec EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
        BEGIN

                x_eam_mat_req_rec := p_eam_mat_req_rec;
--                x_eam_mat_req_rec := p_eam_mat_req_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                -- Defaulting AUTO_REQUEST_MATERIAL flag.
                IF p_eam_mat_req_rec.auto_request_material IS NULL OR
                   p_eam_mat_req_rec.auto_request_material = FND_API.G_MISS_CHAR
                THEN
                   x_eam_mat_req_rec.auto_request_material := 'Y';
                END IF;

                -- Defaulting wip_supply_type
                IF p_eam_mat_req_rec.wip_supply_type IS NULL OR
                   p_eam_mat_req_rec.wip_supply_type = FND_API.G_MISS_NUM OR
                   p_eam_mat_req_rec.wip_supply_type not in (wip_constants.push, wip_constants.bulk, wip_constants.based_on_bom)  -- Fix for Bug 3438964
                THEN
                   x_eam_mat_req_rec.wip_supply_type := 1;
                END IF;

                -- Defaulting quantity_per_assembly
                IF p_eam_mat_req_rec.quantity_per_assembly IS NULL OR
                   p_eam_mat_req_rec.quantity_per_assembly = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.quantity_per_assembly := 1;
                END IF;

                -- Defaulting mrp_net_flag
                IF p_eam_mat_req_rec.mrp_net_flag IS NULL OR
                   p_eam_mat_req_rec.mrp_net_flag = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.mrp_net_flag := 1;
                END IF;


                -- Defaulting quantity_issued
                IF p_eam_mat_req_rec.quantity_issued IS NULL OR
                   p_eam_mat_req_rec.quantity_issued = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.quantity_issued := 0;
                END IF;

                -- Defaulting department_id
                IF (p_eam_mat_req_rec.department_id IS NULL OR
                    p_eam_mat_req_rec.department_id = FND_API.G_MISS_NUM) AND
                   p_eam_mat_req_rec.operation_seq_num is not null AND
                   p_eam_mat_req_rec.organization_id is not null AND
                   p_eam_mat_req_rec.wip_entity_id is not null
                THEN
                  IF p_eam_mat_req_rec.operation_seq_num = 1 THEN
                    x_eam_mat_req_rec.department_id := null;
                  ELSE
                    select department_id into x_eam_mat_req_rec.department_id
                      from wip_operations
                      where wip_entity_id = p_eam_mat_req_rec.wip_entity_id
                      and organization_id = p_eam_mat_req_rec.organization_id
                      and operation_seq_num = p_eam_mat_req_rec.operation_seq_num;

                  END IF;
                END IF;

                l_out_eam_mat_req_rec := x_eam_mat_req_rec;

                get_flex_eam_mat_req
                (  p_eam_mat_req_rec => x_eam_mat_req_rec
                 , x_eam_mat_req_rec => l_out_eam_mat_req_rec
                 );

                x_eam_mat_req_rec := l_out_eam_mat_req_rec;

             EXCEPTION
                WHEN OTHERS THEN
                     EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                     (  p_message_name       => NULL
                      , p_message_text       => G_PKG_NAME || SQLERRM
                      , x_mesg_token_Tbl     => x_mesg_token_tbl
                     );

                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Attribute_Defaulting;


        /******************************************************************
        * Procedure     : Populate_Null_Columns
        * Parameters IN : Material Requirements column record
        *                 Old Material Requirements Column Record
        * Parameters OUT NOCOPY: Material Requirements column record after populating
        * Purpose       : This procedure will look at the columns that the user
        *                 has not filled in and will assign those columns a
        *                 value from the old record.
        *                 This procedure is not called for CREATE
        ********************************************************************/
        PROCEDURE Populate_Null_Columns
        (  p_eam_mat_req_rec           IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , p_old_eam_mat_req_rec       IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_eam_mat_req_rec           OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
        )
        IS
        BEGIN
                x_eam_mat_req_rec := p_eam_mat_req_rec;
--                x_eam_mat_req_rec := p_eam_mat_req_rec;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing null columns prior update'); END IF;

                IF p_eam_mat_req_rec.quantity_per_assembly IS NULL OR
                   p_eam_mat_req_rec.quantity_per_assembly = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.quantity_per_assembly := p_old_eam_mat_req_rec.quantity_per_assembly;
                END IF;

                IF p_eam_mat_req_rec.department_id IS NULL OR
                   p_eam_mat_req_rec.department_id = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.department_id := p_old_eam_mat_req_rec.department_id;
                END IF;

                IF p_eam_mat_req_rec.wip_supply_type IS NULL OR
                   p_eam_mat_req_rec.wip_supply_type = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.wip_supply_type := p_old_eam_mat_req_rec.wip_supply_type;
                END IF;

                IF p_eam_mat_req_rec.date_required IS NULL OR
                   p_eam_mat_req_rec.date_required = FND_API.G_MISS_DATE
                THEN
                   x_eam_mat_req_rec.date_required := p_old_eam_mat_req_rec.date_required;
                END IF;

                IF p_eam_mat_req_rec.required_quantity IS NULL OR
                   p_eam_mat_req_rec.required_quantity = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.required_quantity := p_old_eam_mat_req_rec.required_quantity;
                END IF;

                IF p_eam_mat_req_rec.quantity_issued IS NULL OR
                   p_eam_mat_req_rec.quantity_issued = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.quantity_issued := p_old_eam_mat_req_rec.quantity_issued;
                END IF;

		--fix for 3572280
                IF p_eam_mat_req_rec.released_quantity IS NULL OR
                   p_eam_mat_req_rec.released_quantity = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.released_quantity := p_old_eam_mat_req_rec.released_quantity;
                END IF;

                IF p_eam_mat_req_rec.supply_subinventory IS NULL OR
                   p_eam_mat_req_rec.supply_subinventory = FND_API.G_MISS_CHAR
                THEN
                   x_eam_mat_req_rec.supply_subinventory := p_old_eam_mat_req_rec.supply_subinventory;
                END IF;

                IF p_eam_mat_req_rec.supply_locator_id IS NULL OR
                   p_eam_mat_req_rec.supply_locator_id = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.supply_locator_id := p_old_eam_mat_req_rec.supply_locator_id;
                END IF;

                IF p_eam_mat_req_rec.mrp_net_flag IS NULL OR
                   p_eam_mat_req_rec.mrp_net_flag = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.mrp_net_flag := p_old_eam_mat_req_rec.mrp_net_flag;
                END IF;

                IF p_eam_mat_req_rec.mps_required_quantity IS NULL OR
                   p_eam_mat_req_rec.mps_required_quantity = FND_API.G_MISS_NUM
                THEN
                    x_eam_mat_req_rec.mps_required_quantity := p_old_eam_mat_req_rec.mps_required_quantity;
                END IF;

                IF p_eam_mat_req_rec.mps_date_required IS NULL OR
                   p_eam_mat_req_rec.mps_date_required = FND_API.G_MISS_DATE
                THEN
                   x_eam_mat_req_rec.mps_date_required := p_old_eam_mat_req_rec.mps_date_required;
                END IF;

                IF p_eam_mat_req_rec.component_sequence_id IS NULL OR
                   p_eam_mat_req_rec.component_sequence_id = FND_API.G_MISS_NUM
                THEN
                    x_eam_mat_req_rec.component_sequence_id := p_old_eam_mat_req_rec.component_sequence_id;
                END IF;

                IF p_eam_mat_req_rec.comments IS NULL OR
                   p_eam_mat_req_rec.comments = FND_API.G_MISS_CHAR
                THEN
                    x_eam_mat_req_rec.comments := p_old_eam_mat_req_rec.comments;
                END IF;

                --
                -- Populate Null or missng flex field columns
                --
                IF p_eam_mat_req_rec.attribute_category IS NULL OR
                   p_eam_mat_req_rec.attribute_category = FND_API.G_MISS_CHAR
                THEN
                        x_eam_mat_req_rec.attribute_category := p_old_eam_mat_req_rec.attribute_category;

                END IF;

                IF p_eam_mat_req_rec.attribute1 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute1 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute1  := p_old_eam_mat_req_rec.attribute1;
                END IF;

                IF p_eam_mat_req_rec.attribute2 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute2 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute2  := p_old_eam_mat_req_rec.attribute2;
                END IF;

                IF p_eam_mat_req_rec.attribute3 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute3 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute3  := p_old_eam_mat_req_rec.attribute3;
                END IF;

                IF p_eam_mat_req_rec.attribute4 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute4 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute4  := p_old_eam_mat_req_rec.attribute4;
                END IF;

                IF p_eam_mat_req_rec.attribute5 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute5 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute5  := p_old_eam_mat_req_rec.attribute5;
                END IF;

                IF p_eam_mat_req_rec.attribute6 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute6 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute6  := p_old_eam_mat_req_rec.attribute6;
                END IF;

                IF p_eam_mat_req_rec.attribute7 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute7 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute7  := p_old_eam_mat_req_rec.attribute7;
                END IF;

                IF p_eam_mat_req_rec.attribute8 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute8 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute8  := p_old_eam_mat_req_rec.attribute8;
                END IF;

                IF p_eam_mat_req_rec.attribute9 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute9 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute9  := p_old_eam_mat_req_rec.attribute9;
                END IF;

                IF p_eam_mat_req_rec.attribute10 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute10 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute10 := p_old_eam_mat_req_rec.attribute10;
                END IF;

                IF p_eam_mat_req_rec.attribute11 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute11 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute11 := p_old_eam_mat_req_rec.attribute11;
                END IF;

                IF p_eam_mat_req_rec.attribute12 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute12 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute12 := p_old_eam_mat_req_rec.attribute12;
                END IF;

                IF p_eam_mat_req_rec.attribute13 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute13 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute13 := p_old_eam_mat_req_rec.attribute13;
                END IF;

                IF p_eam_mat_req_rec.attribute14 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute14 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute14 := p_old_eam_mat_req_rec.attribute14;
                END IF;

                IF p_eam_mat_req_rec.attribute15 = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.attribute15 IS NULL
                THEN
                        x_eam_mat_req_rec.attribute15 := p_old_eam_mat_req_rec.attribute15;
                END IF;

                IF p_eam_mat_req_rec.auto_request_material = FND_API.G_MISS_CHAR OR
                   p_eam_mat_req_rec.auto_request_material IS NULL
                THEN
                        x_eam_mat_req_rec.auto_request_material := p_old_eam_mat_req_rec.auto_request_material;
                END IF;

                IF  p_eam_mat_req_rec.unit_price IS NULL OR
                    p_eam_mat_req_rec.unit_price = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.unit_price := p_old_eam_mat_req_rec.unit_price;
                END IF;

  		IF  p_eam_mat_req_rec.suggested_vendor_name IS NULL OR
                    p_eam_mat_req_rec.suggested_vendor_name = FND_API.G_MISS_CHAR
                THEN
                   x_eam_mat_req_rec.suggested_vendor_name := p_old_eam_mat_req_rec.suggested_vendor_name;
                END IF;

                IF  p_eam_mat_req_rec.vendor_id IS NULL OR
                    p_eam_mat_req_rec.vendor_id = FND_API.G_MISS_NUM
                THEN
                   x_eam_mat_req_rec.vendor_id := p_old_eam_mat_req_rec.vendor_id;
                END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Done processing null columns prior update'); END IF;


        END Populate_Null_Columns;



        /******************************************************************
        * Procedure     : GetMaterials_In_Op1
        * Parameters IN : Material Requirements table
        *                       Organization_ID
		                         Wip_Entity_Id
        * Parameters OUT NOCOPY: Material Requirements table after populating
        * Purpose       : This procedure will find all the materials that are
        *                     in operation seq num 1 and append them to the
        *                     table.
		*                     This procedure is called only when there exists any material in operation 1
        ********************************************************************/

       PROCEDURE GetMaterials_In_Op1
        (   p_eam_mat_req_tbl     IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
          , p_organization_id         IN  NUMBER
          , p_wip_entity_id           IN  NUMBER
          , x_eam_mat_req_tbl      OUT  NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        )
		IS
		l_eam_mat_req_tbl  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type := p_eam_mat_req_tbl;
		k            NUMBER :=  l_eam_mat_req_tbl.COUNT ;

		CURSOR MaterialREQ IS
		SELECT
		      WIP_ENTITY_ID                 WIP_ENTITY_ID
			, ORGANIZATION_ID               ORGANIZATION_ID
			, OPERATION_SEQ_NUM             OPERATION_SEQ_NUM
			, INVENTORY_ITEM_ID             INVENTORY_ITEM_ID
			, 2                                   TRANSACTION_TYPE
	     FROM wip_requirement_operations
		 WHERE organization_id = p_organization_id
		 and wip_entity_id = p_wip_entity_id
		 and operation_seq_num = 1;


		BEGIN

		   FOR matreq IN MaterialREQ LOOP
		      k := k + 1 ;

		      l_eam_mat_req_tbl(k).WIP_ENTITY_ID := matreq.WIP_ENTITY_ID;
			  l_eam_mat_req_tbl(k).ORGANIZATION_ID := matreq.ORGANIZATION_ID;
			  l_eam_mat_req_tbl(k).OPERATION_SEQ_NUM := matreq.OPERATION_SEQ_NUM;
              l_eam_mat_req_tbl(k).INVENTORY_ITEM_ID := matreq.INVENTORY_ITEM_ID;
			  l_eam_mat_req_tbl(k).TRANSACTION_TYPE := matreq.TRANSACTION_TYPE ;

		   END LOOP;
           x_eam_mat_req_tbl := l_eam_mat_req_tbl ;

		END GetMaterials_In_Op1 ;


        /******************************************************************
        * Procedure     : Change_OpSeqNum1
        * Parameters IN : Material Requirements column record
        *                       Operation Sequence Number
		                         Department Id
        * Parameters OUT NOCOPY: Material Requirements column record after changing
        * Purpose       : This procedure will change the operation seq num from 1
        *                     to the newly created operation ( p_operation_seq_num )
        *                     and accordingly the department id
        *                     This procedure is called only when there exists any material in operation 1
        ********************************************************************/
		PROCEDURE Change_OpSeqNum1
	    (   p_eam_mat_req_rec     IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
		  , p_operation_seq_num   IN   NUMBER
	      , p_department_id          IN NUMBER
		  , x_eam_mat_req_rec      OUT  NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
        )
        IS
        l_eam_mat_req_rec EAM_PROCESS_WO_PUB.eam_mat_req_rec_type := p_eam_mat_req_rec;

		BEGIN

            IF ( l_eam_mat_req_rec.operation_seq_num = 1 ) THEN
                l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num ;
                l_eam_mat_req_rec.department_id := p_department_id ;
            END IF;

            x_eam_mat_req_rec := l_eam_mat_req_rec ;

        END Change_OpSeqNum1;



END EAM_MAT_REQ_DEFAULT_PVT;

/
