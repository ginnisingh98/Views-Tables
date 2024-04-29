--------------------------------------------------------
--  DDL for Package Body ENG_REV_COMPONENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_REV_COMPONENT_UTIL" AS
/* $Header: ENGUCMPB.pls 115.20 2002/12/12 18:09:21 akumar ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ENG_Rev_Component_Util';

/***************************************************************************
* Procedure	: Convert_Miss_To_Null
* Parameters IN	: Revised component exposed column record
*		  Revised component unexposed column record
* Parameters OUT: Revised Component exposed column record
*		  Revised component unexposed column record.
* Purpose	: This procedure will convert all missing columns to NULL.
****************************************************************************/
PROCEDURE Convert_Miss_To_Null
( p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Rev_Component_Rec		IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
, x_Rev_Comp_Unexp_Rec		IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
)
IS
l_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type :=
			p_rev_component_rec;
l_Rev_Comp_Unexp_Rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type :=
			p_Rev_Comp_Unexp_Rec;
BEGIN

    IF l_rev_component_rec.supply_subinventory = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.supply_subinventory := NULL;
    END IF;

    IF l_rev_component_rec.required_for_revenue = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.required_for_revenue := NULL;
    END IF;

    IF l_rev_component_rec.maximum_allowed_quantity = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.maximum_allowed_quantity := NULL;
    END IF;


    IF l_rev_component_rec.wip_supply_type = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.wip_supply_type := NULL;
    END IF;

    IF l_rev_component_rec.location_name = FND_API.G_MISS_NUM THEN
        l_rev_comp_unexp_rec.supply_locator_id := NULL;
    END IF;

    IF l_rev_component_rec.operation_sequence_number = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.operation_sequence_number := NULL;
    END IF;

    IF l_rev_component_rec.item_sequence_number = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.item_sequence_number := NULL;
    END IF;

    IF l_rev_component_rec.quantity_per_assembly = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.quantity_per_assembly := NULL;
    END IF;

    IF l_rev_component_rec.projected_yield = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.projected_yield := NULL;
    END IF;

    IF l_rev_component_rec.comments = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.comments := NULL;
    END IF;

    IF l_rev_component_rec.start_effective_date = FND_API.G_MISS_DATE THEN
        l_rev_component_rec.start_effective_date := NULL;
    END IF;

    IF l_rev_component_rec.disable_date = FND_API.G_MISS_DATE THEN
        l_rev_component_rec.disable_date := NULL;
    END IF;

    IF l_rev_component_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute_category := NULL;
    END IF;

    IF l_rev_component_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute1 := NULL;
    END IF;

    IF l_rev_component_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute2 := NULL;
    END IF;

    IF l_rev_component_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute3 := NULL;
    END IF;

    IF l_rev_component_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute4 := NULL;
    END IF;

    IF l_rev_component_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute5 := NULL;
    END IF;

    IF l_rev_component_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute6 := NULL;
    END IF;

    IF l_rev_component_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute7 := NULL;
    END IF;

    IF l_rev_component_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute8 := NULL;
    END IF;

    IF l_rev_component_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute9 := NULL;
    END IF;

    IF l_rev_component_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute10 := NULL;
    END IF;

    IF l_rev_component_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute11 := NULL;
    END IF;

    IF l_rev_component_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute12 := NULL;
    END IF;

    IF l_rev_component_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute13 := NULL;
    END IF;

    IF l_rev_component_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute14 := NULL;
    END IF;

    IF l_rev_component_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.attribute15 := NULL;
    END IF;

    IF l_rev_component_rec.planning_percent = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.planning_percent := NULL;
    END IF;

    IF l_rev_component_rec.quantity_related = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.quantity_related := NULL;
    END IF;

    IF l_rev_component_rec.so_basis = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.so_basis := NULL;
    END IF;

    IF l_rev_component_rec.optional = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.optional := NULL;
    END IF;

    IF l_rev_component_rec.mutually_exclusive = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.mutually_exclusive := NULL;
    END IF;

    IF l_rev_component_rec.include_in_cost_rollup = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.include_in_cost_rollup := NULL;
    END IF;

    IF l_rev_component_rec.check_atp = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.check_atp := NULL;
    END IF;

    IF l_rev_component_rec.shipping_allowed = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.shipping_allowed := NULL;
    END IF;

    IF l_rev_component_rec.required_to_ship = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.required_to_ship := NULL;
    END IF;

    IF l_rev_component_rec.include_on_ship_docs = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.include_on_ship_docs := NULL;
    END IF;

    IF l_rev_component_rec.minimum_allowed_quantity = FND_API.G_MISS_NUM THEN
        l_rev_component_rec.minimum_allowed_quantity := NULL;
    END IF;

    x_Rev_Component_Rec := l_rev_component_rec;
    x_Rev_Comp_Unexp_Rec := l_Rev_Comp_Unexp_Rec;

