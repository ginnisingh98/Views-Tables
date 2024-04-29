--------------------------------------------------------
--  DDL for Package GMI_UPDATE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_UPDATE_ORDER" AUTHID CURRENT_USER AS
/*  $Header: GMIUSITS.pls 115.0 2003/12/05 16:44:24 hwahdani noship $ */
/* +=========================================================================+
 |                Copyright (c) 2003 Oracle Corporation                    |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIUSITS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This file is introduced for WSH.J release.                          |
 |     The procedure process_order is called from WSHDDSHB.pls to process  |
 |     OPM Internal orders. The same procedure for earlier releases is     |
 |     already in use and declared in GMIUSHPB.pls and procedure is called |
 |     process_opm_orders                                                  |
 |                                                                         |
 | HISTORY                                                                 |
 |     HAW Initianl release 115.0                                          |
 +=========================================================================+
*/

PROCEDURE process_order(
  P_stop_tab IN  wsh_util_core.id_tab_type
  ,x_return_status OUT NOCOPY VARCHAR2  );


END GMI_UPDATE_ORDER;


 

/
