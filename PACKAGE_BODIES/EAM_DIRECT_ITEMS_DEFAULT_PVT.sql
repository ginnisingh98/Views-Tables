--------------------------------------------------------
--  DDL for Package Body EAM_DIRECT_ITEMS_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_DIRECT_ITEMS_DEFAULT_PVT" AS
/* $Header: EAMVDIDB.pls 115.2 2003/09/26 03:48:56 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVDIDB.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_DIRECT_ITEMS_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  15-SEP-2003    Basanth Roy     Initial Creation
***************************************************************************/
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_DIRECT_ITEMS_DEFAULT_PVT';


        /********************************************************************
        * Function      : get_di_seq_id
        * Return        : NUMBER
        * Purpose       : Function will return direct_item_sequence_id
        *
        **********************************************************************/

        FUNCTION get_di_seq_id
        RETURN NUMBER
        IS
                l_di_seq_id      NUMBER := NULL;
        BEGIN

                SELECT wip_eam_di_seq_id_s.nextval
                INTO   l_di_seq_id
                FROM   sys.dual;

                RETURN l_di_seq_id;

         EXCEPTION
                WHEN OTHERS THEN
                        RETURN NULL;

        END get_di_seq_id;



        /********************************************************************
        * Procedure     : get_flex_eam_direct_items
        * Return        : NUMBER
        **********************************************************************/


        PROCEDURE get_flex_eam_direct_items
          (  p_eam_direct_items_rec IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
           , x_eam_direct_items_rec OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
          )
        IS
        BEGIN

            --  In the future call Flex APIs for defaults
                x_eam_direct_items_rec := p_eam_direct_items_rec;

                IF p_eam_direct_items_rec.attribute_category =FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute_category := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute1  := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute2 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute2  := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute3  := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute4  := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute5  := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute6  := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute7  := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute8  := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute9  := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute10 := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute11 := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute12 := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute13 := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute14 := NULL;
                END IF;

                IF p_eam_direct_items_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                        x_eam_direct_items_rec.attribute15 := NULL;
                END IF;

        END get_flex_eam_direct_items;


        /*********************************************************************
        * Procedure     : Attribute_Defaulting
        * Parameters IN : Direct Items record
        * Parameters OUT NOCOPY: Direct Items record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Attribute Defaulting will default the necessary null
        *                 attribute with appropriate values.
        **********************************************************************/

        PROCEDURE Attribute_Defaulting
        (  p_eam_direct_items_rec              IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_eam_direct_items_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         )
        IS
          l_out_eam_direct_items_rec EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;
        BEGIN

                x_eam_direct_items_rec := p_eam_direct_items_rec;
--                x_eam_direct_items_rec := p_eam_direct_items_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                IF p_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
                then
                  -- Defaulting direct_item_sequence_id
                  x_eam_direct_items_rec.direct_item_sequence_id := get_di_seq_id;
                END IF;

                -- Defaulting AUTO_REQUEST_MATERIAL flag.
                IF p_eam_direct_items_rec.auto_request_material IS NULL OR
                   p_eam_direct_items_rec.auto_request_material = FND_API.G_MISS_CHAR
                THEN
                   x_eam_direct_items_rec.auto_request_material := 'Y';
                END IF;

                -- Defaulting department_id
                IF (p_eam_direct_items_rec.department_id IS NULL OR
                    p_eam_direct_items_rec.department_id = FND_API.G_MISS_NUM) AND
                   p_eam_direct_items_rec.operation_seq_num is not null AND
                   p_eam_direct_items_rec.organization_id is not null AND
                   p_eam_direct_items_rec.wip_entity_id is not null
                THEN
                  IF p_eam_direct_items_rec.operation_seq_num = 1 THEN
                    x_eam_direct_items_rec.department_id := null;
                  ELSE
                    select department_id into x_eam_direct_items_rec.department_id
                      from wip_operations
                      where wip_entity_id = p_eam_direct_items_rec.wip_entity_id
                      and organization_id = p_eam_direct_items_rec.organization_id
                      and operation_seq_num = p_eam_direct_items_rec.operation_seq_num;

                  END IF;
                END IF;

                l_out_eam_direct_items_rec := x_eam_direct_items_rec;

                get_flex_eam_direct_items
                (  p_eam_direct_items_rec => x_eam_direct_items_rec
                 , x_eam_direct_items_rec => l_out_eam_direct_items_rec
                 );

                x_eam_direct_items_rec := l_out_eam_direct_items_rec;

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
        * Parameters IN : Direct Items column record
        *                 Old Direct Items Column Record
        * Parameters OUT NOCOPY: Direct Items column record after populating
        * Purpose       : This procedure will look at the columns that the user
        *                 has not filled in and will assign those columns a
        *                 value from the old record.
        *                 This procedure is not called for CREATE
        ********************************************************************/
        PROCEDURE Populate_Null_Columns
        (  p_eam_direct_items_rec           IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , p_old_eam_direct_items_rec       IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_eam_direct_items_rec           OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
        )
        IS
        BEGIN
                x_eam_direct_items_rec := p_eam_direct_items_rec;
