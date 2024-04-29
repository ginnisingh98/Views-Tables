--------------------------------------------------------
--  DDL for Package Body EAM_PERMIT_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PERMIT_VALIDATE_PVT" AS
/* $Header: EAMVWPVB.pls 120.0.12010000.3 2010/04/23 06:25:48 vboddapa noship $ */

g_dummy NUMBER;
  /********************************************************************
  * Procedure     : Check_Existence
  * Purpose       : Procedure will query the old work permit record and return it in old record variables.
  *********************************************************************/
PROCEDURE CHECK_EXISTENCE(
              p_work_permit_header_rec IN EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type ,
              x_work_permit_header_rec OUT NOCOPY EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type ,
              x_mesg_token_Tbl OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type ,
              x_return_Status OUT NOCOPY VARCHAR2 )
IS
  l_token_tbl EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
  l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
  l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
  l_return_status VARCHAR2(1);
  l_work_permit_header_rec EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;

BEGIN
  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quering Permit'); END IF;
  EAM_PERMIT_UTILITY_PVT.QUERY_ROW (
                  p_work_permit_id => p_work_permit_header_rec.PERMIT_ID ,
                  p_organization_id => p_work_permit_header_rec.organization_id ,
                  x_work_permit_header_rec => l_work_permit_header_rec ,
                  x_Return_status => l_return_status );

  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Query Row Returned with : ' || l_return_status);
  END IF;
  IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND AND p_work_permit_header_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE THEN
    --  l_token_tbl(1).token_name  := 'EAM_WO_PERMIT';
    -- l_token_tbl(1).token_value := p_work_permit_header_rec.direct_item_sequence_id;
    --  l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                        x_Mesg_token_tbl => l_out_Mesg_Token_Tbl ,
                        p_Mesg_Token_Tbl => l_Mesg_Token_Tbl ,
                        p_message_name => 'EAM_PERMIT_ALREADY_EXISTS' ,
                        p_token_tbl => l_token_tbl );
    l_mesg_token_tbl   := l_out_mesg_token_tbl;
    l_return_status    := FND_API.G_RET_STS_ERROR;

  ELSIF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND AND p_work_permit_header_rec.transaction_type IN (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE) THEN
        l_token_tbl(1).token_name  := 'PERMIT_NAME';
        l_token_tbl(1).token_value :=  p_work_permit_header_rec.PERMIT_NAME;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl ,
                  p_Mesg_Token_Tbl => l_Mesg_Token_Tbl ,
                  p_message_name => 'EAM_PERMIT_DOESNOT_EXISTS' ,
                  p_token_tbl => l_token_tbl );
    l_mesg_token_tbl   := l_out_mesg_token_tbl;
    l_return_status    := FND_API.G_RET_STS_ERROR;

  ELSIF l_Return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                x_Mesg_token_tbl => l_out_Mesg_Token_Tbl ,
                p_Mesg_Token_Tbl => l_Mesg_Token_Tbl ,
                p_message_name => NULL ,
                p_message_text => 'Unexpected error' );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    l_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
  ELSE
    l_return_status          := FND_API.G_RET_STS_SUCCESS;
    x_work_permit_header_rec :=l_work_permit_header_rec;
  END IF;
  x_return_status  := l_return_status;
  x_mesg_token_tbl := l_mesg_token_tbl;

END CHECK_EXISTENCE;


/********************************************************************
* Procedure: Check_Attributes
* Purpose: Check_Attributes procedure will validate every Revised item attribute in its entirely.
*********************************************************************/
PROCEDURE CHECK_ATTRIBUTES(
                  p_work_permit_header_rec     IN EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type ,
                  p_old_work_permit_header_rec IN EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type ,
                  x_mesg_token_Tbl OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type ,
                 x_return_Status OUT NOCOPY VARCHAR2 )
IS
  l_err_text VARCHAR2(2000) := NULL;
  l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
  l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
  l_Token_Tbl EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

