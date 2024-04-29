--------------------------------------------------------
--  DDL for Package MSC_M2A_PUSH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_M2A_PUSH" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCPUSHS.pls 120.0 2005/05/25 19:27:59 appldev noship $ */

-- CONSTANTS --
    SYS_YES                 CONSTANT INTEGER := 1;
    SYS_NO                  CONSTANT INTEGER := 2;

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;
   G_MPS_IND                    CONSTANT NUMBER := 2;

   G_APPS107                    CONSTANT NUMBER := 1;
   G_APPS110                    CONSTANT NUMBER := 2;
   G_APPS115                    CONSTANT NUMBER := 3;


   -- Misc --
   NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';

   --  ================= Procedures ====================

   PROCEDURE PUSH_PLAN_INFO(
                      ERRBUF				 OUT NOCOPY VARCHAR2,
	              RETCODE				 OUT NOCOPY NUMBER,
                      pINSTANCE_ID                       IN  NUMBER,
 		      pPLAN_TYPE			 IN  VARCHAR2, -- dummy arg
                      pDESIGNATOR                        IN  VARCHAR2 := NULL,
                      pBUY_ORDERS_ONLY                   IN  NUMBER := SYS_YES,
                      pDEMAND                            IN  NUMBER default 1,
                      pORGANIZATION_ID                   IN  NUMBER,
                             pPLANNER                           IN  VARCHAR2,
                             pCATEGORY_ID                       IN  NUMBER,
                             pITEM_ID                           IN  NUMBER,
                             pDUMMY2                            IN NUMBER,
                             pSUPPLIER_ID                       IN  NUMBER,
                             pDUMMY3                            IN NUMBER,
                             pSUPPLIER_SITE_ID                  IN  NUMBER,
                             pHORIZON_START_DATE                IN  VARCHAR2,
                             pHORIZON_END_DATE                  IN  VARCHAR2); --for bug 3073566

END MSC_M2A_PUSH;
 

/