END Convert_Miss_To_Null;

/***************************************************************************
* Procedure	: Update_Row
* Parameters IN : Revised Component exposed column record
*		  Revised Component unexposed column record
* Parameters OUT: Mesg_Token_Tbl
*		  Return_Status
* Purpose	: Update_Row procedure will update the production record with
*		  the user given values. Any errors will be returned by filling
*		  the Mesg_Token_Tbl and setting the return_status.
****************************************************************************/
PROCEDURE Update_Row
( p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
l_return_status         varchar2(80);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_rev_component_rec    Bom_Bo_Pub.Rev_Component_Rec_Type;
l_err_text                    VARCHAR2(2000);
BEGIN

    UPDATE  BOM_INVENTORY_COMPONENTS
    SET     SUPPLY_SUBINVENTORY	 = p_rev_component_rec.supply_subinventory
    ,       REQUIRED_FOR_REVENUE = p_rev_component_rec.required_for_revenue
    ,       HIGH_QUANTITY        = p_rev_component_rec.maximum_allowed_quantity
    ,       WIP_SUPPLY_TYPE      = p_rev_component_rec.wip_supply_type
    ,       SUPPLY_LOCATOR_ID    =
	DECODE(p_rev_comp_Unexp_rec.supply_locator_id, FND_API.G_MISS_NUM,
	       NULL, p_rev_comp_Unexp_rec.supply_locator_id)
    ,       OPERATION_SEQ_NUM    =
	DECODE(p_rev_component_rec.new_operation_sequence_number,
	       NULL,p_rev_component_rec.operation_sequence_number,
	       p_rev_component_Rec.new_operation_sequence_number
	       )
    ,       LAST_UPDATE_DATE     = SYSDATE
    ,       LAST_UPDATED_BY      = Bom_Globals.Get_User_Id
    ,       LAST_UPDATE_LOGIN    = Bom_Globals.Get_User_Id
    ,       ITEM_NUM             = p_rev_component_rec.item_sequence_number
    ,       COMPONENT_QUANTITY   = p_rev_component_rec.quantity_per_assembly
    ,       COMPONENT_YIELD_FACTOR = p_rev_component_rec.projected_yield
    ,       COMPONENT_REMARKS      = p_rev_component_rec.comments
    ,       DISABLE_DATE           = p_rev_component_rec.disable_date
    ,       ATTRIBUTE_CATEGORY     = p_rev_component_rec.attribute_category
    ,       ATTRIBUTE1             = p_rev_component_rec.attribute1
    ,       ATTRIBUTE2             = p_rev_component_rec.attribute2
    ,       ATTRIBUTE3             = p_rev_component_rec.attribute3
    ,       ATTRIBUTE4             = p_rev_component_rec.attribute4
    ,       ATTRIBUTE5             = p_rev_component_rec.attribute5
    ,       ATTRIBUTE6             = p_rev_component_rec.attribute6
    ,       ATTRIBUTE7             = p_rev_component_rec.attribute7
    ,       ATTRIBUTE8             = p_rev_component_rec.attribute8
    ,       ATTRIBUTE9             = p_rev_component_rec.attribute9
    ,       ATTRIBUTE10            = p_rev_component_rec.attribute10
    ,       ATTRIBUTE11            = p_rev_component_rec.attribute11
    ,       ATTRIBUTE12            = p_rev_component_rec.attribute12
    ,       ATTRIBUTE13            = p_rev_component_rec.attribute13
    ,       ATTRIBUTE14            = p_rev_component_rec.attribute14
    ,       ATTRIBUTE15            = p_rev_component_rec.attribute15
    ,       PLANNING_FACTOR        = p_rev_component_rec.planning_percent
    ,       QUANTITY_RELATED       = p_rev_component_rec.quantity_related
    ,       SO_BASIS               = p_rev_component_rec.so_basis
    ,       OPTIONAL               = p_rev_component_rec.optional
    ,       MUTUALLY_EXCLUSIVE_OPTIONS = p_rev_component_rec.mutually_exclusive
    ,       INCLUDE_IN_COST_ROLLUP = p_rev_component_rec.include_in_cost_rollup
    ,       CHECK_ATP              = p_rev_component_rec.check_atp
    ,       SHIPPING_ALLOWED       = p_rev_component_rec.shipping_allowed
    ,       REQUIRED_TO_SHIP       = p_rev_component_rec.required_to_ship
    ,       INCLUDE_ON_SHIP_DOCS   = p_rev_component_rec.include_on_ship_docs
    ,       LOW_QUANTITY          = p_rev_component_rec.minimum_allowed_quantity
    ,       ACD_TYPE               = p_rev_component_rec.acd_type
    ,       PROGRAM_UPDATE_DATE    = SYSDATE
    ,	    PROGRAM_ID		   = Bom_Globals.Get_Prog_Id
    ,	    Original_System_Reference =
                                 p_rev_component_rec.original_system_reference
    ,       From_End_Item_Unit_Number =
			p_rev_component_rec.from_end_item_unit_number
    ,       To_End_Item_Unit_Number =
			p_rev_component_rec.to_end_item_unit_number
    WHERE   COMPONENT_SEQUENCE_ID = p_Rev_Comp_Unexp_Rec.component_sequence_id
    ;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
		l_err_text := G_PKG_NAME ||
                              ' : Utility (Component Update) ' ||
                              SUBSTR(SQLERRM, 1, 200);
                Error_Handler.Add_Error_Token
		(  p_Message_Name	=> NULL
		 , p_Message_Text	=> l_err_text
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		);
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;

        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Row;

/*****************************************************************************
* Procedure	: Insert_Row
* Parameters IN	: Revised Component exposed column record
*		  Revised Component unexposed column record
* Parameters OUT: Mesg_Token_Tbl
*		  Return_Status
* Purpose	: This procedure will insert a record in the bom_inventory-
*		  component table. Any errors will be filled in the Mesg_Token
*		  Tbl and returned with a return_status of U
*****************************************************************************/
PROCEDURE Insert_Row
( p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
l_err_text		VARCHAR2(2000);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    INSERT  INTO BOM_INVENTORY_COMPONENTS
    (       SUPPLY_SUBINVENTORY
    ,       OPERATION_LEAD_TIME_PERCENT
    ,       REVISED_ITEM_SEQUENCE_ID
    ,       COST_FACTOR
    ,       REQUIRED_FOR_REVENUE
    ,       HIGH_QUANTITY
    ,       COMPONENT_SEQUENCE_ID
    ,       PROGRAM_APPLICATION_ID
    ,       WIP_SUPPLY_TYPE
    ,       SUPPLY_LOCATOR_ID
    ,       BOM_ITEM_TYPE
    ,       OPERATION_SEQ_NUM
    ,       COMPONENT_ITEM_ID
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       ITEM_NUM
    ,       COMPONENT_QUANTITY
    ,       COMPONENT_YIELD_FACTOR
    ,       COMPONENT_REMARKS
    ,       EFFECTIVITY_DATE
    ,       CHANGE_NOTICE
    ,       IMPLEMENTATION_DATE
    ,       DISABLE_DATE
    ,       ATTRIBUTE_CATEGORY
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       PLANNING_FACTOR
    ,       QUANTITY_RELATED
    ,       SO_BASIS
    ,       OPTIONAL
    ,       MUTUALLY_EXCLUSIVE_OPTIONS
    ,       INCLUDE_IN_COST_ROLLUP
    ,       CHECK_ATP
    ,       SHIPPING_ALLOWED
    ,       REQUIRED_TO_SHIP
    ,       INCLUDE_ON_SHIP_DOCS
    ,       INCLUDE_ON_BILL_DOCS
    ,       LOW_QUANTITY
    ,       ACD_TYPE
    ,       OLD_COMPONENT_SEQUENCE_ID
    ,       BILL_SEQUENCE_ID
    ,       REQUEST_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PICK_COMPONENTS
    ,       Original_System_Reference
    ,       From_End_Item_Unit_Number
    , 	    To_End_Item_Unit_Number
    )
    VALUES
    (       p_rev_component_rec.supply_subinventory
    ,       NULL /* Operation Lead Time Percent */
    ,       p_rev_comp_unexp_rec.revised_item_sequence_id
    ,       NULL /* Cost Factor */
    ,       p_rev_component_rec.required_for_revenue
    ,       p_rev_component_rec.maximum_allowed_quantity
    ,       p_rev_comp_Unexp_rec.component_sequence_id
    ,       Bom_Globals.Get_Prog_AppId
    ,       p_rev_component_rec.wip_supply_type
    ,       DECODE(p_rev_comp_Unexp_rec.supply_locator_id, FND_API.G_MISS_NUM,
		   NULL, p_rev_comp_Unexp_rec.supply_locator_id)
    ,       p_rev_comp_Unexp_rec.bom_item_type
    ,       p_rev_component_rec.operation_sequence_number
    ,       p_rev_comp_Unexp_rec.component_item_id
    ,       SYSDATE /* Last Update Date */
    ,       Bom_Globals.Get_User_Id /* Last Updated By */
    ,       SYSDATE /* Creation Date */
    ,       Bom_Globals.Get_User_Id /* Created By */
    ,       Bom_Globals.Get_User_Id /* Last Update Login */
    ,       p_rev_component_rec.item_sequence_number
    ,       p_rev_component_rec.quantity_per_assembly
    ,       p_rev_component_rec.projected_yield
    ,       p_rev_component_rec.comments
    ,       p_rev_component_rec.start_effective_date
    ,       p_rev_component_rec.Eco_Name
    ,       NULL /* Implementation Date */
    ,       p_rev_component_rec.disable_date
    ,       p_rev_component_rec.attribute_category
    ,       p_rev_component_rec.attribute1
    ,       p_rev_component_rec.attribute2
    ,       p_rev_component_rec.attribute3
    ,       p_rev_component_rec.attribute4
    ,       p_rev_component_rec.attribute5
    ,       p_rev_component_rec.attribute6
    ,       p_rev_component_rec.attribute7
    ,       p_rev_component_rec.attribute8
    ,       p_rev_component_rec.attribute9
    ,       p_rev_component_rec.attribute10
    ,       p_rev_component_rec.attribute11
    ,       p_rev_component_rec.attribute12
    ,       p_rev_component_rec.attribute13
    ,       p_rev_component_rec.attribute14
    ,       p_rev_component_rec.attribute15
    ,       p_rev_component_rec.planning_percent
    ,       p_rev_component_rec.quantity_related
    ,       p_rev_component_rec.so_basis
    ,       p_rev_component_rec.optional
    ,       p_rev_component_rec.mutually_exclusive
    ,       p_rev_component_rec.include_in_cost_rollup
    ,       p_rev_component_rec.check_atp
    ,       p_rev_component_rec.shipping_allowed
    ,       p_rev_component_rec.required_to_ship
    ,       p_rev_component_rec.include_on_ship_docs
    ,       NULL /* Include On Bill Docs */
    ,       p_rev_component_rec.minimum_allowed_quantity
    ,       p_rev_component_rec.acd_type
    ,       p_rev_comp_Unexp_rec.old_component_sequence_id
    ,       p_rev_comp_Unexp_rec.bill_sequence_id
    ,       NULL /* Request Id */
    ,       Bom_Globals.Get_Prog_Id
    ,       SYSDATE /* program_update_date */
    ,       p_rev_comp_Unexp_rec.pick_components
    ,	    p_rev_component_rec.original_system_reference
    ,	    p_rev_component_rec.from_end_item_unit_number
    ,       p_rev_component_rec.to_end_item_unit_number
    );

	x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN
--dbms_output.put_line('Unexpected Error occured in Insert . . .' || SQLERRM);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
		l_err_text := G_PKG_NAME ||
                              ' : Utility (Component Insert) ' ||
			      SUBSTR(SQLERRM, 1, 200);
                Error_Handler.Add_Error_Token
		(  p_Message_Name	=> NULL
		 , p_Message_Text	=> l_err_text
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		);
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;

        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Row;

/****************************************************************************
* Procedure	: Delete_Row
* Parameters IN : Revised Component Key
* Parameters OUT: Mesg_Token_Tbl
*		  Return_Status
* Purpose	: Will delete a revised component record for a ECO.
*		  Delete operation will not delete a record in production which
*		  is already implemented.
*****************************************************************************/
PROCEDURE Delete_Row
( p_component_sequence_id	IN  NUMBER
, x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
l_dummy number;
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    DELETE  FROM BOM_INVENTORY_COMPONENTS
    WHERE   COMPONENT_SEQUENCE_ID = p_component_sequence_id;

    /******************************************************************
    -- Also delete the Substitute components and Reference designators
    -- by first logging a warning notifying the user of the cascaded
    -- Delete.
    *******************************************************************/

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
		-- This is a warning.
        THEN
                Error_Handler.Add_Error_Token
		(  p_Message_Name	=> 'ENG_COMP_DEL_CHILDREN'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 );
        END IF;

	DELETE from bom_reference_designators
	 WHERE component_sequence_id = p_component_sequence_id;

	DELETE from bom_substitute_components
	 WHERE component_Sequence_id = p_component_sequence_id;

	x_Return_Status := FND_API.G_RET_STS_SUCCESS;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
       		Error_Handler.Add_Error_Token
		(  p_Message_Name	=> NULL
		 , p_Message_Text	=> 'Error Rev. Comp Delete Row ' ||
					  SUBSTR(SQLERRM, 1, 100)
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		);
		x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
	END IF;
		x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END Delete_Row;

--  Function Query_Row

PROCEDURE Query_Row
( p_Component_Item_Id           IN  NUMBER
, p_Operation_Sequence_Number   IN  NUMBER
, p_Effectivity_Date            IN  DATE
, p_Bill_Sequence_Id            IN  NUMBER
, p_from_end_item_number	IN  VARCHAR2 := NULL
, x_Rev_Component_Rec           OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
, x_Rev_Comp_Unexp_Rec          OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Return_Status               OUT NOCOPY VARCHAR2
)
IS
l_rev_component_rec	Bom_Bo_Pub.Rev_Component_Rec_Type;
l_Rev_Comp_Unexp_Rec	Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
l_err_text		VARCHAR2(2000);
BEGIN

--dbms_output.put_line('Querying component record . . .');
--dbms_output.put_line('Component: ' || to_char(p_Component_Item_Id));
--dbms_output.put_line('Op Seq   : ' || to_char(p_Operation_Sequence_Number));
--dbms_output.put_line('Effective: ' || to_char(p_Effectivity_Date));
--dbms_output.put_line('Bill Seq : ' || to_char(p_Bill_Sequence_Id));

    SELECT  SUPPLY_SUBINVENTORY
    ,       REVISED_ITEM_SEQUENCE_ID
    ,       REQUIRED_FOR_REVENUE
    ,       HIGH_QUANTITY
    ,       COMPONENT_SEQUENCE_ID
    ,       WIP_SUPPLY_TYPE
    ,       SUPPLY_LOCATOR_ID
    ,       BOM_ITEM_TYPE
    ,       OPERATION_SEQ_NUM
    ,       COMPONENT_ITEM_ID
    ,       ITEM_NUM
    ,       COMPONENT_QUANTITY
    ,       COMPONENT_YIELD_FACTOR
    ,       COMPONENT_REMARKS
    ,       EFFECTIVITY_DATE
    ,       CHANGE_NOTICE
    ,       DISABLE_DATE
    ,       ATTRIBUTE_CATEGORY
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       PLANNING_FACTOR
    ,       QUANTITY_RELATED
    ,       SO_BASIS
    ,       OPTIONAL
    ,       MUTUALLY_EXCLUSIVE_OPTIONS
    ,       INCLUDE_IN_COST_ROLLUP
    ,       CHECK_ATP
    ,       SHIPPING_ALLOWED
    ,       REQUIRED_TO_SHIP
    ,       INCLUDE_ON_SHIP_DOCS
    ,       LOW_QUANTITY
    ,       ACD_TYPE
    ,       OLD_COMPONENT_SEQUENCE_ID
    ,       BILL_SEQUENCE_ID
    ,       PICK_COMPONENTS
    ,       FROM_END_ITEM_UNIT_NUMBER
    ,       TO_END_ITEM_UNIT_NUMBER
    INTO    l_rev_component_rec.supply_subinventory
    ,       l_rev_comp_Unexp_rec.revised_item_sequence_id
    ,       l_rev_component_rec.required_for_revenue
    ,       l_rev_component_rec.maximum_allowed_quantity
    ,       l_rev_comp_Unexp_rec.component_sequence_id
    ,       l_rev_component_rec.wip_supply_type
    ,       l_rev_comp_Unexp_rec.supply_locator_id
    ,       l_rev_comp_Unexp_rec.bom_item_type
    ,       l_rev_component_rec.operation_sequence_number
    ,       l_rev_comp_Unexp_rec.component_item_id
    ,       l_rev_component_rec.item_sequence_number
    ,       l_rev_component_rec.quantity_per_assembly
    ,       l_rev_component_rec.projected_yield
    ,       l_rev_component_rec.comments
    ,       l_rev_component_rec.start_effective_date
    ,       l_rev_component_rec.Eco_Name
    ,       l_rev_component_rec.disable_date
    ,       l_rev_component_rec.attribute_category
    ,       l_rev_component_rec.attribute1
    ,       l_rev_component_rec.attribute2
    ,       l_rev_component_rec.attribute3
    ,       l_rev_component_rec.attribute4
    ,       l_rev_component_rec.attribute5
    ,       l_rev_component_rec.attribute6
    ,       l_rev_component_rec.attribute7
    ,       l_rev_component_rec.attribute8
    ,       l_rev_component_rec.attribute9
    ,       l_rev_component_rec.attribute10
    ,       l_rev_component_rec.attribute11
    ,       l_rev_component_rec.attribute12
    ,       l_rev_component_rec.attribute13
    ,       l_rev_component_rec.attribute14
    ,       l_rev_component_rec.attribute15
    ,       l_rev_component_rec.planning_percent
    ,       l_rev_component_rec.quantity_related
    ,       l_rev_component_rec.so_basis
    ,       l_rev_component_rec.optional
    ,       l_rev_component_rec.mutually_exclusive
    ,       l_rev_component_rec.include_in_cost_rollup
    ,       l_rev_component_rec.check_atp
    ,       l_rev_component_rec.shipping_allowed
    ,       l_rev_component_rec.required_to_ship
    ,       l_rev_component_rec.include_on_ship_docs
    ,       l_rev_component_rec.minimum_allowed_quantity
    ,       l_rev_component_rec.acd_type
    ,       l_rev_comp_unexp_rec.old_component_sequence_id
    ,       l_rev_comp_unexp_rec.bill_sequence_id
    ,       l_rev_comp_unexp_rec.pick_components
    ,       l_rev_component_rec.from_end_item_unit_number
    ,       l_rev_component_rec.to_end_item_unit_number
    FROM    BOM_INVENTORY_COMPONENTS
    WHERE   component_item_id = p_component_item_id
      AND   effectivity_date  = p_effectivity_date
      AND   operation_seq_num = p_operation_sequence_number
      AND   bill_sequence_id  = p_bill_sequence_id
      AND   NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR) =
		NVL(p_from_end_item_number, FND_API.G_MISS_CHAR);
--dbms_output.put_line('Finished querying and assigning component record . . .');

    x_Return_Status := Bom_Globals.G_RECORD_FOUND;
    x_Rev_Component_Rec := l_rev_component_rec;
    x_Rev_Comp_Unexp_Rec := l_Rev_Comp_Unexp_Rec;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
	x_return_status := Bom_Globals.G_RECORD_NOT_FOUND;
	x_rev_component_rec := l_rev_component_rec;
	x_Rev_Comp_Unexp_Rec := l_Rev_Comp_Unexp_Rec;

    WHEN OTHERS THEN
	l_err_text := G_PKG_NAME || ' Utility (Component Query Row) '
                                || substrb(SQLERRM,1,200);
--dbms_output.put_line('Unexpected Error: ' || l_err_text);

        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Query_Row;

PROCEDURE Cancel_Component(  p_component_sequence_id	IN  NUMBER
			   , p_cancel_comments		IN  VARCHAR2
			   , p_user_id			IN  NUMBER
			   , p_login_id			IN  NUMBER
			   )
IS
BEGIN
	ENG_Cancel_ECO.Cancel_Revised_Component
       ( comp_seq_id => p_component_sequence_id,
         user_id     => p_user_id,
         login       => p_login_id,
         comment     => p_cancel_comments
        );
END Cancel_Component;

PROCEDURE Perform_Writes(  p_rev_component_rec  IN
                           Bom_Bo_Pub.Rev_Component_Rec_Type
                         , p_rev_comp_unexp_rec IN
                           Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
                         , x_Mesg_Token_Tbl     OUT NOCOPY
                           Error_Handler.Mesg_Token_Tbl_Type
                         , x_Return_Status      OUT NOCOPY VARCHAR2
                         )
IS
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
	l_Rev_component_Rec	Bom_Bo_Pub.Rev_Component_rec_Type;
	l_rev_comp_unexp_rec	Bom_Bo_Pub.rev_comp_unexposed_rec_type;
	l_return_status		VARCHAR2(1);
	l_assembly_type		NUMBER;
	l_Comp_Seq_Id		NUMBER;
	CURSOR c_CheckBillExists IS
		SELECT 1
		  FROM sys.dual
		 WHERE NOT EXISTS
		       ( SELECT bill_sequence_id
			   FROM bom_bill_of_materials
			  WHERE assembly_item_id =
				l_rev_comp_unexp_rec.revised_item_id
			    AND organization_id =
				l_rev_comp_unexp_rec.organization_id
			    AND NVL(alternate_bom_designator, 'NONE') =
				NVL(l_rev_component_rec.alternate_bom_code,
				    'NONE')
			 );

BEGIN
	l_rev_component_rec := p_rev_component_rec;
	l_rev_comp_unexp_rec := p_rev_comp_unexp_rec;
	l_return_status := FND_API.G_RET_STS_SUCCESS;

        IF l_Rev_Component_Rec.Transaction_Type = Bom_GLOBALS.G_OPR_CREATE THEN

--dbms_output.put_line('Test Harness: Executing Insert Row. . . ');

	    FOR CheckBillExists IN c_CheckBillExists LOOP
		-- Loop executes then the bill does not exist.
		-- Procedure Create_New_Bill
		SELECT decode(eng_item_flag, 'N', 1, 2)
		  INTO l_assembly_type
		  FROM mtl_system_items
		 WHERE inventory_item_id = l_rev_comp_unexp_rec.revised_item_id
		   AND organization_id = l_rev_comp_unexp_rec.organization_id;


		--
		-- Log a warning indicating that a new bill has been created
		-- as a result of the component being added.
		--
		Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_NEW_PRIMARY_CREATED'
                 , p_Message_Text       => NULL
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );

		Eng_Rev_Component_Util.Create_New_Bill
		(  p_assembly_item_id		=>
				l_rev_comp_unexp_rec.revised_item_id
                 , p_organization_id		=>
				l_rev_comp_unexp_rec.organization_id
                 , p_pending_from_ecn		=>
				l_rev_component_rec.eco_name
                 , p_bill_sequence_id		=>
				l_rev_comp_unexp_rec.bill_sequence_id
                 , p_common_bill_sequence_id	=>
				l_rev_comp_unexp_rec.bill_sequence_id
                 , p_assembly_type		=> l_assembly_type
		 , p_last_update_date		=> SYSDATE
                 , p_last_updated_by		=> Bom_Globals.Get_User_Id
                 , p_creation_date		=> SYSDATE
                 , p_created_by			=> Bom_Globals.Get_User_Id
                 , p_revised_item_seq_id	=>
				l_rev_comp_unexp_rec.revised_item_sequence_id
                 , p_original_system_reference	=>
				l_rev_component_rec.original_system_reference);
	    END LOOP;

            Insert_Row
            (   p_Rev_component_rec   => l_Rev_Component_Rec
             ,  p_Rev_Comp_Unexp_Rec  => l_Rev_Comp_Unexp_Rec
             ,  x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
             ,  x_return_status   => l_Return_Status
             );
        ELSIF l_Rev_Component_Rec.Transaction_Type = Bom_GLOBALS.G_OPR_UPDATE
        THEN

--dbms_output.put_line('Test Harness: Executing Update Row. . . ');

            Update_Row
            (   p_Rev_component_rec   => l_Rev_Component_Rec
             ,  p_Rev_Comp_Unexp_Rec  => l_Rev_Comp_Unexp_Rec
             ,  x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
             ,  x_return_status   => l_Return_Status
            );
        ELSIF l_Rev_Component_Rec.Transaction_Type = Bom_GLOBALS.G_OPR_DELETE
        THEN

--dbms_output.put_line('Test Harness: Executing Delete Row. . . ');

            Delete_Row
            (   p_component_sequence_id         =>
                l_Rev_Comp_Unexp_Rec.Component_Sequence_Id
            ,   x_Mesg_Token_Tbl                => l_Mesg_Token_Tbl
            ,   x_return_status                 => l_Return_Status
            );
	ELSIF l_Rev_Component_Rec.Transaction_Type = Bom_GLOBALS.G_OPR_CANCEL
	THEN
--dbms_output.put_line('Perform Cancel Component . . .');

		--
		-- Fetch Component Sequence Id
		--
		SELECT component_sequence_id
		  INTO l_comp_seq_id
		  FROM bom_inventory_components
		 WHERE component_item_id =
			l_rev_comp_unexp_rec.component_item_id
		   AND bill_sequence_id = l_rev_comp_unexp_rec.bill_sequence_id
		   AND operation_seq_num =
			l_rev_component_rec.operation_sequence_number
		   AND effectivity_date =
			l_rev_component_rec.start_Effective_date;

		--
		-- Log a warning indicating reference designators and
		-- substitute components will also get deleted.
		--
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_COMP_CANCEL_DEL_CHILDREN'
                 , p_Message_Text       => NULL
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );

		Eng_Rev_Component_Util.Cancel_Component
		(  p_component_sequence_id	=>
			l_comp_seq_id
		 , p_cancel_comments		=>
			l_rev_component_rec.cancel_comments
		 , p_user_id			=>
			Bom_Globals.Get_User_ID
		 , p_login_id			=>
			Bom_Globals.Get_Login_ID
		);

        END IF;

