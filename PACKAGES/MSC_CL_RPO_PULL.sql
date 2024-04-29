--------------------------------------------------------
--  DDL for Package MSC_CL_RPO_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_RPO_PULL" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCPRPOS.pls 120.0 2007/04/05 10:48:43 vpalla noship $ */

  -- SYS_YES                      CONSTANT NUMBER := MSC_UTIL.SYS_YES;
  -- SYS_NO                       CONSTANT NUMBER := MSC_UTIL.SYS_NO   ;

 --  G_SUCCESS                    CONSTANT NUMBER := MSC_UTIL.G_SUCCESS;
 --  G_WARNING                    CONSTANT NUMBER := MSC_UTIL.G_WARNING;
 --  G_ERROR                      CONSTANT NUMBER := MSC_UTIL.G_ERROR  ;

 --  G_APPS107                    CONSTANT NUMBER := MSC_UTIL.G_APPS107;
 --  G_APPS110                    CONSTANT NUMBER := MSC_UTIL.G_APPS110;
 --  G_APPS115                    CONSTANT NUMBER := MSC_UTIL.G_APPS115;
 --  G_APPS120                    CONSTANT NUMBER := MSC_UTIL.G_APPS120;

   PROCEDURE LOAD_IRO  ;
   PROCEDURE LOAD_IRO_DEMAND;   -- For SRP Bug # 5909379

   PROCEDURE LOAD_ERO  ;
   PROCEDURE LOAD_ERO_DEMAND; -- For SRP Bug # 5935273

END MSC_CL_RPO_PULL;

/
