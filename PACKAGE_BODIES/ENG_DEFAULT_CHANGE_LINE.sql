--------------------------------------------------------
--  DDL for Package Body ENG_DEFAULT_CHANGE_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_DEFAULT_CHANGE_LINE" AS
/* $Header: ENGDCHLB.pls 115.8 2003/09/07 19:17:56 mxgovind ship $ */


    G_Pkg_Name      VARCHAR2(30) := 'ENG_Default_Change_Line';


    /*******************************************************************
    * Following are all get functions which will be used by the attribute
    * defaulting procedure. Each column needing to be defaulted has one GET
    * function.
    ********************************************************************/

    -- Chagne Line Id
    FUNCTION Get_Change_Line_Id RETURN NUMBER
    IS
       CURSOR l_cl_seq_cur IS
       SELECT ENG_Change_Lines_S.NEXTVAL CL_Id
       FROM SYS.DUAL ;
    BEGIN
       FOR l_cl_seq_rec IN l_cl_seq_cur LOOP
          RETURN l_cl_seq_rec.CL_Id ;
       END LOOP ;
       RETURN NULL ;

    END Get_Change_Line_Id ;

    /* Comment Out
    PROCEDURE Get_Flex_Change_Line
    (  p_change_line_rec        IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , x_change_line_rec        OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
    )
    IS
        l_change_line_rec      Eng_Eco_Pub.Change_Line_Rec_Type ;

    BEGIN
       --  Initialize change line exp and unexp record
       l_change_line_rec  := p_change_line_rec ;

        --  In the future call Flex APIs for defaults

        IF l_change_line_rec.attribute_category = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute_category := NULL;
        END IF;

        IF l_change_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute1 := NULL;
        END IF;

        IF l_change_line_rec.attribute2 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute2 := NULL;
        END IF;

        IF l_change_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute3 := NULL;
        END IF;

        IF l_change_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute4 := NULL;
        END IF;

        IF l_change_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute5 := NULL;
        END IF;

        IF l_change_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute6 := NULL;
        END IF;

        IF l_change_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute7 := NULL;
        END IF;

        IF l_change_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute8 := NULL;
        END IF;

        IF l_change_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute9 := NULL;
        END IF;

        IF l_change_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute10 := NULL;
        END IF;

        IF l_change_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute11 := NULL;
        END IF;

        IF l_change_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute12 := NULL;
        END IF;

        IF l_change_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute13 := NULL;
        END IF;

        IF l_change_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute14 := NULL;
        END IF;

        IF l_change_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN
            l_change_line_rec.attribute15 := NULL;
        END IF;

        x_change_line_rec := l_change_line_rec ;

    END Get_Flex_Change Line ;
    */


    /********************************************************************
    * Procedure : Attribute_Defaulting for Common
    * Parameters IN : Chagne Line exposed column record
    *                 Chagne Line unexposed column record
    * Parameters OUT: Chagne Line exposed column record after defaulting
    *                 Chagne Line unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Attribute defaulting proc. defualts columns to
    *             appropriate values. Defualting will happen for
    *             exposed as well as unexposed columns.
    *********************************************************************/
    PROCEDURE Attribute_Defaulting
    (  p_change_line_rec           IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec     IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_change_line_rec           IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
     , x_change_line_unexp_rec     IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_mesg_token_tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status             OUT NOCOPY VARCHAR2
    )

    IS

        l_change_line_rec        Eng_Eco_Pub.Change_Line_Rec_Type ;
        l_change_line_unexp_rec  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type ;

        l_return_status          VARCHAR2(1);
        l_temp_return_status     VARCHAR2(1);
        l_err_text               VARCHAR2(2000) ;
        l_Mesg_Token_Tbl         Error_Handler.Mesg_Token_Tbl_Type;
        l_Temp_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;


    BEGIN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Within the Change Line Attr. Defaulting...') ;
