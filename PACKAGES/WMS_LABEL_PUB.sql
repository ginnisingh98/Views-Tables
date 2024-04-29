--------------------------------------------------------
--  DDL for Package WMS_LABEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_LABEL_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSLABLS.pls 115.0 2000/07/07 15:47:32 pkm ship        $ */

/* Define global variables */
  g_dir       VARCHAR2(100); -- get this from profile
  g_file      VARCHAR2(30);  -- generate this based on a sequence or request id
                             -- since it has to be unique
  g_printer   VARCHAR2(30);  -- get this from profile
  g_label     VARCHAR2(30);  -- get this based on business logic
  g_no_copies NUMBER;        -- get this based on business logic
  g_variable_name VARCHAR2(30); -- get the variable name used in the label template
  g_variable_value VARCHAR2(4000); -- get this based on the business logic

   /*---------------------------------------------------------------------*/
   -- Name
   --   FUNCTION Output_file_dir
   /* --------------------------------------------------------------------*/
   -- Purpose
   --   Extract the outfile dir name from the database

   FUNCTION Output_file_dir return varchar2;
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
   --   p_no_of_copies          Number of copies of dupliate label
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
   p_no_of_copies       IN      NUMBER := 1
);
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
   --   p_no_of_copies          Number of copies of dupliate label
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
   p_item_to            IN      VARCHAR2 := NULL       ,
   p_no_of_copies       IN      NUMBER
);
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
   --   p_no_of_copies          Number of copies of dupliate label
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
);
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
   --   p_no_of_copies          Number of copies of dupliate label
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
   p_pslip_number       IN      VARCHAR2 := NULL             ,
   p_no_of_copies       IN      NUMBER
);
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
   --   p_no_of_copies          Number of copies of dupliate label
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
   p_kanban_card_id_to	IN	NUMBER                          ,
   p_no_of_copies       IN      NUMBER
);
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
   --   p_no_of_copies          Number of copies of dupliate label
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
);

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
   --   p_no_of_copies          Number of copies of dupliate label
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
   p_pslip_number       IN      VARCHAR2 := NULL             ,
   p_no_of_copies       IN      NUMBER
);
END WMS_Label_PUB;

 

/
