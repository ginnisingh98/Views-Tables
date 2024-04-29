--------------------------------------------------------
--  DDL for Package Body WMS_LABEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_LABEL_PUB" AS
/* $Header: WMSLABLB.pls 115.0 2000/07/07 15:47:27 pkm ship        $ */
   /*---------------------------------------------------------------------*/
   -- Name
   --   PROCEDURE Location_Label
   /* --------------------------------------------------------------------*/
   --
   -- Purpose
   --   Create XML File for Location label
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --		whether or not to commit the changes to database
   -- 	p_organization_id    	Organization Id - Required Value
   --   p_Zone_From             Zone Range From
   --   p_Zone_To               Zone Range To
   --   p_location_fr           Location Range From
   --                           (only Segment Values are passed)
   --   p_location_to           Location Range To
   --                           (only Segment Values are passed)
   --   p_no_of_copies          No of copies of duplicate labels
   --
   --
   -- Output Parameters
   --   x_return_status
   --       if the pick release process succeeds, the value is
   --		fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --		fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --		fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)

PROCEDURE Location_Label
(  p_api_version   	IN	NUMBER                          ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false     ,
   p_commit	      	IN	VARCHAR2 := fnd_api.g_false     ,
   x_return_status	OUT	VARCHAR2                        ,
   x_msg_count          OUT	NUMBER                          ,
   x_msg_data		OUT	VARCHAR2                        ,
   p_organization_id	IN	NUMBER                          ,
   p_zone_fr    	IN	VARCHAR2 := fnd_api.g_miss_char ,
   p_zone_to		IN	VARCHAR2 := fnd_api.g_miss_char ,
   p_location_fr        IN      VARCHAR2 := fnd_api.g_miss_char ,
   p_location_to        IN      VARCHAR2 := fnd_api.g_miss_char ,
   p_no_of_copies       IN      NUMBER   :=1
) IS
CURSOR loc_cursor IS
       select  inventory_location_id
              ,concatenated_segments locator
              ,subinventory_code
       from mtl_item_locations_kfv
       where concatenated_segments between
                 decode(p_location_fr,null,concatenated_segments,p_location_fr)
             and decode(p_location_to,null,concatenated_segments,p_location_to)
       and subinventory_code between
             decode(p_zone_fr,null,subinventory_code,p_zone_fr)
             and decode(p_zone_to,null,subinventory_code,p_zone_to)
       and organization_id = p_organization_id;
l_loc_rec loc_cursor%ROWTYPE;
l_rec_count NUMBER :=0;
l_printer_header_once VARCHAR2(1):='N';
--
begin
  g_dir := Output_file_dir(); -- get this from profile
  --dbms_output.put_line('directory='||g_dir);
  g_file := 'text123.xml';
  g_no_copies := p_no_of_copies;
/* wms.rules.label needs to be called here to get the correct label
 as per the data created for the label request line
*/
--g_label := wms_rules.label();
/*User the function Get_printer_name() to get the appropriate printer name
  as per the data */
--g_printer := Get_printer_name();
  g_label := 'Loation_Label';
  g_printer := '3op1035ap';
  WMS_CLABEL.setDefaultLabelInfo(g_label,g_printer,g_no_copies);
  WMS_CLABEL.openLabelFile(g_dir,g_file);
  FOR l_loc_rec IN loc_cursor
  LOOP
    IF l_printer_header_once = 'Y' then
       WMS_CLABEL.clearHeader;
       g_variable_name := 'Zone';
       g_variable_value := l_loc_rec.subinventory_code;
       WMS_CLABEL.setHeaderVariable(g_variable_name,g_variable_value);
       g_variable_name := 'Locator';
       g_variable_value := l_loc_rec.locator;
       WMS_CLABEL.setHeaderVariable(g_variable_name,g_variable_value);
  -- Note: Header is also useful to
  -- define the static strings like "Address" on the
  -- label themselves as variables so that language
  -- translations can be done
  -- on these labels and hence making it possible to
  -- use the same label template.
    END IF;
--  FOR l_loc_rec in loc_cursor
--  LOOP
    l_rec_count := l_rec_count+1;
  --  dbms_output.put_line('first row '||l_loc_rec.locator||l_loc_rec.subinventory_code);
    WMS_CLABEL.clearLine;  -- Clear all the previous line variables
    g_printer := '3op1035ap';
    g_label := 'Location_Label';
