--------------------------------------------------------
--  DDL for Package Body OE_PROCESS_OPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PROCESS_OPTIONS_PVT" AS
/* $Header: OEXVOPTB.pls 120.2.12010000.2 2009/07/03 11:32:27 nitagarw ship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30):='OE_Process_Options_Pvt';
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT;               -- Added for bug 8656395


/*-----------------------------------------------------------------------
Forward Declarations
------------------------------------------------------------------------*/

Procedure Handle_DML
( p_options_tbl           IN  OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_model_line_rec        IN  OUT NOCOPY OE_Order_Pub.Line_Rec_Type
 ,p_ui_flag               IN  VARCHAR2
 ,x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


Procedure Fill_In_Classes
( p_top_model_line_id    IN  NUMBER
 ,p_model_component      IN  VARCHAR2
 ,p_model_quantity       IN  NUMBER
 ,p_top_bill_sequence_id IN  NUMBER
 ,p_effective_date       IN  DATE
 ,p_ui_flag              IN VARCHAR2
 ,p_x_options_tbl IN OUT NOCOPY OE_Process_Options_Pvt.SELECTED_OPTIONS_TBL_TYPE
 ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE component_exists
( p_component             IN  VARCHAR2
 ,p_options_tbl           IN OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,x_result                OUT NOCOPY /* file.sql.39 change */ BOOLEAN);


PROCEDURE Check_Duplicate_Components
( p_options_tbl           IN  OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


PROCEDURE Load_BOM_Table
( p_options_tbl         IN  OE_Process_Options_Pvt.SELECTED_OPTIONS_TBL_TYPE
 ,x_bom_validation_tbl  OUT NOCOPY OE_CONFIG_VALIDATION_PVT.VALIDATE_OPTIONS_TBL_TYPE);


PROCEDURE Handle_Disabled_Options
( p_x_option_rec IN OUT NOCOPY OE_Process_Options_Pvt.SELECTED_OPTIONS_REC
 ,p_top_model_line_id  IN  NUMBER);

/* --------------------------------------------------------------------
Procedure Name :  Process_Config_Options
Description    :
This procedure works on the selected options from options window.
1) It first completes the configuration, which means some of the classes
that are not selected by the user are filled in the table of options.
2) After that the configuration is validated using BOM rules.
3) Then we call process_order API to create the option / class lines in
oe tables.

There can not be a duplicate class(llid caode will fail),
however I do not know about a duplicate options. May be we should
have a handled exception for this.

Exception block:
options window UI populates process_messages window to display errors.
If the return status is unexp error, the continue button is disabled
if it is execution error, continue button on msg window is enabled.

we want user to continue only in case of bom based validation failure.
other cases no matter what is the ret status(ex: process_order returned
execution error, we can not commit user changes, so no point in keeping
continue enabled.)
So I am manipulating the return status to always return unexp error
in exception handling block here, in case of a UI call.
In case of delayed request call, we will return what ever
is the error.
The return status is not used in any other way by Options window UI.

Change record:
3687870 : check the fulfilled_flag, open flag etc. for UI.
---------------------------------------------------------------------- */

Procedure Process_Config_Options
( p_options_tbl         IN  OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_header_id           IN  NUMBER
 ,p_top_model_line_id   IN  NUMBER
 ,p_ui_flag             IN  VARCHAR2 := 'Y'
 ,p_caller              IN  VARCHAR2 := '' -- bug 4636208
 ,x_valid_config        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ,x_complete_config     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ,x_change_flag         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ,x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER
 ,x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ,x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
  l_model_line_rec      OE_Order_Pub.Line_Rec_Type;
  l_return_status       VARCHAR2(1):=  FND_API.G_RET_STS_SUCCESS;
  l_validation_status   VARCHAR2(1):=  FND_API.G_RET_STS_SUCCESS;
  l_options_tbl         OE_Process_Options_Pvt.Selected_Options_Tbl_Type;
  l_db_options_tbl      OE_Process_Options_Pvt.SELECTED_OPTIONS_TBL_TYPE;
  l_bom_validation_tbl  OE_CONFIG_VALIDATION_PVT.VALIDATE_OPTIONS_TBL_TYPE;
  l_count               NUMBER;
  I                     NUMBER;
  l_index               NUMBER;
  l_operation           VARCHAR2(1);
  l_valid_config        VARCHAR2(10);
  l_complete_config     VARCHAR2(10);
  l_deleted_options_tbl OE_Order_PUB.request_tbl_type;
  l_updated_options_tbl OE_Order_PUB.request_tbl_type;
  l_rev_date            DATE;
  l_frozen_model_bill   VARCHAR2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --

BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING PROCESS_CONFIG_OPTIONS' , 5 ) ;
  END IF;

  Print_Time('Process_Config_Options start time');

  IF p_ui_flag = 'Y' Then
    OE_Msg_Pub.Initialize;
  END IF;

  OE_Msg_Pub.Set_Msg_Context
  ( p_entity_code => OE_Globals.G_ENTITY_LINE
   ,p_entity_id   => p_top_model_line_id
   ,p_header_id   => p_header_id
   ,p_line_id     => p_top_model_line_id);


  OE_LINE_UTIL.Lock_Row
  ( p_line_id       => p_top_model_line_id
   ,p_x_line_rec    => l_model_line_rec
   ,x_return_status => l_return_status);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    FND_MESSAGE.Set_Name('ONT', 'OE_ORDER_OBJECT_LOCKED');
    OE_MSG_PUB.Add;
  END IF;

  Handle_Ret_Status(p_return_status => l_return_status);

  IF p_ui_flag = 'Y' Then

    oe_debug_pub.add('fulfilled_flag'|| l_model_line_rec.fulfilled_flag , 1 ) ;
    oe_debug_pub.add('open_flag'|| l_model_line_rec.open_flag , 1 ) ;

    IF nvl(l_model_line_rec.open_flag, 'Y') = 'N' THEN
      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_MODEL_CLOSED');
      FND_MESSAGE.Set_Token('MODEL', l_model_line_rec.ordered_item);
      OE_MSG_PUB.Add;

      IF l_debug_level > 0 then
        oe_debug_pub.add('model line is closed', 1);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_model_line_rec.fulfilled_flag  = 'Y' THEN
      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_MODEL_FULFILLED');
      FND_MESSAGE.Set_Token('MODEL', l_model_line_rec.ordered_item);
      OE_MSG_PUB.Add;
      IF l_debug_level > 0 then
        oe_debug_pub.add('model line is fulfilled', 1);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF nvl(l_model_line_rec.model_remnant_flag, 'N') = 'Y'  THEN
      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_REMNANT_NO_CHANGES');
      FND_MESSAGE.Set_Token('MODEL', l_model_line_rec.ordered_item);
      OE_MSG_PUB.Add;
      IF l_debug_level > 0 then
        oe_debug_pub.add('remnant model', 1);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
   END IF;


  OE_MSG_PUB.update_msg_context
  ( p_entity_code                => 'LINE'
   ,p_entity_id                  => l_model_line_rec.line_id
   ,p_header_id                  => l_model_line_rec.header_id
   ,p_line_id                    => l_model_line_rec.line_id
   ,p_order_source_id            => l_model_line_rec.order_source_id
   ,p_orig_sys_document_ref      => l_model_line_rec.orig_sys_document_ref
   ,p_orig_sys_document_line_ref => l_model_line_rec.orig_sys_line_ref
   ,p_orig_sys_shipment_ref      => l_model_line_rec.orig_sys_shipment_ref
   ,p_change_sequence            => l_model_line_rec.change_sequence
   ,p_source_document_id         => l_model_line_rec.source_document_id
   ,p_source_document_line_id    => l_model_line_rec.source_document_line_id
   ,p_source_document_type_id    => l_model_line_rec.source_document_type_id);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CALLING EXPLODE_BILL' , 1 ) ;
  END IF;

  oe_config_pvt.Explode_Bill
  ( p_model_line_rec        => l_model_line_rec
   ,x_config_effective_date => l_rev_date
   ,x_frozen_model_bill     => l_frozen_model_bill
   ,x_return_status         => l_return_status);

  Handle_Ret_Status(p_return_status => l_return_status);


  l_options_tbl := p_options_tbl;

  -- since fill_in_classes and validation needs all the options
  -- get the ones which arenot passed and populate the options_tbl
  -- including the model line, the operation should be NONE or CREATE.

  -- if first time create and UI, use i/p options_tbl as base
  -- if update/del and UI., use db_options_tbl as base.
  -- in case batch val, db_options tbl is sent in by caller.
  -- this is for perf reasons.

  IF p_ui_flag = 'Y' THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GETTING PREVIOUSLY SAVED OPTIONS FROM DB' , 2 ) ;
    END IF;

    Get_Options_From_DB( p_top_model_line_id  => p_top_model_line_id
                        ,p_get_model_line     => TRUE
                        ,p_caller             => 'OPTIONS WINDOW UI'
                        ,p_query_criteria     => 4
                        ,x_disabled_options   => l_frozen_model_bill
                        ,x_options_tbl        => l_db_options_tbl);

    l_count := l_options_tbl.LAST;
    I := l_db_options_tbl.FIRST;
    WHILE I is not null
    LOOP

      BEGIN
        -- if already exist, do not add, continue
        l_index := Find_Matching_comp_index
                   ( p_options_tbl  => l_options_tbl --=> sent in by caller.
                    ,p_comp_code    => l_db_options_tbl(I).component_code);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add
          ('CONTINUE: '|| L_OPTIONS_TBL ( L_INDEX ) .COMPONENT_CODE , 2 ) ;
        END IF;
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        l_count := l_count + 1;
        l_options_tbl(l_count) := l_db_options_tbl(I);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add
          (I ||' ADD DB COMP: '|| L_DB_OPTIONS_TBL ( I ).COMPONENT_CODE , 1);
        END IF;

      END;

      I := l_db_options_tbl.NEXT(I);
    END LOOP;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CALLING CHECK_DUPLICATE_COMPONENTS' , 1 ) ;
  END IF;

  Check_Duplicate_Components
  ( p_options_tbl     => l_options_tbl
   ,x_return_status   => l_return_status );

  Handle_Ret_Status(p_return_status => l_return_status);


  -- cascade updates/deletes
  IF p_ui_flag = 'Y' THEN

    Prepare_Cascade_Tables
    ( p_options_tbl           => l_options_tbl
     ,p_top_model_line_id     => p_top_model_line_id
     ,p_x_updated_options_tbl => l_updated_options_tbl
     ,p_x_deleted_options_tbl => l_deleted_options_tbl);

    IF l_updated_options_tbl.COUNT > 0 OR
       l_deleted_options_tbl.COUNT > 0 THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING CASCADE_UPDATES_DELETES' , 1 ) ;
      END IF;

      OE_Config_Util.Cascade_Updates_Deletes
      ( p_model_line_id       => p_top_model_line_id
       ,p_model_component     => l_model_line_rec.component_code
       ,p_x_options_tbl       => l_options_tbl
       ,p_deleted_options_tbl => l_deleted_options_tbl
       ,p_updated_options_tbl => l_updated_options_tbl
       ,p_ui_flag             => p_ui_flag
       ,x_return_status       => l_return_status);

    END IF;
  END IF; -- if ui flag is Y


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CALLING FILL_IN_CLASSES' , 1 ) ;
  END IF;


  Fill_In_Classes
 ( p_top_model_line_id    => p_top_model_line_id
  ,p_model_component      => l_model_line_rec.component_code
  ,p_model_quantity       => l_model_line_rec.ordered_quantity
  ,p_top_bill_sequence_id => l_model_line_rec.component_sequence_id
  ,p_effective_date       => l_rev_date
  ,p_ui_flag              => p_ui_flag
  ,p_x_options_tbl        => l_options_tbl
  ,x_return_status        => l_return_status);

  Handle_Ret_Status(p_return_status => l_return_status);


  Load_BOM_Table
  ( p_options_tbl          => l_options_tbl
   ,x_bom_validation_tbl   => l_bom_validation_tbl);


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CALLING BOM_BASED_VALIDATION' , 1 ) ;
  END IF;

  IF l_bom_validation_tbl.COUNT > 0 THEN

    OE_CONFIG_VALIDATION_PVT.Bom_Based_Config_Validation
    ( p_top_model_line_id     => p_top_model_line_id
     ,p_options_tbl           => l_bom_validation_tbl
     ,x_valid_config          => l_valid_config
     ,x_complete_config       => l_complete_config
     ,x_return_status         => l_validation_status);

    x_valid_config    := l_valid_config;
    x_complete_config := l_complete_config;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'VALIDATION STATUS '|| L_VALIDATION_STATUS , 1 ) ;
    END IF;

    IF l_validation_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_validation_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_VALIDATION_FAILURE');
      OE_Msg_Pub.Add;
    END IF; -- status = success

    -- added for bug 4636208
    IF p_caller = 'BOOKING' AND
       (l_valid_config = 'FALSE' OR l_complete_config = 'FALSE') THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CALLER IS BOOKING AND ERRORED OUT' , 2 );
      END IF;

      x_return_status   := l_validation_status;
      RETURN;
    END IF; -- bug 4636208 ends

    IF nvl(l_model_line_rec.booked_flag, 'N' ) = 'Y' THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORDER IS BOOKED' , 1 ) ;
      END IF;

      OE_Config_Pvt.put_hold_and_release_hold
      (p_header_id       => p_header_id,
       p_line_id         => p_top_model_line_id,
       p_valid_config    => l_valid_config,
       p_complete_config => l_complete_config,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       x_return_status   => l_return_status);

       Handle_Ret_Status(p_return_status => l_return_status);
    END IF;

  ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NO OPTIONS TO VALIDATE' , 1 ) ;
    END IF;
  END IF;


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CALLING HANDLE_DML' , 1 ) ;
  END IF;

  Handle_DML
  ( p_options_tbl           => l_options_tbl
   ,p_model_line_rec        => l_model_line_rec
   ,p_ui_flag               => p_ui_flag
   ,x_return_status         => l_return_status );

  Handle_Ret_Status(p_return_status => l_return_status);

   oe_msg_pub.count_and_get
   (   p_count                       => x_msg_count
   ,   p_data                        => x_msg_data );

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'NO. OF MESSAGES ' || X_MSG_COUNT , 3 ) ;
     oe_debug_pub.add(  'MESSAGES ' || X_MSG_DATA , 3 ) ;
   END IF;

  Print_Time('Process_Config_Options end time');


  -- from the options window, we want to give user a choice to
  -- save or not to save. from sales order form, we save
  -- (unless there is an unexpected error). And
  -- populate messages, user can go and correct the
  -- configuratio based on the messages.

  IF p_ui_flag = 'Y' THEN
    x_return_status := l_validation_status;
  ELSE
    x_return_status := l_return_status;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING PROCESS_CONFIG_OPTIONS'||X_RETURN_STATUS,5);
  END IF;

EXCEPTION

  -- IMP please read procedure description.

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN PROCESS_CONFIG_OPTIONS'|| SQLERRM ,1);
    END IF;

    IF p_ui_flag = 'Y' THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NO. OF MESSAGES ' || X_MSG_COUNT , 3 ) ;
      oe_debug_pub.add(  'MESSAGES ' || X_MSG_DATA , 3 ) ;
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN PROCESS_CONFIG_OPTIONS'|| SQLERRM ,1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NO. OF MESSAGES ' || X_MSG_COUNT , 3 ) ;
      oe_debug_pub.add(  'MESSAGES ' || X_MSG_DATA , 3 ) ;
    END IF;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN PROCESS_CONFIG_OPTIONS'|| SQLERRM ,1);
      oe_debug_pub.add(  'ERROR: ' || SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
    END IF;

    IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
      oe_msg_pub.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Process_Config');
    END IF;

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data );

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NO. OF MESSAGES ' || X_MSG_COUNT , 3 ) ;
      oe_debug_pub.add(  'MESSAGES ' || X_MSG_DATA , 3 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Process_Config_Options;


/*--------------------------------------------------------
PROCEDURE : Prepare_Cascade_Tables

used to prepare i/p tables for cascade_update_deletes API.
handles diabled options also.
3563690 => pass ordered_item in param10
----------------------------------------------------------*/
PROCEDURE Prepare_Cascade_Tables
( p_options_tbl           IN OUT NOCOPY
                          OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_top_model_line_id     IN NUMBER
 ,p_x_updated_options_tbl IN OUT NOCOPY OE_Order_PUB.request_tbl_type
 ,p_x_deleted_options_tbl IN OUT NOCOPY OE_Order_PUB.request_tbl_type)
IS
  l_count               NUMBER;
  I                     NUMBER;
  l_index               NUMBER;
  l_req_rec             OE_Order_Pub.Request_Rec_Type;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering Prepare_Cascade_Tables', 3 );
  END IF;

  l_count := p_x_updated_options_tbl.COUNT;
  l_index := p_x_deleted_options_tbl.COUNT;

  I := p_options_tbl.FIRST;
  WHILE I is not null
  LOOP

    IF p_options_tbl(I).disabled_flag = 'Y' THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('disabled: '||p_options_tbl(I).component_code,1);
      END IF;

      Handle_Disabled_Options
      ( p_x_option_rec      => p_options_tbl(I)
       ,p_top_model_line_id => p_top_model_line_id);
    END IF;

    IF p_options_tbl(I).operation = OE_GLOBALS.G_OPR_UPDATE
    THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('GET OLD QTY FOR '|| p_OPTIONS_TBL(I).LINE_ID,1);
      END IF;

      SELECT ordered_quantity
      INTO   p_options_tbl(I).old_ordered_quantity
      FROM   oe_order_lines
      WHERE  line_id = p_options_tbl(I).line_id;

      l_count          := l_count + 1;
      l_req_rec.param1 := p_top_model_line_id;
      l_req_rec.param2 := p_options_tbl(I).component_code;
      l_req_rec.param5 := p_options_tbl(I).ordered_quantity;
      l_req_rec.param4 := p_options_tbl(I).old_ordered_quantity;
      l_req_rec.param6 := p_options_tbl(I).change_reason;
      l_req_rec.param7 := p_options_tbl(I).change_comments;

      IF p_options_tbl(I).bom_item_type = 1 THEN
        l_req_rec.param3 := OE_GLOBALS.G_ITEM_MODEL;
      ELSIF p_options_tbl(I).bom_item_type = 2 THEN
        l_req_rec.param3 := OE_GLOBALS.G_ITEM_CLASS;
      ELSE
        l_req_rec.param3 := OE_GLOBALS.G_ITEM_OPTION;
      END IF;

      IF p_options_tbl(I).disabled_flag = 'Y' THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('disabled hence setting param8', 4);
        END IF;
        l_req_rec.param8 := 'Y';
      ELSE
        -- setting cancellation flag to No for now, since user can not
        -- give reason anyway and it will fail. Can I figure out the flag??
        -- yes doing it 11/25/2003
        l_req_rec.param8 := 'N';
      END IF;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add
          ('UPDATE: '||L_REQ_REC.PARAM2||' '
            ||L_REQ_REC.PARAM3||L_REQ_REC.PARAM5,1);
        END IF;
      -- 3563690
      l_req_rec.param10 := p_options_tbl(I).ordered_item ;

      p_x_updated_options_tbl(l_count) := l_req_rec;

    ELSIF p_options_tbl(I).operation = OE_GLOBALS.G_OPR_DELETE
    THEN
      l_index          := l_index + 1;
      l_req_rec.param1 := p_top_model_line_id;
      l_req_rec.param2 := p_options_tbl(I).component_code;

      IF p_options_tbl(I).bom_item_type = 1 THEN
        l_req_rec.param3 := OE_GLOBALS.G_ITEM_MODEL;
      ELSIF p_options_tbl(I).bom_item_type = 2 THEN
        l_req_rec.param3 := OE_GLOBALS.G_ITEM_CLASS;
      ELSE
        l_req_rec.param3 := OE_GLOBALS.G_ITEM_OPTION;
      END IF;
      -- 3563690
      l_req_rec.param10 := p_options_tbl(I).ordered_item ;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DELETE: '|| L_REQ_REC.PARAM2 || ' '
                           || L_REQ_REC.PARAM3 , 1 ) ;
      END IF;
      p_x_deleted_options_tbl(l_index) := l_req_rec;

    END IF;

    I := p_options_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('leaving Prepare_Cascade_Tables', 3 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN Prepare_Cascade_Tables '|| SQLERRM ,1);
    END IF;
    RAISE;
END Prepare_Cascade_Tables;


/*-----------------------------------------------------------
FUNCTION: Find_Matching_Comp_Index
Used to remove duplicates from the options table.
----------------------------------------------------------*/
FUNCTION Find_Matching_Comp_Index
( p_options_tbl  IN OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_comp_code    IN VARCHAR2)
RETURN NUMBER
IS
  I   NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING IND_MATCHING_COMP_INDEX'|| P_COMP_CODE , 1 ) ;
  END IF;

  I := p_options_tbl.FIRST;
  WHILE I is not NULL
  LOOP

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  P_OPTIONS_TBL ( I ) .COMPONENT_CODE
                         || P_OPTIONS_TBL ( I ) .OPERATION , 1 ) ;
    END IF;

    IF p_options_tbl(I).component_code = p_comp_code AND
       p_options_tbl(I).operation <> OE_GLOBALS.G_OPR_INSERT
    THEN
      RETURN I;
    END IF;


    I := p_options_tbl.NEXT(I);
  END LOOP;

  RAISE FND_API.G_EXC_ERROR;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN FIND_MATCHING_COMP_INDEX'|| SQLERRM ,1);
    END IF;
    RAISE;
END Find_Matching_Comp_Index;

/*-----------------------------------------------------------
Procedure: Handle_DML
Currently the option window supports only create operation.
For any updates/deletes user will use sales order form.

To aid performance, in this procedure we first default one option
and use the defaulted record as the base record for all other
options that need to be created. This saves us from defaulting
all n options for 300 or so attributes in oe_order_lines.
We set the item dependent attributes (once that are set dependent
on inventory_item_id in OEXUDEPB.pls) as missing on all the
options so that they will get defaulted individually. Please
note that any future additions to OEXUDEPB.pls should be
added in this API also.

We call process_order and then the change columns procedure
which sets the configuration related links(link to line id etc)
on all the options.

Change Record:
  bug fix 1894020,2184255 to support dff.
  the operation on disabled options should always be none.

  bug fix 3095496, change reason for updates and a call to
  Is_Cancel_Or_Delete for Delete operation.

   Bug 3611416
   Send reason for CREATE operation also, will be required if there is
   a require reason constraint for versioning during create operation.
------------------------------------------------------------*/
Procedure Handle_DML
( p_options_tbl           IN  OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_model_line_rec        IN  OUT NOCOPY OE_Order_Pub.Line_Rec_Type
 ,p_ui_flag               IN  VARCHAR2
 ,x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  -- process_order in params
  l_control_rec               OE_GLOBALS.Control_Rec_Type;
  l_line_rec                  OE_ORDER_PUB.Line_Rec_Type;
  l_line_upd_rec              OE_ORDER_PUB.Line_Rec_Type;
  l_line_del_rec              OE_ORDER_PUB.Line_Rec_Type;
  l_old_line_rec              OE_ORDER_PUB.Line_Rec_Type;
  l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
  l_model_qty                 NUMBER;
  l_return_status             VARCHAR2(1):=  FND_API.G_RET_STS_SUCCESS;
  I                           NUMBER;
  l_line_count                NUMBER;
  l_class_line_rec            OE_ORDER_PUB.Line_Rec_Type;
  l_class_line_count          NUMBER;
  l_class_line_tbl            OE_Order_PUB.Line_Tbl_Type;

  l_direct_save               BOOLEAN;
  l_profile_value             VARCHAR2(1) :=
                        upper(FND_PROFILE.VALUE('ONT_CONFIG_QUICK_SAVE'));
  l_cancellation              BOOLEAN;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  Print_Time('Entering Handle_DML');

  IF p_model_line_rec.booked_flag = 'N' and l_profile_value = 'Y' AND
     p_ui_flag = 'Y' THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'DIRECT SAVE ON' , 1 ) ;
    END IF;
    l_direct_save := TRUE;
  ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'DIRECT SAVE OFF' || L_PROFILE_VALUE , 1 ) ;
    END IF;
    l_direct_save := FALSE;
  END IF;


  --------------- prepare class line rec ----------------------------

  IF l_direct_save THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'DIRECT SAVE IS ON' , 3 ) ;
    END IF;

    OE_Config_Util.Default_Child_Line
    ( p_parent_line_rec  => p_model_line_rec
     ,p_x_child_line_rec => l_class_line_rec
     ,p_direct_save      => l_direct_save
     ,x_return_status    => l_return_status);

  END IF; -- end if direct save

  ----------------- class line rec done --------------------------


  l_line_count                      := 0;
  l_class_line_count                := 0;

  l_line_rec                        := OE_Order_PUB.G_MISS_LINE_REC;
  l_line_upd_rec                    := l_line_rec;
  l_line_del_rec                    := l_line_rec;

  l_line_rec.operation              := OE_GLOBALS.G_OPR_CREATE;
  l_line_upd_rec.operation          := OE_GLOBALS.G_OPR_UPDATE;
  l_line_del_rec.operation          := OE_GLOBALS.G_OPR_DELETE;

  l_line_rec.header_id              := p_model_line_rec.header_id;
  l_line_rec.top_model_line_id      := p_model_line_rec.line_id;
  l_line_rec.item_identifier_type   := 'INT';


  I := p_options_tbl.FIRST;
  WHILE I is not null
  LOOP
    -- note that the operation should be INSERT and not create. CREATE is
    -- used while calling SPC batch validation, not for process_order call.

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(I|| ' OPEARION: '||P_OPTIONS_TBL(I).OPERATION ,1);
    END IF;

    IF p_options_tbl(I).operation = OE_GLOBALS.G_OPR_INSERT
    THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('INSERT: '|| P_OPTIONS_TBL(I).COMPONENT_CODE ,1);
      END IF;

      IF l_direct_save AND p_options_tbl(I).bom_item_type = 2
      THEN
        l_class_line_rec.ordered_quantity
                           := p_options_tbl(I).ordered_quantity;
        l_class_line_rec.order_quantity_uom
                           := p_options_tbl(I).order_quantity_uom;
        l_class_line_rec.component_sequence_id
                           := p_options_tbl(I).component_sequence_id;
        l_class_line_rec.component_code := p_options_tbl(I).component_code;
        l_class_line_rec.sort_order     := p_options_tbl(I).sort_order;
        l_class_line_rec.inventory_item_id
                           := p_options_tbl(I).inventory_item_id;
        l_class_line_rec.ordered_item   := p_options_tbl(I).ordered_item;

        l_class_line_rec.attribute1     := p_options_tbl(I).attribute1;
        l_class_line_rec.attribute2     := p_options_tbl(I).attribute2;
        l_class_line_rec.attribute3     := p_options_tbl(I).attribute3;
        l_class_line_rec.attribute4     := p_options_tbl(I).attribute4;
        l_class_line_rec.attribute5     := p_options_tbl(I).attribute5;
        l_class_line_rec.attribute6     := p_options_tbl(I).attribute6;
        l_class_line_rec.attribute7     := p_options_tbl(I).attribute7;
        l_class_line_rec.attribute8     := p_options_tbl(I).attribute8;
        l_class_line_rec.attribute9     := p_options_tbl(I).attribute9;
        l_class_line_rec.attribute10    := p_options_tbl(I).attribute10;
        l_class_line_rec.attribute11    := p_options_tbl(I).attribute11;
        l_class_line_rec.attribute12    := p_options_tbl(I).attribute12;
        l_class_line_rec.attribute13    := p_options_tbl(I).attribute13;
        l_class_line_rec.attribute14    := p_options_tbl(I).attribute14;
        l_class_line_rec.attribute15    := p_options_tbl(I).attribute15;
        l_class_line_rec.attribute16    := p_options_tbl(I).attribute16;
        l_class_line_rec.attribute17    := p_options_tbl(I).attribute17;
        l_class_line_rec.attribute18    := p_options_tbl(I).attribute18;
        l_class_line_rec.attribute19    := p_options_tbl(I).attribute19;
        l_class_line_rec.attribute20    := p_options_tbl(I).attribute20;
        l_class_line_rec.context        := p_options_tbl(I).context;

        SELECT  OE_ORDER_LINES_S.NEXTVAL
        INTO    l_class_line_rec.line_id
        FROM    DUAL;

        l_class_line_rec.pricing_quantity_uom
                                := l_class_line_rec.order_quantity_uom;
        l_class_line_rec.pricing_quantity
                                := l_class_line_rec.ordered_quantity;

        l_class_line_count                  := l_class_line_count+1;
        l_class_line_tbl(l_class_line_count):= l_class_line_rec;

      ELSE

        l_line_rec.ordered_quantity  := p_options_tbl(I).ordered_quantity;
        l_line_rec.order_quantity_uom
                           := p_options_tbl(I).order_quantity_uom;
        l_line_rec.component_sequence_id
                           := p_options_tbl(I).component_sequence_id;
        l_line_rec.component_code    := p_options_tbl(I).component_code;
        l_line_rec.sort_order        := p_options_tbl(I).sort_order;
        l_line_rec.inventory_item_id := p_options_tbl(I).inventory_item_id;
        l_line_rec.ordered_item      := p_options_tbl(I).ordered_item;

        l_line_rec.attribute1        := p_options_tbl(I).attribute1;
        l_line_rec.attribute2        := p_options_tbl(I).attribute2;
        l_line_rec.attribute3        := p_options_tbl(I).attribute3;
        l_line_rec.attribute4        := p_options_tbl(I).attribute4;
        l_line_rec.attribute5        := p_options_tbl(I).attribute5;
        l_line_rec.attribute6        := p_options_tbl(I).attribute6;
        l_line_rec.attribute7        := p_options_tbl(I).attribute7;
        l_line_rec.attribute8        := p_options_tbl(I).attribute8;
        l_line_rec.attribute9        := p_options_tbl(I).attribute9;
        l_line_rec.attribute10       := p_options_tbl(I).attribute10;
        l_line_rec.attribute11       := p_options_tbl(I).attribute11;
        l_line_rec.attribute12       := p_options_tbl(I).attribute12;
        l_line_rec.attribute13       := p_options_tbl(I).attribute13;
        l_line_rec.attribute14       := p_options_tbl(I).attribute14;
        l_line_rec.attribute15       := p_options_tbl(I).attribute15;
        l_line_rec.attribute16       := p_options_tbl(I).attribute16;
        l_line_rec.attribute17       := p_options_tbl(I).attribute17;
        l_line_rec.attribute18       := p_options_tbl(I).attribute18;
        l_line_rec.attribute19       := p_options_tbl(I).attribute19;
        l_line_rec.attribute20       := p_options_tbl(I).attribute20;
        l_line_rec.context           := p_options_tbl(I).context;
        l_line_rec.change_reason     := 'SYSTEM';

        IF p_options_tbl(I).bom_item_type = 2 THEN
          l_line_rec.item_type_code := OE_GLOBALS.G_ITEM_CLASS;
        ELSE
          l_line_rec.item_type_code := null;
        END IF;

        l_line_count                 := l_line_count + 1;
        l_line_tbl(l_line_count)     := l_line_rec;

      END IF;

    ELSIF p_options_tbl(I).operation = OE_GLOBALS.G_OPR_UPDATE THEN

      l_line_upd_rec.line_id          := p_options_tbl(I).line_id;
      l_line_upd_rec.component_code   := p_options_tbl(I).component_code;
      l_line_upd_rec.ordered_quantity := p_options_tbl(I).ordered_quantity;
      l_line_upd_rec.change_reason    := p_options_tbl(I).change_reason;
      l_line_upd_rec.change_comments  := p_options_tbl(I).change_comments;

      l_line_upd_rec.attribute1       := p_options_tbl(I).attribute1;
      l_line_upd_rec.attribute2       := p_options_tbl(I).attribute2;
      l_line_upd_rec.attribute3       := p_options_tbl(I).attribute3;
      l_line_upd_rec.attribute4       := p_options_tbl(I).attribute4;
      l_line_upd_rec.attribute5       := p_options_tbl(I).attribute5;
      l_line_upd_rec.attribute6       := p_options_tbl(I).attribute6;
      l_line_upd_rec.attribute7       := p_options_tbl(I).attribute7;
      l_line_upd_rec.attribute8       := p_options_tbl(I).attribute8;
      l_line_upd_rec.attribute9       := p_options_tbl(I).attribute9;
      l_line_upd_rec.attribute10      := p_options_tbl(I).attribute10;
      l_line_upd_rec.attribute11      := p_options_tbl(I).attribute11;
      l_line_upd_rec.attribute12      := p_options_tbl(I).attribute12;
      l_line_upd_rec.attribute13      := p_options_tbl(I).attribute13;
      l_line_upd_rec.attribute14      := p_options_tbl(I).attribute14;
      l_line_upd_rec.attribute15      := p_options_tbl(I).attribute15;
      l_line_upd_rec.attribute16      := p_options_tbl(I).attribute16;
      l_line_upd_rec.attribute17      := p_options_tbl(I).attribute17;
      l_line_upd_rec.attribute18      := p_options_tbl(I).attribute18;
      l_line_upd_rec.attribute19      := p_options_tbl(I).attribute19;
      l_line_upd_rec.attribute20      := p_options_tbl(I).attribute20;
      l_line_upd_rec.context          := p_options_tbl(I).context;

      IF p_ui_flag = 'Y' THEN
        l_line_upd_rec.change_reason  := 'CONFIGURATOR';
        l_line_upd_rec.change_comments:=  'Changes in Options Window';
      END IF;

      l_line_count                    := l_line_count + 1;
      l_line_tbl(l_line_count)        := l_line_upd_rec;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('UPDATE LINE_ID: '|| P_OPTIONS_TBL(I).LINE_ID ,1);
      END IF;

    ELSIF p_options_tbl(I).operation = OE_GLOBALS.G_OPR_DELETE THEN

      l_line_del_rec.line_id        := p_options_tbl(I).line_id;
      l_line_del_rec.component_code := p_options_tbl(I).component_code;
      l_line_count                  := l_line_count + 1;

      IF p_ui_flag = 'Y' AND
         p_options_tbl(I).disabled_flag = 'N' THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('calling Is_Cancel_OR_Delete '
          || l_line_del_rec.line_id, 3);
        END IF;

        OE_Config_Pvt.Is_Cancel_OR_Delete
        ( p_line_id           => l_line_del_rec.line_id
         ,p_change_reason     => 'CONFIGURATOR'
         ,p_change_comments   => 'Changes in Options Window'
         ,x_cancellation      => l_cancellation
         ,x_line_rec          => l_line_del_rec);

        oe_debug_pub.add('operation '|| l_line_del_rec.operation, 1);
      END IF;

      l_line_tbl(l_line_count)  := l_line_del_rec;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('DELETE LINE_ID: '|| P_OPTIONS_TBL(I).LINE_ID , 1);
      END IF;

    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('NO ACTION OPERATION '|| p_options_tbl(I).disabled_flag, 1 ) ;
      END IF;

    END IF; -- operation = create

    I := p_options_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add
    (  'OUT OF LOOP '|| L_LINE_COUNT || ' ' || L_CLASS_LINE_COUNT , 1 ) ;
  END IF;


  --even if line_count = 0,  we need to call, for change columns.

  IF p_ui_flag = 'Y' THEN
    l_control_rec.process              := TRUE;
  ELSE
    l_control_rec.process              := FALSE;
  END IF;

  oe_config_pvt.Call_Process_Order
  (  p_line_tbl          => l_line_tbl
    ,p_class_line_tbl    => l_class_line_tbl
    ,p_control_rec       => l_control_rec
    ,p_ui_flag           => p_ui_flag
    ,p_top_model_line_id => p_model_line_rec.top_model_line_id
    ,p_update_columns    => TRUE
    ,x_return_status     => l_return_status);

  x_return_status       := l_return_status;

  Print_Time('Leaving Handle_DML '|| x_return_status);

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN HANDLE_DML: '|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Handle_DML;


