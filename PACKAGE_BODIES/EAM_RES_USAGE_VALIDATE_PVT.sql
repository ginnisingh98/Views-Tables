--------------------------------------------------------
--  DDL for Package Body EAM_RES_USAGE_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_RES_USAGE_VALIDATE_PVT" AS
/* $Header: EAMVRUVB.pls 115.3 2002/12/10 13:02:52 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRUVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_RES_USAGE_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_RES_USAGE_VALIDATE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_dummy         NUMBER;

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
        (  p_eam_res_usage_rec       IN EAM_PROCESS_WO_PUB.eam_res_usage_rec_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
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

   if (p_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

    select 1
      into g_dummy
      from wip_operations wo
     where wo.organization_id = p_eam_res_usage_rec.organization_id
       and wo.wip_entity_id = p_eam_res_usage_rec.wip_entity_id
       and wo.operation_seq_num = p_eam_res_usage_rec.operation_seq_num;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'OP_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_usage_rec.operation_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RU_OP_SEQ_INVALID'
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

   if (p_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

    select 1
      into g_dummy
      from wip_operation_resources wor
     where wor.organization_id = p_eam_res_usage_rec.organization_id
       and wor.wip_entity_id = p_eam_res_usage_rec.wip_entity_id
       and wor.operation_seq_num = p_eam_res_usage_rec.operation_seq_num
       and wor.resource_seq_num = p_eam_res_usage_rec.resource_seq_num;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RU_RES_SEQ_INVALID'
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

  begin

   if (p_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

      select count(*)
        into g_dummy
        from bom_resource_equipments
       where instance_id = p_eam_res_usage_rec.instance_id
         and organization_id = p_eam_res_usage_rec.organization_id;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RU_INSTANCE_INVALID'
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

   if (p_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

    if (p_eam_res_usage_rec.serial_number is not NULL) then

      select count(*)
        into g_dummy
        from mtl_serial_numbers msn, bom_resource_equipments bre
       where msn.inventory_item_id = bre.inventory_item_id
         and msn.current_organization_id = bre.organization_id
         and bre.instance_id = p_eam_res_usage_rec.instance_id
         and msn.serial_number = p_eam_res_usage_rec.serial_number;

    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RU_SERIAL_NUMBER_INVALID'
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

   if (p_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

    if p_eam_res_usage_rec.start_date > p_eam_res_usage_rec.completion_date then
      raise fnd_api.g_exc_unexpected_error;
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RU_START_DATE_INVALID'
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

   if (p_eam_res_usage_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

    if (p_eam_res_usage_rec.assigned_units < 0 ) then
       raise fnd_api.g_exc_unexpected_error;
    end if;

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'RES_SEQ_NUM';
      l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_RU_ASSIGNED_UNIT_INVALID'
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
        (  p_eam_res_usage_rec       IN EAM_PROCESS_WO_PUB.eam_res_usage_rec_type
         , x_return_status          OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )
    IS
            l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        IF p_eam_res_usage_rec.wip_entity_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RU_ENTITY_ID_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_usage_rec.organization_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RU_ORG_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_usage_rec.operation_seq_num IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RU_OP_SEQ_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_usage_rec.resource_seq_num IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RU_RES_SEQ_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_usage_rec.start_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RU_START_DATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_usage_rec.completion_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RU_COMPL_DATE_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_res_usage_rec.assigned_units IS NULL
        THEN
            l_token_tbl(1).token_name  := 'RESOURCE_SEQ_NUM';
            l_token_tbl(1).token_value :=  p_eam_res_usage_rec.resource_seq_num;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_RU_ASSIGNED_UNIT_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    END Check_Required;

END EAM_RES_USAGE_VALIDATE_PVT;

/
