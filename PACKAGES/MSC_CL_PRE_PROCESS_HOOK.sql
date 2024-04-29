--------------------------------------------------------
--  DDL for Package MSC_CL_PRE_PROCESS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_PRE_PROCESS_HOOK" AUTHID CURRENT_USER AS
/* $Header: MSCCPPHS.pls 115.4 2002/11/29 17:33:26 rawasthi ship $ */
   PROCEDURE ENTITY_VALIDATION( ERRBUF                          OUT NOCOPY VARCHAR2,
                                RETCODE                         OUT NOCOPY NUMBER,
                                pBatchID                        IN  NUMBER,
                                pInstanceCode                   IN  VARCHAR2,
                                pEntityName                     IN  VARCHAR2,
                                pInstanceID                     IN  NUMBER);

END MSC_CL_PRE_PROCESS_HOOK;

 

/
