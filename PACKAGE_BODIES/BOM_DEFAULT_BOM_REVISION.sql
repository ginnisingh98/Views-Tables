--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_BOM_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_BOM_REVISION" AS
/* $Header: BOMDREVB.pls 120.0 2005/05/25 06:11:34 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDREVS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Default_Bom_Revision
--
--  NOTES
--
--  HISTORY
--
--  29-JUL-99   Rahul Chitko    Initial Creation
--
***************************************************************************/

        /*******************************************************************
        * Procedure     : Populate_Null_Columns (earlier called Complete_Record)
        * Parameters IN : Bom Revision exposed column record
        *                 Bom Revision DB record of exposed columns
        *                 Bom Revision unexposed column record
        *                 Bom Revision DB record of unexposed columns
        * Parameters OUT: Bom Revision exposed Record
        *                 Bom Revision Unexposed Record
        * Purpose       : Complete record will compare the database record with
        *                 the user given record and will complete the user
        *                 record with values from the database record, for all
        *                 columns that the user has left NULL.
        ********************************************************************/
        PROCEDURE Populate_Null_Columns
        ( p_bom_revision_rec       IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
        , p_old_bom_revision_rec   IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
        , p_bom_rev_unexp_rec      IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
        , p_Old_bom_rev_unexp_rec  IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
        , x_bom_revision_rec       IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Rec_Type
        , x_bom_rev_unexp_rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
        )
	IS
		l_bom_revision_rec	Bom_Bo_Pub.Bom_Revision_Rec_Type:=
					p_bom_revision_rec;
		l_bom_rev_unexp_rec	Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type:=
					p_bom_rev_unexp_rec;
	BEGIN
		IF l_bom_revision_rec.description IS NULL
		THEN
			l_bom_revision_rec.description :=
				p_old_bom_revision_rec.description;
		END IF;

		IF l_bom_revision_rec.revision_label IS NULL
		THEN
			l_bom_revision_rec.revision_label:=
				p_old_bom_revision_rec.revision_label;
		END IF;

		IF l_bom_revision_rec.revision_reason IS NULL
		THEN
			l_bom_revision_rec.revision_reason:=
				p_old_bom_revision_rec.revision_reason;
		END IF;

		IF l_bom_revision_rec.attribute_category IS NULL THEN
                        l_bom_revision_rec.attribute_category :=
                        p_old_bom_revision_rec.attribute_category;
                END IF;

                IF l_bom_revision_rec.attribute1 IS NULL THEN
                        l_bom_revision_rec.attribute1 :=
                                p_old_bom_revision_rec.attribute1;
                END IF;

                IF l_bom_revision_rec.attribute2  IS NULL THEN
                        l_bom_revision_rec.attribute2 :=
                                p_old_bom_revision_rec.attribute2;
                END IF;

                IF l_bom_revision_rec.attribute3 IS NULL THEN
                        l_bom_revision_rec.attribute3 :=
                                p_old_bom_revision_rec.attribute3;
                END IF;

                IF l_bom_revision_rec.attribute4 IS NULL THEN
                        l_bom_revision_rec.attribute4 :=
                                p_old_bom_revision_rec.attribute4;
                END IF;

                IF l_bom_revision_rec.attribute5 IS NULL THEN
                        l_bom_revision_rec.attribute5 :=
                                p_old_bom_revision_rec.attribute5;
                END IF;

                IF l_bom_revision_rec.attribute6 IS NULL THEN
                        l_bom_revision_rec.attribute6 :=
                                p_old_bom_revision_rec.attribute6;
                END IF;

                IF l_bom_revision_rec.attribute7 IS NULL THEN
                        l_bom_revision_rec.attribute7 :=
                                p_old_bom_revision_rec.attribute7;
                END IF;

                IF l_bom_revision_rec.attribute8 IS NULL THEN
                        l_bom_revision_rec.attribute8 :=
                                p_old_bom_revision_rec.attribute8;
                END IF;

                IF l_bom_revision_rec.attribute9 IS NULL THEN
                        l_bom_revision_rec.attribute9 :=
                                p_old_bom_revision_rec.attribute9;
                END IF;

                IF l_bom_revision_rec.attribute10 IS NULL THEN
                        l_bom_revision_rec.attribute10 :=
                                p_old_bom_revision_rec.attribute10;
                END IF;

                IF l_bom_revision_rec.attribute11 IS NULL THEN
                        l_bom_revision_rec.attribute11 :=
                                p_old_bom_revision_rec.attribute11;
                END IF;

                IF l_bom_revision_rec.attribute12 IS NULL THEN
                        l_bom_revision_rec.attribute12 :=
                                p_old_bom_revision_rec.attribute12;
                END IF;

                IF l_bom_revision_rec.attribute13 IS NULL THEN
                        l_bom_revision_rec.attribute13 :=
                                p_old_bom_revision_rec.attribute13;
                END IF;

                IF l_bom_revision_rec.attribute14 IS NULL THEN
                        l_bom_revision_rec.attribute14 :=
                                p_old_bom_revision_rec.attribute14;
                END IF;

                IF l_bom_revision_rec.attribute15 IS NULL THEN
                        l_bom_revision_rec.attribute15 :=
                                p_old_bom_revision_rec.attribute15;
                END IF;

		IF l_bom_revision_rec.description = FND_API.G_MISS_CHAR
		THEN
			l_bom_revision_rec.description := NULL;
		END IF;

		IF l_bom_revision_rec.attribute_category = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute_category := NULL;
                END IF;

                IF l_bom_revision_rec.attribute1 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute1 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute2  = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute2 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute3 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute3 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute4 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute4 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute5 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute5 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute6 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute6 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute7 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute7 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute8 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute8 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute9 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute9 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute10 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute10 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute11 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute11 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute12 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute12 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute13 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute13 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute14 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute14 := NULL;
                END IF;

                IF l_bom_revision_rec.attribute15 = FND_API.G_MISS_CHAR THEN
                        l_bom_revision_rec.attribute15 := NULL;
                END IF;

		x_bom_revision_rec := l_bom_revision_rec;
		x_bom_rev_unexp_rec := l_bom_rev_unexp_rec;

	END Populate_Null_Columns;

END Bom_Default_Bom_Revision;

/
