--------------------------------------------------------
--  DDL for Package Body CHV_ITEM_ORDERS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_ITEM_ORDERS_PKG_S1" as
/* $Header: CHVSORDB.pls 115.0 99/07/17 01:31:46 porting ship $ */
/*===========================================================================

   PROCEDURE NAME:  delete_row()

=============================================================================*/
PROCEDURE delete_row(X_Schedule_Id           IN   NUMBER,
                     X_Schedule_Item_ID      IN   NUMBER
                    ) IS

BEGIN

  DELETE FROM chv_item_orders
   WHERE schedule_id      = X_Schedule_Id
     AND schedule_item_id = X_Schedule_Item_Id ;

  if (SQL%NOTFOUND) then
     null ;
  end if ;

END delete_row ;

END CHV_ITEM_ORDERS_PKG_S1;

/
