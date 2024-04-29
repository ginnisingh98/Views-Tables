--------------------------------------------------------
--  DDL for Package Body EAM_WO_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_VALIDATE_PVT" AS
/* $Header: EAMVWOVB.pls 120.33.12010000.2 2010/03/03 00:01:13 mashah ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWOVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
--  02-May-2005    Anju Gupta         IB/Transactable project changes for R12
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_WO_VALIDATE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_dummy         NUMBER;
g_obj_source VARCHAR2(30)		:= EAM_CONSTANTS.G_OBJ_SOURCE;
g_obj_type VARCHAR2(30)			:= EAM_CONSTANTS.G_OBJ_TYPE;
g_act_source VARCHAR2(30) 	:= EAM_CONSTANTS.G_ACT_SOURCE;
g_act_cause VARCHAR2(30) 		:= EAM_CONSTANTS.G_ACT_CAUSE;
g_act_type VARCHAR2(30) 		:= EAM_CONSTANTS.G_ACT_TYPE;
g_wo_type VARCHAR2(30) 			:= EAM_CONSTANTS.G_WO_TYPE;
g_shutdown_type VARCHAR2(30):= EAM_CONSTANTS.G_SHUTDOWN_TYPE;

    /*******************************************************************
    * Procedure	: Check_Existence
    * Returns	: None
    * Parameters IN : Work Order Record
    * Parameters OUT NOCOPY: Old Work Order Record
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
     ( p_eam_wo_rec             IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
     , x_old_eam_wo_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
     , x_Mesg_Token_Tbl	        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , x_return_status	        OUT NOCOPY VARCHAR2
        )
     IS
            l_token_tbl      EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
            l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_return_status  VARCHAR2(1);
     BEGIN

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quering Work Order'); END IF;

        EAM_WO_UTILITY_PVT.Query_Row
        ( p_wip_entity_id       => p_eam_wo_rec.wip_entity_id
        , p_organization_id     => p_eam_wo_rec.organization_id
        , x_eam_wo_rec          => x_old_eam_wo_rec
        , x_Return_status       => l_return_status
        );

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Query Row Returned with : ' || l_return_status); END IF;

        IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND AND
            p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value := p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_WO_ALREADY_EXISTS'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND AND
             p_eam_wo_rec.transaction_type IN
             (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name  => 'EAM_WO_DOESNOT_EXISTS'
                         , p_token_tbl     => l_token_tbl
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
             , p_message_text       => 'Unexpected error while existence verification of ' || 'EAM WO '|| p_eam_wo_rec.wip_entity_name , p_token_tbl => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        ELSE /* Assign the relevant transaction type for SYNC operations */
            IF p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
               IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND THEN
                   x_old_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
               ELSE
                   x_old_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
               END IF;
            END IF;
            l_return_status := FND_API.G_RET_STS_SUCCESS;

        END IF;

        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;
    END Check_Existence;



    /********************************************************************
    * Procedure     : Check_Attributes_b4_Defaulting
    * Parameters IN : Work Order Column record
    * Parameters OUT NOCOPY: Return Status
    *                 Mesg Token Table
    * Purpose       : Check_Attrbibutes_b4_Defaulting procedure will validate all item
    *                 attributes that are required in defaulting other items

    --  Change History
    --  02-May-2005 Anju Gupta  IB/Transactable Asset changes for R12
    **********************************************************************/

    PROCEDURE Check_Attributes_b4_Defaulting
        (  p_eam_wo_rec              IN EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_Mesg_Token_Tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
    )
    IS
    l_err_text              VARCHAR2(2000) := NULL;
    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    l_old_eam_wo_moid        NUMBER       :=  0;

    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within WO Check Attributes b4 Defaulting . . . '); END IF;


--  organization_id

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating organization_id . . . '); END IF;

  declare
    l_disable_date date;
  begin
      select 1
      into g_dummy
      from mtl_parameters mp
     where mp.organization_id = p_eam_wo_rec.organization_id;

    select nvl(hou.date_to,sysdate+1)
      into l_disable_date
      from hr_organization_units hou
      where organization_id =  p_eam_wo_rec.organization_id;

    if(l_disable_date < sysdate) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then
      l_token_tbl(1).token_name  := 'Organization Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.organization_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ORGANIZATION_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  organization_id (EAM enabled)

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating organization_id (EAM enabled) . . . '); END IF;

--Only check EAM enabled for CMRO, part of bug fix 9313320
 IF p_eam_wo_rec.maintenance_object_source = 2 then

    begin

     select 1
      into g_dummy
      from mtl_parameters mp
      where mp.eam_enabled_flag = 'Y'
      and mp.organization_id = p_eam_wo_rec.organization_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then
      l_token_tbl(1).token_name  := 'Organization Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.organization_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ORG_EAM_ENABLED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

 ELSE  -- For EAM work orders, if mtl org is EAM enabled, then it must be the same as the maintenance org
  begin
      select 1
      into g_dummy
      from wip_eam_parameters wep, mtl_parameters mp
     where wep.organization_id = mp.organization_id
       and mp.eam_enabled_flag = 'Y'
       and wep.organization_id = p_eam_wo_rec.organization_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Organization Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.organization_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ORG_EAM_ENABLED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


END IF;

--  maintenance_object_source

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating maintenance_object_source . . . '); END IF;

  begin

    if p_eam_wo_rec.maintenance_object_source is null or
       p_eam_wo_rec.maintenance_object_source = fnd_api.g_miss_num
    then
      raise fnd_api.g_exc_error;
    end if;

    select 1 into g_dummy from
      mfg_lookups where lookup_type = g_obj_source
      and lookup_code = p_eam_wo_rec.maintenance_object_source;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_error then

      l_token_tbl(1).token_name  := 'Object Source';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.maintenance_object_source;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_MAINT_OBJ_SRC_REQUIRED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    when no_data_found then

      l_token_tbl(1).token_name  := 'Object Source';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.maintenance_object_source;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_MAINT_OBJ_SOURCE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  maintenance_object_type

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating maintenance_object_type . . . '); END IF;

  begin

    if p_eam_wo_rec.maintenance_object_type is null or
       p_eam_wo_rec.maintenance_object_type = fnd_api.g_miss_num or
       p_eam_wo_rec.maintenance_object_type = 1
    then
      raise fnd_api.g_exc_error;
    end if;

    select 1 into g_dummy from
      mfg_lookups where lookup_type = g_obj_type
      and lookup_code = p_eam_wo_rec.maintenance_object_type;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_error then

      l_token_tbl(1).token_name  := 'Object Type';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.maintenance_object_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_MAINT_OBJ_TYPE_REQUIRED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    when no_data_found then

      l_token_tbl(1).token_name  := 'Object Type';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.maintenance_object_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_MAINT_OBJ_TYPE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  maintenance_object_id

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating maintenance_object_id . . . '); END IF;

  begin

    if p_eam_wo_rec.maintenance_object_id is null or
       p_eam_wo_rec.maintenance_object_id = fnd_api.g_miss_num
    then
      raise fnd_api.g_exc_error;
    end if;

    IF p_eam_wo_rec.maintenance_object_type = 3 then
      --CMRO does not use the EAM family of maintenance orgs concept.
      IF p_eam_wo_rec.maintenance_object_source = 1 THEN

        IF p_eam_wo_rec.transaction_type <> EAM_PROCESS_WO_PVT.G_OPR_CREATE THEN
            select maintenance_object_id into l_old_eam_wo_moid
    	    from wip_discrete_jobs
       	    where wip_entity_id = p_eam_wo_rec.wip_entity_id
            and   organization_id = p_eam_wo_rec.organization_id
            and rownum = 1;
        END IF;
        IF  p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            OR (p_eam_wo_rec.transaction_type <> EAM_PROCESS_WO_PVT.G_OPR_CREATE
                AND l_old_eam_wo_moid <>  p_eam_wo_rec.maintenance_object_id) THEN
            -- Code for create validation
            select 1 into g_dummy
            from csi_item_instances cii, mtl_parameters mp
            where cii.last_vld_organization_id = mp.organization_id
            and mp.maint_organization_id = p_eam_wo_rec.organization_id
            and cii.instance_id = p_eam_wo_rec.maintenance_object_id
            and cii.inventory_item_id = nvl(p_eam_wo_rec.asset_group_id, p_eam_wo_rec.rebuild_item_id)
            and rownum = 1;
        END IF;
      END IF;

    ELSIF p_eam_wo_rec.maintenance_object_type = 2 then
      if (p_eam_wo_rec.maintenance_object_source = 1) then
      select 1 into g_dummy from mtl_system_items msi, mtl_parameters mp where
      msi.organization_id = mp.organization_id
      and mp.maint_organization_id = p_eam_wo_rec.organization_id
      and msi.inventory_item_id = p_eam_wo_rec.maintenance_object_id
      and rownum = 1;
      elsif (p_eam_wo_rec.maintenance_object_source = 2) then
      	 select 1 into g_dummy from mtl_system_items where
        organization_id = p_eam_wo_rec.organization_id
        and inventory_item_id = p_eam_wo_rec.maintenance_object_id;
      end if;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_error then

      l_token_tbl(1).token_name  := 'Object Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.maintenance_object_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_MAINT_OBJ_ID_REQUIRED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    when others then

      l_token_tbl(1).token_name  := 'Object Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.maintenance_object_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_MAINT_OBJ_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  rebuild_item_id

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating rebuild_item_id . . . '); END IF;

  begin

    -- for CMRO work orders, the rebuild_item_id cannot be null.
    if p_eam_wo_rec.maintenance_object_source = 2 and
       p_eam_wo_rec.rebuild_item_id is null
    then
      raise fnd_api.g_exc_error;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception

    when fnd_api.g_exc_error then

      l_token_tbl(1).token_name  := 'Wip Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_REBUILD_ITEM_REQUIRED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  rebuild_item_id and asset_group_id

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating rebuild_item_id and asset_group_id. . . '); END IF;

  begin

    -- rebuild_item_id  and asset_group_id cannot both be null.
    if p_eam_wo_rec.asset_group_id is null and
       p_eam_wo_rec.rebuild_item_id is null
    then
      raise fnd_api.g_exc_error;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_error then

      l_token_tbl(1).token_name  := 'Wip Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_AG_RB_REQUIRED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  wip_entity_id

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating wip_entity_id . . . '); END IF;

  begin

    if p_eam_wo_rec.wip_entity_id is not null and
       p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
    then
      raise fnd_api.g_exc_error;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_error then

      l_token_tbl(1).token_name  := 'Wip Entity Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_WIP_ENTITY_ID'
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

        l_token_tbl(1).token_name  := 'Validation (Check Attributes b4 defaulting)';
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

