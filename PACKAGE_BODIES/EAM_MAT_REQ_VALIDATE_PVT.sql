--------------------------------------------------------
--  DDL for Package Body EAM_MAT_REQ_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MAT_REQ_VALIDATE_PVT" AS
/* $Header: EAMVMRVB.pls 120.2.12010000.3 2011/02/22 11:50:36 rsandepo ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMRVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_MAT_REQ_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_MAT_REQ_VALIDATE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;


    /*******************************************************************
    * Procedure	: Check_Existence
    * Returns	: None
    * Parameters IN : Material Requirements Record
    * Parameters OUT NOCOPY: Old Material Requirements Record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: Procedure will query the old EAM work order
    *             record and return it in old record variables. If the
    *             Transaction Type is Create and the record already
    *             exists the return status would be error or if the
    *             transaction type is Update and the record
    *             does not exist then the return status would be an
    *             error as well. Mesg_Token_Table will carry the
    *             error messsage and the tokens associated with the
    *             message.
    *********************************************************************/

     PROCEDURE Check_Existence
     ( p_eam_mat_req_rec        IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
     , x_old_eam_mat_req_rec    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
     , x_Mesg_Token_Tbl	        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , x_return_status	        OUT NOCOPY VARCHAR2
        )
     IS
            l_token_tbl         EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
            l_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_return_status     VARCHAR2(1);
	    l_inventory_item_name   VARCHAR2(240);
     BEGIN

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quering Material Requirement'); END IF;

        EAM_MAT_REQ_UTILITY_PVT.Query_Row
        ( p_wip_entity_id       => p_eam_mat_req_rec.wip_entity_id
        , p_organization_id     => p_eam_mat_req_rec.organization_id
        , p_operation_seq_num   => p_eam_mat_req_rec.operation_seq_num
        , p_inventory_item_id   => p_eam_mat_req_rec.inventory_item_id
        , x_eam_mat_req_rec     => x_old_eam_mat_req_rec
        , x_Return_status       => l_return_status
        );

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Query Row Returned with : ' || l_return_status); END IF;

        IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND AND
            p_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN
	    --Start bug# 11672256
            SELECT segment1 INTO l_inventory_item_name FROM mtl_system_items WHERE  inventory_item_id=p_eam_mat_req_rec.inventory_item_id AND organization_id=p_eam_mat_req_rec.organization_id;
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_NAME';
            l_token_tbl(1).token_value := l_inventory_item_name;
            --End bug# 11672256

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_MR_ALREADY_EXISTS'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND AND
             p_eam_mat_req_rec.transaction_type IN
             (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'EAM_MR_DOESNOT_EXISTS'
                         , p_token_tbl      => l_token_tbl
                         );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF l_Return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl     => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
             , p_message_name       => NULL
             , p_message_text       => 'Unexpected error while existence verification of ' || 'Material Requirement '|| p_eam_mat_req_rec.inventory_item_id , p_token_tbl => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        ELSE /* Assign the relevant transaction type for SYNC operations */
            IF p_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
               IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND THEN
                   x_old_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
               ELSE
                   x_old_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
               END IF;
            END IF;
            l_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;
    END Check_Existence;



    /********************************************************************
    * Procedure     : Check_Attributes
    * Parameters IN : Material Requirements Column record
    *                 Old Material Requirements Column record
    * Parameters OUT NOCOPY: Return Status
    *                 Mesg Token Table
    * Purpose       : Check_Attrbibutes procedure will validate every
    *                 revised item attrbiute in its entirety.
    **********************************************************************/

    PROCEDURE Check_Attributes
        (  p_eam_mat_req_rec              IN EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , p_old_eam_mat_req_rec          IN EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
    )
    IS
    l_err_text              VARCHAR2(2000) := NULL;
    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    g_dummy          NUMBER;
    l_ordered_quantity  NUMBER;
    l_stockable_flag VARCHAR2(1);
    l_allocated     NUMBER;
    l_uom VARCHAR2(5);
    l_material_issue_by_mo   VARCHAR2(1);

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within Material Requirement Check Attributes . . . '); END IF;


