--------------------------------------------------------
--  DDL for Package Body EAM_RES_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_RES_VALIDATE_PVT" AS
/* $Header: EAMVRSVB.pls 120.3.12010000.2 2008/11/06 23:52:18 mashah ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRSVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_RES_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_RES_VALIDATE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_dummy         NUMBER;
g_autocharge_type VARCHAR2(30) := EAM_CONSTANTS.G_AUTOCHARGE_TYPE;

    /*******************************************************************
    * Procedure	: Check_Existence
    * Returns	: None
    * Parameters IN : Resource Record
    * Parameters OUT NOCOPY: Old Resource Record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: Procedure will query the old Resource
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
     ( p_eam_res_rec             IN  EAM_PROCESS_WO_PUB.eam_res_rec_type
     , x_old_eam_res_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_rec_type
     , x_Mesg_Token_Tbl	        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , x_return_status	        OUT NOCOPY VARCHAR2
        )
     IS
            l_token_tbl      EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
            l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_return_status  VARCHAR2(1);
     BEGIN

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quering Resource'); END IF;

        EAM_RES_UTILITY_PVT.Query_Row
        ( p_wip_entity_id       => p_eam_res_rec.wip_entity_id
        , p_organization_id     => p_eam_res_rec.organization_id
        , p_operation_seq_num   => p_eam_res_rec.operation_seq_num
        , p_resource_seq_num    => p_eam_res_rec.resource_seq_num
        , x_eam_res_rec         => x_old_eam_res_rec
        , x_Return_status       => l_return_status
        );

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Query Row Returned with : ' || l_return_status); END IF;

        IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND AND
            p_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value := p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_RES_ALREADY_EXISTS'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND AND
             p_eam_res_rec.transaction_type IN
             (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'EAM_RES_DOESNOT_EXISTS'
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
             , p_message_text       => 'Unexpected error while existence verification of ' || 'Resource '|| p_eam_res_rec.resource_seq_num , p_token_tbl => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        ELSE /* Assign the relevant transaction type for SYNC operations */
            IF p_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
               IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND THEN
                   x_old_eam_res_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
               ELSE
                   x_old_eam_res_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
               END IF;
            END IF;
            l_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;
    END Check_Existence;



    /********************************************************************
    * Procedure     : Check_Attributes
    * Parameters IN : Resource Column record
    *                 Old Resource Column record
    * Parameters OUT NOCOPY: Return Status
    *                 Mesg Token Table
    * Purpose       : Check_Attrbibutes procedure will validate every
    *                 revised item attrbiute in its entirety.
    **********************************************************************/



    PROCEDURE Check_Attributes
        (  p_eam_res_rec             IN EAM_PROCESS_WO_PUB.eam_res_rec_type
         , p_old_eam_res_rec         IN EAM_PROCESS_WO_PUB.eam_res_rec_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
    )
    IS
    l_err_text              VARCHAR2(2000) := NULL;
    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    l_24_hr_resource        NUMBER ;
    l_calendar_code         VARCHAR2(10);
    l_count_shift_num       NUMBER;
    BEGIN