END Check_Attributes_b4_Defaulting;

    /********************************************************************
    * Procedure     : Check_Attributes
    * Parameters IN : Work Order Column record
    *                 Old Work Order Column record
    * Parameters OUT NOCOPY: Return Status
    *                 Mesg Token Table
    * Purpose       : Check_Attrbibutes procedure will validate every
    *                 revised item attrbiute in its entirety.
    -- Change History
    --  Anju Gupta  05/03/05    IB/Transactable Asset changes for R12
    **********************************************************************/

    PROCEDURE Check_Attributes
        (  p_eam_wo_rec              IN EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_old_eam_wo_rec          IN EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
    )
    IS
    l_err_text              VARCHAR2(2000) := NULL;
    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    l_mo_err_flag           VARCHAR2(1) ;
    l_trans_exist           VARCHAR2(1);

    l_rebuild_status        NUMBER;
    l_current_status        NUMBER;
    l_enabled_flag	    VARCHAR2(1);

    l_wo_asset_activity_err     EXCEPTION;

    BEGIN
	l_mo_err_flag:= '';
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within WO Check Attributes . . . '); END IF;


--  organization_id

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating organization_id . . . '); END IF;

  declare
    l_disable_date date;
  begin
      select 1
      into g_dummy
      from mtl_parameters mp
     where mp.organization_id = p_eam_wo_rec.organization_id;

    select nvl(hou.date_to,sysdate+1)
      into l_disable_date
      from hr_organization_units hou
      where organization_id =  p_eam_wo_rec.organization_id;

    if(l_disable_date < sysdate) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception

    when fnd_api.g_exc_unexpected_error then
      l_token_tbl(1).token_name  := 'Organization Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.organization_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ORGANIZATION_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    when no_data_found then

      l_token_tbl(1).token_name  := 'Organization Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.organization_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ORGANIZATION_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;



  end;

   /* PJM MOAC Changes */
   fnd_profile.put('MFG_ORGANIZATION_ID', p_eam_wo_rec.organization_id);


--  organization_id (EAM enabled)

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating organization_id (EAM enabled) . . . '); END IF;

--Only check EAM enabled for CMRO, part of bug fix 9313320
 IF p_eam_wo_rec.maintenance_object_source = 2 then

    begin
      select 1
      into g_dummy
      from mtl_parameters mp
      where mp.eam_enabled_flag = 'Y'
      and mp.organization_id = p_eam_wo_rec.organization_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception

    when no_data_found then
      l_token_tbl(1).token_name  := 'Organization Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.organization_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ORG_EAM_ENABLED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

 ELSE  -- For EAM work orders, if mtl org is EAM enabled, then it must be the same as the maintenance org
  begin
      select 1
      into g_dummy
      from wip_eam_parameters wep, mtl_parameters mp
     where wep.organization_id = mp.organization_id
       and mp.eam_enabled_flag = 'Y'
       and wep.organization_id = p_eam_wo_rec.organization_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Organization Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.organization_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ORG_EAM_ENABLED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

END IF;
--  maintenance_object_type

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating maintenance_object_type . . . '); END IF;

  begin

   if (p_eam_wo_rec.maintenance_object_type is not null) then

         select 1
           into g_dummy
           from mfg_lookups
          where lookup_type = g_obj_type
            and lookup_code = p_eam_wo_rec.maintenance_object_type;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

    end if;

    exception
      when no_data_found then
        l_token_tbl(1).token_name  := 'Maintenance Object Type';
        l_token_tbl(1).token_value :=  p_eam_wo_rec.maintenance_object_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name       => 'EAM_WO_MAINT_OBJECT_TYPE'
       , p_token_tbl          => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    end;


-- object_source_id

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating maintenance_object_id . . . '); END IF;

  begin

   if (p_eam_wo_rec.maintenance_object_type is not null) then

     if (p_eam_wo_rec.maintenance_object_type = 3 and p_eam_wo_rec.maintenance_object_source = 1) then

        IF  p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
            OR (p_eam_wo_rec.transaction_type <> EAM_PROCESS_WO_PVT.G_OPR_CREATE
                AND p_eam_wo_rec.maintenance_object_id <> p_old_eam_wo_rec.maintenance_object_id) THEN
            -- Code for creation
            select 1 into g_dummy
            from csi_item_instances cii, mtl_parameters mp
            where cii.last_vld_organization_id = mp.organization_id
            and mp.maint_organization_id = p_eam_wo_rec.organization_id
            and cii.instance_id = p_eam_wo_rec.maintenance_object_id;
        END IF;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

     elsif (p_eam_wo_rec.maintenance_object_type = 2) then
	  if (p_eam_wo_rec.maintenance_object_source = 1) then
         select 1
           into g_dummy
           from mtl_system_items msi, mtl_parameters mp
          where msi.organization_id = mp.organization_id
          and mp.maint_organization_id = p_eam_wo_rec.organization_id
          and inventory_item_id = p_eam_wo_rec.maintenance_object_id
          and rownum = 1;
      elsif (p_eam_wo_rec.maintenance_object_source = 2) then
      	  select 1
           into g_dummy
           from mtl_system_items
          where organization_id = p_eam_wo_rec.organization_id
            and inventory_item_id = p_eam_wo_rec.maintenance_object_id;
      end if;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

    end if;

    end if;

    exception
      when others then
        l_token_tbl(1).token_name  := 'Maintenance Object Id';
        l_token_tbl(1).token_value :=  p_eam_wo_rec.maintenance_object_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name       => 'EAM_WO_MAINT_OBJECT_ID'
       , p_token_tbl          => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    end;



--  maintenance object
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating maintenance object . . . '); END IF;

  begin

        if (p_eam_wo_rec.asset_group_id is not null) and (p_eam_wo_rec.rebuild_item_id is not null) then

          raise fnd_api.g_exc_unexpected_error;

        end if;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Asset Group';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.asset_group_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_AG_RB_DUPLICATE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  asset_group_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating asset_group_id . . . '); END IF;

  begin

    if (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE and p_eam_wo_rec.asset_group_id is not null) then

      if(p_eam_wo_rec.asset_number is null)
      then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      select 1
        into g_dummy
        from mtl_system_items msi, csi_item_instances cii, mtl_parameters mp
        where cii.inventory_item_id = p_eam_wo_rec.asset_group_id
        and cii.inventory_item_id = msi.inventory_item_id
        and cii.last_vld_organization_id = mp.organization_id
        and msi.organization_id = mp.organization_id
        and mp.maint_organization_id = p_eam_wo_rec.organization_id
	and cii.serial_number = p_eam_wo_rec.asset_number
        and msi.eam_item_type = 1
	and ROWNUM =1 ;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'Asset Group';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.asset_group_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ASSET_GROUP'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  asset_number
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating asset_number . . . '); END IF;

  begin

    if (p_eam_wo_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE,EAM_PROCESS_WO_PVT.G_OPR_UPDATE) and p_eam_wo_rec.asset_number is not null) then

/* In update mode do not check the current maintenance organization*/
       select 1
       into g_dummy
       from csi_item_instances cii
       where cii.inventory_item_id = p_eam_wo_rec.asset_group_id
       and cii.serial_number = p_eam_wo_rec.asset_number
       and nvl(cii.maintainable_flag, 'Y') = 'Y'
       and nvl(cii.active_start_date, sysdate-1) <= sysdate
       and nvl(cii.active_end_date, sysdate+1) >= sysdate ;

    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Asset Number';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.asset_number;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ASSET_NUMBER'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;