--    WMS_CLABEL.setLabelInfo(g_label,g_printer,g_no_copies); -- do this to override
    WMS_CLABEL.setLabelInfo(null,null,null); -- do this to override
  -- Now set all the label variables
    g_variable_name := 'Zone';
    g_variable_value := l_loc_rec.subinventory_code;
    WMS_CLABEL.setLineVariable(g_variable_name,g_variable_value);
    g_variable_name := 'Locator';
    g_variable_value := l_loc_rec.locator;
    WMS_CLABEL.setLineVariable(g_variable_name,g_variable_value);
    WMS_CLABEL.writeLabel(2);  -- This call writes the variables of both the header and the lines.
  END LOOP;
  WMS_CLABEL.closeLabelFile;
  --dbms_output.put_line('Total records in the label '||to_char(l_rec_count));
  x_return_status := fnd_api.g_ret_sts_success;
exception
when others then
  x_return_status := 'E';
   --dbms_output.put_line('Invalid Path:'||sqlcode||' '||sqlerrm);
end Location_Label;
   /*---------------------------------------------------------------------*/
   -- Name
   --   PROCEDURE Item_Label
   /* --------------------------------------------------------------------*/
   --
   -- Purpose
   --   Create XML File for Item Label
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --		whether or not to commit the changes to database
   -- 	p_organization_id    	Organization Id - Required Value
   --   p_Zone_From             Zone Range From
   --   p_Zone_To               Zone Range To
   --   p_location_fr           Location Range From
   --                           (Segment Values are passed)
   --   p_location_to           Location Range To
   --                           (Segment Values are passed)
   --   p_item_fr               item Range From
   --                           (only Segment Values are passed)
   --   p_item_to                Location Range To
   --                           (only Segment Values are passed)
   --   p_no_of_copies          No of copies of duplicate labels
   --
   --
   -- Output Parameters
   --   x_return_status
   --       if the pick release process succeeds, the value is
   --		fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --		fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --		fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)

PROCEDURE Item_Label
(  p_api_version   	IN	NUMBER                          ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false     ,
   p_commit	      	IN	VARCHAR2 := fnd_api.g_false     ,
   x_return_status	OUT	VARCHAR2                        ,
   x_msg_count          OUT	NUMBER                          ,
   x_msg_data		OUT	VARCHAR2                        ,
   p_organization_id	IN	NUMBER                          ,
   p_zone_fr    	IN	VARCHAR2 := NULL                ,
   p_zone_to		IN	VARCHAR2 := NULL                ,
   p_location_fr        IN      VARCHAR2 := NULL                ,
   p_location_to        IN      VARCHAR2 := NULL               ,
   p_item_fr            IN      VARCHAR2 := NULL                ,
   p_item_to            IN      VARCHAR2 := NULL               ,
   p_no_of_copies       IN      NUMBER
) IS
begin
  null;
end Item_Label;
   /*---------------------------------------------------------------------*/
   -- Name
   --   PROCEDURE Material_Movement_Label
   /* --------------------------------------------------------------------*/
   --
   -- Purpose
   --   Create XML File for Material Movement Label like Pick and Putaway
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --		whether or not to commit the changes to database
   -- 	p_organization_id    	Organization Id - Required Value
   --   p_Move_Order_Number     Move Order Number
   --   p_Zone_From             Zone Range From
   --   p_Zone_To               Zone Range To
   --   p_location_fr           Location Range From
   --                           (only Segment Values are passed)
   --   p_location_to           Location Range To
   --                           (only Segment Values are passed)
   --   p_mo_no                 Mover Order Number
   --   p_wip_job_no            WIP Job Number
   --   p_no_of_copies          No of copies of duplicate labels
   --
   --
   -- Output Parameters
   --   x_return_status
   --       if the pick release process succeeds, the value is
   --		fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --		fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --		fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)

