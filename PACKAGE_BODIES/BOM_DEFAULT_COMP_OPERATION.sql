--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_COMP_OPERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_COMP_OPERATION" AS
/* $Header: BOMDCOPB.pls 120.0.12010000.2 2010/01/20 19:34:54 umajumde ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDCOPB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Default_Comp_Operation
--
--  NOTES
--
--  HISTORY
--  27-AUG-2001		Refai Farook	Initial Creation
--
--
***************************************************************************/
--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) :=
			      'BOM_Default_Comp_Operation';

ret_code		      NUMBER;

--  Package global used within the package.

g_bom_comp_ops_rec           Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type;

PROCEDURE Get_Flex_Comp_Operations IS
BEGIN

    IF g_bom_comp_ops_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute1 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute_category := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute1 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute2 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute3 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute4 := NULL;
    END IF;
    IF g_bom_comp_ops_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute5 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute6 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute7 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute8 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute9 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute10 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute11 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute12 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute13 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute14 := NULL;
    END IF;

    IF g_bom_comp_ops_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_bom_comp_ops_rec.attribute15 := NULL;
    END IF;

END;

/******************************************************************
* Procedure	: Attribute_Defaulting
* Parameter IN  : Component ops unexposed Record
*		  Component ops Record
* Parameter IN OUT NOCOPY : Return_Status
*                 Mesg_Token_Tbl
*		  Component ops Record
*		  Component ops Unexposed Record
* Purpose       : Attributes will call get functions for all columns
*		  that need to be defaulted.
*		  Defualting can happen for exposed as well as
*		  unexposed columns.
*******************************************************************/

PROCEDURE Attribute_Defaulting
(   p_bom_comp_ops_rec             IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_REC
,   p_bom_comp_ops_unexp_Rec	   IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
,   x_bom_comp_ops_rec             IN OUT NOCOPY Bom_Bo_Pub.Bom_COmp_Ops_Rec_Type
,   x_bom_comp_ops_unexp_Rec	   IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
,   x_Mesg_Token_Tbl		   IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status		   IN OUT NOCOPY VARCHAR2
)
IS
l_bom_comp_ops_rec                  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type;
stmt_num                            NUMBER := 0;
l_err_text			    VARCHAR2(255);
l_return_status			    VARCHAR2(10);
l_Mesg_Token_Tbl		    Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    l_bom_comp_ops_rec := p_bom_comp_ops_rec;

    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Comp Ops in attrib Defaulting ' || p_bom_comp_ops_Rec.operation_sequence_number); END IF;

    IF l_bom_comp_ops_rec.from_end_item_unit_number = FND_API.G_MISS_CHAR THEN
	l_bom_comp_ops_rec.from_end_item_unit_number := NULL;
    END IF;

    IF l_bom_comp_ops_rec.to_end_item_unit_number = FND_API.G_MISS_CHAR THEN
        l_bom_comp_ops_rec.to_end_item_unit_number := NULL;
    END IF;

/*
    IF l_bom_comp_ops_rec.alternate_bom_code = FND_API.G_MISS_CHAR THEN
        l_bom_comp_ops_rec.alternate_bom_code := NULL;
    END IF;
*/
    g_bom_comp_ops_rec := l_bom_comp_ops_rec;
    Get_Flex_Comp_Operations;
    l_bom_comp_ops_rec := g_bom_comp_ops_rec;

    x_return_status   := FND_API.G_RET_STS_SUCCESS;
    x_Mesg_Token_Tbl  := l_Mesg_Token_Tbl;

    x_bom_comp_ops_rec       := l_bom_comp_ops_rec;
    x_bom_comp_ops_unexp_Rec := p_bom_comp_ops_unexp_rec;


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Comp Ops Attrib Defaulting Done . . .'); END IF;

