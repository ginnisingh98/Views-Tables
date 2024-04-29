--------------------------------------------------------
--  DDL for Package Body CHV_SCHEDULE_ORGS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_SCHEDULE_ORGS_PKG_S1" as
/* $Header: CHVSORGB.pls 115.0 99/07/17 01:31:54 porting ship $ */
/*===========================================================================

   PROCEDURE NAME:  Insert_Row()

=============================================================================*/
PROCEDURE Insert_Row(
                     X_Batch_Id      IN   NUMBER,
		     X_Organization_Id        IN   NUMBER
                    ) IS

BEGIN

  INSERT INTO chv_schedule_organizations(Batch_Id,
				         Organization_Id)
			          values(
					 X_Batch_Id,
					 X_Organization_Id) ;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND ;
  end if ;

END Insert_Row ;

END CHV_SCHEDULE_ORGS_PKG_S1;

/