END IF ;

            l_return_status := FND_API.G_RET_STS_SUCCESS ;
            x_return_status := FND_API.G_RET_STS_SUCCESS ;

            --  Initialize change line  exp and unexp record
            l_change_line_rec  := p_change_line_rec ;
            l_change_line_unexp_rec   := p_change_line_unexp_rec ;


            --
            -- Default Change Line Id
            --
            IF l_change_line_unexp_rec.change_line_id IS NULL OR
               l_change_line_unexp_rec.change_line_id = FND_API.G_MISS_NUM
            THEN
                l_change_line_unexp_rec.change_line_id :=
                Get_Change_Line_Id ;
            END IF ;

            IF l_change_line_unexp_rec.status_code IS NULL OR
               l_change_line_unexp_rec.status_code = FND_API.G_MISS_CHAR
            THEN
                l_change_line_unexp_rec.status_code := '1';
            END IF ;
            --Added as   Approval_Status_Type is a mandatory column
             IF l_change_line_unexp_rec.Approval_Status_Type IS NULL OR
               l_change_line_unexp_rec.Approval_Status_Type = FND_API.G_MISS_CHAR
            THEN
                l_change_line_unexp_rec.Approval_Status_Type := 1;
            END IF ;




            -- IF  l_change_line_rec.attribute_category = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute1  = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute2  = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute3  = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute4  = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute5  = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute6  = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute7  = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute8  = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute9  = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute10 = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute11 = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute12 = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute13 = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute14 = FND_API.G_MISS_CHAR
            -- OR  l_change_line_rec.attribute15 = FND_API.G_MISS_CHAR
            -- THEN
            --
                --   Get_Flex_Change_Line (  p_change_line_rec  => l_change_line_rec
                --                         , x_change_line_rec  => l_change_line_rec ) ;
            --  END IF;

            x_change_line_rec        := l_change_line_rec ;
            x_change_line_unexp_rec  := l_change_line_unexp_rec ;
            x_return_status          := l_return_status ;
            x_mesg_token_tbl         := l_mesg_token_tbl ;

IF BOM_Globals.Get_Debug = 'Y' THEN
     Error_Handler.Write_Debug('Getting out of Change Line Attribute Defualting...');
END IF ;


    EXCEPTION
       WHEN OTHERS THEN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Attribute Defaulting . . .' || SQLERRM );
END IF ;


          l_err_text := G_PKG_NAME || ' Default (Attr. Defaulting) '
                                || substrb(SQLERRM,1,200);
          -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

          -- Return the status and message table.
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mesg_token_tbl := l_mesg_token_tbl ;


    END Attribute_Defaulting ;



    /*******************************************************************
    * Procedure : Populate_Null_Columns
    * Parameters IN : Chagne Line exposed column record
    *                 Chagne Line unexposed column record
    *                 Old Chagne Line exposed column record
    *                 Old Chagne Line unexposed column record
    * Parameters OUT: Chagne Line exposed column record after populating null columns
    *                 Chagne Line unexposed column record after populating null columns
    * Purpose   : Complete record will compare the database record with
    *             the user given record and will complete the user
    *             record with values from the database record, for all
    *             columns that the user has left NULL.
    ********************************************************************/
    PROCEDURE Populate_Null_Columns
    (  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , p_old_change_line_rec         IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_old_change_line_unexp_rec   IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_change_line_rec             IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
     , x_change_line_unexp_rec       IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
    )
    IS

       l_change_line_rec             Eng_Eco_Pub.Change_Line_Rec_Type ;
       l_change_line_unexp_rec       Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type ;

    BEGIN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                 ('Within the Change Line Populate null columns...') ;
END IF ;

            --  Initialize change line exp and unexp record
            l_change_line_rec         := p_change_line_rec ;
            l_change_line_unexp_rec   := p_change_line_unexp_rec ;