/*----------------------------------------------------------------------
PROCEDURE: Handle_Disabled_Options

sets correct operation on disabled child line so that
system can eihter delete or cancel them also populates
message back to user to indicate the same.
-----------------------------------------------------------------------*/
PROCEDURE Handle_Disabled_Options
( p_x_option_rec IN OUT NOCOPY OE_Process_Options_Pvt.SELECTED_OPTIONS_REC
 ,p_top_model_line_id  IN  NUMBER)
IS
  l_line_rec            OE_ORDER_PUB.Line_Rec_Type;
  l_old_line_rec        OE_ORDER_PUB.Line_Rec_Type;
  I                     NUMBER;
  l_sec_result          NUMBER;
  l_return_status       VARCHAR2(1);
  l_line_count          NUMBER;
  l_dummy               VARCHAR2(30);
  l_cancellation        BOOLEAN;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  FND_MESSAGE.Set_Name('ONT', 'ONT_CONFIG_DISABLED_OPTION');
  FND_MESSAGE.Set_Token('OPTION', nvl(p_x_option_rec.ordered_item,
                        p_x_option_rec.inventory_item_id));

  SELECT ordered_item
  INTO   l_dummy
  FROM   oe_order_lines
  WHERE  line_id = p_top_model_line_id;

  FND_MESSAGE.Set_Token('MODEL', nvl(l_dummy, '-'));

  SELECT line_number || '.' || shipment_number || '.' ||
         option_number || '.' || component_number || '.' ||
         service_number
  INTO   l_dummy
  FROM   oe_order_lines
  WHERE  line_id = p_x_option_rec.line_id;

  FND_MESSAGE.Set_Token('LINE_NUM', RTRIM(l_dummy, '.'));
  OE_Msg_Pub.Add;

  OE_Config_Pvt.Is_Cancel_OR_Delete
  ( p_line_id          => p_x_option_rec.line_id
   ,p_change_reason    => 'SYSTEM'
   ,p_change_comments  => 'DISABLED'
   ,x_cancellation     => l_cancellation
   ,x_line_rec         => l_line_rec);

  IF l_cancellation THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('do cancellation hence update with 0', 3 );
    END IF;

    p_x_option_rec.ordered_quantity     := 0;
    p_x_option_rec.operation            := OE_GLOBALS.G_OPR_UPDATE;

    p_x_option_rec.change_reason        := 'SYSTEM';
    p_x_option_rec.change_comments      := 'DISABLED';

  ELSE
    p_x_option_rec.operation            := OE_GLOBALS.G_OPR_DELETE;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('no cancellation, delete ok ', 3 ) ;
    END IF;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('option operation '|| p_x_option_rec.operation, 3);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION Handle_Disabled_Options: '||SQLERRM,1);
    END IF;
    RAISE;
