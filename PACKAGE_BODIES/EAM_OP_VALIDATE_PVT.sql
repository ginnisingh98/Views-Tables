--------------------------------------------------------
--  DDL for Package Body EAM_OP_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OP_VALIDATE_PVT" AS
/* $Header: EAMVOPVB.pls 120.5.12010000.3 2009/10/03 00:46:16 jvittes ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVOPVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_OP_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_OP_VALIDATE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_shutdown_type VARCHAR2(30) := EAM_CONSTANTS.G_SHUTDOWN_TYPE;

    /*******************************************************************
    * Procedure	: Check_Existence
    * Returns	: None
    * Parameters IN : Operation Record
    * Parameters OUT NOCOPY: Old Operation Record
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
     ( p_eam_op_rec             IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
     , x_old_eam_op_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_rec_type
     , x_Mesg_Token_Tbl	        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , x_return_status	        OUT NOCOPY VARCHAR2
        )
     IS
            l_token_tbl      EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
            l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_return_status  VARCHAR2(1);
     BEGIN

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quering Operations'); END IF;

        EAM_OP_UTILITY_PVT.Query_Row
        ( p_wip_entity_id       => p_eam_op_rec.wip_entity_id
        , p_organization_id     => p_eam_op_rec.organization_id
        , p_operation_seq_num   => p_eam_op_rec.operation_seq_num
        , x_eam_op_rec          => x_old_eam_op_rec
        , x_Return_status       => l_return_status
        );

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Query Row Returned with : ' || l_return_status); END IF;

        IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND AND
            p_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN
            l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            l_token_tbl(1).token_value := p_eam_op_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_OP_ALREADY_EXISTS'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND AND
             p_eam_op_rec.transaction_type IN
             (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN
            l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'EAM_OP_DOESNOT_EXISTS'
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
             , p_message_text       => 'Unexpected error while existence verification of ' || 'Operation '|| p_eam_op_rec.operation_seq_num , p_token_tbl => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        ELSE /* Assign the relevant transaction type for SYNC operations */
            IF p_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
               IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND THEN
                   x_old_eam_op_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
               ELSE
                   x_old_eam_op_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
               END IF;
            END IF;
            l_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;
    END Check_Existence;


 /********************************************************************
       * Procedure     :       Is_Dept_Updateable
       * Parameters IN :   Wip_Entity_Id and Operation_Seq_Num
       * Parameters OUT NOCOPY: Return Status
       *                 Mesg Token Table
       * Purpose       :   Is_Dept_Updateable will check if the operation's
       *                        department can be updateable or not
       **********************************************************************/
       FUNCTION Is_Dept_Updateable
           (  p_wip_entity_id                     NUMBER,
              p_organization_id                NUMBER,
              p_operation_seq_num        NUMBER
       ) RETURN BOOLEAN
       IS
              l_inv_count     NUMBER;
              l_direct_count   NUMBER;
              l_res_count       NUMBER;
              l_po_count         NUMBER;
              l_req_count       NUMBER;
              l_dist_count       NUMBER;
       BEGIN

               --initialise variables
               l_inv_count              := 0;
               l_direct_count         :=  0;
               l_res_count             :=  0;
               l_po_count              := 0;
               l_req_count             :=  0;
               l_dist_count            := 0;

                --check if any stocked/non-stocked inventory items exist for this op
                       select count(*)
                       into l_inv_count
                       from dual
                       where exists (select 1
                                                 from wip_requirement_operations wro
                                                 where wro.wip_entity_id = p_wip_entity_id
                                                 and wro.organization_id   = p_organization_id
                                                 and wro.operation_seq_num   = p_operation_seq_num
						 and ( quantity_issued > 0  or
						      EAM_MATERIAL_ALLOCQTY_PKG.allocated_quantity(
						       wro.wip_entity_id,
						       wro.organization_id,
						       wro.operation_seq_num,
						       wro.inventory_item_id ) >0 )
							 );

                  IF(l_inv_count > 0) THEN
                       RETURN FALSE;
                  END IF;

                   --check if any resources exist for this op
                        select count(*)
                        into l_res_count
                        from dual
                        where exists (select 1
                                                   from wip_operation_resources
                                                   where wip_entity_id = p_wip_entity_id
                                                 and organization_id   = p_organization_id
                                                 and operation_seq_num   = p_operation_seq_num);

                  IF(l_res_count > 0) THEN
                       RETURN FALSE;
                  END IF;

                  --check if any pending requisitions exist for this op
                /*  select count(*)
                into l_po_count
                from DUAL
                WHERE EXISTS (SELECT 1
                               FROM po_requisitions_interface
                               where wip_entity_id               = p_wip_entity_id
                                 and destination_organization_id = p_organization_id
                                 and wip_operation_seq_num       = p_operation_seq_num);

              if(l_po_count > 0) then
                RETURN FALSE;
              end if; */


                   --check if any requisitions exist for this op
                select count(*)
                into l_req_count
                from DUAL
                WHERE EXISTS (SELECT 1
                               FROM po_requisition_lines prl, po_requisition_headers prh
                               where prl.requisition_header_id = prh.requisition_header_id
                                 and prl.wip_entity_id               = p_wip_entity_id
                                 and prl.destination_organization_id = p_organization_id
                                 and prl.wip_operation_seq_num       = p_operation_seq_num
                                 and   (prh.authorization_status <>'CANCELLED'
                                    or    prh.authorization_status is null)
                                 and   (prl.cancel_flag <>'Y' or prl.cancel_flag is null)
                                 and   (prl.closed_code not in ('FINALLY CLOSED')
                                    or    prl.closed_code is null)
                                 and   (prl.modified_by_agent_flag <> 'Y'
                                    or    prl.modified_by_agent_flag is null));


              if(l_req_count > 0) then
                RETURN FALSE;
              end if;


                 --check if any purchase orders exist for this op
                select count(*)
                into l_dist_count
                from DUAL
                WHERE EXISTS (SELECT 1
                               FROM po_distributions pds,po_line_locations poll
                               where pds.line_location_id =  poll.line_location_id
                                 and pds.wip_entity_id               = p_wip_entity_id
                                 and pds.destination_organization_id = p_organization_id
                                 and pds.wip_operation_seq_num       = p_operation_seq_num
                                 and   (poll.cancel_flag <>'Y' or poll.cancel_flag is null)
                                 and   (poll.closed_code not in ('CANCELLED','FINALLY CLOSED')
                                        or    poll.closed_code is null));

           IF(l_dist_count > 0) THEN
                RETURN FALSE;
           END IF;

           --dept is updateable
           RETURN TRUE ;

       END Is_Dept_Updateable;




    /********************************************************************
    * Procedure     : Check_Attributes
    * Parameters IN : Operation Column record
    *                 Old Operation Column record
    * Parameters OUT NOCOPY: Return Status
    *                 Mesg Token Table
    * Purpose       : Check_Attrbibutes procedure will validate every
    *                 revised item attrbiute in its entirety.
    **********************************************************************/

    PROCEDURE Check_Attributes
        (  p_eam_op_rec              IN EAM_PROCESS_WO_PUB.eam_op_rec_type
         , p_old_eam_op_rec          IN EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
    )
    IS
    l_err_text              VARCHAR2(2000) := NULL;
    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    g_dummy          NUMBER;
    l_mat_count	     NUMBER;
    l_di_count	     NUMBER;
    l_wedi_count     NUMBER;
    l_po_count       NUMBER;
    l_req_count      NUMBER;
    OP_DEPT_NOT_UPDATEABLE   EXCEPTION;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within WO Check Attributes . . . '); END IF;