-- Exposed Column
IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                 ('Populate null exposed columns......') ;
END IF ;


            IF l_change_line_rec.Description IS NULL
            THEN
               l_change_line_rec.Description
               := p_old_change_line_rec.Description ;
            END IF ;

            IF l_change_line_rec.Sequence_Number IS NULL
            THEN
               l_change_line_rec.Sequence_Number
               := p_old_change_line_rec.Sequence_Number ;
            END IF ;

            IF l_change_line_rec.Need_By_Date IS NULL
            THEN
               l_change_line_rec.Need_By_Date
               := p_old_change_line_rec.Need_By_Date;
            END IF ;

            IF l_change_line_rec.Scheduled_Date IS NULL
            THEN
               l_change_line_rec.Scheduled_Date
               := p_old_change_line_rec.Scheduled_Date;
            END IF ;

            IF l_change_line_rec.Implementation_Date IS NULL
            THEN
               l_change_line_rec.Implementation_Date
               := p_old_change_line_rec.Implementation_Date;
            END IF ;

            IF l_change_line_rec.Cancelation_Date IS NULL
            THEN
               l_change_line_rec.Cancelation_Date
               := p_old_change_line_rec.Cancelation_Date;
            END IF ;

            IF l_change_line_rec.Original_System_Reference IS NULL
            THEN
               l_change_line_rec.Original_System_Reference
               := p_old_change_line_rec.Original_System_Reference ;
            END IF ;


            /* Comment Out
            -- Populate Null Columns for FlexFields
            IF l_change_line_rec.attribute_category IS NULL THEN
                l_change_line_rec.attribute_category :=
                p_old_change_line_rec.attribute_category;
            END IF;

            IF l_change_line_rec.attribute1 IS NULL THEN
                l_change_line_rec.attribute1 :=
                p_old_change_line_rec.attribute1;
            END IF;

            IF l_change_line_rec.attribute2  IS NULL THEN
                l_change_line_rec.attribute2 :=
                p_old_change_line_rec.attribute2;
            END IF;

            IF l_change_line_rec.attribute3 IS NULL THEN
                l_change_line_rec.attribute3 :=
                p_old_change_line_rec.attribute3;
            END IF;

            IF l_change_line_rec.attribute4 IS NULL THEN
                l_change_line_rec.attribute4 :=
                p_old_change_line_rec.attribute4;
            END IF;

            IF l_change_line_rec.attribute5 IS NULL THEN
                l_change_line_rec.attribute5 :=
                p_old_change_line_rec.attribute5;
            END IF;

            IF l_change_line_rec.attribute6 IS NULL THEN
                l_change_line_rec.attribute6 :=
                p_old_change_line_rec.attribute6;
            END IF;

            IF l_change_line_rec.attribute7 IS NULL THEN
                l_change_line_rec.attribute7 :=
                p_old_change_line_rec.attribute7;
            END IF;

            IF l_change_line_rec.attribute8 IS NULL THEN
                l_change_line_rec.attribute8 :=
                p_old_change_line_rec.attribute8;
            END IF;

            IF l_change_line_rec.attribute9 IS NULL THEN
                l_change_line_rec.attribute9 :=
                p_old_change_line_rec.attribute9;
            END IF;

            IF l_change_line_rec.attribute10 IS NULL THEN
                l_change_line_rec.attribute10 :=
                p_old_change_line_rec.attribute10;
            END IF;

            IF l_change_line_rec.attribute11 IS NULL THEN
                l_change_line_rec.attribute11 :=
                p_old_change_line_rec.attribute11;
            END IF;

            IF l_change_line_rec.attribute12 IS NULL THEN
                l_change_line_rec.attribute12 :=
                p_old_change_line_rec.attribute12;
            END IF;

            IF l_change_line_rec.attribute13 IS NULL THEN
                l_change_line_rec.attribute13 :=
                p_old_change_line_rec.attribute13;
            END IF;

            IF l_change_line_rec.attribute14 IS NULL THEN
                l_change_line_rec.attribute14 :=
                p_old_change_line_rec.attribute14;
            END IF;

            IF l_change_line_rec.attribute15 IS NULL THEN
                l_change_line_rec.attribute15 :=
                p_old_change_line_rec.attribute15;
            END IF;

            */

            --
            -- Also copy the Unexposed Columns from Database to New record
            --
IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Populate Null Unexposed columns......') ;
END IF ;


           IF l_change_line_unexp_rec.Change_Line_Id IS NULL OR
              l_change_line_unexp_rec.Change_Line_Id = FND_API.G_MISS_NUM
           THEN
              l_change_line_unexp_rec.Change_Line_Id
              := p_old_change_line_unexp_rec.Change_Line_Id ;
           END IF ;

           IF l_change_line_unexp_rec.Change_Type_Id IS NULL OR
              l_change_line_unexp_rec.Change_Type_Id = FND_API.G_MISS_NUM
           THEN
              l_change_line_unexp_rec.Change_Type_Id
              := p_old_change_line_unexp_rec.Change_Type_Id ;
           END IF ;

           IF l_change_line_unexp_rec.Status_Code IS NULL OR
              l_change_line_unexp_rec.Status_Code = FND_API.G_MISS_CHAR
           THEN
              l_change_line_unexp_rec.Status_Code
              := p_old_change_line_unexp_rec.Status_Code;
           END IF ;

           IF l_change_line_unexp_rec.Assignee_Id IS NULL OR
              l_change_line_unexp_rec.Assignee_Id = FND_API.G_MISS_NUM
           THEN
              l_change_line_unexp_rec.Assignee_Id
              := p_old_change_line_unexp_rec.Assignee_Id ;
           END IF ;

           IF l_change_line_unexp_rec.Object_Name IS NULL OR
              l_change_line_unexp_rec.Object_Name = FND_API.G_MISS_CHAR
           THEN
              l_change_line_unexp_rec.Object_Name
              := p_old_change_line_unexp_rec.Object_Name ;
           END IF ;

           IF l_change_line_unexp_rec.Pk1_Value IS NULL OR
              l_change_line_unexp_rec.Pk1_Value = FND_API.G_MISS_NUM
           THEN
              l_change_line_unexp_rec.Pk1_Value
              := p_old_change_line_unexp_rec.Pk1_Value ;
           END IF ;

           IF l_change_line_unexp_rec.Pk2_Value IS NULL OR
              l_change_line_unexp_rec.Pk2_Value = FND_API.G_MISS_NUM
           THEN
              l_change_line_unexp_rec.Pk2_Value
              := p_old_change_line_unexp_rec.Pk2_Value ;
           END IF ;

           IF l_change_line_unexp_rec.Pk3_Value IS NULL OR
              l_change_line_unexp_rec.Pk3_Value = FND_API.G_MISS_NUM
           THEN
              l_change_line_unexp_rec.Pk3_Value
              := p_old_change_line_unexp_rec.Pk3_Value ;
           END IF ;

           IF l_change_line_unexp_rec.Pk4_Value IS NULL OR
              l_change_line_unexp_rec.Pk4_Value = FND_API.G_MISS_NUM
           THEN
              l_change_line_unexp_rec.Pk4_Value
              := p_old_change_line_unexp_rec.Pk4_Value ;
           END IF ;

           IF l_change_line_unexp_rec.Pk5_Value IS NULL OR
              l_change_line_unexp_rec.Pk5_Value = FND_API.G_MISS_NUM
           THEN
              l_change_line_unexp_rec.Pk5_Value
              := p_old_change_line_unexp_rec.Pk5_Value ;
           END IF ;

           --  Return change line exp and unexp record
           x_change_line_rec         := l_change_line_rec ;
           x_change_line_unexp_rec   := l_change_line_unexp_rec ;

    END Populate_Null_Columns;


    /********************************************************************
    * Procedure : Entity_Defaulting
    * Parameters IN : Chagne Line exposed column record
    *                 Chagne Line unexposed column record
    * Parameters OUT: Chagne Line exposed column record after defaulting
    *                 Change Line unexposed column record after defaulting
    *                 Return Status
    *                 Message Token Table
    * Purpose   : Entity defaulting proc. defualts columns to
    *             appropriate values. Defualting will happen for
    *             exposed as well as unexposed columns.
    *********************************************************************/
    PROCEDURE Entity_Defaulting
    (  p_change_line_rec           IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec     IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , p_old_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_old_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_change_line_rec           IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
     , x_change_line_unexp_rec     IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_mesg_token_tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status             OUT NOCOPY VARCHAR2
    )

    IS

        l_change_line_rec           Eng_Eco_Pub.Change_Line_Rec_Type ;
        l_change_line_unexp_rec     Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type ;

        l_return_status     VARCHAR2(1);
        l_err_text          VARCHAR2(2000) ;
        l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;


    BEGIN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
            ('Within the Change Line Entity Defaulting...') ;
