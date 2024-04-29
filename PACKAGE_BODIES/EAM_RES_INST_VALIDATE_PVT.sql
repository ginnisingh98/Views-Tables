--------------------------------------------------------
--  DDL for Package Body EAM_RES_INST_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_RES_INST_VALIDATE_PVT" AS
/* $Header: EAMVRIVB.pls 120.2 2005/09/21 23:15:01 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRIVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_RES_INST_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_RES_INST_VALIDATE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_dummy         NUMBER;

    /*******************************************************************
    * Procedure	: Check_Existence
    * Returns	: None
    * Parameters IN : Resource Instance Record
    * Parameters OUT NOCOPY: Old Resource Instance Record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: Procedure will query the old Resource Instance
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
     ( p_eam_res_inst_rec             IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
     , x_old_eam_res_inst_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
     , x_Mesg_Token_Tbl               OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , x_return_status                OUT NOCOPY VARCHAR2
        )
     IS
            l_token_tbl      EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
            l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_return_status  VARCHAR2(1);
     BEGIN

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quering Resource Instance'); END IF;

        EAM_RES_INST_UTILITY_PVT.Query_Row
        ( p_wip_entity_id       => p_eam_res_inst_rec.wip_entity_id
        , p_organization_id     => p_eam_res_inst_rec.organization_id
        , p_operation_seq_num   => p_eam_res_inst_rec.operation_seq_num
        , p_resource_seq_num    => p_eam_res_inst_rec.resource_seq_num
        , p_instance_id         => p_eam_res_inst_rec.instance_id
        , p_serial_number       => p_eam_res_inst_rec.serial_number
        , x_eam_res_inst_rec    => x_old_eam_res_inst_rec
        , x_Return_status       => l_return_status
        );

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Query Row Returned with : ' || l_return_status); END IF;

        IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND AND
            p_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN
		l_token_tbl(1).token_name  := 'INSTANCE_NAME';

		if p_eam_res_inst_rec.SERIAL_NUMBER is null then

			select full_name
			into l_token_tbl(1).token_value
			from per_all_people_f papf,bom_resource_employees bre
			where bre.instance_id  = p_eam_res_inst_rec.instance_id
			and papf.person_id = bre.person_id
			and( trunc(sysdate) between papf.effective_start_date
			and papf.effective_end_date);

		else
		            l_token_tbl(1).token_value := p_eam_res_inst_rec.serial_number;
		end if;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_RI_ALREADY_EXISTS'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND AND
             p_eam_res_inst_rec.transaction_type IN
             (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN
            l_token_tbl(1).token_name  := 'INSTANCE_NAME';
         --   l_token_tbl(1).token_value :=  p_eam_res_inst_rec.instance_id;

		if p_eam_res_inst_rec.SERIAL_NUMBER is null then

			select full_name
			into l_token_tbl(1).token_value
			from per_all_people_f papf,bom_resource_employees bre
			where bre.instance_id  = p_eam_res_inst_rec.instance_id
			and papf.person_id = bre.person_id
			and( trunc(sysdate) between papf.effective_start_date
			and papf.effective_end_date);
		else
		            l_token_tbl(1).token_value := p_eam_res_inst_rec.serial_number;
		end if;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'EAM_RI_DOESNOT_EXISTS'
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
             , p_message_text       => 'Unexpected error while existence verification of ' || 'Resource Instance '|| p_eam_res_inst_rec.instance_id , p_token_tbl => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        ELSE /* Assign the relevant transaction type for SYNC operations */
            IF p_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
               IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND THEN
                   x_old_eam_res_inst_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
               ELSE
                   x_old_eam_res_inst_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
               END IF;
            END IF;
            l_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;
    END Check_Existence;



    /********************************************************************
    * Procedure     : Check_Attributes
    * Parameters IN : Resource Instance Column record
    *                 Old Resource Instance Column record
    * Parameters OUT NOCOPY: Return Status
    *                 Mesg Token Table
    * Purpose       : Check_Attrbibutes procedure will validate every
    *                 revised item attrbiute in its entirety.
    **********************************************************************/

    PROCEDURE Check_Attributes
        (  p_eam_res_inst_rec         IN EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , p_old_eam_res_inst_rec     IN EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , x_return_status            OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
    )
    IS
    l_err_text              VARCHAR2(2000) := NULL;
    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

    BEGIN


