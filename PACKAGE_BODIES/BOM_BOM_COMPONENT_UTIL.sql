--------------------------------------------------------
--  DDL for Package Body BOM_BOM_COMPONENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOM_COMPONENT_UTIL" AS
/* $Header: BOMUCMPB.pls 120.11.12010000.7 2010/02/15 19:25:30 umajumde ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      ENGUCMPB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Bom_Component_Util
--
--  NOTES
--
--  HISTORY
--
--  12-JUL-99 Rahul Chitko  Initial Creation
--  24-OCT-00 Masanori Kimizuka Modified Insert_Row to add Eco_For_Production
--
--  31-AUG-01   Refai Farook    One To Many support changes
--
--  25-SEP-01   Refai Farook    Mass changes for unit effectivity changes(Update_Row procedure changed)
--
--  15-NOV-02 Anirban Dey Added Auto_Request_Material Support in 11.5.9
--
--  29-APR-05  Abhishek Rudresh          Common BOM attrs Update
****************************************************************************/
  G_PKG_NAME  CONSTANT VARCHAR2(30) := 'Bom_Bom_Component_Util';

-- FUNCTION Get_Operation_Leadtime
  /********************************************************************
  * Function : Get_Operation_Leadtime
  * Parameters IN : p_assembly_item_id IN NUMBER
  *                 p_organization_id IN NUMBER
  *                 p_alternate_bom_code IN VARCHAR2
  *                 p_operation_seq_num IN NUMBER
  * Returns:  Lead Time percent corresponding to the operation
  * Purpose : This function gives the lead time percent  of the operation
  *           as defined in the routing.
  **********************************************************************/
FUNCTION Get_Operation_Leadtime (
                p_assembly_item_id IN NUMBER,
                p_organization_id IN NUMBER,
                p_alternate_bom_code IN VARCHAR2,
                p_operation_seq_num IN NUMBER)  RETURN NUMBER;


--  PROCEDURE Convert_Miss_To_Null
  /********************************************************************
  * Procedure : Convert_Miss_To_Null
  * Parameters IN : Bom Component Exposed column record
  *     Bom Component Unexposed Column record
  * Parameters OUT: Bom Component exposed column record
  *     Bom Component unexposed column record
  * Purpose : This procedure will convert the missing values of
  *     some attributes that the user wishes to NULL.
  **********************************************************************/
  PROCEDURE Convert_Miss_To_Null
  (  p_bom_component_rec      IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
   , p_bom_Comp_Unexp_Rec     IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
   , x_bom_Component_Rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
   , x_bom_Comp_Unexp_Rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
  )
  IS
    l_rev_component_rec Bom_Bo_Pub.Rev_Component_Rec_Type;
    l_rev_comp_unexp_rec  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
  BEGIN

    -- Convert the BOM Record to ECO Record
    Bom_Bo_Pub.Convert_BomComp_To_EcoComp
    (  p_bom_component_rec  => p_bom_component_rec
     , p_bom_comp_unexp_rec => p_bom_comp_unexp_rec
     , x_rev_component_rec  => l_rev_component_rec
     , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
     );

    -- Call the Convert Missing to Null procedure

    Bom_Bom_Component_Util.Convert_Miss_To_Null
    (  p_rev_component_rec  => l_rev_component_rec
     , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
     , x_rev_component_rec  => l_rev_component_rec
     , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
     );

    -- Convert the ECO Record back to BOM for return

    Bom_Bo_Pub.Convert_EcoComp_To_BomComp
    (  p_rev_component_rec  => l_rev_component_rec
     , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
     , x_bom_component_rec  => x_bom_component_rec
     , x_bom_comp_unexp_rec => x_bom_comp_unexp_rec
    );

  END Convert_Miss_To_Null;


  /*****************************************************************
  * Procedure : Query_Row
  * Parameters IN : Bom Component Key
  * Parameters OUT: Bom component Exposed column Record
  *     Bom component Unexposed column Record
  * Returns : None
  * Purpose : Query will query the database record and seperate
  *     the unexposed and exposed attributes before returning
  *     the records.
  ********************************************************************/
        PROCEDURE Query_Row
        ( p_Component_Item_Id           IN  NUMBER
        , p_Operation_Sequence_Number   IN  NUMBER
        , p_Effectivity_Date            IN  DATE
        , p_Bill_Sequence_Id            IN  NUMBER
        , p_from_end_item_number        IN  VARCHAR2 := NULL
        , x_Bom_Component_Rec           IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Rec_Type
        , x_Bom_Comp_Unexp_Rec       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
        , x_Return_Status            IN OUT NOCOPY VARCHAR2
  , p_Mesg_Token_Tbl              IN  Error_Handler.Mesg_Token_Tbl_Type
  , x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type

        )
  IS
    l_rev_component_rec Bom_Bo_Pub.Rev_component_Rec_Type;
    l_rev_comp_unexp_rec  Bom_Bo_pub.Rev_Comp_unexposed_Rec_Type;

  BEGIN

    x_mesg_token_tbl := p_mesg_token_tbl;

    Bom_Bom_Component_Util.Query_Row
    (  p_component_item_id    => p_component_item_id
     , p_Operation_Sequence_Number  => p_Operation_Sequence_Number
     , p_Effectivity_Date   => p_Effectivity_Date
     , p_Bill_Sequence_Id   => p_Bill_Sequence_Id
     , p_from_end_item_number => p_from_end_item_number
     , x_rev_component_rec    => l_rev_component_rec
     , x_rev_comp_unexp_rec   => l_rev_comp_unexp_rec
     , x_return_status    => x_return_status
     , p_Mesg_Token_Tbl       => p_Mesg_Token_Tbl
     , x_Mesg_Token_Tbl       => x_Mesg_Token_Tbl
     );

    -- Convert the ECO record to BOM Record

    Bom_Bo_Pub.Convert_EcoComp_To_BomComp
    (  p_rev_component_rec    => l_rev_component_rec
     , p_rev_comp_unexp_rec   => l_rev_comp_unexp_rec
     , x_bom_component_rec    => x_bom_component_rec
     , x_bom_comp_unexp_rec   => x_bom_comp_unexp_rec
     );

  END Query_Row;


  /*********************************************************************
  * Procedure : Perform_Writes
  * Parameters IN : Bom Component exposed column record
  *     Bom component unexposed column record
  * Parameters OUT: Return Status
  *     Message Token Table
  * Purpose : Perform Writes is the only exposed procedure when the
  *     user has to perform any insert/update/deletes to the
  *     Inventory Components table.
  *********************************************************************/
  PROCEDURE Perform_Writes
  (  p_bom_component_rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_bom_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_Return_Status      IN OUT NOCOPY VARCHAR2
         )
  IS
                l_rev_component_rec     Bom_Bo_Pub.Rev_Component_Rec_Type;
                l_rev_comp_unexp_rec    Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
  BEGIN

                -- Convert the BOM Record to ECO Record
                Bom_Bo_Pub.Convert_BomComp_To_EcoComp
                (  p_bom_component_rec  => p_bom_component_rec
                 , p_bom_comp_unexp_rec => p_bom_comp_unexp_rec
                 , x_rev_component_rec  => l_rev_component_rec
                 , x_rev_comp_unexp_rec => l_rev_comp_unexp_rec
                 );

    -- Call Perform Writes Procedure

    Bom_Bom_Component_Util.Perform_Writes
    (  p_rev_component_rec  => l_rev_component_rec
     , p_rev_comp_unexp_rec => l_rev_comp_unexp_rec
     , x_mesg_token_tbl => x_mesg_token_tbl
     , x_return_status  => x_return_status
     );

  END Perform_Writes;


  /*******************************************************************/
  --
  -- ECO BO routines
  --
  /******************************************************************/


  PROCEDURE Query_Row
  ( p_Component_Item_Id           IN  NUMBER
  , p_Operation_Sequence_Number   IN  NUMBER
  , p_Effectivity_Date            IN  DATE
  , p_Bill_Sequence_Id            IN  NUMBER
  , p_from_end_item_number  IN  VARCHAR2 := NULL
  , x_Rev_Component_Rec           IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
  , x_Rev_Comp_Unexp_Rec       IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
  , x_Return_Status            IN OUT NOCOPY VARCHAR2
  , p_Mesg_Token_Tbl              IN  Error_Handler.Mesg_Token_Tbl_Type
  , x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type

  )
  IS
    l_rev_component_rec Bom_Bo_Pub.Rev_Component_Rec_Type;
    l_Rev_Comp_Unexp_Rec  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type;
    l_err_text    VARCHAR2(2000);
  BEGIN

