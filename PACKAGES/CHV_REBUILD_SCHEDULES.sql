--------------------------------------------------------
--  DDL for Package CHV_REBUILD_SCHEDULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_REBUILD_SCHEDULES" AUTHID CURRENT_USER as
/*$Header: CHVPRRBS.pls 115.0 99/07/17 01:30:19 porting ship $*/

/*===========================================================================
  PACKAGE NAME:  CHV_REBUILD_SCHEDULES
  DESCRIPTION:   This package contains the server side of Supplier Scheduling
		 APIs to rebuild schedules

  CLIENT/SERVER: Server

  OWNER:         Kim  Powell

============================================================================*/

/*===========================================================================
  PROCEDURE NAME      :  rebuild_scheduled_items

  CHANGE HISTORY      :  Created            23-APR-1995     KPOWELL
==========================================================================*/
PROCEDURE rebuild_item(p_schedule_id	     in NUMBER,
                         p_autoconfirm_flag          in VARCHAR2,
                         p_print_flag                in VARCHAR2 DEFAULT null);

END CHV_REBUILD_SCHEDULES;

 

/