END Handle_Disabled_Options;

/*-----------------------------------------------------------------------
PROCEDURE: Fill_In_Classes
 put every item in p_x_options_tbl in a pl/sql table A
 also put all options in databse in table A.
 see if the striped compo code is already present in the new table
 if not add.
 p_x_options_tbl  is the table is of lines we want to create.
 operation of INSERT indicates that the record is to created in DB.
 operation of CREATE means the record is created however the
 transaction is yet not commited(mainly in case of delyed requests).
------------------------------------------------------------------------*/

Procedure Fill_In_Classes
( p_top_model_line_id        IN NUMBER
 ,p_model_component          IN VARCHAR2
 ,p_model_quantity           IN NUMBER
 ,p_top_bill_sequence_id     IN NUMBER
 ,p_effective_date           IN DATE
 ,p_ui_flag                  IN VARCHAR2
 ,p_x_options_tbl IN OUT NOCOPY OE_Process_Options_Pvt.SELECTED_OPTIONS_TBL_TYPE
 ,x_return_status            OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  I                          NUMBER;
  J                          NUMBER;
  l_count                    NUMBER;
  l_options_tbl_index        NUMBER;
  l_index_before_fill        NUMBER;
  l_in_count                 NUMBER;
  l_component                VARCHAR2(2000);
  l_orig_component           VARCHAR2(2000);
  l_result                   BOOLEAN;
  l_validation_org           NUMBER;
  l_last                     NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  Print_Time('Entering Fill_In_Classes start time');

  l_in_count := p_x_options_tbl.COUNT;

  -- we will use l_options_tbl_count for p_x_options_tbl because
  -- there can be gaps in the tbl, can not use l_count, bug fix.

  l_options_tbl_index  := p_x_options_tbl.LAST;
  l_index_before_fill  := l_options_tbl_index; -- used later

  I := p_x_options_tbl.FIRST;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'I: '|| I , 1 ) ;
  END IF;

  WHILE I is not null
  LOOP
    IF nvl(p_x_options_tbl(I).operation, OE_GLOBALS.G_OPR_NONE)
                       = OE_GLOBALS.G_OPR_INSERT  OR
       nvl(p_x_options_tbl(I).operation, OE_GLOBALS.G_OPR_NONE)
                       = OE_GLOBALS.G_OPR_CREATE
    THEN
      J                := 2;
      l_orig_component := p_x_options_tbl(I).component_code;
      l_component      :=
        SUBSTR(l_orig_component, 1, (INSTR(l_orig_component, '-', 1, J) -1));


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  I || 'HERE COMPONENT: '|| L_COMPONENT , 1 ) ;
      END IF;

      WHILE l_component is NOT NULL
      LOOP

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INNER LOOP COMPONENT: '|| L_COMPONENT , 1 ) ;
        END IF;
        component_exists
        ( p_component             => l_component
         ,p_options_tbl           => p_x_options_tbl
         ,x_result                => l_result);

        IF NOT (l_result) THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add( 'COMOPNENT NOT THERE , SO ADD '||L_COMPONENT,1);
          END IF;
          l_count             := l_count + 1;
          l_options_tbl_index := l_options_tbl_index + 1;
          p_x_options_tbl(l_options_tbl_index).component_code := l_component;
          p_x_options_tbl(l_options_tbl_index).operation := OE_GLOBALS.G_OPR_INSERT;
        ELSE
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'COMPONENT ALREADY PRESENT' , 1 ) ;
          END IF;
        END IF;

        J           := J + 1;
        l_component :=
         SUBSTR(l_orig_component, 1, (INSTR(l_orig_component, '-', 1, J) -1));
      END LOOP;
    END IF;
    I := p_x_options_tbl.NEXT(I);
  END LOOP;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COUNT IN OPTIONS TABLE: '|| P_X_OPTIONS_TBL.COUNT,1);
      oe_debug_pub.add(  'COUNT SENT IN: '|| L_IN_COUNT , 1 ) ;
    END IF;

  IF p_x_options_tbl.count = l_in_count THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NOTHING TO FILL' , 1 ) ;
    END IF;
    RETURN;
  END IF;

  l_validation_org :=  OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID');

  I := l_index_before_fill + 1;
  WHILE I is not null
  LOOP

    l_component := p_x_options_tbl(I).component_code;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add
      (  'COMP COMPLETING: '|| L_COMPONENT ||' ' || L_VALIDATION_ORG , 1 ) ;
    END IF;

    SELECT component_sequence_id, component_item_id, sort_order,
           primary_uom_code, EXTENDED_QUANTITY * p_model_quantity,
           DECODE(bom_item_type, 1, 2, 2, 2, 4, 4)
    INTO  p_x_options_tbl(I).component_sequence_id,
          p_x_options_tbl(I).inventory_item_id,
          p_x_options_tbl(I).sort_order,
          p_x_options_tbl(I).order_quantity_uom,
          p_x_options_tbl(I).ordered_quantity,
          p_x_options_tbl(I).bom_item_type
    FROM  bom_explosions be
    WHERE be.explosion_type  = OE_Config_Util.OE_BMX_OPTION_COMPS
    AND   be.top_bill_sequence_id = p_top_bill_sequence_id
    AND   be.plan_level > 0
    AND   be.effectivity_date <= p_effective_date
    AND   be.disable_date > p_effective_date
    AND   be.component_code = p_x_options_tbl(I).component_code
    AND   rownum = 1;

    BEGIN
      SELECT concatenated_segments
      INTO   p_x_options_tbl(I).ordered_item
      FROM   MTL_SYSTEM_ITEMS_KFV
      WHERE  inventory_item_id = p_x_options_tbl(I).inventory_item_id
      AND    organization_id = l_validation_org;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE FND_API.G_EXC_ERROR;
    END;

    I := p_x_options_tbl.NEXT(I);
  END LOOP;

  Print_Time('Fill_In_Classes end time');

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN FILL_IN_CLASSES' || SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Fill_In_Classes;