--                x_eam_direct_items_rec := p_eam_direct_items_rec;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing null columns prior update'); END IF;


                IF p_eam_direct_items_rec.description IS NULL OR
                   p_eam_direct_items_rec.description = FND_API.G_MISS_CHAR
                THEN
                   x_eam_direct_items_rec.description := p_old_eam_direct_items_rec.description;
                END IF;

                IF p_eam_direct_items_rec.purchasing_category_id IS NULL OR
                   p_eam_direct_items_rec.purchasing_category_id = FND_API.G_MISS_NUM
                THEN
                   x_eam_direct_items_rec.purchasing_category_id := p_old_eam_direct_items_rec.purchasing_category_id;
                END IF;

                IF p_eam_direct_items_rec.uom IS NULL OR
                   p_eam_direct_items_rec.uom = FND_API.G_MISS_CHAR
                THEN
                   x_eam_direct_items_rec.uom := p_old_eam_direct_items_rec.uom;
                END IF;

                IF p_eam_direct_items_rec.suggested_vendor_name IS NULL OR
                   p_eam_direct_items_rec.suggested_vendor_name = FND_API.G_MISS_CHAR
                THEN
                   x_eam_direct_items_rec.suggested_vendor_name := p_old_eam_direct_items_rec.suggested_vendor_name;
                END IF;

                IF p_eam_direct_items_rec.suggested_vendor_id IS NULL OR
                   p_eam_direct_items_rec.suggested_vendor_id = FND_API.G_MISS_NUM
                THEN
                   x_eam_direct_items_rec.suggested_vendor_id := p_old_eam_direct_items_rec.suggested_vendor_id;
                END IF;

                IF p_eam_direct_items_rec.suggested_vendor_site IS NULL OR
                   p_eam_direct_items_rec.suggested_vendor_site = FND_API.G_MISS_CHAR
                THEN
                   x_eam_direct_items_rec.suggested_vendor_site := p_old_eam_direct_items_rec.suggested_vendor_site;
                END IF;

                IF p_eam_direct_items_rec.suggested_vendor_site_id IS NULL OR
                   p_eam_direct_items_rec.suggested_vendor_site_id = FND_API.G_MISS_NUM
                THEN
                   x_eam_direct_items_rec.suggested_vendor_site_id := p_old_eam_direct_items_rec.suggested_vendor_site_id;
                END IF;

                IF p_eam_direct_items_rec.suggested_vendor_contact IS NULL OR
                   p_eam_direct_items_rec.suggested_vendor_contact = FND_API.G_MISS_CHAR
                THEN
                   x_eam_direct_items_rec.suggested_vendor_contact := p_old_eam_direct_items_rec.suggested_vendor_contact;
                END IF;

                IF p_eam_direct_items_rec.suggested_vendor_contact_id IS NULL OR
                   p_eam_direct_items_rec.suggested_vendor_contact_id = FND_API.G_MISS_NUM
                THEN
                   x_eam_direct_items_rec.suggested_vendor_contact_id := p_old_eam_direct_items_rec.suggested_vendor_contact_id;
                END IF;

                IF p_eam_direct_items_rec.suggested_vendor_phone IS NULL OR
                   p_eam_direct_items_rec.suggested_vendor_phone = FND_API.G_MISS_CHAR
                THEN
                   x_eam_direct_items_rec.suggested_vendor_phone := p_old_eam_direct_items_rec.suggested_vendor_phone;
                END IF;

                IF p_eam_direct_items_rec.suggested_vendor_item_num IS NULL OR
                   p_eam_direct_items_rec.suggested_vendor_item_num = FND_API.G_MISS_CHAR
                THEN
                   x_eam_direct_items_rec.suggested_vendor_item_num := p_old_eam_direct_items_rec.suggested_vendor_item_num;
                END IF;

                IF p_eam_direct_items_rec.unit_price IS NULL OR
                   p_eam_direct_items_rec.unit_price = FND_API.G_MISS_NUM
                THEN
                   x_eam_direct_items_rec.unit_price := p_old_eam_direct_items_rec.unit_price;
                END IF;

                IF p_eam_direct_items_rec.department_id IS NULL OR
                   p_eam_direct_items_rec.department_id = FND_API.G_MISS_NUM
                THEN
                   x_eam_direct_items_rec.department_id := p_old_eam_direct_items_rec.department_id;
                END IF;


                IF p_eam_direct_items_rec.need_by_date IS NULL OR
                   p_eam_direct_items_rec.need_by_date = FND_API.G_MISS_DATE
                THEN
                   x_eam_direct_items_rec.need_by_date := p_old_eam_direct_items_rec.need_by_date;
                END IF;

                IF p_eam_direct_items_rec.required_quantity IS NULL OR
                   p_eam_direct_items_rec.required_quantity = FND_API.G_MISS_NUM
                THEN
                   x_eam_direct_items_rec.required_quantity := p_old_eam_direct_items_rec.required_quantity;
                END IF;

                --
                -- Populate Null or missng flex field columns
                --
                IF p_eam_direct_items_rec.attribute_category IS NULL OR
                   p_eam_direct_items_rec.attribute_category = FND_API.G_MISS_CHAR
                THEN
                        x_eam_direct_items_rec.attribute_category := p_old_eam_direct_items_rec.attribute_category;

                END IF;

                IF p_eam_direct_items_rec.attribute1 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute1 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute1  := p_old_eam_direct_items_rec.attribute1;
                END IF;

                IF p_eam_direct_items_rec.attribute2 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute2 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute2  := p_old_eam_direct_items_rec.attribute2;
                END IF;

                IF p_eam_direct_items_rec.attribute3 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute3 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute3  := p_old_eam_direct_items_rec.attribute3;
                END IF;

                IF p_eam_direct_items_rec.attribute4 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute4 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute4  := p_old_eam_direct_items_rec.attribute4;
                END IF;

                IF p_eam_direct_items_rec.attribute5 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute5 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute5  := p_old_eam_direct_items_rec.attribute5;
                END IF;

                IF p_eam_direct_items_rec.attribute6 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute6 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute6  := p_old_eam_direct_items_rec.attribute6;
                END IF;

                IF p_eam_direct_items_rec.attribute7 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute7 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute7  := p_old_eam_direct_items_rec.attribute7;
                END IF;

                IF p_eam_direct_items_rec.attribute8 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute8 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute8  := p_old_eam_direct_items_rec.attribute8;
                END IF;

                IF p_eam_direct_items_rec.attribute9 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute9 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute9  := p_old_eam_direct_items_rec.attribute9;
                END IF;

                IF p_eam_direct_items_rec.attribute10 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute10 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute10 := p_old_eam_direct_items_rec.attribute10;
                END IF;

                IF p_eam_direct_items_rec.attribute11 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute11 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute11 := p_old_eam_direct_items_rec.attribute11;
                END IF;

                IF p_eam_direct_items_rec.attribute12 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute12 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute12 := p_old_eam_direct_items_rec.attribute12;
                END IF;

                IF p_eam_direct_items_rec.attribute13 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute13 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute13 := p_old_eam_direct_items_rec.attribute13;
                END IF;

                IF p_eam_direct_items_rec.attribute14 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute14 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute14 := p_old_eam_direct_items_rec.attribute14;
                END IF;

                IF p_eam_direct_items_rec.attribute15 = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.attribute15 IS NULL
                THEN
                        x_eam_direct_items_rec.attribute15 := p_old_eam_direct_items_rec.attribute15;
                END IF;

                IF p_eam_direct_items_rec.auto_request_material = FND_API.G_MISS_CHAR OR
                   p_eam_direct_items_rec.auto_request_material IS NULL
                THEN
                        x_eam_direct_items_rec.auto_request_material := p_old_eam_direct_items_rec.auto_request_material;
                END IF;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Done processing null columns prior update'); END IF;


        END Populate_Null_Columns;



        /******************************************************************
        * Procedure     : GetDI_In_Op1
        * Parameters IN : Direct Items table
        *                       Organization_ID
		                         Wip_Entity_Id
        * Parameters OUT NOCOPY: Direct Items table after populating
        * Purpose       : This procedure will find all the direct items that are
        *          in operation seq num 1 and append them to the table.
        *          This procedure is called only when there exists any DI in operation 1
        ********************************************************************/

       PROCEDURE GetDI_In_Op1
        (   p_eam_direct_items_tbl     IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
          , p_organization_id         IN  NUMBER
          , p_wip_entity_id           IN  NUMBER
          , x_eam_direct_items_tbl      OUT  NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        )
		IS
		l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type := p_eam_direct_items_tbl;
		k            NUMBER :=  l_eam_direct_items_tbl.COUNT ;

		CURSOR DIRECT_ITEMS_CUR IS
		SELECT
		      WIP_ENTITY_ID                 WIP_ENTITY_ID
			, ORGANIZATION_ID               ORGANIZATION_ID
			, OPERATION_SEQ_NUM             OPERATION_SEQ_NUM
			, DIRECT_ITEM_SEQUENCE_ID             DIRECT_ITEM_SEQUENCE_ID
			, 2                                   TRANSACTION_TYPE
	     FROM wip_eam_direct_items
		 WHERE organization_id = p_organization_id
		 and wip_entity_id = p_wip_entity_id
		 and operation_seq_num = 1;


		BEGIN

		   FOR direc IN DIRECT_ITEMS_CUR LOOP
		      k := k + 1 ;

		      l_eam_direct_items_tbl(k).WIP_ENTITY_ID := direc.WIP_ENTITY_ID;
			  l_eam_direct_items_tbl(k).ORGANIZATION_ID := direc.ORGANIZATION_ID;
			  l_eam_direct_items_tbl(k).OPERATION_SEQ_NUM := direc.OPERATION_SEQ_NUM;
              l_eam_direct_items_tbl(k).DIRECT_ITEM_SEQUENCE_ID := direc.DIRECT_ITEM_SEQUENCE_ID;
			  l_eam_direct_items_tbl(k).TRANSACTION_TYPE := direc.TRANSACTION_TYPE ;

		   END LOOP;
           x_eam_direct_items_tbl := l_eam_direct_items_tbl ;

		END GetDI_In_Op1 ;


        /******************************************************************
        * Procedure     : Change_OpSeqNum1
        * Parameters IN : Direct Items column record
        *                       Operation Sequence Number
		                         Department Id
        * Parameters OUT NOCOPY: Direct Items column record after changing
        * Purpose       : This procedure will change the operation seq num from 1
        *           to the newly created operation ( p_operation_seq_num )
        *           and accordingly the department id
        *           This procedure is called only when there exists any direct items in operation 1
        ********************************************************************/
		PROCEDURE Change_OpSeqNum1
	    (   p_eam_direct_items_rec     IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
		  , p_operation_seq_num   IN   NUMBER
	      , p_department_id          IN NUMBER
		  , x_eam_direct_items_rec      OUT  NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
        )
        IS
        l_eam_direct_items_rec EAM_PROCESS_WO_PUB.eam_direct_items_rec_type := p_eam_direct_items_rec;

		BEGIN

            IF ( l_eam_direct_items_rec.operation_seq_num = 1 ) THEN
                l_eam_direct_items_rec.operation_seq_num := p_operation_seq_num ;
                l_eam_direct_items_rec.department_id := p_department_id ;
            END IF;

            x_eam_direct_items_rec := l_eam_direct_items_rec ;

        END Change_OpSeqNum1;



END EAM_DIRECT_ITEMS_DEFAULT_PVT;

/
