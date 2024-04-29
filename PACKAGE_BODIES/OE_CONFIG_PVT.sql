--------------------------------------------------------
--  DDL for Package Body OE_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CONFIG_PVT" AS
/* $Header: OEXVCFGB.pls 120.13.12010000.2 2008/09/16 04:30:33 spothula ship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30):='oe_config_pvt';


/*--------------------------------------------------------------------
forward declarations
-------------------------------------------------------------------*/

Procedure update_link_to_line_id
( p_top_model_line_id  IN  NUMBER
 ,p_remnant_flag       IN  VARCHAR2
 ,p_config_hdr_id      IN  NUMBER);

Procedure update_ato_line_attributes
( p_top_model_line_id   IN  NUMBER
 ,p_ui_flag             IN  VARCHAR2
 ,p_config_hdr_id       IN  NUMBER);

PROCEDURE Check_If_cancellation
( p_line_id           IN  NUMBER
 ,p_top_model_line_id IN  NUMBER
 ,p_item_type_code    IN  VARCHAR2
 ,x_cancellation      OUT NOCOPY /* file.sql.39 change */ BOOLEAN
 ,x_current_quantity  OUT NOCOPY /* file.sql.39 change */ NUMBER);

PROCEDURE Handle_Inserts
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_config_instance_tbl IN csi_datastructures_pub.instance_cz_tbl
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN  BOOLEAN := FALSE
 ,p_ui_flag           IN  VARCHAR2 := 'Y');

PROCEDURE Handle_Inserts_Old
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN BOOLEAN := FALSE);

PROCEDURE Handle_Updates
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN  BOOLEAN := FALSE
 ,p_ui_flag           IN  VARCHAR2);

PROCEDURE Handle_Updates_old
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN  BOOLEAN := FALSE
 ,p_ui_flag           IN  VARCHAR2);

PROCEDURE Handle_Deletes
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN  BOOLEAN := FALSE
 ,p_ui_flag           IN  VARCHAR2);

PROCEDURE Handle_Deletes_Old
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN  BOOLEAN := FALSE
 ,p_ui_flag           IN  VARCHAR2);

PROCEDURE Print_Time(p_msg   IN  VARCHAR2);

/* --------------------------------------------------------------------
Procedure Name : Process_Config
Description    :

   Lock the configuration. Explode the bill.

   Get the records from cz_config_details_v
   and bom_explosions and
   insert,update,or deletethem from order_lines.

   We will open three cursors :
     the first to pass an operation of INSERT
     for records which do not exist
     =>  handle_inserts proc
     The second to pass an operation of UPDATE
     for records which already exist.
     =>  handle_updates prc
     The third to pass an operation of DELETE
     for records which exist but are no longer selected.
     =>  handle_deletes proc

   get values from cz_config_details_v
   viz.  comp_code, qty, cfg_hdr_id, rev_no
   and bom_explosions viz.
   component_sequence_id, sort_order, bom_item_type,
   bill_sequence_id, top_bill_sequence_id

   call process_order and update the links.

   If the p_ui_flag 'Y', we set the control_rec.process to TRUE
   This means when options are created using configurator,
   we want all the delayed requests to be processed.
   when order_import calls process_order to create options,
   control_rec.process is set to false so that delayed requests
   do not get processed in the recursive call to process_order
   after batch validation.

Change Record:
Bug 2181376: explode bill is not required since in handle_inserts
procedure we will selecet all required data from cz_config_details_v
and do not need to join with bom_explosions anymore. This change is
also useful for multiple instance project.
--------------------------------------------------------------------*/

Procedure Process_Config(p_header_id          IN  NUMBER
                        ,p_config_hdr_id      IN  NUMBER
                        ,p_config_rev_nbr     IN  NUMBER
                        ,p_top_model_line_id  IN  NUMBER
                        ,p_ui_flag            IN  VARCHAR2 :='Y'
                        ,p_config_instance_tbl IN
                         csi_datastructures_pub.instance_cz_tbl := G_CONFIG_INSTANCE_TBL
                        ,x_change_flag        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                        ,x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER
                        ,x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                        ,x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                        )
IS

  -- general, column_changes and and cz's delete api stuff
  l_direct_save                BOOLEAN;
  l_return_status_del          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_model_line_rec             OE_ORDER_PUB.Line_Rec_Type;
  l_profile_value              VARCHAR2(1) :=
                        upper(FND_PROFILE.VALUE('ONT_CONFIG_QUICK_SAVE'));

  -- process_order in params
  l_control_rec                   OE_GLOBALS.Control_Rec_Type;
  l_header_rec                    OE_Order_PUB.Header_Rec_Type;
  l_old_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
  l_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
  l_class_line_tbl                OE_Order_PUB.Line_Tbl_Type;
  l_operation                     VARCHAR2(1) := 'A';
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);
  l_return_status                 VARCHAR2(1);
  l_model_new_qty                 NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  Print_Time('Entering Process Config '|| p_config_hdr_id);

  OE_Msg_Pub.Set_Msg_Context
  ( p_entity_code => OE_Globals.G_ENTITY_LINE
   ,p_entity_id   => p_top_model_line_id
   ,p_header_id   => p_header_id
   ,p_line_id     => p_top_model_line_id);


  OE_LINE_UTIL.Lock_Row (p_line_id       => p_top_model_line_id
                        ,p_x_line_rec    => l_model_line_rec
                        ,x_return_status => l_return_status);

  OE_MSG_PUB.update_msg_context
    ( p_entity_code                 => 'LINE'
     ,p_entity_id                   => l_model_line_rec.line_id
     ,p_header_id                   => l_model_line_rec.header_id
     ,p_line_id                     => l_model_line_rec.line_id
     ,p_orig_sys_document_ref       => l_model_line_rec.orig_sys_document_ref
     ,p_orig_sys_document_line_ref  => l_model_line_rec.orig_sys_line_ref
     ,p_orig_sys_shipment_ref       => l_model_line_rec.orig_sys_shipment_ref
     ,p_change_sequence             => l_model_line_rec.change_sequence
     ,p_source_document_id          => l_model_line_rec.source_document_id
     ,p_source_document_line_id     => l_model_line_rec.source_document_line_id
     ,p_order_source_id             => l_model_line_rec.order_source_id
     ,p_source_document_type_id     => l_model_line_rec.source_document_type_id);

  IF l_model_line_rec.booked_flag = 'N' and l_profile_value = 'Y' AND
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


  -- if model goes thro process_config 1st time i.e just created,
  -- and if qty of model changed in configurator, we have to update it.
  -- in this situation(will happen onlu once in entire life of configuration)

  IF l_model_line_rec.config_header_id is null AND
     l_model_line_rec.config_rev_nbr is null THEN

      BEGIN
        SELECT quantity, config_item_id
        INTO   l_model_new_qty, l_model_line_rec.configuration_id
        FROM   cz_config_details_v
        WHERE  config_hdr_id     = p_config_hdr_id
        AND    config_rev_nbr    = p_config_rev_nbr
        AND    inventory_item_id = l_model_line_rec.inventory_item_id;

        -- Bug 6073974 Update the Configuration id for model line
        UPDATE OE_ORDER_LINES_ALL
        SET CONFIGURATION_ID = l_model_line_rec.configuration_id
        WHERE inventory_item_id = l_model_line_rec.inventory_item_id
        AND LINE_ID = l_model_line_rec.line_id;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Configuration_id for Model: '|| l_model_line_rec.line_id , 1 ) ;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'QTY SELECT: '|| SQLERRM , 1 ) ;
          END IF;
          RAISE;
      END;

      IF l_model_new_qty <> nvl(l_model_line_rec.ordered_quantity, 0) THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('UPDATE MODEL WITH NEW QTY '|| L_MODEL_NEW_QTY,1);
        END IF;

        l_model_line_rec.ordered_quantity       := l_model_new_qty;
        l_model_line_rec.operation              := OE_GLOBALS.G_OPR_UPDATE;
        l_line_tbl(nvl(l_line_tbl.LAST, 0) + 1) := l_model_line_rec;

      END IF;

  END IF;


  Handle_Inserts(p_model_line_rec   => l_model_line_rec
                ,p_config_hdr_id    => p_config_hdr_id
                ,p_config_rev_nbr   => p_config_rev_nbr
                ,p_x_line_tbl       => l_line_tbl
                ,p_config_instance_tbl => p_config_instance_tbl
                ,p_x_class_line_tbl => l_class_line_tbl
                ,p_direct_save      => l_direct_save
                ,p_ui_flag          => p_ui_flag);

  IF l_model_line_rec.config_header_id is not null AND
     l_model_line_rec.config_rev_nbr is not null THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('MODEL QTY: '|| L_MODEL_LINE_REC.ORDERED_QUANTITY,1);
    END IF;

    Handle_Updates(p_model_line_rec   => l_model_line_rec
                  ,p_config_hdr_id    => p_config_hdr_id
                  ,p_config_rev_nbr   => p_config_rev_nbr
                  ,p_x_line_tbl       => l_line_tbl
                  ,p_x_class_line_tbl => l_class_line_tbl
                  ,p_direct_save      => FALSE
                  ,p_ui_flag          => p_ui_flag);

    Handle_Deletes(p_model_line_rec   => l_model_line_rec
                  ,p_config_hdr_id    => p_config_hdr_id
                  ,p_config_rev_nbr   => p_config_rev_nbr
                  ,p_x_line_tbl       => l_line_tbl
                  ,p_x_class_line_tbl => l_class_line_tbl
                  ,p_direct_save      => FALSE
                  ,p_ui_flag          => p_ui_flag);
  ELSE
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'FIRST TIME CREATE , NO UPD/DEL REQ.' , 1 ) ;
     END IF;
     l_operation := 'C';
  END IF;


  --even if line_count = 0,  we need to call, for change columns.

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'PROCESS CONFIG , LINES: '||L_LINE_TBL.COUNT , 1 ) ;
    oe_debug_pub.add(  'DIRECT SAVE LINES: '||L_CLASS_LINE_TBL.COUNT , 1 ) ;
  END IF;

  l_control_rec.check_security       := TRUE;

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
    ,p_top_model_line_id => p_top_model_line_id
    ,p_config_hdr_id     => p_config_hdr_id
    ,p_config_rev_nbr    => p_config_rev_nbr
    ,p_update_columns    => TRUE
    ,x_return_status     => l_return_status);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('PROCESS ORDER RETURN_STATUS: ' || L_RETURN_STATUS ,1);
  END IF;

  IF p_config_hdr_id = l_model_line_rec.config_header_id AND
     p_config_rev_nbr = l_model_line_rec.config_rev_nbr THEN
    oe_debug_pub.add('do not delete, special', 1);
  ELSE
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- since we could not save the config successfully,
      -- delete current rev. in SPC

      Delete_Config( p_config_hdr_id   =>  p_config_hdr_id
                    ,p_config_rev_nbr  =>  p_config_rev_nbr
                    ,x_return_status   =>  l_return_status_del);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
         RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSE
       -- If we successfully save the configuration in oe_order_lines then
       -- Time to delete previous revisions from spc

       IF l_model_line_rec.config_header_id is not null AND
          l_model_line_rec.config_rev_nbr is not null
       THEN
         Delete_Config( p_config_hdr_id   =>  l_model_line_rec.config_header_id
                       ,p_config_rev_nbr  =>  l_model_line_rec.config_rev_nbr
                       ,x_return_status   =>  l_return_status_del);
       END IF;
     END IF; -- if success.
  END IF; -- do no delete

  -- setting change flag, decides to commit and query line block or not.
  IF p_ui_flag = 'Y' AND ( nvl(l_line_tbl.count, 0) > 0 OR
     p_config_hdr_id is not null ) THEN
    x_change_flag := 'Y';
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CHANGED CONFIG INTERACTIVELY' , 1 ) ;
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  Print_Time('Leaving Process Config');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR: ' || SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
        END IF;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Config'
            );
        END IF;

        --  Get message count and data
        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Process_Config;


/*------------------------------------------------------------------
PROCEDURE Handle_Inserts

if a component is present in cz_config_details_v but not present
in oe_order_lines, we need to insert it.

Change Record:
Bug 2181376: explode bill is not required since in this
procedure we will selecet all required data from cz_config_details_v
and do not need to join with bom_explosions anymore. This change is
also useful for multiple instance project
Bug 2869052 :
Default_Child_Line procedure would be called only if there are
any new class lines to be created and direct save shoule be true.
If the call returns an error an exception would be raised. New
variable l_default_child_line has been created.

MACD: Line Type Support -  modified the cursor to select the line_type
also and then if it null and not missing, assigning the child line
record's line_type_id to the retreived line_type

Bug 3611416
Send reason for CREATE operation also, will be required if there is
a require reason constraint for versioning during create operation.

bug3578056
for a new configuration, the IB fields should be NULL for the
top model and child lines
-------------------------------------------------------------------*/

PROCEDURE Handle_Inserts
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_config_instance_tbl IN csi_datastructures_pub.instance_cz_tbl
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN  BOOLEAN := FALSE
 ,p_ui_flag           IN  VARCHAR2 := 'Y')
IS

  CURSOR config_ins_cursor IS
    SELECT c.component_code, c.quantity
          ,c.uom_code, c.inventory_item_id
          ,c.instance_hdr_id, c.instance_rev_nbr
          ,c.component_sequence_id, c.bom_sort_order
          ,c.bom_item_type, c.config_item_id
          ,c.line_type
    FROM  CZ_CONFIG_DETAILS_V c
    WHERE c.config_hdr_id         = p_config_hdr_id
    AND   c.config_rev_nbr        = p_config_rev_nbr
    AND NOT EXISTS
          ( SELECT 'X'
            FROM  oe_order_lines l
            WHERE l.top_model_line_id = p_model_line_rec.line_id
            AND   l.component_code    = c.component_code
            AND   l.configuration_id  = c.config_item_id
            AND   l.open_flag         = 'Y')
    ORDER BY c.component_code;


  l_line_rec                      OE_ORDER_PUB.Line_Rec_Type;
  l_class_line_rec                OE_ORDER_PUB.Line_Rec_Type;
  l_line_count                    NUMBER;
  l_class_line_count              NUMBER;
  l_return_status                 VARCHAR2(1);
  l_concatenated_segments         VARCHAR2(163);
  l_default_child_line            BOOLEAN := TRUE;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  l_top_container_model           VARCHAR2(1);
  l_part_of_container             VARCHAR2(1);
  l_default_line_type_id          NUMBER; --Added for bug 5107271