/*-----------------------------------------------------------------------
PROCEDURE: component_exists
This procedure loops through the options table and finds out if the item
with component_code =  p_component exist in the p_options_table.
If the operation on the matching component record is DELETE, this function
will return a value of false.
------------------------------------------------------------------------*/

PROCEDURE component_exists
( p_component             IN  VARCHAR2
 ,p_options_tbl           IN OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,x_result                OUT NOCOPY /* file.sql.39 change */ BOOLEAN)
IS
  I  NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  I := p_options_tbl.FIRST;

  WHILE I is not null
  LOOP
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(I || ' COMPARING TO COMPONENT: '
                       || P_OPTIONS_TBL ( I ) .COMPONENT_CODE , 1 ) ;
    END IF;

    IF p_options_tbl(I).component_code = p_component AND
       nvl(p_options_tbl(I).operation, OE_GLOBALS.G_OPR_NONE) <>
       OE_GLOBALS.G_OPR_DELETE THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COMPONENT FOUND' , 1 ) ;
      END IF;
      x_result := true;
      RETURN;
    END IF;

    I := p_options_tbl.NEXT(I);
  END LOOP;

  x_result := false;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LEAVING COMPONENT_NOT_EXIST' , 1 ) ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN COMPONENT_NOT_EXIST' || SQLERRM , 1 ) ;
    END IF;
    RAISE;