PROCEDURE Material_Movement_Label
(  p_api_version   	IN	NUMBER                          ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false     ,
   p_commit	      	IN	VARCHAR2 := fnd_api.g_false     ,
   x_return_status	OUT	VARCHAR2                        ,
   x_msg_count          OUT	NUMBER                          ,
   x_msg_data		OUT	VARCHAR2                        ,
   p_organization_id	IN	NUMBER                          ,
   p_zone_fr    	IN	VARCHAR2 := NULL                ,
   p_zone_to		IN	VARCHAR2 := NULL                ,
   p_location_fr        IN      VARCHAR2 := NULL                ,
   p_location_to        IN      VARCHAR2 := NULL               ,
   p_mo_no              IN      NUMBER := NULL               ,
   p_wip_job_no         IN      NUMBER := NULL                ,
   p_no_of_copies       IN      NUMBER
) is
begin
  null;
end Material_Movement_Label;
   /*---------------------------------------------------------------------*/
   -- Name
   --   PROCEDURE Palette_Label
   /* --------------------------------------------------------------------*/
   --
   -- Purpose
   --   Create XML File for Palette Label
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --		whether or not to commit the changes to database
   -- 	p_organization_id    	Organization Id - Required Value
   --   p_Move_Order_Number     Move Order Number
   --   p_Zone_From             Zone Range From
   --   p_Zone_To               Zone Range To
   --   p_Location_fr           Location Range From
   --                           (only Segment Values are passed)
   --   p_Location_to           Location Range To
   --                           (only Segment Values are passed)
   --   p_Shipment Number       Shipment Number
   --   p_Delivery_id           Delivery Id
   --   p_Delivery_line_id      Delivery Line Id
   --   p_Pslip_no              Pick Slip Number
   --   p_no_of_copies          No of copies of duplicate labels
   --
   --
   -- Output Parameters
   --   x_return_status
   --       if the pick release process succeeds, the value is
   --		fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --		fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --		fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)

PROCEDURE Palette_Label
(  p_api_version   	IN	NUMBER                          ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false     ,
   p_commit	      	IN	VARCHAR2 := fnd_api.g_false     ,
   x_return_status	OUT	VARCHAR2                        ,
   x_msg_count          OUT	NUMBER                          ,
   x_msg_data		OUT	VARCHAR2                        ,
   p_organization_id	IN	NUMBER                          ,
   p_zone_fr    	IN	VARCHAR2 := NULL                ,
   p_zone_to		IN	VARCHAR2 := NULL                ,
   p_location_fr        IN      VARCHAR2 := NULL                ,
   p_location_to        IN      VARCHAR2 := NULL               ,
   p_delivery_id        IN      NUMBER := NULL               ,
   p_shipment_number    IN      VARCHAR2 := NULL             ,
   p_delivery_line_id   IN      NUMBER := NULL               ,
   p_pslip_number       IN      VARCHAR2 := NULL          ,
   p_no_of_copies       IN      NUMBER
)is
begin
  null;
end Palette_Label;
   /*---------------------------------------------------------------------*/
   -- Name
   --   PROCEDURE Kanban_Card_Label
   /* --------------------------------------------------------------------*/
   --
   -- Purpose
   --   Create XML File for Kanban Card Label
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --		whether or not to commit the changes to database
   --   p_kanban_card_id_fr        Kanban Card Id Range from
   --   p_kanban_card_id_to        Kanban Card Id Range To
   --   p_no_of_copies          No of copies of duplicate labels
   --
   --
   -- Output Parameters
   --   x_return_status
   --       if the pick release process succeeds, the value is
   --		fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --		fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --		fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)

PROCEDURE  Kanban_Card_Label
(  p_api_version   	IN	NUMBER                          ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false     ,
   p_commit	      	IN	VARCHAR2 := fnd_api.g_false     ,
   x_return_status	OUT	VARCHAR2                        ,
   x_msg_count          OUT	NUMBER                          ,
   x_msg_data		OUT	VARCHAR2                        ,
   p_kanban_card_id_fr	IN	NUMBER                          ,
   p_kanban_card_id_to	IN	NUMBER                  ,
   p_no_of_copies       IN      NUMBER
)is
begin
  null;
end Kanban_Card_Label;
   /*---------------------------------------------------------------------*/
   -- Name
   --   PROCEDURE LPN_Label
   /* --------------------------------------------------------------------*/
   --
   -- Purpose
   --   Create XML File for LPN Label
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --		whether or not to commit the changes to database
   --   p_lpn_fr              LPN Range from
   --   p_lpn_to              LPN Range To
   --   p_customer_id         Customer ID
   --   p_ship_to_loc_id      Ship To Location ID
   --   p_Include_Contents    Include LPn Contents
   --   p_no_of_copies          No of copies of duplicate labels
   --
   --
   -- Output Parameters
   --   x_return_status
   --       if the pick release process succeeds, the value is
   --		fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --		fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --		fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)