--    dbms_output.put_line('Querying component record . . .');
--    dbms_output.put_line('Component: ' ||
--    to_char(p_Component_Item_Id));
--    dbms_output.put_line('Op Seq   : ' ||
--    to_char(p_Operation_Sequence_Number));
--  dbms_output.put_line('Effective: ' || to_char(p_Effectivity_Date));
--  dbms_output.put_line('Bill Seq : ' || to_char(p_Bill_Sequence_Id));


    x_mesg_token_tbl := p_mesg_token_tbl;

        SELECT  ROWID
                ,       SUPPLY_SUBINVENTORY
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
        ,       BASIS_TYPE
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
    , ENFORCE_INT_REQUIREMENTS
    , AUTO_REQUEST_MATERIAL -- Added in 11.5.9 by ADEY
    , SUGGESTED_VENDOR_NAME --- Deepu
    , VENDOR_ID --- Deepu
--    , PURCHASING_CATEGORY_ID --- Deepu
    , UNIT_PRICE --- Deepu
        INTO    l_rev_comp_Unexp_rec.rowid
                ,       l_rev_component_rec.supply_subinventory
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
        ,       l_rev_component_rec.basis_type
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
        ,       l_rev_comp_unexp_rec.enforce_int_requirements_code
    , l_rev_component_rec.auto_request_material -- Added in 11.5.9 by ADEY
    , l_rev_component_rec.Suggested_Vendor_Name --- Deepu
--    , l_rev_component_rec.purchasing_category_id --- Deepu
    , l_rev_comp_unexp_rec.Vendor_Id --- Deepu
    , l_rev_component_rec.Unit_Price --- Deepu
        FROM    BOM_INVENTORY_COMPONENTS
        WHERE   component_item_id = p_component_item_id
          AND   effectivity_date  = p_effectivity_date
          AND   operation_seq_num = nvl(p_operation_sequence_number,1)  --Bug 5856042
          AND   bill_sequence_id  = p_bill_sequence_id
          AND   NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR) =
    NVL(p_from_end_item_number, FND_API.G_MISS_CHAR);

        x_Return_Status := BOM_Globals.G_RECORD_FOUND;
        x_Rev_Component_Rec := l_rev_component_rec;
        x_Rev_Comp_Unexp_Rec := l_Rev_Comp_Unexp_Rec;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished querying and assigning component record . . .'); END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Selecting the lookup meaning for enforce int requirements code . . .'); END IF;

        IF l_rev_comp_unexp_rec.enforce_int_requirements_code IS NOT NULL AND
                l_rev_comp_unexp_rec.enforce_int_requirements_code <> FND_API.G_MISS_NUM THEN
        Begin
    SELECT meaning INTO l_rev_component_rec.enforce_int_requirements FROM mfg_lookups
      WHERE lookup_type = 'BOM_ENFORCE_INT_REQUIREMENTS' AND
      lookup_code = l_rev_comp_unexp_rec.enforce_int_requirements_code;
        exception
          when others then
           l_err_text := G_PKG_NAME ||
              ' Utility (Component Query Row) '
                                || substrb(SQLERRM,1,200);

           Error_Handler.Add_Error_Token
          (  p_message_name => NULL
           , p_message_text => l_err_text
           , p_mesg_token_tbl => p_mesg_token_tbl
           , x_mesg_token_tbl => x_mesg_token_tbl
           );

            x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        End;
  END IF;


    EXCEPTION

          WHEN NO_DATA_FOUND THEN
      x_return_status := BOM_Globals.G_RECORD_NOT_FOUND;
      x_rev_component_rec := l_rev_component_rec;
      x_Rev_Comp_Unexp_Rec := l_Rev_Comp_Unexp_Rec;

          WHEN OTHERS THEN
      l_err_text := G_PKG_NAME ||
        ' Utility (Component Query Row) '
                                || substrb(SQLERRM,1,200);
--      dbms_output.put_line('Unexpected Error: '||l_err_text);

      Error_Handler.Add_Error_Token
      (  p_message_name => NULL
       , p_message_text => l_err_text
       , p_mesg_token_tbl => p_mesg_token_tbl
       , x_mesg_token_tbl => x_mesg_token_tbl
       );

            x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

    END Query_Row;

/***************************************************************************
* Procedure : Update_Row
* Parameters IN : Revised Component exposed column record
*     Revised Component unexposed column record
* Parameters OUT: Mesg_Token_Tbl
*     Return_Status
* Purpose : Update_Row procedure will update the production record with
*     the user given values. Any errors will be returned by filling
*     the Mesg_Token_Tbl and setting the return_status.
****************************************************************************/
PROCEDURE Update_Row
( p_rev_component_rec   IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec    IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status   IN OUT NOCOPY VARCHAR2
)
IS
l_return_status         varchar2(80);
l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
l_rev_component_rec    Bom_Bo_Pub.Rev_Component_Rec_Type;
l_err_text                    VARCHAR2(2000);
l_operation_leadtime  NUMBER := NULL;
l_operation_seq_num  NUMBER;
BEGIN

/* need to populate Operation Lead Time percent corresponding to the operation
  -vhymavat bug3537394 */
  IF((p_rev_component_rec.new_operation_sequence_number IS NULL) OR
     (p_rev_component_rec.new_operation_sequence_number =FND_API.G_MISS_NUM) ) THEN
          l_operation_seq_num := p_rev_component_rec.operation_sequence_number;

  ELSE
         l_operation_seq_num :=p_rev_component_rec.new_operation_sequence_number;
  END IF;

 IF(l_operation_seq_num <>1 and p_rev_component_rec.acd_type is null) THEN
 l_operation_leadtime :=
        Get_Operation_Leadtime (
                p_assembly_item_id =>p_rev_comp_Unexp_rec.revised_item_id
               ,p_organization_id  =>p_rev_comp_Unexp_rec.organization_id
               ,p_alternate_bom_code =>p_rev_component_rec.alternate_bom_code
               ,p_operation_seq_num => l_operation_seq_num
                              );

 END IF;


    UPDATE  BOM_INVENTORY_COMPONENTS
    SET     SUPPLY_SUBINVENTORY  = p_rev_component_rec.supply_subinventory
    ,       REQUIRED_FOR_REVENUE = p_rev_component_rec.required_for_revenue
    ,       HIGH_QUANTITY        = p_rev_component_rec.maximum_allowed_quantity
    ,       WIP_SUPPLY_TYPE      = p_rev_component_rec.wip_supply_type
    ,       SUPPLY_LOCATOR_ID    =
  DECODE(p_rev_comp_Unexp_rec.supply_locator_id, FND_API.G_MISS_NUM,
         NULL, p_rev_comp_Unexp_rec.supply_locator_id)
    ,       OPERATION_SEQ_NUM    = l_operation_seq_num
    ,       EFFECTIVITY_DATE       =
                DECODE(  p_rev_component_rec.new_effectivity_date
                       , FND_API.G_MISS_DATE
                       , p_rev_component_rec.start_effective_date
                       , NULL
                       , p_rev_component_rec.start_effective_date
                       , p_rev_component_rec.new_effectivity_date
                       )
    ,       LAST_UPDATE_DATE     = SYSDATE
    ,       LAST_UPDATED_BY      = BOM_Globals.Get_User_Id
    ,       LAST_UPDATE_LOGIN    = BOM_Globals.Get_User_Id
    ,       ITEM_NUM             = p_rev_component_rec.item_sequence_number
    ,       BASIS_TYPE           = decode(p_rev_component_rec.basis_type,
                                     FND_API.G_MISS_NUM, null,p_rev_component_rec.basis_type)
    ,       COMPONENT_QUANTITY   = p_rev_component_rec.quantity_per_assembly
    ,       COMPONENT_YIELD_FACTOR = p_rev_component_rec.projected_yield
    ,       COMPONENT_REMARKS      =
                                    DECODE( p_rev_component_rec.comments,  --bug:4178604 Replace FND_API.G_MISS_CHAR by NULL
                                            FND_API.G_MISS_CHAR,NULL,
                                            p_rev_component_rec.comments)
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
    ,     PROGRAM_ID       = BOM_Globals.Get_Prog_Id
    ,     OPERATION_LEAD_TIME_PERCENT =  l_operation_leadtime
    ,     Original_System_Reference =
                                 p_rev_component_rec.original_system_reference
    ,       From_End_Item_Unit_Number =
                        DECODE(p_rev_component_rec.new_from_end_item_unit_number
                               ,FND_API.G_MISS_CHAR
                               ,p_rev_component_rec.from_end_item_unit_number
                               ,NULL
                               ,p_rev_component_rec.from_end_item_unit_number
                               ,p_rev_component_rec.new_from_end_item_unit_number
                               )
    ,       To_End_Item_Unit_Number =
      DECODE(  p_rev_component_rec.to_end_item_unit_number
             , FND_API.G_MISS_CHAR
                               , NULL
             , p_rev_component_rec.to_end_item_unit_number
             )
    ,       Enforce_Int_Requirements = p_rev_comp_Unexp_rec.Enforce_Int_Requirements_code
    ,     Auto_Request_Material = p_rev_component_rec.auto_request_material -- Added in 11.5.9 by ADEY
    ,     Suggested_Vendor_Name = p_rev_component_rec.Suggested_Vendor_Name --- Deepu
    ,     Vendor_Id = p_rev_comp_Unexp_rec.Vendor_Id --- Deepu
