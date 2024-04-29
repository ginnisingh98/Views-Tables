--------------------------------------------------------
--  DDL for Package Body BOM_DEFAULT_SUB_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DEFAULT_SUB_COMPONENT" AS
/* $Header: BOMDSBCB.pls 120.2 2005/12/29 00:21:49 dikrishn noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDSBCB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Default_Sub_Component
--
--  NOTES
--
--  HISTORY
--  17-JUL-1999	Rahul Chitko	Initial Creation
--
--
***************************************************************************/
--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) :=
			      'BOM_Default_Sub_Component';
ret_code		      NUMBER;

--  Package global used within the package.

g_sub_component_rec           Bom_Bo_Pub.Sub_Component_Rec_Type;

/******************************************************************
* Local Function: Get_Substitute_Item_Quantity
* Parameter IN	: Substitute Component unexposed Record
* Parameter OUT	: Return_Status
*		  Mesg_Token_Tbl
* Purpose	: Function will fetch the item quantity using the
*		  component sequence id key, from bom_inventory_components
*		  table and return it as the default value for
*		  Substitute_Item_Quantity
*******************************************************************/
FUNCTION Get_Substitute_Item_Quantity
	 (  x_return_status	  IN OUT NOCOPY VARCHAR2
  	  , x_Mesg_Token_Tbl	  IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	  , p_Sub_Comp_Unexp_Rec  IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
	  )
RETURN NUMBER
IS
l_sub_item_quantity  NUMBER;
l_Mesg_Token_Tbl     Error_Handler.Mesg_Token_Tbl_Type;
BEGIN
	   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	   --  Get Substitute Item quantity from the parent component
	   -- using the component sequence id.
	   ---+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SELECT component_quantity
          INTO l_sub_item_quantity
          FROM bom_inventory_components
         WHERE component_sequence_id =
		 p_Sub_Comp_Unexp_Rec.component_sequence_id;

       RETURN (l_sub_item_quantity);

       EXCEPTION
             WHEN OTHERS THEN
		Error_Handler.Add_Error_Token
		(  x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , p_message_name	=> NULL
		 , p_message_text	=>
		   'Substitute Component Attribute Validation ' ||
		   TO_CHAR(SQLCODE) || ' ' || SUBSTR(SQLERRM, 1, 100)
		 );
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        	RETURN FND_API.G_RET_STS_UNEXP_ERROR;

END Get_Substitute_Item_Quantity;

PROCEDURE Get_Flex_Sub_Component
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_sub_component_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute_category := NULL;
    END IF;

    IF g_sub_component_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute1 := NULL;
    END IF;

    IF g_sub_component_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute2 := NULL;
    END IF;

    IF g_sub_component_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute4 := NULL;
    END IF;

    IF g_sub_component_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute5 := NULL;
    END IF;

    IF g_sub_component_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute6 := NULL;
    END IF;

    IF g_sub_component_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute8 := NULL;
    END IF;

    IF g_sub_component_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute9 := NULL;
    END IF;

    IF g_sub_component_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute10 := NULL;
    END IF;

    IF g_sub_component_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute12 := NULL;
    END IF;

    IF g_sub_component_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute13 := NULL;
    END IF;

    IF g_sub_component_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute14 := NULL;
    END IF;

    IF g_sub_component_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute15 := NULL;
    END IF;

    IF g_sub_component_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute3 := NULL;
    END IF;

    IF g_sub_component_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute7 := NULL;
    END IF;

    IF g_sub_component_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_sub_component_rec.attribute11 := NULL;
    END IF;

END Get_Flex_Sub_Component;

/********************************************************************
 * Function      : Get_EnforceInteger_Value
 * Returns       : VARCHAR2
 * Purpose       : Will convert the value of enforce integer requirements code
 *               into enforce integer requirements value
 *                 If the conversion fails then the function will return
 *                 a NULL otherwise will return the code.
 *                 For an unexpected error function will return a
 *                 missing value.
 *********************************************************************/
        FUNCTION Get_EnforceInteger_Value
                 (  p_enforce_integer  IN  NUMBER)
                    RETURN VARCHAR2
        IS
                l_enforce_int_reqvalue  varchar2(80);
        BEGIN
                SELECT meaning INTO l_enforce_int_reqvalue FROM mfg_lookups WHERE
                        lookup_type = 'BOM_ENFORCE_INT_REQUIREMENTS' AND
                        lookup_code = p_enforce_integer;
                Return l_enforce_int_reqvalue;
                EXCEPTION WHEN OTHERS THEN
                        Return NULL;
        END;


