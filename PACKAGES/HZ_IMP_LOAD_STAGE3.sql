--------------------------------------------------------
--  DDL for Package HZ_IMP_LOAD_STAGE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_LOAD_STAGE3" AUTHID CURRENT_USER AS
/*$Header: ARHLS3WS.pls 120.6 2005/10/30 03:53:18 appldev noship $*/

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
    P_UPDATE_STR_ADDR              IN         VARCHAR2,
    P_MAINTAIN_LOC_HIST            IN         VARCHAR2,
    P_ALLOW_ADDR_CORR              IN         VARCHAR2
);

END HZ_IMP_LOAD_STAGE3;
 

/
