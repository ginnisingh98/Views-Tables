--------------------------------------------------------
--  DDL for Package Body EAM_DIRECT_ITEMS_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_DIRECT_ITEMS_VALIDATE_PVT" AS
/* $Header: EAMVDIVB.pls 120.1.12010000.2 2009/04/25 00:20:39 jvittes ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVDIVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_DIRECT_ITEMS_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  15-SEP-2003    Basanth Roy     Initial Creation
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_DIRECT_ITEMS_VALIDATE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;


    /*******************************************************************
    * Procedure	: Check_Existence
    * Returns	: None
    * Parameters IN : Direct Items Record
    * Parameters OUT NOCOPY: Old Direct Items Record
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
     ( p_eam_direct_items_rec        IN  EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
     , x_old_eam_direct_items_rec    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
     , x_Mesg_Token_Tbl	        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , x_return_status	        OUT NOCOPY VARCHAR2
        )
     IS
            l_token_tbl         EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
            l_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_return_status     VARCHAR2(1);
     BEGIN

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quering Direct Item'); END IF;

        EAM_DIRECT_ITEMS_UTILITY_PVT.Query_Row
        ( p_wip_entity_id       => p_eam_direct_items_rec.wip_entity_id
        , p_organization_id     => p_eam_direct_items_rec.organization_id
        , p_operation_seq_num   => p_eam_direct_items_rec.operation_seq_num
        , p_direct_item_sequence_id   => p_eam_direct_items_rec.direct_item_sequence_id
        , x_eam_direct_items_rec     => x_old_eam_direct_items_rec
        , x_Return_status       => l_return_status
        );

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Query Row Returned with : ' || l_return_status); END IF;

        IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND AND
            p_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN
            l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
            l_token_tbl(1).token_value := p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_DI_ALREADY_EXISTS'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND AND
             p_eam_direct_items_rec.transaction_type IN
             (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN
            l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
            l_token_tbl(1).token_value :=  p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'EAM_DI_DOESNOT_EXISTS'
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
             , p_message_text       => 'Unexpected error while existence verification of ' || 'Direct Item '|| p_eam_direct_items_rec.direct_item_sequence_id , p_token_tbl => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        ELSE /* Assign the relevant transaction type for SYNC operations */
            IF p_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
               IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND THEN
                   x_old_eam_direct_items_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
               ELSE
                   x_old_eam_direct_items_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
               END IF;
            END IF;
            l_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;
    END Check_Existence;



    /********************************************************************
    * Procedure     : Check_Attributes
    * Parameters IN : Direct Items Column record
    *                 Old Direct Items Column record
    * Parameters OUT NOCOPY: Return Status
    *                 Mesg Token Table
    * Purpose       : Check_Attrbibutes procedure will validate every
    *                 revised item attrbiute in its entirety.
    **********************************************************************/

    PROCEDURE Check_Attributes
        (  p_eam_direct_items_rec              IN EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , p_old_eam_direct_items_rec          IN EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
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

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within Direct Item Check Attributes . . . '); END IF;


     --  department_id
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating department_id . . . '); END IF;

       begin

       if (p_eam_direct_items_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

         if (p_eam_direct_items_rec.operation_seq_num = 1 and
             p_eam_direct_items_rec.department_id is not null) OR
            (p_eam_direct_items_rec.operation_seq_num <> 1 and
             p_eam_direct_items_rec.department_id is null) then
           raise fnd_api.g_exc_error;
         end if;

         if p_eam_direct_items_rec.operation_seq_num <> 1 then

           select 1 into g_dummy
             from bom_departments where
             department_id = p_eam_direct_items_rec.department_id
             and organization_id = p_eam_direct_items_rec.organization_id;

           select 1 into g_dummy
             from wip_operations where
             wip_entity_id = p_eam_direct_items_rec.wip_entity_id and
             organization_id = p_eam_direct_items_rec.organization_id and
             operation_seq_num = p_eam_direct_items_rec.operation_seq_num and
             department_id = p_eam_direct_items_rec.department_id;

         end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'DEPARTMENT_ID';
           l_token_tbl(1).token_value :=  p_eam_direct_items_rec.department_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_DI_DEPT_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;
--start of fix for 3352406
g_dummy:=0;
l_ordered_quantity:=0;

IF(p_eam_direct_items_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_DELETE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) THEN
--Bug#3691325 If Po Quantity or Req Quantity is greater than zero,we cannot delete the direct item
--Bug#4862404 - (appsperf). Brought the ewodi view query inline and removed all unnecessary tables/columns.

     SELECT greatest(nvl(ewodi.po_quantity_ordered,0), nvl(ewodi.rql_quantity_ordered,0))
     INTO l_ordered_quantity
from
(
SELECT
wed.wip_entity_id AS wip_entity_id,
wed.operation_seq_num,
wed.organization_id,
wed.direct_item_sequence_id,
wed.description as item_description,
wed.quantity as rql_quantity_ordered,
sum(pd.quantity_ordered) as po_quantity_ordered
FROM
( SELECT
wed.wip_entity_id,
wed.operation_seq_num,
wed.organization_id,
wed.direct_item_sequence_id,
wed.description,
/*sum(rql.quantity) #6118897 7509781*/
sum(Decode(upper(NVL(rqh.authorization_status, 'APPROVED')), 'CANCELLED', 0, 'REJECTED', 0, 'SYSTEM_SAVED',0,rql.quantity)) quantity
FROM
wip_eam_direct_items wed, po_requisition_lines_all rql, po_requisition_headers_all rqh
WHERE
wed.wip_entity_id = rql.wip_entity_id (+)
AND wed.organization_id = rql.destination_organization_id (+)
AND wed.operation_seq_num = rql.wip_operation_seq_num (+)
AND rql.requisition_header_id = rqh.requisition_header_id(+)
/*AND upper(NVL(rqh.authorization_status, 'APPROVED') ) not in ('CANCELLED', 'REJECTED','SYSTEM_SAVED') #6118897 7509781*/
AND rql.item_id is null
AND (wed.direct_item_sequence_id = rql.wip_resource_seq_num OR rql.wip_resource_seq_num is null )
AND wed.description = rql.item_description(+)
GROUP BY wed.wip_entity_id, wed.operation_seq_num, wed.organization_id,
wed.direct_item_sequence_id, wed.description
)
wed,
( SELECT
    pd1.wip_entity_id,
    pd1.wip_operation_seq_num,
    pd1.destination_organization_id,
    pol.item_description,
    pd1.wip_resource_seq_num,
    pd1.quantity_ordered,
    pol.item_id,
    pol.cancel_flag
FROM
po_lines_all pol,
po_distributions_all pd1
WHERE
pol.po_line_id = pd1.po_line_id
AND upper(nvl(pol.cancel_flag,'N')) <> 'Y' ) pd    /* #7509781*/
WHERE
wed.wip_entity_id = pd.wip_entity_id(+)
AND wed.organization_id = pd.destination_organization_id (+)
AND wed.operation_seq_num = pd.wip_operation_seq_num(+)
/*AND upper(nvl(pd.cancel_flag,'N')) <> 'Y'   7509781 */
AND pd.item_id is null
AND wed.direct_item_sequence_id = pd.wip_resource_seq_num(+)   /* #7509781 */
AND wed.description = pd.item_description(+)
GROUP BY
wed.wip_entity_id,
wed.operation_seq_num,
wed.organization_id,
wed.direct_item_sequence_id,
wed.description,
wed.quantity
) ewodi
     WHERE ewodi.wip_entity_id= p_eam_direct_items_rec.wip_entity_id
     AND ewodi.operation_seq_num=p_eam_direct_items_rec.operation_seq_num
     AND ewodi.organization_id =p_eam_direct_items_rec.organization_id
     AND ewodi.direct_item_sequence_id=p_eam_direct_items_rec.direct_item_sequence_id;







     IF(p_eam_direct_items_rec.transaction_type =EAM_PROCESS_WO_PVT.G_OPR_DELETE) AND
        (l_ordered_quantity > 0) THEN
	   l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
           l_token_tbl(1).token_value :=  p_eam_direct_items_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_DI_DELETE_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;
  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Cannot delete direct item . . . '); END IF;

           x_return_status :=  EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;
     END IF;
END IF;
--end of fix for 3352406
/*

--  operation_seq_num

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating operation_seq_num . . . '); END IF;

        begin

       if (p_eam_direct_items_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

         if p_eam_direct_items_rec.operation_seq_num = 1 then
	   select 1
	     into g_dummy
	     from dual
	     where  p_eam_direct_items_rec.operation_seq_num = 1
             and not exists (select 1 from wip_operations
             where wip_entity_id = p_eam_direct_items_rec.wip_entity_id
             and organization_id = p_eam_direct_items_rec.organization_id);
         else
           select 1
             into g_dummy
             from wip_operations wo
             where wo.organization_id = p_eam_direct_items_rec.organization_id
             and wo.wip_entity_id = p_eam_direct_items_rec.wip_entity_id
             and wo.operation_seq_num = p_eam_direct_items_rec.operation_seq_num;
         end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'OP_SEQ_NUM';
           l_token_tbl(1).token_value :=  p_eam_direct_items_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_DI_OP_SEQ_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;


     --  direct_item_sequence_id
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating direct_item_sequence_id . . . '); END IF;

       begin

       if (p_eam_direct_items_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

	-- Fix for bug# 3602041 - Removed check for bom_enabled flag in the where clause of the query
           select 1
             into g_dummy
             from mtl_system_items
            where direct_item_sequence_id = p_eam_direct_items_rec.direct_item_sequence_id
              and organization_id = p_eam_direct_items_rec.organization_id
			  and ( bom_item_type  = 4
              and ( eam_item_type  IS NULL or eam_item_type  = 3) );

	  -- Check added so that assets and activities are not included


       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
           l_token_tbl(1).token_value :=  p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_DI_INV_ITEM_INVALID'
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

       if (p_eam_direct_items_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

         if p_eam_direct_items_rec.quantity_per_assembly < 0 then
           raise fnd_api.g_exc_unexpected_error;
         end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'QUANTITY_PER_ASSEMBLY';
           l_token_tbl(1).token_value :=  p_eam_direct_items_rec.quantity_per_assembly;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_DI_QTY_PER_ASSY_INVALID'
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

       if (p_eam_direct_items_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then


           if(p_eam_direct_items_rec.wip_supply_type is not null and p_eam_direct_items_rec.wip_supply_type not in (wip_constants.push, wip_constants.bulk, wip_constants.based_on_bom)) then
             --not a valid supply type

             raise fnd_api.g_exc_unexpected_error;

           end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'WIP_SUPPLY_TYPE';
           l_token_tbl(1).token_value :=  p_eam_direct_items_rec.wip_supply_type;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_DI_SUPPLY_TYPE_INVALID'
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

       if (p_eam_direct_items_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

         if p_eam_direct_items_rec.mrp_net_flag not in (wip_constants.yes, wip_constants.no) then
             raise fnd_api.g_exc_unexpected_error;
         end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'MRP_NET_FLAG';
           l_token_tbl(1).token_value :=  p_eam_direct_items_rec.mrp_net_flag;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_DI_MRP_NET_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;



     --  delete material_requirement
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating material_requirement . . . '); END IF;

       declare
         l_count_mmt        NUMBER :=0;
         l_count_mmtt       NUMBER :=0;
         l_issued_qty       NUMBER :=0;
       begin

       if (p_eam_direct_items_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE) then

           select count(*)
             into l_count_mmtt
             from mtl_material_transactions_temp
            where transaction_source_id = p_eam_direct_items_rec.wip_entity_id
              and organization_id       = p_eam_direct_items_rec.organization_id
              and operation_seq_num     = p_eam_direct_items_rec.operation_seq_num
              and direct_item_sequence_id     = p_eam_direct_items_rec.direct_item_sequence_id;

           if(l_count_mmtt > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

           select count(*)
             into l_count_mmt
             from mtl_material_transactions
            where transaction_source_id = p_eam_direct_items_rec.wip_entity_id
              and organization_id       = p_eam_direct_items_rec.organization_id
              and operation_seq_num     = p_eam_direct_items_rec.operation_seq_num
              and direct_item_sequence_id     = p_eam_direct_items_rec.direct_item_sequence_id;

           if(l_count_mmt > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

           select quantity_issued
             into l_issued_qty
             from wip_requirement_operations
            where wip_entity_id     = p_eam_direct_items_rec.wip_entity_id
              and organization_id   = p_eam_direct_items_rec.organization_id
              and operation_seq_num = p_eam_direct_items_rec.operation_seq_num
              and direct_item_sequence_id = p_eam_direct_items_rec.direct_item_sequence_id;

           if(l_issued_qty <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
           l_token_tbl(1).token_value :=  p_eam_direct_items_rec.wip_entity_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_DI_DELETE_INVALID'
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

       begin
         if p_eam_direct_items_rec.required_quantity < p_eam_direct_items_rec.quantity_issued then
             raise fnd_api.g_exc_unexpected_error;
         end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_DI_REQ_QTY_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;



     --  delete material_requirement
*/


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
    * Parameters IN : Direct Items column record
    * Parameters OUT NOCOPY: Mesg Token Table
    *                 Return_Status
    * Purpose       :
    **********************************************************************/

    PROCEDURE Check_Required
        (  p_eam_direct_items_rec             IN EAM_PROCESS_WO_PUB.eam_direct_items_rec_type
         , x_return_status          OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )
    IS
            l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;



        IF p_eam_direct_items_rec.wip_entity_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
            l_token_tbl(1).token_value :=  p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_DI_ENTITY_ID_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_direct_items_rec.organization_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
            l_token_tbl(1).token_value :=  p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_DI_ORG_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_direct_items_rec.direct_item_sequence_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
            l_token_tbl(1).token_value :=  p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_DI_INV_ITEM_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_direct_items_rec.operation_seq_num IS NULL
        THEN
            l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
            l_token_tbl(1).token_value :=  p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_DI_OP_SEQ_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_direct_items_rec.description IS NULL
        THEN
            l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
            l_token_tbl(1).token_value :=  p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_DI_DESC_REQUIRED'
             , p_token_tbl              => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_direct_items_rec.purchasing_category_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
            l_token_tbl(1).token_value :=  p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_DI_PURCH_CAT_REQUIRED'
             , p_token_tbl              => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_direct_items_rec.required_quantity IS NULL
        THEN
            l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
            l_token_tbl(1).token_value :=  p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_DI_REQ_QTY_REQUIRED'
             , p_token_tbl              => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_direct_items_rec.uom IS NULL
        THEN
            l_token_tbl(1).token_name  := 'DIRECT_ITEM_SEQUENCE_ID';
            l_token_tbl(1).token_value :=  p_eam_direct_items_rec.direct_item_sequence_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_DI_UOM_REQUIRED'
             , p_token_tbl              => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    END Check_Required;

END EAM_DIRECT_ITEMS_VALIDATE_PVT;

/