BEGIN
  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within Permit Check Attributes . . . '); END IF;

  /*IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating organization_id . . . '); END IF;

  DECLARE
    l_disable_date DATE;
  BEGIN
    SELECT 1
    INTO g_dummy
    FROM mtl_parameters mp
    WHERE mp.organization_id = p_work_permit_header_rec.organization_id;
    SELECT NVL(hou.date_to,sysdate+1)
    INTO l_disable_date
    FROM hr_organization_units hou
    WHERE organization_id = p_work_permit_header_rec.organization_id;
    IF(l_disable_date     < sysdate) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    -- l_token_tbl(1).token_name  := 'Organization Id';
    -- l_token_tbl(1).token_value :=  p_eam_wo_rec.organization_id;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                  p_message_name => 'EAM_PERMIT_ORGANIZATION_ID' ,
                  p_token_tbl => l_token_tbl ,
                  p_mesg_token_tbl => l_mesg_token_tbl ,
                  x_mesg_token_tbl => l_out_mesg_token_tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_mesg_token_tbl := l_mesg_token_tbl ;
    RETURN;
  WHEN no_data_found THEN
    -- l_token_tbl(1).token_name  := 'Organization Id';
    -- l_token_tbl(1).token_value :=  p_eam_wo_rec.organization_id;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                    p_message_name => 'EAM_PERMIT_ORGANIZATION_ID' ,
                    p_token_tbl => l_token_tbl ,
                    p_mesg_token_tbl => l_mesg_token_tbl ,
                    x_mesg_token_tbl => l_out_mesg_token_tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_mesg_token_tbl := l_mesg_token_tbl ;
    RETURN;
  END;

  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating organization_id (EAM enabled) . . . ');
  END IF;

  BEGIN
    SELECT 1
    INTO g_dummy
    FROM wip_eam_parameters wep,
      mtl_parameters mp
    WHERE wep.organization_id = mp.organization_id
    AND mp.eam_enabled_flag   = 'Y'
    AND wep.organization_id   = p_work_permit_header_rec.organization_id;
    x_return_status          := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN no_data_found THEN
    -- l_token_tbl(1).token_name  := 'Organization Id';
    -- l_token_tbl(1).token_value :=  p_work_permit_header_rec.organization_id;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                  p_message_name => 'EAM_PERMIT_ORG_EAM_ENABLED' ,
                  p_token_tbl => l_token_tbl ,
                  p_mesg_token_tbl => l_mesg_token_tbl ,
                  x_mesg_token_tbl => l_out_mesg_token_tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_mesg_token_tbl := l_mesg_token_tbl ;
    RETURN;
  END;

/*  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating if Permit ID already exists for create . . . '); END IF;

  DECLARE
    l_count NUMBER;
  BEGIN
    IF (p_work_permit_header_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) THEN
      SELECT COUNT(*)
      INTO l_count
      FROM EAM_WORK_PERMITS
      WHERE PERMIT_ID     = p_work_permit_header_rec.PERMIT_ID
      AND organization_id = p_work_permit_header_rec.organization_id;
      IF(l_count          > 0) THEN
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    --  l_token_tbl(1).token_name  := 'Wip Entity Name';
    -- l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                    p_message_name => 'EAM_PERMIT_ID' ,
                    p_token_tbl => l_token_tbl ,
                    p_mesg_token_tbl => l_mesg_token_tbl ,
                    x_mesg_token_tbl => l_out_mesg_token_tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_mesg_token_tbl := l_mesg_token_tbl ;
    RETURN;
  END; */

  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating if Permit ID exists for update . . . '); END IF;
  DECLARE
    l_count NUMBER;
  BEGIN
    IF (p_work_permit_header_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE) THEN
      SELECT COUNT(*)
      INTO l_count
      FROM EAM_WORK_PERMITS
      WHERE PERMIT_ID     = p_work_permit_header_rec.PERMIT_ID
      AND organization_id = p_work_permit_header_rec.organization_id;

      IF(l_count         <> 1) THEN
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    --  l_token_tbl(1).token_name  := 'Wip Entity Name';
    -- l_token_tbl(1).token_value :=  p_eam_wo_rec.wip_entity_name;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                  p_message_name => 'EAM_PERMIT_ID_NOT_EXIST' ,
                  p_token_tbl => l_token_tbl ,
                  p_mesg_token_tbl => l_mesg_token_tbl ,
                  x_mesg_token_tbl => l_out_mesg_token_tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_mesg_token_tbl := l_mesg_token_tbl ;
    RETURN;
  END;

  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating Permit Name . . . '); END IF;
  DECLARE
    l_count NUMBER;
  BEGIN
    IF (p_work_permit_header_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) THEN
      SELECT COUNT(*)
      INTO l_count
      FROM EAM_WORK_PERMITS
      WHERE PERMIT_NAME   = p_work_permit_header_rec.PERMIT_NAME
      AND organization_id = p_work_permit_header_rec.organization_id;
      IF(l_count          > 0) THEN
        raise fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
        l_token_tbl(1).token_name  := 'PERMIT_NAME';
        l_token_tbl(1).token_value :=  p_work_permit_header_rec.PERMIT_NAME;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                    p_message_name => 'EAM_PERMIT_NAME' ,
                    p_token_tbl => l_token_tbl ,
                    p_mesg_token_tbl => l_mesg_token_tbl ,
                    x_mesg_token_tbl => l_out_mesg_token_tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_mesg_token_tbl := l_mesg_token_tbl ;
    RETURN;
  END;

  --  status_type
 /* IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating status_type. . . '); END IF;
  BEGIN
    IF (p_work_permit_header_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE AND p_work_permit_header_rec.status_type NOT IN (wip_constants.released, wip_constants.draft)) THEN
      raise fnd_api.g_exc_unexpected_error;
    elsif (p_work_permit_header_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE AND p_work_permit_header_rec.status_type NOT IN (wip_constants.released, wip_constants.cancelled,wip_constants.comp_chrg,wip_constants.comp_nochrg )) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    --  l_token_tbl(1).token_name  := 'Status type';
    --  l_token_tbl(1).token_value :=  p_eam_wo_rec.status_type;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                  p_message_name => 'EAM_PERMIT_STATUS_TYPE' ,
                  p_token_tbl => l_token_tbl ,
                  p_mesg_token_tbl => l_mesg_token_tbl ,
                  x_mesg_token_tbl => l_out_mesg_token_tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_mesg_token_tbl := l_mesg_token_tbl ;
    RETURN;
  END;

  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating status_type for cancelled. . . '); END IF;
  BEGIN
    IF (p_work_permit_header_rec.transaction_type= EAM_PROCESS_WO_PVT.G_OPR_UPDATE AND
    p_work_permit_header_rec.status_type = wip_constants.cancelled OR
    p_work_permit_header_rec.PERMIT_NAME <> p_old_work_permit_header_rec.PERMIT_NAME OR
    p_work_permit_header_rec.PERMIT_TYPE <> p_old_work_permit_header_rec.PERMIT_TYPE OR
    p_work_permit_header_rec.DESCRIPTION <> p_old_work_permit_header_rec.DESCRIPTION OR
    p_work_permit_header_rec.ORGANIZATION_ID <> p_old_work_permit_header_rec.ORGANIZATION_ID OR
    p_work_permit_header_rec.VALID_FROM <> p_old_work_permit_header_rec.VALID_FROM OR
    p_work_permit_header_rec.VALID_TO <> p_old_work_permit_header_rec.VALID_TO OR
    p_work_permit_header_rec.PENDING_FLAG <> p_old_work_permit_header_rec.PENDING_FLAG OR
    p_work_permit_header_rec.COMPLETION_DATE <> p_old_work_permit_header_rec.COMPLETION_DATE OR
    p_work_permit_header_rec.USER_DEFINED_STATUS_ID <> p_old_work_permit_header_rec.USER_DEFINED_STATUS_ID OR
    p_work_permit_header_rec.ATTRIBUTE_CATEGORY <> p_old_work_permit_header_rec.ATTRIBUTE_CATEGORY OR
    p_work_permit_header_rec.ATTRIBUTE1 <> p_old_work_permit_header_rec.ATTRIBUTE1 OR
    p_work_permit_header_rec.ATTRIBUTE2 <> p_old_work_permit_header_rec.ATTRIBUTE2 OR
    p_work_permit_header_rec.ATTRIBUTE3 <> p_old_work_permit_header_rec.ATTRIBUTE3 OR
    p_work_permit_header_rec.ATTRIBUTE4 <> p_old_work_permit_header_rec.ATTRIBUTE4 OR
    p_work_permit_header_rec.ATTRIBUTE5 <> p_old_work_permit_header_rec.ATTRIBUTE5 OR
    p_work_permit_header_rec.ATTRIBUTE6 <> p_old_work_permit_header_rec.ATTRIBUTE6 OR
    p_work_permit_header_rec.ATTRIBUTE7 <> p_old_work_permit_header_rec.ATTRIBUTE7 OR
    p_work_permit_header_rec.ATTRIBUTE8 <> p_old_work_permit_header_rec.ATTRIBUTE8 OR
    p_work_permit_header_rec.ATTRIBUTE9 <> p_old_work_permit_header_rec.ATTRIBUTE9 OR
    p_work_permit_header_rec.ATTRIBUTE10<> p_old_work_permit_header_rec.ATTRIBUTE10 OR
    p_work_permit_header_rec.ATTRIBUTE11 <> p_old_work_permit_header_rec.ATTRIBUTE11 OR
    p_work_permit_header_rec.ATTRIBUTE12 <> p_old_work_permit_header_rec.ATTRIBUTE12 OR
    p_work_permit_header_rec.ATTRIBUTE13 <> p_old_work_permit_header_rec.ATTRIBUTE13 OR
    p_work_permit_header_rec.ATTRIBUTE14 <> p_old_work_permit_header_rec.ATTRIBUTE14 OR
    p_work_permit_header_rec.ATTRIBUTE15 <> p_old_work_permit_header_rec.ATTRIBUTE15 OR
    p_work_permit_header_rec.APPROVED_BY <> p_old_work_permit_header_rec.APPROVED_BY ) THEN
      raise fnd_api.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN fnd_api.g_exc_unexpected_error THEN
    --  l_token_tbl(1).token_name  := 'Status type';
    --  l_token_tbl(1).token_value :=  p_eam_wo_rec.status_type;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                  p_message_name => 'EAM_PERMIT_STATUS_TYPE' ,
                  p_token_tbl => l_token_tbl ,
                  p_mesg_token_tbl => l_mesg_token_tbl ,
                  x_mesg_token_tbl => l_out_mesg_token_tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_mesg_token_tbl := l_mesg_token_tbl ;
    RETURN;
  END;*/

  --  user_id
  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating user_id . . . '); END IF;
  BEGIN
    IF (p_work_permit_header_rec.user_id IS NOT NULL) THEN
      SELECT 1
      INTO g_dummy
      FROM fnd_user
      WHERE user_id    = p_work_permit_header_rec.user_id;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;
  EXCEPTION
  WHEN no_data_found THEN
    --l_token_tbl(1).token_name  := 'USER_ID';
    --l_token_tbl(1).token_value :=  p_eam_wo_rec.user_id;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                  p_message_name => 'EAM_PERMIT_USER' ,
                  p_token_tbl => l_token_tbl ,
                  p_mesg_token_tbl => l_mesg_token_tbl ,
                  x_mesg_token_tbl => l_out_mesg_token_tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_mesg_token_tbl := l_mesg_token_tbl ;
    RETURN;
  END;

  --  responsibility_id
  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating responsibility_id . . . '); END IF;
  BEGIN
    IF (p_work_permit_header_rec.responsibility_id IS NOT NULL) THEN
      SELECT 1
      INTO g_dummy
      FROM fnd_responsibility
      WHERE responsibility_id = p_work_permit_header_rec.responsibility_id;
      x_return_status        := FND_API.G_RET_STS_SUCCESS;
    END IF;
  EXCEPTION
  WHEN no_data_found THEN
    -- l_token_tbl(1).token_name  := 'RESPONSIBILITY_ID';
    -- l_token_tbl(1).token_value :=  p_eam_wo_rec.responsibility_id;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                p_message_name => 'EAM_PERMIT_RESPONSIBILITY' ,
                p_token_tbl => l_token_tbl ,
                p_mesg_token_tbl => l_mesg_token_tbl ,
                x_mesg_token_tbl => l_out_mesg_token_tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_mesg_token_tbl := l_mesg_token_tbl ;
    RETURN;
  END;

