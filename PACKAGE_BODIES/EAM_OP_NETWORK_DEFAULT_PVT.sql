--------------------------------------------------------
--  DDL for Package Body EAM_OP_NETWORK_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OP_NETWORK_DEFAULT_PVT" AS
/* $Header: EAMVONDB.pls 115.2 2003/05/14 22:57:31 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVONDB.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_OP_NETWORK_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_OP_NETWORK_DEFAULT_PVT';


        /********************************************************************
        * Procedure     : get_flex_eam_op_network
        * Return        : NUMBER
        **********************************************************************/


        PROCEDURE get_flex_eam_mat_op_network
          (  p_eam_op_network_rec IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
           , x_eam_op_network_rec OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_rec_type
          )
        IS
        BEGIN

            --  In the future call Flex APIs for defaults
                x_eam_op_network_rec := p_eam_op_network_rec;

                IF p_eam_op_network_rec.attribute_category =FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute_category := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute1  := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute2 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute2  := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute3  := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute4  := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute5  := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute6  := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute7  := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute8  := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute9  := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute10 := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute11 := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute12 := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute13 := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute14 := NULL;
                END IF;

                IF p_eam_op_network_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                        x_eam_op_network_rec.attribute15 := NULL;
                END IF;

        END get_flex_eam_mat_op_network;


        /*********************************************************************
        * Procedure     : Attribute_Defaulting
        * Parameters IN : Operation Networks record
        * Parameters OUT NOCOPY: Operation Networks record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Attribute Defaulting will default the necessary null
        *                 attribute with appropriate values.
        **********************************************************************/

        PROCEDURE Attribute_Defaulting
        (  p_eam_op_network_rec      IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_eam_op_network_rec      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         )
        IS
          l_out_eam_op_network_rec EAM_PROCESS_WO_PUB.eam_op_network_rec_type;
        BEGIN

                x_eam_op_network_rec := p_eam_op_network_rec;
--                x_eam_op_network_rec := p_eam_op_network_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                l_out_eam_op_network_rec := x_eam_op_network_rec;

                get_flex_eam_mat_op_network
                (  p_eam_op_network_rec => x_eam_op_network_rec
                 , x_eam_op_network_rec => l_out_eam_op_network_rec
                 );

                x_eam_op_network_rec := l_out_eam_op_network_rec;

        END Attribute_Defaulting;


        /******************************************************************
        * Procedure     : Populate_Null_Columns
        * Parameters IN : Operation Networks column record
        *                 Old Operation Networks Column Record
        * Parameters OUT NOCOPY: Operation Networks column record after populating
        * Purpose       : This procedure will look at the columns that the user
        *                 has not filled in and will assign those columns a
        *                 value from the old record.
        *                 This procedure is not called for CREATE
        ********************************************************************/
        PROCEDURE Populate_Null_Columns
        (  p_eam_op_network_rec           IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , p_old_eam_op_network_rec       IN  EAM_PROCESS_WO_PUB.eam_op_network_rec_type
         , x_eam_op_network_rec           OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_rec_type
        )
        IS
        BEGIN
                x_eam_op_network_rec := p_eam_op_network_rec;
--                x_eam_op_network_rec := p_eam_op_network_rec;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Processing null columns prior update'); END IF;

                IF p_eam_op_network_rec.prior_operation IS NULL OR
                   p_eam_op_network_rec.prior_operation = FND_API.G_MISS_NUM
                THEN
                   x_eam_op_network_rec.prior_operation := p_old_eam_op_network_rec.prior_operation;
                END IF;

                IF p_eam_op_network_rec.next_operation IS NULL OR
                   p_eam_op_network_rec.next_operation = FND_API.G_MISS_NUM
                THEN
                   x_eam_op_network_rec.next_operation := p_old_eam_op_network_rec.next_operation;
                END IF;

                --
                -- Populate Null or missng flex field columns
                --
                IF p_eam_op_network_rec.attribute_category IS NULL OR
                   p_eam_op_network_rec.attribute_category = FND_API.G_MISS_CHAR
                THEN
                        x_eam_op_network_rec.attribute_category := p_old_eam_op_network_rec.attribute_category;

                END IF;

                IF p_eam_op_network_rec.attribute1 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute1 IS NULL
                THEN
                        x_eam_op_network_rec.attribute1  := p_old_eam_op_network_rec.attribute1;
                END IF;

                IF p_eam_op_network_rec.attribute2 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute2 IS NULL
                THEN
                        x_eam_op_network_rec.attribute2  := p_old_eam_op_network_rec.attribute2;
                END IF;

                IF p_eam_op_network_rec.attribute3 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute3 IS NULL
                THEN
                        x_eam_op_network_rec.attribute3  := p_old_eam_op_network_rec.attribute3;
                END IF;

                IF p_eam_op_network_rec.attribute4 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute4 IS NULL
                THEN
                        x_eam_op_network_rec.attribute4  := p_old_eam_op_network_rec.attribute4;
                END IF;

                IF p_eam_op_network_rec.attribute5 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute5 IS NULL
                THEN
                        x_eam_op_network_rec.attribute5  := p_old_eam_op_network_rec.attribute5;
                END IF;

                IF p_eam_op_network_rec.attribute6 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute6 IS NULL
                THEN
                        x_eam_op_network_rec.attribute6  := p_old_eam_op_network_rec.attribute6;
                END IF;

                IF p_eam_op_network_rec.attribute7 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute7 IS NULL
                THEN
                        x_eam_op_network_rec.attribute7  := p_old_eam_op_network_rec.attribute7;
                END IF;

                IF p_eam_op_network_rec.attribute8 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute8 IS NULL
                THEN
                        x_eam_op_network_rec.attribute8  := p_old_eam_op_network_rec.attribute8;
                END IF;

                IF p_eam_op_network_rec.attribute9 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute9 IS NULL
                THEN
                        x_eam_op_network_rec.attribute9  := p_old_eam_op_network_rec.attribute9;
                END IF;

                IF p_eam_op_network_rec.attribute10 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute10 IS NULL
                THEN
                        x_eam_op_network_rec.attribute10 := p_old_eam_op_network_rec.attribute10;
                END IF;

                IF p_eam_op_network_rec.attribute11 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute11 IS NULL
                THEN
                        x_eam_op_network_rec.attribute11 := p_old_eam_op_network_rec.attribute11;
                END IF;

                IF p_eam_op_network_rec.attribute12 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute12 IS NULL
                THEN
                        x_eam_op_network_rec.attribute12 := p_old_eam_op_network_rec.attribute12;
                END IF;

                IF p_eam_op_network_rec.attribute13 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute13 IS NULL
                THEN
                        x_eam_op_network_rec.attribute13 := p_old_eam_op_network_rec.attribute13;
                END IF;

                IF p_eam_op_network_rec.attribute14 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute14 IS NULL
                THEN
                        x_eam_op_network_rec.attribute14 := p_old_eam_op_network_rec.attribute14;
                END IF;

                IF p_eam_op_network_rec.attribute15 = FND_API.G_MISS_CHAR OR
                   p_eam_op_network_rec.attribute15 IS NULL
                THEN
                        x_eam_op_network_rec.attribute15 := p_old_eam_op_network_rec.attribute15;
                END IF;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Done processing null columns prior update'); END IF;


        END Populate_Null_Columns;

END EAM_OP_NETWORK_DEFAULT_PVT;

/
