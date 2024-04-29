--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_REF_DESIGNATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_REF_DESIGNATOR" AS
/* $Header: BOMDRFDB.pls 115.9 2002/11/13 21:05:21 rfarook ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDRFDB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Default_Ref_Designator
--
--  NOTES
--
--  HISTORY
--
--  19-JUL-1999	Rahul Chitko	Initial Creation
--
***************************************************************************/

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'BOM_Default_Ref_Designator';

--  Package global used within the package.

g_ref_designator_rec          Bom_Bo_Pub.Ref_Designator_Rec_Type;

PROCEDURE Get_Flex_Ref_Designator
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_ref_designator_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute_category := NULL;
    END IF;

    IF g_ref_designator_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute1 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute2 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute3 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute4 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute5 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute6 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute7 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute8 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute9 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute10 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute11 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute12 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute13 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute14 := NULL;
    END IF;

    IF g_ref_designator_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_ref_designator_rec.attribute15 := NULL;
    END IF;

END Get_Flex_Ref_Designator;

--  Procedure Attributes

PROCEDURE Attribute_Defaulting
(   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
,   p_ref_desg_unexp_rec        IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_ref_designator_rec        IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
,   x_Ref_Desg_Unexp_Rec        IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status		IN OUT NOCOPY VARCHAR2
)
IS
BEGIN

    /**************************************************************
    *
    * There are no columns that can be defaulted for Reference Desg.
    *
    ***************************************************************/

    g_ref_designator_Rec := p_ref_designator_Rec;

    IF g_ref_designator_rec.attribute_category = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_ref_designator_rec.attribute15 = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Ref_Designator;

    END IF;

        x_ref_designator_rec := g_ref_designator_rec;
	x_ref_Desg_Unexp_Rec := p_ref_Desg_Unexp_Rec;

END Attribute_defaulting;

/********************************************************************
*
* Procedure     : Populate_Null_Columns (Complete_Record)
* Parameters IN : Reference Designator Record as given by the User
*                 Old Reference Designator rec. queried from the DB
* Parameters OUT: Completed Reference Designator Record
*                 Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Complete Record will take the Database record and
*                 compare it with the user record and will complete
*                 the user record by filling in those values from the
*                 DB record that the user has left blank.
*                 Any user filled in columns will not be overwritten
*                 even if the values do not match.
********************************************************************/

PROCEDURE Populate_Null_Columns
(   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_ref_desg_unexp_rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   p_old_Ref_Designator_Rec    IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_old_ref_desg_unexp_rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_Ref_Designator_Rec        IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
,   x_ref_desg_unexp_rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
)
IS
l_ref_designator_rec          Bom_Bo_Pub.Ref_Designator_Rec_Type :=
                              p_ref_designator_rec;
