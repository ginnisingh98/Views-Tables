--------------------------------------------------------
--  DDL for Package Body IEC_QUOTAUPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_QUOTAUPDATE_PVT" AS
/* $Header: IECVQUOB.pls 115.10 2004/05/03 17:47:57 minwang noship $ */

PROCEDURE UPDATE_QUOTA_LIST
   (P_QUOTA_USED            IN NUMBER
   ,P_LIST_HEADER_ID        IN NUMBER
   ,X_WORKING_QUOTA         OUT NOCOPY NUMBER
   )
IS
   l_rt_quota NUMBER;
   CURSOR c_quota IS
     SELECT nvl(QUOTA,0) QUOTA, RELEASE_STRATEGY, nvl(WORKING_QUOTA,0) WORKING_QUOTA
      FROM IEC_G_LIST_RT_INFO WHERE LIST_HEADER_ID = P_LIST_HEADER_ID
        for UPDATE OF WORKING_QUOTA;

BEGIN

    l_rt_quota := -1;
    FOR v_quota IN c_quota LOOP
	    IF v_quota.release_strategy = 'QUO' THEN
	      IF v_quota.quota > 0 THEN
          IF (v_quota.working_quota - P_QUOTA_USED) < 0 THEN
                l_rt_quota := 0;
          ELSE
                l_rt_quota := v_quota.working_quota - P_QUOTA_USED;
          END IF;
        --  dbms_output.put_line('l_rt_quota='|| l_rt_quota );
          UPDATE IEC_G_LIST_RT_INFO SET
          WORKING_QUOTA = l_rt_quota WHERE CURRENT OF c_quota;
        END IF;
      END IF;
    END LOOP;
    X_WORKING_QUOTA := l_rt_quota;
END UPDATE_QUOTA_LIST;

PROCEDURE UPDATE_QUOTA_SUBSET
   (P_QUOTA_USED            IN NUMBER
   ,P_LIST_SUBSET_ID        IN NUMBER
   ,X_WORKING_QUOTA         OUT NOCOPY NUMBER
   )
IS
   l_rt_quota NUMBER;
   l_quota  NUMBER;
   l_release_strategy VARCHAR2(30);
   CURSOR c_quota IS
        SELECT nvl(WORKING_QUOTA,0) WORKING_QUOTA
      FROM IEC_G_SUBSET_RT_INFO WHERE LIST_SUBSET_ID = P_LIST_SUBSET_ID
        for UPDATE OF WORKING_QUOTA;

BEGIN

    l_rt_quota := -1;
    l_quota  := 0;
    l_release_strategy  := '';

    SELECT nvl(QUOTA,0), RELEASE_STRATEGY into l_quota,l_release_strategy
    FROM IEC_G_LIST_SUBSETS WHERE LIST_SUBSET_ID = P_LIST_SUBSET_ID;
    IF l_release_strategy = 'QUO' THEN
      IF l_quota >= 0 THEN

        FOR v_quota IN c_quota LOOP
          IF (v_quota.working_quota - P_QUOTA_USED) < 0 THEN
                l_rt_quota := 0;
          ELSE
                l_rt_quota := v_quota.working_quota - P_QUOTA_USED;
          END IF;

          UPDATE IEC_G_SUBSET_RT_INFO SET
          WORKING_QUOTA = l_rt_quota WHERE CURRENT OF c_quota;
        END LOOP;
      END IF;
    END IF;
    X_WORKING_QUOTA := l_rt_quota;
END UPDATE_QUOTA_SUBSET;

PROCEDURE UPDATE_QUOTA
   (P_ID                    IN NUMBER
   ,P_TYPE                  IN VARCHAR2
   ,P_QUOTA_USED            IN NUMBER
   ,X_WORKING_QUOTA         OUT NOCOPY NUMBER
	 )
IS
BEGIN
    IF P_TYPE = 'L' THEN
                  UPDATE_QUOTA_LIST( P_QUOTA_USED
                                   , P_ID
                                   , X_WORKING_QUOTA);
    ELSE
                  UPDATE_QUOTA_SUBSET( P_QUOTA_USED
                                     , P_ID
                                     , X_WORKING_QUOTA);
    END IF;
END UPDATE_QUOTA;

PROCEDURE UPDATE_QUOTA
   (P_ID                    IN NUMBER
   ,P_TYPE                  IN VARCHAR2
   ,P_QUOTA_USED            IN NUMBER
	 )
IS
   L_WORKING_QUOTA         NUMBER;

BEGIN
    IF P_TYPE = 'L' THEN
                  UPDATE_QUOTA_LIST( P_QUOTA_USED
                                   , P_ID
                                   , L_WORKING_QUOTA);
    ELSE
                  UPDATE_QUOTA_SUBSET( P_QUOTA_USED
                                     , P_ID
                                     , L_WORKING_QUOTA);
    END IF;
END UPDATE_QUOTA;

END IEC_QUOTAUPDATE_PVT;


/
