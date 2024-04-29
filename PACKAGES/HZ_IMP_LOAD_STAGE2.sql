--------------------------------------------------------
--  DDL for Package HZ_IMP_LOAD_STAGE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_LOAD_STAGE2" AUTHID CURRENT_USER AS
/*$Header: ARHLS2WS.pls 120.8 2005/10/30 03:53:16 appldev noship $*/

/*
  TYPE DML_RECORD_TYPE IS RECORD (
   BATCH_ID	              NUMBER(15,0),
   OS	                      VARCHAR2(30),
   FROM_OSR                   VARCHAR2(240),
   TO_OSR                     VARCHAR2(240),
   ACTUAL_CONTENT_SRC         VARCHAR2(30),
   RERUN                      VARCHAR2(1),
   ERROR_LIMIT                NUMBER,
   BATCH_MODE_FLAG            VARCHAR2(1),
   USER_ID                    NUMBER(15,0),
   SYS_DATE                   DATE,
   LAST_UPDATE_LOGIN          NUMBER(15,0),
   PROGRAM_ID                 NUMBER(15,0),
   PROGRAM_APPLICATION_ID     NUMBER(15,0),
   REQUEST_ID                 NUMBER(15,0),
   APPLICATION_ID             NUMBER,
   GMISS_CHAR                 VARCHAR2(1),
   GMISS_NUM                  NUMBER,
   GMISS_DATE                 DATE,
   FLEX_VALIDATION            VARCHAR2(1),
   DSS_SECURITY               VARCHAR2(1),
   ALLOW_DISABLED_LOOKUP      VARCHAR2(1),
   PROFILE_VERSION            VARCHAR2(30)
  );
*/
  -- Stage 1 worker process
  PROCEDURE WORKER_PROCESS(
    Errbuf                         OUT NOCOPY VARCHAR2,
    Retcode                        OUT NOCOPY VARCHAR2,
    P_BATCH_ID                     IN         NUMBER,
    P_ACTUAL_CONTENT_SRC           IN         VARCHAR2,
    P_RERUN                        IN         VARCHAR2,
    P_ERROR_LIMIT                  IN         NUMBER,
    P_BATCH_MODE_FLAG              IN         VARCHAR2,
    P_USER_ID                      IN         NUMBER,
    --bug 3932987
    --P_SYSDATE                      IN         DATE,
    P_SYSDATE                      IN         VARCHAR2,
    P_LAST_UPDATE_LOGIN            IN         NUMBER,
    P_PROGRAM_ID                   IN         NUMBER,
    P_PROGRAM_APPLICATION_ID       IN         NUMBER,
    P_REQUEST_ID                   IN         NUMBER,
    P_APPLICATION_ID               IN         NUMBER,
    P_GMISS_CHAR                   IN         VARCHAR2,
    P_GMISS_NUM	                   IN         NUMBER,
    P_GMISS_DATE                   IN         DATE,
    P_FLEX_VALIDATION              IN         VARCHAR2,
    P_DSS_SECURITY                 IN         VARCHAR2,
    P_ALLOW_DISABLED_LOOKUP        IN         VARCHAR2,
    P_PROFILE_VERSION              IN         VARCHAR2,
    P_WHAT_IF_ANALYSIS             IN         VARCHAR2,
    P_REGISTRY_DEDUP               IN         VARCHAR2,
    P_REGISTRY_DEDUP_MATCH_RULE_ID IN         VARCHAR2
  );

  PROCEDURE ERROR_LIMIT_HANDLING(
    P_BATCH_ID                 IN             NUMBER,
    P_BATCH_MODE_FLAG          IN             VARCHAR2
  );

END HZ_IMP_LOAD_STAGE2;
 

/
