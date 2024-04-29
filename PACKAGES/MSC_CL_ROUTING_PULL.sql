--------------------------------------------------------
--  DDL for Package MSC_CL_ROUTING_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_ROUTING_PULL" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCPRTGS.pls 120.0 2007/04/05 11:02:13 vpalla noship $ */

---   SYS_YES                      CONSTANT NUMBER := MSC_UTIL.SYS_YES;
--   SYS_NO                       CONSTANT NUMBER := MSC_UTIL.SYS_NO   ;

 --  G_SUCCESS                    CONSTANT NUMBER := MSC_UTIL.G_SUCCESS;
 --  G_WARNING                    CONSTANT NUMBER := MSC_UTIL.G_WARNING;
 --  G_ERROR                      CONSTANT NUMBER := MSC_UTIL.G_ERROR  ;

 --  G_APPS107                    CONSTANT NUMBER := MSC_UTIL.G_APPS107;
 --  G_APPS110                    CONSTANT NUMBER := MSC_UTIL.G_APPS110;
 --  G_APPS115                    CONSTANT NUMBER := MSC_UTIL.G_APPS115;
--   G_APPS120                    CONSTANT NUMBER := MSC_UTIL.G_APPS120;

   PROCEDURE LOAD_ROUTING;
   PROCEDURE LOAD_ROUTING_OPERATIONS ;
   PROCEDURE LOAD_OPERATION_RES_SEQS ;
   PROCEDURE LOAD_OPERATION_RESOURCES;
   PROCEDURE LOAD_OPERATION_COMPONENTS ;

END MSC_CL_ROUTING_PULL;

/