l_err_text                    VARCHAR2(2000);
BEGIN

    IF l_ref_designator_rec.ref_designator_comment IS NULL THEN
        l_ref_designator_rec.ref_designator_comment :=
        p_old_ref_designator_rec.ref_designator_comment;
    END IF;

    IF l_ref_designator_rec.attribute_category IS NULL THEN
        l_ref_designator_rec.attribute_category :=
        p_old_ref_designator_rec.attribute_category;
    END IF;

	IF l_ref_designator_rec.attribute1 IS NULL THEN
		l_ref_designator_rec.attribute1 :=
			p_old_ref_designator_rec.attribute1;
	END IF;

	IF l_ref_designator_rec.attribute2 IS NULL THEN
		l_ref_designator_rec.attribute2 :=
			p_old_ref_designator_rec.attribute2;
	END IF;

	IF l_ref_designator_rec.attribute3 IS NULL THEN
		l_ref_designator_rec.attribute3 :=
			p_old_ref_designator_rec.attribute3;
	END IF;

	IF l_ref_designator_rec.attribute4 IS NULL THEN
		l_ref_designator_rec.attribute4 :=
			p_old_ref_designator_rec.attribute4;
	END IF;

	IF l_ref_designator_rec.attribute5 IS NULL THEN
		l_ref_designator_rec.attribute5 :=
			p_old_ref_designator_rec.attribute5;
	END IF;

	IF l_ref_designator_rec.attribute6 IS NULL THEN
		l_ref_designator_rec.attribute6 :=
			p_old_ref_designator_rec.attribute6;
	END IF;

	IF l_ref_designator_rec.attribute7 IS NULL THEN
		l_ref_designator_rec.attribute7 :=
			p_old_ref_designator_rec.attribute7;
	END IF;

	IF l_ref_designator_rec.attribute8 IS NULL THEN
		l_ref_designator_rec.attribute8 :=
			p_old_ref_designator_rec.attribute8;
	END IF;

	IF l_ref_designator_rec.attribute9 IS NULL THEN
		l_ref_designator_rec.attribute9 :=
			p_old_ref_designator_rec.attribute9;
    	END IF;

	IF l_ref_designator_rec.attribute10 IS NULL THEN
        	l_ref_designator_rec.attribute10 :=
        	p_old_ref_designator_rec.attribute10;
    	END IF;

  	IF l_ref_designator_rec.attribute11 IS NULL THEN
        	l_ref_designator_rec.attribute11 :=
        	p_old_ref_designator_rec.attribute11;
    	END IF;

	IF l_ref_designator_rec.attribute12 IS NULL THEN
        	l_ref_designator_rec.attribute12 :=
        	p_old_ref_designator_rec.attribute12;
    	END IF;

	IF l_ref_designator_rec.attribute13 IS NULL THEN
         	l_ref_designator_rec.attribute13 :=
         	p_old_ref_designator_rec.attribute13;
    	END IF;

        IF l_ref_designator_rec.attribute14 IS NULL THEN
        	l_ref_designator_rec.attribute14 :=
        	p_old_ref_designator_rec.attribute14;
    	END IF;

        IF l_ref_designator_rec.attribute15 IS NULL THEN
        	l_ref_designator_rec.attribute15 :=
        	p_old_ref_designator_rec.attribute15;
        END IF;

    /* Assign NULL for MISSING VALUES */

    g_ref_designator_rec := l_ref_designator_rec;
    Get_Flex_Ref_Designator;
    l_ref_designator_rec := g_ref_designator_rec;

    x_Ref_Designator_Rec := l_ref_designator_rec;
    x_ref_desg_unexp_rec := p_ref_desg_unexp_rec;

END Populate_Null_Columns;

/*
** Procedure code for BOM Business Object
*/

PROCEDURE Attribute_Defaulting
(   p_bom_ref_designator_rec   IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type :=
                                   Bom_Bo_Pub.G_MISS_Bom_REF_DESIGNATOR_REC
,   p_bom_ref_desg_unexp_rec   IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
,   x_bom_ref_designator_rec   IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   x_bom_Ref_Desg_Unexp_Rec   IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
,   x_Mesg_Token_Tbl           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status            IN OUT NOCOPY VARCHAR2
)
IS
	l_ref_designator_rec	Bom_Bo_Pub.Ref_Designator_Rec_Type;
	l_ref_desg_unexp_rec	Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
