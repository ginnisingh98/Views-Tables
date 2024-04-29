--------------------------------------------------------
--  DDL for Package Body ENG_DEFAULT_ECO_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_DEFAULT_ECO_REVISION" AS
/* $Header: ENGDREVB.pls 115.10 2002/11/24 12:09:56 bbontemp ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ENG_Default_Eco_Revision';

--  Package global used within the package.

g_eco_revision_rec            ENG_Eco_PUB.Eco_Revision_Rec_Type;

--  Get functions.

FUNCTION Get_Revision
RETURN NUMBER
IS
X_RevId	NUMBER;
BEGIN

	SELECT ENG_CHANGE_ORDER_REVISIONS_S.NEXTVAL
	  INTO X_RevId
	  FROM SYS.DUAL;

	RETURN X_RevId;

END Get_Revision;

PROCEDURE Get_Flex_Eco_Revision
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_eco_revision_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute11 := NULL;
    END IF;

    IF g_eco_revision_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute12 := NULL;
    END IF;

    IF g_eco_revision_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute13 := NULL;
    END IF;

    IF g_eco_revision_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute14 := NULL;
    END IF;

    IF g_eco_revision_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute15 := NULL;
    END IF;

    IF g_eco_revision_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute_category := NULL;
    END IF;

    IF g_eco_revision_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute1  := NULL;
    END IF;

    IF g_eco_revision_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute2  := NULL;
    END IF;

    IF g_eco_revision_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute3  := NULL;
    END IF;

    IF g_eco_revision_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute4  := NULL;
    END IF;

    IF g_eco_revision_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute5  := NULL;
    END IF;

    IF g_eco_revision_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute6  := NULL;
    END IF;

    IF g_eco_revision_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute7  := NULL;
    END IF;

    IF g_eco_revision_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute8  := NULL;
    END IF;

    IF g_eco_revision_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute9  := NULL;
    END IF;

    IF g_eco_revision_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_eco_revision_rec.attribute10 := NULL;
    END IF;

END Get_Flex_Eco_Revision;

/*************************************************************************
*Procedure	: Attribute_Defaulting (Defaulting)
*Parameters IN	: Eco Revision Exposed columns record.
*		  Eco Revision Unexposed Column record.
*Parameters OUT : Eco Revision exposed column record after defaulting
* 		  Eco Revision uxposed column record after defaulting
*		  Mesg Token table
*		  Return_Status
*Purpose	: This procedure will default any exposed or unexposed
*		  columns and return the filled record back.
*		  In case of an error the Mesg Token table is filled and
*		  an error status is set.
**************************************************************************/
PROCEDURE Attribute_Defaulting
(   p_eco_revision_rec	IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_Eco_Rev_Unexp_Rec	IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
,   x_eco_revision_rec	IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Rec_Type
,   x_Eco_Rev_Unexp_Rec	IN OUT NOCOPY Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl	OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status	OUT NOCOPY VARCHAR2
)
IS
l_Eco_Rev_Unexp_Rec Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type;
BEGIN

    --  Initialize g_eco_revision_rec

    g_eco_revision_rec := p_eco_revision_rec;
    l_Eco_Rev_Unexp_Rec := p_Eco_Rev_Unexp_Rec;

    --  Default missing attributes.

--dbms_output.put_line('Performing Attribute defaulting . . .');

    IF l_Eco_Rev_Unexp_Rec.revision_id = FND_API.G_MISS_NUM 	OR
       g_eco_revision_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE OR
       NVL(l_Eco_Rev_Unexp_Rec.revision_id, 0) = 0
    THEN

        l_Eco_Rev_Unexp_Rec.revision_id := Get_Revision;

    END IF;

    IF g_eco_revision_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute_category = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_eco_revision_rec.attribute10 = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Eco_Revision;

    END IF;

        --  Done defaulting attributes

        x_eco_revision_rec := g_eco_revision_rec;
	x_Eco_Rev_Unexp_Rec := l_Eco_Rev_Unexp_Rec;

--    END IF;

END Attribute_Defaulting;