/******************************************************************
* Procedure	: Attribute_Defaulting
* Parameter IN  : Substitute Component unexposed Record
*		  Substitute Component Record
* Parameter IN OUT NOCOPY : Return_Status
*                 Mesg_Token_Tbl
*		  Substitute Component Record
*		  Substitute Component Unexposed Record
* Purpose       : Attributes will call get functions for all columns
*		  that need to be defaulted.
*		  Defualting can happen for exposed as well as
*		  unexposed columns.
*******************************************************************/

PROCEDURE Attribute_Defaulting
(   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_SUB_COMPONENT_REC
,   p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
,   x_sub_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
,   x_Sub_Comp_Unexp_Rec	    IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl		    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status		    IN OUT NOCOPY VARCHAR2
)
IS
stmt_num                            NUMBER := 0;
l_err_text			    VARCHAR2(255);
l_return_status			    VARCHAR2(10);
l_Mesg_Token_Tbl		    Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    --  Initialize g_sub_component_rec

    x_return_status := FND_API.G_RET_STS_SUCCESS;


IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Comp Seq in attrib Defaulting ' || p_Sub_Comp_Unexp_Rec.component_sequence_id); END IF;

    stmt_num := 1;
    g_sub_component_rec := p_sub_component_rec;

   x_Sub_Comp_Unexp_Rec := p_Sub_Comp_Unexp_Rec;

   IF g_sub_component_rec.enforce_int_requirements IS NULL THEN
        x_sub_comp_unexp_rec.enforce_int_requirements_code := 0;
   END IF;

    stmt_num := 2;
    IF g_sub_component_rec.substitute_item_quantity = FND_API.G_MISS_NUM OR
      g_sub_component_rec.substitute_item_quantity IS NULL THEN

      -- Check if Inverse_Quanity value is available. If not default it from component.
      IF g_sub_component_rec.Inverse_Quantity = FND_API.G_MISS_NUM OR
        g_sub_component_rec.Inverse_Quantity IS NULL THEN

        g_sub_component_rec.substitute_item_quantity :=
            Get_Substitute_Item_Quantity
            (  x_return_status	=> l_return_status
             , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
             , p_Sub_Comp_Unexp_Rec	=> p_Sub_Comp_Unexp_Rec
             );
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Quantity Defaulted to : ' || to_char(g_sub_component_rec.substitute_item_quantity)); END IF;


        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            g_sub_component_rec.substitute_item_quantity := 0;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      ELSE
        IF g_sub_component_rec.Inverse_Quantity = 0 THEN
            g_sub_component_rec.substitute_item_quantity := 0;
        ELSE
            g_sub_component_rec.substitute_item_quantity := 1/g_sub_component_rec.Inverse_Quantity;
        END IF;
      END IF;
    END IF;

    IF g_sub_component_rec.acd_type = FND_API.G_MISS_NUM THEN
         g_sub_component_rec.acd_type := NULL;
    END IF;
/* bug2758790, form defaults the enforce req code to 0 and value to 'none' */

    IF (g_sub_component_rec.enforce_int_requirements = FND_API.G_MISS_CHAR
      or  g_sub_component_rec.enforce_int_requirements  is NULL )THEN
         g_sub_component_rec.enforce_int_requirements :=
			Get_EnforceInteger_Value(p_enforce_integer => 0);
    END IF;


    stmt_num :=3;
    IF g_sub_component_rec.attribute_category = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_sub_component_rec.attribute11 = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Sub_Component;

    END IF;

   --  Done defaulting attributes

   x_sub_component_rec := g_sub_component_rec;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Comps Attrib Defaulting Done . . .'); END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
