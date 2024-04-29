--------------------------------------------------------
--  DDL for Package CHV_BUILD_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_BUILD_REVISION" AUTHID CURRENT_USER as
/*$Header: CHVPRBRS.pls 115.0 99/07/17 01:29:43 porting ship $*/

/*===========================================================================
  PACKAGE NAME:  CHV_BUILD_REVISION
  DESCRIPTION:   This package contains the server side of Supplier Scheduling
		 APIs to rebuild schedules

  CLIENT/SERVER: Server

  OWNER:         Kim  Powell

============================================================================*/

/*===========================================================================
  PROCEDURE NAME	create_schedule_revision

  CHANGE HISTORY      :  Created            23-APR-1995     KPOWELL
==========================================================================*/
PROCEDURE create_schedule_revision(p_schedule_id	     in NUMBER,
                         	   p_owner_id 		     in NUMBER,
			 	   p_batch_id 		     in NUMBER);


END CHV_BUILD_REVISION;

 

/
