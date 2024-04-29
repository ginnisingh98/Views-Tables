--------------------------------------------------------
--  DDL for Package Body EAM_OP_NETWORK_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OP_NETWORK_VALIDATE_PVT" AS
/* $Header: EAMVONVB.pls 115.4 2003/06/18 00:16:48 baroy ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVONVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_OP_NETWORK_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_OP_NETWORK_VALIDATE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_dummy         NUMBER;

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
     ( p_eam_op_network_rec     IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
     , x_old_eam_op_network_rec OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_rec_type
     , x_Mesg_Token_Tbl	        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , x_return_status	        OUT NOCOPY VARCHAR2
        )
     IS
            l_token_tbl      EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
            l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_return_status  VARCHAR2(1);
     BEGIN

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Quering Operation Network'); END IF;

        EAM_OP_NETWORK_UTILITY_PVT.Query_Row
        ( p_wip_entity_id       => p_eam_op_network_rec.wip_entity_id
        , p_organization_id     => p_eam_op_network_rec.organization_id
        , p_prior_operation     => p_eam_op_network_rec.prior_operation
        , p_next_operation      => p_eam_op_network_rec.next_operation
        , x_eam_op_network_rec  => x_old_eam_op_network_rec
        , x_Return_status       => l_return_status
        );

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Query Row Returned with : ' || l_return_status); END IF;

        IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND AND
            p_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
        THEN
            l_token_tbl(1).token_name  := 'PRIOR_OPERATION';
            l_token_tbl(1).token_value := p_eam_op_network_rec.prior_operation;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name   => 'EAM_OPN_ALREADY_EXISTS'
             , p_token_tbl      => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            l_return_status := FND_API.G_RET_STS_ERROR;

        ELSIF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND AND
             p_eam_op_network_rec.transaction_type IN
             (EAM_PROCESS_WO_PVT.G_OPR_UPDATE, EAM_PROCESS_WO_PVT.G_OPR_DELETE)
        THEN
            l_token_tbl(1).token_name  := 'PRIOR_OPERATION';
            l_token_tbl(1).token_value :=  p_eam_op_network_rec.prior_operation;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_message_name   => 'EAM_OPN_DOESNOT_EXISTS'
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
             , p_message_text       => 'Unexpected error while existence verification of ' || 'Operation Network '|| p_eam_op_network_rec.prior_operation , p_token_tbl => l_token_tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        ELSE /* Assign the relevant transaction type for SYNC operations */
            IF p_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_SYNC THEN
               IF l_return_status = EAM_PROCESS_WO_PVT.G_RECORD_FOUND THEN
                   x_old_eam_op_network_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
               ELSE
                   x_old_eam_op_network_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
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
        (  p_eam_op_network_rec      IN EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , p_old_eam_op_network_rec  IN EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
    )
    IS
    l_err_text              VARCHAR2(2000) := NULL;
    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

    BEGIN



--  prior_operation

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating prior_operation . . . '); END IF;

   begin

   if (p_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

    select 1
      into g_dummy
      from wip_operations wo
     where wo.organization_id = p_eam_op_network_rec.organization_id
       and wo.wip_entity_id = p_eam_op_network_rec.wip_entity_id
       and wo.operation_seq_num = p_eam_op_network_rec.prior_operation
       and nvl(wo.operation_completed,'N') = 'N';

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'PRIOR_OPERATION';
      l_token_tbl(1).token_value :=  p_eam_op_network_rec.prior_operation;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_OPN_PRIOR_OP_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;


--  next_operation

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating next_operation . . . '); END IF;

   begin

   if (p_eam_op_network_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE) then

    select 1
      into g_dummy
      from wip_operations wo
     where wo.organization_id = p_eam_op_network_rec.organization_id
       and wo.wip_entity_id = p_eam_op_network_rec.wip_entity_id
       and wo.operation_seq_num = p_eam_op_network_rec.next_operation
       and nvl(wo.operation_completed,'N') = 'N';

   end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'NEXT_OPERATION';
      l_token_tbl(1).token_value :=  p_eam_op_network_rec.next_operation;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_OPN_NEXT_OP_INVALID'
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

        IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within Operation Network Check Attributes . . . '); END IF;


    END Check_Attributes;

    /*********************************************************************
    * Procedure     : Check_Required
    * Parameters IN : Material Requirements column record
    * Parameters OUT NOCOPY: Mesg Token Table
    *                 Return_Status
    * Purpose       :
    **********************************************************************/

    PROCEDURE Check_Required
        (  p_eam_op_network_rec     IN EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_return_status          OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )
    IS
            l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
            l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;


        IF p_eam_op_network_rec.wip_entity_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'PRIOR_OPERATION';
            l_token_tbl(1).token_value :=  p_eam_op_network_rec.prior_operation;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OPN_ENTITY_ID_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_op_network_rec.organization_id IS NULL
        THEN
            l_token_tbl(1).token_name  := 'PRIOR_OPERATION';
            l_token_tbl(1).token_value :=  p_eam_op_network_rec.prior_operation;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OPN_ORG_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_op_network_rec.prior_operation IS NULL
        THEN
            l_token_tbl(1).token_name  := 'PRIOR_OPERATION';
            l_token_tbl(1).token_value :=  p_eam_op_network_rec.prior_operation;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OPN_PRIOR_OP_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


        IF p_eam_op_network_rec.next_operation IS NULL
        THEN
            l_token_tbl(1).token_name  := 'PRIOR_OPERATION';
            l_token_tbl(1).token_value :=  p_eam_op_network_rec.prior_operation;

            l_out_mesg_token_tbl  := l_mesg_token_tbl;
            EAM_ERROR_MESSAGE_PVT.Add_Error_Token
            (  p_message_name	=> 'EAM_OPN_NEXT_OP_REQUIRED'
             , p_token_tbl		=> l_Token_tbl
             , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
             );
            l_mesg_token_tbl      := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;



        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    END Check_Required;

END EAM_OP_NETWORK_VALIDATE_PVT;

/