EXCEPTION

    WHEN OTHERS THEN
    	x_bom_comp_ops_rec       := l_bom_comp_ops_rec;
    	x_bom_comp_ops_unexp_Rec := p_bom_comp_ops_unexp_rec;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Attribute_Defaulting;

/******************************************************************************
* Procedure     : Populate_Null_Columns
* Parameters IN : Component ops exposed column record
*                 Component ops DB record of exposed columns
*                 Component ops unexposed column record
*                 Component ops DB record of unexposed columns
* Parameters OUT: Component ops exposed Record
*                 Component ops Unexposed Record
* Purpose       : Complete record will compare the database record with the
*                 user given record and will complete the user record with
*                 values from the database record, for all columns that the
*                 user has left NULL.
******************************************************************************/
PROCEDURE Populate_Null_Columns
( p_bom_comp_ops_rec                IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
, p_old_bom_comp_ops_rec            IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
, p_bom_comp_ops_unexp_rec          IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
, p_old_bom_comp_ops_unexp_rec      IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
, x_bom_comp_ops_rec               IN OUT NOCOPY  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
, x_bom_comp_ops_unexp_rec         IN OUT NOCOPY  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
)
IS
	l_bom_comp_ops_rec 	Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type :=
				p_bom_comp_ops_rec;
	l_bom_comp_ops_unexp_rec 	Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type :=
				p_bom_comp_ops_unexp_rec;