--  department_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating department_id . . . '); END IF;

  begin

   if (p_eam_op_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

       select 1
        into g_dummy
        from bom_departments
       where department_id = p_eam_op_rec.department_id
         and organization_id = p_eam_op_rec.organization_id;

				                 if (p_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE and
							   (p_eam_op_rec.department_id <> p_old_eam_op_rec.department_id)
							   and ((Is_Dept_Updateable(p_wip_entity_id              => p_eam_op_rec.wip_entity_id
													    , p_organization_id         => p_eam_op_rec.organization_id
													    , p_operation_seq_num => p_eam_op_rec.operation_seq_num ))
												  in (FALSE)  and is_op_dept_change_allowed(p_eam_op_rec.wip_entity_id,p_eam_op_rec.operation_seq_num)='N')
							   ) THEN
										raise OP_DEPT_NOT_UPDATEABLE;
						      end if;    --end of check for update and is_dept_updateable
   end if;     --end of check for create/update transaction

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
   WHEN OP_DEPT_NOT_UPDATEABLE THEN
      l_token_tbl(1).token_name  := 'DEPT_NAME';

      SELECT bd.department_code into l_token_tbl(1).token_value
	 FROM  bom_departments bd
	 WHERE 	 bd.DEPARTMENT_ID = p_eam_op_rec.department_id
 	 AND     bd.organization_id   = p_eam_op_rec.organization_id;


      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_OP_DEPT_UPDATE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    when others then

      l_token_tbl(1).token_name  := 'DEPARTMENT_NAME';

      SELECT bd.department_code into l_token_tbl(1).token_value
	 FROM  bom_departments bd
	 WHERE 	 bd.DEPARTMENT_ID = p_eam_op_rec.department_id
 	 AND     bd.organization_id   = p_eam_op_rec.organization_id;


      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_OP_DEPT_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  standard_operation_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating standard_operation_id . . . '); END IF;

  begin

   if (p_eam_op_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    if (p_eam_op_rec.standard_operation_id is not null) then

      select 1
        into g_dummy
        from bom_standard_operations
       where standard_operation_id = p_eam_op_rec.standard_operation_id
         and organization_id = p_eam_op_rec.organization_id;
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'STANDARD_OPERATION';
      l_token_tbl(1).token_value :=  p_eam_op_rec.standard_operation_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_OP_STD_OP_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  minimum_transfer_quantity
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating minimum_transfer_quantity . . . '); END IF;

  begin

   if (p_eam_op_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    if p_eam_op_rec.minimum_transfer_quantity < 0 then
      raise fnd_api.g_exc_unexpected_error;
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'MINIMUM_TRANSFER_QUANTITY';
      l_token_tbl(1).token_value :=  p_eam_op_rec.minimum_transfer_quantity;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_OP_MIN_TRS_QTY_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  count_point_type
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating count_point_type . . . '); END IF;

  begin

   if (p_eam_op_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = 'BOM_COUNT_POINT_TYPE'
         and lookup_code = p_eam_op_rec.count_point_type;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'COUNT_POINT_TYPE';
      l_token_tbl(1).token_value :=  p_eam_op_rec.count_point_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_OP_COUNT_POINT_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  backflush_flag
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating backflush_flag . . . '); END IF;

  begin

   if (p_eam_op_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = 'SYS_YES_NO'
         and lookup_code = p_eam_op_rec.backflush_flag;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'BACKFLUSH_FLAG';
      l_token_tbl(1).token_value :=  p_eam_op_rec.backflush_flag;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_OP_BACKFLUSH_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  shutdown_type
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating shutdown_type . . . '); END IF;

  begin

   if (p_eam_op_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    if p_eam_op_rec.shutdown_type is not null then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = g_shutdown_type
         and lookup_code = p_eam_op_rec.shutdown_type
         and enabled_flag = 'Y';
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'SHUTDOWN_TYPE';
      l_token_tbl(1).token_value :=  p_eam_op_rec.shutdown_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_OP_SHUTDOWN_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  start_date
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating start_date . . . '); END IF;

  begin

   if (p_eam_op_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    if p_eam_op_rec.start_date > p_eam_op_rec.completion_date then
      raise fnd_api.g_exc_unexpected_error;
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'START_DATE';
      l_token_tbl(1).token_value :=  p_eam_op_rec.start_date;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_OP_START_DATE_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  delete operation
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating operation . . . '); END IF;

       declare
         l_count_eoct             NUMBER :=0;
         l_count_res              NUMBER :=0;
         l_count_on               NUMBER :=0;
         l_count_mr               NUMBER :=0;
       begin

       if (p_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE) then

           select count(*)
             into l_count_eoct
             from eam_op_completion_txns
            where wip_entity_id         = p_eam_op_rec.wip_entity_id
              and organization_id       = p_eam_op_rec.organization_id
              and operation_seq_num     = p_eam_op_rec.operation_seq_num;

           if(l_count_eoct > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

           select count(*)
             into l_count_res
             from wip_operation_resources
            where wip_entity_id         = p_eam_op_rec.wip_entity_id
              and organization_id       = p_eam_op_rec.organization_id
              and operation_seq_num     = p_eam_op_rec.operation_seq_num;

           if(l_count_res > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

           select count(*)
             into l_count_on
             from wip_operation_networks
            where wip_entity_id         = p_eam_op_rec.wip_entity_id
              and organization_id       = p_eam_op_rec.organization_id
              and (   prior_operation   = p_eam_op_rec.operation_seq_num
                   or next_operation    = p_eam_op_rec.operation_seq_num);

           if(l_count_on > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;


           select count(*)
             into l_count_mr
             from wip_requirement_operations
            where wip_entity_id         = p_eam_op_rec.wip_entity_id
              and organization_id       = p_eam_op_rec.organization_id
              and operation_seq_num     = p_eam_op_rec.operation_seq_num;

           if(l_count_mr <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
           l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;

           l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_OP_DELETE_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
           l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;



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
    * Parameters IN : Operation column record
    * Parameters OUT NOCOPY: Mesg Token Table
    *                 Return_Status
    * Purpose       :
    **********************************************************************/

    PROCEDURE Check_Required
        (  p_eam_op_rec             IN EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_return_status          OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )
    IS
            l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_eam_op_rec.wip_entity_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OP_ENTITY_ID_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_op_rec.operation_seq_num IS NULL
        THEN
            --l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            --l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;
            l_token_tbl.delete;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_OP_OP_SEQ_REQUIRED'
             , p_token_tbl              => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_op_rec.organization_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OP_ORG_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_op_rec.department_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OP_DEPT_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_op_rec.start_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OP_START_DATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_op_rec.completion_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OP_COMPL_DATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_op_rec.count_point_type IS NULL
        THEN
            l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OP_COUNT_POINT_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_op_rec.backflush_flag IS NULL
        THEN
            l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OP_BACKFLUSH_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_op_rec.minimum_transfer_quantity IS NULL
        THEN
            l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OP_MIN_TRANS_QTY_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    END Check_Required;

    -- This procedure will check that after operation updatates,the depdendency in the operation depdendency network is valid
    -- If the depdencdency fails then ,it throws an error

        PROCEDURE Check_Operation_Netwrok_Dates
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_wip_entity_id                 IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
	x_pri_operation_no              OUT NOCOPY  NUMBER,
	x_next_operation_no             OUT NOCOPY  NUMBER
        ) IS

       CURSOR l_op_network(l_wip_entity_id NUMBER) IS
        SELECT
		won.prior_operation,won.next_operation,wo.last_unit_completion_date,wo1.first_unit_start_date
	FROM  wip_operation_networks won,wip_operations wo,wip_operations wo1
	WHERE won.wip_entity_id   = wo.wip_entity_id AND
	      won.wip_entity_id   = wo1.wip_entity_id AND
	      won.prior_operation = wo.operation_seq_num  AND
	      won.next_operation  = wo1.operation_seq_num  AND
	      won.wip_entity_id   =  l_wip_entity_id;

     BEGIN

       FOR l_opeation IN l_op_network (p_wip_entity_id)
       LOOP
	 If l_opeation.last_unit_completion_date > l_opeation.first_unit_start_date THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
		  x_pri_operation_no := l_opeation.prior_operation;
  		  x_next_operation_no := l_opeation.next_operation;
		  RETURN ;
	 End if;
       END LOOP;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
          when others then
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;

     END Check_Operation_Netwrok_Dates;

 /*********************************************************************
    * Procedure     : is_op_dept_change_allowed
    * Parameters IN : Wip entity id operation sequence number
    * Parameters OUT NOCOPY: Valication Flag
    * Purpose       :
    **********************************************************************/


 FUNCTION is_op_dept_change_allowed(p_wip_entity_id NUMBER,   p_op_seq_num NUMBER) RETURN VARCHAR2 IS l_op_completed VARCHAR2(1);
l_q_issued NUMBER;
l_q_received NUMBER;
l_amount_delivered NUMBER;
l_charged_units NUMBER;
l_return VARCHAR2(1);
l_tx_count NUMBER;
BEGIN

  --1.Is Op Completed

  SELECT nvl(operation_completed,   'N')
  INTO l_op_completed
  FROM wip_operations
  WHERE wip_entity_id = p_wip_entity_id
   AND operation_seq_num = p_op_seq_num;

  IF l_op_completed = 'Y' THEN
    RETURN 'N';
  END IF;

  --2.Is Materail Tx Done
  --WIP_REQUIREMENT_OPERATIONS. quantity_issued > 0
  BEGIN
    SELECT nvl(sum(quantity_issued),   0)
    INTO l_q_issued
    FROM wip_requirement_operations
    WHERE wip_entity_id = p_wip_entity_id
     AND operation_seq_num = p_op_seq_num;

    IF l_q_issued > 0 THEN
      RETURN 'N';
    END IF;

  EXCEPTION
  WHEN no_data_found THEN
    l_return := 'Y';
  END;


  --3. Is Time charged on Operation
  BEGIN
	  SELECT SUM(nvl(applied_resource_units,0))
	  INTO l_charged_units
	  FROM wip_operation_resources wor
	  WHERE wip_entity_id = p_wip_entity_id
	  AND operation_seq_num = p_op_seq_num;

	  IF l_charged_units > 0 THEN
	    RETURN 'N';
	  END IF;

  EXCEPTION
	  WHEN no_data_found THEN
	    l_return := 'Y';
  END ;

  --3.Is non-stock material receipt Done
  --4.Is Direct material receipt  done
  --5.IS Out side processing (OSP) receipt done
  --EAM_WO_DIRECT_ITEMS_LITE_V. quantity_received > 0 or EAM_WO_DIRECT_ITEMS_LITE_V. amount_delivered > 0
  BEGIN
    SELECT nvl(sum(quantity_received),   0),
      nvl(sum(amount_delivered),   0)
    INTO l_q_received,
      l_amount_delivered
    FROM eam_wo_direct_items_lite_v
    WHERE wip_entity_id = p_wip_entity_id
     AND operation_seq_num = p_op_seq_num;

    IF l_q_received > 0 OR l_amount_delivered > 0 THEN
      RETURN 'N';
    END IF;

  EXCEPTION
  WHEN no_data_found THEN
    l_return := 'Y';
  END ;
  -- For checking resource transaction use wip_cost_txn_interface.

    select count(*)  into l_tx_count  from dual
                    where EXISTS (SELECT transaction_id FROM wip_cost_txn_interface
                                  WHERE wip_entity_id = p_wip_entity_id
                                  AND operation_seq_num = p_op_seq_num);

    IF l_tx_count > 0 THEN
      RETURN 'N';
    END IF;
    l_return := 'Y';


  RETURN l_return;

EXCEPTION
WHEN no_data_found THEN
  RETURN 'Y';
END is_op_dept_change_allowed;

  /*********************************************************************
    * Procedure     : is_wo_dept_change_allowed
    * Parameters IN : Wip entity id
    * Parameters OUT NOCOPY: Valication Flag
    * Purpose       :
    **********************************************************************/

 FUNCTION is_wo_dept_change_allowed(x_wip_entity_id NUMBER) RETURN VARCHAR2 IS l_status NUMBER;
BEGIN

  SELECT user_defined_status_id
  INTO l_status
  FROM eam_work_order_details
  WHERE wip_entity_id = x_wip_entity_id;
  --Is WO status  in Draft(17), Un Released(1), Released(3), On Hold(6)

  IF l_status = 17 or l_status = 1 or l_status = 3 or l_status = 6 THEN
    RETURN 'Y';
  END IF;

  RETURN 'N';
END is_wo_dept_change_allowed;

  /*********************************************************************
    * Procedure     : validate_dept_res
    * Parameters IN : Department ID Resource ID
    * Parameters OUT NOCOPY: Valication Flag
    * Purpose       :
    **********************************************************************/


 function validate_dept_res(p_dept_id number , p_res_code varchar2) return varchar2 is
l_rowcount number := 0;
begin
select count(*) into l_rowcount from BOM_DEPARTMENT_RESOURCES_V where DEPARTMENT_ID=p_dept_id and RESOURCE_CODE=p_res_code;
if(l_rowcount > 0) then
 return 'Y';
end if;
return 'N';
end validate_dept_res;
 /*********************************************************************
    * Procedure     : validate_dept_res_instance
    * Parameters IN : Department Id Instance ID Resource ID
    * Parameters OUT NOCOPY: Valication Flag
    * Purpose       :
    **********************************************************************/
 function validate_dept_res_instance(p_dept_id number , p_inst_id number, p_res_id Number) return varchar2 is
l_rowcount number := 0;
begin
 select count(*)  into l_rowcount  from dual
                    where EXISTS (select ROW_ID from BOM_DEPT_RES_INSTANCES_EMP_V
					where DEPARTMENT_ID=p_dept_id and INSTANCE_ID=p_inst_id and RESOURCE_ID=p_res_id);
if(l_rowcount > 0) then
 return 'N';
end if;
return 'Y';
end;



END EAM_OP_VALIDATE_PVT;

/