END component_exists;


/*---------------------------------------------------------------------------
PROCEDURE: Check_Duplicate_Components
This procedure makes sure that every component in the configuration
appears only once.
-------------------------------------------------------------------------*/
PROCEDURE Check_Duplicate_Components
( p_options_tbl           IN  OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
  l_outer_index     NUMBER;
  l_inner_index     NUMBER;
  l_return_status   VARCHAR2(1):=  FND_API.G_RET_STS_SUCCESS;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING CHECK_DUPLICATE_COMPONENTS' , 1 ) ;
    oe_debug_pub.add(  'COUNT: '|| P_OPTIONS_TBL.COUNT , 1 ) ;
  END IF;

  l_outer_index := p_options_tbl.FIRST;
  WHILE l_outer_index is not NULL
  LOOP

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(p_OPTIONS_TBL(l_outer_index).operation
                       || p_OPTIONS_TBL(l_outer_index).component_code,3);
    END IF;

    IF p_options_tbl(l_outer_index).operation =
       OE_GLOBALS.G_OPR_CREATE OR
       p_options_tbl(l_outer_index).operation =
       OE_GLOBALS.G_OPR_INSERT
    THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  L_OUTER_INDEX || ' CHECK DUPL: '
                      ||P_OPTIONS_TBL ( L_OUTER_INDEX ) .COMPONENT_CODE , 1 ) ;
        oe_debug_pub.add(  'SORT ORDER: '
                      || P_OPTIONS_TBL ( L_OUTER_INDEX ) .SORT_ORDER , 1 ) ;
      END IF;

      l_inner_index := p_options_tbl.FIRST;

      WHILE l_inner_index is not NULL
      LOOP

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(L_INNER_INDEX
          || P_OPTIONS_TBL ( L_INNER_INDEX ) .COMPONENT_CODE , 1 ) ;
        END IF;

        IF l_inner_index <> l_outer_index  THEN
          IF p_options_tbl(l_inner_index).component_code =
             p_options_tbl(l_outer_index).component_code
          THEN

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'DUPLICATE EXIST' , 1 ) ;
            END IF;

            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_DUPLICATE_COMPONENT');
            FND_MESSAGE.Set_Token
            ('ITEM', p_options_tbl(l_outer_index).ordered_item);
            OE_Msg_Pub.Add;
          END IF;
        END IF;
        l_inner_index := p_options_tbl.NEXT(l_inner_index);
      END LOOP;
    END IF;
    l_outer_index := p_options_tbl.NEXT(l_outer_index);
  END LOOP;

  x_return_status := l_return_status;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LEAVING CHECK_DUPLICATE_COMPONENTS' , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN CHECK_DUPLICATE_OPTIONS'|| SQLERRM,1);
    END IF;
    RAISE;