BEGIN
  Print_Time('Handle_Inserts start time');

  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INS: PACK H NEW LOGIC' , 1 ) ;
    END IF;

    BEGIN

      UPDATE oe_order_lines oe
      SET ( configuration_id , sort_order ) =
        (SELECT config_item_id , bom_sort_order --bug6628691
         FROM   cz_config_details_v
         WHERE  config_hdr_id = p_config_hdr_id
         AND    config_rev_nbr = p_config_rev_nbr
         AND    component_code = oe.component_code
        )
      WHERE top_model_line_id = p_model_line_rec.line_id
      AND   config_header_id is NULL
      AND   configuration_id is NULL
      AND   item_type_code in ('MODEL', 'CLASS', 'OPTION', 'KIT')
      AND   open_flag = 'Y';

      IF SQL%FOUND THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CONFIGURATION_ID UPDATED '|| SQL%ROWCOUNT ,3);
        END IF;
      ELSE
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CRM 1:CONFIGURATION_ID NOT UPDATED ' , 3 ) ;
        END IF;

        UPDATE oe_order_lines oe
        SET ( configuration_id , sort_order ) =
          (SELECT config_item_id , bom_sort_order --bug6628691
           FROM   cz_config_details_v
           WHERE  config_hdr_id = p_config_hdr_id
           AND    config_rev_nbr = p_config_rev_nbr
           AND    component_code = oe.component_code
	           )
        WHERE top_model_line_id = p_model_line_rec.line_id
        AND   configuration_id is NULL
        AND   item_type_code in ('MODEL', 'CLASS', 'OPTION', 'KIT')
        AND   open_flag = 'Y';

        IF SQL%FOUND THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CRM: CONFIGURATION_ID '|| SQL%ROWCOUNT , 3 ) ;
          END IF;
        ELSE
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CRM 2:CONFIGURATION_ID NOT UPDATED ' , 3 ) ;
          END IF;
        END IF;
      END IF;

    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        FND_Message.Set_Name('ONT', 'OE_CONFIG_MI_NOT_ALLOWED');
        FND_MESSAGE.SET_TOKEN('MODEL', p_model_line_rec.ordered_item);
        FND_MESSAGE.SET_TOKEN('LINE_NUMBER', p_model_line_rec.line_number ||
                                             p_model_line_rec.shipment_number);
        OE_Msg_Pub.Add;
        RAISE;
      WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OTHERS IN CONFIG ID UPD '|| SQLERRM , 1 ) ;
        END IF;
        RAISE;
      END;

  ELSE
    Handle_Inserts_Old
    (p_model_line_rec   => p_model_line_rec
    ,p_config_hdr_id    => p_config_hdr_id
    ,p_config_rev_nbr   => p_config_rev_nbr
    ,p_x_line_tbl       => p_x_line_tbl
    ,p_x_class_line_tbl => p_x_class_line_tbl
    ,p_direct_save      => p_direct_save);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RETURNING..' , 1 ) ;
    END IF;

    RETURN;
  END IF;


  l_line_count       := nvl(p_x_line_tbl.LAST, 0);
  l_class_line_count := nvl(p_x_class_line_tbl.LAST, 0);

  l_line_rec           := OE_ORDER_PUB.G_MISS_LINE_REC;
  l_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;
  l_line_rec.header_id := p_model_line_rec.header_id;
  l_line_rec.item_identifier_type   := 'INT';
  l_line_rec.config_header_id := p_config_hdr_id;
  l_line_rec.config_rev_nbr   := p_config_rev_nbr;
  l_line_rec.change_reason    := 'SYSTEM';

  IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN

    OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
    (  p_line_id             => p_model_line_rec.line_id
      ,x_top_container_model => l_top_container_model
      ,x_part_of_container   => l_part_of_container );

    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('Line ID:'||p_model_line_rec.line_id,3);
       OE_DEBUG_PUB.Add('Top Container:'||l_top_container_model,3);
       OE_DEBUG_PUB.Add('Part of Container:'||l_part_of_container,3);
    END IF;

    IF l_top_container_model = 'Y' THEN

       l_line_rec.ib_owner := NULL;
       l_line_rec.ib_current_location := NULL;
       l_line_rec.ib_installed_at_location := NULL;

       IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('IB Fields set to NULL for child lines',3);
       END IF;

    END IF;
  END IF;


  FOR config_rec in config_ins_cursor
  LOOP

   --MACD---------------------------------------------
    --should populate IB values for all lines except the top
    --container model itself.

    IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN
      FOR T IN 1..p_config_instance_tbl.COUNT LOOP
         IF l_debug_level > 0 THEN
           oe_debug_pub.add('CZ Inst Hdr:'||config_rec.instance_hdr_id,2);
           oe_debug_pub.add('IB inst Hdr:'
                    ||p_config_instance_tbl(T).config_instance_hdr_id,2);
           oe_debug_pub.add('CZ Rev Nbr:'||config_rec.instance_rev_nbr,2);
           oe_debug_pub.add('IB Rev:'
                    ||p_config_instance_tbl(T).config_instance_rev_number,2);
           oe_debug_pub.add('CZ Item:'||config_rec.config_item_id,3);
           oe_debug_pub.add('IB Item:'||
                      p_config_instance_tbl(T).config_instance_item_id,2);
         END IF;

        IF config_rec.instance_hdr_id =
           p_config_instance_tbl(T).config_instance_hdr_id AND
           config_rec.config_item_id =
           p_config_instance_tbl(T).config_instance_item_id THEN

          IF l_debug_level > 0 THEN
            oe_debug_pub.add
            ('match found for item:'||config_rec.inventory_item_id);
          END IF;

          l_line_rec.invoice_to_org_id :=
                       p_config_instance_tbl(T).bill_to_site_use_id;
          l_line_rec.ship_to_org_id :=
                       p_config_instance_tbl(T).ship_to_site_use_id;
          l_line_rec.ib_owner := 'INSTALL_BASE';
          l_line_rec.ib_current_location := 'INSTALL_BASE';
          l_line_rec.ib_installed_at_location := 'INSTALL_BASE';
        END IF;
      END LOOP;
    ELSE
      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Not in pack J. No MACD Logic',3);
        OE_DEBUG_PUB.Add('IB Values NOT populated',3);
      END IF;

    END IF;
    --MACD---------------------------------------------

    -- Get the concatanted segment value to be stored in
    -- order lines at ordered_item

    BEGIN
      SELECT concatenated_segments
      INTO l_concatenated_segments
      FROM MTL_SYSTEM_ITEMS_KFV
      WHERE inventory_item_id = config_rec.inventory_item_id
      AND organization_id = OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CONCAT SEGMENT IS: ' || L_CONCATENATED_SEGMENTS,3);
      oe_debug_pub.add('INSERTING COMP CODE: '||CONFIG_REC.COMPONENT_CODE,1);
      oe_debug_pub.add('CONFIGURATION ID: ' || CONFIG_REC.CONFIG_ITEM_ID ,1);
    END IF;

    IF p_direct_save AND
      (config_rec.bom_item_type = 2 OR config_rec.bom_item_type = 1)
    THEN

      IF l_default_child_line THEN

         oe_debug_pub.add(  'DIRECT SAVE IS ON' , 3 ) ;

         l_class_line_rec.config_header_id := p_config_hdr_id;
         l_class_line_rec.config_rev_nbr   := p_config_rev_nbr;

         OE_Config_Util.Default_Child_Line
         ( p_parent_line_rec  => p_model_line_rec
          ,p_x_child_line_rec => l_class_line_rec
          ,p_direct_save      => p_direct_save
          ,x_return_status    => l_return_status);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_default_child_line := FALSE;
         l_default_line_type_id := l_class_line_rec.line_type_id; --Added for bug 5107271

      END IF;

      IF config_rec.line_type IS NOT NULL AND
         config_rec.line_type <> FND_API.G_MISS_NUM THEN

        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('Line Type from cz:'||config_rec.line_type,3);
        END IF;
        l_class_line_rec.line_type_id := config_rec.line_type;
      ELSE
        /* Modified the below statement for bug 5107271 to assign the value of
           l_default_line_type_id instead of FND_API.G_MISS_NUM */
        -- l_class_line_rec.line_type_id := FND_API.G_MISS_NUM;
        l_class_line_rec.line_type_id := l_default_line_type_id;
      END IF;

      l_class_line_rec.ordered_quantity       := config_rec.quantity;
      l_class_line_rec.order_quantity_uom     := config_rec.uom_code;
      l_class_line_rec.component_sequence_id
                                        := config_rec.component_sequence_id;
      l_class_line_rec.component_code         := config_rec.component_code;
      l_class_line_rec.sort_order             := config_rec.bom_sort_order;
      l_class_line_rec.inventory_item_id      := config_rec.inventory_item_id;
      l_class_line_rec.configuration_id       := config_rec.config_item_id;
      l_class_line_rec.ordered_item           := l_concatenated_segments;

      SELECT  OE_ORDER_LINES_S.NEXTVAL
      INTO    l_class_line_rec.line_id
      FROM    DUAL;

      l_class_line_rec.pricing_quantity_uom
                                := l_class_line_rec.order_quantity_uom;
      l_class_line_rec.pricing_quantity
                                := l_class_line_rec.ordered_quantity;

      l_class_line_count                        := l_class_line_count+1;
      p_x_class_line_tbl(l_class_line_count)    := l_class_line_rec;

    ELSE

      IF config_rec.line_type IS NOT NULL AND
         config_rec.line_type <> FND_API.G_MISS_NUM THEN

        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('cz LineType:'||config_rec.line_type,3);
        END IF;
        l_line_rec.line_type_id := config_rec.line_type;
      ELSE
        l_line_rec.line_type_id := FND_API.G_MISS_NUM;
      END IF;


      l_line_rec.ordered_quantity       := config_rec.quantity;
      l_line_rec.order_quantity_uom     := config_rec.uom_code;
      l_line_rec.component_sequence_id  := config_rec.component_sequence_id;
      l_line_rec.top_model_line_id      := p_model_line_rec.line_id;
      l_line_rec.component_code         := config_rec.component_code;
      l_line_rec.sort_order             := config_rec.bom_sort_order;
      l_line_rec.inventory_item_id      := config_rec.inventory_item_id;
      l_line_rec.configuration_id       := config_rec.config_item_id;
      l_line_rec.ordered_item           := l_concatenated_segments;

      IF config_rec.bom_item_type = 1 OR
         config_rec.bom_item_type = 2 THEN
        l_line_rec.item_type_code     := OE_GLOBALS.G_ITEM_CLASS;
      ELSE
        l_line_rec.item_type_code     := null;
      END IF;

      l_line_count                      := l_line_count+1;
      p_x_line_tbl(l_line_count)        := l_line_rec;
    END IF;

  END LOOP;

  Print_Time('Handle_Inserts end time');
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN HANDLE_INSERTS'|| SQLERRM , 1 ) ;
    END IF;

    RAISE;
END Handle_Inserts;



/*------------------------------------------------------------
PROCEDURE Handle_Inserts_Old

if a component is present in cz_config_details_v but not present
in oe_order_lines, we need to insert it.

Change Record:
Bug 2181376: explode bill is not required since in this
procedure we will selecet all required data from cz_config_details_v
and do not need to join with bom_explosions anymore. This change is
also useful for multiple instance project.
Bug 2869052 :
Default_Child_Line procedure would be called only if there are
any new class lines to be created and direct save shoule be true.
If the call returns an error an exception would be raised. New
variable l_default_child_line has been created.
-------------------------------------------------------------*/

PROCEDURE Handle_Inserts_Old
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN BOOLEAN := FALSE)
IS

  CURSOR config_ins_cursor IS
    SELECT c.component_code, c.quantity
          ,c.uom_code, c.inventory_item_id
          ,c.component_sequence_id, c.bom_sort_order
          ,c.bom_item_type
    FROM  CZ_CONFIG_DETAILS_V c
    WHERE c.config_hdr_id         = p_config_hdr_id
    AND   c.config_rev_nbr        = p_config_rev_nbr
    AND NOT EXISTS
          ( SELECT 'X'
            FROM  oe_order_lines l
            WHERE l.top_model_line_id = p_model_line_rec.line_id
            AND   l.component_code    = c.component_code
            AND   l.open_flag         = 'Y')
    ORDER BY c.component_code;

  l_line_rec                      OE_ORDER_PUB.Line_Rec_Type;
  l_class_line_rec                OE_ORDER_PUB.Line_Rec_Type;
  l_line_count                    NUMBER;
  l_class_line_count              NUMBER;
  l_return_status                 VARCHAR2(1);
  l_concatenated_segments         VARCHAR2(163);
  l_default_child_line            BOOLEAN := TRUE;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  Print_Time('Handle_Inserts start time');

  l_line_count       := nvl(p_x_line_tbl.LAST, 0);
  l_class_line_count := nvl(p_x_class_line_tbl.LAST, 0);

  l_line_rec           := OE_ORDER_PUB.G_MISS_LINE_REC;
  l_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;
  l_line_rec.header_id := p_model_line_rec.header_id;
  l_line_rec.item_identifier_type   := 'INT';


  FOR config_rec in config_ins_cursor
  LOOP

    -- Get the concatanted segment value to be stored in
    -- order lines at ordered_item

    BEGIN
      SELECT concatenated_segments
      INTO l_concatenated_segments
      FROM MTL_SYSTEM_ITEMS_KFV
      WHERE inventory_item_id = config_rec.inventory_item_id
      AND organization_id = OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CONCAT SEGMENT IS: ' || L_CONCATENATED_SEGMENTS ,3);
      oe_debug_pub.add('INSERTING COMP CODE: ' || CONFIG_REC.COMPONENT_CODE,1);
    END IF;

    IF p_direct_save AND
      (config_rec.bom_item_type = 2 OR config_rec.bom_item_type = 1)
    THEN

      IF l_default_child_line THEN

         oe_debug_pub.add(  'DIRECT SAVE IS ON' , 3 ) ;

         OE_Config_Util.Default_Child_Line
         ( p_parent_line_rec  => p_model_line_rec
          ,p_x_child_line_rec => l_class_line_rec
          ,p_direct_save      => p_direct_save
          ,x_return_status    => l_return_status);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_default_child_line := FALSE;

      END IF; -- end if l_default_child_line

      l_class_line_rec.ordered_quantity       := config_rec.quantity;
      l_class_line_rec.order_quantity_uom     := config_rec.uom_code;
      l_class_line_rec.component_sequence_id
                                        := config_rec.component_sequence_id;
      l_class_line_rec.component_code         := config_rec.component_code;
      l_class_line_rec.sort_order             := config_rec.bom_sort_order;
      l_class_line_rec.inventory_item_id      := config_rec.inventory_item_id;
      l_class_line_rec.ordered_item           := l_concatenated_segments;

      SELECT  OE_ORDER_LINES_S.NEXTVAL
      INTO    l_class_line_rec.line_id
      FROM    DUAL;

      l_class_line_rec.pricing_quantity_uom
                                := l_class_line_rec.order_quantity_uom;
      l_class_line_rec.pricing_quantity
                                := l_class_line_rec.ordered_quantity;

      l_class_line_count                        := l_class_line_count+1;
      p_x_class_line_tbl(l_class_line_count)    := l_class_line_rec;

    ELSE

      l_line_rec.ordered_quantity       := config_rec.quantity;
      l_line_rec.order_quantity_uom     := config_rec.uom_code;
      l_line_rec.component_sequence_id  := config_rec.component_sequence_id;
      l_line_rec.top_model_line_id      := p_model_line_rec.line_id;
      l_line_rec.component_code         := config_rec.component_code;
      l_line_rec.sort_order             := config_rec.bom_sort_order;
      l_line_rec.inventory_item_id      := config_rec.inventory_item_id;
      l_line_rec.ordered_item           := l_concatenated_segments;

      IF config_rec.bom_item_type = 1 OR
         config_rec.bom_item_type = 2 THEN
        l_line_rec.item_type_code     := OE_GLOBALS.G_ITEM_CLASS;
      ELSE
        l_line_rec.item_type_code     := null;
      END IF;

      l_line_count                      := l_line_count+1;
      p_x_line_tbl(l_line_count)        := l_line_rec;
    END IF;

  END LOOP;

  Print_Time('Handle_Inserts_Old end time');
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN HANDLE_INSERTS_OLD'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Handle_Inserts_Old;


/*-----------------------------------------------------------
PROCEDURE Handle_Updates

If quantity of a component is different in oe_order_lines and
cz_config_details_v, we need to update that component.

for config UI only: if there is a constraint on qty change,
should we pass a hardcoded reason/comment, or should we fail?
we should fail.

MACD: Compare the line type in OM and CZ and if different
select into cursor. Also, set the child line record's line_type to
the selected value from cz
------------------------------------------------------------*/

PROCEDURE Handle_Updates
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN  BOOLEAN := FALSE
 ,p_ui_flag           IN  VARCHAR2)