--  operation_seq_num

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating operation_seq_num . . . '); END IF;

   begin

   if (p_eam_res_inst_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from wip_operations wo
     where wo.organization_id = p_eam_res_inst_rec.organization_id
       and wo.wip_entity_id = p_eam_res_inst_rec.wip_entity_id
       and wo.operation_seq_num = p_eam_res_inst_rec.operation_seq_num;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'OP_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_inst_rec.operation_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RI_OP_SEQ_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  resource_seq_num

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating resource_seq_num . . . '); END IF;

   begin

   if (p_eam_res_inst_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from wip_operation_resources wor
     where wor.organization_id = p_eam_res_inst_rec.organization_id
       and wor.wip_entity_id = p_eam_res_inst_rec.wip_entity_id
       and wor.operation_seq_num = p_eam_res_inst_rec.operation_seq_num
       and wor.resource_seq_num = p_eam_res_inst_rec.resource_seq_num;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_inst_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RI_RES_SEQ_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  instance_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating instance_id . . . '); END IF;

  declare
    l_resource_type NUMBER;
    l_resource_id   NUMBER;
  begin

   if (p_eam_res_inst_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

      select 1 into g_dummy from
        bom_dept_res_instances bdri,
        bom_department_resources bdr,
        wip_operation_resources wor,
        wip_operations wo where
        wor.wip_entity_id = p_eam_res_inst_rec.wip_entity_id
        and wor.organization_id = p_eam_res_inst_rec.organization_id
        and wor.operation_seq_num = p_eam_res_inst_rec.operation_seq_num
        and wor.resource_seq_num = p_eam_res_inst_rec.resource_seq_num
        and (bdri.department_id = wo.department_id
	or bdri.department_id = bdr.share_from_dept_id)
        and bdri.resource_id = wor.resource_id
        and bdri.instance_id = p_eam_res_inst_rec.instance_id
        and bdr.department_id = wo.department_id
        and bdr.resource_id = wor.resource_id
        and wo.wip_entity_id = wor.wip_entity_id
        and wo.organization_id = wor.organization_id
        and wo.operation_seq_num = wor.operation_seq_num;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when TOO_MANY_ROWS then
      -- Do nothing. Multiple rows mean multiple serial numbers
      -- which are ok.
      null;
    when others then

          l_token_tbl(1).token_name  := 'INSTANCE_NAME';
	-- l_token_tbl(1).token_value :=  p_eam_res_inst_rec.resource_seq_num;

	if p_eam_res_inst_rec.SERIAL_NUMBER is null then
			select full_name
			into l_token_tbl(1).token_value
			from per_all_people_f papf,bom_resource_employees bre
			where bre.instance_id  = p_eam_res_inst_rec.instance_id
			and papf.person_id = bre.person_id
			and( trunc(sysdate) between papf.effective_start_date
			and papf.effective_end_date);
	else
            l_token_tbl(1).token_value := p_eam_res_inst_rec.serial_number;
	end if;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RI_INSTANCE_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;



--  serial_number
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating serial_number . . . '); END IF;

  begin

   if (p_eam_res_inst_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    if (p_eam_res_inst_rec.serial_number is not NULL) then

      select 1
        into g_dummy
        from mtl_serial_numbers msn, bom_resource_equipments bre
       where msn.inventory_item_id = bre.inventory_item_id
         and msn.current_organization_id = bre.organization_id
         and bre.instance_id = p_eam_res_inst_rec.instance_id
         and msn.serial_number = p_eam_res_inst_rec.serial_number;

    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_inst_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RI_SERIAL_NUMBER_INVALID'
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

   if (p_eam_res_inst_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    if p_eam_res_inst_rec.start_date > p_eam_res_inst_rec.completion_date then
      raise fnd_api.g_exc_unexpected_error;
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'START_DATE';
      l_token_tbl(1).token_value :=  p_eam_res_inst_rec.start_date;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RI_START_DATE_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

  --  delete instance
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating delete instance . . . '); END IF;

       declare
         l_count_wt                NUMBER :=0;
         l_count_wcti              NUMBER :=0;
	 l_resource_id		   NUMBER;

	 CURSOR res_inst IS select RESOURCE_id
         from wip_operation_resources
	 where wip_entity_id =  p_eam_res_inst_rec.wip_entity_id
	  and operation_seq_num     = p_eam_res_inst_rec.operation_seq_num
          and resource_seq_num      = p_eam_res_inst_rec.resource_seq_num;
       begin

       if (p_eam_res_inst_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE) then

    open res_inst;
    fetch res_inst into l_resource_id;
    close res_inst;


             select count(*)
             into l_count_wt
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM wip_transactions
			    where wip_entity_id         = p_eam_res_inst_rec.wip_entity_id
			      and organization_id       = p_eam_res_inst_rec.organization_id
			      and operation_seq_num     = p_eam_res_inst_rec.operation_seq_num
			      and resource_seq_num      = p_eam_res_inst_rec.resource_seq_num
			      and resource_id           = l_resource_id
			      and instance_id		= p_eam_res_inst_rec.instance_id)
	      AND rownum <=1  ;



           if(l_count_wt > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

             select count(*)
             into l_count_wcti
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM wip_cost_txn_interface
			    where wip_entity_id         = p_eam_res_inst_rec.wip_entity_id
			      and organization_id       = p_eam_res_inst_rec.organization_id
			      and operation_seq_num     = p_eam_res_inst_rec.operation_seq_num
			      and resource_seq_num      = p_eam_res_inst_rec.resource_seq_num
			      and resource_id           = l_resource_id
      			      and instance_id		= p_eam_res_inst_rec.instance_id)
    	      AND rownum <=1  ;


           if(l_count_wcti > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;


       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
           l_token_tbl(1).token_value :=  p_eam_res_inst_rec.wip_entity_id;

           l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_RES_INST_DELETE_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
           l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;


        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within Resource Instance Check Attributes . . . '); END IF;

    END Check_Attributes;

    /*********************************************************************
    * Procedure     : Check_Required
    * Parameters IN : Resource Instance column record
    * Parameters OUT NOCOPY: Mesg Token Table
    *                 Return_Status
    * Purpose       :
    **********************************************************************/

    PROCEDURE Check_Required
        (  p_eam_res_inst_rec         IN EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
         , x_return_status            OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )
    IS
            l_Mesg_Token_Tbl          EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl          EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl               EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        IF p_eam_res_inst_rec.wip_entity_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INSTANCE_ID';
            l_token_tbl(1).token_value :=  p_eam_res_inst_rec.instance_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RI_ENTITY_ID_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_inst_rec.organization_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INSTANCE_ID';
            l_token_tbl(1).token_value :=  p_eam_res_inst_rec.instance_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RI_ORG_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_res_inst_rec.operation_seq_num IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INSTANCE_ID';
            l_token_tbl(1).token_value :=  p_eam_res_inst_rec.instance_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RI_OP_SEQ_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_inst_rec.resource_seq_num IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INSTANCE_ID';
            l_token_tbl(1).token_value :=  p_eam_res_inst_rec.instance_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RI_RES_REQ_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_inst_rec.instance_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INSTANCE_ID';
            l_token_tbl(1).token_value :=  p_eam_res_inst_rec.instance_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RI_INSTANCE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_inst_rec.start_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INSTANCE_ID';
            l_token_tbl(1).token_value :=  p_eam_res_inst_rec.instance_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RI_START_DATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_inst_rec.completion_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'INSTANCE_ID';
            l_token_tbl(1).token_value :=  p_eam_res_inst_rec.instance_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RI_COMPL_DATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    END Check_Required;

END EAM_RES_INST_VALIDATE_PVT;

/
