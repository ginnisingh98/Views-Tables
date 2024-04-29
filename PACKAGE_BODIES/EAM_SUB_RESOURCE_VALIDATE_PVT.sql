--------------------------------------------------------
--  DDL for Package Body EAM_SUB_RESOURCE_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SUB_RESOURCE_VALIDATE_PVT" AS
/* $Header: EAMVSRVB.pls 120.0 2005/05/24 17:31:04 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVSRVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_SUB_RESOURCE_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_SUB_RESOURCE_VALIDATE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_dummy         NUMBER;
g_autocharge_type VARCHAR2(30) := EAM_CONSTANTS.G_AUTOCHARGE_TYPE;

    /*******************************************************************
    * Procedure	: Check_Existence
    * Returns	: None
    * Parameters IN : Sub Resource Record
    * Parameters OUT NOCOPY: Old Sub Resource Record
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: Procedure will query the old Sub Resource
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
     ( p_eam_sub_res_rec              IN  EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
     , x_old_eam_sub_res_rec          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
     , x_Mesg_Token_Tbl               OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , x_return_status                OUT NOCOPY VARCHAR2
        )
     IS
            l_token_tbl      EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
            l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_return_status  VARCHAR2(1);
     BEGIN

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quering Sub Resource'); END IF;

        EAM_SUB_RESOURCE_UTILITY_PVT.Query_Row
        ( p_wip_entity_id       => p_eam_sub_res_rec.wip_entity_id
        , p_organization_id     => p_eam_sub_res_rec.organization_id
        , p_operation_seq_num   => p_eam_sub_res_rec.operation_seq_num
        , p_resource_seq_num    => p_eam_sub_res_rec.resource_seq_num
        , x_eam_sub_res_rec     => x_old_eam_sub_res_rec
        , x_Return_status       => l_return_status
        );

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Query Row Returned with : ' || l_return_status); END IF;

        IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND AND
            p_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value := p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_SR_ALREADY_EXISTS'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND AND
             p_eam_sub_res_rec.transaction_type IN
             (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'EAM_SR_DOESNOT_EXISTS'
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
             , p_message_text       => 'Unexpected error while existence verification of ' || 'Sub Resource '|| p_eam_sub_res_rec.resource_seq_num , p_token_tbl => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        ELSE /* Assign the relevant transaction type for SYNC operations */
            IF p_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
               IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND THEN
                   x_old_eam_sub_res_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
               ELSE
                   x_old_eam_sub_res_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
               END IF;
            END IF;
            l_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;
    END Check_Existence;



    /********************************************************************
    * Procedure     : Check_Attributes
    * Parameters IN : Sub Resource Column record
    *                 Old Sub Resource Column record
    * Parameters OUT NOCOPY: Return Status
    *                 Mesg Token Table
    * Purpose       : Check_Attrbibutes procedure will validate every
    *                 revised item attrbiute in its entirety.
    **********************************************************************/

    PROCEDURE Check_Attributes
        (  p_eam_sub_res_rec          IN EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
         , p_old_eam_sub_res_rec      IN EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
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

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from wip_operations wo
     where wo.organization_id = p_eam_sub_res_rec.organization_id
       and wo.wip_entity_id = p_eam_sub_res_rec.wip_entity_id
       and wo.operation_seq_num = p_eam_sub_res_rec.operation_seq_num;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'OP_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.operation_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_OP_SEQ_INVALID'
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

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    if p_eam_sub_res_rec.start_date > p_eam_sub_res_rec.completion_date then
      raise fnd_api.g_exc_unexpected_error;
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'START_DATE';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.start_date;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_START_DATE_INVALID'
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

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    if (p_eam_sub_res_rec.assigned_units < 0 ) then
       raise fnd_api.g_exc_unexpected_error;
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_ASSIGNED_UNIT_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  resource_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating resource_id . . . '); END IF;

  begin

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from bom_resources
     where organization_id = p_eam_sub_res_rec.organization_id
       and resource_id = p_eam_sub_res_rec.resource_id;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_RESOURCE_INVALID'
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

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from mtl_units_of_measure
     where uom_code = p_eam_sub_res_rec.uom_code;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_UOM_INVALID'
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

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from mfg_lookups
     where lookup_type = 'CST_BASIS'
       and lookup_code in (1,2)
       and lookup_code = p_eam_sub_res_rec.basis_type;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_BASIS_TYPE_INVALID'
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

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    IF (p_eam_sub_res_rec.activity_id is not NULL)
    THEN

      select 1
        into g_dummy
        from cst_activities
       where (organization_id = p_eam_sub_res_rec.organization_id or organization_id is null)
         and nvl(disable_date, sysdate + 2) > sysdate
         and activity_id = p_eam_sub_res_rec.activity_id;

    END IF;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_ACTIVITY_INVALID'
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

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from mfg_lookups
     where lookup_type = g_autocharge_type
       and lookup_code in (2,3)
       and lookup_code = p_eam_sub_res_rec.autocharge_type;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_AC_TYPE_INVALID'
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

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    select 1
      into g_dummy
      from mfg_lookups
     where lookup_type = 'BOM_RESOURCE_SCHEDULE_TYPE'
       and lookup_code = p_eam_sub_res_rec.scheduled_flag;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_SCHEDULE_TYPE_INVALID'
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

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    IF (p_eam_sub_res_rec.standard_rate_flag is not NULL) and (p_eam_sub_res_rec.standard_rate_flag not in (1, 2))
    THEN

        raise fnd_api.g_exc_unexpected_error;

    END IF;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_STANDARD_RATE_INVALID'
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
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating  Department. . .
 '); END IF;

  begin

   -- Check whether sub resource dept and op dept match.
   select 1 into g_dummy from
     wip_operations wo
     where wo.wip_entity_id   = p_eam_sub_res_rec.wip_entity_id
     and wo.organization_id   = p_eam_sub_res_rec.organization_id
     and wo.operation_seq_num = p_eam_sub_res_rec.operation_seq_num
     and wo.department_id     = p_eam_sub_res_rec.department_id;

   -- Check whether dept is defined in BOM.
   select 1 into g_dummy from
     bom_departments bd where
     bd.organization_id     = p_eam_sub_res_rec.organization_id
     and bd.department_id   = p_eam_sub_res_rec.department_id;

   -- Check whether trying to update department (which is disallowed).
   IF p_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE THEN

     select 1 into g_dummy from
       wip_sub_operation_resources wsor where
       wsor.wip_entity_id         = p_eam_sub_res_rec.wip_entity_id
       and wsor.organization_id   = p_eam_sub_res_rec.organization_id
       and wsor.resource_seq_num  = p_eam_sub_res_rec.resource_seq_num
       and wsor.operation_seq_num = p_eam_sub_res_rec.operation_seq_num
       and wsor.department_id     = p_eam_sub_res_rec.department_id;

   END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_DEPARTMENT_INVALID'
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

   if (p_eam_sub_res_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE, EAM_PROCESS_WO_PVT.G_OPR_UPDATE)) then

    l_hour_uom := FND_PROFILE.value('BOM:HOUR_UOM_CODE');
    l_hour_uom_class := WIP_OP_RESOURCES_UTILITIES.Get_Uom_Class(l_hour_uom);

        select UOM.uom_class
          into l_uom_class
          from BOM_RESOURCES BR, MTL_UNITS_OF_MEASURE_VL UOM
         where BR.resource_id = p_eam_sub_res_rec.resource_id
           and BR.unit_of_measure = UOM.uom_code;

    IF l_hour_uom_class = l_uom_class THEN
           l_uom_time_class_flag := 'Y';
    ELSE
           l_uom_time_class_flag := '';
    END IF;

    IF (p_eam_sub_res_rec.usage_rate_or_amount < 0 and (p_eam_sub_res_rec.autocharge_type = 3 or l_uom_time_class_flag = 'Y'))
    THEN

        raise fnd_api.g_exc_unexpected_error;

    END IF;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_SR_USAGE_RATE_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;



     --  delete substitute_resource
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating substitute_resource . . . '); END IF;

       declare
         l_count_wt                NUMBER :=0;
         l_count_wcti              NUMBER :=0;
         l_applied_res_units       NUMBER :=0;
       begin

       if (p_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE) then

             select count(*)
             into l_count_wt
             from  DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM wip_transactions
			    where wip_entity_id         = p_eam_sub_res_rec.wip_entity_id
			      and organization_id       = p_eam_sub_res_rec.organization_id
			      and operation_seq_num     = p_eam_sub_res_rec.operation_seq_num
			      and resource_seq_num      = p_eam_sub_res_rec.resource_seq_num
			      and resource_id           = p_eam_sub_res_rec.resource_id);

           if(l_count_wt > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

           select count(*)
             into l_count_wcti
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM wip_cost_txn_interface
			    where wip_entity_id         = p_eam_sub_res_rec.wip_entity_id
			      and organization_id       = p_eam_sub_res_rec.organization_id
			      and operation_seq_num     = p_eam_sub_res_rec.operation_seq_num
			      and resource_seq_num      = p_eam_sub_res_rec.resource_seq_num
			      and resource_id           = p_eam_sub_res_rec.resource_id);

           if(l_count_wcti > 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

           select applied_resource_units
             into l_applied_res_units
             from wip_operation_resources
            where wip_entity_id         = p_eam_sub_res_rec.wip_entity_id
              and organization_id       = p_eam_sub_res_rec.organization_id
              and operation_seq_num     = p_eam_sub_res_rec.operation_seq_num
              and resource_seq_num      = p_eam_sub_res_rec.resource_seq_num
              and resource_id           = p_eam_sub_res_rec.resource_id;

           if(l_applied_res_units <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

       end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
           l_token_tbl(1).token_value :=  p_eam_sub_res_rec.wip_entity_id;

           l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_SR_DELETE_INVALID'
            , p_token_tbl     => l_token_tbl
            , p_mesg_token_tbl     => l_mesg_token_tbl
            , x_mesg_token_tbl     => l_out_mesg_token_tbl
           );
           l_mesg_token_tbl      := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           x_mesg_token_tbl := l_mesg_token_tbl ;
           return;

       end;


     --  delete substitute_resource
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating substitute_resource . . . '); END IF;

       declare
         l_count_po               NUMBER :=0;
         l_count_req              NUMBER :=0;
         l_count_dist             NUMBER :=0;
       begin

       if (p_eam_sub_res_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE) then

           select count(*)
             into l_count_po
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM po_requisitions_interface
			    where wip_entity_id               = p_eam_sub_res_rec.wip_entity_id
			      and destination_organization_id = p_eam_sub_res_rec.organization_id
			      and wip_operation_seq_num       = p_eam_sub_res_rec.operation_seq_num
			      and wip_resource_seq_num        = p_eam_sub_res_rec.resource_seq_num
			      and bom_resource_id             = p_eam_sub_res_rec.resource_id);

           if(l_count_po <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;


           select count(*)
             into l_count_req
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM po_requisition_lines
			    where wip_entity_id               = p_eam_sub_res_rec.wip_entity_id
			      and destination_organization_id = p_eam_sub_res_rec.organization_id
			      and wip_operation_seq_num       = p_eam_sub_res_rec.operation_seq_num
			      and wip_resource_seq_num        = p_eam_sub_res_rec.resource_seq_num
			      and bom_resource_id             = p_eam_sub_res_rec.resource_id);

           if(l_count_req <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;


           select count(*)
             into l_count_dist
             from DUAL
	     WHERE EXISTS (SELECT 1
	                    FROM po_distributions
			    where wip_entity_id               = p_eam_sub_res_rec.wip_entity_id
			      and destination_organization_id = p_eam_sub_res_rec.organization_id
			      and wip_operation_seq_num       = p_eam_sub_res_rec.operation_seq_num
			      and wip_resource_seq_num        = p_eam_sub_res_rec.resource_seq_num
			      and bom_resource_id             = p_eam_sub_res_rec.resource_id);

           if(l_count_dist <> 0) then
             raise fnd_api.g_exc_unexpected_error;
           end if;

         end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

       exception
         when others then

           l_token_tbl(1).token_name  := 'WIP_ENTITY_ID';
           l_token_tbl(1).token_value :=  p_eam_sub_res_rec.wip_entity_id;

           l_out_mesg_token_tbl  := l_mesg_token_tbl;
           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  p_message_name  => 'EAM_SR_DELETE_PO_INVALID'
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

        IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within Sub Resource Check Attributes . . . '); END IF;



    END Check_Attributes;

    /*********************************************************************
    * Procedure     : Check_Required
    * Parameters IN : Sub Resource column record
    * Parameters OUT NOCOPY: Mesg Token Table
    *                 Return_Status
    * Purpose       :
    **********************************************************************/

    PROCEDURE Check_Required
        (  p_eam_sub_res_rec          IN EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
         , x_return_status            OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )
    IS
            l_Mesg_Token_Tbl          EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl          EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl               EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_eam_sub_res_rec.wip_entity_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_ENTITY_ID_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.organization_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_ORG_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.operation_seq_num IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_OP_SEQ_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.resource_seq_num IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_RES_SEQ_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.resource_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_RESOURCE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.basis_type IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_BASIS_TYPE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.usage_rate_or_amount IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_USAGE_RATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.scheduled_flag IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_SCHEDULE_TYPE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.autocharge_type IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_AC_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.standard_rate_flag IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_STD_RATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.applied_resource_units IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_APPL_UNIT_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.applied_resource_value IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_APPL_VALUE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.start_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_START_DATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_sub_res_rec.completion_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_sub_res_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_COMPL_DATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_sub_res_rec.department_id IS NULL
        THEN

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_SR_DEPARTMENT_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;



        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    END Check_Required;


END EAM_SUB_RESOURCE_VALIDATE_PVT;

/
