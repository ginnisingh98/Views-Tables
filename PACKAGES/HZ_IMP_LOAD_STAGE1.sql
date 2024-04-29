--------------------------------------------------------
--  DDL for Package HZ_IMP_LOAD_STAGE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_LOAD_STAGE1" AUTHID CURRENT_USER AS
/*$Header: ARHLS1WS.pls 120.6 2005/10/30 03:53:13 appldev noship $*/

-- Stage 1 worker process
PROCEDURE WORKER_PROCESS(
  Errbuf                      OUT NOCOPY     VARCHAR2,
  Retcode                     OUT NOCOPY     VARCHAR2,
  P_BATCH_ID                  IN             NUMBER,
  P_ACTUAL_CONTENT_SRC        IN             VARCHAR2,
  P_RERUN		      IN	     VARCHAR2,
  P_BATCH_MODE_FLAG	      IN	     VARCHAR2
);

END HZ_IMP_LOAD_STAGE1;
 

/