IS
  CURSOR config_upd_cursor IS
    SELECT distinct
          l.line_id
         ,c.component_code
         ,c.quantity
         ,l.ordered_quantity
         ,l.item_type_code
         ,c.line_type
         ,c.bom_sort_order
    FROM  CZ_CONFIG_DETAILS_V c, oe_order_lines l
    WHERE c.config_hdr_id     = p_config_hdr_id
    AND   c.config_rev_nbr    = p_config_rev_nbr
    AND   (c.quantity <> l.ordered_quantity OR
           c.line_type <> l.line_type_id OR
           c.bom_sort_order <> l.sort_order)
    AND   l.top_model_line_id = p_model_line_rec.line_id
    AND   l.component_code    = c.component_code
    AND   l.configuration_id  = c.config_item_id
    AND   l.open_flag         = 'Y';

  l_line_rec                      OE_ORDER_PUB.Line_Rec_Type;
  l_class_line_rec                OE_ORDER_PUB.Line_Rec_Type;
  l_line_count                    NUMBER;
  l_class_line_count              NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  Print_Time('Handle_Updates start time');

  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508'
  THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PACK H NEW LOGIC' , 1 ) ;
    END IF;
  ELSE
    Handle_Updates_Old
    (p_model_line_rec   => p_model_line_rec
    ,p_config_hdr_id    => p_config_hdr_id
    ,p_config_rev_nbr   => p_config_rev_nbr
    ,p_x_line_tbl       => p_x_line_tbl
    ,p_x_class_line_tbl => p_x_class_line_tbl
    ,p_direct_save      => FALSE
    ,p_ui_flag          => p_ui_flag);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RETURNING..' , 1 ) ;
    END IF;

    RETURN;
  END IF;

  l_line_count                 := nvl(p_x_line_tbl.LAST, 0);
  l_class_line_count           := nvl(p_x_class_line_tbl.LAST, 0);

  l_line_rec                   := OE_ORDER_PUB.G_MISS_LINE_REC;
  l_line_rec.operation         := OE_GLOBALS.G_OPR_UPDATE;
  l_line_rec.top_model_line_id := p_model_line_rec.line_id;


  FOR config_rec in config_upd_cursor
  LOOP

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add
      ('OE QTY: '||CONFIG_REC.ORDERED_QUANTITY||'CZ QTY '||CONFIG_REC.QUANTITY ,1);
      oe_debug_pub.add('UPDATING COMP CODE: ' || CONFIG_REC.COMPONENT_CODE ,1);
      oe_debug_pub.add(  'I LINE ID:' || CONFIG_REC.LINE_ID , 1 ) ;
    END IF;

    l_line_rec.line_id               := config_rec.line_id;
    l_line_rec.ordered_quantity      := config_rec.quantity;
    l_line_rec.sort_order            := config_rec.bom_sort_order;

    IF config_rec.line_type IS NOT NULL AND
       config_rec.line_type <> FND_API.G_MISS_NUM THEN

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('MACD Logic,cz Line_type:'||config_rec.line_type,3);
      END IF;
      l_line_rec.line_type_id := config_rec.line_type;
    ELSE
      l_line_rec.line_type_id := FND_API.G_MISS_NUM;
    END IF;


    IF p_ui_flag = 'N' THEN
      l_line_rec.change_reason         := 'SYSTEM';
      l_line_rec.change_comments       := 'Change Cascaded';
    ELSE
      l_line_rec.change_reason         := 'CONFIGURATOR';
      l_line_rec.change_comments       := 'Changes in Configurator Window';
    END IF;

    IF p_direct_save AND config_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS
    THEN
      l_class_line_count                     := l_class_line_count+1;
      p_x_class_line_tbl(l_class_line_count) := l_line_rec;
    ELSE
      l_line_count               := l_line_count+1;
      p_x_line_tbl(l_line_count) := l_line_rec;
    END IF;

  END LOOP;

  Print_Time('Handle_Updates end time');
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN HANDLE_UPDATES'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Handle_Updates;


/*-----------------------------------------------------------
PROCEDURE Handle_Updates_Old

If quantity of a component is different in oe_order_lines and
cz_config_details_v, we need to update that component.

for config UI only: if there is a constraint on qty change,
should we pass a hardcoded reason/comment, or should we fail?
we should fail.
------------------------------------------------------------*/

PROCEDURE Handle_Updates_Old
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN  BOOLEAN := FALSE
 ,p_ui_flag           IN  VARCHAR2)
IS
  CURSOR config_upd_cursor IS
    SELECT distinct
          l.line_id
         ,c.component_code
         ,c.quantity
         ,l.ordered_quantity
         ,l.item_type_code
    FROM  CZ_CONFIG_DETAILS_V c, oe_order_lines l
    WHERE c.config_hdr_id     = p_config_hdr_id
    AND   c.config_rev_nbr    = p_config_rev_nbr
    AND   c.quantity <> l.ordered_quantity
    AND   l.top_model_line_id = p_model_line_rec.line_id
    AND   l.component_code    = c.component_code
    AND   l.open_flag         = 'Y';

  l_line_rec                      OE_ORDER_PUB.Line_Rec_Type;
  l_class_line_rec                OE_ORDER_PUB.Line_Rec_Type;
  l_line_count                    NUMBER;
  l_class_line_count              NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  Print_Time('Handle_Updates_Old start time');

  l_line_count                 := nvl(p_x_line_tbl.LAST, 0);
  l_class_line_count           := nvl(p_x_class_line_tbl.LAST, 0);

  l_line_rec                   := OE_ORDER_PUB.G_MISS_LINE_REC;
  l_line_rec.operation         := OE_GLOBALS.G_OPR_UPDATE;
  l_line_rec.top_model_line_id := p_model_line_rec.line_id;


  FOR config_rec in config_upd_cursor
  LOOP

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OE QTY: '||CONFIG_REC.QUANTITY||'CZ QTY '
                        ||CONFIG_REC.QUANTITY , 1 ) ;
      oe_debug_pub.add('UPDATING COMP CODE: '||CONFIG_REC.COMPONENT_CODE ,1);
      oe_debug_pub.add(  'I LINE ID:' || CONFIG_REC.LINE_ID , 1 ) ;
    END IF;

    l_line_rec.line_id               := config_rec.line_id;
    l_line_rec.ordered_quantity      := config_rec.quantity;

    IF p_ui_flag = 'N' THEN
      l_line_rec.change_reason         := 'SYSTEM';
      l_line_rec.change_comments       := 'Change Cascaded';
    ELSE
      l_line_rec.change_reason         := 'CONFIGURATOR';
      l_line_rec.change_comments       := 'Changes in Configurator Window';
    END IF;

    IF p_direct_save AND config_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS
    THEN
      l_class_line_count                     := l_class_line_count+1;
      p_x_class_line_tbl(l_class_line_count) := l_line_rec;
    ELSE
      l_line_count               := l_line_count+1;
      p_x_line_tbl(l_line_count) := l_line_rec;
    END IF;

  END LOOP;

  Print_Time('Handle_Updates_Old end time');
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN HANDLE_UPDATES_OLD'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Handle_Updates_Old;


/*---------------------------------------------------------
PROCEDURE Handle_Deletes

If a component exists in oe_order_lines, but does not exist
in cz_config_details_v, we need to delete that component.

Change Record:

bug 1939531: to not call check_if_cancellation
if first configuration is yet getting saved for the first
time and link_to_line_id is not yet populated.

do not call the check_if_cancellation id p_ui_flag is 'Y'.
This is because,
1) you can not enter reason and comment in configurator, so
if cancellation constraint is on, delete will fail.
2) configuraor will take care of cascading change to
child and parent lines, so we do not have to check in
oe_order_lines.
----------------------------------------------------------*/

PROCEDURE Handle_Deletes
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN  BOOLEAN := FALSE
 ,p_ui_flag           IN  VARCHAR2)
IS
 CURSOR config_del_cursor IS
    SELECT l.line_id, l.item_type_code, l.link_to_line_id,
           l.component_code, nvl(l.cancelled_flag, 'N') cancelled_flag
    FROM   oe_order_lines l
    WHERE  l.top_model_line_id = p_model_line_rec.line_id
    AND    (l.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
            l.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
            l.item_type_code = OE_GLOBALS.G_ITEM_KIT)
    AND     l.open_flag       = 'Y'
    AND
    (NOT EXISTS
          (     SELECT 'X'
                FROM   CZ_CONFIG_DETAILS_V c
                WHERE  c.component_code = l.component_code
                AND    c.config_item_id = l.configuration_id
                AND    c.config_hdr_id  = p_config_hdr_id
                AND    c.config_rev_nbr = p_config_rev_nbr )
    OR EXISTS
          (     SELECT 'X'
                FROM   CZ_CONFIG_DETAILS_V c
                WHERE  c.component_code = l.component_code
                AND    c.config_item_id = l.configuration_id
                AND    c.config_hdr_id  = p_config_hdr_id
                AND    c.config_rev_nbr = p_config_rev_nbr
                AND    c.quantity = 0));

  l_line_rec                      OE_ORDER_PUB.Line_Rec_Type;
  l_class_line_rec                OE_ORDER_PUB.Line_Rec_Type;
  l_line_count                    NUMBER;
  l_class_line_count              NUMBER;
  l_cancellation                  BOOLEAN;
  l_change_reason                 VARCHAR2(30);
  l_change_comments               VARCHAR2(30);
  l_qty                           NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  Print_Time('Handle_Deletes start time');

  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508'
  THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PACK H NEW LOGIC' , 1 ) ;
    END IF;
  ELSE
   Handle_Deletes_Old
   ( p_model_line_rec   => p_model_line_rec
    ,p_config_hdr_id    => p_config_hdr_id
    ,p_config_rev_nbr   => p_config_rev_nbr
    ,p_x_line_tbl       => p_x_line_tbl
    ,p_x_class_line_tbl => p_x_class_line_tbl
    ,p_direct_save      => FALSE
    ,p_ui_flag          => p_ui_flag);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RETURNING..' , 1 ) ;
    END IF;

    RETURN;
  END IF;

  l_line_count         := nvl(p_x_line_tbl.LAST, 0);
  l_class_line_count   := nvl(p_x_class_line_tbl.LAST, 0);
  l_line_rec           := OE_ORDER_PUB.G_MISS_LINE_REC;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CONFIG_DEL CURSOR OPENED' , 1 ) ;
  END IF;

  FOR config_rec in config_del_cursor
  LOOP

    l_cancellation := FALSE;

    IF (config_rec.link_to_line_id is NOT NULL AND
        p_ui_flag = 'N') OR
        p_ui_flag = 'Y' THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CALLING CHECK_IF.. '||CONFIG_REC.COMPONENT_CODE,3);
      END IF;

      IF p_ui_flag = 'Y' THEN
        l_change_comments  := 'Changes in Configurator Window';
        l_change_reason    := 'CONFIGURATOR';
      ELSE
        l_change_comments  := 'Change Cascaded';
        l_change_reason    := 'SYSTEM';
      END IF;

      Is_Cancel_OR_Delete
      ( p_line_id           => config_rec.line_id
       ,p_change_reason     => l_change_reason
       ,p_change_comments   => l_change_comments
       ,x_cancellation      => l_cancellation
       ,x_line_rec          => l_line_rec);

    END IF;

    IF NOT l_cancellation THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DELETING LINE : ' || CONFIG_REC.LINE_ID ) ;
      END IF;

      l_line_rec.line_id   := config_rec.line_id;
      l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('LINE_ID TO BE DELETED: ' || CONFIG_REC.LINE_ID ,1);
      END IF;

      IF p_direct_save AND
         config_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS
      THEN
        l_class_line_count                     := l_class_line_count+1;
        p_x_class_line_tbl(l_class_line_count) := l_line_rec;
      ELSE
        l_line_count                           := l_line_count+1;
        p_x_line_tbl(l_line_count)             := l_line_rec;
      END IF;

    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'YES CANCELLATION' , 3 ) ;
      END IF;

      IF config_rec.cancelled_flag = 'N' THEN

        l_line_rec.line_id               := config_rec.line_id;
        l_line_rec.operation             := OE_GLOBALS.G_OPR_UPDATE;
        l_line_rec.ordered_quantity      := 0;

        IF p_direct_save AND
           config_rec.item_type_code =OE_GLOBALS.G_ITEM_CLASS
        THEN
          l_class_line_count                     := l_class_line_count+1;
          p_x_class_line_tbl(l_class_line_count) := l_line_rec;
        ELSE
          l_line_count                           := l_line_count+1;
          p_x_line_tbl(l_line_count)             := l_line_rec;
        END IF;

      END IF;
    END IF;

  END LOOP;

  Print_Time('Handle_Deletes end time');
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN HANDLE_DELETES'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Handle_Deletes;


/*---------------------------------------------------------
PROCEDURE Handle_Deletes_Old

If a component exists in oe_order_lines, but does not exist
in cz_config_details_v, we need to delete that component.

Change Record:

bug 1939531: to not call check_if_cancellation
if first configuration is yet getting saved for the first
time and link_to_line_id is not yet populated.

do not call the check_if_cancellation id p_ui_flag is 'Y'.
This is because,
1) you can not enter reason and comment in configurator, so
if cancellation constraint is on, delete will fail.
2) configuraor will take care of cascading change to
child and parent lines, so we do not have to check in
oe_order_lines.
----------------------------------------------------------*/

PROCEDURE Handle_Deletes_Old
( p_model_line_rec    IN  OE_Order_Pub.Line_rec_Type
 ,p_config_hdr_id     IN  NUMBER
 ,p_config_rev_nbr    IN  NUMBER
 ,p_x_line_tbl        IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_x_class_line_tbl  IN  OUT NOCOPY OE_Order_Pub.Line_tbl_Type
 ,p_direct_save       IN  BOOLEAN := FALSE
 ,p_ui_flag           IN  VARCHAR2)
IS
 CURSOR config_del_cursor IS
    SELECT l.line_id, l.item_type_code, l.link_to_line_id,
           l.component_code
    FROM   oe_order_lines l
    WHERE  l.top_model_line_id = p_model_line_rec.line_id
    AND    (l.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
            l.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
            l.item_type_code = OE_GLOBALS.G_ITEM_KIT)
    AND     l.open_flag       = 'Y'
    AND
    (NOT EXISTS
          (     SELECT 'X'
                FROM   CZ_CONFIG_DETAILS_V c
                WHERE  c.component_code = l.component_code
                AND    c.config_hdr_id  = p_config_hdr_id
                AND    c.config_rev_nbr = p_config_rev_nbr )
    OR EXISTS
          (     SELECT 'X'
                FROM   CZ_CONFIG_DETAILS_V c
                WHERE  c.component_code = l.component_code
                AND    c.config_hdr_id  = p_config_hdr_id
                AND    c.config_rev_nbr = p_config_rev_nbr
                AND    c.quantity = 0));

  l_line_rec                      OE_ORDER_PUB.Line_Rec_Type;
  l_class_line_rec                OE_ORDER_PUB.Line_Rec_Type;
  l_line_count                    NUMBER;
  l_class_line_count              NUMBER;
  l_cancellation                  BOOLEAN;
  l_qty                           NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  Print_Time('Handle_Deletes_Old start time');

  l_line_count         := nvl(p_x_line_tbl.LAST, 0);
  l_class_line_count   := nvl(p_x_class_line_tbl.LAST, 0);
  l_line_rec           := OE_ORDER_PUB.G_MISS_LINE_REC;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CONFIG_DEL CURSOR OPENED' , 1 ) ;
  END IF;

  FOR config_rec in config_del_cursor
  LOOP

    l_cancellation := FALSE;

    IF config_rec.link_to_line_id is NOT NULL AND
       p_ui_flag = 'N' THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CALLING CHECK_IF.. '
                         || CONFIG_REC.COMPONENT_CODE , 3 ) ;
      END IF;

      Check_If_cancellation
      ( p_line_id           => config_rec.line_id
       ,p_top_model_line_id => p_model_line_rec.line_id
       ,p_item_type_code    => config_rec.item_type_code
       ,x_cancellation      => l_cancellation
       ,x_current_quantity  => l_qty);

    ELSIF p_ui_flag = 'Y' THEN

      Is_Cancel_OR_Delete
      ( p_line_id           => config_rec.line_id
       ,p_change_reason     => 'CONFIGURATOR'
       ,p_change_comments   => 'Changes in Configurator Window'
       ,x_cancellation      => l_cancellation
       ,x_line_rec          => l_line_rec);

    END IF;

    IF NOT l_cancellation THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DELETING LINE : ' || CONFIG_REC.LINE_ID ) ;
      END IF;

      l_line_rec.line_id   := config_rec.line_id;
      l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('LINE_ID TO BE DELETED: '||CONFIG_REC.LINE_ID,1);
      END IF;

      IF p_direct_save AND
         config_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS
      THEN
        l_class_line_count                     := l_class_line_count+1;
        p_x_class_line_tbl(l_class_line_count) := l_line_rec;
      ELSE
        l_line_count                           := l_line_count+1;
        p_x_line_tbl(l_line_count)             := l_line_rec;
      END IF;

    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'YES CANCELLATION' , 3 ) ;
      END IF;

      IF l_qty <> 0 OR
         p_ui_flag = 'Y' THEN
        l_line_rec.line_id               := config_rec.line_id;
        l_line_rec.operation             := OE_GLOBALS.G_OPR_UPDATE;
        l_line_rec.ordered_quantity      := 0;
        l_line_rec.change_reason         := 'SYSTEM';
        l_line_rec.change_comments       := 'Change Cascaded';

        IF p_direct_save AND
           config_rec.item_type_code =OE_GLOBALS.G_ITEM_CLASS
        THEN
          l_class_line_count                     := l_class_line_count+1;
          p_x_class_line_tbl(l_class_line_count) := l_line_rec;
        ELSE
          l_line_count                           := l_line_count+1;
          p_x_line_tbl(l_line_count)             := l_line_rec;
        END IF;

      END IF;
    END IF;

  END LOOP;

  Print_Time('Handle_Deletes_Old end time');
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN HANDLE_DELETES_OLD'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Handle_Deletes_Old;