--   	dbms_output.put_line('default sub_comp : ' || to_char(stmt_num));
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--	dbms_output.put_line('default sub_comp : ' || to_char(stmt_num));
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
--        dbms_output.put_line('default sub_comp : ' || to_char(stmt_num));

END Attribute_Defaulting;

/******************************************************************************
* Procedure     : Populate_Null_Columns (earlier called Complete_Record)
* Parameters IN : Substitute Component exposed column record
*                 Substitute Component DB record of exposed columns
*                 Substitute Component unexposed column record
*                 Substitute Component DB record of unexposed columns
* Parameters OUT: Substitute Component exposed Record
*                 Substitute Component Unexposed Record
* Purpose       : Complete record will compare the database record with the
*                 user given record and will complete the user record with
*                 values from the database record, for all columns that the
*                 user has left NULL.
******************************************************************************/
PROCEDURE Populate_Null_Columns
( p_sub_component_rec           IN  Bom_Bo_Pub.Sub_Component_Rec_Type
, p_old_sub_component_rec       IN  Bom_Bo_Pub.Sub_Component_Rec_Type
, p_sub_Comp_Unexp_Rec          IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
, p_Old_sub_Comp_Unexp_Rec      IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
, x_sub_Component_Rec           IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
, x_sub_Comp_Unexp_Rec          IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
)
IS
	l_sub_component_rec 	Bom_Bo_Pub.Sub_Component_Rec_Type :=
				p_sub_component_rec;
	l_sub_comp_Unexp_rec 	Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type :=
				p_old_sub_comp_Unexp_rec;
BEGIN

    IF (l_sub_component_rec.substitute_item_quantity = FND_API.G_MISS_NUM OR
          l_sub_component_rec.substitute_item_quantity IS NULL)
    THEN
        IF (l_sub_component_rec.Inverse_Quantity = FND_API.G_MISS_NUM OR
          l_sub_component_rec.Inverse_Quantity IS NULL)
        THEN
          l_sub_component_rec.substitute_item_quantity :=
            p_old_sub_component_rec.substitute_item_quantity;
        ELSE
           IF l_sub_component_rec.Inverse_Quantity = 0 THEN
              l_sub_component_rec.substitute_item_quantity := 0;
           ELSE
              l_sub_component_rec.substitute_item_quantity := 1/l_sub_component_rec.Inverse_Quantity;
           END IF;
        END IF;
    END IF;

    -- Bug 4913211. If clause incorrectly has a check for NOT NULL.
    -- Modified the if clause of all attributes to check for NULL

    IF l_sub_component_rec.attribute_category  IS NULL  THEN
        l_sub_component_rec.attribute_category :=
        p_old_sub_component_rec.attribute_category;
    END IF;

    IF l_sub_component_rec.attribute1  IS NULL  THEN
        l_sub_component_rec.attribute1 :=
        p_old_sub_component_rec.attribute1;
    END IF;

    IF l_sub_component_rec.attribute2  IS NULL  THEN
        l_sub_component_rec.attribute2 := p_old_sub_component_rec.attribute2;
    END IF;

    IF l_sub_component_rec.attribute4  IS NULL  THEN
        l_sub_component_rec.attribute4 := p_old_sub_component_rec.attribute4;
    END IF;

    IF l_sub_component_rec.attribute5  IS NULL  THEN
        l_sub_component_rec.attribute5 := p_old_sub_component_rec.attribute5;
    END IF;

    IF l_sub_component_rec.attribute6  IS NULL  THEN
        l_sub_component_rec.attribute6 := p_old_sub_component_rec.attribute6;
    END IF;

    IF l_sub_component_rec.attribute8  IS NULL  THEN
        l_sub_component_rec.attribute8 := p_old_sub_component_rec.attribute8;
    END IF;

    IF l_sub_component_rec.attribute9  IS NULL  THEN
        l_sub_component_rec.attribute9 := p_old_sub_component_rec.attribute9;
    END IF;

    IF l_sub_component_rec.attribute10  IS NULL  THEN
        l_sub_component_rec.attribute10 := p_old_sub_component_rec.attribute10;
    END IF;

    IF l_sub_component_rec.attribute12  IS NULL  THEN
        l_sub_component_rec.attribute12 := p_old_sub_component_rec.attribute12;
    END IF;

    IF l_sub_component_rec.attribute13  IS NULL  THEN
        l_sub_component_rec.attribute13 := p_old_sub_component_rec.attribute13;
    END IF;

    IF l_sub_component_rec.attribute14  IS NULL  THEN
        l_sub_component_rec.attribute14 := p_old_sub_component_rec.attribute14;
    END IF;

    IF l_sub_component_rec.attribute15  IS NULL  THEN
        l_sub_component_rec.attribute15 := p_old_sub_component_rec.attribute15;
    END IF;