END Check_Duplicate_Components;


/*---------------------------------------------------------------------------
FUNCTION: Use_Configurator

This Function returns true if,
1) configurator is Installed
2) the profile options ONT_USE_CONFIGURATOR is set to 'YES'
Else it returns false.

If the function returns false OM will open options window
to enter options for a model.
Also it will use BOM based validation for configuration validation
1) for order import
2) any modification to configuration through UI.

If the function returns true, Product configurator will be used
to enter options and for batch validation.

Change Record:
bug 1701377 : to use globals for installation statuses.

bug 1922990: For existing customers who were using configurator
but did not have the prodcut configurator installed,
we will use the profile_option BOM: Configurator url.
If the configurator is not installed but this profile
option is set, we will allow customers to use configurator.

----------------------------------------------------------------------------*/
FUNCTION Use_Configurator
RETURN BOOLEAN
IS
l_status                   VARCHAR2(1)  := NULL;
l_result                   BOOLEAN;
l_industry                 VARCHAR2(30) := NULL;
l_configurator_product_id  NUMBER       := 708;
l_profile_value            VARCHAR2(240);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING USE_CONFIGURATOR' , 1 ) ;
  END IF;

  IF OE_GLOBALS.G_CONFIGURATOR_INSTALLED IS NULL THEN
    OE_GLOBALS.G_CONFIGURATOR_INSTALLED
         := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(l_configurator_product_id);
  END IF;

  l_profile_value := upper(FND_PROFILE.VALUE('ONT_USE_CONFIGURATOR'));

  IF nvl(l_profile_value, 'Y') = 'Y' THEN
    IF OE_GLOBALS.G_CONFIGURATOR_INSTALLED = 'Y' THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CONFIGURATOR IS INSTALLED PROFILE SET TO YES',1);
      END IF;
      RETURN true;
    ELSE
      l_profile_value := FND_PROFILE.VALUE('CZ_UIMGR_URL');

      IF l_profile_value is NULL THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'URL VALUE IS NULL , USE OPTIONS WINDOW' , 1 ) ;
        END IF;

        RETURN false;
      ELSE

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'URL PROFILE VALUE '|| L_PROFILE_VALUE , 1 ) ;
        END IF;

        RETURN true;
      END IF;
    END IF;
  ELSE -- use_configurator profile is set to 'N'
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'USE OPTIONS WINDOW' , 1 ) ;
    END IF;
    RETURN false;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LEAVING USE_CONFIGURATOR' , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'USE_CONFIGURATOR EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RETURN false;
