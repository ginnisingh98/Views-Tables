--------------------------------------------------------
--  DDL for Package Body BOM_CONFIG_VALIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CONFIG_VALIDATION_PUB" AS
/* $Header: BOMPCFGB.pls 120.1 2005/12/02 04:44:03 hgelli noship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30):='BOM_Config_Validation_Pub';


/*-----------------------------------------------------------------------
Forward Declarations
------------------------------------------------------------------------*/

Procedure Check_Min_Max
( p_top_bill_sequence_id     IN  NUMBER
 ,p_model_qty                IN  NUMBER
 ,p_effective_date           IN  DATE
 ,p_options_tbl              IN  VALIDATE_OPTIONS_TBL_TYPE
 ,x_valid_config             OUT NOCOPY VARCHAR2
 ,x_return_status            OUT NOCOPY VARCHAR2);


PROCEDURE Check_Ratio_And_Parent
(p_options_tbl             IN  VALIDATE_OPTIONS_TBL_TYPE
,p_top_model_line_id       IN  NUMBER
,x_return_status           OUT NOCOPY VARCHAR2);


PROCEDURE Check_Class_Has_Options
(p_options_tbl             IN  VALIDATE_OPTIONS_TBL_TYPE
,x_complete_config         OUT NOCOPY VARCHAR2
,x_return_status           OUT NOCOPY VARCHAR2);


PROCEDURE Check_Mut_Excl_Options
 ( p_top_bill_sequence_id     IN  NUMBER
  ,p_effective_date           IN  DATE
  ,p_options_tbl              IN  VALIDATE_OPTIONS_TBL_TYPE
  ,x_valid_config             OUT NOCOPY VARCHAR2
  ,x_return_status            OUT NOCOPY VARCHAR2);


PROCEDURE Check_Mandatory_Classes
 ( p_top_bill_sequence_id     IN  NUMBER
  ,p_top_model_line_id        IN  NUMBER
  ,p_effective_date           IN  DATE
  ,p_options_tbl              IN  VALIDATE_OPTIONS_TBL_TYPE
  ,x_complete_config          OUT NOCOPY VARCHAR2
  ,x_return_status            OUT NOCOPY VARCHAR2);


FUNCTION Mutually_Exclusive_Comps_exist
( p_options_tbl     IN   VALIDATE_OPTIONS_TBL_TYPE
 ,p_component_code  IN   VARCHAR2)
RETURN BOOLEAN;


FUNCTION Mandatory_Comps_Missing
( p_options_tbl     IN   VALIDATE_OPTIONS_TBL_TYPE
 ,p_component_code  IN   VARCHAR2)
RETURN BOOLEAN;


FUNCTION Get_Parent_Quantity
( p_component_code     IN  VARCHAR2
 ,p_top_model_line_id  IN  NUMBER
 ,p_options_tbl        IN  VALIDATE_OPTIONS_TBL_TYPE)
RETURN NUMBER;


FUNCTION Check_Option_Exist
( p_component_code   IN  VARCHAR2
 ,p_options_tbl      IN  VALIDATE_OPTIONS_TBL_TYPE)
RETURN BOOLEAN;


FUNCTION Check_Parent_Exists
( p_component_code     IN  VARCHAR2
 ,p_index              IN  NUMBER
 ,p_top_model_line_id  IN  NUMBER
 ,p_options_tbl        IN  VALIDATE_OPTIONS_TBL_TYPE)
RETURN BOOLEAN;


PROCEDURE Handle_Ret_Status
(p_valid_config    IN VARCHAR2 := NULL
,p_complete_config IN VARCHAR2 := NULL);


PROCEDURE Print_Time(p_msg   IN  VARCHAR2);

/*-----------------------------------------------------------------------
PROCEDURE: Bom_Based_Config_Validation

This API takes a list of selected options (p_options_tbl) for the
top level model(p_top_model_line_id ) in OM.

It performs certain validations based on the BOM setup.
1) if the ordered quantity of any option is not out side of
   the Min - Max quantity settings in BOM.
2) if the ratio of ordered quantity of a class to model
   and option to class is integer ratio i.e. exact multiple.
3) to see that a class does not exist w/o any options selected for it.
4) if a class that has mutually exclusive options, does not have
   more than one options selected under it.
5) if at least one option is selected per mandatory class.

If any of the validation fails, it will populate error messages
and will return with a status of error.

Change Record:

ER2625376: changes made to BOM should be visible to Order unitl Booking.

OE_Config_Util.Get_Config_effective_Date should be used to decide
the date for effective/diabled filter on bom_explosions sqls.

p_creatione_date parameter will be renamed to p_effective_date.
------------------------------------------------------------------------*/

Procedure Bom_Based_Config_Validation
( p_top_model_line_id     IN  NUMBER
 ,p_options_tbl           IN  VALIDATE_OPTIONS_TBL_TYPE
 ,x_valid_config          OUT NOCOPY VARCHAR2
 ,x_complete_config       OUT NOCOPY VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
 )