BEGIN
	--
	-- Convert the Bom Reference Designator record to ECO
	--
	Bom_Bo_Pub.Convert_BomDesg_To_EcoDesg
	(  p_bom_ref_designator_rec	=> p_bom_ref_designator_rec
	 , p_bom_ref_desg_unexp_rec	=> p_bom_ref_desg_unexp_rec
	 , x_ref_designator_rec		=> l_ref_designator_rec
	 , x_ref_desg_unexp_rec		=> l_ref_desg_unexp_rec
	 );

	--
	-- Call Attribute Defaulting for Reference Designator
	--

	Bom_Default_Ref_Designator.Attribute_Defaulting
	(  p_ref_designator_rec	=> l_ref_designator_rec
	 , p_ref_desg_unexp_rec	=> l_ref_desg_unexp_rec
	 , x_ref_designator_rec	=> l_ref_designator_rec
	 , x_ref_desg_unexp_rec	=> l_ref_desg_unexp_rec
	 , x_mesg_token_tbl	=> x_mesg_token_Tbl
	 , x_return_status	=> x_return_status
	 );

	--
	-- Covert the Eco Reference Designator Record to Bom
	--

	Bom_Bo_Pub.Convert_EcoDesg_To_BomDesg
	(  p_ref_designator_rec		=> l_ref_designator_rec
	 , p_ref_desg_unexp_rec		=> l_ref_desg_unexp_rec
	 , x_bom_ref_designator_rec	=> x_bom_ref_designator_rec
	 , x_bom_ref_desg_unexp_rec	=> x_bom_ref_desg_unexp_rec
	);

END Attribute_Defaulting;

PROCEDURE Populate_Null_Columns
(   p_bom_ref_designator_rec     IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   p_bom_ref_desg_unexp_rec     IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
,   p_old_bom_Ref_Designator_Rec IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   p_old_bom_ref_desg_unexp_rec IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
,   x_bom_Ref_Designator_Rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   x_bom_ref_desg_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
)
IS
	l_ref_designator_rec		Bom_Bo_Pub.Ref_Designator_Rec_Type;
	l_old_ref_designator_rec 	Bom_Bo_Pub.Ref_Designator_Rec_Type;
	l_ref_desg_unexp_rec		Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
	l_old_ref_desg_unexp_rec	Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
BEGIN

	--
	-- Convert the Bom Reference Designator record to Eco
	--
        Bom_Bo_Pub.Convert_BomDesg_To_EcoDesg
        (  p_bom_ref_designator_rec     => p_bom_ref_designator_rec
         , p_bom_ref_desg_unexp_rec     => p_bom_ref_desg_unexp_rec
         , x_ref_designator_rec         => l_ref_designator_rec
         , x_ref_desg_unexp_rec         => l_ref_desg_unexp_rec
         );

	--
	-- Similarly convert the old record information
	--
	Bom_Bo_Pub.Convert_BomDesg_To_EcoDesg
        (  p_bom_ref_designator_rec     => p_old_bom_ref_designator_rec
         , p_bom_ref_desg_unexp_rec     => p_old_bom_ref_desg_unexp_rec
         , x_ref_designator_rec         => l_old_ref_designator_rec
         , x_ref_desg_unexp_rec         => l_old_ref_desg_unexp_rec
         );


	--
	-- Call the Reference Designator Populate Null Columns
	--
	Bom_Default_Ref_Designator.Populate_Null_Columns
	(  p_ref_designator_rec		=> l_ref_designator_rec
	 , p_ref_desg_unexp_rec		=> l_ref_desg_unexp_rec
	 , p_old_ref_designator_rec	=> l_old_ref_designator_rec
	 , p_old_ref_desg_unexp_rec	=> l_old_ref_desg_unexp_rec
	 , x_ref_designator_rec		=> l_ref_designator_rec
	 , x_ref_desg_unexp_rec		=> l_ref_desg_unexp_rec
	 );

        --
        -- Covert the Eco Reference Designator Record to Bom
        --
        Bom_Bo_Pub.Convert_EcoDesg_To_BomDesg
        (  p_ref_designator_rec         => l_ref_designator_rec
         , p_ref_desg_unexp_rec         => l_ref_desg_unexp_rec
         , x_bom_ref_designator_rec     => x_bom_ref_designator_rec
         , x_bom_ref_desg_unexp_rec     => x_bom_ref_desg_unexp_rec
        );


END Populate_Null_Columns;


END BOM_Default_Ref_Designator;

/
