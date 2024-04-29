--------------------------------------------------------
--  DDL for Package CTO_CHANGE_ORDER_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CHANGE_ORDER_PK" AUTHID CURRENT_USER as
/* $Header: CTOCHODS.pls 120.5 2005/10/11 15:12:51 rkaza noship $ */

/********************************************************************************************************
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA					|
|                         All rights reserved,								|
|                         Oracle Manufacturing								|
|   File Name 		: CTOCHODS.pls								|
|													|
|   Description 	: Get the change order information from order management and send the 		|
|                         information to certain workflow users.					|
|													|
|   History		: Created on 10-aug-2000 by Renga Kannan					|
|                         Modified    12/29/2000 by Renga Kannan                                        |
|                         Modiefed    02/10/2001 by Renga Kannan -- Added new procedure for ML/MO case  |
|                         Modified    02/17/2001 by Renga Kannan -- Changed the signature of            |
|                                                                   send_notification procedure added   |
|                                                                   Added multi level/multi org flag    |
|                                     02/27/2001 by Renga Kannan -- Modified the signature for          |
|                                                                   change_notify made the line_id      |
|                                                                   argument as optional one as OM will |
|                                                                   not pass the line_id in the case of |
|                                                                   adding new option class/option item |
|                                                                   in PTO-ATO                          |
|                                     03/13/2001 By Renga Kannan -- One more pkg variable is added      |
|                                                                   to handle the Delink action         |
|                                                                   from Sales order Pad                |
|                                                                                                       |
|                                                                                                       |
|                                     09/20/2001 By Renga Kannan -- Modified the signature of the       |
|                                                                   Is_item_ml_or_mo, added source_type |
|                                                                   as out variable                     |
|
|				      02/04/2003 Kiran Konada
|						Added a new paramter to pass conifg/ato item id
|						to start_work_flow
|						bugfix 2782394
|
|              Modified on 14-MAR-2003 By Sushant Sawant
|                                         Decimal-Qty Support for Option Items.
|                                         Changed Signature of CHANGE_NOTIFY
|
|              Modified on 01-Jun-2005 By Renga Kannan
|                                         Added NOCOPY Hint

********************************************************************************************************/




     --  Change type constants
     RD_CHANGE       CONSTANT   INTEGER  := 10; --   Request date change
     SSD_CHANGE      CONSTANT   INTEGER  := 20; --   Schedule_ship_date change
     SAD_CHANGE      CONSTANT   INTEGER  := 30; --   Schedule_arrival_date change
     QTY_CHANGE      CONSTANT   INTEGER  := 40; --   Quantity Change
     CONFIG_CHANGE   CONSTANT   INTEGER  := 50; --   Configuration Change
     DELINK_ACTION   CONSTANT   INTEGER  := 60; --   Delink Action from Sales order pad
     WAREHOUSE_CHANGE CONSTANT  INTEGER := 70; --    Warehouse change
     SPLIT_LINE_ACTION  CONSTANT  INTEGER := 80; -- Split Line Action
     --new change type constants for R12 for OPM project
     QTY2_CHANGE       CONSTANT INTEGER :=90; --secondary quantity change
     QTY2_UOM_CHANGE  CONSTANT INTEGER :=100;--Secondary UOM chnage
     QTY_UOM_CHANGE     CONSTANT  INTEGER := 110;--Primary quantity UOM change



     -- The above Delink_action is added by Renga on 03/13/01 to send Notification during delink_item action.

     -- Added by Renga Kannan on 03/13/2001. This pkg variable will act as an indicator
     -- For the delink procedure. Whenever the delink procedure is called from CTO_CHANGE_ORDER_PKG
     -- this variable will be set to 1 other wise this will have the default value as 0.
     -- The delink procedure will look at this variable value and decide to call the notification.

     CHANGE_ORDER_PK_STATE  NUMBER := 0;


     TYPE CHANGE_REC_TYPE IS RECORD(
                                     change_type     number(3),--change to 3 for new 3 digit constants
                                     old_value       varchar2(50),
                                     new_value       varchar2(50)
                                   );


     TYPE CHANGE_TABLE_TYPE IS TABLE OF CHANGE_REC_TYPE INDEX BY BINARY_INTEGER;



     /* Added by Sushant for Decimal-Qty Support for Option Items */
     /* for order quantity changes for option items */
     TYPE OPTION_CHG_DETAILS_TYPE IS RECORD(
                                   Line_id             oe_order_lines.line_id%type ,
                                   Action              varchar2(50),
                                   Old_Qty             number ,
                                   New_Qty             number ,
                                   Inventory_Item_id   mtl_system_items.inventory_item_id%type
                                  );

     TYPE SPLIT_CHG_REC_TYPE IS RECORD(
                                   Line_id             oe_order_lines.line_id%type
                                   );


     /* Added by Sushant for Decimal-Qty Support for Option Items */
     TYPE OPTION_CHG_TABLE_TYPE IS TABLE OF OPTION_CHG_DETAILS_TYPE INDEX BY BINARY_INTEGER;

     TYPE SPLIT_CHG_TABLE_TYPE IS TABLE OF SPLIT_CHG_REC_TYPE INDEX BY BINARY_INTEGER;


     v_option_chg_table  OPTION_CHG_TABLE_TYPE ;
     v_split_chg_table   SPLIT_CHG_TABLE_TYPE ;