--  operation_seq_num

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating operation_seq_num . . . '); END IF;

   begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from wip_operations wo
     where wo.organization_id = p_eam_res_rec.organization_id
       and wo.wip_entity_id = p_eam_res_rec.wip_entity_id
       and wo.operation_seq_num = p_eam_res_rec.operation_seq_num;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'OP_SEQ_NUM_INVALID';
      l_token_tbl(1).token_value :=  p_eam_res_rec.operation_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_OP_SEQ_INVALID'
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

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    if p_eam_res_rec.start_date > p_eam_res_rec.completion_date then
      raise fnd_api.g_exc_unexpected_error;
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'START_DATE';
      l_token_tbl(1).token_value :=  p_eam_res_rec.start_date;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_START_DATE_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  assigned_units
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating assigned_units . . . '); END IF;

  begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    if (p_eam_res_rec.assigned_units is null or p_eam_res_rec.assigned_units < 0 ) then
       raise fnd_api.g_exc_unexpected_error;
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_ASSIGNED_UNIT_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;
/*commenting this check for 7183942

--  A resource cannot be added to same operation twice
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating resource uniquness in operation . . . '); END IF;

  begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE)) then

	    begin
	    select 1
	      into g_dummy
	      from wip_operation_resources wor
	     where wor.organization_id = p_eam_res_rec.organization_id
	       and wor.wip_entity_id = p_eam_res_rec.wip_entity_id
	       and wor.operation_seq_num = p_eam_res_rec.operation_seq_num
	       and wor.resource_id = p_eam_res_rec.resource_id;

	       if g_dummy >=1 then
		       raise fnd_api.g_exc_unexpected_error;
	       end if;
	     exception  when NO_DATA_FOUND then
		null;
	     end ;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_ID';
      l_token_tbl(1).token_value :=  p_eam_res_rec.resource_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_ALD_ADDED_WO'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

/*commenting this check for 7183942*/
--  resource_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating resource_id . . . '); END IF;

  begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from bom_resources
     where organization_id = p_eam_res_rec.organization_id
       and resource_id = p_eam_res_rec.resource_id;

    -- baroy - check whether the resource specified belongs to the department of the operation
    select
      1 into g_dummy
    from
      wip_operations wo,
      bom_departments bd,
      bom_department_resources bdr
    where
      wo.organization_id = p_eam_res_rec.organization_id
      and wo.wip_entity_id = p_eam_res_rec.wip_entity_id
      and wo.operation_seq_num = p_eam_res_rec.operation_seq_num
      and bd.department_id = wo.department_id
      and bdr.department_id = bd.department_id
      and bdr.resource_id = p_eam_res_rec.resource_id;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_RESOURCE_SEQ_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  uom_code
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating uom_code . . . '); END IF;

  begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from mtl_units_of_measure
     where uom_code = p_eam_res_rec.uom_code;

    -- baroy - check whether the uom_code - resource association is correct.
    select 1 into g_dummy from bom_resources
      where organization_id = p_eam_res_rec.organization_id
      and resource_id = p_eam_res_rec.resource_id
      and unit_of_measure = p_eam_res_rec.uom_code;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_UOM_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  basis_type
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating basis_type . . . '); END IF;

  begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from mfg_lookups
     where lookup_type = 'CST_BASIS'
       and lookup_code in (1,2)
       and lookup_code = p_eam_res_rec.basis_type;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_BASIS_TYPE_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  activity_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating activity_id . . . '); END IF;

  begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    IF (p_eam_res_rec.activity_id is not NULL)
    THEN

      select 1
        into g_dummy
        from cst_activities
       where (organization_id = p_eam_res_rec.organization_id or organization_id is null)
         and nvl(disable_date, sysdate + 2) > sysdate
         and activity_id = p_eam_res_rec.activity_id;

    END IF;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;


      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_ACTIVITY_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  autocharge_type
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating autocharge_type . . . '); END IF;

  begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from mfg_lookups
     where lookup_type = g_autocharge_type
       and lookup_code in (2,3)
       and lookup_code = p_eam_res_rec.autocharge_type;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_AC_TYPE_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  scheduled_flag
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating schedule_flag . . . '); END IF;

  begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

       if p_eam_res_rec.scheduled_flag not in (1,2) then
         raise fnd_api.g_exc_error;
       end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_SCHEDULE_TYPE_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  standard_rate_flag
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating schedule_flag . . . '); END IF;

  begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    IF (p_eam_res_rec.standard_rate_flag is not NULL) and (p_eam_res_rec.standard_rate_flag not in (1, 2))
    THEN

        raise fnd_api.g_exc_unexpected_error;

    END IF;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_STANDARD_RATE_INVALID'
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
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating  Department. . . '); END IF;

  begin

   -- Check whether resource dept and op dept match.
   select 1 into g_dummy from
     wip_operations wo
     where wo.wip_entity_id   = p_eam_res_rec.wip_entity_id
     and wo.organization_id   = p_eam_res_rec.organization_id
     and wo.operation_seq_num = p_eam_res_rec.operation_seq_num
     and wo.department_id     = p_eam_res_rec.department_id;

   -- Check whether dept is defined in BOM.
   select 1 into g_dummy from
     bom_departments bd where
     bd.organization_id     = p_eam_res_rec.organization_id
     and bd.department_id   = p_eam_res_rec.department_id;

   -- Check whether trying to update department (which is disallowed).
   IF p_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE THEN
	SELECT 1 into g_dummy
	  FROM wip_operation_resources wor, wip_operations wo
	  WHERE wor.wip_entity_id   = p_eam_res_rec.wip_entity_id
	    AND wo.wip_entity_id      = p_eam_res_rec.wip_entity_id
  	    AND wor.organization_id   = p_eam_res_rec.organization_id
	    AND wo.organization_id    = p_eam_res_rec.organization_id
	    AND wor.resource_seq_num  = p_eam_res_rec.resource_seq_num
	    AND wor.operation_seq_num = p_eam_res_rec.operation_seq_num
	    AND wo.operation_seq_num  = p_eam_res_rec.operation_seq_num
	    AND wo.department_id      = p_eam_res_rec.department_id;
   END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_DEPARTMENT_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  usage_rate_or_amount
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating usage_rate_or_amount . . . '); END IF;
  declare
    l_hour_uom             varchar2(50);
    l_hour_uom_class       varchar2(200);
    l_uom_time_class_flag  varchar2(3);
    l_uom_class            varchar2(10);
  begin

   if (p_eam_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    l_hour_uom := FND_PROFILE.value('BOM:HOUR_UOM_CODE');
    l_hour_uom_class := WIP_OP_RESOURCES_UTILITIES.Get_Uom_Class(l_hour_uom);

        select UOM.uom_class
          into l_uom_class
          from BOM_RESOURCES BR, MTL_UNITS_OF_MEASURE_VL UOM
         where BR.resource_id = p_eam_res_rec.resource_id
           and BR.unit_of_measure = UOM.uom_code;

    IF l_hour_uom_class = l_uom_class THEN
           l_uom_time_class_flag := 'Y';
    ELSE
           l_uom_time_class_flag := '';
    END IF;

    IF (p_eam_res_rec.usage_rate_or_amount < 0 and (p_eam_res_rec.autocharge_type = 3 or l_uom_time_class_flag = 'Y'))
    THEN

        raise fnd_api.g_exc_unexpected_error;

    END IF;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RES_USAGE_RATE_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


    /* added for bug no 3393323 */
    IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating that shift must exists if resource is not 24 hr resource . . . '); END IF;

    begin

    if p_eam_res_rec.scheduled_flag = 1 then
    -- Shift must exists for a resource which is not 24 hour resource

        select calendar_code into l_calendar_code
	   from mtl_parameters
	   where organization_id = p_eam_res_rec.organization_id;

       select   available_24_hours_flag into l_24_hr_resource
	  from   bom_department_resources bdr
	  where   bdr.department_id = p_eam_res_rec.department_id
		 and  bdr.resource_id = p_eam_res_rec.resource_id ;

	 -- available_24_hours_flag is '1' for 24 hr resource and '2' for not 24 hr resource

	 if (l_24_hr_resource = 2) then
         	select    count(rsh.shift_num) into l_count_shift_num
		  from   bom_shift_times shf,
		         bom_resource_shifts rsh,
	                 bom_department_resources bdr
		 where   bdr.department_id = p_eam_res_rec.department_id
			 and  bdr.resource_id = p_eam_res_rec.resource_id
			 and nvl(bdr.share_from_dept_id, bdr.department_id) = rsh.department_id
			 and bdr.resource_id = rsh.resource_id
		         and rsh.shift_num = shf.shift_num
			 and shf.calendar_code = l_calendar_code;


	  if(l_count_shift_num=0) then
	    l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
	    l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_RES_RESOURCE_SHIFT_ND'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
            );
           l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;
	 end if;
       end if;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
     end if;
     exception
       when others then
       l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
       l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

       l_out_mesg_token_tbl  := l_mesg_token_tbl;
       EAM_ERROR_MESSAGE_PVT.Add_Error_Token
       (  p_message_name  => 'EAM_RES_RESOURCE_SHIFT_ND'
        , p_token_tbl     => l_token_tbl
        , p_mesg_token_tbl     => l_mesg_token_tbl
        , x_mesg_token_tbl     => l_out_mesg_token_tbl
       );
       l_mesg_token_tbl      := l_out_mesg_token_tbl;

       x_return_status := FND_API.G_RET_STS_ERROR;
       x_mesg_token_tbl := l_mesg_token_tbl ;
       return;
   end;


     --  delete resource
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating resource . . . '); END IF;

       declare
         l_count_wt                NUMBER :=0;
         l_count_wcti              NUMBER :=0;
         l_applied_res_units       NUMBER :=0;
       begin

       if (p_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE) then

             select count(*)
             into l_count_wt
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM wip_transactions
			    where wip_entity_id         = p_eam_res_rec.wip_entity_id
			      and organization_id       = p_eam_res_rec.organization_id
			      and operation_seq_num     = p_eam_res_rec.operation_seq_num
			      and resource_seq_num      = p_eam_res_rec.resource_seq_num
			      and resource_id           = p_eam_res_rec.resource_id);

           if(l_count_wt > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

             select count(*)
             into l_count_wcti
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM wip_cost_txn_interface
			    where wip_entity_id         = p_eam_res_rec.wip_entity_id
			      and organization_id       = p_eam_res_rec.organization_id
			      and operation_seq_num     = p_eam_res_rec.operation_seq_num
			      and resource_seq_num      = p_eam_res_rec.resource_seq_num
			      and resource_id           = p_eam_res_rec.resource_id);

           if(l_count_wcti > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

           select nvl(applied_resource_units,0)
             into l_applied_res_units
             from wip_operation_resources
            where wip_entity_id         = p_eam_res_rec.wip_entity_id
              and organization_id       = p_eam_res_rec.organization_id
              and operation_seq_num     = p_eam_res_rec.operation_seq_num
              and resource_seq_num      = p_eam_res_rec.resource_seq_num
              and resource_id           = p_eam_res_rec.resource_id;

           if(l_applied_res_units <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
           l_token_tbl(1).token_value :=  p_eam_res_rec.wip_entity_id;

           l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_RES_DELETE_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
           l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;

     --if any resource instances are there we should not be able to delete the resource
     declare
         l_count_inst     NUMBER :=0;
     begin
        if (p_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE) then
		    select count(*)
		    into l_count_inst
		    from wip_op_resource_instances
		    where wip_entity_id         = p_eam_res_rec.wip_entity_id
		      and organization_id       = p_eam_res_rec.organization_id
		      and operation_seq_num     = p_eam_res_rec.operation_seq_num
		      and resource_seq_num      = p_eam_res_rec.resource_seq_num
		      and rownum <=1;

		   if(l_count_inst <> 0) then
		       raise fnd_api.g_exc_unexpected_error;
		   end if;
	 end if;
     exception
         when others then

		   l_out_mesg_token_tbl  := l_mesg_token_tbl;
		   EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		   (  p_message_name  => 'EAM_INSTANCES_EXIST'
		    , p_token_tbl     => l_token_tbl
		    , p_mesg_token_tbl     => l_mesg_token_tbl
		    , x_mesg_token_tbl     => l_out_mesg_token_tbl
		   );
		   l_mesg_token_tbl      := l_out_mesg_token_tbl;

		   x_return_status := FND_API.G_RET_STS_ERROR;
		   x_mesg_token_tbl := l_mesg_token_tbl ;
		   return;
     end;


     --  delete resource
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating substitute_resource . . . '); END IF;

       declare
         l_count_po               NUMBER :=0;
         l_count_req              NUMBER :=0;
         l_count_dist             NUMBER :=0;
       begin

       if (p_eam_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE) then

             select count(*)
             into l_count_po
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM po_requisitions_interface
			    where wip_entity_id               = p_eam_res_rec.wip_entity_id
			      and destination_organization_id = p_eam_res_rec.organization_id
			      and wip_operation_seq_num       = p_eam_res_rec.operation_seq_num
			      and wip_resource_seq_num        = p_eam_res_rec.resource_seq_num
			      and bom_resource_id             = p_eam_res_rec.resource_id);

           if(l_count_po <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;


             select count(*)
             into l_count_req
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM po_requisition_lines prl, po_requisition_headers prh
			    where prl.requisition_header_id = prh.requisition_header_id
			      and prl.wip_entity_id               = p_eam_res_rec.wip_entity_id
			      and prl.destination_organization_id = p_eam_res_rec.organization_id
			      and prl.wip_operation_seq_num       = p_eam_res_rec.operation_seq_num
			      and prl.wip_resource_seq_num        = p_eam_res_rec.resource_seq_num
			      and prl.bom_resource_id             = p_eam_res_rec.resource_id
			      and   (prh.authorization_status <>'CANCELLED'
				 or    prh.authorization_status is null)
			      and   (prl.cancel_flag <>'Y' or prl.cancel_flag is null)
			      and   (prl.closed_code not in ('FINALLY CLOSED')
				 or    prl.closed_code is null)
			      and   (prl.modified_by_agent_flag <> 'Y'
				 or    prl.modified_by_agent_flag is null));


           if(l_count_req <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;


             select count(*)
             into l_count_dist
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM po_distributions pds,po_line_locations poll
			    where pds.line_location_id =  poll.line_location_id
			      and pds.wip_entity_id               = p_eam_res_rec.wip_entity_id
			      and pds.destination_organization_id = p_eam_res_rec.organization_id
			      and pds.wip_operation_seq_num       = p_eam_res_rec.operation_seq_num
			      and pds.wip_resource_seq_num        = p_eam_res_rec.resource_seq_num
			      and pds.bom_resource_id             = p_eam_res_rec.resource_id
			      and   (poll.cancel_flag <>'Y' or poll.cancel_flag is null)
			      and   (poll.closed_code not in ('CANCELLED','FINALLY CLOSED')
				     or    poll.closed_code is null));


           if(l_count_dist <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

         end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
           l_token_tbl(1).token_value :=  p_eam_res_rec.wip_entity_id;

           l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_RES_DELETE_PO_INVALID'
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

        IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within Resource Check Attributes . . . '); END IF;



    END Check_Attributes;

    /*********************************************************************
    * Procedure     : Check_Required
    * Parameters IN : Resource column record
    * Parameters OUT NOCOPY: Mesg Token Table
    *                 Return_Status
    * Purpose       :
    **********************************************************************/

    PROCEDURE Check_Required
        (  p_eam_res_rec            IN EAM_PROCESS_WO_PUB.eam_res_rec_type
         , x_return_status          OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )
    IS
            l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_eam_res_rec.wip_entity_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_ENTITY_ID_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.organization_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_ORG_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.operation_seq_num IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_OP_SEQ_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.resource_seq_num IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_RES_SEQ_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.resource_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_RESOURCE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.basis_type IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_BASIS_TYPE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.usage_rate_or_amount IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_USAGE_RATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.scheduled_flag IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_SCHEDULE_TYPE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.autocharge_type IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_AC_TYPE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.standard_rate_flag IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_STD_RATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.applied_resource_units IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_APPL_UNIT_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.applied_resource_value IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_APPL_VALUE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.start_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_START_DATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.completion_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_COMPL_DATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_rec.department_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_DEPARTMENT_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_res_rec.uom_code IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RES_UOM_CODE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    END Check_Required;

END EAM_RES_VALIDATE_PVT;

/
