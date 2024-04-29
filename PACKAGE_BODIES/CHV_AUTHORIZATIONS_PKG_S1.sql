--------------------------------------------------------
--  DDL for Package Body CHV_AUTHORIZATIONS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_AUTHORIZATIONS_PKG_S1" as
/* $Header: CHVSAUTB.pls 115.0 99/07/17 01:30:32 porting ship $ */
/*===========================================================================

   PROCEDURE NAME:  delete_row()

=============================================================================*/
PROCEDURE delete_row(
                     X_Schedule_Item_ID      IN   NUMBER
                    ) IS

BEGIN

  DELETE FROM chv_authorizations
   WHERE reference_id     = X_Schedule_Item_Id
     AND reference_type   = 'SCHEDULE_ITEMS' ;

  if (SQL%NOTFOUND) then
     null ;
  end if ;

END delete_row ;

END CHV_AUTHORIZATIONS_PKG_S1;

/
