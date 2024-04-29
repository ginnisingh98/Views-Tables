--------------------------------------------------------
--  DDL for Package Body BOM_OP_NETWORK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_OP_NETWORK_UTIL" AS
/* $Header: BOMUONWB.pls 120.2 2006/03/09 21:49:48 bbpatel noship $*/
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUONWB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Op_Network_UTIL
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00 Biao Zhang Initial Creation
--
****************************************************************************/
        G_Pkg_Name      VARCHAR2(30) := 'BOM_Op_Network_UTIL';
        g_token_tbl     Error_Handler.Token_Tbl_Type;


        /*********************************************************************
        * Procedure     : Query_Row
        * Parameters IN : Assembly item id
        *                 Organization Id
        *                 Alternate_Rtg_Code
        * Parameters OUT: Operation network exposed column record
        *                 Operation network unexposed column record
        *                 Mesg token Table
        *                 Return Status
        * Purpose       : Procedure will query the database record, seperate the
        *                 values into exposed columns and unexposed columns and
        *                 return with those records.
        ***********************************************************************/
      PROCEDURE Query_Row
      ( p_from_op_seq_id         IN  NUMBER
      , p_to_op_seq_id           IN  NUMBER
      , x_op_network_rec         IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
      , x_op_network_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_unexposed_Rec_Type
      , x_Return_status          IN OUT NOCOPY VARCHAR2
      )
        IS
        l_op_network_rec        Bom_Rtg_Pub.op_network_Rec_Type;
        l_op_network_unexp_rec  Bom_Rtg_Pub.op_network_Unexposed_Rec_Type;
        l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        l_dummy                 varchar2(10);
        BEGIN
              IF BOM_Rtg_Globals.Get_Debug = 'Y'
              THEN Error_Handler.Write_Debug('Query row for operation network');
              END IF;

                SELECT  from_op_seq_id
                ,       to_op_seq_id
                ,       transition_type
                ,       planning_pct
           --     ,       effecitvity_date
           --     ,       disable_date
                ,       attribute_category
                ,       attribute1
                ,       attribute2
                ,       attribute3
                ,       attribute4
                ,       attribute5
                ,       attribute6
                ,       attribute7
                ,       attribute8
                ,       attribute9
                ,       attribute10
                ,       attribute11
                ,       attribute12
                ,       attribute13
                ,       attribute14
                ,       attribute15
                INTO    l_op_network_unexp_rec.from_op_seq_id
                ,       l_op_network_unexp_rec.to_op_seq_id
                ,       l_op_network_rec.connection_type
                ,       l_op_network_rec.planning_percent
            --    ,       l_op_network_rec.effecitvity_date
            --    ,       l_op_network_rec.disable_date
                ,       l_op_network_rec.attribute_category
                ,       l_op_network_rec.attribute1
                ,       l_op_network_rec.attribute2
                ,       l_op_network_rec.attribute3
                ,       l_op_network_rec.attribute4
                ,       l_op_network_rec.attribute5
                ,       l_op_network_rec.attribute6
                ,       l_op_network_rec.attribute7
                ,       l_op_network_rec.attribute8
                ,       l_op_network_rec.attribute9
                ,       l_op_network_rec.attribute10
                ,       l_op_network_rec.attribute11
                ,       l_op_network_rec.attribute12
                ,       l_op_network_rec.attribute13
                ,       l_op_network_rec.attribute14
                ,       l_op_network_rec.attribute15
                FROM  bom_operation_networks
                WHERE from_op_seq_id = p_from_op_seq_id
                AND to_op_seq_id = p_to_op_seq_id;

                x_return_status        := BOM_Rtg_Globals.G_RECORD_FOUND;
                x_op_network_rec       := l_op_network_rec;
                x_op_network_unexp_rec := l_op_network_unexp_rec;

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := BOM_Rtg_Globals.G_RECORD_NOT_FOUND;
                        x_op_network_rec := l_op_network_rec;
                        x_op_network_unexp_rec := l_op_network_unexp_rec;
                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_op_network_rec := l_op_network_rec;
                        x_op_network_unexp_rec := l_op_network_unexp_rec;

        END Query_Row;

        /********************************************************************
        * Procedure     : Insert_Row
        * Parameters IN : Operation networker exposed column record
        *                 Operation networker unexposed column record
        * Parameters OUT: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 rtg_Bill_Of_Materials table thus creating a new bill
        *********************************************************************/
        PROCEDURE Insert_Row
        (  p_op_network_rec   IN  Bom_Rtg_Pub.op_network_Rec_Type
         , p_op_network_unexp_rec  IN  Bom_Rtg_Pub.op_network_Unexposed_Rec_Type
         , x_mesg_token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status      IN OUT NOCOPY VARCHAR2
         )
        IS
          p_start_effectivity_date DATE;
          p_implementation_date DATE;

        BEGIN

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
 Error_Handler.Write_Debug('Writing Operation networker rec for '
                                  || p_op_network_rec.assembly_item_name);
