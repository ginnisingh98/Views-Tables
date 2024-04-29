--------------------------------------------------------
--  DDL for Package MSC_CL_CLEANSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_CLEANSE" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCCLCAS.pls 120.0 2005/05/27 07:26:58 appldev noship $ */

  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   PROCEDURE CLEANSE( ERRBUF				OUT NOCOPY VARCHAR2,
	              RETCODE				OUT NOCOPY NUMBER,
                      pIID                              IN  NUMBER);

   PROCEDURE CLEANSE_RELEASE(  ERRBUF            OUT NOCOPY VARCHAR2,
                               RETCODE           OUT NOCOPY NUMBER,
                               P_ENTITY          IN  VARCHAR2,
                               P_SR_INSTANCE_ID  IN  NUMBER,
                               P_PO_BATCH_NUMBER IN  NUMBER);

END MSC_CL_CLEANSE;
 

/
