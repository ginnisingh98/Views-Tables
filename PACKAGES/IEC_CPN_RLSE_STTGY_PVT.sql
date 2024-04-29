--------------------------------------------------------
--  DDL for Package IEC_CPN_RLSE_STTGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_CPN_RLSE_STTGY_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVCRLS.pls 115.20 2004/05/18 19:38:16 minwang ship $ */


---------------------------------------------------------
-- Individual subset attributes.
---------------------------------------------------------
TYPE WORKING_QUANTUM is TABLE of IEC_G_SUBSET_RT_INFO.WORKING_QUANTUM%TYPE index by binary_integer;
TYPE WORKING_QUOTA is TABLE of IEC_G_SUBSET_RT_INFO.WORKING_QUOTA%TYPE index by binary_integer;
TYPE QUANTUM is TABLE of IEC_G_LIST_SUBSETS.QUANTUM%TYPE index by binary_integer;
TYPE QUOTA is TABLE of IEC_G_LIST_SUBSETS.QUOTA%TYPE index by binary_integer;
TYPE QUOTA_RESET is TABLE of IEC_G_LIST_SUBSETS.QUOTA_RESET%TYPE index by binary_integer;
TYPE QUOTA_RESET_TIME is TABLE of IEC_G_SUBSET_RT_INFO.QUOTA_RESET_TIME%TYPE index by binary_integer;
TYPE RELEASE_STRATEGY is TABLE of IEC_G_LIST_SUBSETS.RELEASE_STRATEGY%TYPE index by binary_integer;
TYPE USE_FLAG is TABLE of IEC_G_SUBSET_RT_INFO.USE_FLAG%TYPE index by binary_integer;
TYPE SUBSET_PRIORITY is TABLE of IEC_G_LIST_SUBSETS.PRIORITY%TYPE;
TYPE SUBSET_ID is TABLE of IEC_G_LIST_SUBSETS.LIST_SUBSET_ID%TYPE;
TYPE FLAG_COLLECTION is TABLE of VARCHAR2(1) index by binary_integer;

---------------------------------------------------------
-- Individual Entry attributes.
---------------------------------------------------------
TYPE LIST_ENTRY_ID is TABLE of IEC_G_RETURN_ENTRIES.LIST_ENTRY_ID%TYPE index by binary_integer;

---------------------------------------------------------
-- Subset Release Strategies Constants
---------------------------------------------------------
QUANTUM_RLSE_STTGY CONSTANT VARCHAR2( 3 ) := 'QUA';
QUOTA_RLSE_STTGY CONSTANT VARCHAR2( 3 ) := 'QUO';

---------------------------------------------------------
-- Return Code Constants.
---------------------------------------------------------
SCHEDULE_IS_NOT_ACTIVE  CONSTANT VARCHAR2(1)         := 'A';
SCHEDULE_IS_LOCKED  CONSTANT VARCHAR2(1)             := 'L';
SCHEDULE_INTERNAL_ERROR  CONSTANT VARCHAR2(1)        := 'I';
SCHEDULE_ALL_CHECKED_OUT CONSTANT VARCHAR2(1)       := 'C';
SCHEDULE_CALLBACK_EXPIRATION  CONSTANT VARCHAR2(1)   := 'X';
SCHEDULE_CALENDAR_RESTRICTION  CONSTANT VARCHAR2(1)  := 'R';
SCHEDULE_CALENDAR_OUT  CONSTANT VARCHAR2(1)          := 'F';
SCHEDULE_CALLBACK_OUT  CONSTANT VARCHAR2(1)          := 'D';
SCHEDULE_CALENDAR_CALLBACK  CONSTANT VARCHAR2(1)     := 'B';
SCHEDULE_CALENDAR_CALLBACK_OUT  CONSTANT VARCHAR2(1) := 'Z';
SCHEDULE_IS_EMPTY  CONSTANT VARCHAR2(1)              := 'E';

---------------------------------------------------------
-- Sub-Program Unit Declarations
-- Check if a cpn is active..
---------------------------------------------------------
PROCEDURE IS_SCHEDULE_ACTIVE
  (P_SCHEDULE_ID    IN            NUMBER
  ,X_ACTIVE         IN OUT NOCOPY VARCHAR2
  );