IS
  l_return_status           VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS;
  l_top_bill_sequence_id    NUMBER;
  l_effective_date          DATE;
  l_model_qty               NUMBER;
  l_valid_config            VARCHAR2(10);
  l_complete_config         VARCHAR2(10);
  l_old_behavior            VARCHAR2(1);
  l_frozen_model_bill       VARCHAR2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING BOM_BASED_CONFIG_VALIDATION' , 1 ) ;
  END IF;
  Print_Time('Bom_Based_Config_Validation start time');

  G_VALID_CONFIG    := 'TRUE';
  G_COMPLETE_CONFIG := 'TRUE';

  BEGIN
    SELECT component_sequence_id, ordered_quantity
    INTO   l_top_bill_sequence_id, l_model_qty
    FROM   oe_order_lines
    WHERE  line_id = p_top_model_line_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('SELECT FAILED '|| SQLERRM , 1 ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;


  OE_Config_Util.Get_Config_Effective_Date
  ( p_model_line_id         => p_top_model_line_id
   ,x_old_behavior          => l_old_behavior
   ,x_config_effective_date => l_effective_date
   ,x_frozen_model_bill     => l_frozen_model_bill);


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CALLING CHECK_RATIO_AND_PARENT' , 1 ) ;
  END IF;

  Check_Ratio_And_Parent
 ( p_options_tbl              => p_options_tbl
  ,p_top_model_line_id        => p_top_model_line_id
  ,x_return_status            => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    Handle_Ret_Status(p_valid_config   => l_valid_config);
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CALLING CHECK_MIN_MAX' , 1 ) ;
  END IF;

  Check_Min_Max
 ( p_top_bill_sequence_id     => l_top_bill_sequence_id
  ,p_model_qty                => l_model_qty
  ,p_effective_date           => l_effective_date
  ,p_options_tbl              => p_options_tbl
  ,x_valid_config             => l_valid_config
  ,x_return_status            => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    Handle_Ret_Status(p_valid_config   => l_valid_config);
  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CALLING CHECK_CLASS_HAS_OPTIONS' , 1 ) ;
  END IF;

  Check_Class_Has_Options
 ( p_options_tbl              => p_options_tbl
  ,x_complete_config          => l_complete_config
  ,x_return_status            => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    Handle_Ret_Status(p_complete_config   => l_complete_config);
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CALLING CHECK_MUT_EXCL_OPTIONS' , 1 ) ;
  END IF;

  Check_Mut_Excl_Options
 ( p_top_bill_sequence_id     => l_top_bill_sequence_id
  ,p_effective_date           => l_effective_date
  ,p_options_tbl              => p_options_tbl
  ,x_valid_config             => l_valid_config
  ,x_return_status            => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    Handle_Ret_Status(p_valid_config   => l_valid_config);
  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CALLIN CHECK_MANDATORY_CLASSES' , 1 ) ;
  END IF;

  Check_Mandatory_Classes
 ( p_top_bill_sequence_id     => l_top_bill_sequence_id
  ,p_top_model_line_id        => p_top_model_line_id
  ,p_effective_date           => l_effective_date
  ,p_options_tbl              => p_options_tbl
  ,x_complete_config          => l_complete_config
  ,x_return_status            => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    Handle_Ret_Status(p_complete_config   => l_complete_config);
  END IF;


  x_valid_config     := G_VALID_CONFIG;
  x_complete_config  := G_COMPLETE_CONFIG;

  IF G_VALID_CONFIG    = 'FALSE' OR
     G_COMPLETE_CONFIG = 'FALSE' THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  Print_Time('Bom_Based_Config_Validation end time');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING BOM_BASED_CONFIG_VALIDATION'
                       || X_RETURN_STATUS , 1 ) ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('BOM_BASED_CONFIG_VALIDATION EXCEPTION'|| SQLERRM,1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
END Bom_Based_Config_Validation;


/*------------------------------------------------------------------------
PROCEDURE: Check_Ratio_And_Parent
This procedure performs 2 checks,
1) that the child's ordered qty  should be excat mutilple of the parent.
2) option do not exist w/o its parent class.

get the top model's quantity. We loop throgh the option table.
check the ratio of the quatities.
in the same run, check that the parent exists using a helper.

any error in this check should not be allowed to be saved.
so raise exception.

 Part of the logic in this procedure will not be used any more
 -- the decimal ratio check due to Decimal quantities for ATO Options
 Project.The decimal ratio check will be part of line entity validation
 in OEXLLINB.pls
-------------------------------------------------------------------------*/

PROCEDURE Check_Ratio_And_Parent
(p_options_tbl             IN  VALIDATE_OPTIONS_TBL_TYPE
,p_top_model_line_id       IN  NUMBER
,x_return_status           OUT NOCOPY VARCHAR2)
IS
  l_return_status          VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
  l_parent_qty             NUMBER;
  I                        NUMBER;
  l_parent_exists          BOOLEAN := FALSE;
  l_ordered_item           VARCHAR2(2000);
  l_item_type_code         VARCHAR2(30);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING CHECK_RATIO_AND_PARENT' , 1 ) ;
  END IF;
  Print_Time('Check_Ratio_And_Parent start time');

  SELECT ordered_quantity
  INTO   l_parent_qty
  FROM   oe_order_lines
  WHERE  line_id = p_top_model_line_id;

  I := p_options_tbl.FIRST ;

  WHILE I is not null
  LOOP
    IF INSTR(p_options_tbl(I).component_code , '-') <> 0 THEN -- not for model

      /****************** commneted during OM pack J project
      IF p_options_tbl(I).ordered_quantity = 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('QTY IS 0 , DONT CHECK'|| L_PARENT_QTY , 2 ) ;
        END IF;

      ELSE
        IF TRUNC(p_options_tbl(I).ordered_quantity/l_parent_qty) <>
                (p_options_tbl(I).ordered_quantity/l_parent_qty)
        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add('DECIMAL RATIO '||P_OPTIONS_TBL ( I ) .COMPONENT_CODE , 1 ) ;
          END IF;

          FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_DECIMAL_RATIO');

          IF p_options_tbl(I).bom_item_type = 1 THEN
            l_item_type_code := 'MODEL';
          ELSIF p_options_tbl(I).bom_item_type = 2 THEN
            l_item_type_code := 'CLASS';
          ELSE
            l_item_type_code := 'OPTION';
          END IF;

          FND_MESSAGE.Set_TOKEN('ITEM', p_options_tbl(I).ordered_item);
          FND_MESSAGE.Set_TOKEN('TYPECODE', l_item_type_code);
          FND_MESSAGE.Set_TOKEN
          ('VALUE', p_options_tbl(I).ordered_quantity/l_parent_qty);

          SELECT ordered_item, item_type_code
          INTO   l_ordered_item, l_item_type_code
          FROM   oe_order_lines
          WHERE  line_id = p_top_model_line_id;

          FND_MESSAGE.Set_TOKEN('MODEL', l_ordered_item);
          FND_MESSAGE.Set_TOKEN('PTYPECODE', l_item_type_code);

          OE_Msg_Pub.Add;

          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- if the qty = 0

      *********************************************************/

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('NOW CHECKING IF PARENT PRESENT' , 1 ) ;
      END IF;
      l_parent_exists :=  Check_Parent_Exists
                        ( p_component_code => p_options_tbl(I).component_code
                         ,p_index              => I
                         ,p_top_model_line_id  =>    p_top_model_line_id
                         ,p_options_tbl        =>    p_options_tbl);

      IF NOT l_parent_exists THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('MAJOR ERROR , CAN NOT GO FURTHER' , 2 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF; -- if not model

    I := p_options_tbl.NEXT(I);
  END LOOP;

  x_return_status := l_return_status;

  Print_Time('Check_Ratio_And_Parent end time');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING CHECK_RATIO_AND_PARENT' , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CHECK_RATIO_AND_PARENT EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Check_Ratio_And_Parent;


/*-----------------------------------------------------------------------
PROCEDURE: Check_Parent_Exists
This procedure is used to detect corrupt data(Oracle IT had this).
To see if every item in the configuration has immediate parent selected.
------------------------------------------------------------------------*/
FUNCTION Check_Parent_Exists
( p_component_code     IN  VARCHAR2
 ,p_index              IN  NUMBER
 ,p_top_model_line_id  IN  NUMBER
 ,p_options_tbl        IN  VALIDATE_OPTIONS_TBL_TYPE)
RETURN BOOLEAN
IS
  I                        NUMBER;
  l_open_flag              VARCHAR2(1);
  l_ordered_item           VARCHAR2(2000);
  l_line                   VARCHAR2(100);
  l_line_number            NUMBER;
  l_shipment_number        NUMBER;
  l_option_number          NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING CHECK_PARENT_EXISTS'|| P_COMPONENT_CODE , 1 ) ;
  END IF;
  Print_Time('Check_Parent_Exists start time');

  I := p_options_tbl.FIRST;
  WHILE I is not null
  LOOP
    IF p_options_tbl(I).component_code =  SUBSTR(p_component_code, 1,
                                         INSTR(p_component_code, '-', -1) - 1)
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('PARENT FOUND '|| P_OPTIONS_TBL ( I ) .COMPONENT_CODE , 1 ) ;
      END IF;
      RETURN TRUE;
    END IF;

    I := p_options_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('PARENT NOT FOUND , MAY BE CANCELED' , 1 ) ;
  END IF;

  BEGIN

    -- should not get more than 1 rows in all cases.
    SELECT open_flag
    INTO l_open_flag
    FROM oe_order_lines
    where line_id =
    (SELECT line_id
     FROM   oe_order_lines
     WHERE  top_model_line_id = p_top_model_line_id
     AND    component_code = SUBSTR(p_component_code, 1,
                             INSTR(p_component_code, '-', -1) - 1));

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OPEN_FLAG , QTY: '|| L_OPEN_FLAG , 3 ) ;
    END IF;

    IF l_open_flag = 'N' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('PARENT WAS CANCELLED' , 3 ) ;
      END IF;
      RETURN TRUE;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('NO PARENT' , 3 ) ;
      END IF;

      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_NO_PARENT');
      FND_MESSAGE.Set_TOKEN('ITEM', p_options_tbl(p_index).ordered_item);

      BEGIN
        SELECT ordered_item, line_number, shipment_number, option_number
        INTO   l_ordered_item, l_line_number, l_shipment_number, l_option_number
        FROM   oe_order_lines
        WHERE  top_model_line_id = p_top_model_line_id
        AND    component_code = p_component_code;

        l_line := l_line_number || '.'|| l_shipment_number ||'.'|| l_option_number;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_line := null;
      END;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('NOT YET CREATED' , 3 ) ;
      END IF;

      FND_MESSAGE.Set_TOKEN('LINE', l_line);
      OE_MSG_PUB.Add;

      RAISE FND_API.G_EXC_ERROR;
  END;

  RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CHECK_PARENT_EXISTS EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
      RETURN FALSE;
END Check_Parent_Exists;



/*-----------------------------------------------------------------------
PROCEDURE: Check_Min_Max
This procedure loops through the options table.
For each option,
it selects the min and max quantity from bom_explosions table. Some or all
of the options might not have the min max range set up in the BOM set up.
if the ordered quantity is not within the range, it popuplates a message
and it sets the return staus to error.
If all the options are within the min max range, we return success.
------------------------------------------------------------------------*/
Procedure Check_Min_Max
( p_top_bill_sequence_id     IN  NUMBER
 ,p_model_qty                IN  NUMBER
 ,p_effective_date           IN  DATE
 ,p_options_tbl              IN  VALIDATE_OPTIONS_TBL_TYPE
 ,x_valid_config             OUT NOCOPY VARCHAR2
 ,x_return_status            OUT NOCOPY VARCHAR2)
IS
  I                               NUMBER;
  l_max_allowed_qty               NUMBER;
  l_min_allowed_qty               NUMBER;
  l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_valid_config                  VARCHAR2(10) := 'TRUE';
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING CHECK_MIN_MAX' , 1 ) ;
  END IF;
  Print_Time('Check_Min_Max start time');

  I := p_options_tbl.FIRST;

  WHILE I is not NULL

  LOOP
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CHECKING MIN MAK FOR: '|| P_OPTIONS_TBL ( I ) .COMPONENT_CODE , 1 ) ;
    END IF;
    -- if the qty is 0, we delete the line before cancellation
    -- we close the line after cancellation, so no need to do this check.

    IF p_options_tbl(I).ordered_quantity = 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('NO CHECK SINCE QTY = 0' ) ;
      END IF;
    ELSE

      SELECT /*+ INDEX(BE1 BOM_EXPLOSIONS_N1) */
          nvl(be1.high_quantity,0), nvl(be1.low_quantity,0)
      INTO   l_max_allowed_qty, l_min_allowed_qty
      FROM   bom_explosions be1
      WHERE  be1.TOP_BILL_SEQUENCE_ID = p_top_bill_sequence_id
      AND    be1.component_code = p_options_tbl(I).component_code
      AND    be1.effectivity_date <=
                          p_effective_date
      AND    be1.disable_date >
                          p_effective_date
      AND    be1.explosion_type = 'OPTIONAL'
      AND    be1.plan_level >= 0;
      --AND    be1.sort_order = p_options_tbl(I).sort_order;

      IF l_min_allowed_qty <> 0 AND l_max_allowed_qty <> 0 THEN

        -- the trunc functions below were added for bugfix 3870948
        IF trunc(p_options_tbl(I).ordered_quantity/p_model_qty,9) < l_min_allowed_qty OR
           trunc(p_options_tbl(I).ordered_quantity/p_model_qty,9) > l_max_allowed_qty
        THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add('ORDERED QTY OUT OF RANGE' || P_OPTIONS_TBL ( I ) .ORDERED_QUANTITY , 1 ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add('MIN: '||L_MIN_ALLOWED_QTY || 'MAX: '||L_MAX_ALLOWED_QTY , 1 ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add('ITEM'|| P_OPTIONS_TBL ( I ) .ORDERED_ITEM , 1 ) ;
          END IF;

          FND_MESSAGE.Set_Name('ONT', 'OE_VAL_CONFIG_QTY_OUT_OF_RANGE');
          FND_MESSAGE.Set_Token('ITEM', p_options_tbl(I).ordered_item);
          FND_MESSAGE.Set_Token('LOW', l_min_allowed_qty);
          FND_MESSAGE.Set_Token('HIGH', l_max_allowed_qty);
          OE_Msg_Pub.Add;
          l_valid_config  := 'FALSE';
          l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('MIN MAX RANGE NOT SET' , 1 ) ;
        END IF;
      END IF; -- if there is min max setting

    END IF; -- if the qty was 0

    I := p_options_tbl.NEXT(I);
  END LOOP;

  x_valid_config  := l_valid_config;
  x_return_status := l_return_status;

  Print_Time('Check_Min_Max end time');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING CHECK_MIN_MAX' , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CHECK_MIN_MAX EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Check_Min_Max;


/*------------------------------------------------------------------------
FUNCTION: Check_Class_Has_Options
All the classes in a configuration should have at least
one option selected.
-------------------------------------------------------------------------*/
PROCEDURE Check_Class_Has_Options
(p_options_tbl             IN  VALIDATE_OPTIONS_TBL_TYPE
,x_complete_config         OUT NOCOPY VARCHAR2
,x_return_status           OUT NOCOPY VARCHAR2)
IS
  I                 NUMBER;
  l_no_child        BOOLEAN;
  l_return_status   VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
  l_complete_config VARCHAR2(10) := 'TRUE';
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING CHECK_CLASS_HAS_OPTIONS' , 1 ) ;
  END IF;
  Print_Time('Check_Class_Has_Options start time');

  I := p_options_tbl.FIRST ;

  WHILE I is not null
  LOOP
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('BOM_ITEM_TYPE: '|| P_OPTIONS_TBL ( I ) .BOM_ITEM_TYPE , 1 ) ;
    END IF;
    -- model line has null, so will not go in.
    IF p_options_tbl(I).bom_item_type = 2 THEN

      IF p_options_tbl(I).ordered_quantity = 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('NO NEED TO CHECK , EITHER DELETE OR CLOSE' , 1 ) ;
        END IF;

      ELSE

        l_no_child := Check_Option_Exist
                      ( p_component_code   => p_options_tbl(I).component_code
                       ,p_options_tbl      => p_options_tbl);
        IF NOT l_no_child THEN
          FND_MESSAGE.Set_Name('ONT', 'OE_VAL_CONFIG_CLASS_NO_OPTION');
          FND_MESSAGE.Set_Token('CLASS', p_options_tbl(I).ordered_item);
          OE_Msg_Pub.Add;
          l_complete_config  := 'FALSE';
          l_return_status    := FND_API.G_RET_STS_ERROR;
        END IF; -- if no child

      END IF; -- if qty = 0

    END IF; -- if a class

    I := p_options_tbl.NEXT(I);
  END LOOP;

  x_complete_config  := l_complete_config;
  x_return_status    := l_return_status;

  Print_Time('Check_Class_Has_Options end time');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING CHECK_CLASS_HAS_OPTIONS' , 1 ) ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CHECK_CLASS_HAS_OPTIONS EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Check_Class_Has_Options;


/*------------------------------------------------------------------------
FUNCTION: Check_Option_Exist
p_component_code is the class for which we will find out
if a option exist or not.
-------------------------------------------------------------------------*/
FUNCTION Check_Option_Exist
( p_component_code   IN  VARCHAR2
 ,p_options_tbl      IN  VALIDATE_OPTIONS_TBL_TYPE)
RETURN BOOLEAN
IS
  I    NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING CHECK_OPTION_EXIST' , 1 ) ;
  END IF;

  I := p_options_tbl.FIRST;
  WHILE I is not null
  LOOP
    IF p_component_code = SUBSTR(p_options_tbl(I).component_code, 1,
                                 INSTR(p_options_tbl(I).component_code, '-', -1) - 1)
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('CHILD FOUND '|| P_OPTIONS_TBL ( I ) .COMPONENT_CODE , 1 ) ;
      END IF;
      RETURN true;
    END IF;

    I := p_options_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING CHECK_OPTION_EXIST WITH NO CHILD' , 1 ) ;
  END IF;
  RETURN false;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CHECK_OPTION_EXIST EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Check_Option_Exist;


/*------------------------------------------------------------------------
PROCEDURE: Check_Mut_Excl_Options
Opens a cursor of all the classes which have mutually exclusive options
set up in the BOM.
For every such class,
finds out if more than one option is selected. If so, it popuplates a error
message and sets the return status to error.
If all the classes with mutually exclusive options have only one option
selected, it returs success.
-------------------------------------------------------------------------*/

PROCEDURE Check_Mut_Excl_Options
 ( p_top_bill_sequence_id     IN  NUMBER
  ,p_effective_date           IN  DATE
  ,p_options_tbl              IN  VALIDATE_OPTIONS_TBL_TYPE
  ,x_valid_config             OUT NOCOPY VARCHAR2
  ,x_return_status            OUT NOCOPY VARCHAR2)
IS
  I                               NUMBER;
  l_top_bill_sequence_id          NUMBER;
  l_description                   VARCHAR2(240);
  l_component_code                VARCHAR2(1000);
  l_result                        BOOLEAN;
  l_return_status                 VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
  l_valid_config                  VARCHAR2(10) := 'TRUE';

  CURSOR MUTUALLY_EXCLUSIVE_OPTIONS IS
  SELECT   /*+ INDEX(BOMEXP BOM_EXPLOSIONS_N1) */
      bomexp.description, bomexp.component_code
  FROM     BOM_EXPLOSIONS BOMEXP
  WHERE    bomexp.explosion_type = 'OPTIONAL'
  AND      bomexp.top_bill_sequence_id = p_top_bill_sequence_id
  AND      bomexp.plan_level >= 0
  AND      bomexp.effectivity_date <=
           p_effective_date
  AND      bomexp.disable_date >
           p_effective_date
  AND      bomexp.bom_item_type in ( 1, 2 ) /* Model, Class */
  AND      bomexp.mutually_exclusive_options = 1 /* Exclusive */
  ORDER BY bomexp.sort_order;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING CHECK_MUT_EXCL_OPTIONS' , 1 ) ;
  END IF;
  Print_Time('Check_Mut_Excl_Options start time');

  FOR bom_rec in MUTUALLY_EXCLUSIVE_OPTIONS
  LOOP
    l_result := Mutually_Exclusive_Comps_exist
                ( p_options_tbl     => p_options_tbl
                 ,p_component_code  => bom_rec.component_code);

    IF l_result THEN
      FND_MESSAGE.Set_Name('ONT', 'OE_VAL_CONFIG_EXCLUSIVE_CLASS');
      FND_MESSAGE.Set_Token('CLASS', bom_rec.description);
      OE_Msg_Pub.Add;
      l_valid_config  := 'FALSE';
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END LOOP;

  x_valid_config  := l_valid_config;
  x_return_status := l_return_status;

  Print_Time('Check_Mut_Excl_Options end time');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING CHECK_MUT_EXCL_OPTIONS' , 1 ) ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CHECK_MUT_EXCL_OPTIONS EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Check_Mut_Excl_Options;


/*------------------------------------------------------------------------
FUNCTION Mutually_Exclusive_Comps_exist

This function will be called for 1 class with
mutually exclusive options at a time.

Loop through options table, find ou number of options for class
p_component_code, using the component_code field.
e.g.:
p_component_code => 100-200
p_options_tbl    =>
100-200     -- mutually exclusive options set in BOM.
100-200-300 -- 1st
100-200-400 -- 2nd, this is error
100-500
100

IF a configuration has more than 1 components from a class
that has mutually exclusive options, this function returns true.
Else it returns false.
-------------------------------------------------------------------------*/

FUNCTION Mutually_Exclusive_Comps_exist
( p_options_tbl     IN  VALIDATE_OPTIONS_TBL_TYPE
 ,p_component_code  IN  VARCHAR2)
RETURN BOOLEAN
IS
  l_count       NUMBER;
  I             NUMBER;
  l_component   VARCHAR2(1000);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING MUTUALLY_EXCLUSIVE_COMPS_EXIST' , 1 ) ;
  END IF;

 I := p_options_tbl.FIRST;

  l_count := 0;

  WHILE I is not NULL AND l_count < 2
  LOOP
    l_component := SUBSTR(p_options_tbl(I).component_code,
                          1, (INSTR(p_options_tbl(I).component_code, '-', -1) - 1));

    IF l_component = p_component_code AND
       p_options_tbl(I).ordered_quantity <> 0 -- if 0, either will be deleted or closed
    THEN
      l_count := l_count + 1;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  L_COUNT ||' OPTION PRESENT'|| P_OPTIONS_TBL ( I ) .COMPONENT_CODE , 2 ) ;
      END IF;
    END IF;

    I := p_options_tbl.NEXT(I);
  END LOOP;

  IF l_count >= 2 THEN
    RETURN true;
  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('NO MUTAUL EXCLUSION IN CLASS '|| P_COMPONENT_CODE , 1 ) ;
    END IF;
    RETURN false;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING MUTUALLY_EXCLUSIVE_COMPS_EXIST' , 1 ) ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('MUTUALLY_EXCLUSIVE_COMPS_EXIST EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Mutually_Exclusive_Comps_exist;


/*------------------------------------------------------------------------
PROCEDURE: Check_Mandatory_Classes
Opens a cursor which has all classes which are mandatory to this model.
For every such class,
check if at least one option is selectd. If not populte error messate and
set retruns status to error.
-------------------------------------------------------------------------*/

PROCEDURE Check_Mandatory_Classes
 ( p_top_bill_sequence_id     IN  NUMBER
  ,p_top_model_line_id        IN  NUMBER
  ,p_effective_date           IN  DATE
  ,p_options_tbl              IN  VALIDATE_OPTIONS_TBL_TYPE
  ,x_complete_config          OUT NOCOPY VARCHAR2
  ,x_return_status            OUT NOCOPY VARCHAR2)
IS
  l_top_bill_sequence_id          NUMBER;
  l_description                   VARCHAR2(240);
  l_component_code                VARCHAR2(1000);
  l_result                        BOOLEAN;
  l_return_status                 VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
  l_complete_config               VARCHAR2(10) := 'TRUE';

  CURSOR MANDATORY_COMPONENTS IS
  SELECT /*+ INDEX(BOMEXP BOM_EXPLOSIONS_N1) */
      bomexp.description, bomexp.component_code
        --,bomexp.sort_order???? perf
  FROM  bom_explosions bomexp
  WHERE bomexp.explosion_type = 'OPTIONAL'
  AND   bomexp.top_bill_sequence_id = p_top_bill_sequence_id
  AND   bomexp.plan_level >= 0
  AND   bomexp.effectivity_date <=
        p_effective_date
  AND   bomexp.disable_date >
        p_effective_date
  AND   bomexp.bom_item_type IN ( 1, 2 )  -- Model, Class
  AND   bomexp.optional = 2;               -- Mandatory

/*
  CURSOR MANDATORY_COMPONENTS IS
  SELECT bomexp.description, bomexp.component_code
  FROM     OE_ORDER_LINES OECFG
  ,        BOM_EXPLOSIONS BOMEXP
  WHERE   OECFG.TOP_MODEL_LINE_ID = p_top_model_line_id
  AND     OECFG.SERVICE_REFERENCE_LINE_ID IS NULL
  AND     OECFG.ITEM_TYPE_CODE IN ( 'MODEL', 'CLASS' )
  AND     BOMEXP.EXPLOSION_TYPE = 'OPTIONAL'
  AND     BOMEXP.TOP_BILL_SEQUENCE_ID = p_top_bill_sequence_id ???????? + 0
  AND     BOMEXP.PLAN_LEVEL >= 0
  AND     BOMEXP.EFFECTIVITY_DATE <= sysdate
  AND     BOMEXP.DISABLE_DATE > sysdate
  AND     BOMEXP.BOM_ITEM_TYPE IN ( 1, 2 )  Model, Class
  AND     BOMEXP.OPTIONAL = 2  Mandatory
  AND     BOMEXP.Component_code like OECFG.component_code || '%'
  AND     SUBSTR( BOMEXP.COMPONENT_CODE, 1,
          LENGTH( RTRIM( BOMEXP.COMPONENT_CODE,
                 '0123456789' ) ) - 1 ) = OECFG.COMPONENT_CODE
  AND     NOT EXISTS (
          SELECT NULL
          FROM   OE_ORDER_LINES OEOPT
          WHERE  OEOPT.TOP_MODEL_LINE_ID = p_top_model_line_id
          AND    OEOPT.SERVICE_REFERENCE_LINE_ID IS NULL
          AND    OEOPT.COMPONENT_CODE = BOMEXP.COMPONENT_CODE
          )
  ORDER BY BOMEXP.SORT_ORDER;
*/
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING CHECK_MANDATORY_CLASSES' , 1 ) ;
  END IF;
  Print_Time('Check_Mandatory_Classes start time');

  for bom_rec in MANDATORY_COMPONENTS
  LOOP
    l_result := Mandatory_Comps_Missing
                ( p_options_tbl     => p_options_tbl
                 ,p_component_code  => bom_rec.component_code);

    IF l_result THEN
      FND_MESSAGE.Set_Name('ONT', 'OE_VAL_CONFIG_MANDATORY_CLASS');
      FND_MESSAGE.Set_Token('CLASS', bom_rec.description);
      OE_Msg_Pub.Add;
      l_complete_config  := 'FALSE';
      l_return_status    := FND_API.G_RET_STS_ERROR;
    END IF;

  END LOOP;

  x_complete_config  := l_complete_config;
  x_return_status    := l_return_status;

  Print_Time('Check_Mandatory_Classes end time');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING CHECK_MANDATORY_CLASSES '|| L_RETURN_STATUS , 1 ) ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CHECK_MANDATORY_CLASSES EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Check_Mandatory_Classes;


/*------------------------------------------------------------------------
FUNCTION: Mandatory_Comps_Missing

This function finds out if a mandatory component is missing
in the configuration, working on one class at a time.

It uses the pl/sql table of options => p_options_tbl to figure out if
any of the mandatory components for a particular class/model =>
p_component_code is missing.

Returns true, if finds out that mandatory component is missing.
Else returns false.
e.g.=>
p_component_code => 100-500
p_options_tbl    =>
100-200
100-200-300
100-500 -- mandatory class w/o options is error.
100

-------------------------------------------------------------------------*/
FUNCTION Mandatory_Comps_Missing
( p_options_tbl     IN   VALIDATE_OPTIONS_TBL_TYPE
 ,p_component_code  IN   VARCHAR2)
RETURN BOOLEAN
IS
I             NUMBER;
l_found       BOOLEAN;
l_component   VARCHAR2(1000);
J             NUMBER;
l_parent      BOOLEAN;
l_parent_component   VARCHAR2(1000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING MANDATORY_COMPS_MISSING' , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COMPONENT IN ' || P_COMPONENT_CODE , 2 ) ;
  END IF;

  -- Check for mandatory component parent existance in the table.
  -- Look for options only if the parent of the passed component is
  -- found. Other wise return false.

  l_parent := false;

  l_parent_component :=  SUBSTR(p_component_code,1,
                         (INSTR(p_component_code, '-', -1) -1));

  J  := p_options_tbl.FIRST;

  WHILE J is not NULL AND NOT l_parent
  LOOP

   --bug3542229: Front porting
   --Make sure that the option class itself is present
   --The parent may be present due to selection of some other child
   --as well
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('ORDQTY:'||p_options_tbl(J).ordered_quantity);
   END IF;

   --IF  p_options_tbl(J).component_code = p_component_code AND
   IF p_options_tbl(J).component_code = l_parent_component AND --fp: 3618150
       p_options_tbl(J).ordered_quantity <> 0
   THEN
       l_parent := true;
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('PARENT FOUND ' || L_PARENT_COMPONENT , 2 ) ;
       END IF;
   END IF;

   J :=  p_options_tbl.NEXT(J);

  END LOOP;


 IF l_parent THEN
    I := p_options_tbl.FIRST;

    l_found := false;

    WHILE I is not NULL AND NOT l_found
    LOOP
       l_component := SUBSTR(p_options_tbl(I).component_code, 1,
				  (INSTR(p_options_tbl(I).component_code, '-', -1) - 1));

       IF l_component = p_component_code AND
          p_options_tbl(I).ordered_quantity <> 0
       THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add('MANDATORY OPTION PRESENT'|| P_OPTIONS_TBL ( I ) .COMPONENT_CODE , 2 ) ;
         END IF;
         l_found := true;
       END IF;

       I := p_options_tbl.NEXT(I);
    END LOOP;

    IF l_found THEN
       RETURN false;
    ELSE
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('MANDATORY COMP MISSING IN CLASS '|| L_COMPONENT , 1 ) ;
       END IF;
       RETURN true;
    END IF;

 ELSE

   RETURN false;

 END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING MANDATORY_COMPS_MISSING' , 1 ) ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('MANDATORY_COMPS_MISSING EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Mandatory_Comps_Missing;


/*------------------------------------------------------------------------
PROCEDURE Print_Time

-------------------------------------------------------------------------*/

PROCEDURE Print_Time(p_msg   IN  VARCHAR2)
IS
  l_time    VARCHAR2(100);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  l_time := to_char (new_time (sysdate, 'PST', 'EST'),
                                 'DD-MON-YY HH24:MI:SS');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  P_MSG || ': '|| L_TIME , 1 ) ;
  END IF;
END Print_Time;


/*------------------------------------------------------------------------
PROCEDURE Handle_Ret_Status

-------------------------------------------------------------------------*/

PROCEDURE Handle_Ret_Status
(p_valid_config    IN VARCHAR2 := NULL
,p_complete_config IN VARCHAR2 := NULL)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF nvl(p_valid_config, 'TRUE') = 'FALSE' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('SETTING VALID_CONFIG TO FALSE' , 1 ) ;
    END IF;
    G_VALID_CONFIG := 'FALSE';
  END IF;

  IF nvl(p_complete_config, 'TRUE') = 'FALSE' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('SETTING COMPLETE_CONFIG TO FALSE' , 1 ) ;
    END IF;
    G_VALID_CONFIG := 'FALSE';
  END IF;
END Handle_Ret_Status;



/*------------------------------------------------------------------------
FUNCTION: Get_Parent_Quantity
Loops through p_options_tbl. Finds out  the parent of p_component_code
using component_code field in the p_options_tbl. returns parent's qty.

Not used, similar code in Check_Parent_Exists.
-------------------------------------------------------------------------*/
FUNCTION Get_Parent_Quantity
( p_component_code     IN  VARCHAR2
 ,p_top_model_line_id  IN  NUMBER
 ,p_options_tbl        IN  VALIDATE_OPTIONS_TBL_TYPE)
RETURN NUMBER
IS
  I                    NUMBER;
  l_open_flag          VARCHAR2(1);
  l_ordered_quantity   NUMBER;
  l_ordered_item       VARCHAR2(2000);
  l_line_number        NUMBER;
  l_shipment_number    NUMBER;
  l_option_number      NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING GET_PARENT_QUANTITY' , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('FIND PARENT QTY FOR: '|| P_COMPONENT_CODE , 1 ) ;
  END IF;

  I := p_options_tbl.FIRST;
  WHILE I is not null
  LOOP
    IF p_options_tbl(I).component_code =  SUBSTR(p_component_code, 1,
                                          INSTR(p_component_code, '-', -1) - 1)
    THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('PARENT FOUND '|| P_OPTIONS_TBL ( I ) .COMPONENT_CODE , 1 ) ;
      END IF;
      RETURN p_options_tbl(I).ordered_quantity;
    END IF;

    I := p_options_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('NO PARENT FOR ' || P_COMPONENT_CODE , 1 ) ;
  END IF;
  RAISE FND_API.G_EXC_ERROR;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('PARENT NOT FOUND , MAY BE CANCELED' , 1 ) ;
    END IF;

    BEGIN

      SELECT open_flag, ordered_quantity
      INTO l_open_flag, l_ordered_quantity
      FROM oe_order_lines
      where line_id =
      (SELECT line_id
       FROM   oe_order_lines
       WHERE  top_model_line_id = p_top_model_line_id
       AND    component_code = SUBSTR(p_component_code, 1,
                               INSTR(p_component_code, '-', -1) - 1));

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('OPEN_FLAG , QTY: '|| L_OPEN_FLAG || L_ORDERED_QUANTITY , 3 ) ;
       END IF;

      IF l_open_flag = 'N' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('PARENT WAS CANCELLED' , 3 ) ;
        END IF;
        RETURN l_ordered_quantity;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('NO PARENT' , 3 ) ;
        END IF;

        SELECT ordered_item, line_number, shipment_number, option_number
        INTO   l_ordered_item, l_line_number, l_shipment_number, l_option_number
        FROM   oe_order_lines
        WHERE  top_model_line_id = p_top_model_line_id
        AND    component_code = p_component_code;

        FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_NO_PARENT');
        FND_MESSAGE.Set_TOKEN('ITEM', l_ordered_item);
        FND_MESSAGE.Set_TOKEN
        ('LINE', l_line_number || '.'|| l_shipment_number ||'.'|| l_option_number);
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('GET_PARENT_QUANTITY EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Get_Parent_Quantity;

END BOM_Config_Validation_Pub;

/