--    ,     Purchasing_Category_id = p_rev_component_rec.purchasing_category_id --- Deepu
    ,     Unit_Price = p_rev_component_rec.Unit_Price --- Deepu
    ,     REQUEST_ID = Fnd_Global.Conc_Request_Id
    ,     PROGRAM_APPLICATION_ID = Fnd_Global.Prog_Appl_Id
    ,   COMPONENT_ITEM_ID = p_rev_comp_Unexp_rec.COMPONENT_ITEM_ID /* bug 8412156 */
    WHERE   COMPONENT_SEQUENCE_ID = p_Rev_Comp_Unexp_Rec.component_sequence_id
    ;
    --For non-referencing common boms.
    BOMPCMBM.Update_Related_Components( p_src_comp_seq_id   => p_Rev_Comp_Unexp_Rec.component_sequence_id
                        , x_Mesg_Token_Tbl   => x_Mesg_Token_Tbl
                        , x_Return_Status   => x_Return_Status
                        );
--    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
    l_err_text := G_PKG_NAME ||
                              ' : Utility (Component Update) ' ||
                              SUBSTR(SQLERRM, 1, 200);
                Error_Handler.Add_Error_Token
    (  p_Message_Name => NULL
     , p_Message_Text => l_err_text
     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
    );
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;

        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END Update_Row;

--following function has been added for bug 7713832
FUNCTION Get_Src_Comp_Seq_Id(p_component_item_id   IN  NUMBER
                              , p_start_effective_date  IN  DATE
                              , p_op_seq_num      IN  NUMBER
                              , p_bill_sequence_id    IN  NUMBER
                             )
RETURN NUMBER
 	IS
  l_src_bill_seq_id          NUMBER;
  l_src_comp_seq_id          NUMBER;

BEGIN

  SELECT source_bill_sequence_id
        INTO l_src_bill_seq_id
        FROM bom_structures_b
        WHERE bill_sequence_id = p_bill_sequence_id
        and bill_sequence_id <> source_bill_sequence_id;

       select component_sequence_id into l_src_comp_seq_id from bom_components_b
       where component_item_id = p_component_item_id
       and bill_sequence_id = l_src_bill_seq_id
       and operation_seq_num = p_op_seq_num
       and effectivity_date = p_start_effective_date;

       RETURN l_src_comp_seq_id;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
         RETURN NULL;

       WHEN OTHERS THEN
         RETURN NULL;
 END;


/*****************************************************************************
* Procedure : Insert_Row
* Parameters IN : Revised Component exposed column record
*     Revised Component unexposed column record
* Parameters OUT: Mesg_Token_Tbl
*     Return_Status
* Purpose : This procedure will insert a record in the bom_inventory-
*     component table. Any errors will be filled in the Mesg_Token
*     Tbl and returned with a return_status of U
*****************************************************************************/
PROCEDURE Insert_Row
( p_rev_component_rec   IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec    IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status   IN OUT NOCOPY VARCHAR2
)
IS

l_err_text    VARCHAR2(2000);
l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
l_Bo_Id     VARCHAR2(3);

l_old_component_sequence_id NUMBER;    -- Bug 2820641

l_object_revision_id NUMBER;
l_minor_revision_id NUMBER;
l_comp_revision_id NUMBER;
l_comp_minor_revision_id NUMBER;
l_operation_leadtime  NUMBER := NULL;
l_operation_seq_num  NUMBER;

l_src_comp_seq_id NUMBER := NULL;
l1_src_bill_seq_id NUMBER;
l1_com_bill_seq_id NUMBER;

BEGIN

    l_Bo_Id := Bom_Globals.Get_Bo_Identifier;


-- bug 2820641
-- BOM form : BOMFDBOM.fmb won't insert the Old_component_sequence_id.
-- ENG form : ENGFDECN.fmb will always inserts Old_component_sequence_id.

-- moved the select from bom_inventory_components in this block for bug 7713832
-- This was originally in the insert statement
-- It was removed so that while migrating common bill components
--common_component_sequence_id is populated correctly

 if l_Bo_Id = BOM_Globals.G_ECO_BO THEN
  if (p_rev_comp_Unexp_rec.old_component_sequence_id =  FND_API.G_MISS_NUM)
    or (p_rev_comp_Unexp_rec.old_component_sequence_id is NULL)  then
    --l_old_component_sequence_id :=  p_rev_comp_Unexp_rec.component_sequence_id;
    l_src_comp_seq_id := null;
  else
    l_old_component_sequence_id :=   p_rev_comp_Unexp_rec.old_component_sequence_id;
    --these 2 values will always be the same for acd_type 1
     if l_old_component_sequence_id <> p_rev_comp_Unexp_rec.component_sequence_id then
     Select common_component_sequence_id into l_src_comp_seq_id from bom_inventory_components where
      component_sequence_id = l_old_component_sequence_id;
      end if;
  end if;
 else
   if (p_rev_comp_Unexp_rec.old_component_sequence_id =  FND_API.G_MISS_NUM)  then
      l_old_component_sequence_id :=  NULL;
   else
      l_old_component_sequence_id :=   p_rev_comp_Unexp_rec.old_component_sequence_id;
      if l_old_component_sequence_id is not null then
      Select common_component_sequence_id into l_src_comp_seq_id from bom_inventory_components where
      component_sequence_id = l_old_component_sequence_id;
      end if;

   end if;

 end if;
-- bug 2820641

--/* added for BOM Defaulting for WEB-ADI Open Interface calls */


  BOM_GLOBALS.GET_DEF_REV_ATTRS
  (     p_bill_sequence_id =>  p_rev_comp_Unexp_rec.bill_sequence_id
    ,    p_comp_item_id => p_rev_comp_Unexp_rec.component_item_id
    ,   p_effectivity_date =>  nvl(p_rev_component_rec.start_effective_date,SYSDATE)
    ,   x_object_revision_id => l_object_revision_id
    ,   x_minor_revision_id => l_minor_revision_id
    ,   x_comp_revision_id => l_comp_revision_id
    ,   x_comp_minor_revision_id => l_comp_minor_revision_id
  );