END IF ;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        --  Initialize change line exp and unexp record
        l_change_line_rec         := p_change_line_rec ;
        l_change_line_unexp_rec   := p_change_line_unexp_rec ;


        IF l_change_line_rec.Description = FND_API.G_MISS_CHAR
        THEN
            l_change_line_rec.Description := NULL ;
        END IF ;

        IF l_change_line_unexp_rec.Assignee_Id = FND_API.G_MISS_NUM
        THEN
           l_change_line_unexp_rec.Assignee_Id := NULL ;
        END IF;

        IF l_change_line_unexp_rec.Object_Name = FND_API.G_MISS_CHAR
        THEN
           l_change_line_unexp_rec.Object_Name := NULL ;
        END IF;

        IF  l_change_line_unexp_rec.Pk1_Value = FND_API.G_MISS_CHAR
        THEN
               l_change_line_unexp_rec.Pk1_Value := NULL ;
        END IF ;

        IF  l_change_line_unexp_rec.Pk2_Value = FND_API.G_MISS_CHAR
        THEN
               l_change_line_unexp_rec.Pk2_Value := NULL ;
        END IF ;

        IF  l_change_line_unexp_rec.Pk3_Value = FND_API.G_MISS_CHAR
        THEN
               l_change_line_unexp_rec.Pk3_Value := NULL ;
        END IF ;

        IF  l_change_line_unexp_rec.Pk4_Value = FND_API.G_MISS_CHAR
        THEN
               l_change_line_unexp_rec.Pk4_Value := NULL ;
        END IF ;

        IF  l_change_line_unexp_rec.Pk5_Value = FND_API.G_MISS_CHAR
        THEN
               l_change_line_unexp_rec.Pk5_Value := NULL ;
        END IF ;


        /*
        -- FlexFields
        IF l_change_line_rec.attribute_category = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute_category := NULL ;
        END IF;

        IF l_change_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute1 := NULL ;
        END IF;

        IF l_change_line_rec.attribute2  = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute2 := NULL ;
        END IF;

        IF l_change_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute3 := NULL ;
        END IF;

        IF l_change_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute4 := NULL ;
        END IF;

        IF l_change_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute5 := NULL ;
        END IF;

        IF l_change_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute6 := NULL ;
        END IF;

        IF l_change_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute7 := NULL ;
        END IF;

        IF l_change_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute8 := NULL ;
        END IF;

        IF l_change_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute9 := NULL ;
        END IF;

        IF l_change_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute10 := NULL ;
        END IF;

        IF l_change_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute11 := NULL ;
        END IF;

        IF l_change_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute12 := NULL ;
        END IF;

        IF l_change_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute13 := NULL ;
        END IF;

        IF l_change_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute14 := NULL ;
        END IF;

        IF l_change_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                l_change_line_rec.attribute15 := NULL ;
        END IF;
        */

        -- Return the status and message table.
        x_return_status  := l_return_status ;
        x_mesg_token_tbl := l_mesg_token_tbl ;

        -- Return the change line records after entity defaulting.
        x_change_line_rec         := l_change_line_rec ;
        x_change_line_unexp_rec   := l_change_line_unexp_rec ;


    EXCEPTION
       WHEN OTHERS THEN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
          ('Some unknown error in Entity Defaulting . . .' || SQLERRM );
END IF ;

          l_err_text := G_PKG_NAME || ' Defaulting (Entity Defaulting) '
                                || substrb(SQLERRM,1,200);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

          -- Return the status and message table.
          x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_mesg_token_tbl := l_mesg_token_tbl ;

    END Entity_Defaulting ;


END ENG_Default_Change_Line ;

/