END IF;

                --bug:3254815 Update request id, prog id, prog appl id and prog update date.
                INSERT INTO  bom_operation_networks
                (       from_op_seq_id
                ,       to_op_seq_id
                ,       transition_type
                ,       planning_pct
         --       ,       effectivity_date
         --       ,       disable_date
                ,       attribute_category
                ,       attribute1
                ,       attribute2
                ,       attribute3
                ,       attribute4
                ,       attribute5
                ,       attribute6
                ,       attribute7
                ,       attribute8
                ,       attribute9
                ,       attribute10
                ,       attribute11
                ,       attribute12
                ,       attribute13
                ,       attribute14
                ,       attribute15
                ,       creation_date
                ,       created_by
                ,       last_update_date
                ,       last_updated_by
                ,       last_update_login
                ,       original_system_reference -- Added by MK 05/01
                ,       request_id
                ,       program_id
                ,       program_application_id
                ,       program_update_date
                 )
                VALUES
                (  p_op_network_unexp_rec.from_op_seq_id
                 , p_op_network_unexp_rec.to_op_seq_id
                 , p_op_network_rec.connection_type
                 , p_op_network_rec.planning_percent
           --      , NULL
           --      , NULL
                 , p_op_network_rec.attribute_category
                 , p_op_network_rec.attribute1
                 , p_op_network_rec.attribute2
                 , p_op_network_rec.attribute3
                 , p_op_network_rec.attribute4
                 , p_op_network_rec.attribute5
                 , p_op_network_rec.attribute6
                 , p_op_network_rec.attribute7
                 , p_op_network_rec.attribute8
                 , p_op_network_rec.attribute9
                 , p_op_network_rec.attribute10
                 , p_op_network_rec.attribute11
                 , p_op_network_rec.attribute12
                 , p_op_network_rec.attribute13
                 , p_op_network_rec.attribute14
                 , p_op_network_rec.attribute15
                 , SYSDATE
                 , BOM_Rtg_Globals.Get_User_Id
                 , SYSDATE
                 , BOM_Rtg_Globals.Get_User_Id
                 , BOM_Rtg_Globals.Get_Login_Id
                 , p_op_network_rec.original_system_reference -- Added by MK 05/01
                 , Fnd_Global.Conc_Request_Id
                 , Fnd_Global.Conc_Program_Id
                 , Fnd_Global.Prog_Appl_Id
                 , SYSDATE
                );
  -- Update bom_operation sequences to set the X and Y coordinates
  -- for the operations involved in this network.
                update BOM_OPERATION_SEQUENCES set
                X_COORDINATE = p_op_network_rec.From_X_Coordinate
               ,Y_COORDINATE = p_op_network_rec.From_Y_Coordinate
               , last_update_date =  SYSDATE
               , last_updated_by = BOM_Rtg_Globals.Get_User_Id
               , last_update_login = BOM_Rtg_Globals.Get_Login_Id
               , request_id = Fnd_Global.Conc_Request_Id
               , program_id = Fnd_Global.Conc_Program_Id
               , program_application_id = Fnd_Global.Prog_Appl_Id
               , program_update_date = SYSDATE
                where operation_sequence_id =
                p_op_network_unexp_rec.from_op_seq_id;

                update BOM_OPERATION_SEQUENCES set
                X_COORDINATE = p_op_network_rec.To_X_Coordinate
               ,Y_COORDINATE = p_op_network_rec.To_Y_Coordinate
               , last_update_date =  SYSDATE
               , last_updated_by = BOM_Rtg_Globals.Get_User_Id
               , last_update_login = BOM_Rtg_Globals.Get_Login_Id
               , request_id = Fnd_Global.Conc_Request_Id
               , program_id = Fnd_Global.Conc_Program_Id
               , program_application_id = Fnd_Global.Prog_Appl_Id
               , program_update_date = SYSDATE
                where operation_sequence_id =
                p_op_network_unexp_rec.to_op_seq_id;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
            WHEN OTHERS THEN
                        Error_Handler.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||
                                                  ' :Inserting Record ' ||
                                                  SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
                        );
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Insert_Row;

        /********************************************************************
        * Procedure     : Update_Row
        * Parameters IN : Operation networker exposed column record
        *                 Operation networker unexposed column record
        * Parameters OUT: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update into the
        *                 rtg_Bill_Of_Materials table.
        *********************************************************************/
        PROCEDURE Update_Row
        (  p_op_network_rec   IN  Bom_Rtg_Pub.op_network_Rec_Type
         , p_op_network_unexp_rec  IN  Bom_Rtg_Pub.op_network_Unexposed_Rec_Type
         , x_mesg_token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status      IN OUT NOCOPY VARCHAR2
         )
        IS
        p_start_effectivity_date DATE;
        p_implementation_date DATE;
        BEGIN

                --
                -- The fields that are updateable in Operation networker
                -- are...
                --

                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
                  Error_Handler.Write_Debug('Updating operation network ');
                END IF;

                   UPDATE  bom_operation_networks
                     SET
                       from_op_seq_id = DECODE(p_op_network_unexp_rec.new_from_op_seq_id,
                                               NULL , p_op_network_unexp_rec.from_op_seq_id,
                                               p_op_network_unexp_rec.new_from_op_seq_id
                                               )
                     , to_op_seq_id   = DECODE(p_op_network_unexp_rec.new_to_op_seq_id,
                                               NULL , p_op_network_unexp_rec.to_op_seq_id,
                                               p_op_network_unexp_rec.new_to_op_seq_id
                                               )
                     , planning_pct =  p_op_network_rec.planning_percent
                     , transition_type =p_op_network_rec.connection_type
                     , last_update_date =  SYSDATE
                     , last_updated_by = BOM_Rtg_Globals.Get_User_Id
                     , last_update_login = BOM_Rtg_Globals.Get_Login_Id
                     , attribute_category =p_op_network_rec.attribute_category
                     , attribute1 = p_op_network_rec.attribute1
                     , attribute2 = p_op_network_rec.attribute2
                     , attribute3 = p_op_network_rec.attribute3
                     , attribute4 = p_op_network_rec.attribute4
                     , attribute5 = p_op_network_rec.attribute5
                     , attribute6 = p_op_network_rec.attribute6
                     , attribute7 = p_op_network_rec.attribute7
                     , attribute8 = p_op_network_rec.attribute8
                     , attribute9 = p_op_network_rec.attribute9
                     , attribute10= p_op_network_rec.attribute10
                     , attribute11= p_op_network_rec.attribute11
                     , attribute12= p_op_network_rec.attribute12
                     , attribute13= p_op_network_rec.attribute13
                     , attribute14= p_op_network_rec.attribute14
                     , attribute15= p_op_network_rec.attribute15
                     , original_system_reference = p_op_network_rec.original_system_reference
                     , request_id = Fnd_Global.Conc_Request_Id
                     , program_id = Fnd_Global.Conc_Program_Id
                     , program_application_id = Fnd_Global.Prog_Appl_Id
                     , program_update_date = SYSDATE
               WHERE from_op_seq_id = p_op_network_unexp_rec.from_op_seq_id
               AND to_op_seq_id = p_op_network_unexp_rec.to_op_seq_id;

  -- Update bom_operation sequences to set the X and Y coordinates
  -- for the operations involved in this network.
                update BOM_OPERATION_SEQUENCES set
                X_COORDINATE = p_op_network_rec.From_X_Coordinate
               ,Y_COORDINATE = p_op_network_rec.From_Y_Coordinate
               , last_update_date =  SYSDATE
               , last_updated_by = BOM_Rtg_Globals.Get_User_Id
               , last_update_login = BOM_Rtg_Globals.Get_Login_Id
               , request_id = Fnd_Global.Conc_Request_Id
               , program_id = Fnd_Global.Conc_Program_Id
               , program_application_id = Fnd_Global.Prog_Appl_Id
               , program_update_date = SYSDATE
                where operation_sequence_id =
                      DECODE(p_op_network_unexp_rec.new_from_op_seq_id,
                      NULL , p_op_network_unexp_rec.from_op_seq_id,
                      p_op_network_unexp_rec.new_from_op_seq_id);


                update BOM_OPERATION_SEQUENCES set
                X_COORDINATE = p_op_network_rec.To_X_Coordinate
               ,Y_COORDINATE = p_op_network_rec.To_Y_Coordinate
               , last_update_date =  SYSDATE
               , last_updated_by = BOM_Rtg_Globals.Get_User_Id
               , last_update_login = BOM_Rtg_Globals.Get_Login_Id
               , request_id = Fnd_Global.Conc_Request_Id
               , program_id = Fnd_Global.Conc_Program_Id
               , program_application_id = Fnd_Global.Prog_Appl_Id
               , program_update_date = SYSDATE
                where operation_sequence_id =
                      DECODE(p_op_network_unexp_rec.new_to_op_seq_id,
                      NULL , p_op_network_unexp_rec.to_op_seq_id,
                      p_op_network_unexp_rec.new_to_op_seq_id);

        END Update_Row;


        /********************************************************************
        * Procedure     : Delete_Row
        * Parameters IN : Operation networker exposed column record
        *                 Operation networker unexposed column record
        * Parameters OUT: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Delete from the
        *                 rtg_Bill_Of_Materials by creating a delete Group.
        *********************************************************************/
        PROCEDURE Delete_Row
        (  p_op_network_rec       IN  Bom_Rtg_Pub.op_network_Rec_Type
         , p_op_network_unexp_rec IN  Bom_Rtg_Pub.op_network_Unexposed_Rec_Type
         , x_mesg_token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status        IN OUT NOCOPY VARCHAR2
         )
        IS
                l_op_network_unexp_rec  Bom_Rtg_Pub.op_network_Unexposed_Rec_Type                                          := p_op_network_unexp_rec;
                l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;

        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
                        Error_Handler.Write_Debug('Delete operation network.'
                      );
                END IF;

                DELETE FROM bom_operation_networks
                WHERE from_op_seq_id = p_op_network_unexp_rec.from_op_seq_id
                  AND to_op_seq_id = p_op_network_unexp_rec.to_op_seq_id;

                EXCEPTION
                WHEN OTHERS THEN
                    Error_Handler.Add_Error_Token
                    (  p_Message_Name  => NULL
                     , p_Message_Text  => 'ERROR in Delete Operation Network:'
                           || substr(SQLERRM, 1, 100) || ' '    ||
                                  to_char(SQLCODE)
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => x_Mesg_Token_Tbl
                    );
                x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Delete_Row;

        /*********************************************************************
        * Procedure     : Perform_Writes
        * Parameters IN : Operation network Exposed Column Record
        *                 Operation network Unexposed column record
        * Parameters OUT: Messgae Token Table
        *                 Return Status
        * Purpose       : This is the only procedure that the user will have
        *                 access to when he/she needs to perform any kind of
        *                 writes to the bom_operational_routings.
        *********************************************************************/
        PROCEDURE Perform_Writes
       ( p_Op_Network_rec      IN  Bom_Rtg_Pub.Op_Network_Rec_Type
       , p_Op_Network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
       , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status       IN OUT NOCOPY VARCHAR2
       )
        IS
                l_Mesg_Token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
                l_err_text              VARCHAR2(2000) ;

        BEGIN
                IF p_op_network_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
                THEN
                        Insert_Row
                        (  p_op_network_rec     => p_op_network_rec
                         , p_op_network_unexp_rec       => p_op_network_unexp_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                ELSIF p_op_network_rec.transaction_type =
                                                        Bom_Rtg_Globals.G_OPR_UPDATE
                THEN
                        Update_Row
                        (  p_op_network_rec     => p_op_network_rec
                         , p_op_network_unexp_rec => p_op_network_unexp_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

                ELSIF p_op_network_rec.transaction_type =
                                                        BOM_Rtg_Globals.G_OPR_DELETE
                THEN
                        Delete_Row
                        (  p_op_network_rec     => p_op_network_rec
                         , p_op_network_unexp_rec => p_op_network_unexp_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                END IF;

                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;

         EXCEPTION
             WHEN OTHERS THEN
                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                ('Some unknown error in Perform Writes . . .' || SQLERRM );
                END IF ;


                l_err_text := G_PKG_NAME || ' Utility (Perform Writes) '
                                || substrb(SQLERRM,1,200);

                Error_Handler.Add_Error_Token
                (  p_message_name   => NULL
                 , p_message_text   => l_err_text
                 , p_mesg_token_tbl => l_mesg_token_tbl
                 , x_mesg_token_tbl => l_mesg_token_tbl
                ) ;

                -- Return the status and message table.
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                x_mesg_token_tbl := l_mesg_token_tbl ;

        END Perform_Writes;

  /*********************************************************************
  * Procedure     : Get_WSM_Netowrk_Attribs
  * Parameters IN : Assembly item id
  *                 Organization Id
  *                 Alternate_Rtg_Code
  * Parameters OUT:
  *                 previous start operation id
  *                 previous end operation id
  *                 Mesg token Table
  *                 Return Status
  * Purpose       : Procedure will query start and end operation of the
  *                 entire routing and return those
  ***********************************************************************/
  PROCEDURE Get_WSM_Netowrk_Attribs
  ( p_routing_sequence_id        IN  NUMBER
  , x_prev_start_id              IN OUT NOCOPY NUMBER
  , x_prev_end_id                IN OUT NOCOPY NUMBER
  , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_status              IN OUT NOCOPY VARCHAR2
  )
  IS
    l_routing_sequence_id  NUMBER :=0;
    l_common_routing_sequence_id NUMBER :=0;
    l_cfm_routing_flag     NUMBER :=0;
    l_mesg_token_tbl       Error_Handler.Mesg_Token_Tbl_Type ;
    err_code                       NUMBER;
    err_msg                        VARCHAR2(2000);
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select routing_sequence_id, cfm_routing_flag
    into   l_routing_sequence_id,l_cfm_routing_flag
    from bom_operational_routings where
         routing_sequence_id = p_routing_sequence_id;
    -- Get Common Routing Seq Id from System Info Rec.
    -- If the value is Null, set Common Routing Seq Id.
    l_common_routing_sequence_id := BOM_Rtg_Globals.Get_Common_Rtg_Seq_id ;

    IF l_common_routing_sequence_id IS NULL OR
       l_common_routing_sequence_id = FND_API.G_MISS_NUM THEN
      BEGIN
        SELECT  common_routing_sequence_id
        INTO    l_common_routing_sequence_id
        FROM    bom_operational_routings
        WHERE   routing_sequence_id = l_routing_sequence_id;
      END ;
      BOM_Rtg_Globals.Set_Common_Rtg_Seq_id
      ( p_common_rtg_seq_id => l_common_routing_sequence_id );
    END IF;
    IF nvl(l_cfm_routing_flag,2) = 3 THEN
      WSMPUTIL.FIND_ROUTING_START(l_common_routing_sequence_id,
      x_prev_start_id,
      err_code,
      err_msg );

      IF err_code = -1 THEN  --for OSFM routings
        RETURN;
      END IF;

      IF err_msg IS NOT NULL THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => err_msg
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        RETURN;
      END IF;

      WSMPUTIL.FIND_ROUTING_END(l_common_routing_sequence_id,
      x_prev_end_id,
      err_code,
      err_msg );

      IF err_code = -1 THEN  --for OSFM routings
        RETURN;
      END IF;

      IF err_msg IS NOT NULL THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => err_msg
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        RETURN;
      END IF;
    END IF;


    -- Return messages
    x_mesg_token_tbl := l_mesg_token_tbl ;
  END Get_WSM_Netowrk_Attribs;

  /*********************************************************************
  * Procedure     : Set_WSM_Network_Sub_Loc
  * Parameters IN : Assembly item id
  *                 Organization Id
  *                 Alternate_Rtg_Code
  *                 end operation id
  * Parameters OUT:
  *                 Mesg token Table
  *                 Return Status
  * Purpose       : Procedure checks and then sets the sub inventory and
  *                 locator for the OSFM routing
  ***********************************************************************/
  /**********************************************************************
   * The logic : we get assembly's default sub inv and loc.             *
   * Then we get the last op's sinv/loc. If these are null then we check*
   * if routing has sub-inv/loc. If not then we check item's default    *
   * subinv/loc.                                                        *
   * If nothing then error, else,                                       *
   * if item has then take those and put at the routing level.          *
   * If last op's values are not null, then                             *
   * if routing values are null we set those to these.                  *
   * But if routing values are NOT null then we check followin :        *
   * a. If sub-inv are same then we tell user that they are same and if *
   *    you want these to change to one of op's do so in the forms      *
   *    interface.                                                      *
   * b. If loc are the same , similar message.                          *
   **********************************************************************/

  PROCEDURE Set_WSM_Network_Sub_Loc
  ( p_routing_sequence_id        IN  NUMBER
  , p_end_id                     IN  NUMBER
  , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_status              IN OUT NOCOPY VARCHAR2
  )
  IS
    l_item_compl_subinv   varchar2(10);
    l_item_loc_id          NUMBER;
    err_code                       NUMBER;
    err_msg                        VARCHAR2(2000);
    l_completion_subinventory      VARCHAR2(10);
    l_rtg_comp_sub_inv             VARCHAR2(10);
    l_rtg_comp_sub_loc             NUMBER;
    l_inventory_location_id NUMBER;
    l_routing_sequence_id  NUMBER :=0;
    l_common_routing_sequence_id NUMBER :=0;
    l_cfm_routing_flag     NUMBER :=0;
    l_mesg_token_tbl       Error_Handler.Mesg_Token_Tbl_Type ;
    l_assembly_item_id     NUMBER :=0;
    l_org_id               NUMBER :=0;
    actual_end_id          NUMBER; --for bug3134027
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select routing_sequence_id, cfm_routing_flag,
           completion_subinventory, completion_locator_id,
           assembly_item_id , organization_id
    into   l_routing_sequence_id,l_cfm_routing_flag,
           l_rtg_comp_sub_inv , l_rtg_comp_sub_loc,
           l_assembly_item_id , l_org_id
    from bom_operational_routings where
         routing_sequence_id = p_routing_sequence_id;

    -- Get Common Routing Seq Id from System Info Rec.
    -- If the value is Null, set Common Routing Seq Id.
    l_common_routing_sequence_id := BOM_Rtg_Globals.Get_Common_Rtg_Seq_id ;

    IF l_common_routing_sequence_id IS NULL OR
       l_common_routing_sequence_id = FND_API.G_MISS_NUM THEN
      BEGIN
        SELECT  common_routing_sequence_id
        INTO    l_common_routing_sequence_id
        FROM    bom_operational_routings
        WHERE   routing_sequence_id = l_routing_sequence_id;
      END ;
      BOM_Rtg_Globals.Set_Common_Rtg_Seq_id
      ( p_common_rtg_seq_id => l_common_routing_sequence_id );
    END IF;

    IF nvl(l_cfm_routing_flag,2) = 3 THEN
    WSMPUTIL.FIND_ROUTING_END(l_common_routing_sequence_id, --for bug3134027
                             actual_end_id,
                             err_code,
                             err_msg);
     -- Get the Assembly item's completion sub-inv and loc_id
      SELECT wip_supply_subinventory, wip_supply_locator_id
      INTO   l_item_compl_subinv, l_item_loc_id
      FROM   mtl_system_items
      WHERE  organization_id = l_org_id
      AND    inventory_item_id =l_assembly_item_id;

      err_code := 0;
      err_msg := NULL;
      l_completion_subinventory := NULL;

      WSMPUTIL.GET_DEFAULT_SUB_LOC
      (l_org_id,
      l_common_routing_sequence_id,
      actual_end_id, --for bug3134027
      l_completion_subinventory,
      l_inventory_location_id,
      err_code,
      err_msg );

      IF err_msg IS NOT NULL THEN
      -- Last op doesn't have a completion sub-inv defined

        IF l_rtg_comp_sub_inv is NULL THEN
        -- No Manual Entry for comp. sub-inv

          IF l_item_compl_subinv IS NULL THEN
          -- Comple. sub-inv for assy item is also not defined
            Error_Handler.Add_Error_Token
            (  p_message_name   => NULL
             , p_message_text   => err_msg
             , p_mesg_token_tbl => l_mesg_token_tbl
             , x_mesg_token_tbl => l_mesg_token_tbl
            ) ;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_mesg_token_tbl := l_mesg_token_tbl;
            RETURN;
          ELSE
            l_rtg_comp_sub_inv := l_item_compl_subinv;
            l_rtg_comp_sub_loc := l_item_loc_id;
          END IF;
        END IF;
     ELSE    -- Last op HAS a completion sub-inv
       IF l_rtg_comp_sub_inv IS NULL THEN
       -- No Manual Entry for comp. sub-inv
         l_rtg_comp_sub_inv := l_completion_subinventory;
         l_rtg_comp_sub_loc := l_inventory_location_id;

       ELSIF l_completion_subinventory <>
             l_rtg_comp_sub_inv THEN
         Error_Handler.Add_Error_Token
         ( p_message_name   => 'BOM_RBO_WSM_NTWK_OP_RTG_DIF_SI'
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , p_message_type   => 'W'
         ) ;
       ELSIF nvl( l_inventory_location_id ,
                  l_rtg_comp_sub_loc ) <>
       l_rtg_comp_sub_loc  THEN
         Error_Handler.Add_Error_Token
         ( p_message_name   => 'BOM_RBO_WSM_NTWK_OP_RTG_DIF_LC'
         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
         , p_message_type   => 'W'
         ) ;
       END IF ;
     END IF;

     err_code := 0;
     err_msg := NULL;

     WSMPUTIL.UPDATE_SUB_LOC ( l_common_routing_sequence_id,
                               l_rtg_comp_sub_inv,
                               l_rtg_comp_sub_loc,
                               err_code ,
                               err_msg  ) ;

     IF err_msg IS NOT NULL THEN
       Error_Handler.Add_Error_Token
       (  p_message_name   => NULL
       , p_message_text   => err_msg
       , p_mesg_token_tbl => l_mesg_token_tbl
       , x_mesg_token_tbl => l_mesg_token_tbl
       ) ;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       RETURN;
     END IF;
   END IF;
   x_mesg_token_tbl := l_mesg_token_tbl;
  END Set_WSM_Network_Sub_Loc;


  -- bug:5060186 Added two procedures Copy_First_Last_Dis_Op and Copy_Operation
  -- to copy the first or last operation of the network if disabled.
 /*#
  * Procedure to copy the disabled first or last operation of the network.
  * @param p_routing_sequence_id Routing Sequence Id
  * @param x_Mesg_Token_Tbl Message Token Table
  * @rep:paraminfo { @rep:innertype Error_Handler.Mesg_Token_Tbl_Type }
  * @param x_Return_status Return Status
  * @rep:scope private
  * @rep:lifecycle active
  * @rep:displayname Copy First Last Disabled Operation
  */
  PROCEDURE Copy_First_Last_Dis_Op
  ( p_routing_sequence_id       IN  NUMBER
  , x_mesg_token_tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_return_status             IN OUT NOCOPY VARCHAR2
  )
  IS
    -- Get the First Operation of the network ordered by descending effectivity date
    CURSOR First_Op_Of_Nw( c_routing_sequence_id NUMBER ) IS
      SELECT bos.OPERATION_SEQUENCE_ID, bos.DISABLE_DATE
      FROM  BOM_OPERATION_SEQUENCES bos
      WHERE
          bos.IMPLEMENTATION_DATE IS NOT NULL
      AND bos.OPERATION_SEQ_NUM IN
            ( SELECT bos_first.OPERATION_SEQ_NUM
              FROM
                BOM_OPERATION_NETWORKS bon_from,
                BOM_OPERATION_NETWORKS bon_to,
                BOM_OPERATION_SEQUENCES bos_first
              WHERE
                  bon_from.FROM_OP_SEQ_ID = bos_first.OPERATION_SEQUENCE_ID
              AND bon_from.TO_OP_SEQ_ID = bon_to.FROM_OP_SEQ_ID
              AND bon_from.FROM_OP_SEQ_ID <> bon_to.FROM_OP_SEQ_ID
              AND bos_first.IMPLEMENTATION_DATE IS NOT NULL
              AND bos_first.ROUTING_SEQUENCE_ID = c_routing_sequence_id )
      AND bos.ROUTING_SEQUENCE_ID = c_routing_sequence_id
      ORDER BY bos.EFFECTIVITY_DATE DESC;

    -- Get the Last Operation of the network ordered by descending effectivity date
    CURSOR Last_Op_Of_Nw( c_routing_sequence_id NUMBER ) IS
      SELECT bos.OPERATION_SEQUENCE_ID, bos.DISABLE_DATE
      FROM  BOM_OPERATION_SEQUENCES bos
      WHERE
          bos.IMPLEMENTATION_DATE IS NOT NULL
      AND bos.OPERATION_SEQ_NUM IN
          ( SELECT bos_last.OPERATION_SEQ_NUM
            FROM
              BOM_OPERATION_NETWORKS bon_from,
              BOM_OPERATION_NETWORKS bon_to,
              BOM_OPERATION_SEQUENCES bos_last
            WHERE
                bon_to.TO_OP_SEQ_ID = bos_last.OPERATION_SEQUENCE_ID
            AND bon_from.TO_OP_SEQ_ID = bon_to.FROM_OP_SEQ_ID
            AND bon_to.TO_OP_SEQ_ID <> bon_from.TO_OP_SEQ_ID
            AND bos_last.IMPLEMENTATION_DATE IS NOT NULL
            AND bos_last.ROUTING_SEQUENCE_ID = c_routing_sequence_id )
      AND bos.ROUTING_SEQUENCE_ID = c_routing_sequence_id
      ORDER BY bos.EFFECTIVITY_DATE DESC;

  BEGIN
    IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
      Error_Handler.Write_Debug( ' Copying the First/Last operation if disabled');
    END IF;

    FOR l_operation IN First_Op_Of_Nw( p_routing_sequence_id )
    LOOP
      IF ( l_operation.DISABLE_DATE IS NOT NULL ) THEN
        -- First Operation is disabled, copy the operation
        Copy_Operation ( l_operation.OPERATION_SEQUENCE_ID );
        EXIT;
      ELSE
        -- First Operation is not disabled
        EXIT;
      END IF;
    END LOOP;

    FOR l_operation IN Last_Op_Of_Nw( p_routing_sequence_id )
    LOOP
      IF ( l_operation.DISABLE_DATE IS NOT NULL ) THEN
        -- Last Operation is disabled, copy the operation
        Copy_Operation ( l_operation.OPERATION_SEQUENCE_ID );
        EXIT;
      ELSE
        -- Last Operation is not disabled
        EXIT;
      END IF;
    END LOOP;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  END Copy_First_Last_Dis_Op;

 /*#
  * Procedure to copy the operation with new effectivity date as (disable date + 1 sec)
  * Also copy resources and alternate resources.
  *
  * @param p_operation_sequence_id Operation Sequence Id
  * @rep:scope private
  * @rep:lifecycle active
  * @rep:displayname Copy Operation
  */
  PROCEDURE Copy_Operation ( p_operation_sequence_id IN NUMBER )
  IS
    l_op_seq_id         NUMBER;
  BEGIN

    IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
      Error_Handler.Write_Debug( ' Copying operation ' || p_operation_sequence_id );
    END IF;

    -- Get a new operation sequence id
    SELECT  BOM_OPERATION_SEQUENCES_S.NEXTVAL
    INTO    l_op_seq_id
    FROM    DUAL;

    -- Copy the disabled operation with effectivity date as disable date plus one minute
    INSERT INTO BOM_OPERATION_SEQUENCES
                  (
                   OPERATION_SEQUENCE_ID,
                   ROUTING_SEQUENCE_ID,
                   OPERATION_SEQ_NUM,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   STANDARD_OPERATION_ID,
                   DEPARTMENT_ID,
                   OPERATION_LEAD_TIME_PERCENT,
                   MINIMUM_TRANSFER_QUANTITY,
                   COUNT_POINT_TYPE,
                   OPERATION_DESCRIPTION,
                   EFFECTIVITY_DATE,
                   DISABLE_DATE,
                   BACKFLUSH_FLAG,
                   OPTION_DEPENDENT_FLAG,
                   ATTRIBUTE_CATEGORY,
                   ATTRIBUTE1,
                   ATTRIBUTE2,
                   ATTRIBUTE3,
                   ATTRIBUTE4,
                   ATTRIBUTE5,
                   ATTRIBUTE6,
                   ATTRIBUTE7,
                   ATTRIBUTE8,
                   ATTRIBUTE9,
                   ATTRIBUTE10,
                   ATTRIBUTE11,
                   ATTRIBUTE12,
                   ATTRIBUTE13,
                   ATTRIBUTE14,
                   ATTRIBUTE15,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   OPERATION_TYPE,
                   REFERENCE_FLAG,
                   PROCESS_OP_SEQ_ID,
                   LINE_OP_SEQ_ID,
                   YIELD,
                   CUMULATIVE_YIELD,
                   REVERSE_CUMULATIVE_YIELD,
                   LABOR_TIME_CALC,
                   MACHINE_TIME_CALC,
                   TOTAL_TIME_CALC,
                   LABOR_TIME_USER,
                   MACHINE_TIME_USER,
                   TOTAL_TIME_USER,
                   NET_PLANNING_PERCENT,
                   INCLUDE_IN_ROLLUP,
                   OPERATION_YIELD_ENABLED,
                   CHANGE_NOTICE,
                   IMPLEMENTATION_DATE,
                   SHUTDOWN_TYPE,
                   LONG_DESCRIPTION,
                   LOWEST_ACCEPTABLE_YIELD,
                   USE_ORG_SETTINGS,
                   QUEUE_MANDATORY_FLAG,
                   RUN_MANDATORY_FLAG,
                   TO_MOVE_MANDATORY_FLAG,
                   SHOW_NEXT_OP_BY_DEFAULT,
                   SHOW_SCRAP_CODE,
                   SHOW_LOT_ATTRIB,
                   TRACK_MULTIPLE_RES_USAGE_DATES
                 )
                 SELECT
                  l_op_seq_id,
                  BOS.ROUTING_SEQUENCE_ID,
                  BOS.OPERATION_SEQ_NUM,
                  SYSDATE, --LAST_UPDATE_DATE
                  BOM_Rtg_Globals.Get_User_Id, --LAST_UPDATED_BY
                  SYSDATE, --CREATION_DATE
                  BOM_Rtg_Globals.Get_User_Id, --CREATED_BY
                  BOM_Rtg_Globals.Get_Login_Id, --LAST_UPDATE_LOGIN
                  BOS.STANDARD_OPERATION_ID,
                  BOS.DEPARTMENT_ID,
                  BOS.OPERATION_LEAD_TIME_PERCENT,
                  BOS.MINIMUM_TRANSFER_QUANTITY,
                  BOS.COUNT_POINT_TYPE,
                  BOS.OPERATION_DESCRIPTION,
                  BOS.DISABLE_DATE + (1/86400), -- EFFECTIVITY_DATE
                  NULL, -- DISABLE_DATE
                  BOS.BACKFLUSH_FLAG,
                  BOS.OPTION_DEPENDENT_FLAG,
                  BOS.ATTRIBUTE_CATEGORY,
                  BOS.ATTRIBUTE1,
                  BOS.ATTRIBUTE2,
                  BOS.ATTRIBUTE3,
                  BOS.ATTRIBUTE4,
                  BOS.ATTRIBUTE5,
                  BOS.ATTRIBUTE6,
                  BOS.ATTRIBUTE7,
                  BOS.ATTRIBUTE8,
                  BOS.ATTRIBUTE9,
                  BOS.ATTRIBUTE10,
                  BOS.ATTRIBUTE11,
                  BOS.ATTRIBUTE12,
                  BOS.ATTRIBUTE13,
                  BOS.ATTRIBUTE14,
                  BOS.ATTRIBUTE15,
                  BOM_Rtg_Globals.Get_Request_Id,
                  BOM_Rtg_Globals.Get_Prog_AppId,
                  BOM_Rtg_Globals.Get_Prog_Id,
                  SYSDATE, --PROGRAM_UPDATE_DATE
                  DECODE(BOS.OPERATION_TYPE, 4, 1, BOS.OPERATION_TYPE),
                  BOS.REFERENCE_FLAG,
                  BOS.PROCESS_OP_SEQ_ID,
                  BOS.LINE_OP_SEQ_ID,
                  BOS.YIELD,
                  BOS.CUMULATIVE_YIELD,
                  BOS.REVERSE_CUMULATIVE_YIELD,
                  BOS.LABOR_TIME_CALC,
                  BOS.MACHINE_TIME_CALC,
                  BOS.TOTAL_TIME_CALC,
                  BOS.LABOR_TIME_USER,
                  BOS.MACHINE_TIME_USER,
                  BOS.TOTAL_TIME_USER,
                  BOS.NET_PLANNING_PERCENT,
                  BOS.INCLUDE_IN_ROLLUP,
                  BOS.OPERATION_YIELD_ENABLED,
                  BOS.CHANGE_NOTICE,
                  SYSDATE,--IMPLEMENTATION_DATE
                  BOS.SHUTDOWN_TYPE,
                  BOS.LONG_DESCRIPTION,
                  BOS.LOWEST_ACCEPTABLE_YIELD,
                  BOS.USE_ORG_SETTINGS,
                  BOS.QUEUE_MANDATORY_FLAG,
                  BOS.RUN_MANDATORY_FLAG,
                  BOS.TO_MOVE_MANDATORY_FLAG,
                  BOS.SHOW_NEXT_OP_BY_DEFAULT,
                  BOS.SHOW_SCRAP_CODE,
                  BOS.SHOW_LOT_ATTRIB,
                  BOS.TRACK_MULTIPLE_RES_USAGE_DATES
                FROM
                    BOM_OPERATION_SEQUENCES BOS
                WHERE
                    BOS.OPERATION_SEQUENCE_ID = p_operation_sequence_id;

    -- Copy Operation Resources
    INSERT INTO BOM_OPERATION_RESOURCES
                  (
                     OPERATION_SEQUENCE_ID,
                     RESOURCE_SEQ_NUM,
                     RESOURCE_ID,
                     ACTIVITY_ID,
                     STANDARD_RATE_FLAG,
                     ASSIGNED_UNITS,
                     USAGE_RATE_OR_AMOUNT,
                     USAGE_RATE_OR_AMOUNT_INVERSE,
                     BASIS_TYPE,
                     SCHEDULE_FLAG,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_LOGIN,
                     RESOURCE_OFFSET_PERCENT,
                     AUTOCHARGE_TYPE,
                     ATTRIBUTE_CATEGORY,
                     ATTRIBUTE1,
                     ATTRIBUTE2,
                     ATTRIBUTE3,
                     ATTRIBUTE4,
                     ATTRIBUTE5,
                     ATTRIBUTE6,
                     ATTRIBUTE7,
                     ATTRIBUTE8,
                     ATTRIBUTE9,
                     ATTRIBUTE10,
                     ATTRIBUTE11,
                     ATTRIBUTE12,
                     ATTRIBUTE13,
                     ATTRIBUTE14,
                     ATTRIBUTE15,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE,
                     SCHEDULE_SEQ_NUM,
                     SUBSTITUTE_GROUP_NUM,
                     PRINCIPLE_FLAG,
                     SETUP_ID,
                     CHANGE_NOTICE,
                     ACD_TYPE,
                     ORIGINAL_SYSTEM_REFERENCE
                   )
                   SELECT
                     l_op_seq_id,
                     BOR.RESOURCE_SEQ_NUM,
                     BOR.RESOURCE_ID,
                     BOR.ACTIVITY_ID,
                     BOR.STANDARD_RATE_FLAG,
                     BOR.ASSIGNED_UNITS,
                     BOR.USAGE_RATE_OR_AMOUNT,
                     BOR.USAGE_RATE_OR_AMOUNT_INVERSE,
                     BOR.BASIS_TYPE,
                     BOR.SCHEDULE_FLAG,
                     SYSDATE, --LAST_UPDATE_DATE,
                     BOM_Rtg_Globals.Get_User_Id, --LAST_UPDATED_BY
                     SYSDATE, --CREATION_DATE
                     BOM_Rtg_Globals.Get_User_Id, --CREATED_BY
                     BOM_Rtg_Globals.Get_Login_Id, --LAST_UPDATE_LOGIN
                     BOR.RESOURCE_OFFSET_PERCENT,
                     BOR.AUTOCHARGE_TYPE,
                     BOR.ATTRIBUTE_CATEGORY,
                     BOR.ATTRIBUTE1,
                     BOR.ATTRIBUTE2,
                     BOR.ATTRIBUTE3,
                     BOR.ATTRIBUTE4,
                     BOR.ATTRIBUTE5,
                     BOR.ATTRIBUTE6,
                     BOR.ATTRIBUTE7,
                     BOR.ATTRIBUTE8,
                     BOR.ATTRIBUTE9,
                     BOR.ATTRIBUTE10,
                     BOR.ATTRIBUTE11,
                     BOR.ATTRIBUTE12,
                     BOR.ATTRIBUTE13,
                     BOR.ATTRIBUTE14,
                     BOR.ATTRIBUTE15,
                     BOM_Rtg_Globals.Get_Request_Id,
                     BOM_Rtg_Globals.Get_Prog_AppId,
                     BOM_Rtg_Globals.Get_Prog_Id,
                     SYSDATE, --PROGRAM_UPDATE_DATE
                     BOR.SCHEDULE_SEQ_NUM,
                     BOR.SUBSTITUTE_GROUP_NUM,
                     BOR.PRINCIPLE_FLAG,
                     BOR.SETUP_ID,
                     BOR.CHANGE_NOTICE,
                     BOR.ACD_TYPE,
                     BOR.ORIGINAL_SYSTEM_REFERENCE
                   FROM
                      BOM_OPERATION_RESOURCES BOR
                   WHERE
                      BOR.OPERATION_SEQUENCE_ID = p_operation_sequence_id;

    -- Copy Alternate Operation Resources
    INSERT INTO BOM_SUB_OPERATION_RESOURCES
                  (
                     OPERATION_SEQUENCE_ID,
                     SUBSTITUTE_GROUP_NUM,
                     RESOURCE_ID,
                     SCHEDULE_SEQ_NUM,
                     REPLACEMENT_GROUP_NUM,
                     ACTIVITY_ID,
                     STANDARD_RATE_FLAG,
                     ASSIGNED_UNITS,
                     USAGE_RATE_OR_AMOUNT,
                     USAGE_RATE_OR_AMOUNT_INVERSE,
                     BASIS_TYPE,
                     SCHEDULE_FLAG,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_LOGIN,
                     RESOURCE_OFFSET_PERCENT,
                     AUTOCHARGE_TYPE,
                     ATTRIBUTE_CATEGORY,
                     REQUEST_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_ID,
                     PROGRAM_UPDATE_DATE,
                     ATTRIBUTE1,
                     ATTRIBUTE2,
                     ATTRIBUTE3,
                     ATTRIBUTE4,
                     ATTRIBUTE5,
                     ATTRIBUTE6,
                     ATTRIBUTE7,
                     ATTRIBUTE8,
                     ATTRIBUTE9,
                     ATTRIBUTE10,
                     ATTRIBUTE11,
                     ATTRIBUTE12,
                     ATTRIBUTE13,
                     ATTRIBUTE14,
                     ATTRIBUTE15,
                     PRINCIPLE_FLAG,
                     SETUP_ID,
                     CHANGE_NOTICE,
                     ACD_TYPE,
                     ORIGINAL_SYSTEM_REFERENCE
                   )
                   SELECT
                     l_op_seq_id,
                     BSOR.SUBSTITUTE_GROUP_NUM,
                     BSOR.RESOURCE_ID,
                     BSOR.SCHEDULE_SEQ_NUM,
                     BSOR.REPLACEMENT_GROUP_NUM,
                     BSOR.ACTIVITY_ID,
                     BSOR.STANDARD_RATE_FLAG,
                     BSOR.ASSIGNED_UNITS,
                     BSOR.USAGE_RATE_OR_AMOUNT,
                     BSOR.USAGE_RATE_OR_AMOUNT_INVERSE,
                     BSOR.BASIS_TYPE,
                     BSOR.SCHEDULE_FLAG,
                     SYSDATE, --LAST_UPDATE_DATE,
                     BOM_Rtg_Globals.Get_User_Id, --LAST_UPDATED_BY
                     SYSDATE, --CREATION_DATE
                     BOM_Rtg_Globals.Get_User_Id, --CREATED_BY
                     BOM_Rtg_Globals.Get_Login_Id, --LAST_UPDATE_LOGIN
                     BSOR.RESOURCE_OFFSET_PERCENT,
                     BSOR.AUTOCHARGE_TYPE,
                     BSOR.ATTRIBUTE_CATEGORY,
                     BOM_Rtg_Globals.Get_Request_Id,
                     BOM_Rtg_Globals.Get_Prog_AppId,
                     BOM_Rtg_Globals.Get_Prog_Id,
                     SYSDATE, --PROGRAM_UPDATE_DATE
                     BSOR.ATTRIBUTE1,
                     BSOR.ATTRIBUTE2,
                     BSOR.ATTRIBUTE3,
                     BSOR.ATTRIBUTE4,
                     BSOR.ATTRIBUTE5,
                     BSOR.ATTRIBUTE6,
                     BSOR.ATTRIBUTE7,
                     BSOR.ATTRIBUTE8,
                     BSOR.ATTRIBUTE9,
                     BSOR.ATTRIBUTE10,
                     BSOR.ATTRIBUTE11,
                     BSOR.ATTRIBUTE12,
                     BSOR.ATTRIBUTE13,
                     BSOR.ATTRIBUTE14,
                     BSOR.ATTRIBUTE15,
                     BSOR.PRINCIPLE_FLAG,
                     BSOR.SETUP_ID,
                     BSOR.CHANGE_NOTICE,
                     BSOR.ACD_TYPE,
                     BSOR.ORIGINAL_SYSTEM_REFERENCE
                   FROM
                      BOM_SUB_OPERATION_RESOURCES BSOR
                   WHERE
                      BSOR.OPERATION_SEQUENCE_ID = p_operation_sequence_id;

  END Copy_Operation;


END BOM_Op_Network_UTIL;

/
