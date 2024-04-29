--------------------------------------------------------
--  DDL for Package Body MSC_CL_CLEANSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_CLEANSE" AS -- body
/* $Header: MSCCLCAB.pls 120.0 2005/05/25 20:00:48 appldev noship $ */


   PROCEDURE CLEANSE( ERRBUF				OUT NOCOPY VARCHAR2,
	              RETCODE				OUT NOCOPY NUMBER,
                      pIID                              IN  NUMBER)
   IS
   BEGIN
       RETCODE:= G_SUCCESS;
   END ;

   --This package will be called from the release code. Any data cleansing
   --can be performed while releasing the data to the source.
   --P_ENTITY          - Added for future use.
   --P_SR_INSTANCE_ID  - Instance Identifier
   --P_PO_BATCH_NUMBER - Identifier to process the relevant data.
   PROCEDURE CLEANSE_RELEASE(  ERRBUF            OUT NOCOPY VARCHAR2,
                               RETCODE           OUT NOCOPY NUMBER,
                               P_ENTITY          IN  VARCHAR2,
                               P_SR_INSTANCE_ID  IN  NUMBER,
                               P_PO_BATCH_NUMBER IN  NUMBER)
   IS
   BEGIN
       RETCODE := G_SUCCESS;
   END;

END MSC_CL_CLEANSE;

/