/*--------------------------------------------------------------------
PROCEDURE Check_If_cancellation
This procedure is used to see if the deletion of the option/class
is actually a complete cancellation. If so, we will not delete
the lines from oe_order_lines and they will be closed instead.

Change Record:
bug 2191666: the sqls and logic modified when a class gets
cancelled as a result of cascading.
---------------------------------------------------------------------*/
PROCEDURE Check_If_cancellation
( p_line_id           IN  NUMBER
 ,p_top_model_line_id IN  NUMBER
 ,p_item_type_code    IN  VARCHAR2
 ,x_cancellation      OUT NOCOPY /* file.sql.39 change */ BOOLEAN
 ,x_current_quantity  OUT NOCOPY /* file.sql.39 change */ NUMBER)
IS
  l_open_flag        VARCHAR2(1);
  l_line_id          NUMBER;
  l_parent_line_id   NUMBER;
  l_ordered_quantity NUMBER := FND_API.G_MISS_NUM;
  l_component_code   VARCHAR2(1000);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING CHECK_IF_CANCELLATION ' || P_LINE_ID ,1);
  END IF;

  l_line_id        := p_line_id;
  l_parent_line_id := p_line_id;


  BEGIN
    SELECT ordered_quantity, open_flag, component_code
    INTO   l_ordered_quantity, l_open_flag, l_component_code
    FROM   oe_order_lines
    WHERE  line_id = l_line_id;

    IF l_ordered_quantity = 0 THEN
      IF l_open_flag = 'N' THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('THIS WAS A COMPLETE CANCELLATION'|| L_LINE_ID,3);
        END IF;
        x_cancellation     := TRUE;
        x_current_quantity := l_ordered_quantity;
        RETURN;
      ELSE
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('NOT COMPLETE CANCEL, SO DELETE'|| L_LINE_ID ,3);
        END IF;
        x_cancellation     := FALSE;
        x_current_quantity := l_ordered_quantity;
        RETURN;
      END IF;
    END IF;

  EXCEPTION
    WHEN no_data_found THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE NOT IN DB'|| L_LINE_ID , 1 ) ;
      END IF;
    WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OTHERS '|| L_LINE_ID || SQLERRM , 1 ) ;
     END IF;
     RAISE;
  END;

  -- if we came here, that is because of cascading effect not
  -- because the line itself is set to qty = 0.

  l_open_flag      := 'Y';

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('CHECK IF CHANGE CASCADED DOWN '||P_ITEM_TYPE_CODE ,3);
  END IF;

  WHILE l_open_flag = 'Y' AND
        l_parent_line_id <> p_top_model_line_id
  LOOP

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PARENT LINE ID: ' || L_PARENT_LINE_ID
                       || 'LINE ID: '|| L_LINE_ID , 3 ) ;
    END IF;

    SELECT link_to_line_id
    INTO   l_parent_line_id
    FROM   oe_order_lines
    WHERE  line_id = l_line_id;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CAME HERE '|| L_PARENT_LINE_ID , 3 ) ;
    END IF;

    l_line_id := l_parent_line_id;
    BEGIN

      SELECT open_flag
      INTO   l_open_flag
      FROM   oe_order_lines
      WHERE  line_id = l_parent_line_id;

    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OPTION: TOO MANY ROWS IN CHECK CANCEL' , 1 ) ;
        END IF;
        RAISE;

      WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OPTIONS PARENT NOT FOUND'|| L_OPEN_FLAG , 1 ) ;
        END IF;
        l_parent_line_id := p_top_model_line_id;
    END;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OPEN FLAG OF PARENT: '|| L_OPEN_FLAG , 3 ) ;
    END IF;

  END LOOP;

  IF p_item_type_code = OE_GLOBALS.G_ITEM_CLASS AND
     l_open_flag = 'Y'
  THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CHECK IF CHANGE CASCADED UPWARDS TO CLASS/KIT' ,1);
    END IF;

    -- this will happen only if the last option under this class
    -- is set to qty of 0.
    BEGIN

      SELECT   count(*)
      INTO     l_line_id
      FROM     oe_order_lines
      WHERE    top_model_line_id = p_top_model_line_id
      AND      link_to_line_id = p_line_id
      AND      open_flag = 'Y'
      AND      item_type_code IN ('CLASS', 'OPTION', 'KIT');

      SELECT   count(*)
      INTO     l_parent_line_id
      FROM     oe_order_lines
      WHERE    top_model_line_id = p_top_model_line_id
      AND      link_to_line_id = p_line_id
      AND      item_type_code IN ('CLASS', 'OPTION', 'KIT');

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NO. OF OPEN CHILD: '|| L_LINE_ID , 3 ) ;
      oe_debug_pub.add(  'NO. OF CHILD: '|| L_PARENT_LINE_ID , 3 ) ;
    END IF;

    IF l_parent_line_id = 0 THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IT IS A DELETE' , 1 ) ;
      END IF;
      l_open_flag := 'Y';
    ELSIF l_line_id = 0 THEN
      l_open_flag := 'N';
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IT IS A CANCELLATION' , 1 ) ;
      END IF;
    ELSE

      BEGIN
        SELECT count(*)
        INTO   l_line_id
        FROM   oe_order_lines
        WHERE  top_model_line_id = p_top_model_line_id
        AND    component_code like (l_component_code || '%')
        AND    open_flag = 'N'
        AND    cancelled_flag = 'Y'
        AND    item_type_code IN ('CLASS', 'OPTION', 'KIT');

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NO CANELLED LINES' , 2 ) ;
          END IF;
      END;

      IF l_line_id > 0 THEN
        l_open_flag := 'N';
      END IF;

    END IF;

    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'TOO MANY ROWS IN CHECK CANCELLATION' , 1 ) ;
        END IF;
        RAISE;

      WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OTHERS CLASS/KIT'|| L_LINE_ID || SQLERRM , 1 ) ;
        END IF;
        RAISE;
    END;

  END IF;

  x_current_quantity := l_ordered_quantity;

  IF l_open_flag = 'N' THEN
    x_cancellation := TRUE;
  ELSE
    x_cancellation := FALSE;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LEAVING CHECK_IF_CANCELLATION ' || L_OPEN_FLAG , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN CHECK_IF_CANCELLATION'|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Check_If_cancellation;


/*------------------------------------------------------------
PROCEDURE:  Call_Process_Order
            helper to call process_order

The direct operation of update and delete should not
happen, no records should be in class_tbl for update
and delete, since a a value of FALSE is passes to
handle_updates and handle_deletes.

We set a bunch of globals before and after call to lines.
  in a delayed request, process order calls batch validate.
  after batch validation we might insert/update/delete  option
  &/ classes.
  because of this change there should not be again a delayed request
  for batch validation. hence a global OECFG_VALIDATE_CONFIG varchar2(1)
  will be reset and set before and after a call to process_order resp.
  also we do not wnat to cascade here,
  set OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG := 'Y' before the call
  oe_config_ui_used: idicates, options window/configurator call.
  There are some other flags also.

Change Record:
added Insert_into_Set call
 If the parent is in fulfillment set then push the child
 into same fulfillment set. This will handle cases that
 are not calling Lines procedure and doing direct inserts
 into the the table.

MACD: Modified the control record to pass security
---------------------------------------------------------------*/