--  operation_seq_num

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating operation_seq_num . . . '); END IF;

        begin

       if (p_eam_mat_req_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

         begin
           select 1
             into g_dummy
             from wip_operations wo
             where wo.organization_id = p_eam_mat_req_rec.organization_id
             and wo.wip_entity_id = p_eam_mat_req_rec.wip_entity_id
             and wo.operation_seq_num = p_eam_mat_req_rec.operation_seq_num;
         exception
           when others then
             if p_eam_mat_req_rec.operation_seq_num <> 1 then
               raise fnd_api.g_exc_error;
             end if;
             if p_eam_mat_req_rec.operation_seq_num = 1 and
                p_eam_mat_req_rec.department_id is not null then
               raise fnd_api.g_exc_error;
             end if;
         end;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'OP_SEQ_NUM';
           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_OP_SEQ_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;


     --  inventory_item_id
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating inventory_item_id . . . '); END IF;

       declare
         l_stockable_flag  VARCHAR2(2);
         NOT_PURCHASABLE   EXCEPTION;
         l_count NUMBER;
       begin

       if (p_eam_mat_req_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

	-- Fix for bug# 3602041 - Removed check for bom_enabled flag in the where clause of the query
           select 1
             into g_dummy
             from mtl_system_items
            where inventory_item_id = p_eam_mat_req_rec.inventory_item_id
              and organization_id = p_eam_mat_req_rec.organization_id
			  and ( bom_item_type  = 4
              and ( eam_item_type  IS NULL or eam_item_type  = 3 or eam_item_type = 1) );

	  /* Check added so that assets and activities are not included */


          -- Check that if item is stockable, then it is also purchased
          -- and purchasable
          select stock_enabled_flag into l_stockable_flag
            from mtl_system_items where
            inventory_item_id =  p_eam_mat_req_rec.inventory_item_id
            and organization_id = p_eam_mat_req_rec.organization_id;
          if l_stockable_flag = 'N' then
            select count(*) into l_count from mtl_system_items
              where inventory_item_id =  p_eam_mat_req_rec.inventory_item_id
              and organization_id = p_eam_mat_req_rec.organization_id
              and purchasing_enabled_flag = 'Y'
              and purchasing_item_flag = 'Y';
            if l_count <> 1 then
              raise NOT_PURCHASABLE;
            end if;
          end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception

         when NOT_PURCHASABLE then

           l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_ITEM_NOT_PURCH'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

         when others then

           l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_INV_ITEM_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;


     --  quantity_per_assembly
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating quantity_per_assembly . . . '); END IF;

       begin

       if (p_eam_mat_req_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

         if p_eam_mat_req_rec.quantity_per_assembly < 0 then
           raise fnd_api.g_exc_unexpected_error;
         end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'QUANTITY_PER_ASSEMBLY';
           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.quantity_per_assembly;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_QTY_PER_ASSY_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;


     --  supply_subinventory
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating supply_subinventory . . . '); END IF;

       begin

       if (p_eam_mat_req_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

        if p_eam_mat_req_rec.supply_subinventory is not null then
         select 1 into g_dummy
           from mtl_secondary_inventories msinv
           where nvl(msinv.disable_date, sysdate+2) > sysdate
           and msinv.organization_id = p_eam_mat_req_rec.organization_id
           and msinv.secondary_inventory_name = p_eam_mat_req_rec.supply_subinventory;
        end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'SUPPLY_SUB';
           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.supply_subinventory;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_SUPPLY_SUB_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;



     --  supply_locator_id
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating supply_locator_id . . . '); END IF;

       begin

       if (p_eam_mat_req_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

         if p_eam_mat_req_rec.supply_locator_id is not null then
          select 1 into g_dummy
            from mtl_item_locations_kfv
            where (disable_date > sysdate or disable_date is null)
            and organization_id = p_eam_mat_req_rec.organization_id
            and subinventory_code = p_eam_mat_req_rec.supply_subinventory
            and inventory_location_id = p_eam_mat_req_rec.supply_locator_id;
         end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'SUPPLY_LOC';
           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.supply_locator_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_SUPPLY_LOC_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;




     --  department_id
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating department_id . . . '); END IF;

       begin

       if (p_eam_mat_req_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

         if p_eam_mat_req_rec.department_id is null then

           if p_eam_mat_req_rec.operation_seq_num <> 1 then
             raise fnd_api.g_exc_error;
           end if;

         else

           select 1 into g_dummy
             from wip_operations where
             wip_entity_id = p_eam_mat_req_rec.wip_entity_id and
             organization_id = p_eam_mat_req_rec.organization_id and
             operation_seq_num = p_eam_mat_req_rec.operation_seq_num and
             department_id = p_eam_mat_req_rec.department_id;

           select 1 into g_dummy
             from bom_departments where
             department_id = p_eam_mat_req_rec.department_id
             and organization_id = p_eam_mat_req_rec.organization_id;

         end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'DEPARTMENT_NAME';
--           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.department_id;

	SELECT bd.department_code into l_token_tbl(1).token_value
            FROM  bom_departments bd
            WHERE          bd.DEPARTMENT_ID = p_eam_mat_req_rec.department_id
            AND     bd.organization_id   = p_eam_mat_req_rec.organization_id;



            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_DEPT_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;


     --  wip_supply_type
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating wip_supply_type . . . '); END IF;

       begin

       if (p_eam_mat_req_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then


           if(p_eam_mat_req_rec.wip_supply_type is not null and p_eam_mat_req_rec.wip_supply_type not in (wip_constants.push, wip_constants.bulk, wip_constants.based_on_bom)) then
             --not a valid supply type

             raise fnd_api.g_exc_unexpected_error;

           end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'WIP_SUPPLY_TYPE';
           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.wip_supply_type;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_SUPPLY_TYPE_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;


     --  mrp_net_flag
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating mrp_net_flag . . . '); END IF;

       begin

       if (p_eam_mat_req_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

         if p_eam_mat_req_rec.mrp_net_flag not in (wip_constants.yes, wip_constants.no) then
             raise fnd_api.g_exc_unexpected_error;
         end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'MRP_NET_FLAG';
           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.mrp_net_flag;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_MRP_NET_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;

    SELECT stock_enabled_flag,primary_uom_code
    INTO l_stockable_flag,l_uom
    FROM MTL_SYSTEM_ITEMS_KFV
    WHERE inventory_item_id = p_eam_mat_req_rec.inventory_item_id
    AND organization_id = p_eam_mat_req_rec.organization_id;

  IF(p_eam_mat_req_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_DELETE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) THEN
         l_allocated := EAM_MATERIAL_ALLOCQTY_PKG.allocated_quantity(
	                               p_eam_mat_req_rec.wip_entity_id,
				       p_eam_mat_req_rec.operation_seq_num,
       	                               p_eam_mat_req_rec.organization_id,
	                               p_eam_mat_req_rec.inventory_item_id);
  END IF;

IF(l_stockable_flag='Y') THEN
     --  delete material_requirement
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating material_requirement . . . '); END IF;

       declare
         l_count_mmt        NUMBER :=0;
         l_count_mmtt       NUMBER :=0;
         l_issued_qty       NUMBER :=0;
       begin

       if (p_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE) then

           select count(*)
             into l_count_mmtt
             from mtl_material_transactions_temp
            where transaction_source_id = p_eam_mat_req_rec.wip_entity_id
              and organization_id       = p_eam_mat_req_rec.organization_id
              and operation_seq_num     = p_eam_mat_req_rec.operation_seq_num
              and inventory_item_id     = p_eam_mat_req_rec.inventory_item_id;

           if(l_count_mmtt > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

           select count(*)
             into l_count_mmt
             from mtl_material_transactions
            where transaction_source_id = p_eam_mat_req_rec.wip_entity_id
              and organization_id       = p_eam_mat_req_rec.organization_id
              and operation_seq_num     = p_eam_mat_req_rec.operation_seq_num
              and inventory_item_id     = p_eam_mat_req_rec.inventory_item_id;

           if(l_count_mmt > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

           select quantity_issued
             into l_issued_qty
             from wip_requirement_operations
            where wip_entity_id     = p_eam_mat_req_rec.wip_entity_id
              and organization_id   = p_eam_mat_req_rec.organization_id
              and operation_seq_num = p_eam_mat_req_rec.operation_seq_num
              and inventory_item_id = p_eam_mat_req_rec.inventory_item_id;

           if(l_issued_qty <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_DELETE_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;



     --  Required Quantity
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating required_quantity . . . '); END IF;
    if (p_eam_mat_req_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
        and p_eam_mat_req_rec.required_quantity < p_old_eam_mat_req_rec.required_quantity) then
       begin

	select material_issue_by_mo
	into l_material_issue_by_mo
	from wip_discrete_jobs
	where organization_id=p_eam_mat_req_rec.organization_id
	and wip_entity_id=p_eam_mat_req_rec.wip_entity_id;

         if l_material_issue_by_mo='Y' and p_eam_mat_req_rec.required_quantity < nvl(p_eam_mat_req_rec.quantity_issued,0)+ nvl(l_allocated,0) then
             raise fnd_api.g_exc_unexpected_error;
         end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_MR_REQ_QTY_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;
   end if;
 --start of fix for 3352406
ELSE
   g_dummy:=0;
   l_ordered_quantity:=0;

IF(p_eam_mat_req_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_DELETE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) THEN
--Bug#3691325 If Po Quantity or Req Quantity is greater than zero,we cannot delete the direct item
--Bug#4862404 (appsperf) - Brought the eam_work_order_direct_items_v view query inline and removed all
--                         unnecessary columns/tables.
SELECT greatest(nvl(ewodi.po_quantity_ordered,0), nvl(ewodi.rql_quantity_ordered,0))
     INTO l_ordered_quantity
from
(
SELECT
wro.wip_entity_id,
wro.operation_seq_num,
wro.organization_id,
wro.inventory_item_id as item_id,
wro.quantity as rql_quantity_ordered,
sum(pd.quantity_ordered) as po_quantity_ordered
FROM ( SELECT wro.wip_entity_id, wro.operation_seq_num, wro.organization_id, wro.inventory_item_id,
/* sum(rql.quantity) quantity */
sum(Decode(upper(NVL(rqh.authorization_status, 'APPROVED')), 'CANCELLED', 0, 'REJECTED', 0, 'SYSTEM_SAVED',0,rql.quantity)) quantity
FROM (
 SELECT
wro.wip_entity_id, wro.operation_seq_num, wro.organization_id, wro.inventory_item_id
FROM wip_requirement_operations wro, mtl_system_items_kfv msi
WHERE msi.inventory_item_id = wro.inventory_item_id
AND msi.organization_id = wro.organization_id
AND nvl(msi.stock_enabled_flag, 'N') = 'N'
 )
wro,
po_requisition_lines_all rql,
po_requisition_headers_all rqh
WHERE
wro.wip_entity_id = rql.wip_entity_id (+)
AND wro.organization_id = rql.destination_organization_id (+)
AND wro.operation_seq_num = rql.wip_operation_seq_num (+)
AND rql.requisition_header_id = rqh.requisition_header_id(+)
/* AND upper(NVL(rqh.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED') */
AND rql.wip_resource_seq_num is null AND wro.inventory_item_id = rql.item_id (+)
GROUP BY
wro.wip_entity_id, wro.operation_seq_num, wro.organization_id,
wro.inventory_item_id)
wro,
( SELECT pd1.wip_entity_id,
         pd1.wip_operation_seq_num,
         pd1.destination_organization_id,
         pd1.wip_resource_seq_num,
         pd1.quantity_ordered,
         pol.item_id,
         pol.cancel_flag
FROM po_lines_all pol, po_distributions_all pd1
WHERE pol.po_line_id = pd1.po_line_id
AND upper(nvl(pol.cancel_flag, 'N')) <> 'Y') pd
WHERE wro.wip_entity_id = pd.wip_entity_id(+)
AND wro.organization_id = pd.destination_organization_id(+)
AND wro.operation_seq_num = pd.wip_operation_seq_num(+)
/*AND upper(nvl(pd.cancel_flag, 'N')) <> 'Y'  #7509781*/
AND pd.wip_resource_seq_num is null
AND wro.inventory_item_id = pd.item_id (+)
GROUP BY
wro.wip_entity_id, wro.operation_seq_num, wro.organization_id,
wro.inventory_item_id,
 wro.quantity
) ewodi
     WHERE ewodi.wip_entity_id= p_eam_mat_req_rec.wip_entity_id
     AND ewodi.operation_seq_num=p_eam_mat_req_rec.operation_seq_num
     AND ewodi.organization_id=p_eam_mat_req_rec.organization_id
     AND ewodi.item_id=p_eam_mat_req_rec.inventory_item_id;



     IF(p_eam_mat_req_rec.transaction_type =EAM_PROCESS_WO_PVT.G_OPR_DELETE) AND
        (l_ordered_quantity > 0) THEN
	   l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
           l_token_tbl(1).token_value :=  p_eam_mat_req_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_DI_DELETE_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;
  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Cannot delete non-stockable inventory item . . . '); END IF;

           x_return_status :=  EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;
     END IF;
END IF;
END IF;
--end of fix for 3352406

     --  delete material_requirement


    EXCEPTION
        WHEN OTHERS THEN

        l_token_tbl(1).token_name  := 'Validation (Check Attributes)';
        l_token_tbl(1).token_value :=  substrb(SQLERRM,1,200);

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
              EAM_ERROR_MESSAGE_PVT.Add_Error_Token
              (  p_message_name   => NULL
               , p_token_tbl      => l_token_tbl
               , p_mesg_token_tbl => l_mesg_token_tbl
               , x_mesg_token_tbl => l_out_mesg_token_tbl
              ) ;
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

              -- Return the status and message table.
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              x_mesg_token_tbl := l_mesg_token_tbl ;


    END Check_Attributes;

    /*********************************************************************
    * Procedure     : Check_Required
    * Parameters IN : Material Requirements column record
    * Parameters OUT NOCOPY: Mesg Token Table
    *                 Return_Status
    * Purpose       :
    **********************************************************************/

    PROCEDURE Check_Required
        (  p_eam_mat_req_rec             IN EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_return_status          OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )
    IS
            l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        IF p_eam_mat_req_rec.wip_entity_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_MR_ENTITY_ID_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_mat_req_rec.organization_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_MR_ORG_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_mat_req_rec.inventory_item_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_MR_INV_ITEM_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_mat_req_rec.operation_seq_num IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_MR_OP_SEQ_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_mat_req_rec.wip_supply_type IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_MR_SUPPLY_TYPE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_mat_req_rec.required_quantity IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_MR_REQUIRED_QTY_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_mat_req_rec.quantity_issued IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_MR_ISSUED_QTY_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_mat_req_rec.quantity_per_assembly IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_MR_ASSY_QTY_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_mat_req_rec.mrp_net_flag IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INVENTORY_ITEM_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.inventory_item_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_MR_MRP_NET_REQUIRED'
             , p_token_tbl	=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_mat_req_rec.date_required IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INV_ID';
            l_token_tbl(1).token_value :=  p_eam_mat_req_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_MR_DATE_REQ_REQUIRED'
             , p_token_tbl	=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    END Check_Required;

END EAM_MAT_REQ_VALIDATE_PVT;

/