/* need to populate Operation Lead Time percent corresponding to the operation
  -vhymavat bug3537394 */
  IF((p_rev_component_rec.new_operation_sequence_number IS NULL) OR
     (p_rev_component_rec.new_operation_sequence_number =FND_API.G_MISS_NUM) ) THEN

     IF (( p_rev_component_rec.operation_sequence_number IS NULL) OR
         ( p_rev_component_rec.operation_sequence_number =FND_API.G_MISS_NUM)) THEN
         l_operation_seq_num :=   1;
     ELSE
          l_operation_seq_num := p_rev_component_rec.operation_sequence_number;
     END IF;
   ELSE
        l_operation_seq_num :=p_rev_component_rec.new_operation_sequence_number;
  END IF;

 IF(l_operation_seq_num <>1 and p_rev_component_rec.acd_type is null) THEN
 l_operation_leadtime :=
        Get_Operation_Leadtime (
		p_assembly_item_id =>p_rev_comp_Unexp_rec.revised_item_id
               ,p_organization_id  =>p_rev_comp_Unexp_rec.organization_id
               ,p_alternate_bom_code =>p_rev_component_rec.alternate_bom_code
               ,p_operation_seq_num => l_operation_seq_num
                              );

 END IF;

 --Bug 7712832 changes start
       IF Bom_Globals.Get_Caller_Type = 'MIGRATION' THEN

       l_src_comp_seq_id := Get_Src_Comp_Seq_Id(p_component_item_id => p_rev_comp_Unexp_rec.component_item_id,
                                                p_bill_sequence_id => p_rev_comp_Unexp_rec.bill_sequence_id,
                                                p_op_seq_num => p_rev_component_rec.operation_sequence_number,
                                                p_start_effective_date => p_rev_component_rec.start_effective_date);
        END IF;

--Bug 7712832 changes end
    --bug:3254815 Update request id, prog id, prog appl id and prog update date.
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
    ,       BASIS_TYPE
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
    ,       To_End_Item_Unit_Number
    ,       Eco_For_Production -- Added by MK
    ,       Enforce_Int_Requirements
    ,     Auto_Request_Material -- Added in 11.5.9 by ADEY
    ,       Obj_Name -- Added by hgelli.
    ,       pk1_value
    ,       pk2_value
    ,     Suggested_Vendor_Name --- Deepu
    ,     Vendor_Id --- Deepu
--    ,     Purchasing_Category_id --- Deepu
    ,     Unit_Price --- Deepu
    ,from_object_revision_id
    , from_minor_revision_id
    --,component_item_revision_id
    --,component_minor_revision_id
    , common_component_sequence_id
    )
    VALUES
    (       p_rev_component_rec.supply_subinventory
    ,       l_operation_leadtime
    ,       p_rev_comp_unexp_rec.revised_item_sequence_id
    ,       NULL /* Cost Factor */
    ,       p_rev_component_rec.required_for_revenue
    ,       p_rev_component_rec.maximum_allowed_quantity
    ,       p_rev_comp_Unexp_rec.component_sequence_id
    ,       BOM_Globals.Get_Prog_AppId
    ,       p_rev_component_rec.wip_supply_type
    ,       DECODE(p_rev_comp_Unexp_rec.supply_locator_id, FND_API.G_MISS_NUM,
       NULL, p_rev_comp_Unexp_rec.supply_locator_id)
    ,       p_rev_comp_Unexp_rec.bom_item_type
    ,       l_operation_seq_num
    ,       p_rev_comp_Unexp_rec.component_item_id
    ,       SYSDATE /* Last Update Date */
    ,       BOM_Globals.Get_User_Id /* Last Updated By */
    ,       SYSDATE /* Creation Date */
    ,       BOM_Globals.Get_User_Id /* Created By */
    ,       BOM_Globals.Get_User_Id /* Last Update Login */
    ,       DECODE(p_rev_component_rec.item_sequence_number, FND_API.G_MISS_NUM,
       1, NULL,1,p_rev_component_rec.item_sequence_number)
    ,       DECODE(p_rev_component_rec.basis_type,FND_API.G_MISS_NUM,
        NULL,p_rev_component_rec.basis_type)
    ,       p_rev_component_rec.quantity_per_assembly
    ,       p_rev_component_rec.projected_yield
    ,       p_rev_component_rec.comments
    ,       nvl(p_rev_component_rec.start_effective_date,SYSDATE)    --2169237
    ,       p_rev_component_rec.Eco_Name
    ,       DECODE(l_Bo_Id,
                   Bom_Globals.G_BOM_BO,
       Decode( p_rev_comp_Unexp_rec.bom_implementation_date,
         null,
         null,
         SYSDATE),
                   NULL
                  ) /* Implementation Date */
   /*
    ,       DECODE(l_Bo_Id,
                   Bom_Globals.G_BOM_BO,
                   SYSDATE,
                   NULL
                  ) -- Implementation Date
   */
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
--    ,       DECODE( p_rev_comp_Unexp_rec.old_component_sequence_id
--                  , FND_API.G_MISS_NUM
--                  , NULL
--                  ,p_rev_comp_Unexp_rec.old_component_sequence_id
--                  )
    ,       l_old_component_sequence_id
    ,       p_rev_comp_Unexp_rec.bill_sequence_id
    ,       Fnd_Global.Conc_Request_Id /* Request Id */
    ,       BOM_Globals.Get_Prog_Id
    ,       SYSDATE /* program_update_date */
    ,       p_rev_comp_Unexp_rec.pick_components
    ,     p_rev_component_rec.original_system_reference
    ,     DECODE(  p_rev_component_rec.from_end_item_unit_number
       , FND_API.G_MISS_CHAR
       , null
       , p_rev_component_rec.from_end_item_unit_number
       )
    ,       DECODE(  p_rev_component_rec.to_end_item_unit_number
                   , FND_API.G_MISS_CHAR
                   , null
                   , p_rev_component_rec.to_end_item_unit_number
       )
    ,       BOM_Globals.Get_Eco_For_Production
            -- DECODE( l_Bo_Id, BOM_Globals.G_ECO_BO, l_Eco_For_Production, 2) /* Eco for Production flag */
    ,       p_rev_comp_Unexp_rec.Enforce_Int_Requirements_Code
    ,     p_rev_component_rec.auto_request_material -- Added in 11.5.9 by ADEY
    ,      NULL-- Added by hgelli. Identifies this record as Bom Component.
    ,     p_rev_comp_Unexp_rec.component_item_id
    ,     p_rev_comp_Unexp_rec.organization_id
    ,     p_rev_component_rec.Suggested_Vendor_Name --- Deepu
    ,     p_rev_comp_Unexp_rec.Vendor_Id --- Deepu
--    ,     p_rev_component_rec.purchasing_category_id --- Deepu
    ,     p_rev_component_rec.Unit_Price --- Deepu
 	,l_object_revision_id
	,l_minor_revision_id
	--,l_comp_revision_id
	--,l_comp_minor_revision_id
        ,l_src_comp_seq_id -- changed for bug 7713832
    );

    --Bug 7713832 begin
    -- the purpose of this code block is to set the bill_sequence_id and common_bill_sequence_id
    -- of updatable common boms to be the same
    -- this is required since migrator data cannot use 'enable_attrs_update' since
    -- it contains data corresponding to updatable common bom from the source instance
    -- and does not expect the program to automatically create the record

   IF Bom_Globals.Get_Caller_Type = 'MIGRATION' THEN
   select source_bill_sequence_id, common_bill_sequence_id into
          l1_src_bill_seq_id, l1_com_bill_seq_id from bom_structures_b
          where bill_sequence_id = p_rev_comp_Unexp_rec.bill_sequence_id;
   --if the following condition is true and you are here it means you have an updatable common bill
    IF  p_rev_comp_Unexp_rec.bill_sequence_id <> l1_src_bill_seq_id THEN
    --you may already have assigned  bill sequence id to common bill sequence id
    -- in that case no update is needed, otherwise it is required
    IF  p_rev_comp_Unexp_rec.bill_sequence_id <> l1_com_bill_seq_id THEN
       update bom_structures_b set common_bill_sequence_id = p_rev_comp_Unexp_rec.bill_sequence_id
       where bill_sequence_id = p_rev_comp_Unexp_rec.bill_sequence_id;
    END IF;
    END IF;
   END IF;
   --Bug 7713832 end
  --For non-referencing common boms.
  --should only be visited if the caller is not migrator
  --since extract is going to contain corresponding data

  IF Bom_Globals.Get_Caller_Type <> 'MIGRATION' THEN --Bug 7713832
  BOMPCMBM.Insert_Related_Components( p_src_bill_seq_id => p_rev_comp_Unexp_rec.bill_sequence_id
                      , p_src_comp_seq_id => p_rev_comp_Unexp_rec.component_sequence_id
                      , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
                      , x_Return_Status => x_Return_Status
                     );
   END IF;
  --x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  --included for Bug 9076970
  -- if bom is imported w/o routing same components menat to be imported at different operation_seq_num will now
  -- be imported at same operation_seq_num and this would violate the unique key constraints on
  -- effectivity_date, operation_seq_num, component_item_id and bill_sequence_id. hence, this exception is included.
   WHEN DUP_VAL_ON_INDEX THEN
   FND_MESSAGE.SET_NAME('BOM', 'BOM_COMPONENT_DUPLICATE');
   APP_EXCEPTION.RAISE_EXCEPTION;
    --end changes Bug 9076970
    WHEN OTHERS THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Unexpected Error occured in Insert . . .' || SQLERRM); END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
    l_err_text := G_PKG_NAME ||
                              ' : Utility (Component Insert) ' ||
            SUBSTR(SQLERRM, 1, 200);
                Error_Handler.Add_Error_Token
    (  p_Message_Name => NULL
     , p_Message_Text => l_err_text
     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
    );
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        END IF;

        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Row;