END Perform_Writes;

/************ PROCEDURE NOT USED *************************************/
PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_rev_component_rec             IN  Bom_Bo_Pub.Rev_Component_Rec_Type
,   x_rev_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
,   x_err_text			    OUT NOCOPY VARCHAR2
)
IS
l_rev_component_rec           Bom_Bo_Pub.Rev_Component_Rec_Type;
BEGIN
	null;
END Lock_Row;


/******************************************************************************
* Procedure	: Create_New_Bill
* Parameters IN	: Assembly Item ID
*		  Organization ID
*		  Pending from ECN
*		  common_bill_sequence_id
*		  assembly_type
*		  WHO columns
*		  revised_item_sequence_id
* Purpose	: This procedure will be called when a revised component is
*		  the first component being added on a revised item. This
*		  procedure will create a Bill and update the revised item
*		  information indicating that bill for this revised item now
*		  exists.
******************************************************************************/
PROCEDURE Create_New_Bill(  p_assembly_item_id           IN NUMBER
                          , p_organization_id            IN NUMBER
                          , p_pending_from_ecn 	       	 IN VARCHAR2
                          , p_bill_sequence_id           IN NUMBER
                          , p_common_bill_sequence_id    IN NUMBER
                          , p_assembly_type              IN NUMBER
                          , p_last_update_date           IN DATE
                          , p_last_updated_by            IN NUMBER
                          , p_creation_date              IN DATE
                          , p_created_by                 IN NUMBER
			  , p_revised_item_seq_id	 IN NUMBER
                          , p_original_system_reference	 IN VARCHAR2)
IS
BEGIN
	INSERT INTO Bom_Bill_Of_Materials
                    (  assembly_item_id
                     , organization_id
                     , pending_from_ecn
                     , bill_sequence_id
                     , common_bill_sequence_id
                     , assembly_type
                     , last_update_date
                     , last_updated_by
                     , creation_date
                     , created_by
                     , original_system_reference)
                     VALUES (  p_assembly_item_id
			     , p_organization_id
			     , p_pending_from_ecn
			     , p_bill_sequence_id
			     , p_common_bill_sequence_id
			     , p_assembly_type
                             , p_last_update_date
                             , p_last_updated_by
                             , p_creation_date
                             , p_created_by
                             , p_original_system_reference);

                UPDATE eng_revised_items
                   SET bill_sequence_id = p_bill_sequence_id
                 WHERE revised_item_sequence_id = p_revised_item_seq_id;

END Create_New_Bill;


END ENG_Rev_Component_Util;

/
