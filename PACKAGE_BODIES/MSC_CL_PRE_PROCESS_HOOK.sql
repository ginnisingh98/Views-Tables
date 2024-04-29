--------------------------------------------------------
--  DDL for Package Body MSC_CL_PRE_PROCESS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_PRE_PROCESS_HOOK" AS -- body
/* $Header: MSCCPPHB.pls 115.3 2002/11/29 17:33:51 rawasthi ship $ */
  PROCEDURE ENTITY_VALIDATION( ERRBUF                           OUT NOCOPY VARCHAR2,
                                RETCODE                         OUT NOCOPY NUMBER,
                                pBatchID                        IN  NUMBER,
                                pInstanceCode                   IN  VARCHAR2,
                                pEntityName                     IN  VARCHAR2,
                                pInstanceID                     IN  NUMBER)
  IS
  BEGIN
    NULL;
  END ENTITY_VALIDATION;

END MSC_CL_PRE_PROCESS_HOOK ;

/