END CHECK_ATTRIBUTES;


/********************************************************************
* Procedure     : Check_Required
* Purpose       : Check_Required procedure will check the existence of mandatory attributes.
*********************************************************************/
PROCEDURE CHECK_REQUIRED(
          p_work_permit_header_rec IN EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type ,
          x_mesg_token_Tbl OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type ,
          x_return_Status OUT NOCOPY VARCHAR2 )
IS
  l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
  l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
  l_Token_Tbl EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

BEGIN
  IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Checking required attributes for Permit . . . '); END IF;
  x_return_status                       := FND_API.G_RET_STS_SUCCESS;
  IF p_work_permit_header_rec.PERMIT_ID IS NULL THEN
    -- l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
    -- l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                    p_message_name => 'EAM_PERMIT_ID_REQUIRED' ,
                    p_token_tbl => l_Token_tbl ,
                    p_Mesg_Token_Tbl => l_Mesg_Token_Tbl ,
                    x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
  END IF;
  IF p_work_permit_header_rec.PERMIT_NAME IS NULL THEN
    -- l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
    -- l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                  p_message_name => 'EAM_PERMIT_NAME_REQUIRED' ,
                  p_token_tbl => l_Token_tbl ,
                  p_Mesg_Token_Tbl => l_Mesg_Token_Tbl ,
                  x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
  END IF;
  IF p_work_permit_header_rec.ORGANIZATION_ID IS NULL THEN
    -- l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
    -- l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                    p_message_name => 'EAM_PERMIT_ORG_REQUIRED' ,
                    p_token_tbl => l_Token_tbl ,
                    p_Mesg_Token_Tbl => l_Mesg_Token_Tbl ,
                    x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
  END IF;
  IF p_work_permit_header_rec.STATUS_TYPE IS NULL THEN
    -- l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
    -- l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;
    l_out_mesg_token_tbl := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token (
                  p_message_name => 'EAM_PERMIT_STATUS_REQUIRED' ,
                  p_token_tbl => l_Token_tbl ,
                  p_Mesg_Token_Tbl => l_Mesg_Token_Tbl ,
                  x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl );
    l_mesg_token_tbl := l_out_mesg_token_tbl;
    x_return_status  := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_work_permit_header_rec.USER_ID IS NULL
  THEN
  -- l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
  -- l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;
  l_out_mesg_token_tbl  := l_mesg_token_tbl;
  EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name => 'EAM_PERMIT_USERID_REQUIRED'
              , p_token_tbl  => l_Token_tbl
              , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
            );
  l_mesg_token_tbl      := l_out_mesg_token_tbl;
  x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  IF p_work_permit_header_rec.RESPONSIBILITY_ID IS NULL
  THEN
  -- l_token_tbl(1).token_name  := 'OPERATION_SEQ_NUM';
  -- l_token_tbl(1).token_value :=  p_eam_op_rec.operation_seq_num;
  l_out_mesg_token_tbl  := l_mesg_token_tbl;
  EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name => 'EAM_PERMIT_RESPID_REQUIRED'
              , p_token_tbl  => l_Token_tbl
              , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl => l_out_Mesg_Token_Tbl
            );
  l_mesg_token_tbl      := l_out_mesg_token_tbl;
  x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END CHECK_REQUIRED;
END EAM_PERMIT_VALIDATE_PVT;

/