/*
    IF l_sub_component_rec.program_id IS NOT NULL THEN
        l_sub_component_rec.program_id := p_old_sub_component_rec.program_id;
    END IF;
*/

    IF l_sub_component_rec.attribute3  IS NULL  THEN
        l_sub_component_rec.attribute3 := p_old_sub_component_rec.attribute3;
    END IF;

    IF l_sub_component_rec.attribute7  IS NULL  THEN
        l_sub_component_rec.attribute7 := p_old_sub_component_rec.attribute7;
    END IF;

    IF l_sub_component_rec.attribute11  IS NULL  THEN
        l_sub_component_rec.attribute11 := p_old_sub_component_rec.attribute11;
    END IF;

    /* Assign NULL if the values are MISSING */

    g_sub_component_rec := l_sub_component_rec;
    Get_Flex_Sub_Component;
    l_sub_component_rec := g_sub_component_rec;

    l_sub_comp_unexp_rec := p_Old_sub_Comp_Unexp_Rec; -- p_sub_comp_unexp_rec;
    If(p_sub_comp_unexp_rec.new_substitute_component_id is not null) then
     l_sub_comp_unexp_rec.new_substitute_component_id :=p_sub_comp_unexp_rec.new_substitute_component_id;
    end if;

    IF l_sub_component_rec.enforce_int_requirements = FND_API.G_MISS_CHAR THEN
	l_sub_comp_unexp_rec.enforce_int_requirements_code := NULL;
        l_sub_component_rec.enforce_int_requirements := NULL;
    ELSIF l_sub_component_rec.enforce_int_requirements IS NULL THEN
        l_sub_comp_unexp_rec.enforce_int_requirements_code := p_old_sub_comp_unexp_rec.enforce_int_requirements_code;
        l_sub_component_rec.enforce_int_requirements := p_old_sub_component_rec.enforce_int_requirements;
    ELSE
	l_sub_comp_unexp_rec.enforce_int_requirements_code := p_sub_comp_unexp_rec.enforce_int_requirements_code;
    END IF;

    x_Sub_Component_Rec  := l_sub_component_rec;
    x_Sub_Comp_Unexp_Rec  := l_sub_Comp_Unexp_rec;

END Populate_Null_Columns;

PROCEDURE Entity_Defaulting
(   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   p_old_sub_component_rec         IN  Bom_Bo_Pub.Sub_Component_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_Sub_COMPONENT_REC
,   x_sub_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
)
IS
BEGIN
	NULL;
END Entity_Defaulting;

/*
** Procedures for BOM Business Object
*/
PROCEDURE Attribute_Defaulting
(   p_bom_sub_component_rec       IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type :=
                                  Bom_Bo_Pub.G_MISS_Bom_SUB_COMPONENT_REC
,   p_bom_Sub_Comp_Unexp_Rec      IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
,   x_bom_sub_component_rec       IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
,   x_bom_Sub_Comp_Unexp_Rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
,   x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status               IN OUT NOCOPY VARCHAR2
)
IS
	l_sub_component_rec	Bom_Bo_Pub.Sub_Component_Rec_Type;
	l_sub_comp_unexp_rec	Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
BEGIN
	--
	-- Convert the BOM record to ECO
	--