--  eam_linear_location_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating eam_linear_location_id . . . '); END IF;

  begin

    if (p_eam_wo_rec.transaction_type in (EAM_PROCESS_WO_PVT.G_OPR_CREATE,
                                          EAM_PROCESS_WO_PVT.G_OPR_UPDATE)
    and p_eam_wo_rec.eam_linear_location_id is not null) then

      select 1
        into g_dummy
        from eam_linear_locations
       where eam_linear_id = p_eam_wo_rec.eam_linear_location_id;

    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'LIN_LOC';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.eam_linear_location_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_LINEAR_LOCATION'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  rebuild_item_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating rebuild_item_id . . . '); END IF;

  begin

    if (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE and p_eam_wo_rec.rebuild_item_id is not null) then

      IF p_eam_wo_rec.maintenance_object_source = 2 then -- for fix 9313320 do not check maint org for CMRO

       select 1
        into g_dummy
        from mtl_system_items msi, mtl_parameters mp
        where msi.inventory_item_id = p_eam_wo_rec.rebuild_item_id
        and msi.organization_id = mp.organization_id
      --  and mp.maint_organization_id = p_eam_wo_rec.organization_id
        and msi.eam_item_type = 3
        and rownum = 1;

      else
      select 1
        into g_dummy
        from mtl_system_items msi, mtl_parameters mp
        where msi.inventory_item_id = p_eam_wo_rec.rebuild_item_id
        and msi.organization_id = mp.organization_id
        and mp.maint_organization_id = p_eam_wo_rec.organization_id
        and msi.eam_item_type = 3
        and rownum = 1;
      end if;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Rebuild Item Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.rebuild_item_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_REBUILD_ITEM_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  rebuild_serial_number
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating rebuild_serial_number . . . '); END IF;

  begin
    if (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

      if(p_eam_wo_rec.rebuild_item_id is null and
         p_eam_wo_rec.rebuild_serial_number is not null) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      if(p_eam_wo_rec.rebuild_item_id is not null and
         p_eam_wo_rec.rebuild_serial_number is not null) then

        select 1
        into g_dummy
        from csi_item_instances cii, mtl_parameters mp
        where cii.inventory_item_id = p_eam_wo_rec.rebuild_item_id
        and cii.last_vld_organization_id = mp.organization_id
        and mp.maint_organization_id = p_eam_wo_rec.organization_id
        and cii.serial_number = p_eam_wo_rec.rebuild_serial_number
        and nvl(cii.maintainable_flag, 'Y') = 'Y'
        and nvl(cii.active_start_date, sysdate-1) <= sysdate
        and nvl(cii.active_end_date, sysdate+1) >= sysdate;
        end if;

    /* Since serial numbers can be dynamically generated at SO issue and the
       condition was actually commented out, we dont have to perform this query
       at all*/

    end if;



     /* Validation added so that rebuild serial number is not
	     updateable if the WO is in status Released   */
    /*****  Enahancement No. : 2943473   ******/

       IF  (  p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
              and p_eam_wo_rec.rebuild_item_id is not null
              and p_eam_wo_rec.rebuild_serial_number is not null
              and nvl(p_old_eam_wo_rec.rebuild_serial_number,'null_old_serial_number') <>
                            nvl(p_eam_wo_rec.rebuild_serial_number,'null_old_serial_number')  )
       THEN

           IF ( p_eam_wo_rec.status_type = WIP_CONSTANTS.RELEASED
                  and p_old_eam_wo_rec.status_type = WIP_CONSTANTS.RELEASED )
           THEN
                 EAM_WORKORDER_UTIL_PKG.CK_MATERIAL_ALLOC_ON_HOLD(X_Org_Id => p_eam_wo_rec.organization_id,
                             X_Wip_Id => p_eam_wo_rec.wip_entity_id,
                             X_Rep_Id => -1,
                             X_Line_Id => -1,
                             X_Ent_Type=> 6,
			     X_Return_Status=>l_trans_exist);

	         IF(l_trans_exist='F') THEN
		    raise fnd_api.g_exc_unexpected_error;
		 END IF;
           END IF;
       END IF;



	 x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'Rebuild Serial Number';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.rebuild_serial_Number;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_REBUILD_SERIAL_NUMBER'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

-- end if;

-- Serial rebuild number not instantiated status =1
-- When a work order created on non instantiated rebuild serial number is released ,its must have an parent work order
-- 3659469

-- Serial rebuild number is required while releasing the work order if Rebuild number is serial controlled
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating if rebuild_serial_number is mandatory . . . '); END IF;
	BEGIN
             IF p_eam_wo_rec.status_type = 3
		   and p_eam_wo_rec.rebuild_item_id IS NOT NULL
		   and p_eam_wo_rec.rebuild_serial_number IS NULL
                   and p_eam_wo_rec.maintenance_object_source = 1 THEN -- SKIP FOR CMRO

			   select serial_number_control_code
				  into g_dummy
				  from mtl_system_items msi, mtl_parameters mp
				  where msi.inventory_item_id = p_eam_wo_rec.rebuild_item_id
				  and msi.organization_id = mp.organization_id
				  and mp.maint_organization_id = p_eam_wo_rec.organization_id and rownum = 1;

				if g_dummy <> 1 then
						raise fnd_api.g_exc_unexpected_error;
				end if ;

	END IF;

	 x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'Work_Order_Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_REBUILD_SER_REQD'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

end ;

--  parent_wip_entity_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating parent_wip_entity_id . . . '); END IF;

  begin
/* Following validation ensures that only WO of parents of serialized
    rebuildables can become parent work orders of rebuild WO and any
	WO on asset and rebuildables can become Parent WO for non-serialized rebuilds */

    l_rebuild_status := 0;
/*Currently parent_wip_entity can only be specified for a rebuildable work order */
    if p_eam_wo_rec.parent_wip_entity_id is not null then
     IF p_eam_wo_rec.manual_rebuild_flag='Y' THEN /* Added if condition for bug no 3336489 */

     IF ( p_eam_wo_rec.maintenance_object_type = 3 and p_eam_wo_rec.maintenance_object_source = 1)
      THEN

      IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating parent_wip_entity_id . rebuild status=' || l_rebuild_status); END IF;

          SELECT 1
          INTO g_dummy
          FROM mtl_object_genealogy mog, mtl_serial_numbers msn, wip_discrete_jobs wdj,
               mtl_serial_numbers msn1, csi_item_instances cii, mtl_parameters mp, csi_item_instances cii1
          WHERE p_eam_wo_rec.rebuild_item_id is not null
            and cii.instance_id = p_eam_wo_rec.maintenance_object_id
            and cii.last_vld_organization_id = mp.organization_id
            and mp.maint_organization_id = p_eam_wo_rec.organization_id
            and nvl(cii.network_asset_flag,'N') = 'N'
            and msn.current_organization_id = cii.last_vld_organization_id
            and msn.serial_number = cii.serial_number
            and msn.inventory_item_id = cii.inventory_item_id
            and mog.object_id = msn.gen_object_id
            and mog.parent_object_id = msn1.gen_object_id
	    and msn1.current_organization_id = mp.organization_id
            and cii1.serial_number = msn1.serial_number
            and cii1.inventory_item_id = msn1.inventory_item_id
            and cii1.last_vld_organization_id = msn1.current_organization_id
            and cii1.instance_id = wdj.maintenance_object_id
	    and wdj.maintenance_object_type=3
    	    and wdj.status_type not in (5,12,14)
	    and wdj.wip_entity_id = p_eam_wo_rec.parent_wip_entity_id
	    and wdj.organization_id = p_eam_wo_rec.organization_id
            and mog.genealogy_type = 5
            and nvl(mog.start_date_active,sysdate) <= sysdate
	    and nvl(mog.end_date_active,sysdate+1) > sysdate ;

      ELSE
            SELECT 1 INTO
                  g_dummy
		    FROM wip_discrete_jobs
		    WHERE
              p_eam_wo_rec.rebuild_item_id is not null
              and organization_id = p_eam_wo_rec.organization_id
              and wip_entity_id = p_eam_wo_rec.parent_wip_entity_id
              and status_type not in (5,12,14);
      END IF;
     END IF;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'Parent Wip Entity Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.parent_wip_entity_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_PARENT_WIP_ENTITY_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


  /* While updating parent_wip_entity_id check for any transactions posted on the work order */

   begin

      IF (   p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
              AND p_old_eam_wo_rec.parent_wip_entity_id <> p_eam_wo_rec.parent_wip_entity_id )
      THEN
           EAM_WORKORDER_UTIL_PKG.CK_MATERIAL_ALLOC_ON_HOLD(X_Org_Id => p_eam_wo_rec.organization_id,
                             X_Wip_Id => p_eam_wo_rec.wip_entity_id,
                             X_Rep_Id => -1,
                             X_Line_Id => -1,
                             X_Ent_Type=> 6,
			     X_Return_Status=>l_trans_exist);

	         IF(l_trans_exist='F') THEN
		    raise fnd_api.g_exc_unexpected_error;
		 END IF;
       END IF;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

   exception
      when others then

        l_token_tbl(1).token_name  := 'Wip Entity Id';
        l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_id;

        l_out_mesg_token_tbl  := l_mesg_token_tbl;
        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_WO_TRANSACTIONS_EXIST'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
        );
        l_mesg_token_tbl      := l_out_mesg_token_tbl;

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_mesg_token_tbl := l_mesg_token_tbl ;
        return;

   end;




