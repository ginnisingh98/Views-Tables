--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_OP_NETWORK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_OP_NETWORK" AS
/* $Header: BOMDONWB.pls 115.8 2002/11/21 04:37:47 djebar ship $*/
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMDONWB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Default_Op_Network
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00 Biao Zhang Initial Creation
--
****************************************************************************/
        G_Pkg_Name      VARCHAR2(30) := 'BOM_Default_Op_Network';
        g_token_tbl     Error_Handler.Token_Tbl_Type;



        FUNCTION Get_X_Coordinate( p_op_seq_id  IN NUMBER)
        RETURN NUMBER
        IS

           CURSOR l_x_cur( p_op_seq_id NUMBER)
           IS
               SELECT NVL(x_coordinate,0) x_coordinate
               FROM BOM_OPERATION_SEQUENCES
               WHERE operation_sequence_id = p_op_seq_id  ;

           l_x_coordinate NUMBER ;

        BEGIN

           FOR l_x_rec IN l_x_cur (p_op_seq_id )
           LOOP
                l_x_coordinate := l_x_rec.x_coordinate ;

           END LOOP ;


           RETURN l_x_coordinate ;

        END Get_X_Coordinate ;


        FUNCTION Get_Y_Coordinate( p_op_seq_id  IN NUMBER)
        RETURN NUMBER
        IS

           CURSOR l_y_cur( p_op_seq_id NUMBER)
           IS
               SELECT NVL(y_coordinate,0) y_coordinate
               FROM BOM_OPERATION_SEQUENCES
               WHERE operation_sequence_id = p_op_seq_id  ;

           l_y_coordinate NUMBER ;

        BEGIN

           FOR l_y_rec IN l_y_cur (p_op_seq_id )
           LOOP
                l_y_coordinate := l_y_rec.y_coordinate ;

           END LOOP ;


           RETURN l_y_coordinate ;

        END Get_Y_Coordinate ;


        PROCEDURE Get_Flex_Op_Network
          (  p_op_network_rec IN  Bom_Rtg_Pub.Op_Network_Rec_Type
           , x_op_network_rec IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
          )
        IS
        BEGIN

            --  In the future call Flex APIs for defaults
                x_op_network_rec := p_op_network_rec;

                IF p_op_network_rec.attribute_category =FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute_category := NULL;
                END IF;

                IF p_op_network_rec.attribute2 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute2  := NULL;
                END IF;

                IF p_op_network_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute3  := NULL;
                END IF;

                IF p_op_network_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute4  := NULL;
                END IF;

                IF p_op_network_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute5  := NULL;
                END IF;

                IF p_op_network_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute7  := NULL;
                END IF;

                IF p_op_network_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute8  := NULL;
                END IF;

                IF p_op_network_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute9  := NULL;
                END IF;

                IF p_op_network_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute11 := NULL;
                END IF;

                IF p_op_network_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute12 := NULL;
                END IF;

                IF p_op_network_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute13 := NULL;
                END IF;

                IF p_op_network_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute14 := NULL;
                END IF;

                IF p_op_network_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute15 := NULL;
                END IF;

                IF p_op_network_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute1  := NULL;
                END IF;

                IF p_op_network_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute6  := NULL;
                END IF;

                IF p_op_network_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute10 := NULL;
                END IF;

        END Get_Flex_Op_Network;



        /*********************************************************************
        * Procedure     : Attribute_Defaulting
        * Parameters IN : Operation Network exposed record
        *                 Operation Network unexposed record
        * Parameters OUT: Operation Network exposed record after defaulting
        *                 Operation Network unexposed record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Attribute Defaulting will default the necessary null
        *                 attribute with appropriate values.
        **********************************************************************/
        PROCEDURE Attribute_Defaulting
        (  p_op_network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_op_network_rec       IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
         , x_op_network_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
         )
        IS
             l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
             l_err_text  VARCHAR2(2000) ;
        BEGIN

                x_op_network_rec       := p_op_network_rec;
                x_op_network_unexp_rec := p_op_network_unexp_rec;
                x_return_status        := FND_API.G_RET_STS_SUCCESS;

                IF x_op_network_rec.connection_type= FND_API.G_MISS_NUM
                OR x_op_network_rec.connection_type IS NULL
                THEN
                   x_op_network_rec.connection_type := 1;
                END IF;

                IF x_op_network_rec.connection_type= 1 AND
                   ( x_op_network_rec.planning_percent IS NULL OR
                     x_op_network_rec.planning_percent = FND_API.G_MISS_NUM)
                THEN
                   x_op_network_rec.planning_percent := 100;
                END IF;


                IF x_op_network_rec.From_X_Coordinate = FND_API.G_MISS_NUM
                OR x_op_network_rec.From_X_Coordinate IS NULL
                THEN

                   -- Modified for Eam
                   -- x_op_network_rec.From_X_Coordinate := 0;
                   x_op_network_rec.From_X_Coordinate :=
                        Get_X_Coordinate(p_op_seq_id =>
                                         x_op_network_unexp_rec.from_op_seq_id) ;

                END IF;

                IF x_op_network_rec.To_X_Coordinate = FND_API.G_MISS_NUM
                OR x_op_network_rec.To_X_Coordinate IS NULL
                THEN
                   -- Modified for Eam
                   -- x_op_network_rec.To_X_Coordinate := 0;
                   x_op_network_rec.To_X_Coordinate :=
                        Get_X_Coordinate(p_op_seq_id =>
                                         x_op_network_unexp_rec.to_op_seq_id) ;

                END IF;

                IF x_op_network_rec.From_Y_Coordinate = FND_API.G_MISS_NUM
                OR x_op_network_rec.From_Y_Coordinate IS NULL
                THEN
                   -- Modified for Eam
                   -- x_op_network_rec.From_Y_Coordinate := 0;
                   x_op_network_rec.From_Y_Coordinate :=
                        Get_Y_Coordinate(p_op_seq_id =>
                                         x_op_network_unexp_rec.from_op_seq_id) ;

                END IF;

                IF x_op_network_rec.To_Y_Coordinate = FND_API.G_MISS_NUM
                OR x_op_network_rec.To_Y_Coordinate IS NULL
                THEN
                   -- Modified for Eam
                   -- x_op_network_rec.To_Y_Coordinate := 0;
                   x_op_network_rec.To_Y_Coordinate :=
                        Get_Y_Coordinate(p_op_seq_id =>
                                         x_op_network_unexp_rec.to_op_seq_id) ;

                END IF;

                Get_Flex_Op_Network( p_op_network_rec => x_op_network_rec
                                   , x_op_network_rec => x_op_network_rec
                                    );


         EXCEPTION
             WHEN OTHERS THEN
                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                ('Some unknown error in Attribute Defaulting . . .' || SQLERRM );
                END IF ;


                l_err_text := G_PKG_NAME || ' Default (Attr. Defaulting) '
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


        END Attribute_Defaulting;

        /*********************************************************************
        * Procedure     : Entity_Attribute_Defaulting
        * Parameters IN : Operation Network exposed record
        *                 Operation Network unexposed record
        * Parameters OUT: Operation Network exposed record after defaulting
        *                 Operation Network unexposed record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Entity Attribute Defaulting will default the necessary
        *                 entity level attribute with appropriate values.
        **********************************************************************/
        PROCEDURE Entity_Attribute_Defaulting
        (  p_op_network_rec          IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_op_network_unexp_rec    IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_op_network_rec          IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
         , x_op_network_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         )
        IS

             l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
             l_err_text          VARCHAR2(2000) ;
             l_token_tbl         Error_Handler.Token_Tbl_Type;


        BEGIN


                x_op_network_rec := p_op_network_rec;
                x_op_network_unexp_rec := p_op_network_unexp_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                -- operation type will be defaulted for validations
                -- this value indicate whether Lot, Process or Line Op
                IF x_op_network_rec.operation_type IS NULL OR
                   x_op_network_rec.operation_type = FND_API.G_MISS_NUM
                THEN
                   x_op_network_rec.operation_type := 1 ;
                END IF ;



                -- For eAM enhancement
                -- Maintenance Routing Network Defaulting
                -- Connection Type and Planning Type will not be used in
                -- Maintenace Routings.
                -- This defaulting logic set connection type to 1 and
                -- planning percent to 100%. If the user set other values
                -- then generate warning message.
                IF    x_op_network_rec.operation_type = 1
                AND   BOM_Rtg_Globals.Get_Eam_Item_Type =  BOM_Rtg_Globals.G_ASSET_ACTIVITY
                THEN

                    IF x_op_network_rec.connection_type <> 1
                    OR x_op_network_rec.planning_percent <> 100
                    THEN

                        x_op_network_rec.connection_type := 1;
                        x_op_network_rec.planning_percent := 100;


                        l_token_tbl(1).token_name  := 'FROM_OP_SEQ_NUMBER';
                        l_token_tbl(1).token_value :=
                                        x_op_network_rec.from_op_seq_number;
                        l_token_tbl(2).token_name  := 'TO_OP_SEQ_NUMBER';
                        l_token_tbl(2).token_value :=
                                        x_op_network_rec.to_op_seq_number;

                        Error_Handler.Add_Error_Token
                        ( p_message_name       => 'BOM_EAM_NWK_ATTR_IGNORED'
                        , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        , p_Token_Tbl          => l_Token_Tbl
                        , p_message_type       => 'W'
                        ) ;

IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
    Error_Handler.Write_Debug
    ('Setting default values in connection type and trnasition type for eAM Op Network');
END IF;


                    END IF;

                END IF ; -- eAM Operation Network Defaulting


                -- Followings are added to populate null to columns by MK 05/01.
                IF x_op_network_rec.original_system_reference = FND_API.G_MISS_CHAR
                THEN
                   x_op_network_rec.original_system_reference := NULL ;
                END IF;


                IF x_op_network_unexp_rec.new_from_op_seq_id = FND_API.G_MISS_NUM
                THEN
                    x_op_network_unexp_rec.new_from_op_seq_id := NULL ;
                END IF ;

                IF x_op_network_rec.new_from_op_seq_number  = FND_API.G_MISS_NUM
                THEN
                    x_op_network_rec.new_from_op_seq_number := NULL ;
                END IF ;

                IF x_op_network_rec.new_from_start_effective_date = FND_API.G_MISS_DATE
                THEN
                    x_op_network_rec.new_from_start_effective_date := NULL ;
                END IF ;


                IF x_op_network_unexp_rec.new_to_op_seq_id = FND_API.G_MISS_NUM
                THEN
                    x_op_network_unexp_rec.new_to_op_seq_id := NULL ;

                END IF ;

                IF x_op_network_rec.new_to_op_seq_number  = FND_API.G_MISS_NUM
                THEN
                    x_op_network_rec.new_to_op_seq_number := NULL ;
                END IF ;

                IF x_op_network_rec.new_to_start_effective_date = FND_API.G_MISS_DATE
                THEN
                    x_op_network_rec.new_to_start_effective_date := NULL ;
                END IF ;


                -- FlexFields
                IF x_op_network_rec.attribute_category = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute_category := NULL ;
                END IF;

                IF x_op_network_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute1 := NULL ;
                END IF;

                IF x_op_network_rec.attribute2  = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute2 := NULL ;
                END IF;

                IF x_op_network_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute3 := NULL ;
                END IF;

                IF x_op_network_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute4 := NULL ;
                END IF;

                IF x_op_network_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute5 := NULL ;
                END IF;

                IF x_op_network_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute6 := NULL ;
                END IF;

                IF x_op_network_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute7 := NULL ;
                END IF;

                IF x_op_network_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute8 := NULL ;
                END IF;

                IF x_op_network_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute9 := NULL ;
                END IF;

                IF x_op_network_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute10 := NULL ;
                END IF;

                IF x_op_network_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute11 := NULL ;
                END IF;

                IF x_op_network_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute12 := NULL ;
                END IF;

                IF x_op_network_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute13 := NULL ;
                END IF;

                IF x_op_network_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute14 := NULL ;
                END IF;

                IF x_op_network_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                        x_op_network_rec.attribute15 := NULL ;
                END IF;

                -- Return the status and message table.
                x_mesg_token_tbl := l_mesg_token_tbl ;


         EXCEPTION
             WHEN OTHERS THEN
                IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                ('Some unknown error in Entity Defaulting . . .' || SQLERRM );
                END IF ;


                l_err_text := G_PKG_NAME || ' Default (Entity Defaulting) '
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




        END Entity_Attribute_Defaulting;

        /******************************************************************
        * Procedure     : Populate_Null_Columns
        * Parameters IN : Operation Network Exposed column record
        *                 Operation Network Unexposed column record
        *                 Old Operation Network Exposed Column Record
        *                 Old Operation Network Unexposed Column Record
        * Parameters OUT: Operation Network Exposed column record after populating
        *                 Operation Network Unexposed Column record after  populating
        * Purpose       : This procedure will look at the columns that the user
        *                 has not filled in and will assign those columns a
        *                 value from the old record.
        *                 This procedure is not called CREATE
        ********************************************************************/
        PROCEDURE Populate_Null_Columns
        (  p_op_network_rec       IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_op_network_unexp_rec IN  Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , p_old_op_network_rec   IN  Bom_Rtg_Pub.Op_Network_Rec_Type
         , p_old_op_network_unexp_rec IN Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
         , x_op_network_rec       IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Rec_Type
         , x_op_network_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        )
        IS
        BEGIN


                x_op_network_rec := p_op_network_rec;
                x_op_network_unexp_rec := p_op_network_unexp_rec;

                IF p_op_network_rec.Connection_Type IS NULL OR
                   p_op_network_rec.Connection_Type = FND_API.G_MISS_NUM
                THEN

                        x_op_network_rec.Connection_Type:=
                                p_old_op_network_rec.Connection_Type ;

                END IF;

                IF p_op_network_rec.Planning_Percent IS NULL OR
                   p_op_network_rec.Planning_Percent = FND_API.G_MISS_NUM
                THEN

                        x_op_network_rec.Planning_Percent :=
                                p_old_op_network_rec.Planning_Percent ;

                END IF;

                IF p_op_network_rec.From_X_Coordinate IS NULL OR
                   p_op_network_rec.From_X_Coordinate = FND_API.G_MISS_NUM
                THEN

                        x_op_network_rec.From_X_Coordinate :=
                                p_old_op_network_rec.From_X_Coordinate ;

                END IF;

                IF p_op_network_rec.From_Y_Coordinate IS NULL OR
                   p_op_network_rec.From_Y_Coordinate = FND_API.G_MISS_NUM
                THEN

                        x_op_network_rec.From_Y_Coordinate :=
                                p_old_op_network_rec.From_Y_Coordinate ;

                END IF;

                IF p_op_network_rec.To_X_Coordinate IS NULL OR
                   p_op_network_rec.To_X_Coordinate = FND_API.G_MISS_NUM
                THEN

                        x_op_network_rec.To_X_Coordinate :=
                                p_old_op_network_rec.To_X_Coordinate ;

                END IF;

                IF p_op_network_rec.To_Y_Coordinate IS NULL OR
                   p_op_network_rec.To_Y_Coordinate = FND_API.G_MISS_NUM
                THEN

                        x_op_network_rec.To_Y_Coordinate :=
                                p_old_op_network_rec.To_Y_Coordinate ;

                END IF;


                IF p_op_network_rec.attribute_category IS NULL OR
                   p_op_network_rec.attribute_category = FND_API.G_MISS_CHAR
                THEN
                        x_op_network_rec.attribute_category :=
                                p_old_op_network_rec.attribute_category;

                END IF;

                IF p_op_network_rec.attribute1 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute1 IS NULL
                THEN
                        x_op_network_rec.attribute1  :=
                                p_old_op_network_rec.attribute1;
                END IF;

                IF p_op_network_rec.attribute2 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute2 IS NULL
                THEN
                        x_op_network_rec.attribute2  :=
                                p_old_op_network_rec.attribute2;
                END IF;

                IF p_op_network_rec.attribute3 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute3 IS NULL
                THEN
                        x_op_network_rec.attribute3  :=
                                p_old_op_network_rec.attribute3;
                END IF;

                IF p_op_network_rec.attribute4 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute4 IS NULL
                THEN
                        x_op_network_rec.attribute4  :=
                                p_old_op_network_rec.attribute4;
                END IF;

                IF p_op_network_rec.attribute5 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute5 IS NULL
                THEN
                        x_op_network_rec.attribute5  :=
                                p_old_op_network_rec.attribute5;
                END IF;

                IF p_op_network_rec.attribute6 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute6 IS NULL
                THEN
                        x_op_network_rec.attribute6  :=
                                p_old_op_network_rec.attribute6;
                END IF;

                IF p_op_network_rec.attribute7 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute7 IS NULL
                THEN
                        x_op_network_rec.attribute7  :=
                                p_old_op_network_rec.attribute7;
                END IF;

                IF p_op_network_rec.attribute8 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute8 IS NULL
                THEN
                        x_op_network_rec.attribute8  :=
                                p_old_op_network_rec.attribute8;
                END IF;

                IF p_op_network_rec.attribute9 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute9 IS NULL
                THEN
                        x_op_network_rec.attribute9  :=
                                p_old_op_network_rec.attribute9;
                END IF;

                IF p_op_network_rec.attribute10 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute10 IS NULL
                THEN
                        x_op_network_rec.attribute10 :=
                                p_old_op_network_rec.attribute10;
                END IF;

                IF p_op_network_rec.attribute11 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute11 IS NULL
                THEN
                        x_op_network_rec.attribute11 :=
                                p_old_op_network_rec.attribute11;
                END IF;

                IF p_op_network_rec.attribute12 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute12 IS NULL
                THEN
                        x_op_network_rec.attribute12 :=
                                p_old_op_network_rec.attribute12;
                END IF;

                IF p_op_network_rec.attribute13 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute13 IS NULL
                THEN
                        x_op_network_rec.attribute13 :=
                                p_old_op_network_rec.attribute13;
                END IF;

                IF p_op_network_rec.attribute14 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute14 IS NULL
                THEN
                        x_op_network_rec.attribute14 :=
                                p_old_op_network_rec.attribute14;
                END IF;

                IF p_op_network_rec.attribute15 = FND_API.G_MISS_CHAR OR
                   p_op_network_rec.attribute15 IS NULL
                THEN
                        x_op_network_rec.attribute15 :=
                                p_old_op_network_rec.attribute15;
                END IF;

                --
                -- Get the unexposed columns from the database and return
                -- them as the unexposed columns for the current record.
                --
                -- x_op_network_unexp_rec.routing_sequence_id :=
                --         p_old_op_network_unexp_rec.routing_sequence_id;


        END Populate_Null_Columns;



END BOM_Default_Op_Network;

/