PROCEDURE  LPN_Label
(  p_api_version   	IN	NUMBER                          ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false     ,
   p_commit	      	IN	VARCHAR2 := fnd_api.g_false     ,
   x_return_status	OUT	VARCHAR2                        ,
   x_msg_count          OUT	NUMBER                          ,
   x_msg_data		OUT	VARCHAR2                        ,
   p_lpn_fr        	IN      VARCHAR2                        ,
   p_lpn_to     	IN	VARCHAR2                        ,
   p_customer_id        IN      NUMBER                          ,
   p_ship_to_loc_id     IN      NUMBER                          ,
   p_include_contents   IN	VARCHAR2                        ,
   p_no_of_copies       IN      NUMBER
)is
begin
  null;
end LPN_Label;

   /*---------------------------------------------------------------------*/
   -- Name
   --   PROCEDURE Shipping Label
   /* --------------------------------------------------------------------*/
   --
   -- Purpose
   --   Create XML File for Shipping Label
   --
   -- Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --		whether or not to commit the changes to database
   -- 	p_organization_id    	Organization Id - Required Value
   --   p_Move_Order_Number     Move Order Number
   --   p_Zone_From             Zone Range From
   --   p_Zone_To               Zone Range To
   --   p_Location_fr           Location Range From
   --                           (only Segment Values are passed)
   --   p_Location_to           Location Range To
   --                           (only Segment Values are passed)
   --   p_Shipment Number       Shipment Number
   --   p_Delivery_id           Delivery Id
   --   p_Delivery_line_id      Delivery Line Id
   --   p_Pslip_no              Pick Slip Number
   --   p_no_of_copies          No of copies of duplicate labels
   --
   --
   -- Output Parameters
   --   x_return_status
   --       if the pick release process succeeds, the value is
   --		fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --		fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --		fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)

PROCEDURE Shipping_Label
(  p_api_version   	IN	NUMBER                          ,
   p_init_msg_list	IN	VARCHAR2 := fnd_api.g_false     ,
   p_commit	      	IN	VARCHAR2 := fnd_api.g_false     ,
   x_return_status	OUT	VARCHAR2                        ,
   x_msg_count          OUT	NUMBER                          ,
   x_msg_data		OUT	VARCHAR2                        ,
   p_organization_id	IN	NUMBER                          ,
   p_zone_fr    	IN	VARCHAR2 := NULL                ,
   p_zone_to		IN	VARCHAR2 := NULL                ,
   p_location_fr        IN      VARCHAR2 := NULL                ,
   p_location_to        IN      VARCHAR2 := NULL              ,
   p_delivery_id        IN      NUMBER := NULL               ,
   p_shipment_number    IN      VARCHAR2 := NULL             ,
   p_delivery_line_id   IN      NUMBER := NULL               ,
   p_pslip_number       IN      VARCHAR2 := NULL              ,
   p_no_of_copies       IN      NUMBER
)is
begin
  null;
end Shipping_Label;
   /*---------------------------------------------------------------------*/
   -- Name
   --   FUNCTION Output_file_dir
   /* --------------------------------------------------------------------*/
function Output_file_dir return varchar2
IS
   v_db_name VARCHAR2(100);
   v_log_name VARCHAR2(100);
   v_db_name VARCHAR2(100);
   v_st_position number(3);
   v_end_position number(3);
   v_w_position number(3);

BEGIN
   select INSTR(value,',',1,2),INSTR(value,',',1,3)
   into v_st_position,v_end_position from  v$parameter
   where upper(name) = 'UTL_FILE_DIR';

   v_w_position := v_end_position - v_st_position - 1;

   select substr(value,v_st_position+1,v_w_position)
   into v_log_name from v$parameter
   where upper(name) = 'UTL_FILE_DIR';
   v_log_name := ltrim(v_log_name);
   FND_FILE.PUT_NAMES(v_log_name,v_log_name,v_log_name);
   return v_log_name;
EXCEPTION
WHEN OTHERS then
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Output_file_dir;
/*---------------------------------------------------------*/
END WMS_Label_PUB;

/