if bom_globals.get_debug = 'Y' then Error_Handler.write_debug('Comp Seq before conversion ' || p_bom_sub_comp_unexp_rec.component_sequence_id); END IF;

	Bom_Bo_Pub.Convert_BomSComp_to_EcoSComp
	(  p_bom_sub_component_rec	=> p_bom_sub_component_rec
	 , p_bom_sub_comp_unexp_rec	=> p_bom_sub_comp_unexp_rec
	 , x_sub_component_rec		=> l_sub_component_rec
	 , x_sub_comp_unexp_rec		=> l_sub_comp_unexp_rec
	 );

	--
	-- Call Attribute Defaulting
	--
	Bom_Default_Sub_Component.Attribute_Defaulting
	(  p_sub_component_rec	=> l_sub_component_rec
	 , p_sub_comp_unexp_rec	=> l_sub_comp_unexp_rec
	 , x_sub_component_rec  => l_sub_component_rec
         , x_sub_comp_unexp_rec => l_sub_comp_unexp_rec
	 , x_mesg_token_tbl	=> x_mesg_token_tbl
	 , x_return_status	=> x_return_status
	);


        Bom_Bo_Pub.Convert_EcoSComp_to_BomSComp
        (  p_sub_component_rec      => l_sub_component_rec
         , p_sub_comp_unexp_rec     => l_sub_comp_unexp_rec
         , x_bom_sub_component_rec  => x_bom_sub_component_rec
         , x_bom_sub_comp_unexp_rec => x_bom_sub_comp_unexp_rec
         );
if bom_globals.get_debug = 'Y' then Error_Handler.write_debug('Qty after conversion: ' || l_sub_component_rec.substitute_item_quantity); END IF;

END Attribute_Defaulting;

PROCEDURE Populate_Null_Columns
( p_bom_sub_component_rec         IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
, p_old_bom_sub_component_rec     IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
, p_bom_sub_Comp_Unexp_Rec        IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
, p_Old_bom_sub_Comp_Unexp_Rec    IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
, x_bom_sub_Component_Rec         IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
, x_bom_sub_Comp_Unexp_Rec        IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
)
IS
        l_sub_component_rec     Bom_Bo_Pub.Sub_Component_Rec_Type;
        l_sub_comp_unexp_rec    Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
	l_old_sub_component_rec Bom_Bo_Pub.Sub_Component_Rec_Type;
	l_old_sub_comp_unexp_rec Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
BEGIN
        --
        -- Convert the BOM record to ECO
        --
        Bom_Bo_Pub.Convert_BomSComp_To_EcoSComp
        (  p_bom_sub_component_rec      => p_bom_sub_component_rec
         , p_bom_sub_comp_unexp_rec     => p_bom_sub_comp_unexp_rec
         , x_sub_component_rec          => l_sub_component_rec
         , x_sub_comp_unexp_rec         => l_sub_comp_unexp_rec
         );

	--
	-- Convert the old input record
	--

	Bom_Bo_Pub.Convert_BomSComp_To_EcoSComp
	(  p_bom_sub_component_rec      => p_old_bom_sub_component_rec
         , p_bom_sub_comp_unexp_rec     => p_old_bom_sub_comp_unexp_rec
         , x_sub_component_rec          => l_old_sub_component_rec
         , x_sub_comp_unexp_rec         => l_old_sub_comp_unexp_rec
         );


	--
	-- Call Populate Null Columns
	--
	Bom_Default_Sub_Component.Populate_Null_Columns
	(  p_sub_component_rec		=> l_sub_component_rec
	 , p_old_sub_component_rec	=> l_old_sub_component_rec
	 , p_sub_comp_unexp_rec		=> l_sub_comp_unexp_rec
	 , p_old_sub_comp_unexp_rec	=> l_old_sub_comp_unexp_rec
	 , x_sub_component_rec		=> l_sub_component_rec
	 , x_sub_comp_unexp_rec		=> l_sub_comp_unexp_rec
	);

	--
	-- Convert the ECO record back to BOM
	--

	Bom_Bo_Pub.Convert_EcoSComp_to_BomSComp
	(  p_sub_component_rec		=> l_sub_component_rec
	 , p_sub_comp_unexp_rec		=> l_sub_comp_unexp_rec
	 , x_bom_sub_component_rec	=> x_bom_sub_component_rec
	 , x_bom_sub_comp_unexp_rec	=> x_bom_sub_comp_unexp_rec
	);

END Populate_Null_Columns;

END BOM_Default_Sub_Component;

/
