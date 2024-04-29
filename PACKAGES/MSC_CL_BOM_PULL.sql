--------------------------------------------------------
--  DDL for Package MSC_CL_BOM_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_BOM_PULL" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCPBOMS.pls 120.1 2007/04/05 08:42:12 vpalla noship $ */
--   SYS_YES                      CONSTANT NUMBER := MSC_UTIL.SYS_YES;
--   SYS_NO                       CONSTANT NUMBER := MSC_UTIL.SYS_NO   ;

--   G_SUCCESS                    CONSTANT NUMBER := MSC_UTIL.G_SUCCESS;
--   G_WARNING                    CONSTANT NUMBER := MSC_UTIL.G_WARNING;
--   G_ERROR                      CONSTANT NUMBER := MSC_UTIL.G_ERROR  ;

--   G_APPS107                    CONSTANT NUMBER := MSC_UTIL.G_APPS107;
--   G_APPS110                    CONSTANT NUMBER := MSC_UTIL.G_APPS110;
--   G_APPS115                    CONSTANT NUMBER := MSC_UTIL.G_APPS115;
--   G_APPS120                    CONSTANT NUMBER := MSC_UTIL.G_APPS120;

     -- BOM ROUNDING DIRECTION --

   G_ROUND_DOWN                 CONSTANT NUMBER := 1;
   G_ROUND_UP                   CONSTANT NUMBER := 2;
   G_ROUND_NONE                 CONSTANT NUMBER := 3;

   PROCEDURE LOAD_BOM;
   PROCEDURE LOAD_PROCESS_EFFECTIVITY ;
   PROCEDURE LOAD_BOR;
   PROCEDURE LOAD_RESOURCE;
   PROCEDURE LOAD_CO_PRODUCT_BOMS;

   /*ds_plan: change */
   PROCEDURE LOAD_RESOURCE_INSTANCE;
   PROCEDURE LOAD_RESOURCE_SETUP;

END MSC_CL_BOM_PULL;

/