--  job_name
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating wip_entity_name . . . '); END IF;

  declare
    l_count NUMBER;
  begin

    if (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

      select count(*)
        into l_count
        from wip_entities
       where wip_entity_name = p_eam_wo_rec.wip_entity_name
         and organization_id = p_eam_wo_rec.organization_id;

      if(l_count > 0) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Wip Entity Name';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_WIP_ENTITY_NAME'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  job_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating wip_entity_id . . . '); END IF;

  declare
    l_count NUMBER;
  begin

    if (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

      select count(*)
        into l_count
        from wip_entities
       where wip_entity_id = p_eam_wo_rec.wip_entity_id;

      if(l_count > 0) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Wip Entity Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_WIP_ENTITY_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  firm_planned_flag
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating firm_planned_flag . . . '); END IF;

 begin

    if p_eam_wo_rec.firm_planned_flag not in (wip_constants.yes, wip_constants.no) then

        raise fnd_api.g_exc_unexpected_error;

    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Firm Planned Flag';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.firm_planned_flag;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_FIRM_PLANNED_FLAG'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;



--  issue_zero_cost_flag
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating wip_entity_name . . . '); END IF;

  declare
    l_count NUMBER;
  begin

    if upper(p_eam_wo_rec.issue_zero_cost_flag) not in ('Y','N') then

        raise fnd_api.g_exc_unexpected_error;

    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'ISSUE_ZERO_FLAG';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.issue_zero_cost_flag;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ISSUE_ZERO_COST_FLAG'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;



--  schedule_group_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating schedule_group_id . . . '); END IF;
  begin

    if p_eam_wo_rec.schedule_group_id is not null then

      select 1
        into g_dummy
        from wip_schedule_groups_val_v
       where schedule_group_id = p_eam_wo_rec.schedule_group_id
         and organization_id = p_eam_wo_rec.organization_id;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Schedule Group Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.schedule_group_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_SCHEDULE_GROUP'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('p_eam_wo_rec.status_type ' || p_eam_wo_rec.status_type); END IF;
--attribute change not allowed for comp_no_chrg,closed,pending-close,failed-close and cancelled
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating attribute change for complete_no_chrg,cancelled,closed,pending-cl,failed-close statuses');END IF;
--start of fix for 3389850

begin
   IF ( p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE )
      AND (p_eam_wo_rec.status_type IN (5,7,12,14,15))    --if status is complete-no-chrg,cancelled,closed,pending-close and failed-close
      AND (p_eam_wo_rec.status_type=p_old_eam_wo_rec.status_type) --status is same
      AND (  p_eam_wo_rec.description<>p_old_eam_wo_rec.description
            OR p_eam_wo_rec.asset_number<>p_old_eam_wo_rec.asset_number
	    OR p_eam_wo_rec.asset_group_id<>p_old_eam_wo_rec.asset_group_id
	    OR p_eam_wo_rec.rebuild_item_id<>p_old_eam_wo_rec.rebuild_item_id
	    OR p_eam_wo_rec.rebuild_serial_number<>p_old_eam_wo_rec.rebuild_serial_number
	    OR p_eam_wo_rec.maintenance_object_id<>p_old_eam_wo_rec.maintenance_object_id
            OR p_eam_wo_rec.maintenance_object_type<>p_old_eam_wo_rec.maintenance_object_type
            OR p_eam_wo_rec.maintenance_object_source<>p_old_eam_wo_rec.maintenance_object_source
            OR p_eam_wo_rec.eam_linear_location_id<>p_old_eam_wo_rec.eam_linear_location_id
            OR p_eam_wo_rec.notification_required<>p_old_eam_wo_rec.notification_required
	    OR p_eam_wo_rec.class_code<>p_old_eam_wo_rec.class_code
	    OR p_eam_wo_rec.asset_activity_id<>p_old_eam_wo_rec.asset_activity_id
	    OR p_eam_wo_rec.activity_type<>p_old_eam_wo_rec.activity_type
	    OR p_eam_wo_rec.activity_source<>p_old_eam_wo_rec.activity_source
	    OR p_eam_wo_rec.activity_cause<>p_old_eam_wo_rec.activity_cause
	    OR p_eam_wo_rec.work_order_type<>p_old_eam_wo_rec.work_order_type
	    OR p_eam_wo_rec.status_type<>p_old_eam_wo_rec.status_type
   	    OR p_eam_wo_rec.job_quantity<>p_old_eam_wo_rec.job_quantity
	    OR p_eam_wo_rec.date_released<>p_old_eam_wo_rec.date_released
	    OR p_eam_wo_rec.owning_department<>p_old_eam_wo_rec.owning_department
	    OR p_eam_wo_rec.priority<>p_old_eam_wo_rec.priority
	    OR p_eam_wo_rec.requested_start_date<>p_old_eam_wo_rec.requested_start_date
	    OR p_eam_wo_rec.due_date<>p_old_eam_wo_rec.due_date
	    OR p_eam_wo_rec.shutdown_type<>p_old_eam_wo_rec.shutdown_type
	    OR p_eam_wo_rec.firm_planned_flag<>p_old_eam_wo_rec.firm_planned_flag
	    OR p_eam_wo_rec.tagout_required<>p_old_eam_wo_rec.tagout_required
	    OR p_eam_wo_rec.plan_maintenance<>p_old_eam_wo_rec.plan_maintenance
	    OR p_eam_wo_rec.project_id<>p_old_eam_wo_rec.project_id
	    OR p_eam_wo_rec.task_id<>p_old_eam_wo_rec.task_id
	    OR p_eam_wo_rec.end_item_unit_number<>p_old_eam_wo_rec.end_item_unit_number
	    OR p_eam_wo_rec.schedule_group_id<>p_old_eam_wo_rec.schedule_group_id
	    OR p_eam_wo_rec.bom_revision_date<>p_old_eam_wo_rec.bom_revision_date
	    OR p_eam_wo_rec.routing_revision_date<>p_old_eam_wo_rec.routing_revision_date
	    OR p_eam_wo_rec.alternate_bom_designator<>p_old_eam_wo_rec.alternate_bom_designator
	    OR p_eam_wo_rec.alternate_routing_designator<>p_old_eam_wo_rec.alternate_routing_designator
	    OR p_eam_wo_rec.bom_revision<>p_old_eam_wo_rec.bom_revision
	    OR p_eam_wo_rec.routing_revision<>p_old_eam_wo_rec.routing_revision
	    OR p_eam_wo_rec.parent_wip_entity_id<>p_old_eam_wo_rec.parent_wip_entity_id
	    OR p_eam_wo_rec.manual_rebuild_flag<>p_old_eam_wo_rec.manual_rebuild_flag
	    OR p_eam_wo_rec.pm_schedule_id<>p_old_eam_wo_rec.pm_schedule_id
	    OR p_eam_wo_rec.wip_supply_type<>p_old_eam_wo_rec.wip_supply_type
	    OR p_eam_wo_rec.material_account<>p_old_eam_wo_rec.material_account
	    OR p_eam_wo_rec.material_overhead_account<>p_old_eam_wo_rec.material_overhead_account
	    OR p_eam_wo_rec.resource_account<>p_old_eam_wo_rec.resource_account
	    OR p_eam_wo_rec.outside_processing_account<>p_old_eam_wo_rec.outside_processing_account
	    OR p_eam_wo_rec.material_variance_account<>p_old_eam_wo_rec.material_variance_account
	    OR p_eam_wo_rec.resource_variance_account<>p_old_eam_wo_rec.resource_variance_account
	    OR p_eam_wo_rec.outside_proc_variance_account<>p_old_eam_wo_rec.outside_proc_variance_account
	    OR p_eam_wo_rec.std_cost_adjustment_account<>p_old_eam_wo_rec.std_cost_adjustment_account
	    OR p_eam_wo_rec.overhead_account<>p_old_eam_wo_rec.overhead_account
	    OR p_eam_wo_rec.overhead_variance_account<>p_old_eam_wo_rec.overhead_variance_account
	    OR p_eam_wo_rec.scheduled_start_date<>p_old_eam_wo_rec.scheduled_start_date
	    OR p_eam_wo_rec.scheduled_completion_date<>p_old_eam_wo_rec.scheduled_completion_date
    	    OR p_eam_wo_rec.common_bom_sequence_id<>p_old_eam_wo_rec.common_bom_sequence_id
	    OR p_eam_wo_rec.common_routing_sequence_id<>p_old_eam_wo_rec.common_routing_sequence_id
	    OR p_eam_wo_rec.po_creation_time<>p_old_eam_wo_rec.po_creation_time
	    OR p_eam_wo_rec.gen_object_id<>p_old_eam_wo_rec.gen_object_id
	    OR p_eam_wo_rec.attribute_category<>p_old_eam_wo_rec.attribute_category
	    OR p_eam_wo_rec.attribute1<>p_old_eam_wo_rec.attribute1
	    OR p_eam_wo_rec.attribute2<>p_old_eam_wo_rec.attribute2
	    OR p_eam_wo_rec.attribute3<>p_old_eam_wo_rec.attribute3
	    OR p_eam_wo_rec.attribute4<>p_old_eam_wo_rec.attribute4
	    OR p_eam_wo_rec.attribute5<>p_old_eam_wo_rec.attribute5
	    OR p_eam_wo_rec.attribute6<>p_old_eam_wo_rec.attribute6
	    OR p_eam_wo_rec.attribute7<>p_old_eam_wo_rec.attribute7
	    OR p_eam_wo_rec.attribute8<>p_old_eam_wo_rec.attribute8
	    OR p_eam_wo_rec.attribute9<>p_old_eam_wo_rec.attribute9
	    OR p_eam_wo_rec.attribute10<>p_old_eam_wo_rec.attribute10
	    OR p_eam_wo_rec.attribute11<>p_old_eam_wo_rec.attribute11
	    OR p_eam_wo_rec.attribute12<>p_old_eam_wo_rec.attribute12
	    OR p_eam_wo_rec.attribute13<>p_old_eam_wo_rec.attribute13
	    OR p_eam_wo_rec.attribute14<>p_old_eam_wo_rec.attribute14
	    OR p_eam_wo_rec.attribute15<>p_old_eam_wo_rec.attribute15
	    OR p_eam_wo_rec.material_issue_by_mo<>p_old_eam_wo_rec.material_issue_by_mo
	    OR p_eam_wo_rec.issue_zero_cost_flag<>p_old_eam_wo_rec.issue_zero_cost_flag
	    ) THEN
        raise fnd_api.g_exc_unexpected_error;
   END IF;
exception
  when fnd_api.g_exc_unexpected_error then
      l_token_tbl(1).token_name  := 'STATUS_TYPE';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.status_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_CH_ATTR_DISALLOWED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;
end;


--end of fix for 3389850

--  status_type
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating status_type . . . '); END IF;

  declare

    l_count             number;
    l_parent_status     number;

    parent_not_released exception;
    child_released      exception;
    ch_rel_par_canc     exception;

  begin

    if (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE and
        p_eam_wo_rec.status_type not in (wip_constants.unreleased, wip_constants.released, wip_constants.hold, wip_constants.draft)) then

       raise fnd_api.g_exc_unexpected_error;

    elsif (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE) then
      if(p_eam_wo_rec.status_type not in (wip_constants.unreleased, wip_constants.released, wip_constants.comp_chrg,wip_constants.comp_nochrg, wip_constants.closed,
                                      wip_constants.hold, wip_constants.cancelled, wip_constants.pend_sched, wip_constants.draft)
          OR ( p_eam_wo_rec.status_type in (wip_constants.draft) and p_old_eam_wo_rec.status_type not in (wip_constants.draft))
		  /* Added the check so that status will not be updated to status Draft */
--fix for 3389850.cannot change status from complete_no_charges to any status other than complete,closed.cannot change to complete_no_charges from status other than
--complete
          OR  (p_old_eam_wo_rec.status_type=wip_constants.comp_nochrg AND  p_eam_wo_rec.status_type NOT IN (wip_constants.comp_chrg,wip_constants.closed,wip_constants.comp_nochrg) )
/* Bug 3431204 - Should be able to link a Complete No charges WO to another
   Complete NO Charges WO */
OR   (p_eam_wo_rec.status_type=wip_constants.comp_nochrg
           AND p_old_eam_wo_rec.status_type NOT IN
	        (wip_constants.comp_chrg, wip_constants.comp_nochrg,wip_constants.closed,wip_constants.fail_close))) then

        raise fnd_api.g_exc_unexpected_error;

      end if;

    end if;


    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception

     when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Status type';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.status_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_STATUS_TYPE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  job_quantity
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating job_quantity . . . '); END IF;

  begin

      if(p_eam_wo_rec.job_quantity <> 1) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Job Quantity';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.job_quantity;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_JOB_QUANTITY'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  primary_item_id (asset activity)
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating asset_activity_id . . . '); END IF;

  declare
    l_eam_op_tbl EAM_PROCESS_WO_PUB.EAM_OP_TBL_TYPE;
    l_mat_req_exists number;
    l_serial_number_control  NUMBER := 0;
    l_count                  NUMBER := 0;

    ACTIVITY_WO_EXISTS EXCEPTION;
  begin
 -- # 3436679   code added to prevent the defaulting of the asset activity if user removes it while updating work order
    if p_eam_wo_rec.asset_activity_id is not null and p_eam_wo_rec.asset_activity_id <> FND_API.G_MISS_NUM then

      select 1
      into   g_dummy
      from mtl_system_items
      where organization_id = p_eam_wo_rec.organization_id
      and   inventory_item_id = p_eam_wo_rec.asset_activity_id
      and   eam_item_type = 2;

      -- asset activity should not allowed to be updated if the wo has any ops or mat reqs.
      select count(*) into l_mat_req_exists from wip_requirement_operations
        where wip_entity_id = p_eam_wo_rec.wip_entity_id
        and organization_id = p_eam_wo_rec.organization_id;

      if nvl(p_eam_wo_rec.asset_activity_id,-99999) <> nvl(p_old_eam_wo_rec.asset_activity_id,-99999)
      and p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
      and (EAM_OP_UTILITY_PVT.NUM_OF_ROW(
            p_eam_op_tbl      => l_eam_op_tbl
           ,p_wip_entity_id   => p_eam_wo_rec.wip_entity_id
           ,p_organization_id => p_eam_wo_rec.organization_id) = false
           or l_mat_req_exists <> 0) then
        raise fnd_api.g_exc_unexpected_error;
      end if;


    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_CANT_UPDATE_ACTIVITY'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    when ACTIVITY_WO_EXISTS then

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_ACTIVITY_WO_EXISTS'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    when others then

      l_token_tbl(1).token_name  := 'Asset Activity Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.asset_activity_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ASSET_ACTIVITY'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;



--  asset activity association

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating asset_activity_association . . . '); END IF;

  declare
    l_start_date DATE;
    l_end_date DATE;

  begin
 -- # 3436679   code added to prevent the defaulting of the asset activity if user removes it while updating work order
    if (p_eam_wo_rec.asset_activity_id is not null and p_eam_wo_rec.asset_activity_id <> FND_API.G_MISS_NUM and p_eam_wo_rec.maintenance_object_source = 1) then

      if (p_eam_wo_rec.maintenance_object_type = 3) then

        select meaa.start_date_active, meaa.end_date_active
          into l_start_date, l_end_date
          from mtl_eam_asset_activities meaa, mtl_system_items msi
         where meaa.asset_activity_id = p_eam_wo_rec.asset_activity_id
           and meaa.maintenance_object_type = 3
           and nvl(meaa.tmpl_flag, 'N') = 'N'
           and meaa.maintenance_object_id = p_eam_wo_rec.maintenance_object_id
           and msi.inventory_item_id = p_eam_wo_rec.asset_activity_id
           and msi.organization_id = p_eam_wo_rec.organization_id;

      else

      if (p_eam_wo_rec.maintenance_object_type = 2) then

               select min(meaa.start_date_active), min(meaa.end_date_active)
              into l_start_date, l_end_date
              from mtl_eam_asset_activities meaa,mtl_system_items msi
         where meaa.asset_activity_id = p_eam_wo_rec.asset_activity_id
           and meaa.maintenance_object_type = 2
           and meaa.maintenance_object_id = p_eam_wo_rec.maintenance_object_id
           and msi.organization_id = p_eam_wo_rec.organization_id
           and msi.inventory_item_id = p_eam_wo_rec.asset_activity_id
           and nvl(meaa.tmpl_flag, 'N') = 'N';
    end if;

      end if;

      if(l_start_date is not null and
         l_start_date > nvl(p_eam_wo_rec.requested_start_date, p_eam_wo_rec.due_date)) then
        raise l_wo_asset_activity_err;
      end if;

      if(l_end_date is not null and
         l_end_date < nvl(p_eam_wo_rec.due_date, p_eam_wo_rec.requested_start_date)) then
        raise l_wo_asset_activity_err;
      end if;

    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    WHEN l_wo_asset_activity_err THEN

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ASSET_ACTIVITY_DATES'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    when others then

      l_token_tbl(1).token_name  := 'Asset Activity Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.asset_activity_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ASSET_ACTIVITY_ASSOC'
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

      if(p_eam_wo_rec.wip_supply_type is not null and p_eam_wo_rec.wip_supply_type not in (wip_constants.push, wip_constants.bulk, wip_constants.based_on_bom)) then
        --not a valid supply type

        raise fnd_api.g_exc_unexpected_error;

      end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Wip Supply Type';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_supply_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_WIP_SUPPLY_TYPE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  alternate_routing_designator
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating alternate_routing_designator . . . '); END IF;

  begin

  if p_eam_wo_rec.alternate_routing_designator is not null then

      select 1
        into g_dummy
        from bom_routing_alternates_v
       where assembly_item_id = p_eam_wo_rec.asset_activity_id
         and alternate_routing_designator = p_eam_wo_rec.alternate_routing_designator
         and organization_id = p_eam_wo_rec.organization_id
         and routing_type = 1;

  end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Alternate Routing Designator';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.alternate_routing_designator;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ALTERNATE_ROUTING'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  alternate_bom_designator
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating alternate_bom_designator . . . '); END IF;

  begin

  if p_eam_wo_rec.alternate_bom_designator is not null then

      select 1
        into g_dummy
        from bom_bill_alternates_v
       where assembly_item_id = p_eam_wo_rec.asset_activity_id
         and alternate_bom_designator = p_eam_wo_rec.alternate_bom_designator
         and organization_id = p_eam_wo_rec.organization_id
         and assembly_type = 1;

  end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Alternate BOM Designator';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.alternate_bom_designator;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ALTERNATE_BOM'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  project_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating project_id . . . '); END IF;

 declare

    l_min_date DATE;

  begin

    IF p_eam_wo_rec.scheduled_start_date >= sysdate THEN
       l_min_date := sysdate;
    ELSE
       l_min_date := p_eam_wo_rec.scheduled_start_date;
    END IF;

     IF ((p_eam_wo_rec.project_id IS NOT NULL AND p_old_eam_wo_rec.project_id is null) OR
         (p_eam_wo_rec.project_id <> p_old_eam_wo_rec.project_id) OR
		 (p_eam_wo_rec.status_type = 3 and p_old_eam_wo_rec.status_type in (17,1,6)
		  and p_eam_wo_rec.project_id is not null
		 ))
     THEN
		       SELECT distinct mpv.project_id --this query will return multiple rows if the project has tasks
			 INTO g_dummy
			 FROM mtl_project_v mpv, pjm_project_parameters_v ppp, mtl_parameters mp
			WHERE mpv.project_id = ppp.project_id
			  AND mpv.project_id = p_eam_wo_rec.project_id
			  AND ppp.organization_id = p_eam_wo_rec.organization_id
			  AND ppp.organization_id = mp.organization_id
			  AND nvl(mp.project_reference_enabled, 2) = wip_constants.yes
                          /* Commented for bug#5346213 Start
                          AND (mpv.completion_date IS NULL OR mpv.completion_date >= l_min_date)
                          AND (ppp.end_date_active IS NULL OR ppp.end_date_active >= l_min_date);
                          Commented for bug#5346213 End */
                          /* Added for bug#5346213 Start */
                          AND (mpv.completion_date IS NULL OR trunc(mpv.completion_date) >= trunc(l_min_date))
                          AND (ppp.end_date_active IS NULL OR trunc(ppp.end_date_active) >= trunc(l_min_date));
                          /* Added for bug#5346213 End */

     END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Project Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.project_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_PROJECT_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  task_id
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating task_id . . . '); END IF;

  declare

    l_min_date DATE;

  begin
       IF (p_eam_wo_rec.task_id IS NOT NULL) THEN
	      SELECT 1
		INTO g_dummy
		FROM pjm_tasks_v
	       WHERE project_id = p_eam_wo_rec.project_id
		 AND task_id = p_eam_wo_rec.task_id;

          IF p_eam_wo_rec.scheduled_start_date >= sysdate THEN
                l_min_date := sysdate;
	      ELSE
		        l_min_date := p_eam_wo_rec.scheduled_start_date;
		  END IF;

          /* IF p_eam_wo_rec.status_type = 3 and p_old_eam_wo_rec.status_type in (17,1,6) THEN Commented for bug#5346213 */
          /* Added for bug#5346213 Start */
          IF p_eam_wo_rec.status_type = 3 and ( p_old_eam_wo_rec.status_type in (17,1,6) OR p_old_eam_wo_rec.status_type IS NULL ) THEN
          /* Added for bug#5346213 End */
                      SELECT 1
                        INTO g_dummy
                        FROM pjm_tasks_v
                     WHERE project_id = p_eam_wo_rec.project_id
                         AND task_id = p_eam_wo_rec.task_id
                         /* AND (completion_date IS NULL OR completion_date >= l_min_date); Commented for bug#5346213 */
                         AND (completion_date IS NULL OR trunc(completion_date) >= trunc(l_min_date)); /* Added for bug#5346213 */

		  END IF;

       END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Task Id';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.task_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_TASK_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;



--  schedule_dates 0

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating PM Suggested dates  . . . '); END IF;

  begin

    if p_eam_wo_rec.pm_suggested_start_date is not null and
       p_eam_wo_rec.pm_suggested_end_date is not null then

       raise fnd_api.g_exc_unexpected_error;

    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Wip Entity Name';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_TOO_MANY_PM_DATE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  schedule_dates 1

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating due_date, requested_start_date . . . '); END IF;

  begin

    if p_eam_wo_rec.due_date is not null and
       p_eam_wo_rec.requested_start_date is not null then

       raise fnd_api.g_exc_unexpected_error;

    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Wip Entity Name';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_TOO_MANY_DATE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  schedule_dates 2

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating due_date, requested_start_date . . . '); END IF;

  begin

       if p_eam_wo_rec.due_date is null and
          p_eam_wo_rec.requested_start_date is null then

          raise fnd_api.g_exc_unexpected_error;

       end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Wip Entity Name';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_NEED_DATE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  schedule_dates 3
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating schedule_dates . . . '); END IF;

  declare
    l_rtg_count NUMBER;
    l_date_count NUMBER := 0;
  begin

    if p_eam_wo_rec.requested_start_date is not null then
      l_date_count := l_date_count + 1;
    end if;

    if p_eam_wo_rec.due_date is not null then
      l_date_count := l_date_count + 1;
    end if;

    if (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE and l_date_count = 0) then
      --all job creations must have at least one date
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if p_eam_wo_rec.requested_start_date is not null then

      select 1
        into g_dummy
        from bom_calendar_dates bcd, mtl_parameters mp
       where mp.organization_id = p_eam_wo_rec.organization_id
         and mp.calendar_code = bcd.calendar_code
         and mp.calendar_exception_set_id = bcd.exception_set_id
         and bcd.calendar_date = trunc(p_eam_wo_rec.requested_start_date);
    end if;

    if p_eam_wo_rec.due_date is not null then
      select 1
        into g_dummy
        from bom_calendar_dates bcd, mtl_parameters mp
       where mp.organization_id = p_eam_wo_rec.organization_id
         and mp.calendar_code = bcd.calendar_code
         and mp.calendar_exception_set_id = bcd.exception_set_id
         and bcd.calendar_date = trunc(p_eam_wo_rec.due_date);
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'Scheduled Start Date';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.scheduled_start_date;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_SCHEDULE_DATE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;
  --start of fix for 3396136
begin
  IF(p_eam_wo_rec.scheduled_start_date IS NOT NULL)
    AND (p_eam_wo_rec.scheduled_completion_date IS NOT NULL)
    AND (p_eam_wo_rec.scheduled_start_date > p_eam_wo_rec.scheduled_completion_date) THEN
       raise fnd_api.g_exc_unexpected_error;
  END IF;
exception
    when fnd_api.g_exc_unexpected_error then
       l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_SCHEDULE_DATE_MORE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;
end;
 --end of fix for 3396136


--  end_item_unit_number
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating end_item_unit_number . . . '); END IF;

  declare
    is_unit_effective_item boolean;
    l_bom_item_id NUMBER;
  begin

    -- Unit number is required for unit effective assemblies.
  if (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

    if(is_unit_effective_item and p_eam_wo_rec.end_item_unit_number is null) then
      fnd_message.set_name('PJM', 'UEFF-UNIT NUMBER REQUIRED');
    end if;

  end if;

    -- If the assembly item is unit effective, validate the actual
    -- unit number value. The unit number must exist in the same _master_
    -- organization as the item. (We already validate that the item
    -- is in the organization identified by the ORGANIZATION_ID column.)
    if(is_unit_effective_item and p_eam_wo_rec.end_item_unit_number is not null) then
      select 1
        into g_dummy
        from pjm_unit_numbers_lov_v pun,
             mtl_parameters mp
       where pun.unit_number = p_eam_wo_rec.end_item_unit_number
         and mp.organization_id = p_eam_wo_rec.organization_id
         and mp.master_organization_id = pun.master_organization_id;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when too_many_rows then
      null; -- the query returning multiple rows is ok
    when others then
--      fnd_message.set_name('PJM', 'UEFF-UNIT NUMBER INVALID') ;

      l_token_tbl(1).token_name  := 'Unit Number';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.end_item_unit_number;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_UNIT_NUMBER'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  class_code
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating class_code . . . '); END IF;

  declare
    l_disable_date date;
    WO_CANT_CH_WIPACCT exception;
  begin
    if (p_eam_wo_rec.class_code is null) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if p_eam_wo_rec.class_code is not null then

      select disable_date
        into l_disable_date
        from wip_accounting_classes
       where class_code = p_eam_wo_rec.class_code
         and class_type = wip_constants.eam
         and organization_id = p_eam_wo_rec.organization_id;

      if(l_disable_date is not null and
         l_disable_date < nvl(p_eam_wo_rec.due_date, p_eam_wo_rec.requested_start_date)) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

    end if;

    -- bug no 3905702
    if p_old_eam_wo_rec.class_code <> p_eam_wo_rec.class_code then

	     EAM_WORKORDER_UTIL_PKG.CK_MATERIAL_ALLOC_ON_HOLD(X_Org_Id => p_eam_wo_rec.organization_id,
				     X_Wip_Id => p_eam_wo_rec.wip_entity_id,
				     X_Rep_Id => -1,
				     X_Line_Id => -1,
				     X_Ent_Type=> 6,
				     X_Return_Status=>l_trans_exist);

	    IF(l_trans_exist='F') THEN
	       raise WO_CANT_CH_WIPACCT;
	    END IF;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception

    when WO_CANT_CH_WIPACCT then

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WIPACT_CANNOT_CH'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    when others then

      l_token_tbl(1).token_name  := 'Class Code';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.class_code;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_CLASS_CODE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  bom_revision
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating bom_revision . . . '); END IF;

  declare
    l_start_date DATE;
  begin

    l_start_date := greatest(p_eam_wo_rec.requested_start_date, sysdate);
/*
      wip_revisions.bom_revision(p_organization_id => p_eam_wo_rec.organization_id,
                                 p_item_id => p_eam_wo_rec.asset_activity_id,
                                 p_revision => p_eam_wo_rec.bom_revision,
                                 p_revision_date => p_eam_wo_rec.bom_revision_date,
                                 p_start_date => l_start_date);
*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'BOM Revision';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.bom_revision;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_BOM_REVISION'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;

      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  routing_revision
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating routing_revision . . . '); END IF;

  declare
    l_start_date DATE;
    l_count NUMBER;
  begin

    l_start_date := greatest(p_eam_wo_rec.requested_start_date, sysdate);

      select count(*)
        into l_count
        from bom_operational_routings
       where assembly_item_id = p_eam_wo_rec.asset_activity_id
         and organization_id = p_eam_wo_rec.organization_id
         and nvl(alternate_routing_designator, '@@') = nvl(p_eam_wo_rec.alternate_routing_designator, '@@');
/*
      if(l_count > 0) then

        wip_revisions.routing_revision(p_organization_id => p_eam_wo_rec.organization_id,
                                       p_item_id => p_eam_wo_rec.asset_activity_id,
                                       p_revision => p_eam_wo_rec.routing_revision,
                                       p_revision_date => p_eam_wo_rec.routing_revision_date,
                                       p_start_date => l_start_date);

      end if;
*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'Routing Revision';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.routing_revision;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ROUTING_REVISION'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  manual_rebuild_flag
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating manual_rebuild_flag . . . '); END IF;

  begin
    if (p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then
      if(p_eam_wo_rec.manual_rebuild_flag is not null and
         (p_eam_wo_rec.rebuild_item_id is null or
         p_eam_wo_rec.manual_rebuild_flag not in ('Y', 'N'))) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      if(p_eam_wo_rec.manual_rebuild_flag is null and
         p_eam_wo_rec.rebuild_item_id is not null) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Manual Rebuild Flag';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.manual_rebuild_flag;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_MANUAL_REBUILD_FLAG'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  owning_department
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating owing_department_id . . . '); END IF;

  declare
    l_job_date DATE;
    l_disable_date DATE;
  begin
    if p_eam_wo_rec.owning_department is not null then
      l_job_date := nvl(p_eam_wo_rec.due_date, nvl(p_eam_wo_rec.requested_start_date, p_eam_wo_rec.scheduled_completion_date));
      select disable_date
        into l_disable_date
        from bom_departments
       where department_id = p_eam_wo_rec.owning_department
         and organization_id = p_eam_wo_rec.organization_id;

      if(l_disable_date is not null and
         l_disable_date < l_job_date) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'Owning Department';
  --    l_token_tbl(1).token_value :=  p_eam_wo_rec.owning_department;

        SELECT bd.department_code into l_token_tbl(1).token_value
	 FROM  bom_departments bd
	 WHERE 	 bd.DEPARTMENT_ID = p_eam_wo_rec.owning_department
 	 AND     bd.organization_id   = p_eam_wo_rec.organization_id;


      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_OWNING_DEPARTMENT'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  notification_required
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating notification_required . . . '); END IF;

  begin
    if (p_eam_wo_rec.notification_required is not null and
       p_eam_wo_rec.notification_required not in ('Y', 'N')) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Notification Required';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.notification_required;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_NOTIFICATION_REQUIRED'
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
    if p_eam_wo_rec.shutdown_type is not null then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = g_shutdown_type
         and lookup_code = p_eam_wo_rec.shutdown_type
         and enabled_flag = 'Y';
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Shutdown Type';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.shutdown_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_SHUTDOWN_TYPE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  tagout_required
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating tagout_required . . . '); END IF;

  begin
    if (p_eam_wo_rec.tagout_required is not null and
       p_eam_wo_rec.tagout_required not in ('Y', 'N')) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Tagout Required';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.tagout_required;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_TAGOUT_REQUIRED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  plan_maintenance
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating plan_maintenance . . . '); END IF;

  begin
    if p_eam_wo_rec.plan_maintenance is not null and
       p_eam_wo_rec.plan_maintenance not in ('Y', 'N') then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then

      l_token_tbl(1).token_name  := 'Plan Maintenance';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.plan_maintenance;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_PLAN_MAINTENANCE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  work_order_type
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating work_order_type . . . '); END IF;

  begin
    if p_eam_wo_rec.work_order_type is not null then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = g_wo_type
         and lookup_code = p_eam_wo_rec.work_order_type
         and enabled_flag = 'Y';
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Work Order Type';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.work_order_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_WORK_ORDER_TYPE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  activity_type
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating activity_type . . . '); END IF;

  begin
    if p_eam_wo_rec.activity_type is not null then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = g_act_type
         and lookup_code = p_eam_wo_rec.activity_type
         and enabled_flag = 'Y';
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Activity Type';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.activity_type;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ACTIVITY_TYPE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  activity_cause
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating activity_cause . . . '); END IF;

  begin
    if p_eam_wo_rec.activity_cause is not null then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = g_act_cause
         and lookup_code = p_eam_wo_rec.activity_cause
         and enabled_flag = 'Y';
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Activity Cause';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.activity_cause;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ACTIVITY_CAUSE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;



--  activity_source
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating activity_source . . . '); END IF;

  begin
    if p_eam_wo_rec.activity_source is not null then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = g_act_source
         and lookup_code = p_eam_wo_rec.activity_source
         and enabled_flag = 'Y';
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when no_data_found then

      l_token_tbl(1).token_name  := 'Activity Source';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.activity_source;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ACTIVITY_SOURCE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  date_released
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating accounting_period . . . '); END IF;

    --bug#4425025 - need to validate period only when releasing the first time.
     IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Old Date_released is : '||nvl(to_char(p_old_eam_wo_rec.date_released),'NULL')); END IF;

  declare
    l_date_released_calc    DATE;
	l_min_open_period_date  DATE;
  begin

   if (p_eam_wo_rec.status_type     in  (WIP_CONSTANTS.HOLD,WIP_CONSTANTS.RELEASED) and
          nvl(p_old_eam_wo_rec.status_type,0) not in(WIP_CONSTANTS.RELEASED, WIP_CONSTANTS.HOLD) and
          p_old_eam_wo_rec.date_released is null) then

          IF (p_eam_wo_rec.scheduled_start_date < sysdate) THEN
		    select nvl(min(period_start_date),p_eam_wo_rec.scheduled_start_date)
	          into l_min_open_period_date
		      from org_acct_periods
		      where organization_id=p_eam_wo_rec.organization_id
		      and open_flag = 'Y'
			  and period_close_date is null;

                    l_date_released_calc := greatest (l_min_open_period_date,p_eam_wo_rec.scheduled_start_date);
          ELSE
  		    l_date_released_calc := sysdate;
	  END IF;

        --date_released will be defaulted just before change_status procedure call in EAMVWOPB.pls.
	--hence if date_released is NULL, get the defaulted value but do not stamp defaulted value in work order record
	-- as date_released should be populated only when there is no workflow/workflow is approved
	  IF(p_eam_wo_rec.status_type = WIP_CONSTANTS.RELEASED AND p_eam_wo_rec.date_released IS NOT NULL) THEN
	              l_date_released_calc :=  TRUNC(p_eam_wo_rec.date_released);
	  END IF;

          select 1
          into   g_dummy
          from org_acct_periods
          where organization_id = p_eam_wo_rec.organization_id
          and trunc(l_date_released_calc)
          between period_start_date and schedule_close_date
          and period_close_date is NULL;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

    end if;


    exception
      when no_data_found then
        l_token_tbl(1).token_name  := 'Date Released';
        l_token_tbl(1).token_value :=  trunc(l_date_released_calc);

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_NO_ACCT_PERIOD'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    end;


--  maintenance_object_source

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating maintenance_object_source . . . '); END IF;

  begin

   if (p_eam_wo_rec.maintenance_object_source is not null) then

         select 1
           into g_dummy
           from mfg_lookups
          where lookup_type = g_obj_source
            and lookup_code = p_eam_wo_rec.maintenance_object_source;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

    end if;

    exception
      when no_data_found then
        l_token_tbl(1).token_name  := 'Maintenance Object Source';
        l_token_tbl(1).token_value :=  p_eam_wo_rec.maintenance_object_source;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_MAINT_OBJECT_SOURCE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    end;


--  user_id

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating user_id . . . '); END IF;

  begin

   if (p_eam_wo_rec.user_id is not null) then

         select 1
           into g_dummy
           from fnd_user
          where user_id = p_eam_wo_rec.user_id;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

    end if;

    exception
      when no_data_found then
        l_token_tbl(1).token_name  := 'USER_ID';
        l_token_tbl(1).token_value :=  p_eam_wo_rec.user_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_USER'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    end;


--  responsibility_id

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating responsibility_id . . . '); END IF;

  begin

   if (p_eam_wo_rec.responsibility_id is not null) then

         select 1
           into g_dummy
           from fnd_responsibility
          where responsibility_id = p_eam_wo_rec.responsibility_id;

          x_return_status := FND_API.G_RET_STS_SUCCESS;

    end if;

    exception
      when no_data_found then
        l_token_tbl(1).token_name  := 'RESPONSIBILITY_ID';
        l_token_tbl(1).token_value :=  p_eam_wo_rec.responsibility_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_RESPONSIBILITY'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    end;

--  user_defined_status_id

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating user_defined_status_id . . . '); END IF;

  begin

   IF (p_eam_wo_rec.user_defined_status_id IS NOT NULL) AND
         (p_eam_wo_rec.user_defined_status_id <> p_old_eam_wo_rec.user_defined_status_id)THEN

         SELECT enabled_flag
           INTO l_enabled_flag
           FROM EAM_WO_STATUSES_B
          WHERE status_id = p_eam_wo_rec.user_defined_status_id;

          IF l_enabled_flag <> 'Y'  THEN
		RAISE fnd_api.g_exc_error;
	  END IF;

    END IF;

    exception
      when fnd_api.g_exc_error then
        l_token_tbl(1).token_name  := 'USER_DEFINED_STATUS_ID';
        l_token_tbl(1).token_value :=  p_eam_wo_rec.user_defined_status_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_DIS_USER_DEFINED_STATUS'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    end;

--  material_issue_by_mo

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating material_issue_by_mo flag . . . '); END IF;

  begin

    if (p_eam_wo_rec.material_issue_by_mo is null) then
      raise fnd_api.g_exc_unexpected_error;
    else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;



    if  p_eam_wo_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
      and p_eam_wo_rec.status_type not in (WIP_CONSTANTS.DRAFT,WIP_CONSTANTS.UNRELEASED)     /* Bug no 3349197 */
      and not(p_eam_wo_rec.status_type=WIP_CONSTANTS.RELEASED and (p_old_eam_wo_rec.status_type IN (WIP_CONSTANTS.DRAFT,WIP_CONSTANTS.UNRELEASED,WIP_CONSTANTS.CANCELLED)))    /*Bug No 3476156*/
      and p_eam_wo_rec.material_issue_by_mo <> p_old_eam_wo_rec.material_issue_by_mo then

      IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
	  	EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating material_issue_by_mo flag . .wip_entity_id' || p_eam_wo_rec.wip_entity_id);
	  	EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating material_issue_by_mo flag . .org_id' || p_eam_wo_rec.organization_id);
	  END IF;

      if ((p_eam_wo_rec.status_type = WIP_CONSTANTS.HOLD) OR (p_eam_wo_rec.status_type=WIP_CONSTANTS.RELEASED and p_old_eam_wo_rec.status_type=WIP_CONSTANTS.HOLD)) then   /*Bug no 3476156*/
	      -- If material allocation has been done then raise error
		EAM_WORKORDER_UTIL_PKG.CK_MATERIAL_ALLOC_ON_HOLD(X_Org_Id => p_eam_wo_rec.organization_id,
				     X_Wip_Id => p_eam_wo_rec.wip_entity_id,
				     X_Rep_Id => -1,
				     X_Line_Id => -1,
				     X_Ent_Type=> 6 ,
				     x_return_status =>x_return_status);

		if x_return_status<> FND_API.G_RET_STS_SUCCESS then
		  l_mo_err_flag := '2';
		  raise fnd_api.g_exc_error;
		end if;
      else
	      l_mo_err_flag := '1';
	      raise fnd_api.g_exc_error;
      end if;
   end if;
    exception
    when fnd_api.g_exc_error then
      l_out_mesg_token_tbl  := l_mesg_token_tbl;

      If l_mo_err_flag = '1' Then
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_WO_MTL_ISS_DISALLOWED'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
      Else
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name  => 'EAM_WO_MTL_ALRDY_ISSUED'
	       , p_token_tbl     => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
      End if;


      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    when others then

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_MTL_ISSUE_BY_MO'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

    end;

    -- Bug # 4709084 : FAILURE ANALYSIS : Check for failure_code_required..
    IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
       EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating failure_code_required . . . ');
    END IF;

    if (p_eam_wo_rec.failure_code_required is not null and p_eam_wo_rec.failure_code_required not in ('Y', 'N')) then
      l_token_tbl(1).token_name  := 'failure_code_required';
      l_token_tbl(1).token_value :=  p_eam_wo_rec.failure_code_required;
      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_FAILURE_CODE_REQUIRED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;
    else
       x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;

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
    * Parameters IN : Work Order column record
    * Parameters OUT NOCOPY: Mesg Token Table
    *                 Return_Status
    * Purpose       :
    **********************************************************************/

    PROCEDURE Check_Required
        (  p_eam_wo_rec             IN EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_return_status          OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )
    IS
            l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_eam_wo_rec.organization_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_WO_ORG_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF (p_eam_wo_rec.asset_number IS NULL) AND
           (p_eam_wo_rec.rebuild_item_id IS NULL) AND
           (p_eam_wo_rec.maintenance_object_id IS NULL)
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_WO_MAINT_ASSET_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_wo_rec.class_code IS NULL AND p_eam_wo_rec.class_code = FND_API.G_MISS_CHAR
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_WAC_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;



		-- agaurav - Added the check that owning_department is not mandatory
		--             - in the statuses DRAFT and UNRELEASED.

        IF p_eam_wo_rec.status_type not in (wip_constants.draft, wip_constants.unreleased,wip_constants.cancelled, wip_constants.hold)
		THEN
             IF p_eam_wo_rec.owning_department IS NULL
             THEN
                  l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
                  l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

                  l_out_mesg_token_tbl  := l_mesg_token_tbl;
                  EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                  (  p_message_name   => 'EAM_WO_DEPT_REQUIRED'
                   , p_token_tbl      => l_Token_tbl
                   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
                  );
                  l_mesg_token_tbl      := l_out_mesg_token_tbl;

                  x_return_status := FND_API.G_RET_STS_ERROR;

              END IF;
		END IF;


        IF p_eam_wo_rec.wip_entity_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_WIP_ENTITY_ID_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_wo_rec.wip_entity_name IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_WIP_NAME_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_wo_rec.status_type IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_STATUS_TYPE_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_wo_rec.job_quantity IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_JOB_QTY_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_wo_rec.firm_planned_flag IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_FIRM_FLAG_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_wo_rec.wip_supply_type IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_SUPPLY_TYPE_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_wo_rec.scheduled_start_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_START_DATE_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_wo_rec.scheduled_completion_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_COMPL_DATE_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_wo_rec.due_date IS NULL AND p_eam_wo_rec.requested_start_date IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_DATE_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

        IF p_eam_wo_rec.maintenance_object_source IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_MAINT_OBJ_SRC_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_wo_rec.maintenance_object_type IS NOT NULL and
           p_eam_wo_rec.maintenance_object_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_MAINT_OBJ_ID_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_wo_rec.maintenance_object_type IS NULL and
           p_eam_wo_rec.maintenance_object_id IS NOT NULL
        THEN
            l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_MAINT_OBJ_TYPE_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF (p_eam_wo_rec.user_id IS NULL and
           p_eam_wo_rec.responsibility_id IS NOT NULL)
           or (p_eam_wo_rec.user_id IS NOT NULL and
           p_eam_wo_rec.responsibility_id IS NULL)
        THEN
            l_token_tbl(1).token_name  := 'USER_ID';
            l_token_tbl(1).token_value :=  p_eam_wo_rec.user_id;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name   => 'EAM_WO_USER_RESP_REQUIRED'
             , p_token_tbl      => l_Token_tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

/* Added the validation that rebuild serial number is mandatory in status Released */
       IF ( p_eam_wo_rec.status_type in ( WIP_CONSTANTS.RELEASED )
               and p_eam_wo_rec.rebuild_serial_number is NULL
               and p_eam_wo_rec.asset_group_id is NULL
               and p_eam_wo_rec.maintenance_object_type = 3
			   and p_eam_wo_rec.maintenance_object_source = 1)
          THEN
                   l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
                   l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;

                   l_out_mesg_token_tbl  := l_mesg_token_tbl;
                   EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                   (  p_message_name   => 'EAM_WO_REB_SR_NUM_REQUIRED'
                    , p_token_tbl      => l_Token_tbl
                    , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                    , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
                    );
                   l_mesg_token_tbl      := l_out_mesg_token_tbl;

                   x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;



        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    END Check_Required;


END EAM_WO_VALIDATE_PVT;

/