PROCEDURE Call_Process_Order
( p_line_tbl          IN  OUT NOCOPY  OE_Order_Pub.Line_Tbl_Type
 ,p_class_line_tbl    IN  OE_Order_Pub.Line_Tbl_Type
                          := OE_ORDER_PUB.G_MISS_LINE_TBL
 ,p_control_rec       IN  OUT NOCOPY  OE_GLOBALS.Control_Rec_Type
 ,p_ui_flag           IN  VARCHAR2    := 'N'
 ,p_top_model_line_id IN  NUMBER      := null
 ,p_config_hdr_id     IN  NUMBER      := null
 ,p_config_rev_nbr    IN  NUMBER      := null
 ,p_update_columns    IN  BOOLEAN     := FALSE
 ,x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  -- process_order in variables
  I                               NUMBER;
  l_line_rec                      OE_Order_PUB.Line_Rec_Type;
  l_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
  l_old_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);
  l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_index                         NUMBER;
  l_return_code                   NUMBER;  --Bug 4165102
  l_error_buffer                  VARCHAR2(240); --Bug 4165102

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'IN CALL_PROCESS_ORDER '|| P_LINE_TBL.COUNT , 1 ) ;
  END IF;

  IF p_control_rec.check_security IS NULL THEN
    p_control_rec.check_security := TRUE;
  END IF;

  IF p_control_rec.process IS NULL THEN
    IF p_ui_flag = 'Y' THEN
      p_control_rec.process := TRUE;
    ELSE
      p_control_rec.process := FALSE;
    END IF;
  END IF;

  IF p_line_tbl.COUNT > 0 THEN

    -- caller set the security and procees flags on ctrl rec.
    p_control_rec.default_attributes   := TRUE;
    p_control_rec.controlled_operation := TRUE;
    p_control_rec.change_attributes    := TRUE;
    p_control_rec.validate_entity      := TRUE;
    p_control_rec.write_to_DB          := TRUE;
    p_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE;

    -- change made for bug 2350478
    IF p_ui_flag = 'Y' THEN
      OE_CONFIG_PVT.OECFG_CONFIGURATION_PRICING := 'Y';
    END IF;

    --OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG := 'Y';
    OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG := 'N';

    IF p_ui_flag = 'Y' THEN
      OE_CONFIG_UTIL.G_CONFIG_UI_USED := 'Y';
    END IF;

    fnd_profile.put('OE_CALCULATE_TAX_IN_OM', 'N');

    Print_Time('call to lines start time');
    OE_Order_Pvt.Lines
    (   p_validation_level  => FND_API.G_VALID_LEVEL_NONE
    ,   p_control_rec       => p_control_rec
    ,   p_x_line_tbl        => p_line_tbl
    ,   p_x_old_line_tbl    => l_old_line_tbl
    ,   x_return_status     => l_return_status);
    Print_Time('call to lines end time');

    -- OE_GLOBALS.G_RECURSION_MODE := 'N';
    --OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG := 'N';
    OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG := 'Y';
    OE_CONFIG_PVT.OECFG_CONFIGURATION_PRICING := 'N';
    OE_CONFIG_UTIL.G_CONFIG_UI_USED := 'N';

    fnd_profile.put('OE_CALCULATE_TAX_IN_OM', 'Y');

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; -- count > 0



  ----------------------------------------------------------------------
  -- Direct insert/update/delete
  ----------------------------------------------------------------------

  Print_Time('direct ins/upd/del start time');

  l_index := l_line_tbl.COUNT;

  IF nvl(p_class_line_tbl.count, -1) > 0 AND p_ui_flag = 'Y' THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('DIRECT OP ON CLASS: '|| P_CLASS_LINE_TBL.COUNT ,1);
    END IF;

    I := p_class_line_tbl.FIRST;

    WHILE I is not NULL
    LOOP

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('I: '|| P_CLASS_LINE_TBL ( I ) .LINE_ID , 1 ) ;
        END IF;
        l_line_rec := p_class_line_tbl(I);

        IF l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

          /* Bug 4165102 : Call to Globalization hook is included for class lines
           * if the profile option 'OM: Configuration Quick Save' is set to Yes.
           * Note: JG API defaults global_attributes ,only if they are passed as
           * NULL.
           */
          l_line_rec.global_attribute1 := NULL;
          l_line_rec.global_attribute2 := NULL;
          l_line_rec.global_attribute3 := NULL;
          l_line_rec.global_attribute4 := NULL;
          l_line_rec.global_attribute5 := NULL;
          l_line_rec.global_attribute6 := NULL;
          l_line_rec.global_attribute7 := NULL;
          l_line_rec.global_attribute8 := NULL;
          l_line_rec.global_attribute9 := NULL;
          l_line_rec.global_attribute10 := NULL;
          l_line_rec.global_attribute11 := NULL;
          l_line_rec.global_attribute12 := NULL;
          l_line_rec.global_attribute13 := NULL;
          l_line_rec.global_attribute14 := NULL;
          l_line_rec.global_attribute15 := NULL;
          l_line_rec.global_attribute16 := NULL;
          l_line_rec.global_attribute17 := NULL;
          l_line_rec.global_attribute18 := NULL;
          l_line_rec.global_attribute19 := NULL;
          l_line_rec.global_attribute20 := NULL;
          l_line_rec.global_attribute_category := NULL;

          IF l_debug_level > 0 THEN
             OE_DEBUG_PUB.Add('Before calling JG ',2);
          END IF;

          JG_ZZ_OM_COMMON_PKG.default_gdf
             (x_line_rec     => l_line_rec,
              x_return_code  => l_return_code,
              x_error_buffer => l_error_buffer);

          IF l_debug_level > 0 THEN
             OE_DEBUG_PUB.Add('After JG Call:'|| l_return_code || l_error_buffer,2);
          END IF;


          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('INSERT: ' || L_LINE_REC.COMPONENT_CODE , 1 ) ;
          END IF;

          OE_Line_Util.Insert_Row( p_line_rec => l_line_rec);

          OE_Default_Line.Insert_into_set
          (p_line_id         => l_line_rec.top_model_line_id,
           p_child_line_id   => l_line_rec.line_id,
           x_return_status   => l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;
           -- Bug 5912216: Start the line level workflows for config child
           -- lines only in case of normal sales order lines, NOT
           -- when processing negotiation lines.
           IF ( Nvl(l_line_rec.transaction_phase_code, 'F') <> 'N' ) THEN
             OE_Order_WF_Util.CreateStart_LineProcess(l_line_rec);
           END IF;

        ELSIF l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('UPDATE: ' || L_LINE_REC.LINE_ID , 1 ) ;
          END IF;

          UPDATE oe_order_lines
          SET    ordered_quantity = l_line_rec.ordered_quantity
          WHERE  line_id = l_line_rec.line_id;

        ELSIF l_line_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('DELETE: ' || L_LINE_REC.LINE_ID , 1 ) ;
          END IF;

          DELETE FROM oe_order_lines
          WHERE  line_id = l_line_rec.line_id;

        ELSE
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('OPERATION: '|| L_LINE_REC.OPERATION , 1 ) ;
          END IF;
        END IF;

        l_index := l_index + 1;
        l_line_tbl(l_index) := l_line_rec;

        I := p_class_line_tbl.NEXT(I);
    END LOOP;

    Print_Time('direct ins/upd/del end time');
  END IF;


  ---------------------------------------------------------------------
  -- call to update link_to_line_id, ato_line_id etc.
  ---------------------------------------------------------------------
  IF p_update_columns = TRUE THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CALLING CHANGE COLUMNS' , 2 ) ;
      END IF;

      oe_config_pvt.Change_Columns
      (p_top_model_line_id  => p_top_model_line_id,
       p_config_hdr_id      => p_config_hdr_id,
       p_config_rev_nbr     => p_config_rev_nbr,
       p_ui_flag            => p_ui_flag);

      -- for bug 2247331
      oe_service_util.Update_Service_Option_Numbers
      (p_top_model_line_id  => p_top_model_line_id);

  END IF;


  ---------------------------------------------------------------------
  -- call to process_request_and_notify
  ---------------------------------------------------------------------

  Print_Time('Process_Requests_And_notify call start time');
  IF p_ui_flag = 'Y' AND
     p_line_tbl.COUNT > 0 THEN

  IF (p_line_tbl(1).booked_flag = 'Y') THEN
   OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_PRICE_ORDER
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
   END IF;

    OE_ORDER_PVT.Process_Requests_And_notify
    ( p_process_requests       => TRUE
     ,p_notify                 => TRUE
     ,x_return_status          => l_return_status
     ,p_line_tbl               => l_line_tbl
     ,p_old_line_tbl           => l_old_line_tbl);

    Print_Time('Process_Requests_And_notify call end time');
  END IF;


  oe_msg_pub.count_and_get
  ( p_count      => l_msg_count
   ,p_data       => l_msg_data  );


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('AFTER CALLING PROCESS ORDER' , 1 ) ;
    oe_debug_pub.add('L_RETURN_STATUS IS ' || L_RETURN_STATUS , 1 ) ;
  END IF;

  x_return_status := l_return_status;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING CALL_PROCESS_ORDER' , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN CALL_PROCESS_ORDER: '|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Call_Process_Order;


/*----------------------------------------------------------------
Procedure Name : Change_Columns
Description    :
  Update link_to_line_id, ATO_line_id, option_number
  config_header_id and config_rev_nbr of model/class/option
  after updating ato_linr_id, for ato's under pto,
  default stuff.
  update lock_control, once is enough, however if
  p_config_flag is 'N', that is why also update in
  option_number update.
  we can set config_hdr and rev in the line_rec passed
  to process_order. But that will change the hdr and revb
  of only those options that got updated/newly inserted
  not all the options of this model.

  change columns updates:
  column                              when do we want to update
  ------------------------------      ----------------------------
  link_to_line_id                     => creates
  ato_line_id                         => creates
  option_number                       => creates/deletes
  config_header_id, config_rev_nbr    => always

  p_operation : C for create
                D for delete
                A for all (proportional split, copy config calls)
Change Record :
Bug-2405271   : Update Option numbers for Config Item
Bug-3318910   : Update config hdr/rev/id only if top level is MODEL
Bug-3082485   : validation of decimal ratio for options to classes
Bug-3700148   : do not do ratio check if model is remnant
-----------------------------------------------------------------*/

Procedure Change_Columns
(p_top_model_line_id IN NUMBER,
 p_config_hdr_id     IN NUMBER,
 p_config_rev_nbr    IN NUMBER,
 p_ui_flag           IN VARCHAR2 := 'N',
 p_operation         IN VARCHAR2 := 'A')
IS
  l_line_id                   NUMBER;
  l_option_nbr                NUMBER := 0;
  l_link                      NUMBER;
  l_line_count                NUMBER := 0;

  l_model_item_type_code      VARCHAR2(30);
  l_item_type_code            VARCHAR2(30);
  l_model_ato_line_id         NUMBER;
  l_prev_config_header_id     NUMBER;
  l_prev_config_rev_nbr       NUMBER;
  l_remnant_flag              VARCHAR2(1);
  l_configuration_id          NUMBER;
  l_child_ordered_quantity    NUMBER ;
  l_parent_ordered_quantity   NUMBER ;
  l_child_ordered_item        VARCHAR2(200);
  l_parent_ordered_item       VARCHAR2(200);
  l_parent_item_type_code     VARCHAR2(30);
  l_child_inv_item_id         NUMBER ;
  l_parent_inv_item_id        NUMBER ;
  l_ato_line_id               NUMBER ;
  l_ratio_check               VARCHAR2(1);
  l_indivisible_flag          VARCHAR2(1);

  -- option_number of config, talk to PM
  -- 3082485- changing the cursor to chose ordered_quantity ,
  -- ato_line_id , inventory item id and ordered item
  CURSOR option_nbr IS
  SELECT line_id, link_to_line_id, item_type_code,ordered_quantity,
         ato_line_id,inventory_item_id,ordered_item
  FROM   oe_order_lines
  WHERE  top_model_line_id = p_top_model_line_id
  AND    line_id <> p_top_model_line_id
  AND    service_reference_line_id is null
  AND    item_type_code <> OE_GLOBALS.G_ITEM_INCLUDED
  AND    item_type_code <> OE_GLOBALS.G_ITEM_CONFIG
  order by sort_order;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  Print_Time('Entering Change_Columns');

  BEGIN
    SELECT item_type_code, ato_line_id, config_header_id, config_rev_nbr,
           nvl(model_remnant_flag, 'N')
    INTO   l_model_item_type_code , l_model_ato_line_id,
           l_prev_config_header_id, l_prev_config_rev_nbr,
           l_remnant_flag
    FROM   oe_order_lines
    WHERE line_id = p_top_model_line_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('EXCEPTION IN QUERY MODEL ATTIRBS' , 1 ) ;
      END IF;
      RAISE;
  END;


  --/*************** config ids *********************/

  IF l_remnant_flag = 'N' AND
     l_model_item_type_code = 'MODEL' THEN
    IF p_config_hdr_id is NULL THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OPTIONS WINDOW , CONFIGURATION ID' , 1 ) ;
      END IF;

      UPDATE oe_order_lines
      SET    configuration_id  = nvl(configuration_id, 0) + 1,
             lock_control      = lock_control + 1
      WHERE  top_model_line_id = p_top_model_line_id
      AND    item_type_code IN ('MODEL', 'CLASS', 'OPTION', 'KIT');

    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_CONFIG_HDR_ID || ' ' || P_CONFIG_REV_NBR , 1 ) ;
        oe_debug_pub.add(  L_PREV_CONFIG_HEADER_ID
                           ||' '||L_PREV_CONFIG_REV_NBR , 1 ) ;
      END IF;

      UPDATE oe_order_lines
      SET    config_header_id  = p_config_hdr_id,
             config_rev_nbr    = p_config_rev_nbr,
             lock_control      = lock_control + 1
      WHERE  top_model_line_id = p_top_model_line_id
      AND    item_type_code IN ('MODEL', 'CLASS', 'OPTION', 'KIT');
    END IF;
  END IF; -- remnant flag = N

  --/*** update ato line_id and related attributes for subconfig **/

  IF (p_operation = 'C' OR p_operation = 'A') AND
     l_model_item_type_code =  OE_GLOBALS.G_ITEM_MODEL AND
     l_model_ato_line_id    is NULL
  THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('UPDATE ATO ATTRIBS FOR SUBASSEMBLIES' , 1 ) ;
    END IF;
    update_ato_line_attributes( p_top_model_line_id => p_top_model_line_id
                               ,p_ui_flag           => p_ui_flag
                               ,p_config_hdr_id     => p_config_hdr_id);

    --## bug fix 1643546, added new and condition ##1820608
    UPDATE oe_order_lines
    SET    shippable_flag = 'N'
    WHERE  top_model_line_id = p_top_model_line_id
    AND    ato_line_id is NOT NULL
    AND    item_type_code <> OE_GLOBALS.G_ITEM_CONFIG
    AND    NOT (item_type_code = OE_GLOBALS.G_ITEM_OPTION AND
                ato_line_id    = line_id);
  END IF;


  --/************* update link_to_line_id *****************/

  IF p_operation = 'C' OR
     p_operation = 'A' THEN
    update_link_to_line_id
    ( p_top_model_line_id => p_top_model_line_id
     ,p_remnant_flag      => l_remnant_flag
     ,p_config_hdr_id     => p_config_hdr_id);
  END IF;


  --/************* update option_number *****************/

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('UPDATING OPTION_NUMBER IN OE_ORDER_LINES' , 1 ) ;
  END IF;

  OPEN option_nbr;
  LOOP
    FETCH option_nbr into l_line_id, l_link, l_item_type_code,
          l_child_ordered_quantity, l_ato_line_id,
          l_child_inv_item_id,l_child_ordered_item;
    EXIT when option_nbr%notfound;

    l_option_nbr := l_option_nbr + 1;

    UPDATE oe_order_lines
    SET    option_number = l_option_nbr,
           lock_control  = lock_control + 1
    WHERE  line_id = l_line_id;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('FOR '|| L_LINE_ID || ' LLID '|| L_LINK , 3 ) ;
    END IF;

    -- 3082485
    IF l_link <> p_top_model_line_id AND
       p_config_hdr_id is NULL AND
       l_remnant_flag = 'N' THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('do we need to check ration with parent' , 3 ) ;
      END IF;

      l_ratio_check := 'Y';

      IF  l_ato_line_id is not null AND
          l_item_type_code = 'OPTION' AND
          l_ato_line_id <> l_line_id THEN

        SELECT INDIVISIBLE_FLAG
        INTO   l_indivisible_flag
        FROM   mtl_system_items
        WHERE  inventory_item_id = l_child_inv_item_id
        AND    organization_id   =
               OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

        IF nvl(l_indivisible_flag, 'N') = 'N' THEN
          IF l_debug_level  > 0 THEN
            OE_DEBUG_PUB.ADD('this Option can have decimal ratio', 1);
          END IF;

          l_ratio_check := 'N';
        ELSE
          IF l_debug_level  > 0 THEN
            OE_DEBUG_PUB.ADD('this Option can not have decimal ratio', 1);
          END IF;
        END IF;
      END IF;


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('check ration with parent '|| l_ratio_check , 3 ) ;
      END IF;

      IF l_ratio_check = 'Y' THEN

        SELECT ordered_quantity,ordered_item,
               item_type_code,inventory_item_id
        INTO   l_parent_ordered_quantity,l_parent_ordered_item,
               l_parent_item_type_code, l_parent_inv_item_id
        FROM   OE_ORDER_LINES
        WHERE  line_id = l_link;

        IF mod(l_child_ordered_quantity,l_parent_ordered_quantity) <> 0
        THEN

          FND_MESSAGE.SET_NAME('ONT', 'OE_CONFIG_DECIMAL_RATIO');
          FND_MESSAGE.Set_TOKEN
          ('ITEM', nvl(l_child_ordered_item,l_child_inv_item_id));
          FND_MESSAGE.Set_TOKEN
          ('TYPECODE',l_item_type_code);
          FND_MESSAGE.Set_TOKEN
         ('VALUE',to_char(l_child_ordered_quantity/l_parent_ordered_quantity));
          FND_MESSAGE.Set_TOKEN
          ('MODEL', nvl(l_parent_ordered_item,l_parent_inv_item_id));
          FND_MESSAGE.Set_TOKEN('PTYPECODE', l_parent_item_type_code);
          OE_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR ;
        END IF;

      END IF; -- ratio check
    END IF; -- options window
    -- fix for 3082485 ends


    IF l_model_ato_line_id is NULL AND
       (l_item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
        l_item_type_code = OE_GLOBALS.G_ITEM_KIT)
    THEN
      BEGIN
        UPDATE oe_order_lines
        SET    option_number = l_option_nbr,
               lock_control  = lock_control + 1
        WHERE  top_model_line_id = p_top_model_line_id
        AND    link_to_line_id   = l_line_id
        AND    item_type_code    = 'INCLUDED';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('NO INCLUDED ITEMS' , 3 ) ;
          END IF;
      END;

      BEGIN
        UPDATE oe_order_lines
        SET    option_number = l_option_nbr,
               lock_control  = lock_control + 1
        WHERE  top_model_line_id = p_top_model_line_id
        AND    ato_line_id       = l_line_id
        AND    item_type_code    = 'CONFIG';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('NO CONFIG ITEMS' , 3 ) ;
          END IF;
      END;

    END IF;
  END LOOP;

  CLOSE option_nbr;

  IF l_model_ato_line_id is NULL THEN

    UPDATE oe_order_lines o
    SET   ordered_quantity =
      (SELECT ordered_quantity
       FROM   oe_order_lines
       WHERE  line_id = o.link_to_line_id)
    WHERE top_model_line_id = p_top_model_line_id
    AND   item_type_code = OE_GLOBALS.G_ITEM_CONFIG
    AND   nvl(model_remnant_flag, 'N') = 'N';

    UPDATE oe_order_lines
    SET    cancelled_flag = 'Y'
    WHERE  top_model_line_id = p_top_model_line_id
    AND    item_type_code = 'CONFIG'
    AND    ordered_quantity = 0;


  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING CHANGE_COLUMNS IN OE_CONFIG_PVT' , 1 ) ;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXC ERROR IN CHANGE_COLUMNS IN OE_CONFIG_PVT' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR IN CHANGE_COLUMNS IN OE_CONFIG_PVT' , 1 ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Change_Columns;


