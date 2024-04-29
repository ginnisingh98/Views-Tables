--------------------------------------------------------
--  DDL for Package IEC_EXECOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_EXECOCS_PVT" AUTHID CURRENT_USER AS
/* $Header: IECOCEXS.pls 115.22.1158.3 2002/10/02 17:53:04 lcrew ship $ */

-- Generic initial parameter, record and table defs used by CALL_IH
   L_INITIAL NUMBER :=0;
   L_INTERACTION_REC    JTF_IH_PUB.interaction_rec_type;
   L_ACTIVITIES_TBL     JTF_IH_PUB.activity_tbl_type;
   L_MEDIA_REC		JTF_IH_PUB.media_rec_type;
   L_MEDIA_LC_REC	JTF_IH_PUB.media_lc_rec_type;

-- Sub-Program Unit Declarations

/* Called by the Callback Plugin. */
PROCEDURE HANDLE_CALLBACKS
   ( P_SOURCE_ID          IN       NUMBER
   , P_SCHED_ID           IN       NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   );

/* Called by the Status Plugin. */
PROCEDURE HANDLE_STATUS_TRANSITIONS
   ( P_SOURCE_ID          IN       NUMBER
   , P_SERVER_ID          IN       NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   );

/* Called by the Retrieve Plugin. */
PROCEDURE POPULATE_CACHE
   ( P_SOURCE_ID          IN     NUMBER
   , P_SCHEDULE_ID        IN     NUMBER
   , P_LOW_THRESH_PCT     IN     NUMBER
   , P_HIGH_THRESH_PCT    IN     NUMBER
   , P_LIST_INCREASE_PCT  IN     NUMBER
   , P_INIT_CACHE_PCT     IN     NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   );

/* Called by the Recover Plugin. */
PROCEDURE REFRESH_ENTRIES
   ( P_SOURCE_ID          IN       NUMBER
   , P_STALE_INTERVAL      IN       NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   );

/* Called by the Recover Plugin. */
PROCEDURE RECOVER_ENTRIES
   ( P_SOURCE_ID          IN       NUMBER
   , P_LOST_INTERVAL      IN       NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   );

/* Called by the Recycle Plugin. */
PROCEDURE RECYCLE_ENTRIES
   ( P_SOURCE_ID          IN       NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   );

/* Called by HANDLE_STATUS_TRANSITIONS */
/* to update the status of an AMS list */
PROCEDURE UPDATE_LIST_STATUS
   ( P_LIST_HEADER_ID     IN       NUMBER
   , P_SOURCE_ID          IN       NUMBER
   , P_STATUS             IN       NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   );

/* Called by Recycle Process to recoed IH related Information. */
PROCEDURE CALL_IH
   ( P_PARTY_ID 	IN	NUMBER
   , P_START_TIME	IN	DATE
   , P_END_TIME		IN	DATE
   , P_OUTCOME_ID	IN	NUMBER
   , P_REASON_ID	IN	NUMBER
   , P_RESULT_ID	IN	NUMBER
   , P_ACTION_ITEM_ID   IN	NUMBER
   ,X_RETURN_STATUS	OUT	VARCHAR2
   );

/* Called by Recover plugin to remove uneccesary entries from cache. */
PROCEDURE REMOVE_OLD_ENTRIES
   ( SCHED_ID IN NUMBER
   , LIST_ID  IN NUMBER
   , SUBSET_ID IN NUMBER
   , X_RETURN_STATUS	OUT	VARCHAR2
   );

PROCEDURE INSERT_LIST_RETURNS_RECORDS
   ( P_SCHED_ID IN NUMBER
   , P_LIST_ID  IN NUMBER
   , P_VIEW_NAME IN VARCHAR2
   , P_DIALING_METHOD IN VARCHAR2
   , X_RETURN_STATUS    OUT     VARCHAR2
   );

END IEC_EXECOCS_PVT;


 

/