/****************************************************************************
* Procedure : Delete_Row
* Parameters IN : Revised Component Key
* Parameters OUT: Mesg_Token_Tbl
*     Return_Status
* Purpose : Will delete a revised component record for a ECO.
*     Delete operation will not delete a record in production which
*     is already implemented.
*****************************************************************************/
/* Comment out by MK to support delet
PROCEDURE Delete_Row
( p_component_sequence_id IN  NUMBER
, x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status   IN OUT NOCOPY VARCHAR2
)
*/

PROCEDURE Delete_Row
( p_rev_component_rec           IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_rev_comp_unexp_rec          IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status               IN OUT NOCOPY VARCHAR2
)

IS

    l_dummy number;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;

    -- added by MK on 06/04/2001
    Cursor CheckGroup is
    SELECT description,
           delete_group_sequence_id,
           delete_type
    FROM bom_delete_groups
    WHERE delete_group_name = p_rev_comp_unexp_rec.delete_group_name
      AND organization_id = p_rev_comp_unexp_rec.organization_id;

    l_dg_sequence_id        NUMBER;
    l_rev_component_rec     Bom_Bo_Pub.Rev_Component_Rec_Type ;
    l_rev_comp_unexp_rec    Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type  ;
    l_assembly_type         NUMBER;




BEGIN


    --
    -- Initialize Common Record and Status
    --
    l_rev_component_rec  := p_rev_component_rec ;
    l_rev_comp_unexp_rec := p_rev_comp_unexp_rec ;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
    THEN

        DELETE  FROM BOM_INVENTORY_COMPONENTS
        WHERE   COMPONENT_SEQUENCE_ID = p_rev_comp_unexp_rec.component_sequence_id;
                                       -- p_component_sequence_id ;

        /******************************************************************
        -- Also delete the Substitute components and Reference designators
        -- by first logging a warning notifying the user of the cascaded
        -- Delete.
        *******************************************************************/

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    -- This is a warning.
        THEN
                Error_Handler.Add_Error_Token
    (  p_Message_Name => 'BOM_COMP_DEL_CHILDREN'
     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , p_message_type       => 'W'  -- Added by MK on 11/13/00
                 );
        END IF;

  DELETE from bom_reference_designators
   WHERE component_sequence_id = p_rev_comp_unexp_rec.component_sequence_id ;
                                       -- p_component_sequence_id ;

  DELETE from bom_substitute_components
   WHERE component_Sequence_id = p_rev_comp_unexp_rec.component_sequence_id ;
                                       -- p_component_sequence_id ;

   --Bug 9356298 start
   --For non-referencing common boms.
     IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Deleting componenets for non-referencing bom . . .' ); END IF;
     BOMPCMBM.Delete_Related_Components(p_src_comp_seq => p_rev_comp_unexp_rec.component_sequence_id);
   --Bug 9356298 end

    -- In Bom BO, the user is not allowed to delete components directly.
    -- The user can use delete group functionality for deleting components.
    ELSIF Bom_Globals.Get_Bo_Identifier =  Bom_Globals.G_BOM_BO
    THEN


         FOR DG IN CheckGroup
         LOOP
             IF DG.delete_type <> 4 /* Component */ then

                 Error_Handler.Add_Error_Token
                 (  p_message_name => 'BOM_DUPLICATE_DELETE_GROUP'
                  , p_mesg_token_tbl => l_mesg_token_Tbl
                  , x_mesg_token_tbl => l_mesg_token_tbl
                 );

                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_mesg_token_tbl := l_mesg_token_tbl;
                 RETURN;
             END IF;

             l_rev_comp_unexp_rec.DG_Sequence_Id :=
                                 DG.delete_group_sequence_id;
             l_rev_comp_unexp_rec.DG_Description := DG.description;

         END LOOP;

         IF l_rev_comp_unexp_rec.DG_Sequence_Id <> FND_API.G_MISS_NUM
         THEN
                        l_dg_sequence_id := l_rev_comp_unexp_rec.DG_Sequence_Id;
         ELSE
                        l_dg_sequence_id := NULL;
                        Error_Handler.Add_Error_Token
                         (  p_message_name => 'NEW_DELETE_GROUP'
                          , p_mesg_token_tbl => l_mesg_token_Tbl
                          , x_mesg_token_tbl => l_mesg_token_tbl
                          , p_message_type   => 'W' /* Warning */
                         );
         END IF;

 -- bug 5199643
         select assembly_type into l_assembly_type
         from bom_structures_b
         where bill_sequence_id = l_rev_comp_unexp_rec.bill_sequence_id;

         l_dg_sequence_id :=
         MODAL_DELETE.DELETE_MANAGER
         (  new_group_seq_id        => l_dg_sequence_id,
            name                    => l_rev_comp_unexp_rec.Delete_Group_Name,
            group_desc              => l_rev_comp_unexp_rec.dg_description,
            org_id                  => l_rev_comp_unexp_rec.organization_id,
            bom_or_eng              => l_assembly_type, /*dg type must be same as that of bill */
            del_type                => 4 /* Component */,
            ent_bill_seq_id         => l_rev_comp_unexp_rec.bill_sequence_id,
            ent_rtg_seq_id          => NULL,
            ent_inv_item_id         => l_rev_comp_unexp_rec.revised_item_id,
            ent_alt_designator      => l_rev_component_rec.alternate_bom_code,
            ent_comp_seq_id         => l_rev_comp_unexp_rec.component_sequence_id,
            ent_op_seq_id           => NULL,
            user_id                 => BOM_Globals.Get_User_Id
          );

          BOMPCMBM.Delete_Related_Pending_Comps(p_src_comp_seq_id => p_rev_comp_unexp_rec.component_sequence_id
                                                , x_Return_Status => x_Return_Status);

    END IF ;

    --x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          Error_Handler.Add_Error_Token
    (  p_Message_Name => NULL
     , p_Message_Text => 'Error Rev. Comp Delete Row ' ||
            SUBSTR(SQLERRM, 1, 100)
     , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
    );
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
  END IF;
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END Delete_Row;

/*******************************************************
* This is copy of the procedure that is currently used by
* the ECO.
*********************************************************/
Procedure Cancel_Revised_Component (
    comp_seq_id         number,
    user_id             number,
    login               number,
    comment             varchar2
) IS
    err_text            varchar2(2000);
    stmt_num            number;
