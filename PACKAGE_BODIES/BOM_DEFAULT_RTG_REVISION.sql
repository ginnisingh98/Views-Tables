--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_RTG_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_RTG_REVISION" AS
/* $Header: BOMDRRVB.pls 115.3 2002/11/21 05:21:10 djebar ship $ */
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--     BOMDRRVB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Default_Rtg_Revision
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00 Biao Zhang Initial Creation
--
****************************************************************************/
        G_Pkg_Name      VARCHAR2(30) := 'BOM_Default_Rtg_Revision';
        g_token_tbl     Error_Handler.Token_Tbl_Type;

        PROCEDURE Get_Flex_Rtg_revision
          (  p_rtg_revision_rec IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
           , x_rtg_revision_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Rec_Type
          )
        IS
        BEGIN

            --  In the future call Flex APIs for defaults
                x_rtg_revision_rec := p_rtg_revision_rec;

                IF p_rtg_revision_rec.attribute_category =FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute_category := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute2 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute2  := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute3  := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute4  := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute5  := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute7  := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute8  := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute9  := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute11 := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute12 := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute13 := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute14 := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute15 := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute1  := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute6  := NULL;
                END IF;

                IF p_rtg_revision_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                        x_rtg_revision_rec.attribute10 := NULL;
                END IF;

        END Get_Flex_Rtg_revision;



        /*********************************************************************
        * Procedure     : Attribute_Defaulting
        * Parameters IN : Rtg revision exposed record
        *                 Rtg revision unexposed record
        * Parameters out: Rtg revision exposed record after defaulting
        *                 Rtg revision unexposed record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Attribute Defaulting will default the necessary null
        *                 attribute with appropriate values.
        **********************************************************************/
        PROCEDURE Attribute_Defaulting
        (  p_rtg_revision_rec   IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_rev_unexp_rec IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_rtg_revision_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , x_rtg_rev_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      IN OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

                x_rtg_revision_rec := p_rtg_revision_rec;
                x_rtg_rev_unexp_rec := p_rtg_rev_unexp_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;


                Get_Flex_Rtg_revision(  p_rtg_revision_rec => p_rtg_revision_rec                                    , x_rtg_revision_rec => x_rtg_revision_rec
                                    );

        END Attribute_Defaulting;

        /*********************************************************************
        * Procedure     : Entity_Attribute_Defaulting
        * Parameters IN : Rtg revision exposed record
        *                 Rtg revision unexposed record
        * Parameters out: Rtg revision exposed record after defaulting
        *                 Rtg revision unexposed record after defaulting
        *                 Mesg_Token_Table
        *                 Return_Status
        * Purpose       : Entity Attribute Defaulting will default the necessary        *                 entity level attribute with appropriate values.
        **********************************************************************/
        PROCEDURE Entity_Attribute_Defaulting
        (  p_rtg_revision_rec        IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_rev_unexp_rec       IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_rtg_revision_rec        IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , x_rtg_rev_unexp_rec       IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

                x_rtg_revision_rec := p_rtg_revision_rec;
                x_rtg_rev_unexp_rec := p_rtg_rev_unexp_rec;
                x_return_status := FND_API.G_RET_STS_SUCCESS;


                -- Start effecitive date
                IF p_rtg_revision_rec.start_effective_date IS NOT NULL
                AND
                   p_rtg_revision_rec.start_effective_date
                                                <> FND_API.G_MISS_DATE
                THEN
                   IF trunc(p_rtg_revision_rec.start_effective_date)
                       = trunc(sysdate)
                   THEN
                     x_rtg_revision_rec.start_effective_date
                      := to_char(sysdate, 'HH24:MI:SS');
                   ELSIF
                        trunc(p_rtg_revision_rec.start_effective_date)
                       > trunc(sysdate)
                      THEN  x_rtg_revision_rec.start_effective_date
                        := trunc(p_rtg_revision_rec.start_effective_date);
                   END IF;
                END IF;

                IF p_rtg_rev_unexp_rec.implementation_date IS  NULL
                OR TRUNC(p_rtg_revision_rec.start_effective_date)
                    <>  TRUNC(p_rtg_rev_unexp_rec.implementation_date)
                THEN   x_rtg_rev_unexp_rec.implementation_date
                        := p_rtg_revision_rec.start_effective_date;
                END IF;

        END ENTITY_Attribute_Defaulting;

        /******************************************************************
        * Procedure     : Populate_Null_Columns
        * Parameters IN : Rtg revision Exposed column record
        *                 Rtg revision Unexposed column record
        *                 Old Rtg revision Exposed Column Record
        *                 Old Rtg revision Unexposed Column Record
        * Parameters out: Rtg revision Exposed column record after populating
        *                 Rtg revision Unexposed Column record after  populating
        * Purpose       : This procedure will look at the columns that the user         *                 has not filled in and will assign those columns a
        *                 value from the old record.
        *                 This procedure is not called CREATE
        ********************************************************************/
        PROCEDURE Populate_Null_Columns
        (  p_rtg_revision_rec       IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_rev_unexp_rec IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , p_old_rtg_revision_rec   IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_old_rtg_rev_unexp_rec IN Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type              , x_rtg_revision_rec       IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , x_rtg_rev_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
        )
        IS
        BEGIN
                x_rtg_revision_rec := p_rtg_revision_rec;
                x_rtg_rev_unexp_rec := p_rtg_rev_unexp_rec;

                IF p_rtg_revision_rec.attribute_category IS NULL OR
                   p_rtg_revision_rec.attribute_category = FND_API.G_MISS_CHAR
                THEN
                        x_rtg_revision_rec.attribute_category :=
                                p_old_rtg_revision_rec.attribute_category;

                END IF;

                IF p_rtg_revision_rec.attribute2 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute2 IS NULL
                THEN
                        x_rtg_revision_rec.attribute2  :=
                                p_old_rtg_revision_rec.attribute2;
                END IF;

                IF p_rtg_revision_rec.attribute3 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute3 IS NULL
                THEN
                        x_rtg_revision_rec.attribute3  :=
                                p_old_rtg_revision_rec.attribute3;
                END IF;

                IF p_rtg_revision_rec.attribute4 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute4 IS NULL
                THEN
                        x_rtg_revision_rec.attribute4  :=
                                p_old_rtg_revision_rec.attribute4;
                END IF;

                IF p_rtg_revision_rec.attribute5 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute5 IS NULL
                THEN
                        x_rtg_revision_rec.attribute5  :=
                                p_old_rtg_revision_rec.attribute5;
                END IF;

                IF p_rtg_revision_rec.attribute7 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute7 IS NULL
                THEN
                        x_rtg_revision_rec.attribute7  :=
                                p_old_rtg_revision_rec.attribute7;
                END IF;

                IF p_rtg_revision_rec.attribute8 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute8 IS NULL
                THEN
                        x_rtg_revision_rec.attribute8  :=
                                p_old_rtg_revision_rec.attribute8;
                END IF;

                IF p_rtg_revision_rec.attribute9 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute9 IS NULL
                THEN
                        x_rtg_revision_rec.attribute9  :=
                                p_old_rtg_revision_rec.attribute9;
                END IF;

                IF p_rtg_revision_rec.attribute11 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute11 IS NULL
                THEN
                        x_rtg_revision_rec.attribute11 :=
                                p_old_rtg_revision_rec.attribute11;
                END IF;

                IF p_rtg_revision_rec.attribute12 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute12 IS NULL
                THEN
                        x_rtg_revision_rec.attribute12 :=
                                p_old_rtg_revision_rec.attribute12;
                END IF;

                IF p_rtg_revision_rec.attribute13 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute13 IS NULL
                THEN
                        x_rtg_revision_rec.attribute13 :=
                                p_old_rtg_revision_rec.attribute13;
                END IF;

                IF p_rtg_revision_rec.attribute14 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute14 IS NULL
                THEN
                        x_rtg_revision_rec.attribute14 :=
                                p_old_rtg_revision_rec.attribute14;
                END IF;

                IF p_rtg_revision_rec.attribute15 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute15 IS NULL
                THEN
                        x_rtg_revision_rec.attribute15 :=
                                p_old_rtg_revision_rec.attribute15;
                END IF;

                IF p_rtg_revision_rec.attribute1 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute1 IS NULL
                THEN
                        x_rtg_revision_rec.attribute1  :=
                                p_old_rtg_revision_rec.attribute1;
                END IF;

                IF p_rtg_revision_rec.attribute6 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute6 IS NULL
                THEN
                        x_rtg_revision_rec.attribute6  :=
                                p_old_rtg_revision_rec.attribute6;
                END IF;

                IF p_rtg_revision_rec.attribute10 = FND_API.G_MISS_CHAR OR
                   p_rtg_revision_rec.attribute10 IS NULL
                THEN
                        x_rtg_revision_rec.attribute10 :=
                                p_old_rtg_revision_rec.attribute10;
                END IF;

                 --
                -- Get the unexposed columns from the database and return
                -- them as the unexposed columns for the current record.
                --
                x_rtg_rev_unexp_rec.routing_sequence_id :=
                         p_old_rtg_rev_unexp_rec.routing_sequence_id;


END Populate_Null_Columns;



END BOM_Default_Rtg_Revision;

/