/*----------------------------------------------------------------
Procedure : update_link_to_line_id
OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' : Pack H
-----------------------------------------------------------------*/
Procedure update_link_to_line_id
( p_top_model_line_id  IN  NUMBER
 ,p_remnant_flag       IN  VARCHAR2
 ,p_config_hdr_id      IN  NUMBER)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('UPDATING LINK_TO_LINE_ID '|| P_REMNANT_FLAG , 1 ) ;
    oe_debug_pub.add(  P_CONFIG_HDR_ID || ' MODEL: '|| P_TOP_MODEL_LINE_ID ,1);
  END IF;

  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('1 LLID: PACK H NEW LOGIC FOR SPLIT ' , 1 ) ;
    END IF;

    UPDATE  oe_order_lines OEOPT
    SET     link_to_line_id =
            (SELECT line_id
             FROM    oe_order_lines oe1
             WHERE   split_from_line_id =
            (SELECT link_to_line_id
             FROM   oe_order_lines oe2
             WHERE  line_id = OEOPT.split_from_line_id
             AND    oe2.open_flag           = 'Y')
             AND    oe1.top_model_line_id   =  p_top_model_line_id
             AND    oe1.open_flag           = 'Y' )
    WHERE  OEOPT.top_model_line_id  =  p_top_model_line_id
    AND    OEOPT.line_id            <> p_top_model_line_id
    AND    OEOPT.link_to_line_id     is NULL
    AND    OEOPT.split_from_line_id is NOT NULL
    AND    OEOPT.open_flag           = 'Y';

    IF SQL%FOUND THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('1 LLID UPDATED ' || SQL%ROWCOUNT ) ;
      END IF;
    END IF;

  END IF;


  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' AND
     p_config_hdr_id is NOT NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('2 LLID: PACK H NEW LOGIC MI '|| P_REMNANT_FLAG , 1 ) ;
    END IF;

    UPDATE  oe_order_lines OEOPT
    SET     link_to_line_id =
    ( SELECT line_id
      FROM   oe_order_lines OELNK
      WHERE  OELNK.top_model_line_id = OEOPT.top_model_line_id
      AND OELNK.configuration_id =
      ( SELECT parent_config_item_id
        FROM   cz_config_details_v
        WHERE  config_hdr_id  = OELNK.config_header_id
        AND    config_rev_nbr = OELNK.config_rev_nbr
        AND    config_item_id = OEOPT.configuration_id
      )
      AND OELNK.open_flag = 'Y'
    )
    WHERE  OEOPT.top_model_line_id =  p_top_model_line_id
    AND    OEOPT.line_id           <> p_top_model_line_id
    AND    OEOPT.link_to_line_id   IS NULL;

    IF SQL%FOUND THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('2 LLID UPDATED ' || SQL%ROWCOUNT ) ;
      END IF;
    END IF;

  ELSE

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LLID OPTIONS WINDOW OR OLD LOGIC ' , 3 ) ;
    END IF;

    UPDATE  oe_order_lines OEOPT
    SET     link_to_line_id =
    ( SELECT  OELNK.line_id
      FROM    oe_order_lines OELNK
      WHERE   (( OELNK.line_id = oeopt.top_model_line_id OR
                 OELNK.top_model_line_id = OEOPT.top_model_line_id ))
      AND     (OELNK.component_code =  SUBSTR( OEOPT.component_code,1,
               LENGTH( RTRIM( OEOPT.component_code,'0123456789' )) - 1)
      OR      (OELNK.component_code  = OEOPT.component_code AND
               OEOPT.item_type_code  = OE_GLOBALS.G_ITEM_MODEL))
      AND     open_flag = 'Y'
    )
    WHERE  OEOPT.top_model_line_id =  p_top_model_line_id
    AND    OEOPT.line_id           <> p_top_model_line_id
    AND    OEOPT.link_to_line_id   IS NULL
    AND    OEOPT.item_type_code <> OE_GLOBALS.G_ITEM_INCLUDED;

    IF SQL%FOUND THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('3 LLID UPDATED ' || SQL%ROWCOUNT ) ;
      END IF;
    END IF;

    -- only in a post split situation.

    UPDATE  oe_order_lines OEOPT
    SET     link_to_line_id =
            (SELECT line_id
             FROM    oe_order_lines oe1
             WHERE   split_from_line_id =
             (SELECT link_to_line_id
              FROM   oe_order_lines oe2
              WHERE  line_id = OEOPT.split_from_line_id
              AND    oe2.open_flag           = 'Y')
              AND    oe1.top_model_line_id   =  p_top_model_line_id
              AND    oe1.open_flag           = 'Y' )
    WHERE  OEOPT.top_model_line_id  =  p_top_model_line_id
    AND    OEOPT.line_id            <> p_top_model_line_id
    AND    OEOPT.item_type_code      = OE_GLOBALS.G_ITEM_INCLUDED
    AND    OEOPT.link_to_line_id     is NULL
    AND    OEOPT.split_from_line_id is NOT NULL
    AND    OEOPT.open_flag           = 'Y';

    IF SQL%FOUND THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('1 LLID UPDATED ' || SQL%ROWCOUNT ) ;
      END IF;
    END IF;

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('UPDATED LINK_TO_LINE_ID IN OE_ORDER_LINES' , 2 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR IN UPDATE_LINK_TO_LINE_ID' || SQLERRM , 1 ) ;
    END IF;
    RAISE;
END update_link_to_line_id;


/*----------------------------------------------------------------
Procedure : update_ato_line_attributes

Change Record:
bug 1894331
  the select statement for getting ato_line_id in case of
  pto+ato case is modified. look at the bug for more details.
  also made same change in OEXDLINB.pls:get_ato_line.

bug 2143052: added open_flag to cursors.

From mi project, we have decided that ato_line_id will not be
updated if the model is remnant here. The ato_line_id populated
by SPLIT defaulting remains.
-----------------------------------------------------------------*/
Procedure update_ato_line_attributes
( p_top_model_line_id   IN  NUMBER
 ,p_ui_flag             IN  VARCHAR2
 ,p_config_hdr_id       IN  NUMBER)
IS
  l_component_code            varchar2(1000);
  l_project_id                number;
  l_task_id                   number;
  l_ship_from_org_id          number;
  l_ship_to_org_id            number;
  l_schedule_ship_date        date;
  l_schedule_arrival_date     date;
  l_request_date              date;
  l_shipping_method_code      varchar2(30);
  l_freight_carrier_code      varchar2(30);
  l_ato_line_id               number;
  l_option_line_id            number;
  l_ato_line_rec              OE_ORDER_PUB.Line_Rec_Type;
  l_line_rec                  OE_ORDER_PUB.Line_Rec_Type;
  l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
  l_old_line_tbl              OE_Order_PUB.Line_Tbl_Type;
  l_control_rec               OE_GLOBALS.Control_Rec_Type;
  l_line_count                NUMBER := 0;
  l_return_status             VARCHAR2(1);

  -- cursor modified, ## 1820608

  CURSOR ATO_MODELS IS
  SELECT unique(ato_line_id)
  FROM   oe_order_lines_all
  WHERE  top_model_line_id = p_top_model_line_id
  AND    ato_line_id is not null
  AND    item_type_code = OE_GLOBALS.G_ITEM_CLASS
  AND    open_flag = 'Y'; -- ato subconfigs

  CURSOR ATO_OPTIONS(p_ato_line_id       IN NUMBER)
  IS
  SELECT opt.line_id
  FROM   oe_order_lines_all opt, oe_order_lines_all ato_model
  WHERE  opt.top_model_line_id       = p_top_model_line_id AND
         ato_model.top_model_line_id = p_top_model_line_id AND
         ato_model.line_id           = p_ato_line_id AND
         opt.open_flag               = 'Y'           AND
         opt.ato_line_id             = p_ato_line_id AND
         (nvl(ato_model.project_id,-1) <>
          nvl(opt.project_id,-1) OR

          nvl(ato_model.task_id,-1) <>
          nvl(opt.task_id,-1) OR

          nvl(ato_model.ship_from_org_id,-1) <>
          nvl(opt.ship_from_org_id,-1) OR

          nvl(ato_model.ship_to_org_id,-1) <>
          nvl(opt.ship_to_org_id,-1) OR

          nvl(ato_model.schedule_ship_date,SYSDATE) <>
          nvl(opt.schedule_ship_date,SYSDATE) OR

          nvl(ato_model.schedule_arrival_date,SYSDATE) <>
          nvl(opt.schedule_arrival_date,SYSDATE) OR

          nvl(ato_model.request_date,SYSDATE) <>
          nvl(opt.request_date,SYSDATE) OR

          nvl(ato_model.shipping_method_code,'-') <>
          nvl(opt.shipping_method_code,'-') OR

          nvl(ato_model.freight_carrier_code,'-') <>
          nvl(opt.freight_carrier_code,'-') );

          --
          l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
          --
BEGIN

  BEGIN
    -- If the model line is not ATO, then for all ATO lines, set the
    -- ATO_LINE_ID to the "highest" ATO line

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('UPDATING ATO_LINE_ID IN FOR SUBASSEMBLIES' , 1 ) ;
    END IF;


    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' AND
       p_config_hdr_id is NOT NULL
    THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('UPDATE_ATO: PACK H NEW LOGIC MI' , 1 ) ;
      END IF;

      UPDATE oe_order_lines OEOPT
      SET    ato_line_id =
      ( SELECT line_id
        FROM    oe_order_lines OEATO
        WHERE   OEOPT.top_model_line_id = OEATO.top_model_line_id
        AND     OEATO.configuration_id =
                (SELECT  ato_config_item_id
                 FROM    cz_config_details_v
                 WHERE   config_hdr_id  = OEOPT.config_header_id
                 AND     config_rev_nbr = OEOPT.config_rev_nbr
                 AND     config_item_id = OEOPT.configuration_id)
        AND      OEATO.open_flag = 'Y'
      )
      WHERE  TOP_MODEL_LINE_ID = p_top_model_line_id
      AND NOT (item_type_code = 'OPTION' AND
               ato_line_id    = line_id AND
               ato_line_id is not null)
      AND item_type_code <> 'CONFIG' -- not config line important.
      AND nvl(model_remnant_flag, 'N') = 'N'
      AND ordered_quantity > 0;
      -- model remnant condition important

      IF SQL%FOUND THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('NEW ATO_LINE UPDATED ' || SQL%ROWCOUNT ) ;
        END IF;
      ELSE
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('DID NOT UPDATE ANY LINE WITH ATO' ) ;
        END IF;
      END IF;

      -- note that the CONFIG line needs ato_line_id after
      -- proportional split.

      UPDATE  oe_order_lines OEOPT
      SET     ato_line_id =
              (SELECT line_id
               FROM   oe_order_lines oe1
               WHERE  split_from_line_id =
              (SELECT ato_line_id
               FROM   oe_order_lines oe2
               WHERE  line_id = OEOPT.split_from_line_id
               AND    oe2.open_flag           = 'Y')
               AND    oe1.top_model_line_id   =  p_top_model_line_id
               AND    oe1.open_flag           = 'Y' )
      WHERE  OEOPT.top_model_line_id  =  p_top_model_line_id
      AND    OEOPT.line_id            <> p_top_model_line_id
      AND    OEOPT.split_from_line_id is NOT NULL
      AND    OEOPT.open_flag           = 'Y'
      AND    OEOPT.item_type_code = 'CONFIG'
      AND    OEOPT.ato_line_id is null;

      IF SQL%FOUND THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add
          ('DUE TO MI: ATO LINE SPLIT FOR CONFIG ' || SQL%ROWCOUNT ) ;
        END IF;
      END IF;

    ELSE
      -- in case of ato', all of the lines will be remanant or
      -- or none. we do not have choice here, even options window
      -- will have this change.

      UPDATE  oe_order_lines OEOPT
      SET     ato_line_id =
              (SELECT line_id
               FROM   oe_order_lines oe1
               WHERE  split_from_line_id =
              (SELECT ato_line_id
               FROM   oe_order_lines oe2
               WHERE  line_id = OEOPT.split_from_line_id
               AND    oe2.open_flag           = 'Y')
               AND    oe1.top_model_line_id   =  p_top_model_line_id
               AND    oe1.open_flag           = 'Y' )
      WHERE  OEOPT.top_model_line_id  =  p_top_model_line_id
      AND    OEOPT.line_id            <> p_top_model_line_id
      AND    OEOPT.split_from_line_id is NOT NULL
      AND    OEOPT.open_flag           = 'Y'
      AND    OEOPT.model_remnant_flag = 'Y'
      AND    NOT (item_type_code = 'OPTION' AND
                  ato_line_id    = line_id AND
                  ato_line_id is not null);

      IF SQL%FOUND THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('DUE TO MI: ATO_LINE SPLIT' || SQL%ROWCOUNT ) ;
        END IF;
      ELSE

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OLD ATO_LINE_ID / NOT SPLIT' , 1 ) ;
        END IF;

        UPDATE OE_ORDER_LINES_ALL OEOPT
        SET    ATO_LINE_ID =
              ( SELECT OEATO.LINE_ID
                FROM   OE_ORDER_LINES_ALL OEATO
                WHERE  OEATO.TOP_MODEL_LINE_ID =
                       OEOPT.TOP_MODEL_LINE_ID
                AND    ITEM_TYPE_CODE = 'CLASS'
                AND    OEATO.COMPONENT_CODE =
                       SUBSTR( OEOPT.COMPONENT_CODE, 1,
                               LENGTH( OEATO.COMPONENT_CODE )
                              )
                AND OEATO.inventory_item_id =
                    ( SELECT inventory_item_id
                      FROM mtl_system_items
                      WHERE inventory_item_id =
                      OEATO.inventory_item_id
                      AND organization_id =
                      OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID')
                      AND replenish_to_order_flag = 'Y'
                     )
                AND    OEATO.COMPONENT_CODE =
                     ( SELECT MIN( OEMIN.COMPONENT_CODE )
                       FROM   OE_ORDER_LINES_ALL OEMIN
                       WHERE  OEMIN.TOP_MODEL_LINE_ID
                       = OEOPT.TOP_MODEL_LINE_ID
                       AND    OEMIN.COMPONENT_CODE =
                       SUBSTR( OEOPT.COMPONENT_CODE, 1,
                       LENGTH( OEMIN.COMPONENT_CODE ))
                       AND OEMIN.inventory_item_id =
                      ( SELECT inventory_item_id
                        FROM mtl_system_items
                        WHERE inventory_item_id =
                        OEMIN.inventory_item_id
                        AND organization_id =
                        OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID')
                        AND replenish_to_order_flag = 'Y'
                       )
                      )
                 AND ((SUBSTR(OEOPT.component_code,
                       LENGTH(OEATO.component_code) + 1, 1) = '-' OR
                       SUBSTR(OEOPT.component_code,
                       LENGTH(OEATO.component_code) + 1, 1) is NULL)
                      )
                     )
        WHERE  TOP_MODEL_LINE_ID = p_top_model_line_id
        AND NOT (item_type_code = 'OPTION' AND
                 ato_line_id    = line_id AND
                 ato_line_id is not null);

        IF SQL%FOUND THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('OLD ATO_LINE UPDATED ' || SQL%ROWCOUNT ) ;
          END IF;
        END IF;

      END IF; -- split or not

    END IF; -- pack H or not

  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('UNEXPECTED ERROR IN UPDATE ATO_LINE_ID' , 1 ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  ------------------------------------------------------------------

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add
    ('UPDATING OTHER ATTRIBUTES ON OPTIONS/CLASSES OF SUBASSEMBLIES' , 1);
  END IF;

  OPEN ATO_MODELS;
  LOOP
    FETCH ATO_MODELS INTO l_ato_line_id;
    EXIT WHEN ATO_MODELS%NOTFOUND;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ATO LINE: ' || L_ATO_LINE_ID , 1 ) ;
    END IF;

    OE_LINE_UTIL.Lock_Row
    (p_line_id       => l_ato_line_id
    ,p_x_line_rec    => l_ato_line_rec
    ,x_return_status => l_return_status);

    OPEN ATO_OPTIONS(l_ato_line_id);
    LOOP
      FETCH ATO_OPTIONS INTO l_option_line_id;
      EXIT WHEN ATO_OPTIONS%NOTFOUND;

      OE_LINE_UTIL.Query_Row
      (p_line_id  => l_option_line_id
      ,x_line_rec => l_line_rec);

      l_line_count                     := l_line_count + 1;
      l_old_line_tbl(l_line_count)     := l_line_rec;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('UPDATING LINE: ' || L_OPTION_LINE_ID , 1 ) ;
      END IF;

      l_line_rec.operation             := OE_GLOBALS.G_OPR_UPDATE;
      l_line_rec.line_id               := l_option_line_id;
      l_line_rec.project_id            := l_ato_line_rec.project_id;
      l_line_rec.task_id               := l_ato_line_rec.task_id;
      l_line_rec.ship_from_org_id      := l_ato_line_rec.ship_from_org_id;
      l_line_rec.ship_to_org_id        := l_ato_line_rec.ship_to_org_id;
      l_line_rec.schedule_ship_date    :=
                                      l_ato_line_rec.schedule_ship_date;
      l_line_rec.schedule_arrival_date :=
                                      l_ato_line_rec.schedule_arrival_date;
      l_line_rec.request_date          :=
                                      l_ato_line_rec.request_date;
      l_line_rec.shipping_method_code  :=
                                      l_ato_line_rec.shipping_method_code;
      l_line_rec.freight_carrier_code  :=
                                      l_ato_line_rec.freight_carrier_code;

      l_line_tbl(l_line_count)         := l_line_rec;

    END LOOP;
    CLOSE ATO_OPTIONS;
  END LOOP;
  CLOSE ATO_MODELS;

  IF l_line_count = 0 THEN
    RETURN;
  END IF;

  -- Set Control Record
  l_control_rec.check_security       := TRUE;

  -- if ui calls prcess_config, we want all the
  -- delayed requests to be executed.
  -- if batch validation calls it, we do not want
  -- the delayed requests to be executed in recursive
  -- call to process_order

  IF p_ui_flag = 'Y' THEN
    l_control_rec.process              := TRUE;
  ELSE
    l_control_rec.process              := FALSE;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('IN UPDATE_ATO_ATTIRBS , CALLING PROCESS_ORDER' , 1 ) ;
  END IF;

  OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG := 'Y';

  Call_Process_Order
  (  p_line_tbl      => l_line_tbl
    ,p_control_rec   => l_control_rec
    ,p_ui_flag       => p_ui_flag
    ,x_return_status => l_return_status);

  OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG := 'N';

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add
    ('IN UPDATE_ATO_ATTIRBS , AFTER PO: ' || L_RETURN_STATUS , 1 ) ;
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR IN UPDATE_ATO_LINE_ATTRIBUTES' || SQLERRM , 1 ) ;
    END IF;
    RAISE;
END update_ato_line_attributes;


/* --------------------------------------------------------------------
Procedure Name : Delete_Config
Description    : Deletes the configuration from SPC's tables
-------------------------------------------------------------------- */

Procedure Delete_Config
          (p_config_hdr_id      IN  NUMBER ,
           p_config_rev_nbr     IN  NUMBER ,
           x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_usage_exists   number;
l_return_value   number := 1;
l_error_message  varchar2(100);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING DELETE_CONFIG IN OE_CONFIG_PVT' , 1 ) ;
  END IF;

  IF p_config_hdr_id is not null AND
     p_config_rev_nbr is not null THEN

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add
       ('DEL CFG' ||P_CONFIG_HDR_ID || ' ' || P_CONFIG_REV_NBR , 1 ) ;
     END IF;

     CZ_CF_API.Delete_Configuration
             ( config_hdr_id   => p_config_hdr_id
              ,config_rev_nbr  => p_config_rev_nbr
              ,usage_exists    => l_usage_exists
              ,error_message   => l_error_message
              ,return_value    => l_return_value );

-- when error, returns 0, else 1

     IF l_return_value <> 1 THEN
        OE_Msg_Pub.Add_Text(l_error_message);
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('ERROR IN DELETE_CONFIG IN OE_CONFIG_PVT' , 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;
  ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('NOTE : NULL CONFIG_HEADER_ID/CONFIG_REV_NBR PASSED');
    END IF;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING DELETE_CONFIG IN OE_CONFIG_PVT' , 1 ) ;
  END IF;

EXCEPTION
  when others then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR IN DELETE_CONFIG IN OE_CONFIG_PVT' , 1 ) ;
    END IF;


END Delete_Config;


/* --------------------------------------------------------------------
Procedure Name : Copy_Config
Description    : Copies a configuration in spc's tables asnd gives
                 back new config_header_id, new_config_rev_nbr and
                 updates link_to_line_id, ATO_line_id, option_number
                 config_header_id and config_rev_nbr of model/class/option

Change Record:
2611771 : new cz copy config call
3144865 : skip call to change_columns if only model line is selected
3318910 : call change_columns for KIT/ options window, bug fix on top
          of 3144865 to fix the issues in that bug fix.
-------------------------------------------------------------------- */

Procedure Copy_Config(p_top_model_line_id  IN  NUMBER ,
                      p_config_hdr_id      IN  NUMBER ,
                      p_config_rev_nbr     IN  NUMBER ,
                      p_configuration_id   IN  NUMBER ,
                      p_remnant_flag       IN  VARCHAR2 ,
                      x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
  l_return_value      number;
  l_error_message     varchar2(100);
  l_new_config_flag   varchar2(1) := '1';
  l_flag              varchar2(1) := 'Y';
  l_config_hdr_id     number;
  l_config_rev_nbr    number;
  l_configuration_id  number;
  l_ato_line_id       number;
  l_orig_item_id_tbl  CZ_API_PUB.number_tbl_type;
  l_new_item_id_tbl   CZ_API_PUB.number_tbl_type;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_booked_flag       varchar2(1);

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING COPY_CONFIG '|| P_REMNANT_FLAG , 1 ) ;
    oe_debug_pub.add('MODEL LINE: '|| P_TOP_MODEL_LINE_ID , 1 ) ;
  END IF;

  l_return_value := 1;

  -- we need a copy only if not remnant.
  IF p_config_hdr_id is not null AND
     p_config_rev_nbr is not null AND
     p_remnant_flag is null
  THEN

    IF OE_CODE_CONTROL.Get_Code_Release_Level < '110509' THEN

      CZ_CF_API.Copy_Configuration
      ( config_hdr_id       => p_config_hdr_id
       ,config_rev_nbr      => p_config_rev_nbr
       ,new_config_flag     => l_new_config_flag
       ,out_config_hdr_id   => l_config_hdr_id
       ,out_config_rev_nbr  => l_config_rev_nbr
       ,Error_message       => l_error_message
       ,Return_value        => l_return_value );
       -- when error, returns 0, else 1

      IF l_return_value <> 1  THEN
        OE_Msg_Pub.Add_Text(l_error_message);
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('ERROR FROM SPC COPY: ' || L_ERROR_MESSAGE , 1 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;

    ELSE

      CZ_Config_API_Pub.copy_configuration
      ( p_api_version          => 1.0
       ,p_config_hdr_id        => p_config_hdr_id
       ,p_config_rev_nbr       => p_config_rev_nbr
       ,p_copy_mode            => CZ_API_PUB.G_NEW_HEADER_COPY_MODE
       ,x_config_hdr_id        => l_config_hdr_id
       ,x_config_rev_nbr       => l_config_rev_nbr
       ,x_orig_item_id_tbl     => l_orig_item_id_tbl
       ,x_new_item_id_tbl      => l_new_item_id_tbl
       ,x_return_status        => x_return_status
       ,x_msg_count            => l_msg_count
       ,x_msg_data             => l_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        OE_Msg_Pub.Add_Text(l_msg_data);
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('ERROR FROM SPC NEW COPY: ' || L_MSG_DATA , 1 ) ;
        END IF;
        RETURN;
      END IF;

      IF l_new_item_id_tbl.COUNT = 0 THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('no need to update config ids ',1);
        END IF;

      ELSE

        FORALL I IN l_new_item_id_tbl.FIRST..l_new_item_id_tbl.LAST

          UPDATE oe_order_lines
          SET    configuration_id  = l_new_item_id_tbl(I)
          WHERE  top_model_line_id = p_top_model_line_id
          AND    configuration_id  = l_orig_item_id_tbl(I);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('DONE UPDATING NEW CONFIG ITEM IDS' , 1 ) ;
        END IF;

      END IF;

    END IF;

  ELSE

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('NULL CONFIG_HEADER_ID TO COPY_CONFIG , OR REMNANT SET' , 1 ) ;
    END IF;

    UPDATE oe_order_lines
    SET    configuration_id = null,
           config_header_id = null,
           config_rev_nbr   = null
    WHERE  top_model_line_id = p_top_model_line_id;

    IF SQL%FOUND THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CONFIG IDS UPDATED TO NULL' , 2 ) ;
      END IF;
    END IF;
  END IF;


  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' AND
     p_remnant_flag = 'Y'
  THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('1 COPY CONFIG: PACK H NEW LOGIC MI' , 1 ) ;
    END IF;

    UPDATE oe_order_lines
    SET    link_to_line_id = NULL
    WHERE  top_model_line_id = p_top_model_line_id
    AND    split_from_line_id is not NULL;

  ELSE

    UPDATE oe_order_lines
    SET    link_to_line_id = NULL
    WHERE  top_model_line_id = p_top_model_line_id;

  END IF;

  ------------------ ato_line_id ----------------------

  /* Added this query and if stmt to fix bug 1809046.
     Make sure the ato_line_id will be cleared only for Sub config,
     Since Update_ato_line_attributes are updating only Class records
     The ato_line_id populated by SPLIT code in case of PTO+ATO is
     the line_id of the top PTO mode whcih is incorrect. Hence,
     it is important to update the ATO with correct ato_line_id.
   */

  SELECT ato_line_id ,booked_flag, item_type_code
  INTO   l_ato_line_id, l_booked_flag, l_error_message
  FROM   oe_order_lines
  WHERE  line_id = p_top_model_line_id;


  -- if ato model, do not clear ato_line_id. also for ato_item
  -- under pto model do not clear ato_line_id ## 1820608

  IF p_top_model_line_id <> nvl(l_ato_line_id,-99) THEN

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('NULLING ATO_LINE_ID FOR ATO SUB' , 4 ) ;
     END IF;

       UPDATE oe_order_lines
       SET    ato_line_id       = NULL
       WHERE  top_model_line_id = p_top_model_line_id
       AND    NOT (item_type_code = OE_GLOBALS.G_ITEM_OPTION AND
                   ato_line_id    = line_id);
  END IF;

  IF p_remnant_flag is NULL THEN

    IF  nvl(l_booked_flag,'N') = 'N' THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Order Not Booked '|| l_error_message, 5);
      END IF;

      IF p_config_hdr_id is NULL AND
         p_config_rev_nbr is NULL AND
         p_configuration_id is NULL AND
         l_error_message = 'MODEL' THEN

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add
           ('config hdr/rev/id null dont call change column',5);
         END IF;
		update_link_to_line_id
                ( p_top_model_line_id => p_top_model_line_id  --added for bug 7261021
                 ,p_remnant_flag      => p_remnant_flag
                 ,p_config_hdr_id     => p_config_hdr_id);
        RETURN;
      END IF;
    END IF;

  END IF;

  Change_Columns(p_top_model_line_id => p_top_model_line_id,
                 p_config_hdr_id     => l_config_hdr_id,
                 p_config_rev_nbr    => l_config_rev_nbr);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('NEW CONFIG_HEADER_ID: '|| L_CONFIG_HDR_ID , 5 ) ;
    oe_debug_pub.add('NEW CONFIG_REV_NBR: '|| L_CONFIG_REV_NBR , 5 ) ;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING COPY_CONFIG IN OE_CONFIG_PVT' , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR IN COPY_CONFIG,OE_CONFIG_PVT'|| sqlerrm ,1);
    END IF;

    RAISE;
END Copy_Config;


/*-----------------------------------------------------------------
PROCEDURE  put_hold_and_release_hold
Used to put the model line on hold when configuration is invalid/
incomplete after booking. Also the model is released from hold if
it becomesvalid/complete, after the change.

Change Record:
bug fix: 2162660: added check for holds call even before the
apply holds call.
------------------------------------------------------------------*/

PROCEDURE  put_hold_and_release_hold
          ( p_header_id        IN  NUMBER,
            p_line_id          IN  NUMBER,
            p_valid_config     IN  VARCHAR2,
            p_complete_config  IN  VARCHAR2,
            x_msg_count        OUT NOCOPY /* file.sql.39 change */ NUMBER ,
            x_msg_data         OUT NOCOPY /* file.sql.39 change */ VARCHAR2 ,
            x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
  l_holds_tbl                     OE_HOLDS_PVT.order_tbl_type;
  l_hold_id                       NUMBER;
  l_hold_comment                  VARCHAR2(200);
  l_release_reason_code           VARCHAR2(30);
  l_release_comment               VARCHAR2(200);
  l_hold_result_out               VARCHAR2(30):= 'TRUE';
  l_result_out                    VARCHAR2(30);
  l_error                         VARCHAR2(200);
  l_line_number                   NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    Print_Time('entering put_hold_and_release_hold');

    l_hold_id   := 3;

    l_holds_tbl(1).header_id    := p_header_id;
    l_holds_tbl(1).line_id      := p_line_id;

    SELECT line_number || '.'|| shipment_number
    INTO   l_line_number
    FROM   oe_order_lines
    WHERE  line_id = p_line_id;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OE_CONFIG_PVT , BEFORE CHECK_HOLDS ON MODEL' , 1 ) ;
    END IF;

    OE_HOLDS_PUB.CHECK_HOLDS
    ( p_api_version       => 1.0,
      p_line_id           => p_line_id,
      p_hold_id           => l_hold_id,
      x_result_out        => l_hold_result_out,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

      IF l_hold_result_out = FND_API.G_FALSE AND
         (LOWER(p_valid_config) = 'false' OR
          LOWER(p_complete_config) = 'false' ) THEN

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add
           ('INCOMPLETE/INVALID CONFIGURATION IN A BOOKED ORDER' , 1 ) ;
         END IF;

         l_hold_comment              := 'Validation hold on model';

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('BEFORE APPLY_HOLDS ON MODEL' , 1 ) ;
         END IF;

         OE_Holds_pub.apply_holds
         ( p_api_version          =>  1.0,
           p_order_tbl            =>  l_holds_tbl,
           p_hold_id              =>  l_hold_id,
           p_hold_comment         =>  l_hold_comment,
           x_return_status        =>  x_return_status,
           x_msg_count            =>  x_msg_count,
           x_msg_data             =>  x_msg_data );

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('OE_CONFIG_PVT , ERROR IN PUT HOLD' , 1 ) ;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('OE_CONFIG_PVT , ERROR IN PUT HOLD' , 1 ) ;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         FND_MESSAGE.Set_Name('ONT', 'OE_VAL_CONFIG_HOLD_INSERT');
         FND_MESSAGE.Set_Token('LINE_NUMBER', l_line_number);
         OE_Msg_Pub.Add;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('AFTER SUCCESSFUL APPLY_HOLDS ON MODEL' , 1 ) ;
         END IF;
      END IF;

      IF l_hold_result_out = FND_API.G_TRUE AND
         (LOWER(p_valid_config) = 'true' AND
          LOWER(p_complete_config) = 'true' ) THEN

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('VALID/COMPLETE CONFIGURATION IN BOOKED ORDER',1);
         END IF;

         l_release_reason_code  := 'CZ_AUTOMATIC';
         l_release_comment      := 'Configuration is now valid';

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('OE_CONFIG_PVT,BEFORE RELEASE_HOLDS ON MODEL',1);
         END IF;

         OE_Holds_pub.release_holds
         ( p_order_tbl            =>  l_holds_tbl,
           p_hold_id              =>  l_hold_id,
           p_release_reason_code  =>  l_release_reason_code,
           p_release_comment      =>  l_release_comment,
           x_return_status        =>  x_return_status,
           x_msg_count            =>  x_msg_count,
           x_msg_data             =>  x_msg_data  );

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('OE_CONFIG_PVT , ERROR IN RELEASING HOLD',1);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('OE_CONFIG_PVT ,ERROR IN RELEASING HOLD' ,1);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         FND_MESSAGE.Set_Name('ONT', 'OE_VAL_CONFIG_HOLD_REMOVE');
         FND_MESSAGE.Set_Token('LINE_NUMBER', l_line_number);
         OE_Msg_Pub.Add;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('AFTER SUCCESSFUL RELAESE_HOLDS ON MODEL' ,1);
         END IF;
       END IF;

     ELSE -- ret status error
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('OE_CONFIG_PVT , ERROR IN CHECK HOLD' , 1 ) ;
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('OE_CONFIG_PVT , ERROR IN CHECK HOLD' , 1 ) ;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF; -- check holds ret status check.

   Print_Time('leaving put_hold_and_release_hold');

EXCEPTION
   when others then
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('ERROR IN PUT_HOLD_AND_RELEASE_HOLD IN OE_CONFIG_PVT' , 1 ) ;
      END IF;

END put_hold_and_release_hold;

/*-----------------------------------------------------------
Procedure:  Explode_Bill

Explode the BOM for the model, so that we can use the
bom_explosions table on other procedures.
If the component_sequence_id is null for the model line, get
it's value from bom_explosions. Also set the bom values on
the model line rec so that it can be sent in for update.
we will call a direct update on the model line later.

change record:
new parameters for ER config date effectivity 2625376
p_check_effective_date  : if need to check model date effectivity.
x_config_effective_date : null if p_check_effective_date is N
x_frozen_model_bill     : null if p_check_effective_date is N
------------------------------------------------------------*/
Procedure Explode_Bill
( p_model_line_rec        IN  OUT NOCOPY OE_Order_Pub.Line_Rec_Type
 ,p_do_update             IN  BOOLEAN   := TRUE
 ,p_check_effective_date  IN  VARCHAR2  := 'Y'
 ,x_config_effective_date OUT NOCOPY    DATE
 ,x_frozen_model_bill     OUT NOCOPY    VARCHAR2
 ,x_return_status         OUT NOCOPY    VARCHAR2)
IS
  /* variables for call to explode */
  l_rev_date                   DATE;
  l_validation_org             NUMBER :=
                             OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID');
  l_stdcompflag                VARCHAR2(10)
                             := OE_Config_Util.OE_BMX_OPTION_COMPS;
  l_top_item_id                NUMBER;
  l_op_qty                     NUMBER;
  l_top_bill_sequence_id       NUMBER;
  l_frozen_model_bill          VARCHAR2(1);
  l_old_behavior               VARCHAR2(1);
  l_error_code                 NUMBER;
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(2000);
  l_return_status              VARCHAR2(1):=  FND_API.G_RET_STS_SUCCESS;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add( 'model line_id : '|| p_model_line_rec.line_id ,1);
  END IF;

  IF p_check_effective_date = 'Y' THEN

    OE_Config_Util.Get_Config_Effective_Date
    ( p_model_line_id         => p_model_line_rec.line_id
     ,p_model_line_rec        => p_model_line_rec
     ,x_old_behavior          => l_old_behavior
     ,x_config_effective_date => l_rev_date
     ,x_frozen_model_bill     => l_frozen_model_bill);

    IF l_rev_date is NULL THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_config_effective_date := l_rev_date;
    x_frozen_model_bill     := l_frozen_model_bill;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(x_config_effective_date||':'||x_frozen_model_bill,1);
    END IF;

  ELSE

    l_rev_date            := p_model_line_rec.creation_date;

    IF l_rev_date is NULL OR
       l_rev_date = FND_API.G_MISS_DATE THEN
      l_rev_date := sysdate;
    END IF;

  END IF;

  l_top_item_id         := p_model_line_rec.inventory_item_id;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('VALIDATION_ORG: ' || L_VALIDATION_ORG , 1 ) ;
    oe_debug_pub.add('INVENTORY ITEM ID OF MODEL: ' || L_TOP_ITEM_ID , 1 ) ;
    oe_debug_pub.add('CREATION DATE IS: ' || L_REV_DATE , 1 ) ;
  END IF;

   -- Explode the options in Bom_Explosions
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('CALL TO EXPLOSION' , 1 ) ;
  END IF;

  OE_CONFIG_UTIL.Explode
  ( p_validation_org   => l_validation_org
  , p_stdcompflag      => l_stdcompflag
  , p_top_item_id      => l_top_item_id
  , p_revdate          => l_rev_date
  , x_msg_data         => l_msg_data
  , x_error_code       => l_error_code
  , x_return_status    => l_return_status  );


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('AFTER CALL TO EXPLOSION , RETURN STATUS: '
                      || L_RETURN_STATUS , 1 ) ;
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        x_return_status := l_return_status;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := l_return_status;
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_model_line_rec.component_sequence_id is null OR
     p_model_line_rec.component_sequence_id = FND_API.G_MISS_NUM
   THEN

     BEGIN
       SELECT bill_sequence_id
       INTO   p_model_line_rec.component_sequence_id
       FROM   bom_bill_of_materials
       WHERE  assembly_item_id = p_model_line_rec.inventory_item_id
       AND    organization_id = l_validation_org
       AND    alternate_bom_designator is NULL;

       --bug3392064 start
       --modified 0001 to be of varchar type
       p_model_line_rec.sort_order     := Bom_Common_Definitions.get_initial_sort_code;
       --bug3392064 end
       p_model_line_rec.component_code :=
                 to_char(p_model_line_rec.inventory_item_id);

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('EXPLODE_BILL , BILL_SEQ QUERY FAILED' , 1 ) ;
         END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('TOP_BILL_SEQ_ID SELECTED FROM BOM_bill_of_mat' ) ;
     END IF;

     IF p_do_update THEN
       UPDATE oe_order_lines
       SET component_sequence_id  = p_model_line_rec.component_sequence_id
          ,sort_order             = p_model_line_rec.sort_order
          ,component_code         = p_model_line_rec.component_code
          ,lock_control           = lock_control + 1
       WHERE line_id = p_model_line_rec.line_id;

       p_model_line_rec.lock_control := p_model_line_rec.lock_control + 1;
     ELSE
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('CALL FROM VORDB' , 3 ) ;
       END IF;
     END IF;

  END IF;

  x_return_status := l_return_status;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('TOP BILL SEQ ID'
                      || P_MODEL_LINE_REC.COMPONENT_SEQUENCE_ID , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN EXPLODE_BILL: '|| SQLERRM , 1 ) ;
    END IF;
    RAISE;
END Explode_Bill;


/*-----------------------------------------------------------------
PROCEDURE Modify_Included_Items

It is called from OEXULINB from post_lines process.

input params setting
param1  := old ordered_quantity;
param2  := new ordered_quantity;
param3  := change_reason;
param4  := change_comments;
param5  := project_id;
param6  := task_id;
param7  := ship tol above;
param8  := ship tol below;
param9  := ship_to_org_id;
param10 := operation;
param11 := if complete cancellation or not
param12 := line_id;
param13 := top_model_line_id;
date_param1 := request_date;

This will cascade the changes from the class to included items,
on relevant columns.

For every top model line(param13),
  For every class line(param12)
    We get all included items, set new values on thel ine_rec and
    call process_order.
------------------------------------------------------------------*/

PROCEDURE Modify_Included_Items
(x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  I                       NUMBER;
  l_index                 NUMBER;
  l_line_rec              OE_Order_Pub.Line_Rec_Type
                          := OE_Order_Pub.G_Miss_Line_Rec;
  l_line_tbl              OE_Order_PUB.Line_Tbl_Type;
  l_control_rec           OE_GLOBALS.Control_Rec_Type;
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


  CURSOR inc_items(p_link_to_line_id   NUMBER,
                   p_top_model_line_id NUMBER)
  IS
  SELECT line_id, ordered_quantity
  FROM   oe_order_lines
  WHERE  top_model_line_id = p_top_model_line_id
  AND    link_to_line_id   = p_link_to_line_id
  AND    item_type_code    = OE_GLOBALS.G_ITEM_INCLUDED;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING MODIFY_INCLUDED_ITEMS' , 1 ) ;
  END IF;

  l_index := 0;
  I       := OE_MODIFY_INC_ITEMS_TBL.FIRST;
  WHILE I is not NULL
  LOOP
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  I||'CLASS/KIT '
                        || OE_MODIFY_INC_ITEMS_TBL ( I ) .PARAM12 , 2 ) ;
      oe_debug_pub.add
      ('OPERATION '|| OE_MODIFY_INC_ITEMS_TBL ( I ) .PARAM10 , 3 ) ;
    END IF;

    FOR l_rec in inc_items(OE_MODIFY_INC_ITEMS_TBL(I).param12,
                           OE_MODIFY_INC_ITEMS_TBL(I).param13)
    LOOP
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('INC ITEM '|| L_REC.LINE_ID , 1 ) ;
      END IF;

      l_line_rec.line_id          := l_rec.line_id;
      l_line_rec.operation        := OE_MODIFY_INC_ITEMS_TBL(I).param10;

      -- 1. ordered_quantity.

      IF OE_MODIFY_INC_ITEMS_TBL(I).param2 <> FND_API.G_MISS_NUM THEN

        -- old ordered qty of parent can not be 0, so no divide by 0.
	--bug3993709
        l_line_rec.ordered_quantity :=
	       (l_rec.ordered_quantity/OE_MODIFY_INC_ITEMS_TBL(I).param1) *
	                               OE_MODIFY_INC_ITEMS_TBL(I).param2 ;
        l_line_rec.change_reason     := OE_MODIFY_INC_ITEMS_TBL(I).param3;
        l_line_rec.change_comments   := OE_MODIFY_INC_ITEMS_TBL(I).param4;

      END IF; -- Quantity check.


      -- 2. project and task.

      IF nvl(OE_MODIFY_INC_ITEMS_TBL(I).param5, -1) <> FND_API.G_MISS_NUM THEN
        l_line_rec.project_id := OE_MODIFY_INC_ITEMS_TBL(I).param5;
      END IF; -- project.

      IF nvl(OE_MODIFY_INC_ITEMS_TBL(I).param6, -1) <> FND_API.G_MISS_NUM THEN
        l_line_rec.task_id := OE_MODIFY_INC_ITEMS_TBL(I).param6;
      END IF; -- task.


      -- 3. ship_tolerance_above and below

      IF nvl(OE_MODIFY_INC_ITEMS_TBL(I).param7, -1) <> FND_API.G_MISS_NUM THEN
        l_line_rec.ship_tolerance_above := OE_MODIFY_INC_ITEMS_TBL(I).param7;
      END IF; -- ship_tolerance_above.

      IF nvl(OE_MODIFY_INC_ITEMS_TBL(I).param8, -1) <> FND_API.G_MISS_NUM THEN
        l_line_rec.ship_tolerance_below := OE_MODIFY_INC_ITEMS_TBL(I).param8;
      END IF; -- ship_tolerance_below.


      -- 4. ship_to and request_date

      IF nvl(OE_MODIFY_INC_ITEMS_TBL(I).param9, -1) <> FND_API.G_MISS_NUM THEN
        l_line_rec.ship_to_org_id := OE_MODIFY_INC_ITEMS_TBL(I).param9;
      END IF; -- ship_to_org_id.

      IF nvl(OE_MODIFY_INC_ITEMS_TBL(I).date_param1, sysdate)
                                               <> FND_API.G_MISS_DATE THEN
        l_line_rec.request_date := OE_MODIFY_INC_ITEMS_TBL(I).date_param1;
      END IF; -- request_date.


      IF l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
         l_line_rec.ordered_quantity = 0 AND
         OE_MODIFY_INC_ITEMS_TBL(I).param11 = 'N'
      THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('DELETE SINCE NOT FULL CANCEL' , 3 ) ;
         END IF;
         l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
      END IF;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('QTY - OP '|| L_LINE_REC.ORDERED_QUANTITY
                         || L_LINE_REC.OPERATION , 1 ) ;
      END IF;

      l_index := l_index + 1;
      l_line_tbl(l_index) := l_line_rec;
      l_line_rec := OE_Order_Pub.G_MISS_LINE_REC;


    END LOOP; -- end cursor
    I := OE_MODIFY_INC_ITEMS_TBL.NEXT(I);
  END LOOP;

  l_control_rec.process              := FALSE;

  oe_config_pvt.Call_Process_Order
  (  p_line_tbl      => l_line_tbl
    ,p_control_rec   => l_control_rec
    ,x_return_status => l_return_status);

  OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

  x_return_status := l_return_status;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING MODIFY_INCLUDED_ITEMS'|| L_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN MODIFY_INCLUDED_ITEMS'|| SQLERRM , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
END;


/*-----------------------------------------------------------------
PROCEDURE Included_Items_DML
this procedure will not be used anymore,
modify_included_items is used and
that is called from OEXULINB
__________________________________________________________________*/

PROCEDURE Included_Items_DML
( p_x_line_tbl         IN  OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
 ,p_top_model_line_id  IN  NUMBER
 ,p_ui_flag            IN  VARCHAR2
 ,x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  I                       NUMBER;
  l_line_rec              OE_Order_Pub.Line_Rec_Type;
  l_found                 BOOLEAN;
  l_ordered_qty           NUMBER;
  l_component_sequence_id NUMBER;
  l_creation_date         DATE;
  l_length                NUMBER;
  l_code                  VARCHAR2(1000);
  l_index                 NUMBER;
  l_current_qty           NUMBER;
  l_inventory_item_id     NUMBER;
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  CURSOR included_items IS
  SELECT line_id, component_code, link_to_line_id, ordered_quantity
  FROM   oe_order_lines
  WHERE  item_type_code = 'INCLUDED'
  AND    link_to_line_id <> top_model_line_id
  AND    top_model_line_id = p_top_model_line_id;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING INCLUDED_ITEMS_DML '|| P_UI_FLAG , 1 ) ;
  END IF;

  l_index :=  p_x_line_tbl.LAST;
  l_component_sequence_id := NULL;

  FOR l_rec in included_items
  LOOP
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('INCLUDED ITEM: '|| L_REC.COMPONENT_CODE , 2 ) ;
    END IF;

    IF l_component_sequence_id is NULL THEN

      SELECT component_sequence_id, creation_date
      INTO   l_component_sequence_id, l_creation_date
      FROM   oe_order_lines
      WHERE  line_id = p_top_model_line_id;
    END IF;

    l_found := FALSE;

    IF p_ui_flag = 'Y' THEN
      I := p_x_line_tbl.FIRST;
      WHILE I is not null AND NOT l_found
      LOOP

          l_length := LENGTH(p_x_line_tbl(I).component_code);
          l_code   := SUBSTR(p_x_line_tbl(I).component_code,
                INSTR(p_x_line_tbl(I).component_code, '-', -1) + 1, l_length);

          IF SUBSTR(l_rec.component_code, 1,
             INSTR(l_rec.component_code, '-') -1) = l_code
          THEN
            l_line_rec                  := OE_Order_Pub.G_Miss_Line_Rec;
            l_line_rec.operation        := p_x_line_tbl(I).operation;
            l_line_rec.line_id          := l_rec.line_id;

            l_line_rec.ordered_quantity := p_x_line_tbl(I).ordered_quantity;
            l_line_rec.change_reason    := 'SYSTEM';
            l_line_rec.change_comments  := 'Included Items updation';
            l_index                     := l_index + 1;
            p_x_line_tbl(l_index)       := l_line_rec;
            l_found                     := TRUE;

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('PARENT WAS' || L_LINE_REC.OPERATION , 1 ) ;
              oe_debug_pub.add('NEW QTY ' || L_LINE_REC.ORDERED_QUANTITY ,1);
            END IF;
          END IF;

        I := p_x_line_tbl.NEXT(I);
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('COUNT: ' || P_X_LINE_TBL.COUNT || I , 1 ) ;
        END IF;
      END LOOP;
    END IF;

    IF NOT l_found THEN
      -- already updated/deleted and batch validation logged.
      BEGIN
        SELECT ordered_quantity
        INTO   l_ordered_qty
        FROM   oe_order_lines
        WHERE  top_model_line_id = p_top_model_line_id
        AND    line_id = l_rec.link_to_line_id;

        l_line_rec                  := OE_Order_Pub.G_Miss_Line_Rec;
        l_line_rec.operation        := OE_GLOBALS.G_OPR_UPDATE;
        l_line_rec.line_id          := l_rec.line_id;
        l_line_rec.ordered_quantity := l_ordered_qty; -- ratio??***
        l_line_rec.change_reason    := 'SYSTEM';
        l_line_rec.change_comments  := 'Included Items updation';
        l_index                     := l_index + 1;
        p_x_line_tbl(l_index)       := l_line_rec;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('PARENT WAS UPDATED' || L_ORDERED_QTY , 3 ) ;
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_line_rec.operation      := OE_GLOBALS.G_OPR_DELETE;
          l_line_rec.line_id        := l_rec.line_id;
          l_index                   := l_index + 1;
          p_x_line_tbl(l_index)     := l_line_rec;

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('PARENT WAS DELETED' , 3 ) ;
          END IF;

        WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('COULD NOT SELECT PARENT QTY' , 1 ) ;
          END IF;
          RAISE;
      END;

    END IF;

  END LOOP;

  x_return_status := l_return_status;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING INCLUDED_ITEMS_DML' , 1 ) ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN INCLUDED_ITEMS_DML'|| SQLERRM , 1 ) ;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
END Included_Items_DML;


/*-----------------------------------------------------------------
Procedure: Copy_Config1
Not Used.
------------------------------------------------------------------*/
Procedure Copy_Config1(p_config_hdr_id      IN  NUMBER ,
                       p_config_rev_nbr     IN  NUMBER ,
                       x_config_hdr_id      OUT NOCOPY /* file.sql.39 change */ NUMBER ,
                       x_config_rev_nbr     OUT NOCOPY /* file.sql.39 change */ NUMBER ,
                       x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
l_return_value    number;
l_error_message   varchar2(100);
l_new_config_flag varchar2(1) := '1';
l_flag            varchar2(1) := 'Y';
l_config_hdr_id   number;
l_config_rev_nbr  number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING COPY_CONFIG IN OE_CONFIG_PVT' , 1 ) ;
  END IF;

  IF p_config_hdr_id is not null AND
     p_config_rev_nbr is not null THEN

     CZ_CF_API.Copy_Configuration
               (config_hdr_id       => p_config_hdr_id  ,
                config_rev_nbr      => p_config_rev_nbr ,
                new_config_flag     => l_new_config_flag,
                out_config_hdr_id   => l_config_hdr_id  ,
                out_config_rev_nbr  => l_config_rev_nbr ,
                Error_message       => l_error_message  ,
                Return_value        => l_return_value );

     -- when error, returns 0, else 1

     IF l_return_value <> 1 THEN
        OE_Msg_Pub.Add_Text(l_error_message);
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('ERROR FROM SPC COPY: ' || L_ERROR_MESSAGE , 1 ) ;
        END IF;
        x_return_status :=FND_API.G_RET_STS_ERROR;

     ELSE
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('NEW CONFIG_HEADER_ID: '|| L_CONFIG_HDR_ID , 1 ) ;
        END IF;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('NEW CONFIG_REV_NBR: '|| L_CONFIG_REV_NBR , 1 ) ;
        END IF;
        x_config_hdr_id  := l_config_hdr_id;
        x_config_rev_nbr := l_config_rev_nbr;
        x_return_status  := FND_API.G_RET_STS_SUCCESS;
      END IF;

  ELSE
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('NULL CONFIG_HDR/REV_NBR IS PASSED TO COPY_CONFIG',1);
     END IF;

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING COPY_CONFIG IN OE_CONFIG_PVT' , 1 ) ;
  END IF;

EXCEPTION
  when others then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR IN COPY_CONFIG IN OE_CONFIG_PVT' , 1 ) ;
    END IF;

END Copy_Config1;


/*--------------------------------------------------------
PROCEDURE Is_Cancel_OR_Delete

--------------------------------------------------------*/
PROCEDURE Is_Cancel_OR_Delete
( p_line_id          IN NUMBER
 ,p_change_reason    IN VARCHAR2 := null
 ,p_change_comments  IN VARCHAR2 := null
 ,x_cancellation     OUT NOCOPY BOOLEAN
 ,x_line_rec         IN OUT NOCOPY OE_Order_Pub.line_rec_type)
IS
  l_return_status    VARCHAR2(1);
  I                  NUMBER;
  l_msg_count1       NUMBER;
  l_msg_count2       NUMBER;
  l_sec_result       NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  x_cancellation := FALSE;
  l_msg_count1   := OE_Msg_Pub.Count_Msg;

  OE_LINE_UTIL.Query_Row(p_line_id  => p_line_id
                        ,x_line_rec => x_line_rec);



  x_line_rec.operation  := OE_GLOBALS.G_OPR_DELETE;

  OE_Line_Security.Entity
 (  p_line_rec        => x_line_rec
   ,x_result          => l_sec_result
   ,x_return_status   => l_return_status);

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_msg_count2 := OE_Msg_Pub.Count_Msg;


  IF l_msg_count2 > l_msg_count1 THEN
    -- need to remove the messages.
    IF l_msg_count1 = 0 THEN
      OE_Msg_Pub.Delete_Msg;

    ELSE
      I := 0;

      WHILE l_msg_count2 - l_msg_count1 - I > 0
      LOOP

        OE_Msg_Pub.Delete_Msg(l_msg_count2 - I);

        oe_debug_pub.add(OE_Msg_Pub.g_msg_index || '-'
        ||l_msg_count1 || '-'|| l_msg_count2 || '-' ||I, 3 );

        I := I + 1;
      END LOOP;
    END IF;
  END IF;

  IF l_sec_result = OE_PC_GLOBALS.YES THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('do cancellation hence update with 0', 3 );
    END IF;

    x_line_rec.ordered_quantity     := 0;
    x_line_rec.operation            := OE_GLOBALS.G_OPR_UPDATE;

    IF p_change_reason is NOT NULL THEN
      x_line_rec.change_reason        := p_change_reason;
    END IF;

    IF p_change_comments is NOT NULL THEN
      x_line_rec.change_comments      := p_change_comments;
    END IF;

    x_cancellation                  := TRUE;
  ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('no cancellation, delete ok ', 3 ) ;
    END IF;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('option operation '|| x_line_rec.operation, 3);
  END IF;
EXCEPTION
  when OTHERS then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Is_Cancel_OR_Delete '|| sqlerrm, 3);
    END IF;
    RAISE;
END Is_Cancel_OR_Delete;


/*--------------------------------------------------------
PROCEDURE Print_Time

--------------------------------------------------------*/

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


END Oe_Config_Pvt;

/