/**************************************************************************
*Procedure	: Populate_Null_Columns (earlier Complete_Record)
*Parameters IN	: Eco Revisions exposed column record
*		  Eco Revisions record from the Database
*Parameters OUT	: Eco Revisions completed record
*		  Mesg Token Table
*Purpose	: Complete record will take the Database record and compare
*		  it with the user record and complete it with the values from
*		  database, for all those columns that the user has left blank.
*		  User filled columns will not be overwritten.
***************************************************************************/
PROCEDURE Populate_Null_Columns
(   p_eco_revision_rec		IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_old_eco_revision_rec	IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_Eco_Rev_Unexp_Rec		IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
,   p_Old_Eco_Rev_Unexp_Rec	IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
,   x_Eco_Revision_Rec		IN OUT NOCOPY Eng_Eco_Pub.Eco_Revision_Rec_Type
,   x_Eco_Rev_Unexp_Rec		IN OUT NOCOPY Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
)
IS
l_eco_revision_rec	ENG_Eco_PUB.Eco_Revision_Rec_Type :=
			p_eco_revision_rec;
l_Eco_Rev_Unexp_Rec	Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type :=
			p_Eco_Rev_Unexp_Rec;
BEGIN

    --dbms_output.put_line('performing complete record . . . ');

--dbms_output.put_line('Revision_id : ' ||
--	to_char(p_old_Eco_Rev_Unexp_Rec.revision_id));
--dbms_output.put_line('Comment : ' || p_old_eco_revision_rec.comments);

    IF l_Eco_Revision_Rec.comments = FND_API.G_MISS_CHAR THEN
	l_Eco_Revision_Rec.comments := p_Old_Eco_Revision_Rec.Comments;
    END IF;

    IF l_eco_revision_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute11 := p_old_eco_revision_rec.attribute11;
    END IF;

    IF l_eco_revision_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute12 := p_old_eco_revision_rec.attribute12;
    END IF;

    IF l_eco_revision_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute13 := p_old_eco_revision_rec.attribute13;
    END IF;

    IF l_eco_revision_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute14 := p_old_eco_revision_rec.attribute14;
    END IF;

    IF l_eco_revision_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute15 := p_old_eco_revision_rec.attribute15;
    END IF;

    IF l_eco_revision_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute1 := p_old_eco_revision_rec.attribute1;
    END IF;

    IF l_eco_revision_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute2 := p_old_eco_revision_rec.attribute2;
    END IF;

    IF l_eco_revision_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute3 := p_old_eco_revision_rec.attribute3;
    END IF;

    IF l_eco_revision_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute4 := p_old_eco_revision_rec.attribute4;
    END IF;

    IF l_eco_revision_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute5 := p_old_eco_revision_rec.attribute5;
    END IF;

    IF l_eco_revision_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute6 := p_old_eco_revision_rec.attribute6;
    END IF;

    IF l_eco_revision_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute7 := p_old_eco_revision_rec.attribute7;
    END IF;

    IF l_eco_revision_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute8 := p_old_eco_revision_rec.attribute8;
    END IF;

    IF l_eco_revision_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute9 := p_old_eco_revision_rec.attribute9;
    END IF;

    IF l_eco_revision_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_eco_revision_rec.attribute10 := p_old_eco_revision_rec.attribute10;
    END IF;

    --- Complete the Unexposed Record too.

    IF l_Eco_Rev_Unexp_Rec.Revision_Id IS NULL OR
       l_Eco_Rev_Unexp_Rec.Revision_Id = FND_API.G_MISS_NUM
    THEN
	l_Eco_Rev_Unexp_Rec.Revision_Id := p_Old_Eco_Rev_Unexp_Rec.Revision_Id;
    END IF;

    -- Simply copy rest of the columns from old to new
    l_Eco_Rev_Unexp_Rec.Organization_Id :=
    p_Old_Eco_Rev_Unexp_Rec.Organization_Id;

    x_Eco_Revision_Rec := l_eco_revision_rec;
    x_Eco_Rev_Unexp_Rec := l_Eco_Rev_Unexp_Rec;

END Populate_Null_Columns;

END ENG_Default_Eco_Revision;

/