END Use_Configurator;


/*------------------------------------------------------------------------
PROCEDURE: Get_Options_From_DB
only new options in case of cz and all options in case bom
based validation.
This procedure does not return closed lines on purpose.
The bom based validation is smart enough to see
if the ordered quantity is 0 and not to the check.

Change Record:
added additional flex attributes for bug 2184255.

added 2 new parameters,
 p_caller : CONFIGURATOR OR OPTIONS WINDOW
 p_query_criteria : 1 - all, disabled flag not set
                    2 - enabled only,
                    3 - diabled only
                    4 - all with disabled flag set
-------------------------------------------------------------------------*/

PROCEDURE Get_Options_From_DB
( p_top_model_line_id IN  NUMBER
 ,p_get_model_line    IN  BOOLEAN := FALSE
 ,p_caller            IN  VARCHAR2:= ''
 ,p_query_criteria    IN  NUMBER  := 1
 ,x_disabled_options  OUT NOCOPY VARCHAR2
 ,x_options_tbl       OUT NOCOPY
  OE_Process_Options_Pvt.SELECTED_OPTIONS_TBL_TYPE)
IS
  CURSOR  Get_Options
  IS
  SELECT component_code , ordered_quantity, inventory_item_id,
         component_sequence_id, sort_order, order_quantity_uom,
         DECODE(item_type_code, 'MODEL', 1, 'CLASS', 2, 4) bom_item_type,
         ordered_item, configuration_id, config_header_id, line_id,
         attribute1, attribute2, attribute3, attribute4, attribute5,
         attribute6, attribute7, attribute8, attribute9, attribute10,
         attribute11, attribute12, attribute13, attribute14, attribute15,
         attribute16, attribute17, attribute18, attribute19, attribute20,
         context
  FROM   oe_order_lines
  WHERE  top_model_line_id = p_top_model_line_id
  AND    open_flag = 'Y'
  AND    nvl(config_header_id, -1) = -1
  AND    (item_type_code = OE_GLOBALS.G_ITEM_MODEL
  OR      item_type_code = OE_GLOBALS.G_ITEM_OPTION
  OR      item_type_code = OE_GLOBALS.G_ITEM_CLASS
  OR      item_type_code = OE_GLOBALS.G_ITEM_KIT);

  I                         NUMBER;
  l_config_effective_date   DATE;
  l_frozen_model_bill       VARCHAR2(1) := 'Y';
  l_old_behavior            VARCHAR2(1);
  l_validation_org          NUMBER :=
                            OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID');
  l_stdcompflag             VARCHAR2(10)
                            := OE_Config_Util.OE_BMX_OPTION_COMPS;
  l_top_item_id             NUMBER;
  l_op_qty                  NUMBER;
  l_top_bill_sequence_id    NUMBER;
  l_disable_code            NUMBER := 1;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1):=  FND_API.G_RET_STS_SUCCESS;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(p_query_criteria || '-ENTERING GET_OPTIONS_FROM_DB'
                     || P_TOP_MODEL_LINE_ID,1);
  END IF;

  x_disabled_options := 'N';

  IF p_caller is NOT NULL AND
     p_query_criteria > 1 AND
     OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN

    OE_Config_Util.Get_Config_Effective_Date
    ( p_model_line_id         => p_top_model_line_id
     ,x_old_behavior          => l_old_behavior
     ,x_config_effective_date => l_config_effective_date
     ,x_frozen_model_bill     => l_frozen_model_bill);


    IF l_frozen_model_bill = 'N' THEN
      SELECT inventory_item_id, component_sequence_id
      INTO   l_top_item_id, l_top_bill_sequence_id
      FROM   oe_order_lines
      WHERE  line_id = p_top_model_line_id;

      OE_CONFIG_UTIL.Explode
      ( p_validation_org   => OE_SYS_PARAMETERS.VALUE
                            ('MASTER_ORGANIZATION_ID')
      , p_stdcompflag      => l_stdcompflag
      , p_top_item_id      => l_top_item_id
      , p_revdate          => l_config_effective_date
      , x_msg_data         => l_msg_data
      , x_error_code       => l_disable_code
      , x_return_status    => l_return_status);

      Handle_Ret_Status(p_return_status => l_return_status);
    ELSE
      IF p_query_criteria = 3 THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('nothing can be disabled ', 1);
        END IF;
        RETURN;
      END IF;
    END IF;
  END IF;

  I := 0;
  FOR opt_rec in Get_Options
  LOOP

    IF l_frozen_model_bill = 'N' THEN
      BEGIN

        SELECT 1
        INTO   l_disable_code
        FROM   bom_explosions
        WHERE  component_item_id = opt_rec.inventory_item_id
        AND    explosion_type    = Oe_Config_Util.OE_BMX_OPTION_COMPS
        AND    top_bill_sequence_id = l_top_bill_sequence_id
        AND    effectivity_date  <= l_config_effective_date
        AND    disable_date      >  l_config_effective_date
        AND    organization_id   =  OE_SYS_PARAMETERS.VALUE
                                   ('MASTER_ORGANIZATION_ID')
        AND    component_code    =  opt_rec.component_code;

        IF p_query_criteria in (1,2,4) THEN
          l_disable_code := 1; -- error code of 1 means not disabled
        ELSE
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('do not enter loop', 1);
          END IF;
          l_disable_code := 0; -- error code of 0, do not enter loop
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('no data, must be disabled', 1);
          END IF;

          IF p_query_criteria in (1,3,4) THEN
            l_disable_code := 2; -- error code of 2 means disabled
          ELSE -- send enabled only
            l_disable_code := 0;
          END IF;

        WHEN TOO_MANY_ROWS THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('too many rows', 1);
          END IF;
          RAISE;

        WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('bom item select error '|| sqlerrm, 1);
          END IF;
          RAISE;
      END;
    END IF; -- frozen or not

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('disable_code '|| l_disable_code, 3);
    END IF;

    IF ((opt_rec.bom_item_type = 1 AND p_get_model_line) OR
         opt_rec.bom_item_type <> 1 ) AND
       l_disable_code > 0 THEN


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('SAVED OPTION FROM DB '||OPT_REC.COMPONENT_CODE,3);
      END IF;

      IF p_caller = 'OPTIONS WINDOW UI' THEN
        I := Mod(opt_rec.line_id,G_BINARY_LIMIT);              -- Bug 8656395
      ELSE
        I := I + 1;
      END IF;

      x_options_tbl(I).component_code        := opt_rec.component_code;
      x_options_tbl(I).ordered_quantity      := opt_rec.ordered_quantity;
      x_options_tbl(I).inventory_item_id     := opt_rec.inventory_item_id;
      x_options_tbl(I).component_sequence_id := opt_rec.component_sequence_id;
      x_options_tbl(I).sort_order            := opt_rec.sort_order;
      x_options_tbl(I).order_quantity_uom    := opt_rec.order_quantity_uom;
      x_options_tbl(I).bom_item_type         := opt_rec.bom_item_type;
      x_options_tbl(I).ordered_item          := opt_rec.ordered_item;
      x_options_tbl(I).configuration_id      := opt_rec.configuration_id;


      IF l_disable_code = 2 THEN
        x_options_tbl(I).disabled_flag         := 'Y';
        x_disabled_options := 'Y';

        IF l_debug_level > 0  THEN
          oe_debug_pub.add('disabled ****', 1);
        END IF;
      ELSE
        x_options_tbl(I).disabled_flag         := 'N';
      END IF;

      x_options_tbl(I).attribute1            := opt_rec.attribute1;
      x_options_tbl(I).attribute2            := opt_rec.attribute2;
      x_options_tbl(I).attribute3            := opt_rec.attribute3;
      x_options_tbl(I).attribute4            := opt_rec.attribute4;
      x_options_tbl(I).attribute5            := opt_rec.attribute5;
      x_options_tbl(I).attribute6            := opt_rec.attribute6;
      x_options_tbl(I).attribute7            := opt_rec.attribute7;
      x_options_tbl(I).attribute8            := opt_rec.attribute8;
      x_options_tbl(I).attribute9            := opt_rec.attribute9;
      x_options_tbl(I).attribute10           := opt_rec.attribute10;
      x_options_tbl(I).attribute11           := opt_rec.attribute11;
      x_options_tbl(I).attribute12           := opt_rec.attribute12;
      x_options_tbl(I).attribute13           := opt_rec.attribute13;
      x_options_tbl(I).attribute14           := opt_rec.attribute14;
      x_options_tbl(I).attribute15           := opt_rec.attribute15;
      x_options_tbl(I).attribute16           := opt_rec.attribute16;
      x_options_tbl(I).attribute17           := opt_rec.attribute17;
      x_options_tbl(I).attribute18           := opt_rec.attribute18;
      x_options_tbl(I).attribute19           := opt_rec.attribute19;
      x_options_tbl(I).attribute20           := opt_rec.attribute20;
      x_options_tbl(I).context               := opt_rec.context;

      IF opt_rec.configuration_id is NULL AND opt_rec.config_header_id is NULL
      THEN
        x_options_tbl(I).operation             := OE_GLOBALS.G_OPR_CREATE;
      ELSE
        x_options_tbl(I).operation             := OE_GLOBALS.G_OPR_NONE;
      END IF;

      x_options_tbl(I).line_id                 := opt_rec.line_id;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('QTY FROM DB '|| OPT_REC.ORDERED_QUANTITY , 3 );
        oe_debug_pub.add('ATTRIBUTE1 FROM DB '|| OPT_REC.ATTRIBUTE1 , 3 );
      END IF;
    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('----- not assigned '||OPT_REC.COMPONENT_CODE,3);
      END IF;
    END IF; -- if not bom_item = 1

  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LEAVING GET_OPTIONS_FROM_DB' , 1 ) ;
  END IF;

