--------------------------------------------------------
--  DDL for Package MSC_CL_DEMAND_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_DEMAND_PULL" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCPDEMS.pls 120.1 2007/10/08 06:45:02 rsyadav noship $ */

  -- SYS_YES                      CONSTANT NUMBER := MSC_UTIL.SYS_YES;
  -- SYS_NO                       CONSTANT NUMBER := MSC_UTIL.SYS_NO   ;

  -- G_SUCCESS                    CONSTANT NUMBER := MSC_UTIL.G_SUCCESS;
  -- G_WARNING                    CONSTANT NUMBER := MSC_UTIL.G_WARNING;
  -- G_ERROR                      CONSTANT NUMBER := MSC_UTIL.G_ERROR  ;

  -- G_APPS107                    CONSTANT NUMBER := MSC_UTIL.G_APPS107;
  -- G_APPS110                    CONSTANT NUMBER := MSC_UTIL.G_APPS110;
  -- G_APPS115                    CONSTANT NUMBER := MSC_UTIL.G_APPS115;
  -- G_APPS120                    CONSTANT NUMBER := MSC_UTIL.G_APPS120;

   PROCEDURE LOAD_FORECASTS;
   PROCEDURE LOAD_ITEM_FORECASTS;
   PROCEDURE LOAD_MDS_DEMAND;
   PROCEDURE LOAD_SALES_ORDER( p_worker_num IN NUMBER);
   PROCEDURE LOAD_HARD_RESERVATION;
   PROCEDURE LOAD_USER_DEMAND;
   PROCEDURE LOAD_AHL ;
   PROCEDURE LOAD_OPEN_PAYBACKS;
END MSC_CL_DEMAND_PULL;

/