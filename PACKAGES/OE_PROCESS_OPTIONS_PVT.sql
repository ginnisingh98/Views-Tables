--------------------------------------------------------
--  DDL for Package OE_PROCESS_OPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PROCESS_OPTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVOPTS.pls 120.2 2005/11/16 02:47:21 apani ship $ */

/*----------------------------------------------------------------
 1) UI and configuration validation wrapper will populate this
    table and call process_config_options procedure.
 2) The bom item type in this  record type is a manipulated one,
    where a model under a model will have a bom_item_type of 2
    instead of 1.
 3) The operation
    CREATE  => options created but not yet commited, mainly
    for order import delayed request.
    INSERT  => to be created options, in case of UI
               and in case  OE_Config_Uti.Bom_Config_Validation
               after the fill in classes, to be passed to
               handle_create.
    UPDATE  => updated, not used
    DELETED => deleted, not used
    NONE    => no specific operation

Change Record:
additional flex columns for bug 2184255
------------------------------------------------------------------*/

TYPE SELECTED_OPTIONS_REC IS RECORD
(  line_id               NUMBER         := null
  ,component_code        VARCHAR2(2000) := null
  ,inventory_item_id     NUMBER         := null
  ,component_sequence_id NUMBER         := null
  ,sort_order            VARCHAR2(2000) := null  -- 4336446
  ,order_quantity_uom    VARCHAR2(3)    := null
  ,ordered_quantity      NUMBER         := null
  ,old_ordered_quantity  NUMBER         := null
  ,ordered_item          VARCHAR2(4000) := null
  ,bom_item_type         NUMBER         := null
  ,operation             VARCHAR2(30)   := null
  ,change_reason         VARCHAR2(30)   := null
  ,change_comments       VARCHAR2(2000) := null
  ,configuration_id      NUMBER
  ,attribute1            VARCHAR2(240)
  ,attribute2            VARCHAR2(240)
  ,attribute3            VARCHAR2(240)
  ,attribute4            VARCHAR2(240)
  ,attribute5            VARCHAR2(240)
  ,attribute6            VARCHAR2(240)
  ,attribute7            VARCHAR2(240)
  ,attribute8            VARCHAR2(240)
  ,attribute9            VARCHAR2(240)
  ,attribute10           VARCHAR2(240)
  ,attribute11           VARCHAR2(240)
  ,attribute12           VARCHAR2(240)
  ,attribute13           VARCHAR2(240)
  ,attribute14           VARCHAR2(240)
  ,attribute15           VARCHAR2(240)
  ,attribute16           VARCHAR2(240)
  ,attribute17           VARCHAR2(240)
  ,attribute18           VARCHAR2(240)
  ,attribute19           VARCHAR2(240)
  ,attribute20           VARCHAR2(240)
  ,context               VARCHAR2(240)
  ,option_number         NUMBER
  ,disabled_flag         VARCHAR2(1)    := 'N'
);

TYPE SELECTED_OPTIONS_TBL_TYPE IS TABLE OF SELECTED_OPTIONS_REC
INDEX BY BINARY_INTEGER;

/*-------------------------------------------------------------------
Procedure: Process_Config_Options
This Procedure is called when user presses OK on options window, in OM.
--------------------------------------------------------------------*/

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
);

/*-------------------------------------------------------------------
FUNCTION: Use_Configurator
This API takes into consideration product configurator installation
and profile option OM: Use Configurator setting.
Will be used to decide wheter to use configurator or options window.
--------------------------------------------------------------------*/

FUNCTION Use_Configurator
RETURN BOOLEAN;

/*-------------------------------------------------------------------
PROCEDURE: Get_Options_From_DB
--------------------------------------------------------------------*/

PROCEDURE Get_Options_From_DB
( p_top_model_line_id IN  NUMBER
 ,p_get_model_line    IN  BOOLEAN := FALSE
 ,p_caller            IN  VARCHAR2:= ''
 ,p_query_criteria    IN  NUMBER  := 1
 ,x_disabled_options  OUT NOCOPY VARCHAR2
 ,x_options_tbl       OUT NOCOPY
  OE_Process_Options_Pvt.SELECTED_OPTIONS_TBL_TYPE);


/*-------------------------------------------------------------------
PROCEDURE: Find_Matching_Comp_Index
--------------------------------------------------------------------*/

FUNCTION Find_Matching_Comp_Index
( p_options_tbl  IN OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_comp_code    IN VARCHAR2)
RETURN NUMBER;


/*-------------------------------------------------------------------
PROCEDURE: Prepare_Cascade_Tables
used to prepare i/p tables for cascade_update_deletes API.
handles diabled options also.
--------------------------------------------------------------------*/

PROCEDURE Prepare_Cascade_Tables
( p_options_tbl           IN OUT NOCOPY
                          OE_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_top_model_line_id     IN NUMBER
 ,p_x_updated_options_tbl IN OUT NOCOPY OE_Order_PUB.request_tbl_type
 ,p_x_deleted_options_tbl IN OUT NOCOPY OE_Order_PUB.request_tbl_type);

/*-------------------------------------------------------------------
helper functions
--------------------------------------------------------------------*/

PROCEDURE Handle_Ret_Status(p_return_Status   VARCHAR2);

PROCEDURE Print_Time(p_msg   IN  VARCHAR2);


END OE_Process_Options_Pvt;

 

/