EXCEPTION
 WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GET_OPTIONS_FROM_DB EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Get_Options_From_DB;

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

PROCEDURE Handle_Ret_Status(p_return_Status   VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;
END Handle_Ret_Status;


/*------------------------------------------------------------------------
PROCEDURE: Load_BOM_Table

-------------------------------------------------------------------------*/
PROCEDURE Load_BOM_Table
( p_options_tbl         IN  OE_Process_Options_Pvt.SELECTED_OPTIONS_TBL_TYPE
 ,x_bom_validation_tbl  OUT NOCOPY OE_CONFIG_VALIDATION_PVT.VALIDATE_OPTIONS_TBL_TYPE)
IS
I       NUMBER;
l_count NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING LOAD_BOM_TABLE' , 1 ) ;
  END IF;

  l_count := 0;
  I       := p_options_tbl.FIRST;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('NUMBER OF OPTION SENT IN ' || P_OPTIONS_TBL.COUNT,1);
  END IF;

  WHILE I is not null
  LOOP

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(P_OPTIONS_TBL(I).disabled_flag || ' child '
                       || P_OPTIONS_TBL(I).line_id,1);
    END IF;

    IF nvl(p_options_tbl(I).operation, OE_GLOBALS.G_OPR_NONE)
       <> OE_GLOBALS.G_OPR_DELETE AND
       nvl(p_options_tbl(I).disabled_flag, 'N') = 'N' THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        (  'COMPONENT: '|| P_OPTIONS_TBL ( I ) .COMPONENT_CODE , 2 ) ;
      END IF;

      l_count := l_count + 1;
      x_bom_validation_tbl(l_count).component_code
                            := p_options_tbl(I).component_code;
      x_bom_validation_tbl(l_count).ordered_quantity
                            := p_options_tbl(I).ordered_quantity;
      x_bom_validation_tbl(l_count).ordered_item
                            := p_options_tbl(I).ordered_item;
      x_bom_validation_tbl(l_count).bom_item_type
                            := p_options_tbl(I).bom_item_type;
      x_bom_validation_tbl(l_count).sort_order
                            := p_options_tbl(I).sort_order;
    END IF;
    I := p_options_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LEAVING LOAD_BOM_TABLE' , 1 ) ;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LOAD_BOM_TABLE EXCEPTION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END;


END OE_Process_Options_Pvt;

/
