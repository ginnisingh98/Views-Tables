--------------------------------------------------------
--  DDL for Package WIP_ATO_JOBS_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_ATO_JOBS_PRIV" AUTHID CURRENT_USER AS
/* $Header: wipvfass.pls 120.0 2005/07/04 21:46 amgarg noship $ */
/*========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA |
|                          All rights reserved.                           |
+=========================================================================+
|                                                                         |
| File Name    : WIPVFASS.PLS                                             |
|                                                                         |
| DESCRIPTION  : Package Specification for Autocreate FAS.                |
|                                                                         |
| Coders       : Amit Garg                                                |
|                                                                         |
| PURPOSE:      Create Discrete Jobs to satisfy sales order demand for    |
|               replenish-to-order items that meet the user-input criteria|
|                                                                         |
|                                                                         |
|                                                                         |
| PROGRAM SYNOPSIS:                                                       |
|  1.  Update records in mtl_demand that meet criteria with a group_id    |
|  2.  Insert records into wip_entities_interface for mtl_demands records |
|      marked with group_id                                               |
|  3.  Read wip_entities_interface records and inform OE of sales order   |
|      lines that have been linked to WIP                                 |
|  4.  Call mass load routine to create jobs from wip_entities_interface  |
|      records                                                            |
|  5.  Do feedback:                                                       |
|      1.  Update mtl_demand for jobs successfully loaded                 |
|      2.  Create records in wip_so_allocations                           |
|      3.  Read wip_entities_interface and inform OE of sales order       |
|          lines that should be unlinked from WIP                         |
|      4.  Update mtl_demand for jobs that failed load so they can be     |
|          picked up again                                                |
|  6.  Launch report of what occurred in process                          |
|  7.  Delete records from interface table                                |
|                                                                         |
| CALLED BY:   Concurrent Program                                         |
|                                                                         |
|                                                                         |
| HISTORY:                                                                |
+=========================================================================*/

--Global Constants


/*-----------------------------------------------------------+
 |  Defines for linking or unlinking OE order to WIP         |
 +-----------------------------------------------------------+*/
WILINK CONSTANT NUMBER := 1;
WIUNLINK CONSTANT NUMBER := 2;

WPENDING    CONSTANT NUMBER := 1;
WRUNNING    CONSTANT NUMBER := 2;
WERROR      CONSTANT NUMBER := 3;
WCOMPLETED  CONSTANT NUMBER := 4;
WWARNING    CONSTANT NUMBER := 5;

WIP_ML_VALIDATION CONSTANT NUMBER := 2;
WIP_ML_EXPLOSION  CONSTANT NUMBER := 3;
WIP_ML_INSERTION  CONSTANT NUMBER := 5;
WIP_ML_COMPLETE   CONSTANT NUMBER := 4;



PROCEDURE CREATE_JOBS(
          ERRBUF            OUT   NOCOPY VARCHAR2 ,
          RETCODE           OUT   NOCOPY VARCHAR2,
          P_ORDER_NUMBER    IN    VARCHAR2 ,
          P_DUMMY_FIELD     IN    VARCHAR2 ,
          P_OFFSET_DAYS     IN    VARCHAR2 ,
          P_LOAD_TYPE       IN    VARCHAR2 , --CHANGED
          P_STATUS_TYPE     IN    VARCHAR2 , --CHANGED
          P_ORG_ID          IN    VARCHAR2 , --CHANGED
          P_CLASS_CODE      IN    VARCHAR2 , --CHANGED
          P_FAILED_REQ_ID   IN    VARCHAR2 ,
          P_ORDER_LINE_ID   IN    VARCHAR2 ,
          P_BATCH_ID        IN    VARCHAR2);


FUNCTION LOAD_ORDERS
(
          ERRBUF          OUT   NOCOPY VARCHAR2,
          RETCODE         OUT   NOCOPY VARCHAR2,
          P_ORDER_NUMBER    IN    NUMBER DEFAULT -1,
          p_DUMMY_FIELD     IN    NUMBER DEFAULT -1,
          p_OFFSET_DAYS     IN    NUMBER DEFAULT -1,
          p_LOAD_TYPE       IN    NUMBER DEFAULT -1,
          p_STATUS_TYPE     IN    NUMBER DEFAULT -1,
          p_ORG_ID          IN    NUMBER DEFAULT -1,
          p_CLASS_CODE      IN    VARCHAR2 DEFAULT -1,
          p_FAILED_REQ_ID   IN    NUMBER DEFAULT -1,
          p_ORDER_LINE_ID   IN    NUMBER DEFAULT -1,
          p_BATCH_ID        IN    NUMBER DEFAULT -1,
          p_all_success_ptr IN OUT NOCOPY NUMBER )

RETURN    boolean;


Function delete_interface_orders(p_wei_group_id  NUMBER)
return boolean ;


END WIP_ATO_JOBS_PRIV;


 

/
