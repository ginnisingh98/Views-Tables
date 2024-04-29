--------------------------------------------------------
--  DDL for Package Body EAM_OP_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OP_DEFAULT_PVT" AS
/* $Header: EAMVOPDB.pls 120.0.12000000.2 2007/05/09 13:26:54 amourya ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVOPDB.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_OP_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_OP_DEFAULT_PVT';


        /********************************************************************
        * Procedure     : get_flex_eam_op
        * Return        : NUMBER
        **********************************************************************/


        PROCEDURE get_flex_eam_op
          (  p_eam_op_rec IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
           , x_eam_op_rec OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_rec_type
          )
        IS
        BEGIN

            --  In the future call Flex APIs for defaults
                x_eam_op_rec := p_eam_op_rec;

                IF p_eam_op_rec.attribute_category =FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute_category := NULL;
                END IF;

                IF p_eam_op_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute1  := NULL;
                END IF;

                IF p_eam_op_rec.attribute2 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute2  := NULL;
                END IF;

                IF p_eam_op_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute3  := NULL;
                END IF;

                IF p_eam_op_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute4  := NULL;
                END IF;

                IF p_eam_op_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute5  := NULL;
                END IF;

                IF p_eam_op_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute6  := NULL;
                END IF;

                IF p_eam_op_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute7  := NULL;
                END IF;

                IF p_eam_op_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute8  := NULL;
                END IF;

                IF p_eam_op_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute9  := NULL;
                END IF;

                IF p_eam_op_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute10 := NULL;
                END IF;

                IF p_eam_op_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute11 := NULL;
                END IF;

                IF p_eam_op_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute12 := NULL;
                END IF;

                IF p_eam_op_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute13 := NULL;
                END IF;

                IF p_eam_op_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute14 := NULL;
                END IF;

                IF p_eam_op_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_rec.attribute15 := NULL;
                END IF;

        END get_flex_eam_op;


        /*********************************************************************
        * Procedure     : Attribute_Defaulting
        * Parameters IN : Operation record
        * Parameters OUT NOCOPY: Operation record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Attribute Defaulting will default the necessary null
        *                 attribute with appropriate values.
        **********************************************************************/

        PROCEDURE Attribute_Defaulting
        (  p_eam_op_rec              IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_eam_op_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         )
        IS
          l_eam_op_rec               EAM_PROCESS_WO_PUB.eam_op_rec_type;
        BEGIN

                x_eam_op_rec := p_eam_op_rec;