-- Update RT info

PROCEDURE UPDATE_SUBSET_RT_INFO
  (P_CAMPAIGN_ID    IN            NUMBER
  ,P_LIST_HEADER_ID IN            NUMBER
  ,P_SUBSET_ID      IN            NUMBER
  ,P_QUANTUM        IN            NUMBER
  ,P_QUOTA          IN            NUMBER
  ,P_QUOTA_RESET    IN            DATE
  ,P_USE_FLAG       IN            VARCHAR2
  ,X_RESULT         IN OUT NOCOPY VARCHAR2
  );

PROCEDURE GET_CALLBACKS
  (P_SERVER_ID              IN            NUMBER
  ,P_CAMPAIGN_ID            IN            NUMBER
  ,P_SCHEDULE_ID            IN            NUMBER
  ,P_LIST_ID                IN            NUMBER
  ,P_COUNT                  IN            NUMBER
  ,P_VIEW_NAME              IN            VARCHAR2
  ,P_RLSE_CTRL_ALG_ID       IN            NUMBER
  ,X_RETURNS_ID_TAB            OUT NOCOPY SYSTEM.NUMBER_TBL_TYPE
  ,X_RETURN_CODE            IN OUT NOCOPY VARCHAR2
  );

PROCEDURE GET_CUST_CALLBACKS
  (P_SERVER_ID              IN            NUMBER
  ,P_CAMPAIGN_ID            IN            NUMBER
  ,P_SCHEDULE_ID            IN            NUMBER
  ,P_LIST_ID                IN            NUMBER
  ,P_VIEW_NAME              IN            VARCHAR2
  ,P_RLSE_CTRL_ALG_ID       IN            NUMBER
  ,X_RETURNS_ID_TAB            OUT NOCOPY SYSTEM.NUMBER_TBL_TYPE
  ,X_RETURN_CODE            IN OUT NOCOPY VARCHAR2
  );

PROCEDURE GET_SUBSET_ENTRIES
  (P_CAMPAIGN_ID       IN            NUMBER
  ,P_LIST_HEADER_ID    IN            NUMBER
  ,P_SUBSET_ID         IN            NUMBER
  ,P_COUNT             IN            NUMBER
  ,P_RLSE_CTRL_ALG_ID  IN            IEC_G_EXECUTING_LISTS_V.RELEASE_CONTROL_ALG_ID%TYPE
  ,P_VIEW_NAME         IN            VARCHAR2
  ,X_RETURN_CODE       IN OUT NOCOPY VARCHAR2
  ,X_RETURNS_ID_TAB    IN OUT NOCOPY SYSTEM.NUMBER_TBL_TYPE
  );


PROCEDURE GET_SCHED_ENTRIES
  (P_CAMPAIGN_ID       IN            NUMBER
  ,P_SCHED_ID          IN            NUMBER
  ,P_LIST_HEADER_ID    IN            NUMBER
  ,P_COUNT             IN            NUMBER
  ,P_VIEW_NAME         IN            VARCHAR2
  ,P_RLSE_CTRL_ALG_ID  IN            NUMBER
  ,X_RETURN_CODE       IN OUT NOCOPY VARCHAR2
  ,X_RETURNS_ID_TAB    IN OUT NOCOPY SYSTEM.NUMBER_TBL_TYPE
  );

-- Get the records.

PROCEDURE GET_RECORDS
  (P_SERVER_ID        IN            NUMBER
  ,P_CAMPAIGN_ID      IN            NUMBER
  ,P_SCHED_ID         IN            NUMBER
  ,P_TARGET_GROUP_ID  IN            NUMBER
  ,P_COUNT            IN            NUMBER
  ,P_VIEW_NAME        IN            VARCHAR2
  ,P_RLSE_CTRL_ALG_ID IN            NUMBER
  ,X_CACHE_RECORDS       OUT NOCOPY SYSTEM.NUMBER_TBL_TYPE
  ,X_RETURN_CODE         OUT NOCOPY VARCHAR2
  );


END IEC_CPN_RLSE_STTGY_PVT;

 

/