BEGIN

    IF l_bom_comp_ops_rec.from_end_item_unit_number IS NULL  THEN
        l_bom_comp_ops_rec.from_end_item_unit_number :=
          p_old_bom_comp_ops_rec.from_end_item_unit_number;
    END IF;

    IF l_bom_comp_ops_rec.to_end_item_unit_number IS NULL  THEN
        l_bom_comp_ops_rec.to_end_item_unit_number :=
                   p_old_bom_comp_ops_rec.to_end_item_unit_number;
    END IF;

    IF l_bom_comp_ops_rec.alternate_bom_code IS NULL  THEN
        l_bom_comp_ops_rec.alternate_bom_code :=
            p_old_bom_comp_ops_rec.alternate_bom_code;
    END IF;

    IF l_bom_comp_ops_rec.attribute_category IS NULL  THEN
        l_bom_comp_ops_rec.attribute_category :=
        p_old_bom_comp_ops_rec.attribute_category;
    END IF;

    IF l_bom_comp_ops_rec.attribute1 IS NULL  THEN
        l_bom_comp_ops_rec.attribute1 :=
        p_old_bom_comp_ops_rec.attribute1;
    END IF;

    IF l_bom_comp_ops_rec.attribute2 IS NULL  THEN
        l_bom_comp_ops_rec.attribute2 := p_old_bom_comp_ops_rec.attribute2;
    END IF;

    IF l_bom_comp_ops_rec.attribute3 IS NULL  THEN
        l_bom_comp_ops_rec.attribute3 := p_old_bom_comp_ops_rec.attribute3;
    END IF;

    IF l_bom_comp_ops_rec.attribute4 IS NULL  THEN
        l_bom_comp_ops_rec.attribute4 := p_old_bom_comp_ops_rec.attribute4;
    END IF;

    IF l_bom_comp_ops_rec.attribute5 IS NULL  THEN
        l_bom_comp_ops_rec.attribute5 := p_old_bom_comp_ops_rec.attribute5;
    END IF;

    IF l_bom_comp_ops_rec.attribute6 IS NULL  THEN
        l_bom_comp_ops_rec.attribute6 := p_old_bom_comp_ops_rec.attribute6;
    END IF;

    IF l_bom_comp_ops_rec.attribute7 IS NULL  THEN
        l_bom_comp_ops_rec.attribute7 := p_old_bom_comp_ops_rec.attribute7;
    END IF;

    IF l_bom_comp_ops_rec.attribute8 IS NULL  THEN
        l_bom_comp_ops_rec.attribute8 := p_old_bom_comp_ops_rec.attribute8;
    END IF;

    IF l_bom_comp_ops_rec.attribute9 IS NULL  THEN
        l_bom_comp_ops_rec.attribute9 := p_old_bom_comp_ops_rec.attribute9;
    END IF;

    IF l_bom_comp_ops_rec.attribute10 IS NULL  THEN
        l_bom_comp_ops_rec.attribute10 := p_old_bom_comp_ops_rec.attribute10;
    END IF;

    IF l_bom_comp_ops_rec.attribute11 IS NULL  THEN
        l_bom_comp_ops_rec.attribute11 := p_old_bom_comp_ops_rec.attribute11;
    END IF;

    IF l_bom_comp_ops_rec.attribute12 IS NULL  THEN
        l_bom_comp_ops_rec.attribute12 := p_old_bom_comp_ops_rec.attribute12;
    END IF;

    IF l_bom_comp_ops_rec.attribute13 IS NULL  THEN
        l_bom_comp_ops_rec.attribute13 := p_old_bom_comp_ops_rec.attribute13;
    END IF;

    IF l_bom_comp_ops_rec.attribute14 IS NULL  THEN
        l_bom_comp_ops_rec.attribute14 := p_old_bom_comp_ops_rec.attribute14;
    END IF;

    IF l_bom_comp_ops_rec.attribute15 IS NULL  THEN
        l_bom_comp_ops_rec.attribute15 := p_old_bom_comp_ops_rec.attribute15;
    END IF;

    g_bom_comp_ops_rec := l_bom_comp_ops_rec;
    Get_Flex_Comp_Operations;
    l_bom_comp_ops_rec := g_bom_comp_ops_rec;

    l_bom_comp_ops_unexp_rec := p_bom_comp_ops_unexp_Rec;
    if(p_bom_comp_ops_unexp_rec.additional_operation_seq_id is null  or
      p_bom_comp_ops_unexp_rec.additional_operation_seq_id = FND_API.G_MISS_NUM) then
     l_bom_comp_ops_unexp_rec.additional_operation_seq_id :=
			p_old_bom_comp_ops_unexp_rec.additional_operation_seq_id;
    end if;
    if(p_bom_comp_ops_unexp_rec.comp_operation_seq_id is null  or
      p_bom_comp_ops_unexp_rec.comp_operation_seq_id = FND_API.G_MISS_NUM) then
     l_bom_comp_ops_unexp_rec.comp_operation_seq_id :=
			p_old_bom_comp_ops_unexp_rec.comp_operation_seq_id;
    end if;
    --bug 8850425 changes
    --commenting out the following since rowid is a db column
    /*if(p_bom_comp_ops_unexp_rec.rowid is null  or
      p_bom_comp_ops_unexp_rec.rowid = FND_API.G_MISS_NUM) then
     l_bom_comp_ops_unexp_rec.rowid :=
			p_old_bom_comp_ops_unexp_rec.rowid ;
    end if; */
    if(p_bom_comp_ops_unexp_rec.component_sequence_id is null  or
      p_bom_comp_ops_unexp_rec.component_sequence_id = FND_API.G_MISS_NUM) then
     l_bom_comp_ops_unexp_rec.component_sequence_id :=
			p_old_bom_comp_ops_unexp_rec.component_sequence_id ;
    end if;
    if(p_bom_comp_ops_unexp_rec.bill_sequence_id is null  or
      p_bom_comp_ops_unexp_rec.bill_sequence_id = FND_API.G_MISS_NUM) then
     l_bom_comp_ops_unexp_rec.bill_sequence_id :=
			p_old_bom_comp_ops_unexp_rec.bill_sequence_id;
    end if;

    x_bom_comp_ops_unexp_rec := l_bom_comp_ops_unexp_Rec;
    x_bom_comp_ops_Rec       := l_bom_comp_ops_rec;

END Populate_Null_Columns;


END BOM_Default_Comp_Operation;

/