/********************************************************************************************************
+   Name	: Change_Notify										+
+   													+
+   Description : This funcation gets the input data from Order Management and look for the             +
+                 type of change. Based on the type of change and the reservation exists for this       +
+                 customer order this will invoke a notification workflow.				+
+ 													+
+   Output     : x_return_status will be success if this function is executed successfully		+
+                 x_return_status will be error if this function errored out in some place		+
+													+
+													+
+													+
********************************************************************************************************/

    PROCEDURE Change_Notify(
             pLineid 		in	number DEFAULT NULL,  -- Default clause is added by Renga on 02/27/01
             Pchgtype 		in	change_table_type,
             X_return_status	out Nocopy    varchar2,
             X_Msg_Count	out NoCopy    number,
             X_Msg_Data   	out NoCopy    varchar2,
             PoptionChgDtls  in         OPTION_CHG_TABLE_TYPE default  v_option_chg_table,
             PsplitDtls  in             SPLIT_CHG_TABLE_TYPE default  v_split_chg_table);


/********************************************************************************************************
+   Name	: Reservation_exists									+
+     													+
+   Description : This function checks whether any reservation made for this customer order             +
+                 The reservation can be either inventory or wip.					+
+     													+
+   Output	: x_result will be TRUE if reservation exists 						+
+                 x_result will be FALSE if reservation does not exists					+
+													+
********************************************************************************************************/


    PROCEDURE  Reservation_Exists(
              Pconfiglineid	in	number,
              X_return_status 	out Nocopy	varchar2,
              X_result		out Nocopy	boolean,
              X_Msg_Count	out Nocopy	number,
              X_Msg_Data	out Nocopy	varchar2) ;

/********************************************************************************************************
+   Name	: Start_Work_Flow									+
+													+
+   Description : This procedure set the attributes for workflow and start the workflow process		+
+                 The workflow contains one activity of sending notification				+
+													+
********************************************************************************************************/

    PROCEDURE Start_Work_Flow(
              pOrder_no		in	number,
              pLine_no 		in	number,
              pchgtype 		in	change_table_type,
              pmlmo_flag        in      varchar2,
              pconfig_id        in      number,
              x_return_status	out Nocopy varchar2,
	      X_Msg_Count	out Nocopy number,
              X_Msg_Data	out Nocopy varchar2,
              PsplitDtls  in     SPLIT_CHG_TABLE_TYPE default  v_split_chg_table );




/***********************************************************************************************************
*                                                                                                           *
*                                                                                                           *
*    Procedure Name : Is_item_ML_OR_MO                                                                      *
*                                                                                                           *
*    Input         : PInventory_item_id                                                                     *
*                    porg_id                                                                                *
*                                                                                                           *
*    Output        : X_result  --   TRUE/FALSE                                                              *
*                                                                                                           *
*    Description   : This procedure will check whether the given inventory_item in the given org is         *
*                    eithe Multi level or Multi org. If either of them is true it will return TRUE.         *
*                    If it is neither Multi level/Multi Org it will return FALSE                            *
*                                                                                                           *
*                                                                                                           *
************************************************************************************************************/



PROCEDURE  Is_item_ML_OR_MO(
                           pInventory_item_id    IN   mtl_system_items.inventory_item_id%type,
                           pOrg_id               IN   mtl_system_items.organization_id%type,
                           x_result              OUT Nocopy Varchar2,
                           x_source_type         OUT Nocopy Number,
                           x_return_status       OUT Nocopy  Varchar2,
                           x_msg_count           OUT Nocopy Number,
                           x_msg_data            OUT Nocopy Varchar2);



-- rkaza. ireq project. 05/11/2005. Helper procedure to do delete a record from
-- req interface table.
-- Start of comments
-- API name : delete_from_req_interface
-- Type	    : Public
-- Pre-reqs : None.
-- Function : Given orer line id, it deletes the corresponding req interface
--	      records.
-- Parameters:
-- IN	    : p_line_id           	IN NUMBER	Required
--	         order line id.
-- IN       : p_item_id      IN   number required
-- Version  :
--	      Initial version 	115.20
-- End of comments
Procedure delete_from_req_interface(p_line_id IN Number,
                                    p_item_id IN Number,
			   	    x_return_status OUT NOCOPY varchar2);



END CTO_CHANGE_ORDER_PK;


 

/