Begin
/*
** insert the cancelled rev components into eng_revised_components
*/
    stmt_num := 10;
    INSERT INTO ENG_REVISED_COMPONENTS (
        COMPONENT_SEQUENCE_ID,
        COMPONENT_ITEM_ID,
        OPERATION_SEQUENCE_NUM,
        BILL_SEQUENCE_ID,
        CHANGE_NOTICE,
        EFFECTIVITY_DATE,
        BASIS_TYPE,
        COMPONENT_QUANTITY,
        COMPONENT_YIELD_FACTOR,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        CANCELLATION_DATE,
        CANCEL_COMMENTS,
        OLD_COMPONENT_SEQUENCE_ID,
        ITEM_NUM,
        WIP_SUPPLY_TYPE,
        COMPONENT_REMARKS,
        SUPPLY_SUBINVENTORY,
        SUPPLY_LOCATOR_ID,
        DISABLE_DATE,
        ACD_TYPE,
        PLANNING_FACTOR,
        QUANTITY_RELATED,
        SO_BASIS,
        OPTIONAL,
        MUTUALLY_EXCLUSIVE_OPTIONS,
        INCLUDE_IN_COST_ROLLUP,
        CHECK_ATP,
        SHIPPING_ALLOWED,
        REQUIRED_TO_SHIP,
        REQUIRED_FOR_REVENUE,
        INCLUDE_ON_SHIP_DOCS,
        LOW_QUANTITY,
        HIGH_QUANTITY,
        REVISED_ITEM_SEQUENCE_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15)
    SELECT
        IC.COMPONENT_SEQUENCE_ID,
        IC.COMPONENT_ITEM_ID,
        IC.OPERATION_SEQ_NUM,
        IC.BILL_SEQUENCE_ID,
        IC.CHANGE_NOTICE,
        IC.EFFECTIVITY_DATE,
        IC.BASIS_TYPE,
        IC.COMPONENT_QUANTITY,
        IC. COMPONENT_YIELD_FACTOR,
        SYSDATE,
        user_id,
        SYSDATE,
        user_id,
        login,
        sysdate,
        comment,
        IC.OLD_COMPONENT_SEQUENCE_ID,
        IC.ITEM_NUM,
        IC.WIP_SUPPLY_TYPE,
        IC.COMPONENT_REMARKS,
        IC.SUPPLY_SUBINVENTORY,
        IC.SUPPLY_LOCATOR_ID,
        IC.DISABLE_DATE,
        IC.ACD_TYPE,
        IC.PLANNING_FACTOR,
        IC.QUANTITY_RELATED,
        IC.SO_BASIS,
        IC.OPTIONAL,
        IC.MUTUALLY_EXCLUSIVE_OPTIONS,
        IC.INCLUDE_IN_COST_ROLLUP,
        IC.CHECK_ATP,
        IC.SHIPPING_ALLOWED,
        IC.REQUIRED_TO_SHIP,
        IC.REQUIRED_FOR_REVENUE,
        IC.INCLUDE_ON_SHIP_DOCS,
        IC.LOW_QUANTITY,
        IC.HIGH_QUANTITY,
        IC.REVISED_ITEM_SEQUENCE_ID,
        IC.ATTRIBUTE_CATEGORY,
        IC.ATTRIBUTE1,
        IC.ATTRIBUTE2,
        IC.ATTRIBUTE3,
        IC.ATTRIBUTE4,
        IC.ATTRIBUTE5,
        IC.ATTRIBUTE6,
        IC.ATTRIBUTE7,
        IC.ATTRIBUTE8,
        IC.ATTRIBUTE9,
        IC.ATTRIBUTE10,
        IC.ATTRIBUTE11,
        IC.ATTRIBUTE12,
        IC.ATTRIBUTE13,
        IC.ATTRIBUTE14,
        IC.ATTRIBUTE15
    FROM BOM_INVENTORY_COMPONENTS IC
    WHERE IC.COMPONENT_SEQUENCE_ID = comp_seq_id;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows inserted into erc');

/*
** delete from bom_inventory_comps
*/
    DELETE FROM BOM_INVENTORY_COMPONENTS
    WHERE  COMPONENT_SEQUENCE_ID = comp_seq_id;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows delete from bic');

  -- Fixed bug 618781.
  -- Cancelling of Revised component must also cancel the
  -- Subs. components and the reference designators.

/*
**      Delete the Substitute Components and also the Reference Designators
*/
    DELETE FROM BOM_SUBSTITUTE_COMPONENTS SC
    WHERE SC.COMPONENT_SEQUENCE_ID = comp_seq_id;

-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from bsc');

/*
** delete reference designators of all pending revised items on ECO
*/
    stmt_num := 30;
    DELETE FROM BOM_REFERENCE_DESIGNATORS RD
        WHERE RD.COMPONENT_SEQUENCE_ID = comp_seq_id;
-- dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from rfd');

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        err_text :=  'Cancel_Revised_Component' || '(' || stmt_num || ')' ||
                SQLERRM;
        FND_MESSAGE.SET_NAME('BOM', 'BOM_SQL_ERR');
        FND_MESSAGE.SET_TOKEN('ENTITY', err_text);
        APP_EXCEPTION.RAISE_EXCEPTION;
END Cancel_Revised_Component;

PROCEDURE Cancel_Component(  p_component_sequence_id  IN  NUMBER
         , p_cancel_comments    IN  VARCHAR2
         , p_user_id      IN  NUMBER
         , p_login_id     IN  NUMBER
         )
IS
BEGIN
  Cancel_Revised_Component
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
                         , p_control_rec  IN
         Bom_Bo_Pub.Control_Rec_Type
          := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
      , x_Mesg_Token_Tbl     IN OUT NOCOPY
                           Error_Handler.Mesg_Token_Tbl_Type
                         , x_Return_Status      IN OUT NOCOPY VARCHAR2
                         )
IS
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_Rev_component_Rec Bom_Bo_Pub.Rev_Component_rec_Type;
  l_rev_comp_unexp_rec  Bom_Bo_Pub.rev_comp_unexposed_rec_type;
  l_return_status   VARCHAR2(1);
  l_assembly_type   NUMBER;
  l_Comp_Seq_Id   NUMBER;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type; -- Added by MK on 11/13/00
  l_bom_item_type		NUMBER;
  l_Structure_Type_Name VARCHAR2(30);
  l_Assembly_Item_Id NUMBER;
  l_Organization_Id  NUMBER;
  l_Structure_Name VARCHAR2(30);
  l_error_message VARCHAR2(512);


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
  l_bill_sequence_id NUMBER;
    CURSOR GetBillSeqId IS
          SELECT bom_inventory_components_s.nextval bill_sequence_id
    FROM sys.dual;

        err_text            varchar2(2000);
        err_code            varchar2(100);
BEGIN
  l_rev_component_rec := p_rev_component_rec;
  l_rev_comp_unexp_rec := p_rev_comp_unexp_rec;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

        l_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
        l_Token_Tbl(1).Token_Value := l_rev_component_rec.component_item_name;


        IF l_Rev_Component_Rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Test Harness: Executing Insert Row. . . '); END IF;

      IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
      THEN
      FOR CheckBillExists IN c_CheckBillExists LOOP
    -- Loop executes then the bill does not exist.
    -- Procedure Create_New_Bill
/* Bug 1742811
   ECO BO is not in Sync with Form with respect to the BOM Type
   being created .ECO Form Creates BOM based on Change Order Type.
   Below fix made to get the assembly tupe of BOM based on Change Order
   Type of ECO
*/
      select assembly_type
      INTO   l_assembly_type
            --from   eng_change_order_types
      from eng_change_order_types_vl
            where  change_order_type_id =
                              (select change_order_type_id
                               from eng_engineering_changes
                               where  change_notice =
              l_rev_component_rec.eco_name
                               and organization_id =
            l_rev_comp_unexp_rec.organization_id);

/*
    SELECT decode(eng_item_flag, 'N', 1, 2)
      INTO l_assembly_type
      FROM mtl_system_items
     WHERE inventory_item_id = l_rev_comp_unexp_rec.revised_item_id
       AND organization_id = l_rev_comp_unexp_rec.organization_id;
*/
    IF p_control_rec.caller_type = 'FORM'
    THEN
      FOR X_id IN GetBillSeqId LOOP
                  l_rev_comp_unexp_rec.bill_sequence_id :=
           X_id.bill_sequence_id;
      END LOOP;


                        -- Message Name is changed by MK on 11/02/00
                  Error_Handler.Add_Error_Token
                  (  p_Message_Name       => 'ENG_NEW_PRIMARY_CREATED' --  'BOM_ECO_CREATE_BOM'
                   , p_Message_Text       => NULL
                   , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                  );
          ELSE

      --
      -- Log a warning indicating that a new bill has been created
      -- as a result of the component being added.
      --
                        -- Message Name is changed by MK on 11/02/00
      Error_Handler.Add_Error_Token
                  (  p_Message_Name       => 'ENG_NEW_PRIMARY_CREATED' -- 'BOM_NEW_PRIMARY_CREATED'
                   , p_Message_Text       => NULL
                   , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                   , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
       , p_message_type       => 'W'     -- Parameter added as fix for Bug - 3267190
                  );
    END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('BOM_Component_Util: Creating New Bill. . . ');
