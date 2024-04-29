--------------------------------------------------------
--  DDL for Package Body EGO_DEFAULT_CATALOG_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_DEFAULT_CATALOG_GROUP" AS
/* $Header: EGODCAGB.pls 120.1.12010000.3 2010/04/25 15:16:41 vijoshi ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EGODCAGB.pls
--
--  DESCRIPTION
--
--      Body of package EGO_Default_Catalog_Group
--
--  NOTES
--
--  HISTORY
--  20-SEP-2002 Rahul Chitko    Initial Creation
--
****************************************************************************/
        G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EGO_Default_Catalog_Group';

    PROCEDURE Get_Flex_Catalog_Group
    IS
    BEGIN

        --  In the future call Flex APIs for defaults
        EGO_Globals.G_Catalog_Group_Rec := EGO_Globals.G_Catalog_Group_Rec;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute_category =FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute_category := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute2 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute2  := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute3 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute3  := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute4 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute4  := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute5 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute5  := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute7 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute7  := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute8 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute8  := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute9 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute9  := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute11 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute11 := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute12 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute12 := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute13 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute13 := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute14 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute14 := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute15 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute15 := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute1 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute1  := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute6 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute6  := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute10 = FND_API.G_MISS_CHAR THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute10 := NULL;
        END IF;

    END Get_Flex_Catalog_Group;



    /*********************************************************************
    * Procedure     : Attribute_Defaulting
    * Parameter OUT : Mesg_Token_Table
    *                 Return_Status
    * Purpose       : Attribute Defaulting will default the necessary null
    *         attribute with appropriate values.
    **********************************************************************/
    PROCEDURE Attribute_Defaulting
    (  x_mesg_token_tbl OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status  OUT NOCOPY VARCHAR2
     )
    IS
    BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        Get_Flex_Catalog_Group;

        if (EGO_Globals.G_Catalog_Group_Rec.Summary_Flag IS NULL OR
                     EGO_Globals.G_Catalog_Group_Rec.Summary_Flag = FND_API.G_MISS_CHAR)
        then
            if fnd_flex_keyval.summary_flag then
                EGO_Globals.G_Catalog_Group_Rec.Summary_Flag := 'Y';
            else
                EGO_Globals.G_Catalog_Group_Rec.Summary_Flag := 'N';
            end if;
        end if;

        if (EGO_Globals.G_Catalog_Group_Rec.Enabled_Flag IS NULL OR
                   EGO_Globals.G_Catalog_Group_Rec.Enabled_Flag = FND_API.G_MISS_CHAR)
        then
            EGO_Globals.G_Catalog_Group_Rec.Enabled_flag := 'Y';
        end if;

        if (EGO_Globals.G_Catalog_Group_Rec.Item_Creation_Allowed_Flag = FND_API.G_MISS_CHAR)
        then
            EGO_Globals.G_Catalog_Group_Rec.Item_Creation_Allowed_Flag := NULL;
        end if;

        if (EGO_Globals.G_Catalog_Group_Rec.Inactive_Date = FND_API.G_MISS_DATE)
        then
            EGO_Globals.G_Catalog_Group_Rec.Inactive_Date := NULL;
        end if;

        if (EGO_Globals.G_Catalog_Group_Rec.Start_Effective_Date = FND_API.G_MISS_DATE)
        then
            EGO_Globals.G_Catalog_Group_Rec.Start_Effective_Date := NULL;
        end if;

        IF EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id = FND_API.G_MISS_NUM
        THEN
            EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id := null;
        END IF;

        IF (EGO_Globals.G_Catalog_Group_Rec.segment1 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment1 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment2 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment2 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment3 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment3 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment4 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment4 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment5 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment5 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment6 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment6 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment7 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment7 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment8 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment8 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment9 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment9 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment10 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment10 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment11 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment11 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment12 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment12 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment13 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment13 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment14 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment14 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment15 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment15 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment16 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment16 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment17 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment17 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment18 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment18 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment19 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment19 := NULL;
        END IF;
        IF (EGO_Globals.G_Catalog_Group_Rec.segment20 = FND_API.G_MISS_CHAR)
        THEN
            EGO_Globals.G_Catalog_Group_Rec.segment20 := NULL;
        END IF;

                --fix for bug 2822776
                IF EGO_Globals.G_Catalog_Group_Rec.description = FND_API.G_MISS_CHAR
                THEN
                    EGO_Globals.G_Catalog_Group_Rec.description := NULL;
                END IF;


    END Attribute_Defaulting;

    /******************************************************************
    * Procedure : Populate_Null_Columns
    * Purpose   : This procedure will look at the columns that the user
    *         has not filled in and will assign those columns a
    *         value from the database record.
    *         This procedure is not called for CREATE
    ********************************************************************/
    PROCEDURE Populate_Null_Columns
    IS
    BEGIN
        ---- Nulled out the columns if G_MISS_CHAR/G_MISS_NUM is being passed bug 9651715
        ----



        IF EGO_Globals.G_Catalog_Group_Rec.attribute_category IS NULL
        THEN
            EGO_Globals.G_Catalog_Group_Rec.attribute_category :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute_category;

        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute2 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute2  :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute2;
                END IF;

        IF  EGO_Globals.G_Catalog_Group_Rec.attribute3 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute3  :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute3;
                END IF;


        IF EGO_Globals.G_Catalog_Group_Rec.attribute4 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute4  :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute4;
                END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.attribute5 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute5  :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute5;
                END IF;


         if  EGO_Globals.G_Catalog_Group_Rec.attribute7 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute7  :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute7;
                END IF;


        IF   EGO_Globals.G_Catalog_Group_Rec.attribute8 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute8  :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute8;
                END IF;


        if   EGO_Globals.G_Catalog_Group_Rec.attribute9 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute9  :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute9;
                END IF;


        IF EGO_Globals.G_Catalog_Group_Rec.attribute11 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute11 :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute11;
                END IF;


        IF   EGO_Globals.G_Catalog_Group_Rec.attribute12 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute12 :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute12;
                END IF;


        IF   EGO_Globals.G_Catalog_Group_Rec.attribute13 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute13 :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute13;
                END IF;

        IF
           EGO_Globals.G_Catalog_Group_Rec.attribute14 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute14 :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute14;
                END IF;

        IF
           EGO_Globals.G_Catalog_Group_Rec.attribute15 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute15 :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute15;
                END IF;


        IF   EGO_Globals.G_Catalog_Group_Rec.attribute1 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute1  :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute1;
                END IF;


        IF   EGO_Globals.G_Catalog_Group_Rec.attribute6 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute6  :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute6;
                END IF;


        IF   EGO_Globals.G_Catalog_Group_Rec.attribute10 IS NULL
        THEN
                EGO_Globals.G_Catalog_Group_Rec.attribute10 :=
                EGO_Globals.G_Old_Catalog_Group_Rec.attribute10;
                END IF;

        --- This will NULL out DFF attribute columns if they are G_MISS_CHAR
        ---
        Get_Flex_Catalog_Group;

        IF EGO_Globals.G_Catalog_Group_Rec.description IS NULL
        THEN
            EGO_Globals.G_Catalog_Group_Rec.description := EGO_Globals.G_Old_Catalog_Group_Rec.Description;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.summary_flag IS NULL
        THEN
            EGO_Globals.G_Catalog_Group_Rec.summary_flag := EGO_Globals.G_Old_Catalog_Group_Rec.Summary_Flag;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.enabled_flag IS NULL
        THEN
            EGO_Globals.G_Catalog_Group_Rec.enabled_flag := EGO_Globals.G_Old_Catalog_Group_Rec.Enabled_flag;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.inactive_date IS NULL
        THEN
            EGO_Globals.G_Catalog_Group_Rec.inactive_date := EGO_Globals.G_Old_Catalog_Group_Rec.inactive_date;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.start_effective_date IS NULL
        THEN
            EGO_Globals.G_Catalog_Group_Rec.start_effective_date := EGO_Globals.G_Old_Catalog_Group_Rec.start_effective_date;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.description = FND_API.G_MISS_CHAR
        THEN
            EGO_Globals.G_Catalog_Group_Rec.description := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.inactive_date = FND_API.G_MISS_DATE
        THEN
            EGO_Globals.G_Catalog_Group_Rec.inactive_date := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.start_effective_date = FND_API.G_MISS_DATE
        THEN
            EGO_Globals.G_Catalog_Group_Rec.start_effective_date := NULL;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.summary_flag = FND_API.G_MISS_CHAR  THEN
            IF fnd_flex_keyval.summary_flag then
                EGO_Globals.G_Catalog_Group_Rec.Summary_Flag := 'Y';
            ELSE
                EGO_Globals.G_Catalog_Group_Rec.Summary_Flag := 'N';
            END IF;
        END IF;

        IF EGO_Globals.G_Catalog_Group_Rec.enabled_flag = FND_API.G_MISS_CHAR THEN
           EGO_Globals.G_Catalog_Group_Rec.Enabled_flag := 'Y';
        END IF;

                --
                -- Get the unexposed columns from the database and return
                -- them as the unexposed columns for the current record.
                --

         EGO_Globals.G_Catalog_Group_Rec.catalog_group_id := EGO_Globals.G_Old_Catalog_Group_Rec.catalog_group_id;

         IF  EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id IS  NULL
         THEN
            EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id := EGO_Globals.G_Old_Catalog_Group_Rec.parent_catalog_group_id;
         END IF;

         IF  EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id = FND_API.G_MISS_NUM
         THEN
            EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id := NULL;
         END IF;

    END Populate_Null_Columns;

END EGO_Default_Catalog_Group;

/
