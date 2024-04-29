--------------------------------------------------------
--  DDL for Package HZ_IMP_LOAD_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_LOAD_WRAPPER" AUTHID CURRENT_USER AS
/*$Header: ARHLWRPS.pls 120.14 2005/10/30 03:53:23 appldev noship $*/

  TYPE T_ERROR_ID           IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;
  TYPE T_ENTITY_ID          IS TABLE OF NUMBER(15)  INDEX BY BINARY_INTEGER;
  TYPE T_ROWID              IS TABLE OF ROWID         INDEX BY BINARY_INTEGER;
  TYPE T_ACTION_FLAG        IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
  TYPE T_TABLE_NAME         IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
  TYPE T_ERROR		    IS TABLE OF VARCHAR2(2)   INDEX BY BINARY_INTEGER;

  TYPE INDEXVARCHAR30List IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  TYPE DML_RECORD_TYPE IS RECORD (
    BATCH_ID			NUMBER(15),
    OS				VARCHAR2(30),
    FROM_OSR			VARCHAR2(240),
    TO_OSR			VARCHAR2(240),
    ACTUAL_CONTENT_SRC		VARCHAR2(30),
    RERUN			VARCHAR2(1),
    ERROR_LIMIT			NUMBER,
    BATCH_MODE_FLAG		VARCHAR2(1),
    USER_ID			NUMBER(15),
    SYSDATE			DATE,
    LAST_UPDATE_LOGIN		NUMBER(15),
    PROGRAM_ID			NUMBER(15),
    PROGRAM_APPLICATION_ID	NUMBER(15),
    REQUEST_ID			NUMBER(15),
    APPLICATION_ID		NUMBER,
    GMISS_CHAR			VARCHAR2(240),
    GMISS_NUM			NUMBER,
    GMISS_DATE			DATE,
    FLEX_VALIDATION		VARCHAR2(1),
    DSS_SECURITY		VARCHAR2(1),
    ALLOW_DISABLED_LOOKUP	VARCHAR2(1),
    PROFILE_VERSION		VARCHAR2(30)
  );

-- Main wrapper for running data load.
PROCEDURE DATA_LOAD (
  Errbuf                      OUT NOCOPY     VARCHAR2,
  Retcode                     OUT NOCOPY     VARCHAR2,
  P_BATCH_ID                  IN             NUMBER,
  P_ORIG_SYSTEM               IN             VARCHAR2,
  P_WHAT_IF_ANALYSIS          IN             VARCHAR2,
  P_REGISTRY_DEDUP	      IN	     VARCHAR2,
  P_REGISTRY_DEDUP_MATCH_RULE_ID 	IN   NUMBER,
  P_SYSDATE                   IN             VARCHAR2,
  P_BATCH_MODE_FLAG           IN             VARCHAR2,
  P_NUM_OF_WORKERS            IN             NUMBER,
  P_ERROR_LIMIT		      IN             NUMBER,
  P_RERUN_FLAG		      IN             VARCHAR2,
  P_REQUEST_ID		      IN	     NUMBER,
  P_PROGRAM_APPLICATION_ID    IN	     NUMBER,
  P_PROGRAM_ID		      IN	     NUMBER
);

-- Wrapper for running batch data load. Call DATA_LOAD.
PROCEDURE BATCH_DATA_LOAD (
  Errbuf                      OUT NOCOPY     VARCHAR2,
  Retcode                     OUT NOCOPY     VARCHAR2,
  P_BATCH_ID                  IN             NUMBER,
  P_ORIG_SYSTEM               IN             VARCHAR2,
  P_WHAT_IF_ANALYSIS          IN             VARCHAR2,
  P_REGISTRY_DEDUP	      IN	     VARCHAR2,
  P_REGISTRY_DEDUP_MATCH_RULE_ID 	IN   NUMBER,
  P_SYSDATE                   IN             VARCHAR2,
  P_NUM_OF_WORKERS	      IN             NUMBER,
  P_ERROR_LIMIT		      IN             NUMBER,
  P_RERUN_FLAG		      IN             VARCHAR2,
  P_REQUEST_ID		      IN	     NUMBER,
  P_PROGRAM_APPLICATION_ID    IN	     NUMBER,
  P_PROGRAM_ID		      IN	     NUMBER
);

-- Wrapper for running online data load. Call DATA_LOAD.
PROCEDURE ONLINE_DATA_LOAD (
  Errbuf                      OUT NOCOPY     VARCHAR2,
  Retcode                     OUT NOCOPY     VARCHAR2,
  P_BATCH_ID                  IN             NUMBER,
  P_ORIG_SYSTEM               IN             VARCHAR2,
  P_WHAT_IF_ANALYSIS          IN             VARCHAR2,
  P_REGISTRY_DEDUP	      IN	     VARCHAR2,
  P_REGISTRY_DEDUP_MATCH_RULE_ID 	IN   NUMBER,
  P_SYSDATE                   IN             VARCHAR2,
  P_ERROR_LIMIT		      IN             NUMBER,
  P_RERUN_FLAG		      IN             VARCHAR2,
  P_REQUEST_ID		      IN	     NUMBER,
  P_PROGRAM_APPLICATION_ID    IN	     NUMBER,
  P_PROGRAM_ID		      IN	     NUMBER
);

PROCEDURE RETRIEVE_WORK_UNIT(
  P_BATCH_ID                   IN NUMBER,
  P_STAGE                      IN NUMBER,
  P_OS                         IN OUT NOCOPY VARCHAR2,
  P_FROM_OSR                   IN OUT NOCOPY VARCHAR2,
  P_TO_OSR                     IN OUT NOCOPY VARCHAR2,
  P_HWM_STAGE                  OUT NOCOPY NUMBER,
  P_PP_STATUS                  OUT NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_PP_WORK_UNIT(
  P_BATCH_ID                   IN NUMBER,
  P_PP_STATUS                  IN VARCHAR2,
  P_OS                         IN OUT NOCOPY VARCHAR2,
  P_FROM_OSR                   IN OUT NOCOPY VARCHAR2,
  P_TO_OSR                     IN OUT NOCOPY VARCHAR2
);

PROCEDURE GENERATE_ENTITIES_WORK_UNITS(
  P_BATCH_ID                      IN NUMBER,
  P_ORIG_SYSTEM                   IN VARCHAR2
);

PROCEDURE DATA_LOAD_PREPROCESSING(
  P_BATCH_ID                      IN NUMBER,
  P_ORIG_SYSTEM                   IN VARCHAR2,
  P_WHAT_IF_ANALYSIS              IN VARCHAR2,
  P_RERUN_FLAG                    OUT NOCOPY VARCHAR2
);


PROCEDURE CLEANUP_STAGING(
  P_BATCH_ID         IN NUMBER,
  P_BATCH_MODE_FLAG  IN VARCHAR2
);

FUNCTION STAGING_DATA_EXISTS(
  P_BATCH_ID         IN NUMBER,
  P_BATCH_MODE_FLAG  IN VARCHAR2,
  P_STAGE            IN NUMBER
) RETURN VARCHAR2;

END HZ_IMP_LOAD_WRAPPER;
 

/