END IF;
    Bom_Bom_Component_Util.Create_New_Bill
    (  p_assembly_item_id   =>
        l_rev_comp_unexp_rec.revised_item_id
                 , p_organization_id    =>
        l_rev_comp_unexp_rec.organization_id
                 , p_pending_from_ecn   =>
        l_rev_component_rec.eco_name
                 , p_bill_sequence_id   =>
        l_rev_comp_unexp_rec.bill_sequence_id
                 , p_common_bill_sequence_id  =>
        l_rev_comp_unexp_rec.bill_sequence_id
                 , p_assembly_type    => l_assembly_type
     , p_last_update_date   => SYSDATE
                 , p_last_updated_by    => BOM_Globals.Get_User_Id
                 , p_creation_date    => SYSDATE
                 , p_created_by     => BOM_Globals.Get_User_Id
                 , p_revised_item_seq_id  =>
        l_rev_comp_unexp_rec.revised_item_sequence_id
                 , p_original_system_reference  =>
        l_rev_component_rec.original_system_reference);
      END LOOP;
      END IF;

            Insert_Row
            (   p_Rev_component_rec   => l_Rev_Component_Rec
             ,  p_Rev_Comp_Unexp_Rec  => l_Rev_Comp_Unexp_Rec
             ,  x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
             ,  x_return_status   => l_Return_Status
             );

	    If (x_return_Status = FND_API.G_RET_STS_SUCCESS) Then

		Begin
			SELECT BOM_ITEM_TYPE
			INTO   l_bom_item_type
			FROM   MTL_SYSTEM_ITEMS_B
			WHERE  INVENTORY_ITEM_ID = l_rev_comp_unexp_rec.revised_item_id
			AND    ORGANIZATION_ID   = l_rev_comp_unexp_rec.organization_id;

			If l_bom_item_type = BOM_Globals.G_PRODUCT_FAMILY Then
				Product_Family_PKG.Update_PF_Item_Id
					(X_Inventory_Item_Id => l_Rev_Comp_Unexp_Rec.component_item_id,
                                         X_Organization_Id   => l_rev_comp_unexp_rec.organization_id,
                                         X_PF_Item_Id        => l_rev_comp_unexp_rec.revised_item_id,
                                         X_Trans_Type        => NULL,
                                         X_Error_Msg         => err_text,
                                         X_Error_Code        => err_code);
			End if;

		EXCEPTION
    			WHEN OTHERS THEN
        		err_text :=  'Update product family Item id error' || SQLERRM;
        		FND_MESSAGE.SET_NAME('BOM', 'BOM_SQL_ERR');
        		FND_MESSAGE.SET_TOKEN('ENTITY', err_text);
        		APP_EXCEPTION.RAISE_EXCEPTION;
		End;
	    End if;
        ELSIF l_Rev_Component_Rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
        THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Test Harness: Executing Update Row. . . '); END IF;

            Update_Row
            (   p_Rev_component_rec   => l_Rev_Component_Rec
             ,  p_Rev_Comp_Unexp_Rec  => l_Rev_Comp_Unexp_Rec
             ,  x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
             ,  x_return_status   => l_Return_Status
            );
        ELSIF l_Rev_Component_Rec.Transaction_Type = BOM_GLOBALS.G_OPR_DELETE
        THEN

-- dbms_output.put_line('Test Harness: Executing Delete Row. . . ');

            /* Commented out by MK on 06/01/2001
            -- to support deleting thr DeleteGroup
            Delete_Row
            (   p_component_sequence_id         =>
                l_Rev_Comp_Unexp_Rec.Component_Sequence_Id
            ,   x_Mesg_Token_Tbl                => l_Mesg_Token_Tbl
            ,   x_return_status                 => l_Return_Status
            );
            */

            Delete_Row
            (   p_Rev_component_rec   => l_Rev_Component_Rec
             ,  p_Rev_Comp_Unexp_Rec  => l_Rev_Comp_Unexp_Rec
             ,  x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
             ,  x_return_status       => l_Return_Status
            );

  ELSIF l_Rev_Component_Rec.Transaction_Type = BOM_GLOBALS.G_OPR_CANCEL
  THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Perform Cancel Component . . .'); END IF;

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
                (  p_Message_Name       => 'BOM_COMP_CANCEL_DEL_CHILDREN'
                 , p_Message_Text       => NULL
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => l_Token_Tbl  -- Added by MK on 11/13/00
                 , p_message_type       => 'W'          -- Added by MK on 11/13/00
                );

    Bom_Bom_Component_Util.Cancel_Component
    (  p_component_sequence_id  =>
      l_comp_seq_id
     , p_cancel_comments    =>
      l_rev_component_rec.cancel_comments
     , p_user_id      =>
      BOM_Globals.Get_User_ID
     , p_login_id     =>
      BOM_Globals.Get_Login_ID
    );

        END IF;

   /********************************************************************
  -- If the structure type is Packaging Hierarchy the we will do the
  -- following operations.
  ********************************************************************/
  IF l_Rev_Component_Rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE
    OR l_Rev_Component_Rec.Transaction_Type = BOM_GLOBALS.G_OPR_UPDATE
    OR l_Rev_Component_Rec.Transaction_Type = BOM_GLOBALS.G_OPR_DELETE
  THEN
    SELECT STRUCTURE_TYPE_NAME,
        ASSEMBLY_ITEM_ID,
        ORGANIZATION_ID,
        ALTERNATE_BOM_DESIGNATOR
        INTO
        l_Structure_Type_Name,
        l_Assembly_Item_Id,
        l_Organization_Id,
        l_Structure_Name
        FROM BOM_STRUCTURE_TYPES_B STRUCT_TYPE,
             BOM_STRUCTURES_B  BOM_STRUCT
    WHERE  BOM_STRUCT.STRUCTURE_TYPE_ID = STRUCT_TYPE.STRUCTURE_TYPE_ID
    AND BOM_STRUCT.BILL_SEQUENCE_ID = l_Rev_Comp_Unexp_Rec.BILL_SEQUENCE_ID;

    IF (l_Structure_Type_Name ='Packaging Hierarchy') THEN
        l_error_message := NULL;
        BOM_GTIN_RULES.Perform_Rollup (
              p_item_id               =>  l_Rev_Comp_Unexp_Rec.component_item_id
             ,p_organization_id       =>  l_Organization_Id
             ,p_parent_item_id        =>  l_Assembly_Item_Id
             ,p_structure_type_name   =>  l_Structure_Type_Name
             ,p_transaction_type      =>  l_Rev_Component_Rec.Transaction_Type
             ,p_structure_name        =>  l_Structure_Name
             ,x_error_message         =>  l_error_message
             );
        IF l_error_message IS NOT NULL AND l_error_message <> '' THEN
            l_Token_Tbl(1).Token_Name  := 'ERROR_MESSAGE';
            l_Token_Tbl(1).Token_Value := l_error_message;

            Error_Handler.Add_Error_Token
                ( p_message_name  => 'BOM_VALIDATION_FAILURE'
                , p_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                , p_Token_Tbl     => l_Token_Tbl
                );
            l_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
        END IF;

        IF l_Rev_Component_Rec.Transaction_Type = BOM_GLOBALS.G_OPR_CREATE THEN

            BOM_GTIN_RULES.Update_Top_GTIN (
                 p_organization_id     =>  l_Organization_Id
                ,p_component_item_id   =>  l_Rev_Comp_Unexp_Rec.component_item_id
                ,p_parent_item_id      =>  l_Assembly_Item_Id
                ,p_structure_name      =>  l_Structure_Name
                );
        END IF;

        BOM_GTIN_RULES.Check_GTIN_Attributes (
                p_bill_sequence_id     =>  l_rev_comp_unexp_rec.bill_sequence_id
               ,p_assembly_item_id     =>  l_Assembly_Item_Id
               ,p_organization_id      =>  l_Organization_Id
               ,p_alternate_bom_code   =>  l_Structure_Name
               ,p_component_item_id    =>  l_Rev_Comp_Unexp_Rec.component_item_id
               ,x_return_status        =>  l_return_status
               ,x_error_message        =>  l_error_message
               );
        IF l_return_status <> 'S' THEN
            l_Token_Tbl(1).Token_Name  := 'ERROR_MESSAGE';
            l_Token_Tbl(1).Token_Value := l_error_message;

            Error_Handler.Add_Error_Token
                ( p_message_name  => 'BOM_VALIDATION_FAILURE'
                , p_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl=> l_Mesg_Token_Tbl
                , p_Token_Tbl     => l_Token_Tbl
                );
            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
  END IF;


  x_return_status := l_return_status;
  x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