--                x_eam_op_rec := p_eam_op_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                IF p_eam_op_rec.count_point_type IS NULL OR
                   p_eam_op_rec.count_point_type = FND_API.G_MISS_NUM THEN
                  x_eam_op_rec.count_point_type := 1;
                END IF;

                IF p_eam_op_rec.backflush_flag IS NULL OR
                   p_eam_op_rec.backflush_flag = FND_API.G_MISS_NUM THEN
                  x_eam_op_rec.backflush_flag := 2;
                END IF;

                IF p_eam_op_rec.minimum_transfer_quantity IS NULL OR
                   p_eam_op_rec.minimum_transfer_quantity = FND_API.G_MISS_NUM THEN
                  x_eam_op_rec.minimum_transfer_quantity := 0;
                END IF;

                l_eam_op_rec := x_eam_op_rec;
                get_flex_eam_op
                (  p_eam_op_rec => x_eam_op_rec
                 , x_eam_op_rec => l_eam_op_rec
                );
                x_eam_op_rec := l_eam_op_rec;

             EXCEPTION
                WHEN OTHERS THEN
                     EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                     (  p_message_name       => NULL
                      , p_message_text       => G_PKG_NAME || SQLERRM
                      , x_mesg_token_Tbl     => x_mesg_token_tbl
                     );

                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Attribute_Defaulting;


        /******************************************************************
        * Procedure     : Populate_Null_Columns
        * Parameters IN : Operation column record
        *                 Old Operation Column Record
        * Parameters OUT NOCOPY: Operation column record after populating
        * Purpose       : This procedure will look at the columns that the user
        *                 has not filled in and will assign those columns a
        *                 value from the old record.
        *                 This procedure is not called for CREATE
        ********************************************************************/
        PROCEDURE Populate_Null_Columns
        (  p_eam_op_rec           IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
         , p_old_eam_op_rec       IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_eam_op_rec           OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_rec_type
        )
        IS
        BEGIN
                x_eam_op_rec := p_eam_op_rec;
                x_eam_op_rec := p_eam_op_rec;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing null columns prior update'); END IF;


                IF p_eam_op_rec.operation_sequence_id IS NULL OR
                   p_eam_op_rec.operation_sequence_id = FND_API.G_MISS_NUM
                THEN
                    x_eam_op_rec.operation_sequence_id := p_old_eam_op_rec.operation_sequence_id;
                END IF;

                IF p_eam_op_rec.standard_operation_id IS NULL OR
                   p_eam_op_rec.standard_operation_id = FND_API.G_MISS_NUM
                THEN
                    x_eam_op_rec.standard_operation_id := p_old_eam_op_rec.standard_operation_id;
                END IF;

                IF p_eam_op_rec.department_id IS NULL OR
                   p_eam_op_rec.department_id = FND_API.G_MISS_NUM
                THEN
                    x_eam_op_rec.department_id := p_old_eam_op_rec.department_id;
                END IF;

               /* commented for BUG#5997830
	        IF p_eam_op_rec.description IS NULL OR
                   p_eam_op_rec.description = FND_API.G_MISS_CHAR
                THEN
                    x_eam_op_rec.description := p_old_eam_op_rec.description;
                END IF;
		*/

                IF p_eam_op_rec.start_date IS NULL OR
                   p_eam_op_rec.start_date = FND_API.G_MISS_DATE
                THEN
                    x_eam_op_rec.start_date := p_old_eam_op_rec.start_date;
                END IF;

                IF p_eam_op_rec.completion_date IS NULL OR
                   p_eam_op_rec.completion_date = FND_API.G_MISS_DATE
                THEN
                    x_eam_op_rec.completion_date := p_old_eam_op_rec.completion_date;
                END IF;

                IF p_eam_op_rec.count_point_type IS NULL OR
                   p_eam_op_rec.count_point_type = FND_API.G_MISS_NUM
                THEN
                    x_eam_op_rec.count_point_type := p_old_eam_op_rec.count_point_type;
                END IF;

                IF p_eam_op_rec.backflush_flag IS NULL OR
                   p_eam_op_rec.backflush_flag = FND_API.G_MISS_NUM
                THEN
                    x_eam_op_rec.backflush_flag := p_old_eam_op_rec.backflush_flag;
                END IF;

                IF p_eam_op_rec.minimum_transfer_quantity IS NULL OR
                   p_eam_op_rec.minimum_transfer_quantity = FND_API.G_MISS_NUM
                THEN
                    x_eam_op_rec.minimum_transfer_quantity := p_old_eam_op_rec.minimum_transfer_quantity;
                END IF;

               /* commented for BUG#5997830
	       IF p_eam_op_rec.shutdown_type IS NULL OR
                   p_eam_op_rec.shutdown_type = FND_API.G_MISS_CHAR
                THEN
                    x_eam_op_rec.shutdown_type := p_old_eam_op_rec.shutdown_type;
                END IF;
		*/
                --
                -- Populate Null or missng flex field columns
                --
		/* commented for BUG#5997830 --- start ---
                IF p_eam_op_rec.attribute_category IS NULL OR
                   p_eam_op_rec.attribute_category = FND_API.G_MISS_CHAR
                THEN
                        x_eam_op_rec.attribute_category := p_old_eam_op_rec.attribute_category;

                END IF;

                IF p_eam_op_rec.attribute1 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute1 IS NULL
                THEN
                        x_eam_op_rec.attribute1  := p_old_eam_op_rec.attribute1;
                END IF;

                IF p_eam_op_rec.attribute2 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute2 IS NULL
                THEN
                        x_eam_op_rec.attribute2  := p_old_eam_op_rec.attribute2;
                END IF;

                IF p_eam_op_rec.attribute3 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute3 IS NULL
                THEN
                        x_eam_op_rec.attribute3  := p_old_eam_op_rec.attribute3;
                END IF;

                IF p_eam_op_rec.attribute4 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute4 IS NULL
                THEN
                        x_eam_op_rec.attribute4  := p_old_eam_op_rec.attribute4;
                END IF;

                IF p_eam_op_rec.attribute5 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute5 IS NULL
                THEN
                        x_eam_op_rec.attribute5  := p_old_eam_op_rec.attribute5;
                END IF;

                IF p_eam_op_rec.attribute6 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute6 IS NULL
                THEN
                        x_eam_op_rec.attribute6  := p_old_eam_op_rec.attribute6;
                END IF;

                IF p_eam_op_rec.attribute7 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute7 IS NULL
                THEN
                        x_eam_op_rec.attribute7  := p_old_eam_op_rec.attribute7;
                END IF;

                IF p_eam_op_rec.attribute8 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute8 IS NULL
                THEN
                        x_eam_op_rec.attribute8  := p_old_eam_op_rec.attribute8;
                END IF;

                IF p_eam_op_rec.attribute9 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute9 IS NULL
                THEN
                        x_eam_op_rec.attribute9  := p_old_eam_op_rec.attribute9;
                END IF;

                IF p_eam_op_rec.attribute10 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute10 IS NULL
                THEN
                        x_eam_op_rec.attribute10 := p_old_eam_op_rec.attribute10;
                END IF;

                IF p_eam_op_rec.attribute11 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute11 IS NULL
                THEN
                        x_eam_op_rec.attribute11 := p_old_eam_op_rec.attribute11;
                END IF;

                IF p_eam_op_rec.attribute12 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute12 IS NULL
                THEN
                        x_eam_op_rec.attribute12 := p_old_eam_op_rec.attribute12;
                END IF;

                IF p_eam_op_rec.attribute13 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute13 IS NULL
                THEN
                        x_eam_op_rec.attribute13 := p_old_eam_op_rec.attribute13;
                END IF;

                IF p_eam_op_rec.attribute14 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute14 IS NULL
                THEN
                        x_eam_op_rec.attribute14 := p_old_eam_op_rec.attribute14;
                END IF;

                IF p_eam_op_rec.attribute15 = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.attribute15 IS NULL
                THEN
                        x_eam_op_rec.attribute15 := p_old_eam_op_rec.attribute15;
                END IF;

                IF p_eam_op_rec.long_description = FND_API.G_MISS_CHAR OR
                   p_eam_op_rec.long_description IS NULL
                THEN
                        x_eam_op_rec.long_description := p_old_eam_op_rec.long_description;
                END IF;
		--------- end ----------
		*/


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Done processing null columns prior update'); END IF;


        END Populate_Null_Columns;

END EAM_OP_DEFAULT_PVT;

/