END Perform_Writes;


/******************************************************************************
* Procedure : Create_New_Bill
* Parameters IN : Assembly Item ID
*     Organization ID
*     Pending from ECN
*     common_bill_sequence_id
*     assembly_type
*     WHO columns
*     revised_item_sequence_id
* Purpose : This procedure will be called when a revised component is
*     the first component being added on a revised item. This
*     procedure will create a Bill and update the revised item
*     information indicating that bill for this revised item now
*     exists.
******************************************************************************/
PROCEDURE Create_New_Bill(  p_assembly_item_id           IN NUMBER
                          , p_organization_id            IN NUMBER
                          , p_pending_from_ecn           IN VARCHAR2
                          , p_bill_sequence_id           IN NUMBER
                          , p_common_bill_sequence_id    IN NUMBER
                          , p_assembly_type              IN NUMBER
                          , p_last_update_date           IN DATE
                          , p_last_updated_by            IN NUMBER
                          , p_creation_date              IN DATE
                          , p_created_by                 IN NUMBER
        , p_revised_item_seq_id  IN NUMBER
                          , p_original_system_reference  IN VARCHAR2
        , p_alternate_bom_code   IN VARCHAR2 := NULL)
IS
  CURSOR c_structure_type(  p_alternate_bom_code  IN VARCHAR2
        , p_organization_id     IN NUMBER
        )
        IS
  SELECT structure_type_id
    FROM bom_alternate_designators
   WHERE nvl(alternate_designator_code,'XXXXXXXXXXX') =
         nvl(p_alternate_bom_code, 'XXXXXXXXXXX' )
     and organization_id = p_organization_id;

  l_structure_type_id number;
  -- Added for bug 4550996
  CURSOR c_effectivity_control IS
  SELECT effectivity_control
    FROM mtl_system_items
   WHERE inventory_item_id = p_assembly_item_id
     AND organization_id = p_organization_id;

  l_effectivity_control NUMBER;
  -- End bug 4550996
BEGIN

  if bom_globals.get_debug = 'Y'
  then
    error_handler.write_debug('Rev_Comps: default structure type_id for alt: ' || p_alternate_bom_code);
  end if;

  if(p_alternate_bom_code is null)
  then
    for l_structure_type in c_structure_type( p_alternate_bom_code => p_alternate_bom_code
              , p_organization_id    => -1
               )
    loop
      l_structure_type_id := l_structure_type.structure_type_id;

    end loop;
  else
    for l_structure_type in c_structure_type( p_alternate_bom_code => p_alternate_bom_code
                                                        , p_organization_id    => p_organization_id
                                                         )
                loop
                        l_structure_type_id := l_structure_type.structure_type_id;

                end loop;
  end if;

  if bom_globals.get_debug = 'Y'
  then
      error_handler.write_debug('Rev_Comps: defaulted structure type id: ' || l_structure_type_id);
  end if;

  -- Added for fix of bug 4550996
  OPEN c_effectivity_control;
  FETCH c_effectivity_control INTO l_effectivity_control;
  CLOSE c_effectivity_control;
  IF bom_globals.get_debug = 'Y' THEN
      Error_handler.Write_debug('Rev_Comps: defaulted effectivity control: ' || l_effectivity_control);
  END IF;
  -- End fix of bug 4550996

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
                     , original_system_reference
                     , structure_type_id
                     , effectivity_control -- bug 4550996
                     , implementation_date -- bug 4550996
                     , alternate_bom_designator
                     , source_bill_sequence_id --Bug 4550996
                     , pk1_value --Bug 4550996
                     , pk2_value --Bug 4550996
                     )
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
                   , p_original_system_reference
                   , l_structure_type_id
                   , l_effectivity_control -- bug 4550996
                   , sysdate -- bug 4550996
                   , p_alternate_bom_code
                   , p_bill_sequence_id
                   , p_assembly_item_id
                   , p_organization_id
            );

                UPDATE eng_revised_items
                   SET bill_sequence_id = p_bill_sequence_id
                 WHERE revised_item_sequence_id = p_revised_item_seq_id;

END Create_New_Bill;

/***************************************************************************
* Procedure : Convert_Miss_To_Null
* Parameters IN : Revised component exposed column record
*     Revised component unexposed column record
* Parameters OUT: Revised Component exposed column record
*     Revised component unexposed column record.
* Purpose : This procedure will convert all missing columns to NULL.
****************************************************************************/
PROCEDURE Convert_Miss_To_Null
( p_rev_component_rec   IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec    IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Rev_Component_Rec   IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
, x_Rev_Comp_Unexp_Rec    IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
)
IS
l_rev_component_rec Bom_Bo_Pub.Rev_Component_Rec_Type :=
      p_rev_component_rec;
l_Rev_Comp_Unexp_Rec  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type :=
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

    IF l_rev_component_rec.acd_type = FND_API.G_MISS_NUM THEN
  l_rev_component_rec.acd_type := NULL;
    END IF;

    -- Added in 11.5.9 by ADEY
    IF l_rev_component_rec.auto_request_material = FND_API.G_MISS_CHAR THEN
        l_rev_component_rec.auto_request_material := NULL;
    END IF;

    IF l_rev_component_rec.Suggested_Vendor_Name = FND_API.G_MISS_CHAR THEN --- Deepu
        l_rev_component_rec.Suggested_Vendor_Name := NULL;
        l_Rev_Comp_Unexp_Rec.Vendor_Id := NULL;
    END IF;

/*
    IF l_rev_component_rec.purchasing_category_id = FND_API.G_MISS_NUM THEN --- Deepu
        l_rev_component_rec.purchasing_category_id := NULL;
    END IF;
*/
    IF l_rev_component_rec.Unit_Price = FND_API.G_MISS_NUM THEN --- Deepu
        l_rev_component_rec.Unit_Price := NULL;
    END IF;

    x_Rev_Component_Rec := l_rev_component_rec;
    x_Rev_Comp_Unexp_Rec := l_Rev_Comp_Unexp_Rec;

END Convert_Miss_To_Null;


FUNCTION Get_Operation_Leadtime (
		p_assembly_item_id IN NUMBER,
 		p_organization_id IN NUMBER,
   		p_alternate_bom_code IN VARCHAR2,
		p_operation_seq_num IN NUMBER)  RETURN NUMBER
IS

 l_leadtime_percent NUMBER;

 BEGIN

                SELECT  OPERATION_LEAD_TIME_PERCENT
                  into
 		   l_leadtime_percent
                  FROM
                       bom_operation_sequences  bos
                 WHERE
                   bos.routing_sequence_id =
                   (
                      select common_routing_sequence_id
                      from bom_operational_routings
                      where assembly_item_id = p_assembly_item_id
                            and organization_id = p_organization_id
                            and nvl(alternate_routing_designator,
                                  nvl(p_alternate_bom_code, 'NONE')) =
                                nvl(p_alternate_bom_code, 'NONE')
                            and (p_alternate_bom_code is null
                               or (p_alternate_bom_code is not null
                                   and (alternate_routing_designator =
                                          p_alternate_bom_code
                                        or not exists
                                          (select null
                                           from bom_operational_routings bor2
                                           where bor2.assembly_item_id =
                                                 p_assembly_item_id
                                                 and bor2.organization_id = p_organization_id
                                                 and bor2.alternate_routing_designator =                                                 p_alternate_bom_code
                                           )
                                        )
                                    )
                                 )
                   )
                   AND bos.operation_type = 1 --bug: 4161149
                   AND bos.operation_seq_num = p_operation_seq_num
                   and bos.implementation_date is not null
                   and bos.EFFECTIVITY_DATE <= sysdate
                   AND nvl(disable_date,  sysdate+1)
                                > sysdate;

return l_leadtime_percent;
EXCEPTION
  when no_data_found then
    return null; --  BUG : 4559089


END;


END Bom_Bom_Component_Util;

/
